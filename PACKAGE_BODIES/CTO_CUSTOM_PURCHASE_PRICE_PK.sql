--------------------------------------------------------
--  DDL for Package Body CTO_CUSTOM_PURCHASE_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CUSTOM_PURCHASE_PRICE_PK" as
/* $Header: CTOCUPPB.pls 115.0 2002/03/26 21:22:25 pkm ship        $ */



/*---------------------------------------------------------------------------+
    This function tries to get the price list for the given model based ion the
    configurations selected in the oe_order_lines. The price list can be
    Org dependent. So this fucntion will take organization_id in the in parameteres.
    Note:By the time this function is called the config item is not yet created.
    So all the reference needs to go with the model item and the options selected
    in the sales order. If it returns null the models list price will be defaulted
    to Config item also.
+----------------------------------------------------------------------------*/

function Get_Purchase_price(
        p_item_id        in      number,
        p_vendor_id      in      Number,
        p_vendor_site_id in      Number)
Return Boolean IS

begin
	/*----------------------------------------------------------------+
	   This function can be replaced by custom code that will calculate
           the price list for this configuration.
        +-----------------------------------------------------------------*/

	return FALSE;
end Get_purchase_price;

end CTO_CUSTOM_PURCHASE_PRICE_PK;

/
