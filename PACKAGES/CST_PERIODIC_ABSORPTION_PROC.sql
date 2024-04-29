--------------------------------------------------------
--  DDL for Package CST_PERIODIC_ABSORPTION_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERIODIC_ABSORPTION_PROC" AUTHID CURRENT_USER AS
-- $Header: CSTRITPS.pls 120.10.12010000.4 2009/06/11 23:30:08 vjavli ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTRITPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inter Organization Transfer Concurrent Program                    |
--| HISTORY                                                               |
--|     07/21/2003 David Herring       created                            |
--|     11/06/2003 Veeresha Javli  p_run_options datatype is number       |
--|     01/20/2003 Veeresha Javli  x_return_status - Success, Error       |
--|                                x_error_message                        |
--|                                adhere to api standards                |
--|     03/17/2004 Veeresha Javli  WIP completion items: Option 4: Rollup |
--|                                for all items by BOM level             |
--|                                Major design change; Function          |
--|                                Check_Interorg_Item_Level created      |
--|     04/10/2004 Veeresha Javli  Package body name change as            |
--|                                CST_PERIODIC_ABSORPTION_PROC           |
--| ----------------------------------------------------------------------|
--| -------------------------- R12 ENHANCEMENTS --------------------------|
--| ----------------------------------------------------------------------|
--| 06/15/2005 vjavli    BOM115100:Bug#4351270 fix: Time zone issue -     |
--|                      transfer_cp_manager added with p_le_process_upto_|
--|                      date for LE time zone                            |
--| 12/10/2005 vjavli    Get_Transfer_Price_Option function created       |
--| 12/16/2005 vjavli    Calc_Pmac_Update_Cppb_First created - copy of    |
--|                      Calc_Pmac_Update_Cppb for a given cost group     |
--| 10/30/2008 vjavli    FP 12.1.1 Bug 7342514 fix: COST ADJ NOT          |
--|                      CONSIDERED FOR PRIMARY_QUANTITY NOT POPULATED    |
--|                      IN MMT.  Periodic Cost Update - Value Change has |
--|                      to be processed after all the cost owned txns.   |
--|                      In specific, after processing inter-org receipts |
--|                      in the first iteration                           |
--+========================================================================

--===================
-- CONSTANTS
--===================

G_LOG_PROCEDURE         CONSTANT NUMBER := 2;
g_loop_flag		NUMBER := 0;
--=================
-- TYPES
--=================

TYPE rec_type IS
     RECORD (cost_group_id        NUMBER
            ,starting_phase       NUMBER
            ,master_org_id        NUMBER);

TYPE tbl_type IS TABLE OF rec_type INDEX BY PLS_INTEGER;

TYPE Expense_Itm_Table IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE Expense_Item_Table IS TABLE OF Expense_Itm_Table INDEX BY PLS_INTEGER;

TYPE Expense_Flg_Table IS TABLE OF NUMBER INDEX BY MTL_MATERIAL_TRANSACTIONS.SUBINVENTORY_CODE%TYPE;
TYPE Expense_Flag_Table IS TABLE OF Expense_Flg_Table INDEX BY PLS_INTEGER;

G_EXPENSE_FLAG_CACHE Expense_Flag_Table;
G_EXPENSE_ITEM_CACHE Expense_Item_Table;
--=========================
-- PROCEDURES AND FUNCTIONS
--=========================
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
);

--========================================================================
-- PROCEDURE : Transfer_CP_Manager     PUBLIC
-- PARAMETERS: p_legal_entity_id       IN   Legal Entity Id
--             p_cost_type_id          IN   Cost Type Id
--             p_period_id             IN   Period Id
--             p_process_upto_date     IN   Latest Date for Processor Run
--             p_le_process_upto_date  IN   LE process upto date
--             p_tolerance             IN   Tolerance to adhere to
--             p_number_of_iterations  IN   Max number of iterations to try
--             p_run_options           IN   Run options (start,resume,final)
--                                          start - 1, resume - 2, final - 3
--             x_return_status         OUT  NOCOPY VARCHAR2
--             x_msg_count             OUT  NOCOPY NUMBER
--             x_msg_data              OUT  NOCOPY VARCHAR2
-- COMMENT   : This procedure will perform the validation needed
--             prior to processing the inter-org transfer transactions
--=========================================================================

PROCEDURE transfer_cp_manager
( p_legal_entity                 IN  NUMBER
, p_cost_type_id                 IN  NUMBER
, p_period_id                    IN  NUMBER
, p_process_upto_date            IN  VARCHAR2
, p_le_process_upto_date         IN  VARCHAR2
, p_tolerance                    IN  NUMBER
, p_number_of_iterations         IN  NUMBER
, p_number_of_workers            IN  NUMBER
, p_run_options                  IN  NUMBER
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
);

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
);

END CST_PERIODIC_ABSORPTION_PROC;

/
