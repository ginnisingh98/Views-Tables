--------------------------------------------------------
--  DDL for Package CST_PAC_ITERATION_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PAC_ITERATION_PROCESS_PVT" AUTHID CURRENT_USER AS
-- $Header: CSTVIIPS.pls 120.14.12010000.3 2009/08/04 09:10:53 vjavli ship $

-- API Name          : Iteration_Process
-- Type              : Private
-- Function          :
-- Pre-reqs          : None
-- Parameters        :
-- IN                :    p_init_msg_list           IN  VARCHAR2
--                        p_validation_level        IN  NUMBER
--                        p_legal_entity_id         IN  NUMBER
--                        p_cost_type_id            IN  NUMBER
--                        p_cost_method             IN  NUMBER
--                        p_iteration_proc_flag     IN VARCHAR2
--                        p_period_id               IN  NUMBER
--                        p_start_date              IN  DATE
--                        p_end_date                IN  DATE
--                        p_inventory_item_id       IN  NUMBER
--                        p_inventory_item_number   IN VARCHAR2(1025)
--                        p_tolerance               IN  NUMBER
--                        p_iteration_num           IN  NUMBER
--                        p_run_options             IN  NUMBER
--                        p_pac_rates_id            IN  NUMBER
--                        p_uom_control             IN  NUMBER
--			  p_user_id                 IN  NUMBER
--			  p_login_id                IN  NUMBER
--			  p_req_id                  IN  NUMBER
--			  p_prg_id                  IN  NUMBER
--			  p_prg_appid               IN  NUMBER
-- OUT               :    x_return_status           OUT VARCHAR2(1)
--                        x_msg_count               OUT NUMBER
--                        x_msg_data                OUT VARCHAR2(2000)
-- Version           : Current Version :    1.0
--                         Initial version     1.0
-- Notes             :
-- +========================================================================+

-- +========================================================================+
-- GLOBAL CONSTANTS
-- +========================================================================+
G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'CST_PAC_ITERATION_PROCESS_PVT';

-- +========================================================================+
-- PL/SQL table g_cst_group_tbl
-- This table contains all the valid Cost Groups for the user entered
-- Legal Entity
-- period new quantity is the total quantity of all cost owned transactions
-- upto interorg receipts across Cost groups i.e. upto txn category 8
-- +========================================================================+
TYPE cst_group_rec_type IS RECORD
( cost_group_id           NUMBER
, cost_group              VARCHAR2(10)
, master_organization_id  NUMBER
, period_new_quantity     NUMBER
);

TYPE g_cst_group_table_type IS TABLE OF cst_group_rec_type
INDEX BY PLS_INTEGER;

G_CST_GROUP_TBL   g_cst_group_table_type;

-- +========================================================================+
-- PL/SQL table g_cst_group_org_tbl
-- This table contains all the valid organizations in each Cost Group
-- +========================================================================+
TYPE cst_group_org_rec_type IS RECORD
( cost_group_id   NUMBER
, organization_id NUMBER
);

TYPE g_cst_group_org_table_type IS TABLE OF cst_group_org_rec_type
INDEX BY PLS_INTEGER;

G_CST_GROUP_ORG_TBL  g_cst_group_org_table_type;

-- +========================================================================+
-- PL/SQL table g_pwac_new_cost_tbl
-- This table contains :
-- balance before interorg txns, qty before interorg txns,
-- period new balance of all interorg receipts, final new cost of the
-- cost element and level type
-- for a given inventory item id, cost group id and pac period id
-- This table is used get the final new cost which is assigned to all the
-- corresponding group 2 (cost derived) transactions in a given item id,
-- cost group and pac period.
-- period_new_quantity is same for all the cost elements, level in a given
-- item,cost group and pac period
-- This pl/sql table is flushed for each optimal cost group
-- +========================================================================+
TYPE pwac_new_cost_rec_type IS RECORD
( final_new_cost        NUMBER
, period_new_balance    NUMBER
, period_new_quantity   NUMBER
, period_bal_bef_intorg NUMBER
, period_qty_bef_intorg NUMBER
);

TYPE g_pwac_new_cost_table_type IS TABLE OF pwac_new_cost_rec_type INDEX BY PLS_INTEGER;
TYPE g_pwac_cost_table_type IS TABLE OF g_pwac_new_cost_table_type INDEX BY PLS_INTEGER;
G_PWAC_NEW_COST_TBL   g_pwac_cost_table_type;


-- +========================================================================+
-- PL/SQL table g_cg_pwac_cost_tbl
-- This table contains final new cost of the cost element and level type
-- for a given inventory item id, cost group id and pac period id
-- This table is used to update cpicd.item_cost, item_balance for each
-- cost group
-- The table has the same record structure as that of pwac_new_cost_rec_type
-- This pl/sql table is flushed after Nth iteration, after updating cpicd
-- The pl/sql table is flushed in the procedure Update_Cpicd_With_New_Values
-- +========================================================================+

G_CG_PWAC_COST_TBL   g_pwac_new_cost_table_type;

-- +========================================================================+
-- This pl/sql table is used to store interorg items in the current BOM level
-- considering the highest BOM level across cost groups
-- This pl/sql table is flushed before each BOM level
-- Item Id itself is the index
-- +========================================================================+
TYPE interorg_item_level_rec_type IS RECORD
(inventory_item_id   NUMBER
,bom_high_level_code NUMBER
);

TYPE g_interorg_item_level_tab_type IS TABLE OF interorg_item_level_rec_type
INDEX BY PLS_INTEGER;

G_INTERORG_ITEM_LEVEL_TBL g_interorg_item_level_tab_type;


-- +========================================================================+
-- This pl/sql table is used to store PCU value change period balance if any
-- for each cost group, cost_element, level_type for a given interorg item
-- This table is flushed after Nth iteration, after computing new periodic
-- balance
-- This table is accessed with combination of cost_group_id,cost_element_id,
-- level_type
-- +========================================================================+
TYPE g_pcu_value_bal_rec_type IS RECORD
(pcu_value_balance        NUMBER
,cost_group_id            NUMBER
,cost_element_id          NUMBER
,level_type               NUMBER
);

TYPE g_pcu_value_bal_tab_type IS TABLE OF g_pcu_value_bal_rec_type
INDEX BY PLS_INTEGER;

G_PCU_VALUE_CHANGE_TBL g_pcu_value_bal_tab_type;


G_TOL_ACHIEVED_MESSAGE		VARCHAR2(255);
G_TOL_NOT_ACHIEVED_MESSAGE	VARCHAR2(255);

-- +========================================================================+
-- PROCEDURES AND FUNCTIONS
-- +========================================================================+

-- +========================================================================+
-- FUNCTION: Check_Cst_Group    Local Utility
-- PARAMETERS:
--   p_cost_group_id  user input
-- COMMENT:
-- Take p_cost_group_id and look in the PL/SQL table g_cst_group_tbl.
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
RETURN VARCHAR2;

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
RETURN VARCHAR2;


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
RETURN NUMBER;

-- +========================================================================+
-- PROCEDURE: Initialize
-- PARAMETERS:
--   p_legal_entity_id    IN  NUMBER
-- COMMENT:
--   This procedure is to initialize Global PL/SQL tables
--   G_CST_GROUP_TBL to store valid Cost Groups in Legal Entity
--   G_CST_GROUP_ORG_TBL to store valid organizations in those cost groups
--   This procedure is called by the API CST_INTERORG_TRANSFER_PROC
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Initialize
(  p_legal_entity_id    IN  NUMBER
);


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
                           );


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
--
-- USAGE: This procedure is invoked from api:iteration_process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +========================================================================+
PROCEDURE Set_Process_Status( p_legal_entity_id  IN     NUMBER
                            , p_period_id        IN     NUMBER
                            , p_period_end_date  IN     DATE
                            , p_phase_status     IN     NUMBER
                            );

-- +========================================================================+
-- PROCEDURE: Populate_Temp_Tables
-- PARAMETERS:
--   p_cost_group_id         IN  NUMBER
--   p_period_id             IN  NUMBER
--   p_period_start_date     IN  DATE
--   p_period_end_date       IN  DATE
-- COMMENT:
--   This procedure is called by the Iterative PAC Worker
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Populate_Temp_Tables
(  p_cost_group_id         IN      NUMBER
,  p_period_id             IN      NUMBER
,  p_period_start_date     IN      DATE
,  p_period_end_date       IN      DATE
);
-- +========================================================================+
-- PROCEDURE: Retrieve_Interorg_Items
-- PARAMETERS:
--   p_period_id             IN  NUMBER
--   p_cost_group_id         IN  NUMBER
--   p_period_start_date     IN  DATE
--   p_period_end_date       IN  DATE
-- COMMENT:
--   This procedure is called by the API iteration_process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Retrieve_Interorg_Items
(  p_period_id             IN    NUMBER
,  p_cost_group_id         IN    NUMBER
,  p_period_start_date     IN    DATE
,  p_period_end_date       IN    DATE
);

-- +========================================================================+
-- PROCEDURE: Process_Optimal_Sequence
-- PARAMETERS:
--   p_period_id             IN  NUMBER
-- COMMENT:
--   This procedure is called by the Absorption Cost Process
-- PRE-COND:   none
-- EXCEPTIONS:  none
-- +==========================================================================+
PROCEDURE Process_Optimal_Sequence
(  p_period_id             IN    NUMBER
);

-- +========================================================================+
-- PROCEDURE:  Iteration_Process      PRIVATE UTILITY
-- PARAMETERS:
--   p_init_msg_list           IN  VARCHAR2
--   p_validation_level        IN  NUMBER
--   x_return_status           OUT VARCHAR2(1)
--   x_msg_count               OUT NUMBER
--   x_msg_data                OUT VARCHAR2(2000)
--   p_legal_entity_id         IN  NUMBER
--   p_cost_type_id            IN  NUMBER
--   p_cost_method             IN  NUMBER
--   p_iteration_proc_flag     IN VARCHAR2(1)
--   p_period_id               IN  NUMBER
--   p_start_date              IN  DATE
--   p_end_date                IN  DATE
--   p_inventory_item_id       IN  NUMBER
--   p_inventory_item_number   IN  VARHCHAR2(1025)
--   p_tolerance               IN  NUMBER
--   p_iteration_num           IN  NUMBER
--   p_run_options             IN  NUMBER
--   p_pac_rates_id            IN  NUMBER
--   p_uom_control             IN  NUMBER
-- COMMENT:
--   This procedure is called by the Interorg Transfer Cost Process worker
--   after completing the necessary process in phase 5 of standard PAC
--   feature
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
);


END CST_PAC_ITERATION_PROCESS_PVT;

/
