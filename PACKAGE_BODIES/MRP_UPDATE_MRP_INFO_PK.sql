--------------------------------------------------------
--  DDL for Package Body MRP_UPDATE_MRP_INFO_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_UPDATE_MRP_INFO_PK" AS
/* $Header: MRPPUPDB.pls 120.1 2006/08/29 13:48:45 arrsubra noship $ */

PROCEDURE mrp_update_mrp_cols(
                            arg_org_id          IN      NUMBER,
                            arg_item_id         IN      NUMBER,
                            arg_user_id         IN      NUMBER,
                            arg_request_id      IN      NUMBER) IS
--  Constant declarations
    MPS_RELIEF_TYPE         CONSTANT INTEGER := 2;
    R_WORK_ORDER            CONSTANT INTEGER := 1;
    R_PURCH_ORDER           CONSTANT INTEGER := 2;
    R_PURCH_REQ             CONSTANT INTEGER := 5;
    R_PO_RECV               CONSTANT INTEGER := 6;
    R_SHIPMENT              CONSTANT INTEGER := 7;
    R_SHIPMENT_RCV          CONSTANT INTEGER := 8;
    R_FLOW_SCHEDULE         CONSTANT INTEGER := 9;
    NULL_VALUE              CONSTANT INTEGER := -23453;
    ALREADY_PROCESSED       CONSTANT INTEGER := 5;
    IN_PROCESS              CONSTANT INTEGER := 3;
    SCHEDULE_SUPPLY         CONSTANT INTEGER := 2;
    PLANNED_ORDER           CONSTANT INTEGER := 5;
    PSEUDO_SCHEDULE         CONSTANT INTEGER := -100;
    PSEUDO_PLANNED_ORDER    CONSTANT INTEGER := -100;
    UPDATED_SCHEDULE        CONSTANT INTEGER := 2;
    SYS_NO                  CONSTANT INTEGER := 2;
    var_watch_id            NUMBER;
    var_rowid               VARCHAR2(20);
    var_wip_entity_id       NUMBER;
    var_org_id              NUMBER;
    prev_wip_entity_id      NUMBER  := -1;
    prev_org_id             NUMBER := -1;
    var_row_count           NUMBER;
    busy EXCEPTION;
    deadlock EXCEPTION;

    PRAGMA EXCEPTION_INIT(busy, -54);
    PRAGMA EXCEPTION_INIT(deadlock, -60);

    CURSOR jobs_cursor IS
                    SELECT   jobs.rowid,
                             jobs.wip_entity_id,
                             jobs.organization_id
                    FROM     wip_requirement_operations ops,
                             wip_discrete_jobs jobs,
                             mrp_relief_interface mrp
                    WHERE    ops.wip_entity_id (+) = jobs.wip_entity_id
                    AND      ops.organization_id (+) = jobs.organization_id
                    AND      mrp.disposition_type  = R_WORK_ORDER
                    AND      mrp.relief_type       = MPS_RELIEF_TYPE
                    AND      mrp.request_id        = arg_request_id
                    AND      mrp.process_status    = IN_PROCESS
                    AND      mrp.error_message     is NULL
                    AND      mrp.inventory_item_id =
                             DECODE(arg_item_id,NULL_VALUE,
                                    mrp.inventory_item_id,
                                    arg_item_id)
                    AND      mrp.organization_id   =
                             DECODE(arg_org_id,NULL_VALUE,mrp.organization_id,
                                    arg_org_id)
                    AND      jobs.primary_item_id  = mrp.inventory_item_id
                    AND      jobs.organization_id  = mrp.organization_id
                    AND      jobs.wip_entity_id    = mrp.disposition_id
                    FOR UPDATE OF jobs.mps_net_quantity,
                                    ops.mps_required_quantity
                    ORDER BY jobs.organization_id, jobs.wip_entity_id;

    CURSOR flow_schedules_cursor IS
                    SELECT   fs.rowid,
                             fs.wip_entity_id,
                             fs.organization_id
                    FROM     wip_flow_schedules   fs,
                             mrp_relief_interface mrp
                    WHERE    mrp.disposition_type  = R_FLOW_SCHEDULE
                    AND      mrp.relief_type       = MPS_RELIEF_TYPE
                    AND      mrp.request_id        = arg_request_id
                    AND      mrp.process_status    = IN_PROCESS
                    AND      mrp.error_message     is NULL
                    AND      mrp.inventory_item_id =
                             DECODE(arg_item_id,NULL_VALUE,
                                    mrp.inventory_item_id,
                                    arg_item_id)
                    AND      mrp.organization_id   =
                             DECODE(arg_org_id,NULL_VALUE,mrp.organization_id,
                                    arg_org_id)
                    AND      fs.primary_item_id    = mrp.inventory_item_id
                    AND      fs.organization_id    = mrp.organization_id
                    AND      fs.wip_entity_id      = mrp.disposition_id
                    FOR UPDATE OF fs.mps_net_quantity,
                                  fs.mps_scheduled_completion_date
                    ORDER BY fs.organization_id, fs.wip_entity_id;

     CURSOR consol_cursor_ms IS
     SELECT ms.rowid
     FROM   mtl_supply ms
     where  ms.rowid in (
                    SELECT  /*+ INDEX(supply MTL_SUPPLY_N7) */
                            supply.rowid
                    FROM    mtl_supply supply,
                            mrp_relief_interface mrp
                    WHERE   mrp.disposition_type = R_PURCH_REQ
                    AND     mrp.relief_type = MPS_RELIEF_TYPE
                    AND     mrp.inventory_item_id =
                            DECODE(arg_item_id, NULL_VALUE, inventory_item_id,
                                   arg_item_id)
                    AND     mrp.organization_id =
                            DECODE(arg_org_id, NULL_VALUE, organization_id,
                                   arg_org_id)
                    AND     supply.item_id = mrp.inventory_item_id
                    AND     supply.supply_type_code = 'REQ'
                    AND     mrp.line_num =  supply.req_line_id
                    AND     supply.to_organization_id = mrp.organization_id
                    AND     mrp.disposition_id=  supply.req_header_id
                    AND     supply.destination_type_code = 'INVENTORY'
                    AND     mrp.error_message is NULL
                    AND     mrp.process_status = IN_PROCESS
                    AND     mrp.request_id = arg_request_id
                  UNION
                    SELECT  /*+ INDEX(supply MTL_SUPPLY_N5) */
                            supply.rowid
                    FROM    mtl_supply supply,
                            mrp_relief_interface mrp
                    WHERE   mrp.disposition_type = R_PURCH_ORDER
                    AND     mrp.relief_type = MPS_RELIEF_TYPE
                    AND     mrp.inventory_item_id =
                            DECODE(arg_item_id, NULL_VALUE, inventory_item_id,
                                   arg_item_id)
                    AND     mrp.organization_id =
                            DECODE(arg_org_id, NULL_VALUE, organization_id,
                                   arg_org_id)
                    AND     supply.item_id = mrp.inventory_item_id
                    AND     mrp.line_num = supply.po_line_id
                    AND     supply.to_organization_id = mrp.organization_id
                    AND     mrp.disposition_id=  supply.po_header_id
                    AND     supply.supply_type_code = 'PO'
                    AND     supply.destination_type_code = 'INVENTORY'
                    AND     mrp.error_message is NULL
                    AND     mrp.request_id = arg_request_id
                    AND     mrp.process_status = IN_PROCESS
                  UNION
                    SELECT  /*+ INDEX(supply MTL_SUPPLY_N9) */
                            supply.rowid
                    FROM    mtl_supply supply,
                            mrp_relief_interface mrp
                    WHERE   mrp.disposition_type = R_SHIPMENT
                    AND     mrp.relief_type = MPS_RELIEF_TYPE
                    AND     mrp.inventory_item_id =
                            DECODE(arg_item_id, NULL_VALUE, inventory_item_id,
                                   arg_item_id)
                    AND     mrp.organization_id =
                            DECODE(arg_org_id, NULL_VALUE, organization_id,
                                   arg_org_id)
                    AND     supply.item_id = mrp.inventory_item_id
                    AND     mrp.line_num = supply.shipment_line_id
                    AND     supply.to_organization_id = mrp.organization_id
                    AND     mrp.disposition_id= supply.shipment_header_id
                    AND     supply.supply_type_code = 'SHIPMENT'
                    AND     supply.destination_type_code = 'INVENTORY'
                    AND     mrp.error_message is NULL
                    AND     mrp.process_status = IN_PROCESS
                    AND     mrp.request_id = arg_request_id
                 UNION
                    SELECT  /*+ INDEX(supply MTL_SUPPLY_N5) */
                            supply.rowid
                    FROM    mtl_supply supply,
                            mrp_relief_interface mrp
                    WHERE   mrp.disposition_type = R_PO_RECV
                    AND     mrp.relief_type = MPS_RELIEF_TYPE
                    AND     mrp.inventory_item_id =
                            DECODE(arg_item_id, NULL_VALUE, inventory_item_id,
                                   arg_item_id)
                    AND     mrp.organization_id =
                            DECODE(arg_org_id, NULL_VALUE, organization_id,
                                   arg_org_id)
                    AND     supply.item_id = mrp.inventory_item_id
                    AND     mrp.line_num = supply.po_line_id
                    AND     supply.to_organization_id = mrp.organization_id
                    AND     mrp.disposition_id=   supply.po_header_id
                    AND     supply.supply_type_code = 'RECEIVING'
                    AND     supply.destination_type_code = 'INVENTORY'
                    AND     mrp.error_message is NULL
                    AND     mrp.process_status = IN_PROCESS
                    AND     mrp.request_id = arg_request_id
                  UNION
                    SELECT  /*+ INDEX(supply MTL_SUPPLY_N9) */
                            supply.rowid
                    FROM    mtl_supply supply,
                            mrp_relief_interface mrp
                    WHERE   mrp.disposition_type = R_SHIPMENT_RCV
                    AND     mrp.relief_type = MPS_RELIEF_TYPE
                    AND     mrp.inventory_item_id =
                            DECODE(arg_item_id, NULL_VALUE, inventory_item_id,
                                   arg_item_id)
                    AND     mrp.organization_id =
                            DECODE(arg_org_id, NULL_VALUE, organization_id,
                                   arg_org_id)
                    AND     mrp.error_message is NULL
                    AND     supply.item_id = mrp.inventory_item_id
                    AND     mrp.line_num =  supply.shipment_line_id
                    AND     supply.to_organization_id = mrp.organization_id
                    AND     mrp.disposition_id= supply.shipment_header_id
                    AND     supply.supply_type_code = 'RECEIVING'
                    AND     supply.destination_type_code = 'INVENTORY'
                    AND     mrp.process_status = IN_PROCESS
                    AND     mrp.request_id = arg_request_id)
    FOR UPDATE OF ms.mrp_expected_delivery_date ;

    CURSOR dates_cursor IS
                    SELECT  dates.rowid
                    FROM
                            mrp_schedule_dates dates
                    WHERE   dates.schedule_quantity >= 0
                    AND     dates.original_schedule_quantity >= 0
                    AND     dates.schedule_level = PSEUDO_SCHEDULE
                    AND     dates.schedule_origination_type = NULL_VALUE
                    AND     dates.supply_demand_type = SCHEDULE_SUPPLY
                    AND     (dates.organization_id,dates.schedule_designator) IN
                    (select
                             nvl(plans.planned_organization,
                                    desig.organization_id),
                             desig.schedule_designator
                     from
                            mrp_schedule_designators desig,
                            mrp_plan_organizations_v plans
                     WHERE
                        NVL(desig.disable_date, TRUNC(SYSDATE)+1)>TRUNC(SYSDATE)
                     AND  desig.mps_relief = 1
                     AND  desig.schedule_type = 2
                     AND  desig.schedule_designator =plans.compile_designator(+)
                     AND  desig.organization_id = plans.organization_id (+)
                     AND  nvl(plans.planned_organization,
                                    desig.organization_id) in
                       (select distinct mrp.organization_id
                        from mrp_relief_interface mrp
                        where
                               mrp.relief_type = MPS_RELIEF_TYPE
                        AND     mrp.error_message is NULL
                        AND     mrp.process_status = IN_PROCESS
                        AND     mrp.request_id = arg_request_id)
                    );

    CURSOR recommendations_cursor IS
                    SELECT  /* ORDERED
                                INDEX(recom MRP_RECOMMENDATIONS_N1)
                                INDEX(mrp MRP_RELIEF_INTERFACE_N1)
                                INDEX(plans MRP_PLANS_U1) */
                            recom.rowid
                    FROM    mrp_recommendations recom
                    WHERE   recom.new_order_quantity >= 0
                    AND     recom.firm_planned_type = SYS_NO
                    AND     recom.disposition_status_type = NULL_VALUE
                    AND     recom.order_type = PSEUDO_PLANNED_ORDER
                    AND    (recom.compile_designator,recom.organization_id)
                       IN
                    (select plans.compile_designator ,
                            plans.planned_organization
                     from
                            mrp_designators_view desig,
                            mrp_plan_organizations_v plans
                     where
                     NVL(desig.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
                     AND   desig.organization_id = plans.organization_id
                     AND   desig.designator = plans.compile_designator
                     AND   plans.planned_organization in
                             (select distinct mrp.organization_id
                              from mrp_relief_interface mrp
                              where
                                      mrp.relief_type = MPS_RELIEF_TYPE
                              AND     mrp.error_message is NULL
                              AND     mrp.process_status = IN_PROCESS
                              AND     mrp.request_id = arg_request_id)
                    );

BEGIN


    var_watch_id := mrp_print_pk.start_watch(
                    'GEN-deleted from table', arg_request_id, arg_user_id,
                    'TABLE', 'mrp_schedule_dates', 'N');
    var_row_count := 0;
    OPEN dates_cursor;
    LOOP

        FETCH dates_cursor INTO var_rowid;
        exit when dates_cursor%notfound;

        DELETE  FROM    mrp_schedule_dates dates
                WHERE   rowid = var_rowid;

        var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0);

    END LOOP;
    CLOSE dates_cursor;
    mrp_print_pk.stop_watch(arg_request_id, var_watch_id, var_row_count);


    var_watch_id := mrp_print_pk.start_watch(
                        'GEN-deleted from table', arg_request_id, arg_user_id,
                        'TABLE', 'mrp_recommendations', 'N');
    var_row_count := 0;
    OPEN recommendations_cursor;
    LOOP

        FETCH recommendations_cursor INTO var_rowid;
        exit when recommendations_cursor%notfound;

        DELETE  FROM    mrp_recommendations recom
                WHERE   rowid = var_rowid;

        var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0);

    END LOOP;
    CLOSE recommendations_cursor;
    mrp_print_pk.stop_watch(arg_request_id, var_watch_id, var_row_count);

--
--  If called for wip jobs set the completion_date and completion
--  quantities for all the jobs that we performed relief
--

    var_watch_id := mrp_print_pk.start_watch(
                    'GEN-updated', arg_request_id, arg_user_id, 'ENTITY',
                    'wip_discrete_jobs', 'N');
    var_row_count := 0;
    SAVEPOINT jobs;
    LOOP
        BEGIN
            OPEN jobs_cursor;
            EXIT;
        EXCEPTION
            WHEN deadlock THEN
		ROLLBACK TO SAVEPOINT jobs;
                dbms_lock.sleep(5);
        END;
    END LOOP;

    LOOP

        FETCH jobs_cursor INTO var_rowid, var_wip_entity_id, var_org_id;
        exit when jobs_cursor%notfound;

        if (prev_wip_entity_id <> var_wip_entity_id OR
            prev_org_id <> var_org_id)
        then
            UPDATE wip_discrete_jobs jobs
            SET    mps_scheduled_completion_date = scheduled_completion_date,
                   mps_net_quantity = net_quantity,
                   last_update_date = SYSDATE,
                   last_updated_by = arg_user_id
            WHERE  rowid = var_rowid;

            var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0) ;

            UPDATE wip_requirement_operations ops
                SET    ops.mps_required_quantity = ops.required_quantity,
                       ops.mps_date_required = ops.date_required,
                       ops.last_update_date = SYSDATE,
                       ops.last_updated_by = arg_user_id
                WHERE  wip_entity_id = var_wip_entity_id
                AND    organization_id = var_org_id;

            var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0) ;
        end if;
        prev_wip_entity_id := var_wip_entity_id;
        prev_org_id := var_org_id;

    END LOOP;
    CLOSE jobs_cursor;
    mrp_print_pk.stop_watch(arg_request_id, var_watch_id,var_row_count);

--
--  WIP Flow Schedules: set the completion_date and completion
--  quantities for all the flow schedules that we performed relief
--
    var_watch_id := mrp_print_pk.start_watch(
                    'GEN-updated', arg_request_id, arg_user_id, 'ENTITY',
                    'wip_flow_schedules', 'N');
    var_row_count      := 0;
    prev_wip_entity_id := -1;
    prev_org_id        := -1;
    SAVEPOINT flow;

    LOOP
        BEGIN
            OPEN flow_schedules_cursor;
            EXIT;
        EXCEPTION
            WHEN deadlock THEN
                ROLLBACK TO SAVEPOINT flow;
                dbms_lock.sleep(5);
        END;
    END LOOP;

    LOOP

        FETCH flow_schedules_cursor
        INTO  var_rowid, var_wip_entity_id, var_org_id;
        EXIT WHEN flow_schedules_cursor%notfound;

        IF (prev_wip_entity_id <> var_wip_entity_id OR
            prev_org_id <> var_org_id)
        THEN
            UPDATE wip_flow_schedules fs
            SET    mps_scheduled_completion_date = scheduled_completion_date,
                   mps_net_quantity = planned_quantity,
                   last_update_date = SYSDATE,
                   last_updated_by  = arg_user_id
            WHERE  rowid = var_rowid;

            var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0) ;
        END IF;

        prev_wip_entity_id := var_wip_entity_id;
        prev_org_id := var_org_id;

    END LOOP;
    CLOSE flow_schedules_cursor;
    mrp_print_pk.stop_watch(arg_request_id, var_watch_id, var_row_count);

    var_watch_id := mrp_print_pk.start_watch(
                    'GEN-updated', arg_request_id, arg_user_id,
                    'ENTITY', 'mtl_supply', 'N');

    var_row_count := 0;

--  Req Cursor
    SAVEPOINT mtl_sup;

    LOOP
        BEGIN
            OPEN consol_cursor_ms;
            EXIT;
        EXCEPTION
            WHEN deadlock THEN
                ROLLBACK TO SAVEPOINT mtl_sup;
                dbms_lock.sleep(5);
        END;
    END LOOP;

    LOOP

        FETCH consol_cursor_ms INTO var_rowid;
        exit when consol_cursor_ms%notfound;

        UPDATE mtl_supply supply
        SET    mrp_expected_delivery_date = expected_delivery_date ,
               mrp_primary_quantity       = to_org_primary_quantity,
               mrp_to_organization_id     = to_organization_id,
               mrp_destination_type_code  = destination_type_code,
               mrp_to_subinventory        = to_subinventory,
               last_update_date           = SYSDATE,
               last_updated_by            = arg_user_id,
               mrp_primary_uom            =
                 (SELECT     uom_code
                  FROM       mtl_units_of_measure
                  WHERE      unit_of_measure = supply.to_org_primary_uom)
        WHERE  rowid = var_rowid;

        var_row_count := var_row_count + NVL(SQL%ROWCOUNT, 0);

    END LOOP;
    CLOSE consol_cursor_ms;

    mrp_print_pk.stop_watch(arg_request_id, var_watch_id,var_row_count);

END mrp_update_mrp_cols;

END MRP_UPDATE_MRP_INFO_PK;

/
