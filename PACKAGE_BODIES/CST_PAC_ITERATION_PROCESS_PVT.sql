--------------------------------------------------------
--  DDL for Package Body CST_PAC_ITERATION_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PAC_ITERATION_PROCESS_PVT" AS
-- $Header: CSTVIIPB.pls 120.51.12010000.8 2009/08/04 10:39:32 vjavli ship $

-- API Name          : Iteration_Process
-- Type              : Private
-- Function          :
-- Pre-reqs          : None
-- Parameters        :
-- IN                :    p_init_msg_list         IN  VARCHAR2
--                        p_validation_level      IN  NUMBER
--                        p_legal_entity_id       IN  NUMBER
--                        p_cost_type_id          IN  NUMBER
--                        p_cost_method           IN  NUMBER
--                        p_period_id             IN  NUMBER
--                        p_start_date            IN  DATE
--                        p_end_date              IN  DATE
--                        p_inventory_item_id     IN  NUMBER
--                        p_inventory_item_number IN VARCHAR2(1025)
--                        p_tolerance             IN  NUMBER
--                        p_iteration_num         IN  NUMBER
--                        p_run_options           IN  NUMBER
--                        p_user_id               IN  NUMBER
--                        p_login_id              IN  NUMBER
--                        p_req_id                IN  NUMBER
--                        p_prg_id                IN  NUMBER
--                        p_prg_appid             IN  NUMBER
-- OUT               :    x_return_status         OUT VARCHAR2(1)
--                        x_msg_count             OUT NUMBER
--                        x_msg_data              OUT VARCHAR2(2000)
-- Version           : Current Version :    1.0
--                         Initial version     1.0
-- Notes             :
-- +========================================================================+

-- +========================================================================+
-- PRIVATE CONSTANTS AND VARIABLES
-- +========================================================================+
G_MODULE_HEAD CONSTANT  VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

-- +========================================================================+
-- PROCEDURES AND FUNCTIONS OF ITERATION PROCESS
-- +========================================================================+

-- +========================================================================+
-- FUNCTION: Check_Cst_Group    Local Utility
-- PARAMETERS:
--   p_cost_group_id  user input
-- COMMENT:
-- Take p_cost_group_id and look in the PL/SQL table l_cst_group_tbl.
-- A return value 'Y' means that the cost group id belongs to user entered
-- legal entity and therefore its a valid cost group.
-- A return value 'N' means that the cost group is not valid since it is not
-- belong to Legal Entity
-- USAGE: This function is used within the SQL
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Check_Cst_Group
( p_cost_group_id  IN NUMBER
)
RETURN VARCHAR2
IS
  l_cost_group_id_idx  BINARY_INTEGER;
  l_return             VARCHAR2(1) := 'N';

BEGIN
  l_cost_group_id_idx := p_cost_group_id;
  IF CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL.EXISTS(l_cost_group_id_idx)
  THEN
    -- valid Cost Group in Legal Entity
    l_return := 'Y';
  ELSE
    -- not a valid Cost Group
    l_return := 'N';
  END IF;

RETURN(l_return);

END;  -- Check_Cst_Group

-- +========================================================================+
-- FUNCTION: Get_Master_Org   Local Utility
-- PARAMETERS:
--   p_cost_group_id      IN NUMBER  Cost Group Id
-- COMMENT:
--   Get Item Master Organization of the Cost Group
-- USAGE: This procedure is invoked by Compute_iterative_pwac_cost for
-- each optimal cost group of the item
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Get_Master_Org
( p_cost_group_id    IN NUMBER
)
RETURN NUMBER
IS
l_cost_group_id_idx BINARY_INTEGER;
l_master_org_id     NUMBER;

BEGIN
  l_cost_group_id_idx  := p_cost_group_id;
  l_master_org_id      :=
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).master_organization_id;

RETURN l_master_org_id;

END Get_Master_Org;


-- +========================================================================+
-- FUNCTION: Get_Cost_Group   Local Utility
-- PARAMETERS:
--   p_organization_id      IN NUMBER
-- COMMENT:
--   Get Cost Group of the corresponding p_organization_id
-- USAGE: This function is used in the sql cursor
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Get_Cost_Group
( p_organization_id    IN NUMBER
)
RETURN NUMBER
IS
l_routine  CONSTANT  VARCHAR2(30) := 'get_cost_group';
l_organization_id_idx BINARY_INTEGER;
l_cost_group_id       NUMBER;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL.EXISTS(l_organization_id_idx) THEN
    l_cost_group_id      :=
      CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL(l_organization_id_idx).cost_group_id;
  ELSE
    l_cost_group_id := -99;
  END IF;

RETURN l_cost_group_id;

END Get_Cost_Group;


-- +========================================================================+
-- FUNCTION: Check_Cst_Group_Org    Local Utility
-- PARAMETERS:
--   p_organization_id
-- COMMENT:
-- Take p_organization_id and look in the PL/SQL table l_cst_group_org_tbl.
-- A return value 'Y' means that the organization id belongs to one of the
-- valid cost group in legal entity
-- A return value 'N' means that the organization id is NOT belong to
-- valid cost group
-- USAGE: This function is used within the SQL
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Check_Cst_Group_Org
( p_organization_id  IN NUMBER
)
RETURN VARCHAR2
IS
  l_organization_id_idx  BINARY_INTEGER;
  l_return               VARCHAR2(1) := 'N';

BEGIN
  l_organization_id_idx := p_organization_id;
  IF CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL.EXISTS(l_organization_id_idx)
  THEN
    -- Organization exists in one of the valid cost group
    l_return := 'Y';
  ELSE
    -- not a valid organization
    l_return := 'N';
  END IF;

RETURN(l_return);

END Check_Cst_Group_Org ;

-- +========================================================================+
-- FUNCTION: Get_Previous_Iteration_Count     Local Utility
-- PARAMETERS:
--   p_pac_period_id     NUMBER   PAC Period Id
-- COMMENT:
--   This is to get the Previous iteration count if any
--   iteration count initialized to 0
--   After first iteration process, iteration count will be set 1
--   For the remaining iteration process, it will be the maximum
--   iteration_num which is equal to the number of iterations user specified
--   in the previous iteration process
--   This procedure will retrieve the maximum iteration count of the
--   current BOM level
-- USAGE: This function is used in Iteration_Process
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Get_Previous_Iteration_Count
( p_period_id          IN  NUMBER
, p_inventory_item_id  IN  NUMBER
)
RETURN NUMBER
IS

-- Cursor to get maximum iteration number of the current BOM level
-- interorg item
-- For current BOM level item, iteration_count will be 0 for the very
-- first iteration and the count will be > 0 for the consecutive
-- iterations
CURSOR max_iteration_num_cur(c_period_id         NUMBER
                            ,c_inventory_item_id NUMBER
                            )
IS
SELECT
  MAX(iteration_count)
FROM
  CST_PAC_INTORG_ITMS_TEMP
WHERE pac_period_id     = c_period_id
  AND inventory_item_id = c_inventory_item_id
  AND tolerance_flag    = 'N';

l_max_iteration_num    NUMBER;
l_prev_iteration_count NUMBER := 0;

BEGIN
  -- Get maximum iteration number
  OPEN max_iteration_num_cur(p_period_id
                            ,p_inventory_item_id
                            );
  FETCH max_iteration_num_cur
   INTO l_max_iteration_num;

  IF max_iteration_num_cur%FOUND THEN
    l_prev_iteration_count := l_max_iteration_num;
  ELSE
    l_prev_iteration_count := -99;
  END IF;

  CLOSE max_iteration_num_cur;

RETURN l_prev_iteration_count;

END; -- Get_Previous_Iteration_Count

-- +========================================================================+
-- PROCEDURE: Get_Correspond_Pmac_Cost     Local Utility
-- PARAMETERS:
--   p_cost_group_id         Cost Group Id
--   p_cost_type_id         Cost Type Id
--   p_opp_transaction_id    Corresponding Transaction Id
--   p_period_id             PAC Period Id
--   p_organization_id       Organization of Cost owned transaction id
--   p_opp_organization_id   Corresponding organization Id
--   p_transaction_id        Cost owned Transaction Id
--   p_transaction_action_id Direct-interorg,intransit shipment/receipt
--   p_group_num             Group Number
--   x_correspond_pmac_cost  PMAC Cost of the corresponding cost group
-- COMMENT:
--   This procedure is to get the PMAC Cost of corresponding transaction id and
--   organization id from the same temporary table
--   Corresponding transaction id is the cost derived transaction.  Hence,
--   the actual cost is the pmac cost of the corresponding cost group
--
-- USAGE:
--   This procedure is used to compute the transfer cost as a %age of the
--   pmac cost of the corresponding cost group
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
PROCEDURE Get_Correspond_Pmac_Cost
( p_cost_group_id           IN         NUMBER
, p_cost_type_id            IN         NUMBER
, p_opp_transaction_id      IN         NUMBER
, p_period_id               IN         NUMBER
, p_organization_id         IN         NUMBER
, p_opp_organization_id     IN         NUMBER
, p_transaction_id          IN         NUMBER
, p_transaction_action_id   IN         NUMBER
, p_group_num               IN         NUMBER
, x_correspond_pmac_cost    OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'Get_Correspond_Pmac_Cost';

-- cursor to get actual cost from MTL_PAC_ACT_CST_DTL_TEMP
CURSOR new_pwac_cost_cur( c_transaction_id  NUMBER
                        , c_period_id       NUMBER
			, c_cost_type_id    NUMBER
                        , c_cost_group_id NUMBER
                        )
IS
SELECT
  SUM(actual_cost)
FROM
  mtl_pac_act_cst_dtl_temp
WHERE cost_group_id    = c_cost_group_id
  AND cost_type_id     = c_cost_type_id
  AND pac_period_id   <= c_period_id
  AND transaction_id   = c_transaction_id;

l_correspond_org_id      NUMBER;
l_correspond_pmac_cost   NUMBER := 0;
l_cost_group_id          NUMBER;

new_cost_direct_excep    EXCEPTION;
new_cost_intransit_excep EXCEPTION;

BEGIN


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  -- Get New Cost for Direct Interorg Receipt
  IF p_transaction_action_id = 3 THEN
    l_cost_group_id := get_cost_group(p_opp_organization_id);

    OPEN new_pwac_cost_cur(p_opp_transaction_id
                          ,p_period_id
			  ,p_cost_type_id
                          ,l_cost_group_id
                          );

    FETCH new_pwac_cost_cur
     INTO l_correspond_pmac_cost;


    CLOSE new_pwac_cost_cur;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.Directnewcost'
                    , 'Correspond Txn Id:' || p_opp_transaction_id ||
                      ' Correspond organization Id:' || p_opp_organization_id
                       || ' New Cost:' || l_correspond_pmac_cost
                    );
    END IF;

  -- intransit interorg transactions
  ELSIF (p_transaction_action_id = 21 OR p_transaction_action_id = 12) THEN

    -- Set Corresponding Organization Id
    -- intransit receipt - 12 group 1 transactions
    --   Transfer organization id is the corresponding organization
    -- intransit shipment - 21 group 1 transactions
    --   Organization id is the corresponding organization
    -- intransit receipt - 12 group 2 transactions
    --   Organization id is the corresponding organization
    -- intransit shipment - 21 group 2 transactions
    --   Transfer organization id is the corresponding organization
    IF (p_transaction_action_id = 12 AND p_group_num = 1) THEN
      l_correspond_org_id := p_opp_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 1) THEN
      l_correspond_org_id :=  p_organization_id;
    ELSIF (p_transaction_action_id = 12 AND p_group_num = 2) THEN
      l_correspond_org_id := p_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 2) THEN
      l_correspond_org_id := p_opp_organization_id;
    END IF;

    -- p_opp_transaction_id is same as p_transaction_id
    -- eg: TX1' = TX1
    -- note: transfer_transaction_id not available for intransit txns
    l_cost_group_id := get_cost_group(l_correspond_org_id);

    OPEN new_pwac_cost_cur(p_transaction_id
                          ,p_period_id
			  ,p_cost_type_id
                          ,l_cost_group_id
                          );
    FETCH new_pwac_cost_cur
     INTO l_correspond_pmac_cost;

    CLOSE new_pwac_cost_cur;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.Intransitnewcost'
                    , 'Correspond Txn Id:' || p_opp_transaction_id ||
                      ' Correspond organization Id:' || l_correspond_org_id ||
                       ' New Cost:' || l_correspond_pmac_cost
                    );
    END IF;

  END IF;  -- interorg transaction check

  x_correspond_pmac_cost := l_correspond_pmac_cost;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

END Get_Correspond_Pmac_Cost;

-- +========================================================================+
-- PROCEDURE: Get_Correspond_Pwac_New_Cost     Local Utility
-- PARAMETERS:
--   p_cost_group_id        Cost Group Id
--   p_opp_transaction_id   Corresponding Transaction Id
--   p_period_id            PAC Period Id
--   p_organization_id      Organization of Cost owned transaction id
--   p_opp_organization_id  Corresponding organization Id
--   p_transaction_id       Cost owned Transaction Id
--   p_transaction_action_id   Direct-interorg,intransit shipment/receipt
--   p_cost_element_id      Cost Element Id
--   p_level_type           Level Type
--   p_group_num            Group Number
--   x_new_correspond_cost  New Cost of corresponding txn
-- COMMENT:
--   This procedure is to get the New Cost of corresponding transaction id and
--   organization id from the same temporary table for the cost_element_id
--   and level_type
--
-- USAGE:
--   This procedure is used in compute_iterative_pwac_cost during
--   consecutive iterations
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
PROCEDURE Get_Correspond_Pwac_New_Cost
( p_cost_group_id           IN         NUMBER
, p_cost_type_id            IN         NUMBER
, p_opp_transaction_id      IN         NUMBER
, p_period_id               IN         NUMBER
, p_organization_id         IN         NUMBER
, p_opp_organization_id     IN         NUMBER
, p_transaction_id          IN         NUMBER
, p_transaction_action_id   IN         NUMBER
, p_cost_element_id         IN         NUMBER
, p_level_type              IN         NUMBER
, p_group_num               IN         NUMBER
, x_new_correspond_cost     OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'Get_Correspond_Pwac_New_Cost';

-- cursor to get actual cost from MTL_PAC_ACT_CST_DTL_TEMP
CURSOR new_pwac_cost_cur( c_transaction_id  NUMBER
                        , c_period_id       NUMBER
			, c_cost_type_id    NUMBER
                        , c_cost_group_id   NUMBER
                        , c_cost_element_id NUMBER
                        , c_level_type      NUMBER
                        )
IS
SELECT
  actual_cost
FROM
  mtl_pac_act_cst_dtl_temp
WHERE cost_group_id    = c_cost_group_id
  AND pac_period_id   <= c_period_id
  AND cost_type_id     = c_cost_type_id
  AND transaction_id   = c_transaction_id
  AND cost_element_id  = c_cost_element_id
  AND level_type       = c_level_type;

l_correspond_org_id     NUMBER;
l_new_correspond_cost   NUMBER := 0;
l_cost_group_id         NUMBER;

new_cost_direct_excep    EXCEPTION;
new_cost_intransit_excep EXCEPTION;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  -- Get New Cost for Direct Interorg Receipt
  IF p_transaction_action_id = 3 THEN
  l_cost_group_id := get_cost_group(p_opp_organization_id);

    OPEN new_pwac_cost_cur(p_opp_transaction_id
                          ,p_period_id
			  ,p_cost_type_id
                          ,l_cost_group_id
                          ,p_cost_element_id
                          ,p_level_type
                          );

    FETCH new_pwac_cost_cur
     INTO l_new_correspond_cost;

    CLOSE new_pwac_cost_cur;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.Directnewcost'
                    , 'Correspond Txn Id:' || p_opp_transaction_id ||
                      ' Correspond organization Id:' || p_opp_organization_id ||                      ' Cost element Id:' || p_cost_element_id ||
                      ' Level Type:' || p_level_type || ' New Cost:' || l_new_correspond_cost
                    );
    END IF;

  -- intransit interorg transactions
  ELSIF (p_transaction_action_id = 21 OR p_transaction_action_id = 12) THEN

    -- Set Corresponding Organization Id
    -- intransit receipt - 12 group 1 transactions
    --   Transfer organization id is the corresponding organization
    -- intransit shipment - 21 group 1 transactions
    --   Organization id is the corresponding organization
    -- intransit receipt - 12 group 2 transactions
    --   Organization id is the corresponding organization
    -- intransit shipment - 21 group 2 transactions
    --   Transfer organization id is the corresponding organization
    IF (p_transaction_action_id = 12 AND p_group_num = 1) THEN
      l_correspond_org_id := p_opp_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 1) THEN
      l_correspond_org_id :=  p_organization_id;
    ELSIF (p_transaction_action_id = 12 AND p_group_num = 2) THEN
      l_correspond_org_id := p_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 2) THEN
      l_correspond_org_id := p_opp_organization_id;
    END IF;

    -- p_opp_transaction_id is same as p_transaction_id
    -- eg: TX1' = TX1
    -- note: transfer_transaction_id not available for intransit txns
    l_cost_group_id := get_cost_group(l_correspond_org_id);
    OPEN new_pwac_cost_cur(p_transaction_id
                          ,p_period_id
			  ,p_cost_type_id
                          ,l_cost_group_id
                          ,p_cost_element_id
                          ,p_level_type
                          );
    FETCH new_pwac_cost_cur
     INTO l_new_correspond_cost;

--    IF new_cost_cur%NOTFOUND THEN
--      RAISE new_cost_intransit_excep;
--    END IF;

    CLOSE new_pwac_cost_cur;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.Intransitnewcost'
                    , 'Correspond Txn Id:' || p_opp_transaction_id ||
                      ' Correspond organization Id:' || l_correspond_org_id ||                        ' Cost element Id:' || p_cost_element_id ||
                      ' Level Type:' || p_level_type || ' New Cost:' ||
                      l_new_correspond_cost
                    );
    END IF;

  END IF;  -- interorg transaction check

  x_new_correspond_cost := l_new_correspond_cost;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;
END Get_Correspond_Pwac_New_Cost;

-- +========================================================================+
-- PROCEDURE: Get_Correspond_Actual_Cost
-- PARAMETERS:
--   p_period_id               IN  NUMBER
--   p_cost_type_id            IN  NUMBER
--   p_transaction_id          IN  NUMBER
--   p_transaction_action_id   IN  NUMBER
--   p_organization_id         IN  NUMBER Organization Id
--   p_opp_organization_id     IN  NUMBER Transfer Org Id
--   p_opp_transaction_id      IN  NUMBER Corresponding txn id
--   p_cost_element_id         IN  NUMBER Cost element id
--   p_level_type              IN  NUMBER Level type
--   p_group_num               IN  NUMBER  Group Number
--   x_correspond_actual_cost  OUT NOCOPY NUMBER Correspond actual cost
--   x_correspond_txn_flag     OUT NOCOPY VARCHAR2
-- COMMENT:
--   This procedure is to retrieve actual cost of the corresponding
--   shipment PAC transaction with cost element and level type
--   If the corresponding transaction exists, x_correspond_txn_flag set
--   to 'Y'.  Otherwise, flag is set to 'N'
-- USAGE: This procedure is invoked by verify_tolerance_of_item
--        This procedure is also used in balance_pac_txn inorder to
--        determine whether the corresponding pac transaction exists
--        x_correspond_txn_flag is used by blaance_pac_txn
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Get_Correspond_Actual_Cost
  ( p_period_id               IN  NUMBER
  , p_cost_type_id            IN  NUMBER
  , p_transaction_id          IN  NUMBER
  , p_transaction_action_id   IN  NUMBER
  , p_organization_id         IN  NUMBER
  , p_opp_organization_id     IN  NUMBER
  , p_opp_transaction_id      IN  NUMBER
  , p_cost_element_id         IN  NUMBER
  , p_level_type              IN  NUMBER
  , p_group_num               IN  NUMBER
  , x_correspond_actual_cost  OUT NOCOPY  NUMBER
  , x_correspond_txn_flag     OUT NOCOPY  VARCHAR2
  )
IS

l_routine CONSTANT VARCHAR2(30) := 'Get_correspond_actual_cost';

-- Retrieve corresponding actual cost for the direct interorg shipment
CURSOR direct_actual_cost_cur(c_period_id           NUMBER
			     ,c_cost_type_id        NUMBER
                             ,c_cost_group_id       NUMBER
                             ,c_opp_transaction_id  NUMBER
                             ,c_cost_element_id     NUMBER
                             ,c_level_type          NUMBER
                             )
IS
SELECT
  actual_cost
, new_cost
FROM
  mtl_pac_act_cst_dtl_temp
WHERE cost_group_id   =  c_cost_group_id
  AND pac_period_id   <=  c_period_id
  AND cost_type_id    =  c_cost_type_id
  AND transaction_id  =  c_opp_transaction_id
  AND cost_element_id =  c_cost_element_id
  AND level_type      =  c_level_type;


-- Retrieve corresponding actual cost for intransit transactions
CURSOR intransit_actual_cost_cur(c_period_id             NUMBER
				,c_cost_type_id          NUMBER
                                ,c_transaction_id        NUMBER
                                ,c_cost_group_id   NUMBER
                                ,c_cost_element_id       NUMBER
                                ,c_level_type            NUMBER
                                )
IS
SELECT
  actual_cost
FROM
  mtl_pac_act_cst_dtl_temp
WHERE cost_group_id   =  c_cost_group_id
  AND pac_period_id   <=  c_period_id
  AND cost_type_id    =  c_cost_type_id
  AND transaction_id  =  c_transaction_id
  AND cost_element_id =  c_cost_element_id
  AND level_type      =  c_level_type;

l_correspond_org_id        NUMBER;
l_correspond_actual_cost   NUMBER := 0;
l_correspond_txn_flag      VARCHAR2(1);
l_new_cost                 NUMBER := 0;
l_cost_group_id            NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine ||'.txnid'
                  , 'Transaction ID:' || p_transaction_id
                  );
  END IF;

  -- ==================================================================
  -- Check for Transaction Action id
  -- ==================================================================
  -- Is it a Direct interorg transaction
  IF p_transaction_action_id  =  3  THEN
    -- Get actual cost of corresponding direct interorg shipment
    l_cost_group_id := get_cost_group(p_opp_organization_id);
    OPEN direct_actual_cost_cur(p_period_id
	                       ,p_cost_type_id
                               ,l_cost_group_id
                               ,p_opp_transaction_id
                               ,p_cost_element_id
                               ,p_level_type
                               );
    FETCH direct_actual_cost_cur
     INTO l_correspond_actual_cost
         ,l_new_cost;

    IF direct_actual_cost_cur%FOUND THEN
      l_correspond_txn_flag  := 'Y';
    ELSE
      -- Check whether corresponding Cost Group exists
      IF Get_Cost_Group(p_opp_organization_id) = -99 THEN
        -- corresponding cost group not found
        l_correspond_txn_flag := 'C';
      ELSE
        -- corresponding cost group exists, but txn not exists
        l_correspond_txn_flag  := 'N';
      END IF;

    END IF;

    CLOSE direct_actual_cost_cur;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine ||'.Direct_txn'
                    , 'Correspond Txn Info: Organization Id:' ||
                       p_opp_organization_id || ' Transaction Id:' ||
                       p_opp_transaction_id  ||
                    ' Cost element Id:' || p_cost_element_id ||
                    ' Level Type:' || p_level_type  ||
                    ' Correspond Actual Cost:' || l_correspond_actual_cost
                    );
    END IF;

  -- intransit interorg transactions
  ELSIF (p_transaction_action_id = 12 OR p_transaction_action_id = 21 )  THEN
    -- Set Corresponding Organization Id
    -- intransit receipt - 12 group 1 transactions
    --   Transfer organization id is the corresponding organization
    -- intransit shipment - 21 group 1 transactions
    --   Organization id is the corresponding organization
    -- intransit receipt - 12 group 2 transactions
    --   Organization id is the corresponding organization
    -- intransit shipment - 21 group 2 transactions
    --   Transfer organization id is the corresponding organization
    IF (p_transaction_action_id = 12 AND p_group_num = 1) THEN
      l_correspond_org_id := p_opp_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 1) THEN
      l_correspond_org_id :=  p_organization_id;
    ELSIF (p_transaction_action_id = 12 AND p_group_num = 2) THEN
      l_correspond_org_id := p_organization_id;
    ELSIF (p_transaction_action_id = 21 AND p_group_num = 2) THEN
      l_correspond_org_id := p_opp_organization_id;
    END IF;

    l_cost_group_id := get_cost_group(l_correspond_org_id);
    OPEN intransit_actual_cost_cur(p_period_id
			          ,p_cost_type_id
                                  ,p_transaction_id
                                  ,l_cost_group_id
                                  ,p_cost_element_id
                                  ,p_level_type
                                  );

    FETCH intransit_actual_cost_cur
     INTO l_correspond_actual_cost;

    IF intransit_actual_cost_cur%FOUND THEN
      l_correspond_txn_flag  := 'Y';
    ELSE
      -- Check whether corresponding Cost Group exists
      IF l_cost_group_id = -99 THEN
        -- corresponding cost group not found
        l_correspond_txn_flag := 'C';
      ELSE
        -- corresponding cost group exists, but txn not exists
        l_correspond_txn_flag  := 'N';
      END IF;
    END IF;

    CLOSE intransit_actual_cost_cur;

    IF l_correspond_txn_flag = 'C' THEN
      -- Display a message that not cost group found
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_HEAD || l_routine ||'.nocg'
                      , 'No Cost Group found'
                      );
      END IF;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine ||'.Direct_txn'
                    , 'Correspond Txn Info: Organization Id:' ||
                       l_correspond_org_id || ' Transaction Id:' ||
                       p_transaction_id  ||
                    ' Cost element Id:' || p_cost_element_id ||
                    ' Level Type:' || p_level_type  ||
                    ' Correspond Actual Cost:' || l_correspond_actual_cost
                    );
    END IF;


  END IF; -- interorg transactions check

  x_correspond_actual_cost := l_correspond_actual_cost;
  x_correspond_txn_flag    := l_correspond_txn_flag;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                   , 'txn_id '|| p_transaction_id || 'Opp Txn_id '||p_opp_transaction_id || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', 'txn_id '|| p_transaction_id || 'Opp Txn_id '||p_opp_transaction_id || '('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

END; -- Get correspond actual cost

-- +========================================================================+
-- PROCEDURE: Balance_Pac_Txn     Local Utility
-- PARAMETERS:
--   p_period_id            PAC Period Id
--   p_inventory_item_id    Inventory Item Id
--   p_cost_type_id         Cost type of Legal Entity
-- COMMENT:
--   This procedure creates or deletes pac transactions inorder to balance
--   with corresponding interorg transactions
-- USAGE:
--   This procedure is invoked through api: iteration_process
--   after the very iteration (default current behavior)
--   It is invoked only once after the first iteration
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
PROCEDURE Balance_Pac_Txn
( p_period_id          IN  NUMBER
, p_inventory_item_id  IN  NUMBER
, p_cost_type_id       IN  NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'balance_pac_txn';

-- Cursor to obtain PAC transaction cost element and level type
CURSOR pac_bal_txn_cursor(c_cost_group_id     NUMBER
                         ,c_period_id         NUMBER
                         ,c_transaction_id    NUMBER
                         ,c_inventory_item_id NUMBER
                         )
IS
SELECT
  cost_layer_id
, cost_element_id
, level_type
, actual_cost
FROM
  mtl_pac_act_cst_dtl_temp
WHERE pac_period_id     = c_period_id
  AND cost_group_id     = c_cost_group_id
  AND transaction_id    = c_transaction_id
  AND inventory_item_id = c_inventory_item_id
ORDER BY
  cost_element_id
, level_type
, transaction_id
FOR UPDATE;

-- Cursor to obtain interorg transactions of Cost Groups with receipts
CURSOR pac_interorg_txns_cur(c_period_id    NUMBER
                             , c_inventory_item_id NUMBER
			     )
IS
SELECT
  ccit.transaction_id   transaction_id
, ccit.transaction_action_id   transaction_action_id
, ccit.organization_id  organization_id
, nvl(ccit.transfer_organization_id,-1) transfer_organization_id
, ccit.transfer_transaction_id  transfer_transaction_id
, ccit.cost_group_id    cost_group_id
, ccit.txn_type   txn_type
FROM
CST_PAC_INTERORG_TXNS_TMP ccit, cst_pac_intorg_itms_temp cpiit
WHERE ccit.inventory_item_id = c_inventory_item_id
AND ccit.pac_period_id = c_period_id
AND cpiit.inventory_item_id = ccit.inventory_item_id
AND cpiit.cost_group_id     = ccit.cost_group_id
AND cpiit.pac_period_id     = ccit.pac_period_id
AND cpiit.interorg_receipt_flag = 'Y'
ORDER BY ccit.cost_group_id, ccit.txn_type, ccit.transaction_id;

TYPE pac_interorg_txns_tab IS TABLE OF pac_interorg_txns_cur%rowtype INDEX BY BINARY_INTEGER;
l_pac_interorg_txns_tab		pac_interorg_txns_tab;
l_empty_pac_interorg_txns_tab	pac_interorg_txns_tab;

l_loop_count       NUMBER := 0;
l_batch_size       NUMBER := 200;

-- Cursor to obtain cost layer id of corresponding group 1 pac transaction
-- for a given pac period, corresponding cost group and inventory
-- item id
CURSOR pac_group1_cost_layer(c_period_id               NUMBER
                            ,c_opp_cost_group_id       NUMBER
                            ,c_inventory_item_id       NUMBER
                            )
IS
SELECT
  cost_layer_id
FROM
  CST_PAC_ITEM_COSTS
WHERE pac_period_id     =  c_period_id
  AND cost_group_id     = c_opp_cost_group_id
  AND inventory_item_id = c_inventory_item_id;


l_correspond_txn_flag       VARCHAR2(1);
l_correspond_actual_cost    NUMBER;
l_correspond_cost_group_id  NUMBER;
l_correspond_transaction_id NUMBER;
l_correspond_cost_layer_id  NUMBER;
l_moh_absorption_cost       NUMBER := 0;
l_txn_gp_idx                BINARY_INTEGER;

-- Optimal Interorg Flags of Cost Group for the item
l_interorg_receipt_flag  VARCHAR2(1);
l_interorg_shipment_flag VARCHAR2(1);

BEGIN

  IF NOT pac_interorg_txns_cur%ISOPEN THEN
     OPEN pac_interorg_txns_cur(p_period_id
 			       ,p_inventory_item_id
			       );
  END IF;

  LOOP

    l_pac_interorg_txns_tab := l_empty_pac_interorg_txns_tab;
    FETCH pac_interorg_txns_cur BULK COLLECT INTO l_pac_interorg_txns_tab LIMIT l_batch_size;

    l_loop_count := l_pac_interorg_txns_tab.count;

    FOR i IN 1..l_loop_count
    LOOP


      FOR pac_bal_txn_idx IN
        pac_bal_txn_cursor(l_pac_interorg_txns_tab(i).cost_group_id
                          ,p_period_id
                          ,l_pac_interorg_txns_tab(i).transaction_id
                          ,p_inventory_item_id
                          )  LOOP

		-- Get the corresponding PAC transaction
		Get_Correspond_Actual_Cost(p_period_id			=>	p_period_id
					  ,p_cost_type_id		=>	p_cost_type_id
				          ,p_transaction_id		=>      l_pac_interorg_txns_tab(i).transaction_id
				          ,p_transaction_action_id	=>	l_pac_interorg_txns_tab(i).transaction_action_id
				          ,p_organization_id		=>	l_pac_interorg_txns_tab(i).organization_id
				          ,p_opp_organization_id	=>	l_pac_interorg_txns_tab(i).transfer_organization_id
				          ,p_opp_transaction_id		=>	l_pac_interorg_txns_tab(i).transfer_transaction_id
				          ,p_cost_element_id		=>	pac_bal_txn_idx.cost_element_id
				          ,p_level_type			=>	pac_bal_txn_idx.level_type
				          ,p_group_num			=>	l_pac_interorg_txns_tab(i).txn_type
				          ,x_correspond_actual_cost	=>	l_correspond_actual_cost
				          ,x_correspond_txn_flag	=>	l_correspond_txn_flag
				          );

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                         , G_MODULE_HEAD || l_routine ||'.actual_cost'
                         , 'Correspond Actual Cost:' || l_correspond_actual_cost
                           || ' ' || 'Correspond Txn Flag:' || l_correspond_txn_flag
                          );
		END IF;

	        IF l_pac_interorg_txns_tab(i).txn_type = 1 THEN
		  /* Cost owned (group 1) transactions include receipts
		     Corresponding cost derived (group 2) txn include shipment
		     If the corresponding transaction exists
		     if the cost element = 2 and level type = 1 then
		     get material overhead absorption cost of group 1 txn
		     update moh absorption cost in pac txn temp table
		     if the cost element <> 2 then retain as it is */
			IF l_correspond_txn_flag = 'Y' AND pac_bal_txn_idx.cost_element_id = 2 THEN

			          BEGIN
					  SELECT  nvl(actual_cost,0)
					    INTO l_moh_absorption_cost
					  FROM  MTL_PAC_COST_SUBELEMENTS
					  WHERE cost_group_id   = l_pac_interorg_txns_tab(i).cost_group_id
  					    AND transaction_id  = l_pac_interorg_txns_tab(i).transaction_id
					    AND pac_period_id   = p_period_id
					    AND cost_element_id = 2
					    AND level_type      = pac_bal_txn_idx.level_type;

				   EXCEPTION
				   WHEN NO_DATA_FOUND THEN
					l_moh_absorption_cost := 0;
				   END;

			          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			            FND_LOG.string(FND_LOG.LEVEL_STATEMENT , G_MODULE_HEAD || l_routine ||'.moh_actual_cost'
		                      , 'After MOH Retrieve: Cost Group Id:' || l_pac_interorg_txns_tab(i).cost_group_id ||
                                       ' Transaction Id:' || l_pac_interorg_txns_tab(i).transaction_id ||
				       ' Period Id:' || p_period_id || ' Level Type:' || pac_bal_txn_idx.level_type
	                          );
				  END IF;

				  -- Update moh absorption cost in pac txn temp table
			          IF pac_bal_txn_idx.cost_element_id = 2 AND l_moh_absorption_cost <> 0  THEN

				            UPDATE MTL_PAC_ACT_CST_DTL_TEMP
				               SET moh_absorption_cost = l_moh_absorption_cost
				            WHERE CURRENT OF pac_bal_txn_cursor;

			          END IF; -- check for moh absorption

		        END IF; -- check for cost element 2 and correspond txn flag

		  /* If the corresponding transaction NOT exists, then
		     If cost element = 2 then
	             NOTE: DO NOT USE this cost owned receipt for comparison
	             DO NOT delete this record as this record will be put back
	             into MPACD at the end of iteration process
	             No logic as the record will be retained as it is */

		ELSIF l_pac_interorg_txns_tab(i).txn_type = 2 THEN
			-- Cost derived (group 2) transactions include shipments
			-- Corresponding cost owned (group 1) txn include receipt
			-- If the corresponding transaction exists then retain as it is
			-- If the corresponding transaction NOT exists, then insert the
			-- corresponding transaction as it is required to be considered for
			-- iteration process
			-- Insert corresponding group 1 pac transaction if the current
			-- group2 transaction exists and the transaction is direct interorg
			-- DO NOT insert corresponding group 1 pac transaction if the
			-- current group2 transaction is an intransit interorg transaction
			-- and DO NOT use for comparison since the corresponding group 1 txn
			-- may be across periods.

			IF (l_correspond_txn_flag  = 'N') AND (l_pac_interorg_txns_tab(i).transaction_action_id = 3 ) THEN

		        -- Get Corresponding Cost Group Id
			        l_correspond_cost_group_id  := get_cost_group(l_pac_interorg_txns_tab(i).transfer_organization_id);
		        -- for direct interorg:  transfer_transaction_id exists
		        -- for intransit interorg: transfer_transaction_id not exists in mmt
		        -- for intransit interorg: transaction_id is the transfer_transaction_id
		        -- with corresponding cost group
				l_correspond_transaction_id := nvl(l_pac_interorg_txns_tab(i).transfer_transaction_id,
				                                   l_pac_interorg_txns_tab(i).transaction_id);



			-- Get cost layer id of corresponding group 1 transaction
				OPEN pac_group1_cost_layer(p_period_id
                                    ,l_correspond_cost_group_id
                                    ,p_inventory_item_id
                                    );

				FETCH pac_group1_cost_layer
				INTO l_correspond_cost_layer_id;

				CLOSE pac_group1_cost_layer;


				-- Insert into MTL_PAC_ACT_CST_DTL_TEMP
				-- Cost owned transactions
				 INSERT INTO MTL_PAC_ACT_CST_DTL_TEMP
				 ( COST_GROUP_ID
				 , TRANSACTION_ID
				 , PAC_PERIOD_ID
				 , COST_TYPE_ID
				 , COST_ELEMENT_ID
				 , LEVEL_TYPE
				 , INVENTORY_ITEM_ID
				 , COST_LAYER_ID
				 , PRIOR_COST
			         , ACTUAL_COST
				 , NEW_COST
				 , PRIOR_BUY_COST
				 , PRIOR_MAKE_COST
				 , NEW_BUY_COST
				 , NEW_MAKE_COST
				 , USER_ENTERED
				 , INSERTION_FLAG
				 , TRANSACTION_COSTED_DATE
				 , TRANSFER_TRANSACTION_ID
				 , TRANSFER_COST
				 , TRANSPORTATION_COST
				 , MOH_ABSORPTION_COST
				 ) VALUES
				( l_correspond_cost_group_id
				, l_correspond_transaction_id
				, p_period_id
				, p_cost_type_id
				, pac_bal_txn_idx.cost_element_id
				, pac_bal_txn_idx.level_type
				, p_inventory_item_id
				, l_correspond_cost_layer_id
				, 0
				, pac_bal_txn_idx.actual_cost
				, 0
				, 0
				, 0
				, 0
				, 0
				,'Y'
				,'N'
				,NULL
			        ,l_pac_interorg_txns_tab(i).transfer_transaction_id
			        ,0
		                ,0
			        ,0
			        );

			END IF;


		 END IF;  -- group check

      END LOOP; -- end of pac txn loop

    END LOOP; -- FOR i IN 1..l_loop_count

    EXIT WHEN pac_interorg_txns_cur%NOTFOUND;
  END LOOP; --	FETCH loop
  CLOSE pac_interorg_txns_cur;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                   , 'Item_id' ||p_inventory_item_id || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', 'Item_id' ||p_inventory_item_id ||'('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

END; -- Balance pac txn

-- ==========================================================================
-- PROCEDURE : Calc_Pmac_For_Interorg     PRIVATE
-- COMMENT   : This procedure is a copy CSTPPWAC.calculate_periodic_cost with
--           : a minor modification to perform the process only for the
--           : last txn of a transaction category 8 interorg receipts
-- ==========================================================================
PROCEDURE Calc_Pmac_For_Interorg(p_pac_period_id     IN NUMBER
                                ,p_cost_type_id      IN NUMBER
                                ,p_cost_group_id     IN NUMBER
                                ,p_inventory_item_id IN NUMBER
                                ,p_low_level_code    IN NUMBER
                                ,p_user_id           IN NUMBER
                                ,p_login_id          IN NUMBER
                                ,p_request_id        IN NUMBER
                                ,p_prog_id           IN NUMBER
                                ,p_prog_appl_id      IN NUMBER
                                )
IS

 l_routine  CONSTANT VARCHAR2(30) := 'calc_pmac_for_interorg';

 l_stmt_num  NUMBER;
 TYPE t_txn_id_tbl IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.transaction_id%TYPE
        INDEX BY BINARY_INTEGER;
 TYPE t_txn_category_tbl IS TABLE OF CST_PAC_PERIOD_BALANCES.txn_category%TYPE
        INDEX BY BINARY_INTEGER;
 l_last_txn_id_tbl t_txn_id_tbl;
 l_txn_category_tbl t_txn_category_tbl;
 l_cost_layer_id_tbl CSTPPINV.t_cost_layer_id_tbl;

 l_period_quantity  NUMBER;
 l_period_balance   NUMBER;
 l_cg_idx           BINARY_INTEGER;

BEGIN

  FND_FILE.put_line
  ( FND_FILE.log
  , '>> CST_PERIODIC_ABSORPTION_PROC:Calc_Pmac_For_Interorg'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Get the period quantity upto interorg receipts
  l_cg_idx  := to_char(p_cost_group_id);
  l_period_quantity := G_CST_GROUP_TBL(l_cg_idx).period_new_quantity;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || 'pdqty'
                    ,'Cost Group Id:' || p_cost_group_id || ' Inventory Item Id:' || p_inventory_item_id ||  ' Period Quantity upto interorg receipts:' || l_period_quantity
                    );
    END IF;


   -- Build temporary tables to hold the last txn id and txn category values for each cost_layer_id
   -- of a transaction category 8 interorg receipts across CGs
   IF (p_low_level_code = -1) THEN
      -- items without completion
      l_stmt_num := 10;
      SELECT  distinct cost_layer_id, mpacd.transaction_id
      BULK    COLLECT
      INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                      FROM   mtl_pac_actual_cost_details mpacd1
                                      WHERE  mpacd1.txn_category = 8
                                      AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                      AND    mpacd1.pac_period_id = p_pac_period_id
                                      AND    mpacd1.cost_group_id = p_cost_group_id)
      AND     mpacd.cost_group_id     = p_cost_group_id
      AND     mpacd.pac_period_id     = p_pac_period_id
      AND     mpacd.inventory_item_id = p_inventory_item_id
      AND     NOT EXISTS (SELECT 1
                          FROM   cst_pac_low_level_codes cpllc
                          WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                          AND    cpllc.pac_period_id = p_pac_period_id
                          AND    cpllc.cost_group_id = p_cost_group_id);
  ELSE
      -- items with completion
      l_stmt_num := 20;
      SELECT  distinct cost_layer_id, mpacd.transaction_id
      BULK    COLLECT
      INTO    l_cost_layer_id_tbl, l_last_txn_id_tbl
      FROM    mtl_pac_actual_cost_details mpacd
      WHERE   mpacd.transaction_id = (SELECT max(mpacd1.transaction_id)
                                      FROM   mtl_pac_actual_cost_details mpacd1
                                      WHERE  mpacd1.txn_category = 8
                                      AND    mpacd1.inventory_item_id = mpacd.inventory_item_id
                                      AND    mpacd1.pac_period_id = p_pac_period_id
                                      AND    mpacd1.cost_group_id = p_cost_group_id)
      AND     mpacd.cost_group_id     = p_cost_group_id
      AND     mpacd.pac_period_id     = p_pac_period_id
      AND     mpacd.inventory_item_id = p_inventory_item_id
      AND     EXISTS (SELECT 1
                      FROM   cst_pac_low_level_codes cpllc
                      WHERE  cpllc.inventory_item_id = mpacd.inventory_item_id
                      AND    cpllc.low_level_code    = p_low_level_code
                      AND    cpllc.pac_period_id     = p_pac_period_id
                      AND    cpllc.cost_group_id     = p_cost_group_id);
  END IF;


  /****************************************************************************
   Post variance to the last transaction in the last cost owned txn category
   processed.
  ****************************************************************************/
  l_stmt_num := 30;
  FORALL l_index IN l_cost_layer_id_tbl.FIRST..l_cost_layer_id_tbl.LAST
  UPDATE mtl_pac_actual_cost_details mpacd
  SET    variance_amount = (SELECT decode (sign(l_period_quantity),
                                           0, cpicd.item_balance,
                                           (-1 * sign(cpicd.item_balance)), cpicd.item_balance,
                                           0)
                            FROM   cst_pac_item_costs cpic,
                                   cst_pac_item_cost_details cpicd
                            WHERE  cpic.cost_layer_id    = cpicd.cost_layer_id
                            AND    cpicd.cost_layer_id   = l_cost_layer_id_tbl (l_index)
                            AND    cpicd.cost_element_id = mpacd.cost_element_id
                            AND    cpicd.level_type      = mpacd.level_type),
         last_update_date       = sysdate,
         last_updated_by        = p_user_id,
         last_update_login      = p_login_id,
         request_id             = p_request_id,
         program_application_id = p_prog_appl_id,
         program_id             = p_prog_id,
         program_update_date    = sysdate
  WHERE  transaction_id      = l_last_txn_id_tbl (l_index)
  AND    mpacd.cost_group_id = p_cost_group_id
  AND    mpacd.pac_period_id = p_pac_period_id
  AND    mpacd.cost_layer_id = l_cost_layer_id_tbl(l_index)
  AND    (cost_element_id, level_type) = (SELECT cost_element_id, level_type
                                          FROM   cst_pac_item_cost_details cpicd
                                          WHERE  cpicd.cost_layer_id = l_cost_layer_id_tbl (l_index)
                                          AND    cpicd.cost_element_id = mpacd.cost_element_id
                                          AND    cpicd.level_type = mpacd.level_type);


  -- Update Item Cost, item balance
  l_stmt_num := 50;

  IF (p_low_level_code = -1) THEN
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
                      p_user_id,
                      p_login_id,
                      p_request_id,
                      p_prog_appl_id,
                      p_prog_id,
                      sysdate,
                      decode (sign(l_period_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / l_period_quantity),
                      decode (sign(l_period_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(l_period_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              (cpicd.item_balance / l_period_quantity) * cpic.total_layer_quantity),
                      /* cpicd.item_balance and l_period_quantity correspond to the balance and quantity after processing category 8
                         cpic.total_layer_quantity corresponds to the quantity after processing category 9 */
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN (select cost_layer_id
			               from cst_pac_item_costs
			             where inventory_item_id = p_inventory_item_id
			               and pac_period_id = p_pac_period_id
			               and cost_group_id = p_cost_group_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id     = p_pac_period_id
                     AND    cppb.cost_group_id     = p_cost_group_id
                     AND    cppb.cost_layer_id     = cpicd.cost_layer_id
                     AND    cppb.cost_element_id   = cpicd.cost_element_id
                     AND    cppb.level_type        = cpicd.level_type
                     AND    cppb.inventory_item_id = p_inventory_item_id)
      AND    NOT EXISTS (SELECT 1
                         FROM   cst_pac_low_level_codes cpllc
                         WHERE  cpllc.pac_period_id = p_pac_period_id
                         AND    cpllc.cost_group_id = p_cost_group_id
                         AND    cpllc.inventory_item_id = p_inventory_item_id);

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
             burden_cost
             ) =
              (SELECT   p_user_id,
                        sysdate,
                        p_login_id,
                        p_request_id,
                        p_prog_appl_id,
                        p_prog_id,
                        sysdate,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,1,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,2,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,3,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,4,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,5,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,1,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,2,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,3,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,4,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,5,item_cost,0),0)) ,
                        SUM(DECODE(cost_element_id,1,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,2,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,3,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,4,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,5,item_cost,0)) ,
                        SUM(DECODE(level_type,2,item_cost,0))  ,
                        SUM(DECODE(level_type,1,item_cost,0))  ,
                        SUM(item_cost) ,
                        SUM(item_buy_cost)  ,
                        SUM(item_make_cost),
                        SUM(DECODE(cost_element_id,2,DECODE(level_type,2,item_cost,0),item_cost)) ,
                        SUM(DECODE(cost_element_id,2,DECODE(level_type,1,item_cost,0),0))
                  FROM  cst_pac_item_cost_details cpicd
                 WHERE  cpicd.cost_layer_id  = cpic.cost_layer_id)
        WHERE cpic.pac_period_id = p_pac_period_id
	AND   cpic.cost_group_id = p_cost_group_id
	AND   cpic.inventory_item_id = p_inventory_item_id
	AND   EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id     = p_pac_period_id
                      AND    cppb.cost_group_id     = p_cost_group_id
                      AND    cppb.cost_layer_id     = cpic.cost_layer_id
                      AND    cppb.inventory_item_id = p_inventory_item_id)
        AND NOT EXISTS (SELECT 1
                        FROM   cst_pac_low_level_codes cpllc
                        WHERE  cpllc.inventory_item_id = cpic.inventory_item_id
                        AND    cpllc.pac_period_id     = p_pac_period_id
                        AND    cpllc.cost_group_id     = p_cost_group_id)
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
                      p_user_id,
                      p_login_id,
                      p_request_id,
                      p_prog_appl_id,
                      p_prog_id,
                      sysdate,
                      decode (sign(l_period_quantity),
                              0, cpicd.item_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.item_balance / l_period_quantity),
                      decode (sign(l_period_quantity),
                              0, cpicd.item_buy_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.buy_quantity,
                                      0, 0,
                                      cpicd.buy_balance / cpic.buy_quantity)),
                      decode (sign(l_period_quantity),
                              0, cpicd.item_make_cost,
                              (-1 * sign(cpicd.item_balance)), 0,
                              decode (cpic.make_quantity,
                                      0, 0,
                                      cpicd.make_balance / cpic.make_quantity)),
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              (cpicd.item_balance / l_period_quantity) * cpic.total_layer_quantity),
                      /* cpicd.item_balance and l_period_quantity correspond to the balance and quantity after processing category 8
                         cpic.total_layer_quantity corresponds to the quantity after processing category 9 */
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.buy_balance),
                      decode (sign (l_period_quantity),
                              0, 0,
                              (-1 * sign(cpicd.item_balance)), 0,
                              cpicd.make_balance)
                     FROM  cst_pac_item_costs cpic
                     WHERE cpic.cost_layer_id = cpicd.cost_layer_id)
      WHERE  cpicd.cost_layer_id IN (select cost_layer_id
			               from cst_pac_item_costs
			             where inventory_item_id = p_inventory_item_id
			               and pac_period_id = p_pac_period_id
			               and cost_group_id = p_cost_group_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_period_balances cppb
                     WHERE  cppb.pac_period_id     = p_pac_period_id
                     AND    cppb.cost_group_id     = p_cost_group_id
                     AND    cppb.cost_layer_id     = cpicd.cost_layer_id
                     AND    cppb.cost_element_id   = cpicd.cost_element_id
                     AND    cppb.level_type        = cpicd.level_type
                     AND    cppb.inventory_item_id = p_inventory_item_id)
      AND    EXISTS (SELECT 1
                     FROM   cst_pac_low_level_codes cpllc
                     WHERE  cpllc.low_level_code    = p_low_level_code
                     AND    cpllc.pac_period_id     = p_pac_period_id
                     AND    cpllc.cost_group_id     = p_cost_group_id
                     );

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
             burden_cost
            ) =
               (SELECT  p_user_id,
                        sysdate,
                        p_login_id,
                        p_request_id,
                        p_prog_appl_id,
                        p_prog_id,
                        sysdate,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,1,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,2,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,3,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,4,item_cost,0),0)) ,
                        SUM(DECODE(level_type,2,DECODE(cost_element_id,5,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,1,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,2,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,3,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,4,item_cost,0),0)) ,
                        SUM(DECODE(level_type,1,DECODE(cost_element_id,5,item_cost,0),0)) ,
                        SUM(DECODE(cost_element_id,1,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,2,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,3,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,4,item_cost,0)) ,
                        SUM(DECODE(cost_element_id,5,item_cost,0)) ,
                        SUM(DECODE(level_type,2,item_cost,0))  ,
                        SUM(DECODE(level_type,1,item_cost,0))  ,
                        SUM(item_cost) ,
                        SUM(item_buy_cost)  ,
                        SUM(item_make_cost),
                        SUM(DECODE(cost_element_id,2,DECODE(level_type,2,item_cost,0),item_cost)) ,
                        SUM(DECODE(cost_element_id,2,DECODE(level_type,1,item_cost,0),0))
                  FROM  cst_pac_item_cost_details cpicd
                 WHERE  cpicd.cost_layer_id  = cpic.cost_layer_id)
        WHERE cpic.pac_period_id = p_pac_period_id
	AND   cpic.cost_group_id = p_cost_group_id
	AND   cpic.inventory_item_id = p_inventory_item_id
	AND   EXISTS (SELECT 1
                      FROM   cst_pac_period_balances cppb
                      WHERE  cppb.pac_period_id     = p_pac_period_id
                      AND    cppb.cost_group_id     = p_cost_group_id
                      AND    cppb.cost_layer_id     = cpic.cost_layer_id
                      AND    cppb.inventory_item_id = p_inventory_item_id)
        AND   EXISTS (SELECT 1
                      FROM   cst_pac_low_level_codes cpllc
                      WHERE  cpllc.low_level_code    = p_low_level_code
                      AND    cpllc.inventory_item_id = cpic.inventory_item_id
                      AND    cpllc.pac_period_id     = p_pac_period_id
                      AND    cpllc.cost_group_id     = p_cost_group_id)
        AND EXISTS
             (SELECT 'there is detail cost'
              FROM   cst_pac_item_cost_details cpicd
              WHERE  cpicd.cost_layer_id = cpic.cost_layer_id);
  END IF;

  FND_FILE.put_line
  ( FND_FILE.log
  , '<< CST_PERIODIC_ABSORPTION_PROC:Calc_Pmac_For_Interorg'
  );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
WHEN OTHERS THEN
    ROLLBACK;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Calc_Pmac_For_Interorg;


--=====================================================================================
-- PROCEDURE : Calc_Pmac_Update_Cppb    PRIVATE
-- COMMENT   : This procedure invokes
--           : logic equivalent of CSTPPWAC.calculate_periodic_cost for each cost group
--           : CSTPPWAC.update_cppb for each cost groups
--           : Calculates PAC in CPICD, CPIC
--           : Variance Amount is updated for last transaction of a transaction
--           : category 8 interorg receipts
--           : Updates CPPB with period balance, variance amount
--           : Procedure is invoked after the iteration process for
--           : each interorg item once the tolerance is achieved
--======================================================================================
PROCEDURE Calc_Pmac_Update_Cppb(p_pac_period_id     IN NUMBER
                               ,p_cost_type_id      IN NUMBER
                               ,p_cost_group_id     IN NUMBER
                               ,p_inventory_item_id IN NUMBER
                               ,p_end_date          IN DATE
                               ,p_user_id           IN NUMBER
                               ,p_login_id          IN NUMBER
                               ,p_req_id            IN NUMBER
                               ,p_prg_id            IN NUMBER
                               ,p_prg_appid         IN NUMBER
                               )
IS
l_routine  CONSTANT VARCHAR2(30) := 'Calc_Pmac_Update_Cppb';

l_cg_idx         BINARY_INTEGER;
l_low_level_code NUMBER;
l_cost_group_id  NUMBER;
l_period_quantity NUMBER;

-- Cursor to get a low level code for an item in that cost group
CURSOR get_llc_cur(c_pac_period_id     NUMBER
                  ,c_cost_group_id     NUMBER
                  ,c_inventory_item_id NUMBER
                  )
IS
SELECT
  low_level_code
FROM cst_pac_low_level_codes
WHERE pac_period_id     = c_pac_period_id
  AND cost_group_id     = c_cost_group_id
  AND inventory_item_id = c_inventory_item_id;

l_error_num         NUMBER;
l_error_code        VARCHAR2(240);
l_error_msg         VARCHAR2(240);

BEGIN

  FND_FILE.put_line
  ( FND_FILE.log
  , '>> CST_PERIODIC_ABSORPTION_PROC.Calc_Pmac_Update_Cppb'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '>'
                  );
  END IF;

  l_cg_idx := p_cost_group_id;

  l_period_quantity := G_CST_GROUP_TBL(l_cg_idx).period_new_quantity;

  l_cost_group_id := p_cost_group_id;

    -- Get Low Level Code for an item in the cost group
    OPEN get_llc_cur(p_pac_period_id
                    ,l_cost_group_id
                    ,p_inventory_item_id
                    );
    FETCH get_llc_cur
     INTO l_low_level_code;

      IF get_llc_cur%NOTFOUND THEN
        -- no completion item
        l_low_level_code := -1;
      END IF;

    CLOSE get_llc_cur;

    -- Calculate PMAC in CPIC, CPICD; Variance amount update in last txn of
    -- transaction category 8 interorg receipts across CGs
    Calc_Pmac_For_Interorg
    (p_pac_period_id     => p_pac_period_id
    ,p_cost_type_id      => p_cost_type_id
    ,p_cost_group_id     => l_cost_group_id
    ,p_inventory_item_id => p_inventory_item_id
    ,p_low_level_code    => l_low_level_code
    ,p_user_id           => p_user_id
    ,p_login_id          => p_login_id
    ,p_request_id        => p_req_id
    ,p_prog_id           => p_prg_id
    ,p_prog_appl_id      => p_prg_appid
    );

      -- Update cumulative period balances in CPPB for interorg receipts
      -- with txn category 8
       UPDATE CST_PAC_PERIOD_BALANCES cppb
      SET    (last_updated_by,
              last_update_date,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              txn_category_value,
              period_quantity,
              period_balance,
              periodic_cost,
              variance_amount
	      ) =
              (SELECT p_user_id,
                      sysdate,
                      p_login_id,
                      p_req_id,
                      p_prg_appid,
                      p_prg_id,
                      sysdate,
                      (SELECT  sum (nvl (mpacd.actual_cost, 0) * nvl(mmt.periodic_primary_quantity,0))
                       FROM   mtl_pac_actual_cost_details mpacd,
		              mtl_material_transactions mmt
                       WHERE   mpacd.txn_category   = 8
			 AND   mpacd.inventory_item_id = p_inventory_item_id
                         AND   mpacd.pac_period_id = p_pac_period_id
                         AND   mpacd.cost_group_id = l_cost_group_id
			 AND   mpacd.transaction_id = mmt.transaction_id
			 AND   mpacd.inventory_item_id = mmt.inventory_item_id
                         AND   mpacd.cost_layer_id = cppb.cost_layer_id
                         AND   mpacd.cost_element_id = cppb.cost_element_id
                         AND   mpacd.level_type = cppb.level_type),
                      l_period_quantity,
                      l_period_quantity * cpicd.item_cost,
                      cpicd.item_cost,
                      (SELECT  sum (nvl (mpacd.variance_amount, 0))
                       FROM    mtl_pac_actual_cost_details mpacd
                       WHERE   mpacd.txn_category   = 8
                         AND   mpacd.inventory_item_id = p_inventory_item_id
                         AND   mpacd.pac_period_id = p_pac_period_id
                         AND   mpacd.cost_group_id = l_cost_group_id
                         AND   mpacd.cost_layer_id = cppb.cost_layer_id
                         AND   mpacd.cost_element_id = cppb.cost_element_id
                         AND   mpacd.level_type = cppb.level_type)
               FROM    cst_pac_item_cost_details cpicd,
                       cst_pac_item_costs cpic
               WHERE   cpic.cost_layer_id = cpicd.cost_layer_id
               AND     cppb.cost_layer_id = cpicd.cost_layer_id
               AND     cppb.cost_element_id = cpicd.cost_element_id
               AND     cppb.level_type = cpicd.level_type)
      WHERE   cppb.pac_period_id = p_pac_period_id
      AND     cppb.cost_group_id = l_cost_group_id
      AND     cppb.inventory_item_id = p_inventory_item_id
      AND     cppb.txn_category = 8
      AND     EXISTS (SELECT 1
                      FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                      WHERE cppb.cost_layer_id = cpicd1.cost_layer_id
                      AND   cppb.cost_element_id = cpicd1.cost_element_id
                      AND   cppb.level_type = cpicd1.level_type);

      UPDATE CST_PAC_PERIOD_BALANCES cppb
      SET    txn_category_value =
                      (SELECT  sum (nvl (mpacd.actual_cost, 0) * nvl(mmt.periodic_primary_quantity,0))
                       FROM    mtl_pac_actual_cost_details mpacd,
		               mtl_material_transactions mmt
                       WHERE   mpacd.txn_category   = 9
                         AND   mpacd.inventory_item_id = cppb.inventory_item_id
                         AND   mpacd.pac_period_id = cppb.pac_period_id
			 AND   mpacd.transaction_id = mmt.transaction_id
			 AND   mpacd.inventory_item_id = mmt.inventory_item_id
                         AND   mpacd.cost_group_id = cppb.cost_group_id
                         AND   mpacd.cost_layer_id = cppb.cost_layer_id
                         AND   mpacd.cost_element_id = cppb.cost_element_id
                         AND   mpacd.level_type = cppb.level_type)
      WHERE   cppb.pac_period_id = p_pac_period_id
      AND     cppb.cost_group_id = l_cost_group_id
      AND     cppb.inventory_item_id = p_inventory_item_id
      AND     cppb.txn_category = 9
      AND     EXISTS (SELECT 1
                      FROM  CST_PAC_ITEM_COST_DETAILS cpicd1
                      WHERE cppb.cost_layer_id = cpicd1.cost_layer_id
                      AND   cppb.cost_element_id = cpicd1.cost_element_id
                      AND   cppb.level_type = cpicd1.level_type);

  FND_FILE.put_line
  ( FND_FILE.log
  , '<< CST_PERIODIC_ABSORPTION_PROC.Calc_Pmac_Update_Cppb'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Calc_Pmac_Update_Cppb;

-- +========================================================================+
-- PROCEDURE: Create_Mpacd_With_New_Values  PRIVATE UTILITY
-- PARAMETERS: p_pac_period_id
--             p_inventory_item_id  interorg item id
-- COMMENT:
--   This to copy all the records into MPACD from pac transaction temp table
--   only for a given interorg item in the current BOM level for the user
--   specified PAC period
--   Bug 7674673 fix : MPACD.txn_category 8 for cost owned interorg receipts,
--   9 for cost derived interorg shipments
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Create_Mpacd_With_New_Values ( p_pac_period_id     IN NUMBER
                                       , p_inventory_item_id IN NUMBER
				       , p_cost_group_id     IN NUMBER DEFAULT NULL
                                       )
IS

l_routine CONSTANT VARCHAR2(30) := 'create_mpacd_with_new_values';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

    INSERT INTO MTL_PAC_ACTUAL_COST_DETAILS
    ( COST_GROUP_ID
    , TRANSACTION_ID
    , PAC_PERIOD_ID
    , COST_TYPE_ID
    , COST_ELEMENT_ID
    , LEVEL_TYPE
    , INVENTORY_ITEM_ID
    , COST_LAYER_ID
    , ACTUAL_COST
    , VARIANCE_AMOUNT
    , USER_ENTERED
    , INSERTION_FLAG
    , TRANSACTION_COSTED_DATE
    , TXN_CATEGORY -- bug 7674673 fix
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , REQUEST_ID
    , PROGRAM_APPLICATION_ID
    , PROGRAM_ID
    , PROGRAM_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    )
    SELECT
      mpacdt.cost_group_id
    , mpacdt.transaction_id
    , mpacdt.pac_period_id
    , mpacdt.cost_type_id
    , mpacdt.cost_element_id
    , mpacdt.level_type
    , mpacdt.inventory_item_id
    , mpacdt.cost_layer_id
    , mpacdt.actual_cost
    , mpacdt.variance_amount
    , mpacdt.user_entered
    , mpacdt.insertion_flag
    , mpacdt.transaction_costed_date
    , DECODE(cpitt.txn_type,1,8,2,9) txn_category  -- bug 7674673 fix
    , SYSDATE
    , FND_GLOBAL.user_id
    , SYSDATE
    , FND_GLOBAL.user_id
    , FND_GLOBAL.conc_request_id
    , FND_GLOBAL.prog_appl_id
    , FND_GLOBAL.conc_program_id
    , SYSDATE
    , FND_GLOBAL.login_id
    FROM MTL_PAC_ACT_CST_DTL_TEMP mpacdt
        ,CST_PAC_INTERORG_TXNS_TMP cpitt
    WHERE mpacdt.pac_period_id     = p_pac_period_id
      AND mpacdt.inventory_item_id = p_inventory_item_id
      AND mpacdt.cost_group_id     = nvl(p_cost_group_id, mpacdt.cost_group_id)
      AND EXISTS (SELECT 'X'
                  FROM cst_pac_intorg_itms_temp cpiit
	          WHERE cpiit.pac_period_id     = mpacdt.pac_period_id
		    AND cpiit.inventory_item_id = mpacdt.inventory_item_id
		    AND cpiit.cost_group_id     = mpacdt.cost_group_id
		    AND cpiit.diverging_flag    = 'N'
		    AND cpiit.interorg_receipt_flag = 'Y')
      AND mpacdt.transaction_id    = cpitt.transaction_id
      AND mpacdt.pac_period_id     = cpitt.pac_period_id
      AND mpacdt.cost_group_id     = cpitt.cost_group_id
      AND mpacdt.inventory_item_id = cpitt.inventory_item_id;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                    );
    END IF;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END; -- Create Mpacd With New Values


-- +========================================================================+
-- PROCEDURE: Update_Cpicd_With_New_Values  PRIVATE UTILITY
-- PARAMETERS: p_pac_period_id
--             p_inventory_item_id    interorg item id
-- COMMENT:
--   To update corresponding layers in cst_pac_item_cost_details
--   with new cost, new buy cost, new make cost from MPACD for the period
--   To update layer cost information in CPIC
--   NOTE: PAC Transactions belongs to current BOM level interorg item
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Update_Cpicd_With_New_Values(p_pac_period_id     IN NUMBER
                                      ,p_inventory_item_id IN NUMBER
				      ,p_cost_group_id     IN NUMBER DEFAULT NULL
 			              ,p_cost_type_id      IN NUMBER
				      ,p_end_date          IN DATE
                                      )
IS

l_routine CONSTANT VARCHAR2(30) := 'update_cpicd_with_new_values';

CURSOR mpacd_distinct_cur(c_pac_period_id     NUMBER
                         ,c_inventory_item_id NUMBER
			 ,c_cost_group_id     NUMBER
                         )
IS
  SELECT
    DISTINCT mpacd.cost_layer_id
  , mpacd.cost_group_id
  , mpacd.cost_element_id
  , mpacd.level_type
  FROM  mtl_pac_actual_cost_details mpacd, cst_pac_intorg_itms_temp cpiit
  WHERE cpiit.pac_period_id = c_pac_period_id
    AND cpiit.inventory_item_id = c_inventory_item_id
    AND cpiit.cost_group_id = nvl(c_cost_group_id, cpiit.cost_group_id)
    AND cpiit.diverging_flag = 'N'
    AND cpiit.interorg_receipt_flag = 'Y'
    AND mpacd.pac_period_id     = cpiit.pac_period_id
    AND mpacd.inventory_item_id = cpiit.inventory_item_id
    AND mpacd.cost_group_id = cpiit.cost_group_id
  ORDER BY
    mpacd.cost_layer_id
  , mpacd.cost_element_id
  , mpacd.level_type;

mpacd_distinct_cur_row  mpacd_distinct_cur%ROWTYPE;

CURSOR cost_group_cur(c_item_id       NUMBER
                     ,c_pac_period_id NUMBER
                      )
IS
SELECT  cost_group_id
FROM cst_pac_intorg_itms_temp
WHERE inventory_item_id = c_item_id
  AND pac_period_id     = c_pac_period_id
  AND diverging_flag = 'N'
  AND interorg_receipt_flag = 'Y';

l_cg_elmnt_lv_idx   BINARY_INTEGER;

l_item_cost    NUMBER;
l_item_balance NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || 'Item Id '||p_inventory_item_id|| ' Cost Group Id '||p_cost_group_id|| '<'
                  );
  END IF;

  FOR mpacd_idx IN mpacd_distinct_cur(p_pac_period_id
                                     ,p_inventory_item_id
				     ,p_cost_group_id
                                     ) LOOP

    l_cg_elmnt_lv_idx := to_char(mpacd_idx.cost_group_id) ||
      to_char(mpacd_idx.cost_element_id) || to_char(mpacd_idx.level_type);
    l_item_cost    := G_CG_PWAC_COST_TBL(l_cg_elmnt_lv_idx).final_new_cost;
    l_item_balance := G_CG_PWAC_COST_TBL(l_cg_elmnt_lv_idx).period_new_balance;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine ||'.cgellvic'
                    , 'Cost Layer Id:' || mpacd_idx.cost_layer_id || 'Cost Group element level idx:' || l_cg_elmnt_lv_idx || ' Item Cost:' || l_item_cost || ' Item Balance:' || l_item_balance
                    );
    END IF;

    -- ========================================================
    -- Update cpicd with new cost, new buy cost, new make cost
    -- ========================================================
   UPDATE cst_pac_item_cost_details cpicd
    SET  last_update_date       = SYSDATE
        ,last_updated_by        = FND_GLOBAL.user_id
        ,last_update_login      = FND_GLOBAL.login_id
        ,request_id             = FND_GLOBAL.conc_request_id
        ,program_application_id = FND_GLOBAL.prog_appl_id
        ,program_id             = FND_GLOBAL.conc_program_id
        ,program_update_date    = SYSDATE
        ,item_cost              = l_item_cost
        ,item_balance           = l_item_balance
    WHERE cpicd.cost_layer_id   = mpacd_idx.cost_layer_id
      AND cpicd.cost_element_id = mpacd_idx.cost_element_id
      AND cpicd.level_type      = mpacd_idx.level_type;

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
                (SELECT mpacd_idx.cost_layer_id,
                        mpacd_idx.cost_element_id,
                        mpacd_idx.level_type,
                        sysdate,
                        FND_GLOBAL.user_id,
                        sysdate,
                        FND_GLOBAL.user_id,
                        FND_GLOBAL.login_id,
                        FND_GLOBAL.conc_request_id,
                        FND_GLOBAL.prog_appl_id,
                        FND_GLOBAL.conc_program_id,
                        sysdate,
                        l_item_cost,
                        0,
                        0,
                        l_item_balance,
                        0,
                        0
                FROM    dual
                WHERE   NOT EXISTS (SELECT 1
                                    FROM   cst_pac_item_cost_details cpicd1
                                    WHERE  cpicd1.cost_layer_id = mpacd_idx.cost_layer_id
                                    AND    cpicd1.cost_element_id = mpacd_idx.cost_element_id
                                    AND    cpicd1.level_type = mpacd_idx.level_type));
   -- =================================================================
   -- Update layer costs information
   -- =================================================================

   UPDATE cst_pac_item_costs cpic
   SET (last_updated_by
       ,last_update_date
       ,last_update_login
       ,request_id
       ,program_application_id
       ,program_id
       ,program_update_date
       ,pl_material
       ,pl_material_overhead
       ,pl_resource
       ,pl_outside_processing
       ,pl_overhead
       ,tl_material
       ,tl_material_overhead
       ,tl_resource
       ,tl_outside_processing
       ,tl_overhead
       ,material_cost
       ,material_overhead_cost
       ,resource_cost
       ,outside_processing_cost
       ,overhead_cost
       ,pl_item_cost
       ,tl_item_cost
       ,item_cost
       ,item_buy_cost
       ,item_make_cost
       ,unburdened_cost
       ,burden_cost
       ) =
     (SELECT
        FND_GLOBAL.user_id
      , SYSDATE
      , FND_GLOBAL.login_id
      , FND_GLOBAL.conc_request_id
      , FND_GLOBAL.prog_appl_id
      , FND_GLOBAL.conc_program_id
      , SYSDATE
      , SUM(DECODE(level_type,2,DECODE(cost_element_id,1,item_cost,0),0))
      , SUM(DECODE(level_type,2,DECODE(cost_element_id,2,item_cost,0),0))
      , SUM(DECODE(level_type,2,DECODE(cost_element_id,3,item_cost,0),0))
      , SUM(DECODE(level_type,2,DECODE(cost_element_id,4,item_cost,0),0))
      , SUM(DECODE(level_type,2,DECODE(cost_element_id,5,item_cost,0),0))
      , SUM(DECODE(level_type,1,DECODE(cost_element_id,1,item_cost,0),0))
      , SUM(DECODE(level_type,1,DECODE(cost_element_id,2,item_cost,0),0))
      , SUM(DECODE(level_type,1,DECODE(cost_element_id,3,item_cost,0),0))
      , SUM(DECODE(level_type,1,DECODE(cost_element_id,4,item_cost,0),0))
      , SUM(DECODE(level_type,1,DECODE(cost_element_id,5,item_cost,0),0))
      , SUM(DECODE(cost_element_id,1,item_cost,0))
      , SUM(DECODE(cost_element_id,2,item_cost,0))
      , SUM(DECODE(cost_element_id,3,item_cost,0))
      , SUM(DECODE(cost_element_id,4,item_cost,0))
      , SUM(DECODE(cost_element_id,5,item_cost,0))
      , SUM(DECODE(level_type,2,item_cost,0))
      , SUM(DECODE(level_type,1,item_cost,0))
      , SUM(item_cost)
      , SUM(item_buy_cost)
      , SUM(item_make_cost)
      , SUM(DECODE(cost_element_id,2,DECODE(level_type,2,item_cost,0),item_cost))
      , SUM(DECODE(cost_element_id,2,DECODE(level_type,1,item_cost,0),0))
     FROM  cst_pac_item_cost_details cpicd
     WHERE cpicd.cost_layer_id  = mpacd_idx.cost_layer_id
     GROUP BY cpicd.cost_layer_id)
   WHERE cpic.cost_layer_id = mpacd_idx.cost_layer_id
   AND EXISTS
         (SELECT 'there is detail cost'
          FROM   cst_pac_item_cost_details cpicd
          WHERE  cpicd.cost_layer_id = mpacd_idx.cost_layer_id);


  END LOOP; -- end of mpacd temp loop

  -- ================================================================
  -- Calculate Periodic Cost in CPICD, CPIC at the end of iteration
  -- process; Update Variance Amount in the last transaction of MPACD
  -- at the end of iteration process; Invoke calculate_periodic_cost
  -- for each cost group;
  -- Update CPPB Invoke Update_item_cppb for each CG
  -- ================================================================
  IF p_cost_group_id IS NOT NULL THEN
     Calc_Pmac_Update_Cppb(p_pac_period_id     => p_pac_period_id
                          ,p_cost_type_id      => p_cost_type_id
                          ,p_cost_group_id     => p_cost_group_id
                          ,p_inventory_item_id => p_inventory_item_id
                          ,p_end_date          => p_end_date
                          ,p_user_id           => FND_GLOBAL.user_id
                          ,p_login_id          => FND_GLOBAL.login_id
                          ,p_req_id            => FND_GLOBAL.conc_request_id
                          ,p_prg_id            => FND_GLOBAL.conc_program_id
                          ,p_prg_appid         => FND_GLOBAL.prog_appl_id
                          );
  ELSE
    FOR cost_group_idx IN cost_group_cur(p_inventory_item_id
                                      ,p_pac_period_id)
      LOOP
          Calc_Pmac_Update_Cppb(p_pac_period_id     => p_pac_period_id
                               ,p_cost_type_id      => p_cost_type_id
                               ,p_cost_group_id     => cost_group_idx.cost_group_id
                               ,p_inventory_item_id => p_inventory_item_id
                               ,p_end_date          => p_end_date
                               ,p_user_id           => FND_GLOBAL.user_id
                               ,p_login_id          => FND_GLOBAL.login_id
                               ,p_req_id            => FND_GLOBAL.conc_request_id
                               ,p_prg_id            => FND_GLOBAL.conc_program_id
                               ,p_prg_appid         => FND_GLOBAL.prog_appl_id
                               );
      END LOOP;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                    );
    END IF;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END; -- Update Cpicd With New Values


-- +========================================================================+
-- PROCEDURE: Set_Phase5_Status
-- PARAMETERS:
--  p_legal_entity_id       NUMBER   Legal Entity
--  p_cost_group_id         NUMBER   Valid Cost Group in LE
--  p_period_id             NUMBER   PAC Period Id
--  p_phase_status          NUMBER
--    Not Applicable(0)
--    Un Processed  (1)
--    Running       (2)
--    Error         (3)
--    Complete      (4)
-- COMMENT:
-- This procedure sets the phase 5 status to Un Processed (1)
-- at the end of final iteration or when the tolerance is achieved
--
-- USAGE: This procedure is invoked from api:iteration_process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Set_Phase5_Status(p_legal_entity_id  IN     NUMBER
                           ,p_period_id        IN     NUMBER
                           ,p_period_end_date  IN     DATE
                           ,p_phase_status     IN     NUMBER
                           )
IS

l_routine CONSTANT VARCHAR2(30) := 'Set_Phase5_Status';

l_cost_group_id     NUMBER;
l_cst_group_idx     BINARY_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  -- Set Phase 5 Status for all the valid cost groups
  l_cst_group_idx := G_CST_GROUP_TBL.FIRST;
  WHILE (l_cst_group_idx <= G_CST_GROUP_TBL.LAST) LOOP

    -- index itself is the Cost Group Id
    l_cost_group_id := l_cst_group_idx;

    -- Update Process Phases Table for Iteration Process
    UPDATE CST_PAC_PROCESS_PHASES
       SET process_status         =  p_phase_status
          ,process_date           =  SYSDATE
          ,process_upto_date     = decode(p_phase_status,4,p_period_end_date,NULL)
          ,last_update_date        = SYSDATE
          ,last_updated_by         = FND_GLOBAL.user_id
          ,request_id              = FND_GLOBAL.conc_request_id
          ,program_application_id  = FND_GLOBAL.prog_appl_id
          ,program_id              = FND_GLOBAL.conc_program_id
          ,program_update_date     = SYSDATE
          ,last_update_login       = FND_GLOBAL.login_id
    WHERE pac_period_id  =  p_period_id
      AND cost_group_id  =  l_cost_group_id
      AND process_phase  =  5;

  l_cst_group_idx := G_CST_GROUP_TBL.NEXT(l_cst_group_idx);

  END LOOP;

  -- the following commit is required to prevent
  -- a complete rollback if the process errors out
  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

END; -- Set_Phase5_Status


-- +========================================================================+
-- PROCEDURE: Set_Process_Status
-- +========================================================================+
-- PROCEDURE: Set_Process_Status
-- PARAMETERS:
--  p_legal_entity_id       NUMBER   Legal Entity
--  p_period_id             NUMBER   PAC Period Id
--  p_period_end_date       DATE
--  p_phase_status          NUMBER
--    Not Applicable(0)
--    Un Processed  (1)
--    Running       (2)
--    Error         (3)
--    Complete      (4)
--    Resume        (5)  used when non-tolerance items exists
-- COMMENT:
-- This procedure sets the Interorg Transfer Cost Processor - iteration
-- process phase status.  The phase will be 7.  When the iteration process
-- is invoked through main program, the phase status will be set to 1
-- to start with indicating that the status is in Un Processed.
-- When the iteration process begins, the phase status will be set to 2
-- indicating that the status is in Running for all the valid cost groups
-- in the Legal Entity
-- If the iteration process completed with error the status is 3
-- If the iteration process completed where all the items achieved
-- tolerance, then the status is set to 4 - Complete.
-- If the iteration process completed where some of the items are left over
-- with no tolerance achieved AND the resume option is Iteration for non
-- tolerance items, then the status is set to 5 indicating that the
-- status is in Resume where the process is not completed yet.
-- If the iteration process completed where some of the items are left over
-- with no tolerance achieved AND the resume option is Final Iteration, then
-- the status is set to 4 - Complete indicating that the Iteration Process
-- is completed.
-- Update process_upto_date with the user specified process upto date at the
-- end of run options: Start while setting the phase status to 5 - Resume
--
-- USAGE: This procedure is invoked from api:iteration_process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Set_Process_Status( p_legal_entity_id  IN     NUMBER
                            , p_period_id        IN     NUMBER
                            , p_period_end_date  IN     DATE
                            , p_phase_status     IN     NUMBER
                            )
IS

l_routine CONSTANT VARCHAR2(30) := 'set_process_status';

l_cost_group_id     NUMBER;
l_cst_group_idx     BINARY_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  -- Set Phase Status for all the valid cost groups
  l_cst_group_idx := G_CST_GROUP_TBL.FIRST;
  WHILE (l_cst_group_idx <= G_CST_GROUP_TBL.LAST) LOOP

    -- index itself is the Cost Group Id
    l_cost_group_id := l_cst_group_idx;

    -- Update Process Phases Table for Iteration Process
    UPDATE CST_PAC_PROCESS_PHASES
       SET process_status         =  p_phase_status
          ,process_date           =  SYSDATE
          ,process_upto_date      = decode(p_phase_status,4,p_period_end_date,
                                                          5,p_period_end_date,
                                                          3,p_period_end_date,NULL)
          ,last_update_date        = SYSDATE
          ,last_updated_by         = FND_GLOBAL.user_id
          ,request_id              = FND_GLOBAL.conc_request_id
          ,program_application_id  = FND_GLOBAL.prog_appl_id
          ,program_id              = FND_GLOBAL.conc_program_id
          ,program_update_date     = SYSDATE
          ,last_update_login       = FND_GLOBAL.login_id
    WHERE pac_period_id  =  p_period_id
      AND cost_group_id  =  l_cost_group_id
      AND process_phase  =  7;

  l_cst_group_idx := G_CST_GROUP_TBL.NEXT(l_cst_group_idx);

  END LOOP;

  -- the following commit is required to prevent
  -- a complete rollback if the process errors out

  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;
END; -- Set_Process_Status


-- +============================================================================+
-- PROCEDURE: Verify_Tolerance_Of_Item
-- PARAMETERS:
--  p_cost_type_id          NUMBER   Cost Type Id
--  p_inventory_item_id     NUMBER   Interorg Item
--  p_inventory_item_number VARCHAR2 Inventory Item Number
--  p_period_id             NUMBER   PAC Period Id
--  p_period_start_date     DATE     PAC Period Start Date
--  p_period_end_date       DATE     PAC Period End Date
--  p_tolerance             NUMBER   User specified tolerance
--  p_iteration_num         NUMBER   Iteration Number
--  p_end_iteration_num     NUMBER   Last Iteration Number
--  x_tolerance_flag        VARCHAR2 Tolerance Flag
-- COMMENT:
--   This procedure determines the difference between PMAC of current iteration
--   and PMAC of previous iteration
--   Difference will be compared with user specified tolerance as given in the
--   parameter: p_tolerance.
--   If the expected tolerance is achieved for all the cost groups, then the
--   tolerance flag x_tolerance_flag is set to 'Y'.
--   If the tolerance NOT achieved for any of the cost groups, then the tolerance
--   flag x_tolerance_flag is set to 'N'.
-- USAGE: This procedure is invoked from api:iteration_process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +============================================================================+
PROCEDURE Verify_Tolerance_Of_Item(p_cost_type_id          IN  NUMBER
				  ,p_inventory_item_id     IN  NUMBER
                                  ,p_inventory_item_number IN  VARCHAR2
                                  ,p_period_id             IN  NUMBER
                                  ,p_period_start_date     IN  DATE
                                  ,p_period_end_date       IN  DATE
                                  ,p_tolerance             IN  NUMBER
                                  ,p_iteration_num         IN  NUMBER
                                  ,p_end_iteration_num     IN  NUMBER
                                  ,x_tolerance_flag        OUT NOCOPY VARCHAR2
                                  )
IS

l_routine CONSTANT VARCHAR2(30) := 'Verify_Tolerance_Of_Item';

-- Optimal Cost Group according to sequence number
-- NOTE: cost group without interorg receipts are not verified for tolerance.
CURSOR cost_group_item_info_cur(c_item_id        NUMBER
                               ,c_pac_period_id  NUMBER
                               )
IS
SELECT
  cost_group_id
, prev_itr_item_cost
, item_cost
FROM cst_pac_intorg_itms_temp
WHERE inventory_item_id = c_item_id
  AND pac_period_id     = c_pac_period_id
  AND interorg_receipt_flag = 'Y'
  AND DIVERGING_FLAG = 'N'
ORDER BY sequence_num;

cost_group_item_info_row  cost_group_item_info_cur%ROWTYPE;

l_correspond_actual_cost      NUMBER;
l_correspond_txn_flag         VARCHAR2(1);
l_cost_group_id               NUMBER;
-- Number of receipt cost element tolerance not achieved count
l_non_tol_count               NUMBER := 0;

l_inventory_item_number       VARCHAR2(1025);
l_correspond_org_id           NUMBER;

l_cost_group_id_idx           BINARY_INTEGER;
l_cost_group_name             VARCHAR2(10);

l_unit_trans_cost             NUMBER := 0;
l_moh_absorption_cost         NUMBER := 0;

l_diff_cg                     NUMBER;

-- Message variable to display output file messages
l_message   VARCHAR2(2000);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  -- Assign Inventory Item Number
  l_inventory_item_number := p_inventory_item_number;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.item'
                    , 'Inventory Item Id:' || p_inventory_item_id ||
                      ' Item Number:' || l_inventory_item_number
                    );
    END IF;

-- ==========================================================
-- Verify tolerance for each cost group
-- ==========================================================

-- Loop for each optimal cost group
-- NOTE: sequence num 1 is not used for tolerance check
--       interorg_receipt_flag should be 'Y'
OPEN cost_group_item_info_cur(p_inventory_item_id
                             ,p_period_id
                             );

FETCH cost_group_item_info_cur
 INTO cost_group_item_info_row;

WHILE (cost_group_item_info_cur%FOUND ) LOOP

  -- Display Inventory Item Id, Item number

  l_message := p_inventory_item_id ||'	'||l_inventory_item_number||'	';
  -- ======================================
  -- Display Cost Group PMAC iteration info
  -- ======================================
  l_cost_group_id_idx := cost_group_item_info_row.cost_group_id;
  l_cost_group_name := G_CST_GROUP_TBL(l_cost_group_id_idx).cost_group;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine ||'.cgname'
                    , 'Cost Group Index:' || l_cost_group_id_idx || ' Cost Group Name:' || l_cost_group_name ||
                      ' Prev Itr Item Cost:' || cost_group_item_info_row.prev_itr_item_cost ||
                      ' Curr Itr Item Cost:' || cost_group_item_info_row.item_cost
                    );
    END IF;

  -- difference between current iteration pmac item cost and previous iteration pmac
  -- item cost
  l_diff_cg :=
    ABS(nvl(cost_group_item_info_row.item_cost,0) - nvl(cost_group_item_info_row.prev_itr_item_cost,0));

  -- Output format should be same as specified in message CST_PAC_PMAC_ITR_PROMPT

  l_message :=  l_message||l_cost_group_name||'	'||p_iteration_num||'	'
                ||cost_group_item_info_row.item_cost||'	'||cost_group_item_info_row.prev_itr_item_cost||'	'||l_diff_cg;
  FND_FILE.put_line(FND_FILE.OUTPUT, l_message);

    IF l_diff_cg >  p_tolerance  THEN
      l_non_tol_count := 1;
   --   EXIT;
    END IF;

FETCH cost_group_item_info_cur
 INTO cost_group_item_info_row;

END LOOP; -- cost group item info cursor end loop

CLOSE cost_group_item_info_cur;

 IF l_non_tol_count = 0 THEN
    -- Tolerance achieved for all the interorg receipts
    x_tolerance_flag := 'Y';
    FND_FILE.put_line(FND_FILE.OUTPUT, G_TOL_ACHIEVED_MESSAGE);

  ELSE
    -- Tolerance not achieved for the interorg receipts
    -- There are some interorg receipts still yet to achieve the tolerance
    x_tolerance_flag  := 'N';
    FND_FILE.put_line(FND_FILE.OUTPUT, G_TOL_NOT_ACHIEVED_MESSAGE);

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'Item_id'||p_inventory_item_id ||'Iteration Number' ||p_iteration_num || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', 'Item_id'||p_inventory_item_id ||'Iteration Number' ||p_iteration_num ||'('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

END Verify_Tolerance_Of_Item;

-- +========================================================================+
-- PROCEDURE: Initialize
-- PARAMETERS:
--   p_legal_entity_id    IN  NUMBER
-- COMMENT:
--   This procedure is to initialize Global PL/SQL tables
--   G_CST_GROUP_TBL to store valid Cost Groups in Legal Entity
--   G_CST_GROUP_ORG_TBL to store valid organizations in those cost groups
--   This procedure is called by the API Iteration Process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Initialize
(  p_legal_entity_id    IN  NUMBER
)
IS
-- routine name local constant variable
l_routine  CONSTANT VARCHAR2(30) := 'Initialize';

-- Cursor to get valid Cost Groups
-- and corresponding Item Master Organization
CURSOR cst_group_le_cursor ( c_legal_entity_id NUMBER)
IS
  SELECT
    cost_group_id
  , cost_group
  , organization_id  master_organization_id
  FROM
    cst_cost_groups ccg
  WHERE legal_entity = c_legal_entity_id;

cst_group_row      cst_group_le_cursor%rowtype;

-- Cursor to get all the organizations across Cost Groups in Legal Entity
-- Function: check_cst_group is used to validate for the Cost Group in LE
CURSOR cst_group_org_cursor
IS
  SELECT
    cost_group_id
  , organization_id
  FROM
    cst_cost_group_assignments ccga
  WHERE check_cst_group(ccga.cost_group_id) = 'Y'
  ORDER BY cost_group_id;

cst_group_org_row  cst_group_org_cursor%rowtype;

-- binary integer variables
l_cost_group_id_idx     BINARY_INTEGER;
l_organization_id_idx   BINARY_INTEGER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , 'Initialize <'
                  );
  END IF;

  -- Delete records from PL/SQL table
  CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL.delete;
  CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL.delete;

  -- +================================================================*
  -- Get valid cost groups and store it in PL/SQL table
  -- G_CST_GROUP_TBL
  -- +================================================================*
  -- Get valid Cost Groups in Legal Entity
  OPEN cst_group_le_cursor(p_legal_entity_id);

  FETCH cst_group_le_cursor
   INTO cst_group_row;

  -- store the valid Cost Groups in PL/SQL table
  WHILE cst_group_le_cursor%FOUND LOOP
    l_cost_group_id_idx := cst_group_row.cost_group_id;
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).cost_group_id := cst_group_row.cost_group_id;
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).cost_group := cst_group_row.cost_group;
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).master_organization_id := cst_group_row.master_organization_id;
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).period_new_quantity := 0;

  FETCH cst_group_le_cursor
   INTO cst_group_row;

  END LOOP;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.valid_cost_group'
                  , 'Number of valid cost groups in LE:' || G_CST_GROUP_TBL.COUNT
                  );
  END IF;

  CLOSE cst_group_le_cursor;

  -- +================================================================*
  -- Get all the organizations in valid cost groups
  -- Store the organizations in PL/SQL table G_CST_GROUP_ORG_TBL
  -- +================================================================*
  -- Get All the Organizations in valid cost groups
  OPEN cst_group_org_cursor;

  FETCH cst_group_org_cursor
   INTO cst_group_org_row;

  -- Store all the organizations across valid cost groups
  WHILE cst_group_org_cursor%FOUND LOOP
    l_organization_id_idx := cst_group_org_row.organization_id;
    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL(l_organization_id_idx).cost_group_id := cst_group_org_row.cost_group_id;

    CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_ORG_TBL(l_organization_id_idx).organization_id := cst_group_org_row.organization_id;

  FETCH cst_group_org_cursor
   INTO cst_group_org_row;

  END LOOP;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_HEAD || l_routine || '.valid_organizations'
                  , 'Number of valid organizations:'|| G_CST_GROUP_ORG_TBL.COUNT
                  );
  END IF;

  CLOSE cst_group_org_cursor;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                  );
  END IF;
 FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

END Initialize;

-- +========================================================================+
-- PROCEDURE: Populate_Temp_Tables
-- PARAMETERS:
--   p_cost_group_id         IN  NUMBER
--   p_period_start_date     IN  DATE
--   p_period_end_date       IN  DATE
-- COMMENT:
--   This procedure is called by the Iterative PAC Worker
--   Support Transfer pricing option as below
--   Value 0: No include the interorg txns of OM
--   Value 1: Yes, Price not as incoming cost include the interorg txns of OM
--   Value 2: Yes, Price as incoming cost do not include the interorg txns of OM
--   OPM SCENARIO: Exclude any interorg transactions due to OPM organization
--   Cost Owned Txns:
--   Exclude Direct interorg receipt txn coming from OPM org
--   Exclude Intransit Shipment txn FOB:Shipment processed in discrete coming
--   from OPM organization
--   Exclude Logical intransit receipt (15) due to OPM org
--   Cost Derived Txns:
--   Exclude Direct interorg shipment txn to OPM org
--   Exclude Intransit receipt txn FOB:Receipt processed in discrete due to OPM
--   Exclude Logical intransit shipment (22) due to OPM org
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+

PROCEDURE Populate_Temp_Tables
(  p_cost_group_id         IN      NUMBER
,  p_period_id             IN      NUMBER
,  p_period_start_date     IN      DATE
,  p_period_end_date       IN      DATE
)
IS

-- Routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Populate_Temp_Tables';
l_txn_type NUMBER := 0;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  DELETE FROM CST_PAC_INTERORG_TXNS_TMP WHERE COST_GROUP_ID = p_cost_group_id AND PAC_PERIOD_ID = p_period_id;

  --Cost owned across CG interorg transactions for this cost group being populated in CST_PAC_INTERORG_TXNS_TMP
  l_txn_type := 1;

  INSERT INTO CST_PAC_INTERORG_TXNS_TMP
  (	  transaction_id,
	  transaction_action_id,
	  transaction_source_type_id,
	  inventory_item_id,
	  primary_quantity,
	  periodic_primary_quantity,
	  organization_id,
	  transfer_organization_id,
	  subinventory_code,
	  transfer_price,
	  shipment_number,
	  transfer_transaction_id,
	  waybill_airbill,
	  transfer_cost,
	  transportation_cost,
	  transfer_percentage,
	  cost_group_id,
	  transfer_cost_group_id,
	  txn_type,
	  pac_period_id)
 (SELECT
  mmt.transaction_id   transaction_id
, mmt.transaction_action_id   transaction_action_id
, mmt.transaction_source_type_id  transaction_source_type_id
, mmt.inventory_item_id  inventory_item_id
, mmt.primary_quantity   primary_quantity
, mmt.periodic_primary_quantity  periodic_primary_quantity
, mmt.organization_id  organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code  subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
, mmt.shipment_number shipment_number
, mmt.transfer_transaction_id  transfer_transaction_id
, mmt.waybill_airbill waybill_airbill
, nvl(mmt.transfer_cost,0)  transfer_cost
, nvl(mmt.transportation_cost,0)  transportation_cost
, nvl(mmt.transfer_percentage,0)  transfer_percentage
, p_cost_group_id cost_group_id
, decode(c1.cost_group_id, p_cost_group_id, c2.cost_group_id, c1.cost_group_id) transfer_cost_group_id
, l_txn_type txn_type
, p_period_id pac_period_id
FROM
  mtl_material_transactions mmt
, mtl_parameters mp
, cst_cost_group_assignments c1
, cst_cost_group_assignments c2
WHERE
  mmt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND nvl(mmt.owning_tp_type,2) = 2
  AND mmt.organization_id = mp.organization_id
  AND nvl(mp.process_enabled_flag,'N') = 'N'
  AND c1.organization_id = mmt.organization_id
  AND c2.organization_id = mmt.transfer_organization_id
  AND c1.cost_group_id <> c2.cost_group_id
  AND (
      (mmt.transaction_action_id = 3 AND mmt.transaction_source_type_id = 13
       AND EXISTS ( SELECT 'X'
                    FROM cst_cost_group_assignments ccga1
                    WHERE ccga1.cost_group_id = p_cost_group_id
                      AND ccga1.organization_id = mmt.organization_id
                      AND mmt.primary_quantity > 0))
    OR (mmt.transaction_action_id = 21 AND mmt.transaction_source_type_id = 13
       AND EXISTS ( SELECT 'X'
                    FROM mtl_interorg_parameters mip,
                         cst_cost_group_assignments ccga2
                    WHERE mip.from_organization_id = mmt.organization_id
                      AND mip.to_organization_id   = mmt.transfer_organization_id
                      AND nvl(mmt.fob_point,mip.fob_point) = 1
                      AND ccga2.organization_id = mip.to_organization_id
                      AND ccga2.cost_group_id = p_cost_group_id))
    OR (mmt.transaction_action_id = 12 AND mmt.transaction_source_type_id = 13
       AND EXISTS ( SELECT 'X'
                    FROM mtl_interorg_parameters mip,
                         cst_cost_group_assignments ccga3
                    WHERE mip.from_organization_id = mmt.transfer_organization_id
                      AND mip.to_organization_id   = mmt.organization_id
                      AND nvl(mmt.fob_point,mip.fob_point) = 2
                      AND ccga3.organization_id = mip.to_organization_id
                      AND ccga3.cost_group_id   = p_cost_group_id))
      )
UNION
SELECT
  mmt.transaction_id   transaction_id
, mmt.transaction_action_id   transaction_action_id
, mmt.transaction_source_type_id  transaction_source_type_id
, mmt.inventory_item_id  inventory_item_id
, mmt.primary_quantity   primary_quantity
, mmt.periodic_primary_quantity  periodic_primary_quantity
, mmt.organization_id  organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code  subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
, mmt.shipment_number shipment_number
, mmt.transfer_transaction_id  transfer_transaction_id
, mmt.waybill_airbill waybill_airbill
, nvl(mmt.transfer_cost,0)  transfer_cost
, nvl(mmt.transportation_cost,0)  transportation_cost
, nvl(mmt.transfer_percentage,0)  transfer_percentage
, p_cost_group_id cost_group_id
, decode(c1.cost_group_id, p_cost_group_id, c2.cost_group_id, c1.cost_group_id) transfer_cost_group_id
, l_txn_type txn_type
, p_period_id pac_period_id
FROM
  mtl_material_transactions mmt
, mtl_parameters mp
, cst_cost_group_assignments c1
, cst_cost_group_assignments c2
WHERE
  mmt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND nvl(mmt.owning_tp_type,2) = 2
  AND mmt.organization_id = mp.organization_id
  AND nvl(mp.process_enabled_flag,'N') = 'N'
  AND c1.organization_id = mmt.organization_id
  AND c2.organization_id = mmt.transfer_organization_id
  AND c1.cost_group_id <> c2.cost_group_id
  AND NOT EXISTS (SELECT 'X'
	      FROM  mtl_intercompany_parameters mip
	      WHERE nvl(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'),0) = 1
  		AND mip.flow_type = 1
		AND nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'),0) = 2
	        AND mip.ship_organization_id = (select to_number(hoi.org_information3)
		                                from hr_organization_information hoi
				                where hoi.organization_id = decode(mmt.transaction_action_id,21,
						                             mmt.organization_id,mmt.transfer_organization_id)
						  AND hoi.org_information_context = 'Accounting Information')
		AND mip.sell_organization_id = (select to_number(hoi2.org_information3)
		 			        from  hr_organization_information hoi2
						where hoi2.organization_id = decode(mmt.transaction_action_id,21,
						                                    mmt.transfer_organization_id, mmt.organization_id)
						  AND hoi2.org_information_context = 'Accounting Information'))
  AND (
      (mmt.transaction_action_id = 3 AND transaction_source_type_id IN (7,8)
       AND EXISTS ( SELECT 'X'
                    FROM cst_cost_group_assignments ccga1
                    WHERE ccga1.cost_group_id = p_cost_group_id
                      AND ccga1.organization_id = mmt.organization_id
                      AND mmt.primary_quantity > 0))
    OR (mmt.transaction_action_id = 21 AND transaction_source_type_id IN (7,8)
        AND EXISTS ( SELECT 'X'
                     FROM mtl_interorg_parameters mip,
                          cst_cost_group_assignments ccga2
                     WHERE mip.from_organization_id = mmt.organization_id
                       AND mip.to_organization_id   = mmt.transfer_organization_id
                       AND nvl(mmt.fob_point,mip.fob_point) = 1
                       AND ccga2.organization_id = mip.to_organization_id
                       AND ccga2.cost_group_id = p_cost_group_id))
    OR (mmt.transaction_action_id = 12 AND mmt.transaction_source_type_id IN (7,8)
        AND EXISTS ( SELECT 'X'
                     FROM mtl_interorg_parameters mip,
                          cst_cost_group_assignments ccga3
                     WHERE mip.from_organization_id = mmt.transfer_organization_id
                       AND mip.to_organization_id   = mmt.organization_id
                       AND nvl(mmt.fob_point,mip.fob_point) = 2
                       AND ccga3.organization_id = mip.to_organization_id
                       AND ccga3.cost_group_id   = p_cost_group_id))
      ));


 --Cost derived across CG interorg transactions for this cost group being populated in CST_PAC_INTERORG_TXNS_TMP

  l_txn_type := 2;

  INSERT INTO CST_PAC_INTERORG_TXNS_TMP
  (	  transaction_id,
	  transaction_action_id,
	  transaction_source_type_id,
	  inventory_item_id,
	  primary_quantity,
	  periodic_primary_quantity,
	  organization_id,
	  transfer_organization_id,
	  subinventory_code,
	  transfer_price,
	  shipment_number,
	  transfer_transaction_id,
	  waybill_airbill,
	  transfer_cost,
	  transportation_cost,
	  transfer_percentage,
	  cost_group_id,
	  transfer_cost_group_id,
	  txn_type,
	  pac_period_id)
  (SELECT
  mmt.transaction_id  transaction_id
, mmt.transaction_action_id  transaction_action_id
, mmt.transaction_source_type_id  transaction_source_type_id
, mmt.inventory_item_id  inventory_item_id
, mmt.primary_quantity   primary_quantity
, mmt.periodic_primary_quantity  periodic_primary_quantity
, mmt.organization_id  organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code  subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
, mmt.shipment_number  shipment_number
, mmt.transfer_transaction_id  transfer_transaction_id
, mmt.waybill_airbill waybill_airbill
, nvl(mmt.transfer_cost,0)  transfer_cost
, nvl(mmt.transportation_cost,0)  transportation_cost
, nvl(mmt.transfer_percentage,0)  transfer_percentage
, p_cost_group_id cost_group_id
, NULL transfer_cost_group_id
, l_txn_type txn_type
, p_period_id pac_period_id
FROM
  mtl_material_transactions mmt
, mtl_parameters mp
, mtl_parameters mptrans
WHERE
  mmt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND nvl(mmt.owning_tp_type,2) = 2
  AND mmt.organization_id = mp.organization_id
  AND nvl(mp.process_enabled_flag, 'N') = 'N'
  AND (transaction_action_id in (3,12,21) AND transaction_source_type_id = 13
       AND EXISTS (SELECT 'EXISTS'
                     FROM cst_cost_group_assignments ccga
                    WHERE  ccga.cost_group_id   = p_cost_group_id
                      AND (ccga.organization_id = mmt.organization_id OR
                           ccga.organization_id = mmt.transfer_organization_id)))
  AND mptrans.organization_id = mmt.transfer_organization_id
  AND mptrans.process_enabled_flag = 'N'
  AND (transaction_action_id IN (3,12,21)
       AND NOT EXISTS (
         SELECT 'X'
         FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
         WHERE c1.organization_id = mmt.organization_id
           AND c2.organization_id = mmt.transfer_organization_id
           AND c1.cost_group_id   = c2.cost_group_id)
       AND (
         (mmt.transaction_action_id = 3
           AND EXISTS (
             SELECT 'X'
             FROM cst_cost_group_assignments ccga1
             WHERE ccga1.cost_group_id   = p_cost_group_id
               AND ccga1.organization_id = mmt.organization_id
               AND mmt.primary_quantity < 0))
         OR (mmt.transaction_action_id = 21
              AND EXISTS (
                SELECT 'X'
                FROM cst_cost_group_assignments ccga2
                WHERE ccga2.organization_id = mmt.organization_id
                  AND ccga2.cost_group_id   = p_cost_group_id))
          OR (mmt.transaction_action_id = 12
               AND EXISTS (
                SELECT 'X'
                FROM mtl_interorg_parameters mip
                WHERE mip.from_organization_id = mmt.transfer_organization_id
                  AND mip.to_organization_id   = mmt.organization_id
                  AND (
                    (NVL(mmt.fob_point,mip.fob_point) = 1 AND EXISTS (
                      SELECT 'X'
                      FROM cst_cost_group_assignments ccga2
                      WHERE ccga2.organization_id = mip.to_organization_id
                        AND ccga2.cost_group_id   = p_cost_group_id ))
                    OR (NVL(mmt.fob_point,mip.fob_point) = 2 AND EXISTS (
                      SELECT 'X'
                      FROM cst_cost_group_assignments ccga3
                      WHERE ccga3.organization_id = mip.from_organization_id
                        AND ccga3.cost_group_id   = p_cost_group_id )))))
         ))
UNION
SELECT
  mmt1.transaction_id  transaction_id
, mmt1.transaction_action_id  transaction_action_id
, mmt1.transaction_source_type_id  transaction_source_type_id
, mmt1.inventory_item_id  inventory_item_id
, mmt1.primary_quantity   primary_quantity
, mmt1.periodic_primary_quantity  periodic_primary_quantity
, mmt1.organization_id  organization_id
, nvl(mmt1.transfer_organization_id,-1) transfer_organization_id
, mmt1.subinventory_code  subinventory_code
, nvl(mmt1.transfer_price,0) transfer_price
, mmt1.shipment_number  shipment_number
, mmt1.transfer_transaction_id  transfer_transaction_id
, mmt1.waybill_airbill waybill_airbill
, nvl(mmt1.transfer_cost,0)  transfer_cost
, nvl(mmt1.transportation_cost,0)  transportation_cost
, nvl(mmt1.transfer_percentage,0)  transfer_percentage
, p_cost_group_id cost_group_id
, NULL transfer_cost_group_id
, l_txn_type txn_type
, p_period_id pac_period_id
FROM
  mtl_material_transactions mmt1
, mtl_parameters mp1
, mtl_parameters mptrans1
WHERE
  mmt1.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND mmt1.organization_id = nvl(mmt1.owning_organization_id, mmt1.organization_id)
  AND nvl(mmt1.owning_tp_type,2) = 2
  AND mmt1.organization_id = mp1.organization_id
  AND nvl(mp1.process_enabled_flag, 'N') = 'N'
  AND (mmt1.transaction_action_id in (3,12,21) AND mmt1.transaction_source_type_id IN (7,8)
       AND EXISTS (SELECT 'EXISTS'
                     FROM cst_cost_group_assignments ccga
                    WHERE  ccga.cost_group_id   = p_cost_group_id
                      AND (ccga.organization_id = mmt1.organization_id OR
                           ccga.organization_id = mmt1.transfer_organization_id)))
  AND mptrans1.organization_id = mmt1.transfer_organization_id
  AND mptrans1.process_enabled_flag = 'N'
  AND NOT EXISTS (SELECT 'X'
	      FROM  mtl_intercompany_parameters mip
	      WHERE nvl(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'),0) = 1
  		AND mip.flow_type = 1
		AND nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'),0) = 2
	        AND mip.ship_organization_id = (select to_number(hoi.org_information3)
		                                from hr_organization_information hoi
				                where hoi.organization_id = decode(mmt1.transaction_action_id,21,
						                             mmt1.organization_id,mmt1.transfer_organization_id)
						  AND hoi.org_information_context = 'Accounting Information')
		AND mip.sell_organization_id = (select to_number(hoi2.org_information3)
		 			        from  hr_organization_information hoi2
						where hoi2.organization_id = decode(mmt1.transaction_action_id,21,
						                                    mmt1.transfer_organization_id, mmt1.organization_id)
						  AND hoi2.org_information_context = 'Accounting Information'))
  AND (mmt1.transaction_action_id IN (3,12,21) AND mmt1.transaction_source_type_id IN (7,8)
       AND NOT EXISTS (
         SELECT 'X'
         FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
         WHERE c1.organization_id = mmt1.organization_id
           AND c2.organization_id = mmt1.transfer_organization_id
           AND c1.cost_group_id   = c2.cost_group_id)
       AND (
         (mmt1.transaction_action_id = 3
           AND EXISTS (
             SELECT 'X'
             FROM cst_cost_group_assignments ccga1
             WHERE ccga1.cost_group_id   = p_cost_group_id
               AND ccga1.organization_id = mmt1.organization_id
               AND mmt1.primary_quantity < 0))
         OR (mmt1.transaction_action_id = 21
              AND EXISTS (
                SELECT 'X'
                FROM cst_cost_group_assignments ccga2
                WHERE ccga2.organization_id = mmt1.organization_id
                  AND ccga2.cost_group_id   = p_cost_group_id))
          OR (mmt1.transaction_action_id = 12
               AND EXISTS (
                SELECT 'X'
                FROM mtl_interorg_parameters mip
                WHERE mip.from_organization_id = mmt1.transfer_organization_id
                  AND mip.to_organization_id   = mmt1.organization_id
                  AND (
                    (NVL(mmt1.fob_point,mip.fob_point) = 1 AND EXISTS (
                      SELECT 'X'
                      FROM cst_cost_group_assignments ccga2
                      WHERE ccga2.organization_id = mip.to_organization_id
                        AND ccga2.cost_group_id   = p_cost_group_id ))
                    OR (NVL(mmt1.fob_point,mip.fob_point) = 2 AND EXISTS (
                      SELECT 'X'
                      FROM cst_cost_group_assignments ccga3
                      WHERE ccga3.organization_id = mip.from_organization_id
                        AND ccga3.cost_group_id   = p_cost_group_id )))))
         )));


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
 WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                    );
    END IF;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Populate_Temp_Tables;

-- +========================================================================+
-- PROCEDURE: Retrieve_Interorg_Items
-- PARAMETERS:
--   p_period_id             IN  NUMBER
--   p_cost_group_id         IN  NUMBER
--   p_period_start_date     IN  DATE
--   p_period_end_date       IN  DATE
-- COMMENT:
--   This procedure is called by the API iteration_process
--   Support Transfer pricing option as below
--   Value 0: No include the interorg txns of OM
--   Value 1: Yes, Price not as incoming cost include the interorg txns of OM
--   Value 2: Yes, Price as incoming cost do not include the interorg txns of OM
--   OPM SCENARIO: Exclude any interorg transactions due to OPM organization
--   Cost Owned Txns:
--   Exclude Direct interorg receipt txn coming from OPM org
--   Exclude Intransit Shipment txn FOB:Shipment processed in discrete coming
--   from OPM organization
--   Exclude Logical intransit receipt (15) due to OPM org
--   Cost Derived Txns:
--   Exclude Direct interorg shipment txn to OPM org
--   Exclude Intransit receipt txn FOB:Receipt processed in discrete due to OPM
--   Exclude Logical intransit shipment (22) due to OPM org
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Retrieve_Interorg_Items
(  p_period_id             IN      NUMBER
,  p_cost_group_id         IN      NUMBER
,  p_period_start_date     IN      DATE
,  p_period_end_date       IN      DATE
)
IS

-- Routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Retrieve_Interorg_Items';

BEGIN

-- ==============================================================
-- Get Interorg Items with no completion
-- Set low level code to 1000
-- ==============================================================
  INSERT INTO CST_PAC_INTORG_ITMS_TEMP
      (  INVENTORY_ITEM_ID
      ,  COST_GROUP_ID
      ,  PAC_PERIOD_ID
      ,  ITEM_COST
      ,  PREV_ITR_ITEM_COST
      ,  LOW_LEVEL_CODE
      ,  TOLERANCE_FLAG
      ,  ITERATION_COUNT
      ,  DIFFERENCE
      ,  DIVERGING_FLAG
      ,  INTERORG_RECEIPT_FLAG
      )
  SELECT
      distinct ccit.inventory_item_id
      ,  p_cost_group_id
      ,  p_period_id
      ,  0
      ,  0
      ,  1000
      ,  'N'
      ,  0
      ,  0
      ,  'N'
      ,  'Y'
  FROM CST_PAC_INTERORG_TXNS_TMP ccit, mtl_parameters mp
  WHERE ccit.cost_group_id = p_cost_group_id
        AND ccit.pac_period_id = p_period_id
	AND ccit.txn_type = 1
	AND mp.organization_id = ccit.transfer_organization_id
	AND mp.process_enabled_flag = 'N'
	AND NOT EXISTS (
		      SELECT 'X'
		      FROM
		        cst_pac_low_level_codes cpllc
		      WHERE cpllc.inventory_item_id  = ccit.inventory_item_id
		        AND cpllc.pac_period_id      = p_period_id
		        AND cpllc.cost_group_id      = p_cost_group_id);



  INSERT INTO CST_PAC_INTORG_ITMS_TEMP
          (  INVENTORY_ITEM_ID
          ,  COST_GROUP_ID
          ,  PAC_PERIOD_ID
          ,  ITEM_COST
          ,  PREV_ITR_ITEM_COST
          ,  LOW_LEVEL_CODE
          ,  TOLERANCE_FLAG
          ,  ITERATION_COUNT
          ,  DIFFERENCE
          ,  DIVERGING_FLAG
	  ,  INTERORG_RECEIPT_FLAG
	  ,  INTERORG_SHIPMENT_FLAG
	  ,  SEQUENCE_NUM
          )
  SELECT
	 distinct ccit.inventory_item_id
	  ,  p_cost_group_id
	  ,  p_period_id
	  ,  0
	  ,  0
	  ,  1000
	  ,  'N'
	  ,  0
	  ,  0
	  ,  'N'
	  ,  'N'
	  ,  'Y'
	  ,   1
  FROM    CST_PAC_INTERORG_TXNS_TMP ccit
  WHERE ccit.cost_group_id = p_cost_group_id
        AND ccit.pac_period_id = p_period_id
	AND ccit.txn_type = 2
	AND NOT EXISTS (
	    SELECT 'X'
	    FROM cst_pac_intorg_itms_temp cpiit
	    WHERE cpiit.cost_group_id     = p_cost_group_id
	      AND cpiit.pac_period_id     = p_period_id
	      AND cpiit.inventory_item_id = ccit.inventory_item_id)
	AND NOT EXISTS (
	    SELECT 'X'
	    FROM cst_pac_low_level_codes cpllc
	    WHERE cpllc.inventory_item_id = ccit.inventory_item_id
	      AND cpllc.pac_period_id = p_period_id
	      AND cpllc.cost_group_id = p_cost_group_id);


-- ==============================================================
-- Get Interorg Items with completion
-- ==============================================================

  INSERT INTO CST_PAC_INTORG_ITMS_TEMP
          (  INVENTORY_ITEM_ID
          ,  COST_GROUP_ID
          ,  PAC_PERIOD_ID
          ,  ITEM_COST
          ,  PREV_ITR_ITEM_COST
          ,  LOW_LEVEL_CODE
          ,  TOLERANCE_FLAG
          ,  ITERATION_COUNT
          ,  DIFFERENCE
          ,  DIVERGING_FLAG
	  ,  INTERORG_RECEIPT_FLAG
          )
  SELECT
            distinct ccit.inventory_item_id
          ,  p_cost_group_id
          ,  p_period_id
          ,  0
          ,  0
          ,  cpllc.low_level_code
          ,  'N'
          ,  0
	  ,  0
	  ,  'N'
	  ,  'Y'
  FROM CST_PAC_INTERORG_TXNS_TMP ccit, mtl_parameters mp, cst_pac_low_level_codes cpllc
  WHERE ccit.cost_group_id = p_cost_group_id
        AND ccit.pac_period_id = p_period_id
	AND ccit.txn_type = 1
	AND mp.organization_id = ccit.transfer_organization_id
	AND mp.process_enabled_flag = 'N'
	AND cpllc.inventory_item_id  = ccit.inventory_item_id
	AND cpllc.pac_period_id      = p_period_id
	AND cpllc.cost_group_id      = p_cost_group_id;

  INSERT INTO CST_PAC_INTORG_ITMS_TEMP
        (  INVENTORY_ITEM_ID
        ,  COST_GROUP_ID
        ,  PAC_PERIOD_ID
        ,  ITEM_COST
        ,  PREV_ITR_ITEM_COST
        ,  LOW_LEVEL_CODE
        ,  TOLERANCE_FLAG
        ,  ITERATION_COUNT
        ,  DIFFERENCE
        ,  DIVERGING_FLAG
	,  INTERORG_RECEIPT_FLAG
	,  INTERORG_SHIPMENT_FLAG
	,  SEQUENCE_NUM
        )
  SELECT
          distinct ccit.inventory_item_id
        ,  p_cost_group_id
        ,  p_period_id
        ,  0
        ,  0
        ,  cpllc.low_level_code
        ,  'N'
        ,  0
	,  0
	,  'N'
	,  'N'
	,  'Y'
	,   1
  FROM  CST_PAC_INTERORG_TXNS_TMP ccit,  cst_pac_low_level_codes cpllc
  WHERE ccit.cost_group_id = p_cost_group_id
  AND ccit.pac_period_id = p_period_id
  AND ccit.txn_type = 2
  AND cpllc.inventory_item_id  = ccit.inventory_item_id
  AND cpllc.pac_period_id      = p_period_id
  AND cpllc.cost_group_id      = p_cost_group_id
  AND NOT EXISTS (
	    SELECT 'X'
	    FROM cst_pac_intorg_itms_temp cpiit
	    WHERE cpiit.cost_group_id     = p_cost_group_id
	      AND cpiit.pac_period_id     = p_period_id
	      AND cpiit.inventory_item_id = ccit.inventory_item_id);


  UPDATE CST_PAC_INTORG_ITMS_TEMP cpiit
  SET (INTERORG_SHIPMENT_FLAG,
       SEQUENCE_NUM) = (select (case when exists(select 'X'
                                                from CST_PAC_INTERORG_TXNS_TMP ccit
					        where ccit.pac_period_id = p_period_id
					        and ccit.cost_group_id = p_cost_group_id
					        and ccit.inventory_item_id = cpiit.inventory_item_id
					        and ccit.txn_type = 2)
			            then 'Y'
			            else 'N'
			       end) INTERORG_SHIPMENT_FLAG,
			      (case when exists(select 'X'
                                                from CST_PAC_INTERORG_TXNS_TMP ccit
					        where ccit.pac_period_id = p_period_id
					        and ccit.cost_group_id = p_cost_group_id
					        and ccit.inventory_item_id = cpiit.inventory_item_id
					        and ccit.txn_type = 2)
			            then 2
			            else 3
			       end) SEQUENCE_NUM
			from dual)
  where cpiit.cost_group_id     = p_cost_group_id
    AND cpiit.pac_period_id     = p_period_id
    AND cpiit.INTERORG_RECEIPT_FLAG = 'Y';


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Retrieve_Interorg_Items;

-- +========================================================================+
-- PROCEDURES AND FUNCTIONS OF OPTIMAL SEQUENCE COST GROUPS
-- Code Merge of Optimal Sequence Cost Groups
-- +========================================================================+

--========================================================================
-- PROCEDURE  : Process_Optimal_Sequence PRIVATE
-- COMMENT   : Procedure to determine the optimal sequence of the
--             cost groups.
--========================================================================
PROCEDURE Process_Optimal_Sequence
( p_period_id IN NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'Process_Optimal_Sequence';

BEGIN

-- Cost groups with across CG interorg txns are arranged in increasing order of sequence_num, On hand quantity
-- for each inventory item and sequence_num is updated to reflect this order.
-- The inner select query Q selects item, cost group, new sequence number.

  update cst_pac_intorg_itms_temp cos1
  set cos1.sequence_num =
          (select sequence_num
           from (select cos.inventory_item_id inventory_item_id,
                        cos.cost_group_id cost_group_id,
                        cos.pac_period_id pac_period_id,
                        row_number() over (partition by cos.inventory_item_id order by cos.sequence_num
                                                                                      ,nvl(cpic.total_layer_quantity,0)
                                                                                      ,cos.cost_group_id
                                           ) sequence_num
                 FROM cst_pac_item_costs cpic, cst_pac_intorg_itms_temp cos
                 WHERE cpic.inventory_item_id(+) = cos.inventory_item_id
                   AND cpic.cost_group_id(+)   = cos.cost_group_id
                   AND cpic.pac_period_id(+)   = cos.pac_period_id
                   AND cos.pac_period_id = p_period_id)   Q
           WHERE cos1.inventory_item_id = Q.inventory_item_id
             and cos1.cost_group_id = Q.cost_group_id
             and cos1.pac_period_id = Q.pac_period_id)
  WHERE cos1.pac_period_id = p_period_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END  Process_Optimal_Sequence;

-- +========================================================================+
-- PROCEDURE: Get_Balance_Before_Intorg
-- PARAMETERS:
--   p_period_id           IN  NUMBER
--   p_cost_group_id       IN  NUMBER
--   p_inventory_item_id   IN  NUMBER
-- COMMENT:
--   Retrieve Balance before interorg txns across Cost Groups from CPPB.
--   Store the period quantity, period balance into G_PWAC_NEW_COST_TBL
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Get_Balance_Before_Intorg(p_period_id          IN NUMBER
                                   ,p_cost_group_id      IN NUMBER
                                   ,p_inventory_item_id  IN NUMBER
                                   )
IS

-- routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'get_balance_before_intorg';

-- Cursor to retrieve CPPB balance info just before
-- interorg txns across CGs
CURSOR balance_bef_intorg_cur(c_pac_period_id     NUMBER
                             ,c_cost_group_id     NUMBER
                             ,c_inventory_item_id NUMBER
                             ,c_cost_element_id   NUMBER
                             ,c_level_type        NUMBER
                             )
IS
SELECT
  nvl(period_quantity,0)
, nvl(period_balance,0)
FROM cst_pac_period_balances
WHERE pac_period_id     = c_pac_period_id
  AND cost_group_id     = c_cost_group_id
  AND inventory_item_id = c_inventory_item_id
  AND cost_element_id   = c_cost_element_id
  AND level_type        = c_level_type
  AND txn_category < 8
ORDER BY txn_category DESC;

l_cost_element_id        NUMBER;
l_level_type             NUMBER;
l_period_qty_bef_intorg  NUMBER;
l_period_bal_bef_intorg  NUMBER;

l_cg_idx                 BINARY_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;


    -- initialize G_PWAC_NEW_COST_TBL table for all the combination
    -- of cost element and level type in each cost group
    l_cost_element_id := 1;
    WHILE l_cost_element_id <= 5 LOOP
      l_level_type := 1;
      WHILE l_level_type <= 2 LOOP

	       -- initialize period qty and period balance
	       -- before interorg txns
	       l_period_bal_bef_intorg := 0;
	       l_period_qty_bef_intorg := 0;

	       OPEN balance_bef_intorg_cur(p_period_id
		                          ,p_cost_group_id
			                  ,p_inventory_item_id
				          ,l_cost_element_id
	                                  ,l_level_type
		                          );
	       FETCH balance_bef_intorg_cur
	       INTO l_period_qty_bef_intorg
		   ,l_period_bal_bef_intorg;

	      IF balance_bef_intorg_cur%FOUND THEN
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_bal_bef_intorg   := l_period_bal_bef_intorg;
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance      := l_period_bal_bef_intorg;

		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_qty_bef_intorg   := l_period_qty_bef_intorg;
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_quantity     := l_period_qty_bef_intorg;
	      ELSE
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_bal_bef_intorg   := 0;
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance      := 0;
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_qty_bef_intorg   := 0;
		      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_quantity     := 0;
	      END IF;

	      CLOSE balance_bef_intorg_cur;

              l_level_type := l_level_type + 1;
      END LOOP;
      l_cost_element_id := l_cost_element_id + 1;
    END LOOP;

    -- set period quantity at each cost group
    l_cg_idx := p_cost_group_id;
    G_CST_GROUP_TBL(l_cg_idx).period_new_quantity := l_period_qty_bef_intorg;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                    );
    END IF;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Get_Balance_Before_Intorg;

-- +========================================================================+
-- PROCEDURE:    PRIVATE UTILITY
-- PARAMETERS:   Group1_Interorg_Iteration1
-- Descrition:
-- +========================================================================+
PROCEDURE Group1_Interorg_Iteration1
( p_legal_entity_id           IN  NUMBER
, p_master_org_id            IN  NUMBER
, p_cost_type_id             IN  NUMBER
, p_cost_method              IN  NUMBER
, p_cost_group_id            IN  NUMBER
, p_inventory_item_id        IN  NUMBER
, p_low_level_code           IN  NUMBER
, p_period_id                IN  NUMBER
, p_pac_rates_id             IN  NUMBER
, p_uom_control              IN  NUMBER
, p_end_iteration_num        IN  NUMBER
, p_iteration_proc_flag      IN  VARCHAR2
)
IS
-- routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Group1_Interorg_Iteration1';

CURSOR group1_interorg_cur(c_cost_group_id          NUMBER
                          ,c_inventory_item_id      NUMBER
			  ,c_period_id              NUMBER
                          )
IS
SELECT
  ccit.transaction_id   transaction_id
, ccit.transaction_action_id   transaction_action_id
, ccit.transaction_source_type_id  transaction_source_type_id
, ccit.inventory_item_id  inventory_item_id
, ccit.primary_quantity   primary_quantity
, ccit.periodic_primary_quantity  periodic_primary_quantity
, ccit.organization_id  organization_id
, nvl(ccit.transfer_organization_id,-1) transfer_organization_id
, ccit.subinventory_code  subinventory_code
, nvl(ccit.transfer_price,0) transfer_price
, ccit.shipment_number shipment_number
, ccit.transfer_transaction_id  transfer_transaction_id
, ccit.waybill_airbill waybill_airbill
, nvl(ccit.transfer_cost,0)  transfer_cost
, nvl(ccit.transportation_cost,0)  transportation_cost
, nvl(ccit.transfer_percentage,0)  transfer_percentage
, DECODE(msi.inventory_asset_flag,'Y',0,1) exp_item
, DECODE(msubinv.asset_inventory,1,0,1) exp_flag
FROM
CST_PAC_INTERORG_TXNS_TMP ccit
 , mtl_system_items msi
  , mtl_secondary_inventories msubinv
WHERE ccit.inventory_item_id = c_inventory_item_id
AND ccit.cost_group_id = c_cost_group_id
AND ccit.pac_period_id = c_period_id
AND ccit.inventory_item_id = msi.inventory_item_id
AND msi.organization_id = ccit.organization_id
AND msubinv.organization_id(+) = ccit.organization_id
AND msubinv.secondary_inventory_name(+) = ccit.subinventory_code
AND ccit.txn_type = 1;

TYPE group1_interorg_tab IS TABLE OF group1_interorg_cur%rowtype INDEX BY BINARY_INTEGER;
l_group1_interorg_tab		group1_interorg_tab;
l_empty_gp1_interorg_tab	group1_interorg_tab;

l_loop_count       NUMBER := 0;
l_batch_size       NUMBER := 200;
-- Error message variables
l_error_num      NUMBER;
l_error_code     VARCHAR2(240);
l_error_msg      VARCHAR2(240);
l_return_status  VARCHAR2(1);
l_txn_category   NUMBER;

TYPE t_txn_id_tbl_type IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.transaction_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE t_cost_element_id_tbl_type IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.cost_element_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE t_level_type_tbl_type IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.level_type%TYPE
  INDEX BY BINARY_INTEGER;
TYPE t_variance_amt_tbl_type IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.variance_amount%TYPE
  INDEX BY BINARY_INTEGER;

l_txn_id_tbl           t_txn_id_tbl_type;
l_cost_element_id_tbl  t_cost_element_id_tbl_type;
l_level_type_tbl       t_level_type_tbl_type;
l_variance_amt_tbl     t_variance_amt_tbl_type;

BEGIN

  l_txn_category := 8;

  IF NOT group1_interorg_cur%ISOPEN THEN
     OPEN group1_interorg_cur(p_cost_group_id
	 		     ,p_inventory_item_id
			     ,p_period_id
			     );
  END IF;

  LOOP

      l_group1_interorg_tab := l_empty_gp1_interorg_tab;
      FETCH group1_interorg_cur BULK COLLECT INTO l_group1_interorg_tab LIMIT l_batch_size;

      l_loop_count := l_group1_interorg_tab.count;

      FOR i IN 1..l_loop_count
      LOOP


	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.costinvtxn_gp1'
                      ,'Transaction Id:'|| l_group1_interorg_tab(i).transaction_id ||
                       ' Primary Qty:' || l_group1_interorg_tab(i).primary_quantity
                      );
	      END IF;

	      IF (l_group1_interorg_tab(i).subinventory_code IS NULL) THEN
			l_group1_interorg_tab(i).exp_flag := l_group1_interorg_tab(i).exp_item;
	      ELSIF (l_group1_interorg_tab(i).exp_item = 1) THEN
			l_group1_interorg_tab(i).exp_flag := 1;
	      END IF;


	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_STATEMENT
			,G_MODULE_HEAD || l_routine || '.exp_flag'
	                ,'Expense Flag:'|| l_group1_interorg_tab(i).exp_flag ||
		        ' Expense Item:' || l_group1_interorg_tab(i).exp_item
			);
	      END IF;

	      -- insert into cppb for 1000 inventory items
	      l_error_num := 0;
	      IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
			        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
						         ,i_cost_group_id     => p_cost_group_id
			                                 ,i_txn_category      => l_txn_category
			                                 ,i_user_id           => FND_GLOBAL.user_id
			                                 ,i_login_id          => FND_GLOBAL.login_id
			                                 ,i_request_id        => FND_GLOBAL.conc_request_id
						         ,i_prog_id           => FND_GLOBAL.conc_program_id
			                                 ,i_prog_appl_id      => FND_GLOBAL.prog_appl_id
						         ,o_err_num           => l_error_num
			                                 ,o_err_code          => l_error_code
			                                 ,o_err_msg           => l_error_msg
						         );
			        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					  FND_LOG.string(FND_LOG.LEVEL_STATEMENT
					,G_MODULE_HEAD || l_routine || '.incppbir1'
		                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
			                );
			        END IF;
	      END IF; -- plsql item table count

	      IF l_error_num = 0 THEN

				  -- Invoke PAC inventory cost processor
			          CSTPPINV.cost_inv_txn( i_pac_period_id    => p_period_id
							, i_legal_entity     => p_legal_entity_id
				                        , i_cost_type_id     => p_cost_type_id
			                                , i_cost_group_id    => p_cost_group_id
			                                , i_cost_method      => p_cost_method
			                                , i_txn_id           => l_group1_interorg_tab(i).transaction_id
			                                , i_txn_action_id    => l_group1_interorg_tab(i).transaction_action_id
		                                        , i_txn_src_type_id  => l_group1_interorg_tab(i).transaction_source_type_id
			                                , i_item_id          => l_group1_interorg_tab(i).inventory_item_id
			                                , i_txn_qty          => l_group1_interorg_tab(i).primary_quantity
			                                , i_txn_org_id       => l_group1_interorg_tab(i).organization_id
		                                        , i_txfr_org_id      => l_group1_interorg_tab(i).transfer_organization_id
			                                , i_subinventory_code => l_group1_interorg_tab(i).subinventory_code
			                                , i_exp_flag          => l_group1_interorg_tab(i).exp_flag
			                                , i_exp_item          => l_group1_interorg_tab(i).exp_item
			                                , i_pac_rates_id      => p_pac_rates_id
			                                , i_process_group     => 1
			                                , i_master_org_id     => p_master_org_id
			                                , i_uom_control       => p_uom_control
			                                , i_user_id           => FND_GLOBAL.user_id
			                                , i_login_id          => FND_GLOBAL.login_id
			                                , i_request_id        => FND_GLOBAL.conc_request_id
			                                , i_prog_id           => FND_GLOBAL.conc_program_id
			                                , i_prog_appl_id      => FND_GLOBAL.prog_appl_id
			                                , i_txn_category      => l_txn_category
			                                , i_transfer_price_pd => l_group1_interorg_tab(i).transfer_price
			                                , o_err_num           => l_error_num
			                                , o_err_code          => l_error_code
			                                , o_err_msg           => l_error_msg
				                        );

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                            ,G_MODULE_HEAD || l_routine || '.PAC_inv_Processor_gp1'
		                    ,'PAC Inventory Processor:'|| l_error_num || ' ' ||
			            l_error_code || ' ' || l_error_msg
				  );
		                END IF;


	      END IF; -- error num check

	      IF l_error_num <> 0 THEN
		          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
			    , G_MODULE_HEAD || l_routine || '.others'
	                    , 'group1 cost_inv_txn for cost group '|| p_cost_group_id ||' txn id '
	                                 || l_group1_interorg_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
		            );
			  END IF;
		          FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
		          FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		          FND_MESSAGE.set_token('MESSAGE', 'group1 cost_inv_txn for cost group '|| p_cost_group_id ||' txn id '
	                                 || l_group1_interorg_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
		          FND_MSG_PUB.Add;
		          RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      -- Insert into MTL_PAC_ACT_CST_DTL_TEMP only if the iteration
	      -- process flag is enabled with more than 1 iteration

	      IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN

				-- Cost owned transactions
			        INSERT INTO MTL_PAC_ACT_CST_DTL_TEMP
			        ( COST_GROUP_ID
			        , TRANSACTION_ID
			        , PAC_PERIOD_ID
			        , COST_TYPE_ID
			        , COST_ELEMENT_ID
			        , LEVEL_TYPE
			        , INVENTORY_ITEM_ID
			        , COST_LAYER_ID
			        , ACTUAL_COST
			        , VARIANCE_AMOUNT
			        , USER_ENTERED
			        , INSERTION_FLAG
			        , TRANSACTION_COSTED_DATE
			        , SHIPMENT_NUMBER
			        , TRANSFER_TRANSACTION_ID
			        , TRANSPORTATION_COST
			        , MOH_ABSORPTION_COST
			        )
			        SELECT
			          cost_group_id
			        , transaction_id
			        , pac_period_id
			        , cost_type_id
			        , cost_element_id
			        , level_type
			        , inventory_item_id
			        , cost_layer_id
			        , actual_cost
			        , variance_amount
			        , user_entered
			        , insertion_flag
			        , transaction_costed_date
			        , l_group1_interorg_tab(i).shipment_number
			        , l_group1_interorg_tab(i).transfer_transaction_id
			        , decode(cost_element_id,2,
			                 decode(level_type,1,l_group1_interorg_tab(i).transportation_cost,0),0)
			        , 0
			        FROM MTL_PAC_ACTUAL_COST_DETAILS
			        WHERE transaction_id = l_group1_interorg_tab(i).transaction_id
			          AND cost_group_id  = p_cost_group_id
			          AND pac_period_id  = p_period_id
			          AND cost_type_id   = p_cost_type_id;

		        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                        ,G_MODULE_HEAD || l_routine || '.After_ins_MPACD_TEMP'
	                        ,'After inserting mtl_pac_act_cst_dtl_temp:'||
	                         l_group1_interorg_tab(i).transaction_id
	                        );
		        END IF;

				-- Bug 5593086 Pad with nonexistent rows
			        INSERT INTO MTL_PAC_ACT_CST_DTL_TEMP
				 ( COST_GROUP_ID
			         , TRANSACTION_ID
				 , PAC_PERIOD_ID
				 , COST_TYPE_ID
			         , COST_ELEMENT_ID
			         , LEVEL_TYPE
			         , INVENTORY_ITEM_ID
			         , COST_LAYER_ID
			         , ACTUAL_COST
			         , VARIANCE_AMOUNT
			         , USER_ENTERED
			         , INSERTION_FLAG
			         , TRANSACTION_COSTED_DATE
			         , SHIPMENT_NUMBER
			         , TRANSFER_TRANSACTION_ID
			         , TRANSPORTATION_COST
			         , MOH_ABSORPTION_COST
			         )
			        SELECT
			          mpacd.cost_group_id
			         , mpacd.transaction_id
			         , mpacd.pac_period_id
			         , mpacd.cost_type_id
			         , cce.cost_element_id
			         , lt.level_type
			         , mpacd.inventory_item_id
			         , mpacd.cost_layer_id
			         , 0
			         , 0
			         , mpacd.user_entered
			         , mpacd.insertion_flag
			         , mpacd.transaction_costed_date
			         , l_group1_interorg_tab(i).shipment_number
			         , l_group1_interorg_tab(i).transfer_transaction_id
			         , 0
			         , 0
			        FROM (SELECT *
			          FROM MTL_PAC_ACTUAL_COST_DETAILS
			          WHERE transaction_id = l_group1_interorg_tab(i).transaction_id
			            AND cost_group_id  = p_cost_group_id
			            AND pac_period_id  = p_period_id
			            AND cost_type_id   = p_cost_type_id
			            AND rownum = 1) mpacd,
			          CST_COST_ELEMENTS cce,
			          (SELECT 1 level_type FROM DUAL
			           UNION
			           SELECT 2 level_type FROM DUAL) lt
				        WHERE NOT EXISTS
			          (SELECT 1
			           FROM   mtl_pac_act_cst_dtl_temp mpacdt
			           WHERE  mpacdt.cost_group_id = p_cost_group_id
			           AND    mpacdt.transaction_id = l_group1_interorg_tab(i).transaction_id
				   AND    mpacdt.pac_period_id = p_period_id
			           AND    mpacdt.cost_type_id = p_cost_type_id
			           AND    mpacdt.cost_element_id = cce.cost_element_id
			           AND    mpacdt.level_type = lt.level_type);

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		             FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                    ,G_MODULE_HEAD || l_routine || '.After_pad_MPACD_TEMP'
	                   ,'After padding mtl_pac_act_cst_dtl_temp:'||
		             l_group1_interorg_tab(i).transaction_id
			    );
		        END IF;

		END IF; --IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN

      END LOOP; -- FOR i IN 1..l_loop_count

      EXIT WHEN group1_interorg_cur%NOTFOUND;
  END LOOP; --	FETCH loop
  CLOSE group1_interorg_cur;


	-- ======================================================
	-- insert left over interorg receipts into cppb
	-- Calculate Periodic Cost if interorg receipts exist
	-- Update Variance Amount into MPACD_TEMP if interorg
	-- receipts exist and consecutive iterations exist
	-- update cppb if interorg receipts exist
	-- ======================================================
  l_error_num := 0;


  IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
			  CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
					           ,i_cost_group_id     => p_cost_group_id
		                                   ,i_txn_category      => l_txn_category
				                   ,i_user_id           => FND_GLOBAL.user_id
						   ,i_login_id          => FND_GLOBAL.login_id
		                                   ,i_request_id        => FND_GLOBAL.conc_request_id
				                   ,i_prog_id           => FND_GLOBAL.conc_program_id
						   ,i_prog_appl_id      => FND_GLOBAL.prog_appl_id
		                                   ,o_err_num           => l_error_num
				                   ,o_err_code          => l_error_code
						   ,o_err_msg           => l_error_msg
		                                   );

		            l_error_num  := NVL(l_error_num, 0);
		            l_error_code := NVL(l_error_code, 'No Error');
		            l_error_msg  := NVL(l_error_msg, 'No Error');

		          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
			    ,G_MODULE_HEAD || l_routine || '.inscppir2'
                            ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                          );
		          END IF;
  END IF; -- item existence in item id table

  -- ==============================================================
  -- Calculate Periodic Cost after processing all interorg receipts
  -- Variance Amount will be updated
  -- Item Cost will be updated
  -- Calculate Periodic Cost in CPICD, CPIC at the FIRST iteration
  -- process; Update Variance Amount in the last transaction of MPACD;
  -- Update CPPB - Invoke Update_Item_cppb for a given CG
  -- Copy of Calc_Pmac_Update_Cppb for a given cost group
  -- ================================================================
     CSTPPWAC.calculate_periodic_cost(i_pac_period_id  => p_period_id
  		                     ,i_cost_group_id  => p_cost_group_id
				     ,i_cost_type_id   => p_cost_type_id
		                     ,i_low_level_code => p_low_level_code
				     ,i_item_id        => p_inventory_item_id
		                     ,i_user_id        => FND_GLOBAL.user_id
				     ,i_login_id       => FND_GLOBAL.login_id
				     ,i_request_id     => FND_GLOBAL.conc_request_id
		                     ,i_prog_id        => FND_GLOBAL.conc_program_id
				     ,i_prog_appl_id   => FND_GLOBAL.prog_appl_id
		                     ,o_err_num        => l_error_num
				     ,o_err_code       => l_error_code
		                     ,o_err_msg        => l_error_msg
				     );

     l_error_num  := NVL(l_error_num,0);
     l_error_code := NVL(l_error_code, 'No Error');
     l_error_msg  := NVL(l_error_msg, 'No Error');


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                            ,G_MODULE_HEAD || l_routine || '.calcpmac'
                           ,'After calling calculate_periodic_cost:'|| l_error_num || l_error_code || l_error_msg
                            );
    END IF;


    IF p_end_iteration_num > 1 THEN
           -- =====================================
           -- Update variance amount in MPACD_TEMP
           -- =====================================
           SELECT transaction_id, cost_element_id, level_type,variance_amount
              BULK COLLECT
           INTO l_txn_id_tbl, l_cost_element_id_tbl, l_level_type_tbl,l_variance_amt_tbl
           FROM   MTL_PAC_ACTUAL_COST_DETAILS
           WHERE  pac_period_id = p_period_id
             AND  cost_type_id  = p_cost_type_id
             AND  cost_group_id = p_cost_group_id
             AND  inventory_item_id = p_inventory_item_id;

           FORALL l_mpacd_idx IN l_txn_id_tbl.FIRST .. l_txn_id_tbl.LAST
            UPDATE MTL_PAC_ACT_CST_DTL_TEMP
               SET variance_amount   = l_variance_amt_tbl(l_mpacd_idx)
             WHERE pac_period_id     = p_period_id
               AND cost_type_id      = p_cost_type_id
               AND cost_group_id     = p_cost_group_id
               AND inventory_item_id = p_inventory_item_id
               AND cost_element_id   = l_cost_element_id_tbl(l_mpacd_idx)
               AND level_type        = l_level_type_tbl(l_mpacd_idx)
               AND transaction_id    = l_txn_id_tbl(l_mpacd_idx);
    END IF;

  IF l_error_num <> 0 THEN
		           FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
			   FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	  	           FND_MESSAGE.set_token('MESSAGE', 'CSTPPWAC.update_item_cppb for CG '|| p_cost_group_id ||' txn category '
	                                 ||l_txn_category||' t_low_level_code ' ||p_low_level_code
					 ||' error('||l_error_code||') '||l_error_msg);
	 		   FND_MSG_PUB.Add;
	  	           RAISE FND_API.G_EXC_ERROR;
  END IF;

  CSTPPWAC.update_item_cppb (i_pac_period_id  => p_period_id,
			     i_cost_group_id  => p_cost_group_id,
                             i_txn_category   => l_txn_category,
                             i_item_id        => p_inventory_item_id,
                             i_user_id        => FND_GLOBAL.user_id,
                             i_login_id       => FND_GLOBAL.login_id,
                             i_request_id     => FND_GLOBAL.conc_request_id,
                             i_prog_id        => FND_GLOBAL.conc_program_id,
                             i_prog_appl_id   => FND_GLOBAL.prog_appl_id,
                             o_err_num        => l_error_num,
                             o_err_code       => l_error_code,
                             o_err_msg        => l_error_msg );

  -- Set PWAC Item Cost in interorg items temp table
  UPDATE CST_PAC_INTORG_ITMS_TEMP
    SET item_cost = (SELECT nvl(item_cost,0)
                     FROM cst_pac_item_costs cpic
                     WHERE cpic.pac_period_id     = p_period_id
                       AND cpic.cost_group_id     = p_cost_group_id
                       AND cpic.inventory_item_id = p_inventory_item_id)
  WHERE pac_period_id     = p_period_id
    AND cost_group_id     = p_cost_group_id
    AND inventory_item_id = p_inventory_item_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Group1_Interorg_Iteration1;

-- +========================================================================+
-- PROCEDURE:    PRIVATE UTILITY
-- PARAMETERS:   Group2_Interorg_Iteration1
-- Descrition:
-- +========================================================================+
PROCEDURE Group2_Interorg_Iteration1
( p_legal_entity_id           IN  NUMBER
, p_master_org_id            IN  NUMBER
, p_cost_type_id             IN  NUMBER
, p_cost_method              IN  NUMBER
, p_cost_group_id            IN  NUMBER
, p_inventory_item_id        IN  NUMBER
, p_low_level_code           IN  NUMBER
, p_period_id                IN  NUMBER
, p_pac_rates_id             IN  NUMBER
, p_uom_control              IN  NUMBER
, p_end_iteration_num        IN  NUMBER
, p_iteration_proc_flag      IN  VARCHAR2
)
IS
-- routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Group2_Interorg_Iteration1';

CURSOR group2_interorg_cur(c_cost_group_id          NUMBER
                          ,c_inventory_item_id      NUMBER
  			  ,c_period_id              NUMBER
                          )
IS
SELECT
  ccit.transaction_id  transaction_id
, ccit.transaction_action_id  transaction_action_id
, ccit.transaction_source_type_id  transaction_source_type_id
, ccit.inventory_item_id  inventory_item_id
, ccit.primary_quantity   primary_quantity
, ccit.periodic_primary_quantity  periodic_primary_quantity
, ccit.organization_id  organization_id
, nvl(ccit.transfer_organization_id,-1) transfer_organization_id
, ccit.subinventory_code  subinventory_code
, nvl(ccit.transfer_price,0) transfer_price
, ccit.shipment_number  shipment_number
, ccit.transfer_transaction_id  transfer_transaction_id
, nvl(ccit.transfer_cost,0)  transfer_cost
, nvl(ccit.transportation_cost,0)  transportation_cost
, nvl(ccit.transfer_percentage,0)  transfer_percentage
, DECODE(msi.inventory_asset_flag,'Y',0,1) exp_item
, DECODE(msubinv.asset_inventory,1,0,1) exp_flag
FROM
  CST_PAC_INTERORG_TXNS_TMP ccit
  , mtl_system_items msi
  , mtl_secondary_inventories msubinv
WHERE ccit.inventory_item_id = c_inventory_item_id
AND ccit.cost_group_id = c_cost_group_id
AND ccit.pac_period_id = c_period_id
AND ccit.inventory_item_id = msi.inventory_item_id
AND msi.organization_id = ccit.organization_id
AND msubinv.organization_id(+) = ccit.organization_id
AND msubinv.secondary_inventory_name(+) = ccit.subinventory_code
AND ccit.txn_type = 2;

TYPE group2_interorg_tab IS TABLE OF group2_interorg_cur%rowtype INDEX BY BINARY_INTEGER;
l_group2_interorg_tab		group2_interorg_tab;
l_empty_gp2_interorg_tab	group2_interorg_tab;

l_loop_count       NUMBER := 0;
l_batch_size       NUMBER := 200;
-- Error message variables
l_error_num      NUMBER;
l_error_code     VARCHAR2(240);
l_error_msg      VARCHAR2(240);
l_return_status  VARCHAR2(1);
l_txn_category   NUMBER;

BEGIN

      -- initialize transaction category for interorg shipments across CGs as cost derived txns
  l_txn_category := 9;

      -- ==================================================================
      -- Process Group 2 cost derived transactions
      -- ==================================================================
  IF NOT group2_interorg_cur%ISOPEN THEN
     OPEN group2_interorg_cur(p_cost_group_id
	 		     ,p_inventory_item_id
			     ,p_period_id
			     );
  END IF;

  LOOP

      l_group2_interorg_tab := l_empty_gp2_interorg_tab;
      FETCH group2_interorg_cur BULK COLLECT INTO l_group2_interorg_tab LIMIT l_batch_size;

      l_loop_count := l_group2_interorg_tab.count;

      FOR i IN 1..l_loop_count
      LOOP

	      IF (l_group2_interorg_tab(i).subinventory_code IS NULL) THEN
			l_group2_interorg_tab(i).exp_flag := l_group2_interorg_tab(i).exp_item;
	      ELSIF (l_group2_interorg_tab(i).exp_item = 1) THEN
			l_group2_interorg_tab(i).exp_flag := 1;
	      END IF;

	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.exp_flag'
                          ,'Exp Flag:' || l_group2_interorg_tab(i).exp_flag || ' ' ||
                           'Exp Item:' || l_group2_interorg_tab(i).exp_item
                          );
	      END IF;

	      -- insert into cppb for 1000 inventory items
	      l_error_num := 0;

	      IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
		        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
				                 ,i_cost_group_id     => p_cost_group_id
						 ,i_txn_category      => l_txn_category
		                                 ,i_user_id           => FND_GLOBAL.user_id
				                 ,i_login_id          => FND_GLOBAL.login_id
		                                 ,i_request_id        => FND_GLOBAL.conc_request_id
				                 ,i_prog_id           => FND_GLOBAL.conc_program_id
						 ,i_prog_appl_id      => FND_GLOBAL.prog_appl_id
		                                 ,o_err_num           => l_error_num
				                 ,o_err_code          => l_error_code
						 ,o_err_msg           => l_error_msg
		                                 );
		        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                        ,G_MODULE_HEAD || l_routine || '.incppbii1'
			        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
	                );
		        END IF;
	      END IF; -- item existence check in item table

	      IF l_error_num = 0 THEN

	      -- Invoke PAC inventory cost processor
			CSTPPINV.cost_inv_txn( i_pac_period_id    => p_period_id
					     , i_legal_entity     => p_legal_entity_id
		                             , i_cost_type_id     => p_cost_type_id
		                             , i_cost_group_id    => p_cost_group_id
		                             , i_cost_method      => p_cost_method
		                             , i_txn_id           => l_group2_interorg_tab(i).transaction_id
		                             , i_txn_action_id    => l_group2_interorg_tab(i).transaction_action_id
		                             , i_txn_src_type_id  => l_group2_interorg_tab(i).transaction_source_type_id
		                             , i_item_id          => l_group2_interorg_tab(i).inventory_item_id
		                             , i_txn_qty          => l_group2_interorg_tab(i).primary_quantity
		                             , i_txn_org_id       => l_group2_interorg_tab(i).organization_id
		                             , i_txfr_org_id      => l_group2_interorg_tab(i).transfer_organization_id
		                             , i_subinventory_code => l_group2_interorg_tab(i).subinventory_code
		  		             , i_exp_flag          => l_group2_interorg_tab(i).exp_flag
		                             , i_exp_item          => l_group2_interorg_tab(i).exp_item
		                             , i_pac_rates_id      => p_pac_rates_id
				             , i_process_group     => 2
		                             , i_master_org_id     => p_master_org_id
				             , i_uom_control       => p_uom_control
		                             , i_user_id           => FND_GLOBAL.user_id
		                             , i_login_id          => FND_GLOBAL.login_id
		                             , i_request_id        => FND_GLOBAL.conc_request_id
		                             , i_prog_id           => FND_GLOBAL.conc_program_id
		                             , i_prog_appl_id      => FND_GLOBAL.prog_appl_id
		                             , i_txn_category      => l_txn_category
		                             , i_transfer_price_pd => l_group2_interorg_tab(i).transfer_price
		                             , o_err_num           => l_error_num
		                             , o_err_code          => l_error_code
		                             , o_err_msg           => l_error_msg
		                           );

		        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
			      ,G_MODULE_HEAD || l_routine || '.PAC_inv_Processor_gp2'
	                      ,'PAC Inventory Processor:'|| l_error_num || ' ' ||
		               l_error_code || ' ' || l_error_msg
			 );
		        END IF;


	      END IF; -- error num check

	      IF l_error_num <> 0 THEN
		         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
			    , G_MODULE_HEAD || l_routine || '.others'
	                    , 'group2 cost_inv_txn for cost group '|| p_cost_group_id ||' txn id '
	                                 || l_group2_interorg_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
	                    );
			  END IF;
		          FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
		          FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		          FND_MESSAGE.set_token('MESSAGE', 'group2 cost_inv_txn for cost group '|| p_cost_group_id ||' txn id '
	                                 || l_group2_interorg_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
			  FND_MSG_PUB.Add;
		          RAISE FND_API.G_EXC_ERROR;
              END IF;

		-- Insert into MTL_PAC_ACT_CST_DTL_TEMP only if the iteration
		-- process flag is enabled and consecutive iterations exist

	      IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN

			-- Cost derived transactions
		        INSERT INTO MTL_PAC_ACT_CST_DTL_TEMP
		        ( COST_GROUP_ID
		        , TRANSACTION_ID
		        , PAC_PERIOD_ID
		        , COST_TYPE_ID
		        , COST_ELEMENT_ID
		        , LEVEL_TYPE
		        , INVENTORY_ITEM_ID
		        , COST_LAYER_ID
		        , ACTUAL_COST
		        , USER_ENTERED
		        , INSERTION_FLAG
		        , TRANSACTION_COSTED_DATE
		        , SHIPMENT_NUMBER
		        , TRANSFER_TRANSACTION_ID
		        , TRANSPORTATION_COST
		        , MOH_ABSORPTION_COST
		        )
		        SELECT
		          cost_group_id
		        , transaction_id
		        , pac_period_id
		        , cost_type_id
		        , cost_element_id
		        , level_type
		        , inventory_item_id
		        , cost_layer_id
		        , actual_cost
		        , user_entered
		        , insertion_flag
		        , transaction_costed_date
		        , l_group2_interorg_tab(i).shipment_number
		        , l_group2_interorg_tab(i).transfer_transaction_id
		        , decode(cost_element_id,2,
		                 decode(level_type,1,l_group2_interorg_tab(i).transportation_cost,0),0)
		        , 0
		        FROM MTL_PAC_ACTUAL_COST_DETAILS
		        WHERE transaction_id = l_group2_interorg_tab(i).transaction_id
		          AND cost_group_id  = p_cost_group_id
		          AND pac_period_id  = p_period_id
		          AND cost_type_id   = p_cost_type_id;

	            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                            ,G_MODULE_HEAD || l_routine || '.after_ins_gp2'
                            ,'After inserting mtl_pac_act_cst_dtl_temp:' ||
                              l_group2_interorg_tab(i).transaction_id
                            );
	            END IF;

		-- Bug 5593086 Pad with nonexistent rows
			INSERT INTO MTL_PAC_ACT_CST_DTL_TEMP
			( COST_GROUP_ID
		        , TRANSACTION_ID
		        , PAC_PERIOD_ID
 		        , COST_TYPE_ID
		        , COST_ELEMENT_ID
		        , LEVEL_TYPE
		        , INVENTORY_ITEM_ID
		        , COST_LAYER_ID
		        , ACTUAL_COST
   		        , USER_ENTERED
  		        , INSERTION_FLAG
		        , TRANSACTION_COSTED_DATE
		        , SHIPMENT_NUMBER
		        , TRANSFER_TRANSACTION_ID
		        , TRANSPORTATION_COST
		        , MOH_ABSORPTION_COST
		        )
		        SELECT
		          mpacd.cost_group_id
		        , mpacd.transaction_id
    		        , mpacd.pac_period_id
		        , mpacd.cost_type_id
		        , cce.cost_element_id
		        , lt.level_type
		        , mpacd.inventory_item_id
		        , mpacd.cost_layer_id
		        , 0
		        , mpacd.user_entered
		        , mpacd.insertion_flag
		        , mpacd.transaction_costed_date
		        , l_group2_interorg_tab(i).shipment_number
		        , l_group2_interorg_tab(i).transfer_transaction_id
		        , 0
		        , 0
		        FROM (SELECT *
		          FROM MTL_PAC_ACTUAL_COST_DETAILS
		          WHERE transaction_id = l_group2_interorg_tab(i).transaction_id
		            AND cost_group_id  = p_cost_group_id
		            AND pac_period_id  = p_period_id
		            AND cost_type_id   = p_cost_type_id
		            AND rownum = 1) mpacd,
		          CST_COST_ELEMENTS cce,
		          (SELECT 1 level_type FROM DUAL
		           UNION
		           SELECT 2 level_type FROM DUAL) lt
			    WHERE NOT EXISTS
		         (SELECT 1
		          FROM   mtl_pac_act_cst_dtl_temp mpacdt
		          WHERE  mpacdt.cost_group_id = p_cost_group_id
		          AND    mpacdt.transaction_id = l_group2_interorg_tab(i).transaction_id
		          AND    mpacdt.pac_period_id = p_period_id
		          AND    mpacdt.cost_type_id = p_cost_type_id
		          AND    mpacdt.cost_element_id = cce.cost_element_id
		          AND    mpacdt.level_type = lt.level_type);


			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.after_pad_gp2'
				,'After padding mtl_pac_act_cst_dtl_temp:'||
				l_group2_interorg_tab(i).transaction_id
			);
			END IF;

	      END IF; --  IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN
       END LOOP; -- FOR i IN 1..l_loop_count

      EXIT WHEN group2_interorg_cur%NOTFOUND;
  END LOOP; --	FETCH loop
  CLOSE group2_interorg_cur;

      -- ======================================================
      -- Only for FIRST iteration perform:
      -- insert left over interorg issues into cppb
      -- Update CPPB
      -- ======================================================
      l_error_num := 0;

      IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
		    CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
				             ,i_cost_group_id     => p_cost_group_id
					     ,i_txn_category      => l_txn_category
	                                     ,i_user_id           => FND_GLOBAL.user_id
		                             ,i_login_id          => FND_GLOBAL.login_id
				             ,i_request_id        => FND_GLOBAL.conc_request_id
					     ,i_prog_id           => FND_GLOBAL.conc_program_id
	                                     ,i_prog_appl_id      => FND_GLOBAL.prog_appl_id
		                             ,o_err_num           => l_error_num
			                     ,o_err_code          => l_error_code
					     ,o_err_msg           => l_error_msg
		                             );

	            l_error_num  := NVL(l_error_num, 0);
		    l_error_code := NVL(l_error_code, 'No Error');
	            l_error_msg  := NVL(l_error_msg, 'No Error');

	  	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			  FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.inscppii2'
                          ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                          );
	            END IF;
        END IF; -- item existence check in item table

        IF l_error_num = 0 THEN
		    CSTPPWAC.update_item_cppb(i_pac_period_id     => p_period_id
				             ,i_cost_group_id     => p_cost_group_id
        	                             ,i_txn_category      => l_txn_category
		                             ,i_item_id           => p_inventory_item_id
				             ,i_user_id           => FND_GLOBAL.user_id
	                                     ,i_login_id          => FND_GLOBAL.login_id
		                             ,i_request_id        => FND_GLOBAL.conc_request_id
				             ,i_prog_id           => FND_GLOBAL.conc_program_id
	                                     ,i_prog_appl_id      => FND_GLOBAL.prog_appl_id
		                             ,o_err_num           => l_error_num
				             ,o_err_code          => l_error_code
					     ,o_err_msg           => l_error_msg
	                                     );

	            l_error_num  := NVL(l_error_num, 0);
		    l_error_code := NVL(l_error_code, 'No Error');
	            l_error_msg  := NVL(l_error_msg, 'No Error');

		    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.upppii1'
                          ,'After calling update_item_cppb:'|| l_error_num || l_error_code || l_error_msg
                          );
	            END IF;
        END IF; -- error check

        IF l_error_num <> 0 THEN
	            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine || '.others'
                    , 'CSTPPWAC.update_item_cppb for CG '|| p_cost_group_id ||' txn category '
	                                 ||l_txn_category||' t_low_level_code ' ||p_low_level_code
					 ||' error('||l_error_code||') '||l_error_msg
                    );
		  END IF;
	          FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
		  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	          FND_MESSAGE.set_token('MESSAGE', 'CSTPPWAC.update_item_cppb for CG '|| p_cost_group_id ||' txn category '
	                                 ||l_txn_category||' t_low_level_code ' ||p_low_level_code
					 ||' error('||l_error_code||') '||l_error_msg);
		  FND_MSG_PUB.Add;
	          RAISE FND_API.G_EXC_ERROR;
        END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Group2_Interorg_Iteration1;
-- +========================================================================+
-- PROCEDURE: Compute_Iterative_Pwac_Cost   PRIVATE UTILITY
-- PARAMETERS:
--   p_legal_entity_id          NUMBER
--   p_cost_type_id             NUMBER
--   p_cost_method              NUMBER
--   p_inventory_item_id        NUMBER
--   p_period_id                NUMBER
--   p_period_start_date        DATE
--   p_period_end_date          DATE
--   p_iteration_num            NUMBER
--   p_end_iteration_num        NUMBER
--   p_pac_rates_id             NUMBER
--   p_uom_control              NUMBER
--   p_iteration_proc_flag      VARCHAR2
--   x_return_status        OUT NOCOPY VARCHAR2
--   x_error_msg            OUT NOCOPY VARCHAR2
-- COMMENT:
--   This procedure is called by the API iteration_process
--   FOR each optimal cost group LOOP
--     Is the iteration is FIRST iteration
--       default current behavior
--       Process Group 1 (cost owned) interorg transactions across CGs
--       using existing api
--       Process Group 2 (cost derived) interorg transactions across CGs
--       using existing api
--     Is the iteration NOT FIRST iteration
--       consecutive iteration process
--       Process Group 1 (cost owned) interorg txns across CGs
--       Process Group 2 (cost owned) interorg txns across CGs
--   END LOOP
-- PRE-COND:   none
-- EXCEPTIONS:
-- +========================================================================+
PROCEDURE Compute_Iterative_Pwac_Cost
( p_legal_entity_id          IN  NUMBER
, p_cost_type_id             IN  NUMBER
, p_cost_method              IN  NUMBER
, p_inventory_item_id        IN  NUMBER
, p_inventory_item_number    IN  VARCHAR2
, p_cost_group_id            IN  NUMBER
, p_low_level_code           IN  NUMBER
, p_period_id                IN  NUMBER
, p_period_start_date        IN  DATE
, p_period_end_date          IN  DATE
, p_iteration_num            IN  NUMBER
, p_end_iteration_num        IN  NUMBER
, p_pac_rates_id             IN  NUMBER
, p_uom_control              IN  NUMBER
, p_iteration_proc_flag      IN  VARCHAR2
)
IS

-- routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Compute_Iterative_Pwac_Cost';

-- ================================================================
-- Cursor to get Group 1 (cost owned) interorg transactions
-- across Cost Groups
-- Support transfer pricing option:
-- Profile option value: 0 and 1: Include interorg txns from OM
-- Profile option value: 2 : Do not include interorg txns from OM
-- OPM Convergence: Exclude opm logical receipt 15
-- normal interorg receipts other than generated through internal
-- sales orders
-- interorg receipts generated through internal sales orders only
-- when the transfer price option is 0 or 1 (not enabled)
-- transaction source type 7  - internal requisition
-- transaction source type 8  - internal order
-- transaction source type 13 - Oracle Inventory
-- ================================================================
CURSOR group1_interorg_cur(c_cost_group_id          NUMBER
                          ,c_inventory_item_id      NUMBER
			  ,c_period_id              NUMBER
                          )
IS
SELECT
  ccit.transaction_id   transaction_id
, ccit.transaction_action_id   transaction_action_id
, ccit.transaction_source_type_id  transaction_source_type_id
, ccit.inventory_item_id  inventory_item_id
, ccit.primary_quantity   primary_quantity
, ccit.periodic_primary_quantity  periodic_primary_quantity
, ccit.organization_id  organization_id
, nvl(ccit.transfer_organization_id,-1) transfer_organization_id
, ccit.subinventory_code  subinventory_code
, nvl(ccit.transfer_price,0) transfer_price
, ccit.shipment_number shipment_number
, ccit.transfer_transaction_id  transfer_transaction_id
, ccit.waybill_airbill waybill_airbill
, nvl(ccit.transfer_cost,0)  transfer_cost
, nvl(ccit.transportation_cost,0)  transportation_cost
, nvl(ccit.transfer_percentage,0)  transfer_percentage
, DECODE(msi.inventory_asset_flag,'Y',0,1) exp_item
, DECODE(msubinv.asset_inventory,1,0,1) exp_flag
FROM
CST_PAC_INTERORG_TXNS_TMP ccit
 , mtl_system_items msi
  , mtl_secondary_inventories msubinv
WHERE ccit.inventory_item_id = c_inventory_item_id
AND ccit.cost_group_id = c_cost_group_id
AND ccit.pac_period_id = c_period_id
AND ccit.inventory_item_id = msi.inventory_item_id
AND msi.organization_id = ccit.organization_id
AND msubinv.organization_id(+) = ccit.organization_id
AND msubinv.secondary_inventory_name(+) = ccit.subinventory_code
AND ccit.txn_type = 1;

TYPE group1_interorg_tab IS TABLE OF group1_interorg_cur%rowtype INDEX BY BINARY_INTEGER;
l_group1_interorg_tab		group1_interorg_tab;
l_empty_gp1_interorg_tab	group1_interorg_tab;

-- Cursor to obtain PAC transaction cost element, level type and
-- cost information
CURSOR pac_txn_cursor(c_cost_group_id     NUMBER
                     ,c_period_id         NUMBER
                     ,c_transaction_id    NUMBER
                     ,c_inventory_item_id NUMBER
                     )
IS
SELECT
  cost_layer_id
, prior_buy_cost
, prior_make_cost
, new_buy_cost
, new_make_cost
, cost_element_id
, level_type
, prior_cost
, actual_cost
, new_cost
, transfer_transaction_id
, transfer_cost
, transportation_cost
, moh_absorption_cost
, new_buy_quantity
FROM
  mtl_pac_act_cst_dtl_temp
WHERE pac_period_id     = c_period_id
  AND cost_group_id     = c_cost_group_id
  AND transaction_id    = c_transaction_id
  AND inventory_item_id = c_inventory_item_id
ORDER BY
  cost_element_id
, level_type
, transaction_id
FOR UPDATE;

pac_txn_cursor_row   pac_txn_cursor%rowtype;

-- cursor to get pac actual cost from
-- mpacd_temp
CURSOR actual_cost_cur(c_pac_period_id      NUMBER
                      ,c_cost_group_id      NUMBER
                      ,c_inventory_item_id  NUMBER
                      ,c_transaction_id     NUMBER
                      ,c_cost_element_id    NUMBER
                      ,c_level_type         NUMBER
                      )
IS
SELECT
  nvl(actual_cost,0) actual_cost
FROM
  mtl_pac_act_cst_dtl_temp
WHERE pac_period_id     = c_pac_period_id
  AND cost_group_id     = c_cost_group_id
  AND inventory_item_id = c_inventory_item_id
  AND transaction_id    = c_transaction_id
  AND cost_element_id   = c_cost_element_id
  AND level_type        = c_level_type;

-- Cursor to retrieve item cost of a cost group from
-- interorg items temp table
CURSOR prev_itr_item_cost_cur(c_pac_period_id      NUMBER
                             ,c_cost_group_id      NUMBER
                             ,c_inventory_item_id  NUMBER
                             )
IS
SELECT
  nvl(item_cost,0),
  nvl(difference,0)
FROM CST_PAC_INTORG_ITMS_TEMP
WHERE pac_period_id     = c_pac_period_id
  AND cost_group_id     = c_cost_group_id
  AND inventory_item_id = c_inventory_item_id;


l_txn_qty              NUMBER := 0;
l_new_correspond_cost  NUMBER := 0;
l_correspond_pmac_cost NUMBER := 0;
l_cost_element_id      NUMBER := -99;
l_level_type           NUMBER := -99;

l_loop_count       NUMBER := 0;
l_batch_size       NUMBER := 200;

-- Assign transaction variable
l_pwac_new_cost        NUMBER := 0;

l_pwac_item_cost        NUMBER := 0;
l_old_difference            NUMBER;
l_new_difference            NUMBER;
-- Previous iteraton item cost variable
l_prev_itr_item_cost    NUMBER := 0;
l_transfer_cost         NUMBER := 0;
l_unit_transfer_cost    NUMBER := 0;

-- Master Organization of Cost Group
-- NOTE: All organizations under the Cost Group have same master item org
-- expense flag variables

l_valid_txn_flag  VARCHAR2(1);

-- Error message variables
l_error_num      NUMBER;
l_error_code     VARCHAR2(240);
l_error_msg      VARCHAR2(240);
l_return_status  VARCHAR2(1);

-- Transaction category
l_txn_category   NUMBER;
l_txn_quantity   NUMBER;
l_actual_cost    NUMBER;

-- binary index for PWAC New cost table
l_cg_pwac_idx    BINARY_INTEGER;

-- period balance including interorg receipts
l_period_quantity  NUMBER := 0;
-- period running balance
l_period_new_balance NUMBER;

l_cg_idx        BINARY_INTEGER;
l_cost_group_id_idx           BINARY_INTEGER;
l_cost_group_name             VARCHAR2(10);

-- bug 7674673 fix
l_pcu_value_balance NUMBER;
l_cg_elmnt_lv_idx BINARY_INTEGER;

-- Exceptions
l_diverging_exception  EXCEPTION;
BEGIN

  -- ==================================================================
  -- Retrieve Balance before interorg txns across Cost Groups from CPPB
  -- Store the period quantity, period balance into G_PWAC_NEW_COST_TBL
  -- NOTE: G_PWAC_NEW_COST_TBL is deleted at the end of each optimal
  -- cost group in each iteration
  -- period quantity before intorg is stored in G_CST_GROUP_TBL
  -- ==================================================================
    Get_Balance_Before_Intorg(p_period_id           => p_period_id
                             ,p_cost_group_id       => p_cost_group_id
                             ,p_inventory_item_id   => p_inventory_item_id
                             );
    -- =========================================================================
    -- initialize period running quantity at each consecutive iteration.
    -- period quantity is same for all the cost elements, level type for a given
    -- inventory item, cost group, pac period
    -- =========================================================================
    l_period_quantity := G_PWAC_NEW_COST_TBL(1)(1).period_qty_bef_intorg;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.qtybef'
                    ,'Qty before intorg txns:' || l_period_quantity
                    );
    END IF;


   /* If cost is found to be diverging after successive iterations,
      the changes done for this CG will be rolled back.
      The validation of divergence can be done after 3rd iteration.
      Item cost can be said to be diverging if the following is true
      abs(current iteration item cost - previous iteration item cost)
      is more than or equal to abs(previous iteration item cost - the one before that)
    */

    SAVEPOINT diverge_case;

    -- initialize transaction category for interorg receipts across CGs
    l_txn_category := 8;

    -- ===================================================================
    -- Process Group 1 cost owned interorg transactions
    -- ===================================================================
    IF NOT group1_interorg_cur%ISOPEN THEN
     OPEN group1_interorg_cur(p_cost_group_id
	 		     ,p_inventory_item_id
			     ,p_period_id
			     );
    END IF;

    LOOP

      l_group1_interorg_tab := l_empty_gp1_interorg_tab;
      FETCH group1_interorg_cur BULK COLLECT INTO l_group1_interorg_tab LIMIT l_batch_size;

      l_loop_count := l_group1_interorg_tab.count;

      FOR i IN 1..l_loop_count
      LOOP
	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.group1_interorg'
                    ,'Group 1 -- Transaction Id:'|| l_group1_interorg_tab(i).transaction_id
                    );
	    END IF;

	    IF (l_group1_interorg_tab(i).subinventory_code IS NULL) THEN
			l_group1_interorg_tab(i).exp_flag := l_group1_interorg_tab(i).exp_item;
	    ELSIF (l_group1_interorg_tab(i).exp_item = 1) THEN
			l_group1_interorg_tab(i).exp_flag := 1;
	    END IF;

	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.exp_flag'
                    ,'Expense Flag:'|| l_group1_interorg_tab(i).exp_flag ||
                     ' Expense Item:' || l_group1_interorg_tab(i).exp_item
                    );
	    END IF;

	      -- ================================================================
	      -- Consecutive Iterations
	      -- Only for cost groups where interorg receipt exists
	      -- In other words, sequence number 1 should be processed only once
	      -- ----------------------------------------------------------------
	      -- Additional criteria:No PMAC calculation for the below conditions:
	      -- Direct interorg receipt, received in expense subinventory
	      -- Intransit receipt FOB:Receipt, received in expense subinventory
	      -- ----------------------------------------------------------------
	      -- Perform PMAC calculation always when
	      -- Intransit shipment FOB:Shipment, irrespective of the receiving
	      -- in Asset or non-asset sub inventory as it will not be know until
	      -- the intransit receipt is created
	      -- At the time of intransit receipt, the deduction of qty is done
	      -- if received in expense sub inventory.  No deduction of qty if
	      -- received in asset sub inventory.  In either case, cost will NOT
	      -- change
	      -- ----------------------------------------------------------------
	      l_valid_txn_flag := 'Y';

	      IF (l_group1_interorg_tab(i).transaction_action_id = 3 AND
	        l_group1_interorg_tab(i).primary_quantity > 0) OR
		 (l_group1_interorg_tab(i).transaction_action_id = 12) THEN

	        -- Check whether sub inventory is expense sub inventory
	        IF l_group1_interorg_tab(i).exp_flag = 1 THEN
		  l_valid_txn_flag := 'N';
	        END IF;

	      END IF;

	      IF l_valid_txn_flag = 'Y' THEN

		-- ----------------------------------------------------------------
	        -- Consecutive Iterations for Cost Owned Transactions
	        -- Re-calculate PWAC cost
	        -- --------------------------------------------------------------
		-- Reverse the sign of quantity, since shipment is processed by
	        -- receiving cost group
	        IF (l_group1_interorg_tab(i).transaction_action_id = 21) THEN
	          l_txn_qty  := l_group1_interorg_tab(i).primary_quantity * -1;
	        ELSE
	          l_txn_qty  := l_group1_interorg_tab(i).primary_quantity;
	        END IF;

	        -- period balance quantity
	        l_period_quantity := l_period_quantity + l_txn_qty;


	        -- Get PAC Transaction Cost element Id, Level Type and
	        -- Cost Information
	        OPEN pac_txn_cursor(p_cost_group_id
		                 ,p_period_id
			         ,l_group1_interorg_tab(i).transaction_id
				 ,p_inventory_item_id
	                         );

		FETCH pac_txn_cursor
	        INTO pac_txn_cursor_row;

		l_cost_element_id  := pac_txn_cursor_row.cost_element_id;
	        l_level_type       := pac_txn_cursor_row.level_type;


		WHILE pac_txn_cursor%FOUND LOOP

		          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
			        ,G_MODULE_HEAD || l_routine || '.pac_txn_cursor'
				,'Cost element Id:' || l_cost_element_id || ' '
	                         || 'Level Type:' || l_level_type
		                );
		          END IF;


		        --  Get New pwac Cost of corresponding Cost Group for the cost element, level type
		        Get_Correspond_Pwac_New_Cost(p_cost_group_id       => p_cost_group_id
						 ,p_cost_type_id         => p_cost_type_id
						 ,p_opp_transaction_id   => l_group1_interorg_tab(i).transfer_transaction_id
		                                 ,p_period_id            => p_period_id
				                 ,p_organization_id      => l_group1_interorg_tab(i).organization_id
		                                 ,p_opp_organization_id  => l_group1_interorg_tab(i).transfer_organization_id
				                 ,p_transaction_id       => l_group1_interorg_tab(i).transaction_id
		                                 ,p_transaction_action_id => l_group1_interorg_tab(i).transaction_action_id
		                                 ,p_cost_element_id       => l_cost_element_id
				                 ,p_level_type            => l_level_type
		                                 ,p_group_num             => 1
				                 ,x_new_correspond_cost   => l_new_correspond_cost );

		        -- ============================================================================
		        -- Calculate transfer cost as a percentage of PMAC of shipping cost group
		        -- MOH Cost element, current level
		        -- ============================================================================
		         IF l_cost_element_id = 2 AND l_level_type = 1 THEN
			          l_txn_quantity := abs(l_group1_interorg_tab(i).primary_quantity);

			          IF l_group1_interorg_tab(i).transfer_percentage <> 0 THEN

			            --  Get Pmac Cost of corresponding Cost Group - sum of all cost elements, level types
				            Get_Correspond_Pmac_Cost(p_cost_group_id       => p_cost_group_id
								  ,p_cost_type_id        => p_cost_type_id
				                                  ,p_opp_transaction_id   => l_group1_interorg_tab(i).transfer_transaction_id
				                                  ,p_period_id            => p_period_id
								  ,p_organization_id      => l_group1_interorg_tab(i).organization_id
				                                  ,p_opp_organization_id  => l_group1_interorg_tab(i).transfer_organization_id
								  ,p_transaction_id       => l_group1_interorg_tab(i).transaction_id
				                                  ,p_transaction_action_id => l_group1_interorg_tab(i).transaction_action_id
								 ,p_group_num             => 1
				                                 ,x_correspond_pmac_cost   => l_correspond_pmac_cost);

				             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					              FND_LOG.string(FND_LOG.LEVEL_STATEMENT
			                            ,G_MODULE_HEAD || l_routine || '.corr_pmac'
						    ,'Correspond PMAC Cost:' || l_correspond_pmac_cost
			                          );
				             END IF;

				             l_unit_transfer_cost :=
						            (l_correspond_pmac_cost * l_group1_interorg_tab(i).transfer_percentage / 100);

			          ELSIF l_group1_interorg_tab(i).transfer_cost <> 0 THEN   --IF l_group1_idx.transfer_percentage <> 0 THEN

				            -- Transfer percentage is not set; Get the transfer cost amount from MMT
				            -- To obtain Unit Transfer Cost: Transfer cost amount of MMT to be divided by txn qty
				            l_transfer_cost      := l_group1_interorg_tab(i).transfer_cost;
				            l_unit_transfer_cost := l_transfer_cost / l_txn_quantity;

			          END IF; -- IF l_group1_idx.transfer_percentage <> 0 THEN

			          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
		                          ,G_MODULE_HEAD || l_routine || '.txfr_cost1'
		                          ,'Transaction Qty:' || l_txn_quantity || ' Transfer Percentage:' || l_group1_interorg_tab(i).transfer_percentage || ' Unit Transfer Cost:' || l_unit_transfer_cost
				   );
			          END IF;

		         END IF; --IF l_cost_element_id = 2 AND l_level_type = 1


			-- =======================================================================
		        -- Update Actual Cost with New Cost of corresponding transaction
		        -- For cost element 2 - MOH, actual_cost will be New Cost of corresponding
		        -- transaction cost  + Unit Transfer Cost + Unit Transportation Cost
		        -- + moh_absorption_cost
		        -- For all other cost elements, actual_cost will be New Cost of
		        -- corresponding transaction
		        -- =======================================================================
		        UPDATE MTL_PAC_ACT_CST_DTL_TEMP
		          SET actual_cost = decode(cost_element_id, 2,
                             decode(level_type,1, (l_new_correspond_cost + l_unit_transfer_cost +
                             (transportation_cost/l_txn_quantity) + moh_absorption_cost), l_new_correspond_cost),l_new_correspond_cost)
		           , transfer_cost = DECODE(cost_element_id, 2, decode(level_type,1, l_unit_transfer_cost,0),0)
		         WHERE CURRENT OF pac_txn_cursor;

		         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			         FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                       ,G_MODULE_HEAD || l_routine || '.upd_with_new_cost'
		               ,'New Cost of corresponding transaction:' || l_new_correspond_cost
			       );

			         FND_LOG.string(FND_LOG.LEVEL_STATEMENT
		                 ,G_MODULE_HEAD || l_routine || '.transmohcost'
			       ,'Transfer Cost:' || pac_txn_cursor_row.transfer_cost
				|| ' Transportation Cost:' || pac_txn_cursor_row.transportation_cost || ' Transaction Qty:' || abs(l_group1_interorg_tab(i).primary_quantity) || ' MOH Absorption Cost:' || pac_txn_cursor_row.moh_absorption_cost
	                       );

		         END IF;

		         -- ===============================================================================
		         -- Calculate running period balance at each iteration
		         -- To store period new balance for each cost element, level type for a given
		         -- inventory item id, cost group, pac period
		         -- ===============================================================================


		         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.pac_txn_cursor_first'
	                        ,'Cost element Id:' || l_cost_element_id || ' '
		                 || 'Level Type:' || l_level_type
			        );
		         END IF;

		         -- ======================================
	                 -- Get Actual Cost from MPACD TEMP
		         -- current value of actual cost
		         -- ======================================
		         OPEN actual_cost_cur(p_period_id
			                ,p_cost_group_id
				        ,p_inventory_item_id
					,l_group1_interorg_tab(i).transaction_id
	                                ,l_cost_element_id
		                        ,l_level_type
			                );
	                 FETCH actual_cost_cur
	                 INTO l_actual_cost;

			 IF actual_cost_cur%NOTFOUND THEN
		                l_actual_cost := 0;
	                 END IF;

		         CLOSE actual_cost_cur;


		         -- cumulate the running balance for cost element,level type
		         G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance :=
		              G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance + l_txn_qty * l_actual_cost;

	                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			     FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                     ,G_MODULE_HEAD || l_routine || '.newbal'
		             ,'New balance before PCU value change:' || G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance
			     );
		         END IF;



		         -- ===============================================
		         -- Calculate Variance Amount and update MPACD_TEMP
		         -- ===============================================
		         l_period_new_balance :=
			          G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance;

		          UPDATE mtl_pac_act_cst_dtl_temp
		           SET variance_amount = decode(sign(l_period_quantity),
                                   0, l_period_new_balance,
                                   (-1 * sign(l_period_new_balance)),
                                 l_period_new_balance,0)
		          WHERE CURRENT OF pac_txn_cursor;


		 -- Fetch next PAC transaction
		 FETCH pac_txn_cursor
		   INTO pac_txn_cursor_row;

		 EXIT WHEN pac_txn_cursor%NOTFOUND;

		 l_cost_element_id := pac_txn_cursor_row.cost_element_id;
                 l_level_type      := pac_txn_cursor_row.level_type;

                 END LOOP;       --WHILE pac_txn_cursor%FOUND LOOP

	         CLOSE pac_txn_cursor;

	      END IF; -- valid txn flag check

      END LOOP; -- FOR i IN 1..l_loop_count

      EXIT WHEN group1_interorg_cur%NOTFOUND;
    END LOOP; --	FETCH loop
    CLOSE group1_interorg_cur;

  -- ============================================================
  -- Re-average to calculate the new periodic moving average cost
  -- of the item in each cost element, level type
  -- ============================================================
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.qtyaft'
                  ,'Period Quantity after interorg receipts:'|| l_period_quantity
                  );
  END IF;

  -- Calculate the item cost since all cost owned interorg transactions are processed
  -- Set period quantity after all interorg receipts
  l_cg_idx :=  p_cost_group_id;
  G_CST_GROUP_TBL(l_cg_idx).period_new_quantity := l_period_quantity;

  IF p_iteration_num > 1 THEN
         l_cost_element_id := 1;
	 WHILE l_cost_element_id <= 5 LOOP
	   l_level_type := 1;
	   WHILE l_level_type <= 2 LOOP

              -- =============================
              -- Bug 7674673 fix
	      -- Get PCU Value Change Balance
	      -- =============================
	      l_cg_elmnt_lv_idx := TO_CHAR(p_cost_group_id) || TO_CHAR(l_cost_element_id) || TO_CHAR(l_level_type);

              IF G_PCU_VALUE_CHANGE_TBL.EXISTS(l_cg_elmnt_lv_idx) THEN
		l_pcu_value_balance := G_PCU_VALUE_CHANGE_TBL(l_cg_elmnt_lv_idx).pcu_value_balance;
	      ELSE
		l_pcu_value_balance := 0;
	      END IF;

                   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	              ,G_MODULE_HEAD || l_routine || '.pcuvalbal'
		      ,'PCU value change balance: CG-element-level' || l_cg_elmnt_lv_idx || ' '
		       || l_pcu_value_balance
		      );
		   END IF;


	      -- ===========================================================================
	      -- New Period Balance after adding PCU value change at each iteration
	      -- ===========================================================================
	      G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance :=
              G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance + l_pcu_value_balance;

		    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
	                ,G_MODULE_HEAD || l_routine || '.newpcuval'
		        ,'New balance after PCU value change:' || G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance
		       );
		    END IF;

	      l_period_new_balance := G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance;

	      -- ===========================
	      -- Re-calculate new item cost
	      -- ===========================
	      IF (SIGN(l_period_quantity) =  (-1 * SIGN(l_period_new_balance))) OR (l_period_quantity = 0) THEN
	        -- set final new cost to 0
		G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).final_new_cost := 0;
	      ELSE
		G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).final_new_cost
		          := l_period_new_balance / l_period_quantity;
	      END IF;

	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.pdnewbal'
                      ,'Cost Element Id:' || l_cost_element_id || ' Level Type:'
                       || l_level_type || 'Period New Balance:'|| l_period_new_balance
                      );
	      END IF;
              l_level_type := l_level_type + 1;
	   END LOOP;
	   l_cost_element_id := l_cost_element_id + 1;
	 END LOOP;
  END IF;

  IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN
	 -- ==================================================================
	 -- Calculate PMAC Item Cost in the current iteration - Sum of all the
	 -- cost elements,level types
	 -- Store the current iteration and previous iteration PMAC item cost
	 -- ==================================================================

	 -- Sum of all the cost elements and level types
	 l_pwac_item_cost := 0;
         l_cost_element_id := 1;
	 -- Calculate item cost (sum of all cost elements)
	 WHILE l_cost_element_id <= 5 LOOP
   	   l_level_type := 1;
	   WHILE l_level_type <= 2 LOOP
	      l_pwac_item_cost := l_pwac_item_cost + G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).final_new_cost;
	      l_level_type := l_level_type + 1;
	   END LOOP;
	   l_cost_element_id := l_cost_element_id + 1;
	 END LOOP;


	 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine || '.pwacic'
                    , 'Cost Group Id:' || p_cost_group_id || 'PWAC Item Cost:' || l_pwac_item_cost
                    );
	 END IF;

	 -- Retrieve previous iteration pmac item cost
	 -- get item_cost
	 OPEN prev_itr_item_cost_cur(p_period_id
					,p_cost_group_id
					,p_inventory_item_id
					 );
	 FETCH prev_itr_item_cost_cur
		INTO l_prev_itr_item_cost,
		     l_old_difference;
	 CLOSE prev_itr_item_cost_cur;

	 l_new_difference := abs(l_pwac_item_cost-l_prev_itr_item_cost);

	 IF p_iteration_num > 2 and l_new_difference <> 0 and l_new_difference >= l_old_difference THEN
		ROLLBACK TO diverge_case;
		/* Update PAC tables for diverging cost group since further iterations will not take place
		   for the item in this cost group and if the item does not achieve tolerance in this run
		   and user chooses to Resume for Non Tolerance in the next run, the values in PL/SQL table
		   G_CG_PWAC_COST_TBL will be lost and update_cpicd_with_new_values will error out with no data found */
 	        Create_Mpacd_With_New_Values(p_period_id
                                            ,p_inventory_item_id
					    ,p_cost_group_id
                                             );

                Update_Cpicd_With_New_Values(p_pac_period_id      =>  p_period_id
                                            ,p_inventory_item_id  =>  p_inventory_item_id
					    ,p_cost_group_id      =>  p_cost_group_id
					    ,p_cost_type_id       =>  p_cost_type_id
					    ,p_end_date           =>  p_period_end_date
                                            );
		UPDATE CST_PAC_INTORG_ITMS_TEMP
			SET DIVERGING_FLAG = 'Y',
		            TOLERANCE_FLAG = 'Y',
			    ITERATION_COUNT = p_iteration_num
	        WHERE pac_period_id     = p_period_id
	         AND cost_group_id     = p_cost_group_id
		 AND inventory_item_id = p_inventory_item_id;

	        G_PWAC_NEW_COST_TBL.delete;

	        RAISE l_diverging_exception;
	 ELSE
		-- Set current iteration PMAC Item Cost in interorg items temp table
	        -- assigned to item_cost
		-- Set previous iteration PMAC Item Cost in interorg items temp table
	        -- assigned to previous iteration item cost
	        UPDATE CST_PAC_INTORG_ITMS_TEMP
	          SET prev_itr_item_cost  = l_prev_itr_item_cost
		     ,item_cost           = l_pwac_item_cost
	   	     ,difference          = l_new_difference
	        WHERE pac_period_id     = p_period_id
	          AND cost_group_id     = p_cost_group_id
		  AND inventory_item_id = p_inventory_item_id;
	 END IF;
  END IF; --  IF p_iteration_proc_flag = 'Y' AND p_end_iteration_num > 1 THEN


  -- initialize transaction category for interorg shipments across CGs
  -- as cost derived txns
  l_txn_category := 9;
  -- ===========================================================================
  -- Process Group 2 cost derived transactions
  -- The following update statement uses bind variables rather than PL/SQL
  -- function for performance reasons. PL/SQL Engine can give values to these
  -- bind variables before handing over to SQL Engine. With function, it'll have
  -- to switch for each record
  -- ===========================================================================

  update mtl_pac_act_cst_dtl_temp mpacdt
   set mpacdt.actual_cost = (select (CASE mpacdt.level_type
                                       WHEN  1 THEN
				             (CASE mpacdt.cost_element_id
						WHEN 1 THEN G_PWAC_NEW_COST_TBL(1)(1).final_new_cost
						WHEN 2 THEN G_PWAC_NEW_COST_TBL(2)(1).final_new_cost
						WHEN 3 THEN G_PWAC_NEW_COST_TBL(3)(1).final_new_cost
						WHEN 4 THEN G_PWAC_NEW_COST_TBL(4)(1).final_new_cost
						WHEN 5 THEN G_PWAC_NEW_COST_TBL(5)(1).final_new_cost
					      END)
                                       WHEN  2 THEN
				             (CASE mpacdt.cost_element_id
						WHEN 1 THEN G_PWAC_NEW_COST_TBL(1)(2).final_new_cost
						WHEN 2 THEN G_PWAC_NEW_COST_TBL(2)(2).final_new_cost
						WHEN 3 THEN G_PWAC_NEW_COST_TBL(3)(2).final_new_cost
						WHEN 4 THEN G_PWAC_NEW_COST_TBL(4)(2).final_new_cost
						WHEN 5 THEN G_PWAC_NEW_COST_TBL(5)(2).final_new_cost
					      END)
				     END) actual_cost
			     from dual)
  where mpacdt.transaction_id in (select ccit.transaction_id
				  FROM  CST_PAC_INTERORG_TXNS_TMP ccit
				  WHERE ccit.inventory_item_id = p_inventory_item_id
				    AND ccit.cost_group_id = p_cost_group_id
				    AND ccit.pac_period_id = p_period_id
				    AND ccit.txn_type = 2)
  and mpacdt.pac_period_id = p_period_id
  and mpacdt.cost_group_id = p_cost_group_id
  and mpacdt.inventory_item_id  = p_inventory_item_id;

  -- ======================================================================
  -- Populate G_CG_PWAC_COST_TBL from G_PWAC_NEW_COST_TBL
  -- for each cost group, at each iteration when the iteration process flag
  -- is enabled
  -- ======================================================================
  IF p_iteration_proc_flag = 'Y' THEN
    l_cost_element_id := 1;
    WHILE l_cost_element_id <= 5 LOOP
      l_level_type := 1;
      WHILE l_level_type <= 2 LOOP
	l_cg_pwac_idx := to_char(p_cost_group_id) || to_char(l_cost_element_id) || to_char(l_level_type);

        G_CG_PWAC_COST_TBL(l_cg_pwac_idx).final_new_cost := G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).final_new_cost;

        G_CG_PWAC_COST_TBL(l_cg_pwac_idx).period_new_balance := G_PWAC_NEW_COST_TBL(l_cost_element_id)(l_level_type).period_new_balance;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_HEAD || l_routine || '.fncpnb'
                        , 'Cost Group Element Level idx:' || l_cg_pwac_idx || ' CG PWAC final new cost:' || G_CG_PWAC_COST_TBL(l_cg_pwac_idx).final_new_cost || ' CG PWAC period new balance:' || G_CG_PWAC_COST_TBL(l_cg_pwac_idx).period_new_balance
                        );
        END IF;
	l_level_type := l_level_type + 1;
      END LOOP;
      l_cost_element_id := l_cost_element_id + 1;
    END LOOP;

  END IF; -- iteration process flag check

-- Delete global pl/sql table G_PWAC_NEW_COST_TBL at each cost group
  G_PWAC_NEW_COST_TBL.delete;

EXCEPTION
  WHEN l_diverging_exception THEN
   -- Just a warning. No need to raise an exception. The process can continue for other cost groups for the item.
    l_cost_group_id_idx := p_cost_group_id;
    l_cost_group_name := CST_PAC_ITERATION_PROCESS_PVT.G_CST_GROUP_TBL(l_cost_group_id_idx).cost_group;
    FND_MESSAGE.Set_Name('BOM', 'CST_PAC_DIVERGE_WARNING');
    FND_MESSAGE.set_token('ITEM', p_inventory_item_number);
    FND_MESSAGE.set_token('COSTGROUP', l_cost_group_name);
    fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET);
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine ||'.others_exc'
                    , 'others:' || SQLCODE || substr(SQLERRM, 1,200)
                    );
    END IF;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Compute_Iterative_Pwac_Cost;

-- +========================================================================+
-- PROCEDURE:  Iteration_Process      PRIVATE UTILITY
-- PARAMETERS:
--   p_init_msg_list          IN  VARCHAR2
--   p_validation_level       IN  NUMBER
--   x_return_status          OUT VARCHAR2(1)
--   x_msg_count              OUT NUMBER
--   x_msg_data               OUT VARCHAR2(2000)
--   p_legal_entity_id        IN  NUMBER
--   p_cost_type_id           IN  NUMBER
--   p_cost_method            IN  NUMBER
--   p_iteration_proc_flag    IN  VARCHAR2(1)
--   p_period_id              IN  NUMBER
--   p_start_date             IN  DATE
--   p_end_date               IN  DATE
--   p_inventory_item_id      IN  NUMBER
--   p_inventory_item_number  IN VARCHAR2
--   p_tolerance              IN  NUMBER
--   p_iteration_num          IN  NUMBER
--   p_run_options            IN  NUMBER
--   p_pac_rates_id           IN  NUMBER  PAC Rate Id for LE and Cost Type
--   p_uom_control            IN  NUMBER  Primary UOM Control Level
--   p_user_id                IN  NUMBER
--   p_login_id               IN  NUMBER
--   p_req_id                 IN  NUMBER
--   p_prg_id                 IN  NUMBER
--   p_prg_appid              IN  NUMBER
-- COMMENT:
--   This procedure is called by the Interorg Transfer Cost Process worker
--   after completing the necessary process in phase 7
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Iteration_Process
(  p_init_msg_list         IN  VARCHAR2
,  p_validation_level      IN  NUMBER
,  p_legal_entity_id       IN  NUMBER
,  p_cost_type_id          IN  NUMBER
,  p_cost_method           IN  NUMBER
,  p_iteration_proc_flag   IN  VARCHAR2
,  p_period_id             IN  NUMBER
,  p_start_date            IN  DATE
,  p_end_date              IN  DATE
,  p_inventory_item_id     IN  NUMBER
,  p_inventory_item_number IN  VARCHAR2
,  p_tolerance             IN  NUMBER
,  p_iteration_num         IN  NUMBER
,  p_run_options           IN  NUMBER
,  p_pac_rates_id          IN  NUMBER
,  p_uom_control           IN  NUMBER
,  p_user_id               IN  NUMBER
,  p_login_id              IN  NUMBER
,  p_req_id                IN  NUMBER
,  p_prg_id                IN  NUMBER
,  p_prg_appid             IN  NUMBER
)
IS
l_routine     CONSTANT  VARCHAR2(30)  := 'iteration_process';

-- Optimal Cost Group according to sequence number
-- Diverging flag for a Cost Group is updated to Y when cost is diverging for the CG.
CURSOR optimal_cost_group_cur(c_item_id       NUMBER
                             ,c_pac_period_id NUMBER
                             )
IS
SELECT
  cost_group_id
, interorg_receipt_flag
, interorg_shipment_flag
, low_level_code
FROM cst_pac_intorg_itms_temp
WHERE inventory_item_id = c_item_id
  AND pac_period_id     = c_pac_period_id
  AND diverging_flag = 'N'
ORDER BY sequence_num;


-- =======================================================
-- BUG 7674673 fix
-- Cursor to obtain PCU value change period balance
-- =======================================================
CURSOR pcu_value_change_balance_cur(c_pac_period_id NUMBER
                                   ,c_cost_group_id NUMBER
				   ,c_inventory_item_id NUMBER
				   )
IS
  SELECT NVL(cppb1.period_balance,0) - NVL(cppb2.period_balance,0) pcu_value_balance
        ,cppb1.cost_group_id cost_group_id
        ,cppb1.cost_element_id cost_element_id
        ,cppb1.level_type level_type
   FROM cst_pac_period_balances cppb1
       ,cst_pac_period_balances cppb2
   where cppb1.pac_period_id = cppb2.pac_period_id
     and cppb1.cost_group_id = cppb2.cost_group_id
     and cppb1.inventory_item_id = cppb2.inventory_item_id
     and cppb1.cost_element_id = cppb2.cost_element_id
     and cppb1.level_type = cppb2.level_type
     and cppb1.txn_category = 8.5
     and cppb2.txn_category = 8
     and cppb1.pac_period_id     = c_pac_period_id
     AND cppb1.cost_group_id     = c_cost_group_id
     AND cppb1.inventory_item_id = c_inventory_item_id;


-- ==================================================
-- BUG 7674673 fix
-- To check existence of atleast one PCU value change
-- txn for an interorg item
-- ==================================================
CURSOR pcu_value_change_check(c_pac_period_id NUMBER
                             ,c_cost_group_id NUMBER
			     ,c_inventory_item_id NUMBER
			     )
IS
  SELECT count(*)
    FROM CST_PAC_PERIOD_BALANCES
   WHERE pac_period_id = c_pac_period_id
     AND cost_group_id = c_cost_group_id
     AND inventory_item_id = c_inventory_item_id
     AND txn_category = 8.5;


-- ================================
-- Local variables
-- ===============================
  l_inventory_item_id  NUMBER;
  l_tolerance_flag     VARCHAR2(1);
  l_iteration_num      NUMBER;
  t_low_level_code  NUMBER;

-- Iteration Num range variables
  l_prev_iteration_count  NUMBER;
  l_start_iteration_num   NUMBER;
  l_end_iteration_num     NUMBER;
  l_iteration_num_idx     BINARY_INTEGER;
  l_master_org_id      NUMBER;

-- Bug 7674673 fix
l_pcu_value_change_count NUMBER := 0;
l_cg_elmt_lv_idx  BINARY_INTEGER;
l_first_time_flag VARCHAR2(1);


BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.begin'
                  , l_routine || '<'
                  );
  END IF;

  FND_MSG_PUB.initialize;

  -- =======================
  -- API body
  -- =======================

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  , G_MODULE_HEAD || l_routine || '.before_set_process'
                  , 'Before Set Process Status'
                  );
  END IF;

    -- Set process status to 2 - Running for all the valid cost groups
    -- in Legal Entity
    Set_Process_Status( p_legal_entity_id  => p_legal_entity_id
                      , p_period_id        => p_period_id
                      , p_period_end_date  => p_end_date
                      , p_phase_status     => 2
                      );
    -- Set Phase 5 status to 2 - Running for all the CGs to display
    -- the Phase 7 status on the screen
    Set_Phase5_Status( p_legal_entity_id  => p_legal_entity_id
                     , p_period_id        => p_period_id
                     , p_period_end_date  => p_end_date
                     , p_phase_status     => 2
                     );

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT
                      , G_MODULE_HEAD || l_routine || '.Before_iteration_loop'
                      , 'Before Iteration Loop'
                      );
      END IF;

    -- =========================================
    -- Assign interorg item to a local variable
    -- =========================================
    l_inventory_item_id := p_inventory_item_id;


    -- ==================================================================
    -- Get Previous Iteration Count
    -- initialize the starting iteration number for the current iteration
    -- process
    -- for the first iteration process, the starting iteration number
    -- will be initialize to 1 and the previous iteration count to 0
    -- previous iteration count will be -99 if no interorg items found
    -- Previous iteration count of the current bom level interorg item
    -- ==================================================================
    l_prev_iteration_count :=
      Get_Previous_Iteration_Count(p_period_id          => p_period_id
                                  ,p_inventory_item_id  => l_inventory_item_id
                                  );

-- ==================================================
-- Perform interation only when Interorg items found
-- ==================================================
IF l_prev_iteration_count <> -99 THEN
  l_start_iteration_num  := l_prev_iteration_count + 1;

  IF p_iteration_proc_flag = 'Y' THEN
    l_end_iteration_num    := l_prev_iteration_count + p_iteration_num;
  ELSE
    l_end_iteration_num    := l_prev_iteration_count + 1;
  END IF;


  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  ,G_MODULE_HEAD || l_routine || '.iteration_num_range'
                  ,'Starting Iteration Number:'|| l_start_iteration_num
                  || ' Ending Iteration Number:' || l_end_iteration_num
                  );
  END IF;

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    ,G_MODULE_HEAD || l_routine || '.Item'
                    ,'Inventory Item Id:'|| p_inventory_item_id
                    );
  END IF;

  -- ==================================================
  -- bug 7674673 fix PCU value change balance retrieval
  -- to pl/sql table G_PCU_VALUE_CHANGE_TBL
  -- only first time in the consecutive iterations
  -- Therefore, l_first_time_flag is set to Y
  -- ==================================================
  l_first_time_flag := 'Y';

  -- ========================================================================
  -- Perform Item Iteration LOOP
  -- Item --> Iteration --> Optimal Seq cost Group --> interorg Transactions
  -- Item --> Iteration --> Invoke Compute_iterative_pwac_cost
  -- ========================================================================

  FOR l_iteration_num_idx IN l_start_iteration_num .. l_end_iteration_num LOOP

    -- Assign iteration number
    l_iteration_num := l_iteration_num_idx;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    ,G_MODULE_HEAD || l_routine || '.iteration'
                    ,'ITERATION NUMBER:'|| l_iteration_num
                    );
    END IF;

    -- Loop for each optimal cost group
    FOR l_optimal_cg_idx IN optimal_cost_group_cur(l_inventory_item_id
                                                  ,p_period_id
                                                   ) LOOP
        -- ============================================================
	-- check for no completion item in that cost group
	-- set the low level code variable to -1 for no completion item
	-- ============================================================
	IF l_optimal_cg_idx.low_level_code = 1000 THEN
	    t_low_level_code := -1;
	ELSE
	    t_low_level_code := l_optimal_cg_idx.low_level_code;
	END IF;

	IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.string(FND_LOG.LEVEL_EVENT
                 ,G_MODULE_HEAD || l_routine || '.tlevel'
                  ,'Completion or no completion level:' || t_low_level_code
                  );
	END IF;

	l_master_org_id          :=    Get_master_org(l_optimal_cg_idx.cost_group_id);

      IF l_iteration_num_idx = 1 THEN
         IF l_optimal_cg_idx.interorg_receipt_flag = 'Y' THEN

	      Group1_Interorg_Iteration1( p_legal_entity_id          =>   p_legal_entity_id
			  	        , p_master_org_id            =>   l_master_org_id
				        , p_cost_type_id             =>   p_cost_type_id
					, p_cost_method              =>   p_cost_method
					, p_cost_group_id            =>   l_optimal_cg_idx.cost_group_id
				        , p_inventory_item_id        =>   l_inventory_item_id
                                        , p_low_level_code           =>   t_low_level_code
					, p_period_id                =>   p_period_id
					, p_pac_rates_id             =>   p_pac_rates_id
					, p_uom_control              =>   p_uom_control
					, p_end_iteration_num        =>   l_end_iteration_num
					, p_iteration_proc_flag      =>   p_iteration_proc_flag
					);

	 END IF;


         IF l_optimal_cg_idx.interorg_receipt_flag = 'Y' OR l_optimal_cg_idx.interorg_shipment_flag = 'Y' THEN

	      -- Process Periodic Cost Update Value Change only for interorg item
	      -- both completion and no completion items are included
              CST_PERIODIC_ABSORPTION_PROC.Periodic_Cost_Update_By_Level
                (p_period_id             => p_period_id
                ,p_legal_entity          => p_legal_entity_id
                ,p_cost_type_id          => p_cost_type_id
                ,p_cost_group_id         => l_optimal_cg_idx.cost_group_id
                ,p_inventory_item_id     => l_inventory_item_id
                ,p_cost_method           => p_cost_method
                ,p_start_date            => p_start_date
                ,p_end_date              => p_end_date
                ,p_pac_rates_id          => p_pac_rates_id
                ,p_master_org_id         => l_master_org_id
                ,p_uom_control           => p_uom_control
                ,p_low_level_code        => t_low_level_code
		,p_txn_category          => 8.5
                ,p_user_id               => p_user_id
                ,p_login_id              => p_login_id
                ,p_req_id                => p_req_id
                ,p_prg_id                => p_prg_id
                ,p_prg_appid             => p_prg_appid);


		-- Bug 7674673 fix
                -- Set PWAC Item Cost in interorg items temp table
		-- after PCU value change
                UPDATE CST_PAC_INTORG_ITMS_TEMP
                   SET item_cost = (SELECT nvl(item_cost,0)
                                      FROM cst_pac_item_costs cpic
                                     WHERE cpic.pac_period_id     = p_period_id
                                       AND cpic.cost_group_id     = l_optimal_cg_idx.cost_group_id
                                       AND cpic.inventory_item_id = l_inventory_item_id)
                 WHERE pac_period_id  = p_period_id
                   AND cost_group_id  = l_optimal_cg_idx.cost_group_id
                   AND inventory_item_id = l_inventory_item_id;


	 END IF; -- PCU value change only for interorg item


	 IF l_optimal_cg_idx.interorg_shipment_flag = 'Y' THEN
 	      Group2_Interorg_Iteration1( p_legal_entity_id          =>   p_legal_entity_id
			  	        , p_master_org_id            =>   l_master_org_id
					, p_cost_type_id             =>   p_cost_type_id
					, p_cost_method              =>   p_cost_method
					, p_cost_group_id            =>   l_optimal_cg_idx.cost_group_id
					, p_inventory_item_id        =>   l_inventory_item_id
					, p_low_level_code           =>   t_low_level_code
					, p_period_id                =>   p_period_id
					, p_pac_rates_id             =>   p_pac_rates_id
					, p_uom_control              =>   p_uom_control
					, p_end_iteration_num        =>   l_end_iteration_num
					, p_iteration_proc_flag      =>   p_iteration_proc_flag
					);
	 END IF;

      ELSIF l_optimal_cg_idx.interorg_receipt_flag = 'Y' THEN

	   -- ======================================================
	   -- Consecutive iteration logic
	   -- Need to retrieve PCU value change balance first time
	   -- in the first consecutive iteration.  Not necessary to
	   -- retrieve PCU value change balance for every iteration
           IF l_first_time_flag = 'Y' THEN
              -- ===========================================================
	      -- BUG 7674673 fix
	      -- Check for the existence of atleast one PCU value change txn
	      -- If exists, store PCU value change balance in pl/sql table
	      -- ===========================================================
	      l_pcu_value_change_count := 0;

	      OPEN pcu_value_change_check(p_period_id
                                         ,l_optimal_cg_idx.cost_group_id
			                 ,l_inventory_item_id
			                 );

	      FETCH pcu_value_change_check
	       INTO l_pcu_value_change_count;

	      CLOSE pcu_value_change_check;


              IF l_pcu_value_change_count > 0 THEN
                -- PCU value change txn exists

                -- populate PCU value balance into pl/sql table
		FOR pcu_idx IN pcu_value_change_balance_cur(p_period_id
		                                           ,l_optimal_cg_idx.cost_group_id
			                                   ,l_inventory_item_id
			                                   ) LOOP

		   l_cg_elmt_lv_idx := to_char(pcu_idx.cost_group_id) ||
                                       to_char(pcu_idx.cost_element_id) || to_char(pcu_idx.level_type);

                   G_PCU_VALUE_CHANGE_TBL(l_cg_elmt_lv_idx).pcu_value_balance := pcu_idx.pcu_value_balance;
                   G_PCU_VALUE_CHANGE_TBL(l_cg_elmt_lv_idx).cost_group_id := pcu_idx.cost_group_id;
                   G_PCU_VALUE_CHANGE_TBL(l_cg_elmt_lv_idx).cost_element_id := pcu_idx.cost_element_id;
                   G_PCU_VALUE_CHANGE_TBL(l_cg_elmt_lv_idx).level_type := pcu_idx.level_type;

                   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                                   , G_MODULE_HEAD || l_routine ||'.cgellvic'
                                   , 'PCU Value Change :Cost Group element level idx:' || l_cg_elmt_lv_idx ||
			           'Balance:' || G_PCU_VALUE_CHANGE_TBL(l_cg_elmt_lv_idx).pcu_value_balance
                                   );
                   END IF;

	        END LOOP; -- pcu value change


              END IF; -- pcu value change existence check

	   END IF; -- first time check across cost groups


	      -- Perform PWAC Calculation
	      Compute_Iterative_Pwac_Cost(p_legal_entity_id          =>   p_legal_entity_id
		                         ,p_cost_type_id             =>   p_cost_type_id
			                 ,p_cost_method              =>   p_cost_method
 					 ,p_cost_group_id            =>   l_optimal_cg_idx.cost_group_id
				         ,p_inventory_item_id        =>   l_inventory_item_id
					 ,p_inventory_item_number    =>   p_inventory_item_number
					 ,p_low_level_code           =>   t_low_level_code
					 ,p_period_id                =>   p_period_id
	                                 ,p_period_start_date        =>   p_start_date
		                         ,p_period_end_date          =>   p_end_date
			                 ,p_iteration_num            =>   l_iteration_num
				         ,p_end_iteration_num        =>   l_end_iteration_num
					 ,p_pac_rates_id             =>   p_pac_rates_id
	                                 ,p_uom_control              =>   p_uom_control
		                         ,p_iteration_proc_flag      =>   p_iteration_proc_flag
			                 );
      END IF;

    END LOOP; -- end of optimal cost group

    IF l_iteration_num > 1 THEN
      -- consecutive iteration
      -- PCU value change balance retrieved
      -- first time, so no need to retrieve
      -- for further iterations
      -- set l_first_time_flag to N
      l_first_time_flag := 'N';
    END IF;

    -- ===================================================================
    -- Delete MPACD for the corresponding inserted pac transactions in
    -- mtl_pac_act_cst_dtl_temp of an interorg item
    -- Only if the iteration process flag is enabled and consecutive
    -- iterations exist
    -- ===================================================================
    IF l_iteration_num = 1 AND p_iteration_proc_flag = 'Y' THEN

        DELETE FROM mtl_pac_actual_cost_details mpacd
        WHERE mpacd.pac_period_id  = p_period_id
	AND EXISTS (select 'X'
                    from cst_pac_intorg_itms_temp
     		    where cost_group_id = mpacd.cost_group_id
		      and inventory_item_id = l_inventory_item_id
		      and pac_period_id = p_period_id
     		      and interorg_receipt_flag = 'Y')
	AND transaction_id IN (
			      SELECT transaction_id
				FROM  mtl_pac_act_cst_dtl_temp
			      WHERE pac_period_id     = p_period_id
			        AND inventory_item_id = l_inventory_item_id);


        -- ==================================================================
        -- R12 Enhancements: Iteration as an optional process
        -- balance pac txns only if the iteration process is enabled
        -- ====================================================================
        -- Balance pac transactions
        -- This is to determine whether the corresponding pac transaction rows
        -- exists for the cost element, level type
        -- Group 1 (cost owned) pac transactions:
        -- If the corresponding group 2 (cost dervied) transaction exists
        --   If it exists and cost element = 2 material overhead
        --     get material overhead absorption cost, transfer cost and
        --     transportation cost if any for this group 1 transaction
        --     Deduct these costs from actual cost
        --     Left over actual cost is used for comparision
        --     Deducted costs will be added back at the end of iterations
        --   If it exists and cost element is other than 2
        --     Retain the pac txn as it is
        --   If it does not exist in group 2 and cost element = 2,
        --     DO NOT USE this cost owned receipt for comparision
        --     Do NOT delete this record as this record will be put back
        --     into MPACD at the end of iteration process
        --   If it does not exist in group 2 and cost element <> 2,
        --     Delete this record from cost owned group 1 as it is not
        --     required
        -- Group 2 (cost derived) pac transactions:
        -- If the corresponding group 1 (cost owned transaction exists)
        --   If it exists retain as it
        --   If it does not exist, create the corresponding group1 pac txn
        --   only for direct interorg transaction otherwise retain as it is
        --   and DO NOT USE this intransit txn for the comparison
        -- ====================================================================
        Balance_Pac_Txn
        ( p_period_id           => p_period_id
        , p_inventory_item_id   => l_inventory_item_id
        , p_cost_type_id        => p_cost_type_id
        );


    END IF; -- first iteration, process flag enabled with consecutive iterations


    IF p_iteration_proc_flag = 'Y' THEN
        -- =====================================================================
        -- Verify tolerance of inventory item
        -- Check the tolerance for each cost group.  Compare PMAC item cost of
        -- last iteration with the previous iteration
        -- If the tolerance achieved for all the cost groups, then set the
        -- tolerance flag to 'Y'.  Otherwise, tolerance flag set to 'N'
        -- Display interorg receipts, cost element, level type and the
        -- corresponding interorg shipments only for the last iteration or when
        -- the tolerance is achieved
        -- NOTE: Tolerance verification is performed only from 2nd iteration
        -- onwards
        -- =====================================================================
       IF l_iteration_num > 1 THEN
         Verify_Tolerance_Of_Item
		  (p_cost_type_id          => p_cost_type_id
	          ,p_inventory_item_id     => l_inventory_item_id
	          ,p_inventory_item_number => p_inventory_item_number
	          ,p_period_id             => p_period_id
		  ,p_period_start_date     => p_start_date
	          ,p_period_end_date       => p_end_date
	          ,p_tolerance             => p_tolerance
		  ,p_iteration_num         => l_iteration_num
	          ,p_end_iteration_num     => l_end_iteration_num
	          ,x_tolerance_flag        => l_tolerance_flag
		  );
        ELSE
          l_tolerance_flag := 'N';
        END IF;

          -- =====================================================================
          -- Set Tolerance Flag in interorg temp table
          -- Update Tolerance Flag set to 'Y' only for the tolerance achieved items
          -- Run Option 1 - Start; 2 - Resume from error; 3 - Resume for non-
          -- tolerance; 4 - Final
          -- =====================================================================
          IF l_tolerance_flag = 'Y' THEN

            UPDATE CST_PAC_INTORG_ITMS_TEMP
               SET tolerance_flag  = l_tolerance_flag
                  ,iteration_count = l_iteration_num
             WHERE inventory_item_id   = l_inventory_item_id
               AND pac_period_id       = p_period_id
	       AND diverging_flag  <> 'Y';


              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE_HEAD || l_routine || '.upd_tolerance_flag'
                              , 'Tolerance Flag:' || l_tolerance_flag || ' ' ||
                                'Inventory Item Id:' || l_inventory_item_id
                              );
              END IF;

            IF l_iteration_num > 1 THEN
              -- Insert new values into Oracle Costing PAC transaction table only when the
              -- tolerance is achieved for the current BOM level interorg item
              -- Insert new values into MPACD from pac transaction temp table
                Create_Mpacd_With_New_Values(p_period_id
                                          ,l_inventory_item_id
                                          );
                Update_Cpicd_With_New_Values(p_pac_period_id      =>  p_period_id
                                            ,p_inventory_item_id  =>  l_inventory_item_id
					    ,p_cost_type_id       =>  p_cost_type_id
					    ,p_end_date           =>  p_end_date
                                            );
            END IF;

            -- no more iterations for this item as tolerance achieved
            EXIT;

          END IF; -- tolerance flag check

    END IF; -- iteration process flag

    END LOOP; -- iteration end loop

    IF p_iteration_proc_flag = 'Y' THEN

      -- Run Option: 4 Final
      IF p_run_options = 4 THEN

       -- if tolerance is achieved in the final run, then the following steps would have been completed
       -- before exiting the above loop.

        IF l_tolerance_flag <> 'Y' THEN

	 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.string(FND_LOG.LEVEL_EVENT
                        , G_MODULE_HEAD || l_routine || '.upd_final_iteration'
                        , 'Final Iteration for the item:' || l_inventory_item_id
                        );
	 END IF;

         -- Update tolerance flag and final iteration number for this item
         -- Set flag to 'F' - Finalized
         UPDATE CST_PAC_INTORG_ITMS_TEMP
           SET tolerance_flag  = 'F'
              ,iteration_count = l_end_iteration_num
          WHERE pac_period_id       = p_period_id
           AND inventory_item_id   = l_inventory_item_id
           AND tolerance_flag      = 'N';

         -- Insert new values into Oracle Costing PAC transaction table only when the
         -- tolerance is achieved for the current BOM level interorg item
         -- Insert new values into MPACD from pac transaction temp table
          Create_Mpacd_With_New_Values(p_period_id
                                      ,l_inventory_item_id
                                      );

          Update_Cpicd_With_New_Values(p_pac_period_id      =>  p_period_id
                                      ,p_inventory_item_id  =>  l_inventory_item_id
	  			      ,p_cost_type_id       =>  p_cost_type_id
				      ,p_end_date           =>  p_end_date
                                      );
        END IF;

      ELSE
        -- Run Options: 1 - Start, 2 - Resume from error, 3 - Resume for
        -- non tolerance
          -- ===========================================================
          -- Update iteration count for the interorg item
          -- it is required to store the iteration count which
          -- is mainly used in the next iteration process
          -- ===========================================================
          UPDATE CST_PAC_INTORG_ITMS_TEMP
             SET iteration_count     = l_end_iteration_num
           WHERE pac_period_id       = p_period_id
             AND tolerance_flag      = 'N'
             AND inventory_item_id   = l_inventory_item_id
	     AND diverging_flag <> 'Y';

      END IF; -- run option check


        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT
                        , G_MODULE_HEAD || l_routine || '.After_iteration_loop'
                        , 'After Iteration Loop'
                        );
        END IF;

    END IF; -- iteration process check

-- Delete G_CG_PWAC_COST_TBL after iteration process for an interorg item
  G_CG_PWAC_COST_TBL.delete;

-- Delete G_PCU_VALUE_CHANGE_TBL at the end of iteration process for an interorg item
G_PCU_VALUE_CHANGE_TBL.delete;

END IF; -- interorg items found check

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_HEAD || l_routine ||'.end'
                  , l_routine || '>'
                  );
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END Iteration_Process;

END CST_PAC_ITERATION_PROCESS_PVT;

/
