--------------------------------------------------------
--  DDL for Package Body ONT_COACOC_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_COACOC_PACKAGE" as
/*  $Header: ONTCOACB.pls 120.0 2005/06/01 02:57:49 appldev noship $ */

/* Check if a COA/COC is available for an order item */
procedure coaitem_avail ( p_headerid IN  NUMBER ,
			  p_line_id IN  NUMBER,
			  p_inventory_item_id IN  NUMBER,
p_return out nocopy number) is

			  --
			  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
			  --
begin

   p_return := 0;

end coaitem_avail;


/* Check if a COA/COC is available for a delivery item */
procedure coaitem_avail ( p_deliveryid IN  NUMBER ,
			  p_line_id IN  NUMBER,
p_return out nocopy number) is

			  --
			  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
			  --
begin

   p_return := 0;

end coaitem_avail;


end ont_coacoc_package;

/
