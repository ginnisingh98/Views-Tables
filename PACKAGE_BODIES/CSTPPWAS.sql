--------------------------------------------------------
--  DDL for Package Body CSTPPWAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWAS" AS
/* $Header: CSTPWASB.pls 120.33.12010000.2 2009/05/09 03:25:23 jkwac ship $ */

G_MAX_RECORDS CONSTANT NUMBER := 1000;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPWAS';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       insert_wip_costs                                                     |
*----------------------------------------------------------------------------*/
PROCEDURE insert_wip_costs (
        p_pac_period_id           IN          NUMBER,
        p_prior_period_id         IN          NUMBER,
        p_cost_group_id           IN          NUMBER,
        p_cost_type_id            IN          NUMBER,
        p_item_id                 IN          NUMBER,
        p_entity_id               IN          NUMBER,
        p_line_id                 IN          NUMBER,
        p_txn_id                  IN          NUMBER,
        p_net_qty                 IN          NUMBER,
        p_completed_assembly_qty  IN          NUMBER,
        p_user_id                 IN          NUMBER,
        p_final_completion_flag   IN          NUMBER,
        p_start_date              IN          DATE,
        p_end_date                IN          DATE,
        p_login_id                IN          NUMBER,
        p_request_id              IN          NUMBER,
        p_prog_id                 IN          NUMBER DEFAULT -1,
        p_prog_app_id             IN          NUMBER DEFAULT -1,
        x_err_num                 OUT NOCOPY  NUMBER,
        x_err_code                OUT NOCOPY  VARCHAR2,
        x_err_msg                 OUT NOCOPY  VARCHAR2)
IS
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);

l_transaction_action_id         NUMBER; --Aded for R12 PAC enhancement
l_transaction_source_type_id    NUMBER; --Aded for R12 PAC enhancement
l_net_qty                       NUMBER; --Aded for R12 PAC enhancement
l_primary_quantity              NUMBER; --Aded for R12 PAC enhancement
l_details                       NUMBER; --Aded for R12 PAC enhancement
l_job                           NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'insert_wip_costs';
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
                           l_api_name || ' <<< Parameters:
                           p_pac_period_id = ' || p_pac_period_id || '
                           p_prior_period_id = ' || p_prior_period_id || '
                           p_item_id = ' || p_item_id || '
                           p_entity_id = ' || p_entity_id || '
                           p_line_id = ' || p_line_id || '
                           p_net_qty = ' || p_net_qty || '
                           p_completed_assembly_qty = ' || p_completed_assembly_qty ||'
                           p_final_completion_flag = ' || p_final_completion_flag ||'
                           p_txn_id = ' || p_txn_id );
     END IF;

       ----------------------------------------------------------------------
       -- Initialize Variables
       ----------------------------------------------------------------------
       l_stmt_num := 0;
       l_err_num := 0;
       l_err_code := '';
       l_err_msg := '';
       l_details := 0;
       l_job  := 0;

       --------------------------------------------------------------------------
       -- Get the transaction_action_id, transaction_source_id and primary_qty
       --------------------------------------------------------------------------
       l_stmt_num := 10;
       SELECT mmt.transaction_action_id,
              mmt.transaction_source_type_id ,
              mmt.primary_quantity
       INTO   l_transaction_action_id,
              l_transaction_source_type_id,
              l_primary_quantity
       FROM   mtl_material_transactions mmt
       WHERE  mmt.transaction_id = p_txn_id;

       ------------------------------------------------------------
       -- In case Asembly Returns cancels Assembly completions then
       -- Get the completed Assembly Units in this period
       ------------------------------------------------------------
       l_stmt_num := 20;
       IF (p_net_qty = 0 AND p_final_completion_flag = 1 AND l_transaction_action_id = 31 AND l_transaction_source_type_id =5) THEN
            l_net_qty := p_completed_assembly_qty;
       ELSE
           l_net_qty := p_net_qty;
       END IF;

      -------------------------------------------------------------------------------------------
      -- Assembly return transaction needs to relieved at prior period Avg of Relieved cost
      -- In case of p_net_qty = 0 and final_completion transaction exists
      -------------------------------------------------------------------------------------------
       IF ( p_net_qty = 0 AND p_final_completion_flag = 1 AND
            l_transaction_action_id = 32 AND l_transaction_source_type_id = 5)  THEN-- Assembly Return
          -----------------------------------------------------
          -- PAC prior period exists
          -----------------------------------------------------
          l_stmt_num := 30;

	  SELECT COUNT(wppb.PAC_PERIOD_ID)
	    INTO l_job
	    FROM WIP_PAC_PERIOD_BALANCES wppb
	   WHERE wppb.WIP_ENTITY_ID = p_entity_id
	     AND wppb.PAC_PERIOD_ID = p_prior_period_id
	     AND NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(p_line_id,-99));

	    -- Statement level log message for FND logging
          IF (l_sLog) THEN
              FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                              l_module || '.'||l_stmt_num,
                              'l_transaction_action_id :' || l_transaction_action_id || ','||
                              'l_transaction_source_type_id :'  || l_transaction_source_type_id || ','||
                              'l_net_qty :' ||  l_net_qty || ','||
                              'l_job :'  || l_job);
          END IF;

          l_stmt_num := 35;
          IF ( p_prior_period_id <> -1  AND l_job <> 0 ) THEN

               INSERT ALL
                WHEN pp_pl_material_out <> 0 THEN
                   -- Previous Level  and Material cost element
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         1,
                         2,
                         pp_pl_material_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                -- Previous Level and Material Overhead cost element
                WHEN pp_pl_material_overhead_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         2,
                         2,
                         pp_pl_material_overhead_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- Previous Level and Resource cost element
                   WHEN pp_pl_resource_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         3,
                         2,
                         pp_pl_resource_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- Previous Level and Outsideprocessing cost element
                   WHEN pp_pl_outside_processing_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         4,
                         2,
                         pp_pl_outside_processing_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- Previous Level and Overhead cost element
                   WHEN pp_pl_overhead_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         5,
                         2,
                         pp_pl_overhead_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- This Level and Resource cost element
                   WHEN pp_tl_resource_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         3,
                         1,
                         pp_tl_resource_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- This Level and Overhead  cost element
                   WHEN pp_tl_overhead_out <> 0 THEN
                   INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         5,
                         1,
                         pp_tl_overhead_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                   -- This Level and Outsideprocessing cost element
                   WHEN pp_tl_outside_processing_out <> 0 THEN
                        INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                        cost_group_id,
                        cost_type_id ,
                        inventory_item_id,
                        transaction_id,
                        cost_element_id,
                        level_type,
                        transaction_cost,
                        wip_variance, -- New Column
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        last_update_login)
                  VALUES(p_pac_period,
                         p_cost_group,
                         p_cost_type,
                         p_item,
                         p_txn,
                         4,
                         1,
                         pp_tl_outside_processing_out,
                         0, -- New column value
                         SYSDATE,
                         p_user,
                         SYSDATE,
                         p_user,
                         p_request,
                         p_prog_app,
                         p_prog,
                         SYSDATE,
                         p_login)
                  -- Create 0 TL Material instead of 0 PL Material when there is no non-zero cost details
                  WHEN (pp_pl_material_out = 0 AND pp_pl_material_overhead_out = 0 AND pp_pl_resource_out = 0 AND
                        pp_pl_outside_processing_out = 0 AND pp_pl_overhead_out = 0 AND pp_tl_resource_out = 0 AND
                        pp_tl_outside_processing_out = 0 AND pp_tl_overhead_out = 0) THEN
                  INTO mtl_pac_txn_cost_details
                       (pac_period_id,
                       cost_group_id,
                       cost_type_id ,
                       inventory_item_id,
                       transaction_id,
                       cost_element_id,
                       level_type,
                       transaction_cost,
                       last_update_date,
                       last_updated_by,
                       creation_date,
                       created_by,
                       request_id,
                       program_application_id,
                       program_id,
                       program_update_date,
                       last_update_login)
               VALUES (p_pac_period,
                       p_cost_group,
                       p_cost_type,
                       p_item,
                       p_txn,
                       1, -- Material Cost Element
                       1, -- This Level
                       0,-- Zero Cost
                       sysdate,
                       p_user,
                       sysdate,
                       p_user,
                       p_request,
                       p_prog_app,
                       p_prog,
                       sysdate,
                       p_login)

                  SELECT p_pac_period_id p_pac_period,
                         p_cost_group_id p_cost_group,
                         p_cost_type_id  p_cost_type,
                         p_item_id p_item,
                         p_txn_id p_txn,
                         SUM(nvl(wppb.pl_material_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_pl_material_out,
                         SUM(nvl(wppb.pl_material_overhead_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_pl_material_overhead_out,
                         SUM(nvl(wppb.pl_resource_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_pl_resource_out,
                         SUM(nvl(wppb.pl_outside_processing_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_pl_outside_processing_out,
                         SUM(nvl(wppb.pl_overhead_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_pl_overhead_out,
                         SUM(nvl(wppb.tl_resource_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_tl_resource_out,
                         SUM(nvl(wppb.tl_outside_processing_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_tl_outside_processing_out,
                         SUM(nvl(wppb.tl_overhead_out/
                                     decode(nvl(relieved_assembly_units,0),0,1,relieved_assembly_units),0)) pp_tl_overhead_out,
                         p_user_id p_user,
                         p_login_id p_login,
                         p_request_id p_request,
                         p_prog_app_id p_prog_app,
                         p_prog_id p_prog
                  FROM   wip_pac_period_balances wppb
                  WHERE  wppb.pac_period_id = p_prior_period_id
                  AND    wppb.cost_group_id = p_cost_group_id
                  AND    wppb.wip_entity_id = p_entity_id
                  AND    NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(p_line_id,-99));
          ELSE
               INSERT INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id ,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period_id,
                      p_cost_group_id,
                      p_cost_type_id,
                      p_item_id,
                      p_txn_id,
                      1, -- Material Cost Element
                      1, -- This Level
                      0,-- Zero Cost
                      sysdate,
                      p_user_id,
                      sysdate,
                      p_user_id,
                      p_request_id,
                      p_prog_app_id,
                      p_prog_id,
                      sysdate,
                      p_login_id);
          END IF; -- End of IF p_prior_period_id <> -1

      ELSE
          --------------------------------------------------
          --
          --------------------------------------------------
           l_stmt_num := 40;
           INSERT ALL
               -- Previous Level and Material cost element
               WHEN (pl_material_temp <> 0 OR pl_material_temp_var <> 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     wip_variance, -- New Column
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      1,
                      2,
                      pl_material_temp,
                      pl_material_temp_var,-- New column value
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login )
               -- Previous Level and Material Overhead cost element
               WHEN (pl_material_overhead_temp <> 0 OR pl_material_overhead_temp_var <> 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     wip_variance, -- New Column
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      2,
                      2,
                      pl_material_overhead_temp,
                      pl_material_overhead_temp_var,-- New column value
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login )
               -- Previous Level and Resource cost element
               WHEN (pl_resource_temp <> 0 OR pl_resource_temp_var <> 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     wip_variance, -- New Column
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
              VALUES (p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      3,
                      2,
                      pl_resource_temp,
                      pl_resource_temp_var,-- New column value
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login )
               -- Previous Level and Outside Processing cost element
               WHEN (pl_outside_processing_temp <>0 OR pl_outside_processing_temp_var <> 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     wip_variance, -- New Column
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
              VALUES (p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      4,
                      2,
                      pl_outside_processing_temp,
                      pl_outside_processing_temp_var,-- New column value
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login )
               -- Previous Level and Overhead cost element
               WHEN (pl_overhead_temp <>0 OR pl_overhead_temp_var <> 0)  THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     wip_variance, -- New Column
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
              VALUES (p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      5,
                      2,
                      pl_overhead_temp,
                      pl_overhead_temp_var,-- New column value
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login )
               -- This level and Resource Cost Element
               WHEN (tl_resource_temp <> 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id ,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      3,
                      1,
                      tl_resource_temp,
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login)
               -- This Level and Outside Processing cost element
               WHEN tl_outside_processing_temp <>0 THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id ,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      4,
                      1,
                      tl_outside_processing_temp,
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login)
               -- This Level and Overhead cost element
               WHEN tl_overhead_temp <> 0 THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id ,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      5,
                      1,
                      tl_overhead_temp,
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login)
               -- Create 0 TL Material instead of 0 PL Material when there is no non-zero cost details
               WHEN (pl_material_temp = 0 AND pl_material_overhead_temp = 0 AND pl_resource_temp = 0 AND
                     pl_outside_processing_temp = 0 AND pl_overhead_temp = 0 AND tl_resource_temp = 0 AND
                     tl_outside_processing_temp = 0 AND tl_overhead_temp = 0) THEN
               INTO mtl_pac_txn_cost_details
                    (pac_period_id,
                     cost_group_id,
                     cost_type_id ,
                     inventory_item_id,
                     transaction_id,
                     cost_element_id,
                     level_type,
                     transaction_cost,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login)
               VALUES(p_pac_period,
                      p_cost_group,
                      p_cost_type,
                      p_item,
                      p_txn,
                      1, -- Material Cost Element
                      1, -- This Level
                      0,-- Zero Cost
                      sysdate,
                      p_user,
                      sysdate,
                      p_user,
                      p_request,
                      p_prog_app,
                      p_prog,
                      sysdate,
                      p_login)

            SELECT  p_pac_period_id p_pac_period,
                    p_cost_group_id p_cost_group,
                    p_cost_type_id  p_cost_type,
                    p_item_id p_item,
                    p_txn_id p_txn,
                    NVL(SUM(wppb.pl_material_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) pl_material_temp,
                    NVL(SUM(wppb.pl_material_overhead_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) pl_material_overhead_temp,
                    NVL(SUM(wppb.pl_resource_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) pl_resource_temp,
                    NVL(SUM(wppb.pl_outside_processing_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) pl_outside_processing_temp,
                    NVL(SUM(wppb.pl_overhead_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) pl_overhead_temp,
                    NVL(SUM(wppb.tl_resource_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) tl_resource_temp,
                    NVL(SUM(wppb.tl_outside_processing_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) tl_outside_processing_temp,
                    NVL(SUM(wppb.tl_overhead_temp)/
                                    decode(l_net_qty,0,1,l_net_qty),0) tl_overhead_temp,
                    -- All temp Variance Columns
                    NVL(SUM(wppb.pl_material_temp_var),0) pl_material_temp_var,
                    NVL(SUM(wppb.pl_material_overhead_temp_var),0) pl_material_overhead_temp_var,
                    NVL(SUM(wppb.pl_resource_temp_var),0) pl_resource_temp_var,
                    NVL(SUM(wppb.pl_outside_processing_temp_var),0) pl_outside_processing_temp_var,
                    NVL(SUM(wppb.pl_overhead_temp_var),0) pl_overhead_temp_var,
                    p_user_id p_user,
                    p_login_id p_login,
                    p_request_id p_request,
                    p_prog_app_id p_prog_app,
                    p_prog_id p_prog
            FROM    wip_pac_period_balances wppb
            WHERE   wppb.pac_period_id = p_pac_period_id
            AND     wppb.cost_group_id = p_cost_group_id
            AND     wppb.wip_entity_id = p_entity_id
            AND     NVL(wppb.line_id,-99) = decode(wppb.wip_entity_type, 4, -99, NVL(p_line_id,-99));
 END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION
        WHEN OTHERS THEN
                IF (l_uLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                   l_module || '.' || l_stmt_num,
                                   SQLERRM);
                END IF;
                ROLLBACK;
                fnd_file.put_line(fnd_file.log,' Exception in Insert_wip_costs');
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWAS.insert_wip_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END insert_wip_costs;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE:  Relief_BOM_Quantity                                   |
|                                                                            |
|  Design: Ray, Vinayak, Srinath and Subbu                                   |
|                                                                            |
|  Description:                                                              |
|       This Procedure relieves the Material costs based on Predefined       |
|       Materials                                                            |
|                                                                            |
|  Logic:                                                                    |
|     The first cursor gets the operation sequence number for a given job.   |
|                                                                            |
|     Second cursor gets all the components at that operations.              |
|                                                                            |
|    Check any record exists in table CST_PAC_REQ_OPER_COST_DETAILS (cprocd) |
|                                                                            |
|    IF (no record exists in cprocd) THEN                                    |
|       FOR  each cost elements  LOOP                                        |
|                                                                            |
|       END LOOP;                                                            |
|    ELSE                                                                    |
|       Third cursor to get the cost elements from cprocd                    |
|        Relieve material costs accordingly                                  |
|       END of Third cursor                                                  |
|   END IF;                                                                  |
|  END of Second Cursor                                                      |
| End of First Cursor                                                        |
|   UPDATE table WIP_PAC_PERIOD_BALANCES (wppb)                              |
|    Check the job balance in this period for each cost element.             |
|   If the value is negative then put these values in VAR columns            |
|   END;                                                                     |
*----------------------------------------------------------------------------*/
PROCEDURE Relief_BOM_Quantity (
        p_pac_period_id               IN        NUMBER,
        p_prior_period_id             IN        NUMBER,
        p_cost_group_id               IN        NUMBER,
        p_cost_type_id                IN        NUMBER,
        p_entity_id                   IN        NUMBER,
        p_line_id                     IN        NUMBER,
        p_net_qty                     IN        NUMBER,
        p_final_completion_flag       IN        NUMBER,
        p_scrap                       IN        NUMBER,
        p_op_seq                      IN        NUMBER,
        p_start_date                  IN        DATE,
        p_end_date                    IN        DATE,
        p_login_id                    IN        NUMBER,
        p_user_id                     IN        NUMBER,
        p_request_id                  IN        NUMBER,
        p_prog_id                     IN        NUMBER DEFAULT -1,
        p_prog_app_id                 IN        NUMBER DEFAULT -1,
        x_err_num                     OUT NOCOPY     NUMBER,
        x_err_code                    OUT NOCOPY     VARCHAR2,
        x_err_msg                     OUT NOCOPY     VARCHAR2)
IS

l_lot_size                  NUMBER; -- Lot based materials project for R12
l_include_comp_yield        NUMBER; -- Component yield enhancement changes in R12
l_org_id                    NUMBER;
l_repetitive_schedule_id    NUMBER;

CURSOR c_wip_opseq IS
       SELECT wppb.operation_seq_num operation_seq_num
       FROM   WIP_PAC_PERIOD_BALANCES wppb
       WHERE  wppb.pac_period_id = p_pac_period_id
       AND    wppb.cost_group_id = p_cost_group_id
       AND    wppb.wip_entity_id =  p_entity_id
       AND    NVL(wppb.line_id, -99) = nvl(p_line_id,-99)
       AND    wppb.operation_seq_num <= decode(p_scrap,1,p_op_seq,
                                                         wppb.operation_seq_num);

--Added decode for Lot based materials project for R12
--Divide the value of qpa by comp_yield_factor
CURSOR c_wro(c_op_sequence NUMBER) IS
       SELECT wro.inventory_item_id component,
              Decode(wro.basis_type,
                          2, (wro.quantity_per_assembly / l_lot_size),
                          wro.quantity_per_assembly) / decode(l_include_comp_yield,
                                                              1, nvl(wro.component_yield_factor,1),
                                                              1) quantity_per_assembly
       FROM   WIP_REQUIREMENT_OPERATIONS wro
       WHERE  wro.wip_entity_id = p_entity_id
       AND    nvl(wro.repetitive_schedule_id ,-99) = nvl(l_repetitive_schedule_id,-99)
       AND    wro.operation_seq_num = c_op_sequence
       AND    wro.wip_supply_type NOT IN (4,5,6);

CURSOR c_cost_element(op_sequence_num NUMBER,component NUMBER) IS
       SELECT cost_element_id cst_ele_id
       FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
       WHERE  cprocd.pac_period_id = p_pac_period_id
       AND    cprocd.cost_group_id = p_cost_group_id
       AND    cprocd.wip_entity_id = p_entity_id
       AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
       AND    cprocd.operation_seq_num = op_sequence_num
       AND    cprocd.inventory_item_id = component;

type t_cst_element_cost is table of number
             index by binary_integer;

l_op_relieved_comp_cost t_cst_element_cost;
l_job_balance t_cst_element_cost;
l_prior_relieved_comp_cost t_cst_element_cost;

l_applied_qty               NUMBER;
l_record_exists             NUMBER;
l_current_period_cost       NUMBER;
l_avl_relieve_qty           NUMBER;
l_avl_relieve_value         NUMBER;
l_relieved_qty              NUMBER;
l_skip_below_process        NUMBER;
l_prior_relieved_value      NUMBER;
l_prior_relieved_qty        NUMBER;
l_required_qty              NUMBER;
l_assembly_return_cnt       NUMBER;
l_entity_type               NUMBER;
l_stmt_num                  NUMBER;
l_err_num                   NUMBER;
l_err_code                  VARCHAR2(240);
l_err_msg                   VARCHAR2(240);

l_api_name            CONSTANT VARCHAR2(30) := 'Relief_BOM_Quantity';
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
                        l_api_name || ' <<< Parameters:
                        p_pac_period_id = ' || p_pac_period_id || '
                        p_prior_period_id = ' || p_prior_period_id || '
                        p_entity_id = ' || p_entity_id || '
                        p_line_id = ' || p_line_id || '
                        p_net_qty = ' || p_net_qty ||'
                        p_final_completion_flag = ' || p_final_completion_flag ||'
                        p_scrap = ' || p_scrap ||'
                        p_op_seq = ' || p_op_seq );
  END IF;

  l_stmt_num := 0;
  -- Lot based materials project for R12, get the lot size of job
  l_lot_size := 1;

  ------------------------------------------------------
  -- Get the Organization id for Component yield project
  -- Get the entity type for LotBased project
  ------------------------------------------------------
  SELECT entity_type,
         organization_id
  INTO   l_entity_type,
         l_org_id
  FROM   wip_entities
  WHERE  wip_entity_id = p_entity_id;

  IF (l_entity_type <> 2) THEN -- Exclude repetitive schedules.

      SELECT nvl(start_quantity,1) -- to avoid divide by zero error
      INTO   l_lot_size
      FROM   wip_discrete_jobs
      WHERE  wip_entity_id = p_entity_id;
  ELSE
      -- Get the repetitive_schedule_id for a wip entity id and line id
      SELECT wrs.repetitive_schedule_id
      INTO   l_repetitive_schedule_id
      FROM   wip_repetitive_schedules wrs
      WHERE  wrs.wip_entity_id = p_entity_id
      AND    wrs.line_id = p_line_id;
  END IF;

  ---------------------------------------------------------------------------
  -- Get the value of Include Component yield flag, which will determine
  -- whether to include or not component yield factor in quantity per
  -- assembly
  ---------------------------------------------------------------------------
  SELECT  nvl(include_component_yield, 1)
  INTO    l_include_comp_yield
  FROM    wip_parameters
  WHERE   organization_id = l_org_id;

-------------------------------------
-- Intialize job balance PL/SQL table
-------------------------------------
FOR cost_element in 1..5 LOOP
    l_job_balance(cost_element) := 0;
END LOOP;

FOR op_seq_rec IN c_wip_opseq LOOP
    ---------------------------------------------------
    -- Intialize Operation-Component level PL/SQL table
    ---------------------------------------------------
    l_stmt_num := 10;
    FOR cost_element in 1..5 LOOP
        l_op_relieved_comp_cost(cost_element) := 0;
        l_prior_relieved_comp_cost(cost_element) := 0;
    END LOOP;

    FOR comp_rec IN c_wro(op_seq_rec.operation_seq_num) LOOP
        -------------------------------------------------------
        -- Check record count for this Job, Component in cprocd
        -------------------------------------------------------
        l_stmt_num := 20;
        SELECT COUNT(*)
        INTO   l_record_exists
        FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
        WHERE  cprocd.pac_period_id = p_pac_period_id
        AND    cprocd.cost_group_id = p_cost_group_id
        AND    cprocd.wip_entity_id = p_entity_id
        AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
        AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
        AND    cprocd.inventory_item_id = comp_rec.component
        AND    ROWNUM < 2;

        --------------------------------------------------------------------
        -- If no record exists in cprocd, but there is completion/return txn
        --------------------------------------------------------------------
        IF (l_record_exists = 0 ) THEN
           ------------------------------------------------------------
           -- Repeat for 5 cost elements if no record exists in cprocd
           ------------------------------------------------------------
           l_stmt_num := 30;
           FOR i IN 1..5 LOOP

            l_current_period_cost  := 0;
            l_avl_relieve_qty := 0;
            -----------------------------------------------------
            -- No Final completion exists in this PAC Period
            -----------------------------------------------------
            IF (NVL(p_final_completion_flag,0) <> 1) THEN
               -------------------------------------------------------------------
               -- Calculate required Qty
               -------------------------------------------------------------------
               l_stmt_num := 40;
               l_avl_relieve_qty  :=  p_net_qty * comp_rec.quantity_per_assembly;
               ----------------------------------------------
               -- Get the component cost from current period
               ----------------------------------------------
               BEGIN

                   SELECT   SUM(NVL(cpicd.item_cost,0))
                   INTO     l_current_period_cost
                   FROM     cst_pac_item_costs cpic,
                            cst_pac_item_cost_details cpicd
                   WHERE    cpic.pac_period_id = p_pac_period_id
                   AND      cpic.cost_group_id = p_cost_group_id
                   AND      cpic.inventory_item_id = comp_rec.component
                   AND      cpic.cost_layer_id = cpicd.cost_layer_id
                   AND      cpicd.cost_element_id = i
                   GROUP BY cpicd.cost_element_id;
               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     l_current_period_cost  := 0;
               END;
            END IF;
            -----------------------------------------------------------------------
            -- Add period cost to PL/SQL table. This table value will be used
            -- while updating WPPB table at l_stmt_num := 270
            ------------------------------------------------------------------------
            l_stmt_num := 50;
            l_op_relieved_comp_cost(i) := l_op_relieved_comp_cost(i) + l_current_period_cost * l_avl_relieve_qty;
            -- This is used to find out balance to be relieved from this job in this period
            l_job_balance(i) := l_job_balance(i) + l_current_period_cost * l_avl_relieve_qty;

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
				'Operation Seq :' || op_seq_rec.operation_seq_num || ','||
				'Component :' || comp_rec.component || ','||
				'Cost Element :' || i || ','||
                                'l_record_exists :' || l_record_exists || ','||
                                'l_current_period_cost :' || l_current_period_cost || ','||
                                'l_avl_relieve_qty :' || l_avl_relieve_qty || ','||
                                'l_op_relieved_comp_cost :'  || l_op_relieved_comp_cost(i) || ','||
                                'l_job_balance :'  || l_job_balance(i));
            END IF;

            ------------------------------------------------------
            -- Insert a record into CST_PAC_REQ_OPER_COST_DETAILS
            ------------------------------------------------------
            l_stmt_num := 60;
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
                     Temp_Relieved_value,
                     -- who Columns
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     last_update_login
                    )
            VALUES (p_pac_period_id,
                    p_cost_group_id,
                    p_entity_id,
                    p_line_id,
                    comp_rec.component,
                    i,
                    op_seq_rec.operation_seq_num,
                    0,
                    0,
                    l_current_period_cost * l_avl_relieve_qty,
                    l_avl_relieve_qty,
                    0,
                    l_current_period_cost * l_avl_relieve_qty,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    p_request_id,
                    p_prog_app_id,
                    p_prog_id,
                    sysdate,
                    p_login_id);
           END LOOP;
    ---------------------------------------------------------------------------------------
    -- If record exists in cprocd table and there is(are) Assembly completion/return txn(s)
    ---------------------------------------------------------------------------------------
    ELSE
        -------------------------------------------------------------------------------------------
        -- Loop through the Cost elements for which already record is there in cprocd for Component
        -------------------------------------------------------------------------------------------
        FOR cstelement_rec in c_cost_element(op_seq_rec.operation_seq_num,comp_rec.component ) LOOP

            l_applied_qty := 0;
            l_avl_relieve_value := 0;
            l_avl_relieve_qty := 0;
            l_prior_relieved_value := 0;
            l_prior_relieved_qty := 0;
            l_skip_below_process := 0;
            -------------------------------------------------------------
            -- Calculate the Required Quantity
            -------------------------------------------------------------
            l_stmt_num := 70;
            l_required_qty := p_net_qty * comp_rec.quantity_per_assembly;

               -- Statement level log message for FND logging
               IF (l_sLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                   l_module || '.'||l_stmt_num,
  				   'Operation Seq :' || op_seq_rec.operation_seq_num || ','||
				   'Component :' || comp_rec.component || ','||
                                   'Cost Element :' || cstelement_rec.cst_ele_id || ','||
                                   'p_net_qty :' || p_net_qty || ','||
                                   'l_required_qty :' || l_required_qty || ','||
                                   'quantity_per_assembly :'|| comp_rec.quantity_per_assembly ||','||
                                   'l_skip_below_process :'|| l_skip_below_process ||','||
                                   'p_final_completion_flag :'  || p_final_completion_flag);
               END IF;


            ------------------------------------------------------
            -- p_net_qty < 0 then get Avg of Prior Relieved Value
            ------------------------------------------------------
            IF (p_net_qty < 0) THEN
               BEGIN
               l_stmt_num := 80;
               SELECT nvl(relieved_value,0),
                     decode(nvl(relieved_quantity, 0),
                                0,1,
                                nvl(relieved_quantity, 0))
               INTO   l_avl_relieve_value,
                      l_avl_relieve_qty
               FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
               WHERE  cprocd.pac_period_id = p_prior_period_id
               AND    cprocd.cost_group_id = p_cost_group_id
               AND    cprocd.wip_entity_id = p_entity_id
               AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
               AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
               AND    cprocd.inventory_item_id = comp_rec.component
               AND    cprocd.cost_element_id = cstelement_rec.cst_ele_id;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_avl_relieve_value := 0;
                 l_avl_relieve_qty := 1; --To avoid zero Division error
               END;
               ----------------------------------------------------------
               -- Calculate to be Relived value in case of p_net_qty < 0
               ----------------------------------------------------------
               l_stmt_num := 90;
               l_avl_relieve_value := (l_avl_relieve_value/l_avl_relieve_qty) * l_required_qty;
               l_avl_relieve_qty := l_required_qty;
               ------------------------------------------------------------------
               -- Add the Component Relieve value to the Operation Relieve value
               ------------------------------------------------------------------
               l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) :=
                                                  l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) +
                                                  l_avl_relieve_value;
               -- This is used to find out balance to be relieved from this job in this period
               -- For more Assembly returns than Assembly completions then sign of p_net_qty is negative.
               -- So making sign to opposite sign.
               l_job_balance(cstelement_rec.cst_ele_id) := l_job_balance(cstelement_rec.cst_ele_id) + l_avl_relieve_value * (-1);

               -- Statement level log message for FND logging
               IF (l_sLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                   l_module || '.'||l_stmt_num,
                                   'l_avl_relieve_value :' || l_avl_relieve_value || ','||
                                   'l_avl_relieve_qty :'  || l_avl_relieve_qty || ','||
                                   'l_op_relieved_comp_cost :' || l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) || ','||
                                   'l_job_balance :'  || l_job_balance(cstelement_rec.cst_ele_id));
               END IF;

            ELSE -- p_net_qty > 0 OR  p_net_qty = 0

            -------------------------------------------------------------------------------------
            -- p_net_qty = 0, Assembly completions cancels Assembly returns
            -------------------------------------------------------------------------------------
            l_stmt_num := 100;
            IF ( p_net_qty = 0) THEN

               --------------------------------------
               --Check Final completion exists or not
               --------------------------------------
               IF (p_final_completion_flag = 1) THEN

                   ------------------------------------------------
                   -- Get the Assembly return qty in this period
                   ------------------------------------------------
                   l_stmt_num := 110;
                   SELECT sum(primary_quantity)
                   INTO   l_assembly_return_cnt
                   FROM   mtl_material_transactions mmt
                   WHERE  mmt.transaction_source_id =  p_entity_id
                   AND    mmt.transaction_action_id = 32
                   AND    mmt.transaction_source_type_id = 5
                   AND    nvl(mmt.repetitive_line_id,-99) = nvl(p_line_id,-99)
                   AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                                   AND  (TRUNC(p_end_date) + 0.99999);

                   -------------------------------------------------------------------
                   -- Get the Avg of Prior Relieved Value.
                   -------------------------------------------------------------------
                   l_stmt_num := 120;
                   BEGIN
                       SELECT nvl(Relieved_Value,0),
                              decode(sign(nvl(Relieved_quantity,0)),
                                     0,1,
                                     Relieved_quantity)
                       INTO   l_prior_relieved_value,
                              l_prior_relieved_qty
                       FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
                       WHERE  cprocd.wip_entity_id = p_entity_id
                       AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
                       AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
                       AND    cprocd.inventory_item_id = comp_rec.component
                       AND    cprocd.cost_element_id = cstelement_rec.cst_ele_id
                       AND    cprocd.cost_group_id = p_cost_group_id
                       AND    cprocd.pac_period_id = p_prior_period_id;
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            l_prior_relieved_value := 0;
                            l_prior_relieved_qty := 1; -- To avoid Zero division error
                   END;
                   ----------------------------------------------------------------------------
                   -- Add the Net value = Avg of Prior Relieved Value * Assmebly return qty * qpa
                   -- to PL/SQL table. This used to update the WPPB's TEMP column value
                   -- and cprocd's Temp_Relieved_value
                   -----------------------------------------------------------------------------
                   l_prior_relieved_value := (l_prior_relieved_value / l_prior_relieved_qty) *
                                                                       l_assembly_return_cnt *
                                                                       comp_rec.quantity_per_assembly;
                   l_prior_relieved_comp_cost(cstelement_rec.cst_ele_id) := l_prior_relieved_comp_cost(cstelement_rec.cst_ele_id) +
                                                                            (-1) * l_prior_relieved_value;
                   -- This is used to find out balance to be relieved from this job in this period
                   l_job_balance(cstelement_rec.cst_ele_id) := l_job_balance(cstelement_rec.cst_ele_id) + (-1) * l_prior_relieved_value;

                   -- Statement level log message for FND logging
                   IF (l_sLog) THEN
                       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                       l_module || '.'||l_stmt_num,
                                       'l_assembly_return_cnt :' || l_assembly_return_cnt || ','||
                                       'l_prior_relieved_value :'  || l_prior_relieved_value || ','||
                                       'l_prior_relieved_comp_cost :' ||  l_prior_relieved_comp_cost(cstelement_rec.cst_ele_id) || ','||
                                       'l_job_balance :'  || l_job_balance(cstelement_rec.cst_ele_id));
                   END IF;
               ELSE
               -------------------------------------------------------------------
               -- No final completion then relieve at average of prior completions
               -------------------------------------------------------------------
               l_stmt_num := 130;
                   BEGIN
                       SELECT nvl(relieved_value,0),
                              decode(nvl(relieved_quantity, 0),
                                      0,1,
                                     nvl(relieved_quantity, 0))
                       INTO   l_avl_relieve_value,
                              l_avl_relieve_qty
                       FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
                       WHERE  cprocd.pac_period_id = p_prior_period_id
                       AND    cprocd.cost_group_id = p_cost_group_id
                       AND    cprocd.wip_entity_id = p_entity_id
                       AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
                       AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
                       AND    cprocd.inventory_item_id = comp_rec.component
                       AND    cprocd.cost_element_id = cstelement_rec.cst_ele_id;
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                         l_avl_relieve_value := 0;
                         l_avl_relieve_qty := 1; --To avoid zero Division error
                   END;
                   ---------------------------------------------------------------------
                   -- Calculate to be Relived value = average of prior completions
                   -- make l_avl_relieve_qty to zero so subsequent cprocd's relived_qty
                   -- column update will not changed in this case
                   -- Update the new variable l_skip_below_process = 1
                   -- So that we can skip the
                   ---------------------------------------------------------------------
                   l_stmt_num := 140;
                   l_avl_relieve_value := (l_avl_relieve_value/l_avl_relieve_qty);
                   l_avl_relieve_qty := 0;
                   l_skip_below_process := 1;

                   ------------------------------------------------------------------
                   -- Add the Component Relieve value to the Operation Relieve value
                   ------------------------------------------------------------------
                   l_stmt_num := 150;
                   l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) :=
                                                      l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) +
                                                      l_avl_relieve_value;
                   -- This is used to find out balance to be relieved from this job in this period
                   l_job_balance(cstelement_rec.cst_ele_id) := l_job_balance(cstelement_rec.cst_ele_id) + l_avl_relieve_value;

                   -- Statement level log message for FND logging
                   IF (l_sLog) THEN
                       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                       l_module || '.'||l_stmt_num,
                                       'l_skip_below_process :' || l_skip_below_process || ','||
                                       'l_avl_relieve_value :'  || l_avl_relieve_value || ','||
                                       'l_op_relieved_comp_cost :' ||  l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) || ','||
                                       'l_job_balance :'  || l_job_balance(cstelement_rec.cst_ele_id));
                   END IF;
               END IF;

            END IF; --End of IF ( p_net_qty = 0)

            -----------------------------------------------------------------------------
            -- Check to skip the below process or not. In case of p_net_qty = 0 and
            --  no final completion then l_skip_below_process = 1, below part is  skipped
            -- in all other cases below IF will be executed
            -----------------------------------------------------------------------------
            IF (l_skip_below_process <> 1 ) THEN
            ------------------------------------------------------------------------
            -- Get the Available to Relieve Value and Available to Relieve Quantity
            -- applied quantity and relieved quantity
            ------------------------------------------------------------------------
            l_stmt_num := 160;
            SELECT (nvl(applied_value,0) - nvl(relieved_value,0) - nvl(comp_variance,0)),
                    nvl(applied_quantity, 0),
                   (nvl(applied_quantity, 0) - nvl(relieved_quantity, 0)),
                   nvl(relieved_quantity, 0)
            INTO   l_avl_relieve_value,
                   l_applied_qty,
                   l_avl_relieve_qty,
                   l_relieved_qty
            FROM   CST_PAC_REQ_OPER_COST_DETAILS cprocd
            WHERE  cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
            AND    cprocd.inventory_item_id = comp_rec.component
            AND    cprocd.cost_element_id = cstelement_rec.cst_ele_id;

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                'l_applied_qty :'  || l_applied_qty || ','||
                                'l_avl_relieve_qty :' ||  l_avl_relieve_qty || ','||
                                'l_relieved_qty :'  || l_relieved_qty);
            END IF;

            ---------------------------------------------------------------------
            -- Available to Relieve Value and Quantity are zero,
            -- So use Current Periodic Cost for Ordinary completions
            -- If Final completion exists in this period then Relieve Zero Value
            ---------------------------------------------------------------------
            l_stmt_num := 170;
            IF (l_avl_relieve_value = 0 and l_avl_relieve_qty = 0) THEN
               -------------------------------------------------------------------------------------------
               -- Final Completion exists in this period, Ignore Final Completion in case of p_net_qty < 0
               -------------------------------------------------------------------------------------------
               l_stmt_num := 180;
                IF (p_final_completion_flag = 1 AND p_net_qty >= 0) THEN
                   -----------------------------------------------------
                   -- Relieve Zero values
                   -----------------------------------------------------
                   l_avl_relieve_value := 0;
                   --------------------------------------------------------
                   -- Calculate the Relieve Qty in case of Final completion
                   --------------------------------------------------------
                   IF ( (l_required_qty > 0 AND l_applied_qty > l_required_qty) OR
                        (l_required_qty < 0 AND l_applied_qty < l_required_qty)) THEN

                        l_avl_relieve_qty := l_applied_qty - l_relieved_qty;
                        -- Statement level log message for FND logging
                        IF (l_sLog) THEN
                           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                           l_module || '.'||l_stmt_num,
                                           'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                           'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                        END IF;
                   END IF;
                ELSE
                  l_stmt_num := 190;
                  SELECT SUM(NVL(cpicd.item_cost,0))
                  INTO   l_current_period_cost
                  FROM   cst_pac_item_costs cpic,
                         cst_pac_item_cost_details cpicd
                  WHERE  cpic.pac_period_id = p_pac_period_id
                  AND    cpic.cost_group_id = p_cost_group_id
                  AND    cpic.inventory_item_id = comp_rec.component
                  AND    cpic.cost_layer_id = cpicd.cost_layer_id
                  AND    cpicd.cost_element_id = cstelement_rec.cst_ele_id;

                  l_avl_relieve_value := l_current_period_cost * l_required_qty;
                  l_avl_relieve_qty := l_required_qty;
                   -- Statement level log message for FND logging
                   IF (l_sLog) THEN
                       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                       l_module || '.'||l_stmt_num,
                                       'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                       'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                   END IF;
                END IF; -- End of IF at l_stmt_num := 180
            --------------------------------------------------------------------------
            -- Available to Relieve Value and Quantity are negative OR
            -- Available to Relieve Value and Quantity are positive
            -- So use WIP Avg Cost for Ordinary Completions
            -- If Final completion exists in this period then Relieve Available Value
            --------------------------------------------------------------------------
            ELSIF ((l_avl_relieve_value < 0 AND l_avl_relieve_qty < 0) OR
                  (l_avl_relieve_value > 0 and l_avl_relieve_qty > 0)) THEN

               --------------------------------------------------------------------------------------------
               -- Final Completion exists in this period, Ignore Final Completion in case of p_net_qty <0
               --------------------------------------------------------------------------------------------
               l_stmt_num := 200;
               IF (p_final_completion_flag = 1 AND p_net_qty >= 0 ) THEN

                  l_avl_relieve_value := l_avl_relieve_value;
                  --------------------------------------------------------
                  -- Calculate the Relieve Qty in case of Final completion
                  --------------------------------------------------------
                  IF ( (l_required_qty > 0 AND l_applied_qty > l_required_qty) OR
                       (l_required_qty < 0 AND l_applied_qty < l_required_qty)) THEN

                        l_avl_relieve_qty := l_applied_qty - l_relieved_qty;
                        -- Statement level log message for FND logging
                        IF (l_sLog) THEN
                           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                           l_module || '.'||l_stmt_num,
                                           'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                           'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                        END IF;
                  END IF;

               ELSE -- Ordinary Completion Only
                 ----------------------------------------------------------------
                 -- Required Quantity is less than or Equal to Available Quantity
                 ----------------------------------------------------------------
                 l_stmt_num := 210;
                 -- Added Modified new condition
                 IF  (l_required_qty = 0 OR
                     (l_required_qty > 0 and l_avl_relieve_qty > 0 and l_required_qty <= l_avl_relieve_qty) OR
                     (l_required_qty < 0 and l_avl_relieve_qty < 0 and l_required_qty >= l_avl_relieve_qty)) THEN

                     l_avl_relieve_value := (l_avl_relieve_value/l_avl_relieve_qty) *  l_required_qty;
                     l_avl_relieve_qty := l_required_qty;

                     -- Statement level log message for FND logging
                     IF (l_sLog) THEN
                        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                        l_module || '.'||l_stmt_num,
                                        'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                        'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                     END IF;
                 ELSE -- Required Quantity is more than Available Quantity
                    ---------------------------------------------------
                    -- Get the Current Periodic Cost
                    ---------------------------------------------------
                    l_stmt_num := 220;
                    SELECT SUM(NVL(cpicd.item_cost,0))
                    INTO   l_current_period_cost
                    FROM   cst_pac_item_costs cpic,
                           cst_pac_item_cost_details cpicd
                    WHERE  cpic.pac_period_id = p_pac_period_id
                    AND    cpic.cost_group_id = p_cost_group_id
                    AND    cpic.inventory_item_id = comp_rec.component
                    AND    cpic.cost_layer_id = cpicd.cost_layer_id
                    AND    cpicd.cost_element_id = cstelement_rec.cst_ele_id;

                    ------------------------------------------------------------------------------------------------------
                    -- Relieve Value = Available to Relieve Value + (Required qty - Available to Relieve qty ) * PWAC Cost
                    -- Required qty = p_net_qty * comp_rec.quantity_per_assembly
                    ------------------------------------------------------------------------------------------------------
                    l_avl_relieve_value := l_avl_relieve_value + (l_required_qty - l_avl_relieve_qty) *
                                                                  l_current_period_cost;
                    l_avl_relieve_qty := l_required_qty;

                    -- Statement level log message for FND logging
                     IF (l_sLog) THEN
                        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                        l_module || '.'||l_stmt_num,
                                        'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                        'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                     END IF;
                 END IF; -- end of IF l_stmt_num := 210

               END IF; -- End of Final Completion exists in this period, End of l_stmt_num := 200
            ------------------------------------------------------------------------------------------
            -- Available to Relieve Value and Available to Relieve Quantity both are opposite in signs
            ------------------------------------------------------------------------------------------
            ELSIF ((l_avl_relieve_value < 0 AND l_avl_relieve_qty >= 0) OR
                   (l_avl_relieve_value > 0 AND l_avl_relieve_qty <= 0)) THEN
                    --------------------------------------------------------------------------------------------
                    -- Final Completion exists in this period, Ignore Final Completion in case of p_net_qty < 0
                    --------------------------------------------------------------------------------------------
                    l_stmt_num := 240;
                    IF (p_final_completion_flag = 1 AND p_net_qty >= 0) THEN
                        -------------------------------------------
                        -- Relieve Available Value from Job
                        -------------------------------------------
                        l_avl_relieve_value := l_avl_relieve_value;
                        --------------------------------------------------------
                        -- Calculate the Relieve Qty in case of Final completion
                        --------------------------------------------------------
                        IF ( (l_required_qty > 0 AND l_applied_qty > l_required_qty) OR
                             (l_required_qty < 0 AND l_applied_qty < l_required_qty)) THEN

                             l_avl_relieve_qty := l_applied_qty - l_relieved_qty;
                             -- Statement level log message for FND logging
                             IF (l_sLog) THEN
                                 FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                                 l_module || '.'||l_stmt_num,
                                                 'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                                 'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                             END IF;
                        END IF;
                    ELSE
                        -------------------------------------------------------------
                        -- Ordinary Cmpletions Only, So get the Current Periodic Cost
                        -------------------------------------------------------------
                        l_stmt_num := 250;
                        SELECT SUM(NVL(cpicd.item_cost,0))
                        INTO   l_current_period_cost
                        FROM   cst_pac_item_costs cpic,
                               cst_pac_item_cost_details cpicd
                        WHERE  cpic.pac_period_id = p_pac_period_id
                        AND    cpic.cost_group_id = p_cost_group_id
                        AND    cpic.inventory_item_id = comp_rec.component
                        AND    cpic.cost_layer_id = cpicd.cost_layer_id
                        AND    cpicd.cost_element_id = cstelement_rec.cst_ele_id;

                       l_avl_relieve_value := l_current_period_cost * l_required_qty;
                       l_avl_relieve_qty := l_required_qty;

                       -- Statement level log message for FND logging
                       IF (l_sLog) THEN
                           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                           l_module || '.'||l_stmt_num,
                                           'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                           'l_avl_relieve_qty :'  || l_avl_relieve_qty);
                       END IF;
                    END IF; -- End of IF at l_stmt_num := 240
            END IF; -- End of IF at l_stmt_num := 170

            ------------------------------------------------------------------
            -- Add the Component Relieve value to the Operation Relieve value
            ------------------------------------------------------------------
            l_stmt_num := 250;
            l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) :=
                                               l_op_relieved_comp_cost(cstelement_rec.cst_ele_id) +
                                               l_avl_relieve_value;
            -- This is used to find out balance to be relieved from this job in this period
            l_job_balance(cstelement_rec.cst_ele_id) := l_job_balance(cstelement_rec.cst_ele_id) + l_avl_relieve_value;

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                'l_avl_relieve_qty :'  || l_avl_relieve_qty);
            END IF;
           END IF; -- End of IF l_skip_below_process <> 1

         END IF; -- End of IF p_net_qty < 0

            ------------------------------------------------------
            -- Update cprocd table with Calculated Relieved value
            ------------------------------------------------------
            l_stmt_num := 260;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Relieved_value = nvl(cprocd.Relieved_Value,0) +
                                                decode(p_net_qty,
                                                       0,decode(p_final_completion_flag,
                                                                 0, 0,
                                                                 NULL,0,
                                                                 l_avl_relieve_value),
                                                        l_avl_relieve_value),
                   cprocd.Temp_Relieved_value = l_avl_relieve_value + (-1) * l_prior_relieved_value,
                   -- Same as TEMP column in WPPB table. This will be used if Total Job value is -ve then
                   -- Update the Comp_variance = Comp_variance + Temp_Relieved_value at the end
                   cprocd.Relieved_quantity = nvl(cprocd.Relieved_quantity,0) + l_avl_relieve_qty,
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.operation_seq_num = op_seq_rec.operation_seq_num
            AND    cprocd.inventory_item_id = comp_rec.component
            AND    cprocd.cost_element_id = cstelement_rec.cst_ele_id
            AND    cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id;

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                'l_avl_relieve_value :' ||l_avl_relieve_value || ','||
                                'l_prior_relieved_value :' ||l_prior_relieved_value || ','||
                                'l_avl_relieve_qty :'  || l_avl_relieve_qty);
            END IF;
         END LOOP; -- End of Cost Element Loop

     END IF;  -- End of l_record_exists check

  END LOOP; -- End of Component Loop

     -----------------------------------------------------------------------------------
     -- Update the wip_pac_period_balances with relieved values
     -----------------------------------------------------------------------------------
     -- OUT columns will not be updated if p_net_qty = 0 and p_final_completion_flag <>1
     -- In this case only TEMP columns are updated
     ------------------------------------------------------------------------------------
     l_stmt_num := 270;
     UPDATE wip_pac_period_balances wppb
     SET    wppb.pl_material_out = wppb.pl_material_out + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                           0,0,
                                                                           NULL,0,
                                                                           l_op_relieved_comp_cost(1)),
                                                                   l_op_relieved_comp_cost(1)),
            wppb.pl_material_temp = wppb.pl_material_temp + l_op_relieved_comp_cost(1)
                                                          + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                          1, l_prior_relieved_comp_cost(1),
                                                                          0),
                                                                0),

            wppb.pl_material_overhead_out = wppb.pl_material_overhead_out + decode(p_net_qty,
                                                                                   0,decode(p_final_completion_flag,
                                                                                               0,0,
                                                                                               NULL,0,
                                                                                               l_op_relieved_comp_cost(2)),
                                                                                   l_op_relieved_comp_cost(2)),
            wppb.pl_material_overhead_temp = wppb.pl_material_overhead_temp + l_op_relieved_comp_cost(2)
                                                          + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                          1, l_prior_relieved_comp_cost(2),
                                                                          0),0),

            wppb.pl_resource_out = wppb.pl_resource_out +  decode(p_net_qty,
                                                                     0,decode(p_final_completion_flag,
                                                                                        0,0,
                                                                                        NULL,0,
                                                                                        l_op_relieved_comp_cost(3)),
                                                                     l_op_relieved_comp_cost(3)),
            wppb.pl_resource_temp = wppb.pl_resource_temp + l_op_relieved_comp_cost(3)
                                                          + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                          1, l_prior_relieved_comp_cost(3),
                                                                          0), 0),

            wppb.pl_outside_processing_out = wppb.pl_outside_processing_out + decode(p_net_qty,
                                                                                     0,decode(p_final_completion_flag,
                                                                                              0,0,
                                                                                              NULL,0,
                                                                                              l_op_relieved_comp_cost(4)),
                                                                                     l_op_relieved_comp_cost(4)),
            wppb.pl_outside_processing_temp = wppb.pl_outside_processing_temp + l_op_relieved_comp_cost(4)
                                                          + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                          1, l_prior_relieved_comp_cost(4),
                                                                          0), 0),

            wppb.pl_overhead_out = wppb.pl_overhead_out +  decode(p_net_qty,
                                                                  0,decode(p_final_completion_flag,
                                                                           0,0,
                                                                           NULL,0,
                                                                           l_op_relieved_comp_cost(5)),
                                                                  l_op_relieved_comp_cost(5)),
            wppb.pl_overhead_temp = wppb.pl_overhead_temp + l_op_relieved_comp_cost(5)
                                                          + decode(p_net_qty,0,
                                                                   decode(p_final_completion_flag,
                                                                          1, l_prior_relieved_comp_cost(5),
                                                                          0),0),

            wppb.last_update_date = SYSDATE,
            wppb.last_updated_by = p_user_id,
            wppb.last_update_login = p_login_id,
            wppb.request_id = p_request_id,
            wppb.program_application_id = p_prog_app_id,
            wppb.program_id = p_prog_id,
            wppb.program_update_date = SYSDATE

     WHERE  wppb.wip_entity_id = p_entity_id
     AND    wppb.pac_period_id = p_pac_period_id
     AND    wppb.cost_type_id = p_cost_type_id
     AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99)
     AND    wppb.cost_group_id = p_cost_group_id
     AND    wppb.operation_seq_num = op_seq_rec.operation_seq_num;

     END LOOP; -- End of Operation Sequence Loop

     -----------------------------------------------------------------------------
     -- Check Cost Element balance to be relieved from the job are Negative or Not
     -----------------------------------------------------------------------------

     IF (l_job_balance(1) < 0) THEN

            l_stmt_num := 280;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Comp_variance = nvl(cprocd.Comp_variance,0) + nvl(cprocd.Temp_Relieved_value,0),
                   cprocd.Relieved_value = nvl(cprocd.Relieved_value,0) - nvl(cprocd.Temp_Relieved_value,0),
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.cost_element_id = 1;  -- Material Cost Element

            l_stmt_num := 290;
            UPDATE WIP_PAC_PERIOD_BALANCES wppb
                   -- New column to store the variance in case if total job balance is negative
                   -- This column is not storing accumlated value
            SET    wppb.pl_material_temp_var = wppb.pl_material_temp,
                   --   This column is  storing accumlated values of variance
                   wppb.pl_material_var = nvl(wppb.pl_material_var,0) + nvl(wppb.pl_material_temp,0),
                   --Subtract the variance column value from OUT column
                   wppb.pl_material_out = wppb.pl_material_out - wppb.pl_material_temp,
                   -- Make TEMP value to Zero
                   wppb.pl_material_temp = 0,

                   wppb.last_update_date = SYSDATE,
                   wppb.last_updated_by = p_user_id,
                   wppb.last_update_login = p_login_id,
                   wppb.request_id = p_request_id,
                   wppb.program_application_id = p_prog_app_id,
                   wppb.program_id = p_prog_id,
                   wppb.program_update_date = SYSDATE
            WHERE  wppb.cost_group_id = p_cost_group_id
            AND    wppb.pac_period_id = p_pac_period_id
            AND    wppb.cost_type_id = p_cost_type_id
            AND    wppb.wip_entity_id = p_entity_id
            AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99);

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                ' Negative Value in Job of Cost element = 1');
            END IF;
     END IF;

     IF (l_job_balance(2) < 0) THEN

            l_stmt_num := 300;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Comp_variance = nvl(cprocd.Comp_variance,0) + cprocd.Temp_Relieved_value,
                   cprocd.Relieved_value = cprocd.Relieved_value - cprocd.Temp_Relieved_value,
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.cost_element_id = 2;  -- Material Overhead Cost Element

            l_stmt_num := 310;
            UPDATE wip_pac_period_balances wppb
                    -- New column to store the variance in case total job balance is negative
            SET    wppb.pl_material_overhead_temp_var = wppb.pl_material_overhead_temp,
                   --   This column is  storing accumlated values of variance
                   wppb.pl_material_overhead_var = nvl(wppb.pl_material_overhead_var,0) + nvl(wppb.pl_material_overhead_temp,0),
                   --Subtract the variance column value from OUT column
                   wppb.pl_material_overhead_out = wppb.pl_material_overhead_out - wppb.pl_material_overhead_temp,
                   -- Make TEMP value to Zero
                   wppb.pl_material_overhead_temp = 0,
                   wppb.last_update_date = SYSDATE,
                   wppb.last_updated_by = p_user_id,
                   wppb.last_update_login = p_login_id,
                   wppb.request_id = p_request_id,
                   wppb.program_application_id = p_prog_app_id,
                   wppb.program_id = p_prog_id,
                   wppb.program_update_date = SYSDATE
            WHERE  wppb.cost_group_id = p_cost_group_id
            AND    wppb.pac_period_id = p_pac_period_id
            AND    wppb.cost_type_id = p_cost_type_id
            AND    wppb.wip_entity_id = p_entity_id
            AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99);

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                ' Negative Value in Job for Cost element = 2');
            END IF;
     END IF;

     IF (l_job_balance(3) < 0) THEN

            l_stmt_num := 320;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Comp_variance = nvl(cprocd.Comp_variance,0) + cprocd.Temp_Relieved_value,
                   cprocd.Relieved_value = cprocd.Relieved_value - cprocd.Temp_Relieved_value,
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.cost_element_id = 3;  -- Resource Cost Element

            l_stmt_num := 330;
            UPDATE wip_pac_period_balances wppb
                   -- New column to store the variance in case if total job balance is negative
            SET    wppb.pl_resource_temp_var = wppb.pl_resource_temp,
                   --   This column is  storing accumlated values of variance
                   wppb.pl_resource_var = nvl(wppb.pl_resource_var,0) + nvl(wppb.pl_resource_temp,0),
                   --Subtract the variance column value from OUT column
                   wppb.pl_resource_out = wppb.pl_resource_out - wppb.pl_resource_temp,
                   -- Make TEMP value to Zero
                   wppb.pl_resource_temp = 0,
                   wppb.last_update_date = SYSDATE,
                   wppb.last_updated_by = p_user_id,
                   wppb.last_update_login = p_login_id,
                   wppb.request_id = p_request_id,
                   wppb.program_application_id = p_prog_app_id,
                   wppb.program_id = p_prog_id,
                   wppb.program_update_date = SYSDATE
            WHERE  wppb.cost_group_id = p_cost_group_id
            AND    wppb.pac_period_id = p_pac_period_id
            AND    wppb.cost_type_id = p_cost_type_id
            AND    wppb.wip_entity_id = p_entity_id
            AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99);

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                ' Negative Value in Job for Cost element = 3');
            END IF;
     END IF;

     IF (l_job_balance(4) < 0) THEN

            l_stmt_num := 340;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Comp_variance = nvl(cprocd.Comp_variance,0) + cprocd.Temp_Relieved_value,
                   cprocd.Relieved_value = cprocd.Relieved_value - cprocd.Temp_Relieved_value,
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.cost_element_id = 4;  -- Outside Processing Cost Element

            l_stmt_num := 350;
            UPDATE wip_pac_period_balances wppb
                   -- New column to store the varaince in case total job balance is negative
            SET    wppb.pl_outside_processing_temp_var = wppb.pl_outside_processing_temp,
                   --   This column is  storing accumlated values of variance
                   wppb.pl_outside_processing_var = nvl(wppb.pl_outside_processing_var,0) + nvl(wppb.pl_outside_processing_temp,0),
                   --Subtract the variance column value from OUT column
                   wppb.pl_outside_processing_out = wppb.pl_outside_processing_out - wppb.pl_outside_processing_temp,
                   -- Make TEMP value to Zero
                   wppb.pl_outside_processing_temp = 0,
                   wppb.last_update_date = SYSDATE,
                   wppb.last_updated_by = p_user_id,
                   wppb.last_update_login = p_login_id,
                   wppb.request_id = p_request_id,
                   wppb.program_application_id = p_prog_app_id,
                   wppb.program_id = p_prog_id,
                   wppb.program_update_date = SYSDATE
            WHERE  wppb.cost_group_id = p_cost_group_id
            AND    wppb.pac_period_id = p_pac_period_id
            AND    wppb.cost_type_id = p_cost_type_id
            AND    wppb.wip_entity_id = p_entity_id
            AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99);

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                ' Negative Value in Job for Cost element = 4');
            END IF;
     END IF;

     IF (l_job_balance(5) < 0) THEN

            l_stmt_num := 360;
            UPDATE CST_PAC_REQ_OPER_COST_DETAILS cprocd
            SET    cprocd.Comp_variance = nvl(cprocd.Comp_variance,0) + cprocd.Temp_Relieved_value,
                   cprocd.Relieved_value = cprocd.Relieved_value - cprocd.Temp_Relieved_value,
                   cprocd.last_update_date = SYSDATE,
                   cprocd.last_updated_by = p_user_id,
                   cprocd.last_update_login = p_login_id,
                   cprocd.request_id = p_request_id,
                   cprocd.program_application_id = p_prog_app_id,
                   cprocd.program_id = p_prog_id,
                   cprocd.program_update_date = SYSDATE
            WHERE  cprocd.cost_group_id = p_cost_group_id
            AND    cprocd.pac_period_id = p_pac_period_id
            AND    cprocd.wip_entity_id = p_entity_id
            AND    nvl(cprocd.line_id, -99) = nvl(p_line_id,-99)
            AND    cprocd.cost_element_id = 5;  -- Overhead Processing Cost Element

            l_stmt_num := 370;
            UPDATE wip_pac_period_balances wppb
                   -- New column to store the varaince in case total job balance is negative
            SET    wppb.pl_overhead_temp_var = wppb.pl_overhead_temp,
                   --   This column is  storing accumlated values of variance
                   wppb.pl_overhead_var = nvl(wppb.pl_overhead_var,0) + nvl(wppb.pl_overhead_temp,0),
                   --Subtract the variance column value from OUT column
                   wppb.pl_overhead_out = wppb.pl_overhead_out - wppb.pl_overhead_temp,
                   -- Make TEMP value to Zero
                   wppb.pl_overhead_temp = 0,
                   wppb.last_update_date = SYSDATE,
                   wppb.last_updated_by = p_user_id,
                   wppb.last_update_login = p_login_id,
                   wppb.request_id = p_request_id,
                   wppb.program_application_id = p_prog_app_id,
                   wppb.program_id = p_prog_id,
                   wppb.program_update_date = SYSDATE
            WHERE  wppb.cost_group_id = p_cost_group_id
            AND    wppb.pac_period_id = p_pac_period_id
            AND    wppb.cost_type_id = p_cost_type_id
            AND    wppb.wip_entity_id = p_entity_id
            AND    nvl(wppb.line_id, -99) = nvl(p_line_id,-99);

            -- Statement level log message for FND logging
            IF (l_sLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                                l_module || '.'||l_stmt_num,
                                ' Negative Value in Job for Cost element = 5');
            END IF;
     END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,' Exception '||to_char(l_stmt_num));
        IF (l_uLog) THEN
           FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                           l_module || '.' || l_stmt_num,
                           SQLERRM);
        END IF;
        ROLLBACK;
        x_err_num := SQLCODE;
        x_err_code := NULL;
        x_err_msg := SUBSTR('CSTPPWAS.Relief_BOM_Quantity('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END Relief_BOM_Quantity;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|       process_net_relief                                                     |
*----------------------------------------------------------------------------*/
PROCEDURE process_net_relief (
                                p_pac_period_id             IN    NUMBER,
                                p_prior_period_id           IN    NUMBER,
                                p_cost_group_id             IN    NUMBER,
                                p_cost_type_id              IN    NUMBER,
                                p_legal_entity              IN    NUMBER,
                                p_cost_method               IN    NUMBER,
                                p_cost_layer_id             IN    NUMBER,
                                p_qty_layer_id              IN    NUMBER,
                                p_pac_rates_id              IN    NUMBER,
                                p_entity_type               IN    NUMBER,
                                p_org_id                    IN    NUMBER,
                                p_entity_id                 IN    NUMBER,
                                p_final_completion_flag     IN    NUMBER,
                                p_material_relief_algorithm IN    NUMBER,
                                p_line_id                   IN    NUMBER DEFAULT NULL,
                                p_net_qty                   IN    NUMBER,
                                p_start_date                IN    DATE,
                                p_end_date                  IN    DATE,
                                p_scrap                     IN    NUMBER DEFAULT -1,
                                p_op_seq                    IN    NUMBER DEFAULT NULL,
                                p_master_org_id             IN    NUMBER,
                                p_uom_control               IN    NUMBER,
                                p_user_id                   IN    NUMBER,
                                p_login_id                  IN    NUMBER,
                                p_request_id                IN    NUMBER,
                                p_prog_id                   IN    NUMBER DEFAULT -1,
                                p_prog_app_id               IN    NUMBER DEFAULT -1,
                                p_txn_category              IN    NUMBER,
                                x_err_num                   OUT NOCOPY        NUMBER,
                                x_err_code                  OUT NOCOPY        VARCHAR2,
                                x_err_msg                   OUT NOCOPY        VARCHAR2)
IS
CURSOR c_scrap_txn IS
        SELECT  mmt.transaction_id txn_id,
                mmt.inventory_item_id item_id,
                mmt.primary_quantity pri_qty,
                mmt.organization_id org_id,
                mmt.subinventory_code subinv,
                mmt.transaction_action_id txn_action_id,
                mmt.transaction_source_type_id txn_src_type_id
        FROM    mtl_material_transactions mmt
        WHERE   mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                     AND (TRUNC(p_end_date) + 0.99999)
        AND     mmt.transaction_source_type_id = 5
        AND     mmt.transaction_source_id = p_entity_id
        AND     NVL(mmt.repetitive_line_id,-99) = NVL(p_line_id,-99)
        AND     mmt.transaction_action_id  = 30
        AND     NVL(mmt.operation_seq_num, -1) = NVL(p_op_seq,-1)
        ORDER BY mmt.primary_quantity DESC, mmt.transaction_id; -- minimize the occurences of negative periodic inventory quantity

CURSOR c_assy_txn IS
        SELECT  mmt.transaction_id txn_id,
                mmt.inventory_item_id item_id,
                mmt.primary_quantity pri_qty,
                mmt.organization_id org_id,
                mmt.subinventory_code subinv,
                mmt.transaction_action_id txn_action_id,
                mmt.transaction_source_type_id txn_src_type_id
        FROM    mtl_material_transactions mmt
        WHERE   mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                   AND (TRUNC(p_end_date) + 0.99999)
        AND     mmt.transaction_source_type_id = 5
        AND     mmt.transaction_source_id = p_entity_id
        AND     NVL(mmt.repetitive_line_id,-99) = NVL(p_line_id,-99)
        AND     mmt.transaction_action_id IN (31,32)
        ORDER BY mmt.transaction_action_id, mmt.transaction_id; -- minimize the occurences of negative periodic inventory quantity

l_uom_conv_rate                 NUMBER;
l_conv_net_qty                  NUMBER;
l_item_id                       NUMBER;
l_org_id                        NUMBER;
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_exp_item                      NUMBER;
l_exp_flag                      NUMBER;
l_wip_assy_hook                 NUMBER;
cst_process_error               EXCEPTION;
/* Added new local variables for R12 PAC enhancements */
l_assembly_return_cnt          NUMBER;
l_net_qty                      NUMBER;
l_completed_assembly_qty       NUMBER;
l_net_completion               NUMBER;

/* Start bug6847717 */
l_net_tl_resource_value           NUMBER;
l_net_tl_overhead_value           NUMBER;
l_net_tl_osp_value                NUMBER;
l_net_pl_material_value           NUMBER;
l_net_pl_moh_value                NUMBER;
l_net_pl_resource_value           NUMBER;
l_net_pl_osp_value                NUMBER;
l_net_pl_overhead_value           NUMBER;
/* End bug6847717 */

l_api_name            CONSTANT VARCHAR2(30) := 'process_net_relief';
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
                         l_api_name || ' <<<');

        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.begin',
                        l_api_name || ' <<< Parameters:
                        p_cost_layer_id = ' || p_cost_layer_id || '
                        p_qty_layer_id = ' || p_qty_layer_id || '
                        p_entity_type = ' || p_entity_type || '
                        p_org_id = ' || p_org_id || '
                        p_entity_id = ' || p_entity_id ||'
                        p_final_completion_flag = ' || p_final_completion_flag ||'
                        p_material_relief_algorithm = ' || p_material_relief_algorithm ||'
                        p_line_id = ' || p_line_id ||'
                        p_net_qty = ' || p_net_qty ||'
                        p_scrap = ' || p_scrap ||'
                        p_op_seq = ' || p_op_seq ||'
                        p_txn_category = ' || p_txn_category);
        END IF;
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_wip_assy_hook := -1;

       IF (p_scrap = 1 AND p_entity_type <> 4) THEN

           SELECT SUM(mmt.primary_quantity)
           INTO   l_net_completion
           FROM   mtl_material_transactions mmt
           WHERE  mmt.transaction_source_id = p_entity_id
           AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                        AND (TRUNC(p_end_date) + 0.99999)
           AND    mmt.transaction_source_type_id = 5
           AND    mmt.transaction_action_id IN (31,32);

       END IF;

        ----------------------------------------------------------------------
        -- This proc will be called for those entities/line that have a record
        -- in wppb.
        -- There is no need to check/create Create WIP BAL Rec as such
        -- a record will always exist when this proc is called.
        -- This is becasue a completion/scrap/return always required
        -- a preceding move transactions.  The move transactions
        -- will create the WIPBAL record in the process_wipresovhd
        -- procedure.  For CFMs, the rec will be created while processing
        -- the res_ovhds or material component issue txns.
        ----------------------------------------------------------------------



        ----------------------------------------------------------------------
        -- Reset the Temp columns
        ----------------------------------------------------------------------

        l_stmt_num := 0;

        UPDATE  wip_pac_period_balances wppb
        SET     tl_resource_temp = 0,
                tl_overhead_temp = 0,
                tl_outside_processing_temp = 0,
                pl_material_temp = 0,
                pl_material_overhead_temp = 0,
                pl_resource_temp = 0,
                pl_outside_processing_temp = 0,
                pl_overhead_temp = 0
        WHERE   wppb.pac_period_id = p_pac_period_id
        AND     wppb.cost_group_id = p_cost_group_id
        AND     wppb.wip_entity_id = p_entity_id
        AND     NVL(wppb.line_id,-99) = decode(p_entity_type, 4, -99, NVL(p_line_id,-99));

        ----------------------------------------------------------------------
        -- Relieve Costs
        ----------------------------------------------------------------------


          --------------------------------------------------------------------
          -- Check whether CFM  completion/return/scrap.
          -- For non-scheduled CFMs, Each transaction will be Unique
          -- WIP entity.
          -- For CFMs, We do not distinguish between net completion and return.
          -- The Variance column has no meaning for CFM entities.
          -- Flush/Relieve all costs from the entity as:
          -- IN-OUT-VAR
          --------------------------------------------------------------------

          IF (p_entity_type = 4) THEN

            l_stmt_num := 10;

            UPDATE wip_pac_period_balances wppb
            SET (tl_resource_out,
                 tl_resource_temp,
                 tl_outside_processing_out,
                 tl_outside_processing_temp,
                 tl_overhead_out,
                 tl_overhead_temp,
                 pl_material_out,
                 pl_material_temp,
                 pl_material_overhead_out,
                 pl_material_overhead_temp,
                 pl_resource_out,
                 pl_resource_temp,
                 pl_outside_processing_out,
                 pl_outside_processing_temp,
                 pl_overhead_out,
                 pl_overhead_temp
                ) =
            (SELECT
            (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        -NVL(wppb.tl_resource_var,0)),
            (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        -NVL(wppb.tl_resource_var,0)),
            (NVL(wppb.tl_outside_processing_in,0)
                                - NVL(wppb.tl_outside_processing_out,0)
                                - NVL(wppb.tl_outside_processing_var,0)),
            (NVL(wppb.tl_outside_processing_in,0)
                                - NVL(wppb.tl_outside_processing_out,0)
                                - NVL(wppb.tl_outside_processing_var,0)),
            (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                - NVL(wppb.tl_overhead_var,0)),
            (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                - NVL(wppb.tl_overhead_var,0)),
            (NVL(wppb.pl_material_in,0)-NVL(wppb.pl_material_out,0)
                                - NVL(wppb.pl_material_var,0)),
            (NVL(wppb.pl_material_in,0)-NVL(wppb.pl_material_out,0)
                                - NVL(wppb.pl_material_var,0)),
            (NVL(wppb.pl_material_overhead_in,0)
                                - NVL(wppb.pl_material_overhead_out,0)
                                - NVL(wppb.pl_material_overhead_var,0)),
            (NVL(wppb.pl_material_overhead_in,0)
                                - NVL(wppb.pl_material_overhead_out,0)
                                - NVL(wppb.pl_material_overhead_var,0)),
            (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0)
                                - NVL(wppb.pl_resource_var,0)),
            (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0)
                                - NVL(wppb.pl_resource_var,0)),
            (NVL(wppb.pl_outside_processing_in,0)
                                - NVL(wppb.pl_outside_processing_out,0)
                                - NVL(wppb.pl_outside_processing_var,0)),
            (NVL(wppb.pl_outside_processing_in,0)
                                - NVL(wppb.pl_outside_processing_out,0)
                                - NVL(wppb.pl_outside_processing_var,0)),
            (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)
                                - NVL(wppb.pl_overhead_var,0)),
            (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)
                                - NVL(wppb.pl_overhead_var,0))
             FROM wip_pac_period_balances wppb2,
                  wip_flow_schedules wfs
             WHERE wppb2.pac_period_id = p_pac_period_id
             AND   wppb2.cost_group_id = p_cost_group_id
             AND   wppb2.wip_entity_id = p_entity_id
             AND   wppb2.operation_seq_num = wppb.operation_seq_num
             AND   wfs.wip_entity_id = p_entity_id
            )
            WHERE wppb.pac_period_id = p_pac_period_id
            AND wppb.cost_group_id = p_cost_group_id
            AND wppb.wip_entity_id = p_entity_id
            AND wppb.operation_seq_num <=
                decode(p_scrap,1,nvl(p_op_seq,wppb.operation_seq_num),wppb.operation_seq_num);
          ELSE -- If not CFM completion/return
              /* material Completion Algo is based on BOM */
              /* This algo relieves the material costs based on the BOM */
              l_stmt_num := 20;

              IF ( p_material_relief_algorithm = 0 ) THEN
                Relief_BOM_Quantity(p_pac_period_id          => p_pac_period_id,
                                    p_prior_period_id        => p_prior_period_id,
                                    p_cost_group_id          => p_cost_group_id ,
                                    p_cost_type_id           => p_cost_type_id,
                                    p_entity_id              => p_entity_id,
                                    p_line_id                => p_line_id,
                                    p_net_qty                => p_net_qty,
                                    p_final_completion_flag  => p_final_completion_flag,
                                    p_scrap                  => p_scrap,
                                    p_op_seq                 => p_op_seq,
                                    p_start_date             => p_start_date,
                                    p_end_date               => p_end_date,
                                    p_login_id               => p_login_id,
                                    p_user_id                => p_user_id,
                                    p_request_id             => p_request_id,
                                    p_prog_id                => p_prog_id,
                                    p_prog_app_id            => p_prog_app_id,
                                    x_err_num                => x_err_num,
                                    x_err_code               => x_err_code,
                                    x_err_msg                => x_err_msg );
                 /* Calculation TL resource, Overhead and OSP */
                 /* They always will be relieved based on actuals */
                 IF (p_net_qty > 0) THEN
                         l_stmt_num := 25;

	       /* Bug6847717: Calculate the total value across op_seq */
	       SELECT NVL(SUM(NVL(wppb.tl_resource_in,0)-
                          NVL(wppb.tl_resource_out,0)
                          - NVL(wppb.tl_resource_var,0)),0) net_tl_resource_value,
	              NVL(SUM(NVL(wppb.tl_overhead_in,0)-
                          NVL(wppb.tl_overhead_out,0)
                          - NVL(wppb.tl_overhead_var,0)),0) net_tl_overhead_value,
                      NVL(SUM(NVL(wppb.tl_outside_processing_in,0)-
                          NVL(wppb.tl_outside_processing_out,0)
                          - NVL(wppb.tl_outside_processing_var,0)),0) net_tl_osp_value
                 INTO
                 l_net_tl_resource_value,
                 l_net_tl_overhead_value,
                 l_net_tl_osp_value
               FROM wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                  AND wppb.cost_group_id = p_cost_group_id
                  AND wppb.wip_entity_id = p_entity_id
                  AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                  AND wppb.operation_seq_num <=
                      decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                         /* Final completion exists */
                         IF p_final_completion_flag = 1 THEN

                              UPDATE wip_pac_period_balances wppb
                              SET (tl_resource_out,
                                   tl_resource_temp,
                                   tl_outside_processing_out,
                                   tl_outside_processing_temp,
                                   tl_overhead_out,
                                   tl_overhead_temp
                                  ) =
                                  (SELECT
                                       NVL(wppb.tl_resource_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
						       -NVL(wppb.tl_resource_out,0)
						       -NVL(tl_resource_var,0))
						       +SIGN(l_net_tl_resource_value)
						       +2
						       ),
                                                1,
						(NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                                           - NVL(tl_resource_var,0)),
                                                0
                                             ),
				       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
						       -NVL(wppb.tl_resource_out,0)
						       -NVL(tl_resource_var,0))
						       +SIGN(l_net_tl_resource_value)
						       +2
						       ),
                                                1,
                                                (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                                          - NVL(tl_resource_var,0)),
                                                0
                                             ),
                                       NVL(tl_outside_processing_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
						       -NVL(wppb.tl_outside_processing_out,0)
						       -NVL(wppb.tl_outside_processing_var,0))
						       +SIGN(l_net_tl_osp_value)
						       +2
						       ),
                                                 1,
                                                 (NVL(wppb.tl_outside_processing_in,0)
                                                      - NVL(wppb.tl_outside_processing_out,0)
                                                      - NVL(wppb.tl_outside_processing_var,0)),
                                                 0
                                            ),
				       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
			                               -NVL(wppb.tl_outside_processing_out,0)
                        			       -NVL(wppb.tl_outside_processing_var,0))
						       +SIGN(l_net_tl_osp_value)
						       +2
						       ),
                                               1,
                                               (NVL(wppb.tl_outside_processing_in,0)
                                                  - NVL(wppb.tl_outside_processing_out,0)
                                                  - NVL(wppb.tl_outside_processing_var,0)),
                                               0
                                            ),
                                       NVL(tl_overhead_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
						       -NVL(wppb.tl_overhead_out,0)
						       -NVL(wppb.tl_overhead_var,0))
						       +SIGN(l_net_tl_overhead_value)
						       +2
						       ),
                                              1,
                                             (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                                        - NVL(wppb.tl_overhead_var,0)),
                                             0
                                            ),
				       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
						       -NVL(wppb.tl_overhead_out,0)
						       -NVL(wppb.tl_overhead_var,0))
						       +SIGN(l_net_tl_overhead_value)
						       +2
						       ),
                                              1,
                                              (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                                        - NVL(wppb.tl_overhead_var,0)),
                                              0
                                             )
                                  FROM  wip_pac_period_balances wppb2
                                  WHERE wppb2.pac_period_id =p_pac_period_id
                                  AND   wppb2.cost_group_id = p_cost_group_id
                                  AND   wppb2.wip_entity_id = p_entity_id
                                  AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                                  AND   wppb2.operation_seq_num = wppb.operation_seq_num
                               )
                              WHERE wppb.pac_period_id = p_pac_period_id
                              AND   wppb.cost_group_id = p_cost_group_id
                              AND   wppb.wip_entity_id = p_entity_id
                              AND   NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                              AND   wppb.operation_seq_num <= wppb.operation_seq_num;
                        ELSE    /* No Final completion exists */
                              UPDATE wip_pac_period_balances wppb
                              SET (tl_resource_out,
                                   tl_resource_temp,
                                   tl_outside_processing_out,
                                   tl_outside_processing_temp,
                                   tl_overhead_out,
                                   tl_overhead_temp
                                  ) =
                                  (SELECT
                                       NVL(wppb.tl_resource_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
						       -NVL(wppb.tl_resource_out,0)
						       -NVL(tl_resource_var,0))
						       +SIGN(l_net_tl_resource_value)
						       +2
						       ),
                                               1,
                                               (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                                        - NVL(tl_resource_var,0))*
                                               decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                       NVL(wppb2.relieved_assembly_units,0) - nvl(unrelieved_scrap_quantity,0)),
                                                        0,  1,
                                                       -1,  1,
                                                        p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                       NVL(wppb2.relieved_assembly_units,0) - nvl(wppb2.unrelieved_scrap_quantity,0))
                                                     ),
                                              0
                                             ),
				       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
						       -NVL(wppb.tl_resource_out,0)
						       -NVL(tl_resource_var,0))
						       +SIGN(l_net_tl_resource_value)
						       +2
						       ),
                                               1,
                                              (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                                        - NVL(tl_resource_var,0))*
                                                    decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                            NVL(wppb2.relieved_assembly_units,0) -
                                                            nvl(unrelieved_scrap_quantity,0)),
                                                             0,  1,
                                                             -1, 1,
                                                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                                                          ),
                                               0
                                            ),
                                       NVL(tl_outside_processing_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
						       -NVL(wppb.tl_outside_processing_out,0)
						       -NVL(wppb.tl_outside_processing_var,0))
						       +SIGN(l_net_tl_osp_value)
						       +2
						       ),
                                                1,
                                                (NVL(wppb.tl_outside_processing_in,0)
                                                 - NVL(wppb.tl_outside_processing_out,0)
                                                 - NVL(wppb.tl_outside_processing_var,0))*
                                                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                                NVL(wppb2.relieved_assembly_units,0) -
                                                                NVL(wppb2.unrelieved_scrap_quantity,0)),
                                                                0,  1,
                                                                -1, 1,
                                                                 p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                                                              ),
                                               0
                                            ),
				       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
						       -NVL(wppb.tl_outside_processing_out,0)
						       -NVL(wppb.tl_outside_processing_var,0))
						       +SIGN(l_net_tl_osp_value)
						       +2
						       ),
                                        1,
                                        (NVL(wppb.tl_outside_processing_in,0)
                                                        - NVL(wppb.tl_outside_processing_out,0)
                                                        - NVL(wppb.tl_outside_processing_var,0))*
                                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                                          0,  1,
                                          -1, 1,
                                          p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                                        ),
                                        0
                                      ),
                                       NVL(tl_overhead_out,0) +
				       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
						       -NVL(wppb.tl_overhead_out,0)
						       -NVL(wppb.tl_overhead_var,0))
						       +SIGN(l_net_tl_overhead_value)
						       +2
						       ),
                                        1,
                                        (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                                        - NVL(wppb.tl_overhead_var,0))*
                                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                                          0,  1,
                                          -1, 1,
                                          p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                                        ),
                                        0
                                      ),
				       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
						       -NVL(wppb.tl_overhead_out,0)
						       -NVL(wppb.tl_overhead_var,0))
						       +SIGN(l_net_tl_overhead_value)
						       +2
						       ),
                                        1,
                                        (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                                        - NVL(wppb.tl_overhead_var,0))*
                                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                                             0,  1,
                                          -1, 1,
                                          p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                                    NVL(wppb2.relieved_assembly_units,0) - nvl(wppb2.unrelieved_scrap_quantity,0))
                                        ),
                                        0
                                      )
                                       FROM wip_pac_period_balances wppb2
                                       WHERE wppb2.pac_period_id = p_pac_period_id
                                       AND   wppb2.cost_group_id = p_cost_group_id
                                       AND   wppb2.wip_entity_id = p_entity_id
                                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                              )
                              WHERE wppb.pac_period_id = p_pac_period_id
                              AND wppb.cost_group_id = p_cost_group_id
                              AND wppb.wip_entity_id = p_entity_id
                              AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                              AND wppb.operation_seq_num <=
                                        decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
                        END IF;
                   ELSIF (p_net_qty < 0) THEN
                       l_stmt_num := 28;

		       /* Bug6847717: Calculate the total value across op_seq */
		       SELECT NVL(SUM(NVL(wppb.tl_resource_out,0)),0) net_tl_resource_value,
		              NVL(SUM(NVL(wppb.tl_overhead_out,0)),0) net_tl_overhead_value,
		              NVL(SUM(NVL(wppb.tl_outside_processing_out,0)),0) net_tl_osp_value
		       INTO
		       l_net_tl_resource_value,
		       l_net_tl_overhead_value,
		       l_net_tl_osp_value
		       FROM wip_pac_period_balances wppb
		       WHERE wppb.pac_period_id = p_prior_period_id
		         AND wppb.cost_group_id = p_cost_group_id
	                 AND wppb.wip_entity_id = p_entity_id
                         AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                         AND wppb.operation_seq_num <=
                             decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                       UPDATE wip_pac_period_balances wppb
                       SET (tl_resource_out,
                            tl_resource_temp,
                            tl_outside_processing_out,
                            tl_outside_processing_temp,
                            tl_overhead_out,
                            tl_overhead_temp) =
                             (SELECT
                               NVL(wppb.tl_resource_out,0) +
			       decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
					   +SIGN(l_net_tl_resource_value)
					   +2
					   ),
                                        1,
                                        NVL(wppb2.tl_resource_out,0) *
                                            p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                      0),
			       decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
					   +SIGN(l_net_tl_resource_value)
					   +2
					   ),
                                        1,
                                        NVL(wppb2.tl_resource_out,0) *
                                               p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                        0),
                               NVL(wppb.tl_outside_processing_out,0) +
			       decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
					   +SIGN(l_net_tl_osp_value)
					   +2
					   ),
                                        1,
                                        NVL(wppb2.tl_outside_processing_in,0)*
                                                p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                     0),
			       decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
					   +SIGN(l_net_tl_osp_value)
					   +2
					   ),
                                        1,
                                        NVL(wppb2.tl_outside_processing_in,0)*
                                                p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                    0),
                               NVL(wppb.tl_overhead_out,0) +
	                       decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
			      	           +SIGN(l_net_tl_overhead_value)
				           +2
					   ),
                                        1,
                                        NVL(wppb2.tl_overhead_out,0) *
                                                p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                    0),
	                       decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
			      	           +SIGN(l_net_tl_overhead_value)
				           +2
					   ),
                                        1,
                                        NVL(wppb2.tl_overhead_out,0) *
                                                p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                0,1,wppb2.relieved_assembly_units),
                                    0)
                               FROM  wip_pac_period_balances wppb2
                               WHERE wppb2.pac_period_id = p_prior_period_id
                               AND   wppb2.cost_group_id = p_cost_group_id
                               AND   wppb2.wip_entity_id = p_entity_id
                               AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                               AND   wppb2.operation_seq_num = wppb.operation_seq_num
                              )
                              WHERE  wppb.pac_period_id = p_pac_period_id
                              AND    wppb.cost_group_id = p_cost_group_id
                              AND    wppb.wip_entity_id = p_entity_id
                              AND    NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                              AND    wppb.operation_seq_num <=
                                        decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
                   ELSE /* p_net_qty=0 */
                       /* Final Completion, Flush out everything from the Job for TL columns */
                       l_stmt_num := 30;

		       /* Bug6847717: Calculate the total value across op_seq */
		       SELECT NVL(SUM(NVL(wppb.tl_resource_out,0)),0) net_tl_resource_value,
		              NVL(SUM(NVL(wppb.tl_overhead_out,0)),0) net_tl_overhead_value,
		              NVL(SUM(NVL(wppb.tl_outside_processing_out,0)),0) net_tl_osp_value
		       INTO
		       l_net_tl_resource_value,
		       l_net_tl_overhead_value,
		       l_net_tl_osp_value
		       FROM wip_pac_period_balances wppb
		       WHERE wppb.pac_period_id = p_prior_period_id
		         AND wppb.cost_group_id = p_cost_group_id
	                 AND wppb.wip_entity_id = p_entity_id
                         AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
	                 AND wppb.operation_seq_num <=
                             decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                       IF p_final_completion_flag = 1 THEN

                            SELECT sum(primary_quantity)
                            INTO   l_assembly_return_cnt
                            FROM   mtl_material_transactions mmt
                            WHERE  mmt.transaction_source_id =  p_entity_id
                            AND    mmt.transaction_action_id = 32
                            AND    nvl(mmt.repetitive_line_id,-99) = nvl(p_line_id,-99)
                            AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                                             AND  (TRUNC(p_end_date) + 0.99999);
                              -- If this period is not the first period
                            IF p_prior_period_id <> -1 then

                                     l_stmt_num := 32;
                                     UPDATE wip_pac_period_balances wppb
                                      SET (tl_resource_out,
                                           tl_resource_temp,
                                           tl_outside_processing_out,
                                           tl_outside_processing_temp,
                                           tl_overhead_out,
                                           tl_overhead_temp
                                         ) =
                                      (SELECT
                                       NVL(wppb.tl_resource_out,0) +
                                       decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
                                                   +SIGN(l_net_tl_resource_value)
                                                   +2
                                                   ),
                                                  1,
                                                 NVL(wppb2.tl_resource_out,0) *
                                                      l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                              0),
                                       decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
                                                   +SIGN(l_net_tl_resource_value)
                                                   +2
                                                   ),
                                                1,  NVL(wppb2.tl_resource_out,0) *
                                                   l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                               0),
                                       NVL(wppb.tl_outside_processing_out,0) +
                                       decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
                                                   +SIGN(l_net_tl_osp_value)
                                                   +2
                                                   ),
                                                1,
                                                 NVL(wppb2.tl_outside_processing_in,0)*
                                                 l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                             0),
                                       decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
                                                   +SIGN(l_net_tl_osp_value)
                                                   +2
                                                   ),
                                                1,
                                                NVL(wppb2.tl_outside_processing_in,0)*
                                                        l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                            0),
                                       NVL(wppb.tl_overhead_out,0) +
                                       decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
                                                   +SIGN(l_net_tl_overhead_value)
                                                   +2
                                                   ),
                                                1,
                                                NVL(wppb2.tl_overhead_out,0) *
                                                   l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                            0),
                                       decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
                                                   +SIGN(l_net_tl_overhead_value)
                                                   +2
                                                   ),
                                                1,
                                                NVL(wppb2.tl_overhead_out,0) *
                                                        l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                                        0,1,wppb2.relieved_assembly_units),
                                            0)
                                       FROM  wip_pac_period_balances wppb2
                                       WHERE wppb2.pac_period_id = p_prior_period_id
                                       AND   wppb2.cost_group_id = p_cost_group_id
                                       AND   wppb2.wip_entity_id = p_entity_id
                                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                                      )
                                      WHERE
                                      wppb.pac_period_id = p_pac_period_id
                                      AND wppb.cost_group_id = p_cost_group_id
                                      AND wppb.wip_entity_id = p_entity_id
                                      AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                                      AND wppb.operation_seq_num <=
                                                decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                           END IF; /*  p_final_completion_flag = 1 */
                              l_stmt_num := 34;
                              UPDATE wip_pac_period_balances wppb
                              SET (tl_resource_out,
                                   tl_resource_temp,
                                   tl_outside_processing_out,
                                   tl_outside_processing_temp,
                                   tl_overhead_out,
                                   tl_overhead_temp
                                 ) =
                              (SELECT
                               NVL(wppb.tl_resource_out,0) +
                              decode(SIGN(SIGN(NVL(wppb2.tl_resource_in,0)
                                               -NVL(wppb2.tl_resource_out,0)
                                               -NVL(wppb2.tl_resource_var,0))
                                          +SIGN(l_net_tl_resource_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_resource_in,0)-NVL(wppb2.tl_resource_out,0)
                                                - NVL(wppb2.tl_resource_var,0)),
                               0
                              ),
                              decode(SIGN(SIGN(NVL(wppb2.tl_resource_in,0)
                                               -NVL(wppb2.tl_resource_out,0)
                                               -NVL(wppb2.tl_resource_var,0))
                                          +SIGN(l_net_tl_resource_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_resource_in,0)-NVL(wppb2.tl_resource_out,0)
                                                - NVL(wppb2.tl_resource_var,0))
                                ,0
                              ),
                               NVL(wppb.tl_outside_processing_out,0) +
                              decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_in,0)
                                                - NVL(wppb2.tl_outside_processing_out,0)
                                                - NVL(wppb2.tl_outside_processing_var,0))
                                          +SIGN(l_net_tl_osp_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_outside_processing_in,0)
                                                - NVL(wppb2.tl_outside_processing_out,0)
                                                - NVL(wppb2.tl_outside_processing_var,0))
                                ,0
                              ),
                              decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_in,0)
                                                - NVL(wppb2.tl_outside_processing_out,0)
                                                - NVL(wppb2.tl_outside_processing_var,0))
                                          +SIGN(l_net_tl_osp_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_outside_processing_in,0)
                                                - NVL(wppb2.tl_outside_processing_out,0)
                                                - NVL(wppb2.tl_outside_processing_var,0)),
                                0
                              ),
                               NVL(tl_overhead_out,0) +
                              decode(SIGN(SIGN(NVL(wppb2.tl_overhead_in,0)
                                               -NVL(wppb2.tl_overhead_out,0)
                                               -NVL(wppb2.tl_overhead_var,0))
                                          +SIGN(l_net_tl_overhead_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_overhead_in,0)-NVL(wppb2.tl_overhead_out,0)
                                                - NVL(wppb2.tl_overhead_var,0)),
                                0
                              ),
                              decode(SIGN(SIGN(NVL(wppb2.tl_overhead_in,0)
                                               -NVL(wppb2.tl_overhead_out,0)
                                               -NVL(wppb2.tl_overhead_var,0))
                                          +SIGN(l_net_tl_overhead_value)
                                          +2
                                          ),
                                1,
                                (NVL(wppb2.tl_overhead_in,0)-NVL(wppb2.tl_overhead_out,0)
                                                - NVL(wppb2.tl_overhead_var,0)),
                                0
                              )
                               FROM wip_pac_period_balances wppb2
                               WHERE wppb2.pac_period_id = p_pac_period_id
                               AND   wppb2.cost_group_id = p_cost_group_id
                               AND   wppb2.wip_entity_id = p_entity_id
                               AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                               AND   wppb2.operation_seq_num = wppb.operation_seq_num
                              )
                              WHERE
                              wppb.pac_period_id = p_pac_period_id
                              AND wppb.cost_group_id = p_cost_group_id
                              AND wppb.wip_entity_id = p_entity_id
                              AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                              AND wppb.operation_seq_num <=
                                        decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                       ELSE  /* No Final Completion */
                              l_stmt_num := 36;
                              UPDATE wip_pac_period_balances wppb
                              SET    (
                                       tl_resource_temp,
                                       tl_outside_processing_temp,
                                       tl_overhead_temp
                                     )
                                    =
                                     ( SELECT DECODE(
						SIGN(SIGN(NVL(tl_resource_out,0))
						     +SIGN(l_net_tl_resource_value)
						     +2
						     ),
                                                1,
                                                NVL(tl_resource_out,0) /
                                                DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                                0
                                              ),
                                              DECODE(
                                                SIGN(SIGN(NVL(tl_outside_processing_out,0))
                                                     +SIGN(l_net_tl_osp_value)
                                                     +2
                                                     ),
                                                1,
                                                NVL(tl_outside_processing_out,0) /
                                                DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                                0
                                              ),
                                              DECODE(
                                                SIGN(SIGN(NVL(tl_overhead_out,0))
                                                     +SIGN(l_net_tl_overhead_value)
                                                     +2
                                                     ),
                                                1,
                                                NVL(tl_overhead_out,0) /
                                                DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                                0
                                              )
                                       FROM   wip_pac_period_balances
                                       WHERE  pac_period_id = p_prior_period_id
                                       AND    cost_group_id = p_cost_group_id
                                       AND    wip_entity_id = p_entity_id
                                       AND    NVL(line_id,-99) = NVL(p_line_id,-99)
                                       AND    operation_seq_num = wppb.operation_seq_num
                                     )
                              WHERE  pac_period_id = p_pac_period_id
                              AND    cost_group_id = p_cost_group_id
                              AND    wip_entity_id = p_entity_id
                              AND    NVL(line_id,-99) = NVL(p_line_id,-99)
                              AND    operation_seq_num <= decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
                    END IF; /* Final Completion Check */
                  END IF; /* End of P_net_qty */
           ELSE -- Actuals Logic
            l_stmt_num := 38;
            IF (p_net_qty > 0) THEN  -- completion are more than returns

	       /* Bug6847717: Calculate the total value across op_seq */
	       SELECT NVL(SUM(NVL(wppb.tl_resource_in,0)-
                          NVL(wppb.tl_resource_out,0)
                          - NVL(wppb.tl_resource_var,0)),0) net_tl_resource_value,
	              NVL(SUM(NVL(wppb.tl_overhead_in,0)-
                          NVL(wppb.tl_overhead_out,0)
                          - NVL(wppb.tl_overhead_var,0)),0) net_tl_overhead_value,
                      NVL(SUM(NVL(wppb.tl_outside_processing_in,0)-
                          NVL(wppb.tl_outside_processing_out,0)
                          - NVL(wppb.tl_outside_processing_var,0)),0) net_tl_osp_value,
                      NVL(SUM(NVL(wppb.pl_material_in,0)-
                          NVL(wppb.pl_material_out,0)
                          - NVL(wppb.pl_material_var,0)),0) net_pl_material_value,
                      NVL(SUM(NVL(wppb.pl_material_overhead_in,0)-
                          NVL(wppb.pl_material_overhead_out,0)
                          - NVL(wppb.pl_material_overhead_var,0)),0) net_pl_moh_value,
                      NVL(SUM(NVL(wppb.pl_resource_in,0)-
                          NVL(wppb.pl_resource_out,0)
                          - NVL(wppb.pl_resource_var,0)),0) net_pl_resource_value,
                      NVL(SUM(NVL(wppb.pl_outside_processing_in,0)-
                          NVL(wppb.pl_outside_processing_out,0)
                          - NVL(wppb.pl_outside_processing_var,0)),0) net_pl_osp_value,
                      NVL(SUM(NVL(wppb.pl_overhead_in,0)-
                          NVL(wppb.pl_overhead_out,0)
                          - NVL(wppb.pl_overhead_var,0)),0) net_pl_overhead_value
                 INTO
                 l_net_tl_resource_value,
                 l_net_tl_overhead_value,
                 l_net_tl_osp_value,
                 l_net_pl_material_value,
                 l_net_pl_moh_value,
                 l_net_pl_resource_value,
                 l_net_pl_osp_value,
                 l_net_pl_overhead_value
               FROM wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_pac_period_id
                  AND wppb.cost_group_id = p_cost_group_id
                  AND wppb.wip_entity_id = p_entity_id
                  AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                  AND wppb.operation_seq_num <=
                      decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

              IF p_final_completion_flag = 1 THEN     /* Final completion exists */
            l_stmt_num := 40;
                      UPDATE wip_pac_period_balances wppb
                      SET (tl_resource_out,
                           tl_resource_temp,
                           tl_outside_processing_out,
                           tl_outside_processing_temp,
                           tl_overhead_out,
                           tl_overhead_temp,
                           pl_material_out,
                           pl_material_temp,
                           pl_material_overhead_out,
                           pl_material_overhead_temp,
                           pl_resource_out,
                           pl_resource_temp,
                           pl_outside_processing_out,
                           pl_outside_processing_temp,
                           pl_overhead_out,
                           pl_overhead_temp
                        ) =
                      (SELECT
                       NVL(wppb.tl_resource_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
                                        -NVL(wppb.tl_resource_out,0)
                                        -NVL(tl_resource_var,0))
                                   +SIGN(l_net_tl_resource_value)
                                   +2
                                   ),
                                 1,
                                 (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        - NVL(tl_resource_var,0)),
                                  0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
                                        -NVL(wppb.tl_resource_out,0)
                                        -NVL(tl_resource_var,0))
                                   +SIGN(l_net_tl_resource_value)
                                   +2
                                   ),
                                   1,
                                   (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        - NVL(tl_resource_var,0)),
                                 0
                             ),
                       NVL(tl_outside_processing_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0))
                                   +SIGN(l_net_tl_osp_value)
                                   +2
                                   ),
                                1,
                                (NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0)),
                                0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0))
                                   +SIGN(l_net_tl_osp_value)
                                   +2
                                   ),
                                1,
                                (NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0)),
                                0
                             ),
                       NVL(tl_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
                                        -NVL(wppb.tl_overhead_out,0)
                                        -NVL(wppb.tl_overhead_var,0))
                                   +SIGN(l_net_tl_overhead_value)
                                   +2
                                   ),
                                  1,
                                   (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                      - NVL(wppb.tl_overhead_var,0)),
                                  0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
                                        -NVL(wppb.tl_overhead_out,0)
                                        -NVL(wppb.tl_overhead_var,0))
                                   +SIGN(l_net_tl_overhead_value)
                                   +2
                                   ),
                               1,
                                (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                            - NVL(wppb.tl_overhead_var,0)),
                               0
                             ),
                       NVL(pl_material_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.pl_material_in,0)
                                        -NVL(wppb.pl_material_out,0)
                                        -NVL(wppb.pl_material_var,0))
                                   +SIGN(l_net_pl_material_value)
                                   +2
                                   ),
                               1,
                                (NVL(wppb.pl_material_in,0) - NVL(wppb.pl_material_out,0) - nvl(wppb.pl_material_in_apull,0)
                                        - NVL(wppb.pl_material_var,0)) + nvl(wppb.pl_material_in_apull,0),
                               0
                              ),
                       decode(SIGN(SIGN(NVL(wppb.pl_material_in,0)
                                        -NVL(wppb.pl_material_out,0)
                                        -NVL(wppb.pl_material_var,0))
                                   +SIGN(l_net_pl_material_value)
                                   +2
                                   ),
                               1,
                                (NVL(wppb.pl_material_in,0)-NVL(wppb.pl_material_out,0)-nvl(wppb.pl_material_in_apull,0)
                                        - NVL(wppb.pl_material_var,0)) + nvl(wppb.pl_material_in_apull,0),
                               0
                            ),
                       NVL(pl_material_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
                                   +SIGN(l_net_pl_moh_value)
                                   +2
                                   ),
                              1,
                               (NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0) - nvl(wppb.pl_material_overhead_in_apull,0)
                                        - NVL(wppb.pl_material_overhead_var,0)) + nvl(wppb.pl_material_overhead_in_apull,0),
                              0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
                                   +SIGN(l_net_pl_moh_value)
                                   +2
                                   ),
                                1,
                                 (NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0) - nvl(wppb.pl_material_overhead_in_apull,0)
                                        - NVL(wppb.pl_material_overhead_var,0)) + nvl(wppb.pl_material_overhead_in_apull,0),
                                0
                             ),
                       NVL(pl_resource_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.pl_resource_in,0)
					-NVL(wppb.pl_resource_out,0)
                                        -NVL(wppb.pl_resource_var,0))
                                   +SIGN(l_net_pl_resource_value)
                                   +2
                                   ),
                                1,
                                (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0) - nvl(wppb.pl_resource_in_apull,0)
                                        - NVL(wppb.pl_resource_var,0)) + nvl(wppb.pl_resource_in_apull,0),
                                0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.pl_resource_in,0)
					-NVL(wppb.pl_resource_out,0)
                                        -NVL(wppb.pl_resource_var,0))
                                   +SIGN(l_net_pl_resource_value)
                                   +2
                                   ),
                                1,
                                 (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0) - nvl(wppb.pl_resource_in_apull,0)
                                        - NVL(wppb.pl_resource_var,0)) + nvl(wppb.pl_resource_in_apull,0),
                                0
                             ),
                       NVL(pl_outside_processing_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
                                   +SIGN(l_net_pl_osp_value)
                                   +2
                                   ),
                                1,
                                 (NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)-nvl(wppb.pl_outside_processing_in_apull,0)
                                        - NVL(wppb.pl_outside_processing_var,0)) + nvl(wppb.pl_outside_processing_in_apull,0),
                                0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
                                   +SIGN(l_net_pl_osp_value)
                                   +2
                                   ),
                                1,
                                 (NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)-nvl(wppb.pl_outside_processing_in_apull,0)
                                        - NVL(wppb.pl_outside_processing_var,0)) + nvl(wppb.pl_outside_processing_in_apull,0),
                                0
                             ),
                       NVL(pl_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb.pl_overhead_in,0)
					-NVL(wppb.pl_overhead_out,0)
                                        -NVL(wppb.pl_overhead_var,0))
                                   +SIGN(l_net_pl_overhead_value)
                                   +2
				   ),
                                1,
                                 (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)-nvl(wppb.pl_overhead_in_apull,0)
                                        - NVL(wppb.pl_overhead_var,0)) + nvl(wppb.pl_overhead_in_apull,0),
                                0
                             ),
                       decode(SIGN(SIGN(NVL(wppb.pl_overhead_in,0)
					-NVL(wppb.pl_overhead_out,0)
                                        -NVL(wppb.pl_overhead_var,0))
                                   +SIGN(l_net_pl_overhead_value)
                                   +2
				   ),
                                1,
                                 (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)-nvl(wppb.pl_overhead_in_apull,0)
                                        - NVL(wppb.pl_overhead_var,0)) + nvl(wppb.pl_overhead_in_apull,0),
                                0
                             )
                       FROM  wip_pac_period_balances wppb2
                       WHERE wppb2.pac_period_id = p_pac_period_id
                       AND   wppb2.cost_group_id = p_cost_group_id
                       AND   wppb2.wip_entity_id = p_entity_id
                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                      )
                      WHERE wppb.pac_period_id = p_pac_period_id
                      AND   wppb.cost_group_id = p_cost_group_id
                      AND   wppb.wip_entity_id = p_entity_id
                      AND   NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                      AND   wppb.operation_seq_num <= wppb.operation_seq_num;
              ELSE     /* No Final completion exists */
                      l_stmt_num := 42;
                      UPDATE wip_pac_period_balances wppb
                      SET (tl_resource_out,
                        tl_resource_temp,
                        tl_outside_processing_out,
                        tl_outside_processing_temp,
                        tl_overhead_out,
                        tl_overhead_temp,
                        pl_material_out,
                        pl_material_temp,
			scrap_pull_material,  -- Added by Bug#4717026
                        pl_material_overhead_out,
                        pl_material_overhead_temp,
                        scrap_pull_material_overhead,  -- Added by Bug#4717026
                        pl_resource_out,
                        pl_resource_temp,
                	scrap_pull_resource,  -- Added by Bug#4717026
                        pl_outside_processing_out,
                        pl_outside_processing_temp,
              		scrap_pull_outside_processing,  -- Added by Bug#4717026
                        pl_overhead_out,
                        pl_overhead_temp,
			scrap_pull_overhead  -- Added by Bug#4717026
                        ) =
                      (SELECT
                       NVL(wppb.tl_resource_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.tl_resource_in,0)
				       -NVL(wppb2.tl_resource_out,0)
                                       -NVL(wppb2.tl_resource_var,0))
				  +SIGN(l_net_tl_resource_value)
                                  +2
                                  ),
                        1,
                        (NVL(wppb2.tl_resource_in,0)-NVL(wppb2.tl_resource_out,0)
                                        - NVL(wppb2.tl_resource_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0) - nvl(wppb2.unrelieved_scrap_quantity,0)),
                              0,  1,
                             -1, 1,
                              p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0) - nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.tl_resource_in,0)
				       -NVL(wppb2.tl_resource_out,0)
                                       -NVL(wppb2.tl_resource_var,0))
				  +SIGN(l_net_tl_resource_value)
                                  +2
                                  ),
                        1,
                        (NVL(wppb2.tl_resource_in,0)-NVL(wppb2.tl_resource_out,0)
                                        - NVL(wppb2.tl_resource_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                              0,  1,
                             -1, 1,
                              p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                       NVL(tl_outside_processing_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_in,0)
                                        - NVL(wppb2.tl_outside_processing_out,0)
                                        - NVL(wppb2.tl_outside_processing_var,0))
				  +SIGN(l_net_tl_osp_value)
       				  +2
				  ),
                        1,
                        (NVL(wppb2.tl_outside_processing_in,0)
                                        - NVL(wppb2.tl_outside_processing_out,0)
                                        - NVL(wppb2.tl_outside_processing_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                             0,  1,
                            -1, 1,
                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_in,0)
                                        - NVL(wppb2.tl_outside_processing_out,0)
                                        - NVL(wppb2.tl_outside_processing_var,0))
				  +SIGN(l_net_tl_osp_value)
       				  +2
				  ),
                        1,
                        (NVL(wppb2.tl_outside_processing_in,0)
                                        - NVL(wppb2.tl_outside_processing_out,0)
                                        - NVL(wppb2.tl_outside_processing_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                       NVL(tl_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.tl_overhead_in,0)
				       -NVL(wppb2.tl_overhead_out,0)
                                       -NVL(wppb2.tl_overhead_var,0))
				  +SIGN(l_net_tl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.tl_overhead_in,0)-NVL(wppb2.tl_overhead_out,0)
                                        - NVL(wppb2.tl_overhead_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.tl_overhead_in,0)
				       -NVL(wppb2.tl_overhead_out,0)
                                       -NVL(wppb2.tl_overhead_var,0))
				  +SIGN(l_net_tl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.tl_overhead_in,0)-NVL(wppb2.tl_overhead_out,0)
                                        - NVL(wppb2.tl_overhead_var,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                             0,  1,
                            -1, 1,
                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ),
                        0
                      ),
                       NVL(pl_material_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.pl_material_in,0)
				       -NVL(wppb2.pl_material_out,0)
                                       -NVL(wppb2.pl_material_var,0))
				  +SIGN(l_net_pl_material_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_material_in,0)-NVL(wppb2.pl_material_out,0)- nvl(wppb2.pl_material_in_apull,0)
                                        - NVL(wppb2.pl_material_var,0)+ nvl(wppb.scrap_pull_material,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) +   decode(p_scrap,1, p_net_qty * nvl(wppb.pl_material_in_apull,0)/(wppb.relieved_scrap_qty + nvl(l_net_completion,0)),
		            nvl(wppb.pl_material_in_apull,0) - nvl(wppb.scrap_pull_material,0)),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.pl_material_in,0)
				       -NVL(wppb2.pl_material_out,0)
                                       -NVL(wppb2.pl_material_var,0))
				  +SIGN(l_net_pl_material_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_material_in,0)- NVL(wppb2.pl_material_out,0)- nvl(wppb2.pl_material_in_apull,0)
                                        - NVL(wppb2.pl_material_var,0)+ nvl(wppb2.scrap_pull_material,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) +  decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_material_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		            nvl(wppb2.pl_material_in_apull,0) - nvl(wppb2.scrap_pull_material,0)),
                        0
                      ),

                     NVL(wppb.scrap_pull_material,0) +
          	      decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_material_in_apull,0)/
		               (wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),0),

                       NVL(pl_material_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.pl_material_overhead_in,0)
                                        - NVL(wppb2.pl_material_overhead_out,0)
                                        - NVL(wppb2.pl_material_overhead_var,0))
				  +SIGN(l_net_pl_moh_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_material_overhead_in,0)
                                        - NVL(wppb2.pl_material_overhead_out,0)- nvl(wppb2.pl_material_overhead_in_apull,0)
                                        - NVL(wppb2.pl_material_overhead_var,0)+  nvl(wppb2.scrap_pull_material_overhead,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                             0,  1,
                            -1, 1,
                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb.pl_material_overhead_in_apull,0)/(wppb.relieved_scrap_qty + nvl(l_net_completion,0)),
		            nvl(wppb.pl_material_overhead_in_apull,0) - nvl(wppb2.scrap_pull_material_overhead,0)),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.pl_material_overhead_in,0)
                                        - NVL(wppb2.pl_material_overhead_out,0)
                                        - NVL(wppb2.pl_material_overhead_var,0))
				  +SIGN(l_net_pl_moh_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_material_overhead_in,0)
                                        - NVL(wppb2.pl_material_overhead_out,0)-nvl(wppb2.pl_material_overhead_in_apull,0)
                                        - NVL(wppb2.pl_material_overhead_var,0)+  nvl(wppb2.scrap_pull_material_overhead,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                             0,  1,
                            -1, 1,
                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_material_overhead_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		            nvl(wppb2.pl_material_overhead_in_apull,0) - nvl(wppb2.scrap_pull_material_overhead,0)),
                        0
                      ),

                  NVL(wppb.scrap_pull_material_overhead,0) +
  	          decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_material_overhead_in_apull,0)/
		       (wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),0),

                       NVL(pl_resource_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.pl_resource_in,0)
					-NVL(wppb2.pl_resource_out,0)
                                        - NVL(wppb2.pl_resource_var,0))
				  +SIGN(l_net_pl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_resource_in,0)- NVL(wppb2.pl_resource_out,0)- nvl(wppb2.pl_resource_in_apull,0)
                                        - NVL(wppb2.pl_resource_var,0) + NVL(wppb2.scrap_pull_resource,0) )*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_resource_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_resource_in_apull,0) - NVL(wppb2.scrap_pull_resource,0)),
                        0
                      ),

                      decode(SIGN(SIGN(NVL(wppb2.pl_resource_in,0)
					-NVL(wppb2.pl_resource_out,0)
                                        - NVL(wppb2.pl_resource_var,0))
				  +SIGN(l_net_pl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_resource_in,0)- NVL(wppb2.pl_resource_out,0)- nvl(wppb2.pl_resource_in_apull,0)
                                        - NVL(wppb2.pl_resource_var,0) + NVL(wppb2.scrap_pull_resource,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0,  1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_resource_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_resource_in_apull,0) - NVL(wppb2.scrap_pull_resource,0)),
                        0
                      ),

		  NVL(wppb.scrap_pull_resource,0) +
               	      decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_resource_in_apull,0)/
		              (wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),0),

                       NVL(pl_outside_processing_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.pl_outside_processing_in,0)
                                        - NVL(wppb2.pl_outside_processing_out,0)
                                        - NVL(wppb2.pl_outside_processing_var,0)
					+ NVL(wppb.scrap_pull_outside_processing,0))
				  +SIGN(l_net_pl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_outside_processing_in,0)
                                        - NVL(wppb2.pl_outside_processing_out,0)- nvl(wppb2.pl_outside_processing_in_apull,0)
                                        - NVL(wppb2.pl_outside_processing_var,0) + NVL(wppb2.scrap_pull_resource,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                             0,  1,
                            -1, 1,
                             p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_outside_processing_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_outside_processing_in_apull,0) - NVL(wppb2.scrap_pull_outside_processing,0)),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
				  +SIGN(l_net_pl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)-nvl(wppb.pl_outside_processing_in_apull,0)
                                        - NVL(wppb.pl_outside_processing_var,0) + NVL(wppb.scrap_pull_outside_processing,0))*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0, 1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_outside_processing_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_outside_processing_in_apull,0) - NVL(wppb2.scrap_pull_outside_processing,0)),
                        0
                      ),

		      NVL(scrap_pull_outside_processing,0) +
	              decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_outside_processing_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),0),

                       NVL(pl_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_overhead_in,0)
					-NVL(wppb.pl_overhead_out,0)
                                        -NVL(wppb.pl_overhead_var,0))
				  +SIGN(l_net_pl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_overhead_in,0)-NVL(wppb2.pl_overhead_out,0)-nvl(wppb2.pl_overhead_in_apull,0)
                                        - NVL(wppb2.pl_overhead_var,0) + NVL(wppb2.scrap_pull_overhead,0) )*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0, 1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_overhead_in_apull,0)/(relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_overhead_in_apull,0) -  NVL(wppb2.scrap_pull_overhead,0)),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb2.pl_overhead_in,0)
					-NVL(wppb2.pl_overhead_out,0)
                                        -NVL(wppb2.pl_overhead_var,0))
				  +SIGN(l_net_pl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb2.pl_overhead_in,0)-NVL(wppb2.pl_overhead_out,0)-nvl(wppb2.pl_overhead_in_apull,0)
                                        - NVL(wppb2.pl_overhead_var,0) + NVL(wppb2.scrap_pull_overhead,0) )*
                        decode(SIGN(NVL(wppb2.operation_completed_units,0) -
                                NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0)),
                           0, 1,
                          -1, 1,
                           p_net_qty/ (NVL(wppb2.operation_completed_units,0) -
                                    NVL(wppb2.relieved_assembly_units,0)- nvl(wppb2.unrelieved_scrap_quantity,0))
                        ) + decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_overhead_in_apull,0)/(relieved_scrap_qty + nvl(l_net_completion,0)),
		             nvl(wppb2.pl_overhead_in_apull,0) -  NVL(wppb2.scrap_pull_overhead,0)),
                        0
                      ),
		       NVL(wppb.scrap_pull_overhead,0) +
              	      decode(p_scrap,1, p_net_qty * nvl(wppb2.pl_overhead_in_apull,0)/(wppb2.relieved_scrap_qty + nvl(l_net_completion,0)),0)

                       FROM wip_pac_period_balances wppb2
                       WHERE wppb2.pac_period_id = p_pac_period_id
                       AND   wppb2.cost_group_id = p_cost_group_id
                       AND   wppb2.wip_entity_id = p_entity_id
                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                      )
                      WHERE wppb.pac_period_id = p_pac_period_id
                      AND   wppb.cost_group_id = p_cost_group_id
                      AND   wppb.wip_entity_id = p_entity_id
                      AND   NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                      AND   wppb.operation_seq_num <=
                                decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
                END IF;
            ELSIF p_net_qty < 0 THEN -- This is a net return
              l_stmt_num := 44;

	      /* Bug6847717: Calculate the total value across op_seq */
	       SELECT NVL(SUM(NVL(wppb.tl_resource_out,0)),0) net_tl_resource_value,
	              NVL(SUM(NVL(wppb.tl_overhead_out,0)),0) net_tl_overhead_value,
                      NVL(SUM(NVL(wppb.tl_outside_processing_out,0)),0) net_tl_osp_value,
                      NVL(SUM(NVL(wppb.pl_material_out,0)),0) net_pl_material_value,
                      NVL(SUM(NVL(wppb.pl_material_overhead_out,0)),0) net_pl_moh_value,
                      NVL(SUM(NVL(wppb.pl_resource_out,0)),0) net_pl_resource_value,
                      NVL(SUM(NVL(wppb.pl_outside_processing_out,0)),0) net_pl_osp_value,
		      NVL(SUM(NVL(wppb.pl_overhead_out,0)),0) net_pl_overhead_value
                 INTO
                 l_net_tl_resource_value,
                 l_net_tl_overhead_value,
                 l_net_tl_osp_value,
                 l_net_pl_material_value,
                 l_net_pl_moh_value,
                 l_net_pl_resource_value,
                 l_net_pl_osp_value,
                 l_net_pl_overhead_value
               FROM wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_prior_period_id
                  AND wppb.cost_group_id = p_cost_group_id
                  AND wppb.wip_entity_id = p_entity_id
                  AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                  AND wppb.operation_seq_num <=
                      decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

              UPDATE wip_pac_period_balances wppb
              SET (tl_resource_out,
                        tl_resource_temp,
                        tl_outside_processing_out,
                        tl_outside_processing_temp,
                        tl_overhead_out,
                        tl_overhead_temp,
                        pl_material_out,
                        pl_material_temp,
                        pl_material_overhead_out,
                        pl_material_overhead_temp,
                        pl_resource_out,
                        pl_resource_temp,
                        pl_outside_processing_out,
                        pl_outside_processing_temp,
                        pl_overhead_out,
                        pl_overhead_temp
                ) =
              (SELECT
               NVL(wppb.tl_resource_out,0) +
              decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
			  +SIGN(l_net_tl_resource_value)
			  +2
			  ),
                1,
                NVL(wppb2.tl_resource_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
              decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
			  +SIGN(l_net_tl_resource_value)
			  +2
			  ),
                1,
                NVL(wppb2.tl_resource_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.tl_outside_processing_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
			   +SIGN(l_net_tl_osp_value)
			   +2
			   ),
                1,
                NVL(wppb2.tl_outside_processing_in,0)*
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
			   +SIGN(l_net_tl_osp_value)
			   +2
			   ),
                1,
                NVL(wppb2.tl_outside_processing_in,0)*
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.tl_overhead_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
			   +SIGN(l_net_tl_overhead_value)
			   +2
			   ),
                1,
                NVL(wppb2.tl_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
			   +SIGN(l_net_tl_overhead_value)
			   +2
			   ),
                1,
                NVL(wppb2.tl_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.pl_material_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.pl_material_out,0))
			   +SIGN(l_net_pl_material_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_material_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.pl_material_out,0))
			   +SIGN(l_net_pl_material_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_material_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.pl_material_overhead_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.pl_material_overhead_out,0))
			   +SIGN(l_net_pl_moh_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_material_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.pl_material_overhead_out,0))
			   +SIGN(l_net_pl_moh_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_material_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.pl_resource_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.pl_resource_out,0))
			   +SIGN(l_net_pl_resource_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_resource_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.pl_resource_out,0))
			   +SIGN(l_net_pl_resource_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_resource_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.pl_outside_processing_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.pl_outside_processing_out,0))
			   +SIGN(l_net_pl_osp_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_outside_processing_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.pl_outside_processing_out,0))
			   +SIGN(l_net_pl_osp_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_outside_processing_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               NVL(wppb.pl_overhead_out,0) +
               decode(SIGN(SIGN(NVL(wppb2.pl_overhead_out,0))
			   +SIGN(l_net_pl_overhead_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0),
               decode(SIGN(SIGN(NVL(wppb2.pl_overhead_out,0))
			   +SIGN(l_net_pl_overhead_value)
			   +2
			   ),
                1,
                NVL(wppb2.pl_overhead_out,0) *
                        p_net_qty/decode(NVL(wppb2.relieved_assembly_units,0),
                                        0,1,wppb2.relieved_assembly_units),
                0)
               FROM  wip_pac_period_balances wppb2
               WHERE wppb2.pac_period_id = p_prior_period_id
               AND   wppb2.cost_group_id = p_cost_group_id
               AND   wppb2.wip_entity_id = p_entity_id
               AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
               AND   wppb2.operation_seq_num = wppb.operation_seq_num
              )
              WHERE  wppb.pac_period_id = p_pac_period_id
              AND    wppb.cost_group_id = p_cost_group_id
              AND    wppb.wip_entity_id = p_entity_id
              AND    NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
              AND    wppb.operation_seq_num <=
                        decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
            ELSE
              l_stmt_num := 46;
              -- This is net cancellation between completions and returns

	       /* Bug6847717: Calculate the total value across op_seq */
	       SELECT NVL(SUM(NVL(wppb.tl_resource_out,0)),0) net_tl_resource_value,
	              NVL(SUM(NVL(wppb.tl_overhead_out,0)),0) net_tl_overhead_value,
                      NVL(SUM(NVL(wppb.tl_outside_processing_out,0)),0) net_tl_osp_value,
                      NVL(SUM(NVL(wppb.pl_material_out,0)),0) net_pl_material_value,
                      NVL(SUM(NVL(wppb.pl_material_overhead_out,0)),0) net_pl_moh_value,
                      NVL(SUM(NVL(wppb.pl_resource_out,0)),0) net_pl_resource_value,
                      NVL(SUM(NVL(wppb.pl_outside_processing_out,0)),0) net_pl_osp_value,
		      NVL(SUM(NVL(wppb.pl_overhead_out,0)),0) net_pl_overhead_value
                 INTO
                 l_net_tl_resource_value,
                 l_net_tl_overhead_value,
                 l_net_tl_osp_value,
                 l_net_pl_material_value,
                 l_net_pl_moh_value,
                 l_net_pl_resource_value,
                 l_net_pl_osp_value,
                 l_net_pl_overhead_value
               FROM wip_pac_period_balances wppb
                WHERE wppb.pac_period_id = p_prior_period_id
                  AND wppb.cost_group_id = p_cost_group_id
                  AND wppb.wip_entity_id = p_entity_id
                  AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                  AND wppb.operation_seq_num <=
                      decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

              IF p_final_completion_flag = 1 THEN

                     l_stmt_num := 48;
                     SELECT sum(primary_quantity)
                     INTO   l_assembly_return_cnt
                     FROM   mtl_material_transactions mmt
                     WHERE  mmt.transaction_source_id =  p_entity_id
                     AND    mmt.transaction_action_id = 32
                     AND    nvl(mmt.repetitive_line_id,-99) = nvl(p_line_id,-99)
                     AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                                     AND  (TRUNC(p_end_date) + 0.99999);

                  IF (p_prior_period_id <> -1) then

                     l_stmt_num := 50;
                     UPDATE wip_pac_period_balances wppb
                      SET    (  tl_resource_out,
                                tl_outside_processing_out,
                                tl_overhead_out,
                                pl_material_out,
                                pl_material_overhead_out,
                                pl_resource_out,
                                pl_outside_processing_out,
                                pl_overhead_out
                        ) =
                      (SELECT
                       NVL(wppb.tl_resource_out,0) +
                      decode(SIGN(SIGN(NVL(wppb2.tl_resource_out,0))
				  +SIGN(l_net_tl_resource_value)
				  +2
				  ),
                        1,
                        NVL(wppb2.tl_resource_out,0) *
                                l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                      0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.tl_outside_processing_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.tl_outside_processing_out,0))
				   +SIGN(l_net_tl_osp_value)
				   +2
				   ),
                        1,
                        NVL(wppb2.tl_outside_processing_in,0)*
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.tl_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.tl_overhead_out,0))
				   +SIGN(l_net_tl_overhead_value)
				   +2
				   ),
                        1,
                        NVL(wppb2.tl_overhead_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.pl_material_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.pl_material_out,0))
				   +SIGN(l_net_pl_material_value)
				   +2
				   ),
                        1,
                        NVL(wppb2.pl_material_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.pl_material_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.pl_material_overhead_out,0))
				   +SIGN(l_net_pl_moh_value)
			 	   +2
				   ),
                        1,
                        NVL(wppb2.pl_material_overhead_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                         0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.pl_resource_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.pl_resource_out,0))
				   +SIGN(l_net_pl_resource_value)
				   +2
			 	   ),
                        1,
                        NVL(wppb2.pl_resource_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                     0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.pl_outside_processing_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.pl_outside_processing_out,0))
				   +SIGN(l_net_pl_osp_value)
				   +2
				   ),
                        1,
                        NVL(wppb2.pl_outside_processing_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                0,1,wppb2.relieved_assembly_units),
                        0),
                       NVL(wppb.pl_overhead_out,0) +
                       decode(SIGN(SIGN(NVL(wppb2.pl_overhead_out,0))
				   +SIGN(l_net_pl_overhead_value)
				   +2
				   ),
                        1,
                        NVL(wppb2.pl_overhead_out,0) *
                           l_assembly_return_cnt/decode(NVL(wppb2.relieved_assembly_units,0),
                                                       0,1,wppb2.relieved_assembly_units),
                        0)
                       FROM  wip_pac_period_balances wppb2
                       WHERE wppb2.pac_period_id = p_prior_period_id
                       AND   wppb2.cost_group_id = p_cost_group_id
                       AND   wppb2.wip_entity_id = p_entity_id
                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                      )
                      WHERE  wppb.pac_period_id = p_pac_period_id
                      AND    wppb.cost_group_id = p_cost_group_id
                      AND    wppb.wip_entity_id = p_entity_id
                      AND    NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                      AND    wppb.operation_seq_num <=
                                decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);

                 END IF;  /* end of period <> -1 */
                      l_stmt_num := 52;
                      UPDATE wip_pac_period_balances wppb
                      SET ( tl_resource_out,
                            tl_resource_temp,
                            tl_outside_processing_out,
                            tl_outside_processing_temp,
                            tl_overhead_out,
                            tl_overhead_temp,
                            pl_material_out,
                            pl_material_temp,
                            pl_material_overhead_out,
                            pl_material_overhead_temp,
                            pl_resource_out,
                            pl_resource_temp,
                            pl_outside_processing_out,
                            pl_outside_processing_temp,
                            pl_overhead_out,
                            pl_overhead_temp
                        ) =
                      (SELECT
                       NVL(wppb.tl_resource_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
					-NVL(wppb.tl_resource_out,0)
                                        -NVL(tl_resource_var,0))
				  +SIGN(l_net_tl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        - NVL(tl_resource_var,0)),
                       0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.tl_resource_in,0)
					-NVL(wppb.tl_resource_out,0)
                                        -NVL(tl_resource_var,0))
				  +SIGN(l_net_tl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_resource_in,0)-NVL(wppb.tl_resource_out,0)
                                        - NVL(tl_resource_var,0))
                        ,0
                      ),
                       NVL(tl_outside_processing_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0))
				  +SIGN(l_net_tl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0))
                        ,0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0))
				  +SIGN(l_net_tl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_outside_processing_in,0)
                                        - NVL(wppb.tl_outside_processing_out,0)
                                        - NVL(wppb.tl_outside_processing_var,0)),
                        0
                      ),
                       NVL(tl_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
					-NVL(wppb.tl_overhead_out,0)
                                        -NVL(wppb.tl_overhead_var,0))
				  +SIGN(l_net_tl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                        - NVL(wppb.tl_overhead_var,0)),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.tl_overhead_in,0)
					-NVL(wppb.tl_overhead_out,0)
                                        -NVL(wppb.tl_overhead_var,0))
				  +SIGN(l_net_tl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.tl_overhead_in,0)-NVL(wppb.tl_overhead_out,0)
                                        - NVL(wppb.tl_overhead_var,0)),
                        0
                      ),
                       NVL(pl_material_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_material_in,0)
					-NVL(wppb.pl_material_out,0)
                                        -NVL(wppb.pl_material_var,0))
				  +SIGN(l_net_pl_material_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_material_in,0)-NVL(wppb.pl_material_out,0)- nvl(wppb.pl_material_in_apull,0)
                                        - NVL(wppb.pl_material_var,0))
                         + nvl(wppb.pl_material_in_apull,0),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_material_in,0)
					-NVL(wppb.pl_material_out,0)
                                        -NVL(wppb.pl_material_var,0))
				  +SIGN(l_net_pl_material_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_material_in,0)-NVL(wppb.pl_material_out,0)-nvl(wppb.pl_material_in_apull,0)
                                        - NVL(wppb.pl_material_var,0)) + nvl(wppb.pl_material_in_apull,0),
                        0
                      ),
                       NVL(pl_material_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
				  +SIGN(l_net_pl_moh_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)-nvl(wppb.pl_material_overhead_in_apull,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
                         + nvl(wppb.pl_material_overhead_in_apull,0),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
				  +SIGN(l_net_pl_moh_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_material_overhead_in,0)
                                        - NVL(wppb.pl_material_overhead_out,0)-nvl(wppb.pl_material_overhead_in_apull,0)
                                        - NVL(wppb.pl_material_overhead_var,0))
                        + nvl(wppb.pl_material_overhead_in_apull,0),
                        0
                      ),
                       NVL(pl_resource_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_resource_in,0)
					-NVL(wppb.pl_resource_out,0)
                                        -NVL(wppb.pl_resource_var,0))
				  +SIGN(l_net_pl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0)-nvl(wppb.pl_resource_in_apull,0)
                                        - NVL(wppb.pl_resource_var,0))
                         + nvl(wppb.pl_resource_in_apull,0),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_resource_in,0)
					-NVL(wppb.pl_resource_out,0)
                                        -NVL(wppb.pl_resource_var,0))
				  +SIGN(l_net_pl_resource_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_resource_in,0)-NVL(wppb.pl_resource_out,0)-nvl(wppb.pl_resource_in_apull,0)
                                        - NVL(wppb.pl_resource_var,0)) + nvl(wppb.pl_resource_in_apull,0),
                        0
                      ),
                       NVL(pl_outside_processing_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
				  +SIGN(l_net_pl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)-nvl(wppb.pl_outside_processing_in_apull,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
                         + nvl(wppb.pl_outside_processing_in_apull,0),
                        0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)
                                        - NVL(wppb.pl_outside_processing_var,0))
				  +SIGN(l_net_pl_osp_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_outside_processing_in,0)
                                        - NVL(wppb.pl_outside_processing_out,0)-nvl(wppb.pl_outside_processing_in_apull,0)
                                        - NVL(wppb.pl_outside_processing_var,0)) +
                                        nvl(wppb.pl_outside_processing_in_apull,0),
                        0
                      ),
                       NVL(pl_overhead_out,0) +
                      decode(SIGN(SIGN(NVL(wppb.pl_overhead_in,0)
					-NVL(wppb.pl_overhead_out,0)
                                        -NVL(wppb.pl_overhead_var,0))
				  +SIGN(l_net_pl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)-nvl(wppb.pl_overhead_in_apull,0)
                                        - NVL(wppb.pl_overhead_var,0))
                         + nvl(wppb.pl_overhead_in_apull,0),
                         0
                      ),
                      decode(SIGN(SIGN(NVL(wppb.pl_overhead_in,0)
					-NVL(wppb.pl_overhead_out,0)
                                        -NVL(wppb.pl_overhead_var,0))
				  +SIGN(l_net_pl_overhead_value)
				  +2
				  ),
                        1,
                        (NVL(wppb.pl_overhead_in,0)-NVL(wppb.pl_overhead_out,0)-nvl(wppb.pl_overhead_in_apull,0)
                                        - NVL(wppb.pl_overhead_var,0))
                        + nvl(wppb.pl_overhead_in_apull,0),
                        0
                      )
                       FROM wip_pac_period_balances wppb2
                       WHERE wppb2.pac_period_id = p_pac_period_id
                       AND   wppb2.cost_group_id = p_cost_group_id
                       AND   wppb2.wip_entity_id = p_entity_id
                       AND   NVL(wppb2.line_id,-99) = NVL(p_line_id,-99)
                       AND   wppb2.operation_seq_num = wppb.operation_seq_num
                      )
                      WHERE
                      wppb.pac_period_id = p_pac_period_id
                      AND wppb.cost_group_id = p_cost_group_id
                      AND wppb.wip_entity_id = p_entity_id
                      AND NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
                      AND wppb.operation_seq_num <=
                                decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
            ELSE
                      l_stmt_num := 54;
                      UPDATE wip_pac_period_balances wppb
                      SET    (
                               tl_resource_temp,
                               tl_outside_processing_temp,
                               tl_overhead_temp,
                               pl_material_temp,
                               pl_material_overhead_temp,
                               pl_resource_temp,
                               pl_outside_processing_temp,
                               pl_overhead_temp
                             )
                      =      (
                               SELECT DECODE(
                                        SIGN(SIGN(NVL(tl_resource_out,0))
					     +SIGN(l_net_tl_resource_value)
					     +2
					     ),
                                        1,
                                        NVL(tl_resource_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(tl_outside_processing_out,0))
					     +SIGN(l_net_tl_osp_value)
					     +2
					     ),
                                        1,
                                        NVL(tl_outside_processing_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(tl_overhead_out,0))
					     +SIGN(l_net_tl_overhead_value)
					     +2
					     ),
                                        1,
                                        NVL(tl_overhead_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(pl_material_out,0))
					     +SIGN(l_net_pl_material_value)
					     +2
					     ),
                                        1,
                                        NVL(pl_material_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(pl_material_overhead_out,0))
					     +SIGN(l_net_pl_moh_value)
					     +2
					     ),
                                        1,
                                        NVL(pl_material_overhead_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(pl_resource_out,0))
					     +SIGN(l_net_pl_resource_value)
					     +2
					     ),
                                        1,
                                        NVL(pl_resource_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(pl_outside_processing_out,0))
					     +SIGN(l_net_pl_osp_value)
					     +2
					     ),
                                        1,
                                        NVL(pl_outside_processing_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      ),
                                      DECODE(
                                        SIGN(SIGN(NVL(pl_overhead_out,0))
					     +SIGN(l_net_pl_overhead_value)
					     +2
					     ),
                                        1,
                                        NVL(pl_overhead_out,0) /
                                        DECODE(NVL(relieved_assembly_units,0),0,1,relieved_assembly_units),
                                        0
                                      )
                               FROM   wip_pac_period_balances
                               WHERE  pac_period_id = p_prior_period_id
                               AND    cost_group_id = p_cost_group_id
                               AND    wip_entity_id = p_entity_id
                               AND    NVL(line_id,-99) = NVL(p_line_id,-99)
                               AND    operation_seq_num = wppb.operation_seq_num
                             )
                      WHERE  pac_period_id = p_pac_period_id
                      AND    cost_group_id = p_cost_group_id
                      AND    wip_entity_id = p_entity_id
                      AND    NVL(line_id,-99) = NVL(p_line_id,-99)
                      AND    operation_seq_num <= decode(p_scrap,1,p_op_seq,wppb.operation_seq_num);
             END IF; -- end of p_final_completion_flag = 1
            END IF; -- Check whether p_net_qty is > 0, < 0 or = 0
         END IF; /* End of p_material_relief_algorithm */

            ------------------------------------------------------------------
            -- Update wppb.RELIEVED_ASSEMBLY_UNITS
            ------------------------------------------------------------------
            l_stmt_num := 56;
            UPDATE  wip_pac_period_balances wppb
            SET     wppb.relieved_assembly_units =
                    NVL(wppb.relieved_assembly_units,0) + p_net_qty
            WHERE   wppb.pac_period_id = p_pac_period_id
            AND     wppb.cost_group_id = p_cost_group_id
            AND     wppb.wip_entity_id = p_entity_id
            AND     NVL(wppb.line_id,-99) = NVL(p_line_id,-99)
            AND     wppb.operation_seq_num <= decode(p_scrap,1,p_op_seq,
                                                               wppb.operation_seq_num);
          END IF; -- check for cfm

        ----------------------------------------------------------------------
        -- Load transaction costs in MPTCD
        -- Costs to be loaded into MPTCD must be in the
        -- pri uom of the master item organization
        -- The costs stored in the temp column and p_net_qty are based
        -- on the organization's pri UOM which may be different from
        -- the item master org's pri UOM. So, we will convert both
        -- costs and quantity if the uom control is not 1 i.e. not at
        -- the item master org level
        ----------------------------------------------------------------------

        l_uom_conv_rate := 1;

        IF (p_uom_control <> 1) THEN

                l_stmt_num := 60;

                SELECT  NVL(we.primary_item_id,-1),
                        we.organization_id
                INTO    l_item_id,
                        l_org_id
                FROM    wip_entities we
                WHERE   we.wip_entity_id = p_entity_id;

             IF (l_item_id <> -1) THEN
                l_stmt_num := 65;
                CSTPPINV.get_um_rate (  i_txn_org_id          => l_org_id,
                                        i_master_org_id       => p_master_org_id,
                                        i_txn_cost_group_id   => -1,
                                        i_txfr_cost_group_id  => -2,
                                        i_txn_action_id       => -3,
                                        i_item_id             => l_item_id,
                                        i_uom_control         => p_uom_control,
                                        i_user_id             => p_user_id,
                                        i_login_id            => p_login_id,
                                        i_request_id          => p_request_id,
                                        i_prog_id             => p_prog_id,
                                        i_prog_appl_id        => p_prog_app_id,
                                        o_um_rate             => l_uom_conv_rate,
                                        o_err_num             => l_err_num,
                                        o_err_code            => l_err_code,
                                        o_err_msg             => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('UOM conv error wip_entity: '
                                                ||TO_CHAR(p_entity_id)
                                                ||':'
                                                ||l_err_msg,1,240);
                         RAISE CST_PROCESS_ERROR;

                END IF;

             ELSE
               l_stmt_num := 67;

               l_uom_conv_rate :=1;

             END IF;

        END IF; -- check for uom control level

        l_stmt_num := 70;
        IF ( p_net_qty = 0 and p_final_completion_flag = 1 ) then

           SELECT sum(primary_quantity)
           INTO   l_completed_assembly_qty
           FROM   mtl_material_transactions mmt
           WHERE  mmt.transaction_source_id = p_entity_id
           AND    nvl(mmt.repetitive_line_id,-99) = nvl(p_line_id,-99)
           AND    mmt.transaction_action_id  = 31
           AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                       AND (TRUNC(p_end_date) + 0.99999);
        END IF;

       l_conv_net_qty := p_net_qty * l_uom_conv_rate;
       -- Using same variable for conversion value aslo
       l_completed_assembly_qty := l_completed_assembly_qty * l_uom_conv_rate;

        IF (p_scrap = 1) THEN -- Its a scrap txn

          FOR c_txn_rec IN c_scrap_txn LOOP

                l_stmt_num := 75;

                insert_wip_costs
                        (p_pac_period_id          => p_pac_period_id,
                         p_prior_period_id        => p_prior_period_id,
                         p_cost_group_id          => p_cost_group_id,
                         p_cost_type_id           => p_cost_type_id,
                         p_item_id                => c_txn_rec.item_id,
                         p_entity_id              => p_entity_id,
                         p_line_id                => p_line_id,
                         p_txn_id                 => c_txn_rec.txn_id,
                         p_net_qty                => l_conv_net_qty,
                         p_completed_assembly_qty => NULL,
                         p_final_completion_flag  => NULL,
                         p_start_date             => p_start_date,
                         p_end_date               => p_end_date,
                         p_user_id                => p_user_id,
                         p_login_id               => p_login_id,
                         p_request_id             => p_request_id,
                         p_prog_id                => p_prog_id,
                         p_prog_app_id            => p_prog_app_id,
                         x_err_num                => l_err_num,
                         x_err_code               => l_err_code,
                         x_err_msg                => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Txn_id: '
                                                ||TO_CHAR(c_txn_rec.txn_id)
                                                ||':'
                                                ||l_err_msg,1,240);
                         RAISE CST_PROCESS_ERROR;

                END IF;

                l_stmt_num := 80;

                check_expense_flags (
                                p_item_id    => c_txn_rec.item_id,
                                p_subinv     => c_txn_rec.subinv,
                                p_org_id     => c_txn_rec.org_id,
                                x_exp_item   => l_exp_item,
                                x_exp_flag   => l_exp_flag,
                                x_err_num    => l_err_num,
                                x_err_code   => l_err_code,
                                x_err_msg    => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Item_id: '
                                                ||TO_CHAR(c_txn_rec.item_id)
                                                ||':'
                                                ||l_err_msg,1,240);

                        RAISE CST_PROCESS_ERROR;

                END IF;

                l_stmt_num := 85;

                CSTPPWAC.cost_processor
                        (i_legal_entity         => p_legal_entity,
                         i_pac_period_id        => p_pac_period_id,
                         i_org_id               => p_org_id,
                         i_cost_group_id        => p_cost_group_id,
                         i_txn_cost_group_id    => NULL,
                         i_txfr_cost_group_id   => NULL,
                         i_cost_type_id         => p_cost_type_id,
                         i_cost_method          => p_cost_method,
                         i_process_group        => 1,
                         i_txn_id               => c_txn_rec.txn_id,
                         i_qty_layer_id         => p_qty_layer_id,
                         i_cost_layer_id        => p_cost_layer_id,
                         i_pac_rates_id         => p_pac_rates_id,
                         i_item_id              => c_txn_rec.item_id,
                         i_txn_qty              => c_txn_rec.pri_qty *
                                                        l_uom_conv_rate,
                         i_txn_action_id        => c_txn_rec.txn_action_id,
                         i_txn_src_type_id      => c_txn_rec.txn_src_type_id,
                         i_fob_point            => NULL,
                         i_exp_item             => l_exp_item,
                         i_exp_flag             => l_exp_flag,
                         i_cost_hook_used       => -1,
                         i_user_id              => p_user_id,
                         i_login_id             => p_login_id,
                         i_req_id               => p_request_id,
                         i_prg_appl_id          => p_prog_app_id,
                         i_prg_id               => p_prog_id,
                         i_txn_category         => p_txn_category,
                         o_err_num              => l_err_num,
                         o_err_code             => l_err_code,
                         o_err_msg              => l_err_msg);

                  IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Txn_id: '
                                                ||TO_CHAR(c_txn_rec.txn_id)
                                                ||':'
                                                ||l_err_msg,1,240);
                        RAISE CST_PROCESS_ERROR;

                  END IF;

          END LOOP; --scrap_txn_loop

        ELSE -- Its is an assembly completion/return txn

          l_stmt_num := 90;

          FOR c_txn_rec IN c_assy_txn LOOP
                l_stmt_num := 95;

                  insert_wip_costs
                        (p_pac_period_id         => p_pac_period_id,
                         p_prior_period_id       => p_prior_period_id,
                         p_cost_group_id         => p_cost_group_id,
                         p_cost_type_id          => p_cost_type_id,
                         p_item_id               => c_txn_rec.item_id,
                         p_entity_id             => p_entity_id,
                         p_line_id               => p_line_id,
                         p_txn_id                => c_txn_rec.txn_id,
                         p_net_qty               => l_conv_net_qty,
                         p_completed_assembly_qty => l_completed_assembly_qty,
                         p_final_completion_flag => p_final_completion_flag,
                         p_start_date            => p_start_date,
                         p_end_date              => p_end_date,
                         p_user_id               => p_user_id,
                         p_login_id              => p_login_id,
                         p_request_id            => p_request_id,
                         p_prog_id               => p_prog_id,
                         p_prog_app_id           => p_prog_app_id,
                         x_err_num               => l_err_num,
                         x_err_code              => l_err_code,
                         x_err_msg               => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Txn_id: '
                                                ||TO_CHAR(c_txn_rec.txn_id)
                                                ||':'
                                                ||l_err_msg,1,240);

                         RAISE CST_PROCESS_ERROR;

                END IF;

                l_stmt_num := 100;

                check_expense_flags (
                                p_item_id    => c_txn_rec.item_id,
                                p_subinv     => c_txn_rec.subinv,
                                p_org_id     => c_txn_rec.org_id,
                                x_exp_item   => l_exp_item,
                                x_exp_flag   => l_exp_flag,
                                x_err_num    => l_err_num,
                                x_err_code   => l_err_code,
                                x_err_msg    => l_err_msg);

                IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Item_id: '
                                                ||TO_CHAR(c_txn_rec.item_id)
                                                ||':'
                                                ||l_err_msg,1,240);
                        RAISE CST_PROCESS_ERROR;

                END IF;

                l_stmt_num := 105;

                CSTPPWAC.cost_processor
                        (i_legal_entity         => p_legal_entity,
                         i_pac_period_id        => p_pac_period_id,
                         i_org_id               => p_org_id,
                         i_cost_group_id        => p_cost_group_id,
                         i_txn_cost_group_id    => NULL,
                         i_txfr_cost_group_id   => NULL,
                         i_cost_type_id         => p_cost_type_id,
                         i_cost_method          => p_cost_method,
                         i_process_group        => 1,
                         i_txn_id               => c_txn_rec.txn_id,
                         i_qty_layer_id         => p_qty_layer_id,
                         i_cost_layer_id        => p_cost_layer_id,
                         i_pac_rates_id         => p_pac_rates_id,
                         i_item_id              => c_txn_rec.item_id,
                         i_txn_qty              => c_txn_rec.pri_qty *
                                                        l_uom_conv_rate,
                         i_txn_action_id        => c_txn_rec.txn_action_id,
                         i_txn_src_type_id      => c_txn_rec.txn_src_type_id,
                         i_fob_point            => NULL,
                         i_exp_item             => l_exp_item,
                         i_exp_flag             => l_exp_flag,
                         i_cost_hook_used       => -1,
                         i_user_id              => p_user_id,
                         i_login_id             => p_login_id,
                         i_req_id               => p_request_id,
                         i_prg_appl_id          => p_prog_app_id,
                         i_prg_id               => p_prog_id,
                         i_txn_category         => p_txn_category,
                         o_err_num              => l_err_num,
                         o_err_code             => l_err_code,
                         o_err_msg              => l_err_msg);

                  IF (l_err_num <> 0) THEN

                        l_err_msg := SUBSTR('Txn_id: '
                                                ||TO_CHAR(c_txn_rec.txn_id)
                                                ||':'
                                                ||l_err_msg,1,240);
                        RAISE CST_PROCESS_ERROR;
                END IF;

          END LOOP; --assy_txn_loop
        END IF; -- check for p_scrap

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

        WHEN CST_PROCESS_ERROR THEN
                IF (l_exceptionLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                                   l_module || '.' || l_stmt_num,
                                   l_err_msg);
                END IF;
                x_err_num := l_err_num;
                x_err_code := l_err_code;
                x_err_msg := l_err_msg;

        WHEN OTHERS THEN
                IF (l_uLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                   l_module || '.' || l_stmt_num,
                                   SQLERRM);
                END IF;
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPWAS.process_net_relief('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

END process_net_relief;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_nonreworkassembly_txns                                       |
|   called for items that have nonrework completion/return/scrap txns        |
|   in the period                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE process_nonreworkassembly_txns(
       p_pac_period_id                  IN      NUMBER,
       p_start_date                     IN      DATE,
       p_end_date                       IN      DATE,
       p_prior_period_id                IN      NUMBER,
       p_item_id                        IN      NUMBER,
       p_cost_group_id                  IN      NUMBER,
       p_cost_type_id                   IN      NUMBER,
       p_legal_entity                   IN      NUMBER,
       p_cost_method                    IN      NUMBER,
       p_pac_rates_id                   IN      NUMBER,
       p_master_org_id                  IN      NUMBER,
       p_material_relief_algorithm      IN      NUMBER,
       p_uom_control                    IN      NUMBER,
       p_low_level_code                 IN      NUMBER,
       p_user_id                        IN      NUMBER,
       p_login_id                       IN      NUMBER,
       p_request_id                     IN      NUMBER,
       p_prog_id                        IN      NUMBER DEFAULT -1,
       p_prog_app_id                    IN      NUMBER DEFAULT -1,
       x_err_num                        OUT NOCOPY      NUMBER,
       x_err_code                       OUT NOCOPY      VARCHAR2,
       x_err_msg                        OUT NOCOPY      VARCHAR2)
IS

l_cost_method_hook              NUMBER;
l_cost_layer_id                 NUMBER;
l_qty_layer_id                  NUMBER;
l_open_flag                     VARCHAR2(1);
l_stmt_num                      NUMBER;
l_pri_uom_code                  VARCHAR2(3);
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_exp_flag                      NUMBER;
l_exp_item                      NUMBER;
cst_process_error               EXCEPTION;
l_final_completion_count        NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'process_nonreworkassembly_txns';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

------------------------------------------------------------------------------
-- All relieves are based on the concept of net relieves. i.e.
-- Net Relief = Completion - Return
-- Job information is also built on the concept of net units earned i.e.
-- if you complete 10 units from Op 10 and Return 5 units to Op 30 then,
-- the net relief logic uses:
-- net_qty = 10-5 = 5
-- Resource earned at Op 10 = 10
-- Resource earned at Op 30 = 5
-- Its possible then the completion is done at period P1 where the PAC
-- rates (say for a resource) were lower than the period (P2) in which the
-- net return was done.   Net return is always done based on prior period's
-- values.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- This cursor will give the net scrap qty for all wip_entity/line that :-
--      1. Had scrap transaction(s) in this period
--      2. AND entity belongs to one of the memeber organizations
--      3. AND entity has a record in wppb i.e. has some value
--      4. AND entity is a non-rework job
------------------------------------------------------------------------------

       CURSOR  c_non_rework_entity_scrap  IS
       SELECT  mmt.transaction_source_id entity_id,
               mmt.organization_id org_id,
               we.entity_type entity_type,
               mmt.repetitive_line_id line_id,
               mmt.operation_seq_num op_seq,
               SUM(mmt.primary_quantity) net_scrap
       FROM    mtl_material_transactions mmt,
               cst_cost_group_assignments ccga,
               wip_entities we
       WHERE   mmt.inventory_item_id = p_item_id
       AND     mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND     mmt.transaction_source_type_id = 5
       AND     mmt.transaction_action_id  = 30
       AND     mmt.organization_id = ccga.organization_id
       AND     ccga.cost_group_id = p_cost_group_id
       AND     we.wip_entity_id = mmt.transaction_source_id
       AND     we.organization_id = mmt.organization_id
       AND     NOT EXISTS  (SELECT 1
                            FROM   mtl_material_transactions mmt1
                            WHERE  mmt1.inventory_item_id = we.primary_item_id
                            AND    mmt1.transaction_source_id = we.wip_entity_id
                            AND    mmt1.organization_id = we.organization_id
                            AND    mmt1.transaction_source_type_id = 5
                            AND    mmt1.transaction_action_id in (1,27,33,34)
                            AND    mmt1.transaction_date BETWEEN TRUNC(p_start_date)
                                                      AND     (TRUNC (p_end_date) + 0.99999))
       GROUP BY
               mmt.transaction_source_id,
               mmt.organization_id,
               we.entity_type,
               mmt.repetitive_line_id,
               mmt.operation_seq_num
        ORDER BY
                SUM(mmt.primary_quantity) DESC, -- minimize the occurences of negative periodic inventory quantity
                mmt.transaction_source_id;      -- a consistent tie breaker


------------------------------------------------------------------------------
-- This cursor will give the net compl/ret qty for all wip_entity/line that :-
--      1. Had completion/return transaction(s) in this period
--      2. AND entity belongs to one of the memeber organizations
--      3. AND entity has a record in wppb i.e. has some value
--      4. AND entity is a non-rework job
------------------------------------------------------------------------------

       CURSOR   c_non_rework_entity_complete  IS
       SELECT   mmt.transaction_source_id entity_id,
                mmt.organization_id org_id,
                we.entity_type entity_type,
                mmt.repetitive_line_id line_id,
                SUM(mmt.primary_quantity) net_completion
       FROM     mtl_material_transactions mmt,
                cst_cost_group_assignments ccga,
                wip_entities we
       WHERE    mmt.inventory_item_id = p_item_id
       AND      mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND      mmt.transaction_source_type_id = 5
       AND      mmt.transaction_action_id IN (31,32)
       AND      mmt.organization_id = ccga.organization_id
       AND      ccga.cost_group_id = p_cost_group_id
       AND      we.wip_entity_id = mmt.transaction_source_id
       AND      we.organization_id = mmt.organization_id
       AND      NOT EXISTS (SELECT 1
                            FROM   mtl_material_transactions mmt1
                            WHERE  mmt1.inventory_item_id = we.primary_item_id
                            AND    mmt1.transaction_source_id = we.wip_entity_id
                            AND    mmt1.organization_id = we.organization_id
                            AND    mmt1.transaction_source_type_id = 5
                            AND    mmt1.transaction_action_id in (1,27,33,34)
                            AND    mmt1.transaction_date BETWEEN TRUNC(p_start_date)
                                                             AND (TRUNC (p_end_date) + 0.99999))
        /* R12 PAC Enhancements for China and Taiwan: Exclude eAM entities as rebuildable jobs can be
           completed only in expense subinventories at 0 cost so they should not be costed and no
           distributions created */
        AND     we.entity_type not in (6,7)
       GROUP BY
               mmt.transaction_source_id,
               mmt.organization_id,
               we.entity_type,
               mmt.repetitive_line_id
       ORDER BY
                SUM(mmt.primary_quantity) DESC, -- minimize the occurences of negative periodic inventory quantity
                mmt.transaction_source_id;      -- a consistent tie breaker

------------------------------------------------------------------------------
-- This Cursor will get all scrap quantity without scrap account
-- in this period for a given assembly
-- Populates all the wip entities for this assembly
------------------------------------------------------------------------------
       CURSOR scrap_no_account is
       SELECT wmt.transaction_id wip_txn_id,
              wmt.wip_entity_id wip_entity,
              wmt.line_id line,
              wmt.fm_operation_seq_num from_op_seq,
              wmt.fm_intraoperation_step_type from_op_step,
              wmt.to_operation_seq_num to_op_seq,
              wmt.to_intraoperation_step_type to_op_step,
              wmt.primary_quantity pri_qty
       FROM   cst_cost_group_assignments ccga,
              wip_move_transactions wmt
       WHERE  wmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND    wmt.organization_id = ccga.organization_id
       AND    ccga.cost_group_id = p_cost_group_id
       AND    wmt.primary_item_id = p_item_id
       AND    wmt.scrap_account_id is null
       AND    (wmt.fm_intraoperation_step_type = 5 OR
               wmt.to_intraoperation_step_type = 5);

BEGIN

       IF (l_pLog) THEN
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.begin',
                        l_api_name || ' <<< Parameters:
                        p_pac_period_id = ' || p_pac_period_id || '
                        p_prior_period_id = ' || p_prior_period_id || '
                        p_item_id = ' || p_item_id || '
                        p_low_level_code = ' || p_low_level_code || '
			p_material_relief_algorithm = '|| p_material_relief_algorithm || '
                        p_cost_type_id = ' || p_cost_type_id );

       END IF;

       ----------------------------------------------------------------------
       -- Initialize Variables
       ----------------------------------------------------------------------

       l_err_num := 0;
       l_err_code := '';
       l_err_msg := '';
       l_cost_layer_id := 0;
       l_qty_layer_id := 0;
       l_cost_method_hook := -1;

       ----------------------------------------------------------------------
       -- Check and Create layer for the assembly, if required
       ----------------------------------------------------------------------

       l_stmt_num := 5;
       CSTPPCLM.layer_id (
                       i_pac_period_id => p_pac_period_id,
                       i_legal_entity  => p_legal_entity,
                       i_item_id => p_item_id,
                       i_cost_group_id => p_cost_group_id,
                       o_cost_layer_id => l_cost_layer_id,
                       o_quantity_layer_id => l_qty_layer_id,
                       o_err_num => l_err_num,
                       o_err_code => l_err_code,
                       o_err_msg  => l_err_msg);

       IF (l_err_num <> 0) THEN
               RAISE CST_PROCESS_ERROR;
       END IF;


       IF (l_cost_layer_id = 0 AND l_qty_layer_id = 0) THEN
       l_stmt_num := 10;
       CSTPPCLM.create_layer (
                       i_pac_period_id  => p_pac_period_id,
                       i_legal_entity   => p_legal_entity,
                       i_item_id        => p_item_id,
                       i_cost_group_id  => p_cost_group_id,
                       i_user_id        => p_user_id,
                       i_login_id       => p_login_id,
                       i_request_id     => p_request_id,
                       i_prog_id        => p_prog_id,
                       i_prog_appl_id   => p_prog_app_id,
                       o_cost_layer_id  => l_cost_layer_id,
                       o_quantity_layer_id => l_qty_layer_id,
                       o_err_num        => l_err_num,
                       o_err_code       => l_err_code,
                       o_err_msg        => l_err_msg);

               IF (l_err_num <> 0) THEN
                       RAISE CST_PROCESS_ERROR;
               END IF;
       END IF; -- Check Create Layer

        FOR c_scrap_rec IN scrap_no_account LOOP
        l_stmt_num := 15;

        IF (c_scrap_rec.from_op_step <> 5 and c_scrap_rec.to_op_step = 5) then

           l_stmt_num := 20;
           UPDATE WIP_PAC_PERIOD_BALANCES
           SET    unrelieved_scrap_quantity = nvl(unrelieved_scrap_quantity,0) + c_scrap_rec.pri_qty
           WHERE  wip_entity_id =  c_scrap_rec.wip_entity
           AND    nvl(line_id,-99) = decode(wip_entity_type, 4, -99, nvl(c_scrap_rec.line,-99))
           AND    operation_seq_num <= c_scrap_rec.to_op_seq
           AND    cost_type_id =  p_cost_type_id
           AND    pac_period_id = p_pac_period_id
           AND    cost_group_id = p_cost_group_id;

         END IF;

         IF (c_scrap_rec.from_op_step = 5 and c_scrap_rec.to_op_step <> 5) then

           l_stmt_num := 25;

           UPDATE WIP_PAC_PERIOD_BALANCES
           SET    unrelieved_scrap_quantity = nvl(unrelieved_scrap_quantity,0) - c_scrap_rec.pri_qty
           WHERE  wip_entity_id =  c_scrap_rec.wip_entity
           AND    nvl(line_id,-99) = decode(wip_entity_type, 4, -99, nvl(c_scrap_rec.line,-99))
           AND    operation_seq_num <= c_scrap_rec.from_op_seq
           AND    cost_type_id =  p_cost_type_id
           AND    pac_period_id = p_pac_period_id
           AND    cost_group_id = p_cost_group_id;

         END IF;

         IF (c_scrap_rec.from_op_step = 5 and c_scrap_rec.to_op_step = 5) then

           l_stmt_num := 30;

           IF (c_scrap_rec.from_op_seq > c_scrap_rec.to_op_seq) THEN

              l_stmt_num := 35;
              UPDATE WIP_PAC_PERIOD_BALANCES
              SET    unrelieved_scrap_quantity = nvl(unrelieved_scrap_quantity,0) - c_scrap_rec.pri_qty
              WHERE  wip_entity_id =  c_scrap_rec.wip_entity
              AND    nvl(line_id,-99) = decode(wip_entity_type, 4, -99, nvl(c_scrap_rec.line,-99))
              AND    operation_seq_num > c_scrap_rec.to_op_seq
              AND    operation_seq_num <= c_scrap_rec.from_op_seq
              AND    cost_type_id =  p_cost_type_id
              AND    pac_period_id = p_pac_period_id
              AND    cost_group_id = p_cost_group_id;

           ELSE

               l_stmt_num := 40;

               UPDATE WIP_PAC_PERIOD_BALANCES
               SET    unrelieved_scrap_quantity = nvl(unrelieved_scrap_quantity,0) + c_scrap_rec.pri_qty
               WHERE  wip_entity_id =  c_scrap_rec.wip_entity
               AND    nvl(line_id,-99) = decode(wip_entity_type, 4, -99, nvl(c_scrap_rec.line,-99))
               AND    operation_seq_num > c_scrap_rec.from_op_seq
               AND    operation_seq_num <= c_scrap_rec.to_op_seq
               AND    cost_type_id =  p_cost_type_id
               AND    pac_period_id = p_pac_period_id
               AND    cost_group_id = p_cost_group_id;

           END IF;
         END IF;

       END LOOP;

      FOR c_ent_rec IN c_non_rework_entity_scrap LOOP

           fnd_file.put_line(fnd_file.log,' Scrap_Qty Update << ');
           l_stmt_num := 45;

           UPDATE WIP_PAC_PERIOD_BALANCES
           SET    relieved_scrap_qty = nvl(relieved_scrap_qty,0) + c_ent_rec.net_scrap
           WHERE  wip_entity_id =  c_ent_rec.entity_id
           AND    nvl(line_id,-99) = decode(wip_entity_type, 4, -99, nvl(c_ent_rec.line_id,-99))
           AND    operation_seq_num <= c_ent_rec.op_seq
           AND    cost_type_id =  p_cost_type_id
           AND    pac_period_id = p_pac_period_id
           AND    cost_group_id = p_cost_group_id;

      END LOOP;


       l_stmt_num := 50;

    --------------------------------------------------------------------------
    -- Process scrap transactions for non-rework jobs
    -- If number of records exceeds threshold value, insert them into
    -- CST_PAC_PERIOD_BALANCES and clear the PL/SQL tables.
    --------------------------------------------------------------------------

       FOR c_ent_rec IN c_non_rework_entity_scrap LOOP
       l_stmt_num := 60;
        IF (CSTPPINV.l_item_id_tbl.COUNT >= G_MAX_RECORDS AND p_cost_method <> 4) THEN
          CSTPPWAC.insert_into_cppb(i_pac_period_id   =>  p_pac_period_id,
                                    i_cost_group_id   =>  p_cost_group_id,
                                    i_txn_category    =>  4,        /* Non-rework completions */
                                    i_user_id         =>  p_user_id,
                                    i_login_id        =>  p_login_id,
                                    i_request_id      =>  p_request_id,
                                    i_prog_id         =>  p_prog_id,
                                    i_prog_appl_id    =>  p_prog_app_id,
                                    o_err_num         =>  l_err_num,
                                    o_err_code        =>  l_err_code,
                                    o_err_msg         =>  l_err_msg);
          IF (l_err_num <> 0) THEN
              l_err_msg := SUBSTR('CSTPPWAS.process_nonreworkassembly_txns('
                                ||TO_CHAR(l_stmt_num)
                                ||'):'
                                ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
        END IF;

       l_stmt_num := 65;
       process_net_relief       (
               p_pac_period_id             => p_pac_period_id,
               p_prior_period_id           => p_prior_period_id,
               p_cost_group_id             => p_cost_group_id,
               p_cost_type_id              => p_cost_type_id,
               p_legal_entity              => p_legal_entity,
               p_cost_method               => p_cost_method,
               p_cost_layer_id             => l_cost_layer_id,
               p_qty_layer_id              => l_qty_layer_id,
               p_pac_rates_id              => p_pac_rates_id,
               p_entity_type               => c_ent_rec.entity_type,
               p_org_id                    => c_ent_rec.org_id,
               p_entity_id                 => c_ent_rec.entity_id,
               p_line_id                   => c_ent_rec.line_id,
               p_net_qty                   =>  c_ent_rec.net_scrap,
               p_start_date                => p_start_date,
               p_end_date                  => p_end_date,
               p_scrap                     => 1,
               p_op_seq                    => c_ent_rec.op_seq,
               p_final_completion_flag     => NULL,
               p_material_relief_algorithm => p_material_relief_algorithm,
               p_master_org_id             => p_master_org_id,
               p_uom_control               => p_uom_control,
               p_user_id                   => p_user_id,
               p_login_id                  => p_login_id,
               p_request_id                => p_request_id,
               p_prog_id                   => p_prog_id,
               p_prog_app_id               => p_prog_app_id,
               p_txn_category              => 4,  -- txn_category = 4 for non-rework completions/scrap
               x_err_num                   => l_err_num,
               x_err_code                  => l_err_code,
               x_err_msg                   => l_err_msg);

               IF (l_err_num <>0) THEN
                       l_err_msg := SUBSTR('scrap entity/line: '
                                       ||TO_CHAR(c_ent_rec.entity_id)
                                       ||'/'
                                       ||TO_CHAR(c_ent_rec.line_id)
                                       ||':'
                                       ||l_err_msg,1,240);
                       RAISE CST_PROCESS_ERROR;
               END IF;
       END LOOP; --c_non_rework_entity_scrap

    --------------------------------------------------------------------------
    -- Process completions transactions for non-rework jobs
    -- If number of records exceeds threshold value, insert them into
    -- CST_PAC_PERIOD_BALANCES and clear the PL/SQL tables.
    --------------------------------------------------------------------------

       l_stmt_num := 70;
       FOR c_ent_rec IN c_non_rework_entity_complete LOOP
       l_stmt_num := 75;

       SELECT count(*)
       INTO   l_final_completion_count
       FROM   mtl_material_transactions mmt
       WHERE  mmt.transaction_source_id = c_ent_rec.entity_id
       AND    nvl(mmt.repetitive_line_id,-99) = nvl( c_ent_rec.line_id,-99)
       AND    mmt.final_completion_flag = 'Y'
       AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                       AND (TRUNC(p_end_date) + 0.99999)
       AND    ROWNUM < 2;

        IF (CSTPPINV.l_item_id_tbl.COUNT >= G_MAX_RECORDS AND p_cost_method <> 4) THEN
          l_stmt_num := 80;
          CSTPPWAC.insert_into_cppb(i_pac_period_id   =>  p_pac_period_id,
                                    i_cost_group_id   =>  p_cost_group_id,
                                    i_txn_category    =>  4,   /* Non-rework completions */
                                    i_user_id         =>  p_user_id,
                                    i_login_id        =>  p_login_id,
                                    i_request_id      =>  p_request_id,
                                    i_prog_id         =>  p_prog_id,
                                    i_prog_appl_id    =>  p_prog_app_id,
                                    o_err_num         =>  l_err_num,
                                    o_err_code        =>  l_err_code,
                                    o_err_msg         =>  l_err_msg);
          IF (l_err_num <> 0) THEN
              l_err_msg := SUBSTR('CSTPPWAS.process_nonreworkassembly_txns('
                                ||TO_CHAR(l_stmt_num)
                                ||'):'
                                ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
        END IF;

       l_stmt_num := 85;
       process_net_relief       (
               p_pac_period_id              => p_pac_period_id,
               p_prior_period_id            => p_prior_period_id,
               p_cost_group_id              => p_cost_group_id,
               p_cost_type_id               => p_cost_type_id,
               p_legal_entity               => p_legal_entity,
               p_cost_method                => p_cost_method,
               p_cost_layer_id              => l_cost_layer_id,
               p_qty_layer_id               => l_qty_layer_id,
               p_pac_rates_id               => p_pac_rates_id,
               p_entity_type                => c_ent_rec.entity_type,
               p_org_id                     => c_ent_rec.org_id,
               p_entity_id                  => c_ent_rec.entity_id,
               p_line_id                    => c_ent_rec.line_id,
               p_net_qty                    => c_ent_rec.net_completion,
               p_start_date                 => p_start_date,
               p_end_date                   => p_end_date,
               p_scrap                      => -1,
               p_op_seq                     => NULL,
               p_final_completion_flag      => l_final_completion_count,
               p_material_relief_algorithm  => p_material_relief_algorithm,
               p_master_org_id              => p_master_org_id,
               p_uom_control                => p_uom_control,
               p_user_id                    => p_user_id,
               p_login_id                   => p_login_id,
               p_request_id                 => p_request_id,
               p_prog_id                    => p_prog_id,
               p_prog_app_id                => p_prog_app_id,
               p_txn_category               => 4,  -- txn_category = 4 for non-rework completions/scrap
               x_err_num                    => l_err_num,
               x_err_code                   => l_err_code,
               x_err_msg                    => l_err_msg);

               IF (l_err_num <>0) THEN
                 l_err_msg := SUBSTR('cmpl entity/line: '
                                 ||TO_CHAR(c_ent_rec.entity_id)
                                 ||'/'
                                 ||TO_CHAR(c_ent_rec.line_id)
                                 ||':'
                                 ||l_err_msg,1,240);
                 RAISE CST_PROCESS_ERROR;
               END IF;
       END LOOP; --c_non_rework_entity_complete

      -- Flush the remaining records from PL/SQL tables.
      l_stmt_num := 90;
      IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND p_cost_method <> 4) THEN
          CSTPPWAC.insert_into_cppb(i_pac_period_id   =>  p_pac_period_id,
                                    i_cost_group_id   =>  p_cost_group_id,
                                    i_txn_category    =>  4,  /* Non-rework completions */
                                    i_user_id         =>  p_user_id,
                                    i_login_id        =>  p_login_id,
                                    i_request_id      =>  p_request_id,
                                    i_prog_id         =>  p_prog_id,
                                    i_prog_appl_id    =>  p_prog_app_id,
                                    o_err_num         =>  l_err_num,
                                    o_err_code        =>  l_err_code,
                                    o_err_msg         =>  l_err_msg);

          IF (l_err_num <> 0) THEN
              l_err_msg := SUBSTR('CSTPPWAS.process_nonreworkassembly_txns('
                                ||TO_CHAR(l_stmt_num)
                                ||'):'
                                ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
       END IF;

       IF (p_cost_method <> 4) THEN
         l_stmt_num := 100;
         CSTPPWAC.update_cppb(i_pac_period_id  =>  p_pac_period_id,
                              i_cost_group_id  =>  p_cost_group_id,
                              i_txn_category   =>  4,    /* Non-rework Completions */
                              i_low_level_code =>  p_low_level_code,
                              i_user_id        =>  p_user_id,
                              i_login_id       =>  p_login_id,
                              i_request_id     =>  p_request_id,
                              i_prog_id        =>  p_prog_id,
                              i_prog_appl_id   =>  p_prog_app_id,
                              o_err_num        =>  l_err_num,
                              o_err_code       =>  l_err_code,
                              o_err_msg        =>  l_err_msg);

         IF (l_err_num <> 0) THEN
            l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                  || TO_CHAR(l_stmt_num)
                                  ||'):'
                                  ||l_err_msg,1,240);
             RAISE CST_PROCESS_ERROR;
         END IF;
       END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

       WHEN CST_PROCESS_ERROR THEN
               IF (l_exceptionLog) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                                  l_module || '.' || l_stmt_num,
                                  l_err_msg);
               END IF;
               x_err_num := l_err_num;
               x_err_code := l_err_code;
               x_err_msg := SUBSTR(l_err_msg,1,240);

       WHEN OTHERS THEN
               IF (l_uLog) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                  l_module || '.' || l_stmt_num,
                                  SQLERRM);
               END IF;
               ROLLBACK;
               x_err_num := SQLCODE;
               x_err_code := NULL;
               x_err_msg := SUBSTR('CSTPPWAS.process_nonreworkassembly_txns ('
                               || to_char(l_stmt_num)
                               || '): '
                               ||SQLERRM,1,240);

END process_nonreworkassembly_txns;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_reworkassembly_txns                                          |
|  Called for items that have rework completion/return/scrap txns            |
|  in the period                                                             |
*----------------------------------------------------------------------------*/
PROCEDURE process_reworkassembly_txns(
       p_pac_period_id                  IN      NUMBER,
       p_start_date                     IN      DATE,
       p_end_date                       IN      DATE,
       p_prior_period_id                IN      NUMBER,
       p_item_id                        IN      NUMBER,
       p_cost_group_id                  IN      NUMBER,
       p_cost_type_id                   IN      NUMBER,
       p_legal_entity                   IN      NUMBER,
       p_cost_method                    IN      NUMBER,
       p_pac_rates_id                   IN      NUMBER,
       p_master_org_id                  IN      NUMBER,
       p_material_relief_algorithm      IN      NUMBER,
       p_uom_control                    IN      NUMBER,
       p_low_level_code                 IN      NUMBER,
       p_user_id                        IN      NUMBER,
       p_login_id                       IN      NUMBER,
       p_request_id                     IN      NUMBER,
       p_prog_id                        IN      NUMBER DEFAULT -1,
       p_prog_app_id                    IN      NUMBER DEFAULT -1,
       x_err_num                        OUT NOCOPY      NUMBER,
       x_err_code                       OUT NOCOPY      VARCHAR2,
       x_err_msg                        OUT NOCOPY      VARCHAR2)
IS
l_cost_method_hook              NUMBER;
l_cost_layer_id                 NUMBER;
l_qty_layer_id                  NUMBER;
l_open_flag                     VARCHAR2(1);
l_stmt_num                      NUMBER;
l_pri_uom_code                  VARCHAR2(3);
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_exp_flag                      NUMBER;
l_exp_item                      NUMBER;
cst_process_error               EXCEPTION;
l_final_completion_count        NUMBER;
l_co_txns_count                 NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'process_reworkassembly_txns';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

------------------------------------------------------------------------------
-- This cursor will get all the WIP Component txns where this item
-- is issued to a WIP entity building itself.(Non Standard Job-Rework)
------------------------------------------------------------------------------

       CURSOR   c_rework_issue_txns IS
       SELECT   mmt.transaction_id txn_id,
                mmt.transaction_source_id entity_id,
                mmt.repetitive_line_id line_id,
                mmt.primary_quantity pri_qty,
                mmt.inventory_item_id item_id,
                mmt.operation_seq_num op_seq,
                mmt.organization_id org_id
       FROM     mtl_material_transactions mmt,
                wip_entities we,
                cst_cost_group_assignments ccga /* bug3930450 - Added ccga join to process txns for a particular cost group */
       WHERE    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND      ccga.cost_group_id = p_cost_group_id /* bug3930450 */
       AND      ccga.organization_id = mmt.organization_id /* bug3930450 */
       AND      mmt.transaction_source_type_id = 5
       AND      mmt.transaction_action_id IN (1,27,33,34)
       AND      mmt.inventory_item_id = p_item_id
       AND      we.wip_entity_id = mmt.transaction_source_id
       AND      we.organization_id = mmt.organization_id
       AND      NVL(we.primary_item_id,-1) = mmt.inventory_item_id;

-----------------------------------------------------------------------------
-- This cursor will give the net scrap qty for all wip_entity/line that :-
--      1. Had scrap transaction(s) in this period
--      2. AND entity belongs to one of the memeber organizations
--      3. AND entity has a record in wppb i.e. has some value
--      4. AND entity is a rework job
------------------------------------------------------------------------------

       CURSOR   c_rework_entity_scrap  IS
       SELECT   mmt.transaction_source_id entity_id,
                mmt.organization_id org_id,
                we.entity_type entity_type,
                mmt.repetitive_line_id line_id,
                mmt.operation_seq_num op_seq,
                SUM(mmt.primary_quantity) net_scrap
       FROM     mtl_material_transactions mmt,
                cst_cost_group_assignments ccga,
                wip_entities we
       WHERE    mmt.inventory_item_id = p_item_id
       AND      mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND      mmt.transaction_source_type_id = 5
       AND      mmt.transaction_action_id  = 30
       AND      mmt.organization_id = ccga.organization_id
       AND      ccga.cost_group_id = p_cost_group_id
       AND      we.wip_entity_id = mmt.transaction_source_id
       AND      we.organization_id = mmt.organization_id
       AND      EXISTS (SELECT  1
                        FROM    mtl_material_transactions mmt1
                        WHERE   mmt1.inventory_item_id = we.primary_item_id
                        AND     mmt1.transaction_source_id = we.wip_entity_id
                        AND     mmt1.organization_id = we.organization_id
                        AND     mmt1.transaction_source_type_id = 5
                        AND     mmt1.transaction_action_id in (1,27,33,34)
                        AND     mmt1.transaction_date BETWEEN TRUNC(p_start_date)
                                           AND    (TRUNC (p_end_date) + 0.99999))
       GROUP BY
               mmt.transaction_source_id,
               mmt.organization_id,
               we.entity_type,
               mmt.repetitive_line_id,
               mmt.operation_seq_num
        ORDER BY
                SUM(mmt.primary_quantity) DESC, -- minimize the occurences of negative periodic inventory quantity
                mmt.transaction_source_id;      -- a consistent tie breaker

-----------------------------------------------------------------------------
-- This cursor will give the net compl/ret qty for all wip_entity/line that :-
--      1. Had completion/return transaction(s) in this period
--      2. AND entity belongs to one of the memeber organizations
--      3. AND entity has a record in wppb i.e. has some value
--      4. AND entity is a rework job
------------------------------------------------------------------------------

       CURSOR   c_rework_entity_complete  IS
       SELECT   mmt.transaction_source_id entity_id,
                mmt.organization_id org_id,
                we.entity_type entity_type,
                mmt.repetitive_line_id line_id,
                SUM(mmt.primary_quantity) net_completion
       FROM     mtl_material_transactions mmt,
                cst_cost_group_assignments ccga,
                wip_entities we
       WHERE    mmt.inventory_item_id = p_item_id
       AND      mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                    AND (TRUNC(p_end_date) + 0.99999)
       AND      mmt.transaction_source_type_id = 5
       AND      mmt.transaction_action_id IN (31,32)
       AND      mmt.organization_id = ccga.organization_id
       AND      ccga.cost_group_id = p_cost_group_id
       AND      we.wip_entity_id = mmt.transaction_source_id
       AND      we.organization_id = mmt.organization_id
       AND      EXISTS(SELECT   1
                       FROM     mtl_material_transactions mmt1
                       WHERE    mmt1.inventory_item_id = we.primary_item_id
                       AND      mmt1.transaction_source_id = we.wip_entity_id
                       AND      mmt1.organization_id = we.organization_id
                       AND      mmt1.transaction_source_type_id = 5
                       AND      mmt1.transaction_action_id in (1,27,33,34)
                       AND      mmt1.transaction_date BETWEEN TRUNC(p_start_date)
                                                    AND (TRUNC (p_end_date) + 0.99999))
        /* Exclude eAM entities as only rebuildable jobs can be completed only
        in expense subinventories at 0 cost so they should not be costed and no
        distributions created */
        AND     we.entity_type not in (6,7)
       GROUP BY
               mmt.transaction_source_id,
               mmt.organization_id,
               we.entity_type,
               mmt.repetitive_line_id
       ORDER BY
                SUM(mmt.primary_quantity) DESC, -- minimize the occurences of negative periodic inventory quantity
                mmt.transaction_source_id;      -- a consistent tie breaker

BEGIN

       IF (l_pLog) THEN

        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.begin',
                        l_api_name || ' <<< Parameters:
                        p_pac_period_id = ' || p_pac_period_id || '
                        p_prior_period_id = ' || p_prior_period_id || '
                        p_item_id = ' || p_item_id || '
                        p_low_level_code = ' || p_low_level_code || '
			p_material_relief_algorithm = '|| p_material_relief_algorithm || '
                        p_cost_type_id = ' || p_cost_type_id );
        END IF;

       ----------------------------------------------------------------------
       -- Initialize Variables
       ----------------------------------------------------------------------

       l_err_num := 0;
       l_err_code := '';
       l_err_msg := '';
       l_cost_layer_id := 0;
       l_qty_layer_id := 0;
       l_cost_method_hook := -1;
       l_co_txns_count := 0;
       ----------------------------------------------------------------------
       -- Check and Create layer for the assembly, if required
       ----------------------------------------------------------------------

       l_stmt_num := 5;

       CSTPPCLM.layer_id (
                       i_pac_period_id => p_pac_period_id,
                       i_legal_entity  => p_legal_entity,
                       i_item_id => p_item_id,
                       i_cost_group_id => p_cost_group_id,
                       o_cost_layer_id => l_cost_layer_id,
                       o_quantity_layer_id => l_qty_layer_id,
                       o_err_num => l_err_num,
                       o_err_code => l_err_code,
                       o_err_msg  => l_err_msg);

       IF (l_err_num <> 0) THEN
               RAISE CST_PROCESS_ERROR;
       END IF;


       IF (l_cost_layer_id = 0 AND l_qty_layer_id = 0) THEN

       l_stmt_num := 10;

       CSTPPCLM.create_layer (
                       i_pac_period_id => p_pac_period_id,
                       i_legal_entity  => p_legal_entity,
                       i_item_id        => p_item_id,
                       i_cost_group_id => p_cost_group_id,
                       i_user_id        => p_user_id,
                       i_login_id       => p_login_id,
                       i_request_id     => p_request_id,
                       i_prog_id        => p_prog_id,
                       i_prog_appl_id   => p_prog_app_id,
                       o_cost_layer_id  => l_cost_layer_id,
                       o_quantity_layer_id => l_qty_layer_id,
                       o_err_num        => l_err_num,
                       o_err_code       => l_err_code,
                       o_err_msg        => l_err_msg);

               IF (l_err_num <> 0) THEN
                       RAISE CST_PROCESS_ERROR;
               END IF;
       END IF; -- Check Create Layer

       l_stmt_num := 15;
       FOR c_rework_rec IN c_rework_issue_txns LOOP

        IF (CSTPPINV.l_item_id_tbl.COUNT >= G_MAX_RECORDS AND p_cost_method <> 4) THEN
          l_stmt_num := 20;
          CSTPPWAC.insert_into_cppb(i_pac_period_id  =>  p_pac_period_id,
                                    i_cost_group_id  =>  p_cost_group_id,
                                    i_txn_category   =>  6,      /* Rework Issues */
                                    i_user_id        =>  p_user_id,
                                    i_login_id       =>  p_login_id,
                                    i_request_id     =>  p_request_id,
                                    i_prog_id        =>  p_prog_id,
                                    i_prog_appl_id   =>  p_prog_app_id,
                                    o_err_num        =>  l_err_num,
                                    o_err_code       =>  l_err_code,
                                    o_err_msg        =>  l_err_msg);

          IF (l_err_num <> 0) THEN
             l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                ||TO_CHAR(l_stmt_num)
                                ||'):'
                                ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
        END IF;

       l_stmt_num := 25;
       CSTPPWMT.charge_wip_material (
                       p_pac_period_id              => p_pac_period_id,
                       p_cost_group_id              => p_cost_group_id,
                       p_txn_id                     => c_rework_rec.txn_id,
                       p_exp_item                   => NULL,
                       p_exp_flag                   => NULL,
                       p_legal_entity               => p_legal_entity,
                       p_cost_type_id               => p_cost_type_id,
                       p_cost_method                => p_cost_method,
                       p_pac_rates_id               => p_pac_rates_id,
                       p_master_org_id              => p_master_org_id,
                       p_material_relief_algorithm  => p_material_relief_algorithm,
                       p_uom_control                => p_uom_control,
                       p_user_id                    => p_user_id,
                       p_login_id                   => p_login_id,
                       p_request_id                 => p_request_id,
                       p_prog_id                    => p_prog_id,
                       p_prog_app_id                => p_prog_app_id,
                       p_txn_category               => 6,        /* Rework issues */
                       x_cost_method_hook           => l_cost_method_hook,
                       x_err_num                    => l_err_num,
                       x_err_code                   => l_err_code,
                       x_err_msg                    => l_err_msg);

               IF (l_err_num <>0) THEN
                       l_err_msg := SUBSTR('Rewrk_txn_id: '
                                       ||TO_CHAR(c_rework_rec.txn_id)
                                       ||':'
                                       ||l_err_msg,1,240);
                       RAISE CST_PROCESS_ERROR;
               END IF;
       END LOOP; --c_rework_issue_txns

       l_stmt_num := 30;
       IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND p_cost_method <> 4) THEN

        CSTPPWAC.insert_into_cppb(i_pac_period_id  =>  p_pac_period_id,
                                  i_cost_group_id  =>  p_cost_group_id,
                                  i_txn_category   =>  6,  /* Rework Issues */
                                  i_user_id        =>  p_user_id,
                                  i_login_id       =>  p_login_id,
                                  i_request_id     =>  p_request_id,
                                  i_prog_id        =>  p_prog_id,
                                  i_prog_appl_id   =>  p_prog_app_id,
                                  o_err_num        =>  l_err_num,
                                  o_err_code       =>  l_err_code,
                                  o_err_msg        =>  l_err_msg);

        IF (l_err_num <> 0) THEN
           l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                              ||TO_CHAR(l_stmt_num)
                              ||'):'
                              ||l_err_msg,1,240);
            RAISE CST_PROCESS_ERROR;
        END IF;
       END IF;

       IF (p_cost_method <> 4) THEN
          l_stmt_num := 35;
          CSTPPWAC.update_cppb(i_pac_period_id   =>  p_pac_period_id,
                               i_cost_group_id   =>  p_cost_group_id,
                               i_txn_category    =>  6,          /* Rework Issues */
                               i_low_level_code  =>  p_low_level_code,
                               i_user_id         =>  p_user_id,
                               i_login_id        =>  p_login_id,
                               i_request_id      =>  p_request_id,
                               i_prog_id         =>  p_prog_id,
                               i_prog_appl_id    =>  p_prog_app_id,
                               o_err_num         =>  l_err_num,
                               o_err_code        =>  l_err_code,
                               o_err_msg         =>  l_err_msg);

          IF (l_err_num <> 0) THEN
             l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                   || TO_CHAR(l_stmt_num)
                                   ||'):'
                                   ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
       END IF;

       ----------------------------------------------------------------------
       -- Relieve each entity's scrap/scrap_return cost
       ----------------------------------------------------------------------

       l_stmt_num := 40;

       FOR c_ent_rec IN c_rework_entity_scrap LOOP

          l_co_txns_count := l_co_txns_count + 1;

          IF (CSTPPINV.l_item_id_tbl.COUNT >= G_MAX_RECORDS AND p_cost_method <> 4) THEN

            CSTPPWAC.insert_into_cppb(i_pac_period_id  =>  p_pac_period_id,
                                      i_cost_group_id  =>  p_cost_group_id,
                                      i_txn_category   =>  7,   /* Rework Completions */
                                      i_user_id        =>  p_user_id,
                                      i_login_id       =>  p_login_id,
                                      i_request_id     =>  p_request_id,
                                      i_prog_id        =>  p_prog_id,
                                      i_prog_appl_id   =>  p_prog_app_id,
                                      o_err_num        =>  l_err_num,
                                      o_err_code       =>  l_err_code,
                                      o_err_msg        =>  l_err_msg);
            IF (l_err_num <> 0) THEN
               l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                  ||TO_CHAR(l_stmt_num)
                                  ||'):'
                                  ||l_err_msg,1,240);
                RAISE CST_PROCESS_ERROR;
            END IF;
          END IF;

          l_stmt_num := 45;
          process_net_relief    (
                  p_pac_period_id              => p_pac_period_id,
                  p_prior_period_id            => p_prior_period_id,
                  p_cost_group_id              => p_cost_group_id,
                  p_cost_type_id               => p_cost_type_id,
                  p_legal_entity               => p_legal_entity,
                  p_cost_method                => p_cost_method,
                  p_cost_layer_id              => l_cost_layer_id,
                  p_qty_layer_id               => l_qty_layer_id,
                  p_pac_rates_id               => p_pac_rates_id,
                  p_entity_type                => c_ent_rec.entity_type,
                  p_org_id                     => c_ent_rec.org_id,
                  p_entity_id                  => c_ent_rec.entity_id,
                  p_line_id                    => c_ent_rec.line_id,
                  p_net_qty                    =>  c_ent_rec.net_scrap,
                  p_start_date                 => p_start_date,
                  p_end_date                   => p_end_date,
                  p_scrap                      => 1,
                  p_op_seq                     => c_ent_rec.op_seq,
                  p_final_completion_flag      => NULL,
                  p_material_relief_algorithm  => p_material_relief_algorithm,
                  p_master_org_id              => p_master_org_id,
                  p_uom_control                => p_uom_control,
                  p_user_id                    => p_user_id,
                  p_login_id                   => p_login_id,
                  p_request_id                 => p_request_id,
                  p_prog_id                    => p_prog_id,
                  p_prog_app_id                => p_prog_app_id,
                  p_txn_category               => 7, /* rework completions/scrap */
                  x_err_num                    => l_err_num,
                  x_err_code                   => l_err_code,
                  x_err_msg                    => l_err_msg);

           IF (l_err_num <> 0) THEN

                   l_err_msg := SUBSTR('scrap entity/line: '
                                   ||TO_CHAR(c_ent_rec.entity_id)
                                   ||'/'
                                   ||TO_CHAR(c_ent_rec.line_id)
                                   ||':'
                                   ||l_err_msg,1,240);
                   RAISE CST_PROCESS_ERROR;

           END IF;
        END LOOP; --c_rework_entity_scrap

       ----------------------------------------------------------------------
       -- Relieve each entity's completion/return cost
       ----------------------------------------------------------------------
        l_stmt_num := 50;

        FOR c_ent_rec IN c_rework_entity_complete LOOP

           l_co_txns_count := l_co_txns_count + 1;

           SELECT count(*)
           INTO   l_final_completion_count
           FROM   mtl_material_transactions mmt
           WHERE  mmt.transaction_source_id = c_ent_rec.entity_id
           AND    nvl(mmt.repetitive_line_id,-99) = nvl( c_ent_rec.line_id,-99)
           AND    mmt.final_completion_flag = 'Y'
           AND    mmt.transaction_date BETWEEN TRUNC(p_start_date)
                                         AND (TRUNC(p_end_date) + 0.99999)
           AND    ROWNUM < 2;

            IF (CSTPPINV.l_item_id_tbl.COUNT >= G_MAX_RECORDS AND p_cost_method <> 4) THEN
             CSTPPWAC.insert_into_cppb(i_pac_period_id  =>  p_pac_period_id,
                                       i_cost_group_id  =>  p_cost_group_id,
                                       i_txn_category   =>  7,   /* Rework completions */
                                       i_user_id        =>  p_user_id,
                                       i_login_id       =>  p_login_id,
                                       i_request_id     =>  p_request_id,
                                       i_prog_id        =>  p_prog_id,
                                       i_prog_appl_id   =>  p_prog_app_id,
                                       o_err_num        =>  l_err_num,
                                       o_err_code       =>  l_err_code,
                                       o_err_msg        =>  l_err_msg);

             IF (l_err_num <> 0) THEN
                l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'):'
                                   ||l_err_msg,1,240);
                 RAISE CST_PROCESS_ERROR;
             END IF;
            END IF;

           l_stmt_num := 55;
           process_net_relief   (
                   p_pac_period_id              => p_pac_period_id,
                   p_prior_period_id            => p_prior_period_id,
                   p_cost_group_id              => p_cost_group_id,
                   p_cost_type_id               => p_cost_type_id,
                   p_legal_entity               => p_legal_entity,
                   p_cost_method                => p_cost_method,
                   p_cost_layer_id              => l_cost_layer_id,
                   p_qty_layer_id               => l_qty_layer_id,
                   p_pac_rates_id               => p_pac_rates_id,
                   p_entity_type                => c_ent_rec.entity_type,
                   p_org_id                     => c_ent_rec.org_id,
                   p_entity_id                  => c_ent_rec.entity_id,
                   p_line_id                    => c_ent_rec.line_id,
                   p_net_qty                    => c_ent_rec.net_completion,
                   p_start_date                 => p_start_date,
                   p_end_date                   => p_end_date,
                   p_scrap                      => -1,
                   p_op_seq                     => NULL,
                   p_final_completion_flag      => l_final_completion_count,
                   p_material_relief_algorithm  => p_material_relief_algorithm,
                   p_master_org_id              => p_master_org_id,
                   p_uom_control                => p_uom_control,
                   p_user_id                    => p_user_id,
                   p_login_id                   => p_login_id,
                   p_request_id                 => p_request_id,
                   p_prog_id                    => p_prog_id,
                   p_prog_app_id                => p_prog_app_id,
                   p_txn_category               => 7, /* rework completions/scrap */
                   x_err_num                    => l_err_num,
                   x_err_code                   => l_err_code,
                   x_err_msg                    => l_err_msg);

           IF (l_err_num <>0) THEN

              l_err_msg := SUBSTR('cmpl entity/line: '
                              ||TO_CHAR(c_ent_rec.entity_id)
                              ||'/'
                              ||TO_CHAR(c_ent_rec.line_id)
                              ||':'
                              ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;

           END IF;

        END LOOP; --c_rework_entity_complete

        /* Insert into cppb */
        l_stmt_num := 60;
         IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND p_cost_method <> 4) THEN

          CSTPPWAC.insert_into_cppb(i_pac_period_id  =>  p_pac_period_id,
                                    i_cost_group_id  =>  p_cost_group_id,
                                    i_txn_category   =>  7,  /* Rework completions */
                                    i_user_id        =>  p_user_id,
                                    i_login_id       =>  p_login_id,
                                    i_request_id     =>  p_request_id,
                                    i_prog_id        =>  p_prog_id,
                                    i_prog_appl_id   =>  p_prog_app_id,
                                    o_err_num        =>  l_err_num,
                                    o_err_code       =>  l_err_code,
                                    o_err_msg        =>  l_err_msg);
          IF (l_err_num <> 0) THEN
             l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                ||TO_CHAR(l_stmt_num)
                                ||'):'
                                ||l_err_msg,1,240);
              RAISE CST_PROCESS_ERROR;
          END IF;
         END IF;

        /* Calculate Periodic Cost if cost method is not ILIFO and there
           have is atleast one cost owned transaction for rework assemblies */

         IF (p_cost_method <> 4 AND l_co_txns_count > 0) THEN
             l_stmt_num := 65;
             CSTPPWAC.calculate_periodic_cost(i_pac_period_id   =>  p_pac_period_id,
                                              i_cost_group_id   =>  p_cost_group_id,
                                              i_cost_type_id    =>  p_cost_type_id,
                                              i_low_level_code  =>  p_low_level_code,
                                              i_item_id         =>  NULL, /* Used only by PACP */
                                              i_user_id         =>  p_user_id,
                                              i_login_id        =>  p_login_id,
                                              i_request_id      =>  p_request_id,
                                              i_prog_id         =>  p_prog_id,
                                              i_prog_appl_id    =>  p_prog_app_id,
                                              o_err_num         =>  l_err_num,
                                              o_err_code        =>  l_err_code,
                                              o_err_msg         =>  l_err_msg);

             IF (l_err_num <> 0) THEN
                l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'):'
                                   ||l_err_msg,1,240);
                 RAISE CST_PROCESS_ERROR;
             END IF;

             /* Update cppb */
             l_stmt_num := 70;
             CSTPPWAC.update_cppb(i_pac_period_id   =>  p_pac_period_id,
                                  i_cost_group_id   =>  p_cost_group_id,
                                  i_txn_category    =>  7,       /* Rework Completions */
                                  i_low_level_code  =>  p_low_level_code,
                                  i_user_id         =>  p_user_id,
                                  i_login_id        =>  p_login_id,
                                  i_request_id      =>  p_request_id,
                                  i_prog_id         =>  p_prog_id,
                                  i_prog_appl_id    =>  p_prog_app_id,
                                  o_err_num         =>  l_err_num,
                                  o_err_code        =>  l_err_code,
                                  o_err_msg         =>  l_err_msg);

             IF (l_err_num <> 0) THEN
                l_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                                   ||TO_CHAR(l_stmt_num)
                                   ||'):'
                                   ||l_err_msg,1,240);
                 RAISE CST_PROCESS_ERROR;
             END IF;
          END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

       WHEN CST_PROCESS_ERROR THEN
               IF (l_exceptionLog) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                                  l_module || '.' || l_stmt_num,
                                  l_err_msg);
               END IF;
               x_err_num := l_err_num;
               x_err_code := l_err_code;
               x_err_msg := SUBSTR(l_err_msg,1,240);

       WHEN OTHERS THEN
               IF (l_uLog) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                  l_module || '.' || l_stmt_num,
                                  SQLERRM);
               END IF;
               ROLLBACK;
               x_err_num := SQLCODE;
               x_err_code := NULL;
               x_err_msg := SUBSTR('CSTPPWAS.process_reworkassembly_txns('
                               || to_char(l_stmt_num)
                               || '): '
                               ||SQLERRM,1,240);
END process_reworkassembly_txns;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                  |
|       check_expense_flags                                                  |
|   utility procedure to return item and expense flags               |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE check_expense_flags(
       p_item_id                IN      NUMBER,
       p_subinv                 IN      VARCHAR2,
       p_org_id                 IN      NUMBER,
       x_exp_item               OUT NOCOPY      NUMBER,
       x_exp_flag               OUT NOCOPY      NUMBER,
       x_err_num                OUT NOCOPY      NUMBER,
       x_err_code               OUT NOCOPY      VARCHAR2,
       x_err_msg                OUT NOCOPY      VARCHAR2)
IS

l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_exp_item                      NUMBER;
l_exp_flag                      NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'check_expense_flags';
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
                        l_api_name || ' <<< Parameters:
                        p_item_id = ' || p_item_id );

       END IF;
       ----------------------------------------------------------------------
       -- Initialize Variables
       ----------------------------------------------------------------------

       l_err_num        := 0;
       l_err_code       := '';
       l_err_msg        := '';
       l_exp_item       := 0;
       l_exp_flag       := 0;

       ----------------------------------------------------------------------
       -- Check Item flag
       ----------------------------------------------------------------------

       l_stmt_num := 5;

       SELECT  decode(inventory_asset_flag,'Y',0,1)
       INTO    l_exp_item
       FROM    mtl_system_items msi
       WHERE   inventory_item_id = p_item_id
       AND     organization_id = p_org_id;

       ----------------------------------------------------------------------
       -- Check Item flag
       ----------------------------------------------------------------------

       l_stmt_num := 10;

       IF (p_subinv IS NULL) THEN
               l_exp_flag := l_exp_item;
       ELSE
               SELECT  decode(l_exp_item,1,1,decode(asset_inventory,1,0,1))
               INTO    l_exp_flag
               FROM    mtl_secondary_inventories msi
               WHERE   secondary_inventory_name = p_subinv
               AND     organization_id = p_org_id;
       END IF;

       l_stmt_num := 15;

       x_exp_item := l_exp_item;
       x_exp_flag := l_exp_flag;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

EXCEPTION

       WHEN OTHERS THEN
               IF (l_uLog) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                  l_module || '.' || l_stmt_num,
                                  SQLERRM);
               END IF;
               ROLLBACK;
               x_err_num := SQLCODE;
               x_err_code := NULL;
               x_err_msg := SUBSTR('CSTPPWAS.check_expense_flags('
                               || to_char(l_stmt_num)
                               || '): '
                               ||SQLERRM,1,240);

END check_expense_flags;

END cstppwas;

/
