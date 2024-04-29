--------------------------------------------------------
--  DDL for Package INV_MINMAX_HELPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MINMAX_HELPER_PVT" AUTHID CURRENT_USER AS
/* $Header: INVMMXDS.pls 115.0 2001/02/12 17:51:18 pkm ship      $ */


function get_shipped_qty
  (p_organization_id	IN	NUMBER,
   p_inventory_item_id	IN	NUMBER,
   p_order_line_id      IN      NUMBER
   ) return number;

end inv_minmax_helper_pvt;

 

/
