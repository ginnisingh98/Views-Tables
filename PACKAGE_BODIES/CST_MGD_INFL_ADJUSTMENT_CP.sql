--------------------------------------------------------
--  DDL for Package Body CST_MGD_INFL_ADJUSTMENT_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_INFL_ADJUSTMENT_CP" AS
/* $Header: CSTCIADB.pls 120.6 2006/02/26 22:44:36 vmutyala noship $ */

--================================
-- PRIVATE CONSTANTS AND VARIABLES
--================================
g_period_is_final_exc         EXCEPTION;
g_price_index_exc             EXCEPTION;

g_infl_index_value_null_exc   EXCEPTION;

G_MODULE_HEAD CONSTANT VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

--===================
-- PRIVATE PROCEDURES
--===================

--=========================================================================
-- PROCEDURE : Check_Inflation_Process_Run     PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             x_return_status         Return Status of procedure
-- COMMENT   : This procedure checks whether inflation adjustment processor
--             has been run for the organization in that accounting
--             period id
--             This procedure will use the status table:
--             CST_MGD_INFL_ADJ_PER_STATUSES
-- USAGE      : Used for validation in Transfer_to_GL Process
-- EXCEPTIONS: l_infl_processor_run_exc
--========================================================================
PROCEDURE Check_Inflation_Process_Run (
  p_org_id                  IN         NUMBER
, p_acct_period_id          IN         NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
)
IS
l_infl_processor_run_exc EXCEPTION;
l_process_count  NUMBER;

-- check if the inflation processor is run for the organization
-- in that accounting period range
CURSOR inflation_check_cur(c_org_id                  NUMBER
                          ,c_acct_period_id          NUMBER
                          )
IS
  SELECT
    COUNT(*)
  FROM cst_mgd_infl_adj_per_statuses
  WHERE organization_ID = c_org_id
    AND acct_period_id  = c_acct_period_id
    AND status = 'PROCESS';

BEGIN

  OPEN inflation_check_cur(p_org_id
                          ,p_acct_period_id
                          );

  FETCH inflation_check_cur
   INTO l_process_count;

  CLOSE inflation_check_cur;

  IF l_process_count = 0
  THEN
    -- Inflation Adjustment Processor not run yet
    RAISE l_infl_processor_run_exc;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN l_infl_processor_run_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INFL_PROCESSOR_RUN');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_Inflation_Process_Run'
                             );
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_Inflation_Process_Run'
                             );
    END IF;
    RAISE;

END Check_Inflation_Process_Run;


--========================================================================
-- PROCEDURE : Check_Period_Status     PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_org_id                Organization ID
--             p_acct_period_id        Account period ID
-- COMMENT   : This procedure checks if inflation adjustment for a
--             period is marked "FINAL"
-- EXCEPTIONS: g_period_is_final_exc   Period is final
--========================================================================
PROCEDURE Check_Period_Status (
  p_country_code   IN  VARCHAR2
, p_org_id         IN  NUMBER
, p_acct_period_id IN  NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'check_period_status';
l_status              NUMBER;
l_period_is_final_exc EXCEPTION;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- check if period has been adjusted and posted to GL
  SELECT
    COUNT(1)
  INTO
    l_status
  FROM
    CST_MGD_INFL_ADJ_PER_STATUSES a
  , ORG_ACCT_PERIODS b
  WHERE a.Organization_ID = p_org_id
    AND a.Acct_Period_ID  = p_acct_period_id
    AND a.Status          = 'FINAL'
    AND b.Acct_Period_ID  = p_acct_period_id
    AND b.Organization_ID = p_org_id
    AND b.Open_Flag       = 'N'
    AND b.Period_Close_Date IS NOT NULL;

  IF l_status > 0
  THEN
    RAISE l_period_is_final_exc;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  WHEN l_period_is_final_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_PERIOD_FINAL');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_Period_Status'
                             );
    END IF;
    RAISE g_period_is_final_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Check_Period_Status'
                             );
    END IF;
    RAISE;

END Check_Period_Status;


--========================================================================
-- PROCEDURE : Get_Inflation_Index_Value PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             p_inflation_index       Inflation index
--             x_inflation_index_value Inflation index value
-- COMMENT   : This procedure retrieves the inflation value (%) to be used
--             for adjustment from inflation index.
-- EXCEPTIONS: OTHERS
--========================================================================
PROCEDURE Get_Inflation_Index_Value (
  p_org_id                IN  NUMBER
, p_acct_period_id        IN  NUMBER
, p_inflation_index       IN  VARCHAR2
, x_inflation_index_value OUT NOCOPY NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_inflation_index_value';
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  SELECT
    Price_Index_Value/100
  INTO
    x_inflation_index_value
  FROM
    FA_PRICE_INDEX_VALUES a
  , FA_PRICE_INDEXES b
  , ORG_ACCT_PERIODS c
  WHERE c.Acct_Period_ID   = p_acct_period_id
    AND c.Organization_ID  = p_org_id
    AND b.Price_Index_Name = p_inflation_index
    AND a.Price_Index_ID   = b.Price_Index_ID
    AND a.From_Date        = c.Period_Start_Date
    AND a.To_Date          = c.Schedule_Close_Date
    AND c.Open_Flag        = 'N';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_PRICE_INDEX');
    FND_MSG_PUB.Add;
    RAISE g_price_index_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Inflation_Index_Value'
                             );
    END IF;
    RAISE;

END Get_Inflation_Index_Value;


--========================================================================
-- PROCEDURE : Get_valid_cost_group    PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             x_cost_group_id       valid cost group id
-- COMMENT   : Procedure to get the valid cost group
--========================================================================
PROCEDURE Get_valid_cost_group (
  p_org_id	     IN  NUMBER
 ,x_cost_group_id    OUT NOCOPY CST_COST_GROUPS.cost_group_id%TYPE
)
IS
l_routine CONSTANT VARCHAR2(30) := 'get_valid_cost_group';

-- get the default cost group
CURSOR c_default_cost_group_cur IS
  SELECT
    default_cost_group_id
   FROM MTL_PARAMETERS
  WHERE organization_id = p_org_id;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- Get the default cost group
  OPEN c_default_cost_group_cur;

  FETCH c_default_cost_group_cur
   INTO x_cost_group_id;

  CLOSE c_default_cost_group_cur;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END;


--========================================================================
-- PROCEDURE : Calculate_Adjustment    PRIVATE
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_org_id                Organization ID
--             p_country_code          Country code
--             p_acct_period_id        Account period ID
--             p_inflation_index       Inflation index
-- COMMENT   : This is the concurrent program for inflation adjustment.
--========================================================================
PROCEDURE Calculate_Adjustment (
  x_errbuf          OUT NOCOPY VARCHAR2
, x_retcode         OUT NOCOPY VARCHAR2
, p_org_id          IN  NUMBER
, p_country_code    IN  VARCHAR2
, p_acct_period_id  IN  NUMBER
, p_inflation_index IN  VARCHAR2
)
IS
l_routine CONSTANT VARCHAR2(30) := 'calculate_adjustment';

l_api_version_number        NUMBER := 1.0;
l_org_id                    NUMBER;
l_inv_item_id               NUMBER;
l_item_unit_avg_cost        NUMBER;
l_status                    NUMBER;
l_return_status             VARCHAR2(1);
l_last_closed_period_id     NUMBER;
l_last_adjusted_period_id   NUMBER;
l_last_acct_period_id       NUMBER;
l_inflation_index_value     NUMBER;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(100);
l_get_hist_data_flag        VARCHAR2(1);
l_prev_acct_period_id       NUMBER;
l_prev_sch_close_date       DATE;
l_curr_period_start_date    DATE;
l_curr_period_end_date      DATE;
l_profile_category_name     VARCHAR2(100);
l_category_id               VARCHAR2(100);
l_profile_category_set_name VARCHAR2(100);
l_category_set_id           VARCHAR2(100);
l_cost_group_id             CST_COST_GROUPS.cost_group_id%TYPE;
l_inflation_adjustment_rec
  CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type;
l_period_gap_exc            EXCEPTION;
l_period_is_missing_exc     EXCEPTION;
l_missing_hist_data_exc     EXCEPTION;

--Bug 3889172
l_wms_org_exc		    EXCEPTION;
l_wms_enabled_flag          VARCHAR2(1);

/* Bug 5026760 Non Mergeable View cst_per_close_dtls_v replaced by union on base tables */
CURSOR l_inv_items_csr(c_acct_period_id   NUMBER
                      ,c_organization_id  NUMBER
                      ,c_cost_group_id    NUMBER
                      ,c_category_set_id  NUMBER
                      ,c_category_id      NUMBER
                      ) IS
  SELECT
    DISTINCT inventory_item_id
  FROM
    cst_period_close_summary
  WHERE acct_period_id  = c_acct_period_id
    AND organization_id = c_organization_id
    AND cost_group_id   = c_cost_group_id
    AND CST_MGD_INFL_ADJUSTMENT_PVT.Infl_Item_Category(inventory_item_id
                                                      ,c_organization_id
                                                      ,c_category_set_id
                                                      ,c_category_id
                                                      ) = 'Y'
  UNION
  SELECT
    DISTINCT inventory_item_id
  FROM
    mtl_per_close_dtls
  WHERE acct_period_id  = c_acct_period_id
    AND organization_id = c_organization_id
    AND cost_group_id   = c_cost_group_id
    AND CST_MGD_INFL_ADJUSTMENT_PVT.Infl_Item_Category(inventory_item_id
                                                      ,c_organization_id
                                                      ,c_category_set_id
                                                      ,c_category_id
                                                      ) = 'Y';


-- debug level variables to use within loop
l_debug_level NUMBER;
l_state_level NUMBER;

BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                ,G_MODULE_HEAD || l_routine || '.begin'
                ,l_routine || '<'
                );
END IF;

-- initialize item category and item category set profile options
l_profile_category_name     := 'CST_MGD_INFL_ADJ_CTG';
l_profile_category_set_name := 'CST_MGD_INFL_ADJ_CTG_SET';

-- initialize debug level variables to use within loop
l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_state_level := FND_LOG.LEVEL_STATEMENT;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  -- Bug # 3889172 check if the Org is WMS enabled.
  SELECT WMS_ENABLED_FLAG
  INTO l_wms_enabled_flag
  FROM MTL_PARAMETERS
  WHERE ORGANIZATION_ID = p_org_id;

  IF l_wms_enabled_flag = 'Y' THEN
	RAISE l_wms_org_exc;
  END IF;

  CST_MGD_INFL_ADJUSTMENT_PVT.Check_Period_Close
  ( p_org_id         => p_org_id
  , p_acct_period_id => p_acct_period_id
  );

  -- Check if the inflation is posted to GL for the current period
  Check_Period_Status( p_country_code   => p_country_code
                     , p_org_id         => p_org_id
                     , p_acct_period_id => p_acct_period_id
                     );

  /* removed as part of bug#1474753 fix
  -- Check for historical data
  CST_MGD_INFL_ADJUSTMENT_PVT.Check_First_Time
  ( p_country_code       => p_country_code
  , p_org_id             => p_org_id
  , x_get_hist_data_flag => l_get_hist_data_flag
  );
  */


  -- Get previous account period id and scheduled close date.
  -- previous period obtained only if the previous period inflation
  -- is transferred to GL,otherwise returns null
  --
  CST_MGD_INFL_ADJUSTMENT_PVT.Get_Previous_Acct_Period_ID
  ( p_organization_id     => p_org_id
  , p_acct_period_id      => p_acct_period_id
  , x_prev_acct_period_id => l_prev_acct_period_id
  , x_prev_sch_close_date => l_prev_sch_close_date
  );


  -- Close date set to 23:59:59
  IF l_prev_sch_close_date IS NOT NULL THEN
    l_prev_sch_close_date := TRUNC(l_prev_sch_close_date) + (86399/86400);
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= l_debug_level) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.prevsch'
                  ,'Previous Acct Period Id:' || l_prev_acct_period_id || ' ' ||'Previous Schedule Close Date:' || TO_CHAR(l_prev_sch_close_date,'DD-MON-YYYY HH24:MI:SS')
                  );
  END IF;

  -- Get current period start date.
  CST_MGD_INFL_ADJUSTMENT_PVT.Get_Curr_Period_Start_Date
  ( p_org_id                 => p_org_id
  , p_acct_period_id         => p_acct_period_id
  , x_curr_period_start_date => l_curr_period_start_date
  , x_curr_period_end_date   => l_curr_period_end_date
  );


  -- From date is at midnight for the day
  -- bug#5012817 fix: remove canonical to date as it is already in
  -- date format
  l_curr_period_start_date := TRUNC(l_curr_period_start_date);

  -- The to date is at 23:59:59 of that date entered
  l_curr_period_end_date := TRUNC(l_curr_period_end_date) + (86399/86400);

  IF (FND_LOG.LEVEL_STATEMENT >= l_debug_level) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.curpddt'
                  ,'Current Period Start Date:' || TO_CHAR(l_curr_period_start_date,'DD-MON-YYYY HH24:MI:SS')  || ' ' ||'Current Period End Date:' || TO_CHAR(l_curr_period_end_date,'DD-MON-YYYY HH24:MI:SS')
                  );
  END IF;

  -- check if the previous period exists
  IF l_prev_sch_close_date IS NOT NULL THEN
    -- Check inflation adjustment period gap.
    IF l_curr_period_start_date > l_prev_sch_close_date + 1
    THEN
      RAISE l_period_gap_exc;
    END IF;
  END IF;

  Get_Inflation_Index_Value
  ( p_org_id                => p_org_id
  , p_acct_period_id        => p_acct_period_id
  , p_inflation_index       => p_inflation_index
  , x_inflation_index_value => l_inflation_index_value
  );

  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.itemcat'
                  , 'Item Category Set Id:' || l_category_set_id ||
                    ' Item Category Id:' || l_category_id
                  );
  END IF;

  -- delete pre-existing data if it exists
  DELETE FROM
    CST_MGD_INFL_ADJUSTED_COSTS
  WHERE Organization_ID   = p_org_id
    AND Acct_Period_ID    = p_acct_period_id
    AND Country_Code      = p_country_code
    AND Historical_Flag   = 'N';

  DELETE FROM
    CST_MGD_INFL_TSF_ORG_ENTRIES
  WHERE Organization_ID   = p_org_id
    AND Acct_Period_ID    = p_acct_period_id
    AND Country_Code      = p_country_code;

  -- ========================================================================
  -- Delete the status record only if not posted to GL
  -- If the entries are posted to GL, then the status will be FINAL
  -- This is to delete the status record from previous inflation run (if any)
  -- where the entries are not yet posted to GL
  -- ========================================================================
  DELETE FROM
    CST_MGD_INFL_ADJ_PER_STATUSES
  WHERE organization_id = p_org_id
    AND acct_period_id  = p_acct_period_id
    AND status  = 'PROCESS';

  FND_PROFILE.Get(l_profile_category_name, l_category_id);
  FND_PROFILE.Get(l_profile_category_set_name, l_category_set_id);

  IF (l_state_level >= l_debug_level) THEN
    FND_LOG.string(l_state_level
                  , G_MODULE_HEAD || l_routine || '.itemcat'
                  , 'Item Category Set Id:' || l_category_set_id ||
                    ' Item Category Id:' || l_category_id
                  );
  END IF;


  -- Get valid cost group
  Get_valid_cost_group( p_org_id
                       ,l_cost_group_id);


  IF (FND_LOG.LEVEL_EVENT >= l_debug_level) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT
                  , G_MODULE_HEAD || l_routine || '.cg_group'
                  , 'Cost Group Id:' || to_char(l_cost_group_id)
                  );
  END IF;

    -- Calculate inflation adjustment for each item
    FOR k IN l_inv_items_csr(p_acct_period_id
                            ,p_org_id
                            ,l_cost_group_id
                            ,TO_NUMBER(l_category_set_id)
                            ,TO_NUMBER(l_category_id)
                            ) LOOP

      l_inv_item_id := k.inventory_item_id;

        IF (l_state_level >= l_debug_level) THEN
          FND_LOG.string(l_state_level
                        , G_MODULE_HEAD || l_routine || '.itemcsr'
                        , 'Item Id:' || l_inv_item_id  || ' ' ||
                          'Org Id:' || p_org_id || ' ' ||
                          'Country Code:' || p_country_code || ' ' ||
                          'Acct Period Id:' || p_acct_period_id
                        );
        END IF;

       l_inflation_adjustment_rec.country_code           := p_country_code;
       l_inflation_adjustment_rec.organization_id        := p_org_id;
       l_inflation_adjustment_rec.acct_period_id         := p_acct_period_id;
       l_inflation_adjustment_rec.inventory_item_id      := l_inv_item_id;
       l_inflation_adjustment_rec.category_id            :=
         TO_NUMBER(l_category_id);
       l_inflation_adjustment_rec.category_set_id        :=
         TO_NUMBER(l_category_set_id);
       l_inflation_adjustment_rec.last_update_date       := SYSDATE;
       l_inflation_adjustment_rec.last_updated_by        :=
         NVL(TO_NUMBER(fnd_profile.value('USER_ID')),0);
       l_inflation_adjustment_rec.creation_date          := SYSDATE;
       l_inflation_adjustment_rec.created_by             :=
         NVL(TO_NUMBER(fnd_profile.value('USER_ID')),0);
       l_inflation_adjustment_rec.last_update_login      :=
         TO_NUMBER(fnd_profile.value('LOGIN_ID'));
       l_inflation_adjustment_rec.request_id             :=
         TO_NUMBER(fnd_profile.value('CONC_REQUEST_ID'));
       l_inflation_adjustment_rec.program_application_id :=
         TO_NUMBER(fnd_profile.value('PROG_APPL_ID'));
       l_inflation_adjustment_rec.program_id             :=
         TO_NUMBER(fnd_profile.value('CONC_PROG_ID'));
       l_inflation_adjustment_rec.program_update_date    := SYSDATE;

       -- get period end item unit avg. cost
       CST_MGD_INFL_ADJUSTMENT_PVT.Get_Period_End_Avg_Cost
       ( p_acct_period_id           => p_acct_period_id
       , p_org_id                   => p_org_id
       , p_inv_item_id              => l_inv_item_id
       , p_cost_group_id            => l_cost_group_id
       , x_period_end_item_avg_cost => l_item_unit_avg_cost
       );

       l_inflation_adjustment_rec.item_unit_cost := l_item_unit_avg_cost;

        IF (l_state_level >= l_debug_level) THEN
          FND_LOG.string(l_state_level
                        , G_MODULE_HEAD || l_routine || '.itemunitavgcost'
                        , 'Item Unit Average Cost:' || l_item_unit_avg_cost
                        );
        END IF;

       -- calling inflation adjustment engine
       CST_MGD_INFL_ADJUSTMENT_PVT.Create_Inflation_Adjusted_Cost
       ( p_api_version_number       => l_api_version_number
      , p_init_msg_list            => FND_API.G_FALSE
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data
      , p_inflation_index_value    => l_inflation_index_value
      , p_prev_acct_period_id      => l_prev_acct_period_id
      , p_inflation_adjustment_rec => l_inflation_adjustment_rec
      , p_cost_group_id            => l_cost_group_id
      );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END LOOP; -- for item cursor

  -- ======================================================
  -- Set the inflation processor status to PROCESS
  -- Insert a record with status PROCESS
  -- ======================================================
  CST_MGD_INFL_ADJUSTMENT_PVT.Create_Infl_Period_Status
  ( p_org_id         => p_org_id
  , p_acct_period_id => p_acct_period_id
  , x_return_status  => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- report success
  x_errbuf  := NULL;
  x_retcode := 0;

  IF (FND_LOG.LEVEL_PROCEDURE >= l_debug_level) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION

  -- Bug # 3889172
  WHEN l_wms_org_exc THEN
    FND_MESSAGE.set_name('BOM', 'CST_MGD_INFL_WMS_ORG');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Calculate_Adjustment'
                             );
    END IF;
     x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
     x_retcode := 2;

  WHEN l_period_gap_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_PERIOD_GAP');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Calculate_Adjustment'
                             );
    END IF;
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;
  WHEN g_price_index_exc THEN
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Calculate_Adjustment'
      );
    END IF;
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;

END Calculate_Adjustment;


--=======================================================================i
-- PROCEDURE : Get_User_Category_Name  PRIVATE
-- PARAMETERS: p_je_category_name      JE catergory name
--             x_user_category_name    User catergory name
-- COMMENT   : This procedure takes je_category_name and returns
--             user_category_name.
-- EXCEPTIONS: OTHERS
--========================================================================
PROCEDURE Get_User_Category_Name (
  p_je_category_name   IN  VARCHAR2
, x_user_category_name OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SELECT
    User_JE_Category_Name
  INTO
    x_user_category_name
  FROM
    GL_JE_CATEGORIES
  WHERE JE_Category_Name = p_je_category_name;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_User_Category_Name'
                             );
    END IF;
    RAISE;

END Get_User_Category_Name;


--========================================================================
-- PROCEDURE : Get_User_Source_Name    PRIVATE
-- PARAMETERS: p_je_source_name        JE source name
--             x_user_source_name      User source name
-- COMMENT   : This procedure takes je_source_name and returns
--             user_source_name.
-- EXCEPTIONS: OTHERS
--========================================================================
PROCEDURE Get_User_Source_Name (
  p_je_source_name   IN  VARCHAR2
, x_user_source_name OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SELECT
    User_JE_Source_Name
  INTO
    x_user_source_name
  FROM
    GL_JE_SOURCES
  WHERE JE_Source_Name = p_je_source_name;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_User_Source_Name'
                             );
    END IF;
    RAISE;

END Get_User_Source_Name;


--=======================================================================
-- PROCEDURE : Transfer_to_GL          PRIVATE
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_org_id                Organization ID
--             p_country_code          Country code
--             p_acct_period_id        Account perio ID
-- COMMENT   : This concurrent program creates account entries for
--             inflation adjusted items and set the period to final.
--========================================================================
PROCEDURE Transfer_to_GL (
  x_errbuf         OUT NOCOPY VARCHAR2
, x_retcode        OUT NOCOPY VARCHAR2
, p_org_id         IN  NUMBER
, p_country_code   IN  VARCHAR2
, p_acct_period_id IN  NUMBER
)
IS
l_routine CONSTANT VARCHAR2(30) := 'transfer_to_gl';
l_acct_entry_tbl_rec
  CST_MGD_INFL_ADJUSTMENT_PVT.Infl_Adj_Acct_Tbl_Rec_Type;
l_transfer_entry_tbl_rec
  CST_MGD_INFL_ADJUSTMENT_PVT.Infl_Adj_Acct_Tbl_Rec_Type;
l_status                     NUMBER;
l_infl_adj_item_id           NUMBER;
l_inventory_adj_acct_cr      NUMBER;
l_inventory_adj_acct_dr      NUMBER;
l_monetary_corr_acct_cr      NUMBER;
l_sales_cost_acct_dr         NUMBER;
l_transfer_org_id            NUMBER;
l_transfer_acct_cr           NUMBER;
l_transfer_acct_dr           NUMBER;
l_index                      BINARY_INTEGER;
l_return_status              VARCHAR2(1);
l_set_of_books_id            NUMBER;
l_currency_code              VARCHAR2(15);
l_user_category_name         VARCHAR(25);
l_user_source_name           VARCHAR(25);
l_curr_period_start_date     DATE;
l_curr_period_end_date       DATE;

no_infl_processor_run_exc    EXCEPTION;

CURSOR l_infl_adj_item_csr IS
  SELECT
    ADJ.Inventory_Item_ID
  , ADJ.Inventory_Adj_Acct_CR
  , ADJ.Inventory_Adj_Acct_DR
  , ADJ.Monetary_Corr_Acct_CR
  , ADJ.Sales_Cost_Acct_DR
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS ADJ
  , MTL_SYSTEM_ITEMS SYS
  WHERE ADJ.Country_Code      = p_country_code
    AND ADJ.Acct_Period_ID    = p_acct_period_id
    AND ADJ.Organization_ID   = p_org_id
    AND ADJ.Inventory_Item_ID = SYS.Inventory_Item_ID
    AND SYS.Organization_ID   = p_org_id;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  -- Check whether transfer to GL already run
  Check_Period_Status
  ( p_country_code   => p_country_code
  , p_org_id         => p_org_id
  , p_acct_period_id => p_acct_period_id
  );

  -- Check Inflation processor run
  Check_Inflation_Process_Run
  ( p_org_id         => p_org_id
  , p_acct_period_id => p_acct_period_id
  , x_return_status  => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE no_infl_processor_run_exc;
  END IF;


  CST_MGD_INFL_ADJUSTMENT_PVT.Get_Set_Of_Books_ID
  ( p_org_id          => p_org_id
  , x_set_of_books_id => l_set_of_books_id
  );

  CST_MGD_INFL_ADJUSTMENT_PVT.Get_Currency_Code
  ( p_set_of_books_id => l_set_of_books_id
  , x_currency_code   => l_currency_code
  );

  Get_User_Category_Name
  ( p_je_category_name   => 'Adjustment'
  , x_user_category_name => l_user_category_name
  );

  Get_User_Source_Name
  ( p_je_source_name   => 'Inflation'
  , x_user_source_name => l_user_source_name
  );

  CST_MGD_INFL_ADJUSTMENT_PVT.Get_Curr_Period_Start_Date
  ( p_org_id                 => p_org_id
  , p_acct_period_id         => p_acct_period_id
  , x_curr_period_start_date => l_curr_period_start_date
  , x_curr_period_end_date   => l_curr_period_end_date
  );

  -- From date is at midnight for the day
  -- bug#5012817 fix: remove canonical to date as it is already in
  -- date format
  l_curr_period_start_date := TRUNC(l_curr_period_start_date);

  -- The to date is at 23:59:59 of that date entered
  l_curr_period_end_date := TRUNC(l_curr_period_end_date) + (86399/86400);


  OPEN l_infl_adj_item_csr;
  LOOP
    FETCH
      l_infl_adj_item_csr
    INTO
      l_infl_adj_item_id
    , l_inventory_adj_acct_cr
    , l_inventory_adj_acct_dr
    , l_monetary_corr_acct_cr
    , l_sales_cost_acct_dr;
    EXIT WHEN l_infl_adj_item_csr%NOTFOUND;

     CST_MGD_INFL_ADJUSTMENT_PVT.GL_Interface_Default
     ( p_country_code          => p_country_code
     , p_org_id                => p_org_id
     , p_inv_item_id           => l_infl_adj_item_id
     , p_acct_period_id        => p_acct_period_id
     , p_inventory_adj_acct_cr => l_inventory_adj_acct_cr
     , p_inventory_adj_acct_dr => l_inventory_adj_acct_dr
     , p_monetary_corr_acct_cr => l_monetary_corr_acct_cr
     , p_sales_cost_acct_dr    => l_sales_cost_acct_dr
     , p_set_of_books_id       => l_set_of_books_id
     , p_currency_code         => l_currency_code
     , p_user_category_name    => l_user_category_name
     , p_user_source_name      => l_user_source_name
     , p_accounting_date       => l_curr_period_end_date
     , x_acct_entry_tbl_rec    => l_acct_entry_tbl_rec
     );

     -- Post journal into GL_INTERFACE
     l_index := NVL(l_acct_entry_tbl_rec.FIRST, 0);
     IF l_index > 0
     THEN
       LOOP
         IF NVL(l_acct_entry_tbl_rec(l_index).entered_cr, 0) +
            NVL(l_acct_entry_tbl_rec(l_index).entered_dr, 0)
            <> 0
         THEN
           CST_MGD_INFL_ADJUSTMENT_PVT.Create_Journal_Entries
           ( p_infl_adj_acct_rec => l_acct_entry_tbl_rec(l_index)
           );
         END IF;
         EXIT WHEN l_index = l_acct_entry_tbl_rec.LAST;
	    l_index := l_acct_entry_tbl_rec.NEXT(l_index);
       END LOOP;
    END IF;
  END LOOP;

  -- Set period status to final
  -- Update status table to 'FINAL'
  CST_MGD_INFL_ADJUSTMENT_PVT.Update_Infl_Period_Status
  ( p_org_id         => p_org_id
  , p_acct_period_id => p_acct_period_id
  , x_return_status  => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- report success
  x_errbuf  := NULL;
  x_retcode := 0;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN no_infl_processor_run_exc THEN
    x_errbuf := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Transfer_to_GL'
      );
    END IF;
    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;

END Transfer_to_GL;


END CST_MGD_INFL_ADJUSTMENT_CP;

/
