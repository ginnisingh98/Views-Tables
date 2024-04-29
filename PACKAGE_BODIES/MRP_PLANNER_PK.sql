--------------------------------------------------------
--  DDL for Package Body MRP_PLANNER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PLANNER_PK" AS
/* $Header: MRPPPLNB.pls 115.14 2004/01/22 02:29:56 schaudha ship $ */

BUFFER_SIZE_LEN     CONSTANT INTEGER := 1000000;
TYPE col_date       IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE col_number     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_rowid   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE col_bool       IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
var_debug           BOOLEAN;


-- ********************** mb_delete_ms_outside_tf *************************
PROCEDURE   mb_delete_ms_outside_tf(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_jcurr_date      IN  NUMBER) IS
BEGIN
            mb_delete_ms_outside_tf(arg_compile_desig,
                                arg_org_id,
                                arg_jcurr_date,
                                NULL_VALUE);
END mb_delete_ms_outside_tf;

-- ********************** mb_delete_ms_outside_tf *************************
PROCEDURE   mb_delete_ms_outside_tf(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_jcurr_date      IN  NUMBER,
                            arg_query_id        IN  NUMBER) IS
--1851794--
                            var_bkwd_compat     VARCHAR2(2) := FND_PROFILE.VALUE('MRP_NEW_PLANNER_BACK_COMPATIBILITY');

BEGIN
    /*-------------------------------------------------------------+
     |  We need to go to mtl_system_items because mrp_system_items |
     |  may not have been populated at that point                  |
     +-------------------------------------------------------------*/
--1851794 For phantoms if backward compatibility is yes treat them like standard items
    DELETE  mrp_schedule_dates dates
    WHERE  EXISTS
            (SELECT NULL
            FROM    bom_calendar_dates cal1,
                    bom_calendar_dates cal2,
                    mtl_parameters param,
                    mtl_system_items sys
            WHERE   dates.schedule_date > cal1.calendar_date
            AND     cal1.exception_set_id = cal2.exception_set_id
            AND     cal1.calendar_code = cal2.calendar_code
            AND     cal1.seq_num  = cal2.prior_seq_num +
                        NVL(DECODE(sys.wip_supply_type,
                            PHANTOM_ASSY,DECODE(var_bkwd_compat,'N',0,'Y',
                            DECODE(sys.planning_time_fence_code, USER_TF,
                            CEIL(sys.planning_time_fence_days),
                            CUM_TOTAL_LT,
                            CEIL(sys.cumulative_total_lead_time),
                            CUM_MFG_LT,
                            CEIL(sys.cum_manufacturing_lead_time),
                            TOTAL_LT, CEIL(sys.full_lead_time))),
                            DECODE(sys.planning_time_fence_code, USER_TF,
                            CEIL(sys.planning_time_fence_days),
                            CUM_TOTAL_LT,
                            CEIL(sys.cumulative_total_lead_time),
                            CUM_MFG_LT,
                            CEIL(sys.cum_manufacturing_lead_time),
                            TOTAL_LT, CEIL(sys.full_lead_time))), 0)
            AND     cal2.exception_set_id = param.calendar_exception_set_id
            AND     cal2.calendar_code = param.calendar_code
            AND     cal2.calendar_date = TO_DATE(arg_jcurr_date, 'J')
            AND     param.organization_id = sys.organization_id
            AND     sys.organization_id = dates.organization_id
            AND     sys.inventory_item_id = dates.inventory_item_id)
    AND     dates.supply_demand_type = SCHEDULE_SUPPLY
    AND     dates.schedule_level IN (ORIG_SCHEDULE, UPDATED_SCHEDULE)
    AND     (arg_query_id = NULL_VALUE
             OR
             (dates.inventory_item_id, dates.organization_id)  in
             (SELECT    number1, number2
              from      mrp_form_query
              WHERE     query_id = arg_query_id))
    AND     organization_id in
            (select planned_organization
             from   mrp_plan_organizations_v
             where  organization_id = arg_org_id
             and    compile_designator = arg_compile_desig)
    AND     schedule_designator = arg_compile_desig;

    /*-------------------------------------------------------------+
     |  We need to delete the past due planned orders where the    |
     |  planning time fence is 0.                                  |
     |  Only the planned orders with schedule_quantity OR          |
     |  repetitive_daily_rate > 0 are deleted. This takes care of  |
     |  The schedule consumption information.                      |
     +-------------------------------------------------------------*/

    DELETE  mrp_schedule_dates dates
    WHERE  EXISTS
            (SELECT NULL
            FROM    mtl_system_items sys
            WHERE
                        NVL(DECODE(sys.wip_supply_type,
                            PHANTOM_ASSY, 0,
                            DECODE(sys.planning_time_fence_code, USER_TF,
                            CEIL(sys.planning_time_fence_days),
                            CUM_TOTAL_LT,
                            CEIL(sys.cumulative_total_lead_time),
                            CUM_MFG_LT,
                            CEIL(sys.cum_manufacturing_lead_time),
                            TOTAL_LT, CEIL(sys.full_lead_time))), 0) = 0
            AND     sys.organization_id = dates.organization_id
            AND     sys.inventory_item_id = dates.inventory_item_id)
    AND     dates.supply_demand_type = SCHEDULE_SUPPLY
    AND     dates.schedule_level IN (ORIG_SCHEDULE, UPDATED_SCHEDULE)
    AND     DECODE(dates.rate_end_date, NULL,
                 dates.schedule_quantity, dates.repetitive_daily_rate) > 0
    AND     (arg_query_id = NULL_VALUE
             OR
             (dates.inventory_item_id, dates.organization_id)  in
             (SELECT    number1, number2
              from      mrp_form_query
              WHERE     query_id = arg_query_id))
    AND     organization_id in
            (select planned_organization
             from   mrp_plan_organizations_v
             where  organization_id = arg_org_id
             and    compile_designator = arg_compile_desig)
    AND     schedule_designator = arg_compile_desig;

    COMMIT;

    UPDATE  mrp_schedule_dates dates
    SET     rate_end_date =
            (SELECT cal1.calendar_date
            FROM    bom_calendar_dates cal1,
                    bom_calendar_dates cal2,
                    mtl_parameters param,
                    mtl_system_items sys
            WHERE   dates.rate_end_date > cal1.calendar_date
            AND     dates.schedule_date <= cal1.calendar_date
            AND     cal1.exception_set_id = cal2.exception_set_id
            AND     cal1.calendar_code = cal2.calendar_code
            AND     cal1.seq_num  = cal2.next_seq_num +
                        NVL(DECODE(sys.wip_supply_type,
                            PHANTOM_ASSY, 0,
                            DECODE(sys.planning_time_fence_code, USER_TF,
                            CEIL(sys.planning_time_fence_days),
                            CUM_TOTAL_LT,
                            CEIL(sys.cumulative_total_lead_time),
                            CUM_MFG_LT,
                            CEIL(sys.cum_manufacturing_lead_time),
                            TOTAL_LT, CEIL(sys.full_lead_time))), 0)
            AND     cal2.exception_set_id = param.calendar_exception_set_id
            AND     cal2.calendar_code = param.calendar_code
            AND     cal2.calendar_date = TO_DATE(arg_jcurr_date, 'J')
            AND     param.organization_id = sys.organization_id
            AND     sys.organization_id = dates.organization_id
            AND     sys.inventory_item_id = dates.inventory_item_id)
    WHERE   EXISTS
            (SELECT NULL
            FROM    bom_calendar_dates cal1,
                    bom_calendar_dates cal2,
                    mtl_parameters param,
                    mtl_system_items sys
            WHERE   dates.rate_end_date > cal1.calendar_date
            AND     dates.schedule_date <= cal1.calendar_date
            AND     cal1.exception_set_id = cal2.exception_set_id
            AND     cal1.calendar_code = cal2.calendar_code
            AND     cal1.seq_num  = cal2.next_seq_num +
                        NVL(DECODE(sys.wip_supply_type,
                            PHANTOM_ASSY, 0,
                            DECODE(sys.planning_time_fence_code, USER_TF,
                            CEIL(sys.planning_time_fence_days),
                            CUM_TOTAL_LT,
                            CEIL(sys.cumulative_total_lead_time),
                            CUM_MFG_LT,
                            CEIL(sys.cum_manufacturing_lead_time),
                            TOTAL_LT, CEIL(sys.full_lead_time))), 0)
            AND     cal2.exception_set_id = param.calendar_exception_set_id
            AND     cal2.calendar_code = param.calendar_code
            AND     cal2.calendar_date = TO_DATE(arg_jcurr_date, 'J')
            AND     param.organization_id = sys.organization_id
            AND     sys.organization_id = dates.organization_id
            AND     sys.inventory_item_id = dates.inventory_item_id)
    AND     dates.supply_demand_type = SCHEDULE_SUPPLY
    AND     dates.rate_end_date is NOT NULL
    AND     dates.schedule_level IN (ORIG_SCHEDULE, UPDATED_SCHEDULE)
    AND     (arg_query_id = NULL_VALUE
             OR
             (dates.inventory_item_id, dates.organization_id)  in
             (SELECT    number1, number2
              from      mrp_form_query
              WHERE     query_id = arg_query_id))
    AND     organization_id in
            (select planned_organization
             from   mrp_plan_organizations_v
             where  organization_id = arg_org_id
             and    compile_designator = arg_compile_desig)
    AND     schedule_designator = arg_compile_desig;

    COMMIT;

END mb_delete_ms_outside_tf;

-- ********************** create_new_planner_mps_entries ********************
PROCEDURE   create_new_planner_mps_entries(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_sched_desig     IN  VARCHAR2,
                            arg_org_id          IN  NUMBER) IS

    MPS_AND_DRP_PLANNING CONSTANT INTEGER := 8;

BEGIN
    INSERT INTO mrp_schedule_dates
                 (inventory_item_id,
                 reference_schedule_id,
                 organization_id,
                 schedule_designator,
                 schedule_level,
                 schedule_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 schedule_quantity,
                 schedule_origination_type,
                 source_forecast_designator,
                 source_organization_id,
                 source_schedule_designator,
                 mps_transaction_id,
                 repetitive_daily_rate,
                 rate_end_date,
                 schedule_workdate,
                 original_schedule_quantity,
                 supply_demand_type,
                 project_id,
                 task_id,
				 line_id,
				 end_item_unit_number)
        SELECT   changes.inventory_item_id,
                 changes.transaction_id,
                 changes.organization_id,
                 changes.compile_designator,
                 UPDATED_SCHEDULE,
                 changes.new_schedule_date,
                 SYSDATE,
                 changes.last_updated_by,
                 SYSDATE,
                 changes.last_updated_by,
                 -1,
                 DECODE(changes.order_type,
                     PLANNED_ORDER, changes.new_order_quantity,
                     NULL),
                 SCHED_MPS_PLAN,
                 NULL,
                 changes.source_organization_id,
                 arg_sched_desig,
                 mrp_schedule_dates_s.nextval,
                 daily_rate,
                 last_unit_completion_date,
                 new_schedule_date,
                 changes.new_order_quantity,
                 SCHEDULE_SUPPLY,
                 changes.project_id,
                 changes.task_id,
				 changes.line_id,
				 changes.end_item_unit_number
        FROM    mrp_recommendations   changes,
                mrp_system_items       data
        WHERE   NOT EXISTS
                (SELECT NULL
                FROM    mrp_schedule_dates dates
                WHERE   dates.schedule_level = UPDATED_SCHEDULE
                  AND   dates.organization_id = changes.organization_id
                  AND   dates.inventory_item_id = changes.inventory_item_id
                  AND   dates.schedule_designator = changes.compile_designator
                  AND   dates.reference_schedule_id = changes.transaction_id)
          AND   changes.organization_id = data.organization_id
          AND   changes.compile_designator = data.compile_designator
          AND   changes.inventory_item_id = data.inventory_item_id
          AND   changes.order_type IN (PLANNED_ORDER, REPETITVE_SCHEDULE)
          AND   data.mrp_planning_code IN (MPS_PLANNING, MPS_AND_DRP_PLANNING)
          AND   data.organization_id IN (select planned_organization
                    from mrp_plan_organizations_v
                    where organization_id = arg_org_id
                    and compile_designator = arg_compile_desig)
          AND   data.compile_designator = arg_compile_desig;

    COMMIT;
END create_new_planner_mps_entries;


-- ********************** create_orig_mps_entries *************************
PROCEDURE   create_orig_mps_entries(
                            arg_sched_desig     IN  VARCHAR2,
                            arg_org_id          IN  NUMBER) IS
BEGIN
    INSERT INTO mrp_schedule_dates
                 (inventory_item_id,
                 reference_schedule_id,
                 organization_id,
                 schedule_designator,
                 schedule_level,
                 schedule_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 schedule_quantity,
                 schedule_origination_type,
                 repetitive_daily_rate,
                 source_forecast_designator,
                 rate_end_date,
                 mps_transaction_id,
                 schedule_comments,
                 source_organization_id,
                 source_schedule_designator,
                 schedule_workdate,
                 original_schedule_quantity,
                 supply_demand_type)
        SELECT   inventory_item_id,
                 reference_schedule_id,
                 organization_id,
                 schedule_designator,
                 ORIG_SCHEDULE,
                 schedule_date,
                 last_update_date,
                 last_updated_by,
                 SYSDATE,
                 last_updated_by,
                 -1,
                 schedule_quantity,
                 schedule_origination_type,
                 repetitive_daily_rate,
                 source_forecast_designator,
                 rate_end_date,
                 mps_transaction_id,
                 schedule_comments,
                 source_organization_id,
                 source_schedule_designator,
                 schedule_date,
                 original_schedule_quantity,
                 supply_demand_type
        FROM    mrp_schedule_dates  dates
        WHERE   NOT EXISTS
                (SELECT NULL
                FROM    mrp_schedule_dates
                WHERE   mps_transaction_id =
                            dates.mps_transaction_id
                  AND   schedule_level = ORIG_SCHEDULE)
          AND   schedule_level = UPDATED_SCHEDULE
          AND   (organization_id = arg_org_id OR arg_org_id IS NULL)
          AND   (schedule_designator = arg_sched_desig OR
                arg_sched_desig IS NULL);

    COMMIT;
END create_orig_mps_entries;

-- ********************** create_mbp_orig_mps_entries *************************
PROCEDURE   create_mbp_orig_mps_entries(
                            arg_sched_desig     IN  VARCHAR2,
                            arg_org_id          IN  NUMBER) IS
BEGIN
    INSERT INTO mrp_schedule_dates
                 (inventory_item_id,
                 reference_schedule_id,
                 organization_id,
                 schedule_designator,
                 schedule_level,
                 schedule_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 schedule_quantity,
                 schedule_origination_type,
                 repetitive_daily_rate,
                 source_forecast_designator,
                 rate_end_date,
                 mps_transaction_id,
                 schedule_comments,
                 source_organization_id,
                 source_schedule_designator,
                 schedule_workdate,
                 original_schedule_quantity,
                 supply_demand_type,
                 project_id,
                 task_id,
				 line_id)
        SELECT   inventory_item_id,
                 reference_schedule_id,
                 organization_id,
                 schedule_designator,
                 ORIG_SCHEDULE,
                 schedule_date,
                 last_update_date,
                 last_updated_by,
                 SYSDATE,
                 last_updated_by,
                 -1,
                 schedule_quantity,
                 schedule_origination_type,
                 repetitive_daily_rate,
                 source_forecast_designator,
                 rate_end_date,
                 mps_transaction_id,
                 schedule_comments,
                 source_organization_id,
                 source_schedule_designator,
                 schedule_date,
                 original_schedule_quantity,
                 supply_demand_type,
                 project_id,
                 task_id,
				 line_id
        FROM    mrp_schedule_dates  dates
        WHERE   NOT EXISTS
                (SELECT NULL
                FROM    mrp_schedule_dates
                WHERE   mps_transaction_id =
                            dates.mps_transaction_id
                  AND   schedule_level = ORIG_SCHEDULE)
          AND   schedule_level = UPDATED_SCHEDULE
          AND   organization_id IN (select planned_organization
                            from mrp_plan_organizations_v
                            where organization_id = arg_org_id
                            and compile_designator = arg_sched_desig)
          AND   schedule_designator = arg_sched_desig;

END create_mbp_orig_mps_entries;

END; -- package

/
