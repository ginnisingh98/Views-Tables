--------------------------------------------------------
--  DDL for Package Body CSTPECEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPECEP" AS
/* $Header: CSTECEPB.pls 120.5.12010000.2 2012/03/23 01:41:33 fayang ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSTPECEP';

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       estimate_wip_jobs                                                    |
|                                                                            |
|  p_job_otion  :                                                            |
|             1:  All Jobs                                                   |
|             2:  Specific job                                               |
|             3:  All Jobs for an asset                                      |
|             4:  All Jobs for an department                                 |
|                                                                            |
|  Estimation Status    :                                                    |
|             NULL,1:  Pending                                               |
|             -ve   :  Running                                               |
|                  3:  Error                                                 |
|                  7:  Complete                                              |
|                                                                            |
|  PARAMETERS                                                                |
|             p_organization_id                                              |
|             p_entity_type                                                  |
|             p_job_option                                                   |
|             p_wip_entity_id                                                |
|             p_inventory_item_id                                            |
|             p_asset_number                                                 |
|             p_owning_department_id                                         |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE estimate_wip_jobs(
        errbuf                     OUT NOCOPY           VARCHAR2,
        retcode                    OUT NOCOPY           NUMBER,
        p_organization_id          IN           NUMBER,
        p_entity_type              IN           NUMBER   DEFAULT 6,
        p_job_option               IN           NUMBER   DEFAULT 1,
        p_item_dummy               IN           NUMBER   DEFAULT NULL,
        p_job_dummy                IN           NUMBER   DEFAULT NULL,
        p_owning_department_dummy  IN           NUMBER   DEFAULT NULL,
        p_wip_entity_id            IN           NUMBER   DEFAULT NULL,
        p_inventory_item_id        IN           NUMBER   DEFAULT NULL,
        p_asset_number             IN           VARCHAR2 DEFAULT NULL,
        p_owning_department_id     IN           NUMBER   DEFAULT NULL
)
IS

l_dummy                         NUMBER;
l_debug                         VARCHAR2(80);
l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(8000) := '';

l_err_num                       NUMBER := 0;
l_err_code                      VARCHAR2(240) := '';
l_err_msg                       VARCHAR2(240) := '';

l_stmt_num                      NUMBER := 0;
l_request_id                    NUMBER := 0;
l_user_id                       NUMBER := 0;
l_prog_id                       NUMBER := 0;
l_prog_app_id                   NUMBER := 0;
l_login_id                      NUMBER := 0;
l_conc_program_id               NUMBER := 0;

l_estimation_group_id           NUMBER := 0;
l_current_wip_id                NUMBER := 0;
/*l_update_wip_job_flag         NUMBER := 1;*/

conc_status                     BOOLEAN;
/*cst_process_error             EXCEPTION;*/
process_error                   EXCEPTION;

l_entity_id_tab CSTPECEP.wip_entity_id_type;
l_maint_organization_id         NUMBER;

BEGIN

        ---------------------------------------------------------------------
        -- Initializing Variables
        ---------------------------------------------------------------------
        l_err_num       := 0;
        l_err_code      := '';
        l_err_msg       := '';

        l_request_id    := 0;
        l_user_id       := 0;
        l_prog_id       := 0;
        l_prog_app_id   := 0;
        l_login_id      := 0;

        ----------------------------------------------------------------------
        -- retrieving concurrent program information
        ----------------------------------------------------------------------
        l_stmt_num := 5;

        l_request_id       := FND_GLOBAL.conc_request_id;
        l_user_id          := FND_GLOBAL.user_id;
        l_prog_id          := FND_GLOBAL.conc_program_id;
        l_prog_app_id      := FND_GLOBAL.prog_appl_id;
        l_login_id         := FND_GLOBAL.conc_login_id;
        l_conc_program_id  := FND_GLOBAL.conc_program_id;

        l_debug            := FND_PROFILE.VALUE('MRP_DEBUG');

        l_stmt_num := 10;

        IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'request_id: '
                                        ||to_char(l_request_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'prog_appl_id: '
                                        ||to_char(l_prog_app_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_user_id: '
                                        ||to_char(l_user_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_program_id: '
                                        ||to_char(l_prog_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_login_id: '
                                        ||to_char(l_login_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_conc_program_id: '
                                        ||to_char(l_conc_program_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debug: '
                                        ||l_debug);


        FND_FILE.PUT_LINE(FND_FILE.LOG, '  ');

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Organization: '
                                        ||TO_CHAR(p_organization_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Option: '
                                        ||TO_CHAR(p_job_option));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'WIP Entity Id: '
                                        ||TO_CHAR(p_wip_entity_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inventory Item Id: '
                                        ||TO_CHAR(p_inventory_item_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Asset Number: '
                                        ||p_asset_number);

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Owning Dept Id: '
                                        ||TO_CHAR(p_owning_department_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, '  ');

        END IF;

        l_stmt_num := 15;

        IF ((p_job_option = 2 AND p_wip_entity_id IS NULL) OR
              (p_job_option = 3 AND p_inventory_item_id IS NULL) OR
                (p_job_option = 4 AND p_owning_department_id IS NULL) OR
                  (p_entity_type NOT IN (1,6)))
        THEN

                l_err_code := 'Invalid Program Argument Combination';

                l_err_num  := 2002;
                l_err_msg  := 'CSTPECEP.estimate_wip_jobs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||l_err_code;
                IF l_debug = 'Y' THEN
                FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
                END IF;
                CONC_STATUS := FND_CONCURRENT.
                                SET_COMPLETION_STATUS('ERROR',l_err_msg);
        ELSE

        l_stmt_num := 17;

        SELECT  -1 * cst_wip_cost_estimates_s.nextval
        INTO    l_estimation_group_id
        FROM    DUAL;

        /* Select Maintenance organization id for this org. The work order will be created
           in maintenance org only. That would mean that all wip table will store the
           WO details against the maintenance organization id */
        select maint_organization_id
        into l_maint_organization_id
        from mtl_parameters where organization_id = p_organization_id; /* Bug 5203079*/

        l_stmt_num := 20;

            IF p_job_option = 1 THEN

                UPDATE  wip_discrete_jobs wdj -- job_option 1
                SET     wdj.estimation_status = l_estimation_group_id,
                    wdj.last_update_date      = SYSDATE,
                    wdj.last_updated_by      = l_user_id,
                    wdj.request_id            = l_request_id
                WHERE WDJ.organization_id = l_maint_organization_id
                AND NVL(WDJ.estimation_status,1) <> 7
                AND NVL(WDJ.estimation_status,1) > 0
                AND WDJ.status_type IN (1,3,4,6,17)
                AND p_job_option = 1
                AND p_entity_type IN (1,6)
                AND EXISTS ( SELECT 'X'
                         FROM  wip_entities we
                         WHERE  we.wip_entity_id = wdj.wip_entity_id
                         AND    we.entity_type = p_entity_type
                       )RETURNING wdj.wip_entity_id BULK COLLECT INTO l_entity_id_tab;

            ELSIF p_job_option = 2 THEN

                UPDATE  wip_discrete_jobs wdj -- job_option 2
                SET     wdj.estimation_status = l_estimation_group_id,
                    wdj.last_update_date      = SYSDATE,
                    wdj.last_updated_by      = l_user_id,
                    wdj.request_id            = l_request_id
                WHERE WDJ.organization_id = l_maint_organization_id
                AND NVL(WDJ.estimation_status,1) <> 7
                AND NVL(WDJ.estimation_status,1) > 0
                AND WDJ.status_type IN (1,3,4,6,17)
                AND p_job_option = 2
                AND WDJ.wip_entity_id = p_wip_entity_id
                RETURNING wdj.wip_entity_id BULK COLLECT INTO l_entity_id_tab;

            ELSIF p_job_option = 3 AND p_entity_type=1 THEN

                UPDATE  wip_discrete_jobs wdj -- option 3 entity_type 1, primary_item_id
                SET     wdj.estimation_status = l_estimation_group_id,
                    wdj.last_update_date      = SYSDATE,
                    wdj.last_updated_by      = l_user_id,
                    wdj.request_id            = l_request_id
                WHERE WDJ.organization_id = l_maint_organization_id
                AND NVL(wdj.estimation_status,1) <> 7
                AND NVL(wdj.estimation_status,1) > 0
                AND WDJ.status_type IN (1,3,4,6,17)
                AND p_job_option = 3
                AND WDJ.primary_item_id = p_inventory_item_id
                AND p_entity_type = 1
                AND EXISTS ( SELECT 'X'
                         FROM  wip_entities WE
                         WHERE WE.wip_entity_id = WDJ.wip_entity_id
                         AND   WE.entity_type = p_entity_type
                       )
                RETURNING wdj.wip_entity_id BULK COLLECT INTO l_entity_id_tab;

            ELSIF p_job_option = 3 AND p_entity_type=6 THEN

                UPDATE  wip_discrete_jobs wdj -- job_option 3 entity_type 6
                SET     wdj.estimation_status = l_estimation_group_id,
                    wdj.last_update_date      = SYSDATE,
                    wdj.last_updated_by      = l_user_id,
                    wdj.request_id            = l_request_id
                WHERE wdj.organization_id = l_maint_organization_id
                AND NVL(wdj.estimation_status,1) <> 7
                AND NVL(wdj.estimation_status,1) > 0
                AND wdj.status_type IN (1,3,4,6,17)
                AND p_job_option = 3
                AND wdj.maintenance_object_id in
                (select cii.instance_id
                 from csi_item_instances cii
                 where cii.instance_number = p_asset_number
                 AND cii.inventory_item_id = p_inventory_item_id
                )
                AND wdj.maintenance_object_type = 3
                AND p_entity_type = 6
                RETURNING wdj.wip_entity_id BULK COLLECT INTO l_entity_id_tab;

            ELSIF p_job_option = 4 THEN

                UPDATE  wip_discrete_jobs wdj -- option 4
                SET     wdj.estimation_status = l_estimation_group_id,
                    wdj.last_update_date      = SYSDATE,
                    wdj.last_updated_by      = l_user_id,
                    wdj.request_id            = l_request_id
                WHERE wdj.organization_id = l_maint_organization_id
                AND NVL(wdj.estimation_status,1) <> 7
                AND NVL(wdj.estimation_status,1) > 0
                AND wdj.status_type IN (1,3,4,6,17)
                AND p_job_option = 4
                AND wdj.owning_department = p_owning_department_id
                AND p_entity_type = 6
                RETURNING wdj.wip_entity_id BULK COLLECT INTO l_entity_id_tab;

            END IF;

        IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
                            ||' Job Record(s) Updated with Group Id: '
                            ||TO_CHAR(l_estimation_group_id));

        FND_FILE.PUT_LINE(FND_FILE.LOG, '  ');
        END IF;

        COMMIT;

       l_stmt_num := 22;
       /* Delete from the global temp table just to make sure it is empty */
       DELETE FROM cst_eam_direct_items_temp;

       l_stmt_num := 24;

       /* Populate the Global Temp Table that replaces WEDIV */
       CST_eamCost_PUB.Insert_tempEstimateDetails (
                p_api_version     => 1.0,
                x_return_status   => l_return_status,
                x_msg_count       => l_msg_count,
                x_msg_data        => l_msg_data,
                p_entity_id_tab   => l_entity_id_tab
                );


        --------------------------------------------------------------------
        -- Processs WIP Jobs
        --------------------------------------------------------------------
        -- Have a savepoint before starting the job. This is main savepoint
           SAVEPOINT CSTPECEP_MAIN_PUB;

        l_stmt_num := 30;

        IF l_entity_id_tab.COUNT > 0 THEN

            -- Delete existing estimates
            -- The estimate may have been rolled up to asset

                 CST_EAMCOST_PUB.delete_eamperbal(
                            p_api_version          => 1.0,
                            p_init_msg_list        => FND_API.g_false,
                            p_entity_id_tab  => l_entity_id_tab,
                            p_org_id               => l_maint_organization_id,
                            p_type                 => 1,
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);

                 IF l_return_status <> FND_API.g_ret_sts_success THEN


                 CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_msg_return_status);

                 l_err_code := 'Error: CSTEAM_COST_PUB.delete_eamperbal()';

                 RAISE process_error;

                END IF;

 /* the following lines delete the rows for this wip entity ID from the table
    CST_EAM_WO_ESTIMATE_DETAILS */

                l_stmt_num := 32;

           FORALL l_index IN l_entity_id_tab.FIRST..l_entity_id_tab.LAST
               Delete from CST_EAM_WO_ESTIMATE_DETAILS
               where wip_entity_id = l_entity_id_tab(l_index);

           /* Added the call to Delete_eamBalAcct as part of eAM
              Requirements Project - R12. The procedure deletes the
              rows for this wip entity ID from the table
              WIP_EAM_BALANCE_BY_ACCOUNTS */

                l_stmt_num := 35;
                CST_eamCost_PUB.Delete_eamBalAcct(
                            p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_FALSE,
                            p_commit            => FND_API.G_FALSE,
                            p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     => l_return_status,
                            x_msg_count         => l_msg_count,
                            x_msg_data          => l_msg_data,
                            p_entity_id_tab     => l_entity_id_tab,
                            p_org_id            => l_maint_organization_id
                    ) ;

                IF l_return_status <> FND_API.g_ret_sts_success THEN

                 CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_msg_return_status);

                 l_err_code := 'Error: CST_EAMCOST_PUB.Delete_eamBalAcct()';

                 RAISE process_error;

                END IF;

                IF l_return_status <> FND_API.g_ret_sts_success THEN

                 CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_msg_return_status);

                 l_err_code := 'Error: CST_eamCost_PUB.Insert_tempEstimateDetails()';

                 RAISE process_error;

                END IF;

                l_stmt_num := 38;

                FOR l_index IN l_entity_id_tab.FIRST..l_entity_id_tab.LAST LOOP
                BEGIN

                    -- Have an intermediate savepoint. Its position is updated as and when
                    -- we have a successful completion. We would rollback only errored out estimation
                    SAVEPOINT CSTPECEP_INT_PUB;

                         l_stmt_num := 40;

                          CST_EAMCOST_PUB.compute_job_estimate
                                          ( p_api_version           => 1.0,
                                          p_init_msg_list           => FND_API.g_true,
                                          p_debug                 => l_debug,
                                          p_wip_entity_id         => l_entity_id_tab(l_index),
                                          p_user_id               => l_user_id,
                                          p_request_id            => l_request_id,
                                          p_prog_id               => l_prog_id,
                                          p_prog_app_id           => l_prog_app_id,
                                          p_login_id              => l_login_id,
                                          x_return_status         => l_return_status,
                                          x_msg_count             => l_msg_count,
                                          x_msg_data              => l_msg_data);

                IF l_return_status <> FND_API.g_ret_sts_success THEN

                CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_msg_return_status);

                l_err_code := 'Error: CSTEAM_COST_PUB.compute_job_estimate()';

                RAISE process_error;

                END IF;

                l_stmt_num := 45;

                CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_msg_return_status);

/* the following statement sets the status to re estimate if the status of the
  job is 9(re estimate and runnin, otherwise the status is set to 7(complete) */


                UPDATE  wip_discrete_jobs wdj
                SET     estimation_status     = decode(estimation_status,9,8,7),
                    last_estimation_date  = SYSDATE,
                    last_estimation_req_id = l_request_id,
                    last_update_date      = SYSDATE
                WHERE   wdj.wip_entity_id = l_entity_id_tab(l_index);

          EXCEPTION
                   WHEN PROCESS_ERROR THEN

                   ROLLBACK TO CSTPECEP_INT_PUB;

                   UPDATE wip_discrete_jobs
                   SET    estimation_status = 3,
                         last_update_date  = SYSDATE,
                         last_estimation_date = SYSDATE,
                         last_estimation_req_id = l_request_id
                   WHERE  wip_entity_id     = l_entity_id_tab(l_index);


                    l_err_num  := 2002;
                    l_err_msg  := 'CSTPECEP.estimate_wip_jobs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||l_err_code;
                    IF l_debug = 'Y' THEN
                    FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
                    END IF;
            END;

        END LOOP; -- End l_entity_id_tab loop
    END IF;   --  checking for count

  END IF;   -- Main If

  COMMIT;  -- All Done. Commit

EXCEPTION

        WHEN OTHERS THEN

                -- Rollback all. Even last estimation data is restored. That is primary reason
                -- of having this main Savepoint. This is done only in some unexpected exception
                ROLLBACK TO CSTPECEP_MAIN_PUB;

                FORALL l_index IN l_entity_id_tab.FIRST..l_entity_id_tab.LAST
                UPDATE wip_discrete_jobs
                SET    estimation_status = 1,
                       last_update_date  = SYSDATE,
                         last_estimation_date = SYSDATE,
                         last_estimation_req_id = l_request_id
                WHERE  estimation_status = l_estimation_group_id
                AND    wip_entity_id = l_entity_id_tab(l_index);

                l_err_num := SQLCODE;
                l_err_code := NULL;
                l_err_msg := SUBSTR('CSTPECEP.estimate_wip_jobs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
                IF l_debug = 'Y' THEN
                FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
                END IF;
                CONC_STATUS := FND_CONCURRENT.
                                SET_COMPLETION_STATUS('ERROR',l_err_msg);
                COMMIT;


END estimate_wip_jobs;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       Estimate_WorkOrder_GRP                                               |
|                                                                            |
|       API provided for online estimation of workorder.                     |
|       WDJ.estimation_status should be set to Running and Committed         |
|       before calling this API. This is to prevent concurrency issues       |
|       if there is a Cost Estimation Concurrent request currently           |
|       running.                                                             |
|                                                                            |
|       This API has been added as part of estimation enhancements for       |
|       Patchset I.                                                          |
|                                                                            |
|  PARAMETERS                                                                |
|             p_organization_id                                              |
|             p_wip_entity_id                                                |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE Estimate_WorkOrder_GRP(
        p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2,
        p_commit                IN              VARCHAR2,
        p_validation_level      IN              NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        p_organization_id       IN              NUMBER,
        p_wip_entity_id         IN              NUMBER,
        p_delete_only           IN              VARCHAR2 := 'N'
)
IS

l_api_name                      CONSTANT VARCHAR2(30) := 'Estimate_WorkOrder';
l_api_version                   CONSTANT NUMBER       := 1.0;

l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(8000) := '';
l_api_message                   VARCHAR2(1000) := '';

l_stmt_num                      NUMBER := 0;
l_request_id                    NUMBER := 0;
l_user_id                       NUMBER := 0;
l_prog_id                       NUMBER := 0;
l_prog_app_id                   NUMBER := 0;
l_login_id                      NUMBER := 0;
l_conc_program_id               NUMBER := 0;

l_entity_id_tab CSTPECEP.wip_entity_id_type;


BEGIN

     --  Standard Start of API savepoint
         SAVEPOINT Estimate_WorkOrder_GRP;

        l_stmt_num := 5;

     -- Standard call to check for call compatibility
         IF NOT FND_API.Compatible_API_Call( l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
        END IF;

     -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_entity_id_tab(1) := p_wip_entity_id; -- Bug#4239253 PL/SQL table to be used instead of p_wip_entity_id


        l_stmt_num := 10;

        l_request_id       := FND_GLOBAL.conc_request_id;
        l_user_id          := FND_GLOBAL.user_id;
        l_prog_id          := FND_GLOBAL.conc_program_id;
        l_prog_app_id      := FND_GLOBAL.prog_appl_id;
        l_login_id         := FND_GLOBAL.conc_login_id;
        l_conc_program_id  := FND_GLOBAL.conc_program_id;

        --------------------------------------------------------------------
        -- Processs WorkOrder
        --------------------------------------------------------------------

        l_stmt_num := 20;
     -- Delete existing estimates
     -- The estimate may have been rolled up to asset

        CST_EAMCOST_PUB.delete_eamperbal(
                            p_api_version          => 1.0,
                            p_init_msg_list        => FND_API.g_false,
                            p_entity_id_tab        => l_entity_id_tab,
                            p_org_id               => p_organization_id,
                            p_type                 => 1,
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);

        IF l_return_status <> FND_API.g_ret_sts_success THEN

                l_api_message := 'Error: CST_EAMCOST_PUB.delete_eamperbal()';

                FND_MSG_PUB.ADD_EXC_MSG('CSTPECEP', 'ESTIMATE_WORKORDER('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
                RAISE FND_API.g_exc_error;

        END IF;

        /* the following lines delete the rows for this wip entity ID from the table
           CST_EAM_WO_ESTIMATE_DETAILS */

        l_stmt_num := 30;

        Delete from CST_EAM_WO_ESTIMATE_DETAILS
        where wip_entity_id = l_entity_id_tab(1);

           /* Added the call to Delete_eamBalAcct as part of eAM
              Requirements Project - R12. The procedure deletes the
              rows for this wip entity ID from the table
              WIP_EAM_BALANCE_BY_ACCOUNTS */

                l_stmt_num := 35;
                CST_eamCost_PUB.Delete_eamBalAcct(
                            p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_FALSE,
                            p_commit            => FND_API.G_FALSE,
                            p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     => l_return_status,
                            x_msg_count         => l_msg_count,
                            x_msg_data          => l_msg_data,
                            p_entity_id_tab     => l_entity_id_tab,
                            p_org_id            => p_organization_id
                    ) ;

                IF l_return_status <> FND_API.g_ret_sts_success THEN

                   l_api_message := 'Error: CST_EAMCOST_PUB.Delete_eamBalAcct()';

                   FND_MSG_PUB.ADD_EXC_MSG('CSTPECEP', 'ESTIMATE_WORKORDER('
                                         ||TO_CHAR(l_stmt_num)
                                         ||'): ', l_api_message);
                   RAISE FND_API.g_exc_error;

                END IF;


                DELETE FROM cst_eam_direct_items_temp;

                l_stmt_num := 36;

      IF (NVL(p_delete_only, 'N') = 'N') THEN

                l_stmt_num := 37;

                /* Populate the Global Temp Table that replaces WEDIV */
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

                l_stmt_num := 38;


        l_stmt_num := 40;

        CST_EAMCOST_PUB.compute_job_estimate
                            (p_api_version           => 1.0,
                             p_init_msg_list         => FND_API.g_false,
                             p_debug                 => 'N',
                             p_wip_entity_id         => l_entity_id_tab(1),
                             p_user_id               => l_user_id,
                             p_request_id            => l_request_id,
                             p_prog_id               => l_prog_id,
                             p_prog_app_id           => l_prog_app_id,
                             p_login_id              => l_login_id,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data);

        IF l_return_status <> FND_API.g_ret_sts_success THEN

                l_api_message := 'Error: CST_EAMCOST_PUB.compute_job_estimate()';

                FND_MSG_PUB.ADD_EXC_MSG('CSTPECEP', 'ESTIMATE_WORKORDER('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
                RAISE FND_API.g_exc_error;

        END IF;

        l_stmt_num := 50;

/* the following statement sets the status to re estimate if the status of the
  job is 9(re estimate and runnin, otherwise the status is set to 7(complete) */


        UPDATE  wip_discrete_jobs wdj
        SET     estimation_status     = decode(estimation_status,9,8,7),
                last_estimation_date  = SYSDATE,
                last_estimation_req_id = l_request_id,
                last_update_date      = SYSDATE
        WHERE   wdj.wip_entity_id = l_entity_id_tab(1);

      END IF; -- p_delete_only check

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO Estimate_WorkOrder_GRP;

      UPDATE wip_discrete_jobs
      SET    estimation_status = 3,
             last_update_date  = SYSDATE,
             last_estimation_date = SYSDATE,
             last_estimation_req_id = l_request_id
      WHERE  wip_entity_id     = l_entity_id_tab(1);

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO Estimate_WorkOrder_GRP;

      UPDATE wip_discrete_jobs
      SET    estimation_status = 3,
             last_update_date  = SYSDATE,
             last_estimation_date = SYSDATE,
             last_estimation_req_id = l_request_id
      WHERE  wip_entity_id     = l_entity_id_tab(1);

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --

   WHEN OTHERS THEN
      ROLLBACK TO Estimate_WorkOrder_GRP;


      UPDATE wip_discrete_jobs
      SET    estimation_status = 3,
             last_update_date  = SYSDATE,
             last_estimation_date = SYSDATE,
             last_estimation_req_id = l_request_id
      WHERE  wip_entity_id     = l_entity_id_tab(1);

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CSTPECEP'
              , 'Estimate_WorkOrder : l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END Estimate_WorkOrder_GRP;



END CSTPECEP;

/
