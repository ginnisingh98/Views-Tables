--------------------------------------------------------
--  DDL for Package Body CTO_CUSTOM_LIST_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CUSTOM_LIST_PRICE_PK" as
/* $Header: CTOCULPB.pls 115.3 2002/05/08 11:47:55 pkm ship      $ */



/*---------------------------------------------------------------------------+
    This function tries to get the price list for the given model based ion the
    configurations selected in the oe_order_lines. The price list can be
    Org dependent. So this fucntion will take organization_id in the in parameteres.
    Note:By the time this function is called the config item is not yet created.
    So all the reference needs to go with the model item and the options selected
    in the sales order. If it returns null the models list price will be defaulted
    to Config item also.
+----------------------------------------------------------------------------*/

function Get_list_price(
        pModelLineId        in      number,  -- Model Line Id in oe_order_lines_all
        pInventory_item_id  in      Number,
        pOrganization_id    in      Number)
Return Number IS

begin
	/*----------------------------------------------------------------+
	   This function can be replaced by custom code that will calculate
           the price list for this configuration.
        +-----------------------------------------------------------------*/

	return NULL;
end Get_list_price;

end CTO_CUSTOM_LIST_PRICE_PK;

/
