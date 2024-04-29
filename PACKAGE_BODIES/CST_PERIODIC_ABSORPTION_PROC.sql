--------------------------------------------------------
--  DDL for Package Body CST_PERIODIC_ABSORPTION_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERIODIC_ABSORPTION_PROC" AS
-- $Header: CSTRITPB.pls 120.52.12010000.8 2009/07/17 21:08:08 vjavli ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTRITPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Periodic Absorption Cost Processor  Concurrent Program             |
--|                                                                       |
--| 10/30/2008 vjavli FP 12.1.1 7342514 fix: Periodic_Cost_Update_By_Level|
--|                   for PCU - value change will be invoked after        |
--|                   processing all the cost owned transactions,just     |
--|                   before processing cost derived transactions         |
--|                   Procedure Periodic_Cost_Update_By_Level is          |
--|                   is invoked for PCU value change for non interorg    |
--|                   items which include for both completion and no      |
--|                   completion items                                    |
--|                   Iteration_Process signature changed with who columns|
--| 04/26/2008 vjavli FP Bug 7674673 fix:When interorg_item_flag is 1     |
--|                  atleast one of the cost group has valid interorg txn |
--|                  which will get processed in iteration_process proc.  |
--|                  It is possible that remaining cost groups for which  |
--|                  no interorg txns exists may have to be processed with|
--|                  PCU - value change txns,if any even though interorg_ |
--|                  item_flag is 1 across the cost groups in pac period  |
--|                  This means, remaining cost groups with no interorg   |
--|                  txns have to be considered to process PCU Value Chng |
--|                  Function Check_For_No_Interorg_CG to validate for non|
--|                  interorg cost group                                  |
--+=======================================================================+

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'CST_PERIODIC_ABSORPTION_PROC';
g_org_id               NUMBER     := FND_PROFILE.value('ORG_ID');
-- to store the item and its BOM highest level across cost groups
TYPE item_level_rec_type IS RECORD
( inventory_item_id  NUMBER
);

TYPE g_item_level_table_type IS TABLE OF item_level_rec_type
INDEX BY BINARY_INTEGER;
G_ITEM_LEVEL_TBL  g_item_level_table_type;

TYPE PAC_REQUEST_REC IS RECORD
( pac_period_id   NUMBER,
  cost_group_id   NUMBER,
  request_id      NUMBER,
  request_status  VARCHAR2(1),
  phase_status   NUMBER
);


TYPE PAC_REQUEST_TABLE IS TABLE OF PAC_REQUEST_REC
     INDEX BY BINARY_INTEGER;

G_REQUEST_TABLE   PAC_REQUEST_TABLE;

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_HEAD CONSTANT  VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';
G_TOL_ACHIEVED_FORALL_CG NUMBER := 0;
--===========================================================
-- PUBLIC FUNCTIONS
--===========================================================

--========================================================================
-- PROCEDURE : Get Exp Flag                PRIVATE
-- COMMENT   : get exp flag for items considered to be an asset
--=========================================================================
PROCEDURE get_exp_flag
(p_item_id                 IN NUMBER
,p_org_id                  IN NUMBER
,p_subinventory_code       IN VARCHAR2
,x_exp_flag                OUT NOCOPY NUMBER
,x_exp_item                OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'get_exp_flag';
--=================
-- VARIABLES
--=================

l_exp_flag             NUMBER;
l_exp_item             NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  IF G_EXPENSE_ITEM_CACHE.EXISTS(p_org_id) AND G_EXPENSE_ITEM_CACHE(p_org_id).EXISTS(p_item_id) THEN
          l_exp_item := G_EXPENSE_ITEM_CACHE(p_org_id)(p_item_id);
  ELSE

	  SELECT DECODE(inventory_asset_flag,'Y',0,1)
	  INTO l_exp_item
	  FROM mtl_system_items
	  WHERE inventory_item_id = p_item_id
	  AND organization_id = p_org_id;

	  G_EXPENSE_ITEM_CACHE(p_org_id)(p_item_id) := l_exp_item;
  END IF;

  IF p_subinventory_code IS NULL THEN

    l_exp_flag := l_exp_item;

  ELSE

    IF G_EXPENSE_FLAG_CACHE.EXISTS(p_org_id) AND G_EXPENSE_FLAG_CACHE(p_org_id).EXISTS(p_subinventory_code) THEN
          l_exp_flag := G_EXPENSE_FLAG_CACHE(p_org_id)(p_subinventory_code);
    ELSE
	  SELECT DECODE(l_exp_item,1,1,DECODE(asset_inventory,1,0,1))
	  INTO l_exp_flag
	  FROM mtl_secondary_inventories
	  WHERE secondary_inventory_name = p_subinventory_code
	  AND organization_id = p_org_id;

          G_EXPENSE_FLAG_CACHE(p_org_id)(p_subinventory_code) := l_exp_flag;
    END IF;
  END IF;
  g_loop_flag := 0;
  x_exp_item := l_exp_item;
  x_exp_flag := l_exp_flag;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
WHEN OTHERS THEN  /* to catch overflow exception */
    IF g_loop_flag = 0 THEN
        g_loop_flag := 1;
        G_EXPENSE_FLAG_CACHE.DELETE;
	G_EXPENSE_ITEM_CACHE.DELETE;
        get_exp_flag(p_item_id		      => p_item_id
		    ,p_org_id		      => p_org_id
		    ,p_subinventory_code      => p_subinventory_code
		    ,x_exp_flag               => l_exp_flag
		    ,x_exp_item               => l_exp_item
		    );
       x_exp_flag := l_exp_flag;
       x_exp_item := l_exp_item;
    ELSE
	    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
    END IF;
END get_exp_flag;

-- +========================================================================+
-- FUNCTION: Get_Item_Number    Local Utility
-- PARAMETERS:
--   p_inventory_item_id   Inventory Item Id
-- COMMENT:
--   This is to get the Inventory Item Number
-- USAGE: This function is used in Absorption_Cost_Process
-- PRE-COND: none
-- EXCEPTIONS: none
-- +========================================================================+
FUNCTION Get_Item_Number
( p_inventory_item_id  IN  NUMBER
)
RETURN VARCHAR2
IS
-- Cursor to get the inventory item number
CURSOR item_cur(c_inventory_item_id  NUMBER)
IS
SELECT
  concatenated_segments
FROM
  MTL_SYSTEM_ITEMS_B_KFV
WHERE inventory_item_id = c_inventory_item_id
  AND rownum = 1;

l_inventory_item_number  VARCHAR2(1025);

BEGIN
  OPEN item_cur(p_inventory_item_id);
  FETCH item_cur
   INTO l_inventory_item_number;

  CLOSE item_cur;

  RETURN l_inventory_item_number;

END; -- Get_Item_Number

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Get Phase Status    PRIVATE
-- COMMENT   : Get the status of a specific phase
--========================================================================
PROCEDURE get_phase_status
( p_pac_period_id       IN         NUMBER
, p_phase               IN         NUMBER
, p_cost_group_id       IN         NUMBER
, x_status              OUT NOCOPY NUMBER
)
IS

l_routine  CONSTANT  VARCHAR2(30) := 'get_phase_status';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  IF p_phase = 7 THEN
	 SELECT
	    process_status
	  INTO x_status
	  FROM
	    cst_pac_process_phases
	  WHERE pac_period_id = p_pac_period_id
	    AND process_phase = p_phase
	    AND rownum = 1;
  ELSE
	SELECT
	    process_status
    	  INTO x_status
	  FROM
	    cst_pac_process_phases
	  WHERE pac_period_id = p_pac_period_id
	    AND process_phase = p_phase
	    AND cost_group_id = p_cost_group_id;
  END IF;

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
END get_phase_status;

-- =========================================================================
-- FUNCTION  Find_Prev_Process_Upto_Date                      PRIVATE
-- PARAMETERS: p_pac_period_id IN  NUMBER
-- RETURN x_process_upto_date  OUT NOCOPY DATE
-- This function retrieves Process Upto Date used in first iteration
-- Note that process upto date is stored in CST_PAC_PROCESS_PHASES.
-- This function is invoked only during consecutive iterations
-- =========================================================================
FUNCTION Find_Prev_Process_Upto_Date
(p_pac_period_id  IN NUMBER)
RETURN DATE
IS
l_routine CONSTANT VARCHAR2(30) := 'Find_Prev_Process_Upto_Date';

-- Cursor to obtain process upto date for a given pac period
-- NOTE: process upto date is same for all valid cost groups in the
--       legal entity for Phase 7
CURSOR process_upto_date_cur(c_pac_period_id  NUMBER)
IS
SELECT
  TO_CHAR(process_upto_date, 'YYYY/MM/DD HH24:MI:SS')
FROM
  cst_pac_process_phases
WHERE pac_period_id = c_pac_period_id
  AND process_phase = 7;

-- variables for process upto date
l_process_upto_date  VARCHAR2(30);
x_process_upto_date  DATE;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;


  OPEN process_upto_date_cur(p_pac_period_id);
  FETCH process_upto_date_cur
   INTO l_process_upto_date;

  CLOSE process_upto_date_cur;

  x_process_upto_date :=
    TRUNC(FND_DATE.canonical_to_date(l_process_upto_date)) + (86399/86400);

  RETURN x_process_upto_date;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END Find_Prev_Process_Upto_Date;

--========================================================================
-- PROCEDURE : Process cost own completion item         PRIVATE
-- COMMENT   : Run the cost processor for non rework assembly jobs
--=========================================================================
PROCEDURE Process_Non_Rework_Comps
( p_period_id             IN NUMBER
, p_start_date            IN DATE
, p_end_date              IN DATE
, p_prev_period_id        IN NUMBER
, p_cost_group_id         IN NUMBER
, p_inventory_item_id     IN NUMBER
, p_cost_type_id          IN NUMBER
, p_legal_entity          IN NUMBER
, p_cost_method           IN NUMBER
, p_pac_rates_id          IN NUMBER
, p_master_org_id         IN NUMBER
, p_mat_relief_algorithm  IN NUMBER
, p_uom_control           IN NUMBER
, p_low_level_code        IN NUMBER
, p_user_id               IN NUMBER
, p_login_id              IN NUMBER
, p_req_id                IN NUMBER
, p_prg_id                IN NUMBER
, p_prg_appid             IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'process_non_rework_comps';

--=================
-- VARIABLES
--=================

l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);

BEGIN


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;


      CSTPPWAS.process_nonreworkassembly_txns
       (p_pac_period_id             => p_period_id
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_prior_period_id           => p_prev_period_id
       ,p_item_id                   => p_inventory_item_id
       ,p_cost_group_id             => p_cost_group_id
       ,p_cost_type_id              => p_cost_type_id
       ,p_legal_entity              => p_legal_entity
       ,p_cost_method               => p_cost_method
       ,p_pac_rates_id              => p_pac_rates_id
       ,p_master_org_id             => p_master_org_id
       ,p_material_relief_algorithm => p_mat_relief_algorithm
       ,p_uom_control               => p_uom_control
       ,p_low_level_code            => p_low_level_code
       ,p_user_id                   => p_user_id
       ,p_login_id                  => p_login_id
       ,p_request_id                => p_req_id
       ,p_prog_id                   => p_prg_id
       ,p_prog_app_id               => p_prg_appid
       ,x_err_num                   => l_error_num
       ,x_err_code                  => l_error_code
       ,x_err_msg                   => l_error_msg);

      l_error_num  := NVL(l_error_num, 0);
      l_error_code := NVL(l_error_code, 'No Error');
      l_error_msg  := NVL(l_error_msg, 'No Error');

      IF l_error_num <> 0
      THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine || '.others'
                    , 'process_nonreworkassembly_txns for cost group '||p_cost_group_id||' item id '
	                                 ||p_inventory_item_id||' ('||l_error_code||') '||l_error_msg
                    );
	END IF;

	FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'process_nonreworkassembly_txns for cost group '||p_cost_group_id||' item id '
	                                 ||p_inventory_item_id||' ('||l_error_code||') '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;


END Process_Non_Rework_Comps;


--=================================================================================
-- PROCEDURE : Process cost own completion item         PRIVATE
-- COMMENT   : Run the cost processor for rework assembly issue and completion jobs
--=================================================================================
PROCEDURE Process_Rework_Issue_Comps
( p_period_id             IN NUMBER
, p_start_date            IN DATE
, p_end_date              IN DATE
, p_prev_period_id        IN NUMBER
, p_cost_group_id         IN NUMBER
, p_inventory_item_id     IN NUMBER
, p_cost_type_id          IN NUMBER
, p_legal_entity          IN NUMBER
, p_cost_method           IN NUMBER
, p_pac_rates_id          IN NUMBER
, p_master_org_id         IN NUMBER
, p_mat_relief_algorithm  IN NUMBER
, p_uom_control           IN NUMBER
, p_low_level_code        IN NUMBER
, p_user_id               IN NUMBER
, p_login_id              IN NUMBER
, p_req_id                IN NUMBER
, p_prg_id                IN NUMBER
, p_prg_appid             IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'process_rework_issue_comps';

--=================
-- VARIABLES
--=================

l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);

BEGIN


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;


      CSTPPWAS.process_reworkassembly_txns
       (p_pac_period_id             => p_period_id
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_prior_period_id           => p_prev_period_id
       ,p_item_id                   => p_inventory_item_id
       ,p_cost_group_id             => p_cost_group_id
       ,p_cost_type_id              => p_cost_type_id
       ,p_legal_entity              => p_legal_entity
       ,p_cost_method               => p_cost_method
       ,p_pac_rates_id              => p_pac_rates_id
       ,p_master_org_id             => p_master_org_id
       ,p_material_relief_algorithm => p_mat_relief_algorithm
       ,p_uom_control               => p_uom_control
       ,p_low_level_code            => p_low_level_code
       ,p_user_id                   => p_user_id
       ,p_login_id                  => p_login_id
       ,p_request_id                => p_req_id
       ,p_prog_id                   => p_prg_id
       ,p_prog_app_id               => p_prg_appid
       ,x_err_num                   => l_error_num
       ,x_err_code                  => l_error_code
       ,x_err_msg                   => l_error_msg);

      l_error_num  := NVL(l_error_num, 0);
      l_error_code := NVL(l_error_code, 'No Error');
      l_error_msg  := NVL(l_error_msg, 'No Error');

      IF l_error_num <> 0
      THEN
       	FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'CSTPPWAS.process_reworkassembly_txns for cost group '||p_cost_group_id||' item id '
	                                 ||p_inventory_item_id||' ('||l_error_code||') '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;


END Process_Rework_Issue_Comps;

--========================================================================
-- PROCEDURE : Periodic Cost Update by level   PRIVATE
-- COMMENT   : Run the cost processor for modes
--           : periodic cost update (value change)
--=========================================================================
PROCEDURE Periodic_Cost_Update_By_Level
( p_period_id               IN NUMBER
, p_legal_entity            IN NUMBER
, p_cost_type_id            IN NUMBER
, p_cost_group_id           IN NUMBER
, p_inventory_item_id       IN NUMBER
, p_cost_method             IN NUMBER
, p_start_date              IN DATE
, p_end_date                IN DATE
, p_pac_rates_id            IN NUMBER
, p_master_org_id           IN NUMBER
, p_uom_control             IN NUMBER
, p_low_level_code          IN NUMBER
, p_txn_category            IN NUMBER
, p_user_id                 IN NUMBER
, p_login_id                IN NUMBER
, p_req_id                  IN NUMBER
, p_prg_id                  IN NUMBER
, p_prg_appid               IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'periodic_cost_update_by_level';

--===============================================================
-- Cursor for Periodic Cost Update for items in the current level
--===============================================================
CURSOR upd_val_csr_type_level
( c_start_date         DATE
, c_end_date           DATE
, c_cost_group_id      NUMBER
, c_cost_type_id       NUMBER
, c_inventory_item_id  NUMBER
)
IS
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1)	transfer_organization_id
, mmt.subinventory_code
FROM mtl_material_transactions mmt
WHERE mmt.transaction_date BETWEEN c_start_date AND c_end_date
  AND mmt.transaction_action_id = 24
  AND mmt.transaction_source_type_id = 14
  AND value_change IS NOT NULL
  AND mmt.primary_quantity = 0
  AND NVL(org_cost_group_id,-1) = c_cost_group_id
  AND NVL(cost_type_id,-1) = c_cost_type_id
  AND mmt.inventory_item_id = c_inventory_item_id;

TYPE upd_val_txn_tab IS TABLE OF upd_val_csr_type_level%rowtype INDEX BY BINARY_INTEGER;
l_upd_val_txn_tab	upd_val_txn_tab;
l_empty_txn_tab		upd_val_txn_tab;
--=================
-- VARIABLES
--=================

l_current_index    BINARY_INTEGER := 0;
l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);
l_process_group    NUMBER := 0;
l_count            NUMBER;
l_exp_flag         NUMBER;
l_exp_item         NUMBER;

-- Transaction Category
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;


    IF NOT upd_val_csr_type_level%ISOPEN THEN
      OPEN upd_val_csr_type_level(p_start_date
                                 ,p_end_date
                                 ,p_cost_group_id
                                 ,p_cost_type_id
                                 ,p_inventory_item_id
                                 );
    END IF;

    LOOP
        l_upd_val_txn_tab := l_empty_txn_tab;
        FETCH upd_val_csr_type_level BULK COLLECT INTO l_upd_val_txn_tab LIMIT l_batch_size;

	l_loop_count := l_upd_val_txn_tab.count;

	FOR i IN 1..l_loop_count
	LOOP
              -- insert into cppb
	      l_error_num := 0;

	      IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
	        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => p_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );
               l_error_num  := NVL(l_error_num, 0);
               l_error_code := NVL(l_error_code, 'No Error');
	       l_error_msg  := NVL(l_error_msg, 'No Error');

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb5'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
	        END IF;
              END IF; -- item table count check

	      IF l_error_num = 0 THEN

		  CSTPPINV.cost_inv_txn
			(i_pac_period_id       => p_period_id
			,i_legal_entity        => p_legal_entity
		         ,i_cost_type_id        => p_cost_type_id
		         ,i_cost_group_id       => p_cost_group_id
		         ,i_cost_method         => p_cost_method
		         ,i_txn_id              => l_upd_val_txn_tab(i).transaction_id
		         ,i_txn_action_id       => l_upd_val_txn_tab(i).transaction_action_id
		         ,i_txn_src_type_id     => l_upd_val_txn_tab(i).transaction_source_type_id
		         ,i_item_id             => l_upd_val_txn_tab(i).inventory_item_id
		         ,i_txn_qty             => l_upd_val_txn_tab(i).primary_quantity
		         ,i_txn_org_id          => l_upd_val_txn_tab(i).organization_id
		         ,i_txfr_org_id         => l_upd_val_txn_tab(i).transfer_organization_id
		         ,i_subinventory_code   => l_upd_val_txn_tab(i).subinventory_code
		         ,i_exp_flag            => l_exp_flag
		         ,i_exp_item            => l_exp_item
		         ,i_pac_rates_id        => p_pac_rates_id
		         ,i_process_group       => l_process_group
		         ,i_master_org_id       => p_master_org_id
		         ,i_uom_control         => p_uom_control
		         ,i_user_id             => p_user_id
		         ,i_login_id            => p_login_id
		         ,i_request_id          => p_req_id
		         ,i_prog_id             => p_prg_id
		         ,i_prog_appl_id        => p_prg_appid
		         ,i_txn_category        => p_txn_category
		         ,i_transfer_price_pd   => 0
		         ,o_err_num             => l_error_num
		         ,o_err_code            => l_error_code
		         ,o_err_msg             => l_error_msg);

	          l_error_num  := NVL(l_error_num, 0);
	          l_error_code := NVL(l_error_code, 'No Error');
	          l_error_msg  := NVL(l_error_msg, 'No Error');

	      END IF; -- error number check

	      IF l_error_num <> 0 THEN
			IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
		              , G_MODULE_HEAD || l_routine || '.others'
		              , 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_upd_val_txn_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
                        );
		       END IF;

		  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
		  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	          FND_MESSAGE.set_token('MESSAGE', 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_upd_val_txn_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
	          FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
	      END IF;
        END LOOP; --	FOR i IN 1..l_loop_count

	EXIT WHEN upd_val_csr_type_level%NOTFOUND;
      END LOOP; --	FETCH loop
    CLOSE upd_val_csr_type_level;

      -- =============================================================
      -- insert left over cost PCU value change transactions into cppb
      -- txn_category is either 5 or 8.5
      -- =============================================================
      l_error_num := 0;

      IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => p_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb6'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      -- Calculate Periodic Item Cost and Variance
      IF l_error_num = 0 THEN
        CSTPPWAC.calculate_periodic_cost(i_pac_period_id   => p_period_id
                                        ,i_cost_group_id   => p_cost_group_id
                                        ,i_cost_type_id    => p_cost_type_id
                                        ,i_low_level_code  => p_low_level_code
                                        ,i_item_id         => p_inventory_item_id
                                        ,i_user_id         => p_user_id
                                        ,i_login_id        => p_login_id
                                        ,i_request_id      => p_req_id
                                        ,i_prog_id         => p_prg_id
                                        ,i_prog_appl_id    => p_prg_appid
                                        ,o_err_num         => l_error_num
                                        ,o_err_code        => l_error_code
                                        ,o_err_msg         => l_error_msg
                                        );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');
      END IF;

      -- ==============================================================
      -- BUG 8547715 fix: Update CPPB with period_balnce, item_cost
      -- variance_amount for each transaction category
      -- variance_amount is obtained from the last transaction of txn_category
      -- txn_category 5 for non-interorg item cost groups invoked outside of
      -- iteration logic.
      -- txn_category 8.5 for interorg item cost groups invoked thru
      -- iteration process
      -- item-cost group belongs to either txn_category 5 OR 8.5
      -- ===============================================================

      -- PCU value change with primary qty 0

      IF l_error_num = 0 THEN
        CSTPPWAC.update_item_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => p_txn_category
                                 ,i_item_id           => p_inventory_item_id
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.updcppb3'
                        ,'After calling update_item_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num <> 0
      THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine || '.others'
                    , 'Error in cost group ' || p_cost_group_id ||
		      'txn category:' || p_txn_category || ' ('||l_error_code||') '||l_error_msg
                    );
	END IF;

        FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'Error for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;


END Periodic_Cost_Update_By_Level;


--========================================================================
-- PROCEDURE : Find Starting Phase    PRIVATE
-- COMMENT   : Find the starting phase for the cost group
--           : Starting phase depend on Processing Types :
--           :  1. Run Acquisition Only (Acquisition Cost SRS)
--           :  Start Phase = 1.
--           :  2. Run From phase 2 (PAC SRS option 1).
--           :  Validate that phase 1 completed, error out if it's not
--           :  If phase 1 is completed, then Start Phase = 2.
--           :  3. Run From error out phase (PAC SRS option 2)
--           :  Validate that phase 1 completed, error out if it's not
--           :  If phase 1 is completed, then Start Phase = Error Out Phase.
--           :  If no error out phase (All complete/pending),
--           :  start from phase 2.
--=========================================================================
PROCEDURE find_starting_phase
( p_legal_entity       IN NUMBER
, p_cost_type_id       IN NUMBER
, p_period_id          IN NUMBER
, p_end_date           IN DATE
, p_cost_group_id      IN NUMBER
, p_run_options        IN NUMBER
, x_starting_phase     OUT NOCOPY NUMBER
, p_user_id            IN NUMBER
, p_login_id           IN NUMBER
, p_req_id             IN NUMBER
, p_prg_id             IN NUMBER
, p_prg_appid          IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'find_starting_phase';
--=================
-- VARIABLES
--=================

l_starting_phase     NUMBER;
l_phase_status       NUMBER;
l_count              NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Run Options: 3 Resume for tolerance; 4 Final iteration
  IF (p_run_options = 3 OR p_run_options = 4) THEN
    l_starting_phase := 7;
    -- Process_upto_date check count
    l_count := 0;

  ELSIF p_run_options = 1 THEN
    -- Run Options: 1 Start

      -- Set the starting phase to 1
      l_starting_phase := 1;

      -- Process_upto_date check count
      l_count := 0;

  ELSE
    -- Run Options: 2 Resume from error
      SELECT nvl(min(process_phase), 1)
        INTO l_starting_phase
        FROM cst_pac_process_phases
       WHERE pac_period_id = p_period_id
         AND cost_group_id = p_cost_group_id
         AND process_status = 3
         AND ( process_phase <= 5 OR process_phase = 7);

    -- Make sure that process_upto_date of the acquisition cost is
    -- equal or less than the period end date
    IF l_starting_phase = 7 THEN

      SELECT nvl(min(process_phase), 7)
        INTO l_starting_phase
	FROM cst_pac_process_phases
      WHERE pac_period_id = p_period_id
         AND cost_group_id = p_cost_group_id
         AND process_status = 3
         AND process_phase IN (8);

      SELECT
        count(1)
      INTO l_count
      FROM cst_pac_process_phases
      WHERE pac_period_id = p_period_id
        AND cost_group_id = p_cost_group_id
        AND process_phase = 5
        AND process_upto_date <= p_end_date;

    ELSIF l_starting_phase <= 5 THEN
      SELECT
        count(1)
      INTO l_count
      FROM cst_pac_process_phases
      WHERE pac_period_id = p_period_id
        AND cost_group_id = p_cost_group_id
        AND process_phase = l_starting_phase - 1
        AND process_upto_date <= p_end_date;
    END IF;

  END IF;

  x_starting_phase := l_starting_phase;

     IF l_count <> 0 THEN
       -- Set the starting phase status to error
        CST_PERIODIC_AVERAGE_PROC_CP.set_status
         ( p_period_id        => p_period_id
         , p_cost_group_id    => p_cost_group_id
         , p_phase            => l_starting_phase
         , p_status           => 3
         , p_end_date         => p_end_date
         , p_user_id          => p_user_id
         , p_login_id         => p_login_id
         , p_req_id           => p_req_id
         , p_prg_id           => p_prg_id
         , p_prg_appid        => p_prg_appid);

        FND_MESSAGE.Set_Name('BOM', 'CST_PAC_PROCESS_DATE_ACQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END find_starting_phase;

--========================================================================
-- FUNCTION : Get Uom Control Level PRIVATE
-- COMMENT   : Find the cost method
--=========================================================================
FUNCTION get_uom_control_level
RETURN NUMBER
IS

l_routine CONSTANT VARCHAR2(30) := 'get_uom_control_level';
--=================
-- VARIABLES
--=================

l_uom_control    NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT control_level
  INTO l_uom_control
  FROM mtl_item_attributes
  WHERE attribute_name = 'MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE';

  RETURN l_uom_control;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END get_uom_control_level;

--========================================================================
-- PROCEDURE : Validate Master Org                              PRIVATE
-- COMMENT   : Validate Master Organization
--========================================================================
PROCEDURE validate_master_org
( p_legal_entity      IN NUMBER
, p_cost_type_id      IN NUMBER
, p_cost_group_id     IN NUMBER
, x_master_org_id     OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_master_org';
--=================
-- VARIABLES
--=================

l_master_org_id       NUMBER;
l_count               NUMBER;
l_message             VARCHAR2(250);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT NVL(organization_id,-1)
  INTO   l_master_org_id
  FROM   cst_cost_groups
  WHERE  cost_group_id = p_cost_group_id;

  -- Validate that all the orgs under this cost group
  -- have the same master.
  -- The logic to prove this
  -- checks the cost group assignment
  -- table for organizations associated
  -- with the given cost group when the
  -- master org is different than the
  -- master org being validated.

  SELECT count(1)
  INTO   l_count
  FROM   mtl_parameters mp
  WHERE  mp.master_organization_id <> l_master_org_id
    AND  mp.organization_id IN (
      SELECT organization_id
      FROM   cst_cost_group_assignments ccga
      WHERE  ccga.cost_group_id = p_cost_group_id)
    AND rownum = 1;

  IF l_count = 0
  THEN

    x_master_org_id := l_master_org_id;

  ELSE
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_SOL_MST');
    FND_MESSAGE.set_token('CSTGRP', p_cost_group_id);
    l_message   := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_master_org;

--========================================================================
-- PROCEDURE : Find_Pac_Rates_algorithm    PRIVATE
-- COMMENT   : Find the pac rates and
--           : Material Relief Algorithm (introduced in R12)
--           : 0 - Use Pre-defined Materials
--           : 1 - Use Actual Materials
--=========================================================================
PROCEDURE find_pac_rates_algorithm
( p_legal_entity         IN NUMBER
, p_cost_type_id         IN NUMBER
, x_pac_rates_id         OUT NOCOPY NUMBER
, x_mat_relief_algorithm OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'find_pac_rates_algorithm';
--=================
-- VARIABLES
--=================

l_pac_rates_id         NUMBER;
l_mat_relief_algorithm NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    nvl(max(pac_rates_cost_type_id),-1)
  , nvl(max(material_relief_algorithm),1)
  INTO l_pac_rates_id
      ,l_mat_relief_algorithm
  FROM cst_le_cost_types
  WHERE legal_entity = p_legal_entity
    AND cost_type_id = p_cost_type_id;

  x_pac_rates_id         := l_pac_rates_id;
  x_mat_relief_algorithm := l_mat_relief_algorithm;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END find_pac_rates_algorithm;

--========================================================================
-- PROCEDURE : Validate_Process_Upto_Date    PRIVATE
-- COMMENT   : Check whether the process upto date lies between the PAC
--           : Start Date and End Date
--=========================================================================
PROCEDURE validate_process_upto_date
( p_process_upto_date      IN VARCHAR2
, p_period_id              IN NUMBER
, p_run_options            IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_process_upto_date';
--=================
-- VARIABLES
--=================

l_count       NUMBER;
l_process_upto_date DATE;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Run options 1 - Start
  -- Check process upto date is within the range
  IF p_run_options = 1 THEN
  l_process_upto_date :=
    TRUNC(FND_DATE.canonical_to_date(p_process_upto_date));
    FND_FILE.put_line
    ( FND_FILE.log
    , 'Process Upto Date:' || l_process_upto_date
    );

    SELECT count(1)
    INTO l_count
    FROM CST_PAC_PERIODS cpp
    WHERE cpp.pac_period_id      = p_period_id
      AND TRUNC(cpp.period_end_date)   >= l_process_upto_date
      AND TRUNC(cpp.period_start_date) <= l_process_upto_date;

    FND_FILE.put_line
    ( FND_FILE.log
    , ' Count of Periods in the range:' || l_count
    );

    IF l_count = 0 THEN
      FND_MESSAGE.Set_Name('BOM', 'CST_PAC_PROCESS_DATE_ERROR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    -- All other run options: 2 - Resume for Error, 3 - Resume for non tolerance
    -- , 4 - Final process upto date should be NULL
    IF p_process_upto_date IS NOT NULL THEN
      FND_MESSAGE.Set_Name('BOM', 'CST_PAC_PROCESS_DATE_NULL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- run options check

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_process_upto_date;

--========================================================================
-- PROCEDURE : Number_Of_Assignments    PRIVATE
-- COMMENT   : find if a cost group has assignments
--=========================================================================
PROCEDURE number_of_assignments
( p_cost_group_id          IN NUMBER
, p_period_id              IN NUMBER
, p_user_id                IN NUMBER
, p_login_id               IN NUMBER
, p_req_id                 IN NUMBER
, p_prg_id                 IN NUMBER
, p_prg_appid              IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'number_of_assignments';
--=================
-- VARIABLES
--=================

l_num_of_assignments       NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT count(1)
  INTO l_num_of_assignments
  FROM cst_cost_group_assignments ccga
  WHERE ccga.cost_group_id = p_cost_group_id;

  IF l_num_of_assignments = 0 THEN

    UPDATE cst_pac_process_phases
    SET process_status = 3,
        process_date = SYSDATE,
        last_update_date = SYSDATE,
        last_updated_by = p_user_id,
        request_id = p_req_id,
        program_application_id = p_prg_appid,
        program_id = p_prg_id,
        program_update_date = SYSDATE,
        last_update_login = p_login_id
    WHERE pac_period_id = p_period_id
      AND cost_group_id = p_cost_group_id;

/*

      AND process_phase = decode(l_processing_options,1,1,2);

*/
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END number_of_assignments;

--========================================================================
-- PROCEDURE : find_cost_method    PRIVATE
-- COMMENT   : Find the cost method
--=========================================================================
PROCEDURE find_cost_method
( p_legal_entity        IN NUMBER
, p_cost_type_id        IN NUMBER
, x_cost_method         OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'find_cost_method';
--=================
-- VARIABLES
--=================

l_cost_method       NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT nvl(max(primary_cost_method),-1)
  INTO l_cost_method
  FROM cst_le_cost_types clct
  WHERE clct.legal_entity = p_legal_entity
    AND clct.cost_type_id = p_cost_type_id;

  x_cost_method := l_cost_method;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END find_cost_method;

--========================================================================
-- PROCEDURE : Validate_Cost_Groups    PRIVATE
-- COMMENT   : This procedure will find the cost groups that fall
--           : under this cost type/legal entity association and
--           : check their validity
--=========================================================================
PROCEDURE validate_cost_groups
( p_legal_entity       IN NUMBER
, p_cost_type_id       IN NUMBER
, p_period_id          IN NUMBER
, p_cost_group_id      IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_cost_groups';
  --=================
  -- VARIABLES
  --=================
  l_count                       NUMBER;
  l_message                     VARCHAR2(250);
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT count(1)
  INTO l_count
  FROM cst_cost_groups ccg
  WHERE ccg.legal_entity = p_legal_entity
  AND ccg.cost_group_id = p_cost_group_id
  AND trunc(nvl(ccg.disable_date, SYSDATE+1)) > trunc(SYSDATE)
  AND EXISTS (
    SELECT 'X'
    FROM cst_pac_process_phases cppp
    WHERE cppp.cost_group_id = ccg.cost_group_id
    AND cppp.pac_period_id = p_period_id);

  IF l_count = 0
  THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_CG');
    FND_MESSAGE.set_token('CSTGRP', p_cost_group_id);
    l_message := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_cost_groups;

--========================================================================
-- PROCEDURE : Find_Period_Duration    PRIVATE
-- COMMENT   : Find the Start and End dates for the current period
--=========================================================================
PROCEDURE find_period_duration
( p_legal_entity          IN NUMBER
, p_cost_type_id          IN NUMBER
, p_period_id             IN NUMBER
, p_process_upto_date     IN VARCHAR2
, x_start_date            OUT NOCOPY DATE
, x_end_date              OUT NOCOPY DATE
)
IS

l_routine CONSTANT VARCHAR2(30) := 'find_period_duration';
--=================
-- VARIABLES
--=================

l_start_date        VARCHAR2(30);
l_end_date          VARCHAR2(30);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT TO_CHAR(period_start_date,'YYYY/MM/DD HH24:MI:SS')
        ,p_process_upto_date
  INTO l_start_date
      ,l_end_date
  FROM cst_pac_periods cpp
  WHERE cpp.pac_period_id = p_period_id
    AND cpp.legal_entity = p_legal_entity
    AND cpp.cost_type_id = p_cost_type_id;

  x_start_date := TO_DATE(l_start_date,'YYYY/MM/DD HH24:MI:SS');

  -- set to 23:59:59 to retrieve all the records
  x_end_date   := TRUNC(FND_DATE.canonical_to_date(l_end_date)) + (86399/86400);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END find_period_duration;

--========================================================================
-- PROCEDURE : Validate_Phases_Seeded    PRIVATE
-- COMMENT   : This procedure will ensure all 7 phases are seeded for
--           : each cost group and phase 7 has a process status of 1
--=========================================================================
PROCEDURE validate_phases_seeded
( p_cost_group_id      IN NUMBER
, p_period_id          IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_phases_seeded';
--=================
-- VARIABLES
--=================

l_status    NUMBER := 1;
l_count     NUMBER;
l_message   VARCHAR2(250);
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT count(1)
  INTO l_count
  FROM cst_pac_process_phases
  WHERE cost_group_id = p_cost_group_id
  AND pac_period_id = p_period_id;

  IF l_count <> 8
  THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_PHS_SED');
    l_message   := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_phases_seeded;

--========================================================================
-- PROCEDURE : Validate_Previous_Period    PRIVATE
-- COMMENT   : This procedure will ensure that previous period is closed
--=========================================================================
PROCEDURE validate_previous_period
( p_legal_entity       IN NUMBER
, p_cost_type_id       IN NUMBER
, p_period_id          IN NUMBER
, x_prev_period_id     OUT NOCOPY NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_previous_period';
--=================
-- VARIABLES
--=================

l_count            NUMBER;
l_prev_period_id   NUMBER;
l_period_closed    NUMBER;
l_period_complete  NUMBER;
l_message          VARCHAR2(250);
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT nvl(max(cpp.pac_period_id), -1)
  INTO l_prev_period_id
  FROM cst_pac_periods cpp
  WHERE cpp.legal_entity = p_legal_entity
    AND cpp.cost_type_id = p_cost_type_id
    AND cpp.pac_period_id < p_period_id;

  IF l_prev_period_id <> -1
  THEN

    SELECT count(1)
    INTO l_period_closed
    FROM cst_pac_periods cpp
    WHERE cpp.pac_period_id = l_prev_period_id
      AND cpp.legal_entity = p_legal_entity
      AND cpp.cost_type_id = p_cost_type_id
      AND cpp.open_flag = 'N'
      AND cpp.period_close_date IS NOT NULL;

    IF l_period_closed = 0 THEN
      FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_PRE_PER');
      l_message   := FND_MESSAGE.GET;
      FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
      FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
      FND_MESSAGE.set_token('MESSAGE', l_message);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.prevpd'
                  ,'Previous Period Id:' || l_prev_period_id
                  );
  END IF;

  x_prev_period_id := l_prev_period_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_previous_period;

--========================================================================
-- PROCEDURE : Validate_Period    PRIVATE
-- COMMENT   : This procedure checks the current period is open
--           : for the legal entity, cost type association.
--=========================================================================
PROCEDURE validate_period
( p_legal_entity       IN NUMBER
, p_cost_type_id       IN NUMBER
, p_period_id          IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_period';
--=================
-- VARIABLES
--=================

l_count     NUMBER;
l_message   VARCHAR2(250);
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT count(1)
  INTO l_count
  FROM cst_pac_periods cpp
  WHERE cpp.legal_entity = p_legal_entity
    AND cpp.cost_type_id = p_cost_type_id
    AND cpp.pac_period_id = p_period_id
    AND cpp.open_flag = 'Y'
    AND cpp.period_close_date IS NULL;

  IF l_count = 0
  THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_CUR_PER');
    l_message   := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_period;

--========================================================================
-- PROCEDURE : Validate_Le_Ct_Association    PRIVATE
-- COMMENT   : check the validity of cost type, legal entity
--           : and their association
--=========================================================================
PROCEDURE validate_le_ct_association
( p_legal_entity   IN NUMBER
, p_cost_type_id   IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_le_ct_association';
--=================
-- VARIABLES
--=================

l_count     NUMBER;
l_message   VARCHAR2(250);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT count(1)
  INTO l_count
  FROM cst_cost_types cct
  WHERE cct.cost_type_id = p_cost_type_id
    AND cct.organization_id IS NULL
    AND cct.allow_updates_flag = 2
    AND trunc(nvl(cct.disable_date, SYSDATE+1)) > trunc(SYSDATE);

  IF l_count = 0
  THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_CT');
    l_message := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT count(1)
  INTO l_count
  FROM cst_le_cost_types clct
  WHERE clct.legal_entity = p_legal_entity
    AND clct.cost_type_id = p_cost_type_id;

  IF l_count = 0
  THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_VAL_LE_CT');
    l_message := FND_MESSAGE.GET;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', l_message);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END validate_le_ct_association;

--=========================================================================
-- PROCEDURE : Process_Gp2_Other_Txns
-- COMMENT   : This procedure processes items in current BOM
--           : level with interorg txns within the same cost group and non
--           : interorg txns
--=========================================================================
PROCEDURE Process_Gp2_Other_Txns
(p_legal_entity           IN NUMBER
,p_cost_type_id           IN NUMBER
,p_cost_method            IN NUMBER
,p_period_id              IN NUMBER
,p_start_date             IN DATE
,p_end_date               IN DATE
,p_prev_period_id         IN NUMBER
,p_cg_tab                 IN CST_PERIODIC_ABSORPTION_PROC.tbl_type
,p_inventory_item_id      IN NUMBER
,p_uom_control            IN NUMBER
,p_pac_rates_id           IN NUMBER
,p_mat_relief_algorithm   IN NUMBER
,p_user_id                IN NUMBER
,p_login_id               IN NUMBER
,p_req_id                 IN NUMBER
,p_prg_id                 IN NUMBER
,p_prg_appid              IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'process_gp2_other_txns';

-- =======================================================================
-- Cursor to retrieve Group 2 Transactions :
-- interorg txns within the same cost group
-- non inter org txns
-- interorg txns across cost groups generated through internal sales orders
-- when the transfer price option is 2
-- OPM convergence - Logical intransit shipment 22 processed at shipping
-- cost group; direct interorg shipment where receiving org is OPM
-- Interorg txns within same CG
-- All items other than interorg items across cost groups
-- =======================================================================
CURSOR group2_other_cur(c_period_start_date      DATE
                       ,c_period_end_date        DATE
                       ,c_pac_period_id          NUMBER
                       ,c_cost_group_id          NUMBER
                       ,c_inventory_item_id      NUMBER
                       )
IS
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM  mtl_material_transactions mmt
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND EXISTS (select 'X'
              from mtl_parameters mp
	      where mmt.organization_id = mp.organization_id
               AND  nvl(mp.process_enabled_flag, 'N') = 'N')
  AND transaction_action_id in (3,12,21)
  AND EXISTS (SELECT 'EXISTS'
                   FROM cst_cost_group_assignments ccga
                   WHERE ccga.cost_group_id = c_cost_group_id
                     AND (ccga.organization_id = mmt.organization_id OR
                          ccga.organization_id = mmt.transfer_organization_id))
  AND (
         (mmt.transaction_source_type_id = 13
            AND EXISTS (select 'X'
                        from mtl_parameters mp2
	                where mp2.organization_id = mmt.transfer_organization_id
                         AND mp2.process_enabled_flag = 'Y'))
      OR (mmt.transaction_source_type_id in (7,8)
            AND EXISTS (SELECT 'X'
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
 						          AND hoi2.org_information_context = 'Accounting Information')))
         )
  AND (transaction_action_id IN (3,12,21)
       AND NOT EXISTS (SELECT 'X'
                       FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                       WHERE c1.organization_id = mmt.organization_id
                         AND c2.organization_id = mmt.transfer_organization_id
                         AND c1.cost_group_id = c2.cost_group_id)
       AND (
              (mmt.transaction_action_id = 3
               AND EXISTS (SELECT 'X'
                           FROM cst_cost_group_assignments ccga1
                           WHERE ccga1.cost_group_id = c_cost_group_id
                           AND ccga1.organization_id = mmt.organization_id
                           AND mmt.primary_quantity < 0)
	      )
           OR (mmt.transaction_action_id = 21
               AND EXISTS (SELECT 'X'
                           FROM cst_cost_group_assignments ccga2
                           WHERE ccga2.organization_id = mmt.organization_id
                           AND ccga2.cost_group_id = c_cost_group_id)
	      )
           OR (mmt.transaction_action_id = 12
               AND EXISTS (SELECT 'X'
                           FROM mtl_interorg_parameters mip
                           WHERE mip.from_organization_id = mmt.transfer_organization_id
                             AND mip.to_organization_id = mmt.organization_id
                             AND (
			           (NVL(mmt.fob_point,mip.fob_point) = 1
				    AND EXISTS (SELECT 'X'
                                                FROM cst_cost_group_assignments ccga2
                                                WHERE ccga2.organization_id = mip.to_organization_id
                                                  AND ccga2.cost_group_id = c_cost_group_id)
				   )
                                OR (NVL(mmt.fob_point,mip.fob_point) = 2
				    AND EXISTS (SELECT 'X'
                                                FROM cst_cost_group_assignments ccga3
                                                WHERE ccga3.organization_id = mip.from_organization_id
                                                  AND ccga3.cost_group_id = c_cost_group_id)
				   )
				 )
		           )
	      )
           )
      )
  AND NOT EXISTS (SELECT 'X'
                  FROM cst_pac_low_level_codes cpllc
                  WHERE cpllc.inventory_item_id = mmt.inventory_item_id
                    AND cpllc.pac_period_id = c_pac_period_id
                    AND cpllc.cost_group_id = c_cost_group_id)
UNION ALL
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM  mtl_material_transactions mmt
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND EXISTS (select 'X'
              from mtl_parameters mp
	      where mmt.organization_id = mp.organization_id
               AND  nvl(mp.process_enabled_flag, 'N') = 'N')
  AND (
           (mmt.transaction_action_id = 22
             AND EXISTS ( SELECT 'X'
                          FROM  cst_cost_group_assignments ccga0
                          WHERE ccga0.organization_id = mmt.organization_id
                            AND ccga0.cost_group_id = c_cost_group_id))
        OR ( (mmt.transaction_action_id IN (12,21) OR (mmt.transaction_action_id = 3 AND mmt.primary_quantity < 0))
             AND EXISTS (SELECT 'X'
                         FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                         WHERE c1.organization_id = mmt.organization_id
                           AND c2.organization_id = mmt.transfer_organization_id
                           AND c1.cost_group_id = c2.cost_group_id
   			   AND c1.cost_group_id = c_cost_group_id))
      )
  AND NOT EXISTS (SELECT 'X'
                  FROM cst_pac_low_level_codes cpllc
                  WHERE cpllc.inventory_item_id = mmt.inventory_item_id
                    AND cpllc.pac_period_id = c_pac_period_id
                    AND cpllc.cost_group_id = c_cost_group_id)
UNION ALL
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM
  mtl_material_transactions mmt
, cst_cost_group_assignments ccga
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND transaction_action_id in (4,8,28,33,34,1,2,5,27)
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND ccga.cost_group_id   = c_cost_group_id
  AND ccga.organization_id = mmt.organization_id
  AND nvl(mmt.logical_transactions_created, 1) <> 2
  AND nvl(mmt.logical_transaction, 3) <> 1
  AND (transaction_action_id IN (4,8,28,33,34)
      OR (transaction_action_id IN (2,5) AND primary_quantity < 0)
      OR (transaction_action_id in (1, 27)
          AND transaction_source_type_id IN (3,6,13)
          AND transaction_cost IS NULL)
      OR (transaction_action_id in (1,27)
         AND transaction_source_type_id NOT IN (1,3,6,13)) )
  AND NOT EXISTS (
    SELECT 'X'
    FROM cst_pac_low_level_codes cpllc
    WHERE cpllc.inventory_item_id = mmt.inventory_item_id
      AND cpllc.pac_period_id = c_pac_period_id
      AND cpllc.cost_group_id = c_cost_group_id);

-- =======================================================================
-- Cursor to retrieve Group 2 Transactions - interorg txns within the same
-- cost group and non inter org txns for completion items in current BOM
-- highest level
-- Interorg txns generated through internal sales orders when transfer
-- price option is enabled - option 2
-- Interorg txns within the same CG
-- OPM equivalent txn (logical shipment 22) to be processed by shipping CG
-- All other cost derived txns
-- =======================================================================
CURSOR group2_other_comp_cur(c_period_start_date     DATE
                            ,c_period_end_date       DATE
                            ,c_pac_period_id         NUMBER
                            ,c_cost_group_id         NUMBER
                            ,c_inventory_item_id     NUMBER
                            )
IS
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM  mtl_material_transactions mmt
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND EXISTS (select 'X'
              from mtl_parameters mp
	      where mmt.organization_id = mp.organization_id
               AND  nvl(mp.process_enabled_flag, 'N') = 'N')
  AND transaction_action_id in (3,12,21)
  AND EXISTS (SELECT 'EXISTS'
                   FROM cst_cost_group_assignments ccga
                   WHERE ccga.cost_group_id = c_cost_group_id
                     AND (ccga.organization_id = mmt.organization_id OR
                          ccga.organization_id = mmt.transfer_organization_id))
  AND (
         (mmt.transaction_source_type_id = 13
            AND EXISTS (select 'X'
                        from mtl_parameters mp2
	                where mp2.organization_id = mmt.transfer_organization_id
                         AND mp2.process_enabled_flag = 'Y'))
      OR (mmt.transaction_source_type_id in (7,8)
            AND EXISTS (SELECT 'X'
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
 						          AND hoi2.org_information_context = 'Accounting Information')))
         )
  AND (transaction_action_id IN (3,12,21)
       AND NOT EXISTS (SELECT 'X'
                       FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                       WHERE c1.organization_id = mmt.organization_id
                         AND c2.organization_id = mmt.transfer_organization_id
                         AND c1.cost_group_id = c2.cost_group_id)
       AND (
              (mmt.transaction_action_id = 3
               AND EXISTS (SELECT 'X'
                           FROM cst_cost_group_assignments ccga1
                           WHERE ccga1.cost_group_id = c_cost_group_id
                           AND ccga1.organization_id = mmt.organization_id
                           AND mmt.primary_quantity < 0)
	      )
           OR (mmt.transaction_action_id = 21
               AND EXISTS (SELECT 'X'
                           FROM cst_cost_group_assignments ccga2
                           WHERE ccga2.organization_id = mmt.organization_id
                           AND ccga2.cost_group_id = c_cost_group_id)
	      )
           OR (mmt.transaction_action_id = 12
               AND EXISTS (SELECT 'X'
                           FROM mtl_interorg_parameters mip
                           WHERE mip.from_organization_id = mmt.transfer_organization_id
                             AND mip.to_organization_id = mmt.organization_id
                             AND (
			           (NVL(mmt.fob_point,mip.fob_point) = 1
				    AND EXISTS (SELECT 'X'
                                                FROM cst_cost_group_assignments ccga2
                                                WHERE ccga2.organization_id = mip.to_organization_id
                                                  AND ccga2.cost_group_id = c_cost_group_id)
				   )
                                OR (NVL(mmt.fob_point,mip.fob_point) = 2
				    AND EXISTS (SELECT 'X'
                                                FROM cst_cost_group_assignments ccga3
                                                WHERE ccga3.organization_id = mip.from_organization_id
                                                  AND ccga3.cost_group_id = c_cost_group_id)
				   )
				 )
		           )
	      )
           )
      )
  AND EXISTS (SELECT 'X'
                  FROM cst_pac_low_level_codes cpllc
                  WHERE cpllc.inventory_item_id = mmt.inventory_item_id
                    AND cpllc.pac_period_id = c_pac_period_id
                    AND cpllc.cost_group_id = c_cost_group_id)
UNION ALL
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM  mtl_material_transactions mmt
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND EXISTS (select 'X'
              from mtl_parameters mp
	      where mmt.organization_id = mp.organization_id
               AND  nvl(mp.process_enabled_flag, 'N') = 'N')
  AND (
           (mmt.transaction_action_id = 22
             AND EXISTS ( SELECT 'X'
                          FROM  cst_cost_group_assignments ccga0
                          WHERE ccga0.organization_id = mmt.organization_id
                            AND ccga0.cost_group_id = c_cost_group_id))
        OR ( (mmt.transaction_action_id IN (12,21) OR (mmt.transaction_action_id = 3 AND mmt.primary_quantity < 0))
             AND EXISTS (SELECT 'X'
                         FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                         WHERE c1.organization_id = mmt.organization_id
                           AND c2.organization_id = mmt.transfer_organization_id
                           AND c1.cost_group_id = c2.cost_group_id
   			   AND c1.cost_group_id = c_cost_group_id))
      )
  AND EXISTS (SELECT 'X'
                  FROM cst_pac_low_level_codes cpllc
                  WHERE cpllc.inventory_item_id = mmt.inventory_item_id
                    AND cpllc.pac_period_id = c_pac_period_id
                    AND cpllc.cost_group_id = c_cost_group_id)
UNION ALL
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
, nvl(mmt.transfer_price,0) transfer_price
FROM
  mtl_material_transactions mmt
, cst_cost_group_assignments ccga
WHERE transaction_date between c_period_start_date AND c_period_end_date
  AND transaction_action_id in (4,8,28,33,34,1,2,5,27)
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = c_inventory_item_id
  AND nvl(mmt.owning_tp_type,2) = 2
  AND ccga.cost_group_id = c_cost_group_id
  AND ccga.organization_id = mmt.organization_id
  AND nvl(mmt.logical_transactions_created, 1) <> 2
  AND nvl(mmt.logical_transaction, 3) <> 1
  AND (transaction_action_id IN (4,8,28) /* Bug 8469865: Removed actions 33, 34 from list */
    OR (transaction_action_id IN (2,5) AND primary_quantity < 0)
    OR (transaction_action_id in (1,27)
      AND transaction_source_type_id IN (3,6,13)
      AND transaction_cost IS NULL)
    OR (transaction_action_id in (1,27)
      AND transaction_source_type_id NOT IN (1,3,5,6,13) )
    OR (
      ((transaction_action_id IN (1,27) AND transaction_source_type_id = 5)
      OR transaction_action_id IN (33,34))
      AND NOT EXISTS (
        SELECT 'X'
        FROM wip_entities we
        WHERE we.wip_entity_id = mmt.transaction_source_id
          AND we.primary_item_id = mmt.inventory_item_id)) )
  AND EXISTS (
    SELECT 'X'
    FROM cst_pac_low_level_codes cpllc
    WHERE cpllc.inventory_item_id = mmt.inventory_item_id
      AND cpllc.pac_period_id = c_pac_period_id
      AND cpllc.cost_group_id = c_cost_group_id);

TYPE group2_other_tab IS TABLE OF group2_other_cur%rowtype INDEX BY BINARY_INTEGER;
l_group2_other_tab		group2_other_tab;
l_empty_group2_other_tab	group2_other_tab;

l_loop_count       NUMBER := 0;
l_batch_size       NUMBER := 200;

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


-- Variables
l_current_index    BINARY_INTEGER;

-- Expense flag variables
l_exp_flag         NUMBER;
l_exp_item         NUMBER;

-- variable for charge WIP Material
l_hook_used        NUMBER;

-- variable to set process group 2
l_process_group    NUMBER := 2;

-- Error message variables
l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);

-- Transaction Category
l_txn_category     NUMBER;
l_low_level_code   NUMBER;

-- Exceptions
group2_other_except EXCEPTION;
error_transaction_id NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;
  -- initialize transaction category for group 2 (cost derived) transactions
  l_txn_category := 9;

l_current_index := p_cg_tab.FIRST;

LOOP
  -- Get Low Level Code for an item in the cost group
  OPEN get_llc_cur(p_period_id
                  ,p_cg_tab(l_current_index).cost_group_id
                  ,p_inventory_item_id
                  );
  FETCH get_llc_cur
   INTO l_low_level_code;

  -- =============================================================
  -- Items across cost groups may be in different BOM levels
  -- If item not found in pac low level code, set to -1 inorder to
  -- pass the value into update_item_cppb
  -- =============================================================
  IF get_llc_cur%NOTFOUND THEN
    l_low_level_code := -1;
  END IF;

  CLOSE get_llc_cur;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.lowlvcg'
                      ,'Cost Group Id:' || p_cg_tab(l_current_index).cost_group_id || ' Low Level Code:' || l_low_level_code
                      );
      END IF;

  IF l_low_level_code <> -1 THEN
  -- completion item
    OPEN group2_other_comp_cur
         (p_start_date
         ,p_end_date
         ,p_period_id
         ,p_cg_tab(l_current_index).cost_group_id
         ,p_inventory_item_id
         );

  ELSIF (l_low_level_code = -1) THEN
  -- no completion item
    OPEN group2_other_cur
         (p_start_date
         ,p_end_date
         ,p_period_id
         ,p_cg_tab(l_current_index).cost_group_id
         ,p_inventory_item_id
         );
  END IF;

  LOOP

      l_group2_other_tab := l_empty_group2_other_tab;
      IF l_low_level_code <> -1 THEN
	      FETCH group2_other_comp_cur BULK COLLECT INTO l_group2_other_tab LIMIT l_batch_size;
      ELSIF (l_low_level_code = -1) THEN
	      FETCH group2_other_cur BULK COLLECT INTO l_group2_other_tab LIMIT l_batch_size;
      END IF;
      l_loop_count := l_group2_other_tab.count;

      FOR i IN 1..l_loop_count
      LOOP

		-- ======================================================================
		-- Process Group 2 transactions for a completion item in the current level
		-- interorg transactions within the same cost group and
		-- non interorg transactions
		-- ======================================================================
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.group2_non_interorg'
				,'Group 2 - Transaction Id:'|| l_group2_other_tab(i).transaction_id );

			FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.gp2_item_id'
				,'Inventory Item Id:' || p_inventory_item_id || ' ' || 'Cost Group Id:'
				|| p_cg_tab(l_current_index).cost_group_id || ' Period Id:' || p_period_id
				);
		END IF;

		-- Get Expense Flag
                Get_exp_flag(p_item_id           => p_inventory_item_id
		            ,p_org_id            => l_group2_other_tab(i).organization_id
			    ,p_subinventory_code => l_group2_other_tab(i).subinventory_code
			    ,x_exp_flag          => l_exp_flag
			    ,x_exp_item          => l_exp_item
			    );

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.exp_flag_wip'
                          ,'Exp Flag:' || l_exp_flag || ' ' ||
                           'Exp Item:' || l_exp_item
                          );
		END IF;

		IF (l_group2_other_tab(i).transaction_source_type_id = 5 AND l_group2_other_tab(i).transaction_action_id <> 2) THEN

			-- ===========================================================
			-- insert into cppb
			-- ===========================================================
			l_error_num := 0;

			IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
				CSTPPWAC.insert_into_cppb(i_pac_period_id   => p_period_id
							,i_cost_group_id   => p_cg_tab(l_current_index).cost_group_id
							,i_txn_category      => l_txn_category
							,i_user_id           => p_user_id
							,i_login_id          => p_login_id
							,i_request_id        => p_req_id
							,i_prog_id           => p_prg_id
							,i_prog_appl_id      => p_prg_appid
							,o_err_num           => l_error_num
							,o_err_code          => l_error_code
							,o_err_msg           => l_error_msg
							);
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.string(FND_LOG.LEVEL_STATEMENT
					,G_MODULE_HEAD || l_routine || '.inscppb10'
					,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
					);
				END IF;
			END IF;

			IF l_error_num = 0 THEN

				-- Invoke Charge WIP Material
				   CSTPPWMT.charge_wip_material(  p_pac_period_id             => p_period_id
							        , p_cost_group_id             => p_cg_tab(l_current_index).cost_group_id
								, p_txn_id                    => l_group2_other_tab(i).transaction_id
								, p_exp_item                  => l_exp_item
								, p_exp_flag                  => l_exp_flag
								, p_legal_entity              => p_legal_entity
								, p_cost_type_id              => p_cost_type_id
								, p_cost_method               => p_cost_method
								, p_pac_rates_id              => p_pac_rates_id
								, p_material_relief_algorithm => p_mat_relief_algorithm
								, p_master_org_id             => p_cg_tab(l_current_index).master_org_id
								, p_uom_control               => p_uom_control
								, p_user_id                   => p_user_id
								, p_login_id                  => p_login_id
								, p_request_id                => p_req_id
								, p_prog_id                   => p_prg_id
								, p_prog_app_id               => p_prg_appid
								, p_txn_category              => l_txn_category
								, x_cost_method_hook          => l_hook_used
								, x_err_num                   => l_error_num
								, x_err_code                  => l_error_code
								, x_err_msg                   => l_error_msg
								 );

				    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.string(FND_LOG.LEVEL_STATEMENT
					,G_MODULE_HEAD || l_routine || '.gp2_charge_wip'
					,'Charge WIP Material:'|| l_error_num || ' ' ||
					l_error_code || ' ' || l_error_msg
					);
				    END IF;

			END IF; -- error number check

			IF l_error_num <> 0 THEN
				error_transaction_id := l_group2_other_tab(i).transaction_id;
				RAISE group2_other_except;
			END IF;

		ELSE

			-- insert into cppb
			l_error_num := 0;

			IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
				 CSTPPWAC.insert_into_cppb(i_pac_period_id    => p_period_id
							  ,i_cost_group_id    => p_cg_tab(l_current_index).cost_group_id
			                                   ,i_txn_category      => l_txn_category
						           ,i_user_id           => p_user_id
			                                   ,i_login_id          => p_login_id
						           ,i_request_id        => p_req_id
			                                   ,i_prog_id           => p_prg_id
						           ,i_prog_appl_id      => p_prg_appid
			                                   ,o_err_num           => l_error_num
						           ,o_err_code          => l_error_code
			                                   ,o_err_msg           => l_error_msg
						           );
			         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.string(FND_LOG.LEVEL_STATEMENT
					,G_MODULE_HEAD || l_routine || '.inscppb11'
					,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
					);
				 END IF;

				 IF l_error_num <> 0 THEN
					FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
					FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
					FND_MESSAGE.set_token('MESSAGE', 'Error in insert/update cpbb for cost group id '
					   ||p_cg_tab(l_current_index).cost_group_id||' ( '||l_error_code||' ) '||l_error_msg);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				 END IF;
			END IF;

			IF l_error_num = 0 THEN

				CSTPPINV.cost_inv_txn(i_pac_period_id      => p_period_id
						     ,i_legal_entity       => p_legal_entity
					           ,i_cost_type_id       => p_cost_type_id
					           ,i_cost_group_id      => p_cg_tab(l_current_index).cost_group_id
					           ,i_cost_method        => p_cost_method
					           ,i_txn_id             => l_group2_other_tab(i).transaction_id
					           ,i_txn_action_id      => l_group2_other_tab(i).transaction_action_id
					           ,i_txn_src_type_id    => l_group2_other_tab(i).transaction_source_type_id
					           ,i_item_id            => p_inventory_item_id
					           ,i_txn_qty            => l_group2_other_tab(i).primary_quantity
					           ,i_txn_org_id         => l_group2_other_tab(i).organization_id
					           ,i_txfr_org_id        => l_group2_other_tab(i).transfer_organization_id
					           ,i_subinventory_code  => l_group2_other_tab(i).subinventory_code
					           ,i_exp_flag           => l_exp_flag
					           ,i_exp_item           => l_exp_item
					           ,i_pac_rates_id       => p_pac_rates_id
					           ,i_process_group      => l_process_group
					           ,i_master_org_id      => p_cg_tab(l_current_index).master_org_id
					           ,i_uom_control        => p_uom_control
					           ,i_user_id            => p_user_id
					           ,i_login_id           => p_login_id
					           ,i_request_id         => p_req_id
					           ,i_prog_id            => p_prg_id
					           ,i_prog_appl_id       => p_prg_appid
					           ,i_txn_category       => l_txn_category
					           ,o_err_num            => l_error_num
					           ,o_err_code           => l_error_code
					           ,o_err_msg            => l_error_msg);

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.string(FND_LOG.LEVEL_STATEMENT
		                          ,G_MODULE_HEAD || l_routine || '.befcostinvtxn'
				          ,'After calling cost_inv_txn:'|| l_error_num || l_error_code || l_error_msg);
			        END IF;

				l_error_num  := NVL(l_error_num, 0);
				l_error_code := NVL(l_error_code, 'No Error');
				l_error_msg  := NVL(l_error_msg, 'No Error');

			END IF; -- error num check

			IF l_error_num <> 0 THEN
			        error_transaction_id := l_group2_other_tab(i).transaction_id;
			        RAISE group2_other_except;
		        END IF;

		END IF; -- WIP issue check

      END LOOP; -- FOR i IN 1..l_loop_count
      IF l_low_level_code <> -1 THEN
	EXIT WHEN group2_other_comp_cur%NOTFOUND;
      ELSIF l_low_level_code = -1 THEN
	EXIT WHEN group2_other_cur%NOTFOUND;
      END IF;
  END LOOP; --	FETCH loop

    IF group2_other_cur%ISOPEN THEN
      CLOSE group2_other_cur;
    END IF;

    IF group2_other_comp_cur%ISOPEN THEN
      CLOSE group2_other_comp_cur;
    END IF;

      -- ======================================================
      -- insert left over group2 completion txns into cppb
      -- ======================================================
      l_error_num := 0;

      IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cg_tab(l_current_index).cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb12'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num = 0 THEN
        CSTPPWAC.update_item_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cg_tab(l_current_index).cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_item_id           => p_inventory_item_id
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.updcppb11'
                        ,'After calling update_item_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num <> 0
      THEN
        FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'Error in insert/update cpbb for cost group id '||p_cg_tab(l_current_index).cost_group_id||' ( '||l_error_code||' ) '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


EXIT WHEN l_current_index = p_cg_tab.LAST;
l_current_index := p_cg_tab.NEXT(l_current_index);

END LOOP; -- cost group loop

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
 WHEN group2_other_except THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.group2_other_exc'
                  , 'group2_other_exc for txn_id '||error_transaction_id || l_error_code || l_error_msg
                  );
  END IF;
  FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
  FND_MESSAGE.set_token('MESSAGE', 'group2_other_exc for txn_id '||error_transaction_id|| l_error_code || l_error_msg);
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;
WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Process_Gp2_Other_Txns;


--=========================================================================
-- PROCEDURE : Process_Comp_Items
-- COMMENT   : This procedure processes WIP Assembly and WIP Issue txns for
--           : items having completion and PCU - value change transactions
--           : for items in current BOM level considering the highest BOM
--           : level across cost groups
--=========================================================================
PROCEDURE Process_Comp_Items
(p_legal_entity           IN NUMBER
,p_cost_type_id           IN NUMBER
,p_cost_method            IN NUMBER
,p_period_id              IN NUMBER
,p_start_date             IN DATE
,p_end_date               IN DATE
,p_prev_period_id         IN NUMBER
,p_cg_tab                 IN CST_PERIODIC_ABSORPTION_PROC.tbl_type
,p_inventory_item_id      IN NUMBER
,p_uom_control            IN NUMBER
,p_pac_rates_id           IN NUMBER
,p_mat_relief_algorithm   IN NUMBER
,p_user_id                IN NUMBER
,p_login_id               IN NUMBER
,p_req_id                 IN NUMBER
,p_prg_id                 IN NUMBER
,p_prg_appid              IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'process_comp_items';



-- Variables
l_current_index    BINARY_INTEGER;
l_cost_update_type NUMBER;
l_low_level_code   NUMBER;

cursor c_low_level_code_cur(c_pac_period_id     NUMBER
                           ,c_cost_group_id     NUMBER
                           ,c_inventory_item_id NUMBER
                           )
IS
SELECT
  low_level_code
FROM cst_pac_low_level_codes
WHERE pac_period_id      = c_pac_period_id
  AND cost_group_id      = c_cost_group_id
  AND inventory_item_id  = c_inventory_item_id;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;


  l_current_index := p_cg_tab.FIRST;

  LOOP
    -- Get  Low Level Code for the Item in that cost group
    OPEN c_low_level_code_cur(p_period_id
                             ,p_cg_tab(l_current_index).cost_group_id
                             ,p_inventory_item_id
                             );
    FETCH c_low_level_code_cur
     INTO l_low_level_code;

    -- completion item in the cost group
    -- note that an item can exist as a completion item in one cost group and
    -- no completion in another cost group
    IF c_low_level_code_cur%FOUND THEN

      -- ===================================================================
      -- Process WIP transactions
      -- ===================================================================
      -- Process non-rework assembly completion transactons
      CST_PERIODIC_ABSORPTION_PROC.Process_Non_Rework_Comps
       (p_period_id             => p_period_id
       ,p_start_date            => p_start_date
       ,p_end_date              => p_end_date
       ,p_prev_period_id        => p_prev_period_id
       ,p_cost_group_id         => p_cg_tab(l_current_index).cost_group_id
       ,p_inventory_item_id     => p_inventory_item_id
       ,p_cost_type_id          => p_cost_type_id
       ,p_legal_entity          => p_legal_entity
       ,p_cost_method           => p_cost_method
       ,p_pac_rates_id          => p_pac_rates_id
       ,p_master_org_id         => p_cg_tab(l_current_index).master_org_id
       ,p_mat_relief_algorithm  => p_mat_relief_algorithm
       ,p_uom_control           => p_uom_control
       ,p_low_level_code        => l_low_level_code
       ,p_user_id               => p_user_id
       ,p_login_id              => p_login_id
       ,p_req_id                => p_req_id
       ,p_prg_id                => p_prg_id
       ,p_prg_appid             => p_prg_appid);

      -- Process rework assembly issue and completion transactons
      CST_PERIODIC_ABSORPTION_PROC.Process_Rework_Issue_Comps
       (p_period_id             => p_period_id
       ,p_start_date            => p_start_date
       ,p_end_date              => p_end_date
       ,p_prev_period_id        => p_prev_period_id
       ,p_cost_group_id         => p_cg_tab(l_current_index).cost_group_id
       ,p_inventory_item_id     => p_inventory_item_id
       ,p_cost_type_id          => p_cost_type_id
       ,p_legal_entity          => p_legal_entity
       ,p_cost_method           => p_cost_method
       ,p_pac_rates_id          => p_pac_rates_id
       ,p_master_org_id         => p_cg_tab(l_current_index).master_org_id
       ,p_mat_relief_algorithm  => p_mat_relief_algorithm
       ,p_uom_control           => p_uom_control
       ,p_low_level_code        => l_low_level_code
       ,p_user_id               => p_user_id
       ,p_login_id              => p_login_id
       ,p_req_id                => p_req_id
       ,p_prg_id                => p_prg_id
       ,p_prg_appid             => p_prg_appid);

    END IF;

    CLOSE c_low_level_code_cur;

  EXIT WHEN l_current_index = p_cg_tab.LAST;

  l_current_index := p_cg_tab.NEXT(l_current_index);

  END LOOP;


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
END Process_Comp_Items;


--=========================================================================
-- PROCEDURE : Get_Absorption_Level_Of_Items       PRIVATE
-- COMMENT   : This procedure determines the Absorption Level across
--           : cost groups for each valid inventory item
--           : Absorption Level is determined based on the below criteria
--             1. BOM Highest Level across Cost Groups
--             2. Parent item should always have the higher BOM level than
--                all of its child items
--             If Parent item has lower BOM level than one of its child item
--             then the parent item's BOM level will be bumped up to next
--             higher level of its child item.
--=========================================================================
PROCEDURE Get_Absorption_Level_Of_Items(p_period_id         IN NUMBER
                                       ,p_legal_entity_id   IN NUMBER
                                       ,p_period_start_date IN DATE
                                       ,p_period_end_date   IN DATE
                                       )
IS
l_routine CONSTANT VARCHAR2(30) := 'get_absorption_level_of_items';

-- Cursor retrieve items in the current absorption level code
CURSOR items_in_current_absl_cur(c_pac_period_id         NUMBER
                                ,c_absorption_level_code NUMBER
                                )
IS
SELECT
  inventory_item_id
FROM cst_pac_itms_absl_codes
WHERE pac_period_id = c_pac_period_id
  AND absorption_level_code = c_absorption_level_code
FOR UPDATE OF absorption_level_code;

items_in_current_absl_row    items_in_current_absl_cur%ROWTYPE;


-- Cursor to print in diagnostics the items in a deadlock
CURSOR items_in_deadlock_cur(c_pac_period_id         NUMBER
                             ,c_absorption_level_code NUMBER
                             )
IS
SELECT  distinct(mst.concatenated_segments)
FROM cst_pac_itms_absl_codes cpiac, MTL_SYSTEM_ITEMS_B_KFV mst
WHERE cpiac.pac_period_id = c_pac_period_id
AND cpiac.absorption_level_code < c_absorption_level_code
AND cpiac.inventory_item_id = mst.inventory_item_id;


l_topmost_bom_level_code         NUMBER;
l_low_level_count                NUMBER;
l_lower_bom_level_code           NUMBER;
l_absorption_level_code          NUMBER;
l_topmost_absl_level_code        NUMBER;
l_min_child_absl_level_code      NUMBER;
l_reposition_absl_level_code     NUMBER;

l_dead_lock_message              VARCHAR2(3000) := ' ';
l_item_name			 MTL_SYSTEM_ITEMS_B_KFV.concatenated_segments%TYPE;
l_continue_loop_flag             VARCHAR2(1) := 'Y';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Purge cst_pac_itms_absl_codes
   DELETE cst_pac_itms_absl_codes
   WHERE pac_period_id = p_period_id;

   INSERT INTO cst_pac_itms_absl_codes
      (inventory_item_id
      ,pac_period_id
      ,absorption_level_code
      ,process_flag
      )
   SELECT /*+ leading (MMT) INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N5)*/
       distinct(mmt.inventory_item_id)
      ,p_period_id
      ,1000
      ,'N'
   FROM mtl_material_transactions mmt, cst_cost_groups ccg, cst_cost_group_assignments ccga
   WHERE mmt.transaction_date between p_period_start_date AND p_period_end_date
      AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
      AND nvl(mmt.owning_tp_type,2) = 2
      AND ccg.legal_entity = p_legal_entity_id
      AND ccga.organization_id = mmt.organization_id
      AND ccga.cost_group_id = ccg.cost_group_id
      AND NOT EXISTS (SELECT /*+ no_unnest*/ 'X'
	              FROM cst_pac_low_level_codes cpllc
	              WHERE cpllc.inventory_item_id  = mmt.inventory_item_id
	                AND cpllc.pac_period_id      = p_period_id);

  -- initialize lower bom level code
   l_lower_bom_level_code := 999;

  -- Get top most BOM level code across all items in all cost groups
   SELECT  min(low_level_code) top_most_bom_level_code
         , count(low_level_code) low_level_count
   INTO    l_topmost_bom_level_code
         ,l_low_level_count
   FROM   cst_pac_low_level_codes
   WHERE pac_period_id = p_period_id;

   IF l_low_level_count = 0 THEN
     -- Completion Items not exist
     l_topmost_bom_level_code := 1000;
   END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.topmostbomlvl'
                    ,'Topmost bom level code across items in all CGs:' || l_topmost_bom_level_code
                    );
   END IF;


  -- Any completion item exists
   IF l_topmost_bom_level_code < 1000 THEN

          INSERT INTO cst_pac_itms_absl_codes
            (pac_period_id
            ,inventory_item_id
            ,absorption_level_code
            ,process_flag
            )
          SELECT
             p_period_id
            ,cpllc.inventory_item_id
            ,min(low_level_code) bom_highest_level_code
            ,'N'
	  FROM cst_pac_low_level_codes cpllc
	  WHERE pac_period_id  = p_period_id
	  GROUP BY inventory_item_id;

   END IF; -- check for any completion item

  -- ===========================================================
  -- Determine Absorption Level Codes
  -- ===========================================================
   IF l_topmost_bom_level_code >= 1000 THEN
	l_continue_loop_flag := 'N';
   END IF;

   WHILE (l_continue_loop_flag = 'Y') LOOP
     l_continue_loop_flag := 'N';
     l_absorption_level_code := 999;

     -- Retrieve topmost absorption level code
     SELECT  min(absorption_level_code)
     INTO l_topmost_absl_level_code
     FROM cst_pac_itms_absl_codes
     WHERE pac_period_id = p_period_id;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.topmostabscode'
                      ,'Topmost absorption level code:' || l_topmost_absl_level_code
                      );
     END IF;

     WHILE (l_absorption_level_code >= l_topmost_absl_level_code) LOOP

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.abslvcode'
                      ,'Current absorption level code:' || l_absorption_level_code
                      );
       END IF;

      -- Retrieve items in the current absorption level code
       OPEN items_in_current_absl_cur(p_period_id
                                     ,l_absorption_level_code
                                     );
       FETCH items_in_current_absl_cur
        INTO items_in_current_absl_row;

       IF items_in_current_absl_cur%NOTFOUND THEN
         BEGIN
	 --CST_PAC_ABS_DEAD_LOCK is "The following items with absorption_level_code greater than 'ABS_CODE' are in a loop halting the process in deadlock. 'ITEMS'"
         OPEN    items_in_deadlock_cur(p_period_id,l_absorption_level_code);

	 FETCH items_in_deadlock_cur
	 INTO l_item_name;
	            l_dead_lock_message := l_item_name;
	 FETCH items_in_deadlock_cur
	 INTO l_item_name;
	 WHILE (items_in_deadlock_cur%FOUND) LOOP
		l_dead_lock_message := l_dead_lock_message || ', '|| l_item_name;
		FETCH items_in_deadlock_cur
		INTO l_item_name;
	 END LOOP;
	 CLOSE items_in_deadlock_cur;

	EXCEPTION
	WHEN OTHERS THEN
        FND_MESSAGE.Set_Name('BOM', 'CST_PAC_ABS_DEAD_LOCK');
        FND_MESSAGE.Set_token('ABS_CODE', l_absorption_level_code);
        FND_MESSAGE.set_token('ITEMS', l_dead_lock_message);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        END;

        FND_MESSAGE.Set_Name('BOM', 'CST_PAC_ABS_DEAD_LOCK');
	FND_MESSAGE.Set_token('ABS_CODE', l_absorption_level_code);
        FND_MESSAGE.set_token('ITEMS', l_dead_lock_message);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
       END IF;


       WHILE (items_in_current_absl_cur%FOUND) LOOP

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.absitem'
                        ,'Current Absorption level item:' || items_in_current_absl_row.inventory_item_id
                        );
        END IF;

        -- ==================================================================================================
        -- Check whether the retrieved item has child items which is in higher absorption level than
        -- its retrieved parent item.  If so, then bump up the absorption level of the retrieved item
        -- one level up than its child item
        -- Criteria: Parent item should always have the higher absorption level (lower absorption level code)
        -- than all of its child items
        -- ==================================================================================================
	SELECT  min(cpiac.absorption_level_code) min_child_absl_level_code
	INTO l_min_child_absl_level_code
        FROM cst_pac_itms_absl_codes cpiac
        WHERE cpiac.pac_period_id  = p_period_id
        AND cpiac.inventory_item_id IN (SELECT DISTINCT cpet.component_item_id
                                    FROM cst_pac_explosion_temp cpet
                                   WHERE cpet.pac_period_id  = cpiac.pac_period_id
                                     AND cpet.assembly_item_id = items_in_current_absl_row.inventory_item_id
				     AND cpet.component_item_id <> cpet.assembly_item_id
                                  );

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.minchildabslv'
                          ,'Highest absorption level across its child items:' || l_min_child_absl_level_code
                          );
          END IF;

        -- Check whether the absorption level of parent item is lower than or equal to its child item
        -- NOTE: Lower absorption level will have higher absorption level code
        IF l_absorption_level_code >= l_min_child_absl_level_code THEN

          -- bump up the absorption level of parent item
          l_reposition_absl_level_code := l_min_child_absl_level_code - 1;

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          ,G_MODULE_HEAD || l_routine || '.reposabslvcode'
                          ,'Reposition Absorption Level Code:' || l_reposition_absl_level_code || ' Item Id:' || items_in_current_absl_row.inventory_item_id
                          );
          END IF;

          UPDATE CST_PAC_ITMS_ABSL_CODES
             SET absorption_level_code = l_reposition_absl_level_code
           WHERE CURRENT OF items_in_current_absl_cur;
	   l_continue_loop_flag := 'Y';
        END IF;

      FETCH items_in_current_absl_cur
       INTO items_in_current_absl_row;

      END LOOP; -- items in current absorption level

      CLOSE items_in_current_absl_cur;

      l_absorption_level_code := l_absorption_level_code - 1;
    END LOOP; -- absorption level loop

  END LOOP; -- absorption loop count

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

END Get_Absorption_Level_Of_Items;

--========================================================================
-- PROCEDURE : Validate_Uncosted_Txns       PRIVATE
-- COMMENT   : This procedure validates for any uncosted transactions in
--           : all cost groups
--           : Procedure is invoked during run options 3 - resume for
--           : consecutive iterations
--========================================================================
PROCEDURE Validate_Uncosted_Txns
(p_legal_entity_id     IN NUMBER
,p_pac_period_id       IN NUMBER
,p_period_start_date   IN DATE
,p_period_end_date     IN DATE
)
IS

l_routine CONSTANT VARCHAR2(30) := 'validate_uncosted_txns';

-- Local Variables
l_pending_txns    BOOLEAN;
l_backdated_txns  BOOLEAN;
l_count_rows      NUMBER;

-- exceptions
l_pending_txns_except   EXCEPTION;
l_backdated_txns_except EXCEPTION;

BEGIN

  FND_FILE.put_line
  ( FND_FILE.log
  , '>> CST_PERIODIC_ABSORPTION_PROC:validate_uncosted_txns'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- initialize boolean variables
  l_pending_txns   := FALSE;
  l_backdated_txns := FALSE;
  l_count_rows     := 0;


  -- ===========================================================
  -- Validate Pending Transactions
  -- ===========================================================
  -- Check for pending rows in MMTT
  l_count_rows := 0;

SELECT	count(1)
  INTO  l_count_rows
  FROM	mtl_material_transactions_temp mmtt
 WHERE	NVL(mmtt.transaction_status,0) <> 2
   AND  CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(mmtt.organization_id) = 'Y'
   AND	mmtt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
   AND  ROWNUM = 1;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.pendmmtt'
                    ,'Pending Txns in MMTT:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_pending_txns := TRUE;
    RAISE l_pending_txns_except;
  END IF;


  -- Check for pending rows in MTI
  l_count_rows := 0;

SELECT	count(1)
INTO    l_count_rows
FROM	mtl_transactions_interface mti
WHERE	CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(mti.organization_id) = 'Y'
AND	mti.transaction_date BETWEEN p_period_start_date AND p_period_end_date
AND ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.pendmti'
                    ,'Pending Txns in MTI:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_pending_txns := TRUE;
    RAISE l_pending_txns_except;
  END IF;


  -- Check for pending rows in WCTI
  l_count_rows := 0;

SELECT	count(1)
  INTO  l_count_rows
  FROM	wip_cost_txn_interface wcti
 WHERE	CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(wcti.organization_id) = 'Y'
   AND	wcti.transaction_date BETWEEN p_period_start_date AND p_period_end_date
   AND  ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.pendwcti'
                    ,'Pending Txns in WCTI:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_pending_txns := TRUE;
    RAISE l_pending_txns_except;
  END IF;


  -- Check for pending rows in RTI
  l_count_rows := 0;

  SELECT  count(1)
  INTO    l_count_rows
  FROM    rcv_transactions_interface rti
  WHERE   rti.to_organization_code  IN
          (SELECT ood.organization_code
             FROM cst_organization_definitions ood
            WHERE CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(ood.organization_id) = 'Y'
          )
  AND     rti.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND     ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.pendrti'
                    ,'Pending Txns in RTI:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_pending_txns := TRUE;
    RAISE l_pending_txns_except;
  END IF;

  -- ========================================================
  -- Validate for backdated transactions
  -- ========================================================
  -- Check for backdated txns in MMT
  l_count_rows := 0;

  SELECT count(1)
  INTO   l_count_rows
  FROM   mtl_material_transactions mmt
  WHERE  mmt.creation_date > ( SELECT MIN(cppp.process_date)
                               FROM   cst_pac_process_phases cppp
                               WHERE
                                 (   (cppp.process_phase <= 4 OR cppp.process_phase = 7)
                                 AND cppp.process_upto_date IS NOT NULL)
                                 AND cppp.pac_period_id = p_pac_period_id
                                 AND CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group(cppp.cost_group_id) = 'Y'
                                 )
  AND    CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(mmt.organization_id) = 'Y'
  AND    mmt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND    ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.backmmt'
                    ,'Backdated Txns in MMT:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_backdated_txns := TRUE;
    RAISE l_backdated_txns_except;
  END IF;


  -- Check for backdated txns in WT
  l_count_rows := 0;

  SELECT  count(1)
  INTO    l_count_rows
  FROM    wip_transactions wt
  WHERE   wt.creation_date > ( SELECT MIN(cppp.process_date)
                               FROM   cst_pac_process_phases cppp
                               WHERE
                                 (   (cppp.process_phase <= 4 OR cppp.process_phase = 7)
                                 AND cppp.process_upto_date IS NOT NULL)
                                 AND cppp.pac_period_id = p_pac_period_id
                                 AND CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group(cppp.cost_group_id) = 'Y'
                                 )
  AND     CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(wt.organization_id) = 'Y'
  AND     wt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND     ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.backwt'
                    ,'Backdated Txns in WT:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_backdated_txns := TRUE;
    RAISE l_backdated_txns_except;
  END IF;


  -- Check for backdated txns in RT
  l_count_rows := 0;

SELECT  count(1)
INTO    l_count_rows
FROM    rcv_transactions rt
WHERE   rt.creation_date > (SELECT MIN(cppp.process_date)
                            FROM   cst_pac_process_phases cppp
                            WHERE
                              (   (cppp.process_phase <= 4 OR cppp.process_phase = 7)
                              AND cppp.process_upto_date IS NOT NULL)
                              AND cppp.pac_period_id = p_pac_period_id
                              AND CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group(cppp.cost_group_id) = 'Y'
                              )
AND     CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(rt.organization_id) = 'Y'
AND     rt.transaction_date BETWEEN p_period_start_date AND p_period_end_date
AND     ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.backrt'
                    ,'Backdated Txns in RT:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_backdated_txns := TRUE;
    RAISE l_backdated_txns_except;
  END IF;


  -- Check for backdated txns in RAE
  l_count_rows := 0;

  SELECT  count(1)
  INTO    l_count_rows
  FROM    rcv_accounting_events rae
  WHERE   rae.creation_date > ( SELECT MIN(cppp.process_date)
                                  FROM   cst_pac_process_phases cppp
                                 WHERE
                                   (  (cppp.process_phase <= 4 OR cppp.process_phase = 7)
                                   AND cppp.process_upto_date IS NOT NULL)
                                   AND cppp.pac_period_id = p_pac_period_id
                                   AND CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group(cppp.cost_group_id) = 'Y'
                                   )
  AND     CST_PAC_ITERATION_PROCESS_PVT.Check_Cst_Group_Org(rae.organization_id) = 'Y'
  AND     rae.transaction_date BETWEEN p_period_start_date AND p_period_end_date
  AND     rae.event_type_id IN (7,8, 9, 10)
  AND     ROWNUM = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.backrae'
                    ,'Backdated Txns in RAE:' || l_count_rows
                    );
    END IF;

  IF (l_count_rows <> 0) THEN
    l_backdated_txns := TRUE;
    RAISE l_backdated_txns_except;
  END IF;


  FND_FILE.put_line
  ( FND_FILE.log
  , '<< CST_PERIODIC_ABSORPTION_PROC:validate_uncosted_txns'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;


EXCEPTION
WHEN l_pending_txns_except THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.pendtxn1_exc'
                  , 'Pending Trasactions exist. Process all the pending transactions by import through applications interface'
                  );
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.pendtxn2_exc'
                  , 'Rerun the processor with run options Start'
                  );
  END IF;

  FND_MESSAGE.Set_Name('BOM', 'CST_PAC_PENDING_TXN');
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

WHEN l_backdated_txns_except THEN
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine || '.backdated_exc'
                  , 'Backdated Trasactions exist. Rerun the processor with run options Start');
  END IF;

  FND_MESSAGE.Set_Name('BOM', 'CST_PAC_BACKDATED_TXN');
  FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;


END Validate_Uncosted_Txns;

-- =======================================================================
-- PROCEDURE  : Insert_Ending_Balance_All_Cgs       PRIVATE
-- COMMENT    : This procedure invokes CSTPPWAC.insert_ending_balance for
--            : each cost group
--            : Inserts to CPPB from CPIC, CPICD, CPQL at the end of PAC
--            : Period
-- =======================================================================
PROCEDURE Insert_Ending_Balance_All_Cgs
(p_pac_period_id    IN  NUMBER
,p_cg_tab           IN  CST_PERIODIC_ABSORPTION_PROC.tbl_type
,p_end_date         IN  DATE
,p_user_id          IN  NUMBER
,p_login_id         IN  NUMBER
,p_req_id           IN  NUMBER
,p_prg_id           IN  NUMBER
,p_prg_appid        IN  NUMBER
)
IS

-- routine name local constant variable
l_routine CONSTANT VARCHAR2(30) := 'Insert_Ending_Balance_All_Cgs';

l_error_num         NUMBER;
l_error_code        VARCHAR2(240);
l_error_msg         VARCHAR2(240);

l_cg_idx  BINARY_INTEGER;

BEGIN

  FND_FILE.put_line
  ( FND_FILE.log
  , '>> CST_PERIODIC_ABSORPTION_PROC.Insert_Ending_Balance_All_Cgs'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- ============================================================
  -- for each cost group, insert into CPPB from CPIC, CPICD, CPQL
  -- ============================================================
  l_cg_idx := p_cg_tab.FIRST;
  LOOP
    CSTPPWAC.insert_ending_balance(i_pac_period_id   => p_pac_period_id
                                  ,i_cost_group_id   => p_cg_tab(l_cg_idx).cost_group_id
                                  ,i_user_id         => p_user_id
                                  ,i_login_id        => p_login_id
                                  ,i_request_id      => p_req_id
                                  ,i_prog_id         => p_prg_id
                                  ,i_prog_appl_id    => p_prg_appid
                                  ,o_err_num         => l_error_num
                                  ,o_err_code        => l_error_code
                                  ,o_err_msg         => l_error_msg
                                  );

   l_error_num  := NVL(l_error_num,0);
   l_error_code := NVL(l_error_code, 'No Error');
   l_error_msg  := NVL(l_error_msg, 'No Error');

     IF l_error_num <> 0 THEN
       FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
       FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
       FND_MESSAGE.set_token('MESSAGE', 'Error in CSTPPWAC.insert_ending_balance for cost group id '||p_cg_tab(l_cg_idx).cost_group_id||' ( '||l_error_code||' ) '||l_error_msg);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  EXIT WHEN l_cg_idx = p_cg_tab.LAST;

  l_cg_idx := p_cg_tab.NEXT(l_cg_idx);

  END LOOP;

  FND_FILE.put_line
  ( FND_FILE.log
  , '<< CST_PERIODIC_ABSORPTION_PROC.Insert_Ending_Balance_All_Cgs'
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
END Insert_Ending_Balance_All_Cgs;

--=========================================================================
-- FUNCTION : Check_For_No_Interorg_CG  PRIVATE
-- COMMENT  : This function checks for non interorg cost groups
--            by validating against CST_PAC_INTORG_ITMS_TEMP table
--            CST_PAC_INTORG_ITMS_TEMP contains inventory items and Cost
--            Groups which have only valid interorg txns across cost groups
--            Cost Groups which have no vaid interorg txns are NOT present
--            in this table
--            This function is used to get those non-interorg cost groups
--            for which PCU - value change txns have to be processed.
--=========================================================================
FUNCTION Check_For_No_Interorg_CG
(p_period_id           IN NUMBER
,p_cost_group_id       IN NUMBER
,p_inventory_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
l_routine CONSTANT VARCHAR2(30) := 'Check_For_No_Interorg_CG';

-- Cursor to check for the cost group with any interorg transaction
CURSOR c_non_interorg_cg_cur(c_pac_period_id     NUMBER
                            ,c_cost_group_id     NUMBER
			    ,c_inventory_item_id NUMBER
                            )
IS
  SELECT 'X'
    FROM CST_PAC_INTORG_ITMS_TEMP
   WHERE pac_period_id     = c_pac_period_id
     AND cost_group_id     = c_cost_group_id
     AND inventory_item_id = c_inventory_item_id;

l_present_cg VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_HEAD || l_routine || '.begin'
                    , l_routine || '<'
                    );
  END IF;

  OPEN c_non_interorg_cg_cur(p_period_id
                            ,p_cost_group_id
			    ,p_inventory_item_id
			    );


  FETCH c_non_interorg_cg_cur
   INTO l_present_cg;

  IF c_non_interorg_cg_cur%FOUND THEN
    -- Cost Group has valid interorg txns and therefore
    -- this cost group should not be processed under non-interorg
    -- cost group
    l_present_cg := 'N' ;
  ELSE
    -- Cost Group has NO valid interorg txns and therefore
    -- require to be processed under non-interorg cost group
    l_present_cg := 'Y';
  END IF;

  CLOSE c_non_interorg_cg_cur;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_HEAD || l_routine || '.prcg'
                    , 'Non-Interorg Cost Group(Y/N):' || p_cost_group_id || '  ' || l_present_cg
                    );
   END IF;

  RETURN l_present_cg;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    ,G_MODULE_HEAD || l_routine || '.end'
                    ,l_routine || '>'
                    );
  END IF;

END Check_For_No_Interorg_CG;


--=========================================================================
-- PROCEDURE : Absorption_Cost_Process     PRIVATE
-- COMMENT   : This procedure processes all the
--           : cost owned transactions for item transactions
--           : that belong to the legal entity/cost type
--           : association.
--           : This is a preliminary step before calling the iterative
--           : procedure that processes the interorg transactions.
--           : Rollup for all items by BOM level
--=========================================================================
PROCEDURE Absorption_Cost_Process
(p_period_id              IN NUMBER
,p_prev_period_id         IN NUMBER
,p_legal_entity           IN NUMBER
,p_cost_type_id           IN NUMBER
,p_cg_tab                 IN CST_PERIODIC_ABSORPTION_PROC.tbl_type
,p_run_options            IN NUMBER
,p_number_of_iterations   IN NUMBER
,p_cost_method            IN NUMBER
,p_start_date             IN DATE
,p_end_date               IN DATE
,p_pac_rates_id           IN NUMBER
,p_mat_relief_algorithm   IN NUMBER
,p_uom_control            IN NUMBER
,p_tolerance              IN NUMBER
,p_user_id                IN NUMBER
,p_login_id               IN NUMBER
,p_req_id                 IN NUMBER
,p_prg_id                 IN NUMBER
,p_prg_appid              IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'absorption_cost_process';


-- Cursor retrieve items in the current absorption level code
-- where the items are unprocessed
CURSOR items_in_cur_absl_level_cur(c_pac_period_id         NUMBER
                                  ,c_absorption_level_code NUMBER
                                  )
IS
SELECT
  inventory_item_id
FROM cst_pac_itms_absl_codes
WHERE pac_period_id         = c_pac_period_id
  AND absorption_level_code = c_absorption_level_code
  AND process_flag          = 'N';

cursor c_low_level_code_cur(c_pac_period_id     NUMBER
                           ,c_inventory_item_id NUMBER
                           )
IS
SELECT  low_level_code
FROM cst_pac_low_level_codes
WHERE pac_period_id      = c_pac_period_id
  AND inventory_item_id  = c_inventory_item_id
  AND rownum = 1;

-- Cursor to obtain pac low level code at each cost group
cursor c_low_level_code_cg_cur(c_pac_period_id     NUMBER
                              ,c_cost_group_id     NUMBER
                              ,c_inventory_item_id NUMBER
                              )
IS
SELECT
  low_level_code
FROM cst_pac_low_level_codes
WHERE pac_period_id      = c_pac_period_id
  AND cost_group_id      = c_cost_group_id
  AND inventory_item_id  = c_inventory_item_id;


--=================
-- VARIABLES
--=================

l_current_level_code          NUMBER;
l_inventory_item_id           NUMBER;
l_tol_item_flag               NUMBER;
l_tolerance_flag              NUMBER;
l_item_idx                    BINARY_INTEGER;
l_interorg_item_flag          NUMBER;
l_assembly_processed_flag     VARCHAR2(1);
l_assembly_item               VARCHAR2(1);
l_run_options                 NUMBER;
l_inventory_item_number       VARCHAR2(1025);
l_interorg_non_tol_lp_cnt     NUMBER;
l_low_level_code              NUMBER := 0;

l_topmost_absl_level_code     NUMBER;
l_lowest_absl_level_code      NUMBER;
l_message                     VARCHAR2(2000);


-- Variables for Iteration Process
l_init_msg_list            VARCHAR2(1) := FND_API.G_TRUE;
l_validation_level         NUMBER      := FND_API.G_VALID_LEVEL_FULL;
l_iteration_proc_flag      VARCHAR2(1);

l_cg_idx                   BINARY_INTEGER;
l_cost_update_type         NUMBER;

-- FP Bug 7674673 fix
l_non_interorg_cg_check       VARCHAR2(1);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Initialize Global PL/SQL tables used in PAC interorg
  -- iteration process for each run
  CST_PAC_ITERATION_PROCESS_PVT.Initialize
                                 (p_legal_entity_id   => p_legal_entity
                                 );
  -- TAB is used as a delimiter in output which can be viewed in spreadsheet application to see the progress through iterations.
  FND_MESSAGE.Set_Name('BOM', 'CST_PAC_OUTPUT_MESSAGE');
  l_message := FND_MESSAGE.Get;
  FND_FILE.put_line(FND_FILE.OUTPUT, l_message);

  FND_MESSAGE.Set_Name('BOM', 'CST_PAC_PMAC_ITR_PROMPT');
  l_message := FND_MESSAGE.Get;
  FND_FILE.put_line(FND_FILE.OUTPUT, l_message);
  /* Storing the translated messages in global variable since in CST_PAC_ITERATION_PROCESS_PVT.Verify_Tolerance_Of_Item
  it need not be translated for each item */
  FND_MESSAGE.SET_NAME('BOM', 'CST_PAC_INTORG_TOLERANCE');
  CST_PAC_ITERATION_PROCESS_PVT.G_TOL_ACHIEVED_MESSAGE := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('BOM', 'CST_PAC_INTORG_NO_TOL');
  CST_PAC_ITERATION_PROCESS_PVT.G_TOL_NOT_ACHIEVED_MESSAGE := FND_MESSAGE.GET;

  -- Get the iteration process flag to check whether an iteration is an
  -- optional process

  SELECT    nvl(iteration_proc_flag,'N')
  INTO l_iteration_proc_flag
  FROM cst_le_cost_types
  WHERE legal_entity = p_legal_entity
  AND cost_type_id = p_cost_type_id;

  IF (p_run_options = 1 OR p_run_options = 2) THEN

    -- ===============================================================
    -- Determine Absorption Level Code of all items across cost groups
    -- ===============================================================
      Get_Absorption_Level_Of_Items(p_period_id         => p_period_id
                                   ,p_legal_entity_id   => p_legal_entity
                                   ,p_period_start_date => p_start_date
                                   ,p_period_end_date   => p_end_date
                                   );

      -- Assign Absorption Level Code to Interorg Items
	 UPDATE CST_PAC_INTORG_ITMS_TEMP cpiit
	 SET cpiit.absorption_level_code =
               (SELECT absorption_level_code
                  FROM cst_pac_itms_absl_codes
                 WHERE pac_period_id     = cpiit.pac_period_id
                   AND inventory_item_id = cpiit.inventory_item_id
               )
	WHERE cpiit.pac_period_id = p_period_id;

  END IF; -- resume option Start

  -- ===============================================================
  -- Check for uncosted transactions when run options is resume for
  -- consecutive iterations
  -- To prevent the consecutive iterations when uncosted txn exists
  -- ===============================================================
  IF p_run_options = 3 THEN
    Validate_Uncosted_Txns(p_legal_entity_id   => p_legal_entity
                          ,p_pac_period_id     => p_period_id
                          ,p_period_start_date => p_start_date
                          ,p_period_end_date   => p_end_date
                          );
  END IF;


  -- ========================================================================
  -- Get topmost absorption level across all items
  -- NOTE: for no completion items topmost absorption level code will be 1000
  -- ========================================================================
  SELECT  NVL(min(absorption_level_code),1000)
  INTO l_topmost_absl_level_code
  FROM cst_pac_itms_absl_codes
  WHERE pac_period_id = p_period_id;

  -- ========================================
  -- initialize the starting Absorption level
  -- ========================================
  -- get the lowermost absorption level when the
  -- run options 3 - Resume or 4 - Final
  IF p_run_options = 3 OR p_run_options = 4 THEN

	SELECT  NVL(max(absorption_level_code),1000)
	 INTO l_lowest_absl_level_code
	FROM cst_pac_itms_absl_codes
	WHERE pac_period_id = p_period_id
	  AND process_flag  = 'N';
  ELSE
	  -- run options 1 - start or 2 - error
	  l_lowest_absl_level_code   := 1000;
  END IF;

  -- ===================================================
  -- Periodic Absorption Rollup across absorption levels
  -- ===================================================

  -- Set run options variable
  l_run_options := p_run_options;

    -- Initialize interorg items in LOOP count which have not achieved tolerance
    l_interorg_non_tol_lp_cnt := 0;



  FOR l_current_level_idx IN REVERSE l_topmost_absl_level_code .. l_lowest_absl_level_code LOOP

	-- Purge private pl/sql table G_ITEM_LEVEL_TBL containing previous level items
	CST_PERIODIC_ABSORPTION_PROC.G_ITEM_LEVEL_TBL.DELETE;

	l_current_level_code := l_current_level_idx;

	-- Display current BOM level code
	IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT
                        , G_MODULE_HEAD || l_routine || '.currentabslevel'
                        , 'Current absorption Level Code:' || l_current_level_code
                        );
	 END IF;

	-- ================================================================
	-- Retrieve all items in the current absorption level
	-- Store the item and its absorption in private pl/sql table
	-- G_ITEM_LEVEL_TBL
	-- ================================================================

	OPEN items_in_cur_absl_level_cur(p_period_id
                                    ,l_current_level_code
                                    );
	FETCH items_in_cur_absl_level_cur BULK COLLECT INTO G_ITEM_LEVEL_TBL;
	CLOSE items_in_cur_absl_level_cur;

	-- Initialize interorg item non tolerance counter
	-- counter for the non tolerance interorg items in each absorption level
	l_interorg_non_tol_lp_cnt := 0;

	-- =========================================================================
	-- Perform Absorption Process in the current absorption level
	-- =========================================================================
	 l_item_idx := G_ITEM_LEVEL_TBL.FIRST;

    WHILE (l_item_idx  <= G_ITEM_LEVEL_TBL.LAST) LOOP

	    l_inventory_item_id := G_ITEM_LEVEL_TBL(l_item_idx).inventory_item_id;
	    l_inventory_item_number := Get_Item_Number(l_inventory_item_id);

	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_HEAD || l_routine ||'.item'
                          , 'Inventory Item Id:' || l_inventory_item_id ||
                            ' Item Number:' || l_inventory_item_number
                          );
            END IF;
	     -- Check whether an item is an interorg item
	    SELECT count(1)
	    INTO
	      l_interorg_item_flag
	    FROM
	      cst_pac_intorg_itms_temp
	    WHERE inventory_item_id     = l_inventory_item_id
	      AND pac_period_id         = p_period_id
	      AND absorption_level_code = l_current_level_code
	      AND rownum = 1;

	    -- initialize completion item flag
	    IF l_current_level_code = 1000 THEN
	        /* assembly items with completion/scrap/return might appear with LLC of 1000 */
	        OPEN c_low_level_code_cur(p_period_id
                                         ,l_inventory_item_id
                                         );
                FETCH c_low_level_code_cur
                INTO l_low_level_code;

                IF c_low_level_code_cur%FOUND THEN
 	             l_assembly_item := 'Y';
		ELSE
	             -- No completion item
                     -- No WIP assembly transaction exists, nothing to process
	             -- set the flag to already processed to avoid Group 1' invoke
	             l_assembly_item := 'N';
                END IF;
		CLOSE c_low_level_code_cur;
	    ELSE
	        l_assembly_item := 'Y';
	    END IF;

	    IF (l_interorg_item_flag = 1 AND l_assembly_item = 'Y') THEN

	        -- completion item and interorg item
	        -- maximum iteration count of the current absorption level interorg item
	        -- iteration count should be 0 for first time invoke
		-- l_wip_assembly_process_flag indicates whether wip completion txns are already processed or not
		  SELECT  decode(max(iteration_count), 0, 'N', 'Y')
		        INTO l_assembly_processed_flag
		  FROM
			cst_pac_intorg_itms_temp
		  WHERE pac_period_id       = p_period_id
		  AND absorption_level_code = l_current_level_code
		  AND inventory_item_id     = l_inventory_item_id;

	    ELSIF l_interorg_item_flag = 0 THEN
		-- completion, non interorg item
		 -- it means very first process
		  -- set wip assembly already processed flag to N
		l_assembly_processed_flag := 'N';

	    END IF;

       IF l_assembly_processed_flag = 'N' THEN
	         -- first time execution for the current absorption level item

		  -- ===============================================================================
		  -- Process WIP Assembly, WIP Issue transactions and PCU value change for all items
		  -- at this level in each cost group
		  -- Process non-rework assembly txns
		  -- PCU value change txns by level
		  -- Process rework issue and assembly txns
		  -- NOTE: An item may exist in different levels across cost groups
		  -- ===============================================================================
		Process_Comp_Items
		        (p_legal_entity         => p_legal_entity
                        ,p_cost_type_id         => p_cost_type_id
                        ,p_cost_method          => p_cost_method
                        ,p_period_id            => p_period_id
                        ,p_start_date           => p_start_date
                        ,p_end_date             => p_end_date
                        ,p_prev_period_id       => p_prev_period_id
                        ,p_cg_tab               => p_cg_tab
                        ,p_inventory_item_id    => l_inventory_item_id
                        ,p_uom_control          => p_uom_control
                        ,p_pac_rates_id         => p_pac_rates_id
                        ,p_mat_relief_algorithm => p_mat_relief_algorithm
                        ,p_user_id              => p_user_id
                        ,p_login_id             => p_login_id
                        ,p_req_id               => p_req_id
                        ,p_prg_id               => p_prg_id
                        ,p_prg_appid            => p_prg_appid
                        );

       END IF; -- check to execute first time in each absorption level

       -- Perform Iteration Process only for an interorg item
       -- NOTE:
       IF l_interorg_item_flag = 1 THEN

		      -- =======================================================================
	              -- Perform Item Iteration LOOP
		      -- Item --> Iteration --> Optimal Seq cost Group --> interorg Transactions
		      -- Item --> Iteration_Process
		      -- =======================================================================
		 CST_PAC_ITERATION_PROCESS_PVT.Iteration_Process
		       (p_init_msg_list           => l_init_msg_list
		       ,p_validation_level        => l_validation_level
		       ,p_legal_entity_id         => p_legal_entity
		       ,p_cost_type_id            => p_cost_type_id
		       ,p_cost_method             => p_cost_method
		       ,p_iteration_proc_flag     => l_iteration_proc_flag
		       ,p_period_id               => p_period_id
		       ,p_start_date              => p_start_date
		       ,p_end_date                => p_end_date
		       ,p_inventory_item_id       => l_inventory_item_id
		       ,p_inventory_item_number   => l_inventory_item_number
		       ,p_tolerance               => p_tolerance
		       ,p_iteration_num           => p_number_of_iterations
		       ,p_run_options             => l_run_options
		       ,p_pac_rates_id            => p_pac_rates_id
		       ,p_uom_control             => p_uom_control
		       ,p_user_id                 => p_user_id
		       ,p_login_id                => p_login_id
		       ,p_req_id                  => p_req_id
		       ,p_prg_id                  => p_prg_id
		       ,p_prg_appid               => p_prg_appid
		       );

       END IF; -- bug 7674673 fix iteration process only for interorg item

       -- ===================================================================
	-- Periodic Cost Update - Value Change for remaing cost groups
	-- for which no valid interorg txns exists.
	-- FP Bug 7674673 fix:
	-- Scenario: If l_interorg_item_flag is 1, atleast there is a
	-- cost group for which interorg txn exists.   There may be cost
	-- groups for which no interorg txns exists for the inventory item
	-- , pac period which have to be processed for the PCU - value
	-- change transactions, even though the interorg flag is 1 which
	-- indicates a presence of an interorg txn in any of the cost groups.
	-- Therefore, if l_interorg_item_flag is 1, check for
	-- non-interorg cost group to process for PCU - value change txns.
	-- Table: CST_PAC_INTORG_ITMS_TEMP contains inventory items of
	-- those cost groups having only valid interorg txns or scenario with
	-- FOB:shipment
	-- Cost groups having no valid interorg txns do not exist in the
	-- interorg table and therefore cannot get processed in the
	-- iteration_process procedure.
	-- bug 7674673 fix : Separate IF condition necessary
	-- ===================================================================
	IF (p_run_options = 1 OR p_run_options = 2) AND l_interorg_item_flag = 1 THEN

	   l_cost_update_type := 2; -- PCU Value Change
	   l_cg_idx := p_cg_tab.FIRST;
	   LOOP

	     -- FP Bug 7674673 fix: check for non interorg cost group
	     -- Process PCU - value change only for those cost groups which have not
	     -- got processed in iteration_process procedure
             l_non_interorg_cg_check := Check_For_No_Interorg_CG
					(p_period_id         => p_period_id
	                                ,p_cost_group_id     => p_cg_tab(l_cg_idx).cost_group_id
					,p_inventory_item_id => l_inventory_item_id
					);


	     IF l_non_interorg_cg_check = 'Y' THEN

                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                                   ,G_MODULE_HEAD || l_routine || '.noncgid'
                                   ,'Non Interorg Cost Group Id:' || p_cg_tab(l_cg_idx).cost_group_id
		    	           );
		 END IF;


		    -- Get PAC Low Level Code for the Item in that cost group
	             OPEN c_low_level_code_cg_cur(p_period_id
                                                 ,p_cg_tab(l_cg_idx).cost_group_id
                                                 ,l_inventory_item_id
                                                 );
	             FETCH c_low_level_code_cg_cur
                      INTO l_low_level_code;

	             -- completion item in the cost group
	             -- note that an item can exist as a completion item in one cost group and
	             -- no completion in another cost group
	             IF c_low_level_code_cg_cur%NOTFOUND THEN
	               l_low_level_code := -1; -- no completion item
                     END IF;

	             CLOSE c_low_level_code_cg_cur;

		  -- Periodic Cost Update value change only for non-interorg items in
		  -- the cost group where the same item is an interorg item in other cost groups.
		  -- both completion and no completion items are included
		  CST_PERIODIC_ABSORPTION_PROC.Periodic_Cost_Update_By_Level
		  (p_period_id             => p_period_id
		  ,p_legal_entity          => p_legal_entity
		  ,p_cost_type_id          => p_cost_type_id
		  ,p_cost_group_id         => p_cg_tab(l_cg_idx).cost_group_id
		  ,p_inventory_item_id     => l_inventory_item_id
		  ,p_cost_method           => p_cost_method
		  ,p_start_date            => p_start_date
		  ,p_end_date              => p_end_date
		  ,p_pac_rates_id          => p_pac_rates_id
		  ,p_master_org_id         => p_cg_tab(l_cg_idx).master_org_id
		  ,p_uom_control           => p_uom_control
		  ,p_low_level_code        => l_low_level_code
		  ,p_txn_category          => 5
		  ,p_user_id               => p_user_id
		  ,p_login_id              => p_login_id
		  ,p_req_id                => p_req_id
		  ,p_prg_id                => p_prg_id
		  ,p_prg_appid             => p_prg_appid);


	     END IF; -- non-interorg check

	   EXIT WHEN l_cg_idx = p_cg_tab.LAST;

           l_cg_idx := p_cg_tab.NEXT(l_cg_idx);

           END LOOP; -- cost group loop


       ELSIF (p_run_options = 1 OR p_run_options = 2) AND l_interorg_item_flag = 0 THEN
         -- ============================================================================
         -- Periodic Cost Update - Value Change only for non-interorg items
         -- Process PCU - value change after processing all the cost owned transactions
         -- just before processing cost derived transactions
         -- ----------------------------------------------------------------------------
         -- Periodic Cost Update - Value Change for all cost groups when interorg
         -- item flag is 0.  This means none of the cost groups have any valid interorg
         -- txns including FOB:shipment kind of a scenario influencing the receiving
         -- cost group even when there is no interorg receipt in the receiving cost group
         -- ============================================================================
         l_cost_update_type := 2; -- PCU Value Change
	 l_cg_idx := p_cg_tab.FIRST;
	 LOOP
	       -- Get PAC Low Level Code for the Item in that cost group
	       OPEN c_low_level_code_cg_cur(p_period_id
                                           ,p_cg_tab(l_cg_idx).cost_group_id
                                           ,l_inventory_item_id
                                           );
	       FETCH c_low_level_code_cg_cur
                 INTO l_low_level_code;

	         -- completion item in the cost group
	         -- note that an item can exist as a completion item in one cost group and
	         -- no completion in another cost group
                 IF c_low_level_code_cg_cur%NOTFOUND THEN
	           l_low_level_code := -1; -- no completion item
                 END IF;

	       CLOSE c_low_level_code_cg_cur;

            -- Periodic Cost Update value change only for non-interorg items
            -- both completion and no completion items are included
            CST_PERIODIC_ABSORPTION_PROC.Periodic_Cost_Update_By_Level
            (p_period_id             => p_period_id
            ,p_legal_entity          => p_legal_entity
            ,p_cost_type_id          => p_cost_type_id
            ,p_cost_group_id         => p_cg_tab(l_cg_idx).cost_group_id
            ,p_inventory_item_id     => l_inventory_item_id
            ,p_cost_method           => p_cost_method
            ,p_start_date            => p_start_date
            ,p_end_date              => p_end_date
            ,p_pac_rates_id          => p_pac_rates_id
            ,p_master_org_id         => p_cg_tab(l_cg_idx).master_org_id
            ,p_uom_control           => p_uom_control
            ,p_low_level_code        => l_low_level_code
	    ,p_txn_category          => 5
            ,p_user_id               => p_user_id
            ,p_login_id              => p_login_id
            ,p_req_id                => p_req_id
            ,p_prg_id                => p_prg_id
            ,p_prg_appid             => p_prg_appid);

         EXIT WHEN l_cg_idx = p_cg_tab.LAST;

         l_cg_idx := p_cg_tab.NEXT(l_cg_idx);

         END LOOP; -- cost group loop


       END IF;


	   -- =====================================================================
	   -- Process Group 2 Transactions only when the tolerance achieved for an
	   -- interorg item in the current absorption level or pac item costs finalized
	   -- For non interorg items, process group 2 transactions
	   -- =====================================================================

	   IF (l_interorg_item_flag = 1 AND l_iteration_proc_flag = 'Y') THEN

	      -- Check whether tolerance achieved for an interorg item in the
	      -- current absorption level
	      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.string(FND_LOG.LEVEL_EVENT
                      , G_MODULE_HEAD || l_routine || '.check_nontol_items_lvl'
                      , 'Check whether tolerance achieved for the item'
                    );
	      END IF;

	      -- check the tolerance for an interorg item
	      -- l_tol_item_flag "Tolerance Not achieved for atleast one CG" = 1 "Tolerance achieved for all CGs" = 0
	      SELECT count(1)
	       INTO l_tol_item_flag
	      FROM cst_pac_intorg_itms_temp
	      WHERE pac_period_id     = p_period_id
	       AND inventory_item_id = l_inventory_item_id
	       AND tolerance_flag    = 'N'
	       AND rownum = 1;

	   END IF; -- interorg item and iteration process check



       -- ========================================================================
       -- Interorg items not achieved tolerance within a user specified
       -- number of iterations
       -- non tolerance item counter only when iteration process is enabled
       -- ========================================================================
       IF (l_interorg_item_flag = 1 AND l_tol_item_flag <> G_TOL_ACHIEVED_FORALL_CG
        AND l_iteration_proc_flag = 'Y') THEN
        l_interorg_non_tol_lp_cnt := l_interorg_non_tol_lp_cnt + 1;
       END IF;

      -- ==========================================================================
      -- tolerance achieved for an interorg item in the current absorption level.
      -- tolerance achieved either by matching receipts or finalizing pac item cost.
      -- Process Group 2 transactions only when the tolerance is either achieved
      -- or finalized for an interorg item OR first time execution for non interorg
      -- item provided iteration process should have been enabled
      -- If iteration process is not enabled, then process group 2 transactions
      -- without any further check
      -- ==========================================================================
      IF (l_interorg_item_flag = 1 AND l_tol_item_flag = G_TOL_ACHIEVED_FORALL_CG ) OR
         (l_interorg_item_flag = 0) OR (l_iteration_proc_flag = 'N' ) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_HEAD || l_routine || '.gp2txn'
                        , 'Processing WIP Issue and other group 2 transactions'
                        );
        END IF;

        Process_Gp2_Other_Txns
            (p_legal_entity          => p_legal_entity
            ,p_cost_type_id          => p_cost_type_id
            ,p_cost_method           => p_cost_method
            ,p_period_id             => p_period_id
            ,p_start_date            => p_start_date
            ,p_end_date              => p_end_date
            ,p_prev_period_id        => p_prev_period_id
            ,p_cg_tab                => p_cg_tab
            ,p_inventory_item_id     => l_inventory_item_id
            ,p_uom_control           => p_uom_control
            ,p_pac_rates_id          => p_pac_rates_id
            ,p_mat_relief_algorithm  => p_mat_relief_algorithm
            ,p_user_id               => p_user_id
            ,p_login_id              => p_login_id
            ,p_req_id                => p_req_id
            ,p_prg_id                => p_prg_id
            ,p_prg_appid             => p_prg_appid
            );

        -- Set the process flag to Y after processing
        -- other cost derived txns - group 2
        UPDATE CST_PAC_ITMS_ABSL_CODES
           SET process_flag  = 'Y'
         WHERE pac_period_id         = p_period_id
           AND inventory_item_id     = l_inventory_item_id
           AND absorption_level_code = l_current_level_code;

	--commit the processing.
        COMMIT;
      END IF; -- Group 2 processing criteria check


    l_item_idx := G_ITEM_LEVEL_TBL.NEXT(l_item_idx);


    END LOOP; --     WHILE (l_item_idx  <= G_ITEM_LEVEL_TBL.LAST) LOOP


    -- ====================================================================
    -- Check Run options is Final
    -- Run options Final is applicable only for the items in current level
    -- of absorption loop
    -- For the next levels of absorption loop, run options should be set to
    -- Resume
    -- ====================================================================
    IF l_run_options = 4 THEN
      -- set run options to resume for remaining absorption loops
      l_run_options := 3;
    END IF;

      -- ==================================================================
      -- Check for any interorg items in the current absorption level which
      -- have not yet acheived tolerance.
      -- Note that the counter will be incremented only when the iteration
      -- process flag is enabled
      -- ==================================================================
      IF l_interorg_non_tol_lp_cnt <> 0 THEN
        -- Set Periodic Absorption Cost Processor status to Resume
        -- Set process status to 5 - Resume for all the valid cost groups
        -- in Legal Entity
        CST_PAC_ITERATION_PROCESS_PVT.Set_Process_Status( p_legal_entity_id  => p_legal_entity
                                                        , p_period_id        => p_period_id
                                                        , p_period_end_date  => p_end_date
                                                        , p_phase_status     => 5
                                                        );

        -- Set Phase 5 status to 5 - Resume for all the CGs to display
        -- the Phase 7 status on the screen
        CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status
          ( p_legal_entity_id  => p_legal_entity
          , p_period_id        => p_period_id
          , p_period_end_date  => p_end_date
          , p_phase_status     => 5
          );

	FND_MESSAGE.Set_Name('BOM', 'CST_PAC_TOL_NOT_ACHIEVED');
	fnd_file.put_line(fnd_file.output, fnd_message.get);

        EXIT;

      END IF;


  END LOOP; --   FOR l_current_level_idx IN REVERSE l_topmost_absl_level_code .. l_lowest_absl_level_code LOOP

  -- ==========================
  -- Insert Ending Balance
  -- ==========================
  -- insert into CPPB only at the period end
  -- check to make sure that no repetitive insertions during start,resume,error or final run options
  IF (l_current_level_code = l_topmost_absl_level_code) AND (l_interorg_non_tol_lp_cnt = 0) THEN
    Insert_Ending_Balance_All_Cgs(p_pac_period_id   => p_period_id
                                 ,p_cg_tab          => p_cg_tab
                                 ,p_end_date        => p_end_date
                                 ,p_user_id         => p_user_id
                                 ,p_login_id        => p_login_id
                                 ,p_req_id          => p_req_id
                                 ,p_prg_id          => p_prg_id
                                 ,p_prg_appid       => p_prg_appid
                                 );
  END IF; -- insert into CPPB only at the period end


  -- Set the Phase status by considering the iteration process flag
  IF l_iteration_proc_flag = 'Y' THEN
    -- =====================================================================
    -- Check for tolerance achieved for all interorg items
    -- Interorg items should either be tolerance achieved or pac item
    -- costs finalized
    -- Set the interorg transfer cost process phase 7 status to 4 - Complete
    -- Set the periodic cost process phase 5 status to 1 - unprocessed
    -- =====================================================================

     SELECT  count(1)
     INTO l_tolerance_flag
     FROM cst_pac_intorg_itms_temp
     WHERE pac_period_id  = p_period_id
      AND tolerance_flag = 'N'
      AND rownum = 1;


      IF l_tolerance_flag = 0 THEN
        -- All the items are absorbed
        -- ====================================================================================
        -- Set Phase 7 status to 4 - complete for all valid cost groups
        -- Set Phase 5 status to 1 - unprocessed for all valid cost groups
        -- ====================================================================================
        CST_PAC_ITERATION_PROCESS_PVT.Set_Process_Status(p_legal_entity_id  => p_legal_entity
                                                        ,p_period_id        => p_period_id
                                                        ,p_period_end_date  => p_end_date
                                                        ,p_phase_status     => 4
                                                        );

        -- Set Phase 5 status to 1 - Un Processed for all the valid cost
        -- groups in Legal Entity
        CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity
                                                       ,p_period_id        => p_period_id
                                                       ,p_period_end_date  => p_end_date
                                                       ,p_phase_status     => 1
                                                       );



      END IF; -- tolerance check

  ELSE
    -- iteration process is not enabled; only default iteration
    -- ====================================================================================
    -- Set Phase 7 status to 4 - complete for all valid cost groups
    -- Set Phase 5 status to 1 - unprocessed for all valid cost groups
    -- ====================================================================================
    CST_PAC_ITERATION_PROCESS_PVT.Set_Process_Status(p_legal_entity_id  => p_legal_entity
                                                    ,p_period_id        => p_period_id
                                                    ,p_period_end_date  => p_end_date
                                                    ,p_phase_status     => 4
                                                    );

    -- Set Phase 5 status to 1 - Un Processed for all the valid cost
    -- groups in Legal Entity
    CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity
                                                   ,p_period_id        => p_period_id
                                                   ,p_period_end_date  => p_end_date
                                                   ,p_phase_status     => 1
                                                   );


  END IF; -- iteration process enabled check

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     -- Set Phase 7 Status to error
     CST_PAC_ITERATION_PROCESS_PVT.Set_Process_Status(p_legal_entity_id  => p_legal_entity
                                                    ,p_period_id        => p_period_id
                                                    ,p_period_end_date  => p_end_date
                                                    ,p_phase_status     => 3
                                                    );
     COMMIT;
     RAISE FND_API.G_EXC_ERROR;

 WHEN OTHERS THEN
    ROLLBACK;
    -- Set Phase 7 Status to error
    CST_PAC_ITERATION_PROCESS_PVT.Set_Process_Status(p_legal_entity_id  => p_legal_entity
                                                    ,p_period_id        => p_period_id
                                                    ,p_period_end_date  => p_end_date
                                                    ,p_phase_status     => 3
                                                    );
    COMMIT;
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Absorption_Cost_Process;

-- =======================================================================
-- PROCEDURE : Process_Logical_Txns  PRIVATE
-- COMMENT   : This procedure will process all logical transactions
--             Process consigned price update transactions
--             Drop Shipment / global procurement changes
--             Exclude OPM logical intransit receipts
-- =======================================================================
PROCEDURE process_logical_txns
( p_period_id        IN    NUMBER
, p_legal_entity_id  IN    NUMBER
, p_cost_type_id     IN    NUMBER
, p_cost_group_id    IN    NUMBER
, p_cost_method      IN    NUMBER
, p_master_org_id    IN    NUMBER
, p_uom_control      IN    NUMBER
, p_start_date       IN    DATE
, p_end_date         IN    DATE
, p_user_id          IN    NUMBER
, p_login_id         IN    NUMBER
, p_req_id           IN    NUMBER
, p_prg_id           IN    NUMBER
, p_prg_appid        IN    NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30)  := 'process_logical_txns';

-- Logical transaction cursor
CURSOR logical_txn_cur(c_cost_group_id  NUMBER
                      ,c_start_date     DATE
                      ,c_end_date       DATE
                      )
IS
SELECT
  mmt.transaction_id
, mmt.transaction_action_id
, mmt.transaction_source_type_id
, mmt.inventory_item_id
, mmt.primary_quantity
, mmt.organization_id
, nvl(mmt.transfer_organization_id,-1) transfer_organization_id
, mmt.subinventory_code
FROM
  mtl_material_transactions mmt
, cst_cost_group_assignments ccga
WHERE mmt.transaction_date BETWEEN c_start_date AND c_end_date
  AND ccga.organization_id = mmt.organization_id
  AND ccga.cost_group_id   = c_cost_group_id
  AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
  AND nvl(mmt.owning_tp_type,2) = 2
/* exclude OPM logical intransit receipts */
  AND mmt.transaction_action_id <> 15
/* Ensure that only logical transactions get picked up */
  AND ((nvl(mmt.logical_transaction,3) = 1
        AND mmt.parent_transaction_id IS NOT NULL
        AND nvl(mmt.logical_trx_type_code,6) <= 5)
      OR mmt.transaction_type_id = 20)
ORDER BY
  transaction_date
, transaction_id;

TYPE logical_txn_tab IS TABLE OF logical_txn_cur%ROWTYPE INDEX BY BINARY_INTEGER;
l_logical_txn_tab	logical_txn_tab;
l_empty_logical_txn_tab logical_txn_tab;

l_error_num   NUMBER;
l_error_code  VARCHAR2(240);
l_error_msg   VARCHAR2(240);
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;
logical_txn_except  EXCEPTION;


BEGIN

  FND_FILE.put_line
  ( FND_FILE.log
  , '>> CST_PERIODIC_ABSORPTION_PROC:process_logical_txns'
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  IF NOT logical_txn_cur%ISOPEN THEN
      OPEN logical_txn_cur(p_cost_group_id
                         ,p_start_date
                         ,p_end_date
                         );
  END IF;

  LOOP
        l_logical_txn_tab := l_empty_logical_txn_tab;
        FETCH logical_txn_cur BULK COLLECT INTO l_logical_txn_tab LIMIT l_batch_size;

	l_loop_count := l_logical_txn_tab.count;

	FOR i IN 1..l_loop_count
	LOOP
		    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.logical_txn1'
                      ,'logical transaction - Transaction Id:' || l_logical_txn_tab(i).transaction_id || ' Action Id:' || l_logical_txn_tab(i).transaction_action_id
                     );
		    END IF;

		    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                     ,G_MODULE_HEAD || l_routine || '.logical_txn2'
                     ,'Source Type Id:' || l_logical_txn_tab(i).transaction_source_type_id || ' inventory item id:' || l_logical_txn_tab(i).inventory_item_id
                     );
		    END IF;

		    CSTPPINV.cost_acct_events(i_pac_period_id      => p_period_id
				             ,i_legal_entity       => p_legal_entity_id
		                               ,i_cost_type_id       => p_cost_type_id
				               ,i_cost_group_id      => p_cost_group_id
		                               ,i_cost_method        => p_cost_method
				               ,i_txn_id             => l_logical_txn_tab(i).transaction_id
		                               ,i_item_id            => l_logical_txn_tab(i).inventory_item_id
				               ,i_txn_qty            => l_logical_txn_tab(i).primary_quantity
		                               ,i_txn_org_id         => l_logical_txn_tab(i).organization_id
				               ,i_master_org_id      => p_master_org_id
		                               ,i_uom_control        => p_uom_control
		                               ,i_user_id            => p_user_id
				               ,i_login_id           => p_login_id
		                               ,i_request_id         => p_req_id
				               ,i_prog_id            => p_prg_id
		                               ,i_prog_appl_id       => p_prg_appid
				               ,o_err_num            => l_error_num
		                               ,o_err_code           => l_error_code
				               ,o_err_msg            => l_error_msg
						);

		IF l_error_num <> 0 THEN
		        FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
		        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		        FND_MESSAGE.set_token('MESSAGE', 'CSTPPINV.cost_acct_events for cost group '||p_cost_group_id||' logical txn id '||l_logical_txn_tab(i).transaction_id
	                                 ||' item id '||l_logical_txn_tab(i).inventory_item_id||' org id '||l_logical_txn_tab(i).organization_id||' ('||l_error_code||') '||l_error_msg);
		        FND_MSG_PUB.Add;
			-- Set Phase 5 status to Error
		        CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity_id
			                                   ,p_period_id        => p_period_id
				                           ,p_period_end_date  => p_end_date
					                   ,p_phase_status     => 3
						           );
		        RAISE FND_API.G_EXC_ERROR;
	        END IF;


	END LOOP;
	EXIT WHEN logical_txn_cur%NOTFOUND;
      END LOOP; --	FETCH loop
    CLOSE logical_txn_cur;

  FND_FILE.put_line
  ( FND_FILE.log
  , '<< CST_PERIODIC_ABSORPTION_PROC:process_logical_txns'
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
END process_logical_txns;

--========================================================================
-- PROCEDURE : GET_OPEN_REQUESTS_COUNT
-- COMMENT   : Returns the number of Requests still running
--=======================================================================
FUNCTION GET_OPEN_REQUESTS_COUNT
 RETURN NUMBER
IS

l_count NUMBER := 0;
l_routine  CONSTANT  VARCHAR2(30) := 'get_open_requests_count';
-- Cursor to obtain the request status
CURSOR c_check_request_status(c_request_id NUMBER)
  IS
  SELECT phase_code
    FROM FND_CONCURRENT_REQUESTS
   WHERE request_id = c_request_id;

BEGIN

  FOR i IN 1 .. G_REQUEST_TABLE.COUNT
  LOOP
    IF G_REQUEST_TABLE(i).request_id is NOT NULL THEN

      IF NVL(G_REQUEST_TABLE(i).request_status , 'X') <> 'C' THEN

	OPEN c_check_request_status(G_REQUEST_TABLE(i).request_id);

        FETCH c_check_request_status
         INTO G_REQUEST_TABLE(i).request_status;

        CLOSE c_check_request_status;

	IF G_REQUEST_TABLE(i).request_status = 'C'
        THEN
            get_phase_status
                 ( p_pac_period_id       =>         G_REQUEST_TABLE(i).pac_period_id
		  ,p_phase               =>         8
                  ,p_cost_group_id       =>         G_REQUEST_TABLE(i).cost_group_id
                  ,x_status              =>         G_REQUEST_TABLE(i).phase_status
                 );

	    IF G_REQUEST_TABLE(i).phase_status = 3 THEN
	        FND_MESSAGE.Set_Name('BOM', 'CST_PAC_AVG_WORKER_ERROR');
	        FND_MESSAGE.set_token('CG_ID', G_REQUEST_TABLE(i).cost_group_id);
		FND_MESSAGE.set_token('REQUEST_ID', G_REQUEST_TABLE(i).request_id);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 ELSE
            l_count := l_count + 1;
        END IF;
      END IF;
     END IF;
  END LOOP;

  RETURN l_count ;

END GET_OPEN_REQUESTS_COUNT;

--========================================================================
-- PROCEDURE : Transfer_Cost_Processor_Worker     PUBLIC
-- COMMENT   : This procedure will process phases 1-4 for all transactions
--             and then process phase 7 for only interorg transactions
--=========================================================================
PROCEDURE transfer_cp_worker
( p_legal_entity           IN  NUMBER
, p_cost_type_id           IN  NUMBER
, p_cost_method            IN  NUMBER
, p_period_id              IN  NUMBER
, p_prev_period_id         IN  NUMBER
, p_tolerance              IN  NUMBER
, p_number_of_iterations   IN  NUMBER
, p_number_of_workers      IN  NUMBER
, p_cg_tab                 IN  CST_PERIODIC_ABSORPTION_PROC.tbl_type
, p_uom_control            IN  NUMBER
, p_pac_rates_id           IN  NUMBER
, p_mat_relief_algorithm   IN  NUMBER
, p_start_date             IN  DATE
, p_end_date               IN  DATE
, p_run_options            IN  NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'transfer_cp_worker';

--=================
-- VARIABLES
--=================

l_current_index      BINARY_INTEGER;
l_prg_appid          NUMBER;
l_prg_id             NUMBER;
l_req_id             NUMBER;
l_user_id            NUMBER;
l_login_id           NUMBER;
l_sleep_time         NUMBER       := 15;
-- Variables
l_phase7_status      NUMBER;
l_phase5_status      NUMBER;
l_return_code        NUMBER;
l_error_msg          VARCHAR2(255);
l_error_code         VARCHAR2(15);
l_error_num          NUMBER;
l_submit_req_id	     NUMBER;
l_worker_idx         NUMBER := 1;
l_message           VARCHAR2(2000);
-- Exceptions
lifo_cost_except  EXCEPTION;
wip_close_except  EXCEPTION;


BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  l_prg_appid := FND_GLOBAL.prog_appl_id;
  l_prg_id    := FND_GLOBAL.conc_program_id;
  l_req_id    := FND_GLOBAL.conc_request_id;
  l_user_id   := FND_GLOBAL.user_id;
  l_login_id  := FND_GLOBAL.login_id;

  G_REQUEST_TABLE.delete;

  l_current_index := p_cg_tab.FIRST;

  LOOP

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.cgid'
                      ,'Cost Group Id:' || p_cg_tab(l_current_index).cost_group_id
                      );
      END IF;

      IF p_run_options > 2 AND p_cg_tab(l_current_index).starting_phase < 5 THEN
           FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
           FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
           FND_MESSAGE.set_token('MESSAGE', 'Run Options Resume for Tolerance and Final cannot be chosen since the cost group '
	    ||p_cg_tab(l_current_index).cost_group_id||' has not completed one of previous phases');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF p_run_options < 3 AND (p_cg_tab(l_current_index).starting_phase < 5 OR p_cg_tab(l_current_index).starting_phase = 8) THEN
      --  submit concurrent request. Run Options should never be greater than 2 for these concurrent requests
      l_submit_req_id := FND_REQUEST.SUBMIT_REQUEST('BOM',
                               'CST_PAC_WORKER',
                               NULL,
                               NULL,
                               FALSE,
                               p_legal_entity,
			       p_cost_type_id,
			       p_cg_tab(l_current_index).master_org_id,
			       p_cost_method,
			       p_cg_tab(l_current_index).cost_group_id,
			       p_period_id,
			       p_prev_period_id,
			       p_cg_tab(l_current_index).starting_phase,
			       p_pac_rates_id,
			       p_uom_control,
			       p_start_date,
			       p_end_date
                              );
      COMMIT;
      IF (l_submit_req_id = 0) THEN
          l_message := fnd_message.get;
          FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	  FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
          FND_MESSAGE.set_token('MESSAGE', 'Unable to submit request for Iterative PAC Worker '||l_message);
          FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
      END IF;
      --  store the request id in G_REQUEST_TABLE
      fnd_file.put_line(FND_FILE.LOG, 'Request Id for Cost Group ' || p_cg_tab(l_current_index).cost_group_id ||' : '||l_submit_req_id);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      ,G_MODULE_HEAD || l_routine || '.reqId'
                      ,'Request '|| l_submit_req_id ||' submitted for Cost Group Id: ' || p_cg_tab(l_current_index).cost_group_id
                      );
      END IF;
      G_REQUEST_TABLE(l_worker_idx).request_id := l_submit_req_id;
      G_REQUEST_TABLE(l_worker_idx).pac_period_id := p_period_id;
      G_REQUEST_TABLE(l_worker_idx).cost_group_id := p_cg_tab(l_current_index).cost_group_id;
      l_worker_idx := l_worker_idx + 1;
    END IF;

    EXIT WHEN l_current_index = p_cg_tab.LAST;

    l_current_index := p_cg_tab.NEXT(l_current_index);

     LOOP
      IF GET_OPEN_REQUESTS_COUNT < p_number_of_workers THEN
                  EXIT;
      END IF;
      DBMS_LOCK.sleep(l_sleep_time);
     END LOOP;

  END LOOP;

  LOOP
      IF GET_OPEN_REQUESTS_COUNT = 0 THEN
                  EXIT;
      END IF;
      DBMS_LOCK.sleep(l_sleep_time);
  END LOOP;

  --========================================================================================
  -- To arrange different cost groups in incresing order of On Hand quantities for each item
  --========================================================================================

  CST_PAC_ITERATION_PROCESS_PVT.Process_Optimal_Sequence(p_period_id => p_period_id);

  -- ====================================================================
  -- Absorption Cost Rollup Process
  -- ====================================================================
  CST_PERIODIC_ABSORPTION_PROC.Absorption_Cost_Process
   (p_period_id                 => p_period_id
   ,p_prev_period_id            => p_prev_period_id
   ,p_legal_entity              => p_legal_entity
   ,p_cost_type_id              => p_cost_type_id
   ,p_cg_tab                    => p_cg_tab
   ,p_run_options               => p_run_options
   ,p_number_of_iterations      => p_number_of_iterations
   ,p_cost_method               => p_cost_method
   ,p_start_date                => p_start_date
   ,p_end_date                  => p_end_date
   ,p_pac_rates_id              => p_pac_rates_id
   ,p_mat_relief_algorithm      => p_mat_relief_algorithm
   ,p_uom_control               => p_uom_control
   ,p_tolerance                 => p_tolerance
   ,p_user_id                   => l_user_id
   ,p_login_id                  => l_login_id
   ,p_req_id                    => l_req_id
   ,p_prg_id                    => l_prg_id
   ,p_prg_appid                 => l_prg_appid);

  -- =============================================================================
  -- Invoke Phase 5 Processes
  -- If Cost Method is 4 - Incremental LIFO, call lifo_cost_processor
  -- Process all logical transactions Drop Shipment / Global Procurement changes
  -- Process WIP Close transactions
  -- =============================================================================

  -- Check for Phase 7 completion and Phase 5 not yet completed
  CST_PERIODIC_ABSORPTION_PROC.get_phase_status(p_pac_period_id => p_period_id
                                               ,p_phase         => 7
					       ,p_cost_group_id => NULL
                                               ,x_status        => l_phase7_status
                                               );
  -- Is Phase 7 complete
  IF l_phase7_status = 4 THEN
      -- ========================================================
      -- Process Phase 5 for all Cost Groups
      -- ========================================================

      -- Set Phase 5 status to 2 - Running for all Cost Groups
      CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity
                                                     ,p_period_id        => p_period_id
                                                     ,p_period_end_date  => p_end_date
                                                     ,p_phase_status     => 2
                                                     );

      l_current_index := p_cg_tab.FIRST;

      LOOP

        FND_FILE.put_line
        ( FND_FILE.log
        , 'Cost Group Id:' || p_cg_tab(l_current_index).cost_group_id
        );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.cgid'
                        ,'Cost Group Id:' || p_cg_tab(l_current_index).cost_group_id
                        );
        END IF;

        -- Call lifo_cost_processor only if cost method is 4 - Incremental LIFO
        IF p_cost_method = 4 THEN

          CST_MGD_LIFO_COST_PROCESSOR.Lifo_Cost_Processor
           (p_pac_period_id   => p_period_id
           ,p_cost_group_id   => p_cg_tab(l_current_index).cost_group_id
           ,p_cost_type_id    => p_cost_type_id
           ,p_user_id         => l_user_id
           ,p_login_id        => l_login_id
           ,p_req_id          => l_req_id
           ,p_prg_id          => l_prg_id
           ,p_prg_appl_id     => l_prg_appid
           ,x_retcode         => l_return_code
           ,x_errbuff         => l_error_msg
           ,x_errcode         => l_error_code
           );

           IF l_return_code <> 0 THEN
            FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
            FND_MESSAGE.set_token('MESSAGE', 'CST_MGD_LIFO_COST_PROCESSOR.Lifo_Cost_Processor for cost group '||
	                          p_cg_tab(l_current_index).cost_group_id||' ('||l_error_code||') '||l_error_msg);
            FND_MSG_PUB.Add;
	    -- Set Phase 5 status to Error
            CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity
                                                           ,p_period_id        => p_period_id
                                                           ,p_period_end_date  => p_end_date
                                                           ,p_phase_status     => 3
                                                           );
            RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

        -- Process Logical Transactions
        CST_PERIODIC_ABSORPTION_PROC.process_logical_txns
         (p_period_id          => p_period_id
         ,p_legal_entity_id    => p_legal_entity
         ,p_cost_type_id       => p_cost_type_id
         ,p_cost_group_id      => p_cg_tab(l_current_index).cost_group_id
         ,p_cost_method        => p_cost_method
         ,p_master_org_id      => p_cg_tab(l_current_index).master_org_id
         ,p_uom_control        => p_uom_control
         ,p_start_date         => p_start_date
         ,p_end_date           => p_end_date
         ,p_user_id            => l_user_id
         ,p_login_id           => l_login_id
         ,p_req_id             => l_req_id
         ,p_prg_id             => l_prg_id
         ,p_prg_appid          => l_prg_appid
         );

        -- Process all close jobs
        CSTPPWCL.process_wip_close_txns
         (p_pac_period_id          => p_period_id
         ,p_start_date             => p_start_date
         ,p_end_date               => p_end_date
         ,p_cost_group_id          => p_cg_tab(l_current_index).cost_group_id
         ,p_cost_type_id           => p_cost_type_id
         ,p_user_id                => l_user_id
         ,p_login_id               => l_login_id
         ,p_request_id             => l_req_id
         ,p_prog_id                => l_prg_id
         ,p_prog_app_id            => l_prg_appid
         ,x_err_num                => l_error_num
         ,x_err_code               => l_error_code
         ,x_err_msg                => l_error_msg
         );

         IF l_error_num <> 0 THEN
            FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
            FND_MESSAGE.set_token('MESSAGE', 'CSTPPWCL.process_wip_close_txns for cost group '||
	                          p_cg_tab(l_current_index).cost_group_id||' ('||l_error_code||') '||l_error_msg);
            FND_MSG_PUB.Add;
	    -- Set Phase 5 status to Error
            CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id  => p_legal_entity
                                                           ,p_period_id        => p_period_id
                                                           ,p_period_end_date  => p_end_date
                                                           ,p_phase_status     => 3
                                                           );
            RAISE FND_API.G_EXC_ERROR;
         END IF;


        EXIT WHEN l_current_index = p_cg_tab.LAST;

        l_current_index := p_cg_tab.NEXT(l_current_index);

      END LOOP;

      -- Set Phase 5 completion for all cost groups
      CST_PAC_ITERATION_PROCESS_PVT.Set_Phase5_Status(p_legal_entity_id => p_legal_entity
                                                     ,p_period_id       => p_period_id
                                                     ,p_period_end_date => p_end_date
                                                     ,p_phase_status    => 4
                                                     );
  END IF; -- Phase 7 check


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END transfer_cp_worker;

--========================================================================
-- PROCEDURE : Transfer_Cost_Processor_Manager     PUBLIC
-- COMMENT   : This procedure will perform the validation needed
--             prior to processing the inter-org transfer transactions
--=========================================================================
PROCEDURE  transfer_cp_manager
( p_legal_entity               IN NUMBER
, p_cost_type_id               IN NUMBER
, p_period_id                  IN NUMBER
, p_process_upto_date          IN VARCHAR2
, p_le_process_upto_date       IN VARCHAR2
, p_tolerance                  IN NUMBER
, p_number_of_iterations       IN NUMBER
, p_number_of_workers          IN NUMBER
, p_run_options                IN NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

l_routine CONSTANT VARCHAR2(30) := 'transfer_cp_manager';
--=================
-- CURSORS
--=================

  CURSOR cst_grp_csr_type IS
    SELECT
      ccg.cost_group_id cost_group_id
    , ccg.cost_group  cost_group
    FROM cst_cost_groups ccg
       , cst_le_cost_types clct
    WHERE ccg.legal_entity = clct.legal_entity
    AND clct.legal_entity  = p_legal_entity
    AND clct.cost_type_id  = p_cost_type_id;

  cst_grp_csr_row   cst_grp_csr_type%rowtype;


--=================
-- VARIABLES
--=================

l_count            NUMBER;
l_prev_period_id   NUMBER;
l_empty_cons_tab   tbl_type;
l_txn_tab          tbl_type;
l_current_index    BINARY_INTEGER := 0;
l_cost_method      NUMBER;
l_uom_control      NUMBER;
l_pac_rates_id     NUMBER;
l_start_date       DATE;
l_end_date         DATE;
l_prg_appid        NUMBER;
l_prg_id           NUMBER;
l_req_id           NUMBER;
l_user_id          NUMBER;
l_login_id         NUMBER;
l_run_options      NUMBER;

-- variable for tolerance achieve check
l_tol_achieve_flag      VARCHAR2(1);
l_inventory_item_id     NUMBER;

-- Material Relief Algorithm - R12 enhancement
l_mat_relief_algorithm  NUMBER;

-- Variables for Iteration Process
l_init_msg_list            VARCHAR2(1) := FND_API.G_TRUE;
l_validation_level         NUMBER      := FND_API.G_VALID_LEVEL_FULL;
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_error_msg                VARCHAR2(2000);

-- Variable for the pl/sql table l_txn_tab cost group index
l_cost_group_idx           BINARY_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

   -- Getting Program Information
  l_prg_appid := FND_GLOBAL.prog_appl_id;
  l_prg_id    := FND_GLOBAL.conc_program_id;
  l_req_id    := FND_GLOBAL.conc_request_id;
  l_user_id   := FND_GLOBAL.user_id;
  l_login_id  := FND_GLOBAL.login_id;

  l_run_options := p_run_options;

  -- Call procedure to check the validity of cost type,
  -- legal entity and their association

  CST_PERIODIC_ABSORPTION_PROC.validate_le_ct_association
   (p_legal_entity      => p_legal_entity
   ,p_cost_type_id      => p_cost_type_id);

  -- Call procedure to check that the current period is open
  -- legal entity and their association

  CST_PERIODIC_ABSORPTION_PROC.validate_period
   (p_legal_entity      => p_legal_entity
   ,p_cost_type_id      => p_cost_type_id
   ,p_period_id         => p_period_id);

  -- Validate that previous period has been closed
  CST_PERIODIC_ABSORPTION_PROC.validate_previous_period
   (p_legal_entity      => p_legal_entity
   ,p_cost_type_id      => p_cost_type_id
   ,p_period_id         => p_period_id
   ,x_prev_period_id    => l_prev_period_id);


  -- Find the cost method being used for this
  -- legal entity/cost type association
  -- It needs to be PAC

  CST_PERIODIC_ABSORPTION_PROC.find_cost_method
   (p_legal_entity      => p_legal_entity
   ,p_cost_type_id      => p_cost_type_id
   ,x_cost_method       => l_cost_method);

  -- Validate that the upto parameter
  -- falls within the boundaries of the period when
  -- run options is 1 - Start; for all other run
  -- options process upto date should be NULL

  -- Bug#4351270 fix: time zone validate for process upto date
  -- with respect to Legal Entity
    CST_PERIODIC_ABSORPTION_PROC.validate_process_upto_date
     (p_process_upto_date   => p_le_process_upto_date
     ,p_period_id           => p_period_id
     ,p_run_options         => p_run_options
     );

  -- Get Unit of Measure control level

  l_uom_control := CST_PERIODIC_ABSORPTION_PROC.get_uom_control_level;


  -- Find The Pac Rates and
  -- Material Relief Algorithm (introduced in R12)
  CST_PERIODIC_ABSORPTION_PROC.find_pac_rates_algorithm
   (p_legal_entity         => p_legal_entity
   ,p_cost_type_id         => p_cost_type_id
   ,x_pac_rates_id         => l_pac_rates_id
   ,x_mat_relief_algorithm => l_mat_relief_algorithm
   );

  -- Get the valid cost groups in a legal entity
  IF NOT cst_grp_csr_type%ISOPEN
  THEN
    OPEN cst_grp_csr_type;
  END IF;

  -- clear the pl/sql table before use
  l_txn_tab                := l_empty_cons_tab;

  FETCH cst_grp_csr_type
   INTO cst_grp_csr_row;

   -- Cost Group Id itself is the index
   l_cost_group_idx := cst_grp_csr_row.cost_group_id;
   l_txn_tab(l_cost_group_idx).cost_group_id := cst_grp_csr_row.cost_group_id;

  WHILE cst_grp_csr_type%FOUND
  LOOP

    FETCH cst_grp_csr_type
     INTO cst_grp_csr_row;

     l_cost_group_idx := cst_grp_csr_row.cost_group_id;
     l_txn_tab(l_cost_group_idx).cost_group_id := cst_grp_csr_row.cost_group_id;

  END LOOP;

  CLOSE cst_grp_csr_type;

  -- Find the Start and End dates for the current period
  -- period start date is obtained from cpp
  -- period end date is the user entered process upto date
  -- For run options 3 - resume for non tolerance and 4 - final iteration
  -- l_end_date will be null since the user will not enter any
  -- process upto date in the input parameter screen
  CST_PERIODIC_ABSORPTION_PROC.find_period_duration
   (p_legal_entity         => p_legal_entity
   ,p_cost_type_id         => p_cost_type_id
   ,p_period_id            => p_period_id
   ,p_process_upto_date    => p_process_upto_date
   ,x_start_date           => l_start_date
   ,x_end_date             => l_end_date);

  -- get process upto date for run options 3 - resume for non tolerance
  -- and 4 - final iteration
  IF l_run_options > 1 THEN

  l_end_date := CST_PERIODIC_ABSORPTION_PROC.Find_Prev_Process_Upto_Date
                  (p_pac_period_id  => p_period_id);
  END IF;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT
                      ,G_MODULE_HEAD || l_routine || '.dtrange'
                      ,'Date Range:' || TO_CHAR(l_start_date,'DD-MON-YYYY HH24:MI:SS') || ' ' || TO_CHAR(l_end_date,'DD-MON-YYYY HH24:MI:SS')
                      );
      END IF;

  l_current_index := l_txn_tab.FIRST;

  LOOP

    -- The following checks need to be made for each cost group

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,G_MODULE_HEAD || l_routine || '.cgid'
                    ,'Cost Group Id:' || l_txn_tab(l_current_index).cost_group_id
                    );
    END IF;

    -- Call procedure to validate current cost group

    CST_PERIODIC_ABSORPTION_PROC.validate_cost_groups
     (p_legal_entity      => p_legal_entity
     ,p_cost_type_id      => p_cost_type_id
     ,p_period_id         => p_period_id
     ,p_cost_group_id     => l_txn_tab(l_current_index).cost_group_id);

    -- Ensure all appropriate phases in the process phases table
    -- are seeded correctly

    CST_PERIODIC_ABSORPTION_PROC.validate_phases_seeded
     (p_cost_group_id     => l_txn_tab(l_current_index).cost_group_id
     ,p_period_id         => p_period_id);

    -- check that the cost group has assignments

    CST_PERIODIC_ABSORPTION_PROC.number_of_assignments
     (p_cost_group_id     => l_txn_tab(l_current_index).cost_group_id
     ,p_period_id         => p_period_id
     ,p_user_id           => l_user_id
     ,p_login_id          => l_login_id
     ,p_req_id            => l_req_id
     ,p_prg_id            => l_prg_id
     ,p_prg_appid         => l_prg_appid);

    -- Validate Master Organization

    CST_PERIODIC_ABSORPTION_PROC.validate_master_org
     (p_legal_entity      => p_legal_entity
     ,p_cost_type_id      => p_cost_type_id
     ,p_cost_group_id     => l_txn_tab(l_current_index).cost_group_id
     ,x_master_org_id     => l_txn_tab(l_current_index).master_org_id);

    -- Find the starting Phase for the current cost group and
    -- store it in a pl/sql table of record

    CST_PERIODIC_ABSORPTION_PROC.find_starting_phase
     (p_legal_entity      => p_legal_entity
     ,p_cost_type_id      => p_cost_type_id
     ,p_period_id         => p_period_id
     ,p_end_date          => l_end_date
     ,p_cost_group_id     => l_txn_tab(l_current_index).cost_group_id
     ,p_run_options       => l_run_options
     ,x_starting_phase    => l_txn_tab(l_current_index).starting_phase
     ,p_user_id           => l_user_id
     ,p_login_id          => l_login_id
     ,p_req_id            => l_req_id
     ,p_prg_id            => l_prg_id
     ,p_prg_appid         => l_prg_appid);

    FND_FILE.put_line
    ( FND_FILE.log
    , 'Cost Group Id:' || l_txn_tab(l_current_index).cost_group_id || ' ' ||
      'Starting Phase:' || l_txn_tab(l_current_index).starting_phase
    );

    EXIT WHEN l_current_index = l_txn_tab.LAST;

    l_current_index := l_txn_tab.NEXT(l_current_index);

  END LOOP;


    -- if the run option is 1 then this is the initial
    -- processing of these records.
    -- if the the run option is 3 then this is a resumption
    -- of processing after an error.

    CST_PERIODIC_ABSORPTION_PROC.transfer_cp_worker
     (p_legal_entity           => p_legal_entity
     ,p_cost_type_id           => p_cost_type_id
     ,p_cost_method            => l_cost_method
     ,p_period_id              => p_period_id
     ,p_prev_period_id         => l_prev_period_id
     ,p_tolerance              => p_tolerance
     ,p_number_of_iterations   => p_number_of_iterations
     ,p_number_of_workers      => p_number_of_workers
     ,p_cg_tab                 => l_txn_tab
     ,p_uom_control            => l_uom_control
     ,p_pac_rates_id           => l_pac_rates_id
     ,p_mat_relief_algorithm   => l_mat_relief_algorithm
     ,p_start_date             => l_start_date
     ,p_end_date               => l_end_date
     ,p_run_options            => l_run_options
     );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF l_error_msg IS NOT NULL THEN
    x_msg_data      := l_error_msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    FND_MSG_PUB.Count_And_Get
      (p_encoded  => FND_API.G_FALSE
      ,p_count    => x_msg_count
      ,p_data     => l_msg_data
      );
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := l_msg_data;
  END IF;

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine , x_msg_data
                  );
  END IF;

WHEN OTHERS THEN
  x_msg_data        := SQLCODE || substr(SQLERRM, 1, 200);
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get
      (p_encoded  => FND_API.G_FALSE
      ,p_count    => x_msg_count
      ,p_data     => l_msg_data
      );

  FND_FILE.put_line
  ( FND_FILE.log
  , 'Error in transfer_cp_manager '|| x_msg_data || '  ' || substr(l_msg_data, 1,250)
  );

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'others:' || x_msg_data || '  ' || substr(l_msg_data, 1,250)
                  );
  END IF;

END transfer_cp_manager;

END CST_PERIODIC_ABSORPTION_PROC;

/
