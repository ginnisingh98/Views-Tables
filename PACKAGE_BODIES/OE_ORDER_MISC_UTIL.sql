--------------------------------------------------------
--  DDL for Package Body OE_ORDER_MISC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_MISC_UTIL" AS
/* $Header: OEXMISCB.pls 120.1 2006/05/25 07:57:27 pkannan noship $ */

-- Bug 5244726
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_Misc_Util';

/* Procedure Get_Item_Info
-------------------------------------------------------
This procedure will return ordered_item, ordered_item_description and
inventory_item based on passing in item_identifier_type */

PROCEDURE GET_ITEM_INFO
(   x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   x_ordered_item          OUT NOCOPY VARCHAR2
,   x_ordered_item_desc     OUT NOCOPY VARCHAR2
,   x_inventory_item        OUT NOCOPY VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
) IS

l_organization_id   Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',p_org_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER GET_ITEM_INFO PROCEDURE' ) ;
       oe_debug_pub.add(  'ITEM_IDENTIFIER_TYPE : '||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'INVENTORY_ITEM_ID : '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'ORDERED_ITEM_ID : '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'ORDERED_ITEM : '||P_ORDERED_ITEM ) ;
       oe_debug_pub.add(  'SOLD_TO_ORG_ID : '||P_SOLD_TO_ORG_ID ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS; --bug 5064901

   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN

         SELECT  concatenated_segments
                ,concatenated_segments
                ,description
         INTO x_ordered_item
             ,x_inventory_item
             ,x_ordered_item_desc
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' AND
   p_ordered_item_id is not null and p_sold_to_org_id is not null  THEN

         SELECT citems.customer_item_number
               ,sitems.concatenated_segments
               ,nvl(citems.customer_item_desc, sitems.description)
         INTO  x_ordered_item
              ,x_inventory_item
              ,x_ordered_item_desc
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'CAT' THEN

         SELECT  category_concat_segs
                ,category_concat_segs
                ,description
         INTO x_ordered_item
             ,x_inventory_item
             ,x_ordered_item_desc
         FROM  mtl_categories_v
         WHERE CATEGORY_ID = p_inventory_item_id;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'ALL' THEN

      x_ordered_item  := NULL;
      x_inventory_item := NULL;
      x_ordered_item_desc := NULL;
   ELSE
        IF p_ordered_item_id IS NULL THEN
            SELECT   items.cross_reference
                    ,sitems.concatenated_segments
                    ,nvl(items.description, sitems.description)
            INTO   x_ordered_item
                  ,x_inventory_item
                  ,x_ordered_item_desc
            FROM  mtl_cross_reference_types types
              , mtl_cross_references items
              , mtl_system_items_vl sitems
            WHERE types.cross_reference_type = items.cross_reference_type
              AND items.inventory_item_id = sitems.inventory_item_id
              AND sitems.organization_id = l_organization_id
              AND sitems.inventory_item_id = p_inventory_item_id
              AND items.cross_reference_type = p_item_identifier_type
              AND items.cross_reference = p_ordered_item;

        END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT GET_ITEM_INFO PROCEDURE' ) ;
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR; --bug 5064901
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INT type : no_data_found' ) ;
        END IF;
    When too_many_rows then
        x_return_status := FND_API.G_RET_STS_ERROR; --bug 5064901
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INT type : too_many_rows' ) ;
        END IF;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; --bug 5064901
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INT type : others' ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,   'GET_ITEM_INFO');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ITEM_INFO;


FUNCTION CONVERT_UOM
(
  p_item_id   	   IN  NUMBER
, p_from_uom_code IN  VARCHAR2
, p_to_uom_code   IN  VARCHAR2
, p_from_qty  	   IN  NUMBER
) RETURN NUMBER
AS
  l_new_qty	NUMBER ;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
     IF p_from_qty IS NOT NULL THEN
       l_new_qty := INV_CONVERT.INV_UM_CONVERT(p_item_id
                                            ,9 -- Precision (Default precision is 6 decimals)
                                            ,p_from_qty
                                            ,p_from_uom_code
                                            ,p_to_uom_code
                                            ,NULL -- From uom name
                                            ,NULL -- To uom name
                                            );
     ELSE
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Convert from quantity is null value, not calling uom conversion api, return null for to_qty');
	END IF;
	l_new_qty:=null;
     END IF;

     RETURN l_new_qty;

EXCEPTION

  WHEN OTHERS THEN
 	RETURN -99999;

END CONVERT_UOM;

END OE_Order_Misc_Util;

/
