--------------------------------------------------------
--  DDL for Package Body WMS_CARTNZN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CARTNZN_PUB" AS
/* $Header: WMSCRTNB.pls 120.15.12010000.6 2009/11/26 10:04:05 abasheer ship $*/
--
-- File        : WMSCRTNB.pls
-- Content     : WMS_CARTNZN_PUB package specification
-- Description : WMS cartonization API
-- Notes       :
-- Modified    : 09/12/2000 cjandhya created


-- API name    : cartonize
-- Type        : group
-- Function    : populates the cartonization_id, container_item_id columns,
--               of rows belonging to a particular move order header id in
--               mtl_material_transactions_temp.

-- Pre-reqs    :  Those columns wouldn't be populated if the cartonization_id
--                for that row is already populated,
--                or if values for organization_id, inventory_item_id ,
--                primary qunatity, transaction_quantity,  transaction_uom,
--                trans action_temp_id are not all filled or if there is no
--                conversion defined between primary and transaction uoms of
--                the item of interest. each item has to be assigned to a
--                category of contained_item category set and that category
--                should have some container items.
--                The lines that can be packed together are identified by the
--                carton_grouping_id(MTL_TXN_REQEST_LINES) for the
--                move_order_line_id of that line.


-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   p_out_bound            specifies if the call is for outbound process
--   p_org_id                 organization_id
--   p_move_order_header_id header_id for the lines to be cartonized


-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter

-- Version
--   Currently version is 1.0

   PROCEDURE rulebased_cartonization(
                      x_return_status         OUT   NOCOPY VARCHAR2,
                      x_msg_count             OUT   NOCOPY NUMBER,
                      x_msg_data              OUT   NOCOPY VARCHAR2,
                      p_out_bound             IN    VARCHAR2,
                      p_org_id                IN    NUMBER,
                      p_move_order_header_id  IN    NUMBER,
                      p_input_for_bulk        IN    WMS_BULK_PICK.bulk_input_rec  DEFAULT null
                      );


 G_PKG_NAME   CONSTANT VARCHAR2(30) := 'WMS_CARTNZN_PUB';
 g_current_release_level CONSTANT NUMBER  :=  WMS_CONTROL.G_CURRENT_RELEASE_LEVEL;
 g_j_release_level  CONSTANT NUMBER := INV_RELEASE.G_J_RELEASE_LEVEL;
 g_k_release_level  CONSTANT NUMBER := INV_RELEASE.G_K_RELEASE_LEVEL;  -- ER : 6682436
 g_move_order_pick_wave CONSTANT NUMBER       := inv_globals.g_move_order_pick_wave;


 CURR_HEADER_ID_FOR_MIXED  NUMBER;
 PREV_HEADER_ID_FOR_MIXED  NUMBER;

 -- variable used to store the error code, pushed into stack on error
 ERROR_CODE            VARCHAR2(30)  := NULL;
 ERROR_MSG             VARCHAR2(255) := NULL;


 --  Record type used to store the original and the transaction_temp_id
 --  split from it

 TYPE t_temp_id_rel_rec IS RECORD
   (
     orig_temp_id mtl_material_transactions_temp.transaction_temp_id%TYPE ,
     splt_temp_id mtl_material_transactions_temp.transaction_temp_id%TYPE,
     primary_quantity NUMBER,
     secondary_quantity NUMBER,
     processed VARCHAR2(1) := 'N');


 TYPE t_temp_id_rel_tb IS TABLE OF t_temp_id_rel_rec INDEX BY  BINARY_INTEGER;

 --  TABLE used to store the original and the transaction_temp_id
 --  split from it

 TEMP_ID_TABLE       t_temp_id_rel_tb;

 TEMP_ID_TABLE_INDEX NUMBER := 0;

 --Variable storing if log is enabled
 g_trace_on           NUMBER := NULL;

  --for device integration
 SUBTYPE WDR_ROW IS WMS_DEVICE_REQUESTS%ROWTYPE;

 SUBTYPE MMTT_ROW_TYPE IS MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE;

 -- Table that needs to be passed inv_rcv_common_apis for splitting
 -- mtl_transaction_lots_temp and mtl_serial_numbers_temp

 api_table inv_rcv_common_apis.trans_rec_tb_tp;

 -- This value is incremented and inserted into sequence_id of the table
 -- wms_packaging_hist on every insert
 --sequence_id      NUMBER := 1;


 dummy_header_id  NUMBER := -1;
 dummy_temp_id    NUMBER := -1;

 -- Mode in which cartonization is called
 packaging_mode      NUMBER := 1;

 -- caching items associated with LPNs and packages
 cache_package_id     NUMBER := -1;
 cache_pkg_item_id    NUMBER := NULL;

 cache_lpn_id         NUMBER := -1;
 cache_lpn_item_id    NUMBER := NULL;

 --Bug 2520774 fix
 l_auto_pick_confirm_flag   VARCHAR2(1)   := 'N';


 FUNCTION to_mmtt(wct_rec wct_row_type) RETURN mmtt_row_type
   IS
      mmt_rec mmtt_row_type;
 BEGIN

    mmt_rec.transaction_header_id:=wct_rec.transaction_header_id;
    mmt_rec.transaction_temp_id:=wct_rec.transaction_temp_id;
    mmt_rec.source_code:=wct_rec.source_code;
    mmt_rec.source_line_id:=wct_rec.source_line_id;
    mmt_rec.transaction_mode:=wct_rec.transaction_mode;
    mmt_rec.lock_flag:=wct_rec.lock_flag;
    mmt_rec.last_update_date:=wct_rec.last_update_date;
    mmt_rec.last_updated_by:=wct_rec.last_updated_by;
    mmt_rec.creation_date:=wct_rec.creation_date;
    mmt_rec.created_by:=wct_rec.created_by;
    mmt_rec.last_update_login:=wct_rec.last_update_login;
    mmt_rec.request_id:=wct_rec.request_id;
    mmt_rec.program_application_id:=wct_rec.program_application_id;
    mmt_rec.program_id:=wct_rec.program_id;
    mmt_rec.program_update_date:=wct_rec.program_update_date;
    mmt_rec.inventory_item_id:=wct_rec.inventory_item_id;
    mmt_rec.revision:=wct_rec.revision;
    mmt_rec.organization_id:=wct_rec.organization_id;
    mmt_rec.subinventory_code:=wct_rec.subinventory_code;
    mmt_rec.locator_id:=wct_rec.locator_id;
    mmt_rec.transaction_quantity:=wct_rec.transaction_quantity;
    mmt_rec.primary_quantity:=wct_rec.primary_quantity;
    mmt_rec.transaction_uom:=wct_rec.transaction_uom;
    mmt_rec.transaction_cost:=wct_rec.transaction_cost;
    mmt_rec.transaction_type_id:=wct_rec.transaction_type_id;
    mmt_rec.transaction_action_id:=wct_rec.transaction_action_id;
    mmt_rec.transaction_source_type_id:=wct_rec.transaction_source_type_id;
    mmt_rec.transaction_source_id:=wct_rec.transaction_source_id;
    mmt_rec.transaction_source_name:=wct_rec.transaction_source_name;
    mmt_rec.transaction_date:=wct_rec.transaction_date;
    mmt_rec.acct_period_id:=wct_rec.acct_period_id;
    mmt_rec.distribution_account_id:=wct_rec.distribution_account_id;
    mmt_rec.transaction_reference:=wct_rec.transaction_reference;
    mmt_rec.requisition_line_id:=wct_rec.requisition_line_id;
    mmt_rec.requisition_distribution_id:=wct_rec.requisition_distribution_id;
    mmt_rec.reason_id:=wct_rec.reason_id;
    mmt_rec.lot_number:=wct_rec.lot_number;
    mmt_rec.lot_expiration_date:=wct_rec.lot_expiration_date;
    mmt_rec.serial_number:=wct_rec.serial_number;
    mmt_rec.receiving_document:=wct_rec.receiving_document;
    mmt_rec.demand_id:=wct_rec.demand_id;
    mmt_rec.rcv_transaction_id:=wct_rec.rcv_transaction_id;
    mmt_rec.move_transaction_id:=wct_rec.move_transaction_id;
    mmt_rec.completion_transaction_id:=wct_rec.completion_transaction_id;
    mmt_rec.wip_entity_type:=wct_rec.wip_entity_type;
    mmt_rec.schedule_id:=wct_rec.schedule_id;
    mmt_rec.repetitive_line_id:=wct_rec.repetitive_line_id;
    mmt_rec.employee_code:=wct_rec.employee_code;
    mmt_rec.primary_switch:=wct_rec.primary_switch;
    mmt_rec.schedule_update_code:=wct_rec.schedule_update_code;
    mmt_rec.setup_teardown_code:=wct_rec.setup_teardown_code;
    mmt_rec.item_ordering:=wct_rec.item_ordering;
    mmt_rec.negative_req_flag:=wct_rec.negative_req_flag;
    mmt_rec.operation_seq_num:=wct_rec.operation_seq_num;
    mmt_rec.picking_line_id:=wct_rec.picking_line_id;
    mmt_rec.trx_source_line_id:=wct_rec.trx_source_line_id;
    mmt_rec.trx_source_delivery_id:=wct_rec.trx_source_delivery_id;
    mmt_rec.physical_adjustment_id:=wct_rec.physical_adjustment_id;
    mmt_rec.cycle_count_id:=wct_rec.cycle_count_id;
    mmt_rec.rma_line_id:=wct_rec.rma_line_id;
    mmt_rec.customer_ship_id:=wct_rec.customer_ship_id;
    mmt_rec.currency_code:=wct_rec.currency_code;
    mmt_rec.currency_conversion_rate:=wct_rec.currency_conversion_rate;
    mmt_rec.currency_conversion_type:=wct_rec.currency_conversion_type;
    mmt_rec.currency_conversion_date:=wct_rec.currency_conversion_date;
    mmt_rec.ussgl_transaction_code:=wct_rec.ussgl_transaction_code;
    mmt_rec.vendor_lot_number:=wct_rec.vendor_lot_number;
    mmt_rec.encumbrance_account:=wct_rec.encumbrance_account;
    mmt_rec.encumbrance_amount:=wct_rec.encumbrance_amount;
    mmt_rec.ship_to_location:=wct_rec.ship_to_location;
    mmt_rec.shipment_number:=wct_rec.shipment_number;
    mmt_rec.transfer_cost:=wct_rec.transfer_cost;
    mmt_rec.transportation_cost:=wct_rec.transportation_cost;
    mmt_rec.transportation_account:=wct_rec.transportation_account;
    mmt_rec.freight_code:=wct_rec.freight_code;
    mmt_rec.containers:=wct_rec.containers;
    mmt_rec.waybill_airbill:=wct_rec.waybill_airbill;
    mmt_rec.expected_arrival_date:=wct_rec.expected_arrival_date;
    mmt_rec.transfer_subinventory:=wct_rec.transfer_subinventory;
    mmt_rec.transfer_organization:=wct_rec.transfer_organization;
    mmt_rec.transfer_to_location:=wct_rec.transfer_to_location;
    mmt_rec.new_average_cost:=wct_rec.new_average_cost;
    mmt_rec.value_change:=wct_rec.value_change;
    mmt_rec.percentage_change:=wct_rec.percentage_change;
    mmt_rec.material_allocation_temp_id:=wct_rec.material_allocation_temp_id;
    mmt_rec.demand_source_header_id:=wct_rec.demand_source_header_id;
    mmt_rec.demand_source_line:=wct_rec.demand_source_line;
    mmt_rec.demand_source_delivery:=wct_rec.demand_source_delivery;
    mmt_rec.item_segments:=wct_rec.item_segments;
    mmt_rec.item_description:=wct_rec.item_description;
    mmt_rec.item_trx_enabled_flag:=wct_rec.item_trx_enabled_flag;
    mmt_rec.item_location_control_code:=wct_rec.item_location_control_code;
    mmt_rec.item_restrict_subinv_code:=wct_rec.item_restrict_subinv_code;
    mmt_rec.item_restrict_locators_code:=wct_rec.item_restrict_locators_code;
    mmt_rec.item_revision_qty_control_code:=wct_rec.item_revision_qty_control_code;
    mmt_rec.item_primary_uom_code:=wct_rec.item_primary_uom_code;
    mmt_rec.item_uom_class:=wct_rec.item_uom_class;
    mmt_rec.item_shelf_life_code:=wct_rec.item_shelf_life_code;
    mmt_rec.item_shelf_life_days:=wct_rec.item_shelf_life_days;
    mmt_rec.item_lot_control_code:=wct_rec.item_lot_control_code;
    mmt_rec.item_serial_control_code:=wct_rec.item_serial_control_code;
    mmt_rec.item_inventory_asset_flag:=wct_rec.item_inventory_asset_flag;
    mmt_rec.allowed_units_lookup_code:=wct_rec.allowed_units_lookup_code;
    mmt_rec.department_id:=wct_rec.department_id;
    mmt_rec.department_code:=wct_rec.department_code;
    mmt_rec.wip_supply_type:=wct_rec.wip_supply_type;
    mmt_rec.supply_subinventory:=wct_rec.supply_subinventory;
    mmt_rec.supply_locator_id:=wct_rec.supply_locator_id;
    mmt_rec.valid_subinventory_flag:=wct_rec.valid_subinventory_flag;
    mmt_rec.valid_locator_flag:=wct_rec.valid_locator_flag;
    mmt_rec.locator_segments:=wct_rec.locator_segments;
    mmt_rec.current_locator_control_code:=wct_rec.current_locator_control_code;
    mmt_rec.number_of_lots_entered:=wct_rec.number_of_lots_entered;
    mmt_rec.wip_commit_flag:=wct_rec.wip_commit_flag;
    mmt_rec.next_lot_number:=wct_rec.next_lot_number;
    mmt_rec.lot_alpha_prefix:=wct_rec.lot_alpha_prefix;
    mmt_rec.next_serial_number:=wct_rec.next_serial_number;
    mmt_rec.serial_alpha_prefix:=wct_rec.serial_alpha_prefix;
    mmt_rec.shippable_flag:=wct_rec.shippable_flag;
    mmt_rec.posting_flag:=wct_rec.posting_flag;
    mmt_rec.required_flag:=wct_rec.required_flag;
    mmt_rec.process_flag:=wct_rec.process_flag;
    mmt_rec.error_code:=wct_rec.error_code;
    mmt_rec.error_explanation:=wct_rec.error_explanation;
    mmt_rec.attribute_category:=wct_rec.attribute_category;
    mmt_rec.attribute1:=wct_rec.attribute1;
    mmt_rec.attribute2:=wct_rec.attribute2;
    mmt_rec.attribute3:=wct_rec.attribute3;
    mmt_rec.attribute4:=wct_rec.attribute4;
    mmt_rec.attribute5:=wct_rec.attribute5;
    mmt_rec.attribute6:=wct_rec.attribute6;
    mmt_rec.attribute7:=wct_rec.attribute7;
    mmt_rec.attribute8:=wct_rec.attribute8;
    mmt_rec.attribute9:=wct_rec.attribute9;
    mmt_rec.attribute10:=wct_rec.attribute10;
    mmt_rec.attribute11:=wct_rec.attribute11;
    mmt_rec.attribute12:=wct_rec.attribute12;
    mmt_rec.attribute13:=wct_rec.attribute13;
    mmt_rec.attribute14:=wct_rec.attribute14;
    mmt_rec.attribute15:=wct_rec.attribute15;
    mmt_rec.movement_id:=wct_rec.movement_id;
    mmt_rec.reservation_quantity:=wct_rec.reservation_quantity;
    mmt_rec.shipped_quantity:=wct_rec.shipped_quantity;
    mmt_rec.transaction_line_number:=wct_rec.transaction_line_number;
    mmt_rec.task_id:=wct_rec.task_id;
    mmt_rec.to_task_id:=wct_rec.to_task_id;
    mmt_rec.source_task_id:=wct_rec.source_task_id;
    mmt_rec.project_id:=wct_rec.project_id;
    mmt_rec.source_project_id:=wct_rec.source_project_id;
    mmt_rec.pa_expenditure_org_id:=wct_rec.pa_expenditure_org_id;
    mmt_rec.to_project_id:=wct_rec.to_project_id;
    mmt_rec.expenditure_type:=wct_rec.expenditure_type;
    mmt_rec.final_completion_flag:=wct_rec.final_completion_flag;
    mmt_rec.transfer_percentage:=wct_rec.transfer_percentage;
    mmt_rec.transaction_sequence_id:=wct_rec.transaction_sequence_id;
    mmt_rec.material_account:=wct_rec.material_account;
    mmt_rec.material_overhead_account:=wct_rec.material_overhead_account;
    mmt_rec.resource_account:=wct_rec.resource_account;
    mmt_rec.outside_processing_account:=wct_rec.outside_processing_account;
    mmt_rec.overhead_account:=wct_rec.overhead_account;
    mmt_rec.flow_schedule:=wct_rec.flow_schedule;
    mmt_rec.cost_group_id:=wct_rec.cost_group_id;
    mmt_rec.demand_class:=wct_rec.demand_class;
    mmt_rec.qa_collection_id:=wct_rec.qa_collection_id;
    mmt_rec.kanban_card_id:=wct_rec.kanban_card_id;
    mmt_rec.overcompletion_transaction_qty:=wct_rec.overcompletion_transaction_qty;
    mmt_rec.overcompletion_primary_qty:=wct_rec.overcompletion_primary_qty;
    mmt_rec.overcompletion_transaction_id:=wct_rec.overcompletion_transaction_id;
    mmt_rec.end_item_unit_number:=wct_rec.end_item_unit_number;
    mmt_rec.scheduled_payback_date:=wct_rec.scheduled_payback_date;
    mmt_rec.line_type_code:=wct_rec.line_type_code;
    mmt_rec.parent_transaction_temp_id:=wct_rec.parent_transaction_temp_id;
    mmt_rec.put_away_strategy_id:=wct_rec.put_away_strategy_id;
    mmt_rec.put_away_rule_id:=wct_rec.put_away_rule_id;
    mmt_rec.pick_strategy_id:=wct_rec.pick_strategy_id;
    mmt_rec.pick_rule_id:=wct_rec.pick_rule_id;
    mmt_rec.move_order_line_id:=wct_rec.move_order_line_id;
    mmt_rec.task_group_id:=wct_rec.task_group_id;
    mmt_rec.pick_slip_number:=wct_rec.pick_slip_number;
    mmt_rec.reservation_id:=wct_rec.reservation_id;
    mmt_rec.common_bom_seq_id:=wct_rec.common_bom_seq_id;
    mmt_rec.common_routing_seq_id:=wct_rec.common_routing_seq_id;
    mmt_rec.org_cost_group_id:=wct_rec.org_cost_group_id;
    mmt_rec.cost_type_id:=wct_rec.cost_type_id;
    mmt_rec.transaction_status:=wct_rec.transaction_status;
    mmt_rec.standard_operation_id:=wct_rec.standard_operation_id;
    mmt_rec.task_priority:=wct_rec.task_priority;
    mmt_rec.wms_task_type:=wct_rec.wms_task_type;
    mmt_rec.parent_line_id:=wct_rec.parent_line_id;
    mmt_rec.transfer_cost_group_id:=wct_rec.transfer_cost_group_id;
    mmt_rec.lpn_id:=wct_rec.lpn_id;
    mmt_rec.transfer_lpn_id:=wct_rec.transfer_lpn_id;
    mmt_rec.wms_task_status:=wct_rec.wms_task_status;
    mmt_rec.content_lpn_id:=wct_rec.content_lpn_id;
    mmt_rec.container_item_id:=wct_rec.container_item_id;
    mmt_rec.cartonization_id:=wct_rec.cartonization_id;
    mmt_rec.pick_slip_date:=wct_rec.pick_slip_date;
    mmt_rec.rebuild_item_id:=wct_rec.rebuild_item_id;
    mmt_rec.rebuild_serial_number:=wct_rec.rebuild_serial_number;
    mmt_rec.rebuild_activity_id:=wct_rec.rebuild_activity_id;
    mmt_rec.rebuild_job_name:=wct_rec.rebuild_job_name;
    mmt_rec.organization_type:=wct_rec.organization_type;
    mmt_rec.transfer_organization_type:=wct_rec.transfer_organization_type;
    mmt_rec.owning_organization_id:=wct_rec.owning_organization_id;
    mmt_rec.owning_tp_type:=wct_rec.owning_tp_type;
    mmt_rec.xfr_owning_organization_id:=wct_rec.xfr_owning_organization_id;
    mmt_rec.transfer_owning_tp_type:=wct_rec.transfer_owning_tp_type;
    mmt_rec.planning_organization_id:=wct_rec.planning_organization_id;
    mmt_rec.planning_tp_type:=wct_rec.planning_tp_type;
    mmt_rec.xfr_planning_organization_id:=wct_rec.xfr_planning_organization_id;
    mmt_rec.transfer_planning_tp_type:=wct_rec.transfer_planning_tp_type;
    mmt_rec.secondary_uom_code:=wct_rec.secondary_uom_code;
    mmt_rec.secondary_transaction_quantity:=wct_rec.secondary_transaction_quantity;
    mmt_rec.transaction_batch_id:=wct_rec.transaction_batch_id;
    mmt_rec.transaction_batch_seq:=wct_rec.transaction_batch_seq;
    mmt_rec.allocated_lpn_id:=wct_rec.allocated_lpn_id;
    mmt_rec.schedule_number:=wct_rec.schedule_number;
    mmt_rec.scheduled_flag:=wct_rec.scheduled_flag;
    mmt_rec.class_code:=wct_rec.class_code;
    mmt_rec.schedule_group:=wct_rec.schedule_group;
    mmt_rec.build_sequence:=wct_rec.build_sequence;
    mmt_rec.bom_revision:=wct_rec.bom_revision;
    mmt_rec.routing_revision:=wct_rec.routing_revision;
    mmt_rec.bom_revision_date:=wct_rec.bom_revision_date;
    mmt_rec.routing_revision_date:=wct_rec.routing_revision_date;
    mmt_rec.alternate_bom_designator:=wct_rec.alternate_bom_designator;
    mmt_rec.alternate_routing_designator:=wct_rec.alternate_routing_designator;
    mmt_rec.operation_plan_id:=wct_rec.operation_plan_id;
    mmt_rec.move_order_header_id:=wct_rec.move_order_header_id;
    mmt_rec.serial_allocated_flag:=wct_rec.serial_allocated_flag;

    RETURN mmt_rec;

 END;


 PROCEDURE create_wct(p_move_order_header_id IN NUMBER,
                      p_transaction_header_id IN NUMBER,
                      p_input_for_bulk IN WMS_BULK_PICK.BULK_INPUT_REC := null)
   IS

      mmtt_rec MMTT_ROW_TYPE;

      CURSOR c1(mo_hdr_id NUMBER) IS
       /* added the index hint with the suggestion of apps performance team */
        SELECT /*+index (mmtt,mtl_material_trans_temp_n14)*/  mmtt.* FROM
           mtl_material_transactions_temp mmtt, mtl_txn_request_lines
           mtrl WHERE mtrl.header_id =  mo_hdr_id AND
           mmtt.move_order_line_id = mtrl.line_id AND
           --2513907 fix
           mmtt.container_item_id IS null;

      CURSOR c2(txn_hdr_id NUMBER) IS
         SELECT mmtt.* FROM
           mtl_material_transactions_temp mmtt
           WHERE
           mmtt.transaction_header_id = txn_hdr_id;

           -- following cursors added for patchset J bulk picking   ---------------

     CURSOR c11_bulk_all_fast(p_organization_id NUMBER) IS
         SELECT mmtt.* FROM
           mtl_material_transactions_temp mmtt,mtl_allocations_gtmp mag
          WHERE    mmtt.wms_task_status = 8   -- unreleased
	   And     nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And     mmtt.cartonization_id IS null   -- not cartonized
           And     mmtt.organization_id = p_organization_id
           AND     mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND     mmtt.move_order_header_id = mag.move_order_header_id
           AND    (mmtt.serial_allocated_flag <> 'Y' OR
                   mmtt.serial_allocated_flag IS NULL ) --Should not bulk
                      --Bug3628747
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           for update of mmtt.transaction_temp_id; -- to lock the records

      CURSOR c11_bulk_only_sub_item_fast(p_organization_id NUMBER) IS
          SELECT mmtt.* FROM
           mtl_material_transactions_temp mmtt,mtl_allocations_gtmp mag
          WHERE    mmtt.wms_task_status = 8   -- unreleased
	   And     nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And     mmtt.cartonization_id IS null   -- not cartonized
           And     mmtt.organization_id = p_organization_id
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
          AND (mmtt.serial_allocated_flag <> 'Y' OR
                mmtt.serial_allocated_flag IS NULL ) -- should not bulk those childs
               --Bug3628747
           AND mmtt.move_order_header_id = mag.move_order_header_id
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           AND  ( EXISTS (SELECT 1   -- sub is bulk picking enabled
                         FROM mtl_secondary_inventories msi
                        WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                          AND msi.organization_id = mmtt.organization_id
                          AND msi.enable_bulk_pick = 'Y')
               OR EXISTS (SELECT 1   -- item is bulk picking enabled
                            FROM mtl_system_items msi
                           WHERE msi.inventory_item_id = mmtt.inventory_item_id
                             AND msi.bulk_picked_flag = 'Y')
                 )
           for update of mmtt.transaction_temp_id; -- to lock the records


     CURSOR c11_bulk_all(p_organization_id NUMBER) IS
         SELECT mmtt.* FROM
           mtl_material_transactions_temp mmtt,mtl_txn_request_headers moh,
           wsh_pick_grouping_rules spg
          WHERE    mmtt.wms_task_status = 8   -- unreleased
	   And     nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And     mmtt.cartonization_id IS null   -- not cartonized
           And     mmtt.organization_id = p_organization_id
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND mmtt.move_order_header_id = moh.header_id
           AND spg.pick_grouping_rule_id = moh.grouping_rule_id
           AND spg.pick_method <>WMS_GLOBALS.PICK_METHOD_ORDER  -- not order pciking
           AND moh.move_order_type = INV_GLOBALS.g_move_order_pick_wave   -- pick wave move order only
                -- following is the logic for the input parameters
           AND (mmtt.serial_allocated_flag <> 'Y' OR
                 mmtt.serial_allocated_flag IS NULL ) -- should not bulk those childs Bug3628747
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND moh.request_number between nvl(p_input_for_bulk.start_mo_request_number,moh.request_number) and
                           nvl(p_input_for_bulk.end_mo_request_number,moh.request_number)
           AND moh.creation_date between nvl(p_input_for_bulk.start_release_date,moh.creation_date) and
                            nvl(p_input_for_bulk.end_release_date,moh.creation_date)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           for update of mmtt.transaction_temp_id; -- to lock the records

      CURSOR c11_bulk_only_sub_item(p_organization_id NUMBER) IS
          SELECT mmtt.* FROM
           mtl_material_transactions_temp mmtt,mtl_txn_request_headers moh,
           wsh_pick_grouping_rules spg
          WHERE    mmtt.wms_task_status = 8   -- unreleased
	   And     nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And     mmtt.cartonization_id IS null   -- not cartonized
           And     mmtt.organization_id = p_organization_id
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND mmtt.move_order_header_id = moh.header_id
           AND spg.pick_grouping_rule_id = moh.grouping_rule_id
           AND spg.pick_method <>WMS_GLOBALS.PICK_METHOD_ORDER  -- not order pciking
            AND (mmtt.serial_allocated_flag <> 'Y' OR
                 mmtt.serial_allocated_flag IS NULL ) -- should not bulk those lines
                -- Bug3628747
           AND moh.move_order_type = INV_GLOBALS.g_move_order_pick_wave   -- pick wave move order only
                -- following is the logic for the input parameters
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND moh.request_number between nvl(p_input_for_bulk.start_mo_request_number,moh.request_number) and
                           nvl(p_input_for_bulk.end_mo_request_number,moh.request_number)
           AND moh.creation_date between nvl(p_input_for_bulk.start_release_date,moh.creation_date) and
                            nvl(p_input_for_bulk.end_release_date,moh.creation_date)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           AND  ( EXISTS (SELECT 1   -- sub is bulk picking enabled
                         FROM mtl_secondary_inventories msi
                        WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                          AND msi.organization_id = mmtt.organization_id
                          AND msi.enable_bulk_pick = 'Y')
               OR EXISTS (SELECT 1   -- item is bulk picking enabled
                            FROM mtl_system_items msi
                           WHERE msi.inventory_item_id = mmtt.inventory_item_id
                             AND msi.bulk_picked_flag = 'Y')
                 )
           for update of mmtt.transaction_temp_id; -- to lock the records

          CURSOR c11_bulk_trip(p_organization_id NUMBER) IS
          select mmtt.*
          from   wsh_delivery_legs wdl,wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
                 wsh_trip_stops wts, mtl_material_transactions_temp mmtt,mtl_txn_request_headers moh,
                 wsh_pick_grouping_rules spg
          where wts.trip_id = p_input_for_bulk.trip_id
           and  wdl.pick_up_stop_id = wts.stop_id
           and wdl.delivery_id = wda.delivery_id
           and wda.delivery_detail_id = wdd.delivery_detail_id
           and mmtt.move_order_line_id = wdd.move_order_line_id
           and mmtt.wms_task_status = 8   -- unreleased
           And nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And mmtt.cartonization_id IS null   -- not cartonized
           And mmtt.organization_id = p_organization_id
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND mmtt.move_order_header_id = moh.header_id
           AND spg.pick_grouping_rule_id = moh.grouping_rule_id
           AND spg.pick_method <>WMS_GLOBALS.PICK_METHOD_ORDER  -- not order pciking
           AND (mmtt.serial_allocated_flag <> 'Y' OR
                 mmtt.serial_allocated_flag IS NULL ) -- should not bulk those lines
             --Bug3628747
           AND moh.move_order_type = INV_GLOBALS.g_move_order_pick_wave   -- pick wave move order only
                -- following is the logic for the input parameters
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND moh.request_number between nvl(p_input_for_bulk.start_mo_request_number,moh.request_number) and
                           nvl(p_input_for_bulk.end_mo_request_number,moh.request_number)
           AND moh.creation_date between nvl(p_input_for_bulk.start_release_date,moh.creation_date) and
                            nvl(p_input_for_bulk.end_release_date,moh.creation_date)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           for update of mmtt.transaction_temp_id; -- to lock the records

           CURSOR c11_bulk_trip_sub_item(p_organization_id NUMBER) IS
          select mmtt.*
          from   wsh_delivery_legs wdl,wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
                 wsh_trip_stops wts, mtl_material_transactions_temp mmtt,mtl_txn_request_headers moh,
                 wsh_pick_grouping_rules spg
          where wts.trip_id = p_input_for_bulk.trip_id
           and  wdl.pick_up_stop_id = wts.stop_id
           and wdl.delivery_id = wda.delivery_id
           and wda.delivery_detail_id = wdd.delivery_detail_id
           and mmtt.move_order_line_id = wdd.move_order_line_id
           and mmtt.wms_task_status = 8   -- unreleased
	   And nvl(mmtt.lock_flag,'$') <> 'Y'  --Bug#8546026
           And mmtt.cartonization_id IS null   -- not cartonized
           And mmtt.organization_id = p_organization_id
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND mmtt.move_order_header_id = moh.header_id
           AND spg.pick_grouping_rule_id = moh.grouping_rule_id
           AND spg.pick_method <>WMS_GLOBALS.PICK_METHOD_ORDER  -- not order pciking
           AND (mmtt.serial_allocated_flag <> 'Y' OR
                 mmtt.serial_allocated_flag IS NULL ) -- should not bulk those lines
               --Bug3628747
           AND moh.move_order_type = INV_GLOBALS.g_move_order_pick_wave   -- pick wave move order only
                -- following is the logic for the input parameters
           AND  mmtt.subinventory_code = nvl(p_input_for_bulk.subinventory_code, mmtt.subinventory_code)
           AND mmtt.inventory_item_id = nvl(p_input_for_bulk.item_id,mmtt.inventory_item_id)
           AND moh.request_number between nvl(p_input_for_bulk.start_mo_request_number,moh.request_number) and
                           nvl(p_input_for_bulk.end_mo_request_number,moh.request_number)
           AND moh.creation_date between nvl(p_input_for_bulk.start_release_date,moh.creation_date) and
                            nvl(p_input_for_bulk.end_release_date,moh.creation_date)
           AND Exists ( select 1
                        From wsh_delivery_details wdd,wsh_delivery_assignments_v wda
                        Where wdd.move_order_line_id = mmtt.move_order_line_id
                          AND wdd.delivery_detail_id = wda.delivery_Detail_id
                          AND nvl(wda.delivery_id,-1) = decode(p_input_for_bulk.delivery_id,null,nvl(wda.delivery_id,-1),p_input_for_bulk.delivery_id)
                      )
           AND  ( EXISTS (SELECT 1   -- sub is bulk picking enabled
                                         FROM mtl_secondary_inventories msi
                                        WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                                          AND msi.organization_id = mmtt.organization_id
                                          AND msi.enable_bulk_pick = 'Y')
                  OR EXISTS (SELECT 1   -- item is bulk picking enabled
                                            FROM mtl_system_items msi
                                           WHERE msi.inventory_item_id = mmtt.inventory_item_id
                                             AND msi.bulk_picked_flag = 'Y')
                 )
           for update of mmtt.transaction_temp_id; -- to lock the records
           l_organization_id NUMBER;
           l_return_status   VARCHAR2(1);
           l_lot_control_code NUMBER;
           l_serial_control_code NUMBER;
           l_fast_possible boolean;

 BEGIN

    if (g_trace_on = 1) then log_event('Enter create_wct'); END IF;

    error_code := 'GET_CLPN_ATTR';

    IF( p_move_order_header_id IS NULL AND
        p_transaction_header_id IS NULL ) THEN

       if (g_trace_on = 1) then log_event('Error- mo hdr id and txn hdr id are null'); END IF;
       RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    IF(p_move_order_header_id IS NOT NULL) THEN

       if (g_trace_on = 1) then log_event(' mo hdr id '||p_move_order_header_id);  END IF;

       IF (p_move_order_header_id <> -1) THEN     --- patchset J bulk picking    ------------
           if (g_trace_on = 1) then log_event('calling from pick release'); end if;
           OPEN c1(p_move_order_header_id);
       ELSE
           if (g_trace_on = 1) then --log_event('PATCHSET J-- BULK PICKING -- START');
                                    log_event('calling from concurrent program'); end if;
           l_organization_id := p_input_for_bulk.organization_id;
           if (g_trace_on = 1) then log_event(' organization_id '||l_organization_id); end if;

           -- make sure the temp table is empty, the following is to improve performance
           -- when move order number or creation dates are entered
           delete mtl_allocations_gtmp;
           l_fast_possible := false;
           if p_input_for_bulk.start_mo_request_number is not null
              or p_input_for_bulk.start_release_date is not null then -- select the move_order_headers
               l_fast_possible := true;
               insert into mtl_allocations_gtmp
               (move_order_header_id)
                  select moh.header_id
                  from mtl_txn_request_headers moh,
                       wsh_pick_grouping_rules spg
                  where spg.pick_grouping_rule_id = moh.grouping_rule_id
                    AND spg.pick_method <>WMS_GLOBALS.PICK_METHOD_ORDER  -- not order pciking
                    AND moh.move_order_type = INV_GLOBALS.g_move_order_pick_wave   -- pick wave move order only
                    AND moh.request_number between nvl(p_input_for_bulk.start_mo_request_number,moh.request_number) and
                           nvl(p_input_for_bulk.end_mo_request_number,moh.request_number)
                    AND moh.creation_date between nvl(p_input_for_bulk.start_release_date,moh.creation_date) and
                            nvl(p_input_for_bulk.end_release_date,moh.creation_date);
           end if;

           if (p_input_for_bulk.trip_id is null) then
              if (p_input_for_bulk.only_sub_item = 1) then
                  if (l_fast_possible) then
                      if (g_trace_on = 1) then log_event('OPEN c11_bulk_only_sub_item_fast'); end if;
                      OPEN c11_bulk_only_sub_item_fast(l_organization_id);
                  else
                      if (g_trace_on = 1) then log_event('OPEN c11_bulk_only_sub_item'); end if;

                      OPEN c11_bulk_only_sub_item(l_organization_id);
                  end if;
              else
                  if (l_fast_possible) then
                      if (g_trace_on = 1) then log_event('OPEN c11_bulk_all_fast'); end if;
                      OPEN c11_bulk_all_fast(l_organization_id);
                  else
                      if (g_trace_on = 1) then log_event('OPEN c11_bulk_all'); end if;
                      OPEN c11_bulk_all(l_organization_id);
                  end if;
              end if;
           else
               if (p_input_for_bulk.only_sub_item = 1) then
                    if (g_trace_on = 1) then log_event('OPEN c11_bulk_trip_sub_item'); end if;
                    OPEN c11_bulk_trip_sub_item(l_organization_id);
               else
                    if (g_trace_on = 1) then log_event('OPEN c11_bulk_trip'); end if;
                   OPEN c11_bulk_trip(l_organization_id);
              end if;
           end if;
        END IF;
       -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING -- END'); end if;
     ELSIF(p_transaction_header_id IS NOT NULL) THEN

       if (g_trace_on = 1) then log_event(' txn hdr id '||p_transaction_header_id); END IF;

       OPEN c2(p_transaction_header_id);

    END IF;

    LOOP
       mmtt_rec := NULL;

       IF(p_move_order_header_id IS NOT NULL) THEN
          IF (p_move_order_header_id <> -1) THEN    -- patchset J bulk picking  -----
             IF c1%isopen THEN
                 FETCH c1 INTO mmtt_rec;
                 EXIT WHEN c1%notfound;
              END IF;
          ELSE
            -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING -- START'); end if;
             IF c11_bulk_all%isopen THEN
                 FETCH c11_bulk_all INTO mmtt_rec;
                 EXIT WHEN c11_bulk_all%notfound;
             ELSIF c11_bulk_only_sub_item%isopen THEN
                 FETCH c11_bulk_only_sub_item INTO mmtt_rec;
                 EXIT WHEN c11_bulk_only_sub_item%notfound;
             ELSIF c11_bulk_trip%isopen THEN
                 FETCH c11_bulk_trip INTO mmtt_rec;
                 EXIT WHEN c11_bulk_trip%notfound;
             ELSIF c11_bulk_trip_sub_item%isopen THEN
                 FETCH c11_bulk_trip_sub_item INTO mmtt_rec;
                 EXIT WHEN c11_bulk_trip_sub_item%notfound;
             ELSIF c11_bulk_all_fast%isopen THEN
                 FETCH c11_bulk_all_fast INTO mmtt_rec;
                 EXIT WHEN c11_bulk_all_fast%notfound;
             ELSIF c11_bulk_only_sub_item_fast%isopen THEN
                 FETCH c11_bulk_only_sub_item_fast INTO mmtt_rec;
                 EXIT WHEN c11_bulk_only_sub_item_fast%notfound;
             END IF;
            -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING -- END'); end if;
          END IF;

        ELSIF(p_transaction_header_id IS NOT NULL) THEN

             IF c2%isopen THEN
                FETCH c2 INTO mmtt_rec;
                EXIT WHEN c2%notfound;
             END IF;
       END IF;

       ---   patchset J bulk picking   -----
       if mmtt_rec.parent_line_id is not null then  -- child line
           if (g_trace_on = 1) then -- log_event('PATCHSET J-- BULK PICKING -- START');
                                    log_event('checking the lot and serial control code'); end if;
           select lot_control_code,serial_number_control_code
           into l_lot_control_code,l_serial_control_code
           from mtl_system_items_b msi, mtl_material_transactions_temp mmtt
           where mmtt.transaction_temp_id = mmtt_rec.transaction_Temp_id
             and mmtt.organization_id = msi.organization_id
             and msi.inventory_item_id = mmtt.inventory_item_id;
           if (g_trace_on = 1) then log_event('transaction_temp_id:'|| mmtt_rec.transaction_Temp_id ||
                                              ' lot control code :'||l_lot_control_code ||
                                              ' serial control code :'||l_serial_control_code);
           end if;
           if (g_trace_on = 1) then log_event('nullify the parent_line_id for the child task '); end if;

           update mtl_material_transactions_temp
           set parent_line_id = null
           where transaction_temp_id = mmtt_rec.transaction_Temp_id;

           -- call update_parent_mmtt to change the qty or delete the parent line --------
           if (g_trace_on = 1) then log_event('calling update_parent_mmtt ....'); end if;
           inv_trx_util_pub.update_parent_mmtt(x_return_status => l_return_status
                                               , p_parent_line_id =>mmtt_rec.parent_line_id
                                               , p_child_line_id => mmtt_rec.transaction_Temp_id
                                               , p_lot_control_code => l_lot_control_code
                                               , p_serial_control_code => l_serial_control_code);
           if (g_trace_on = 1) then log_event('returning from update_parent_mmtt:'||l_return_status); end if;
           if (l_return_status <> fnd_api.g_ret_sts_success) then
               RAISE fnd_api.g_exc_unexpected_error;
           end if;
          -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING --END'); end if;
       end if;

       ---- end of patchset J bulk picking  -------------------
       if (g_trace_on = 1) then log_event('Insert transaction temp id:'||mmtt_rec.transaction_temp_id); end if;
       if (g_trace_on = 1) then log_event('transaction quantity:'||mmtt_rec.transaction_quantity); end if;
       if (g_trace_on = 1) then log_event('secondary transaction quantity:'||mmtt_rec.secondary_transaction_quantity); end if; --invconv kkillams
       INSERT INTO wms_cartonization_temp
         (transaction_header_id,
          transaction_temp_id,
          source_code,
          source_line_id,
          transaction_mode,
          lock_flag,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          inventory_item_id,
          revision,
          organization_id,
          subinventory_code,
          locator_id,
          transaction_quantity,
          primary_quantity,
          transaction_uom,
          transaction_cost,
          transaction_type_id,
          transaction_action_id,
          transaction_source_type_id,
          transaction_source_id,
          transaction_source_name,
          transaction_date,
          acct_period_id,
          distribution_account_id,
          transaction_reference,
          requisition_line_id,
          requisition_distribution_id,
          reason_id,
          lot_number,
          lot_expiration_date,
          serial_number,
          receiving_document,
          demand_id,
          rcv_transaction_id,
          move_transaction_id,
          completion_transaction_id,
          wip_entity_type,
          schedule_id,
          repetitive_line_id,
         employee_code,
         primary_switch,
         schedule_update_code,
         setup_teardown_code,
         item_ordering,
         negative_req_flag,
         operation_seq_num,
         picking_line_id,
         trx_source_line_id,
         trx_source_delivery_id,
         physical_adjustment_id,
         cycle_count_id,
         rma_line_id,
         customer_ship_id,
         currency_code,
         currency_conversion_rate,
         currency_conversion_type,
         currency_conversion_date,
         ussgl_transaction_code,
         vendor_lot_number,
         encumbrance_account,
         encumbrance_amount,
         ship_to_location,
         shipment_number,
         transfer_cost,
         transportation_cost,
         transportation_account,
         freight_code,
         containers,
         waybill_airbill,
         expected_arrival_date,
         transfer_subinventory,
         transfer_organization,
         transfer_to_location,
         new_average_cost,
         value_change,
         percentage_change,
         material_allocation_temp_id,
         demand_source_header_id,
         demand_source_line,
         demand_source_delivery,
         item_segments,
         item_description,
         item_trx_enabled_flag,
         item_location_control_code,
         item_restrict_subinv_code,
         item_restrict_locators_code,
         item_revision_qty_control_code,
         item_primary_uom_code,
         item_uom_class,
         item_shelf_life_code,
         item_shelf_life_days,
         item_lot_control_code,
         item_serial_control_code,
         item_inventory_asset_flag,
         allowed_units_lookup_code,
         department_id,
         department_code,
         wip_supply_type,
         supply_subinventory,
         supply_locator_id,
         valid_subinventory_flag,
         valid_locator_flag,
         locator_segments,
         current_locator_control_code,
         number_of_lots_entered,
         wip_commit_flag,
         next_lot_number,
         lot_alpha_prefix,
         next_serial_number,
         serial_alpha_prefix,
         shippable_flag,
         posting_flag,
         required_flag,
         process_flag,
         error_code,
         error_explanation,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         movement_id,
         reservation_quantity,
         shipped_quantity,
         transaction_line_number,
         task_id,
         to_task_id,
         source_task_id,
         project_id,
         source_project_id,
         pa_expenditure_org_id,
         to_project_id,
         expenditure_type,
         final_completion_flag,
         transfer_percentage,
         transaction_sequence_id,
         material_account,
         material_overhead_account,
         resource_account,
         outside_processing_account,
         overhead_account,
         flow_schedule,
         cost_group_id,
         demand_class,
         qa_collection_id,
         kanban_card_id,
         overcompletion_transaction_qty,
         overcompletion_primary_qty,
         overcompletion_transaction_id,
         end_item_unit_number,
         scheduled_payback_date,
         line_type_code,
         parent_transaction_temp_id,
         put_away_strategy_id,
         put_away_rule_id,
         pick_strategy_id,
         pick_rule_id,
         move_order_line_id,
         task_group_id,
         pick_slip_number,
         reservation_id,
         common_bom_seq_id,
         common_routing_seq_id,
         org_cost_group_id,
         cost_type_id,
         transaction_status,
         standard_operation_id,
         task_priority,
         wms_task_type,
         parent_line_id,
         --source_lot_number,
         transfer_cost_group_id,
         lpn_id,
         transfer_lpn_id,
         wms_task_status,
         content_lpn_id,
         container_item_id,
         cartonization_id,
         pick_slip_date,
         rebuild_item_id,
         rebuild_serial_number,
         rebuild_activity_id,
         rebuild_job_name,
         organization_type,
         transfer_organization_type,
         owning_organization_id,
         owning_tp_type,
         xfr_owning_organization_id,
         transfer_owning_tp_type,
         planning_organization_id,
         planning_tp_type,
         xfr_planning_organization_id,
         transfer_planning_tp_type,
         secondary_uom_code,
         secondary_transaction_quantity,
         transaction_batch_id,
         transaction_batch_seq,
         allocated_lpn_id,
         schedule_number,
         scheduled_flag,
         class_code,
         schedule_group,
         build_sequence,
         bom_revision,
         routing_revision,
         bom_revision_date,
         routing_revision_date,
         alternate_bom_designator,
         alternate_routing_designator,
         operation_plan_id,
         move_order_header_id,
         serial_allocated_flag)
         values
         (mmtt_rec.transaction_header_id,
          mmtt_rec.transaction_temp_id,
          mmtt_rec.source_code,
          mmtt_rec.source_line_id,
          mmtt_rec.transaction_mode,
          mmtt_rec.lock_flag,
          mmtt_rec.last_update_date,
          mmtt_rec.last_updated_by,
          mmtt_rec.creation_date,
          mmtt_rec.created_by,
          mmtt_rec.last_update_login,
          mmtt_rec.request_id,
          mmtt_rec.program_application_id,
          mmtt_rec.program_id,
          mmtt_rec.program_update_date,
          mmtt_rec.inventory_item_id,
          mmtt_rec.revision,
          mmtt_rec.organization_id,
          mmtt_rec.subinventory_code,
          mmtt_rec.locator_id,
          mmtt_rec.transaction_quantity,
          mmtt_rec.primary_quantity,
          mmtt_rec.transaction_uom,
          mmtt_rec.transaction_cost,
          mmtt_rec.transaction_type_id,
          mmtt_rec.transaction_action_id,
          mmtt_rec.transaction_source_type_id,
          mmtt_rec.transaction_source_id,
          mmtt_rec.transaction_source_name,
          mmtt_rec.transaction_date,
          mmtt_rec.acct_period_id,
          mmtt_rec.distribution_account_id,
          mmtt_rec.transaction_reference,
         mmtt_rec.requisition_line_id,
         mmtt_rec.requisition_distribution_id,
         mmtt_rec.reason_id,
         mmtt_rec.lot_number,
         mmtt_rec.lot_expiration_date,
         mmtt_rec.serial_number,
         mmtt_rec.receiving_document,
         mmtt_rec.demand_id,
         mmtt_rec.rcv_transaction_id,
         mmtt_rec.move_transaction_id,
         mmtt_rec.completion_transaction_id,
         mmtt_rec.wip_entity_type,
         mmtt_rec.schedule_id,
         mmtt_rec.repetitive_line_id,
         mmtt_rec.employee_code,
         mmtt_rec.primary_switch,
         mmtt_rec.schedule_update_code,
         mmtt_rec.setup_teardown_code,
         mmtt_rec.item_ordering,
         mmtt_rec.negative_req_flag,
         mmtt_rec.operation_seq_num,
         mmtt_rec.picking_line_id,
         mmtt_rec.trx_source_line_id,
         mmtt_rec.trx_source_delivery_id,
         mmtt_rec.physical_adjustment_id,
         mmtt_rec.cycle_count_id,
         mmtt_rec.rma_line_id,
         mmtt_rec.customer_ship_id,
         mmtt_rec.currency_code,
         mmtt_rec.currency_conversion_rate,
         mmtt_rec.currency_conversion_type,
         mmtt_rec.currency_conversion_date,
         mmtt_rec.ussgl_transaction_code,
         mmtt_rec.vendor_lot_number,
         mmtt_rec.encumbrance_account,
         mmtt_rec.encumbrance_amount,
         mmtt_rec.ship_to_location,
         mmtt_rec.shipment_number,
         mmtt_rec.transfer_cost,
         mmtt_rec.transportation_cost,
         mmtt_rec.transportation_account,
         mmtt_rec.freight_code,
         mmtt_rec.containers,
         mmtt_rec.waybill_airbill,
         mmtt_rec.expected_arrival_date,
         mmtt_rec.transfer_subinventory,
         mmtt_rec.transfer_organization,
         mmtt_rec.transfer_to_location,
         mmtt_rec.new_average_cost,
         mmtt_rec.value_change,
         mmtt_rec.percentage_change,
         mmtt_rec.material_allocation_temp_id,
         mmtt_rec.demand_source_header_id,
         mmtt_rec.demand_source_line,
         mmtt_rec.demand_source_delivery,
         mmtt_rec.item_segments,
         mmtt_rec.item_description,
         mmtt_rec.item_trx_enabled_flag,
         mmtt_rec.item_location_control_code,
         mmtt_rec.item_restrict_subinv_code,
         mmtt_rec.item_restrict_locators_code,
         mmtt_rec.item_revision_qty_control_code,
         mmtt_rec.item_primary_uom_code,
         mmtt_rec.item_uom_class,
         mmtt_rec.item_shelf_life_code,
         mmtt_rec.item_shelf_life_days,
         mmtt_rec.item_lot_control_code,
         mmtt_rec.item_serial_control_code,
         mmtt_rec.item_inventory_asset_flag,
         mmtt_rec.allowed_units_lookup_code,
         mmtt_rec.department_id,
         mmtt_rec.department_code,
         mmtt_rec.wip_supply_type,
         mmtt_rec.supply_subinventory,
         mmtt_rec.supply_locator_id,
         mmtt_rec.valid_subinventory_flag,
         mmtt_rec.valid_locator_flag,
         mmtt_rec.locator_segments,
         mmtt_rec.current_locator_control_code,
         mmtt_rec.number_of_lots_entered,
         mmtt_rec.wip_commit_flag,
         mmtt_rec.next_lot_number,
         mmtt_rec.lot_alpha_prefix,
         mmtt_rec.next_serial_number,
         mmtt_rec.serial_alpha_prefix,
         mmtt_rec.shippable_flag,
         mmtt_rec.posting_flag,
         mmtt_rec.required_flag,
         mmtt_rec.process_flag,
         mmtt_rec.error_code,
         mmtt_rec.error_explanation,
         mmtt_rec.attribute_category,
         mmtt_rec.attribute1,
         mmtt_rec.attribute2,
         mmtt_rec.attribute3,
         mmtt_rec.attribute4,
         mmtt_rec.attribute5,
         mmtt_rec.attribute6,
         mmtt_rec.attribute7,
         mmtt_rec.attribute8,
         mmtt_rec.attribute9,
         mmtt_rec.attribute10,
         mmtt_rec.attribute11,
         mmtt_rec.attribute12,
         mmtt_rec.attribute13,
         mmtt_rec.attribute14,
         mmtt_rec.attribute15,
         mmtt_rec.movement_id,
         mmtt_rec.reservation_quantity,
         mmtt_rec.shipped_quantity,
         mmtt_rec.transaction_line_number,
         mmtt_rec.task_id,
         mmtt_rec.to_task_id,
         mmtt_rec.source_task_id,
         mmtt_rec.project_id,
         mmtt_rec.source_project_id,
         mmtt_rec.pa_expenditure_org_id,
         mmtt_rec.to_project_id,
         mmtt_rec.expenditure_type,
         mmtt_rec.final_completion_flag,
         mmtt_rec.transfer_percentage,
         mmtt_rec.transaction_sequence_id,
         mmtt_rec.material_account,
         mmtt_rec.material_overhead_account,
         mmtt_rec.resource_account,
         mmtt_rec.outside_processing_account,
         mmtt_rec.overhead_account,
         mmtt_rec.flow_schedule,
         mmtt_rec.cost_group_id,
         mmtt_rec.demand_class,
         mmtt_rec.qa_collection_id,
         mmtt_rec.kanban_card_id,
         mmtt_rec.overcompletion_transaction_qty,
         mmtt_rec.overcompletion_primary_qty,
         mmtt_rec.overcompletion_transaction_id,
         mmtt_rec.end_item_unit_number,
         mmtt_rec.scheduled_payback_date,
         mmtt_rec.line_type_code,
         mmtt_rec.parent_transaction_temp_id,
         mmtt_rec.put_away_strategy_id,
         mmtt_rec.put_away_rule_id,
         mmtt_rec.pick_strategy_id,
         mmtt_rec.pick_rule_id,
         mmtt_rec.move_order_line_id,
         mmtt_rec.task_group_id,
         mmtt_rec.pick_slip_number,
         mmtt_rec.reservation_id,
         mmtt_rec.common_bom_seq_id,
         mmtt_rec.common_routing_seq_id,
         mmtt_rec.org_cost_group_id,
         mmtt_rec.cost_type_id,
         mmtt_rec.transaction_status,
         mmtt_rec.standard_operation_id,
         mmtt_rec.task_priority,
         mmtt_rec.wms_task_type,
         mmtt_rec.parent_line_id,
         --mmtt_rec.source_lot_number,
         mmtt_rec.transfer_cost_group_id,
         mmtt_rec.lpn_id,
         mmtt_rec.transfer_lpn_id,
         mmtt_rec.wms_task_status,
         mmtt_rec.content_lpn_id,
         mmtt_rec.container_item_id,
         mmtt_rec.cartonization_id,
         mmtt_rec.pick_slip_date,
         mmtt_rec.rebuild_item_id,
         mmtt_rec.rebuild_serial_number,
         mmtt_rec.rebuild_activity_id,
         mmtt_rec.rebuild_job_name,
         mmtt_rec.organization_type,
         mmtt_rec.transfer_organization_type,
         mmtt_rec.owning_organization_id,
         mmtt_rec.owning_tp_type,
         mmtt_rec.xfr_owning_organization_id,
         mmtt_rec.transfer_owning_tp_type,
         mmtt_rec.planning_organization_id,
         mmtt_rec.planning_tp_type,
         mmtt_rec.xfr_planning_organization_id,
         mmtt_rec.transfer_planning_tp_type,
         mmtt_rec.secondary_uom_code,
         mmtt_rec.secondary_transaction_quantity,
         mmtt_rec.transaction_batch_id,
         mmtt_rec.transaction_batch_seq,
         mmtt_rec.allocated_lpn_id,
         mmtt_rec.schedule_number,
         mmtt_rec.scheduled_flag,
         mmtt_rec.class_code,
         mmtt_rec.schedule_group,
         mmtt_rec.build_sequence,
         mmtt_rec.bom_revision,
         mmtt_rec.routing_revision,
         mmtt_rec.bom_revision_date,
         mmtt_rec.routing_revision_date,
         mmtt_rec.alternate_bom_designator,
         mmtt_rec.alternate_routing_designator,
         mmtt_rec.operation_plan_id,
         mmtt_rec.move_order_header_id,
         mmtt_rec.serial_allocated_flag);

    END LOOP;

    IF c1%isopen THEN
       CLOSE c1;
     ELSIF c2%isopen THEN
       CLOSE c2;
    END IF;

    IF c11_bulk_all%isopen THEN
        CLOSE c11_bulk_all;
    ELSIF c11_bulk_only_sub_item%isopen THEN
        CLOSE c11_bulk_only_sub_item;
    ELSIF c11_bulk_trip%isopen THEN
        CLOSE c11_bulk_trip;
    ELSIF c11_bulk_trip_sub_item%isopen THEN
        CLOSE c11_bulk_trip_sub_item;
    ELSIF c11_bulk_all_fast%isopen THEN
        CLOSE c11_bulk_all_fast;
    ELSIF c11_bulk_only_sub_item_fast%isopen THEN
        CLOSE c11_bulk_only_sub_item_fast;
    END IF;
 EXCEPTION
    WHEN OTHERS THEN
       if (g_trace_on = 1) then log_event(' Error occurred in create_wct proc'||Sqlerrm); END IF;
       RAISE fnd_api.g_exc_unexpected_error;
 END create_wct;







 PROCEDURE get_cached_lpn_attributes(p_lpn_id                  IN NUMBER,
                                     x_inventory_item_id       OUT NOCOPY NUMBER,
                                     x_gross_weight            OUT NOCOPY NUMBER,
                                     x_content_volume          OUT NOCOPY NUMBER,
                                     x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
                                     x_content_volume_uom_code OUT NOCOPY VARCHAR2,
                                     x_tare_weight             OUT NOCOPY NUMBER,
                                     x_tare_weight_uom_code    OUT NOCOPY VARCHAR2,
                                     x_found_flag              OUT NOCOPY VARCHAR2)
   IS
 BEGIN

    error_code := 'GET_CLPN_ATTR';


    x_inventory_item_id       := lpn_attr_table(p_lpn_id).inventory_item_id;
    x_gross_weight            := lpn_attr_table(p_lpn_id).gross_weight;
    x_gross_weight_uom_code   := lpn_attr_table(p_lpn_id).gross_weight_uom_code;
    x_content_volume          := lpn_attr_table(p_lpn_id).content_volume;
    x_content_volume_uom_code := lpn_attr_table(p_lpn_id).content_volume_uom_code;
    x_tare_weight             := lpn_attr_table(p_lpn_id).tare_weight;
    x_tare_weight_uom_code    := lpn_attr_table(p_lpn_id).tare_weight_uom_code;
    x_found_flag              := 'Y';
 EXCEPTION
    WHEN OTHERS THEN
       x_inventory_item_id       := NULL;
       x_gross_weight            := NULL;
       x_gross_weight_uom_code   := NULL;
       x_content_volume          := NULL;
       x_content_volume_uom_code := NULL;
       x_tare_weight             := NULL;
       x_tare_weight_uom_code    := NULL;
       x_found_flag              := 'N';
 END;

 PROCEDURE get_cached_package_attributes(p_org_id                  IN NUMBER,
                                         p_package_id              IN NUMBER,
                                         x_inventory_item_id       OUT NOCOPY NUMBER,
                                         x_gross_weight            OUT NOCOPY NUMBER,
                                         x_content_volume          OUT NOCOPY NUMBER,
                                         x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
                                         x_content_volume_uom_code OUT NOCOPY VARCHAR2,
                                         x_tare_weight             OUT NOCOPY NUMBER,
                                         x_tare_weight_uom_code    OUT NOCOPY VARCHAR2,
                                         x_found_flag              OUT NOCOPY VARCHAR2)

   IS
 BEGIN
    error_code := 'GET_CPKG_ATTR';
    x_inventory_item_id       := pkg_attr_table(p_package_id).inventory_item_id;
    x_gross_weight            := pkg_attr_table(p_package_id).gross_weight;
    x_gross_weight_uom_code   := pkg_attr_table(p_package_id).gross_weight_uom_code;
    x_content_volume          := pkg_attr_table(p_package_id).content_volume;
    x_content_volume_uom_code := pkg_attr_table(p_package_id).content_volume_uom_code;
    x_tare_weight             := pkg_attr_table(p_package_id).tare_weight;
    x_tare_weight_uom_code    := pkg_attr_table(p_package_id).tare_weight_uom_code;
    x_found_flag              := 'Y';
 EXCEPTION
    WHEN OTHERS THEN
       x_inventory_item_id       := NULL;
       x_gross_weight            := NULL;
       x_gross_weight_uom_code   := NULL;
       x_content_volume          := NULL;
       x_content_volume_uom_code := NULL;
       x_tare_weight             := NULL;
       x_tare_weight_uom_code    := NULL;
       x_found_flag              := 'N';
 END;



 -- Given a transaction_temp_id, this returns whether the allocated lpn is
 -- is fully  allocated,  partially allocated or no LPN allocated.

  FUNCTION get_lpn_alloc_flag(p_temp_id IN NUMBER)
    return  VARCHAR2   IS
    l_lpn_alloc_flag VARCHAR2(1):= null;
  BEGIN
     error_code := 'GET_LPN_ALLOC';

       l_lpn_alloc_flag := t_lpn_alloc_flag_table(p_temp_id).lpn_alloc_flag;
       return l_lpn_alloc_flag;
  EXCEPTION
      WHEN  OTHERS  THEN
            RETURN 'N';
  END  get_lpn_alloc_flag;


  -- This procedures returns different attributes for an LPN

  PROCEDURE get_lpn_attributes(p_lpn_id                  IN NUMBER,
                               x_inventory_item_id       OUT NOCOPY NUMBER,
                               x_gross_weight            OUT NOCOPY NUMBER,
                               x_content_volume          OUT NOCOPY NUMBER,
                               x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
                               x_content_volume_uom_code OUT NOCOPY VARCHAR2,
                               x_tare_weight             OUT NOCOPY NUMBER,
                               x_tare_weight_uom_code    OUT NOCOPY VARCHAR2)
    IS
       l_inventory_item_id       NUMBER:= NULL;
       l_gross_weight            NUMBER:= NULL;
       l_content_volume          NUMBER:= NULL;
       l_gross_weight_uom_code   VARCHAR2(3):= NULL;
       l_content_volume_uom_code VARCHAR2(3):= NULL;
       l_tare_weight             NUMBER      := NULL;
       l_tare_weight_uom_code    VARCHAR2(3)    := NULL;
       l_found_flag VARCHAR2(1)              := NULL;

  BEGIN
     error_code := 'GET_LPN_ATTR';

     get_cached_lpn_attributes (p_lpn_id                 => p_lpn_id,
                                x_inventory_item_id       => l_inventory_item_id,
                                x_gross_weight            => l_gross_weight,
                                x_content_volume          => l_content_volume,
                                x_gross_weight_uom_code   => l_gross_weight_uom_code,
                                x_content_volume_uom_code => l_content_volume_uom_code,
                                x_tare_weight             => l_tare_weight,
                                x_tare_weight_uom_code    => l_tare_weight_uom_code,
                                x_found_flag              => l_found_flag );

       IF( l_found_flag = 'Y') THEN
          if (g_trace_on = 1) then log_event(' using cached values '); END IF;
          x_inventory_item_id  := l_inventory_item_id;
          x_gross_weight       := l_gross_weight;
          x_content_volume     := l_content_volume;
          x_gross_weight_uom_code   := l_gross_weight_uom_code;
          x_content_volume_uom_code := l_content_volume_uom_code;
          x_tare_weight             :=  l_tare_weight;
          x_tare_weight_uom_code    := l_tare_weight_uom_code;
        ELSE

          SELECT
            inventory_item_id,
            Decode(gross_weight_uom_code,NULL,0,nvl(gross_weight,0)),
            gross_weight_uom_code,
            Decode(content_volume_uom_code,NULL,0,nvl(content_volume,0)),
            content_volume_uom_code,
            Decode(tare_weight_uom_code,NULL,0,nvl(tare_weight,0)),
            tare_weight_uom_code
            INTO
            x_inventory_item_id,
            x_gross_weight,
            x_gross_weight_uom_code,
            x_content_volume,
            x_content_volume_uom_code,
            x_tare_weight,
            x_tare_weight_uom_code
            FROM
            wms_license_plate_numbers
            WHERE
            lpn_id = p_lpn_id;

          lpn_attr_table(p_lpn_id).inventory_item_id  := x_inventory_item_id;
          lpn_attr_table(p_lpn_id).gross_weight       := x_gross_weight;
          lpn_attr_table(p_lpn_id).content_volume     := x_content_volume;
          lpn_attr_table(p_lpn_id).gross_weight_uom_code   := x_gross_weight_uom_code;
          lpn_attr_table(p_lpn_id).content_volume_uom_code := x_content_volume_uom_code;
          lpn_attr_table(p_lpn_id).tare_weight             := x_tare_weight;
          lpn_attr_table(p_lpn_id).tare_weight_uom_code    := x_tare_weight_uom_code;

       END IF;


       if (g_trace_on = 1) then
          log_event(' inventory_item_id:'||x_inventory_item_id);
          log_event(' gross_weight:'||x_gross_weight);
          log_event(' gross_weight_uom_code:'||x_gross_weight_uom_code);
          log_event(' content_volume:'||x_content_volume);
          log_event(' content_volume_uom_code:'||x_content_volume_uom_code);
          log_event(' tare:'||x_tare_weight);
          log_event(' tare_uom_code:'||x_tare_weight_uom_code);

        END IF;

  EXCEPTION
     WHEN OTHERS THEN
        if (g_trace_on = 1) then log_event(' LPN attributes not found'); END IF;
        x_inventory_item_id := NULL;
        x_gross_weight := NULL;
        x_gross_weight_uom_code := NULL;
        x_content_volume := NULL;
        x_content_volume_uom_code := NULL;
        x_tare_weight := NULL;
        x_tare_weight_uom_code := NULL;


  END get_lpn_attributes;

  -- This procedures returns different attributes for a package
  PROCEDURE get_package_attributes(p_org_id                  IN NUMBER,
                                   p_package_id              IN NUMBER,
                                   x_inventory_item_id       OUT NOCOPY NUMBER,
                                   x_gross_weight            OUT NOCOPY NUMBER,
                                   x_content_volume          OUT NOCOPY NUMBER,
                                   x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
                                   x_content_volume_uom_code OUT NOCOPY VARCHAR2,
                                   x_tare_weight             OUT NOCOPY NUMBER,
                                   x_tare_weight_uom_code    OUT NOCOPY VARCHAR2)
    IS

       l_c_inventory_item_id       NUMBER:= NULL;
       l_c_gross_weight            NUMBER:= NULL;
       l_c_content_volume          NUMBER:= NULL;
       l_c_gross_weight_uom_code   VARCHAR2(3):= NULL;
       l_c_content_volume_uom_code VARCHAR2(3):= NULL;
       l_c_tare_weight             NUMBER:= NULL;
       l_c_tare_weight_uom_code   VARCHAR2(3):= NULL;

       l_found_flag                VARCHAR2(1):= NULL;

       l_gross_weight            NUMBER;
       l_content_volume          NUMBER;
       l_final_wt                NUMBER := 0;
       l_final_twt               NUMBER := 0;
       l_final_vol               NUMBER := 0;
       l_gross_weight_uom_code   VARCHAR2(3);
       l_content_volume_uom_code VARCHAR2(3);
       l_tare_weight             NUMBER:= NULL;
       l_tare_weight_uom_code    VARCHAR2(3):= NULL;

       l_std_wt_uom              VARCHAR2(3);
       l_std_vol_uom             VARCHAR2(3);
       l_ut_wt                   NUMBER := NULL;
       l_ut_vol                  NUMBER := NULL;
       l_item_id                 NUMBER := NULL;
       l_wt                      NUMBER := NULL;
       l_vol                     NUMBER := NULL;
       l_twt                     NUMBER := NULL;
       l_msg                     VARCHAR2(255);

       CURSOR wts_n_vols IS
          SELECT
            parent_item_id,
            Decode(gross_weight_uom_code,NULL,0,nvl(gross_weight,0)),
            gross_weight_uom_code,
            Decode(content_volume_uom_code,NULL,0,nvl(content_volume,0)),
            content_volume_uom_code,
            Decode(tare_weight_uom_code,NULL,0,nvl(tare_weight,0)),
            tare_weight_uom_code
            FROM
            WMS_PACKAGING_HIST
            WHERE
            PARENT_PACKAGE_id = p_package_id;
  BEGIN
     if (g_trace_on = 1) then log_event(' Entered get label attributes for package:'||p_package_id); END IF;

     error_code := 'GET_PKG_ATTR';

     get_cached_package_attributes (p_org_id              => p_org_id,
                                    p_package_id              => p_package_id,
                                    x_inventory_item_id       => l_c_inventory_item_id,
                                    x_gross_weight            => l_c_gross_weight,
                                    x_content_volume          => l_c_content_volume,
                                    x_gross_weight_uom_code   => l_c_gross_weight_uom_code,
                                    x_content_volume_uom_code => l_c_content_volume_uom_code,
                                    x_tare_weight             => l_c_tare_weight,
                                    x_tare_weight_uom_code    => l_c_tare_weight_uom_code,
                                    x_found_flag              => l_found_flag );

       IF( l_found_flag = 'Y') THEN

          if (g_trace_on = 1) then log_event(' using cached values '); END IF;
          x_inventory_item_id       := l_c_inventory_item_id;
          x_gross_weight            := l_c_gross_weight;
          x_content_volume          := l_c_content_volume;
          x_gross_weight_uom_code   := l_c_gross_weight_uom_code;
          x_content_volume_uom_code := l_c_content_volume_uom_code;
          x_tare_weight             := l_c_tare_weight;
          x_tare_weight_uom_code    := l_c_tare_weight_uom_code;

        ELSE
          x_inventory_item_id := NULL;
          x_gross_weight := NULL;
          x_gross_weight_uom_code := NULL;
          x_content_volume := NULL;
          x_content_volume_uom_code := NULL;
          x_tare_weight             := NULL;
          x_tare_weight_uom_code    := NULL;


          SELECT
            parent_item_id
            INTO
            x_inventory_item_id
            FROM
            WMS_PACKAGING_HIST
            WHERE
            PARENT_PACKAGE_id = p_package_id
            AND rownum < 2;

          if (g_trace_on = 1) then log_event(' container item_id:'||x_inventory_item_id); END IF;

          SELECT
            Decode(weight_uom_code,NULL,0,nvl(unit_weight,0)),
            Decode(volume_uom_code,NULL,0,Nvl(unit_volume,0)),
            weight_uom_code,
            volume_uom_code
            INTO
            l_ut_wt,
            l_ut_vol,
            l_std_wt_uom,
            l_std_vol_uom
            FROM
            mtl_system_items
            WHERE
            organization_id = p_org_id AND
            inventory_item_id = x_inventory_item_id;

          if (g_trace_on = 1) then
             log_event(' Container Item attributes are');
             log_event(' unit_wt'||l_ut_wt);
             log_event(' Unit_vol'||l_ut_vol);
             log_event(' std wt uom'||l_std_wt_uom);
             log_event(' std vol uom '||l_std_vol_uom);
          END IF;
          OPEN wts_n_vols;

          LOOP



             if (g_trace_on = 1) then log_event(' Fetching from wts_n_vols'); END IF;
             FETCH wts_n_vols INTO
               l_item_id,
               l_gross_weight,
               l_gross_weight_uom_code,
               l_content_volume,
               l_content_volume_uom_code,
               l_tare_weight,
               l_tare_weight_uom_code;

             EXIT WHEN wts_n_vols%notfound;

             if (g_trace_on = 1) then
                log_event(' container it id'||l_item_id);
                log_event(' gross_weight '||l_gross_weight);
                log_event(' content_volume '||l_content_volume);
                log_event(' gross_weight_uom_code '||l_gross_weight_uom_code);
                log_event(' content_volume_uom_code '||l_content_volume_uom_code);
                log_event(' tare_weight '||l_tare_weight);
                log_event(' tare_weight_uom_code '||l_tare_weight_uom_code);
             END IF;
                -- Logic
             -- We try to convert everything to the container items wt/vol uom first
             -- If that is null we have to pick up first non null wt/vol uom as standard
             -- for each record logic should be
             -- if the weight uom is not null on the record
             --     if the std wt uom is not set
             --         set this uom as the standard uom
             --     else
             --        if std wt uom is different from the current uom
             --           convert wt to the std uom
             --           if conversion returns null, -1 set the wt to zero
             --        else
             --           no conversion needed
             --        end if
             --      end if
             --  else
             --     there should be no contribution of weight from this record.
             --     set l_gross_weight to zero
             --  end if;
             --  Same logic applies for volume

             IF (l_gross_weight_uom_code IS NOT NULL) THEN

                IF l_std_wt_uom IS NULL THEN

                   l_std_wt_uom := l_gross_weight_uom_code;

                 ELSIF (l_gross_weight_uom_code <> l_std_wt_uom ) THEN

                   l_wt := inv_convert.inv_um_convert
                     ( l_item_id,
                       5,
                       l_gross_weight,
                       l_gross_weight_uom_code,
                       l_std_wt_uom,
                       NULL,
                       null
                       );

                   IF( l_wt < 0 ) THEN
                      if (g_trace_on = 1) then log_event('Error converting UOM from '||l_gross_weight_uom_code||' to '||l_std_wt_uom||' qty '||l_gross_weight); END IF;
                      l_gross_weight := 0;
                    ELSE
                      l_gross_weight := l_wt;
                   END IF;


                   if (g_trace_on = 1) then log_event(' gross_weight - after conv '||l_gross_weight); END IF;

                 ELSE

                   NULL;

                END IF;

              ELSE

                l_gross_weight := 0;

             END IF;

             IF (l_tare_weight_uom_code IS NOT NULL) THEN

                IF l_std_wt_uom IS NULL THEN

                   l_std_wt_uom := l_tare_weight_uom_code;

                 ELSIF (l_tare_weight_uom_code <> l_std_wt_uom ) THEN

                   l_twt := inv_convert.inv_um_convert
                     ( l_item_id,
                       5,
                       l_tare_weight,
                       l_tare_weight_uom_code,
                       l_std_wt_uom,
                       NULL,
                       null
                       );

                   IF( l_twt < 0 ) THEN
                      if (g_trace_on = 1) then log_event('Error converting UOM from '||l_tare_weight_uom_code||' to '||l_std_wt_uom||' qty '||l_tare_weight); END IF;
                      l_tare_weight := 0;
                    ELSE
                      l_tare_weight := l_twt;
                      l_tare_weight_uom_code  := l_std_wt_uom;
                   END IF;

                   if (g_trace_on = 1) then log_event(' tare_weight - after conv '||l_tare_weight); END IF;

                 ELSE

                   NULL;

                END IF;

              ELSE

                l_tare_weight := 0;

             END IF;


             l_final_wt := l_final_wt + l_gross_weight;
             l_final_twt := l_final_twt + l_tare_weight;

             if (g_trace_on = 1) then log_event('new l_final_wt '||l_final_wt); END IF;


             IF (l_content_volume_uom_code IS NOT NULL) THEN

                IF l_std_vol_uom IS NULL THEN

                   l_std_vol_uom := l_content_volume_uom_code;

                 ELSIF (l_content_volume_uom_code <> l_std_vol_uom ) THEN

                   l_vol := inv_convert.inv_um_convert
                     ( l_item_id,
                       5,
                       l_content_volume,
                       l_content_volume_uom_code,
                       l_std_vol_uom,
                       NULL,
                       null
                       );

                   IF( l_vol < 0 ) THEN
                      if (g_trace_on = 1) then log_event('Error converting UOM from '||l_content_volume_uom_code||' to '||l_std_vol_uom||' qty '||l_content_volume); END IF;
                      l_content_volume := 0;

                    ELSE

                      l_content_volume := l_vol;

                   END IF;

                   if (g_trace_on = 1) then log_event(' content_volume - after conv '||l_content_volume); END IF;
                 ELSE

                   NULL;

                END IF;

              ELSE

                l_content_volume := 0;

             END IF;

             l_final_vol := l_final_vol + l_content_volume;
             if (g_trace_on = 1) then log_event(' new l_final_vol '||l_final_vol); END IF;

          END LOOP;

          IF wts_n_vols%isopen then
             CLOSE wts_n_vols;
          END IF;


          l_final_wt := l_final_wt + l_ut_wt;
          l_final_twt := l_final_twt + l_ut_wt;

          l_final_vol := greatest(l_final_vol, l_ut_vol);

          if (g_trace_on = 1) then
             log_event(' l_final_wt - at end '||l_final_wt);
             log_event(' l_final_vol - at end '||l_final_vol);
          END IF;

          x_gross_weight := l_final_wt;
          x_content_volume := l_final_vol;
          x_gross_weight_uom_code := l_std_wt_uom;
          x_content_volume_uom_code := l_std_vol_uom;
          x_tare_weight    := l_final_twt;
          x_tare_weight_uom_code := l_std_wt_uom;

          pkg_attr_table(p_package_id).inventory_item_id       := x_inventory_item_id;
          pkg_attr_table(p_package_id).gross_weight            := x_gross_weight;
          pkg_attr_table(p_package_id).content_volume          := x_content_volume;
          pkg_attr_table(p_package_id).gross_weight_uom_code   := x_gross_weight_uom_code;
          pkg_attr_table(p_package_id).content_volume_uom_code := x_content_volume_uom_code;
          pkg_attr_table(p_package_id).tare_weight             := x_tare_weight;
          pkg_attr_table(p_package_id).tare_weight_uom_code    := x_tare_weight_uom_code;

       END IF;

  EXCEPTION
     WHEN OTHERS THEN
        if (g_trace_on = 1) then log_event('Error Occurred in get Attributes'); END IF;
        l_msg := Sqlerrm;
        if (g_trace_on = 1) then log_event(l_msg); END IF;

  END get_package_attributes;


  -- Returns the conatiner item associated with an LPN

  FUNCTION get_lpn_Itemid(P_lpn_id IN NUMBER)
    return NUMBER
    IS
       l_ret NUMBER := NULL;
  BEGIN
     error_code := 'GET_LPN_ITM';
      IF( cache_lpn_id = p_lpn_id) THEN

        RETURN cache_lpn_item_id;
       ELSE

         SELECT inventory_item_id
           INTO l_ret
           FROM wms_license_plate_numbers
           WHERE
           lpn_id = p_lpn_id;


         cache_lpn_id := p_lpn_id;

         cache_lpn_item_id := l_ret;
      END IF;

     RETURN l_ret;

  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;
  END get_lpn_Itemid;


  -- Returns the conatiner item associated with a package

  FUNCTION get_PACKAGE_Itemid(P_PACKAGE_id IN NUMBER)
    return NUMBER
    IS
       l_ret NUMBER := NULL;
  BEGIN
     error_code := 'GET_PKG_ATTR';
     IF( cache_package_id = p_package_id) THEN

        RETURN cache_pkg_item_id;
      ELSE
        SELECT PARENT_ITEM_ID
          INTO l_ret
          FROM WMS_PACKAGING_HIST
          WHERE
          PARENT_PACKAGE_id = p_PACKAGE_id
          AND rownum < 2;


        cache_package_id := p_package_id;

        cache_pkg_item_id := l_ret;
     END IF;


     RETURN l_ret;

  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;
  END get_package_Itemid;


 -- This procedure inserts rows into packaging history table

 PROCEDURE insert_ph
   (p_orig_header_id            IN NUMBER,
    p_transaction_temp_id       IN NUMBER)
   IS
      l_header_id   NUMBER;
      l_item_id     NUMBER;
      l_org_id      NUMBER;
      l_prim_qty    NUMBER;
      l_rev         VARCHAR2(3);
      l_clpn_id     VARCHAR2(30);
      l_cartonization_id VARCHAR2(30);
      l_citem_id    NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number  VARCHAR2(80);
      l_serial_number VARCHAR2(30);
      counter       NUMBER := 0;
      v_lot_control_code NUMBER := NULL;
      v_serial_control_code NUMBER := NULL;
      l_stemp_id NUMBER := NULL;
      l_qty NUMBER := NULL;
      l_weight NUMBER := NULL;
      l_volume NUMBER := NULL;
      l_gross_weight NUMBER := NULL;
      l_gross_weight_uom_code VARCHAR2(3) := NULL;
      l_content_volume NUMBER := NULL;
      l_content_volume_uom_code VARCHAR2(3) := NULL;
      l_cont_item_id NUMBER := NULL;
      l_tare_weight  NUMBER := NULL;
      l_tare_weight_uom_code VARCHAR2(3) := NULL;


      CURSOR lots is
         SELECT lot_number, serial_transaction_temp_id, primary_quantity
           FROM mtl_transaction_lots_temp
           WHERE
           transaction_temp_id = p_transaction_temp_id;

     CURSOR serials(p_temp_id NUMBER, p_org_id NUMBER, p_item_id NUMBER) is
        SELECT msn.serial_number
          FROM
          mtl_serial_numbers_temp msnt,
          mtl_serial_numbers msn
          WHERE
          msnt.transaction_temp_id = p_temp_id AND
          msn.current_organization_id = p_org_id AND
          msn.inventory_item_id = p_item_id AND
          msn.serial_number >= msnt.fm_serial_number AND
          msn.serial_number <= msnt.to_serial_number;

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     TYPE lot_tab_type IS TABLE OF VARCHAR2(80)
       INDEX BY binary_integer;
     TYPE serial_tab_type IS TABLE OF VARCHAR2(30)
       INDEX BY binary_integer;
     TYPE qty_tab_type IS TABLE OF NUMBER
       INDEX BY binary_integer;

     lot_table    lot_tab_type;
     serial_table serial_tab_type;
     qty_table    qty_tab_type;
     l_temp_id    NUMBER;
     l_msg        VARCHAR2(100);
 BEGIN

    error_code := 'INSERT_PH';

    if (g_trace_on = 1) then log_event('entered insert_ph'); END IF;
    SELECT
      transaction_header_id,
      organization_id,
      inventory_item_id,
      revision,
      primary_quantity,
      content_lpn_id,
      cartonization_id,
      container_item_id
      INTO
      l_header_id,
      l_org_id,
      l_item_id,
      l_rev,
      l_prim_qty,
      l_clpn_id,
      l_cartonization_id,
      l_citem_id
      FROM
      wms_cartonization_temp
      WHERE
      transaction_temp_id =  p_transaction_temp_id;

   IF( p_transaction_temp_id < 0 ) THEN
      l_temp_id := NULL;
    ELSE
      l_temp_id :=  p_transaction_temp_id;
   END IF;



   IF l_header_id > 0 THEN

      if (g_trace_on = 1) then log_event('header_id > 0'); END IF;

      IF l_clpn_id IS NULL THEN

         if (g_trace_on = 1) then log_event('content_lpn_id is null'); END IF;

         select
           lot_control_code,
           serial_number_control_code,
           Decode(weight_uom_code,NULL,0,nvl(unit_weight,0)),
           Decode(volume_uom_code,NULL,0,Nvl(unit_volume,0)),
           weight_uom_code,
           volume_uom_code
           INTO
           v_lot_control_code,
           v_serial_control_code,
           l_weight,
           l_volume,
           l_gross_weight_uom_code,
           l_content_volume_uom_code
           from mtl_system_items msi
           where
           inventory_item_id = l_item_id AND
           organization_id = l_org_id;

         if (g_trace_on = 1) then
            log_event('lot_control_code '||v_lot_control_code );
            log_event('serial_control_code '||v_serial_control_code);
         END IF;

         --Bug 3528061 fix
         IF( (outbound = 'Y') AND (g_allocate_serial_flag = 'N')) THEN
            if (g_trace_on = 1) then
               log_event('outbound and allocate_serial_flag is off');
           END IF;
           v_serial_control_code := 6;
         END IF;
         --Bug 3528061 fix

         IF (v_lot_control_code = 2 AND v_serial_control_code IN (1,6))  THEN

            if (g_trace_on = 1) then log_event(' Lot controlled only '); END IF;
            OPEN lots;
            LOOP
               FETCH lots INTO l_lot_number, l_stemp_id, l_qty;

               EXIT WHEN lots%notfound;

               counter := counter + 1;
               lot_table(counter) := l_lot_number;
               serial_table(counter) := NULL;
               qty_table(counter) := l_qty;


            END LOOP;
            IF( lots%isopen) then
               CLOSE lots;
            END IF;



          ELSIF (v_lot_control_code = 1 AND v_serial_control_code NOT IN (1,6)) THEN

                  if (g_trace_on = 1) then log_event(' Serial controlled only '); END IF;

                  OPEN serials(p_transaction_temp_id,l_org_id, l_item_id);
                  LOOP
                     FETCH serials INTO l_serial_number;

                     EXIT WHEN serials%notfound;
                     counter := counter + 1;
                     lot_table(counter) := NULL;
                     serial_table(counter) := l_serial_number;
                     qty_table(counter) := 1;


                  END LOOP;
                  IF(serials%isopen) then
                     CLOSE serials;
                  END IF;



          ELSIF (v_lot_control_code = 2 AND v_serial_control_code NOT IN (1,6))  THEN

                        if (g_trace_on = 1) then log_event(' Both lot and Serial controlled  '); END IF;

                        OPEN lots;
                        LOOP
                           --FETCH lots.serial_transaction_temp_id, lots.lot_number INTO l_stemp_id,l_lot_number;

                           FETCH lots INTO l_lot_number, l_stemp_id, l_qty;

                           EXIT WHEN lots%notfound;

                           OPEN serials(l_stemp_id,l_org_id, l_item_id);
                           LOOP
                              FETCH serials INTO l_serial_number;

                              EXIT WHEN serials%notfound;

                              counter := counter + 1;
                              lot_table(counter) := l_lot_number;
                              serial_table(counter) := l_serial_number;
                              qty_table(counter) := 1;


                           END LOOP;
                           IF(serials%isopen) then
                              CLOSE serials;
                            END IF;
                        END LOOP;

                        IF lots%isopen then
                           CLOSE lots;
                        END IF;


          ELSE

                                 if (g_trace_on = 1) then log_event(' No Control Item'); END IF;
                                 counter := counter + 1;

                                 lot_table(counter) := NULL;
                                 serial_table(counter) := NULL;
                                 qty_table(counter) := l_prim_qty;



         END IF;


         LOOP
            EXIT WHEN counter <= 0;

            l_gross_weight := l_weight * qty_table(counter);
            l_content_volume := l_volume * qty_table(counter);

            if (g_trace_on = 1) then
               log_event('gross weight '||l_gross_weight);
               log_event('content_volume '||l_content_volume);
            END IF;

            INSERT INTO WMS_PACKAGING_HIST
              (
               organization_id,
               header_id,
               sequence_id,
               pack_level,
               inventory_item_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               revision,
               lot_number,
               fm_serial_number,
               to_serial_number,
               primary_quantity,
               PACKAGE_id,
               parent_package_id,
               lpn_id,
               parent_lpn_id,
               parent_item_id,
               gross_weight,
               content_volume,
               gross_weight_uom_code,
               content_volume_uom_code,
               packaging_mode,
               reference_id
               )
              VALUES
              (l_org_id,
               p_orig_header_id,
               wms_cartnzn_pub.g_wms_pack_hist_seq,
               pack_level,
               l_item_id,
               Sysdate,
               fnd_global.user_id,
               Sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               l_rev,
               lot_table(counter),
               serial_table(counter),
               serial_table(counter),
               qty_table(counter),
               null,
               l_cartonization_id,
               null,
               null,
               l_citem_id,
               l_gross_weight,
               l_content_volume,
               l_gross_weight_uom_code,
               l_content_volume_uom_code,
               packaging_mode,
               l_temp_id
               );

            wms_cartnzn_pub.g_wms_pack_hist_seq := wms_cartnzn_pub.g_wms_pack_hist_seq + 1;

            counter := counter -1;
         END LOOP;


       ELSE
               --L_CLPN_ID IS NOT NULL

               get_lpn_attributes(p_lpn_id => l_clpn_id,
                                  x_inventory_item_id => l_cont_item_id,
                                  x_gross_weight      => l_gross_weight,
                                  x_gross_weight_uom_code => l_gross_weight_uom_code,
                                  x_content_volume    => l_content_volume,
                                  x_content_volume_uom_code => l_content_volume_uom_code,
                                  x_tare_weight            => l_tare_weight,
                                  x_tare_weight_uom_code   => l_tare_weight_uom_code
                                  );


               INSERT INTO WMS_PACKAGING_HIST
                 (organization_id,
                  header_id,
                  sequence_id,
                  pack_level,
                  inventory_item_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  revision,
                  lot_number,
                  fm_serial_number,
                  to_serial_number,
                  primary_quantity,
                  PACKAGE_id,
                  parent_package_id,
                  lpn_id,
                  parent_lpn_id,
                  parent_item_id,
                  gross_weight,
                  content_volume,
                  gross_weight_uom_code,
                  content_volume_uom_code,
                  packaging_mode,
                  reference_id
                  )
                 VALUES
                 (l_org_id,
                  p_orig_header_id,
                  wms_cartnzn_pub.g_wms_pack_hist_seq,
                  pack_level,
                  NULL,
                  Sysdate,
                  fnd_global.user_id,
                  Sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id,
                  null,
                  null,
                  null,
                  NULL,
                  1,
                  null,
                  l_cartonization_id,
                  L_CLPN_ID,
                  null,
                  l_citem_id,
                  l_gross_weight,
                  l_content_volume,
                  l_gross_weight_uom_code,
                  l_content_volume_uom_code,
                  packaging_mode,
                  l_temp_id
                  );
               wms_cartnzn_pub.g_wms_pack_hist_seq :=
                 wms_cartnzn_pub.g_wms_pack_hist_seq + 1;
      END IF;

    ELSE
                              --HEADER ID < 0
                              get_package_attributes(p_org_id   => l_org_id,
                                                     p_package_id => l_clpn_id,
                                                     x_inventory_item_id => l_cont_item_id,
                                                     x_gross_weight      => l_gross_weight,
                                                     x_gross_weight_uom_code => l_gross_weight_uom_code,
                                                     x_content_volume    => l_content_volume,
                                                     x_content_volume_uom_code => l_content_volume_uom_code,
                                                     x_tare_weight            => l_tare_weight,
                                                     x_tare_weight_uom_code   => l_tare_weight_uom_code
                                                     );



                              INSERT INTO WMS_PACKAGING_HIST
                                (organization_id,
                                 header_id,
                                 sequence_id,
                                 pack_level,
                                 inventory_item_id,
                                 creation_date,
                                 created_by,
                                 last_update_date,
                                 last_updated_by,
                                 last_update_login,
                                 revision,
                                 lot_number,
                                 fm_serial_number,
                                 to_serial_number,
                                 primary_quantity,
                                 PACKAGE_id,
                                 parent_package_id,
                                 lpn_id,
                                 parent_lpn_id,
                                 parent_item_id,
                                 gross_weight,
                                 content_volume,
                                 gross_weight_uom_code,
                                 content_volume_uom_code,
                                 packaging_mode,
                                 reference_id,
                                 tare_weight,
                                 tare_weight_uom_code
                                 )
                                VALUES
                                (
                                 l_org_id,
                                 p_orig_header_id,
                                 wms_cartnzn_pub.g_wms_pack_hist_seq,
                                 pack_level,
                                 l_cont_item_id,
                                 Sysdate,
                                 fnd_global.user_id,
                                 Sysdate,
                                 fnd_global.user_id,
                                 fnd_global.login_id,
                                 null,
                                 null,
                                 null,
                                 NULL,
                                 1,
                                 l_clpn_id,
                                 l_cartonization_id,
                                 null,
                                 null,
                                 l_citem_id,
                                 l_gross_weight,
                                 l_content_volume,
                                 l_gross_weight_uom_code,
                                 l_content_volume_uom_code,
                                 packaging_mode,
                                 l_temp_id,
                                 l_tare_weight,
                                 l_tare_weight_uom_code
                                 );

                              wms_cartnzn_pub.g_wms_pack_hist_seq := wms_cartnzn_pub.g_wms_pack_hist_seq + 1;
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
       l_msg := Sqlerrm;
       if (g_trace_on = 1) then log_event('Exception occurred in insert_ph '||l_msg); END IF;
 END insert_ph;


 -- This returns the new transaction temp id to be used to insert
 -- a row in WCT for packing next level

 FUNCTION get_next_temp_id    RETURN NUMBER
   IS
 BEGIN
    dummy_temp_id := dummy_temp_id -1;

    RETURN dummy_temp_id;

 END get_next_temp_id;

 -- This returns the new transaction header id to be used to insert
 -- a row in WCT for packing next level

 FUNCTION get_next_header_id
   RETURN NUMBER
   IS
 BEGIN
    dummy_header_id := dummy_header_id -1;

    RETURN dummy_header_id;

 END get_next_header_id;


 -- This returns the next package to be used

 FUNCTION get_next_package_id
   RETURN NUMBER
   IS
      l_package_sequence NUMBER;
 BEGIN

   if (g_trace_on = 1) then log_event(' In get next package id'); END IF;
   SELECT wms_packaging_hist_s.nextVal into
     l_package_sequence FROM dual;

   RETURN l_package_sequence;

 END get_next_package_id;



 PROCEDURE update_gross_weight(p_header_id      IN NUMBER,
                               p_organization_id IN NUMBER)
   IS
      CURSOR plpns IS
         SELECT
           wph.parent_lpn_id,
           Decode(wph.tare_weight_uom_code,NULL,0,Nvl(wph.tare_weight,0)) tare_weight,
           wph.tare_weight_uom_code
           FROM
           wms_packaging_hist wph
           WHERE
           header_id = p_header_id AND
           organization_id = p_organization_id AND
           parent_lpn_id IS NOT NULL
           ORDER BY parent_lpn_id;



           prev_lpn             NUMBER := -1;
           fin_wt               NUMBER := 0;
           tr_wt                NUMBER := 0;
           l_lpn_cur_gr_wt      NUMBER := NULL;
           l_lpn_wt_from_db     NUMBER := 0;
           gr_wt_uom_code       VARCHAR2(3) := NULL;
           l_wt_uom_from_db     VARCHAR2(3) := NULL;

           l_api_return_status  VARCHAR2(1);
           l_msg_count          NUMBER;
           l_msg_data           VARCHAR2(2000);

           l_lpn_rec            WMS_CONTAINER_PUB.lpn;

 BEGIN

    error_code := 'UPD_GR_WT';



    FOR lpn_cur IN plpns LOOP

       if (g_trace_on = 1) then log_event('calculating gr wt for lpn '||lpn_cur.parent_lpn_id); END IF;

       tr_wt := 0;

       IF( lpn_cur.parent_lpn_id <> prev_lpn ) THEN

          IF( prev_lpn <> -1) THEN

             if (g_trace_on = 1) then
                log_event('adding to gross wt '||fin_wt);
                log_event(' for the lpn '|| prev_lpn);
             END IF;

             SELECT gross_weight
                  , gross_weight_uom_code
               INTO l_lpn_wt_from_db
                  , l_wt_uom_from_db
               FROM wms_license_plate_numbers
              WHERE lpn_id = prev_lpn;

             l_lpn_rec.lpn_id := prev_lpn;
             l_lpn_rec.gross_weight := NVL(l_lpn_wt_from_db,0) + fin_wt;
             l_lpn_rec.gross_weight_uom_code := NVL(l_wt_uom_from_db,gr_wt_uom_code);

             l_api_return_status := fnd_api.g_ret_sts_success;
             wms_container_pvt.modify_lpn
             ( p_api_version      => 1.0
             , p_init_msg_list    => fnd_api.g_false
             , p_commit           => fnd_api.g_false
             , p_validation_level => fnd_api.g_valid_level_full
             , x_return_status    => l_api_return_status
             , x_msg_count        => l_msg_count
             , x_msg_data         => l_msg_data
             , p_lpn              => l_lpn_rec
             , p_caller           => 'WMS_LPNMGMT'
             );

             IF l_api_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF g_trace_on = 1 THEN
                   log_event('Error from wms_container_pvt.modify_lpn: ' || l_msg_data);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             ELSE
                IF g_trace_on = 1 THEN
                   log_event('LPN gross weight updated');
                END IF;
             END IF;
          END IF;


          SELECT gross_weight_uom_code, gross_weight INTO
            gr_wt_uom_code, l_lpn_cur_gr_wt
            FROM wms_license_plate_numbers
            WHERE lpn_id = lpn_cur.parent_lpn_id;

          prev_lpn := lpn_cur.parent_lpn_id ;

          fin_wt := 0;
       END IF;


       IF ( lpn_cur.tare_weight <> 0 ) THEN

          IF (lpn_cur.tare_weight_uom_code IS NOT NULL) THEN

             IF gr_wt_uom_code IS NULL THEN

                if (g_trace_on = 1) then log_event('lpn has null uom'); END IF;

                gr_wt_uom_code := lpn_cur.tare_weight_uom_code;

                IF l_lpn_cur_gr_wt IS NOT NULL OR l_lpn_cur_gr_wt > 0 THEN
                   if (g_trace_on = 1) then log_event('INCONSISTENT LPN DATA - WEIGHT without UOM'); END IF;
                END IF;

                tr_wt := lpn_cur.tare_weight;

              ELSIF (lpn_cur.tare_weight_uom_code <> gr_wt_uom_code) THEN

                tr_wt := inv_convert.inv_um_convert
                  ( null,
                    5,
                    lpn_cur.tare_weight,
                    lpn_cur.tare_weight_uom_code,
                    gr_wt_uom_code,
                    NULL,
                    null
                    );

                IF( tr_wt < 0 ) THEN
                   if (g_trace_on = 1) then log_event('Error converting UOM from '||lpn_cur.tare_weight_uom_code||' to '||gr_wt_uom_code||' qty '||lpn_cur.tare_weight); END IF;
                   tr_wt := 0;
                END IF;

              ELSE
                tr_wt := lpn_cur.tare_weight;
             END IF;

             if (g_trace_on = 1) then log_event(' tare_weight - after conv '||tr_wt); END IF;

             IF( tr_wt > 0) THEN
                fin_wt := fin_wt + tr_wt;
             END IF;

          END IF; -- lpn_cur.tare weight uom code is not null

       END IF; --lpn_cur.tare_weight <> 0

    END LOOP;

    IF( (fin_wt) > 0 AND (prev_lpn IS NOT NULL) AND (prev_lpn > 0) ) THEN

       if (g_trace_on = 1) then
          log_event('adding to gross wt '||fin_wt);
          log_event(' for the lpn '|| prev_lpn);
       END IF;

       SELECT gross_weight
            , gross_weight_uom_code
         INTO l_lpn_wt_from_db
            , l_wt_uom_from_db
         FROM wms_license_plate_numbers
        WHERE lpn_id = prev_lpn;

       l_lpn_rec.lpn_id := prev_lpn;
       l_lpn_rec.gross_weight := NVL(l_lpn_wt_from_db,0) + fin_wt;
       l_lpn_rec.gross_weight_uom_code := NVL(l_wt_uom_from_db,gr_wt_uom_code);

       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_container_pvt.modify_lpn
       ( p_api_version      => 1.0
       , p_init_msg_list    => fnd_api.g_false
       , p_commit           => fnd_api.g_false
       , p_validation_level => fnd_api.g_valid_level_full
       , x_return_status    => l_api_return_status
       , x_msg_count        => l_msg_count
       , x_msg_data         => l_msg_data
       , p_lpn              => l_lpn_rec
       , p_caller           => 'WMS_LPNMGMT'
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF g_trace_on = 1 THEN
             log_event('Error from wms_container_pvt.modify_lpn: ' || l_msg_data);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          IF g_trace_on = 1 THEN
             log_event('LPN gross weight updated');
          END IF;
       END IF;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       if (g_trace_on = 1) then log_event('error occurred in update gross weight'); END IF;
 END update_gross_weight;


 -- This function can be obsoeleted if u use a connect by at the caller

 PROCEDURE get_parent(p_child IN NUMBER,
                      x_par_cart_id OUT NOCOPY NUMBER,
                      x_par_cont_id OUT NOCOPY NUMBER) IS
 BEGIN
    error_code := 'GET_PAR';
    if (g_trace_on = 1) then log_event(' Enter get_parent for child '||p_child); END IF;

    SELECT cartonization_id, container_item_id
      INTO
      x_par_cart_id, x_par_cont_id
      FROM wms_cartonization_temp
      WHERE
      content_lpn_id = p_child AND
      transaction_header_id < 0;

    if (g_trace_on = 1) then
       log_event(' cartonization_id '||x_par_cart_id);
       log_event(' container_item_id'||x_par_cont_id);
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       x_par_cart_id := NULL;
       x_par_cont_id := NULL;
       if (g_trace_on = 1) then
          log_event(' cartonization_id '||x_par_cart_id);
          log_event(' container_item_id'||x_par_cont_id);
       END IF;
 END get_parent;


 -- This procedure is called to generate lpns for the outermost
 -- packages used to pack a mmtt line

 PROCEDURE generate_lpns( P_header_id IN NUMBER,
                          p_organization_id IN NUMBER)
   IS
      orig_temp_id NUMBER := NULL;
      cart_id NUMBER := NULL;
      cont_id NUMBER := NULL;
      par_cart_id NUMBER := NULL;
      par_cont_id NUMBER := NULL;
      l_return_status VARCHAR2(1);
      l_msg_data      varchar2(255);
      l_msg_count     NUMBER;
      v_lpn_id_out    NUMBER;
      v_process_id    NUMBER;
      v_lpn_out       VARCHAR2(30);
      par_lpn_id      NUMBER := NULL;
      l_inventory_item_id NUMBER := NULL;   -- Added for LSP, bug 9087971


      CURSOR bpack_rows IS
         SELECT
           transaction_temp_id,
           cartonization_id,
           CONTAINER_ITEM_ID
           FROM
           wms_cartonization_temp
           WHERE
           transaction_header_id = p_header_id
           --Bug 2864774 fix
           ORDER BY cartonization_id;
      CURSOR obound_rows IS
         SELECT
           wct.transaction_temp_id,
           wct.cartonization_id,
           wct.CONTAINER_ITEM_ID,
           wct.inventory_item_id      -- Added for LSP, bug 9087971
           FROM
           wms_cartonization_temp wct,
           mtl_txn_request_lines mtrl
           WHERE
           wct.move_order_line_id = mtrl.line_id AND
           mtrl.header_id = p_header_id AND
           wct.transaction_header_id >= 0 -- AND
--           wct.container_item_id IS NOT NULL   --ER : 6682436
           -- Bug 3876178
           ORDER BY cartonization_id;



 BEGIN

    error_code := 'GEN_LPNS';

    if (g_trace_on = 1) then log_event('In generated_LPNs '); END IF;
    if (g_trace_on = 1) then log_event('OUTBOUND : '||outbound); END IF;

    IF outbound = 'N' THEN
       OPEN bpack_rows;
     ELSE
       OPEN obound_rows;
       if (g_trace_on = 1) then log_event('opening outbound rows.'); END IF;
    END IF;


    LOOP


       IF outbound = 'N' THEN
          FETCH bpack_rows INTO orig_temp_id, cart_id, cont_id;
          EXIT WHEN bpack_rows%notfound;
        ELSE
             FETCH obound_rows INTO orig_temp_id, cart_id, cont_id, l_inventory_item_id;         -- For LSP, bug 9087971
             if (g_trace_on = 1) then log_event('Fetch suceeded'); END IF;
             EXIT WHEN obound_rows%notfound;
       END IF;

       IF cart_id IS NOT NULL THEN

         -- can potentially use a connect by here
          LOOP

            get_parent(p_child => cart_id,
                       x_par_cart_id => par_cart_id,
                       x_par_cont_id => par_cont_id);

            EXIT WHEN par_cart_id IS NULL;

            cart_id := par_cart_id;
            cont_id := par_cont_id;

         END LOOP;


         par_lpn_id := NULL;


         BEGIN
            SELECT parent_lpn_id INTO par_lpn_id
              FROM wms_packaging_hist
              WHERE
              parent_package_id  = cart_id AND
              header_id = p_header_id AND
              ROWNUM < 2;
         EXCEPTION
            WHEN others THEN
               par_lpn_id := NULL;
         END;

         l_return_status := fnd_api.g_ret_sts_success;

         IF par_lpn_id IS NULL THEN


            wms_container_pub.generate_lpn(  p_api_version => 1.0,
                                             p_validation_level => fnd_api.g_valid_level_none,
                                             x_return_status => l_return_status,
                                             x_msg_count =>  l_msg_count,
                                             x_msg_data =>  l_msg_data,
                                             p_organization_id =>  p_organization_id,
                                             p_container_item_id => cont_id,
                                             p_lpn_id_out => v_lpn_id_out,
                                             p_lpn_out => v_lpn_out,
                                             p_process_id => v_process_id,
                                             p_client_code => wms_deploy.get_client_code(l_inventory_item_id)         -- Added for LSP, bug 9087971
                                             );

            if (g_trace_on = 1) then log_event('generated LPN '||v_lpn_out); END IF;

          ELSE

            if (g_trace_on = 1) then log_event('lpn already generated '||par_lpn_id); END IF;
            v_lpn_id_out := par_lpn_id;

         END IF;



         IF( l_return_status <> fnd_api.g_ret_sts_success ) THEN

            if (g_trace_on = 1) then log_event('ERROR generating the lpns '||l_return_status); END IF;
            RAISE fnd_api.g_exc_unexpected_error;

          ELSE
            UPDATE wms_cartonization_temp
              SET
              cartonization_id = v_lpn_id_out,
              container_item_id = cont_id
              WHERE
              transaction_temp_id = orig_temp_id;

            if (g_trace_on = 1) then log_event('updated wms_cartonization_temp for temp id '||orig_temp_id); END IF;


            UPDATE WMS_PACKAGING_HIST
              SET parent_lpn_id = v_lpn_id_out
              --parent_package_id = NULL
              WHERE
              parent_package_id = cart_id;

            if (g_trace_on = 1) then log_event('updated WMS_PACKAGING_HIST for package_id '||cart_id); END IF;



         END IF; -- l_return_status <> fnd_api.g_ret_sts_success

       END IF;--cart_id IS NOT NULL

    END LOOP;


    IF outbound = 'N' THEN
       IF( bpack_rows%isopen) then
          CLOSE bpack_rows;
       END IF;

     ELSE

       IF obound_rows%isopen then
          CLOSE obound_rows;
       END IF;

   END IF;

   if (g_trace_on = 1) then log_event('updating packaging history'); END IF;

   UPDATE wms_packaging_hist
     SET parent_package_id = NULL
     WHERE
     parent_lpn_id IS NOT NULL AND
       parent_package_id IS NOT NULL AND
         header_id = p_header_id;

       IF packaging_mode <> wms_cartnzn_pub.PR_pKG_mode  THEN
          --need not be called in pick release mode
          update_gross_weight(p_header_id,p_organization_id);
       END IF;

 END generate_lpns;







 PROCEDURE split_lot_serials ( p_organization_id IN NUMBER)
   IS
      l_counter NUMBER := NULL;
      v_allocate_serial_flag VARCHAR2(1) := NULL;
      v_lot_control_code NUMBER := NULL;
      v_serial_control_code NUMBER := NULL;
      curr_temp_id NUMBER := NULL;
      api_table_index NUMBER := 0;
      l_temporary_temp_id NUMBER := NULL;
 BEGIN

    error_code := 'SPLT_LOT_SER';


    if (g_trace_on = 1) then log_event('Entered split_lot_serial '); END IF;
    l_counter := 1;

    --Bug 3528061
    IF outbound = 'N' THEN
       v_allocate_serial_flag := 'Y';
     ELSE
       v_allocate_serial_flag := g_allocate_serial_flag;
    END IF;

    if (g_trace_on = 1) then log_event('size of the temp table is '||temp_id_table_index); END IF;

    LOOP
       EXIT WHEN l_counter > temp_id_table_index;

       if (g_trace_on = 1) then log_event('counter '||l_counter); END IF;

       IF temp_id_table(l_counter).processed <> 'Y' THEN

          --log_event(' processing '||l_counter);

          curr_temp_id := temp_id_table(l_counter).orig_temp_id;

          if (g_trace_on = 1) then log_event('processsing temp_id '||curr_temp_id); END IF;

          select msi.lot_control_code, msi.serial_number_control_code
            INTO v_lot_control_code, v_serial_control_code
            from mtl_system_items msi where
            (msi.inventory_item_id, msi.organization_id) =
            (
               select mmtt.inventory_item_id, mmtt.organization_id from
               wms_cartonization_temp mmtt WHERE mmtt.transaction_temp_id = curr_temp_id
               );

          IF( (v_allocate_serial_flag IS NULL) OR
              (v_allocate_serial_flag = 'N') ) THEN
             v_serial_control_code := 6;
          END IF;

          api_table.delete;

          api_table_index := 0;

          /* Hack for sony */
          api_table_index := api_table_index + 1;

          SELECT mtl_material_transactions_s.NEXTVAL INTO
            api_table(api_table_index).transaction_id
            FROM dual;

          SELECT primary_quantity ,secondary_transaction_quantity INTO
            api_table(api_table_index).primary_quantity,
            api_table(api_table_index).secondary_quantity
            FROM
            wms_cartonization_temp
            WHERE
            transaction_temp_id = curr_temp_id;

          l_temporary_temp_id := api_table(api_table_index).transaction_id;

          /* Hack for sony */


          if (g_trace_on = 1) then log_event(api_table_index||'*'||api_table(api_table_index).transaction_id||'*'||api_table(api_table_index).primary_quantity); END IF;

          FOR l_counter2 IN 1..temp_id_table.COUNT LOOP

             IF temp_id_table(l_counter2).orig_temp_id = curr_temp_id  THEN

                api_table_index := api_table_index + 1;

                api_table(api_table_index).transaction_id :=  temp_id_table(l_counter2).splt_temp_id;
                api_table(api_table_index).primary_quantity :=  temp_id_table(l_counter2).primary_quantity;
                api_table(api_table_index).secondary_quantity  :=  temp_id_table(l_counter2).secondary_quantity;
                temp_id_table(l_counter2).processed := 'Y';

                if (g_trace_on = 1) then log_event(api_table_index||'*'||api_table(api_table_index).transaction_id||'*'||api_table(api_table_index).primary_quantity);  END IF;
             END IF;

          END LOOP;

          IF api_table_index  > 0 THEN
             --Setting  the variable to  order lots  by creation date
             inv_rcv_common_apis.g_order_lots_by := inv_rcv_common_apis.g_order_lots_by_creation_date;

             inv_rcv_common_apis.break
               (p_original_tid        => curr_temp_id,
                p_new_transactions_tb => api_table,
                p_lot_control_code => v_lot_control_code,
                p_serial_control_code => v_serial_control_code);

             --Setting  it back to  default
             inv_rcv_common_apis.g_order_lots_by := inv_rcv_common_apis.g_order_lots_by_exp_date;
          END IF;

          /* Hack for sony */
          UPDATE mtl_transaction_lots_temp
            SET
            transaction_temp_id = curr_temp_id
            WHERE
            transaction_temp_id = l_temporary_temp_id;
          /* Hack for sony */

       END IF; --end for processed <> 'Y'


       --log_event( l_counter||'-'||temp_id_table(l_counter).orig_temp_id
       --                ||'-'||temp_id_table(l_counter).splt_temp_id
       --                );
       l_counter := l_counter + 1;
    END LOOP;

    api_table.delete;

   api_table_index := 0;

   temp_id_table.DELETE;

   temp_id_table_index := 0;

 END split_lot_serials;


 --Bug 2478970 fix

 FUNCTION validate_cont_item(p_item_id IN NUMBER,
                             p_org_id  IN NUMBER)
   RETURN VARCHAR2
   IS
      l_ret VARCHAR2(1) := 'Y';
 BEGIN

    IF p_item_id IS NULL OR
      p_org_id IS NULL THEN
       RETURN 'N';
    END IF;

    SELECT  'Y' INTO l_ret
      FROM dual WHERE exists
      (SELECT inventory_item_id
       FROM  MTL_SYSTEM_ITEMS
       WHERE ORGANIZATION_ID = p_org_id
       AND INVENTORY_ITEM_ID = p_item_id
       AND mtl_transactions_enabled_flag = 'Y'
       AND enabled_flag = 'Y');

   RETURN L_RET;
 EXCEPTION
    WHEN no_data_found THEN
       RETURN 'N';
    WHEN OTHERS THEN
       RETURN 'N';
 END validate_cont_item;

 --**************************************
 -- patchset J bulk picking
   --
   -- API name    : AssignTT
   -- Type        : Private
   -- Function    : Assign task type to records in MMTT
   -- Input Parameters  :
   --
   -- Output Parameters:
   -- Version     :
   --   Current version 1.0
   --
   -- Notes       : calls AssignTT(p_task_id NUMBER)
   --
   -- This procedure loops through mtl_material_transactions_temp table, assign
   -- user defined task type to tasks that have not been assigned a task type
   -- for the given Move Order Header.
   -- This API is created when doing patchset J bulk picking
   -- ****************************************


   PROCEDURE assigntts(
     p_api_version          IN            NUMBER
   , p_init_msg_list        IN            VARCHAR2 :=fnd_api.g_false
   , p_commit               IN            VARCHAR2 :=fnd_api.g_false
   , p_validation_level     IN            NUMBER   := fnd_api.g_valid_level_full
   , x_return_status        OUT NOCOPY    VARCHAR2
   , x_msg_count            OUT NOCOPY    NUMBER
   , x_msg_data             OUT NOCOPY    VARCHAR2
   , p_move_order_header_id IN            NUMBER
   ) IS


   CURSOR c_tasks IS
      SELECT transaction_temp_id
        FROM wms_cartonization_temp wct
       WHERE
          parent_line_id is null or             -- non bulked records
          parent_line_id = transaction_temp_id;  -- parents only

   Cursor c_tasks_con is
   Select transaction_temp_id
   From wms_cartonization_temp
   Where parent_line_id = transaction_temp_id;


     l_task_id       NUMBER;
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
     l_api_name      VARCHAR2(30)   := 'assignTTs';
 BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    IF p_move_order_header_id <> -1 THEN
        OPEN c_tasks;
    ELSE OPEN c_tasks_con;
    END IF;

    LOOP
      IF p_move_order_header_id <> -1 THEN
          FETCH c_tasks INTO l_task_id;
          EXIT WHEN c_tasks%NOTFOUND;
      ELSE
          FETCH c_tasks_con INTO l_task_id;
          EXIT WHEN c_tasks_con%NOTFOUND;
      END IF;
      wms_rule_pvt.assigntt(
        p_api_version                => 1.0
      , p_task_id                    => l_task_id
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status  := fnd_api.g_ret_sts_error;
      END IF;
    END LOOP;
    IF p_move_order_header_id <> -1 THEN
        CLOSE c_tasks;
    ELSE
        CLOSE c_tasks_con;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END assigntts;


 --   Stop level
 --    if specified as zero - cartonizes till the levels setup

 PROCEDURE cartonize(
                      p_api_version           IN    NUMBER,
                      p_init_msg_list         IN    VARCHAR2 :=fnd_api.g_false,
                      p_commit                IN    VARCHAR2 :=fnd_api.g_false,
                      p_validation_level      IN    NUMBER   :=fnd_api.g_valid_level_full,
                      x_return_status         OUT   NOCOPY VARCHAR2,
                      x_msg_count             OUT   NOCOPY NUMBER,
                      x_msg_data              OUT   NOCOPY VARCHAR2,
                      p_out_bound             IN    VARCHAR2,
                      p_org_id                IN    NUMBER,
                      p_move_order_header_id  IN    NUMBER,
                      p_disable_cartonization IN    VARCHAR2,
                      p_transaction_header_id IN    NUMBER,
                      p_stop_level            IN    NUMBER,
                      p_packaging_mode        IN    NUMBER,
                      p_input_for_bulk        IN    WMS_BULK_PICK.bulk_input_rec  DEFAULT null
                      ) IS

                         l_api_name     CONSTANT VARCHAR2(30) := 'cartonize';
                         l_api_version  CONSTANT NUMBER       := 1.0;


                         v1 WCT_ROW_TYPE;

                         cartonization_profile  VARCHAR2(1)   := 'Y';
                         v_cart_value NUMBER;
                         v_container_item_id NUMBER:= NULL;
                         v_qty NUMBER:= -1;
                         v_qty_per_cont NUMBER := -1;
                         v_tr_qty_per_cont NUMBER:= -1;
                         v_sec_tr_qty_per_cont NUMBER:= -1; --invconv kkillams
                         v_lpn_out VARCHAR2(30) := ' ';
                         v_primary_uom_code VARCHAR2(3);
                         v_loop NUMBER := 0;
                         v_process_id NUMBER := 0;
                         v_ttemp_id NUMBER := 0;
                         v_lpn_id_out NUMBER := 0;
                         v_lpn_id NUMBER := 0;
                         ret_value   NUMBER := 29;
                         v_return_status VARCHAR2(1);
                         v_left_prim_quant NUMBER;
                         v_left_tr_quant NUMBER;
                         v_sec_left_tr_quant NUMBER; --invconv kkillams
                         v_sublvlctrl VARCHAR2(1) := '2';
                         --Bug 2720653 fix
                         --l_lpn_id_tbl inv_label.transaction_id_rec_type;
                         l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
                         l_msg_count NUMBER;
                         l_msg_data VARCHAR2(400);
                         l_progress VARCHAR2(10);
                         l_label_status VARCHAR2(500);
                         l_counter NUMBER := 0;
                         v_prev_move_order_line_id NUMBER := 0;
                         space_avail_for NUMBER := 0;
                         tr_space_avail_for NUMBER := 0;
                         sec_tr_space_avail_for NUMBER := 0; --invconv kkillams
                         curr_temp_id mtl_material_transactions_temp.transaction_temp_id%TYPE ;
                         v_lot_control_code NUMBER := NULL;
                         v_serial_control_code NUMBER := NULL;
                         api_table_index NUMBER := 0;
                         l_current_header_id  NUMBER := NULL;
                         l_stop_level    NUMBER := -1;
                         v_prev_item_id  NUMBER := NULL;
                         l_prev_package_id NUMBER := NULL;
                         l_temp_id       NUMBER := NULL;
                         l_item_id       NUMBER := NULL;
                         l_qty           NUMBER := NULL;
                         l_tr_qty        NUMBER := NULL;
                         l_sec_tr_qty    NUMBER := NULL;
                         l_clpn_id       NUMBER := NULL;
                         l_citem_id      NUMBER := NULL;
                         l_package_id      NUMBER := NULL;
                         l_upd_qty_flag VARCHAR2(1) := NULL;
                         l_prev_header_id NUMBER := NULL;
                         l_header_id     NUMBER := NULL;
                         L_no_pkgs_gen   VARCHAR2(1);
                         l_prev_condition  VARCHAR2(1);
                         l_revision_code   VARCHAR2(1);
                         l_lot_code        VARCHAR2(1);
                         l_serial_code     VARCHAR2(1);
                         l_is_revision_control  BOOLEAN;
                         l_is_lot_control       BOOLEAN;
                         l_is_serial_control    BOOLEAN;
                         l_rqoh NUMBER;
                         l_qr   NUMBER;
                         l_qs   NUMBER;
                         l_atr  NUMBER;
                         l_att  NUMBER;
                         l_qoh  NUMBER;
                         l_lpn_fully_allocated  VARCHAR2(1) :='N';
                         l_autocreate_delivery_flag VARCHAR2(1) := 'N';
                         percent_fill_basis         VARCHAR2(1) :='W';
                         l_valid_container VARCHAR2(1) := 'Y';

                         l_cartonize_sales_orders VARCHAR2(1) :=NULL;
                         l_cartonize_manufacturing VARCHAR2(1) :=NULL;
                         l_move_order_type   NUMBER;

                         l_rulebased_setup_exists    NUMBER    := 0;
                         l_api_return_status    VARCHAR2(1);
                         l_count1  NUMBER;

                         CURSOR wct_rows IS
                            SELECT wct.* FROM wms_cartonization_temp wct,
                              mtl_txn_request_lines mtrl,
                              mtl_secondary_inventories sub,
                              mtl_parameters mtlp
                              WHERE
                              wct.move_order_line_id =mtrl.line_id
                              AND mtrl.header_id = p_move_order_header_id
                              AND wct.cartonization_id IS null
                              AND mtlp.organization_id = wct.organization_id
                              AND sub.organization_id = wct.organization_id
--                              AND wct.cartonization_id IS NULL
                              AND wct.transfer_lpn_id IS NULL
                              AND sub.secondary_inventory_name = wct.subinventory_code
                              AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
				   OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
				   OR (NVL(mtlp.cartonization_flag,-1) = 4)
				   OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
				  )
                                ORDER BY wct.move_order_line_id,
                                wct.inventory_item_id, Abs(wct.transaction_temp_id);



                              CURSOR OB_LBPRT IS
                                 SELECT DISTINCT mmtt.cartonization_id FROM
                                   --2513907 fix
                                 wms_cartonization_temp mmtt,
                               --mtl_material_transactions_temp mmtt,
                               mtl_txn_request_lines mtrl WHERE
                               mmtt.move_order_line_id = mtrl.line_id
                               AND mtrl.header_id      = p_move_order_header_id
                               AND mmtt.cartonization_id IS NOT NULL
                                 ORDER BY mmtt.cartonization_id;

                          CURSOR IB_LBPRT IS
                             SELECT DISTINCT mmtt.cartonization_id FROM
                               --2513907 fix
                               wms_cartonization_temp mmtt
                              --mtl_material_transactions_temp mmtt
                              WHERE
                              mmtt.transaction_header_id = p_transaction_header_id
                              AND mmtt.cartonization_id IS NOT NULL
                                ORDER BY mmtt.cartonization_id;

                           /*
                           CURSOR bpack_rows(p_hdr_id NUMBER) IS
                              SELECT * FROM
                                wms_cartonization_temp
                                WHERE
                                transaction_header_id = p_hdr_id
                                AND cartonization_id IS NULL
                                AND transfer_lpn_id IS NULL
                                order by  move_order_line_id,
                                decode(content_lpn_id,null,inventory_item_id,
                                                    decode(sign(p_hdr_id),
                                                           -1,
                                                           wms_cartnzn_pub.Get_package_ItemId(content_lpn_id),
                                                           wms_cartnzn_pub.Get_LPN_ItemId(content_lpn_id)
                             ) ); */


                           CURSOR bpack_rows(p_hdr_id NUMBER) IS
                              SELECT * FROM
                                wms_cartonization_temp
                                WHERE
                                transaction_header_id = p_hdr_id
                                AND cartonization_id IS NULL
                                AND transfer_lpn_id IS NULL
                                order by  move_order_line_id,
                                decode(content_lpn_id,null,inventory_item_id,
                                                    decode(sign(p_hdr_id),
                                                           -1,
                                                           inventory_item_id,
                                                           wms_cartnzn_pub.Get_LPN_ItemId(content_lpn_id)
                             ) ),Abs(transaction_temp_id);


                           CURSOR packages(p_hdr_id NUMBER) IS
                              SELECT
                               transaction_temp_id,
                               inventory_item_id,
                               primary_quantity,
                               transaction_quantity,
                               secondary_transaction_quantity, --invconv kkillams
                               content_lpn_id,
                               container_item_id,
                               cartonization_id
                               FROM
                               wms_cartonization_temp
                               WHERE
                               transaction_header_id = p_hdr_id
                               order by cartonization_id;

                          CURSOR opackages(p_hdr_id NUMBER) IS
                             SELECT
                               wct.transaction_temp_id,
                               wct.inventory_item_id,
                               wct.primary_quantity,
                               wct.transaction_quantity,
                               wct.secondary_transaction_quantity, --invconv kkillams
                               wct.content_lpn_id,
                               wct.container_item_id,
                               wct.cartonization_id
                               FROM
                               wms_cartonization_temp wct,
                               mtl_txn_request_lines mtrl
                               WHERE
                               wct.move_order_line_id = mtrl.line_id AND
                               mtrl.header_id = p_hdr_id
                               order by wct.cartonization_id;

 BEGIN

    error_code := 'CARTONIZE 10';

    SAVEPOINT   cartonize_pub;
    IF (NOT fnd_api.compatible_api_call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name )) THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    IF (fnd_api.to_boolean ( p_init_msg_list )) THEN
       fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    --setting the global variable for trace
    g_trace_on := fnd_profile.value('INV_DEBUG_TRACE');

    log_event('G_CURRENT_RELEASE_LEVEL : '||G_CURRENT_RELEASE_LEVEL);

    if (g_trace_on = 1) then
       log_event('Table_name is '||table_name);

       log_event('Deleting rows in wms_cartonization_temp');
    END IF;

    --making sure that we are starting with an empty table
    DELETE wms_cartonization_temp;

    pkg_attr_table.DELETE;
    lpn_attr_table.DELETE;
    lpns_generated_tb.DELETE;

    -- Setting the global variable for packaging
    packaging_mode := p_packaging_mode;

    -- Setting the global variable for sequence
    --sequence_id := 1;

    IF( packaging_mode = wms_cartnzn_pub.PR_pKG_mode OR
        packaging_mode = wms_cartnzn_pub.mfg_PR_pKG_mode) THEN
       outbound := 'Y';
     ELSIF(packaging_mode IN (wms_cartnzn_pub.int_bP_pkg_mode,
                                wms_cartnzn_pub.mob_bP_pkg_mode ,
                                wms_cartnzn_pub.prepack_pkg_mode) ) THEN
       outbound := 'N';
     ELSE
       outbound := p_out_bound;
    END IF;

    IF( p_disable_cartonization = 'Y') THEN
       -- This is the case when the cartonization is only called
       -- for task type assignment, task splitting and task consolidation
       cartonization_profile := 'N';

     ELSIF (outbound = 'N') THEN
        --  cartonization profile is always Y for non outbound
       cartonization_profile := 'Y';

     ELSE
       BEGIN

          SELECT Nvl(cartonization_flag,-1),
            Nvl(cartonize_sales_orders,'Y'),
            Nvl(cartonize_manufacturing,'N'),
            --Bug 3528061 fix
            Nvl(allocate_serial_flag,'N'),
            NVL(default_pick_op_plan_id,-1)
            INTO
            v_cart_value,
            l_cartonize_sales_orders,
            l_cartonize_manufacturing,
            --Bug 3528061 fix
            g_allocate_serial_flag,
            wms_cartnzn_pub.g_default_pick_op_plan_id
            FROM mtl_parameters
            WHERE organization_id = p_org_id;

            wms_cartnzn_pub.g_org_cartonization_value  :=  v_cart_value;
            wms_cartnzn_pub.g_org_cartonize_so_flag    :=  l_cartonize_sales_orders;
            wms_cartnzn_pub.g_org_cartonize_mfg_flag   :=  l_cartonize_manufacturing;
            wms_cartnzn_pub.g_org_allocate_serial_flag :=  g_allocate_serial_flag;

       EXCEPTION
          WHEN OTHERS THEN
             v_cart_value := NULL;
       END;

       IF( v_cart_value  = 1) THEN

          IF ((packaging_mode = wms_cartnzn_pub.pr_pkg_mode)
              AND (l_cartonize_sales_orders = 'Y'))
            OR
            ((packaging_mode = wms_cartnzn_pub.mfg_pr_pkg_mode)
             AND (l_cartonize_manufacturing = 'Y'))
            THEN
             -- Cartonization is enabled for the whole organization
             v_sublvlctrl := '1';
             cartonization_profile := 'Y';
           ELSE
             cartonization_profile := 'N';
          END IF;

        ELSIF( v_cart_value  = 3) THEN

          IF ((packaging_mode = wms_cartnzn_pub.pr_pkg_mode)
              AND (l_cartonize_sales_orders = 'Y'))
            OR
            ((packaging_mode = wms_cartnzn_pub.mfg_pr_pkg_mode)
             AND (l_cartonize_manufacturing = 'Y'))
            THEN
             --cartonization is controlled at the subinventory level
             v_sublvlctrl := '3';
             cartonization_profile := 'Y';
           ELSE
             cartonization_profile := 'N';
          END IF;
        ELSE
          cartonization_profile := 'N';
       END IF;

    END IF;

    g_sublvlctrl := v_sublvlctrl ; --Bug#7168367.Store it in global variable

    BEGIN
       SELECT percent_fill_basis_flag
         INTO percent_fill_basis
         FROM wsh_shipping_parameters
         WHERE organization_id = p_org_id AND
         ROWNUM = 1;
         wms_cartnzn_pub.g_percent_fill_basis := percent_fill_basis;
    EXCEPTION
       WHEN OTHERS THEN
          percent_fill_basis := 'W';
          wms_cartnzn_pub.g_percent_fill_basis := 'W';
    END;

    IF(g_trace_on = 1) THEN
       log_event(' cartonization profile is '||cartonization_profile||' outbound is'||outbound || ' controlled at sub level is '||v_sublvlctrl);
       log_event('Percent fill basis '||percent_fill_basis);
    END IF;

    IF (p_move_order_header_id <> -1) THEN
       BEGIN
          SELECT Nvl(auto_pick_confirm_flag, 'N')
               , Nvl(autocreate_delivery_flag, 'N')
          INTO l_auto_pick_confirm_flag
             , l_autocreate_delivery_flag
          FROM wsh_picking_batches
          WHERE batch_id =
          (SELECT request_number
          FROM mtl_txn_request_headers
          WHERE header_id = p_move_order_header_id
          AND move_order_type = inv_globals.G_MOVE_ORDER_PICK_WAVE);

          IF l_auto_pick_confirm_flag = 'Y' THEN
             IF (g_trace_on = 1) THEN log_event('Auto pick confirm is ON for this batch'); END IF;
          END IF;

          WMS_CARTNZN_PUB.g_autocreate_delivery_flag := l_autocreate_delivery_flag;
          WMS_CARTNZN_PUB.g_auto_pick_confirm_flag := l_auto_pick_confirm_flag;

       EXCEPTION
       WHEN OTHERS THEN
          l_auto_pick_confirm_flag := 'N';
          WMS_CARTNZN_PUB.g_autocreate_delivery_flag := 'N';
          WMS_CARTNZN_PUB.g_auto_pick_confirm_flag := 'N';
       END;
    END IF;

------------------------ ER : 6682436 START ---------------------------------
-- Rule based cartonization will only be called for Pick Release Mode -------

   IF(g_trace_on = 1) THEN
      log_event('Packagin mode : '|| packaging_mode);
      log_event('wms_cartnzn_pub.PR_pKG_mode : '|| wms_cartnzn_pub.PR_pKG_mode);
   END IF;

   IF WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001
   AND packaging_mode = wms_cartnzn_pub.PR_pKG_mode THEN

      IF(g_trace_on = 1) THEN
         log_event('Checking the rules setup');
      END IF;

      SELECT count(1)
       INTO l_rulebased_setup_exists
       FROM wms_selection_criteria_txn_v
      WHERE rule_type_code = 12
        AND enabled_flag = 1
        AND from_organization_id = p_org_id
        AND ROWNUM = 1;

      IF l_rulebased_setup_exists > 0 THEN
         IF(g_trace_on = 1) THEN
            log_event('Rules setup exists');
         END IF;

         table_name := 'wms_cartonization_temp';

         IF wms_cartnzn_pub.g_org_cartonization_value IN (1,3) THEN
            log_event('Calling rulebased cartonization ');
            WMS_CARTNZN_PUB.rulebased_cartonization
            (
            x_return_status         => l_api_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_out_bound             => 'Y',
            p_org_id                => p_org_id,
            p_move_order_header_id  => p_move_order_header_id,
            p_input_for_bulk        => null
            );

            log_event('RETURNING FROM CARTONIZATION');
            RETURN;   -- Bug : 6962305
         END IF;
      ELSE
         log_event('Rulebased setup does not exist, going to default cartonization logic');
      END IF;  -- Rulebased cartonization
   END IF;  -- Release level check
------------------------ ER : 6682436 END ---------------------------------

    -- This setting ensures that all operations we do are on
    -- wms_cartonization_temp until its changed
    table_name := 'wms_cartonization_temp';

    IF (g_trace_on = 1) THEN log_event(' Inserting mmtt rows to wct'); END IF;

    IF  ( outbound = 'Y') THEN

       IF ( p_move_order_header_id = 0) THEN
          error_code := 'CARTONIZE 20';
          if (g_trace_on = 1) then log_event(' error move order header id '||p_move_order_header_id);  END IF;
          RAISE fnd_api.g_exc_error;
       END IF;

       -- changed for patchset J bulk picking -----------
       -- change for concurrent bulk picking program ------

       IF (g_trace_on = 1) THEN log_event(' move order header id '||p_move_order_header_id);  END IF;
       IF (p_move_order_header_id = -1 ) THEN  -- this is called from concurrent program
        --   if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING '); end if;
           l_move_order_type := INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE;
           if (g_trace_on = 1) then log_event('This is called from concurrent program'); end if;
       ELSE
        -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING '); end if;
         SELECT move_order_type
         INTO l_move_order_type
         FROM mtl_txn_request_headers
         WHERE header_id = p_move_order_header_id;

         if (g_trace_on = 1) then log_event('Move order type:'||l_move_order_type); end if;
      END IF;

      l_auto_pick_confirm_flag := 'N';

       IF l_auto_pick_confirm_flag = 'Y' THEN
          IF (g_trace_on = 1) THEN log_event('Auto pick confirm is ON - Not calling task type assignment'); END IF;

       ELSE
          error_code := 'CARTONIZE 30';

          --- patchset J, bulk picking    ---------------------------
          IF G_CURRENT_RELEASE_LEVEL < G_J_RELEASE_LEVEL OR
             l_move_order_type <> G_MOVE_ORDER_PICK_WAVE THEN
              IF (g_trace_on = 1) THEN log_event(' calling wms_rule_pvt.assigntts for task type assignment' );  END IF;
              wms_rule_pvt.assigntts(
                                  p_api_version => 1.0,
                                  p_move_order_header_id =>  p_move_order_header_id,
                                  x_return_status    => l_return_status,
                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             error_code := 'CARTONIZE 40';
             -- insert the message into the stack
             if (g_trace_on = 1) then log_event(' Task type assignment failed'); END IF;
          END IF;

          l_return_status := fnd_api.g_ret_sts_success;
          END IF; -- end the in line branching

          IF (p_move_order_header_id <> -1 ) THEN
              if (g_trace_on = 1) then log_event(' calling wms_rule_pvt.assign_operation_plan for  OP assignment' );  END IF;
              wms_rule_pvt.assign_operation_plans(
                                               p_api_version => 1.0,
                                               p_move_order_header_id => p_move_order_header_id,
                                               x_return_status    => l_return_status,
                                               x_msg_count        => l_msg_count,
                                               x_msg_data         => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  error_code := 'CARTONIZE 45';
                  -- insert the message into the stack
              if (g_trace_on = 1) then log_event(' Operation plan assignment failed'); END IF;
              END IF;
          END IF;

       END IF;


       IF (g_trace_on = 1) THEN log_event(' inserting mmtt rows of this header into wms_cartonization_temp '|| p_move_order_header_id );  END IF;

       error_code := 'CARTONIZE 50';

       -- Bug 2457428 fix

       create_wct(p_move_order_header_id => p_move_order_header_id,
                  p_transaction_header_id => NULL,
                  p_input_for_bulk =>p_input_for_bulk);

       --INSERT INTO wms_cartonization_temp SELECT mmtt.* FROM
       --mtl_material_transactions_temp mmtt, mtl_txn_request_lines
       --mtrl WHERE mtrl.header_id = p_move_order_header_id AND
       --mmtt.move_order_line_id = mtrl.line_id;

     ELSE --outbound = 'N'

       error_code := 'CARTONIZE 60';
       if (g_trace_on = 1) then log_event(' inserting mmtt rows of this header into wms_cartonization_temp '|| p_transaction_header_id ); END IF;

       -- Bug 2457428 fix

       create_wct(p_move_order_header_id => NULL,
                  p_transaction_header_id => p_transaction_header_id
                  );

       --INSERT INTO wms_cartonization_temp
       --SELECT mmtt.* FROM
       --mtl_material_transactions_temp mmtt
       --WHERE
       --mmtt.transaction_header_id = p_transaction_header_id;

    END IF;

    -- Setting the stop level
    IF p_stop_level IS NULL THEN
       l_stop_level := -1;
     ELSE
       l_stop_level := p_stop_level;
    END IF;

    -- Setting the current level we are packing
    pack_level := 0;


    IF(outbound = 'Y') THEN
       l_current_header_id := p_move_order_header_id;
     ELSE
       l_current_header_id := p_transaction_header_id;
    END IF;


    if (g_trace_on = 1) then
       log_event(' l_stop_level '||l_stop_level);
       log_event(' l_current_level '||pack_level);
       log_event(' l_current_header_id '||l_current_header_id);
    END IF;

    IF( cartonization_profile = 'Y') THEN

       if (g_trace_on = 1) then log_event(' cartonization_profile '||cartonization_profile); END IF;


       --- THis is the Multi level Cartonization loop

       LOOP

          if (g_trace_on = 1) then log_event(' cur lev '||pack_level ||' stop lev'||l_stop_level); END IF;

          EXIT WHEN ( (pack_level >= l_stop_level) AND (l_stop_level <> -1));

          v_prev_item_id := -1;
          v_prev_move_order_line_id  := -1;


          --bpack_rows should select only rows with transaction_header_id = l_current_header_id
          if (g_trace_on = 1) then log_event(' opening  cusror  hdr id'||l_current_header_id); END IF;


          IF( (outbound = 'Y') AND (pack_level = 0)) THEN

             error_code := 'CARTONIZE 70';
             if (g_trace_on = 1) then log_event('opening wct_rows'); END IF;
             OPEN wct_rows;
             if (g_trace_on = 1) then log_event('opened bpack rows'); END IF;
           ELSE
             error_code := 'CARTONIZE 90';
             if (g_trace_on = 1) then log_event('opening bpack_rows'); END IF;
             OPEN bpack_rows(l_current_header_id);
             if (g_trace_on = 1) then log_event(' Opened bpack rows'); END IF;
          END IF;

          -- THis is the loop for cartonization using the container - item
          -- relation ship. The cursor already orders by move_order_line_id
          -- inventory_item_id. Here is the pseudo code logic
          -- 1)Fetch a line
          -- 2)if line has the same move_order_line_id  as the previously fetched row.
          --     a) call the shipping api to see if any container is
          --          setup
          --     b) get the quantity per container
          --   ELSE
          --     if space is available in previous container
          --         pack as much of this item into that container
          --         and reduce the primary_quantity, space available for
          --         correspondingly
          --   end if;
          -- 3)if the line has primary_quantity to pack
          --     calculate the number of containers needed to pack from
          --     quantity per container, pack the line
          --   else
          --   go to the top of the loop to fetch new row

          error_code := 'CARTONIZE 100';

          LOOP

             if (g_trace_on = 1) then log_event(' Fetching rows'); END IF;

             IF( (outbound = 'Y') AND (pack_level = 0)) THEN

                error_code := 'CARTONIZE 110';
                FETCH wct_rows INTO v1;
                EXIT WHEN wct_rows%notfound;

                SELECT
                  revision_qty_control_code,
                  lot_control_code,
                  serial_number_control_code
                  INTO
                  l_revision_code,
                  l_lot_code,
                  l_serial_code
                  FROM    mtl_system_items
                  WHERE   organization_id = v1.organization_id
                  AND     inventory_item_id = v1.inventory_item_id;

                if l_revision_code> 1 then
                   l_is_revision_control := TRUE;
                 else
                   l_is_revision_control := FALSE;
                end if;

                IF l_lot_code > 1 THEN
                   l_is_lot_control := TRUE;
                 ELSE
                   l_is_lot_control := FALSE;
                END IF;

                IF (l_serial_code>1 AND l_serial_code<>6) then
                   l_is_serial_control := TRUE;
                 else
                   l_is_serial_control := FALSE;
                end if;

                IF (v1.allocated_lpn_id IS NOT NULL ) THEN

                   error_code := 'CARTONIZE 120';

                      -- Bug 3740610 No need to call qty tree,getting on-hand qty from table

                        SELECT NVL(SUM(primary_transaction_quantity),0)
                         into l_qoh FROM mtl_onhand_quantities_detail
                         WHERE organization_id = v1.organization_id
                          AND subinventory_code = v1.subinventory_code
                          AND locator_id = v1.locator_id
                         AND lpn_id = v1.allocated_lpn_id;
                          if (g_trace_on = 1) then log_event('lpn_id' || v1.allocated_lpn_id);
                                        log_event('l_qoh' || l_qoh);
                                        log_event('PrimaryQty'|| v1.primary_quantity);
                           end if;

                    --Bug 3740610 Comparing on-hand qty with primary_qty of mmtt

                     IF (  l_qoh = v1.primary_quantity ) THEN
                         l_lpn_fully_allocated := 'Y';
                         select v1.transaction_temp_id, 'Y'
                           into t_lpn_alloc_flag_table(v1.transaction_temp_id)
                           from dual;

                       ELSE
                         l_lpn_fully_allocated := 'N';
                         select v1.transaction_temp_id, 'N'
                           into t_lpn_alloc_flag_table(v1.transaction_temp_id)
                           from dual;
                      END IF;
                    ELSE
                      l_lpn_fully_allocated := 'Y';
                      select v1.transaction_temp_id, 'Y'
                        into t_lpn_alloc_flag_table(v1.transaction_temp_id)
                        from dual;
                      if (g_trace_on = 1) then log_event(' calling qty tree returns unsuccessfully' ); END IF;
                   END IF ;

              ELSE
                   error_code := 'CARTONIZE 130';
                   -- outbound = 'N'
                   FETCH bpack_rows INTO v1;

                   EXIT WHEN bpack_rows%notfound;

                   -- THis setting always ensures that in non outbound
                   -- modes, cartonization is not retricted by lpn
                   -- allocation values

                   l_lpn_fully_allocated := 'N';
             END IF;

             if (g_trace_on = 1) then log_event(' Fetch succeeded');
                                      log_event('lpn_fully_allocated:'||l_lpn_fully_allocated);
                                       log_event ('lpn_id after if:'||v1.allocated_lpn_id);
              end if;


             IF ( v1.allocated_lpn_id IS NOT NULL ) AND
               ( l_lpn_fully_allocated = 'Y' ) THEN
                null;
              ELSE

                --populate lpn_alloc_flag with null for loose item
                select v1.transaction_temp_id, null
                  into  t_lpn_alloc_flag_table(v1.transaction_temp_id)
                  from dual;


                -- If the content_lpn_id is populated on the mmtt record
                -- could be two cases. Either we are trying to pack an LPN
                -- or a package. We will have packages poulated in this
                -- column only by multi level cartonization and when it
                -- does that, the row is inserted with negative header id
                -- Basing on this we either get the item associated with
                -- the lpn, or item associated with the package

                error_code := 'CARTONIZE 140';

                if ( v1.content_lpn_id is not null ) then

                   if (g_trace_on = 1) then log_event(' content_lpn_id IS NOT NULL'); END IF;

                   IF v1.transaction_header_id  < 0 THEN
                      error_code := 'CARTONIZE 150';
                      --THe content_lpn_id has a package in it ..
                      --v1.inventory_item_id := Get_package_ItemId(v1.content_lpn_id);

                    ELSE
                      error_code := 'CARTONIZE 160';
                      --THe content_lpn_id has a LPN in it ..
                      v1.inventory_item_id := Get_LPN_ItemId(v1.content_lpn_id);
                   END IF;

                   -- When we are packaing an lpn or a package the qty is
                   -- always 1
                   v1.primary_quantity := 1;
                   v1.transaction_quantity := 1;

                end if;

                error_code := 'CARTONIZE 170';
                SELECT primary_uom_code INTO v_primary_uom_code FROM mtl_system_items
                  WHERE inventory_item_id = v1.inventory_item_id AND
                  organization_id = v1.ORGANIZATION_ID;

                if ( v1.content_lpn_id is not null ) THEN
                   -- We want to set the transaction uom same as primary uom
                   v1.transaction_uom := v_primary_uom_code;
                END IF;



                if (g_trace_on = 1) then
                   log_event(' inventory_item_id:'||v1.inventory_item_id);
                   log_event(' primary_quantity:'||v1.primary_quantity);
                   log_event(' primary_uom_code:'||v_primary_uom_code);
                   log_event(' transaction_quantity:'||v1.transaction_quantity);
                   log_event(' transaction_uom:'||v1.transaction_uom);
                   log_event(' secondary_transaction_quantity:'||v1.secondary_transaction_quantity); --invconv kkillams
                   log_event(' secondary_uom_code:'||v1.secondary_uom_code); --invconv kkillams
                END IF;



                IF (outbound = 'Y') AND (pack_level = 0) AND
                  (v_prev_move_order_line_id  <> v1.move_order_line_id) THEN
                   l_prev_condition := 'Y';

                 ELSIF (outbound = 'Y') AND (pack_level <> 0) AND
                   ((v_prev_move_order_line_id  <> v1.move_order_line_id) OR
                   ( v1.inventory_item_id <> v_prev_item_id)) THEN

                   l_prev_condition := 'Y';
                 ELSIF (outbound = 'N') AND ( v1.inventory_item_id <>
                                              v_prev_item_id) THEN
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

                IF l_prev_condition = 'Y' THEN


                   if (g_trace_on = 1) then log_event(' call wms_container_pub.container_required_qty api for item id '||v1.inventory_item_id);  END IF;


                   v_prev_item_id := v1.inventory_item_id;
                   v_prev_move_order_line_id := v1.move_order_line_id;
                   v_container_item_id := NULL;
                   v_qty_per_cont := -1;
                   v_qty := -1;
                   space_avail_for := 0;
                   --Bug 2478970 fix
                   l_valid_container := 'Y';

                   IF (outbound = 'Y') AND (pack_level = 0)
                       AND (packaging_mode = wms_cartnzn_pub.pr_pkg_mode) THEN
                      error_code := 'CARTONIZE 180';
                      wsh_interface.Get_Max_Load_Qty(p_move_order_line_id => v1.move_order_line_id,
                                                     x_max_load_quantity  => v_qty_per_cont,
                                                     x_container_item_id  => v_container_item_id,
                                                     x_return_status     => v_return_status);

                      l_valid_container := 'Y'; --Undoing 2478970 fix
                      --Bug 2478970 fix
                      --l_valid_container := validate_cont_item(p_item_id =>v_container_item_id,
                      --                                        p_org_id  =>v1.organization_id);
                      --log_event('validate_cont ret '|| l_valid_container);
                      --Bug 2478970 fix

                      IF(  (v_return_status = fnd_api.g_ret_sts_success) AND
                           (v_qty_per_cont > 0) AND
                           (v_container_item_id IS NOT NULL) AND
                           (v_container_item_id > 0) ) THEN

                         v_qty := ceil(v1.primary_quantity/v_qty_per_cont);
                         -- This quantity needs to be recalculated. This is
                         -- poulated to pass the check marked by '#chk1'

                      END IF;


                      IF (g_trace_on = 1) THEN
                         log_event('wsh_interface.Get_Max_Load_Qty return status'||v_return_status);
                         log_event('container '||v_container_item_id);
                         log_event('Number of dum containers '||v_qty);
                      END IF;

                      v_prev_move_order_line_id := v1.move_order_line_id;



                    ELSE
                      error_code := 'CARTONIZE 190';
                      wms_container_pub.Container_Required_Qty
                        (  p_api_version       => 1.0,
                           x_return_status     => v_return_status,
                           x_msg_count         => l_msg_count,
                           x_msg_data          => l_msg_data,
                           p_source_item_id    => v1.inventory_item_id,
                           p_source_qty        => v1.primary_quantity,
                           p_source_qty_uom    => v_primary_uom_code,
                           p_organization_id   => v1.organization_id,
                           p_dest_cont_item_id => v_container_item_id,
                           p_qty_required       => v_qty
                           );

                      if (g_trace_on = 1) then
                         log_event('container_required_quantity return status'||v_return_status);
                         log_event('container '||v_container_item_id);
                         log_event('Number of conatiners '||v_qty);
                      END IF;


                     v_prev_item_id := v1.inventory_item_id;

                     IF( (v_return_status = fnd_api.g_ret_sts_success )   AND
                         (v_qty IS NOT NULL) AND
                         (v_qty > 0) AND
                         (v_container_item_id IS NOT NULL) AND
                         (v_container_item_id > 0) ) THEN

                        error_code := 'CARTONIZE 200';


                           SELECT max_load_quantity INTO v_qty_per_cont FROM wsh_container_items
                             WHERE load_item_id = v1.inventory_item_id AND
                             master_organization_id = v1.organization_id AND
                             container_item_id = v_container_item_id;

                     END IF;

                   END IF;



                   if (g_trace_on = 1) then log_event('qty per container is '||v_qty_per_cont);  END IF;

                   --#chk1

                   IF( (v_return_status <> fnd_api.g_ret_sts_success ) OR
                       (v_qty_per_cont IS NULL) OR
                       (v_qty IS NULL) OR
                       (v_container_item_id IS NULL) OR
                       (v_qty <= 0) OR
                       (v_container_item_id <= 0) OR
                       (v_qty_per_cont <= 0) OR
                       --Bug 2478970 fix
                       l_valid_container = 'N'
                       ) THEN

                      if (g_trace_on = 1) then log_event('improper values returned by container_required_qty ');  END IF;


                    ELSE

                      select msi.serial_number_control_code
                        INTO  v_serial_control_code
                        from mtl_system_items msi
                        where
                        msi.inventory_item_id = v1.inventory_item_id AND
                        msi.organization_id  = v1.organization_id;


                      IF( (v_serial_control_code NOT IN (1,6) ) AND
                          (Ceil(v_qty_per_cont) > v_qty_per_cont )
                          ) THEN

                         if (g_trace_on = 1) then
                            log_event('cannot split serial controlled items to  fractions');
                            log_event('Please check the container item relationships');
                         END IF;

                         v_qty_per_cont := 0;
                         v_serial_control_code := NULL;
                      END IF;

                      v_serial_control_code := NULL;

                      v_tr_qty_per_cont := inv_convert.inv_um_convert
                        ( v1.inventory_item_id,
                          5,
                          v_qty_per_cont,
                          v_primary_uom_code,
                          v1.transaction_uom,
                          NULL,
                         null
                          );
                     --invconv kkillams
                     IF v1.secondary_uom_code IS NOT NULL THEN
                      v_sec_tr_qty_per_cont := inv_convert.inv_um_convert
                        ( v1.inventory_item_id,
                          5,
                          v_qty_per_cont,
                          v_primary_uom_code,
                          v1.secondary_uom_code,
                          NULL,
                         null
                          );
                      END IF;
                      if (g_trace_on = 1) then log_event(' Transaction qty per conatiner is '||v_tr_qty_per_cont); END IF;
                      if (g_trace_on = 1) then log_event(' Secondary Transaction qty per conatiner is '||v_sec_tr_qty_per_cont); END IF;
                   END IF;

                 ELSE

                   IF (space_avail_for > 0) THEN

                      if (g_trace_on = 1) then log_event(' Space available for '||space_avail_for); END IF;

                      IF (v1.primary_quantity <= space_avail_for) THEN

                         if (g_trace_on = 1) then log_event(' Prim qty '||v1.primary_quantity|| ' <= '||space_avail_for); END IF;

                         space_avail_for := space_avail_for -  v1.primary_quantity;

                         IF( v1.content_lpn_id IS NULL) THEN
                            l_upd_qty_flag := 'Y';

                          ELSE
                            l_upd_qty_flag := 'N';
                         END IF;


                         update_mmtt
                           (        p_transaction_temp_id => v1.transaction_temp_id,
                                    p_primary_quantity   => v1.primary_quantity,
                                    p_transaction_quantity  => v1.transaction_quantity,
                                    p_secondary_quantity    => v1.secondary_transaction_quantity, --invconv kkillams
                                    --p_LPN_string            => v_lpn_out,
                                    p_lpn_id                => v_lpn_id,
                                    p_container_item_id     => v_container_item_id,
                                    p_parent_line_id        => NULL,
                                    p_upd_qty_flag          => l_upd_qty_flag,
                                    x_return_status             => l_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data );

                         v1.primary_quantity := 0;

                       ELSE

                         if (g_trace_on = 1) then log_event(' Prim qty '||v1.primary_quantity|| ' > '||space_avail_for); END IF;

                         tr_space_avail_for := inv_convert.inv_um_convert
                           ( v1.inventory_item_id,
                             5,
                             space_avail_for,
                             v_primary_uom_code,
                             v1.transaction_uom,
                             NULL,
                             null
                             );
                          --invconv kkillams
                         sec_tr_space_avail_for := NULL;
                         IF v1.secondary_uom_code IS NOT NULL THEN
                                 sec_tr_space_avail_for := inv_convert.inv_um_convert
                                   ( v1.inventory_item_id,
                                     5,
                                     space_avail_for,
                                     v_primary_uom_code,
                                     v1.secondary_uom_code,
                                     NULL,
                                     null
                                     );
                         END IF;
                         if (g_trace_on = 1) then log_event(' Tr space avail for '||tr_space_avail_for); END IF;

                         insert_mmtt
                           (        p_transaction_temp_id   => v1.transaction_temp_id,
                                    p_primary_quantity      => space_avail_for,
                                    p_transaction_quantity  => tr_space_avail_for,
                                    p_secondary_quantity    => sec_tr_space_avail_for, --invconv kkillams
                                    --p_LPN_string            => v_lpn_out,
                                    p_lpn_id                => v_lpn_id,
                                    p_container_item_id     => v_container_item_id,
                                    x_return_status      =>     l_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data );


                         v1.primary_quantity := v1.primary_quantity -  space_avail_for;

                         v1.transaction_quantity := inv_convert.inv_um_convert
                           ( v1.inventory_item_id,
                             5,
                             v1.primary_quantity,
                             v_primary_uom_code,
                             v1.transaction_uom,
                             NULL,
                             null
                             );
                         --invconv kkillams
                         IF v1.secondary_uom_code IS NOT NULL THEN
                            v1.secondary_transaction_quantity
                            := inv_convert.inv_um_convert
                                   ( v1.inventory_item_id,
                                     5,
                                     v1.primary_quantity,
                                     v_primary_uom_code,
                                     v1.secondary_uom_code,
                                     NULL,
                                     null
                                     );
                         END IF;

                         space_avail_for := 0;

                         if (g_trace_on = 1) then
                            log_event('Prim qty '||v1.primary_quantity);
                            log_event(' Tr qty   '||v1.transaction_quantity);
                            log_event('Sec Tr qty   '||v1.secondary_transaction_quantity); --invconv kkillams
                            log_event(' Space Avail for '||space_avail_for);
                         END IF;

                      END IF;


                   END IF;

                END IF;


                /* Condition #3 */
                IF ( v_return_status <> FND_API.g_ret_sts_success OR
                     v_qty_per_cont IS NULL                       OR
                     v_qty_per_cont <= 0                          OR
                     v_container_item_id IS NULL                  OR
                     v_tr_qty_per_cont  IS NULL                   OR
                     v_tr_qty_per_cont <= 0                       OR
                     v1.primary_quantity <= 0 ) THEN

                   if (g_trace_on = 1) then log_event(' Container_Required_Qty - inc values');  END IF;
                   /* Condition #3a */
                   NULL;
                 ELSE
                   /* Condition #3b */

                   IF( v1.content_lpn_id IS NULL) THEN
                      l_upd_qty_flag := 'Y';
                    ELSE
                      l_upd_qty_flag := 'N';
                   END IF;

                   v_qty := ceil( v1.primary_quantity/v_qty_per_cont);

                   IF( MOD(v1.primary_quantity,v_qty_per_cont) = 0 ) THEN
                      space_avail_for := 0;
                    else
                      space_avail_for :=  v_qty_per_cont -  MOD(v1.primary_quantity,v_qty_per_cont);
                   END IF;

                   if (g_trace_on = 1) then log_event('space avail for '||space_avail_for); END IF;


                   /* Condition #4 */
                   IF(  (v1.primary_quantity <= v_qty_per_cont) OR ( v_qty = 1) ) THEN

                      if (g_trace_on = 1) then log_event(' primary_quantity <= qty per conatiner or'||' NUMBER OF cont = 1'); END IF;

                      v_lpn_id := get_next_package_id;
                      if (g_trace_on = 1) then
                         log_event(' Generated label Id '||v_lpn_id);
                      END IF;

                         update_mmtt
                        (        p_transaction_temp_id => v1.transaction_temp_id,
                                 p_primary_quantity   => v1.primary_quantity,
                                 p_transaction_quantity  => v1.transaction_quantity,
                                 p_secondary_quantity    => v1.secondary_transaction_quantity, --invconv kkillams
                                 --p_LPN_string            => v_lpn_out,
                                 p_lpn_id                => v_lpn_id,
                                 p_container_item_id     => v_container_item_id,
                                 p_parent_line_id       => NULL,
                                 p_upd_qty_flag         => l_upd_qty_flag ,
                                 x_return_status              => l_return_status,
                                 x_msg_count             => x_msg_count,
                                 x_msg_data              => x_msg_data );
                    ELSE
                      /* Condition #4b */

                      v_loop := v_qty;


                     if (g_trace_on = 1) then log_event(' NUMBER OF cont:'||v_qty); END IF;
                     --Bug2422193 fix moved this update to above as package
                     --ids need TO be generated IN the ORDER IN which rows
                     --are considered for cartonization
                     v_lpn_id := get_next_package_id;
                     if (g_trace_on = 1) then
                        log_event(' Generated label Id '||v_lpn_id);
                        log_event('calling update_mmtt');
                     END IF;

                     update_mmtt
                       (        p_transaction_temp_id => v1.transaction_temp_id,
                                p_primary_quantity   => v_qty_per_cont,
                                p_transaction_quantity  => v_tr_qty_per_cont,
                                p_secondary_quantity    => v_sec_tr_qty_per_cont, --invconv kkillams
                                --p_LPN_string            => v_lpn_out,
                                p_lpn_id                => v_lpn_id,
                                p_container_item_id     => v_container_item_id,
                                p_parent_line_id       => NULL,
                                p_upd_qty_flag         => l_upd_qty_flag,
                                x_return_status       => l_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data );



                     v_loop := v_loop - 1;

                     --Bug2422193 fix

                     LOOP

                        EXIT WHEN v_loop < 2;

                        v_lpn_id := get_next_package_id;
                        if (g_trace_on = 1) then
                           log_event(' Generated label Id '||v_lpn_id);
                           log_event(' calling insert mmtt');
                         END IF;
                        insert_mmtt
                          (        p_transaction_temp_id => v1.transaction_temp_id,
                                   p_primary_quantity   => v_qty_per_cont,
                                   p_transaction_quantity  => v_tr_qty_per_cont,
                                   p_secondary_quantity    => v_sec_tr_qty_per_cont, --invconv kkillams
                                   --p_LPN_string            => v_lpn_out,
                                   p_lpn_id                => v_lpn_id,
                                   p_container_item_id     => v_container_item_id,
                                   x_return_status            => l_return_status,
                                   x_msg_count             => x_msg_count,
                                   x_msg_data              => x_msg_data );

                        if (g_trace_on = 1) then log_event(' called insert mmtt'); END IF;
                        v_loop := v_loop - 1;


                     END LOOP;
                     --Bug2422193 fix
                     --v_lpn_id := get_next_package_id;
                     --log_event(' Generated label Id '||v_lpn_id);

                     --log_event('calling update_mmtt');

                     --update_mmtt
                       --(        p_transaction_temp_id => v1.transaction_temp_id,
                                --p_primary_quantity   => v_qty_per_cont,
                                --p_transaction_quantity  => v_tr_qty_per_cont,
                                --p_LPN_string            => v_lpn_out,
                                --p_lpn_id                => v_lpn_id,
                                --p_container_item_id     => v_container_item_id,
                                --p_parent_line_id       => NULL,
                                --p_upd_qty_flag         => l_upd_qty_flag,
                                --x_return_status             => l_return_status,
                                --x_msg_count             => x_msg_count,
                                --x_msg_data              => x_msg_data );


                     --Bug2422193 fix

                     v_lpn_id := get_next_package_id;
                     if (g_trace_on = 1) then log_event(' Generated label Id '||v_lpn_id); END IF;

                     v_left_prim_quant :=  MOD(v1.primary_quantity,v_qty_per_cont);
                     v_left_tr_quant :=  MOD(v1.transaction_quantity,v_tr_qty_per_cont);

                     IF v1.secondary_uom_code IS NOT NULL THEN --invconv kkillams
                        v_sec_left_tr_quant :=  MOD(v1.secondary_transaction_quantity,v_sec_tr_qty_per_cont);
                     END IF;

                     IF(  v_left_prim_quant = 0 OR  v_left_tr_quant =0) THEN
                        v_left_prim_quant := v_qty_per_cont;
                        v_left_tr_quant   := v_tr_qty_per_cont;
                        IF v1.secondary_uom_code IS NOT NULL THEN --invconv kkillams
                           v_sec_left_tr_quant :=  v_sec_tr_qty_per_cont;
                        END IF;
                     END IF;

                     if (g_trace_on = 1) then log_event('calling insert mmtt'); END IF;
                     insert_mmtt
                       (        p_transaction_temp_id  => v1.transaction_temp_id,
                                p_primary_quantity     => v_left_prim_quant,
                                p_transaction_quantity => v_left_tr_quant,
                                p_secondary_quantity    => v_sec_left_tr_quant, --invconv kkillams
                                --p_LPN_string           => v_lpn_out,
                                p_lpn_id                => v_lpn_id,
                                p_container_item_id    => v_container_item_id,
                                x_return_status       => l_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data );


                     NULL;
                     -- Shipping API

                  END IF;
                  /* Close Condition #4 */
                END IF;
               /* Close Condition #3 */
             END IF;
            /** for v1.allocated_lpn_id is not null*/
          END LOOP;

          if (g_trace_on = 1) then log_event(' end working with wms_container_pub.container_required_qty  api ' );  END IF;

          error_code := 'CARTONIZE 220';

          if (g_trace_on = 1) then log_event(' Calling item-category cartonization'); END IF;

          IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN


             ret_value:= do_cartonization(p_move_order_header_id,0,outbound,
                                          v_sublvlctrl,percent_fill_basis);


           ELSE
             if (g_trace_on = 1) then
                log_event('in else for cartonization');
                log_event('passing header id '||l_current_header_id);
                log_event('passing outbound '||outbound);
                log_event('passing Sub level Control'||v_sublvlctrl);
             END IF;
                ret_value:= do_cartonization(0,l_current_header_id,outbound,
                                             v_sublvlctrl,percent_fill_basis);

          END IF;

          if (g_trace_on = 1) then
             log_event(' cartonization returned'|| ret_value);
             log_event(' calling split_lot_serials ');
          END IF;

          split_lot_serials(p_org_id);

          if (g_trace_on = 1) then log_event(' Populating Packaging History Table'); END IF;

          l_prev_package_id := -1;


          l_prev_header_id := l_current_header_id;

          if (g_trace_on = 1) then log_event(' prev header id '||l_prev_header_id ); END IF;

          l_current_header_id := get_next_header_id;

          if (g_trace_on = 1) then log_event(' current_header_id '||l_current_header_id); END IF;

          error_code := 'CARTONIZE 225';
          t_lpn_alloc_flag_table.delete;
          error_code := 'CARTONIZE 226';
          IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
             error_code := 'CARTONIZE 227';
             OPEN opackages(l_prev_header_id);
           ELSE
             error_code := 'CARTONIZE 228';
             OPEN packages(l_prev_header_id);
          END IF;


          l_no_pkgs_gen := 'Y';

          error_code := 'CARTONIZE 230';

          LOOP

             if (g_trace_on = 1) then log_event('Fetching Packages cursor '); END IF;

             error_code := 'CARTONIZE 240';

             IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
                FETCH opackages INTO l_temp_id,l_item_id, l_qty, l_tr_qty,l_sec_tr_qty, l_clpn_id, l_citem_id, l_package_id;
                EXIT WHEN opackages%notfound;
              ELSE
                   FETCH packages INTO l_temp_id,l_item_id, l_qty, l_tr_qty, l_sec_tr_qty, l_clpn_id, l_citem_id, l_package_id;
                   EXIT WHEN packages%notfound;
             END IF;



             if (g_trace_on = 1) then
                log_event('temp_id '||l_temp_id );
                log_event('item_id  '||l_item_id );
                log_event('qty  '||l_qty );
                log_event('tr_qty '||l_tr_qty);
                log_event('sec_tr_qty '||l_sec_tr_qty);
                log_event('clpn_id '||l_clpn_id);
                log_event('citem_id '||l_citem_id);
                log_event('package_id '||l_package_id);
             END IF;
             if( l_package_id is not null ) THEN

                l_no_pkgs_gen := 'N';
                if( l_package_id <> l_prev_package_id ) then

                   l_prev_package_id := l_package_id;

                   if (g_trace_on = 1) then log_event(' Inserting a new row for package '||l_package_id); END IF;


                   insert_mmtt
                     (    p_transaction_temp_id  => l_temp_id,
                          p_primary_quantity     => l_qty,
                          p_transaction_quantity => l_tr_qty,
                          p_secondary_quantity   => l_sec_tr_qty, --invconv kkillams
                          p_new_txn_hdr_id    => l_current_header_id,
                          p_new_txn_tmp_id      => get_next_temp_id,
                          p_clpn_id              => l_package_id,
                          p_item_id             => l_citem_id,
                          x_return_status          => l_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data );



                end if;

                if (g_trace_on = 1) then log_event(' Calling InsertPH for temp_id'||l_temp_id); END IF;
                IF( outbound = 'Y' ) then
                   Insert_PH(p_move_order_header_id, l_temp_id);
                 ELSE
                   Insert_PH(p_transaction_header_id, l_temp_id);
                END IF;
             END IF;


          END LOOP;

          IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
             IF opackages%isopen THEN
                CLOSE opackages;
             END IF;
           ELSE
             IF packages%isopen THEN
                CLOSE packages;
             END IF;
          END IF;


          IF( l_no_pkgs_gen = 'Y' ) THEN
             if (g_trace_on = 1) then log_event('no labels generated in the previous level-EXITING'); END IF;

             IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN

                IF( wct_rows%isopen) then
                   CLOSE wct_rows;
                END IF;


              ELSE

                IF(bpack_rows%isopen) then
                   CLOSE bpack_rows;
                END IF;


             END IF;

             EXIT;
          END IF;




          IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
             IF wct_rows%isopen THEN
                CLOSE wct_rows;
             END IF;

           ELSE
             IF(bpack_rows%isopen) then
                CLOSE bpack_rows;
             END IF;

          END IF;


          pack_level := pack_level + 1;
          if (g_trace_on = 1) then
             log_event(' Incremented the current level');
             log_event(' going back to the multi-cart loop');
          END IF;

       END LOOP; -- Ends the loop for multi level cartonization


       IF ( outbound = 'Y') THEN
          l_header_id := p_move_order_header_id;
        ELSE
          l_header_id := p_transaction_header_id;
       END IF;

       -- We have to update the end labels to LPNS and update the
       -- packaging history and mmtt correspondingly

       if (g_trace_on = 1) then log_event(' calling Generate_LPNs for header id '||l_header_id); END IF;

       BEGIN
          error_code := 'CARTONIZE 250';

          generate_lpns(p_header_id => l_header_id,
                        p_organization_id => p_org_id);
       EXCEPTION
          WHEN OTHERS THEN
             IF( packaging_mode IN (wms_cartnzn_pub.int_bp_pkg_mode,
                                      wms_cartnzn_pub.mob_bP_pkg_mode ,
                                      wms_cartnzn_pub.prepack_pkg_mode) ) THEN
                if (g_trace_on = 1) then log_event('erroring out since the mode is bulk pack ');  END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSE
                if (g_trace_on = 1) then log_event('not erroring out since the mode is Pick release ');  END IF;
                RAISE fnd_api.g_exc_error;
             END IF;
       END ;


       DELETE wms_cartonization_temp
         WHERE
         transaction_header_id < 0;

     ELSE
                   -- Cartonization profile = 'N'
                   null;
    END IF;

    IF( outbound = 'Y') THEN

       IF l_auto_pick_confirm_flag = 'Y' THEN
          if (g_trace_on = 1) then log_event('Auto pick confirm is ON - Not calling task consolidation - splitting'); END IF;

        ELSE

          if (g_trace_on = 1) then log_event(' calling consolidation' );  END IF;

          -- patchset J bulk picking   -----------------------------------
          if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL
             AND l_move_order_type = g_move_order_pick_wave THEN
                  if (g_trace_on = 1)  then -- log_event('PATCHSET J-- BULK PICKING --START');
                                           log_event('Calling consolidate_bulk_tasks_for_so....');
                                           log_event('move order header id '||p_move_order_header_id); end if;
                  wms_task_dispatch_engine.consolidate_bulk_tasks_for_so
                                          (p_api_version => 1.0,
                                           x_return_status => l_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data,
                                           p_move_order_header_id => p_move_order_header_id);
                   IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
                        -- we don't want to exit if there is any error here, for example data error or something
                        if (g_trace_on = 1) then log_event(' consolidate_bulk_tasks_for_so returns '||l_return_status); END IF;
                   END IF;
                   if (g_trace_on = 1) then log_event(' calling ins_wct_rows_into_mmtt after consolidation'); END IF;

                   ins_wct_rows_into_mmtt( p_m_o_h_id           => p_move_order_header_id,
                                           p_outbound           => 'Y',
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data);
                   -- since the return value is not set up inside above procedure, so no need to check it
                   -- but above procedure will throw unexpected error in case of errors, so this API will capture the
                   -- error.

                   WMS_CARTNZN_PUB.assigntts(
                                                  p_api_version => 1.0,
                                                  p_move_order_header_id =>  p_move_order_header_id,
                                                  x_return_status    => l_return_status,
                                                  x_msg_count        => l_msg_count,
                                                  x_msg_data         => l_msg_data);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       error_code := 'CARTONIZE 40.1';
                       if (g_trace_on = 1) then log_event(' Task type assignment failed'); END IF;
                  END IF;
                 -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING --END'); end if;
         ELSE
             if (g_trace_on = 1) then log_event('Calling consolidate_bulk_tasks...');  end if;
             wms_task_dispatch_engine.consolidate_bulk_tasks
                                          (p_api_version => 1.0,
                                           x_return_status => l_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data,
                                           p_move_order_header_id => p_move_order_header_id);
         END IF;
         ----- end of changed for patchset J bulk picking -----------


         IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
                   --Push the message into the stack
              if (g_trace_on = 1) then log_event(' consolidate_bulk_tasks returns '||l_return_status); END IF;
         END IF;

          if (g_trace_on = 1) then log_event(' calling task splitting' );  END IF;
          wms_task_dispatch_engine.split_tasks
            (p_api_version => 1.0,
             x_return_status => l_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_move_order_header_id => p_move_order_header_id);

          IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
             --Push the message into the stack
             if (g_trace_on = 1) then log_event(' split_tasks returns '||l_return_status); END IF;
          END IF;

          -- patchset J bulk picking -------------------
          IF (G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL
           AND l_move_order_type =g_move_order_pick_wave AND
           p_move_order_header_id = -1 ) THEN    -- calling from concurrent program
               if (g_trace_on = 1) then  -- log_event('PATCHSET J-- BULK PICKING --START');
                                        log_event('calling assign pick slip number...'); end if;
               INV_Pick_Release_PUB.assign_pick_slip_number(
                                    x_return_status         => l_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_move_order_header_id  => p_move_order_header_id,
                                    p_ps_mode            => null,
                                    p_grouping_rule_id  => null,
                                    p_allow_partial_pick => null);
                  IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
                     --Push the message into the stack
                     if (g_trace_on = 1) then log_event(' assign_pick_slip_number returns '||l_return_status); END IF;
                  END IF;
           END IF;

       END IF;

    END IF;



    if (g_trace_on = 1) then log_event(' calling ins_wct_rows_into_mmtt'); END IF;


    -- patchset J bulk picking   -------------------
    IF( outbound= 'Y' ) then
       if (G_CURRENT_RELEASE_LEVEL < G_J_RELEASE_LEVEL) or
          (G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL
           AND l_move_order_type <>g_move_order_pick_wave ) THEN
          ins_wct_rows_into_mmtt( p_m_o_h_id           => p_move_order_header_id,
                               p_outbound           => 'Y',
                               x_return_status      => l_return_status,
                               x_msg_count              => x_msg_count,
                               x_msg_data               => x_msg_data);
        end if;

     ELSE
       ins_wct_rows_into_mmtt( p_m_o_h_id           => p_transaction_header_id,
                               p_outbound           => 'N',
                               x_return_status      => l_return_status,
                               x_msg_count              => x_msg_count,
                               x_msg_data               => x_msg_data);
    END IF;


    error_code := 'CARTONIZE 260';
    if (g_trace_on = 1) then log_event(' calling print label' ); END IF;
    l_counter := 1;



    IF( outbound = 'Y') THEN

       OPEN OB_LBPRT;
       loop
          FETCH OB_LBPRT INTO lpns_generated_tb(l_counter);
          EXIT WHEN OB_LBPRT%notfound;

          if (g_trace_on = 1) then log_event(' print label for lpn '|| lpns_generated_tb(l_counter)); END IF;
          l_counter := l_counter + 1;
       END LOOP;
       IF OB_LBPRT%ISOPEN THEN
          CLOSE OB_LBPRT;
       END IF;

     ELSE
             OPEN IB_LBPRT;
             LOOP
                FETCH IB_LBPRT INTO lpns_generated_tb(l_counter);
                EXIT WHEN IB_LBPRT%notfound;

                if (g_trace_on = 1) then log_event(' print label for lpn '|| lpns_generated_tb(l_counter)); END IF;
                l_counter := l_counter + 1;
             END LOOP;
             IF IB_LBPRT%ISOPEN THEN
                CLOSE IB_LBPRT;
             END IF;
    END IF;


    IF --(l_lpn_id_tbl IS NOT NULL) AND bug 2720653 fix
      (lpns_generated_tb.count > 0) THEN

       IF( packaging_mode = wms_cartnzn_pub.PR_pKG_mode OR
        packaging_mode = wms_cartnzn_pub.mfg_PR_pKG_mode) THEN
          if (g_trace_on = 1) then log_event('wms_cartnzn_pub before  inv_label.print_label '); END IF;

          l_return_status := fnd_api.g_ret_sts_success;

          inv_label.print_label
            (x_return_status => l_return_status
             , x_msg_count => l_msg_count
             , x_msg_data  => l_msg_data
             , x_label_status  => l_label_status
             , p_api_version   => 1.0
             , p_print_mode => 1
             , p_business_flow_code => 22
             , p_transaction_id => lpns_generated_tb
             );
          if (g_trace_on = 1) then log_event('wms_cartnzn_pub after inv_label.print_label ');  END IF;

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');  -- MSGTBD
             FND_MSG_PUB.ADD;

             --IF( packaging_mode IN (2,3,4) ) THEN
             --x_return_status := l_return_status;
             --x_msg_data := l_msg_data;
             --x_msg_count := l_msg_count;
             --END IF;

             if (g_trace_on = 1) then log_event('wms_cartnzn_pub inv_label.print_label FAILED;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')); END IF;
          END IF;
       END IF; -- end packaging_mode in 1

     ELSE
       if (g_trace_on = 1) then log_event('could not cartonize any of the lines'); END IF;

       IF( packaging_mode IN (wms_cartnzn_pub.int_bp_pkg_mode,
                              wms_cartnzn_pub.mob_bP_pkg_mode ,
                              wms_cartnzn_pub.prepack_pkg_mode)) THEN
         if (g_trace_on = 1) then log_event('erroring out since the mode is bulk pack '); END IF;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;

    END IF;

    if (g_trace_on = 1) then log_event('return status is '||x_return_status);  END IF;

    IF wct_rows%isopen THEN
       CLOSE wct_rows;
    END IF;


 EXCEPTION

    WHEN fnd_api.g_exc_error THEN
       if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
       ROLLBACK TO  cartonize_pub;
       x_return_status := fnd_api.g_ret_sts_success;

       FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
       FND_MSG_PUB.ADD;

       if (g_trace_on = 1) then log_event('EXCEPTION occurred from ERROR_CODE:'||error_code); END IF;

       fnd_msg_pub.count_and_get
         (
           p_count  => x_msg_count,
           p_data   => x_msg_data
           );

       --      IF (x_msg_count = 0) THEN
       --        dbms_output.put_line('Successful');
       --       ELSIF (x_msg_count = 1) THEN
       --        dbms_output.put_line ('Not Successful');
       --        dbms_output.put_line (replace(x_msg_data,chr(0),' '));
       --       ELSE
       --        dbms_output.put_line ('Not Successful2');
       --        For I in 1..x_msg_count LOOP
       --           x_msg_data := fnd_msg_pub.get(I,'F');
       --           dbms_output.put_line(replace(x_msg_data,chr(0),' '));
       --        END LOOP;
       --      END IF;

       IF wct_rows%isopen THEN
          CLOSE wct_rows;
       END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
       if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
       ROLLBACK TO  cartonize_pub;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
       FND_MSG_PUB.ADD;
       if (g_trace_on = 1) then log_event('Exception occurred from ERROR_CODE:'||error_code); END IF;
       fnd_msg_pub.count_and_get
         (
           p_count  => x_msg_count,
           p_data   => x_msg_data
           );

       IF wct_rows%isopen THEN
          CLOSE wct_rows;
       END IF;

    WHEN OTHERS  THEN
       ROLLBACK TO  cartonize_pub;
       if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       ERROR_MSG := Sqlerrm;

       FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
       FND_MSG_PUB.ADD;

       if (g_trace_on = 1) then log_event('Exception occurred from ERROR_CODE:'||error_code); END IF;

       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error ) THEN

          fnd_msg_pub.add_exc_msg
            ( g_pkg_name,
              l_api_name,
              ERROR_MSG
              );
       END IF;

      fnd_msg_pub.count_and_get
        (
          p_count  => x_msg_count,
          p_data   => x_msg_data
          );

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;

 END cartonize;


 PROCEDURE UPDATE_MMTT(
                        p_transaction_temp_id   IN        NUMBER,
                        p_primary_quantity        IN      NUMBER,
                        p_transaction_quantity    IN      NUMBER,
                        p_secondary_quantity      IN      NUMBER, --invconv kkillams
                        p_LPN_string              IN      VARCHAR2,
                        p_lpn_id                  IN      NUMBER,
                        p_container_item_id       IN      NUMBER,
                        p_parent_line_id          IN      NUMBER,
                        p_upd_qty_flag            IN      VARCHAR2,
                        x_return_status         OUT       NOCOPY VARCHAR2,
                        x_msg_count             OUT       NOCOPY NUMBER,
                        x_msg_data              OUT       NOCOPY VARCHAR2)
   IS

      l_lpn NUMBER := 0;
      par_line_id NUMBER := NULL;

 BEGIN

    error_code := 'UPD_MMTT';

    if (g_trace_on = 1) then log_event(' In update mmtt '||p_upd_qty_flag ); END IF;

    IF p_lpn_id IS NOT NULL THEN

       l_lpn := p_lpn_id;

     elsIF p_lpn_string IS NOT NULL then

       SELECT lpn_id INTO l_lpn FROM wms_license_plate_numbers WHERE
         license_plate_number = p_lpn_string;
     ELSE

       l_lpn := NULL;
    END IF;


    if (g_trace_on = 1) then log_event('l_lpn '||l_lpn); END IF;



    IF p_primary_quantity IS NULL THEN
       NULL;
       --GET PRIMARY QUANTITY
    END IF;


    IF table_name = 'mtl_material_transactions_temp' THEN

       if (g_trace_on = 1) then log_event(' table_name = mtl_material_transactions_temp'); END IF;


       IF p_parent_line_id = -99999 THEN
          SELECT parent_line_id INTO par_line_id FROM
            mtl_material_transactions_temp WHERE transaction_temp_id =
            p_transaction_temp_id;
       ELSE
          par_line_id := p_parent_line_id;
       END IF;


       if (g_trace_on = 1) then log_event(' upd qty flag is '||p_upd_qty_flag ); END IF;

      IF( p_upd_qty_flag = 'Y') THEN


         UPDATE mtl_material_transactions_temp SET
           primary_quantity = p_primary_quantity,
           transaction_quantity = p_transaction_quantity,
           secondary_transaction_quantity = p_secondary_quantity, --invconv kkillams
           cartonization_id = l_LPN,
           container_item_id = p_container_item_id,
           parent_line_id = par_line_id,
           last_update_date = Sysdate,
           last_updated_by = fnd_global.user_id
           WHERE
           transaction_temp_id = p_transaction_temp_id;
       ELSE
         UPDATE mtl_material_transactions_temp SET
           cartonization_id = l_LPN,
           container_item_id = p_container_item_id,
           parent_line_id = par_line_id,
           last_update_date = Sysdate,
           last_updated_by = fnd_global.user_id
           WHERE
           transaction_temp_id = p_transaction_temp_id;
      END IF;


     ELSE

      if (g_trace_on = 1) then log_event(' table_name = wms_cartonization_temp');  END IF;

      IF p_parent_line_id = -99999 THEN

         SELECT parent_line_id INTO par_line_id FROM
           wms_cartonization_temp WHERE transaction_temp_id =
           p_transaction_temp_id;
       ELSE
         par_line_id := p_parent_line_id;
      END IF;

      if (g_trace_on = 1) then log_event(' upd qty flag is '||p_upd_qty_flag ); END IF;

      IF( p_upd_qty_flag = 'Y') THEN

         UPDATE wms_cartonization_temp SET
           primary_quantity = p_primary_quantity,
           transaction_quantity = p_transaction_quantity,
           secondary_transaction_quantity = p_secondary_quantity, --invconv kkillams
           cartonization_id = l_LPN,
           parent_line_id = par_line_id,
           container_item_id = p_container_item_id,
           last_update_date = Sysdate,
           last_updated_by = fnd_global.user_id
           WHERE
           transaction_temp_id = p_transaction_temp_id;
       ELSE
         UPDATE wms_cartonization_temp SET
           cartonization_id = l_LPN,
           parent_line_id = par_line_id,
           container_item_id = p_container_item_id,
           last_update_date = Sysdate,
           last_updated_by = fnd_global.user_id
           WHERE
           transaction_temp_id = p_transaction_temp_id;
      END IF;



    END IF;



 END update_mmtt;



 PROCEDURE INSERT_MMTT(
                        p_transaction_temp_id   IN      NUMBER,
                        p_primary_quantity      IN      NUMBER,
                        p_transaction_quantity  IN      NUMBER,
                        p_secondary_quantity    IN      NUMBER , --invconv kkillams
                        p_LPN_string            IN      VARCHAR2,
                        p_lpn_id                IN      NUMBER,
                        p_container_item_id     IN      NUMBER,
                        p_new_txn_hdr_id        IN      NUMBER,
                        p_new_txn_tmp_id        IN      NUMBER,
                        p_clpn_id               IN      NUMBER,
                        p_item_id               IN      NUMBER,
                        x_return_status         OUT     NOCOPY VARCHAR2,
                        x_msg_count             OUT     NOCOPY NUMBER,
                        x_msg_data              OUT     NOCOPY VARCHAR2 )
   IS

      v1 WCT_ROW_TYPE;
      cnt NUMBER;

      l_lpn NUMBER;
 BEGIN
    error_code := 'INS_MMTT';
    if (g_trace_on = 1) then log_event(' In insert mmtt with temp_id '||p_transaction_temp_id ); END IF;

    IF p_lpn_id IS NOT NULL THEN
       l_lpn := p_lpn_id;

     elsIF p_lpn_string IS NOT NULL THEN

       SELECT lpn_id INTO L_lpn FROM wms_license_plate_numbers WHERE
         license_plate_number = p_lpn_string;

     ELSE

       l_lpn := NULL;

    END IF;

    if (g_trace_on = 1) then
       log_event(' lpn id IS '||l_lpn);
       log_event(' table name is '||table_name);
    END IF;

    IF( table_name = 'wms_cartonization_temp' ) THEN


       SELECT *  INTO  v1 FROM wms_cartonization_temp WHERE
         transaction_temp_id = p_transaction_temp_id AND ROWNUM < 2;

     ELSE
       --Bug 3296177 code should never come here
       if (g_trace_on = 1) THEN  log_event('ERROR:INS_MMTT with mtl_material_transactions_temp'); end if;
       RAISE fnd_api.g_exc_error;
       --SELECT *  INTO  v1 FROM mtl_material_transactions_temp WHERE
       --transaction_temp_id = p_transaction_temp_id;

    END IF;

    if (g_trace_on = 1) then log_event(' v1.inventory_item_id is '||v1.inventory_item_id); END IF;

    v1.primary_quantity := p_primary_quantity;
    v1.transaction_quantity := p_transaction_quantity;
    v1.secondary_transaction_quantity :=  p_secondary_quantity; --invconv kkillams
    v1.cartonization_id := l_LPN;
    v1.container_item_id := p_container_item_id;
    v1.last_update_date := Sysdate;
    v1.last_updated_by := fnd_global.user_id;
    v1.creation_date := Sysdate;
    v1.created_by := fnd_global.user_id;


    IF p_new_txn_hdr_id IS NOT NULL THEN
      v1.transaction_header_id := p_new_txn_hdr_id;
    END IF;

    IF ( p_new_txn_tmp_id IS NULL AND p_transaction_temp_id > 0 ) THEN

       SELECT mtl_material_transactions_s.NEXTVAL
         INTO v1.transaction_temp_id
         FROM dual;

     ELSE

       v1.transaction_temp_id := p_new_txn_tmp_id;

    END IF;

   IF( p_clpn_id IS NOT NULL) THEN
      v1.content_lpn_id := p_clpn_id;
   END IF;


   IF ( p_transaction_temp_id > 0 AND v1.transaction_temp_id > 0 ) then
      temp_id_table_index := temp_id_table_index + 1;
      temp_id_table(temp_id_table_index).orig_temp_id := p_transaction_temp_id;
      temp_id_table(temp_id_table_index).splt_temp_id :=  v1.transaction_temp_id;
      temp_id_table(temp_id_table_index).primary_quantity :=  v1.primary_quantity;
      temp_id_table(temp_id_table_index).secondary_quantity :=  v1.secondary_transaction_quantity;
   END IF;


    IF p_item_id IS NOT NULL THEN
      v1.inventory_item_id := p_item_id;
    END IF;


   IF (table_name = 'mtl_material_transactions_temp') THEN

      RAISE fnd_api.g_exc_error;
      --wms_task_dispatch_engine.insert_mmtt
        --(l_mmtt_rec => v1);

    ELSE

      wms_task_dispatch_engine.insert_wct
        (l_wct_rec => v1);

   END IF;





 END insert_mmtt;







 PROCEDURE log_event(
                      p_message VARCHAR2)
  IS

     l_module VARCHAR2(255);
     l_mesg VARCHAR2(255);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

   l_module := 'wms.plsql.' || 'wms_cartnzn_pub' || '.' || 'cartonization';

   --inv_pick_wave_pick_confirm_pub.TraceLog(err_msg => p_message,
   --                                      module => 'WMS_CARTNZN_PUB'
   --                                      );


   l_mesg := to_char(sysdate, 'YYYY-MM-DD HH:DD:SS') || p_message;

   IF (l_debug = 1) THEN
      -- dbms_output.put_line(l_mesg);
      inv_trx_util_pub.trace(l_mesg, 'WMS_CARTNZN_PUB');
   END IF;


 END log_event;





 PROCEDURE test IS

    x_return_status VARCHAR2(100);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(300);
    mlid       NUMBER;
    v_qty_per_cont  NUMBER;
    v_container_item_id  NUMBER;
   v_return_status  VARCHAR2(300);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    /*mlid := 1;
    table_name := 'WMS_CARTONIZATION_TEMP';
      mlid := do_cartonization(mohdrid =>5388, trxhdrid =>3243813, outbound => 'N', sublvlctrl =>'1');

     dbms_output.put_line(mlid);*/


      cartonize( p_api_version => 1.0,
                 p_commit =>fnd_api.g_false,
                 p_out_bound => 'N',
                 p_org_id => 1884,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 --p_move_order_header_id => 5388,
                 p_transaction_header_id => 3243813,
                 --p_stop_level           => 2,
              p_packaging_mode       => 3
                 );

    /*
    ins_wct_rows_into_mmtt(
      p_m_o_h_id    => 40262,
      x_return_status=> x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data  => x_msg_data     );

      SELECT line_id INTO mlid FROM mtl_txn_request_lines WHERE header_id = 40262
      AND roWnum < 2;

      wsh_interface.Get_Max_Load_Qty(p_move_order_line_id => mlid,
      x_max_load_quantity  => v_qty_per_cont,
      x_container_item_id  => v_container_item_id,
      x_return_status      => v_return_status);

      --dbms_output.put_line(v_qty_per_cont);
      --dbms_output.put_line(v_container_item_id);
      --  dbms_output.put_line( v_return_status);
      */

 END test;





 FUNCTION do_cartonization( mohdrid NUMBER, trxhdrid NUMBER, outbound VARCHAR2, sublvlctrl VARCHAR2, per_fill VARCHAR2) RETURN NUMBER IS
    language java name
      'oracle.apps.wms.cartonization.server.Cartonization.start(java.lang.Long, java.lang.Long, java.lang.String, java.lang.String, java.lang.String) return java.lang.Long';


   --This procedure inserts records into wms_device_requests table for further
    -- processing by device integration code.This procedure is called from
    -- WMSCRTNB.pls and WMSTSKUB.pls

  PROCEDURE insert_device_request_rec(p_mmtt_row IN mmtt_row)
    IS

       CURSOR lot_ser_cursor(p_transaction_temp_id NUMBER) IS
          SELECT
            mtlt.lot_number lot_num,
           mtlt.transaction_quantity lot_qty,
            msnt.fm_serial_number ser_num
            FROM mtl_material_transactions_temp mmtt,
            mtl_transaction_lots_temp mtlt,
            mtl_serial_numbers_temp msnt
            WHERE
            mmtt.transaction_temp_id = p_transaction_temp_id
            AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
            AND mmtt.transaction_temp_id = msnt.transaction_temp_id(+)
            AND ((mmtt.transaction_temp_id=msnt.transaction_temp_id
                  AND mtlt.serial_transaction_temp_id=msnt.transaction_temp_id)
                 OR  1=1);

       l_serial_code NUMBER;
       l_lot_code NUMBER;
       wdrData wdr_row;
       l_device_id NUMBER;
       l_qty NUMBER;
       l_count NUMBER;
       l_bus_event_id NUMBER;

 BEGIN


    IF wms_device_integration_pvt.wms_call_device_request = 1 THEN
       --set in INVPPICB.pls through call to is_device_set_up()

       l_bus_event_id :=
         WMS_Device_Integration_PVT.wms_be_pick_release;

     ELSIF wms_device_integration_pvt.wms_call_device_request = 2 THEN
       --set in INVUTILB.pls/WMSTSKUB.pls through call to is_device_set_up()

       l_bus_event_id :=
         WMS_Device_Integration_PVT.wms_be_mo_task_alloc;
    END IF;


    IF wms_device_integration_pvt.wms_call_device_request IS NOT NULL THEN
       --insert line for load operation
       INSERT INTO wms_device_requests (request_id,
                                        task_id,
                                        task_summary,
                                        task_type_id,
                                        business_event_id,
                                        organization_id,
                                        subinventory_code,
                                        locator_id,
                                        transfer_org_id,
                                        transfer_sub_code,
                                        transfer_loc_id,
                                        inventory_item_id,
                                        revision,
                                        uom,
					lpn_id,
                                        xfer_lpn_id,--4472870
                                        transaction_quantity,
                                        last_update_date,
                                        last_updated_by) VALUES

         ( WMS_Device_Integration_PVT.wms_pkRel_dev_req_id, --global var so that for all lines in a pick release, it remains same
           p_mmtt_row.transaction_temp_id,
           'Y',
           1, --"LOAD"
           l_bus_event_id,
           p_mmtt_row.organization_id ,  --use you local variables for these values
           p_mmtt_row.subinventory_code,
           p_mmtt_row.locator_id ,
           p_mmtt_row.transfer_organization,
           NULL,
           NULL,
           p_mmtt_row.inventory_item_id,
           p_mmtt_row.revision,
           p_mmtt_row.transaction_uom,
	   p_mmtt_row.allocated_lpn_id,
           p_mmtt_row.cartonization_id,
           p_mmtt_row.transaction_quantity,
           Sysdate,
           FND_GLOBAL.USER_ID);


       --insert another line for drop
       INSERT INTO wms_device_requests (request_id,
                                        task_id,
                                        task_summary,
                                        task_type_id,
                                        business_event_id,
                                        organization_id,
                                        subinventory_code,
                                        locator_id,
                                        transfer_org_id,
                                        transfer_sub_code,
                                        transfer_loc_id,
                                        inventory_item_id,
                                        revision,
                                        uom,
					lpn_id,
                                        xfer_lpn_id, --4472870
                                        transaction_quantity,
                                        last_update_date,
                                        last_updated_by) VALUES

         ( WMS_Device_Integration_PVT.wms_pkRel_dev_req_id, --global var so that for all lines in a pick release, it remains same
           p_mmtt_row.transaction_temp_id,
           'Y',
           2, --"DROP"
           l_bus_event_id,
           p_mmtt_row.organization_id ,
           NULL,
           NULL,
           p_mmtt_row.transfer_organization,
           p_mmtt_row.transfer_subinventory ,
           p_mmtt_row.transfer_to_location ,
           p_mmtt_row.inventory_item_id,
           p_mmtt_row.revision,
           p_mmtt_row.transaction_uom,
	   p_mmtt_row.allocated_lpn_id,
           p_mmtt_row.cartonization_id,
           p_mmtt_row.transaction_quantity,
           Sysdate,
           FND_GLOBAL.USER_ID);

       wdrdata.request_id := WMS_Device_Integration_PVT.wms_pkrel_dev_req_id;
       wdrData.organization_id := p_mmtt_row.organization_id;
       wdrData.subinventory_code := p_mmtt_row.subinventory_code ;
       wdrData.business_event_id := l_bus_event_id;
       wdrData.locator_id := p_mmtt_row.locator_id;
       wdrData.task_id := p_mmtt_row.transaction_temp_id ;
       wdrData.task_summary := 'Y';
       wdrData.transfer_org_id   := p_mmtt_row.transfer_organization;
       wdrData.transfer_sub_code := p_mmtt_row.transfer_subinventory;
       wdrData.transfer_loc_id   := p_mmtt_row.transfer_to_location;


       --Call an api to get the device, this API also updates above
       --inserted records WITH found matching device id
       l_device_id := WMS_Device_Integration_PVT.SELECT_DEVICE(wdrData,'Y',NULL);



       IF  l_device_id <> 0 THEN --process further only if device IS found

          --CHECK whether it is a lot/Serial controlled item
          SELECT
            msi.serial_number_control_code,
            msi.lot_control_code
            INTO
            l_serial_code,
            l_lot_code
            FROM mtl_system_items msi
            WHERE msi.inventory_item_id = p_mmtt_row.inventory_item_id
            AND   msi.organization_id   = p_mmtt_row.organization_id;


          IF (l_lot_code >1 OR l_serial_code >1) THEN --LOT OR/AND SERIAL ITEMS

             --check to see whether need to insert lot/ser record
             IF wms_device_integration_pvt.wms_insert_lotSer_rec_WDR = 1 THEN

                FOR l_rec IN lot_ser_cursor(p_mmtt_row.transaction_temp_id) LOOP
                   IF (l_rec.lot_num IS NOT NULL OR l_rec.ser_num IS NOT NULL) THEN
                      IF (l_rec.ser_num IS NOT NULL) THEN
                         l_qty := 1;
                       ELSE
                         l_qty := l_rec.lot_qty;
                      END IF;
                      l_count := l_count + 1;
                      INSERT INTO wms_device_requests
			(request_id,
			 task_id,
			 relation_id,
			 sequence_id,
			 task_summary,
			 task_type_id,
			 business_event_id,
			 organization_id,
			 subinventory_code,
			 locator_id,
			 transfer_org_id,
			 transfer_sub_code,
			 transfer_loc_id,
			 inventory_item_id,
			 revision,
			 uom,
			 lot_number,
			 lot_qty,
			 serial_number,
			 lpn_id,
			 xfer_lpn_id,
			 transaction_quantity,
			 device_id,
			 status_code,
			 last_update_date,
			 last_updated_by,
			 last_update_login)
			VALUES
                        (WMS_Device_Integration_PVT.wms_pkRel_dev_req_id,
                         p_mmtt_row.transaction_temp_id,
                         NULL,
                         NULL,
                         'N',
                         NULL,
                         l_bus_event_id,
                         p_mmtt_row.organization_id,
                         p_mmtt_row.subinventory_code,
                         p_mmtt_row.locator_id,
                         p_mmtt_row.transfer_organization,
                         p_mmtt_row.transfer_subinventory,
                         p_mmtt_row.transfer_to_location,
                         p_mmtt_row.inventory_item_id,
                         p_mmtt_row.revision,
                         p_mmtt_row.TRANSACTION_uom,
                         l_rec.lot_num,
                         l_rec.lot_qty,
                         l_rec.ser_num,
			 p_mmtt_row.allocated_lpn_id,
			 p_mmtt_row.cartonization_id,
			 l_qty,
                         l_device_id,
                         'S',
                         p_mmtt_row.last_update_date,
                         p_mmtt_row.last_updated_by,
                         p_mmtt_row.last_update_login);
                   END IF;
                END LOOP;

                IF(l_count = 0) THEN
                   if (g_trace_on = 1) then
                      log_event('Error in inserting lot serial details in WDR,no data');
                   END IF;

                END IF;

             END IF;--Lot/serial enabled check

          END IF;--lot/serial item check

       END IF; -- device IS found

    END IF;--p_mmtt_row.transaction_temp_id > 0


  END insert_device_request_rec;


 PROCEDURE ins_wct_rows_into_mmtt(
                                   p_m_o_h_id         IN       NUMBER,
                                   p_outbound         IN      VARCHAR2,
                                   x_return_status      OUT     NOCOPY VARCHAR2,
                                   x_msg_count          OUT     NOCOPY NUMBER,
                                   x_msg_data           OUT     NOCOPY VARCHAR2)
   is
      CURSOR wct_rows IS
         SELECT wct.* FROM wms_cartonization_temp wct,
           mtl_txn_request_lines mtrl WHERE wct.move_order_line_id =
           mtrl.line_id AND mtrl.header_id = p_m_o_h_id;

      -- patchset J bulk picking  ---
      -- following cursor will be used for calling from concurrent program   --
      -- also after patchset J, this cursor will replace wct_row since no need to
      -- query by move order header  and also to query parent lines ---------------------
      CURSOR wct_rows_bulk IS
         SELECT wct.* FROM wms_cartonization_temp wct;

      -- end of patchset J bulk picking --------------

      CURSOR bpack_rows IS
           SELECT * FROM wms_cartonization_temp
             WHERE
             transaction_header_id = p_m_o_h_id;

      CURSOR lot_ser_cursor(p_transaction_temp_id NUMBER) IS
         SELECT
           mtlt.lot_number lot_num,
           mtlt.transaction_quantity lot_qty,
           msnt.fm_serial_number ser_num
           FROM mtl_material_transactions_temp mmtt,
           mtl_transaction_lots_temp mtlt,
           mtl_serial_numbers_temp msnt
           WHERE
           mmtt.transaction_temp_id = p_transaction_temp_id
           AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
           AND mmtt.transaction_temp_id = msnt.transaction_temp_id(+)
           AND ((mmtt.transaction_temp_id=msnt.transaction_temp_id
                 AND mtlt.serial_transaction_temp_id=msnt.transaction_temp_id)
                OR  1=1);

      v2 WCT_ROW_TYPE;
      v1 MMTT_ROW_TYPE;
      v_lpn VARCHAR2(255);
      v_exist VARCHAR2(1);
      l_msg VARCHAR2(255);

        l_serial_code NUMBER;
        l_lot_code NUMBER;
        wdrData wdr_row;
        l_device_id NUMBER;
        l_qty NUMBER;
        l_count NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    error_code := 'INS_WCT_ROWS_TO_MMTT';
    if (g_trace_on = 1) then log_event(' Entered insert wct rows to mmtt'||p_m_o_h_id); END IF;
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    IF( p_outbound IS NOT NULL AND p_outbound = 'N') THEN
       if (g_trace_on = 1) then log_event(' open bpack_rows'); END IF;
       OPEN bpack_rows;
     ELSE
       IF G_CURRENT_RELEASE_LEVEL < G_J_RELEASE_LEVEL THEN -- bulk picking patchset J ---
          if (g_trace_on = 1) then log_event(' open wct_rows'); END IF;
          OPEN wct_rows;
        ELSE
          -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING --START'); end if;
                OPEN wct_rows_bulk;
           --  if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING --END'); end if;
         END IF;
      END IF;

     LOOP

         IF( p_outbound IS NOT NULL AND p_outbound = 'N') THEN
            if (g_trace_on = 1) then log_event(' fetching  a bpack row '); END IF;
            FETCH bpack_rows INTO v2;
            EXIT WHEN bpack_rows%notfound;
            if (g_trace_on = 1) then log_event(' fetched  a row '); END IF;
          ELSE
            IF  G_CURRENT_RELEASE_LEVEL < G_J_RELEASE_LEVEL  THEN -- bulk picking patchset J ---
               if (g_trace_on = 1) then log_event(' fetching  a wct row '); END IF;
               FETCH wct_rows INTO v2;
               EXIT WHEN wct_rows%notfound;
               if (g_trace_on = 1) then log_event(' fetched  a row ');  END IF;
            ELSE
               if (g_trace_on = 1) then -- log_event('PATCHSET J-- BULK PICKING --START');
                                        log_event(' fetching  a wct row '); END IF;
                       FETCH wct_rows_bulk INTO v2;
                       EXIT WHEN wct_rows_bulk%notfound;
               if (g_trace_on = 1) then log_event(' fetched  a row ');  END IF;
              -- if (g_trace_on = 1) then log_event('PATCHSET J-- BULK PICKING --END'); end if;
            END IF;

        END IF;

        v1 := to_mmtt(v2);

         IF packaging_mode IN (wms_cartnzn_pub.int_bp_pkg_mode,
                               wms_cartnzn_pub.mob_bp_pkg_mode ) THEN

            v1.transfer_lpn_id := v1.cartonization_id;

         END IF;



      IF( v1.transaction_temp_id > 0 ) then

         --INSERT RECORDS INTO WMS_DEVICE_REQUESTS TABLE
          insert_device_request_rec(v1);
          --/////////////////

            if (g_trace_on = 1) then log_event(' temp_id > 0'); END IF;

            v_exist := 'N';

            BEGIN
               SELECT 'Y' INTO v_exist FROM dual
                 WHERE
                 exists ( SELECT transaction_temp_id FROM mtl_material_transactions_temp
                       WHERE transaction_temp_id = v1.transaction_temp_id);
            EXCEPTION
               WHEN no_data_found THEN
                  v_exist := 'N';
            END;


            if (g_trace_on = 1) then log_event(' row_exist '||v_exist); END IF;

            IF v1.cartonization_id IS NOT NULL THEN
               IF (g_trace_on = 1) then log_event(' Cartonization id  '||v1.cartonization_id); END IF;
                  SELECT license_plate_number INTO v_lpn FROM wms_license_plate_numbers WHERE
                  lpn_id = v1.cartonization_id;
               ELSE
                  v_lpn := NULL;
                  --2513907 fix
               IF v1.container_item_id IS NULL THEN
                  v1.container_item_id := -1;
               END IF;
              --2513907 fix
            END IF;

            if (g_trace_on = 1) then log_event(' After the cartonization id condition '); END IF;

            table_name := 'mtl_material_transactions_temp';


            IF v_exist = 'Y' THEN

               if (g_trace_on = 1) then
                  log_event('calling update mmtt for  tempid:'||v1.transaction_temp_id);
                  log_event(' primary quantity:'||v1.primary_quantity);
                  log_event(' transaction_quantity:'|| v1.transaction_quantity);
                  log_event(' secondary transaction_quantity:'|| v1.secondary_transaction_quantity); --invconv kkillams
               END IF;

               UPDATE_MMTT(
                            p_transaction_temp_id =>  v1.transaction_temp_id,
                            p_primary_quantity    =>  v1.primary_quantity,
                            p_transaction_quantity => v1.transaction_quantity,
                            p_secondary_quantity   => v1.secondary_transaction_quantity, --invconv kkillams
                            --p_LPN_string           => v_lpn,
                            p_lpn_id               => v1.cartonization_id,
                            p_container_item_id    => v1.container_item_id,
                            p_parent_line_id       => v1.parent_line_id,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data );

             ELSIF v_EXIST = 'N' THEN

               if (g_trace_on = 1) then log_event(' inserting row into mmtt for temp id :'||v1.transaction_temp_id); END IF;
               wms_task_dispatch_engine.insert_mmtt(l_mmtt_rec => v1);
             ELSE
               RAISE fnd_api.g_exc_unexpected_error;

            END IF;
         END IF;

      END LOOP;

      IF( p_outbound IS NOT NULL AND p_outbound = 'N') THEN
         IF( bpack_rows%isopen) then
            close bpack_rows;
         END IF;

       ELSE

         IF( wct_rows%isopen ) then
            close wct_rows;
         END IF;

      END IF;



   EXCEPTION
    WHEN OTHERS THEN
       IF( wct_rows%isopen ) then
          CLOSE wct_rows;
       END IF;
       --l_msg := Sqlerrm;
       if (g_trace_on = 1) then log_event('SQL Error Message ' || SQLERRM); END IF;
       if (g_trace_on = 1) then log_event('SQL Error Code ' || SQLCODE); END IF;
       if (g_trace_on = 1) then log_event('error OCCURRED IN INSERTING WCT ROWS BACK TO MMTT'); END IF;
       RAISE fnd_api.g_exc_unexpected_error;


 END ins_wct_rows_into_mmtt;

 FUNCTION get_log_flag RETURN VARCHAR2 IS

    log_flag VARCHAR2(1) := 'Y';
    --Bug 3319754 changes. Also made change so that get_log_flag
    --returns 'Y' irrespective of level
    g_trace_on number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    --l_dbg_lvl  NUMBER := 0;

    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    error_code := 'GET_LOG_FLAG';

--    select fnd_profile.value('INV_DEBUG_TRACE')
--      into g_trace_on
--      from dual;

--    if( g_trace_on = 1 ) then
--       select fnd_profile.value('INV_DEBUG_LEVEL')
--       into l_dbg_lvl
--       from dual;
--    END IF;

    if(g_trace_on = 1) THEN --AND l_dbg_lvl > 5 then
       log_flag := 'Y';
     ELSE
       log_flag := 'N';
    END IF;

    RETURN log_flag;


 EXCEPTION
   when others then
      null;
 END get_log_flag;

   PROCEDURE cartonize_single_item (
                        x_return_status         OUT   NOCOPY VARCHAR2,
                        x_msg_count             OUT   NOCOPY NUMBER,
                        x_msg_data              OUT   NOCOPY VARCHAR2,
                        p_out_bound             IN    VARCHAR2,
                        p_org_id                IN    NUMBER,
                        p_move_order_header_id  IN    NUMBER,
                        p_subinventory_name     IN    VARCHAR2 DEFAULT NULL
   )
   IS
      l_api_name     CONSTANT VARCHAR2(30) := 'cartonize_single_item';
      l_api_version  CONSTANT NUMBER       := 1.0;
      v1 WCT_ROW_TYPE;
      cartonization_profile  VARCHAR2(1)   := 'Y';
      v_cart_value NUMBER;
      v_container_item_id NUMBER:= NULL;
      v_qty NUMBER:= -1;
      v_qty_per_cont NUMBER := -1;
      v_tr_qty_per_cont NUMBER:= -1;
      v_sec_tr_qty_per_cont NUMBER:= -1;
      v_lpn_out VARCHAR2(30) := ' ';
      v_primary_uom_code VARCHAR2(3);
      v_loop NUMBER := 0;
      v_process_id NUMBER := 0;
      v_ttemp_id NUMBER := 0;
      v_lpn_id_out NUMBER := 0;
      v_lpn_id NUMBER := 0;
      ret_value   NUMBER := 29;
      v_return_status VARCHAR2(1);
      v_left_prim_quant NUMBER;
      v_left_tr_quant NUMBER;
      v_sec_left_tr_quant NUMBER;
      v_sublvlctrl VARCHAR2(1) := '2';
      --Bug 2720653 fix
      --l_lpn_id_tbl inv_label.transaction_id_rec_type;
      l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(400);
      l_progress VARCHAR2(10);
      l_label_status VARCHAR2(500);
      l_counter NUMBER := 0;
      v_prev_move_order_line_id NUMBER := -999;
      space_avail_for NUMBER := 0;
      tr_space_avail_for NUMBER := 0;
      sec_tr_space_avail_for NUMBER := 0; --invconv kkillams
      curr_temp_id mtl_material_transactions_temp.transaction_temp_id%TYPE ;
      v_lot_control_code NUMBER := NULL;
      v_serial_control_code NUMBER := NULL;
      api_table_index NUMBER := 0;
      l_current_header_id  NUMBER := NULL;
      l_stop_level    NUMBER := -1;
      v_prev_item_id  NUMBER := -999;
      l_prev_package_id NUMBER := NULL;
      l_temp_id       NUMBER := NULL;
      l_item_id       NUMBER := NULL;
      l_qty           NUMBER := NULL;
      l_tr_qty        NUMBER := NULL;
      l_sec_tr_qty    NUMBER := NULL;
      l_clpn_id       NUMBER := NULL;
      l_citem_id      NUMBER := NULL;
      l_package_id      NUMBER := NULL;
      l_upd_qty_flag VARCHAR2(1) := NULL;
      l_prev_header_id NUMBER := NULL;
      l_header_id     NUMBER := NULL;
      L_no_pkgs_gen   VARCHAR2(1);
      l_prev_condition  VARCHAR2(1);
      l_revision_code   VARCHAR2(1);
      l_lot_code        VARCHAR2(1);
      l_serial_code     VARCHAR2(1);
      l_is_revision_control  BOOLEAN;
      l_is_lot_control       BOOLEAN;
      l_is_serial_control    BOOLEAN;
      l_rqoh NUMBER;
      l_qr   NUMBER;
      l_qs   NUMBER;
      l_atr  NUMBER;
      l_att  NUMBER;
      l_qoh  NUMBER;
      l_lpn_fully_allocated  VARCHAR2(1) :='N';
      percent_fill_basis         VARCHAR2(1) :='W';
      l_valid_container VARCHAR2(1) := 'Y';

      l_cartonize_sales_orders VARCHAR2(1) :=NULL;
      l_cartonize_manufacturing VARCHAR2(1) :=NULL;
      l_move_order_type   NUMBER;
      l_pack_level  number := 0;

      l_uom_rate number;

      CURSOR wct_rows IS
      SELECT wct.* FROM wms_cartonization_temp wct,
      mtl_txn_request_lines mtrl,
      mtl_secondary_inventories sub,
      mtl_parameters mtlp
      WHERE
      wct.move_order_line_id =mtrl.line_id
      AND mtrl.header_id = p_move_order_header_id
      AND wct.cartonization_id IS null
      AND mtlp.organization_id = wct.organization_id
      AND sub.organization_id = wct.organization_id
      AND wct.transfer_lpn_id IS NULL
      AND sub.secondary_inventory_name = wct.subinventory_code
      AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
	  OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
	  OR (NVL(mtlp.cartonization_flag,-1) = 4)
	  OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
	  )
      ORDER BY wct.inventory_item_id,
      wct.move_order_line_id,
          Abs(wct.transaction_temp_id);

      CURSOR wct_sub_rows IS
      SELECT wct.* FROM wms_cartonization_temp wct,
      mtl_txn_request_lines mtrl,
      mtl_secondary_inventories sub,
      mtl_parameters mtlp
      WHERE
      wct.move_order_line_id =mtrl.line_id
      AND mtrl.header_id = p_move_order_header_id
      AND wct.cartonization_id IS null
      AND mtlp.organization_id = wct.organization_id
      AND sub.organization_id = wct.organization_id
      AND wct.transfer_lpn_id IS NULL
      AND sub.secondary_inventory_name = wct.subinventory_code
      AND wct.subinventory_code = p_subinventory_name
      AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
	  OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
	  OR (NVL(mtlp.cartonization_flag,-1) = 4)
	  OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
	  )
      ORDER BY wct.inventory_item_id,
      wct.move_order_line_id,
          Abs(wct.transaction_temp_id);

      CURSOR OB_LBPRT IS
      SELECT DISTINCT mmtt.cartonization_id FROM
      --2513907 fix
      wms_cartonization_temp mmtt,
      --mtl_material_transactions_temp mmtt,
      mtl_txn_request_lines mtrl WHERE
      mmtt.move_order_line_id = mtrl.line_id
      AND mtrl.header_id      = p_move_order_header_id
      AND mmtt.cartonization_id IS NOT NULL
      ORDER BY mmtt.cartonization_id;

      CURSOR bpack_rows(p_hdr_id NUMBER) IS
      SELECT * FROM
      wms_cartonization_temp
      WHERE
      transaction_header_id = p_hdr_id
      AND cartonization_id IS NULL
      AND transfer_lpn_id IS NULL
      order by  move_order_line_id,
      decode(content_lpn_id,null,inventory_item_id,
      decode(sign(p_hdr_id),
      -1,
      inventory_item_id,
      wms_cartnzn_pub.Get_LPN_ItemId(content_lpn_id)
      ) ),Abs(transaction_temp_id);

      CURSOR packages(p_hdr_id NUMBER) IS
      SELECT
      transaction_temp_id,
      inventory_item_id,
      primary_quantity,
      transaction_quantity,
      secondary_transaction_quantity, --invconv kkillams
      content_lpn_id,
      container_item_id,
      cartonization_id
      FROM
      wms_cartonization_temp
      WHERE
      transaction_header_id = p_hdr_id
      order by cartonization_id;

      CURSOR opackages(p_hdr_id NUMBER) IS
      SELECT
      wct.transaction_temp_id,
      wct.inventory_item_id,
      wct.primary_quantity,
      wct.transaction_quantity,
      wct.secondary_transaction_quantity, --invconv kkillams
      wct.content_lpn_id,
      wct.container_item_id,
      wct.cartonization_id
      FROM
      wms_cartonization_temp wct,
      mtl_txn_request_lines mtrl
      WHERE
      wct.move_order_line_id = mtrl.line_id AND
      mtrl.header_id = p_hdr_id
      order by wct.cartonization_id;



   BEGIN

      IF (g_trace_on = 1) THEN
         log_event(' Inside CARTONIZE_SINGLE_ITEM()');
      END IF;

      outbound := 'Y';
      error_code := 'CARTONIZE 100';

      IF (g_trace_on = 1) THEN
         log_event(' outbound = '|| outbound || ' pack level ' || pack_level);
         log_event(' restrcited subinventory = '|| p_subinventory_name);
      END IF;

      IF p_subinventory_name IS NOT NULL THEN
         IF (g_trace_on = 1) THEN
            log_event(' Opening cursor wct_sub_row ');
         END IF;
         OPEN wct_sub_rows;
      ELSE
         IF (g_trace_on = 1) THEN
            log_event(' Opening cursor wct_row ');
         END IF;
         OPEN wct_rows;
      END IF;

--      OPEN wct_rows;

      LOOP
         IF( (outbound = 'Y') AND (pack_level = 0)) THEN

            IF p_subinventory_name IS NOT NULL THEN
               FETCH wct_sub_rows INTO v1;
               IF (g_trace_on = 1) THEN
                  log_event('wct_sub_rows Fetch success');
               END IF;
               EXIT WHEN wct_sub_rows%NOTFOUND;
            ELSE
               FETCH wct_rows INTO v1;
               IF (g_trace_on = 1) THEN
                  log_event('wct_rows Fetch success');
               END IF;
               EXIT WHEN wct_rows%NOTFOUND;
            END IF;

            IF NOT INV_CACHE.set_item_rec(v1.organization_id, v1.inventory_item_id) THEN
               IF (g_trace_on = 1) THEN
                  log_event('Inventory Cache Set Item Rec Failed');
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_revision_code := inv_cache.item_rec.revision_qty_control_code;
            l_lot_code := inv_cache.item_rec.lot_control_code;
            l_serial_code := inv_cache.item_rec.serial_number_control_code;

            IF (g_trace_on = 1) THEN
               log_event('revision code : '|| l_revision_code);
               log_event('lot code : '|| l_lot_code);
               log_event('serial code : '|| l_serial_code);
            END IF;

            IF l_revision_code> 1 THEN
               l_is_revision_control := TRUE;
            ELSE
               l_is_revision_control := FALSE;
            END IF;

            IF l_lot_code > 1 THEN
               l_is_lot_control := TRUE;
            ELSE
               l_is_lot_control := FALSE;
            END IF;

            IF (l_serial_code>1 AND l_serial_code<>6) THEN
               l_is_serial_control := TRUE;
            ELSE
               l_is_serial_control := FALSE;
            END IF;

            IF (v1.allocated_lpn_id IS NOT NULL ) THEN
               -- Bug 3740610 No need to call qty tree,getting on-hand qty from table
               SELECT NVL(SUM(primary_transaction_quantity),0)
               into l_qoh FROM mtl_onhand_quantities_detail
               WHERE organization_id = v1.organization_id
               AND subinventory_code = v1.subinventory_code
               AND locator_id = v1.locator_id
               AND lpn_id = v1.allocated_lpn_id;

               IF (g_trace_on = 1) THEN log_event('lpn_id' || v1.allocated_lpn_id);
                  log_event('l_qoh' || l_qoh);
                  log_event('PrimaryQty'|| v1.primary_quantity);
               END IF;

               --Bug 3740610 Comparing on-hand qty with primary_qty of mmtt

               IF (l_qoh = v1.primary_quantity) THEN
                  l_lpn_fully_allocated := 'Y';
                  t_lpn_alloc_flag_table(v1.transaction_temp_id).transaction_temp_id := v1.transaction_temp_id;
                  t_lpn_alloc_flag_table(v1.transaction_temp_id).lpn_alloc_flag := 'Y';

               ELSE
                  l_lpn_fully_allocated := 'N';
                  t_lpn_alloc_flag_table(v1.transaction_temp_id).transaction_temp_id := v1.transaction_temp_id;
                  t_lpn_alloc_flag_table(v1.transaction_temp_id).lpn_alloc_flag := 'N';

               END IF;
            ELSE
               l_lpn_fully_allocated := 'Y';
               t_lpn_alloc_flag_table(v1.transaction_temp_id).transaction_temp_id := v1.transaction_temp_id;
               t_lpn_alloc_flag_table(v1.transaction_temp_id).lpn_alloc_flag := 'Y';

            END IF ;

         END IF;

         IF (g_trace_on = 1) THEN
            log_event(' Fetch succeeded');
            log_event('lpn_fully_allocated:'||l_lpn_fully_allocated);
            log_event('lpn_id after if:'||v1.allocated_lpn_id);
         END IF;

         IF (v1.allocated_lpn_id IS NOT NULL)
         AND (l_lpn_fully_allocated = 'Y') THEN
            null;
         ELSE
            IF (g_trace_on = 1) THEN
               log_event('v1.transaction_temp_id : ' || v1.transaction_temp_id);
            END IF;

            --populate lpn_alloc_flag with null for loose item
            t_lpn_alloc_flag_table(v1.transaction_temp_id).transaction_temp_id := v1.transaction_temp_id;
            t_lpn_alloc_flag_table(v1.transaction_temp_id).lpn_alloc_flag := NULL;

--            SELECT v1.transaction_temp_id, null
--            INTO  t_lpn_alloc_flag_table(v1.transaction_temp_id)
--            FROM dual;

            -- If the content_lpn_id is populated on the mmtt record
            -- could be two cases. Either we are trying to pack an LPN
            -- or a package. We will have packages poulated in this
            -- column only by multi level cartonization and when it
            -- does that, the row is inserted with negative header id
            -- Basing on this we either get the item associated with
            -- the lpn, or item associated with the package

            IF ( v1.content_lpn_id IS NOT NULL ) THEN
               IF (g_trace_on = 1) THEN log_event(' content_lpn_id IS NOT NULL'); END IF;
                  IF v1.transaction_header_id  < 0 THEN
                     error_code := 'CARTONIZE 150';
                     --THe content_lpn_id has a package in it ..
                     --v1.inventory_item_id := Get_package_ItemId(v1.content_lpn_id);
                  ELSE
                     error_code := 'CARTONIZE 160';
                     --THe content_lpn_id has a LPN in it ..
                     v1.inventory_item_id := Get_LPN_ItemId(v1.content_lpn_id);
                  END IF;
                  -- When we are packaing an lpn or a package the qty is
                  -- always 1
                  v1.primary_quantity := 1;
                  v1.transaction_quantity := 1;
                END IF;

               error_code := 'CARTONIZE 170';

               v_primary_uom_code := inv_cache.item_rec.primary_uom_code;

               IF ( v1.content_lpn_id IS NOT NULL ) THEN
                  -- We want to set the transaction uom same as primary uom
                  v1.transaction_uom := v_primary_uom_code;
               END IF;

               IF (g_trace_on = 1) THEN
                  log_event(' inventory_item_id:'||v1.inventory_item_id);
                  log_event(' primary_quantity:'||v1.primary_quantity);
                  log_event(' primary_uom_code:'||v_primary_uom_code);
                  log_event(' transaction_quantity:'||v1.transaction_quantity);
                  log_event(' transaction_uom:'||v1.transaction_uom);
                  log_event(' secondary_transaction_quantity:'||v1.secondary_transaction_quantity); --invconv kkillams
                  log_event(' secondary_uom_code:'||v1.secondary_uom_code); --invconv kkillams
               END IF;

               IF (outbound = 'Y')
               AND (pack_level = 0)
               AND (v1.inventory_item_id <> v_prev_item_id) THEN
                  l_prev_condition := 'Y';
               ELSIF (outbound = 'Y')
               AND (pack_level <> 0)
               AND ((v_prev_move_order_line_id  <> v1.move_order_line_id)
               OR (v1.inventory_item_id <> v_prev_item_id) ) THEN
                  l_prev_condition := 'Y';
               ELSIF (outbound = 'N') AND ( v1.inventory_item_id <> v_prev_item_id) THEN
                  l_prev_condition := 'Y';
               ELSE
                  l_prev_condition := 'N';
               END IF;

               IF (g_trace_on = 1) then log_event(' l_prev_condition '||l_prev_condition);  END IF;
               -- The below condition is used when to make a
               -- call to the an api that returns conatiner item relation
               -- ship if present
               -- In outbound mode
               --  you have to call this when previous move order line id
               --  is different from the current one
               -- In the inbound mode
               --  We need to call if the previous item is different form
               -- the current item

               IF l_prev_condition = 'Y' THEN
                  IF (g_trace_on = 1) then log_event(' call wms_container_pub.container_required_qty api for item id '||v1.inventory_item_id);  END IF;

                  v_prev_item_id := v1.inventory_item_id;
                  v_prev_move_order_line_id := v1.move_order_line_id;
                  v_container_item_id := NULL;
                  v_qty_per_cont := -1;
                  v_qty := -1;
                  space_avail_for := 0;
                  --Bug 2478970 fix
                  l_valid_container := 'Y';

                  IF (outbound = 'Y') AND (pack_level = 0)
                  AND (packaging_mode = wms_cartnzn_pub.pr_pkg_mode) THEN
                     error_code := 'CARTONIZE 180';
                     wsh_interface.Get_Max_Load_Qty(p_move_order_line_id => v1.move_order_line_id,
                                                  x_max_load_quantity  => v_qty_per_cont,
                                                  x_container_item_id  => v_container_item_id,
                                                  x_return_status     => v_return_status);

                   l_valid_container := 'Y'; --Undoing 2478970 fix

                   IF(  (v_return_status = fnd_api.g_ret_sts_success) AND
                        (v_qty_per_cont > 0) AND
                        (v_container_item_id IS NOT NULL) AND
                        (v_container_item_id > 0) ) THEN

                      v_qty := ceil(v1.primary_quantity/v_qty_per_cont);
                      -- This quantity needs to be recalculated. This is
                      -- poulated to pass the check marked by '#chk1'
                   END IF;

                   IF (g_trace_on = 1) THEN
                      log_event('wsh_interface.Get_Max_Load_Qty return status'||v_return_status);
                      log_event('container '||v_container_item_id);
                      log_event('Number of dum containers '||v_qty);
                   END IF;

                   v_prev_move_order_line_id := v1.move_order_line_id;

               ELSE
                  error_code := 'CARTONIZE 190';
                  wms_container_pub.Container_Required_Qty
                  (  p_api_version       => 1.0,
                     x_return_status     => v_return_status,
                     x_msg_count         => l_msg_count,
                     x_msg_data          => l_msg_data,
                     p_source_item_id    => v1.inventory_item_id,
                     p_source_qty        => v1.primary_quantity,
                     p_source_qty_uom    => v_primary_uom_code,
                     p_organization_id   => v1.organization_id,
                     p_dest_cont_item_id => v_container_item_id,
                     p_qty_required       => v_qty
                     );

                  IF (g_trace_on = 1) THEN
                     log_event('container_required_quantity return status'||v_return_status);
                     log_event('container '||v_container_item_id);
                     log_event('Number of conatiners '||v_qty);
                  END IF;

                  v_prev_item_id := v1.inventory_item_id;

                  IF( (v_return_status = fnd_api.g_ret_sts_success )   AND
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

               END IF;

               IF (g_trace_on = 1) THEN
                  log_event('qty per container is '||v_qty_per_cont);
               END IF;
                --#chk1

               IF( (v_return_status <> fnd_api.g_ret_sts_success ) OR
                   (v_qty_per_cont IS NULL) OR
                   (v_qty IS NULL) OR
                   (v_container_item_id IS NULL) OR
                   (v_qty <= 0) OR
                   (v_container_item_id <= 0) OR
                   (v_qty_per_cont <= 0) OR
                   --Bug 2478970 fix
                   l_valid_container = 'N'
                  ) THEN

                  IF (g_trace_on = 1) THEN
                     log_event('improper values returned by container_required_qty ');
                  END IF;
               ELSE
                  v_serial_control_code := inv_cache.item_rec.serial_number_control_code;

                  IF( (v_serial_control_code NOT IN (1,6) )
                  AND (Ceil(v_qty_per_cont) > v_qty_per_cont )) THEN
                     IF (g_trace_on = 1) THEN
                        log_event('cannot split serial controlled items to  fractions');
                        log_event('Please check the container item relationships');
                     END IF;

                     v_qty_per_cont := 0;
                     v_serial_control_code := NULL;
                  END IF;

                  v_serial_control_code := NULL;

                  v_tr_qty_per_cont := ROUND((v_qty_per_cont * inv_convert.inv_um_convert(
                                                                  p_item_id       => v1.inventory_item_id,
                                                                  p_from_uom_code => v_primary_uom_code,
                                                                  p_to_uom_code   => v1.transaction_uom
                                                                  )),
                                                                  5);

                     --invconv kkillams
                  IF v1.secondary_uom_code IS NOT NULL THEN

                     v_sec_tr_qty_per_cont := ROUND((v_qty_per_cont * inv_convert.inv_um_convert(
                                                                     p_item_id       => v1.inventory_item_id,
                                                                     p_from_uom_code => v_primary_uom_code,
                                                                     p_to_uom_code   => v1.secondary_uom_code
                                                                     )),
                                                                     5);

                  END IF;

                  if (g_trace_on = 1) then log_event(' Transaction qty per conatiner is '||v_tr_qty_per_cont); END IF;
                  if (g_trace_on = 1) then log_event(' Secondary Transaction qty per conatiner is '||v_sec_tr_qty_per_cont); END IF;
               END IF;
            ELSE
               IF (space_avail_for > 0) THEN
                  if (g_trace_on = 1) then log_event(' Space available for '||space_avail_for); END IF;
                  IF (v1.primary_quantity <= space_avail_for) THEN
                     if (g_trace_on = 1) then log_event(' Prim qty '||v1.primary_quantity|| ' <= '||space_avail_for); END IF;
                     space_avail_for := space_avail_for -  v1.primary_quantity;

                     IF( v1.content_lpn_id IS NULL) THEN
                        l_upd_qty_flag := 'Y';
                     ELSE
                        l_upd_qty_flag := 'N';
                     END IF;
                     update_mmtt
                     (p_transaction_temp_id => v1.transaction_temp_id,
                     p_primary_quantity   => v1.primary_quantity,
                     p_transaction_quantity  => v1.transaction_quantity,
                     p_secondary_quantity    => v1.secondary_transaction_quantity, --invconv kkillams
                     --p_LPN_string            => v_lpn_out,
                     p_lpn_id                => v_lpn_id,
                     p_container_item_id     => v_container_item_id,
                     p_parent_line_id        => NULL,
                     p_upd_qty_flag          => l_upd_qty_flag,
                     x_return_status             => l_return_status,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data
                     );

                     v1.primary_quantity := 0;
                  ELSE
                     if (g_trace_on = 1) then log_event(' Prim qty '||v1.primary_quantity|| ' > '||space_avail_for); END IF;

                     tr_space_avail_for := ROUND((space_avail_for * inv_convert.inv_um_convert(
                                                                  p_item_id       => v1.inventory_item_id,
                                                                  p_from_uom_code => v_primary_uom_code,
                                                                  p_to_uom_code   => v1.transaction_uom
                                                                  )),
                                                                  5);

                     sec_tr_space_avail_for := NULL;

                     IF v1.secondary_uom_code IS NOT NULL THEN

                        sec_tr_space_avail_for := ROUND((space_avail_for * inv_convert.inv_um_convert(
                                                                     p_item_id       => v1.inventory_item_id,
                                                                     p_from_uom_code => v_primary_uom_code,
                                                                     p_to_uom_code   => v1.secondary_uom_code
                                                                     )),
                                                                     5);

                     END IF;
                     if (g_trace_on = 1) then log_event(' Tr space avail for '||tr_space_avail_for); END IF;

                     insert_mmtt
                     (p_transaction_temp_id   => v1.transaction_temp_id,
                     p_primary_quantity      => space_avail_for,
                     p_transaction_quantity  => tr_space_avail_for,
                     p_secondary_quantity    => sec_tr_space_avail_for, --invconv kkillams
                     --p_LPN_string            => v_lpn_out,
                     p_lpn_id                => v_lpn_id,
                     p_container_item_id     => v_container_item_id,
                     x_return_status      =>     l_return_status,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data
                     );

                     v1.primary_quantity := v1.primary_quantity -  space_avail_for;

                     v1.transaction_quantity := ROUND((v1.primary_quantity * inv_convert.inv_um_convert(
                                                                  p_item_id       => v1.inventory_item_id,
                                                                  p_from_uom_code => v_primary_uom_code,
                                                                  p_to_uom_code   => v1.transaction_uom
                                                                  )),
                                                                  5);

                     IF v1.secondary_uom_code IS NOT NULL THEN

                        v1.secondary_transaction_quantity := ROUND((v1.primary_quantity * inv_convert.inv_um_convert(
                                                                     p_item_id       => v1.inventory_item_id,
                                                                     p_from_uom_code => v_primary_uom_code,
                                                                     p_to_uom_code   => v1.secondary_uom_code
                                                                     )),
                                                                     5);

                     END IF;

                     space_avail_for := 0;

                     IF (g_trace_on = 1) THEN
                        log_event('Prim qty '||v1.primary_quantity);
                        log_event('Tr qty   '||v1.transaction_quantity);
                        log_event('Sec Tr qty   '||v1.secondary_transaction_quantity); --invconv kkillams
                        log_event('Space Avail for '||space_avail_for);
                     END IF;
                  END IF;
               END IF;
            END IF;

            -- Condition #
            IF (v_return_status <> FND_API.g_ret_sts_success OR
               v_qty_per_cont IS NULL                       OR
               v_qty_per_cont <= 0                          OR
               v_container_item_id IS NULL                  OR
               v_tr_qty_per_cont  IS NULL                   OR
               v_tr_qty_per_cont <= 0                       OR
               v1.primary_quantity <= 0 ) THEN

               if (g_trace_on = 1) then log_event(' Container_Required_Qty - inc values');  END IF;
                   -- Condition #3a
               NULL;
            ELSE
               -- Condition #3b
               IF( v1.content_lpn_id IS NULL) THEN
                  l_upd_qty_flag := 'Y';
               ELSE
                  l_upd_qty_flag := 'N';
               END IF;

               v_qty := ceil( v1.primary_quantity/v_qty_per_cont);

               IF( MOD(v1.primary_quantity,v_qty_per_cont) = 0 ) THEN
                  space_avail_for := 0;
               ELSE
                  space_avail_for :=  v_qty_per_cont -  MOD(v1.primary_quantity,v_qty_per_cont);
               END IF;

               IF (g_trace_on = 1) THEN log_event('space avail for '||space_avail_for); END IF;
               /* Condition #4 */
                  IF(  (v1.primary_quantity <= v_qty_per_cont) OR ( v_qty = 1) ) THEN
                     IF (g_trace_on = 1) THEN log_event(' primary_quantity <= qty per conatiner or'||' NUMBER OF cont = 1'); END IF;
                     v_lpn_id := get_next_package_id;
                     IF (g_trace_on = 1) THEN
                        log_event(' Generated label Id '||v_lpn_id);
                     END IF;

                     update_mmtt
                     (        p_transaction_temp_id => v1.transaction_temp_id,
                              p_primary_quantity   => v1.primary_quantity,
                              p_transaction_quantity  => v1.transaction_quantity,
                              p_secondary_quantity    => v1.secondary_transaction_quantity, --invconv kkillams
                              --p_LPN_string            => v_lpn_out,
                              p_lpn_id                => v_lpn_id,
                              p_container_item_id     => v_container_item_id,
                              p_parent_line_id       => NULL,
                              p_upd_qty_flag         => l_upd_qty_flag ,
                              x_return_status              => l_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data );
                  ELSE
                  /* Condition #4b */

                  v_loop := v_qty;
                  IF (g_trace_on = 1) THEN log_event(' NUMBER OF cont:'||v_qty); END IF;
                  --Bug2422193 fix moved this update to above as package
                  --ids need TO be generated IN the ORDER IN which rows
                  --are considered for cartonization
                  v_lpn_id := get_next_package_id;
                  IF (g_trace_on = 1) THEN
                     log_event('Generated label Id '||v_lpn_id);
                     log_event('calling update_mmtt');
                  END IF;

                  update_mmtt
                    (        p_transaction_temp_id => v1.transaction_temp_id,
                             p_primary_quantity   => v_qty_per_cont,
                             p_transaction_quantity  => v_tr_qty_per_cont,
                             p_secondary_quantity    => v_sec_tr_qty_per_cont, --invconv kkillams
                             --p_LPN_string            => v_lpn_out,
                             p_lpn_id                => v_lpn_id,
                             p_container_item_id     => v_container_item_id,
                             p_parent_line_id       => NULL,
                             p_upd_qty_flag         => l_upd_qty_flag,
                             x_return_status       => l_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data );

                  v_loop := v_loop - 1;

                  -- Bug 2422193 fix

                  LOOP
                  EXIT WHEN v_loop < 2;
                     v_lpn_id := get_next_package_id;
                     IF (g_trace_on = 1) THEN
                        log_event(' Generated label Id '||v_lpn_id);
                        log_event(' calling insert mmtt');
                     END IF;
                     insert_mmtt
                       (        p_transaction_temp_id => v1.transaction_temp_id,
                                p_primary_quantity   => v_qty_per_cont,
                                p_transaction_quantity  => v_tr_qty_per_cont,
                                p_secondary_quantity    => v_sec_tr_qty_per_cont, --invconv kkillams
                                --p_LPN_string            => v_lpn_out,
                                p_lpn_id                => v_lpn_id,
                                p_container_item_id     => v_container_item_id,
                                x_return_status            => l_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data );

                     IF (g_trace_on = 1) THEN
                        log_event(' called insert mmtt');
                     END IF;
                     v_loop := v_loop - 1;
                  END LOOP;

                  v_lpn_id := get_next_package_id;
                  IF (g_trace_on = 1) THEN
                     log_event(' Generated label Id '||v_lpn_id);
                  END IF;

                  v_left_prim_quant :=  MOD(v1.primary_quantity,v_qty_per_cont);
                  v_left_tr_quant :=  MOD(v1.transaction_quantity,v_tr_qty_per_cont);

                  IF v1.secondary_uom_code IS NOT NULL THEN --invconv kkillams
                     v_sec_left_tr_quant :=  MOD(v1.secondary_transaction_quantity,v_sec_tr_qty_per_cont);
                  END IF;

                  IF(  v_left_prim_quant = 0 OR  v_left_tr_quant =0) THEN
                     v_left_prim_quant := v_qty_per_cont;
                     v_left_tr_quant   := v_tr_qty_per_cont;
                     IF v1.secondary_uom_code IS NOT NULL THEN --invconv kkillams
                        v_sec_left_tr_quant :=  v_sec_tr_qty_per_cont;
                     END IF;
                  END IF;

                  if (g_trace_on = 1) then log_event('calling insert mmtt'); END IF;
                  insert_mmtt
                    (        p_transaction_temp_id  => v1.transaction_temp_id,
                             p_primary_quantity     => v_left_prim_quant,
                             p_transaction_quantity => v_left_tr_quant,
                             p_secondary_quantity    => v_sec_left_tr_quant, --invconv kkillams
                             --p_LPN_string           => v_lpn_out,
                             p_lpn_id                => v_lpn_id,
                             p_container_item_id    => v_container_item_id,
                             x_return_status       => l_return_status,
                             x_msg_count            => x_msg_count,
                             x_msg_data             => x_msg_data
                             );

                  NULL;
                     -- Shipping API
               END IF;
                  -- Close Condition #4
            END IF;
               -- Close Condition #3
         END IF;
            -- for v1.allocated_lpn_id is not null
      END LOOP;

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;

      IF wct_sub_rows%isopen THEN
         CLOSE wct_sub_rows;
      END IF;

      IF (g_trace_on = 1) THEN
         log_event('out of the loops :)');
      END IF;

   x_return_status :=  fnd_api.g_ret_sts_success;
   EXCEPTION
   WHEN OTHERS THEN
      log_event('SQLERRM : '|| SQLERRM);
      log_event('SQLCODE : '|| SQLCODE);
   END cartonize_single_item;

   PROCEDURE rulebased_cartonization
   (
      x_return_status         OUT   NOCOPY VARCHAR2,
      x_msg_count             OUT   NOCOPY NUMBER,
      x_msg_data              OUT   NOCOPY VARCHAR2,
      p_out_bound             IN    VARCHAR2,
      p_org_id                IN    NUMBER,
      p_move_order_header_id  IN    NUMBER,
      p_input_for_bulk        IN    WMS_BULK_PICK.bulk_input_rec  DEFAULT NULL
   )
   IS
      v_cartonization_value     NUMBER;
      l_cartonize_sales_orders  VARCHAR2(1) :=NULL;
      l_cartonize_manufacturing VARCHAR2(1) :=NULL;
      l_auto_pick_confirm_flag  VARCHAR2(1) := 'N';
      l_return_status           VARCHAR2(1) := 'E';
      l_msg_count               NUMBER;
      l_move_order_type         NUMBER;
      l_msg_data                VARCHAR2(2000);
      wct_row                   WCT_ROW_TYPE;
      l_api_return_status       VARCHAR2(1);
      l_count1                  NUMBER;
      l_label_status            VARCHAR2(500);
      l_header_id               NUMBER;
      L_PREV_PACKAGE_ID  number;
      L_PREV_HEADER_ID  number;
      L_CURRENT_HEADER_ID number   :=  p_move_order_header_id;
       l_qty           NUMBER := NULL;
      l_tr_qty        NUMBER := NULL;
      l_sec_tr_qty    NUMBER := NULL;
      l_clpn_id       NUMBER := NULL;
      l_citem_id      NUMBER := NULL;
      l_package_id      NUMBER := NULL;
      l_upd_qty_flag VARCHAR2(1) := NULL;
      L_no_pkgs_gen   VARCHAR2(1);
      l_temp_id number;
      l_item_id number;
      l_packaging_return_status VARCHAR2(1);

      TYPE rules_table_type IS TABLE OF wms_selection_criteria_txn%rowtype;
      rules_table rules_table_type;

      CURSOR wct_rows IS
      SELECT wct.* FROM wms_cartonization_temp wct,
      mtl_txn_request_lines mtrl,
      mtl_secondary_inventories sub,
      mtl_parameters mtlp
      WHERE
      wct.move_order_line_id =mtrl.line_id
      AND mtrl.header_id = p_move_order_header_id
      AND wct.cartonization_id IS null
      AND mtlp.organization_id = wct.organization_id
      AND sub.organization_id = wct.organization_id
      AND wct.cartonization_id IS NULL
      AND wct.transfer_lpn_id IS NULL
      AND sub.secondary_inventory_name = wct.subinventory_code
      AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
	  OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
	  OR (NVL(mtlp.cartonization_flag,-1) = 4)
	  OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
	  )
      ORDER BY wct.move_order_line_id,
      wct.subinventory_code,
      wct.inventory_item_id, Abs(wct.transaction_temp_id);

      CURSOR OB_LBPRT IS
      SELECT DISTINCT mmtt.cartonization_id FROM
      --2513907 fix
      wms_cartonization_temp mmtt,
      --mtl_material_transactions_temp mmtt,
      mtl_txn_request_lines mtrl WHERE
      mmtt.move_order_line_id = mtrl.line_id
      AND mtrl.header_id      = p_move_order_header_id
      AND mmtt.cartonization_id IS NOT NULL
      ORDER BY mmtt.cartonization_id;


      CURSOR packages(p_hdr_id NUMBER) IS
      SELECT
      transaction_temp_id,
      inventory_item_id,
      primary_quantity,
      transaction_quantity,
      secondary_transaction_quantity, --invconv kkillams
      content_lpn_id,
      container_item_id,
      cartonization_id
      FROM
      wms_cartonization_temp
      WHERE
      transaction_header_id = p_hdr_id
      order by cartonization_id;

      CURSOR opackages(p_hdr_id NUMBER) IS
      SELECT
      wct.transaction_temp_id,
      wct.inventory_item_id,
      wct.primary_quantity,
      wct.transaction_quantity,
      wct.secondary_transaction_quantity, --invconv kkillams
      wct.content_lpn_id,
      wct.container_item_id,
      wct.cartonization_id
      FROM
      wms_cartonization_temp wct,
      mtl_txn_request_lines mtrl
      WHERE
      wct.move_order_line_id = mtrl.line_id AND
      mtrl.header_id = p_hdr_id
      order by wct.cartonization_id;

      l_count number;
      l_counter number := 1;
      l_return_type_id number;

   BEGIN

      IF (g_trace_on = 1) THEN
         log_event('In RULEBASED_CARTONIZATION()');
         log_event('Populating wms_cartonization_temp from MMTT rows');
      END IF;
      g_cartonize_pick_slip := 'N';

      IF (g_trace_on = 1) THEN
         log_event('Auto Pick Confirm Flag is : '|| WMS_CARTNZN_PUB.g_auto_pick_confirm_flag);
      END IF;

      IF WMS_CARTNZN_PUB.g_auto_pick_confirm_flag = 'N' THEN

         IF (g_trace_on = 1) THEN
            log_event(' move order header id '||p_move_order_header_id);
         END IF;

         IF (g_trace_on = 1) THEN
            log_event('Calling wms_rule_pvt.assigntts for task type assignment');
         END IF;

         wms_rule_pvt.assigntts(
                          p_api_version          => 1.0
                        , p_move_order_header_id => p_move_order_header_id
                        , x_return_status        => l_return_status
                        , x_msg_count            => l_msg_count
                        , x_msg_data             => l_msg_data
                        );

         IF (g_trace_on = 1) THEN
            log_event(' Task type assignment returned with status :' ||l_return_status);
         END IF;

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            log_event(' Task type assignment failed');
         END IF;

         l_return_status := fnd_api.g_ret_sts_success;

         IF (p_move_order_header_id <> -1 ) THEN

            log_event('Calling wms_rule_pvt.assign_operation_plan for Operation Plan assignment' );

            wms_rule_pvt.assign_operation_plans(
                                             p_api_version => 1.0
                                           , p_move_order_header_id => p_move_order_header_id
                                           , x_return_status        => l_return_status
                                           , x_msg_count            => l_msg_count
                                           , x_msg_data             => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               error_code := 'CARTONIZE 45';
               -- insert the message into the stack
               log_event(' Operation plan assignment failed');
            ELSE
               log_event(' Operation plan assignment returned success');
            END IF;
         END IF;

         IF (g_trace_on = 1) THEN
            log_event('Calling INV_PICK_RELEASE_PUB.assign_pick_slip_number ');
         END IF;

         INV_PICK_RELEASE_PUB.assign_pick_slip_number(
                                                  x_return_status         => l_return_status
                                                , x_msg_count             => x_msg_count
                                                , x_msg_data              => x_msg_data
                                                , p_move_order_header_id  => p_move_order_header_id
                                                , p_ps_mode               => null
                                                , p_grouping_rule_id      => null
                                                , p_allow_partial_pick    => null
                                                );
         IF (g_trace_on = 1) THEN
            log_event('assign_pick_slip_number returns'||l_return_status);
         END IF;

      END IF; -- l_auto_pick_confirm_flag = 'N'

      IF (g_trace_on = 1) THEN
         log_event('Populating wms_cartonization_temp from MMTT rows');
      END IF;

      create_wct(
           p_move_order_header_id => p_move_order_header_id
         , p_transaction_header_id => NULL
         , p_input_for_bulk =>p_input_for_bulk
         );

      IF (g_trace_on = 1) THEN
         SELECT count(*)
         INTO l_count
         FROM wms_cartonization_temp;
         log_event('NUMBER OF ROWS INSERTED IN WCT : '|| l_count);
      END IF;

      IF (g_trace_on = 1) THEN
         log_event('Goint to cartonize');
      END IF;

      SELECT * BULK COLLECT
        INTO rules_table
        FROM wms_selection_criteria_txn
       WHERE rule_type_code = 12
         AND from_organization_id = p_org_id   -- Bug : 6962305
         AND enabled_flag = 1
       ORDER BY sequence_number;

      FOR i in rules_table.FIRST .. rules_table.LAST LOOP

         IF rules_table(i).return_type_id = 1 THEN

            cartonize_single_item
            (
               x_return_status         => l_api_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_out_bound             => 'Y',
               p_org_id                => rules_table(i).from_organization_id,
               p_move_order_header_id  => p_move_order_header_id,
               p_subinventory_name     => rules_table(i).from_subinventory_name
            );

         ELSIF rules_table(i).return_type_id = 2 THEN

            cartonize_mixed_item
            (
               x_return_status         => l_api_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_out_bound             => 'Y',
               p_org_id                => rules_table(i).from_organization_id,
               p_move_order_header_id  => p_move_order_header_id,
               p_transaction_header_id => NULL,
               p_subinventory_name     => rules_table(i).from_subinventory_name,
               p_pack_level            => 0,
               p_stop_level            => 0
            );

            pack_level := 0;

         ELSIF rules_table(i).return_type_id = 3 THEN

            g_cartonize_pick_slip := 'Y';
            cartonize_pick_slip
            (
                p_org_id                => rules_table(i).from_organization_id,
                p_move_order_header_id  => p_move_order_header_id,
                p_subinventory_name     => rules_table(i).from_subinventory_name,
                x_return_status         => l_return_status
             );

         ELSIF rules_table(i).return_type_id = 4 THEN

            cartonize_customer_logic
            (
                p_org_id                => rules_table(i).from_organization_id,
                p_move_order_header_id  => p_move_order_header_id,
                p_subinventory_name     => rules_table(i).from_subinventory_name,
                x_return_status         => l_return_status
             );

         END IF;

         -- Do not consider WCT rows used for multi-level packaging history
         SELECT count(1)
         INTO l_count
         FROM wms_cartonization_temp
         WHERE cartonization_id IS NULL
         AND transaction_header_id >= 0;

         IF l_count = 0 THEN
            EXIT;
         END IF;

      END LOOP;

      -- If there are any more rows left for cartonization for first level, cartonize through default logic
      IF l_count > 0 THEN

         cartonize_default_logic
         (
            p_org_id                => p_org_id,
            p_move_order_header_id  => p_move_order_header_id,
            p_out_bound             => 'Y',
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
         );

      END IF;

      IF (g_trace_on = 1) THEN
         log_event('Done with FIRST LEVEL OF CARTONIZATION, inserting packaging history');
      END IF;

      pack_level := 0;

      insert_ph
      (
         p_move_order_header_id  => p_move_order_header_id,
         p_current_header_id     => p_move_order_header_id,
         x_return_status         => l_packaging_return_status
      );

      IF (g_trace_on = 1) THEN
         log_event('After Insert_Ph');
      END IF;

      IF (g_trace_on = 1) THEN
         log_event('Done with FIRST LEVEL OF CARTONIZATION');
         log_event('Calling CARTONIZE_MIXED_ITEM for doing MULTI-LEVEL CARTONIZATION');
      END IF;

      cartonize_mixed_item
      (
         x_return_status         => l_api_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_out_bound             => 'Y',
         p_org_id                => p_org_id,
         p_move_order_header_id  => p_move_order_header_id,
         p_transaction_header_id => NULL,
         p_pack_level            => 1
      );

      l_header_id := p_move_order_header_id;

      IF (g_trace_on = 1) THEN
         log_event('Calling Generate_LPNs for header id ** '||l_header_id);
      END IF;

      BEGIN
          generate_lpns(p_header_id => l_header_id,
                        p_organization_id => p_org_id);
      EXCEPTION
      WHEN OTHERS THEN
         IF (g_trace_on = 1) THEN
            log_event('not erroring out since the mode is Pick release ');
         END IF;
         RAISE fnd_api.g_exc_error;
      END;

      DELETE wms_cartonization_temp
      WHERE transaction_header_id < 0;

      log_event('Out of cartonization logic going to print labels');

      IF( outbound = 'Y') THEN
         OPEN OB_LBPRT;
         LOOP
            FETCH OB_LBPRT INTO lpns_generated_tb(l_counter);
            EXIT WHEN OB_LBPRT%notfound;

            IF (g_trace_on = 1) THEN
               log_event(' print label for lpn '|| lpns_generated_tb(l_counter));
            END IF;
            l_counter := l_counter + 1;
         END LOOP;
         IF OB_LBPRT%ISOPEN THEN
            CLOSE OB_LBPRT;
         END IF;
      END IF;

      IF (g_trace_on = 1) THEN
         log_event('lpns_generated_tb.count : '|| lpns_generated_tb.count);
      END IF;

      IF (g_trace_on = 1) THEN log_event('Auto pick confirm flag : '|| l_auto_pick_confirm_flag); END IF;

      IF l_auto_pick_confirm_flag = 'Y' THEN
         if (g_trace_on = 1) then log_event('Auto pick confirm is ON - Not calling task consolidation - splitting'); END IF;
      ELSE

         IF (g_trace_on = 1)  then -- log_event('PATCHSET J-- BULK PICKING --START');
            log_event('Calling consolidate_bulk_tasks_for_so....');
            log_event('move order header id '||p_move_order_header_id);
         END IF;

         wms_task_dispatch_engine.consolidate_bulk_tasks_for_so
            (p_api_version => 1.0,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_move_order_header_id => p_move_order_header_id);

         IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
         -- we don't want to exit if there is any error here, for example data error or something
         IF (g_trace_on = 1) THEN log_event(' consolidate_bulk_tasks_for_so returns '||l_return_status); END IF;
         END IF;
         IF (g_trace_on = 1) THEN log_event(' calling ins_wct_rows_into_mmtt after consolidation'); END IF;

         ins_wct_rows_into_mmtt( p_m_o_h_id           => p_move_order_header_id,
         p_outbound           => 'Y',
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

         -- since the return value is not set up inside above procedure, so no need to check it
         -- but above procedure will throw unexpected error in case of errors, so this API will capture the
         -- error.

         IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
            --Push the message into the stack
            IF (g_trace_on = 1) THEN log_event(' consolidate_bulk_tasks returns '||l_return_status); END IF;
         END IF;

         IF (g_trace_on = 1) THEN log_event(' calling task splitting' );  END IF;

         wms_task_dispatch_engine.split_tasks
         (
            p_api_version => 1.0,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_move_order_header_id => p_move_order_header_id
         );

         IF(l_return_status <> fnd_api.g_ret_sts_success ) THEN
         --Push the message into the stack
            IF (g_trace_on = 1) THEN log_event(' split_tasks returns '||l_return_status); END IF;
         END IF;
      END IF;

      --Bug 6873966
      --moved the label printing call after stamping the cartonization_id on the mmtt
      IF (lpns_generated_tb.COUNT > 0) THEN

         IF packaging_mode = wms_cartnzn_pub.PR_pKG_mode THEN
            IF (g_trace_on = 1) THEN
               log_event('wms_cartnzn_pub before  inv_label.print_label ');
            END IF;
            l_return_status := fnd_api.g_ret_sts_success;

            inv_label.print_label
                           (
                             x_return_status => l_return_status
                           , x_msg_count => l_msg_count
                           , x_msg_data  => l_msg_data
                           , x_label_status  => l_label_status
                           , p_api_version   => 1.0
                           , p_print_mode => 1
                           , p_business_flow_code => 22
                           , p_transaction_id => lpns_generated_tb
                           );

            IF (g_trace_on = 1) THEN
               log_event('wms_cartnzn_pub after inv_label.print_label ');
            END IF;

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');  -- MSGTBD
               FND_MSG_PUB.ADD;
               IF (g_trace_on = 1) THEN
                  log_event('wms_cartnzn_pub inv_label.print_label FAILED;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'));
               END IF;
            END IF;
         END IF; -- end packaging_mode in 1
      ELSE
         IF (g_trace_on = 1) THEN
            log_event('COULD NOT CARTONIZE ANY OF THE LINES');
         END IF;
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      log_event('Exception in rulebased cartonization');
      log_event('SQL Error Message :' || SQLERRM);
      log_event('SQL Error Code :' || SQLCODE);
--         v_cart_value := NULL;
   END rulebased_cartonization;

   PROCEDURE cartonize_mixed_item (
                      x_return_status         OUT   NOCOPY VARCHAR2,
                      x_msg_count             OUT   NOCOPY NUMBER,
                      x_msg_data              OUT   NOCOPY VARCHAR2,
                      p_out_bound             IN    VARCHAR2,
                      p_org_id                IN    NUMBER,
                      p_move_order_header_id  IN    NUMBER,
                      p_transaction_header_id IN    NUMBER,
                      p_disable_cartonization IN    VARCHAR2 DEFAULT 'N',
                      p_subinventory_name     IN    VARCHAR2 DEFAULT NULL,
                      p_stop_level            IN    NUMBER DEFAULT NULL,
                      p_pack_level            IN    NUMBER
                      )
   IS
      l_api_name     CONSTANT VARCHAR2(30) := 'cartonize_mixed_item';
      l_api_version  CONSTANT NUMBER       := 1.0;
      v1 WCT_ROW_TYPE;
      cartonization_profile  VARCHAR2(1)   := 'Y';
      v_cart_value NUMBER;
      v_container_item_id NUMBER:= NULL;
      v_qty NUMBER:= -1;
      v_qty_per_cont NUMBER := -1;
      v_tr_qty_per_cont NUMBER:= -1;
      v_sec_tr_qty_per_cont NUMBER:= -1;
      v_lpn_out VARCHAR2(30) := ' ';
      v_primary_uom_code VARCHAR2(3);
      v_loop NUMBER := 0;
      v_process_id NUMBER := 0;
      v_ttemp_id NUMBER := 0;
      v_lpn_id_out NUMBER := 0;
      v_lpn_id NUMBER := 0;
      ret_value   NUMBER := 29;
      v_return_status VARCHAR2(1);
      v_left_prim_quant NUMBER;
      v_left_tr_quant NUMBER;
      v_sec_left_tr_quant NUMBER;
      v_sublvlctrl VARCHAR2(1) := g_sublvlctrl; --Bug#7168367.Get form global variable.
      l_header_id     NUMBER := NULL;
      --Bug 2720653 fix
      --l_lpn_id_tbl inv_label.transaction_id_rec_type;
      l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(400);
      l_progress VARCHAR2(10);
      l_label_status VARCHAR2(500);
      l_counter NUMBER := 0;
      v_prev_move_order_line_id NUMBER := 0;
      space_avail_for NUMBER := 0;
      tr_space_avail_for NUMBER := 0;
      sec_tr_space_avail_for NUMBER := 0; --invconv kkillams
      curr_temp_id mtl_material_transactions_temp.transaction_temp_id%TYPE ;
      v_lot_control_code NUMBER := NULL;
      v_serial_control_code NUMBER := NULL;
      api_table_index NUMBER := 0;
      l_current_header_id  NUMBER := NULL;
      l_stop_level    NUMBER := -1;
      v_prev_item_id  NUMBER := NULL;
      l_prev_package_id NUMBER := NULL;
      l_temp_id       NUMBER := NULL;
      l_item_id       NUMBER := NULL;

      l_qty           NUMBER := NULL;
      l_tr_qty        NUMBER := NULL;
      l_sec_tr_qty    NUMBER := NULL;
      l_clpn_id       NUMBER := NULL;
      l_citem_id      NUMBER := NULL;
      l_package_id      NUMBER := NULL;
      l_upd_qty_flag VARCHAR2(1) := NULL;
      l_prev_header_id NUMBER := NULL;
      L_no_pkgs_gen   VARCHAR2(1);
      l_prev_condition  VARCHAR2(1);
      l_revision_code   VARCHAR2(1);
      l_lot_code        VARCHAR2(1);
      l_serial_code     VARCHAR2(1);
      l_is_revision_control  BOOLEAN;
      l_is_lot_control       BOOLEAN;
      l_is_serial_control    BOOLEAN;
      l_rqoh NUMBER;
      l_qr   NUMBER;
      l_qs   NUMBER;
      l_atr  NUMBER;
      l_att  NUMBER;
      l_qoh  NUMBER;
      l_lpn_fully_allocated  VARCHAR2(1) :='N';
      percent_fill_basis         VARCHAR2(1) :='W';
      l_valid_container VARCHAR2(1) := 'Y';

      l_cartonize_sales_orders VARCHAR2(1)  :=NULL;
      l_cartonize_manufacturing VARCHAR2(1) :=NULL;
      l_move_order_type   NUMBER;
      l_pack_level        NUMBER := 0;

       CURSOR wct_rows IS
          SELECT wct.* FROM wms_cartonization_temp wct,
            mtl_txn_request_lines mtrl,
            mtl_secondary_inventories sub,
            mtl_parameters mtlp
            WHERE
            wct.move_order_line_id =mtrl.line_id
            AND mtrl.header_id = p_move_order_header_id
            AND wct.cartonization_id IS null
            AND mtlp.organization_id = wct.organization_id
            AND sub.organization_id = wct.organization_id
            AND wct.cartonization_id IS NULL
            AND wct.transfer_lpn_id IS NULL
            AND sub.secondary_inventory_name = wct.subinventory_code
            AND wct.subinventory_code = NVL(p_subinventory_name,wct.subinventory_code)
            AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
		OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
		OR (NVL(mtlp.cartonization_flag,-1) = 4)
		OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
		)
            ORDER BY wct.move_order_line_id,
                     wct.inventory_item_id,
                     Abs(wct.transaction_temp_id);

            CURSOR OB_LBPRT IS
               SELECT DISTINCT mmtt.cartonization_id FROM
                 --2513907 fix
               wms_cartonization_temp mmtt,
             --mtl_material_transactions_temp mmtt,
             mtl_txn_request_lines mtrl WHERE
             mmtt.move_order_line_id = mtrl.line_id
             AND mtrl.header_id      = p_move_order_header_id
             AND mmtt.cartonization_id IS NOT NULL
               ORDER BY mmtt.cartonization_id;

         CURSOR bpack_rows(p_hdr_id NUMBER) IS
            SELECT * FROM
              wms_cartonization_temp
              WHERE
              transaction_header_id = p_hdr_id
              AND cartonization_id IS NULL
              AND transfer_lpn_id IS NULL
              order by  move_order_line_id,
              decode(content_lpn_id,null,inventory_item_id,
                                  decode(sign(p_hdr_id),
                                         -1,
                                         inventory_item_id,
                                         wms_cartnzn_pub.Get_LPN_ItemId(content_lpn_id)
           ) ),Abs(transaction_temp_id);


         CURSOR packages(p_hdr_id NUMBER) IS
            SELECT
             transaction_temp_id,
             inventory_item_id,
             primary_quantity,
             transaction_quantity,
             secondary_transaction_quantity, --invconv kkillams
             content_lpn_id,
             container_item_id,
             cartonization_id
             FROM
             wms_cartonization_temp
             WHERE
             transaction_header_id = p_hdr_id
             order by cartonization_id;

        CURSOR opackages(p_hdr_id NUMBER) IS
           SELECT
             wct.transaction_temp_id,
             wct.inventory_item_id,
             wct.primary_quantity,
             wct.transaction_quantity,
             wct.secondary_transaction_quantity, --invconv kkillams
             wct.content_lpn_id,
             wct.container_item_id,
             wct.cartonization_id
             FROM
             wms_cartonization_temp wct,
             mtl_txn_request_lines mtrl
             WHERE
             wct.move_order_line_id = mtrl.line_id AND
             mtrl.header_id = p_hdr_id
             order by wct.cartonization_id;

             l_cartonization_profile  VARCHAR2(1)   := 'Y';
   BEGIN

      --setting the global variable for trace
      g_trace_on := fnd_profile.value('INV_DEBUG_TRACE');
      -- Setting the global variable for packaging
      --      packaging_mode := p_packaging_mode;
      -- Setting the global variable for sequence
      --sequence_id := 1;

      --      l_current_header_id := p_move_order_header_id;

      -- For subinventory restriction in Rules Workbench

      IF (g_trace_on = 1) THEN log_event(' In CARTONIZE_MIXED_ITEM()'); END IF;

      IF p_subinventory_name IS NOT NULL THEN

         IF (g_trace_on = 1) THEN log_event(' Updating wct with dummy cartonization id for sub other than : ' || p_subinventory_name); END IF;

         UPDATE wms_cartonization_temp
            SET cartonization_id = -99999
              , container_item_id = -99999
          WHERE subinventory_code <> p_subinventory_name
            AND organization_id = p_org_id
            AND cartonization_id IS NULL;

      END IF;

      IF p_pack_level = 0 THEN
         curr_header_id_for_mixed := p_move_order_header_id;
      END IF;

      outbound := 'Y';
      cartonization_profile := 'Y';

      IF( cartonization_profile = 'Y') THEN

         pack_level := p_pack_level;

         LOOP

            IF (g_trace_on = 1) THEN log_event(' pack_level '||pack_level ||' l_stop_level'||l_stop_level); END IF;

            EXIT WHEN ( (pack_level >= l_stop_level) AND (l_stop_level <> -1));

            IF p_stop_level IS NOT NULL THEN
               l_stop_level := p_stop_level;
               IF (g_trace_on = 1) THEN
                  log_event('This procedure called for FIRST LEVEL cartonization only');
               END IF;
            ELSE
               IF (g_trace_on = 1) THEN
                  log_event('This procedure called for MULTI LEVEL cartonization');
               END IF;
            END IF;

            v_prev_item_id := -1;
            v_prev_move_order_line_id  := -1;

             --bpack_rows should select only rows with transaction_header_id = l_current_header_id
            if (g_trace_on = 1) then log_event(' opening  cusror  hdr id'||l_current_header_id); END IF;


            IF( (outbound = 'Y') AND (pack_level = 0)) THEN
               error_code := 'CARTONIZE 70';
               if (g_trace_on = 1) then log_event('opening wct_rows'); END IF;
               OPEN wct_rows;
               if (g_trace_on = 1) then log_event('opened bpack rows'); END IF;
            ELSE
               error_code := 'CARTONIZE 90';
               if (g_trace_on = 1) then log_event('opening bpack_rows'); END IF;
               OPEN bpack_rows(l_current_header_id);
               if (g_trace_on = 1) then log_event(' Opened bpack rows'); END IF;
            END IF;

            IF (g_trace_on = 1) THEN
               log_event(' l_stop_level '||l_stop_level);
               log_event(' l_current_level '||pack_level);
               log_event(' l_current_header_id '||l_current_header_id);
            END IF;

            IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
               ret_value:= do_cartonization(p_move_order_header_id,0,outbound,
                                          v_sublvlctrl,WMS_CARTNZN_PUB.g_percent_fill_basis);

            ELSE
               IF (g_trace_on = 1) THEN
                  log_event('in else for cartonization');
                  log_event('passing header id '||l_current_header_id);
                  log_event('passing outbound '||outbound);
                  log_event('passing Sub level Control'||v_sublvlctrl);
               END IF;
               ret_value:= do_cartonization(0,curr_header_id_for_mixed,outbound,
                                          v_sublvlctrl,WMS_CARTNZN_PUB.g_percent_fill_basis);

            END IF;

            IF (g_trace_on = 1) THEN
               log_event(' cartonization returned'|| ret_value);
               log_event(' calling split_lot_serials ');
            END IF;

            split_lot_serials(p_org_id);

            IF (g_trace_on = 1) then log_event(' pack level'); END IF;

            IF pack_level <> 0 THEN

               IF (g_trace_on = 1) then log_event(' Populating Packaging History Table'); END IF;

               l_prev_package_id := -1;

             --  l_prev_header_id := l_current_header_id;

               prev_header_id_for_mixed := curr_header_id_for_mixed;

               l_prev_header_id := prev_header_id_for_mixed;

               IF (g_trace_on = 1) then log_event(' prev header id '||l_prev_header_id ); END IF;
      --         l_current_header_id := get_next_header_id;
               curr_header_id_for_mixed := get_next_header_id;
               l_current_header_id := curr_header_id_for_mixed;
               IF (g_trace_on = 1) then log_event(' current_header_id '||curr_header_id_for_mixed); END IF;

               error_code := 'CARTONIZE 225';
               t_lpn_alloc_flag_table.delete;
               error_code := 'CARTONIZE 226';

               IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
                  error_code := 'CARTONIZE 227';
                   if (g_trace_on = 1) then log_event('Opening OPACKAGES cursor for l_prev_header_id'||l_prev_header_id); END IF;
                  OPEN opackages(l_prev_header_id);
               ELSE
                   if (g_trace_on = 1) then log_event('Opening PACKAGES cursor for l_prev_header_id'||l_prev_header_id); END IF;
                  error_code := 'CARTONIZE 228';
                  OPEN packages(l_prev_header_id);
               END IF;

               l_no_pkgs_gen := 'Y';
               error_code := 'CARTONIZE 230';

               LOOP

                  if (g_trace_on = 1) then log_event('Fetching Packages cursor '); END IF;
                  error_code := 'CARTONIZE 240';

                  IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
                      if (g_trace_on = 1) then log_event('OPACKAGES'); END IF;
                     FETCH opackages INTO l_temp_id,l_item_id, l_qty, l_tr_qty,l_sec_tr_qty, l_clpn_id, l_citem_id, l_package_id;
                     EXIT WHEN opackages%notfound;
                  ELSE
                                  if (g_trace_on = 1) then log_event('PACKAGES'); END IF;
                     FETCH packages INTO l_temp_id,l_item_id, l_qty, l_tr_qty, l_sec_tr_qty, l_clpn_id, l_citem_id, l_package_id;
                     EXIT WHEN packages%notfound;
                  END IF;

                  IF (g_trace_on = 1) THEN
                     log_event('temp_id '||l_temp_id );
                     log_event('item_id  '||l_item_id );
                     log_event('qty  '||l_qty );
                     log_event('tr_qty '||l_tr_qty);
                     log_event('sec_tr_qty '||l_sec_tr_qty);
                     log_event('clpn_id '||l_clpn_id);
                     log_event('citem_id '||l_citem_id);
                     log_event('package_id '||l_package_id);
                  END IF;

                  IF( l_package_id IS NOT NULL ) THEN

                     l_no_pkgs_gen := 'N';
                     IF( l_package_id <> l_prev_package_id ) THEN
                        l_prev_package_id := l_package_id;
                        IF (g_trace_on = 1) then log_event(' Inserting a new row for package '||l_package_id); END IF;
                           insert_mmtt
                           (p_transaction_temp_id  => l_temp_id,
                           p_primary_quantity     => l_qty,
                           p_transaction_quantity => l_tr_qty,
                           p_secondary_quantity   => l_sec_tr_qty, --invconv kkillams
                           p_new_txn_hdr_id    => l_current_header_id,
                           p_new_txn_tmp_id      => get_next_temp_id,
                           p_clpn_id              => l_package_id,
                           p_item_id             => l_citem_id,
                           x_return_status          => l_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data );
                        END IF;
                     IF (g_trace_on = 1) THEN log_event(' Calling InsertPH for temp_id'||l_temp_id); END IF;
                     IF( outbound = 'Y' ) THEN
                        Insert_PH(p_move_order_header_id, l_temp_id);
                     ELSE
                        Insert_PH(p_transaction_header_id, l_temp_id);
                     END IF;
                  END IF;
               END LOOP;

               IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
                  IF opackages%isopen THEN
                     CLOSE opackages;
                  END IF;
               ELSE
                  IF packages%isopen THEN
                     CLOSE packages;
                  END IF;
               END IF;
            END IF;  -- pack level <> 0

            IF( l_no_pkgs_gen = 'Y' ) THEN
               if (g_trace_on = 1) then log_event('no labels generated in the previous level-EXITING'); END IF;
               IF ( (outbound = 'Y') AND (pack_level = 0) ) THEN
                  IF( wct_rows%isopen) then
                     CLOSE wct_rows;
                  END IF;
               ELSE
                  IF(bpack_rows%isopen) then
                     CLOSE bpack_rows;
                  END IF;
               END IF;
               EXIT;
            END IF;

            IF ((outbound = 'Y') AND (pack_level = 0)) THEN
               IF wct_rows%isopen THEN
                  CLOSE wct_rows;
               END IF;
            ELSE
               IF(bpack_rows%isopen) then
                  CLOSE bpack_rows;
               END IF;
            END IF;

            pack_level := pack_level + 1;

            IF (g_trace_on = 1) THEN
               log_event(' Incremented the current level');
               log_event(' going back to the multi-cart loop');
            END IF;
         END LOOP; -- Ends the loop for multi level cartonization

         l_header_id := p_move_order_header_id;

      ELSE
                   -- Cartonization profile = 'N'
         NULL;
      END IF;

      IF (g_trace_on = 1) THEN log_event('return status is '||x_return_status);  END IF;

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;

      IF p_subinventory_name IS NOT NULL THEN
         IF (g_trace_on = 1) THEN log_event(' Updating wct with back to null where the dummy cartonization id was populated for sub restrictions : '); END IF;

        UPDATE wms_cartonization_temp
           SET cartonization_id = NULL
             , container_item_id = NULL
         WHERE subinventory_code <> p_subinventory_name
           AND organization_id = p_org_id
           AND cartonization_id = -99999
           AND container_item_id = -99999;
      END IF;

   EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
      ROLLBACK TO  cartonize_pub;
      x_return_status := fnd_api.g_ret_sts_success;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
      FND_MSG_PUB.ADD;
      IF (g_trace_on = 1) THEN log_event('EXCEPTION occurred from ERROR_CODE:'||error_code); END IF;
      fnd_msg_pub.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data
      );

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      if (g_trace_on = 1) then log_event('Exception occurred from SQLERRM:'||SQLERRM); END IF;
      if (g_trace_on = 1) then log_event('Exception occurred from SQLCODE:'||SQLCODE); END IF;
      if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
      ROLLBACK TO  cartonize_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
      FND_MSG_PUB.ADD;
      if (g_trace_on = 1) then log_event('Exception occurred from ERROR_CODE:'||error_code); END IF;
      fnd_msg_pub.count_and_get
      (
         p_count  => x_msg_count,
         p_data   => x_msg_data
      );

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;
   WHEN OTHERS  THEN
      ROLLBACK TO  cartonize_pub;
      if (g_trace_on = 1) then log_event('Rolling back to savepoint cartonize_pub'); END IF;
      if (g_trace_on = 1) then log_event('Exception occurred from SQLERRM:'||SQLERRM); END IF;
      if (g_trace_on = 1) then log_event('Exception occurred from SQLCODE:'||SQLCODE); END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ERROR_MSG := Sqlerrm;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
      FND_MSG_PUB.ADD;
      IF (g_trace_on = 1) THEN log_event('Exception occurred from ERROR_CODE:'||error_code); END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
         fnd_msg_pub.add_exc_msg
         ( g_pkg_name,
           l_api_name,
           ERROR_MSG
         );
      END IF;

      fnd_msg_pub.count_and_get
        (
          p_count  => x_msg_count,
          p_data   => x_msg_data
          );

      IF wct_rows%isopen THEN
         CLOSE wct_rows;
      END IF;

   END cartonize_mixed_item;

PROCEDURE cartonize_pick_slip
        (
                p_org_id               IN  NUMBER,
                p_move_order_header_id IN  NUMBER,
                p_subinventory_name    IN  VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2 )
IS
        CURSOR Pick_slip_cur
        IS
                SELECT DISTINCT wct.pick_slip_number
                FROM    wms_cartonization_temp wct,
                        mtl_txn_request_lines mtrl,
                        mtl_parameters mtlp,
                        mtl_secondary_inventories sub
                WHERE   mtrl.header_id               = p_move_order_header_id
                    AND mtrl.organization_id         = p_org_id
                    AND wct.move_order_line_id       = mtrl.line_id
                    AND wct.organization_id          = mtrl.organization_id
                    AND mtlp.organization_id         = wct.organization_id
                    AND sub.organization_id          = wct.organization_id
                    AND sub.secondary_inventory_name = wct.subinventory_code
                    AND wct.cartonization_id  IS NULL
                    AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
			OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
			OR (NVL(mtlp.cartonization_flag,-1) = 4)
			OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
			)
                ORDER BY 1 ;

        CURSOR Pick_slip_sub_cur
        IS
                SELECT DISTINCT wct.pick_slip_number
                FROM    wms_cartonization_temp wct,
                        mtl_txn_request_lines mtrl,
                        mtl_parameters mtlp,
                        mtl_secondary_inventories sub
                WHERE   mtrl.header_id               = p_move_order_header_id
                    AND mtrl.organization_id         = p_org_id
                    AND wct.move_order_line_id       = mtrl.line_id
                    AND wct.organization_id          = mtrl.organization_id
                    AND wct.subinventory_code        = p_subinventory_name
                    AND mtlp.organization_id         = wct.organization_id
                    AND sub.organization_id          = wct.organization_id
                    AND sub.secondary_inventory_name = wct.subinventory_code
                    AND wct.cartonization_id  IS NULL
                    AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
			OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
			OR (NVL(mtlp.cartonization_flag,-1) = 4)
			OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
			)
                ORDER BY 1 ;

        CURSOR Delivery_cur (p_pick_slip_number NUMBER)
        IS
                SELECT DISTINCT wda.delivery_id
                FROM    mtl_txn_request_lines mtrl,
                        wms_cartonization_temp wct,
                        wsh_delivery_details wdd  ,
                        wsh_delivery_assignments wda
                WHERE   mtrl.organization_id   = p_org_id
                    AND mtrl.header_id         = p_move_order_header_id
                    AND wct.move_order_line_id = mtrl.line_id
                    AND wct.organization_id    = mtrl.organization_id
                    AND wct.pick_slip_number   = p_pick_slip_number
                    AND wct.cartonization_id  IS NULL
                    AND wct.demand_source_line = wdd.source_line_id
                    AND wdd.move_order_line_id = mtrl.line_id
                    AND wda.delivery_detail_id = wdd.delivery_detail_id
                    AND wda.delivery_id       IS NOT NULL
                ORDER BY 1 ;

        CURSOR Delivery_sub_cur (p_pick_slip_number NUMBER)
        IS
                SELECT DISTINCT wda.delivery_id
                FROM    mtl_txn_request_lines mtrl,
                        wms_cartonization_temp wct,
                        wsh_delivery_details wdd  ,
                        wsh_delivery_assignments wda
                WHERE   mtrl.organization_id   = p_org_id
                    AND mtrl.header_id         = p_move_order_header_id
                    AND wct.move_order_line_id = mtrl.line_id
                    AND wct.organization_id    = mtrl.organization_id
                    AND wct.subinventory_code  = p_subinventory_name
                    AND wct.pick_slip_number   = p_pick_slip_number
                    AND wct.cartonization_id   IS NULL
                    AND wct.demand_source_line = wdd.source_line_id
                    AND wdd.move_order_line_id = mtrl.line_id
                    AND wda.delivery_detail_id = wdd.delivery_detail_id
                    AND wda.delivery_id        IS NOT NULL
                ORDER BY 1 ;

        l_pick_slip      NUMBER;
        l_carton_lpn_id  NUMBER ;
        l_curr_deliv     NUMBER;
        l_del_det_id_tab WSH_UTIL_CORE.id_tab_type;
        l_grouping_rows  WSH_UTIL_CORE.id_tab_type;
        l_return_status  VARCHAR2(100);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(10000);
        l_index          NUMBER;

TYPE l_grp_rec
IS
        RECORD
        (
                grouping_id   NUMBER ,
                carton_lpn_id NUMBER
        );

TYPE l_grp_tb
IS
        TABLE OF l_grp_rec INDEX BY BINARY_INTEGER;

        l_grp_table l_grp_tb;
BEGIN
        IF (g_trace_on = 1) THEN
                log_event('In CARTONIZE_PICK_SLIP()  with following parameters ');
                log_event('p_org_id =>'|| p_org_id );
                log_event('p_move_order_header_id =>'|| p_move_order_header_id );
                log_event('p_subinventory_name =>'|| p_subinventory_name );
        END IF;

        IF p_subinventory_name IS NULL THEN
           OPEN Pick_slip_cur ;
        ELSE
           OPEN Pick_slip_sub_cur ;
        END IF;

        LOOP
                IF p_subinventory_name IS NULL THEN
                   FETCH   Pick_slip_cur
                   INTO    l_pick_slip ;
                   EXIT  WHEN Pick_slip_cur%NOTFOUND;
                ELSE
                   FETCH   Pick_slip_sub_cur
                   INTO    l_pick_slip ;
                   EXIT  WHEN Pick_slip_sub_cur%NOTFOUND;
                END IF;

                IF (g_trace_on = 1) THEN
                        log_event('current Pick slip number : '|| l_pick_slip );
                END IF;

                IF p_subinventory_name IS NULL THEN
                   OPEN Delivery_cur (l_pick_slip);
                ELSE
                   OPEN Delivery_sub_cur (l_pick_slip);
                END IF;

                LOOP
                        IF p_subinventory_name IS NULL THEN
                            FETCH   Delivery_cur
                            INTO    l_curr_deliv ;
                            EXIT  WHEN Delivery_cur%NOTFOUND;
                        ELSE
                            FETCH   Delivery_sub_cur
                            INTO    l_curr_deliv ;
                            EXIT  WHEN Delivery_sub_cur%NOTFOUND;
                        END IF;

                        IF (g_trace_on = 1) THEN
                                log_event('Generating lpn for delivery id : '|| l_curr_deliv );
                        END IF;

                        l_carton_lpn_id := get_next_package_id;

                        UPDATE wms_cartonization_temp
                        SET     cartonization_id     = l_carton_lpn_id
                        WHERE   transaction_temp_id IN
                                (SELECT wct.transaction_temp_id
                                FROM    wsh_delivery_details wdd    ,
                                        wms_cartonization_temp wct  ,
                                        wsh_delivery_assignments wda,
                                        mtl_txn_request_lines mtrl
                                WHERE   wda.delivery_detail_id = wdd.delivery_detail_id
                                    AND wdd.source_line_id     = wct.demand_source_line
                                    AND wct.move_order_line_id = mtrl.line_id
                                    AND wct.cartonization_id  IS NULL
                                    AND wda.delivery_id        = l_curr_deliv
                                    AND wct.pick_slip_number   = l_pick_slip
                                    AND wdd.move_order_line_id = mtrl.line_id
                                    AND mtrl.header_id         = p_move_order_header_id
                                    AND mtrl.organization_id   = p_org_id
                                ) ;
                        IF (g_trace_on = 1) THEN
                                log_event('Updated carton LPN :'|| l_carton_lpn_id ||' for delivery:'||l_curr_deliv );
                        END IF;
                END LOOP ; --Delivery cursor.

                IF Delivery_cur%ISOPEN THEN
                   CLOSE Delivery_cur ;
                ELSIF Delivery_sub_cur%ISOPEN THEN
                   CLOSE Delivery_sub_cur ;
                END IF;

                IF (g_trace_on = 1) THEN
                        log_event('Done with all deliveries for this pick slip number, now checking non-delivery WDDs ' );
                END IF;
                BEGIN --- WDDs which does not have delivery created yet.
                     l_index := 1 ;

                     IF p_subinventory_name IS NULL THEN
                        SELECT  wdd.delivery_detail_id BULK COLLECT
                        INTO    l_del_det_id_tab
                        FROM    mtl_txn_request_lines mtrl,
                                wms_cartonization_temp wct,
                                wsh_delivery_details wdd  ,
                                wsh_delivery_assignments wda
                        WHERE   mtrl.organization_id   = p_org_id
                            AND mtrl.header_id         = p_move_order_header_id
                            AND wct.move_order_line_id = mtrl.line_id
                            AND wct.organization_id    = mtrl.organization_id
                            AND wct.pick_slip_number   = l_pick_slip
                            AND wct.cartonization_id  IS NULL
                            AND wct.demand_source_line = wdd.source_line_id
                            AND wdd.move_order_line_id = mtrl.line_id
                            AND wda.delivery_detail_id = wdd.delivery_detail_id
                            AND wda.delivery_id IS NULL;
                     ELSE
                        SELECT  wdd.delivery_detail_id BULK COLLECT
                        INTO    l_del_det_id_tab
                        FROM    mtl_txn_request_lines mtrl,
                                wms_cartonization_temp wct,
                                wsh_delivery_details wdd  ,
                                wsh_delivery_assignments wda
                        WHERE   mtrl.organization_id   = p_org_id
                            AND mtrl.header_id         = p_move_order_header_id
                            AND wct.move_order_line_id = mtrl.line_id
                            AND wct.organization_id    = mtrl.organization_id
                            AND wct.subinventory_code  = p_subinventory_name
                            AND wct.pick_slip_number   = l_pick_slip
                            AND wct.cartonization_id  IS NULL
                            AND wct.demand_source_line = wdd.source_line_id
                            AND wdd.move_order_line_id = mtrl.line_id
                            AND wda.delivery_detail_id = wdd.delivery_detail_id
                            AND wda.delivery_id IS NULL;
                     END IF;

                     IF (g_trace_on = 1) THEN
                             log_event('There are '||l_del_det_id_tab.COUNT ||' non-delivery WDDs ' );
                     END IF;

                     IF (l_del_det_id_tab.COUNT > 0 ) THEN
                           IF (g_trace_on = 1) THEN
                           log_event('calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping' );
                           END IF;
                          WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping( p_line_rows => l_del_det_id_tab,
                                          x_grouping_rows => l_grouping_rows,
                                          x_return_status => l_return_status);
                                    IF l_return_status  = 'E' THEN
                        IF (g_trace_on = 1) THEN
                               log_event('API WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping returned Error' );
                        END IF;
                              x_return_status := fnd_api.g_ret_sts_unexp_error ;
                         RETURN;
                     END IF;

                     FOR i IN l_del_det_id_tab.FIRST .. l_del_det_id_tab.LAST
                     LOOP
                        l_carton_lpn_id := NULL ;
                        FOR j IN 1..l_grp_table.COUNT
                        LOOP
                           IF ( l_grouping_rows(i) = l_grp_table(j).grouping_id ) THEN
                              l_carton_lpn_id := l_grp_table(j).carton_lpn_id ;
                           END IF;
                        END LOOP;

                        IF ( l_carton_lpn_id   IS NULL ) THEN
                           l_carton_lpn_id                     := get_next_package_id;
                           l_grp_table(l_index ).grouping_id   := l_grouping_rows(i);
                           l_grp_table(l_index ).carton_lpn_id := l_carton_lpn_id;
                           l_index                             := l_index + 1 ;
                        END IF;

                        IF (g_trace_on = 1) THEN
                           log_event('Got carton_lpn_id :'||l_carton_lpn_id );
                        END IF;

                        UPDATE wms_cartonization_temp
                        SET     cartonization_id     = l_carton_lpn_id
                        WHERE   transaction_temp_id IN
                        (SELECT wct.transaction_temp_id
                        FROM    wsh_delivery_details wdd  ,
                                wms_cartonization_temp wct,
                                mtl_txn_request_lines mtrl
                        WHERE   wdd.delivery_detail_id = l_del_det_id_tab (i)
                        AND wct.pick_slip_number   = l_pick_slip
                        AND wdd.source_line_id     = wct.demand_source_line
                        AND wdd.move_order_line_id = mtrl.line_id
                        AND wct.move_order_line_id = mtrl.line_id
                        AND wct.cartonization_id  IS NULL
                        AND mtrl.header_id         = p_move_order_header_id
                        AND mtrl.organization_id   = p_org_id
                        ) ;

                        IF (g_trace_on = 1) THEN
                           log_event('Updated WCT for wdd :'||l_del_det_id_tab (i) );
                        END IF;
                 END LOOP ; --FOR l_del_det_id_tab records

			        IF (g_trace_on = 1) THEN
                     log_event('Done with all non-delivery WDDs for this pick slip number ' );
	              END IF;
			        l_grp_table.DELETE ;
       			  l_del_det_id_tab.DELETE ;
			END IF; --WDD table count.
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      IF (g_trace_on = 1) THEN
         log_event('All WDDs have delivery associated .' );
      END IF;
      WHEN OTHERS THEN
         IF (g_trace_on = 1) THEN
                 log_event('OTHERS Exception !!! .' );
         END IF;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
      END ;
   END LOOP ; -- Pick slip cursor.
   IF Pick_slip_cur%ISOPEN THEN
      CLOSE Pick_slip_cur;
   ELSIF Pick_slip_sub_cur%ISOPEN THEN
      CLOSE Pick_slip_sub_cur;
   END IF;
   IF (g_trace_on = 1) THEN
          log_event('Done with all pick slip numbers ' );
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;
   IF (g_trace_on   = 1) THEN
      log_event('Cartonize_pick_slip finished normally.');
   END IF;
EXCEPTION
WHEN OTHERS THEN
        IF (g_trace_on = 1) THEN
                log_event('Error in cartonize_pick_clip () :'||SQLERRM);
        END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
END cartonize_pick_slip;


   PROCEDURE cartonize_customer_logic
                  (
                    p_org_id                 IN          NUMBER
                  , p_move_order_header_id   IN          NUMBER
                  , p_subinventory_name      IN          VARCHAR2
                  , x_return_status          OUT NOCOPY  VARCHAR2
                  )
   IS

      TYPE l_cart_tab_type IS TABLE OF mtl_material_transactions_temp.cartonization_id%TYPE INDEX BY BINARY_INTEGER;
      TYPE l_trans_temp_tab_type IS TABLE OF mtl_material_transactions_temp.transaction_temp_id%TYPE INDEX BY BINARY_INTEGER;

      l_mmtt_table          WMS_CARTONIZATION_USER_PUB.mmtt_type;
      l_out_mmtt_table      WMS_CARTONIZATION_USER_PUB.mmtt_type;

      CURSOR Delivery_cur (p_pick_slip_number NUMBER)
      IS
         SELECT DISTINCT wda.delivery_id
           FROM mtl_txn_request_lines mtrl,
                wms_cartonization_temp wct,
                wsh_delivery_details wdd  ,
                wsh_delivery_assignments wda
          WHERE mtrl.organization_id   = p_org_id
            AND mtrl.header_id         = p_move_order_header_id
            AND wct.move_order_line_id = mtrl.line_id
            AND wct.organization_id    = mtrl.organization_id
            AND wct.pick_slip_number   = p_pick_slip_number
            AND wct.cartonization_id  IS NULL
            AND wct.demand_source_line = wdd.source_line_id
            AND wdd.move_order_line_id = mtrl.line_id
            AND wda.delivery_detail_id = wdd.delivery_detail_id
            AND wda.delivery_id       IS NOT NULL
          ORDER BY 1 ;

      CURSOR Delivery_sub_cur (p_pick_slip_number NUMBER)
      IS
         SELECT DISTINCT wda.delivery_id
           FROM mtl_txn_request_lines mtrl,
                wms_cartonization_temp wct,
                wsh_delivery_details wdd  ,
                wsh_delivery_assignments wda
          WHERE mtrl.organization_id   = p_org_id
            AND mtrl.header_id         = p_move_order_header_id
            AND wct.move_order_line_id = mtrl.line_id
            AND wct.organization_id    = mtrl.organization_id
            AND wct.subinventory_code  = p_subinventory_name
            AND wct.pick_slip_number   = p_pick_slip_number
            AND wct.cartonization_id  IS NULL
            AND wct.demand_source_line = wdd.source_line_id
            AND wdd.move_order_line_id = mtrl.line_id
            AND wda.delivery_detail_id = wdd.delivery_detail_id
            AND wda.delivery_id       IS NOT NULL
          ORDER BY 1 ;

      l_pick_slip      NUMBER;
      l_carton_lpn_id  NUMBER ;
      l_curr_deliv     NUMBER;
      l_del_det_id_tab WSH_UTIL_CORE.id_tab_type;
      l_grouping_rows  WSH_UTIL_CORE.id_tab_type;
      l_return_status  VARCHAR2(100);
      l_msg_count      NUMBER;
      l_msg_data       VARCHAR2(10000);
      l_index          NUMBER;

      TYPE l_grp_rec
      IS RECORD
               (
                      grouping_id   NUMBER ,
                      carton_lpn_id NUMBER
               );

      TYPE l_grp_tb
      IS
      TABLE OF l_grp_rec INDEX BY BINARY_INTEGER;

      l_grp_table              l_grp_tb;
      l_cart_tab               l_cart_tab_type;
      l_trans_temp_tab         l_trans_temp_tab_type;
      l_invalid_cartonization  EXCEPTION;
      l_grouping_rows_temp     NUMBER;
      l_carton_id_exists       VARCHAR2(1);
      l_cart_return_status     VARCHAR2(1);
      l_delivery_id_temp       NUMBER;
      l_carton_delivery_count  NUMBER;
      l_cartons_not_stamped    VARCHAR2(1) := 'Y';

   BEGIN

      IF (g_trace_on = 1) THEN
         log_event('In CARTONIZE_CUSTOMER_LOGIC()  with following parameters ');
         log_event('p_org_id =>'|| p_org_id );
         log_event('p_move_order_header_id =>'|| p_move_order_header_id );
         log_event('p_subinventory_name =>'|| p_subinventory_name );
      END IF;

      IF p_subinventory_name IS NOT NULL THEN

         SELECT wct.* BULK COLLECT INTO l_mmtt_table
          FROM wms_cartonization_temp wct,
               mtl_txn_request_lines mtrl,
               mtl_secondary_inventories sub,
               mtl_parameters mtlp
         WHERE wct.move_order_line_id =mtrl.line_id
           AND mtrl.header_id = p_move_order_header_id
           AND mtlp.organization_id = wct.organization_id
           AND sub.organization_id = wct.organization_id
           AND sub.secondary_inventory_name = wct.subinventory_code
           AND wct.subinventory_code = p_subinventory_name
           AND wct.organization_id = p_org_id
           AND wct.cartonization_id IS NULL
           AND wct.transfer_lpn_id IS NULL
           AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
		OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
		OR (NVL(mtlp.cartonization_flag,-1) = 4)
		OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
		)
           ORDER BY wct.move_order_line_id,
                     wct.inventory_item_id,
                     Abs(wct.transaction_temp_id);
      ELSE

         SELECT wct.* BULK COLLECT INTO l_mmtt_table
          FROM wms_cartonization_temp wct,
               mtl_txn_request_lines mtrl,
               mtl_secondary_inventories sub,
               mtl_parameters mtlp
         WHERE wct.move_order_line_id =mtrl.line_id
           AND mtrl.header_id = p_move_order_header_id
           AND mtlp.organization_id = wct.organization_id
           AND sub.secondary_inventory_name = wct.subinventory_code
           AND sub.organization_id = wct.organization_id
           AND wct.organization_id = p_org_id
           AND wct.cartonization_id IS NULL
           AND wct.transfer_lpn_id IS NULL
           AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
		OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
		OR (NVL(mtlp.cartonization_flag,-1) = 4)
		OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
		)
           ORDER BY wct.move_order_line_id,
                     wct.inventory_item_id,
                     Abs(wct.transaction_temp_id);

      END IF;

      IF (g_trace_on = 1) THEN
         log_event('l_mmtt_table.COUNT  : ' || l_mmtt_table.COUNT);
      END IF;

      WMS_CARTONIZATION_USER_PUB.CARTONIZE (
                                     x_return_status    => l_cart_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , x_task_table       => l_out_mmtt_table
                                   , p_organization_id  => p_org_id
                                   , p_task_table       => l_mmtt_table
                                    );

      IF (g_trace_on = 1) THEN
         log_event('l_out_mmtt_table.COUNT  : ' || l_out_mmtt_table.COUNT);
      END IF;

      IF NVL(l_cart_return_status,'E') = 'E'
      OR l_mmtt_table.COUNT <> l_out_mmtt_table.COUNT THEN
         IF (g_trace_on = 1) THEN
            log_event('WMS_CARTONIZATION_USER_PUB.cartonize() returned failure, exiting cartonize_customer_logic() ');
         END IF;
         x_return_status := 'E';
         RETURN;
      END IF;

      -- loop to get the distinct cartonization ids
--      l_cart_tab(1) := l_out_mmtt_table(1).cartonization_id;

      l_cart_tab.DELETE;

      IF (g_trace_on = 1) THEN
         log_event('Reached SAVEPOINT CUSTOMER_LOGIC_SP');
      END IF;

      SAVEPOINT CUSTOMER_LOGIC_SP;

      FOR i IN l_out_mmtt_table.FIRST .. l_out_mmtt_table.LAST LOOP

         IF l_out_mmtt_table(i).cartonization_id IS NOT NULL THEN

            IF l_cart_tab.COUNT = 0 THEN
               l_cart_tab(1) := l_out_mmtt_table(i).cartonization_id;
            END IF;

            l_cartons_not_stamped := 'N';

            UPDATE wms_cartonization_temp
               SET cartonization_id    = l_out_mmtt_table(i).cartonization_id
                 , container_item_id   = l_out_mmtt_table(i).container_item_id
             WHERE transaction_temp_id = l_out_mmtt_table(i).transaction_temp_id;

            l_carton_id_exists := 'N';

            FOR j IN l_cart_tab.FIRST .. l_cart_tab.LAST LOOP
               IF l_out_mmtt_table(i).cartonization_id = l_cart_tab(j) THEN
                  l_carton_id_exists := 'Y';
                  EXIT;
               END IF;
            END LOOP;
            IF l_carton_id_exists = 'N' THEN
               l_cart_tab(l_cart_tab.COUNT + 1) := l_out_mmtt_table(i).cartonization_id;
            END IF;
         END IF;

      END LOOP;

      IF (g_trace_on = 1) THEN
         log_event('Updated WCT rows with customer logic cartonization ids');
      END IF;

      IF l_cartons_not_stamped = 'Y' THEN
         IF (g_trace_on = 1) THEN
            log_event('The customer did not stamp cartonization_id on any task, returning');
         END IF;
         RAISE L_INVALID_CARTONIZATION;
      END IF;

      FOR i IN l_cart_tab.FIRST .. l_cart_tab.LAST LOOP

         l_del_det_id_tab.DELETE;

         IF (g_trace_on = 1) THEN
            log_event('Getting WDD rows for cartonization_id : '|| l_cart_tab(i));
         END IF;

         SELECT DISTINCT wdd.delivery_detail_id BULK COLLECT
           INTO l_del_det_id_tab
           FROM wsh_delivery_details wdd,
                wms_cartonization_temp wct,
                mtl_txn_request_lines mtrl
          WHERE wct.move_order_line_id = mtrl.line_id
            AND mtrl.header_id = p_move_order_header_id
            AND wct.organization_id = mtrl.organization_id
            AND wct.demand_source_line = wdd.source_line_id
            AND wct.organization_id = p_org_id
            AND wdd.move_order_line_id = mtrl.line_id
            AND wct.cartonization_id = l_cart_tab(i);

         IF (g_trace_on = 1) THEN
            FOR j IN l_del_det_id_tab.FIRST .. l_del_det_id_tab.LAST LOOP
               log_event('l_del_det_id_tab ('|| i ||') : '|| l_del_det_id_tab(j));
            END LOOP;
         END IF;

         IF (l_del_det_id_tab.COUNT > 0 ) THEN

            IF (g_trace_on = 1) THEN
               log_event('calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping' );
            END IF;

            WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping
                                              (
                                              p_line_rows     => l_del_det_id_tab,
                                              x_grouping_rows => l_grouping_rows,
                                              x_return_status => l_return_status
                                              );

            IF NVL(l_return_status,'E')  = 'E' THEN
               IF (g_trace_on = 1) THEN
                      log_event('API WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping returned Error' );
               END IF;
               RAISE L_INVALID_CARTONIZATION;
            END IF;

            IF (g_trace_on = 1) THEN
               log_event('Grouping rows returned for cartonization_id : '|| l_cart_tab(i));
               FOR j IN l_grouping_rows.FIRST .. l_grouping_rows.LAST LOOP
                  log_event('l_grouping_rows ( '|| i || ' ) : ' || l_grouping_rows(j));
               END LOOP;
            END IF;

            l_grouping_rows_temp := l_grouping_rows(1);
            FOR j IN l_grouping_rows.FIRST .. l_grouping_rows.LAST LOOP
               IF l_grouping_rows_temp <> l_grouping_rows(j) THEN
                  log_event('Tasks associated with cartonization_id '|| l_cart_tab(i)|| ' cannot be shipped together');
                  RAISE L_INVALID_CARTONIZATION;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      IF (g_trace_on = 1) THEN
         log_event ('Suggest containers by customer algorithm are verified successfully.');
         log_event ('Exiting normally from cartonize_customer_logic()');
      END IF;

   EXCEPTION
   WHEN L_INVALID_CARTONIZATION THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (g_trace_on = 1) THEN
         log_event('Unable to cartonize, ROLLING BACK to CUSTOMER_LOGIC_SP and exiting from cartonize_customer_logic');
      END IF;
      ROLLBACK TO CUSTOMER_LOGIC_SP;
   WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (g_trace_on = 1) THEN
         log_event('Unexpected error in cartonize_customer_logic(), rolling back to CUSTOMER_LOGIC_SP');
         log_event('SQLCODE : ' || SQLCODE);
         log_event('SQLERRM : ' || SQLERRM);
      END IF;
      ROLLBACK TO CUSTOMER_LOGIC_SP;

   END cartonize_customer_logic;


   PROCEDURE cartonize_default_logic (
                      p_org_id                IN    NUMBER,
                      p_move_order_header_id  IN    NUMBER,
                      p_out_bound             IN    VARCHAR2,
                      x_return_status         OUT   NOCOPY VARCHAR2,
                      x_msg_count             OUT   NOCOPY NUMBER,
                      x_msg_data              OUT   NOCOPY VARCHAR2
   )
   IS
      l_api_return_status VARCHAR2(1);

   BEGIN

      IF (g_trace_on = 1) THEN
         log_event ('IN CARTONIZE_DEFAULT_LOGIC()');
         log_event ('calling procedure CARTONIZE_SINGLE_ITEM()');
      END IF;

      cartonize_single_item
      (
         x_return_status         => l_api_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_out_bound             => 'Y',
         p_org_id                => p_org_id,
         p_move_order_header_id  => p_move_order_header_id
      );

      IF (g_trace_on = 1) THEN
         log_event ('calling procedure CARTONIZE_MIXED_ITEM()');
      END IF;

      cartonize_mixed_item
      (
         x_return_status         => l_api_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_out_bound             => 'Y',
         p_org_id                => p_org_id,
         p_move_order_header_id  => p_move_order_header_id,
         p_transaction_header_id => NULL,
         p_stop_level            => 0, -- For first level only
         p_pack_level            => 0
      );

      IF (g_trace_on = 1) THEN log_event ('Returing normally from CARTONIZE_DEFAULT_LOGIC()'); END IF;
      x_return_status := 'S';
   EXCEPTION
   WHEN OTHERS THEN
      IF (g_trace_on = 1) THEN log_event ('SQL Error Message : '|| SQLERRM); END IF;
      IF (g_trace_on = 1) THEN log_event ('SQL Error Code : '|| SQLCODE); END IF;
      x_return_status := 'E';
   END;

PROCEDURE insert_ph
         (
             p_move_order_header_id IN NUMBER,
             p_current_header_id    IN NUMBER,
             x_return_status        OUT NOCOPY NUMBER
          )
IS

   L_PREV_PACKAGE_ID       NUMBER;
   L_PREV_HEADER_ID        NUMBER;
   L_CURRENT_HEADER_ID     NUMBER;
   l_qty                   NUMBER := NULL;
   l_tr_qty                NUMBER := NULL;
   l_sec_tr_qty            NUMBER := NULL;
   l_clpn_id               NUMBER := NULL;
   l_citem_id              NUMBER := NULL;
   l_package_id            NUMBER := NULL;
   l_upd_qty_flag          VARCHAR2(1) := NULL;
   L_no_pkgs_gen           VARCHAR2(1);
   l_temp_id               NUMBER;
   l_item_id               NUMBER;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);


   CURSOR opackages(p_hdr_id NUMBER) IS
   SELECT
   wct.transaction_temp_id,
   wct.inventory_item_id,
   wct.primary_quantity,
   wct.transaction_quantity,
   wct.secondary_transaction_quantity, --invconv kkillams
   wct.content_lpn_id,
   wct.container_item_id,
   wct.cartonization_id
   FROM
   wms_cartonization_temp wct,
   mtl_txn_request_lines mtrl
   WHERE
   wct.move_order_line_id = mtrl.line_id AND
   mtrl.header_id = p_move_order_header_id
   ORDER BY wct.cartonization_id;

BEGIN

   IF (g_trace_on = 1) THEN log_event('Coming in my insert_ph'); END IF;
   IF (g_trace_on = 1) THEN log_event('Pack_level' || pack_level); END IF;
   l_prev_package_id := -1;
   l_prev_header_id := p_current_header_id;
   l_current_header_id := get_next_header_id;
   curr_header_id_for_mixed := l_current_header_id;

   IF (g_trace_on = 1) THEN log_event('Setting curr_header_id_for_mixed : ' || curr_header_id_for_mixed); END IF;


   t_lpn_alloc_flag_table.DELETE;

   OPEN opackages(l_prev_header_id);
   l_no_pkgs_gen := 'Y';

   LOOP

      IF (g_trace_on = 1) THEN
         log_event('Fetching Packages cursor ');
      END IF;

      error_code := 'CARTONIZE 240';

      FETCH opackages INTO l_temp_id,l_item_id, l_qty, l_tr_qty,l_sec_tr_qty, l_clpn_id, l_citem_id, l_package_id;
      EXIT WHEN opackages%notfound;

      IF (g_trace_on = 1) THEN
         log_event('temp_id '||l_temp_id );
         log_event('item_id  '||l_item_id );
         log_event('qty  '||l_qty );
         log_event('tr_qty '||l_tr_qty);
         log_event('sec_tr_qty '||l_sec_tr_qty);
         log_event('clpn_id '||l_clpn_id);
         log_event('citem_id '||l_citem_id);
         log_event('package_id '||l_package_id);
      END IF;

      IF( l_package_id IS NOT NULL ) THEN

         l_no_pkgs_gen := 'N';
         IF( l_package_id <> l_prev_package_id ) THEN
            l_prev_package_id := l_package_id;

            IF (g_trace_on = 1) THEN
               log_event(' Inserting a new row for package '||l_package_id);
            END IF;

            insert_mmtt
            (
            p_transaction_temp_id  => l_temp_id,
            p_primary_quantity     => l_qty,
            p_transaction_quantity => l_tr_qty,
            p_secondary_quantity   => l_sec_tr_qty, --invconv kkillams
            p_new_txn_hdr_id    => l_current_header_id,
            p_new_txn_tmp_id      => get_next_temp_id,
            p_clpn_id              => l_package_id,
            p_item_id             => l_citem_id,
            x_return_status          => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data
            );
         END IF;

         IF (g_trace_on = 1) THEN
            log_event(' Calling InsertPH for temp_id'||l_temp_id);
         END IF;

         insert_ph(p_move_order_header_id, l_temp_id);

      END IF;
   END LOOP;

   IF opackages%isopen THEN
      CLOSE opackages;
   END IF;

END insert_ph;



END WMS_CARTNZN_PUB;

/
