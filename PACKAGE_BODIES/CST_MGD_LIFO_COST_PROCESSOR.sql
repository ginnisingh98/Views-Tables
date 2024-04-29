--------------------------------------------------------
--  DDL for Package Body CST_MGD_LIFO_COST_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_LIFO_COST_PROCESSOR" AS
--$Header: CSTGLCPB.pls 120.2 2006/05/26 08:00:52 vmutyala noship $
--/*==========================================================================+
--|   Copyright (c) 2001 Oracle Corporation Belmont, California, USA          |
--|                          All rights reserved.                             |
--+===========================================================================+
--|                                                                           |
--| File Name   : CSTGLCPB.pls                                                |
--| Description	: Incremental Lifo Cost Processor                             |
--|                                                                           |
--| Revision                                                                  |
--|  1/29/99      DHerring   Created                                          |
--|  2/1/99       DHerring   Compiled                                         |
--|  2/3/99       DHerring   Tested                                           |
--|  2/5/99       DHerring   Re-Formatted to meet MGD standards               |
--|  2/23/99      DHerring   further modification to meet standards           |
--|                          and modification to lifo calculation             |
--|  3/4/99       DHerring   incorporated feedback from review                |
--|  3/5/99       DHerring   added correct exception handling                 |
--|  6/16/99      DHerring   added extra logic to support change in           |
--|                          requirement for market value                     |
--|  7/09/99      DHerring   Extra procedures added to use temp table         |
--|                          and simplify incremental lifo report             |
--|  1/29/01	  AFerrara   Added procedure get_pac_id             	      |
--|  			     Added procedure check_quantity	   	      |
--| 04/13/2001    Vjavli     Created procedure lifo_purge for the             |
--|                          purge functionality                              |
--| 04/13/2001    Vjavli     Created procedure selective_purge as part        |
--|                          of purge functionality.  This procedure will be  |
--|                          invoked by lifo_purge                            |
--| 04/16/2001    Vjavli     Created log and log initialize procedures        |
--| 04/23/2001    vjavli     updated with commit size logic                   |
--| 04/26/2001    vjavli     removed commit size logic as per the meeting     |
--| 05/09/2001    vjavli     modified master org cursor in the lifo purge     |
--| 05/16/2001    vjavli     selective purge modified to purge the records    |
--|                          upto entered period                              |
--| 07/25/2001    vjavli     recalculate total quantity and delta for the open|
--|                          period layer in the populate_layers procedure    |
--|                          This is to fix the bug# 1785079                  |
--| 08/10/2001    vjavli     Recalculate only for the open period             |
--|                          fix to bug#1929915                               |
--| 08/20/2001    vjavli     to fix first_period issue for the begin qty <=0  |
--|                          Selective_LIFO_Purge modified                    |
--| 11/19/2002    tsimmond   UTF8 :l_master_org_name changed to VARCHAR2(240) |
--| 12/04/2002    fdubois    adding NOCOPY for OUT parameters                 |
--| 04/06/2005    vjavli     XLE Uptake:pop_detail_data INSERT stmts modified |
--| 04/06/2005    vjavli     XLE Uptake:pop_summary_data INSERT stmts modified|
--| 01/08/2006    vjavli     FP:11i8-12.0 Bug 4028737 fix: Base bug 3775498   |
--|                          find_first_period : begin_layer_quantity <= 0 is |
--|                          compared to identify the first period            |
--| 05/24/2006    vmutyala   Replaced ORG_ORGANIZATION_DEFINITIONS to avoid   |
--|                          performance issue and added the join condition on|
--|                          cost_layer_id between pic and pql in all insert  |
--|                          into cstgilev_temp statements. Bug 5239725       |
--+==========================================================================*/

--=================
-- TYPES
--=================

TYPE period_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--=================
-- CONSTANTS
--=================

G_CST_MGD_LIFO_COST_PROCESSOR VARCHAR2(30) := 'CST_MGD_LIFO_COST_PROCESSOR';

--==================
-- GLOBAL VARIABLES
--==================

g_period_tab period_tbl_type;
g_current_period_index BINARY_INTEGER := 0;
g_old_cost_group_id NUMBER := 0;
g_empty_period_tab period_tbl_type;

--====================
-- Debug log variables
--====================

g_log_level     NUMBER      := NULL;  -- 0 for manual test
g_log_mode      VARCHAR2(3) := 'OFF'; -- possible values: OFF, SQL, SRS

--=========================================================================
-- PROCEDURE  : find_first_period              PRIVATE
-- PARAMETERS : p_pac_period_id                period id
--            : p_item_id                      inventory item id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
-- COMMENT    : Find the first period to calculate incremental lifo
--              from. This is either the first period recorded or
--              the period with a preceeding total quantity of 0.
--              The procedure loops back through previous periods
--              until it find the first period to calculate from
--              and assigns this period id to a global variable.
-- PRE-COND   : The procedure is fed the correct period id and item id.
--              The period ids can be sorted in chonological order.
--              The total quantity layer column can be accessed.
--=========================================================================
PROCEDURE find_first_period
( p_pac_period_id  IN  NUMBER
, p_item_id        IN  NUMBER
, p_cost_group_id  IN  NUMBER
, p_cost_type_id   IN  NUMBER
)
IS

--================
-- CURSORS
--================

CURSOR period_cur IS
  SELECT
    cst_pac_periods.pac_period_id
  FROM
    cst_pac_periods,
    cst_pac_item_costs
  WHERE cst_pac_periods.pac_period_id = cst_pac_item_costs.pac_period_id
    AND cst_pac_item_costs.inventory_item_id = p_item_id
    AND cst_pac_item_costs.cost_group_id = p_cost_group_id
    AND cst_pac_periods.cost_type_id = p_cost_type_id
  ORDER BY cst_pac_periods.period_year, cst_pac_periods.period_num;



--=================
-- LOCAL VARIABLES
--=================

l_begin_quantity   NUMBER;
l_market_value     NUMBER;
l_current_period   NUMBER;

BEGIN

  -- Initialize Local Variables

  l_begin_quantity := 0;


  -- clear the pl/sql table before use
  g_period_tab := g_empty_period_tab;

  -- open cursor

  IF NOT period_cur%ISOPEN
  THEN
  OPEN period_cur;
  END IF;

  FETCH period_cur INTO g_period_tab(g_period_tab.COUNT+1);

  WHILE period_cur%FOUND
  LOOP

    FETCH period_cur INTO g_period_tab(g_period_tab.COUNT+1);

  END LOOP;

  CLOSE period_cur;

  -- Initialize on the current period p_pac_period_id

  g_current_period_index := g_period_tab.FIRST;

  WHILE g_period_tab(g_current_period_index) <> p_pac_period_id
  LOOP

   g_current_period_index := g_period_tab.NEXT(g_current_period_index);

  END LOOP;

  l_current_period := g_period_tab(g_current_period_index);

  -- The sequence of the plsql table gperiod_tab is correct because the
  -- cursor period_cur is ordered by period year then period num
  -- FP:11i8-12.0: Bug 4028737 fix

  LOOP

    SELECT
      cpql.begin_layer_quantity
     ,cpic.market_value
    INTO
      l_begin_quantity
     ,l_market_value
    FROM
      cst_pac_item_costs cpic
    , cst_pac_quantity_layers cpql
    WHERE cpic.pac_period_id = l_current_period
      AND cpic.inventory_item_id = p_item_id
      AND cpic.cost_group_id = p_cost_group_id
      AND cpic.cost_layer_id = cpql.cost_layer_id;


    -- Stop retrograding through previous periods if
    -- you reach the first period
    -- or the begin quantity is <= 0
    -- or a market value was entered for the period
    -- FP:11i8-12.0: Bug 4028737 fix

    EXIT WHEN g_current_period_index = g_period_tab.FIRST
         OR l_begin_quantity <= 0
         OR l_market_value IS NOT NULL;

    g_current_period_index := g_period_tab.PRIOR(g_current_period_index);
    l_current_period := g_period_tab(g_current_period_index);

  END LOOP;

  g_old_cost_group_id := p_cost_group_id;



EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'find_first_period'
                             );
    END IF;
    RAISE;
END find_first_period;

--=========================================================================
-- PROCEDURE  : populate_layers                PRIVATE
-- PARAMETERS : p_pac_period_id                period id
--            : p_item_id                      inventory item id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_user_id                      user id
--            : p_login_id                     login id
--            : p_req_id                       requisition id
--            : p_prg_id                       prg id
--            : p_prg_appl_id                  prg appl id
-- COMMENT    : This procedure finds the delta balance
--            : between periods and records it in
--            : cst_pac_quantity_layers for each
--            : period.
--            : This is neccessary for the lifo calcualtion
--            : the delta quantity may be a negative number.
-- PRE-COND   : Calacualte the delta inventory per item per period
--            : and populate CST_PAC_QUANTITY_LAYER.LAYER_QUANTITY
--            : with that value.
-- UPDATED BY : Veeresha Javli
--              Recalculated total quantity and delta for the open period
--              layer
--              Perform recalculation only for open period
--=========================================================================
PROCEDURE populate_layers
( p_pac_period_id  IN  NUMBER
, p_item_id        IN  NUMBER
, p_cost_group_id  IN  NUMBER
, p_cost_type_id   IN  NUMBER
, p_user_id        IN  NUMBER
, p_login_id       IN  NUMBER
, p_req_id         IN  NUMBER
, p_prg_id         IN  NUMBER
, p_prg_appl_id    IN  NUMBER
)
IS

--==============
-- CURSORS
--==============

-- Cursor to get issue qty, make qty and buy qty
CURSOR get_quantity_cur(c_period_id NUMBER
                       ,c_cost_group_id NUMBER
                       ,c_inventory_item_id NUMBER) IS
  SELECT
    nvl(buy_quantity,0)
   ,nvl(make_quantity,0)
   ,nvl(issue_quantity,0)
   ,market_value
  FROM
    cst_pac_item_costs
  WHERE pac_period_id = c_period_id
    AND cost_group_id = c_cost_group_id
    AND inventory_item_id = c_inventory_item_id;

CURSOR get_period_status_cur(c_period_id NUMBER) IS
  SELECT open_flag
   FROM  CST_PAC_PERIODS
  WHERE  pac_period_id = c_period_id;


--=================
-- LOCAL VARIABLES
--=================

l_current_total        NUMBER;
l_previous_total       NUMBER;
l_delta_period         NUMBER;
l_delta_period_index   BINARY_INTEGER;
l_delta_quantity       NUMBER;
l_market_value         NUMBER;
l_buy_quantity         NUMBER;
l_make_quantity        NUMBER;
l_issue_quantity       NUMBER;
l_open_flag            VARCHAR2(1);

BEGIN

  -- initialise local variables

  l_delta_period_index := g_current_period_index;
  l_delta_period := g_period_tab(l_delta_period_index);
  l_delta_quantity := 0;
  l_current_total := 0;
  l_previous_total := 0;

  LOOP

    SELECT
      total_layer_quantity
    , market_value
    INTO
      l_current_total
    , l_market_value
    FROM
      cst_pac_item_costs
    WHERE pac_period_id = l_delta_period
      AND inventory_item_id = p_item_id
      AND cost_group_id = p_cost_group_id;

    -- If a market value was entered then the delta is the total quantity

    IF
      l_market_value IS NULL
    THEN
      l_delta_quantity := l_current_total - l_previous_total;
    ELSE
      l_delta_quantity := l_current_total;
    END IF;

    UPDATE cst_pac_quantity_layers
    SET
      last_updated_by = p_user_id
    , last_update_date = sysdate
    , last_update_login = p_login_id
    , request_id = p_req_id
    , program_application_id = p_prg_appl_id
    , program_id = p_prg_id
    , program_update_date = sysdate
    , layer_quantity = l_delta_quantity
    WHERE pac_period_id = l_delta_period
      AND inventory_item_id = p_item_id
      AND cost_group_id = p_cost_group_id;

    EXIT WHEN l_delta_period_index = g_period_tab.LAST;

    l_delta_period_index := g_period_tab.NEXT(l_delta_period_index);
    l_delta_period := g_period_tab(l_delta_period_index);

    l_previous_total := l_current_total;


  END LOOP;

  -- Recalculate total quantity and delta for the open period layer

  -- get the status of the last period
  OPEN get_period_status_cur(l_delta_period);

  FETCH get_period_status_cur
   INTO l_open_flag;

  CLOSE get_period_status_cur;

  -- Check whether period is open
  IF (l_open_flag = 'Y') THEN
    -- get the quantities
    OPEN get_quantity_cur(l_delta_period
                         ,p_cost_group_id
                         ,p_item_id );

    FETCH get_quantity_cur
     INTO l_buy_quantity
         ,l_make_quantity
         ,l_issue_quantity
         ,l_market_value;

    CLOSE get_quantity_cur;

      l_current_total := l_previous_total + l_buy_quantity + l_make_quantity - l_issue_quantity;

        UPDATE cst_pac_item_costs
        SET
          last_updated_by        = p_user_id
         ,last_update_date       = sysdate
         ,last_update_login      = p_login_id
         ,request_id             = p_req_id
         ,program_application_id = p_prg_appl_id
         ,program_id             = p_prg_id
         ,program_update_date    = sysdate
         ,total_layer_quantity   = l_current_total
        WHERE pac_period_id         = l_delta_period
          AND inventory_item_id     = p_item_id
          AND cost_group_id         = p_cost_group_id;


      IF
        l_market_value IS NULL
      THEN
        l_delta_quantity := l_current_total - l_previous_total;
      ELSE
        l_delta_quantity := l_current_total;
      END IF;


      UPDATE cst_pac_quantity_layers
      SET
        last_updated_by        = p_user_id
      , last_update_date       = sysdate
      , last_update_login      = p_login_id
      , request_id             = p_req_id
      , program_application_id = p_prg_appl_id
      , program_id             = p_prg_id
      , program_update_date    = sysdate
      , layer_quantity         = l_delta_quantity
      WHERE pac_period_id     = l_delta_period
        AND inventory_item_id = p_item_id
        AND cost_group_id     = p_cost_group_id;

  END IF; -- open flag

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'populate_layers'
                             );
    END IF;
    RAISE;
END populate_layers;

--=========================================================================
-- PROCEDURE  : calc_lifo_cost                 PRIVATE
-- PARAMETERS : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_user_id                      user id
-- COMMENT    : Calculate the Incremental LIFO item cost and populate
--              CST_PAC_ITEM_COSTS.ITEM_COST with that value.
-- PRE-COND   : The delta quantity can be pulled for CST_PAC_QUANTITY_LAYERS.
--              The weighted average cost per item per period can be easily
--              calculated
--=========================================================================
PROCEDURE calc_lifo_cost
( p_pac_period_id  IN  NUMBER
, p_item_id        IN  NUMBER
, p_cost_group_id  IN  NUMBER
, p_cost_type_id   IN  NUMBER
, p_user_id        IN  NUMBER
)
IS

--================
-- TYPES
--================

TYPE l_inventory_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--=================
-- LOCAL VARIABLES
--=================

l_process_error          EXCEPTION;
l_wac_cost               NUMBER;
l_quantity_layers        NUMBER;
l_total_quantity         NUMBER;
l_lifo_cost              NUMBER;
l_inventory_value        NUMBER;
l_x_quant                NUMBER;
l_y_quant                NUMBER;
l_current_period         NUMBER;
l_delta_period_index     BINARY_INTEGER;
l_delta_period           NUMBER;
l_market_value           NUMBER;
j_market_value           NUMBER;
l_justification          VARCHAR2(240);
l_rowid                  ROWID;
l_rowid_char             VARCHAR2(24);
l_inventory_tab          l_inventory_tbl_type;
l_empty_inventory_tab    l_inventory_tbl_type;


buy_quantity             NUMBER;
item_buy_cost            NUMBER;
make_quantity            NUMBER;
item_make_cost           NUMBER;
inventory_item_id        NUMBER;
wac_cost                 NUMBER;


-- Now calculate the LIFO cost and populate item_cost
-- in cst_mgd_lifo_item_costs

BEGIN

  -- initialise local variables

  l_wac_cost := 0;
  l_quantity_layers := 0;
  l_total_quantity := 0;
  l_lifo_cost := 0;
  l_inventory_value := 0;
  l_x_quant := 0;
  l_y_quant := 0;
  l_current_period := g_period_tab(g_current_period_index);
  l_delta_period_index := g_current_period_index;
  l_delta_period := l_current_period;

  -- initialize the PL/SQL table

  l_inventory_tab(0) := 0;

  FOR l_inventory_index IN g_period_tab.FIRST .. g_period_tab.LAST
  LOOP
  l_inventory_tab(l_inventory_index) := 0;
  END LOOP;

  LOOP

    SELECT
      cpic.buy_quantity
    , cpic.item_buy_cost
    , cpic.make_quantity
    , cpic.item_make_cost
    , cpic.inventory_item_id
    , cpic.market_value
    INTO
      buy_quantity
    , item_buy_cost
    , make_quantity
    , item_make_cost
    , inventory_item_id
    , l_market_value
    FROM
      cst_pac_item_costs cpic
      WHERE cpic.pac_period_id = l_current_period
      AND cpic.inventory_item_id = p_item_id
      AND cpic.cost_group_id = p_cost_group_id;

    -- If a market value was entered the use that in place of weighted average

    IF
      l_market_value IS NOT NULL
    THEN
      SELECT
          cpql.layer_quantity
        , l_market_value
      INTO
          l_quantity_layers
        , l_wac_cost
      FROM
          cst_pac_item_costs cpic, cst_pac_quantity_layers cpql
      WHERE cpic.pac_period_id = cpql.pac_period_id
        AND cpic.cost_group_id = cpql.cost_group_id
        AND cpic.inventory_item_id = cpql.inventory_item_id
        AND cpic.pac_period_id = l_current_period
        AND cpic.inventory_item_id = p_item_id
        AND cpic.cost_group_id = p_cost_group_id;
    ELSE
      SELECT
          cpql.layer_quantity
        , DECODE((cpic.buy_quantity + cpic.make_quantity)
              , 0, 0
              , (cpic.buy_quantity * cpic.item_buy_cost +
                 cpic.make_quantity * cpic.item_make_cost)/
                (cpic.buy_quantity + cpic.make_quantity)
              )
      INTO
          l_quantity_layers
        , l_wac_cost
      FROM
          cst_pac_item_costs cpic, cst_pac_quantity_layers cpql
      WHERE cpic.pac_period_id = cpql.pac_period_id
        AND cpic.cost_group_id = cpql.cost_group_id
        AND cpic.inventory_item_id = cpql.inventory_item_id
        AND cpic.pac_period_id = l_current_period
        AND cpic.inventory_item_id = p_item_id
        AND cpic.cost_group_id = p_cost_group_id;
    END IF;

    -- finds the delta quantity for the period being calculated for
    -- The delta has been previously calculated and populated in
    -- cst_pac_quantity_layers

      l_x_quant := l_quantity_layers;

    -- if there is a negative delta quantity. Work out
    -- which year the inventory for this item
    -- should be removed from with the following
    -- while loop

    l_delta_period_index := g_current_period_index;

    WHILE l_x_quant < 0 AND l_delta_period_index <> g_period_tab.FIRST
    LOOP

      l_delta_period_index := g_period_tab.PRIOR(l_delta_period_index);
      l_delta_period := g_period_tab(l_delta_period_index);

      SELECT
        cpql.layer_quantity
        , DECODE((cpic.buy_quantity + cpic.make_quantity)
             , 0, 0
             , (cpic.buy_quantity * cpic.item_buy_cost +
                cpic.make_quantity * cpic.item_make_cost)/
               (cpic.buy_quantity + cpic.make_quantity))
             , cpic.market_value
        INTO
        l_y_quant
      , l_wac_cost
      , j_market_value
      FROM cst_pac_item_costs cpic, cst_pac_quantity_layers cpql
      WHERE cpic.pac_period_id = cpql.pac_period_id
        AND cpic.cost_group_id = cpql.cost_group_id
        AND cpic.inventory_item_id = cpql.inventory_item_id
        AND cpic.pac_period_id = l_delta_period
        AND cpic.inventory_item_id = p_item_id
        AND cpic.cost_group_id = p_cost_group_id;

      IF j_market_value IS NOT NULL THEN
        l_wac_cost := j_market_value;
        j_market_value := NULL;
      END IF;

      l_x_quant := l_x_quant + l_y_quant;

    END LOOP;

    l_inventory_tab(g_current_period_index) :=
    l_inventory_tab(l_delta_period_index - 1)
    + l_x_quant * l_wac_cost;

    -- Using current period parameter p_pac_period_id
    -- as the premise to exit, instead of
    -- gperiod_tab.LAST allows more flexibility
    -- You can calculate the lifo unit cost for
    -- earlier periods

    EXIT WHEN g_period_tab(g_current_period_index) = p_pac_period_id;

    g_current_period_index := g_period_tab.NEXT(g_current_period_index);
    l_current_period := g_period_tab(g_current_period_index);

  END LOOP;

  SELECT
    total_layer_quantity
    INTO
    l_total_quantity
  FROM cst_pac_item_costs
  WHERE pac_period_id = l_current_period
    AND inventory_item_id = p_item_id
    AND cost_group_id = p_cost_group_id;

  IF l_total_quantity <= 0
  THEN
    l_lifo_cost := 0;
  ELSE
    l_lifo_cost := l_inventory_tab(g_current_period_index)/l_total_quantity;
  END IF;

  SELECT rowid
        ,market_value
        ,justification
  INTO l_rowid
      ,l_market_value
      ,l_justification
  FROM cst_pac_item_costs
  WHERE pac_period_id = l_current_period
    AND inventory_item_id = p_item_id
    AND cost_group_id = p_cost_group_id;

  l_rowid_char := ROWIDTOCHAR(l_rowid);

  --  Call the table handler to update item cost

  CST_PAC_ITEM_COSTS_PKG.update_row( l_rowid_char
                                   , l_lifo_cost
                                   , l_market_value
                                   , l_justification
                                   , sysdate
                                   , p_user_id
                                   );

  -- clean PL/SQL table of previous calculations

  l_inventory_tab := l_empty_inventory_tab;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'calc_lifo_cost'
                             );
    END IF;
    RAISE;
END calc_lifo_cost;

--=========================================================================
-- PROCEDURE  : lifo_cost_processor            PUBLIC
-- PARAMETERS : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_user_id                      user id
--            : p_login_id                     login id
--            : p_req_id                       requisition id
--            : p_prg_id                       prg id
--            : p_prg_appl_id                  prg appl id
--            : x_retcode                      0 success, 1 warning, 2 error
--            : x_errbuff                      error buffer
-- COMMENT    : Gateway procedure to the three procedures that calcualate
--              incremental LIFO. Called from the pac worker after
--              transactional processing and loops through all inventory
--              items for a particular period.
-- PRE-COND   : The weighted average cost recorded in CST_PAC_ITEM_COSTS
--              for the period must be solely for items bought or made in
--              that period.
--=========================================================================
PROCEDURE lifo_cost_processor
( p_pac_period_id  IN  NUMBER
, p_cost_group_id  IN  NUMBER
, p_cost_type_id   IN  NUMBER
, p_user_id        IN  NUMBER
, p_login_id       IN  NUMBER
, p_req_id         IN  NUMBER
, p_prg_id         IN  NUMBER
, p_prg_appl_id    IN  NUMBER
, x_retcode        OUT NOCOPY NUMBER
, x_errbuff        OUT NOCOPY VARCHAR2
, x_errcode        OUT NOCOPY VARCHAR2
)
IS

--=================
-- CURSORS
--=================

CURSOR item_cur IS
  SELECT
    inventory_item_id
  FROM
    cst_pac_item_costs
  WHERE pac_period_id = p_pac_period_id
    AND cost_group_id = p_cost_group_id;

--=================
-- LOCAL VARIABLES
--=================

l_current_item          NUMBER;

BEGIN

  -- initialize the message stack

  FND_MSG_PUB.Initialize;

  -- loop on items
  OPEN item_cur;

  LOOP

    FETCH item_cur INTO l_current_item;
    IF item_cur%NOTFOUND
    THEN
      EXIT;
    END IF;

    -- find the first period to calculate from

    CST_MGD_LIFO_COST_PROCESSOR.find_first_period(  p_pac_period_id
                                                  , l_current_item
                                                  , p_cost_group_id
                                                  , p_cost_type_id
                                                  );

    -- record the delta quantity between periods

    CST_MGD_LIFO_COST_PROCESSOR.populate_layers(  p_pac_period_id
                                                , l_current_item
                                                , p_cost_group_id
                                                , p_cost_type_id
                                                , p_user_id
                                                , p_login_id
                                                , p_req_id
                                                , p_prg_id
                                                , p_prg_appl_id
                                                );

    -- calculate and record the lifo item cost

    CST_MGD_LIFO_COST_PROCESSOR.calc_lifo_cost(  p_pac_period_id
                                               , l_current_item
                                               , p_cost_group_id
                                               , p_cost_type_id
                                               , p_user_id
                                               );


  END LOOP;

  -- report success

  x_errbuff := NULL;
  x_retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'lifo_cost_processor'
                             );
    END IF;
    x_retcode := 2;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
END lifo_cost_processor;



--=========================================================================
-- PROCEDURE  : pop_summary_data               PUBLIC
-- PARAMETERS : p_legal_entity                 legal entity
--            : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_master_org                   master organization
--            : p_item_code_from               beginning of item range
--            : p_item_code_to                 end of item range
-- COMMENT    : Procedure that populates a temporary table with the
--              exact data required for the Periodic Incremental LIFO
--              Valuation Report (Summary).
-- PRE-COND   : The procedure is called from a public procedure called
--              CST_MGD_LIFO_COST_PROCESSOR.populate_temp_table
--=========================================================================
PROCEDURE pop_summary_data
( p_legal_entity_id   IN  NUMBER
, p_pac_period_id     IN  NUMBER
, p_cost_group_id     IN  NUMBER
, p_cost_type_id      IN  NUMBER
, p_master_org        IN  NUMBER
, p_item_from         IN  NUMBER
, p_item_to           IN  NUMBER
)
IS

--=================
-- CURSORS
--=================

CURSOR item_cur IS
  SELECT
    inventory_item_id
  FROM
    cst_pac_item_costs
  WHERE pac_period_id = p_pac_period_id
    AND cost_group_id = p_cost_group_id
    AND inventory_item_id BETWEEN p_item_from AND p_item_to;

--================
-- TYPES
--================

TYPE l_inventory_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--=================
-- LOCAL VARIABLES
--=================

l_process_error          EXCEPTION;
l_current_item           NUMBER;
l_market_value           NUMBER;
l_inventory_tab          l_inventory_tbl_type;
l_empty_inventory_tab    l_inventory_tbl_type;

BEGIN

  -- initialize the message stack

  FND_MSG_PUB.Initialize;

  -- loop on items
  OPEN item_cur;

  LOOP

    FETCH item_cur INTO l_current_item;
    IF item_cur%NOTFOUND
    THEN
      EXIT;
    END IF;

    SELECT
        market_value
    INTO
        l_market_value
    FROM
        cst_pac_item_costs
    WHERE pac_period_id = p_pac_period_id
      AND inventory_item_id = l_current_item
      AND cost_group_id = p_cost_group_id;

    IF l_market_value IS null
    THEN

       INSERT into CSTGILEV_TEMP(
           item_id
         , item_desc
         , period_id
         , period_name
         , wac
         , lifo_cost
         , layer_quantity
         , total_layer_quantity
         , item_code
         , uom_code
         , inventory_value)
         SELECT
           pic.inventory_item_id
         , msi.description
         , pp.pac_period_id
         , pp.period_name
         , DECODE((pic.make_quantity+pic.buy_quantity)
                       , 0, 0
                       ,(pic.item_make_cost*pic.make_quantity +
                         pic.item_buy_cost*pic.buy_quantity)/
                        ( pic.make_quantity+pic.buy_quantity))
         , pic.item_cost
         , pql.layer_quantity
         , pic.total_layer_quantity
         , kfv.concatenated_segments
         , msi.primary_uom_code
         , (pic.item_cost * pic.total_layer_quantity)
         FROM
           cst_cost_groups cg
         , cst_le_cost_types clt
         , cst_pac_periods pp
         , cst_pac_item_costs pic
         , cst_pac_quantity_layers pql
         , mtl_system_items msi
         , mtl_system_items_kfv kfv
         WHERE clt.legal_entity     = p_legal_entity_id
         AND pp.legal_entity        = clt.legal_entity
         AND cg.legal_entity        = clt.legal_entity
         AND cg.cost_group_id       = p_cost_group_id
         AND pp.pac_period_id       = p_pac_period_id
         AND clt.cost_type_id        = pp.cost_type_id
         AND clt.cost_type_id        = p_cost_type_id
         AND pic.cost_group_id      = cg.cost_group_id
         AND pic.pac_period_id      = p_pac_period_id
         AND pql.pac_period_id      = pic.pac_period_id
         AND pql.cost_group_id      = pic.cost_group_id
         AND pql.inventory_item_id  = l_current_item
         AND msi.inventory_item_id  = l_current_item
         AND msi.organization_id    = cg.organization_id
         AND kfv.inventory_item_id  = l_current_item
         AND pic.inventory_item_id  = kfv.inventory_item_id
         AND kfv.organization_id    = p_master_org
	 AND pic.cost_layer_id      = pql.cost_layer_id;

     ELSE

       INSERT into CSTGILEV_TEMP(
           item_id
         , item_desc
         , period_id
         , period_name
         , wac
         , lifo_cost
         , market_value
         , layer_quantity
         , total_layer_quantity
         , item_code
         , uom_code
         , inventory_value)
         SELECT
           pic.inventory_item_id
         , msi.description
         , pp.pac_period_id
         , pp.period_name
         , DECODE((pic.make_quantity+pic.buy_quantity)
                       , 0, 0
                       ,(pic.item_make_cost*pic.make_quantity +
                         pic.item_buy_cost*pic.buy_quantity)/
                        ( pic.make_quantity+pic.buy_quantity))
         , pic.item_cost
         , pic.market_value
         , pql.layer_quantity
         , pic.total_layer_quantity
         , kfv.concatenated_segments
         , msi.primary_uom_code
         , (pic.market_value * pic.total_layer_quantity)
         FROM
           cst_cost_groups cg
         , cst_le_cost_types clt
         , cst_pac_periods pp
         , cst_pac_item_costs pic
         , cst_pac_quantity_layers pql
         , mtl_system_items msi
         , mtl_system_items_kfv kfv
         WHERE clt.legal_entity     = p_legal_entity_id
         AND pp.legal_entity        = clt.legal_entity
         AND cg.legal_entity        = clt.legal_entity
         AND cg.cost_group_id       = p_cost_group_id
         AND pp.pac_period_id       = p_pac_period_id
         AND clt.cost_type_id        = pp.cost_type_id
         AND clt.cost_type_id        = p_cost_type_id
         AND pic.cost_group_id      = cg.cost_group_id
         AND pic.pac_period_id      = p_pac_period_id
         AND pql.pac_period_id      = pic.pac_period_id
         AND pql.cost_group_id      = pic.cost_group_id
         AND pql.inventory_item_id  = l_current_item
         AND msi.inventory_item_id  = l_current_item
         AND msi.organization_id    = cg.organization_id
         AND kfv.inventory_item_id  = l_current_item
         AND pic.inventory_item_id  = kfv.inventory_item_id
         AND kfv.organization_id    = p_master_org
	 AND pic.cost_layer_id      = pql.cost_layer_id;

     END IF;

  END LOOP;

  -- find the total value of all calculated inventory values

  UPDATE CSTGILEV_TEMP
  SET total_inventory_value =
     (SELECT SUM(inventory_value)
      FROM cstgilev_temp
      WHERE period_id = p_pac_period_id)
  WHERE period_id = p_pac_period_id
  AND item_id = l_current_item;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'pop_summary_data'
                             );
    END IF;
    RAISE;
END pop_summary_data;

--=========================================================================
-- PROCEDURE  : pop_detail_data                PUBLIC
-- PARAMETERS : p_legal_entity                 legal entity
--            : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_master_org                   master organization
--            : p_item_code_from               beginning of range
--            : p_item_code_to                 end of item range
-- COMMENT    : Procedure that populates a temporary table with the
--              exact data required for the Periodic Incremental LIFO
--              Valuation Report (Detail).
-- PRE-COND   : The procedure is called from a public procedure called
--              CST_MGD_LIFO_COST_PROCESSOR.populate_temp_table
--=========================================================================
PROCEDURE pop_detail_data
( p_legal_entity_id   IN  NUMBER
, p_pac_period_id     IN  NUMBER
, p_cost_group_id     IN  NUMBER
, p_cost_type_id      IN  NUMBER
, p_master_org        IN  NUMBER
, p_item_from         IN  NUMBER
, p_item_to           IN  NUMBER
)
IS

--=================
-- CURSORS
--=================

CURSOR item_cur IS
  SELECT
    inventory_item_id
  FROM
    cst_pac_item_costs
  WHERE pac_period_id = p_pac_period_id
    AND cost_group_id = p_cost_group_id
    AND inventory_item_id BETWEEN p_item_from AND p_item_to;

--================
-- TYPES
--================

TYPE l_inventory_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--=================
-- LOCAL VARIABLES
--=================

l_process_error          EXCEPTION;
l_current_period         NUMBER;
l_market_value           NUMBER;
l_current_item           NUMBER;
l_inventory_tab          l_inventory_tbl_type;
l_empty_inventory_tab    l_inventory_tbl_type;

BEGIN

  -- initialize the message stack

  FND_MSG_PUB.Initialize;

  -- loop on items
  OPEN item_cur;

  LOOP

    FETCH item_cur INTO l_current_item;

    IF item_cur%NOTFOUND
    THEN
      EXIT;
    END IF;

    -- initialize the PL/SQL table

    l_inventory_tab(0) := 0;

       -- Find the first period to calculate from

       CST_MGD_LIFO_COST_PROCESSOR.find_first_period(  p_pac_period_id
                                                    , l_current_item
                                                    , p_cost_group_id
                                                    , p_cost_type_id
                                                    );

    FOR l_inventory_index IN g_period_tab.FIRST .. g_period_tab.LAST
    LOOP
    l_inventory_tab(l_inventory_index) := 0;
    END LOOP;

    LOOP

      SELECT
          market_value
      INTO
          l_market_value
      FROM
          cst_pac_item_costs
      WHERE pac_period_id = g_period_tab(g_current_period_index)
        AND inventory_item_id = l_current_item
        AND cost_group_id = p_cost_group_id;

      -- Exit loop if period = current period

      EXIT WHEN g_period_tab(g_current_period_index) = p_pac_period_id;

      IF l_market_value IS NULL
      THEN

         INSERT into CSTGILEV_TEMP(
           item_id
         , item_desc
         , period_id
         , period_name
         , wac
         , layer_quantity
         , total_layer_quantity
         , item_code
         , uom_code
         , inventory_value)
         SELECT
           pic.inventory_item_id
         , msi.description
         , pp.pac_period_id
         , pp.period_name
         , DECODE((pic.make_quantity+pic.buy_quantity)
                       , 0, 0
                       ,(pic.item_make_cost*pic.make_quantity +
                         pic.item_buy_cost*pic.buy_quantity)/
                        ( pic.make_quantity+pic.buy_quantity))
         , pql.layer_quantity
         , pic.total_layer_quantity
         , kfv.concatenated_segments
         , msi.primary_uom_code
         , (pic.item_cost * pic.total_layer_quantity)
         FROM
           cst_cost_groups cg
         , cst_le_cost_types clt
         , cst_pac_periods pp
         , cst_pac_item_costs pic
         , cst_pac_quantity_layers pql
         , mtl_system_items msi
         , mtl_system_items_kfv kfv
         WHERE clt.legal_entity     = p_legal_entity_id
         AND pp.legal_entity        = clt.legal_entity
         AND cg.legal_entity        = clt.legal_entity
         AND cg.cost_group_id       = p_cost_group_id
         AND pp.pac_period_id       = g_period_tab(g_current_period_index)
         AND clt.cost_type_id        = pp.cost_type_id
         AND clt.cost_type_id        = p_cost_type_id
         AND pic.cost_group_id      = cg.cost_group_id
         AND pic.pac_period_id      = g_period_tab(g_current_period_index)
         AND pql.pac_period_id      = g_period_tab(g_current_period_index)
         AND pql.cost_group_id      = pic.cost_group_id
         AND pql.inventory_item_id  = l_current_item
         AND msi.inventory_item_id  = pql.inventory_item_id
         AND msi.organization_id    = cg.organization_id
         AND kfv.inventory_item_id  = msi.inventory_item_id
         AND pic.inventory_item_id  = kfv.inventory_item_id
         AND kfv.organization_id    = p_master_org
	 AND pic.cost_layer_id      = pql.cost_layer_id;


      ELSE

         INSERT into CSTGILEV_TEMP(
           item_id
         , item_desc
         , period_id
         , period_name
         , wac
         , market_value
         , justification
         , layer_quantity
         , total_layer_quantity
         , item_code
         , uom_code
         , inventory_value)
         SELECT
           pic.inventory_item_id
         , msi.description
         , pp.pac_period_id
         , pp.period_name
         , pic.market_value
         , pic.market_value
         , pic.justification
         , pql.layer_quantity
         , pic.total_layer_quantity
         , kfv.concatenated_segments
         , msi.primary_uom_code
         , (pic.market_value * pic.total_layer_quantity)
         FROM
           cst_cost_groups cg
         , cst_le_cost_types clt
         , cst_pac_periods pp
         , cst_pac_item_costs pic
         , cst_pac_quantity_layers pql
         , mtl_system_items msi
         , mtl_system_items_kfv kfv
         WHERE clt.legal_entity     = p_legal_entity_id
         AND pp.legal_entity        = clt.legal_entity
         AND cg.legal_entity        = clt.legal_entity
         AND cg.cost_group_id       = p_cost_group_id
         AND pp.pac_period_id       = g_period_tab(g_current_period_index)
         AND clt.cost_type_id        = pp.cost_type_id
         AND clt.cost_type_id        = p_cost_type_id
         AND pic.cost_group_id      = cg.cost_group_id
         AND pic.pac_period_id      = g_period_tab(g_current_period_index)
         AND pql.pac_period_id      = g_period_tab(g_current_period_index)
         AND pql.cost_group_id      = pic.cost_group_id
         AND pql.inventory_item_id  = l_current_item
         AND msi.inventory_item_id  = pql.inventory_item_id
         AND msi.organization_id    = cg.organization_id
         AND kfv.inventory_item_id  = msi.inventory_item_id
         AND pic.inventory_item_id  = kfv.inventory_item_id
         AND kfv.organization_id    = p_master_org
	 AND pic.cost_layer_id      = pql.cost_layer_id;

      END IF;

      g_current_period_index := g_period_tab.NEXT(g_current_period_index);
      l_current_period := g_period_tab(g_current_period_index);

    END LOOP;

    -- The final report record has a unique format
    -- dependent on the existence of a market value

    IF l_market_value IS NULL
    THEN

       INSERT into CSTGILEV_TEMP(
          item_id
        , item_desc
        , period_id
        , period_name
        , wac
        , lifo_cost
        , justification
        , layer_quantity
        , total_layer_quantity
        , item_code
        , uom_code
        , inventory_value)
        SELECT
          pic.inventory_item_id
        , msi.description
        , pp.pac_period_id
        , pp.period_name
        , DECODE((pic.make_quantity+pic.buy_quantity)
                      , 0, 0
                      ,(pic.item_make_cost*pic.make_quantity +
                        pic.item_buy_cost*pic.buy_quantity)/
                       ( pic.make_quantity+pic.buy_quantity))
        , pic.item_cost lifo_cost
        , pic.justification
        , pql.layer_quantity
        , pic.total_layer_quantity
        , kfv.concatenated_segments
        , msi.primary_uom_code
        , (pic.item_cost * pic.total_layer_quantity)
        FROM
          cst_cost_groups cg
        , cst_le_cost_types clt
        , cst_pac_periods pp
        , cst_pac_item_costs pic
        , cst_pac_quantity_layers pql
        , mtl_system_items msi
        , mtl_system_items_kfv kfv
        WHERE clt.legal_entity     = p_legal_entity_id
        AND pp.legal_entity        = clt.legal_entity
        AND cg.legal_entity        = clt.legal_entity
        AND cg.cost_group_id       = p_cost_group_id
        AND pp.pac_period_id       = p_pac_period_id
        AND clt.cost_type_id       = pp.cost_type_id
        AND clt.cost_type_id       = p_cost_type_id
        AND pic.cost_group_id      = cg.cost_group_id
        AND pic.pac_period_id      = p_pac_period_id
        AND pql.pac_period_id      = pic.pac_period_id
        AND pql.cost_group_id      = pic.cost_group_id
        AND pql.inventory_item_id  = l_current_item
        AND msi.inventory_item_id  = pql.inventory_item_id
        AND msi.organization_id    = cg.organization_id
        AND kfv.inventory_item_id  = msi.inventory_item_id
        AND pic.inventory_item_id  = kfv.inventory_item_id
        AND kfv.organization_id    = p_master_org
	AND pic.cost_layer_id      = pql.cost_layer_id;

     ELSE

       INSERT into CSTGILEV_TEMP(
          item_id
        , item_desc
        , period_id
        , period_name
        , wac
        , lifo_cost
        , market_value
        , justification
        , layer_quantity
        , total_layer_quantity
        , item_code
        , uom_code
        , inventory_value)
        SELECT
          pic.inventory_item_id
        , msi.description
        , pp.pac_period_id
        , pp.period_name
        , DECODE((pic.make_quantity+pic.buy_quantity)
                      , 0, 0
                      ,(pic.item_make_cost*pic.make_quantity +
                        pic.item_buy_cost*pic.buy_quantity)/
                       ( pic.make_quantity+pic.buy_quantity))
        , pic.item_cost lifo_cost
        , pic.market_value
        , pic.justification
        , pql.layer_quantity
        , pic.total_layer_quantity
        , kfv.concatenated_segments
        , msi.primary_uom_code
        , (pic.market_value * pic.total_layer_quantity)
        FROM
          cst_cost_groups cg
        , cst_le_cost_types clt
        , cst_pac_periods pp
        , cst_pac_item_costs pic
        , cst_pac_quantity_layers pql
        , mtl_system_items msi
        , mtl_system_items_kfv kfv
        WHERE clt.legal_entity     = p_legal_entity_id
        AND pp.legal_entity        = clt.legal_entity
        AND cg.legal_entity        = clt.legal_entity
        AND cg.cost_group_id       = p_cost_group_id
        AND pp.pac_period_id       = p_pac_period_id
        AND clt.cost_type_id       = pp.cost_type_id
        AND clt.cost_type_id       = p_cost_type_id
        AND pic.cost_group_id      = cg.cost_group_id
        AND pic.pac_period_id      = p_pac_period_id
        AND pql.pac_period_id      = pic.pac_period_id
        AND pql.cost_group_id      = pic.cost_group_id
        AND pql.inventory_item_id  = l_current_item
        AND msi.inventory_item_id  = pql.inventory_item_id
        AND msi.organization_id    = cg.organization_id
        AND kfv.inventory_item_id  = msi.inventory_item_id
        AND pic.inventory_item_id  = kfv.inventory_item_id
        AND kfv.organization_id    = p_master_org
	AND pic.cost_layer_id      = pql.cost_layer_id;

     END IF;


     -- Only insert one value into total_inventory_value
     -- so that the report sums correctly

     UPDATE CSTGILEV_TEMP
     SET total_inventory_value =
        (SELECT
         inventory_value
         FROM cstgilev_temp
         WHERE period_id = p_pac_period_id
         AND item_id = l_current_item)
     WHERE period_id = p_pac_period_id
     AND item_id = l_current_item;

  END LOOP;

  -- clean PL/SQL table of previous calculations

  l_inventory_tab := l_empty_inventory_tab;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'pop_detail_data'
                             );
    END IF;
    RAISE;
END pop_detail_data;

--=========================================================================
-- PROCEDURE  : populate_temp_table            PUBLIC
-- PARAMETERS : p_legal_entity                 legal entity
--            : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_item_code_from               beginning of item range
--            : p_item_code_to                 end of item range
--            : x_retcode                      0 success, 1 warning, 2 error
--            : x_errbuff                      error buffer
-- COMMENT    : This Procedure decides whether to populate
--              the temporary table CSTGILEV_TEMP with summarized
--              or detailed information.
-- PRE-COND   : The procedure is called from a before report trigger in
--              the incremental LIFO evaluation report. The cost processor
--              has already run.
--=========================================================================
PROCEDURE populate_temp_table
( p_legal_entity_id   IN  NUMBER
, p_pac_period_id     IN  NUMBER
, p_cost_group_id     IN  NUMBER
, p_cost_type_id      IN  NUMBER
, p_detailed_report   IN  VARCHAR2
, p_item_code_from    IN  VARCHAR2
, p_item_code_to      IN  VARCHAR2
, x_retcode           OUT NOCOPY NUMBER
, x_errbuff           OUT NOCOPY VARCHAR2
, x_errcode           OUT NOCOPY VARCHAR2
)
IS

l_master_org        NUMBER;
l_min_item_from     NUMBER;
l_max_item_to       NUMBER;
l_item_from         VARCHAR2(24);
l_item_to           VARCHAR2(24);


BEGIN

  l_master_org := 0;

  -- First find the master organization

  SELECT organization_id
  INTO l_master_org
  FROM cst_cost_groups
  WHERE cost_group_id = p_cost_group_id;

  -- Calculate the min and max ranges

  SELECT
    min(inventory_item_id)
  , max(inventory_item_id)
  INTO
    l_item_from
  , l_item_to
  FROM
    cst_pac_item_costs
  WHERE cost_group_id = p_cost_group_id
    AND pac_period_id = p_pac_period_id;

  -- Find if the :from or :to range paramenters have values
  -- if they are null then set them to the appropriate
  -- min or max values

  IF p_item_code_from IS not null
  THEN
    SELECT
      inventory_item_id
    INTO
      l_item_from
    FROM mtl_system_items_kfv
    WHERE concatenated_segments = p_item_code_from
      AND organization_id = l_master_org;
  END IF;

  IF p_item_code_to IS not null
  THEN
    SELECT
      inventory_item_id
    INTO
      l_item_to
    FROM mtl_system_items_kfv
    WHERE concatenated_segments = p_item_code_to
      AND organization_id = l_master_org;
  END IF;

  -- Call either the procedure for the summary or detailed report
  -- depending on input parameter

  IF p_detailed_report = 'Y'
  THEN

       -- If this is a detailed report populate the
       -- temporary table with period layers.

       CST_MGD_LIFO_COST_PROCESSOR.pop_detail_data(p_legal_entity_id
                                                   , p_pac_period_id
                                                   , p_cost_group_id
                                                   , p_cost_type_id
                                                   , l_master_org
                                                   , l_item_from
                                                   , l_item_to
                                                   );
  ELSE

       -- If this is a summary report populate the
       -- temporary table with data representing the
       -- current period.

       CST_MGD_LIFO_COST_PROCESSOR.pop_summary_data(p_legal_entity_id
                                                    , p_pac_period_id
                                                    , p_cost_group_id
                                                    , p_cost_type_id
                                                    , l_master_org
                                                    , l_item_from
                                                    , l_item_to
                                                    );

  END IF;

  -- report success

  x_errbuff := NULL;
  x_retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                             , 'populate_temp_table'
                             );
    END IF;
    x_retcode := 2;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
END populate_temp_table;


--=========================================================================
-- PROCEDURE  : get_period_id		       PUBLIC
-- PARAMETERS : p_interface_id                 interface id
-- 	      : p_legal_entity                 legal entity
--            : p_cost_type_id                 cost type id
--            : p_pac_period_id                period id
--            : p_err_num		       end of item range
--            : p_err_code                     0 success, 1 warning, 2 error
--            : p_err_msg                      error buffer
-- COMMENT    : This procedere gets the period id to manage
--              the LIFO loading layer utility
-- PRE-COND   :
--=========================================================================
PROCEDURE get_pac_id
( p_interface_header_id   IN      NUMBER
, p_legal_entity          IN      NUMBER
, p_cost_type_id          IN      NUMBER
, p_pac_period_id         OUT     NOCOPY NUMBER
, p_err_num               OUT     NOCOPY NUMBER
, p_err_code              OUT     NOCOPY VARCHAR2
, p_err_msg               OUT     NOCOPY VARCHAR2
)
IS

l_stmt_num                      NUMBER;
l_count				NUMBER;

BEGIN
  ----------------------------------------------------------------------
  -- Initialize Variables
  ----------------------------------------------------------------------

  l_stmt_num := 1;

  SELECT cpp.pac_period_id
  INTO   p_pac_period_id
  FROM   cst_pac_periods cpp
  WHERE  (cpp.period_name, cpp.cost_type_id)  =
         ( SELECT cpici.period_name,
                  cct.cost_type_id
           FROM   cst_pc_item_cost_interface cpici,
                  cst_cost_types             cct
           WHERE  cpici.interface_header_id = p_interface_header_id
           AND    cpici.cost_type = cct.cost_type
         )
  AND    cpp.open_flag = 'N';

  l_stmt_num := 2;

  UPDATE cst_pc_item_cost_interface cpici
  SET    cpici.pac_period_id = p_pac_period_id
  WHERE  cpici.interface_header_id = p_interface_header_id;

  l_stmt_num := 3;

  SELECT count(*)
  INTO   l_count
  FROM   cst_pc_item_cost_interface cpici
  WHERE  cpici.pac_period_id  = p_pac_period_id
  AND    (cpici.inventory_item_id,cpici.cost_group,cpici.cost_type) IN
           (
            SELECT inventory_item_id, cost_group , cost_type
            FROM   cst_pc_item_cost_interface
            WHERE  interface_header_id = p_interface_header_id
           );

  IF l_count > 1 THEN
    p_pac_period_id := 0;
    p_err_num := 99;
    p_err_code := NULL;
    p_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR.get_pac_id('
                   || to_char(l_stmt_num)
                   || '): '
                   ||'TOO MANY PERIODS',1,240);
  END IF;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    p_err_num := 1403;
    p_err_code := NULL;
    p_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR.get_pac_id('
                   || to_char(l_stmt_num)
                   || '): '
                   ||SQLERRM,1,240);

  WHEN OTHERS THEN
    ROLLBACK;
    p_err_num := SQLCODE;
    p_err_code := NULL;
    p_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR.get_pac_id('
                   || to_char(l_stmt_num)
                   || '): '
                   ||SQLERRM,1,240);


END get_pac_id;


--=========================================================================
-- PROCEDURE  : check_quantity		     PUBLIC
-- PARAMETERS : p_interface_group_id         interface id
--            : p_err_num		     end of item range
--            : p_err_code                   0 success, 1 warning, 2 error
--            : p_err_msg                    error buffer
-- COMMENT    : This procedere check if layer quantity of period n is equal
--              to begin layer quantity of period n+1 for the LIFO loading layer
-- PRE-COND   :
--=========================================================================
PROCEDURE check_quantity
( p_interface_group_id   IN      NUMBER
, p_err_num              OUT     NOCOPY NUMBER
, p_err_code             OUT     NOCOPY VARCHAR2
, p_err_msg              OUT     NOCOPY VARCHAR2
)
IS

CURSOR c_interface (a_interface_group_id IN  NUMBER) IS
  SELECT interface_header_id,
         cost_group,
         cost_type,
         inventory_item_id,
         begin_layer_quantity,
         layer_quantity
  FROM	 cst_pc_item_cost_interface
  WHERE  interface_group_id = a_interface_group_id
  ORDER BY cost_group, cost_type, inventory_item_id, pac_period_id;

RECINTERFACE c_interface%ROWTYPE;

l_cost_group 			VARCHAR2(10) := NULL;
l_cost_type			VARCHAR2(10);
l_inventory_item_id		NUMBER;
l_begin_layer_quantity		NUMBER;
l_layer_quantity		NUMBER;
l_primary_cost_method		NUMBER;
l_initial_quantity              NUMBER;

l_stmt_num                      NUMBER;

BEGIN
  ----------------------------------------------------------------------
  -- Initialize Variables
  ----------------------------------------------------------------------

  l_stmt_num := 1;


  OPEN c_interface(p_interface_group_id);
  LOOP
    FETCH c_interface INTO RECINTERFACE;
    IF (c_interface %NOTFOUND) THEN
      EXIT;
    ELSE
      IF l_cost_group IS NULL THEN -- First record fetched
        SELECT clct.primary_cost_method
        INTO   l_primary_cost_method
        FROM   cst_cost_types cct,
               cst_le_cost_types clct
        WHERE  cct.cost_type_id = clct.cost_type_id
        AND    clct.legal_entity =
                 (SELECT DISTINCT ccg.legal_entity
             	  FROM   cst_cost_groups ccg,
                         cst_cost_group_assignments ccga
                  WHERE  ccg.cost_group_id = ccga.cost_group_id
                  AND    ccg.cost_group_type = 2
                  AND    ccg.cost_group IN
                           (SELECT cpici.cost_group
                            FROM   cst_pc_item_cost_interface cpici
                            WHERE  cpici.interface_header_id =
                                     RECINTERFACE.interface_header_id
		           )
		 )
        AND    cct.cost_type IN
                 (SELECT cpici.cost_type
                  FROM   cst_pc_item_cost_interface cpici
                  WHERE   cpici.interface_header_id =
                            RECINTERFACE.interface_header_id
	         );

        SELECT cpici.begin_layer_quantity
        INTO l_initial_quantity
        FROM   cst_pc_item_cost_interface cpici
        WHERE   cpici.interface_header_id =
                  RECINTERFACE.interface_header_id;

        IF l_primary_cost_method <> 4 OR l_initial_quantity <> 0 THEN
          EXIT;
        END IF;
      ELSIF (l_cost_group = RECINTERFACE.cost_group AND
        l_cost_type     = RECINTERFACE.cost_type AND
        l_inventory_item_id = RECINTERFACE.inventory_item_id) THEN
        IF l_layer_quantity <> RECINTERFACE.begin_layer_quantity THEN
	  p_err_num := 99;
          p_err_code := NULL;
          p_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR'
                         ||'.check_quantity('
                         || to_char(l_stmt_num)
                         || '): '
		         ||'begin layer quantity not correct'
                         ||' for interface_id='
		         ||TO_CHAR(RECINTERFACE.interface_header_id),1,240);

          UPDATE cst_pc_item_cost_interface
             SET process_flag = 3,
                 error_flag   = 22,
                 error_explanation = 'Begin layer quantity not correct for LIFO record'
           WHERE interface_header_id = RECINTERFACE.interface_header_id;
          COMMIT;
          EXIT;
        END IF;
      END IF;
      l_cost_group	   	   := RECINTERFACE.cost_group;
      l_cost_type		   := RECINTERFACE.cost_type;
      l_inventory_item_id	   := RECINTERFACE.inventory_item_id;
      l_begin_layer_quantity 	   := RECINTERFACE.begin_layer_quantity;
      l_layer_quantity	           := RECINTERFACE.layer_quantity;
    END IF;
  END LOOP;
  CLOSE c_interface;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_err_num := SQLCODE;
    p_err_code := NULL;
    p_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR.check_quantity('
                   || to_char(l_stmt_num)
                   || '): '
                   ||SQLERRM,1,240);


END check_quantity;

--=========================================================================
-- PROCEDURE  : loading_lifo_cost               PUBLIC
-- PARAMETERS : p_interface_group_id        interface unique id
--            : p_err_num                    end of item range
--            : p_err_code                   0 success, 1 warning, 2 error
--            : p_err_msg                    error buffer
-- COMMENT    : This procedure reads cost group, period id, item id from
--              the interface header table and uses them as input to
--              the standard procedure that calculates lifo.
-- PRE-COND   :
--=========================================================================
PROCEDURE loading_lifo_cost
(p_interface_group_id   IN      NUMBER
,p_user_id              IN      NUMBER
,p_login_id             IN      NUMBER
,p_req_id               IN      NUMBER
,p_prg_id               IN      NUMBER
,p_prg_appl_id          IN      NUMBER
,x_err_num              OUT     NOCOPY NUMBER
,x_err_code             OUT     NOCOPY VARCHAR2
,x_err_msg              OUT     NOCOPY VARCHAR2
)
IS

CURSOR c_interface (a_interface_group_id IN  NUMBER) IS
  SELECT pac_period_id,
         cost_group_id,
         cost_type,
         inventory_item_id,
         interface_header_id
  FROM   cst_pc_item_cost_interface
  WHERE  interface_group_id = a_interface_group_id
  ORDER BY cost_group, cost_type, inventory_item_id, pac_period_id;

RECINTERFACE c_interface%ROWTYPE;

l_stmt_num                      NUMBER;
l_user_id                       NUMBER;
l_cost_type_id                  NUMBER;
l_primary_cost_method           NUMBER;
l_login_id                      NUMBER;
l_req_id                        NUMBER;
l_prg_id                        NUMBER;
l_prg_appl_id                   NUMBER;


BEGIN
  ----------------------------------------------------------------------
  -- Initialize Variables
  ----------------------------------------------------------------------

  l_stmt_num := 1;

  l_user_id := p_user_id;
  l_login_id := p_login_id;
  l_req_id := p_req_id;
  l_prg_id := p_prg_id;
  l_prg_appl_id := p_prg_appl_id;

  OPEN c_interface(p_interface_group_id);
  LOOP
    FETCH c_interface INTO RECINTERFACE;
    IF (c_interface %NOTFOUND) THEN
      EXIT;
    ELSE
      SELECT clct.primary_cost_method
      INTO   l_primary_cost_method
      FROM   cst_cost_types cct,
             cst_le_cost_types clct
      WHERE  cct.cost_type_id = clct.cost_type_id
      AND    clct.legal_entity =
               (SELECT DISTINCT ccg.legal_entity
                FROM   cst_cost_groups ccg,
                       cst_cost_group_assignments ccga
                WHERE  ccg.cost_group_id = ccga.cost_group_id
                AND    ccg.cost_group_type = 2
                AND    ccg.cost_group IN
                         (SELECT cpici.cost_group
                          FROM   cst_pc_item_cost_interface cpici
                          WHERE  cpici.interface_header_id =
                                   RECINTERFACE.interface_header_id
                         )
               )
      AND    cct.cost_type IN
               (SELECT cpici.cost_type
                FROM   cst_pc_item_cost_interface cpici
                WHERE   cpici.interface_header_id =
                          RECINTERFACE.interface_header_id
               );

      IF l_primary_cost_method <> 4 THEN
        EXIT;
      END IF;

      -- The interface table does not hold the cost type id
      -- The lifo processor requires the cost type id

      SELECT cost_type_id
      INTO l_cost_type_id
      FROM cst_cost_types
      WHERE cost_type = RECINTERFACE.cost_type;

      -- find the first period to calculate from

      CST_MGD_LIFO_COST_PROCESSOR.find_first_period(RECINTERFACE.pac_period_id
                                                   ,RECINTERFACE.inventory_item_id
                                                   ,RECINTERFACE.cost_group_id
                                                   ,l_cost_type_id
                                                    );

      -- record the delta quantity between periods

      CST_MGD_LIFO_COST_PROCESSOR.populate_layers(RECINTERFACE.pac_period_id
                                                 ,RECINTERFACE.inventory_item_id
                                                 ,RECINTERFACE.cost_group_id
                                                 ,l_cost_type_id
                                                 ,l_user_id
                                                 ,l_login_id
                                                 ,l_req_id
                                                 ,l_prg_id
                                                 ,l_prg_appl_id
                                                 );

      -- call the cost processor to calc lifo

      CST_MGD_LIFO_COST_PROCESSOR.calc_lifo_cost(RECINTERFACE.pac_period_id
                                                ,RECINTERFACE.inventory_item_id
                                                ,RECINTERFACE.cost_group_id
                                                ,l_cost_type_id
                                                ,l_user_id);


    END IF;
  END LOOP;
  CLOSE c_interface;

  -- report success

  x_err_msg := NULL;
  x_err_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_err_num := SQLCODE;
    x_err_code := NULL;
    x_err_msg := SUBSTR('CST_MGD_LIFO_COST_PROCESSOR.loading_lifo_cost('
                   || to_char(l_stmt_num)
                   || '): '
                   ||SQLERRM,1,240);


END loading_lifo_cost;


--========================================================================
-- PROCEDURE  : Log_Initialize   PRIVATE
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PRIVATE
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--========================================================================
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;

--=========================================================================
-- PROCEDURE  : selective_purge                PRIVATE
-- PARAMETERS : p_legal_entity_id              legal entity
--            : p_pac_period_id                user specified layer period id
--            : p_first_period_id              first period id for an item
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_item_id                      Inventory item id
-- COMMENT    : This Procedure selectively purges the historical LIFO layers
--              where the delta <=0 and market value does not exist for a
--              given inventory item per cost group per cost type
--=========================================================================
PROCEDURE selective_purge
( p_legal_entity_id        IN  NUMBER
, p_pac_period_id          IN  NUMBER
, p_first_period_id        IN  NUMBER
, p_cost_group_id          IN  NUMBER
, p_cost_type_id           IN  NUMBER
, p_item_id                IN  NUMBER
)
IS

--=================
-- CURSORS
--=================

-- cursor to get market value
CURSOR get_market_value_cur(c_period_id     NUMBER
                           ,c_cost_group_id NUMBER
                           ,c_item_id       NUMBER)
IS
  SELECT
    market_value
  FROM  CST_PAC_ITEM_COSTS
  WHERE pac_period_id     = c_period_id
    AND cost_group_id     = c_cost_group_id
    AND inventory_item_id = c_item_id;

-- cursor to get begin layer quantity
CURSOR get_begin_quantity_cur(c_period_id     NUMBER
                             ,c_cost_group_id NUMBER
                             ,c_item_id       NUMBER)
IS
  SELECT
    begin_layer_quantity
  FROM  CST_PAC_QUANTITY_LAYERS
  WHERE pac_period_id     = c_period_id
    AND cost_group_id     = c_cost_group_id
    AND inventory_item_id = c_item_id;


-- cursor to obtain delta (layer quantity)
CURSOR get_layer_quantity_cur(c_period_id     NUMBER
                             ,c_item_id       NUMBER
                             ,c_cost_group_id NUMBER)
IS
  SELECT
    layer_quantity
  FROM  CST_PAC_QUANTITY_LAYERS
  WHERE pac_period_id     = c_period_id
    AND inventory_item_id = c_item_id
    AND cost_group_id     = c_cost_group_id;

-- cursor to obtain the period end date
CURSOR get_period_end_date_cur(c_period_id  NUMBER)
IS
  SELECT
    period_end_date
  FROM  CST_PAC_PERIODS
  WHERE pac_period_id   = c_period_id;

-- cursor to obtain the prior purge count
CURSOR get_purge_prior_cnt_cur(c_cost_group_id NUMBER,
                              c_item_id        NUMBER,
                              c_first_period_end_date DATE)
IS
  SELECT
    COUNT(*)
  FROM  CST_PAC_ITEM_COSTS
  WHERE  cost_group_id      = c_cost_group_id
    AND  inventory_item_id  = c_item_id
    AND  pac_period_id   IN (SELECT pac_period_id
                             FROM   CST_PAC_PERIODS
                             WHERE  period_end_date
                                    < c_first_period_end_date);



--=================
-- LOCAL VARIABLES
--=================

l_period_id                   NUMBER;
l_market_value                NUMBER;
l_layer_quantity              NUMBER;
l_first_layer_quantity        NUMBER;
l_first_begin_quantity        NUMBER;
l_first_period_end_date       DATE;
l_errorcode                   NUMBER;
l_errortext                   VARCHAR2(200);


l_purge_prior_count       NUMBER  := 0;
l_rec_purge_count         NUMBER;
l_total_purge_count       NUMBER  := 0;

-- store the list of item cost periods
l_period_index         BINARY_INTEGER;


BEGIN

CST_MGD_LIFO_COST_PROCESSOR.Log
        (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
         ,'Start of Proc:Selective Purge'
      );

-- initialize the message stack
   FND_MSG_PUB.Initialize;

  -- get market value for the first period
  OPEN get_market_value_cur(p_first_period_id
                           ,p_cost_group_id
                           ,p_item_id
                            );
  FETCH get_market_value_cur INTO l_market_value;

  CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                     ,'Market Value: ' || to_char(l_market_value)
                   );

  CLOSE get_market_value_cur;

  -- get begining quantity for the first period
  OPEN get_begin_quantity_cur(p_first_period_id
                             ,p_cost_group_id
                             ,p_item_id
                              );

  FETCH get_begin_quantity_cur INTO l_first_begin_quantity;

  CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                     ,'Begin quantity of the first period: ' ||
                     to_char(l_first_begin_quantity)
                   );

  CLOSE get_begin_quantity_cur;

  OPEN  get_period_end_date_cur(p_first_period_id);
  FETCH get_period_end_date_cur
  INTO  l_first_period_end_date;

  CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                     ,'First period end date: ' ||
                     to_char(l_first_period_end_date)

                   );

  CLOSE get_period_end_date_cur;


  -- delete prior item cost layers
  IF (l_market_value IS NOT NULL) OR (l_first_begin_quantity <= 0) THEN

    -- get the historical prior purge count
      OPEN get_purge_prior_cnt_cur(p_cost_group_id,
                                   p_item_id,
                                   l_first_period_end_date);

      FETCH get_purge_prior_cnt_cur
       INTO l_purge_prior_count;

      CLOSE get_purge_prior_cnt_cur;

    -- Delete all the prior item costs
        DELETE  CST_PAC_ITEM_COSTS
         WHERE  cost_group_id      = p_cost_group_id
           AND  inventory_item_id  = p_item_id
           AND  pac_period_id   IN (SELECT pac_period_id
                                    FROM   CST_PAC_PERIODS
                                    WHERE   period_end_date
                                            < l_first_period_end_date);


    -- Delete all the prior item quantity layers
       DELETE  CST_PAC_QUANTITY_LAYERS
        WHERE  cost_group_id      = p_cost_group_id
          AND  inventory_item_id  = p_item_id
          AND  pac_period_id   IN (SELECT pac_period_id
                                   FROM   CST_PAC_PERIODS
                                   WHERE  period_end_date
                                          < l_first_period_end_date);


       COMMIT; -- Deleted all the prior item cost layers with commit size
       CST_MGD_LIFO_COST_PROCESSOR.Log
                     (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                      ,'Number of historical item cost layers purged: ' ||
                      to_char(l_purge_prior_count)
                 );


    -- update the total purge count
    l_total_purge_count := l_total_purge_count + l_purge_prior_count;

  END IF;


   -- initialize the purge count
   l_rec_purge_count := 0;

   -- initialize the cost layer range for commit

   -- Get the period index of the p_pac_period_id
   -- first period index
   l_period_index :=
     CST_MGD_LIFO_COST_PROCESSOR.g_current_period_index;

   -- get the first period id
     l_period_id  :=
       CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_period_index);

   WHILE (l_period_index <>
     CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.LAST)  LOOP

     IF (l_period_id = p_pac_period_id) THEN

       CST_MGD_LIFO_COST_PROCESSOR.Log
            (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
             ,'Current Period Index: ' ||
               to_char(l_period_index) || ' ' ||
               'Period Id:' || to_char(l_period_id)
             );
       EXIT;
     END IF;
     --  get the next period index
     l_period_index :=
       CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.NEXT(l_period_index);

     l_period_id :=
       CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_period_index);

   END LOOP;

  WHILE (l_period_id <> p_first_period_id)  LOOP
    OPEN get_layer_quantity_cur(l_period_id
                                ,p_item_id
                                ,p_cost_group_id);

    CST_MGD_LIFO_COST_PROCESSOR.Log
            (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
             ,'Period Id: ' ||
              to_char(l_period_id)
             );

    FETCH get_layer_quantity_cur
     INTO l_layer_quantity;

    CST_MGD_LIFO_COST_PROCESSOR.Log
             (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
              ,'Delta of the item cost layer: ' ||
                to_char(l_layer_quantity)
              );

    CLOSE get_layer_quantity_cur;

         -- delete the layer if the delta is negative or 0
         IF (l_layer_quantity <= 0) THEN

              DELETE CST_PAC_ITEM_COSTS
              WHERE  pac_period_id      = l_period_id
                AND  inventory_item_id  = p_item_id
                AND  cost_group_id      = p_cost_group_id;

              DELETE  CST_PAC_QUANTITY_LAYERS
              WHERE   pac_period_id     = l_period_id
                AND   inventory_item_id = p_item_id
                AND   cost_group_id     = p_cost_group_id;


            --  get the previous period layer
            l_period_index :=
              CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.PRIOR(l_period_index);

            l_period_id :=
             CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_period_index);

            -- add delta to the end quantity of the previous period item costs
            UPDATE CST_PAC_ITEM_COSTS
              SET  total_layer_quantity = total_layer_quantity + l_layer_quantity
            WHERE  pac_period_id        = l_period_id
              AND  inventory_item_id    = p_item_id
              AND  cost_group_id        = p_cost_group_id;

            -- add delta to the previous period quantity layer
            UPDATE CST_PAC_QUANTITY_LAYERS
               SET layer_quantity    = layer_quantity + l_layer_quantity
             WHERE pac_period_id     = l_period_id
               AND inventory_item_id = p_item_id
               AND cost_group_id     = p_cost_group_id;

            l_rec_purge_count := l_rec_purge_count + 1;

         ELSE

         --  get the previous period layer
              l_period_index :=
                CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.PRIOR(l_period_index);

              l_period_id :=
                CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_period_index);

         END IF;


  END LOOP;


  -- for the first period
  -- check whether delta is <= 0 and market value is null
     IF (l_period_id = p_first_period_id) THEN
        OPEN get_layer_quantity_cur(p_first_period_id
                                   ,p_item_id
                                   ,p_cost_group_id);

         FETCH get_layer_quantity_cur
         INTO  l_first_layer_quantity;

         CLOSE get_layer_quantity_cur;

       IF ((l_first_layer_quantity <= 0) AND ( l_market_value IS NULL)) THEN
         --  Delete the item cost and quantity layer
              DELETE CST_PAC_ITEM_COSTS
               WHERE pac_period_id     =  p_first_period_id
                 AND inventory_item_id =  p_item_id
                 AND cost_group_id     =  p_cost_group_id;

              DELETE  CST_PAC_QUANTITY_LAYERS
               WHERE  pac_period_id     = p_first_period_id
                 AND  inventory_item_id = p_item_id
                 AND  cost_group_id     = p_cost_group_id;

              -- update the purge counters
              l_rec_purge_count := l_rec_purge_count + 1;

       ELSE
         -- Update begin quantity to 0
         -- Update delta to the end quantity
             UPDATE CST_PAC_QUANTITY_LAYERS
                SET begin_layer_quantity = 0,
                    layer_quantity = (SELECT  total_layer_quantity
                                        FROM  CST_PAC_ITEM_COSTS
                                       WHERE  pac_period_id     =  p_first_period_id
                                         AND  inventory_item_id =  p_item_id
                                         AND  cost_group_id     =  p_cost_group_id)
             WHERE pac_period_id     = p_first_period_id
               AND inventory_item_id = p_item_id
               AND cost_group_id     = p_cost_group_id;
       END IF;

     END IF;

COMMIT;  -- deleted all the item cost layers
  -- update total purge count
  l_total_purge_count := l_total_purge_count + l_rec_purge_count;

  CST_MGD_LIFO_COST_PROCESSOR.Log
                   (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_EVENT
                     ,'Inventory Item Id: ' || to_char(p_item_id)
                     || ' Total item cost layers purged: ' ||
                     to_char(l_total_purge_count)
                    );


  CST_MGD_LIFO_COST_PROCESSOR.Log
                   (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                  ,'End of Proc:Selective Purge'
                 );

EXCEPTION

   WHEN OTHERS THEN
        l_errorcode := SQLCODE;
          l_errortext := SUBSTR(SQLERRM,1,200);
        CST_MGD_LIFO_COST_PROCESSOR.Log
              (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_ERROR
               ,to_char(l_errorcode) || l_errortext
            );

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                                ,'selective_purge'
                                );
     END IF;

END selective_purge;


--=========================================================================
-- PROCEDURE  : lifo_purge                     PUBLIC
-- PARAMETERS : x_retcode                      0 success, 1 warning, 2 error
--            : x_errbuff                      error buffer
--            : p_legal_entity                 legal entity
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_pac_period_id                user specified period id
--            : p_category_set_name            Item category set name
--            : p_category_struct              Category Structure used by
--                                             category pair
--            : p_category_from                begining of item category
--                                             range
--            : p_category_to                  end of item category range
--            : p_item_from                    beginning of item range
--            : p_item_to                      end of item range
-- COMMENT    : This Procedure purges the historical LIFO layers as per the
--              purge algorithm.  This procedure will invoke the private
--              procedures find_first_period and selective_purge
--=========================================================================
PROCEDURE lifo_purge
(x_errbuff           OUT NOCOPY VARCHAR2
,x_retcode           OUT NOCOPY VARCHAR2
,p_legal_entity_id   IN  NUMBER
,p_cost_group_id     IN  NUMBER
,p_cost_type_id      IN  NUMBER
,p_pac_period_id     IN  NUMBER
,p_category_set_name IN  VARCHAR2
,p_category_struct   IN  NUMBER
,p_category_from     IN  VARCHAR2
,p_category_to       IN  VARCHAR2
,p_item_from         IN  VARCHAR2
,p_item_to           IN  VARCHAR2
)
IS

--=================
-- CURSORS
--=================

-- cursor to obtain master organization for the cost group
-- where cost group type is Organization (Organization cost group)
CURSOR master_org_cur(c_cost_group_id  NUMBER) IS
   SELECT
    ccg.organization_id,
    HOU.name
   FROM CST_COST_GROUPS ccg,
        HR_ORGANIZATION_UNITS HOU,
        HR_ORGANIZATION_INFORMATION HOI
   WHERE HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
    AND HOI.ORG_INFORMATION1 = 'INV'
    AND HOI.ORG_INFORMATION2 = 'Y'
    AND ( HOI.ORG_INFORMATION_CONTEXT || '')  = 'CLASS'
    AND ccg.cost_group_id   = c_cost_group_id
    AND ccg.cost_group_type = 2
    AND ccg.organization_id = HOU.organization_id;

-- cursor to obtain list of item numbers for a given legal entity,
-- cost period, cost group, cost type, item category, item range
-- and master organization
CURSOR item_number_cur(c_legal_entity_id      NUMBER,
                       c_pac_period_id        NUMBER,
                       c_cost_group_id        NUMBER,
                       c_cost_type_id         NUMBER,
                       c_item_number_from     VARCHAR2,
                       c_item_number_to       VARCHAR2,
                       c_category_struct      NUMBER,
                       c_category_from        VARCHAR2,
                       c_category_to          VARCHAR2,
                       c_master_org_id        NUMBER)  IS
  SELECT
    msi.concatenated_segments item_number,
    msi.inventory_item_id
  FROM
    CST_PAC_PERIODS pp
   ,CST_PAC_ITEM_COSTS pic
   ,MTL_SYSTEM_ITEMS_KFV msi
   ,MTL_ITEM_CATEGORIES mic
   ,MTL_CATEGORIES_KFV mc
  WHERE    pp.legal_entity            = c_legal_entity_id
    AND    pic.cost_group_id          = c_cost_group_id
    AND    pp.cost_type_id            = c_cost_type_id
    AND    pp.pac_period_id           = c_pac_period_id
    AND    pic.pac_period_id          = pp.pac_period_id
    AND    pic.inventory_item_id      = msi.inventory_item_id
    AND    msi.inventory_item_id      = mic.inventory_item_id
    AND    msi.organization_id        = mic.organization_id
    AND    mic.category_id            = mc.category_id
    AND    mc.structure_id            = c_category_struct
    AND    mc.concatenated_segments
           BETWEEN nvl(c_category_from,mc.concatenated_segments)
               AND nvl(c_category_to,mc.concatenated_segments)
    AND    msi.concatenated_segments
           BETWEEN nvl(c_item_number_from,msi.concatenated_segments)
               AND nvl(c_item_number_to,msi.concatenated_segments)
    AND    msi.organization_id        = c_master_org_id
  ORDER BY msi.concatenated_segments;


--=================
-- LOCAL VARIABLES
--=================

l_first_period_id         NUMBER;
l_profile_org_id          NUMBER;
l_master_org_id           NUMBER;
l_master_org_name         VARCHAR2(240);
l_item_number             VARCHAR2(240);
l_inventory_item_id       NUMBER;

-- store the list of item cost periods
l_period_tab              CST_MGD_LIFO_COST_PROCESSOR.period_tbl_type;
l_first_period_index      BINARY_INTEGER;
l_period_index            BINARY_INTEGER;
l_next_period_index       BINARY_INTEGER;
l_period_id               NUMBER;
l_next_period_id          NUMBER;
l_total_quantity          NUMBER;

BEGIN

-- initialize log
   CST_MGD_LIFO_COST_PROCESSOR.Log_Initialize;

-- initialize the message stack
   FND_MSG_PUB.Initialize;

   CST_MGD_LIFO_COST_PROCESSOR.Log
        (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
         ,'Start of Proc:Lifo purge'
      );

-- Print the Parameter values
   CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'----- PARAMETERS -----'
                );

   CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Legal entity Id    : ' || to_char(p_legal_entity_id)
                );

   CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Cost group Id      : ' || to_char(p_cost_group_id)
                 );

   CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Cost type Id       : ' || to_char(p_cost_type_id)
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Pac Period Id      : ' || to_char(p_pac_period_id)
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Category Set name  : ' || p_category_set_name
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Category Structure : ' || to_char(p_category_struct)
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Category From      : ' || p_category_from
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Category To        : ' || p_category_to
                 );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Item From          : ' || p_item_from
                );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
                 ,'Item To            : ' || p_item_to
                );


-- get master organization id
   OPEN master_org_cur(p_cost_group_id);

   FETCH master_org_cur
    INTO l_master_org_id,
         l_master_org_name;


   CST_MGD_LIFO_COST_PROCESSOR.Log
                (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                 ,'Master Organization Id: ' || to_char(l_master_org_id)
                 || ' ' || l_master_org_name
               );

   CLOSE master_org_cur;


   -- for each item find the first period and purge the historical LIFO layers
   FOR item_number_list in item_number_cur(p_legal_entity_id
                                         ,p_pac_period_id
                                         ,p_cost_group_id
                                         ,p_cost_type_id
                                         ,p_item_from
                                         ,p_item_to
                                         ,p_category_struct
                                         ,p_category_from
                                         ,p_category_to
                                         ,l_master_org_id)

   LOOP

     -- Item Information
     l_item_number       :=  item_number_list.item_number;
     l_inventory_item_id :=  item_number_list.inventory_item_id;

     CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                     ,'Item Number: ' || l_item_number
                     || ' ' || 'Item Id: ' || to_char(l_inventory_item_id)
                   );


    -- Get the first period per item per cost group per cost type
    CST_MGD_LIFO_COST_PROCESSOR.find_first_period(p_pac_period_id
                                                 ,l_inventory_item_id
                                                 ,p_cost_group_id
                                                 ,p_cost_type_id);

    -- first period index
    l_first_period_index := CST_MGD_LIFO_COST_PROCESSOR.g_current_period_index;

    -- first period id
    l_first_period_id  :=
            CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_first_period_index);

    -- get the total quantity of the first period
    SELECT
      total_layer_quantity
    INTO
      l_total_quantity
    FROM
      cst_pac_item_costs
    WHERE pac_period_id = l_first_period_id
      AND inventory_item_id = l_inventory_item_id
      AND cost_group_id = p_cost_group_id;

   -- Get the period index of the p_pac_period_id

   l_period_index := l_first_period_index;

   WHILE (l_period_index <=
     CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.LAST) LOOP

    l_period_id :=
      CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_period_index);

     IF (l_period_id = p_pac_period_id) THEN

       CST_MGD_LIFO_COST_PROCESSOR.Log
            (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
             ,'Current Period Index: ' ||
               to_char(l_period_index) || ' ' ||
               'Period Id:' || to_char(l_period_id)
             );
       EXIT;
     END IF;

    l_period_index :=
      CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.NEXT(l_period_index);

   END LOOP;

  -- get the proper first period when total qty is <= 0
  IF (l_total_quantity <= 0
     AND l_first_period_index <> g_period_tab.LAST) THEN

    l_next_period_index :=
      CST_MGD_LIFO_COST_PROCESSOR.g_period_tab.NEXT(l_first_period_index);
    l_next_period_id :=
      CST_MGD_LIFO_COST_PROCESSOR.g_period_tab(l_next_period_index);

   -- check the incremented index lies within the current period index
    IF l_next_period_index <= l_period_index THEN
      l_first_period_index := l_next_period_index;
      l_first_period_id    := l_next_period_id;
    END IF;

  END IF;

    CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_EVENT
                     ,'Proc:find first period  completed'
                   );

    CST_MGD_LIFO_COST_PROCESSOR.Log
                    (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_STATEMENT
                     ,'First Period Id: ' || to_char(l_first_period_id)
                   );

    -- selective purge of the item cost historical LIFO layers
    CST_MGD_LIFO_COST_PROCESSOR.selective_purge(p_legal_entity_id
                                               ,p_pac_period_id
                                               ,l_first_period_id
                                               ,p_cost_group_id
                                               ,p_cost_type_id
                                               ,l_inventory_item_id);


   END LOOP; -- for the list of items

  CST_MGD_LIFO_COST_PROCESSOR.Log
      (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
          ,'End of Proc:Lifo purge'
       );


  CST_MGD_LIFO_COST_PROCESSOR.Log
      (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
          ,'Selective LIFO Purge Successful'
       );

  x_errbuff := NULL;
  x_retcode := RETCODE_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_CST_MGD_LIFO_COST_PROCESSOR
                              ,'lifo_purge'
                              );
     END IF;

     CST_MGD_LIFO_COST_PROCESSOR.Log
         (CST_MGD_LIFO_COST_PROCESSOR.G_LOG_PROCEDURE
          ,'Selective LIFO Purge Failed'
          );

     x_retcode := RETCODE_ERROR;
     x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);

END Lifo_purge;

END CST_MGD_LIFO_COST_PROCESSOR;

/
