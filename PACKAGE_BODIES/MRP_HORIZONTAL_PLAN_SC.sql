--------------------------------------------------------
--  DDL for Package Body MRP_HORIZONTAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_HORIZONTAL_PLAN_SC" AS
/*  $Header: MRPPHOPB.pls 120.9 2008/01/13 23:34:05 schaudha ship $ */

SYS_YES  CONSTANT INTEGER := 1;
SYS_NO   CONSTANT INTEGER := 2;

PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* order type lookup  */
PURCH_REQ           CONSTANT INTEGER := 2;
WORK_ORDER          CONSTANT INTEGER := 3;
REPETITIVE_SCHEDULE CONSTANT INTEGER := 4;
PLANNED_ORDER       CONSTANT INTEGER := 5;
MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
NONSTD_JOB          CONSTANT INTEGER := 7;
RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
REQUIREMENT         CONSTANT INTEGER := 9;
FPO_SUPPLY          CONSTANT INTEGER := 10;
SHIPMENT            CONSTANT INTEGER := 11;
RECEIPT_SHIPMENT    CONSTANT INTEGER := 12;
DIS_JOB_BY      CONSTANT INTEGER := 14;
NON_ST_JOB_BY       CONSTANT INTEGER := 15;
REP_SCHED_BY        CONSTANT INTEGER := 16;
PLANNED_BY      CONSTANT INTEGER := 17;
FLOW_SCHED      CONSTANT INTEGER := 27;
FLOW_SCHED_BY	CONSTANT INTEGER := 28;
PAYBACK_SUPPLY       CONSTANT INTEGER :=29;


SALES               CONSTANT INTEGER := 10;  /* horizontal plan type lookup */
FORECAST            CONSTANT INTEGER := 20;
DEPENDENT           CONSTANT INTEGER := 30;
SCRAP               CONSTANT INTEGER := 40;
PB_DEMAND           CONSTANT INTEGER := 45;
OTHER               CONSTANT INTEGER := 50;
GROSS               CONSTANT INTEGER := 70;
WIP                 CONSTANT INTEGER := 81;
FLOW_SCHEDULE		CONSTANT INTEGER := 82;
PO                  CONSTANT INTEGER := 83;
REQ                 CONSTANT INTEGER := 85;
TRANSIT             CONSTANT INTEGER := 87;
RECEIVING           CONSTANT INTEGER := 89;
PLANNED             CONSTANT INTEGER := 90;
PB_SUPPLY           CONSTANT INTEGER := 95;
SUPPLY              CONSTANT INTEGER := 100;
ON_HAND             CONSTANT INTEGER := 105;
PAB                 CONSTANT INTEGER := 110;
SS                  CONSTANT INTEGER := 120;
ATP                 CONSTANT INTEGER := 130;
CURRENT_S           CONSTANT INTEGER := 140;
POH                 CONSTANT INTEGER := 150;
EXP_LOT             CONSTANT INTEGER := 160;
TARGET_SS           CONSTANT INTEGER := 125;

SALES_OFF           CONSTANT INTEGER := 1; /* offsets */
FORECAST_OFF        CONSTANT INTEGER := 2;
DEPENDENT_OFF       CONSTANT INTEGER := 3;
SCRAP_OFF           CONSTANT INTEGER := 4;
PB_DEMAND_OFF       CONSTANT INTEGER := 5;
OTHER_OFF           CONSTANT INTEGER := 6;
GROSS_OFF           CONSTANT INTEGER := 7;
WIP_OFF             CONSTANT INTEGER := 8;
PO_OFF              CONSTANT INTEGER := 9;
REQ_OFF             CONSTANT INTEGER := 10;
TRANSIT_OFF         CONSTANT INTEGER := 11;
RECEIVING_OFF       CONSTANT INTEGER := 12;
PLANNED_OFF         CONSTANT INTEGER := 13;
PB_SUPPLY_OFF       CONSTANT INTEGER := 14;
SUPPLY_OFF          CONSTANT INTEGER := 15;
ON_HAND_OFF         CONSTANT INTEGER := 16;
PAB_OFF             CONSTANT INTEGER := 17;
SS_OFF              CONSTANT INTEGER := 18;
ATP_OFF             CONSTANT INTEGER := 19;
CURRENT_S_OFF       CONSTANT INTEGER := 20;
POH_OFF             CONSTANT INTEGER := 21;
EXP_LOT_OFF         CONSTANT INTEGER := 22;

NUM_OF_TYPES        CONSTANT INTEGER := 22;
NUM_OF_COLUMNS      CONSTANT INTEGER := 36;

/* WIP job status lookups */
JOB_UNRELEASED          CONSTANT INTEGER := 1;
JOB_RELEASED            CONSTANT INTEGER := 3;
JOB_COMPLETE            CONSTANT INTEGER := 4;
JOB_HOLD                        CONSTANT INTEGER := 6;

/* Schedule Level */
UPDATED_SCHEDULE        CONSTANT INTEGER := 2;

/* Schedule supply demand */
SCHEDULE_DEMAND         CONSTANT INTEGER := 1;
SCHEDULE_SUPPLY         CONSTANT INTEGER := 2;

/* Independent demand types for Current Data */
IDT_SCHEDULE            CONSTANT INTEGER := 1;
IDT_FORECAST        CONSTANT INTEGER := 2;

/* forecast buckets */
DAILY_BUCKET            CONSTANT INTEGER := 1;
WEEKLY_BUCKET           CONSTANT INTEGER := 2;
MONTHLY_BUCKET          CONSTANT INTEGER := 3;

/* MRP demand types */
DEMAND_PLANNED_ORDER CONSTANT INTEGER := 1;
DEMAND_OPTIONAL         CONSTANT INTEGER := 22;
DEMAND_PAYBACK          CONSTANT INTEGER := 27;

/* Rounding control */
DO_ROUND                        CONSTANT INTEGER := 1;
DO_NOT_ROUND            CONSTANT INTEGER := 2;

/* safety stock code */
NON_MRP_PCT             CONSTANT INTEGER := 1;

/* lot control */
FULL_LOT_CONTROL        CONSTANT INTEGER := 2;

/* sub inventory type */
NETTABLE                        CONSTANT INTEGER := 1;

/*MTL_DEMAND types */
SALES_ORDER             CONSTANT INTEGER := 2;

/* input designator type */
MDS_DESIGNATOR_TYPE     CONSTANT INTEGER := 1;


function compute_daily_rate_t
                    (var_calendar_code varchar2,
                     var_exception_set_id number,
                     var_daily_production_rate number,
                     var_quantity_completed number,
                     fucd date,
                     var_date date) return number is
var_tot_completed number ;
var_diff number ;
var_change number ;
var_prior_completed number ;
var_ret_val number ;
var_fucd_seq number ;
var_lucd_seq number ;
Begin
    select cal.prior_seq_num
    into   var_fucd_seq
    FROM    bom_calendar_dates  cal
    WHERE   cal.exception_set_id = var_exception_set_id
    AND   cal.calendar_code = var_calendar_code
    AND   cal.calendar_date = TRUNC(fucd) ;

    select cal.prior_seq_num
    into   var_lucd_seq
    FROM    bom_calendar_dates  cal
    WHERE   cal.exception_set_id = var_exception_set_id
    AND   cal.calendar_code = var_calendar_code
    AND   cal.calendar_date = TRUNC(var_date) ;

    var_diff := ABS(var_fucd_seq - var_lucd_seq) + 1 ;

    var_tot_completed := var_diff * var_daily_production_rate ;

    if (var_tot_completed <= var_quantity_completed)
    then
        var_ret_val := 0;
        return(var_ret_val);
    end if;

    var_prior_completed := var_daily_production_rate * (var_diff -1) ;

    var_change := var_quantity_completed - var_prior_completed ;

    if (var_change > 0 )
    then
        var_ret_val := var_daily_production_rate - var_change ;
    else
        var_ret_val := var_daily_production_rate  ;
    end if;

    return(var_ret_val);
end ;

/* 2663505 - Removed defaulting of arg_current_data, arg_res_level
according to PL/SQL stds. since we always pass these parameters */

Procedure populate_horizontal_plan (item_list_id IN NUMBER,
                             arg_plan_id IN NUMBER,
                             arg_organization_id IN NUMBER,
                             arg_compile_designator IN VARCHAR2,
                             arg_plan_organization_id IN NUMBER,
                             arg_bucket_type IN NUMBER,
                             arg_cutoff_date IN DATE,
                             arg_current_data IN NUMBER,
                             arg_ind_demand_type IN NUMBER DEFAULT NULL,
                             arg_source_list_name IN VARCHAR2 DEFAULT NULL,
                             enterprize_view IN BOOLEAN,
                             arg_res_level IN NUMBER,
                             arg_resval1 IN VARCHAR2 DEFAULT NULL,
                             arg_resval2 IN NUMBER DEFAULT NULL) IS
-- -----------------------------------------
-- This cursor selects row type information.
-- -----------------------------------------
/* Added TARGET_SS in where clause for bug 1976800 */
/* Added lookup_code 25,97 for bug 3565869 */
CURSOR row_types IS
 SELECT meaning,
       lookup_code
FROM   mfg_lookups
WHERE  lookup_type = 'MRP_HORIZONTAL_PLAN_TYPE_SC'
AND    lookup_code NOT IN (FLOW_SCHEDULE,TARGET_SS,25,97)  /* Flow Schedules shown under WIP at
									   present. However there is an order
									   type defined for flow schedules.
									   This condition needs to be removed
									   in the future when flow schedules
									   will be shown separately in the
									   Horizontal Plan. */
ORDER BY lookup_code;

row_type_rec    row_types%ROWTYPE;

last_date       DATE;
sid             NUMBER;
l_oe_install varchar2(5):='OE';


-- ------------------------------------------------------------
-- BUG # 2792927
-- Declare Global Variable to store the value
-- of the profile option - Inventory Supplier Consigned Enabled.
-- -------------------------------------------------------------

CURSOR  mrp_current_activity_ont_I IS
------------------------
---   WIP Discrete Jobs
-----------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        WIP row_type,
        WIP_OFF offset,
        jobs.scheduled_completion_date new_date,
        jobs.scheduled_completion_date old_date,
        SUM(GREATEST( 0, (jobs.net_quantity - jobs.quantity_completed
                        - jobs.quantity_scrapped))) new_quantity,
        SUM(GREATEST( 0, (jobs.net_quantity - jobs.quantity_completed
                        - jobs.quantity_scrapped))) old_quantity
FROM    mrp_form_query list,
        wip_discrete_jobs jobs,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
               AND jobs.project_id is NULL)
         OR  (DECODE(arg_res_level,
        3,nvl(mrp_get_project.planning_group(jobs.project_id),'-23453'),
        4,nvl(to_char(jobs.project_id), '-23453'))
                                                  = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(jobs.project_id), '-23453')
                                                  = nvl(arg_resval1,'-23453')
               AND  nvl(jobs.task_id, -23453) = nvl(arg_resval2, -23453)))
and     jobs.organization_id = items.organization_id
and     jobs.primary_item_id = items.inventory_item_id
and     jobs.status_type IN (JOB_UNRELEASED,
                JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     jobs.scheduled_completion_date < last_date
and     jobs.net_quantity > 0
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      jobs.completion_subinventory = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        WIP,
        WIP_OFF,
        jobs.scheduled_completion_date,
        jobs.scheduled_completion_date
UNION ALL
--------------------------
---  Discrete Job Scrap
--------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        SCRAP row_type,
        SCRAP_OFF offset,
        jobs.scheduled_completion_date new_date,
        jobs.scheduled_completion_date old_date,
        SUM(GREATEST(0, (jobs.net_quantity - jobs.quantity_completed
        - jobs.quantity_scrapped))*NVL(items.shrinkage_rate, 0))  new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        wip_discrete_jobs jobs,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR (arg_res_level = 2
              AND jobs.project_id is NULL)
         OR  (DECODE(arg_res_level,
               3,nvl(mrp_get_project.planning_group(jobs.project_id),'-23453'),
               4,nvl(to_char(jobs.project_id), '-23453'))
                                               = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
              AND  nvl(to_char(jobs.project_id), '-23453')
                                        = nvl(arg_resval1,'-23453')
              AND  nvl(jobs.task_id, -23453) = nvl(arg_resval2, -23453)))
and     jobs.organization_id = items.organization_id
and     jobs.primary_item_id = items.inventory_item_id
and     jobs.status_type IN (JOB_UNRELEASED,
        JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     jobs.scheduled_completion_date < last_date
and     jobs.net_quantity > 0
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      jobs.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        SCRAP,
        SCRAP_OFF,
        jobs.scheduled_completion_date,
        jobs.scheduled_completion_date,
        0
UNION ALL
-----------------------------
--- Discrete Job Requirements
-----------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        DEPENDENT row_type,
        DEPENDENT_OFF offset,
        ops.date_required new_date,
        ops.date_required old_date,
        SUM(ops.required_quantity - ops.quantity_issued -
            (NVL(wo.cumulative_scrap_quantity,0)*NVL(ops.quantity_per_assembly, 1))
               ) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
		wip_operations wo,
        wip_requirement_operations ops,
        wip_discrete_jobs jobs,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
                AND jobs.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(jobs.project_id),'-23453'),
                4,nvl(to_char(jobs.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
              AND  nvl(to_char(jobs.project_id), '-23453')
                                                 = nvl(arg_resval1,'-23453')
              AND nvl(jobs.task_id, -23453) = nvl(arg_resval2, -23453)))
and     ops.organization_id = items.organization_id
and     ops.inventory_item_id = items.inventory_item_id
and     ( NVL(ops.quantity_issued, 0) <
                        NVL(ops.mps_required_quantity, 0)
          OR (ops.mps_required_quantity < 0 ))
and     jobs.organization_id  = ops.organization_id
and     jobs.wip_entity_id  = ops.wip_entity_id
and          jobs.status_type IN (JOB_UNRELEASED,
                JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     ops.date_required < last_date
and     ops.mrp_net_flag = SYS_YES
and     ops.wip_supply_type <> 6
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      jobs.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND     ops.wip_entity_id  = wo.wip_entity_id (+)
AND     ops.organization_id = wo.organization_id (+)
AND     ops.operation_seq_num =wo.operation_seq_num (+)
AND     NVL(ops.repetitive_schedule_id,0) = NVL(wo.repetitive_schedule_id (+) ,0)
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        DEPENDENT,
        DEPENDENT_OFF,
        ops.date_required,
        ops.date_required,
        0
UNION ALL
---------------------------------
--- Flow Schedules
---------------------------------
SELECT
    items.inventory_item_id item_id,
    items.organization_id org_id,
    WIP row_type,
    WIP_OFF offset,
    flow_sched.scheduled_completion_date new_date,
    flow_sched.scheduled_completion_date old_date,
	SUM(GREATEST( 0, (flow_sched.planned_quantity -
							  flow_sched.quantity_completed))) new_quantity,
    SUM(GREATEST( 0, (flow_sched.planned_quantity -
                          flow_sched.quantity_completed))) old_quantity
FROM    mrp_form_query list,
        wip_flow_schedules flow_sched,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE  (arg_res_level = 1
    OR  (arg_res_level = 2
            AND flow_sched.project_id is NULL)
    OR  (DECODE(arg_res_level,
        3,nvl(mrp_get_project.planning_group(flow_sched.project_id),'-23453'),
        4,nvl(to_char(flow_sched.project_id), '-23453'))
                           = nvl(arg_resval1,'-23453'))
    OR  (arg_res_level = 5
            AND  nvl(to_char(flow_sched.project_id), '-23453')
                    = nvl(arg_resval1,'-23453')
            AND  nvl(flow_sched.task_id, -23453) = nvl(arg_resval2, -23453)))
and     flow_sched.organization_id = items.organization_id
and     flow_sched.primary_item_id = items.inventory_item_id
and     flow_sched.scheduled_completion_date < last_date
and		flow_sched.scheduled_completion_date >= trunc(sysdate)
and     flow_sched.planned_quantity > 0
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      flow_sched.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        WIP,
        WIP_OFF,
        flow_sched.scheduled_completion_date,
        flow_sched.scheduled_completion_date
UNION ALL
-----------------------------------
---- Flow schedule demand
----------------------------------
SELECT
		items.inventory_item_id item_id,
		items.organization_id org_id,
		DEPENDENT type,
		DEPENDENT_OFF offset,
		dates.calendar_date new_date,
		dates.calendar_date old_date,
		SUM(GREATEST(0, ((nvl(fs.planned_quantity, 0) -
						      nvl(fs.quantity_completed, 0)) *
			 (bic.component_quantity/bic.component_yield_factor)
				* bic.planning_factor/100))) new_quantity,
		SUM(GREATEST(0, ((nvl(fs.planned_quantity, 0) -
								  nvl(fs.quantity_completed, 0)) *
			  (bic.component_quantity/bic.component_yield_factor)
				* bic.planning_factor/100))) old_quantity
FROM	bom_calendar_dates dates,
		mtl_parameters mp,
		wip_flow_schedules fs,
		mrp_system_items msi_assy,
		bom_bill_of_materials bbm,
		bom_inventory_components bic,
		mrp_system_items items,
		mrp_form_query list,
                mrp_sub_inventories msi
WHERE  (arg_res_level = 1
		OR  (arg_res_level = 2
			AND fs.project_id is NULL)
		OR  (DECODE(arg_res_level,
				3,nvl(mrp_get_project.planning_group(fs.project_id),'-23453'),
				4,nvl(to_char(fs.project_id), '-23453'))
							   = nvl(arg_resval1,'-23453'))
	    OR  (arg_res_level = 5
			   AND  nvl(to_char(fs.project_id), '-23453')
				   	= nvl(arg_resval1,'-23453')
		  		AND  nvl(fs.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     dates.seq_num is not null
AND		dates.calendar_date < last_date
AND 	dates.seq_num  =
						(select c2.prior_seq_num -
					 ceil((1- nvl(bic.operation_lead_time_percent, 0)/100) *
							(nvl(msi_assy.fixed_lead_time, 0) +
							((fs.planned_quantity - fs.quantity_completed) *
								nvl(msi_assy.variable_lead_time, 0))))
						 from bom_calendar_dates c2
						 where c2.calendar_code = mp.calendar_code
					     and  c2.exception_set_id = mp.calendar_exception_set_id
					     and   c2.calendar_date =
									trunc(fs.scheduled_completion_date)
						)
AND		dates.exception_set_id = mp.calendar_exception_set_id
AND		dates.calendar_code = mp.calendar_code
AND		mp.organization_id = msi_assy.organization_id
AND		fs.planned_quantity > 0
AND		fs.scheduled_completion_date >= TRUNC(SYSDATE)
AND		nvl(fs.alternate_bom_designator, '-23453') =
			nvl(bbm.alternate_bom_designator, '-23453')
AND		fs.organization_id = msi_assy.organization_id
AND		fs.primary_item_id = msi_assy.inventory_item_id
AND		msi_assy.compile_designator = items.compile_designator
AND		msi_assy.organization_id = bbm.organization_id
AND		msi_assy.inventory_item_id = bbm.assembly_item_id
AND		bbm.common_bill_sequence_id = bic.bill_sequence_id
AND     bic.effectivity_date <= last_date
AND		bic.component_item_id = items.inventory_item_id
AND		items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND		items.compile_designator = list.char1
AND		list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      fs.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
		items.inventory_item_id,
		items.organization_id,
		DEPENDENT,
		DEPENDENT_OFF,
		dates.calendar_date,
		dates.calendar_date
UNION ALL
----------------------------------
---- Flow Schedule By Product
----------------------------------
SELECT
		items.inventory_item_id item_id,
		items.organization_id org_id,
		DEPENDENT type,
		DEPENDENT_OFF offset,
		dates.calendar_date new_date,
		dates.calendar_date old_date,
		SUM(((nvl(fs.planned_quantity, 0) -
						      nvl(fs.quantity_completed, 0)) *
			 (bic.component_quantity/bic.component_yield_factor)
				* bic.planning_factor/100)) new_quantity,
		SUM(((nvl(fs.planned_quantity, 0) -
								  nvl(fs.quantity_completed, 0)) *
			  (bic.component_quantity/bic.component_yield_factor)
				* bic.planning_factor/100)) old_quantity
FROM	bom_calendar_dates dates,
		mtl_parameters mp,
		wip_flow_schedules fs,
		mrp_system_items msi_assy,
		bom_bill_of_materials bbm,
		bom_inventory_components bic,
		mrp_system_items items,
		mrp_form_query list,
        mrp_sub_inventories msi
WHERE  (arg_res_level = 1
		OR  (arg_res_level = 2
			AND fs.project_id is NULL)
		OR  (DECODE(arg_res_level,
				3,nvl(mrp_get_project.planning_group(fs.project_id),'-23453'),
				4,nvl(to_char(fs.project_id), '-23453'))
							   = nvl(arg_resval1,'-23453'))
	    OR  (arg_res_level = 5
			   AND  nvl(to_char(fs.project_id), '-23453')
				   	= nvl(arg_resval1,'-23453')
		  		AND  nvl(fs.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     dates.seq_num is not null
AND		dates.calendar_date < last_date
AND 	dates.seq_num  =
						(select c2.prior_seq_num -
					 ceil((1- nvl(bic.operation_lead_time_percent, 0)/100) *
							(nvl(msi_assy.fixed_lead_time, 0) +
							((fs.planned_quantity - fs.quantity_completed) *
								nvl(msi_assy.variable_lead_time, 0))))
						 from bom_calendar_dates c2
						 where c2.calendar_code = mp.calendar_code
					     and  c2.exception_set_id = mp.calendar_exception_set_id
					     and   c2.calendar_date =
									trunc(fs.scheduled_completion_date)
						)
AND		dates.exception_set_id = mp.calendar_exception_set_id
AND		dates.calendar_code = mp.calendar_code
AND		mp.organization_id = msi_assy.organization_id
AND		fs.planned_quantity > 0
AND		fs.scheduled_completion_date >= TRUNC(SYSDATE)
AND		nvl(fs.alternate_bom_designator, '-23453') =
			nvl(bbm.alternate_bom_designator, '-23453')
AND		fs.organization_id = msi_assy.organization_id
AND		fs.primary_item_id = msi_assy.inventory_item_id
AND		msi_assy.compile_designator = items.compile_designator
AND		msi_assy.organization_id = bbm.organization_id
AND		msi_assy.inventory_item_id = bbm.assembly_item_id
AND		bic.component_quantity < 0
AND		bbm.common_bill_sequence_id = bic.bill_sequence_id
AND     bic.effectivity_date <= last_date
AND		bic.component_item_id = items.inventory_item_id
AND		items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND		items.compile_designator = list.char1
AND		list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      fs.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
		items.inventory_item_id,
		items.organization_id,
		DEPENDENT,
		DEPENDENT_OFF,
		dates.calendar_date,
		dates.calendar_date
UNION ALL
---------------------------------
--- Flow Schedule Scrap
---------------------------------
SELECT
	items.inventory_item_id item_id,
	items.organization_id org_id,
	SCRAP row_type,
	SCRAP_OFF offset,
	flow_sched.scheduled_completion_date new_date,
	flow_sched.scheduled_completion_date old_date,
	SUM(GREATEST( 0, ((flow_sched.planned_quantity -
				      flow_sched.quantity_completed) *
					  nvl(items.shrinkage_rate, 0)))) new_quantity,
    SUM(GREATEST( 0, ((flow_sched.planned_quantity -
					   flow_sched.quantity_completed) *
					   nvl(items.shrinkage_rate, 0)))) old_quantity
FROM wip_flow_schedules flow_sched,
	 mrp_system_items items,
	 mrp_form_query list,
        mrp_sub_inventories msi
WHERE  (arg_res_level = 1
		OR  (arg_res_level = 2
			AND flow_sched.project_id is NULL)
		OR  (DECODE(arg_res_level,
			 3,nvl(mrp_get_project.planning_group(flow_sched.project_id),'-23453'),
			 4,nvl(to_char(flow_sched.project_id), '-23453'))
			   	= nvl(arg_resval1,'-23453'))
		OR  (arg_res_level = 5
	   		 AND  nvl(to_char(flow_sched.project_id), '-23453')
						   = nvl(arg_resval1,'-23453')
	   		 AND  nvl(flow_sched.task_id, -23453) = nvl(arg_resval2, -23453)))
AND  flow_sched.organization_id = items.organization_id
AND  flow_sched.primary_item_id = items.inventory_item_id
AND	 flow_sched.scheduled_completion_date < last_date
AND	 flow_sched.scheduled_completion_date >= TRUNC(sysdate)
AND	 flow_sched.planned_quantity > 0
AND  items.inventory_item_id = list.number1
AND  items.organization_id = list.number2
AND  items.compile_designator = list.char1
AND  list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      flow_sched.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
	items.inventory_item_id,
	items.organization_id,
	SCRAP,
	SCRAP_OFF,
	flow_sched.scheduled_completion_date,
	flow_sched.scheduled_completion_date
UNION ALL
----------------------------------
--- Current repetitive schedules
----------------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        CURRENT_S row_type,
        CURRENT_S_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(MRP_HORIZONTAL_PLAN_SC.compute_daily_rate_t(dates.calendar_code, dates.exception_set_id,
                               sched.daily_production_rate, sched.quantity_completed,
                               sched.first_unit_completion_date, dates.calendar_date ))  new_quantity ,
        SUM(MRP_HORIZONTAL_PLAN_SC.compute_daily_rate_t(dates.calendar_code, dates.exception_set_id,
                               sched.daily_production_rate, sched.quantity_completed,
                               sched.first_unit_completion_date, dates.calendar_date )) old_quantity
FROM    mrp_form_query list,
        bom_calendar_dates dates,
        mtl_parameters param,
        wip_repetitive_schedules sched,
        wip_repetitive_items rep_items,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE   rep_items.primary_item_id = items.inventory_item_id
and     rep_items.organization_id = items.organization_id
and     rep_items.wip_entity_id = sched.wip_entity_id
and     rep_items.line_id = sched.line_id
and     sched.organization_id = items.organization_id
and     sched.status_type IN (JOB_UNRELEASED,
           JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     dates.seq_num is not null
and     TRUNC(dates.calendar_date)
                >= TRUNC(sched.first_unit_completion_date)
and     TRUNC(dates.calendar_date)
                <= (select trunc(cal.calendar_date - 1)
                    from bom_calendar_dates cal
                    where cal.exception_set_id = dates.exception_set_id
                    and   cal.calendar_code    = dates.calendar_code
                    and   cal.seq_num =  (select cal1.prior_seq_num +  ceil(sched.processing_work_days)
                                          from bom_calendar_dates cal1
                                          where cal1.exception_set_id = dates.exception_set_id
                                          and cal1.calendar_code    = dates.calendar_code
                                          and cal1.calendar_date = TRUNC(sched.first_unit_completion_date)) )
and     dates.calendar_date < last_date
and     dates.exception_set_id = param.calendar_exception_set_id
and     dates.calendar_code = param.calendar_code
and     param.organization_id = items.organization_id
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      rep_items.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        CURRENT_S,
        CURRENT_S_OFF,
        dates.calendar_date,
        dates.calendar_date
UNION ALL
--------------------------------------
--- Current repetitive schedule scrap
--------------------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        SCRAP row_type,
        SCRAP_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(sched.daily_production_rate*NVL(items.shrinkage_rate, 0))
         new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        bom_calendar_dates dates,
        mtl_parameters param,
        wip_repetitive_schedules sched,
        wip_repetitive_items rep_items,
        mrp_system_items items,
        mrp_sub_inventories msi
WHERE   rep_items.primary_item_id = items.inventory_item_id
and     rep_items.organization_id = items.organization_id
and     rep_items.wip_entity_id = sched.wip_entity_id
and     rep_items.line_id = sched.line_id
and     sched.organization_id = items.organization_id
and     sched.status_type IN (JOB_UNRELEASED,
           JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     dates.seq_num is not null
and     TRUNC(dates.calendar_date)
                >= TRUNC(sched.first_unit_completion_date)
and     TRUNC(dates.calendar_date)
                <= (select trunc(cal.calendar_date - 1)
                    from bom_calendar_dates cal
                    where cal.exception_set_id = dates.exception_set_id
                    and   cal.calendar_code    = dates.calendar_code
                    and   cal.seq_num =  (select cal1.prior_seq_num +  ceil(sched.processing_work_days)
                                          from bom_calendar_dates cal1
                                          where cal1.exception_set_id = dates.exception_set_id
                                          and cal1.calendar_code    = dates.calendar_code
                                          and cal1.calendar_date = TRUNC(sched.first_unit_completion_date)) )
and     dates.calendar_date < last_date
and     dates.exception_set_id = param.calendar_exception_set_id
and     dates.calendar_code = param.calendar_code
and     param.organization_id = items.organization_id
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      rep_items.completion_subinventory = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        SCRAP,
        SCRAP_OFF,
        dates.calendar_date,
        dates.calendar_date,
        0
UNION ALL
----------------------------------------------
--- Current Repetitive Schedule requirements
----------------------------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        DEPENDENT row_type,
        DEPENDENT_OFF offset,
        ops.date_required new_date,
        ops.date_required old_date,
        SUM(ops.required_quantity - ops.quantity_issued) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        wip_requirement_operations ops,
        wip_repetitive_schedules sched,
        mrp_system_items items,
        WIP_REPETITIVE_ITEMS  rep_items,
        mrp_sub_inventories msi
WHERE   ops.organization_id = items.organization_id
and     ops.inventory_item_id = items.inventory_item_id
and     ops.mrp_net_flag = SYS_YES
and     ops.wip_supply_type <> 6
and     NVL(ops.quantity_issued, 0) <
                        NVL(ops.required_quantity, 0)
and     sched.organization_id  = ops.organization_id
and     sched.wip_entity_id  = ops.wip_entity_id
and     sched.repetitive_schedule_id = ops.repetitive_schedule_id
and     sched.organization_id = items.organization_id
and          sched.status_type IN (JOB_UNRELEASED,
                JOB_RELEASED, JOB_COMPLETE, JOB_HOLD)
and     ops.date_required < last_date
and     items.inventory_item_id = list.number1
and     items.organization_id = list.number2
and     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      rep_items.completion_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        DEPENDENT,
        DEPENDENT_OFF,
        ops.date_required,
        ops.date_required,
        0
UNION ALL
--------------------------
--- MDS
-------------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        DECODE(sched.schedule_origination_type,
               1, OTHER,
               2, FORECAST,
               3, SALES,
               4, OTHER,
               6, OTHER,
               7, OTHER,
               8, FORECAST,
               11, DEPENDENT) row_type,
        DECODE(sched.schedule_origination_type,
               1, OTHER_OFF,
               2, FORECAST_OFF,
               3, SALES_OFF,
               4, OTHER_OFF,
               6, OTHER_OFF,
               7, OTHER_OFF,
               8, FORECAST_OFF,
               11, DEPENDENT_OFF) offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(DECODE(sched.rate_end_date, NULL, sched.schedule_quantity,
                        sched.repetitive_daily_rate)) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        bom_calendar_dates dates,
        mtl_parameters param,
        mrp_schedule_dates sched,
        mrp_plan_schedules_v plan_sched,
        mrp_plans plans,
        mrp_system_items items
WHERE   (arg_res_level = 1
        OR  (arg_res_level = 2
               AND sched.project_id is NULL)
        OR  (DECODE(arg_res_level,
              3,nvl(mrp_get_project.planning_group(sched.project_id),'-23453'),
              4,nvl(to_char(sched.project_id), '-23453'))
                           = nvl(arg_resval1,'-23453'))
        OR  (arg_res_level = 5
               AND  nvl(to_char(sched.project_id), '-23453')
                                     = nvl(arg_resval1,'-23453')
               AND  nvl(sched.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      items.organization_id = NVL(plan_sched.input_organization_id,
                                    plans.organization_id)
AND     items.compile_designator = plans.compile_designator
AND     items.inventory_item_id = sched.inventory_item_id
AND     plan_sched.input_designator_type (+) = MDS_DESIGNATOR_TYPE
AND     NVL(plan_sched.input_organization_id, plans.organization_id) =
            sched.organization_id
AND    NVL(plan_sched.input_designator_name, plans.curr_schedule_designator)  =
        sched.schedule_designator
AND     plans.organization_id = plan_sched.organization_id (+)
AND     plans.compile_designator = plan_sched.compile_designator (+)
AND     sched.schedule_level = UPDATED_SCHEDULE
AND     sched.supply_demand_type = SCHEDULE_DEMAND
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
--AND     dates.seq_num is not null
AND (( sched.rate_end_date IS NOT NULL  /* Repetitively planned item */
       AND     dates.seq_num IS NOT NULL )
            OR
     ( sched.rate_end_date IS NULL ))
AND     dates.calendar_date BETWEEN sched.schedule_workdate
AND     NVL(sched.rate_end_date, sched.schedule_workdate)
AND     dates.calendar_date < last_date
AND     param.organization_id = items.organization_id
AND     items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     arg_ind_demand_type = IDT_SCHEDULE
AND     list.query_id = item_list_id
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        DECODE(sched.schedule_origination_type,
                1, OTHER,
                2, FORECAST,
                3, SALES,
                4, OTHER,
                6, OTHER,
                7, OTHER,
                8, FORECAST,
                11, DEPENDENT),
        DECODE(sched.schedule_origination_type,
                1, OTHER_OFF,
                2, FORECAST_OFF,
                3, SALES_OFF,
                4, OTHER_OFF,
                6, OTHER_OFF,
                7, OTHER_OFF,
                8, FORECAST_OFF,
                11, DEPENDENT_OFF),
        dates.calendar_date,
        dates.calendar_date,
        0
UNION ALL
-----------------------
--- Forecast Demand
-----------------------
SELECT
        items.inventory_item_id  item_id,
        items.organization_id org_id,
        FORECAST row_type,
        FORECAST_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(fcst.current_forecast_quantity) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        bom_calendar_dates dates,
        mtl_parameters param,
        mrp_forecast_dates fcst,
        mrp_forecast_designators desig,
        mrp_load_parameters load,
        mrp_system_items items
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
                AND fcst.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(fcst.project_id),'-23453'),
                4,nvl(to_char(fcst.project_id), '-23453'))
                                   = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(fcst.project_id), '-23453')
                             = nvl(arg_resval1,'-23453')
               AND  nvl(fcst.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     fcst.organization_id = items.organization_id
AND     fcst.inventory_item_id = items.inventory_item_id
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
--AND     dates.seq_num is not null
AND (( fcst.rate_end_date IS NOT NULL  /* Repetitively planned item */
       AND     dates.seq_num IS NOT NULL )
            OR
     ( fcst.rate_end_date IS NULL ))
AND     ((dates.calendar_date BETWEEN fcst.forecast_date
                AND     NVL(fcst.rate_end_date, forecast_date)
                AND     fcst.bucket_type = DAILY_BUCKET)
        OR
        (dates.calendar_date BETWEEN fcst.forecast_date
                AND     NVL(fcst.rate_end_date, forecast_date)
                AND     fcst.bucket_type = WEEKLY_BUCKET
                AND     dates.calendar_date IN
                        (select week_start_date
                        from bom_cal_week_start_dates
                        where calendar_code = param.calendar_code
                        and   exception_set_id = param.calendar_exception_set_id
                        and   param.organization_id = list.number2 ))
        OR
        (dates.calendar_date BETWEEN fcst.forecast_date
                AND     NVL(fcst.rate_end_date, forecast_date)
                AND     fcst.bucket_type = MONTHLY_BUCKET
                AND     dates.calendar_date IN
                        (select period_start_date
                        from bom_period_start_dates
                        where calendar_code = param.calendar_code
                        and   exception_set_id = param.calendar_exception_set_id
                        and   param.organization_id = list.number2)))
AND     dates.calendar_date < last_date
AND     param.organization_id = items.organization_id
AND     items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     arg_ind_demand_type = IDT_FORECAST
AND     fcst.current_forecast_quantity > 0
AND     fcst.organization_id = desig.organization_id
AND     fcst.forecast_designator = desig.forecast_designator
AND     ((desig.forecast_designator = load.source_forecast_designator)
OR      (desig.forecast_set = load.source_forecast_designator))
AND     desig.organization_id = load.source_organization_id
AND     load.selection_list_name = arg_source_list_name
AND     list.query_id = item_list_id
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        FORECAST,
        FORECAST_OFF,
        dates.calendar_date,
        dates.calendar_date,
        0
UNION ALL
---------------
--- PO Supply
---------------
--------------------
-- Purchase Orders
--------------------
SELECT
   ms.item_id item_id,
   ms.to_organization_id org_id,
   PO row_type,
   PO_OFF offset,
   mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
   mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
   SUM(ms.to_org_primary_quantity) new_quantity,
   SUM(ms.to_org_primary_quantity) old_quantity
FROM    po_distributions_all pd,
        mtl_supply ms,
        mrp_system_items items,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
               3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
               4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.expected_delivery_date < last_date
AND      pd.po_distribution_id = ms.po_distribution_id
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.po_line_id is not null
AND      ms.item_id is not null
AND      ms.to_org_primary_quantity > 0
AND      ( ms.supply_type_code = 'PO' or
           ms.supply_type_code = 'ASN')
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pd.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.po_line_location_id  = ODSS.line_location_id)
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        PO,
        PO_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
---------------------
-- Intransit Shipment
----------------------
 SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    TRANSIT row_type,
    TRANSIT_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(nvl(ms.to_org_primary_quantity, 0) * pd.req_line_quantity/pl.quantity)
           new_quantity,
    SUM(nvl(ms.to_org_primary_quantity, 0) * pd.req_line_quantity/pl.quantity)
           old_quantity
FROM    po_req_distributions_all pd,
        po_requisition_lines_all pl,
        mrp_system_items items,
        mtl_supply ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
            3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
            4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      pd.requisition_line_id = pl.requisition_line_id
AND      pl.quantity > 0
AND      pl.requisition_line_id = ms.req_line_id
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is not null
AND      ms.shipment_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'SHIPMENT'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pl.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY ms.item_id,
         ms.to_organization_id,
         TRANSIT,
         TRANSIT_OFF,
         mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    TRANSIT row_type,
    TRANSIT_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(ms.to_org_primary_quantity)new_quantity,
    SUM(ms.to_org_primary_quantity) old_quantity
FROM    mtl_secondary_inventories msub,
        mrp_system_items items,
        mtl_supply ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
               AND msub.project_id is NULL)
         OR  (DECODE(arg_res_level,
               3,nvl(mrp_get_project.planning_group(msub.project_id),'-23453'),
               4,nvl(to_char(msub.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(msub.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(msub.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.to_organization_id = msub.organization_id(+)
AND      ms.to_subinventory =  msub.secondary_inventory_name(+)
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is  null
AND      ms.shipment_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'SHIPMENT'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      ms.to_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        TRANSIT,
        TRANSIT_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
------------------------
-- Purchase Requisitions
------------------------
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    REQ row_type,
    REQ_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(nvl(ms.to_org_primary_quantity,0) * pd.req_line_quantity/
         prl.quantity) new_quantity,
    SUM(nvl(ms.to_org_primary_quantity,0) * pd.req_line_quantity/
         prl.quantity) old_quantity
FROM mrp_system_items items,
     po_req_distributions_all pd,
     po_requisition_lines_all prl,
     mtl_supply ms,
     mrp_form_query list,
        mrp_sub_inventories msi
WHERE (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      pd.requisition_line_id = prl.requisition_line_id
AND      prl.requisition_line_id = ms.req_line_id
AND      ms.to_org_primary_quantity > 0
AND      (prl.destination_subinventory is NULL OR
         ( exists (SELECT NULL from mtl_secondary_inventories
          where organization_id = prl.destination_organization_id AND
                secondary_inventory_name = prl.destination_subinventory AND
                nvl(availability_type,2) = SYS_YES)))
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'REQ'
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      prl.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.req_line_id  = ODSS.requisition_line_id)
GROUP BY
       ms.item_id,
       ms.to_organization_id,
       REQ,
       REQ_OFF,
       mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
----------------------
-- Intransit Receipts
----------------------
SELECT
  ms.item_id item_id,
  ms.to_organization_id org_id,
  RECEIVING row_type,
  RECEIVING_OFF offset,
  mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
  mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
  SUM(nvl(ms.TO_ORG_PRIMARY_QUANTITY, 0) * pd.req_line_quantity /
                                           pl.quantity) new_quantity,
  SUM(nvl(ms.TO_ORG_PRIMARY_QUANTITY, 0) * pd.req_line_quantity /
                                           pl.quantity) old_quantity
FROM po_requisition_lines_all pl,
     po_req_distributions_all pd,
     mrp_system_items items,
     mtl_supply ms,
     mrp_form_query list,
        mrp_sub_inventories msi
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      pd.requisition_line_id = pl.requisition_line_id
AND      pl.quantity > 0
AND      ms.req_line_id = pl.requisition_line_id
AND      ms.expected_delivery_date < last_date
AND      ms.po_distribution_id is  null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'RECEIVING'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pl.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.req_line_id = ODSS.requisition_line_id)
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        RECEIVING,
        RECEIVING_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    RECEIVING  row_type,
    RECEIVING_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(ms.to_org_primary_quantity)new_quantity,
    SUM(ms.to_org_primary_quantity) old_quantity
FROM   mtl_secondary_inventories msub,
       mrp_system_items items,
       mtl_supply ms,
       mrp_form_query list,
        mrp_sub_inventories msi
WHERE (arg_res_level = 1
         OR  (arg_res_level = 2
               AND msub.project_id is NULL)
         OR  (DECODE(arg_res_level,
               3,nvl(mrp_get_project.planning_group(msub.project_id),'-23453'),
               4,nvl(to_char(msub.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(msub.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(msub.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.to_organization_id = msub.organization_id(+)
AND      ms.to_subinventory =  msub.secondary_inventory_name(+)
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is  null
AND      ms.po_distribution_id is null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'RECEIVING'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      ms.to_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        RECEIVING,
        RECEIVING_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
-------------------
-- PO in Receiving
-------------------
SELECT
   ms.item_id item_id,
   ms.to_organization_id org_id,
   RECEIVING row_type,
   RECEIVING_OFF offset,
   mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
   mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
   SUM(ms.to_org_primary_quantity) new_quantity,
   SUM(ms.to_org_primary_quantity) old_quantity
FROM    po_distributions_all pd,
        mrp_system_items items,
        mtl_supply  ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
           AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      pd.po_distribution_id = ms.po_distribution_id
AND      ms.expected_delivery_date < last_date
AND      ms.destination_type_code = 'INVENTORY'
and      ms.item_id is not null
AND      ms.to_org_primary_quantity > 0
AND      ms.supply_type_code = 'RECEIVING'
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pd.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.po_line_location_id  = ODSS.line_location_id)
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        RECEIVING,
        RECEIVING_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
-------------------
--- PO SUPPLY Scrap
-------------------
-----------------------
-- Purchase Order Scrap
-----------------------
SELECT
   ms.item_id item_id,
   ms.to_organization_id org_id,
   SCRAP row_type,
   SCRAP_OFF  offset,
   mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
   mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
   SUM(ms.to_org_primary_quantity * DECODE(SIGN(ITEMS.SHRINKAGE_RATE),
       -1, 0, (NVL(ITEMS.SHRINKAGE_RATE,0)))) new_quantity,
   0  old_quantity
FROM    po_distributions_all pd,
        mrp_system_items items,
        mtl_supply ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.expected_delivery_date < last_date
AND      pd.po_distribution_id = ms.po_distribution_id
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.po_line_id is not null
and      ms.item_id is not null
AND      ms.to_org_primary_quantity > 0
AND      ( ms.supply_type_code = 'PO' or
           ms.supply_type_code = 'ASN')
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pd.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.po_line_location_id  = ODSS.line_location_id)
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        SCRAP,
        SCRAP_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
---------------------------
-- Intransit Shipment Scrap
---------------------------
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    SCRAP row_type,
    SCRAP_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM((nvl(ms.to_org_primary_quantity,0)* pd.req_line_quantity/pl.quantity) * DECODE(SIGN(ITEMS.SHRINKAGE_RATE),
       -1, 0, (NVL(ITEMS.SHRINKAGE_RATE,0)))) new_quantity,
     0   old_quantity
FROM    po_req_distributions_all pd,
        po_requisition_lines_all pl,
        mrp_system_items items,
        mtl_supply ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      pl.requisition_line_id = pd.requisition_line_id
AND      pl.quantity > 0
AND      ms.req_line_id = pl.requisition_line_id
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is not null
AND      ms.shipment_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'SHIPMENT'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      pl.destination_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY ms.item_id,
         ms.to_organization_id,
         SCRAP,
         SCRAP_OFF,
         mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    SCRAP row_type,
    SCRAP_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(nvl(ms.to_org_primary_quantity,0) * DECODE(SIGN(ITEMS.SHRINKAGE_RATE),
       -1, 0, (NVL(ITEMS.SHRINKAGE_RATE,0)))) new_quantity,
    0 old_quantity
FROM    mtl_secondary_inventories msub,
        mrp_system_items items,
        mtl_supply ms,
        mrp_form_query list,
        mrp_sub_inventories msi
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
               AND msub.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(msub.project_id),'-23453'),
                4,nvl(to_char(msub.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(msub.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(msub.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.to_organization_id = msub.organization_id(+)
AND      ms.to_subinventory =  msub.secondary_inventory_name(+)
AND      ms.expected_delivery_date < last_date
AND      ms.req_line_id is  null
AND      ms.shipment_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'SHIPMENT'
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.to_org_primary_quantity > 0
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      ms.to_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
GROUP BY
        ms.item_id,
        ms.to_organization_id,
        SCRAP,
        SCRAP_OFF,
        mrp_calendar.date_offset(items.organization_id,1,ms.receipt_date, CEIL(items.POSTPROCESSING_LEAD_TIME))
UNION ALL
-------------------------------
-- Purchase Requisitions Scrap
-------------------------------
SELECT
    ms.item_id item_id,
    ms.to_organization_id org_id,
    SCRAP row_type,
    SCRAP_OFF offset,
    mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) new_date,
    mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME)) old_date,
    SUM(nvl(ms.to_org_primary_quantity,0) *DECODE(SIGN(ITEMS.SHRINKAGE_RATE),
       -1, 0, (NVL(ITEMS.SHRINKAGE_RATE,0)))) new_quantity,
    0 old_quantity
FROM mrp_system_items items,
     po_req_distributions_all pd,
     mtl_supply ms,
     mrp_form_query list,
     mrp_sub_inventories msi
WHERE (arg_res_level = 1
         OR  (arg_res_level = 2
               AND pd.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(mrp_get_project.planning_group(pd.project_id),'-23453'),
                4,nvl(to_char(pd.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(pd.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(pd.task_id, -23453) = nvl(arg_resval2, -23453)))
AND      ms.to_org_primary_quantity > 0
AND      pd.req_line_quantity > 0
AND      ms.destination_type_code = 'INVENTORY'
AND      ms.expected_delivery_date < last_date
AND      pd.requisition_line_id = ms.req_line_id
AND      ms.req_line_id is not null
AND      ms.item_id is not null
AND      ms.supply_type_code = 'REQ'
AND      items.inventory_item_id = ms.item_id
AND      items.organization_id = ms.to_organization_id
AND      ms.item_id = list.number1
AND      ms.to_organization_id = list.number2
AND      items.compile_designator = list.char1
AND      list.query_id = item_list_id
AND      NVL(msi.compile_designator,items.compile_designator) = items.compile_designator
AND      NVL(msi.organization_id,items.organization_id)  =  items.organization_id
AND      ms.to_subinventory  = msi.sub_inventory_code(+)
AND      NVL(msi.netting_type,1) = 1
AND    NOT EXISTS (select 'y'  FROM   OE_DROP_SHIP_SOURCES ODSS
                   WHERE  ms.req_line_id  = ODSS.requisition_line_id)
GROUP BY
       ms.item_id,
       ms.to_organization_id,
       SCRAP,
       SCRAP_OFF,
       mrp_calendar.date_offset(items.organization_id,1,ms.need_by_date, CEIL(items.POSTPROCESSING_LEAD_TIME))

UNION ALL
---------------------------------------------
--- Planned order, Model /* Modified in 1402080 */
---------------------------------------------

SELECT
        items.inventory_item_id  item_id,
        items.organization_id org_id,
        DEPENDENT row_type,
        DEPENDENT_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        DECODE(SIGN(SUM(DECODE(reqs.assembly_demand_comp_date, NULL,
             reqs.using_requirements_quantity, daily_demand_rate)*
                ((NVL(recom.new_order_quantity, 0)
                - NVL(implemented_quantity, 0))/NVL(recom.new_order_quantity,1)))),-1,0,
                  SUM(DECODE(reqs.assembly_demand_comp_date, NULL,
                  reqs.using_requirements_quantity, daily_demand_rate)*
                  ((NVL(recom.new_order_quantity, 0)
                - NVL(implemented_quantity, 0))/NVL(recom.new_order_quantity,1)))) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        bom_calendar_dates dates,
        mtl_parameters param,
        mrp_recommendations recom,
        mrp_gross_requirements reqs,
        mrp_system_items items,
        mrp_plan_organizations_v mpov /*1402080*/
WHERE    (arg_res_level = 1
         OR  (arg_res_level = 2
                AND reqs.project_id is NULL)
         OR  (DECODE(arg_res_level,
                 3,nvl(reqs.planning_group,'-23453'),
                 4,nvl(to_char(reqs.project_id), '-23453'))
                                        = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(reqs.project_id), '-23453')
                                        = nvl(arg_resval1,'-23453')
               AND  nvl(reqs.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     reqs.origination_type in (DEMAND_PLANNED_ORDER)
AND     reqs.organization_id = items.organization_id
AND     reqs.compile_designator = items.compile_designator
AND     reqs.inventory_item_id = items.inventory_item_id
--AND     recom.organization_id = reqs.organization_id /*1402080*/
AND     recom.inventory_item_id = reqs.using_assembly_item_id
AND     recom.compile_designator = reqs.compile_designator
AND     recom.transaction_id = reqs.disposition_id
AND     recom.order_type = 5
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.seq_num is not null
AND     dates.calendar_date BETWEEN reqs.using_assembly_demand_date
AND     NVL(reqs.assembly_demand_comp_date, reqs.using_assembly_demand_date)
AND     reqs.using_assembly_demand_date < last_date
AND     param.organization_id = items.organization_id
AND     items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND     mpov.compile_designator   = reqs.compile_designator/*1402080*/
AND     mpov.planned_organization = reqs.organization_id   /*1402080*/
--AND     mpov.organization_id      = recom.organization_id  /*1475470*/
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        DEPENDENT,
        DEPENDENT_OFF,
        dates.calendar_date,
        dates.calendar_date,
        0
UNION ALL
----------------------------------------------------------
--Option Class Demand/*Added separately in 1402080 for option class demand*/
----------------------------------------------------------
 SELECT
        reqs.inventory_item_id item_id,
        reqs.organization_id org_id,
        DEPENDENT row_type,
        DEPENDENT_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(DECODE(reqs.assembly_demand_comp_date,
        NULL, using_requirements_quantity,
        daily_demand_rate)) new_quantity,
        0 old_quantity
FROM    mrp_form_query      list,
        mtl_parameters      param,
        mrp_gross_requirements  reqs,
        bom_calendar_dates  dates
WHERE (arg_res_level = 1
                 OR  (arg_res_level = 2
                                AND reqs.project_id is NULL)
                 OR  (DECODE(arg_res_level,
                                 3,nvl(reqs.planning_group,'-23453'),
                                 4,nvl(to_char(reqs.project_id), '-23453'))
                                 = nvl(arg_resval1,'-23453'))
                 OR  (arg_res_level = 5
                           AND  nvl(to_char(reqs.project_id), '-23453')
                                  = nvl(arg_resval1,'-23453')
                           AND  nvl(reqs.task_id, -23453)
                                  = nvl(arg_resval2, -23453)))
AND     origination_type in (DEMAND_OPTIONAL)
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.seq_num IS NOT NULL
AND     dates.calendar_date BETWEEN reqs.using_assembly_demand_date
AND     NVL(reqs.assembly_demand_comp_date, reqs.using_assembly_demand_date)
AND     reqs.using_assembly_demand_date < last_date
AND     reqs.compile_designator = list.char1
AND     reqs.inventory_item_id = list.number1
AND     reqs.organization_id = list.number2
AND     param.organization_id = list.number2
AND     list.query_id = item_list_id
GROUP BY
        reqs.inventory_item_id,
        reqs.organization_id,
        DEPENDENT,
        DEPENDENT_OFF,
        dates.calendar_date,
        dates.calendar_date,
            0
UNION ALL
------------------------------------------------------------
--payback demand
------------------------------------------------------------
SELECT
        mipv.inventory_item_id item_id,
        mipv.organization_id org_id,
        PB_DEMAND row_type,
        PB_DEMAND_OFF offset,
        mipv.payback_date new_date,
        mipv.payback_date old_date,
        sum(mipv.quantity) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        mrp_project_parameters pa,
        mtl_parameters param,
        mrp_item_borrow_payback_qty_v  mipv
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND mipv.borrow_project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(pa.planning_group,'-23453'),
                4,nvl(to_char(mipv.borrow_project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(mipv.borrow_project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(mipv.borrow_task_id, -23453) =
					nvl(arg_resval2, -23453)))
AND     pa.project_id(+)=mipv.borrow_project_id
AND     pa.organization_id(+)=mipv.organization_id
AND     param.project_reference_enabled  = 1
AND     param.organization_id = mipv.organization_id
AND     trunc(mipv.payback_date) < last_date
AND     mipv.inventory_item_id = list.number1
AND     mipv.owning_organization_id = list.number2
AND     mipv.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        mipv.inventory_item_id,
        mipv.organization_id,
        PB_DEMAND,
        PB_DEMAND_OFF,
        mipv.payback_date,
        mipv.payback_date,
        0
UNION ALL
SELECT
        mubq.inventory_item_id item_id,
        mubq.organization_id org_id,
        PB_DEMAND row_type,
        PB_DEMAND_OFF offset,
        mubq.payback_date new_date,
        mubq.payback_date old_date,
        sum(mubq.quantity-nvl(mupq.quantity, 0)) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        mrp_project_parameters pa,
        mtl_parameters param,
        mrp_unit_borrow_qty_v mubq,
        mrp_unit_payback_qty_v mupq
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND mubq.borrow_project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(pa.planning_group,'-23453'),
                4,nvl(to_char(mubq.borrow_project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(mubq.borrow_project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(mubq.borrow_task_id, -23453) =
                                        nvl(arg_resval2, -23453)))
AND     pa.project_id(+)=mubq.borrow_project_id
AND     pa.organization_id(+)=mubq.organization_id
AND     mubq.borrow_transaction_id = mupq.borrow_transaction_id(+)
AND     mubq.compile_designator = mupq.compile_designator(+)
AND		mubq.organization_id = mupq.organization_id(+)
AND		mubq.inventory_item_id = mupq.inventory_item_id(+)
AND     param.project_reference_enabled  = 1
AND     param.organization_id = mubq.organization_id
AND     trunc(mubq.payback_date) < last_date
AND     mubq.inventory_item_id = list.number1
AND     mubq.owning_org_id = list.number2
AND     mubq.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        mubq.inventory_item_id,
        mubq.organization_id,
        PB_DEMAND,
        PB_DEMAND_OFF,
        mubq.payback_date,
        mubq.payback_date,
        0
UNION ALL
------------------------------------------------------------
--payback supply
------------------------------------------------------------
SELECT
        mipv.inventory_item_id item_id,
        mipv.organization_id org_id,
        PB_SUPPLY row_type,
        PB_SUPPLY_OFF offset,
        mipv.payback_date new_date,
        mipv.payback_date old_date,
        sum(mipv.quantity) new_quantity,
        sum(mipv.quantity) old_quantity
FROM    mrp_form_query list,
        mrp_project_parameters pa,
        mtl_parameters param,
        mrp_item_borrow_payback_qty_v  mipv
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND mipv.borrow_project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(pa.planning_group,'-23453'),
                4,nvl(to_char(mipv.borrow_project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(mipv.borrow_project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(mipv.borrow_task_id, -23453) =
					nvl(arg_resval2, -23453)))
AND     pa.project_id(+)=mipv.borrow_project_id
AND     pa.organization_id(+)=mipv.organization_id
AND     param.project_reference_enabled  = 1
AND     param.organization_id = mipv.organization_id
AND     trunc(mipv.payback_date) < last_date
AND     mipv.inventory_item_id = list.number1
AND     mipv.owning_organization_id = list.number2
AND     mipv.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        mipv.inventory_item_id,
        mipv.organization_id,
        PB_SUPPLY,
        PB_SUPPLY_OFF,
        mipv.payback_date,
        mipv.payback_date
UNION ALL
SELECT
        mubq.inventory_item_id item_id,
        mubq.organization_id org_id,
        PB_SUPPLY row_type,
        PB_SUPPLY_OFF offset,
        mubq.payback_date new_date,
        mubq.payback_date old_date,
        sum(mubq.quantity-nvl(mupq.quantity, 0)) new_quantity,
        sum(mubq.quantity-nvl(mupq.quantity, 0)) old_quantity
FROM    mrp_form_query list,
        mrp_project_parameters pa,
        mtl_parameters param,
        mrp_unit_borrow_qty_v mubq,
        mrp_unit_payback_qty_v mupq
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND mubq.borrow_project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(pa.planning_group,'-23453'),
                4,nvl(to_char(mubq.borrow_project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(mubq.borrow_project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(mubq.borrow_task_id, -23453) =
                                        nvl(arg_resval2, -23453)))
AND     pa.project_id(+)=mubq.borrow_project_id
AND     pa.organization_id(+)=mubq.organization_id
AND     mubq.borrow_transaction_id = mupq.borrow_transaction_id(+)
AND		mubq.compile_designator = mupq.compile_designator(+)
AND		mubq.organization_id = mupq.organization_id(+)
AND		mubq.inventory_item_id = mupq.inventory_item_id(+)
AND     param.project_reference_enabled  = 1
AND     param.organization_id = mubq.organization_id
AND     trunc(mubq.payback_date) < last_date
AND     mubq.inventory_item_id = list.number1
AND     mubq.owning_org_id = list.number2
AND     mubq.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        mubq.inventory_item_id,
        mubq.organization_id,
        PB_SUPPLY,
        PB_SUPPLY_OFF,
        mubq.payback_date,
        mubq.payback_date
UNION ALL
---------------------
--- Planned Orders
---------------------
SELECT
        rec.inventory_item_id item_id,
        rec.organization_id org_id,
        PLANNED row_type,
        PLANNED_OFF offset,
        --rec.new_schedule_date new_date,
        /* Bug 1888531 */
        NVL(rec.firm_date, rec.new_schedule_date) new_date,
        rec.old_schedule_date old_date,
        SUM(GREATEST(0, nvl(rec.firm_quantity, rec.new_order_quantity) -
                                (nvl(rec.implemented_quantity, 0)
                + nvl(rec.quantity_in_process, 0)))) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        mrp_recommendations rec
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND rec.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(rec.planning_group,'-23453'),
                4,nvl(to_char(rec.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(rec.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(rec.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     rec.order_type = PLANNED_ORDER
AND     rec.inventory_item_id = list.number1
/* Bug 1888531 */
AND     nvl(rec.firm_date,rec.new_schedule_date) < last_date
AND     rec.organization_id = list.number2
AND     rec.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        rec.inventory_item_id,
        rec.organization_id,
        PLANNED,
        PLANNED_OFF,
/* Bug 1888531 */
        nvl(rec.firm_date,rec.new_schedule_date),
        rec.old_schedule_date,
        0
UNION ALL
----------------------------------------------
----- Planned Order By Product
----------------------------------------------
SELECT
        rec.inventory_item_id item_id,
        rec.organization_id org_id,
        DEPENDENT row_type,
        DEPENDENT_OFF offset,
        rec.new_schedule_date new_date,
        rec.old_schedule_date old_date,
		SUM(-1 * rec.new_order_quantity),
        0 old_quantity
FROM    mrp_form_query list,
        mrp_recommendations rec
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
               AND rec.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(rec.planning_group,'-23453'),
                4,nvl(to_char(rec.project_id), '-23453'))
                                       = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
               AND  nvl(to_char(rec.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
               AND  nvl(rec.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     rec.order_type = PLANNED_BY
AND     rec.inventory_item_id = list.number1
AND     rec.new_schedule_date < last_date
AND     rec.organization_id = list.number2
AND     rec.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        rec.inventory_item_id,
        rec.organization_id,
        DEPENDENT,
        DEPENDENT_OFF,
        rec.new_schedule_date,
        rec.old_schedule_date,
        0
UNION ALL
---------------------------
--- Planned orders scrap
---------------------------
SELECT
        rec.inventory_item_id item_id,
        rec.organization_id org_id,
        SCRAP row_type,
        SCRAP_OFF offset,
        rec.new_schedule_date new_date,
        rec.old_schedule_date old_date,
        SUM(rec.new_order_quantity*NVL(items.shrinkage_rate, 0)) new_quantity,
        0 old_quantity
FROM    mrp_form_query list,
        mrp_recommendations rec,
        mrp_system_items items
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
                AND rec.project_id is NULL)
         OR  (DECODE(arg_res_level,
                3,nvl(rec.planning_group,'-23453'),
                4,nvl(to_char(rec.project_id), '-23453'))
                                            = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
                AND  nvl(to_char(rec.project_id), '-23453')
                                       = nvl(arg_resval1,'-23453')
                AND  nvl(rec.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     rec.order_type = PLANNED_ORDER
AND     rec.new_schedule_date < last_date
AND     rec.organization_id = items.organization_id
AND     rec.compile_designator = items.compile_designator
AND     rec.inventory_item_id = items.inventory_item_id
AND     rec.inventory_item_id = list.number1
AND     rec.organization_id = list.number2
AND     rec.compile_designator = list.char1
AND     list.query_id = item_list_id
GROUP BY
        rec.inventory_item_id,
        rec.organization_id,
        SCRAP,
        SCRAP_OFF,
        rec.new_schedule_date,
        rec.old_schedule_date,
        0
UNION ALL
---------------------
-- Sales Orders
------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        SALES row_type,
        SALES_OFF offset,
        demand.requirement_date new_date,
        demand.requirement_date old_date,
        SUM(demand.primary_uom_quantity   - GREATEST(demand.completed_quantity,
          demand.reservation_quantity) ) new_quantity,
        0 old_quantity
FROM    oe_order_lines_all sl,
        mtl_demand_omoe demand,
        mrp_system_items items,
        mrp_form_query list
WHERE   (arg_res_level = 1
        OR  (arg_res_level = 2
              AND sl.project_id is NULL)
        OR  (DECODE(arg_res_level,
                 3,nvl(mrp_get_project.planning_group(sl.project_id),'-23453'),
                 4,nvl(to_char(sl.project_id), '-23453'))
                                  = nvl(arg_resval1,'-23453'))
        OR  (arg_res_level = 5
               AND  nvl(to_char(sl.project_id), '-23453')
                                          = nvl(arg_resval1,'-23453')
               AND  nvl(sl.task_id, -23453) = nvl(arg_resval2, -23453)))
and     to_number(demand.demand_source_line) = sl.line_id (+)
and     demand.demand_source_type in (2, 8)
and     items.organization_id = demand.organization_id
and     items.inventory_item_id = demand.inventory_item_id
and     demand.demand_source_type = SALES_ORDER
and     demand.available_to_mrp = SYS_YES
and     demand.primary_uom_quantity >
                            NVL(demand.completed_quantity, 0)
AND     items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     list.query_id = item_list_id
AND     arg_ind_demand_type = IDT_FORECAST--bug3211478
GROUP BY
        items.inventory_item_id,
        items.organization_id,
        SALES,
        SALES_OFF,
        demand.requirement_date,
        demand.requirement_date,
        0
UNION ALL
------------------
--- Safety stock
------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        SS row_type,
        SS_OFF offset,
        safety.effectivity_date new_date,
        safety.effectivity_date old_date,
        DECODE (NVL(items.rounding_control_type, DO_NOT_ROUND),
                DO_ROUND, CEIL(NVL(safety.safety_stock_quantity, 0)),
                NVL(safety.safety_stock_quantity, 0)),
        0 old_quantity
FROM    mrp_form_query list,
        mtl_safety_stocks safety,
        mrp_system_items items
WHERE   TRUNC(safety.effectivity_date) < last_date
AND     TRUNC(safety.effectivity_date) >=
            (SELECT NVL(TRUNC(max(effectivity_date)), TRUNC(SYSDATE))
             FROM    mtl_safety_stocks
             WHERE   organization_id = items.organization_id
             AND     inventory_item_id = items.inventory_item_id
             AND     effectivity_date <= TRUNC(SYSDATE))
AND     safety.organization_id = items.organization_id
AND     safety.inventory_item_id = items.inventory_item_id
AND     items.safety_stock_code = NON_MRP_PCT
AND     items.inventory_item_id = list.number1
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     list.query_id = item_list_id
UNION ALL
------------------
--- Expired Lots
------------------
SELECT
        items.inventory_item_id item_id,
        items.organization_id org_id,
        EXP_LOT row_type,
        EXP_LOT_OFF offset,
        lots.expiration_date new_date,
        lots.expiration_date old_date,
        NVL(SUM(moq.primary_transaction_quantity), 0) new_quantity,
        0 old_quantity
FROM
         mtl_item_locations mil,
         mtl_lot_numbers lots,
         mtl_onhand_quantities_detail moq,
         mrp_sub_inventories sub,
         mrp_system_items items,
         mrp_plan_organizations_v orgs,
         mrp_form_query list
  WHERE   (arg_res_level = 1
                OR  (arg_res_level = 2
                       AND mil.project_id is NULL)
                OR  (DECODE(arg_res_level,
                            3,nvl(mrp_get_project.planning_group(mil.project_id),'-23453'),
                        4,nvl(to_char(mil.project_id), '-23453'))
                                                                          = nvl(arg_resval1,'-23453'))
                OR  (arg_res_level = 5
                                 AND  nvl(to_char(mil.project_id), '-23453')
                                                                                  = nvl(arg_resval1,'-23453')
                                 AND  nvl(mil.task_id, -23453) = nvl(arg_resval2, -23453)))
 AND     (moq.organization_id       = mil.organization_id(+)
  AND     moq.locator_id            = mil.inventory_location_id(+))
  AND     moq.inventory_item_id     = lots.inventory_item_id
  AND     moq.organization_id       = lots.organization_id
  AND     moq.lot_number            = lots.lot_number
  AND     lots.expiration_date < last_date
  AND     NVL(lots.expiration_date,trunc(sysdate)) >= trunc(sysdate)
  AND     moq.inventory_item_id     = items.inventory_item_id
  AND     moq.organization_id       = sub.organization_id
  AND     moq.subinventory_code     = sub.sub_inventory_code
  AND     items.lot_control_code = 2
  AND     items.organization_id     = orgs.planned_organization
  AND     items.compile_designator  = orgs.compile_designator
  AND     sub.organization_id       = orgs.planned_organization
  AND     sub.compile_designator    = orgs.compile_designator
  AND     sub.netting_type =  NETTABLE
  AND     orgs.organization_id = list.number2
  AND     orgs.compile_designator = list.char1
  AND     items.inventory_item_id = list.number1
  AND     list.query_id = item_list_id
   GROUP BY items.inventory_item_id,
     items.organization_id,
           moq.subinventory_code,
     moq.revision,
     moq.locator_id,
     moq.lot_number,
     lots.expiration_date,
     mil.project_id,
     mil.task_id,
     sub.netting_type,
     orgs.organization_id,
     items.compile_designator
UNION ALL
-----------------
--- On hand
-----------------
--start of bug  3332404 On hand sql
SELECT
	 moq.Inventory_Item_ID item_id,
	 moq.Organization_ID org_id,
         ON_HAND row_type,
         ON_HAND_OFF offset,
         to_date(1, 'J') new_date,
         to_date(1, 'J') old_date,
         NVL(SUM(moq.primary_transaction_quantity),0) new_quantity,
        0 old_quantity
  FROM MTL_Onhand_Quantities_detail moq,
       mtl_parameters   param,
       mtl_material_statuses mms,
       mrp_system_items masis,
       MTL_LOT_NUMBERS mln,
       MTL_ITEM_LOCATIONS mil,
       PJM_PROJECT_PARAMETERS mpp,
        mrp_sub_inventories sub,
       mrp_form_query list
 WHERE (arg_res_level = 1
                OR  (arg_res_level = 2
                           AND mil.project_id is NULL)
                OR  (DECODE(arg_res_level,
                            3,nvl(mrp_get_project.planning_group(mil.project_id),'-23453'),
                            4,nvl(to_char(mil.project_id), '-23453')) = nvl(arg_resval1,'-23453'))
                OR  (arg_res_level = 5
                       AND  nvl(to_char(mil.project_id), '-23453')
                                                                  = nvl(arg_resval1,'-23453')
                           AND  nvl(mil.task_id, -23453) = nvl(arg_resval2, -23453)))
   AND param.organization_id = moq.organization_id
   AND moq.status_id = mms.status_id(+)
   AND moq.Inventory_Item_ID= masis.Inventory_Item_ID
   AND moq.Organization_ID= masis.Organization_ID
   AND masis.Effectivity_Control= 1
   AND mln.Organization_ID(+)= moq.Organization_ID
   AND mln.Inventory_Item_ID(+)= moq.Inventory_Item_ID
   AND mln.Lot_Number(+)= moq.Lot_Number
   AND mil.Organization_ID(+)= moq.Organization_ID
   AND NVL(mln.expiration_date, trunc(sysdate)) >= trunc(sysdate)
   AND mil.Inventory_Location_ID(+)= moq.Locator_ID
   AND mpp.Project_ID(+)= mil.Project_ID
   AND mpp.Organization_ID(+)= mil.Organization_ID
   AND sub.organization_id    = masis.organization_id
   AND sub.compile_designator = masis.compile_designator
   AND sub.sub_inventory_code = moq.subinventory_code
   AND moq.organization_id    = sub.organization_id
   AND sub.netting_type =  NETTABLE
   AND ((param.default_status_id is not null
         and mms.availability_type = 1 )
        OR
        (param.default_status_id is null
         AND NVL(mln.availability_type,1) = 1
         AND NVL(mil.availability_type,1) = 1 ))
   AND masis.organization_id = list.number2
   AND masis.compile_designator = list.char1
   AND masis.inventory_item_id = list.number1
   AND list.query_id = item_list_id
   GROUP BY
     moq.inventory_item_id,
     moq.organization_id,
     mil.project_id,
     mil.task_id,
     sub.sub_inventory_code,
     masis.compile_designator,
     masis.organization_id,
     sub.netting_type
UNION ALL
SELECT /*+ ORDERED */
         x.Inventory_Item_ID,
         x.Organization_ID,
         ON_HAND row_type,
         ON_HAND_OFF offset,
         to_date(1, 'J') new_date,
         to_date(1, 'J') old_date,
         NVL(SUM(x.Lot_Quantity) , 0) new_quantity,
         0 old_quantity
   FROM
       ( SELECT
             msn.Current_Organization_ID Organization_ID,
             msn.Inventory_Item_ID,
             msn.Current_Subinventory_Code Subinventory_Code,
             1 Lot_Quantity,
             masis.compile_designator,
             msn.Current_Locator_ID Locator_ID,
             msn.Lot_Number
         FROM MTL_SERIAL_NUMBERS msn,
             mrp_system_items masis
         WHERE msn.Current_Status IN ( 3,5)
         AND masis.Organization_ID= msn.Current_Organization_ID
         AND masis.Inventory_Item_ID= msn.Inventory_Item_ID
         AND masis.Effectivity_Control= 2 ) x,
       MTL_LOT_NUMBERS mln,
       MTL_ITEM_LOCATIONS mil,
       PJM_PROJECT_PARAMETERS mpp,
       mrp_sub_inventories sub,
       mrp_form_query list
 WHERE
   (arg_res_level = 1
                OR  (arg_res_level = 2
                           AND mil.project_id is NULL)
                OR  (DECODE(arg_res_level,
                            3,nvl(mrp_get_project.planning_group(mil.project_id),'-23453'),
                            4,nvl(to_char(mil.project_id), '-23453')) = nvl(arg_resval1,'-23453'))
                OR  (arg_res_level = 5
                       AND  nvl(to_char(mil.project_id), '-23453')
                                                                  = nvl(arg_resval1,'-23453')
                           AND  nvl(mil.task_id, -23453) = nvl(arg_resval2, -23453)))
   AND mln.Organization_ID(+)= x.Organization_ID
   AND mln.Inventory_Item_ID(+)= x.Inventory_Item_ID
   AND mln.Lot_Number(+)= x.Lot_Number
   AND NVL(mln.expiration_date, trunc(sysdate)) >= trunc(sysdate)
   AND mil.Organization_ID(+)= x.Organization_ID
   AND mil.Inventory_Location_ID(+)= x.Locator_ID
   AND mpp.Project_ID(+)= mil.Project_ID
   AND mpp.Organization_ID(+)= mil.Organization_ID
   AND sub.organization_id = x.Organization_ID
   AND sub.compile_designator = x.compile_designator
   AND sub.sub_inventory_code = x.subinventory_code
   AND sub.netting_type =  NETTABLE
   AND NVL(mln.availability_type,1) = 1
   AND NVL(mil.availability_type,1) = 1
   AND x.organization_id = list.number2
   AND x.compile_designator = list.char1
   AND x.inventory_item_id = list.number1
   AND list.query_id = item_list_id
   GROUP BY
     x.inventory_item_id,
     x.organization_id,
     mil.project_id,
     mil.task_id,
     sub.sub_inventory_code,
     x.compile_designator,
     x.organization_id,
     sub.netting_type
UNION ALL
SELECT
       mmtt.Inventory_Item_ID item_id,
       mmtt.Organization_ID org_id,
       ON_HAND row_type,
       ON_HAND_OFF offset,
       to_date(1, 'J') new_date,
       to_date(1, 'J') old_date,
       NVL(SUM(mmtt.Primary_Quantity) , 0) new_quantity,
       0 old_quantity
  FROM PJM_PROJECT_PARAMETERS mpp,
       mrp_system_items masis,
       MTL_Material_Transactions_Temp mmtt,
       MTL_ITEM_LOCATIONS mil,
       mrp_sub_inventories sub,
       mrp_form_query list
 WHERE
       (arg_res_level = 1
         OR  (arg_res_level = 2
               AND mmtt.project_id is NULL)
         OR  (DECODE(arg_res_level,
              3,nvl(mrp_get_project.planning_group(mmtt.project_id),'-23453'),
              4,nvl(to_char(mmtt.project_id), '-23453'))
                                      = nvl(arg_resval1,'-23453'))
        OR   (arg_res_level = 5
                AND  nvl(to_char(mmtt.project_id), '-23453')
                                      = nvl(arg_resval1,'-23453')
                AND  nvl(mmtt.task_id, -23453) = nvl(arg_resval2, -23453)))
   AND EXISTS
   (SELECT 'x'
    FROM mtl_material_statuses mms
    WHERE
    mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(
                              mmtt.organization_id,
	                          mmtt.inventory_item_id,
		                      mmtt.subinventory_code,
				       		  mmtt.locator_id,
						      mmtt.lot_number,
          					  mmtt.lpn_id,
                              mmtt.transaction_action_id),
                        mms.status_id)
    AND mms.availability_type =1)
   AND mpp.Organization_ID(+)= mmtt.Organization_ID
   AND mpp.Project_ID(+)= mmtt.Project_ID
   AND mmtt.Posting_Flag= 'Y'
   AND masis.Organization_ID= mmtt.Organization_ID
   AND masis.Inventory_Item_ID= mmtt.Inventory_Item_ID
   AND masis.Effectivity_Control= 1
   AND NVL(mmtt.transaction_status,0) <> 2
   AND mil.Organization_ID(+)= mmtt.Organization_ID
   AND mil.Inventory_Location_ID(+)= mmtt.Locator_ID
   AND sub.organization_id = mmtt.Organization_ID
   AND sub.compile_designator = masis.compile_designator
   AND sub.sub_inventory_code = mmtt.subinventory_code
   AND sub.netting_type =  NETTABLE
   AND NVL(mil.availability_type,1) = 1
   AND masis.organization_id = list.number2
   AND masis.compile_designator = list.char1
   AND masis.inventory_item_id = list.number1
   AND list.query_id = item_list_id
   group by
    mmtt.inventory_item_id,
    mmtt.organization_id,
    mmtt.project_id,
    mmtt.task_id,
    sub.sub_inventory_code,
    masis.compile_designator,
    masis.organization_id,
    sub.netting_type
UNION ALL
SELECT
       mmtt.Inventory_Item_ID item_id,
       mmtt.Organization_ID org_id,
       ON_HAND row_type,
       ON_HAND_OFF offset,
       to_date(1, 'J') new_date,
       to_date(1, 'J') old_date,
       NVL(SUM(mmtt.Primary_Quantity ) , 0) new_quantity,
       0 old_quantity
  FROM PJM_PROJECT_PARAMETERS mpp,
       mrp_system_items masis,
       MTL_Material_Transactions_Temp mmtt,
       MTL_ITEM_LOCATIONS mil,
       mrp_sub_inventories sub,
       mrp_form_query list
 WHERE
   (arg_res_level = 1
     OR(arg_res_level = 2 AND mmtt.project_id is NULL)
     OR(DECODE(arg_res_level,3,nvl(mrp_get_project.planning_group(mmtt.project_id),'-23453'),
        4,nvl(to_char(mmtt.project_id), '-23453')) = nvl(arg_resval1,'-23453'))
     OR   (arg_res_level = 5 AND  nvl(to_char(mmtt.project_id), '-23453') = nvl(arg_resval1,'-23453')
   AND  nvl(mmtt.task_id, -23453) = nvl(arg_resval2, -23453)))
   AND EXISTS
   (SELECT 'x'
    FROM mtl_material_statuses mms
    WHERE
    mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(
                              mmtt.organization_id,
	                          mmtt.inventory_item_id,
		                      mmtt.subinventory_code,
				       		  mmtt.locator_id,
						      mmtt.lot_number,
          					  mmtt.lpn_id,
                              mmtt.transaction_action_id),
                        mms.status_id)
    AND mms.availability_type =1)
   AND mpp.Organization_ID(+)= mmtt.Organization_ID
   AND mpp.Project_ID(+)= mmtt.Project_ID
   AND mmtt.Posting_Flag= 'Y'
   AND mmtt.Transaction_Action_ID= 1
   AND mmtt.Transaction_Source_Type_ID in (1,5)
   AND masis.Organization_ID= mmtt.Organization_ID
   AND masis.Inventory_Item_ID= mmtt.Inventory_Item_ID
   AND masis.Effectivity_Control= 2
   AND NVL(mmtt.transaction_status,0) <> 2
   AND mil.Organization_ID(+)= mmtt.Organization_ID
   AND mil.Inventory_Location_ID(+)= mmtt.Locator_ID
   AND sub.organization_id = mmtt.Organization_ID
   AND sub.compile_designator = masis.compile_designator
   AND sub.sub_inventory_code = mmtt.subinventory_code
   AND sub.netting_type =  NETTABLE
   AND NVL(mil.availability_type,1) = 1
   AND masis.organization_id = list.number2
   AND masis.compile_designator = list.char1
   AND masis.inventory_item_id = list.number1
   AND list.query_id = item_list_id
   group by
   mmtt.inventory_item_id,
   mmtt.organization_id,
   mmtt.project_id,
   mmtt.task_id,
   sub.sub_inventory_code,
   masis.compile_designator,
   masis.organization_id,
   sub.netting_type
UNION ALL
SELECT
       mmtt.Inventory_Item_ID item_id,
       mmtt.Organization_ID org_id,
       ON_HAND row_type,
       ON_HAND_OFF offset,
       to_date(1, 'J') new_date,
       to_date(1, 'J') old_date,
       NVL(SUM(mmtt.Primary_Quantity ), 0) new_quantity,
       0 old_quantity
  FROM PJM_PROJECT_PARAMETERS mpp,
       MTL_Serial_Numbers_Temp msnt,
       MTL_SERIAL_NUMBERS msn,
       mrp_system_items masis,
       MTL_Material_Transactions_Temp mmtt,
       MTL_ITEM_LOCATIONS mil,
       mrp_sub_inventories sub,
       mrp_form_query list
 WHERE
    (arg_res_level = 1
     OR(arg_res_level = 2 AND mmtt.project_id is NULL)
     OR(DECODE(arg_res_level,3,nvl(mrp_get_project.planning_group(mmtt.project_id),'-23453'),
        4,nvl(to_char(mmtt.project_id), '-23453')) = nvl(arg_resval1,'-23453'))
     OR   (arg_res_level = 5 AND  nvl(to_char(mmtt.project_id), '-23453') = nvl(arg_resval1,'-23453')
   AND nvl(mmtt.task_id, -23453) = nvl(arg_resval2, -23453)))
   AND EXISTS
   (SELECT 'x'
    FROM mtl_material_statuses mms
    WHERE
    mms.status_id= nvl(INV_MATERIAL_STATUS_GRP.get_default_status(
                              mmtt.organization_id,
	                          mmtt.inventory_item_id,
		                      mmtt.subinventory_code,
				       		  mmtt.locator_id,
						      mmtt.lot_number,
          					  mmtt.lpn_id,
                              mmtt.transaction_action_id),
                        mms.status_id)
    AND mms.availability_type =1)
   AND mpp.Organization_ID(+)= mmtt.Organization_ID
   AND mpp.Project_ID(+)= mmtt.Project_ID
   AND msnt.Transaction_Temp_ID= mmtt.Transaction_Temp_ID
   AND msnt.Fm_Serial_Number= msn.Serial_Number
   AND msn.Inventory_Item_ID= mmtt.Inventory_Item_ID
   AND mmtt.Posting_Flag= 'Y'
   AND NOT( mmtt.Transaction_Action_ID= 1
            AND mmtt.Transaction_Source_Type_ID in (1,5))
   AND masis.Organization_ID= mmtt.Organization_ID
   AND masis.Inventory_Item_ID= mmtt.Inventory_Item_ID
   AND masis.Effectivity_Control= 2
   AND NVL(mmtt.transaction_status,0) <> 2
   AND mil.Organization_ID(+)= mmtt.Organization_ID
   AND mil.Inventory_Location_ID(+)= mmtt.Locator_ID
   AND sub.organization_id = mmtt.Organization_ID
   AND sub.compile_designator = masis.compile_designator
   AND sub.sub_inventory_code = mmtt.subinventory_code
   AND sub.netting_type =  NETTABLE
   AND NVL(mil.availability_type,1) = 1
   AND masis.organization_id = list.number2
   AND masis.compile_designator = list.char1
   AND masis.inventory_item_id = list.number1
   AND list.query_id = item_list_id
   group by
   mmtt.inventory_item_id,
   mmtt.organization_id,
   mmtt.project_id,
   mmtt.task_id,
   sub.sub_inventory_code,
   masis.compile_designator,
   masis.organization_id,
   sub.netting_type

--end of bug  3332404 On hand sql
UNION ALL
SELECT MTRL.Inventory_Item_ID item_id,
       MTRL.Organization_ID org_id,
       ON_HAND row_type,
       ON_HAND_OFF offset,
       to_date(1, 'J') new_date,
       to_date(1, 'J') old_date,
       SUM(QUANTITY - NVL(QUANTITY_DELIVERED,0)) new_quantity,
       0 old_quantity
FROM  MTL_TXN_REQUEST_LINES  MTRL,
      MTL_TXN_REQUEST_HEADERS MTRH,
      MTL_TRANSACTION_TYPES   MTT,
      PJM_PROJECT_PARAMETERS mpp,
      MRP_PLAN_ORGANIZATIONS_V  ORG,
      MRP_SYSTEM_ITEMS ITEMS,
      MRP_FORM_QUERY list
where
     (arg_res_level = 1
        OR(arg_res_level = 2 AND MTRL.project_id is NULL)
        OR(DECODE(arg_res_level,3,nvl(mrp_get_project.planning_group(MTRL.project_id),'-23453'),
        4,nvl(to_char(MTRL.project_id), '-23453')) = nvl(arg_resval1,'-23453'))
        OR   (arg_res_level = 5 AND  nvl(to_char(MTRL.project_id), '-23453') = nvl(arg_resval1,'-23453')
	AND nvl(MTRL.task_id, -23453) = nvl(arg_resval2, -23453)))
      AND ITEMS.ORGANIZATION_ID = ORG.PLANNED_ORGANIZATION
      AND mpp.Organization_ID(+)= MTRL.Organization_ID
      AND mpp.Project_ID(+)= MTRL.Project_ID
      AND ITEMS.COMPILE_DESIGNATOR = ORG.COMPILE_DESIGNATOR
      AND MTRL.ORGANIZATION_ID = ITEMS.ORGANIZATION_ID
      AND MTRL.INVENTORY_ITEM_ID = ITEMS.INVENTORY_ITEM_ID
      AND MTRH.MOVE_ORDER_TYPE = 6
      AND MTRL.TRANSACTION_SOURCE_TYPE_ID = 5
      AND MTT.TRANSACTION_ACTION_ID = 31
      AND MTT.TRANSACTION_TYPE_ID = MTRL.TRANSACTION_TYPE_ID
      AND MTRL.LINE_STATUS = 7
      AND MTRL.LPN_ID IS NOT NULL
      AND MTRH.HEADER_ID = MTRL.HEADER_ID
      AND ITEMS.organization_id = list.number2
      AND ITEMS.compile_designator = list.char1
      AND ITEMS.inventory_item_id = list.number1
      AND list.query_id = item_list_id
      GROUP BY
      MTRL.inventory_item_id,
      MTRL.organization_id,
      MTRL.project_id,
      MTRL.task_id,
      ITEMS.compile_designator,
      ITEMS.organization_id
UNION ALL
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  list.number1,
        list.number2,
        ON_HAND,
        ON_HAND_OFF,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        0
FROM    mrp_form_query list
WHERE   list.query_id = item_list_id
ORDER BY
     1, 2, 5, 3;

-- --------------------------------------------
-- This cursor selects the snapshot activity in
-- MRP_GROSS_REQUIREMENTS and
-- MRP_RECOMMENDATIONS for the items in the
-- item list.
-- --------------------------------------------
CURSOR  mrp_snapshot_activity IS
 SELECT rec.inventory_item_id item_id,
        rec.organization_id org_id,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO,
        PURCH_REQ,          REQ,
        WORK_ORDER,         WIP,
        FLOW_SCHED,         WIP,
        REPETITIVE_SCHEDULE,PLANNED,
        PLANNED_ORDER,      PLANNED,
        NONSTD_JOB,         WIP,
        RECEIPT_PURCH_ORDER,RECEIVING,
        SHIPMENT,           TRANSIT,
        RECEIPT_SHIPMENT,   RECEIVING,
        PAYBACK_SUPPLY, PB_SUPPLY,
        PLANNED) row_type,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO_OFF,
        PURCH_REQ,          REQ_OFF,
        WORK_ORDER,         WIP_OFF,
        FLOW_SCHED,         WIP_OFF,
        REPETITIVE_SCHEDULE,PLANNED_OFF,
        PLANNED_ORDER,      PLANNED_OFF,
        NONSTD_JOB,         WIP_OFF,
        RECEIPT_PURCH_ORDER,RECEIVING_OFF,
        SHIPMENT,           TRANSIT_OFF,
        RECEIPT_SHIPMENT,   RECEIVING_OFF,
    DIS_JOB_BY,     DEPENDENT_OFF,
    NON_ST_JOB_BY,      DEPENDENT_OFF,
    REP_SCHED_BY,       DEPENDENT_OFF,
    PLANNED_BY,     DEPENDENT_OFF,
	FLOW_SCHED_BY,	DEPENDENT_OFF,
        PAYBACK_SUPPLY, PB_SUPPLY_OFF,
        PLANNED_OFF) offset,
        dates.calendar_date new_date,
        decode(rec.order_type, PAYBACK_SUPPLY,
               dates.calendar_date, rec.old_schedule_date) old_date,
        SUM(DECODE(rec.disposition_status_type,
            1, DECODE(rec.last_unit_completion_date,
                    NULL, rec.new_order_quantity,
                        rec.daily_rate) *
           DECODE(rec.order_type,
            DIS_JOB_BY, -1,
            NON_ST_JOB_BY,  -1,
            REP_SCHED_BY,   -1,
            PLANNED_BY, -1,
			FLOW_SCHED_BY, -1,
            1)
        , 0)) new_quantity,
        SUM(NVL(rec.old_order_quantity,0)) old_quantity
FROM    mrp_form_query      list,
        mtl_parameters      param,
        mrp_recommendations rec,
        bom_calendar_dates      dates
WHERE   (arg_res_level = 1
         OR  (arg_res_level = 2
                AND rec.project_id is NULL)
         OR  (DECODE(arg_res_level,
                       3,nvl(rec.planning_group,'-23453'),
                       4,nvl(to_char(rec.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
         OR  (arg_res_level = 5
                AND  nvl(to_char(rec.project_id), '-23453')
                                                = nvl(arg_resval1,'-23453')
                AND  nvl(rec.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
--AND     dates.seq_num IS NOT NULL
AND (( rec.last_unit_completion_date IS NOT NULL  /* Repetitively planned item */
       AND     dates.seq_num IS NOT NULL )
            OR
     ( rec.last_unit_completion_date IS NULL ))
AND     dates.calendar_date BETWEEN rec.new_schedule_date
AND     NVL(rec.last_unit_completion_date, rec.new_schedule_date)
AND     (rec.new_schedule_date < last_date OR
         rec.old_schedule_date < last_date)
AND     rec.compile_designator = list.char1
AND     rec.inventory_item_id = list.number1
AND     rec.organization_id = list.number2
AND     param.organization_id = list.number2
AND     list.query_id = item_list_id
GROUP BY
        rec.inventory_item_id,
        rec.organization_id,
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO,
        PURCH_REQ,          REQ,
        WORK_ORDER,         WIP,
        FLOW_SCHED,         WIP,
        REPETITIVE_SCHEDULE,PLANNED,
        PLANNED_ORDER,      PLANNED,
        NONSTD_JOB,         WIP,
        RECEIPT_PURCH_ORDER,RECEIVING,
        SHIPMENT,           TRANSIT,
        RECEIPT_SHIPMENT,   RECEIVING,
        PAYBACK_SUPPLY, PB_SUPPLY,
        PLANNED),
        DECODE(rec.order_type,
        PURCHASE_ORDER,     PO_OFF,
        PURCH_REQ,          REQ_OFF,
        WORK_ORDER,         WIP_OFF,
        FLOW_SCHED,         WIP_OFF,
        REPETITIVE_SCHEDULE,PLANNED_OFF,
        PLANNED_ORDER,      PLANNED_OFF,
        NONSTD_JOB,         WIP_OFF,
        RECEIPT_PURCH_ORDER,RECEIVING_OFF,
        SHIPMENT,           TRANSIT_OFF,
        RECEIPT_SHIPMENT,   RECEIVING_OFF,
    DIS_JOB_BY,     DEPENDENT_OFF,
    NON_ST_JOB_BY,      DEPENDENT_OFF,
    REP_SCHED_BY,       DEPENDENT_OFF,
    PLANNED_BY,     DEPENDENT_OFF,
	FLOW_SCHED_BY, 	DEPENDENT_OFF,
        PAYBACK_SUPPLY, PB_SUPPLY_OFF,
        PLANNED_OFF),
       dates.calendar_date,
       decode(rec.order_type, PAYBACK_SUPPLY, dates.calendar_date,
             rec.old_schedule_date)
UNION ALL
SELECT  mgr.inventory_item_id item_id,
        mgr.organization_id org_id,
        DECODE(mgr.origination_type,
            1, DEPENDENT,
            2, DEPENDENT,
            3, DEPENDENT,
            4, DEPENDENT,
            5, EXP_LOT,
            6, SALES,
            7, FORECAST,
            8, OTHER,
            9, OTHER,
            10, OTHER,
            11, OTHER,
            12, OTHER,
            15, OTHER,
            16, SCRAP,
            17, SCRAP,
            18, SCRAP,
            19, SCRAP,
            20, SCRAP,
            21, SCRAP,
            22, DEPENDENT,
            23, SCRAP,
            24, DEPENDENT,
            25, DEPENDENT,
	    26, SCRAP,
            DEMAND_PAYBACK, PB_DEMAND,
            OTHER) row_type,
        DECODE(mgr.origination_type,
            1, DEPENDENT_OFF,
            2, DEPENDENT_OFF,
            3, DEPENDENT_OFF,
            4, DEPENDENT_OFF,
            5, EXP_LOT_OFF,
            6, SALES_OFF,
            7, FORECAST_OFF,
            8, OTHER_OFF,
            9, OTHER_OFF,
            10, OTHER_OFF,
            11, OTHER_OFF,
            12, OTHER_OFF,
            15, OTHER_OFF,
            16, SCRAP_OFF,
            17, SCRAP_OFF,
            18, SCRAP_OFF,
            19, SCRAP_OFF,
            20, SCRAP_OFF,
            21, SCRAP_OFF,
            22, DEPENDENT_OFF,
            23, SCRAP_OFF,
            24, DEPENDENT_OFF,
            25, DEPENDENT_OFF,
	    26, SCRAP_OFF,
            DEMAND_PAYBACK, PB_DEMAND_OFF,
            OTHER_OFF) offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        SUM(DECODE(mgr.assembly_demand_comp_date,
        NULL, using_requirements_quantity,
        daily_demand_rate)) new_quantity,
        0 old_quantity
FROM    mrp_form_query      list,
        mtl_parameters      param,
        mrp_gross_requirements  mgr,
        bom_calendar_dates  dates
WHERE (arg_res_level = 1
       OR  (arg_res_level = 2
                AND mgr.project_id is NULL)
       OR  (DECODE(arg_res_level,
                      3,nvl(mgr.planning_group,'-23453'),
                      4,nvl(to_char(mgr.project_id), '-23453'))
                                                = nvl(arg_resval1,'-23453'))
       OR  (arg_res_level = 5
                AND  nvl(to_char(mgr.project_id), '-23453')
                                   = nvl(arg_resval1,'-23453')
                 AND  nvl(mgr.task_id, -23453) = nvl(arg_resval2, -23453)))
AND     dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
--AND     dates.seq_num IS NOT NULL
AND (( mgr.assembly_demand_comp_date IS NOT NULL  /* Repetitively planned item */
       AND     dates.seq_num IS NOT NULL )
               OR
     ( mgr.assembly_demand_comp_date IS NULL ))
AND     dates.calendar_date BETWEEN mgr.using_assembly_demand_date
AND     NVL(mgr.assembly_demand_comp_date, mgr.using_assembly_demand_date)
AND     mgr.using_assembly_demand_date < last_date
AND     mgr.compile_designator = list.char1
AND     mgr.inventory_item_id = list.number1
AND     mgr.organization_id = list.number2
AND     param.organization_id = list.number2
AND     list.query_id = item_list_id
GROUP BY
        mgr.inventory_item_id,
        mgr.organization_id,
        DECODE(mgr.origination_type,
            1, DEPENDENT,
            2, DEPENDENT,
            3, DEPENDENT,
            4, DEPENDENT,
            5, EXP_LOT,
            6, SALES,
            7, FORECAST,
            8, OTHER,
            9, OTHER,
            10, OTHER,
            11, OTHER,
            12, OTHER,
            15, OTHER,
            16, SCRAP,
            17, SCRAP,
            18, SCRAP,
            19, SCRAP,
            20, SCRAP,
            21, SCRAP,
            22, DEPENDENT,
            23, SCRAP,
            24, DEPENDENT,
            25, DEPENDENT,
	    26, SCRAP,
            DEMAND_PAYBACK, PB_DEMAND,
            OTHER),
        DECODE(mgr.origination_type,
            1, DEPENDENT_OFF,
            2, DEPENDENT_OFF,
            3, DEPENDENT_OFF,
            4, DEPENDENT_OFF,
            5, EXP_LOT_OFF,
            6, SALES_OFF,
            7, FORECAST_OFF,
            8, OTHER_OFF,
            9, OTHER_OFF,
            10, OTHER_OFF,
            11, OTHER_OFF,
            12, OTHER_OFF,
            15, OTHER_OFF,
            16, SCRAP_OFF,
            17, SCRAP_OFF,
            18, SCRAP_OFF,
            19, SCRAP_OFF,
            20, SCRAP_OFF,
            21, SCRAP_OFF,
            22, DEPENDENT_OFF,
            23, SCRAP_OFF,
            24, DEPENDENT_OFF,
            25, DEPENDENT_OFF,
	    26, SCRAP_OFF,
            DEMAND_PAYBACK, PB_DEMAND_OFF,
            OTHER_OFF),
        dates.calendar_date,
        dates.calendar_date,
            0
UNION ALL
SELECT  avail.inventory_item_id item_id,
        avail.organization_id org_id,
        ATP row_type,
        ATP_OFF offset,
        avail.schedule_date new_date,
        avail.schedule_date old_date,
        avail.quantity_available new_quantity,
        0 old_quantity
FROM    mrp_form_query      list,
        mrp_available_to_promise avail
WHERE   avail.schedule_date < last_date
AND     avail.organization_id = list.number2
AND     avail.compile_designator = list.char1
AND     avail.inventory_item_id = list.number1
AND     list.query_id = item_list_id
UNION ALL
SELECT  items.inventory_item_id item_id,
        items.organization_id org_id,
        ON_HAND row_type,
        ON_HAND_OFF offset,
        to_date(1, 'J') new_date,
        to_date(1, 'J') old_date,
        items.nettable_quantity new_quantity,
        0 old_quantity
FROM    mrp_plans plans,
        mrp_onhand_quantities  items,
        mrp_form_query      list
WHERE   ((arg_res_level = 1 )
        OR (arg_res_level = 2
            AND items.project_id is null)
        OR (DECODE(arg_res_level, 3, nvl(items.planning_group,'-23453'),
                                  4, nvl(to_char(items.project_id),'-23453'))
             = nvl(arg_resval1,'-23453'))
        OR ( arg_res_level = 5
            AND nvl(to_char(items.project_id),'-23453')
                  = nvl(arg_resval1,'-23453')
            AND nvl(items.task_id,-23453) = nvl(arg_resval2,-23453)))
AND     plans.curr_reservation_level in (1, 2, 3)
AND     plans.organization_id = arg_plan_organization_id
AND     plans.compile_designator = arg_compile_designator
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     items.inventory_item_id = list.number1
AND     list.query_id = item_list_id
UNION ALL
SELECT  items.inventory_item_id item_id,
        items.organization_id org_id,
        ON_HAND row_type,
        ON_HAND_OFF offset,
        to_date(1, 'J') new_date,
        to_date(1, 'J') old_date,
        items.nettable_inventory_quantity new_quantity,
        0 old_quantity
FROM    mrp_plans plans,
        mrp_system_items  items,
        mrp_form_query      list
WHERE   arg_res_level = 1
AND     (plans.curr_reservation_level  = 4 OR
             plans.curr_reservation_level is NULL)
AND     plans.organization_id = arg_plan_organization_id
AND     plans.compile_designator = arg_compile_designator
AND     items.organization_id = list.number2
AND     items.compile_designator = list.char1
AND     items.inventory_item_id = list.number1
AND     list.query_id = item_list_id
UNION ALL
SELECT  safety.inventory_item_id item_id,
        safety.organization_id org_id,
        SS row_type,
        SS_OFF offset,
        safety.period_start_date new_date,
        safety.period_start_date old_date,
        safety.safety_stock_quantity new_quantity,
        0 old_quantity
FROM    mrp_safety_stock    safety,
        mrp_form_query      list
WHERE   safety.period_start_date < last_date
AND     safety.organization_id = list.number2
AND     safety.compile_designator = list.char1
AND     safety.inventory_item_id = list.number1
AND     list.query_id = item_list_id
UNION ALL
SELECT  sched.inventory_item_id item_id,
        sched.organization_id org_id,
        CURRENT_S row_type,
        CURRENT_S_OFF offset,
        dates.calendar_date new_date,
        dates.calendar_date old_date,
        sched.daily_rate new_quantity,
        0 old_quantity
FROM    mrp_form_query      list,
        mtl_parameters      param,
        mrp_aggregate_rates sched,
        bom_calendar_dates  dates
WHERE   dates.exception_set_id = param.calendar_exception_set_id
AND     dates.calendar_code = param.calendar_code
AND     dates.seq_num IS NOT NULL
AND     dates.calendar_date BETWEEN sched.first_unit_completion_date
AND     sched.last_unit_completion_date
AND     sched.first_unit_completion_date < last_date
AND     sched.compile_designator = list.char1
AND     sched.inventory_item_id = list.number1
AND     sched.organization_id = param.organization_id
AND     param.organization_id = list.number2
AND     list.query_id = item_list_id
UNION ALL
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  list.number1,
        list.number2,
        ON_HAND,
        ON_HAND_OFF,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        0
FROM    mrp_form_query list
WHERE   list.query_id = item_list_id

ORDER BY
     1, 2, 5, 3;

TYPE mrp_activity IS RECORD
     (item_id      NUMBER,
      org_id       NUMBER,
      row_type     NUMBER,
      offset       NUMBER,
      new_date     DATE,
      old_date     DATE,
      new_quantity NUMBER,
      old_quantity NUMBER);

activity_rec     mrp_activity;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_char   IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

var_dates           calendar_date;   -- Holds the start dates of buckets
bucket_cells_tab    column_number;       -- Holds the quantities per bucket
bucket_type_tab     column_number;
bucket_type_txt_tab column_char;
last_item_id        NUMBER := -1;
last_org_id        NUMBER := -1;
prev_ss_quantity    NUMBER := -1;
prev_ss_date        DATE;
ss_quantity         NUMBER := -1;
ss_date             DATE;

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
old_bucket_counter BINARY_INTEGER := 0;
counter        BINARY_INTEGER := 0;

-- =============================================================================
--
-- add_to_plan add the 'quantity' to the correct cell of the current bucket.
--
-- =============================================================================
PROCEDURE add_to_plan(bucket IN NUMBER,
                      offset IN NUMBER,
                      quantity IN NUMBER) IS
location NUMBER;
BEGIN
  IF enterprize_view THEN
    location := (bucket - 1) + offset;
  ELSE
    location := ((bucket - 1) * NUM_OF_TYPES) + offset;
  END IF;
  bucket_cells_tab(location) := NVL(bucket_cells_tab(location),0) + quantity;
END;

-- =============================================================================
--
-- flush_item_plan inserts into MRP_MATERIAL_PLANS
--
-- =============================================================================
PROCEDURE flush_item_plan(inv_item_id IN NUMBER,
                          org_id IN NUMBER) IS
loop_counter BINARY_INTEGER := 1;
item_name VARCHAR2(255);
org_code VARCHAR2(3);
atp_counter  BINARY_INTEGER := 1;
total_reqs      NUMBER := 0;
lot_quantity NUMBER := 0;
expired_qty NUMBER := 0;
total_supply NUMBER := 0;
committed_demand NUMBER := 0;
atp_qty NUMBER := 0;
carried_back_atp_qty NUMBER := 0;
atp_flag NUMBER;

BEGIN
  -- ---------------------
  -- Get the item segments
  -- ---------------------
  SELECT item_number,
         param.organization_code
  INTO   item_name,
         org_code
  FROM   mtl_item_flexfields items,
         mtl_parameters param
  WHERE  param.organization_id = items.organization_id
  AND    items.inventory_item_id = inv_item_id
  AND    items.organization_id = org_id;

 -- -------------------------
 -- get the calculate_atp flag
 -- -------------------------

  SELECT calculate_atp
  INTO   atp_flag
  FROM   mrp_system_items
  WHERE  compile_designator = arg_compile_designator
  AND    inventory_item_id = inv_item_id
  AND    organization_id = org_id;

  IF NOT enterprize_view THEN
    -- -----------------------------
    -- Calculate gross requirements,
    -- Total suppy
    -- PAB
    -- POH
    -- -----------------------------

    FOR loop IN 1..NUM_OF_COLUMNS LOOP
      ----------------------
      -- Gross requirements.
      -- -------------------
--      dbms_output.put_line('r 101');
      lot_quantity := bucket_cells_tab(((loop - 1) * NUM_OF_TYPES)+
                        EXP_LOT_OFF);
      total_reqs := total_reqs +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      FORECAST_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      DEPENDENT_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) +
                      PB_DEMAND_OFF) +
                    bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF);
        --------------------
        -- Lot Expirations
        --------------------
--      dbms_output.put_line('r 102');
        IF(lot_quantity > total_reqs and lot_quantity > 0
           and arg_current_data = 1) THEN
                expired_qty := lot_quantity - total_reqs;
                total_reqs := 0;
                add_to_plan(loop,
                GROSS_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF) +
                                expired_qty);
        ELSE
--      dbms_output.put_line('r 103');
           IF arg_current_data = 1 THEN
-- Exclude lot expiration in the current view.
                add_to_plan(loop,
                GROSS_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF));
           ELSE
--Include Expired lot quantity in the snapshot view.
                add_to_plan(loop,
                GROSS_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SALES_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + FORECAST_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + DEPENDENT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_DEMAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SCRAP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + EXP_LOT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + OTHER_OFF));
           END IF;
        END IF;


      -- -------------
      -- Total supply.
      -- -------------
--      dbms_output.put_line('r 104');
      add_to_plan(loop,
                SUPPLY_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + WIP_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PO_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + REQ_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + TRANSIT_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + RECEIVING_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PB_SUPPLY_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + PLANNED_OFF));

      -- ----------------------------
      -- Projected available balance.
      -- ----------------------------
      IF loop = 1 THEN
--      dbms_output.put_line('r 105');
        add_to_plan(loop,
                PAB_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SUPPLY_OFF)  -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      ELSE
--      dbms_output.put_line('r 106');
        add_to_plan(loop,
                PAB_OFF,
                bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + PAB_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + SUPPLY_OFF)  -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      END IF;

      -- ------------------
      -- Projected on hand.
      -- ------------------
      IF loop = 1 THEN
--      dbms_output.put_line('r 107');
        add_to_plan(loop,
                POH_OFF,
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + ON_HAND_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      ELSE
--      dbms_output.put_line('r 108');
        add_to_plan(loop,
                POH_OFF,
                bucket_cells_tab(((loop - 2) * NUM_OF_TYPES) + POH_OFF) +
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + CURRENT_S_OFF) -
                bucket_cells_tab(((loop - 1) * NUM_OF_TYPES) + GROSS_OFF));
      END IF;

    END LOOP; -- columnd
        ----------------
        -- calculate ATP
        ----------------
    if atp_flag = 1 then -- only calculate atp when atp_flag is 1

         IF arg_current_data = 1 THEN
                FOR      atp_counter IN REVERSE 1..NUM_OF_COLUMNS LOOP
                   IF atp_counter = 1 THEN
                        total_supply := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SUPPLY_OFF)+
                                bucket_cells_tab(((atp_counter - 1) *
                                NUM_OF_TYPES) + ON_HAND_OFF);
                   ELSE
                        total_supply := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SUPPLY_OFF);
                   END IF;
                        committed_demand := bucket_cells_tab(((atp_counter - 1)
                                * NUM_OF_TYPES) + SALES_OFF) +
                                bucket_cells_tab(((atp_counter - 1) *
                                NUM_OF_TYPES) + DEPENDENT_OFF) +
								bucket_cells_tab(((atp_counter - 1) *
								NUM_OF_TYPES) + SCRAP_OFF);
                        atp_qty := total_supply - committed_demand -
                                   carried_back_atp_qty;
                        IF(atp_qty >= 0) THEN
                                add_to_plan(atp_counter, ATP_OFF, atp_qty);
                                carried_back_atp_qty := 0;
                                atp_qty := 0;
                        ELSE
                                add_to_plan(atp_counter, ATP_OFF, 0);
                                carried_back_atp_qty := -atp_qty;
                                atp_qty := 0;
                        END IF;

                END LOOP;
         END IF;
    END IF;

    FOR loop_counter IN 1..NUM_OF_TYPES LOOP
      INSERT INTO mrp_material_plans(
        plan_id,
        organization_id,
        compile_designator,
        plan_organization_id,
        inventory_item_id,
        item_segments,
        organization_code,
        horizontal_plan_type,
        horizontal_plan_type_text,
        bucket_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        quantity1,  quantity2,  quantity3,  quantity4,
        quantity5,  quantity6,  quantity7,  quantity8,
        quantity9,  quantity10,     quantity11,     quantity12,
        quantity13,     quantity14,     quantity15,     quantity16,
        quantity17,     quantity18,     quantity19,     quantity20,
        quantity21,     quantity22,     quantity23,     quantity24,
        quantity25,     quantity26,     quantity27,     quantity28,
        quantity29,     quantity30,     quantity31,     quantity32,
        quantity33,     quantity34,     quantity35,     quantity36)
      VALUES (
        arg_plan_id,
        org_id,
        arg_compile_designator,
        arg_plan_organization_id,
        inv_item_id,
        item_name,
        org_code,
        bucket_type_tab(loop_counter),
        bucket_type_txt_tab(loop_counter),
        --arg_bucket_type,--3468984
        DECODE(arg_current_data, SYS_YES, DECODE(arg_bucket_type, 1, -4, 2, -5, 3, -6),
                                                            decode(arg_bucket_type,1,4,
                                                                                   2,5,
                                                                                   3,6)),
        SYSDATE,
        -1,
        SYSDATE,
        -1,
      bucket_cells_tab((NUM_OF_TYPES * 0) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 1) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 2) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 3) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 4) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 5) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 6) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 7) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 8) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 9) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 10) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 11) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 12) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 13) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 14) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 15) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 16) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 17) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 18) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 19) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 20) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 21) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 22) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 23) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 24) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 25) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 26) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 27) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 28) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 29) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 30) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 31) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 32) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 33) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 34) + loop_counter),
      bucket_cells_tab((NUM_OF_TYPES * 35) + loop_counter));
    END LOOP;
  ELSE
-- apatanka
   bucket_cells_tab(OTHER_OFF) :=
           bucket_cells_tab(OTHER_OFF)+bucket_cells_tab(PB_DEMAND_OFF);
   bucket_cells_tab(GROSS_OFF) :=
           bucket_cells_tab(SALES_OFF)+bucket_cells_tab(FORECAST_OFF)+
           bucket_cells_tab(DEPENDENT_OFF)+bucket_cells_tab(SCRAP_OFF)+
           bucket_cells_tab(OTHER_OFF);
   bucket_cells_tab(SUPPLY_OFF):=
           bucket_cells_tab(WIP_OFF)+bucket_cells_tab(PO_OFF)+
           bucket_cells_tab(REQ_OFF)+bucket_cells_tab(TRANSIT_OFF)+
           bucket_cells_tab(RECEIVING_OFF)+bucket_cells_tab(PLANNED_OFF)+
           bucket_cells_tab(PB_SUPPLY_OFF);

    INSERT INTO mrp_material_plans(
      plan_id,
      organization_id,
      compile_designator,
      plan_organization_id,
      inventory_item_id,
      item_segments,
      organization_code,
      horizontal_plan_type,
      horizontal_plan_type_text,
      bucket_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      quantity1,  quantity2,  quantity3,  quantity4,
      quantity5,  quantity6,  quantity7,  quantity8,
      quantity9,  quantity10,     quantity11,     quantity12,
      quantity13,     quantity14,     quantity15,     quantity16,
      quantity17,     quantity18,     quantity19,     quantity20,
      quantity21,     quantity22,     quantity23,     quantity24,
      quantity25,     quantity26,     quantity27,     quantity28,
      quantity29,     quantity30,     quantity31,     quantity32,
      quantity33,     quantity34,     quantity35,     quantity36)
    VALUES (
      arg_plan_id,
      org_id,
      arg_compile_designator,
      arg_plan_organization_id,
      inv_item_id,
      item_name,
      org_code,
      10,
      'ENTERPRIZE_VIEW',
      arg_bucket_type,
      SYSDATE,
      -1,
      SYSDATE,
      -1,
    bucket_cells_tab(1),
    bucket_cells_tab(2),
    bucket_cells_tab(3),
    bucket_cells_tab(4),
    bucket_cells_tab(5),
    bucket_cells_tab(6),
    bucket_cells_tab(7),
    bucket_cells_tab(8),
    bucket_cells_tab(9),
    bucket_cells_tab(10),
    bucket_cells_tab(11),
    bucket_cells_tab(12),
    bucket_cells_tab(13),
    bucket_cells_tab(14),
    bucket_cells_tab(15),
    bucket_cells_tab(16),
    bucket_cells_tab(17),
    bucket_cells_tab(18),
    bucket_cells_tab(19),
    bucket_cells_tab(20),
    bucket_cells_tab(21),
    bucket_cells_tab(22),
    bucket_cells_tab(23),
    bucket_cells_tab(24),
    bucket_cells_tab(25),
    bucket_cells_tab(26),
    bucket_cells_tab(27),
    bucket_cells_tab(28),
    bucket_cells_tab(29),
    bucket_cells_tab(30),
    bucket_cells_tab(31),
    bucket_cells_tab(32),
    bucket_cells_tab(33),
    bucket_cells_tab(34),
    bucket_cells_tab(35),
    bucket_cells_tab(36));
-- apatanka
--   update mrp_material_plans set quantity6 = quantity1+quantity2+quantity3
--  +quantity4+quantity5
--   where inventory_item_id = inv_item_id and
--   organization_id = arg_plan_organization_id and
--         compile_designator = arg_compile_designator and
--   horizontal_plan_type_text = 'ENTERPRIZE_VIEW';


  END IF;

END flush_item_plan;

-- =============================================================================
BEGIN
--- fnd_global.initialize (sid, 0, 101, 1, 0, 0, 0, 0, 0, 0);

  SELECT OE_INSTALL.Get_Active_Product
  INTO l_oe_install
  FROM DUAL;

  -- --------------------------
  -- Setup the row type tables.
  -- --------------------------
  counter := 1;

  IF NOT enterprize_view THEN
    OPEN row_types;

    LOOP
      FETCH row_types
      INTO  row_type_rec;

      EXIT WHEN row_types%NOTFOUND;

      bucket_type_tab(counter) := row_type_rec.lookup_code;
      bucket_type_txt_tab(counter) := row_type_rec.meaning;
      counter := counter + 1;
    END LOOP;
    CLOSE row_types;
  END IF;

  -- ---------------------------------
  -- Initialize the bucket cells to 0.
  -- ---------------------------------
  IF enterprize_view THEN
    FOR counter IN 1..NUM_OF_COLUMNS LOOP
      bucket_cells_tab(counter) := 0;
    END LOOP;
    last_date := arg_cutoff_date;
  ELSE
    FOR counter IN 1..(NUM_OF_TYPES * NUM_OF_COLUMNS) LOOP
      bucket_cells_tab(counter) := 0;
    END LOOP;

    -- --------------------
-- Bug 3468984 bucket_type clause changed for 4,5,6
    -- Get the bucket dates
    -- --------------------
    SELECT
      date1,  date2,  date3,  date4,
      date5,  date6,  date7,  date8,
      date9,  date10, date11, date12,
      date13, date14, date15, date16,
      date17, date18, date19, date20,
      date21, date22, date23, date24,
      date25, date26, date27, date28,
      date29, date30, date31, date32,
      date33, date34, date35, date36,
      date37
    INTO
      var_dates(1),  var_dates(2),  var_dates(3),  var_dates(4),
      var_dates(5),  var_dates(6),  var_dates(7),  var_dates(8),
      var_dates(9),  var_dates(10), var_dates(11), var_dates(12),
      var_dates(13), var_dates(14), var_dates(15), var_dates(16),
      var_dates(17), var_dates(18), var_dates(19), var_dates(20),
      var_dates(21), var_dates(22), var_dates(23), var_dates(24),
      var_dates(25), var_dates(26), var_dates(27), var_dates(28),
      var_dates(29), var_dates(30), var_dates(31), var_dates(32),
      var_dates(33), var_dates(34), var_dates(35), var_dates(36),
      var_dates(37)
    FROM  mrp_workbench_bucket_dates
    WHERE NVL(planned_organization, organization_id) = arg_organization_id
    AND   organization_id = arg_plan_organization_id
    AND   compile_designator  = arg_compile_designator
    AND   bucket_type         = DECODE(arg_current_data, SYS_YES,
                                    DECODE(arg_bucket_type, 1, -4,
                                                            2, -5,
                                                            3, -6),
                                                            decode(arg_bucket_type,1,4,
                                                                                   2,5,
                                                                                   3,6));
    last_date := LEAST(var_dates(37), arg_cutoff_date);
  END IF;

  bucket_counter := 2;
  old_bucket_counter := 2;

  IF arg_current_data = 1 THEN
  	OPEN mrp_current_activity_ont_I;
  ELSE
     OPEN mrp_snapshot_activity;
  END IF;

  LOOP

    IF arg_current_data = 1 THEN
    	FETCH mrp_current_activity_ont_I
             INTO  activity_rec;
   --    dbms_output.put_line('item_id:' ||activity_rec.item_id );
      IF ( mrp_current_activity_ont_I%NOTFOUND OR
          (activity_rec.item_id <> last_item_id) OR
          ( activity_rec.org_id  <> last_org_id)) AND
         last_item_id <> -1 THEN

        -- --------------------------
        -- Need to flush the plan for
        -- the previous item.
        -- --------------------------
        IF prev_ss_quantity <> -1 AND
           NOT enterprize_view THEN
          FOR k IN bucket_counter..NUM_OF_COLUMNS LOOP
            add_to_plan(k - 1,
                        SS_OFF,
                        prev_ss_quantity);
          END LOOP;
        END IF;
        flush_item_plan(last_item_id,
                        last_org_id);

        bucket_counter := 2;
        old_bucket_counter := 2;
        prev_ss_quantity := -1;
        ss_quantity :=-1;
        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
        IF enterprize_view THEN
          FOR counter IN 1..NUM_OF_COLUMNS LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        ELSE
          FOR counter IN 1..(NUM_OF_TYPES * NUM_OF_COLUMNS) LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
      END IF;

    EXIT WHEN mrp_current_activity_ont_I%NOTFOUND;

    ELSE
      FETCH mrp_snapshot_activity
      INTO  activity_rec;
--        dbms_output.put_line('item_id:' ||activity_rec.item_id );
      IF ((mrp_snapshot_activity%NOTFOUND) OR
          (activity_rec.item_id <> last_item_id) OR
          ( activity_rec.org_id  <> last_org_id)) AND
         last_item_id <> -1 THEN

        -- --------------------------
        -- Need to flush the plan for
        -- the previous item.
        -- --------------------------
        IF prev_ss_quantity <> -1 AND
           NOT enterprize_view THEN
          FOR k IN bucket_counter..NUM_OF_COLUMNS LOOP
            add_to_plan(k - 1,
                        SS_OFF,
                        prev_ss_quantity);
          END LOOP;
        END IF;
        flush_item_plan(last_item_id,
                        last_org_id);

        bucket_counter := 2;
        old_bucket_counter := 2;
        prev_ss_quantity := -1;
        ss_quantity :=-1;
        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
        IF enterprize_view THEN
          FOR counter IN 1..NUM_OF_COLUMNS LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        ELSE
          FOR counter IN 1..(NUM_OF_TYPES * NUM_OF_COLUMNS) LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
      END IF;

      EXIT WHEN mrp_snapshot_activity%NOTFOUND;
    END IF;

    IF enterprize_view THEN
      IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
        add_to_plan(CURRENT_S_OFF + 1, 0, activity_rec.old_quantity);
      END IF;
      add_to_plan(activity_rec.offset + 1 , 0,
      activity_rec.new_quantity);
    ELSE
      IF activity_rec.row_type = SS THEN

        -- --------------------------
        -- Got a safety stock record.
        -- --------------------------
        ss_quantity := activity_rec.new_quantity;
        ss_date := activity_rec.new_date;

        IF activity_rec.new_date < var_dates(bucket_counter) THEN
          -- ----------------------------------
          -- This safety stock quantity applies
          -- to the current bucket.
          -- ----------------------------------
          prev_ss_quantity := activity_rec.new_quantity;
          prev_ss_date := activity_rec.new_date;
        END IF;
      END IF;

      IF activity_rec.new_date >= var_dates(bucket_counter) THEN

        -- -------------------------------------------------------
        -- We got an activity falls after the current bucket. So we
        -- will move the bucket counter forward until we find the
        -- bucket where this activity falls.  Note that we should
        -- not advance the counter bejond NUM_OF_COLUMNS.
        -- --------------------------------------------------------
        WHILE activity_rec.new_date >= var_dates(bucket_counter) AND
              bucket_counter <= NUM_OF_COLUMNS LOOP

          -- -----------------------------------------------------
          -- If the variable last_ss_quantity is not -1 then there
          -- is a safety stock entry that we need to add for the
          -- current bucket before we move the bucket counter
          -- forward.
          -- -----------------------------------------------------
          IF prev_ss_quantity <> -1 THEN
            add_to_plan(bucket_counter - 1,
                        SS_OFF,
                        prev_ss_quantity);
--             prev_ss_quantity := -1;
          END IF;

          bucket_counter := bucket_counter + 1;

        END LOOP;
        prev_ss_quantity := ss_quantity;
        prev_ss_date := ss_date;
      END IF;

      -- ---------------------------------------------------------
      -- Add the retrieved activity to the plan if it falls in the
      -- current bucket and it is not a safety stock entry.
      -- ---------------------------------------------------------
      IF activity_rec.new_date < var_dates(bucket_counter) AND
         activity_rec.row_type <> SS THEN
        add_to_plan(bucket_counter - 1,
            activity_rec.offset,
                    activity_rec.new_quantity);
      END IF;

      -- -------------------------------------
      -- Add to the current schedule receipts.
      -- -------------------------------------
      IF activity_rec.row_type IN (WIP, PO, REQ, TRANSIT,
                                   RECEIVING, PB_SUPPLY) THEN
        WHILE activity_rec.old_date >= var_dates(old_bucket_counter) AND
             old_bucket_counter <= NUM_OF_COLUMNS LOOP
          -- ----------
          -- move back.
          -- ----------
          old_bucket_counter := old_bucket_counter + 1;

        END LOOP;

        WHILE activity_rec.old_date < var_dates(old_bucket_counter - 1)  AND
           /* old_bucket_counter < 2  LOOP 2159997 */

              old_bucket_counter  > 2  LOOP /*Bug 2159997*/
          -- -------------
          -- move forward.
          -- -------------
          old_bucket_counter := old_bucket_counter  - 1;
        END LOOP;
        IF activity_rec.old_date < var_dates(old_bucket_counter) THEN
          add_to_plan(old_bucket_counter - 1,
                      CURRENT_S_OFF,
                      activity_rec.old_quantity);
        END IF;
      END IF;
    END IF;
    last_item_id := activity_rec.item_id;
    last_org_id := activity_rec.org_id;
  END LOOP;

  IF arg_current_data = 1 THEN
    CLOSE mrp_current_activity_ont_I;
 ELSE
     CLOSE mrp_snapshot_activity;
  END IF;

END;
END;

/
