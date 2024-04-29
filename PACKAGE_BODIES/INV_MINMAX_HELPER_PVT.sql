--------------------------------------------------------
--  DDL for Package Body INV_MINMAX_HELPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MINMAX_HELPER_PVT" AS
/* $Header: INVMMXDB.pls 115.1 2001/02/12 22:39:28 pkm ship      $ */

function get_shipped_qty
  (p_organization_id	IN	NUMBER,
   p_inventory_item_id	IN	NUMBER,
   p_order_line_id      IN      NUMBER
   ) return NUMBER
  IS
     l_shipped_qty NUMBER := 0;
BEGIN
   BEGIN
      SELECT SUM(primary_quantity)
	INTO l_shipped_qty
	FROM mtl_material_transactions
       WHERE transaction_action_id = 1
	 AND source_line_id = p_order_line_id
	 AND organization_id = p_organization_id
	 AND inventory_item_id = p_inventory_item_id;
   EXCEPTION
      WHEN OTHERS THEN
	 l_shipped_qty := 0;
   END ;

   IF l_shipped_qty IS NULL THEN l_shipped_qty := 0;
    ELSE l_shipped_qty := -1 * l_shipped_qty;
   END IF;

   RETURN l_shipped_qty;
END get_shipped_qty;

END inv_minmax_helper_pvt;

/
