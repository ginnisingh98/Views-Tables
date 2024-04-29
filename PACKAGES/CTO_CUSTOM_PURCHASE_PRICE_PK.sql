--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_PURCHASE_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_PURCHASE_PRICE_PK" AUTHID CURRENT_USER as
/* $Header: CTOCUPPS.pls 115.0 2002/03/26 21:22:41 pkm ship        $ */


/*---------------------------------------------------------------------------+
    This function tries to get the price list for the given model based ion the
    configurations selected in the oe_order_lines. The price list can be
    Org dependent. So this fucntion will take organization_id in the in parameteres.
    Note:By the time this function is called the config item is not yet created.
    So all the reference needs to go with the model item and the options selected
    in the sales order. The list price needs to be calculated per unit.
+----------------------------------------------------------------------------*/

function Get_purchase_Price(
        p_item_id           in      Number,
	p_vendor_id         in      Number,
	p_vendor_site_id    in      Number)
Return boolean;

end CTO_CUSTOM_PURCHASE_PRICE_PK;

 

/
