--------------------------------------------------------
--  DDL for Package Body WSMPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLOAD" AS
/* $Header: WSMLOADB.pls 120.10.12010000.2 2008/09/02 06:11:44 sisankar ship $ */

/* Forward declaration of this PRIVATE PROCEDURE */

type t_wsm_wtxn_hdr_tbl is table of wsm_split_merge_txn_interface%rowtype index by binary_integer;
type t_wsm_wtxn_sj_tbl  is table of wsm_starting_jobs_interface%rowtype index by binary_integer;
type t_wsm_wtxn_rj_tbl  is table of wsm_resulting_jobs_interface%rowtype index by binary_integer;

type t_wtxn_hdr_id_tbl is table of wsm_split_merge_txn_interface.header_id%type index by binary_integer;
type t_wtxn_job_id_tbl is table of number index by binary_integer;
type t_wtxn_job_name_tbl is table of number index by wip_entities.wip_entity_name%type;

g_user_id               number;
g_user_login_id         number;
g_program_appl_id       number;
g_request_id            number;
g_program_id            number;

/*logging variables*/

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

g_ret_success       varchar2(1)    := FND_API.G_RET_STS_SUCCESS;
g_ret_error         varchar2(1)    := FND_API.G_RET_STS_ERROR;
g_ret_unexpected    varchar2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;

-- This procedure is used to add a errored job to the PL/SQL errored jobs table...
Procedure add_errored_jobs (p_error_job_name            IN            VARCHAR2                  ,
                            p_error_job_id              IN            NUMBER                    ,
                            p_error_org_id              IN            NUMBER                    ,
                            p_error_job_id_tbl          IN OUT NOCOPY t_wtxn_job_id_tbl         ,
                            p_error_job_name_tbl        IN OUT NOCOPY t_wtxn_job_name_tbl
                            )

IS

BEGIN
        IF p_error_job_id is not NULL and
           p_error_job_name is not NULL and
           p_error_org_id is not NULL
        THEN
                p_error_job_id_tbl(p_error_job_id) := 1;
                p_error_job_name_tbl(p_error_job_name) := p_error_org_id;

        ELSIF p_error_job_id is not NULL THEN -- Job Name is null
                p_error_job_id_tbl(p_error_job_id) := 1;

                DECLARE
                        l_wip_entity_name       WIP_ENTITIES.wip_entity_name%TYPE;
                        l_org_id                NUMBER;
                BEGIN
                        SELECT wip_entity_name,organization_id
                        into   l_wip_entity_name,l_org_id
                        FROM   WIP_ENTITIES
                        WHERE  wip_entity_id = p_error_job_id;

                        p_error_job_name_tbl(l_wip_entity_name) := l_org_id;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                null;
                END;

        ELSIF p_error_job_name is not NULL THEN -- Job id is NULL

                p_error_job_name_tbl(p_error_job_name) := p_error_org_id;

                DECLARE
                        l_wip_entity_id NUMBER;
                BEGIN
                        SELECT wip_entity_id
                        into   l_wip_entity_id
                        FROM   WIP_ENTITIES
                        WHERE  wip_entity_name = p_error_job_name
                        and    organization_id = p_error_org_id;

                        p_error_job_id_tbl(l_wip_entity_id) := 1;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                null;
                END;
        END IF;

END add_errored_jobs;


Procedure algo_create_copies (
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_error_msg      OUT NOCOPY VARCHAR2
                             ) is
    CURSOR C_ALGORITHM IS
    SELECT  distinct(wdj.wip_entity_id) wip_entity_id,
            wdj.organization_id,
            wdj.primary_item_id,
            wlbj.internal_copy_type,
            wlbj.copy_parent_wip_entity_id,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.routing_reference_id) routing_item_id, -- Fix for bug #3347947
            wdj.alternate_routing_designator alt_rtg_desig,-- Fix for bug #3347947
            wdj.common_routing_sequence_id,
            wdj.routing_revision_date,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.bom_reference_id) bill_item_id,-- Fix for bug #3347947
            wdj.alternate_bom_designator,
            WSMPUTIL.GET_JOB_BOM_SEQ_ID(wdj.wip_entity_id) bill_sequence_id,  -- Added : To fix bug #3286849
            wdj.common_bom_sequence_id,
            wdj.bom_revision_date,
            wdj.wip_supply_type
    FROM    wsm_lot_based_jobs wlbj,
            wip_discrete_jobs wdj,
            wsm_sm_resulting_jobs wsrj
    WHERE   wsrj.internal_group_id = WSMPLOAD.G_GROUP_ID
    AND     wsrj.wip_entity_id = wlbj.wip_entity_id
    AND     wlbj.wip_entity_id = wdj.wip_entity_id
    AND     wdj.status_type = 3 -- Released jobs
    AND     wlbj.internal_copy_type in (1, 2)
    ORDER BY wlbj.internal_copy_type;

    c_algorithm_rec C_ALGORITHM%ROWTYPE;

   CURSOR C_INF_SCH_PAR_REP_JOBS IS
    SELECT  distinct(wdj.wip_entity_id) wip_entity_id,
            wdj.organization_id,
            decode(wlbj.on_rec_path, 'Y', WIP_CONSTANTS.MIDPOINT_FORWARDS, WIP_CONSTANTS.CURRENT_OP) inf_sch_mode
    FROM    wsm_lot_based_jobs wlbj,
            wip_discrete_jobs wdj,
            wsm_sm_resulting_jobs wsrj
    WHERE   wsrj.internal_group_id = WSMPLOAD.G_GROUP_ID
    AND     wsrj.wip_entity_id = wlbj.wip_entity_id
    AND     wlbj.wip_entity_id = wdj.wip_entity_id
    AND     wdj.status_type = 3 -- Released jobs
    AND     wlbj.infinite_schedule = 'Y';

    c_inf_sch_par_rep_jobs_rec C_INF_SCH_PAR_REP_JOBS%ROWTYPE;


    l_job_op_seq_num        NUMBER;
    l_job_op_seq_id         NUMBER;
    l_job_std_op_id         NUMBER;
    l_job_intra_op          NUMBER;
    l_job_dept_id           NUMBER;
    l_job_qty               NUMBER;
    l_job_op_start_dt       DATE;
    l_job_op_comp_dt        DATE;

    l_return_code       number;
    l_return_status     VARCHAR2(1);
    l_error_code        NUMBER;
    l_error_msg         VARCHAR2(2000);
    l_error_count       NUMBER;

    --OPTII-PERF Changes
    l_phantom_exists    NUMBER;
    --OPTII-PERF Changes

    -- Logging variables.....
    l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
    l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num          NUMBER;
    l_module            VARCHAR2(100) := 'wsm.plsql.WSMPLOAD.algo_create_copies';
    -- Logging variables...

begin

    --Start ALGORITHM : Additions for APS-WLT --
    SAVEPOINT s_process_one_wlt;

    --    If l_debug = 'Y' Then
    --        l_stmt_num := 47.1;
    --
    --        SELECT  count(distinct(wdj.wip_entity_id))
    --        INTO    l_temp
    --        FROM    wsm_lot_based_jobs wlbj,
    --                wip_discrete_jobs wdj,
    --                wsm_sm_resulting_jobs wsrj
    --        WHERE   wsrj.internal_group_id = WSMPLOAD.G_GROUP_ID
    --        AND     wsrj.wip_entity_id = wlbj.wip_entity_id
    --        AND     wlbj.wip_entity_id = wdj.wip_entity_id
    --        AND     wdj.status_type = 3 -- Released jobs
    --        AND     wlbj.internal_copy_type in (1, 2);
    --
    --        FND_FILE.put_line(FND_FILE.log, '1. Start ALGORITHM for making copies to work on '||l_temp||' jobs');
    --
    --    End If;
    --
     OPEN C_ALGORITHM;
     LOOP
            l_stmt_num := 10;
            FETCH C_ALGORITHM INTO c_algorithm_rec;
            EXIT WHEN C_ALGORITHM%NOTFOUND;


            -- If l_debug = 'Y' Then
            --     FND_FILE.put_line(FND_FILE.log, 'Processing for we_id='||c_algorithm_rec.wip_entity_id||
            --                         ', internal_copy_type='||c_algorithm_rec.internal_copy_type||
            --                         ', copy_parent_wip_entity_id='||c_algorithm_rec.copy_parent_wip_entity_id);
            -- End If;


            IF (c_algorithm_rec.internal_copy_type = 1) THEN

                -- If l_debug = 'Y' Then
                --     FND_FILE.put_line(FND_FILE.log, 'Calling WSM_JobCopies_PVT.Create_RepJobCopies');
                -- End If;

                l_stmt_num := 47.2;

                l_error_code := 0;

                WSM_JobCopies_PVT.Create_RepJobCopies
                          (x_err_buf              => l_error_msg,
                           x_err_code             => l_error_code,
                           p_rep_wip_entity_id    => c_algorithm_rec.copy_parent_wip_entity_id,
                           p_new_wip_entity_id    => c_algorithm_rec.wip_entity_id,
                           p_last_update_date     => sysdate,
                           p_last_updated_by      => FND_GLOBAL.USER_ID,
                           p_last_update_login    => FND_GLOBAL.LOGIN_ID,
                           p_creation_date        => sysdate,
                           p_created_by           => FND_GLOBAL.USER_ID,
                           p_request_id           => FND_GLOBAL.CONC_REQUEST_ID,
                           p_program_app_id       => FND_GLOBAL.PROG_APPL_ID,
                           p_program_id           => FND_GLOBAL.CONC_PROGRAM_ID,
                           p_program_update_date  => sysdate,
                           p_inf_sch_flag         => 'Y',
                           p_inf_sch_mode         => NULL,
                           p_inf_sch_date         => NULL
                          );

                IF (l_error_code <> 0) THEN
                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_JobCopies_PVT.Create_RepJobCopies returned error:'||l_error_msg,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;

                ELSE
                    if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_JobCopies_PVT.Create_RepJobCopies returned success',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                    End if;
                END IF;

            ELSIF (c_algorithm_rec.internal_copy_type = 2) THEN
                if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Calling WSM_JobCopies_PVT.Create_JobCopies',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                End if;

                -- OPTII-PERF: Find if phantom exists or not.
                BEGIN
                         select 1 into l_phantom_exists
                         from  bom_inventory_components
                         where bill_sequence_id = c_algorithm_rec.common_bom_sequence_id
                         and   c_algorithm_rec.bom_revision_date between effectivity_date and
                                        nvl(disable_date,c_algorithm_rec.bom_revision_date+1)
                         and   wip_supply_type = 6
                         and   rownum = 1;

                         l_phantom_exists := 1;
                EXCEPTION
                        WHEN OTHERS THEN
                           l_phantom_exists := 2;
                end;
                -- OPTII-PERF: Find if phantom exists or not.

                l_stmt_num := 47.3;


                WSM_JobCopies_PVT.Create_JobCopies  -- Call #1
                        (x_err_buf              => l_error_msg,
                         x_err_code             => l_error_code,
                         p_wip_entity_id        => c_algorithm_rec.wip_entity_id,
                         p_org_id               => c_algorithm_rec.organization_id,
                         p_primary_item_id      => c_algorithm_rec.primary_item_id,

                         p_routing_item_id      => c_algorithm_rec.routing_item_id,-- Fix for bug #3347947
                         p_alt_rtg_desig        => c_algorithm_rec.alt_rtg_desig,-- Fix for bug #3347947
                         p_rtg_seq_id           => NULL,-- Will be NULL till reqd for some functionality
                         p_common_rtg_seq_id    => c_algorithm_rec.common_routing_sequence_id,
                         p_rtg_rev_date         => c_algorithm_rec.routing_revision_date,
                         p_bill_item_id         => c_algorithm_rec.bill_item_id,-- Fix for bug #3347947
                         p_alt_bom_desig        => c_algorithm_rec.alternate_bom_designator,
                         p_bill_seq_id          => c_algorithm_rec.bill_sequence_id,-- To fix bug #3286849
                         p_common_bill_seq_id   => c_algorithm_rec.common_bom_sequence_id,

                         p_bom_rev_date         => c_algorithm_rec.bom_revision_date,
                         p_wip_supply_type      => c_algorithm_rec.wip_supply_type,
                         p_last_update_date     => sysdate,
                         p_last_updated_by      => FND_GLOBAL.USER_ID,
                         p_last_update_login    => FND_GLOBAL.LOGIN_ID,
                         p_creation_date        => sysdate,
                         p_created_by           => FND_GLOBAL.USER_ID,
                         p_request_id           => FND_GLOBAL.CONC_REQUEST_ID,
                         p_program_app_id       => FND_GLOBAL.PROG_APPL_ID,
                         p_program_id           => FND_GLOBAL.CONC_PROGRAM_ID,
                         p_program_update_date  => sysdate,
                         p_inf_sch_flag         => 'Y',
                         p_inf_sch_mode         => NULL, -- Create_JobCopies to figure out
                         p_inf_sch_date         => NULL,  -- Create_JobCopies to figure out

                         --OPTII-PERF Changes
                         p_charges_exist        => 1,
                         p_phantom_exists       => l_phantom_exists,
                         p_insert_wip           => 2
                         --OPTII-PERF Changes
                        );

                -- Fixed bug #3303267 : Checked the return value based on changed error codes
                -- IF (x_err_code <> 0) THEN
                IF (l_error_code = 0) OR
                   (l_error_code IS NULL) OR -- No error
                   (l_error_code = -1)    -- Warning
                THEN
                    if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned success',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                    End if;
                ELSE
                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_JobCopies_PVT.Create_JobCopies returned error:'||l_error_msg,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- x_err_code := 0;    -- Fix for bug #3421662 --
            END IF;

            l_stmt_num := 47.4;

            UPDATE  wsm_lot_based_jobs
            SET     internal_copy_type = 0,
                    copy_parent_wip_entity_id = NULL
            WHERE   wip_entity_id = c_algorithm_rec.wip_entity_id;

            if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Reset internal_copy_type, copy_parent_wip_entity_id for we_id='||c_algorithm_rec.wip_entity_id,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
            End if;

        END LOOP; --C_ALGORITHM
        CLOSE C_ALGORITHM;

        l_stmt_num := 47.5;

        -- Call Infinite Scheduler to schedule parent rep jobs in Split/Merge transactions
        OPEN C_INF_SCH_PAR_REP_JOBS;
        LOOP
            l_stmt_num := 47.6;
            FETCH C_INF_SCH_PAR_REP_JOBS INTO c_inf_sch_par_rep_jobs_rec;
            EXIT WHEN C_INF_SCH_PAR_REP_JOBS%NOTFOUND;

            if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Calling WSMPJUPD.GET_JOB_CURR_OP_INFO',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
            End if;

            WSMPJUPD.GET_JOB_CURR_OP_INFO
                            (p_wip_entity_id        => c_inf_sch_par_rep_jobs_rec.wip_entity_id,
                             p_op_seq_num           => l_job_op_seq_num,
                             p_op_seq_id            => l_job_op_seq_id,
                             p_std_op_id            => l_job_std_op_id,
                             p_intra_op             => l_job_intra_op,
                             p_dept_id              => l_job_dept_id,
                             p_op_qty               => l_job_qty,
                             p_op_start_date        => l_job_op_start_dt,
                             p_op_completion_date   => l_job_op_comp_dt,
                             x_err_code             => l_error_code,
                             x_err_buf              => l_error_msg,
                             x_msg_count            => x_msg_count);

            IF (l_error_code <> 0) THEN
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSMPJUPD.GET_JOB_CURR_OP_INFO returned error:'||l_error_code,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

            END IF;

            l_stmt_num := 47.7;

            if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Calling WSM_infinite_scheduler_PVT.schedule',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
            End if;

            WSM_infinite_scheduler_PVT.schedule
                    (
                     p_initMsgList   => FND_API.g_true,
                     p_endDebug      => FND_API.g_true,
                     p_orgID         => c_inf_sch_par_rep_jobs_rec.organization_id,
                     p_wipEntityID   => c_inf_sch_par_rep_jobs_rec.wip_entity_id,
                     p_scheduleMode  => c_inf_sch_par_rep_jobs_rec.inf_sch_mode,
                     p_startDate     => l_job_op_start_dt,
                     p_endDate       => NULL,
                     p_opSeqNum      => 0-l_job_op_seq_num,
                     p_resSeqNum     => NULL,
                     x_returnStatus  => l_return_status,
                     x_errorMsg      => l_error_msg
                    );

            IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                -- x_error_code := -1;
                IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_infinite_scheduler_PVT.schedule returned error:'||l_error_msg,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                -- x_error_code := 0;
                if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_infinite_scheduler_PVT.schedule returned success',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                End if;

            END IF;

        END LOOP; --C_INF_SCH_PAR_REP_JOBS
        CLOSE C_INF_SCH_PAR_REP_JOBS;

exception
        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (p_encoded    => 'F'          ,
                                           p_count      => x_msg_count  ,
                                           p_data       => x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get ( p_encoded   => 'F'         ,
                                            p_count     => x_msg_count ,
                                            p_data      => x_error_msg
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

                FND_MSG_PUB.Count_And_Get (  p_encoded  => 'F'          ,
                                             p_count    => x_msg_count  ,
                                             p_data     => x_error_msg
                                          );
end;

--Start: Changes for APS-WLT: Added overloaded procedure --
PROCEDURE LOAD(ERRBUF       OUT NOCOPY VARCHAR2,
               RETCODE      OUT NOCOPY NUMBER,
               p_copy_qa     IN VARCHAR2, -- not needed
               p_group_id    IN NUMBER -- DEFAULT NULL
               )
IS
BEGIN
    LOAD(ERRBUF, RETCODE, p_copy_qa, p_group_id, 1);
END;
--End: Changes for APS-WLT: Added overloaded procedure --


PROCEDURE LOAD(ERRBUF       OUT NOCOPY VARCHAR2,
               RETCODE      OUT NOCOPY NUMBER,
               p_copy_qa     IN VARCHAR2, -- not needed
               p_group_id    IN NUMBER,
               p_copy_flag   IN NUMBER -- 1=> copies after each transaction, 2=> copies at end
                                       -- Added this flag for APS-WLT
               )
IS
    l_header_id               NUMBER;
    l_group_id                NUMBER;
    l_txn_id                  NUMBER;
    l_msg_count               NUMBER;
    l_error_msg               VARCHAR2(2000);
    l_error_txn               number := 0;

    -- Logging variables.....
    l_msg_tokens              WSM_Log_PVT.token_rec_tbl;
    l_log_level               number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_stmt_num                NUMBER;
    l_module                  VARCHAR2(100) := 'wsm.plsql.WSMPLOAD.load';
    -- Logging variables...

    l_internal_group_id       NUMBER;

    l_profile_value           NUMBER; -- Added for APS-WLT: This implies Option A - old behavior
    l_del_int_prof_value      NUMBER; -- Added for APS-WLT: Contains value of profile WSM_INTERFACE_HISTORY_DAYS

    l_wsm_wtxn_hdr_tbl        t_wsm_wtxn_hdr_tbl;
    l_wsm_wtxn_sj_tbl         t_wsm_wtxn_sj_tbl;
    l_wsm_wtxn_rj_tbl         t_wsm_wtxn_rj_tbl;

    l_txn_header_rec          WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE;
    l_starting_jobs_tbl       WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE;
    l_resulting_jobs_tbl      WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE;
    l_secondary_qty_tbl       WSM_WIP_LOT_TXN_PVT.WSM_JOB_SECONDARY_QTY_TBL_TYPE;
    l_wsm_serial_num_tbl      WSM_SERIAL_SUPPORT_GRP.WSM_SERIAL_NUM_TBL;

    l_txn_status_tbl          t_wtxn_hdr_id_tbl;
    l_txn_header_tbl          t_wtxn_hdr_id_tbl;
    l_errored_job_id_tbl      t_wtxn_job_id_tbl;
    l_errored_job_name_tbl    t_wtxn_job_name_tbl;
    l_txn_id_tbl              t_wtxn_job_id_tbl;

    l_txn_counter             NUMBER := 0 ; --ADD AH
    l_counter                 NUMBER := 0; --ADD AH
    l_sj_counter              number;
    l_sj_api_counter          number;
    l_rj_counter              number;
    l_rj_api_counter          number;
    l_conc_status             BOOLEAN;
    l_tmp_org_id              number;
    l_return_code             number;
    l_return_status           varchar2(1);
    l_poreq_request_id        number;

    l_rep_job_index           number;
    l_index                   number ;

    l_st_lot_number           varchar2(100);
    l_st_inv_item_id          number;
    L_PROGRAM_STATUS          NUMBER := null;
    l_txn_processed           number := 0;
    l_dummy                   number;

    l_mo_org_id                     NUMBER;                                   -- Add: bug5485653
    l_ou_id                         NUMBER;                                   -- Add: bug5485653
    l_org_acct_ctxt                 VARCHAR2(30):= 'Accounting Information';  -- Add: bug5485653

    -- ST : Added for bug 5297923
    e_invalid_job_data        exception;
    cursor c_pending_txn_header is
    select  *
    from wsm_split_merge_txn_interface wsmti
    where nvl(wsmti.group_id,-99999) = nvl(nvl(p_group_id,wsmti.group_id),-99999)
    and   wsmti.transaction_date <= sysdate
    and   wsmti.process_status =  WIP_CONSTANTS.PENDING
    order by transaction_date,header_id;

BEGIN
    l_stmt_num := 5;
    g_user_id                   := FND_GLOBAL.USER_ID;
    g_user_login_id             := FND_GLOBAL.LOGIN_ID;
    g_program_appl_id           := FND_GLOBAL.PROG_APPL_ID;
    g_request_id                := FND_GLOBAL.CONC_REQUEST_ID;
    g_program_id                := FND_GLOBAL.CONC_PROGRAM_ID;

    -- FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered LOAD procedure'); --Remove
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Entered LOAD procedure' ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    -- To get Option A or Option C
    l_profile_value := 1;

    -- In case of option A no copies...
    -- can replace the global with local ones.....
    IF (l_profile_value = 2) THEN
        WSMPJUPD.g_copy_mode := 0;       -- Dont make copies
    ELSE
        WSMPJUPD.g_copy_mode := p_copy_flag; -- Make copies based on p_copy_flag
    END IF;

    l_stmt_num := 10;
    select wsm_sm_txn_int_group_s.nextval into l_internal_group_id from dual;

    /* do you need this ... global variable.... */
    WSMPLOAD.G_GROUP_ID := l_internal_group_id; -- WLTEnh add

    /* Start the loop here.... */
    loop
            l_wsm_wtxn_hdr_tbl.delete;
            l_wsm_wtxn_sj_tbl.delete;
            l_wsm_wtxn_rj_tbl.delete;

            l_txn_status_tbl.delete;
            l_txn_header_tbl.delete;


            open c_pending_txn_header;
            fetch c_pending_txn_header bulk collect into l_wsm_wtxn_hdr_tbl
            limit 1000; -- hard coded this .. change to a profile...
            close c_pending_txn_header;


            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'The no of records in WSMTI: -> '
                                                                ||l_wsm_wtxn_hdr_tbl.count      ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            if l_wsm_wtxn_hdr_tbl.count = 0 then -- No records retrieved.. exit..
                exit;
            end if;

            -- set the status for all the collected interface header records to RUNNING...
            DECLARE
                l_header_id_tbl t_wtxn_job_id_tbl;
            BEGIN

                l_index := l_wsm_wtxn_hdr_tbl.first;
                while l_index is not null loop
                        l_header_id_tbl(l_header_id_tbl.count + 1) := l_wsm_wtxn_hdr_tbl(l_index).header_id;
                        l_index := l_wsm_wtxn_hdr_tbl.next(l_index);
                end loop;

                -- Update..
                forall l_cntr in l_header_id_tbl.first..l_header_id_tbl.last
                        update wsm_split_merge_txn_interface wsmti
                        set process_status              = WIP_CONSTANTS.RUNNING,
                            group_id                    = decode(group_id, NULL, l_internal_group_id, p_group_id),
                            internal_group_id           = l_internal_group_id,
                            REQUEST_ID                  = g_request_id,
                            PROGRAM_UPDATE_DATE         = sysdate,
                            PROGRAM_APPLICATION_ID      = g_program_appl_id,
                            PROGRAM_ID                  = g_program_id,
                            LAST_UPDATE_DATE            = sysdate,
                            LAST_UPDATED_BY             = g_user_id,
                            LAST_UPDATE_LOGIN           = g_user_login_id,
                            transaction_id              = wsm_split_merge_transactions_s.nextval
                        where wsmti.header_id = l_header_id_tbl(l_cntr)
                        RETURNING transaction_id BULK COLLECT into l_txn_id_tbl;
            END;
            -- Completed setting the status...

            select wsji.*
            bulk collect into l_wsm_wtxn_sj_tbl
            from wsm_starting_jobs_interface wsji,
                 wsm_split_merge_txn_interface wsmti
            where wsji.header_id = wsmti.header_id
            and   wsmti.process_status =  WIP_CONSTANTS.RUNNING
            and   wsji.process_status  =  WIP_CONSTANTS.PENDING
            and   wsmti.internal_group_id = l_internal_group_id
            and   wsmti.transaction_date <= sysdate
            order by wsmti.transaction_date,wsmti.header_id;

            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'The no of starting records : -> '
                                                                ||l_wsm_wtxn_sj_tbl.count       ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            select wrji.*
            bulk collect into l_wsm_wtxn_rj_tbl
            from wsm_resulting_jobs_interface wrji,
                 wsm_split_merge_txn_interface wsmti
            where wrji.header_id = wsmti.header_id
            and   wsmti.process_status =  WIP_CONSTANTS.RUNNING
            and   wrji.process_status  =  WIP_CONSTANTS.PENDING
            and   wsmti.internal_group_id = l_internal_group_id
            and   wsmti.transaction_date <= sysdate
            order by wsmti.transaction_date,wsmti.header_id;

            if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'The no of resulting records : -> '
                                                                ||l_wsm_wtxn_rj_tbl.count       ,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
            End if;

            update wsm_starting_jobs_interface wsji
            set process_status          = WIP_CONSTANTS.RUNNING,
                group_id                = decode(group_id, NULL, l_internal_group_id, p_group_id),
                internal_group_id       = l_internal_group_id,
                REQUEST_ID              = g_request_id,
                PROGRAM_UPDATE_DATE     = sysdate,
                PROGRAM_APPLICATION_ID  = g_program_appl_id,
                PROGRAM_ID              = g_program_id,
                LAST_UPDATE_DATE        = sysdate,
                LAST_UPDATED_BY         = g_user_id,
                LAST_UPDATE_LOGIN       = g_user_login_id
            where wsji.header_id in ( select header_id from
                                      wsm_split_merge_txn_interface wsmti
                                      where wsmti.process_status =  WIP_CONSTANTS.RUNNING
                                      and   wsmti.transaction_date <= sysdate
                                      and internal_group_id = l_internal_group_id
                                     )
            and   wsji.process_status =  WIP_CONSTANTS.PENDING;

            update wsm_resulting_jobs_interface wrji
            set process_status          = WIP_CONSTANTS.RUNNING,
                group_id                = decode(group_id, NULL, l_internal_group_id, p_group_id),
                internal_group_id       = l_internal_group_id,
                REQUEST_ID              = g_request_id,
                PROGRAM_UPDATE_DATE     = sysdate,
                PROGRAM_APPLICATION_ID  = g_program_appl_id,
                PROGRAM_ID              = g_program_id,
                LAST_UPDATE_DATE        = sysdate,
                LAST_UPDATED_BY         = g_user_id,
                LAST_UPDATE_LOGIN       = g_user_login_id
            where wrji.header_id in ( select header_id from
                                      wsm_split_merge_txn_interface wsmti
                                      where wsmti.process_status =  WIP_CONSTANTS.RUNNING
                                      and   wsmti.transaction_date <= sysdate
                                      and internal_group_id = l_internal_group_id
                                     )
            and   wrji.process_status =  WIP_CONSTANTS.PENDING;

            -- issue update statements for all the transactions...
            COMMIT;

            l_stmt_num := 35;
            l_sj_counter := l_wsm_wtxn_sj_tbl.first;
            l_rj_counter := l_wsm_wtxn_rj_tbl.first;

            -- check if this is being used or not....
            l_txn_counter := l_wsm_wtxn_hdr_tbl.first;

            while l_txn_counter is not null loop
            -- for l_txn_counter in l_wsm_wtxn_hdr_tbl.first..l_wsm_wtxn_hdr_tbl.last loop

                l_txn_header_rec := null;

                l_starting_jobs_tbl.delete;
                l_resulting_jobs_tbl.delete;

                -- ok here we assign the fields and invoke the API based on the txn type....
                -- Transaction info
                l_txn_header_rec.TRANSACTION_TYPE_ID            := l_wsm_wtxn_hdr_tbl(l_txn_counter).TRANSACTION_TYPE_ID;
                l_txn_header_rec.TRANSACTION_DATE               := l_wsm_wtxn_hdr_tbl(l_txn_counter).TRANSACTION_DATE;
                l_txn_header_rec.TRANSACTION_REFERENCE          := l_wsm_wtxn_hdr_tbl(l_txn_counter).TRANSACTION_REFERENCE;
                l_txn_header_rec.REASON_ID                      := l_wsm_wtxn_hdr_tbl(l_txn_counter).REASON_ID;

                -- select wsm_split_merge_transactions_s.nextval into l_txn_header_rec.transaction_id from dual;
                l_txn_header_rec.transaction_id                 := l_txn_id_tbl(l_txn_counter);

                l_txn_header_rec.ORGANIZATION_ID                := l_wsm_wtxn_hdr_tbl(l_txn_counter).ORGANIZATION_ID;

                l_txn_header_rec.ATTRIBUTE_CATEGORY             := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE_CATEGORY;
                l_txn_header_rec.ATTRIBUTE1                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE1;
                l_txn_header_rec.ATTRIBUTE2                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE2;
                l_txn_header_rec.ATTRIBUTE3                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE3;
                l_txn_header_rec.ATTRIBUTE4                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE4;
                l_txn_header_rec.ATTRIBUTE5                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE5;
                l_txn_header_rec.ATTRIBUTE6                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE6;
                l_txn_header_rec.ATTRIBUTE7                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE7;
                l_txn_header_rec.ATTRIBUTE8                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE8;
                l_txn_header_rec.ATTRIBUTE9                     := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE9;
                l_txn_header_rec.ATTRIBUTE10                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE10;
                l_txn_header_rec.ATTRIBUTE11                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE11;
                l_txn_header_rec.ATTRIBUTE12                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE12;
                l_txn_header_rec.ATTRIBUTE13                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE13;
                l_txn_header_rec.ATTRIBUTE14                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE14;
                l_txn_header_rec.ATTRIBUTE15                    := l_wsm_wtxn_hdr_tbl(l_txn_counter).ATTRIBUTE15;

                l_mo_org_id                                     := l_txn_header_rec.ORGANIZATION_ID; -- Add: bug5485653

                --populate the txn details for logging--

                -- bug 5557667 header_id and transaction_id were being passed in incorrect order. changed the following line

           --   WSM_log_Pvt.PopulateIntfInfo (l_txn_header_rec.transaction_id, l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id);
                WSM_log_Pvt.PopulateIntfInfo (l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id,l_txn_header_rec.transaction_id);

                -- bug 5557667 end changes

                l_sj_api_counter := 1;

                l_rep_job_index := -1;

                while l_sj_counter is not null and l_wsm_wtxn_sj_tbl(l_sj_counter).header_id = l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id loop

                        -- assign the starting job fields....
                        l_starting_jobs_tbl(l_sj_api_counter).WIP_ENTITY_ID                     := l_wsm_wtxn_sj_tbl(l_sj_counter).WIP_ENTITY_ID;
                        l_starting_jobs_tbl(l_sj_api_counter).WIP_ENTITY_NAME                   := l_wsm_wtxn_sj_tbl(l_sj_counter).WIP_ENTITY_NAME;
                        l_starting_jobs_tbl(l_sj_api_counter).REPRESENTATIVE_FLAG               := l_wsm_wtxn_sj_tbl(l_sj_counter).REPRESENTATIVE_FLAG;
                        l_starting_jobs_tbl(l_sj_api_counter).PRIMARY_ITEM_ID                   := l_wsm_wtxn_sj_tbl(l_sj_counter).PRIMARY_ITEM_ID;
                        l_starting_jobs_tbl(l_sj_api_counter).ORGANIZATION_ID                   := l_wsm_wtxn_sj_tbl(l_sj_counter).ORGANIZATION_ID;
                        l_starting_jobs_tbl(l_sj_api_counter).INTRAOPERATION_STEP               := l_wsm_wtxn_sj_tbl(l_sj_counter).INTRAOPERATION_STEP;
                        l_starting_jobs_tbl(l_sj_api_counter).OPERATION_SEQ_NUM                 := l_wsm_wtxn_sj_tbl(l_sj_counter).OPERATION_SEQ_NUM;
                        l_starting_jobs_tbl(l_sj_api_counter).COMMON_ROUTING_SEQUENCE_ID        := l_wsm_wtxn_sj_tbl(l_sj_counter).ROUTING_SEQ_ID;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE_CATEGORY                := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE_CATEGORY;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE1                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE1;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE2                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE2;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE3                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE3;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE4                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE4;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE5                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE5;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE6                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE6;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE7                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE7;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE8                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE8;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE9                        := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE9;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE10                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE10;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE11                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE11;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE12                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE12;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE13                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE13;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE14                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE14;
                        l_starting_jobs_tbl(l_sj_api_counter).ATTRIBUTE15                       := l_wsm_wtxn_sj_tbl(l_sj_counter).ATTRIBUTE15;


                        if  l_wsm_wtxn_sj_tbl(l_sj_counter).REPRESENTATIVE_FLAG = 'Y' then
                            l_rep_job_index := l_sj_api_counter;
                        end if;

                        l_sj_api_counter := l_sj_api_counter +1;
                        l_sj_counter := l_wsm_wtxn_sj_tbl.next(l_sj_counter);


                end loop;

                l_rj_api_counter := 1;

                while l_rj_counter is not null and l_wsm_wtxn_rj_tbl(l_rj_counter).header_id = l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id loop

                        -- JOB HEADER
                        l_resulting_jobs_tbl(l_rj_api_counter).WIP_ENTITY_NAME                        := l_wsm_wtxn_rj_tbl(l_rj_counter).WIP_ENTITY_NAME;
                        l_resulting_jobs_tbl(l_rj_api_counter).DESCRIPTION                            := l_wsm_wtxn_rj_tbl(l_rj_counter).DESCRIPTION;
                        l_resulting_jobs_tbl(l_rj_api_counter).JOB_TYPE                               := l_wsm_wtxn_rj_tbl(l_rj_counter).JOB_TYPE;
                        l_resulting_jobs_tbl(l_rj_api_counter).STATUS_TYPE                            := null; -- currently null,,, but have to add it to the released job....

                        -- Primary details
                        l_resulting_jobs_tbl(l_rj_api_counter).ORGANIZATION_ID                        := l_wsm_wtxn_rj_tbl(l_rj_counter).ORGANIZATION_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).PRIMARY_ITEM_ID                        := l_wsm_wtxn_rj_tbl(l_rj_counter).PRIMARY_ITEM_ID;

                        -- Bom and Routing
                        l_resulting_jobs_tbl(l_rj_api_counter).BOM_REFERENCE_ID                       := l_wsm_wtxn_rj_tbl(l_rj_counter).BOM_REFERENCE_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).ROUTING_REFERENCE_ID                   := l_wsm_wtxn_rj_tbl(l_rj_counter).ROUTING_REFERENCE_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).COMMON_BOM_SEQUENCE_ID                 := l_wsm_wtxn_rj_tbl(l_rj_counter).COMMON_BOM_SEQUENCE_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).COMMON_ROUTING_SEQUENCE_ID             := l_wsm_wtxn_rj_tbl(l_rj_counter).COMMON_ROUTING_SEQUENCE_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).BOM_REVISION                           := l_wsm_wtxn_rj_tbl(l_rj_counter).BOM_REVISION;
                        l_resulting_jobs_tbl(l_rj_api_counter).ROUTING_REVISION                       := l_wsm_wtxn_rj_tbl(l_rj_counter).ROUTING_REVISION;
                        l_resulting_jobs_tbl(l_rj_api_counter).BOM_REVISION_DATE                      := l_wsm_wtxn_rj_tbl(l_rj_counter).BOM_REVISION_DATE;
                        l_resulting_jobs_tbl(l_rj_api_counter).ROUTING_REVISION_DATE                  := l_wsm_wtxn_rj_tbl(l_rj_counter).ROUTING_REVISION_DATE;
                        l_resulting_jobs_tbl(l_rj_api_counter).ALTERNATE_BOM_DESIGNATOR               := l_wsm_wtxn_rj_tbl(l_rj_counter).ALTERNATE_BOM_DESIGNATOR;
                        l_resulting_jobs_tbl(l_rj_api_counter).ALTERNATE_ROUTING_DESIGNATOR           := l_wsm_wtxn_rj_tbl(l_rj_counter).ALTERNATE_ROUTING_DESIGNATOR;

                        -- Quantity
                        l_resulting_jobs_tbl(l_rj_api_counter).START_QUANTITY                         := l_wsm_wtxn_rj_tbl(l_rj_counter).START_QUANTITY;
                        l_resulting_jobs_tbl(l_rj_api_counter).NET_QUANTITY                           := l_wsm_wtxn_rj_tbl(l_rj_counter).NET_QUANTITY;

                        -- Starting operation
                        l_resulting_jobs_tbl(l_rj_api_counter).STARTING_OPERATION_SEQ_NUM             := l_wsm_wtxn_rj_tbl(l_rj_counter).STARTING_OPERATION_SEQ_NUM;
                        l_resulting_jobs_tbl(l_rj_api_counter).STARTING_INTRAOPERATION_STEP           := l_wsm_wtxn_rj_tbl(l_rj_counter).STARTING_INTRAOPERATION_STEP;
                        l_resulting_jobs_tbl(l_rj_api_counter).STARTING_OPERATION_CODE                := l_wsm_wtxn_rj_tbl(l_rj_counter).STARTING_OPERATION_CODE;
                        l_resulting_jobs_tbl(l_rj_api_counter).STARTING_STD_OP_ID                     := l_wsm_wtxn_rj_tbl(l_rj_counter).STARTING_STD_OP_ID;

                        -- Specifi to split txn...
                        l_resulting_jobs_tbl(l_rj_api_counter).SPLIT_HAS_UPDATE_ASSY                  := l_wsm_wtxn_rj_tbl(l_rj_counter).SPLIT_HAS_UPDATE_ASSY;

                        -- Completion sub inv details...
                        l_resulting_jobs_tbl(l_rj_api_counter).COMPLETION_SUBINVENTORY                := l_wsm_wtxn_rj_tbl(l_rj_counter).COMPLETION_SUBINVENTORY;
                        l_resulting_jobs_tbl(l_rj_api_counter).COMPLETION_LOCATOR_ID                  := l_wsm_wtxn_rj_tbl(l_rj_counter).COMPLETION_LOCATOR_ID;

                        -- Dates
                        l_resulting_jobs_tbl(l_rj_api_counter).SCHEDULED_START_DATE                   := l_wsm_wtxn_rj_tbl(l_rj_counter).SCHEDULED_START_DATE;
                        l_resulting_jobs_tbl(l_rj_api_counter).SCHEDULED_COMPLETION_DATE              := l_wsm_wtxn_rj_tbl(l_rj_counter).SCHEDULED_COMPLETION_DATE;

                        -- Other parameters
                        l_resulting_jobs_tbl(l_rj_api_counter).BONUS_ACCT_ID                          := l_wsm_wtxn_rj_tbl(l_rj_counter).BONUS_ACCT_ID;
                        l_resulting_jobs_tbl(l_rj_api_counter).CLASS_CODE                             := l_wsm_wtxn_rj_tbl(l_rj_counter).class_code;
                        l_resulting_jobs_tbl(l_rj_api_counter).COPRODUCTS_SUPPLY                      := l_wsm_wtxn_rj_tbl(l_rj_counter).COPRODUCTS_SUPPLY;

                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE_CATEGORY                     := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE_CATEGORY;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE1                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE1;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE2                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE2;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE3                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE3;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE4                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE4;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE5                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE5;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE6                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE6;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE7                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE7;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE8                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE8;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE9                             := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE9;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE10                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE10;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE11                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE11;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE12                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE12;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE13                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE13;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE14                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE14;
                        l_resulting_jobs_tbl(l_rj_api_counter).ATTRIBUTE15                            := l_wsm_wtxn_rj_tbl(l_rj_counter).ATTRIBUTE15;

                        l_rj_api_counter := l_rj_api_counter +1;
                        l_rj_counter := l_wsm_wtxn_rj_tbl.next(l_rj_counter);

                end loop;


                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'The no of resulting records for this Txn : -> '
                                                                        ||l_resulting_jobs_tbl.count    ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                -- make a call to this procedure to invoke the API....
                -- before calling this procedure check if any of the starting jobs are errored out,,,,,
                l_stmt_num := 50;

                l_error_txn := 0;

                l_index := l_starting_jobs_tbl.first;
                while l_index is not null loop
                        if (l_errored_job_id_tbl.exists(l_starting_jobs_tbl(l_index).wip_entity_id)) or
                           ( l_errored_job_name_tbl.exists(l_starting_jobs_tbl(l_index).wip_entity_name)
                             and
                             l_errored_job_name_tbl(l_starting_jobs_tbl(l_index).wip_entity_name) = l_txn_header_rec.organization_id
                            )
                             or
                           (l_error_txn = 1)
                        then
                                l_stmt_num := 51;
                                -- add the job and its name to the errored out list....

                                add_errored_jobs (  p_error_job_name            => l_starting_jobs_tbl(l_index).wip_entity_name         ,
                                                    p_error_job_id              => l_starting_jobs_tbl(l_index).wip_entity_id           ,
                                                    p_error_org_id              => l_txn_header_rec.organization_id                     ,
                                                    p_error_job_id_tbl          => l_errored_job_id_tbl                                 ,
                                                    p_error_job_name_tbl        => l_errored_job_name_tbl
                                                 );
                                l_error_txn := 1;

                        end if;

                        if l_error_txn <> 1 then

                                -- To check if any errored or pending previous txn exists...
                                begin
                                        l_stmt_num := 52;
                                        select 1
                                        into l_dummy -- 'Earlier Errored Txn Exists in WSJI'
                                        from WSM_STARTING_JOBS_INTERFACE WSJI,
                                             WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                                        Where wsmti.process_status IN (WIP_CONSTANTS.PENDING,WIP_CONSTANTS.ERROR)
                                        and wsji.header_id = wsmti.header_id
                                        and (wsji.wip_entity_id = l_starting_jobs_tbl(l_index).wip_entity_id
                                             OR
                                              ( wsji.wip_entity_name = l_starting_jobs_tbl(l_index).wip_entity_name
                                                 and
                                                wsji.organization_id = nvl(l_starting_jobs_tbl(l_index).organization_id,l_txn_header_rec.organization_id)
                                              )
                                            )
                                        and wsmti.transaction_date < l_txn_header_rec.transaction_date;

                                        l_stmt_num := 53;
                                        l_error_txn := 1;

                                        select 1
                                        into l_dummy -- 'Earlier Errored Txn Exists in WRJI'
                                        from WSM_RESULTING_JOBS_INTERFACE WRJI,
                                             WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                                        Where wsmti.process_status IN (WIP_CONSTANTS.PENDING,WIP_CONSTANTS.ERROR)
                                        and wrji.header_id = wsmti.header_id
                                        and (wrji.wip_entity_name = l_starting_jobs_tbl(l_index).wip_entity_name)
                                        and wrji.organization_id = nvl(l_starting_jobs_tbl(l_index).organization_id,l_txn_header_rec.organization_id)
                                        and wsmti.transaction_date < l_txn_header_rec.transaction_date;

                                        l_error_txn := 1;

                                exception
                                        when no_data_found then
                                                null;

                                        when others then
                                                l_error_txn := 1;
                                end;

                                if l_error_txn = 1 then  --  add the job and its name to the errored out list....
                                        l_stmt_num := 54;

                                        add_errored_jobs (  p_error_job_name            => l_starting_jobs_tbl(l_index).wip_entity_name         ,
                                                            p_error_job_id              => l_starting_jobs_tbl(l_index).wip_entity_id           ,
                                                            p_error_org_id              => l_txn_header_rec.organization_id                     ,
                                                            p_error_job_id_tbl          => l_errored_job_id_tbl                                 ,
                                                            p_error_job_name_tbl        => l_errored_job_name_tbl
                                                         );

                                end if;
                        end if;

                        l_index := l_starting_jobs_tbl.next(l_index);
                end loop;

                l_stmt_num := 55;

                if l_error_txn = 0 then

                        l_stmt_num := 60;

                        SAVEPOINT s_process_one_wlt;

                        -- ST : Serial Support Project ---
                        IF l_txn_header_rec.transaction_type_id IN (WSMPCNST.SPLIT,WSMPCNST.UPDATE_QUANTITY) AND
                           l_starting_jobs_tbl.count = 1
                        THEN

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'Invoking WSM_Serial_Support_PVT.WLT_serial_intf_proc',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                WSM_Serial_Support_PVT.WLT_serial_intf_proc (    p_header_id            => l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id                   ,
                                                                                 p_wip_entity_id        => l_starting_jobs_tbl(l_starting_jobs_tbl.first).wip_entity_id  ,
                                                                                 p_wip_entity_name      => l_starting_jobs_tbl(l_starting_jobs_tbl.first).wip_entity_name,
                                                                                 p_wlt_txn_type         => l_wsm_wtxn_hdr_tbl(l_txn_counter).transaction_type_id         ,
                                                                                 p_organization_id      => l_wsm_wtxn_hdr_tbl(l_txn_counter).organization_id             ,
                                                                                 x_serial_num_tbl       => l_wsm_serial_num_tbl ,
                                                                                 x_return_status        => l_return_status      ,
                                                                                 -- ST : Fix for bug 5218774 : Corrected the parameters being passed..
                                                                                 x_error_msg            => l_error_msg          ,
                                                                                 x_error_count          => l_msg_count
                                                                               );

                                IF l_return_status <> G_RET_SUCCESS THEN
                                -- error out..
                                    IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_text           => 'WSM_Serial_Support_PVT.WLT_serial_intf_proc Failed',
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_msg_tokens         => l_msg_tokens,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                    END IF;

                                    l_stmt_num := 61;

                                    ROLLBACK TO s_process_one_wlt;

                                    -- ST : Fix for bug 5226648 --
                                    -- Push the error messages to the Conc. log file --
                                    IF (l_msg_count = 1)  THEN
                                            fnd_file.put_line(fnd_file.log,l_error_msg);
                                    ELSIF (l_msg_count > 1)  THEN
                                            FOR i IN 1..l_msg_count LOOP
                                                l_error_msg := fnd_msg_pub.get( p_msg_index => l_msg_count - i + 1,
                                                                                p_encoded   => FND_API.G_FALSE
                                                                             );
                                                fnd_file.put_line(fnd_file.log,l_error_msg);
                                            END LOOP;
                                    END IF;
                                    -- ST : Fix for bug 5226648 end --

                                    l_txn_status_tbl(l_txn_counter) := wip_constants.error;
                                    l_txn_header_tbl(l_txn_counter) := l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id;

                                    l_stmt_num := 62;
                                    -- also add the job name and the job wip entity id also... to the errored list....
                                    l_index := l_starting_jobs_tbl.first;
                                    while l_index is not null loop
                                        -- add the wip entity id and name to the errored PL/SQL tables...
                                        add_errored_jobs (  p_error_job_name            => l_starting_jobs_tbl(l_index).wip_entity_name         ,
                                                            p_error_job_id              => l_starting_jobs_tbl(l_index).wip_entity_id           ,
                                                            p_error_org_id              => l_wsm_wtxn_hdr_tbl(l_txn_counter).organization_id    ,
                                                            p_error_job_id_tbl          => l_errored_job_id_tbl                                 ,
                                                            p_error_job_name_tbl        => l_errored_job_name_tbl
                                                         );

                                        l_index := l_starting_jobs_tbl.next(l_index);

                                    end loop;

                                    l_stmt_num := 63;
                                    -- error...
                                    l_program_status := nvl(l_program_status,-1);
                                    GOTO next_txn;
                               END IF;
                        END IF;
                        -- ST : Serial Support Project ---

                        -- invoke_txn_API
                        l_return_status := null;
                        l_msg_count     := 0;
                        l_error_msg     := null;

                        -- ST : Fix for bug 5233265 --
                        -- Store the information required beforehand..
                        -- Wip entity Name can be updated... (but the original wip entity name needed for Lot attributes code) --
                        IF l_txn_header_rec.transaction_type_id = WSMPCNST.BONUS THEN
                                l_st_lot_number :=  NULL;
                                l_st_inv_item_id := NULL;
                        ELSE
                                l_stmt_num := 63;
                                IF l_txn_header_rec.transaction_type_id = WSMPCNST.MERGE THEN
                                    l_st_lot_number := l_starting_jobs_tbl(l_rep_job_index).wip_entity_name;
                                    l_st_inv_item_id := l_starting_jobs_tbl(l_rep_job_index).primary_item_id;
                                ELSE
                                    l_rep_job_index := l_starting_jobs_tbl.first;
                                    l_st_lot_number := l_starting_jobs_tbl(l_rep_job_index).wip_entity_name;
                                    l_st_inv_item_id := l_starting_jobs_tbl(l_rep_job_index).primary_item_id;
                                END IF;

                                -- Check for NULL values and try to get them.. if not found error out..
                                IF l_st_lot_number IS NULL OR l_st_inv_item_id IS NULL THEN
                                        IF l_starting_jobs_tbl(l_rep_job_index).wip_entity_id IS NULL THEN
                                                l_stmt_num := 64;
                                                BEGIN
                                                        -- These two can cause error...
                                                        select we.wip_entity_name,
                                                               wdj.primary_item_id
                                                        into   l_st_lot_number,
                                                               l_st_inv_item_id
                                                        from   wip_entities we,
                                                               wip_discrete_jobs wdj
                                                        where  we.wip_entity_name = l_starting_jobs_tbl(l_rep_job_index).wip_entity_name
                                                        and    we.wip_entity_id = wdj.wip_entity_id
                                                        and    we.organization_id = l_txn_header_rec.organization_id;


                                                EXCEPTION
                                                        WHEN NO_DATA_FOUND THEN
                                                                RAISE e_invalid_job_data;
                                                END;
                                        ELSE
                                                -- Having two SQLs as using a single SQL with nvls on both wip_entity_id
                                                -- and wip_entity_name will be non-performant
                                                l_stmt_num := 65;
                                                BEGIN
                                                        -- These two can cause error...
                                                        select we.wip_entity_name,
                                                               wdj.primary_item_id
                                                        into   l_st_lot_number,
                                                               l_st_inv_item_id
                                                        from   wip_entities we,
                                                               wip_discrete_jobs wdj
                                                        where  we.wip_entity_name = nvl(l_starting_jobs_tbl(l_rep_job_index).wip_entity_name,we.wip_entity_name)
                                                        and    we.wip_entity_id = wdj.wip_entity_id
                                                        and    we.wip_entity_id = l_starting_jobs_tbl(l_rep_job_index).wip_entity_id
                                                        and    we.organization_id = l_txn_header_rec.organization_id;

                                                EXCEPTION
                                                        WHEN NO_DATA_FOUND THEN
                                                                RAISE e_invalid_job_data;
                                                END;
                                        END IF; -- wip_entity_id IS NULL
                                END IF; -- l_st_lot_number IS NULL OR l_st_inv_item_id IS NULL
                        END IF; -- txn_type = BONUS
                        -- ST : Fix for bug 5233265 --

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'Calling WSM_WIP_LOT_TXN_PVT.invoke_txn_API',
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        WSM_WIP_LOT_TXN_PVT.invoke_txn_API (     p_api_version  => 1.0,
                                                                 p_commit                => FND_API.G_FALSE,
                                                                 p_init_msg_list         => FND_API.G_TRUE,
                                                                 p_validation_level      => 1,
                                                                 p_calling_mode          => 1, --indicates that called from interface(2-Forms,1-Interface)
                                                                 p_txn_header_rec        => l_txn_header_rec,
                                                                 p_starting_jobs_tbl     => l_starting_jobs_tbl,
                                                                 p_resulting_jobs_tbl    => l_resulting_jobs_tbl,
                                                                 P_wsm_serial_num_tbl    => l_wsm_serial_num_tbl,
                                                                 p_secondary_qty_tbl     => l_secondary_qty_tbl,
                                                                 -- ST : Added for bug 5263262 --
                                                                 p_invoke_req_worker     => 0                  ,
                                                                 x_return_status         => l_return_status,
                                                                 x_msg_count             => l_msg_count,
                                                                 x_error_msg             => l_error_msg
                                                               );

                        if( g_log_level_statement   >= l_log_level ) then
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => 'WSM_WIP_LOT_TXN_PVT.invoke_txn_API returned :'||l_return_status,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens,
                                                       p_fnd_log_level      => g_log_level_statement,
                                                       p_run_log_level      => l_log_level
                                                      );
                        End if;

                        IF (l_msg_count = 1)  THEN
                                fnd_file.put_line(fnd_file.log,l_error_msg);
                        ELSIF (l_msg_count > 1)  THEN
                            FOR i IN 1..l_msg_count LOOP
                                l_error_msg := fnd_msg_pub.get( p_msg_index => l_msg_count - i + 1,
                                                                p_encoded   => FND_API.G_FALSE
                                                             );
                                fnd_file.put_line(fnd_file.log,l_error_msg);
                            END LOOP;
                        END IF;

                        -- after the call assign back the details that would have been derived in the main API code...
                        -- here...
                        -- if it returns success then add the particularly header id .... to the success list.... else to the failure list...
                        l_stmt_num := 68;

                        if l_return_status = fnd_api.g_ret_sts_success then

                                if( g_log_level_statement   >= l_log_level ) then
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => 'WSM_WIP_LOT_TXN_PVT.invoke_txn_API returned success',
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens,
                                                               p_fnd_log_level      => g_log_level_statement,
                                                               p_run_log_level      => l_log_level
                                                              );
                                End if;

                                l_stmt_num := 70;
                                l_txn_status_tbl(l_txn_counter) := wip_constants.completed;
                                l_txn_header_tbl(l_txn_counter) := l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id;

                                -- ST : Commenting out the below code for bug 5233265
                                -- IF l_txn_header_rec.transaction_type_id = WSMPCNST.BONUS THEN
                                --         l_st_lot_number :=  NULL;
                                --         l_st_inv_item_id := NULL;
                                -- ELSE
                                --      IF l_txn_header_rec.transaction_type_id = WSMPCNST.MERGE THEN
                                --             l_st_lot_number := l_starting_jobs_tbl(l_rep_job_index).wip_entity_name;
                                --          l_st_inv_item_id := l_starting_jobs_tbl(l_rep_job_index).primary_item_id;
                                --         ELSE
                                --             l_rep_job_index := l_starting_jobs_tbl.first;
                                --             l_st_lot_number := l_starting_jobs_tbl(l_rep_job_index).wip_entity_name;
                                --             l_st_inv_item_id := l_starting_jobs_tbl(l_rep_job_index).primary_item_id;
                                --         END IF;
                                --
                                -- END IF;

                                l_index := l_resulting_jobs_tbl.first;

                                l_stmt_num := 75;

                                while (l_index is not null) loop

                                        l_return_code := 0;
                                        l_error_msg     := null;

                                        l_stmt_num := 80;
                                        -- Call lot attr

                                        if( g_log_level_statement   >= l_log_level ) then
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_text           => 'Calling WSM_LotAttr_PVT.create_update_lotattr',
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_msg_tokens         => l_msg_tokens,
                                                                       p_fnd_log_level      => g_log_level_statement,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        End if;

                                        WSM_LotAttr_PVT.create_update_lotattr(x_err_code        => l_return_code,
                                                                              x_err_msg         => l_error_msg,
                                                                              p_lot_number      => l_resulting_jobs_tbl(l_index).wip_entity_name,
                                                                              p_inv_item_id     => l_resulting_jobs_tbl(l_index).primary_item_id,
                                                                              p_org_id          => l_txn_header_rec.organization_id,
                                                                              p_intf_txn_id     => l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id,
                                                                              p_intf_src_code   => 'WSM',
                                                                              p_src_lot_number  => l_st_lot_number,
                                                                              p_src_inv_item_id => l_st_inv_item_id);

                                        l_stmt_num := 85;

                                        IF (l_return_code <> 0) THEN

                                            ROLLBACK TO s_process_one_wlt;

                                            -- error out..
                                            IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_text           => l_error_msg              ,
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                        fnd_file.put_line(fnd_file.log,l_error_msg);
                                            END IF;

                                            l_stmt_num := 90;
                                            l_txn_status_tbl(l_txn_counter) := wip_constants.error;
                                            l_txn_header_tbl(l_txn_counter) := l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id;

                                            l_index := l_starting_jobs_tbl.first;

                                            -- also add the job name and the job wip entity id also... to the errored list....
                                            WHILE l_index IS NOT NULL LOOP
                                                -- add the wip entity id and name to the errored PL/SQL tables...

                                                add_errored_jobs (  p_error_job_name            => l_starting_jobs_tbl(l_index).wip_entity_name         ,
                                                                    p_error_job_id              => l_starting_jobs_tbl(l_index).wip_entity_id           ,
                                                                    p_error_org_id              => l_wsm_wtxn_hdr_tbl(l_txn_counter).organization_id    ,
                                                                    p_error_job_id_tbl          => l_errored_job_id_tbl                                 ,
                                                                    p_error_job_name_tbl        => l_errored_job_name_tbl
                                                                 );

                                                l_index := l_starting_jobs_tbl.next(l_index);

                                            END LOOP;

                                            l_program_status := nvl(l_program_status,-1);
                                            EXIT;
                                       END IF;

                                       l_stmt_num := 92;
                                       l_index := l_resulting_jobs_tbl.next(l_index);
                              END LOOP;

                              l_stmt_num := 95;

                          ELSE

                                    IF not(l_msg_count >= 1) then
                                        fnd_message.set_name('WSM','WSM_GENERIC_ERROR');
                                        l_error_msg := fnd_message.get;
                                        fnd_file.put_line(fnd_file.log,l_error_msg);
                                    END IF;

                                    l_stmt_num := 105;

                                    ROLLBACK TO s_process_one_wlt;

                                    l_txn_status_tbl(l_txn_counter) := wip_constants.error;
                                    l_txn_header_tbl(l_txn_counter) := l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id;

                                    l_stmt_num := 106;
                                    -- also add the job name and the job wip entity id also... to the errored list....
                                    l_index := l_starting_jobs_tbl.first;
                                    while l_index is not null loop
                                        -- add the wip entity id and name to the errored PL/SQL tables...
                                        add_errored_jobs (  p_error_job_name            => l_starting_jobs_tbl(l_index).wip_entity_name         ,
                                                            p_error_job_id              => l_starting_jobs_tbl(l_index).wip_entity_id           ,
                                                            p_error_org_id              => l_wsm_wtxn_hdr_tbl(l_txn_counter).organization_id    ,
                                                            p_error_job_id_tbl          => l_errored_job_id_tbl                                 ,
                                                            p_error_job_name_tbl        => l_errored_job_name_tbl
                                                         );

                                        l_index := l_starting_jobs_tbl.next(l_index);

                                    end loop;

                                    l_stmt_num := 108;
                                    -- error...
                                    l_program_status := nvl(l_program_status,-1);
                                    l_stmt_num := 109;
                          END IF;
                ELSE
                        -- error
                        l_stmt_num := 110;
                        l_program_status := nvl(l_program_status,-1);
                        -- add the header id to the errored list....
                        l_txn_status_tbl(l_txn_counter) := wip_constants.error;
                        l_txn_header_tbl(l_txn_counter) := l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id;

                        -- Add the error message : ST : Fix for bug 4859986
                        IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'TABLE';
                                l_msg_tokens(1).TokenValue := 'WSM_STARTING_JOBS_INTERFACE (header_id = ' || l_wsm_wtxn_hdr_tbl(l_txn_counter).header_id
                                                              || ' )';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_PENDING_TXN'        ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                END IF;

                -- ST : Serial Support Project ---
                <<next_txn>>
                -- ST : Serial Support Project ---
                l_txn_counter := l_wsm_wtxn_hdr_tbl.next(l_txn_counter);

            END LOOP;

            l_stmt_num := 120;
            -- here the call to procedure which will do copy algorithm.....
            if (WSMPJUPD.g_copy_mode = 2) then

                l_return_code := 0;
                l_error_msg     :=null;

                -- algo_create_copies
                l_stmt_num := 125;

                if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Calling algo_create_copies',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                End if;

                algo_create_copies ( x_return_status    => l_return_code,
                                     x_msg_count        => l_msg_count,
                                     x_error_msg        => l_error_msg
                                   );

                -- if return status not success then error out...
                if l_return_code <> 0 then
                     IF G_LOG_LEVEL_ERROR >= l_log_level OR FND_MSG_PUB.check_msg_level(g_msg_lvl_error) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_error_msg              ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                     END IF;
                     l_program_status := nvl(l_program_status,-1);
                end if;

            end if;
            -- OSP FP I begin
            l_stmt_num := 130;
            if ( WSMPJUPD.g_osp_exists = 1) then

                    /*Added Code to set MOAC parameter for bug 5485653  */

                    select to_number(ORG_INFORMATION3) into l_ou_id
                    from HR_ORGANIZATION_INFORMATION
                    where ORGANIZATION_ID = l_mo_org_id
                    and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;

                    FND_REQUEST.SET_ORG_ID (l_ou_id);

                    l_poreq_request_id := fnd_request.submit_request('PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, 'ITEM',
                                                                     NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                                                                    ) ;

                    if( g_log_level_statement   >= l_log_level ) then
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => 'Concurrent Request for Requisition Import Submitted',
                                               p_stmt_num           => l_stmt_num               ,
                                               p_msg_tokens         => l_msg_tokens,
                                               p_fnd_log_level      => g_log_level_statement,
                                               p_run_log_level      => l_log_level
                                              );
                    END IF;
            END IF ;

            -- OSP FP I end
            l_stmt_num := 140;

            forall l_counter in l_txn_status_tbl.first..l_txn_status_tbl.last
                update wsm_resulting_jobs_interface wrji
                set group_id                    = decode(group_id, NULL, l_internal_group_id, p_group_id),
                    internal_group_id           = l_internal_group_id,
                    REQUEST_ID                  = g_request_id,
                    PROGRAM_UPDATE_DATE         = sysdate,
                    PROGRAM_APPLICATION_ID      = g_program_appl_id,
                    PROGRAM_ID                  = g_program_id,
                    process_status              = l_txn_status_tbl(l_counter),
                    LAST_UPDATE_DATE            = sysdate,
                    LAST_UPDATED_BY             = g_user_id,
                    LAST_UPDATE_LOGIN           = g_user_login_id
                where wrji.header_id = l_txn_header_tbl(l_counter)
                and wrji.process_status = WIP_CONSTANTS.RUNNING;

            forall l_counter in l_txn_status_tbl.first..l_txn_status_tbl.last
                update wsm_starting_jobs_interface wsji
                set group_id                    = decode(group_id, NULL, l_internal_group_id, p_group_id),
                    internal_group_id           = l_internal_group_id,
                    REQUEST_ID                  = g_request_id,
                    PROGRAM_UPDATE_DATE         = sysdate,
                    PROGRAM_APPLICATION_ID      = g_program_appl_id,
                    PROGRAM_ID                  = g_program_id,
                    process_status              = l_txn_status_tbl(l_counter),
                    LAST_UPDATE_DATE            = sysdate,
                    LAST_UPDATED_BY             = g_user_id,
                    LAST_UPDATE_LOGIN           = g_user_login_id
                where wsji.header_id = l_txn_header_tbl(l_counter)
                and wsji.process_status = WIP_CONSTANTS.RUNNING;

            forall l_counter in l_txn_status_tbl.first..l_txn_status_tbl.last

                update wsm_split_merge_txn_interface wsmti
                set group_id                    = decode(group_id, NULL, l_internal_group_id, p_group_id),
                    internal_group_id           = l_internal_group_id,
                    REQUEST_ID                  = g_request_id,
                    PROGRAM_UPDATE_DATE         = sysdate,
                    PROGRAM_APPLICATION_ID      = g_program_appl_id,
                    PROGRAM_ID                  = g_program_id,
                    process_status              = l_txn_status_tbl(l_counter),
                    LAST_UPDATE_DATE            = sysdate,
                    LAST_UPDATED_BY             = g_user_id,
                    LAST_UPDATE_LOGIN           = g_user_login_id
                WHERE  wsmti.process_status = WIP_CONSTANTS.RUNNING
                and    wsmti.header_id = l_txn_header_tbl(l_counter)
                and    nvl(wsmti.group_id,l_internal_group_id) = nvl(p_group_id,l_internal_group_id) -- Modified for bug 7145473.
                and   wsmti.transaction_date <= sysdate;

           l_txn_processed := l_wsm_wtxn_hdr_tbl.count + l_txn_processed;

    end loop;
    -- end the loop here....

    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Total Transactions Processed : ' || l_txn_processed,
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    -- ST : Fix for bug 4859986
    -- log a message for no pending rows (at error level so that it appears in the log..)
    IF (l_txn_processed = 0  AND (g_log_level_error >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR))) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(  p_module_name        => l_module                 ,
                                         p_msg_name           => 'WSM_NO_PEND_TXNS'       ,
                                         p_msg_appl_name      => 'WSM'                    ,
                                         p_msg_tokens         => l_msg_tokens             ,
                                         p_stmt_num           => l_stmt_num               ,
                                         p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                         p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                         p_run_log_level      => l_log_level
                                        );
    END IF;

    -- ok here we go and delete the completed the txns ..... based on the profile
    l_stmt_num := 160;
    l_del_int_prof_value := fnd_profile.value('WSM_INTERFACE_HISTORY_DAYS');

    -- delete from wsm_starting_jobs_interface
    DELETE wsm_starting_jobs_interface
    WHERE  header_id IN (  SELECT header_id
                           FROM   wsm_split_merge_txn_interface
                           WHERE  process_status = WIP_CONSTANTS.COMPLETED
                           AND    transaction_date <= decode(l_del_int_prof_value, NULL, transaction_date-1,
                                                             SYSDATE - l_del_int_prof_value));

    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Deleted : ' || SQL%ROWCOUNT || ' rows from wsm_starting_jobs_interface',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 170;
    -- delete from wsm_resulting_jobs_interface
    DELETE wsm_resulting_jobs_interface
    WHERE  header_id IN (SELECT header_id
                         FROM   wsm_split_merge_txn_interface
                         WHERE  process_status = WIP_CONSTANTS.COMPLETED
                         AND    transaction_date <= decode(l_del_int_prof_value, NULL, transaction_date-1,
                                                           SYSDATE - l_del_int_prof_value));


    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Deleted : ' || SQL%ROWCOUNT || ' rows from wsm_resulting_jobs_interface',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    l_stmt_num := 180;
    DELETE wsm_split_merge_txn_interface
    WHERE  process_status = WIP_CONSTANTS.COMPLETED
    AND    transaction_date <= decode(l_del_int_prof_value, NULL, transaction_date-1,
                                      SYSDATE - l_del_int_prof_value);

    -- delete from wsm_split_merge_txn_interface
    if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Deleted : ' || SQL%ROWCOUNT || ' rows from wsm_split_merge_txn_interface',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
    End if;

    --log the errors/warnings to WIE table--
    WSM_log_Pvt.writetoWIE;

    if l_program_status is null then -- no errors...
        -- gotto to set the concurrent program status...

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Procedure Load suuccessful',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;
        l_stmt_num := 155;
        retcode:=0;
        -- Standard conc program return code....
    else
        -- warnings or error...
        l_stmt_num := 160;
        retcode := -1;

        if( g_log_level_statement   >= l_log_level ) then
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Procedure Load unsuccessful: Error :',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );
        End if;

        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Errors encountered in interface txn please check the log file.');

    end if;

    commit;

EXCEPTION
        -- ST : Added for bug 5297923
        WHEN e_invalid_job_data THEN
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN
                        fnd_message.set_name('WSM','WSM_INVALID_FIELD');
                        fnd_message.set_token('FLD_NAME','Wip Entity Name/Wip Entity ID/organization id');
                        l_error_msg := fnd_message.get;

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_text           => l_error_msg              ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                        fnd_file.put_line(FND_FILE.LOG,l_error_msg);
                ELSE
                        fnd_message.set_name('WSM','WSM_GENERIC_ERROR');
                        l_error_msg := fnd_message.get;
                END IF;

                errbuf  := l_error_msg;
                retcode := -1;

                l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Errors encountered in interface txn, please check the log file.');
                commit;
        -- ST : Added for bug 5297923 : end --

        WHEN OTHERS THEN
                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                fnd_message.set_name('WSM','WSM_GENERIC_ERROR');
                errbuf := fnd_message.get;
                retcode := -1;
                l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Errors encountered in interface txn, please check the log file.');
                commit;

END LOAD;

END WSMPLOAD;

/
