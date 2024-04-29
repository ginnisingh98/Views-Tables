--------------------------------------------------------
--  DDL for Package Body CST_JOBCLOSEVAR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_JOBCLOSEVAR_GRP" AS
/* $Header: CSTGWJVB.pls 120.1 2005/08/04 14:59:09 visrivas noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):='CST_JobCloseVar_GRP';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Calculate_Job_Variance
(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        p_commit                IN      VARCHAR2,
        p_validation_level      IN      NUMBER,

        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,

        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_prg_appl_id           IN      NUMBER,
        p_prg_id                IN      NUMBER,
        p_req_id                IN      NUMBER,
        p_wcti_group_id         IN      NUMBER,
        p_org_id                IN      NUMBER
)
IS
    l_api_name     CONSTANT VARCHAR2(30) :='Calculate_Job_Variance';
    l_api_version  CONSTANT NUMBER       := 1.0;
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
    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
    */

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

    l_err_num               NUMBER;
    l_err_msg               VARCHAR2(240);
    l_err_code              VARCHAR2(240);
    l_costing_method        NUMBER;
    l_return_code           NUMBER;

    l_return_status         VARCHAR2(1);
    l_stmt_num              NUMBER;
    l_msg_data              VARCHAR2(240);

    /* SLA */
    TYPE l_num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_transaction_t  l_num_tab;
    l_index           NUMBER;

    CURSOR c_transactions IS
      SELECT TRANSACTION_ID
      FROM   WIP_COST_TXN_INTERFACE
      WHERE  GROUP_ID = p_wcti_group_id;

BEGIN

    /* Standard Start of API savepoint */
    SAVEPOINT   Calculate_Job_Variance_GRP;

    l_stmt_num := 0;
    /* Procedure level log message for Entry point */
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start of ' || l_full_name || '(' ||
               'p_user_id=' || p_user_id || ',' ||
               'p_login_id=' || p_login_id ||',' ||
               'p_prg_appl_id=' || p_prg_appl_id ||',' ||
               'p_prg_id=' || p_prg_id ||',' ||
               'p_req_id=' || p_req_id ||',' ||
               'p_wcti_group_id=' || p_wcti_group_id ||',' ||
               'p_org_id=' || p_org_id ||
               ')');
    END IF;

    /* Standard call to check for call compatibility. */
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*------------------------------------------------------------------------+
    |  Calling CSTPOYLD.transact_op_yield_var to calculate and account        |
    |  operation yield variance for lot based job.                            |
    +------------------------------------------------------------------------*/
    l_stmt_num := 10;

    l_return_code := CSTPOYLD.transact_op_yield_var (
                       p_wcti_group_id,
                       p_user_id,
                       p_login_id,
                       p_prg_appl_id,
                       p_prg_id,
                       p_req_id,
                       l_err_num,
                       l_err_code,
                       l_err_msg);

    IF (l_return_code <> 1) THEN
           l_msg_data := 'CSTPOYLD.transact_op_yield_var: ' || l_err_msg;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*------------------------------------------------------------------------+
    |   Check if any of the jobs have an asset route associated with it.      |
    |   CST_eamCost_PUB.Redistribute_WIP_Accounts redistributes accounts      |
    |   values from the Accounting class of the route job to the accounting   |
    |   class of the memeber assets.                                          |
    +------------------------------------------------------------------------*/
    l_stmt_num := 20;

    CST_eamCost_PUB.Redistribute_WIP_Accounts (
                    p_api_version             => 1.0,
                    p_wcti_group_id           => p_wcti_group_id,
                    p_user_id                 => p_user_id,
                    p_request_id              => p_req_id,
                    p_prog_id                 => p_prg_id,
                    p_prog_app_id             => p_prg_appl_id,
                    p_login_id                => p_login_id,
                    x_return_status           => l_return_status,
                    x_msg_count               => x_msg_count,
                    x_msg_data                => x_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           l_msg_data := 'Error in CST_eamCost_PUB.Redistribute_WIP_Accounts()';
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*------------------------------------------------------------------------+
    |   Post elemental variance for discrete and non-std jobs.                |
    |   Group same accounts. If the account is unique for the cost element    |
    |   then populate cost_element_id, otherwise, NULL.                       |
    |   Sum across all accounting periods and minus variance that has         |
    |   already been posted.                                                  |
    |   NOTE: The period close form gives warning if there is pending uncosted|
    |   txns.  But the user can go ahead closing the period.  This will       |
    |   cause In's and Out's of the period to be changed after the period     |
    |   is closed.  In order to recognize these late txns, need to sum        |
    |   across all accounting periods.                                        |
    +------------------------------------------------------------------------*/
    l_stmt_num := 30;

    INSERT INTO wip_transaction_accounts
                (transaction_id,
                reference_account,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                transaction_date,
                wip_entity_id,
                repetitive_schedule_id,
                accounting_line_type,
                transaction_value,
                base_transaction_value,
                contra_set_id,
                primary_quantity,
                rate_or_amount,
                basis_type,
                resource_id,
                cost_element_id,
                activity_id,
                currency_code,
                currency_conversion_date,
                currency_conversion_type,
                currency_conversion_rate,
                request_id,
                program_application_id,
                program_id,
                program_update_date)
    SELECT      wcti.transaction_id,
                DECODE(cce.cost_element_id,
                       1, wdj.material_account,
                       2, wdj.material_overhead_account,
                       3, wdj.resource_account,
                       4, wdj.outside_processing_account,
                       5, wdj.overhead_account),
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_login_id,
                wcti.organization_id,
                wcti.transaction_date,
                wcti.wip_entity_id,
                NULL,
                7,
                NULL,
                SUM(DECODE(cce.cost_element_id,
                          1, (NVL(wpb.pl_material_out,0)
                                  - NVL(wpb.pl_material_in,0)
                                  + NVL(wpb.pl_material_var,0)
                                  + NVL(wpb.tl_material_out,0)
                                  - 0
                                  + NVL(wpb.tl_material_var,0)),
                          2, (NVL(wpb.pl_material_overhead_out,0)
                                  - NVL(wpb.pl_material_overhead_in,0)
                                  + NVL(wpb.pl_material_overhead_var,0)
                                  + NVL(wpb.tl_material_overhead_out,0)
                                  - 0
                                  + NVL(wpb.tl_material_overhead_var,0)),
                          3, (NVL(wpb.pl_resource_out,0)
                                  - NVL(wpb.pl_resource_in,0)
                                  + NVL(wpb.pl_resource_var,0)
                                  + NVL(wpb.tl_resource_out,0)
                                  - NVL(wpb.tl_resource_in,0)
                                  + NVL(wpb.tl_resource_var,0)),
                          4, (NVL(wpb.pl_outside_processing_out,0)
                                  - NVL(wpb.pl_outside_processing_in,0)
                                  + NVL(wpb.pl_outside_processing_var,0)
                                  + NVL(wpb.tl_outside_processing_out,0)
                                  - NVL(wpb.tl_outside_processing_in,0)
                                  + NVL(wpb.tl_outside_processing_var,0)),
                          5, (NVL(wpb.pl_overhead_out,0)
                                  - NVL(wpb.pl_overhead_in,0)
                                  + NVL(wpb.pl_overhead_var,0)
                                  + NVL(wpb.tl_overhead_out,0)
                                  - NVL(wpb.tl_overhead_in,0)
                                  + NVL(wpb.tl_overhead_var,0)))),
                wcti.wip_entity_id,
                NULL,
                NULL,
                NULL,
                NULL,
                DECODE((MAX(cce.cost_element_id) - MIN(cce.cost_element_id)),
                       0, MAX(cce.cost_element_id), NULL),
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                p_req_id,
                p_prg_appl_id,
                p_prg_id,
                sysdate
    FROM        wip_cost_txn_interface wcti,
                wip_period_balances wpb,
                wip_discrete_jobs wdj,
                cst_cost_elements cce
    WHERE       wcti.group_id = p_wcti_group_id
    AND         wcti.wip_entity_id = wpb.wip_entity_id
    AND         wcti.wip_entity_id = wdj.wip_entity_id
    AND         wcti.acct_period_id >= wpb.acct_period_id
    GROUP BY    wcti.transaction_id,
                wcti.wip_entity_id,
                wcti.organization_id,
                wcti.transaction_date,
                decode(cce.cost_element_id,
                        1, wdj.material_account,
                        2, wdj.material_overhead_account,
                        3, wdj.resource_account,
                        4, wdj.outside_processing_account,
                        5, wdj.overhead_account);

    /*------------------------------------------------------------------------+
    |   Post single level variances for discrete and non-expense non-std jobs |
    |   NOTE: The period close form gives warning if there is pending uncosted|
    |   txns.  But the user can go ahead closing the period.  This will       |
    |   cause In's and Out's of the period to be changed after the period     |
    |   is closed.  In order to recognize these late txns, need to sum        |
    |  across all accounting periods.                                         |
    +------------------------------------------------------------------------*/
    l_stmt_num := 40;

    INSERT INTO wip_transaction_accounts
                (transaction_id,
                reference_account,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                transaction_date,
                wip_entity_id,
                repetitive_schedule_id,
                accounting_line_type,
                transaction_value,
                base_transaction_value,
                contra_set_id,
                primary_quantity,
                rate_or_amount,
                basis_type,
                resource_id,
                cost_element_id,
                activity_id,
                currency_code,
                currency_conversion_date,
                currency_conversion_type,
                currency_conversion_rate,
                request_id,
                program_application_id,
                program_id,
                program_update_date)
    SELECT      wcti.transaction_id,
                DECODE(cce.cost_element_id,
                       1, wdj.material_variance_account,
                       3, wdj.resource_variance_account,
                       4, wdj.outside_proc_variance_account,
                       5, wdj.overhead_variance_account),
                SYSDATE,
                p_user_id,
                SYSDATE,
                p_user_id,
                p_login_id,
                wcti.organization_id,
                wcti.transaction_date,
                wcti.wip_entity_id,
                NULL,
                8,
                NULL,
                SUM(DECODE(cce.cost_element_id,
                          1, -1 * ( NVL(wpb.pl_material_out,0)
                                  - NVL(wpb.pl_material_in,0)
                                  + NVL(wpb.pl_material_var,0)
                                  + NVL(wpb.pl_material_overhead_out,0)
                                  - NVL(wpb.pl_material_overhead_in,0)
                                  + NVL(wpb.pl_material_overhead_var,0)
                                  + NVL(wpb.pl_resource_out,0)
                                  - NVL(wpb.pl_resource_in,0)
                                  + NVL(wpb.pl_resource_var,0)
                                  + NVL(wpb.pl_overhead_out,0)
                                  - NVL(wpb.pl_overhead_in,0)
                                  + NVL(wpb.pl_overhead_var,0)
                                  + NVL(wpb.pl_outside_processing_out,0)
                                  - NVL(wpb.pl_outside_processing_in,0)
                                  + NVL(wpb.pl_outside_processing_var,0)
                                  + NVL(wpb.tl_material_out,0)
                                  - 0
                                  + NVL(wpb.tl_material_var,0)
                                  + NVL(wpb.tl_material_overhead_out,0)
                                  - 0
                                  + NVL(wpb.tl_material_overhead_var,0)),
                          3, -1 * ( NVL(wpb.tl_resource_out,0)
                                  - NVL(wpb.tl_resource_in,0)
                                  + NVL(wpb.tl_resource_var,0)),
                          4, -1 * ( NVL(wpb.tl_outside_processing_out,0)
                                  - NVL(wpb.tl_outside_processing_in,0)
                                  + NVL(wpb.tl_outside_processing_var,0)),
                          5, -1 * ( NVL(wpb.tl_overhead_out,0)
                                  - NVL(wpb.tl_overhead_in,0)
                                  + NVL(wpb.tl_overhead_var,0)))),
                wcti.wip_entity_id,
                NULL,
                NULL,
                NULL,
                NULL,
                DECODE((MAX(cce.cost_element_id) - MIN(cce.cost_element_id)),
                        0, MAX(cce.cost_element_id), NULL),
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                p_req_id,
                p_prg_appl_id,
                p_prg_id,
                SYSDATE
    FROM        wip_cost_txn_interface wcti,
                wip_period_balances wpb,
                wip_discrete_jobs wdj,
                cst_cost_elements cce
    WHERE       wcti.group_id = p_wcti_group_id
    AND         cce.cost_element_id <> 2
    AND         wcti.wip_entity_id = wpb.wip_entity_id
    AND         wcti.wip_entity_id = wdj.wip_entity_id
    AND         wcti.acct_period_id >= wpb.acct_period_id
    GROUP BY    wcti.transaction_id,
                wcti.wip_entity_id,
                wcti.organization_id,
                wcti.transaction_date,
                DECODE(cce.cost_element_id,
                       1, wdj.material_variance_account,
                       3, wdj.resource_variance_account,
                       4, wdj.outside_proc_variance_account,
                       5, wdj.overhead_variance_account);
    l_stmt_num := 45;
    OPEN c_transactions;
    FETCH c_transactions BULK COLLECT INTO l_transaction_t;
    CLOSE c_transactions;

    l_stmt_num := 46;
    FORALL l_index in l_transaction_t.FIRST..l_transaction_t.LAST
      UPDATE WIP_TRANSACTION_ACCOUNTS
      SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
      WHERE  TRANSACTION_ID    = l_transaction_t(l_index);

    l_stmt_num := 47;
    /* Create the Events for the transactions in the WCTI group */

    CST_XLA_PVT.CreateBulk_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_wcti_group_id    => p_wcti_group_id,
      p_organization_id  => p_org_id );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    /*------------------------------------------------------------------------+
    |   Update variance columns.                                              |
    |   While summing across wip_period_balance rows to accumulate costs we   |
    |   do not want the var values in the close period to get picked up. So   |
    |   we need them out with the decode. This is needed since wip now lets   |
    |   you re-open a closed job and variance could be posted multiple        |
    |   times in the same period if the job were closed repeatedly.           |
    +------------------------------------------------------------------------*/
    l_stmt_num := 50;

    UPDATE      wip_period_balances wpb
    SET         (last_updated_by,
                last_update_date,
                last_update_login,
                pl_material_var,
                pl_material_overhead_var,
                pl_resource_var,
                pl_outside_processing_var,
                pl_overhead_var,
                tl_material_var,
                tl_material_overhead_var,
                tl_resource_var,
                tl_outside_processing_var,
                tl_overhead_var )
                =
                (SELECT     p_user_id,
                            SYSDATE,
                            p_login_id,
                            SUM(  NVL(pl_material_in,0)
                                - NVL(pl_material_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(pl_material_var,0))),
                            SUM(  NVL(pl_material_overhead_in,0)
                                - NVL(pl_material_overhead_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(pl_material_overhead_var,0))),
                            SUM(  NVL(pl_resource_in,0)
                                - NVL(pl_resource_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(pl_resource_var,0))),
                            SUM(  NVL(pl_outside_processing_in,0)
                                - NVL(pl_outside_processing_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(pl_outside_processing_var,0))),
                            SUM(  NVL(pl_overhead_in,0)
                                - NVL(pl_overhead_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(pl_overhead_var,0))),
                            SUM(  0
                                - NVL(tl_material_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(tl_material_var,0))),
                            SUM(  0
                                - NVL(tl_material_overhead_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(tl_material_overhead_var,0))),
                            SUM(  NVL(tl_resource_in,0)
                                - NVL(tl_resource_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(tl_resource_var,0))),
                            SUM(  NVL(tl_outside_processing_in,0)
                                - NVL(tl_outside_processing_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(tl_outside_processing_var,0))),
                            SUM(  NVL(tl_overhead_in,0)
                                - NVL(tl_overhead_out,0)
                                - DECODE(wpb2.acct_period_id,
                                        wpb.acct_period_id,0,
                                        NVL(tl_overhead_var,0)))
                 FROM       wip_period_balances wpb2
                 WHERE      wpb2.wip_entity_id = wpb.wip_entity_id
                 AND        wpb2.acct_period_id <= wpb.acct_period_id)
    WHERE      (wpb.acct_period_id,
                wpb.wip_entity_id)
    IN         (SELECT      i.acct_period_id,
                            i.wip_entity_id
                FROM        wip_cost_txn_interface i
                WHERE       i.group_id = p_wcti_group_id);

    /*------------------------------------------------------------------------+
    |  Get the primary costing method of the Organization.                    |
    +------------------------------------------------------------------------*/
    l_stmt_num := 60;

    SELECT      primary_cost_method
    INTO        l_costing_method
    FROM        mtl_parameters
    WHERE       organization_id = p_org_id;

    /*------------------------------------------------------------------------+
    |  If primary_cost_method is average, FIFO or LIFO then update the        |
    |  value of variance relieved                                             |
    +------------------------------------------------------------------------*/
    l_stmt_num := 70;

    IF (l_costing_method IN (2, 5, 6)) THEN

        UPDATE   wip_req_operation_cost_details w
        SET      (relieved_variance_value)
                  =   (SELECT  NVL(applied_matl_value,0)
                              - NVL(relieved_matl_completion_value,0)
                              - NVL(relieved_matl_scrap_value,0)
                      FROM    wip_req_operation_cost_details w2
                      WHERE   w.wip_entity_id      = w2.wip_entity_id
                      AND     w.organization_id    = w2.organization_id
                      AND     w.inventory_item_id  = w2.inventory_item_id
                      AND     w.operation_seq_num  = w2.operation_seq_num
                      AND     w.cost_element_id    = w2.cost_element_id )
        WHERE    w.wip_entity_id
                 IN  (SELECT wip_entity_id
                      FROM    wip_cost_txn_interface wcti
                      WHERE   wcti.group_id = p_wcti_group_id );

        UPDATE   wip_operation_resources w
        SET      (relieved_variance_value)
                  =   (SELECT   NVL(applied_resource_value,0)
                               - NVL(relieved_res_completion_value,0)
                               - NVL(relieved_res_scrap_value,0)
                      FROM     wip_operation_resources w2
                      WHERE    w.wip_entity_id     = w2.wip_entity_id
                      AND      w.organization_id   = w2.organization_id
                      AND      w.operation_seq_num = w2.operation_seq_num
                      AND      w.resource_seq_num  = w2.resource_seq_num)
        WHERE    w.wip_entity_id
                 IN   (SELECT wip_entity_id
                      FROM    wip_cost_txn_interface wcti
                      WHERE   wcti.group_id = p_wcti_group_id);

        UPDATE   wip_operation_overheads w
        SET      (relieved_variance_value)
                 =    (SELECT  NVL(applied_ovhd_value,0)
                               - NVL(relieved_ovhd_completion_value,0)
                               - NVL(relieved_ovhd_scrap_value,0)
                      FROM     wip_operation_overheads w2
                      WHERE    w.wip_entity_id     = w2.wip_entity_id
                      AND      w.organization_id   = w2.organization_id
                      AND      w.operation_seq_num = w2.operation_seq_num
                      AND      w.resource_seq_num  = w2.resource_seq_num
                      AND      w.overhead_id       = w2.overhead_id
                      AND      w.basis_type        = w2.basis_type )
        WHERE    w.wip_entity_id
                 IN   (SELECT wip_entity_id
                      FROM    wip_cost_txn_interface wcti
                      WHERE   wcti.group_id = p_wcti_group_id);
    END IF;

    /*------------------------------------------------------------------------+
    |   Delete any balance rows beyond the job's close date (accounting       |
    |  period starting date > job close date)                                 |
    +------------------------------------------------------------------------*/
    l_stmt_num := 80;

    DELETE FROM     WIP_PERIOD_BALANCES wpb
    WHERE           (wpb.acct_period_id,
                    wpb.wip_entity_id)
    IN
        (SELECT     a.acct_period_id,
                    i.wip_entity_id
         FROM       wip_cost_txn_interface i,
                    org_acct_periods a
         WHERE      i.group_id = p_wcti_group_id
         AND        a.acct_period_id > i.acct_period_id
         AND        a.organization_id = i.organization_id);

    /*------------------------------------------------------------------------+
    |  Copy rows from wip_cost_txn_interface to wip_transactions and          |
    |  delete from wip_cost_txn_interface.                                    |
    +------------------------------------------------------------------------*/
    l_stmt_num := 90;

    l_err_num := CSTPWCPX.CMLCPX(p_wcti_group_id,
                            p_org_id,
                            6,
                            p_user_id,
                            p_login_id,
                            p_prg_appl_id,
                            p_prg_id,
                            p_req_id,
                            l_err_msg);

    IF (l_err_num <> 0) THEN
           l_msg_data := 'CSTPWCPX.CMLCPX: ' || l_err_msg;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Procedure level log message for Entry point */
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'End of ' || l_full_name
               );
    END IF;

    /* Get message count and if 1, return message data. */
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    /* Standard check of p_commit. */
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Calculate_Job_Variance_GRP;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            IF l_errorLog THEN
               FND_LOG.STRING(
                   FND_LOG.LEVEL_ERROR,
                   l_module || '.' || l_stmt_num,
                   l_msg_data
                   );
            END IF;

            /* Get message count and if 1, return message data. */
            FND_MSG_PUB.Count_And_Get
            (       p_count                 =>      x_msg_count,
                    p_data                  =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Calculate_Job_Variance_GRP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (l_exceptionLog) THEN
               FND_LOG.STRING(
                   FND_LOG.LEVEL_EXCEPTION,
                   l_module || '.' || l_stmt_num,
                   l_msg_data
                   );
            END IF;

            FND_MSG_PUB.Count_And_Get
            (       p_count                 =>      x_msg_count,
                    p_data                  =>      x_msg_data
            );

    WHEN OTHERS THEN
            ROLLBACK TO Calculate_Job_Variance_GRP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF (l_uLog) THEN
               FND_LOG.STRING(
                   FND_LOG.LEVEL_UNEXPECTED,
                   l_module || '.' || l_stmt_num,
                   SQLERRM
                   );
            END IF;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 240)
            );
            END IF;
            FND_MSG_PUB.Count_And_Get
            (       p_count                 =>      x_msg_count,
                    p_data                  =>      x_msg_data
            );

END Calculate_Job_Variance;

END CST_JobCloseVar_GRP;  /* end package body */

/
