--------------------------------------------------------
--  DDL for Package Body CST_COSTPROCVALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_COSTPROCVALIDATION_PVT" AS
/* $Header: CSTVCPVB.pls 120.3.12010000.2 2010/08/19 20:05:43 vjavli ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_CostProcValidation_PVT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- PROCEDURE
--  Validate_Transactions      validates inventory transactions
--
PROCEDURE Validate_Transactions(
    x_return_status            OUT NOCOPY VARCHAR2)
IS
   l_api_name CONSTANT VARCHAR2(30) := 'Validate_Transactions';
   l_stmt_num  NUMBER;
   l_application_id NUMBER;
   l_concurrent_program_name VARCHAR2(10);
   l_cmcmcw_prog_id NUMBER;
   l_cmcacw_prog_id NUMBER;
   l_cmclcw_prog_id NUMBER;
   l_error_code VARCHAR2(240);
   l_error_expl VARCHAR2(240);

   l_start_date              DATE;
   l_org_code                VARCHAR2(4);
   l_count                   NUMBER;

   CURSOR orgs_to_process
   IS
     SELECT DISTINCT organization_id
     FROM   mtl_material_transactions
     WHERE  costed_flag = 'N';

   /* Period Close Diagnostics: Added new cursor */
   CURSOR orgs_with_error
   IS
     SELECT mp.organization_code,
            count (transaction_id)
     FROM   mtl_material_transactions mmt,
            mtl_parameters mp
     WHERE  mmt.costed_flag = 'E'
     AND    mmt.last_update_date >= l_start_date
     AND    mp.organization_id = mmt.organization_id
     GROUP BY mp.organization_code;

   l_org_id NUMBER;
   l_legal_entity NUMBER;
   l_timezone_offset NUMBER;
   l_pjm_installed BOOLEAN;

   l_last_updated_by         NUMBER;
   l_last_update_login       NUMBER;
   l_program_application_id  NUMBER;
   l_program_id              NUMBER;
   l_request_id              NUMBER;

   l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
   l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

   l_uLog  CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN
   l_application_id := 702;
   l_last_updated_by         := fnd_global.user_id;
   l_last_update_login       := fnd_global.login_id;
   l_program_application_id  := fnd_global.prog_appl_id;
   l_program_id              := fnd_global.conc_program_id;
   l_request_id              := fnd_global.conc_request_id;

   l_start_date              := sysdate;

   SAVEPOINT CST_Validate_Transactions_PVT;

   /*------------------------------------------------------------+
    |  Check for orphaned transactions:
    |  reset transaction group id for the transactions that have
    |  costed_flag = 'N' and one of the following conditions:
    |
    |  - the assigned worker is not in some incomplete status
    |    (Pending, Running, or Inactive)
    |
    |  - the assigned worker is no longer in the table
    |    FND_CONCURRENT_REQUESTS
    |
    |  * Note that logical transactions (part of global drop ship
    |    project for J) will not be resubmitted even if they are
    |    marked as costed_flag = 'N'. This is because the parent
    |    physical transaction could have errored out.
    +------------------------------------------------------------*/

   l_stmt_num := 10;
   /* retrieve material cost worker program ID*/
   l_concurrent_program_name := 'CMCMCW';
   SELECT concurrent_program_id
   INTO   l_cmcmcw_prog_id
   FROM   fnd_concurrent_programs
   WHERE  application_id          = l_application_id
   AND    concurrent_program_name = l_concurrent_program_name;

   l_stmt_num := 20;
   /* retrieve actual cost worker program ID*/
   l_concurrent_program_name := 'CMCACW';
   SELECT concurrent_program_id
   INTO   l_cmcacw_prog_id
   FROM   fnd_concurrent_programs
   WHERE  application_id          = l_application_id
   AND    concurrent_program_name = l_concurrent_program_name;

   l_stmt_num := 30;
   /* retrieve layer cost worker program ID*/
   l_concurrent_program_name := 'CMCLCW';
   SELECT concurrent_program_id
   INTO   l_cmclcw_prog_id
   FROM   fnd_concurrent_programs
   WHERE  application_id          = l_application_id
   AND    concurrent_program_name = l_concurrent_program_name;

   l_stmt_num := 40;
   UPDATE /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */
          mtl_material_transactions MMT
   SET    transaction_group_id = NULL,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  MMT.transaction_group_id is not null
   AND NVL(MMT.logical_transaction,0) <> 1
   AND MMT.costed_flag = 'N'
   AND NOT EXISTS
   ( SELECT 'incomplete concurrent program'
     FROM fnd_concurrent_requests FCR
     WHERE FCR.concurrent_program_id in (l_cmcmcw_prog_id, l_cmcacw_prog_id, l_cmclcw_prog_id)
     AND FCR.program_application_id = 702
     AND FCR.phase_code in ('P','R','I')
     AND decode(FCR.concurrent_program_id,
                         l_cmcmcw_prog_id,to_number(FCR.argument1),
                         l_cmcacw_prog_id,to_number(FCR.argument1),
                         l_cmclcw_prog_id,to_number(FCR.argument1),
                         to_number(null)) = MMT.transaction_group_id );

   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||'.'||l_api_name||'debug updated rows: '||to_char(sql%rowcount));

   l_stmt_num := 50;
   /* VALIDATION 7,10: Interorg txns should not be from and to the same org. */
   l_error_code := 'CST_INVALID_INTERORG';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  mmt.costed_flag = 'N'
   AND    mmt.transaction_action_id in (3,12,21)
   AND    mmt.organization_id = mmt.transfer_organization_id;

   l_stmt_num := 60;
   /* VALIDATION 3,4,5: Txfr txns should have all txfr columns populated. */
   l_error_code := 'CST_INVALID_TXFR';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  mmt.costed_flag = 'N'
   AND    mmt.transaction_action_id IN (2,3,5,28)
   AND  (  mmt.transfer_transaction_id IS NULL
        OR NOT EXISTS (
          SELECT 1 FROM mtl_secondary_inventories msi
          WHERE msi.secondary_inventory_name = mmt.subinventory_code
          AND   msi.organization_id = mmt.organization_id)
        OR NOT EXISTS (
          SELECT 1 FROM mtl_secondary_inventories msi
          WHERE msi.secondary_inventory_name = mmt.transfer_subinventory
          AND   msi.organization_id = mmt.transfer_organization_id)
        OR (    mmt.transaction_action_id IN (2,5,28)
            AND mmt.organization_id <> mmt.transfer_organization_id));

   l_stmt_num := 70;
   /* VALIDATION 1: Acct_period_id should match txn date. */
   l_error_code := 'CST_MATCH_DATE_PERIOD';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;

   OPEN orgs_to_process;

   LOOP

   FETCH orgs_to_process INTO l_org_id;

     EXIT WHEN orgs_to_process%NOTFOUND;

     SELECT TO_NUMBER(org_information2)
     INTO   l_legal_entity
     FROM   hr_organization_information
     WHERE  org_information_context = 'Accounting Information'
     AND    organization_id = l_org_id;

     l_timezone_offset := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(SYSDATE, l_legal_entity) - SYSDATE;

     l_stmt_num := 72;

     UPDATE mtl_material_transactions mmt
     SET    costed_flag = 'E',
            error_code = l_error_code,
            error_explanation = l_error_expl,
            last_update_date = SYSDATE,
            last_updated_by = l_last_updated_by,
            last_update_login = l_last_update_login,
            program_update_date = SYSDATE,
            program_application_id = l_program_application_id,
            program_id = l_program_id,
            request_id = l_request_id
     WHERE  mmt.costed_flag = 'N'
     AND    mmt.organization_id = l_org_id
     AND    DECODE(transaction_action_id,24,transaction_source_type_id,-1)<>14
     AND   (   mmt.acct_period_id IS NULL
            OR mmt.acct_period_id = -1
            OR NOT EXISTS
              (SELECT 1
               FROM   org_acct_periods oap
               WHERE  oap.organization_id = l_org_id
               AND    oap.acct_period_id = mmt.acct_period_id
               AND    mmt.transaction_date - l_timezone_offset BETWEEN
                      oap.period_start_date AND oap.schedule_close_date+.99999));

   END LOOP;

   l_stmt_num := 80;
   /* VALIDATION 2,6,8,9,11,12: Cost group validation (non null, must be in ccga or default). */
   /* ignore scrap, wip/inv lot transactions, periodic cost update, pack/unpack, container */
   l_error_code := 'CST_INVALID_CG';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  mmt.costed_flag = 'N'
   AND    transaction_action_id NOT IN (30,40,41,42,43,50,51,52)
   AND    DECODE(transaction_action_id,24,transaction_source_type_id,-1)<>14
   AND    (
              cost_group_id IS NULL
          OR  (   cost_group_id <> 1
              AND cost_group_id NOT IN (
                    SELECT ccga.cost_group_id
                    FROM   cst_cost_group_accounts ccga
                    WHERE  ccga.organization_id = mmt.organization_id
                  )
              )
          );

   l_stmt_num := 90;
   /* VALIDATION 6,9,12: Txfr CG validation in org (non null, must be in ccga or default). */
   l_error_code := 'CST_MATCH_TXFR_CG_ORG';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  costed_flag = 'N'
   AND   (   (    transaction_action_id = 12
              AND fob_point = 1)
          OR (    transaction_action_id = 21
              AND fob_point = 2)
          OR  transaction_action_id IN (2,5,28))
   AND    (
              transfer_cost_group_id IS NULL
          OR  (   transfer_cost_group_id <> 1
              AND transfer_cost_group_id NOT IN (
                    SELECT ccga.cost_group_id
                    FROM   cst_cost_group_accounts ccga
                    WHERE  ccga.organization_id = mmt.organization_id
                  )
              )
          );

   l_stmt_num := 100;
   /* VALIDATION 8,11: Txfr CG validation in txfr org (non null, must be in ccga or default). */
   l_error_code := 'CST_MATCH_TXFR_CG_TXFR_ORG';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  costed_flag = 'N'
   AND   (   (    transaction_action_id = 12
              AND fob_point = 2)
          OR (    transaction_action_id = 21
              AND fob_point = 1)
          OR  transaction_action_id = 3)
   AND    (
              transfer_cost_group_id IS NULL
          OR  (   transfer_cost_group_id <> 1
              AND transfer_cost_group_id NOT IN (
                    SELECT ccga.cost_group_id
                    FROM   cst_cost_group_accounts ccga
                    WHERE  ccga.organization_id = mmt.transfer_organization_id
                  )
              )
          );

   l_stmt_num := 110;
   /* VALIDATION 13: make sure that acct alias is valid */
   l_error_code := 'CST_INVALID_ACCT_ALIAS';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  costed_flag = 'N'
   AND    transaction_action_id in (1,27,29)
   AND    transaction_source_type_id = 6
   AND NOT EXISTS
     (SELECT 1
      FROM   mtl_generic_dispositions mgd
      WHERE  mgd.organization_id = mmt.organization_id
      AND    mgd.disposition_id = mmt.transaction_source_id);

   l_stmt_num := 120;
   /* VALIDATION 14: Issues and receipts should have valid subinventories. */
   l_error_code := 'CST_INVALID_SUB';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  mmt.costed_flag = 'N'
   AND    mmt.transaction_action_id in (1,27)
   AND NOT EXISTS
     (SELECT 1
      FROM   mtl_secondary_inventories msi
      WHERE  msi.organization_id = mmt.organization_id
      AND    msi.secondary_inventory_name = mmt.subinventory_code);

   l_stmt_num := 130;
   /* VALIDATION 15, 16: WIP transactions should refer to valid wip entity and be in wpb. */
   l_error_code := 'CST_INVALID_WIP';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  mmt.costed_flag = 'N'
   AND    mmt.transaction_source_type_id = 5
   AND NOT EXISTS
     (SELECT 1
      FROM   wip_entities we
      WHERE  we.organization_id = mmt.organization_id
      AND    we.wip_entity_id = mmt.transaction_source_id
      AND   (we.entity_type = 4
         OR EXISTS (
             SELECT 1 from wip_period_balances wpb
             WHERE wpb.organization_id = mmt.organization_id
             AND wpb.wip_entity_id = mmt.transaction_source_id
             AND wpb.acct_period_id = mmt.acct_period_id)));

   l_stmt_num := 140;
   /* VALIDATION 17: txn date not less than job/schedule release date */
   l_error_code := 'CST_INVALID_JOB_DATE';
   FND_MESSAGE.set_name('BOM', l_error_code);
   l_error_expl := FND_MESSAGE.Get;
   UPDATE mtl_material_transactions mmt
   SET    costed_flag = 'E',
          error_code = l_error_code,
          error_explanation = l_error_expl,
          last_update_date = SYSDATE,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login,
          program_update_date = SYSDATE,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          request_id = l_request_id
   WHERE  costed_flag = 'N'
   AND    transaction_source_type_id = 5
   AND NOT EXISTS
     (SELECT 1
      FROM   wip_discrete_jobs wdj
      WHERE  wdj.organization_id = mmt.organization_id
      AND    wdj.wip_entity_id = mmt.transaction_source_id
      AND    wdj.date_released <= mmt.transaction_date
      UNION ALL
      SELECT 1
      FROM   wip_repetitive_schedules wrs, mtl_material_txn_allocations mmta
      WHERE  wrs.organization_id = mmt.organization_id
      AND    wrs.date_released <= mmt.transaction_date
      AND    mmta.organization_id = mmt.organization_id
      AND    mmta.transaction_id = mmt.transaction_id
      AND    wrs.repetitive_schedule_id = mmta.repetitive_schedule_id
      UNION ALL
      SELECT 1
      FROM   wip_entities we
      WHERE  we.organization_id = mmt.organization_id
      AND    we.wip_entity_id = mmt.transaction_source_id
      AND    we.entity_type = 4
     );

   COMMIT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Period Close Diagnostics: Raise system alert for each organization
      that has transactions failing validation */

    l_stmt_num := 150;

    IF (l_uLog) THEN
     OPEN orgs_with_error;
     LOOP
     FETCH orgs_with_error INTO l_org_code, l_count;
      EXIT WHEN orgs_with_error%NOTFOUND;
      FND_MESSAGE.SET_NAME ('BOM','CST_MTL_COSTING_ERROR');
      FND_MESSAGE.SET_TOKEN ('COUNT', l_count);
      FND_MESSAGE.SET_TOKEN ('ORG_CODE', l_org_code);
      FND_LOG.MESSAGE (FND_LOG.LEVEL_UNEXPECTED, l_module || '.validation_failure', FALSE);
     END LOOP;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO CST_Validate_Transactions_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||'.'||l_api_name||': Error at stmt '||l_stmt_num||': '||SQLERRM);

END Validate_Transactions;

END CST_CostProcValidation_PVT;

/
