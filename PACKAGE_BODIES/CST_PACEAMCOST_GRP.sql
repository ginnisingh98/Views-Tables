--------------------------------------------------------
--  DDL for Package Body CST_PACEAMCOST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PACEAMCOST_GRP" AS
/* $Header: CSTPPEAB.pls 120.12 2006/08/25 09:44:20 arathee noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):='CST_PacEamCost_GRP';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- Start of comments
--  API name    : Estimate_PAC_WipJobs
--  Type        : Public.
--  Function    : This API is called from SRS to estimate eAM WorkOrders in PAC
--                Flow:
--                |-- Insert into CST_PAC_EAM_WO_EST_STATUSES all WIP entities not yet
--                |   estimated for the given cost type.
--                |-- For the job/Jobs to be estimated for the given cost type.
--                |   |-- Update est flag to a -ve no for the jobs to be processed.
--                |   |-- Call Delete_PAC_EamPerBal to delete prior estimation columns
--                |   |-- Compute the estimates, call Compute_PAC_JobEstimates API
--                |   |-- Update the est status to 7 if successfull or to 3 if errors out
--                |   End Loop;
--                Update Estimation status of unprocessed jobs to Pending for any other
--                  exception so that they can be processed in the next run.
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   errbuf              OUT NOCOPY  VARCHAR2 Conc req param
--              retcode             OUT NOCOPY  NUMBER Conc req param
--              p_legal_entity_id   IN   NUMBER   Required
--              p_cost_type_id      IN   NUMBER   Required
--              p_period_id         IN   NUMBER   Required
--              p_cost_group_id     IN   NUMBER   Required
--              p_entity_type       IN   NUMBER   Optional  DEFAULT 6
--              p_job_option        IN   NUMBER   Optional  DEFAULT 1
--              p_job_dummy         IN   NUMBER   Optional  DEFAULT NULL
--              p_wip_entity_id     IN   NUMBER   Optional  DEFAULT NULL
--  OUT     :
--  Version : Current version   1.0
--
--  Notes       : This procedure is called as a concurrent program to estiamte work orders
--                p_job_otion :
--                           1:  All Jobs
--                           2:  Specific job
--
--                Estimation Status:
--                           NULL,1:  Pending
--                              -ve:  Running
--                                3:  Error
--                                7:  Complete
--
-- End of comments

PROCEDURE Estimate_PAC_WipJobs(
                    errbuf                     OUT NOCOPY  VARCHAR2,
                    retcode                    OUT NOCOPY  NUMBER,
                    p_legal_entity_id          IN   NUMBER,
                    p_cost_type_id             IN   NUMBER,
                    p_period_id                IN   NUMBER,
                    p_cost_group_id            IN   NUMBER,
                    p_entity_type              IN   NUMBER   DEFAULT 6,
                    p_job_option               IN   NUMBER   DEFAULT 1,
                    p_job_dummy                IN   NUMBER   DEFAULT NULL,
                    p_wip_entity_id            IN   NUMBER   DEFAULT NULL
) IS
l_api_name      CONSTANT VARCHAR2(30) := 'Estimate_PAC_WipJobs';
l_api_version   CONSTANT NUMBER       := 1.0;
l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

l_dummy                NUMBER;
l_count                NUMBER;
l_index                NUMBER;
l_return_status        VARCHAR(1);
l_msg_return_status    VARCHAR2(1);
l_msg_count            NUMBER := 0;
l_msg_data             VARCHAR2(8000);
l_api_message          VARCHAR2(1000);
l_stmt_num             NUMBER := 0;
l_request_id           NUMBER := 0;
l_user_id              NUMBER := 0;
l_prog_id              NUMBER := 0;
l_prog_app_id          NUMBER := 0;
l_login_id             NUMBER := 0;
l_conc_program_id      NUMBER := 0;

l_estimation_group_id  NUMBER := 0;
l_organization_id      NUMBER := 0;

CONC_STATUS            BOOLEAN;
PROCESS_ERROR          EXCEPTION;

l_conc_warning_flag    VARCHAR2(1);

l_wip_entity_id_tab CST_PacEamCost_GRP.G_WIP_ENTITY_TYP;
l_entity_id_tab CSTPECEP.wip_entity_id_type;

return_val BOOLEAN;
phase      VARCHAR2(300);
status     VARCHAR2(300);
dev_phase  VARCHAR2(300);
dev_status VARCHAR2(300);
message    VARCHAR2(300);

BEGIN

    /* Procedure level log message for Entry point */
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Estimate_PAC_WipJobs <<');
    END IF;

    --   Initializing Variables
    l_conc_warning_flag := FND_API.G_FALSE;

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 5;

    -- retrieving concurrent program information
    l_request_id       := FND_GLOBAL.conc_request_id;
    l_user_id          := FND_GLOBAL.user_id;
    l_prog_id          := FND_GLOBAL.conc_program_id;
    l_prog_app_id      := FND_GLOBAL.prog_appl_id;
    l_login_id         := FND_GLOBAL.conc_login_id;
    l_conc_program_id  := FND_GLOBAL.conc_program_id;

    l_api_message      := 'CST_PacEamCost_GRP.Estimate_PAC_WipJobs() params:'
                        || ' l_request_id '          || to_char(l_request_id)
                        || ' l_user_id '             || to_char(l_user_id)
                        || ' l_prog_id '             || to_char(l_prog_id)
                        || ' l_prog_app_id '         || to_char(l_prog_app_id)
                        || ' l_login_id '            || to_char(l_login_id)
                        || ' l_conc_program_id '     || to_char(l_conc_program_id)
                        || ' p_job_option '          || to_char(p_job_option)
                        || ' p_wip_entity_id '       || to_char(p_wip_entity_id);

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            l_api_message);
    END IF;

    l_stmt_num := 10;

    IF ((p_job_option = 2 AND p_wip_entity_id IS NULL)
         OR (p_entity_type <> 6)) THEN

        l_api_message := ' ( ' || to_char(l_stmt_num) || ' ): '
                         || 'Invalid Program Argument Combination';

        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                l_api_name,
                                l_api_message);

        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                               'CST_PacEamCost_GRP.Estimate_PAC_WipJobs '
                               || l_api_message);

    ELSE -- All parameters are valid

        l_stmt_num := 15;

        l_count := 0;

        -- Check for concurrency. At one time only one estimation processor should be running
        -- For a given Organization/legal entity/Cost type combination

        SELECT count(*)
        INTO   l_count
        FROM   fnd_concurrent_requests    FCR
        WHERE  FCR.program_application_id = l_prog_app_id
        AND    FCR.concurrent_program_id  = l_prog_id
        AND    FCR.argument1  = to_char(p_legal_entity_id)
        AND    FCR.argument2  = to_char(p_cost_type_id)
        AND    FCR.argument4  = to_char(p_cost_group_id) -- Also adding CG for check
        -- Adding the condions as estimating all jobs will not estimate an already
        -- estimated job. So estimaing a specific job should have no concurreny problem.
        AND    FCR.argument6  = to_char(p_job_option)
        AND    nvl(FCR.argument8,-999)  = to_char(nvl(p_wip_entity_id,-999))
        AND    FCR.phase_code = 'R';

        IF l_count > 1 then -- more than 1 concurrent request running with same parameter combination

            -- If More than 1 then error out
            CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                                   fnd_message.get_string('BOM','CST_REQ_ERROR'));

        ELSE

            l_dummy := 0;

            -- Select estimate number, take -ve to denote estimation status is running
            SELECT -1 * cst_wip_cost_estimates_s.NEXTVAL
            INTO   l_estimation_group_id
            FROM   DUAL;

            l_stmt_num := 20;

            /* Insert all discrete jobs not present in estimation table i.e. All
               WorkOrders that are being estimated for a cost type for the first time
               Also the stsus of WorkOrder should
               AND then
               Update status flag in PAC estimate status table for all jobs to be
               estimated  for each job option */


            IF p_job_option=1 then

                l_stmt_num := 25;


                INSERT INTO CST_PAC_EAM_WO_EST_STATUSES es
                (     legal_entity_id,
                      cost_group_id,
                      wip_entity_id,
                      organization_id,
                      cost_type_id,
                      estimation_status,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_estimation_req_id,
                      LAST_ESTIMATION_DATE
                )
                ( SELECT
                      p_legal_entity_id,
                      p_cost_group_id,
                      wdj.wip_entity_id,
                      wdj.organization_id,
                      p_cost_type_id,
                      NULL,
                      SYSDATE,
                      l_user_id,
                      SYSDATE,
                      l_user_id,
                      l_request_id,
                      SYSDATE
                  FROM  wip_discrete_jobs wdj,
                        wip_entities we,
                        cst_cost_group_assignments ccga
                  WHERE wdj.wip_entity_id = we.wip_entity_id
                  AND   wdj.organization_id = ccga.organization_id
                  AND   ccga.cost_group_id = p_cost_group_id
                  AND   we.entity_type = 6
                  AND   NOT EXISTS ( SELECT 'Not existing jobs'
                                     FROM  CST_PAC_EAM_WO_EST_STATUSES es1
                                     WHERE es1.wip_entity_id = wdj.wip_entity_id
                                     AND   es1.legal_entity_id = p_legal_entity_id
                                     AND   es1.cost_type_id  = p_cost_type_id
                                     AND   es1.cost_group_id = p_cost_group_id
                                   )
                 AND    wdj.status_type IN (1,3,4,6,17)
                 AND    p_job_option = 1
                 AND    p_entity_type = 6
                 AND    EXISTS ( SELECT 'X'
                                 FROM   wip_entities we
                                 WHERE  we.wip_entity_id = wdj.wip_entity_id
                                 AND    we.entity_type = p_entity_type)
                        );

                l_stmt_num := 30;

                UPDATE  CST_PAC_EAM_WO_EST_STATUSES es
                SET     es.estimation_status     = l_estimation_group_id,
                        es.last_update_date      = SYSDATE,
                        es.last_updated_by       = l_user_id,
                        es.last_estimation_req_id = l_request_id
                WHERE   es.legal_entity_id = p_legal_entity_id
                AND     es.cost_type_id  = p_cost_type_id
                AND     es.cost_group_id = p_cost_group_id
                AND     p_job_option = 1
                AND     p_entity_type = 6
                AND     NVL(es.estimation_status,1) <> 7 -- for all jobs do not re-estimate
                AND     EXISTS ( SELECT 'X'
                                 FROM   wip_entities we
                                 WHERE  we.wip_entity_id = es.wip_entity_id
                                 AND    we.entity_type = p_entity_type
                               )
                AND     NVL(es.estimation_status,1) > 0
                AND     EXISTS ( SELECT  'Status Check for WO'
                                 FROM    wip_discrete_jobs wdj
                                 WHERE   wdj.status_type IN (1,3,4,6,17)
                                 AND     wdj.wip_entity_id = nvl(p_wip_entity_id,wdj.wip_entity_id)
                                 AND     wdj.wip_entity_id = es.wip_entity_id
                               )
                RETURNING es.wip_entity_id BULK COLLECT INTO l_wip_entity_id_tab;

                l_stmt_num := 35;

                COMMIT;  -- COMMIT is imp here to maintain concurrency. This makes sure
                         -- that the same records are not picked up again.

            ELSIF p_job_option=2 then

                l_stmt_num := 40;

                INSERT INTO CST_PAC_EAM_WO_EST_STATUSES es
                        ( legal_entity_id,
                          cost_group_id,
                          wip_entity_id,
                          organization_id,
                          cost_type_id,
                          estimation_status,
                          creation_date,
                          created_by,
                          last_update_date,
                          last_updated_by,
                          last_estimation_req_id,
                          LAST_ESTIMATION_DATE
                        )
                ( SELECT  p_legal_entity_id,
                          p_cost_group_id,
                          wdj.wip_entity_id,
                          wdj.organization_id,
                          p_cost_type_id,
                          NULL,
                          SYSDATE,
                          l_user_id,
                          SYSDATE,
                          l_user_id,
                          l_request_id,
                          SYSDATE
                  FROM    wip_discrete_jobs wdj, wip_entities we
                  WHERE   wdj.wip_entity_id = we.wip_entity_id
                  AND     we.entity_type = 6
                  AND     NOT EXISTS
                               ( SELECT 'Not existing jobs'
                                 FROM  CST_PAC_EAM_WO_EST_STATUSES es1
                                 WHERE es1.wip_entity_id = p_wip_entity_id
                                 AND   es1.legal_entity_id = p_legal_entity_id
                                 AND   es1.cost_type_id  = p_cost_type_id
                                 AND   es1.cost_group_id = p_cost_group_id
                               )
                 AND      wdj.status_type IN (1,3,4,6,17)
                 AND      p_job_option = 2
                 AND      wdj.wip_entity_id = p_wip_entity_id );

                l_stmt_num := 45;

                UPDATE  CST_PAC_EAM_WO_EST_STATUSES es
                SET     es.estimation_status     = l_estimation_group_id,
                        es.last_update_date      = SYSDATE,
                        es.last_updated_by       = l_user_id,
                        es.last_estimation_req_id = l_request_id
                WHERE   es.legal_entity_id = p_legal_entity_id
                AND     es.cost_group_id = p_cost_group_id
                AND     es.cost_type_id  = p_cost_type_id
                AND     p_job_option = 2
                AND     es.wip_entity_id = p_wip_entity_id
                AND     NVL(es.estimation_status,1) > 0
                AND     EXISTS ( SELECT  'Status Check for WO'
                                 FROM    wip_discrete_jobs wdj
                                 WHERE   wdj.status_type IN (1,3,4,6,17)
                                 AND     wdj.wip_entity_id = nvl(p_wip_entity_id,wdj.wip_entity_id)
                                 AND     wdj.wip_entity_id = es.wip_entity_id
                               )
                RETURNING es.wip_entity_id BULK COLLECT INTO l_wip_entity_id_tab;

                l_stmt_num := 50;

                COMMIT;  -- COMMIT is imp here to maintain concurrency. This makes sure
                         -- that the same records are not picked up again.

            END IF;

            -- statement level logging
            IF (l_sLog) THEN
                FND_LOG.STRING(
                    FND_LOG.LEVEL_STATEMENT,
                    l_module || '.' || l_stmt_num,
                    TO_CHAR(SQL%ROWCOUNT) ||' Job Record(s) Updated with Group Id: '
                    ||TO_CHAR(l_estimation_group_id));
            END IF;

            l_stmt_num := 55;

            -- Default savepoint in the begining before starting processing jobs.
            SAVEPOINT Estimate_PAC_WipJobs_PUB;

            -----------------------
            -- Processs WIP Jobs --
            -----------------------

            IF l_wip_entity_id_tab.COUNT > 0 THEN

                l_stmt_num := 60;

                -- Delete existing estimates
                Delete_PAC_EamPerBal(
                           p_api_version       => 1.0,
                           p_wip_entity_id_tab => l_wip_entity_id_tab,
                           p_legal_entity_id   => p_legal_entity_id,
                           p_cost_group_id     => p_cost_group_id,
                           p_cost_type_id      => p_cost_type_id,
                           x_return_status     => l_return_status,
                           x_msg_count         => l_msg_count,
                           x_msg_data          => l_msg_data);

                l_stmt_num := 65;

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                    l_api_message := 'CST_PacEamCost_GRP.delete_PacEamPerBal() failed';
                    l_msg_data := l_api_message;
                    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                            l_api_name,
                                            '('|| to_char(l_stmt_num) || '): '|| l_api_message);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- ERROR rollback and exit
                END IF;

                -- statement level logging
                IF (l_sLog) THEN
                    l_api_message := 'CST_PacEamCost_GRP.Estimate_PAC_WipJobs('
                                     || to_char(l_stmt_num) || '): '
                                     || 'Delete/Update successful in delete_eamperbal';
                    FND_LOG.STRING(
                        FND_LOG.LEVEL_STATEMENT,
                        l_module || '.' || l_stmt_num,
                        l_api_message);
                END IF;

                /* Added the call to Delete_PAC_eamBalAcct as part of
                   eAM enhancements Project - R12 */

                Delete_PAC_eamBalAcct (
                             p_api_version       => 1.0,
                             p_init_msg_list     => FND_API.G_FALSE,
                             p_commit            => FND_API.G_FALSE,
                             p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                             p_wip_entity_id_tab => l_wip_entity_id_tab,
                             p_legal_entity_id   => p_legal_entity_id,
                             p_cost_group_id     => p_cost_group_id,
                             p_cost_type_id      => p_cost_type_id,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

            l_stmt_num := 66;

            IF(l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               l_api_message := 'CST_PacEamCost_GRP.delete_PAC_EamBalAcct() failed';
               l_msg_data := l_api_message;
               FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name,
               '('|| to_char(l_stmt_num) || '): '|| l_api_message);
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- ERROR rollback and exit
            END IF;

            -- statement level logging
            IF (l_sLog) THEN
               l_api_message := 'CST_PacEamCost_GRP. delete_PAC_EamBalAcct ('
                         || to_char(l_stmt_num) || '): '
                         || 'Delete/Update successful in delete_pac_eambalacct';
               FND_LOG.STRING(
                         FND_LOG.LEVEL_STATEMENT,
                         l_module || '.' || l_stmt_num,
                         l_api_message);
            END IF;

            l_stmt_num := 67;

            /* Delete from the global temp table just to make sure it is empty */
            DELETE FROM cst_eam_direct_items_temp;

            l_stmt_num := 68;

            /* Copying data to another table type as need to call perpetual est package */
            For i in l_wip_entity_id_tab.FIRST..l_wip_entity_id_tab.LAST LOOP
                l_entity_id_tab(i) := l_wip_entity_id_tab(i);
            END LOOP;

            /* Populate the Global Temp Table that replaces wip_eam_direct_items WEDIV
               Thereafter in this file cst_eam_direct_items_temp CEDIT replaces WEDIV
               This is done to improve the performance of the cursor queries in estimation*/
            CST_eamCost_PUB.Insert_tempEstimateDetails (
                      p_api_version     => 1.0,
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_entity_id_tab   => l_entity_id_tab
                      );

            IF l_return_status <> FND_API.g_ret_sts_success THEN

               l_api_message := 'Error: CST_eamCost_PUB.Insert_tempEstimateDetails()';

               FND_MSG_PUB.ADD_EXC_MSG('CSTPECEP', 'ESTIMATE_WORKORDER('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
               RAISE FND_API.g_exc_error;

            END IF;

            -- statement level logging
            IF (l_sLog) THEN
               l_api_message := 'CST_eamCost_PUB.Insert_tempEstimateDetails ('
                         || to_char(l_stmt_num) || '): '
                         || 'Insert int CEDIV successful Insert_tempEstimateDetails';
               FND_LOG.STRING(
                         FND_LOG.LEVEL_STATEMENT,
                         l_module || '.' || l_stmt_num,
                         l_api_message);
            END IF;

            l_stmt_num := 69;

                -- Initializing the var to first record of PL/SQL table
                l_index := l_wip_entity_id_tab.FIRST;

                -- Looping thru the records which have to be processed
                WHILE (l_index IS NOT NULL) LOOP

                    l_stmt_num := 70;

                    SAVEPOINT Estimate_PAC_WipJobs_PUB;

                    -- statement level logging
                    IF (l_sLog) THEN
                        FND_LOG.STRING(
                            FND_LOG.LEVEL_STATEMENT,
                            l_module || '.' || l_stmt_num,
                            'Processing Job:' || TO_CHAR(l_wip_entity_id_tab(l_index)));
                    END IF;

                    BEGIN

                        l_stmt_num := 75;

                        -- Estimate the Job
                        CST_PacEamCost_GRP.Compute_PAC_JobEstimates(
                                        p_api_version     => 1.0,
                                        x_return_status   => l_return_status,
                                        x_msg_count       => l_msg_count,
                                        x_msg_data        => l_msg_data,
                                        p_legal_entity_id => p_legal_entity_id,
                                        p_cost_group_id   => p_cost_group_id,
                                        p_cost_type_id    => p_cost_type_id,
                                        p_period_id       => p_period_id,
                                        p_wip_entity_id   => l_wip_entity_id_tab(l_index),
                                        p_user_id         => l_user_id,
                                        p_request_id      => l_request_id,
                                        p_prog_id         => l_prog_id,
                                        p_prog_app_id     => l_prog_app_id,
                                        p_login_id        => l_login_id);

                        l_stmt_num := 80;

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                            l_api_message := 'CST_PacEamCost_GRP.Compute_PAC_JobEstimates failed';
                            FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                                    l_api_name,
                                                    '('|| to_char(l_stmt_num) || '): '|| l_api_message);
                            RAISE PROCESS_ERROR;
                        END IF;

                        -- set the status of successfully estimated job to to 7(complete)
                        UPDATE CST_PAC_EAM_WO_EST_STATUSES
                        SET    estimation_status      = 7,
                               last_estimation_date   = SYSDATE,
                               last_estimation_req_id = l_request_id,
                               last_update_date       = SYSDATE
                        WHERE  wip_entity_id = l_wip_entity_id_tab(l_index)
                        AND    legal_entity_id = p_legal_entity_id
                        AND    cost_type_id  = p_cost_type_id
                        AND    cost_group_id = p_cost_group_id;

                        l_stmt_num := 85;

                        -- statement level logging
                        IF (l_sLog) THEN
                            l_api_message := 'Estimation complete for wip_entity_id = '
                                             || to_char(l_wip_entity_id_tab(l_index));
                            FND_LOG.STRING(
                                FND_LOG.LEVEL_STATEMENT,
                                l_module || '.' || l_stmt_num,
                                l_api_message);
                        END IF;

                    EXCEPTION

                       WHEN PROCESS_ERROR THEN

                        ROLLBACK TO Estimate_PAC_WipJobs_PUB;

                        -- set the status of job for which estimation failed to 3(error)
                        UPDATE CST_PAC_EAM_WO_EST_STATUSES
                        SET    estimation_status = 3,
                               last_update_date  = SYSDATE,
                               last_estimation_date = SYSDATE,
                               last_estimation_req_id = l_request_id
                        WHERE  wip_entity_id = l_wip_entity_id_tab(l_index)
                        AND    legal_entity_id = p_legal_entity_id
                        AND    cost_type_id  = p_cost_type_id
                        AND    cost_group_id = p_cost_group_id;

                        l_conc_warning_flag := FND_API.G_TRUE; -- When even one has failed. Display a warning.

                        l_stmt_num := 90;

                        -- statement level logging
                        IF (l_sLog) THEN
                            l_api_message := 'Estimation failed for wip_entity_id = '
                                             || to_char(l_wip_entity_id_tab(l_index));
                            FND_LOG.STRING(
                                FND_LOG.LEVEL_STATEMENT,
                                l_module || '.' || l_stmt_num,
                                l_api_message);
                        END IF;

                    END;

                    -- Get the next index
                    l_index := l_wip_entity_id_tab.NEXT(l_index);

                END LOOP; -- WHILE (l_index IS NOT NULL) LOOP

                -- Set status to warning if even one failed. If no Error, default is Success.
                IF FND_API.to_boolean(l_conc_warning_flag) THEN
                    l_stmt_num := 95;
                    IF p_job_option = 2 THEN
                        l_api_message := 'Estimation of the job failed';
                    ELSE
                        l_api_message := 'Estimation of one or more jobs failed';
                    END IF;

                    CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', l_api_message);

                END IF;

            END IF; -- IF l_wip_entity_id_tab.COUNT > 0 THEN

        END IF; -- IF l_dummy > 1

    END IF; -- IF ((p_job_option = 2 AND p_wip_entity_id IS NULL) OR (p_entity_type <> 6)) THEN


    -- Commit now as processing is complete.
    COMMIT;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Estimate_PAC_WipJobs >>'
               );
    END IF;

EXCEPTION

    WHEN OTHERS THEN -- Error in delete is caught here too

        ROLLBACK TO Estimate_PAC_WipJobs_PUB;

        -- Change status of unprocessed jobs to 1 (Pending) so that they can be processed next time.
        FORALL l_index IN l_wip_entity_id_tab.FIRST..l_wip_entity_id_tab.LAST
           UPDATE CST_PAC_EAM_WO_EST_STATUSES
             SET   estimation_status = 1,
                   last_update_date  = SYSDATE,
                   last_estimation_date = SYSDATE,
                   last_estimation_req_id = l_request_id
             WHERE estimation_status = l_estimation_group_id
             AND   wip_entity_id = l_wip_entity_id_tab(l_index)
             AND   legal_entity_id = p_legal_entity_id
             AND   cost_type_id  = p_cost_type_id
             AND   cost_group_id = p_cost_group_id;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data); -- show the message of where it failed.
        END IF;

        l_api_message := '(' || TO_CHAR(l_stmt_num) || ') : '|| SUBSTRB (SQLERRM , 1 , 240);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     l_api_message);
        END IF;

        -- Set status of conc process to Error.
        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                            'CST_PacEamCost_GRP.Estimate_PAC_WipJobs ' ||l_api_message);

        COMMIT;

END Estimate_PAC_WipJobs;


-- Start of comments
--  API name    : Delete_PAC_EamPerBal
--  Type        : Public.
--  Function    : This API is called from Estimate_PAC_WipJobs
--                Flow:
--                |-- Get estimation details of the wip_entity LOOP
--                |   |--Update amount in cst_pac_eam_asset_per_balances
--                |   End Loop;
--                |-- Update estimation columns of cst_pac_eam_period_balances to 0
--                |-- Delete the row in cst_pac_eam_period_balances if estimation and
--                |   actual cost columns are 0 or null
--                |-- Similarly delete the row in cst_pac_eam_asset_per_balances if
--                |   estimation and actual cost columns are 0 or null
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN   NUMBER   Required
--              p_cost_group_id     IN   NUMBER   Required
--              p_cost_type_id      IN   NUMBER   Required
--              p_organization_id   IN  NUMBER   Required
--              p_wip_entity_id_tab IN  CST_PacEamCost_GRP.G_WIP_ENTITY_TYP   Required
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure does bulk deletes and bulk updates of the prior estimation
--                data for the particular Legal Entity/Cost Group/Cost Type using the PL/SQL table
--
-- End of comments

PROCEDURE Delete_PAC_EamPerBal (
              p_api_version       IN         NUMBER,
              p_init_msg_list     IN         VARCHAR2,
              p_commit            IN         VARCHAR2,
              p_validation_level  IN         VARCHAR2,
              x_return_status     OUT NOCOPY VARCHAR2,
              x_msg_count         OUT NOCOPY NUMBER,
              x_msg_data          OUT NOCOPY VARCHAR2,
              p_legal_entity_id   IN         NUMBER,
              p_cost_group_id     IN         NUMBER,
              p_cost_type_id      IN         NUMBER,
              p_wip_entity_id_tab IN         CST_PacEamCost_GRP.G_WIP_ENTITY_TYP
) IS

l_api_name    CONSTANT       VARCHAR2(30) := 'Delete_PAC_EamPerBal';
l_api_version CONSTANT       NUMBER       := 1.0;

l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(8000);
l_stmt_num       NUMBER;
l_api_message    VARCHAR2(1000);

l_index          NUMBER;
l_asset_group_id NUMBER;
l_asset_number   VARCHAR2(30);
l_asset_count    NUMBER;
l_act_mat_cost   NUMBER;
l_act_lab_cost   NUMBER;
l_act_eqp_cost   NUMBER;
l_sys_mat_est    NUMBER;
l_sys_lab_est    NUMBER;
l_sys_eqp_est    NUMBER;

l_txn_date       VARCHAR2(21) := to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');
l_organization_id NUMBER;

/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

CURSOR v_est_csr(c_organization_id NUMBER,
                 c_wip_entity_id NUMBER) IS
SELECT   period_set_name,
         period_name,
         maint_cost_category,
         sum(NVL(system_estimated_mat_cost,0)) sys_mat,
         sum(NVL(system_estimated_lab_cost,0)) sys_lab,
         sum(NVL(system_estimated_eqp_cost,0)) sys_eqp
FROM     cst_pac_eam_period_balances
WHERE    wip_entity_id = c_wip_entity_id
AND      organization_id = c_organization_id
AND      legal_entity_id = p_legal_entity_id
AND      cost_group_id = p_cost_group_id
AND      cost_type_id = p_cost_type_id
GROUP BY period_set_name,
         period_name,
         maint_cost_category;

BEGIN

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Delete_PAC_EamPerBal <<');
    END IF;

    /*  Standard Start of API savepoint */
    SAVEPOINT Delete_PAC_EamPerBal_PUB;

    /*  Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Initialize API return status to success */
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Get asset group and asset number of job */
    l_stmt_num := 100;

    IF p_wip_entity_id_tab.COUNT > 0 THEN -- Process only if records exist

        -- Initializing the var to first record of PL/SQL table
        l_index := p_wip_entity_id_tab.FIRST;

        -- Looping thru the records which have to be processed
        WHILE (l_index IS NOT NULL) LOOP

            l_stmt_num := 105;

            SELECT asset_group_id,
                   asset_number,
                   organization_id
            INTO   l_asset_group_id,
                   l_asset_number,
                   l_organization_id
            FROM   wip_discrete_jobs
            WHERE  wip_entity_id = p_wip_entity_id_tab(l_index);

            l_stmt_num := 110;

            FOR v_est_rec IN v_est_csr(l_organization_id,
                                       p_wip_entity_id_tab(l_index)) LOOP

                -- Update system estimates in cst_pac_eam_asset_per_balances
                IF ( v_est_rec.sys_mat <> 0
                     OR v_est_rec.sys_lab <> 0
                     OR v_est_rec.sys_eqp <> 0)   THEN

                      l_stmt_num := 120;

                      UPDATE cst_pac_eam_asset_per_balances
                      SET    system_estimated_mat_cost = system_estimated_mat_cost -
                                                         v_est_rec.sys_mat,
                             system_estimated_lab_cost = system_estimated_lab_cost -
                                                         v_est_rec.sys_lab,
                             system_estimated_eqp_cost = system_estimated_eqp_cost -
                                                         v_est_rec.sys_eqp
                      WHERE  legal_entity_id = p_legal_entity_id
                      AND    cost_group_id = p_cost_group_id
                      AND    cost_type_id = p_cost_type_id
                      AND    period_set_name = v_est_rec.period_set_name
                      AND    period_name = v_est_rec.period_name
                      AND    inventory_item_id = l_asset_group_id
                      AND    serial_number = l_asset_number
                      AND    maint_cost_category = v_est_rec.maint_cost_category;

                END IF;

            END LOOP;

            -- Delete cpeapb rows with zeros in ALL value columns
            DELETE from cst_pac_eam_asset_per_balances
            WHERE  NVL(actual_mat_cost,0) = 0
            AND    NVL(actual_lab_cost,0) = 0
            AND    NVL(actual_eqp_cost,0) = 0
            AND    NVL(system_estimated_mat_cost,0) = 0
            AND    NVL(system_estimated_lab_cost,0) = 0
            AND    NVL(system_estimated_eqp_cost,0) = 0
            AND    inventory_item_id = l_asset_group_id
            AND    serial_number = l_asset_number
            AND    legal_entity_id = p_legal_entity_id
            AND    cost_group_id = p_cost_group_id
            AND    cost_type_id = p_cost_type_id ;

            -- statement level logging
            IF (l_sLog) THEN
                FND_LOG.STRING(
                    FND_LOG.LEVEL_STATEMENT,
                    l_module || '.' || l_stmt_num,
                    'Delete/Update CPEAPB successful for ' || TO_CHAR(p_wip_entity_id_tab(l_index)));
            END IF;

            -- Get the next index
            l_index := p_wip_entity_id_tab.NEXT(l_index);

        END LOOP; -- WHILE (l_index IS NOT NULL) LOOP


        l_stmt_num := 130;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'CPEAPB Updation completed successfully.');
        END IF;

        -- Update cpepb estimates to zeros
        FORALL l_index IN p_wip_entity_id_tab.FIRST..p_wip_entity_id_tab.LAST
         UPDATE cst_pac_eam_period_balances
          SET   system_estimated_mat_cost = 0,
                system_estimated_lab_cost = 0,
                system_estimated_eqp_cost = 0
          WHERE wip_entity_id =  p_wip_entity_id_tab(l_index)
            AND legal_entity_id = p_legal_entity_id
            AND cost_group_id = p_cost_group_id
            AND cost_type_id = p_cost_type_id ;

        l_stmt_num := 140;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'CPEPB Updation completed successfully.');
        END IF;

        -- Delete cpepb rows with zeros in ALL value columns
        FORALL l_index IN p_wip_entity_id_tab.FIRST..p_wip_entity_id_tab.LAST
         DELETE FROM cst_pac_eam_period_balances
          WHERE actual_mat_cost = 0
          AND   NVL(actual_lab_cost,0) = 0
          AND   NVL(actual_eqp_cost,0) = 0
          AND   NVL(system_estimated_mat_cost,0) = 0
          AND   NVL(system_estimated_lab_cost,0) = 0
          AND   NVL(system_estimated_eqp_cost,0) = 0
          AND   wip_entity_id = p_wip_entity_id_tab(l_index)
          AND   legal_entity_id = p_legal_entity_id
          AND   cost_group_id = p_cost_group_id
          AND   cost_type_id = p_cost_type_id ;

        l_stmt_num := 150;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Delted from CPEPB successfully.');
        END IF;

    END IF; -- end check count of records

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Delete_PAC_EamPerBal >>'
               );
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_PAC_EamPerBal_PUB;
        x_return_status := FND_API.g_ret_sts_error;
        /*  Get message count and data */
        FND_MSG_PUB.COUNT_AND_GET(  p_count => x_msg_count,
                                    p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_PAC_EamPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        /*  Get message count and data */
        FND_MSG_PUB.COUNT_AND_GET(  p_count  => x_msg_count,
                                    p_data   => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Delete_PAC_EamPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || ') : '
                                     || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        /*  Get message count and data */
        FND_MSG_PUB.COUNT_AND_GET(  p_count  => x_msg_count,
                                    p_data   => x_msg_data);

END Delete_PAC_EamPerBal;


-- Start of comments
--  API name    : Compute_PAC_JobEstimates
--  Type        : Public.
--  Function    : This API is called from Estimate_PAC_WipJobs
--                Flow:
--                |-- Check Entity Type is eAM
--                |-- Get charge asset using API
--                |-- Get the period set name and period name
--                |   |-- if scheduled date is in current PAC period use CST_PAC_PERIODS
--                |   |-- else if its in a future period use GL_PERIODS
--                |   End IF
--                |-- Derive the currency extended precision for the organization
--                |-- Derive valuation rates cost type based on organization's cost method
--                |-- For Resources, open c_wor cursor LOOP
--                |   |-- Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |-- Get_eamCostElement
--                |   |-- InsertUpdate_PAC_eamPerBal (send asset number, category, wip entity id, eAM cost element, departments etc.)
--                |   |-- For Resource based Overheads open c_rbo cursor LOOP
--                |   |   |-- InsertUpdate_PAC_eamPerBal
--                |   |   END LOOP for c_rbo
--                |   |-- ADD value for the total resource based Overheads for this resource and the resource value
--                |   END LOOP for c_wor
--                |-- Compute Material Costs, open c_wro cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get_eamCostElement
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For 'Non-stockable' Direct Items open c_wrodi cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get_eamCostElement
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For 'Description based' Direct Items open c_wedi cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get Cost Element from CST_CAT_ELE_EXP_ASSOCS table (not from API)
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For PO and REQ open c_pda cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get Cost Element from cst_CAT_ELE_EXP_ASSOCS table (not from API)
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version      IN   NUMBER   Required
--              p_init_msg_list    IN   VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit           IN   VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level IN   NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_cost_group_id    IN   NUMBER   Required
--              p_legal_entity_id  IN   NUMBER   Required
--              p_Period_id        IN   NUMBER   Required
--              p_wip_entity_id    IN   NUMBER   Required
--              p_user_id          IN   NUMBER   Required
--              p_request_id       IN   NUMBER   Required
--              p_prog_id          IN   NUMBER   Required
--              p_prog_app_id      IN   NUMBER   Required
--              p_login_id         IN   NUMBER   Required
-- OUT      :   x_return_status    OUT  VARCHAR2(1)
--              x_msg_count        OUT  NUMBER
--              x_msg_data         OUT  VARCHAR2(2000)
-- Version  : Current version   1.0
--
-- Notes        : This procedure calculates the estimates for the Work Order for the
--                Legal Entity/Cost Group/Cost Type association
--
-- End of comments

PROCEDURE Compute_PAC_JobEstimates (
                p_api_version      IN   NUMBER,
                p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN   VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    OUT  NOCOPY  VARCHAR2,
                x_msg_count        OUT  NOCOPY  NUMBER,
                x_msg_data         OUT  NOCOPY  VARCHAR2,
                p_legal_entity_id  IN   NUMBER,
                p_cost_group_id    IN   NUMBER,
                p_cost_type_id     IN   NUMBER,
                p_Period_id        IN   NUMBER,
                p_wip_entity_id    IN   NUMBER,
                p_user_id          IN   NUMBER,
                p_request_id       IN   NUMBER,
                p_prog_id          IN   NUMBER,
                p_prog_app_id      IN   NUMBER,
                p_login_id         IN   NUMBER
) IS

l_api_name    CONSTANT  VARCHAR2(30) := 'Compute_PAC_JobEstimates';
l_api_version CONSTANT  NUMBER       := 1.0;

l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

l_return_status         VARCHAR(1)  := FND_API.G_RET_STS_SUCCESS;
l_msg_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(8000);

l_api_message           VARCHAR2(250);
l_stmt_num              NUMBER;

l_lot_size              NUMBER;
l_scheduled_completion_date DATE;
l_entity_type           NUMBER;
l_organization_id       NUMBER;
l_asset_group_item_id   NUMBER;
l_asset_number          VARCHAR2(30);
l_mnt_obj_id            NUMBER;
l_trunc_le_sched_comp_date DATE;
l_dummy                 NUMBER;
l_period_set_name       VARCHAR2(80);
l_period_name           VARCHAR2(80);
l_acct_period_id        NUMBER;
l_round_unit            NUMBER;
l_precision             NUMBER;
l_ext_precision         NUMBER;
l_prior_period_id       NUMBER;
l_pac_rates_id          NUMBER;
l_operation_dept_id     NUMBER;
l_owning_dept_id        NUMBER;
l_dept_id               NUMBER;
l_maint_cost_category   NUMBER;
l_eam_cost_element      NUMBER;
l_sum_rbo               NUMBER;

l_mfg_cost_element_id   NUMBER;
l_period_start_date     DATE;

l_acct_id               NUMBER;
l_material_account      NUMBER;
l_material_overhead_account NUMBER;
l_resource_account      NUMBER;
l_osp_account           NUMBER;
l_overhead_account      NUMBER;
l_wip_acct_class        VARCHAR2(11);

l_exec_flag                 NUMBER;
l_index_var                 NUMBER;
l_value                     NUMBER;
l_account                   NUMBER;


/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


/* Cursor to fetch all resources and their rates for a wip entity */

CURSOR c_wor IS
SELECT wor.operation_seq_num operation_seq_num,
       crc.resource_rate resource_rate,
       wor.uom_code uom,
       wor.usage_rate_or_amount resource_usage,
       DECODE(br.functional_currency_flag,
              1, 1,
              NVL(crc.resource_rate,0))
           * wor.usage_rate_or_amount
           * DECODE(wor.basis_type,
                    1, l_lot_size, 2, 1, 1) raw_resource_value,
       ROUND(DECODE(br.functional_currency_flag,
                    1, 1,
                    NVL(crc.resource_rate,0))
           * wor.usage_rate_or_amount
           * DECODE(wor.basis_type,
                    1, l_lot_size,
                    2, 1, 1) ,l_ext_precision) resource_value,
       wor.resource_id resource_id,
       wor.resource_seq_num resource_seq_num,
       wor.basis_type basis_type,
       wor.usage_rate_or_amount
           * DECODE(wor.basis_type,
                    1, l_lot_size,
                    2, 1, 1) usage_rate_or_amount,
       wor.standard_rate_flag standard_flag,
       wor.department_id department_id,
       br.functional_currency_flag functional_currency_flag,
       br.cost_element_id cost_element_id,
       br.resource_type resource_type
FROM   wip_operation_resources wor,
       bom_resources br,
       cst_resource_costs crc
WHERE  wor.wip_entity_id = p_wip_entity_id
AND    br.resource_id     = wor.resource_id
AND    br.organization_id = wor.organization_id
AND    crc.resource_id = wor.resource_id
AND    crc.cost_type_id = l_pac_rates_id;


/* Overheads associated with the resource that would be fetched by
  the above cursor */

CURSOR c_rbo (p_resource_id   NUMBER,
              p_dept_id       NUMBER,
              p_organization_id        NUMBER,
              p_res_units     NUMBER,
              p_res_value     NUMBER) IS
SELECT cdo.overhead_id ovhd_id,
       cdo.rate_or_amount actual_cost,
       cdo.basis_type basis_type,
       ROUND(cdo.rate_or_amount
            * DECODE(cdo.basis_type,
                     3, p_res_units, p_res_value),
                     l_ext_precision) rbo_value,
       cdo.department_id
FROM   cst_resource_overheads cro,
       cst_department_overheads cdo
WHERE  cdo.department_id    = p_dept_id
AND    cdo.organization_id  = p_organization_id
AND    cdo.cost_type_id     = l_pac_rates_id
AND    cdo.basis_type IN (3,4)
AND    cro.cost_type_id     = cdo.cost_type_id
AND    cro.resource_id      = p_resource_id
AND    cro.overhead_id      = cdo.overhead_id
AND    cro.organization_id  = cdo.organization_id;


/* Select the materials reqt from WRO for the wip Entity */

CURSOR c_wro IS
SELECT   wro.operation_seq_num operation_seq_num,
         wro.department_id department_id,
         ROUND(SUM(NVL(wro.required_quantity,0)
              *  DECODE(msi.eam_item_type,
                        3, decode(wdj.issue_zero_cost_flag,
                                  'Y',0,
                                  nvl(cpic.item_cost,0)),
                         NVL(cpic.item_cost,0))), l_ext_precision) mat_value,
         ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,
                                 'Y',0,
                                  nvl(cpic.material_cost,0)),
                        NVL(cpic.material_cost,0))), l_ext_precision) material_cost,
         ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,
                                 'Y',0,
                                  nvl(cpic.material_overhead_cost,0)),
                        NVL(cpic.material_overhead_cost,0))), l_ext_precision)
                                                              material_overhead_cost,
         ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,
                                 'Y',0,
                                 nvl(cpic.resource_cost,0)),
                        NVL(cpic.resource_cost,0))), l_ext_precision)
                                                                       resource_cost,
         ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,
                                 'Y',0,
                                  nvl(cpic.outside_processing_cost,0)),
                        NVL(cpic.outside_processing_cost,0))), l_ext_precision)
                                                             outside_processing_cost,
         ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,
                                 'Y',0,
                                 nvl(cpic.overhead_cost,0)),
                        NVL(cpic.overhead_cost,0))), l_ext_precision) overhead_cost
FROM     wip_requirement_operations wro,
         cst_pac_item_costs cpic,
         mtl_system_items_b msi,
         wip_discrete_jobs wdj
WHERE    wro.wip_entity_id = p_wip_entity_id
AND      wdj.wip_entity_id = wro.wip_entity_id
AND      cpic.inventory_item_id = wro.inventory_item_id
AND      cpic.cost_group_id = p_cost_group_id
AND      cpic.pac_period_id = l_prior_period_id /* Prior period id */
AND      wro.wip_supply_type IN (1,4)
AND      nvl(wro.released_quantity,-1) <> 0
/* Non stockable items will be included in c_wrodi */
AND      msi.organization_id = wro.organization_id
AND      msi.inventory_item_id = wro.inventory_item_id
AND      msi.stock_enabled_flag = 'Y'
GROUP BY wro.operation_seq_num,
         wro.department_id;

/*  Cursor to select any non-stockable based direct items, exclude
those which have REQ or PO to be picked by c_pda*/

CURSOR c_wrodi IS
SELECT   wro.operation_seq_num operation_seq_num,
         wro.department_id department_id,
         msi.inventory_item_id item_id,
         mic.category_id category_id,
         ROUND(SUM(DECODE(SIGN(NVL(wro.required_quantity,0)
                               - NVL(cediv.quantity_ordered,0)),
                          1, NVL(wro.required_quantity,0)
                             - NVL(cediv.quantity_ordered,0),
                          0)
                   * NVL(wro.unit_price,0)), l_ext_precision) mat_value
FROM     wip_requirement_operations wro,
         (SELECT   ced.work_order_number,
                   ced.organization_id,
                   ced.task_number,
                   ced.item_id,
                   SUM(inv_convert.inv_um_convert(ced.item_id,
                                                  NULL,
                                                  ced.quantity_ordered,
                                                  ced.uom_code,
                                                  msi.primary_uom_code,
                                                  NULL,
                                                  NULL)
                      ) quantity_ordered
          /* We convert to primary_uom because the required_quantity in WRO is
             always in the primary unit of measure. Sum is needed because there
             could be multiple POs/Reqs for the same non-stockable item */
          FROM     cst_eam_direct_items_temp ced,
                   mtl_system_items_b msi
          WHERE    ced.item_id = msi.inventory_item_id
          AND      ced.organization_id = msi.organization_id
          AND      ced.work_order_number = p_wip_entity_id
          GROUP BY ced.work_order_number,
                   ced.organization_id,
                   ced.task_number,
                   ced.item_id
         ) cediv,
         mtl_system_items_b msi,
         mtl_item_categories mic,
         mtl_default_category_sets mdcs
WHERE    wro.wip_entity_id = p_wip_entity_id
AND      cediv.work_order_number(+) = wro.wip_entity_id
AND      cediv.item_id(+) = wro.inventory_item_id
AND      cediv.organization_id(+) = wro.organization_id
AND      cediv.task_number(+) = wro.operation_seq_num
AND      wro.wip_supply_type IN (1,4)
AND      msi.organization_id = wro.organization_id
AND      msi.inventory_item_id = wro.inventory_item_id
AND      msi.stock_enabled_flag = 'N'
AND      msi.inventory_item_id = mic.inventory_item_id
AND      mic.category_set_id = mdcs.category_set_id
AND      mic.organization_id = wro.organization_id
AND      mdcs.functional_area_id = 2
GROUP BY wro.operation_seq_num,
         wro.department_id,
         msi.inventory_item_id,
         mic.category_id;

/*  Cursor to select any description based direct items, exclude those which have
REQ or PO to be picked by c_pda*/

CURSOR c_wedi IS
SELECT   wedi.operation_seq_num operation_seq_num,
         wedi.department_id department_id,
         wedi.purchasing_category_id category_id,
         wedi.direct_item_sequence_id direct_item_id,
         ROUND(
              DECODE(cedit.order_type_lookup_code,
                  'FIXED PRICE', NVL(wedi.amount,0) * NVL(cedit.currency_rate,1) - sum( NVL(cedit.amount_delivered ,0)),
                  'RATE', NVL(wedi.amount,0) * NVL(cedit.currency_rate,1) - sum(NVL(cedit.amount_delivered ,0)),
              DECODE(SIGN(NVL(wedi.required_quantity,0)
                           - SUM(inv_convert.inv_um_convert(NULL,
                                                           NULL,
                                                           NVL(cedit.quantity_ordered,0),
                                                           NVL(cedit.uom_code, wedi.uom),
                                                           wedi.uom,
                                                           NULL,
                                                           NULL))),
                      1, (NVL(wedi.required_quantity,0)
                          - SUM(inv_convert.inv_um_convert(NULL,
                                                           NULL,
                                                           NVL(cedit.quantity_ordered,0),
                                                           NVL(cedit.uom_code, wedi.uom),
                                                           wedi.uom,
                                                           NULL,
                                                           NULL))),
                      0) * NVL(wedi.unit_price, 0) * NVL(cedit.currency_rate,1)), l_ext_precision) wedi_value
FROM     wip_eam_direct_items wedi,
         cst_eam_direct_items_temp cedit
WHERE    wedi.wip_entity_id = p_wip_entity_id
AND      cedit.work_order_number(+) = wedi.wip_entity_id
AND      cedit.organization_id(+) = wedi.organization_id
AND      cedit.direct_item_sequence_id(+) = wedi.direct_item_sequence_id
AND      cedit.task_number(+) = wedi.operation_seq_num
/* AND      cedit.category_id(+) = wedi.purchasing_category_id   Commented for bug 5478136 */
GROUP BY wedi.operation_seq_num,
         wedi.department_id,
         wedi.purchasing_category_id,
         wedi.direct_item_sequence_id,
         NVL(wedi.required_quantity,0),
         NVL(wedi.unit_price,0),
         cedit.order_type_lookup_code,
         NVL(wedi.amount,0),
         NVL(cedit.currency_rate,1);


/* Cursor to pick-up value of direct items for which REQ/PO was created */

CURSOR c_pda IS
SELECT   ROUND(SUM(decode(NVL(pla.order_type_lookup_code,'QUANTITY'),
                        'RATE',NVL(cedit.amount,0) - (NVL(pda.amount_cancelled,0)
                               + /* Tax */ PO_TAX_SV.get_tax('PO',pda.po_distribution_id))* NVL(cedit.currency_rate,1),
                'FIXED PRICE',NVL(cedit.amount,0) - (NVL(pda.amount_cancelled,0)
                              + /* Tax */ PO_TAX_SV.get_tax('PO',pda.po_distribution_id))* NVL(cedit.currency_rate,1),
                        NVL(plla.price_override,0) *
                        (NVL(pda.quantity_ordered,0) - NVL(pda.quantity_cancelled,0)
                        + /* Tax */ PO_TAX_SV.get_tax('PO',pda.po_distribution_id)) * NVL(cedit.currency_rate,1))
                   ), l_ext_precision
              ) pda_value,
         pda.wip_operation_seq_num operation_seq_num,
         pla.category_id category_id,
         nvl(pha.approved_date, pha.last_update_date) category_date
FROM     po_distributions_all pda,
         po_line_locations_all plla,
         po_headers_all pha,
         po_lines_all pla,
         cst_eam_direct_items_temp cedit
WHERE    cedit.work_order_number = p_wip_entity_id
AND      cedit.organization_id = l_organization_id
AND      cedit.task_number = pda.wip_operation_seq_num
AND      cedit.category_id = pla.category_id
AND      pha.po_header_id = cedit.po_header_id
AND      pla.po_line_id = cedit.po_line_id
AND      pda.wip_entity_id = cedit.work_order_number
AND      pda.po_header_id = cedit.po_header_id
AND      pda.destination_organization_id = cedit.organization_id
AND      pda.po_line_id = pla.po_line_id
AND      plla.line_location_id = pda.line_location_id
GROUP BY pda.wip_operation_seq_num,
         pla.category_id,
         pha.approved_date,
         pha.last_update_date,
         cedit.currency_rate
UNION ALL
SELECT  ROUND(SUM(
        DECODE(NVL(prla.order_type_lookup_code,'QUANTITY'),
                        'RATE', NVL(cedit.amount,NVL(prla.amount * cedit.currency_rate,0)),
                        'FIXED PRICE', NVL(cedit.amount,NVL(prla.amount * cedit.currency_rate,0)),
                        NVL(prla.unit_price,0) * NVL(prla.quantity,0))
                         * NVL(cedit.currency_rate,1)), l_ext_precision) pda_value,
         prla.wip_operation_seq_num operation_seq_num,
         prla.category_id category_id,
         prha.last_update_date category_date
FROM     po_requisition_lines_all prla,
         po_requisition_headers_all prha,
         cst_eam_direct_items_temp cedit
WHERE    cedit.work_order_number = p_wip_entity_id
AND      cedit.organization_id = l_organization_id
AND      cedit.task_number = prla.wip_operation_seq_num
AND      cedit.category_id = prla.category_id
        /*to ensure that we do not double count*/
AND      cedit.po_header_id IS NULL
AND      prha.requisition_header_id = cedit.requisition_header_id
AND      prla.destination_organization_id = cedit.organization_id
AND      prla.wip_entity_id = cedit.work_order_number
AND      prla.requisition_line_id = cedit.requisition_line_id
GROUP BY prla.wip_operation_seq_num,
         prla.category_id,
         prha.last_update_date,
         cedit.currency_rate;


/* Cursor added for Budgeting and Forecasting Requirements - R12 */
    cursor c_acct (p_wip_entity_id NUMBER) is
    select material_account,
           material_overhead_account,
           resource_account,
           outside_processing_account,
           overhead_account,
           class_code wip_acct_class
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id;

BEGIN

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Compute_PAC_JobEstimates <<');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT Compute_PAC_JobEstimates_PUB;

    -- standard call to check for call compatibility
    IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize api return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- assign to local variables
    l_stmt_num := 200;

    -- Check Entity Type is eAM befor continuing
    SELECT entity_type,
           organization_id
    INTO   l_entity_type,
           l_organization_id
    FROM   wip_entities we
    WHERE  we.wip_entity_id = p_wip_entity_id;

    l_stmt_num := 205;

    IF (l_entity_type <> 6 ) THEN
        l_msg_data := 'Invalid WIP entity type: ' || TO_CHAR(l_entity_type)
                      ||' WIP Entity: ' || TO_CHAR(p_wip_entity_id);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT start_quantity,
           scheduled_completion_date
    INTO   l_lot_size,
           l_scheduled_completion_date
    FROM   wip_discrete_jobs wdj
    WHERE  wdj.wip_entity_id = p_wip_entity_id;

    l_stmt_num := 210;

    -- Get charge asset using API
    BEGIN
        CST_EAMCOST_PUB.get_charge_asset (
                              p_api_version             =>  1.0,
                              p_wip_entity_id           =>  p_wip_entity_id,
                              x_inventory_item_id       =>  l_asset_group_item_id,
                              x_serial_number           =>  l_asset_number,
                              x_maintenance_object_id   =>  l_mnt_obj_id,
                              x_return_status           =>  l_return_status,
                              x_msg_count               =>  l_msg_count,
                              x_msg_data                =>  l_msg_data);
     EXCEPTION
         WHEN OTHERS THEN
            l_msg_data := 'CST_EAMCOST_PUB.get_charge_asset() failed';
            RAISE FND_API.G_EXC_ERROR;
     END;

    l_stmt_num := 215;

    l_api_message := 'l_asset_group_item_id : '|| TO_CHAR(l_asset_group_item_id)
                     || ' l_asset_number : '|| l_asset_number;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_api_message := 'CST_EAMCOST_PUB.get_charge_asset() returned error ' || l_api_message;
        l_msg_data := l_api_message;
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                 l_api_name,
                                 '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                 || SUBSTRB (SQLERRM , 1 , 240));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            l_api_message);
    END IF;

    l_trunc_le_sched_comp_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                                                            l_scheduled_completion_date,
                                                            l_organization_id);
    l_stmt_num := 220;

    SELECT count(*)
    INTO   l_dummy
    FROM   cst_pac_periods  cpp
    WHERE  cpp.pac_period_id = p_period_id
    AND    LEGAL_ENTITY = p_legal_entity_id
    AND    COST_TYPE_ID = p_cost_type_id
    AND    l_trunc_le_sched_comp_date BETWEEN cpp.PERIOD_START_DATE
                                              AND cpp.PERIOD_END_DATE;
    l_stmt_num := 225;

    IF (NVL(l_dummy,0) = 1) THEN

        l_stmt_num := 227;

        -- Get period info if completion date is in current open period
        SELECT cpp.PAC_PERIOD_ID,
               cpp.period_set_name,
               cpp.period_name,
               cpp.period_start_date
        INTO   l_acct_period_id,
               l_period_set_name,
               l_period_name,
               l_period_start_date
        FROM   CST_PAC_periods cpp
        WHERE  cpp.pac_period_id = p_period_id
        AND    l_trunc_le_sched_comp_date BETWEEN cpp.period_start_date
                                                  AND cpp.period_end_date;

        l_stmt_num := 230;

    ELSE  -- Get period info from Gl_periods, if completion date is in future period

        l_stmt_num := 232;

        /* The following query will be modified to refer to
        cst_organization_definitions as an impact of the HR-PROFILE option. */

        SELECT gp.period_set_name,  gp.period_name,
               gp.start_date
        INTO   l_period_set_name, l_period_name,
               l_period_start_date
        FROM   gl_periods gp,
               gl_sets_of_books gsob,
               cst_organization_definitions ood
        WHERE  ood.organization_id = l_organization_id
        AND    gsob.set_of_books_id = ood.set_of_books_id
        AND    gp.period_set_name = gsob.period_set_name
        AND    gp.adjustment_period_flag = 'N'
        AND    gp.period_type = gsob.accounted_period_type
        AND    l_trunc_le_sched_comp_date BETWEEN gp.start_date
                                                  AND gp.end_date;
        l_stmt_num := 235;

    END IF; -- check for l_dummy

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'Period Details- l_acct_period_id: ' || TO_CHAR(l_acct_period_id)
            || ' l_period_set_name: '|| TO_CHAR(l_period_set_name)
            || ' l_period_name: '    || TO_CHAR(l_period_name));
    END IF;

    IF (l_acct_period_id IS NULL
        AND (l_period_set_name IS NULL OR l_period_name IS NULL)) THEN

        l_msg_data := 'Cannot Find Period for Date: '
                         ||TO_CHAR(l_trunc_le_sched_comp_date);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Derive the currency extended precision for the organization
    CSTPUTIL.CSTPUGCI(l_organization_id,
                      l_round_unit,
                      l_precision,
                      l_ext_precision);

    l_stmt_num := 240;

    /* Request submission should be with proper inputs like Legal Entity,
       Pac Cost type and Cost group. Now Populate prior Period ID */

    SELECT NVL(MAX(cpp.pac_period_id), -1)
    INTO   l_prior_period_id
    FROM   cst_pac_periods cpp
    WHERE  cpp.cost_type_id = p_cost_type_id
    AND    cpp.legal_entity = p_legal_entity_id
    AND    cpp.pac_period_id < p_period_id;

    l_stmt_num := 245;

    -- Derive valuation PAC rates cost type for the PAC cost type

    SELECT nvl(max(pac_rates_cost_type_id),-1)
    INTO   l_pac_rates_id
    FROM   cst_le_cost_types
    WHERE  legal_entity = p_legal_entity_id
    AND    cost_type_id = p_cost_type_id;

    l_stmt_num := 250;

    IF (l_pac_rates_id = -1) THEN
        l_msg_data := 'PAC Rates Type is not defined for Cost Type: '|| TO_CHAR(p_cost_type_id);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   /* Fetch the WAC account information for this wip job */
      open c_acct(p_wip_entity_id);
        fetch c_acct into
          l_material_account,
          l_material_overhead_account,
          l_resource_account,
          l_osp_account,
          l_overhead_account,
          l_wip_acct_class;
      close c_acct;


    --------------------------------------------
    -- Open cursor c_wor to get the resources --
    --------------------------------------------
    FOR c_wor_rec IN c_wor LOOP

        l_stmt_num := 255;

        -- get the maintenance cost category by callling the API
        CST_EAMCOST_PUB.Get_MaintCostCat(
                                 p_txn_mode       => 2 ,
                                 p_wip_entity_id  => p_wip_entity_id,
                                 p_opseq_num      => c_wor_rec.operation_seq_num,
                                 p_resource_id    => c_wor_rec.resource_id,
                                 p_res_seq_num    => c_wor_rec.resource_seq_num,
                                 x_return_status  => l_return_status,
                                 x_operation_dept => l_operation_dept_id,
                                 x_owning_dept    => l_owning_dept_id,
                                 x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 260;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Get the eAM cost element by calling API
        l_eam_cost_element := CST_EAMCOST_PUB.Get_eamCostElement(
                                                 p_txn_mode    => 2,
                                                 p_org_id      => l_organization_id,
                                                 p_resource_id => c_wor_rec.resource_id);

        l_stmt_num := 265;

        IF l_eam_cost_element = 0 THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_eamCostElement() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Insert estimated resource values into WPEPB and CPEAPB */
        InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   p_legal_entity_id  => p_legal_entity_id,
                                   p_cost_group_id    => p_cost_group_id,
                                   p_cost_type_id     => p_cost_type_id,
                                   p_period_id        => l_acct_period_id,
                                   p_period_set_name  => l_period_set_name,
                                   p_period_name      => l_period_name,
                                   p_organization_id  => l_organization_id,
                                   p_wip_entity_id    => p_wip_entity_id,
                                   p_owning_dept_id   => l_owning_dept_id,
                                   p_dept_id          => l_operation_dept_id,
                                   p_maint_cost_cat   => l_maint_cost_category,
                                   p_opseq_num        => c_wor_rec.operation_seq_num,
                                   p_eam_cost_element => l_eam_cost_element,
                                   p_asset_group_id   => l_asset_group_item_id,
                                   p_asset_number     => l_asset_number,
                                   p_value_type       => 2,
                                   p_value            => c_wor_rec.resource_value,
                                   p_user_id          => p_user_id,
                                   p_request_id       => p_request_id,
                                   p_prog_id          => p_prog_id,
                                   p_prog_app_id      => p_prog_app_id,
                                   p_login_id         => p_login_id);

        l_stmt_num := 270;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'insertupdate_PAC_eamperbal() returned error ';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF c_wor_rec.resource_value <> 0 then

        l_stmt_num := 273;

        case(c_wor_rec.cost_element_id)
         when 3 then
                l_acct_id := l_resource_account;
         when 4 then
                l_acct_id := l_osp_account;
         else
                l_acct_id := l_resource_account;
        end case;

        Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_wor_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_acct_id,
                p_value                 => c_wor_rec.resource_value,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => c_wor_rec.cost_element_id,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

         l_api_message := 'Insert_PAC_eamBalAcct error';
         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

       END IF;

     END IF;  -- if c_wor_rec.resource_value !=0


        -- Compute Resource Based Overheads Costs (WOR)

        -- set sum variable that calculates the total Overhead for the resource to 0
        l_sum_rbo := 0;

        FOR c_rbo_rec IN c_rbo(c_wor_rec.resource_id,
                               l_owning_dept_id,
                               l_organization_id,
                               c_wor_rec.usage_rate_or_amount,
                               c_wor_rec.raw_resource_value) LOOP

            l_stmt_num := 275;

            -- sum the total resource based overheads
            l_sum_rbo := l_sum_rbo + NVL(c_rbo_rec.rbo_value,0);

            InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data,
                                       p_legal_entity_id  => p_legal_entity_id,
                                       p_cost_group_id    => p_cost_group_id,
                                       p_cost_type_id     => p_cost_type_id,
                                       p_period_id        => l_acct_period_id,
                                       p_period_set_name  => l_period_set_name,
                                       p_period_name      => l_period_name,
                                       p_organization_id  => l_organization_id,
                                       p_wip_entity_id    => p_wip_entity_id,
                                       p_owning_dept_id   => l_owning_dept_id,
                                       p_dept_id          => l_operation_dept_id,
                                       p_maint_cost_cat   => l_maint_cost_category,
                                       p_opseq_num        => c_wor_rec.operation_seq_num,
                                       p_eam_cost_element => l_eam_cost_element,
                                       p_asset_group_id   => l_asset_group_item_id,
                                       p_asset_number     => l_asset_number,
                                       p_value_type       => 2,
                                       p_value            => c_rbo_rec.rbo_value,
                                       p_user_id          => p_user_id,
                                       p_request_id       => p_request_id,
                                       p_prog_id          => p_prog_id,
                                       p_prog_app_id      => p_prog_app_id,
                                       p_login_id         => p_login_id);

            l_stmt_num := 280;

            IF l_return_status <> FND_API.g_ret_sts_success THEN
                l_api_message := 'insertupdate_PAC_eamperbal() returned error';
                l_msg_data := l_api_message;
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                         l_api_name,
                                         '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                         || SUBSTRB (SQLERRM , 1 , 240));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END LOOP; /* c_rbo_rec */

     /* Insert Resource based overheads only if the value is greater than 0 */
      IF ( l_sum_rbo <> 0 ) THEN

          l_stmt_num := 283;

      Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_wor_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_overhead_account,
                p_value                 => l_sum_rbo,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => 5,   /* Overhead cost Element*/
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

    IF l_return_status <> FND_API.g_ret_sts_success THEN

        l_api_message := 'Insert_PAC_eamBalAcct error';
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

    END IF;

       END IF;  -- if l_sum_rbo != 0

    END LOOP; /* c_wor_rec */

    l_stmt_num := 285;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'Resource Cost Calc completed successfully');
    END IF;

    -------------------------------------------------
    -- Compute Material Costs (WRO + WRODI + WEDI) --
    -------------------------------------------------
    FOR c_wro_rec IN c_wro LOOP

        -- Get maint cost category for the material - call API
        CST_EAMCOST_PUB.Get_MaintCostCat(p_txn_mode   => 1 ,
                                     p_wip_entity_id  => p_wip_entity_id,
                                     p_opseq_num      => c_wro_rec.operation_seq_num,
                                     x_return_status  => l_return_status,
                                     x_operation_dept => l_operation_dept_id,
                                     x_owning_dept    => l_owning_dept_id,
                                     x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 290;

        IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 295;

        -- Get eam cost element by calling API
        l_eam_cost_element := CST_EAMCOST_PUB.Get_eamCostElement(
                                                 p_txn_mode => 1,
                                                 p_org_id   => l_organization_id);

        l_stmt_num := 300;

        IF l_eam_cost_element = 0 THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_eamCostElement() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Insert estimated material values into WPEPB and CPEAPB
        InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   p_legal_entity_id  => p_legal_entity_id,
                                   p_cost_group_id    => p_cost_group_id,
                                   p_cost_type_id     => p_cost_type_id,
                                   p_period_id        => l_acct_period_id,
                                   p_period_set_name  => l_period_set_name,
                                   p_period_name      => l_period_name,
                                   p_organization_id  => l_organization_id,
                                   p_wip_entity_id    => p_wip_entity_id,
                                   p_owning_dept_id   => l_owning_dept_id,
                                   p_dept_id          => c_wro_rec.department_id,
                                   p_maint_cost_cat   => l_maint_cost_category,
                                   p_opseq_num        => c_wro_rec.operation_seq_num,
                                   p_eam_cost_element => l_eam_cost_element,
                                   p_asset_group_id   => l_asset_group_item_id,
                                   p_asset_number     => l_asset_number,
                                   p_value_type       => 2,
                                   p_value            => c_wro_rec.mat_value,
                                   p_user_id          => p_user_id,
                                   p_request_id       => p_request_id,
                                   p_prog_id          => p_prog_id,
                                   p_prog_app_id      => p_prog_app_id,
                                   p_login_id         => p_login_id);

        l_stmt_num := 305;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'insertupdate_PAC_eamperbal() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_stmt_num := 308;

      /* Enter Estimation details for all the manufacturing cost elements where cost is
         non-zero - Eam Enhancements Project R12 */

      for l_index_var in 1..5 loop

       IF (l_sLog) THEN

            l_api_message :=' Calling Insert_eamBalAcct... ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = l_mfg_cost_element_id,' ;
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_account) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            FND_LOG.STRING(
               FND_LOG.LEVEL_STATEMENT,
               l_module || '.' || l_stmt_num,
               l_api_message);
       END IF;

       case (l_index_var)
       when 1 then
              If  c_wro_rec.material_cost <> 0 then
                 l_mfg_cost_element_id := 1;
                 l_account := l_material_account;
                 l_value := c_wro_rec.material_cost;
                 l_exec_flag := 1;
              Else
                 l_exec_flag := 0;
              End If;
       when 2 then
              If  c_wro_rec.material_overhead_cost <> 0 then
                 l_mfg_cost_element_id := 2;
                 l_account := l_material_overhead_account;
                 l_value := c_wro_rec.material_overhead_cost;
                 l_exec_flag := 1;
              Else
                 l_exec_flag := 0;
              End If;
        when 3 then
              If  c_wro_rec.resource_cost <> 0 then
                 l_mfg_cost_element_id := 3;
                 l_account := l_resource_account;
                 l_value := c_wro_rec.resource_cost;
                 l_exec_flag := 1;
              Else
                 l_exec_flag := 0;
              End If;
        when 4 then
              If c_wro_rec.outside_processing_cost <> 0 then
                 l_mfg_cost_element_id := 4;
                 l_account := l_osp_account;
                 l_value :=  c_wro_rec.outside_processing_cost;
                 l_exec_flag := 1;
              Else
                 l_exec_flag := 0;
              End If;
        when 5 then
              If c_wro_rec.overhead_cost <> 0 then
                 l_mfg_cost_element_id := 5;
                 l_account := l_overhead_account;
                 l_value :=  c_wro_rec.overhead_cost;
                 l_exec_flag := 1;
              Else
                 l_exec_flag := 0;
              End If;
       end case;

       If (l_exec_flag = 1) then

        Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_wro_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_account,
                p_value                 => l_value,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => l_mfg_cost_element_id,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

    IF l_return_status <> FND_API.g_ret_sts_success THEN

        l_api_message := 'Insert_PAC_eamBalAcct error';
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

    END IF;
       End If;

      end Loop; /* End For Loop for l_index_var */


    END LOOP; -- end c_wro_rec

    l_stmt_num := 310;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'WRO Cost Calc completed successfully');
    END IF;

    ------------------------------------
    -- Get non-stockable direct items --
    ------------------------------------
    FOR c_wrodi_rec IN c_wrodi LOOP

        l_stmt_num := 315;

        CST_EAMCOST_PUB.Get_MaintCostCat(
                         p_txn_mode       => 1 ,
                         p_wip_entity_id  => p_wip_entity_id,
                         p_opseq_num      => c_wrodi_rec.operation_seq_num,
                         x_return_status  => l_return_status,
                         x_operation_dept => l_operation_dept_id,
                         x_owning_dept    => l_owning_dept_id,
                         x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 320;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.g_exc_error;
        END IF;

       BEGIN
        select cceea.mnt_cost_element_id, cceea.mfg_cost_element_id
        into   l_eam_cost_element,  l_mfg_cost_element_id
        from   cst_cat_ele_exp_assocs cceea
        where  cceea.category_id = c_wrodi_rec.category_id
        and    NVL(cceea.end_date, SYSDATE) + 1 > SYSDATE
        and    cceea.start_date <= sysdate;
      exception
        when no_data_found then
          l_eam_cost_element := 3;
          l_mfg_cost_element_id := 1;
      end;


        l_stmt_num := 325;

        IF l_eam_cost_element = 0 THEN
            l_api_message := 'Invalid cost element for the direct item';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.g_exc_error;
        END IF;

        l_stmt_num := 330;

        /* Insert estimated material values into WPEPB and CPEAPB */
        InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   p_legal_entity_id  => p_legal_entity_id,
                                   p_cost_group_id    => p_cost_group_id,
                                   p_cost_type_id     => p_cost_type_id,
                                   p_period_id        => l_acct_period_id,
                                   p_period_set_name  => l_period_set_name,
                                   p_period_name      => l_period_name,
                                   p_organization_id  => l_organization_id,
                                   p_wip_entity_id    => p_wip_entity_id,
                                   p_owning_dept_id   => l_owning_dept_id,
                                   p_dept_id          => c_wrodi_rec.department_id,
                                   p_maint_cost_cat   => l_maint_cost_category,
                                   p_opseq_num        => c_wrodi_rec.operation_seq_num,
                                   p_eam_cost_element => l_eam_cost_element,
                                   p_asset_group_id   => l_asset_group_item_id,
                                   p_asset_number     => l_asset_number,
                                   p_value_type       => 2,
                                   p_value            => c_wrodi_rec.mat_value,
                                   p_user_id          => p_user_id,
                                   p_request_id       => p_request_id,
                                   p_prog_id          => p_prog_id,
                                   p_prog_app_id      => p_prog_app_id,
                                   p_login_id         => p_login_id);

        l_stmt_num := 335;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'insertupdate_PAC_eamperbal() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

     IF c_wrodi_rec.mat_value <> 0 THEN

        l_stmt_num := 338;

       case(l_mfg_cost_element_id)
           when 1 then
                l_acct_id := l_material_account;
           when 3 then
                l_acct_id := l_resource_account;
           when 4 then
                l_acct_id := l_osp_account;
           when 5 then
                l_acct_id := l_overhead_account;
           else
                l_acct_id := l_material_account;
       end case;

       Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_wrodi_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_acct_id,
                p_value                 => c_wrodi_rec.mat_value,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => l_mfg_cost_element_id,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

        l_api_message := 'Insert_PAC_eamBalAcct error';
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

       END IF;
     End If;

    END LOOP; /* end c_wrodi_rec */


    l_stmt_num := 340;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'WRODI Cost Calc completed successfully');
    END IF;

    --------------------------------------------
    -- Get all description based direct items --
    --------------------------------------------
    FOR c_wedi_rec IN c_wedi LOOP

        l_stmt_num := 345;

        CST_EAMCOST_PUB.Get_MaintCostCat(p_txn_mode       => 1 ,
                         p_wip_entity_id  => p_wip_entity_id,
                         p_opseq_num      => c_wedi_rec.operation_seq_num,
                         x_return_status  => l_return_status,
                         x_operation_dept => l_operation_dept_id,
                         x_owning_dept    => l_owning_dept_id,
                         x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 350;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT cceea.mnt_cost_element_id,  cceea.mfg_cost_element_id
            INTO   l_eam_cost_element, l_mfg_cost_element_id
            FROM   cst_cat_ele_exp_assocs cceea
            WHERE  cceea.category_id = c_wedi_rec.category_id
            AND    NVL(cceea.end_date, SYSDATE) + 1 > SYSDATE
             and    cceea.start_date <= sysdate;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            l_eam_cost_element := 3;
            l_mfg_cost_element_id := 1;
        END;

        l_stmt_num := 355;

        InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   p_legal_entity_id  => p_legal_entity_id,
                                   p_cost_group_id    => p_cost_group_id,
                                   p_cost_type_id     => p_cost_type_id,
                                   p_period_id        => l_acct_period_id,
                                   p_period_set_name  => l_period_set_name,
                                   p_period_name      => l_period_name,
                                   p_organization_id  => l_organization_id,
                                   p_wip_entity_id    => p_wip_entity_id,
                                   p_owning_dept_id   => l_owning_dept_id,
                                   p_dept_id          => c_wedi_rec.department_id,
                                   p_maint_cost_cat   => l_maint_cost_category,
                                   p_opseq_num        => c_wedi_rec.operation_seq_num,
                                   p_eam_cost_element => l_eam_cost_element,
                                   p_asset_group_id   => l_asset_group_item_id,
                                   p_asset_number     => l_asset_number,
                                   p_value_type       => 2,
                                   p_value            => c_wedi_rec.wedi_value,
                                   p_user_id          => p_user_id,
                                   p_request_id       => p_request_id,
                                   p_prog_id          => p_prog_id,
                                   p_prog_app_id      => p_prog_app_id,
                                   p_login_id         => p_login_id);

        l_stmt_num := 360;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'insertupdate_PAC_eamperbal() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    If c_wedi_rec.wedi_value <> 0 then

       l_stmt_num := 363;

       case(l_mfg_cost_element_id)
           when 1 then
                l_acct_id := l_material_account;
           when 3 then
                l_acct_id := l_resource_account;
           when 4 then
                l_acct_id := l_osp_account;
           when 5 then
                l_acct_id := l_overhead_account;
           else
                l_acct_id := l_material_account;
       end case;

       Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_wedi_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_acct_id,
                p_value                 => c_wedi_rec.wedi_value,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => l_mfg_cost_element_id,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

        l_api_message := 'Insert_PAC_eamBalAcct error';
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

       END IF;
    End If;
    END LOOP; /* end c_wedi_rec */


    l_stmt_num := 365;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'CST_PacEamCost_GRP.Compute_PAC_JobEstimatess(' || to_char(l_stmt_num)
            || '): WEDI Cost Calc completed successfully');
    END IF;

    ----------------------------------------------
    -- Get all info of direct items with REQ/PO --
    ----------------------------------------------
    FOR c_pda_rec IN c_pda LOOP

        l_stmt_num := 370;

        SELECT department_id
        INTO   l_dept_id
        FROM   wip_operations wo
        WHERE  wo.wip_entity_id = p_wip_entity_id
        AND    wo.operation_seq_num = c_pda_rec.operation_seq_num;

        l_stmt_num := 375;

        CST_EAMCOST_PUB.Get_MaintCostCat(p_txn_mode       => 1 ,
                         p_wip_entity_id  => p_wip_entity_id,
                         p_opseq_num      => c_pda_rec.operation_seq_num,
                         x_return_status  => l_return_status,
                         x_operation_dept => l_operation_dept_id,
                         x_owning_dept    => l_owning_dept_id,
                         x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 380;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT cceea.mnt_cost_element_id, cceea.mfg_cost_element_id
            INTO   l_eam_cost_element, l_mfg_cost_element_id
            FROM   cst_cat_ele_exp_assocs cceea
            WHERE  cceea.category_id = c_pda_rec.category_id
            AND    c_pda_rec.category_date >= cceea.start_date
            AND    c_pda_rec.category_date < (nvl(cceea.end_date, sysdate) + 1);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            l_eam_cost_element := 3;
            l_mfg_cost_element_id := 1;
        END;

        l_stmt_num := 385;

        /* Insert estimated material values into WPEPB and CPEAPB */

        InsertUpdate_PAC_eamPerBal(p_api_version      => 1.0,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   p_legal_entity_id  => p_legal_entity_id,
                                   p_cost_group_id    => p_cost_group_id,
                                   p_cost_type_id     => p_cost_type_id,
                                   p_period_id        => l_acct_period_id,
                                   p_period_set_name  => l_period_set_name,
                                   p_period_name      => l_period_name,
                                   p_organization_id  => l_organization_id,
                                   p_wip_entity_id    => p_wip_entity_id,
                                   p_owning_dept_id   => l_owning_dept_id,
                                   p_dept_id          => l_dept_id,
                                   p_maint_cost_cat   => l_maint_cost_category,
                                   p_opseq_num        => c_pda_rec.operation_seq_num,
                                   p_eam_cost_element => l_eam_cost_element,
                                   p_asset_group_id   => l_asset_group_item_id,
                                   p_asset_number     => l_asset_number,
                                   p_value_type       => 2,
                                   p_value            => c_pda_rec.pda_value,
                                   p_user_id          => p_user_id,
                                   p_request_id       => p_request_id,
                                   p_prog_id          => p_prog_id,
                                   p_prog_app_id      => p_prog_app_id,
                                   p_login_id         => p_login_id);

        l_stmt_num := 390;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'insertupdate_PAC_eamperbal() returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

     If  c_pda_rec.pda_value <> 0 then

       l_stmt_num := 393;

       case(l_mfg_cost_element_id)
           when 1 then
                l_acct_id := l_material_account;
           when 3 then
                l_acct_id := l_resource_account;
           when 4 then
                l_acct_id := l_osp_account;
           when 5 then
                l_acct_id := l_overhead_account;
           else
                l_acct_id := l_material_account;
       end case;

       Insert_PAC_eamBalAcct(
                p_api_version           => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_legal_entity_id       => p_legal_entity_id,
                p_cost_group_id         => p_cost_group_id,
                p_cost_type_id          => p_cost_type_id,
                p_period_id             => l_acct_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => l_organization_id,
                p_wip_entity_id         => p_wip_entity_id,
                p_owning_dept_id        => l_owning_dept_id,
                p_dept_id               => l_operation_dept_id,
                p_maint_cost_cat        => l_maint_cost_category,
                p_opseq_num             => c_pda_rec.operation_seq_num,
                p_period_start_date     => l_period_start_date,
                p_account_ccid          => l_acct_id,
                p_value                 => c_pda_rec.pda_value,
                p_txn_type              => l_eam_cost_element,
                p_wip_acct_class        => l_wip_acct_class,
                p_mfg_cost_element_id   => l_mfg_cost_element_id,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

        l_api_message := 'Insert_PAC_eamBalAcct error';
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_PAC_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

       END IF;
     End If;

    END LOOP; -- end c_pda_rec

    l_stmt_num := 395;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'CST_PacEamCost_GRP.Compute_PAC_JobEstimatess(' || to_char(l_stmt_num)
            || '): PO/REQ Cost Calc completed successfully');
    END IF;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                               p_data  => x_msg_data );

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Compute_PAC_JobEstimates >>'
               );
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Compute_PAC_JobEstimates_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;

        -- statement level logging
        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Compute_PAC_JobEstimates_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- statement level logging
        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Compute_PAC_JobEstimates_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || ') : '
                                     || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data  => x_msg_data);

END Compute_PAC_JobEstimates;

-- Start of comments
--  API name    : InsertUpdate_pac_eamPerBal
--  Type        : Public.
--  Function    : This API is called from Compute_PAC_JobEstimates and Compute_PAC_JobActuals
--                Flow:
--                |-- Identify column to update value
--                |-- IF p_value_type = 1 THEN           ==> actual_cost
--                |   |-- IF p_eam_cost_element = 1 THEN    --> equipment
--                |   |   |-- l_column := 'actual_eqp_cost';
--                |   |   |-- l_col_type := 11;
--                |   |-- ELSIF p_eam_cost_element = 2 THEN --> labor
--                |   |   |-- l_column := 'actual_lab_cost';
--                |   |   |-- l_col_type := 12;
--                |   |-- ELSE                              --> material
--                |   |   |-- l_column := 'actual_mat_cost';
--                |   |   |-- l_col_type := 13;
--                |   |   END IF;
--                |-- ELSE                                ==> system estimated
--                |   |-- IF p_eam_cost_element = 1 THEN     --> equipment
--                |   |   |-- l_column := 'system_estimated_eqp_cost';
--                |   |   |-- l_col_type := 21;
--                |   |-- ELSIF p_eam_cost_element = 2 THEN  --> labor
--                |   |   |-- l_column := 'system_estimated_lab_cost';
--                |   |   |-- l_col_type := 22;
--                |   |-- ELSE                              --> material
--                |   |   |-- l_column := 'system_estimated_mat_cost';
--                |   |   |-- l_col_type := 23;
--                |   |   END IF;
--                |   END IF;
--                |-- Insert/update CST_PAC_EAM_PERIOD_BALANCES
--                |   |-- Check if txn record already existing CST_PAC_EAM_PERIOD_BALANCES
--                |   |   |-- If yes then UPDATE estimation details
--                |   |   |-- Else Insert estimation details
--                |-- Insert into asset period balances, call InsertUpdate_pac_assetPerBal
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version      IN NUMBER   Required
--              p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id  IN NUMBER
--              p_cost_group_id    IN NUMBER
--              p_cost_type_id     IN NUMBER
--              p_period_id        IN NUMBER   Optional Default = null
--              p_period_set_name  IN VARCHAR2 Optional Default = null
--              p_period_name      IN VARCHAR2 Optional Default = null
--              p_organization_id  IN NUMBER   Required
--              p_wip_entity_id    IN NUMBER   Required
--              p_owning_dept_id   IN NUMBER   Required
--              p_dept_id          IN NUMBER   Required
--              p_maint_cost_cat   IN NUMBER   Required
--              p_opseq_num        IN NUMBER   Required
--              p_eam_cost_element IN NUMBER   Required
--              p_asset_group_id   IN NUMBER   Required
--              p_asset_number     IN VARCHAR2 Required
--              p_value_type       IN NUMBER   Required
--              p_value            IN NUMBER   Required
--              p_user_id          IN NUMBER   Required
--              p_request_id       IN NUMBER   Required
--              p_prog_id          IN NUMBER   Required
--              p_prog_app_id      IN NUMBER   Required
--              p_login_id         IN NUMBER   Required
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure inserts actuals (p_value_type = 1) or estimated (p_value_type = 2)
--                values into CST_PAC_EAM_PERIOD_BALANCES
--
-- End of comments

PROCEDURE InsertUpdate_PAC_eamPerBal (
                p_api_version      IN          NUMBER,
                p_init_msg_list    IN          VARCHAR2,
                p_commit           IN          VARCHAR2,
                p_validation_level IN          VARCHAR2,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                p_legal_entity_id  IN          NUMBER,
                p_cost_group_id    IN          NUMBER,
                p_cost_type_id     IN          NUMBER,
                p_period_id        IN          NUMBER   := null,
                p_period_set_name  IN          VARCHAR2 := null,
                p_period_name      IN          VARCHAR2 := null,
                p_organization_id  IN          NUMBER,
                p_wip_entity_id    IN          NUMBER,
                p_owning_dept_id   IN          NUMBER,
                p_dept_id          IN          NUMBER,
                p_maint_cost_cat   IN          NUMBER,
                p_opseq_num        IN          NUMBER,
                p_eam_cost_element IN          NUMBER,
                p_asset_group_id   IN          NUMBER,
                p_asset_number     IN          VARCHAR2,
                p_value_type       IN          NUMBER,
                p_value            IN          NUMBER,
                p_user_id          IN          NUMBER,
                p_request_id       IN          NUMBER,
                p_prog_id          IN          NUMBER,
                p_prog_app_id      IN          NUMBER,
                p_login_id         IN          NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'InsertUpdate_PAC_eamPerBal';
l_api_version CONSTANT NUMBER       := 1.0;

l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

l_return_status     VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(8000);
l_stmt_num          NUMBER;
l_api_message       VARCHAR2(1000);

l_wepb_row_exists   NUMBER;
l_ceapb_row_exists  NUMBER;
l_count             NUMBER;

l_column            VARCHAR2(80);
l_col_type          NUMBER;
l_statement         VARCHAR2(2000);

l_period_id         NUMBER;
l_period_set_name   VARCHAR2(15);
l_period_name       VARCHAR2(15);
l_period_start_date DATE;
l_open_period       VARCHAR2(1) := FND_API.G_TRUE;
l_maint_obj_id      NUMBER;
l_maint_obj_type    NUMBER;

/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'InsertUpdate_PAC_eamPerBal <<');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT InsertUpdate_PAC_eamPerBal_PUB;


    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num := 400;

    -------------------------------------------------------------------------------
    -- Get period id if period set name and period name is passed and vice versa --
    -------------------------------------------------------------------------------

    -- Calling program must pass period id or period set and period name.
    IF   (p_period_id is null OR p_period_id = 0)
          AND  (p_period_set_name is null OR p_period_name is null)  THEN
         l_msg_data := 'Must pass period id, or period set name and period name. '
                       || 'Job id: ' || TO_CHAR(p_wip_entity_id);
         RAISE FND_API.G_EXC_ERROR;
    END IF;


    BEGIN
        l_stmt_num := 405;

        SELECT pac_period_id,
               period_set_name,
               period_name,
               period_start_date
        INTO   l_period_id,
               l_period_set_name,
               l_period_name,
               l_period_start_date
        FROM   CST_PAC_PERIODS
        WHERE  cost_type_id = p_cost_type_id
        AND    (pac_period_id = p_period_id
               OR (period_set_name = p_period_set_name
                   AND period_name = p_period_name));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN     -- no open period
            l_open_period := FND_API.G_FALSE;
    END;

    -- Get data from gl_periods if it is a future period.
    IF NOT FND_API.to_boolean(l_open_period)  THEN
        l_stmt_num := 410;

        l_period_set_name := p_period_set_name;
        l_period_name := p_period_name;

        SELECT 0,
               period_set_name,
               period_name,
               start_date
        INTO   l_period_id,
               l_period_set_name,
               l_period_name,
               l_period_start_date
        FROM   gl_periods
        WHERE  period_set_name = l_period_set_name
        AND    period_name = l_period_name;
    END IF;

    ---------------------------------------
    --  Identify column to update value. --
    ---------------------------------------
    IF p_value_type = 1 THEN             -- actual_cost
        IF p_eam_cost_element = 1  THEN     -- equiptment
             l_column := 'actual_eqp_cost';
             l_col_type := 11;
        ELSIF  p_eam_cost_element = 2  THEN -- labor
             l_column := 'actual_lab_cost';
             l_col_type := 12;
        ELSE                                -- material
             l_column := 'actual_mat_cost';
             l_col_type := 13;
        END IF;
    ELSE                                  -- system estimated
        IF p_eam_cost_element = 1  THEN      -- equiptment
             l_column := 'system_estimated_eqp_cost';
             l_col_type := 21;
        ELSIF  p_eam_cost_element = 2  THEN  -- labor
             l_column := 'system_estimated_lab_cost';
             l_col_type := 22;
        ELSE                                 -- material
             l_column := 'system_estimated_mat_cost';
             l_col_type := 23;
        END IF;
    END IF;

    -----------------------------------------------
    -- Insert/update cst_pac_eam_period_balances --
    -----------------------------------------------
    SELECT count(*)
    INTO   l_count
    FROM   cst_pac_eam_period_balances
    WHERE  period_set_name = l_period_set_name
    AND    period_name = l_period_name
    AND    pac_period_id = l_period_id
    AND    organization_id = p_organization_id
    AND    wip_entity_id = p_wip_entity_id
    AND    maint_cost_category = p_maint_cost_cat
    AND    owning_dept_id = p_owning_dept_id
    AND    operations_dept_id = p_dept_id
    AND    operation_seq_num = p_opseq_num
    AND    cost_group_id = p_cost_group_id
    AND    cost_type_id = p_cost_type_id
    AND    legal_entity_id = p_legal_entity_id;

    l_stmt_num := 415;

    IF l_count <> 0 THEN /* If records already exist, Update */

        l_stmt_num := 420;

        -- Building the statement before to improve performance
        l_statement := 'UPDATE cst_pac_eam_period_balances SET '
                   || l_column || '=' || 'nvl('|| l_column || ',0) + nvl(:p_value,0)'
                   || ', last_update_date = sysdate'
                   || ', last_updated_by = :p_user_id'
                   || ', last_update_login = :p_login_id'
                   || ' WHERE period_set_name = :l_period_set_name'
                   || ' AND cost_type_id = :p_cost_type_id'
                   || ' AND cost_group_id = :p_cost_group_id'
                   || ' AND legal_entity_id = :p_legal_entity_id'
                   || ' AND period_name = :l_period_name'
                   || ' AND organization_id = :p_organization_id'
                   || ' AND wip_entity_id = :p_wip_entity_id'
                   || ' AND maint_cost_category = :p_maint_cost_cat'
                   || ' AND owning_dept_id = :p_owning_dept_id'
                   || ' AND operations_dept_id = :p_dept_id'
                   || ' AND operation_seq_num = :p_opseq_num';

        EXECUTE IMMEDIATE l_statement
        USING p_value, p_user_id, p_login_id, l_period_set_name, p_cost_type_id, p_cost_group_id,
              p_legal_entity_id, l_period_name, p_organization_id, p_wip_entity_id,p_maint_cost_cat,
              p_owning_dept_id, p_dept_id, p_opseq_num ;

        l_stmt_num := 425;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Update Successful for Job id: ' || TO_CHAR(p_wip_entity_id));
        END IF;

    ELSE -- Else, no records found, so Insert

        l_stmt_num := 430;

        INSERT INTO cst_pac_eam_period_balances (
            legal_entity_id,
            cost_group_id,
            cost_type_id,
            period_set_name,
            period_name,
            pac_period_id,
            wip_entity_id,
            organization_id,
            owning_dept_id,
            operations_dept_id,
            operation_seq_num,
            maint_cost_category,
            actual_mat_cost,
            actual_lab_cost,
            actual_eqp_cost,
            system_estimated_mat_cost,
            system_estimated_lab_cost,
            system_estimated_eqp_cost,
            period_start_date,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id
         )
        VALUES (
            p_legal_entity_id,
            p_cost_group_id,
            p_cost_type_id,
            l_period_set_name,
            l_period_name,
            l_period_id,
            p_wip_entity_id,
            p_organization_id,
            p_owning_dept_id,
            p_dept_id,
            p_opseq_num,
            p_maint_cost_cat,
            DECODE(l_col_type, 13, NVL(p_value,0),0),  -- actual mat
            DECODE(l_col_type, 12, NVL(p_value,0),0),  -- actual lab
            DECODE(l_col_type, 11, NVL(p_value,0),0),  -- actual eqp
            DECODE(l_col_type, 23, NVL(p_value,0),0),  -- sys est
            DECODE(l_col_type, 22, NVL(p_value,0),0),  -- sys est
            DECODE(l_col_type, 21, NVL(p_value,0),0),  -- sys est
            l_period_start_date,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_login_id,
            p_request_id,
            p_prog_app_id,
            p_prog_id
        );

        l_stmt_num := 435;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Insert Successful for Job id: ' || TO_CHAR(p_wip_entity_id));
        END IF;

    END IF;   -- end checking job balance row

    /* Obtain Maintenance_Object_id and Maintenance_Object_Type from
       WIP_DISCRETE_JOBS. eAM enhancements project - R12 */
       select maintenance_object_id, maintenance_object_type
       into l_maint_obj_id, l_maint_obj_type
       from wip_discrete_jobs
       where wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id;

    /*------------------------------------------------------------
    Check for Asset Route is not added in this enhancement.
    So directly insert into asset_per_bal table
    ------------------------------------------------------------*/
    l_stmt_num := 440;

    InsertUpdate_pac_assetPerBal(p_legal_entity_id   =>  p_legal_entity_id,
                                 p_cost_group_id     => p_cost_group_id,
                                 p_cost_type_id      => p_cost_type_id,
                                 p_api_version       => 1.0,
                                 x_return_status     => l_return_status,
                                 x_msg_count         => l_msg_count,
                                 x_msg_data          => l_msg_data,
                                 p_period_id         => l_period_id,
                                 p_period_set_name   => l_period_set_name,
                                 p_period_name       => l_period_name,
                                 p_organization_id   => p_organization_id,
                                 p_maint_cost_cat    => p_maint_cost_cat,
                                 p_asset_group_id    => p_asset_group_id,
                                 p_asset_number      => p_asset_number,
                                 p_value             => p_value,
                                 p_column            => l_column,
                                 p_col_type          => l_col_type,
                                 p_period_start_date => l_period_start_date,
                                 p_maintenance_object_id => l_maint_obj_id,
                                 p_maintenance_object_type => l_maint_obj_type,
                                 p_user_id           => p_user_id,
                                 p_request_id        => p_request_id,
                                 p_prog_id           => p_prog_id,
                                 p_prog_app_id       => p_prog_app_id,
                                 p_login_id          => p_login_id);

    l_stmt_num := 445;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_api_message := 'insertupdate_PAC_assetperbal() returned error';
        l_msg_data := l_api_message;
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                 l_api_name,
                                 '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                 || SUBSTRB (SQLERRM , 1 , 240));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
         COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data );

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'InsertUpdate_PAC_eamPerBal >>'
               );
    END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO InsertUpdate_PAC_eamPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO InsertUpdate_PAC_eamPerBal_PUB;
        x_return_status := FND_API.g_ret_sts_unexp_error ;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.count_and_get(p_count  => x_msg_count,
                                  p_data   => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO InsertUpdate_PAC_eamPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        --  Get message count and data
        FND_MSG_PUB.count_and_get(p_count  => x_msg_count,
                                  p_data   => x_msg_data);

END InsertUpdate_PAC_eamPerBal;


-- Start of comments
--  API name    : InsertUpdate_pac_assetPerBal
--  Type        : Public.
--  Function    : This API is called from InsertUpdate_PAC_eamPerBal
--                Flow:
--                Check if records already exist in CST_EAM_PAC_ASSET_PER_BALANCES
--                |-- If yes then Update CST_PAC_EAM_ASSET_PER_BALANCES
--                |-- Else Insert into CST_PAC_EAM_ASSET_PER_BALANCES
--                End if
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER   Default = null,
--              p_period_set_name   IN  VARCHAR2 Default = null,
--              p_period_name       IN  VARCHAR2 Default = null,
--              p_organization_id   IN  NUMBER,
--              p_maint_cost_cat    IN  NUMBER,
--              p_asset_group_id    IN  NUMBER,
--              p_asset_number      IN  VARCHAR2,
--              p_value             IN  NUMBER,
--              p_column            IN  VARCHAR2,
--              p_col_type          IN  NUMBER,
--              p_period_start_date IN  DATE,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER,
--              p_maintenance_object_id IN NUMBER, -- Added for eAM enhancements project R12
--              p_maintenance_object_type IN NUMBER  -- Added for eAM enhancements project R12
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure insets or Updates Actual/Estimate details at the Asset Group/Serial Number level
--
-- End of comments

PROCEDURE InsertUpdate_PAC_assetPerBal (
                p_api_version          IN         NUMBER,
                p_init_msg_list        IN         VARCHAR2,
                p_commit               IN         VARCHAR2,
                p_validation_level     IN         VARCHAR2,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY NUMBER,
                x_msg_data             OUT NOCOPY VARCHAR2,
                p_legal_entity_id      IN         NUMBER,
                p_cost_group_id        IN         NUMBER,
                p_cost_type_id         IN         NUMBER,
                p_period_id            IN         NUMBER   := null,
                p_period_set_name      IN         VARCHAR2 := null,
                p_period_name          IN         VARCHAR2 := null,
                p_organization_id      IN         NUMBER,
                p_maint_cost_cat       IN         NUMBER,
                p_asset_group_id       IN         NUMBER,
                p_asset_number         IN         VARCHAR2,
                p_value                IN         NUMBER,
                p_column               IN         VARCHAR2,
                p_col_type             IN         NUMBER,
                p_period_start_date    IN         DATE,
                p_maintenance_object_id  IN       NUMBER,
                p_maintenance_object_type  IN       NUMBER,
                p_user_id              IN         NUMBER,
                p_request_id           IN         NUMBER,
                p_prog_id              IN         NUMBER,
                p_prog_app_id          IN         NUMBER,
                p_login_id             IN         NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'InsertUpdate_PAC_assetPerBal';
l_api_version  CONSTANT NUMBER := 1.0;

l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(8000);
l_api_message       VARCHAR2(1000);

l_statement         VARCHAR2(2000);

l_stmt_num          NUMBER := 10;
l_count             NUMBER := 0;

/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'InsertUpdate_PAC_assetPerBal <<');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT InsertUpdate_PAC_astPerBal_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if records already exist for the asset
    SELECT  count(*)
    INTO    l_count
    FROM    cst_pac_eam_asset_per_balances
    WHERE   period_set_name = p_period_set_name
    AND     period_name = p_period_name
    AND     organization_id = p_organization_id
    AND     inventory_item_id = p_asset_group_id
    AND     serial_number = p_asset_number
    AND     maint_cost_category = p_maint_cost_cat
    AND     cost_group_id = p_cost_group_id
    AND     cost_type_id = p_cost_type_id
    AND     legal_entity_id = p_legal_entity_id;

    l_stmt_num := 500;

    IF l_count > 0 THEN -- If records already exist then Update

        l_stmt_num := 505;

        l_statement := 'UPDATE cst_pac_eam_asset_per_balances SET '
                        || p_column || '='
                        || 'nvl('|| p_column || ',0) + nvl(:p_value,0)'
                        || ', last_update_date = sysdate'
                        || ', last_updated_by = :p_user_id'
                        || ' WHERE period_set_name = :p_period_set_name'
                        || ' AND period_name = :p_period_name'
                        || ' AND organization_id = :p_organization_id'
                        || ' AND inventory_item_id = :p_asset_group_id'
                        || ' AND serial_number = :p_asset_number'
                        || ' AND maint_cost_category = :p_maint_cost_cat'
                        || ' AND cost_group_id = :p_cost_group_id'
                        || ' AND cost_type_id = :p_cost_type_id'
                        || ' AND legal_entity_id = :p_legal_entity_id';

        EXECUTE IMMEDIATE l_statement
        USING p_value, p_user_id, p_period_set_name, p_period_name, p_organization_id, p_asset_group_id,
              p_asset_number, p_maint_cost_cat, p_cost_group_id, p_cost_type_id, p_legal_entity_id;

        l_stmt_num := 510;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Update Successful for Serial Number ' || TO_CHAR(p_asset_number));
        END IF;

    ELSE -- If no records exist, then Insert

        l_stmt_num := 515;

        INSERT INTO cst_pac_eam_asset_per_balances (
            legal_entity_id,
            cost_group_id,
            cost_type_id,
            period_set_name,
            period_name,
            pac_period_id,
            organization_id,
            inventory_item_id,
            serial_number,
            maint_cost_category,
            actual_mat_cost,
            actual_lab_cost,
            actual_eqp_cost,
            system_estimated_mat_cost,
            system_estimated_lab_cost,
            system_estimated_eqp_cost,
            period_start_date,
            maintenance_object_id,
            maintenance_object_type,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            request_id,
            program_application_id
        )
        VALUES (
            p_legal_entity_id,
            p_cost_group_id,
            p_cost_type_id,
            p_period_set_name,
            p_period_name,
            p_period_id,
            p_organization_id,
            p_asset_group_id,
            p_asset_number,
            p_maint_cost_cat,
            DECODE(p_col_type, 13, NVL(p_value,0),0),  -- actual mat
            DECODE(p_col_type, 12, NVL(p_value,0),0),  -- actual lab
            DECODE(p_col_type, 11, NVL(p_value,0),0),  -- actual eqp
            DECODE(p_col_type, 23, NVL(p_value,0),0),  -- sys est
            DECODE(p_col_type, 22, NVL(p_value,0),0),  -- sys est
            DECODE(p_col_type, 21, NVL(p_value,0),0),  -- sys est
            p_period_start_date,
            p_maintenance_object_id,
            p_maintenance_object_type,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_request_id,
            p_prog_app_id
        );

        l_stmt_num := 520;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Insert Successful for Serial Number ' || TO_CHAR(p_asset_number));
        END IF;

    END IF;        -- end checking asset balance rowcount

    l_stmt_num := 525;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.COUNT_AND_GET (p_count => x_msg_count,
                               p_data  => x_msg_data );

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'InsertUpdate_PAC_assetPerBal >>'
               );
    END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO InsertUpdate_PAC_astPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO InsertUpdate_PAC_astPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data   => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO InsertUpdate_PAC_astPerBal_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));

        END IF;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data   => x_msg_data);

END InsertUpdate_PAC_assetPerBal;



-- Start of comments
--  API name    : Compute_PAC_JobActuals
--  Type        : Public.
--  Function    : This API is called from CSTPPWRO.process_wip_resovhd_txns and
--                  CSTPPWMT.charge_wip_material
--                Flow:
--                |-- Get Period set name and Period name from Period ID passed
--                |-- Get asset group, asset number and maint obj for the wip_entity_id
--                |-- Derive the currency extended precision for the organization
--                |-- Get maint cost category
--                |-- Get eAM cost element
--                |   |-- If Direct Items use get_CostEle_for_DirectItem
--                |   |-- Else use Get_eamCostElement
--                |-- End If
--                |-- Call API InsertUpdate_PAC_eamPerBal to update eAM PAC tables.
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default =
--                                                        FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER   Default = null,
--              p_organization_id   IN  NUMBER,
--              p_txn_mode          IN  NUMBER,
--              p_txn_id            IN  NUMBER,
--              p_value             IN  NUMBER,
--              p_entity_id         IN  NUMBER,
--              p_op_seq            IN  NUMBER,
--              p_resource_id       IN  NUMBER,
--              p_resource_seq_num  IN  NUMBER,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure gets asset, cost element and category associations
--                for the actual txns and then calls API's to update PAC_EAM tables
--
-- End of comments

PROCEDURE Compute_PAC_JobActuals(
                    p_api_version      IN NUMBER,
                    p_init_msg_list    IN VARCHAR2,
                    p_commit           IN VARCHAR2,
                    p_validation_level IN NUMBER,
                    x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2,
                    p_legal_entity_id  IN NUMBER,
                    p_cost_group_id    IN NUMBER,
                    p_cost_type_id     IN NUMBER,
                    p_pac_period_id    IN NUMBER,
                    p_pac_ct_id        IN NUMBER,
                    p_organization_id  IN NUMBER,
                    p_txn_mode         IN NUMBER, -- To indicate Resource/Direct Item Txn
                    p_txn_id           IN NUMBER,
                    p_value            IN NUMBER,
                    p_wip_entity_id    IN NUMBER,
                    p_op_seq           IN NUMBER,
                    p_resource_id      IN NUMBER,
                    p_resource_seq_num IN NUMBER,
                    p_user_id          IN NUMBER,
                    p_request_id       IN NUMBER,
                    p_prog_app_id      IN NUMBER,
                    p_prog_id          IN NUMBER,
                    p_login_id         IN NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'Compute_PAC_JobActuals';
l_api_version  CONSTANT NUMBER := 1.0;

l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(8000);
l_api_message       VARCHAR2(1000);

l_stmt_num          NUMBER := 10;

l_pac_period_id        NUMBER := 0;
l_period_set_name      VARCHAR2(1000) := null;
l_period_name          VARCHAR2(1000) := null;
l_owning_dept_id       NUMBER := 0;
l_operation_dept_id    NUMBER := 0;
l_maint_cost_category  NUMBER := 0;
l_mnt_obj_id           NUMBER := 0;
l_eam_cost_element     NUMBER := 0;
l_asset_group_item_id  NUMBER := 0;
l_asset_number         VARCHAR2(30);
l_round_unit           NUMBER := 0;
l_precision            NUMBER := 0;
l_ext_precision        NUMBER := 0;

/* Log Severities*/
/* 6- UNEXPECTED */
/* 5- ERROR      */
/* 4- EXCEPTION  */
/* 3- EVENT      */
/* 2- PROCEDURE  */
/* 1- STATEMENT  */

/* In general, we should use the following:
G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
*/

l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Compute_PAC_JobActuals <<');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Compute_PAC_JobActuals_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 0;

    -- Get period details from period id
    SELECT cpp.PAC_PERIOD_ID,
           cpp.period_set_name,
           cpp.period_name
    INTO   l_pac_period_id,
           l_period_set_name,
           l_period_name
    FROM   CST_PAC_periods cpp
    WHERE  cpp.pac_period_id = p_pac_period_id;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'Period details retreived');
    END IF;

    l_stmt_num := 5;

    IF (l_pac_period_id IS NULL
        AND (l_period_set_name IS NULL OR l_period_name IS NULL)) THEN

        l_api_message := 'Cannot Find Period for the period_id ' || TO_CHAR(p_pac_period_id);
        l_msg_data := l_api_message;
        FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                l_api_name,
                                '(' || TO_CHAR(l_stmt_num) ||'): ' || l_api_message);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get the associated asset item
    CST_EAMCOST_PUB.GET_CHARGE_ASSET (
                      p_api_version           =>  1.0,
                      p_wip_entity_id         =>  p_wip_entity_id,
                      x_inventory_item_id     =>  l_asset_group_item_id,
                      x_serial_number         =>  l_asset_number,
                      x_maintenance_object_id =>  l_mnt_obj_id,
                      x_return_status         =>  l_return_status,
                      x_msg_count             =>  l_msg_count,
                      x_msg_data              =>  l_msg_data);

    l_stmt_num := 10;

    IF (L_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS) THEN
        l_api_message := 'CST_EAMCOST_PUB.GET_CHARGE_ASSET() returned error';
        l_msg_data := l_api_message;
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', 'CST_PacEamCost_GRP.Compute_PAC_JobActuals('
                                      || to_char(l_stmt_num) || '): '|| l_api_message);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'Got associated Asset Item');
    END IF;


   -- Derive the currency extended precision for the organization
    CSTPUTIL.CSTPUGCI(p_organization_id,
                      l_round_unit,
                      l_precision,
                      l_ext_precision);

    l_stmt_num := 15;

    IF (p_txn_mode = 17 ) then -- For Direct Item txns

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Processing for Direct Item');
        END IF;

        -- Get the associated maintainence cost category set by the user
        CST_EAMCOST_PUB.Get_MaintCostCat(
                         p_txn_mode       => 1,
                         p_wip_entity_id  => p_wip_entity_id,
                         p_opseq_num      => p_op_seq,
                         p_resource_id    => p_resource_id,
                         p_res_seq_num    => p_resource_seq_num,
                         x_return_status  => l_return_status,
                         x_operation_dept => l_operation_dept_id,
                         x_owning_dept    => l_owning_dept_id,
                         x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 20;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                    l_api_name,
                                    '(' || TO_CHAR(l_stmt_num) ||'): ' || l_api_message);
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Get direct item cost element
        CST_EAMCOST_PUB.get_CostEle_for_DirectItem (
                                p_api_version       =>  1.0,
                                p_init_msg_list     =>  p_init_msg_list,
                                p_commit            =>  p_commit,
                                p_validation_level  =>  p_validation_level,
                                x_return_status     =>  l_return_status,
                                x_msg_count         =>  l_msg_count,
                                x_msg_data          =>  l_msg_data,
                                p_txn_id            =>  p_txn_id,
                                p_mnt_or_mfg        =>  1,
                                p_pac_or_perp       =>  1, -- PAC calling
                                x_cost_element_id   =>  l_eam_cost_element);

        l_stmt_num := 25;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            l_api_message := 'CST_EAMCOST_PUB.get_CostEle_for_DirectItem returned error';
            l_msg_data := l_api_message;
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', 'CST_PacEamCost_GRP.Compute_PAC_JobActuals('
                                          || to_char(l_stmt_num) || '): ' || l_api_message);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Maint cost cat and cost element got for Direct Item');
        END IF;

    ELSE -- Not a direct Item

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Not a Direct Item');
        END IF;

        -- Get the associated maintainence cost category set by the user
        CST_EAMCOST_PUB.Get_MaintCostCat(
                         p_txn_mode       => p_txn_mode ,
                         p_wip_entity_id  => p_wip_entity_id,
                         p_opseq_num      => p_op_seq,
                         p_resource_id    => p_resource_id,
                         p_res_seq_num    => p_resource_seq_num,
                         x_return_status  => l_return_status,
                         x_operation_dept => l_operation_dept_id,
                         x_owning_dept    => l_owning_dept_id,
                         x_maint_cost_cat => l_maint_cost_category);

        l_stmt_num := 20;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_api_message := 'CST_EAMCOST_PUB.Get_MaintCostCat returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                    l_api_name,
                                    '(' || TO_CHAR(l_stmt_num) ||'): ' || l_api_message);
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Get eam cost element
        l_eam_cost_element := CST_EAMCOST_PUB.Get_eamCostElement(
                                                 p_txn_mode     =>  p_txn_mode,
                                                 p_org_id       =>  p_organization_id,
                                                 p_resource_id  =>  p_resource_id);

        l_stmt_num := 25;

        IF l_eam_cost_element = 0 THEN
            l_api_message := 'Get_eamCostElement returned error';
            l_msg_data := l_api_message;
            FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                    l_api_name,
                                    '(' || TO_CHAR(l_stmt_num) ||'): ' || l_api_message);
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- statement level logging
        IF (l_sLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || l_stmt_num,
                'Got Maint cost cat and cost element values');
        END IF;

    END IF; -- end direct item check

    l_stmt_num := 30;

    InsertUpdate_PAC_eamPerBal(
                    p_api_version      => 1.0,
                    x_return_status    => l_return_status,
                    x_msg_count        => l_msg_count,
                    x_msg_data         => l_msg_data,
                    p_legal_entity_id  => p_legal_entity_id,
                    p_cost_group_id    => p_cost_group_id,
                    p_cost_type_id     => p_cost_type_id,
                    p_period_id        => l_pac_period_id,
                    p_period_set_name  => l_period_set_name,
                    p_period_name      => l_period_name,
                    p_organization_id  => p_organization_id,
                    p_wip_entity_id    => p_wip_entity_id,
                    p_owning_dept_id   => l_owning_dept_id,
                    p_dept_id          => l_operation_dept_id,
                    p_maint_cost_cat   => l_maint_cost_category,
                    p_opseq_num        => p_op_seq,
                    p_eam_cost_element => l_eam_cost_element,
                    p_asset_group_id   => l_asset_group_item_id,
                    p_asset_number     => l_asset_number,
                    p_value_type       => 1, --Actuals
                    p_value            => p_value,
                    p_user_id          => p_user_id,
                    p_request_id       => p_request_id,
                    p_prog_id          => p_prog_id,
                    p_prog_app_id      => p_prog_app_id,
                    p_login_id         => p_login_id);

    l_stmt_num := 35;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_api_message := 'insertupdate_PAC_eamperbal() returned error';
        l_msg_data := l_api_message;
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                 l_api_name,
                                 '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                 || SUBSTRB (SQLERRM , 1 , 240));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- statement level logging
    IF (l_sLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_STATEMENT,
            l_module || '.' || l_stmt_num,
            'Insert/Update successful for Actuals');
    END IF;

    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    l_stmt_num := 40;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.COUNT_AND_GET (p_count => x_msg_count,
                               p_data  => x_msg_data );

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Compute_PAC_JobActuals >>'
               );
    END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO Compute_PAC_JobActuals_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO Compute_PAC_JobActuals_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data   => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Compute_PAC_JobActuals_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                     l_api_name,
                                     '(' || TO_CHAR(l_stmt_num) || '): ' || l_api_message
                                     || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        IF (l_uLog) THEN
            FND_LOG.STRING(
                FND_LOG.LEVEL_UNEXPECTED,
                l_module || '.' || l_stmt_num ,
                l_msg_data || SUBSTRB (SQLERRM , 1 , 240));
        END IF;

        --  Get message count and data
        FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                  p_data   => x_msg_data);


END Compute_PAC_JobActuals;


-- Start of comments
--  API name    : Insert_PAC_eamBalAcct
--  Type        : Public.
--  Function    : This API is called from CST_PacEamCost_GRP.Estimate_PAC_WipJobs.
--                The procedure inserts/updates data into CST_PAC_EAM_BALANCE_BY_ACCTS
--                table.
--                Flow:
--                |-- Verify if the estimation data already exists for the wip job
--                |   and GL Account for the given cost group and cost type.
--                |   |--If data already exists add the new acct_value to existing
--                |      acct_value
--                |   |--Else insert a new row into the table
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER
--              p_init_msg_list     IN  VARCHAR2
--              p_commit            IN  VARCHAR2
--              p_validation_level  IN  NUMBER
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER,
--              p_period_set_name   IN  VARCHAR2,
--              p_period_name       IN  VARCHAR2,
--              p_org_id            IN  NUMBER,
--              p_wip_entity_id     IN  NUMBER,
--              p_owning_dept_id    IN  NUMBER,
--              p_dept_id           IN  NUMBER,
--              p_maint_cost_cat    IN  NUMBER,
--              p_opseq_num         IN  NUMBER,
--              p_period_start_date IN  DATE,
--              p_account_ccid      IN  NUMBER,
--              p_value             IN  NUMBER,
--              p_txn_type          IN  NUMBER,
--              p_wip_acct_class    IN  VARCHAR2,
--              p_mfg_cost_element_id IN NUMBER,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--
-- End of comments
PROCEDURE Insert_PAC_eamBalAcct
(
        p_api_version         IN  NUMBER,
        p_init_msg_list       IN  VARCHAR2,
        p_commit              IN  VARCHAR2,
        p_validation_level    IN  NUMBER,
        x_return_status       OUT NOCOPY  VARCHAR2,
        x_msg_count           OUT NOCOPY  NUMBER,
        x_msg_data            OUT NOCOPY  VARCHAR2,
        p_legal_entity_id     IN  NUMBER,
        p_cost_group_id       IN  NUMBER,
        p_cost_type_id        IN  NUMBER,
        p_period_id           IN  NUMBER,
        p_period_set_name     IN  VARCHAR2,
        p_period_name         IN  VARCHAR2,
        p_org_id              IN  NUMBER,
        p_wip_entity_id       IN  NUMBER,
        p_owning_dept_id      IN  NUMBER,
        p_dept_id             IN  NUMBER,
        p_maint_cost_cat      IN  NUMBER,
        p_opseq_num           IN  NUMBER,
        p_period_start_date   IN  DATE,
        p_account_ccid        IN  NUMBER,
        p_value               IN  NUMBER,
        p_txn_type            IN  NUMBER,
        p_wip_acct_class      IN  VARCHAR2,
        p_mfg_cost_element_id   IN NUMBER,
        p_user_id             IN  NUMBER,
        p_request_id          IN  NUMBER,
        p_prog_id             IN  NUMBER,
        p_prog_app_id         IN  NUMBER,
        p_login_id            IN  NUMBER
)
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Insert_PAC_eamBalAcct';
    l_api_version    CONSTANT NUMBER := 1.0;

        l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
        l_module       CONSTANT VARCHAR2(60) := 'cst.plsql.'||l_full_name;

       /* Log Severities*/
       /* 6- UNEXPECTED */
       /* 5- ERROR      */
       /* 4- EXCEPTION  */
       /* 3- EVENT      */
       /* 2- PROCEDURE  */
       /* 1- STATEMENT  */

       /* In general, we should use the following:
          G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
          l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
          l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
          l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
          l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
          l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
          l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
       */

        l_uLog         CONSTANT BOOLEAN :=  FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND
                                            FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
        l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_cnt_cebba    NUMBER;
        l_stmt_num     NUMBER;

BEGIN
    -- Standard Start of API savepoint
        SAVEPOINT   Insert_PAC_eamBalAcct_PUB;

        if( l_pLog ) then
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start of ' || l_full_name || '(' ||
               'p_user_id=' || p_user_id || ',' ||
               'p_login_id=' || p_login_id ||',' ||
               'p_prog_app_id=' || p_prog_app_id ||',' ||
               'p_prog_id=' || p_prog_id ||',' ||
               'p_request_id=' || p_request_id ||',' ||
               'p_legal_entity_id=' || p_legal_entity_id ||',' ||
               'p_cost_group_id=' || p_cost_group_id ||',' ||
               'p_cost_type_id=' || p_cost_type_id ||',' ||
               'p_wip_entity_id=' || p_wip_entity_id ||',' ||
               'p_org_id=' || p_org_id ||',' ||
               'p_wip_acct_class=' || p_wip_acct_class ||',' ||
               'p_account_ccid=' || p_account_ccid ||',' ||
               'p_maint_cost_cat =' || p_maint_cost_cat  ||',' ||
               'p_opseq_num=' || p_opseq_num ||',' ||
               'p_mfg_cost_element_id=' || p_mfg_cost_element_id ||',' ||
               'p_dept_id=' || p_dept_id ||',' ||
               'p_value=' || p_value ||',' ||
               ')');
        end if;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version,
                                        p_api_version,
                                l_api_name ,
                                        'CST_eamCost_PUB')
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

        l_stmt_num := 10;

    --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        /* Update the record if already exists else insert a new one */

        MERGE INTO CST_PAC_EAM_BALANCE_BY_ACCTS  cebba
        USING
        (
         SELECT NULL FROM DUAL
        ) temp
        ON
        (
        cebba.legal_entity_id     = p_legal_entity_id AND
        cebba.cost_group_id       = p_cost_group_id AND
        cebba.cost_type_id        = p_cost_type_id AND
        cebba.period_set_name     = p_period_set_name AND
        cebba.period_name         = p_period_name AND
        cebba.wip_entity_id       = p_wip_entity_id AND
        cebba.organization_id     = p_org_id AND
        cebba.maint_cost_category = p_maint_cost_cat AND
        cebba.owning_dept_id      = p_owning_dept_id AND
        cebba.period_start_date   = p_period_start_date AND
        cebba.account_id          = p_account_ccid AND
        cebba.txn_type            = p_txn_type AND
        cebba.wip_acct_class_code = p_wip_acct_class AND
        cebba.mfg_cost_element_id = p_mfg_cost_element_id
        )
        WHEN MATCHED THEN
         UPDATE
                SET cebba.acct_value  = cebba.acct_value + p_value,
                cebba.LAST_UPDATE_DATE = sysdate,
                cebba.LAST_UPDATED_BY = p_user_id,
                cebba.LAST_UPDATE_LOGIN = p_login_id
        WHEN NOT MATCHED THEN
         INSERT
                (
                LEGAL_ENTITY_ID,
                COST_GROUP_ID,
                COST_TYPE_ID,
                PERIOD_SET_NAME,
                PERIOD_NAME,
                ACCT_PERIOD_ID,
                WIP_ENTITY_ID,
                ORGANIZATION_ID,
                OPERATIONS_DEPT_ID,
                OPERATIONS_SEQ_NUM,
                MAINT_COST_CATEGORY,
                OWNING_DEPT_ID,
                PERIOD_START_DATE,
                ACCOUNT_ID,
                ACCT_VALUE,
                TXN_TYPE,
                WIP_ACCT_CLASS_CODE,
                MFG_COST_ELEMENT_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN
                )VALUES
                (
                p_legal_entity_id,
                p_cost_group_id,
                p_cost_type_id,
                p_period_set_name,
                p_period_name     ,
                p_period_id      ,
                p_wip_entity_id,
                p_org_id  ,
                p_dept_id,
                p_opseq_num ,
                p_maint_cost_cat,
                p_owning_dept_id,
                p_period_start_date,
                p_account_ccid,
                p_value ,
                p_txn_type,
                p_wip_acct_class,
                p_mfg_cost_element_id,
                sysdate,
                p_user_id ,
                sysdate,
                p_prog_app_id ,
                p_login_id
                );

           if( l_sLog ) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                l_module || '.' || to_char(l_stmt_num),
                '.updated/inserted the record for :' || to_char(p_wip_entity_id)
                );
           end if;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;


       /* Procedure level log message for Exit point */
        IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'End of ' || l_full_name
               );
        END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
        );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Insert_PAC_eamBalAcct_PUB;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240)
                     );
                END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Insert_PAC_eamBalAcct_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240)
                     );
                END IF;

        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   'CST_eamCost_PUB'   ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );
END Insert_PAC_eamBalAcct;



-- Start of comments
--  API name    : Delete_PAC_eamBalAcct
--  Type        : Public.
--  Function    : This API is called from CST_PacEamCost_GRP.Estimate_PAC_WipJobs
--                Flow:
--                |-- Delete estimation data from CST_EAM_BALANCE_BY_ACCTS table for the
--                |   given legal entity id, cost group, cost type and wip job
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER
--              p_init_msg_list     IN  VARCHAR2
--              p_commit            IN  VARCHAR2
--              p_validation_level  IN  NUMBER
--
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_organization_id   IN  NUMBER,
--              p_wip_entity_id_tab IN  CST_PacEamCost_GRP.WIP_ENTITY_TYP,
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
-- End of comments
PROCEDURE Delete_PAC_eamBalAcct
(
        p_api_version       IN        NUMBER,
        p_init_msg_list     IN        VARCHAR2,
        p_commit        IN        VARCHAR2,
        p_validation_level  IN        NUMBER    ,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY VARCHAR2,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_wip_entity_id_tab     IN  CST_PacEamCost_GRP.G_WIP_ENTITY_TYP,
        p_legal_entity_id       IN        NUMBER,
        p_cost_group_id         IN        NUMBER,
        p_cost_type_id          IN        NUMBER

)
IS
    l_api_name  CONSTANT VARCHAR2(30) := 'Delete_PAC_eamBalAcct';
    l_api_version   CONSTANT NUMBER  := 1.0;

        l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
        l_module       CONSTANT VARCHAR2(60) :=  'cst.plsql.'||l_full_name;

        l_uLog         CONSTANT BOOLEAN :=  FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND
                                            FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_pLog         CONSTANT BOOLEAN :=  l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

        l_stmt_num     NUMBER;
BEGIN
    -- Standard Start of API savepoint
        SAVEPOINT   Delete_PAC_eamBalAcct_PUB;
        -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (l_api_version,
                                    p_api_version,
                            l_api_name ,
                                'CST_eamCost_PUB')
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

        if( l_pLog ) then
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start of ' || l_full_name);
        end if;


    --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 10;

       /* Delete data from CST_PAC_EAM_BALANCE_BY_ACCTS */
        FORALL l_index IN p_wip_entity_id_tab.FIRST..p_wip_entity_id_tab.LAST
    Delete from CST_PAC_EAM_BALANCE_BY_ACCTS
    where wip_entity_id = p_wip_entity_id_tab(l_index)
--        and organization_id=p_org_id                     -- sikhanna not required
        and legal_entity_id = p_legal_entity_id
        and cost_group_id = p_cost_group_id
        and cost_type_id = p_cost_type_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

       /* Procedure level log message for Exit point */
        IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'End of ' || l_full_name
               );
        END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
        );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_PAC_eamBalAcct_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     l_full_name ||'('|| l_stmt_num ||') :' ||
                     SUBSTRB (SQLERRM , 1 , 240));
                END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Delete_PAC_eamBalAcct_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     l_full_name ||'('|| l_stmt_num ||') :' ||
                     SUBSTRB (SQLERRM , 1 , 240));
                END IF;

        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   'CST_eamCost_PUB'   ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );
END Delete_PAC_eamBalAcct;

END CST_PacEamCost_GRP;

/
