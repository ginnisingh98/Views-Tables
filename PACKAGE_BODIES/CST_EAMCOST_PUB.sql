--------------------------------------------------------
--  DDL for Package Body CST_EAMCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_EAMCOST_PUB" AS
/* $Header: CSTPEACB.pls 120.32.12010000.18 2010/05/29 00:22:20 hyu ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_eamCost_PUB';
G_LOG_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
PG_DEBUG             VARCHAR2(1)  := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT 'CST_EAMCOST_PUB',
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_msg_prefix     VARCHAR2(64);
  l_msg_level      NUMBER;
  l_msg_module     VARCHAR2(256);
  l_beg_end_suffix VARCHAR2(15);
  l_org_cnt        NUMBER;
  l_line           VARCHAR2(32767);
BEGIN
  l_line       := line;
  l_msg_prefix := msg_prefix;
  l_msg_level  := msg_level;
  l_msg_module := msg_module;
  IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0) THEN
    l_msg_level  := FND_LOG.LEVEL_EXCEPTION;
  END IF;
  IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND PG_DEBUG = 'N' THEN
    RETURN;
  END IF;
  IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(l_msg_level, l_msg_module, SUBSTRB(l_line,1,4000));
  END IF;
EXCEPTION
  WHEN OTHERS THEN RAISE;
END debug;



FUNCTION Get_Transaction_Quantity(p_rcv_trx_id   IN NUMBER
                                 ,p_rcv_qty      IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_item(p_rcv_trx_id IN NUMBER)
  IS
  SELECT msi.outside_operation_uom_type
       , rt.primary_quantity
       , rt.transaction_type
    FROM mtl_system_items           msi
       , rcv_transactions           rt
       , po_lines_all               pl
   WHERE rt.transaction_id       = p_rcv_trx_id
     AND rt.po_line_id           = pl.po_line_id
     AND msi.inventory_item_id   = pl.item_id
     AND msi.organization_id     = rt.organization_id;

  CURSOR c_use_rate(p_rcv_trx_id IN NUMBER)
  IS
  SELECT wor.activity_id
       , wor.resource_id
       , wor.usage_rate_or_amount
       , wor.basis_type
       , wor.autocharge_type
       , wor.uom_code
       , wor.standard_rate_flag
    FROM rcv_transactions         rt
    ,    wip_operation_resources  wor
   WHERE rt.transaction_id      = p_rcv_trx_id
     AND wor.wip_entity_id      = rt.wip_entity_id
     AND wor.organization_id    = rt.organization_id
     AND wor.operation_seq_num  = rt.wip_operation_seq_num
     AND wor.resource_seq_num   = rt.wip_resource_seq_num
     AND (rt.wip_repetitive_schedule_id IS NULL
               OR wor.repetitive_schedule_id = rt.wip_repetitive_schedule_id);


   l_uom_basis        VARCHAR2(25);
   l_po_qty           NUMBER;
   l_transaction_type VARCHAR2(30);
   l_not_found        VARCHAR2(1) := 'N';
   l_rec              c_use_rate%ROWTYPE;
   l_res              NUMBER;
BEGIN
   debug('Get_Transaction_Quantity+');
   debug('  p_rcv_trx_id :'||p_rcv_trx_id);
   debug('  p_rcv_qty    :'||p_rcv_qty);

   IF (p_rcv_trx_id IS NULL OR p_rcv_trx_id = 0) OR
      (p_rcv_qty    IS NULL OR p_rcv_qty    = 0)
   THEN
      debug('10');
      debug('Get_Transaction_Quantity-');
      RETURN p_rcv_qty;
   END IF;
   OPEN c_item(p_rcv_trx_id);
   FETCH c_item INTO l_uom_basis
                    ,l_po_qty
                    ,l_transaction_type;
   IF c_item%NOTFOUND THEN
     debug('20');
     l_not_found := 'Y';
   END IF;
   CLOSE c_item;
   IF l_not_found = 'Y' THEN
     debug('Get_Transaction_Quantity-');
     RETURN p_rcv_qty;
   END IF;

   OPEN c_use_rate(p_rcv_trx_id);
   FETCH c_use_rate INTO l_rec;
   IF c_use_rate%NOTFOUND THEN
      debug('30');
     l_not_found := 'Y';
   END IF;
   CLOSE c_use_rate;
   IF l_not_found = 'Y' THEN
      debug('Get_Transaction_Quantity-');
     RETURN p_rcv_qty;
   END IF;
   -- Calculate the transaction quantity.
   debug('  l_uom_basis :'||l_uom_basis);
   debug('  l_rec.usage_rate_or_amount:'||l_rec.usage_rate_or_amount);
   IF l_uom_basis = 'ASSEMBLY' THEN
       IF (    l_rec.usage_rate_or_amount IS NOT NULL
           AND l_rec.usage_rate_or_amount <> 0)
       THEN
          debug('40');
          l_res := p_rcv_qty * l_rec.usage_rate_or_amount;
       ELSE
          debug('50');
          l_res := p_rcv_qty;
       END IF;
   ELSIF l_uom_basis = 'RESOURCE' THEN
      debug('60');
      l_res := p_rcv_qty;
   ELSE
      debug('70');
      debug('Get_Transaction_Quantity-');
      RETURN p_rcv_qty;
   END IF;
   debug('l_res:'||l_res);
   debug('Get_Transaction_Quantity-');
   RETURN l_res;
EXCEPTION
   WHEN OTHERS THEN
      debug('EXCEPTION OTHERS in Get_Transaction_Quantity :'||SQLERRM);
      RETURN p_rcv_qty;
END Get_Transaction_Quantity;


PROCEDURE display_rcv_rev_type
(p IN RCV_SeedEvents_PVT.rcv_event_rec_type,
 l OUT NOCOPY  VARCHAR2)
IS
BEGIN
 l := SUBSTRB(
' event_type_id :'       ||p.event_type_id||
',event_source :'        ||p.event_source||
',rcv_transaction_id :'  ||p.rcv_transaction_id||
',direct_delivery_flag :'||p.direct_delivery_flag||
',inv_distribution_id :' ||p.inv_distribution_id||
',transaction_date :'    ||p.transaction_date||
',po_header_id :'        ||p.po_header_id||
',po_release_id :'       ||p.po_release_id||
',po_line_id :'          ||p.po_line_id||
',po_line_location_id :' ||p.po_line_location_id||
',po_distribution_id :'  ||p.po_distribution_id||
',trx_flow_header_id :'  ||p.trx_flow_header_id||
',set_of_books_id :'     ||p.set_of_books_id||
',org_id :'              ||p.org_id||
',transfer_org_id:'      ||p.transfer_org_id||
',organization_id:'      ||p.organization_id||
',transfer_organization_id:'||p.transfer_organization_id||
',item_id :'         ||p.item_id||
',unit_price :'      ||p.unit_price||
',unit_nr_tax :'     ||p.unit_nr_tax||
',unit_rec_tax :'    ||p.unit_rec_tax||
',prior_unit_price :'||p.prior_unit_price||
',prior_nr_tax:'     ||p.prior_nr_tax||
',prior_rec_tax:'    ||p.prior_rec_tax||
',intercompany_pricing_option:'||p.intercompany_pricing_option||
',service_flag :'      ||p.service_flag||
',transaction_amount :'||p.transaction_amount||
',currency_code :'     ||p.currency_code||
',currency_conversion_type :'||p.currency_conversion_type||
',currency_conversion_rate :'||p.currency_conversion_rate||
',currency_conversion_date :'||p.currency_conversion_date||
',intercompany_price :'      ||p.intercompany_price||
',intercompany_curr_code :'  ||p.intercompany_curr_code||
',transaction_uom :'         ||p.transaction_uom||
',trx_uom_code :'            ||p.trx_uom_code||
',transaction_quantity :'    ||p.transaction_quantity||
',primary_uom :'             ||p.primary_uom||
',primary_quantity :'        ||p.primary_quantity||
',source_doc_uom :'          ||p.source_doc_uom||
',source_doc_quantity :'     ||p.source_doc_quantity||
',destination_type_code :'   ||p.destination_type_code||
',cross_ou_flag :'           ||p.cross_ou_flag||
',procurement_org_flag :'    ||p.procurement_org_flag ||
',ship_to_org_flag :'        ||p.ship_to_org_flag  ||
',drop_ship_flag :'          ||p.drop_ship_flag    ||
',debit_account_id :'        ||p.debit_account_id  ||
',credit_account_id :'       ||p.credit_account_id||
',intercompany_cogs_account_id :'||p.intercompany_cogs_account_id||
',lcm_account_id :'          ||p.lcm_account_id ||
',unit_landed_cost :'        ||p.unit_landed_cost,1,3980);
END;

/* ======================================================================= */
-- PROCEDURE
-- Process__MatCost
--
-- DESCRIPTION
-- This API retrieves  the charges of the costed MTL_MATERIAL_TRANSACTIONS
-- row, then called Update_eamCost to populate the eAM tables.
-- This API should be called for a specific MMT transaction which has been
-- costed successfully.
--
-- PURPOSE
-- To support eAM job costing for Rel 11i.6
--
/*=========================================================================== */

PROCEDURE Process_MatCost(
     p_api_version               IN      NUMBER,
     p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
     p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
     p_validation_level          IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     x_return_status             OUT NOCOPY     VARCHAR2,
     x_msg_count                 OUT NOCOPY     NUMBER,
     x_msg_data                  OUT NOCOPY     VARCHAR2,
     p_txn_id                    IN      NUMBER,
     p_user_id                   IN      NUMBER,
     p_request_id                IN      NUMBER,
     p_prog_id                   IN      NUMBER,
     p_prog_app_id               IN      NUMBER,
     p_login_id                  IN      NUMBER
     ) IS
   l_api_name    CONSTANT        VARCHAR2(30) := 'Process_MatCost';
   l_api_version CONSTANT        NUMBER       := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_txn_date            VARCHAR2(21);
   l_period_id           NUMBER;
   l_wip_entity_id       NUMBER;
   l_opseq_num           NUMBER;
   l_value               NUMBER;
   l_value_type          NUMBER := 1;  -- actual cost
   l_txn_mode            NUMBER := 1;  -- material transaction
   l_org_id              NUMBER;
   l_debug               VARCHAR2(80);

  BEGIN

   --  Standard Start of API savepoint
      SAVEPOINT Process_MatCost_PUB;
      l_debug := fnd_profile.value('MRP_DEBUG');


   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

    -- Get MMT info
       l_stmt_num := 10;
       SELECT transaction_source_id,
              operation_seq_num,
              acct_period_id,
              organization_id,
              to_char(transaction_date,'YYYY/MM/DD HH24:MI:SS')
          INTO l_wip_entity_id,
               l_opseq_num,
               l_period_id,
               l_org_id,
               l_txn_date
          FROM mtl_material_transactions
          WHERE transaction_id = p_txn_id;

   -- Get transaction value.
      l_stmt_num := 20;
      BEGIN

         SELECT SUM(NVL(base_transaction_value,0))
         INTO l_value
         FROM mtl_transaction_accounts
         WHERE transaction_id = p_txn_id
           AND accounting_line_type = 7         -- WIP valuation
         GROUP BY transaction_id;
      EXCEPTION /* bug fix 2077391 */
          WHEN NO_DATA_FOUND    THEN --no distributions in MTA
                  l_value := 0;
      END;

      l_stmt_num := 30;
         if (l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log, 'calling Update_eamCost');
         end if;
      Update_eamCost (
                p_api_version                  => 1.0,
                x_return_status                => l_return_status,
                x_msg_count                    => l_msg_count,
                x_msg_data                     => l_msg_data,
                p_txn_mode                     => l_txn_mode,
                p_period_id                    => l_period_id,
                p_org_id                       => l_org_id,
                p_wip_entity_id                => l_wip_entity_id,
                p_opseq_num                    => l_opseq_num,
                p_value_type                   => l_value_type,
                p_value                        => l_value,
                p_user_id                      => p_user_id,
                p_request_id                   => p_request_id,
                p_prog_id                      => p_prog_id,
                p_prog_app_id                  => p_prog_app_id,
                p_login_id                     => p_login_id,
                p_txn_date                     => l_txn_date);

       IF l_return_status <> FND_API.g_ret_sts_success THEN
          FND_FILE.put_line(FND_FILE.log, x_msg_data);
          l_api_message := 'Update_eamCost returned error';
          FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
          FND_MESSAGE.set_token('TEXT', l_api_message);
          FND_MSG_pub.add;
          RAISE FND_API.g_exc_error;
       END IF;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );


   EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Process_MatCost_PUB;
         x_return_status := FND_API.g_ret_sts_error;

      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO Process_MatCost_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

   --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
         ROLLBACK TO Process_MatCost_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PVT'
                  , 'Process_MatCost : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

  --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      END Process_MatCost;

/*=========================================================================== */
-- PROCEDURE
-- Process_ResCost
--
-- DESCRIPTION
-- This API processes all resources transactions in WIP_TRANSACTIONS for a
-- specified group id.  For each transaction, it identifies the correct
-- eAM cost element, department type, then populate eAM tables accordingly.
-- The calling program should ensure that all transactions for a
-- specific group id are costed successfully before calling this API.
--
-- PURPOSE
-- To support eAM job costing for Rel 11i.5
--
/*=========================================================================== */

PROCEDURE Process_ResCost(
          p_api_version               IN      NUMBER,
          p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level          IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,
          p_group_id                  IN      NUMBER,
          p_user_id                   IN      NUMBER,
          p_request_id                IN      NUMBER,
          p_prog_id                   IN      NUMBER,
          p_prog_app_id               IN      NUMBER,
          p_login_id                  IN      NUMBER
          ) IS
   l_api_name    CONSTANT        VARCHAR2(30) := 'Process_ResCost';
   l_api_version CONSTANT        NUMBER       := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_wip_entity_id       NUMBER;
   l_opseq_num           NUMBER;
   l_value               NUMBER;
   l_value_type          NUMBER := 1;  -- actual cost
   l_txn_mode            NUMBER; -- 2=resource txn, 3=res txn with specified charge dept
   l_period_id           NUMBER;
   l_resource_id         NUMBER;
   l_res_seq_num         NUMBER;
   l_debug               VARCHAR2(80);



-- Cursor to pull all WT transactions with group id = p_group_id and
-- eAM wip entity type.

   CURSOR l_resourcetxn_csr IS
      SELECT wt.transaction_id,
             wt.organization_id,
             wt.wip_entity_id,
             wt.acct_period_id,
             DECODE(wt.resource_id,NULL, null,
                                   wt.resource_id) resource_id,
             wt.operation_seq_num,
             wt.resource_seq_num,
             wt.charge_department_id,
             to_char(wt.transaction_date,'YYYY/MM/DD HH24:MI:SS') txn_date
         FROM wip_transactions wt
         WHERE wt.group_id = p_group_id
           AND EXISTS
              (SELECT 'eam jobs'
                 FROM wip_entities we
                 WHERE we.wip_entity_id = wt.wip_entity_id
                   AND we.entity_type in (6,7));

  BEGIN

   --  Standard Start of API savepoint
      SAVEPOINT Process_ResCost_PUB;
      l_debug := fnd_profile.value('MRP_DEBUG');


     if (l_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'In process_resCost');
     end if;


   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

    -- Loop thru cursor to process the fetched resource transactions
       FOR l_resourcetxn_rec IN l_resourcetxn_csr LOOP
          l_stmt_num := 40;
             SELECT SUM(NVL(wta.base_transaction_value,0))
                INTO l_value
             FROM wip_transaction_accounts wta
             WHERE transaction_id = l_resourcetxn_rec.transaction_id
             AND accounting_line_type = 7;

   /*  dle 7/20 ---------------------------------------------------------
      Add logic to check for user-entered charge dept.  If yes, populate
      p_res_seq_num with it.  The sole purpose to pass resource seq num
      to update_eamcost is for Get_MaintCostCat to determine the owning
      dept.  Since we have the charge dept, there is no need for
      Update_EamCost to call Get_MaintCostCat later on.  So it is safe to
      use p_res_seq_num for charge dept id
   */
          IF l_resourcetxn_rec.charge_department_id <> 0 THEN
             l_txn_mode := 3;   -- resource txn w/ specified charge dept
             l_res_seq_num := l_resourcetxn_rec.charge_department_id;
          ELSE
             l_txn_mode := 2;   -- resource txn w/o specified charge dept
             l_res_seq_num := l_resourcetxn_rec.resource_seq_num;
          END IF;

       if (l_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'l_txn_mode: ' || to_char(l_txn_mode));
     end if;

          l_stmt_num := 50;
          Update_eamCost (
                p_api_version              => 1.0,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data,
                p_txn_mode                 => l_txn_mode,
                p_period_id                => l_resourcetxn_rec.acct_period_id,
                p_org_id                   => l_resourcetxn_rec.organization_id,
                p_wip_entity_id            => l_resourcetxn_rec.wip_entity_id,
                p_opseq_num                => l_resourcetxn_rec.operation_seq_num,
                p_resource_id              => l_resourcetxn_rec.resource_id,
                p_res_seq_num              => l_res_seq_num,
                p_value_type               => l_value_type,
                p_value                    => l_value,
                p_user_id                  => p_user_id,
                p_request_id               => p_request_id,
                p_prog_id                  => p_prog_id,
                p_prog_app_id              => p_prog_app_id,
                p_login_id                 => p_login_id,
                p_txn_date                 => l_resourcetxn_rec.txn_date);

          IF l_return_status <> FND_API.g_ret_sts_success THEN
             FND_FILE.put_line(FND_FILE.log, x_msg_data);
             l_api_message := 'Update_eamCost returned error';
             FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
          END IF;

      END LOOP;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );


   EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Process_ResCost_PUB;
         x_return_status := FND_API.g_ret_sts_error;

      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO Process_ResCost_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

   --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
         ROLLBACK TO Process_ResCost_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PVT'
                  , 'Process_ResCost : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

  --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   END Process_ResCost;


/* ================================================================================= */
-- PROCEDURE
--   Update_eamCost
--
-- DESCRIPTION
--   This API insert or updates WIP_EAM_PERIOD_BALANCES and CST_EAM_ASSET_PER_BALANCES
--   with the amount passed by the calling program.
--
-- PURPOSE:
--    Support eAM job costing in Oracle Applications Rel 11i
--
-- PARAMETERS:
--   p_txn_mode:  indicates if it is a material cost (inventory items or direct
--                item) or resource cost.  Values:
--                      1 = material transaction
--                      2 = resource transaction
--                      3 = resource txn with user-specified charge department
--   p_wip_entity_id:  current job for which the charge is incurred
--   p_resource_id:  if it is a resource transaction (p_txn_mode = 2),
--                   a resource id must be passed by the calling program
--                   Do not pass param for material or dept-based overhead.
--   p_res_seq_num:  if it is a resource transaction (p_txn_mode = 2),
--                   the operation resource seq num must be passed.
--                   If p_txn_mode = 3, it is the charge department id.
--                   Do not pass param for material or dept-based overhead.
--   p_value_type: 1 = actual cost
--                 2 = estimated cost
--   p_period_id:  period id of an open period.  If the cost is for a future period
--                 pass the period set name and period name instead.  DO NOT pass
--                 period id 0, error will occur if there is no period id 0
--   p_period_set_name and p_period_name:  parameters to be passed instead of
--                 period id for a future period.
--
--   ACTUAL COSTS:
--   For a material transaction (inventory item) or receiving transaction
--   (direct item), it identifies the dept type of the using department.
--   For a resource transaction, it identifies the eAM cost element based
--   on the resource type, and the dept type of the owning department.
--
--   ESTIMATED COSTS:
--   The eAM cost estimating process will call this API to populate
--   WIP_EAM_PERIOD_BALANCES and CST_EAM_ASSET_PER_BALANCES with the estimated
--   cost values.  If it is a re-estimate, the calling program should back out the
--   old estimates from both WIP_EAM_PERIOD_BALANCES and CST_EAM_ASSET_PER_BALANCES
--   before calling this API and passing the new estimates to avoid duplication.
/* =============================================================================== */

PROCEDURE Update_eamCost (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_txn_mode                      IN      NUMBER, -- 1=material, 2=resource, 4=direct item
          p_period_id                     IN      NUMBER := null,
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_wip_entity_id                 IN      NUMBER,
          p_opseq_num                     IN      NUMBER, -- routing operation sequence
          p_resource_id                   IN      NUMBER := null,
          p_res_seq_num                   IN      NUMBER := null,
          p_value_type                    IN      NUMBER, -- 1=actual, 2=estimated
          p_value                         IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER,
          p_txn_date                      IN           VARCHAR2,
          p_txn_id                          IN          NUMBER DEFAULT -1 -- Direct Item Acct Enh (Patchset J)
          ) IS

   l_api_name    CONSTANT        VARCHAR2(30) := 'Update_eamCost';
   l_api_version CONSTANT        NUMBER       := 1.0;

   l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count               NUMBER := 0;
   l_msg_data                VARCHAR2(8000);
   l_stmt_num                NUMBER := 0;
   l_api_message             VARCHAR2(1000);

   l_wip_entity_type         NUMBER;
   l_resource_type           NUMBER := 0;
   l_maint_cost_category     NUMBER;
   l_asset_group_id          NUMBER;
   l_asset_number            VARCHAR2(30);
   l_eam_cost_element        NUMBER;
   l_dept_id                 NUMBER;
   l_owning_dept_id          NUMBER;
   l_mnt_obj_id              NUMBER;
   l_debug                   VARCHAR2(80);
   l_po_header_id            NUMBER;
   l_po_line_id              NUMBER;
   l_category_id             NUMBER;
   l_approved_date           DATE;
   l_check_category          NUMBER;/*BUG 8835299*/

   BEGIN

   --  Standard Start of API savepoint
      SAVEPOINT Update_eamCost_PUB;
      l_debug := fnd_profile.value('MRP_DEBUG');

      if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log, 'In Update_eamCost');
      end if;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

       IF (p_txn_mode not in (1,2,3,4) OR
           p_value_type not in (1,2) OR
           (p_resource_id is not null AND
            p_res_seq_num is null) OR
           (p_period_id is null AND
            (p_period_set_name is null or
            p_period_name is null))) THEN
             FND_MESSAGE.set_name('BOM', 'CST_INVALID_PARAMS');
             FND_MESSAGE.set_token('JOB', p_wip_entity_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.g_exc_error;
       END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing job '
                                     || to_char(p_wip_entity_id));


   -- Process only job with eAM wip entity type
      l_stmt_num := 60;

      SELECT we.entity_type
         INTO l_wip_entity_type
      FROM wip_entities we
      WHERE we.wip_entity_id = p_wip_entity_id;

      IF l_wip_entity_type not in (6,7) THEN
         l_api_message := 'Job is not eAM job.';
         l_api_message := l_api_message ||'Job id: '|| TO_CHAR(p_wip_entity_id);
         FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
         FND_MESSAGE.set_token('TEXT', l_api_message);
         FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

     l_stmt_num := 62;
     -- Get charge asset using API
     get_charge_asset (
          p_api_version             =>  1.0,
          p_wip_entity_id           =>  p_wip_entity_id,
          x_inventory_item_id       =>  l_asset_group_id,
          x_serial_number           =>  l_asset_number,
          x_maintenance_object_id   =>  l_mnt_obj_id,
          x_return_status           =>  l_return_status,
          x_msg_count               =>  l_msg_count,
          x_msg_data                =>  l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         FND_MESSAGE.set_token('TEXT', l_api_message);
         FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

   ------------------------------------------------------------
   -- Get eam cost element
   ------------------------------------------------------------
      l_stmt_num := 70;

      /* p_txn_mode = for Direct Item Txns; Direct Item Acct Enh (Patchset J) */
      if p_txn_mode = 4 then
        get_CostEle_for_DirectItem (
          p_api_version                =>        1.0,
          p_init_msg_list        =>        p_init_msg_list,
          p_commit                =>        p_commit,
          p_validation_level        =>        p_validation_level,
          x_return_status        =>        l_return_status,
          x_msg_count                =>        l_msg_count,
          x_msg_data                =>        l_msg_data,
          p_txn_id                =>        p_txn_id,
          p_mnt_or_mfg                =>        1,
          x_cost_element_id        =>        l_eam_cost_element
          );

        if (l_return_status <> fnd_api.g_ret_sts_success) then
          FND_FILE.put_line(FND_FILE.log, x_msg_data);
          l_api_message := 'get_CostElement_for_DirectItem returned unexpected error';
          FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
          FND_MESSAGE.set_token('TEXT', l_api_message);
          FND_MSG_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        end if;

        if (l_debug = 'Y') then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'eam_cost_element_id: '|| to_char(l_eam_cost_element));
        end if;

      else /* p_txn_mode in (1,2,3) */
        l_eam_cost_element := Get_eamCostElement(p_txn_mode,p_org_id,p_resource_id);

        IF l_eam_cost_element = 0 THEN
          l_api_message := 'Get_eamCostElement returned error';
          FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
          FND_MESSAGE.set_token('TEXT', l_api_message);
          FND_MSG_pub.add;
          RAISE FND_API.g_exc_error;
        END IF;
      end if; /* p_txn_mode */

   --------------------------------------------------------------
   -- Get maintenance cost category and departments
   --------------------------------------------------------------
      IF p_txn_mode = 3  THEN
         l_owning_dept_id := p_res_seq_num;

         l_stmt_num := 72;

        SELECT decode(maint_cost_category,NULL,0,1)
         INTO l_check_category
        FROM bom_departments
        WHERE department_id = l_owning_dept_id;

       IF(l_debug = 'Y')THEN
           fnd_file.put_line(fnd_file.log, 'l_check_category'||l_check_category);
       END IF;

       IF(l_check_category=1) THEN

         SELECT maint_cost_category
            INTO l_maint_cost_category
         FROM bom_departments
         WHERE department_id = l_owning_dept_id;

       ELSE
 	 SELECT def_maint_cost_category
 	 INTO l_maint_cost_category
 	 FROM wip_eam_parameters
 	 WHERE organization_id = p_org_id;

       END IF;

         l_stmt_num := 73;
         SELECT department_id
           INTO l_dept_id
         FROM wip_operations
         WHERE wip_entity_id = p_wip_entity_id
           AND operation_seq_num = p_opseq_num
           AND organization_id = p_org_id;

      ELSE
         l_stmt_num := 80;
         l_return_status := FND_API.G_RET_STS_SUCCESS;

      if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log, 'Getting maint Cost_category');
      end if;

        Get_MaintCostCat(
            p_txn_mode,
            p_wip_entity_id    => p_wip_entity_id,
            p_opseq_num        => p_opseq_num,
            p_resource_id      => p_resource_id,
            p_res_seq_num      => p_res_seq_num,
            x_return_status    => l_return_status,
            x_operation_dept   => l_dept_id,
            x_owning_dept      => l_owning_dept_id,
            x_maint_cost_cat   => l_maint_cost_category);

         IF l_return_status <> FND_API.g_ret_sts_success THEN
             FND_FILE.put_line(FND_FILE.log, x_msg_data);
             l_api_message := 'Get_MaintCostCat returned error';
             FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
         END IF;

      END IF;    -- end checking p_txn_mode

       if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'Calling insertUpdate_EamPerBal');
      end if;

   -- Insert/update WIP_EAM_PERIOD_BALANCES
      l_stmt_num := 120;
      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => p_period_id,
          p_period_set_name               => p_period_set_name,
          p_period_name                   => p_period_name,
          p_org_id                        => p_org_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => l_dept_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => p_opseq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => p_value_type,
          p_value                         => p_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id,
          p_txn_date                      => p_txn_date);

       IF l_return_status <> FND_API.g_ret_sts_success THEN
          FND_FILE.put_line(FND_FILE.log, x_msg_data);
          l_api_message := 'InsertUpdate_eamPerBal returned error';
          FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
          FND_MESSAGE.set_token('TEXT', l_api_message);
          FND_MSG_pub.add;
          RAISE FND_API.g_exc_error;
       END IF;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );


   EXCEPTION
      WHEN FND_API.g_exc_error THEN
          FND_FILE.PUT_LINE(fnd_file.log,'1 exception ' || SQLERRM );
         ROLLBACK TO Update_eamCost_PUB;
         x_return_status := FND_API.g_ret_sts_error;

      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
             FND_FILE.PUT_LINE(fnd_file.log,'1 exception ' || SQLERRM );
            ROLLBACK TO Update_eamCost_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

   --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, 'Exception in Update_eamcost'|| SQLERRM);
         ROLLBACK TO Update_eamCost_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB'
                  , 'Update_eamCost : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

  --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
END Update_eamCost;

/* ========================================================================= */
-- PROCEDURE
-- InsertUpdate_eamPerBal
--
-- DESCRIPTION
-- This procedure inserts or updates a row in wip_eam_period_balances table,
-- according to the parameters passed by the calling program.
-- Subsequently, it also inserts or update the related row in
-- cst_eam_asset_per_balances.
--
-- PURPOSE
-- Oracle Application Rel 11i.5
-- eAM Job Costing support
--
-- PARAMETERS
--        p_period_id
--        p_period_set_name  : for an open period, passing period id,
--                             instead of set name and period name,
--                             would be sufficient
--        p_period_name
--        p_org_id
--        p_wip_entity_id
--        p_dept_id          : department assigned to operation
--        p_owning_id        : department owning resource
--        p_maint_cost_dat   : department tyoe of cost incurred
--        p_opseq_num        : routing op seq
--        p_eam_cost_element : eam cost element id
--        p_asset_group_id   : inventory item id
--        p_asset_number     : serial number of asset item
--        p_value_type       : 1= actual cost, 2=system estimated cost
--        p_value            : cost amount
--
-- HISTORY
--    04/02/01      Dieu-Thuong Le         Initial creation
--
------------------------------------------------------------------------------

PROCEDURE InsertUpdate_eamPerBal (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_period_id                     IN      NUMBER := null,
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_wip_entity_id                 IN      NUMBER,
          p_owning_dept_id                IN      NUMBER,
          p_dept_id                       IN      NUMBER,
          p_maint_cost_cat                IN      NUMBER,
          p_opseq_num                     IN      NUMBER,
          p_eam_cost_element              IN      NUMBER,
          p_asset_group_id                IN      NUMBER,
          p_asset_number                  IN      VARCHAR2,
          p_value_type                    IN      NUMBER,
          p_value                         IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER,
          p_txn_date                      IN          VARCHAR2
          ) IS

   l_api_name    CONSTANT        VARCHAR2(30) := 'InsertUpdate_eamPerBal';
   l_api_version CONSTANT        NUMBER       := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_wepb_row_exists     NUMBER := 0;
   l_ceapb_row_exists    NUMBER := 0;
   l_statement           VARCHAR2(2000) := NULL;
   l_column              VARCHAR2(80) := NULL;
   l_col_type            NUMBER;

   l_period_id           NUMBER;
   l_period_set_name     VARCHAR2(15);
   l_period_name         VARCHAR2(15);
   l_period_start_date   DATE;
   open_period           BOOLEAN := TRUE;

   l_route_asset         VARCHAR2(1) := 'N';
   l_asset_count         NUMBER := 0;
   l_alloc_amount        NUMBER := 0;

   l_count               NUMBER := 0;
   l_debug               VARCHAR2(80);

   l_maint_obj_id        NUMBER;
   l_maint_obj_type      NUMBER;

/* Changed the following cursor to pick the member asset information from
   EAM_WORK_ORDER_ROUTE table instead of MTL_EAM_NETWORK_ASSETS
   for eAM Requirements Project- R12  */

    /* Bug 5315176 - Added the union clause below as EWOR table is
       not populated if the work order is in draft status */
     CURSOR c_network_assets (p_wip_entity_id NUMBER) IS
     select cii.instance_id,cii.inventory_item_id,cii.serial_number
     from csi_item_instances cii,
          eam_work_order_route ewor
     where ewor.wip_entity_id=p_wip_entity_id
     and cii.instance_id=ewor.instance_id
     union
     select mena.maintenance_object_id,cii.inventory_item_id,cii2.serial_number
     from csi_item_instances cii,
          mtl_eam_network_assets mena,
          mtl_parameters mp,
          csi_item_instances cii2
     where cii.instance_number = p_asset_number
     and mena.network_object_id = cii.instance_id
     and cii2.instance_id = mena.maintenance_object_id
     and cii.inventory_item_id = p_asset_group_id
     and mp.maint_organization_id = p_org_id
     and cii.last_vld_organization_id = mp.organization_id
     and nvl(mena.start_date_active, sysdate) <= sysdate
     and nvl(mena.end_date_active, sysdate) >= sysdate
     and maintenance_object_type =3;

   BEGIN


   --  Standard Start of API savepoint
      SAVEPOINT InsertUpdate_eamPerBal_PUB;
      l_debug := fnd_profile.value('MRP_DEBUG');

     if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(fnd_file.log,'In InsertUpdate_eamPerBal');
        FND_FILE.PUT_LINE(fnd_file.log,'p_asset_group_id: ' || to_char( p_asset_group_id ));
     end if;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

    -------------------------------------------------------------
    -- Get period id if period set name and period name is passed
    -- and vice versa
    -------------------------------------------------------------
    -- Calling program must pass period id or period set and period name.

       IF (p_period_id is null OR
           p_period_id = 0 ) AND
          (p_period_set_name is null OR
           p_period_name is null)  THEN
             l_api_message := 'Must pass period id, or period set name and period name. ';
             l_api_message := 'Job id: ' || TO_CHAR(p_wip_entity_id);
             FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_PUB.ADD;
             RAISE FND_API.g_exc_error;
       END IF;

    -- Get data from org_acct_periods if it is an open period.
       BEGIN
             l_stmt_num := 300;
             SELECT acct_period_id,
                    period_set_name,
                    period_name,
                    period_start_date
                INTO
                    l_period_id,
                    l_period_set_name,
                    l_period_name,
                    l_period_start_date
             FROM org_acct_periods
             WHERE organization_id = p_org_id  AND
                   (acct_period_id = p_period_id OR
                   (period_set_name = p_period_set_name AND
                    period_name = p_period_name));
       EXCEPTION
             WHEN no_data_found THEN     -- no open period
                  open_period := FALSE;
       END;

    -- Get data from gl_periods if it is a future period.
       IF NOT open_period  THEN
          l_stmt_num := 130;
         /* Bug 2113001 */
          l_period_set_name := p_period_set_name;
          l_period_name := p_period_name;
             SELECT 0,
                 period_set_name,
                 period_name,
                 start_date
              INTO
                 l_period_id,
                 l_period_set_name,
                 l_period_name,
                 l_period_start_date
          FROM gl_periods
          WHERE period_set_name = l_period_set_name AND
                period_name = l_period_name;
       END IF;

    ---------------------------------------------------------------
    -- Identify column to update value.
    ---------------------------------------------------------------

       IF p_value_type = 1 THEN                   -- actual_cost
          IF p_eam_cost_element = 1  THEN               -- equiptment
             l_column := 'actual_eqp_cost';
             l_col_type := 11;
          ELSIF  p_eam_cost_element = 2  THEN           -- labor
             l_column := 'actual_lab_cost';
             l_col_type := 12;
          ELSE
             l_column := 'actual_mat_cost';             -- material
             l_col_type := 13;
          END IF;
       ELSE                                        -- system estimated
          IF p_eam_cost_element = 1  THEN                 -- equiptment
             l_column := 'system_estimated_eqp_cost';
             l_col_type := 21;
          ELSIF  p_eam_cost_element = 2  THEN             -- labor
             l_column := 'system_estimated_lab_cost';
             l_col_type := 22;
          ELSE
             l_column := 'system_estimated_mat_cost';     -- material
             l_col_type := 23;
          END IF;
       END IF;

    /* -----------------------------------------------------------
     Insert/update WIP_EAM_PERIOD_BALANCES
     ------------------------------------------------------------- */

       l_stmt_num := 140;
       /* Bug 5315176 - Added nvl as operations are stamped in Requirements
          only when the work order is released */
       SELECT count(*)
          INTO l_count
          FROM wip_eam_period_balances
       WHERE period_set_name = l_period_set_name        AND
            period_name = l_period_name                 AND
            /* Bug 2113001 */
            acct_period_id = l_period_id               AND
            organization_id = p_org_id                  AND
            wip_entity_id = p_wip_entity_id             AND
            maint_cost_category = p_maint_cost_cat      AND
            owning_dept_id = p_owning_dept_id           AND
            nvl(operations_dept_id,-99) = nvl(p_dept_id,-99)  AND
            operation_seq_num = p_opseq_num;

       IF l_count <> 0 THEN
          l_stmt_num := 150;
       /* Bug 2545791: Change statement to use bind variables. */
       /* Bug 2935692: Change statement to use bind variables even in SET clause. */
       /* Bug 5315176 - Added nvl as operations are stamped in Requirements
          only when the work order is released */
          l_statement := 'UPDATE wip_eam_period_balances SET '
                        || l_column || '='
                        || 'nvl('|| l_column || ',0) + nvl(:p_value,0)'
                        || ', last_update_date = sysdate'
                        || ', last_updated_by = :p_user_id'
                        || ', last_update_login = :p_login_id'
                        || ' WHERE period_set_name = :l_period_set_name'
                        || ' AND period_name = :l_period_name'
                        || ' AND organization_id = :p_org_id'
                        || ' AND wip_entity_id = :p_wip_entity_id'
                        || ' AND maint_cost_category = :p_maint_cost_cat'
                        || ' AND owning_dept_id = :p_owning_dept_id'
                        || ' AND nvl(operations_dept_id,-99) = nvl(:p_dept_id,-99)'
                        || ' AND operation_seq_num = :p_opseq_num';



/*Bug 4205566 - Ignore row with acct_period_id = 0 when updating actual costs*/
         IF p_value_type = 1 THEN
            l_statement := l_statement
                           || ' AND acct_period_id <> 0';
         END IF;

         EXECUTE IMMEDIATE l_statement USING p_value,
                           p_user_id, p_login_id, l_period_set_name,
                           l_period_name, p_org_id, p_wip_entity_id,
                           p_maint_cost_cat, p_owning_dept_id,
                           p_dept_id, p_opseq_num ;

       ELSE
          l_stmt_num := 160;

          if (l_debug = 'Y') then
         FND_FILE.PUT_LINE(fnd_file.log,'Inserting wip_eam_period_balances....');
         FND_FILE.PUT_LINE(fnd_file.log,'period_Setname: '|| l_period_set_name );
         FND_FILE.PUT_LINE(fnd_file.log,'period_name: '||l_period_name );
         FND_FILE.PUT_LINE(fnd_file.log,'acct_period_id: '||to_char( l_period_id) );
         FND_FILE.PUT_LINE(fnd_file.log,'owning_dept_id: '||to_char(p_owning_dept_id) );
         FND_FILE.PUT_LINE(fnd_file.log,'op dept_id: '||to_char(p_dept_id ));
         FND_FILE.PUT_LINE(fnd_file.log,'op_seq_num: '||to_char(p_opseq_num) );
         FND_FILE.PUT_LINE(fnd_file.log,'COST_category: '|| to_char( p_maint_cost_cat) );
         FND_FILE.PUT_LINE(fnd_file.log,'asset group id: '|| to_char( p_asset_group_id) );
         end if;


          INSERT INTO wip_eam_period_balances (
             period_set_name,
             period_name,
             acct_period_id,
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
             manual_estimated_mat_cost,
             manual_estimated_lab_cost,
             manual_estimated_eqp_cost,
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
             l_period_set_name,
             l_period_name,
             l_period_id,
             p_wip_entity_id,
             p_org_id,
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
             0,
             0,
             0,
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
         if (l_debug = 'Y') then
           fnd_file.put_line(fnd_file.log, 'Inserted into wepb');
         end if;

      END IF;   -- end checking job balance row

          -- ------------------------------------------------------
          --  Get Maintenance_Object_Id and Maintenance_Object_Type
          --  for this asset (eAM Requirements Project - R12)
          -- -------------------------------------------------------
             SELECT maintenance_object_id, maintenance_object_type
             INTO l_maint_obj_id, l_maint_obj_type
             FROM WIP_DISCRETE_JOBS
             WHERE wip_entity_id = p_wip_entity_id
             AND organization_id = p_org_id;


     ------------------------------------------------------------
     --   Check for Route Asset
     ------------------------------------------------------------
     l_stmt_num := 162;

    /* Changes to refer CII instead of MSN as Network_Asset_Flag is
       no longer stored in MSN (Changes for eaM Requirements Project - R12) */

    If( l_maint_obj_type = 3) then
      BEGIN
         select network_asset_flag
         into l_route_asset
         from CSI_Item_Instances
         where instance_id = l_maint_obj_id;
      EXCEPTION /* bug fix 2716439 */
         WHEN NO_DATA_FOUND    THEN --no distributions in MTA
                l_route_asset := 'N';
      END;
    Else
       l_route_asset := 'N';
    End if;


     ---------------------------------------
     --  Check for Asset route
     ---------------------------------------
     if (l_route_asset = 'Y') then
       fnd_file.put_line(fnd_file.log,'txn date: ' || p_txn_date);

       l_stmt_num := 164;

   /* Pick up the member asset route information from EAM_WORK_ORDER_ROUTE
      instead of MTL_EAM_NETWORK_ASSETS (Changes for eaM Requirements
      Project - R12) */

       select count(*)
       into l_asset_count
       from EAM_WORK_ORDER_ROUTE
       where wip_entity_id=p_wip_entity_id;

      /* Bug 5315176 - Added the following statement as EWOR table might not
         be populated if the Work order is in Draft status */
         If l_asset_count =0 then
          select count(*)
          into l_asset_count
          from mtl_eam_network_assets mena,
               csi_item_instances cii,
               mtl_parameters mp
          where cii.instance_number = p_asset_number
          and mena.network_object_id = cii.instance_id
          and cii.inventory_item_id = p_asset_group_id
          and mp.maint_organization_id = p_org_id
          and cii.last_vld_organization_id = mp.organization_id
          and nvl(mena.start_date_active, sysdate) <= sysdate
          and nvl(mena.end_date_active, sysdate) >= sysdate
          and maintenance_object_type =3;
        end if;

     end if;

     -------------------------------------------------------------------
     --  Update actual and estimated costs by member asset.
     -------------------------------------------------------------------
     l_stmt_num := 165;
     if (l_asset_count > 0) then

       l_stmt_num := 166;

       l_alloc_amount := p_value/l_asset_count;


       l_stmt_num := 167;
       for route_Assets in c_network_assets(p_wip_entity_id)
        LOOP

          ------------------------------------------------
          --   insert into asset period balances
          ------------------------------------------------


          InsertUpdate_assetPerBal (
                p_api_version           => 1.0,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_period_id             => l_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => p_org_id,
                p_maint_cost_cat        => p_maint_cost_cat,
                p_asset_group_id        => route_assets.inventory_item_id,
                p_asset_number          => route_assets.serial_number,
                p_value                 => l_alloc_amount,
                p_column                => l_column,
                p_col_type              => l_col_type,
                p_period_start_date     => l_period_start_date,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id,
                p_maint_obj_type        => 3.0,
                p_maint_obj_id          => route_assets.instance_id
          );


          --BUG#5985039 FP BUG#5984909
          -- If return status is not success, raise error
          IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'InsertUpdate_assetPerBal error';
              FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB',
                    'InsertUpdate_eamPerBal('||to_char(l_stmt_num) || ')', l_api_message);
              RAISE FND_API.g_exc_error;
          END IF;

        END LOOP;

     else

        InsertUpdate_assetPerBal (
                p_api_version           => 1.0,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_period_id             => l_period_id,
                p_period_set_name       => l_period_set_name,
                p_period_name           => l_period_name,
                p_org_id                => p_org_id,
                p_maint_cost_cat        => p_maint_cost_cat,
                p_asset_group_id        => p_asset_group_id,
                p_asset_number          => p_asset_number,
                p_value                 => p_value,
                p_column                => l_column,
                p_col_type              => l_col_type,
                p_period_start_date     => l_period_start_date,
                p_user_id               => p_user_id,
                p_request_id            => p_request_id,
                p_prog_id               => p_prog_id,
                p_prog_app_id           => p_prog_app_id,
                p_login_id              => p_login_id,
                p_maint_obj_id          => l_maint_obj_id,
                p_maint_obj_type        => l_maint_obj_type
          );

          --BUG#5985039 - FPBUG 5984909
          -- If return status is not success, raise error
          IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'InsertUpdate_assetPerBal error';
              FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB',
                    'InsertUpdate_eamPerBal('||to_char(l_stmt_num) || ')', l_api_message);
              RAISE FND_API.g_exc_error;
          END IF;



     end if;

      if (l_debug = 'Y') then
      FND_FILE.PUT_LINE(fnd_file.log,'inserted into cst_eam_asset_per_balances' );
      end if;

      -- Standard check of p_commit
          IF FND_API.to_Boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   EXCEPTION

      WHEN FND_API.g_exc_error THEN
          FND_FILE.PUT_LINE(fnd_file.log,' exception' || SQLERRM );
         ROLLBACK TO InsertUpdate_eamPerBal_PUB;
         x_return_status := FND_API.g_ret_sts_error;

      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
             FND_FILE.PUT_LINE(fnd_file.log,' exception' || SQLERRM );
            ROLLBACK TO InsertUpdate_eamPerBal_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

      --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
          FND_FILE.PUT_LINE(fnd_file.log,'exception' || SQLERRM );
         ROLLBACK TO InsertUpdate_eamPerBal_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB',
                    'InsertUpdate_eamPerBal : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

      --  Get message count and data
           FND_MSG_PUB.count_and_get
             (  p_count  => x_msg_count
              , p_data   => x_msg_data
             );
   END InsertUpdate_eamPerBal;

/* ========================================================================= */
-- PROCEDURE
-- InsertUpdate_assetPerBal
--
-- DESCRIPTION
--
-- PURPOSE
-- Oracle Application Rel 11i.5
-- eAM Job Costing support
--
-- PARAMETERS
--        p_period_id
--        p_period_set_name  : for an open period, passing period id,
--                             instead of set name and period name,
--                             would be sufficient
--        p_period_name
--        p_org_id
--        p_maint_cost_dat   : department tyoe of cost incurred
--        p_eam_cost_element : eam cost element id
--        p_asset_group_id   : inventory item id
--        p_asset_number     : serial number of asset item
--        p_value_type       : 1= actual cost, 2=system estimated cost
--        p_value            : cost amount
--        p_maint_obj_id     : CII.instance_id (added for
--                             eAM Requirements Project-R12)
--        p_maint_obj_type   : 3 for serialized asset or serialized
--                             rebuildable item
--                             2 for non-serialized rebuildable item
--
-- HISTORY
--    03/27/05      Anjali R   Added p_maint_obj_id and p_maint_obj_type parameters
--                             for eAM Requirements Project - R12.
--                             CST_EAM_ASSET_PER_BALANCES table will now
--                             store corresponding IB Instance_id for each
--                             serialized asset or serialized rebuildable.
--                             For non-serialized rebuildable item, it will
--                             store MSI.inventory_item_id.
--    09/18/02      Anitha     Initial creation
--
------------------------------------------------------------------------------

PROCEDURE InsertUpdate_assetPerBal (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_period_id                     IN      NUMBER := null,
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_maint_cost_cat                IN      NUMBER,
          p_asset_group_id                IN      NUMBER,
          p_asset_number                  IN      VARCHAR2,
          p_value                         IN      NUMBER,
          p_column                        IN      VARCHAR2,
          p_col_type                      IN      NUMBER,
          p_period_start_date             IN      DATE,
          p_maint_obj_id                  IN          NUMBER,
          p_maint_obj_type                IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER
          ) IS

      l_api_name     CONSTANT  VARCHAR2(30) := 'InsertUpdate_assetPerBal';
      l_api_version  CONSTANT  NUMBER := 1.0;

      l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_msg_count         NUMBER := 0;
      l_msg_data          VARCHAR2(8000);
      l_api_message       VARCHAR2(1000);

      l_period_id           NUMBER;
      l_period_set_name     VARCHAR2(15);
      l_period_name         VARCHAR2(15);
      l_period_start_date   DATE;
      l_statement           VARCHAR2(2000) := NULL;

      l_stmt_num          NUMBER := 10;
      l_count             NUMBER := 0;

      l_debug            VARCHAR2(1);

  BEGIN
         --  Standard Start of API savepoint
      SAVEPOINT InsertUpdate_assetPerBal_PUB;
      l_debug := fnd_profile.value('MRP_DEBUG');

     if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(fnd_file.log,'In InsertUpdate_assetPerBal');
        FND_FILE.PUT_LINE(fnd_file.log,'p_asset_group_id: ' || to_char( p_asset_group_id ));
     end if;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

      l_count := 0;

      SELECT count(*)
         INTO l_count
         FROM cst_eam_asset_per_balances
      WHERE period_set_name = p_period_set_name     AND
            period_name = p_period_name             AND
            organization_id = p_org_id              AND
            inventory_item_id = p_asset_group_id    AND
            serial_number = p_asset_number          AND
            maint_cost_category = p_maint_cost_cat;

      IF l_count > 0 THEN
         l_stmt_num := 180;
      /* Bug 2545791: Using bind variables to construct statement */
      /* Bug 2935692: Change statement to use bind variables even in SET clause. */

      l_statement := 'UPDATE cst_eam_asset_per_balances SET '
                        || p_column || '='
                        || 'nvl('|| p_column || ',0) + nvl(:p_value,0)'
                        || ', last_update_date = sysdate'
                        || ', last_updated_by = :p_user_id'
                        || ' WHERE period_set_name = :p_period_set_name'
                        || ' AND period_name = :p_period_name'
                        || ' AND organization_id = :p_org_id'
                        || ' AND inventory_item_id = :p_asset_group_id'
                        || ' AND serial_number = :p_asset_number'
                        || ' AND maint_cost_category = :p_maint_cost_cat';

     EXECUTE IMMEDIATE l_statement USING p_value, p_user_id, p_period_set_name,
                      p_period_name, p_org_id, p_asset_group_id, p_asset_number,
                      p_maint_cost_cat ;

      ELSE
          l_stmt_num := 190;
          INSERT INTO cst_eam_asset_per_balances (
             period_set_name,
             period_name,
             acct_period_id,
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
             manual_estimated_mat_cost,
             manual_estimated_lab_cost,
             manual_estimated_eqp_cost,
             period_start_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             maintenance_object_type,
             maintenance_object_id
             )
         VALUES (
             p_period_set_name,
             p_period_name,
             p_period_id,
             p_org_id,
             p_asset_group_id,
             p_asset_number,
             p_maint_cost_cat,
             DECODE(p_col_type, 13, NVL(p_value,0),0),  -- actual mat
             DECODE(p_col_type, 12, NVL(p_value,0),0),  -- actual lab
             DECODE(p_col_type, 11, NVL(p_value,0),0),  -- actual eqp
             DECODE(p_col_type, 23, NVL(p_value,0),0),  -- sys est
             DECODE(p_col_type, 22, NVL(p_value,0),0),  -- sys est
             DECODE(p_col_type, 21, NVL(p_value,0),0),  -- sys est
             0,    -- manual estimated (not implemented yet)
             0,
             0,
             p_period_start_date,
             sysdate,
             p_user_id,
             sysdate,
             p_user_id,
             p_request_id,
             p_prog_app_id,
             p_maint_obj_type,
             p_maint_obj_id
             );
      END IF;        -- end checking asset balance rowcount


      -- Standard check of p_commit
          IF FND_API.to_Boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   EXCEPTION

      WHEN FND_API.g_exc_error THEN
          FND_FILE.PUT_LINE(fnd_file.log,' exception' || SQLERRM );
         ROLLBACK TO InsertUpdate_assetPerBal_PUB;
         x_return_status := FND_API.g_ret_sts_error;
      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
             FND_FILE.PUT_LINE(fnd_file.log,' exception' || SQLERRM );
            ROLLBACK TO InsertUpdate_assetPerBal_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

      --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
          FND_FILE.PUT_LINE(fnd_file.log,'exception' || SQLERRM );
         ROLLBACK TO InsertUpdate_assetPerBal_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB',
                    'InsertUpdate_assetPerBal : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

      --  Get message count and data
           FND_MSG_PUB.count_and_get
             (  p_count  => x_msg_count
              , p_data   => x_msg_data
             );
   END InsertUpdate_assetPerBal;


/* ============================================================== */
-- FUNCTION
-- Get_eamCostElement()
--
-- DESCRIPTION
-- Function to return the correct eAM cost element, based on
-- the transaction mode and the resource id of a transaction.
--
-- PARAMETERS
-- p_txn_mode (1=material, 2=resource)
-- p_org_id
-- p_resource_id (optional; to be passed only for a resource tranx)
--
/* ================================================================= */

FUNCTION Get_eamCostElement(
          p_txn_mode             IN  NUMBER,
          p_org_id               IN  NUMBER,
          p_resource_id          IN  NUMBER := null)
   RETURN number  IS

   l_eam_cost_element          NUMBER;
   l_resource_type             NUMBER;
   l_stmt_num                  NUMBER;
   l_debug                     VARCHAR2(80);

   BEGIN
   -------------------------------------------------------------------
   -- Determine eAM cost element.
   --   1 (equipment) ==> resource type 1 'machine'
   --   2 (labor)     ==> resource type 2 'person'
   --   3 (material)  ==> inventory or direct item
   --   For other resource types, use the default eAM cost element
   --   from eAM parameters
   --------------------------------------------------------------------

     l_debug := fnd_profile.value('MRP_DEBUG');

     if (l_debug = 'Y') THEN
       fnd_file.put_line(fnd_file.log, 'In Get_eamCostElement');
     end if;


      IF p_txn_mode = 1 THEN    -- material
         l_eam_cost_element := 3;
      ELSE                     -- resource
         IF p_resource_id is not null THEN
            l_stmt_num := 200;
            SELECT resource_type
               INTO l_resource_type
            FROM bom_resources
            WHERE organization_id = p_org_id
              AND resource_id = p_resource_id;
         END IF;      -- end checking resource id

         IF l_resource_type in (1,2) THEN
            l_eam_cost_element := l_resource_type;
         ELSE
            l_stmt_num := 210;
            SELECT def_eam_cost_element_id
               into l_eam_cost_element
            FROM wip_eam_parameters
            WHERE organization_id = p_org_id;
         END IF;      -- end checking resource type
      END IF;         -- end checking txn mode

     if (l_debug = 'Y') THEN
       fnd_file.put_line(fnd_file.log, 'l_eam_cost_element: '|| to_char(l_eam_cost_element));
        fnd_file.put_line(fnd_file.log, 'resource id: '|| to_char(p_resource_id));
     end if;

      RETURN l_eam_cost_element;

   EXCEPTION
      WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Get_eamCostElement - statement '
                           || l_stmt_num || ': '
                           || substr(SQLERRM,1,200));

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB'
                  , '.Get_eamCostElement : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

         RETURN 0;

END Get_eamCostElement;

/* ==================================================================== */
-- PROCEDURE
-- Get_MaintCostCat
--
-- DESCRIPTION
--
-- This procedure identifies the using, owning departments and the
-- related maint. cost cat for a resource or overhead charge based
-- on the transaction mode, wip entity id, routing operation, and
-- resource id.
-- Resource id and resource seq num are optional.  They should be
-- passed only for resource charges.  If they are not passed, this
-- procedure will assume it is a dept based (move based) overhead
-- charges.
--
-- IMPORTANT: Call this procedure ONLY if there is no user-entered CHARGE
-- DEPARTMENT ID.  There is no need to try and figure out the owning
-- department.  User-entered charge department is the overriding
-- owning department.
--
-- HISTORY
-- 4/02/01       Dieu-Thuong Le          Initial creation
--
/* ==================================================================== */

PROCEDURE Get_MaintCostCat(
          p_txn_mode           IN       NUMBER,
          p_wip_entity_id      IN       NUMBER,
          p_opseq_num          IN       NUMBER,
          p_resource_id        IN       NUMBER := null,
          p_res_seq_num        IN       NUMBER := null,
          x_return_status      OUT NOCOPY      VARCHAR2,
          x_operation_dept     OUT NOCOPY      NUMBER,
          x_owning_dept        OUT NOCOPY      NUMBER,
          x_maint_cost_cat     OUT NOCOPY      NUMBER
          ) IS

          l_owning_dept_id               NUMBER;
          l_dept_id                      NUMBER;
          l_maint_cost_category          NUMBER;
          l_stmt_num                     NUMBER;
          l_entity_type                  NUMBER;
          l_organization_id              NUMBER;
          l_ops_exists                   NUMBER := 0;

   BEGIN
   -----------------------------------------------------------------------
   -- Material and dept-based overhead
   --       Owning dept is the same than operation dept.
   --
   -- Resource and resource-based overhead
   --       Operation dept = wor.department_id, if null then get
   --                        wo.department_id
   --       (Note: wor.department id exists and can be different than
   --              wo.department id only for corner cases, such as
   --              phantom operation.)
   --       Owning dept = identify from bdr.share_from_dept_id
   --
   -- Department maintenance cost category.
   --       Identify from bom_departments.  If null for owning dept, get it
   --       for wip_discrete_jobs.owning_department_id.  If there is still
   --       no maintenance cost cat, get the default cost cat from
   --       wip_eam_parameters.
   --
   -- (anjgupta) If no operation dept is identified(eg if there is no routing)
   --  use the Work order owning dept for costing

   ------------------------------------------------------------------------
-- Initialize return status to success.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get organization id, just in case we need to get default cost
-- category from wip_eam_parameters later on.
      l_stmt_num := 215;
      SELECT entity_type,
             organization_id
      INTO   l_entity_type,
             l_organization_id
      FROM   wip_entities we
      WHERE  we.wip_entity_id = p_wip_entity_id;

-- Check for existence of operation.  If a job has a bill but no routing,
-- component requirements will not have a department associated to it.
-- In this case, the default cost category should be used.

      l_stmt_num := 220;
      SELECT count(*)
         INTO l_ops_exists
      FROM wip_operations
      WHERE wip_entity_id = p_wip_entity_id
        AND operation_seq_num = p_opseq_num;

      IF (p_txn_mode = 1) OR  -- material or dept ovhd or direct item txns
         (p_txn_mode = 2 AND p_resource_id is null) OR
         (p_txn_mode = 4) THEN

         l_stmt_num := 225;
         IF l_ops_exists <> 0 THEN     -- have operation
            l_stmt_num := 230;
            SELECT bd.department_id
               INTO l_dept_id
            FROM bom_departments bd,
                 wip_operations wo
            WHERE bd.department_id = wo.department_id
              AND wo.wip_entity_id = p_wip_entity_id
              AND wo.operation_seq_num = p_opseq_num;
         END IF;     -- end checking operation

         /* For material and dept-based overhead,
            owning dept is the same than using dept */
         l_owning_dept_id := l_dept_id;

      ELSE  -- resource
         l_stmt_num := 240;
         SELECT bdr.department_id,
                DECODE(bdr.share_from_dept_id,null,bdr.department_id,
                       bdr.share_from_dept_id)
                INTO l_dept_id, l_owning_dept_id
         FROM wip_operation_resources wor,
              wip_operations wo,
              bom_department_resources bdr
         WHERE bdr.department_id =
                   decode(wor.department_id,null,
                          wo.department_id, wor.department_id)
           AND bdr.resource_id = wor.resource_id
           AND wor.wip_entity_id = p_wip_entity_id
           AND wor.operation_seq_num = p_opseq_num
           AND wor.resource_seq_num = p_res_seq_num
           AND wo.wip_entity_id = wor.wip_entity_id
           AND wo.operation_seq_num = wor.operation_seq_num;

      END IF;    -- end checking material/ovhd

      -- If no dept is identified, get the job's owning dept.
      -- If Job does not have owning dept, get default cost category

      IF l_owning_dept_id is NULL THEN
           l_stmt_num := 250;
           /* get job's owning department  */
           SELECT owning_department
              INTO l_owning_dept_id
           FROM wip_discrete_jobs
           WHERE wip_entity_id = p_wip_entity_id;
      END IF;

      -- Bug 2158026 - if the operation dept is null, then use the
      --               work order owning dept for costing purposes
      IF l_dept_id IS NULL THEN
           l_stmt_num := 251;
           l_dept_id := l_owning_dept_id;
      END IF;

      IF l_entity_type = 1 THEN /* added by sgosain for future use */
         l_stmt_num := 260;
         l_maint_cost_category := 1;
       ELSE
            IF l_owning_dept_id is NOT NULL THEN        -- have department
                l_stmt_num := 270;
                SELECT maint_cost_category
                INTO l_maint_cost_category
                FROM bom_departments
                WHERE department_id = l_owning_dept_id;

            END IF;   -- end checking dept
      END IF;     -- end checking wip_entity_type

      /* Bug 1988507- If l_maint_cost_category is null
         get default maint_cost_category */
       IF l_maint_cost_category IS NULL THEN
           l_stmt_num := 280;
            SELECT def_maint_cost_category
               INTO l_maint_cost_category
            FROM wip_eam_parameters
            WHERE organization_id = l_organization_id;
       END IF;

      x_owning_dept := l_owning_dept_id;
      x_operation_dept := l_dept_id;
      x_maint_cost_cat := l_maint_cost_category;

/*
DBMS_OUTPUT.PUT_LINE('l_owning_dept_id: ' || l_owning_dept_id);
DBMS_OUTPUT.PUT_LINE('l_dept_id: ' || l_dept_id);
DBMS_OUTPUT.PUT_LINE('l_maint_cost_category: ' || l_maint_cost_category);
*/

   EXCEPTION
      WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Get_MaintCostCat - statement '
                           || l_stmt_num || ': '
                           || substr(SQLERRM,1,200));
         x_return_status := FND_API.g_ret_sts_unexp_error ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB'
                  , '.Get_MaintCostCat. : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

END Get_MaintCostCat;

/* =====================================================================  */
-- PROCEDURE                                                              --
--   Delete_eamPerBal                                                     --
-- DESCRIPTION                                                            --
--   This API removes the cost of a specific type, such as system         --
--   or manual estimates from wip_eam_per_balances and delete the rows    --
--   if all the costs are zeros.  It also update the corresponding amount --
--   It also update the corresponding amount in                           --
--   cst_eam_asset_per_balances.                                          --
--   NOTE:  This process is at the wip entity level.                      --
--                                                                        --
--   p_type = 1  (system estimates)                                       --
--            2 (manual estimates)                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
-- HISTORY:                                                               --
--                                                                        --
--    05/02/01      Dieu-thuong Le   Initial creation                     --
/* ======================================================================= */

PROCEDURE Delete_eamPerBal (
          p_api_version         IN       NUMBER,
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_commit              IN       VARCHAR2 := FND_API.G_FALSE,
          p_validation_level    IN       VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2,
          p_entity_id_tab       IN  CSTPECEP.wip_entity_id_type,
          p_org_id              IN       NUMBER,
          p_type                IN       NUMBER :=1
          )  IS

   l_api_name    CONSTANT       VARCHAR2(30) := 'Delete_eamPerBal';
   l_api_version CONSTANT       NUMBER       := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_asset_count         NUMBER := 0;
   l_maint_obj_id        NUMBER;
   l_act_mat_cost        NUMBER;
   l_act_lab_cost        NUMBER;
   l_act_eqp_cost        NUMBER;
   l_sys_mat_est         NUMBER;
   l_sys_lab_est         NUMBER;
   l_sys_eqp_est         NUMBER;
   l_man_mat_est         NUMBER;
   l_man_lab_est         NUMBER;
   l_man_eqp_est         NUMBER;

   l_txn_date            VARCHAR2(21) := to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');

   /* Added for Bug 5315176 */
   l_inventory_item_id   NUMBER;
   l_asset_number        VARCHAR2(30);
   l_route_asset         VARCHAR2(1);
   l_maint_obj_type      NUMBER;

   CURSOR v_est_csr(c_org_id NUMBER,
                               c_wip_entity_id NUMBER) IS
      SELECT period_set_name,
             period_name,
             maint_cost_category,
             sum(NVL(system_estimated_mat_cost,0)) sys_mat,
             sum(NVL(system_estimated_lab_cost,0)) sys_lab,
             sum(NVL(system_estimated_eqp_cost,0)) sys_eqp,
             sum(NVL(manual_estimated_mat_cost,0)) man_mat,
             sum(NVL(manual_estimated_lab_cost,0)) man_lab,
             sum(NVL(manual_estimated_eqp_cost,0)) man_eqp
         FROM wip_eam_period_balances
      WHERE wip_entity_id = c_wip_entity_id AND
            organization_id = c_org_id
      GROUP BY period_set_name,
               period_name,
               maint_cost_category;

   BEGIN

   --  Standard Start of API savepoint
      SAVEPOINT Delete_eamPerBal_PUB;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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

  -- Since passing parameter is a PL/SQL table, check if it has any element.
    -- Then proceed. First loop thru all and update, then bulk delete
    IF p_entity_id_tab.COUNT > 0 THEN

     FOR l_index IN p_entity_id_tab.FIRST..p_entity_id_tab.LAST LOOP

    -- Get asset group and asset number of job
       l_stmt_num := 300;
       SELECT maintenance_object_id,
              maintenance_object_type,
              asset_group_id,
              asset_number
       INTO l_maint_obj_id,
            l_maint_obj_type,
            l_inventory_item_id,
            l_asset_number
       FROM wip_discrete_jobs
       WHERE organization_id = p_org_id AND
             wip_entity_id = p_entity_id_tab(l_index);

    -- Check if the work order is for a route asset
    -- Delete asset cost from member assets if the above is true

    /* Refer EAM_WORK_ORDER_ROUTE table instead of MTL_EAM_NETWORK_ASSETS
       table. (Changes for eAM Requirements Project - R12) */
    l_stmt_num := 310;

    /* Bug 5315176 - Added the following check to determine if the asset
       for which work order is being estimated is an asset route  */
    If( l_maint_obj_type = 3) then
      BEGIN
         select network_asset_flag
         into l_route_asset
         from CSI_Item_Instances
         where instance_id = l_maint_obj_id;
      EXCEPTION
         WHEN NO_DATA_FOUND    THEN
                l_route_asset := 'N';
      END;
    Else
       l_route_asset := 'N';
    End if;

    l_stmt_num := 312;

    If l_route_asset = 'Y' then
      select count(*)
      into l_asset_count
      from EAM_WORK_ORDER_ROUTE ewor
      where ewor.wip_entity_id = p_entity_id_tab(l_index);

   /* Bug 5315176 - Added the following statement as EWOR table is not
      populated for Work Orders in Draft status */
      If l_asset_count =0 then
       select count(*)
       into l_asset_count
       from mtl_eam_network_assets mena,
            csi_item_instances cii,
            mtl_parameters mp
       where cii.instance_number = l_asset_number
       and mena.network_object_id = cii.instance_id
       and cii.inventory_item_id = l_inventory_item_id
       and mp.maint_organization_id = p_org_id
       and cii.last_vld_organization_id = mp.organization_id
       and nvl(mena.start_date_active, sysdate) <= sysdate
       and nvl(mena.end_date_active, sysdate) >= sysdate
       and maintenance_object_type =3;
      end if;
    End if;
   -----------------------------------------------------
   -- Update cst_eam_asset_per_balances first before
   -- deleting wip_eam_period_balances
   -- If the asset on the work order is a route asset,
   -- then adjust asset value for the members
   ------------------------------------------------------

   if (l_asset_count > 0) then
      FOR v_est_rec IN v_est_csr(p_org_id,
                          p_entity_id_tab(l_index)) LOOP

         IF (p_type = 1) AND            -- update sys est
            ( v_est_rec.sys_mat <> 0 OR
              v_est_rec.sys_lab <> 0 OR
              v_est_rec.sys_eqp <> 0)   THEN
              l_stmt_num := 312;
              UPDATE cst_eam_asset_per_balances
              SET system_estimated_mat_cost =
                    system_estimated_mat_cost
                  - (v_est_rec.sys_mat/l_asset_count),
                 system_estimated_lab_cost =
                    system_estimated_lab_cost
                  - (v_est_rec.sys_lab/l_asset_count),
                 system_estimated_eqp_cost =
                    system_estimated_eqp_cost
                  - (v_est_rec.sys_eqp/l_asset_count)
              WHERE period_set_name = v_est_rec.period_set_name AND
                    period_name = v_est_rec.period_name AND
                    maintenance_object_id in
                       (select ewor.instance_id
                        from eam_work_order_route ewor
                        where ewor.wip_entity_id = p_entity_id_tab(l_index)
                        union    /* Added the union clause for Bug 5315176 */
                        select mena.maintenance_object_id
                        from mtl_eam_network_assets mena,
                             csi_item_instances cii,
                             mtl_parameters mp
                        where cii.instance_number = l_asset_number
                        and mena.network_object_id = cii.instance_id
                        and cii.inventory_item_id = l_inventory_item_id
                        and mp.maint_organization_id = p_org_id
                        and cii.last_vld_organization_id = mp.organization_id
                        and nvl(mena.start_date_active, sysdate) <= sysdate
                        and nvl(mena.end_date_active, sysdate) >= sysdate
                        and maintenance_object_type =3
                        )
                    AND organization_id = p_org_id
                    AND maint_cost_category = v_est_rec.maint_cost_category;

           ----------------------------------------------------------------
           -- Delete ceapb rows with zeros in ALL value columns
           ----------------------------------------------------------------
           DELETE from cst_eam_asset_per_balances
           WHERE actual_mat_cost = 0 AND
           NVL(actual_lab_cost,0) = 0 AND
           NVL(actual_eqp_cost,0) = 0 AND
           NVL(system_estimated_mat_cost,0) = 0 AND
           NVL(system_estimated_lab_cost,0) = 0 AND
           NVL(system_estimated_eqp_cost,0) = 0 AND
           NVL(manual_estimated_mat_cost,0) = 0 AND
           NVL(manual_estimated_lab_cost,0) = 0 AND
           NVL(manual_estimated_eqp_cost,0) = 0 AND
           period_set_name = v_est_rec.period_set_name AND
           period_name = v_est_rec.period_name AND
           maintenance_object_id in
              (select ewor.instance_id
               from eam_work_order_route ewor
               where ewor.wip_entity_id = p_entity_id_tab(l_index)
               union    /* Added the union clause for Bug 5315176 */
               select mena.maintenance_object_id
               from mtl_eam_network_assets mena,
                    csi_item_instances cii,
                    mtl_parameters mp
               where cii.instance_number = l_asset_number
               and mena.network_object_id = cii.instance_id
               and cii.inventory_item_id = l_inventory_item_id
               and mp.maint_organization_id = p_org_id
               and cii.last_vld_organization_id = mp.organization_id
               and nvl(mena.start_date_active, sysdate) <= sysdate
               and nvl(mena.end_date_active, sysdate) >= sysdate
               and maintenance_object_type =3
               )
           AND organization_id = p_org_id
           AND maint_cost_category = v_est_rec.maint_cost_category;

             ELSIF (p_type = 2) AND           -- update manual est
              (v_est_rec.man_mat <> 0 OR
               v_est_rec.man_lab <> 0 OR
               v_est_rec.man_eqp <> 0)    THEN
              l_stmt_num := 314;
              UPDATE cst_eam_asset_per_balances
              SET manual_estimated_mat_cost =
                    manual_estimated_mat_cost
                  - (v_est_rec.man_mat/l_asset_count),
                 manual_estimated_lab_cost =
                    manual_estimated_lab_cost
                  - (v_est_rec.man_lab/l_asset_count),
                 manual_estimated_eqp_cost =
                    manual_estimated_eqp_cost
                  - (v_est_rec.man_eqp/l_asset_count)
              WHERE period_set_name = v_est_rec.period_set_name AND
                    period_name = v_est_rec.period_name AND
                    maintenance_object_id in
                       (select ewor.instance_id
                        from eam_work_order_route ewor
                        where ewor.wip_entity_id = p_entity_id_tab(l_index)
                        union    /* Added the union clause for Bug 5315176 */
                        select mena.maintenance_object_id
                        from mtl_eam_network_assets mena,
                             csi_item_instances cii,
                             mtl_parameters mp
                        where cii.instance_number = l_asset_number
                        and mena.network_object_id = cii.instance_id
                        and cii.inventory_item_id = l_inventory_item_id
                        and mp.maint_organization_id = p_org_id
                        and cii.last_vld_organization_id = mp.organization_id
                        and nvl(mena.start_date_active, sysdate) <= sysdate
                        and nvl(mena.end_date_active, sysdate) >= sysdate
                        and maintenance_object_type =3
                    )
                    AND organization_id = p_org_id AND
                    maint_cost_category = v_est_rec.maint_cost_category;

               ----------------------------------------------------------------
               -- Delete ceapb rows with zeros in ALL value columns
               ----------------------------------------------------------------
               DELETE from cst_eam_asset_per_balances
               WHERE actual_mat_cost = 0 AND
               NVL(actual_lab_cost,0) = 0 AND
               NVL(actual_eqp_cost,0) = 0 AND
               NVL(system_estimated_mat_cost,0) = 0 AND
               NVL(system_estimated_lab_cost,0) = 0 AND
               NVL(system_estimated_eqp_cost,0) = 0 AND
               NVL(manual_estimated_mat_cost,0) = 0 AND
               NVL(manual_estimated_lab_cost,0) = 0 AND
               NVL(manual_estimated_eqp_cost,0) = 0 AND
               period_set_name = v_est_rec.period_set_name AND
               period_name = v_est_rec.period_name AND
               maintenance_object_id in
                  (select ewor.instance_id
                   from eam_work_order_route ewor
                   where ewor.wip_entity_id = p_entity_id_tab(l_index)
                   union    /* Added the union clause for Bug 5315176 */
                   select mena.maintenance_object_id
                   from mtl_eam_network_assets mena,
                        csi_item_instances cii,
                        mtl_parameters mp
                   where cii.instance_number = l_asset_number
                   and mena.network_object_id = cii.instance_id
                   and cii.inventory_item_id = l_inventory_item_id
                   and mp.maint_organization_id = p_org_id
                   and cii.last_vld_organization_id = mp.organization_id
                   and nvl(mena.start_date_active, sysdate) <= sysdate
                   and nvl(mena.end_date_active, sysdate) >= sysdate
                   and maintenance_object_type =3
               )
               AND organization_id = p_org_id AND
               maint_cost_category = v_est_rec.maint_cost_category;

             END IF;  --end checking p_value
          END LOOP;

     ELSE -- for assets which do not have an asset route

      FOR v_est_rec IN v_est_csr(p_org_id,
                          p_entity_id_tab(l_index)) LOOP

         IF (p_type = 1) AND            -- update sys est
            ( v_est_rec.sys_mat <> 0 OR
              v_est_rec.sys_lab <> 0 OR
              v_est_rec.sys_eqp <> 0)   THEN
              l_stmt_num := 316;
              UPDATE cst_eam_asset_per_balances
              SET system_estimated_mat_cost =
                    system_estimated_mat_cost
                  - v_est_rec.sys_mat,
                 system_estimated_lab_cost =
                    system_estimated_lab_cost
                  - v_est_rec.sys_lab,
                 system_estimated_eqp_cost =
                    system_estimated_eqp_cost
                  - v_est_rec.sys_eqp
              WHERE period_set_name = v_est_rec.period_set_name AND
                    period_name = v_est_rec.period_name AND
                    maintenance_object_id = l_maint_obj_id AND
                    maint_cost_category = v_est_rec.maint_cost_category;

         ELSIF (p_type = 2) AND           -- update manual est
              (v_est_rec.man_mat <> 0 OR
               v_est_rec.man_lab <> 0 OR
               v_est_rec.man_eqp <> 0)    THEN
              l_stmt_num := 320;
              UPDATE cst_eam_asset_per_balances
              SET manual_estimated_mat_cost =
                    manual_estimated_mat_cost
                  - v_est_rec.man_mat,
                 manual_estimated_lab_cost =
                    manual_estimated_lab_cost
                  - v_est_rec.man_lab,
                 manual_estimated_eqp_cost =
                    manual_estimated_eqp_cost
                  - v_est_rec.man_eqp
              WHERE period_set_name = v_est_rec.period_set_name AND
                    period_name = v_est_rec.period_name AND
                    maintenance_object_id = l_maint_obj_id AND
                    organization_id = p_org_id AND
                    maint_cost_category = v_est_rec.maint_cost_category;
         END IF;        -- end checking p_value
      END LOOP;
     END IF; -- check for asset route

    END LOOP; -- End loop for p_entity_id_tab


     l_stmt_num := 325;
    ----------------------------------------------------------------
    -- Delete ceapb rows with zeros in ALL value columns
    ----------------------------------------------------------------
     DELETE from cst_eam_asset_per_balances
     WHERE actual_mat_cost = 0 AND
           NVL(actual_lab_cost,0) = 0 AND
           NVL(actual_eqp_cost,0) = 0 AND
           NVL(system_estimated_mat_cost,0) = 0 AND
           NVL(system_estimated_lab_cost,0) = 0 AND
           NVL(system_estimated_eqp_cost,0) = 0 AND
           NVL(manual_estimated_mat_cost,0) = 0 AND
           NVL(manual_estimated_lab_cost,0) = 0 AND
           NVL(manual_estimated_eqp_cost,0) = 0 AND
           maintenance_object_id = l_maint_obj_id AND
           organization_id = p_org_id;

   -------------------------------------------------------------
   -- Update wepb estimates to zeros
   -------------------------------------------------------------
     l_stmt_num := 330;
     FORALL l_index IN p_entity_id_tab.FIRST..p_entity_id_tab.LAST

      UPDATE wip_eam_period_balances
         SET system_estimated_mat_cost =
                decode(p_type,1,0,system_estimated_mat_cost),
             system_estimated_lab_cost =
                decode(p_type,1,0,system_estimated_lab_cost),
             system_estimated_eqp_cost =
                decode(p_type,1,0,system_estimated_eqp_cost),
             manual_estimated_mat_cost =
                decode(p_type,2,0,manual_estimated_mat_cost),
             manual_estimated_lab_cost =
                decode(p_type,2,0,manual_estimated_lab_cost),
             manual_estimated_eqp_cost =
                decode(p_type,2,0,manual_estimated_eqp_cost)
      WHERE wip_entity_id = p_entity_id_tab(l_index) AND
            organization_id = p_org_id;

   ----------------------------------------------------------------
   -- Delete wepb and ceapb rows with zeros in ALL value columns
   ----------------------------------------------------------------
      l_stmt_num := 340;
      FORALL l_index IN p_entity_id_tab.FIRST..p_entity_id_tab.LAST
        DELETE from wip_eam_period_balances
        WHERE actual_mat_cost = 0 AND
            NVL(actual_lab_cost,0) = 0 AND
            NVL(actual_eqp_cost,0) = 0 AND
            NVL(system_estimated_mat_cost,0) = 0 AND
            NVL(system_estimated_lab_cost,0) = 0 AND
            NVL(system_estimated_eqp_cost,0) = 0 AND
            NVL(manual_estimated_mat_cost,0) = 0 AND
            NVL(manual_estimated_lab_cost,0) = 0 AND
            NVL(manual_estimated_eqp_cost,0) = 0 AND
            wip_entity_id = p_entity_id_tab(l_index) AND
            organization_id = p_org_id;

          l_stmt_num := 350;

    END IF;

   EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Delete_eamPerBal_PUB;
         x_return_status := FND_API.g_ret_sts_error;

      --  Get message count and data
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO Delete_eamPerBal_PUB;
            x_return_status := FND_API.g_ret_sts_unexp_error ;

   --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      WHEN OTHERS THEN
         ROLLBACK TO Delete_eamPerBal_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         FND_FILE.PUT_LINE(FND_FILE.LOG,'Delete_eamPerBal - statement '
                           || l_stmt_num || ': '
                           || substr(SQLERRM,1,200));

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_eamCost_PUB'
                  , '.Delete_eamPerBal : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

  --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   END Delete_eamPerBal;


--------------------------------------------------------------------------n
-- PROCEDURE                                                              --
--   Compute_Job_Estimate                                                 --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for a Job                             --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:
--
--    03/29/05     Anjali R      Added call to Insert_eamBalAcct() to     --
--                               insert estimation details into           --
--                               CST_EAM_BALANCE_BY_ACCOUNTS table, for   --
--                               eAM Requirements Project - R12.          --
--
--    04/17/01     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Compute_Job_Estimate (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug              IN   VARCHAR2 := 'N',
                            p_wip_entity_id      IN   NUMBER,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

    l_api_name    CONSTANT       VARCHAR2(30) := 'Compute_Job_Estimate';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000);

    l_entity_type               NUMBER := 0;
    l_organization_id           NUMBER := 0;
    l_rates_ct                  NUMBER := 0;
    l_lot_size                  NUMBER := 0;
    l_round_unit                NUMBER := 0;
    l_precision                 NUMBER := 0;
    l_ext_precision             NUMBER := 0;
    l_wip_project_id            NUMBER := 0;
    l_cost_group_id             NUMBER := 0;
    l_primary_cost_method       NUMBER := 0;
    l_acct_period_id            NUMBER := NULL;
    l_scheduled_completion_date DATE;
    l_operation_dept_id         NUMBER := 0;
    l_owning_dept_id            NUMBER := 0;
    l_maint_cost_category       NUMBER := 0;
    l_eam_cost_element          NUMBER := 0;
    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_message               VARCHAR2(10000);
    l_stmt_num                  NUMBER;
    l_dept_id                   NUMBER := 0;
    l_period_set_name           VARCHAR2(15) := NULL;
    l_period_name               VARCHAR2(15) := NULL;
    l_dummy                     NUMBER := 0;
    l_asset_group_item_id               NUMBER := 0;
    l_asset_number              VARCHAR2(80);
    l_department_id             NUMBER := 0;
    l_sum_rbo                   NUMBER := 0;
    l_mnt_obj_id                NUMBER;
    l_trunc_le_sched_comp_date  DATE;

    l_acct_id                   NUMBER;
    l_material_account          NUMBER;
    l_material_overhead_account NUMBER;
    l_resource_account          NUMBER;
    l_overhead_account          NUMBER;
    l_osp_account               NUMBER;
    l_wip_acct_class            VARCHAR2(10);

    l_exec_flag                 NUMBER;
    l_index_var                 NUMBER;
    l_value                     NUMBER;
    l_account                   NUMBER;
    l_approved_date             DATE;

    CURSOR c_wor IS
      SELECT wor.operation_seq_num operation_seq_num,
             crc.resource_rate resource_rate,
             wor.uom_code uom,
             wor.usage_rate_or_amount resource_usage,
             decode(br.functional_currency_flag,
                            1, 1,
                            NVL(crc.resource_rate,0))
                   * wor.usage_rate_or_amount
                   * decode(wor.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) raw_resource_value,

             ROUND(decode(br.functional_currency_flag,
                            1, 1,
                            NVL(crc.resource_rate,0))
                   * wor.usage_rate_or_amount
                   * decode(wor.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) ,l_ext_precision) resource_value,
             wor.resource_id resource_id,
             wor.resource_seq_num resource_seq_num,
             wor.basis_type basis_type,
             wor.usage_rate_or_amount
                   * decode(wor.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) usage_rate_or_amount,
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
      AND    crc.cost_type_id = l_rates_ct;

    CURSOR c_rbo (  p_resource_id   NUMBER,
                    p_dept_id       NUMBER,
                    p_org_id        NUMBER,
                    p_res_units     NUMBER,
                    p_res_value     NUMBER) IS

      SELECT  cdo.overhead_id ovhd_id,
              cdo.rate_or_amount actual_cost,
              cdo.basis_type basis_type,
              ROUND(cdo.rate_or_amount *
                        decode(cdo.basis_type,
                                3, p_res_units,
                                p_res_value), l_ext_precision) rbo_value,
              cdo.department_id
      FROM    cst_resource_overheads cro,
              cst_department_overheads cdo
      WHERE   cdo.department_id    = p_dept_id
      AND     cdo.organization_id  = p_org_id
      AND     cdo.cost_type_id     = l_rates_ct
      AND     cdo.basis_type IN (3,4)
      AND     cro.cost_type_id     = cdo.cost_type_id
      AND     cro.resource_id      = p_resource_id
      AND     cro.overhead_id      = cdo.overhead_id
      AND     cro.organization_id  = cdo.organization_id;

   /* Select the costs corresponding to each cost element. The non-zero value for each
      cost element will be used to estimate charges for WAC Accounts - eAM Enhancements
      Project R12 */

   CURSOR c_wro IS
      SELECT wro.operation_seq_num operation_seq_num,
             wro.department_id department_id,
             ROUND(SUM(NVL(wro.required_quantity,0) * -- l_lot_size *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.item_cost,0)),
                        NVL(ccicv.item_cost,0))), l_ext_precision) mat_value,
             ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.material_cost,0)),
                        NVL(ccicv.material_cost,0))), l_ext_precision) material_cost,
             ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.material_overhead_cost,0)),
                        NVL(ccicv.material_overhead_cost,0))), l_ext_precision) material_overhead_cost,
             ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.resource_cost,0)),
                        NVL(ccicv.resource_cost,0))), l_ext_precision) resource_cost,
             ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.outside_processing_cost,0)),
                        NVL(ccicv.outside_processing_cost,0))), l_ext_precision) outside_processing_cost,
             ROUND(SUM(NVL(wro.required_quantity,0) *
               decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,
                                                          nvl(ccicv.overhead_cost,0)),
                        NVL(ccicv.overhead_cost,0))), l_ext_precision) overhead_cost
      FROM   wip_requirement_operations wro,
             cst_cg_item_costs_view ccicv,
             mtl_system_items_b msi,
             wip_discrete_jobs wdj
      WHERE  wro.wip_entity_id = p_wip_entity_id
             AND wdj.wip_entity_id = wro.wip_entity_id
             AND ccicv.inventory_item_id = wro.inventory_item_id
             AND ccicv.organization_id = wro.organization_id
             AND ccicv.cost_group_id = decode(l_primary_cost_method,1,1,
                                                l_cost_group_id)
             AND wro.wip_supply_type IN (1,4)
             AND nvl(wro.released_quantity,-1) <> 0
             /* Non stockable items will be included in c_wrodi */
             AND msi.organization_id = wro.organization_id
             AND msi.inventory_item_id = wro.inventory_item_id
             AND msi.stock_enabled_flag = 'Y'
             AND wro.wip_entity_id = wdj.wip_entity_id    /* Bug 5230287 */
             AND wro.organization_id = wdj.organization_id   /* Bug 5230287 */
      GROUP BY wro.operation_seq_num,
               wro.department_id;

   /* Added this cursor for patchset J, to use unit price in WRO for
      unordered qty of non-stockable items */
   CURSOR c_wrodi IS
   SELECT
             wro.operation_seq_num operation_seq_num,
             wro.department_id department_id,
             ROUND(SUM(
                     DECODE(
                       SIGN(NVL(wro.required_quantity,0) - NVL(wediv.quantity_ordered,0)),
                       1,
                       NVL(wro.required_quantity,0) - NVL(wediv.quantity_ordered,0),
                       0
                     ) *
                     NVL(wro.unit_price,0)), l_ext_precision) mat_value,
                     msi.inventory_item_id item_id,
                     mic.category_id category_id
      FROM   wip_requirement_operations wro,
             (SELECT cedi.work_order_number,
                     cedi.organization_id,
                     cedi.task_number,
                     cedi.item_id,
                     SUM(
                       inv_convert.inv_um_convert(
                         cedi.item_id, NULL, cedi.quantity_ordered,
                         cedi.uom_code, msi.primary_uom_code, NULL, NULL
                       )
                       /* We convert to primary_uom because the required_quantity in
                          WRO is always in the primary unit of measure */
                     ) quantity_ordered
                     /* Sum is needed because there could be multiple POs/Reqs
                        for the same non-stockable item */
              FROM   cst_eam_direct_items_temp cedi,
                     mtl_system_items_b msi
              WHERE  cedi.item_id = msi.inventory_item_id
              AND    cedi.organization_id = msi.organization_id
              AND    cedi.work_order_number = p_wip_entity_id
              GROUP
              BY     cedi.work_order_number,
                     cedi.organization_id,
                     cedi.task_number,
                     cedi.item_id
             ) wediv,
             mtl_system_items_b msi,
             mtl_item_categories mic,
             mtl_default_category_sets mdcs
      WHERE  wro.wip_entity_id = p_wip_entity_id
      AND    wediv.work_order_number(+) = wro.wip_entity_id
      AND    wediv.item_id (+)= wro.inventory_item_id
      AND    wediv.organization_id(+) = wro.organization_id
      AND    wediv.task_number(+) = wro.operation_seq_num
      AND    wro.wip_supply_type IN (1,4)
      AND    msi.organization_id = wro.organization_id
      AND    msi.inventory_item_id = wro.inventory_item_id
      AND    msi.stock_enabled_flag = 'N'
      AND    msi.inventory_item_id = mic.inventory_item_id
      AND    mic.category_set_id = mdcs.category_set_id
      AND    mic.organization_id = wro.organization_id
      AND    mdcs.functional_area_id = 2
      GROUP  BY
             wro.operation_seq_num,
             wro.department_id,
             msi.inventory_item_id,
             mic.category_id;

  /* Added this cursor for patchset J, to include unordered quantity
      of description items */
   CURSOR c_wedi IS
      SELECT
             wedi.operation_seq_num operation_seq_num,
             wedi.department_id department_id,
             wedi.purchasing_category_id category_id,
             wedi.direct_item_sequence_id direct_item_id,
             ROUND(
               DECODE(wediv.order_type_lookup_code,
                'FIXED PRICE', NVL(wedi.amount,0) * NVL(wediv.currency_rate,1) - sum( NVL(wediv.amount_delivered ,0)),
                'RATE', NVL(wedi.amount,0) * NVL(wediv.currency_rate,1) - sum(NVL(wediv.amount_delivered ,0)),
                 DECODE(
                 SIGN(
                   NVL(wedi.required_quantity,0) -
                   SUM(
                     /* Sum is needed because there could be multiple
                        POs/Reqs for the same description item */
                     inv_convert.inv_um_convert(
                       NULL, NULL, NVL(wediv.quantity_ordered,0),
                       NVL(wediv.uom_code, wedi.uom), wedi.uom, NULL, NULL
                     )
                   )
                 ),
                 1,
                 (
                   NVL(wedi.required_quantity,0) -
                   SUM(
                     inv_convert.inv_um_convert(
                       NULL, NULL, NVL(wediv.quantity_ordered,0),
                       NVL(wediv.uom_code, wedi.uom), wedi.uom, NULL, NULL
                     )
                   )
                 ),
                 0
               ) * NVL(wedi.unit_price, 0) * NVL(wediv.currency_rate,1)),
               l_ext_precision
             ) wedi_value
      FROM   wip_eam_direct_items wedi,
             cst_eam_direct_items_temp wediv
      WHERE  wedi.wip_entity_id = p_wip_entity_id
      AND    wediv.work_order_number(+) = wedi.wip_entity_id
      AND    wediv.organization_id(+) = wedi.organization_id
      AND    wediv.direct_item_sequence_id(+) = wedi.direct_item_sequence_id
      AND    wediv.task_number(+) = wedi.operation_seq_num
/*      AND    wediv.category_id(+) = wedi.purchasing_category_id   - commented for Bug 5403190 */
      GROUP
      BY     wedi.operation_seq_num,
             wedi.department_id,
             wedi.purchasing_category_id,
             wedi.direct_item_sequence_id,
             NVL(wedi.required_quantity,0),
             NVL(wedi.unit_price,0),
             NVL(wedi.amount,0),
             wediv.order_type_lookup_code,
             wediv.currency_rate;

   /* Bug 2283331 - Cancelled or Rejected POs/Req. should not be estimated */
   /* Added category_id, category_date for Direct Item Acct Enh (Patchset J) */
   /* The join to WEDIV in the cursor is mainly to restrict the POs/Reqs to
      those corresponding to the direct items */

   /* The following cursor is changed to pick up the amount for Service Line
      Types from PO/Requisition tables based on order_type_lookup_code.
      (for eAM Requirements Project - R12) */
   CURSOR c_pda IS
      SELECT
              ROUND(SUM(
                       decode
                       (
                         NVL(pla.order_type_lookup_code,'QUANTITY'),
                        'RATE',(
                                (NVL(wediv.amount,0) -   NVL(pda.amount_cancelled,0))
                                + PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                                )
                                * NVL(wediv.currency_rate,1)  ,
                        'FIXED PRICE',(
                                       (NVL(wediv.amount,0) - NVL(pda.amount_cancelled,0))
                                       + PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                                       )
                                       * NVL(wediv.currency_rate,1),
                        (
                         NVL(plla.price_override,0) *
                         (NVL(pda.quantity_ordered,0) - NVL(pda.quantity_cancelled,0))
                        + PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                        )
                        * NVL(wediv.currency_rate,1)
                   )), l_ext_precision
              ) pda_value,
              pda.wip_operation_seq_num operation_seq_num,
              pla.category_id category_id,
              nvl(pha.approved_date, pha.last_update_date) category_date,
              pha.type_lookup_code, /* Bug 5201970 */
              wediv.po_release_id   /* Bug 5201970 */
      FROM    po_distributions_all pda,
              po_line_locations_all plla,
              po_headers_all pha,
              po_lines_all pla,
              cst_eam_direct_items_temp wediv
      WHERE   wediv.work_order_number = p_wip_entity_id
      AND     wediv.organization_id = l_organization_id
      AND     wediv.task_number = pda.wip_operation_seq_num
      AND     wediv.category_id = pla.category_id
      AND     pha.po_header_id = wediv.po_header_id
      AND     pla.po_line_id = wediv.po_line_id
      AND     pda.wip_entity_id = wediv.work_order_number
      AND     pda.po_header_id = wediv.po_header_id
      AND     pda.destination_organization_id = wediv.organization_id
      AND     pda.po_line_id = pla.po_line_id
      AND     plla.line_location_id = pda.line_location_id
      GROUP BY pda.wip_operation_seq_num,
               pla.category_id,
               pha.approved_date,
               pha.last_update_date,
               wediv.currency_rate,
               pha.last_update_date,
               pha.type_lookup_code,
               wediv.po_release_id
      UNION
          SELECT
              ROUND(SUM(
                        DECODE(NVL(prla.order_type_lookup_code,'QUANTITY'),
                        'RATE', NVL(wediv.amount,NVL(prla.amount * nvl(wediv.currency_rate,1),0)),
                        'FIXED PRICE', NVL(wediv.amount,NVL(prla.amount * nvl(wediv.currency_rate,1),0)),
                        NVL(prla.unit_price,0) * NVL(prla.quantity,0))
                         * NVL(wediv.currency_rate,1)), 6) pda_value,
              prla.wip_operation_seq_num operation_seq_num,
              prla.category_id category_id,
              prha.last_update_date category_date,
              null, /* Bug 5201970 */
              null  /* Bug 5201970 */
      FROM    po_requisition_lines_all prla,
              po_requisition_headers_all prha,
              cst_eam_direct_items_temp wediv
      WHERE   wediv.work_order_number = p_wip_entity_id
      AND     wediv.organization_id = l_organization_id
      AND     wediv.task_number = prla.wip_operation_seq_num
      AND     wediv.category_id = prla.category_id
      AND     wediv.po_header_id IS NULL -- to ensure that we do not double count
      AND     prha.requisition_header_id = wediv.requisition_header_id
      AND     prla.destination_organization_id = wediv.organization_id
      AND     prla.wip_entity_id = wediv.work_order_number
      AND     prla.requisition_line_id = wediv.requisition_line_id
      GROUP BY prla.wip_operation_seq_num,
               prla.category_id,
               prha.last_update_date,
               wediv.currency_rate;


   CURSOR c_dbo IS

      SELECT  SUM(ROUND(NVL(cdo.rate_or_amount,0) *
                decode(cdo.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) ,l_ext_precision)) dbo_value,
              cdo.department_id department_id ,
              wo.operation_seq_num operation_seq_num

      FROM    wip_operations wo,
              cst_department_overheads cdo
      WHERE   cdo.cost_type_id = l_rates_ct
      AND     cdo.organization_id = l_organization_id
      AND     cdo.department_id = wo.department_id
      AND     wo.wip_entity_id = p_wip_entity_id
      AND     cdo.rate_or_amount <> 0
      AND     cdo.basis_type IN (1,2)
      GROUP BY wo.operation_seq_num,
               cdo.department_id;


  /* Cursor added for eAM Budgeting and Forecasting Requirements (R12).
     The cursor returns the WIP Account that will be hit for the given
     job and cost element. */
    cursor c_acct( p_wip_entity_id NUMBER) is
    select  material_account,
            material_overhead_account,
            resource_account,
            outside_processing_account,
            overhead_account,
            class_code wip_acct_class
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id;


l_period_start_date Date;
l_mfg_cost_element_id Number;

BEGIN
    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT Compute_Job_Estimate;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables
    l_stmt_num := 10;

    -------------------------------------------------------------------------
    -- Check Entity Type is eAM
    -------------------------------------------------------------------------

    SELECT  entity_type,
            organization_id
    INTO    l_entity_type,
            l_organization_id
    FROM    wip_entities we
    WHERE   we.wip_entity_id = p_wip_entity_id;


    IF (l_entity_type NOT IN (1,6)) THEN

      l_api_message := l_api_message|| 'Invalid WIP entity type: '
                      ||TO_CHAR(l_entity_type)
                      ||' WIP Entity: '
                      ||TO_CHAR(p_wip_entity_id);

      FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
      RAISE FND_API.g_exc_error;

    ELSE

      l_stmt_num := 15;

      SELECT start_quantity,
             NVL(project_id, -1),
             scheduled_completion_date
      INTO   l_lot_size,
             l_wip_project_id,
             l_scheduled_completion_date
      FROM   wip_discrete_jobs wdj
      WHERE  wdj.wip_entity_id = p_wip_entity_id;

      l_stmt_num := 16;
      -- Get charge asset using API
      get_charge_asset (
          p_api_version             =>  1.0,
          p_wip_entity_id           =>  p_wip_entity_id,
          x_inventory_item_id       =>  l_asset_group_item_id,
          x_serial_number           =>  l_asset_number,
          x_maintenance_object_id   =>  l_mnt_obj_id,
          x_return_status           =>  l_return_status,
          x_msg_count               =>  l_msg_count,
          x_msg_data                =>  l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         FND_MESSAGE.set_token('TEXT', l_api_message);
         FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;


    END IF;

    /* Bug #1950738. Use default cost group of organization */
    SELECT NVL(default_cost_group_id,-1)
    INTO l_cost_group_id
    FROM mtl_parameters
    WHERE organization_id = l_organization_id;

    IF (l_wip_project_id <> -1) THEN

      l_stmt_num := 20;

      SELECT NVL(costing_group_id,-1)
      INTO   l_cost_group_id
      FROM   pjm_project_parameters ppp
      WHERE  ppp.project_id = l_wip_project_id
      AND    ppp.organization_id = l_organization_id;

      IF (l_cost_group_id = -1) THEN

        l_api_message := 'No CG Found for Project: '
                        ||TO_CHAR(l_wip_project_id)
                        ||' Organization: '
                        ||TO_CHAR(l_organization_id);
        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

      END IF;

    END IF; -- check for wip_project_id <> -1


    -------------------------------------------------------------------------
    -- Find the period in which the scheduled completion date falls
    -------------------------------------------------------------------------

    l_stmt_num := 23;
    l_trunc_le_sched_comp_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                                    l_scheduled_completion_date,
                                    l_organization_id);

    l_stmt_num := 25;

    SELECT  count(*)
    INTO    l_dummy
    FROM    org_acct_periods oap
    WHERE   oap.organization_id = l_organization_id
    AND     l_trunc_le_sched_comp_date BETWEEN oap.period_start_date
                                       AND     oap.schedule_close_date;

    IF (NVL(l_dummy,0) = 1) THEN

      l_stmt_num := 30;

      SELECT  oap.acct_period_id,
              oap.period_set_name,
              oap.period_name,
              oap.period_start_date
      INTO    l_acct_period_id,
              l_period_set_name,
              l_period_name,
              l_period_start_date
      FROM    org_acct_periods oap
      WHERE   oap.organization_id = l_organization_id
      AND     l_trunc_le_sched_comp_date BETWEEN oap.period_start_date
                                         AND     oap.schedule_close_date;

    ELSE

      l_stmt_num := 35;

/* The following query will be modified to refer to cst_organization_definitions
   as an impact of the HR-PROFILE option. */

      SELECT  gp.period_set_name,
              gp.period_name,
              gp.start_date
      INTO    l_period_set_name,
              l_period_name,
              l_period_start_date
      FROM    gl_periods gp,
              gl_sets_of_books gsob,
              /*org_organization_definitions ood */
              cst_organization_definitions ood
      WHERE   ood.organization_id = l_organization_id
      AND     gsob.set_of_books_id = ood.set_of_books_id
      AND     gp.period_set_name = gsob.period_set_name
      AND     gp.adjustment_period_flag = 'N'
      AND     gp.period_type = gsob.accounted_period_type
      AND     l_trunc_le_sched_comp_date BETWEEN gp.start_date
                                         AND     gp.end_date;

    END IF; -- check for l_dummy

    IF (l_acct_period_id IS NULL AND (l_period_set_name IS NULL OR
                       l_period_name IS NULL)) THEN

      l_stmt_num := 40;

      l_api_message := 'Cannot Find Period for Date: ';
      l_api_message := l_api_message||TO_CHAR(l_trunc_le_sched_comp_date);
      FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
      RAISE FND_API.g_exc_error;

    END IF;

    -------------------------------------------------------------------------
    -- Derive the currency extended precision for the organization
    -------------------------------------------------------------------------
    l_stmt_num := 45;

    CSTPUTIL.CSTPUGCI(l_organization_id,
                      l_round_unit,
                      l_precision,
                      l_ext_precision);


    -------------------------------------------------------------------------
    -- Derive valuation rates cost type based on organization's cost method
    -------------------------------------------------------------------------

    l_stmt_num := 50;

    SELECT  decode (mp.primary_cost_method,
                      1, mp.primary_cost_method,
                      NVL(mp.avg_rates_cost_type_id,-1)),
            mp.primary_cost_method
    INTO    l_rates_ct,
            l_primary_cost_method
    FROM    mtl_parameters mp
    WHERE   mp.organization_id = l_organization_id;

    IF (l_rates_ct = -1) THEN

        l_api_message := 'Rates Type not defined for Org: '
                         ||TO_CHAR(l_organization_id);

        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;


    END IF;

    IF (p_debug = 'Y') THEN
      l_api_message := 'Wip Entity Type: '||TO_CHAR(l_entity_type);
      l_api_message := l_api_message||' Rates Ct: '||TO_CHAR(l_rates_ct);
      l_api_message := l_api_message||' Lot Size: '||TO_CHAR(l_lot_size);
      l_api_message := l_api_message||' Ext Precision: '
                                         ||TO_CHAR(l_ext_precision);
      l_api_message := l_api_message||' Asset Group Id: '
                                         ||TO_CHAR(l_asset_group_item_id);
      l_api_message := l_api_message||' Asset Number: '
                                         ||l_asset_number;
      l_api_message := l_api_message||' Wip Proj Id: '
                                         ||TO_CHAR(l_wip_project_id);
      l_api_message := l_api_message||' Cg Id: '||TO_CHAR(l_cost_group_id);
      l_api_message := l_api_message||' Cost Method: '
                                         ||TO_CHAR(l_primary_cost_method);
      l_api_message := l_api_message||' Acct Prd Id: '
                                         ||TO_CHAR(l_acct_period_id);
      l_api_message := l_api_message||' Schd. Compl. Dt: '
                                         ||TO_CHAR(l_scheduled_completion_date);
      l_api_message := l_api_message||' TruncLE ComplDt: '
                                         ||TO_CHAR(l_trunc_le_sched_comp_date);
      l_api_message := l_api_message||' Prd Set Name: '
                                         ||l_period_set_name;
      l_api_message := l_api_message||' Prd Name: '
                                         ||l_period_name;
      FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
      FND_MSG_PUB.add;

    END IF;


    open c_acct(p_wip_entity_id);
    fetch c_acct into
         l_material_account,
         l_material_overhead_account,
         l_resource_account,
         l_osp_account,
         l_overhead_account,
         l_wip_acct_class;
    close c_acct;


    -------------------------------------------------------------------------
    -- Compute Resource Costs (WOR)
    -------------------------------------------------------------------------

    l_stmt_num := 55;

    FOR c_wor_rec IN c_wor LOOP


      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_wor_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ';
        l_api_message :=l_api_message||TO_CHAR(c_wor_rec.department_id);
        l_api_message :=l_api_message||' Resource Type: ';
        l_api_message :=l_api_message||TO_CHAR(c_wor_rec.resource_type);
        l_api_message :=l_api_message||' WOR,Value: '||TO_CHAR(c_wor_rec.resource_value);

        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 60;

      Get_MaintCostCat(
         p_txn_mode         => 2 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_wor_rec.operation_seq_num,
         p_resource_id      => c_wor_rec.resource_id,
         p_res_seq_num      => c_wor_rec.resource_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

      l_stmt_num := 65;

      l_eam_cost_element :=
                   Get_eamCostElement(p_txn_mode    => 2,
                                      p_org_id      => l_organization_id,
                                      p_resource_id => c_wor_rec.resource_id);

      IF l_eam_cost_element = 0 THEN

         l_api_message := 'Get_eamCostElement returned error';
         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

      END IF;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 70;

      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => l_operation_dept_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_wor_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_wor_rec.resource_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;


      IF c_wor_rec.resource_value <> 0 then

         l_stmt_num := 73;


         case(c_wor_rec.cost_element_id)
         when 3 then
                l_acct_id := l_resource_account;
         when 4 then
                l_acct_id := l_osp_account;
         else
                l_acct_id := l_resource_account;
         end case;


         IF (p_debug = 'Y') THEN
           l_api_message :=' Calling Insert_eamBalAcct... WOR... ';
           l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
           l_api_message :=l_api_message|| ' mfg_cost_element_id = ' || TO_CHAR(c_wor_rec.cost_element_id) ;
           l_api_message :=l_api_message|| ', account_id  =  ' || TO_CHAR(l_acct_id) || ',';
           l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
           l_api_message :=l_api_message|| ' Sum WOR = ' || TO_CHAR( c_wor_rec.resource_value);
           FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
          FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
           FND_MSG_PUB.add;
         END IF;

            Insert_eamBalAcct(
              p_api_version                   => 1.0,
              p_init_msg_list                 => FND_API.G_FALSE,
              p_commit                        => FND_API.G_FALSE,
              p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
              x_return_status                 => l_return_status,
              x_msg_count                     => l_msg_count,
              x_msg_data                      => l_msg_data,
              p_period_id                     => l_acct_period_id,
              p_period_set_name               => l_period_set_name,
              p_period_name                   => l_period_name,
              p_org_id                        => l_organization_id,
              p_wip_entity_id                 => p_wip_entity_id,
              p_owning_dept_id                => l_owning_dept_id,
              p_dept_id                       => l_operation_dept_id,
              p_maint_cost_cat                => l_maint_cost_category,
              p_opseq_num                     => c_wor_rec.operation_seq_num,
              p_period_start_date             => l_period_start_date,
              p_account_ccid                  => l_acct_id,
              p_value                         => c_wor_rec.resource_value,
              p_txn_type                      => l_eam_cost_element,
              p_wip_acct_class                => l_wip_acct_class,
              p_mfg_cost_element_id           => c_wor_rec.cost_element_id,
              p_user_id                       => p_user_id,
              p_request_id                    => p_request_id,
              p_prog_id                       => p_prog_id,
              p_prog_app_id                   => p_prog_app_id,
              p_login_id                      => p_login_id);

           IF l_return_status <> FND_API.g_ret_sts_success THEN

              l_api_message := 'Insert_eamBalAcct error';
              FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                         ||TO_CHAR(l_stmt_num)
                                         ||'): ', l_api_message);
              RAISE FND_API.g_exc_error;

           END IF;
        ELSE

           IF (p_debug = 'Y') THEN
            l_api_message :=' Sum WOR = ' || TO_CHAR( c_wor_rec.resource_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
           END IF;

        END IF;  -- if c_wor_rec.resource_value !=0

      -----------------------------------------------------------------------
      -- Compute Resource Based Overheads Costs (WOR)
      -----------------------------------------------------------------------

      l_stmt_num := 75;

      /* set the sum variable that calculates the total Overhead for the resource to 0*/

      l_sum_rbo := 0;

      FOR c_rbo_rec IN c_rbo(c_wor_rec.resource_id,
                             l_owning_dept_id,
                             l_organization_id,
                             c_wor_rec.usage_rate_or_amount,
                             c_wor_rec.raw_resource_value)
      LOOP

        IF (p_debug = 'Y') THEN

          l_api_message :=' Op: ';
          l_api_message :=l_api_message||TO_CHAR(c_wor_rec.operation_seq_num);
          l_api_message :=l_api_message||' RBO,Value: '||TO_CHAR(c_rbo_rec.rbo_value);
          l_api_message :=l_api_message||' MCC: ';
          l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
          l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
          FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
          FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
          FND_MSG_PUB.add;

        END IF;

        l_stmt_num := 80;

        /* sum the total resource based overheads */
        l_sum_rbo := l_sum_rbo + NVL(c_rbo_rec.rbo_value,0);

        InsertUpdate_eamPerBal(
            p_api_version                   => 1.0,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_period_id                     => l_acct_period_id,
            p_period_set_name               => l_period_set_name,
            p_period_name                   => l_period_name,
            p_org_id                        => l_organization_id,
            p_wip_entity_id                 => p_wip_entity_id,
            p_owning_dept_id                => l_owning_dept_id,
            p_dept_id                       => l_operation_dept_id,
            p_maint_cost_cat                => l_maint_cost_category,
            p_opseq_num                     => c_wor_rec.operation_seq_num,
            p_eam_cost_element              => l_eam_cost_element,
            p_asset_group_id                => l_asset_group_item_id,
            p_asset_number                  => l_asset_number,
            p_value_type                    => 2,
            p_value                         => c_rbo_rec.rbo_value,
            p_user_id                       => p_user_id,
            p_request_id                    => p_request_id,
            p_prog_id                       => p_prog_id,

            p_prog_app_id                   => p_prog_app_id,
            p_login_id                      => p_login_id);

        IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

        END IF;

      END LOOP; -- c_rbo_rec


      l_stmt_num := 83;

     /* Insert Resource based overheads only if the value is greater than 0 */
      IF ( l_sum_rbo <> 0 ) THEN

       IF (p_debug = 'Y') THEN

            l_api_message :=' Calling Insert_eamBalAcct... RBO... ';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = 5,' ;
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_overhead_account) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum RBO = ' || TO_CHAR(l_sum_rbo);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

        Insert_eamBalAcct(
         p_api_version                   => 1.0,
         p_init_msg_list                 => FND_API.G_FALSE,
         p_commit                        => FND_API.G_FALSE,
         p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
         x_return_status                 => l_return_status,
         x_msg_count                     => l_msg_count,
         x_msg_data                      => l_msg_data,
         p_period_id                     => l_acct_period_id,
         p_period_set_name               => l_period_set_name,
         p_period_name                   => l_period_name,
         p_org_id                        => l_organization_id,
         p_wip_entity_id                 => p_wip_entity_id,
         p_owning_dept_id                => l_owning_dept_id,
         p_dept_id                       => l_operation_dept_id,
         p_maint_cost_cat                => l_maint_cost_category,
         p_opseq_num                     => c_wor_rec.operation_seq_num,
         p_period_start_date             => l_period_start_date,
         p_account_ccid                  => l_overhead_account,
         p_value                         => l_sum_rbo,
         p_txn_type                      => l_eam_cost_element,
         p_wip_acct_class                => l_wip_acct_class,
         p_mfg_cost_element_id           => 5,    /* Overhead Cost Element */
         p_user_id                       => p_user_id,
         p_request_id                    => p_request_id,
         p_prog_id                       => p_prog_id,
         p_prog_app_id                   => p_prog_app_id,
         p_login_id                      => p_login_id);

         IF l_return_status <> FND_API.g_ret_sts_success THEN

           l_api_message := 'Insert_eamBalAcct error';
           FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                    ||TO_CHAR(l_stmt_num)
                                    ||'): ', l_api_message);
           RAISE FND_API.g_exc_error;

        END IF;

     ELSE
       IF (p_debug = 'Y') THEN
            l_api_message :=' Sum RBO = ' || TO_CHAR(l_sum_rbo);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;
     END IF;  -- if l_sum_rbo != 0

      /*Now ADD the value for the total resource based Overheads for this
      resource and the resource value and insert into CST_EAM_WO_ESTIMATE_DETAILS */

      l_sum_rbo := l_sum_rbo + c_wor_rec.resource_value;

      l_stmt_num := 85;

      Insert into CST_EAM_WO_ESTIMATE_DETAILS(
                     wip_entity_id,
                     organization_id,
                     operations_dept_id,
                     operations_seq_num,
                     maint_cost_category,
                     owning_dept_id,
                     estimated_cost,
                     resource_id,
                     resource_rate,
                     uom,
                     resource_usage,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date)
             VALUES(
                     p_wip_entity_id,
                     l_organization_id,
                     l_operation_dept_id,
                     c_wor_rec.operation_seq_num,
                     l_maint_cost_category,
                     l_owning_dept_id,
                     l_sum_rbo,
                     c_wor_rec.resource_id,
                     c_wor_rec.resource_rate,
                     c_wor_rec.uom,
                     c_wor_rec.resource_usage,
                     SYSDATE,
                     p_user_id,
                     SYSDATE,
                     p_user_id,
                     p_login_id,
                     p_request_id,
                     p_prog_app_id,
                     p_prog_id,
                     SYSDATE);

    END LOOP; --c_wor_rec

/*

Support For earning Department Based Overheads is not being provided in the first phase of
eAM release. Therefore commenting out the follwing code.


    -------------------------------------------------------------------------
    -- Compute Department Based Overheads Costs
    -------------------------------------------------------------------------

    l_stmt_num := 90;

    FOR c_dbo_rec IN c_dbo LOOP

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_dbo_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ';
        l_api_message :=l_api_message||TO_CHAR(c_dbo_rec.department_id);
        l_api_message :=l_api_message||' DBO,Value: '||TO_CHAR(c_dbo_rec.dbo_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 92;

      Get_MaintCostCat(
         p_txn_mode         => 2 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_dbo_rec.operation_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

      l_stmt_num := 95;

      l_eam_cost_element :=
                   Get_eamCostElement(p_txn_mode    => 2,
                                      p_org_id      => l_organization_id);

      IF l_eam_cost_element = 0 THEN

         l_api_message := 'Get_eamCostElement returned error';
         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

      END IF;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 100;

      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => l_operation_dept_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_dbo_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_dbo_rec.dbo_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'INSERTUPDATE_EAMPERBAL ERROR';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;


    --  Adding the call to Insert_eamBalAcct in case this part of the  code is
    --  de-commented later

        IF ( c_dbo_rec.dbo_value <> 0 ) THEN

       IF (p_debug = 'Y') THEN

            l_api_message :=' Calling Insert_eamBalAcct... DBO... ';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = 5,' ;
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_overhead_account) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum DBO = ' || TO_CHAR(l_sum_dbo);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

        Insert_eamBalAcct(
         p_api_version                   => 1.0,
         p_init_msg_list                 => FND_API.G_FALSE,
         p_commit                        => FND_API.G_FALSE,
         p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
         x_return_status                 => l_return_status,
         x_msg_count                     => l_msg_count,
         x_msg_data                      => l_msg_data,
         p_period_id                     => l_acct_period_id,
         p_period_set_name               => l_period_set_name,
         p_period_name                   => l_period_name,
         p_org_id                        => l_organization_id,
         p_wip_entity_id                 => p_wip_entity_id,
         p_owning_dept_id                => l_owning_dept_id,
         p_dept_id                       => l_operation_dept_id,
         p_maint_cost_cat                => l_maint_cost_category,
         p_opseq_num                     => c_dbo_rec.operation_seq_num,
         p_period_start_date             => l_period_start_date,
         p_account_ccid                  => l_overhead_account,
         p_value                         => c_dbo_rec.dbo_value,
         p_txn_type                      => l_eam_cost_element,
         p_wip_acct_class                => l_wip_acct_class,
         p_mfg_cost_element_id           => 5,    -- Overhead Cost Element
         p_user_id                       => p_user_id,
         p_request_id                    => p_request_id,
         p_prog_id                       => p_prog_id,
         p_prog_app_id                   => p_prog_app_id,
         p_login_id                      => p_login_id);

         IF l_return_status <> FND_API.g_ret_sts_success THEN

           l_api_message := 'Insert_eamBalAcct error';
           FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                    ||TO_CHAR(l_stmt_num)
                                    ||'): ', l_api_message);
           RAISE FND_API.g_exc_error;

        END IF;

     ELSE
       IF (p_debug = 'Y') THEN
            l_api_message :=' Sum DBO = ' || TO_CHAR(l_sum_dbo);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

    END LOOP; */

    -------------------------------------------------------------------------
    -- Compute Material Costs (WRO + WRODI)
    -------------------------------------------------------------------------

    l_stmt_num := 105;


    FOR c_wro_rec IN c_wro LOOP

      l_stmt_num := 110;

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_wro_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_wro_rec.department_id);
        l_api_message :=l_api_message||' WRO,Value: '||TO_CHAR(c_wro_rec.mat_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      Get_MaintCostCat(
         p_txn_mode         => 1 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_wro_rec.operation_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

       END IF;

      l_stmt_num := 115;

      l_eam_cost_element :=
                   Get_eamCostElement(p_txn_mode    => 1,
                                      p_org_id      => l_organization_id);

      IF l_eam_cost_element = 0 THEN

         l_api_message := 'Get_eamCostElement returned error';

         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

      END IF;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 120;

      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => c_wro_rec.department_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_wro_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_wro_rec.mat_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;


      l_stmt_num := 123;

      /* Enter Estimation details for all the manufacturing cost elements where cost is
         non-zero - Eam Enhancements Project R12 */

      for l_index_var in 1..5 loop

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

       IF (p_debug = 'Y' and l_exec_flag = 1) THEN
            l_api_message :=' Calling Insert_eamBalAcct... WRO... ';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = ' || TO_CHAR(l_mfg_cost_element_id) ;
            l_api_message :=l_api_message|| ', account_id  =  ' || TO_CHAR(l_account) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum WRO = ' || TO_CHAR(l_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

     If (l_exec_flag = 1) then
      Insert_eamBalAcct(
       p_api_version                   => 1.0,
       p_init_msg_list                 => FND_API.G_FALSE,
       p_commit                        => FND_API.G_FALSE,
       p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
       x_return_status                 => l_return_status,
       x_msg_count                     => l_msg_count,
       x_msg_data                      => l_msg_data,
       p_period_id                     => l_acct_period_id,
       p_period_set_name               => l_period_set_name,
       p_period_name                   => l_period_name,
       p_org_id                        => l_organization_id,
       p_wip_entity_id                 => p_wip_entity_id,
       p_owning_dept_id                => l_owning_dept_id,
       p_dept_id                       => l_operation_dept_id,
       p_maint_cost_cat                => l_maint_cost_category,
       p_opseq_num                     => c_wro_rec.operation_seq_num,
       p_period_start_date             => l_period_start_date,
       p_account_ccid                  => l_account,
       p_value                         => l_value,
       p_txn_type                      => l_eam_cost_element,
       p_wip_acct_class                => l_wip_acct_class,
       p_mfg_cost_element_id           => l_mfg_cost_element_id,
       p_user_id                       => p_user_id,
       p_request_id                    => p_request_id,
       p_prog_id                      => p_prog_id,
       p_prog_app_id                   => p_prog_app_id,
       p_login_id                      => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Insert_eamBalAcct error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                       ||TO_CHAR(l_stmt_num)
                                       ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

       END IF;

       IF (p_debug = 'Y') THEN
            l_api_message :=' Sum WRO = 0';
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;
      End If;
      End loop;  /* End For Loop for l_index_var */

      /* Now start inserting the Estimation details into CST_EAM_WO_ESTIMATE_DETAILS */
      l_stmt_num := 125;

      Insert into CST_EAM_WO_ESTIMATE_DETAILS(
                   wip_entity_id,
                   organization_id,
                   operations_dept_id,
                   operations_seq_num,
                   maint_cost_category,
                   owning_dept_id,
                   estimated_cost,
                   inventory_item_id,
                   item_cost,
                   required_quantity,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date)
            SELECT p_wip_entity_id,
                   wro.organization_id,
                   l_operation_dept_id,
                   wro.operation_seq_num,
                   l_maint_cost_category,
                   l_owning_dept_id,
                   NVL(wro.required_quantity,0) *           --     lot_size * Commented for bug 5398315
                        decode(msi.eam_item_type,
                                3,decode(wdj.issue_zero_cost_flag,'Y',0,nvl(ccicv.item_cost,0)),
                                NVL(ccicv.item_cost,0)),
                   wro.inventory_item_id,
                   decode(msi.eam_item_type,
                        3,decode(wdj.issue_zero_cost_flag,'Y',0,ccicv.item_cost),
                        ccicv.item_cost),
                   wro.required_quantity,
                   SYSDATE,
                   p_user_id,
                   SYSDATE,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_app_id,
                   p_prog_id,
                   SYSDATE
              FROM wip_requirement_operations wro,
                   cst_cg_item_costs_view ccicv,
                   wip_discrete_jobs wdj,
                   mtl_system_items_b msi
              WHERE wro.wip_entity_id = p_wip_entity_id
                   AND ccicv.inventory_item_id = wro.inventory_item_id
                   AND ccicv.organization_id = wro.organization_id
                   AND ccicv.cost_group_id = decode(l_primary_cost_method,1,1,
                                                              l_cost_group_id)
                   AND wro.wip_supply_type IN (1,4)
                   AND nvl(wro.released_quantity,-1) <> 0
                   AND wdj.wip_entity_id = wro.wip_entity_id
                   AND msi.inventory_item_id = wro.inventory_item_id
                   AND msi.organization_id = wro.organization_id
                   AND msi.stock_enabled_flag = 'Y'
                   AND wro.department_id = c_wro_rec.department_id
                   AND wro.operation_seq_num = c_wro_rec.operation_seq_num
                   AND wdj.organization_id = wro.organization_id ;/* Bug 5230287 */

              /* NOTE: joining to ccicv.cost_group_id of 1 for standard costing org.
                       for ccicv, using default cost group id for that org is not
                       needed in the case of standard costing. */

    END LOOP;

    l_stmt_num := 130;

    FOR c_wrodi_rec IN c_wrodi LOOP

      l_stmt_num := 140;

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_wrodi_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_wrodi_rec.department_id);
        l_api_message :=l_api_message||' WRO Direct Items,Value: '||TO_CHAR(c_wrodi_rec.mat_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      Get_MaintCostCat(
         p_txn_mode         => 1 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_wrodi_rec.operation_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

       END IF;

      l_stmt_num := 145;

      BEGIN
        select cceea.mnt_cost_element_id,cceea.mfg_cost_element_id
        into   l_eam_cost_element,l_mfg_cost_element_id
        from   cst_cat_ele_exp_assocs cceea
        where  cceea.category_id = c_wrodi_rec.category_id
        and    NVL(cceea.end_date, SYSDATE) + 1 > SYSDATE
        and    cceea.start_date <= sysdate;
      exception
        when no_data_found then
          l_eam_cost_element := 3;
          l_mfg_cost_element_id := 1;
      end;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 150;

       InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => c_wrodi_rec.department_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_wrodi_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_wrodi_rec.mat_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;


     IF c_wrodi_rec.mat_value <> 0 THEN
      l_stmt_num := 153;

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

      IF (p_debug = 'Y') THEN

            l_api_message :=' Calling Insert_eamBalAcct... WRODI... ';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = ' || TO_CHAR(l_mfg_cost_element_id) || ',';
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_acct_id) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum WRODI = ' || TO_CHAR(c_wrodi_rec.mat_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
      END IF;

      Insert_eamBalAcct(
       p_api_version                   => 1.0,
       p_init_msg_list                 => FND_API.G_FALSE,
       p_commit                        => FND_API.G_FALSE,
       p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
       x_return_status                 => l_return_status,
       x_msg_count                     => l_msg_count,
       x_msg_data                      => l_msg_data,
       p_period_id                     => l_acct_period_id,
       p_period_set_name               => l_period_set_name,
       p_period_name                   => l_period_name,
       p_org_id                        => l_organization_id,
       p_wip_entity_id                 => p_wip_entity_id,
       p_owning_dept_id                => l_owning_dept_id,
       p_dept_id                       => l_operation_dept_id,
       p_maint_cost_cat                => l_maint_cost_category,
       p_opseq_num                     => c_wrodi_rec.operation_seq_num,
       p_period_start_date             => l_period_start_date,
       p_account_ccid                  => l_acct_id,
       p_value                         => c_wrodi_rec.mat_value,
       p_txn_type                      => l_eam_cost_element,
       p_wip_acct_class                => l_wip_acct_class,
       p_mfg_cost_element_id           => l_mfg_cost_element_id,
       p_user_id                       => p_user_id,
       p_request_id                    => p_request_id,
       p_prog_id                       => p_prog_id,
       p_prog_app_id                   => p_prog_app_id,
       p_login_id                      => p_login_id);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

         l_api_message := 'Insert_eamBalAcct error';
         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

       END IF;

      ELSE
       IF (p_debug = 'Y') THEN
            l_api_message :=' Sum WRODI = ' || TO_CHAR(c_wrodi_rec.mat_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

      END IF;  -- if c_wrodi_rec.mat_value != 0

      /* Now start inserting the Estimation details into CST_EAM_WO_ESTIMATE_DETAILS */
      l_stmt_num := 155;

      Insert into CST_EAM_WO_ESTIMATE_DETAILS(
                   wip_entity_id,
                   organization_id,
                   operations_dept_id,
                   operations_seq_num,
                   maint_cost_category,
                   owning_dept_id,
                   estimated_cost,
                   inventory_item_id,
                   direct_item,
                   item_cost,
                   required_quantity,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date)
            SELECT p_wip_entity_id,
                   wro.organization_id,
                   l_operation_dept_id,
                   wro.operation_seq_num,
                   l_maint_cost_category,
                   l_owning_dept_id,
                   (NVL(wro.required_quantity,0) - NVL(wediv.quantity_ordered,0))
                    * NVL(wro.unit_price,0),
                   wro.inventory_item_id,
                   'Y',
                   NVL(wro.unit_price,0),
                   NVL(wro.required_quantity,0) - NVL(wediv.quantity_ordered,0),
                   SYSDATE,
                   p_user_id,
                   SYSDATE,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_app_id,
                   p_prog_id,
                   SYSDATE
              FROM wip_requirement_operations wro,
                   (SELECT
                           cedi.work_order_number,
                           cedi.organization_id,
                           cedi.task_number,
                           cedi.item_id,
                           SUM(
                             inv_convert.inv_um_convert(
                               cedi.item_id, NULL, cedi.quantity_ordered,
                               cedi.uom_code, msi.primary_uom_code, NULL, NULL
                             )
                             /* We convert to primary_uom because the required_quantity in
                                WRO is always in the primary unit of measure */
                           ) quantity_ordered
                           /* Sum is needed because there could be multiple POs/Reqs
                              for the same non-stockable item */
                    FROM   cst_eam_direct_items_temp cedi,
                           mtl_system_items_b msi
                    WHERE  cedi.item_id = msi.inventory_item_id
                    AND    cedi.organization_id = msi.organization_id
                    AND    cedi.work_order_number  = p_wip_entity_id
                    GROUP
                    BY     cedi.work_order_number,
                           cedi.organization_id,
                           cedi.task_number,
                           cedi.item_id
                   ) wediv,
                   mtl_system_items_b msi
              WHERE wro.wip_entity_id = p_wip_entity_id
              AND   wediv.work_order_number(+) = wro.wip_entity_id
              AND   wediv.item_id(+) = wro.inventory_item_id
              AND   wediv.organization_id(+) = wro.organization_id
              AND   wediv.task_number(+) = wro.operation_seq_num
              AND   wro.wip_supply_type IN (1,4)
              AND   msi.organization_id = wro.organization_id
              AND   msi.inventory_item_id = wro.inventory_item_id
              AND   msi.stock_enabled_flag = 'N'
              AND   wro.department_id = c_wrodi_rec.department_id
              AND   wro.operation_seq_num = c_wrodi_rec.operation_seq_num
              AND   wro.inventory_item_id = c_wrodi_rec.item_id
              AND   NVL(wro.required_quantity,0) > NVL(wediv.quantity_ordered,0);

    END LOOP;

    l_stmt_num := 158;
    FOR c_wedi_rec IN c_wedi LOOP

      l_stmt_num := 160;

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_wedi_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_wedi_rec.department_id);
        l_api_message :=l_api_message||' Category ID: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_wedi_rec.category_id);
        l_api_message :=l_api_message||' Direct Item Sequence ID: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_wedi_rec.direct_item_id);
        l_api_message :=l_api_message||' WRO Direct Items,Value: '||TO_CHAR(c_wedi_rec.wedi_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      Get_MaintCostCat(
         p_txn_mode         => 1 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_wedi_rec.operation_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

       IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

       END IF;

      l_stmt_num := 165;

      BEGIN
        select cceea.mnt_cost_element_id,cceea.mfg_cost_element_id
        into   l_eam_cost_element,l_mfg_cost_element_id
        from   cst_cat_ele_exp_assocs cceea
        where  cceea.category_id = c_wedi_rec.category_id
        and    NVL(cceea.end_date, SYSDATE) + 1 > SYSDATE
        and    cceea.start_date <= sysdate;
      exception
        when no_data_found then
          l_eam_cost_element := 3;
          l_mfg_cost_element_id := 1;
      end;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 170;
      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => c_wedi_rec.department_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_wedi_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_wedi_rec.wedi_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

    If c_wedi_rec.wedi_value <> 0 then
      l_stmt_num := 173;

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

      IF (p_debug = 'Y') THEN

            l_api_message :=' Calling Insert_eamBalAcct... WEDI';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = ' || TO_CHAR( l_mfg_cost_element_id);
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_acct_id) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum WEDI = ' || TO_CHAR(c_wedi_rec.wedi_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
      END IF;

      Insert_eamBalAcct(
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_FALSE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        p_period_id                     => l_acct_period_id,
        p_period_set_name               => l_period_set_name,
        p_period_name                   => l_period_name,
        p_org_id                        => l_organization_id,
        p_wip_entity_id                 => p_wip_entity_id,
        p_owning_dept_id                => l_owning_dept_id,
        p_dept_id                       => l_operation_dept_id,
        p_maint_cost_cat                => l_maint_cost_category,
        p_opseq_num                     => c_wedi_rec.operation_seq_num,
        p_period_start_date             => l_period_start_date,
        p_account_ccid                  => l_acct_id,
        p_value                         => c_wedi_rec.wedi_value,
        p_txn_type                      => l_eam_cost_element,
        p_wip_acct_class                => l_wip_acct_class,
        p_mfg_cost_element_id           => l_mfg_cost_element_id,
        p_user_id                       => p_user_id,
        p_request_id                    => p_request_id,
        p_prog_id                       => p_prog_id,
        p_prog_app_id                   => p_prog_app_id,
        p_login_id                      => p_login_id);

        IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Insert_eamBalAcct error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                    ||TO_CHAR(l_stmt_num)
                                    ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

         END IF;

      Else
       IF (p_debug = 'Y') THEN
            l_api_message :=' Sum WEDI = ' || TO_CHAR(c_wedi_rec.wedi_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
       END IF;

      End If; -- if c_wedi_rec.wedi_value !=0

      /* Now start inserting the Estimation details into CST_EAM_WO_ESTIMATE_DETAILS */
      l_stmt_num := 175;

      Insert into CST_EAM_WO_ESTIMATE_DETAILS(
                   wip_entity_id,
                   organization_id,
                   operations_dept_id,
                   operations_seq_num,
                   maint_cost_category,
                   owning_dept_id,
                   estimated_cost,
                   item_description,
                   direct_item,
                   item_cost,
                   required_quantity,
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
                   p_wip_entity_id,
                   wedi.organization_id,
                   l_operation_dept_id,
                   wedi.operation_seq_num,
                   l_maint_cost_category,
                   l_owning_dept_id,
                   DECODE(cedi.order_type_lookup_code,
                   'FIXED PRICE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1) - sum(NVL(cedi.amount_delivered,0)),
                   'RATE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1) - sum(NVL(cedi.amount_delivered,0)),
                   (NVL(wedi.required_quantity,0) -
                      SUM(
                        /* Sum is needed because there could be multiple
                           POs/Reqs for the same description item */
                        inv_convert.inv_um_convert(
                          NULL, NULL, NVL(cedi.quantity_ordered,0),
                          NVL(cedi.uom_code, wedi.uom), wedi.uom, NULL, NULL
                        )
                      )
                   ) * NVL(wedi.unit_price, 0) * NVL(cedi.currency_rate,1)),
                   wedi.description,
                   'Y',
                   DECODE(cedi.order_type_lookup_code,
                          'FIXED PRICE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1),
                          'RATE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1),
                           NVL(wedi.unit_price, 0) * NVL(cedi.currency_rate,1) ),
                   DECODE(cedi.order_type_lookup_code,
                   'FIXED PRICE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1) - sum(NVL(cedi.amount_delivered,0)),
                   'RATE',NVL(wedi.amount,0) * NVL(cedi.currency_rate,1) - sum(NVL(cedi.amount_delivered,0)),
                   NVL(wedi.required_quantity,0) -
                     SUM(
                       /* Sum is needed because there could be multiple
                          POs/Reqs for the same description item */
                       inv_convert.inv_um_convert(
                         NULL, NULL, NVL(cedi.quantity_ordered,0),
                         NVL(cedi.uom_code, wedi.uom), wedi.uom, NULL, NULL
                       )
                     )),
                   SYSDATE,
                   p_user_id,
                   SYSDATE,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_app_id,
                   p_prog_id,
                   SYSDATE
              FROM wip_eam_direct_items wedi,
                   cst_eam_direct_items_temp cedi
              WHERE wedi.wip_entity_id = p_wip_entity_id
              AND   cedi.work_order_number(+) = wedi.wip_entity_id
              AND   cedi.direct_item_sequence_id(+) = wedi.direct_item_sequence_id
              AND   cedi.organization_id(+) = wedi.organization_id
              AND   cedi.task_number(+) = wedi.operation_seq_num
/*              AND   cedi.category_id(+) = wedi.purchasing_category_id  Commented for Bug 5403190 */
              AND   wedi.department_id = c_wedi_rec.department_id
              AND   wedi.operation_seq_num = c_wedi_rec.operation_seq_num
              AND   wedi.purchasing_category_id = c_wedi_rec.category_id
              AND   wedi.direct_item_sequence_id = c_wedi_rec.direct_item_id
              GROUP
              BY    wedi.operation_seq_num,
                    wedi.organization_id,
                    NVL(wedi.required_quantity,0),
                    NVL(wedi.unit_price, 0),
                    NVL(wedi.amount,0),
                    wedi.description,
                    cedi.order_type_lookup_code,
                    cedi.currency_rate
              HAVING
                   DECODE(cedi.order_type_lookup_code,
                    'FIXED PRICE',NVL(wedi.amount,0) - sum(NVL(cedi.amount_delivered,0)),
                    'RATE',NVL(wedi.amount,0) - sum(NVL(cedi.amount_delivered,0)),
                    NVL(wedi.required_quantity,0) -                       SUM(
                        inv_convert.inv_um_convert(
                          NULL, NULL, NVL(cedi.quantity_ordered,0),
                          NVL(cedi.uom_code, wedi.uom), wedi.uom, NULL, NULL
                        )
                      )) > 0;

    END LOOP;

    l_stmt_num := 178;
    FOR c_pda_rec IN c_pda LOOP

      l_stmt_num := 180;

      SELECT  department_id
      INTO    l_dept_id
      FROM    wip_operations wo
      WHERE   wo.wip_entity_id = p_wip_entity_id
      AND     wo.operation_seq_num = c_pda_rec.operation_seq_num;

      IF (p_debug = 'Y') THEN

        l_api_message :=l_api_message||' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_pda_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ';
        l_api_message :=l_api_message||TO_CHAR(l_dept_id);
        l_api_message :=l_api_message||' Category ID ';
        l_api_message :=l_api_message||TO_CHAR(c_pda_rec.category_id);
        l_api_message :=l_api_message||' Category Date ';
        l_api_message :=l_api_message||TO_CHAR(c_pda_rec.category_date);
        l_api_message :=l_api_message||' PDA,Value: '||TO_CHAR(c_pda_rec.pda_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 185;

      Get_MaintCostCat(
         p_txn_mode         => 1 ,
         p_wip_entity_id    => p_wip_entity_id,
         p_opseq_num        => c_pda_rec.operation_seq_num,
         x_return_status    => l_return_status,
         x_operation_dept   => l_operation_dept_id,
         x_owning_dept      => l_owning_dept_id,
         x_maint_cost_cat   => l_maint_cost_category);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_MaintCostCat returned error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

        l_stmt_num :=187;
        If (c_pda_rec.type_lookup_code = 'BLANKET') then
           select approved_date
           into l_approved_date
           from po_releases_all
           where po_release_id = c_pda_rec.po_release_id;
         Else
           l_approved_date := c_pda_rec.category_date;
         End if;

      l_stmt_num := 190;
      begin
        select cceea.mnt_cost_element_id, cceea.mfg_cost_element_id
        into l_eam_cost_element, l_mfg_cost_element_id
        from cst_cat_ele_exp_assocs cceea
        where cceea.category_id = c_pda_rec.category_id
          and l_approved_date >= cceea.start_date
          and l_approved_date < (nvl(cceea.end_date, sysdate) + 1);
      exception
        when no_data_found then
          l_eam_cost_element := 3;
          l_mfg_cost_element_id :=1;
      end;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 195;

      InsertUpdate_eamPerBal(
          p_api_version                   => 1.0,
          x_return_status                 => l_return_status,
          x_msg_count                     => l_msg_count,
          x_msg_data                      => l_msg_data,
          p_period_id                     => l_acct_period_id,
          p_period_set_name               => l_period_set_name,
          p_period_name                   => l_period_name,
          p_org_id                        => l_organization_id,
          p_wip_entity_id                 => p_wip_entity_id,
          p_owning_dept_id                => l_owning_dept_id,
          p_dept_id                       => l_dept_id,
          p_maint_cost_cat                => l_maint_cost_category,
          p_opseq_num                     => c_pda_rec.operation_seq_num,
          p_eam_cost_element              => l_eam_cost_element,
          p_asset_group_id                => l_asset_group_item_id,
          p_asset_number                  => l_asset_number,
          p_value_type                    => 2,
          p_value                         => c_pda_rec.pda_value,
          p_user_id                       => p_user_id,
          p_request_id                    => p_request_id,
          p_prog_id                       => p_prog_id,
          p_prog_app_id                   => p_prog_app_id,
          p_login_id                      => p_login_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'insertupdate_eamperbal error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

     If  c_pda_rec.pda_value <> 0 then
      l_stmt_num := 197;

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

      IF (p_debug = 'Y') THEN

            l_api_message :=' Calling Insert_eamBalAcct... PDA...';
            l_api_message :=l_api_message|| ' p_wip_entity_id = ' || TO_CHAR(p_wip_entity_id) || ', ';
            l_api_message :=l_api_message|| ' mfg_cost_element_id = ' || TO_CHAR(l_mfg_cost_element_id) || ',';
            l_api_message :=l_api_message|| ' account_id  =  ' || TO_CHAR(l_acct_id) || ',';
            l_api_message :=l_api_message|| ' eam_cost_element_id = '||TO_CHAR(l_eam_cost_element);
            l_api_message :=l_api_message|| ' Sum PDA = ' || TO_CHAR( c_pda_rec.pda_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
      END IF;

      Insert_eamBalAcct(
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_FALSE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        p_period_id                     => l_acct_period_id,
        p_period_set_name               => l_period_set_name,
        p_period_name                   => l_period_name,
        p_org_id                        => l_organization_id,
        p_wip_entity_id                 => p_wip_entity_id,
        p_owning_dept_id                => l_owning_dept_id,
        p_dept_id                       => l_operation_dept_id,
        p_maint_cost_cat                => l_maint_cost_category,
        p_opseq_num                     => c_pda_rec.operation_seq_num,
        p_period_start_date             => l_period_start_date,
        p_account_ccid                  => l_acct_id,
        p_value                         => c_pda_rec.pda_value,
        p_txn_type                      => l_eam_cost_element,
        p_wip_acct_class                => l_wip_acct_class,
        p_mfg_cost_element_id           => l_mfg_cost_element_id,
        p_user_id                       => p_user_id,
        p_request_id                    => p_request_id,
        p_prog_id                       => p_prog_id,
        p_prog_app_id                   => p_prog_app_id,
        p_login_id                      => p_login_id);

        IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Insert_eamBalAcct error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMCOST_PUB', 'Insert_eamBalAcct('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

        END IF;
       Else
          IF (p_debug = 'Y') THEN
            l_api_message :=' Sum PDA = ' || TO_CHAR( c_pda_rec.pda_value);
            FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
            FND_MSG_PUB.add;
           END IF;
       End If; -- if  c_pda_rec.pda_value != 0

      l_stmt_num := 200;

      /* Insert quantity as NULL for Service Line types */

      Insert into CST_EAM_WO_ESTIMATE_DETAILS(
                  wip_entity_id,
                  organization_id,
                  operations_dept_id,
                  operations_seq_num,
                  maint_cost_category,
                  owning_dept_id,
                  direct_item,
                  estimated_cost,
                  required_quantity,
                  item_cost,
                  rate,
                  requisition_header_id,
                  po_header_id,
                  requisition_line_id,
                  po_distribution_id,
                  line_location_id,
                  item_description,
                  inventory_item_id,
                  req_auth_status,
                  po_line_cancel_flag,
                  req_line_cancel_flag,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date)
           SELECT  p_wip_entity_id,
                   l_organization_id,
                   l_operation_dept_id,
                   c_pda_rec.operation_seq_num,
                   l_maint_cost_category,
                   l_owning_dept_id,
                   'Y',
                   CST_TEMP.estimated_cost,
                   CST_TEMP.required_quantity,
                   CST_TEMP.unit_price,
                   CST_TEMP.rate,
                   CST_TEMP.requisition_header_id,
                   CST_TEMP.po_header_id,
                   CST_TEMP.requisition_line_id,
                   CST_TEMP.po_distribution_id,
                   CST_TEMP.line_location_id,
                   CST_TEMP.item_description,
                   CST_TEMP.item_id,
                   CST_TEMP.req_auth_status,
                   'N', -- enforced in the view WEDIV
                   'N', -- enforced in the view WEDIV
                   SYSDATE,
                   p_user_id,
                   SYSDATE,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_app_id,
                   p_prog_id,
                   SYSDATE
           FROM    (
                    SELECT  decode(NVL(pla.order_type_lookup_code,'QUANTITY'),
                            'RATE',(
                                    (NVL(cedi.amount,0) -   NVL(pda.amount_cancelled,0))
                                    + PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                                    )
                                   * NVL(cedi.currency_rate,1),
                            'FIXED PRICE',(
                                    (NVL(cedi.amount,0) - NVL(pda.amount_cancelled,0))
                                     + PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                                    )
                                    * NVL(cedi.currency_rate,1),
                            (NVL(plla.price_override,0) *
                             (NVL(pda.quantity_ordered,0) - NVL(pda.quantity_cancelled,0))
                            + /* Tax */ PO_TAX_SV.get_tax('PO',pda.po_distribution_id)
                            )
                            * NVL(cedi.currency_rate,1))    estimated_cost,
                            decode(NVL(pla.order_type_lookup_code,'QUANTITY'),
                            'RATE',NVL(cedi.amount,0) ,
                            'FIXED PRICE',NVL(cedi.amount,0),
                             NVL(cedi.unit_price,0)) unit_price,
                            DECODE(pla.order_type_lookup_code,'RATE',NULL,'FIXED PRICE',NULL,
                                   NVL(pda.quantity_ordered,0) - NVL(pda.quantity_cancelled,0)
                                  ) required_quantity,
                            pda.rate rate,
                            cedi.po_header_id po_header_id,
                            cedi.requisition_header_id requisition_header_id,
                            cedi.requisition_line_id requisition_line_id,
                            pda.po_distribution_id po_distribution_id,
                            plla.line_location_id line_location_id,
                            pla.item_description item_description,
                            pla.item_id item_id,
                            cedi.req_authorization_status req_auth_status
                    FROM    po_distributions_all pda,
                            po_line_locations_all plla,
                            po_headers_all pha,
                            po_lines_all pla,
                            cst_eam_direct_items_temp cedi
                    WHERE   cedi.work_order_number = p_wip_entity_id
                    AND     cedi.organization_id = l_organization_id
                    AND     cedi.task_number = pda.wip_operation_seq_num
                    AND     cedi.category_id = pla.category_id
                    AND     pha.po_header_id = cedi.po_header_id
                    AND     pla.po_line_id = cedi.po_line_id
                    AND     pda.wip_entity_id = cedi.work_order_number
                    AND     pda.po_header_id = cedi.po_header_id
                    AND     pda.po_line_id = cedi.po_line_id
                    AND     pda.destination_organization_id = cedi.organization_id
                    AND     plla.line_location_id = pda.line_location_id
                    AND     pda.wip_operation_seq_num = c_pda_rec.operation_seq_num
                    AND     pla.category_id = c_pda_rec.category_id
                    AND     NVL(pha.approved_date, pha.last_update_date) = c_pda_rec.category_date
                    UNION ALL
                    SELECT
                            decode(NVL(prla.order_type_lookup_code,'QUANTITY'),
                            'RATE',NVL(cedi.amount,NVL(prla.amount,0) * NVL(cedi.currency_rate,1)),
                            'FIXED PRICE',NVL(cedi.amount, NVL(prla.amount,0)* NVL(cedi.currency_rate,1)),
                            NVL(prla.unit_price,0) * NVL(prla.quantity,0) )
                                           * NVL(cedi.currency_rate,1) estimated_cost,
                             decode(NVL(prla.order_type_lookup_code,'QUANTITY'),
                            'RATE',NVL(cedi.amount,0),
                            'FIXED PRICE',NVL(cedi.amount,0),
                             NVL(cedi.unit_price,0)) unit_price,
                            decode(NVL(prla.order_type_lookup_code,'QUANTITY'),
                                  'RATE',NULL, 'FIXED PRICE',NULL,
                                   prla.quantity) required_quantity,
                            prla.rate rate,
                            TO_NUMBER(NULL) po_header_id,
                            cedi.requisition_header_id requisition_header_id,
                            cedi.requisition_line_id requisition_line_id,
                            TO_NUMBER(NULL) po_distribution_id,
                            TO_NUMBER(NULL) line_location_id,
                            prla.item_description item_description,
                            prla.item_id item_id,
                            cedi.req_authorization_status req_auth_status
                    FROM    po_requisition_lines_all prla,
                            po_requisition_headers_all prha,
                            cst_eam_direct_items_temp cedi
                    WHERE   cedi.work_order_number = p_wip_entity_id
                    AND     cedi.organization_id = l_organization_id
                    AND     cedi.task_number = prla.wip_operation_seq_num
                    AND     cedi.category_id = prla.category_id
                    AND     cedi.po_header_id IS NULL -- to ensure that we do not double count
                    AND     prha.requisition_header_id = cedi.requisition_header_id
                    AND     prla.destination_organization_id = cedi.organization_id
                    AND     prla.wip_entity_id = cedi.work_order_number
                    AND     prla.requisition_line_id = cedi.requisition_line_id
                    AND     prla.wip_operation_seq_num = c_pda_rec.operation_seq_num
                    AND     prla.category_id = c_pda_rec.category_id
                    AND     prha.last_update_date = c_pda_rec.category_date
                    ) CST_TEMP;

    END LOOP;

    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );

 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_EamJob_PUB'
              , 'Compute_Job_Estimate : l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END Compute_Job_Estimate;


-- Start of comments
----------------------------------------------------------------------------
-- API name     : Rollup_Cost
-- Type         : Public
-- Pre-reqs     : None.
-- Function     : Rollup total cost for Asset Item
-- Parameters
-- IN           :
--                p_inventory_item_id           IN NUMBER        Required
--                      inventory_item_id in csi_item_instances
--                p_serial_number               IN VARCHAR2        Required
--                      serial_number in csi_item_instances
--                p_period_set_name             IN VARCHAR2        Required
--                      period_set_name in ORG_ACCT_PERIODS_V
--                p_beginning_period_name          IN VARCHAR2        Required
--                      starting period name for EAM cost Rollup
--                p_ending_period_name                IN VARCHAR2        Required
--                      ending period name for EAM Cost Rollup
--
-- Version      :
--
-- history      :
--     04/17/2001 Terence chan          Genesis
----------------------------------------------------------------------------
-- End of comments

PROCEDURE Rollup_Cost (
          p_api_version                        IN NUMBER,
        p_init_msg_list                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level                IN NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                        OUT NOCOPY VARCHAR2 ,
        x_msg_count                        OUT NOCOPY NUMBER ,
        x_msg_data                        OUT NOCOPY VARCHAR2 ,

        p_inventory_item_id                   IN NUMBER ,
        p_serial_number                       IN VARCHAR2 ,
        P_period_set_name                IN VARCHAR2 ,
        p_beginning_period_name         IN VARCHAR2 ,
        p_ending_period_name                 IN VARCHAR2 ,

        x_group_id                            OUT NOCOPY NUMBER )

        IS
        l_api_name         CONSTANT        VARCHAR2(30) := 'Rollup_Cost';
        l_api_version        CONSTANT        NUMBER             := 1.0;
        l_api_message                        VARCHAR2(2400);

        l_statement                        NUMBER := 0;
        l_gen_object_id                 NUMBER;
        l_count                                NUMBER := 0;
        l_period_start_date                DATE;
        l_period_end_date                DATE;

        l_maintenance_object_id         NUMBER;
        l_org_id         NUMBER;
BEGIN
        ---------------------------------------------
        --  Standard start of API savepoint
        ---------------------------------------------
        SAVEPOINT Rollup_Cost_PUB;

        ------------------------------------------------
        --  Standard call to check for API compatibility
        ------------------------------------------------
        l_statement := 10;
        IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
           RAISE fnd_api.G_exc_unexpected_error;
        END IF;

        ------------------------------------------------------------
        -- Initialize message list if p_init_msg_list is set to TRUE
        -------------------------------------------------------------
        l_statement := 20;
        IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
        END IF;

        -------------------------------------------------------------
        --  Initialize API return status to Success
        -------------------------------------------------------------
        l_statement := 30;
        x_return_status := fnd_api.g_ret_sts_success;

        ------------------------------------------------
        -- find out object_id from MTL_SERIAL_NUMBERS
        -- using inventory_item_id
        -- and serial number
        ------------------------------------------------
        l_statement := 40;
        SELECT gen_object_id, current_organization_id
        INTO l_gen_object_id, l_org_id
        FROM mtl_serial_numbers
        WHERE inventory_item_id = p_inventory_item_id
        AND serial_number         = p_serial_number;

        l_statement := 45;
        SELECT mtl_eam_asset_activities_s.nextval
        INTO x_group_id
        FROM dual;

        l_statement := 50;

        IF p_beginning_period_name IS NOT NULL THEN
           select
             y.start_date
           into
             l_period_start_date
           from gl_periods y,
                mfg_lookups x
           where
            y.adjustment_period_flag = 'N'  and
            x.lookup_type(+) = 'MTL_ACCT_PERIOD_STATUS' and
            x.enabled_flag(+) = 'Y' and
            x.lookup_code (+)= 67 and
            y.period_name = p_beginning_period_name and
            y.period_set_name = p_period_set_name;

        ELSE
                l_period_start_date := NULL;
        END IF;

        l_statement := 55;

        IF p_ending_period_name IS NOT NULL THEN
          select
           y.end_date
          into
           l_period_end_date
          from gl_periods y,
               mfg_lookups x
          where
           y.adjustment_period_flag = 'N' and
           x.lookup_type(+) = 'MTL_ACCT_PERIOD_STATUS' and
           x.enabled_flag(+) = 'Y' and
           x.lookup_code (+)= 67 and
           y.period_name = p_ending_period_name and
           y.period_set_name = p_period_set_name;
        ELSE
                l_period_end_date := NULL;
        END IF;

        ------------------------------------------------
        -- Take a snapshot of hierarchy structure from
        -- MTL_OBJECT_GENEALOGY
        -- and put it into CST_EAM_HIERARCHY_SNAPSHOT
        -- using l_gen_object_id and all it's child
        ------------------------------------------------
        l_statement := 60;
        INSERT INTO cst_eam_hierarchy_snapshot
        (group_id,
         object_type,
         object_id,
         parent_object_type,
         parent_object_id,
         level_num,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         last_update_login
        )
        SELECT DISTINCT
         x_group_id,
         1, -- Asset
         object_id,
         1, -- Asset
         parent_object_id,
         level,
         sysdate,
         1,
         sysdate,
         1,
         NULL,
         NULL,
         NULL
        FROM mtl_object_genealogy
        START WITH object_id = l_gen_object_id
        /* Bug 8792876 - AND sysdate between start_date_active and nvl(end_date_active, sysdate)*/
        AND (END_DATE_ACTIVE IS NULL OR  END_DATE_ACTIVE >=
                                                    NVL(l_period_start_date,END_DATE_ACTIVE)) AND
                                            (START_DATE_ACTIVE <=
                                                NVL(l_period_end_date,START_DATE_ACTIVE))
        CONNECT BY parent_object_id = PRIOR object_id
        /* Bug 8792876 - AND sysdate between start_date_active and nvl(end_date_active, sysdate);*/
        AND (END_DATE_ACTIVE IS NULL OR  END_DATE_ACTIVE >=
                                                    NVL(l_period_start_date,END_DATE_ACTIVE)) AND
                                            (START_DATE_ACTIVE <=
                                                NVL(l_period_end_date,START_DATE_ACTIVE));

        ------------------------------------------------
        -- check for single asset. If it's the case
        -- insert one row into CST_EAM_HIERARCHY_SNAPSHOT
        ------------------------------------------------
        l_statement := 65;
        SELECT count(*)
        INTO l_count
        FROM cst_eam_hierarchy_snapshot
        WHERE group_id = x_group_id;

        IF (l_count = 0) THEN

	l_statement := 70;

        /*  AMONDAL's fix, updated by DLE    */
        INSERT INTO cst_eam_hierarchy_snapshot
        (group_id,
         object_type,
         object_id,
         parent_object_type,
         parent_object_id,
         level_num,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         last_update_login
        )
        SELECT DISTINCT
         x_group_id,
         1, -- Asset
         object_id,
         1, -- Asset
         parent_object_id,
         level,
         sysdate,
         1,
         sysdate,
         1,
         NULL,
         NULL,
         NULL
        FROM mtl_object_genealogy
        START WITH parent_object_id = l_gen_object_id
        /* Bug 8792876 - AND sysdate between start_date_active and nvl(end_date_active, sysdate)*/
        AND (END_DATE_ACTIVE IS NULL OR  END_DATE_ACTIVE >=
                                                    NVL(l_period_start_date,END_DATE_ACTIVE)) AND
                                            (START_DATE_ACTIVE <=
                                                NVL(l_period_end_date,START_DATE_ACTIVE))
        CONNECT BY parent_object_id = PRIOR object_id
        /* Bug 8792876 - AND sysdate between start_date_active and nvl(end_date_active, sysdate);*/
        AND (END_DATE_ACTIVE IS NULL OR  END_DATE_ACTIVE >=
                                                    NVL(l_period_start_date,END_DATE_ACTIVE)) AND
                                            (START_DATE_ACTIVE <=
                                                NVL(l_period_end_date,START_DATE_ACTIVE));

        /*  end of AMONDAL's fix   */
	l_statement := 75;

        INSERT INTO cst_eam_hierarchy_snapshot
        (group_id,
         object_type,
         object_id,
         parent_object_type,
         parent_object_id,
         level_num,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         last_update_login
        )
        VALUES
        (x_group_id,
         1, -- Asset
         l_gen_object_id,
         1, -- Asset
        -1,
        1,
        sysdate,
        1,
        sysdate,
        1,
        NULL,
        NULL,
        NULL );
        END IF;

        ------------------------------------------------
        -- Roll Up the Cost of Asset Item and all it's child
        -- By ACCT_PERIOD_ID
        -- and MAINT_COST_ELEMENT
        -- and ORGANIZATION_ID
        ------------------------------------------------
        /* Bug 8792876 - l_statement := 60;

        IF p_beginning_period_name IS NOT NULL THEN
           select
             y.start_date
           into
             l_period_start_date
           from gl_periods y,
                mfg_lookups x
           where
            y.adjustment_period_flag = 'N'  and
            x.lookup_type(+) = 'MTL_ACCT_PERIOD_STATUS' and
            x.enabled_flag(+) = 'Y' and
            x.lookup_code (+)= 67 and
            y.period_name = p_beginning_period_name and
            y.period_set_name = p_period_set_name;

        ELSE
                l_period_start_date := NULL;
        END IF;

        l_statement := 70;

        IF p_ending_period_name IS NOT NULL THEN
          select
           y.end_date
          into
           l_period_end_date
          from gl_periods y,
               mfg_lookups x
          where
           y.adjustment_period_flag = 'N' and
           x.lookup_type(+) = 'MTL_ACCT_PERIOD_STATUS' and
           x.enabled_flag(+) = 'Y' and
           x.lookup_code (+)= 67 and
           y.period_name = p_ending_period_name and
           y.period_set_name = p_period_set_name;
        ELSE
                l_period_end_date := NULL;
        END IF; */

        -- dbms_output.put_line('p_ending_period_name :=' || p_ending_period_name);
        -- dbms_output.put_line('l_period_end_date :=' || l_period_end_date);
        -- dbms_output.put_line('p_beginning_period_name := ' || p_beginning_period_name);
        -- dbms_output.put_line('l_period_start_date := ' || l_period_start_date);

        l_statement := 80;

       /* Get the maintenance_object_id for the asset */
        select cii.instance_id
        into l_maintenance_object_id
        from csi_item_instances cii
        where cii.serial_number = p_serial_number
        and cii.inventory_item_id = p_inventory_item_id;


       /* Inserted maintenance_object_id and maintenance_object_type from CEAPB as
          part of eAM Requirements Project - R12. */

        INSERT INTO cst_eam_rollup_temp
        (group_id,
         period_set_name,
         period_name,
         inventory_item_id,
         serial_number,
         organization_id,
         acct_period_id,
         maint_cost_category,
         actual_mat_cost,
         actual_lab_cost,
         actual_eqp_cost,
         system_estimated_mat_cost,
         system_estimated_lab_cost,
         system_estimated_eqp_cost,
         manual_estimated_mat_cost,
         manual_estimated_lab_cost,
         manual_estimated_eqp_cost,
         period_start_date,
         maintenance_object_type,
         maintenance_object_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         request_id,
         program_application_id
        )
        SELECT
         x_group_id,
         p_period_set_name,
         ceapb.period_name,
         p_inventory_item_id,
         p_serial_number,
         ceapb.organization_id,
         ceapb.acct_period_id,
         ceapb.maint_cost_category,
         sum(ceapb.actual_mat_cost),
         sum(ceapb.actual_lab_cost),
         sum(ceapb.actual_eqp_cost),
         sum(ceapb.system_estimated_mat_cost),
         sum(ceapb.system_estimated_lab_cost),
         sum(ceapb.system_estimated_eqp_cost),
         sum(ceapb.manual_estimated_mat_cost),
         sum(ceapb.manual_estimated_lab_cost),
         sum(ceapb.manual_estimated_eqp_cost),
         ceapb.period_start_date,
         3,
         l_maintenance_object_id,
         sysdate,
         1,
         sysdate,
         1,
         NULL,
         NULL
        FROM cst_eam_asset_per_balances ceapb,
             mtl_serial_numbers msn,
             cst_eam_hierarchy_snapshot cehs
        WHERE ceapb.organization_id = l_org_id
        AND   ceapb.inventory_item_id = msn.inventory_item_id
        AND   ceapb.serial_number     = msn.serial_number
        AND   msn.gen_object_id       = cehs.object_id
        AND   cehs.group_id              = x_group_id
        AND   ceapb.period_set_name   = p_period_set_name
        AND   ceapb.period_start_date >= DECODE(l_period_start_date, NULL, ceapb.period_start_date, l_period_start_date)
        AND   ceapb.period_start_date <= DECODE(l_period_end_date, NULL, ceapb.period_start_date, l_period_end_date)
        GROUP BY
        ceapb.period_name,
        ceapb.organization_id,
        ceapb.acct_period_id,
        ceapb.maint_cost_category,
        ceapb.period_start_date;

        l_statement := 90;
        ---------------------------------------------------------------------------
        -- Check if there is anything inserted
        ---------------------------------------------------------------------------
        SELECT count(*) INTO l_count
        FROM cst_eam_rollup_temp
        WHERE group_id = x_group_id;

        l_statement := 100;
        ---------------------------------------------------------------------------
        -- If nothing, raise error
        ---------------------------------------------------------------------------
        IF (l_count = 0) THEN
           l_api_message := 'No row is inserted into CST_EAM_ROLLUP_TEMP';
           fnd_msg_pub.add_exc_msg
           ( G_PKG_NAME,
             l_api_name,
             l_api_message );
           RAISE fnd_api.g_exc_error;
        END IF;

        ---------------------------------------------------------------------------
        -- Standard check of p_commit
        ---------------------------------------------------------------------------
        l_statement := 110;
        IF FND_API.to_Boolean(p_commit) THEN
           COMMIT WORK;
        END IF;

        ---------------------------------------------------------------------------
        -- Standard Call to get message count and if count = 1, get message info
        ---------------------------------------------------------------------------
        l_statement := 120;
        fnd_msg_pub.count_and_get (p_count     => x_msg_count,
                                   p_data      => x_msg_data );


EXCEPTION
        WHEN fnd_api.g_exc_error then
                ROLLBACK TO Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_msg_pub.count_and_get ( p_count => x_msg_count,
                                                p_data  => x_msg_data );

        WHEN fnd_api.g_exc_unexpected_error then
                ROLLBACK TO Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_msg_pub.count_and_get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;

                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                   fnd_msg_pub.add_exc_msg
                 ( G_PKG_NAME,l_api_name || ' : Statement - ' || to_char(l_statement));
                END IF;

                fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                           p_data  => x_msg_data );

END Rollup_Cost;


-- Start of comments
----------------------------------------------------------------------------
-- API name     : Purge_Rollup_Cost
-- Type         : Public
-- Pre-reqs     : None.
-- Function     : Rollup total cost for Asset Item
-- Parameters
-- IN           :
--                p_group_id                IN VARCHAR2        Required
--                      group_id in cst_eam_hierarchy_snapshot
--                                  cst_eam_rollup_temp
--
-- Version      :
--
-- history      :
--     05/09/2001 Terence chan          Genesis
----------------------------------------------------------------------------
-- End of comments
PROCEDURE Purge_Rollup_Cost (
          p_api_version                        IN NUMBER,
        p_init_msg_list                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level                IN NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                        OUT NOCOPY VARCHAR2 ,
        x_msg_count                        OUT NOCOPY NUMBER ,
        x_msg_data                        OUT NOCOPY VARCHAR2 ,

        p_group_id                            IN NUMBER )

        IS

        l_api_name         CONSTANT        VARCHAR2(30) := 'Purge_Rollup_Cost';
        l_api_version        CONSTANT        NUMBER             := 1.0;
        l_api_message                        VARCHAR2(240);

        l_statement                        NUMBER := 0;

BEGIN
        ---------------------------------------------
        --  Standard start of API savepoint
        ---------------------------------------------
        SAVEPOINT Purge_Rollup_Cost_PUB;

        ------------------------------------------------
        --  Standard call to check for API compatibility
        ------------------------------------------------
        l_statement := 10;
        IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
           RAISE fnd_api.G_exc_unexpected_error;
        END IF;

        ------------------------------------------------------------
        -- Initialize message list if p_init_msg_list is set to TRUE
        -------------------------------------------------------------
        l_statement := 20;
        IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
        END IF;

        -------------------------------------------------------------
        --  Initialize API return status to Success
        -------------------------------------------------------------
        l_statement := 30;
        x_return_status := fnd_api.g_ret_sts_success;

        -------------------------------------------------------------
        --  Purge cst_am_hierarchy_snapshot
        -------------------------------------------------------------
        l_statement := 40;
        DELETE cst_eam_hierarchy_snapshot
        WHERE group_id= p_group_id;

        -------------------------------------------------------------
        --  Pruge cst_eam_rollup_temp
        -------------------------------------------------------------
        l_statement := 50;
        DELETE cst_eam_rollup_temp
        WHERE group_id= p_group_id;

        ---------------------------------------------------------------------------
        -- Standard check of p_commit
        ---------------------------------------------------------------------------
        l_statement := 60;
        IF FND_API.to_Boolean(p_commit) THEN
           COMMIT WORK;
        END IF;

        ---------------------------------------------------------------------------
        -- Standard Call to get message count and if count = 1, get message info
        ---------------------------------------------------------------------------
        l_statement := 70;
        fnd_msg_pub.count_and_get (p_count     => x_msg_count,
                                   p_data      => x_msg_data );


EXCEPTION

        WHEN fnd_api.g_exc_error then
                ROLLBACK TO Purge_Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_msg_pub.count_and_get ( p_count => x_msg_count,
                                                p_data  => x_msg_data );

        WHEN fnd_api.g_exc_unexpected_error then
                ROLLBACK TO Purge_Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_msg_pub.count_and_get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO Purge_Rollup_Cost_PUB;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                   fnd_msg_pub.add_exc_msg
                   ( G_PKG_NAME,l_api_name || ' : Statement - ' || to_char(l_statement));
                END IF;
                fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                           p_data  => x_msg_data );

END Purge_Rollup_Cost;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   check_if_direct_item                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   checks if this is a direct item transaction                          --
--    * Organization should be EAM enabled                                --
--    * Destination should be EAM job                                     --
--    * Item number is null or the item should not be of type OSP         --
-- PURPOSE:                                                               --
--    Called by the function process_OSP_Transaction in the receiving     --
--    transaction processor                                               --
--                                                                        --
-- HISTORY:                                                               --
--    05/01/01  Anitha Dixit    Created                                   --
----------------------------------------------------------------------------

PROCEDURE check_if_direct_item (
                p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                p_interface_txn_id              IN      NUMBER,

                x_direct_item_flag              OUT NOCOPY     NUMBER,
                x_return_status                 OUT NOCOPY     VARCHAR2,
                x_msg_count                     OUT NOCOPY     NUMBER,
                x_msg_data                      OUT NOCOPY     VARCHAR2
                ) IS

  l_api_name    CONSTANT        VARCHAR2(30) := 'check_if_direct_item';
  l_api_version CONSTANT        NUMBER              := 1.0;

  l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(8000);
  l_stmt_num            NUMBER := 0;

  l_wip_entity_id       NUMBER;
  l_entity_type         NUMBER;
  l_item_id             NUMBER;
  l_org_id              NUMBER;
  l_eam_flag            VARCHAR2(1);
  l_osp_item            VARCHAR2(1);

  l_api_message         VARCHAR2(1000);
  l_debug               VARCHAR2(80);
  l_interface_txn_id    NUMBER;

  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT check_if_direct_item_PUB;
    l_debug := fnd_profile.value('MRP_DEBUG');

    if (l_debug = 'Y') then
         FND_FILE.PUT_LINE(fnd_file.log,'Check if direct item');
    end if;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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
    l_stmt_num := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_direct_item_flag := 0;

    -- Validate IN parameters
    l_stmt_num := 20;
    IF (p_interface_txn_id IS NULL) THEN
         RAISE fnd_api.g_exc_error;
    END IF;

    -- Due to changes in Bug #1926731, p_interface_txn_id now contains the rcv_transaction_id
    -- instead of interface_transaction_id. Get the interface_transaction_id from rcv_transactions.
    l_stmt_num := 25;

    if(l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'RCV transaction ID : '||p_interface_txn_id);
    end if;

    SELECT interface_transaction_id
    INTO l_interface_txn_id
    FROM rcv_transactions
    WHERE transaction_id = p_interface_txn_id;

    IF (l_interface_txn_id IS NULL) THEN
         RAISE fnd_api.g_exc_error;
    END IF;

    if(l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'Interface Txn ID : '||l_interface_txn_id);
    end if;

    -- Obtain wip entity, organization and item ID for the receiving transaction
    l_stmt_num := 30;
    SELECT wip_entity_id,
           item_id,
           to_organization_id
      INTO l_wip_entity_id,
           l_item_id,
           l_org_id
      FROM rcv_transactions_interface
     WHERE interface_transaction_id = l_interface_txn_id;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'WE: ' || to_char(l_wip_entity_id));
        fnd_file.put_line(fnd_file.log,'item: ' || to_char(l_item_id));
        fnd_file.put_line(fnd_file.log,'to_org: ' || to_char(l_org_id));
    end if;

    -- Get EAM enabled flag for organization
    l_stmt_num := 40;
    SELECT nvl(eam_enabled_flag,'N')
      INTO l_eam_flag
      FROM mtl_parameters
     WHERE organization_id = l_org_id;

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'EAM flag: ' || l_eam_flag);
    end if;

    -- Get entity type for the job
    l_stmt_num := 50;
    SELECT nvl(entity_type,-1)
      INTO l_entity_type
      FROM wip_entities
     WHERE wip_entity_id = l_wip_entity_id;

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Entity: ' || to_char(l_entity_type));
    end if;

    -- Validate organization and entity type
    l_stmt_num := 60;
    IF ((l_eam_flag <> 'Y') OR (l_entity_type NOT IN (6,7))) THEN
        x_direct_item_flag := 0;
    ELSE
        -- Check for Item ID
        l_stmt_num := 70;
        if (l_debug = 'Y') then
             fnd_file.put_line(fnd_file.log,'EAM job!');
        end if;

        IF (l_item_id IS NULL) THEN
             x_direct_item_flag := 1;
        ELSE
             l_stmt_num := 80;
             SELECT nvl(outside_operation_flag,'N')
               INTO l_osp_item
               FROM mtl_system_items_b
              WHERE inventory_item_id = l_item_id
                AND organization_id = l_org_id;

             if (l_debug = 'Y') then
                  fnd_file.put_line(fnd_file.log,'osp flag : ' || l_osp_item);
             end if;

             IF (l_osp_item = 'N') THEN
                  x_direct_item_flag := 1;
             ELSE
                  x_direct_item_flag := 0;
             END IF; /* check if item is OSP or not */
        END IF;  /* check for NULL item_id */
    END IF; /* Organization and job are of EAM type */

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Direct item flag : ' || to_char(x_direct_item_flag));
    end if;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO check_if_direct_item_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO check_if_direct_item_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      ROLLBACK TO check_if_direct_item_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'check_if_direct_item : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END check_if_direct_item;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   process_direct_item_txn                                              --
-- DESCRIPTION                                                            --
--   This is the wrapper function to do direct item costing               --
--    * Inserts transaction into wip_cost_txn_interface                   --
-- PURPOSE:                                                               --
--    API to process direct item transaction. Called from the function    --
--    process_OSP_transaction in the receiving transaction processor      --
-- HISTORY:                                                               --
--    05/01/01          Anitha Dixit    Created                           --
----------------------------------------------------------------------------

PROCEDURE process_direct_item_txn (
                p_api_version                        IN        NUMBER,
                 p_init_msg_list                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_validation_level                IN        VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                p_directItem_rec                IN        WIP_Transaction_PUB.Res_Rec_Type,

                x_directItem_rec                IN OUT NOCOPY        WIP_Transaction_PUB.Res_Rec_Type,
                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
                ) IS

  l_api_name    CONSTANT        VARCHAR2(30) := 'process_direct_item_txn';
  l_api_version CONSTANT        NUMBER              := 1.0;

  l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(8000);
  l_stmt_num            NUMBER := 0;

  l_actual_res_rate     NUMBER;
  l_txn_id              NUMBER;
  l_project_id          NUMBER;
  l_task_id             NUMBER;
  l_op_seq_num          NUMBER;
  l_txn_type            VARCHAR2(240);
  l_wip_entity_id       NUMBER;
  l_txn_value           NUMBER;
  l_primary_qty         NUMBER;
  l_wip_acct            NUMBER := -1;
  l_dept_id             NUMBER;
  l_org_id              NUMBER;
  l_user_id             NUMBER;
  l_login_id            NUMBER;
  l_curr_rate           NUMBER;

  l_quantity            NUMBER;
  l_primary_quantity    NUMBER;

  l_item_id                    NUMBER;
  l_source_doc_unit_of_measure VARCHAR2(25);
  l_source_doc_uom_code        VARCHAR2(3);

  l_directItem_rec      WIP_Transaction_PUB.Res_Rec_Type;

  l_api_message         VARCHAR2(1000);
  l_debug               VARCHAR2(80);

  l_curr_code           VARCHAR2(16);
  l_po_txn_type         VARCHAR2(25);

  l_interface_txn_id    NUMBER;

  l_po_order_type_lookup_code VARCHAR2(20);

-- Bug 9356654 WIP Encumbrance enhancement Change
  l_encumbrance_amount         NUMBER;
  l_encumbrance_quantity       NUMBER;
  l_encumbrance_ccid           NUMBER;
  l_encumbrance_type_id        NUMBER;
  l_enc_return_status          VARCHAR2(1);
  l_enc_msg_count              NUMBER;
  l_enc_msg_data               VARCHAR2(2000);

  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT process_direct_item_txn_PUB;

    l_debug := fnd_profile.value('MRP_DEBUG');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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
    l_stmt_num := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize direct item record
    l_stmt_num := 20;
    l_directItem_rec := p_directItem_rec;

    -- Due to changes in Bug #1926731, l_directItem_rec.rcv_transaction_id now contains the rcv_transaction_id
    -- instead of interface_transaction_id. Get the interface_transaction_id from rcv_transactions.
    l_stmt_num := 25;

   l_txn_id := l_directItem_rec.rcv_transaction_id;
    if(l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'RCV transaction ID : '||l_txn_id);
    end if;

    /* Modified quantity to source_doc_quantity for bug 3253815. When the
       receipt UOM is different from the UOM on the PO, using quantity
       instead of the source_doc_quantity results in an incorrect actual_res_rate
       when it is converted to the primary_uom */
    SELECT interface_transaction_id, source_doc_quantity /*, primary_quantity*/
    INTO l_interface_txn_id, l_quantity /*, l_primary_quantity*/
    FROM rcv_transactions
   WHERE transaction_id = l_txn_id;

    IF (l_interface_txn_id IS NULL) THEN
         RAISE fnd_api.g_exc_error;
    END IF;

    -- Bug #2144236. Interface_txn_id was getting inserted into WCTI
    -- instead of rcv_transaction_id
    -- l_directItem_rec.rcv_transaction_id := l_interface_txn_id;

    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Interface txn ID : '
                             || to_char(l_interface_txn_id));
    end if;


    -- Get actual resource rate
    l_stmt_num := 30;

    /* Added a check for order_type_lookup_code to consider PO Service Line
       Types for Direct Item Delivery to Shop Floor. Changes are for eAM
       Requirements Project - R12 */

/*       SELECT  decode(pol.order_type_lookup_code,
       'RATE', rti.amount + rti.amount *
          PO_TAX_SV.get_tax('PO',pod.po_distribution_id)/pod.amount_ordered,
       'FIXED PRICE', rti.amount + rti.amount *
          PO_TAX_SV.get_tax('PO',pod.po_distribution_id)/pod.amount_ordered,
       (rti.po_unit_price +
          PO_TAX_SV.get_tax('PO',pod.po_distribution_id)/pod.quantity_ordered)),
           nvl(l_directItem_rec.currency_conversion_rate,nvl(rti.currency_conversion_rate,1)),
           rti.currency_code,
           pol.order_type_lookup_code
      into l_actual_res_rate,
           l_curr_rate,
           l_curr_code,
           l_po_order_type_lookup_code
      from po_distributions_all pod,
           rcv_transactions_interface rti,
           po_lines_all pol
     where rti.interface_transaction_id = l_interface_txn_id
     and  pod.po_distribution_id = rti.po_distribution_id
     and pol.po_header_id=pod.po_header_id
     and pol.po_line_id=pod.po_line_id; */

    -- Get rti details
    l_stmt_num := 30;

    select
	   decode(pol.order_type_lookup_code,
              'RATE',  rti.amount
			         +   rti.amount
					  *  PO_TAX_SV.get_tax('PO',pod.po_distribution_id)
					  /  pod.amount_ordered,
               'FIXED PRICE', rti.amount
			         +  rti.amount
                      *  PO_TAX_SV.get_tax('PO',pod.po_distribution_id)
					  /  pod.amount_ordered,
               (   rti.po_unit_price
                 +  PO_TAX_SV.get_tax('PO',pod.po_distribution_id)
				   /pod.quantity_ordered)),
	   nvl(l_directItem_rec.currency_conversion_rate,nvl(rti.currency_conversion_rate,nvl(pod.rate,1))),
	   --
           --rti.currency_code,
	   --
           pol.order_type_lookup_code,
           1,
           rti.last_updated_by,
           sysdate,
           l_actual_res_rate,
           rti.currency_code,
           nvl(l_directItem_rec.currency_conversion_date,rti.currency_conversion_date),
           --BUG introduced by the fix of bug#7355438
	   -- The l_directItem_rec.currency_conversion_rate value is always null
	   -- l_curr_rate
	   --
           nvl(l_directItem_rec.currency_conversion_type,rti.currency_conversion_type),
           rti.last_updated_by,
           sysdate,
           rti.last_update_login,
           rti.wip_operation_seq_num,
           rti.organization_id,
           rti.po_header_id,
           rti.po_line_id,
           2,
           1,
           sysdate,
           pod.project_id,
           rti.reason_id,
           rti.comments,
           2,
           pod.task_id,
           rti.transaction_date,
           decode(pol.order_type_lookup_code, 'RATE',NULL,
                                               'FIXED PRICE', NULL,
                                                rti.quantity),
           17,
           rti.uom_code,
           rti.wip_entity_id,
           pol.item_id,
           rti.source_doc_unit_of_measure
     into l_actual_res_rate,
          l_directItem_rec.currency_conversion_rate,
          --
	  --l_curr_code,
          --
          l_po_order_type_lookup_code,
          l_directItem_rec.basis_type,
          l_directItem_rec.created_by,
          l_directItem_rec.creation_date,
          l_directItem_rec.currency_actual_rsc_rate,
          l_directItem_rec.currency_code,
          l_directItem_rec.currency_conversion_date,
          l_directItem_rec.currency_conversion_type,
          l_directItem_rec.last_updated_by,
          l_directItem_rec.last_update_date,
          l_directItem_rec.last_update_login,
          l_directItem_rec.operation_seq_num,
          l_directItem_rec.organization_id,
          l_directItem_rec.po_header_id,
          l_directItem_rec.po_line_id,
          l_directItem_rec.process_phase,
          l_directItem_rec.process_status,
          l_directItem_rec.program_update_date,
          l_directItem_rec.project_id,
          l_directItem_rec.reason_id,
          l_directItem_rec.reference,
          l_directItem_rec.standard_rate_flag,
          l_directItem_rec.task_id,
          l_directItem_rec.transaction_date,
          l_directItem_rec.transaction_quantity,
          l_directItem_rec.transaction_type,
          l_directItem_rec.transaction_uom,
          l_directItem_rec.wip_entity_id,
          l_item_id,
          l_source_doc_unit_of_measure
     from rcv_transactions  rti,
          po_distributions_all pod,
          po_lines_all pol
   where rti.transaction_id = l_txn_id
      and rti.po_distribution_id = pod.po_distribution_id
      and pol.po_line_id = pod.po_line_id;

   l_curr_rate := l_directItem_rec.currency_conversion_rate;
   l_curr_code := l_directItem_rec.currency_code;

    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'Actual resource rate: ' || to_char(l_actual_res_rate) ||
                                     'Currency Conv rate : ' ||to_char(l_curr_rate)||
                                     'Order Type Lookup Code : ' ||to_char( l_po_order_type_lookup_code));
    end if;


----------------------------------------------------------
-- Bug 9356654 -WIP Encumbrance Enhancement Change 1 :To support Encumbrance for Direct items
-- Calling NEW Encumbrance API to get encumbrance details for a delivery transaction id
-- corresponding to Direct Item
-- This API will
----------------------------------------------------------

    l_stmt_num := 35;

    Get_Encumbrance_Data(
     p_receiving_transaction_id  => l_txn_id ,
     p_api_version                => 1.0 ,
     x_encumbrance_amount         => l_encumbrance_amount,
     x_encumbrance_quantity       => l_encumbrance_quantity,
     x_encumbrance_ccid           => l_encumbrance_ccid,
     x_encumbrance_type_id        =>l_encumbrance_type_id,
     x_return_status              =>l_enc_return_status,
     x_msg_count                  =>l_enc_msg_count,
     x_msg_data                   =>l_enc_msg_data);


	l_directItem_rec.ENCUMBRANCE_TYPE_ID  := l_encumbrance_type_id;
	l_directItem_rec.ENCUMBRANCE_AMOUNT   := l_encumbrance_amount;
	l_directItem_rec.ENCUMBRANCE_QUANTITY := l_encumbrance_quantity;
	l_directItem_rec.ENCUMBRANCE_CCID     := l_encumbrance_ccid;

  -- End of the changes EAM Enc




    l_stmt_num := 40;

    if l_item_id is null then

-- Get UOM code for the source document's UOM

     IF ( l_po_order_type_lookup_code <> 'FIXED PRICE') THEN /*ADDED FOR BUG 7668184*/

     SELECT uom_code
     INTO   l_source_doc_uom_code
     FROM   mtl_units_of_measure
     WHERE  unit_of_measure = l_source_doc_unit_of_measure;

     l_directItem_rec.primary_uom := l_source_doc_uom_code;
     l_directItem_rec.primary_quantity := l_quantity; /* populate primary_quantity as source doc quantity */

     END IF;

    else

    SELECT msi.primary_uom_code
      INTO l_directItem_rec.primary_uom
      from mtl_system_items_b msi
     where msi.inventory_item_id = l_item_id
       and msi.organization_id = l_directItem_rec.organization_id;

    l_directItem_rec.primary_quantity := inv_convert.inv_um_convert(
          l_item_id,
          NULL,
          l_directItem_rec.transaction_quantity, -- TRX quantity
          l_directItem_rec.transaction_uom,      -- TRX UOM
          l_directItem_rec.primary_uom,          -- PRI uom
          NULL,
          NULL);

    end if;

    /* Bug 4683371 : Removed the select statement added for Bug #1795350.
       The currency conversion rate should be  multiplied by the product of Unit Price * Quantity
       to obtain the correct transaction value. As we are not using the primary quantity here,
       we can defer the actual resource rate calculation till Cost Processing.   */

    /* Bug 2595198 - adjust actual resource rate against the primary uom quantity */

   /* No need to adjust quantity in case of Service Line Types
     - eAM Requirements Project R12 */

    IF ( l_po_order_type_lookup_code <> 'RATE'
         AND  l_po_order_type_lookup_code <> 'FIXED PRICE') THEN
      l_actual_res_rate := l_actual_res_rate * (l_quantity/l_directItem_rec.primary_quantity);
    END IF;

    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'Actual resource rate: ' || to_char(l_actual_res_rate));
    end if;

    l_directItem_rec.actual_resource_rate := l_actual_res_rate * l_curr_rate;
    l_directItem_rec.usage_rate_or_amount := l_actual_res_rate * l_curr_rate;

    -- Get rti details
    -- Bug 2304290: insert uom code instead of uom into l_directItem_rec

    /* Bug 3831013 : l_directItem_rec.primary_uom must be the base uom code of the class
               to which the transaction uom belongs and not the primary_unit_of_measure
               of rti */

/*    l_stmt_num := 40;*/

    /* eAM  Requirements Project (R12) - Populate quantity as NULL for Service Line Types */
/*    select (l_actual_res_rate * l_curr_rate),
           1,
           rti.last_updated_by,
           sysdate,
           l_actual_res_rate,
           rti.currency_code,
           nvl(l_directItem_rec.currency_conversion_date,rti.currency_conversion_date),
           l_curr_rate,
           nvl(l_directItem_rec.currency_conversion_type,rti.currency_conversion_type),
           rti.last_updated_by,
           sysdate,
           rti.last_update_login,
           rti.wip_operation_seq_num,
           rti.to_organization_id,
           rti.po_header_id,
           rti.po_line_id,
           decode(l_po_order_type_lookup_code, 'RATE',NULL,
                                               'FIXED PRICE', NULL,
                                                rti.primary_quantity),
           muom.uom_code,
           2,
           1,
           sysdate,
           pod.project_id,
           rti.reason_id,
           rti.comments,
           2,
           pod.task_id,
           rti.transaction_date,
           decode(l_po_order_type_lookup_code, 'RATE',NULL,
                                               'FIXED PRICE', NULL,
                                                rti.quantity),
           17,
           rti.uom_code,
           l_actual_res_rate * l_curr_rate,
           rti.wip_entity_id
     into l_directItem_rec.actual_resource_rate,
          l_directItem_rec.basis_type,
          l_directItem_rec.created_by,
          l_directItem_rec.creation_date,
          l_directItem_rec.currency_actual_rsc_rate,
          l_directItem_rec.currency_code,
          l_directItem_rec.currency_conversion_date,
          l_directItem_rec.currency_conversion_rate,
          l_directItem_rec.currency_conversion_type,
          l_directItem_rec.last_updated_by,
          l_directItem_rec.last_update_date,
          l_directItem_rec.last_update_login,
          l_directItem_rec.operation_seq_num,
          l_directItem_rec.organization_id,
          l_directItem_rec.po_header_id,
          l_directItem_rec.po_line_id,
          l_directItem_rec.primary_quantity,
          l_directItem_rec.primary_uom,
          l_directItem_rec.process_phase,
          l_directItem_rec.process_status,
          l_directItem_rec.program_update_date,
          l_directItem_rec.project_id,
          l_directItem_rec.reason_id,
          l_directItem_rec.reference,
          l_directItem_rec.standard_rate_flag,
          l_directItem_rec.task_id,
          l_directItem_rec.transaction_date,
          l_directItem_rec.transaction_quantity,
          l_directItem_rec.transaction_type,
          l_directItem_rec.transaction_uom,
          l_directItem_rec.usage_rate_or_amount,
          l_directItem_rec.wip_entity_id
     from rcv_transactions_interface rti,
          po_distributions_all pod,
          mtl_units_of_measure muom,
          mtl_units_of_measure puom
    where rti.interface_transaction_id = l_interface_txn_id
      and rti.po_distribution_id = pod.po_distribution_id
      and puom.unit_of_measure(+) = rti.unit_of_measure
      and muom.uom_class(+) = puom.uom_class
      and muom.base_uom_flag(+) = 'Y'
      and muom.language(+) = userenv('LANG');  */

    if (l_debug = 'Y') then
     fnd_file.put_line(fnd_file.log,'Populated direct item record for job ' || to_char(l_directItem_rec.wip_entity_id));
    end if;


    -- Obtain PO transaction type
    select transaction_type
    into l_po_txn_type
    from rcv_transactions_interface
    where interface_transaction_id = l_interface_txn_id;

    if (l_debug = 'Y') then
     fnd_file.put_line(fnd_file.log,'PO txn type is ' || l_po_txn_type);
   end if;

    -- Update sign on primary quantity
    l_stmt_num := 45;
    if ( l_po_order_type_lookup_code <> 'RATE'
         AND  l_po_order_type_lookup_code <> 'FIXED PRICE' AND
         (l_po_txn_type = 'RETURN TO RECEIVING' OR l_po_txn_type = 'RETURN TO VENDOR')) then

      l_directItem_rec.primary_quantity := -1 * abs(l_directItem_rec.primary_quantity);
      l_directItem_rec.transaction_quantity := -1 * abs(l_directItem_rec.transaction_quantity);

    end if;
    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'Primary quantity: ' || to_char(l_directItem_rec.primary_quantity));
    end if;

    -- Get WE details
    l_stmt_num := 50;
    select primary_item_id,
           wip_entity_name,
           entity_type
      into l_directItem_rec.primary_item_id,
           l_directItem_rec.wip_entity_name,
           l_directItem_rec.entity_type
      from wip_entities
     where wip_entity_id = l_directItem_rec.wip_entity_id;

     if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'Job Name : ' || l_directItem_rec.wip_entity_name);
     end if;

    -- Get Department details
    l_stmt_num := 60;
    select wo.department_id,
           bd.department_code
      into l_directItem_rec.department_id,
           l_directitem_rec.department_code
      from wip_operations wo,
           bom_departments bd
     where wo.wip_entity_id = l_directItem_rec.wip_entity_id
       and wo.operation_seq_num = l_directItem_rec.operation_seq_num
       and wo.organization_id = l_directItem_rec.organization_id
       and bd.department_id = wo.department_id;
     if (l_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Dept Code : ' || l_directitem_rec.department_code);
     end if;

    -- Default other attributes
    l_stmt_num := 70;
    select user_name
    into l_directItem_rec.created_by_name
    from fnd_user
    where user_id = l_directItem_rec.created_by;
    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'user name : ' || l_directItem_rec.created_by_name);
    end if;

    l_stmt_num := 80;
    select user_name
    into l_directItem_rec.last_updated_by_name
    from fnd_user
    where user_id = l_directItem_rec.last_updated_by;
    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'updated by ' || l_directItem_rec.last_updated_by);
    end if;

    l_stmt_num := 90;
    select organization_code
    into l_directItem_rec.organization_code
    from mtl_parameters
    where organization_id = l_directItem_rec.organization_id;
    if (l_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'organization code ' || l_directItem_rec.organization_code);
    end if;

    l_stmt_num := 100;
    if (l_directItem_rec.reason_id IS NOT NULL) then
         select reason_name
         into l_directItem_rec.reason_name
         from mtl_transaction_reasons
         where reason_id = l_directItem_rec.reason_id;
         if (l_debug = 'Y') then
           fnd_file.put_line(fnd_file.log,'reason name ' || l_directItem_rec.reason_name);
         end if;
    end if;


    -- Update out variable
    l_stmt_num := 110;
    x_directItem_rec := l_directItem_rec;

    -- Insert/Update rows in WEDI/WRO
    l_stmt_num := 120;
    WIP_EAM_RESOURCE_TRANSACTION.WIP_EAMRCVDIRECTITEM_HOOK(
      p_api_version   => 1.0,
      p_rcv_txn_id    => l_directItem_rec.rcv_transaction_id,
      p_primary_qty   => l_directItem_rec.primary_quantity,
      p_primary_uom   => l_directItem_rec.primary_uom,
      p_unit_price    => l_directItem_rec.actual_resource_rate,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data
    );

    IF l_return_status <> FND_API.g_ret_sts_success THEN
       FND_FILE.put_line(FND_FILE.log, l_msg_data);
       l_api_message := 'WIP_EAM_RESOURCE_TRANSACTION.WIP_EAMRCVDIRECTITEM_HOOK returned error';
       FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
       FND_MESSAGE.set_token('TEXT', l_api_message);
       FND_MSG_pub.add;
       RAISE FND_API.g_exc_error;
    END IF;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_direct_item_txn_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO process_direct_item_txn_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      ROLLBACK TO process_direct_item_txn_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'process_direct_item_txn : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END process_direct_item_txn;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   cost_direct_item_txn                                                 --
-- DESCRIPTION                                                            --
--   cost a transaction record from wip_cost_txn_interface                --
--    * new transaction type called Direct Shopfloor Delivery             --
--    * called by cmlctw                                                  --
--    * inserts debits and credits into wip_transaction_accounts          --
--    * update eam asset cost and asset period balances                   --
-- PURPOSE:                                                               --
--   procedure that costs a direct item transaction and does              --
--   accounting                                                           --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit            Created                   --
----------------------------------------------------------------------------
PROCEDURE cost_direct_item_txn (
                p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                p_group_id                      IN      NUMBER,
                p_prg_appl_id                   IN      NUMBER,
                p_prg_id                        IN      NUMBER,
                p_request_id                    IN      NUMBER,
                p_user_id                       IN      NUMBER,
                p_login_id                      IN      NUMBER,

                x_return_status                 OUT NOCOPY     VARCHAR2,
                x_msg_count                     OUT NOCOPY     NUMBER,
                x_msg_data                      OUT NOCOPY     VARCHAR2
                ) IS

  l_api_name    CONSTANT        VARCHAR2(30) := 'cost_direct_item_txn';
  l_api_version CONSTANT        NUMBER       := 1.0;

  l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(8000);
  l_stmt_num            NUMBER := 0;

  l_func_curr_code      NUMBER;
  l_func_mau            NUMBER;
  l_func_precision      NUMBER;
  l_txn_value           NUMBER;
  l_base_txn_value      NUMBER;
  l_wip_acct            NUMBER;
  l_acct_line_type      NUMBER;

  l_count               NUMBER := -1;
  l_api_message         VARCHAR2(1000);
  l_debug               VARCHAR2(80);
  l_cost_element        NUMBER := 1;

  l_organization_id     NUMBER;

  CURSOR direct_item_txn_cur IS
    select wcti.transaction_id,
           wcti.organization_id,
           nvl(wcti.acct_period_id,-1) acct_period_id,
           nvl(wcti.receiving_account_id,-1) rcv_acct_id,
           nvl(wcti.actual_resource_rate,0) act_res_rate,
           nvl(wcti.currency_actual_resource_rate, 0) curr_act_res_rate,
           wcti.wip_entity_id,
           wcti.operation_seq_num opseq_num,
           wcti.primary_quantity qty,
           wcti.source_code src_code,
           to_char(wcti.transaction_date,'YYYY/MM/DD HH24:MI:SS') txn_date,
           wcti.rcv_transaction_id,
           wcti.currency_code,                   /* bug 4683371 */
           wcti.currency_conversion_rate,        /* bug 4683371 */
          ----------------------------------------------------
          -- BUG#9356654 Added for WIP encumbrance enhancement
          ----------------------------------------------------
           wcti.encumbrance_type_id,
           wcti.encumbrance_amount,
           wcti.encumbrance_quantity,
           wcti.encumbrance_ccid,
           mp.encumbrance_reversal_flag
	from wip_cost_txn_interface  wcti
	,    mtl_parameters          mp
    where wcti.group_id = p_group_id
      and wcti.process_status = 2
	  and wcti.organization_id = mp.organization_id;


  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT cost_direct_item_txn_PUB;

    l_debug := fnd_profile.value('MRP_DEBUG');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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
    l_stmt_num := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num := 50;
    -- Loop through all direct item transactions
    FOR direct_item_txn_rec IN direct_item_txn_cur LOOP

          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Transaction ID ' || to_char(direct_item_txn_rec.transaction_id));
          end if;
       /* Organization_id is the same for the entire group */
       l_organization_id := direct_item_txn_rec.organization_id;

          l_stmt_num := 60;
          -- Obtain transaction value and line type

        /* Added the select statements in the IF clause  for bug 4683371. The transaction value is
            first calculated and then rounded with standard precision of the functional currency*/

          /* Removed the select statement that fetched actual resource rate in functional
             currency for IPV xrf txns as actual resource rate is correctly populated in WCTI,
             no need to convert the value. Bug 5360723 */
          if (direct_item_txn_rec.src_code = 'IPV') then
             l_txn_value := direct_item_txn_rec.curr_act_res_rate;
             l_base_txn_value := direct_item_txn_rec.act_res_rate;
             l_acct_line_type := 2;
          else

           /* As part of eAM Reuirements Project (R12) - for PO Service Line Types,
              quantity column in WCTI will have NULL value */
             if (direct_item_txn_rec.qty is NULL) then
             select decode(nvl(fc.minimum_accountable_unit,0),0,
                           round(direct_item_txn_rec.act_res_rate,fc.precision),
                           round(direct_item_txn_rec.act_res_rate/fc.minimum_accountable_unit)
                                *fc.minimum_accountable_unit) ,
                    (decode(nvl(fc.minimum_accountable_unit,0),0,
                           round(direct_item_txn_rec.act_res_rate,fc.precision),
                           round(direct_item_txn_rec.act_res_rate/fc.minimum_accountable_unit)
                                *fc.minimum_accountable_unit)) / nvl(direct_item_txn_rec.currency_conversion_rate,1)
             into l_base_txn_value,
                  l_txn_value
             from fnd_currencies fc
             where currency_code = direct_item_txn_rec.currency_code;

             else
             select decode(nvl(fc.minimum_accountable_unit,0),0,
                            round(direct_item_txn_rec.act_res_rate * direct_item_txn_rec.qty ,fc.precision),
                            round(direct_item_txn_rec.act_res_rate * direct_item_txn_rec.qty /fc.minimum_accountable_unit)
                                          *fc.minimum_accountable_unit),
                    ( decode(nvl(fc.minimum_accountable_unit,0),0,
                            round(direct_item_txn_rec.act_res_rate * direct_item_txn_rec.qty ,fc.precision),
                            round(direct_item_txn_rec.act_res_rate * direct_item_txn_rec.qty /fc.minimum_accountable_unit)
                                          *fc.minimum_accountable_unit)) / nvl(direct_item_txn_rec.currency_conversion_rate,1)
                       into l_base_txn_value,
                            l_txn_value
                       from fnd_currencies fc
             where currency_code = direct_item_txn_rec.currency_code;

             end if;
             l_acct_line_type := 5;
          end if;

          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Transaction value ' || to_char(l_txn_value));
            fnd_file.put_line(fnd_file.log,'Base Transaction value ' || to_char(l_base_txn_value));
            fnd_file.put_line(fnd_file.log,'Quantity ' || to_char(direct_item_txn_rec.qty));
          end if;

          l_stmt_num := 80;
          if (l_debug = 'Y') then
           fnd_file.put_line(fnd_file.log,'Insert RI account ' || to_char(direct_item_txn_rec.rcv_acct_id));
          end if;

          -- Insert line for receiving inspection if it's not an IPV transfer
          -- Insert line for account (adjusment account) if it's an IPV transfer
          insert_direct_item_distr (
                  p_api_version         =>        1.0,
                  p_txn_id                =>        direct_item_txn_rec.transaction_id,
                  p_ref_acct                =>        direct_item_txn_rec.rcv_acct_id,
                  p_txn_value                =>        -1 * l_txn_value,
                  p_base_txn_value      =>      -1 * l_base_txn_value,
                  p_wip_entity_id       =>        direct_item_txn_rec.wip_entity_id,
                  p_acct_line_type      =>        l_acct_line_type,
                  p_prg_appl_id         =>      p_prg_appl_id,
                  p_prg_id              =>      p_prg_id,
                  p_request_id          =>      p_request_id,
                  p_user_id             =>      p_user_id,
                  p_login_id            =>      p_login_id,
                  x_return_status        =>        x_return_status,
                  x_msg_count                =>        x_msg_count,
                  x_msg_data                =>        x_msg_data
                  ,p_enc_insert_flag        =>  direct_item_txn_rec.encumbrance_reversal_flag
                  );

           if (x_return_status <> fnd_api.g_ret_sts_success) then
                raise fnd_api.g_exc_unexpected_error;
           end if;





	   --{ Bug 9356654 WIP Encumbrance enhancement Change 2

	   l_stmt_num := 85;
	   IF  (    direct_item_txn_rec.encumbrance_type_id  IS NOT NULL
	        AND direct_item_txn_rec.encumbrance_ccid     IS NOT NULL
	        AND NVL(direct_item_txn_rec.encumbrance_amount,0) <> 0
		)THEN



		l_acct_line_type := 15;
		insert_direct_item_distr (
                  p_api_version         =>   1.0,
                  p_txn_id              =>   direct_item_txn_rec.transaction_id,
                  p_ref_acct            =>   direct_item_txn_rec.encumbrance_ccid,
                  p_txn_value           =>   NULL, /* Will be calculated within API */
                  p_base_txn_value      =>   direct_item_txn_rec.encumbrance_amount, -- HYU Discussed we need to detect returns
                  p_wip_entity_id       =>   direct_item_txn_rec.wip_entity_id,
                  p_acct_line_type      =>   l_acct_line_type,
                  p_prg_appl_id         =>   p_prg_appl_id,
                  p_prg_id              =>   p_prg_id,
                  p_request_id          =>   p_request_id,
                  p_user_id             =>   p_user_id,
                  p_login_id            =>   p_login_id,
                  x_return_status       =>   x_return_status,
                  x_msg_count           =>   x_msg_count,
                  x_msg_data            =>   x_msg_data
                  ,p_enc_insert_flag        =>  direct_item_txn_rec.encumbrance_reversal_flag
                  );

		IF (x_return_status <> fnd_api.g_ret_sts_success) then
			raise fnd_api.g_exc_unexpected_error;
		END IF;

	   END IF;


	   --} WIP Encumbrance enhancement ends

          l_stmt_num := 90;
          -- Obtain material account for the job
          get_CostEle_for_DirectItem (
            p_api_version        =>        1.0,
            p_init_msg_list        =>        p_init_msg_list,
            p_commit                =>        p_commit,
            p_validation_level        =>        p_validation_level,
            x_return_status        =>        l_return_status,
            x_msg_count                =>        l_msg_count,
            x_msg_data                =>        l_msg_data,
            p_txn_id                =>        direct_item_txn_rec.transaction_id,
            p_mnt_or_mfg        =>        2,
            x_cost_element_id        =>        l_cost_element
            );

          if (l_return_status <> fnd_api.g_ret_sts_success) then
            FND_FILE.put_line(FND_FILE.log, x_msg_data);
            l_api_message := 'get_CostEle_for_DirectItem returned unexpected error';
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            FND_MSG_pub.add;
            raise fnd_api.g_exc_unexpected_error;
          end if;

          if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'mfg cost_element_id: '|| to_char(l_cost_element));
          end if;

          select decode(l_cost_element, 1, nvl(material_account,-1),
                                        3, nvl(resource_account, -1),
                                        4, nvl(outside_processing_account, -1), -1)
          into l_wip_acct
          from wip_discrete_jobs
          where wip_entity_id = direct_item_txn_rec.wip_entity_id;

          l_stmt_num := 100;
          -- Insert line for WIP valuation
          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Insert WIP material acct ' || to_char(l_wip_acct));
          end if;


          insert_direct_item_distr (
                  p_api_version         =>      1.0,
                  p_txn_id              =>      direct_item_txn_rec.transaction_id,
                  p_ref_acct            =>      l_wip_acct,
                  p_txn_value           =>      l_txn_value,
                  p_base_txn_value      =>      l_base_txn_value,
                  p_wip_entity_id       =>        direct_item_txn_rec.wip_entity_id,
                  p_acct_line_type      =>      7,
                  p_prg_appl_id         =>        p_prg_appl_id,
                  p_prg_id                =>        p_prg_id,
                  p_request_id                =>        p_request_id,
                  p_user_id                =>        p_user_id,
                  p_login_id                =>        p_login_id,
                  x_return_status       =>      x_return_status,
                  x_msg_count           =>      x_msg_count,
                  x_msg_data            =>      x_msg_data
                  ,p_enc_insert_flag        =>  direct_item_txn_rec.encumbrance_reversal_flag
                  );

           if (x_return_status <> fnd_api.g_ret_sts_success) then
                raise fnd_api.g_exc_unexpected_error;
           end if;


          -- Update wip period balances , pl_material_in
          l_stmt_num := 110;
          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Update wip_period_balances');
          end if;

          update_wip_period_balances (
                  p_api_version                =>        1.0,
                  p_wip_entity_id        =>        direct_item_txn_rec.wip_entity_id,
                  p_acct_period_id        =>        direct_item_txn_rec.acct_period_id,
                  p_txn_id                =>        direct_item_txn_rec.transaction_id,
                  p_prg_appl_id         =>      p_prg_appl_id,
                  p_prg_id              =>      p_prg_id,
                  p_request_id          =>      p_request_id,
                  p_user_id             =>      p_user_id,
                  p_login_id            =>      p_login_id,
                  x_return_status        =>      x_return_status,
                  x_msg_count                =>        x_msg_count,
                  x_msg_data                 =>        x_msg_data
                  );

           if (x_return_status <> fnd_api.g_ret_sts_success) then
                raise fnd_api.g_exc_unexpected_error;
           end if;

          -- update wip_eam_asset_per_balances material cost
          l_stmt_num := 120;
          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Update eamcost');
          end if;

            update_eamCost (
                p_api_version           =>      1.0,
                p_validation_level      =>      p_validation_level,
                x_return_status         =>      x_return_status,
                x_msg_count             =>      x_msg_count,
                x_msg_data              =>      x_msg_data,
                p_txn_mode              =>      4, /* Direct Item */
                p_period_id             =>      direct_item_txn_rec.acct_period_id,
                p_org_id                =>      direct_item_txn_rec.organization_id,
                p_wip_entity_id         =>      direct_item_txn_rec.wip_entity_id,
                p_opseq_num             =>      direct_item_txn_rec.opseq_num,
                p_value_type            =>      1,
             /* Bug 2924311: the following parameter should contain the base transaction value */
                p_value                 =>      l_base_txn_value,
                p_user_id               =>      p_user_id,
                p_request_id            =>      p_request_id,
                p_prog_id               =>      p_prg_id,
                p_prog_app_id           =>      p_prg_appl_id,
                p_login_id              =>      p_login_id,
                p_txn_date              =>        direct_item_txn_rec.txn_date,
                p_txn_id                =>        direct_item_txn_rec.transaction_id
                );

           if (x_return_status <> fnd_api.g_ret_sts_success) then
                raise fnd_api.g_exc_unexpected_error;
           end if;
      END LOOP; /* for transactions */

      /* insert_direct_item_txn */
      l_stmt_num := 130;
      if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'Insert direct item transaction');
      end if;
      insert_direct_item_txn (
                  p_api_version                =>        1.0,
                  p_group_id                =>        p_group_id,
                  p_prg_appl_id         =>      p_prg_appl_id,
                  p_prg_id              =>      p_prg_id,
                  p_request_id          =>      p_request_id,
                  p_user_id             =>      p_user_id,
                  p_login_id            =>      p_login_id,
                  x_return_status       =>      x_return_status,
                  x_msg_count           =>      x_msg_count,
                  x_msg_data            =>      x_msg_data
                  );

           if (x_return_status <> fnd_api.g_ret_sts_success) then
                raise fnd_api.g_exc_unexpected_error;
           end if;

    l_stmt_num := 135;
    /* Create the Events for the transactions in the WCTI group */

    CST_XLA_PVT.CreateBulk_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_wcti_group_id    => p_group_id,
      p_organization_id  => l_organization_id );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_stmt_num := 140;
    if (l_debug = 'Y') then
     fnd_file.put_line(fnd_file.log,'Delete from wcti');
    end if;
    delete from wip_cost_txn_interface
    where group_id = p_group_id
    and process_status = 2;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO cost_direct_item_txn_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO cost_direct_item_txn_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      ROLLBACK TO cost_direct_item_txn_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_file.put_line(fnd_file.log,'CST_eamCost_PUB.cost_direct_item_txn: Statement(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'cost_direct_item_txn : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END cost_direct_item_txn;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_direct_item_distr                                             --
--                                                                        --
-- DESCRIPTION                                                            --
--   insert accounting into wip_transaction_accounts                      --
--    * WIP valuation account used is material account                    --
--    * Offset against Receiving Inspection account                       --
--    * Accounting done at actuals (PO price + non recoverable tax)       --
-- PURPOSE:                                                               --
--   insert accounting into wip_transaction_accounts                      --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit            Created                   --
----------------------------------------------------------------------------

PROCEDURE insert_direct_item_distr (
                p_api_version                        IN        NUMBER,
                 p_init_msg_list                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_validation_level                IN        VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                p_txn_id                        IN         NUMBER,
                p_ref_acct                        IN        NUMBER,
                p_txn_value                        IN        NUMBER,
                p_base_txn_value                IN      NUMBER,
                p_wip_entity_id                        IN        NUMBER,
                p_acct_line_type                IN        NUMBER,
                p_prg_appl_id                   IN        NUMBER,
                p_prg_id                        IN        NUMBER,
                p_request_id                    IN        NUMBER,
                p_user_id                       IN        NUMBER,
                p_login_id                      IN        NUMBER,

                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
                  ,p_enc_insert_flag            IN       NUMBER DEFAULT 1
                ) IS

  l_api_name    CONSTANT        VARCHAR2(30) := 'insert_direct_item_distr';
  l_api_version CONSTANT        NUMBER              := 1.0;

  l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(8000);
  l_stmt_num            NUMBER := 0;

  l_currency            VARCHAR2(30);
  l_func_currency       VARCHAR2(30);
  l_org_id              NUMBER;
  l_txn_value           NUMBER;
  l_base_txn_value      NUMBER;
  l_cost_element        NUMBER; /* Direct Item Acct Enh Project */

  l_api_message         VARCHAR2(1000);
  l_debug               VARCHAR2(80);
  l_need_enc            VARCHAR2(1) := 'Y';

  l_same_currency       NUMBER := 1;  --Bug 9356654 WIP Encumbrance enhancement

  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT insert_direct_item_distr_PUB;

    l_debug := fnd_profile.value('MRP_DEBUG');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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
    l_stmt_num := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Verify account
    l_stmt_num := 20;
    if (p_ref_acct = -1) then
          RAISE fnd_api.g_exc_error;
    end if;

    -- Get transaction details
    l_stmt_num := 30;
    select organization_id, currency_code
    into l_org_id,l_currency
    from wip_cost_txn_interface
    where transaction_id = p_txn_id;

    -- DBMS_OUTPUT.PUT_LINE('Currency ' || l_currency);
    -- Get functional currency
    l_stmt_num := 40;

   /* The following select statement will be modified to refer to
      cst_organization_definitions as an impact of the HR-PROFILE option. */

    select ood.currency_code
    into l_func_currency
    from cst_organization_definitions ood
    where ood.organization_id = l_org_id;


    -- Get txn value and base txn value
    l_stmt_num := 50;

    /* Bug 9356654 Encumbrnce enhancement for direct item */
    IF p_acct_line_type = 15 THEN
        l_base_txn_value := p_base_txn_value;
	if (nvl(l_currency,l_func_currency) = l_func_currency) then
	l_txn_value := null;
	l_same_currency := 1;
	else
	 l_same_currency := 0;
	end if ;


        --BUG#9356654 Do not insert encumbrance line if encumbrance reversal flag is unchecked
        IF  p_enc_insert_flag = 2 THEN
	   l_need_enc := 'N';
           RETURN;
        END IF;

    ELSE


    if (nvl(l_currency,l_func_currency) = l_func_currency) then
         l_txn_value := null;

         l_stmt_num := 60;
         select decode(minimum_accountable_unit,null,
                        decode(precision, null, p_base_txn_value, round(p_base_txn_value,precision)),
                        0, decode(precision, null, p_base_txn_value, round(p_base_txn_value,precision)),
                        round(p_base_txn_value/minimum_accountable_unit) * minimum_accountable_unit)
         into l_base_txn_value
         from fnd_currencies
         where currency_code = l_func_currency;
    else
         l_stmt_num := 70;
         select decode(minimum_accountable_unit,null,
                        decode(precision, null, p_txn_value, round(p_txn_value,precision)),
                        0, decode(precision, null, p_txn_value, round(p_txn_value,precision)),
                        round(p_txn_value/minimum_accountable_unit) * minimum_accountable_unit)
         into l_txn_value
         from fnd_currencies
         where currency_code = l_currency;

         l_stmt_num := 90;
         select decode(minimum_accountable_unit,null,
                   decode(precision, null, p_base_txn_value, round(p_base_txn_value,precision)),
                   0, decode(precision, null, p_base_txn_value, round(p_base_txn_value,precision)),
                   round((p_base_txn_value)/minimum_accountable_unit) * minimum_accountable_unit)
         into l_base_txn_value
         from fnd_currencies
         where currency_code = l_func_currency;
    end if;

    END IF; /* p_acct_line_type = 15 */


    if (l_debug = 'Y') then
          fnd_file.put_line(fnd_file.log,'Txn value: ' || to_char(l_txn_value));
          fnd_file.put_line(fnd_file.log,'Base txn value: ' || to_char(l_base_txn_value));
    end if;


    /* Bug 9356654 WIP Encumbrance enhancement
    For Encumbrance line cost element id should be null
    */
    IF (p_acct_line_type <> 15) THEN

    l_stmt_num := 95;
    /* Direct Item Acct Enh (Patchset J) */
    get_CostEle_for_DirectItem (
      p_api_version             =>        1.0,
      p_init_msg_list           =>        p_init_msg_list,
      p_commit                  =>        p_commit,
      p_validation_level        =>        p_validation_level,
      x_return_status           =>        l_return_status,
      x_msg_count               =>        l_msg_count,
      x_msg_data                =>        l_msg_data,
      p_txn_id                  =>        p_txn_id,
      p_mnt_or_mfg              =>        2,
      x_cost_element_id         =>        l_cost_element
      );

    if (l_return_status <> fnd_api.g_ret_sts_success) then
      FND_FILE.put_line(FND_FILE.log, x_msg_data);
      l_api_message := 'get_CostEle_for_DirectItem returned unexpected error';
      FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_api_message);
      FND_MSG_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_debug = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'mfg cost_element_id: '|| to_char(l_cost_element));
    end if;

    END IF; --p_acct_line_type <> 15

    -- insert into wip_transaction_accounts
    l_stmt_num := 100;

    IF (p_acct_line_type <> 15) OR (l_need_enc = 'Y') THEN
    Insert into wip_transaction_accounts (
                        wip_sub_ledger_id,
                             transaction_id,
                        reference_account,
                         last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        organization_id,
                        transaction_date,
                        wip_entity_id,
                        accounting_line_type,
                        transaction_value,
                        base_transaction_value,
                        primary_quantity,
                        rate_or_amount,
                        basis_type,
                        cost_element_id,
                        currency_code,
                        currency_conversion_date,
                        currency_conversion_type,
                        currency_conversion_rate,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        encumbrance_type_id -- Bug 9356654 WIP Encumbrance enhancement Change 3
						)
                select        DECODE(p_acct_line_type, 15, -1,1) * CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
                        p_txn_id,
                        p_ref_acct,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_login_id,
                        wcti.organization_id,
                        wcti.transaction_date,
                        p_wip_entity_id,
                        p_acct_line_type,
--{BUG#9356654
       DECODE(p_acct_line_type,
	          15,
              DECODE(SIGN(NVL(wcti.primary_quantity,0)),0,-1,1,-1 ,-1,1 )*
              DECODE(l_same_currency,
                     0,  -- base_currency <> txn_currency
                     DECODE(fc.minimum_accountable_unit,
                            null,
                            DECODE(fc.precision, null,
                                   ROUND(l_base_txn_value/nvl(pod.rate,1),2),
                                   ROUND(l_base_txn_value/nvl(pod.rate,1),fc.precision)),
                             0,
                            DECODE(fc.precision, null,
                                   l_base_txn_value/nvl(pod.rate,1),
                                   round(l_base_txn_value/nvl(pod.rate,1),fc.precision)),
                            ROUND((l_base_txn_value/nvl(pod.rate,1))/fc.minimum_accountable_unit) * fc.minimum_accountable_unit
                            ),
				      l_txn_value
				      ),
                l_txn_value
				),      -- transaction_value
          -- l_txn_value
--}
   DECODE(p_acct_line_type,
          15,
          DECODE(SIGN(NVL(wcti.primary_quantity,0)),0,-1,1,-1 ,-1,1 )*l_base_txn_value,l_base_txn_value
          ), --base_transaction_value
   DECODE(p_acct_line_type,
          15,
          wcti.encumbrance_quantity,
          DECODE(wcti.source_code,'IPV',NULL,wcti.primary_quantity)
          ),  --primary_quantity
   DECODE(p_acct_line_type, 15,
          (l_base_txn_value/wcti.encumbrance_quantity),
          wcti.actual_resource_rate
          ), --rate_or_amount
          1,  --basis_type
   DECODE(p_acct_line_type, 15,NULL,l_cost_element),
   wcti.currency_code,
   DECODE(p_acct_line_type, 15,nvl(pod.rate_date,pod.creation_date),wcti.currency_conversion_date), -- conversion_date
   DECODE(p_acct_line_type, 15,poh.rate_type,wcti.currency_conversion_type),
   DECODE(p_acct_line_type, 15,nvl(pod.rate,1),wcti.currency_conversion_rate),
   p_request_id,
   p_prg_appl_id,
   p_prg_id,
   sysdate,
   DECODE(p_acct_line_type,15,encumbrance_type_id,NULL) --Bug 9356654 WIP Encumbrance enhancement Change 3
     FROM   wip_cost_txn_interface wcti,
			po_distributions_all pod,
			po_headers_all poh,
			rcv_transactions rt,
			fnd_currencies fc
                WHERE  wcti.transaction_id = p_txn_id
		AND	poh.po_header_id = wcti.po_header_id
		AND	poh.po_header_id = pod.po_header_id
		AND	poh.po_header_id = rt.po_header_id
		AND	rt.po_distribution_id = pod.po_distribution_id
		AND	rt.transaction_id = wcti.rcv_transaction_id
		AND     fc.currency_code = wcti.currency_code;
     END IF;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO insert_direct_item_distr_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO insert_direct_item_distr_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      ROLLBACK TO insert_direct_item_distr_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_file.put_line(fnd_file.log,'CST_eamCost_PUB.insert_direct_item_distr(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'insert_direct_item_distr : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END insert_direct_item_distr;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   update_wip_period_balances                                           --
-- DESCRIPTION                                                            --
--   This function updates the tl_material_in in wip_period_balances      --
--   for the Direct Item Shopfloor delivery transaction                   --
-- PURPOSE:                                                               --
--   Oracle Applications - Enterprise asset management                    --
--   Beta on 11i Patchset G                                               --
--   Costing Support for EAM                                              --
--                                                                        --
-- HISTORY:                                                               --
--    07/18/01                  Anitha Dixit            Created           --
----------------------------------------------------------------------------
PROCEDURE update_wip_period_balances (
                    p_api_version        IN   NUMBER,
                    p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
                    p_commit             IN   VARCHAR2 := FND_API.G_FALSE,
                    p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,

                    p_wip_entity_id      IN   NUMBER,
                    p_acct_period_id         IN   NUMBER,
                    p_txn_id                 IN   NUMBER,
                    p_prg_appl_id        IN   NUMBER,
                    p_prg_id             IN   NUMBER,
                    p_request_id         IN   NUMBER,
                    p_user_id            IN   NUMBER,
                    p_login_id           IN   NUMBER,

                    x_return_status      OUT NOCOPY  VARCHAR2,
                    x_msg_count          OUT NOCOPY  NUMBER,
                    x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

          l_api_name    CONSTANT        VARCHAR2(30) := 'update_wip_period_balances';
          l_api_version CONSTANT        NUMBER       := 1.0;

          l_api_message                 VARCHAR2(240);
          l_statement                   NUMBER := 0;
          l_txn_value                   NUMBER := 0;

          l_debug                       VARCHAR2(80);
          l_cost_element                NUMBER := 1;
          l_update_stmt                        VARCHAR2(2000) := NULL;

BEGIN
      ---------------------------------------------
      --  Standard start of API savepoint
      ---------------------------------------------
      SAVEPOINT  update_wip_period_balances_PUB;

      l_debug := fnd_profile.value('MRP_DEBUG');

      ------------------------------------------------
      --  Standard call to check for API compatibility
      ------------------------------------------------
      l_statement := 10;
      IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
            RAISE fnd_api.G_exc_unexpected_error;
      END IF;

      ------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE
      -------------------------------------------------------------
      l_statement := 20;
      IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
      end if;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_statement := 30;
      x_return_status := fnd_api.g_ret_sts_success;

      ----------------------------------------------------
      --  Validate Account Period ID
      ----------------------------------------------------
      l_statement := 40;
      if ((nvl(p_acct_period_id,-1) = -1) OR (p_txn_id IS NULL))  then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      -----------------------------------
      --   Obtain transaction value
      -----------------------------------
      l_statement := 50;
      select sum(nvl(base_transaction_value,0))
      into l_txn_value
      from wip_transaction_accounts
      where transaction_id = p_txn_id
      and accounting_line_type = 7;

      -----------------------------------------------
      --  Obtain manufacturing cost element
      -----------------------------------------------
      l_statement := 55;

      /* Direct Item Acct Enh (Patchset J) */
      get_CostEle_for_DirectItem (
        p_api_version                =>        1.0,
        p_init_msg_list                =>        p_init_msg_list,
        p_commit                =>        p_commit,
        p_validation_level        =>        p_validation_level,
        x_return_status                =>        x_return_status,
        x_msg_count                =>        x_msg_count,
        x_msg_data                =>        x_msg_data,
        p_txn_id                =>        p_txn_id,
        p_mnt_or_mfg                =>        2,
        x_cost_element_id        =>        l_cost_element
        );

      if (x_return_status <> fnd_api.g_ret_sts_success) then
        FND_FILE.put_line(FND_FILE.log, x_msg_data);
        l_api_message := 'get_CostEle_for_DirectItem returned unexpected error';
        FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
        FND_MSG_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'mfg cost_element: '|| to_char(l_cost_element));
      end if;

      /* Bug 4321505 - Modified the dynamic update query to remove literals
         in the SQL and use bind variables instead. This is to make the SQL
         comply with PL/SQL Standards */

      if l_cost_element = 1 then
       l_update_stmt := 'UPDATE wip_period_balances ' ||
        'SET pl_material_in = nvl( pl_material_in, 0) + :l_txn_value , ' ||
        'last_update_date = sysdate, ' ||
        'last_updated_by = :p_user_id, ' ||
        'last_update_login = :p_login_id, ' ||
        'request_id = :p_request_id, ' ||
        'program_application_id = :p_prg_appl_id, ' ||
        'program_id =:p_prg_id, ' ||
        'program_update_date = sysdate ' ||
        'WHERE wip_entity_id = :p_wip_entity_id ' ||
        ' AND acct_period_id = :p_acct_period_id ';

      elsif l_cost_element = 3 then
       l_update_stmt := 'UPDATE wip_period_balances ' ||
        'SET tl_resource_in = nvl( tl_resource_in, 0) + :l_txn_value , ' ||
        'last_update_date = sysdate, ' ||
        'last_updated_by = :p_user_id, ' ||
        'last_update_login = :p_login_id, ' ||
        'request_id = :p_request_id, ' ||
        'program_application_id = :p_prg_appl_id, ' ||
        'program_id =:p_prg_id, ' ||
        'program_update_date = sysdate ' ||
        'WHERE wip_entity_id = :p_wip_entity_id ' ||
        ' AND acct_period_id = :p_acct_period_id ';

      else
       l_update_stmt := 'UPDATE wip_period_balances ' ||
        'SET tl_outside_processing_in = ' ||
        'nvl( tl_outside_processing_in, 0)  + :l_txn_value , ' ||
        'last_update_date = sysdate, ' ||
        'last_updated_by = :p_user_id, ' ||
        'last_update_login = :p_login_id, ' ||
        'request_id = :p_request_id, ' ||
        'program_application_id = :p_prg_appl_id, ' ||
        'program_id =:p_prg_id, ' ||
        'program_update_date = sysdate ' ||
        'WHERE wip_entity_id = :p_wip_entity_id ' ||
        ' AND acct_period_id = :p_acct_period_id ';

      end if;

      --------------------------------------------
      --  Update wip_period_balances
      --------------------------------------
      l_statement := 60;

      EXECUTE IMMEDIATE l_update_stmt USING
        l_txn_value, p_user_id, p_login_id, p_request_id, p_prg_appl_id, p_prg_id,
        p_wip_entity_id, p_acct_period_id;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


EXCEPTION
    WHEN fnd_api.g_exc_error then
       ROLLBACK TO update_wip_period_balances_PUB;
       x_return_status := fnd_api.g_ret_sts_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN fnd_api.g_exc_unexpected_error then
       ROLLBACK TO update_wip_period_balances_PUB;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
       ROLLBACK TO update_wip_period_balances_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
           fnd_msg_pub.add_exc_msg
              ( 'CST_eamCost_PUB',' update_wip_period_balances : Statement - ' || to_char(l_statement));
      end if;

      fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  END  update_wip_period_balances;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_direct_item_txn                                               --
-- DESCRIPTION                                                            --
--   insert a transaction record into wip_transactions                    --
--    * new transaction type called Direct Shopfloor Delivery             --
--    * called by cost_direct_item_txn                                    --
-- PURPOSE:                                                               --
--   procedure that inserts a transaction into wip_transactions and       --
--   deletes the record from wip_cost_txn_interface                       --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit            Created                   --
----------------------------------------------------------------------------
PROCEDURE insert_direct_item_txn (
                p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                p_group_id                      IN        NUMBER,
                p_prg_appl_id                   IN        NUMBER,
                p_prg_id                        IN        NUMBER,
                p_request_id                        IN        NUMBER,
                p_user_id                        IN        NUMBER,
                p_login_id                        IN        NUMBER,

                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
                ) IS

  l_api_name    CONSTANT        VARCHAR2(30) := 'insert_direct_item_txn';
  l_api_version CONSTANT        NUMBER       := 1.0;

  l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(8000);
  l_stmt_num            NUMBER := 0;

  l_api_message         VARCHAR2(1000);
  l_debug               VARCHAR2(80);

  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT insert_direct_item_txn_PUB;

    l_debug := fnd_profile.value('MRP_DEBUG');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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


    -- Insert into Wip_transactions
    l_stmt_num := 20;
    if (l_debug = 'Y') then
     fnd_file.put_line(fnd_file.log,'Insert into WT');
    end if;

    /* Insert Currency_Actual_Resource_Rate also - Bug 2719622 */

    insert into wip_transactions (
                        transaction_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        organization_id,
                        wip_entity_id,
                        primary_item_id,
                        acct_period_id,
                        department_id,
                        transaction_type,
                        transaction_date,
                        line_id,
                        source_code,
                        source_line_id,
                        operation_seq_num,
                        standard_rate_flag,
                        usage_rate_or_amount,
                        basis_type,
                        transaction_quantity,
                        transaction_uom,
                        primary_quantity,
                        primary_uom,
                        actual_resource_rate,
                        currency_actual_resource_rate,
                        currency_code,
                        currency_conversion_date,
                        currency_conversion_type,
                        currency_conversion_rate,
                        reason_id,
                        reference,
                        po_header_id,
                        po_line_id,
                        rcv_transaction_id,
                        request_id,
                        program_application_id,
                        program_id,
                        pm_cost_collected,
                        project_id,
                        task_id,
                        /*Bug 9356654 Wip Encumbrance Enhancement */
                        encumbrance_type_id,
                        encumbrance_amount,
                        encumbrance_quantity,
                        encumbrance_ccid
						 )
               select   wcti.transaction_id,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_login_id,
                        wcti.organization_id,
                        wcti.wip_entity_id,
                        wcti.primary_item_id,
                        wcti.acct_period_id,
                        wcti.department_id,
                        17,
                        wcti.transaction_date,
                        wcti.line_id,
                        wcti.source_code,
                        wcti.source_line_id,
                        wcti.operation_seq_num,
                        wcti.standard_rate_flag,
                        wcti.usage_rate_or_amount,
                        wcti.basis_type,
                        decode(wcti.source_code,'IPV',NULL,wcti.transaction_quantity),
                        wcti.transaction_uom,
                        decode(wcti.source_code,'IPV',NULL,wcti.primary_quantity),
                        wcti.primary_uom,
                        wcti.actual_resource_rate,
                        wcti.currency_actual_resource_rate,
                        wcti.currency_code,
                        wcti.currency_conversion_date,
                        wcti.currency_conversion_type,
                        wcti.currency_conversion_rate,
                        wcti.reason_id,
                        wcti.reference,
                        wcti.po_header_id,
                        wcti.po_line_id,
                        wcti.rcv_transaction_id,
                        p_request_id,
                        p_prg_appl_id,
                        p_prg_id,
                        'N',
                        wcti.project_id,
                        wcti.task_id,
			/*Bug 9356654 Wip Encumbrance Enhancement */
			wcti.encumbrance_type_id,
            -- Sign logic: If delivery to SF >0
            --             If return from SF <0
            --             If correct as per sign
			DECODE(SIGN(NVL(wcti.primary_quantity,0))
			       ,0,1
			       ,1,1
                   ,-1,-1)* wcti.encumbrance_amount,  -- signed encumbrance_amount
			DECODE(SIGN(NVL(wcti.primary_quantity,0))
			       ,0,1
			       ,1,1
                   ,-1,-1)* wcti.encumbrance_quantity, -- signed encumbrance_quantity
			wcti.encumbrance_ccid
                  from  wip_cost_txn_interface wcti
                where   group_id = p_group_id
                  and   process_status = 2;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO insert_direct_item_txn_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO insert_direct_item_txn_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      ROLLBACK TO insert_direct_item_txn_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_file.put_line(fnd_file.log,'CST_eamCost_PUB.insert_direct_item_txn: Statement(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'insert_direct_item_txn : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END insert_direct_item_txn;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Direct_Item_Charge_Acct                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API determines returns the material account number
--  given a EAM job (entity  type = 6,7)                                     --
--  If the wip identity doesn't refer to an EAM job type then             --
--  -1 is returned, -1 is also returned if material account is not          --
--  defined for that particular wip entity.
--
--  This API has been moved to CST_Utility_PUB to limit dependencies for  --
--  PO.  Any changes J (11.5.10) and higher made to this API should NOT be--
--  made here, but at CST_Utiltiy_PUB.get_Direct_Item_Charge_Acct.
--
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--   Costing Support for EAM                                              --
--   Called by PO account generator
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    07/18/01                  Vinit Srivastava        Created           --
----------------------------------------------------------------------------

PROCEDURE get_Direct_Item_Charge_Acct (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                            p_wip_entity_id      IN   NUMBER := NULL,
                            x_material_acct     OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

          l_api_name    CONSTANT        VARCHAR2(30) := 'get_Direct_Item_Charge_Acct';
          l_api_version CONSTANT        NUMBER       := 1.0;

          l_api_message                 VARCHAR2(240);
          l_statement                   NUMBER := 0;
          l_material_account            NUMBER := -1;
          l_entity_type                 NUMBER;

BEGIN

      ---------------------------------------------
      --  Standard start of API savepoint
      ---------------------------------------------
      SAVEPOINT  get_Direct_Item_Charge_Acct;

      ------------------------------------------------
      --  Standard call to check for API compatibility
      ------------------------------------------------
      l_statement := 10;
      IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
            RAISE fnd_api.G_exc_unexpected_error;
      END IF;

      ------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE
      -------------------------------------------------------------
      l_statement := 20;
      IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
      end if;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_statement := 30;
      x_return_status := fnd_api.g_ret_sts_success;


      -------------------------------------------------
      --  Validate input parameters
      -------------------------------------------------
      l_statement := 40;
      if (p_wip_entity_id is null) then
            l_api_message := 'Please specify a wip entity id';
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            FND_MSG_PUB.add;

            RAISE fnd_api.g_exc_error;
      end if;

      ---------------------------------------------
      --  Verify if EAM job
      ---------------------------------------------
      l_statement := 45;
      select entity_type
      into l_entity_type
      from wip_entities
      where wip_entity_id = p_wip_entity_id;

      if (l_entity_type in (6,7)) then
      ---------------------------------------------
      --  Obtain material_account
      ---------------------------------------------
         l_statement := 50;
         select nvl(material_account,-1)
         into l_material_account
         from wip_discrete_jobs
         where wip_entity_id = p_wip_entity_id;
      end if;

        x_material_acct := l_material_account;

EXCEPTION
    WHEN fnd_api.g_exc_error then
       x_return_status := fnd_api.g_ret_sts_error;
       x_material_acct := -1;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN fnd_api.g_exc_unexpected_error then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       x_material_acct := -1;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_material_acct := -1;
      If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
           fnd_msg_pub.add_exc_msg
              ( 'CST_eamCost_PUB',' get_Direct_Item_Charge_Acct : Statement - ' || to_char(l_statement));
      end if;

      fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  END  get_Direct_Item_Charge_Acct;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  validate_for_reestimation                                             --
--                                                                        --
-- DESCRIPTION                                                            --
--  validates if the re-estimation flag on the work order value summary   --
--  form, can be updated                                                  --
--    * Calls validate_est_status_hook. If hook is used, default          --
--      validation will be overridden                                     --
--    * Default Validation :                                              --
--      If curr_est_status is Complete, flag can be checked to re-estimate -
--      If curr_est_status is Re-estimate, flag can be unchecked to complete
-- PURPOSE:                                                               --
--    called by work order value summary form                             --
--                                                                        --
-- HISTORY:                                                               --
--    08/26/01  Anitha Dixit    Created                                   --
----------------------------------------------------------------------------
PROCEDURE validate_for_reestimation (
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := fnd_api.g_false,
                p_commit                IN      VARCHAR2 := fnd_api.g_false,
                p_validation_level      IN      VARCHAR2 := fnd_api.g_valid_level_full,

                p_wip_entity_id         IN      NUMBER,
                p_job_status            IN      NUMBER,
                p_curr_est_status       IN      NUMBER,

                x_validate_flag         OUT NOCOPY     NUMBER,
                x_return_status         OUT NOCOPY     VARCHAR2,
                x_msg_count             OUT NOCOPY     NUMBER,
                x_msg_data              OUT NOCOPY     VARCHAR2
                ) IS
     l_api_name         CONSTANT        VARCHAR2(30) := 'validate_for_reestimation';
     l_api_version      CONSTANT        NUMBER       := 1.0;

     l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count        NUMBER := 0;
     l_msg_data         VARCHAR2(8000);
     l_stmt_num         NUMBER := 0;

     l_err_num          NUMBER := 0;
     l_err_code         VARCHAR2(240);
     l_err_msg          VARCHAR2(8000);

     l_validate_flag    NUMBER := 0;
     l_hook             NUMBER := 0;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT validate_for_reestimation_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
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
    l_stmt_num := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call validation hook
   l_stmt_num := 10;
   l_hook := CSTPACHK.validate_job_est_status_hook (
                i_wip_entity_id         =>      p_wip_entity_id,
                i_job_status            =>      p_job_status,
                i_curr_est_status       =>      p_curr_est_status,
                o_validate_flag         =>      l_validate_flag,
                o_err_num               =>      l_err_num,
                o_err_code              =>      l_err_code,
                o_err_msg               =>      l_err_msg );

   if (l_err_num <> 0) then
     raise fnd_api.g_exc_unexpected_error;
   end if;


   l_stmt_num := 20;
   if (l_hook = 1) then
     x_validate_flag := l_validate_flag;
     return;
   end if;

   l_stmt_num := 30;
   /* Bug 3361378 - Pending WOs can be estimated */
   if (p_curr_est_status = 1 or p_curr_est_status IS null) then
        x_validate_flag :=1;
   elsif (p_curr_est_status = 2 or p_curr_est_status = 3) then
     x_validate_flag := 0;
   elsif (p_curr_est_status = 7) then
     if (p_job_status in (1,3,4,6, 17)) then /* bug 2186082 draft WOs can be reestimated */
       x_validate_flag := 1;
     else
       x_validate_flag := 0;
     end if;
   elsif (p_curr_est_status = 8 OR p_curr_est_status = 9) then
     x_validate_flag := 1;
   else
     x_validate_flag := 0;
   end if;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO validate_for_reestimation_PUB;
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO validate_for_reestimation_PUB;
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   WHEN OTHERS THEN
      ROLLBACK TO validate_for_reestimation_PUB;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_eamCost_PUB'
              , 'validate_for_reestimation : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END validate_for_reestimation;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Redistribute_WIP_Accounts                                            --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API redistributes  accounts values from the Accounting class    --
--   of the route job to the accounting class of the memeber assets.      --
--   It does so for the variance accounts of the corresponding WACs.      --
--   This API should be called from period close(CSTPWPVR)                --
--   and job close (cmlwjv)                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--   11/26/02  Anitha         Modified to support close through SRS       --
--                            merged accounting entry creation into       --
--                            single SQL against the job close txn        --
--   09/26/02  Hemant G       Created                                     --
--   09/07/07  Veeresha Javli  Bug: 5767070 fix:  use round               --
----------------------------------------------------------------------------
PROCEDURE Redistribute_WIP_Accounts (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level   IN   VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
                            p_wcti_group_id      IN   NUMBER,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_return_status      OUT  NOCOPY VARCHAR2,
                            x_msg_count          OUT  NOCOPY NUMBER,
                            x_msg_data           OUT  NOCOPY VARCHAR2 ) IS

    l_api_name    CONSTANT       VARCHAR2(30) :='Redistribute_WIP_Accounts';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000);

    l_class_code                VARCHAR2(10);

    l_weightage_factor          NUMBER := 0;
    l_number_members            NUMBER := 0;
    l_pl_var                    NUMBER := 0;
    l_res_var                   NUMBER := 0;
    l_osp_var                   NUMBER := 0;
    l_ovh_var                   NUMBER := 0;
    l_min_acct_unit             NUMBER := 0;
    l_round_unit                NUMBER := 0;
    l_precision                 NUMBER := 0;
    l_ext_precision             NUMBER := 0;
    l_currency_code             VARCHAR2(15);

    l_pl_var_total              NUMBER := 0;
    l_res_var_total             NUMBER := 0;
    l_osp_var_total             NUMBER := 0;
    l_ovh_var_total             NUMBER := 0;

    l_mtl_var_acct              NUMBER;
    l_res_var_acct              NUMBER;
    l_osp_var_acct              NUMBER;
    l_ovh_var_acct              NUMBER;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_message               VARCHAR2(10000);
    l_stmt_num                  NUMBER;

    l_dummy                     NUMBER := 0;


  /* Changes required in the following cursor to refer to CII
     instead of MSN for network Asset Flag (eAM Requirements
      Project - R12) */

    CURSOR c_route_assets(p_wcti_group_id NUMBER) IS
     select wcti.transaction_id,
            wcti.organization_id,
            wcti.wip_entity_id,
            wcti.acct_period_id,
            to_char(wcti.transaction_date,'YYYY/MM/DD HH24:MI:SS') txn_date,
            cii.inventory_item_id,
            cii.serial_number,
            wdj.class_code,
            wdj.primary_item_id,
            wdj.project_id,
            wdj.task_id,
            wdj.maintenance_object_id
       from wip_cost_txn_interface wcti,
            wip_discrete_jobs wdj,
            wip_entities we,
            csi_item_instances cii
      where wcti.group_id = p_wcti_group_id
        and wdj.wip_entity_id = wcti.wip_entity_id
        and we.wip_entity_id = wcti.wip_entity_id
        and we.entity_type in (6,7)
        and cii.instance_id = wdj.maintenance_object_id
        and wdj.maintenance_object_type = 3
        and cii.network_asset_flag = 'Y';


  /* Changes required in following cursor as current org can view assets
     assigned to itself and to organizations that it maintains.
     Also changed to pick member assets information from
     EAM_WORK_ORDER_ROUTE table (eAM Requirements Project - R12). */

     CURSOR c_ewor (p_org_id NUMBER,
                   p_wip_entity_id NUMBER) IS
     select cii.inventory_item_id,
            cii.serial_number,
            msn.gen_object_id
     from   csi_item_instances cii,
            eam_work_order_route ewor,
            mtl_serial_numbers msn,
            wip_discrete_jobs wdj
     where wdj.organization_id = p_org_id
     and ewor.wip_entity_id = p_wip_entity_id
     and ewor.wip_entity_id = wdj.wip_entity_id
     and cii.instance_id = ewor.instance_id
     and msn.inventory_item_id = cii.inventory_item_id
     and msn.serial_number = cii.serial_number;

BEGIN

    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT Redistribute_WIP_Accounts;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables
    l_stmt_num := 10;

    SELECT DISTINCT COD.currency_code
    INTO   l_currency_code
    FROM   cst_organization_definitions COD,
           wip_cost_txn_interface WCTI
    WHERE  WCTI.group_id = p_wcti_group_id
    AND    WCTI.organization_id = COD.organization_id;

    l_stmt_num := 12;
    FND_CURRENCY.GET_INFO( l_currency_code, l_precision, l_ext_precision, l_min_acct_unit);

    if (l_min_acct_unit = 0 OR l_min_acct_unit IS NULL) then
       l_min_acct_unit := power(10, -1*l_precision);
    end if;

    -------------------------------------------------------------------------
    -- Check Entity Type is eAM and that it has a Route Asset
    -------------------------------------------------------------------------
    fnd_file.put_line(fnd_file.log,'enter-->');

    fnd_file.put_line(fnd_file.log,'p_wcti_group_id: ' || to_char(p_wcti_group_id));

    for c_route_rec in c_route_assets(p_wcti_group_id)

     LOOP
       fnd_file.put_line(fnd_file.log,'Route rec: txn:' || to_char(c_route_rec.transaction_id)
                           || ' Org:' || to_char(c_route_rec.organization_id)
                           || ' WE:' || to_char(c_route_rec.wip_entity_id)
                           || ' AcctPer: ' || to_char(c_route_rec.acct_period_id));

       l_stmt_num := 15;

       --------------------------------------------------------
       --    Initialize local variables for each wip entity ID
       --------------------------------------------------------
       l_pl_var := 0;
       l_res_var := 0;
       l_osp_var := 0;
       l_ovh_var := 0;
       l_pl_var_total := 0;
       l_res_var_total := 0;
       l_osp_var_total := 0;
       l_ovh_var_total := 0;
       l_number_members := 0;

       -----------------------------------------------------------------------
       --  Get the number of memeber assets in this network/route
       -----------------------------------------------------------------------

      /* There will be as many number of rows in EAM_WORK_ORDER_ROUTE table as
         there are asset members in the asset route at the time of Work Order
         Release. Changing reference to EWOR from MENA. (eAM Requirements
         Project - R12) */

       l_stmt_num := 20;

       select count(*)
       into l_number_members
       from EAM_WORK_ORDER_ROUTE ewor
       where ewor.wip_entity_id = c_route_rec.wip_entity_id;

       if (l_number_members > 0) then

         l_stmt_num := 25;
         l_weightage_factor := 1/l_number_members;

         l_api_message := ' Number Members: ' ||TO_CHAR(l_number_members);
         l_api_message := l_api_message || ' Weightage Factor: '||TO_CHAR(l_weightage_factor);
         FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
         FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
         FND_MSG_PUB.add;

         -------------------------------------------------------------
         --  Get variance amounts pl + moh, resource , osp, overhead
         --------------------------------------------------------------
         l_stmt_num := 30;
         select
           -1* SUM(NVL(wpb.pl_material_out,0)
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
              SUM(NVL(wpb.tl_resource_in,0)
                    - NVL(wpb.tl_resource_out,0)
                    - NVL(wpb.tl_resource_var,0)),
              SUM(NVL(wpb.tl_outside_processing_in,0)
                    - NVL(wpb.tl_outside_processing_out,0)
                    - NVL(wpb.tl_outside_processing_var,0)),
              SUM(NVL(wpb.tl_overhead_in,0)
                    - NVL(wpb.tl_overhead_out,0)
                    - NVL(wpb.tl_overhead_var,0))
            INTO l_pl_var,
                 l_res_var,
                 l_osp_var,
                 l_ovh_var
            from wip_period_balances wpb
           where wpb.wip_entity_id = c_route_rec.wip_entity_id
             and wpb.acct_period_id <= c_route_rec.acct_period_id;

           l_stmt_num := 32;

           FOR c_ewor_rec IN c_ewor(c_route_rec.organization_id,
                                    c_route_rec.wip_entity_id)
            LOOP

             l_stmt_num := 35;

             -------------------------------------------
             ---  Get wip accounting class
             -------------------------------------------
             l_stmt_num := 40;
             WIP_EAM_UTILS.DEFAULT_ACC_CLASS(
                                p_org_id          => c_route_rec.organization_id,
                                p_job_type        => 1,
                                p_serial_number   => c_ewor_rec.serial_number,
                                p_asset_group_id  => c_ewor_rec.inventory_item_id,
                                p_asset_activity_id => c_route_rec.primary_item_id,
                                p_project_id      => c_route_rec.project_id,
                                p_task_id         => c_route_rec.task_id,
                                x_class_code      => l_class_code,
                                x_return_status   => l_return_status,
                                x_msg_data        => l_msg_data
                                );

             if (l_return_status <> fnd_api.g_ret_sts_success) then
                  raise fnd_api.g_exc_unexpected_error;
             end if;


             l_stmt_num := 45;
             if (l_class_code is not null) then
                  select material_variance_account,
                         resource_variance_account,
                         outside_proc_variance_account,
                         overhead_variance_account
                    into l_mtl_var_acct,
                         l_res_var_acct,
                         l_osp_var_acct,
                         l_ovh_var_acct
                    from wip_accounting_classes
                   where class_code = l_class_code
                     and organization_id = c_route_rec.organization_id;

               ---------------------------------------------------------------------
               --  Dr. Member Route Accounts
               ---------------------------------------------------------------------

               l_stmt_num := 50;
               INSERT INTO wip_transaction_accounts
                   (TRANSACTION_ID,             REFERENCE_ACCOUNT,
                    LAST_UPDATE_DATE,           LAST_UPDATED_BY,
                    CREATION_DATE,              CREATED_BY,
                    LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
                    TRANSACTION_DATE,           WIP_ENTITY_ID,
                    ACCOUNTING_LINE_TYPE,       BASE_TRANSACTION_VALUE,
                    CONTRA_SET_ID,              COST_ELEMENT_ID,
                    REQUEST_ID,                 PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,                 PROGRAM_UPDATE_DATE)

               SELECT
                    c_route_rec.transaction_id,
                    decode(cce.cost_element_id,
                            1,l_mtl_var_acct,
                            3,l_res_var_acct,
                            4,l_osp_var_acct,
                            5,l_ovh_var_acct),
                    SYSDATE,
                    p_user_id,
                    SYSDATE,
                    p_user_id,
                    p_login_id,
                    c_route_rec.organization_id,
                    to_date(c_route_rec.txn_date,'YYYY/MM/DD HH24:MI:SS'),
                    c_route_rec.wip_entity_id,
                    8, -- accounting_line_type is WIP variance,
                    ROUND((decode(cce.cost_element_id,
                           1, l_pl_var,
                           3, l_res_var,
                           4, l_osp_var,
                           5, l_ovh_var) * l_weightage_factor)/l_min_acct_unit) * l_min_acct_unit,
                    c_ewor_rec.gen_object_id,
                    cce.cost_element_id,
                    p_request_id,
                    p_prog_app_id,
                    p_prog_id,
                    SYSDATE
               FROM cst_cost_elements cce
              WHERE cce.cost_element_id <> 2
             GROUP BY cce.cost_element_id
             HAVING decode(cce.cost_element_id,
                           1, l_pl_var,
                           3, l_res_var,
                           4, l_osp_var,
                           5, l_ovh_var) * l_weightage_factor <> 0;

               l_stmt_num := 55;
               l_pl_var_total := l_pl_var_total + (ROUND((l_pl_var * l_weightage_factor)/l_min_acct_unit) * l_min_acct_unit);
               l_res_var_total := l_res_var_total + (ROUND((l_res_var * l_weightage_factor)/l_min_acct_unit) * l_min_acct_unit);
               l_osp_var_total := l_osp_var_total + (ROUND((l_osp_var * l_weightage_factor)/l_min_acct_unit) * l_min_acct_unit);
               l_ovh_var_total := l_ovh_var_total + (ROUND((l_ovh_var * l_weightage_factor)/l_min_acct_unit) * l_min_acct_unit);
             end if;  -- check for class code

         END LOOP; -- end for member assets



         l_stmt_num := 60;
         ---------------------------------------------------------------------
         --  Cr. Route Accounts for the Balance
         ---------------------------------------------------------------------


         INSERT INTO wip_transaction_accounts
             (TRANSACTION_ID,            REFERENCE_ACCOUNT,
             LAST_UPDATE_DATE,           LAST_UPDATED_BY,
             CREATION_DATE,              CREATED_BY,
             LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
             TRANSACTION_DATE,           WIP_ENTITY_ID,
             ACCOUNTING_LINE_TYPE,
             BASE_TRANSACTION_VALUE,
             CONTRA_SET_ID,              COST_ELEMENT_ID,
             REQUEST_ID,                 PROGRAM_APPLICATION_ID,
             PROGRAM_ID,                 PROGRAM_UPDATE_DATE)
        SELECT
            c_route_rec.transaction_id,
            decode(cce.cost_element_id,
              1, wdj.material_variance_account,
              3, wdj.resource_variance_account,
              4, wdj.outside_proc_variance_account,
              5, wdj.overhead_variance_account),
            SYSDATE,
            p_user_id,
            SYSDATE,
            p_user_id,
            p_login_id,
            c_route_rec.organization_id,
            to_date(c_route_rec.txn_date,'YYYY/MM/DD HH24:MI:SS'),
            c_route_rec.wip_entity_id,
            8,
            decode(cce.cost_element_id,
                    1,l_pl_var_total,
                    3,l_res_var_total,
                    4,l_osp_var_total,
                    5,l_ovh_var_total) * -1,
            c_route_rec.maintenance_object_id,
            cce.cost_element_id, -- CE
            p_request_id,
            p_prog_app_id,
            p_prog_id,
            SYSDATE
      FROM  cst_cost_elements cce,
            wip_discrete_jobs wdj
     where  cce.cost_element_id <> 2
            and wdj.wip_entity_id = c_route_rec.wip_entity_id
    group by cce.cost_element_id,
             decode(cce.cost_element_id,
              1, wdj.material_variance_account,
              3, wdj.resource_variance_account,
              4, wdj.outside_proc_variance_account,
              5, wdj.overhead_variance_account)
    having  decode(cce.cost_element_id,
                       1,l_pl_var_total,
                       3,l_res_var_total,
                       4,l_osp_var_total,
                       5,l_ovh_var_total) <> 0;

               l_stmt_num := 65;
               UPDATE WIP_TRANSACTION_ACCOUNTS
               SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
               WHERE  TRANSACTION_ID = c_route_rec.transaction_id;


     end if; --check for member assets count

    END LOOP; --for route jobs

    l_stmt_num := 75;
    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );

 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_file.put_line(fnd_file.log,l_msg_data);

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_EamJob_PUB'
              , 'Redistribute_WIP_Accounts : l_stmt_num - '
                         ||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END Redistribute_WIP_Accounts;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  get_charge_asset                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API will be called instead of obtaining charge asset             --
--  from wdj.asset_group_id                                               --
--  It will provide support for the following                             --
--   * regular asset work orders                                          --
--   * rebuild work orders with parent asset                              --
--   * standalone rebuild work orders                                     --
--   * installed base items - future                                      --
-- PURPOSE:                                                               --
--   Oracle Applications 11i.9                                            --
--                                                                        --
-- HISTORY:                                                               --
--    03/29/05  Anjali R   Modified for eAM Requirements Project - R12.   --
--                         changes include reference to CSI_ITEM_INSTANCES--
--                         table from MTL_EAM_NETWORK_ASSETS.             --
--    11/26/02  Ray Thng   Created                                        --
----------------------------------------------------------------------------
  PROCEDURE get_charge_asset (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_wip_entity_id             IN         NUMBER,
    x_inventory_item_id         OUT NOCOPY csi_item_instances.inventory_item_id%TYPE,
    x_serial_number             OUT NOCOPY csi_item_instances.serial_number%TYPE,
    x_maintenance_object_id     OUT NOCOPY mtl_serial_numbers.gen_object_id%TYPE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2)
  IS
    l_api_name CONSTANT         VARCHAR2(30) := 'get_asset';
    l_api_version CONSTANT      NUMBER       := 1.0;
    l_stmt_num                  NUMBER       := 0;
    l_return_status             VARCHAR2(1)  := fnd_api.g_ret_sts_success;

    l_parent_wip_entity_id      wip_discrete_jobs.parent_wip_entity_id%TYPE;
    l_parent_maint_object_type  wip_discrete_jobs.maintenance_object_type%TYPE;
    l_parent_maint_object_id    wip_discrete_jobs.maintenance_object_source%TYPE;
    l_parent_network_asset_flag csi_item_instances.network_asset_flag%TYPE;
    l_parent_inventory_item_id  csi_item_instances.inventory_item_id%TYPE;
    l_parent_serial_number      csi_item_instances.serial_number%TYPE;
    l_maint_object_type         wip_discrete_jobs.maintenance_object_type%TYPE;
    l_maint_object_id           wip_discrete_jobs.maintenance_object_source%TYPE;
    l_inventory_item_id         csi_item_instances.inventory_item_id%TYPE;
    l_serial_number             csi_item_instances.serial_number%TYPE;
  BEGIN
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_stmt_num := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Retrieve information about the current work order and its parent
   /* Changed the following SQL statement to refer to CII
      instead of MSN for network Asset Flag */
    l_stmt_num := 10;
    SELECT  wdj.parent_wip_entity_id,
            pwdj.maintenance_object_type,
            pwdj.maintenance_object_id,
            pcii.network_asset_flag,
            pcii.inventory_item_id,
            pcii.serial_number,
            wdj.maintenance_object_type,
            wdj.maintenance_object_id,
            cii.inventory_item_id,
            cii.serial_number
    INTO    l_parent_wip_entity_id,
            l_parent_maint_object_type,
            l_parent_maint_object_id,
            l_parent_network_asset_flag,
            l_parent_inventory_item_id,
            l_parent_serial_number,
            l_maint_object_type,
            l_maint_object_id,
            l_inventory_item_id,
            l_serial_number
    FROM    wip_discrete_jobs wdj,
            wip_discrete_jobs pwdj,
            csi_item_instances cii,
            csi_item_instances pcii
    WHERE   wdj.wip_entity_id = p_wip_entity_id
    AND     cii.instance_id (+) = wdj.maintenance_object_id
    AND     pwdj.wip_entity_id (+) = wdj.parent_wip_entity_id
    AND     pcii.instance_id (+) = pwdj.maintenance_object_id;

   /* Also added condition below to check for Maintenance_object_type as 3
      as part of eAM Requirements project. For assets associated with
      IB instances, maintenance_object_id will store value as 3. All previous
      rows storing the value of 1 will be updated to 3 as part of the project */
    -- Set the output depending on the work order type and the network asset flag
    l_stmt_num := 20;
    -- Rebuildable Work Order with a non network asset parent

    IF l_parent_maint_object_type = 3 AND
       l_parent_network_asset_flag = 'N' THEN
      x_inventory_item_id := l_parent_inventory_item_id;
      x_serial_number := l_parent_serial_number;
      x_maintenance_object_id := l_parent_maint_object_id;
    -- Rebuildable Work Order with a network asset parent OR Asset Work Order
    ELSIF  l_maint_object_type = 3 AND
           (   l_parent_wip_entity_id IS NULL
           OR  l_parent_maint_object_type <> 3
           OR  l_parent_network_asset_flag <> 'N') THEN
      x_inventory_item_id := l_inventory_item_id;
      x_serial_number := l_serial_number;
      x_maintenance_object_id := l_maint_object_id;
    -- Other cases
    ELSE
      x_inventory_item_id := NULL;
      x_serial_number := NULL;
      x_maintenance_object_id := NULL;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    l_stmt_num := 30;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(
          'CST_eamCost_PUB',
          'get_charge_asset : Statement - '|| to_char(l_stmt_num));
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END get_charge_asset;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  get_CostEle_for_DirectItem                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API will return which cost element ID is to be charged for the
--   the direct item transactions
-- PURPOSE:                                                               --
--   Oracle Applications 11i.10                                            --
--                                                                        --
-- HISTORY:                                                               --
--    06/26/03  Linda Soo        Created                                   --
----------------------------------------------------------------------------
PROCEDURE get_CostEle_for_DirectItem (
  p_api_version                 IN         NUMBER,
  p_init_msg_list               IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN           VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN           NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_txn_id                      IN           NUMBER,
  p_mnt_or_mfg                  IN           NUMBER, -- 1: eam cost element,
                                                   -- 2: manufacturing cost ele
  p_pac_or_perp                 IN         NUMBER, -- 1 for PAC, 0 (default) for Perpetual
  x_cost_element_id             OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2)
IS
  l_api_name            CONSTANT        VARCHAR2(30) := 'get_CostElement_for_DirectItem';
  l_api_version         CONSTANT        NUMBER := 1.0;

  l_api_message                         VARCHAR2(240);
  l_statement                           NUMBER := 0;
  l_debug                   VARCHAR2(80);

  l_count                               NUMBER;
  l_po_header_id                        NUMBER;
  l_po_line_id                          NUMBER;
  l_category_id                         NUMBER;
  l_approved_date                       DATE;
  l_cost_element_id                     NUMBER;

 l_type_lookup_code                    VARCHAR2(20);
  l_po_release_id                       NUMBER;
  l_rcv_txn_id                          NUMBER;

BEGIN
  -----------------------------------
  -- Standard start of API savepoint
  -----------------------------------
  SAVEPOINT get_CostEle_for_DirectItem_PVT;

  l_debug := fnd_profile.value('MRP_DEBUG');
  if (l_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'In get_CostEle_for_DirectItem');
  end if;

  ------------------------------------------------
  -- Standard call to check for API compatibility
  ------------------------------------------------
  l_statement := 10;
  IF not fnd_api.compatible_api_call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME ) then
    RAISE fnd_api.G_exc_unexpected_error;
  END IF;

  -------------------------------------------------------------
  -- Initialize message list if p_init_msg_list is set to TRUE
  -------------------------------------------------------------
  l_statement := 20;
  IF fnd_api.to_Boolean(p_init_msg_list) then
    fnd_msg_pub.initialize;
  end if;

  -------------------------------------------
  -- Initialize API return status to Success
  -------------------------------------------
  l_statement := 30;
  x_return_status := fnd_api.g_ret_sts_success;

  -----------------------------
  -- Validate input parameters
  -----------------------------
  l_statement := 40;
  if (p_txn_id is null or p_mnt_or_mfg is null) then
    l_api_message := 'One of the IN parameter is null';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  ----------------------------------------------------------------------
  --  Verify if transaction ID exists, Obtain po_header_id and po_line_id
  ----------------------------------------------------------------------

 IF p_pac_or_perp = 0 THEN -- Perpetual side code not changed
  l_statement := 50;
  begin
    select nvl(wcti.po_header_id, -1),
           nvl(wcti.po_line_id, -1),
           nvl(wcti.rcv_transaction_id, -1)
    into l_po_header_id,
         l_po_line_id,
         l_rcv_txn_id
    from wip_cost_txn_interface wcti
    where wcti.transaction_id = p_txn_id;
  exception
    when no_data_found then
      l_api_message := 'Transaction ID does not exist in WIP_COST_TXN_INTERFACE table. ';
      FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_api_message);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;
  end;
 ELSE -- Done to support eAM in PAC, get data from WT as WCTI contains nothing at this moment
  l_statement := 55;
  begin
    select nvl(wt.po_header_id, -1),
           nvl(wt.po_line_id, -1),
           nvl(wt.rcv_transaction_id, -1)
    into l_po_header_id,
         l_po_line_id,
         l_rcv_txn_id
    from wip_transactions wt
    where wt.transaction_id = p_txn_id;
  exception
    when no_data_found then
      l_api_message := 'Transaction ID does not exist in WIP_TRANSACTIONS table. ';
      FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_api_message);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;
  end;
 END IF;


  ----------------------------------------
  --  Obtain approved_date, po doc type
  ---------------------------------------
  l_statement := 60;
  if (l_po_header_id <> -1) then
    select pha.approved_date,
           type_lookup_code
    into l_approved_date,
         l_type_lookup_code
    from po_headers_all pha
    where pha.po_header_id = l_po_header_id;
  else
    l_api_message := 'No po_header_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
    l_api_message := l_api_message || ' wip_cost_txn_interface ';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

  -----------------------
  --  Obtain category_id
  -----------------------
  l_statement := 70;
  if (l_po_line_id <> -1) then
    select nvl(pla.category_id, -1)
    into l_category_id
    from po_lines_all pla
    where pla.po_line_id = l_po_line_id;
  else
    l_api_message := 'No po_line_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
    l_api_message := l_api_message || ' wip_cost_txn_interface ';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

  ------------------------
  --  Obtain cost element
  ------------------------
  l_statement := 80;
  if (l_category_id <> -1 and l_approved_date is not null) then

     If (l_type_lookup_code = 'BLANKET') then

         If (l_rcv_txn_id <> -1) then
           select po_release_id
           into l_po_release_id
           from rcv_transactions
           where transaction_id = l_rcv_txn_id;
         Else
           l_api_message := 'No rcv_transaction_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
           l_api_message := l_api_message || ' wip_cost_txn_interface ';
           FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
           FND_MESSAGE.set_token('TEXT', l_api_message);
           FND_MSG_pub.add;
           RAISE FND_API.g_exc_error;
         End if;

         If (l_po_release_id <> -1) then
           select approved_date
           into l_approved_date
           from po_releases_all
           where po_release_id = l_po_release_id;
         Else
           l_api_message := 'No po_release_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
           l_api_message := l_api_message || ' wip_cost_txn_interface ';
           FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
           FND_MESSAGE.set_token('TEXT', l_api_message);
           FND_MSG_pub.add;
           RAISE FND_API.g_exc_error;
         End if;

    end if;

    if p_mnt_or_mfg = 1 then
      begin
        select cceea.mnt_cost_element_id
        into l_cost_element_id
        from cst_cat_ele_exp_assocs cceea
        where cceea.category_id = l_category_id
          and l_approved_date >= cceea.start_date
          and l_approved_date < (nvl(cceea.end_date,sysdate) + 1);
      exception
        when no_data_found then
          l_cost_element_id := 3;
      end;
    else
      begin
        select cceea.mfg_cost_element_id
        into l_cost_element_id
        from cst_cat_ele_exp_assocs cceea
        where cceea.category_id = l_category_id
          and l_approved_date >= cceea.start_date
          and l_approved_date < (nvl(cceea.end_date, sysdate) + 1);
      exception
        when no_data_found then
          l_cost_element_id := 1;
      end;
    end if;
  elsif (l_category_id = -1) then
    l_api_message := 'No category_id exist for PO Line ID: ' || TO_CHAR(l_po_line_id);
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  else
    l_api_message := 'PO Header ID ' || TO_CHAR(l_po_header_id);
    l_api_message := l_api_message || ' has not been approved';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

  x_cost_element_id := l_cost_element_id;

  -- Standard Call to get message count and if count = 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count     => x_msg_count,
    p_data      => x_msg_data );

EXCEPTION
  WHEN fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    x_cost_element_id := -1;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_cost_element_id := -1;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    x_cost_element_id:= -1;
    If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg ( 'CST_eamCost_PUB',
        ' get_CostElement_for_DirectItem: Statement - ' || to_char(l_statement));
    end if;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );
END get_CostEle_for_DirectItem;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|   PROCEDURE                                                                 |
|     get_ExpType_for_DirectItem                                              |
|                                                                             |
|   DESCRIPTION                                                               |
|     This API retrieves the direct  expenditure type  that will be used  for |
|     direct items , its  logic will default  the  expenditure  type  to  the |
|     expenditure type found  in  the  category  associations  form  for  the |
|     category associated with the purchase order line and if not found there |
|     it will like at the expenditure type in the pjm  project parameters and |
|     if not found there it will look at the expenditure  type in the pjm org |
|     parameters.                                                             |
|                                                                             |
|   PURPOSE:                                                                  |
|     Oracle Applications R12                                                 |
|     To support Cost Collection Transfer to Projects of Direct Items for EAM |
|     work orders                                                             |
|   PARAMETERS:                                                               |
|     p_api_version           IN         NUMBER                               |
|     p_init_msg_list         IN         VARCHAR2 := FND_API.G_FALSE          |
|     p_commit                IN         VARCHAR2 := FND_API.G_FALSE          |
|     p_validation_level      IN         NUMBER := FND_API.G_VALID_LEVEL_FULL |
|     p_txn_id                IN         NUMBER                               |
|     x_expenditure_type      OUT NOCOPY VARCHAR2                             |
|     x_return_status         OUT NOCOPY VARCHAR2                             |
|     x_msg_count             OUT NOCOPY NUMBER                               |
|     x_msg_data              OUT NOCOPY VARCHAR2                             |
|                                                                             |
|                                                                             |
|    HISTORY:                                                                 |
|     06/26/03  Linda Soo        Created                                      |
|     08/20/09  Ivan Pineda      Added logic for  this  API  to  retrieve the |
|                                expenditure type from pjm_project_parameters |
|                                or pjm_org_parameters when its  not found in |
|                                in the category associations                 |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  PROCEDURE get_ExpType_for_DirectItem (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN           VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN           NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_txn_id                    IN           NUMBER,
    x_expenditure_type          OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2)
IS
  l_api_name            CONSTANT        VARCHAR2(30) := 'get_ExpType_for_DirectItem';
  l_api_version         CONSTANT        NUMBER := 1.0;

  l_api_message                         VARCHAR2(240);
  l_statement                           NUMBER := 0;
  l_debug                   VARCHAR2(80);

  l_count                               NUMBER;
  l_po_header_id                        NUMBER;
  l_po_line_id                          NUMBER;
  l_category_id                         NUMBER;
  l_approved_date                       DATE;
  l_expenditure_type                    VARCHAR2(30);
  /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++
     Added this two  parameters for bug  7328006 to retrieve
     project_id  and o rganization_id in  the same access to
     wip_transactions to don't hurt  the  performance and at
     the same time be able to access  Pjm_project_parameters
     and pjm_org_parameters to check if the expenditure type
     is defined in there
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  l_organization_id			NUMBER;
  l_project_id				NUMBER;

BEGIN
  -----------------------------------
  -- Standard start of API savepoint
  -----------------------------------
  SAVEPOINT get_ExpType_for_DirectItem_PVT;

  l_debug := fnd_profile.value('MRP_DEBUG');
  if (l_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'In get_ExpType_for_DirectItem');
  end if;

  ------------------------------------------------
  -- Standard call to check for API compatibility
  ------------------------------------------------
  l_statement := 10;
  IF not fnd_api.compatible_api_call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME ) then
    RAISE fnd_api.G_exc_unexpected_error;
  END IF;

  -------------------------------------------------------------
  -- Initialize message list if p_init_msg_list is set to TRUE
  -------------------------------------------------------------
  l_statement := 20;
  IF fnd_api.to_Boolean(p_init_msg_list) then
    fnd_msg_pub.initialize;
  end if;

  -------------------------------------------
  -- Initialize API return status to Success
  -------------------------------------------
  l_statement := 30;
  x_return_status := fnd_api.g_ret_sts_success;

  -----------------------------
  -- Validate input parameters
  -----------------------------
  l_statement := 40;
  if (p_txn_id is null) then
    l_api_message := 'IN parameter is null';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  -----------------------------------------------------------------------
  --  Verify if transaction ID exists and Obtain po_header_id, po_line_id
  --  project_id and organization_id from wip_transactions
  -----------------------------------------------------------------------
  l_statement := 50;
  begin
    select nvl(wt.po_header_id, -1),
      	   nvl(wt.po_line_id, -1),
	   nvl(wt.project_id, -1),
	   nvl(wt.organization_id, -1)
    into   l_po_header_id,
           l_po_line_id,
           l_project_id,
           l_organization_id
    from   wip_transactions wt
    where  wt.transaction_id = p_txn_id;
  exception
    when no_data_found then
      l_api_message := 'Transaction ID does not exist in WIP_TRANSACTIONS table.';
      FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_api_message);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;
  end;

  -------------------------
  --  Obtain approved_date
  -------------------------
  l_statement := 60;
  if (l_po_header_id <> -1) then
    select pha.approved_date
    into l_approved_date
    from po_headers_all pha
    where pha.po_header_id = l_po_header_id;
  else
    l_api_message := 'No po_header_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
    l_api_message := l_api_message || ' wip_transactions ';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

  -----------------------
  --  Obtain category_id
  -----------------------
  l_statement := 70;
  if (l_po_line_id <> -1) then
    select nvl(pla.category_id, -1)
    into l_category_id
    from po_lines_all pla
    where pla.po_line_id = l_po_line_id;
  else
    l_api_message := 'No po_line_id exist for transaction ID: ' || TO_CHAR(p_txn_id);
    l_api_message := l_api_message || ' wip_transactions ';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   The following logic will be used to derive the expenditure
   type for direct items:
   1. Look  into the category associations to find the exp
      type associated with the purchasing category for the
      direct item
   2. If 1 is not found then look at the expenditure type
      at the pjm_project_parameters table defined for
      direct items.
   3. If 2 is not found (like in the case of the common
      project) then use the expenditure type at the
      pjm_org_parameters table defined for direct items
   4. If 3 is not found then error out
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  |   Check if the expenditure type is  defined in the     |
  |   category associations                                |
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  l_statement := 80;
  if (l_category_id <> -1 and l_approved_date is not null) then
    begin
      select pet.expenditure_type
      into l_expenditure_type
      from cst_cat_ele_exp_assocs cceea,
        pa_expenditure_types pet
      where cceea.category_id = l_category_id
        and l_approved_date >= cceea.start_date
        and l_approved_date < (nvl(cceea.end_date, sysdate) + 1)
    and cceea.expenditure_type_id = pet.expenditure_type_id;
    exception
      when no_data_found then
        l_expenditure_type := to_char(-1);
    end;
  elsif (l_category_id = -1) then
    l_api_message := 'No category_id exist for PO Line ID: ' || TO_CHAR(l_po_line_id);
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  else
    l_api_message := 'PO Header ID ' || TO_CHAR(l_po_header_id);
    l_api_message := l_api_message || ' has not been approved';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    RAISE FND_API.g_exc_error;
  end if;

  /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  |   Check if the expenditure type was not defined in the |
  |   category associations then try to derive it from     |
  |   pjm_project_parameters                               |
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  l_statement := 90;
  if (l_expenditure_type = to_char(-1)) then
  	if (l_debug = 'Y') THEN
    		fnd_file.put_line(fnd_file.log, 'No expenditure type found in category associations');
    		fnd_file.put_line(fnd_file.log, 'Deriving expenditure type from Project Parameters');
 	end if;
     	begin
      		select 	ppp.dir_item_expenditure_type
      		into	l_expenditure_type
      		from	pjm_project_parameters ppp
      		where	ppp.project_id = l_project_id
                and     ppp.organization_id = l_organization_id;
       	exception
          	when no_data_found then
        		l_expenditure_type := to_char(-1);
    	end;
   end if;

  /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  |   Check if the expenditure type was not defined in the |
  |   project parameters then try to derive it from the    |
  |   pjm_org_parameters                                   |
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  l_statement := 100;
  if (l_expenditure_type = to_char(-1)) then
  	if (l_debug = 'Y') THEN
    		fnd_file.put_line(fnd_file.log, 'No expenditure type found in Project Parameters');
    		fnd_file.put_line(fnd_file.log, 'Deriving expenditure type from PJM Org Parameters');
 	end if;
     	begin
      		select 	pop.dir_item_expenditure_type
      		into	l_expenditure_type
      		from	pjm_org_parameters pop
      		where	pop.organization_id = l_organization_id;
       	exception
          	when no_data_found then
  			if (l_debug = 'Y') THEN
    				fnd_file.put_line(fnd_file.log, 'No expenditure type found, transaction will error out');
 			end if;
        		l_expenditure_type := to_char(-1);
    			l_api_message := 'No expenditure type has been setup in the category, project prameters';
                        l_api_message := l_api_message || ' or project organization parameters';
   			FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
   			FND_MESSAGE.set_token('TEXT', l_api_message);
    			FND_MSG_pub.add;
    			RAISE FND_API.g_exc_error;
    	end;
   end if;

  x_expenditure_type := l_expenditure_type;

  -- Standard Call to get message count and if count = 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count     => x_msg_count,
    p_data      => x_msg_data );

EXCEPTION
  WHEN fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    x_expenditure_type := to_char(-1);

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_expenditure_type := to_char(-1);

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    x_expenditure_type := to_char(-1);
    If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg ( 'CST_eamCost_PUB',
        ' get_ExpType_for_DirectItem: Statement - ' || to_char(l_statement));
    end if;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );
END get_ExpType_for_DirectItem;

  PROCEDURE Rollup_WorkOrderCost(
    p_api_version     IN         NUMBER,
    p_init_msg_list   IN         VARCHAR2,
    p_commit          IN         VARCHAR2,
    p_group_id        IN         NUMBER,
    p_organization_id IN         NUMBER,
    p_user_id         IN         NUMBER,
    p_prog_appl_id    IN         NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2
   )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Rollup_WorkOrderCost';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_max_level NUMBER;
    l_stmt_num NUMBER := 0;
    l_object_type_count NUMBER;
    l_object_type_exc EXCEPTION;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Rollup_WorkOrderCost_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

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

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_group_id||','||
                          p_organization_id||','||
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 5;
    SELECT count(*)
    INTO   l_object_type_count
    FROM   cst_eam_hierarchy_snapshot
    WHERE  group_id = p_group_id
    AND    (object_type IS NULL OR parent_object_type IS NULL);

    IF l_object_type_count <> 0 THEN
      RAISE l_object_type_exc;
    END IF;

    -- Calculate the depth of the hierarchy
    l_stmt_num := 10;
    SELECT MAX(level_num)
    INTO   l_max_level
    FROM   cst_eam_hierarchy_snapshot
    WHERE  group_id = p_group_id;

    -- Generate a warning if there is no matching record in the supplied group id
    l_stmt_num := 15;
    IF l_max_level IS NULL and l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => 'There is no matching record in CST_EAM_HIERARCHY_SNAPSHOT ' ||
                        'for group id ' || p_group_id
      );
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    -- Delete existing calculations for this group id
    l_stmt_num := 17;
    DELETE cst_eam_rollup_costs
    WHERE  group_id = p_group_id;

    -- Generate a warning if there are existing calculations for this group id
    l_stmt_num := 19;
    IF SQL%ROWCOUNT > 0 and l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => 'Deleted ' || SQL%ROWCOUNT || ' existing calculation for ' ||
                        ' group id '|| p_group_id
      );
    END IF;

    -- Calculate the cumulative costs, starting from the leaf nodes.
    l_stmt_num := 20;
    FOR l_level IN REVERSE 0 .. l_max_level LOOP
      INSERT
      INTO   cst_eam_rollup_costs(
               group_id,
               object_type,
               object_id,
               period_set_name,
               period_name,
               maint_cost_category,
               actual_mat_cost,
               actual_lab_cost,
               actual_eqp_cost,
               estimated_mat_cost,
               estimated_lab_cost,
               estimated_eqp_cost,
               last_update_date,
               last_updated_by,
               creation_date,
               creation_by,
               program_application_id
             )
      SELECT TEMP.group_id,
             TEMP.object_type,
             TEMP.object_id,
             TEMP.period_set_name,
             TEMP.period_name,
             TEMP.maint_cost_category,
             SUM(TEMP.actual_mat_cost),
             SUM(TEMP.actual_lab_cost),
             SUM(TEMP.actual_eqp_cost),
             SUM(TEMP.estimated_mat_cost),
             SUM(TEMP.estimated_lab_cost),
             SUM(TEMP.estimated_eqp_cost),
             SYSDATE,
             p_user_id,
             SYSDATE,
             p_user_id,
             p_prog_appl_id
      FROM   (
               SELECT CURR.group_id group_id,
                      CURR.object_type object_type,
                      CURR.object_id object_id,
                      WEPB.period_set_name period_set_name,
                      WEPB.period_name period_name,
                      WEPB.maint_cost_category maint_cost_category,
                      SUM(NVL(WEPB.actual_mat_cost,0)) actual_mat_cost,
                      SUM(NVL(WEPB.actual_lab_cost,0)) actual_lab_cost,
                      SUM(NVL(WEPB.actual_eqp_cost,0)) actual_eqp_cost,
                      SUM(NVL(WEPB.system_estimated_mat_cost,0)) estimated_mat_cost,
                      SUM(NVL(WEPB.system_estimated_lab_cost,0)) estimated_lab_cost,
                      SUM(NVL(WEPB.system_estimated_eqp_cost,0)) estimated_eqp_cost
               FROM   cst_eam_hierarchy_snapshot CURR,
                      wip_eam_period_balances WEPB
               WHERE  CURR.group_id = p_group_id
               AND    CURR.level_num = l_level
               AND    CURR.object_type = 2 -- WIP job
               AND    WEPB.organization_id = p_organization_id
               AND    WEPB.wip_entity_id = CURR.object_id
               GROUP
               BY     CURR.group_id,
                      CURR.object_type,
                      CURR.object_id,
                      WEPB.period_set_name,
                      WEPB.period_name,
                      WEPB.maint_cost_category
               UNION ALL
               SELECT CURR.group_id,
                      CURR.object_type,
                      CURR.object_id,
                      CERC.period_set_name,
                      CERC.period_name,
                      CERC.maint_cost_category,
                      SUM(NVL(CERC.actual_mat_cost,0)),
                      SUM(NVL(CERC.actual_lab_cost,0)),
                      SUM(NVL(CERC.actual_eqp_cost,0)),
                      SUM(NVL(CERC.estimated_mat_cost,0)),
                      SUM(NVL(CERC.estimated_lab_cost,0)),
                      SUM(NVL(CERC.estimated_eqp_cost,0))
               FROM   cst_eam_hierarchy_snapshot CURR,
                      cst_eam_hierarchy_snapshot CHILDREN,
                      cst_eam_rollup_costs CERC
               WHERE  CURR.group_id = p_group_id
               AND    CURR.level_num = l_level
               AND    CHILDREN.group_id = p_group_id
               AND    CHILDREN.parent_object_type = CURR.object_type
               AND    CHILDREN.parent_object_id = CURR.object_id
               AND    CERC.group_id = p_group_id
               AND    CERC.object_type = CHILDREN.object_type
               AND    CERC.object_id = CHILDREN.object_id
               GROUP
               BY     CURR.group_id,
                      CURR.object_type,
                      CURR.object_id,
                      CERC.period_set_name,
                      CERC.period_name,
                      CERC.maint_cost_category
             ) TEMP
      GROUP
      BY     TEMP.group_id,
             TEMP.object_type,
             TEMP.object_id,
             TEMP.period_set_name,
             TEMP.period_name,
             TEMP.maint_cost_category;
    END LOOP;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||
                        ': Successfully rolled up the cost for group id '||
                        p_group_id
      );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Rollup_WorkOrderCost_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN l_object_type_exc THEN
      ROLLBACK TO Rollup_WorkOrderCost_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => 'Object type must be inserted. Use 0 instead of '||
                          'NULL for entities that are not a WIP entity'
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO Rollup_WorkOrderCost_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Rollup_WorkOrderCost;

  PROCEDURE Purge_RollupCost(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_group_id         IN         NUMBER,
    p_prog_appl_id     IN         NUMBER,
    p_last_update_date IN         DATE,
    x_return_status    OUT NOCOPY VARCHAR2
   )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Purge_RollupCost';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Purge_RollupCost_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

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

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_group_id||','||
                          p_prog_appl_id||','||
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 10;
    DELETE cst_eam_hierarchy_snapshot
    WHERE  group_id = NVL(p_group_id,group_id)
    AND    program_application_id =
           NVL(p_prog_appl_id,program_application_id)
    AND    last_update_date < NVL(p_last_update_date,last_update_date+1);

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||
                        ': Successfully deleted '||
                        SQL%ROWCOUNT||
                        ' from CST_EAM_HIERARHCY_SNAPSHOT'
      );
    END IF;

    l_stmt_num := 20;
    DELETE cst_eam_rollup_costs
    WHERE  group_id = NVL(p_group_id,group_id)
    AND    program_application_id =
           NVL(p_prog_appl_id,program_application_id)
    AND    last_update_date < NVL(p_last_update_date,last_update_date+1);

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||
                        ': Successfully deleted '||
                        SQL%ROWCOUNT||
                        ' from CST_EAM_ROLLUP_COSTS'
      );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Purge_RollupCost_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Purge_RollupCost_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Purge_RollupCost;


--------------------------------------------------------------------------
--      API name         : Insert_eamBalAcct
--      Type                : Public
--      Description     : This API inserts data in CST_EAM_BALANCE_BY_ACCOUNTS
--                        table.
--
--      HISTORY
--      04/29/05   Anjali R    Added as part of eAM Requirements Project (R12)
--
--------------------------------------------------------------------------
PROCEDURE Insert_eamBalAcct
(
        p_api_version                IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2,
        p_commit                IN        VARCHAR2,
        p_validation_level        IN        NUMBER,
        x_return_status         OUT NOCOPY        VARCHAR2,
        x_msg_count             OUT NOCOPY        NUMBER,
        x_msg_data              OUT NOCOPY        VARCHAR2,
        p_period_id             IN      NUMBER,
        p_period_set_name       IN      VARCHAR2,
        p_period_name           IN      VARCHAR2,
        p_org_id                IN      NUMBER,
        p_wip_entity_id         IN      NUMBER,
        p_owning_dept_id        IN      NUMBER,
        p_dept_id               IN      NUMBER,
        p_maint_cost_cat        IN      NUMBER,
        p_opseq_num             IN      NUMBER,
        p_period_start_date     IN          DATE,
        p_account_ccid          IN      NUMBER,
        p_value                 IN      NUMBER,
        p_txn_type              IN      NUMBER,
        p_wip_acct_class        IN      VARCHAR2,
        p_mfg_cost_element_id   IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER,
        p_prog_app_id           IN      NUMBER,
        p_login_id              IN      NUMBER
)
IS
        l_api_name       CONSTANT VARCHAR2(30) := 'Insert_eamBalAcct';
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


        l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED>=G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
        l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

        l_cnt_cebba    NUMBER;
        l_stmt_num     NUMBER;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Insert_eamBalAcct_PUB;

        if( l_pLog ) then
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Start of ' || l_full_name || '(' ||
               'p_user_id=' || p_user_id || ',' ||
               'p_login_id=' || p_login_id ||',' ||
               'p_prog_app_id=' || p_prog_app_id ||',' ||
               'p_prog_id=' || p_prog_id ||',' ||
               'p_request_id=' || p_request_id ||',' ||
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

        MERGE INTO CST_EAM_BALANCE_BY_ACCOUNTS  cebba
        USING
        (
         SELECT NULL FROM DUAL
        )
        ON
        (
        cebba.period_set_name     = period_set_name AND
        cebba.period_name         = p_period_name    AND
        cebba.acct_period_id      = p_period_id     AND
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
         Insert
                (
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
        (          p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Insert_eamBalAcct_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                   FND_LOG.LEVEL_UNEXPECTED,
                          l_module || '.' || l_stmt_num ,
                        l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB(SQLERRM , 1 , 240)
                      );
                END IF;

                FND_MSG_PUB.Count_And_Get
                (          p_count                =>      x_msg_count     ,
                        p_data                 =>      x_msg_data
                );
    WHEN OTHERS THEN
                ROLLBACK TO Insert_eamBalAcct_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num ,
                     l_full_name || '( '|| l_stmt_num || ') :' || SUBSTRB(SQLERRM , 1 , 240)
                     );
                END IF;

                IF         FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                            (        'CST_eamCost_PUB'   ,
                                    l_api_name
                            );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (          p_count                =>      x_msg_count     ,
                        p_data                 =>      x_msg_data
                );
END Insert_eamBalAcct;


-------------------------------------------------------------------------------
--      API name         : Delete_eamBalAcct
--      Type                : Public
--      Function        : This API deletes data from CST_EAM_BALANCE_BY_ACCOUNTS
--                        table for the given wip_entity_id.
--
--      History                :
--      03/29/05  Anjali R    Added as part of eAM requirements Project (R12)
--
-------------------------------------------------------------------------------
PROCEDURE Delete_eamBalAcct
(
        p_api_version                IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2,
        p_commit                IN        VARCHAR2,
        p_validation_level        IN        NUMBER        ,
        x_return_status         OUT NOCOPY        VARCHAR2,
        x_msg_count             OUT NOCOPY        VARCHAR2,
        x_msg_data              OUT NOCOPY        VARCHAR2,
        p_org_id                IN          NUMBER,
        p_entity_id_tab         IN      CSTPECEP.wip_entity_id_type
)
IS
        l_api_name        CONSTANT VARCHAR2(30)        := 'Delete_eamBalAcct';
        l_api_version   CONSTANT NUMBER         := 1.0;

        l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
        l_module       CONSTANT VARCHAR2(60) := 'cst.plsql.'||l_full_name;

        l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED>=G_LOG_LEVEL AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

        l_stmt_num     NUMBER;
BEGIN
        -- Standard Start of API savepoint
    SAVEPOINT   Delete_eamBalAcct_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (        l_api_version,
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
               l_module || '.begin',  'Start of ' || l_full_name );
        end if;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 10;

       /* Delete data from CST_EAM_BALANCE_BY_ACCOUNTS */
       FORALL l_index IN p_entity_id_tab.FIRST..p_entity_id_tab.LAST
        Delete from CST_EAM_BALANCE_BY_ACCOUNTS
        where wip_entity_id = p_entity_id_tab(l_index)
        and organization_id=p_org_id;

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
        (          p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_eamBalAcct_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                        FND_LOG.STRING(
                                FND_LOG.LEVEL_UNEXPECTED,
                                l_module || '.' || l_stmt_num ,
                     l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240));
                END IF;

                FND_MSG_PUB.Count_And_Get
                (          p_count                =>      x_msg_count     ,
                        p_data                 =>      x_msg_data
                );
    WHEN OTHERS THEN
                ROLLBACK TO Delete_eamBalAcct_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF (l_uLog) THEN
                  FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240));
                END IF;

                IF         FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                            (        'CST_eamCost_PUB'   ,
                                    l_api_name
                            );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (          p_count                =>      x_msg_count     ,
                        p_data                 =>      x_msg_data
                );
END Delete_eamBalAcct;


PROCEDURE Insert_tempEstimateDetails
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_entity_id_tab        IN  CSTPECEP.wip_entity_id_type
)
IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Delete_eamBalAcct';
    l_api_version  CONSTANT NUMBER       := 1.0;

    l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED>=G_LOG_LEVEL
                                       AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

    l_stmt_num     NUMBER;

l_is_shared_proc varchar2(1);
l_currency_code varchar2(20);
l_currency_date date;
l_currency_type varchar2(10);
l_unit_price  number;
l_currency_rate number;
l_return_status varchar2(200);
l_amount number;
l_amount_delivered number;
l_schema VARCHAR2(30);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_gather_stats NUMBER;

cursor c_cedi is
select project_id,
       purchasing_ou_id,
       receiving_ou_id,
       organization_id,
       document_type,
       currency_code,
       currency_rate,
       currency_date,
       currency_type,
       txn_flow_header_id,
       unit_price,
       set_of_books_id,
       order_type_lookup_code,
       amount,
       amount_delivered
from cst_eam_direct_items_temp
where purchasing_ou_id <> receiving_ou_id
FOR UPDATE;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Insert_tempEstimateDetails_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        'CST_eamCost_PUB') THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    IF( l_pLog ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
           l_module || '.begin',  'Start of ' || l_full_name );
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num := 10;

    /* Insert rows for POs for Direct Items */
    FORALL l_index in p_entity_id_tab.FIRST..p_entity_id_tab.LAST
    INSERT INTO cst_eam_direct_items_temp
    SELECT
      pd.wip_entity_id,
      pd.wip_operation_seq_num,
      pd.destination_organization_id,
      wo.department_id,
      to_number(null),
      poh.segment1 ,
      pd.item_description,
      uom.uom_code,
      pd.unit_price,
      to_number(null),
      sum(pd.quantity_ordered) ,
      sum(pd.quantity_delivered),
      to_date(null),
      sum(pd.quantity_ordered),
      sum(pd.quantity_cancelled),
      to_char(null),
      to_number(null),
      pd.line_location_id,
      pd.cancel_flag,
      pd.item_id,
      null, -- rql.closed_code,
      pd.closed_code,
      null, --  rqh.authorization_status,
      poh.authorization_status,
      pd.po_line_id,
      poh.po_header_id,
      to_number(null), -- rqh.requisition_header_id,
      wed.direct_item_sequence_id,
      pd.category_id,
      pd.po_release_id,
      to_number(null), -- rql.requisition_line_id,
      pd.order_type_lookup_code,
      pd.amount_ordered,
      pd.amount_delivered,
      pd.req_distribution_id,
      poh.approved_date,
      pd.project_id, -- PROJECT_ID
      pd.org_id, -- PURCHASING_OU_ID
      to_number(org_information1), -- SET_OF_BOOKS_ID
      to_number(NULL), -- TXN_FLOW_HEADER_ID
      to_number(hoi.org_information3), -- RECEIVING_OU_ID
      poh.currency_code,   -- CURRENCY_CODE
      poh.rate_date,   -- CURRENCY_DATE
      poh.rate_type,   -- CURRENCY_TYPE
      pd.rate, -- CURRENCY_RATE  ,
      poh.type_lookup_code, -- DOCUMENT_TYPE
      to_char(null) -- IS_SHARED_PROC
    FROM
      po_line_types plt,
      mtl_units_of_measure uom,
      po_headers_all poh,
      wip_eam_direct_items wed,
      hr_organization_information hoi,
      wip_operations wo,
      (SELECT
          pd1.wip_entity_id,
          pd1.wip_operation_seq_num,
          pd1.destination_organization_id,
          pd1.wip_line_id,
          pol.item_description,
          pol.unit_price,
          pd1.quantity_ordered,
          pd1.quantity_cancelled,
          pd1.quantity_delivered,
          pd1.line_location_id,
          pol.cancel_flag,
          pol.item_id,
          pol.closed_code,
          pol.po_line_id,
          pol.category_id,
          pd1.po_release_id,
          pol.order_type_lookup_code,
          pd1.amount_ordered,
          pd1.amount_delivered,
          pd1.req_distribution_id,
          pd1.rate,
          pol.unit_meas_lookup_code,
          pd1.destination_type_code,
          pol.line_type_id,
          pd1.po_header_id,
          pd1.project_id,
          pol.org_id
       FROM po_lines_all pol,
            po_distributions_all pd1
       WHERE pol.po_line_id = pd1.po_line_id AND
             pd1.wip_entity_id = p_entity_id_tab(l_index)
      ) pd
    WHERE
      pd.po_line_id = pd.po_line_id AND
      pd.wip_entity_id = p_entity_id_tab(l_index) AND
      poh.po_header_id = pd.po_header_id AND
      pd.line_type_id = plt.line_type_id AND
      upper(nvl(plt.outside_operation_flag, 'N')) = 'N' AND
      pd.destination_type_code = 'SHOP FLOOR' AND
      pd.unit_meas_lookup_code = uom.unit_of_measure (+) AND
      upper(nvl(pd.cancel_flag, 'N')) <> 'Y' AND
      pd.wip_entity_id IS NOT NULL AND
      pd.item_description = wed.description(+) AND
      pd.wip_entity_id = wed.wip_entity_id (+) AND
      pd.wip_operation_seq_num = wed. operation_seq_num (+) AND
      pd.destination_organization_id = wed.organization_id (+) AND
      hoi.organization_id = pd.destination_organization_id AND
      hoi.org_information_context = 'Accounting Information' AND
      wo.wip_entity_id(+) = p_entity_id_tab(l_index) AND
      wo.organization_id(+) = pd.destination_organization_id AND
      wo.operation_seq_num(+) = pd.wip_operation_seq_num
    GROUP BY pd.wip_entity_id,
             pd.wip_operation_seq_num,
             pd.destination_organization_id,
             wo.department_id,
             poh.segment1,
             pd.item_description,
             uom.uom_code,
             pd.order_type_lookup_code,
             pd.unit_price,
             pd.amount_ordered,
             pd.amount_delivered,
             poh.currency_code,
             pd.cancel_flag,
             pd.item_id,
             pd.closed_code,
             poh.authorization_status,
             pd.po_line_id,
             poh.po_header_id,
             wed.direct_item_sequence_id,
             pd.category_id,
             pd.po_release_id,
             pd.req_distribution_id,
             pd.rate,
             poh.approved_date,
             pd.wip_line_id,
             pd.line_location_id,
             pd.project_id,
             pd.org_id, -- PURCHASING_OU_ID
             to_number(org_information1), -- SET_OF_BOOKS_ID
             to_number(hoi.org_information3), -- RECEIVING_OU_ID
             poh.currency_code,   -- CURRENCY_CODE
             poh.rate_date,   -- CURRENCY_DATE
             poh.rate_type,   -- CURRENCY_TYPE
             pd.rate, -- CURRENCY_RATE  ,
             poh.type_lookup_code; -- DOCUMENT_TYPE

    l_stmt_num := 20;

    UPDATE cst_eam_direct_items_temp cedi
    SET TXN_FLOW_HEADER_ID =(SELECT transaction_flow_header_id
                             FROM po_line_locations_all poll
                             WHERE poll.line_location_id = cedi.line_location_id)
    WHERE cedi.line_location_id is not null;


    /* Will insert for Reqs after updation to avoid extra rows that need not participate in updation */

    UPDATE cst_eam_direct_items_temp cedi
    SET (REQUISITION_NUMBER,
         REQ_AUTHORIZATION_STATUS,
         REQUISITION_HEADER_ID,
         REQUISITION_LINE_ID,
         CLOSED_CODE
         ) = (SELECT rqh.segment1,
                     rqh.authorization_status,
                     rqh.requisition_header_id,
                     rql.requisition_line_id,
                     rql.closed_code
              FROM   po_requisition_headers_all rqh,
                     po_requisition_lines_all rql,
                     po_req_distributions_all rqd
              WHERE  rql.requisition_header_id = rqh.requisition_header_id AND
                     rqd.requisition_line_id = rql.requisition_line_id AND
                     rqd.distribution_id(+) = cedi.req_distribution_id
              )
    WHERE cedi.req_distribution_id IS NOT NULL;

    l_stmt_num := 30;

    /* Insert rows for Reqs for Direct Items */
    FORALL l_index in p_entity_id_tab.FIRST..p_entity_id_tab.LAST
    INSERT INTO cst_eam_direct_items_temp
    SELECT
     rql.wip_entity_id,
     rql.wip_operation_seq_num,
     rql.destination_organization_id,
     wo.department_id,
     rqh.segment1,
     null,
     rql.item_description,
     uom.uom_code,
     rql.unit_price,
     rql.quantity,
     rql.quantity,
     to_number(null),
     to_date(null),
     to_number(null),
     to_number(null),
     to_char(null),
     to_number(null),
     to_number(null),
     to_char(null),
     rql.item_id,
     rql.closed_code,
     to_char(null),
     rqh.authorization_status,
     to_char(null),
     to_number(null),
     to_number(null),
     rqh.requisition_header_id,
     wed.direct_item_sequence_id,
     rql.category_id,
     to_number(null),
     rql.requisition_line_id,
     rql.order_type_lookup_code,
     rql.amount,
     to_number(null) ,
     to_number(null),
     rqh.last_update_date,
     to_number(NULL), -- PROJECT_ID
     rql.org_id, -- PURCHASING_OU_ID
     to_number(hoi.org_information1), -- SET_OF_BOOKS_ID
     to_number(NULL), -- TXN_FLOW_HEADER_ID
     to_number(hoi.org_information3), -- RECEIVING_OU_ID
     rql.currency_code,   -- CURRENCY_CODE
     rql.rate_date,   -- CURRENCY_DATE
     rql.rate_type,   -- CURRENCY_TYPE
     rql.rate, -- CURRENCY_RATE  ,
     rqh.type_lookup_code,  -- DOCUMENT_TYPE
     to_char(null) -- IS_SHARED_PROC
    FROM
      po_requisition_lines_all rql,
      po_requisition_headers_all rqh,
      po_line_types plt,
      mtl_units_of_measure uom,
      wip_eam_direct_items wed,
      hr_organization_information hoi,
      wip_operations wo
    WHERE
      rql.requisition_header_id = rqh.requisition_header_id AND
      rql.line_type_id =   plt.line_type_id AND
      rql.unit_meas_lookup_code = uom.unit_of_measure (+) AND
      upper(rqh.authorization_status) NOT IN ('CANCELLED', 'REJECTED','SYSTEM_SAVED')   AND
      rql.line_location_id IS NULL AND
      upper(nvl(rql.cancel_flag, 'N')) <> 'Y' AND
      upper(nvl(plt.outside_operation_flag, 'N')) = 'N' AND
      rql.destination_type_code =   'SHOP FLOOR' AND
      rql.wip_entity_id IS NOT NULL AND
      rql.item_description =   wed.description (+) AND
      rql.wip_entity_id = wed.wip_entity_id (+) AND
      RQL.WIP_OPERATION_SEQ_NUM = WED.OPERATION_SEQ_NUM (+) AND
      rql.destination_organization_id = wed.organization_id (+) AND
      rql.wip_entity_id =   p_entity_id_tab(l_index) AND
      hoi.organization_id = rql.destination_organization_id AND
      hoi.org_information_context = 'Accounting Information'  AND
      wo.wip_entity_id(+) = p_entity_id_tab(l_index) AND
      wo.organization_id(+) = rql.destination_organization_id AND
      wo.operation_seq_num(+) = RQL.WIP_OPERATION_SEQ_NUM ;


      for c_cedi_rec in c_cedi loop

        l_amount := 0;
        l_amount_delivered := 0;
        l_unit_price := 0;

        PO_SHARED_PROC_GRP.check_shared_proc_scenario
            (
                 p_api_version                => 1.0,
                 p_init_msg_list              => FND_API.G_FALSE,
                 x_return_status              => l_return_status,
                 p_destination_type_code      => 'SHOP FLOOR',
                 p_document_type_code         => c_cedi_rec.document_type,
                 p_project_id                 => c_cedi_rec.project_id,
                 p_purchasing_ou_id           => c_cedi_rec.purchasing_ou_id,
                 p_ship_to_inv_org_id         => c_cedi_rec.organization_id,
                 p_transaction_flow_header_id => c_cedi_rec.txn_flow_header_id,
                 x_is_shared_proc_scenario    => l_is_shared_proc
             );

       l_is_shared_proc := nvl(l_is_shared_proc,'N');

       if (l_is_shared_proc = 'Y') then

           IF (c_cedi_rec.currency_code IS NULL) THEN
                  SELECT currency_code
                  INTO   l_currency_code
                  FROM   gl_sets_of_books
                  WHERE  set_of_books_id = c_cedi_rec.set_of_books_id;
           Else
                  l_currency_code := c_cedi_rec.currency_code;
           END IF;

           IF (c_cedi_rec.currency_date IS NULL) THEN
                  l_currency_date := SYSDATE;
           Else
                  l_currency_date := c_cedi_rec.currency_date;
           END IF;

           fnd_profile.get('IC_CURRENCY_CONVERSION_TYPE', l_currency_type);

           l_currency_rate := PO_CORE_S.get_conversion_rate (
                                   c_cedi_rec.set_of_books_id,
                                   l_currency_code,
                                   l_currency_date,
                                   l_currency_type);

           If c_cedi_rec.order_type_lookup_code ='FIXED PRICE' or c_cedi_rec.order_type_lookup_code ='RATE' then
                l_amount := c_cedi_rec.amount * l_currency_rate;
                l_amount_delivered := c_cedi_rec.amount_delivered * l_currency_rate;
           else
                l_unit_price := c_cedi_rec.unit_price * l_currency_rate;
           end if;

           update cst_eam_direct_items_temp
           set unit_price = l_unit_price,
               currency_rate = l_currency_rate,
               currency_code = l_currency_code,
               currency_date = l_currency_date,
               currency_type = l_currency_type,
               is_shared_proc = l_is_shared_proc,
               amount = l_amount,
               amount_delivered = l_amount_delivered
           where current of c_cedi;

       End If;

      end loop;

      /* Gather stats for the temporary table CST_EAM_DIRECT_ITEMS_TEMP  if number
         of work orders are greater than 1000. Full table scan seems better in case of less
         work orders*/
      If p_entity_id_tab.COUNT> 1000 then


            l_stmt_num := 26;
            l_gather_stats := CST_Utility_PUB.check_Db_Version(
                                p_api_version     => 1.0,
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data
                              );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_gather_stats = 1
            THEN
              l_stmt_num := 37;
              IF NOT FND_INSTALLATION.GET_APP_INFO('BOM', l_status, l_industry, l_schema)
              THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF l_schema IS NOT NULL
              THEN
                l_stmt_num := 29;
                FND_STATS.GATHER_TABLE_STATS(l_schema, 'CST_EAM_DIRECT_ITEMS_TEMP');
              END IF;

            END IF;

       End if;

      l_stmt_num := 40;

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
    (   p_count => x_msg_count,
        p_data  => x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Insert_tempEstimateDetails_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF (l_uLog) THEN
                 FND_LOG.STRING(
                         FND_LOG.LEVEL_UNEXPECTED,
                         l_module || '.' || l_stmt_num ,
              l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240));
         END IF;

         FND_MSG_PUB.Count_And_Get
         (   p_count => x_msg_count,
             p_data  => x_msg_data
         );

    WHEN OTHERS THEN
         ROLLBACK TO Insert_tempEstimateDetails_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF (l_uLog) THEN
           FND_LOG.STRING(
              FND_LOG.LEVEL_UNEXPECTED,
              l_module || '.' || l_stmt_num,
              l_full_name ||'('|| l_stmt_num ||') :' || SUBSTRB (SQLERRM , 1 , 240));
         END IF;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg('CST_eamCost_PUB'
                                         , l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         (   p_count => x_msg_count,
             p_data  => x_msg_data
         );

END Insert_tempEstimateDetails;



PROCEDURE Get_Encumbrance_Data(
  p_receiving_transaction_id   IN         NUMBER
 ,p_api_version                IN         NUMBER DEFAULT 1
 ,x_encumbrance_amount         OUT NOCOPY NUMBER
 ,x_encumbrance_quantity       OUT NOCOPY NUMBER
 ,x_encumbrance_ccid           OUT NOCOPY NUMBER
 ,x_encumbrance_type_id        OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2)
IS
  /*Parameters list */
  l_rcv_transaction_id       NUMBER := p_receiving_transaction_id;
  l_api_version              NUMBER := p_api_version;
  l_encumbrance_amount       NUMBER;
  l_encumbrance_quantity     NUMBER;
  l_encumbrance_ccid         NUMBER;
  l_encumbrance_type_id      NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_text                 VARCHAR2(2000);
  l_direct_delivery_flag     VARCHAR2(1) := NULL;

  /*Api details*/
  l_api_name        CONSTANT VARCHAR2(30)   := 'Get_Encumbrance_Data';
  l_api_message              VARCHAR2(1000);
  l_stmt_num                 NUMBER := 0;

  /*Local variable*/
  l_po_header_id          NUMBER;
  l_po_distribution_id    NUMBER;
  l_po_org_id             NUMBER;
  l_po_sob_id             NUMBER;
  l_destination_type      VARCHAR(25);
  l_rcv_trx_date          DATE;
  l_drop_ship_flag        NUMBER;
  l_rcv_organization_id   NUMBER;
  l_category_id           NUMBER;
  l_project_id            NUMBER;
  l_accrual_flag          VARCHAR2(1)    := 'N';
  l_po_document_type_code PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_cross_ou_flag         VARCHAR2(1) := 'N'  ;
  l_rcv_org_id            NUMBER;
  l_rcv_sob_id            NUMBER;
  l_procurement_org_flag  VARCHAR2(1)   := 'Y';
  l_entered_cr            NUMBER;
  l_entered_dr            NUMBER;
  l_accounted_cr          NUMBER;
  l_accounted_dr          NUMBER;
  l_prior_entered_cr      NUMBER;
  l_ussgl_option          VARCHAR2(1);
  l_msg_data              VARCHAR2(8000) := '';
  l_encumbrance_flag      VARCHAR2(1);
  lstr                    VARCHAR2(4000);

  /* Currency infomration */
  l_curreny_code          VARCHAR2(15);
  l_curreny_code_func     VARCHAR2(15);
  l_min_acct_unit_doc     NUMBER;
  l_min_acct_unit_func    NUMBER;
  l_precision_doc         NUMBER;
  l_precision_func        NUMBER;
  l_chart_of_accounts_id  NUMBER;
  l_po_encumbrance_amount NUMBER;
  l_rcv_event             rcv_seedevents_pvt.rcv_event_rec_type;

BEGIN
  debug('Get_Encumbrance_Data +');
  debug('  p_receiving_transaction_id: '||p_receiving_transaction_id );
  debug('  p_api_version             : '||p_api_version );

  --------------------------------------------------------
  --In this API logic to return desired value is divided in three steps
  --Step 1:
  --For a Deliver transaction id  logic  to Seed event record type structure,which will provide
  --i) Encumrbance Qty
  --ii) Currency Conversion rate
  --iii) Encumbrance account
  --iv) Unit Price - To compute encumbrance amount
  --Step 2 : Get the encumbrance_type_id
  --Step 3 : Compute encumbrance amount using values got in Step 1  and assign final
  --values to out parameter
  ---------------------------------------------------------

  -- Standard start of API savepoint
  SAVEPOINT GET_ENCUMBRANCE_DATA_PVT;
  l_stmt_num := 10 ;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;


  -- Unlike for Receive transactions, for Deliver transactions, the po_distribution_id
  -- is always available.
  l_stmt_num := 20;
  debug(l_stmt_num);

  SELECT   RT.po_header_id,
           RT.po_distribution_id,
           POD.destination_type_code,
           RT.transaction_date,
           NVL(RT.dropship_type_code,3),
           POH.org_id,
           POLL.ship_to_organization_id,
           POL.category_id,
           POL.project_id,
           NVL(POLL.accrue_on_receipt_flag,'N'),
           POH.type_lookup_code,
           pod.encumbered_Amount
     INTO  l_po_header_id,
           l_po_distribution_id,
           l_destination_type,
           l_rcv_trx_date,
           l_drop_ship_flag,
           l_po_org_id,
           l_rcv_organization_id,
           l_category_id,
           l_project_id,
           l_accrual_flag,
           l_po_document_type_code,
           l_po_encumbrance_amount
     FROM  po_headers_all            POH,
           po_line_locations_all     POLL,
           po_lines_all              POL,
           po_distributions_all      POD,
           rcv_transactions          RT
    WHERE   RT.transaction_id         = p_receiving_transaction_id
    AND     POH.po_header_id          = RT.po_header_id
    AND     POLL.line_location_id     = RT.po_line_location_id
    AND     POL.po_line_id            = RT.po_line_id
    AND     POD.po_distribution_id    = RT.po_distribution_id;

  debug(' RCV Transaction ID :'|| p_receiving_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Destination Type : '|| l_destination_type ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', Project ID : '|| l_project_id ||
                          ', Category ID : ' || l_category_id ||
                         ', Accrual Flag : ' || l_accrual_flag );
  l_stmt_num := 25;
  debug(l_stmt_num);
  debug(' l_po_encumbrance_amount :'||l_po_encumbrance_amount);
  IF l_po_encumbrance_amount IS NULL OR l_po_encumbrance_amount = 0 THEN
   x_encumbrance_amount    := NULL;
   x_encumbrance_quantity  := NULL;
   x_encumbrance_ccid      := NULL;
   x_encumbrance_type_id   := NULL;
   RETURN;
  END IF;


  l_stmt_num := 30;
  debug(l_stmt_num);

  -- Get Receiving Operating Unit and SOB
  SELECT  operating_unit, ledger_id
  INTO    l_rcv_org_id, l_rcv_sob_id
  FROM    cst_acct_info_v
  WHERE   organization_id = l_rcv_organization_id;

  debug('  l_rcv_org_id:'||l_rcv_org_id);
  debug('  l_rcv_sob_id:'||l_rcv_sob_id);

  l_stmt_num := 35;
  debug(l_stmt_num);
  -- Get PO SOB
  SELECT  set_of_books_id
  INTO    l_po_sob_id
  FROM    financials_system_parameters
  WHERE   org_id = l_rcv_org_id;

  debug('  l_po_sob_id:'||l_po_sob_id);

  IF(l_po_org_id <> l_rcv_org_id) THEN  l_cross_ou_flag := 'Y'; END IF;
  debug('  l_cross_ou_flag:'||l_cross_ou_flag);

  l_stmt_num := 40;
  debug(l_stmt_num);

  RCV_SeedEvents_PVT.Check_EncumbranceFlag(
                  p_api_version           => 1.0,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  p_rcv_sob_id            => l_rcv_sob_id,
                  x_encumbrance_flag      => l_encumbrance_flag,
                  x_ussgl_option          => l_ussgl_option);

  debug('  l_encumbrance_flag : '||l_encumbrance_flag);
  debug('  x_return_status    : '||x_return_status);
  debug('  x_msg_count        : '||x_msg_count);
  debug('  x_msg_data         : '||x_msg_data);

  IF(l_encumbrance_flag = 'Y') THEN
    l_stmt_num := 50 ;
    debug(l_stmt_num);

    /*****************************************************
    By calling Seed_RAEEvent we are only getting recirds structure with necessary values
    such as Qty,Price ,currency_conversion_rate.At any point of time we are not inserting any events
    in rcv_accounting_events or any other events table
    *****************************************************/
    RCV_SeedEvents_PVT.Seed_RAEEvent(
              p_api_version           => 1.0,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
              p_event_source          => 'RECEIVING',
              p_event_type_id         => RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL,
              p_rcv_transaction_id    => p_receiving_transaction_id,-- parmeter p_rcv_transaction_id
              p_inv_distribution_id   => NULL,
              p_po_distribution_id    => l_po_distribution_id,
              p_direct_delivery_flag  => l_direct_delivery_flag ,-- parameter p_direct_delivery_flag
              p_cross_ou_flag         => l_cross_ou_flag,
              p_procurement_org_flag  => l_procurement_org_flag,
              p_ship_to_org_flag      => 'Y',
              p_drop_ship_flag        => l_drop_ship_flag,
              p_org_id                => l_rcv_org_id,
              p_organization_id       => l_rcv_organization_id,
              p_transfer_org_id       => NULL,
              p_trx_flow_header_id    => NULL,
              p_transfer_organization_id => NULL,
              p_transaction_forward_flow_rec  => NULL,
              p_transaction_reverse_flow_rec  => NULL,
              p_unit_price            => NULL,
              p_prior_unit_price      => NULL,
              p_lcm_flag              => 'N',
              x_rcv_event             => l_rcv_event );

    display_rcv_rev_type(l_rcv_event,lstr);
    debug(lstr);
    debug('  x_return_status    : '||x_return_status);
    debug('  x_msg_count        : '||x_msg_count);
    debug('  x_msg_data         : '||x_msg_data);

    -- In the case of encumbrance reversals, the quantity to unencumber
    --   may turn out to be zero if the quantity delivered is greater than the quantity
    --   ordered. In such a situation, we should not error out the event.
    IF x_return_status = FND_API.g_ret_sts_success THEN
      NULL;
    ELSIF x_return_status <> 'W' THEN
      l_api_message := 'EXCEPTION:'||lstr;
      debug(l_api_message );
      x_msg_data  := l_api_message;
      x_msg_count := x_msg_count + 1;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  ELSE
    l_stmt_num := 55 ;
    debug(l_stmt_num);
  END IF;  /* l_encumbrance_flag = 'Y' */

 /*******************************************************
  Step 2  Getting Encumbrance Type ID
  ****************************************************** */
  BEGIN
    l_stmt_num := 60;
    debug(l_stmt_num);

    SELECT g2.ENCUMBRANCE_TYPE_ID
    INTO l_encumbrance_type_id  /* Out parameter*/
    FROM GL_ENCUMBRANCE_TYPES g2
    WHERE g2.encumbrance_type_key = 'Obligation';

    debug('  l_encumbrance_type_id:'||l_encumbrance_type_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_api_message := 'EXCEPTION ENCUMBRANCE_TYPE_ID FROM GL_ENCUMBRANCE_TYPES NOT FOUND';
    debug(l_stmt_num||':'||l_api_message);
  WHEN OTHERS THEN
    l_api_message := 'EXCEPTION '||SQLERRM;
    debug(l_stmt_num||':'||l_api_message);
    x_msg_data := l_api_message;
    RAISE FND_API.g_exc_unexpected_error;
  END;

  /*******************************************************
  Step 3 Encumbrance Amount Computation Logic
  *******************************************************/
  -- Document Currency
  l_stmt_num := 70;
  debug(l_stmt_num);
  BEGIN
    SELECT
      CURRENCY_CODE,
      MINIMUM_ACCOUNTABLE_UNIT,
      PRECISION
    INTO
      l_curreny_code,
      l_min_acct_unit_doc,
      l_precision_doc
    FROM
      FND_CURRENCIES
    WHERE
      CURRENCY_CODE =l_rcv_event.currency_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_api_message := l_stmt_num||':EXCEPTION: CURRENCY ISSUE l_rcv_event.currency_code:'||l_rcv_event.currency_code;
      debug(l_api_message);
      x_msg_data  := l_api_message;
      x_msg_count := x_msg_count + 1;
      RAISE FND_API.g_exc_unexpected_error;
  END;

  -- Functional Currency
  BEGIN
    l_stmt_num := 80;
    debug(l_stmt_num||':COA - BASE_CURRENCY');
    SELECT nvl(chart_of_accounts_id, 0),
          currency_code
    INTO   l_chart_of_accounts_id,
         l_curreny_code_func
    FROM   GL_SETS_OF_BOOKS
    WHERE  set_of_books_id = l_rcv_event.set_of_books_id;

    debug('  l_chart_of_accounts_id:'||l_chart_of_accounts_id||';l_curreny_code_func:'||l_curreny_code_func);

    l_stmt_num := 90 ;
    debug(l_stmt_num||':MINUMUM_ACCOUTABLE_UNIT - PRECISION');
    SELECT
      MINIMUM_ACCOUNTABLE_UNIT,
      PRECISION
    INTO
      l_min_acct_unit_func,
      l_precision_func
    FROM
      FND_CURRENCIES
    WHERE
      CURRENCY_CODE = l_curreny_code_func;
    debug('  l_min_acct_unit_func:'||l_min_acct_unit_func||';l_precision_func:'||l_precision_func);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_api_message := l_stmt_num||'EXCEPTION base currency issue';
      debug(l_api_message);
      x_msg_data  := l_api_message;
      x_msg_count := x_msg_count + 1;
      RAISE FND_API.g_exc_unexpected_error;
  END;

  -- Populate the Accounting Structure
  -- Entered_Cr
  l_stmt_num := 100;
  debug(l_stmt_num);

/*Adding Non Recoverable Tax to Price/amount to get final accounted/entered amount*/
  IF (l_rcv_event.unit_price IS NULL) THEN
    l_rcv_event.TRANSACTION_AMOUNT := l_rcv_event.TRANSACTION_AMOUNT + nvl(l_rcv_event.TRANSACTION_AMOUNT*l_rcv_event.unit_nr_tax,0);
    l_entered_cr        := l_rcv_event.TRANSACTION_AMOUNT ;
  ELSE
    l_rcv_event.UNIT_PRICE := l_rcv_event.UNIT_PRICE + nvl(l_rcv_event.unit_nr_tax,0) ;
    l_rcv_event.PRIOR_UNIT_PRICE := l_rcv_event.PRIOR_UNIT_PRICE + nvl(l_rcv_event.prior_nr_tax,0);

    l_entered_cr        := l_rcv_event.source_doc_quantity * (l_rcv_event.UNIT_PRICE) ;
    l_prior_entered_cr  := l_rcv_event.source_doc_quantity * (l_rcv_event.PRIOR_UNIT_PRICE );
  END IF;

  -- Accounted_Dr, Accounted_Nr_Tax, Accounted_Rec_Tax
  -- Use Document Currency Precision/MAU to round before doing currency conversion
  l_stmt_num := 110;
  debug(l_stmt_num);
  IF ( l_min_acct_unit_doc IS NOT NULL ) THEN
    l_entered_cr        := ROUND (l_entered_cr / l_min_acct_unit_doc)
	                       * l_min_acct_unit_doc;
    IF ( l_rcv_event.UNIT_PRICE IS NULL ) THEN
      l_accounted_cr := ROUND (l_rcv_event.TRANSACTION_AMOUNT/l_min_acct_unit_doc)
	                    * l_min_acct_unit_doc
						* l_rcv_event.CURRENCY_CONVERSION_RATE;
    ELSE
      l_accounted_cr := ROUND (l_rcv_event.source_doc_quantity *  l_rcv_event.UNIT_PRICE/l_min_acct_unit_doc)
	                    * l_min_acct_unit_doc
	                    * l_rcv_event.CURRENCY_CONVERSION_RATE;
    END IF; -- UNIT_PRICE NULL
  ELSE
    l_entered_cr        := ROUND (l_entered_cr, l_precision_doc);
    -- ACCOUNTED_CR
    IF ( l_rcv_event.UNIT_PRICE IS NULL ) THEN
      l_accounted_cr := ROUND (l_rcv_event.TRANSACTION_AMOUNT, l_precision_doc)
	                    * l_rcv_event.CURRENCY_CONVERSION_RATE;
    ELSE
      l_accounted_cr := ROUND (l_rcv_event.source_doc_quantity *  l_rcv_event.UNIT_PRICE, l_precision_doc)
	                    * l_rcv_event.CURRENCY_CONVERSION_RATE;
    END IF;
  END IF; -- l_min_acct_unit_doc IS NOT NULL

  -- ACCOUNTED_CR, Entered_CR, NR_Tax, Rec_Tax
  -- Use Functional Currency to Round the amounts obtained above.
  l_stmt_num := 120;
  debug(l_stmt_num);
  IF ( l_min_acct_unit_func IS NOT NULL ) THEN
    l_accounted_cr      := ROUND (l_accounted_cr / l_min_acct_unit_func) * l_min_acct_unit_func;
  ELSE
    l_accounted_cr      := ROUND (l_accounted_cr, l_precision_func);
  END IF;

  l_stmt_num := 130;
  debug(l_stmt_num);

  /*Assigning value to LOCAL parameter*/
  l_encumbrance_amount	  := l_accounted_cr;
  l_encumbrance_quantity  := l_rcv_event.primary_quantity;
  l_encumbrance_ccid      := nvl(l_rcv_event.credit_account_id,l_rcv_event.debit_account_id);

  /*Assigning value to OUT parameter*/

  x_encumbrance_amount     := ABS(l_accounted_cr)   ; /*Ensuring that abs value will be returned*/
  x_encumbrance_quantity   := l_rcv_event.primary_quantity ;


  x_encumbrance_quantity   := Get_Transaction_Quantity
                                (p_rcv_trx_id => p_receiving_transaction_id
                                ,p_rcv_qty    => x_encumbrance_quantity);

  x_encumbrance_quantity   := ABS(x_encumbrance_quantity); -- As per design always unsigned


  x_encumbrance_type_id    := l_encumbrance_type_id;

  /* For return to recieving txn l_rcv_event.credit_account_id will be null and encumbrance account
     will be stamped in l_rcv_event.debit_account_id */
  x_encumbrance_ccid       :=nvl(l_rcv_event.credit_account_id,l_rcv_event.debit_account_id);


  debug(' x_encumbrance_amount   :'||x_encumbrance_amount );
  debug(' x_encumbrance_quantity :'||x_encumbrance_quantity );
  debug(' x_encumbrance_type_id  :'||x_encumbrance_type_id );
  debug(' x_encumbrance_ccid     :'||x_encumbrance_ccid );
  debug(' x_return_status        :'||x_return_status);
  debug(' x_msg_count            :'||x_msg_count);
  debug(' x_msg_data             :'||x_msg_data);
  debug('Get_Encumbrance_Data -');

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO GET_ENCUMBRANCE_DATA_PVT;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );
    debug('UNEXPECTED EXCEPTION GET_ENCUMBRANCE_DATA : '||l_stmt_num||' : '||x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO GET_ENCUMBRANCE_DATA_PVT;
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );
    debug('OTHERS EXCEPTION GET_ENCUMBRANCE_DATA : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
END Get_Encumbrance_Data;

PROCEDURE get_account
(p_wip_entity_id      IN   NUMBER,
 p_item_id            IN   NUMBER  DEFAULT NULL,
 p_account_name       IN   VARCHAR2,
 p_api_version        IN   NUMBER  DEFAULT 1,
 x_acct               OUT  NOCOPY  NUMBER,
 x_return_status      OUT  NOCOPY  VARCHAR2,
 x_msg_count          OUT  NOCOPY  NUMBER,
 x_msg_data           OUT  NOCOPY  VARCHAR2)
IS
  CURSOR c(p_wip_entity_id IN NUMBER) IS
  SELECT  we.entity_type                 entity_type
  ,       wac.class_code                 class_code
  ,       wac.class_type                 class_type
  ,       wac.material_account           material_account
  ,       wac.material_variance_account  material_variance_account
  ,       wac.resource_account           resource_account
  ,       wac.outside_processing_account outside_processing_account
  ,       wac.overhead_account           overhead_account
  ,       wac.encumbrance_account        wac_encumbrance_account
  ,       msi.encumbrance_account        msi_encumbrance_account
  ,       mp.encumbrance_account         mp_encumbrance_account
   FROM wip_entities           we
   ,    wip_discrete_jobs      wdj
   ,    wip_accounting_classes wac
   ,    mtl_system_items       msi
   ,    mtl_parameters         mp
  WHERE we.wip_entity_id         = p_wip_entity_id
    AND we.wip_entity_id         = wdj.wip_entity_id
    AND wac.organization_id      = wdj.organization_id
    AND wac.class_code           = wdj.class_code
    AND msi.inventory_item_id(+) = NVL(p_item_id,-9999)
    AND msi.organization_id(+)   = wdj.organization_id
    AND wdj.organization_id      = mp.organization_id;
  l_rec         c%ROWTYPE;
  l_no_row      VARCHAR2(1) := 'N';
  no_input      EXCEPTION;
  account_name  EXCEPTION;
  c_no_row      EXCEPTION;
  acct_null     EXCEPTION;
BEGIN
  debug('get_account +');
  debug('  p_wip_entity_id  : '||p_wip_entity_id );
  debug('  p_account_name   : '||p_account_name  );
  debug('  p_item_id        : '||p_item_id       );

  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;

  IF p_wip_entity_id IS NULL THEN
    RAISE no_input;
  END IF;

  debug('10');
  IF p_account_name NOT IN ('ENCUMBRANCE',
                        'MATERIAL',
                        'MATERIAL_VARIANCE',
                        'RESOURCE',
                        'OSP',
                        'OVERHEAD')
  THEN
    RAISE account_name;
  END IF;

  debug('20');
  OPEN  c(p_wip_entity_id => p_wip_entity_id);
  FETCH c INTO l_rec;
  IF c%NOTFOUND THEN
    l_no_row := 'Y';
  END IF;
  CLOSE c;

  IF l_no_row = 'Y' THEN
    RAISE c_no_row;
  END IF;

  debug('30');
  IF    p_account_name = 'ENCUMBRANCE'      THEN

    IF     l_rec.wac_encumbrance_account IS NOT NULL  THEN
      debug('  Encumbrance account selected WAC');
      x_acct  := l_rec.wac_encumbrance_account;
    ELSIF  l_rec.msi_encumbrance_account IS NOT NULL  THEN
      debug('  Encumbrance account selected MSI');
      x_acct  := l_rec.msi_encumbrance_account;
    ELSE
      debug('  Encumbrance account selected INV ORG');
      x_acct  := l_rec.mp_encumbrance_account;
    END IF;

  ELSIF p_account_name = 'MATERIAL'          THEN
    debug('  Material Account');
    x_acct :=  l_rec.material_account;
  ELSIF p_account_name = 'MATERIAL_VARIANCE' THEN
    debug('  Material Variance Account');
    x_acct :=  l_rec.material_variance_account;
  ELSIF p_account_name = 'RESOURCE'          THEN
    x_acct :=  l_rec.resource_account;
  ELSIF p_account_name = 'OSP'               THEN
    debug('  OSP Account');
    x_acct :=  l_rec.outside_processing_account;
  ELSE
    debug('  Overhead Account');
    x_acct :=  l_rec.overhead_account;
  END IF;

  IF x_acct IS NULL THEN
    RAISE acct_null;
  END IF;

  debug('  x_acct           : '||x_acct);
  debug('  x_return_status  : '||x_return_status);
  debug('  x_msg_count      : '||x_msg_count);
  debug('  x_msg_data       : '||x_msg_data);
  debug('get_account -');
EXCEPTION
  WHEN no_input THEN
    x_msg_data := 'EXCEPTION NO_INPUTS in GET_ACCOUNT p_wip_entity_id :'||p_wip_entity_id;
    x_msg_count:= x_msg_count + 1;
    debug(x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_acct := NULL;
  WHEN account_name THEN
    FND_MESSAGE.SET_NAME( 'BOM', 'CST_ACCOUNT_UNDEFINED' );
    FND_MESSAGE.SET_TOKEN( 'ACCOUNT', p_account_name);
    FND_MSG_PUB.ADD;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_acct := NULL;
    debug('EXCEPTION account_name '||p_account_name||' in GET_ACCOUNT');
  WHEN c_no_row THEN
    x_msg_data := 'EXCEPTION c_no_row in GET_ACCOUNT p_wip_entity_id :'||p_wip_entity_id;
    x_msg_count:= x_msg_count + 1;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_acct := NULL;
    debug(x_msg_data);
  WHEN acct_null THEN
    FND_MESSAGE.SET_NAME( 'BOM'     , 'CST_NO_ACCOUNT_FOUND' );
    FND_MESSAGE.SET_TOKEN( 'ID'     , p_wip_entity_id);
    FND_MESSAGE.SET_TOKEN( 'ACCOUNT', p_account_name);
    FND_MSG_PUB.ADD;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_acct := NULL;
    debug('EXCEPTION CST_NO_ACCOUNT_FOUND in GET_ACCOUNT  p_account_name ' || p_account_name ||' - p_wip_entity_id :'||p_wip_entity_id);
  WHEN OTHERS THEN
    x_msg_data := 'EXCEPTION OTHERS IN get_account '||SQLERRM;
    x_msg_count:= x_msg_count + 1;
    debug(x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_acct := NULL;
END;


PROCEDURE check_enc_rev_flag
(p_organization_id    IN NUMBER,
 x_enc_rev_flag       OUT  NOCOPY  VARCHAR2,
 x_return_status      OUT  NOCOPY  VARCHAR2,
 x_msg_count          OUT  NOCOPY  NUMBER,
 x_msg_data           OUT  NOCOPY  VARCHAR2)
IS
  CURSOR c(p_organization_id IN NUMBER) IS
  SELECT decode(encumbrance_reversal_flag,1,1,2)
    FROM mtl_parameters
   WHERE organization_id = p_organization_id;
  l_encumbrance_reversal_flag  NUMBER;
  l_no_org                     VARCHAR2(1) := 'N';
  l_no_org_exc                 EXCEPTION;
BEGIN
 debug('check_enc_rev_flag +');
 debug('  p_organization_id  : '||p_organization_id );

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_msg_count     := 0;

 OPEN c(p_organization_id);
 FETCH c INTO l_encumbrance_reversal_flag;
 IF c%NOTFOUND THEN
    debug(' Cursur C does not return any row' );
    l_no_org := 'Y';
 END IF;
 CLOSE c;

 IF l_no_org = 'Y' THEN
    RAISE l_no_org_exc;
 END IF;

 debug(' l_encumbrance_reversal_flag :'||l_encumbrance_reversal_flag );

 IF     l_encumbrance_reversal_flag = 1 THEN
     x_enc_rev_flag := 'Y';
 ELSIF  l_encumbrance_reversal_flag = 2 THEN
     x_enc_rev_flag := 'N';
 ELSE
     x_msg_data       := 'Error encumbrance_reversal_flag should be 1 or 2. Current value:'||
	                      l_encumbrance_reversal_flag;
     debug(x_msg_data);
     x_return_status  := FND_API.G_RET_STS_ERROR;
     x_msg_count      := x_msg_count + 1;
     x_enc_rev_flag := 'N';
 END IF;
 debug(x_enc_rev_flag);
 debug('check_enc_rev_flag -');

EXCEPTION
  WHEN l_no_org_exc THEN
    x_enc_rev_flag  := 'N';
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := 'EXCEPTION l_no_org_exc: No inventory organization :'||p_organization_id;
    debug(x_msg_data);
    x_msg_count     := x_msg_count + 1;
  WHEN OTHERS THEN
    x_enc_rev_flag  := 'N';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := 'EXCEPTION OTHERS IN check_enc_rev_flag '||SQLERRM;
    debug(x_msg_data);
    x_msg_count:= x_msg_count + 1;
    END;

END CST_eamCost_PUB;

/
