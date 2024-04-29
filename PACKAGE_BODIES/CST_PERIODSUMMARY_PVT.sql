--------------------------------------------------------
--  DDL for Package Body CST_PERIODSUMMARY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERIODSUMMARY_PVT" AS

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_PeriodSummary_PVT';

  PROCEDURE WaitOn_Request(
    ERRBUF                   OUT NOCOPY VARCHAR2,
    RETCODE                  OUT NOCOPY NUMBER,
    p_api_version            IN         NUMBER,
    p_request_id             IN         NUMBER,
    p_org_id                 IN         NUMBER,
    p_period_id              IN         NUMBER
  ) IS
    l_return_val BOOLEAN;
    l_phase VARCHAR2(80);
    l_status VARCHAR2(80);
    l_dev_phase VARCHAR2(15);
    l_dev_status VARCHAR2(15);
    l_message VARCHAR2(255);

    l_rec_id NUMBER;
    l_rep_type NUMBER := 0;
    l_currency_code VARCHAR2(15);

    l_api_name CONSTANT VARCHAR2(30) := 'WaitOn_Request';
    l_api_version CONSTANT NUMBER := 1.0;
    l_stmt_num NUMBER;

    COULD_NOT_LAUNCH_REC_RPT EXCEPTION;

    l_sched_close_date DATE;
    l_legal_entity NUMBER;
    l_count NUMBER;
    l_unprocessed_table VARCHAR2(30);
    l_unprocessed_txn EXCEPTION;
    l_untransferred_table VARCHAR2(30);
    l_untransferred_dist EXCEPTION;
    l_conc_status BOOLEAN;

  BEGIN

    l_stmt_num := 0;

    -- Standard Start of API savepoint
    SAVEPOINT WaitOn_Request_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           ( p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_FILE.put_line(FND_FILE.LOG, 'Waiting for request ID: ' || p_request_id);
    FND_FILE.put_line(FND_FILE.LOG, 'Organization ID:        ' || p_org_id);
    FND_FILE.put_line(FND_FILE.LOG, 'Accounting Period ID:   ' || p_period_id);

    l_stmt_num := 10;
    l_return_val := FND_CONCURRENT.Wait_For_Request(
                      request_id => p_request_id,
                      interval   => 60,
                      max_wait   => 0,
                      phase      => l_phase,
                      status     => l_status,
                      dev_phase  => l_dev_phase,
                      dev_status => l_dev_status,
                      message    => l_message
                    );

    l_stmt_num := 20;
    IF (l_return_val = TRUE AND
       (l_dev_status = 'NORMAL' OR l_dev_status = 'WARNING')) THEN

      l_stmt_num := 22;
      SELECT schedule_close_date
      INTO   l_sched_close_date
      FROM   org_acct_periods
      WHERE  acct_period_id = p_period_id;

      l_stmt_num := 24;
      SELECT legal_entity
      INTO   l_legal_entity
      FROM   cst_organization_definitions
      WHERE  organization_id = p_org_id;

      l_stmt_num := 26;
      l_sched_close_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                              l_sched_close_date,
                              l_legal_entity
                            );

      l_sched_close_date := l_sched_close_date + 1;


      -- check if there are unprocessed transactions in MMTT/MMT/WCTI
      SELECT  COUNT(*)
      INTO    l_count
      FROM    mtl_material_transactions_temp
      WHERE   organization_id = p_org_id
      AND     transaction_date < l_sched_close_date
      AND     NVL(transaction_status,0) <> 2; -- 2 indicates a save-only status

      IF l_count <> 0 THEN
         l_unprocessed_table := 'MTL_MATERIAL_TRANSACTIONS_TEMP';
         RAISE l_unprocessed_txn;
      END IF;

      SELECT  COUNT(*)
      INTO    l_count
      FROM    mtl_material_transactions
      WHERE   organization_id = p_org_id
      AND     transaction_date < l_sched_close_date
      AND     costed_flag is not null;

      IF l_count <> 0 THEN
         l_unprocessed_table := 'MTL_MATERIAL_TRANSACTIONS';
         RAISE l_unprocessed_txn;
      END IF;

      SELECT  COUNT(*)
      INTO    l_count
      FROM    wip_cost_txn_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date < l_sched_close_date;

      IF l_count <> 0 THEN
         l_unprocessed_table := 'WIP_COST_TXN_INTERFACE';
         RAISE l_unprocessed_txn;
      END IF;

      SELECT  COUNT(*)
      INTO    l_count
      FROM    wsm_split_merge_transactions
      WHERE   organization_id = p_org_id
      AND     costed <> wip_constants.completed
      AND     transaction_date < l_sched_close_date;

      IF l_count <> 0 THEN
         l_unprocessed_table := 'WSM_SPLIT_MERGE_TRANSACTIONS';
         RAISE l_unprocessed_txn;
      END IF;

      SELECT  COUNT(*)
      INTO    l_count
      FROM    wsm_split_merge_txn_interface
      WHERE   organization_id = p_org_id
      AND     process_status <> wip_constants.completed
      AND     transaction_date < l_sched_close_date;

      IF l_count <> 0 THEN
         l_unprocessed_table := 'WSM_SPLIT_MERGE_TXN_INTERFACE';
         RAISE l_unprocessed_txn;
      END IF;

      -- check if there are untransferred distributions in MTA/WTA

      SELECT COUNT(*)
      INTO   l_count
      FROM   mtl_transaction_accounts
      WHERE  gl_batch_id = -1
      AND    organization_id = p_org_id
      AND    transaction_date < l_sched_close_date;

      IF l_count <> 0 THEN
         l_untransferred_table := 'MTL_TRANSACTION_ACCOUNTS';
         RAISE l_untransferred_dist;
      END IF;

      SELECT COUNT(*)
      INTO   l_count
      FROM   wip_transaction_accounts
      WHERE  gl_batch_id = -1
      AND    organization_id = p_org_id
      AND    transaction_date < l_sched_close_date;

      IF l_count <> 0 THEN
         l_untransferred_table := 'WIP_TRANSACTION_ACCOUNTS';
         RAISE l_untransferred_dist;
      END IF;

      UPDATE org_acct_periods
      SET    summarized_flag = 'N',
             open_flag = 'N'
      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_period_id;

      IF (FND_PROFILE.VALUE('CST_PERIOD_SUMMARY') = '1') THEN

        l_stmt_num := 30;

        SELECT ML.lookup_code
        INTO   l_rep_type
        FROM   mfg_lookups ML,
               mtl_parameters MP
        WHERE  MP.organization_id = p_org_id
        AND    ML.lookup_type = 'CST_PER_CLOSE_REP_TYPE'
        AND    ML.lookup_code =
               DECODE(MP.primary_cost_method,
                 1,DECODE(
                     MP.wms_enabled_flag,
                     'Y',1,
                     DECODE(
                       MP.cost_group_accounting,
                       1,DECODE(
                           MP.project_reference_enabled,
                           1,1,
                           2
                         ),
                       2
                     )
                   ),
                 1
               );

        l_stmt_num := 40;
        SELECT currency_code
        INTO   l_currency_code
        FROM   gl_sets_of_books SOB,
               org_organization_definitions OOD
        WHERE  OOD.organization_id = p_org_id
        AND    OOD.set_of_books_id = SOB.set_of_books_id;

        l_stmt_num := 50;
        -- Launch reconciliation report
        l_rec_id := FND_REQUEST.submit_request(
                      application => 'BOM',
                      program     => 'CSTRPCRE',
                      description => NULL,
                      start_time  => NULL,
                      sub_request => FALSE,
                      argument1   => p_org_id,
                      argument2   => FND_PROFILE.VALUE('MFG_CHART_OF_ACCOUNTS_ID'),
                      argument3   => l_rep_type,
                      argument4   => 1,
                      argument5   => p_period_id,
                      argument6   => NULL,
                      argument7   => NULL,
                      argument8   => NULL,
                      argument9   => NULL,
                      argument10  => NULL,
                      argument11  => NULL,
                      argument12  => NULL,
                      argument13 => l_currency_code,
                      argument14 => FND_PROFILE.VALUE('DISPLAY_INVERSE_RATE'),
                      argument15 => 2,
                      argument16 => 1);

        IF l_rec_id = 0 THEN
          RAISE COULD_NOT_LAUNCH_REC_RPT;
        END IF;
      END IF;
    ELSE
      l_stmt_num := 60;
      UPDATE org_acct_periods
      SET    open_flag = 'Y'
      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_period_id;
      l_message := 'Transfer to GL (request_id '||p_request_id||') completed with error';
      FND_FILE.put_line(FND_FILE.LOG,l_message);
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO WaitOn_Request_PVT;
      FND_FILE.put_line(FND_FILE.LOG, 'API not compatible');
    WHEN l_unprocessed_txn THEN
      ROLLBACK TO WaitOn_Request_PVT;
      l_message := 'There exist(s) '|| l_count || ' unprocessed transaction(s) in ' || l_unprocessed_table;
      FND_FILE.put_line(FND_FILE.LOG,l_message);
      UPDATE org_acct_periods
      SET    open_flag = 'Y'
      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_period_id;
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
    WHEN l_untransferred_dist THEN
      ROLLBACK TO WaitOn_Request_PVT;
      l_message := 'There exist(s) '|| l_count || ' untransferred distribution(s) in ' || l_untransferred_table;
      FND_FILE.put_line(FND_FILE.LOG,l_message);
      UPDATE org_acct_periods
      SET    open_flag = 'Y'
      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_period_id;
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
    WHEN COULD_NOT_LAUNCH_REC_RPT THEN
      ROLLBACK TO WaitOn_Request_PVT;
      FND_FILE.put_line(FND_FILE.LOG, 'could not launch reconciliation report');
    WHEN OTHERS THEN
      ROLLBACK TO WaitOn_Request_PVT;
      FND_FILE.put_line(FND_FILE.LOG, l_stmt_num||':'||SQLERRM);
  END WaitOn_Request;

END CST_PeriodSummary_PVT;

/
