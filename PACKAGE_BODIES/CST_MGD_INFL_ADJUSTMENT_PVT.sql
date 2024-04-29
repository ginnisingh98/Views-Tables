--------------------------------------------------------
--  DDL for Package Body CST_MGD_INFL_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_INFL_ADJUSTMENT_PVT" AS
/* $Header: CSTVIADB.pls 120.13.12010000.2 2008/10/29 21:54:04 vjavli ship $ */

--===================
-- TYPES
--===================
TYPE Transfer_Rec_Type IS RECORD
( transaction_id           NUMBER
, inventory_item_id        NUMBER
, organization_id          NUMBER
, acct_period_id           NUMBER
, last_update_date         DATE
, last_updated_by          NUMBER
, creation_date            DATE
, created_by               NUMBER
, last_update_login        NUMBER
, request_id               NUMBER
, program_application_id   NUMBER
, program_id               NUMBER
, program_update_date      DATE
, country_code             VARCHAR2(2)
, transfer_organization_id NUMBER
, entered_dr               NUMBER
, entered_cr               NUMBER
);

TYPE Transfer_Tbl_Rec_Type IS TABLE OF Transfer_Rec_Type
INDEX BY BINARY_INTEGER;

--===================
-- CONSTANTS
--===================

--================================
-- PRIVATE VARIABLES AND CONSTANTS
--================================
g_period_not_closed_exc      EXCEPTION;
g_no_hist_data_exc           EXCEPTION;
g_no_data_previous_data_exc  EXCEPTION;
g_acct_ccid_null_exc         EXCEPTION;
g_tnsf_period_gap_exc        EXCEPTION;

G_MODULE_HEAD CONSTANT VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Check_Period_Close      PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--           : p_acct_period_id        Account period ID
-- COMMENT   : This procedure check if an accounting period is closed.
-- EXCEPTIONS: g_period_not_closed_exc Period is not closed
--========================================================================
PROCEDURE Check_Period_Close
( p_org_id         IN  NUMBER
, p_acct_period_id IN  NUMBER
)
IS
l_routine  CONSTANT VARCHAR2(30) := 'check_period_close';

l_period_close_date DATE;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    Period_Close_Date
  INTO
    l_period_close_date
  FROM
    ORG_ACCT_PERIODS
  WHERE Organization_ID = p_org_id
    AND Acct_Period_ID  = p_acct_period_id
    AND Open_Flag       = 'N'
    AND Period_Close_Date IS NOT NULL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_PER_NOT_CLOSED');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Check_Period_Close'
      );
    END IF;
    RAISE g_period_not_closed_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Check_Period_Close'
      );
    END IF;
    RAISE;

END Check_Period_Close;


--========================================================================
-- PROCEDURE : Get_Previous_Acct_Period_ID PRIVATE
-- PARAMETERS: p_organization_id       Organization ID
--             p_acct_period_id        Account period ID
--             x_prev_acct_period_id   Perious period account period ID
--             x_prev_sch_close_date   Perious period schedule close date
-- COMMENT   : This procedure retrieves previous period account period ID
--             and scheduled close date.
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Previous_Acct_Period_ID
( p_organization_id     IN  NUMBER
, p_acct_period_id      IN  NUMBER
, x_prev_acct_period_id OUT NOCOPY NUMBER
, x_prev_sch_close_date OUT NOCOPY DATE
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_previous_acct_period_id';
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    Schedule_Close_Date
  , Acct_Period_ID
  INTO
    x_prev_sch_close_date
  , x_prev_acct_period_id
  FROM
    ORG_ACCT_PERIODS
  WHERE Organization_ID = p_organization_id
    AND Acct_Period_ID  = (SELECT
                             MAX(Acct_Period_ID)
                           FROM
                             CST_MGD_INFL_ADJ_PER_STATUSES
                           WHERE Organization_ID = p_organization_id
                             AND Status          = 'FINAL')
    AND Open_Flag       = 'N'
    AND Period_Close_Date IS NOT NULL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   NULL;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Get_Previous_Acct_Period_ID'
      );
    END IF;
    RAISE;

END Get_Previous_Acct_Period_ID;

--========================================================================
-- PROCEDURE : Get_Prev_Org_Acct_Period_ID PRIVATE
-- PARAMETERS: p_organization_id       Organization ID
--             p_acct_period_id        Account period ID
--             x_previous_acct_period_id
--                                     Inventory org previous period ID
-- COMMENT   : This procedure retrieves the inventory organization's previous
--             period account period ID regardless if inflation adjustment
--             has been run for the period or not. If found, return the ID,
--             else return NULL. This procedure does not validate the
--             current period, just get the previous inventory period.
-- EXCEPTIONS: when no date found, do nothing.
--========================================================================
PROCEDURE Get_Prev_Org_Acct_Period_ID
( p_organization_id         IN  NUMBER
, p_acct_period_id          IN  NUMBER
, x_prev_org_acct_period_id OUT NOCOPY NUMBER
)
IS
  l_prev_org_acct_period_id NUMBER;
  l_cur_org_acct_period_val NUMBER;
BEGIN
  SELECT oap2.period_year * 10000 + oap2.period_num
  INTO   l_cur_org_acct_period_val
  FROM   ORG_ACCT_PERIODS oap2
  WHERE  oap2.organization_id = p_organization_id
  AND    oap2.acct_period_id  = p_acct_period_id;

  SELECT oap.acct_period_id
  INTO   l_prev_org_acct_period_id
  FROM   ORG_ACCT_PERIODS oap
  WHERE  oap.period_year * 10000 + oap.period_num =
         (SELECT MAX(oap2.period_year * 10000 + oap2.period_num)
          FROM   ORG_ACCT_PERIODS oap2
          WHERE  oap2.organization_id = p_organization_id
          AND    (oap2.period_year * 10000 + oap2.period_num) <
                 l_cur_org_acct_period_val
         )
  AND    oap.organization_id = p_organization_id;

  x_prev_org_acct_period_id := l_prev_org_acct_period_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Get_Prev_Org_Acct_Period_ID'
      );
    END IF;
    RAISE;

END Get_Prev_Org_Acct_Period_ID;

--========================================================================
-- PROCEDURE : Get_Curr_Period_Start_Date PRIVATE
-- PARAMETERS: p_org_id                 Organization ID
--             p_acct_period_id         Account period ID
--             x_curr_period_start_date Current period start date
--             x_curr_period_end_date   Current period schedule
--                                      close date
-- COMMENT   : This procedure returns the current period start date
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Curr_Period_Start_Date
( p_org_id                 IN         NUMBER
, p_acct_period_id         IN         NUMBER
, x_curr_period_start_date OUT NOCOPY DATE
, x_curr_period_end_date   OUT NOCOPY DATE
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_curr_period_start_date';
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    Period_Start_Date
  , Schedule_Close_Date
  INTO
    x_curr_period_start_date
  , x_curr_period_end_date
  FROM
    ORG_ACCT_PERIODS
  WHERE Acct_Period_ID  = p_acct_period_id
    AND Organization_ID = p_org_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Curr_Period_Start_Date'
                             );
    END IF;
    RAISE;

END Get_Curr_Period_Start_Date;


--=======================================================================
-- PROCEDURE : Get_Previous_Period_Info PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_organization_id       Organization ID
--             p_inventory_item_id     Inventory item ID
--             p_acct_period_id        Account period ID
--             p_prev_acct_period_id   Previous account period id
--             p_cost_group_id         Cost Group Id
--             x_previous_qty          Previous period quantity
--             x_previous_cost         Previous period total cost
--             x_previous_inflation_adj Previous period inflation
--                                      adjustment
-- COMMENT   : This procedure returns previous inflation adjustment
--             data
-- EXCEPTIONS:
--             made obsolete g_no_data_previous_data_exc  No rows selected
--             part of bug#1474753 fix
--             removed historical flag parameter.
--========================================================================
PROCEDURE Get_Previous_Period_Info
( p_country_code           IN  VARCHAR2
, p_organization_id        IN  NUMBER
, p_inventory_item_id      IN  NUMBER
, p_acct_period_id         IN  NUMBER
, p_prev_acct_period_id    IN  NUMBER
, p_cost_group_id          IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_previous_qty           OUT NOCOPY NUMBER
, x_previous_cost          OUT NOCOPY NUMBER
, x_previous_inflation_adj OUT NOCOPY NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_previous_period_info';
l_previous_qty             NUMBER;
l_previous_cost            NUMBER;
l_previous_inflation_adj   NUMBER;
l_item_exists_infl         VARCHAR2(1);
l_item_exists_cst          VARCHAR2(1);
l_prev_org_acct_period_id  NUMBER;
l_previous_unit_cost       NUMBER;

BEGIN

  -- initialize
  l_previous_qty           := 0;
  l_previous_unit_cost     := 0;
  l_previous_cost          := 0;
  l_previous_inflation_adj := 0;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    NVL((Actual_Inflation_Adj - ABS(Issue_Inflation_Adj)),0)
  , NVL((Actual_Qty - ABS(Issue_Qty)),0)
  , NVL((Actual_Cost - ABS(Issue_Cost)),0)
  INTO
    l_previous_inflation_adj
  , l_previous_qty
  , l_previous_cost
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS
  WHERE Country_Code      = nvl(p_country_code, country_code)
    AND Acct_Period_ID    = p_prev_acct_period_id
    AND Organization_ID   = p_organization_id
    AND Inventory_Item_ID = p_inventory_item_id;

  x_previous_qty           := l_previous_qty;
  x_previous_cost          := l_previous_cost;
  x_previous_inflation_adj := l_previous_inflation_adj;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.inflprevpd'
                  , 'Inflation Adjustments for previous period not found'
                  );
    END IF;

    -- Get the previous accounting period if any and get the cost from
    -- the CST view since no inflation adjustment has been run for
    -- such period.
    --
    Get_Prev_Org_Acct_Period_ID
      ( p_organization_id             => p_organization_id
      , p_acct_period_id              => p_acct_period_id
      , x_prev_org_acct_period_id     => l_prev_org_acct_period_id
      );

    IF l_prev_org_acct_period_id IS NULL THEN

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.inflprevpd'
                  , 'This is the first accounting period of organization'
                  );
      END IF;
      --
      x_previous_qty           := 0;
      x_previous_cost          := 0;
      x_previous_inflation_adj := 0;

    ELSE
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.inflprevpd'
                  , 'A previous accounting period exist for this organization'
                  );
      END IF;

      /* Bug 4912789 the following query is replaced because CST_PER_CLOSE_DTLS_V is a Non Mergeable View
      SELECT   NVL(SUM(period_end_quantity),0)
             , NVL(SUM(period_end_unit_cost),0)
      INTO     l_previous_qty
             , l_previous_unit_cost
      FROM   CST_PER_CLOSE_DTLS_V
      WHERE  organization_id   = p_organization_id
      AND    inventory_item_id = p_inventory_item_id
      AND    acct_period_id    = l_prev_org_acct_period_id
      AND    cost_group_id     = NVL(p_cost_group_id,cost_group_id); */

      SELECT NVL(SUM(period_end_quantity),0)
             , NVL(SUM(period_end_unit_cost*period_end_quantity),0)
	INTO     l_previous_qty
             , l_previous_cost
	FROM (
	SELECT  rollback_quantity period_end_quantity,
		decode(rollback_quantity,0,0,rollback_value/rollback_quantity) period_end_unit_cost
	  FROM    cst_period_close_summary
	  WHERE organization_id   = p_organization_id
	      AND    inventory_item_id = p_inventory_item_id
	      AND    acct_period_id    = l_prev_org_acct_period_id
	      AND    cost_group_id     = NVL(p_cost_group_id,cost_group_id)
	UNION ALL
	SELECT  period_end_quantity, period_end_unit_cost
	  FROM    mtl_per_close_dtls
	  WHERE organization_id   = p_organization_id
	      AND    inventory_item_id = p_inventory_item_id
	      AND    acct_period_id    = l_prev_org_acct_period_id
	      AND    cost_group_id     = NVL(p_cost_group_id,cost_group_id)
	);


     -- ================================================================
     -- Bug#4130232 fix: Previous Cost is the Previous Period Total Cost
     -- ================================================================
      x_previous_qty := l_previous_qty;
      x_previous_cost:= l_previous_cost;
      x_previous_inflation_adj := 0;

    END IF;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT
           , G_MODULE_HEAD || l_routine || '.inflprevinfo'
           , 'Previous Period Quantity:' || x_previous_qty ||
           ' Previous Period Unit Cost:' || l_previous_unit_cost ||
           ' Previous Period Total Cost:' || x_previous_cost ||
           ' Previous Inflation Adjustment:' || x_previous_inflation_adj
         );
      END IF;


  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Previous_Period_Info'
                             );
    END IF;
    RAISE;

END Get_Previous_Period_Info;


--========================================================================
-- PROCEDURE : Get_Purchase_Qty        PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_inventory_item_id     Inventory item ID
--             p_acct_period_id        Account period ID
--             p_cost_group_id         Cost Group ID
--             x_purchase_qty          Purchase quantity in period
-- COMMENT   : This procedure returns the purchase quantity incurred in
--             a period.
--========================================================================
PROCEDURE Get_Purchase_Qty
( p_org_id            IN  NUMBER
, p_inventory_item_id IN  NUMBER
, p_acct_period_id    IN  NUMBER
, p_cost_group_id     IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_purchase_qty      OUT NOCOPY NUMBER
)
IS
l_routine  CONSTANT VARCHAR2(30) := 'get_purchase_qty';
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- get purchase quantity for adjustment period
  SELECT
    NVL(SUM(Primary_Quantity), 0)
  INTO
    x_purchase_qty
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE Acct_Period_ID           = p_acct_period_id
    AND Organization_ID          = p_org_id
    AND Inventory_Item_ID        = p_inventory_item_id
    AND Primary_Quantity         > 0
    AND Cost_Group_ID            = p_cost_group_id
    AND Transfer_Organization_ID IS NULL
    AND nvl(owning_tp_type,2) <> 1
    AND transaction_id NOT IN (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE acct_period_id  = p_acct_period_id
                                  AND organization_id = p_org_id
                                  AND inventory_item_id = p_inventory_item_id
                                  AND transaction_source_type_id = 13
                                  AND transaction_action_id = 24)
    AND transaction_id NOT IN (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE acct_period_id  = p_acct_period_id
                                  AND organization_id = p_org_id
                                  AND inventory_item_id = p_inventory_item_id
                                  AND transaction_source_type_id = 13
                                  AND transaction_action_id = 5);


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Purchase_Qty'
                             );
    END IF;
    RAISE;

END Get_Purchase_Qty;


--========================================================================
-- PROCEDURE : Get_Issue_Qty           PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_inventory_item_id     Inventory item ID
--             p_acct_period_id        Account period ID
--             p_cost_group_id         Cost Group ID
--             x_issue_qty             Issue quantity in period
-- COMMENT   : This procedure returns the issue quantity incurred in
--             a period.
--========================================================================
PROCEDURE Get_Issue_Qty
( p_org_id            IN  NUMBER
, p_inventory_item_id IN  NUMBER
, p_acct_period_id    IN  NUMBER
, p_cost_group_id     IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_issue_qty         OUT NOCOPY NUMBER
)
IS
BEGIN

  -- get issue qty
  SELECT
    NVL(SUM(Primary_Quantity), 0)
  INTO
    x_issue_qty
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE Acct_Period_ID        = p_acct_period_id
    AND Organization_ID       = p_org_id
    AND Inventory_Item_ID     = p_inventory_item_id
    AND Primary_Quantity      < 0
    AND Cost_Group_ID         = p_cost_group_id
    AND Transfer_Organization_ID IS NULL
    AND nvl(owning_tp_type,2) <> 1
    AND transaction_id NOT IN (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE acct_period_id  = p_acct_period_id
                                  AND organization_id = p_org_id
                                  AND inventory_item_id = p_inventory_item_id
                                  AND transaction_source_type_id = 13
                                  AND transaction_action_id = 5);

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Issue_Qty'
                             );
    END IF;
    RAISE;

END Get_Issue_Qty;


--========================================================================
-- PROCEDURE : Transfer_Tbl_Default    PRIVATE
-- PARAMETERS: p_inventory_item_id     Inventory item ID
--             p_organization_id       Organization ID
--             p_acct_period_id        Account period ID
--             p_country_code          Country code
--             p_transfer_org_id       Transfer organization ID
--             x_transfer_rec          Transfer data record
-- COMMENT   : This procedure defaults the transfer organization record
--========================================================================
PROCEDURE Transfer_Tbl_Default
( p_transaction_id    IN  NUMBER
, p_inventory_item_id IN  NUMBER
, p_organization_id   IN  NUMBER
, p_acct_period_id    IN  NUMBER
, p_country_code      IN  VARCHAR2
, p_transfer_org_id   IN  NUMBER
, x_transfer_rec      OUT NOCOPY Transfer_Rec_Type
)
IS
l_transfer_rec Transfer_Rec_Type;
BEGIN

  -- default transfer entries table information
  l_transfer_rec.transaction_id           := p_transaction_id;
  l_transfer_rec.inventory_item_id        := p_inventory_item_id;
  l_transfer_rec.organization_id          := p_organization_id;
  l_transfer_rec.acct_period_id           := p_acct_period_id;
  l_transfer_rec.last_update_date         := SYSDATE;
  l_transfer_rec.last_updated_by          :=
    NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);
  l_transfer_rec.creation_date            := SYSDATE;
  l_transfer_rec.created_by               :=
    NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);
  l_transfer_rec.last_update_login        :=
    TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'));
  l_transfer_rec.request_id               :=
    TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'));
  l_transfer_rec.program_application_id   :=
    TO_NUMBER(FND_PROFILE.Value('PROG_APPL_ID'));
  l_transfer_rec.program_id               :=
    TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID'));
  l_transfer_rec.program_update_date      := SYSDATE;
  l_transfer_rec.country_code             := p_country_code;
  l_transfer_rec.transfer_organization_id := p_transfer_org_id;

  x_transfer_rec := l_transfer_rec;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Transfer_Tbl_Default'
                             );
    END IF;
    RAISE;

END Transfer_Tbl_Default;

/* historical data check removed bug#1474753 fix
--========================================================================
-- PROCEDURE : Check_First_Time        PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_org_id                Organization ID
--             x_get_hist_data_flag    Historical data flag
-- COMMENT   : This procedure determines if the process is running for
--             the first time.
-- EXCEPTIONS:
--             made obsolete g_no_hist_data_exc      No historical data
--             as part of bug#1474753 fix
--========================================================================
PROCEDURE Check_First_Time
( p_country_code       IN  VARCHAR2
, p_org_id             IN  NUMBER
, x_get_hist_data_flag OUT NOCOPY VARCHAR2
)
IS
l_status                NUMBER;
l_missing_hist_data_exc EXCEPTION;
BEGIN

  x_get_hist_data_flag := 'N';

  -- check for first time
  -- if there is data for more than
  -- 1 period then it's not first time
  SELECT
    COUNT(DISTINCT(Acct_Period_ID))
  INTO
    l_status
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS
  WHERE Country_Code    = p_country_code
    AND Organization_ID = p_org_id;

-- removed as part of bug#1474753 fix
--  IF l_status < 1
--  THEN
--    RAISE l_missing_hist_data_exc;
--  ELSIF l_status = 1
--  THEN
--    x_get_hist_data_flag := 'Y';
--  ELSE
--    x_get_hist_data_flag := 'N';
--  END IF;


-- introduced as part of bug#1474753 fix
-- set only the flag according to status
  IF l_status >= 1
  THEN
   x_get_hist_data_flag := 'Y';
  ELSE
   x_get_hist_data_flag := 'N';
  END IF;


EXCEPTION

  WHEN l_missing_hist_data_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_NO_HIST_DATA');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_First_Time'
                             );
    END IF;
    RAISE g_no_hist_data_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_First_Time'
                             );
    END IF;
    RAISE;

END Check_First_Time;

*/

--========================================================================
-- FUNCTION  : Infl_Item_Category  PRIVATE
-- PARAMETERS: p_inventory_item_id Inventory Item ID
--             p_org_id            Organization ID
--             p_category_set_id   Item Category Set ID
--             p_category_id       Item Category ID
-- COMMENT   : This function returns 'Y' if the item requires inflation
--             adjustment.
-- EXCEPTIONS: g_no_hist_data_exc  No historical data
--========================================================================
FUNCTION Infl_Item_Category
( p_inventory_item_id IN  NUMBER
, p_org_id            IN  NUMBER
, p_category_set_id   IN  NUMBER
, p_category_id       IN  NUMBER
)
RETURN VARCHAR2 IS

l_item_valid_flag VARCHAR2(1);
l_record_count NUMBER;

BEGIN
  l_item_valid_flag := 'N';

  IF (p_category_set_id IS NOT NULL) AND (p_category_id IS NULL) THEN
    SELECT
      COUNT(1)
    INTO
      l_record_count
    FROM
      MTL_ITEM_CATEGORIES
    WHERE Inventory_Item_ID = p_inventory_item_id
      AND Organization_ID   = p_org_id
      AND Category_Set_ID   = p_category_set_id;

    IF l_record_count = 1 THEN
      l_item_valid_flag := 'Y';
    END IF;
  ELSIF (p_category_set_id IS NULL) AND (p_category_id IS NOT NULL) THEN
    SELECT
      COUNT(1)
    INTO
      l_record_count
    FROM
      MTL_ITEM_CATEGORIES
    WHERE Inventory_Item_ID = p_inventory_item_id
      AND Organization_ID   = p_org_id
      AND Category_ID       = p_category_id;

    IF l_record_count > 0 THEN
      l_item_valid_flag := 'Y';
    END IF;
  ELSIF (p_category_set_id IS NOT NULL) AND (p_category_id IS NOT NULL) THEN
    SELECT
      COUNT(1)
    INTO
      l_record_count
    FROM
      MTL_ITEM_CATEGORIES
    WHERE Inventory_Item_ID = p_inventory_item_id
      AND Organization_ID   = p_org_id
      AND Category_Set_ID   = p_category_set_id
      AND Category_ID       = p_category_id;

    IF l_record_count = 1 THEN
      l_item_valid_flag := 'Y';
    END IF;
  ELSIF (p_category_set_id IS NULL) AND (p_category_id IS NULL) THEN
    l_item_valid_flag := 'Y';
  END IF;

  RETURN l_item_valid_flag;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Infl_Item_Category'
                             );
    END IF;
    RAISE;

END Infl_Item_Category;


--========================================================================
-- PROCEDURE : Calc_Inflation_Adj         PRIVATE
-- PARAMETERS: p_inflation_adjustment_rec Inflation data record
--             p_inflation_index_value    Inflation index value
--             p_prev_acct_period_id      Previous account period id
--             p_cost_group_id            Cost Group Id
--             x_inflation_adjustment_rec Inflation data record
--             x_tnsf_out_entry_tbl_rec   Transfer out table record
--             x_tnsf_in_entry_tbl_rec    Transfer in table record
-- COMMENT   : This procedure calculates the inflation adjustment for a
--             period.
--     ***     Begin cost of an item is it's ending cost in the previous
--             period. It is NOT average unit cost * total quantity.
-- EXCEPTIONS: g_tnsf_period_gap_exc      Inflation period gap in
--                                        transfer organization
--========================================================================
PROCEDURE Calc_Inflation_Adj
( p_inflation_adjustment_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
, p_inflation_index_value    IN  NUMBER
, p_prev_acct_period_id      IN  NUMBER
, p_cost_group_id            IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_inflation_adjustment_rec OUT NOCOPY
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
, x_tnsf_out_entry_tbl_rec   OUT NOCOPY Transfer_Tbl_Rec_Type
, x_tnsf_in_entry_tbl_rec    OUT NOCOPY Transfer_Tbl_Rec_Type
)
IS
l_routine CONSTANT VARCHAR2(30) := 'calc_inflation_adj';

l_inflation_adjustment_rec
  CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type;
l_tnsf_out_entry_tbl_rec     Transfer_Tbl_Rec_Type;
l_tnsf_in_entry_tbl_rec      Transfer_Tbl_Rec_Type;
l_onhand_unit_infl_cost      NUMBER;
l_out_index                  NUMBER := 1;
l_in_index                   NUMBER := 1;
l_transfer_in_begin_qty      NUMBER;
l_transfer_in_begin_cost     NUMBER;
l_transfer_in_begin_infl_adj NUMBER;
l_transfer_in_prev_infl_adj  NUMBER;
l_transfer_in_purchase_qty   NUMBER;
l_transfer_in_unit_infl_cost NUMBER;
l_actual_unit_infl_cost      NUMBER;
l_inv_inflation_CR           NUMBER := 0;
l_inv_inflation_DR           NUMBER := 0;
l_monetary_corr_CR           NUMBER := 0;
l_sales_cost_inf_DR          NUMBER := 0;
l_previous_infl_adj          NUMBER;
l_transfer_hist_data_flag    VARCHAR2(1);
l_tnsf_prev_acct_per_id      NUMBER;
l_tnsf_prev_sch_close_date   DATE;
l_tnsf_curr_per_start_date   DATE;
l_tnsf_curr_per_end_date     DATE;
l_transfer_org_code          VARCHAR2(3);
l_err_transfer_org_id        NUMBER;
l_transfer_in_cg_id          CST_COST_GROUPS.cost_group_id%TYPE;

l_tnsf_period_gap_exc        EXCEPTION;

-- ===============================================================
-- Bug#2949878 fix: cursor modified
-- transfer_cost_group_id removed
-- sub-query from org_acct_periods removed instead new condition
-- added to retrieve the corresponding transfer account period id
-- Bug#2912818 fix: Exclude consigned inventory transactions
-- nvl(mtl.owning_tp_type,2) <> 1 added
-- ===============================================================
CURSOR l_transfer_in_item_csr IS
  SELECT
    MTL.Transaction_ID
  , MTL.Transfer_Organization_ID
  , NVL(Primary_Quantity, 0) Transfer_In_Qty
  , ORG.Acct_Period_ID TNSF_Acct_Period_ID
  FROM
    MTL_MATERIAL_TRANSACTIONS MTL
  , ORG_ACCT_PERIODS         ORG
  WHERE MTL.Organization_ID   = p_inflation_adjustment_rec.organization_id
    AND MTL.Inventory_Item_ID = p_inflation_adjustment_rec.inventory_item_id
    AND MTL.Acct_Period_ID    = p_inflation_adjustment_rec.acct_period_id
    AND MTL.Primary_Quantity  > 0
    AND MTL.Cost_Group_ID     = p_cost_group_id
    AND MTL.Transfer_Organization_ID <> MTL.Organization_ID
    AND MTL.Transfer_Organization_ID IS NOT NULL
    AND ORG.Organization_ID   = MTL.Transfer_Organization_ID
    AND MTL.transaction_date BETWEEN
        TRUNC(ORG.period_start_date)
    AND (TRUNC(ORG.schedule_close_date) + (86399/86400))
    AND ORG.period_close_date IS NOT NULL
    AND ORG.open_flag <> 'Y'
    AND NVL(MTL.owning_tp_type,2) <> 1
  ORDER BY
    trunc(MTL.transaction_date)
  , MTL.creation_date
  , MTL.transaction_id;

-- bug#2949878 fix: transfer_cost_group_id removed from query
-- bug#2912818 fix: nvl(owning_tp_type,2) <> 1 added
CURSOR l_transfer_out_item_csr IS
  SELECT
    Transaction_ID
  , Transfer_Organization_ID
  , NVL(Primary_Quantity, 0) Transfer_Out_Qty
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE Organization_ID   = p_inflation_adjustment_rec.organization_id
    AND Inventory_Item_ID = p_inflation_adjustment_rec.inventory_item_id
    AND Acct_Period_ID    = p_inflation_adjustment_rec.acct_period_id
    AND Primary_Quantity  < 0
    AND Cost_Group_ID     = p_cost_group_id
    AND Transfer_Organization_ID <> Organization_ID
    AND Transfer_Organization_ID IS NOT NULL
    AND NVL(owning_tp_type,2) <> 1
  ORDER BY
    trunc(transaction_date)
  , creation_date
  , transaction_id;

-- Bug#4395397 fix: cursor to retrieve cost group of transfer in organization
CURSOR c_transfer_in_cg_cur(c_transfer_in_org_id  NUMBER)
IS
SELECT
  default_cost_group_id
FROM MTL_PARAMETERS
WHERE organization_id = c_transfer_in_org_id;


-- local debug variables to use within loop
l_debug_level NUMBER;
l_state_level NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Assign local debug variables to use within loop
  l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level := FND_LOG.LEVEL_STATEMENT;
  -- initialize
  l_transfer_hist_data_flag  := 'N';

  l_inflation_adjustment_rec := p_inflation_adjustment_rec;

  /* get previous period data */

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine || '.infladjrec'
                    , 'Inflation Adjustment record details: '
                    || 'Country Code:' || l_inflation_adjustment_rec.country_code || ' Organization Id:' || to_char(l_inflation_adjustment_rec.organization_id)
   || ' Inventory Id:' || to_char(l_inflation_adjustment_rec.inventory_item_id)
   || ' Accounting Period:' || to_char(l_inflation_adjustment_rec.acct_period_id));
    END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine || '.prevpddtl'
                    , 'Previous Period details: ' || ' Previous Period Id:'|| p_prev_acct_period_id
                    );
    END IF;

  Get_Previous_Period_Info
  ( p_country_code           => l_inflation_adjustment_rec.country_code
  , p_organization_id        => l_inflation_adjustment_rec.organization_id
  , p_inventory_item_id      => l_inflation_adjustment_rec.inventory_item_id
  , p_acct_period_id         => l_inflation_adjustment_rec.acct_period_id
  , p_prev_acct_period_id    => p_prev_acct_period_id
  , p_cost_group_id          => p_cost_group_id
  , x_previous_qty           => l_inflation_adjustment_rec.begin_qty
  , x_previous_cost          => l_inflation_adjustment_rec.begin_cost
  , x_previous_inflation_adj => l_previous_infl_adj
  );

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine || '.prevpdinfl'
                    , 'Previous Period Inflation: ' || 'Begin Qty:' ||
                       to_char(l_inflation_adjustment_rec.begin_qty) ||
                       ' Begin Cost:' || to_char(l_inflation_adjustment_rec.begin_cost) || ' Previous Inflation Adj:' || to_char(l_previous_infl_adj)
                    );
    END IF;

  l_inflation_adjustment_rec.begin_inflation_adj :=
    ((l_inflation_adjustment_rec.begin_cost + l_previous_infl_adj) *
     p_inflation_index_value) + l_previous_infl_adj;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.begininfltot'
                  ,'Beginning Total Inflation:' || to_char(l_inflation_adjustment_rec.begin_inflation_adj)
                  );
  END IF;

  -- debit begin inflation adjustment
  l_inv_inflation_DR := l_inflation_adjustment_rec.begin_inflation_adj -
                        l_previous_infl_adj;

  -- credit monetary correction with begin inflation adjustment
  l_monetary_corr_CR := l_inflation_adjustment_rec.begin_inflation_adj -
                        l_previous_infl_adj;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.dbcrinfl'
                  , 'Debit begin inflation:' || to_char(l_inv_inflation_DR) ||
                    ' Credit begin inflation:' || to_char(l_monetary_corr_CR)
                  );
  END IF;

  /* Calc. Beginning Unit Inflation Cost */

  -- get purchase quantity for adjustment period
  Get_Purchase_Qty
  ( p_org_id            => l_inflation_adjustment_rec.organization_id
  , p_inventory_item_id => l_inflation_adjustment_rec.inventory_item_id
  , p_acct_period_id    => l_inflation_adjustment_rec.acct_period_id
  , p_cost_group_id     => p_cost_group_id
  , x_purchase_qty      => l_inflation_adjustment_rec.purchase_qty
  );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.purchqty'
                  , 'Purchase Qty:' || to_char(l_inflation_adjustment_rec.purchase_qty)
                  );
  END IF;

  l_inflation_adjustment_rec.purchase_cost :=
    l_inflation_adjustment_rec.purchase_qty *
    l_inflation_adjustment_rec.item_unit_cost;

  IF (l_inflation_adjustment_rec.begin_qty +
      l_inflation_adjustment_rec.purchase_qty) = 0
  THEN
    l_onhand_unit_infl_cost := 0;
  ELSE
    l_onhand_unit_infl_cost :=
      l_inflation_adjustment_rec.begin_inflation_adj/
      (l_inflation_adjustment_rec.begin_qty +
       l_inflation_adjustment_rec.purchase_qty);
  END IF;

  /* adjust for transfers */

  -- initiate actual balances
  l_inflation_adjustment_rec.actual_qty :=
    l_inflation_adjustment_rec.begin_qty +
    l_inflation_adjustment_rec.purchase_qty;

  l_inflation_adjustment_rec.actual_inflation_adj :=
    l_inflation_adjustment_rec.begin_inflation_adj;

  -- get transfer out information
  FOR l_transfer_out_info IN l_transfer_out_item_csr
  LOOP

  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.trnsoutinfo'
                  , 'Transfer out information: ' || 'Transaction Id:' ||
                    to_char(l_transfer_out_info.Transaction_ID) ||
                    ' Transfer Org Id:' || to_char(l_transfer_out_info.Transfer_Organization_ID)
                  );
  END IF;


    Transfer_Tbl_Default
    ( p_transaction_id    => l_transfer_out_info.Transaction_ID
    , p_inventory_item_id => l_inflation_adjustment_rec.inventory_item_id
    , p_organization_id   => l_inflation_adjustment_rec.organization_id
    , p_acct_period_id    => l_inflation_adjustment_rec.acct_period_id
    , p_country_code      => l_inflation_adjustment_rec.country_code
    , p_transfer_org_id   => l_transfer_out_info.Transfer_Organization_ID
    , x_transfer_rec      => l_tnsf_out_entry_tbl_rec(l_out_index)
    );

      l_tnsf_out_entry_tbl_rec(l_out_index).entered_dr :=
        ABS(l_transfer_out_info.Transfer_Out_Qty * l_onhand_unit_infl_cost);
      l_tnsf_out_entry_tbl_rec(l_out_index).entered_cr := 0;

    -- credit adjusting org. with what's debitted for opposing org.
    l_inv_inflation_CR := l_inv_inflation_CR +
                          l_tnsf_out_entry_tbl_rec(l_out_index).entered_dr;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsoutcrinfo'
                    , 'Transfer Out Qty:' || to_char(l_transfer_out_info.Transfer_Out_Qty) || ' Inflation credit:' || to_char(l_inv_inflation_CR)
                    );
    END IF;

    -- Transfer_Out_Qty is negative for transfer out
    l_inflation_adjustment_rec.actual_qty :=
      l_inflation_adjustment_rec.actual_qty +
      l_transfer_out_info.Transfer_Out_Qty;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.actualqty'
                    , 'Actual Qty:' || to_char(l_inflation_adjustment_rec.actual_qty)
                    );
    END IF;

    l_inflation_adjustment_rec.actual_inflation_adj :=
      l_inflation_adjustment_rec.actual_inflation_adj -
      l_tnsf_out_entry_tbl_rec(l_out_index).entered_dr;


    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.actualinfl'
                    , 'Actual inflation adjustment:' ||
                      to_char(l_inflation_adjustment_rec.actual_inflation_adj)
                    );
    END IF;

    l_out_index := l_out_index + 1;
  END LOOP;

  -- get transfer in information
  FOR l_transfer_in_info IN l_transfer_in_item_csr
  LOOP

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsininfo'
                    , 'Transfer in information: ' || 'Transaction Id:' ||
                       to_char(l_transfer_in_info.Transaction_ID) ||
                       ' Transfer Org Id:' || to_char(l_transfer_in_info.Transfer_Organization_ID)
                    );
    END IF;

      OPEN c_transfer_in_cg_cur(l_transfer_in_info.transfer_organization_id);
      FETCH c_transfer_in_cg_cur
       INTO l_transfer_in_cg_id;
      CLOSE c_transfer_in_cg_cur;

      IF (l_state_level >= l_debug_level) THEN
        FND_LOG.string(l_state_level
                      ,G_MODULE_HEAD || l_routine || '.transcgid'
                      ,'Transfer in cost group id: ' || l_transfer_in_cg_id
                      );
      END IF;


    Transfer_Tbl_Default
    ( p_transaction_id    => l_transfer_in_info.Transaction_ID
    , p_inventory_item_id => l_inflation_adjustment_rec.inventory_item_id
    , p_organization_id   => l_inflation_adjustment_rec.organization_id
    , p_acct_period_id    => l_inflation_adjustment_rec.acct_period_id
    , p_country_code      => l_inflation_adjustment_rec.country_code
    , p_transfer_org_id   => l_transfer_in_info.Transfer_Organization_ID
    , x_transfer_rec      => l_tnsf_in_entry_tbl_rec(l_in_index)
    );

    /* get transfer-in unit inflation cost */

    /* historical data check removed as part of bug#1474753 fix
    Check_First_Time
    ( p_country_code       => l_inflation_adjustment_rec.country_code
    , p_org_id             => l_transfer_in_info.Transfer_Organization_ID
    , x_get_hist_data_flag => l_transfer_hist_data_flag
    );
    */

    -- Get previous account period id and scheduled close date
    -- for transfer in organization.
    Get_Previous_Acct_Period_ID
    ( p_organization_id     => l_transfer_in_info.Transfer_Organization_ID
    , p_acct_period_id      => l_transfer_in_info.TNSF_Acct_Period_ID
    , x_prev_acct_period_id => l_tnsf_prev_acct_per_id
    , x_prev_sch_close_date => l_tnsf_prev_sch_close_date
    );

    -- set to mid night 23:59:59
    l_tnsf_prev_sch_close_date :=
      TRUNC(l_tnsf_prev_sch_close_date) + (86399/86400);

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                      ,G_MODULE_HEAD || l_routine || '.tsfact'
                      ,'Tnsf Prev. Acct Period Id:' || l_tnsf_prev_acct_per_id || ' ' || l_tnsf_prev_sch_close_date
                      );
    END IF;

    -- Get current period start date.
    Get_Curr_Period_Start_Date
    ( p_org_id                 => l_transfer_in_info.Transfer_Organization_ID
    , p_acct_period_id         => l_transfer_in_info.TNSF_Acct_Period_ID
    , x_curr_period_start_date => l_tnsf_curr_per_start_date
    , x_curr_period_end_date   => l_tnsf_curr_per_end_date
    );

    l_tnsf_curr_per_start_date := TRUNC(l_tnsf_curr_per_start_date);
    l_tnsf_curr_per_end_date := TRUNC(l_tnsf_curr_per_end_date) + (86399/86400);

      IF (l_state_level >= l_debug_level) THEN
        FND_LOG.string(l_state_level
                      ,G_MODULE_HEAD || l_routine || '.tnsdte'
                      ,'Transfer Current Period Start Date:' || TO_CHAR(l_tnsf_curr_per_start_date, 'DD-MON-YYYY HH24:MI:SS') || ' ' || TO_CHAR(l_tnsf_curr_per_end_date, 'DD-MON-YYYY HH24:MI:SS')
                      );
      END IF;

    -- Check if the previous period exists
    IF (l_tnsf_prev_sch_close_date IS NOT NULL) THEN
      -- Check inflation adjustment period gap
      IF l_tnsf_curr_per_start_date > l_tnsf_prev_sch_close_date + 1
      THEN
        l_err_transfer_org_id := l_transfer_in_info.Transfer_Organization_ID;
        RAISE l_tnsf_period_gap_exc;
      END IF;
    END IF;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsinpdstart'
                    , 'Transfer in current period start date:' || to_char(l_tnsf_curr_per_start_date, 'DD-MON-YYYY HH24:MI:SS') || ' Transfer in previous schedule close date:' || to_char(l_tnsf_prev_sch_close_date, 'DD-MON-YYYY HH24:MI:SS')
                    );
    END IF;

    -- FP:11i9-11i12:Bug#4420392: Transfer in Cost Group id used
    Get_Previous_Period_Info
    ( p_country_code           => l_inflation_adjustment_rec.country_code
    , p_organization_id        =>
        l_transfer_in_info.Transfer_Organization_ID
    , p_inventory_item_id      =>
        l_inflation_adjustment_rec.inventory_item_id
    , p_acct_period_id         =>
        l_transfer_in_info.TNSF_Acct_Period_ID
    , p_prev_acct_period_id    => l_tnsf_prev_acct_per_id
    , p_cost_group_id          => l_transfer_in_cg_id
    , x_previous_qty           => l_transfer_in_begin_qty
    , x_previous_cost          => l_transfer_in_begin_cost
    , x_previous_inflation_adj => l_transfer_in_prev_infl_adj
    );

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsinprevinfl'
                    , 'Transfer in previous period inflation: ' ||
                      'Begin qty:' || to_char(l_transfer_in_begin_qty) ||
                      ' Begin Cost:' || to_char(l_transfer_in_begin_cost)
                      || 'Previous inflation:' || to_char(l_transfer_in_prev_infl_adj)
                    );
    END IF;

    l_transfer_in_begin_infl_adj :=
      ((l_transfer_in_begin_cost + l_transfer_in_prev_infl_adj) *
        p_inflation_index_value) + l_transfer_in_prev_infl_adj;

    -- FP:11i9-11i12:Bug#4420392: Transfer in Cost Group id used
    Get_Purchase_Qty
    ( p_org_id            => l_transfer_in_info.Transfer_Organization_ID
    , p_inventory_item_id => l_inflation_adjustment_rec.inventory_item_id
    , p_acct_period_id    => l_transfer_in_info.TNSF_Acct_Period_ID
    , p_cost_group_id     => l_transfer_in_cg_id
    , x_purchase_qty      => l_transfer_in_purchase_qty
    );

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsinpurchqty'
                    , 'Transfer in purchase qty: ' || l_transfer_in_purchase_qty
                    );
    END IF;

    IF (l_transfer_in_begin_qty + l_transfer_in_purchase_qty) = 0
    THEN
      l_transfer_in_unit_infl_cost := 0;
    ELSE
      l_transfer_in_unit_infl_cost := l_transfer_in_begin_infl_adj/
                                      (l_transfer_in_begin_qty +
                                       l_transfer_in_purchase_qty);
    END IF;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsinunitinfl'
                    , 'Transfer in unit inflation cost:' || to_char(l_transfer_in_unit_infl_cost)
                    );
    END IF;

    -- account entry for opposing organization
    l_tnsf_in_entry_tbl_rec(l_in_index).entered_cr :=
      l_transfer_in_info.Transfer_In_Qty * l_transfer_in_unit_infl_cost;
    l_tnsf_in_entry_tbl_rec(l_in_index).entered_dr := 0;

    -- debit adjusting org. with what's credited to the opposing org.
    l_inv_inflation_DR := l_inv_inflation_DR +
                          l_tnsf_in_entry_tbl_rec(l_in_index).entered_cr;

    -- Update rolling balances
    l_inflation_adjustment_rec.actual_qty :=
      l_inflation_adjustment_rec.actual_qty +
      l_transfer_in_info.Transfer_In_Qty;

    l_inflation_adjustment_rec.actual_inflation_adj :=
      l_inflation_adjustment_rec.actual_inflation_adj +
      l_tnsf_in_entry_tbl_rec(l_in_index).entered_cr;


    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.trnsininflcr'
                    , 'Transfer in entered cr:' || to_char(l_tnsf_in_entry_tbl_rec(l_in_index).entered_cr) || 'Inflation Dr:' || to_char(l_inv_inflation_DR)
                    );
    END IF;

    l_in_index := l_in_index + 1;
  END LOOP;

  l_inflation_adjustment_rec.actual_cost :=
    l_inflation_adjustment_rec.actual_qty *
    l_inflation_adjustment_rec.item_unit_cost;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.actualcost'
                    , 'Actual Cost:' || to_char(l_inflation_adjustment_rec.actual_cost)
                    );
    END IF;

  -- update unit inflation cost
  IF l_inflation_adjustment_rec.actual_qty = 0
  THEN
    l_actual_unit_infl_cost := 0;
  ELSE
    l_actual_unit_infl_cost :=
      l_inflation_adjustment_rec.actual_inflation_adj/
      l_inflation_adjustment_rec.actual_qty;
  END IF;

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.actualqty'
                    , 'Actual Qty:' || l_inflation_adjustment_rec.actual_qty
                    );

      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.actualunitinfl'
                    , 'Actual Unit Inflation Cost:' || to_char(l_actual_unit_infl_cost)
                    );

    END IF;

  /* Adjust for issues */

  -- get issue qty and cost
  Get_Issue_Qty
  ( p_org_id            => l_inflation_adjustment_rec.organization_id
  , p_inventory_item_id => l_inflation_adjustment_rec.inventory_item_id
  , p_acct_period_id    => l_inflation_adjustment_rec.acct_period_id
  , p_cost_group_id     => p_cost_group_id
  , x_issue_qty         => l_inflation_adjustment_rec.issue_qty
  );

    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.issueqty'
                    , 'Issue Quantity:' || to_char(l_inflation_adjustment_rec.issue_qty)
                    );
    END IF;

  l_inflation_adjustment_rec.Issue_Inflation_Adj :=
    l_inflation_adjustment_rec.issue_qty * l_actual_unit_infl_cost;

  l_inflation_adjustment_rec.issue_cost :=
    l_inflation_adjustment_rec.issue_qty *
    l_inflation_adjustment_rec.item_unit_cost;

  -- issue accounting entry
  l_sales_cost_inf_DR := l_inflation_adjustment_rec.issue_inflation_adj;

  -- =======================================================================
  -- Bug#4552111 fix: formual changed so that l_inv_inflation_CR is negative
  -- =======================================================================
  l_inv_inflation_CR :=
    l_inflation_adjustment_rec.Issue_Inflation_Adj - l_inv_inflation_CR;

  l_inflation_adjustment_rec.inventory_adj_acct_cr := l_inv_inflation_CR;
  l_inflation_adjustment_rec.inventory_adj_acct_dr := l_inv_inflation_DR;
  l_inflation_adjustment_rec.monetary_corr_acct_cr := l_monetary_corr_CR;
  l_inflation_adjustment_rec.sales_cost_acct_dr    := l_sales_cost_inf_DR;
  l_inflation_adjustment_rec.historical_flag       := 'N';


    IF (l_state_level >= l_debug_level) THEN
      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.infladjrec1'
                    , 'Inflation Adjustment record information: '
                      || 'Begin:' || to_char(l_inflation_adjustment_rec.begin_inflation_adj) || ' Actual:' || to_char(l_inflation_adjustment_rec.actual_inflation_adj)
                    );

      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.infladjrec2'
                    , ' Issue:' || to_char(l_inflation_adjustment_rec.issue_inflation_adj) || ' Credit:' || to_char(l_inflation_adjustment_rec.inventory_adj_acct_cr) || ' Debit:' || to_char(l_inflation_adjustment_rec.inventory_adj_acct_dr)
                    );

      FND_LOG.string(l_state_level
                    , G_MODULE_HEAD || l_routine || '.infladjrec3'
                    , ' Monetary Credit:' || to_char(l_inflation_adjustment_rec.monetary_corr_acct_cr) || ' Sales cost Debit' || to_char(l_inflation_adjustment_rec.sales_cost_acct_dr)
                   );
    END IF;

  -- return parameters
  x_inflation_adjustment_rec := l_inflation_adjustment_rec;
  x_tnsf_out_entry_tbl_rec   := l_tnsf_out_entry_tbl_rec;
  x_tnsf_in_entry_tbl_rec    := l_tnsf_in_entry_tbl_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN l_tnsf_period_gap_exc THEN
    SELECT
      Organization_Code
    INTO
      l_transfer_org_code
    FROM
      MTL_PARAMETERS
    WHERE
      Organization_ID = l_err_transfer_org_id;

    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_PER_GAP_TNSF');
    FND_MESSAGE.Set_Token('ORG', l_transfer_org_code);
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Calc_Inflation_Adj'
                             );
    END IF;
    RAISE g_tnsf_period_gap_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , 'Calc_Inflation_Adj'
                             );
    END IF;
    RAISE;

END Calc_Inflation_Adj;


--========================================================================
-- PROCEDURE : Insert_Inflation_Adj    PRIVATE
-- PARAMETERS: p_inflation_adjustment_rec Inflation data record
-- COMMENT   : This procedure inserts inflation adjustment data.
--========================================================================
PROCEDURE Insert_Inflation_Adj
( p_inflation_adjustment_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
)
IS
BEGIN

  INSERT INTO
    CST_MGD_INFL_ADJUSTED_COSTS(
      Inventory_Item_ID
    , Organization_ID
    , Acct_Period_ID
    , Last_Update_Date
    , Last_Updated_By
    , Creation_Date
    , Created_By
    , Last_Update_Login
    , Request_ID
    , Program_Application_ID
    , Program_ID
    , Program_Update_Date
    , Country_Code
    , Begin_Qty
    , Begin_Cost
    , Begin_Inflation_Adj
    , Purchase_Qty
    , Purchase_Cost
    , Actual_Qty
    , Actual_Cost
    , Actual_Inflation_Adj
    , Issue_Qty
    , Issue_Cost
    , Issue_Inflation_Adj
    , Inventory_Adj_Acct_CR
    , Inventory_Adj_Acct_DR
    , Monetary_Corr_Acct_CR
    , Sales_Cost_Acct_DR
    , Historical_Flag
    )
  VALUES(
      p_inflation_adjustment_rec.inventory_item_id
    , p_inflation_adjustment_rec.organization_id
    , p_inflation_adjustment_rec.acct_period_id
    , p_inflation_adjustment_rec.last_update_date
    , p_inflation_adjustment_rec.last_updated_by
    , p_inflation_adjustment_rec.creation_date
    , p_inflation_adjustment_rec.created_by
    , p_inflation_adjustment_rec.last_update_login
    , p_inflation_adjustment_rec.request_id
    , p_inflation_adjustment_rec.program_application_id
    , p_inflation_adjustment_rec.program_id
    , p_inflation_adjustment_rec.program_update_date
    , p_inflation_adjustment_rec.country_code
    , p_inflation_adjustment_rec.begin_qty
    , p_inflation_adjustment_rec.begin_cost
    , p_inflation_adjustment_rec.begin_inflation_adj
    , p_inflation_adjustment_rec.purchase_qty
    , p_inflation_adjustment_rec.purchase_cost
    , p_inflation_adjustment_rec.actual_qty
    , p_inflation_adjustment_rec.actual_cost
    , p_inflation_adjustment_rec.actual_inflation_adj
    , p_inflation_adjustment_rec.issue_qty
    , p_inflation_adjustment_rec.issue_cost
    , p_inflation_adjustment_rec.issue_inflation_adj
    , p_inflation_adjustment_rec.inventory_adj_acct_cr
    , p_inflation_adjustment_rec.inventory_adj_acct_dr
    , p_inflation_adjustment_rec.monetary_corr_acct_cr
    , p_inflation_adjustment_rec.sales_cost_acct_dr
    , p_inflation_adjustment_rec.historical_flag
    );

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Insert_Inflation_Adj'
                             );
    END IF;
    RAISE;

END Insert_Inflation_Adj;


--========================================================================
-- PROCEDURE : Insert_Transfer_Entries PRIVATE
-- PARAMETERS: p_tnsf_acct_entry_rec   Transfer organization account
--                                     record
-- COMMENT   : This procedure inserts transfer organization account
--             entries
--========================================================================
PROCEDURE Insert_Transfer_Entries
( p_tnsf_acct_entry_rec IN  Transfer_Rec_Type
)
IS
BEGIN

  INSERT INTO
    CST_MGD_INFL_TSF_ORG_ENTRIES(
      Transaction_ID
    , Inventory_Item_ID
    , Organization_ID
    , Acct_Period_ID
    , Last_Update_Date
    , Last_Updated_By
    , Creation_Date
    , Created_By
    , Last_Update_Login
    , Request_ID
    , Program_Application_ID
    , Program_ID
    , Program_Update_Date
    , Country_Code
    , Transfer_Organization_ID
    , Entered_DR
    , Entered_CR
    )
  VALUES(
      p_tnsf_acct_entry_rec.transaction_id
    , p_tnsf_acct_entry_rec.inventory_item_id
    , p_tnsf_acct_entry_rec.organization_id
    , p_tnsf_acct_entry_rec.acct_period_id
    , p_tnsf_acct_entry_rec.last_update_date
    , p_tnsf_acct_entry_rec.last_updated_by
    , p_tnsf_acct_entry_rec.creation_date
    , p_tnsf_acct_entry_rec.created_by
    , p_tnsf_acct_entry_rec.last_update_login
    , p_tnsf_acct_entry_rec.request_id
    , p_tnsf_acct_entry_rec.program_application_id
    , p_tnsf_acct_entry_rec.program_id
    , p_tnsf_acct_entry_rec.program_update_date
    , p_tnsf_acct_entry_rec.country_code
    , p_tnsf_acct_entry_rec.transfer_organization_id
    , p_tnsf_acct_entry_rec.entered_dr
    , p_tnsf_acct_entry_rec.entered_cr
    );

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Insert_Transfer_Entries'
                             );
    END IF;
    RAISE;

END Insert_Transfer_Entries;


--========================================================================
-- PROCEDURE : Create_Inflation_Adjusted_Cost PRIVATE
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_inflation_index_value Inflation index value
--             p_prev_acct_period_id   Previous account period id
--             p_inflation_adjustment_rec Inflation data record
--             p_cost_group_id         Cost Group Id
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This API is called by concurrent program.
--=======================================================================
PROCEDURE Create_Inflation_Adjusted_Cost
( p_api_version_number       IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_inflation_index_value    IN  NUMBER
, p_prev_acct_period_id      IN  NUMBER
, p_inflation_adjustment_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
, p_cost_group_id            IN  CST_COST_GROUPS.cost_group_id%TYPE
)
IS
l_routine CONSTANT VARCHAR2(30) := 'create_inflation_adjusted_cost';

l_return_status            VARCHAR2(1);
L_API_VERSION_NUMBER       CONSTANT NUMBER := 1.0;
L_API_NAME                 CONSTANT VARCHAR2(30)
					  := 'Create_Inflation_Adjusted_Cost';
l_inflation_adjustment_rec
  CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type;
l_infl_adjustment_out_rec
  CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type;
l_tnsf_out_entry_tbl_rec   Transfer_Tbl_Rec_Type;
l_tnsf_in_entry_tbl_rec    Transfer_Tbl_Rec_Type;
l_index                    BINARY_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
         ( L_API_VERSION_NUMBER
         , p_api_version_number
         , L_API_NAME
         , G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_inflation_adjustment_rec := p_inflation_adjustment_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.infladjorgacct'
                  ,'Inflation Adjustment Rec: Organization Id:' ||
                    l_inflation_adjustment_rec.organization_id ||
                  ' Acct Period Id:' || l_inflation_adjustment_rec.acct_period_id
                  );
  END IF;

  -- Calculate inflation adjustment
  Calc_Inflation_Adj
  ( p_inflation_adjustment_rec => l_inflation_adjustment_rec
  , p_inflation_index_value    => p_inflation_index_value
  , p_prev_acct_period_id      => p_prev_acct_period_id
  , p_cost_group_id            => p_cost_group_id
  , x_inflation_adjustment_rec => l_infl_adjustment_out_rec
  , x_tnsf_out_entry_tbl_rec   => l_tnsf_out_entry_tbl_rec
  , x_tnsf_in_entry_tbl_rec    => l_tnsf_in_entry_tbl_rec
  );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.aftercalcinfl'
                  , 'After Calc_Inflation_Adj'
                  );
  END IF;

  Insert_Inflation_Adj
  ( p_inflation_adjustment_rec => l_infl_adjustment_out_rec
  );

  -- store transfer out organization account entries
  l_index := NVL(l_tnsf_out_entry_tbl_rec.FIRST, 0);
  IF l_index > 0
  THEN
    LOOP
      IF NVL(l_tnsf_out_entry_tbl_rec(l_index).entered_cr, 0) +
         NVL(l_tnsf_out_entry_tbl_rec(l_index).entered_dr, 0)
         <> 0
      THEN
        Insert_Transfer_Entries
        ( p_tnsf_acct_entry_rec => l_tnsf_out_entry_tbl_rec(l_index)
        );
      END IF;
      EXIT WHEN l_index = l_tnsf_out_entry_tbl_rec.LAST;
      l_index := l_tnsf_out_entry_tbl_rec.NEXT(l_index);
    END LOOP;
  END IF;

  -- store transfer in organization account entries
  l_index := NVL(l_tnsf_in_entry_tbl_rec.FIRST, 0);
  IF l_index > 0
  THEN
    LOOP
      IF NVL(l_tnsf_in_entry_tbl_rec(l_index).entered_cr, 0) +
         NVL(l_tnsf_in_entry_tbl_rec(l_index).entered_dr, 0)
         <> 0
      THEN
        Insert_Transfer_Entries
        ( p_tnsf_acct_entry_rec => l_tnsf_in_entry_tbl_rec(l_index)
        );
      END IF;
      EXIT WHEN l_index = l_tnsf_in_entry_tbl_rec.LAST;
      l_index := l_tnsf_in_entry_tbl_rec.NEXT(l_index);
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Create_Inflation_Adjusted_Cost'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END Create_Inflation_Adjusted_Cost;


--========================================================================
-- PROCEDURE : Get_Acct_CCID           PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_org_id                Organization ID
--             p_inv_item_id           Inventory item ID
--             x_inv_adj_ccid          Inventory inflation account CCID
--             x_monetary_corr_ccid    Monetary correction account CCID
--             x_sales_cost_ccid       Sales cost account CCID
-- COMMENT   : This procedure return the account CCIDs.
-- EXCEPTIONS: g_acct_ccid_null_exc    Missing CCID
--========================================================================
PROCEDURE Get_Acct_CCID
( p_country_code       IN  VARCHAR2
, p_org_id             IN  NUMBER
, p_inv_item_id        IN  NUMBER
, x_inv_adj_ccid       OUT NOCOPY VARCHAR2
, x_monetary_corr_ccid OUT NOCOPY VARCHAR2
, x_sales_cost_ccid    OUT NOCOPY VARCHAR2
)
IS

l_routine CONSTANT VARCHAR2(30) := 'get_acct_ccid';

l_inv_adj_ccid       VARCHAR2(150);
l_monetary_corr_ccid VARCHAR2(150);
l_sales_cost_ccid    VARCHAR2(150);
l_err_item_code      VARCHAR2(40);
l_acct_ccid_null_exc EXCEPTION;
BEGIN

  SELECT
    Global_Attribute3
  , Global_Attribute4
  , Global_Attribute5
  INTO
    l_inv_adj_ccid
  , l_monetary_corr_ccid
  , l_sales_cost_ccid
  FROM
    MTL_SYSTEM_ITEMS
  WHERE Organization_ID                        = p_org_id
    AND Inventory_Item_ID                      = p_inv_item_id
    AND SUBSTR(GLOBAL_ATTRIBUTE_CATEGORY, 4,2) = p_country_code;

  IF  (l_inv_adj_ccid IS NULL)
     OR
      (l_monetary_corr_ccid IS NULL)
     OR
      (l_sales_cost_ccid IS NULL)
  THEN
    RAISE l_acct_ccid_null_exc;
  END IF;

  x_inv_adj_ccid       := l_inv_adj_ccid;
  x_monetary_corr_ccid := l_monetary_corr_ccid;
  x_sales_cost_ccid    := l_sales_cost_ccid;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    ,G_MODULE_HEAD || l_routine || '.nodatafound'
                    ,'Organization Id:' || p_org_id || ' Inventory Item Id:' ||
                      p_inv_item_id || ' Country Code:' || p_country_code
                    );
   END IF;
   RAISE;

  WHEN l_acct_ccid_null_exc THEN
    SELECT
      Concatenated_Segments
    INTO
      l_err_item_code
    FROM
      MTL_SYSTEM_ITEMS_KFV
    WHERE Organization_ID   = p_org_id
      AND Inventory_Item_ID = p_inv_item_id;
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_ACCT_CCID_NULL');
    FND_MESSAGE.Set_Token('ITEM', l_err_item_code);
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_CCID'
                             );
    END IF;
    RAISE g_acct_ccid_null_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_CCID'
                             );
    END IF;
    RAISE;

END Get_Acct_CCID;


--========================================================================
-- PROCEDURE : Get_Set_Of_Books_ID     PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             x_set_of_books_id       Set of books ID
-- COMMENT   : This procedure returns the set of books id.
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Set_Of_Books_ID
( p_org_id          IN         NUMBER
, x_set_of_books_id OUT NOCOPY NUMBER
)
IS
l_set_of_books_id       NUMBER;

BEGIN

  SELECT
    Set_Of_Books_ID
  INTO
    x_set_of_books_id
  FROM
    gl_sets_of_books
  , hr_organization_information
  WHERE set_of_books_id   =  org_information1
    AND upper(org_information_context) = upper('Accounting Information')
    AND organization_id   = p_org_id;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Set_Of_Books_ID'
                             );
    END IF;
    RAISE;

END Get_Set_Of_Books_ID;


--========================================================================
-- PROCEDURE : Get_Currency_Code       PRIVATE
-- PARAMETERS: p_set_of_books_id       Set of books ID
--             x_currency_code         Currency code
-- COMMENT   : This procedure returns the currency code for a set of books
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Currency_Code
( p_set_of_books_id IN         NUMBER
, x_currency_code   OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SELECT
    Currency_Code
  INTO
    x_currency_code
  FROM
    GL_SETS_OF_BOOKS
  WHERE Set_Of_Books_ID = p_set_of_books_id;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Currency_Code'
                             );
    END IF;
    RAISE;

END Get_Currency_Code;


--========================================================================
-- PROCEDURE : GL_Interface_Default    PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_org_id                Organization ID
--             p_inv_item_id           Inventory item ID
--             p_acct_period_id        Accout period id
--             p_inventory_adj_acct_cr Credit entry for inventory
--                                     inflation account
--             p_inventory_adj_acct_dr Debit entry for inventory
--                                     inflation account
--             p_monetary_corr_acct_cr Credit entry for monetary
--                                     correction account
--             p_sales_cost_acct_dr    Debit entry for sales cost account
--             p_set_of_books_id       Set of books id
--             p_currency_code         Currency code
--             p_user_category_name    User JE category name
--             p_user_source_name      User JE source name
--             x_acct_entry_tbl_rec    Account entry table record
-- COMMENT   : This procedure defaults value for GL_INTERFACE
--========================================================================
PROCEDURE GL_Interface_Default
( p_country_code          IN  VARCHAR2
, p_org_id                IN  NUMBER
, p_inv_item_id           IN  NUMBER
, p_acct_period_id        IN  NUMBER
, p_inventory_adj_acct_cr IN  NUMBER
, p_inventory_adj_acct_dr IN  NUMBER
, p_monetary_corr_acct_cr IN  NUMBER
, p_sales_cost_acct_dr    IN  NUMBER
, p_set_of_books_id       IN  NUMBER
, p_currency_code         IN  VARCHAR2
, p_user_category_name    IN  VARCHAR2
, p_user_source_name      IN  VARCHAR2
, p_accounting_date       IN  DATE
, x_acct_entry_tbl_rec    OUT NOCOPY Infl_Adj_Acct_Tbl_Rec_Type
)
IS
l_routine CONSTANT VARCHAR2(30) := 'gl_interface_default';

l_acct_entry_tbl_rec Infl_Adj_Acct_Tbl_Rec_Type;
l_inv_adj_ccid         VARCHAR2(150);
l_monetary_corr_ccid   VARCHAR2(150);
l_sales_cost_ccid      VARCHAR2(150);
l_tnsf_set_of_books_id NUMBER;
l_tnsf_currency_code   VARCHAR2(15);
l_net_inv_acct_entry   NUMBER;
l_counter              NUMBER;

-- Bug#4376862 fix (base bug#4363532 fix) : imbalance in GL_INTERFACE postings
-- To balance the Debit and Credit entries inorder to post into GL_INTERFACE
l_total_credit         NUMBER;
l_total_debit          NUMBER;
l_precision            NUMBER;
l_imbalance            NUMBER;
l_ctr_count            NUMBER;

CURSOR l_transfer_org_csr IS
  SELECT
    Transfer_Organization_ID
  , NVL(SUM(Entered_CR), 0) Entered_CR
  , NVL(SUM(Entered_DR), 0) Entered_DR
  FROM
    CST_MGD_INFL_TSF_ORG_ENTRIES
  WHERE Acct_Period_ID    = p_acct_period_id
    AND Organization_ID   = p_org_id
    AND Inventory_Item_ID = p_inv_item_id
    AND Country_Code      = p_country_code
  GROUP BY Transfer_Organization_ID;

-- Cursor to retrieve the precision of a currency code
CURSOR precision_cur(c_currency_code VARCHAR2)
IS
SELECT
  nvl(precision,0)
FROM fnd_currencies
WHERE currency_code = c_currency_code;


-- local debug vairables to use within loop
l_debug_level  NUMBER;
l_state_level  NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  Get_Acct_CCID( p_country_code       => p_country_code
               , p_org_id             => p_org_id
               , p_inv_item_id        => p_inv_item_id
               , x_inv_adj_ccid       => l_inv_adj_ccid
               , x_monetary_corr_ccid => l_monetary_corr_ccid
               , x_sales_cost_ccid    => l_sales_cost_ccid
               );

  -- Retrieve precision of a currency code
  OPEN precision_cur(p_currency_code);
  FETCH precision_cur
   INTO l_precision;
     IF precision_cur%NOTFOUND THEN
       -- a record must exist.  This scenario should not occur
       l_precision := 0;
     END IF;
  CLOSE precision_cur;

  -- Bug#4376862 fix (Base Bug#4363532 fix)
  -- intialize l_total_credit and l_total_debit
  l_total_credit := 0;
  l_total_debit  := 0;

  -- Assign local debug variables to use within loop
  l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level := FND_LOG.LEVEL_STATEMENT;

  -- FP:11i9-11i12:Bug#4369851 fix (Base Bug#4306670 fix)
  -- Inflation Adjustment account cannot be split into two
  -- components - inflation adjustment monetary and inflation   -- adjustment sales cost; since each account has to be
  -- summarized in GL_INTERFACE
  -- Therefore net inventory inflation adjustment is modified
  FOR l_counter IN 1..3
  LOOP
    l_acct_entry_tbl_rec(l_counter).status          := 'NEW';
    l_acct_entry_tbl_rec(l_counter).set_of_books_id := p_set_of_books_id;

    l_acct_entry_tbl_rec(l_counter).user_je_source_name :=
      p_user_source_name;

    l_acct_entry_tbl_rec(l_counter).user_je_category_name :=
      p_user_category_name;

    l_acct_entry_tbl_rec(l_counter).accounting_date := p_accounting_date;
    l_acct_entry_tbl_rec(l_counter).currency_code   := p_currency_code;
    l_acct_entry_tbl_rec(l_counter).date_created    := SYSDATE;

    l_acct_entry_tbl_rec(l_counter).created_by :=
      NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);

    l_acct_entry_tbl_rec(l_counter).actual_flag := 'A';

    -- ======================================================================================
    -- inv. inflation account
    -- FP:11i9-11i12:Bug#4369851 fix (base bug#4306670 fix)
    -- inflation adjustment cannot be split into two components
    -- Each account is summarized
    -- NOTE: l_net_inv_acct_entry := abs(p_inventory_adj_acct_cr) -
    -- p_inventory_adj_acct_dr
    -- Base bug#4456502 second fix: l_net_inv_acct_entry :=
    -- round(abs(p_inventory_adj_acct_cr),l_precision) -
    -- round(abs(p_inventory_adj_acct_dr),l_precision)
    -- --------------------------------------------------------------------------------------
    -- FP Bug#7346248 fix: inflation adjustment account logic modified
    -- l_net_inv_acct_entry := round(p_inventory_adj_acct_cr, l_precision) +
    -- round(p_inventory_adj_acct_dr, l_precision)
    -- if l_net_inv_acct_entry is positive then l_total_debit := abs(l_net_inv_acct_entry)
    -- if l_net_inv_acct_entry is negative then l_total_credit := abs(l_net_inv_acct_entry)
    -- ======================================================================================

    IF l_counter = 1
    THEN
      l_acct_entry_tbl_rec(l_counter).code_combination_id := l_inv_adj_ccid;

      l_net_inv_acct_entry := round(p_inventory_adj_acct_cr,l_precision) +
                              round(p_inventory_adj_acct_dr,l_precision);

      IF (l_net_inv_acct_entry > 0) THEN
        l_acct_entry_tbl_rec(l_counter).entered_dr := round(l_net_inv_acct_entry,l_precision);
        l_total_debit :=
          l_total_debit + l_acct_entry_tbl_rec(l_counter).entered_dr;
      ELSE
        l_acct_entry_tbl_rec(l_counter).entered_cr := round(ABS(l_net_inv_acct_entry),l_precision);
        l_total_credit :=
          l_total_credit + l_acct_entry_tbl_rec(l_counter).entered_cr;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.inflacct'
                      ,'Inventory Inflation Adjustment Account'
                      );

        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.infldrcr'
                      ,'Entered Dr:' || l_acct_entry_tbl_rec(l_counter).entered_dr
                      || ' Entered Cr:' || l_acct_entry_tbl_rec(l_counter).entered_cr
                      );
      END IF;

    -- ========================================================================
    -- Bug#4225409 fix:out of balance fix in GL_INTERFACE when -ve inflation
    -- index; monetary correction acct cr to be posted in entered_dr if value
    -- is -ve
    -- ========================================================================
    -- monetary account
    ELSIF l_counter = 2
    THEN
      l_acct_entry_tbl_rec(l_counter).code_combination_id :=
        l_monetary_corr_ccid;

      IF SIGN(p_monetary_corr_acct_cr) = 1 THEN
        -- value is positive
        l_acct_entry_tbl_rec(l_counter).entered_cr := round(p_monetary_corr_acct_cr,l_precision);
        l_total_credit :=
          l_total_credit + l_acct_entry_tbl_rec(l_counter).entered_cr;
      ELSE
        -- value is negative or zero
        l_acct_entry_tbl_rec(l_counter).entered_dr := round(ABS(p_monetary_corr_acct_cr),l_precision);
        l_total_debit :=
          l_total_debit + l_acct_entry_tbl_rec(l_counter).entered_dr;
      END IF;

          IF (l_state_level >= l_debug_level) THEN
            FND_LOG.string(l_state_level
                          ,G_MODULE_HEAD || l_routine || '.monacct'
                          , 'Monetary Account'
                          );

            FND_LOG.string(l_state_level
                          ,G_MODULE_HEAD || l_routine || '.mondrcr'
                          ,'Entered Cr:' || l_acct_entry_tbl_rec(l_counter).entered_cr || 'Entered Dr:' || l_acct_entry_tbl_rec(l_counter).entered_dr
                          );
          END IF;

    -- sales cost account
    -- ========================================================================
    -- Bug#4225409 fix:out of balance fix in GL_INTERFACE when -ve inflation
    -- index; sales cost acct dr to be posted in entered_cr if value
    -- is -ve
    -- If the value is positive, post it in ENTERED_CR
    -- if the value is negative, post it in ENTERED_DR
    -- ========================================================================
    ELSIF l_counter = 3
    THEN
      l_acct_entry_tbl_rec(l_counter).code_combination_id :=
        l_sales_cost_ccid;
      IF SIGN(p_sales_cost_acct_dr) = 1 THEN
        -- value is positive
        l_acct_entry_tbl_rec(l_counter).entered_cr := round(p_sales_cost_acct_dr,l_precision);
        l_total_credit :=
          l_total_credit + l_acct_entry_tbl_rec(l_counter).entered_cr;
      ELSE
        -- value is negative
        l_acct_entry_tbl_rec(l_counter).entered_dr := round(ABS(p_sales_cost_acct_dr),l_precision);
        l_total_debit :=
          l_total_debit + l_acct_entry_tbl_rec(l_counter).entered_dr;
      END IF;

          IF (l_state_level >= l_debug_level) THEN
            FND_LOG.string(l_state_level
                          ,G_MODULE_HEAD || l_routine || '.salesacct'
                          , 'Sales Cost Account'
                          );

            FND_LOG.string(l_state_level
                          ,G_MODULE_HEAD || l_routine || '.salesdrcr'
                          ,'Entered Dr:' || l_acct_entry_tbl_rec(l_counter).entered_dr || 'Entered Cr:' || l_acct_entry_tbl_rec(l_counter).entered_cr
                          );
          END IF;

    END IF;

  END LOOP;

  l_counter := 4;
  -- for transfer organizations
  -- Base Bug#4456502 second fix:l_net_inv_acct_entry := round(abs(p_inventory_adj_acct_cr),l_precision)
  -- round(abs(p_inventory_adj_acct_dr),l_precision)
  -- Bug#4376862 fix(Base bug#4363532 fix): rounding issue
  FOR l_transfer_acct IN l_transfer_org_csr
  LOOP
    Get_Acct_CCID( p_country_code       => p_country_code
                 , p_org_id             =>
                     l_transfer_acct.Transfer_Organization_ID
                 , p_inv_item_id        => p_inv_item_id
                 , x_inv_adj_ccid       => l_inv_adj_ccid
                 , x_monetary_corr_ccid => l_monetary_corr_ccid
                 , x_sales_cost_ccid    => l_sales_cost_ccid
                 );

    Get_Set_Of_Books_ID( p_org_id          =>
                           l_transfer_acct.Transfer_Organization_ID
                       , x_set_of_books_id => l_tnsf_set_of_books_id
                       );

    Get_Currency_Code( p_set_of_books_id => l_tnsf_set_of_books_id
                     , x_currency_code   => l_tnsf_currency_code
                     );

    l_acct_entry_tbl_rec(l_counter).status          := 'NEW';
    l_acct_entry_tbl_rec(l_counter).set_of_books_id :=
      l_tnsf_set_of_books_id;

    l_acct_entry_tbl_rec(l_counter).user_je_source_name :=
      p_user_source_name;

    l_acct_entry_tbl_rec(l_counter).user_je_category_name :=
      p_user_category_name;

    l_acct_entry_tbl_rec(l_counter).accounting_date := p_accounting_date;
    l_acct_entry_tbl_rec(l_counter).currency_code   :=
      l_tnsf_currency_code;

    l_acct_entry_tbl_rec(l_counter).date_created    := SYSDATE;

    l_acct_entry_tbl_rec(l_counter).created_by :=
      NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);

    l_acct_entry_tbl_rec(l_counter).actual_flag         := 'A';
    l_acct_entry_tbl_rec(l_counter).code_combination_id := l_inv_adj_ccid;

    l_net_inv_acct_entry :=
      round(ABS(l_transfer_acct.Entered_CR),l_precision) - round(ABS(l_transfer_acct.Entered_DR),l_precision);

    IF (l_net_inv_acct_entry > 0)
    THEN
      l_acct_entry_tbl_rec(l_counter).entered_cr := round(l_net_inv_acct_entry,l_precision);
      l_total_credit := l_total_credit + l_acct_entry_tbl_rec(l_counter).entered_cr;
    ELSE
      l_acct_entry_tbl_rec(l_counter).entered_dr :=
         round(ABS(l_net_inv_acct_entry),l_precision);
      l_total_debit := l_total_debit + l_acct_entry_tbl_rec(l_counter).entered_dr;
    END IF;

      IF (l_state_level >= l_debug_level) THEN
        FND_LOG.string(l_state_level
                      ,G_MODULE_HEAD || l_routine || '.transorg'
                      , 'Transfer Organization Id:' || l_transfer_acct.Transfer_Organization_ID
                      );

        FND_LOG.string(l_state_level
                      ,G_MODULE_HEAD || l_routine || '.crdr'
                      ,'Entered Cr:' || l_acct_entry_tbl_rec(l_counter).entered_cr || ' Entered Dr:' || l_acct_entry_tbl_rec(l_counter).entered_dr
                      );

      END IF;

    l_counter := l_counter + 1;

  END LOOP;

  -- =================================================================
  -- Bug#4376862 fix (Base bug#4363532 fix): balance debit and credit
  -- Perform balancing the accounts inorder to post into GL_INTERFACE
  -- =================================================================
  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  ,G_MODULE_HEAD || l_routine || '.totdrcr'
                  ,'Total Debit:' || l_total_debit || ' Total Credit:' || l_total_credit
                  );
  END IF;

  l_imbalance := l_total_debit - l_total_credit;

  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  ,G_MODULE_HEAD || l_routine || '.imbal'
                  , 'Imbalance Value:' || l_imbalance
                  );
  END IF;


  IF SIGN(l_imbalance) = 1 THEN
    -- positive, add the imbalance to credit a/c (increase the value)
    l_ctr_count := 0;
    FOR l_ctr_idx IN 1..l_counter
    LOOP
      -- set the counter to get the counter of the a/c
      l_ctr_count := l_ctr_count + 1;
      IF l_acct_entry_tbl_rec(l_ctr_idx).entered_cr IS NOT NULL THEN

        l_acct_entry_tbl_rec(l_ctr_idx).entered_cr :=
          l_acct_entry_tbl_rec(l_ctr_idx).entered_cr + l_imbalance;

        IF (l_state_level >= l_debug_level) THEN
          FND_LOG.string(l_state_level
                        ,G_MODULE_HEAD || l_routine || '.balentcr'
                        , 'Counter of the a/c:' || l_ctr_count ||
                          ' Balanced Entered Cr:' || l_acct_entry_tbl_rec(l_ctr_idx).entered_cr
                        );
        END IF;

        EXIT;
      END IF;
    END LOOP;

  ELSIF SIGN(l_imbalance) = -1 THEN
    -- set the counter to get the counter of the a/c
    l_ctr_count := 0;
    -- negative, add the imbalance to debit a/c (increase the value)
    FOR l_ctr_idx IN 1..l_counter
    LOOP
      -- set the counter to get the counter of the a/c
      l_ctr_count := l_ctr_count + 1;
      IF l_acct_entry_tbl_rec(l_ctr_idx).entered_dr IS NOT NULL THEN

        l_acct_entry_tbl_rec(l_ctr_idx).entered_dr :=
          l_acct_entry_tbl_rec(l_ctr_idx).entered_dr + ABS(l_imbalance);

        IF (l_state_level >= l_debug_level) THEN
          FND_LOG.string(l_state_level
                        ,G_MODULE_HEAD || l_routine || '.balentdr'
                        , 'Counter of the a/c:' || l_ctr_count ||
                          ' Balanced Entered Dr:' || l_acct_entry_tbl_rec(l_ctr_idx).entered_dr
                        );
        END IF;

        EXIT;
      END IF;
    END LOOP;

  END IF;

  x_acct_entry_tbl_rec := l_acct_entry_tbl_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'GL_Interface_Default'
                             );
    END IF;
    RAISE;

END GL_Interface_Default;


--========================================================================
-- PROCEDURE : Create_Journal_Entries  PRIVATE
-- PARAMETERS: p_infl_adj_acct_rec     Inflation account record
-- COMMENT   : This procedure crreates the account entry data.
--========================================================================
PROCEDURE Create_Journal_Entries
( p_infl_adj_acct_rec IN  Infl_Adj_Acct_Rec_Type
)
IS
BEGIN

  INSERT INTO
    GL_INTERFACE(
      Status
    , Set_Of_Books_ID
    , User_JE_Source_Name
    , User_JE_Category_Name
    , Accounting_Date
    , Currency_Code
    , Date_Created
    , Created_By
    , Actual_Flag
    , Entered_DR
    , Entered_CR
    , Code_Combination_ID
    )
  VALUES(
      p_infl_adj_acct_rec.Status
    , p_infl_adj_acct_rec.Set_Of_Books_ID
    , p_infl_adj_acct_rec.User_JE_Source_Name
    , p_infl_adj_acct_rec.User_JE_Category_Name
    , p_infl_adj_acct_rec.Accounting_Date
    , p_infl_adj_acct_rec.Currency_Code
    , p_infl_adj_acct_rec.Date_Created
    , p_infl_adj_acct_rec.Created_By
    , p_infl_adj_acct_rec.Actual_Flag
    , p_infl_adj_acct_rec.Entered_DR
    , p_infl_adj_acct_rec.Entered_CR
    , p_infl_adj_acct_rec.Code_Combination_ID
    );

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Journal_Entries'
                             );
    END IF;
    RAISE;

END Create_Journal_Entries;


--========================================================================
-- PROCEDURE : Create_Infl_Period_Status    PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             x_return_status         Return error if failed
-- COMMENT   : This procedure makes the inflation adjusted period status
--             to PROCESS
-- USAGE     : This procedue is used in Calculate_Adjustment at the end
--             inflation processor run to set the inflation status
-- EXCEPTIONS: g_exception1            exception description
--========================================================================
PROCEDURE Create_Infl_Period_Status
( p_org_id         IN         NUMBER
, p_acct_period_id IN         NUMBER
, x_return_status  OUT NOCOPY VARCHAR2
)
IS
l_routine  CONSTANT VARCHAR2(30) := 'create_infl_period_status';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO
    CST_MGD_INFL_ADJ_PER_STATUSES(
      Organization_ID
    , Acct_Period_ID
    , Last_Update_Date
    , Last_Updated_By
    , Creation_Date
    , Created_By
    , Last_Update_Login
    , Request_ID
    , Program_Application_ID
    , Program_ID
    , Program_Update_Date
    , STATUS
    )
  VALUES(
      p_org_id
    , p_acct_period_id
    , SYSDATE
    , NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , SYSDATE
    , NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
    , TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'))
    , TO_NUMBER(FND_PROFILE.Value('PROG_APPL_ID'))
    , TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID'))
    , SYSDATE
    , 'PROCESS'
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Infl_Period_Status'
                             );
    END IF;
    RAISE;

END Create_Infl_Period_Status;


--========================================================================
-- PROCEDURE : Update_Infl_Period_Status    PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             x_return_status         Return error if failed
-- COMMENT   : This procedure makes the inflation adjusted period status
--             to FINAL
-- USAGE     : This procedure is used in Transfer_to_GL at the end
--             to set the inflation status FINAL
-- EXCEPTIONS: g_exception1            exception description
--========================================================================
PROCEDURE Update_Infl_Period_Status
( p_org_id         IN         NUMBER
, p_acct_period_id IN         NUMBER
, x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE CST_MGD_INFL_ADJ_PER_STATUSES
    SET Status                 = 'FINAL'
      , Last_Update_Date       = SYSDATE
      , Last_Updated_By        = NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
      , Creation_Date          = SYSDATE
      , Created_By             = NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
      , Last_Update_Login      = TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
      , Request_ID             = TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'))
      , Program_Application_ID = TO_NUMBER(FND_PROFILE.Value('PROG_APPLD_ID'))
      , Program_ID             = TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID'))
      , Program_Update_Date    = SYSDATE
  WHERE organization_id = p_org_id
    AND acct_period_id  = p_acct_period_id;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Period_Status'
                             );
    END IF;
    RAISE;

END Update_Infl_Period_Status;


--========================================================================
-- PROCEDURE : Validate_Hist_Attributes PRIVATE
-- PARAMETERS: p_historical_infl_adj_rec Historical data record
--             x_return_status          Return error if failed
-- COMMENT   : This procedure validates historical data
--========================================================================
PROCEDURE Validate_Hist_Attributes
( p_historical_infl_adj_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
, x_return_status           OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate historical inflation adjustment attributes
  IF (p_historical_infl_adj_rec.country_code IS NULL)
    OR
     (LENGTH(p_historical_infl_adj_rec.country_code) <> 2)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.organization_id IS NULL)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.acct_period_id IS NULL)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.inventory_item_id IS NULL)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.begin_qty IS NULL)
--    OR
--     (p_historical_infl_adj_rec.begin_qty < 0)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.begin_cost IS NULL)
--    OR
--     (p_historical_infl_adj_rec.begin_cost < 0)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_historical_infl_adj_rec.begin_inflation_adj IS NULL)
--    OR
--     (p_historical_infl_adj_rec.begin_inflation_adj < 0)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Validate_Hist_Attributes'
                             );
    END IF;
    RAISE;

END Validate_Hist_Attributes;


--========================================================================
-- PROCEDURE : Hist_Default            PRIVATE
-- PARAMETERS: p_historical_infl_adj_rec Historical data record
--             x_historical_infl_adj_rec Historical data record
-- COMMENT   : This procedure defaults historical data
--========================================================================
PROCEDURE Hist_Default
( p_historical_infl_adj_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
, x_historical_infl_adj_rec OUT NOCOPY
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
)
IS
l_historical_infl_adj_rec
  CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type;
BEGIN

  l_historical_infl_adj_rec := p_historical_infl_adj_rec;

  IF (l_historical_infl_adj_rec.last_update_date IS NULL)
  THEN
    l_historical_infl_adj_rec.last_update_date := SYSDATE;
  END IF;

  IF (l_historical_infl_adj_rec.last_updated_by IS NULL)
  THEN
    l_historical_infl_adj_rec.last_updated_by :=
      NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);
  END IF;

  IF (l_historical_infl_adj_rec.creation_date IS NULL)
  THEN
    l_historical_infl_adj_rec.creation_date := SYSDATE;
  END IF;

  IF (l_historical_infl_adj_rec.created_by IS NULL)
  THEN
    l_historical_infl_adj_rec.created_by :=
      NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0);
  END IF;

  IF (l_historical_infl_adj_rec.last_update_login IS NULL)
  THEN
    l_historical_infl_adj_rec.last_update_login :=
      TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'));
  END IF;

  IF (l_historical_infl_adj_rec.request_id IS NULL)
  THEN
    l_historical_infl_adj_rec.request_id :=
      TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'));
  END IF;

  IF (l_historical_infl_adj_rec.program_application_id IS NULL)
  THEN
    l_historical_infl_adj_rec.program_application_id :=
      TO_NUMBER(FND_PROFILE.Value('PROG_APPL_ID'));
  END IF;

  IF (l_historical_infl_adj_rec.program_id IS NULL)
  THEN
    l_historical_infl_adj_rec.program_id :=
      TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID'));
  END IF;

  IF (l_historical_infl_adj_rec.program_update_date IS NULL)
  THEN
    l_historical_infl_adj_rec.program_update_date := SYSDATE;
  END IF;

  l_historical_infl_adj_rec.purchase_qty          := NULL;
  l_historical_infl_adj_rec.purchase_cost         := NULL;
  l_historical_infl_adj_rec.actual_qty            :=
  l_historical_infl_adj_rec.begin_qty;
  l_historical_infl_adj_rec.actual_cost           :=
  l_historical_infl_adj_rec.begin_cost;
  l_historical_infl_adj_rec.actual_inflation_adj  :=
  l_historical_infl_adj_rec.begin_inflation_adj;
  l_historical_infl_adj_rec.issue_qty             := 0;
  l_historical_infl_adj_rec.issue_cost            := 0;
  l_historical_infl_adj_rec.issue_inflation_adj   := 0;
  l_historical_infl_adj_rec.inventory_adj_acct_cr := 0;
  l_historical_infl_adj_rec.inventory_adj_acct_dr := 0;
  l_historical_infl_adj_rec.monetary_corr_acct_cr := 0;
  l_historical_infl_adj_rec.sales_cost_acct_dr    := 0;
  l_historical_infl_adj_rec.historical_flag       := 'Y';

  x_historical_infl_adj_rec := l_historical_infl_adj_rec;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Hist_Default'
                             );
    END IF;
    RAISE;

END Hist_Default;


--========================================================================
-- PROCEDURE : Get_Period_End_Avg_Cost PRIVATE
-- PARAMETERS: p_acct_period_id        Account period ID
--             p_org_id                Organization ID
--             p_inv_item_id           Inventory item ID
--             p_cost_group_id         Cost Group Id
--             x_period_end_item_avg_cost Period end item unit average
--                                        cost
-- COMMENT   : This procedure returns period end item unit average cost.
-- cost group id NVL syntax added to support the inventory master book rpt
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Period_End_Avg_Cost
( p_acct_period_id           IN  NUMBER
, p_org_id                   IN  NUMBER
, p_inv_item_id              IN  NUMBER
, p_cost_group_id            IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_period_end_item_avg_cost OUT NOCOPY NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_period_end_avg_cost';

  -- cursor to retrieve period end unit cost from view
  CURSOR period_end_unit_cost_cursor(c_org_id  NUMBER
                                    ,c_acct_period_id NUMBER
                                    ,c_inv_item_id    NUMBER
                                    ,c_cost_group_id  CST_COST_GROUPS.cost_group_id%TYPE
                                    )
  IS
  SELECT
    SUM(Period_End_Unit_Cost)
  , DECODE(SUM(NVL(ABS(Period_End_Quantity), 1) * Period_End_Unit_Cost), 0, SUM(Period_End_Unit_Cost)/COUNT(*), SUM(NVL(ABS(Period_End_Quantity), 1) * Period_End_Unit_Cost)) /
  DECODE(SUM(NVL(ABS(Period_End_Quantity), 1)), 0, 1, SUM(NVL(ABS(Period_End_Quantity), 1)))
   FROM (
	SELECT  rollback_quantity period_end_quantity,
		decode(rollback_quantity,0,0,rollback_value/rollback_quantity) period_end_unit_cost
	  FROM    cst_period_close_summary
	  WHERE Organization_ID   = c_org_id
    	   AND Acct_Period_ID    = c_acct_period_id
    	   AND Inventory_Item_ID = c_inv_item_id
    	   AND Cost_Group_ID     = NVL(c_cost_group_id,Cost_Group_ID)
	UNION ALL
	SELECT  period_end_quantity, period_end_unit_cost
	  FROM    mtl_per_close_dtls
	  WHERE Organization_ID   = c_org_id
    	  AND Acct_Period_ID    = c_acct_period_id
    	  AND Inventory_Item_ID = c_inv_item_id
    	  AND Cost_Group_ID     = NVL(c_cost_group_id,Cost_Group_ID)
	);

l_sum_per_end_unit_cost    NUMBER;
l_nd_per_end_cost_exc      EXCEPTION;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Retrieve Period End Unit Cost
  OPEN period_end_unit_cost_cursor(p_org_id
                                  ,p_acct_period_id
                                  ,p_inv_item_id
                                  ,p_cost_group_id
                                  );
  FETCH period_end_unit_cost_cursor
   INTO
    l_sum_per_end_unit_cost
  , x_period_end_item_avg_cost;

  CLOSE period_end_unit_cost_cursor;

  IF l_sum_per_end_unit_cost IS NULL
  THEN
    RAISE l_nd_per_end_cost_exc;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN l_nd_per_end_cost_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_UNIT_COST_NULL');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Period_End_Avg_Cost'
                             );
    END IF;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Period_End_Avg_Cost'
                             );
    END IF;
    RAISE;

END Get_Period_End_Avg_Cost;


END CST_MGD_INFL_ADJUSTMENT_PVT;

/
