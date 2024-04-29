--------------------------------------------------------
--  DDL for Package Body PA_COST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_UTILS" as
  --  $Header: PAXCUTLB.pls 115.0 99/07/16 15:23:24 porting ship $

  function CDL_Exists( x_expenditure_item_id  IN  number)
   return boolean
   is
      dummy integer;
   begin

       --
       -- Verify if there is any CDL associated with this expenditure item.
       --

       SELECT 1
       INTO   dummy
       FROM   SYS.Dual
       WHERE  EXISTS
	      (SELECT 1
	       FROM   PA_Cost_Distribution_Lines
	       WHERE  Expenditure_Item_ID = x_expenditure_item_id);

       -- Find at least one CDL with the specified expenditure_item_id
       return(TRUE);

   exception
	when NO_DATA_FOUND then
	     return(FALSE);
   end CDL_Exists;


  function Related_Item_Exists( x_expenditure_item_id  IN  number)
   return boolean
   is
      dummy integer;
   begin

       --
       -- Verify if there is any related items associated with the source item
       --

       SELECT 1
       INTO   dummy
       FROM   SYS.Dual
       WHERE  EXISTS
	      (SELECT 1
	       FROM   PA_Expenditure_Items
	       WHERE  Source_Expenditure_Item_ID = x_expenditure_item_id);

       -- Find at least one related item with the specified expenditure_item_id
       return(TRUE);

   exception
	when NO_DATA_FOUND then
	     return(FALSE);
   end Related_Item_Exists;


end PA_Cost_Utils;

/
