--------------------------------------------------------
--  DDL for Package Body GML_READ_IC_B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_READ_IC_B" AS
/* $Header: GMLRITMB.pls 115.5 2002/03/18 11:38:43 pkm ship     $ */

  /*##########################################################################
  #
  #  FUNCTION
  #   read_price_qty_source
  #
  #  DESCRIPTION         (see above)
  #
  #
  # MODIFICATION HISTORY
  # 18-JAN-2002  Plowe Created
  #########################################################################*/

FUNCTION read_price_qty_source

(
  p_inventory_item_id IN NUMBER
 ,p_ship_from_org_id  IN NUMBER
)

RETURN NUMBER IS


l_pricing_qty_source	NUMBER;


CURSOR c_opm_item ( discrete_org_id  IN NUMBER
                    ,discrete_item_id IN NUMBER) IS
       SELECT nvl(ont_pricing_qty_source,0)
       FROM  ic_item_mst_b
       WHERE delete_mark = 0
       AND   item_no in (SELECT segment1
         	FROM mtl_system_items
     	WHERE organization_id   = discrete_org_id
          AND   inventory_item_id = discrete_item_id);


BEGIN

       oe_debug_pub.add('OPM - Entering GML_READ_IC_B.read_price_qty_source', 5);


       OPEN c_opm_item( p_ship_from_org_id
                      , p_inventory_item_id);
       FETCH c_opm_item
         INTO l_pricing_qty_source;
         IF c_opm_item%NOTFOUND THEN
		/* clear the pricing_qty_source field in the cache */
               l_pricing_qty_source := NULL;
         END IF;

       RETURN (l_pricing_qty_source);

EXCEPTION
 WHEN OTHERS THEN
   RETURN (0);

END read_price_qty_source;

END GML_READ_IC_B;

/
