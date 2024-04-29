--------------------------------------------------------
--  DDL for Package Body ONT_ICP_PROCESS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ICP_PROCESS_PACKAGE" as
/*  $Header: ONTPROCB.pls 120.4 2005/09/28 00:38:13 shewgupt ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):= 'ONT_ICP_PROCESS_PACKAGE' ;

--Below procedures/functions obsoleted after inventory convergence project
/*
  function is_process_item(p_inventory_item_id in number,
                           p_ship_from_org_id in number)  return number is
  dummy_for_x   char(1);
  x_item_rec          OE_ORDER_CACHE.item_rec_type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  begin
     x_item_rec := OE_Order_Cache.Load_Item (p_inventory_item_id
                              ,p_ship_from_org_id);

   IF x_item_rec.process_warehouse_flag = 'Y' AND
      x_item_rec.dualum_ind in (0,1,2,3) THEN
    return  1;
  END IF;
    return  0;

  EXCEPTION
    when others then
     return 0;
  end is_process_item;

procedure is_process_installed (p_return out nocopy number) is

v_return boolean;
v_status varchar2(100);
v_industry varchar2(100);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 begin
 v_return := fnd_installation.get(555,555,v_status,v_industry);
 if v_return=TRUE then
   p_return := 1;
 else
   p_return := 0;

 end if;
 end is_process_installed;


function get_itemid(p_organization_id IN  NUMBER, p_inventory_item_id IN  NUMBER) return number is

   Cursor getitem(org_id number, item_id number) is
   SELECT item_id
   FROM  ic_item_mst
   WHERE delete_mark = 0
   AND   item_no in (SELECT segment1
	FROM mtl_system_items
	WHERE organization_id   = org_id
        AND   inventory_item_id = item_id);

    rItem getitem%ROWTYPE;
    vItem	number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
    BEGIN

	OPEN getitem(p_organization_id, p_inventory_item_id);
        	fetch getitem INTO rItem;
	CLOSE getitem;

	vItem := rItem.item_id;
	return vItem;

     EXCEPTION
	 when others then
     return 0;
  end get_itemid;


function get_lotid(p_inv_itemid IN  NUMBER, p_orgid IN NUMBER, p_lot_number IN  varchar2, p_sublot_number in varchar2) return number is

  l_item_id                ic_tran_pnd.item_id%TYPE;
  l_lot_id                 ic_tran_pnd.lot_id%TYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  BEGIN

	  SELECT iim.item_id INTO l_item_id
	  FROM   ic_item_mst iim,
	         mtl_system_items msi
	  WHERE  msi.inventory_item_id = p_inv_itemid
	  AND    msi.organization_id = p_orgid
	  AND    msi.segment1 = iim.item_no;


	  IF p_lot_number IS NULL
	  THEN
	    l_lot_id := 0;
	  ELSIF p_sublot_number IS NULL
	  THEN
	    SELECT lot_id INTO l_lot_id
	    FROM   ic_lots_mst
	    WHERE  item_id = l_item_id
	    AND    lot_no = p_lot_number;
	  ELSE
	    SELECT lot_id INTO l_lot_id
	    FROM   ic_lots_mst
	    WHERE  item_id = l_item_id
	    AND    lot_no = p_lot_number
	    AND    sublot_no = p_sublot_number;
	  END IF;

	return l_lot_id;

     EXCEPTION
	 when others then
     return 0;
  end get_lotid; */


--procedure added for inventory convergence project

procedure dual_uom_and_grade_control
(
p_inventory_item_id IN NUMBER ,
p_ship_from_org_id IN NUMBER := FND_API.G_MISS_NUM,
p_org_id IN NUMBER ,
x_dual_control_flag OUT NOCOPY VARCHAR2 ,
x_grade_control_flag OUT NOCOPY VARCHAR2,
x_wms_enabled_flag OUT NOCOPY VARCHAR2
)
IS
l_debug_level constant NUMBER := oe_debug_pub.g_debug_level ;
l_item_rec    OE_Order_Cache.item_rec_type ;
BEGIN

/* if both inventory_item_id and ship_from_org_id are passed then
   check id the item is dual_uom/grade controlled */
   IF ( p_inventory_item_id IS NOT NULL and
	p_inventory_item_id <> FND_API.G_MISS_NUM
	--p_ship_from_org_id IS NOT NULL and
	--p_ship_from_org_id <> FND_API.G_MISS_NUM
      )
   THEN
        l_item_rec := OE_Order_Cache.Load_Item( p_key1 => p_inventory_item_id
					       ,p_key2 => p_ship_from_org_id
					       ,p_key3 => p_org_id) ;
        if (l_debug_level >0 ) then
	   oe_debug_pub.add('Entering dual_uom_and_grade_control - tracking_quantity_ind ='||
				l_item_rec.tracking_quantity_ind ) ;
	end if ;
	IF l_item_rec.tracking_quantity_ind = 'PS' THEN
	    x_dual_control_flag := 'Y' ;
	    if (l_debug_level >0 ) then
	         oe_debug_pub.add('Dual UOM control is true');
	    end if ;
	ELSE
	    x_dual_control_flag := 'N' ;
	    if (l_debug_level >0 ) then
	         oe_debug_pub.add('Dual UOM control is false');
	    end if ;
	END IF ;

	IF l_item_rec.grade_control_flag = 'Y' THEN
	    x_grade_control_flag := 'Y' ;
	    if (l_debug_level >0 ) then
	         oe_debug_pub.add('Grade control is true');
	    end if ;
	ELSE
	    x_grade_control_flag := 'N' ;
	    if (l_debug_level >0 ) then
	         oe_debug_pub.add('Grade control is false');
	    end if ;
	END IF ;

	    x_wms_enabled_flag :=  l_item_rec.wms_enabled_flag ;
	    if (l_debug_level >0 ) then
	         oe_debug_pub.add('WMS Enabled Flag :'||x_wms_enabled_flag);
	    end if ;
   END IF ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	x_grade_control_flag := 'N' ;
	x_dual_control_flag := 'N' ;
	x_wms_enabled_flag := 'N' ;
	if (l_debug_level >0 ) then
	         oe_debug_pub.add('no_data_found in dual_uom_and_grade_control');
	end if ;
   WHEN OTHERS THEN
	if OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
		OE_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME ,
		  'Dual_Uom_And_Grade_Control'
		) ;
        end if ;
	if (l_debug_level >0 ) then
	         oe_debug_pub.add('Others in dual_uom_and_grade_control');
	end if ;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END dual_uom_and_grade_control ;

end ont_icp_process_package;

/
