--------------------------------------------------------
--  DDL for Package Body CRP_PLANNER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CRP_PLANNER_PK" AS
/* $Header: CRPPPLNB.pls 115.1 99/07/16 10:31:09 porting ship $ */

-- ********************** start_plan *************************
PROCEDURE   start_plan(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_user_id         IN  NUMBER) IS
BEGIN
    UPDATE  mrp_plans
    SET     crp_plan_start_date = SYSDATE,
            last_update_date = SYSDATE,
            last_updated_by = arg_user_id
    WHERE   organization_id = arg_org_id
      AND   compile_designator = arg_compile_desig;

    COMMIT;
END start_plan;

-- ********************** complete_plan *************************
PROCEDURE   complete_plan(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_user_id         IN  NUMBER) IS
BEGIN
    UPDATE  mrp_plans
    SET     crp_plan_completion_date = SYSDATE,
            last_update_date = SYSDATE,
            last_updated_by = arg_user_id
    WHERE   organization_id = arg_org_id
      AND     compile_designator = arg_compile_desig;

    COMMIT;
END complete_plan;
-- ********************** plan_jobs *************************
PROCEDURE   plan_jobs(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_user_id         IN  NUMBER,
                            arg_cutoff_date     IN  DATE,
                            arg_request_id      IN  NUMBER,
                            arg_calendar_code   IN  VARCHAR2,
                            arg_exception_set_id IN NUMBER) IS
                            var_watch_id        NUMBER;
                            var_row_count       NUMBER;
                            var_spread_load     NUMBER;
BEGIN

    var_watch_id := mrp_print_pk.start_watch('CAP-load discrete jobs',
        arg_request_id,
        arg_user_id);

     var_spread_load := TO_NUMBER(FND_PROFILE.VALUE('CRP_SPREAD_LOAD'));


    /*-------------------------------------------------------------------+
     |  Load the resource plan for discrete jobs into crp_resource_hours |
     +------------------------------------------------------------------*/

    --- To correctly calculate the resource end date, we find the difference
    --- between the actual # of days the requiremente should be spread
    --- and the current amount of days we spread now. We correct the
    ---
    INSERT  INTO crp_resource_plan
                (transaction_id,
                 department_id,
                 resource_id,
                 organization_id,
                 designator,
                 source_transaction_id,
                 assembly_item_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 resource_date,
                 resource_hours,
                 repetitive_type,
                 operation_seq_num,
                 resource_seq_num,
                 resource_end_date,
                 daily_resource_hours)
        SELECT   crp_resource_plan_s.nextval,
                 resources.department_id,
                 resources.resource_id,
                 resources.organization_id,
                 arg_compile_desig,
                 recom.transaction_id,
                 recom.inventory_item_id,
                 SYSDATE,
                 arg_user_id,
                 SYSDATE,
                 arg_user_id,
                 -1,
                 res_date.calendar_date,
                 DECODE(SIGN(resources.operation_hours_required
                     -  resources.hours_expended), -1, 0,
                     (resources.operation_hours_required -
                        resources.hours_expended)),
                 NOT_REPETITIVE_PLANNED,
                 resources.operation_seq_num,
                 resources.resource_seq_num,
                 DECODE(var_spread_load,
                        1, greatest(res_end.calendar_date, res_date.calendar_date),
                            NULL),
                 DECODE(SIGN(resources.operation_hours_required
                     -  resources.hours_expended), -1, 0,
                     (resources.operation_hours_required -
                        resources.hours_expended))/
                     (greatest(res_end.seq_num, res_date.seq_num)  -
                        res_date.seq_num + 1)
        FROM    bom_calendar_dates res_end,
                bom_calendar_dates old_end_date,
                bom_calendar_dates  res_date,
                bom_calendar_dates  old_start_date,
                mrp_wip_resources   resources,
                MRP_recommendations recom
      WHERE     res_end.exception_set_id = arg_exception_set_id
        AND     res_end.calendar_code = arg_calendar_code
        AND     res_end.seq_num =
                    old_end_date.prior_seq_num + NVL(recom.reschedule_days, 0) -
                       DECODE(resources.resource_end_date, NULL, 0,
                        ((TRUNC(resources.resource_end_date)-
                          TRUNC(resources.first_unit_start_date)+1) -
                          ceil(resources.resource_end_date-resources.first_unit_start_date)))
        AND     old_end_date.exception_set_id = arg_exception_set_id
        AND     old_end_date.calendar_code = arg_calendar_code
        AND     old_end_date.calendar_date =
                   NVL(TRUNC(resources.resource_end_date),
                       TRUNC(resources.first_unit_start_date))
        AND     res_date.seq_num =
                   old_start_date.prior_seq_num + NVL(recom.reschedule_days, 0)
        AND     res_date.calendar_date <= arg_cutoff_date
        AND     res_date.exception_set_id = arg_exception_set_id
        AND     res_date.calendar_code = arg_calendar_code
        AND     old_start_date.calendar_date =
                    TRUNC(resources.first_unit_start_date)
        AND     old_start_date.exception_set_id = arg_exception_set_id
        AND     old_start_date.calendar_code = arg_calendar_code
        AND     resources.organization_id = recom.organization_id
        AND     resources.compile_designator = recom.compile_designator
        AND     resources.wip_entity_id = recom.disposition_id
        AND     recom.disposition_status_type <> CANCEL_ORDER
        AND     recom.order_type IN (WORK_ORDER, NONSTD_JOB)
        AND     recom.organization_id  IN
                (select planned_organization
                 from   mrp_plan_organizations_v
                 where  organization_id = arg_org_id
                 and    compile_designator = arg_compile_desig)
        AND     resources.operation_hours_required > resources.hours_expended
        AND     recom.compile_designator = arg_compile_desig;


    var_row_count := SQL%ROWCOUNT;
    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            var_row_count);
    COMMIT;
END plan_jobs;

-- ********************** plan_discrete *************************
PROCEDURE   plan_discrete(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_user_id         IN  NUMBER,
                            arg_cutoff_date     IN  DATE,
                            arg_request_id      IN  NUMBER,
                            arg_calendar_code   IN  VARCHAR2,
                            arg_exception_set_id IN NUMBER) IS
                            var_watch_id        NUMBER;
                            var_row_count       NUMBER;
                            var_spread_load     NUMBER;
BEGIN
    var_watch_id := mrp_print_pk.start_watch('CAP-load planned orders',
            arg_request_id,
            arg_user_id);

    var_spread_load := TO_NUMBER(FND_PROFILE.VALUE('CRP_SPREAD_LOAD'));

    INSERT  INTO crp_resource_plan
                    (transaction_id,
                     department_id,
                     resource_id,
                     organization_id,
                     designator,
                     source_transaction_id,
                     assembly_item_id,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     resource_date,
                     resource_hours,
                     repetitive_type,
                     operation_seq_num,
                     resource_seq_num,
                     resource_end_date,
                     daily_resource_hours)
        SELECT      crp_resource_plan_s.nextval,
                    labor.department_id,
                    labor.resource_id,
                    labor.organization_id,
                    arg_compile_desig,
                    recom.transaction_id,
                    recom.inventory_item_id,
                    SYSDATE,
                    arg_user_id,
                    SYSDATE,
                    arg_user_id,
                    -1,
                    res_date.calendar_date,
                    decode(labor.basis, BASIS_PER_ITEM,
                        (labor.runtime_quantity * recom.new_order_quantity),
                        labor.runtime_quantity),
                    NOT_REPETITIVE_PLANNED,
                    labor.operation_seq_num,
                    labor.resource_seq_num,
                    NULL,
                    NULL
          FROM    bom_calendar_dates res_date,
                  bom_calendar_dates sched_date,
                  mrp_system_items items,
                  mrp_planned_resource_reqs labor,
                  mrp_recommendations        recom,
                  mrp_plans mp
          WHERE   res_date.seq_num =
                    TRUNC(sched_date.seq_num
                   - CEIL((items.variable_lead_time * new_order_quantity +
                            items.fixed_lead_time)  *
                        (1 - NVL(labor.resource_offset_percent, 0))))
            AND   res_date.calendar_date <= arg_cutoff_date
            AND   res_date.exception_set_id = arg_exception_set_id
            AND   res_date.calendar_code = arg_calendar_code
            AND   sched_date.calendar_date =
                    recom.new_schedule_date
            AND   sched_date.exception_set_id = arg_exception_set_id
            AND   sched_date.calendar_code = arg_calendar_code
            AND   items.planning_make_buy_code = decode(
                                     NVL(mp.use_new_planner,SYS_NO),
                                     SYS_NO, MAKE, items.planning_make_buy_code)
            AND   items.organization_id = recom.organization_id
            AND   items.compile_designator = recom.compile_designator
            AND   items.inventory_item_id = recom.inventory_item_id
            AND   labor.organization_id = recom.organization_id
            AND   labor.compile_designator = recom.compile_designator
            AND   labor.using_assembly_item_id = recom.inventory_item_id
            AND   recom.organization_id = decode(mp.use_new_planner,
                                     SYS_YES, nvl(recom.source_organization_id,
                                    recom.organization_id),
                                recom.organization_id)
            AND   recom.disposition_status_type <> CANCEL_ORDER
            AND   recom.order_type = PLANNED_ORDER
            AND   recom.organization_id IN
                                        (Select planned_organization
                                         from mrp_plan_organizations_v
                                         where organization_id =  arg_org_id
                                         and compile_designator =
                                            arg_compile_desig)
            AND   recom.compile_designator = mp.compile_designator
            AND   mp.organization_id = arg_org_id
            AND   mp.compile_designator = arg_compile_desig;

    var_row_count := SQL%ROWCOUNT;
    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            var_row_count);

    if var_spread_load = 1 then

        --  Update the resource end date of a resource requirement to
        --  the start date of the next resource requirement within the
        --  same operation.

        var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                arg_request_id,
                arg_user_id,
                'ENTITY',
                'crp_resource_plan(1)',
                'N');

        update  crp_resource_plan plan1
        set     resource_end_date =
                (SELECT resource_date
                 FROM   crp_resource_plan plan2
                 WHERE   (plan2.resource_seq_num =
                         (select min(resource_seq_num)
                          from   crp_resource_plan plan3
                          where  plan3.source_transaction_id =
                                    plan2.source_transaction_id
                          and    plan3.operation_seq_num =
                                    plan2.operation_seq_num
                          and    plan3.resource_seq_num >
                                    plan1.resource_seq_num)
                 AND    plan2.source_transaction_id =
                            plan1.source_transaction_id
                 AND    plan2.operation_seq_num = plan1.operation_seq_num))
        where   source_transaction_id in
                (select transaction_id
                 from   mrp_recommendations
                 where  compile_designator = arg_compile_desig
                 and    organization_id in
                        (select planned_organization
                         from   mrp_plan_organizations_v
                         where  compile_designator = arg_compile_desig
                         and    organization_id = arg_org_id)
                 and    order_type = PLANNED_ORDER);

        var_row_count := SQL%ROWCOUNT;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                var_row_count);

        --  Update the resource end date of last resource requirement in
        --  an operation to the start date of the next operation

        var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                arg_request_id,
                arg_user_id,
                'ENTITY',
                'crp_resource_plan(2)',
                'N');

        update  crp_resource_plan plan1
        set     resource_end_date =
                (SELECT resource_date
                 FROM   crp_resource_plan plan2
                 WHERE  (plan2.resource_seq_num, plan2.operation_seq_num) =
                        (SELECT min(resource_seq_num), min(operation_seq_num)
                         FROM   crp_resource_plan plan3
                         where  plan3.source_transaction_id =
                                    plan2.source_transaction_id
                         and    plan3.operation_seq_num >
                                    plan1.operation_seq_num)
                 AND    plan2.source_transaction_id =
                            plan1.source_transaction_id)
        where   source_transaction_id in
                (select transaction_id
                 from   mrp_recommendations
                 where  compile_designator = arg_compile_desig
                 and    organization_id in
                        (select planned_organization
                         from   mrp_plan_organizations_v
                         where  compile_designator = arg_compile_desig
                         and    organization_id = arg_org_id)
                 and    order_type = PLANNED_ORDER)
        and      resource_end_date is null;

        var_row_count := SQL%ROWCOUNT;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                var_row_count);

        --  Update the resource end date of the last resource requirement
        --  for a planned order to the planned order due date
        var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                arg_request_id,
                arg_user_id,
                'ENTITY',
                'crp_resource_plan(3)',
                'N');

        update  crp_resource_plan plan1
        set     resource_end_date =
                (select     new_schedule_date
                 from       mrp_recommendations
                 where      transaction_id = plan1.source_transaction_id)
        where   source_transaction_id in
                (select transaction_id
                 from   mrp_recommendations
                 where  compile_designator = arg_compile_desig
                 and    organization_id in
                        (select planned_organization
                         from   mrp_plan_organizations_v
                         where  compile_designator = arg_compile_desig
                         and    organization_id = arg_org_id)
                 and    order_type = PLANNED_ORDER)
        and      resource_end_date is null;

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                var_row_count);

    end if;

    COMMIT;
END plan_discrete;
-- ********************** plan_repetitive *************************
PROCEDURE   plan_repetitive(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_user_id         IN  NUMBER,
                            arg_cutoff_date     IN  DATE,
                            arg_request_id      IN  NUMBER,
                            arg_calendar_code   IN  VARCHAR2,
                            arg_exception_set_id IN NUMBER) IS
                            var_watch_id        NUMBER;
                            var_row_count       NUMBER;

BEGIN

    var_watch_id := mrp_print_pk.start_watch('CAP-load repetitive jobs',
            arg_request_id,
            arg_user_id);

    INSERT  INTO crp_resource_plan
                (transaction_id,
                 department_id,
                 resource_id,
                 organization_id,
                 designator,
                 source_transaction_id,
                 assembly_item_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 resource_date,
                 resource_hours,
                 repetitive_type,
                 operation_seq_num,
                 resource_seq_num,
                 resource_end_date,
                 daily_resource_hours)
     SELECT     crp_resource_plan_s.nextval,
                labor.department_id,
                labor.resource_id,
                labor.organization_id,
                arg_compile_desig,
                recom.transaction_id,
                recom.inventory_item_id,
                sysdate,
                arg_user_id,
                sysdate,
                arg_user_id,
                -1,
                first_res_date.calendar_date,
                decode(labor.basis, BASIS_PER_ITEM,
                            (labor.runtime_quantity * NVL(recom.daily_rate,0) *
                                (last_res_date.seq_num -
                                first_res_date.seq_num + 1)),
                       labor.runtime_quantity),
                REPETITIVELY_PLANNED,
                labor.operation_seq_num,
                labor.resource_seq_num,
                last_res_date.calendar_date,
                decode(labor.basis, BASIS_PER_ITEM,
                        labor.runtime_quantity * NVL(recom.daily_rate,0),
                        labor.runtime_quantity /
                            (last_res_date.seq_num -
                            first_res_date.seq_num + 1))
          FROM  bom_calendar_dates last_res_date,
                bom_calendar_dates first_res_date,
                bom_calendar_dates last_due,
                bom_calendar_dates first_due,
                mrp_system_items items,
                mrp_planned_resource_reqs labor,
                mrp_recommendations recom,
        mrp_plans mp
          WHERE last_res_date.seq_num =
                      TRUNC(last_due.seq_num
                            - CEIL((items.variable_lead_time *
                                NVL(recom.daily_rate,0) +
                                    items.fixed_lead_time) *
                                (1-NVL(labor.resource_offset_percent,0))))
            AND last_res_date.calendar_date < arg_cutoff_date
            AND last_res_date.exception_set_id = arg_exception_set_id
            AND last_res_date.calendar_code = arg_calendar_code
            AND first_res_date.seq_num =
                      TRUNC(first_due.seq_num
                            - CEIL((items.variable_lead_time *
                                    NVL(recom.daily_rate,0) +
                                        items.fixed_lead_time) *
                                    (1-NVL(labor.resource_offset_percent,0))))
            AND first_res_date.exception_set_id = arg_exception_set_id
            AND first_res_date.calendar_code = arg_calendar_code
            AND last_due.calendar_date =
                    recom.last_unit_completion_date
            AND last_due.exception_set_id = arg_exception_set_id
            AND last_due.calendar_code = arg_calendar_code
            AND first_due.calendar_date = recom.new_schedule_date
            AND first_due.exception_set_id = arg_exception_set_id
            AND first_due.calendar_code = arg_calendar_code
            AND items.organization_id = recom.organization_id
            AND items.compile_designator = recom.compile_designator
            AND items.inventory_item_id = recom.inventory_item_id
            AND items.planning_make_buy_code = decode(
                                     NVL(mp.use_new_planner,SYS_NO),
                                     SYS_NO, MAKE, items.planning_make_buy_code)
            AND labor.organization_id = recom.organization_id
            AND labor.compile_designator = recom.compile_designator
            AND labor.using_assembly_item_id = recom.inventory_item_id
            AND recom.organization_id = decode(mp.use_new_planner,
                                               1, nvl(recom.source_organization_id,
                                                      recom.organization_id),
                                               recom.organization_id)
            AND recom.disposition_status_type <> CANCEL_ORDER
            AND recom.order_type = REPETITVE_SCHEDULE
            AND recom.organization_id IN
                (select planned_organization
                 from   mrp_plan_organizations_v
                 where  organization_id = arg_org_id
                 and    compile_designator = arg_compile_desig)
            AND recom.compile_designator = mp.compile_designator
            AND mp.organization_id = arg_org_id
            AND mp.compile_designator = arg_compile_desig;

    var_row_count := SQL%ROWCOUNT;
    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            var_row_count);
    COMMIT;
END plan_repetitive;

END; -- crp_planner_pk

/
