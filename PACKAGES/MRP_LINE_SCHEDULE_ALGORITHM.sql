--------------------------------------------------------
--  DDL for Package MRP_LINE_SCHEDULE_ALGORITHM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_LINE_SCHEDULE_ALGORITHM" AUTHID CURRENT_USER AS
/* $Header: MRPLSCHS.pls 120.0.12010000.1 2008/07/28 04:48:18 appldev ship $ */

C_EXT_SALES_ORDER    CONSTANT NUMBER := 2;
C_INT_SALES_ORDER    CONSTANT NUMBER := 8;
C_PLANNED_ORDER      CONSTANT NUMBER := 100;
C_YES                CONSTANT NUMBER := 1;
C_NO                 CONSTANT NUMBER := 3;
C_VAR		     CONSTANT NUMBER := 1;
C_SO_DEMAND	     CONSTANT NUMBER := 5;
C_PO_DEMAND 	     CONSTANT NUMBER := 3;
C_CRITERIA_ID	     CONSTANT NUMBER := 1;
C_NO_LEVEL_LOAD	     CONSTANT NUMBER := 3;
C_LEVEL_LOAD	     CONSTANT NUMBER := 2;
C_MIXED_MODEL	     CONSTANT NUMBER := 1;
C_ROUND_TYPE	     CONSTANT NUMBER := 1;
C_USER_DEFINE_NO     CONSTANT NUMBER := 2;
C_ASC		     CONSTANT NUMBER := 1;
C_DESC		     CONSTANT NUMBER := 2;
C_ITEM		     CONSTANT NUMBER := 2;
C_NORM		     CONSTANT NUMBER := 1;
C_COMPLETE	     CONSTANT NUMBER := 2;
C_DATE_ON	     CONSTANT NUMBER := 1;

-- This table holds the NET capacity for each date (indexed by dates) as well
-- as the completion time of the last scheduled flow schedule.

TYPE CapRecTyp IS RECORD (
	capacity      NUMBER);

TYPE CapTabTyp IS TABLE OF CapRecTyp
	INDEX BY BINARY_INTEGER;

-- This table stores the latest time in the day where a flow schedule is
-- scheduled, indexed by the date

TYPE TimeRecTyp IS RECORD (
	start_completion_time  NUMBER,
	end_completion_time  NUMBER);

TYPE TimeTabTyp IS TABLE OF TimeRecTyp
	INDEX BY BINARY_INTEGER;

-- This table stores the highest sequence for each schedule group
-- indexed by the schedule group id

TYPE BuildSeqTyp IS RECORD (
	buildseq NUMBER);

TYPE BuildSeqTabTyp IS TABLE OF BuildSeqTyp
	INDEX BY BINARY_INTEGER;

-- This table store the order modifier restrictions for each item
-- indexed by the item id

TYPE OrderModTyp IS RECORD (
	minVal	NUMBER,
	maxVal	NUMBER);

TYPE OrderModTabTyp IS TABLE OF OrderModTyp
	INDEX BY BINARY_INTEGER;

-- This table stores for each item, the quantity remaining from the
-- newest flow schedule with order modifiers that can be used to
-- schedule the original schedules.  The table is indexed by the item id.
-- The table also stores a column which is a flag indicating
-- if at least one flow schedule has been created for this item.

TYPE ItemQtyTyp IS RECORD (
	remainQty	NUMBER,
	wip_id		NUMBER);

TYPE ItemQtyTabTyp IS TABLE OF ItemQtyTyp
	INDEX BY BINARY_INTEGER;

-- This table stores the total demand and demand ratio for each item.
-- The table also stores the round type of the item. 1 - round, 2 - no round.

TYPE DemandRecTyp IS RECORD (
	totalDemand  NUMBER,
	roundType    NUMBER,
	sequence     NUMBER);

TYPE DemandTabTyp IS TABLE OF DemandRecTyp
	INDEX BY BINARY_INTEGER;

TYPE fs_select_type IS RECORD(
   	wip_entity number,
   	creation_date date,
   	schedule_date date,
   	promise_date date,
   	request_date date,
   	planning_priority number,
   	primary_item_id number,
   	planned_quantity number,
   	schedule_group_id number);

-- This table stores the relevant columns of the wip flow schedules table.
-- This table is used in the mix model algorithm for performance improvement.

TYPE FlowScheduleTyp IS RECORD (
  	scheduled_flag			NUMBER,
 	organization_id 		NUMBER,
	last_update_date		DATE,
 	last_updated_by			NUMBER,
	creation_date			DATE,
	created_by			NUMBER,
	class_code			VARCHAR2(10),
	line_id				NUMBER,
	primary_item_id			NUMBER,
 	scheduled_start_date		DATE,
	planned_quantity		NUMBER,
	quantity_completed		NUMBER,
	scheduled_completion_date 	DATE,
	schedule_group_id		NUMBER,
	build_sequence			NUMBER,
	status				NUMBER,
 	schedule_number			VARCHAR2(30),
	demand_source_header_id		NUMBER,
	demand_source_line		VARCHAR2(30),
	demand_source_delivery	 	VARCHAR2(30),
	demand_source_type		NUMBER,
	project_id			NUMBER,
	task_id				NUMBER,
        end_item_unit_number		VARCHAR2(30),
	request_id			NUMBER,
        attribute1                      VARCHAR2(150),
        attribute2                      VARCHAR2(150),
        attribute3                      VARCHAR2(150),
        attribute4                      VARCHAR2(150),
        attribute5                      VARCHAR2(150),
        attribute6                      VARCHAR2(150),
        attribute7                      VARCHAR2(150),
        attribute8                      VARCHAR2(150),
        attribute9                      VARCHAR2(150),
        attribute10                     VARCHAR2(150),
        attribute11                     VARCHAR2(150),
        attribute12                     VARCHAR2(150),
        attribute13                     VARCHAR2(150),
        attribute14                     VARCHAR2(150),
        attribute15                     VARCHAR2(150),
        material_account                NUMBER,
        material_overhead_account       NUMBER,
        resource_account                NUMBER,
        outside_processing_account      NUMBER,
        material_variance_account       NUMBER,
        resource_variance_account       NUMBER,
        outside_proc_var_account        NUMBER,
        std_cost_adjustment_account     NUMBER,
        overhead_account                NUMBER,
        overhead_variance_account       NUMBER,
        bom_revision                    VARCHAR2(3),  /* 2185087 */
        routing_revision                VARCHAR2(3),
        bom_revision_date               DATE,
        routing_revision_date           DATE,
        alternate_bom_designator        VARCHAR2(10),
        alternate_routing_designator    VARCHAR2(10),
        completion_subinventory         VARCHAR2(30),
        completion_locator_id           NUMBER ,
        demand_class                    VARCHAR2(30),
        attribute_category              VARCHAR2(30),
        kanban_card_id                  NUMBER
);

TYPE FlowScheduleTabTyp IS TABLE OF FlowScheduleTyp
	INDEX BY BINARY_INTEGER;


-- This table stores the remaining quantity to be allocated for each item
-- on the date.  The table is indexed by item id

TYPE ItemAllocTyp IS RECORD (
	date		NUMBER,
	remainQty	NUMBER,
	complete_flag	NUMBER);

TYPE ItemAllocTabTyp IS TABLE OF ItemAllocTyp
	INDEX BY BINARY_INTEGER;

-- This table is used by the mixed model algorithm.  It stores the item
-- and the total demand for the item, but sorted in a descending order
-- with the item of the highest demand to item of the lowest demand.

TYPE ItemDemandTyp IS RECORD (
	item		NUMBER,
	qty		NUMBER,
	fixed_lead_time	NUMBER,
	var_lead_time	NUMBER);

TYPE ItemDemandTabTyp IS TABLE OF ItemDemandTyp
	INDEX BY BINARY_INTEGER;

TYPE pat_rec IS RECORD (
    	curr_pattern 	LONG,
      	pos        	NUMBER);

 TYPE pat_tab_type IS TABLE OF pat_rec
	INDEX BY BINARY_INTEGER;

-- variable holds the mode of operation
  V_MODE NUMBER := C_PLANNED_ORDER;

-- variable holds the global demand in this scheduling run
  V_GLOBAL_DEMAND NUMBER := 1;

-- variable holds the query id used in mrp_form_query table
  V_QUERY_ID NUMBER := 1;

-- variable holds the package name used for error messages
  V_PKG_NAME VARCHAR2(30) := 'MRP_LINE_SCHEDULE_ALGORITHM';

-- variable holds the error line number used for error messages
  V_ERROR_LINE NUMBER := 1;

-- variable holds the procedure name used for error messates
  V_PROCEDURE_NAME VARCHAR2(30) := 'PROCEDURE NAME';

	FUNCTION Create_Cursor(	p_rule_id IN NUMBER,
				p_org_id IN NUMBER,
				p_line_id IN NUMBER,
				p_order IN NUMBER,
				p_type IN NUMBER,
				p_item_id IN NUMBER) RETURN INTEGER;

  	PROCEDURE calculate_linecap(
				p_line_id IN NUMBER,
 				p_org_id IN NUMBER,
 				p_flex_tolerance IN NUMBER,
                                p_cap_tab IN OUT NOCOPY CapTabTyp,
				p_time_tab IN TimeTabTyp,
                                p_schedule_start_date IN NUMBER,
                                p_schedule_start_time IN NUMBER,
                                p_schedule_end_date IN NUMBER,
                                p_schedule_end_time IN NUMBER);

	FUNCTION order_scheduling_rule(
				p_rule_id IN NUMBER,
				p_order IN NUMBER) RETURN VARCHAR2;

	PROCEDURE calculate_order_quantities(
				p_org_id  IN NUMBER,
				p_order_mod_tab IN OUT NOCOPY OrderModTabTyp);

	PROCEDURE calculate_build_sequences(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
				p_build_seq_tab IN OUT NOCOPY BuildSeqTabTyp);

	PROCEDURE time_existing_fs(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
                                p_schedule_start_date IN NUMBER,
                                p_schedule_start_time IN NUMBER,
                                p_schedule_end_date IN NUMBER,
                                p_schedule_end_time IN NUMBER,
				p_time_tab IN OUT NOCOPY TimeTabTyp);

	PROCEDURE create_po_fs(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_orderMod_tab IN OUT NOCOPY OrderModTabTyp);

	PROCEDURE rounding_process(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_demand_tab IN OUT NOCOPY DemandTabTyp);

	PROCEDURE schedule_orders (
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN DemandTabTyp,
				p_time_tab IN OUT NOCOPY TimeTabTyp);

	PROCEDURE calculate_production_plan(
				p_org_id IN NUMBER,
				p_line_id IN NUMBER,
				p_first_date IN DATE,
				p_last_date IN DATE,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN OUT NOCOPY DemandTabTyp);

	PROCEDURE schedule_orders_level (
				p_line_id IN NUMBER,
				p_org_id  IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
				p_time_tab IN OUT NOCOPY TimeTabTyp);

	PROCEDURE update_buildseq (
				p_line_id IN NUMBER,
				p_org_id  IN NUMBER);

	PROCEDURE schedule_mix_model (
				p_line_id IN NUMBER,
				p_org_id  IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN OUT NOCOPY DemandTabTyp,
				p_item_demand_tab IN ItemDemandTabTyp,
				p_time_tab IN OUT NOCOPY TimeTabTyp);

	PROCEDURE Schedule(
	         		p_rule_id  IN NUMBER,
             	     		p_line_id  IN NUMBER,
             	     		p_org_id   IN NUMBER,
             	     		p_scheduling_start_date IN DATE,
             	     		p_scheduling_end_date   IN DATE,
             	     		p_flex_tolerance   IN NUMBER,
				x_return_status OUT NOCOPY VARCHAR2,
			 	x_msg_count OUT NOCOPY NUMBER,
  		    		x_msg_data  OUT NOCOPY VARCHAR2);

	FUNCTION mix_model(
				p_item_demand_tab IN ItemDemandTabTyp)
				RETURN LONG;

	PROCEDURE calculate_demand (
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_demand_tab IN OUT NOCOPY DemandTabTyp);


	PROCEDURE calculate_demand_mix (
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_item_demand_tab IN OUT NOCOPY ItemDemandTabTyp);

	FUNCTION calculate_begin_time (
				p_org_id	IN NUMBER,
				p_completion_date IN DATE,
				p_lead_time	IN NUMBER,
				p_start_time	IN NUMBER,
				p_end_time	IN NUMBER) RETURN DATE;

        FUNCTION calculate_completion_time(
				p_org_id	IN NUMBER,
				p_item_id	IN NUMBER,
				p_qty		IN NUMBER,
				p_line_id	IN NUMBER,
				p_start_date IN DATE) RETURN DATE;

END MRP_LINE_SCHEDULE_ALGORITHM;

/
