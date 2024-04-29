--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_LIST_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_LIST_PRICE_PK" AUTHID CURRENT_USER as
/* $Header: CTOCULPS.pls 115.3 2002/05/08 11:47:56 pkm ship      $ */


/*---------------------------------------------------------------------------+
    This function tries to get the price list for the given model based ion the
    configurations selected in the oe_order_lines. The price list can be
    Org dependent. So this fucntion will take organization_id in the in parameteres.
    Note:By the time this function is called the config item is not yet created.
    So all the reference needs to go with the model item and the options selected
    in the sales order. The list price needs to be calculated per unit.
+----------------------------------------------------------------------------*/

function Get_list_Price(
	pModelLineId        in      number,                                  -- Model Line Id in oe_order_lines_all
        pInventory_item_id  in      Number,
        pOrganization_id    in      Number)
Return Number;

end CTO_CUSTOM_LIST_PRICE_PK;

 

/
