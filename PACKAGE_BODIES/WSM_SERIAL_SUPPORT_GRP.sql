--------------------------------------------------------
--  DDL for Package Body WSM_SERIAL_SUPPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_SERIAL_SUPPORT_GRP" AS
/* $Header: WSMGSERB.pls 120.2.12000000.2 2007/02/23 12:32:48 mprathap ship $ */

g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error         NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success       NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success           varchar2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error             varchar2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

-- This procedure will be invoked by the WIP move processor (for interface transactions)
-- If the transaction type is an undo/assembly return transaction populate_components will be invoked.
-- Or else the WIP API wip_movProc_grp.backflushIntoMTI will be invoked which would derive backflush components..

Procedure backflush_comp(p_wipEntityID      IN        NUMBER,
                         p_orgID            IN        NUMBER,
                         p_primaryQty       IN        NUMBER,
                         p_txnDate          IN        DATE,
                         p_txnHdrID         IN        NUMBER,
                         p_txnType          IN        NUMBER,
                         p_fmOp             IN        NUMBER,
                         p_fmStep           IN        NUMBER,
                         p_toOp             IN        NUMBER,
                         p_toStep           IN        NUMBER,
                         p_movTxnID         IN        NUMBER,
                         p_cplTxnID         IN        NUMBER:= NULL,
                         p_mtlTxnMode       IN        NUMBER,
                         p_reasonID         IN        NUMBER := NULL,
                         p_reference        IN        VARCHAR2 := NULL,
                         p_init_msg_list    IN        VARCHAR2,
                         x_lotSerRequired   OUT NOCOPY NUMBER,
                         x_returnStatus     OUT NOCOPY VARCHAR2,
                         x_error_msg        OUT NOCOPY VARCHAR2,
                         x_error_count      OUT NOCOPY  NUMBER
                       )
IS

l_job_type NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_Serial_support_GRP.backflush_comp';
-- Logging variables....

BEGIN
        l_stmt_num := 10;

        x_returnStatus := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        select entity_type
        into l_job_type
        from wip_entities WE
        where WE.wip_entity_id = p_wipEntityID
        and   WE.organization_id = p_orgID;

        l_stmt_num := 20;

        -- if it is a Lot based job undo/return transaction then, call WSM API
        if (l_job_type = 5) and
           (p_txnType = 3 OR ( (p_fmOp > p_toOp)
                                OR
                                ( (p_fmOp = p_toOp) and (p_fmStep > p_toStep) )
                             )
           )
        then
                l_stmt_num := 30;


                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking populate_components',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                populate_components(p_wip_entity_id             => p_wipEntityID,
                                    p_organization_id           => p_orgId,
                                    p_move_txn_id               => p_movTxnID,
                                    p_move_txn_type             => p_txnType,
                                    p_txn_date                  => p_txnDate,
                                    p_mtl_txn_hdr_id            => p_txnHdrID,
                                    p_compl_txn_id              => p_cplTxnID,
                                    x_return_status             => x_returnStatus     ,
                                    x_error_count               => x_error_msg        ,
                                    x_error_msg                 => x_error_count
                                    );

                if x_returnStatus <> G_RET_SUCCESS then
                        IF x_returnStatus = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_returnStatus = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
                l_stmt_num := 40;
        else

                l_stmt_num := 50;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking wip_movProc_grp.backflushIntoMTI',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                -- else call WIP procedure.. (Please refer the WIP MED here )
                wip_movProc_grp.backflushIntoMTI ( p_wipEntityID     =>  p_wipEntityID     ,
                                                   p_orgID           =>  p_orgID           ,
                                                   p_primaryQty      =>  p_primaryQty      ,
                                                   p_txnDate         =>  p_txnDate         ,
                                                   p_txnHdrID        =>  p_txnHdrID        ,
                                                   p_txnType         =>  p_txnType         ,
                                                   p_fmOp            =>  p_fmOp            ,
                                                   p_fmStep          =>  p_fmStep          ,
                                                   p_toOp            =>  p_toOp            ,
                                                   p_toStep          =>  p_toStep          ,
                                                   p_movTxnID        =>  p_movTxnID        ,
                                                   p_cplTxnID        =>  p_cplTxnID        ,
                                                   p_mtlTxnMode      =>  p_mtlTxnMode      ,
                                                   p_reasonID        =>  p_reasonID        ,
                                                   p_reference       =>  p_reference       ,
                                                   x_lotSerRequired  =>  x_lotSerRequired  ,
                                                   x_returnStatus    =>  x_returnStatus
                                                 );

                if x_returnStatus <> G_RET_SUCCESS then
                        IF x_returnStatus = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_returnStatus = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

                l_stmt_num := 60;
        end if;
EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_returnStatus := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_returnStatus := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );
        WHEN OTHERS THEN

                 x_returnStatus := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );
END backflush_comp;

-- Populate MMTT,MTLT and MSNT for an assembly return/undo transaction for a lot based job
-- based on the previous move transaction records in MMT,MTL,MUT.

procedure populate_components(p_wip_entity_id           IN         NUMBER,
                              p_organization_id         IN         NUMBER,
                              p_move_txn_id             IN         NUMBER,
                              p_move_txn_type           IN         NUMBER,
                              p_txn_date                IN         DATE,
                              p_mtl_txn_hdr_id          IN         NUMBER,
                              p_compl_txn_id            IN         NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_error_count             OUT NOCOPY NUMBER,
                              x_error_msg               OUT NOCOPY VARCHAR2
                             )


IS
l_user_id  NUMBER := FND_GLOBAL.user_id;
l_login_id NUMBER := fnd_global.login_id;
l_req_id   NUMBER := fnd_global.conc_request_id;

l_prog_appl_id NUMBER := fnd_global.prog_appl_id;
l_prog_id      NUMBER := fnd_global.conc_program_id;

l_lot_controlled        NUMBER;
l_serial_txn_id         NUMBER;
l_scrap_txn_id          NUMBER;
l_move_txn_id           NUMBER;
l_acct_period_id        NUMBER;
l_temp_id               NUMBER;

cursor c_mmt_txn is
        SELECT TRANSACTION_ID
        FROM  MTL_MATERIAL_TRANSACTIONS MMT
        WHERE MMT.organization_id = p_organization_id
        AND   MMT.move_transaction_id IN (l_move_txn_id,l_scrap_txn_id)
        AND   MMT.transaction_source_id = p_wip_entity_id
        AND   MMT.subinventory_code IS NOT NULL
        AND   MMT.transaction_type_id IN (WIP_CONSTANTS.ISSCOMP_TYPE,  -- 35 -- WIP Component Issue
                                          WIP_CONSTANTS.ISSNEGC_TYPE   -- 38 -- Negative component issue
                                          );

        -- Transaction types
        -- ISSCOMP_TYPE CONSTANT NUMBER := 35;    -- Components taken out of INV
        -- BFLREPL_TYPE CONSTANT NUMBER := 51;    -- Backflush replenishment
        -- COSTUPD_TYPE CONSTANT NUMBER := 25;    -- Cost update
        -- RETCOMP_TYPE CONSTANT NUMBER := 43;    -- Components put into INV
        -- SCRASSY_TYPE CONSTANT NUMBER := 90;    -- Assembly scrap
        -- CPLASSY_TYPE CONSTANT NUMBER := 44;    -- Assemblies put into INV
        -- RETASSY_TYPE CONSTANT NUMBER := 17;    -- Assemblies taken out of INV
        -- ISSNEGC_TYPE CONSTANT NUMBER := 38;    -- Negative component issue
        -- RETNEGC_TYPE CONSTANT NUMBER := 48;    -- Negative component return
--Bug 5614015: added rowid in the cursor c_lot_txn
cursor c_lot_txn(v_txn_id IN NUMBER) IS
        SELECT TRANSACTION_ID,
               SERIAL_TRANSACTION_ID,
               LOT_NUMBER,
               ROWID
        from  mtl_transaction_lot_numbers MTLN
        where MTLN.organization_id = p_organization_id
        and   MTLN.transaction_id = v_txn_id;

l_open_past_period BOOLEAN := false;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_GRP.populate_components';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF (G_LOG_LEVEL_PROCEDURE >= l_log_level) THEN
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_move_txn_id';
                l_param_tbl(1).paramValue := p_move_txn_id;

                l_param_tbl(2).paramName := 'p_mtl_txn_hdr_id';
                l_param_tbl(2).paramValue := p_mtl_txn_hdr_id;

                l_param_tbl(3).paramName := 'p_organization_id';
                l_param_tbl(3).paramValue := p_organization_id;

                l_param_tbl(4).paramName := 'p_wip_entity_id';
                l_param_tbl(4).paramValue := p_wip_entity_id;

                WSM_Log_PVT.logProcParams(p_module_name         => 'wsm.plsql.WSM_SERIAL_SUPPORT_GRP.populate_components',
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_stmt_num := 20;

        invttmtx.tdatechk(org_id                => p_organization_id,
                          transaction_date      => p_txn_date,
                          period_id             => l_acct_period_id,
                          open_past_period      => l_open_past_period
                          );


        if(l_acct_period_id is null or
           l_acct_period_id <= 0)
        then
                l_stmt_num := 30;

                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'INV_NO_OPEN_PERIOD'     ,
                                               p_msg_appl_name      => 'INV'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        end if;

        -- get a txn header id..
        -- No will be passed...
        /*SELECT mtl_material_transactions_s.nextval
        into p_mtl_txn_hdr_id
        from dual;
        */

        /* Have to be passed....
        if p_move_txn_type = wip_constants.RET_TXN then
                SELECT mtl_material_transactions_s.nextval
                into p_compl_txn_id
                from dual;
        end if;
        */

        -- could be a move and scrap transaction too...
        -- get the move transaction id alone...
        l_stmt_num := 40;

        --Bug 5215899: Handle null value for batch_id.
        select  max(wmt.transaction_id)
        into    l_move_txn_id
        from    wip_move_transactions wmt
        where   wmt.organization_id = p_organization_id
        and     wmt.wip_entity_id = p_wip_entity_id
        and     wmt.wsm_undo_txn_id IS NULL
        and     wmt.transaction_id = nvl(wmt.batch_id,wmt.transaction_id)
        and     wmt.transaction_id <> p_move_txn_id;

        begin
                select  wmt.transaction_id
                into    l_scrap_txn_id
                from    wip_move_transactions wmt
                where   wmt.organization_id = p_organization_id
                and     wmt.wip_entity_id = p_wip_entity_id
                and     wmt.wsm_undo_txn_id IS NULL
                and     wmt.transaction_id <> p_move_txn_id
                and     wmt.transaction_id <> wmt.batch_id
                and     wmt.batch_id = l_move_txn_id;
        exception
                when no_data_found then
                        null;
        end;

        l_stmt_num := 50;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Old Transaction Values : Move Transaction ID : ' || l_move_txn_id || ' Scrap Transaction ID : ' || l_scrap_txn_id,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        for l_mmt_rec in c_mmt_txn loop

                l_stmt_num := 60;
                select mtl_material_transactions_s.nextval
                into l_temp_id
                from dual;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'MMTT Transaction ID : ' || l_temp_id,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_stmt_num := 70;
                -- Insert into MMTT
                INSERT INTO mtl_material_transactions_temp
                (
                    TRANSACTION_HEADER_ID,
                    TRANSACTION_TEMP_ID,
                    SOURCE_CODE,
                    SOURCE_LINE_ID,
                    PROCESS_FLAG,
                    POSTING_FLAG,
                    --WIP_COMMIT_FLAG,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    PROGRAM_APPLICATION_ID,
                    REQUEST_ID,
                    ORGANIZATION_ID,
                    SUBINVENTORY_CODE,
                    LOCATOR_ID,
                    INVENTORY_ITEM_ID,
                    REVISION,
                    TRANSACTION_TYPE_ID,
                    TRANSACTION_ACTION_ID,
                    TRANSACTION_SOURCE_TYPE_ID,
                    TRANSACTION_SOURCE_ID,
                    TRANSACTION_SOURCE_NAME,
                    TRANSACTION_REFERENCE,
                    REASON_ID,
                    TRANSACTION_DATE,
                    ACCT_PERIOD_ID,
                    TRANSACTION_QUANTITY,
                    TRANSACTION_UOM,
                    PRIMARY_QUANTITY,
                    OPERATION_SEQ_NUM,
                    DEPARTMENT_ID,
                    EMPLOYEE_CODE,
                    WIP_ENTITY_TYPE,
                    COMPLETION_TRANSACTION_ID,
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
                    MOVEMENT_ID,
                    SOURCE_PROJECT_ID,
                    SOURCE_TASK_ID,
                    PROJECT_ID,
                    TASK_ID,
                    MOVE_TRANSACTION_ID --Bug 5207917
                   )
                   SELECT
                   p_mtl_txn_hdr_id,
                   l_temp_id,
                   MMT.SOURCE_CODE,
                   MMT.SOURCE_LINE_ID,
                   'Y', -- PROCESS_FLAG,
                   'Y',--  POSTING_FLAG,
                   --'N',--  WIP_COMMIT_FLAG,
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   l_login_id,
                   l_prog_id,
                   sysdate,
                   l_prog_appl_id,
                   l_req_id,
                   MMT.ORGANIZATION_ID,
                   MMT.SUBINVENTORY_CODE,
                   MMT.LOCATOR_ID,
                   MMT.INVENTORY_ITEM_ID,
                   MMT.REVISION,
                   decode(MMT.TRANSACTION_ACTION_ID,wip_constants.issnegc_action,
                                                 wip_constants.retnegc_type,
                                                 wip_constants.retcomp_type

                   ),
                   decode(MMT.TRANSACTION_ACTION_ID,wip_constants.issnegc_action,
                                                 wip_constants.retnegc_action,
                                                 wip_constants.retcomp_action

                   ),
                   MMT.TRANSACTION_SOURCE_TYPE_ID,
                   MMT.TRANSACTION_SOURCE_ID,
                   MMT.TRANSACTION_SOURCE_NAME,
                   MMT.TRANSACTION_REFERENCE,
                   MMT.REASON_ID,
                   p_txn_date, -- transaction date
                   l_acct_period_id, -- accout period id...
                   -1 * MMT.TRANSACTION_QUANTITY,
                   MMT.TRANSACTION_UOM,
                   -1 * MMT.PRIMARY_QUANTITY,
                   MMT.OPERATION_SEQ_NUM,
                   MMT.DEPARTMENT_ID,
                   MMT.EMPLOYEE_CODE,
                   5, --MMT.WIP_ENTITY_TYPE,
                   p_compl_txn_id,
                   MMT.ATTRIBUTE_CATEGORY,
                   MMT.ATTRIBUTE1,
                   MMT.ATTRIBUTE2,
                   MMT.ATTRIBUTE3,
                   MMT.ATTRIBUTE4,
                   MMT.ATTRIBUTE5,
                   MMT.ATTRIBUTE6,
                   MMT.ATTRIBUTE7,
                   MMT.ATTRIBUTE8,
                   MMT.ATTRIBUTE9,
                   MMT.ATTRIBUTE10,
                   MMT.ATTRIBUTE11,
                   MMT.ATTRIBUTE12,
                   MMT.ATTRIBUTE13,
                   MMT.ATTRIBUTE14,
                   MMT.ATTRIBUTE15,
                   MMT.MOVEMENT_ID,
                   MMT.SOURCE_PROJECT_ID,
                   MMT.SOURCE_TASK_ID,
                   MMT.PROJECT_ID,
                   MMT.TASK_ID,
                   p_move_txn_id --Bug 5207917
                   FROM MTL_MATERIAL_TRANSACTIONS MMT
                   WHERE TRANSACTION_ID = l_mmt_rec.transaction_id;

                   IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Inserted : ' || SQL%ROWCOUNT || ' rows into MMTT',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                   END IF;

                   l_stmt_num := 80;
                   l_lot_controlled := 0;
                   -- Now obtain the the Lot
                   for l_lot_txn_rec in c_lot_txn(l_mmt_rec.transaction_id) loop

                        l_stmt_num := 90;

                        l_lot_controlled := 1;
                        if l_lot_txn_rec.serial_transaction_id is not null then
                                l_stmt_num := 100;
                                select mtl_material_transactions_s.nextval
                                into l_serial_txn_id
                                from dual;
                        else
                                l_stmt_num := 110;
                                l_serial_txn_id := null;
                        end if;

                        l_stmt_num := 120;
                        insert into mtl_transaction_lots_temp
                        (
                        TRANSACTION_TEMP_ID           ,
                        LAST_UPDATE_DATE              ,
                        LAST_UPDATED_BY               ,
                        CREATION_DATE                 ,
                        CREATED_BY                    ,
                        LAST_UPDATE_LOGIN             ,
                        REQUEST_ID                    ,
                        PROGRAM_APPLICATION_ID        ,
                        PROGRAM_ID                    ,
                        PROGRAM_UPDATE_DATE           ,
                        TRANSACTION_QUANTITY          ,
                        PRIMARY_QUANTITY              ,
                        LOT_NUMBER                    ,
                        SERIAL_TRANSACTION_TEMP_ID    ,
                        DESCRIPTION                   ,
                        VENDOR_NAME                   ,
                        SUPPLIER_LOT_NUMBER           ,
                        ORIGINATION_DATE              ,
                        DATE_CODE                     ,
                        GRADE_CODE                    ,
                        CHANGE_DATE                   ,
                        MATURITY_DATE                 ,
                        STATUS_ID                     ,
                        RETEST_DATE                   ,
                        AGE                           ,
                        ITEM_SIZE                     ,
                        COLOR                         ,
                        VOLUME                        ,
                        VOLUME_UOM                    ,
                        PLACE_OF_ORIGIN               ,
                        BEST_BY_DATE                  ,
                        LENGTH                        ,
                        LENGTH_UOM                    ,
                        RECYCLED_CONTENT              ,
                        THICKNESS                     ,
                        THICKNESS_UOM                 ,
                        WIDTH                         ,
                        WIDTH_UOM                     ,
                        CURL_WRINKLE_FOLD             ,
                        LOT_ATTRIBUTE_CATEGORY        ,
                        C_ATTRIBUTE1                  ,
                        C_ATTRIBUTE2                  ,
                        C_ATTRIBUTE3                  ,
                        C_ATTRIBUTE4                  ,
                        C_ATTRIBUTE5                  ,
                        C_ATTRIBUTE6                  ,
                        C_ATTRIBUTE7                  ,
                        C_ATTRIBUTE8                  ,
                        C_ATTRIBUTE9                  ,
                        C_ATTRIBUTE10                 ,
                        C_ATTRIBUTE11                 ,
                        C_ATTRIBUTE12                 ,
                        C_ATTRIBUTE13                 ,
                        C_ATTRIBUTE14                 ,
                        C_ATTRIBUTE15                 ,
                        C_ATTRIBUTE16                 ,
                        C_ATTRIBUTE17                 ,
                        C_ATTRIBUTE18                 ,
                        C_ATTRIBUTE19                 ,
                        C_ATTRIBUTE20                 ,
                        D_ATTRIBUTE1                  ,
                        D_ATTRIBUTE2                  ,
                        D_ATTRIBUTE3                  ,
                        D_ATTRIBUTE4                  ,
                        D_ATTRIBUTE5                  ,
                        D_ATTRIBUTE6                  ,
                        D_ATTRIBUTE7                  ,
                        D_ATTRIBUTE8                  ,
                        D_ATTRIBUTE9                  ,
                        D_ATTRIBUTE10                 ,
                        N_ATTRIBUTE1                  ,
                        N_ATTRIBUTE2                  ,
                        N_ATTRIBUTE3                  ,
                        N_ATTRIBUTE4                  ,
                        N_ATTRIBUTE5                  ,
                        N_ATTRIBUTE6                  ,
                        N_ATTRIBUTE7                  ,
                        N_ATTRIBUTE8                  ,
                        N_ATTRIBUTE9                  ,
                        N_ATTRIBUTE10                 ,
                        VENDOR_ID                     ,
                        TERRITORY_CODE                ,
                        PRODUCT_CODE                  ,
                        PRODUCT_TRANSACTION_ID        ,
                        ATTRIBUTE_CATEGORY            ,
                        ATTRIBUTE1                    ,
                        ATTRIBUTE2                    ,
                        ATTRIBUTE3                    ,
                        ATTRIBUTE4                    ,
                        ATTRIBUTE5                    ,
                        ATTRIBUTE6                    ,
                        ATTRIBUTE7                    ,
                        ATTRIBUTE8                    ,
                        ATTRIBUTE9                    ,
                        ATTRIBUTE10                   ,
                        ATTRIBUTE11                   ,
                        ATTRIBUTE12                   ,
                        ATTRIBUTE13                   ,
                        ATTRIBUTE14                   ,
                        ATTRIBUTE15                   --,
                        )
                        SELECT
                        l_temp_id                     ,
                        sysdate                       ,
                        l_user_id                     ,
                        sysdate                       ,
                        l_user_id                     ,
                        l_login_id                    ,
                        l_req_id                      ,
                        l_prog_appl_id                ,
                        l_prog_id                     ,
                        sysdate                       ,
                        -1 * TRANSACTION_QUANTITY          ,
                        -1 * PRIMARY_QUANTITY              ,
                        LOT_NUMBER                    ,
                        l_serial_txn_id               ,
                        DESCRIPTION                   ,
                        VENDOR_NAME                   ,
                        SUPPLIER_LOT_NUMBER           ,
                        ORIGINATION_DATE              ,
                        DATE_CODE                     ,
                        GRADE_CODE                    ,
                        CHANGE_DATE                   ,
                        MATURITY_DATE                 ,
                        STATUS_ID                     ,
                        RETEST_DATE                   ,
                        AGE                           ,
                        ITEM_SIZE                     ,
                        COLOR                         ,
                        VOLUME                        ,
                        VOLUME_UOM                    ,
                        PLACE_OF_ORIGIN               ,
                        BEST_BY_DATE                  ,
                        LENGTH                        ,
                        LENGTH_UOM                    ,
                        RECYCLED_CONTENT              ,
                        THICKNESS                     ,
                        THICKNESS_UOM                 ,
                        WIDTH                         ,
                        WIDTH_UOM                     ,
                        CURL_WRINKLE_FOLD             ,
                        LOT_ATTRIBUTE_CATEGORY        ,
                        C_ATTRIBUTE1                  ,
                        C_ATTRIBUTE2                  ,
                        C_ATTRIBUTE3                  ,
                        C_ATTRIBUTE4                  ,
                        C_ATTRIBUTE5                  ,
                        C_ATTRIBUTE6                  ,
                        C_ATTRIBUTE7                  ,
                        C_ATTRIBUTE8                  ,
                        C_ATTRIBUTE9                  ,
                        C_ATTRIBUTE10                 ,
                        C_ATTRIBUTE11                 ,
                        C_ATTRIBUTE12                 ,
                        C_ATTRIBUTE13                 ,
                        C_ATTRIBUTE14                 ,
                        C_ATTRIBUTE15                 ,
                        C_ATTRIBUTE16                 ,
                        C_ATTRIBUTE17                 ,
                        C_ATTRIBUTE18                 ,
                        C_ATTRIBUTE19                 ,
                        C_ATTRIBUTE20                 ,
                        D_ATTRIBUTE1                  ,
                        D_ATTRIBUTE2                  ,
                        D_ATTRIBUTE3                  ,
                        D_ATTRIBUTE4                  ,
                        D_ATTRIBUTE5                  ,
                        D_ATTRIBUTE6                  ,
                        D_ATTRIBUTE7                  ,
                        D_ATTRIBUTE8                  ,
                        D_ATTRIBUTE9                  ,
                        D_ATTRIBUTE10                 ,
                        N_ATTRIBUTE1                  ,
                        N_ATTRIBUTE2                  ,
                        N_ATTRIBUTE3                  ,
                        N_ATTRIBUTE4                  ,
                        N_ATTRIBUTE5                  ,
                        N_ATTRIBUTE6                  ,
                        N_ATTRIBUTE7                  ,
                        N_ATTRIBUTE8                  ,
                        N_ATTRIBUTE9                  ,
                        N_ATTRIBUTE10                 ,
                        VENDOR_ID                     ,
                        TERRITORY_CODE                ,
                        PRODUCT_CODE                  ,
                        PRODUCT_TRANSACTION_ID        ,
                        ATTRIBUTE_CATEGORY            ,
                        ATTRIBUTE1                    ,
                        ATTRIBUTE2                    ,
                        ATTRIBUTE3                    ,
                        ATTRIBUTE4                    ,
                        ATTRIBUTE5                    ,
                        ATTRIBUTE6                    ,
                        ATTRIBUTE7                    ,
                        ATTRIBUTE8                    ,
                        ATTRIBUTE9                    ,
                        ATTRIBUTE10                   ,
                        ATTRIBUTE11                   ,
                        ATTRIBUTE12                   ,
                        ATTRIBUTE13                   ,
                        ATTRIBUTE14                   ,
                        ATTRIBUTE15                   --,
                        --PARENT_LOT_NUMBER
                        from MTL_TRANSACTION_LOT_NUMBERS
                       --Bug 5614015:Rowid is used to uniquely identify the lot selected
                        --where transaction_id = l_mmt_rec.transaction_id
                        --and   lot_number     = l_lot_txn_rec.lot_number;
                        where rowid = l_lot_txn_rec.rowid;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Inserted : ' || SQL%ROWCOUNT
                                                                                || ' rows into MTLT for lot '
                                                                                || l_lot_txn_rec.lot_number,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 130;
                        if nvl(l_serial_txn_id,0) <> 0 then

                                l_stmt_num := 140;
                                insert into mtl_serial_numbers_temp
                                (
                                TRANSACTION_TEMP_ID                  ,
                                LAST_UPDATE_DATE                     ,
                                LAST_UPDATED_BY                      ,
                                CREATION_DATE                        ,
                                CREATED_BY                           ,
                                LAST_UPDATE_LOGIN                    ,
                                REQUEST_ID                           ,
                                PROGRAM_APPLICATION_ID               ,
                                PROGRAM_ID                           ,
                                PROGRAM_UPDATE_DATE                  ,
                                --VENDOR_SERIAL_NUMBER                 ,
                                --VENDOR_LOT_NUMBER                    ,
                                FM_SERIAL_NUMBER                     ,
                                TO_SERIAL_NUMBER                     ,
                                --SERIAL_PREFIX                      ,
                                --ERROR_CODE                         ,
                                --GROUP_HEADER_ID                    ,
                                PARENT_SERIAL_NUMBER                 ,
                                SERIAL_ATTRIBUTE_CATEGORY            ,
                                ORIGINATION_DATE                     ,
                                C_ATTRIBUTE1                         ,
                                C_ATTRIBUTE2                         ,
                                C_ATTRIBUTE3                         ,
                                C_ATTRIBUTE4                         ,
                                C_ATTRIBUTE5                         ,
                                C_ATTRIBUTE6                         ,
                                C_ATTRIBUTE7                         ,
                                C_ATTRIBUTE8                         ,
                                C_ATTRIBUTE9                         ,
                                C_ATTRIBUTE10                        ,
                                C_ATTRIBUTE11                        ,
                                C_ATTRIBUTE12                        ,
                                C_ATTRIBUTE13                        ,
                                C_ATTRIBUTE14                        ,
                                C_ATTRIBUTE15                        ,
                                C_ATTRIBUTE16                        ,
                                C_ATTRIBUTE17                        ,
                                C_ATTRIBUTE18                        ,
                                C_ATTRIBUTE19                        ,
                                C_ATTRIBUTE20                        ,
                                D_ATTRIBUTE1                         ,
                                D_ATTRIBUTE2                         ,
                                D_ATTRIBUTE3                         ,
                                D_ATTRIBUTE4                         ,
                                D_ATTRIBUTE5                         ,
                                D_ATTRIBUTE6                         ,
                                D_ATTRIBUTE7                         ,
                                D_ATTRIBUTE8                         ,
                                D_ATTRIBUTE9                         ,
                                D_ATTRIBUTE10                        ,
                                N_ATTRIBUTE1                         ,
                                N_ATTRIBUTE2                         ,
                                N_ATTRIBUTE3                         ,
                                N_ATTRIBUTE4                         ,
                                N_ATTRIBUTE5                         ,
                                N_ATTRIBUTE6                         ,
                                N_ATTRIBUTE7                         ,
                                N_ATTRIBUTE8                         ,
                                N_ATTRIBUTE9                         ,
                                N_ATTRIBUTE10                        ,
                                STATUS_ID                            ,
                                TERRITORY_CODE                       ,
                                TIME_SINCE_NEW                       ,
                                CYCLES_SINCE_NEW                     ,
                                TIME_SINCE_OVERHAUL                  ,
                                CYCLES_SINCE_OVERHAUL                ,
                                TIME_SINCE_REPAIR                    ,
                                CYCLES_SINCE_REPAIR                  ,
                                TIME_SINCE_VISIT                     ,
                                CYCLES_SINCE_VISIT                   ,
                                TIME_SINCE_MARK                      ,
                                CYCLES_SINCE_MARK                    ,
                                NUMBER_OF_REPAIRS                    ,
                                PRODUCT_CODE                         ,
                                PRODUCT_TRANSACTION_ID               ,
                                ATTRIBUTE_CATEGORY                   ,
                                ATTRIBUTE1                           ,
                                ATTRIBUTE2                           ,
                                ATTRIBUTE3                           ,
                                ATTRIBUTE4                           ,
                                ATTRIBUTE5                           ,
                                ATTRIBUTE6                           ,
                                ATTRIBUTE7                           ,
                                ATTRIBUTE8                           ,
                                ATTRIBUTE9                           ,
                                ATTRIBUTE10                          ,
                                ATTRIBUTE11                          ,
                                ATTRIBUTE12                          ,
                                ATTRIBUTE13                          ,
                                ATTRIBUTE14                          ,
                                ATTRIBUTE15                          ,
                                DFF_UPDATED_FLAG
                                --PARENT_LOT_NUMBER
                                )
                                select
                                l_serial_txn_id                                      ,
                                sysdate                                              ,
                                l_user_id                                            ,
                                sysdate                                              ,
                                l_user_id                                            ,
                                l_login_id                                           ,
                                l_req_id                                             ,
                                l_prog_appl_id                                       ,
                                l_prog_id                                            ,
                                sysdate                                              ,
                                --VENDOR_SERIAL_NUMBER                                 ,
                                --VENDOR_LOT_NUMBER                                    ,
                                MUT.SERIAL_NUMBER                                       ,
                                MUT.SERIAL_NUMBER                                       ,
                                --SERIAL_PREFIX                                     ,
                                --ERROR_CODE                                        ,
                                --GROUP_HEADER_ID                                   ,
                                MSN.PARENT_SERIAL_NUMBER                                ,
                                --END_ITEM_UNIT_NUMBER                                ,
                                MUT.SERIAL_ATTRIBUTE_CATEGORY                           ,
                                MUT.ORIGINATION_DATE                                    ,
                                MUT.C_ATTRIBUTE1                                        ,
                                MUT.C_ATTRIBUTE2                                        ,
                                MUT.C_ATTRIBUTE3                                        ,
                                MUT.C_ATTRIBUTE4                                        ,
                                MUT.C_ATTRIBUTE5                                        ,
                                MUT.C_ATTRIBUTE6                                        ,
                                MUT.C_ATTRIBUTE7                                        ,
                                MUT.C_ATTRIBUTE8                                        ,
                                MUT.C_ATTRIBUTE9                                        ,
                                MUT.C_ATTRIBUTE10                                       ,
                                MUT.C_ATTRIBUTE11                                       ,
                                MUT.C_ATTRIBUTE12                                       ,
                                MUT.C_ATTRIBUTE13                                       ,
                                MUT.C_ATTRIBUTE14                                       ,
                                MUT.C_ATTRIBUTE15                                       ,
                                MUT.C_ATTRIBUTE16                                       ,
                                MUT.C_ATTRIBUTE17                                       ,
                                MUT.C_ATTRIBUTE18                                       ,
                                MUT.C_ATTRIBUTE19                                       ,
                                MUT.C_ATTRIBUTE20                                       ,
                                MUT.D_ATTRIBUTE1                                        ,
                                MUT.D_ATTRIBUTE2                                        ,
                                MUT.D_ATTRIBUTE3                                        ,
                                MUT.D_ATTRIBUTE4                                        ,
                                MUT.D_ATTRIBUTE5                                        ,
                                MUT.D_ATTRIBUTE6                                        ,
                                MUT.D_ATTRIBUTE7                                        ,
                                MUT.D_ATTRIBUTE8                                        ,
                                MUT.D_ATTRIBUTE9                                        ,
                                MUT.D_ATTRIBUTE10                                       ,
                                MUT.N_ATTRIBUTE1                                        ,
                                MUT.N_ATTRIBUTE2                                        ,
                                MUT.N_ATTRIBUTE3                                        ,
                                MUT.N_ATTRIBUTE4                                        ,
                                MUT.N_ATTRIBUTE5                                        ,
                                MUT.N_ATTRIBUTE6                                        ,
                                MUT.N_ATTRIBUTE7                                        ,
                                MUT.N_ATTRIBUTE8                                        ,
                                MUT.N_ATTRIBUTE9                                        ,
                                MUT.N_ATTRIBUTE10                                       ,
                                MUT.STATUS_ID                                           ,
                                MUT.TERRITORY_CODE                                      ,
                                MUT.TIME_SINCE_NEW                                      ,
                                MUT.CYCLES_SINCE_NEW                                    ,
                                MUT.TIME_SINCE_OVERHAUL                                 ,
                                MUT.CYCLES_SINCE_OVERHAUL                               ,
                                MUT.TIME_SINCE_REPAIR                                   ,
                                MUT.CYCLES_SINCE_REPAIR                                 ,
                                MUT.TIME_SINCE_VISIT                                    ,
                                MUT.CYCLES_SINCE_VISIT                                  ,
                                MUT.TIME_SINCE_MARK                                     ,
                                MUT.CYCLES_SINCE_MARK                                   ,
                                MUT.NUMBER_OF_REPAIRS                                   ,
                                MUT.PRODUCT_CODE                                        ,
                                MUT.PRODUCT_TRANSACTION_ID                              ,
                                MUT.ATTRIBUTE_CATEGORY                                  ,
                                MUT.ATTRIBUTE1                                          ,
                                MUT.ATTRIBUTE2                                          ,
                                MUT.ATTRIBUTE3                                          ,
                                MUT.ATTRIBUTE4                                          ,
                                MUT.ATTRIBUTE5                                          ,
                                MUT.ATTRIBUTE6                                          ,
                                MUT.ATTRIBUTE7                                          ,
                                MUT.ATTRIBUTE8                                          ,
                                MUT.ATTRIBUTE9                                          ,
                                MUT.ATTRIBUTE10                                         ,
                                MUT.ATTRIBUTE11                                         ,
                                MUT.ATTRIBUTE12                                         ,
                                MUT.ATTRIBUTE13                                         ,
                                MUT.ATTRIBUTE14                                         ,
                                MUT.ATTRIBUTE15                                         ,
                                decode(nvl(MUT.ATTRIBUTE_CATEGORY,-1),-1,'N','Y')
                                from mtl_unit_transactions MUT,
                                     mtl_serial_numbers MSN
                                where MUT.transaction_id = l_lot_txn_rec.serial_transaction_id
                                and   MUT.serial_number = MSN.serial_number
                                and   MSN.current_organization_id = MUT.ORGANIZATION_ID
                                and   msn.last_transaction_id = l_mmt_rec.transaction_id; --l_lot_txn_rec.serial_transaction_id;

                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Inserted : ' || SQL%ROWCOUNT
                                                                                        || ' rows into MSTT(Serial)',
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;
                        end if;

                   end loop;

                   l_stmt_num := 150;
                   if l_lot_controlled = 0 then

                           l_stmt_num := 160;
                           -- insert the records for serial controlled assemblies...
                           insert into mtl_serial_numbers_temp
                           (
                                TRANSACTION_TEMP_ID                                 ,
                                LAST_UPDATE_DATE                                    ,
                                LAST_UPDATED_BY                                     ,
                                CREATION_DATE                                       ,
                                CREATED_BY                                          ,
                                LAST_UPDATE_LOGIN                                   ,
                                REQUEST_ID                                          ,
                                PROGRAM_APPLICATION_ID                              ,
                                PROGRAM_ID                                          ,
                                PROGRAM_UPDATE_DATE                                 ,
                                --VENDOR_SERIAL_NUMBER                                ,
                                --VENDOR_LOT_NUMBER                                   ,
                                FM_SERIAL_NUMBER                                    ,
                                TO_SERIAL_NUMBER                                    ,
                                --SERIAL_PREFIX                                     ,
                                --ERROR_CODE                                        ,
                                --GROUP_HEADER_ID                                   ,
                                PARENT_SERIAL_NUMBER                                ,
                                --END_ITEM_UNIT_NUMBER                                ,
                                SERIAL_ATTRIBUTE_CATEGORY                            ,
                                ORIGINATION_DATE                                    ,
                                C_ATTRIBUTE1                                        ,
                                C_ATTRIBUTE2                                        ,
                                C_ATTRIBUTE3                                        ,
                                C_ATTRIBUTE4                                        ,
                                C_ATTRIBUTE5                                        ,
                                C_ATTRIBUTE6                                        ,
                                C_ATTRIBUTE7                                        ,
                                C_ATTRIBUTE8                                        ,
                                C_ATTRIBUTE9                                        ,
                                C_ATTRIBUTE10                                       ,
                                C_ATTRIBUTE11                                       ,
                                C_ATTRIBUTE12                                       ,
                                C_ATTRIBUTE13                                       ,
                                C_ATTRIBUTE14                                       ,
                                C_ATTRIBUTE15                                       ,
                                C_ATTRIBUTE16                                       ,
                                C_ATTRIBUTE17                                       ,
                                C_ATTRIBUTE18                                       ,
                                C_ATTRIBUTE19                                       ,
                                C_ATTRIBUTE20                                       ,
                                D_ATTRIBUTE1                                        ,
                                D_ATTRIBUTE2                                        ,
                                D_ATTRIBUTE3                                        ,
                                D_ATTRIBUTE4                                        ,
                                D_ATTRIBUTE5                                        ,
                                D_ATTRIBUTE6                                        ,
                                D_ATTRIBUTE7                                        ,
                                D_ATTRIBUTE8                                        ,
                                D_ATTRIBUTE9                                        ,
                                D_ATTRIBUTE10                                       ,
                                N_ATTRIBUTE1                                        ,
                                N_ATTRIBUTE2                                        ,
                                N_ATTRIBUTE3                                        ,
                                N_ATTRIBUTE4                                        ,
                                N_ATTRIBUTE5                                        ,
                                N_ATTRIBUTE6                                        ,
                                N_ATTRIBUTE7                                        ,
                                N_ATTRIBUTE8                                        ,
                                N_ATTRIBUTE9                                        ,
                                N_ATTRIBUTE10                                       ,
                                STATUS_ID                                           ,
                                TERRITORY_CODE                                      ,
                                TIME_SINCE_NEW                                      ,
                                CYCLES_SINCE_NEW                                    ,
                                TIME_SINCE_OVERHAUL                                 ,
                                CYCLES_SINCE_OVERHAUL                               ,
                                TIME_SINCE_REPAIR                                   ,
                                CYCLES_SINCE_REPAIR                                 ,
                                TIME_SINCE_VISIT                                    ,
                                CYCLES_SINCE_VISIT                                  ,
                                TIME_SINCE_MARK                                     ,
                                CYCLES_SINCE_MARK                                   ,
                                NUMBER_OF_REPAIRS                                   ,
                                PRODUCT_CODE                                        ,
                                PRODUCT_TRANSACTION_ID                              ,
                                ATTRIBUTE_CATEGORY                                  ,
                                ATTRIBUTE1                                          ,
                                ATTRIBUTE2                                          ,
                                ATTRIBUTE3                                          ,
                                ATTRIBUTE4                                          ,
                                ATTRIBUTE5                                          ,
                                ATTRIBUTE6                                          ,
                                ATTRIBUTE7                                          ,
                                ATTRIBUTE8                                          ,
                                ATTRIBUTE9                                          ,
                                ATTRIBUTE10                                         ,
                                ATTRIBUTE11                                         ,
                                ATTRIBUTE12                                         ,
                                ATTRIBUTE13                                         ,
                                ATTRIBUTE14                                         ,
                                ATTRIBUTE15                                         ,
                                DFF_UPDATED_FLAG
                                --PARENT_LOT_NUMBER
                            )
                            select
                                l_temp_id                                           ,
                                sysdate                                             ,
                                l_user_id                                           ,
                                sysdate                                             ,
                                l_user_id                                           ,
                                l_login_id                                          ,
                                l_req_id                                            ,
                                l_prog_appl_id                                      ,
                                l_prog_id                                           ,
                                sysdate                                             ,
                                --VENDOR_SERIAL_NUMBER                                ,
                                --VENDOR_LOT_NUMBER                                   ,
                                MUT.SERIAL_NUMBER                                       ,
                                MUT.SERIAL_NUMBER                                       ,
                                --SERIAL_PREFIX                                     ,
                                --ERROR_CODE                                        ,
                                --GROUP_HEADER_ID                                   ,
                                MSN.PARENT_SERIAL_NUMBER                                ,
                                --END_ITEM_UNIT_NUMBER                                ,
                                MUT.SERIAL_ATTRIBUTE_CATEGORY                           ,
                                MUT.ORIGINATION_DATE                                    ,
                                MUT.C_ATTRIBUTE1                                        ,
                                MUT.C_ATTRIBUTE2                                        ,
                                MUT.C_ATTRIBUTE3                                        ,
                                MUT.C_ATTRIBUTE4                                        ,
                                MUT.C_ATTRIBUTE5                                        ,
                                MUT.C_ATTRIBUTE6                                        ,
                                MUT.C_ATTRIBUTE7                                        ,
                                MUT.C_ATTRIBUTE8                                        ,
                                MUT.C_ATTRIBUTE9                                        ,
                                MUT.C_ATTRIBUTE10                                       ,
                                MUT.C_ATTRIBUTE11                                       ,
                                MUT.C_ATTRIBUTE12                                       ,
                                MUT.C_ATTRIBUTE13                                       ,
                                MUT.C_ATTRIBUTE14                                       ,
                                MUT.C_ATTRIBUTE15                                       ,
                                MUT.C_ATTRIBUTE16                                       ,
                                MUT.C_ATTRIBUTE17                                       ,
                                MUT.C_ATTRIBUTE18                                       ,
                                MUT.C_ATTRIBUTE19                                       ,
                                MUT.C_ATTRIBUTE20                                       ,
                                MUT.D_ATTRIBUTE1                                        ,
                                MUT.D_ATTRIBUTE2                                        ,
                                MUT.D_ATTRIBUTE3                                        ,
                                MUT.D_ATTRIBUTE4                                        ,
                                MUT.D_ATTRIBUTE5                                        ,
                                MUT.D_ATTRIBUTE6                                        ,
                                MUT.D_ATTRIBUTE7                                        ,
                                MUT.D_ATTRIBUTE8                                        ,
                                MUT.D_ATTRIBUTE9                                        ,
                                MUT.D_ATTRIBUTE10                                       ,
                                MUT.N_ATTRIBUTE1                                        ,
                                MUT.N_ATTRIBUTE2                                        ,
                                MUT.N_ATTRIBUTE3                                        ,
                                MUT.N_ATTRIBUTE4                                        ,
                                MUT.N_ATTRIBUTE5                                        ,
                                MUT.N_ATTRIBUTE6                                        ,
                                MUT.N_ATTRIBUTE7                                        ,
                                MUT.N_ATTRIBUTE8                                        ,
                                MUT.N_ATTRIBUTE9                                        ,
                                MUT.N_ATTRIBUTE10                                       ,
                                MUT.STATUS_ID                                           ,
                                MUT.TERRITORY_CODE                                      ,
                                MUT.TIME_SINCE_NEW                                      ,
                                MUT.CYCLES_SINCE_NEW                                    ,
                                MUT.TIME_SINCE_OVERHAUL                                 ,
                                MUT.CYCLES_SINCE_OVERHAUL                               ,
                                MUT.TIME_SINCE_REPAIR                                   ,
                                MUT.CYCLES_SINCE_REPAIR                                 ,
                                MUT.TIME_SINCE_VISIT                                    ,
                                MUT.CYCLES_SINCE_VISIT                                  ,
                                MUT.TIME_SINCE_MARK                                     ,
                                MUT.CYCLES_SINCE_MARK                                   ,
                                MUT.NUMBER_OF_REPAIRS                                   ,
                                MUT.PRODUCT_CODE                                        ,
                                MUT.PRODUCT_TRANSACTION_ID                              ,
                                MUT.ATTRIBUTE_CATEGORY                                  ,
                                MUT.ATTRIBUTE1                                          ,
                                MUT.ATTRIBUTE2                                          ,
                                MUT.ATTRIBUTE3                                          ,
                                MUT.ATTRIBUTE4                                          ,
                                MUT.ATTRIBUTE5                                          ,
                                MUT.ATTRIBUTE6                                          ,
                                MUT.ATTRIBUTE7                                          ,
                                MUT.ATTRIBUTE8                                          ,
                                MUT.ATTRIBUTE9                                          ,
                                MUT.ATTRIBUTE10                                         ,
                                MUT.ATTRIBUTE11                                         ,
                                MUT.ATTRIBUTE12                                         ,
                                MUT.ATTRIBUTE13                                         ,
                                MUT.ATTRIBUTE14                                         ,
                                MUT.ATTRIBUTE15                                         ,
                                decode(nvl(MUT.ATTRIBUTE_CATEGORY,-1),-1,'N','Y')
                                -- PARENT_LOT_NUMBER
                                from mtl_unit_transactions MUT,
                                     mtl_serial_numbers MSN
                                where MUT.transaction_id = l_mmt_rec.transaction_id
                                and   MUT.serial_number = MSN.serial_number
                                and   MSN.current_organization_id = MUT.ORGANIZATION_ID
                                and   msn.last_transaction_id = l_mmt_rec.transaction_id;

                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Inserted : ' || SQL%ROWCOUNT
                                                                                        || ' rows into MSTT(Serial)',
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;

                        end if;

          end loop;

exception

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );
        WHEN OTHERS THEN

                x_return_status := G_RET_UNEXPECTED;

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get( p_encoded     =>  'F'            ,
                                           p_count      =>  x_error_count   ,
                                           p_data       =>  x_error_msg
                                         );
END populate_components;

END WSM_Serial_support_GRP;

/
