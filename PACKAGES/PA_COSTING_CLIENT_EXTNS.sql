--------------------------------------------------------
--  DDL for Package PA_COSTING_CLIENT_EXTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COSTING_CLIENT_EXTNS" AUTHID CURRENT_USER as
-- $Header: PAXCHCES.pls 120.2 2007/02/06 09:29:25 rshaik ship $

  procedure Add_Transactions_Hook( x_expenditure_item_id    in number,
                                   x_sys_linkage_function   in varchar2,
                                   x_status                 in out NOCOPY number);


  procedure Calc_Raw_Cost_Hook(
                                x_transaction_type       in varchar2 default 'ACTUAL',
                                x_expenditure_item_id    in number,
                                x_sys_linkage_function   in varchar2,
				x_raw_cost_amount        in out NOCOPY pa_expenditure_items.raw_cost%type, --Changed for Bug#3858467
                                x_currency_code          in out NOCOPY pa_expenditure_items.denom_currency_code%type, --Changed for Bug#5594124
                                x_status                 in out NOCOPY number);

end PA_Costing_Client_Extns;

/
