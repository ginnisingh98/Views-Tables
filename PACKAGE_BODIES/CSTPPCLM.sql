--------------------------------------------------------
--  DDL for Package Body CSTPPCLM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPCLM" AS
/* $Header: CSTPCLMB.pls 120.3.12010000.2 2008/08/08 12:31:36 smsasidh ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPCLM';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*------------------------------------------------------------------
 | PROCEDURE layer_id
 |
 | Obtain quantity layer id and cost layer id if already exists
 | Otherwise they are 0.
 ------------------------------------------------------------------*/
PROCEDURE layer_id (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  o_cost_layer_id           OUT NOCOPY NUMBER,
  o_quantity_layer_id       OUT NOCOPY NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
  l_cpiql_cnt		    NUMBER;
  l_cpic_cnt		    NUMBER;
  retval                    NUMBER;
  layer_errors		    EXCEPTION;
  l_stmt_num                NUMBER;
  l_cpic_cost_layer_id      NUMBER;
  l_cpql_quantity_layer_id  NUMBER;
  l_cpql_count              NUMBER;

  l_api_name                CONSTANT VARCHAR2(30) := 'layer_id';
  l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
  l_module                  CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

  l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
  l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

 -- Cursor to get cost_layer_id from CPIC
 -- This is to check the existence of atleast one record
 CURSOR c_cpic_cost_layer IS
   SELECT cost_layer_id
     FROM cst_pac_item_costs
    WHERE pac_period_id     = i_pac_period_id
      AND inventory_item_id = i_item_id
      AND cost_group_id     = i_cost_group_id;

 -- Cursor to get cost_layer_id from CPQL
 -- This is to check the existence of atleast one record
--  and to get maximum quantity_layer_id
-- included count condition
 CURSOR c_cpql_quantity_layer IS
   SELECT COUNT(quantity_layer_id), MAX(quantity_layer_id)
     FROM cst_pac_quantity_layers
    WHERE pac_period_id     = i_pac_period_id
      AND inventory_item_id = i_item_id
      AND cost_group_id     = i_cost_group_id
   GROUP BY quantity_layer_id;

BEGIN

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.begin',
                   l_api_name || ' <<< Parameters: ' ||
                   ' i_pac_period_id: ' || i_pac_period_id ||
                   ' i_legal_entity: ' || i_legal_entity ||
                   ' i_item_id: ' || i_item_id ||
                   ' i_cost_group_id: ' || i_cost_group_id);
  END IF;

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';



  l_stmt_num := 10;
  -- Get cost_layer_id from CPIC
  OPEN c_cpic_cost_layer;
  FETCH c_cpic_cost_layer
   INTO l_cpic_cost_layer_id;

  IF c_cpic_cost_layer%FOUND THEN
    l_cpic_cnt := 1;
  ELSE
    l_cpic_cnt := 0;
  END IF;

  CLOSE c_cpic_cost_layer;

  l_stmt_num := 20;
  -- Get cost_layer_id from CPQL
  OPEN c_cpql_quantity_layer;
  FETCH c_cpql_quantity_layer
   INTO l_cpql_count, l_cpql_quantity_layer_id;

  IF l_cpql_count > 0 THEN
    l_cpiql_cnt := 1;
  ELSE
    l_cpiql_cnt := 0;
  END IF;

  CLOSE c_cpql_quantity_layer;


/*------------------------------------------------------------------
 | Raise layer errors if :
 | - Nothing in item cost table , and row exists in quantity layer table
 | - Row exists in item cost table, and nothing in quantity layer table
 ------------------------------------------------------------------*/
  IF ( (l_cpic_cnt = 0 AND l_cpiql_cnt > 0) OR
       (l_cpic_cnt > 0 AND l_cpiql_cnt = 0) ) THEN
    raise layer_errors;
  END IF;

  IF (l_cpic_cnt = 0 AND l_cpiql_cnt = 0) THEN
    l_stmt_num := 30;
    o_cost_layer_id := 0;
    o_quantity_layer_id := 0;
  ELSE
    l_stmt_num := 40;
    o_cost_layer_id := l_cpic_cost_layer_id;

    o_quantity_layer_id := l_cpql_quantity_layer_id;

  END IF;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>> Out Parameters: ' ||
                   ' o_cost_layer_id: ' || o_cost_layer_id ||
                   ' o_quantity_layer_id: ' || o_quantity_layer_id);
  END IF;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
    o_cost_layer_id := 0;
    o_quantity_layer_id := 0;

  WHEN layer_errors THEN
    o_cost_layer_id := 0;
    o_quantity_layer_id := 0;
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCLM.LAYER_ID: layers inconsistency';
    IF (l_exceptionLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                       l_module || '.' || l_stmt_num,
                       o_err_msg);
    END IF;
  WHEN others THEN
    IF (l_uLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                       l_module || '.' || l_stmt_num,
                       SQLERRM);
    END IF;
    o_cost_layer_id := 0;
    o_quantity_layer_id := 0;
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCLM.LAYER_ID:' || substrb(SQLERRM,1,150);

END layer_id;

PROCEDURE create_layer (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_cost_layer_id           OUT NOCOPY NUMBER,
  o_quantity_layer_id       OUT NOCOPY NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
  l_cost_layer_id           NUMBER;
  l_quantity_layer_id	    NUMBER;
  l_stmt_num                NUMBER;

  l_api_name                CONSTANT VARCHAR2(30) := 'create_layer';
  l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
  l_module                  CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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
  END IF;

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  /*
  ** check for existing layer
  */
  l_stmt_num := 10;
  CSTPPCLM.layer_id(i_pac_period_id, i_legal_entity, i_item_id,
                    i_cost_group_id, l_cost_layer_id, l_quantity_layer_id,
                    o_err_num, o_err_code, o_err_msg);

  IF ( l_cost_layer_id = 0) THEN
    l_stmt_num := 20;
    /*
    ** if the cost_layer_id is 0, then the layer doesn't exist, so we
    ** should create it in cst_pac_item_costs and cst_pac_quantity_layers
    */
    SELECT cst_pac_item_costs_s.nextval
    INTO l_cost_layer_id
    FROM dual;

    l_stmt_num := 30;
    SELECT bom.cst_pac_quantity_layers_s.nextval
    INTO l_quantity_layer_id
    FROM dual;

    l_stmt_num := 40;
    INSERT INTO cst_pac_item_costs (
      cost_layer_id,
      pac_period_id,
      inventory_item_id,
      cost_group_id,
      total_layer_quantity,
      buy_quantity,
      make_quantity,
      issue_quantity,
      item_cost,
      item_buy_cost,
      item_make_cost,
      begin_item_cost,
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
      program_id,
      program_application_id,
      program_update_date,
      last_update_login
      )
    VALUES (
      l_cost_layer_id,
      i_pac_period_id,
      i_item_id,
      i_cost_group_id,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      SYSDATE,
      i_login_id
    );

    l_stmt_num := 50;
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
      program_id,
      program_application_id,
      program_update_date,
      last_update_login
    )
    VALUES (
      l_cost_layer_id,
      1,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      SYSDATE,
      i_login_id

    );

    l_stmt_num := 60;
    INSERT INTO cst_pac_quantity_layers (
      quantity_layer_id,
      cost_layer_id,
      pac_period_id,
      inventory_item_id,
      cost_group_id,
      layer_quantity,
      begin_layer_quantity,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      last_update_login
      )
    VALUES (
      l_quantity_layer_id,
      l_cost_layer_id,
      i_pac_period_id,
      i_item_id,
      i_cost_group_id,
      0,
      0,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      SYSDATE,
      i_login_id
    );

  l_stmt_num := 70;
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
          i_item_id,
          l_cost_layer_id,
          l_quantity_layer_id,
          1,              -- cost element
          1,              -- level type
          1,              -- txn_category (Period Beginning)
          0,              -- txn_category_qty
          0,              -- txn_category_value
          0,              -- period_quantity
          0,              -- periodic_cost
          0,              -- period_balance
          0,              -- variance
          sysdate,
          i_user_id,
          i_login_id,
          i_user_id,
          sysdate,
          i_request_id,
          i_prog_appl_id,
          i_prog_id,
          sysdate
   from   dual
   -- Insert balance records in CPPB only for asset items. Check asset flag for
   -- the item in the item master organization
   where  exists (select 1
                  from   mtl_system_items msi, cst_cost_groups ccg
                  where  msi.inventory_item_id = i_item_id
                  and    msi.inventory_asset_flag = 'Y'
                  and    msi.organization_id = ccg.organization_id
                  and    ccg.cost_group_id = i_cost_group_id));

  END IF;

  o_cost_layer_id := l_cost_layer_id;
  o_quantity_layer_id := l_quantity_layer_id;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>> Out Parameters: ' ||
                   ' o_cost_layer_id: ' || o_cost_layer_id ||
                   ' o_quantity_layer_id: ' || o_quantity_layer_id);
  END IF;

EXCEPTION

  WHEN others THEN
    IF (l_uLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                       l_module || '.' || l_stmt_num,
                       SQLERRM);
    END IF;
    o_cost_layer_id := 0;
    o_quantity_layer_id := 0;
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCLM.CREATE_LAYER:' || substrb(SQLERRM,1,150);

END create_layer;

END CSTPPCLM;

/
