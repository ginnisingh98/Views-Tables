--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_COSTING" as
/* $Header: PAXCCECB.pls 120.2 2007/02/06 09:28:07 rshaik ship $ */

  procedure Calc_Raw_Cost(
                           x_transaction_type       in varchar2 default 'ACTUAL',
                           x_expenditure_item_id    in number,
                           x_sys_linkage_function   in varchar2,
                           x_denom_raw_cost         in out NOCOPY pa_expenditure_items.raw_cost%type, --Changed for Bug#3858467
   			   x_denom_currency_code    in out NOCOPY pa_expenditure_items.denom_currency_code%type, --Added for Bug#5594124
                           x_status                 in out NOCOPY number    )
   is
   begin
	-- Reset the output parameters.
	x_denom_raw_cost := NULL;
	x_denom_currency_code := NULL; -- Added for bug#5594124
	x_status := 0;
       if ( x_transaction_type = 'ACTUAL') then
        if (x_sys_linkage_function = 'ST') then
	   -- Add your calculation of straight time expenditure item.
	   -- Do not add 'commit' or 'rollback' in your code, since Oracle
	   -- Project Accounting controls the transaction for you.
	   -- If the processing for straight time and overtime expenditure
	   -- items are identical, remove this 'if' statement.
	   null;
        else
	   -- Add your calculation of overtime expenditure item.
	   null;
        end if;
       elsif ( x_transaction_type = 'FORECAST') then
        -- Add your calculation for forecast
         null;
       end if;
   exception
	when others then
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to x_status.
	-- To raise an ORACLE error, assign SQLCODE to x_status.
        x_status := SQLCODE;
	null;

   end Calc_Raw_Cost;

end PA_Client_Extn_Costing;

/
