--------------------------------------------------------
--  DDL for Package Body WSM_JOBCOSTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_JOBCOSTING_GRP" as
/* $Header: WSMGCSTB.pls 115.2 2003/08/13 20:48:39 vjambhek ship $ */

/*-------------------------------------------------------------+
| Name : Insert_MaterialTxn
---------------------------------------------------------------*/
--This procedure is called to insert record in MMT
--only for Bonus/Split/Merge/Update Quantity transactions

PROCEDURE Insert_MaterialTxn(p_txn_id   IN NUMBER,
                          x_err_code OUT NOCOPY NUMBER,
                          x_err_buf  OUT NOCOPY VARCHAR2
                         )
IS
    l_stmt_num          NUMBER;

    l_wms_org           VARCHAR2(5);
    l_def_cost_grp_id   NUMBER := 0;
    l_acct_period_id    NUMBER := 0;
    l_org_id            NUMBER;
    l_txn_date          DATE;

    e_proc_error  EXCEPTION;

BEGIN
    x_err_code := 0;

    l_stmt_num := 5;

    SELECT  organization_id,
            transaction_date
    INTO    l_org_id,
            l_txn_date
    FROM    wsm_split_merge_transactions
    WHERE   transaction_id = p_txn_id;

    l_stmt_num := 10;

    SELECT wms_enabled_flag,
           default_cost_group_id
    INTO   l_wms_org,
           l_def_cost_grp_id
    FROM   mtl_parameters
    WHERE  organization_id = l_org_id;

    l_stmt_num := 20;

    l_acct_period_id := -1;
    BEGIN
        SELECT acct_period_id
        INTO   l_acct_period_id
        FROM   org_acct_periods
        WHERE  organization_id = l_org_id
        AND    trunc(nvl(l_txn_date, sysdate))
                        between PERIOD_START_DATE and SCHEDULE_CLOSE_DATE
        AND    period_close_date is NULL
        AND    OPEN_FLAG = 'Y';

    EXCEPTION
        WHEN NO_DATA_FOUND then
            x_err_code := -1;
            fnd_message.set_name('WSM', 'WSM_ACCT_PERIOD_NOT_OPEN');
            x_err_buf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, 'WSM_JobCosting_GRP.Insert_MaterialTxn('||l_stmt_num||'): '||x_err_buf);

        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_buf := 'Insert_MaterialTxn('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
            fnd_file.put_line(fnd_file.log, x_err_buf);
    END;

    IF (nvl(l_acct_period_id , -1) = -1) THEN
        x_err_code := -1;
        fnd_message.set_name('WSM', 'WSM_ACCT_PERIOD_NOT_OPEN');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCosting_GRP.Insert_MaterialTxn('||l_stmt_num||'): '||x_err_buf);
    END IF;

    IF (x_err_code <> 0) THEN
        GOTO L_ERROR;   --x_err_code has errcode, x_err_buf has the error message
    END IF;

    l_stmt_num := 30;

    INSERT INTO mtl_material_transactions
            (TRANSACTION_ID,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
             CREATION_DATE, CREATED_BY, REQUEST_ID,
             PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
             INVENTORY_ITEM_ID, ORGANIZATION_ID, TRANSACTION_TYPE_ID,
             TRANSACTION_ACTION_ID,
             TRANSACTION_SOURCE_TYPE_ID,
             TRANSACTION_SOURCE_ID,
             TRANSACTION_SOURCE_NAME,
             TRANSACTION_QUANTITY,
             PRIMARY_QUANTITY,
             TRANSACTION_UOM,
             TRANSACTION_DATE, SOURCE_LINE_ID,
             OPERATION_SEQ_NUM,
             ACCT_PERIOD_ID, COSTED_FLAG,
             COST_GROUP_ID
            )
    SELECT  mtl_material_transactions_s.nextval,
            sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
            sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_REQUEST_ID,
            FND_GLOBAL.PROG_APPL_ID, FND_GLOBAL.CONC_PROGRAM_ID, sysdate,
            WSRJ.primary_item_id, WSMT.organization_id, MTT.transaction_type_id,
            decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, 40,
                                             WSMPCNST.MERGE, 41,
                                             WSMPCNST.BONUS, 42,
                                             WSMPCNST.UPDATE_QUANTITY, 43, 0),
            MTT.transaction_source_type_id,
            decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, WSSJ.wip_entity_id, WSRJ.wip_entity_id),
            decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, WSSJ.wip_entity_name, WSRJ.wip_entity_name),
            decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, WSSJ.available_quantity, WSRJ.start_quantity),
            decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, WSSJ.available_quantity, WSRJ.start_quantity),
            MSI.primary_uom_code,
            WSMT.transaction_date, WSMT.transaction_id,
            decode(WSMT.transaction_type_id, WSMPCNST.BONUS, WSRJ.starting_operation_seq_num, WSSJ.operation_seq_num),
            OAP.acct_period_id, 'N',
            decode(l_wms_org, 'Y', l_def_cost_grp_id, NULL)
    FROM    wsm_sm_starting_jobs           WSSJ,
            wsm_split_merge_transactions   WSMT,
            wsm_sm_resulting_jobs          WSRJ,
            mtl_system_items               MSI,
            org_acct_periods               OAP,
            mtl_transaction_types          MTT
    WHERE   WSMT.transaction_id = p_txn_id
    AND     WSMT.transaction_id = decode(WSMT.transaction_type_id, WSMPCNST.BONUS, WSMT.transaction_id,
                                         WSSJ.transaction_id)
    AND     WSMT.transaction_id = WSRJ.transaction_id
    AND     WSRJ.primary_item_id = MSI.inventory_item_id
    AND     WSRJ.organization_id = MSI.organization_id
    AND     WSMT.organization_id = OAP.organization_id
    AND     trunc(WSMT.transaction_date) between period_start_date and schedule_close_date
    AND     MTT.transaction_action_id IN(decode(WSMT.transaction_type_id, WSMPCNST.SPLIT, 40,
                                                                          WSMPCNST.MERGE, 41,
                                                                          WSMPCNST.BONUS, 42,
                                                                          WSMPCNST.UPDATE_QUANTITY, 43, 0))
    AND     MTT.transaction_source_type_id = 5
    AND     rownum = 1;     --This picks up only 1 row for Split/Merge

    fnd_file.put_line(fnd_file.log, 'Records inserted into MMT ='||SQL%ROWCOUNT);

    IF (SQL%ROWCOUNT <> 1) THEN
        x_err_code := -1;
        fnd_message.set_name('WSM', 'WSM_INS_TBL_FAILED');
        fnd_message.set_token('ELEMENT', 'mtl_material_transactions');
        x_err_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCosting_GRP.Insert_MaterialTxn('||l_stmt_num||'): '||x_err_buf);
        GOTO L_ERROR;
    ELSE
        GOTO L_SUCCESS;
    END IF;

<<L_ERROR>>     --x_err_code has errcode, x_err_buf has the error message
    fnd_file.put_line(fnd_file.log, 'WSM_JobCosting_GRP.Insert_MaterialTxn: Rollback due to l_stmt_num = '||l_stmt_num);
    raise e_proc_error;

<<L_SUCCESS>>
    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;
    fnd_file.put_line(fnd_file.log, 'WSM_JobCosting_GRP.Insert_MaterialTxn: Returned success');

EXCEPTION
    WHEN e_proc_error THEN
        x_err_buf := ' WSM_JobCosting_GRP.Insert_MaterialTxn('||l_stmt_num||'): '||x_err_buf;
        fnd_file.put_line(fnd_file.log,x_err_buf);

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCosting_GRP.Insert_MaterialTxn('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Insert_MaterialTxn;


/*-------------------------------------------------------------+
| Name : Update_QtyIssued
---------------------------------------------------------------*/
--This procedure is called only for Bonus/Split/Merge/Update Quantity transactions


PROCEDURE Update_QtyIssued(p_txn_id    IN  NUMBER,
                            p_txn_type  IN  NUMBER,
                            x_err_code  OUT NOCOPY NUMBER,
                            x_err_buf   OUT NOCOPY VARCHAR2
                           )
IS
    l_stmt_num   NUMBER;
    l_op_seq_num NUMBER;
    l_rep_we_id  NUMBER;
    l_avail_qty  NUMBER;
    l_result_qty NUMBER;

BEGIN

    l_stmt_num := 3;

IF (p_txn_type = WSMPCNST.BONUS) THEN

    l_stmt_num := 5;

    SELECT wip_entity_id,
           starting_operation_seq_num
    INTO   l_rep_we_id,
           l_op_seq_num
    FROM   WSM_SM_RESULTING_JOBS
    WHERE  transaction_id = p_txn_id;

    l_stmt_num := 7;

    -- Update quantity_issued for all operations prior to starting_operation_seq_num
    UPDATE wip_requirement_operations
    SET    quantity_issued = required_quantity
    WHERE  wip_entity_id = l_rep_we_id
    AND    operation_seq_num < l_op_seq_num
    AND    wip_supply_type not in (2, 4, 5, 6);

ELSE -- for Split/Merge/Update Quantity
    l_stmt_num := 10;
    SELECT wip_entity_id,
           operation_seq_num,
           available_quantity
    INTO   l_rep_we_id,
           l_op_seq_num,
           l_avail_qty
    FROM   WSM_SM_STARTING_JOBS
    WHERE  transaction_id = p_txn_id
    AND    representative_flag = 'Y';

  IF p_txn_type IN (WSMPCNST.SPLIT, WSMPCNST.MERGE) THEN --This has been added to improve performance
                                 -- as such the following stmts wont update anything for Upd Qty
    l_stmt_num := 20;
    -- Update the non-representative starting jobs
    UPDATE wip_requirement_operations wro
    SET    wro.quantity_issued = round(NVL(wro.quantity_relieved, 0), 6)
    WHERE  wro.wip_entity_id in (select wip_entity_id
                                 from   wsm_sm_starting_jobs
                                 where  transaction_id = p_txn_id
                                 and    wip_entity_id <> l_rep_we_id)
    AND    nvl(wro.quantity_issued, 0) >= nvl(wro.quantity_relieved, 0)
                        -- If there is a PUSH comp and the whole qty is scrapped, qty_rel > qty_iss
    AND    not exists (select 'obsolete operation'
                       from   wip_operations wo
                       where  wo.wip_entity_id     = wro.wip_entity_id
                       and    wo.organization_id   = wro.organization_id
                       and    wo.operation_seq_num = wro.operation_seq_num
                       and    wo.count_point_type  = 3);

    l_stmt_num := 30;
    -- Update the non-matching resulting jobs i.e. new jobs
    UPDATE wip_requirement_operations wro
    SET    wro.quantity_issued =
              (SELECT round(decode(sign(nvl(wro1.quantity_issued, 0) - nvl(wro1.quantity_relieved, 0)), 1, 1, 0)
                                 *(nvl(wro1.quantity_issued,0) - nvl(wro1.quantity_relieved, 0))
                                 * WSRJ.start_quantity/l_avail_qty, 6)
               FROM   wip_requirement_operations wro1,
                      wsm_sm_resulting_jobs WSRJ
               WHERE  wro1.wip_entity_id     = l_rep_we_id
               AND    wro1.inventory_item_id = wro.inventory_item_id
               AND    wro1.organization_id   = wro.organization_id
               AND    wro1.operation_seq_num = wro.operation_seq_num
               AND    WSRJ.wip_entity_id = wro.wip_entity_id
	       AND    WSRJ.transaction_id = p_txn_id) -- Fix for bug #3086120
    WHERE  wro.wip_entity_id in (select wip_entity_id
                                 from   wsm_sm_resulting_jobs
                                 where  transaction_id = p_txn_id
                                 and    wip_entity_id <> l_rep_we_id)
    AND    not exists (select 'obsolete operation'
                       from   wip_operations wo
                       where  wo.wip_entity_id     = wro.wip_entity_id
                       and    wo.organization_id   = wro.organization_id
                       and    wo.operation_seq_num = wro.operation_seq_num
                       and    wo.count_point_type  = 3);
  END IF;

    l_stmt_num := 40;
    -- Update the representative job, may or may not be present in resulting
    BEGIN
        SELECT WSRJ.start_quantity
        INTO   l_result_qty
        FROM   wsm_sm_resulting_jobs WSRJ
        WHERE  WSRJ.transaction_id = p_txn_id
        AND    WSRJ.wip_entity_id in (select wip_entity_id
                                      from   wsm_sm_starting_jobs
                                      where  transaction_id = p_txn_id
                                      and    wip_entity_id = l_rep_we_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_result_qty := 0;
    END;

    UPDATE wip_requirement_operations wro
    SET    wro.quantity_issued =
                round((decode(sign(nvl(wro.quantity_issued, 0) - nvl(wro.quantity_relieved, 0)), 1, 1, 0)
                     *(nvl(wro.quantity_issued,0) - nvl(wro.quantity_relieved, 0)) * l_result_qty/l_avail_qty
                     + nvl(wro.quantity_relieved, 0)), 6)
    WHERE  wro.wip_entity_id in (select wip_entity_id
                                 from   wsm_sm_starting_jobs
                                 where  transaction_id = p_txn_id
                                 and    wip_entity_id = l_rep_we_id)
    AND    wro.quantity_issued > NVL(wro.quantity_relieved, 0) -- Added to fix bug #2797647
    AND    not exists (select 'obsolete operation'
                       from   wip_operations wo
                       where  wo.wip_entity_id     = wro.wip_entity_id
                       and    wo.organization_id   = wro.organization_id
                       and    wo.operation_seq_num = wro.operation_seq_num
                       and    wo.count_point_type  = 3);

END IF; --ELSE -- for Split/Merge/Update Quantity

    l_stmt_num := 50;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCosting_GRP.Update_QtyIssued('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Update_QtyIssued;



END WSM_JobCosting_GRP;

/
