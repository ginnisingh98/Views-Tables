--------------------------------------------------------
--  DDL for Package WIP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: WIPSVATS.pls 115.9 2002/12/01 13:13:55 simishra ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )RETURN BOOLEAN;

-- FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Description(p_description IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Entity_Type(p_entity_type IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION Organization(p_organization_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Primary_Item(p_primary_item_id IN NUMBER,
		      p_organization_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Program(p_program_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Wip_Entity(p_wip_entity_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Wip_Entity_Name(p_wip_entity_name IN VARCHAR2,
			 p_organization_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Alternate_Bom_Designator(p_alternate_bom_designator IN VARCHAR2,
				  p_organization_id          IN NUMBER)RETURN BOOLEAN;
FUNCTION Alternate_Rout_Designator(p_alternate_rout_designator IN VARCHAR2,
				   p_organization_id           IN NUMBER)RETURN BOOLEAN;
FUNCTION Bom_Revision(p_bom_revision      IN VARCHAR2,
		      p_inventory_item_id IN NUMBER,
		      p_organization_id   IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Bom_Revision_Date(p_bom_revision_date IN DATE)RETURN BOOLEAN;
FUNCTION Build_Sequence(p_build_sequence      IN NUMBER,
			p_wip_entity_id       IN NUMBER,
			p_organization_id     IN NUMBER,
			p_line_id             IN NUMBER,
			p_schedule_group_id   IN NUMBER)RETURN BOOLEAN;
FUNCTION Class(p_class_code      IN VARCHAR2,
	       p_organization_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Completion_Locator(p_completion_locator_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Completion_Subinventory(p_completion_subinventory IN VARCHAR2,
				 p_organization_id         IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Date_Closed(p_date_closed IN DATE)RETURN BOOLEAN;
-- FUNCTION Demand_Class(p_demand_class IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Source_Delivery(p_demand_source_delivery  IN VARCHAR2,
				p_demand_source_line      IN VARCHAR2,
				p_demand_source_header_id IN NUMBER,
				p_demand_source_type      IN NUMBER,
				p_inventory_item_id       IN NUMBER)RETURN BOOLEAN;
FUNCTION Demand_Source_Header(p_demand_source_header_id IN NUMBER,
			      p_demand_source_type      IN NUMBER,
			      p_inventory_item_id       IN NUMBER)RETURN BOOLEAN;
FUNCTION Demand_Source_Line(p_demand_source_line IN VARCHAR2,
			    p_demand_source_header_id IN NUMBER,
			    p_demand_source_type      IN NUMBER,
			    p_inventory_item_id       IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Demand_Source_Type(p_demand_source_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Kanban_Card(p_kanban_card_id   IN NUMBER,
		     p_organization_id  IN NUMBER)RETURN BOOLEAN;
FUNCTION Line(p_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Account(p_material_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Overhead_Account(p_material_overhead_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Variance_Account(p_material_variance_account IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Mps_Net_Quantity(p_mps_net_quantity IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Mps_Scheduled_Cpl_Date(p_mps_scheduled_cpl_date IN DATE)RETURN BOOLEAN;
FUNCTION Osp_Account(p_osp_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Osp_Variance_Account(p_osp_variance_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Overhead_Account(p_overhead_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Overhead_Variance_Account(p_overhead_variance_account IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Planned_Quantity(p_planned_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Project(p_project_id      IN NUMBER,
		 p_organization_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Quantity_Completed(p_quantity_completed IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Account(p_resource_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Variance_Account(p_resource_variance_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Routing_Revision(p_routing_revision  IN VARCHAR2,
			  p_inventory_item_id IN NUMBER,
			  p_organization_id   IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Routing_Revision_Date(p_routing_revision_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Scheduled_Completion_Date(p_scheduled_completion_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Scheduled(p_scheduled_flag IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Scheduled_Start_Date(p_scheduled_start_date IN DATE)RETURN BOOLEAN;
FUNCTION Schedule_Group(p_schedule_group_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Schedule_Number(p_schedule_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Status(p_status IN NUMBER)RETURN BOOLEAN;
FUNCTION Std_Cost_Adj_Account(p_std_cost_adj_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Task(p_task_id         IN NUMBER,
	      p_project_id      IN NUMBER,
	      p_organization_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Bom_Reference(p_bom_reference_id IN NUMBER,
		       p_organization_id  IN NUMBER)RETURN BOOLEAN;
FUNCTION Common_Bom_Sequence(p_common_bom_sequence_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Common_Rout_Sequence(p_common_rout_sequence_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Date_Completed(p_date_completed IN DATE)RETURN BOOLEAN;
-- FUNCTION Date_Released(p_date_released IN DATE)RETURN BOOLEAN;
FUNCTION Firm_Planned(p_firm_planned_flag IN NUMBER)RETURN BOOLEAN;
FUNCTION Job_Type(p_job_type IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Lot_Number(p_lot_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Net_Quantity(p_net_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Overcpl_Tolerance_Type(p_overcpl_tolerance_type IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Overcpl_Tolerance_Value(p_overcpl_tolerance_value IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Project_Costed(p_project_costed IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Quantity_Scrapped(p_quantity_scrapped IN NUMBER)RETURN BOOLEAN;
FUNCTION Routing_Reference(p_routing_reference_id IN NUMBER,
			   p_organization_id      IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Source(p_source_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Source_Line(p_source_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Start_Quantity(p_start_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Status_Type(p_status_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Wip_Supply_Type(p_wip_supply_type IN NUMBER)RETURN BOOLEAN;

-- FUNCTION Daily_Production_Rate(p_daily_production_rate IN NUMBER)RETURN BOOLEAN;
-- FUNCTION First_Unit_Cpl_Date(p_first_unit_cpl_date IN DATE)RETURN BOOLEAN;
-- FUNCTION First_Unit_Start_Date(p_first_unit_start_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Last_Unit_Cpl_Date(p_last_unit_cpl_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Last_Unit_Start_Date(p_last_unit_start_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Processing_Work_Days(p_processing_work_days IN NUMBER)RETURN BOOLEAN;
FUNCTION Repetitive_Schedule(p_repetitive_schedule_id IN NUMBER)RETURN BOOLEAN;

-- FUNCTION Dummy(p_dummy IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Acct_Period(p_acct_period_id IN NUMBER,
		     p_organization_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Allowed_Units_Lookup(p_allowed_units_lookup_code IN NUMBER)RETURN BOOLEAN;
FUNCTION Completion_Transaction(p_completion_transaction_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Containers(p_containers IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Cost_Group(p_cost_group_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Current_Loc_Control(p_current_loc_control_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Customer_Ship(p_customer_ship_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Cycle_Count(p_cycle_count_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Demand(p_demand_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Distribution_Account(p_distribution_account_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Encumbrance_Account(p_encumbrance_account IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Encumbrance_Amount(p_encumbrance_amount IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Error(p_error_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Error_Explanation(p_error_explanation IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Expected_Arrival_Date(p_expected_arrival_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Expenditure_Type(p_expenditure_type IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Final_Completion(p_final_completion_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Flow_Schedule(p_flow_schedule IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Freight(p_freight_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Inventory_Item(p_inventory_item_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Description(p_item_description IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Item_Inventory_Asset(p_item_inventory_asset_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Item_Loc_Control(p_item_loc_control_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Lot_Control(p_item_lot_control_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Ordering(p_item_ordering IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Primary_Uom(p_item_primary_uom_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Item_Restrict_Loc(p_item_restrict_loc_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Restrict_Subinv(p_item_restrict_subinv_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Rev_Qty_Control(p_item_rev_qty_control_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Segments(p_item_segments IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Item_Serial_Control(p_item_serial_control_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Shelf_Life(p_item_shelf_life_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Shelf_Life_Days(p_item_shelf_life_days IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Item_Trx_Enabled(p_item_trx_enabled_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Item_Uom_Class(p_item_uom_class IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Locator(p_locator_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Locator_Segments(p_locator_segments IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Lock_Flag(p_lock_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Lot_Alpha_Prefix(p_lot_alpha_prefix IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Lot_Expiration_Date(p_lot_expiration_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Material_Alloc_Temp(p_material_alloc_temp_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Movement(p_movement_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Negative_Req(p_negative_req_flag IN NUMBER)RETURN BOOLEAN;
-- FUNCTION New_Average_Cost(p_new_average_cost IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Next_Lot_Number(p_next_lot_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Next_Serial_Number(p_next_serial_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Number_Of_Lots_Entered(p_number_of_lots_entered IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Overcpl_Primary_Qty(p_overcpl_primary_qty IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Overcpl_Transaction(p_overcpl_transaction_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Overcpl_Transaction_Qty(p_overcpl_transaction_qty IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Pa_Expenditure_Org(p_pa_expenditure_org_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Percentage_Change(p_percentage_change IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Physical_Adjustment(p_physical_adjustment_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Picking_Line(p_picking_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Posting(p_posting_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Primary_Switch(p_primary_switch IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Process(p_process_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Process_Type(p_process_type IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Qa_Collection(p_qa_collection_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Receiving_Document(p_receiving_document IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Repetitive_Line(p_repetitive_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Required(p_required_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Req_Distribution(p_req_distribution_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Requisition_Line(p_requisition_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Reservation_Quantity(p_reservation_quantity IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Revision(p_revision IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Rma_Line(p_rma_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Schedule(p_schedule_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Schedule_Update(p_schedule_update_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Serial_Alpha_Prefix(p_serial_alpha_prefix IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Serial_Number(p_serial_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Setup_Teardown(p_setup_teardown_code IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Shipment_Number(p_shipment_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Shippable(p_shippable_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Shipped_Quantity(p_shipped_quantity IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Ship_To_Location(p_ship_to_location IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Source_Project(p_source_project_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Source_Task(p_source_task_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Subinventory(p_subinventory_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Supply_Locator(p_supply_locator_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Supply_Subinventory(p_supply_subinventory IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION To_Project(p_to_project_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION To_Task(p_to_task_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Action(p_transaction_action_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Cost(p_transaction_cost IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Date(p_transaction_date IN DATE)RETURN BOOLEAN;
-- FUNCTION Transaction_Header(p_transaction_header_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Line_Number(p_transaction_line_number IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Mode(p_transaction_mode IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Quantity(p_transaction_quantity IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Reference(p_transaction_reference IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Transaction_Sequence(p_transaction_sequence_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Source(p_transaction_source_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Source_Name(p_transaction_source_name IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Transaction_Src_Type(p_transaction_src_type_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transaction_Temp(p_transaction_temp_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transfer_Cost(p_transfer_cost IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transfer_Organization(p_transfer_organization IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transfer_Percentage(p_transfer_percentage IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transfer_Subinventory(p_transfer_subinventory IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Transfer_To_Location(p_transfer_to_location IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transportation_Account(p_transportation_account IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Transportation_Cost(p_transportation_cost IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Trx_Source_Delivery(p_trx_source_delivery_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Trx_Source_Line(p_trx_source_line_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Ussgl_Transaction(p_ussgl_transaction_code IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Valid_Locator(p_valid_locator_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Valid_Subinventory(p_valid_subinventory_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Value_Change(p_value_change IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Vendor_Lot_Number(p_vendor_lot_number IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Waybill_Airbill(p_waybill_airbill IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Wip_Commit(p_wip_commit_flag IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Wip_Entity_Type(p_wip_entity_type IN NUMBER)RETURN BOOLEAN;

FUNCTION Activity(p_activity_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Activity_Name(p_activity_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Actual_Resource_Rate(p_actual_resource_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Autocharge_Type(p_autocharge_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Basis_Type(p_basis_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Created_By_Name(p_created_by_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency(p_currency_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency_Conversion_Date(p_currency_conversion_date IN DATE)RETURN BOOLEAN;
FUNCTION Currency_Conversion_Rate(p_currency_conversion_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Currency_Conversion_Type(p_currency_conversion_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency_Actual_Rsc_Rate(p_currency_actual_rsc_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Department_Code(
	p_department_code IN VARCHAR2,
	p_organization_id IN NUMBER,
	p_attribute_name  IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION Department_Id (
	p_department_id IN NUMBER,
	p_attribute_name IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION Employee(p_employee_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Employee_Num(p_employee_num IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Group_Id(p_group_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Updated_By_Name(p_last_updated_by_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Move_Transaction(p_move_transaction_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Operation_Seq_Num(
	p_operation_seq_num IN NUMBER,
	p_attribute_name IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION Po_Header(p_po_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Po_Line(p_po_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Primary_Quantity(p_primary_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Primary_Uom(p_primary_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Primary_Uom_Class(p_primary_uom_class IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Process_Phase(
	p_process_phase IN NUMBER,
	p_lookup_type IN VARCHAR2)
  RETURN BOOLEAN;
FUNCTION Process_Status(p_process_status IN NUMBER)RETURN BOOLEAN;
FUNCTION Project_Number(p_project_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Rcv_Transaction(p_rcv_transaction_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reason(p_reason_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reason_Name(p_reason_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Receiving_Account(p_receiving_account_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reference(p_reference IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Resource_Code(
	p_resource_code IN VARCHAR2,
	p_organization_id IN NUMBER)
  RETURN BOOLEAN;
FUNCTION Resource_Id(p_resource_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Seq_Num(p_resource_seq_num IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Type(p_resource_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Standard_Rate(p_standard_rate_flag IN NUMBER)RETURN BOOLEAN;
FUNCTION Task_Number(p_task_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Transaction(p_transaction_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Usage_Rate_Or_Amount(p_usage_rate_or_amount IN NUMBER)RETURN BOOLEAN;

/**FUNCTION Fm_Department_Code(p_fm_department_code IN VARCHAR2, p_organization_id IN NUMBER)RETURN BOOLEAN; **/
/**FUNCTION Fm_Department_Id(p_fm_department_id IN NUMBER)RETURN BOOLEAN; **/
/**FUNCTION Fm_Intraop_Step_Type(p_fm_intraop_step_type IN NUMBER)RETURN BOOLEAN;**/
/**FUNCTION Fm_Operation(p_fm_operation_code IN VARCHAR2)RETURN BOOLEAN; **/
/**FUNCTION Fm_Operation_Seq_Num(p_fm_operation_seq_num IN NUMBER)RETURN BOOLEAN;**/
FUNCTION Intraop_Step_Type(
	p_intraop_step_type IN NUMBER,
	p_attribute_name       IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION Kanban(p_kanban_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Operation_Code(
	p_operation_code IN VARCHAR2,
	p_attribute_name IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION Overcompletion(p_overcompletion_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Overmove_Txn_Qty(p_overmove_txn_qty IN NUMBER)RETURN BOOLEAN;
FUNCTION Scrap_Account(p_scrap_account_id IN NUMBER)RETURN BOOLEAN;
/**FUNCTION To_Department_Code(p_to_department_code IN VARCHAR2, p_organization_id IN NUMBER)RETURN BOOLEAN; **/
/*FUNCTION To_Department_Id(p_to_department_id IN NUMBER)RETURN BOOLEAN; */
/*FUNCTION To_Intraop_Step_Type(p_to_intraop_step_type IN NUMBER)RETURN BOOLEAN;*/
/**FUNCTION To_Operation(p_to_operation_code IN VARCHAR2)RETURN BOOLEAN; **/
/** FUNCTION To_Operation_Seq_Num(p_to_operation_seq_num IN NUMBER)RETURN BOOLEAN; **/
FUNCTION Transaction_Link(p_transaction_link_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Transaction_Type(
	p_transaction_type_id IN NUMBER,
	p_lookup_type IN VARCHAR2)
  RETURN BOOLEAN;
FUNCTION Transaction_Uom(p_transaction_uom IN VARCHAR2)RETURN BOOLEAN;

-- FUNCTION Currency_Act_Rsc_Rate(p_currency_act_rsc_rate IN NUMBER)RETURN BOOLEAN;

--  END GEN validate

END WIP_Validate;

 

/
