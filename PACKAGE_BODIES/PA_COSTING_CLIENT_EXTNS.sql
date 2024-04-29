--------------------------------------------------------
--  DDL for Package Body PA_COSTING_CLIENT_EXTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COSTING_CLIENT_EXTNS" as
-- $Header: PAXCHCEB.pls 120.2 2007/02/06 09:29:11 rshaik ship $


  procedure Add_Transactions_Hook( x_expenditure_item_id    in number,
                                   x_sys_linkage_function   in varchar2,
                                   x_status                 in out NOCOPY number)
   is
   begin

        PA_Client_Extn_Txn.Add_Transactions(x_expenditure_item_id,
					    x_sys_linkage_function,
					    x_status);

   exception
	when others then
	x_status := SQLCODE;

   end Add_Transactions_Hook;


   procedure Calc_Raw_Cost_Hook(
                                 x_transaction_type       in varchar2 default 'ACTUAL',
                                 x_expenditure_item_id    in number,
                                 x_sys_linkage_function   in varchar2,
                                 x_raw_cost_amount        in out NOCOPY pa_expenditure_items.raw_cost%type, --Changed for Bug#3858467
				 x_currency_code          in out NOCOPY pa_expenditure_items.denom_currency_code%type, -- Added for bug#5594124
                                 x_status                 in out NOCOPY number)
   is
   /* Added the following parameters for bug 5594124 */
	l_denom_currency_code pa_expenditure_items.denom_currency_code%type;

      begin

        l_denom_currency_code := x_currency_code; /* Added for bug 5594124 */
        /* Added the parameter x_currency_code in the call to Calc_Raw_Cost */
        PA_Client_Extn_Costing.Calc_Raw_Cost(x_transaction_type,
                                              x_expenditure_item_id,
					      x_sys_linkage_function,
					      x_raw_cost_amount,
					      x_currency_code,
					      x_status);

        /* Rounding off tmount depending on the currency */
        /* x_raw_cost_amount := pa_currency.round_currency_amt(x_raw_cost_amount); commented for bug#2573989 */


        if (NVL(x_currency_code, l_denom_currency_code)  = l_denom_currency_code) then

	    x_currency_code := l_denom_currency_code;

        end if;

   exception
	when others then
	x_status := SQLCODE;

   end Calc_Raw_Cost_Hook;


end PA_Costing_Client_Extns;

/
