--------------------------------------------------------
--  DDL for Package MRP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: MRPSVATS.pls 115.5 99/07/16 12:38:05 porting ship $ */

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
FUNCTION Alternate_Bom_Designator(p_alternate_bom_designator IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Alternate_Routing_Desig(p_alternate_routing_desig IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Bom_Revision(p_bom_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Bom_Revision_Date(p_bom_revision_date IN DATE)RETURN BOOLEAN;
FUNCTION Build_Sequence(p_build_sequence IN NUMBER)RETURN BOOLEAN;
FUNCTION Class(p_class_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Completion_Locator(p_completion_locator_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Completion_Subinventory(p_completion_subinventory IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
FUNCTION Date_Closed(p_date_closed IN DATE)RETURN BOOLEAN;
FUNCTION Demand_Class(p_demand_class IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Source_Delivery(p_demand_source_delivery IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Source_Header(p_demand_source_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Demand_Source_Line(p_demand_source_line IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Source_Type(p_demand_source_type IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION Line(p_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Account(p_material_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Overhead_Account(p_material_overhead_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Material_Variance_Account(p_material_variance_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Mps_Net_Quantity(p_mps_net_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Mps_Scheduled_Comp_Date(p_mps_scheduled_comp_date IN DATE)RETURN BOOLEAN;
FUNCTION Organization(p_organization_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Outside_Processing_Acct(p_outside_processing_acct IN NUMBER)RETURN BOOLEAN;
FUNCTION Outside_Proc_Var_Acct(p_outside_proc_var_acct IN NUMBER)RETURN BOOLEAN;
FUNCTION Overhead_Account(p_overhead_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Overhead_Variance_Account(p_overhead_variance_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Planned_Quantity(p_planned_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Primary_Item(p_primary_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program(p_program_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Project(p_project_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Quantity_Completed(p_quantity_completed IN NUMBER)RETURN BOOLEAN;
FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Account(p_resource_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Resource_Variance_Account(p_resource_variance_account IN NUMBER)RETURN BOOLEAN;
FUNCTION Routing_Revision(p_routing_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Routing_Revision_Date(p_routing_revision_date IN DATE)RETURN BOOLEAN;
FUNCTION Scheduled_Completion_Date(p_scheduled_completion_date IN DATE)RETURN BOOLEAN;
FUNCTION Scheduled(p_scheduled_flag IN NUMBER)RETURN BOOLEAN;
FUNCTION Scheduled_Start_Date(p_scheduled_start_date IN DATE)RETURN BOOLEAN;
FUNCTION Schedule_Group(p_schedule_group_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Schedule_Number(p_schedule_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Status(p_status IN NUMBER)RETURN BOOLEAN;
FUNCTION Std_Cost_Adjustment_Acct(p_std_cost_adjustment_acct IN NUMBER)RETURN BOOLEAN;
FUNCTION Task(p_task_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Wip_Entity(p_wip_entity_id IN NUMBER)RETURN BOOLEAN;
FUNCTION End_Item_Unit_Number(p_end_item_unit_number IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Quantity_Scrapped(p_quantity_scrapped IN NUMBER) RETURN BOOLEAN;

FUNCTION Assignment_Set
(   p_Assignment_Set_Id             IN  NUMBER
)  RETURN BOOLEAN;

FUNCTION Assignment
(   p_Assignment_Id                 IN  NUMBER
)  RETURN BOOLEAN;

FUNCTION Sourcing_Rule
(   p_Sourcing_Rule_Id              IN  NUMBER
)  RETURN BOOLEAN;

FUNCTION Receiving_Org
(   p_Sr_Receipt_Id                 IN  NUMBER
)  RETURN BOOLEAN;

FUNCTION Shipping_Org
(   p_Sr_Source_Id                  IN  NUMBER
)  RETURN BOOLEAN;

--  END GEN validate

END MRP_Validate;

 

/
