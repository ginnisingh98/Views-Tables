--------------------------------------------------------
--  DDL for Package PA_COST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_UTILS" AUTHID CURRENT_USER as
  -- $Header: PAXCUTLS.pls 115.0 99/07/16 15:23:27 porting ship $

  function CDL_Exists( x_expenditure_item_id    IN     number)
    return boolean;

  function Related_Item_Exists( x_expenditure_item_id    IN     number)
    return boolean;

end PA_Cost_Utils;

 

/
