--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BILLING" as
/* $Header: PAXICTMB.pls 120.1 2005/08/05 08:53:27 lveerubh noship $ */

  procedure Calc_Bill_Amount( x_transaction_type       in varchar2 default 'ACTUAL',
                              x_expenditure_item_id    in number,
                              x_sys_linkage_function   in varchar2,
                              x_amount                 in out NOCOPY number,
                              x_bill_rate_flag         in out NOCOPY  varchar2,
                              x_status                 in out NOCOPY number,
                              x_bill_trans_currency_code   out NOCOPY varchar2, /* following 4 new columns added for MCB2 */
                              x_bill_txn_bill_rate         out NOCOPY number,
                              x_markup_percentage          out NOCOPY number,
                              x_rate_source_id             out NOCOPY number)
  is
     l_amount                NUMBER(22,5);
     l_bill_rate_flag        VARCHAR2(1);
     l_status                NUMBER;
     l_bill_trans_currency_code VARCHAR2(30);
     l_bill_txn_bill_rate     NUMBER;
     l_markup_percentage      NUMBER;
     l_rate_source_id         NUMBER;
   begin
	-- Reset the output parameters.
	x_amount := NULL;
	x_bill_rate_flag := NULL;
	x_status := 0;
/*1673818 Comment modified from  x_bill_rate_flag to 'Y'  to  x_bill_rate_flag to 'B' */
	-- Add your calculation of bill amount here.
	-- Assign the result of bill amount to x_amount
	-- If you want a bill rate populated by Project Accounting, set
	-- x_bill_rate_flag to 'B' return rate in the x_bill_txn_bill_rate and if you are using markup, return
        -- markup percentage in the x_markup_percentage and populate the x_rate_source_id with unique identifier
        -- of the source that was used to derive the bill rate or markup. If x_bill_rate_flag's null or
        -- set to 'N', x_amount will be treated as a markup, and bill rate will not be populated.
        -- Do not add 'commit' or 'rollback' in your code, since Oracle
        -- Project Accounting controls the transaction for you.
        -- Added transaction type parameter possible values are 'ACTUAL','FORECAST' so do your calculation accordingly
   exception
	when others then
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to x_status.
	-- To raise an ORACLE error, assign SQLCODE to x_status.
	--Null out all the IN OUT and OUT parameters.
	null;

   end Calc_Bill_Amount;


end PA_Client_Extn_Billing;

/
