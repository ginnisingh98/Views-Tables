--------------------------------------------------------
--  DDL for Package Body CST_LCMADJUSTMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_LCMADJUSTMENTS_PVT" AS
/* $Header: CSTLCADB.pls 120.0.12010000.9 2009/06/29 01:08:48 mpuranik noship $ */

/*------------------------------------------------------------------------------------------
  Landed Cost Adjustment algorithm:

The worker runs for a subset of adjustment transactions in an organization.
Each set is stamped by a unique group id.

Phase 1: Validation
-------------------
1. Validate all the unvalidated interface records i.e. Process_status = 1
   (Pending).
2. Transactions that fail validation are set to process_status=3 amd are
   not picked up for processing until they are corrected and resubmitted
   by users. Validated records are set to process_status=2 (Validated).

Phase 2: Adjustment Processing
------------------------------
1. Collect all the organization level information, such as accounts,
   ledger information etc.
2. For each lcm adjustment transaction -
   a. Retrieve all the data related to the receipt transaction and
      its child transactions (Correct, Return, Deliver).
      Only transactions that have transaction date prior to the
      transaction date of the landed cost adjustment transaction
      are considered for adjustment.
   b. Generate the RCV_ACCOUNTING_EVENTS for the receipts and
      delivery adjustments.
      For each LCM transaction following receiving events are created:-
      i. Adjustments against the net received quantity.
         Event Type Id 15 i.e. Landed Cost Adjustments for Receipts.
      ii. Adjustments against the net delivered quantity of Asset items
         to Asset Subinventories. Event Type Id 16 - Landed Cost Adjustments
         for Deliveries to Asset.
      iii. Adjustments against the net delivered quantity of Expense items or
         to Expense Subinventories. Event Type Id 17 - Landed Cost Adjustments
         for Deliveries to Expense. For deliveries to Expense the accounting
         is created against Receiving Inspection and Expense Account.
         For wms-enabled subinventories, this account should be derived from the
         cost group against which the delivery was made.
      iv. Generate the average / layer cost update transactions.
          - This update transactions would be created only for the
          delivery transactions made against Asset items and subinventories.
          - The average / layer cost update will be only done for the net quantity
            (incoming quantity) that was delivered. The net quantity is
            populated in the primary_quantity column of the transaction. Please
          - The Average cost update transaction is created against the cost group
            against which the original delivery was made. In case of wms-enabled
            organizations, this could mean multiple cost groups for each parent receipt.
            In such a case, multiple average cost update transactions will be created.
          - The layer cost update is done against the layers that were hit by the
            original delivery and the layer values are updated in proportion of the
            delivered quantities against each layer.
          - Create records into tables rcv_accounting_events, rcv_receiving_sub_ledger,
            mtl_material_transactions, mtl_cst_txn_cost_details and XLA_EVENTS_INT_GT using
            the global temporary tables.
------------------------------------------------------------------------------------------*/

G_PKG_NAME  CONSTANT     VARCHAR2(30) :='CST_LcmAdjustments_PVT';
G_LOG_LEVEL CONSTANT           NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG CONSTANT          VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PO_APPLICATION_ID CONSTANT NUMBER       := 201;

-- Accounting Line Types
RECEIVING_INSPECTION       CONSTANT VARCHAR2(30) := 'Receiving Inspection';
LC_ABSORPTION CONSTANT              VARCHAR2(30) := 'Landed Cost Absorption';
PURCHASE_PRICE_VARIANCE             VARCHAR2(30) := 'Purchase Price Variance';
INVENTORY_EXPENSE                   VARCHAR2(30) := 'Expense';


/*===========================================================================+
|                                                                            |
| PROCEDURE      : Process_LcmAdjustments                                    |
|                                                                            |
| DESCRIPTION    : This Procedure is the main procedure for the landed       |
|                  cost adjustment worker. This procedure makes calls        |
|                  to other procedures in the package which validate,        |
|                  calculate and create landed cost adjustments.             |
|                                                                            |
| CALLED FROM    : Launch_Workers (CST_LcmAdjustments_PUB)                   |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_group_id        IN  NUMBER    REQUIRED                 |
|                   p_organization_id IN  NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  errbuf           OUT  NOCOPY VARCHAR2                    |
|                   retcode          OUT  NOCOPY NUMBER                      |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Process_LcmAdjustments
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER,
    p_group_id                      IN      NUMBER,
    p_organization_id               IN      NUMBER
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Process_LcmAdjustments';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                      NUMBER;
  l_num_records                   NUMBER;
  l_no_of_errored                 NUMBER;
  l_no_of_validated               NUMBER := 0;
  l_conc_status                   BOOLEAN;
  l_wms_enabled_flag              VARCHAR2(1);
  l_primary_cost_method           NUMBER;
  l_ledger_id                     NUMBER;
  INVALID_ADJUSTMENT_TXNS  EXCEPTION;

BEGIN

  l_stmt_num := 0;

    /* Procedure level log message for Entry point */
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      '>> ' || l_api_name || ': Parameters:' ||
      ' Group id '  || p_group_id ||
      ', Organization id '  || p_organization_id
      );
  END IF;

  -- Initialize message list
  FND_MSG_PUB.initialize;

  /* Initialize API return status to success */
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;

  /* Call the landed cost interface records validation proceduere */
  Validate_Lc_Interface
                 (p_api_version        => l_api_version,
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                  p_group_id           => p_group_id,
                  p_organization_id    => p_organization_id,
                  x_no_of_errored      => l_no_of_errored,
                  x_return_status      => l_return_status);

  IF l_return_status <> FND_API.g_ret_sts_success THEN
     IF l_exceptionLog THEN
       fnd_message.set_name('BOM','CST_LOG_EXCEPTION');
       fnd_message.set_token('CALLED','Validate_Lc_Interface');

     END IF;

     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  l_stmt_num := 15;

  SELECT Count(*)
    INTO l_no_of_validated
    FROM cst_lc_adj_interface
   WHERE process_status = 2
     AND organization_id = p_organization_id
     AND group_id = p_group_id
     AND ROWNUM = 1;

  l_stmt_num := 20;

  /* Call the remaining procedures only if there are any validated records */
  IF l_no_of_validated > 0 THEN

    l_stmt_num := 30;

    /* Populate common information related to the lcm adjustment transaction */
    Populate_Lcm_Adjustment_Info
                 (p_api_version        => l_api_version,
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                  p_group_id           => p_group_id,
                  p_organization_id    => p_organization_id,
                  x_ledger_id          => l_ledger_id,
                  x_primary_cost_method => l_primary_cost_method,
                  x_wms_enabled_flag   => l_wms_enabled_flag,
                  x_return_status      => l_return_status);

    IF l_return_status <> FND_API.g_ret_sts_success THEN
      IF l_exceptionLog THEN
        fnd_message.set_name('BOM','CST_LOG_EXCEPTION');
        fnd_message.set_token('CALLED','Populate_Temp_Adjustment_Data');

      END IF;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_stmt_num := 40;

    /* Populate the adjustment data into the global temporary tables */
    Populate_Temp_Adjustment_Data
                 (p_api_version        => l_api_version,
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                  p_primary_cost_method => l_primary_cost_method,
                  p_wms_enabled_flag   => l_wms_enabled_flag,
                  x_return_status      => l_return_status);

    IF l_return_status <> FND_API.g_ret_sts_success THEN
      IF l_exceptionLog THEN
        fnd_message.set_name('BOM','CST_LOG_EXCEPTION');
        fnd_message.set_token('CALLED','Populate_Temp_Adjustment_Data');

      END IF;

      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_stmt_num := 50;

    /* Insert the adjustment data from the GTTs into the actual tables */
    Insert_Adjustment_Data
                 (p_api_version        => l_api_version,
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                  p_group_id           => p_group_id,
                  p_organization_id    => p_organization_id,
                  p_ledger_id          => l_ledger_id,
                  x_return_status      => l_return_status);

    IF l_return_status <> FND_API.g_ret_sts_success THEN
      IF l_exceptionLog THEN
        fnd_message.set_name('BOM','CST_LOG_EXCEPTION');
        fnd_message.set_token('CALLED','Insert_Adjustment_Data');

      END IF;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_stmt_num := 60;

    COMMIT WORK;

  END IF; /* l_no_of_validated > 0 */

  l_stmt_num := 70;
  /* Set Status to warning if some transactions have failed validation */
  IF l_no_of_errored > 0 THEN
    l_stmt_num := 80;
    RAISE INVALID_ADJUSTMENT_TXNS;

  END IF;

  l_stmt_num := 90;
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.end',
      '<< ' || l_api_name
      );
  END IF;

EXCEPTION
    WHEN INVALID_ADJUSTMENT_TXNS THEN

      FND_MESSAGE.SET_NAME('BOM', 'CST_INVALID_LCM_TRANSACTIONS');
      FND_MESSAGE.SET_TOKEN('NUM', l_no_of_errored);
      FND_MESSAGE.SET_TOKEN('ORG', p_organization_id);
      FND_MESSAGE.SET_TOKEN('GROUP', p_group_id);
      FND_MESSAGE.SET_MODULE(l_module);
      fnd_file.put_line( FND_FILE.LOG, FND_MESSAGE.GET);

      IF l_ulog THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',FND_MESSAGE.GET);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;

      IF (l_ulog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',FND_MESSAGE.GET);

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;

      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',FND_MESSAGE.GET);

    WHEN OTHERS THEN
      ROLLBACK;

        FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
        FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
        FND_MESSAGE.set_token('PROCEDURE',l_api_name);
        FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

        FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
        FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                       FND_MESSAGE.GET);
      fnd_file.put_line( FND_FILE.LOG, FND_MESSAGE.GET);

END Process_LcmAdjustments;

/*===========================================================================+
|                                                                            |
| PROCEDURE      : Populate_Lcm_Adjustment_Info                              |
|                                                                            |
| DESCRIPTION    : This procedure populates CST_LC_ADJ_ACCTG_INFO_GT with    |
|                  the organization level information and CST_LC_RCV_TXN_GT  |
|                  with the entire hierarchy of transaction within the       |
|                  cutoff date under the parent receipt transaction of the   |
|                  lcm adjustment transaction.                               |
|                                                                            |
|                                                                            |
| CALLED FROM    : Process_LcmAdjustments Procedure                          |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_group_id          IN  NUMBER    REQUIRED               |
|                   p_organization_id   IN  NUMBER    REQUIRED               |
|                   p_api_version       IN  NUMBER    REQUIRED               |
|                   p_init_msg_list     IN  VARCHAR2  REQUIRED               |
|                   p_validation_level  IN  NUMBER    REQUIRED               |
|                                                                            |
| OUT            :  x_ledger_id              OUT  NOCOPY VARCHAR2            |
|                   x_primary_cost_method    OUT  NOCOPY NUMBER              |
|                   x_primary_cost_method    OUT  NOCOPY VARCHAR2            |
|                   x_return_status          OUT  NOCOPY NUMBER              |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Populate_Lcm_Adjustment_Info
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_group_id                      IN      NUMBER,
   p_organization_id               IN      NUMBER,
   x_ledger_id                     OUT     NOCOPY NUMBER,
   x_primary_cost_method           OUT     NOCOPY NUMBER,
   x_wms_enabled_flag              OUT     NOCOPY VARCHAR2,
   x_return_status                 OUT     NOCOPY VARCHAR2
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Populate_Lcm_Adjustment_Info';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                       NUMBER;
  l_num_records                    NUMBER;
  l_msg_data                       VARCHAR2(240);

  l_err_num                         NUMBER;
  l_error_code                      VARCHAR2(240);
  l_error_msg                       VARCHAR2(240);
  l_acct_id                         NUMBER;
  l_lcm_account                     NUMBER;
  l_lcm_var_account                 NUMBER;
  l_receiving_account               NUMBER;
  l_purchase_price_var_account      NUMBER;
  l_org_expense_account             NUMBER;
  l_primary_cost_method             NUMBER;
  l_wms_enabled_flag                varchar2(1);
  l_legal_entity_id                 NUMBER;
  l_ledger_id                       NUMBER;
  l_operating_unit                  NUMBER;
  l_chart_of_accounts_id            NUMBER;
  l_currency_code                   varchar2(15);
  l_user_je_category_name           NUMBER;
  l_user_je_source_name             NUMBER;
  l_minimum_accountable_unit        NUMBER;
  l_precision                       NUMBER;

  cursor c_lcm_txns (p_group_id number) is
   select transaction_id, transaction_date, rcv_transaction_id
     from cst_lc_adj_interface
    where process_status = 2
      and organization_id = p_organization_id
      and group_id = p_group_id;

  CURSOR c_adj_offset_account IS
    SELECT t.*, t.rowid
      FROM cst_lc_accounts_gt t;

BEGIN

  l_stmt_num := 0;

  /* Procedure level log message for Entry point */
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      '>> ' || l_api_name || ': Parameters:' ||
      ' Api version '  || p_api_version ||
      ', Init msg list '  || p_init_msg_list ||
      ', Validation level '  || p_validation_level ||
      ', Group id '  || p_group_id ||
      ', Organization id '  || p_organization_id
      );
  END IF;

  /* Standard call to check for call compatibility */
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_init_msg_list is set to TRUE */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /* Initialize API return status to success */
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;

  /* Retrieve the organization / ledger / OU related information for the organization */
  select rp.lcm_account_id,
         mp.lcm_var_account,
         rp.receiving_account_id,
         mp.purchase_price_var_account,
         mp.expense_account,
         mp.primary_cost_method,
         mp.wms_enabled_flag,
         cai.legal_entity,
         cai.ledger_id,
         cai.operating_unit,
         nvl(gsob.chart_of_accounts_id, 0),
         fc.currency_code,
         fc.minimum_accountable_unit,
         fc.precision
    into l_lcm_account,
         l_lcm_var_account,
         l_receiving_account,
         l_purchase_price_var_account,
         l_org_expense_account,
         l_primary_cost_method,
         l_wms_enabled_flag,
         l_legal_entity_id,
         l_ledger_id,
         l_operating_unit,
         l_chart_of_accounts_id,
         l_currency_code,
         l_minimum_accountable_unit,
         l_precision
    from rcv_parameters rp,
         mtl_parameters mp,
         cst_acct_info_v cai,
         gl_sets_of_books gsob,
         fnd_currencies fc
   where rp.organization_id = p_organization_id
     and mp.organization_id = p_organization_id
     and cai.organization_id = p_organization_id
     and gsob.set_of_books_id = cai.ledger_id
     and fc.currency_code = gsob.currency_code;

  l_stmt_num := 20;

  /* Return the primary cost method, wms flag and ledger id */
  x_primary_cost_method := l_primary_cost_method;
  x_wms_enabled_flag    := l_wms_enabled_flag;
  x_ledger_id           := l_ledger_id;

  l_stmt_num := 30;

  /* Insert all the PO, accounting and Landed cost adjustment related information for
     the lcm transaction. This will be used by all the events and accounting created
     for this lcm transaction */
  INSERT INTO CST_LC_ADJ_ACCTG_INFO_GT
   (lcm_transaction_id,
    rcv_transaction_id,
    inventory_item_id,
    prior_landed_cost,
    new_landed_cost,
    transaction_date,
    accounting_date,
    organization_id,
    po_number,
    po_header_id,
    po_release_id,
    po_line_id,
    po_line_location_id,
    source_doc_unit_of_measure,
    primary_unit_of_measure,
    lcm_account,
    lcm_var_account,
    receiving_account,
    purchase_price_var_account,
    org_expense_account,
    legal_entity_id,
    ledger_id,
    operating_unit,
    chart_of_accounts_id,
    func_currency_code,
    func_minimum_accountable_unit,
    func_precision,
    period_name,
    acct_period_id,
    inventory_asset_flag
    )
  SELECT   li.transaction_id,
           li.rcv_transaction_id,
           li.inventory_item_id,
           li.prior_landed_cost,
           li.new_landed_cost,
           li.transaction_date,
           INV_LE_TIMEZONE_PUB.Get_Le_Day_Time_For_Ou(
                             li.transaction_date,
                             l_operating_unit),
	   li.organization_id,
           poh.segment1,
           rt.po_header_id,
           rt.po_release_id,
           rt.po_line_id,
           rt.po_line_location_id,
           rt.source_doc_unit_of_measure,
           msi.primary_unit_of_measure,
           l_lcm_account,
           l_lcm_var_account,
           l_receiving_account,
           l_purchase_price_var_account,
           l_org_expense_account,
           l_legal_entity_id,
           l_ledger_id,
           l_operating_unit,
           l_chart_of_accounts_id,
           l_currency_code,
           l_minimum_accountable_unit,
           l_precision,
           gps.period_name,
           oap.acct_period_id,
           msi.inventory_asset_flag
      FROM cst_lc_adj_interface li,
           gl_period_statuses gps,
           mtl_system_items_b msi,
           po_headers_all poh,
           org_acct_periods oap,
           rcv_transactions rt
     WHERE li.group_id = p_group_id
       AND li.organization_id = p_organization_id
       AND li.process_status = 2
       AND gps.application_id = G_PO_APPLICATION_ID
       AND gps.set_of_books_id = l_ledger_id
       AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(li.transaction_date, l_legal_entity_id) >= Trunc(gps.start_date)
       AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(li.transaction_date, l_legal_entity_id) <= Trunc(gps.end_date)
       AND gps.adjustment_period_flag <> 'Y'
       AND msi.inventory_item_id = li.inventory_item_id
       AND msi.organization_id = li.organization_id
       AND rt.transaction_id = li.rcv_transaction_id
       AND poh.po_header_id = rt.po_header_id
       AND oap.organization_id = li.organization_id
       AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(li.transaction_date, l_legal_entity_id) >= Trunc(oap.period_start_date)
       AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(li.transaction_date, l_legal_entity_id) <= Trunc(oap.schedule_close_date);

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 40;

  /* Insert all the receiving side transactions that have the receipt transaction
     corresponding to the lcm adjustment as their root. */
  for c_lt in c_lcm_txns (p_group_id) loop

    l_stmt_num := 50;
    INSERT INTO CST_LC_RCV_TXN_GT
     (group_id, lcm_transaction_id,
      rcv_transaction_id,
      parent_transaction_id,
      accounting_event_id,
      transaction_type,
      source_doc_quantity,
      primary_quantity,
      subinventory_code,
      po_distribution_id
      )
    SELECT p_group_id, -1 * c_lt.transaction_id,
           transaction_id,
           parent_transaction_id,
           NULL, /* accounting_event_id*/
           transaction_type,
           rt.source_doc_quantity,
           rt.primary_quantity,
           rt.subinventory,
           rt.po_distribution_id
      FROM rcv_transactions rt
     WHERE rt.transaction_type IN ('RECEIVE', 'MATCH', 'RETURN TO VENDOR', 'CORRECT', 'DELIVER', 'RETURN TO RECEIVING')
       AND rt.transaction_date < c_lt.transaction_date
       START WITH rt.transaction_id = c_lt.rcv_transaction_id
       CONNECT BY rt.parent_transaction_id = PRIOR rt.transaction_id;

     IF (l_sLog AND l_pLog) THEN
       l_num_records := SQL%ROWCOUNT;
       FND_LOG.STRING(
         FND_LOG.LEVEL_PROCEDURE,
         l_module || '.query(' || l_stmt_num || ')',
         l_num_records || ' Rows inserted'
         );

     END IF;

   end loop;

   l_stmt_num := 60;
   INSERT INTO CST_LC_RCV_TXN_GT
   (group_id,
    lcm_transaction_id,
    accounting_event_id,
    rcv_transaction_id,
    parent_transaction_id,
    po_distribution_id,
    source_doc_quantity,
    primary_quantity,
    transaction_type,
    parent_transaction_type,
    subinventory_code
    )
   SELECT  rt.group_id,
           -1 * rt.lcm_transaction_id,
           rae.accounting_event_id,
           rt.rcv_transaction_id,
           NULL, /* parent_transaction_id */
	   nvl(rae.po_distribution_id, rt.po_distribution_id),
           nvl(rae.source_doc_quantity, rt.source_doc_quantity),
           nvl(rae.primary_quantity,rt.primary_quantity),
           rt.transaction_type,
           Decode(rt.transaction_type, 'CORRECT', rt_parent.transaction_type, rt.transaction_type) parent_transaction_type,
           rt.subinventory_code
      FROM rcv_transactions rt_parent,
           rcv_accounting_events rae,
           CST_LC_RCV_TXN_GT rt
     WHERE rae.rcv_transaction_id (+) = rt.rcv_transaction_id
       AND Nvl(rae.event_type_id,2) in (1,2,3,4,5,6)
       AND rt_parent.transaction_id (+) = rt.parent_transaction_id;

   IF (l_sLog AND l_pLog) THEN
     l_num_records := SQL%ROWCOUNT;
     FND_LOG.STRING(
       FND_LOG.LEVEL_PROCEDURE,
       l_module || '.query(' || l_stmt_num || ')',
       l_num_records || ' Rows inserted'
       );

   END IF;

   l_stmt_num := 65;
   DELETE FROM CST_LC_RCV_TXN_GT
    WHERE lcm_transaction_id < 0;

   IF (l_sLog AND l_pLog) THEN
     l_num_records := SQL%ROWCOUNT;
     FND_LOG.STRING(
       FND_LOG.LEVEL_PROCEDURE,
       l_module || '.query(' || l_stmt_num || ')',
       l_num_records || ' Rows Deleted'
       );

   END IF;

  l_stmt_num := 70;
/*--------------------------------------------------------------------------------------------------
 COST METHOD: STANDARD                                                                             |
---------------------------------------------------------------------------------------------------|
 SCENARIO NO. | WMS | ASSET | ACCOUNTING LINE TYPE    | ID    || ACCOUNT                           |
---------------------------------------------------------------------------------------------------|
           1. | Y   | Y     | Purchase price variance | 6     || ORG PPV ACCOUNT                   |
           2. | Y   | N     | Expense                 | 2     || SUBINVENTORY EXPENSE ACCOUNT      |
           3. | N   | Y     | Purchase price variance | 6     || CG PPV ACCOUNT                    |
           4. | N   | N     | Expense                 | 2     || CG EXPENSE ACCOUNT                |
---------------------------------------------------------------------------------------------------|
 COST METHOD: ACTUAL                                                                               |
---------------------------------------------------------------------------------------------------|
 SCENARIO NO. | WMS | ASSET | ACCOUNTING LINE TYPE    | ID    || ACCOUNT                           |
---------------------------------------------------------------------------------------------------|
           5. | Y   | Y     | Landed Cost absorption  | 38    || ORG LANDED COST ABSORPTION ACCOUNT|
           6. | Y   | N     | Expense                 | 2     || SUBINVENTORY EXPENSE ACCOUNT      |
           7. | N   | Y     | Landed Cost Absorption  | 38    || ORG LANDED COST ABSORPTION ACCOUNT|
           8. | N   | N     | Expense                 | 2     || CG EXPENSE ACCOUNT                |
--------------------------------------------------------------------------------------------------*/
  INSERT INTO CST_LC_ACCOUNTS_GT
    (LCM_TRANSACTION_ID,
     RCV_TRANSACTION_ID,
     TRANSACTION_ID,
     COST_GROUP_ID,
     SUBINVENTORY_CODE,
     ACCOUNT,
     ACCOUNTING_LINE_TYPE_ID,
     ACCOUNTING_LINE_TYPE,
     DEBIT_CREDIT_FLAG,
     EXP_FLAG
    )
    SELECT rt.lcm_transaction_id,
           rt.rcv_transaction_id,
           Max(mmt.transaction_id),
           Decode(l_wms_enabled_flag, 'Y', mmt.cost_group_id, NULL) cost_group_id,
           rt.subinventory_code,
           Decode( /* Derive Scenarios */
            Decode(l_primary_cost_method, 1,
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                1,
                2), 2),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                3,
                4), 4)),
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                5,
                6), 6),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                7,
                8), 8))),
             1,
             acc.purchase_price_var_account,
             2,
             mse.expense_account,
             3,
             Decode(mmt.cost_group_id, 1, acc.purchase_price_var_account, ccga.purchase_price_var_account),
             4,
             Decode(mmt.cost_group_id, 1, nvl(mse.expense_account, acc.org_expense_account), ccga.expense_account),
             5,
             acc.lcm_account,
             6,
             nvl(mse.expense_account, acc.org_expense_account),
             7,
             acc.lcm_account,
             8,
             Decode(mmt.cost_group_id, 1, nvl(mse.expense_account, acc.org_expense_account), ccga.expense_account)) account,
           Decode( /* Derive Scenarios */
            Decode(l_primary_cost_method, 1,
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                1,
                2), 2),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                3,
                4), 4)),
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                5,
                6), 6),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                7,
                8), 8))),
             1,
              6,
             2,
              2,
             3,
              6,
             4,
              2,
             5,
              38,
             6,
              2,
             7,
              38,
             8,
              2) account_line_type_id,
           Decode( /* Derive Scenarios */
            Decode(l_primary_cost_method, 1,
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                1,
                2), 2),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                3,
                4), 4)),
              Decode(l_wms_enabled_flag, 'N',
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                5,
                6), 6),
               Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                7,
                8), 8))),
             1,
              'Purchase Price Variance',
             2,
              'Expense',
             3,
              'Purchase Price Variance',
             4,
              'Expense',
             5,
              'Landed Cost Absorption',
             6,
              'Expense',
             7,
              'Landed Cost Absorption',
             8,
              'Expense') account_line_type,
           Decode(sign(acc.new_landed_cost-acc.prior_landed_cost), 1, 1, -1) debit_credit_flag,
           Decode(acc.inventory_asset_flag, 'Y', Decode(mse.asset_inventory, 1,
                0,
                1), 1) exp_flag
      FROM mtl_material_transactions mmt,
           cst_lc_rcv_txn_gt rt,
           cst_cost_group_accounts ccga,
           cst_lc_adj_acctg_info_gt acc,
           mtl_secondary_inventories mse
     WHERE mmt.transaction_source_type_id = 1
       AND mmt.organization_id = p_organization_id
       AND mmt.rcv_transaction_id = rt.rcv_transaction_id
       AND mse.organization_id = p_organization_id
       AND mse.secondary_inventory_name = rt.subinventory_code
       AND rt.transaction_type IN ('DELIVER', 'RETURN TO RECEIVING', 'CORRECT')
       AND rt.parent_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
       AND ccga.cost_group_id (+) = mmt.cost_group_id
       AND rt.lcm_transaction_id = acc.lcm_transaction_id
  GROUP BY mmt.cost_group_id,
           rt.subinventory_code,
           rt.lcm_transaction_id,
           rt.rcv_transaction_id,
           acc.inventory_asset_flag,
           mse.asset_inventory,
           acc.purchase_price_var_account,
           mmt.cost_group_id,
           ccga.purchase_price_var_account,
           mse.expense_account,
           acc.org_expense_account,
            ccga.expense_account,
           acc.lcm_account,
           acc.new_landed_cost,
           acc.prior_landed_cost;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows updated'
      );

  END IF;

  l_stmt_num := 80;
  IF l_primary_cost_method = 1 THEN

    l_stmt_num := 90;
    FOR c_account IN c_adj_offset_account LOOP

      l_stmt_num := 100;
      l_acct_id := CSTPSCHK.std_get_account_id( p_organization_id, c_account.transaction_id,
                     -1 * c_account.debit_credit_flag, c_account.accounting_line_type_id, 1,
                     0, c_account.subinventory_code, c_account.cost_group_id, c_account.exp_flag, 0,
                     l_err_num, l_error_code, l_error_msg);

      IF NVL(l_err_num, 0) <> 0 THEN

        l_error_msg := 'Retrieval of ' || c_account.accounting_line_type || ' account' ||
            ' from client extension errored out with: ' || '(' || substr(l_error_code, 10) || ') - ' || substr(Nvl(l_error_msg, 'Unknown Error'), 100);

	l_stmt_num := 110;
        INSERT INTO cst_lc_adj_interface_errors
               (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
               CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
         VALUES (p_group_id, c_account.lcm_transaction_id, 'ACCOUNT', l_error_msg,
               fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id,
               SYSDATE, SYSDATE, fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id);

         IF (l_sLog AND l_pLog) THEN
           l_num_records := SQL%ROWCOUNT;
           FND_LOG.STRING(
             FND_LOG.LEVEL_PROCEDURE,
             l_module || '.query(' || l_stmt_num || ')',
             l_num_records || ' Rows inserted'
             );

         END IF;

       END IF;

       l_stmt_num := 120;
       IF l_acct_id <> -1 THEN

	 l_stmt_num := 130;
         UPDATE cst_lc_accounts_gt
            SET account = l_acct_id
          WHERE rowid = c_account.rowid;

       END IF;

    END LOOP;

    l_stmt_num := 140;
    UPDATE cst_lc_adj_interface i
       SET process_status = 3,
           group_id = NULL
     WHERE group_id = p_group_id
       AND process_status IN (1,2)
       AND organization_id = p_organization_id
       AND EXISTS (SELECT 1
                     FROM cst_lc_adj_interface_errors e
                    WHERE e.transaction_id = i.transaction_id
                      AND e.group_id = p_group_id
                      AND error_column = 'ACCOUNT');

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows updated'
        );

    END IF;

    l_stmt_num := 150;
    DELETE FROM cst_lc_accounts_gt t
     WHERE EXISTS (SELECT 1
                     FROM cst_lc_adj_interface_errors e
                    WHERE e.transaction_id = t.lcm_transaction_id
                      AND e.group_id = p_group_id
                      AND error_column = 'ACCOUNT');

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows deleted'
        );

    END IF;

    l_stmt_num := 160;
    DELETE FROM cst_lc_rcv_txn_gt t
     WHERE EXISTS (SELECT 1
                     FROM cst_lc_adj_interface_errors e
                    WHERE e.transaction_id = t.lcm_transaction_id
                      AND e.group_id = p_group_id
                      AND error_column = 'ACCOUNT');

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows deleted'
        );

    END IF;

    l_stmt_num := 170;
    DELETE FROM cst_lc_adj_acctg_info_gt t
     WHERE EXISTS (SELECT 1
                     FROM cst_lc_adj_interface_errors e
                    WHERE e.transaction_id = t.lcm_transaction_id
                      AND e.group_id = p_group_id
                          AND error_column = 'ACCOUNT');

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows deleted'
        );

    END IF;

  END IF; -- l_primary_cost_method = 1

  l_stmt_num := 180;

  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.end',
      '<< ' || l_api_name || ': Out Parameters:' ||
      ' x_ledger_id '  || x_ledger_id ||
      ', x_primary_cost_method '  || x_primary_cost_method ||
      ', x_wms_enabled_flag '  || x_wms_enabled_flag
      );
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_ulog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
        FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
        FND_MESSAGE.set_token('PROCEDURE',l_api_name);
        FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

        FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
        FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

END Populate_Lcm_Adjustment_Info;

/*===========================================================================+
|                                                                            |
| PROCEDURE      : Populate_Temp_Adjustment_Data                             |
|                                                                            |
| DESCRIPTION    : This procedure creates the receiveing events and average  |
|                  and layer cost update data in global temporary tables.    |
|                                                                            |
|                                                                            |
|                                                                            |
|                                                                            |
|                                                                            |
| CALLED FROM    : Process_LcmAdjustments Procedure                          |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_primary_cost_method  IN  NUMBER    REQUIRED            |
|                   p_wms_enabled_flag     IN  NUMBER    REQUIRED            |
|                   p_api_version          IN  NUMBER    REQUIRED            |
|                   p_init_msg_list        IN  VARCHAR2  REQUIRED            |
|                   p_validation_level     IN  NUMBER    REQUIRED            |
|                                                                            |
| OUT            :  x_return_status          OUT  NOCOPY NUMBER              |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Populate_Temp_Adjustment_Data
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_primary_cost_method           IN      NUMBER,
   p_wms_enabled_flag              IN      VARCHAR2,
   x_return_status                 OUT     NOCOPY VARCHAR2
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Populate_Temp_Adjustment_Data';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                       NUMBER;
  l_num_records                    NUMBER;
  l_msg_data                       VARCHAR2(240);

BEGIN

  l_stmt_num := 0;

  /* Procedure level log message for Entry point */
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      '>> ' || l_api_name || ': Parameters:' ||
      ' Api version '  || p_api_version ||
      ', Init msg list '  || p_init_msg_list ||
      ', Validation level '  || p_validation_level ||
      ', Primary cost method '  || p_primary_cost_method ||
      ', Wms enabled flag '  || p_wms_enabled_flag
      );
  END IF;

  /* Standard call to check for call compatibility */
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_init_msg_list is set to TRUE */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
  END IF;

  /* Initialize API return status to success */
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;

  /* Create the Receipt Adjustment Events - Event type id = 15 */
  INSERT INTO CST_LC_RAE_EVENTS_GT
    (LCM_TRANSACTION_ID,
     ACCOUNTING_EVENT_ID,
     EVENT_SOURCE,
     EVENT_SOURCE_ID,
     EVENT_TYPE_ID,
     RCV_TRANSACTION_ID,
     INVENTORY_ITEM_ID,
     PRIOR_UNIT_PRICE,
     UNIT_PRICE,
     transaction_date,
     organization_id,
     ORG_ID,
     SET_OF_BOOKS_ID,
     PO_HEADER_ID,
     PO_RELEASE_ID,
     PO_LINE_ID,
     PO_LINE_LOCATION_ID,
     PO_DISTRIBUTION_ID,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_TYPE,
     CURRENCY_CONVERSION_RATE,
     CURRENCY_CONVERSION_DATE,
     SOURCE_DOC_UNIT_OF_MEASURE,
     TRANSACTION_UNIT_OF_MEASURE,
     PRIMARY_UNIT_OF_MEASURE,
     source_doc_quantity,
     TRANSACTION_quantity,
     primary_quantity,
     CREDIT_ACCOUNT_ID,
     DEBIT_ACCOUNT_ID,
     CREDIT_ACCOUNTING_LINE_TYPE,
     DEBIT_ACCOUNTING_LINE_TYPE,
     /* who columns */
     CREATED_BY,
     CREATION_DATE,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATED_BY,
     REQUEST_ID,
     ACCOUNTED_FLAG)
  SELECT acc.lcm_transaction_id,
     NULL,
     'LC_ADJUSTMENTS',
     acc.lcm_transaction_id,
     15,
     acc.rcv_transaction_id,
     acc.inventory_item_id,
     acc.prior_landed_cost,
     acc.new_landed_cost,
     acc.transaction_date,
     acc.organization_id,
     acc.operating_unit,
     acc.ledger_id,
     acc.po_header_id,
     acc.po_release_id,
     acc.po_line_id,
     acc.po_line_location_id,
     rt.po_distribution_id,
     acc.func_currency_code,
     NULL,
     1,
     acc.transaction_date,
     acc.source_doc_unit_of_measure,
     acc.primary_unit_of_measure,
     acc.primary_unit_of_measure,
     sum(Decode(rt.transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     'CORRECT', Decode(rt.parent_transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     0)) * rt.source_doc_quantity) source_doc_quantity,
     sum(Decode(rt.transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     'CORRECT', Decode(rt.parent_transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     0)) * rt.primary_quantity) transaction_quantity,
     sum(Decode(rt.transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     'CORRECT', Decode(rt.parent_transaction_type,
     'RECEIVE', 1,
     'MATCH', 1,
     'RETURN TO VENDOR', -1,
     0)) * rt.primary_quantity) primary_quantity,
     Decode(SIGN(acc.new_landed_cost-acc.prior_landed_cost), -1, acc.receiving_account, acc.lcm_account) CREDIT_ACCOUNT_ID,
     Decode(SIGN(acc.new_landed_cost-acc.prior_landed_cost),  1, acc.receiving_account, acc.lcm_account) DEBIT_ACCOUNT_ID,
     Decode(SIGN(acc.new_landed_cost-acc.prior_landed_cost), -1, 'Receiving Inspection', 'Landed Cost Absorption') CREDIT_ACCOUNTING_LINE_TYPE,
     Decode(SIGN(acc.new_landed_cost-acc.prior_landed_cost),  1, 'Receiving Inspection', 'Landed Cost Absorption')  DEBIT_ACCOUNTING_LINE_TYPE,
     fnd_global.user_id,
     SYSDATE,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE,
     SYSDATE,
     fnd_global.login_id,
     fnd_global.user_id,
     fnd_global.conc_request_id,
     'N'
     FROM CST_LC_ADJ_ACCTG_INFO_GT ACC,
          CST_LC_RCV_TXN_GT RT
     WHERE acc.lcm_transaction_id = RT.lcm_transaction_id
       AND (rt.transaction_type IN ('RECEIVE', 'MATCH', 'RETURN TO VENDOR')
        OR (rt.transaction_type = 'CORRECT'
            AND rt.parent_transaction_type IN ('RECEIVE', 'MATCH', 'RETURN TO VENDOR')))
     GROUP BY acc.lcm_transaction_id,
     ACC.rcv_transaction_id,
     inventory_item_id,
     prior_landed_cost,
     new_landed_cost,
     transaction_date,
     organization_id,
     operating_unit,
     ledger_id,
     po_header_id,
     po_release_id,
     po_line_id,
     po_line_location_id,
     po_distribution_id,
     func_currency_code,
     source_doc_unit_of_measure,
     primary_unit_of_measure,
     receiving_account,
     LCM_account
     HAVING sum(Decode(rt.transaction_type,
       'RECEIVE', 1,
       'MATCH', 1,
       'RETURN TO VENDOR', -1,
       'CORRECT', Decode(rt.parent_transaction_type,
       'RECEIVE', 1,
       'MATCH', 1,
       'RETURN TO VENDOR', -1,
       0)) * rt.source_doc_quantity) <> 0;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 20;

  /* Create the Delivery Adjustment Events - Event type id = 16,17 */
  l_stmt_num := 30;
  INSERT INTO CST_LC_RAE_EVENTS_GT
    (LCM_TRANSACTION_ID,
     ACCOUNTING_EVENT_ID,
     EVENT_SOURCE,
     EVENT_SOURCE_ID,
     EVENT_TYPE_ID,
     RCV_TRANSACTION_ID,
     INVENTORY_ITEM_ID,
     PRIOR_UNIT_PRICE,
     UNIT_PRICE,
     transaction_date,
     organization_id,
     ORG_ID,
     SET_OF_BOOKS_ID,
     PO_HEADER_ID,
     PO_RELEASE_ID,
     PO_LINE_ID,
     PO_LINE_LOCATION_ID,
     PO_DISTRIBUTION_ID,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_TYPE,
     CURRENCY_CONVERSION_RATE,
     CURRENCY_CONVERSION_DATE,
     SOURCE_DOC_UNIT_OF_MEASURE,
     TRANSACTION_UNIT_OF_MEASURE,
     PRIMARY_UNIT_OF_MEASURE,
     source_doc_quantity,
     TRANSACTION_quantity,
     primary_quantity,
     CREDIT_ACCOUNT_ID,
     DEBIT_ACCOUNT_ID,
     CREDIT_ACCOUNTING_LINE_TYPE,
     DEBIT_ACCOUNTING_LINE_TYPE,
     /* who columns */
     CREATED_BY,
     CREATION_DATE,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATED_BY,
     REQUEST_ID,
     ACCOUNTED_FLAG)
  SELECT acc.lcm_transaction_id,
     NULL,
     'LC_ADJUSTMENTS',
     acc.lcm_transaction_id,
     Decode(adj_acc.exp_flag,
            1, 17,
            16),
     acc.rcv_transaction_id,
     acc.inventory_item_id,
     acc.prior_landed_cost,
     acc.new_landed_cost,
     acc.transaction_date,
     acc.organization_id,
     acc.operating_unit,
     acc.ledger_id,
     acc.PO_HEADER_ID,
     acc.PO_RELEASE_ID,
     acc.PO_LINE_ID,
     acc.PO_LINE_LOCATION_ID,
     rt.PO_DISTRIBUTION_ID,
     acc.func_currency_code,
     NULL,
     1,
     acc.transaction_date,
     acc.SOURCE_DOC_UNIT_OF_MEASURE,
     acc.PRIMARY_UNIT_OF_MEASURE,
     acc.PRIMARY_UNIT_OF_MEASURE,
     sum(Decode(transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     'CORRECT', Decode(parent_transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     0)) * source_doc_quantity) source_doc_quantity,
     sum(Decode(transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     'CORRECT', Decode(parent_transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     0)) * primary_quantity) transaction_quantity,
     sum(Decode(transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     'CORRECT', Decode(parent_transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     0)) * primary_quantity) primary_quantity,
     Decode(adj_acc.debit_credit_flag,  1, acc.receiving_account, adj_acc.account) CREDIT_ACCOUNT_ID,
     Decode(adj_acc.debit_credit_flag, -1, acc.receiving_account, adj_acc.account) DEBIT_ACCOUNT_ID,
     Decode(adj_acc.debit_credit_flag,  1, 'Receiving Inspection', adj_acc.accounting_line_type) CREDIT_ACCOUNTING_LINE_TYPE,
     Decode(adj_acc.debit_credit_flag, -1, 'Receiving Inspection', adj_acc.accounting_line_type)  DEBIT_ACCOUNTING_LINE_TYPE,
     fnd_global.user_id,
     SYSDATE,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE,
     SYSDATE,
     fnd_global.login_id,
     fnd_global.user_id,
     fnd_global.conc_request_id,
     'N'
   FROM cst_lc_adj_acctg_info_gt acc,
        cst_lc_rcv_txn_gt rt,
        cst_lc_accounts_gt adj_acc
  WHERE (rt.transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
         or (rt.transaction_type = 'CORRECT'
            and rt.parent_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')))
    and rt.lcm_transaction_id = acc.lcm_transaction_id
    and adj_acc.lcm_transaction_id = acc.lcm_transaction_id
  GROUP BY acc.lcm_transaction_id,
     acc.rcv_transaction_id,
     inventory_item_id,
     prior_landed_cost,
     new_landed_cost,
     transaction_date,
     acc.organization_id,
     operating_unit,
     ledger_id,
     po_header_id,
     po_release_id,
     po_line_id,
     po_line_location_id,
     po_distribution_id,
     func_currency_code,
     source_doc_unit_of_measure,
     primary_unit_of_measure,
     receiving_account,
     adj_acc.account,
     adj_acc.exp_flag,
     adj_acc.debit_credit_flag,
     adj_acc.accounting_line_type
   HAVING sum(Decode(transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     'CORRECT', Decode(parent_transaction_type,
     'DELIVER', 1,
     'RETURN TO RECEIVING', -1,
     0)) * source_doc_quantity) <> 0;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 50;
  UPDATE CST_LC_RAE_EVENTS_GT
  SET accounting_event_id = rcv_accounting_event_s.NEXTVAL;

  l_stmt_num := 60;
  IF p_primary_cost_method = 2 THEN
    l_stmt_num := 70;

    /* Insert Average cost update transactions for the deliveries of
       asset items into asset organizations */
    INSERT INTO CST_LC_MMT_GT
      (lcm_transaction_id,
       transaction_id,
       transaction_type_id,
       transaction_action_id,
       transaction_source_type_id,
       cost_group_id,
       primary_quantity,
       value_change,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       inventory_item_id,
       organization_id,
       transaction_date,
       acct_period_id,
       transaction_source_name,
       source_code,
       transaction_reference,
       trx_source_line_id,
       material_account,
       material_overhead_account,
       resource_account,
       outside_processing_account,
       overhead_account,
       expense_account_id,
       costed_flag,
       pm_cost_collected,
       owning_organization_id,
       owning_tp_type,
       transaction_uom)
    SELECT
       acc.lcm_transaction_id,
       NULL,
       80,
       24,
       13,
       mmt.cost_group_id,
       sum(mmt.primary_quantity),
       sum(mmt.primary_quantity) * (acc.new_landed_cost - acc.prior_landed_cost),
       SYSDATE,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.login_id,
       fnd_global.conc_request_id,
       fnd_global.prog_appl_id,
       fnd_global.conc_program_id,
       SYSDATE,
       acc.inventory_item_id,
       acc.organization_id,
       acc.transaction_date,
       acc.acct_period_id,
       'LCM ADJUSTMENT',
       'LCMADJ',
       acc.lcm_transaction_id,
       acc.rcv_transaction_id,
       acc.lcm_account,
       acc.lcm_account,
       acc.lcm_account,
       acc.lcm_account,
       acc.lcm_account,
       acc.lcm_var_account,
       'N',
       NULL,
       acc.organization_id,
       2,
       msi.primary_uom_code
    FROM cst_lc_adj_acctg_info_gt acc,
         cst_lc_rcv_txn_gt rt,
         mtl_secondary_inventories mse,
         mtl_material_transactions mmt,
         mtl_system_items_b msi
   WHERE (rt.transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
         or (rt.transaction_type = 'CORRECT'
            and rt.parent_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')))
     and rt.lcm_transaction_id = acc.lcm_transaction_id
     AND mse.secondary_inventory_name = rt.subinventory_code
     and mse.organization_id = acc.organization_id
     and mmt.rcv_transaction_id = rt.rcv_transaction_id
     AND (acc.inventory_asset_flag = 'Y' AND Nvl(mse.asset_inventory,2) = 1)
     AND msi.inventory_item_id = acc.inventory_item_id
     AND msi.organization_id= acc.organization_id
     GROUP BY
       mmt.cost_group_id,
       acc.inventory_item_id,
       acc.organization_id,
       acc.transaction_date,
       acc.acct_period_id,
       acc.rcv_transaction_id,
       acc.lcm_account,
       acc.lcm_transaction_id,
       acc.lcm_var_account,
       acc.new_landed_cost,
       acc.prior_landed_cost,
       msi.primary_uom_code
   HAVING sum(mmt.primary_quantity) <> 0;

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows inserted'
        );

    END IF;

    l_stmt_num := 75;
    UPDATE CST_LC_MMT_GT
    SET transaction_id = MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL;

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows updated'
        );

  END IF;

  END IF; --p_primary_cost_method = 2 THEN

  l_stmt_num := 80;
  IF p_primary_cost_method IN (5,6) THEN

    l_stmt_num := 90;
    /* Insert Layer cost update transactions for the deliveries of
       asset items into asset organizations */
    INSERT INTO CST_LC_MMT_GT
      (lcm_transaction_id,
       transaction_id,
       transaction_type_id,
       transaction_action_id,
       transaction_source_type_id,
       transaction_source_id,
       cost_group_id,
       primary_quantity,
       value_change,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       inventory_item_id,
       organization_id,
       transaction_date,
       acct_period_id,
       transaction_source_name,
       source_code,
       transaction_reference,
       trx_source_line_id,
       material_account,
       material_overhead_account,
       resource_account,
       outside_processing_account,
       overhead_account,
       expense_account_id,
       costed_flag,
       pm_cost_collected,
       owning_organization_id,
       owning_tp_type,
       transaction_uom)
    SELECT txn.lcm_transaction_id,
       NULL,
       28,
       24,
       15,
       inv_layer_id,
       txn.cost_group_id,
       sum(txn.layer_quantity),
       txn.value_change,
       SYSDATE,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.login_id,
       fnd_global.conc_request_id,
       fnd_global.prog_appl_id,
       fnd_global.conc_program_id,
       SYSDATE,
       txn.inventory_item_id,
       txn.organization_id,
       txn.transaction_date,
       txn.acct_period_id,
       'LCM ADJUSTMENT',
       'LCMADJ',
       txn.lcm_transaction_id,
       txn.rcv_transaction_id,
       txn.lcm_account,
       txn.lcm_account,
       txn.lcm_account,
       txn.lcm_account,
       txn.lcm_account,
       txn.lcm_var_account,
       'N',
       NULL,
       txn.organization_id,
       2,
       msi.primary_uom_code
    FROM (SELECT DISTINCT acc.lcm_transaction_id,
                mmt.transaction_id,
                mclacd.inv_layer_id,
                mclacd.layer_quantity,
                mmt.cost_group_id,
                acc.inventory_item_id,
                acc.organization_id,
                acc.transaction_date,
                acc.acct_period_id,
                acc.rcv_transaction_id,
                acc.lcm_account,
                acc.lcm_var_account,
                (layer_quantity * (acc.new_landed_cost - acc.prior_landed_cost)) value_change
              FROM mtl_material_transactions mmt,
                   mtl_cst_layer_act_cost_details mclacd,
                   cst_lc_adj_acctg_info_gt acc,
                   cst_lc_rcv_txn_gt rt,
                   mtl_secondary_inventories mse
              WHERE (rt.transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
                     or (rt.transaction_type = 'CORRECT'
                         and rt.parent_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')))
              and rt.lcm_transaction_id = acc.lcm_transaction_id
              AND mse.secondary_inventory_name = rt.subinventory_code
              and mse.organization_id = acc.organization_id
              and mmt.rcv_transaction_id = rt.rcv_transaction_id
              and mmt.transaction_id = mclacd.transaction_id
              AND (acc.inventory_asset_flag = 'Y' AND Nvl(mse.asset_inventory,2) = 1)) txn,
              mtl_system_items_b msi
         WHERE msi.inventory_item_id = txn.inventory_item_id
           AND msi.organization_id= txn.organization_id
     GROUP BY txn.lcm_transaction_id, txn.COST_GROUP_ID,
              txn.INV_LAYER_ID,
              txn.cost_group_id,
              txn.inventory_item_id,
              txn.organization_id,
              txn.transaction_date,
              txn.acct_period_id,
              txn.rcv_transaction_id,
              txn.value_change,
              txn.lcm_account,
              txn.lcm_var_account,
              msi.primary_uom_code
       HAVING sum(txn.layer_quantity) <> 0;

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows inserted'
        );

    END IF;

    l_stmt_num := 100;
    UPDATE CST_LC_MMT_GT
    SET transaction_id = MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL;

    IF (l_sLog AND l_pLog) THEN
      l_num_records := SQL%ROWCOUNT;
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        l_module || '.query(' || l_stmt_num || ')',
        l_num_records || ' Rows updated'
        );

    END IF;

  END IF; -- p_primary_cost_method IN (5,6) THEN


  l_stmt_num := 110;
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.end',
      '<< ' || l_api_name || ': Out Parameters:' ||
      ', x_return_status '  || x_return_status
      );
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
        FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
        FND_MESSAGE.set_token('PROCEDURE',l_api_name);
        FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

        FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
        FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

END Populate_Temp_Adjustment_Data;

/*===========================================================================+
|                                                                            |
| PROCEDURE      : Insert_Adjustment_Data                                    |
|                                                                            |
| DESCRIPTION    : This procedure inserts the receiving events data and the  |
|                  average and layer cost update data from temporary tables  |
|                  into RCV_ACCOUNTING_EVENTS and MTL_MATERIAL_TRANSACTIONS. |
|                  Accounting and other entries are also calculated and      |
|                  inserted into RCV_RECEIVING_SUBLEDGER, XLA_EVENTS_INT_GT  |
|                  and MTL_CST_TXN_COST_DETAILS.                             |
|                                                                            |
| CALLED FROM    : Process_LcmAdjustments Procedure                          |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_group_id          IN  NUMBER    REQUIRED               |
|                   p_organization_id   IN  NUMBER    REQUIRED               |
|                   p_ledger_id         IN  NUMBER    REQUIRED               |
|                   p_api_version       IN  NUMBER    REQUIRED               |
|                   p_init_msg_list     IN  VARCHAR2  REQUIRED               |
|                   p_validation_level  IN  NUMBER    REQUIRED               |
|                                                                            |
| OUT            :  x_return_status          OUT  NOCOPY NUMBER              |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Insert_Adjustment_Data
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_group_id                      IN      NUMBER,
   p_organization_id               IN      NUMBER,
   p_ledger_id                     IN      NUMBER,
   x_return_status                 OUT     NOCOPY VARCHAR2
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Insert_Adjustment_Data';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                       NUMBER;
  l_num_records                    NUMBER;
  l_msg_data                       VARCHAR2(240);


BEGIN

  l_stmt_num := 0;

  /* Procedure level log message for Entry point */
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      '>> ' || l_api_name || ': Parameters:' ||
      ' Api version '  || p_api_version ||
      ', Init msg list '  || p_init_msg_list ||
      ', Validation level '  || p_validation_level ||
      ', Group id '  || p_group_id ||
      ', Ledger id '  || p_ledger_id
      );
  END IF;

  /* Standard call to check for call compatibility */
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_init_msg_list is set to TRUE */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
  END IF;

  /* Initialize API return status to success */
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;

  /* Create RCV accounting events data from the GTT */
  INSERT INTO rcv_accounting_events
    (accounting_event_id,
     event_source,
     event_source_id,
     event_type_id,
     rcv_transaction_id,
     inventory_item_id,
     prior_unit_price,
     unit_price,
     transaction_date,
     organization_id,
     org_id,
     set_of_books_id,
     po_header_id,
     po_release_id,
     po_line_id,
     po_line_location_id,
     po_distribution_id,
     currency_code,
     currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     source_doc_unit_of_measure,
     transaction_unit_of_measure,
     primary_unit_of_measure,
     source_doc_quantity,
     transaction_quantity,
     primary_quantity,
     credit_account_id,
     debit_account_id,
     /* who columns */
     created_by,
     creation_date,
     program_application_id,
     program_id,
     program_udpate_date,
     last_update_date,
     last_update_login,
     last_updated_by,
     request_id,
     accounted_flag)
  SELECT accounting_event_id,
     event_source,
     event_source_id,
     event_type_id,
     rcv_transaction_id,
     inventory_item_id,
     prior_unit_price,
     unit_price,
     transaction_date,
     organization_id,
     org_id,
     set_of_books_id,
     po_header_id,
     po_release_id,
     po_line_id,
     po_line_location_id,
     po_distribution_id,
     currency_code,
     currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     source_doc_unit_of_measure,
     transaction_unit_of_measure,
     primary_unit_of_measure,
     source_doc_quantity,
     transaction_quantity,
     primary_quantity,
     credit_account_id,
     debit_account_id,
     /* who columns */
     created_by,
     creation_date,
     program_application_id,
     program_id,
     program_update_date,
     last_update_date,
     last_update_login,
     last_updated_by,
     request_id,
     accounted_flag
  FROM cst_lc_rae_events_gt;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 20;

  /* Create the debit lines in the subledger for the rcv accounting events */
  INSERT INTO rcv_receiving_sub_ledger
    (created_by,
     creation_date,
     program_application_id,
     program_id,
     program_update_date,
     last_update_date,
     last_update_login,
     last_updated_by,
     request_id,
     rcv_sub_ledger_id,
     accounting_event_id,
     accounting_line_type,
     rcv_transaction_id,
     actual_flag,
     je_source_name,
     je_category_name,
     set_of_books_id,
     accounting_date,
     code_combination_id,
     entered_dr,
     accounted_dr,
     currency_code,
     user_currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     transaction_date,
     period_name,
     chart_of_accounts_id,
     functional_currency_code,
     reference1,
     reference2,
     reference3,
     reference4,
     source_doc_quantity,
     accrual_method_flag,
     accounted_nr_tax,
     accounted_rec_tax,
     entered_nr_tax,
     entered_rec_tax
     )
  SELECT
     fnd_global.user_id,
     SYSDATE,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE,
     SYSDATE,
     fnd_global.login_id,
     fnd_global.user_id,
     fnd_global.conc_request_id,
     rcv_receiving_sub_ledger_s.nextval,
     rae.accounting_event_id,
     rae.debit_accounting_line_type,
     rae.rcv_transaction_id,
     'A',
     'Purchasing',
     'Receiving',
     rae.set_of_books_id,
     Trunc(acc.accounting_date),
     rae.debit_account_id,
     /* ENTERED */
     Decode(func_minimum_accountable_unit
     , NULL, Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price)), func_precision)
           , Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price))/ func_minimum_accountable_unit) * func_minimum_accountable_unit),
     /* ACCOUNTED */
     Decode(func_minimum_accountable_unit
     , NULL, Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price)), func_precision)
           , Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price))/ func_minimum_accountable_unit) * func_minimum_accountable_unit),
     acc.func_currency_code,
     NULL,
     1,
     acc.transaction_date,
     acc.transaction_date,
     acc.period_name,
     acc.chart_of_accounts_id,
     acc.func_currency_code,
     'PO',
     rae.po_header_id,
     rae.po_distribution_id,
     acc.po_number,
     rae.source_doc_quantity,
     'O',
     0,
     0,
     0,
     0
  FROM cst_lc_rae_events_gt rae,
       cst_lc_adj_acctg_info_gt acc
  WHERE rae.lcm_transaction_id = acc.lcm_transaction_id;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 30;
  /* Create the credit lines in the subledger for the rcv accounting events */
  INSERT INTO rcv_receiving_sub_ledger
    (created_by,
     creation_date,
     program_application_id,
     program_id,
     program_update_date,
     last_update_date,
     last_update_login,
     last_updated_by,
     request_id,
     rcv_sub_ledger_id,
     accounting_event_id,
     accounting_line_type,
     rcv_transaction_id,
     actual_flag,
     je_source_name,
     je_category_name,
     set_of_books_id,
     accounting_date,
     code_combination_id,
     accounted_cr,
     entered_cr,
     currency_code,
     user_currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     transaction_date,
     period_name,
     chart_of_accounts_id,
     functional_currency_code,
     reference1,
     reference2,
     reference3,
     reference4,
     source_doc_quantity,
     accrual_method_flag,
     accounted_nr_tax,
     accounted_rec_tax,
     entered_nr_tax,
     entered_rec_tax)
  SELECT
     fnd_global.user_id,
     SYSDATE,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE,
     SYSDATE,
     fnd_global.login_id,
     fnd_global.user_id,
     fnd_global.conc_request_id,
     rcv_receiving_sub_ledger_s.NEXTVAL,
     rae.accounting_event_id,
     rae.credit_accounting_line_type,
     rae.rcv_transaction_id,
     'A',
     'Purchasing',
     'Receiving',
     rae.set_of_books_id,
     Trunc(acc.accounting_date),
     rae.credit_account_id,
     /* ENTERED */
     Decode(func_minimum_accountable_unit
     , NULL, Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price)), func_precision)
           , Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price))/ func_minimum_accountable_unit) * func_minimum_accountable_unit),
     /* ACCOUNTED */
     Decode(func_minimum_accountable_unit
     , NULL, Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price)), func_precision)
           , Round(ABS(rae.primary_quantity *  (rae.unit_price - rae.prior_unit_price))/ func_minimum_accountable_unit) * func_minimum_accountable_unit),
     acc.func_currency_code,
     NULL,
     1,
     acc.transaction_date,
     acc.transaction_date,
     acc.period_name,
     acc.chart_of_accounts_id,
     acc.func_currency_code,
     'PO',
     rae.po_header_id,
     rae.po_distribution_id,
     acc.po_number,
     rae.source_doc_quantity,
     'O',
     0,
     0,
     0,
     0
  FROM cst_lc_rae_events_gt rae,
       cst_lc_adj_acctg_info_gt acc
  WHERE rae.lcm_transaction_id = acc.lcm_transaction_id;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 40;
  /* Create the transaction cost details for the average /layer cost update transactions */
  INSERT INTO MTL_CST_TXN_COST_DETAILS
    (transaction_id,
     organization_id,
     inventory_item_id,
     cost_element_id,
     level_type,
     value_change,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date)
  SELECT
     mmt.transaction_id,
     mmt.organization_id,
     mmt.inventory_item_id,
     1,
     1,
     mmt.primary_quantity * (acc.new_landed_cost - acc.prior_landed_cost),
     SYSDATE,
     fnd_global.user_id,
     SYSDATE,
     fnd_global.user_id,
     fnd_global.login_id,
     fnd_global.conc_request_id,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE
  FROM cst_lc_mmt_gt mmt,
       cst_lc_adj_acctg_info_gt acc
  WHERE mmt.lcm_transaction_id = acc.lcm_transaction_id;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 50;

  /* Create the the average / layer cost update transactions */
  INSERT INTO MTL_MATERIAL_TRANSACTIONS
    (transaction_id,
     transaction_type_id,
     transaction_action_id,
     transaction_source_type_id,
     transaction_source_id,
     cost_group_id,
     primary_quantity,
     transaction_quantity,
     value_change,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     inventory_item_id,
     organization_id,
     transaction_date,
     acct_period_id,
     transaction_source_name,
     source_code,
     trx_source_line_id,
     transaction_reference,
     material_account,
     material_overhead_account,
     resource_account,
     outside_processing_account,
     overhead_account,
     expense_account_id,
     costed_flag,
     pm_cost_collected,
     owning_organization_id,
     owning_tp_type,
     transaction_uom)
  SELECT
     transaction_id,
     transaction_type_id,
     transaction_action_id,
     transaction_source_type_id,
     transaction_source_id,
     cost_group_id,
     primary_quantity,
     primary_quantity,
     value_change,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     inventory_item_id,
     organization_id,
     transaction_date,
     acct_period_id,
     transaction_source_name,
     source_code,
     trx_source_line_id,
     transaction_reference,
     material_account,
     material_overhead_account,
     resource_account,
     outside_processing_account,
     overhead_account,
     expense_account_id,
     costed_flag,
     pm_cost_collected,
     owning_organization_id,
     owning_tp_type,
     transaction_uom
  FROM CST_LC_MMT_GT;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 60;
  /* Create the xla events */
  INSERT INTO XLA_EVENTS_INT_GT
    (application_id,
     ledger_id,
     entity_code,
     source_id_int_1,
     source_id_int_2,
     source_id_int_3,
     event_class_code,
     event_type_code,
     event_date,
     event_status_code,
     security_id_int_1,
     security_id_int_2,
     transaction_date,
     reference_date_1,
     transaction_number,
     budgetary_control_flag)
  SELECT 707,
     acc.ledger_id,
     'RCV_ACCOUNTING_EVENTS',
     rae.rcv_transaction_id,
     rae.accounting_event_id,
     rae.organization_id,
     cmap.event_class_code,
     cmap.event_type_code,
     rae.transaction_date,
     XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
     rae.organization_id,
     rae.org_id,
     rae.transaction_date,
     acc.accounting_date,
     rae.accounting_event_id,
     NULL
  FROM cst_lc_rae_events_gt rae,
       cst_lc_adj_acctg_info_gt acc,
       cst_xla_rcv_event_map cmap
  WHERE rae.lcm_transaction_id = acc.lcm_transaction_id
    AND cmap.event_class_code IN ('LDD_COST_ADJ_RCV', 'LDD_COST_ADJ_DEL')
    AND cmap.transaction_type_id = rae.event_type_id;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 70;

  /* Call the xla package for creating xla events for the receiving events in bulk */
  xla_events_pub_pkg.create_bulk_events(p_application_id => 707,
      p_ledger_id => p_ledger_id,
      p_entity_type_code => 'RCV_ACCOUNTING_EVENTS',
      p_source_application_id => 201);

  l_stmt_num := 80;
  /* Insert into the LCM transactions table to maintain history of this adjustment */
  INSERT INTO cst_lc_adj_transactions
    (transaction_id,
     rcv_transaction_id,
     organization_id,
     inventory_item_id,
     transaction_date,
     prior_landed_cost,
     new_landed_cost,
     group_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date)
  SELECT
     transaction_id,
     rcv_transaction_id,
     organization_id,
     inventory_item_id,
     transaction_date,
     prior_landed_cost,
     new_landed_cost,
     group_id,
     SYSDATE,
     fnd_global.user_id,
     SYSDATE,
     fnd_global.user_id,
     fnd_global.login_id,
     fnd_global.conc_request_id,
     fnd_global.prog_appl_id,
     fnd_global.conc_program_id,
     SYSDATE
  FROM cst_lc_adj_interface
  WHERE group_id = p_group_id
    AND organization_id = p_organization_id
    AND process_status = 2;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 90;
  DELETE
   FROM cst_lc_adj_interface e
  WHERE e.group_id = p_group_id
    AND e.organization_id = p_organization_id
    AND e.process_status = 2
    AND EXISTS (SELECT 1
        FROM cst_lc_adj_transactions t
       WHERE t.transaction_id = e.transaction_id);

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows deleted'
      );

  END IF;

  l_stmt_num := 100;
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.end',
      '<< ' || l_api_name || ': Out Parameters:' ||
      ', x_return_status '  || x_return_status
      );
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
        FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
        FND_MESSAGE.set_token('PROCEDURE',l_api_name);
        FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

        FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
        FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

END Insert_Adjustment_Data;

/*===========================================================================+
|                                                                            |
| PROCEDURE      : Validate_Lc_Interface                                     |
|                                                                            |
| DESCRIPTION    : This procedure validates unvalidated interface records,   |
|                  populates details of failed validation into table         |
|                  CST_LC_ADJ_INTERFACE_ERRORS and updates the process_status|
|                  of interface records to validated = 2 or errored = 3.     |
|                                                                            |
|                                                                            |
|                                                                            |
| CALLED FROM    : Process_LcmAdjustments Procedure                          |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_group_id          IN  NUMBER    REQUIRED               |
|                   p_organization_id   IN  NUMBER    REQUIRED               |
|                   p_api_version       IN  NUMBER    REQUIRED               |
|                   p_init_msg_list     IN  VARCHAR2  REQUIRED               |
|                   p_validation_level  IN  NUMBER    REQUIRED               |
|                                                                            |
| OUT            :  x_ledger_id              OUT  NOCOPY VARCHAR2            |
|                   x_primary_cost_method    OUT  NOCOPY NUMBER              |
|                   x_primary_cost_method    OUT  NOCOPY VARCHAR2            |
|                   x_return_status          OUT  NOCOPY NUMBER              |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Validate_Lc_Interface
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    p_group_id                      IN      NUMBER,
    p_organization_id               IN      NUMBER,
    x_no_of_errored                 OUT     NOCOPY NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Validate_Lc_Interface';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                      NUMBER;
  l_num_records                   NUMBER;
  l_msg_data                      VARCHAR2(240);

  l_gl_info               RCV_CreateAccounting_PVT.RCV_AE_GLINFO_REC_TYPE;

BEGIN

    l_stmt_num := 0;

    /* Procedure level log message for Entry point */
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      '>> ' || l_api_name || ': Parameters:' ||
      ' Api version '  || p_api_version ||
      ', Init msg list '  || p_init_msg_list ||
      ', Validation level '  || p_validation_level ||
      ', Group id '  || p_group_id
      );
  END IF;

     /* Initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Standard call to check for call compatibility */
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

    l_stmt_num := 10;

    /* Validating the lcm adjustments.
       A record will be created for each, lcm adjustment transaction and error combination in
       the cst_lc_adj_interface_errors table and the adjustment interface record will be
       set to error status */
    INSERT ALL
    WHEN new_landed_cost < 0 THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'NEW_LANDED_COST', 'The column cannot have negative value',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN prior_landed_cost < 0 THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'PRIOR_LANDED_COST', 'The column cannot have negative value',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN closing_status <> 'O' THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'TRANSACTION_DATE', 'Purchasing Period is Closed or in the Future',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN open_flag = 'N' THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'TRANSACTION_DATE', 'Inventory Period is Closed',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN rcv_transaction_id = -1 THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'RCV_TRANSACTION_ID', 'Invalid Rcv Transaction',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN destination_type_code = 'EXPENSE' OR destination_type_code = 'SHOP FLOOR' THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'RCV_TRANSACTION_ID',
    'Destination type is set to ' || destination_type_code, fnd_global.user_id, SYSDATE,
    fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE, fnd_global.login_id,
    fnd_global.user_id, fnd_global.conc_request_id)
    WHEN NOT (parent_transaction_id = -1 AND transaction_type IN ('RECEIVE', 'MATCH') ) THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'RCV_TRANSACTION_ID', 'The receipt transaction is not the parent receipt',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN lcm_flag = 'N' THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'RCV_TRANSACTION_ID', 'PO Shipment is not LCM Enabled',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN pol_item_id <> clai_inventory_item_id THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'INVENTORY_ITEM_ID',
    'Item Id in adjustment transaction and original receipt donot match', fnd_global.user_id, SYSDATE,
    fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE, fnd_global.login_id,
    fnd_global.user_id, fnd_global.conc_request_id)
    WHEN rt_organization_id <> clai_organization_id THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'ORGANIZATION_ID', 'Organization Id in adjustment transaction
    and original receipt donot match', fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id,
    fnd_global.conc_program_id, SYSDATE, SYSDATE, fnd_global.login_id, fnd_global.user_id,
    fnd_global.conc_request_id)
    WHEN lcm_enabled_flag = 'N' THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'ORGANIZATION_ID', 'Organization is not LCM Enabled',
    fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE,
    fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id)
    WHEN nvl(lcm_account_id, -1) = -1 THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'ORGANIZATION_ID',
    'Landed cost absorption account is not defined for the organization', fnd_global.user_id, SYSDATE,
    fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE, fnd_global.login_id,
    fnd_global.user_id, fnd_global.conc_request_id)
    WHEN Decode(primary_cost_method, 1, 0, Nvl(lcm_var_account, -1)) = -1 THEN
    INTO cst_lc_adj_interface_errors (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
    CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
    VALUES (p_group_id, transaction_id, 'ORGANIZATION_ID',
    'Landed cost variance account is not defined for the organization', fnd_global.user_id, SYSDATE,
    fnd_global.prog_appl_id, fnd_global.conc_program_id, SYSDATE, SYSDATE, fnd_global.login_id,
    fnd_global.user_id, fnd_global.conc_request_id)
    SELECT distinct clai.transaction_id, clai.rcv_transaction_id, new_landed_cost, prior_landed_cost,
           gps.closing_status, open_flag, Nvl(rt.transaction_id, -1) recv_transaction_id,
           pod.destination_type_code, parent_transaction_id, transaction_type, Nvl(POLL.lcm_flag, 'N') lcm_flag,
           pol.item_id pol_item_id,
           clai.inventory_item_id clai_inventory_item_id,
           Nvl(rt.organization_id, -1) rt_organization_id, clai.organization_id clai_organization_id,
           Nvl(lcm_enabled_flag, 'N') lcm_enabled_flag,
           mp.lcm_var_account, rp.lcm_account_id, mp.primary_cost_method,
           msi.inventory_item_id msi_item_id
      FROM org_acct_periods oap,
           cst_lc_adj_interface clai,
           rcv_transactions rt,
           rcv_accounting_events rae,
           po_lines_all pol,
           po_line_locations_all poll,
           po_distributions_all pod,
           gl_period_statuses gps,
           cst_acct_info_v cai,
           mtl_parameters mp,
           mtl_system_items_b msi,
           rcv_parameters rp
     WHERE oap.organization_id (+) = clai.organization_id
     AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) >= Trunc(oap.period_start_date)
     AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) <= Trunc(oap.schedule_close_date)
     AND clai.group_id = p_group_id
     AND clai.process_status = 1
     AND clai.organization_id = p_organization_id
     AND rt.transaction_id  (+) = clai.rcv_transaction_id
     AND rae.rcv_transaction_id (+) = clai.rcv_transaction_id
     AND rae.event_type_id in (1,4)
     AND rae.po_line_location_id = poll.line_location_id (+)
     AND rae.po_distribution_id = pod.po_distribution_id (+)
     AND rae.po_line_id = pol.po_line_id (+)
     AND cai.organization_id  (+) = clai.organizatIon_id
     AND gps.ledger_id (+) = cai.ledger_id
     AND gps.application_id = G_PO_APPLICATION_ID
     AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) >= Trunc(gps.start_date)
     AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) <= Trunc(gps.end_date)
     AND gps.adjustment_period_flag <> 'Y'
     AND mp.organization_id (+) = clai.organization_id
     AND rp.organization_id (+) = clai.organization_id
     AND msi.inventory_item_id (+) = clai.inventory_item_id
     AND msi.organization_id (+) = clai.organization_id;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

     l_stmt_num := 20;
    /* For already validated transactions only check if PO period is still open */
     INSERT INTO cst_lc_adj_interface_errors
               (GROUP_ID, transaction_id, error_column, error_message, CREATED_BY,
               CREATION_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN, LAST_UPDATED_BY, REQUEST_ID)
        SELECT p_group_id, transaction_id, 'TRANSACTION_DATE', 'Purchasing Period is Closed or in the Future',
               fnd_global.user_id, SYSDATE, fnd_global.prog_appl_id, fnd_global.conc_program_id,
               SYSDATE, SYSDATE, fnd_global.login_id, fnd_global.user_id, fnd_global.conc_request_id
          FROM cst_lc_adj_interface clai,
               gl_period_statuses gps,
               cst_acct_info_v cai
         WHERE clai.group_id = p_group_id
           AND clai.process_status = 2
           AND clai.organization_id = p_organization_id
           AND cai.organization_id  = p_organization_id
           AND gps.set_of_books_id = cai.ledger_id
           AND gps.application_id = G_PO_APPLICATION_ID
           AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) >= Trunc(gps.start_date)
           AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(clai.transaction_date, cai.legal_entity) <= Trunc(gps.end_date)
           AND gps.adjustment_period_flag <> 'Y'
           and gps.closing_status <> 'O';

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows inserted'
      );

  END IF;

  l_stmt_num := 30;
  /* Set the errored adjustment interface records for the group to ERROR status */
  UPDATE cst_lc_adj_interface i
     SET process_status = 3,
         group_id = NULL
   WHERE group_id = p_group_id
     AND process_status IN (1,2)
     AND organization_id = p_organization_id
     AND EXISTS (SELECT 1
                   FROM cst_lc_adj_interface_errors e
                  WHERE e.transaction_id = i.transaction_id
                    AND e.group_id = p_group_id);

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows updated'
      );

  END IF;

     x_no_of_errored := SQL%ROWCOUNT;

     l_stmt_num := 40;
    /* Set all unerrored adjustment interface records for the group to VALIDATED status */
     UPDATE cst_lc_adj_interface
        SET process_status = 2
      WHERE group_id = p_group_id
        AND organization_id = p_organization_id
        AND process_status = 1;

  IF (l_sLog AND l_pLog) THEN
    l_num_records := SQL%ROWCOUNT;
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.query(' || l_stmt_num || ')',
      l_num_records || ' Rows updated'
      );

  END IF;

     l_stmt_num := 50;
  IF (
  l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.end',
      '<< ' || l_api_name || ': Out Parameters:' ||
      ' x_no_of_errored '  || x_no_of_errored ||
      ', x_return_status '  || x_return_status
      );
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF (l_uLog) THEN
        FND_MESSAGE.set_name('BOM', 'CST_UNEXP_ERROR');
        FND_MESSAGE.set_token('PACKAGE', G_PKG_NAME);
        FND_MESSAGE.set_token('PROCEDURE',l_api_name);
        FND_MESSAGE.set_token('STATEMENT',to_char(l_stmt_num));
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

        FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
        FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
        FND_MSG_PUB.ADD;

      END IF;

END Validate_Lc_Interface;

END CST_LcmAdjustments_PVT;  -- end package body

/
