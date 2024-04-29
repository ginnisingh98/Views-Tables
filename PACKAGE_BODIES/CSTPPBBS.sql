--------------------------------------------------------
--  DDL for Package Body CSTPPBBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPBBS" AS
/* $Header: CSTPBBSB.pls 120.8 2007/05/24 12:37:04 vmutyala ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPBBS';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       copy_prior_info                                              |
*----------------------------------------------------------------------------*/
PROCEDURE copy_prior_info(
        i_pac_period_id         IN      NUMBER,
        i_prior_pac_period_id   IN      NUMBER,
        i_legal_entity          IN      NUMBER,
        i_cost_type_id          IN      NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_cost_method           IN      NUMBER,
        i_user_id               IN      NUMBER,
        i_login_id              IN      NUMBER,
        i_request_id            IN      NUMBER,
        i_prog_id               IN      NUMBER DEFAULT -1,
        i_prog_app_id           IN      NUMBER DEFAULT -1,
        o_err_num               OUT NOCOPY      NUMBER,
        o_err_code              OUT NOCOPY      VARCHAR2,
        o_err_msg               OUT NOCOPY      VARCHAR2)
IS

l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(240);
PROCESS_ERROR           EXCEPTION;
l_stmt_num              NUMBER;

l_api_name              CONSTANT VARCHAR2(30) := 'copy_prior_info';
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module                CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.begin',
                   l_api_name || ' <<< ' || 'Parameters :' ||
                   ' i_pac_period_id: ' || i_pac_period_id ||
                   ' i_prior_pac_period_id: ' || i_prior_pac_period_id ||
                   ' i_legal_entity: ' || i_legal_entity ||
                   ' i_cost_type_id: ' || i_cost_type_id ||
                   ' i_cost_group_id: ' || i_cost_group_id ||
                   ' i_cost_method: ' || i_cost_method);
  END IF;

  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  IF (i_cost_method = 3) THEN
    l_stmt_num := 10;
    copy_prior_info_PWAC (i_pac_period_id, i_prior_pac_period_id,
                          i_legal_entity, i_cost_type_id, i_cost_group_id,
                          i_user_id,
                          i_login_id, i_request_id, i_prog_id, i_prog_app_id,
                          l_err_num, l_err_code, l_err_msg);
    IF (l_err_num <> 0) THEN
      raise PROCESS_ERROR;
    END IF;
  ELSE
    l_stmt_num := 20;
    CSTPFCHK.copy_prior_info_hook (i_pac_period_id, i_prior_pac_period_id,
                          i_legal_entity, i_cost_type_id, i_cost_group_id,
                          i_cost_method, i_user_id,
                          i_login_id, i_request_id, i_prog_app_id, i_prog_id,
                          l_err_num, l_err_code, l_err_msg);
    IF (l_err_num <> 0) THEN
      raise PROCESS_ERROR;
    END IF;
  END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

  WHEN PROCESS_ERROR THEN
    IF (l_exceptionLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                       l_module || '.' || l_stmt_num,
                       l_err_msg);
    END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;

END copy_prior_info;




/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURES/FUNCTIONS                                              |
*----------------------------------------------------------------------------*/
PROCEDURE copy_prior_info_PWAC(
        i_pac_period_id         IN      NUMBER,
        i_prior_pac_period_id   IN      NUMBER,
        i_legal_entity          IN      NUMBER,
        i_cost_type_id          IN      NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_user_id               IN      NUMBER,
        i_login_id              IN      NUMBER,
        i_request_id            IN      NUMBER,
        i_prog_id               IN      NUMBER DEFAULT -1,
        i_prog_app_id           IN      NUMBER DEFAULT -1,
        o_err_num               OUT NOCOPY      NUMBER,
        o_err_code              OUT NOCOPY      VARCHAR2,
        o_err_msg               OUT NOCOPY      VARCHAR2)
IS

l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(240);
l_stmt_num              NUMBER;
l_count                 NUMBER;
l_use_hook              NUMBER;
l_cost_layer_id         NUMBER;
l_quantity_layer_id     NUMBER;
l_cost_method_type      NUMBER;
l_current_start_date    DATE;
CURRENT_DATA_EXISTS     EXCEPTION;
PROCESS_ERROR           EXCEPTION;


  l_api_name            CONSTANT VARCHAR2(30) := 'copy_prior_info_PWAC';
  l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
  l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

  l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
  l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.begin',
                   l_api_name || ' <<< ' || 'Parameters :' ||
                   ' i_pac_period_id: ' || i_pac_period_id ||
                   ' i_prior_pac_period_id: ' || i_prior_pac_period_id ||
                   ' i_legal_entity: ' || i_legal_entity ||
                   ' i_cost_type_id: ' || i_cost_type_id ||
                   ' i_cost_group_id: ' || i_cost_group_id);
  END IF;
----------------------------------------------------------------------
-- Initialize Variables
----------------------------------------------------------------------

  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

--------------------------------------------------------------------
-- Copy from previous period, if this is not the first run period --
--------------------------------------------------------------------
  IF (i_prior_pac_period_id <> -1) THEN

--------------------------------------------------------
-- Making sure that we have no data in current period --
--------------------------------------------------------
    l_stmt_num := 10;
    l_count := 0;
    SELECT count(1)
    INTO l_count
    FROM cst_pac_item_costs
    WHERE pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id
      AND rownum = 1;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;

    l_stmt_num := 20;
    l_count := 0;
    SELECT count(1)
    INTO l_count
    FROM wip_pac_period_balances
    WHERE pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id
      AND rownum = 1;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;

    l_stmt_num := 22;
    l_count := 0;
    SELECT count(1)
    INTO   l_count
    FROM   cst_pac_req_oper_cost_details
    WHERE  pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id
      AND rownum = 1;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;

    l_stmt_num := 25;
    l_count := 0;
    SELECT count(1)
    INTO l_count
    FROM cst_pac_period_balances
    WHERE pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id
      AND rownum = 1;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;

--------------------------------------------------------------------------------
-- Copy data from previous period to current period of the following tables : --
-- 1. cst_pac_item_costs                                                      --
-- 2. cst_pac_item_cost_details                                               --
-- 3. cst_pac_quantity_layers                                                 --
-- New cost_layer_id and quantity_layer_id are generated for every rows       --
-- inserted.                                                                  --
--------------------------------------------------------------------------------
-------------------------------------------
-- Copy prior info of CST_PAC_ITEM_COSTS --
-------------------------------------------
      l_stmt_num := 30;
      INSERT INTO cst_pac_item_costs (
        cost_layer_id,
        pac_period_id,
        cost_group_id,
        inventory_item_id,
        total_layer_quantity,
        buy_quantity,
        make_quantity,
        issue_quantity,
        item_cost,
        begin_item_cost,
        item_buy_cost,
        item_make_cost,
        material_cost,
        material_overhead_cost,
        resource_cost,
        overhead_cost,
        outside_processing_cost,
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
        pl_item_cost,
        tl_item_cost,
        unburdened_cost,
        burden_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
      SELECT
        cst_pac_item_costs_s.nextval,
        i_pac_period_id,
        cost_group_id,
        inventory_item_id,
        total_layer_quantity,
        0,
        0,
        0,
        item_cost,
        item_cost,
        0,
        0,
        material_cost,
        material_overhead_cost,
        resource_cost,
        overhead_cost,
        outside_processing_cost,
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
        pl_item_cost,
        tl_item_cost,
        unburdened_cost,
        burden_cost,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_request_id,
        i_prog_app_id,
        i_prog_id,
        SYSDATE,
        i_login_id
      FROM cst_pac_item_costs cpic
      WHERE cpic.pac_period_id = i_prior_pac_period_id
        AND cpic.cost_group_id = i_cost_group_id;

--------------------------------------------------
-- Copy prior info of CST_PAC_ITEM_COST_DETAILS --
--------------------------------------------------
      l_stmt_num := 40;
      INSERT INTO cst_pac_item_cost_details (
        cost_layer_id,
        cost_element_id,
        level_type,
        item_cost,
        item_buy_cost,
        item_make_cost,
        item_balance,
        make_balance,
        buy_balance,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
      SELECT
        cpic2.cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        cpicd.item_cost,
        0,
        0,
        cpicd.item_cost * cpic1.total_layer_quantity,
        0,
        0,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_request_id,
        i_prog_app_id,
        i_prog_id,
        SYSDATE,
        i_login_id
      FROM cst_pac_item_cost_details cpicd,
           cst_pac_item_costs cpic1,
	   cst_pac_item_costs cpic2
      WHERE cpicd.cost_layer_id = cpic1.cost_layer_id
        AND cpic1.pac_period_id = i_prior_pac_period_id
        AND cpic1.cost_group_id = i_cost_group_id
	AND cpic2.pac_period_id = i_pac_period_id
	AND cpic2.cost_group_id = cpic1.cost_group_id
	AND cpic2.inventory_item_id = cpic1.inventory_item_id;

------------------------------------------------
-- Copy prior info of CST_PAC_QUANTITY_LAYERS --
------------------------------------------------
        l_stmt_num := 50;
        INSERT INTO cst_pac_quantity_layers (
          quantity_layer_id,
          cost_layer_id,
          pac_period_id,
          cost_group_id,
          inventory_item_id,
          layer_quantity,
          begin_layer_quantity,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          last_update_login)
        SELECT
          cst_pac_quantity_layers_s.nextval,
          cpic.cost_layer_id,
          i_pac_period_id,
          cpql.cost_group_id,
          cpql.inventory_item_id,
          cpql.layer_quantity,
          cpql.layer_quantity,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_request_id,
          i_prog_app_id,
          i_prog_id,
          SYSDATE,
          i_login_id
        FROM cst_pac_quantity_layers cpql,
        cst_pac_item_costs cpic
        WHERE cpql.pac_period_id = i_prior_pac_period_id
	AND cpic.pac_period_id = i_pac_period_id
        AND cpic.cost_group_id = i_cost_group_id
	AND cpic.cost_group_id = cpql.cost_group_id
	AND cpic.inventory_item_id = cpql.inventory_item_id;

------------------------------------------------
-- Copy prior info of CST_PAC_PERIOD_BALANCES --
------------------------------------------------

        /* Bug 5496879 If the prior period was closed with pre R12 code, txn_category 10
           (ending balance line) would not have been created. So insert begining balance
           txn_category 1 from CPIC and CPICD instead of prior period CPPB */
        /* Note: this might cause regression to Bug 5337969 as Exp item data is inserted into CPPB */

        l_stmt_num := 55;
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
                      1,                   -- txn_category
                      0,                   -- txn_category_qty
                      0,                   -- txn_category_value
                      cpic.total_layer_quantity,
                      cpicd.item_cost,
                      cpicd.item_balance, -- period_balance
                      0,                   -- variance
                      sysdate,
                      i_user_id,
                      i_login_id,
                      i_user_id,
                      sysdate,
                      i_request_id,
                      i_prog_app_id,
                      i_prog_id,
                      sysdate
              FROM    cst_pac_item_costs cpic,
                      cst_pac_item_cost_details cpicd,
                      cst_pac_quantity_layers cpql
              WHERE   cpic.cost_group_id  = i_cost_group_id
	      	  AND cpic.pac_period_id = i_pac_period_id
                  AND cpicd.cost_layer_id = cpic.cost_layer_id
                  AND cpql.cost_layer_id  = cpic.cost_layer_id
		  AND cpql.inventory_item_id = cpic.inventory_item_id
		  AND cpql.cost_group_id = cpic.cost_group_id
		  AND cpql.pac_period_id = cpic.pac_period_id);

---------------------------------------------------------------------------
-- Copy prior info of wip_pac_period_balances                           --
-- Only the followings are copied :                                     --
-- 1. Discrete jobs that are opened or closed in the current period.    --
-- 2. Scheduled CFM that are opened or closed in the current period.    --
-- 3. Repetitive Schedules having at least line that are opened or      --
--    closed in the current period.                                     --
-- Thus jobs/schedules that are closed in the previous period will not  --
-- be copied to current period.
---------------------------------------------------------------------------
    l_stmt_num := 60;
    SELECT period_start_date
    INTO l_current_start_date
    FROM CST_PAC_PERIODS
    WHERE pac_period_id = i_pac_period_id;

    l_stmt_num := 70;
    INSERT INTO wip_pac_period_balances (
      pac_period_id,
      cost_group_id,
      cost_type_id,
      organization_id,
      wip_entity_id,
      line_id,
      operation_seq_num,
      operation_completed_units,
      relieved_assembly_units,
      tl_resource_in,
      tl_resource_out,
      tl_outside_processing_in,
      tl_outside_processing_out,
      tl_overhead_in,
      tl_overhead_out,
      pl_material_in,
      pl_material_out,
      pl_resource_in,
      pl_resource_out,
      pl_overhead_in,
      pl_overhead_out,
      pl_outside_processing_in,
      pl_outside_processing_out,
      pl_material_overhead_in,
      pl_material_overhead_out,
      /*added _apull columns for bug#3229515*/
      pl_material_in_apull,
      pl_resource_in_apull,
      pl_overhead_in_apull,
      pl_outside_processing_in_apull,
      pl_material_overhead_in_apull,
      /*end of addition for bug#3229515*/
      tl_resource_temp,
      tl_outside_processing_temp,
      tl_overhead_temp,
      pl_material_temp,
      pl_material_overhead_temp,
      pl_resource_temp,
      pl_outside_processing_temp,
      pl_overhead_temp,
      tl_resource_var,
      tl_outside_processing_var,
      tl_overhead_var,
      pl_material_var,
      pl_material_overhead_var,
      pl_resource_var,
      pl_outside_processing_var,
      pl_overhead_var,
      wip_entity_type,
      unrelieved_scrap_quantity,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_update_login )
    SELECT
      i_pac_period_id,
      wppb.cost_group_id,
      wppb.cost_type_id,
      wppb.organization_id,
      wppb.wip_entity_id,
      wppb.line_id,
      wppb.operation_seq_num,
      wppb.operation_completed_units,
      wppb.relieved_assembly_units,
      wppb.tl_resource_in,
      wppb.tl_resource_out,
      wppb.tl_outside_processing_in,
      wppb.tl_outside_processing_out,
      wppb.tl_overhead_in,
      wppb.tl_overhead_out,
      wppb.pl_material_in,
      wppb.pl_material_out,
      wppb.pl_resource_in,
      wppb.pl_resource_out,
      wppb.pl_overhead_in,
      wppb.pl_overhead_out,
      wppb.pl_outside_processing_in,
      wppb.pl_outside_processing_out,
      wppb.pl_material_overhead_in,
      wppb.pl_material_overhead_out,
      /*bug#3229515-make _apull cols 0 since whatever is incurred would be
      relieved in the same period*/
      0,
      0,
      0,
      0,
      0,
      /*end of addition for bug#3229515*/
      wppb.tl_resource_temp,
      wppb.tl_outside_processing_temp,
      wppb.tl_overhead_temp,
      wppb.pl_material_temp,
      wppb.pl_material_overhead_temp,
      wppb.pl_resource_temp,
      wppb.pl_outside_processing_temp,
      wppb.pl_overhead_temp,
      wppb.tl_resource_var,
      wppb.tl_outside_processing_var,
      wppb.tl_overhead_var,
      wppb.pl_material_var,
      wppb.pl_material_overhead_var,
      wppb.pl_resource_var,
      wppb.pl_outside_processing_var,
      wppb.pl_overhead_var,
      wppb.wip_entity_type,
      wppb.unrelieved_scrap_quantity,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_app_id,
      i_prog_id,
      SYSDATE,
      i_login_id
    FROM
      wip_pac_period_balances wppb, wip_entities we
    WHERE
      wppb.pac_period_id = i_prior_pac_period_id
      AND wppb.cost_group_id = i_cost_group_id
      AND wppb.wip_entity_id = we.wip_entity_id
      AND (
      ( we.entity_type IN (1,3) AND EXISTS (
        SELECT 'X'
        FROM wip_discrete_jobs wdj
        WHERE
          wdj.wip_entity_id = wppb.wip_entity_id AND
          NVL(wdj.date_closed, l_current_start_date) >= l_current_start_date))
      OR (we.entity_type = 4 AND EXISTS (
        SELECT 'X'
        FROM wip_flow_schedules wfs
        WHERE
          wfs.wip_entity_id = wppb.wip_entity_id AND
          wfs.scheduled_flag = 1 AND
          wfs.status IN (1,2) AND
          NVL(wfs.date_closed, l_current_start_date) >= l_current_start_date))
      OR (we.entity_type =2 AND EXISTS (
        SELECT 'X'
        FROM wip_repetitive_schedules wrs
        WHERE
          wrs.wip_entity_id = wppb.wip_entity_id AND
          wrs.line_id = wppb.line_id AND
          NVL(wrs.date_closed, l_current_start_date) >= l_current_start_date)));

      ---------------------------------------
      -- Added R12 PAC enhancement
      ---------------------------------------
      l_stmt_num := 75;
      INSERT INTO CST_PAC_REQ_OPER_COST_DETAILS
       (pac_period_id,
        cost_group_id,
        wip_entity_id,
        line_id,
        inventory_item_id,
        cost_element_id,
        operation_seq_num,
        applied_value,
        applied_quantity,
        relieved_value,
        relieved_quantity,
        comp_variance,
        temp_relieved_value,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id ,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
        SELECT i_pac_period_id,
               wprocd.cost_group_id,
               wprocd.wip_entity_id,
               wprocd.line_id,
               wprocd.inventory_item_id,
               wprocd.cost_element_id,
               wprocd.operation_seq_num,
               wprocd.applied_value,
               wprocd.applied_quantity,
               wprocd.relieved_value,
               wprocd.relieved_quantity,
               wprocd.comp_variance,
               0,
               SYSDATE,
               i_user_id,
               SYSDATE,
               i_user_id,
               i_request_id,
               i_prog_app_id,
               i_prog_id,
               SYSDATE,
               i_login_id
        FROM   CST_PAC_REQ_OPER_COST_DETAILS wprocd,
               WIP_ENTITIES we
        WHERE  wprocd.pac_period_id = i_prior_pac_period_id
        AND    wprocd.cost_group_id = i_cost_group_id
        AND    wprocd.wip_entity_id = we.wip_entity_id
        AND (
             ( we.entity_type IN (1,3) AND EXISTS (
                SELECT 'X'
                FROM wip_discrete_jobs wdj
                WHERE
                  wdj.wip_entity_id = wprocd.wip_entity_id AND
                  NVL(wdj.date_closed, l_current_start_date) >= l_current_start_date))
                OR (we.entity_type = 2 AND EXISTS (
                SELECT 'X'
                FROM wip_repetitive_schedules wrs
                WHERE
                  wrs.wip_entity_id = wprocd.wip_entity_id AND
                  wrs.line_id = wprocd.line_id AND
                  NVL(wrs.date_closed, l_current_start_date) >= l_current_start_date)));

  END IF;

----------------------
-- Calling the hook --
----------------------
  l_stmt_num := 80;
  l_use_hook := CSTPPCHK.beginning_balance_hook(
                          i_pac_period_id,
                          i_prior_pac_period_id,
                          i_legal_entity,
                          i_cost_type_id,
                          i_cost_group_id,
                          3,
                          i_user_id,
                          i_login_id,
                          i_request_id,
                          i_prog_id,
                          i_prog_app_id,
                          l_err_num,
                          l_err_code,
                          l_err_msg );

  IF (l_err_num <> 0) THEN
      raise PROCESS_ERROR;
  END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

  WHEN CURRENT_DATA_EXISTS THEN
    o_err_num := 9999;
    o_err_code := NULL;
    o_err_msg := SUBSTR('CSTPPBBS.copy_prior_info_PWAC('
                 || to_char(l_stmt_num)
                 || '): current period data already exists' ,1,240);
    IF (l_exceptionLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                       l_module || '.' || l_stmt_num,
                       o_err_msg);
    END IF;

  WHEN PROCESS_ERROR THEN
    IF (l_exceptionLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                       l_module || '.' || l_stmt_num,
                       l_err_msg);
    END IF;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_code := NULL;
    o_err_msg := SUBSTR('CSTPPBBS.copy_prior_info_PWAC('
                 || to_char(l_stmt_num) || '): ' ||SQLERRM,1,240);

    IF (l_uLog) THEN
         FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                         l_module || '.' || l_stmt_num,
                         SQLERRM);
    END IF;

END copy_prior_info_PWAC;

END CSTPPBBS;

/
