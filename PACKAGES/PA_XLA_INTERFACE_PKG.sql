--------------------------------------------------------
--  DDL for Package PA_XLA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_XLA_INTERFACE_PKG" AUTHID CURRENT_USER AS
--  $Header: PAXLAIFS.pls 120.9.12000000.3 2007/11/23 09:27:43 rjayaram ship $

/*----------------------------------------------------------------------
 * Parameter description :
 * p_calling_module:
 *     This is the token that the calling process will pass.
 *     Based on this different code paths are executed.
 *     Valid values for this parameter are:
 *       LAB     - for Straight Time and Over Time
 *       SUPP    - for Expense Report Adjustments and Supplier Invoice
 *                 Adjustments
 *       USG     - for Usages
 *       PJ      - for Miscellaneous
 *       INV     - for Inventory
 *       WIP     - for Work in Process
 *       BTC     - for Burden Transactions
 *       TBC     - for Burden on same line
 *       Cost    - Encompasses all of the above.
 *
 *       BL      - for Borrow and Lend
 *       PC      - for Provider Reclassification
 *       Revenue - for Revenue
 *
 * p_data_set_id:
 *   The meaning of this parameter is dependent on the calling module.
 *   - If the calling module is one of "Cost" related transactions, it is
 *     the request id of the process.
 *   - If the calling module is Budget Baseline process, then this is
 *     the budget_version_id that is baselined
 *   - If the calling module is Fundscheck process, then packet_id is
 *     passed.
 *
 * x_result_code:
 *    'Success' or 'Failed' based on success or failure in raising
 *    an accounting event.
 *---------------------------------------------------------------------*/


procedure create_events(p_calling_module  IN         VARCHAR2,
                        p_data_set_id     IN         NUMBER,
                        x_result_code     OUT NOCOPY VARCHAR2);


-- function to return the accounting source
function get_source(p_transaction_source varchar2, p_payment_id number)
         return varchar2;

-- procedure to populate accounting source and parent line number
procedure populate_acct_source;

  FUNCTION Get_Post_Acc_Sla_Ccid(
                         P_Acct_Event_Id              IN PA_Cost_Distribution_Lines_All.Acct_Event_Id%TYPE
                        ,P_Transfer_Status_Code       IN PA_Cost_Distribution_Lines_All.Transfer_Status_Code%TYPE
                        ,P_Transaction_Source         IN PA_Expenditure_Items_All.Transaction_Source%TYPE
                        ,P_Historical_Flag            IN PA_Expenditure_Items_All.Historical_Flag%TYPE
                        ,P_Distribution_Id_1          IN XLA_Distribution_Links.Source_Distribution_Id_Num_1%TYPE
                        ,P_Distribution_Id_2          IN XLA_Distribution_Links.Source_Distribution_Id_Num_2%TYPE
                        ,P_Distribution_Type          IN VARCHAR2
                        ,P_Ccid                       IN PA_Cost_Distribution_Lines_All.Dr_Code_Combination_Id%TYPE DEFAULT NULL
                        ,P_Account_Type               IN VARCHAR2 DEFAULT 'DEBIT'
                        ,P_Ledger_Id                  IN PA_Implementations_All.Set_Of_Books_Id%TYPE
                       )
    RETURN NUMBER;

  FUNCTION Get_Sla_Ccid( P_Application_Id    NUMBER
                        ,P_Distribution_Id_1 NUMBER
                        ,P_Distribution_Id_2 NUMBER
                        ,P_Distribution_Type XLA_Distribution_Links.SOURCE_DISTRIBUTION_TYPE%TYPE
                        ,P_Account_Type      VARCHAR2
                        ,P_Ledger_Id         NUMBER
                       )
  RETURN NUMBER;

END PA_XLA_INTERFACE_PKG;

 

/
