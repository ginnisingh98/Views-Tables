--------------------------------------------------------
--  DDL for Package Body CST_MGD_INFL_ADJUSTMENT_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_INFL_ADJUSTMENT_RPT" AS
/* $Header: CSTRIADB.pls 120.3 2006/02/15 05:10:07 vmutyala noship $ */

--===================
-- TYPES
--===================
TYPE Report_Rec_Type IS RECORD
( organization_id        NUMBER
, inventory_item_id      NUMBER
, txn_date               DATE
, txn_type               VARCHAR2(30)
, txn_ini_qty            NUMBER
, txn_ini_unit_cost      NUMBER
, txn_ini_h_total_cost   NUMBER
, txn_ini_adj_total_cost NUMBER
, txn_qty                NUMBER
, txn_unit_cost          NUMBER
, txn_h_total_cost       NUMBER
, txn_adj_total_cost     NUMBER
, txn_fnl_qty            NUMBER
, txn_fnl_unit_cost      NUMBER
, txn_fnl_h_total_cost   NUMBER
, txn_fnl_adj_total_cost NUMBER
, creation_date          DATE
, txn_id                 NUMBER
);

TYPE Report_Tbl_Rec_Type IS TABLE OF Report_Rec_Type
INDEX BY BINARY_INTEGER;

--================================
-- PRIVATE CONSTANTS AND VARIABLES
--================================
G_MODULE_HEAD CONSTANT VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

--===================
-- PRIVATE PROCEDURES
--===================

--=======================================================================
-- PROCEDURE : Get_valid_cost_group    PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             x_cost_group_id       valid cost group id
-- COMMENT   : Procedure to get the valid cost group
--========================================================================
PROCEDURE Get_valid_cost_group
( p_org_id           IN  NUMBER
 ,x_cost_group_id    IN OUT NOCOPY CST_COST_GROUPS.cost_group_id%TYPE
)
IS

-- get the default cost group
CURSOR c_default_cost_group_cur IS
  SELECT
    default_cost_group_id
   FROM MTL_PARAMETERS
  WHERE organization_id = p_org_id;

BEGIN

  -- Get the default cost group
  OPEN c_default_cost_group_cur;

  FETCH c_default_cost_group_cur
   INTO x_cost_group_id;

  CLOSE c_default_cost_group_cur;

END;

--=======================================================================
-- PROCEDURE : Get_Previous_Acct_Period    PRIVATE
-- PARAMETERS: p_organization_id           Organization ID
--             p_acct_period_id            Accounting Period ID
--             x_prev_acct_period_id       Previous Accounting Period ID
--             x_prev_sch_close_date       Previous schedule close date
-- COMMENT   : Procedure to get the previous accounting period
--========================================================================
PROCEDURE Get_Previous_Acct_Period
( p_organization_id           IN  NUMBER
, p_period_start_date         IN  DATE
, x_prev_acct_period_id       OUT NOCOPY NUMBER
, x_prev_sch_close_date       OUT NOCOPY DATE
)
IS
-- Cursor to obtain previous accounting period Id
CURSOR previous_acct_period_cur( c_period_start_date  DATE
                               , c_organization_id    NUMBER
                               )
IS
  SELECT
    acct_period_id
  , schedule_close_date
  FROM
    ORG_ACCT_PERIODS
  WHERE trunc(period_start_date) < c_period_start_date
    AND organization_id          = c_organization_id
  ORDER BY
    period_start_date DESC;

BEGIN

  OPEN previous_acct_period_cur( p_period_start_date
                               , p_organization_id
                               );

  FETCH previous_acct_period_cur
   INTO x_prev_acct_period_id
       ,x_prev_sch_close_date;

  CLOSE previous_acct_period_cur;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;

END Get_Previous_Acct_period;

--========================================================================
-- PROCEDURE : Insert_Rpt_Data         PRIVATE
-- PARAMETERS: p_rpt_item_rec          Kardex report data for one row
-- COMMENT   :
-- EXCEPTIONS: OTHERS
-- HISTORY: NVL syntax added by vjavli
--          part of bug#1474753 fix
--========================================================================
PROCEDURE Insert_Rpt_Data
( p_rpt_item_rec    IN  Report_Rec_Type
)
IS
BEGIN
  INSERT INTO
    CST_MGD_INFL_ADJ_KARDEX_DATA(
      ORGANIZATION_ID
    , INVENTORY_ITEM_ID
    , TXN_DATE
    , TXN_TYPE
    , TXN_INI_QTY
    , TXN_INI_UNIT_COST
    , TXN_INI_H_TOTAL_COST
    , TXN_INI_ADJ_TOTAL_COST
    , TXN_QTY
    , TXN_UNIT_COST
    , TXN_H_TOTAL_COST
    , TXN_ADJ_TOTAL_COST
    , TXN_FNL_QTY
    , TXN_FNL_UNIT_COST
    , TXN_FNL_H_TOTAL_COST
    , TXN_FNL_ADJ_TOTAL_COST
    , CREATION_DATE
    , TRANSACTION_ID
    )
  VALUES(
      p_rpt_item_rec.organization_id
    , p_rpt_item_rec.inventory_item_id
    , p_rpt_item_rec.txn_date
    , p_rpt_item_rec.txn_type
    , NVL(p_rpt_item_rec.txn_ini_qty,0)
    , NVL(p_rpt_item_rec.txn_ini_unit_cost,0)
    , NVL(p_rpt_item_rec.txn_ini_h_total_cost,0)
    , NVL(p_rpt_item_rec.txn_ini_adj_total_cost,0)
    , p_rpt_item_rec.txn_qty
    , p_rpt_item_rec.txn_unit_cost
    , p_rpt_item_rec.txn_h_total_cost
    , p_rpt_item_rec.txn_adj_total_cost
    , NVL(p_rpt_item_rec.txn_fnl_qty,0)
    , NVL(p_rpt_item_rec.txn_fnl_unit_cost,0)
    , NVL(p_rpt_item_rec.txn_fnl_h_total_cost,0)
    , NVL(p_rpt_item_rec.txn_fnl_adj_total_cost,0)
    , p_rpt_item_rec.creation_date
    , p_rpt_item_rec.txn_id
    );

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Insert_Rpt_Data'
                             );
    END IF;
    RAISE;

END Insert_Rpt_Data;


--========================================================================
-- PROCEDURE : Get_Acct_Period_ID      PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_rpt_from_date         Report start date
--             P_rpt_to_date           Report end date
--             x_rpt_from_acct_per_id  Report start account period ID
--             x_rpt_to_acct_per_id    Report end account period ID
-- COMMENT   : Get the account period IDs for user defined reporting
--             period
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Acct_Period_ID
( p_org_id               IN  NUMBER
, p_rpt_from_date        IN  DATE
, P_rpt_to_date          IN  DATE
, x_rpt_from_acct_per_id OUT NOCOPY NUMBER
, x_rpt_to_acct_per_id   OUT NOCOPY NUMBER
)
IS
l_rpt_from_acct_per_id NUMBER;
l_rpt_to_acct_per_id   NUMBER;
BEGIN
  -- get account period id for report from date
  SELECT
    acct_period_id
  INTO
    x_rpt_from_acct_per_id
  FROM
    ORG_ACCT_PERIODS oap
  WHERE oap.organization_id = p_org_id
    AND oap.period_start_date <= p_rpt_from_date
    AND oap.schedule_close_date >= p_rpt_from_date
    AND oap.open_flag       = 'N'
    AND oap.period_close_date IS NOT NULL;

  -- get account period id for report to date
  SELECT
    acct_period_id
  INTO
    x_rpt_to_acct_per_id
  FROM
    ORG_ACCT_PERIODS oap
  WHERE oap.organization_id = p_org_id
    AND oap.period_start_date <= p_rpt_to_date
    AND oap.schedule_close_date >= p_rpt_to_date
    AND oap.open_flag       = 'N'
    AND oap.period_close_date IS NOT NULL;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_ND_ACCT_PER_ID');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID'
                             );
    END IF;
    RAISE ;


  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID'
                             );
    END IF;
    RAISE;

END Get_Acct_Period_ID;


--========================================================================
-- PROCEDURE : Get_Unit_Infl_Adj_Cost  PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             p_item_id               Inventory item ID
--             x_unit_infl_adj         Inventory item period end unit
--                                     inflation adjusted cost
--           : x_init_qty              Period begin quantity
-- COMMENT   : Retrieve item unit inflation adjusted cost and begin
--             quantity
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Unit_Infl_Adj_Cost
( p_org_id             IN  NUMBER
, p_acct_period_id     IN  NUMBER
, p_item_id            IN  NUMBER
, x_unit_infl_adj      OUT NOCOPY NUMBER
, x_init_qty           OUT NOCOPY NUMBER
)
IS
l_final_infl_adj NUMBER;
l_final_qty      NUMBER;
BEGIN

  SELECT
    Begin_Qty
  , NVL((Actual_Inflation_Adj - Issue_Inflation_Adj), 0)
  , NVL((Actual_Qty - Issue_Qty), 0)
  INTO
    x_init_qty
  , l_final_infl_adj
  , l_final_qty
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS
  WHERE Organization_ID   = p_org_id
    AND Acct_Period_ID    = p_acct_period_id
    AND Inventory_Item_ID = p_item_id;

  IF l_final_qty = 0
  THEN
    x_unit_infl_adj := 0;
  ELSE
    x_unit_infl_adj := l_final_infl_adj/l_final_qty;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Unit_Infl_Adj_Cost'
                             );
    END IF;
    RAISE;

END Get_Unit_Infl_Adj_Cost;


--========================================================================
-- PROCEDURE : Get_Txn_Type            PRIVATE
-- PARAMETERS: p_txn_type_id           Transaction type ID
--             x_txn_type_name         Transaction type name
-- COMMENT   : Retrieve transaction type name from ID
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Txn_Type
( p_txn_type_id   IN  NUMBER
, x_txn_type_name OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SELECT
    Transaction_Type_Name
  INTO
    x_txn_type_name
  FROM
    MTL_TRANSACTION_TYPES
  WHERE Transaction_Type_ID = p_txn_type_id
    AND NVL(Disable_Date, SYSDATE + 1) > SYSDATE;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Txn_Type'
                             );
    END IF;
    RAISE;

END Get_Txn_Type;


--========================================================================
-- PROCEDURE : Get_Offset_Qty         PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_item_id               Inventory item ID
--             p_from_acct_per_id      Report start account period ID
--             p_rpt_from_date         Report start date
--             p_cost_group_id         Valid Cost Group ID
--             x_off_set_qty           Amount needed to off set begin
--                                     quantity
-- COMMENT   : If user wants to create report from a date that does not
--             coincide with the account period start date. The initial
--             quantity needs to be off set by this amount.
--             Exclude Sub inventory transactions transaction action id 2
--             Bug#2912818 fix: Exclude consigned transaction
--             nvl(owning_tp_type,2) <> 1 added
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Offset_Qty
( p_org_id           IN  NUMBER
, p_item_id          IN  NUMBER
, p_from_acct_per_id IN  NUMBER
, p_rpt_from_date    IN  DATE
, p_cost_group_id    IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_offset_qty       OUT NOCOPY NUMBER
)
IS
BEGIN

  SELECT
    NVL(SUM(Primary_Quantity), 0)
  INTO
    x_offset_qty
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE Organization_ID   = p_org_id
    AND Inventory_Item_ID = p_item_id
    AND Acct_Period_ID    = p_from_acct_per_id
    AND transaction_action_id <> 2
    AND Transaction_Date  < p_rpt_from_date
    AND Cost_Group_ID     = p_cost_group_id
    AND nvl(owning_tp_type,2) <> 1;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_offset_qty := 0;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Offset_Qty'
                             );
    END IF;
    RAISE;

END Get_Offset_Qty;


--========================================================================
-- PROCEDURE : Get_Item_Txn_Info       PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_item_id               Inventory item ID
--             p_acct_period_id        Mfg accounting period ID
--             p_per_first_txn_date    First transaction date for
--                                     reporting.
--             p_per_last_txn_date     Last transaction date for
--                                     reporting.
--
--             p_item_prev_cost        previous period item cost
--             removed: p_item_unit_cost Inventory item unit average cost
--
--             p_item_init_qty         Inventory item period begin
--                                     quantity
--             p_item_unit_infl_adj    Inventory item period end unit
--                                     inflation adjusted cost
--             p_offset_qty            Offset initial quantity for first
--                                     reporting period.
--             p_cost_group_id         valid cost group id
--             x_rpt_item_tbl_rec      Report data record
-- COMMENT   : Builds data for one row
--             exclude sub inventory transactions transaction action id 2
--             Bug#2912818 fix: Exclude consigned inventory transaction
--             nvl(owning_tp_type,2) <> 1 added
-- EXCEPTION : l_txn_cost_exc          Missing transaction costs.
--========================================================================
PROCEDURE Get_Item_Txn_Info
( p_org_id             IN  NUMBER
, p_item_id            IN  NUMBER
, p_acct_period_id     IN  NUMBER
, p_per_first_txn_date IN  DATE
, p_per_last_txn_date  IN  DATE
, p_item_prev_cost     IN  NUMBER
, p_item_init_qty      IN  NUMBER
, p_item_init_infl     IN  NUMBER
, p_item_unit_infl_adj IN  NUMBER
, p_offset_qty         IN  NUMBER
, p_cost_group_id      IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_rpt_item_tbl_rec   OUT NOCOPY Report_Tbl_Rec_Type
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_item_txn_info';

l_rpt_item_tbl_rec    Report_Tbl_Rec_Type;
l_txn_init_qty        NUMBER;
l_txn_init_infl       NUMBER;
l_prev_acct_period_id NUMBER;
l_prev_sch_close_date DATE;
l_index               BINARY_INTEGER := 1;
l_begin_unit_cost     NUMBER;
l_txn_cost_exc        EXCEPTION;
CURSOR l_item_txn_csr IS
  SELECT
    Transaction_ID
  , Transaction_Type_ID
  , Transaction_Date
  , Primary_Quantity
  , Actual_Cost
  , Prior_Cost
  , New_Cost
  , Transfer_Organization_ID
  , transaction_source_type_id
  , transaction_action_id
  , creation_date
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE Organization_ID   = p_org_id
    AND Inventory_Item_ID = p_item_id
    AND Acct_Period_ID    = p_acct_period_id
    AND transaction_action_id <> 2
    AND Transaction_Date  BETWEEN p_per_first_txn_date
                              AND p_per_last_txn_date
    AND Primary_Quantity <> 0
    AND Cost_Group_ID     = p_cost_group_id
    AND nvl(owning_tp_type,2) <> 1
  ORDER BY
    TRUNC(Transaction_Date)
  , creation_date
  , transaction_id;

-- local debug variables to use within loop
l_debug_level NUMBER;
l_state_level NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine || '.begin'
                  , l_routine || '<'
                  );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.acctpd'
                  , 'Account Period Id:' || p_acct_period_id
                  );
  END IF;

  l_txn_init_qty  := p_item_init_qty - p_offset_qty;
  l_txn_init_infl := p_item_init_infl;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.txniniinfl'
                  , 'Txn initial inflation:' || l_txn_init_infl ||
                    ' ' || 'Txn initial inflation cost:' || p_item_unit_infl_adj
                  );
  END IF;

  -- Assign local debug variables to use within loop
  l_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level  := FND_LOG.LEVEL_STATEMENT;

  FOR l_item_txn_info IN l_item_txn_csr
  LOOP

    IF (l_item_txn_info.Actual_Cost IS NULL)
    THEN
      RAISE l_txn_cost_exc;
    END IF;

    l_rpt_item_tbl_rec(l_index).organization_id        := p_org_id;
    l_rpt_item_tbl_rec(l_index).inventory_item_id      := p_item_id;
    l_rpt_item_tbl_rec(l_index).txn_date               :=
      l_item_txn_info.Transaction_Date;

    --Bug 4086030 transaction id and creation date are added
    l_rpt_item_tbl_rec(l_index).txn_id                 := l_item_txn_info.transaction_id;
    l_rpt_item_tbl_rec(l_index).creation_date          := l_item_txn_info.creation_date;
    Get_Txn_Type
    ( p_txn_type_id   => l_item_txn_info.Transaction_Type_ID
    , x_txn_type_name => l_rpt_item_tbl_rec(l_index).txn_type
    );

    -- ==================================================================
    -- Beginning Inventory Calculation
    -- ==================================================================
    l_rpt_item_tbl_rec(l_index).txn_ini_qty            := l_txn_init_qty;
    l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost      :=
      l_item_txn_info.Prior_Cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty *
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost := l_txn_init_infl;

    -- ======================================================================
    -- Transaction: Calculation
    -- ======================================================================
      l_rpt_item_tbl_rec(l_index).txn_qty := l_item_txn_info.Primary_Quantity;

    -- Bug#3850750 fix: Average Cost Update Transactions
    IF l_item_txn_info.transaction_source_type_id = 13 AND
       l_item_txn_info.transaction_action_id = 24 THEN
      -- Transaction Unit Cost should be delta equal to new cost - prior cost
      l_rpt_item_tbl_rec(l_index).txn_unit_cost :=
        l_item_txn_info.New_Cost - l_item_txn_info.Prior_Cost;
    ELSE
    -- All other transactions
      l_rpt_item_tbl_rec(l_index).txn_unit_cost          :=
      l_item_txn_info.Actual_Cost;
    END IF;

    l_rpt_item_tbl_rec(l_index).txn_h_total_cost       :=
      l_rpt_item_tbl_rec(l_index).txn_qty *
      l_rpt_item_tbl_rec(l_index).txn_unit_cost;

    -- ======================================================================
    -- Transaction Total Inflation Cost
    -- bug#2862030 fix: calculation logic change for transaction
    -- adjustment total cost
    -- bug#2919777 fix: calculatin logic applies only to issues
    -- For receipts, the old logic holds good since inflation happens
    -- only for issues and NOT for receipts
    --
    -- Bug#3878129 fix: No inflation calculation for PO Receipt correction
    -- Bug#3927188 fix: No inflation calculation for SO Pick Release txns
    -- if the transaction is an internal transfer
    -- If the transaction is outbound of LE, then inflation will be calculated
    -- ======================================================================
    IF l_rpt_item_tbl_rec(l_index).txn_qty < 0 	THEN
    -- Process issues

      -- =========================================
      -- Check for PO Receipt delivery adjustments
      -- Bug3878129 fix: PO Receipt correction
      -- =========================================
      IF l_item_txn_info.transaction_source_type_id = 1 AND
         l_item_txn_info.transaction_action_id = 29 THEN
        l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     := 0;

      ELSIF l_item_txn_info.transaction_source_type_id = 2 AND
         l_item_txn_info.transaction_action_id = 28 THEN
      -- ===============================================================
      -- Check for Sales Order Staging transfer
      -- Bug#3927188 fix: SO Pick Release txn with an internal transfer
      -- ===============================================================
        l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     := 0;

      ELSIF l_item_txn_info.transaction_source_type_id = 13 AND
            l_item_txn_info.transaction_action_id = 5 THEN
      -- ===============================================================
      -- Check for VMI Planning Transfer Issues
      -- Bug#3862228 fix: VMI Planning Transfers - inflation adj is 0
      -- ===============================================================
        l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     := 0;
      ELSE
        l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     :=
          l_item_txn_info.Primary_Quantity * p_item_unit_infl_adj;
      END IF;

    ELSE
    -- receipts
      l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     := 0;
    END IF;

    -- ====================================================================
    -- Final Inventory Calculation
    -- Bug#2862030 fix: final adjustment cost is initial adjustment cost
    -- PLUS transaction adjustment cost
    -- Old logic: txn_fnl_qty * p_item_unit_infl_adj
    -- ====================================================================
    IF l_item_txn_info.transaction_source_type_id = 13 AND
       l_item_txn_info.transaction_action_id = 24 THEN
      -- Bug#3850750 fix: Transaction Qty of Average Cost Update txns
      -- Do not add transaction qty of average cost update transactions
      -- since the cost is updated on the inventory balance quantity
      l_rpt_item_tbl_rec(l_index).txn_fnl_qty   :=
        l_rpt_item_tbl_rec(l_index).txn_ini_qty;
    ELSIF l_item_txn_info.transaction_source_type_id = 13 AND
          l_item_txn_info.transaction_action_id = 5 THEN
      -- Bug#3862228 fix: VMI Planning transfers to be excluded
      -- Do not add transaction qty of VMI planning transfers
      l_rpt_item_tbl_rec(l_index).txn_fnl_qty   :=
        l_rpt_item_tbl_rec(l_index).txn_ini_qty;
    ELSE
      -- All other transactions
      l_rpt_item_tbl_rec(l_index).txn_fnl_qty  :=
        l_rpt_item_tbl_rec(l_index).txn_ini_qty +
        l_item_txn_info.Primary_Quantity;
    END IF;

    l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost      :=
      l_item_txn_info.New_Cost;
    l_rpt_item_tbl_rec(l_index).txn_fnl_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_fnl_qty *
      l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost;

    IF ((l_item_txn_info.Primary_Quantity > 0)
        AND
       (l_item_txn_info.Transfer_Organization_ID IS NULL))
       OR
       (l_item_txn_info.Transfer_Organization_ID = p_org_id)
    THEN
      l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost;
    ELSE
      l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost +
      l_rpt_item_tbl_rec(l_index).txn_adj_total_cost;
    END IF;

    l_txn_init_qty  := l_rpt_item_tbl_rec(l_index).txn_fnl_qty;
    l_txn_init_infl := l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost;

  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.itemtxninfo'
                  , '*** Item Txn Info *** '
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.itemtxndate'
                  , 'Item Id:' || l_rpt_item_tbl_rec(l_index).inventory_item_id
                  || ' Transaction Date:' || l_rpt_item_tbl_rec(l_index).txn_date
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.inicostdtls1'
                  , 'Initial cost details:' || 'initial qty:'
                    || l_rpt_item_tbl_rec(l_index).txn_ini_qty || ' '
                    || 'unit cost:'
                    || l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.inicostdtls2'
                  , 'historical total cost:' || l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost || ' ' || 'adj total cost:' || l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.txncostdtls1'
                  , 'Transaction cost details:' || 'trn qty:' || l_rpt_item_tbl_rec(l_index).txn_qty || ' ' || 'unit cost:' || l_rpt_item_tbl_rec(l_index).txn_unit_cost
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.txncostdtls2'
                  , 'historical total cost:' || l_rpt_item_tbl_rec(l_index).txn_h_total_cost || ' ' || 'adj total cost:' || l_rpt_item_tbl_rec(l_index).txn_adj_total_cost
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.fnlcostdtls1'
                  , 'Final cost details:' || 'final qty:' || l_rpt_item_tbl_rec(l_index).txn_fnl_qty || ' ' || 'unit cost:' || l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost
                  );

    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.fnlcostdtls2'
                  , 'historical total cost:' || l_rpt_item_tbl_rec(l_index).txn_fnl_h_total_cost || ' ' || 'adj total cost:' || l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost
                  );

  END IF;

    l_index        := l_index + 1;
  END LOOP;

  IF NVL(l_rpt_item_tbl_rec.FIRST, 0) = 0
  THEN

    l_rpt_item_tbl_rec(l_index).organization_id        := p_org_id;
    l_rpt_item_tbl_rec(l_index).inventory_item_id      := p_item_id;
    l_rpt_item_tbl_rec(l_index).txn_ini_qty            := l_txn_init_qty;
    l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost      := p_item_prev_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty *
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost := p_item_init_infl;
    l_rpt_item_tbl_rec(l_index).txn_fnl_qty            :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty;
    l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost      := p_item_prev_cost;
    l_rpt_item_tbl_rec(l_index).txn_fnl_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost;
    l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost;
  END IF;

  x_rpt_item_tbl_rec := l_rpt_item_tbl_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN l_txn_cost_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_UNIT_COST_NULL');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Item_Txn_Info'
                             );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Item_Txn_Info'
                             );
    END IF;
    RAISE;

END Get_Item_Txn_Info;


--========================================================================
-- PROCEDURE : Create_Infl_Adj_Rpt     PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_item_from_code        Report start item code
--             p_item_to_code          Report end item code
--             p_rpt_from_date         Report start date
--             p_rpt_to_date           Report end date
-- COMMENT   : Main procedure called by Kardex report
--========================================================================
PROCEDURE Create_Infl_Adj_Rpt
( p_org_id         IN  NUMBER
, p_item_from_code IN  VARCHAR2 := NULL
, p_item_to_code   IN  VARCHAR2 := NULL
, p_rpt_from_date  IN  VARCHAR2
, p_rpt_to_date    IN  VARCHAR2
)
IS
l_routine CONSTANT VARCHAR2(30) := 'create_infl_adj_rpt';

l_rpt_item_tbl_rec     Report_Tbl_Rec_Type;
l_item_id              NUMBER;
l_item_unit_cost       NUMBER;
l_begin_unit_cost      NUMBER;
l_acct_period_id       NUMBER;
l_rpt_from_acct_per_id NUMBER;
l_rpt_to_acct_per_id   NUMBER;
l_final_infl_adj       NUMBER;
l_final_qty            NUMBER;
l_purchase_qty         NUMBER;
l_unit_infl_adj        NUMBER;
l_per_begin_qty        NUMBER;
l_begin_infl_adj       NUMBER;
l_offset_qty           NUMBER;
l_per_first_txn_date   DATE;
l_per_last_txn_date    DATE;
l_period_start_date    DATE;
l_period_schedule_close_date    DATE;
l_index                BINARY_INTEGER;
l_cost_group_id        CST_COST_GROUPS.cost_group_id%TYPE;

-- Previous Period variables
l_prev_acct_period_id    NUMBER;
l_prev_sch_close_date    DATE;
l_previous_qty           NUMBER;
l_previous_cost          NUMBER;
l_previous_inflation_adj NUMBER;
l_previous_unit_cost     NUMBER;

-- Date range variables for mid night settings
l_rpt_date_from        DATE;
l_rpt_date_to          DATE;

-- Date range variables for accounting period comparison
l_date_from            DATE;
l_date_to              DATE;

CURSOR l_item_range_csr( c_org_id               NUMBER
                       , c_item_from_code       VARCHAR2
                       , c_item_to_code         VARCHAR2
                       , c_rpt_from_acct_per_id NUMBER
                       , c_rpt_to_acct_per_id   NUMBER
                       )
 IS
  SELECT
    INFL.Inventory_Item_ID
  , INFL.Acct_Period_ID
  , NVL(INFL.Begin_Qty,0)
  , NVL(INFL.Begin_Inflation_Adj,0)
  , (NVL(INFL.Actual_Inflation_Adj,0) - ABS(NVL(INFL.Issue_Inflation_Adj,0)))
  , (NVL(INFL.Actual_Qty,0) - ABS(NVL(INFL.Issue_Qty,0)))
  , PER.Schedule_Close_Date
  , PER.Period_Start_Date
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS  INFL
  , MTL_SYSTEM_ITEMS_B_KFV       MSI
  , ORG_ACCT_PERIODS             PER
  WHERE INFL.Organization_ID   = c_org_id
    AND MSI.Organization_ID    = c_org_id
    AND PER.Organization_ID    = c_org_id
    AND INFL.Inventory_Item_ID = MSI.Inventory_Item_ID
    AND MSI.Concatenated_Segments BETWEEN c_item_from_code
                                      AND c_item_to_code
    AND INFL.Acct_Period_ID BETWEEN c_rpt_from_acct_per_id
                                AND c_rpt_to_acct_per_id
    AND INFL.Acct_Period_ID    = PER.Acct_Period_ID
    AND PER.Open_Flag          = 'N'
    AND PER.PERIOD_CLOSE_DATE IS NOT NULL
  ORDER BY INFL.Acct_Period_ID;


CURSOR l_item_all_csr( c_org_id                NUMBER
                     , c_rpt_from_acct_per_id  NUMBER
                     , c_rpt_to_acct_per_id    NUMBER
                     )
IS
  SELECT
    INFL.Inventory_Item_ID
  , INFL.Acct_Period_ID
  , NVL(INFL.Begin_Qty,0)
  , NVL(INFL.Begin_Inflation_Adj,0)
  , (NVL(INFL.Actual_Inflation_Adj,0) - ABS(NVL(INFL.Issue_Inflation_Adj,0)))
  , (NVL(INFL.Actual_Qty,0) - ABS(NVL(INFL.Issue_Qty,0)))
  , PER.Schedule_Close_Date
  , PER.Period_Start_Date
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS  INFL
  , MTL_SYSTEM_ITEMS_B           MSI
  , ORG_ACCT_PERIODS             PER
  WHERE INFL.Organization_ID   = c_org_id
    AND MSI.Organization_ID    = c_org_id
    AND PER.Organization_ID    = c_org_id
    AND INFL.Inventory_Item_ID = MSI.Inventory_Item_ID
    AND INFL.Acct_Period_ID BETWEEN c_rpt_from_acct_per_id
                                AND c_rpt_to_acct_per_id
    AND INFL.Acct_Period_ID    = PER.Acct_Period_ID
    AND PER.Open_Flag          = 'N'
    AND PER.PERIOD_CLOSE_DATE IS NOT NULL
  ORDER BY INFL.Acct_Period_ID;
BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    ,G_MODULE_HEAD || l_routine || '.begin'
                    , l_routine || '<'
                    );
    END IF;

  DELETE FROM CST_MGD_INFL_ADJ_KARDEX_DATA;

  -- From Date is set at midnight for the day
  l_rpt_date_from := TRUNC(FND_DATE.canonical_to_date(p_rpt_from_date));
  -- To date set to mid night 23:59:59
  l_rpt_date_to   := TRUNC(FND_DATE.canonical_to_date(p_rpt_to_date)) + (86399/86400);

  -- Date range for accounting periods
  -- used to get the accounting periods
  l_date_from := FND_DATE.canonical_to_date(p_rpt_from_date);
  l_date_to   := FND_DATE.canonical_to_date(p_rpt_to_date);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.rptdatefrom'
                  ,'Canonical Date From:' || l_rpt_date_from
                  );

    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.rptdateto'
                  ,'Canonical Date To:' || l_rpt_date_to
                  );

    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.acctpdfrom'
                  ,'Accounting Period Date From:' || l_date_from
                  );

    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.acctpdto'
                  ,'Accounting Period Date To:' || l_date_to
                  );

  END IF;


  -- dbms_output.put_line('before Get_Acct_Period_ID');
  Get_Acct_Period_ID
  ( p_org_id               => p_org_id
  , p_rpt_from_date        => l_date_from
  , p_rpt_to_date          => l_date_to
  , x_rpt_from_acct_per_id => l_rpt_from_acct_per_id
  , x_rpt_to_acct_per_id   => l_rpt_to_acct_per_id
  );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.rptacctpd'
                  ,'Report from Acct period id:' || l_rpt_from_acct_per_id ||
                   ' ' || 'Report to Acct period id:' || l_rpt_to_acct_per_id
                  );
  END IF;

--  dbms_output.put_line('before Check_Period_Close');
  CST_MGD_INFL_ADJUSTMENT_PVT.Check_Period_Close
  ( p_org_id         => p_org_id
  , p_acct_period_id => l_rpt_to_acct_per_id
  );

  IF p_item_from_code IS NULL OR p_item_to_code IS NULL
  THEN
    OPEN l_item_all_csr( p_org_id
                       , l_rpt_from_acct_per_id
                       , l_rpt_to_acct_per_id
                       );
  ELSE
    OPEN l_item_range_csr( p_org_id
                         , p_item_from_code
                         , p_item_to_code
                         , l_rpt_from_acct_per_id
                         , l_rpt_to_acct_per_id
                         );
  END IF;
  LOOP
    IF p_item_from_code IS NULL OR p_item_to_code IS NULL
    THEN
      FETCH
        l_item_all_csr
      INTO
        l_item_id
      , l_acct_period_id
      , l_per_begin_qty
      , l_begin_infl_adj
      , l_final_infl_adj
      , l_final_qty
      , l_period_schedule_close_date
      , l_period_start_date;
	 EXIT WHEN l_item_all_csr%NOTFOUND;
    ELSE
      FETCH
        l_item_range_csr
      INTO
        l_item_id
      , l_acct_period_id
      , l_per_begin_qty
      , l_begin_infl_adj
      , l_final_infl_adj
      , l_final_qty
      , l_period_schedule_close_date
      , l_period_start_date;
      EXIT WHEN l_item_range_csr%NOTFOUND;
    END IF;

--    CST_MGD_INFL_ADJUSTMENT_PVT.Get_Purchase_Qty
--    ( p_org_id            => p_org_id
--    , p_inventory_item_id => l_item_id
--    , p_acct_period_id    => l_acct_period_id
--    , x_purchase_qty      => l_purchase_qty
--    );

--    IF l_final_qty - l_purchase_qty = 0
--    THEN
--      l_unit_infl_adj := 0;
--    ELSE
--      l_unit_infl_adj := l_final_infl_adj/(l_final_qty - l_purchase_qty);
--    END IF;

    IF l_final_qty = 0
    THEN
      l_unit_infl_adj := 0;
    ELSE
      l_unit_infl_adj := l_final_infl_adj/l_final_qty;
    END IF;

-- Get the valid cost group
-- as part of bug#1474753 fix
   Get_valid_cost_group( p_org_id
                        ,l_cost_group_id);

    IF l_acct_period_id = l_rpt_from_acct_per_id
    THEN
      -- in case report start date doesn't align with
      -- account period start date
      Get_Offset_Qty
      ( p_org_id           => p_org_id
      , p_item_id          => l_item_id
      , p_from_acct_per_id => l_rpt_from_acct_per_id
      , p_rpt_from_date    => l_rpt_date_from
      , p_cost_group_id    => l_cost_group_id
      , x_offset_qty       => l_offset_qty
      );
    ELSE
      l_offset_qty := 0;
    END IF;

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  ,G_MODULE_HEAD || l_routine || '.offsetqty'
                  ,'Offset Qty:' || l_offset_qty
                  );
  END IF;

--    dbms_output.put_line('before Get_Period_End_Avg_Cost');
    CST_MGD_INFL_ADJUSTMENT_PVT.Get_Period_End_Avg_Cost
    ( p_acct_period_id           => l_acct_period_id
    , p_org_id                   => p_org_id
    , p_inv_item_id              => l_item_id
    , p_cost_group_id            => l_cost_group_id
    , x_period_end_item_avg_cost => l_item_unit_cost
    );

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  ,G_MODULE_HEAD || l_routine || '.itemunitcost'
                  ,'Item Id:' || l_item_id || ' ' ||
                  'Item Unit Cost:' || l_item_unit_cost
                  );
  END IF;

-- Get Previous Account Period Id
   Get_Previous_Acct_Period
   ( p_organization_id     => p_org_id
   , p_period_start_date   => l_period_start_date
   , x_prev_acct_period_id => l_prev_acct_period_id
   , x_prev_sch_close_date => l_prev_sch_close_date
   );

  -- Schedule close date set to 23:59:59
  l_prev_sch_close_date := TRUNC(l_prev_sch_close_date) + (86399/86400);

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  ,G_MODULE_HEAD || l_routine || '.itempdinfo'
                  ,'Item Id:' || l_item_id || ' ' ||
                   'Period Start Date:' || l_period_start_date || ' ' ||
                   'Previous Acct Period Id:' || l_prev_acct_period_id || ' ' ||
                   'Previous Schedule Close Date:' || l_prev_sch_close_date
                  );
  END IF;

-- Get Previous Period Info
   CST_MGD_INFL_ADJUSTMENT_PVT.Get_Previous_Period_info
   ( p_country_code            => NULL
   , p_organization_id         => p_org_id
   , p_inventory_item_id       => l_item_id
   , p_acct_period_id          => l_acct_period_id
   , p_prev_acct_period_id     => l_prev_acct_period_id
   , p_cost_group_id           => l_cost_group_id
   , x_previous_qty            => l_previous_qty
   , x_previous_cost           => l_previous_cost
   , x_previous_inflation_adj  => l_previous_inflation_adj
   );

  IF l_previous_qty <> 0 THEN
  l_previous_unit_cost := (l_previous_cost / l_previous_qty);
  ELSE
    l_previous_unit_cost := 0;
  END IF;

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  ,G_MODULE_HEAD || l_routine || '.prevpdinfo'
                  ,'Previous Qty:' || l_previous_qty || ' ' ||
                   'Previous Period Cost:' || l_previous_cost || ' ' ||
                   'Previous Inflation Adj:' || l_previous_inflation_adj
                  );
  END IF;

    IF l_rpt_from_acct_per_id <> l_rpt_to_acct_per_id
      AND
       l_acct_period_id = l_rpt_from_acct_per_id
    THEN
       l_per_first_txn_date := l_rpt_date_from;
       l_per_last_txn_date  :=
         TRUNC(l_period_schedule_close_date) + (86399/86400);
    ELSIF
       l_rpt_from_acct_per_id <> l_rpt_to_acct_per_id
      AND
       l_acct_period_id = l_rpt_to_acct_per_id
    THEN
       l_per_first_txn_date := TRUNC(l_period_start_date);
       l_per_last_txn_date  := l_rpt_date_to;
    ELSIF
       l_rpt_from_acct_per_id = l_rpt_to_acct_per_id
    THEN
       l_per_first_txn_date := l_rpt_date_from;
       l_per_last_txn_date  := l_rpt_date_to;
    ELSE
       l_per_first_txn_date := TRUNC(l_period_start_date);
       l_per_last_txn_date  :=
         TRUNC(l_period_schedule_close_date) + (86399/86400);
    END IF;

--    dbms_output.put_line('before Get_Item_Txn_Info');
    Get_Item_Txn_Info
    ( p_org_id             => p_org_id
    , p_item_id            => l_item_id
    , p_acct_period_id     => l_acct_period_id
    , p_per_first_txn_date => l_per_first_txn_date
    , p_per_last_txn_date  => l_per_last_txn_date
    , p_item_prev_cost     => l_previous_unit_cost
    , p_item_init_qty      => l_per_begin_qty
    , p_item_init_infl     => l_begin_infl_adj
    , p_item_unit_infl_adj => l_unit_infl_adj
    , p_offset_qty         => l_offset_qty
    , p_cost_group_id      => l_cost_group_id
    , x_rpt_item_tbl_rec   => l_rpt_item_tbl_rec
    );
--    dbms_output.put_line('after Get_Item_Txn_Info');

    l_index := NVL(l_rpt_item_tbl_rec.FIRST, 0);
    IF l_index > 0
    THEN
      LOOP
        Insert_Rpt_Data
	   ( p_rpt_item_rec    => l_rpt_item_tbl_rec(l_index)
	   );
        EXIT WHEN l_index = l_rpt_item_tbl_rec.LAST;
        l_index := l_rpt_item_tbl_rec.NEXT(l_index);
      END LOOP;
    END IF;

  END LOOP;

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
                             , 'Create_Infl_Adj_Rpt'
                             );
    END IF;
    RAISE;

END Create_Infl_Adj_Rpt;


END CST_MGD_INFL_ADJUSTMENT_RPT;

/
