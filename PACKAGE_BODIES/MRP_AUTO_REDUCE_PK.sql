--------------------------------------------------------
--  DDL for Package Body MRP_AUTO_REDUCE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_AUTO_REDUCE_PK" AS
/* $Header: MRPPARPB.pls 115.1 99/07/16 12:31:23 porting ship $'*/

PROCEDURE mrp_auto_reduce_mps(
                            arg_sched_mgr       IN      NUMBER,
                            arg_org_id          IN      NUMBER,
                            arg_user_id         IN      NUMBER,
                            arg_sched_desig     IN      VARCHAR2,
                            arg_request_id      IN      NUMBER) IS
--  Constant declarations
    MPS_AUTO_NONE           CONSTANT INTEGER := 1;
    MPS_AUTO_PAST_DUE       CONSTANT INTEGER := 2;
    MPS_AUTO_DEMAND_TF      CONSTANT INTEGER := 3;
    MPS_AUTO_PLANNING_TF    CONSTANT INTEGER := 4;
    CUM_TOTAL_LT            CONSTANT INTEGER := 1;
    CUM_MFG_LT              CONSTANT INTEGER := 2;
    TOTAL_LT                CONSTANT INTEGER := 3;
    USER_TF                 CONSTANT INTEGER := 4;
    UPDATED_SCHEDULE        CONSTANT INTEGER := 2;
    MTL_SUPPLY_TYPE         CONSTANT INTEGER := 2;
    SYS_YES                 CONSTANT INTEGER := 1;
    MPS_RELIEF              CONSTANT INTEGER := 2;
    R_AUTO_REDUCE           CONSTANT INTEGER := 4;

    transaction_id          mrp_schedule_dates.mps_transaction_id%TYPE;
    sched_quantity          mrp_schedule_dates.schedule_quantity%TYPE;
    sched_date              mrp_schedule_dates.schedule_date%TYPE;
    sched_rowid             ROWID;
    var_watch_id            NUMBER;
    rows_processed          NUMBER := 0;
    VERSION                 CONSTANT CHAR(80) :=
        '$Header: MRPPARPB.pls 115.1 99/07/16 12:31:23 porting ship $';

--  Declare the cursor for selecting discrete MPS entries that past the
--  user-defined auto-reduction date

    CURSOR DISCRETE_SCHEDULES_CUR IS
        SELECT  mps_transaction_id,
                schedule_quantity,
                schedule_date,
                rowid
        FROM    mrp_schedule_dates dates
        WHERE   exists
                (SELECT NULL
                 FROM   bom_calendar_dates cal1,
                        bom_calendar_dates cal2,
                        mtl_parameters param,
                        mtl_system_items sys
                 WHERE  cal1.calendar_code = param.calendar_code
                 AND    cal1.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal1.calendar_date = TRUNC(SYSDATE)
                 AND    cal2.calendar_code = param.calendar_code
                 AND    cal2.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal2.seq_num = cal1.next_seq_num  +
                        (DECODE(sys.auto_reduce_mps,
                            MPS_AUTO_PAST_DUE,
                            0,
                            MPS_AUTO_DEMAND_TF,
                            DECODE(sys.demand_time_fence_code,
                                USER_TF,
                                CEIL(
                                    NVL(sys.demand_time_fence_days, 0)),
                                CUM_TOTAL_LT,
                                  CEIL(
                                    NVL(sys.cumulative_total_lead_time,
                                        0)),
                                CUM_MFG_LT,
                                  CEIL(
                                    NVL(sys.cum_manufacturing_lead_time,
                                        0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0))),
                            MPS_AUTO_PLANNING_TF,
                                DECODE(sys.planning_time_fence_code,
                                USER_TF,
                                  CEIL(
                                    NVL(sys.planning_time_fence_days,
                                        0)),
                                CUM_TOTAL_LT,
                                  CEIL(
                                    NVL(sys.cumulative_total_lead_time,
                                        0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0)))))
                AND     dates.schedule_date <  cal2.calendar_date
                AND     param.organization_id = dates.organization_id
                AND     sys.organization_id = dates.organization_id
                AND     sys.auto_reduce_mps <> MPS_AUTO_NONE
                AND     sys.auto_reduce_mps is not null
                AND     sys.inventory_item_id = dates.inventory_item_id)
        AND     dates.schedule_level = UPDATED_SCHEDULE
        AND     dates.supply_demand_type = MTL_SUPPLY_TYPE
        AND     dates.schedule_quantity <> 0
        AND     dates.rate_end_date is NULL
        AND     dates.organization_id = DECODE(arg_sched_mgr, SYS_YES,
                    dates.organization_id, arg_org_id)
        AND     dates.schedule_designator = DECODE(arg_sched_mgr,
                    SYS_YES, dates.schedule_designator,
                    arg_sched_desig);

BEGIN

--  If called for discrete schedules select all the discrete entries that
--  are past the auto-reduction date, insert a row into
--  mrp_schedule_consumptions, and then reduce the MPS entry to zero.

    var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                              arg_request_id,
                                              arg_user_id,
                                              'ENTITY',
                                              'mrp_schedule_dates',
                                              'N');
        OPEN    DISCRETE_SCHEDULES_CUR;
        LOOP
            FETCH   DISCRETE_SCHEDULES_CUR  INTO
                    transaction_id,
                    sched_quantity,
                    sched_date,
                    sched_rowid;

            EXIT WHEN   DISCRETE_SCHEDULES_CUR%NOTFOUND;

            rows_processed := rows_processed + 1;

            INSERT INTO mrp_schedule_consumptions(
                transaction_id,
                relief_type,
                disposition_type,
                disposition_id,
                line_num,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                order_date,
                order_quantity,
                relief_quantity,
                schedule_date,
                program_application_id,
                program_id,
                program_update_date)
            VALUES (
                transaction_id,
                MPS_RELIEF,
                R_AUTO_REDUCE,
                NULL,
                NULL,
                SYSDATE,
                arg_user_id,
                SYSDATE,
                arg_user_id,
                arg_user_id,
                sched_date,
                sched_quantity,
                sched_quantity,
                sched_date,
                NULL,
                NULL,
                NULL);

            UPDATE  mrp_schedule_dates
            SET     schedule_quantity = 0,
                    last_updated_by = arg_user_id,
                    last_update_date = SYSDATE
            WHERE   rowid = sched_rowid;

        END LOOP;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                rows_processed);

--  Delete all the repetitive entries that are past the auto-reduce date

    var_watch_id := mrp_print_pk.start_watch('GEN-deleting from table',
                                              arg_request_id,
                                              arg_user_id,
                                              'ROUTINE',
                                              'mrarmps_auto_reduce_mps',
                                              'N',
                                              'TABLE',
                                              'mrp_schedule_dates',
                                              'N');
        DELETE  mrp_schedule_dates dates
        WHERE   exists
                (SELECT NULL
                 FROM   bom_calendar_dates cal1,
                        bom_calendar_dates cal2,
                        mtl_parameters param,
                        mtl_system_items sys
                 WHERE  cal1.calendar_code = param.calendar_code
                 AND    cal1.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal1.calendar_date = TRUNC(SYSDATE)
                 AND    cal2.calendar_code = param.calendar_code
                 AND    cal2.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal2.seq_num = cal1.next_seq_num  +
                        (DECODE(sys.auto_reduce_mps,
                            MPS_AUTO_PAST_DUE,
                            0,
                            MPS_AUTO_DEMAND_TF,
                            DECODE(sys.demand_time_fence_code,
                                USER_TF,
                                  CEIL(
                                    NVL(sys.demand_time_fence_days, 0)),
                                CUM_TOTAL_LT,
                                  CEIL(
                                    NVL(sys.cumulative_total_lead_time,
                                        0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0))),
                            MPS_AUTO_PLANNING_TF,
                            DECODE(sys.planning_time_fence_code,
                                USER_TF,
                                  CEIL(NVL(
                                    sys.planning_time_fence_days, 0)),
                                CUM_TOTAL_LT,
                                  CEIL(NVL(
                                    sys.cumulative_total_lead_time, 0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0)))))
                AND     dates.rate_end_date < cal2.calendar_date
                AND     param.organization_id = dates.organization_id
                AND     sys.organization_id = dates.organization_id
                AND     sys.auto_reduce_mps <> MPS_AUTO_NONE
                AND     sys.auto_reduce_mps is not null
                AND     sys.inventory_item_id = dates.inventory_item_id)
        AND     dates.schedule_level = UPDATED_SCHEDULE
        AND     dates.supply_demand_type = MTL_SUPPLY_TYPE
        AND     dates.rate_end_date is NOT NULL
        AND     dates.organization_id = DECODE(arg_sched_mgr, SYS_YES,
                    dates.organization_id, arg_org_id)
        AND     dates.schedule_designator = DECODE(arg_sched_mgr,
                    SYS_YES, dates.schedule_designator,
                    arg_sched_desig);

        rows_processed := SQL%ROWCOUNT;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                rows_processed);
--  Truncate all the entries that start before the auto-reduce date but end
--  after the auto-reduce date
    var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                              arg_request_id,
                                              arg_user_id,
                                              'ENTITY',
                                              'mrp_schedule_dates',
                                              'N');

        UPDATE  mrp_schedule_dates dates
        SET     last_update_date = SYSDATE,
                last_updated_by = arg_user_id,
                dates.schedule_date =
                (SELECT cal2.calendar_date
                 FROM   bom_calendar_dates cal1,
                        bom_calendar_dates cal2,
                        mtl_parameters param,
                        mtl_system_items sys
                 WHERE  cal1.calendar_code = param.calendar_code
                 AND    cal1.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal1.calendar_date = TRUNC(SYSDATE)
                 AND    cal2.calendar_code = param.calendar_code
                 AND    cal2.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal2.seq_num = cal1.next_seq_num  +
                        (DECODE(sys.auto_reduce_mps,
                            MPS_AUTO_PAST_DUE,
                            0,
                            MPS_AUTO_DEMAND_TF,
                            DECODE(sys.demand_time_fence_code,
                                USER_TF,
                                  CEIL(NVL(
                                    sys.demand_time_fence_days, 0)),
                                CUM_TOTAL_LT,
                                  CEIL(NVL(
                                    sys.cumulative_total_lead_time, 0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,
                                        0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0))),
                            MPS_AUTO_PLANNING_TF,
                            DECODE(sys.planning_time_fence_code,
                                USER_TF,
                                    CEIL(NVL(
                                    sys.planning_time_fence_days,
                                        0)),
                                CUM_TOTAL_LT,
                                    CEIL(NVL(
                                        sys.cumulative_total_lead_time,
                                            0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,
                                        0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0)))))
                AND     dates.rate_end_date >= cal2.calendar_date
                AND     dates.schedule_date < cal2.calendar_date
                AND     param.organization_id = dates.organization_id
                AND     sys.organization_id = dates.organization_id
                AND     sys.auto_reduce_mps <> MPS_AUTO_NONE
                AND     sys.auto_reduce_mps is not null
                AND     sys.inventory_item_id = dates.inventory_item_id)
        WHERE   exists
                (SELECT NULL
                 FROM   bom_calendar_dates cal1,
                        bom_calendar_dates cal2,
                        mtl_parameters param,
                        mtl_system_items sys
                 WHERE  cal1.calendar_code = param.calendar_code
                 AND    cal1.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal1.calendar_date = TRUNC(SYSDATE)
                 AND    cal2.calendar_code = param.calendar_code
                 AND    cal2.exception_set_id =
                                param.calendar_exception_set_id
                 AND    cal2.seq_num = cal1.next_seq_num  +
                        (DECODE(sys.auto_reduce_mps,
                            MPS_AUTO_PAST_DUE,
                            0,
                            MPS_AUTO_DEMAND_TF,
                            DECODE(sys.demand_time_fence_code,
                                USER_TF,
                                  CEIL(NVL(
                                    sys.demand_time_fence_days, 0)),
                                CUM_TOTAL_LT,
                                  CEIL(NVL(
                                    sys.cumulative_total_lead_time, 0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,
                                        0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0))),
                            MPS_AUTO_PLANNING_TF,
                            DECODE(sys.planning_time_fence_code,
                                USER_TF,
                                    CEIL(NVL(
                                        sys.planning_time_fence_days,
                                            0)),
                                CUM_TOTAL_LT,
                                    CEIL(NVL(
                                        sys.cumulative_total_lead_time,
                                            0)),
                                CUM_MFG_LT,
                                  CEIL(NVL(
                                    sys.cum_manufacturing_lead_time,
                                        0)),
                                TOTAL_LT,
                                    CEIL(NVL(sys.full_lead_time, 0)))))
                AND     dates.rate_end_date >= cal2.calendar_date
                AND     dates.schedule_date < cal2.calendar_date
                AND     param.organization_id = dates.organization_id
                AND     sys.organization_id = dates.organization_id
                AND     sys.auto_reduce_mps <> MPS_AUTO_NONE
                AND     sys.auto_reduce_mps is not null
                AND     sys.inventory_item_id = dates.inventory_item_id)
        AND     dates.schedule_level = UPDATED_SCHEDULE
        AND     dates.supply_demand_type = MTL_SUPPLY_TYPE
        AND     dates.rate_end_date is NOT NULL
        AND     dates.organization_id = DECODE(arg_sched_mgr, SYS_YES,
                    dates.organization_id, arg_org_id)
        AND     dates.schedule_designator = DECODE(arg_sched_mgr,
                    SYS_YES, dates.schedule_designator,
                    arg_sched_desig);
        rows_processed := SQL%ROWCOUNT;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                rows_processed);
END mrp_auto_reduce_mps;

END MRP_AUTO_REDUCE_PK;

/
