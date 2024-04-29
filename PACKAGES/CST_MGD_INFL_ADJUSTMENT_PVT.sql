--------------------------------------------------------
--  DDL for Package CST_MGD_INFL_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_INFL_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVIADS.pls 115.15 2004/05/20 09:34:18 vjavli ship $ */

--===================
-- GLOBAL CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_MGD_INFL_ADJUSTMENT_PVT';

--===================
-- TYPES
--===================

TYPE Infl_Adj_Acct_Rec_Type IS RECORD
( status                VARCHAR2(50)
, set_of_books_id       NUMBER
, user_je_source_name   VARCHAR2(25)
, user_je_category_name VARCHAR2(25)
, accounting_date       DATE
, currency_code         VARCHAR2(15)
, date_created          DATE
, created_by            NUMBER
, actual_flag           VARCHAR2(1)
, entered_dr            NUMBER
, entered_cr            NUMBER
, code_combination_id   NUMBER
);

TYPE Infl_Adj_Acct_Tbl_Rec_Type IS TABLE OF Infl_Adj_Acct_Rec_Type
INDEX BY BINARY_INTEGER;

--========================
-- PUBLIC FUNCTIONS
--========================

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
RETURN VARCHAR2;


--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Check_Period_Close      PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--           : p_acct_period_id        Account period ID
-- COMMENT   : This procedure check if an accounting period is closed.
-- EXCEPTIONS: g_period_not_closed_exc Period is not closed
--             g_toom_many_per_close_exc Too many rows selected
--========================================================================
PROCEDURE Check_Period_Close
( p_org_id         IN  NUMBER
, p_acct_period_id IN  NUMBER
);


--========================================================================
-- PROCEDURE : Get_Previous_Acct_Period_ID PRIVATE
-- PARAMETERS: p_organization_id       Organization ID
--             p_acct_period_id        Account period ID
--             x_prev_acct_period_id   Perious period account period ID
--             x_prev_sch_close_date   Perious period schedule close date
-- COMMENT   : This procedure retrieves previous period account period ID
--             and scheduled close date.
-- EXCEPTIONS: g_no_data_prev_per_id_exc  No data found
--             g_too_many_prev_per_id_exc Too many rows selected
--========================================================================
PROCEDURE Get_Previous_Acct_Period_ID
( p_organization_id     IN         NUMBER
, p_acct_period_id      IN         NUMBER
, x_prev_acct_period_id OUT NOCOPY NUMBER
, x_prev_sch_close_date OUT NOCOPY DATE
);


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
);


--========================================================================
-- PROCEDURE : Get_Curr_Period_Start_Date PRIVATE
-- PARAMETERS: p_org_id                 Organization ID
--             p_acct_period_id         Account period ID
--             x_curr_period_start_date Current period start date
-- COMMENT   : This procedure returns the current period start date
-- EXCEPTIONS: g_no_data_start_date_exc  No data found
--             g_too_many_start_date_exc Too many rows selected
--========================================================================
PROCEDURE Get_Curr_Period_Start_Date
( p_org_id                 IN           NUMBER
, p_acct_period_id         IN           NUMBER
, x_curr_period_start_date OUT NOCOPY	DATE
, x_curr_period_end_date   OUT NOCOPY   DATE
);


--========================================================================
-- PROCEDURE : Get_Purchase_Qty        PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_inventory_item_id     Inventory item ID
--             p_acct_period_id        Account period ID
--             p_cost_group_id         Cost Group Id
--             x_purchase_qty          Purchase quantity in period
-- COMMENT   : This procedure returns the purchase quantity incurred in
--             a period.
--========================================================================
PROCEDURE Get_Purchase_Qty
( p_org_id            IN         NUMBER
, p_inventory_item_id IN         NUMBER
, p_acct_period_id    IN         NUMBER
, p_cost_group_id     IN         CST_COST_GROUPS.cost_group_id%TYPE
, x_purchase_qty      OUT NOCOPY NUMBER
);

/* bug#1474753 fix -- historical data check removed
--========================================================================
-- PROCEDURE : Check_First_Time        PRIVATE
-- PARAMETERS: p_country_code          Country code
--             p_org_id                Organization ID
--             x_get_hist_data_flag    Historical data flag
-- COMMENT   : This procedure determines if the process is running for
--             the first time.
-- EXCEPTIONS: g_no_hist_data_exc      No historical data
--========================================================================
PROCEDURE Check_First_Time
( p_country_code       IN  VARCHAR2
, p_org_id             IN  NUMBER
, x_get_hist_data_flag OUT NOCOPY VARCHAR2
);
*/


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
);


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
);


--========================================================================
-- PROCEDURE : Create_Inflation_Adjusted_Cost PRIVATE
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_inflation_index_value Inflation index value
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
);


--========================================================================
-- PROCEDURE : Get_Set_Of_Books_ID     PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             x_set_of_books_id       Set of books ID
-- COMMENT   : This procedure returns the set of books id.
-- EXCEPTIONS: g_no_data_set_of_books_exc  No data found
--             g_too_many_set_of_books_exc Too many rows selected
--========================================================================
PROCEDURE Get_Set_Of_Books_ID
( p_org_id          IN         NUMBER
, x_set_of_books_id OUT NOCOPY NUMBER
);


--========================================================================
-- PROCEDURE : Get_Currency_Code       PRIVATE
-- PARAMETERS: p_set_of_books_id       Set of books ID
--             x_currency_code         Currency code
-- COMMENT   : This procedure returns the currency code for a set of books
-- EXCEPTIONS: g_no_data_curr_code_exc No data found
--             g_too_many_curr_code_exc Too many rows selected
--========================================================================
PROCEDURE Get_Currency_Code
( p_set_of_books_id IN         NUMBER
, x_currency_code   OUT NOCOPY VARCHAR2
);


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
--             p_accounting_date       Accounting date entry
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
);


--========================================================================
-- PROCEDURE : Create_Journal_Entries  PRIVATE
-- PARAMETERS: p_infl_adj_acct_rec     Inflation account record
-- COMMENT   : This procedure crreates the account entry data.
--========================================================================
PROCEDURE Create_Journal_Entries
( p_infl_adj_acct_rec IN  Infl_Adj_Acct_Rec_Type
);


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
);


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
);


--========================================================================
-- PROCEDURE : Insert_Inflation_Adj    PRIVATE
-- PARAMETERS: p_inflation_adjustment_rec Inflation data record
-- COMMENT   : This procedure inserts inflation adjustment data.
--========================================================================
PROCEDURE Insert_Inflation_Adj
( p_inflation_adjustment_rec IN
    CST_MGD_INFL_ADJUSTMENT_PUB.Inflation_Adjustment_Rec_Type
);


--========================================================================
-- PROCEDURE : Get_Period_End_Avg_Cost PRIVATE
-- PARAMETERS: p_acct_period_id        Account period ID
--             p_org_id                Organization ID
--             p_inv_item_id           Inventory item ID
--             p_cost_group_id         Cost Group Id
--             x_period_end_item_avg_cost Period end item unit average
--                                        cost
-- COMMENT   : This procedure returns period end item unit average cost.
-- EXCEPTIONS: g_no_data_per_unit_cost_exc  No end period unit cost
--========================================================================
PROCEDURE Get_Period_End_Avg_Cost
( p_acct_period_id           IN  NUMBER
, p_org_id                   IN  NUMBER
, p_inv_item_id              IN  NUMBER
, p_cost_group_id            IN  CST_COST_GROUPS.cost_group_id%TYPE
, x_period_end_item_avg_cost OUT NOCOPY NUMBER
);

END CST_MGD_INFL_ADJUSTMENT_PVT;

 

/
