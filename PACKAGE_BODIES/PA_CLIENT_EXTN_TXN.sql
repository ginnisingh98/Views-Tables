--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_TXN" as
/*  $Header: PAXCCETB.pls 120.1.12000000.3 2007/04/11 08:41:13 srachako ship $ */

  procedure Add_Transactions( x_expenditure_item_id    IN     number,
                              x_sys_linkage_function   IN     varchar2,
                              x_status                 IN OUT NOCOPY number    ) is




   begin
	-- Initialize the output parameters.
	x_status := 0;

        if (x_sys_linkage_function = 'ST') then
            -- add your code for straight time expenditure item.
           -- Do not add 'commit' or 'rollback' in your code, since Oracle
           -- Project Accounting controls the transaction for you.
           -- If the processing for straight time and overtime expenditure
           -- items are identical, remove this 'if' statement.
           null;


        else
	   -- Add your code for overtime expenditure item.
	   null;
        end if;

   exception
	when others then
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to x_status.
	-- To raise an ORACLE error, assign SQLCODE to x_status.
	null;

   end Add_Transactions;


end PA_Client_Extn_Txn;

/
