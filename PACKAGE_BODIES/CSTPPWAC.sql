--------------------------------------------------------
--  DDL for Package Body CSTPPWAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWAC" AS
/* $Header: CSTPWACB.pls 120.28.12010000.9 2009/12/15 01:32:30 anjha ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPWAC';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- PROCEDURE
--  cost_processor      Costs inventory transactions
--
procedure cost_processor(
  I_LEGAL_ENTITY        IN        NUMBER,
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_ORG_ID              IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_TXN_COST_GROUP_ID   IN        NUMBER,
  I_TXFR_COST_GROUP_ID  IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_COST_METHOD         IN        NUMBER,
  I_PROCESS_GROUP       IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_PAC_RATES_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_TXN_SRC_TYPE_ID     IN        NUMBER,
  I_FOB_POINT           IN        NUMBER,
  I_EXP_ITEM            IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_COST_HOOK_USED      IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_new_cost            NUMBER;
  l_no_update_qty       NUMBER;
  l_hook                NUMBER;
  l_interorg_rec        NUMBER;
  l_across_cgs          NUMBER;
  l_issue_qty           NUMBER;
  l_buy_qty             NUMBER;
  l_make_qty            NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.cost_processor';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.cost_processor with '||
        'I_LEGAL_ENTITY = '||I_LEGAL_ENTITY||','||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_ORG_ID = '||I_ORG_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_TXN_COST_GROUP_ID = '||I_TXN_COST_GROUP_ID||','||
        'I_TXFR_COST_GROUP_ID = '||I_TXFR_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_COST_METHOD = '||I_COST_METHOD||','||
        'I_PROCESS_GROUP = '||I_PROCESS_GROUP||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_PAC_RATES_ID = '||I_PAC_RATES_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_TXN_SRC_TYPE_ID = '||I_TXN_SRC_TYPE_ID||','||
        'I_FOB_POINT = '||I_FOB_POINT||','||
        'I_EXP_ITEM = '||I_EXP_ITEM||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_COST_HOOK_USED = '||I_COST_HOOK_USED||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_new_cost := 0;
  l_no_update_qty := 0;
  l_hook := i_cost_hook_used;
  l_interorg_rec := 0;
  l_across_cgs := 0;
  l_issue_qty := 0;
  l_buy_qty := 0;
  l_make_qty := 0;

/*
  insert_txn_history(i_pac_period_id, i_cost_group_id, i_txn_id,
                      i_process_group, i_item_id, i_qty_layer_id,
                      i_txn_qty, i_user_id, i_login_id, i_req_id,
                      i_prg_appl_id, i_prg_id, i_txn_category,
                      l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
    -- Error occured
    raise fnd_api.g_exc_unexpected_error;
  end if;
 */

  -- No need to process cost update
  if (i_txn_action_id = 24) then
    if i_cost_method = 3 then
      -- PWAC cost method
      CSTPPWAC.periodic_cost_update(
                                  i_pac_period_id,
                                  i_cost_group_id,
                                  i_cost_type_id,
                                  i_txn_id,
                                  i_cost_layer_id,
                                  i_qty_layer_id,
                                  i_item_id,
                                  i_user_id,
                                  i_login_id,
                                  i_req_id,
                                  i_prg_appl_id,
                                  i_prg_id,
                                  i_txn_category,
				  i_txn_qty,/*LCM*/
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
    else
      -- Incremental LIFO cost method
      CSTPFCHK.periodic_cost_update_hook(
                                       i_pac_period_id,
                                       i_cost_group_id,
                                       i_cost_type_id,
                                       i_txn_id,
                                       i_cost_layer_id,
                                       i_qty_layer_id,
                                       i_item_id,
                                       i_user_id,
                                       i_login_id,
                                       i_req_id,
                                       i_prg_appl_id,
                                       i_prg_id,
                                       i_txn_category,
				       i_txn_qty,/*LCM*/
                                       l_err_num,
                                       l_err_code,
                                       l_err_msg);
    end if;

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;

    /*
    -- Updating txn history table
    update_txn_history(i_pac_period_id, i_cost_group_id, i_txn_id,
                      i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                      l_err_num, l_err_code, l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;
    */

    GOTO out_arg_log;

  end if;

  -- InterOrg transfer crossing Cost Groups
  if (i_txn_cost_group_id <> i_txfr_cost_group_id) then
    l_across_cgs := 1;
  else
    l_across_cgs := 0;
  end if;


  -- 1) The Direct Interorg Receipt
  -- 2) The Intransit Shipment fob ship and processed by receiving CG
  -- 3) The Intransit Rceipt fob receipt and processed by receiving CG
  if ((i_txn_action_id = 3  and i_txn_qty > 0) or
      (i_txn_action_id = 21 and i_fob_point = 1 and i_cost_group_id = i_txfr_cost_group_id) or
      (i_txn_action_id = 12 and i_fob_point = 2 and i_cost_group_id = i_txn_cost_group_id) or
      (i_txn_action_id = 15 and i_fob_point = 1)) -- INVCONV sikhanna, no 22 as cost-derived
  then
    l_interorg_rec := 1;
  else
    l_interorg_rec := 0;
  end if;

  -- Call the Actual Cost Hook for following transactions
  -- 1) asset item
  -- 2) Cost Owned transactions
  -- 3) None WIP related transactions.
  -- Actual Cost Hook for WIP transactions is called in
  -- WIP transaction processor.
  if (i_exp_item = 0 and i_process_group = 1 and i_txn_src_type_id <> 5) then
    l_hook := CSTPPCHK.actual_cost_hook(
                                i_pac_period_id,
                                i_cost_group_id,
                                i_cost_type_id,
                                i_cost_method,
                                i_txn_id,
                                i_cost_layer_id,
                                i_qty_layer_id,
                                i_pac_rates_id,
                                i_user_id,
                                i_login_id,
                                i_req_id,
                                i_prg_appl_id,
                                i_prg_id,
                                l_err_num,
                                l_err_code,
                                l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;
  end if;

  if (l_hook = -1) then
    -- If hook is not used then proceed to compute actual cost.

    -- PAC Weighted Average costing method
    if (i_cost_method = 3) then
      l_new_cost := CSTPPWAC.compute_pwac_cost(
                                i_pac_period_id,
                                i_org_id,
                                i_cost_group_id,
                                i_cost_type_id,
                                i_txn_id,
                                i_cost_layer_id,
                                i_pac_rates_id,
                                i_item_id,
                                i_txn_qty,
                                i_txn_action_id,
                                i_txn_src_type_id,
                                l_interorg_rec,
                                l_across_cgs,
                                i_exp_flag,
                                i_user_id,
                                i_login_id,
                                i_req_id,
                                i_prg_appl_id,
                                i_prg_id,
                                i_txn_category,
                                l_err_num,
                                l_err_code,
                                l_err_msg);
    -- All other Fiscal costing method
    else
      l_new_cost := CSTPFCHK.compute_pac_cost_hook(
                                i_pac_period_id,
                                i_org_id,
                                i_cost_group_id,
                                i_cost_type_id,
                                i_txn_id,
                                i_cost_layer_id,
                                i_pac_rates_id,
                                i_item_id,
                                i_txn_qty,
                                i_txn_action_id,
                                i_txn_src_type_id,
                                l_interorg_rec,
                                l_across_cgs,
                                i_exp_flag,
                                i_user_id,
                                i_login_id,
                                i_req_id,
                                i_prg_appl_id,
                                i_prg_id,
                                i_txn_category,
                                l_err_num,
                                l_err_code,
                                l_err_msg);
    end if;

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;

  else
    -- user populated actual cost.
    l_new_cost := 1;
  end if;

  -- No need to proceed for expense items and WIP Scrap
  if (i_exp_item = 1 or i_txn_action_id = 30) then
    /*
    -- Updating txn history table
    update_txn_history(i_pac_period_id, i_cost_group_id, i_txn_id,
                      i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                      l_err_num, l_err_code, l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;
    */

    GOTO out_arg_log;

  -- 1) Sub Transfer
  -- 2) VMI Planning Transfer
  -- 3) InterOrg Transfer(within same CG or no ownership changes)
  -- 4) bug 6942050 fix: internal order shipment staging transfer
  -- 5) cost group transfer
  elsif ((i_txn_action_id = 2) or
         (i_txn_action_id = 5) or
         (i_txn_action_id = 28) or
         (i_txn_action_id = 55) or
         (i_txn_action_id in (3,21,12) and l_across_cgs = 0) or
         (i_txn_action_id = 21 and i_fob_point = 2) or
         (i_txn_action_id = 12 and i_fob_point = 1))
  then
    CSTPPWAC.sub_transfer(
                        i_pac_period_id,
                        i_org_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_pac_rates_id,
                        i_item_id,
                        i_txn_qty,
                        i_txn_action_id,
                        i_txn_src_type_id,
                        i_exp_flag,
                        l_no_update_qty,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;

  -- InterOrg Transfer across cost groups(ownership changes)
  -- INVCONV sikhanna adding 15 and 22 (as these will be across CG's only)
  elsif (i_txn_action_id in (3,21,12,15,22) and l_across_cgs = 1) then

    CSTPPWAC.interorg(  i_pac_period_id,
                        i_org_id,
                        i_cost_group_id,
                        i_txfr_cost_group_id,
                        i_cost_type_id,
                        i_cost_method,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        i_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_txn_src_type_id,
                        i_exp_flag,
                        l_interorg_rec,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;

  -- The Group 1 and 1' transactions
  elsif (i_process_group = 1) then

    if (i_txn_action_id in (31,32)) then
      l_make_qty := i_txn_qty;
    else
      l_buy_qty := i_txn_qty;
    end if;

  -- bug 2541342 : add if clause so we do not reaverage cost for
  --               group 1 txns of into expense subinventories.
  --               issue/buy/make qtys still updated to match
  --               qty adjustments when doing subtransfer out of
  --               expense subinventories for asset items.

     if (i_exp_flag = 1) then

            UPDATE cst_pac_item_costs cpic
              SET   last_update_date       = sysdate,
                    last_updated_by        = i_user_id,
                    last_update_login      = i_login_id,
                    request_id             = i_req_id,
                    program_application_id = i_prg_appl_id,
                    program_id             = i_prg_id,
                    program_update_date    = sysdate,
                    issue_quantity = issue_quantity + i_txn_qty,
                    buy_quantity   = buy_quantity + l_buy_qty,
                    make_quantity  = make_quantity + l_make_qty
            WHERE cpic.cost_layer_id = i_cost_layer_id;
     else
  -- end of bug 2541342 addition; original code follows

      CSTPPWAC.cost_owned_txns(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        i_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

      if (l_err_num <> 0) then
        -- Error occured
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if; -- end of if clause for bug 2541342


 -- The Group 2 transactions
  elsif (i_process_group = 2) then

    -- Cost Derived transactions has impact only on issue quantity
    l_issue_qty := i_txn_qty * -1;

    CSTPPWAC.cost_derived_txns(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        i_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_txn_src_type_id,
                        i_exp_flag,
                        l_no_update_qty,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;

  end if;

  /*
  -- Updating txn history table
  update_txn_history(i_pac_period_id, i_cost_group_id, i_txn_id,
                      i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                      l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
    -- Error occured
    raise fnd_api.g_exc_unexpected_error;
  end if;
  */

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.cost_processor with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'cost_processor',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
    END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END cost_processor;

-- PROCEDURE
--  cost_owned_txns
--
procedure cost_owned_txns(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_ISSUE_QTY           IN        NUMBER,
  I_BUY_QTY             IN        NUMBER,
  I_MAKE_QTY            IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_COST_METHOD         IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_txn_cost_exist      NUMBER;
  l_txn_cost            NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.cost_owned_txns';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.cost_owned_txns with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_ISSUE_QTY = '||I_ISSUE_QTY||','||
        'I_BUY_QTY = '||I_BUY_QTY||','||
        'I_MAKE_QTY = '||I_MAKE_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_COST_METHOD = '||I_COST_METHOD||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  -- PAC Weighted Average costing method
  if (i_cost_method = 3) then
    CSTPPWAC.calc_pwac_cost(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        i_txn_qty,
                        i_issue_qty,
                        i_buy_qty,
                        i_make_qty,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

  -- All other Fiscal costing method
  else
    CSTPFCHK.calc_pac_cost_hook(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        i_txn_qty,
                        i_issue_qty,
                        i_buy_qty,
                        i_make_qty,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);
  end if;

  if (l_err_num <> 0) then
    -- Error occured
    raise fnd_api.g_exc_unexpected_error;
  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.cost_owned_txns with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'cost_owned_txns',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
    END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END cost_owned_txns;

-- PROCEDURE
--  cost_derived_txns
--
procedure cost_derived_txns(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_ISSUE_QTY           IN        NUMBER,
  I_BUY_QTY             IN        NUMBER,
  I_MAKE_QTY            IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_TXN_SRC_TYPE_ID     IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_NO_UPDATE_QTY       IN        NUMBER,
  I_COST_METHOD         IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.cost_derived_txns';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.cost_derived_txns with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_ISSUE_QTY = '||I_ISSUE_QTY||','||
        'I_BUY_QTY = '||I_BUY_QTY||','||
        'I_MAKE_QTY = '||I_MAKE_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_TXN_SRC_TYPE_ID = '||I_TXN_SRC_TYPE_ID||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_NO_UPDATE_QTY = '||I_NO_UPDATE_QTY||','||
        'I_COST_METHOD = '||I_COST_METHOD||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  -- PAC Weighted Average costing method
  if (i_cost_method = 3) then
    CSTPPWAC.current_pwac_cost(
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_txn_qty,
                        i_issue_qty,
                        i_buy_qty,
                        i_make_qty,
                        i_txn_action_id,
                        i_exp_flag,
                        i_no_update_qty,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        i_txn_id,
                        i_item_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg);
  else
  -- All other Fiscal costing method
    CSTPFCHK.current_pac_cost_hook(
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_txn_qty,
                        i_issue_qty,
                        i_buy_qty,
                        i_make_qty,
                        i_txn_action_id,
                        i_exp_flag,
                        i_no_update_qty,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg);
  end if;

  if (l_err_num <> 0) then
    -- Error occured
    raise fnd_api.g_exc_unexpected_error;
  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.cost_derived_txns with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'cost_derived_txns',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END cost_derived_txns;

-- PROCEDURE
--  sub_transfer
--
procedure sub_transfer(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_ORG_ID              IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_PAC_RATES_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_TXN_SRC_TYPE_ID     IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_NO_UPDATE_QTY       IN        NUMBER,
  I_COST_METHOD         IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_exp1                NUMBER;
  l_exp2                NUMBER;
  l_from_exp            NUMBER;
  l_to_exp              NUMBER;
  l_txn_qty             NUMBER;
  l_issue_qty           NUMBER;
  l_buy_qty             NUMBER;
  l_make_qty            NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.sub_transfer';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.sub_transfer with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_ORG_ID = '||I_ORG_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_PAC_RATES_ID = '||I_PAC_RATES_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_TXN_SRC_TYPE_ID = '||I_TXN_SRC_TYPE_ID||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_NO_UPDATE_QTY = '||I_NO_UPDATE_QTY||','||
        'I_COST_METHOD = '||I_COST_METHOD||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_issue_qty := 0;
  l_buy_qty := 0;
  l_make_qty := 0;


  l_stmt_num := 10;
  select decode(asset_inventory,1,0,1)
  into l_exp1
  from mtl_secondary_inventories msi,
       mtl_material_transactions mmt
  where msi.secondary_inventory_name = mmt.subinventory_code
  and msi.organization_id = i_org_id
  and mmt.transaction_id = i_txn_id
  and mmt.organization_id = i_org_id;


  -- Intransit is always Asset
  if (i_txn_action_id in (21,12)) then
    l_exp2 := 0;
  else
    l_stmt_num := 20;
    select decode(asset_inventory,1,0,1)
    into l_exp2
    from mtl_secondary_inventories msi,
         mtl_material_transactions mmt
    where msi.secondary_inventory_name = mmt.transfer_subinventory
    and msi.organization_id = mmt.transfer_organization_id
    and mmt.transaction_id = i_txn_id
    and mmt.organization_id = i_org_id;
  end if;

  /* Changes for VMI. Adding Planning Transfer transaction */
  if (i_txn_action_id in (2,3,5,21)) then
    l_from_exp := l_exp1;
    l_to_exp := l_exp2;
  else
    l_from_exp := l_exp2;
    l_to_exp := l_exp1;
  end if;


  -- no changes necessary for asset->asset or exp->exp
  -- 1) asset->asset : no changes
  -- 2) exp->exp : no changes
  if (l_from_exp = l_to_exp) then
    GOTO out_arg_log;

  -- update issue quantity only for exp->asset or asset->exp
  -- 3) exp->asset   : increase qty
  -- 4) asset->exp   : decrease qty
  elsif ((l_from_exp = 1 and l_to_exp = 0)                              -- exp->asset
         or (l_from_exp = 0 and l_to_exp = 1 and i_txn_action_id = 12)  -- asset->expense intransit receipt
                                                                        -- added for bug #2531002
        ) then
    l_txn_qty := i_txn_qty * -1;                -- increase qty for exp->asset,
                                                -- decrease qty for asset->exp intransit receipt
    l_issue_qty := i_txn_qty;

  elsif (l_from_exp = 0 and l_to_exp = 1) then  -- asset->exp
    l_txn_qty := i_txn_qty;                     -- decrease qty
    l_issue_qty := i_txn_qty * -1;

  end if;


  l_stmt_num := 30;
  CSTPPWAC.cost_derived_txns(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        l_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_txn_src_type_id,
                        0,                        -- disable i_exp_flag
                        i_no_update_qty,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

  if (l_err_num <> 0) then
    -- Error occured
    raise fnd_api.g_exc_unexpected_error;
  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.sub_transfer with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'sub_transfer',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END sub_transfer;

-- PROCEDURE
--  interorg
--
procedure interorg(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_ORG_ID              IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_TXFR_COST_GROUP_ID  IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_COST_METHOD         IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_ISSUE_QTY           IN        NUMBER,
  I_BUY_QTY             IN        NUMBER,
  I_MAKE_QTY            IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_TXN_SRC_TYPE_ID     IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_INTERORG_REC        IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_txn_qty             NUMBER;
  l_issue_qty           NUMBER;
  l_buy_qty             NUMBER;
  l_make_qty            NUMBER;
  l_no_update_qty       NUMBER;
  l_exp1                NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.interorg';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.interorg with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_ORG_ID = '||I_ORG_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_TXFR_COST_GROUP_ID = '||I_TXFR_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_COST_METHOD = '||I_COST_METHOD||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_ISSUE_QTY = '||I_ISSUE_QTY||','||
        'I_BUY_QTY = '||I_BUY_QTY||','||
        'I_MAKE_QTY = '||I_MAKE_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_TXN_SRC_TYPE_ID = '||I_TXN_SRC_TYPE_ID||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_INTERORG_REC = '||I_INTERORG_REC||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_issue_qty := 0;
  l_buy_qty := 0;
  l_make_qty := 0;
  l_no_update_qty := 0;


  -- 1) The Intransit Shipment fob ship and processed by receiving CG
  -- 2) The Intransit Receipt fob receipt and processed by shipping CG
  -- 3) The logical transactions created for OPM - discrete transfers
  -- For above cases, it's in/out of Intransit, thus, always asset.
  if ( (i_cost_group_id = i_txfr_cost_group_id) OR (I_TXN_ACTION_ID in (15,22)) ) then
    l_exp1 := 0;

  else
    select decode(asset_inventory,1,0,1)
    into l_exp1
    from mtl_secondary_inventories msi,
         mtl_material_transactions mmt
    where msi.secondary_inventory_name = mmt.subinventory_code
    and msi.organization_id = i_org_id
    and mmt.transaction_id = i_txn_id
    and mmt.organization_id = i_org_id;

  end if;


  -- No Quantity or Cost changes for items in/out of expense sub
  if (l_exp1 = 1) then
    GOTO out_arg_log;

  -- 1) The Direct Interorg Receipt
  -- 2) The Intransit Shipment fob ship and processed by receiving CG
  -- 3) The Intransit Rceipt fob receipt and processed by receiving CG
  elsif (i_interorg_rec = 1) then

    -- reverse the sign of quantity, since shipment is processed by
    -- receiving costgroup
    if (i_txn_action_id = 21) then -- no need to reverse sign of txn act 15
      l_buy_qty := i_txn_qty * -1;
      l_txn_qty := i_txn_qty * -1;
    else
      l_buy_qty := i_txn_qty;
      l_txn_qty := i_txn_qty;
    end if;

    CSTPPWAC.cost_owned_txns(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        l_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;


  -- 1) The Direct Interorg Shipment
  -- 2) The Intransit Shipment fob ship and processed by sending CG
  -- 3) The Intransit Rceipt fob receipt and processed by sending CG
  else

    -- reverse the sign of quantity, since receipt is processed by
    -- shipping costgroup
    if (i_txn_action_id in (12,22)) then -- INVCONV sikhanna
      l_issue_qty := i_txn_qty;
      l_txn_qty := i_txn_qty * -1;
    else
      l_issue_qty := i_txn_qty * -1;
      l_txn_qty := i_txn_qty;
    end if;

    CSTPPWAC.cost_derived_txns(
                        i_pac_period_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_qty_layer_id,
                        i_item_id,
                        l_txn_qty,
                        l_issue_qty,
                        l_buy_qty,
                        l_make_qty,
                        i_txn_action_id,
                        i_txn_src_type_id,
                        i_exp_flag,
                        l_no_update_qty,
                        i_cost_method,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;


  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.interorg with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'interorg',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END interorg;

-- FUNCTION
--  compute_pwac_cost
--
function compute_pwac_cost(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_ORG_ID              IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_PAC_RATES_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_TXN_SRC_TYPE_ID     IN        NUMBER,
  I_INTERORG_REC        IN        NUMBER,
  I_ACROSS_CGS          IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
)
return integer IS
  l_ret_val             NUMBER;
  l_level               NUMBER;
  l_txn_cost_exist      NUMBER;
  l_cost_details        NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_earn_moh            NUMBER;
  l_moh_org_id          NUMBER;
  l_fob_point           NUMBER;
  l_txfr_org_id         NUMBER;

  -- Variables defined for eAM Support in PAC
  l_eam_job NUMBER;
  l_zero_cost_flag NUMBER;
  l_return_status        VARCHAR(1)  := FND_API.G_RET_STS_SUCCESS;
  l_msg_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(8000) := '';
  l_api_message          VARCHAR2(1000) := '';

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.compute_pwac_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.compute_pwac_cost with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_ORG_ID = '||I_ORG_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_PAC_RATES_ID = '||I_PAC_RATES_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_TXN_SRC_TYPE_ID = '||I_TXN_SRC_TYPE_ID||','||
        'I_INTERORG_REC = '||I_INTERORG_REC||','||
        'I_ACROSS_CGS = '||I_ACROSS_CGS||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_txn_cost_exist := 0;
  l_cost_details := 0;
  l_moh_org_id := i_org_id;

  l_stmt_num := 10;

  select count(*)
  into l_txn_cost_exist
  from mtl_pac_txn_cost_details
  where transaction_id = i_txn_id
  and cost_group_id = i_cost_group_id
  and pac_period_id = i_pac_period_id;

  if (l_txn_cost_exist > 0) then

    l_ret_val := 1;
    l_stmt_num := 20;

    INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        wip_variance, -- New Column added for BOM based WIP reqmnt
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
    SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        mptcd.cost_element_id,
        mptcd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        mptcd.inventory_item_id,
        mptcd.transaction_cost,
        mptcd.wip_variance,
        'Y',
        'N',
        SYSDATE,
	i_txn_category
    FROM  mtl_pac_txn_cost_details mptcd
    WHERE transaction_id = i_txn_id
    AND   pac_period_id  = i_pac_period_id
    AND   cost_group_id  = i_cost_group_id;

  else
    l_ret_val := 0;

    /********************************************************************
     ** Create detail rows in MTL_PAC_ACTUAL_COST_DETAILS based on     **
     ** records in CST_PAC_ITEM_COST_DETAILS.  Since we are using      **
     ** current average the actual cost, prior cost and new cost are   **
     ** all the same.                                                  **
     ** If detail rows do not exist in CST_PAC_ITEM_COST_DETAILS,      **
     ** we will insert a TL material 0 cost layer.                     **
     ********************************************************************/

    l_stmt_num := 30;

    select count(*)
    into l_cost_details
    from cst_pac_item_cost_details
    where cost_layer_id = i_cost_layer_id;



    if (l_cost_details > 0) then

        l_eam_job := 0;

        IF (I_TXN_SRC_TYPE_ID = 5) THEN  -- checking for eAM jobs

            SELECT  decode(WE.entity_type,6,1,7,1,0)
            INTO    l_eam_job
            FROM    mtl_material_transactions MMT, WIP_ENTITIES WE
            WHERE   MMT.transaction_id = i_txn_id
            AND     MMT.transaction_source_id = WE.wip_entity_id;

       END IF;

        IF (l_eam_job = 1) THEN

                l_stmt_num := 35;

          /* Check the zero cost flag for rebuildables */
          CST_Utility_PUB.get_zeroCostIssue_flag (
                p_api_version    =>        1.0,
                x_return_status  =>        l_return_status,
                x_msg_count      =>        l_msg_count,
                x_msg_data       =>        l_msg_data,
                p_txn_id         =>        i_txn_id,
                x_zero_cost_flag =>        l_zero_cost_flag
                );

          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                l_err_num := -4321;  -- Giving a number which is non-zero
                l_err_code := l_msg_count;
                l_err_msg := 'get_zeroCostIssue_flag returned unexpected error';
                RAISE fnd_api.g_exc_unexpected_error;
          END IF;

        END IF;


      l_stmt_num := 40;


      INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
      SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        decode(l_zero_cost_flag, 1, 0, cpicd.item_cost), /* changed for eAM support in PAC. Added decode to handle rebuilds */
        'N',
        'N',
        SYSDATE,
	i_txn_category
      FROM  cst_pac_item_cost_details cpicd
      WHERE cpicd.cost_layer_id = i_cost_layer_id;

    else
      l_stmt_num := 50;

      INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
      VALUES(
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        1,
        1,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        0,
        'N',
        'N',
        SYSDATE,
	i_txn_category);
    end if;

  end if;

  -- Apply material overhead to certain txns which are asset item and
  -- asset subinventory
  if ((i_exp_flag <> 1) AND
      ((i_txn_action_id = 27 and i_txn_src_type_id = 1) or -- PO receipt
       (i_txn_action_id = 1 and i_txn_src_type_id = 1)  or -- RTV
       (i_txn_action_id = 29 and i_txn_src_type_id = 1) or -- Delivery Adj
       (i_txn_action_id = 31 and i_txn_src_type_id = 5) or -- WIP completions
       (i_txn_action_id = 32 and i_txn_src_type_id = 5) or -- Assembly return
       (i_across_cgs = 1 and i_interorg_rec = 1) or  -- Across CGs and Ownership changes
       (i_txn_action_id = 6 and i_txn_src_type_id in (1, 13)))  -- Transfer to regular/Consigned
     ) then

     -- Intransit Shipment transaction for FOB Shipment has to absorb MOH from
     -- transfer_organization_id in MMT instead of organization_id
    if (i_interorg_rec = 1 and i_txn_action_id = 21) then

        l_stmt_num := 60;
        select nvl(mmt.fob_point, mip.fob_point), mmt.transfer_organization_id
        into   l_fob_point, l_txfr_org_id
        from   mtl_interorg_parameters mip, mtl_material_transactions mmt
        where  mip.from_organization_id = i_org_id
          and  mip.to_organization_id = mmt.transfer_organization_id
          and  mmt.transaction_id = i_txn_id;

        if (l_fob_point = 1) then
          l_moh_org_id := l_txfr_org_id;
        end if;

        fnd_file.put_line (fnd_file.log, 'moh org: ' || l_moh_org_id);
    end if;

    l_stmt_num := 70;
    CST_MOHRULES_PUB.apply_moh ( p_api_version     => 1.0,
                                 p_organization_id => l_moh_org_id,
                                 p_earn_moh        => l_earn_moh,
                                 p_txn_id          => i_txn_id,
                                 p_item_id         => i_item_id,
                                 x_return_status   => l_return_status,
                                 x_msg_count       => l_msg_count,
                                 x_msg_data        => l_err_msg
                               );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        -- Error occured
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_earn_moh = 1) THEN

    l_level := 1;

    l_stmt_num := 80;
    CSTPPWAC.apply_material_ovhd(
                        i_pac_period_id,
                        l_moh_org_id,
                        i_cost_group_id,
                        i_cost_type_id,
                        i_txn_id,
                        i_cost_layer_id,
                        i_pac_rates_id,
                        i_item_id,
                        i_txn_qty,
                        l_level,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
			i_txn_category,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise fnd_api.g_exc_unexpected_error;
    end if;
    l_ret_val := 1;

  end if;
  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.compute_pwac_cost with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */

  return l_ret_val;

  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'compute_pwac_cost',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
    return l_ret_val;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
    return l_ret_val;
  /* --- end of auto log --- */
END compute_pwac_cost;

-- PROCEDURE
--  apply_material_ovhd         Applying this level material overhead based
--                              on the pre-defined rates in the material
--
procedure apply_material_ovhd(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_ORG_ID              IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_PAC_RATES_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_LEVEL               IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_mpacd_mat_ovhds     NUMBER;
  l_mpcs_mat_ovhds      NUMBER;
  l_item_cost           NUMBER;
  l_res_id              NUMBER;

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.apply_material_ovhd';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.apply_material_ovhd with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_ORG_ID = '||I_ORG_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_PAC_RATES_ID = '||I_PAC_RATES_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_LEVEL = '||I_LEVEL||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID || ',' ||
	'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;

  select count(*)
  into l_mpacd_mat_ovhds
  from mtl_pac_actual_cost_details mpacd
  where transaction_id = i_txn_id
  and cost_layer_id = i_cost_layer_id
  and cost_element_id = 2
  and level_type = decode(i_level, 1,1,level_type);

  l_stmt_num := 20;

  select nvl(sum(actual_cost),0)
  into l_item_cost
  from mtl_pac_actual_cost_details mpacd
  where transaction_id = i_txn_id
  and cost_layer_id = i_cost_layer_id;

  l_stmt_num := 30;

  INSERT INTO mtl_pac_cost_subelements(
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_element_id,
        level_type,
        resource_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        actual_cost,
        user_entered)
  SELECT i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        cicd.cost_element_id,
        cicd.level_type,
        cicd.resource_id,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        decode(cicd.basis_type, 1, cicd.usage_rate_or_amount,
                                2, cicd.usage_rate_or_amount/abs(i_txn_qty),
                                5, cicd.usage_rate_or_amount * l_item_cost,
                                6, cicd.usage_rate_or_amount * cicd.basis_factor,0),
        'N'
  FROM  cst_item_cost_details cicd
  WHERE inventory_item_id = i_item_id
  AND   organization_id = i_org_id
  AND   cost_type_id = i_pac_rates_id
  AND   basis_type in (1,2,5,6)
  AND   cost_element_id = 2
  AND   level_type = decode(i_level, 1,1,level_type);

  l_stmt_num := 40;

  select count(*)
  into l_mpcs_mat_ovhds
  from mtl_pac_cost_subelements
  where transaction_id = i_txn_id
  and pac_period_id = i_pac_period_id
  and cost_group_id = i_cost_group_id
  and cost_element_id = 2
  and level_type = decode(i_level, 1,1,level_type);

  l_stmt_num := 50;

  if (l_mpcs_mat_ovhds > 0) then

    -- Material Overhead element cost already exists in MPACD,
    -- thus, add all additional material overhead.
    if (l_mpacd_mat_ovhds > 0) then

      l_stmt_num := 60;

      UPDATE mtl_pac_actual_cost_details mpacd
      SET      (last_update_date,
                     last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                actual_cost,
                transaction_costed_date) =
               (SELECT  sysdate,
                          i_user_id,
                          sysdate,
                          i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        sysdate,
                        sum(mpcs.actual_cost) + mpacd.actual_cost,
                        sysdate
                FROM mtl_pac_cost_subelements mpcs
                WHERE mpcs.transaction_id = i_txn_id
                AND   mpcs.pac_period_id  = i_pac_period_id
                AND   mpcs.cost_group_id  = i_cost_group_id
                AND   mpcs.cost_element_id = 2)
      WHERE mpacd.transaction_id = i_txn_id
      AND   mpacd.cost_group_id = i_cost_group_id
      AND   mpacd.cost_layer_id = i_cost_layer_id
      AND   mpacd.cost_element_id = 2
      AND   mpacd.level_type = 1;

    else

      l_stmt_num := 70;

      INSERT INTO mtl_pac_actual_cost_details(
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
      SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        2,
        1,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        sum(actual_cost),
        'Y',
        'N',
        SYSDATE,
	i_txn_category
      FROM  mtl_pac_cost_subelements
      WHERE transaction_id = i_txn_id
      AND   pac_period_id  = i_pac_period_id
      AND   cost_group_id  = i_cost_group_id
      AND   cost_element_id = 2;

    end if;
  end if;



    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.apply_material_ovhd with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END apply_material_ovhd;

-- PROCEDURE
--  current_pwac_cost
--
procedure current_pwac_cost(
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_ISSUE_QTY           IN        NUMBER,
  I_BUY_QTY             IN        NUMBER,
  I_MAKE_QTY            IN        NUMBER,
  I_TXN_ACTION_ID       IN        NUMBER,
  I_EXP_FLAG            IN        NUMBER,
  I_NO_UPDATE_QTY       IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.current_pwac_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.current_pwac_cost with '||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_ISSUE_QTY = '||I_ISSUE_QTY||','||
        'I_BUY_QTY = '||I_BUY_QTY||','||
        'I_MAKE_QTY = '||I_MAKE_QTY||','||
        'I_TXN_ACTION_ID = '||I_TXN_ACTION_ID||','||
        'I_EXP_FLAG = '||I_EXP_FLAG||','||
        'I_NO_UPDATE_QTY = '||I_NO_UPDATE_QTY||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  if ((i_txn_action_id = 30) or (i_no_update_qty = 1) or (i_exp_flag = 1)) then
    GOTO out_arg_log;
  else


  --  Insert quantity and balance details into PL/SQL table for each
  --  item-cost_element_id-level_type combination in mpacd.

    l_stmt_num := 10;
  FOR x IN
  (SELECT actual_cost, cost_element_id, level_type
  FROM mtl_pac_actual_cost_details mpacd
  WHERE mpacd.cost_layer_id = i_cost_layer_id
  AND   mpacd.transaction_id = i_txn_id)
  LOOP
   DECLARE
    l_index NUMBER;
    l_count NUMBER;
   BEGIN
     l_index := -1;

     -- Check if the item-cost_element_id-level_type combination exists
     IF (CSTPPINV.l_item_start_index_tbl.EXISTS (i_item_id)) THEN
       FOR l_count IN (CSTPPINV.l_item_start_index_tbl(i_item_id))..(CSTPPINV.l_item_end_index_tbl(i_item_id))
       LOOP
       IF (CSTPPINV.l_item_id_tbl(l_count) = i_item_id AND
             CSTPPINV.l_cost_element_id_tbl(l_count) = x.cost_element_id AND
                CSTPPINV.l_level_type_tbl(l_count) = x.level_type) THEN
          l_index := l_count;
       END IF;
       END LOOP;
     ELSE
             CSTPPINV.l_item_start_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
             CSTPPINV.l_item_end_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
     END IF;
     IF (l_index = -1) THEN
       -- Combination not found: Insert intp PL/SQL table
       l_index := CSTPPINV.l_item_id_tbl.COUNT + 1;
       CSTPPINV.l_item_id_tbl(l_index) := i_item_id;
       CSTPPINV.l_cost_layer_id_tbl(l_index) := i_cost_layer_id;
       CSTPPINV.l_qty_layer_id_tbl(l_index) := i_qty_layer_id;
       CSTPPINV.l_cost_element_id_tbl(l_index) := x.cost_element_id;
       CSTPPINV.l_level_type_tbl(l_index) := x.level_type;
       CSTPPINV.l_txn_category_tbl (l_index) := i_txn_category;

       CSTPPINV.l_item_balance_tbl(l_index) := x.actual_cost * i_txn_qty;
       CSTPPINV.l_make_balance_tbl(l_index) := x.actual_cost * i_make_qty;
       CSTPPINV.l_buy_balance_tbl(l_index) := x.actual_cost * i_buy_qty;

       CSTPPINV.l_item_end_index_tbl (i_item_id) := l_index;
     ELSE
       -- Combination found: Update balance in PL/SQL table.
       CSTPPINV.l_item_balance_tbl(l_index) := (x.actual_cost * i_txn_qty) + CSTPPINV.l_item_balance_tbl(l_index);
       CSTPPINV.l_make_balance_tbl(l_index) := (x.actual_cost * i_make_qty) + CSTPPINV.l_make_balance_tbl(l_index);
       CSTPPINV.l_buy_balance_tbl(l_index) := (x.actual_cost * i_buy_qty) + CSTPPINV.l_buy_balance_tbl(l_index);
     END IF;
   END;
  END LOOP;

    -- Insert/Update quantities in PL/SQL tables
    IF CSTPPINV.l_item_quantity_tbl.EXISTS (i_item_id) THEN
      CSTPPINV.l_item_quantity_tbl(i_item_id) := i_txn_qty + CSTPPINV.l_item_quantity_tbl(i_item_id);
    ELSE
      CSTPPINV.l_item_quantity_tbl(i_item_id):= i_txn_qty;
    END IF;

    IF CSTPPINV.l_make_quantity_tbl.EXISTS (i_item_id) THEN
      CSTPPINV.l_make_quantity_tbl(i_item_id) := i_make_qty + CSTPPINV.l_make_quantity_tbl(i_item_id);
    ELSE
      CSTPPINV.l_make_quantity_tbl(i_item_id):= i_make_qty;
    END IF;

    IF CSTPPINV.l_issue_quantity_tbl.EXISTS (i_item_id) THEN
      CSTPPINV.l_issue_quantity_tbl (i_item_id):= i_issue_qty + CSTPPINV.l_issue_quantity_tbl(i_item_id);
    ELSE
      CSTPPINV.l_issue_quantity_tbl(i_item_id):= i_issue_qty;
    END IF;

    IF CSTPPINV.l_buy_quantity_tbl.EXISTS (i_item_id) THEN
      CSTPPINV.l_buy_quantity_tbl (i_item_id):= i_buy_qty + CSTPPINV.l_buy_quantity_tbl(i_item_id);
    ELSE
      CSTPPINV.l_buy_quantity_tbl(i_item_id):= i_buy_qty;
    END IF;
  end if;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.current_pwac_cost with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'current_pwac_cost',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END current_pwac_cost;

-- PROCEDURE
--  calc_pwac_cost
--
procedure calc_pwac_cost(
  I_PAC_PERIOD_ID       IN        NUMBER,
  I_COST_GROUP_ID       IN        NUMBER,
  I_COST_TYPE_ID        IN        NUMBER,
  I_TXN_ID              IN        NUMBER,
  I_COST_LAYER_ID       IN        NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_ITEM_ID             IN        NUMBER,
  I_TXN_QTY             IN        NUMBER,
  I_ISSUE_QTY           IN        NUMBER,
  I_BUY_QTY             IN        NUMBER,
  I_MAKE_QTY            IN        NUMBER,
  I_USER_ID             IN        NUMBER,
  I_LOGIN_ID            IN        NUMBER,
  I_REQ_ID              IN        NUMBER,
  I_PRG_APPL_ID         IN        NUMBER,
  I_PRG_ID              IN        NUMBER,
  I_TXN_CATEGORY        IN        NUMBER,
  O_Err_Num             OUT NOCOPY        NUMBER,
  O_Err_Code            OUT NOCOPY        VARCHAR2,
  O_Err_Msg             OUT NOCOPY        VARCHAR2
) IS
  l_cur_onhand          NUMBER;
  l_cur_buy_qty         NUMBER;
  l_cur_make_qty        NUMBER;
  l_new_onhand          NUMBER;
  l_new_buy_qty         NUMBER;
  l_new_make_qty        NUMBER;

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.calc_pwac_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.calc_pwac_cost with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_ISSUE_QTY = '||I_ISSUE_QTY||','||
        'I_BUY_QTY = '||I_BUY_QTY||','||
        'I_MAKE_QTY = '||I_MAKE_QTY||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_cur_onhand := 0;
  l_cur_buy_qty := 0;
  l_cur_make_qty := 0;
  l_new_onhand := 0;
  l_new_buy_qty := 0;
  l_new_make_qty := 0;


  /********************************************************************
   ** Update mtl_pac_actual_cost_details and update the prior cost   **
   ** to the current average for the elements that exists and insert **
   ** in to mtl_pac_actual_cost_details the current average cost for **
   ** the elements that do not exist.                                **
   ********************************************************************/

  l_stmt_num := 10;

  INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
  SELECT i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        0,
        'N',
        'N',
        sysdate,
	i_txn_category
  FROM  cst_pac_item_cost_details cpicd
  WHERE cost_layer_id = i_cost_layer_id
  AND NOT EXISTS
        (SELECT        'this detail is not in mpacd already'
         FROM        mtl_pac_actual_cost_details mpacd
         WHERE        mpacd.transaction_id = i_txn_id
         AND        mpacd.cost_group_id = i_cost_group_id
         AND        mpacd.cost_layer_id = i_cost_layer_id
         AND        mpacd.cost_element_id = cpicd.cost_element_id
         AND        mpacd.level_type = cpicd.level_type);

  l_stmt_num := 20;
  FOR x IN
 (SELECT actual_cost, cost_element_id, level_type
      FROM   mtl_pac_actual_cost_details mpacd
  WHERE mpacd.cost_layer_id = i_cost_layer_id
  AND   mpacd.transaction_id = i_txn_id)
  LOOP
   DECLARE
    l_index NUMBER;
    l_count NUMBER;
   BEGIN
     l_index := -1;
     IF (CSTPPINV.l_item_start_index_tbl.EXISTS (i_item_id)) THEN   /* item already exists */
       FOR l_count IN (CSTPPINV.l_item_start_index_tbl(i_item_id))..(CSTPPINV.l_item_end_index_tbl(i_item_id))
       LOOP
       IF (CSTPPINV.l_item_id_tbl(l_count) = i_item_id AND
             CSTPPINV.l_cost_element_id_tbl(l_count) = x.cost_element_id AND
                CSTPPINV.l_level_type_tbl(l_count) = x.level_type) THEN
          l_index := l_count;
       END IF;
       END LOOP;
     ELSE							/* new item */
             CSTPPINV.l_item_start_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
             CSTPPINV.l_item_end_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
     END IF;
     IF (l_index = -1) THEN

       /*********************************************************************
          Item-cost_element-level_type combination not found: Insert into
          PL/SQL table. Quantity is maintained for each item, whereas all
          other tables are maintained for each item-cost_element-level_type
       **********************************************************************/

       l_index := CSTPPINV.l_item_id_tbl.COUNT + 1;
       CSTPPINV.l_item_id_tbl(l_index) := i_item_id;
       CSTPPINV.l_cost_layer_id_tbl(l_index) := i_cost_layer_id;
       CSTPPINV.l_qty_layer_id_tbl(l_index) := i_qty_layer_id;
       CSTPPINV.l_cost_element_id_tbl(l_index) := x.cost_element_id;
       CSTPPINV.l_level_type_tbl(l_index) := x.level_type;
       CSTPPINV.l_txn_category_tbl (l_index) := i_txn_category;

       CSTPPINV.l_item_balance_tbl(l_index) := x.actual_cost * i_txn_qty;
       CSTPPINV.l_make_balance_tbl(l_index) := x.actual_cost * i_make_qty;
       CSTPPINV.l_buy_balance_tbl(l_index) := x.actual_cost * i_buy_qty;

       CSTPPINV.l_item_end_index_tbl (i_item_id) := l_index;
     ELSE

       /*************************************************************************
         Update/Insert total quantity, make quantity, buy quantity for each item
       **************************************************************************/

       CSTPPINV.l_item_balance_tbl(l_index) := (x.actual_cost * i_txn_qty) + CSTPPINV.l_item_balance_tbl(l_index);
       CSTPPINV.l_make_balance_tbl(l_index) := (x.actual_cost * i_make_qty) + CSTPPINV.l_make_balance_tbl(l_index);
       CSTPPINV.l_buy_balance_tbl(l_index) := (x.actual_cost * i_buy_qty) + CSTPPINV.l_buy_balance_tbl(l_index);
     END IF;
   END;
  END LOOP;

  IF CSTPPINV.l_item_quantity_tbl.EXISTS (i_item_id) THEN
    CSTPPINV.l_item_quantity_tbl(i_item_id) := i_txn_qty + CSTPPINV.l_item_quantity_tbl(i_item_id);
  ELSE
    CSTPPINV.l_item_quantity_tbl(i_item_id):= i_txn_qty;
  END IF;

  IF CSTPPINV.l_make_quantity_tbl.EXISTS (i_item_id) THEN
    CSTPPINV.l_make_quantity_tbl(i_item_id) := i_make_qty + CSTPPINV.l_make_quantity_tbl(i_item_id);
  ELSE
    CSTPPINV.l_make_quantity_tbl(i_item_id):= i_make_qty;
  END IF;

  IF CSTPPINV.l_issue_quantity_tbl.EXISTS (i_item_id) THEN
    CSTPPINV.l_issue_quantity_tbl (i_item_id):= i_issue_qty + CSTPPINV.l_issue_quantity_tbl(i_item_id);
  ELSE
    CSTPPINV.l_issue_quantity_tbl(i_item_id):= i_issue_qty;
  END IF;

  IF CSTPPINV.l_buy_quantity_tbl.EXISTS (i_item_id) THEN
    CSTPPINV.l_buy_quantity_tbl (i_item_id):= i_buy_qty + CSTPPINV.l_buy_quantity_tbl(i_item_id);
  ELSE
    CSTPPINV.l_buy_quantity_tbl(i_item_id):= i_buy_qty;
  END IF;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.calc_pwac_cost with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  /* --- start of auto log --- */
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CSTPPWAC',
        p_procedure_name => 'calc_pwac_cost',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END calc_pwac_cost;

-- PROCEDURE
--  periodic_cost_update
--
PROCEDURE periodic_cost_update (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_COST_TYPE_ID        IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_COST_LAYER_ID       IN      NUMBER,
  I_QTY_LAYER_ID        IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  I_TXN_QTY             IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2)
IS
  l_value_change_flag   NUMBER;
  l_stmt_num            NUMBER;
  l_onhand              NUMBER;
  l_make_qty            NUMBER;
  l_buy_qty             NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.periodic_cost_update';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.periodic_cost_update with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_COST_TYPE_ID = '||I_COST_TYPE_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_COST_LAYER_ID = '||I_COST_LAYER_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
    /* --- end of auto log --- */

  /********************************************************************
   ** Insert into mpacd, all the elemental cost :                    **
   ** - exists in cpicd, but not exists in mptcd                     **
   ** It will use the current cost in cpicd as the new cost          **
   ********************************************************************/
  l_stmt_num := 10;

  INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        prior_cost,
        prior_buy_cost,
        prior_make_cost,
        new_cost,
        new_buy_cost,
        new_make_cost,
        variance_amount,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
  SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        decode (i_txn_category, 5, 0, 8.5, 0,2.5,0, nvl(cpicd.item_cost,0)), -- insert 0 for PCU value change
        nvl(cpicd.item_cost,0),
        nvl(cpicd.item_buy_cost,0),
        nvl(cpicd.item_make_cost,0),
        nvl(cpicd.item_cost,0),
        nvl(cpicd.item_buy_cost,0),
        nvl(cpicd.item_make_cost,0),
          0,    -- variance
        'Y',
        'N',
          sysdate,
	i_txn_category
  FROM  cst_pac_item_cost_details cpicd
  WHERE cpicd.cost_layer_id  = i_cost_layer_id
    AND not exists (
        SELECT 'not exists in mptcd'
        FROM mtl_pac_txn_cost_details mptcd
        WHERE mptcd.transaction_id = i_txn_id
          AND mptcd.pac_period_id  = i_pac_period_id
          AND mptcd.cost_group_id  = i_cost_group_id
          AND mptcd.cost_element_id = cpicd.cost_element_id
          AND mptcd.level_type = cpicd.level_type);

  /********************************************************************
   ** Insert into mpacd, all the elemental cost :                    **
   ** - exists in mptcd and cpicd                                    **
   ** - exists in mptcd but not exists in cpicd                      **
   ** New cost will be calculated based on current cost (if exists)  **
   ** and cost change in mptcd.                                      **
   ********************************************************************/
  l_stmt_num := 20;
  INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
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
        actual_cost,
        prior_cost,
        prior_buy_cost,
        prior_make_cost,
        new_cost,
        new_buy_cost,
        new_make_cost,
        variance_amount,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category,
	onhand_variance_amount)
  SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        mptcd.cost_element_id,
        mptcd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        mptcd.inventory_item_id,
        decode(mptcd.new_periodic_cost,NULL,
             decode(mptcd.percentage_change,NULL,
                  /* value change formula */
               decode(sign(cpql.layer_quantity),1,
		      decode(sign(i_txn_qty),1,
		        decode(sign(cpql.layer_quantity-i_txn_qty),-1,
			       (mptcd.value_change/i_txn_qty*cpql.layer_quantity),
                               nvl(mptcd.value_change,0)
			       ),
			    nvl(mptcd.value_change,0)),
                      nvl(mptcd.value_change,0)),
                   /* percentage change formula */
                   nvl(cpicd.item_cost,0)*(1+mptcd.percentage_change/100)),
             /* new average cost formula */
             mptcd.new_periodic_cost),
        decode (mptcd.value_change, NULL, nvl(cpicd.item_cost,0), NULL),
        decode (mptcd.value_change, NULL, nvl(cpicd.item_buy_cost,0), NULL),
        decode (mptcd.value_change, NULL, nvl(cpicd.item_make_cost,0), NULL),
        decode(mptcd.new_periodic_cost,NULL,
             decode(mptcd.percentage_change,NULL,
                  /* value change formula */
                       NULL,    /* do not populate new_cost for value_change */
                   /* percentage change formula */
                   nvl(cpicd.item_cost,0)*(1+mptcd.percentage_change/100)),
             /* new average cost formula */
             mptcd.new_periodic_cost),
        decode (mptcd.value_change, NULL, nvl(cpicd.item_buy_cost,0), NULL),
        decode (mptcd.value_change, NULL, nvl(cpicd.item_make_cost,0), NULL),
        NULL,   /* variance */
        'Y',
        'N',
        sysdate,
	i_txn_category,
	decode(mptcd.value_change,NULL,
               0,
	       decode(sign(i_txn_qty),1,
	              decode(sign(cpql.layer_quantity),1,
		             decode(sign(cpql.layer_quantity-i_txn_qty),-1,
			            mptcd.value_change*(1-cpql.layer_quantity/i_txn_qty),
				    0
			            ),
			     0
		             ),
		      0
	              )
               )
  FROM  mtl_pac_txn_cost_details mptcd,
        cst_pac_item_cost_details cpicd,
        cst_pac_quantity_layers cpql
  WHERE mptcd.transaction_id = i_txn_id
    AND mptcd.pac_period_id  = i_pac_period_id
    AND mptcd.cost_group_id  = i_cost_group_id
    AND cpql.cost_layer_id = i_cost_layer_id
    AND cpql.quantity_layer_id = i_qty_layer_id
    AND cpicd.cost_layer_id (+) = i_cost_layer_id
    AND cpicd.cost_element_id (+) = mptcd.cost_element_id
    AND cpicd.level_type (+) = mptcd.level_type;

  /****************************************************************************
    If the transaction is not a value change cost update, set the value_change
    flag to 1, otherwise set it to 0
  *****************************************************************************/

  l_stmt_num := 30;
  SELECT DECODE(MAX(value_change),NULL, 1, 0)
    INTO   l_value_change_flag
  FROM mtl_pac_txn_cost_details mptcd
  WHERE mptcd.transaction_id = i_txn_id
    AND mptcd.pac_period_id  = i_pac_period_id
    AND mptcd.cost_group_id  = i_cost_group_id;

    l_stmt_num := 40;
    SELECT nvl(total_layer_quantity,0),
           nvl(make_quantity,0),
           nvl(buy_quantity,0)
    INTO   l_onhand,
           l_make_qty,
           l_buy_qty
    FROM   cst_pac_item_costs
    WHERE  cost_layer_id = i_cost_layer_id;

   IF (l_value_change_flag <> 0)
   THEN
     -- New Cost or percent change cost update
  l_stmt_num := 50;
     DELETE FROM cst_pac_item_cost_details
     WHERE cost_layer_id = i_cost_layer_id;

     l_stmt_num := 60;
     INSERT INTO cst_pac_item_cost_details(
           cost_layer_id,
           cost_element_id,
           level_type,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           item_cost,
           item_buy_cost,
           item_make_cost,
           item_balance,
           buy_balance,
           make_balance)
    SELECT i_cost_layer_id,
           mpacd.cost_element_id,
           mpacd.level_type,
           sysdate,
           i_user_id,
           sysdate,
           i_user_id,
           i_login_id,
           i_req_id,
           i_prg_appl_id,
           i_prg_id,
           sysdate,
           mpacd.new_cost,
           mpacd.new_buy_cost,
           mpacd.new_make_cost,
           mpacd.new_cost * l_onhand,
           mpacd.new_buy_cost * l_buy_qty,
           mpacd.new_make_cost * l_make_qty
     FROM  mtl_pac_actual_cost_details mpacd
     WHERE mpacd.transaction_id = i_txn_id
     AND   mpacd.cost_group_id = i_cost_group_id
     AND   mpacd.cost_layer_id = i_cost_layer_id;

  l_stmt_num := 70;
      UPDATE cst_pac_item_costs cpic
       SET (last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            pl_material,
            pl_material_overhead,
            pl_resource,
            pl_outside_processing,
            pl_overhead,
            tl_material,
            tl_material_overhead,
            tl_resource,
            tl_outside_processing,
            tl_overhead,
            material_cost,
            material_overhead_cost,
            resource_cost,
            outside_processing_cost,
            overhead_cost,
            pl_item_cost,
            tl_item_cost,
            item_cost,
            begin_item_cost,
            item_buy_cost,
            item_make_cost,
            unburdened_cost,
            burden_cost) =
         (SELECT
            i_user_id,
            sysdate,
            i_login_id,
            i_req_id,
            i_prg_appl_id,
            i_prg_id,
            sysdate,
            SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),        -- PL_MATERIAL
            SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),        -- PL_MATERIAL_OVERHEAD
            SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),        -- PL_RESOURCE
            SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),        -- PL_OUTSIDE_PROCESSING
            SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),        -- PL_OVERHEAD
            SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),        -- TL_MATERIAL
            SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),        -- TL_MATERIAL_OVERHEAD
            SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),        -- TL_RESOURCE
            SUM(DECODE(LEVEL_TYPE ,1,DECODE(COST_ELEMENT_ID ,4,ITEM_COST,0),0)),      -- TL_OUTSIDE_PROCESSING
            SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),        -- TL_OVERHEAD
            SUM(DECODE(COST_ELEMENT_ID,1,ITEM_COST,0)),                               -- MATERIAL_COST
            SUM(DECODE(COST_ELEMENT_ID,2,ITEM_COST,0)),                               -- MATERIAL_OVERHEAD_COST
            SUM(DECODE(COST_ELEMENT_ID,3,ITEM_COST,0)),                               -- RESOURCE_COST
            SUM(DECODE(COST_ELEMENT_ID,4,ITEM_COST,0)),                               -- OUTSIDE_PROCESSING_COST
            SUM(DECODE(COST_ELEMENT_ID,5,ITEM_COST,0)),                               -- OVERHEAD_COST
            SUM(DECODE(LEVEL_TYPE,2,ITEM_COST,0)),                                    -- PL_ITEM_COST
            SUM(DECODE(LEVEL_TYPE,1,ITEM_COST,0)),                                    -- TL_ITEM_COST
            SUM(ITEM_COST),                                                           -- ITEM_COST
            DECODE(l_value_change_flag, 1, SUM(ITEM_COST), cpic.begin_item_cost),
            SUM(ITEM_BUY_COST),                                                       -- ITEM_BUY_COST
            SUM(ITEM_MAKE_COST),                                                      -- ITEM_MAKE_COST
            SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,2,ITEM_COST,0),ITEM_COST)),-- UNBURDENED_COST
            SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,1,ITEM_COST,0),0))         -- BURDEN_COST
          FROM CST_PAC_ITEM_COST_DETAILS
          WHERE COST_LAYER_ID = i_cost_layer_id
          GROUP BY COST_LAYER_ID)
      WHERE cpic.cost_layer_id = i_cost_layer_id
      AND EXISTS
            (SELECT 'there is detail cost'
             FROM   cst_pac_item_cost_details cpicd
             WHERE  cpicd.cost_layer_id = i_cost_layer_id);

     l_stmt_num := 80;
     MERGE INTO CST_PAC_PERIOD_BALANCES cppb
     USING      (SELECT   i_pac_period_id pac_period_id,
                          i_cost_group_id cost_group_id,
                          i_item_id item_id,
                          i_cost_layer_id cost_layer_id,
                          i_qty_layer_id qty_layer_id,
                          mpacd.cost_element_id cost_element_id,
                          mpacd.level_type level_type,
                          2 txn_category,  -- txn category = 2 for PCU new cost and % change
                          0 category_quantity,  -- quantity = 0 for cost update transactions
                          (l_onhand * (mpacd.actual_cost - mpacd.prior_cost)) category_balance,
                          (l_onhand * mpacd.actual_cost) period_balance,
                          l_onhand period_quantity,
                          mpacd.actual_cost
                  FROM    mtl_pac_actual_cost_details mpacd
                  WHERE   mpacd.cost_layer_id = i_cost_layer_id
                  AND     mpacd.pac_period_id = i_pac_period_id
                  AND     mpacd.cost_group_id = i_cost_group_id
                  AND     mpacd.transaction_id = i_txn_id) mpacd
      ON	  (       cppb.pac_period_id = mpacd.pac_period_id
                  AND     cppb.cost_group_id = mpacd.cost_group_id
                  AND     cppb.cost_layer_id = mpacd.cost_layer_id
                  AND     cppb.cost_element_id = mpacd.cost_element_id
                  AND     cppb.level_type = mpacd.level_type
                  AND     cppb.txn_category = mpacd.txn_category)
      WHEN NOT MATCHED THEN
                  INSERT  (PAC_PERIOD_ID,
                          COST_GROUP_ID,
                          INVENTORY_ITEM_ID,
                          COST_LAYER_ID,
                          QUANTITY_LAYER_ID,
                          COST_ELEMENT_ID,
                          LEVEL_TYPE,
                          TXN_CATEGORY,
                          TXN_CATEGORY_QTY,
                          TXN_CATEGORY_VALUE,
                          PERIOD_BALANCE,
                          PERIOD_QUANTITY,
                          PERIODIC_COST,
                          VARIANCE_AMOUNT,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_LOGIN,
                          CREATED_BY,
                          CREATION_DATE,
                          REQUEST_ID,
                          PROGRAM_APPLICATION_ID,
                          PROGRAM_ID,
                          PROGRAM_UPDATE_DATE)
                  VALUES  (mpacd.pac_period_id,
                          mpacd.cost_group_id,
                          mpacd.item_id,
                          mpacd.cost_layer_id,
                          mpacd.qty_layer_id,
                          mpacd.cost_element_id,
                          mpacd.level_type,
                          mpacd.txn_category,
                          mpacd.category_quantity,
                          mpacd.category_balance,
                          mpacd.period_balance,
                          mpacd.period_quantity,
                          mpacd.actual_cost,
                          0,
                          sysdate,
                          i_user_id,
                          i_login_id,
                          i_user_id,
                          sysdate,
                          i_req_id,
                          i_prg_appl_id,
                          i_prg_id,
                          sysdate)
             WHEN MATCHED THEN
                  UPDATE  SET
                          txn_category_qty = mpacd.category_quantity,
                          txn_category_value = txn_category_value + mpacd.category_balance,
                          period_quantity = mpacd.period_quantity,
                          period_balance = mpacd.period_balance,
                          periodic_cost = mpacd.actual_cost,
                          last_update_date = sysdate,
                          last_updated_by = i_user_id,
                          last_update_login = i_login_id,
                          request_id = i_req_id,
                          program_application_id = i_prg_appl_id,
                          program_id = i_prg_id,
                          program_update_date = sysdate;
  l_stmt_num := 85;
  UPDATE mtl_material_transactions mmt
    SET  periodic_primary_quantity = l_onhand
    WHERE mmt.transaction_id = i_txn_id;
    fnd_file.put_line(fnd_file.log,'Updated MMT with primary_quantity: ' || to_char(l_onhand));
  ELSE
     /* Value Change transaction - treated like cost owned transactions */
     l_stmt_num := 90;

     FOR x in
     (select actual_cost, cost_element_id, level_type
     from  mtl_pac_actual_cost_details mpacd
     where mpacd.cost_layer_id = i_cost_layer_id
     and   mpacd.cost_group_id = i_cost_group_id
     and   mpacd.transaction_id = i_txn_id)
     LOOP
        DECLARE
           l_index NUMBER;
           l_count NUMBER;
        BEGIN
           l_stmt_num := 100;
           l_index := -1;
           IF (CSTPPINV.l_item_start_index_tbl.EXISTS (i_item_id)) THEN   /* item already exists */
              FOR l_count IN (CSTPPINV.l_item_start_index_tbl(i_item_id))..(CSTPPINV.l_item_end_index_tbl(i_item_id))
              LOOP
              IF (CSTPPINV.l_item_id_tbl(l_count) = i_item_id AND
                    CSTPPINV.l_cost_element_id_tbl(l_count) = x.cost_element_id AND
                       CSTPPINV.l_level_type_tbl(l_count) = x.level_type) THEN
                 l_index := l_count;
              END IF;
              END LOOP;
           ELSE							/* new item */
              CSTPPINV.l_item_start_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
              CSTPPINV.l_item_end_index_tbl (i_item_id) := CSTPPINV.l_item_id_tbl.COUNT + 1;
           END IF;
           l_stmt_num := 110;
           IF (l_index = -1) THEN	/* item-cost_element-level_type combination not found: Insert*/
              l_index := CSTPPINV.l_item_id_tbl.COUNT + 1;
              CSTPPINV.l_item_id_tbl(l_index) := i_item_id;
              CSTPPINV.l_cost_layer_id_tbl(l_index) := i_cost_layer_id;
              CSTPPINV.l_qty_layer_id_tbl(l_index) := i_qty_layer_id;
              CSTPPINV.l_cost_element_id_tbl(l_index) := x.cost_element_id;
              CSTPPINV.l_level_type_tbl(l_index) := x.level_type;
              CSTPPINV.l_txn_category_tbl (l_index) := i_txn_category;

              CSTPPINV.l_item_balance_tbl(l_index) := x.actual_cost;
              CSTPPINV.l_make_balance_tbl(l_index) := 0;
              CSTPPINV.l_buy_balance_tbl(l_index) := 0;

              CSTPPINV.l_item_end_index_tbl (i_item_id) := l_index;
           ELSE					/* item-cost_element-level_type combination found: Update*/
              CSTPPINV.l_item_balance_tbl(l_index) := x.actual_cost + CSTPPINV.l_item_balance_tbl(l_index);
           END IF;
        END;
     END LOOP;

/* Fix for Bug 1970458
 * For a value change periodic update cost transaction,
 * update the primary_quantity in mmt to the layer quantity from cpql.
 * Prior to this, the quantity at the beginning of the period was being
 * used and this caused errors in the distributions.
 * The layer qty can be obtained from cst_pac_quantity_layers
 */
    l_stmt_num := 120;
    UPDATE mtl_material_transactions mmt
    SET --primary_quantity  = l_onhand,
        /* Bug 2288994. Update periodic_primary_quantity also */
        periodic_primary_quantity = l_onhand
    WHERE mmt.value_change IS NOT NULL
    AND mmt.transaction_id = i_txn_id;
    fnd_file.put_line(fnd_file.log,'Updated MMT with primary_quantity: ' || to_char(l_onhand));

 END IF;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.periodic_cost_update with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
    /* --- end of auto log --- */
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END periodic_cost_update;

/* Commented to remove the dependency on cst_pc_txn_history table
--as part of customer bug 6751847 and fp bug 5999388 performance fixes
-- PROCEDURE
--  insert_txn_history
--
PROCEDURE insert_txn_history (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_PROCESS_GROUP       IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_QTY_LAYER_ID        IN        NUMBER,
  I_TXN_QTY             IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
) IS
  l_stmt_num            NUMBER;

    -- start of auto log ---
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.insert_txn_history';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

     -- end of auto log ---
BEGIN
    --- start of auto log ---
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.insert_txn_history with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_PROCESS_GROUP = '||I_PROCESS_GROUP||','||
        'I_ITEM_ID = '||I_ITEM_ID||','||
        'I_QTY_LAYER_ID = '||I_QTY_LAYER_ID||','||
        'I_TXN_QTY = '||I_TXN_QTY||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID||','||
        'I_TXN_CATEGORY = '||I_TXN_CATEGORY
      );
    END IF;
     --- end of auto log ---

  l_stmt_num := 10;
  INSERT INTO cst_pc_txn_history (
    pac_period_id,
    cost_group_id,
    transaction_id,
    process_seq,
    process_group,
    inventory_item_id,
    txn_master_qty,
    prior_costed_master_qty,
    txn_category,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_update_login)
  (SELECT
    i_pac_period_id,
    i_cost_group_id,
    i_txn_id,
    cst_pc_txn_history_s.nextval,
    i_process_group,
    i_item_id,
    i_txn_qty,
    layer_quantity,
    i_txn_category,
    sysdate,
    i_user_id,
    sysdate,
    i_user_id,
    i_req_id,
    i_prg_appl_id,
    i_prg_id,
    SYSDATE,
    i_login_id
  FROM
    cst_pac_quantity_layers
  WHERE quantity_layer_id = i_qty_layer_id);

     --- start of auto log ---
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.insert_txn_history with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
     --- end of auto log ---
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
   --- end of auto log ---
END insert_txn_history;
*/

/*
-- Commented to remove the dependency on cst_pc_txn_history table
-- as part of customer bug 6751847 and fp bug 5999388 performance fixes
-- PROCEDURE
-- PROCEDURE
--  update_txn_history
--
PROCEDURE update_txn_history (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
) IS
  l_stmt_num            NUMBER;

    --- start of auto log ---
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.update_txn_history';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

     --- end of auto log ---
BEGIN
     --- start of auto log ---
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.update_txn_history with '||
        'I_PAC_PERIOD_ID = '||I_PAC_PERIOD_ID||','||
        'I_COST_GROUP_ID = '||I_COST_GROUP_ID||','||
        'I_TXN_ID = '||I_TXN_ID||','||
        'I_USER_ID = '||I_USER_ID||','||
        'I_LOGIN_ID = '||I_LOGIN_ID||','||
        'I_REQ_ID = '||I_REQ_ID||','||
        'I_PRG_APPL_ID = '||I_PRG_APPL_ID||','||
        'I_PRG_ID = '||I_PRG_ID
      );
    END IF;
     --- end of auto log ---

  l_stmt_num := 10;
  UPDATE cst_pc_txn_history
    SET( actual_cost,
         new_cost,
         prior_cost )=
    (SELECT
      sum(actual_cost),
      sum(new_cost),
      sum(prior_cost)
    FROM
      mtl_pac_actual_cost_details
    WHERE pac_period_id = i_pac_period_id
      and cost_group_id = i_cost_group_id
      and transaction_id = i_txn_id)
  WHERE pac_period_id = i_pac_period_id
    and cost_group_id = i_cost_group_id
    and transaction_id = i_txn_id;

     --- start of auto log ---
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.update_txn_history with '||
        'O_Err_Num = '||O_Err_Num||','||
        'O_Err_Code = '||O_Err_Code||','||
        'O_Err_Msg = '||O_Err_Msg
      );
    END IF;
     --- end of auto log ---
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
   --- end of auto log ---
END update_txn_history;
*/

-- PROCEDURE
--  insert_into_cppb
--
PROCEDURE insert_into_cppb(i_pac_period_id  IN  NUMBER,
                           i_cost_group_id  IN  NUMBER,
                           i_txn_category   IN  NUMBER,
                           i_user_id        IN  NUMBER,
                           i_login_id       IN  NUMBER,
                           i_request_id     IN  NUMBER,
                           i_prog_id        IN  NUMBER,
                           i_prog_appl_id   IN  NUMBER,
                           o_err_num        OUT NOCOPY NUMBER,
                           o_err_code       OUT NOCOPY VARCHAR2,
                           o_err_msg        OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;
  l_new_qty_tbl  CSTPPINV.t_item_quantity_tbl;
  l_new_buy_qty_tbl CSTPPINV.t_item_quantity_tbl;
  l_new_make_qty_tbl CSTPPINV.t_item_quantity_tbl;
  l_new_issue_qty_tbl CSTPPINV.t_item_quantity_tbl;
  l_category_qty_tbl CSTPPINV.t_item_quantity_tbl;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.insert_into_cppb';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.insert_into_cppb with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_txn_category = '||i_txn_category||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

  l_stmt_num := 10;
  IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
    FOR l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
    LOOP
      IF (i_txn_category = 5 OR i_txn_category = 8.5 OR
          i_txn_category = 2.5) THEN
        -- Periodic Cost Update value change
        SELECT cpic.total_layer_quantity,
               cpic.buy_quantity,
               cpic.make_quantity,
               cpic.issue_quantity,
               0             /* category_qty = 0 for cost updates */
        INTO   l_new_qty_tbl (l_index),
               l_new_buy_qty_tbl (l_index),
               l_new_make_qty_tbl (l_index),
               l_new_issue_qty_tbl (l_index),
               l_category_qty_tbl (l_index)
        FROM   cst_pac_item_costs cpic
        WHERE  cpic.cost_layer_id = CSTPPINV.l_cost_layer_id_tbl (l_index);
      ELSE
        SELECT cpic.total_layer_quantity + CSTPPINV.l_item_quantity_tbl (CSTPPINV.l_item_id_tbl(l_index)),
               cpic.buy_quantity +  CSTPPINV.l_buy_quantity_tbl (CSTPPINV.l_item_id_tbl(l_index)),
               cpic.make_quantity + CSTPPINV.l_make_quantity_tbl (CSTPPINV.l_item_id_tbl(l_index)),
               cpic.issue_quantity + CSTPPINV.l_issue_quantity_tbl (CSTPPINV.l_item_id_tbl(l_index)),
               CSTPPINV.l_item_quantity_tbl (CSTPPINV.l_item_id_tbl(l_index))
        INTO   l_new_qty_tbl (l_index),
               l_new_buy_qty_tbl (l_index),
               l_new_make_qty_tbl (l_index),
               l_new_issue_qty_tbl (l_index),
               l_category_qty_tbl (l_index)
        FROM   cst_pac_item_costs cpic
        WHERE  cpic.cost_layer_id = CSTPPINV.l_cost_layer_id_tbl (l_index);
      END IF;
    END LOOP;
  END IF;

  l_stmt_num := 20;
  FORALL l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
  MERGE INTO CST_PAC_PERIOD_BALANCES cppb
  USING      (SELECT   i_pac_period_id pac_period_id,
                       i_cost_group_id cost_group_id,
                       CSTPPINV.l_item_id_tbl(l_index) item_id,
                       CSTPPINV.l_cost_layer_id_tbl(l_index) cost_layer_id,
                       CSTPPINV.l_qty_layer_id_tbl(l_index) qty_layer_id,
                       CSTPPINV.l_cost_element_id_tbl(l_index) cost_element_id,
                       CSTPPINV.l_level_type_tbl(l_index) level_type,
                       CSTPPINV.l_txn_category_tbl(l_index) txn_category,
                       l_category_qty_tbl (l_index) category_quantity,
                       CSTPPINV.l_item_balance_tbl(l_index) category_balance
               FROM    dual) temp
   ON		(      cppb.pac_period_id = temp.pac_period_id
               AND     cppb.cost_layer_id = temp.cost_layer_id
               AND     cppb.cost_element_id = temp.cost_element_id
               AND     cppb.level_type = temp.level_type
               AND     cppb.txn_category = temp.txn_category)
   WHEN NOT MATCHED THEN
               INSERT  (pac_period_id,
                       cost_group_id,
                       inventory_item_id,
                       cost_layer_id,
                       quantity_layer_id,
                       cost_element_id,
                       level_type,
                       txn_category,
                       txn_category_qty,
                       txn_category_value,
                       last_update_date,
                       last_updated_by,
                       last_update_login,
                       created_by,
                       creation_date,
                       request_id,
                       program_application_id,
                       program_id,
                       program_update_date)
               VALUES  (temp.pac_period_id,
                       temp.cost_group_id,
                       temp.item_id,
                       temp.cost_layer_id,
                       temp.qty_layer_id,
                       temp.cost_element_id,
                       temp.level_type,
                       temp.txn_category,
                       temp.category_quantity,
                       temp.category_balance,
                       sysdate,
                       i_user_id,
                       i_login_id,
                       i_user_id,
                       sysdate,
                       i_request_id,
                       i_prog_appl_id,
                       i_prog_id,
                       sysdate)
          WHEN MATCHED THEN
               UPDATE  SET
                       txn_category_qty = txn_category_qty + temp.category_quantity,
                       txn_category_value = txn_category_value + temp.category_balance,
                       last_update_date = sysdate,
                       last_updated_by = i_user_id,
                       last_update_login = i_login_id,
                       request_id = i_request_id,
                       program_application_id = i_prog_appl_id,
                       program_id = i_prog_id,
                       program_update_date = sysdate;

  l_stmt_num := 30;
  -- Update balance of existing rows in CPICD
  FORALL l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
  UPDATE CST_PAC_ITEM_COST_DETAILS cpicd
  SET    item_balance = nvl(item_balance, 0) + CSTPPINV.l_item_balance_tbl (l_index),
         make_balance = nvl(make_balance, 0) + CSTPPINV.l_make_balance_tbl (l_index),
         buy_balance  = nvl(buy_balance, 0) + CSTPPINV.l_buy_balance_tbl (l_index),
         last_update_date = sysdate,
         last_updated_by = i_user_id,
         last_update_login = i_login_id,
         request_id = i_request_id,
         program_application_id = i_prog_appl_id,
         program_id = i_prog_id,
         program_update_date = sysdate
  WHERE  cpicd.cost_layer_id = CSTPPINV.l_cost_layer_id_tbl (l_index)
  AND    cpicd.cost_element_id = CSTPPINV.l_cost_element_id_tbl (l_index)
  AND    cpicd.level_type = CSTPPINV.l_level_type_tbl (l_index);

  l_stmt_num := 40;
  -- Insert missing cost elements into CPICD
  FORALL l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
  INSERT  INTO CST_PAC_ITEM_COST_DETAILS cpicd
               (cost_layer_id,
                cost_element_id,
                level_type,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                item_cost,
                item_buy_cost,
                item_make_cost,
                item_balance,
                make_balance,
                buy_balance)
                (SELECT CSTPPINV.l_cost_layer_id_tbl (l_index),
                        CSTPPINV.l_cost_element_id_tbl (l_index),
                        CSTPPINV.l_level_type_tbl (l_index),
                        sysdate,
                        i_user_id,
                        sysdate,
                        i_user_id,
                        i_login_id,
                        i_request_id,
                        i_prog_appl_id,
                        i_prog_id,
                        sysdate,
                        0,
                        0,
                        0,
                        CSTPPINV.l_item_balance_tbl (l_index),
                        CSTPPINV.l_make_balance_tbl (l_index),
                        CSTPPINV.l_buy_balance_tbl (l_index)
                FROM    dual
                WHERE   NOT EXISTS (SELECT 1
                                    FROM   cst_pac_item_cost_details cpicd1
                                    WHERE  cpicd1.cost_layer_id = CSTPPINV.l_cost_layer_id_tbl (l_index)
                                    AND    cpicd1.cost_element_id = CSTPPINV.l_cost_element_id_tbl (l_index)
                                    AND    cpicd1.level_type = CSTPPINV.l_level_type_tbl (l_index)));

  l_stmt_num := 50;
  /* Changing the query as per Bug5045692. Performance Fix */
  /* update quantities and balance in CPIC */
  FORALL l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
  UPDATE cst_pac_item_costs cpic
  SET   total_layer_quantity   = l_new_qty_tbl (l_index),
        issue_quantity         = l_new_issue_qty_tbl (l_index),
        buy_quantity           = l_new_buy_qty_tbl(l_index),
        make_quantity          = l_new_make_qty_tbl (l_index),
        last_update_date       = sysdate,
        last_updated_by        = i_user_id,
        request_id             = i_request_id,
        program_application_id = i_prog_appl_id,
        program_id             = i_prog_id,
        program_update_date    = sysdate,
        last_update_login      = i_login_id
  WHERE cpic.cost_layer_id     = CSTPPINV.l_cost_layer_id_tbl (l_index);

  l_stmt_num := 60;
  /* Update CPQL quantity */
  FORALL l_index IN CSTPPINV.l_item_id_tbl.FIRST..CSTPPINV.l_item_id_tbl.LAST
  UPDATE CST_PAC_QUANTITY_LAYERS cpql
  SET    (last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          layer_quantity) =
          (SELECT i_user_id,
                  sysdate,
                  i_login_id,
                  i_request_id,
                  i_prog_appl_id,
                  i_prog_id,
                  sysdate,
                  l_new_qty_tbl (l_index)
            FROM  sys.dual)
           WHERE  cpql.quantity_layer_id = CSTPPINV.l_qty_layer_id_tbl (l_index)
           AND EXISTS
          (SELECT 'there is a layer'
           FROM   cst_pac_quantity_layers cpql
           WHERE  cpql.quantity_layer_id = CSTPPINV.l_qty_layer_id_tbl (l_index));

     l_stmt_num := 70;
     /* Clear All PL/SQL tables */
     CSTPPINV.l_item_id_tbl.DELETE;
     CSTPPINV.l_cost_layer_id_tbl.DELETE;
     CSTPPINV.l_qty_layer_id_tbl.DELETE;

     CSTPPINV.l_cost_element_id_tbl.DELETE;
     CSTPPINV.l_level_type_tbl.DELETE;
     CSTPPINV.l_txn_category_tbl.DELETE;

     CSTPPINV.l_item_balance_tbl.DELETE;
     CSTPPINV.l_make_balance_tbl.DELETE;
     CSTPPINV.l_buy_balance_tbl.DELETE;

     CSTPPINV.l_item_quantity_tbl.DELETE;
     CSTPPINV.l_make_quantity_tbl.DELETE;
     CSTPPINV.l_buy_quantity_tbl.DELETE;
     CSTPPINV.l_issue_quantity_tbl.DELETE;

     CSTPPINV.l_item_start_index_tbl.DELETE;
     CSTPPINV.l_item_end_index_tbl.DELETE;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.insert_into_cppb with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END insert_into_cppb;

-- +========================================================================+
-- PROCEDURE:    PRIVATE UTILITY
-- PARAMETERS:   calc_item_periodic_cost
-- Descrition:   Called from calculate_periodic_cost with inventory_item_id
-- +========================================================================+
PROCEDURE calc_item_periodic_cost (i_pac_period_id   IN  NUMBER,
                                   i_cost_group_id   IN  NUMBER,
                                   i_cost_type_id    IN  NUMBER,
                                   i_low_level_code  IN  NUMBER,
                                   i_item_id         IN  NUMBER,
                                   i_user_id         IN  NUMBER,
                                   i_login_id        IN  NUMBER,
                                   i_request_id      IN  NUMBER,
                                   i_prog_id         IN  NUMBER,
                                   i_prog_appl_id    IN  NUMBER,
                                   o_err_num         OUT NOCOPY NUMBER,
                                   o_err_code        OUT NOCOPY VARCHAR2,
                                   o_err_msg         OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;
  l_max_txn_category NUMBER;
  TYPE t_txn_id_tbl IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.transaction_id%TYPE
         INDEX BY BINARY_INTEGER;
  TYPE t_txn_category_tbl IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.txn_category%TYPE
         INDEX BY BINARY_INTEGER;
  l_last_txn_id_tbl t_txn_id_tbl;
  l_txn_category_tbl t_txn_category_tbl;
  l_cost_layer_id_tbl CSTPPINV.t_cost_layer_id_tbl;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.calc_item_periodic_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.calc_item_periodic_cost with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_cost_type_id = '||i_cost_type_id||','||
        'i_low_level_code = '||i_low_level_code||','||
        'i_item_id = '||i_item_id||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

   -- Build temporary tables to hold the last txn id and txn category values for each cost_layer_id
   IF (i_low_level_code = -1) THEN
      -- items without completion
      l_stmt_num := 10;
      SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
      BULK    COLLECT
      INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                      FROM   mtl_pac_actual_cost_details mpacd1
                                      WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                      FROM cst_pac_period_balances cppb
                                                                     WHERE cppb.pac_period_id = i_pac_period_id
                                                                       AND cppb.cost_group_id = i_cost_group_id
                                                                       AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                      AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                      AND    mpacd1.pac_period_id     = i_pac_period_id
                                      AND    mpacd1.cost_group_id     = i_cost_group_id)
      AND     mpacd.cost_group_id = i_cost_group_id
      AND     mpacd.pac_period_id = i_pac_period_id
      AND     mpacd.inventory_item_id = i_item_id
      AND     NOT EXISTS (SELECT 1
                          FROM   cst_pac_low_level_codes cpllc
                          WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                          AND    cpllc.pac_period_id = i_pac_period_id
                          AND    cpllc.cost_group_id = i_cost_group_id);
  ELSE
      -- items with completion
      l_stmt_num := 20;

      -- get the maximum transaction category that has been processed for any item having
      -- completions till this point in time.

      SELECT  max(txn_category)
      INTO    l_max_txn_category
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.pac_period_id = i_pac_period_id
      AND     mpacd.cost_group_id = i_cost_group_id
      AND     mpacd.inventory_item_id = i_item_id
      AND     EXISTS (SELECT  1
                      FROM    cst_pac_low_level_codes cpllc
                      WHERE   cpllc.cost_group_id = i_cost_group_id
                      AND     cpllc.pac_period_id = i_pac_period_id
                      AND     cpllc.inventory_item_id = mpacd.inventory_item_id
                      AND     cpllc.low_level_code = i_low_level_code);

      IF l_sLog THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.'||l_stmt_num,'l_max_txn_category = '||l_max_txn_category);
      END IF;

      IF (l_max_txn_category = 7) THEN
         -- Rework completions. Pick only items having records with transaction
         -- category = 7 to avoid updating variance again wrongly for other cost owned
         -- transaction categories

         l_stmt_num := 25;
         SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
         BULK    COLLECT
         INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
         FROM    mtl_pac_actual_cost_details mpacd
         WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                         FROM   mtl_pac_actual_cost_details mpacd1
                                         WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                         FROM cst_pac_period_balances cppb
                                                                        WHERE cppb.pac_period_id = i_pac_period_id
                                                                          AND cppb.cost_group_id = i_cost_group_id
                                                                          AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                         AND    mpacd1.txn_category      = l_max_txn_category
                                         AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                         AND    mpacd1.pac_period_id     = i_pac_period_id
                                         AND    mpacd1.cost_group_id     = i_cost_group_id)
         AND     mpacd.cost_group_id = i_cost_group_id
         AND     mpacd.pac_period_id = i_pac_period_id
         AND     mpacd.inventory_item_id = i_item_id
         AND     EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                         AND    cpllc.low_level_code = i_low_level_code
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);
      ELSE
         -- Non rework completions

         l_stmt_num := 30;
         SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
         BULK    COLLECT
         INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
         FROM    mtl_pac_actual_cost_details mpacd
         WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                         FROM   mtl_pac_actual_cost_details mpacd1
                                         WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                         FROM cst_pac_period_balances cppb
                                                                        WHERE cppb.pac_period_id = i_pac_period_id
                                                                          AND cppb.cost_group_id = i_cost_group_id
                                                                          AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                         AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                         AND    mpacd1.pac_period_id = i_pac_period_id
                                         AND    mpacd1.cost_group_id = i_cost_group_id)
         AND     mpacd.cost_group_id = i_cost_group_id
         AND     mpacd.pac_period_id = i_pac_period_id
         AND     mpacd.inventory_item_id = i_item_id
         AND     EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                         AND    cpllc.low_level_code = i_low_level_code
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);
      END IF;
  END IF;


  /****************************************************************************
   Post variance to the last transaction in the last cost owned txn category
   processed for that item. Insert rows into mpacd for missing cost elements
  ****************************************************************************/

  l_stmt_num := 35;
  FORALL l_index IN l_cost_layer_id_tbl.FIRST..l_cost_layer_id_tbl.LAST
  UPDATE mtl_pac_actual_cost_details mpacd
  SET    variance_amount = (SELECT decode (sign(cpic.total_layer_quantity),
                                           0, cpicd.item_balance,
                                           (-1 * sign(cpicd.item_balance)), cpicd.item_balance,
                                           0)
                            FROM   cst_pac_item_costs cpic,
                                   cst_pac_item_cost_details cpicd
                            WHERE  cpic.cost_layer_id = cpicd.cost_layer_id
                            AND    cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
                            AND    cpicd.cost_element_id = mpacd.cost_element_id
                            AND    cpicd.level_type = mpacd.level_type),
         last_update_date = sysdate,
         last_updated_by = i_user_id,
         last_update_login = i_login_id,
         request_id = i_request_id,
         program_application_id = i_prog_appl_id,
         program_id = i_prog_id,
         program_update_date = sysdate
  WHERE  transaction_id = l_last_txn_id_tbl (l_index)
  AND    mpacd.cost_group_id = i_cost_group_id
  AND    mpacd.pac_period_id = i_pac_period_id
  AND    mpacd.cost_layer_id = l_cost_layer_id_tbl(l_index)
  AND    (cost_element_id, level_type) = (SELECT cost_element_id, level_type
                                          FROM   cst_pac_item_cost_details cpicd
                                          WHERE  cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
                                          AND    cpicd.cost_element_id = mpacd.cost_element_id
                                          AND    cpicd.level_type = mpacd.level_type);

  l_stmt_num := 40;
  FORALL l_index IN l_cost_layer_id_tbl.FIRST..l_cost_layer_id_tbl.LAST
  INSERT INTO mtl_pac_actual_cost_details mpacd
          (COST_GROUP_ID,
          TRANSACTION_ID,
          PAC_PERIOD_ID,
          COST_TYPE_ID,
          COST_ELEMENT_ID,
          LEVEL_TYPE,
          INVENTORY_ITEM_ID,
          COST_LAYER_ID,
          ACTUAL_COST,
          USER_ENTERED,
          INSERTION_FLAG,
          TRANSACTION_COSTED_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          VARIANCE_AMOUNT,
	  TXN_CATEGORY)
          (SELECT  i_cost_group_id,
                   l_last_txn_id_tbl (l_index),
                   i_pac_period_id,
                   i_cost_type_id,
                   cpicd.cost_element_id,
                   cpicd.level_type,
                   cpic.inventory_item_id,
                   cpic.cost_layer_id,
                   0,
                   'N',
                   'N',
                   sysdate,
                   SYSDATE,
                   i_user_id,
                   SYSDATE,
                   i_user_id,
                   i_request_id,
                   i_prog_appl_id,
                   i_prog_id,
                   SYSDATE,
                   i_login_id,
                   decode (sign(cpic.total_layer_quantity),
                           0, cpicd.item_balance,
                           (-1 * sign(cpicd.item_balance)), cpicd.item_balance,
                           0),
		   l_txn_category_tbl(l_index)
           FROM    cst_pac_item_cost_details cpicd,
                   cst_pac_item_costs cpic
           WHERE   cpicd.cost_layer_id = cpic.cost_layer_id
           AND     cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
           AND     NOT EXISTS (SELECT 1
                               FROM   mtl_pac_actual_cost_details mpacd1
                               WHERE  mpacd1.transaction_id = l_last_txn_id_tbl (l_index)
                               AND    mpacd1.cost_layer_id = cpicd.cost_layer_id
                               AND    mpacd1.cost_element_id = cpicd.cost_element_id
                               AND    mpacd1.level_type = cpicd.level_type)
                             );
  l_stmt_num := 50;

  IF (i_low_level_code = -1) THEN
       -- Items that do not have completion
       UPDATE cst_pac_item_cost_details cpicd
       SET    (last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              item_cost,
              item_buy_cost,
              item_make_cost,
              item_balance,
              buy_balance,
              make_balance) =
              (SELECT sysdate,
                      i_user_id,
                      i_login_id,
                      i_request_id,
                      i_prog_appl_id,
                      i_prog_id,
                      sysdate,
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / cpic.total_layer_quantity),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN ( SELECT cost_layer_id
				      FROM cst_pac_item_costs
				      WHERE inventory_item_id = i_item_id
					AND cost_group_id = i_cost_group_id
			 	        AND pac_period_id = i_pac_period_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id = i_pac_period_id
                     AND    cppb.cost_group_id = i_cost_group_id
                     AND    cppb.cost_layer_id = cpicd.cost_layer_id
                     AND    cppb.cost_element_id = cpicd.cost_element_id
                     AND    cppb.level_type = cpicd.level_type
                     AND    cppb.inventory_item_id = i_item_id)
      AND    NOT EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id
                         AND    cpllc.inventory_item_id = i_item_id);

       l_stmt_num := 60;
       UPDATE cst_pac_item_costs cpic
        SET (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             pl_material,
             pl_material_overhead,
             pl_resource,
             pl_outside_processing,
             pl_overhead,
             tl_material,
             tl_material_overhead,
             tl_resource,
             tl_outside_processing,
             tl_overhead,
             material_cost,
             material_overhead_cost,
             resource_cost,
             outside_processing_cost,
             overhead_cost,
             pl_item_cost,
             tl_item_cost,
             item_cost,
             item_buy_cost,
             item_make_cost,
             unburdened_cost,
             burden_cost) =
            (SELECT i_user_id,
                    sysdate,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate,
                    pl_material,
                    pl_material_overhead,
                    pl_resource,
                    pl_outside_processing,
                    pl_overhead,
                    tl_material,
                    tl_material_overhead,
                    tl_resource,
                    tl_outside_processing,
                    tl_overhead,
                    material_cost,
                    material_overhead_cost,
                    resource_cost,
                    outside_processing_cost,
                    overhead_cost,
                    pl_item_cost,
                    tl_item_cost,
                    item_cost,
                    item_buy_cost,
                    item_make_cost,
                    unburdened_cost,
                    burden_cost
              FROM  cst_pac_item_costs_v v
             WHERE  v.cost_layer_id = cpic.cost_layer_id)
        WHERE  cpic.inventory_item_id = i_item_id
	AND    cpic.cost_group_id = i_cost_group_id
	AND    cpic.pac_period_id = i_pac_period_id
        AND    EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id = i_pac_period_id
                      AND    cppb.cost_group_id = i_cost_group_id
                      AND    cppb.cost_layer_id = cpic.cost_layer_id)
        AND NOT EXISTS (SELECT 1
                        FROM   cst_pac_low_level_codes cpllc
                        WHERE  cpllc.inventory_item_id = cpic.inventory_item_id
                        AND    cpllc.pac_period_id = i_pac_period_id
                        AND    cpllc.cost_group_id = i_cost_group_id)
        AND EXISTS
             (SELECT 'there is detail cost'
              FROM   cst_pac_item_cost_details cpicd
              WHERE  cpicd.cost_layer_id = cpic.cost_layer_id);
  ELSE
    -- low_level_code <> -1; items having completion

       l_stmt_num := 70;
       UPDATE cst_pac_item_cost_details cpicd
       SET    (last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              item_cost,
              item_buy_cost,
              item_make_cost,
              item_balance,
              buy_balance,
              make_balance) =
              (SELECT sysdate,
                      i_user_id,
                      i_login_id,
                      i_request_id,
                      i_prog_appl_id,
                      i_prog_id,
                      sysdate,
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / cpic.total_layer_quantity),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN ( SELECT cost_layer_id
				      FROM cst_pac_item_costs
				      WHERE inventory_item_id = i_item_id
					AND cost_group_id = i_cost_group_id
			 	        AND pac_period_id = i_pac_period_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id = i_pac_period_id
                     AND    cppb.cost_group_id = i_cost_group_id
                     AND    cppb.cost_layer_id = cpicd.cost_layer_id
                     AND    cppb.cost_element_id = cpicd.cost_element_id
                     AND    cppb.level_type = cpicd.level_type
                     AND    cppb.inventory_item_id = i_item_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_low_level_codes cpllc
                     WHERE  cpllc.low_level_code = i_low_level_code
                     AND    cpllc.pac_period_id = i_pac_period_id
                     AND    cpllc.cost_group_id = i_cost_group_id
                     AND    cpllc.inventory_item_id = i_item_id);

       l_stmt_num := 80;
       UPDATE cst_pac_item_costs cpic
        SET (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             pl_material,
             pl_material_overhead,
             pl_resource,
             pl_outside_processing,
             pl_overhead,
             tl_material,
             tl_material_overhead,
             tl_resource,
             tl_outside_processing,
             tl_overhead,
             material_cost,
             material_overhead_cost,
             resource_cost,
             outside_processing_cost,
             overhead_cost,
             pl_item_cost,
             tl_item_cost,
             item_cost,
             item_buy_cost,
             item_make_cost,
             unburdened_cost,
             burden_cost) =
            (SELECT i_user_id,
                    sysdate,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate,
                    pl_material,
                    pl_material_overhead,
                    pl_resource,
                    pl_outside_processing,
                    pl_overhead,
                    tl_material,
                    tl_material_overhead,
                    tl_resource,
                    tl_outside_processing,
                    tl_overhead,
                    material_cost,
                    material_overhead_cost,
                    resource_cost,
                    outside_processing_cost,
                    overhead_cost,
                    pl_item_cost,
                    tl_item_cost,
                    item_cost,
                    item_buy_cost,
                    item_make_cost,
                    unburdened_cost,
                    burden_cost
              FROM  cst_pac_item_costs_v v
             WHERE  v.cost_layer_id = cpic.cost_layer_id)
        WHERE cpic.inventory_item_id = i_item_id
	AND   cpic.cost_group_id = i_cost_group_id
	AND   cpic.pac_period_id = i_pac_period_id
        AND   EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id = i_pac_period_id
                      AND    cppb.cost_group_id = i_cost_group_id
                      AND    cppb.cost_layer_id = cpic.cost_layer_id)
        AND   EXISTS (SELECT 1
                      FROM   cst_pac_low_level_codes cpllc
                      WHERE  cpllc.low_level_code = i_low_level_code
                      AND    cpllc.inventory_item_id = cpic.inventory_item_id
                      AND    cpllc.pac_period_id = i_pac_period_id
                      AND    cpllc.cost_group_id = i_cost_group_id)
        AND EXISTS
             (SELECT 'there is detail cost'
              FROM   cst_pac_item_cost_details cpicd
              WHERE  cpicd.cost_layer_id = cpic.cost_layer_id);
  END IF;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.calc_item_periodic_cost with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END calc_item_periodic_cost;

-- PROCEDURE
--  calc_periodic_cost
--
PROCEDURE calc_periodic_cost (i_pac_period_id   IN  NUMBER,
                              i_cost_group_id   IN  NUMBER,
                              i_cost_type_id    IN  NUMBER,
                              i_low_level_code  IN  NUMBER,
                              i_user_id         IN  NUMBER,
                              i_login_id        IN  NUMBER,
                              i_request_id      IN  NUMBER,
                              i_prog_id         IN  NUMBER,
                              i_prog_appl_id    IN  NUMBER,
                              o_err_num         OUT NOCOPY NUMBER,
                              o_err_code        OUT NOCOPY VARCHAR2,
                              o_err_msg         OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;
  l_max_txn_category NUMBER;
  TYPE t_txn_id_tbl IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.transaction_id%TYPE
         INDEX BY BINARY_INTEGER;
  TYPE t_txn_category_tbl IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.txn_category%TYPE
         INDEX BY BINARY_INTEGER;
  l_last_txn_id_tbl t_txn_id_tbl;
  l_txn_category_tbl t_txn_category_tbl;
  l_cost_layer_id_tbl CSTPPINV.t_cost_layer_id_tbl;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.calc_periodic_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.calc_periodic_cost with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_cost_type_id = '||i_cost_type_id||','||
        'i_low_level_code = '||i_low_level_code||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

   -- Build temporary tables to hold the last txn id and txn category values for each cost_layer_id
   IF (i_low_level_code = -1) THEN
      -- items without completion
      l_stmt_num := 10;
      SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
      BULK    COLLECT
      INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                      FROM   mtl_pac_actual_cost_details mpacd1
                                      WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                      FROM cst_pac_period_balances cppb
                                                                     WHERE cppb.pac_period_id = i_pac_period_id
                                                                       AND cppb.cost_group_id = i_cost_group_id
                                                                       AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                      AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                      AND    mpacd1.pac_period_id     = i_pac_period_id
                                      AND    mpacd1.cost_group_id     = i_cost_group_id)
      AND     mpacd.cost_group_id = i_cost_group_id
      AND     mpacd.pac_period_id = i_pac_period_id
      AND     NOT EXISTS (SELECT 1
                          FROM   cst_pac_low_level_codes cpllc
                          WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                          AND    cpllc.pac_period_id = i_pac_period_id
                          AND    cpllc.cost_group_id = i_cost_group_id);
  ELSE
      -- items with completion
      l_stmt_num := 20;

      -- get the maximum transaction category that has been processed for any item having
      -- completions till this point in time.

      SELECT  max(mpacd.txn_category)
      INTO    l_max_txn_category
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.pac_period_id = i_pac_period_id
      AND     mpacd.cost_group_id = i_cost_group_id
      AND     EXISTS (SELECT  1
                      FROM    cst_pac_low_level_codes cpllc
                      WHERE   cpllc.cost_group_id = i_cost_group_id
                      AND     cpllc.pac_period_id = i_pac_period_id
                      AND     cpllc.inventory_item_id = mpacd.inventory_item_id
                      AND     cpllc.low_level_code = i_low_level_code);

      IF l_sLog THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module||'.'||l_stmt_num,'l_max_txn_category = '||l_max_txn_category);
      END IF;

      IF (l_max_txn_category = 7) THEN
         -- Rework completions. Pick only items having records with transaction
         -- category = 7 to avoid updating variance again wrongly for other cost owned
         -- transaction categories

         l_stmt_num := 25;
         SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
         BULK    COLLECT
         INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
         FROM    mtl_pac_actual_cost_details mpacd
         WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                         FROM   mtl_pac_actual_cost_details mpacd1
                                         WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                         FROM cst_pac_period_balances cppb
                                                                        WHERE cppb.pac_period_id = i_pac_period_id
                                                                          AND cppb.cost_group_id = i_cost_group_id
                                                                          AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                         AND    mpacd1.txn_category      = l_max_txn_category
                                         AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                         AND    mpacd1.pac_period_id     = i_pac_period_id
                                         AND    mpacd1.cost_group_id     = i_cost_group_id)
         AND     mpacd.cost_group_id = i_cost_group_id
         AND     mpacd.pac_period_id = i_pac_period_id
         AND     EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                         AND    cpllc.low_level_code = i_low_level_code
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);
      ELSE
         -- Non rework completions

         l_stmt_num := 30;
         SELECT  distinct cost_layer_id, mpacd.transaction_id, mpacd.txn_category
         BULK    COLLECT
         INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl, l_txn_category_tbl
         FROM    mtl_pac_actual_cost_details mpacd
         WHERE   mpacd.transaction_id = (SELECT max(transaction_id)
                                         FROM   mtl_pac_actual_cost_details mpacd1
                                         WHERE  mpacd1.txn_category = (SELECT max(txn_category)
                                                                         FROM cst_pac_period_balances cppb
                                                                        WHERE cppb.pac_period_id = i_pac_period_id
                                                                          AND cppb.cost_group_id = i_cost_group_id
                                                                          AND cppb.cost_layer_id = mpacd.cost_layer_id)
                                         AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                         AND    mpacd1.pac_period_id = i_pac_period_id
                                         AND    mpacd1.cost_group_id = i_cost_group_id)
         AND     mpacd.cost_group_id = i_cost_group_id
         AND     mpacd.pac_period_id = i_pac_period_id
         AND     EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                         AND    cpllc.low_level_code = i_low_level_code
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);
      END IF;
  END IF;


  /****************************************************************************
   Post variance to the last transaction in the last cost owned txn category
   processed for that item. Insert rows into mpacd for missing cost elements
  ****************************************************************************/

  l_stmt_num := 35;
  FORALL l_index IN l_cost_layer_id_tbl.FIRST..l_cost_layer_id_tbl.LAST
  UPDATE mtl_pac_actual_cost_details mpacd
  SET    variance_amount = (SELECT decode (sign(cpic.total_layer_quantity),
                                           0, cpicd.item_balance,
                                           (-1 * sign(cpicd.item_balance)), cpicd.item_balance,
                                           0)
                            FROM   cst_pac_item_costs cpic,
                                   cst_pac_item_cost_details cpicd
                            WHERE  cpic.cost_layer_id = cpicd.cost_layer_id
                            AND    cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
                            AND    cpicd.cost_element_id = mpacd.cost_element_id
                            AND    cpicd.level_type = mpacd.level_type),
         last_update_date = sysdate,
         last_updated_by = i_user_id,
         last_update_login = i_login_id,
         request_id = i_request_id,
         program_application_id = i_prog_appl_id,
         program_id = i_prog_id,
         program_update_date = sysdate
  WHERE  transaction_id = l_last_txn_id_tbl (l_index)
  AND    mpacd.cost_group_id = i_cost_group_id
  AND    mpacd.pac_period_id = i_pac_period_id
  AND    mpacd.cost_layer_id = l_cost_layer_id_tbl(l_index)
  AND    (cost_element_id, level_type) = (SELECT cost_element_id, level_type
                                          FROM   cst_pac_item_cost_details cpicd
                                          WHERE  cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
                                          AND    cpicd.cost_element_id = mpacd.cost_element_id
                                          AND    cpicd.level_type = mpacd.level_type);

  l_stmt_num := 40;
  FORALL l_index IN l_cost_layer_id_tbl.FIRST..l_cost_layer_id_tbl.LAST
  INSERT INTO mtl_pac_actual_cost_details mpacd
          (COST_GROUP_ID,
          TRANSACTION_ID,
          PAC_PERIOD_ID,
          COST_TYPE_ID,
          COST_ELEMENT_ID,
          LEVEL_TYPE,
          INVENTORY_ITEM_ID,
          COST_LAYER_ID,
          ACTUAL_COST,
          USER_ENTERED,
          INSERTION_FLAG,
          TRANSACTION_COSTED_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          VARIANCE_AMOUNT,
	  TXN_CATEGORY)
          (SELECT  i_cost_group_id,
                   l_last_txn_id_tbl (l_index),
                   i_pac_period_id,
                   i_cost_type_id,
                   cpicd.cost_element_id,
                   cpicd.level_type,
                   cpic.inventory_item_id,
                   cpic.cost_layer_id,
                   0,
                   'N',
                   'N',
                   sysdate,
                   SYSDATE,
                   i_user_id,
                   SYSDATE,
                   i_user_id,
                   i_request_id,
                   i_prog_appl_id,
                   i_prog_id,
                   SYSDATE,
                   i_login_id,
                   decode (sign(cpic.total_layer_quantity),
                           0, cpicd.item_balance,
                           (-1 * sign(cpicd.item_balance)), cpicd.item_balance,
                           0),
	           l_txn_category_tbl(l_index)
           FROM    cst_pac_item_cost_details cpicd,
                   cst_pac_item_costs cpic
           WHERE   cpicd.cost_layer_id = cpic.cost_layer_id
           AND     cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
           AND     NOT EXISTS (SELECT 1
                               FROM   mtl_pac_actual_cost_details mpacd1
                               WHERE  mpacd1.transaction_id = l_last_txn_id_tbl (l_index)
                               AND    mpacd1.cost_layer_id = cpicd.cost_layer_id
                               AND    mpacd1.cost_element_id = cpicd.cost_element_id
                               AND    mpacd1.level_type = cpicd.level_type)
                             );
  l_stmt_num := 50;

  IF (i_low_level_code = -1) THEN
       -- Items that do not have completion
       UPDATE cst_pac_item_cost_details cpicd
       SET    (last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              item_cost,
              item_buy_cost,
              item_make_cost,
              item_balance,
              buy_balance,
              make_balance) =
              (SELECT sysdate,
                      i_user_id,
                      i_login_id,
                      i_request_id,
                      i_prog_appl_id,
                      i_prog_id,
                      sysdate,
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / cpic.total_layer_quantity),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN ( SELECT cost_layer_id
				      FROM cst_pac_item_costs
				      WHERE pac_period_id = i_pac_period_id
					AND cost_group_id = i_cost_group_id)
        AND  EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id = i_pac_period_id
                     AND    cppb.cost_group_id = i_cost_group_id
                     AND    cppb.cost_layer_id = cpicd.cost_layer_id
                     AND    cppb.cost_element_id = cpicd.cost_element_id
                     AND    cppb.level_type = cpicd.level_type)
      AND    NOT EXISTS (SELECT 1
			 FROM   cst_pac_low_level_codes cpllc,
                                cst_pac_item_costs cpic1
                         WHERE  cpllc.inventory_item_id = cpic1.inventory_item_id
                         AND    cpic1.cost_layer_id = cpicd.cost_layer_id
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);

       l_stmt_num := 60;
       UPDATE cst_pac_item_costs cpic
        SET (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             pl_material,
             pl_material_overhead,
             pl_resource,
             pl_outside_processing,
             pl_overhead,
             tl_material,
             tl_material_overhead,
             tl_resource,
             tl_outside_processing,
             tl_overhead,
             material_cost,
             material_overhead_cost,
             resource_cost,
             outside_processing_cost,
             overhead_cost,
             pl_item_cost,
             tl_item_cost,
             item_cost,
             item_buy_cost,
             item_make_cost,
             unburdened_cost,
             burden_cost) =
            (SELECT i_user_id,
                    sysdate,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate,
                    pl_material,
                    pl_material_overhead,
                    pl_resource,
                    pl_outside_processing,
                    pl_overhead,
                    tl_material,
                    tl_material_overhead,
                    tl_resource,
                    tl_outside_processing,
                    tl_overhead,
                    material_cost,
                    material_overhead_cost,
                    resource_cost,
                    outside_processing_cost,
                    overhead_cost,
                    pl_item_cost,
                    tl_item_cost,
                    item_cost,
                    item_buy_cost,
                    item_make_cost,
                    unburdened_cost,
                    burden_cost
              FROM  cst_pac_item_costs_v v
             WHERE  v.cost_layer_id = cpic.cost_layer_id)
        WHERE  cpic.cost_group_id = i_cost_group_id
	AND    cpic.pac_period_id = i_pac_period_id
        AND    EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id = i_pac_period_id
                      AND    cppb.cost_group_id = i_cost_group_id
                      AND    cppb.cost_layer_id = cpic.cost_layer_id)
        AND NOT EXISTS (SELECT 1
                        FROM   cst_pac_low_level_codes cpllc
                        WHERE  cpllc.inventory_item_id = cpic.inventory_item_id
                        AND    cpllc.pac_period_id = i_pac_period_id
                        AND    cpllc.cost_group_id = i_cost_group_id)
        AND EXISTS
             (SELECT 'there is detail cost'
              FROM   cst_pac_item_cost_details cpicd
              WHERE  cpicd.cost_layer_id = cpic.cost_layer_id);
  ELSE
    -- low_level_code <> -1; items having completion

       l_stmt_num := 70;
       UPDATE cst_pac_item_cost_details cpicd
       SET    (last_update_date,
              last_updated_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              item_cost,
              item_buy_cost,
              item_make_cost,
              item_balance,
              buy_balance,
              make_balance) =
              (SELECT sysdate,
                      i_user_id,
                      i_login_id,
                      i_request_id,
                      i_prog_appl_id,
                      i_prog_id,
                      sysdate,
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / cpic.total_layer_quantity),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(cpic.total_layer_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (cpic.total_layer_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN ( SELECT cost_layer_id
				      FROM cst_pac_item_costs
				      WHERE pac_period_id = i_pac_period_id
					AND cost_group_id = i_cost_group_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id = i_pac_period_id
                     AND    cppb.cost_group_id = i_cost_group_id
                     AND    cppb.cost_layer_id = cpicd.cost_layer_id
                     AND    cppb.cost_element_id = cpicd.cost_element_id
                     AND    cppb.level_type = cpicd.level_type)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_low_level_codes cpllc,
                            cst_pac_item_costs cpic1
                     WHERE  cpllc.low_level_code = i_low_level_code
                     AND    cpllc.pac_period_id = i_pac_period_id
                     AND    cpllc.cost_group_id = i_cost_group_id
                     AND    cpllc.inventory_item_id = cpic1.inventory_item_id
                     AND    cpic1.cost_layer_id = cpicd.cost_layer_id);

       l_stmt_num := 80;
       UPDATE cst_pac_item_costs cpic
        SET (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             pl_material,
             pl_material_overhead,
             pl_resource,
             pl_outside_processing,
             pl_overhead,
             tl_material,
             tl_material_overhead,
             tl_resource,
             tl_outside_processing,
             tl_overhead,
             material_cost,
             material_overhead_cost,
             resource_cost,
             outside_processing_cost,
             overhead_cost,
             pl_item_cost,
             tl_item_cost,
             item_cost,
             item_buy_cost,
             item_make_cost,
             unburdened_cost,
             burden_cost) =
            (SELECT i_user_id,
                    sysdate,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate,
                    pl_material,
                    pl_material_overhead,
                    pl_resource,
                    pl_outside_processing,
                    pl_overhead,
                    tl_material,
                    tl_material_overhead,
                    tl_resource,
                    tl_outside_processing,
                    tl_overhead,
                    material_cost,
                    material_overhead_cost,
                    resource_cost,
                    outside_processing_cost,
                    overhead_cost,
                    pl_item_cost,
                    tl_item_cost,
                    item_cost,
                    item_buy_cost,
                    item_make_cost,
                    unburdened_cost,
                    burden_cost
              FROM  cst_pac_item_costs_v v
             WHERE  v.cost_layer_id = cpic.cost_layer_id)
        WHERE cpic.cost_group_id = i_cost_group_id
	AND   cpic.pac_period_id = i_pac_period_id
        AND   EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id = i_pac_period_id
                      AND    cppb.cost_group_id = i_cost_group_id
                      AND    cppb.cost_layer_id = cpic.cost_layer_id)
        AND   EXISTS (SELECT 1
                      FROM   cst_pac_low_level_codes cpllc
                      WHERE  cpllc.low_level_code = i_low_level_code
                      AND    cpllc.inventory_item_id = cpic.inventory_item_id
                      AND    cpllc.pac_period_id = i_pac_period_id
                      AND    cpllc.cost_group_id = i_cost_group_id)
        AND EXISTS
             (SELECT 'there is detail cost'
              FROM   cst_pac_item_cost_details cpicd
              WHERE  cpicd.cost_layer_id = cpic.cost_layer_id);
  END IF;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.calc_periodic_cost with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END calc_periodic_cost;

-- PROCEDURE
--  calculate_periodic_cost
--
PROCEDURE calculate_periodic_cost (i_pac_period_id   IN  NUMBER,
                                   i_cost_group_id   IN  NUMBER,
                                   i_cost_type_id    IN  NUMBER,
                                   i_low_level_code  IN  NUMBER,
                                   i_item_id         IN  NUMBER,
                                   i_user_id         IN  NUMBER,
                                   i_login_id        IN  NUMBER,
                                   i_request_id      IN  NUMBER,
                                   i_prog_id         IN  NUMBER,
                                   i_prog_appl_id    IN  NUMBER,
                                   o_err_num         OUT NOCOPY NUMBER,
                                   o_err_code        OUT NOCOPY VARCHAR2,
                                   o_err_msg         OUT NOCOPY VARCHAR2)
IS
    l_stmt_num  NUMBER;
 /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.calculate_periodic_cost';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    l_stmt_num := 10;
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.calculate_periodic_cost with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_cost_type_id = '||i_cost_type_id||','||
        'i_low_level_code = '||i_low_level_code||','||
        'i_item_id = '||i_item_id||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

   /* The procedures calc_periodic_cost, calc_item_periodic_cost have similar logic and any change in one
      should be synchronized with similar change in the other. "calc_periodic_cost" processes all items and
      "calc_item_periodic_cost" processes for i_item_id. For performance, nvl condition is removed so that index on
      inventory_item_id is utilised when i_item_id is passed */
   IF (i_item_id  IS NULL) THEN
            l_stmt_num := 20;
            calc_periodic_cost(i_pac_period_id  => i_pac_period_id,
                               i_cost_group_id  => i_cost_group_id,
                               i_cost_type_id   => i_cost_type_id,
                               i_low_level_code => i_low_level_code,
                               i_user_id        => i_user_id,
                               i_login_id       => i_login_id,
                               i_request_id     => i_request_id,
                               i_prog_id        => i_prog_id,
                               i_prog_appl_id   => i_prog_appl_id,
                               o_err_num        => o_err_num,
                               o_err_code       => o_err_code,
                               o_err_msg        => o_err_msg);
   ELSE
            l_stmt_num := 30;
            calc_item_periodic_cost(i_pac_period_id  => i_pac_period_id,
                                    i_cost_group_id  => i_cost_group_id,
                                    i_cost_type_id   => i_cost_type_id,
                                    i_low_level_code => i_low_level_code,
             		            i_item_id        => i_item_id,
                                    i_user_id        => i_user_id,
                                    i_login_id       => i_login_id,
                                    i_request_id     => i_request_id,
                                    i_prog_id        => i_prog_id,
                                    i_prog_appl_id   => i_prog_appl_id,
                                    o_err_num        => o_err_num,
                                    o_err_code       => o_err_code,
                                    o_err_msg        => o_err_msg);
   END IF;
  /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.calculate_periodic_cost with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
END calculate_periodic_cost;

-- PROCEDURE
--  update_cppb
--
PROCEDURE update_cppb (i_pac_period_id  IN  NUMBER,
                       i_cost_group_id  IN  NUMBER,
                       i_txn_category   IN  NUMBER,
                       i_low_level_code IN  NUMBER,
                       i_user_id        IN  NUMBER,
                       i_login_id       IN  NUMBER,
                       i_request_id     IN  NUMBER,
                       i_prog_id        IN  NUMBER,
                       i_prog_appl_id   IN  NUMBER,
                       o_err_num        OUT NOCOPY NUMBER,
                       o_err_code       OUT NOCOPY VARCHAR2,
                       o_err_msg        OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.update_cppb';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.update_cppb with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_txn_category = '||i_txn_category||','||
        'i_low_level_code = '||i_low_level_code||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

 -- Update total period quantity, balance, periodic cost and variance into cppb
  IF (i_low_level_code = -2) THEN

  -- Called after group1_trx cursor, which processes both items with completion and
  -- items without completion. So we need to update cppb for all items irrespective
  -- of whether they have completions or not.

     l_stmt_num := 10;
     UPDATE CST_PAC_PERIOD_BALANCES cppb
     SET    (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             period_balance,
             period_quantity,
             periodic_cost,
             variance_amount) =
             (SELECT i_user_id,
                     sysdate,
                     i_login_id,
                     i_request_id,
                     i_prog_appl_id,
                     i_prog_id,
                     sysdate,
                     cpicd.item_balance,
                     cpic.total_layer_quantity,
                     cpicd.item_cost,
                     (SELECT  sum (nvl (mpacd.variance_amount, 0))
                       FROM   mtl_pac_actual_cost_details mpacd
                      WHERE   mpacd.txn_category      = i_txn_category
                        AND   mpacd.inventory_item_id = cppb.inventory_item_id
                        AND   mpacd.pac_period_id     = i_pac_period_id
                        AND   mpacd.cost_group_id     = i_cost_group_id
                        AND   mpacd.cost_layer_id     = cppb.cost_layer_id
                        AND   mpacd.cost_element_id   = cppb.cost_element_id
                        AND   mpacd.level_type        = cppb.level_type)
             FROM    cst_pac_item_cost_details cpicd,
                     cst_pac_item_costs cpic
             WHERE   cpic.cost_layer_id   = cpicd.cost_layer_id
             AND     cppb.cost_layer_id   = cpicd.cost_layer_id
             AND     cppb.cost_element_id = cpicd.cost_element_id
             AND     cppb.level_type      = cpicd.level_type)
     WHERE   cppb.pac_period_id = i_pac_period_id
     AND     cppb.cost_group_id = i_cost_group_id
     AND     cppb.txn_category  = i_txn_category
     AND     i_txn_category = (SELECT max (txn_category)
                               FROM   MTL_PAC_ACTUAL_COST_DETAILS
                               WHERE  pac_period_id     = i_pac_period_id
                               AND    cost_group_id     = i_cost_group_id
                               AND    inventory_item_id = cppb.inventory_item_id)
     AND     EXISTS (SELECT 1
                     FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                     WHERE cppb.cost_layer_id   = cpicd1.cost_layer_id
                     AND   cppb.cost_element_id = cpicd1.cost_element_id
                     AND   cppb.level_type      = cpicd1.level_type);

  ELSIF (i_low_level_code = -1) THEN

  -- Items without completion

     l_stmt_num := 20;
     UPDATE CST_PAC_PERIOD_BALANCES cppb
     SET    (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             period_balance,
             period_quantity,
             periodic_cost,
             variance_amount) =
             (SELECT i_user_id,
                     sysdate,
                     i_login_id,
                     i_request_id,
                     i_prog_appl_id,
                     i_prog_id,
                     sysdate,
                     cpicd.item_balance,
                     cpic.total_layer_quantity,
                     cpicd.item_cost,
                     (SELECT  sum (nvl (mpacd.variance_amount, 0))
                       FROM   mtl_pac_actual_cost_details mpacd
                      WHERE   mpacd.txn_category      = i_txn_category
                        AND   mpacd.inventory_item_id = cppb.inventory_item_id
                        AND   mpacd.pac_period_id     = i_pac_period_id
                        AND   mpacd.cost_group_id     = i_cost_group_id
                        AND   mpacd.cost_layer_id     = cppb.cost_layer_id
                        AND   mpacd.cost_element_id   = cppb.cost_element_id
                        AND   mpacd.level_type        = cppb.level_type)
             FROM    cst_pac_item_cost_details cpicd,
                     cst_pac_item_costs cpic
             WHERE   cpic.cost_layer_id   = cpicd.cost_layer_id
             AND     cppb.cost_layer_id   = cpicd.cost_layer_id
             AND     cppb.cost_element_id = cpicd.cost_element_id
             AND     cppb.level_type      = cpicd.level_type)
     WHERE   cppb.pac_period_id  = i_pac_period_id
     AND     cppb.cost_group_id  = i_cost_group_id
     AND     cppb.txn_category   = i_txn_category
     AND     i_txn_category = (SELECT max (txn_category)
                               FROM   MTL_PAC_ACTUAL_COST_DETAILS
                               WHERE  pac_period_id = i_pac_period_id
                               AND    cost_group_id = i_cost_group_id
                               AND    inventory_item_id = cppb.inventory_item_id)
     AND     EXISTS (SELECT 1
                     FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                     WHERE cppb.cost_layer_id = cpicd1.cost_layer_id
                     AND   cppb.cost_element_id = cpicd1.cost_element_id
                     AND   cppb.level_type = cpicd1.level_type)
     AND     NOT EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.inventory_item_id = cppb.inventory_item_id
                         AND    cpllc.pac_period_id = i_pac_period_id
                         AND    cpllc.cost_group_id = i_cost_group_id);
  ELSIF (i_low_level_code <> -1) THEN

  -- Items with completion

     l_stmt_num := 30;
     UPDATE  CST_PAC_PERIOD_BALANCES cppb
     SET    (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             period_balance,
             period_quantity,
             periodic_cost,
             variance_amount) =
             (SELECT i_user_id,
                     sysdate,
                     i_login_id,
                     i_request_id,
                     i_prog_appl_id,
                     i_prog_id,
                     sysdate,
                     cpicd.item_balance,
                     cpic.total_layer_quantity,
                     cpicd.item_cost,
                     (select  sum (nvl (mpacd.variance_amount, 0))
                       from   mtl_pac_actual_cost_details mpacd
                      where   mpacd.txn_category      = i_txn_category
                        and   mpacd.inventory_item_id = cppb.inventory_item_id
                        and   mpacd.pac_period_id     = i_pac_period_id
                        and   mpacd.cost_group_id     = i_cost_group_id
                        and   mpacd.cost_layer_id     = cppb.cost_layer_id
                        and   mpacd.cost_element_id   = cppb.cost_element_id
                        and   mpacd.level_type        = cppb.level_type)
             FROM    cst_pac_item_cost_details cpicd,
                     cst_pac_item_costs cpic
             WHERE   cpic.cost_layer_id = cpicd.cost_layer_id
             AND     cppb.cost_layer_id = cpicd.cost_layer_id
             AND     cppb.cost_element_id = cpicd.cost_element_id
             AND     cppb.level_type = cpicd.level_type)
     WHERE   cppb.pac_period_id = i_pac_period_id
     AND     cppb.cost_group_id = i_cost_group_id
     AND     cppb.txn_category = i_txn_category
     AND     i_txn_category = (SELECT max (txn_category)
                               FROM   MTL_PAC_ACTUAL_COST_DETAILS
                               WHERE  pac_period_id = i_pac_period_id
                               AND    cost_group_id = i_cost_group_id
                               AND    inventory_item_id = cppb.inventory_item_id)
     AND     EXISTS (SELECT 1
                     FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                     WHERE cppb.cost_layer_id = cpicd1.cost_layer_id
                     AND   cppb.cost_element_id = cpicd1.cost_element_id
                     AND   cppb.level_type = cpicd1.level_type)
     AND     EXISTS (SELECT 1
                     FROM   cst_pac_low_level_codes cpllc
                     WHERE  cpllc.inventory_item_id = cppb.inventory_item_id
                     AND    cpllc.low_level_code = i_low_level_code
                     AND    cpllc.pac_period_id = i_pac_period_id
                     AND    cpllc.cost_group_id = i_cost_group_id);
  END IF;

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.update_cppb with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END update_cppb;

-- PROCEDURE
--  update_item_cppb, to be used in iPAC during rollup
--

PROCEDURE update_item_cppb (i_pac_period_id  IN  NUMBER,
                            i_cost_group_id  IN  NUMBER,
                            i_txn_category   IN  NUMBER,
			    i_item_id        IN  NUMBER,
                            i_user_id        IN  NUMBER,
                            i_login_id       IN  NUMBER,
                            i_request_id     IN  NUMBER,
                            i_prog_id        IN  NUMBER,
                            i_prog_appl_id   IN  NUMBER,
                            o_err_num        OUT NOCOPY NUMBER,
                            o_err_code       OUT NOCOPY VARCHAR2,
                            o_err_msg        OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.update_item_cppb';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.update_item_cppb with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_txn_category = '||i_txn_category||','||
	'i_item_id = '||i_item_id||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

     l_stmt_num := 10;
     UPDATE CST_PAC_PERIOD_BALANCES cppb
     SET    (last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             period_balance,
             period_quantity,
             periodic_cost,
             variance_amount) =
             (SELECT i_user_id,
                     sysdate,
                     i_login_id,
                     i_request_id,
                     i_prog_appl_id,
                     i_prog_id,
                     sysdate,
                     cpicd.item_balance,
                     cpic.total_layer_quantity,
                     cpicd.item_cost,
                     (SELECT  sum (nvl (mpacd.variance_amount, 0))
                       FROM   mtl_pac_actual_cost_details mpacd
                      WHERE   mpacd.txn_category      = cppb.txn_category
                        AND   mpacd.inventory_item_id = cppb.inventory_item_id
                        AND   mpacd.pac_period_id     = cppb.pac_period_id
                        AND   mpacd.cost_group_id     = cppb.cost_group_id
                        AND   mpacd.cost_layer_id     = cppb.cost_layer_id
                        AND   mpacd.cost_element_id   = cppb.cost_element_id
                        AND   mpacd.level_type        = cppb.level_type)
             FROM    cst_pac_item_cost_details cpicd,
                     cst_pac_item_costs cpic
             WHERE   cpic.cost_layer_id = cpicd.cost_layer_id
             AND     cppb.cost_layer_id = cpicd.cost_layer_id
             AND     cppb.cost_element_id = cpicd.cost_element_id
             AND     cppb.level_type = cpicd.level_type)
     WHERE   cppb.pac_period_id = i_pac_period_id
     AND     cppb.cost_group_id = i_cost_group_id
     AND     cppb.txn_category = i_txn_category
     AND     cppb.inventory_item_id = i_item_id
     AND     i_txn_category = (SELECT max (txn_category)
                               FROM   MTL_PAC_ACTUAL_COST_DETAILS
                               WHERE  pac_period_id = i_pac_period_id
                               AND    cost_group_id = i_cost_group_id
                               AND    inventory_item_id = cppb.inventory_item_id)
     AND     EXISTS (SELECT 1
                     FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                     WHERE cppb.cost_layer_id = cpicd1.cost_layer_id
                     AND   cppb.cost_element_id = cpicd1.cost_element_id
                     AND   cppb.level_type = cpicd1.level_type);

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.update_item_cppb with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END update_item_cppb;

-- PROCEDURE
--  insert_ending_balance
--
PROCEDURE insert_ending_balance (i_pac_period_id IN  NUMBER,
                                 i_cost_group_id IN  NUMBER,
                                 i_user_id       IN  NUMBER,
                                 i_login_id      IN  NUMBER,
                                 i_request_id    IN  NUMBER,
                                 i_prog_id       IN  NUMBER,
                                 i_prog_appl_id  IN  NUMBER,
                                 o_err_num       OUT NOCOPY NUMBER,
                                 o_err_code      OUT NOCOPY VARCHAR2,
                                 o_err_msg       OUT NOCOPY VARCHAR2)
IS
  l_stmt_num  NUMBER;

    /* --- start of auto log --- */
    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CSTPPWAC.insert_ending_balance';
    l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                       fnd_log.TEST(fnd_log.level_unexpected, l_module);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    /* --- end of auto log --- */
BEGIN
    /* --- start of auto log --- */
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CSTPPWAC.insert_ending_balance with '||
        'i_cost_group_id = '||i_cost_group_id||','||
        'i_user_id = '||i_user_id||','||
        'i_login_id = '||i_login_id||','||
        'i_request_id = '||i_request_id||','||
        'i_prog_id = '||i_prog_id||','||
        'i_prog_appl_id = '||i_prog_appl_id
      );
    END IF;
    /* --- end of auto log --- */

 l_stmt_num := 10;
 INSERT INTO cst_pac_period_balances (
           pac_period_id,
           cost_group_id,
           inventory_item_id,
           cost_layer_id,
           quantity_layer_id,
           cost_element_id,
           level_type,
           txn_category,
           txn_category_qty,
           txn_category_value,
           period_quantity,
           periodic_cost,
           period_balance,
           variance_amount,
           last_update_date,
           last_updated_by,
           last_update_login,
           created_by,
           creation_date,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
           (SELECT i_pac_period_id,
                   i_cost_group_id,
                   cpic.inventory_item_id,
                   cpic.cost_layer_id,
                   cpql.quantity_layer_id,
                   cpicd.cost_element_id,
                   cpicd.level_type,
                   10,                   -- txn_category
                   0,
                   0,
                   cpic.total_layer_quantity,
                   cpicd.item_cost,
                   cpicd.item_balance,
                   0,
                   sysdate,
                   i_user_id,
                   i_login_id,
                   i_user_id,
                   sysdate,
                   i_request_id,
                   i_prog_appl_id,
                   i_prog_id,
                   sysdate
           FROM    cst_pac_item_costs cpic,
                   cst_pac_item_cost_details cpicd,
                   cst_pac_quantity_layers cpql
           WHERE   cpic.pac_period_id = i_pac_period_id
           AND     cpic.cost_group_id = i_cost_group_id
           AND     cpicd.cost_layer_id = cpic.cost_layer_id
           AND     cpql.cost_layer_id = cpic.cost_layer_id
           -- Insert ending balance records in CPPB only for asset items, i.e. only for items
           -- which already have atleast one record in CPPB
           AND     exists (select 1
                           from   cst_pac_period_balances cppb1
                           where  cppb1.inventory_item_id = cpic.inventory_item_id
                           and    cppb1.cost_group_id = cpic.cost_group_id
                           and    cppb1.pac_period_id = cpic.pac_period_id));

    /* --- start of auto log --- */
    <<out_arg_log>>

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CSTPPWAC.insert_ending_balance with '||
        'o_err_num = '||o_err_num||','||
        'o_err_code = '||o_err_code||','||
        'o_err_msg = '||o_err_msg
      );
    END IF;
    /* --- end of auto log --- */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_uLog THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    o_err_num := SQLCODE;
    o_err_msg := l_module || ' (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
  /* --- end of auto log --- */
END insert_ending_balance;

END CSTPPWAC;

/
