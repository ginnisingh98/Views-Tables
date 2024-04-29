--------------------------------------------------------
--  DDL for Package Body WSMPOPRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPOPRN" AS
/* $Header: WSMOPRNB.pls 120.25.12010000.2 2008/09/24 15:39:09 tbhande ship $ */

/*============================================================================+
|  Copyright (c) 1996 Oracle Corporation, Redwood Shores, California, USA     |
|                           All rights reserved.                              |
|                                                                             |
|     DESCRIPTION                                                             |
|   This package body is used to add WIP Operations to the WIP routing        |
|   from the custom move transactions form                                    |
|                                                                             |
|     HISTORY                                                                 |
|       06/23/97        DJOFFE          Created                               |
|       04/29/00        REDWIN          Modified and added procs For WSM      |
|       06/12/00        REDWIN          First Check In                        |
|       09/29/00        GRATNAM         Modified update_job_name()for         |
|                                       assy returns                          |
|       01/15/01        SBHASKAR        Bugfix 1523334:Incase of Jump, insert |
|                                       into wip_operation_resources          |
|                                       using bom_std_op_resources            |
+============================================================================*/

g_update_flag boolean:=TRUE;
--mes
g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error     NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success   NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error         VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
--mes end
--NSO Modification by abedajna begin
-- Changed the signature of the procedure so that l_op_seq_id is passed along with l_std_operatio_id.
-- commenting out the procedure call and replacing by the mofied call.
/*
**PROCEDURE add_operation(
**        p_transaction_type_id           IN      NUMBER,
**        P_Commit                        IN      NUMBER,
**        X_Wip_Entity_Id                 IN      NUMBER,
**        X_Organization_Id               IN      NUMBER,
**        X_From_Op                       IN      NUMBER,
**        X_To_Op                         IN      NUMBER, -- op seq num to be added in WO
**        X_Standard_Operation_Id         IN      NUMBER,
**        x_error_code                    OUT     NUMBER,
**        x_error_msg                     OUT     VARCHAR2
**        ) IS
*/
--move enh? overload this

PROCEDURE Add_Operation(
        p_transaction_type_id           IN      NUMBER,
        P_Commit                        IN      NUMBER,
        X_Wip_Entity_Id                 IN      NUMBER,
        X_Organization_Id               IN      NUMBER,
        X_From_Op                       IN      NUMBER,
        X_To_Op                         IN      NUMBER,
        --NSO Modification by abedajna
        X_Standard_Operation_Id         IN      NUMBER,
        X_Op_Seq_Id                     IN      NUMBER,
        x_error_code                    OUT NOCOPY     NUMBER,
        x_error_msg                     OUT NOCOPY     VARCHAR2)
IS
BEGIN
    add_operation(
        p_transaction_type_id,
        P_Commit,
        X_Wip_Entity_Id,
        X_Organization_Id,
        X_From_Op,
        X_To_Op,
        X_Standard_Operation_Id,
        X_Op_Seq_Id,
        x_error_code,
        x_error_msg,
        null,
        null,
        null,
        null,
        null,
        null);
END;

PROCEDURE add_operation(
    p_transaction_type_id           IN      NUMBER,
    P_Commit                        IN      NUMBER,
    X_Wip_Entity_Id                 IN      NUMBER,
    X_Organization_Id               IN      NUMBER,
    X_From_Op                       IN      NUMBER,
    X_To_Op                         IN      NUMBER, -- op seq num to be added in WO
    X_Standard_Operation_Id         IN      NUMBER,
    X_Op_Seq_Id                     IN      NUMBER, -- CZH.I_OED-2, this is the replacement
    x_error_code                    OUT     NOCOPY NUMBER,
    x_error_msg                     OUT     NOCOPY VARCHAR2,
    p_txn_quantity                  IN      NUMBER,
    p_reco_op_flag                  IN      VARCHAR2,
    p_to_rtg_op_seq_num             IN      NUMBER,
    p_txn_date                      IN      DATE,
    p_dup_val_ignore                IN      VARCHAR2,
    p_jump_flag                     IN      VARCHAR2
    ) IS

--NSO Modification by abedajna end

    p_user          NUMBER := FND_GLOBAL.USER_ID;
    p_login         NUMBER := FND_GLOBAL.LOGIN_ID;
    p_req_id        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    p_appl_id       NUMBER := FND_GLOBAL.PROG_APPL_ID;
    p_prog_id       NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    p_curdate       DATE := SYSDATE;
    p_rtg_rev_date  DATE;    -- ADD: CZH.I_OED-1
    l_count         NUMBER := 0;
    l_stat_num      NUMBER;
    --l_last_op_seq NUMBER; -- DEL: CZH.I_9999
    l_op_seq_incr   NUMBER;
    -- l_max_op_seq NUMBER;
    l_op_seq_id     NUMBER;    --bugfix 2026218

    l_dept_id       number; -- abb H
    l_job_type      number; -- abb H
    l_scrap_account number; -- abb H
    l_est_absorption_account  number; -- abb H
    l_est_scrap_acc number;
    l_fm_op_seq_id  number; -- BUG2256872
    l_po_move_exists BOOLEAN ; -- OSP FP I
    l_recommended_op VARCHAR2(1) := 'N';
    l_start_quantity    NUMBER;
    x_returnStatus      VARCHAR2(1);
    l_reco_start_date       DATE;
    l_reco_completion_date  DATE;
    l_infi_start_date       DATE;
    l_job_copy_flag     NUMBER;
    l_wsor_max_res_seq_num  NUMBER := 0;

    -- Logging variables.....
    l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
    l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPOPRN.add_operation';
    l_param_tbl                             WSM_Log_PVT.param_tbl_type;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             number;
    l_msg_data                              varchar2(4000);

BEGIN
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'Inside WSMPOPRN p_transaction_type_id '||p_transaction_type_id||
        ' P_Commit '||P_Commit||
        ' X_Wip_Entity_Id '||X_Wip_Entity_Id||
        ' X_Organization_Id '||X_Organization_Id||
        ' X_From_Op '||X_From_Op||
        ' X_To_Op '||X_To_Op||
        ' X_Standard_Operation_Id '||X_Standard_Operation_Id||
        ' X_Op_Seq_Id '||X_Op_Seq_Id||
        ' p_txn_quantity '||p_txn_quantity||
        ' p_reco_op_flag '||p_reco_op_flag||
        ' p_to_rtg_op_seq_num '||p_to_rtg_op_seq_num||
        ' p_txn_date '||p_txn_date);
    END IF;

    -- We use program_id of -999 to indicate that the record is
    -- created by the custom moves form

    l_stat_num := 10;
--move enh 115.78 changed from WSMPCNST to WSMPUTIL
    IF WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y' THEN
        l_job_copy_flag := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE;
    ELSE
        l_job_copy_flag := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(x_organization_id);
    END IF;

    if (l_job_copy_flag = 1) then
        g_aps_wps_profile := 'Y';
    else
        g_aps_wps_profile := 'N';
    end if;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'g_aps_wps_profile '||g_aps_wps_profile);
    END IF;

    -- Moved down to fix bug # 1497882
    /*
    IF (p_transaction_type_id IN (1, 2)) THEN -- only for move and completion
    delete_operation (
         X_Wip_Entity_id,
         X_Organization_id,
--       X_From_Op,
         X_To_Op,
         X_Error_Code,
         X_Error_Msg);
    END IF;
    */
    -- End changes to fix bug # 1497882

    -- If move within the same operation, do nothing
l_stat_num := 200;
    SELECT --nvl(last_operation_seq_num, 9999), -- DEL: CZH.I_9999
           nvl(op_seq_num_increment, 10)
    INTO   --l_last_op_seq,                     -- DEL: CZH.I_9999
           l_op_seq_incr
    FROM   wsm_parameters
    WHERE  organization_id = X_Organization_Id;

    -- BC: CZH.BUG2168828, should call disable_operations even move to last operation
    IF (x_from_op = x_to_op)
    THEN -- Redundant check for Move interface
        return;
    -- BD: CZH.I_9999, 9999 is no longer the last op in WO
    /************************
    ELSIF (x_to_op = l_last_op_seq) THEN
        if (l_debug = 'Y') then -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Calling Disable_operations..');
        end if; -- czh:BUG1995161

        Disable_operations (x_Wip_entity_id,
                    x_Organization_id,
                x_From_op,
                x_error_code,
                x_error_msg );
    return;
    ************************/
    -- ED: CZH.I_9999
    END IF;
    -- EC: CZH.BUG2168828

    /* This is all extracted from wiloer.ppc */
    l_stat_num := 20;

    /* Code below added by AM for forward moves */

    -- BD: BUG1496147
    /***********************
    BEGIN
        SELECT unique max(operation_seq_num)
        INTO   l_max_op_seq
        FROM   wip_operations
        WHERE  WIP_ENTITY_ID = x_wip_entity_id
        AND    operation_seq_num NOT IN
               ( SELECT nvl(last_operation_seq_num, 9999)
                 FROM   wsm_parameters
                 WHERE  organization_id = x_organization_id ) ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_max_op_seq := 0;
    END;
    ************************/
    -- ED: BUG1496147

    if (l_debug = 'Y') then  -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Calling delete_operation..');
    end if;  -- czh:BUG1995161

    -- Moved here from up to fix bug # 1497882
    -- in form, opertion is added when to_op_seq is selected
l_stat_num := 210;
    delete_operation (X_Wip_Entity_id,
                      X_Organization_id,
                      x_to_op, -- l_max_op_seq + l_op_seq_incr, --X_To_Op,-- Fix bug #1496147
                      X_Error_Code,
                      X_Error_Msg);
    -- End changes to fix bug # 1497882


    if (l_debug = 'Y') then -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Calling Disable_operations..');
    end if; -- czh:BUG1995161

    -- CZH.I_9999, disable operation is called before adding the operation!
l_stat_num := 220;
    Disable_operations (x_Wip_entity_id,
            x_Organization_id,
            x_From_op,
            x_error_code,
            x_error_msg,
            p_txn_date);


    /* Above code added by AM for forward moves */

--move enh added the IF
    IF ((g_aps_wps_profile='N') AND (X_Op_Seq_Id IS NOT NULL)) THEN
        -- NSO Modification by abedajna begin
        -- Replaced Standard Operation Id by the op_seq_id

        -- BA: CZH.I_OED-1, should honor ROUTING_REVISION_DATE
l_stat_num := 230;
        --move enh added start_quantity
        SELECT NVL(ROUTING_REVISION_DATE, SYSDATE), start_quantity
        INTO   p_rtg_rev_date, l_start_quantity
        FROM   WIP_DISCRETE_JOBS wdj
        WHERE  wdj.ORGANIZATION_ID = X_Organization_Id
        AND    wdj.WIP_ENTITY_ID = X_Wip_Entity_Id;
        -- EA: CZH.I_OED-1

l_stat_num := 240;
        SELECT  count(*)
        INTO    l_count
        FROM    BOM_OPERATION_SEQUENCES bos,
            WIP_DISCRETE_JOBS wdj
        WHERE   wdj.WIP_ENTITY_ID = X_Wip_Entity_Id
        AND     wdj.ORGANIZATION_ID = X_Organization_Id
        --  AND     bos.standard_operation_id = X_Standard_Operation_Id
        AND     bos.operation_sequence_id = X_Op_Seq_Id
        AND     bos.routing_sequence_id = wdj.common_routing_sequence_id
        --BC: CZH.I_OED-1, should honor ROUTING_REVISION_DATE
        --bug1725145
        --validate disabled operation
        --AND     sysdate <= nvl(bos.disable_date, sysdate+1)
        --AND     bos.effectivity_date <= sysdate;
        --endfix 1725145
        AND     p_rtg_rev_date <= nvl(bos.disable_date, p_rtg_rev_date+1)
        AND     p_rtg_rev_date >= bos.effectivity_date;
        --EC: CZH.I_OED-1

--NSO Modification by abedajna end
    ELSIF ((g_aps_wps_profile='Y') AND (x_op_seq_id IS NOT NULL)) THEN
l_stat_num := 250;
        SELECT  count(*)
        INTO    l_count
        FROM    WSM_COPY_OPERATIONS WCO
        WHERE   WCO.WIP_ENTITY_ID = X_Wip_Entity_Id
        AND wco.operation_sequence_id = x_op_seq_id;
    END IF;

    if (l_debug = 'Y') then -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: l_count = '||l_count);
    end if; -- czh:BUG1995161

--move enh added the IF
    IF ((g_aps_wps_profile='N') OR (l_count=0)) THEN
        IF(l_count > 0) THEN   -- Not a Jump Operation
            if (l_debug = 'Y') then -- czh:BUG1995161
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: NOT a Jump operation. Inserting into WO..');
            end if; -- czh:BUG1995161

            -- OSP FP I begin
            l_stat_num := 260;
            l_po_move_exists := WSMPUTIL.check_po_move (
                                    p_sequence_id      => x_op_seq_id,
                                    p_sequence_id_type => 'O' ,
                                    p_routing_rev_date => p_rtg_rev_date,
                                    x_err_code         => x_error_code ,
                                    x_err_msg          => x_error_msg ) ;

            IF (x_error_code <> 0) THEN
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling WSMPUTIL.check_po_move: '||x_error_msg);
                return ;
            END IF;
            IF (l_po_move_exists) THEN
                FND_MESSAGE.SET_NAME('WSM','WSM_OP_PO_MOVE');
                x_error_code := -1;
                x_error_msg := FND_MESSAGE.GET;
                return ;
            END IF;
            -- OSP FP I end
l_stat_num := 270;
--bug 3162358 115.78 added CUMULATIVE_SCRAP_QUANTITY
            INSERT INTO WIP_OPERATIONS
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                ORGANIZATION_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                OPERATION_SEQUENCE_ID,
                STANDARD_OPERATION_ID,
                DEPARTMENT_ID,
                DESCRIPTION,
                SCHEDULED_QUANTITY,
                QUANTITY_IN_QUEUE,
                QUANTITY_RUNNING,
                QUANTITY_WAITING_TO_MOVE,
                QUANTITY_REJECTED,
                QUANTITY_SCRAPPED,
                QUANTITY_COMPLETED,
                FIRST_UNIT_START_DATE,
                FIRST_UNIT_COMPLETION_DATE,
                LAST_UNIT_START_DATE,
                LAST_UNIT_COMPLETION_DATE,
                PREVIOUS_OPERATION_SEQ_NUM,
                NEXT_OPERATION_SEQ_NUM,
                COUNT_POINT_TYPE,
                BACKFLUSH_FLAG,
                MINIMUM_TRANSFER_QUANTITY,
                DATE_LAST_MOVED,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                OPERATION_YIELD,
                OPERATION_YIELD_ENABLED,
                CUMULATIVE_SCRAP_QUANTITY,
                WSM_COSTED_QUANTITY_COMPLETED,
                LOWEST_ACCEPTABLE_YIELD) --mes
            SELECT  X_Wip_Entity_Id,
                --      X_From_Op + 10,
                --              X_From_Op + l_op_seq_incr,
                x_to_op, -- l_max_op_seq + l_op_seq_incr, -- Fix bug #1496147
                X_Organization_Id,
                p_curdate,
                p_user,
                p_curdate,
                p_user,
                p_login,
                DECODE(p_req_id, 0, '', p_req_id),
                DECODE(p_appl_id, 0, '', p_appl_id),
                DECODE(p_commit, 1, p_prog_id, -999),
                DECODE(p_prog_id, 0, '', p_curdate),
                SEQ.OPERATION_SEQUENCE_ID,
                SEQ.STANDARD_OPERATION_ID,
                SEQ.DEPARTMENT_ID,
                SEQ.OPERATION_DESCRIPTION,
                ROUND(DJ.Start_Quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                0, 0, 0, 0, 0, 0,
                DJ.SCHEDULED_START_DATE,
                DJ.SCHEDULED_COMPLETION_DATE,
                DJ.SCHEDULED_START_DATE,
                DJ.SCHEDULED_COMPLETION_DATE,
                -- Bug  4614970 0, 0,
                -- x_to_op - l_op_seq_incr,0, -- Bug 4614970 The previous line is commented and replaced by this line
                x_to_op - l_op_seq_incr,null, -- Bug 5336643 Populated null instead of zero
                SEQ.COUNT_POINT_TYPE,
                SEQ.BACKFLUSH_FLAG,
                NVL(SEQ.MINIMUM_TRANSFER_QUANTITY, 0),
                '',
                SEQ.ATTRIBUTE_CATEGORY,
                SEQ.ATTRIBUTE1,
                SEQ.ATTRIBUTE2,
                SEQ.ATTRIBUTE3,
                SEQ.ATTRIBUTE4,
                SEQ.ATTRIBUTE5,
                SEQ.ATTRIBUTE6,
                SEQ.ATTRIBUTE7,
                SEQ.ATTRIBUTE8,
                SEQ.ATTRIBUTE9,
                SEQ.ATTRIBUTE10,
                SEQ.ATTRIBUTE11,
                SEQ.ATTRIBUTE12,
                SEQ.ATTRIBUTE13,
                SEQ.ATTRIBUTE14,
                SEQ.ATTRIBUTE15,
                SEQ.YIELD,
                to_char(SEQ.OPERATION_YIELD_ENABLED),
                DJ.QUANTITY_SCRAPPED,
                0,
                SEQ.LOWEST_ACCEPTABLE_YIELD
            FROM    BOM_OPERATIONAL_ROUTINGS  R,
                BOM_OPERATION_SEQUENCES   SEQ,
                WIP_DISCRETE_JOBS DJ
            WHERE   SEQ.ROUTING_SEQUENCE_ID =
                        nvl(r.common_routing_sequence_id, r.routing_sequence_id)
             -- BC: CZH.I_OED-1, should honor routing revision date
             --AND  p_curdate >= SEQ.effectivity_date
             --AND  p_curdate <= NVL(SEQ.DISABLE_DATE,p_curdate+2)
             AND    p_rtg_rev_date >= SEQ.effectivity_date
             AND    p_rtg_rev_date <= NVL(SEQ.DISABLE_DATE, p_rtg_rev_date+2)
             -- EC: CZH.I_OED-1
             AND    R.ASSEMBLY_ITEM_ID =
                        DECODE( DJ.JOB_TYPE, 1,
                                DJ.PRIMARY_ITEM_ID, DJ.ROUTING_REFERENCE_ID)
             AND    DJ.WIP_ENTITY_ID = X_Wip_Entity_Id
             AND    DJ.ORGANIZATION_ID = X_Organization_Id
             AND    SEQ.operation_sequence_id = X_Op_Seq_Id
             --NSO  Modification by abedajna begin
             --AND  SEQ.Standard_operation_id = X_Standard_Operation_Id
             --NSO  Modification by abedajna end
             AND    SEQ.routing_sequence_id = dj.common_routing_sequence_id;

    --bugfix 2026218
    --copy attachment from operations document attachment defined in the network routing form.
            if sql%rowcount > 0 then
    l_stat_num := 280;
                select operation_sequence_id
                into   l_op_seq_id
                from   wip_operations
                where  wip_entity_id = x_wip_entity_id
                and    operation_seq_num = x_to_op
                and    organization_id = x_organization_id;

                FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                        X_FROM_ENTITY_NAME => 'BOM_OPERATION_SEQUENCES',
                        X_FROM_PK1_VALUE   => to_char(l_op_seq_id),
                        X_TO_ENTITY_NAME   => 'WSM_LOT_BASED_OPERATIONS',
                        X_TO_PK1_VALUE   => to_char(x_wip_entity_id),
                        X_TO_PK2_VALUE   => to_char(x_to_op),
                        X_TO_PK3_VALUE   => to_char(x_organization_id),
                        X_CREATED_BY     => p_user,
                        X_LAST_UPDATE_LOGIN => p_login,
                        X_PROGRAM_APPLICATION_ID => p_appl_id,
                        X_PROGRAM_ID => p_prog_id,
                        X_REQUEST_ID => p_req_id);
            end if;
            --endfix 2026218
            if (l_debug = 'Y') then -- czh:BUG1995161
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Inserted '
                         ||sql%rowcount||' records in WO.');
            end if; -- czh:BUG1995161


        ELSE  -- Jump Operation
            if (l_debug = 'Y') then -- czh:BUG1995161
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: JUMP operation. Inserting into WO..');
            end if; -- czh:BUG1995161


            -- OSP FP I begin
            l_stat_num := 290;
            l_po_move_exists := WSMPUTIL.check_po_move (
                    p_sequence_id      => x_standard_operation_id,
                    p_sequence_id_type => 'S' ,
                    p_routing_rev_date => p_rtg_rev_date,
                    x_err_code         => x_error_code ,
                    x_err_msg          => x_error_msg ) ;


            IF (x_error_code <> 0) THEN
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation '||
                    'calling WSMPUTIL.check_po_move: '||x_error_msg);
                return ;
            END IF;
            IF (l_po_move_exists) THEN
                FND_MESSAGE.SET_NAME('WSM','WSM_OP_PO_MOVE');
                x_error_code := -1;
                x_error_msg := FND_MESSAGE.GET;
                return ;
            END IF;
                -- OSP FP I End

            -- BA: BUG2256872,  fetch previous_operation_seq_id only if operation_sequence_id is NULL
            l_stat_num := 300;
            select nvl(operation_sequence_id, previous_operation_seq_id)
            into   l_fm_op_seq_id
            from   wip_operations
            where  wip_entity_id     = x_wip_entity_id
            and    operation_seq_num = x_from_op
            and    organization_id   = x_organization_id;
            -- EA: BUG2256872

            l_stat_num := 310;
--bug 3162358 115.78 added CUMULATIVE_SCRAP_QUANTITY
            INSERT INTO WIP_OPERATIONS
                    (WIP_ENTITY_ID,
                    OPERATION_SEQ_NUM,
                    ORGANIZATION_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    REQUEST_ID,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    OPERATION_SEQUENCE_ID,
                    STANDARD_OPERATION_ID,
                    DEPARTMENT_ID,
                    DESCRIPTION,
                    SCHEDULED_QUANTITY,
                    QUANTITY_IN_QUEUE,
                    QUANTITY_RUNNING,
                    QUANTITY_WAITING_TO_MOVE,
                    QUANTITY_REJECTED,
                    QUANTITY_SCRAPPED,
                    QUANTITY_COMPLETED,
                    FIRST_UNIT_START_DATE,
                    FIRST_UNIT_COMPLETION_DATE,
                    LAST_UNIT_START_DATE,
                    LAST_UNIT_COMPLETION_DATE,
                    PREVIOUS_OPERATION_SEQ_NUM,
                    NEXT_OPERATION_SEQ_NUM,
                    COUNT_POINT_TYPE,
                    BACKFLUSH_FLAG,
                    MINIMUM_TRANSFER_QUANTITY,
                    DATE_LAST_MOVED,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    OPERATION_YIELD,
                    OPERATION_YIELD_ENABLED,   -- BC: BUG2256872
                    PREVIOUS_OPERATION_SEQ_ID,
                    CUMULATIVE_SCRAP_QUANTITY, -- EC: BUG2256872
                    WSM_COSTED_QUANTITY_COMPLETED,
                    LOWEST_ACCEPTABLE_YIELD) --mes
            SELECT  X_Wip_Entity_Id,
                    --      X_From_Op + 10,
                    --              X_From_Op + l_op_seq_incr,
                    x_to_op, -- l_max_op_seq + l_op_seq_incr, -- Fix bug #1496147
                    X_Organization_Id,
                    p_curdate,
                    p_user,
                    p_curdate,
                    p_user,
                    p_login,
                    DECODE(p_req_id, 0, '', p_req_id),
                    DECODE(p_appl_id, 0, '', p_appl_id),
                    DECODE(p_commit, 1, p_prog_id, -999),
                    DECODE(p_prog_id, 0, '', p_curdate),
                    NULL, --SEQ.OPERATION_SEQUENCE_ID,
                    bso.STANDARD_OPERATION_ID,
                    bso.DEPARTMENT_ID,
                    bso.OPERATION_DESCRIPTION,
                    ROUND(DJ.Start_Quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                    0, 0, 0, 0, 0, 0,
                    DJ.SCHEDULED_START_DATE,
                    DJ.SCHEDULED_COMPLETION_DATE,
                    DJ.SCHEDULED_START_DATE,
                    DJ.SCHEDULED_COMPLETION_DATE,
                    -- Bug  4614970 0, 0,
                    -- x_to_op - l_op_seq_incr,0, -- Bug 4614970 The previous line is commented and replaced by this line
                    x_to_op - l_op_seq_incr,null, -- Bug 5336643 Populated null instead of zero
                    bso.COUNT_POINT_TYPE,
                    bso.BACKFLUSH_FLAG,
                    NVL(bso.MINIMUM_TRANSFER_QUANTITY, 0),
                    '',
                    bso.ATTRIBUTE_CATEGORY,
                    bso.ATTRIBUTE1,
                    bso.ATTRIBUTE2,
                    bso.ATTRIBUTE3,
                    bso.ATTRIBUTE4,
                    bso.ATTRIBUTE5,
                    bso.ATTRIBUTE6,
                    bso.ATTRIBUTE7,
                    bso.ATTRIBUTE8,
                    bso.ATTRIBUTE9,
                    bso.ATTRIBUTE10,
                    bso.ATTRIBUTE11,
                    bso.ATTRIBUTE12,
                    bso.ATTRIBUTE13,
                    bso.ATTRIBUTE14,
                    bso.ATTRIBUTE15,
                    bso.YIELD,
                    to_char(bso.OPERATION_YIELD_ENABLED), --BC: BUG2256872
                    l_fm_op_seq_id,                       --EC: BUG2256872
                    DJ.QUANTITY_SCRAPPED,
                    0,
                    BSO.LOWEST_ACCEPTABLE_YIELD
            FROM    BOM_STANDARD_OPERATIONS bso,
                    WIP_DISCRETE_JOBS       DJ
            WHERE   DJ.WIP_ENTITY_ID = X_Wip_Entity_Id
            AND     DJ.ORGANIZATION_ID = X_Organization_Id
            AND     bso.Standard_operation_id = X_Standard_Operation_Id;

        -- BA: bugfix 2626658/2681671 moved to here from below
        --copy attachment from operations document attachment defined in the BOM standard operation form.
            if sql%rowcount > 0 then
                FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                    X_FROM_ENTITY_NAME  => 'BOM_STANDARD_OPERATIONS',
                    X_FROM_PK1_VALUE    => to_char(x_STANDARD_OPERATION_ID),
                    X_TO_ENTITY_NAME    => 'WSM_LOT_BASED_OPERATIONS',
                    X_TO_PK1_VALUE      => to_char(x_wip_entity_id),
                    X_TO_PK2_VALUE      => to_char(x_to_op),
                    X_TO_PK3_VALUE      => to_char(x_organization_id),
                    X_CREATED_BY        => p_user,
                    X_LAST_UPDATE_LOGIN => p_login,
                    X_PROGRAM_APPLICATION_ID => p_appl_id,
                    X_PROGRAM_ID        => p_prog_id,
                    X_REQUEST_ID        => p_req_id);
            end if;

            if (l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,
                    'WSMPOPRN.add_operation: Inserted '||sql%rowcount||' records in WO.');
            end if;
            -- EA: bugfix 2626658/2681671
            --mes
            UPDATE  WSM_LOT_BASED_JOBS
            SET     current_job_op_seq_num = x_to_op,
                    current_rtg_op_seq_num = null
            WHERE   WIP_ENTITY_ID = x_wip_entity_id;

            --bug 5191386 - OSFMST1: SCRAP CODES AND BONUS CODES NOT DISPLAYED IN MOVE OUT FOR OP OUTSIDE RT
            copy_to_op_mes_info(
              p_wip_entity_id           => x_wip_entity_id
            , p_to_job_op_seq_num       => x_to_op
            , p_to_rtg_op_seq_num       => null
            , p_txn_quantity            => p_txn_quantity
            , p_user                    => p_user
            , p_login                   => p_login
            , x_return_status           => l_return_status
            , x_msg_count               => l_msg_count
            , x_msg_data                => l_msg_data
            );

            IF l_return_status = g_ret_error THEN
              RAISE FND_API.G_EXC_ERROR;
              l_stat_num := 370;
              IF (l_msg_count = 1)  THEN
                x_error_code := -1;
                x_error_msg := l_msg_data;
              ELSE
                FOR i IN 1..l_msg_count LOOP
                    x_error_code := -1;
                    x_error_msg := substr(x_error_msg||fnd_msg_pub.get, 1, 4000);
                END LOOP;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = g_ret_unexpected THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --end bug 5191386
        END IF;

        -- BD: bugfix 2626658/2681671
        -- the following attachement is for jump operation. should move inside Jump condition
        /******
        --bugfix 2026218
        --copy attachment from operations document attachment defined in the BOM standard operation form.
        if sql%rowcount > 0 then
           FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                        X_FROM_ENTITY_NAME => 'BOM_STANDARD_OPERATIONS',
                        X_FROM_PK1_VALUE   => to_char(x_STANDARD_OPERATION_ID),
                        X_TO_ENTITY_NAME   => 'WSM_LOT_BASED_OPERATIONS',
                        X_TO_PK1_VALUE   => to_char(x_wip_entity_id),
                        X_TO_PK2_VALUE   => to_char(x_to_op),
                        X_TO_PK3_VALUE   => to_char(x_organization_id),
                        X_CREATED_BY     => p_user,
                        X_LAST_UPDATE_LOGIN => p_login,
                        X_PROGRAM_APPLICATION_ID => p_appl_id,
                        X_PROGRAM_ID => p_prog_id,
                        X_REQUEST_ID => p_req_id);
        end if;
        --endfix 2026218

        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,
                    'WSMPOPRN.add_operation: Inserted '||sql%rowcount||' records in WO.');
        end if;
        ******/
        -- ED: bugfix 2626658/2681671

        l_stat_num := 30;
        if (l_debug = 'Y') then -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Calling set_prev_next..');
        end if; -- czh:BUG1995161
        l_stat_num := 320;
        -- Bug 4614970 : Changed the signature of set_prev_next so that only one row in WO is updated in the procedure
        /******
        set_prev_next(X_wip_entity_id,
              x_organization_id,
              x_error_code,
              x_error_msg);
        ******/

        set_prev_next(
            X_wip_entity_id,
            x_organization_id,
            x_from_op,
            x_to_op,
            l_op_seq_incr,
            x_error_code,
            x_error_msg);

        l_stat_num := 40;
        if (l_debug = 'Y') then -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Calling create_op_details..');
        end if; -- czh:BUG1995161

-- abb H optional scrap modification begin

        begin

            l_stat_num := 40.1;
            SELECT  BD.DEPARTMENT_ID, BD.SCRAP_ACCOUNT, BD.EST_ABSORPTION_ACCOUNT
            into    l_dept_id, l_scrap_account, l_est_absorption_account
            FROM    WIP_OPERATIONS WO,
                    BOM_DEPARTMENTS BD
            WHERE   WO.WIP_ENTITY_ID = x_wip_entity_id
            AND     WO.OPERATION_SEQ_NUM = x_to_op
            AND     WO.ORGANIZATION_ID = x_organization_id
            AND     WO.DEPARTMENT_ID = BD.DEPARTMENT_ID;

            l_stat_num := 40.15;
            select  job_type
            into    l_job_type
            from    wip_discrete_jobs
            where   wip_entity_id = x_wip_entity_id;

            l_stat_num := 40.2;
            x_error_code := 0;
            l_est_scrap_acc := WSMPUTIL.WSM_ESA_ENABLED(x_wip_entity_id, x_error_code, x_error_msg);
            if x_error_code <> 0 then
                x_error_msg := 'WSMOPRNB.create_op_details('||l_stat_num||')'|| x_error_msg;
                rollback;
                return;
            end if;

            l_stat_num := 40.3;
            if (l_est_scrap_acc = 1 and l_job_type = 1) and
               (l_scrap_account is null or l_est_absorption_account is null) then
                x_error_code := -1;
                fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                fnd_message.set_token('DEPT_ID',to_char(l_dept_id));
                x_error_msg := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMOPRNB.create_op_details('||l_stat_num||')'|| x_error_msg);
                rollback;
                return;
            end if;

        exception
            when others then
            x_error_code := SQLCODE;
            x_error_msg := 'WSMOPRNB.add_operation('||l_stat_num||')'|| substr(SQLERRM,1,1000);
            rollback;
            return;
        end;

-- abb H optional scrap modification end

        l_stat_num := 330;
        create_op_details(x_wip_entity_id,
                      x_organization_id,
                  x_to_op, -- l_max_op_seq + l_op_seq_incr,-- Fix bug #1496147
                  x_error_code,
                  x_error_msg);
    ELSE --(g_aps_wps_profile='Y')
        l_stat_num := 260;
--move enh 115.76 removed the po_move check since it is done during copy creation
/*        l_po_move_exists := WSMPUTIL.check_po_move (
                                p_sequence_id      => x_op_seq_id,
                                p_sequence_id_type => 'O' ,
                                p_routing_rev_date => p_rtg_rev_date,
                                x_err_code         => x_error_code ,
                                x_err_msg          => x_error_msg ) ;

        IF (x_error_code <> 0) THEN
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling WSMPUTIL.check_po_move: '||x_error_msg);
            return ;
        END IF;
        IF (l_po_move_exists) THEN
            FND_MESSAGE.SET_NAME('WSM','WSM_OP_PO_MOVE');
            x_error_code := -1;
            x_error_msg := FND_MESSAGE.GET;
            return ;
        END IF;
*/
        BEGIN
            l_stat_num := 340;

            SELECT  nvl(WCO.recommended, 'N'), WCO.RECO_START_DATE, WCO.reco_completion_date,
            WCO.DEPARTMENT_ID, WCO.SCRAP_ACCOUNT, WCO.EST_ABSORPTION_ACCOUNT
            INTO    l_recommended_op, l_reco_start_date, l_reco_completion_date,
            l_dept_id, l_scrap_account, l_est_absorption_account
            FROM    WSM_COPY_OPERATIONS WCO
            WHERE   wip_entity_id = X_Wip_Entity_Id
            AND     operation_sequence_id = x_op_seq_id;

            l_stat_num := 60;

            WSMPOPRN.copy_plan_to_execution(x_error_code
                        , x_error_msg
                        , X_Organization_Id
                        , X_Wip_Entity_Id
                        , x_to_op
                        , p_to_rtg_op_seq_num
                        , x_op_seq_id
                        , l_recommended_op
                        , p_txn_quantity
                        , p_txn_date
                        , p_user
                        , p_login
                        , p_req_id
                        , p_appl_id
                        , p_prog_id
                        , 'N'
                        , l_start_quantity);

            IF (x_error_code <> 0) THEN
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling WSMPUTIL.copy_plan_to_execution: '||x_error_msg);
                return ;
            ELSE
                IF (l_debug = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling WSMPUTIL.copy_plan_to_execution returned success');
                END IF;
            END IF;

--move enh 115.76 commented this out since this is merged with the previous sql
/*        l_stat_num := 71;

            SELECT  WCO.DEPARTMENT_ID, WCO.SCRAP_ACCOUNT, WCO.EST_ABSORPTION_ACCOUNT
            into    l_dept_id, l_scrap_account, l_est_absorption_account
            FROM    WSM_COPY_OPERATIONS WCO
            WHERE   WCO.WIP_ENTITY_ID = X_Wip_Entity_Id
            AND     WCO.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
            AND     WCO.ORGANIZATION_ID = X_Organization_Id;
*/
            l_stat_num := 80;

            select job_type
            into l_job_type
            from wip_discrete_jobs
            where wip_entity_id = X_Wip_Entity_Id;

            l_stat_num := 90;

            x_error_code := 0;
            l_est_scrap_acc := WSMPUTIL.WSM_ESA_ENABLED(X_Wip_Entity_Id, x_error_code, x_error_msg);
            if x_error_code <> 0 then
                x_error_msg := 'WSMOPRNB.('||l_stat_num||')'|| x_error_msg;
                rollback;
                return;
            end if;

            l_stat_num := 100;

            if (l_est_scrap_acc = 1 and l_job_type = 1) and
               (l_scrap_account is null or l_est_absorption_account is null) then
                x_error_code := -1;
                fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                fnd_message.set_token('DEPT_ID',to_char(l_dept_id));
                x_error_msg := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log, 'WSMOPRNB.create_op_details('||l_stat_num||')'|| x_error_msg);
                rollback;
                return;
            end if;

        END;
        --endfix 2026218
        if (l_debug = 'Y') then -- czh:BUG1995161
           fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: Inserted '
                     ||sql%rowcount||' records in WO.');
        end if; -- czh:BUG1995161

    END IF; --g_aps_wps=1
    IF (g_aps_wps_profile='Y') THEN
            l_stat_num := 70;

        UPDATE  WSM_LOT_BASED_JOBS wlbj
        SET     wlbj.on_rec_path = l_recommended_op
        WHERE   wlbj.wip_entity_id = X_Wip_Entity_Id
        AND     wlbj.organization_id = X_Organization_Id
        AND     wlbj.on_rec_path <> l_recommended_op;

        BEGIN
            SELECT nvl(max(resource_seq_num), 10)
            INTO   l_wsor_max_res_seq_num
            FROM   WIP_SUB_OPERATION_RESOURCES WSOR
            WHERE  wip_entity_id = x_wip_entity_id
            AND    OPERATION_SEQ_NUM = x_to_op;
        EXCEPTION
            WHEN no_data_found THEN
                null;
        END;

        IF (l_count=0) THEN --jump outside rtg
          INSERT INTO WIP_SUB_OPERATION_RESOURCES
                    (wip_entity_id,
                    operation_seq_num,
                    resource_seq_num,
                    organization_id,
                    repetitive_schedule_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    resource_id,
                    uom_code,
                    basis_type,
                    usage_rate_or_amount,
                    activity_id,
                    scheduled_flag,
                    assigned_units,
            maximum_assigned_units, /* ST : Detailed Scheduling */
                    autocharge_type,
                    standard_rate_flag,
                    applied_resource_units,
                    applied_resource_value,
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
                    completion_date,
                    start_date,
                    schedule_seq_num,
                    substitute_group_num,
                    replacement_group_num,
                    setup_id)
            SELECT  WO.wip_entity_id,
                    x_to_op,
--bug 3311695 changed the select below to a private function to be compatible with db 8.1.7.4
/*                    rownum + (SELECT nvl(max(resource_seq_num), 10)
                              FROM   WIP_SUB_OPERATION_RESOURCES WSOR
                              WHERE  wip_entity_id = x_wip_entity_id
                              AND    OPERATION_SEQ_NUM = x_to_op),--.resource_seq_num
*/
                    (rownum + l_wsor_max_res_seq_num),
                    WO.organization_id,
                    null,
                    SYSDATE ,
                    p_user,
                    SYSDATE,
                    p_user,
                    p_login,
                    BSSOR.resource_id,
                    BR.unit_of_measure,
                    BSSOR.basis_type,
                    BSSOR.usage_rate_or_amount,
                    BSSOR.activity_id,
                    BSSOR.schedule_flag,
                    BSSOR.assigned_units,
            BSSOR.assigned_units, /* ST : Detailed Scheduling */
                    BSSOR.autocharge_type,
                    BSSOR.standard_rate_flag,
                    0, --WCOR.applied_resource_units,
                    0, -- WCOR.applied_resource_value,
                    BSSOR.attribute_category,
                    BSSOR.attribute1,
                    BSSOR.attribute2,
                    BSSOR.attribute3,
                    BSSOR.attribute4,
                    BSSOR.attribute5,
                    BSSOR.attribute6,
                    BSSOR.attribute7,
                    BSSOR.attribute8,
                    BSSOR.attribute9,
                    BSSOR.attribute10,
                    BSSOR.attribute11,
                    BSSOR.attribute12,
                    BSSOR.attribute13,
                    BSSOR.attribute14,
                    BSSOR.attribute15,
                    p_txn_date,
                    p_txn_date,
                    BSSOR.schedule_seq_num  , --NULL, --schedule_seq_num, / -- Bug 7371846
                    BSSOR.substitute_group_num,
                    BSSOR.replacement_group_num, --replacement_group_num,
                    NULL --setup_id
            FROM    BOM_RESOURCES BR,
                    BOM_STD_SUB_OP_RESOURCES BSSOR,
                    WIP_OPERATIONS wo
            WHERE   WO.WIP_ENTITY_ID = x_wip_entity_id
            AND     WO.OPERATION_SEQ_NUM = x_to_op
            AND     BSSOR.standard_operation_id = WO.standard_operation_id
            AND     BSSOR.RESOURCE_ID = BR.RESOURCE_ID;
        END IF;
--moved the following code to after processing move in form and interface

        /***********
        IF ((p_jump_flag = 'Y') OR (l_recommended_op <> 'Y') OR (l_reco_start_date IS NULL)
        OR (l_reco_completion_date IS NULL)) THEN

            SELECT  last_unit_completion_date
            INTO    l_infi_start_date
            FROM    WIP_OPERATIONS
            WHERE   wip_entity_id = X_Wip_Entity_Id
            AND     organization_id = X_Organization_Id
            AND     operation_seq_num = X_From_Op;

            wsm_infinite_scheduler_pvt.schedule(
                    p_initMsgList   => fnd_api.g_true,
                    p_endDebug      => fnd_api.g_true,
                    p_orgID         => X_Organization_Id,
                    p_wipEntityID   => X_Wip_Entity_Id,
                    p_scheduleMode  => WIP_CONSTANTS.CURRENT_OP,
                    p_startDate     => l_infi_start_date,
                    p_endDate       => null,
                    p_opSeqNum      => -X_To_Op,
                    p_scheQuantity  =>  p_txn_quantity,
                    x_returnStatus  => x_returnStatus,
                    x_errorMsg      => x_error_msg);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling wsm_infinite_scheduler_pvt.schedule: '||x_error_msg);
                x_error_code := -1;
                return ;
            ELSE
                IF (l_debug = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling wsm_infinite_scheduler_pvt.schedule returned success');
                END IF;
            END IF;
        END IF;
        ***********/
    END IF;

EXCEPTION
    -- This just means that the operation was already inserted
    WHEN dup_val_on_index THEN
        NULL;

    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.add_operation('||l_stat_num||')'|| substr(SQLERRM,1,200);
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation: other excpn: (stmt'||l_stat_num
                                         ||'):'||x_error_msg);
END add_operation;


PROCEDURE Disable_operations (
    x_Wip_entity_id     IN NUMBER,
    x_Organization_id   IN NUMBER,
    x_From_op           IN NUMBER,
    x_error_code        OUT NOCOPY NUMBER,
    x_err_msg           OUT NOCOPY VARCHAR2,
    p_txn_date          IN  DATE) IS

BEGIN
        -- CZH.I_9999, Disable_operations should be called before insert the
        -- operation in to WO, hence, all the operations with op_seq_num
        -- greater than x_from_op should be disabled!

    UPDATE wip_operations
    SET    count_point_type = 3,
           scheduled_quantity = 0, -- Added to fix bug #2686501
--bug 3595728 change from sysdate to p_txn_date-1 second
--           disable_date = sysdate -- Bug 2931071
            disable_date = p_txn_date - 1/(24*60*60)
--end bug 3595728
    WHERE  wip_entity_id = x_wip_entity_id
    AND    operation_seq_num > x_from_op;
    -- BD: CZH.I_9999
    --AND    operation_seq_num NOT IN
    --  (SELECT nvl(last_operation_seq_num, 9999)
    --  FROM wsm_parameters
    --  WHERE organization_id = x_organization_id ) ;
    -- ED: CZH.I_9999

    -- bug 3203505 change order of update WOR and WRO
    UPDATE wip_operation_resources
    SET    autocharge_type = 2
    WHERE  wip_entity_id = x_wip_entity_id
    AND    operation_seq_num > x_from_op;
    -- BD: CZH.I_9999
    --AND    operation_seq_num NOT IN
    --  (SELECT nvl(last_operation_seq_num, 9999)
    --  FROM wsm_parameters
    --  WHERE organization_id = x_organization_id ) ;
    -- ED: CZH.I_9999

    UPDATE wip_requirement_operations
    SET    required_quantity = 0
           --quantity_per_assembly = 0  abb, bug 2931071
    WHERE  wip_entity_id = x_wip_entity_id
    AND    operation_seq_num > x_from_op;
    -- BD: CZH.I_9999
    --AND    operation_seq_num NOT IN
    --  (SELECT nvl(last_operation_seq_num, 9999)
    --  FROM wsm_parameters
    --  WHERE organization_id = x_organization_id ) ;
    -- ED: CZH.I_9999

EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_err_msg := 'WSMOPRNB.disable_operation : '|| substr(SQLERRM,1,200);

        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.Disable_operations: other excpn: '|| x_err_msg);


END Disable_operations;


PROCEDURE Delete_Operation(
        X_Wip_Entity_Id         IN      NUMBER,
        X_Organization_id       IN      NUMBER,
        --X_From_Op             IN      NUMBER,
        X_To_Op                 IN      NUMBER,
        x_error_code            OUT NOCOPY     NUMBER,
        x_error_msg             OUT NOCOPY     VARCHAR2
        ) IS
l_stat_num NUMBER;

BEGIN
l_stat_num := 10;
    DELETE  FROM WIP_OPERATIONS
    WHERE   WIP_ENTITY_ID = X_Wip_Entity_id
    --AND   OPERATION_SEQ_NUM > X_From_Op
    AND     OPERATION_SEQ_NUM = X_To_Op
    AND     PROGRAM_ID = -999
    AND     ORGANIZATION_ID = X_Organization_Id;

    IF SQL%ROWCOUNT > 0 THEN
       l_stat_num := 20;
       --bugfix 2026218
       --delete attached document, since operation was deleted from wip_operations table.

       FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                          X_entity_name => 'WSM_LOT_BASED_OPERATIONS',
                          X_pk1_value => to_char(x_wip_entity_id),
                          X_pk2_value => to_char(x_to_op),
                          x_pk3_value => to_char(x_organization_id),
                          X_delete_document_flag => 'Y');
       --endfix 2026218
       -- Bug 4614970 Call to set_prev_next is not required in this procedure
       -- set_prev_next gets called eventually in add_operation at a different place.
       /**************
       set_prev_next(X_Wip_Entity_id,
             X_Organization_Id,
             x_error_code,
             x_error_msg);
       ****************/
       l_stat_num := 30;
       DELETE FROM WIP_OPERATION_RESOURCES
       WHERE  WIP_ENTITY_ID = X_Wip_Entity_id
       --AND  OPERATION_SEQ_NUM > X_From_Op
       AND    OPERATION_SEQ_NUM = X_To_Op
       AND    PROGRAM_ID = -999
       AND    ORGANIZATION_ID = X_Organization_Id;

       l_stat_num := 40;
       DELETE FROM WIP_OPERATION_YIELDS
       WHERE WIP_ENTITY_ID = X_Wip_Entity_id
       --AND OPERATION_SEQ_NUM > X_From_Op
       AND   OPERATION_SEQ_NUM = X_To_Op
       AND   PROGRAM_ID = -999
       AND   ORGANIZATION_ID = X_Organization_Id;

       l_stat_num := 50;
       DELETE FROM WIP_REQUIREMENT_OPERATIONS
       WHERE  WIP_ENTITY_ID = X_Wip_Entity_id
       --AND  OPERATION_SEQ_NUM > X_From_Op
       AND    OPERATION_SEQ_NUM = X_To_Op
       AND    ORGANIZATION_ID = X_Organization_Id;
    END IF;
EXCEPTION
        WHEN others THEN
                x_error_code := SQLCODE;
                x_error_msg := 'WSMOPRNB.delete_operation('||l_stat_num||')'|| substr(SQLERRM,1,200);

                -- czh:BUG1995161
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.delete_operation: other excpn: '|| x_error_msg);

END delete_operation;

PROCEDURE create_op_details (
         X_wip_entity_Id        IN      NUMBER,
         X_organization_Id      IN      NUMBER,
         X_op_seq_num           IN      NUMBER,
         x_error_code           OUT NOCOPY     NUMBER,
         x_error_msg            OUT NOCOPY     VARCHAR2
     ) IS
l_stat_num NUMBER;

BEGIN
l_stat_num := 10;
        INSERT INTO WIP_OPERATION_RESOURCES
                (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
                ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
                RESOURCE_ID, UOM_CODE,
                BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
                SCHEDULED_FLAG, ASSIGNED_UNITS, AUTOCHARGE_TYPE,
                STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
                START_DATE, COMPLETION_DATE,
                ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
                ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
                ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
                ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
                ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
                ATTRIBUTE15,
                SCHEDULE_SEQ_NUM,                   --bugfix 2493065
                SUBSTITUTE_GROUP_NUM,
                PRINCIPLE_FLAG,
                SETUP_ID)
         SELECT OPS.WIP_ENTITY_ID, OPS.OPERATION_SEQ_NUM, ORS.RESOURCE_SEQ_NUM,
                OPS.ORGANIZATION_ID, OPS.REPETITIVE_SCHEDULE_ID,
                OPS.LAST_UPDATE_DATE, OPS.LAST_UPDATED_BY, OPS.CREATION_DATE,
                OPS.CREATED_BY, OPS.LAST_UPDATE_LOGIN, OPS.REQUEST_ID,
                OPS.PROGRAM_APPLICATION_ID, OPS.PROGRAM_ID,
                OPS.PROGRAM_UPDATE_DATE, ORS.RESOURCE_ID, RSC.UNIT_OF_MEASURE,
                ORS.BASIS_TYPE, ORS.USAGE_RATE_OR_AMOUNT, ORS.ACTIVITY_ID,
                ORS.SCHEDULE_FLAG, ORS.ASSIGNED_UNITS, ORS.AUTOCHARGE_TYPE,
                ORS.STANDARD_RATE_FLAG, 0, 0,
                OPS.FIRST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
                ORS.ATTRIBUTE_CATEGORY, ORS.ATTRIBUTE1, ORS.ATTRIBUTE2,
                ORS.ATTRIBUTE3, ORS.ATTRIBUTE4, ORS.ATTRIBUTE5,
                ORS.ATTRIBUTE6, ORS.ATTRIBUTE7, ORS.ATTRIBUTE8,
                ORS.ATTRIBUTE9, ORS.ATTRIBUTE10, ORS.ATTRIBUTE11,
                ORS.ATTRIBUTE12, ORS.ATTRIBUTE13, ORS.ATTRIBUTE14,
                ORS.ATTRIBUTE15,
                ORS.SCHEDULE_SEQ_NUM,                   --bugfix 2493065
                ORS.SUBSTITUTE_GROUP_NUM,
                ORS.PRINCIPLE_FLAG,
                ORS.SETUP_ID
           FROM BOM_RESOURCES RSC,
                BOM_OPERATION_RESOURCES ORS,
                WIP_OPERATIONS OPS
          WHERE OPS.ORGANIZATION_ID = X_Organization_Id
            AND OPS.WIP_ENTITY_ID = X_Wip_Entity_Id
        AND OPS.OPERATION_SEQ_NUM = X_op_seq_num
            AND OPS.OPERATION_SEQUENCE_ID = ORS.OPERATION_SEQUENCE_ID
            AND ORS.RESOURCE_ID = RSC.RESOURCE_ID
            AND RSC.ORGANIZATION_ID = OPS.ORGANIZATION_ID;

-- Begin bugfix 1523334 : If the above INSERT fails, it could be because OPS.OPERATION_SEQUENCE_ID
--            is null. This will be true in case of JUMP operation.
--            We will fetch the details from BOM_STD_OP_RESOURCES

    IF (sql%rowcount = 0) THEN
l_stat_num := 15;
         INSERT INTO WIP_OPERATION_RESOURCES
                (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
                ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
                RESOURCE_ID, UOM_CODE,
                BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
                SCHEDULED_FLAG, ASSIGNED_UNITS, AUTOCHARGE_TYPE,
                STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
                START_DATE, COMPLETION_DATE,
                ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
                ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
                ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
                ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
                ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
                ATTRIBUTE15,
		SCHEDULE_SEQ_NUM,                  --Added : -- bug 7371846
                SUBSTITUTE_GROUP_NUM,              --Added : -- bug 7371846
                REPLACEMENT_GROUP_NUM  )           --Added : -- bug 7371846
          SELECT OPS.WIP_ENTITY_ID, OPS.OPERATION_SEQ_NUM, ORS.RESOURCE_SEQ_NUM,
                OPS.ORGANIZATION_ID, OPS.REPETITIVE_SCHEDULE_ID,
                OPS.LAST_UPDATE_DATE, OPS.LAST_UPDATED_BY, OPS.CREATION_DATE,
                OPS.CREATED_BY, OPS.LAST_UPDATE_LOGIN, OPS.REQUEST_ID,
                OPS.PROGRAM_APPLICATION_ID, OPS.PROGRAM_ID,
                OPS.PROGRAM_UPDATE_DATE, ORS.RESOURCE_ID, RSC.UNIT_OF_MEASURE,
                ORS.BASIS_TYPE, ORS.USAGE_RATE_OR_AMOUNT, ORS.ACTIVITY_ID,
                ORS.SCHEDULE_FLAG, ORS.ASSIGNED_UNITS, ORS.AUTOCHARGE_TYPE,
                ORS.STANDARD_RATE_FLAG, 0, 0,
                OPS.FIRST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
                ORS.ATTRIBUTE_CATEGORY, ORS.ATTRIBUTE1, ORS.ATTRIBUTE2,
                ORS.ATTRIBUTE3, ORS.ATTRIBUTE4, ORS.ATTRIBUTE5,
                ORS.ATTRIBUTE6, ORS.ATTRIBUTE7, ORS.ATTRIBUTE8,
                ORS.ATTRIBUTE9, ORS.ATTRIBUTE10, ORS.ATTRIBUTE11,
                ORS.ATTRIBUTE12, ORS.ATTRIBUTE13, ORS.ATTRIBUTE14,
                ORS.ATTRIBUTE15,
		ORS.RESOURCE_SEQ_NUM,                  --Added :  -- bug 7371846
                ORS.SUBSTITUTE_GROUP_NUM,              --Added :  -- bug 7371846
                0                                      --Added :  -- make it as zero on resources level -- bug 7371846
          FROM BOM_RESOURCES RSC,
                BOM_STD_OP_RESOURCES ORS,
                WIP_OPERATIONS OPS
          WHERE OPS.ORGANIZATION_ID = X_Organization_Id
            AND OPS.WIP_ENTITY_ID = X_Wip_Entity_Id
        AND OPS.OPERATION_SEQ_NUM = X_op_seq_num
            AND OPS.STANDARD_OPERATION_ID = ORS.STANDARD_OPERATION_ID
            AND ORS.RESOURCE_ID = RSC.RESOURCE_ID
            AND RSC.ORGANIZATION_ID = OPS.ORGANIZATION_ID;
    END IF;
-- End bugfix 1523334

-- bugfix 1611094
-- for jumping operation, the operation_seq_id insert into the wip_operations table will be null,
-- so the previous select statment will not insert row into wip_operation_yields,
-- changed where clause, so that new record will be insert into the wip_operation_yields with jumping operation

        -- The below insert is used for Costing Changes (OP Yield)
l_stat_num := 20;
        INSERT INTO WIP_OPERATION_YIELDS
                (WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                PROGRAM_APPLICATION_ID, PROGRAM_ID,PROGRAM_UPDATE_DATE,
                STATUS, SCRAP_ACCOUNT, EST_SCRAP_ABSORB_ACCOUNT)
        SELECT  WO.WIP_ENTITY_ID, WO.OPERATION_SEQ_NUM, WO.ORGANIZATION_ID,
                WO.LAST_UPDATE_DATE, WO.LAST_UPDATED_BY, WO.CREATION_DATE,
                WO.CREATED_BY, WO.LAST_UPDATE_LOGIN, WO.REQUEST_ID,
                WO.PROGRAM_APPLICATION_ID, WO.PROGRAM_ID, WO.PROGRAM_UPDATE_DATE,
                NULL, BD.SCRAP_ACCOUNT, BD.EST_ABSORPTION_ACCOUNT
        FROM    WIP_OPERATIONS WO,
--      BOM_OPERATION_SEQUENCES BOS, fix bug 1611094
        BOM_DEPARTMENTS BD
       WHERE    WO.WIP_ENTITY_ID = X_Wip_Entity_Id
         AND    WO.OPERATION_SEQ_NUM = X_op_seq_num
         AND    WO.ORGANIZATION_ID = X_Organization_Id
    --   AND    WO.OPERATION_SEQUENCE_ID = BOS.OPERATION_SEQUENCE_ID --bugfix 1611094
         AND    WO.DEPARTMENT_ID = BD.DEPARTMENT_ID;  --bugfix 1611094

EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.create_op_details('||l_stat_num||')'|| substr(SQLERRM,1,200);

        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.create_op_details: other excpn: '|| x_error_msg);

END create_op_details;

--
-- bugfix 2644217: Removed the organization_id join to get an optimal plan
-- ("first row with min/max range scan")
-- With min/max range scan, it only looks one row ahead or one row after .....versus the
-- original plan head to scan all matching rows, sort them and then pick the max or the min.
--
PROCEDURE set_prev_next (
         X_wip_entity_Id        IN      NUMBER,
         X_organization_Id      IN      NUMBER,
         x_error_code           OUT NOCOPY     NUMBER,
         x_error_msg            OUT NOCOPY     VARCHAR2
     ) IS
l_stat_num NUMBER;
BEGIN
l_stat_num := 10;
    UPDATE  WIP_OPERATIONS WO
    SET     WO.PREVIOUS_OPERATION_SEQ_NUM =
                (SELECT MAX(OPERATION_SEQ_NUM)
                   FROM WIP_OPERATIONS
                  WHERE WIP_ENTITY_ID = X_Wip_Entity_Id
                    -- bugfix 2644217: AND ORGANIZATION_ID = X_Organization_Id
                    AND OPERATION_SEQ_NUM < WO.OPERATION_SEQ_NUM),
            WO.NEXT_OPERATION_SEQ_NUM =
                (SELECT MIN(OPERATION_SEQ_NUM)
                   FROM WIP_OPERATIONS
                  WHERE WIP_ENTITY_ID = X_Wip_Entity_Id
                    -- bugfix 2644217: AND ORGANIZATION_ID = X_Organization_Id
                    AND OPERATION_SEQ_NUM > WO.OPERATION_SEQ_NUM)
    WHERE   WO.WIP_ENTITY_ID = X_Wip_Entity_Id
    AND     WO.ORGANIZATION_ID = X_Organization_Id;
EXCEPTION
        WHEN others THEN
                x_error_code := SQLCODE;
                x_error_msg := 'WSMOPRNB.set_prev_next('||l_stat_num||')'|| substr(SQLERRM,1,200);

                -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.set_prev_next: other excpn: '|| x_error_msg);

END set_prev_next;

-- Begin Changes Bug 4614970
-- Procedure set_prev_next has been overloaded, two new parameters introduced from the earlier procedure definition

PROCEDURE set_prev_next (
    X_wip_entity_Id         IN      NUMBER,
    X_organization_Id       IN      NUMBER,
    X_from_op               IN  NUMBER,
    X_to_op                 IN  NUMBER,
    X_op_seq_incr           IN  NUMBER,
    x_error_code            OUT NOCOPY     NUMBER,
    x_error_msg             OUT NOCOPY     VARCHAR2
    ) IS

    l_stat_num NUMBER;

BEGIN

    l_stat_num := 10;


    UPDATE WIP_OPERATIONS WO
    SET WO.PREVIOUS_OPERATION_SEQ_NUM = decode(WO.OPERATION_SEQ_NUM - x_op_seq_incr,0,null,WO.OPERATION_SEQ_NUM - x_op_seq_incr) ,
                                        -- Bug 5336643 Added decode so that null is populated instead of zero
        WO.NEXT_OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM + x_op_seq_incr
    WHERE  WO.WIP_ENTITY_ID = X_Wip_Entity_Id
    AND WO.ORGANIZATION_ID = X_Organization_Id
    AND WO.OPERATION_SEQ_NUM >= x_from_op
    AND WO.OPERATION_SEQ_NUM < x_to_op ;

EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.set_prev_next overloaded ('||l_stat_num||')'|| substr(SQLERRM,1,200);
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.set_prev_next overloaded : other excpn: '|| x_error_msg);

END set_prev_next;

-- End changes Bug 4614970

PROCEDURE get_current_op (
        p_wip_entity_id         IN  NUMBER,
        p_current_op_seq        OUT NOCOPY     NUMBER,
        p_current_op_step       OUT NOCOPY     NUMBER,
        p_next_mand_step        OUT NOCOPY     NUMBER,
        x_error_code            OUT NOCOPY     NUMBER,
        x_error_msg             OUT NOCOPY     VARCHAR2
    ) IS

l_step                  NUMBER;
l_step_code             VARCHAR2(80);
l_op                    NUMBER;
l_std_operation_id      NUMBER;
l_intra_op_flag_value   NUMBER;
l_stat_num              NUMBER;
BEGIN

-- Bugfix 1551170 begin
-- We will first check if the job has been completely scrapped. If so, return with
-- operation_seq_num and intraoperation_step namely SCRAP.


l_stat_num := 5;
   BEGIN
    SELECT  operation_seq_num,
            WIP_CONSTANTS.SCRAP,
            nvl(to_number(STANDARD_OPERATION_ID),0),
            ml.meaning
    INTO    l_op,
            l_step,
            l_std_operation_id,
            l_step_code
    FROM
            mfg_lookups ml,
            wip_operations wo
    WHERE   wip_entity_id = p_wip_entity_id
    AND     quantity_in_queue = 0
    AND     quantity_running = 0
    AND     quantity_waiting_to_move = 0
    AND     quantity_scrapped = quantity_completed
    AND     quantity_completed > 0
    AND     count_point_type <> 3
    AND     ml.lookup_type = 'WIP_INTRAOPERATION_STEP'
    AND     ml.lookup_code = WIP_CONSTANTS.SCRAP;

    p_current_op_seq  := l_op;
    p_current_op_step := l_step;

    return; -- if the above select returns a row, then, the
        -- job was completely scrapped.
   EXCEPTION
        when NO_DATA_FOUND then null;   -- if the above select did not return a row, proceed further..
   END;
-- Bugfix 1551170 end


l_stat_num :=10;
    SELECT  operation_seq_num,
            decode(quantity_in_queue, 0,
                decode(quantity_running, 0, WIP_CONSTANTS.TOMOVE, WIP_CONSTANTS.RUN),
                WIP_CONSTANTS.QUEUE),
            nvl(to_number(STANDARD_OPERATION_ID),0),
                ml.meaning
    INTO    l_op,
            l_step,
            l_std_operation_id,
            l_step_code
    FROM
            mfg_lookups ml,
            wip_operations wo
    WHERE   wip_entity_id = p_wip_entity_id
    AND     (quantity_in_queue <> 0
    OR      quantity_running <> 0
    OR      quantity_waiting_to_move <> 0)
    AND     ml.lookup_type = 'WIP_INTRAOPERATION_STEP'
    AND     ml.lookup_code =
            decode(quantity_in_queue, 0,
                   decode(quantity_running, 0, WIP_CONSTANTS.TOMOVE, WIP_CONSTANTS.RUN),
                       WIP_CONSTANTS.QUEUE);

    p_current_op_seq  := l_op;
    p_current_op_step := l_step;
l_stat_num := 20;
    l_intra_op_flag_value := get_intra_operation_value(l_std_operation_id,
                               x_error_code,
                               x_error_msg);
l_stat_num := 30;
    p_next_mand_step := get_next_mandatory_step(l_step, l_intra_op_flag_value);
EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.get_current_op('||l_stat_num||')'|| substr(SQLERRM,1,200);
END get_current_op;

FUNCTION get_intra_operation_value (
        p_std_op_id    IN      NUMBER,
        x_error_code   OUT NOCOPY     NUMBER,
        x_error_msg    OUT NOCOPY     VARCHAR2
    ) RETURN NUMBER IS

l_queue_flag    NUMBER;
l_run_flag  NUMBER;
l_to_move_flag  NUMBER;
l_stat_num  NUMBER;
l_row_count NUMBER;
-- Logging variables.....
l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPOPRN.get_intra_operation_value';
l_param_tbl                             WSM_Log_PVT.param_tbl_type;
l_error_count                           NUMBER;
l_return_code                           NUMBER;
l_error_msg                             VARCHAR2(4000);
l_stmt_num                              NUMBER := 0;

BEGIN
--begin WSM modification (bug. 1377752) by abedajna, 08/23/00

l_stat_num := 10;

    --***VJ Changed for Performance Upgrade***--
    BEGIN
--MES replacing WSM_OPERATION_DETAILS with BOM_STANDARD_OPERATIONS
/*
        SELECT  QUEUE_MANDATORY_FLAG,
                RUN_MANDATORY_FLAG,
                TO_MOVE_MANDATORY_FLAG
        INTO    l_queue_flag,
                l_run_flag,
                l_to_move_flag
        FROM    WSM_OPERATION_DETAILS
        WHERE   STANDARD_OPERATION_ID = p_std_op_id;
*/
        SELECT  decode(QUEUE_MANDATORY_FLAG, 0, 2, NULL, 2, QUEUE_MANDATORY_FLAG),
                decode(RUN_MANDATORY_FLAG, 0, 2, NULL, 2, RUN_MANDATORY_FLAG),
                decode(TO_MOVE_MANDATORY_FLAG, 0, 2, NULL, 2, TO_MOVE_MANDATORY_FLAG)
        INTO    l_queue_flag,
                l_run_flag,
                l_to_move_flag
        FROM    BOM_STANDARD_OPERATIONS
        WHERE   STANDARD_OPERATION_ID = p_std_op_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        return(1);
    END;

    IF (l_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, '*************************** p_std_op_id '||p_std_op_id||
        ' l_queue_flag '||l_queue_flag);
    END IF;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      l_msg_tokens.delete;
      WSM_log_PVT.logMessage (
        p_module_name     => l_module,
        p_msg_text          => 'After SELECT from BOM_STANDARD_OPERATIONS '||
        ';l_queue_flag '||
        l_queue_flag||
        ';l_run_flag '||
        l_run_flag||
        ';l_to_move_flag '||
        l_to_move_flag,
        p_stmt_num          => l_stmt_num,
        p_msg_tokens        => l_msg_tokens,
        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT,
        p_run_log_level     => l_log_level
      );
    END IF;
    --***VJ End Changes***--

    --***VJ Deleted for Performance Upgrade***--
    -- Replaced by above BEGIN-END block--
    --***   SELECT COUNT(*)
    --***   INTO l_row_count
    --***   FROM    WSM_OPERATION_DETAILS
    --***   WHERE   STANDARD_OPERATION_ID = p_std_op_id;
    --***
    --***   IF l_row_count = 0 THEN
    --***       return(1);
    --***   END IF;
    --***--end WSM modification (bug. 1377752) by abedajna, 08/23/00
    --***
    --***l_stat_num := 20;
    --***   SELECT  QUEUE_MANDATORY_FLAG,
    --***       RUN_MANDATORY_FLAG,
    --***       TO_MOVE_MANDATORY_FLAG
    --***   INTO    l_queue_flag,
    --***       l_run_flag,
    --***       l_to_move_flag
    --***   FROM    WSM_OPERATION_DETAILS
    --***   WHERE   STANDARD_OPERATION_ID = p_std_op_id;
    --***VJ End Deletions***--

    IF l_queue_flag = 2 AND l_run_flag = 2 AND l_to_move_flag = 2 THEN
        return(1);
    ELSIF l_queue_flag = 1 AND l_run_flag = 2 AND l_to_move_flag = 2 THEN
        return(2);
    ELSIF l_queue_flag = 2 AND l_run_flag = 1 AND l_to_move_flag = 2 THEN
        return(3);
    ELSIF l_queue_flag = 1 AND l_run_flag = 1 AND l_to_move_flag = 2 THEN
        return(4);
    ELSIF l_queue_flag = 2 AND l_run_flag = 2 AND l_to_move_flag = 1 THEN
        return(5);
    ELSIF l_queue_flag = 1 AND l_run_flag = 2 AND l_to_move_flag = 1 THEN
        return(6);
    ELSIF l_queue_flag = 2 AND l_run_flag = 1 AND l_to_move_flag = 1 THEN
        return(7);
    ELSIF l_queue_flag = 1 AND l_run_flag = 1 AND l_to_move_flag = 1 THEN
        return(8);
    END IF;
EXCEPTION

    --begin WSM modification (bug. 1377752) by abedajna, 08/23/00
    --  WHEN no_data_found THEN
    --            x_error_code := SQLCODE;
    --            x_error_msg := 'WSMOPRNB.get_intra_operation_value('||l_stat_num||')'|| substr(SQLERRM,1,200);
    --      return(1);
    --end WSM modification (bug. 1377752) by abedajna, 08/23/00
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.get_intra_operation_value('||l_stat_num||')'|| substr(SQLERRM,1,200);

        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.get_intra_operation_value: other excpn: '|| x_error_msg);

END get_intra_operation_value;

FUNCTION get_next_mandatory_step(x_step IN NUMBER, x_flag IN NUMBER)
    RETURN NUMBER IS
BEGIN

    IF x_step = WIP_CONSTANTS.TOMOVE THEN
        return(0);
    ELSIF x_step = WIP_CONSTANTS.RUN and x_flag < 5 THEN
        return(0);
    ELSIF x_step = WIP_CONSTANTS.RUN THEN
        return(WIP_CONSTANTS.TOMOVE);
    ELSIF x_step = WIP_CONSTANTS.QUEUE and x_flag IN (3,4,7,8) THEN
        return(WIP_CONSTANTS.RUN);
    ELSIF x_step = WIP_CONSTANTS.QUEUE and x_flag IN (5,6) THEN
        return(WIP_CONSTANTS.TOMOVE);
    ELSIF x_step = 0 AND x_flag IN (2,4,6,8) THEN
        return(WIP_CONSTANTS.QUEUE);
    ELSIF x_step = 0 AND x_flag IN (3,7) THEN
        return(WIP_CONSTANTS.RUN);
    ELSIF x_step = 0 and x_flag = 5 THEN
        return(WIP_CONSTANTS.TOMOVE);
    ELSE
        return(0);
    END IF;

END get_next_mandatory_step;

PROCEDURE get_sec_inv_loc(
        p_routing_seq_id                IN      NUMBER,
        x_secondary_invetory_name       OUT NOCOPY     VARCHAR2,
        x_secondary_locator             OUT NOCOPY     NUMBER,
        x_error_code                    OUT NOCOPY     NUMBER,
        x_error_msg                     OUT NOCOPY     VARCHAR2
    ) IS

l_end_op_seq_id             NUMBER;
l_secondary_inventory_name  VARCHAR2(10);
l_secondary_locator         NUMBER;
l_stat_num              NUMBER;

BEGIN
    -- CZH.I_OED-1: !!!! IMPORTANT !!!!
    -- when we call find_routing_end, we need to pass routing revision date
    -- I can not find where is this procedure called
    -- If you need to call this function, please let me know

l_stat_num := 10;
    if (l_debug = 'Y') then  -- czh:BUG1995161
           fnd_file.put_line (fnd_file.log, 'WSMPOPRN.get_sec_inv_loc: Calling WSMPUTIL.FIND_ROUTING_END ..');
    end if; -- czh:BUG1995161

    WSMPUTIL.FIND_ROUTING_END(p_routing_seq_id,
            l_end_op_seq_id,
            x_error_code,
            x_error_msg);

l_stat_num := 20;
--MES replacing WSM_OPERATION_DETAILS with BOM_STANDARD_OPERATIONS
/*
    SELECT  SECONDARY_INVENTORY_NAME,
            INVENTORY_LOCATION_ID
    INTO    l_secondary_inventory_name,
            l_secondary_locator
    FROM    WSM_OPERATION_DETAILS WOD,
            BOM_OPERATION_SEQUENCES BOS
    WHERE   WOD.STANDARD_OPERATION_ID = BOS.STANDARD_OPERATION_ID
    AND     BOS.OPERATION_SEQUENCE_ID = l_end_op_seq_id;
*/
    SELECT  DEFAULT_SUBINVENTORY,
            DEFAULT_LOCATOR_ID
    INTO    l_secondary_inventory_name,
            l_secondary_locator
    FROM    BOM_STANDARD_OPERATIONS BSO,
            BOM_OPERATION_SEQUENCES BOS
    WHERE   BSO.STANDARD_OPERATION_ID = BOS.STANDARD_OPERATION_ID
    AND     BOS.OPERATION_SEQUENCE_ID = l_end_op_seq_id;

EXCEPTION
    WHEN others then
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.get_sec_inv_loc('||l_stat_num||')'|| substr(SQLERRM,1,200);

        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.get_sec_inv_loc: other excpn: '|| x_error_msg);

END get_sec_inv_loc;

FUNCTION update_job_name (
    p_wip_entity_id IN  NUMBER,
    p_subinventory  IN  VARCHAR2,
    p_org_id        IN  NUMBER,
    p_txn_type      IN  NUMBER,
    /*BA#1803065*/
    p_dup_job_name  OUT NOCOPY   VARCHAR2,
    /*BA#1803065*/
    x_error_code    OUT NOCOPY NUMBER,
    x_error_msg     OUT NOCOPY VARCHAR2
    ) return VARCHAR2 IS

    -- Added the parameter P_UPDATE_FLAG to the function update_job_name.
    -- The function will update wip_entities with the new job name only
    -- if p_update_flag has the value 'TRUE'.

    l_sep               VARCHAR2(1);
    l_suffix            VARCHAR2(30);
    l_new_name          VARCHAR2(240); -- Changed to 240 from 60--
    l_entity_name       VARCHAR2(240); -- Changed to 240 from 60--
    l_count             NUMBER;
    l_stat_num          NUMBER;
    l_comp_subinv       VARCHAR2(10);
    another_job_exists  EXCEPTION;
    no_sector_subinv    EXCEPTION; -- abb

    -- Bug 1522722: added code to read the new profile WSM_COMPLETE_SEC_LOT_EXTN_LEVEL
    -- Values can be : 1 = "Item"
    --                 2 = "Subinventory"

    x_level         VARCHAR2(30);

    -- Added for 12.1 enhancement
	l_reuse_jobname     NUMBER;


BEGIN

    l_count := 0;

    --  Bug 1522722 Get the job suffix level
    x_level := nvl(FND_PROFILE.value('WSM_COMPLETE_SEC_LOT_EXTN_LEVEL'), '1'); -- default should be "Item"


    l_stat_num := 10;

    --Fix bug #1504009
        IF (p_subinventory IS NULL) THEN
            select completion_subinventory
            into   l_comp_subinv
            from   wip_discrete_jobs
            where  wip_entity_id = p_wip_entity_id
            and    organization_id = p_org_id;      -- as part of bugfix 2062110: added orgn_id

        /* ST bug fix 3256834 : check if l_comp_subinv is null get it using the routing sequence id .... */
        IF (l_comp_subinv IS NULL) THEN
           /* Get the completion subinventory of the routing associated with the job */
           l_stat_num := 15;
           select bor.completion_subinventory
           into   l_comp_subinv
           from   wip_discrete_jobs wdj,BOM_OPERATIONAL_ROUTINGS bor
           where  wdj.wip_entity_id = p_wip_entity_id
           and    wdj.organization_id = p_org_id
           and    wdj.common_routing_sequence_id = bor.routing_sequence_id;

        END IF;
        /* ST bug fix 3256834 : end */
        ELSE
            l_comp_subinv := p_subinventory;
        END IF;
    --End Fix bug #1504009

    select  JOB_COMPLETION_SEPARATOR,nvl(REUSE_JOBNAME,1)
    into    l_sep,l_reuse_jobname
    from    wsm_parameters
    where   organization_id = p_org_id;

    -- The below condition is modified for 12.1 enhancement.
	-- If reuse job name is set to 'yes' then only we need to append sector extension.
    if (p_txn_type = 2 and l_reuse_jobname = 1) then    -- For completions
        if (x_level = '1') then  -- Fix bug 1522722
             BEGIN
                l_stat_num := 20;
                select  l_sep || wse.sector_extension_code
                into    l_suffix
                from    wip_entities we,
                    wsm_sector_extensions wse,
                    wsm_item_extensions wie
                where   we.wip_entity_id = p_wip_entity_id
                and we.primary_item_id = wie.inventory_item_id
                and we.organization_id = wie.organization_id
                and wie.sector_extension_id = wse.sector_extension_id;
             EXCEPTION
                when no_data_found then
                    l_suffix := null;
             END;
        end if;

      -- Fix bug1522722
        IF (l_suffix is null) or (x_level = '2') THEN -- subinventory
l_stat_num := 30;
            -- abb bug 2345650: added the exception block and no-data-found handler.
            BEGIN
                select  l_sep || wse.sector_extension_code
                into    l_suffix
                from    wsm_sector_extensions wse,
                        wsm_subinventory_extensions wsube
                where   wse.sector_extension_id = wsube.sector_extension_id
                and     wsube.secondary_inventory_name = l_comp_subinv -- p_subinventory Fix bug #1504009
                and     wsube.organization_id = p_org_id;
            EXCEPTION
                when no_data_found then
                    raise no_sector_subinv;
            END;
        END IF;

l_stat_num := 40;
        select    wip_entity_name
        into      l_new_name
        from      wip_entities
        where     wip_entity_id = p_wip_entity_id
        and       organization_id = p_org_id;     -- as part of bugfix 2062110 : added orgn_id

        IF l_suffix is null THEN
            return(null);
        END IF;

        while(TRUE)
        LOOP
            l_new_name := l_new_name || l_suffix;

            l_stat_num := 50;
            select  count(*)
            into    l_count
            from    wip_entities
            where   wip_entity_name = l_new_name
            /*BA#2073251*/
            and     organization_id = p_org_id;
            /*EA#2073251*/

            IF l_count = 0 THEN
l_stat_num := 60;
                if (g_update_flag) THEN
                    update  wip_entities
                    set     wip_entity_name = l_new_name
                    where   wip_entity_id = p_wip_entity_id
                    and     organization_id = p_org_id;     -- as part of bugfix 2062110 : added orgn_id
                end if;
                return(l_new_name);
            END IF;
        END LOOP;

        -- couple of situation might occur here.
		-- if reuse job name is set to 'yes' no issues.
		-- if reuse job name is set to 'no' then we need to trim sector extn for jobs completed/cancelled before
		-- this parameter was set. There are no issues for jobs completed/cancelled  after this parameter was set.
        elsif (p_txn_type = 3) then    -- For Assy Returns

l_stat_num := 20;

            select wip_entity_name
            into   l_entity_name
            from   wip_entities
            where  wip_entity_id = p_wip_entity_id
            and    organization_id = p_org_id;

l_stat_num := 30;

            select  substr(l_entity_name,1, decode(instr(l_entity_name,l_sep) -1, -1, length(l_entity_name), instr(l_entity_name, l_sep) -1))
            into    l_new_name
            from    sys.dual;


l_stat_num := 40;
            --bugfix 2820900: moved the assigment to before IF
            p_dup_job_name := l_new_name;                 -- bugfix 1803065

            --
            -- bugfix 2820900: Only when the new name is different from the current name, we will check the existence.
            -- This is important for this fix as there might be existing jobs which are complete/canceled but without sector lot extn.
            --

            if (l_entity_name <> l_new_name) then           -- bugfix 2820900 : added if clause
                select count(*)
                into   l_count
                from   wip_entities
                where  wip_entity_name = l_new_name
                and    organization_id = p_org_id;

                -- p_dup_job_name := l_new_name;      -- bugfix 2820900: moved the assigment above.


                if (l_count > 0) then
                    raise another_job_exists;
                end if;

l_stat_num := 50;

                if (g_update_flag) THEN
                    update wip_entities
                    set    wip_entity_name = l_new_name
                    where  wip_entity_id = p_wip_entity_id
                    and    organization_id = p_org_id;
                end if;
            end if;         -- bugfix 2820900 : added if clause

            return(l_new_name);

         elsif(l_reuse_jobname = 2) then
l_stat_num := 60;
             select wip_entity_name
            into   l_entity_name
            from   wip_entities
            where  wip_entity_id = p_wip_entity_id
            and    organization_id = p_org_id;

          return(l_entity_name);
	end if;

EXCEPTION
        when no_data_found then
            x_error_code := SQLCODE;
            x_error_msg := 'WSMOPRNB.update_job_name('||l_stat_num||'): No Data Found';
            -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, x_error_msg);
            return(-1);

        when another_job_exists then
            FND_MESSAGE.SET_NAME('WSM', 'WSM_DUP_JOB_NAME');
            FND_MESSAGE.SET_TOKEN('JOB_NAME', l_new_name);  -- bugfix 2820900: corrected the token name
            x_error_msg := fnd_message.get;
            x_error_code := -1;
            fnd_file.put_line(fnd_file.log, x_error_msg);
            return(-1);


-- abb bug 2345650: added the exception block and no-data-found handler.
        when no_sector_subinv then
            FND_MESSAGE.SET_NAME('WSM', 'WSM_NO_SECTOR_SUBINV');
            FND_MESSAGE.SET_TOKEN('SUB', l_comp_subinv);
            x_error_msg := fnd_message.get;
            x_error_code := -1;
            fnd_file.put_line(fnd_file.log, x_error_msg);
            return(-1);

        when others then
            x_error_code := SQLCODE;
            x_error_msg := 'WSMOPRNB.update_job_name('||l_stat_num||')'|| substr(SQLERRM,1,200);
            -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, x_error_msg);
            return(-1);

END update_job_name;


-- Bug# 1986051.
-- The following is a cover routine that sets g_update_flag as per the
-- passed value p_update_flag and calls the above function update_job_name

FUNCTION update_job_name (
    p_wip_entity_id     IN  NUMBER,
    p_subinventory      IN  VARCHAR2,
    p_org_id            IN  NUMBER,
    p_txn_type          IN  NUMBER,
        p_update_flag   IN      BOOLEAN,
    /*BA#1803065*/
    p_dup_job_name      OUT NOCOPY   VARCHAR2,
    /*BA#1803065*/
    x_error_code        OUT NOCOPY NUMBER,
    x_error_msg         OUT NOCOPY VARCHAR2
    ) return VARCHAR2 IS

x_ret_val  VARCHAR2(240);

BEGIN
    g_update_flag:=p_update_flag;
    x_ret_val:=update_job_name(p_wip_entity_id,p_subinventory,p_org_id,
    p_txn_type,p_dup_job_name,x_error_code,x_error_msg);

    g_update_flag:=TRUE;  -- Set the default value TRUE
    return(x_ret_val);

END update_job_name;

PROCEDURE update_job_name1 (
    p_wip_entity_id         IN  NUMBER,
    p_org_id                IN  NUMBER,
    p_reentered_job_name    IN OUT NOCOPY   VARCHAR2,
    x_error_code            OUT NOCOPY NUMBER,
    x_error_msg             OUT NOCOPY VARCHAR2
    )  IS

l_stat_num NUMBER;
l_count NUMBER;
another_job_exists exception;

BEGIN

    l_count := 0;
    l_stat_num := 10;

    select count(*)
    into   l_count
    from   wip_entities
    where  wip_entity_name = p_reentered_job_name
    /*BA#2073251*/
    and    organization_id = p_org_id;
    /*EA#2073251*/

    if (l_count > 0) then
        raise another_job_exists;
    end if;

    l_stat_num := 20;

    update  wip_entities
    set     wip_entity_name = p_reentered_job_name
    where   wip_entity_id = p_wip_entity_id
    and     organization_id = p_org_id;

    x_error_code := 0;

EXCEPTION
    when no_data_found then
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.update_job_name1('||l_stat_num||'): No Data Found';
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, x_error_msg);

    when another_job_exists then
        FND_MESSAGE.SET_NAME('WSM', 'WSM_DUP_JOB_NAME');                -- bugfix 2820900: added this
        FND_MESSAGE.SET_TOKEN('JOB_NAME', p_reentered_job_name);        -- bugfix 2820900: corrected the token name
        x_error_msg := fnd_message.get;
        x_error_code := -1;

        --bugfix 2820900: commented
        --x_error_msg := 'WSMOPRNB.update_job_name1('||l_stat_num||'): Another job exists with the name ' || p_reentered_job_name;
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, x_error_msg);

    when others then
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.update_job_name1('||l_stat_num||')'|| substr(SQLERRM,1,200);
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, x_error_msg);

END update_job_name1;
/*EA#1803065*/

-- Bug 2328947
PROCEDURE rollback_before_add_operation IS
    /*bug 4759095: We shall rollback to savepoint after obtaining the lock on wdj so that this lock is
    retained. This is to prevent another user from doing move transactions against the same job. */
    savepoint_not_found          EXCEPTION;
    PRAGMA EXCEPTION_INIT(savepoint_not_found, -1086);
begin
    rollback to AFTER_LOCK_WDJ;
EXCEPTION
    when savepoint_not_found then
        rollback;
end rollback_before_add_operation;

PROCEDURE copy_plan_to_execution(
                  x_error_code          OUT NOCOPY NUMBER
                , x_error_msg           OUT NOCOPY VARCHAR2
                , p_org_id              IN NUMBER
                , p_wip_entity_id       IN NUMBER
                , p_to_job_op_seq_num   IN NUMBER
                , p_to_rtg_op_seq_num   IN NUMBER
                , p_to_op_seq_id        IN NUMBER
                , p_reco_op_flag        IN VARCHAR2
                , p_txn_quantity        IN NUMBER
                , p_txn_date            IN DATE
                , p_user                IN NUMBER
                , p_login               IN NUMBER
                , p_request_id          IN NUMBER
                , p_program_application_id IN NUMBER
                , p_program_id          IN NUMBER
                , p_dup_val_ignore      IN VARCHAR2
                , p_start_quantity      IN NUMBER
                )
IS
    l_stmt_num          NUMBER;
    l_wor_count         NUMBER := 0;
    l_wor_reco_res      NUMBER := 0;
    l_recommended_op    VARCHAR2(1);
    l_est_scrap_acc     NUMBER;
    l_job_type          NUMBER;
    l_dept_id           NUMBER;
    l_scrap_account     NUMBER;
    l_est_absorption_account NUMBER;
    p_commit            NUMBER := 1;
    e_proc_error        EXCEPTION;
    l_phantom_exists    NUMBER;

    -- Logging variables.....
    l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
    l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPOPRN.copy_plan_to_execution';
    l_param_tbl                             WSM_Log_PVT.param_tbl_type;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             number;
    l_msg_data                              varchar2(4000);
BEGIN
    l_stmt_num := 10;
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: p_org_id '||p_org_id||
                ' p_wip_entity_id '||p_wip_entity_id||
                ' p_to_job_op_seq_num '||p_to_job_op_seq_num||
                ' p_to_rtg_op_seq_num '||p_to_rtg_op_seq_num||
                ' p_to_op_seq_id '||p_to_op_seq_id||
                ' p_reco_op_flag '||p_reco_op_flag||
                ' p_txn_quantity '||p_txn_quantity||
                ' p_txn_date '||p_txn_date||
                ' p_user '||p_user||
                ' p_login '||p_login||
                ' p_request_id '||p_request_id||
                ' p_program_application_id '||p_program_application_id||
                ' p_program_id '||p_program_id);
    end if;

--move enh? ask vj abt recommended col in WO
--bug 3162358 115.78 added CUMULATIVE_SCRAP_QUANTITY
--bug 3370199 added wsm_op_seq_num
    INSERT INTO WIP_OPERATIONS
            (WIP_ENTITY_ID,
            OPERATION_SEQ_NUM,
            ORGANIZATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            OPERATION_SEQUENCE_ID,
            STANDARD_OPERATION_ID,
            DEPARTMENT_ID,
            DESCRIPTION,
            SCHEDULED_QUANTITY,
            QUANTITY_IN_QUEUE,
            QUANTITY_RUNNING,
            QUANTITY_WAITING_TO_MOVE,
            QUANTITY_REJECTED,
            QUANTITY_SCRAPPED,
            QUANTITY_COMPLETED,
            FIRST_UNIT_START_DATE,
            FIRST_UNIT_COMPLETION_DATE,
            LAST_UNIT_START_DATE,
            LAST_UNIT_COMPLETION_DATE,
            PREVIOUS_OPERATION_SEQ_NUM,
            NEXT_OPERATION_SEQ_NUM,
            COUNT_POINT_TYPE,
            BACKFLUSH_FLAG,
            MINIMUM_TRANSFER_QUANTITY,
            DATE_LAST_MOVED,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            OPERATION_YIELD,
            OPERATION_YIELD_ENABLED,
            RECOMMENDED,
            CUMULATIVE_SCRAP_QUANTITY,
            WSM_OP_SEQ_NUM,
            WSM_COSTED_QUANTITY_COMPLETED,
            LOWEST_ACCEPTABLE_YIELD)
    SELECT  p_wip_entity_id,
            p_to_job_op_seq_num,
            p_org_id,
            SYSDATE,
            p_user,
            SYSDATE,
            p_user,
            p_login,
            DECODE(p_request_id, 0, '', p_request_id),
            DECODE(p_program_application_id, 0, '', p_program_application_id),
            DECODE(p_commit, 1, p_program_id, -999),
            DECODE(p_program_id, 0, '', SYSDATE),
            WCO.OPERATION_SEQUENCE_ID,
            WCO.STANDARD_OPERATION_ID,
            WCO.DEPARTMENT_ID,
            WCO.OPERATION_DESCRIPTION,
        /*bug 3686872 added nvl(WCO.RECO_SCHEDULED_QUANTITY to the code below removed p_txn_quantity*/
            --ROUND(nvl(p_txn_quantity, 0), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
        ROUND(nvl(WCO.RECO_SCHEDULED_QUANTITY, 0), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
            0, 0, 0, 0, 0, 0,
            decode(recommended, 'Y', nvl(RECO_START_DATE, p_txn_date), p_txn_date), --move_enh? populate the reco dates for planned op or ...
            decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, p_txn_date), p_txn_date),
            decode(recommended, 'Y', nvl(RECO_START_DATE, p_txn_date), p_txn_date),
            decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, p_txn_date), p_txn_date),
            0, 0,
            WCO.COUNT_POINT_TYPE,
            WCO.BACKFLUSH_FLAG,
            NVL(WCO.MINIMUM_TRANSFER_QUANTITY, 0),
            '',
            WCO.ATTRIBUTE_CATEGORY,
            WCO.ATTRIBUTE1,
            WCO.ATTRIBUTE2,
            WCO.ATTRIBUTE3,
            WCO.ATTRIBUTE4,
            WCO.ATTRIBUTE5,
            WCO.ATTRIBUTE6,
            WCO.ATTRIBUTE7,
            WCO.ATTRIBUTE8,
            WCO.ATTRIBUTE9,
            WCO.ATTRIBUTE10,
            WCO.ATTRIBUTE11,
            WCO.ATTRIBUTE12,
            WCO.ATTRIBUTE13,
            WCO.ATTRIBUTE14,
            WCO.ATTRIBUTE15,
            WCO.YIELD,
            to_char(WCO.OPERATION_YIELD_ENABLED),
            nvl(RECOMMENDED, 'N'),
            WDJ.QUANTITY_SCRAPPED,
            WCO.operation_seq_num,
            0,
            WCO.LOWEST_ACCEPTABLE_YIELD
    FROM    WSM_COPY_OPERATIONS WCO,
            WIP_DISCRETE_JOBS WDJ
    WHERE   WCO.wip_entity_id=p_wip_entity_id
    AND     WCO.organization_id=p_org_id
    AND     WCO.operation_seq_num = p_to_rtg_op_seq_num
    AND     WDJ.organization_id = WCO.organization_id
    AND     WDJ.wip_entity_id = WCO.wip_entity_id;

    --bugfix 2026218
    --copy attachment from operations document attachment defined in the network routing form.
    IF SQL%ROWCOUNT > 0 THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                X_FROM_ENTITY_NAME => 'BOM_OPERATION_SEQUENCES',
                X_FROM_PK1_VALUE   => to_char(p_to_op_seq_id),
                X_TO_ENTITY_NAME   => 'WSM_LOT_BASED_OPERATIONS',
                X_TO_PK1_VALUE   => to_char(p_wip_entity_id),
                X_TO_PK2_VALUE   => to_char(p_to_job_op_seq_num),
                X_TO_PK3_VALUE   => to_char(p_org_id),
                X_CREATED_BY     => p_user,
                X_LAST_UPDATE_LOGIN => p_login,
                X_PROGRAM_APPLICATION_ID => p_program_application_id,
                X_PROGRAM_ID => p_program_id,
                X_REQUEST_ID => p_request_id);

        if (l_debug = 'Y') then -- czh:BUG1995161
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted ' ||sql%rowcount||' records in WO.');
        end if; -- czh:BUG1995161
    ELSE
        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||sql%rowcount||' records in WO.');
        end if;
        x_error_msg := 'WSMOPRNB.('||l_stmt_num||')'|| 'no rows in WO';
        x_error_code := -1;
        raise e_proc_error;
    END IF;

    l_stmt_num := 20;
/******
Bug 3571019 - Get SCRAP_ACCOUNT, EST_SCRAP_ABSORB_ACCOUNT from WCO instead of BD
    INSERT INTO WIP_OPERATION_YIELDS
            (WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
            CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
            PROGRAM_APPLICATION_ID, PROGRAM_ID,PROGRAM_UPDATE_DATE,
            STATUS, SCRAP_ACCOUNT, EST_SCRAP_ABSORB_ACCOUNT)
    SELECT  WO.WIP_ENTITY_ID, WO.OPERATION_SEQ_NUM, WO.ORGANIZATION_ID,
            SYSDATE,
            p_user,
            SYSDATE,
            p_user,
            p_login,
            DECODE(p_request_id, 0, '', p_request_id),
            DECODE(p_program_application_id, 0, '', p_program_application_id),
            DECODE(p_commit, 1, p_program_id, -999),
            DECODE(p_program_id, 0, '', SYSDATE),
            NULL, BD.SCRAP_ACCOUNT, BD.EST_ABSORPTION_ACCOUNT
    FROM    WIP_OPERATIONS WO,
            BOM_DEPARTMENTS BD
    WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
     AND    WO.OPERATION_SEQ_NUM = p_to_job_op_seq_num
     AND    WO.ORGANIZATION_ID = p_org_id
     AND    WO.DEPARTMENT_ID = BD.DEPARTMENT_ID;  --bugfix 1611094
*******/

     INSERT INTO WIP_OPERATION_YIELDS
             (WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
             CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
             PROGRAM_APPLICATION_ID, PROGRAM_ID,PROGRAM_UPDATE_DATE,
             STATUS, SCRAP_ACCOUNT, EST_SCRAP_ABSORB_ACCOUNT)
     SELECT  WO.WIP_ENTITY_ID, WO.OPERATION_SEQ_NUM, WO.ORGANIZATION_ID,
             SYSDATE,
             p_user,
             SYSDATE,
             p_user,
             p_login,
             DECODE(p_request_id, 0, '', p_request_id),
             DECODE(p_program_application_id, 0, '', p_program_application_id),
             DECODE(p_commit, 1, p_program_id, -999),
             DECODE(p_program_id, 0, '', SYSDATE),
             NULL, WCO.SCRAP_ACCOUNT, WCO.EST_ABSORPTION_ACCOUNT
     FROM    WIP_OPERATIONS WO,
             WSM_COPY_OPERATIONS WCO
     WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
      AND    WO.OPERATION_SEQ_NUM = p_to_job_op_seq_num
      AND    WO.ORGANIZATION_ID = p_org_id
      AND    WCO.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
      AND   WCO.OPERATION_SEQ_NUM = WO.WSM_OP_SEQ_NUM;


    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||sql%rowcount||' records in WOY.');
    end if;

l_stmt_num := 30;
    --move enh?
    BEGIN
--commenting out following sql after code review of bug 3587239
        /*********
        SELECT  1
        INTO    l_phantom_exists
        FROM    WSM_COPY_REQUIREMENT_OPS
        WHERE   EXISTS (SELECT  null
                FROM    WSM_COPY_REQUIREMENT_OPS WCRO
                WHERE   WCRO.WIP_ENTITY_ID = p_wip_entity_id
                AND     WCRO.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
                AND WCRO.recommended='Y');
        *********/
--move enh merging may be needed because of phantoms and component substitution
--adding following sql after code review of bug 3587239
        SELECT  1
        INTO    l_phantom_exists
        FROM    WSM_COPY_REQUIREMENT_OPS WCRO
        WHERE   WCRO.WIP_ENTITY_ID = p_wip_entity_id
                AND WCRO.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
                AND WCRO.recommended='Y'
                AND WCRO.source_phantom_id <> -1;
    EXCEPTION
        WHEN no_data_found THEN
            l_phantom_exists := 0;

        WHEN too_many_rows THEN
            l_phantom_exists := 1;
    END;

    IF (l_debug='Y') THEN
        fnd_file.put_line(fnd_file.log, 'WSMOPRNB.add_operation' ||'(stmt_num='||l_stmt_num||') :
        l_phantom_exists '||l_phantom_exists);
    END IF;

    l_stmt_num := 40;

    IF (l_phantom_exists=1) THEN
        DECLARE

            CURSOR c_phantoms IS
                SELECT  WCRO.COMPONENT_ITEM_ID,
                        WCRO.organization_id,
                        WCRO.wip_entity_id,
                        WCRO.COMPONENT_SEQUENCE_ID,
                        WCRO.WIP_SUPPLY_TYPE,
                        decode(WCRO.recommended, 'Y', Nvl(WCRO.reco_date_required, p_txn_date), p_txn_date),
--move enh 115.77 component yield no longer factored in
/*                        round((WCRO.quantity_per_assembly/decode(WCRO.COMPONENT_YIELD_FACTOR,
                                                           0, 1, WCRO.COMPONENT_YIELD_FACTOR)), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION)*p_txn_quantity,
                        round((WCRO.quantity_per_assembly/decode(WCRO.COMPONENT_YIELD_FACTOR,
                                                           0, 1, WCRO.COMPONENT_YIELD_FACTOR)), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
*/
--bug 3587239 Round the required quantity to 6 places
                        WCRO.basis_type,     --LBM enh
--Bug 5236684:Component yield factor should include the yield of the source phantom also.
                        decode(nvl(wcro.basis_type,1),1,nvl(wcro1.component_yield_factor,1),1)*wcro.component_yield_factor,   --LBM enh
--component shrinkage
--                        ROUND((WCRO.quantity_per_assembly/WCRO.component_yield_factor)
                        ROUND((WCRO.quantity_per_assembly)
                              *decode(wcro.basis_type, 2, 1, p_txn_quantity),  WSMPCNST.NUMBER_OF_DECIMALS), --LBM enh
--component shrinkage
--                        WCRO.quantity_per_assembly,
--Bug 5236684:Bill_quantity_per_assembly should include the Bill_quantity_per_assembly of source phantom also.
                        decode(nvl(wcro.basis_type,1),1,nvl(WCRO1.bill_quantity_per_assembly,1),1)*WCRO.bill_quantity_per_assembly,
                        WCRO.supply_subinventory,
                        WCRO.supply_locator_id,
                        decode(WCRO.wip_supply_type,
                            5, 2,
                            decode(sign(WCRO.quantity_per_assembly),
                                -1, 2,
                                1)) mrp_net_flag,
                        WCRO.component_remarks,
                        WCRO.attribute_category,
                        WCRO.attribute1,
                        WCRO.attribute2,
                        WCRO.attribute3,
                        WCRO.attribute4,
                        WCRO.attribute5,
                        WCRO.attribute6,
                        WCRO.attribute7,
                        WCRO.attribute8,
                        WCRO.attribute9,
                        WCRO.attribute10,
                        WCRO.attribute11,
                        WCRO.attribute12,
                        WCRO.attribute13,
                        WCRO.attribute14,
                        WCRO.attribute15,
                        MSI.segment1,
                        MSI.segment2,
                        MSI.segment3,
                        MSI.segment4,
                        MSI.segment5,
                        MSI.segment6,
                        MSI.segment7,
                        MSI.segment8,
                        MSI.segment9,
                        MSI.segment10,
                        MSI.segment11,
                        MSI.segment12,
                        MSI.segment13,
                        MSI.segment14,
                        MSI.segment15,
                        MSI.segment16,
                        MSI.segment17,
                        MSI.segment18,
                        MSI.segment19,
                        MSI.segment20,
                        WCRO.department_id
                FROM    WSM_COPY_REQUIREMENT_OPS WCRO,
                        WSM_COPY_REQUIREMENT_OPS WCRO1,--Added for bug 5236684
                        MTL_SYSTEM_ITEMS MSI
                WHERE   WCRO.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
                AND     WCRO.WIP_ENTITY_ID= p_wip_entity_id
                AND     MSI.inventory_item_id = WCRO.component_item_id
                AND     MSI.organization_id = WCRO.organization_id
                AND     WCRO.RECOMMENDED='Y'
                --Added for bug 5236684
                AND     WCRO.WIP_ENTITY_ID = WCRO1.WIP_ENTITY_ID(+)
		AND     WCRO1.OPERATION_SEQ_NUM(+)= -1*p_to_rtg_op_seq_num
		AND     WCRO.source_phantom_id = WCRO1.component_item_id(+)
                ORDER BY WCRO.component_item_id, WCRO.wip_supply_type desc;

            type t_inventory_item_id is table of WIP_REQUIREMENT_OPERATIONS.inventory_item_id%type index by binary_integer;
            type t_organization_id is table of WIP_REQUIREMENT_OPERATIONS.organization_id%type index by binary_integer;
            type t_wip_entity_id is table of WIP_REQUIREMENT_OPERATIONS.wip_entity_id%type index by binary_integer;
            type t_component_sequence_id is table of WIP_REQUIREMENT_OPERATIONS.component_sequence_id%type index by binary_integer;
            type t_wip_supply_type is table of WIP_REQUIREMENT_OPERATIONS.wip_supply_type%type index by binary_integer;
            type t_date_required is table of WIP_REQUIREMENT_OPERATIONS.date_required%type index by binary_integer;
            type t_basis_type is table of WIP_REQUIREMENT_OPERATIONS.basis_type%type index by binary_integer;  --LBM enh
            type t_component_yield_factor is table of WIP_REQUIREMENT_OPERATIONS.component_yield_factor%type index by binary_integer;  --LBM enh
            type t_required_quantity is table of WIP_REQUIREMENT_OPERATIONS.required_quantity%type index by binary_integer;
            type t_quantity_per_assembly is table of WIP_REQUIREMENT_OPERATIONS.quantity_per_assembly%type index by binary_integer;
            type t_supply_subinventory is table of WIP_REQUIREMENT_OPERATIONS.supply_subinventory%type index by binary_integer;
            type t_supply_locator_id is table of WIP_REQUIREMENT_OPERATIONS.supply_locator_id%type index by binary_integer;
            type t_mrp_net_flag is table of WIP_REQUIREMENT_OPERATIONS.mrp_net_flag%type index by binary_integer;
            type t_comments is table of WIP_REQUIREMENT_OPERATIONS.comments%type index by binary_integer;
            type t_attribute_category is table of WIP_REQUIREMENT_OPERATIONS.attribute_category%type index by binary_integer;
            type t_attribute1 is table of WIP_REQUIREMENT_OPERATIONS.attribute1%type index by binary_integer;
            type t_attribute2 is table of WIP_REQUIREMENT_OPERATIONS.attribute2%type index by binary_integer;
            type t_attribute3 is table of WIP_REQUIREMENT_OPERATIONS.attribute3%type index by binary_integer;
            type t_attribute4 is table of WIP_REQUIREMENT_OPERATIONS.attribute4%type index by binary_integer;
            type t_attribute5 is table of WIP_REQUIREMENT_OPERATIONS.attribute5%type index by binary_integer;
            type t_attribute6 is table of WIP_REQUIREMENT_OPERATIONS.attribute6%type index by binary_integer;
            type t_attribute7 is table of WIP_REQUIREMENT_OPERATIONS.attribute7%type index by binary_integer;
            type t_attribute8 is table of WIP_REQUIREMENT_OPERATIONS.attribute8%type index by binary_integer;
            type t_attribute9 is table of WIP_REQUIREMENT_OPERATIONS.attribute9%type index by binary_integer;
            type t_attribute10 is table of WIP_REQUIREMENT_OPERATIONS.attribute10%type index by binary_integer;
            type t_attribute11 is table of WIP_REQUIREMENT_OPERATIONS.attribute11%type index by binary_integer;
            type t_attribute12 is table of WIP_REQUIREMENT_OPERATIONS.attribute12%type index by binary_integer;
            type t_attribute13 is table of WIP_REQUIREMENT_OPERATIONS.attribute13%type index by binary_integer;
            type t_attribute14 is table of WIP_REQUIREMENT_OPERATIONS.attribute14%type index by binary_integer;
            type t_attribute15 is table of WIP_REQUIREMENT_OPERATIONS.attribute15%type index by binary_integer;
            type t_segment1 is table of WIP_REQUIREMENT_OPERATIONS.segment1%type index by binary_integer;
            type t_segment2 is table of WIP_REQUIREMENT_OPERATIONS.segment2%type index by binary_integer;
            type t_segment3 is table of WIP_REQUIREMENT_OPERATIONS.segment3%type index by binary_integer;
            type t_segment4 is table of WIP_REQUIREMENT_OPERATIONS.segment4%type index by binary_integer;
            type t_segment5 is table of WIP_REQUIREMENT_OPERATIONS.segment5%type index by binary_integer;
            type t_segment6 is table of WIP_REQUIREMENT_OPERATIONS.segment6%type index by binary_integer;
            type t_segment7 is table of WIP_REQUIREMENT_OPERATIONS.segment7%type index by binary_integer;
            type t_segment8 is table of WIP_REQUIREMENT_OPERATIONS.segment8%type index by binary_integer;
            type t_segment9 is table of WIP_REQUIREMENT_OPERATIONS.segment9%type index by binary_integer;
            type t_segment10 is table of WIP_REQUIREMENT_OPERATIONS.segment10%type index by binary_integer;
            type t_segment11 is table of WIP_REQUIREMENT_OPERATIONS.segment11%type index by binary_integer;
            type t_segment12 is table of WIP_REQUIREMENT_OPERATIONS.segment12%type index by binary_integer;
            type t_segment13 is table of WIP_REQUIREMENT_OPERATIONS.segment13%type index by binary_integer;
            type t_segment14 is table of WIP_REQUIREMENT_OPERATIONS.segment14%type index by binary_integer;
            type t_segment15 is table of WIP_REQUIREMENT_OPERATIONS.segment15%type index by binary_integer;
            type t_segment16 is table of WIP_REQUIREMENT_OPERATIONS.segment16%type index by binary_integer;
            type t_segment17 is table of WIP_REQUIREMENT_OPERATIONS.segment17%type index by binary_integer;
            type t_segment18 is table of WIP_REQUIREMENT_OPERATIONS.segment18%type index by binary_integer;
            type t_segment19 is table of WIP_REQUIREMENT_OPERATIONS.segment19%type index by binary_integer;
            type t_segment20 is table of WIP_REQUIREMENT_OPERATIONS.segment20%type index by binary_integer;
            type t_department_id is table of WIP_REQUIREMENT_OPERATIONS.department_id%type index by binary_integer;

            v_inventory_item_id t_inventory_item_id;
            v_organization_id t_organization_id;
            v_wip_entity_id t_wip_entity_id;
            v_component_sequence_id t_component_sequence_id;
            v_wip_supply_type t_wip_supply_type;
            v_date_required t_date_required;
            v_basis_type t_basis_type; --LBM enh
            v_component_yield_factor t_component_yield_factor; --LBM enh
            v_required_quantity t_required_quantity;
            v_quantity_per_assembly t_quantity_per_assembly;
            v_supply_subinventory t_supply_subinventory;
            v_supply_locator_id t_supply_locator_id;
            v_mrp_net_flag t_mrp_net_flag;
            v_comments t_comments;
            v_attribute_category t_attribute_category;
            v_attribute1 t_attribute1;
            v_attribute2 t_attribute2;
            v_attribute3 t_attribute3;
            v_attribute4 t_attribute4;
            v_attribute5 t_attribute5;
            v_attribute6 t_attribute6;
            v_attribute7 t_attribute7;
            v_attribute8 t_attribute8;
            v_attribute9 t_attribute9;
            v_attribute10 t_attribute10;
            v_attribute11 t_attribute11;
            v_attribute12 t_attribute12;
            v_attribute13 t_attribute13;
            v_attribute14 t_attribute14;
            v_attribute15 t_attribute15;
            v_segment1 t_segment1;
            v_segment2 t_segment2;
            v_segment3 t_segment3;
            v_segment4 t_segment4;
            v_segment5 t_segment5;
            v_segment6 t_segment6;
            v_segment7 t_segment7;
            v_segment8 t_segment8;
            v_segment9 t_segment9;
            v_segment10 t_segment10;
            v_segment11 t_segment11;
            v_segment12 t_segment12;
            v_segment13 t_segment13;
            v_segment14 t_segment14;
            v_segment15 t_segment15;
            v_segment16 t_segment16;
            v_segment17 t_segment17;
            v_segment18 t_segment18;
            v_segment19 t_segment19;
            v_segment20 t_segment20;
            v_department_id t_department_id;

            l_no_of_rows    NUMBER;
            i               NUMBER := 1;
            j               NUMBER;
        BEGIN
            l_stmt_num := 50;
            OPEN c_phantoms;
            --bulk fetch records into PL/SQL tables
            fetch c_phantoms bulk collect into
                v_inventory_item_id
                , v_organization_id
                , v_wip_entity_id
                , v_component_sequence_id
                , v_wip_supply_type
                , v_date_required
                , v_basis_type    --LBM enh
                , v_component_yield_factor  --LBM enh
                , v_required_quantity
                , v_quantity_per_assembly
                , v_supply_subinventory
                , v_supply_locator_id
                , v_mrp_net_flag
                , v_comments
                , v_attribute_category
                , v_attribute1
                , v_attribute2
                , v_attribute3
                , v_attribute4
                , v_attribute5
                , v_attribute6
                , v_attribute7
                , v_attribute8
                , v_attribute9
                , v_attribute10
                , v_attribute11
                , v_attribute12
                , v_attribute13
                , v_attribute14
                , v_attribute15
                , v_segment1
                , v_segment2
                , v_segment3
                , v_segment4
                , v_segment5
                , v_segment6
                , v_segment7
                , v_segment8
                , v_segment9
                , v_segment10
                , v_segment11
                , v_segment12
                , v_segment13
                , v_segment14
                , v_segment15
                , v_segment16
                , v_segment17
                , v_segment18
                , v_segment19
                , v_segment20
                , v_department_id;

                IF (l_debug = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'count '||v_inventory_item_id.count);
                END IF;

            LOOP
                l_stmt_num := 60;

                IF v_inventory_item_id.exists(i+1) THEN
                    IF (v_inventory_item_id(i)=v_inventory_item_id(i+1)) THEN
                        v_required_quantity(i+1) := v_required_quantity(i+1) + v_required_quantity(i);
                        v_quantity_per_assembly(i+1) := v_quantity_per_assembly(i+1) + v_quantity_per_assembly(i);
                        v_basis_type.delete(i);     --LBM enh
                        v_component_yield_factor.delete(i); --LBM enh
                        v_inventory_item_id.delete(i);
                        v_organization_id.delete(i);
                        v_wip_entity_id.delete(i);
                        v_component_sequence_id.delete(i);
                        v_wip_supply_type.delete(i);
                        v_date_required.delete(i);
                        v_required_quantity.delete(i);
                        v_quantity_per_assembly.delete(i);
                        v_supply_subinventory.delete(i);
                        v_supply_locator_id.delete(i);
                        v_mrp_net_flag.delete(i);
                        v_comments.delete(i);
                        v_attribute_category.delete(i);
                        v_attribute1.delete(i);
                        v_attribute2.delete(i);
                        v_attribute3.delete(i);
                        v_attribute4.delete(i);
                        v_attribute5.delete(i);
                        v_attribute6.delete(i);
                        v_attribute7.delete(i);
                        v_attribute8.delete(i);
                        v_attribute9.delete(i);
                        v_attribute10.delete(i);
                        v_attribute11.delete(i);
                        v_attribute12.delete(i);
                        v_attribute13.delete(i);
                        v_attribute14.delete(i);
                        v_attribute15.delete(i);
                        v_segment1.delete(i);
                        v_segment2.delete(i);
                        v_segment3.delete(i);
                        v_segment4.delete(i);
                        v_segment5.delete(i);
                        v_segment6.delete(i);
                        v_segment7.delete(i);
                        v_segment8.delete(i);
                        v_segment9.delete(i);
                        v_segment10.delete(i);
                        v_segment11.delete(i);
                        v_segment12.delete(i);
                        v_segment13.delete(i);
                        v_segment14.delete(i);
                        v_segment15.delete(i);
                        v_segment16.delete(i);
                        v_segment17.delete(i);
                        v_segment18.delete(i);
                        v_segment19.delete(i);
                        v_segment20.delete(i);
                        v_department_id.delete(i);

                    END IF;
                    i := i+1;
                ELSE
                    EXIT;
                END IF;
            END LOOP;

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'count after consolidation'||v_inventory_item_id.count);
            END IF;

            l_no_of_rows := v_inventory_item_id.last;
            j := l_no_of_rows + 1;
            FOR i in 1..l_no_of_rows LOOP
                IF v_inventory_item_id.exists(i) THEN
                    v_inventory_item_id(j) := v_inventory_item_id(i);
                    v_organization_id(j) := v_organization_id(i);
                    v_wip_entity_id(j) := v_wip_entity_id(i);
                    v_component_sequence_id(j) := v_component_sequence_id(i);
                    v_wip_supply_type(j) := v_wip_supply_type(i);
                    v_date_required(j) := v_date_required(i);
                    v_basis_type(j) := v_basis_type(i);   --LBM enh
                    v_component_yield_factor(j) := v_component_yield_factor(i);  --LBM enh
                    v_required_quantity(j) := v_required_quantity(i);
                    v_quantity_per_assembly(j) := v_quantity_per_assembly(i);
                    v_supply_subinventory(j) := v_supply_subinventory(i);
                    v_supply_locator_id(j) := v_supply_locator_id(i);
                    v_mrp_net_flag(j) := v_mrp_net_flag(i);
                    v_comments(j) := v_comments(i);
                    v_attribute_category(j) := v_attribute_category(i);
                    v_attribute1(j) := v_attribute1(i);
                    v_attribute2(j) := v_attribute2(i);
                    v_attribute3(j) := v_attribute3(i);
                    v_attribute4(j) := v_attribute4(i);
                    v_attribute5(j) := v_attribute5(i);
                    v_attribute6(j) := v_attribute6(i);
                    v_attribute7(j) := v_attribute7(i);
                    v_attribute8(j) := v_attribute8(i);
                    v_attribute9(j) := v_attribute9(i);
                    v_attribute10(j) := v_attribute10(i);
                    v_attribute11(j) := v_attribute11(i);
                    v_attribute12(j) := v_attribute12(i);
                    v_attribute13(j) := v_attribute13(i);
                    v_attribute14(j) := v_attribute14(i);
                    v_attribute15(j) := v_attribute15(i);
                    v_segment1(j) := v_segment1(i);
                    v_segment2(j) := v_segment2(i);
                    v_segment3(j) := v_segment3(i);
                    v_segment4(j) := v_segment4(i);
                    v_segment5(j) := v_segment5(i);
                    v_segment6(j) := v_segment6(i);
                    v_segment7(j) := v_segment7(i);
                    v_segment8(j) := v_segment8(i);
                    v_segment9(j) := v_segment9(i);
                    v_segment10(j) := v_segment10(i);
                    v_segment11(j) := v_segment11(i);
                    v_segment12(j) := v_segment12(i);
                    v_segment13(j) := v_segment13(i);
                    v_segment14(j) := v_segment14(i);
                    v_segment15(j) := v_segment15(i);
                    v_segment16(j) := v_segment16(i);
                    v_segment17(j) := v_segment17(i);
                    v_segment18(j) := v_segment18(i);
                    v_segment19(j) := v_segment19(i);
                    v_segment20(j) := v_segment20(i);
                    v_department_id(j) := v_department_id(i);

                    j := j+1;
                END IF;
            END LOOP;

            l_stmt_num := 70;
            FORALL i in (l_no_of_rows + 1)..(j-1)
--move enh changed released quantity to start_qty*qpa on 21 Oct 03
                INSERT INTO WIP_REQUIREMENT_OPERATIONS
                            (inventory_item_id,
                            organization_id,
                            wip_entity_id,
                            operation_seq_num,
                            repetitive_schedule_id,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            component_sequence_id,
                            wip_supply_type,
                            date_required,
                            basis_type,   --LBM enh
                            required_quantity,
                            quantity_issued,
                            quantity_per_assembly,
                            supply_subinventory,
                            supply_locator_id,
                            mrp_net_flag,
                            comments,
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
                            segment1,
                            segment2,
                            segment3,
                            segment4,
                            segment5,
                            segment6,
                            segment7,
                            segment8,
                            segment9,
                            segment10,
                            segment11,
                            segment12,
                            segment13,
                            segment14,
                            segment15,
                            segment16,
                            segment17,
                            segment18,
                            segment19,
                            segment20,
                            department_id,
                            released_quantity,
                            component_yield_factor) --component shrinkage
                    VALUES (v_inventory_item_id(i)
                            , v_organization_id(i)
                            , v_wip_entity_id(i)
                            , p_to_job_op_seq_num
                            , NULL,
                            SYSDATE,
                            p_user,
                            SYSDATE,
                            p_user,
                            p_login
                            , v_component_sequence_id(i)
                            , v_wip_supply_type(i)
                            , v_date_required(i)
                            , v_basis_type(i)    --LBM enh
                            , v_required_quantity(i)
                            , 0
                            , v_quantity_per_assembly(i)
                            , v_supply_subinventory(i)
                            , v_supply_locator_id(i)
                            , v_mrp_net_flag(i)
                            , v_comments(i)
                            , v_attribute_category(i)
                            , v_attribute1(i)
                            , v_attribute2(i)
                            , v_attribute3(i)
                            , v_attribute4(i)
                            , v_attribute5(i)
                            , v_attribute6(i)
                            , v_attribute7(i)
                            , v_attribute8(i)
                            , v_attribute9(i)
                            , v_attribute10(i)
                            , v_attribute11(i)
                            , v_attribute12(i)
                            , v_attribute13(i)
                            , v_attribute14(i)
                            , v_attribute15(i)
                            , v_segment1(i)
                            , v_segment2(i)
                            , v_segment3(i)
                            , v_segment4(i)
                            , v_segment5(i)
                            , v_segment6(i)
                            , v_segment7(i)
                            , v_segment8(i)
                            , v_segment9(i)
                            , v_segment10(i)
                            , v_segment11(i)
                            , v_segment12(i)
                            , v_segment13(i)
                            , v_segment14(i)
                            , v_segment15(i)
                            , v_segment16(i)
                            , v_segment17(i)
                            , v_segment18(i)
                            , v_segment19(i)
                            , v_segment20(i)
                            , v_department_id(i)
--bug 3587239 Round the released quantity to 6 places
                            , ROUND( decode(v_basis_type(i), 2, 1, p_start_quantity)
                               *(v_quantity_per_assembly(i)/v_component_yield_factor(i)), WSMPCNST.NUMBER_OF_DECIMALS)  --LBM enh
                            , v_component_yield_factor(i));
            END;
        ELSE

            INSERT INTO WIP_REQUIREMENT_OPERATIONS
                    (inventory_item_id,
                    organization_id,
                    wip_entity_id,
                    operation_seq_num,
                    repetitive_schedule_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    component_sequence_id,
                    wip_supply_type,
                    date_required,
                    basis_type,       --LBM enh
                    required_quantity,
                    quantity_issued,
                    quantity_per_assembly,
                    supply_subinventory,
                    supply_locator_id,
                    mrp_net_flag,
                    comments,
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
                    segment1,
                    segment2,
                    segment3,
                    segment4,
                    segment5,
                    segment6,
                    segment7,
                    segment8,
                    segment9,
                    segment10,
                    segment11,
                    segment12,
                    segment13,
                    segment14,
                    segment15,
                    segment16,
                    segment17,
                    segment18,
                    segment19,
                    segment20,
                    department_id,
                    --VJ: Start additions for Costing enhancement for WLTEnh--
                    costed_quantity_issued,
                    costed_quantity_relieved,
                    --VJ: End additions for Costing enhancement for WLTEnh--
                    released_quantity,
                    component_yield_factor) --component shrinkage
            SELECT  WCRO.COMPONENT_ITEM_ID,
                    WCRO.organization_id,
                    WCRO.wip_entity_id,
                    p_to_job_op_seq_num,
                    NULL,
                    SYSDATE,
                    p_user,
                    SYSDATE,
                    p_user,
                    p_login,
                    WCRO.COMPONENT_SEQUENCE_ID,
                    WCRO.WIP_SUPPLY_TYPE,
                    decode(recommended, 'Y', Nvl(WCRO.reco_date_required, p_txn_date), p_txn_date),
--move enh 115.77 component yield no longer factored in
/*                    round((WCRO.quantity_per_assembly/decode(WCRO.COMPONENT_YIELD_FACTOR,
                               0, 1, WCRO.COMPONENT_YIELD_FACTOR)), WSMPCNST.NUMBER_OF_DECIMALS)*p_txn_quantity,
*/

/*                    round((WCRO.quantity_per_assembly/decode(WCRO.COMPONENT_YIELD_FACTOR,
                                                       0, 1, WCRO.COMPONENT_YIELD_FACTOR)), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
*/
--bug 3587239 Round the required quantity to 6 places
                    WCRO.basis_type,     --LBM enh
--                  Component shrinkage
--                    ROUND((WCRO.quantity_per_assembly/wcro.component_yield_factor)
                    ROUND((WCRO.quantity_per_assembly)
                             * decode(wcro.basis_type, 2, 1, p_txn_quantity), WSMPCNST.NUMBER_OF_DECIMALS),   --LBM enh
                    0,
--component shrinkage
--                    WCRO.quantity_per_assembly,
                    WCRO.bill_quantity_per_assembly,
                    WCRO.supply_subinventory,
                    WCRO.supply_locator_id,
                    decode(WCRO.wip_supply_type,
                        5, 2,
                        decode(sign(WCRO.quantity_per_assembly),
                            -1, 2,
                            1)) mrp_net_flag,
                    WCRO.component_remarks,
                    WCRO.attribute_category,
                    WCRO.attribute1,
                    WCRO.attribute2,
                    WCRO.attribute3,
                    WCRO.attribute4,
                    WCRO.attribute5,
                    WCRO.attribute6,
                    WCRO.attribute7,
                    WCRO.attribute8,
                    WCRO.attribute9,
                    WCRO.attribute10,
                    WCRO.attribute11,
                    WCRO.attribute12,
                    WCRO.attribute13,
                    WCRO.attribute14,
                    WCRO.attribute15,
                    MSI.segment1,
                    MSI.segment2,
                    MSI.segment3,
                    MSI.segment4,
                    MSI.segment5,
                    MSI.segment6,
                    MSI.segment7,
                    MSI.segment8,
                    MSI.segment9,
                    MSI.segment10,
                    MSI.segment11,
                    MSI.segment12,
                    MSI.segment13,
                    MSI.segment14,
                    MSI.segment15,
                    MSI.segment16,
                    MSI.segment17,
                    MSI.segment18,
                    MSI.segment19,
                    MSI.segment20,
                    WCRO.department_id,
                    NULL,
                    NULL,
--bug 3587239 Round the released quantity to 6 places
                    ROUND(decode(wcro.basis_type, 2, 1, p_start_quantity)
                     *(WCRO.quantity_per_assembly/wcro.component_yield_factor), WSMPCNST.NUMBER_OF_DECIMALS),  --LBM enh
                    WCRO.component_yield_factor --component shrinkage
            FROM    WSM_COPY_REQUIREMENT_OPS WCRO,
                    MTL_SYSTEM_ITEMS MSI
            WHERE   WCRO.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
            AND     WCRO.WIP_ENTITY_ID= p_wip_entity_id
            AND     MSI.inventory_item_id = WCRO.component_item_id
            AND     MSI.organization_id = WCRO.organization_id
            AND     WCRO.RECOMMENDED='Y';

    END IF;

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||SQL%ROWCOUNT||' records in WRO.');
    end if;

    l_stmt_num := 80;

    INSERT INTO WIP_OPERATION_RESOURCES
            (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
            ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
            CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
            PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
            RESOURCE_ID, UOM_CODE,
            BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
            SCHEDULED_FLAG, ASSIGNED_UNITS,
        /* ST : Detailed Scheduling */
        maximum_assigned_units,
        batch_id,
        firm_flag,
        group_sequence_id,
        group_sequence_number,
        parent_resource_seq,
        /* ST : Detailed Scheduling */
        AUTOCHARGE_TYPE,
            STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
            START_DATE, COMPLETION_DATE,
            ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
            ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
            ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
            ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
            ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
            ATTRIBUTE15,
            SCHEDULE_SEQ_NUM,                   --bugfix 2493065
            SUBSTITUTE_GROUP_NUM,
            REPLACEMENT_GROUP_NUM,
            PRINCIPLE_FLAG,
            SETUP_ID)
     SELECT WCOR.WIP_ENTITY_ID
            , p_to_job_op_seq_num
            , WCOR.RESOURCE_SEQ_NUM
            , WCOR.ORGANIZATION_ID
            , NULL
            , SYSDATE
            , p_user
            , SYSDATE
            , p_user
            , p_login
            , DECODE(p_request_id, 0, '', p_request_id)
            , DECODE(p_program_application_id, 0, '', p_program_application_id)
            , DECODE(p_commit, 1, p_program_id, -999)
            , DECODE(p_program_id, 0, '', SYSDATE)
            , WCOR.RESOURCE_ID
            , WCOR.UOM_CODE
            , WCOR.BASIS_TYPE
            , WCOR.USAGE_RATE_OR_AMOUNT
            , WCOR.ACTIVITY_ID
            , WCOR.SCHEDULE_FLAG
            , WCOR.ASSIGNED_UNITS
            /* ST : Detailed Scheduling */
        , WCOR.MAX_ASSIGNED_UNITS
        , WCOR.batch_id
        , WCOR.firm_type
        , WCOR.group_sequence_id
        , WCOR.group_sequence_num
        , WCOR.parent_resource_seq_num
        /* ST : Detailed Scheduling */
        , WCOR.AUTOCHARGE_TYPE
            , WCOR.STANDARD_RATE_FLAG
            , 0
            , 0
            , decode(recommended, 'Y', nvl(RECO_START_DATE, p_txn_date), p_txn_date)
            , decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, p_txn_date), p_txn_date)
            , WCOR.ATTRIBUTE_CATEGORY
            , WCOR.ATTRIBUTE1
            , WCOR.ATTRIBUTE2
            , WCOR.ATTRIBUTE3
            , WCOR.ATTRIBUTE4
            , WCOR.ATTRIBUTE5
            , WCOR.ATTRIBUTE6
            , WCOR.ATTRIBUTE7
            , WCOR.ATTRIBUTE8
            , WCOR.ATTRIBUTE9
            , WCOR.ATTRIBUTE10
            , WCOR.ATTRIBUTE11
            , WCOR.ATTRIBUTE12
            , WCOR.ATTRIBUTE13
            , WCOR.ATTRIBUTE14
            , WCOR.ATTRIBUTE15
            , WCOR.SCHEDULE_SEQ_NUM
            , WCOR.SUBSTITUTE_GROUP_NUM
            , WCOR.REPLACEMENT_GROUP_NUM
            , WCOR.PRINCIPLE_FLAG
            , WCOR.SETUP_ID
    FROM    WSM_COPY_OP_RESOURCES WCOR
    WHERE   WCOR.ORGANIZATION_ID = p_org_id
    AND     WCOR.WIP_ENTITY_ID = p_Wip_Entity_Id
    AND     WCOR.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
    AND     WCOR.recommended='Y';

    l_wor_count := SQL%ROWCOUNT;

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: l_wor_count '||l_wor_count||
        ' l_wor_reco_res '||l_wor_reco_res);
    end if;

    l_stmt_num := 80;
--MES added department_id
    INSERT INTO WIP_SUB_OPERATION_RESOURCES
            (wip_entity_id,
            operation_seq_num,
            resource_seq_num,
            organization_id,
            repetitive_schedule_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            resource_id,
            uom_code,
            basis_type,
            usage_rate_or_amount,
            activity_id,
            scheduled_flag,
            assigned_units,
        maximum_assigned_units, /* ST : Detailed Scheduling */
            autocharge_type,
            standard_rate_flag,
            applied_resource_units,
            applied_resource_value,
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
            completion_date,
            start_date,
            schedule_seq_num,
            substitute_group_num,
            replacement_group_num,
            setup_id,
            department_id)
    SELECT  WCOR.wip_entity_id,
            p_to_job_op_seq_num,
            WCOR.resource_seq_num,
            WCOR.organization_id,
            null,
            SYSDATE ,
            p_user,
            SYSDATE,
            p_user,
            p_login,
            WCOR.resource_id,
            WCOR.uom_code,
            WCOR.basis_type,
            WCOR.usage_rate_or_amount,
            WCOR.activity_id,
            WCOR.schedule_flag,
            WCOR.assigned_units,
        WCOR.max_assigned_units,
            WCOR.autocharge_type,
            WCOR.standard_rate_flag,
            0, --WCOR.applied_resource_units,--move enh?
            0, -- WCOR.applied_resource_value, --move enh?
            WCOR.attribute_category,
            WCOR.attribute1,
            WCOR.attribute2,
            WCOR.attribute3,
            WCOR.attribute4,
            WCOR.attribute5,
            WCOR.attribute6,
            WCOR.attribute7,
            WCOR.attribute8,
            WCOR.attribute9,
            WCOR.attribute10,
            WCOR.attribute11,
            WCOR.attribute12,
            WCOR.attribute13,
            WCOR.attribute14,
            WCOR.attribute15,
            --as per Zhaohui copying the dates from WCOR
            nvl(WCOR.RECO_START_DATE, p_txn_date),
            nvl(WCOR.RECO_COMPLETION_DATE, p_txn_date),
            WCOR.schedule_seq_num,
            WCOR.substitute_group_num,
            WCOR.replacement_group_num,
            WCOR.setup_id,
            WCOR.department_id
    FROM    WSM_COPY_OP_RESOURCES WCOR
    WHERE   WCOR.ORGANIZATION_ID = p_org_id
    AND     WCOR.WIP_ENTITY_ID = p_Wip_Entity_Id
    AND     WCOR.OPERATION_SEQ_NUM = p_to_rtg_op_seq_num
    AND     WCOR.PHANTOM_ITEM_ID IS NULL
    AND     WCOR.recommended<>'Y';

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||SQL%ROWCOUNT||
         ' records in WIP_SUB_OPERATION_RESOURCES.');
    end if;

    l_stmt_num := 90;

    IF (l_wor_count > 0) THEN
        INSERT into WIP_OP_RESOURCE_INSTANCES
            (WIP_ENTITY_ID
            , OPERATION_SEQ_NUM
            , RESOURCE_SEQ_NUM
            , ORGANIZATION_ID
            , LAST_UPDATE_DATE
            , LAST_UPDATED_BY
            , CREATION_DATE
            , CREATED_BY
            , LAST_UPDATE_LOGIN
            , INSTANCE_ID
            , SERIAL_NUMBER
            , START_DATE
            , COMPLETION_DATE
            , BATCH_ID)
        SELECT WCORI.WIP_ENTITY_ID
            , p_to_job_op_seq_num
            , WCORI.RESOURCE_SEQ_NUM
            , WCORI.ORGANIZATION_ID
            , SYSDATE
            , p_user
            , SYSDATE
            , p_user
            , p_login
            , WCORI.INSTANCE_ID
            , WCORI.SERIAL_NUMBER
            , WCORI.START_DATE
            , WCORI.COMPLETION_DATE
            , WCORI.BATCH_ID
        FROM    WSM_COPY_OP_RESOURCE_INSTANCES WCORI
                -- WIP_OPERATION_RESOURCES WOR    Bug 5478658 join with WOR not required
        WHERE   WCORI.WIP_ENTITY_ID= p_wip_entity_id
        AND     WCORI.Operation_seq_num = p_to_rtg_op_seq_num ;

    --  Bug 5478658 Join conditions with WOR removed
    --  AND     WOR.WIP_ENTITY_ID= WCORI.WIP_ENTITY_ID
    --  AND     WOR.Operation_seq_num= WCORI.Operation_seq_num
    --  AND     WOR.RESOURCE_SEQ_NUM= WCORI.RESOURCE_SEQ_NUM;

        if (l_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||SQL%ROWCOUNT
                    ||' rows in WIP_OP_RESOURCE_INSTANCES');
        end if;

        INSERT into wip_operation_resource_usage
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                RESOURCE_SEQ_NUM,
                REPETITIVE_SCHEDULE_ID,
                ORGANIZATION_ID,
                START_DATE,
                COMPLETION_DATE,
                ASSIGNED_UNITS,
        -- resource_hours, /* ST : Detailed scheduling */
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                INSTANCE_ID,
                SERIAL_NUMBER,
                CUMULATIVE_PROCESSING_TIME)
        SELECT WCORU.WIP_ENTITY_ID,
                p_to_job_op_seq_num,
                WCORU.RESOURCE_SEQ_NUM,
                null,
                WCORU.ORGANIZATION_ID,
                WCORU.START_DATE,
                WCORU.COMPLETION_DATE,
                WCORU.ASSIGNED_UNITS,
        -- WCORU.RESOURCE_HOURS, /* ST : Detailed scheduling */
                SYSDATE ,
                p_user,
                SYSDATE,
                p_user,
                p_login,
                DECODE(p_request_id, 0, '', p_request_id),
                DECODE(p_program_application_id, 0, '', p_program_application_id),
                DECODE(p_commit, 1, p_program_id, -999),
                DECODE(p_program_id, 0, '', SYSDATE),
                WCORU.INSTANCE_ID,
                WCORU.SERIAL_NUMBER,
                WCORU.CUMULATIVE_PROCESSING_TIME
        FROM -- WIP_OPERATION_RESOURCES WOR,  Bug 5478658 join with WOR not required
                WSM_COPY_OP_RESOURCE_USAGE WCORU
        WHERE   WCORU.WIP_ENTITY_ID= p_wip_entity_id
        AND     WCORU.Operation_seq_num = p_to_rtg_op_seq_num ;

    --  Bug 5478658 Join conditions with WOR removed
    --  AND     WOR.WIP_ENTITY_ID= WCORU.WIP_ENTITY_ID
    --  AND     WOR.Operation_seq_num= WCORU.Operation_seq_num
    --  AND     WOR.RESOURCE_SEQ_NUM= WCORU.RESOURCE_SEQ_NUM;

    END IF;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Inserted '||SQL%ROWCOUNT
        ||' rows in wip_operation_resource_usage');
    end if;

    l_stmt_num := 100;

    if (l_debug = 'Y') then -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution: Calling set_prev_next..');
    end if; -- czh:BUG1995161

    set_prev_next(p_wip_entity_id,
          p_org_id,
          x_error_code,
          x_error_msg);

    IF (x_error_code <> 0) THEN
        raise e_proc_error;
    END IF;

    copy_to_op_mes_info(
      p_wip_entity_id           => p_wip_entity_id
    , p_to_job_op_seq_num       => p_to_job_op_seq_num
    , p_to_rtg_op_seq_num       => p_to_rtg_op_seq_num
    , p_txn_quantity            => p_txn_quantity
    , p_user                    => p_user
    , p_login                   => p_login
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    );

    IF l_return_status = g_ret_error THEN
      RAISE FND_API.G_EXC_ERROR;
      l_stmt_num := 370;
      IF (l_msg_count = 1)  THEN
        x_error_code := -1;
        x_error_msg := l_msg_data;
      ELSE
        FOR i IN 1..l_msg_count LOOP
            x_error_code := -1;
            x_error_msg := substr(x_error_msg||fnd_msg_pub.get, 1, 4000);
        END LOOP;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = g_ret_unexpected THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
      IF (l_return_status = g_ret_success) THEN
        l_msg_tokens.delete;
        WSM_log_PVT.logMessage (
          p_module_name     => l_module ,
          p_msg_text          => 'WSMPOPRN.copy_to_op_mes_info returned successfully',
          p_stmt_num          => l_stmt_num   ,
          p_msg_tokens        => l_msg_tokens   ,
          p_fnd_log_level     => G_LOG_LEVEL_STATEMENT  ,
          p_run_log_level     => l_log_level
        );
      END IF;
    END IF;

EXCEPTION
    -- This just means that the operation was already inserted
    WHEN e_proc_error THEN
        x_error_code := -1;
        x_error_msg := 'WSMPOPRN.copy_plan_to_execution('||l_stmt_num||'): '||x_error_msg;
        fnd_file.put_line(fnd_file.log, x_error_msg);

    WHEN dup_val_on_index THEN
        BEGIN
            IF (p_dup_val_ignore='N') THEN
                x_error_code := SQLCODE;
                x_error_msg := 'WSMOPRNB.copy_plan_to_execution('||l_stmt_num||')'|| substr(SQLERRM,1,2000);
            ELSE
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution other excpn: (stmt'||l_stmt_num ||'): dup_val_on_index');
            END IF;
        END;

    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.copy_plan_to_execution('||l_stmt_num||')'|| substr(SQLERRM,1,2000);
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.copy_plan_to_execution other excpn: (stmt'||l_stmt_num ||'):'||x_error_msg);

END copy_plan_to_execution;

PROCEDURE call_infinite_scheduler(
    x_error_code                OUT NOCOPY NUMBER,
    x_error_msg                 OUT NOCOPY VARCHAR2,
    p_jump_flag                 IN VARCHAR2,
    p_wip_entity_id             IN NUMBER,
    p_org_id                    IN NUMBER,
    p_to_op_seq_id              IN NUMBER,
    p_fm_job_op_seq_num         IN NUMBER,
    p_to_job_op_seq_num         IN NUMBER,
    p_scheQuantity              IN NUMBER)
IS
    l_recommended_op            VARCHAR2(1);
    x_returnStatus              VARCHAR2(1);
    l_reco_start_date           DATE;
    l_reco_completion_date      DATE;
    l_infi_start_date           DATE;
    l_stmt_num                  NUMBER;
BEGIN
    l_stmt_num := 10;
    BEGIN
        SELECT  nvl(recommended, 'N'), RECO_START_DATE, reco_completion_date
        INTO    l_recommended_op, l_reco_start_date, l_reco_completion_date
        FROM    WSM_COPY_OPERATIONS
        WHERE   wip_entity_id = p_wip_entity_id
        AND     operation_sequence_id = p_to_op_seq_id;
    EXCEPTION
        WHEN no_data_found THEN
            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'To Op not present in WSM_COPY_OPERATIONS');
            END IF;
            null;
    END;

    IF ((p_jump_flag = 'Y') OR (l_recommended_op <> 'Y') OR (l_reco_start_date IS NULL)
        OR (l_reco_completion_date IS NULL)) THEN
            l_stmt_num := 20;

            SELECT  last_unit_completion_date
            INTO    l_infi_start_date
            FROM    WIP_OPERATIONS
            WHERE   wip_entity_id = p_wip_entity_id
            AND     organization_id = p_org_id
            AND     operation_seq_num = p_fm_job_op_seq_num;

            l_stmt_num := 30;
            wsm_infinite_scheduler_pvt.schedule(
                    p_initMsgList   => fnd_api.g_true,
                    p_endDebug      => fnd_api.g_true,
                    p_orgID         => p_org_id,
                    p_wipEntityID   => p_wip_entity_id,
                    p_scheduleMode  => WIP_CONSTANTS.CURRENT_OP,
                    p_startDate     => l_infi_start_date,
                    p_endDate       => null,
                    p_opSeqNum      => -p_to_job_op_seq_num,
                    p_scheQuantity  =>  p_scheQuantity,
                    x_returnStatus  => x_returnStatus,
                    x_errorMsg      => x_error_msg);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
                fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling wsm_infinite_scheduler_pvt.schedule: '||x_error_msg);
                x_error_code := -1;
                return ;
            ELSE
                IF (l_debug = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, 'WSMPOPRN.add_operation calling wsm_infinite_scheduler_pvt.schedule returned success');
                END IF;
            END IF;
    END IF;
    x_error_code := 0;
EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.call_infinite_scheduler('||l_stmt_num||')'|| substr(SQLERRM,1,2000);
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.call_infinite_scheduler other excpn: (stmt'||l_stmt_num ||'):'||x_error_msg);
END call_infinite_scheduler;

--bug 3162358 115.78 added this new procedure which will be called from WSMTXSFM.pld and WSMLBMIB.pls
/*
PROCEDURE upd_cumulative_scrap_qty(
      x_error_code              OUT NOCOPY NUMBER
    , x_error_msg               OUT NOCOPY VARCHAR2
    , p_org_id                  IN NUMBER
    , p_wip_entity_id           IN NUMBER
    , p_job_op_seq_num          IN NUMBER)
IS
    l_stmt_num  NUMBER;
BEGIN
    l_stmt_num := 10;
    UPDATE  WIP_OPERATIONS WO
    SET     cumulative_scrap_quantity =
            (SELECT quantity_scrapped
            FROM    WIP_DISCRETE_JOBS WDJ
            WHERE   WDJ.wip_entity_id = p_wip_entity_id
            AND     WDJ.organization_id = p_org_id)
    WHERE   WO.wip_entity_id        = p_wip_entity_id
    AND     WO.organization_id      = p_org_id
    AND     WO.operation_seq_num    = p_job_op_seq_num;
EXCEPTION
    WHEN others THEN
        x_error_code := SQLCODE;
        x_error_msg := 'WSMOPRNB.upd_cumulative_scrap_qty('||l_stmt_num||')'|| substr(SQLERRM,1,2000);
        -- czh:BUG1995161
        fnd_file.put_line(fnd_file.log, 'WSMPOPRN.upd_cumulative_scrap_qty other excpn: (stmt'||l_stmt_num ||'):'||x_error_msg);
END upd_cumulative_scrap_qty;
*/

/******************************************************************************************
Procedure to copy mes data from setup tables to job operation tables
******************************************************************************************/
Procedure copy_to_op_mes_info(
    p_wip_entity_id             IN NUMBER
    , p_to_job_op_seq_num       IN NUMBER
    , p_to_rtg_op_seq_num       IN NUMBER
    , p_txn_quantity            IN NUMBER
    , p_user                    IN NUMBER
    , p_login                   IN NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    )
    IS
      l_stmt_num                                NUMBER;
      l_serialization_started                   NUMBER;

    -- Logging variables.....
        l_msg_tokens                            WSM_Log_PVT.token_rec_tbl;
        l_log_level                             number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        l_module                                CONSTANT VARCHAR2(100)  := 'wsm.plsql.WSMPLBMI.getJobOpPageProperties';
        l_param_tbl                             WSM_Log_PVT.param_tbl_type;
        x_error_count                           NUMBER;
        x_return_code                           NUMBER;
        x_error_msg                             VARCHAR2(4000);

BEGIN
    x_return_status := G_RET_SUCCESS;
    IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

      l_param_tbl.delete;
      l_param_tbl(1).paramName := 'p_wip_entity_id';
      l_param_tbl(1).paramValue := p_wip_entity_id;
      l_param_tbl(2).paramName := 'p_to_job_op_seq_num';
      l_param_tbl(2).paramValue := p_to_job_op_seq_num;
      l_param_tbl(3).paramName := 'p_txn_quantity';
      l_param_tbl(3).paramValue := p_txn_quantity;
      l_param_tbl(4).paramName := 'p_user';
      l_param_tbl(5).paramValue := p_user;
      l_param_tbl(6).paramName := 'p_login';
      l_param_tbl(6).paramValue := p_login;

      WSM_Log_PVT.logProcParams(p_module_name   => l_module   ,
              p_param_tbl     => l_param_tbl,
              p_fnd_log_level     => G_LOG_LEVEL_PROCEDURE
      );
    END IF;

    INSERT INTO WSM_OP_SECONDARY_QUANTITIES
        (
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        ORGANIZATION_ID,
        WIP_ENTITY_ID,
        UOM_CODE,
        OPERATION_SEQ_NUM,
        MOVE_IN_QUANTITY,
        MOVE_OUT_QUANTITY
        )
        SELECT  SYSDATE,
            p_user,
            p_login,
            SYSDATE,
            p_user,
            ORGANIZATION_ID,
            WIP_ENTITY_ID,
            UOM_CODE,
            p_to_job_op_seq_num,
            CURRENT_QUANTITY,
            NULL
        FROM    WSM_JOB_SECONDARY_QUANTITIES
        WHERE   WIP_ENTITY_ID = p_wip_entity_id
        and     currently_active = 1;

        l_stmt_num := 92;

        INSERT INTO WSM_OP_REASON_CODES
        (
        ORGANIZATION_ID,
        WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,
        CODE_TYPE,
        REASON_CODE,
        QUANTITY,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        LAST_UPDATED_LOGIN
        )
        SELECT  DISTINCT ORGANIZATION_ID,
            WIP_ENTITY_ID,
            OPERATION_SEQ_NUM,
            1, --CODE_TYPE,
            SCRAP_CODE,
            NULL,
            p_user,
            SYSDATE,
            p_user,
            SYSDATE,
            p_login
        FROM    BOM_STD_OP_SCRAP_CODES BSOSC,
            WIP_OPERATIONS WO
        WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
        AND     WO.OPERATION_SEQ_NUM = p_to_job_op_seq_num
        AND     BSOSC.STANDARD_OPERATION_ID = WO.STANDARD_OPERATION_ID;

        l_stmt_num := 93;
        INSERT INTO WSM_OP_REASON_CODES
        (
        ORGANIZATION_ID,
        WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,
        CODE_TYPE,
        REASON_CODE,
        QUANTITY,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        LAST_UPDATED_LOGIN
        )
        SELECT  DISTINCT ORGANIZATION_ID,
            WIP_ENTITY_ID,
            OPERATION_SEQ_NUM,
            2, --CODE_TYPE,
            BONUS_CODE,
            NULL,
            p_user,
            SYSDATE,
            p_user,
            SYSDATE,
            p_login
        FROM    BOM_STD_OP_BONUS_CODES BSOSC,
            WIP_OPERATIONS WO
        WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
        AND     WO.OPERATION_SEQ_NUM = p_to_job_op_seq_num
        AND     BSOSC.STANDARD_OPERATION_ID = WO.STANDARD_OPERATION_ID;

        UPDATE  WSM_LOT_BASED_JOBS
        SET     current_job_op_seq_num = p_to_job_op_seq_num,
                current_rtg_op_seq_num = p_to_rtg_op_seq_num
        WHERE   WIP_ENTITY_ID = p_wip_entity_id;



        FND_MSG_PUB.Count_And_Get (   p_encoded       =>      'F'           ,
                          p_count             =>      x_error_count         ,
                          p_data              =>      x_error_msg
                                      );
EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded       =>      'F'           ,
                                  p_count             =>      x_error_count         ,
                                  p_data              =>      x_error_msg
                              );

            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded       =>      'F'           ,
                                  p_count             =>      x_error_count         ,
                                  p_data              =>      x_error_msg
                              );
            WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)      OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                    WSM_log_PVT.handle_others( p_module_name        => l_module         ,
                                   p_stmt_num           => l_stmt_num       ,
                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                   p_run_log_level      => l_log_level
                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded       =>      'F'           ,
                                  p_count             =>      x_error_count         ,
                                  p_data              =>      x_error_msg
                      );
END;
--MES END

--bug 5337172 intermediate function generated by rosetta
function update_job_name(p_wip_entity_id  NUMBER
    , p_subinventory  VARCHAR2
    , p_org_id  NUMBER
    , p_txn_type  NUMBER
    , p_update_flag  number
    , p_dup_job_name out nocopy  VARCHAR2
    , x_error_code out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  ) return varchar2

  as
    ddp_update_flag boolean;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if p_update_flag is null
      then ddp_update_flag := null;
    elsif p_update_flag = 0
      then ddp_update_flag := false;
    else ddp_update_flag := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := WSMPOPRN.update_job_name(p_wip_entity_id,
      p_subinventory,
      p_org_id,
      p_txn_type,
      ddp_update_flag,
      p_dup_job_name,
      x_error_code,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    return ddrosetta_retval;
  end;
--end bug 5337172
END WSMPOPRN;


/
