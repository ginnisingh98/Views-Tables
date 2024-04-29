--------------------------------------------------------
--  DDL for Package Body WSH_USA_QUANTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_USA_QUANTITY_PVT" as
/* $Header: WSHUSAQB.pls 120.11.12010000.2 2010/02/25 16:07:24 sankarun ship $ */


--G_PACKAGE_NAME         CONSTANT   VARCHAR2(50) := 'WSH_USA_QUANTITY_PVT';

-- Forward declaration for the procedures to be used in update_ordered_quantity

PROCEDURE log_exception(
  p_ship_from_location_id   IN   NUMBER,
  p_delivery_id       IN   NUMBER DEFAULT NULL,
  p_delivery_detail_id     IN  NUMBER,
  p_parent_delivery_detail_id  IN  NUMBER DEFAULT NULL,
  p_delivery_assignment_id   IN  NUMBER,
  p_inventory_item_id     IN   NUMBER,
  p_reason           IN  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2);

PROCEDURE Handle_Overpick_cancelled(
  p_source_line_id    IN  NUMBER,
  p_source_code       IN  VARCHAR2,
  p_context           IN  VARCHAR2,
  x_return_status     OUT NOCOPY    VARCHAR2);

-- HW OPMCONV - Removed p_process_flag parameter
PROCEDURE cancel_quantity(
  p_source_code       IN  VARCHAR2,
  p_source_header_id       IN NUMBER,   --  New
  p_source_line_id       IN NUMBER,   --  New
  p_delivery_detail_id     IN NUMBER,
  p_parent_delivery_detail_id  IN NUMBER DEFAULT NULL,
  p_serial_number       IN  VARCHAR2,
  p_transaction_temp_id   IN  NUMBER,
  p_released_status     IN  VARCHAR2,
  p_move_order_line_id     IN NUMBER,
  p_organization_id     IN  NUMBER,
  p_inventory_item_id     IN  NUMBER ,
  p_subinventory         IN VARCHAR2 ,
  p_revision           IN VARCHAR2 ,
  p_lot_number         IN VARCHAR2 ,
  p_locator_id         IN NUMBER ,
  p_ordered_quantity       IN NUMBER,
  p_requested_quantity     IN NUMBER,
  p_requested_quantity2   IN  NUMBER,
  p_picked_quantity     IN  NUMBER DEFAULT NULL,
  p_picked_quantity2       IN NUMBER DEFAULT NULL,
  p_shipped_quantity       IN NUMBER,
  p_shipped_quantity2     IN  NUMBER,
  p_changed_detail_quantity IN  NUMBER,
  p_changed_detail_quantity2   IN NUMBER,
  p_ship_tolerance_above   IN      NUMBER,
  p_serial_quantity        IN              NUMBER,
  p_replenishment_status   IN   VARCHAR2 DEFAULT NULL,  --bug# 6689448 (replenishment project)
  x_return_status       OUT NOCOPY    VARCHAR2);

-- Forward declaration for the procedures end


PROCEDURE Update_Ordered_Quantity(
p_changed_attribute    IN  WSH_INTERFACE.ChangedAttributeRecType
, p_source_code        IN  VARCHAR2
, p_action_flag        IN  VARCHAR2
, p_wms_flag           IN  VARCHAR2  DEFAULT 'N'
, p_context            IN  VARCHAR2  DEFAULT NULL
                                     -- determines context of quantity update:
                                     -- 'OVERPICK' = overpick normalization (bug 2942655 / 2936559)
                                     -- NULL = normal order line quantity update
, x_return_status      OUT NOCOPY   VARCHAR2
)
IS

--  R12, X-dock
--  If 'Released to Warehouse' lines have to be deleted from WSH, first line with NULL MOL should be
--  reduced/deleted and then either of details from Inventory or X-dock can be picked
--  Add nvl(move_order_line_id,0) asc to ORDER BY clause
CURSOR C_Old_Line is
SELECT  wdd.delivery_detail_id,
      wdd.serial_number,
      wdd.transaction_temp_id,
      wdd.source_line_id,
      wdd.pickable_flag,
      wdd.move_order_line_id,
      wdd.ship_from_location_id,
      wdd.organization_id,
      wdd.inventory_item_id,
      wdd.subinventory,
      wdd.revision,
      wdd.locator_id,
      wdd.lot_number,
      wdd.released_status,
      wdd.requested_quantity,
      wdd.picked_quantity,
      wdd.cancelled_quantity,
      wdd.shipped_quantity,
      wdd.requested_quantity2,
      wdd.picked_quantity2,
      wdd.cancelled_quantity2,
      wdd.shipped_quantity2,
          wdd.ship_tolerance_above,
    wda.parent_delivery_detail_id,
    wda.delivery_assignment_id,
    wnd.planned_flag,
    wnd.delivery_id,
    nvl(wnd.status_code,'NO') status_code,
    -- Included Shipment Batch Id for TPW - Distributed Organization Changes
    wdd.shipment_batch_id,
          0 serial_quantity,
	--OTM R12
	wdd.weight_uom_code,
	wdd.requested_quantity_uom,
	--
        wnd.ignore_for_planning, -- OTM R12 : update requested quantity change
        wnd.tms_interface_flag,   -- OTM R12 : update requested quantity change
        wdd.replenishment_status   --bug# 6689448 (replenishment project)
FROM    wsh_delivery_details wdd,
    wsh_new_deliveries wnd,
    wsh_delivery_assignments_v wda
WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
AND    wda.delivery_id = wnd.delivery_id (+)
AND    wdd.source_line_id = p_changed_attribute.source_line_id
AND    wdd.source_code  = p_source_code
AND    wdd.delivery_detail_id = decode (p_changed_attribute.delivery_detail_id,
           FND_API.G_MISS_NUM , wdd.delivery_detail_id ,
           p_changed_attribute.delivery_detail_id)
AND    wdd.container_flag = 'N'
AND    wdd.released_status <> 'D'   -- New
AND    DECODE(p_context, 'OVERPICK',wdd.requested_quantity,1) > 0 -- bug 2941581.  Skip the 0 requested quantities for overpick normalization.
ORDER BY  -- TPW - Distributed Organization Changes (Delivery Lines not associated with Shipment Batch has to be processed first)
      nvl(wdd.shipment_batch_id,-1) asc,
      decode(nvl(wnd.status_code,'NO'),'NO',1,'OP',2,10),
      decode(wda.parent_delivery_detail_id,NULL,1,10),
      decode(wnd.planned_flag,'N',1,'Y',2,'F',3,10),
      decode(wdd.released_status,'N',1,'R',2,'X',3,'B',4,'S',5,'Y',6,10),
      nvl(wdd.move_order_line_id,0) asc,
      nvl(wdd.requested_quantity,0) asc, -- This will make sure that maximum number of details are
      wdd.delivery_detail_id;     -- accounted for

CURSOR C_Old_Line_Ser is
SELECT  wdd.delivery_detail_id,
        wdd.serial_number,
        wdd.transaction_temp_id,
        wdd.source_line_id,
        wdd.pickable_flag,
        wdd.move_order_line_id,
        wdd.ship_from_location_id,
        wdd.organization_id,
        wdd.inventory_item_id,
        wdd.subinventory,
        wdd.revision,
        wdd.locator_id,
        wdd.lot_number,
        wdd.released_status,
        wdd.requested_quantity,
        wdd.picked_quantity,
        wdd.cancelled_quantity,
        wdd.shipped_quantity,
        wdd.requested_quantity2,
        wdd.picked_quantity2,
        wdd.cancelled_quantity2,
        wdd.shipped_quantity2,
        wdd.ship_tolerance_above,
        wda.parent_delivery_detail_id,
        wda.delivery_assignment_id,
        wnd.planned_flag,
        wnd.delivery_id,
        nvl(wnd.status_code,'NO') status_code,
        -- TPW - Distributed Organization Changes
        wdd.shipment_batch_id,
        sum(to_number(msnt.serial_prefix)) serial_quantity,
 	--OTM R12
	wdd.weight_uom_code,
	wdd.requested_quantity_uom,
	--
        wnd.ignore_for_planning, -- OTM R12 : update requested quantity change
        wnd.tms_interface_flag,   -- OTM R12 : update requested quantity change
        wdd.replenishment_status   --bug# 6689448 (replenishment project)
FROM      wsh_delivery_details wdd,
          wsh_new_deliveries wnd,
          wsh_delivery_assignments_v wda,
          mtl_serial_numbers_temp msnt
WHERE    wdd.delivery_detail_id = wda.delivery_detail_id
AND        wda.delivery_id = wnd.delivery_id (+)
AND        wdd.source_line_id = p_changed_attribute.source_line_id
AND        wdd.source_code      = p_source_code
AND        wdd.delivery_detail_id = decode (p_changed_attribute.delivery_detail_id,
                                   FND_API.G_MISS_NUM , wdd.delivery_detail_id ,
                                   p_changed_attribute.delivery_detail_id)
AND        wdd.container_flag = 'N'
AND        wdd.released_status <> 'D'
AND        wdd.transaction_temp_id = msnt.transaction_temp_id(+)
AND    DECODE(p_context, 'OVERPICK',wdd.requested_quantity,1) > 0 -- bug 2941581.  Skip the 0 requested quantities for overpick normalization.
GROUP BY  wdd.delivery_detail_id,
          wdd.serial_number,
          wdd.transaction_temp_id,
          wdd.source_line_id,
          wdd.pickable_flag,
          wdd.move_order_line_id,
          wdd.ship_from_location_id,
          wdd.organization_id,
          wdd.inventory_item_id,
          wdd.subinventory,
          wdd.revision,
          wdd.locator_id,
          wdd.lot_number,
          wdd.released_status,
          wdd.requested_quantity,
          wdd.picked_quantity,
          wdd.cancelled_quantity,
          wdd.shipped_quantity,
          wdd.requested_quantity2,
          wdd.picked_quantity2,
          wdd.cancelled_quantity2,
          wdd.shipped_quantity2,
          wdd.ship_tolerance_above,
          wda.parent_delivery_detail_id,
          wda.delivery_assignment_id,
          wnd.planned_flag,
          wnd.delivery_id,
          nvl(wnd.status_code,'NO'),
	  --OTM R12
	  wdd.weight_uom_code,
 	  wdd.requested_quantity_uom,
	  --
	  -- TPW - Distributed Organization Changes
          wdd.shipment_batch_id,
          wnd.ignore_for_planning, -- OTM R12 : update requested quantity change
          wnd.tms_interface_flag,  -- OTM R12 : update requested quantity change
          wdd.replenishment_status -- bug# 6689448 (replenishment project)
ORDER BY   -- TPW - Distributed Organization Changes (Delivery Lines not associated with Shipment Batch has to be processed first)
                  nvl(wdd.shipment_batch_id,-1) asc,
		  decode(nvl(wnd.status_code,'NO'),'NO',1,'OP',2,10),
                  decode(wda.parent_delivery_detail_id,NULL,1,10),
                  decode(wnd.planned_flag,'N',1,'Y',2,'F',3,10),
                  decode(wdd.released_status,'N',1,'R',2,'X',3,'B',4,'S',5,'Y',6,10),
                  nvl(wdd.move_order_line_id,0) asc,
                  nvl(wdd.requested_quantity,0) - decode(sum(to_number(msnt.serial_prefix)),NULL,decode(wdd.serial_number,NULL,0,1),
                                                         sum(to_number(msnt.serial_prefix))) desc,
                  nvl(wdd.requested_quantity,0) asc, -- This will make sure that maximum number of details are
                  wdd.delivery_detail_id;                       -- accounted for

CURSOR  C_sum_req_quantity is
SELECT  sum(nvl(requested_quantity,0)),sum(nvl(requested_quantity2,0))
FROM    wsh_delivery_details
WHERE  source_line_id = p_changed_attribute.source_line_id
AND    source_code =  p_source_code
GROUP BY  source_line_id;

CURSOR  C_get_others is
SELECT  organization_id,inventory_item_id,requested_quantity_uom,requested_quantity_uom2
FROM    wsh_delivery_details
WHERE  source_line_id = p_changed_attribute.source_line_id
AND    source_code = p_source_code
AND    rownum < 2;

CURSOR  c_is_ser_control (c_item_id NUMBER, c_organization_id NUMBER) is
select  serial_number_control_code
from    mtl_system_items
where   inventory_item_id = c_item_id
and     organization_id = c_organization_id ;

CURSOR c_shipping_parameters(c_organization_id NUMBER) IS
  SELECT freight_class_cat_set_id, commodity_code_cat_set_id, enforce_ship_set_and_smc  --
  FROM wsh_shipping_parameters
  WHERE organization_id = c_organization_id;

l_ship_parameters c_shipping_parameters%ROWTYPE;

 l_ship_set_id NUMBER;

CURSOR c_get_ship_set_name(c_set_id IN NUMBER) is
  SELECT set_name
  FROM oe_sets
  WHERE set_id = c_set_id;

  l_ship_set_name  VARCHAR2(30);

CURSOR c_check_smc_model_change (c_top_model_line_id NUMBER,
                              c_p_source_header_id NUMBER) IS
  SELECT top_model_line_id FROM
  wsh_delivery_details WHERE
  top_model_line_id = c_top_model_line_id AND
  source_code = 'OE' AND
  ship_model_complete_flag = 'Y' AND
  source_header_id = c_p_source_header_id AND
  released_status IN ('S', 'Y', 'C','I') AND
  rownum =1;

--bug#6407943.
CURSOR  C_item_details(c_organization_id NUMBER,c_item_id NUMBER)  IS
SELECT  primary_uom_code
from    mtl_system_items
where   inventory_item_id = c_item_id
and     organization_id = c_organization_id ;

l_primary_uom                 VARCHAR2(3);
--bug#6407943.

l_top_model_line_id     NUMBER;

old_delivery_detail_rec C_Old_line%ROWTYPE;

l_changed_line_quantity       NUMBER := 0;
l_changed_line_quantity2         NUMBER := 0;
l_changed_detail_quantity       NUMBER := 0;
l_changed_detail_quantity2       NUMBER := 0;
l_ready_release_change_qty       NUMBER := 0;
l_ready_release_change_qty2     NUMBER := 0;
l_original_ordered_quantity     NUMBER := 0;
l_new_ordered_quantity         NUMBER := 0;
l_valid_update_quantity       NUMBER := 0;
l_organization_id           NUMBER := 0;
l_inventory_item_id         NUMBER := 0;
l_src_requested_quantity_uom       VARCHAR2(3);
l_requested_quantity_uom         VARCHAR2(3);
l_requested_quantity_uom2       VARCHAR2(3);

l_exception_return_status       VARCHAR2(30);
l_exception_msg_count         NUMBER;
l_exception_msg_data           VARCHAR2(4000) := NULL;
l_exception_location_id       NUMBER;
l_exception_error_message       VARCHAR2(2000) := NULL;
l_exception_assignment_id       NUMBER;

l_delivery_detail_rec           wsh_glbl_var_strct_grp.delivery_details_rec_type;
l_delivery_assignments_info     WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_TYPE;
l_dummy_delivery_detail_id       NUMBER;
l_dummy_rowid             VARCHAR2(30);
l_dummy_id               NUMBER;

l_return_status           VARCHAR2(30);
l_rs_ignored                                            VARCHAR2(30);
l_api_version_number           NUMBER := 1.0;
l_msg_count             NUMBER;
l_msg_data               VARCHAR2(3000);
l_check_move_header         NUMBER;
l_message               VARCHAR2(2000);
l_ship_status             VARCHAR2(100);
l_released_status           VARCHAR2(100);
l_reason                 VARCHAR2(50);

l_changed_requested_quantity       NUMBER;
l_new_requested_quantity         NUMBER;
l_msg                 VARCHAR2(2000):=NULL;
l_counter               NUMBER := 0;

-- HW OPMCONV - Removed
l_new_requested_quantity2       NUMBER(19,9);
l_commit                 VARCHAR2(1);
-- HW OPMCONV - Removed format of 19,9
l_transfer_qty             NUMBER;
l_Changed_Quantity2         NUMBER(19,9);
-- HW OPMCONV - Removed format of 19,9
l_original_ordered_quantity2       NUMBER;
l_new_quantity2           NUMBER(19,9);
l_rsv_array             INV_RESERVATION_GLOBAL.mtl_reservation_tbl_type;
l_size                 NUMBER;

l_net_weight       NUMBER;
l_volume           NUMBER;

-- TPW - Distributed Organization Changes
l_wh_type            VARCHAR2(30);

l_ser_control      NUMBER;

create_detail_failure         EXCEPTION;
create_assignment_failure       EXCEPTION;
reject_update             EXCEPTION;
reject_delete             EXCEPTION;

l_details_id          WSH_UTIL_CORE.Id_Tab_Type;
delete_detail_failure      EXCEPTION;
invalid_smc_model_change            EXCEPTION;
invalid_ship_set                     EXCEPTION;

/* H projects: pricing integration csun */
i     NUMBER := 0;
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type;
mark_reprice_error  EXCEPTION;
-- deliveryMerge
Adjust_Planned_Flag_Err  EXCEPTION;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

--OTM R12
l_split_delivery_detail_tab	WSH_ENTITY_INFO_TAB;
l_split_delivery_detail_rec	WSH_ENTITY_INFO_REC;
l_item_quantity_uom_tab	        WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_gc3_is_installed              VARCHAR2(1);

-- OTM R12 : update requested quantity change
l_delivery_id_tab               WSH_UTIL_CORE.ID_TAB_TYPE;
l_interface_flag_tab            WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_call_update                   VARCHAR2(1);
-- End of OTM R12 : update requested quantity change
--
-- 5870774
l_oke_cancel_qty_allowed      NUMBER;
l_src_cancel_qty_allowed      NUMBER;

--
l_debug_on BOOLEAN;
--
l_test NUMBER;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UPDATE_ORDERED_QUANTITY';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_ACTION_FLAG',P_ACTION_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CONTEXT',P_CONTEXT);
       WSH_DEBUG_SV.log(l_module_name,'source_header_id',p_changed_attribute.source_header_id);
       WSH_DEBUG_SV.log(l_module_name,'original_source_line_id',p_changed_attribute.original_source_line_id);
       WSH_DEBUG_SV.log(l_module_name,'source_line_id',p_changed_attribute.source_line_id);
       WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',p_changed_attribute.delivery_detail_id);
       WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_changed_attribute.ordered_quantity);
       WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom',p_changed_attribute.order_quantity_uom);
       WSH_DEBUG_SV.log(l_module_name,'ordered_quantity2',p_changed_attribute.ordered_quantity2);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_QUANTITY_PVT.UPDATE_ORDERED_QUANTITY, ACTION = '|| P_ACTION_FLAG  );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --OTM R12 initialize
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   IF (l_gc3_is_installed IS NULL) THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;

   IF (l_gc3_is_installed = 'Y') THEN
     l_split_delivery_detail_tab := WSH_ENTITY_INFO_TAB();
     l_split_delivery_detail_tab.EXTEND;
   END IF;
   --

   OPEN  C_sum_req_quantity;
   FETCH C_sum_req_quantity INTO l_original_ordered_quantity,l_original_ordered_quantity2;
   CLOSE C_sum_req_quantity;

   OPEN  C_get_others;
   FETCH C_get_others INTO l_organization_id,l_inventory_item_id,l_requested_quantity_uom,l_requested_quantity_uom2;
   CLOSE C_get_others;

    -- TPW - Distributed Organization Changes - Start
   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                             p_organization_id => l_organization_id,
                             x_return_status   => l_return_status );

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
   END IF;

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      x_return_status := l_return_status;
      raise reject_update;
   END IF;
   -- TPW - Distributed Organization Changes - End


   --bug#6407943: begin.
   -- There is a possibility of having quantity change on delivery lines when there is a change in org
   -- value on sales order line and item's primary uom is different in old and new orgs.

   IF  ( (p_changed_attribute.ship_from_org_id <> FND_API.G_MISS_NUM)
          AND (p_changed_attribute.ship_from_org_id <> l_organization_id) )
          and (p_changed_attribute.inventory_item_id = FND_API.G_MISS_NUM ) THEN
   --{
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'inside primary UOM change checking.');
      END IF;
      OPEN  C_item_details(p_changed_attribute.ship_from_org_id,l_inventory_item_id);
      FETCH C_item_details INTO l_primary_uom;
      CLOSE C_item_details;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_primary_uom',l_primary_uom);
         WSH_DEBUG_SV.log(l_module_name,'l_requested_quantity_uom',l_requested_quantity_uom);
      END IF;
      IF (l_primary_uom <> l_requested_quantity_uom) THEN
         l_requested_quantity_uom := l_primary_uom;   --overrite the requested qty uom.
      END IF;
   --}
   END IF;
   --bug#6407943: end

   OPEN c_shipping_parameters(l_organization_id);
   FETCH c_shipping_parameters INTO l_ship_parameters;
    IF ( c_shipping_parameters%NOTFOUND ) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Shipping Parameters notfound for warehuse:'||l_organization_id);
      END IF;
      WSH_INTERFACE.PrintMsg(txt=>'Shipping Parameters notfound for warehouse:'||l_organization_id);
      END IF;
   CLOSE c_shipping_parameters;

   --
   -- Debug Statements
   --
--HW OPMCONV - Removed checking for process org and code forking

    IF (NVL(p_changed_attribute.ordered_quantity, 0) <> 0) THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_new_ordered_quantity := WSH_WV_UTILS.Convert_Uom(
            p_changed_attribute.order_quantity_uom,
            l_requested_quantity_uom, -- Converting UOM using any detail
            p_changed_attribute.ordered_quantity,
            l_inventory_item_id);
    ELSE
     l_new_ordered_quantity := p_changed_attribute.ordered_quantity;  -- In req quantity unit
      -- 5870774 for OKE
      if (p_source_code = 'OKE') then
      -- Then Cancel the entire Cancellable Qty.
      --
        begin
          select sum(wdd.requested_quantity)
          into  l_oke_cancel_qty_allowed
          from wsh_delivery_details wdd
          where
                wdd.source_line_id = p_changed_attribute.source_line_id
            and wdd.source_code   =  p_source_code
            and not exists (select 'x' from
                wsh_delivery_assignments wda,
                wsh_new_deliveries wnd
                where  wda.delivery_detail_id = wdd.delivery_detail_id
                  and  wda.delivery_id  = wnd.delivery_id
                  and  wnd.status_code in ('CL', 'IT', 'CO'));
        --
        exception
         WHEN NO_DATA_FOUND THEN
         --
         l_oke_cancel_qty_allowed := 0;
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         END IF;
         --
        end;

       --
        l_new_ordered_quantity := l_original_ordered_quantity - l_oke_cancel_qty_allowed;  -- In req quantity unit
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'New Ordered Qty: '|| l_new_ordered_quantity);
            WSH_DEBUG_SV.logmsg(l_module_name, 'OKE Req Qty. Cancellable : '|| l_oke_cancel_qty_allowed);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Orig. Req Qty. Cancellable : '|| l_original_ordered_quantity);
        END IF;
        --
      end if; -- OKE
     --
    END IF;

    l_changed_line_quantity := l_new_ordered_quantity - l_original_ordered_quantity;  --  In req quantity unit
       l_changed_detail_quantity := ABS(l_changed_line_quantity);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGE LINE QTY = '|| L_CHANGED_LINE_QUANTITY  );
    END IF;
    --
-- HW OPMCONV - Removed code forking

   if ( p_changed_attribute.ordered_quantity2 =  FND_API.G_MISS_NUM ) then
     l_new_requested_quantity2 := null ;
   else
     l_new_requested_quantity2 := p_changed_attribute.ordered_quantity2 ;
   end if ;


   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'l_original_ordered_quantity2 = '||l_original_ordered_quantity2 );
       WSH_DEBUG_SV.logmsg(l_module_name, 'p_changed_attribute.ordered_quantity2 = '||p_changed_attribute.ordered_quantity2  );
   END IF;

   l_changed_line_quantity2 := l_new_requested_quantity2 - l_original_ordered_quantity2;  --  In req quantity unit

   l_changed_detail_quantity2 := ABS(l_changed_line_quantity2);

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'NEW REQUESTED_QUANTITY2 = '||L_CHANGED_LINE_QUANTITY2  );
   END IF;
   --
   --
    -- 5870774: Update the new SRC requested qty. on the Wdds with Line_id = source_line_id
    --  otherwise all the Non_Cancelled Lines will show src_requested qty = 0, after call to UpdateRecords in WSHUSAAB.pls
    -- In WSHUSAAB.pls, we do not Re-update these lines Already Updated here for OKE and ord.qty=0 condition
    -- Note, the wdd record being cancelled will get Updated with src req. qty = 0 in this Package, so it is out of context below
    if (p_source_code = 'OKE' and p_changed_attribute.ordered_quantity = 0) THEN
       if ( p_changed_attribute.order_quantity_uom <> l_requested_quantity_uom ) then
               WSH_INTEGRATION.Get_Cancel_Qty_Allowed
                ( p_source_code             => p_source_code,
                  p_source_line_id          => p_changed_attribute.source_line_id,
                  x_cancel_qty_allowed      => l_src_cancel_qty_allowed,
                  x_return_status           => l_return_status,
                  x_msg_count               => l_msg_count,
                  x_msg_data                => l_msg_data
                 );
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,' l_return_status : ',l_return_status);
                  WSH_DEBUG_SV.log(l_module_name,' l_src_cancel_qty_allowed : ',l_src_cancel_qty_allowed);
               END IF;
        else
         l_src_cancel_qty_allowed := l_oke_cancel_qty_allowed;
        end if;
      --
      UPDATE WSH_DELIVERY_DETAILS
      set src_requested_quantity = (src_requested_quantity - l_src_cancel_qty_allowed),
          last_update_date  = SYSDATE,
          last_updated_by    = FND_GLOBAL.USER_ID,
          last_update_login  = FND_GLOBAL.LOGIN_ID
      where source_code  = p_source_code
      and source_line_id = p_changed_attribute.source_line_id;
       --
       IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,' After Update- l_src_cancel_qty_allowed : ',l_src_cancel_qty_allowed);
       END IF;
    end if;  -- OKE

    -- Check if Item is Serial Controlled
  --Bug 6669284
  --If the source is OKE and inventory item id is null skip serial control validation
  IF (p_source_code <> 'OKE' OR (p_source_code = 'OKE'AND l_inventory_item_id IS NOT NULL)) THEN
  OPEN c_is_ser_control(l_inventory_item_id, l_organization_id);
  FETCH c_is_ser_control INTO l_ser_control;
  IF c_is_ser_control%NOTFOUND THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'No records found in mtl_system_items for Item Id '||L_INVENTORY_ITEM_ID||' AND
                                           organization '||L_ORGANIZATION_ID  );
     END IF;
     raise no_data_found ;
  END IF;
  CLOSE c_is_ser_control;
  END IF;

  SAVEPOINT startloop;

  IF l_ser_control = 1 THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'OPEN C_OLD_LINE CURSOR');
     END IF;
     --
     OPEN C_Old_line;
  ELSE
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'OPEN C_OLD_LINE_SER CURSOR');
     END IF;
     --
     OPEN C_Old_line_ser;
  END IF;
  LOOP
  IF l_ser_control = 1 THEN
         FETCH C_Old_line INTO old_delivery_detail_rec;
         EXIT WHEN C_Old_line%NOTFOUND;
  ELSE
         FETCH C_Old_line_ser INTO old_delivery_detail_rec;
         EXIT WHEN C_Old_line_ser%NOTFOUND;
  END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'IN C_OLD_LINE LOOP : DEL DET', OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
     WSH_DEBUG_SV.log(l_module_name, 'L_READY_RELEASE_CHANGE_QTY', L_READY_RELEASE_CHANGE_QTY  );
     WSH_DEBUG_SV.log(l_module_name, 'L_CHANGED_DETAIL_QUANTITY', L_CHANGED_DETAIL_QUANTITY  );
     WSH_DEBUG_SV.log(l_module_name, 'l_changed_detail_quantity2', l_changed_detail_quantity2);
   END IF;
   --
   IF (p_action_flag = 'D') THEN

  /* csun: the delete details will release the reservation and delete
     delivery detail line, freight cost, delivery assignment entry
   */
  IF old_delivery_detail_rec.delivery_id is not NULL THEN
     i := i+1;
     l_del_tab(i) := old_delivery_detail_rec.delivery_id;
  END IF;

  IF (old_delivery_detail_rec.status_code =  'NO') AND --sperera 940/945
     (old_delivery_detail_rec.parent_delivery_detail_id IS NULL) THEN

       l_details_id.delete;
        l_details_id(1) := old_delivery_detail_rec.delivery_detail_id;

       --bug# 6689448 (replenishment project) (Begin) : added the code to call WMS api for replenshment requested delivery
       -- detail lines with zeqo qty so that WMS deletes the replenishment record.
       IF (old_delivery_detail_rec.replenishment_status = 'R' and old_delivery_detail_rec.released_status in ('R','B')) THEN
       --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL (
                p_delivery_detail_id => old_delivery_detail_rec.delivery_detail_id,
                p_primary_quantity   => 0, --- WMS will delete the records from replenishment table.
	        x_return_status      => x_return_status);
            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            --{
                 IF l_debug_on THEN
       	             WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
 	             WSH_DEBUG_SV.pop(l_module_name);
  	         END IF;
	         RETURN;
	    --}
            END IF;
       --}
       END IF;
       --bug# 6689448 (replenishment project):end

       WSH_INTERFACE.Delete_Details(
          p_details_id  => l_details_id ,
          x_return_status => l_return_status);

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'WSH_INTERFACE.DELETE_DETAILS l_return_status',l_return_status);
       END IF;

       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
         l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         raise delete_detail_failure;
       END IF;


  ELSE
    l_released_status := 'line is assigned to a delivery, or line is packed';
     -- If there exists any detail which is packed or in a planned or closed delivery or
       -- with released status other than N/R/X
       -- rollback the changes and reject the request
  ROLLBACK TO SAVEPOINT startloop;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'REJECT REQUEST AS SOME DELIVERY LINES ARE '||L_RELEASED_STATUS  );
    END IF;
    --
    FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_DELETE_QUANTITY');
    RAISE reject_delete;
  END IF;

   ELSIF (p_action_flag = 'U') THEN


/* Start updating quantities according to the rules */

  IF (l_changed_line_quantity > 0)
  OR ( (l_changed_line_quantity2 > 0) and (l_changed_line_quantity >= 0) )  -- OPM 2187389 need this to fix if qty2 increases but does not work for qty2 decrease

    THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_LINE_QUANTITY > 0'  );
         WSH_DEBUG_SV.logmsg(l_module_name, ' OR L_CHANGED_LINE_QUANTITY2 > 0'  );
     END IF;

     IF l_ship_parameters.enforce_ship_set_and_smc = 'Y' THEN
      --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'CHECKING SHIP SETS'  );
       END IF;
     --
        OPEN  c_check_smc_model_change(p_changed_attribute.top_model_line_id,p_changed_attribute.source_header_id);
        FETCH c_check_smc_model_change INTO l_top_model_line_id;
        IF c_check_smc_model_change%FOUND THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'INVALID CHANGES IN SMC MODEL'  );
          END IF;
          --  raise exception.
          CLOSE c_check_smc_model_change;
          RAISE invalid_smc_model_change;
        END IF;
        CLOSE c_check_smc_model_change;
      END IF;
    /* H Projects: pricing integration csun, added the delivery id here */
    IF old_delivery_detail_rec.delivery_id is not NULL THEN
        i := i+1;
        l_del_tab(i) := old_delivery_detail_rec.delivery_id;
          END IF;

-- Case I : Delvry Stat = OP/Unassigned Packed = N Planned = N Released Status = N/R/X
    --bug# 6689448 (replenishment project): Should not allow to add the qty on replenishment requested and replenishment completed details.
    IF ( ((old_delivery_detail_rec.status_code IN ('OP', 'SA', 'NO'))) AND -- sperera 940/945
     -- TPW - Distributed Organization Changes - Start
     ( nvl(l_wh_type, FND_API.G_MISS_CHAR) <> 'TW2' OR
       ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TW2' AND
         old_delivery_detail_rec.shipment_batch_id is null ) ) AND
     -- TPW - Distributed Organization Changes - End
     (old_delivery_detail_rec.parent_delivery_detail_id IS NULL) AND
     (NVL(old_delivery_detail_rec.planned_flag,'N') = 'N') AND
     ( NVL(old_delivery_detail_rec.released_status,'N') = 'N' or
       (NVL(old_delivery_detail_rec.released_status,'N') = 'R' AND old_delivery_detail_rec.replenishment_status is NULL) or
       NVL(old_delivery_detail_rec.released_status,'N') = 'X' ))  THEN
        --
        --
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Updating wsh_delivery_details', old_delivery_detail_rec.delivery_detail_id);
             WSH_DEBUG_SV.logmsg(l_module_name, 'Old value of requ_qty is ', old_delivery_detail_rec.requested_quantity );
             WSH_DEBUG_SV.logmsg(l_module_name, 'Old value of requ_qty2 is ' ,old_delivery_detail_rec.requested_quantity2 );
          END IF;

        UPDATE wsh_delivery_details SET
           requested_quantity   = old_delivery_detail_rec.requested_quantity + l_changed_detail_quantity,
           requested_quantity2  = old_delivery_detail_rec.requested_quantity2 + l_changed_line_quantity2, -- OPM B2187389
           last_update_date  = SYSDATE,
           last_updated_by    = FND_GLOBAL.USER_ID,
           last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE source_line_id = old_delivery_detail_rec.source_line_id
           AND delivery_detail_id = old_delivery_detail_rec.delivery_detail_id;

        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',old_delivery_detail_rec.delivery_detail_id);
        END IF;
        l_detail_tab(1) := old_delivery_detail_rec.delivery_detail_id;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
        --

        -- J: W/V Changes
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_WV_UTILS.Detail_Weight_Volume(
          p_delivery_detail_id => old_delivery_detail_rec.delivery_detail_id,
          p_update_flag        => 'Y',
          p_post_process_flag  => 'Y',
          p_calc_wv_if_frozen  => 'N',
          x_net_weight         => l_net_weight,
          x_volume             => l_volume,
          x_return_status      => l_rs_ignored);

        IF l_rs_ignored = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
          x_return_status := l_rs_ignored;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of W/V Changes

	--OTM R12, calling delivery detail splitter one record at a time here.
        --in this API, changed detail quantity will always be positive since if you decrease the
        --quantity, it will go to cancel_quantity API.
        --no need to validate l_changed_detail_quantity for NULL, should not be NULL from
        --above code.
	IF (l_changed_detail_quantity > 0 AND l_gc3_is_installed = 'Y') THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'delivery detail id',old_delivery_detail_rec.delivery_detail_id);
            WSH_DEBUG_SV.log(l_module_name,'inventory item id',old_delivery_detail_rec.inventory_item_id);
            WSH_DEBUG_SV.log(l_module_name,'net weight',l_net_weight);
            WSH_DEBUG_SV.log(l_module_name,'organization id',old_delivery_detail_rec.organization_id);
            WSH_DEBUG_SV.log(l_module_name,'weight uom code',old_delivery_detail_rec.weight_uom_code);
            WSH_DEBUG_SV.log(l_module_name,'requested quantity',old_delivery_detail_rec.requested_quantity + l_changed_detail_quantity);
            WSH_DEBUG_SV.log(l_module_name,'ship from location id',old_delivery_detail_rec.ship_from_location_id);
            WSH_DEBUG_SV.log(l_module_name,'requested quantity uom',old_delivery_detail_rec.requested_quantity_uom);
          END IF;

          --prepare table of delivery detail information to call splitter
	  l_split_delivery_detail_tab(1) := WSH_ENTITY_INFO_REC(
					old_delivery_detail_rec.delivery_detail_id,
					NULL,
					old_delivery_detail_rec.inventory_item_id,
					l_net_weight,
					0,
					old_delivery_detail_rec.organization_id,
					old_delivery_detail_rec.weight_uom_code,
					old_delivery_detail_rec.requested_quantity + l_changed_detail_quantity,
					old_delivery_detail_rec.ship_from_location_id,
					NULL);
	  l_item_quantity_uom_tab(1)   := old_delivery_detail_rec.requested_quantity_uom;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split(
	               	p_detail_tab            => l_split_delivery_detail_tab,
			p_item_quantity_uom_tab => l_item_quantity_uom_tab,
	             	x_return_status         => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split: ' || l_return_status);
          END IF;

	  -- we will not fail based on l_return_status here because
          -- we do not want to stop the flow
          -- if the detail doesn't split, it will be caught later in
          -- delivery splitting and will have exception on the detail
          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery detail split failed for ' || old_delivery_detail_rec.delivery_detail_id );
            END IF;
          END IF;
          --END splitter call

          -- OTM R12 : update requested quantity change
          l_call_update := 'Y';

          IF (old_delivery_detail_rec.delivery_id IS NOT NULL AND
              nvl(old_delivery_detail_rec.ignore_for_planning, 'N') = 'N') THEN
            l_delivery_id_tab.DELETE;
            l_interface_flag_tab.DELETE;
            l_delivery_id_tab(1) := old_delivery_detail_rec.delivery_id;

            -- calculate the interface flag to be updated
            IF old_delivery_detail_rec.tms_interface_flag IN
               (WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED,
                WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS) THEN
              l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id_tab', l_delivery_id_tab(1));
                WSH_DEBUG_SV.log(l_module_name, 'l_interface_flag_tab', l_interface_flag_tab(1));
              END IF;
            ELSE
              l_call_update := 'N';
            END IF;


            IF (l_call_update = 'Y') THEN
              WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                      p_delivery_id_tab        => l_delivery_id_tab,
                      p_tms_interface_flag_tab => l_interface_flag_tab,
                      x_return_status          => l_return_status);

              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                x_return_status := l_return_status;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN;
              END IF;
            END IF;
          END IF;
          -- End of OTM R12 : update requested quantity change
	END IF;
	--END OTM R12


-- Case II : Everything other than Case I

    ELSE

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Need to create a new delivery detail');
        WSH_DEBUG_SV.log(l_module_name, 'l_changed_detail_quantity', l_changed_detail_quantity);
        WSH_DEBUG_SV.log(l_module_name, 'l_changed_detail_quantity2', l_changed_detail_quantity2);
      END IF;
      IF (NVL(old_delivery_detail_rec.released_status,'N') <> 'D') THEN -- This is to avoid 'D' lines

           l_delivery_detail_rec.requested_quantity := l_changed_detail_quantity;
           --
           -- Bug 2754311
           --
-- HW OPMCONV - Removed code forking and fixed the condition
            IF ( old_delivery_detail_rec.requested_quantity2 <> FND_API.G_MISS_NUM
                  OR old_delivery_detail_rec.requested_quantity2 IS NOT NULL ) THEN
                l_delivery_detail_rec.requested_quantity2 := l_changed_detail_quantity2;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_changed_detail_quantity2', l_changed_detail_quantity2);
                   WSH_DEBUG_SV.log(l_module_name,'New_DD.req_qty2', l_delivery_detail_rec.requested_quantity2);
               END IF;
             ELSE
               l_delivery_Detail_rec.requested_quantity2 := FND_API.G_MISS_NUM;
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'IN ELSE AND l_changed_detail_quantity2', l_changed_detail_quantity2);
             END IF;
           END IF;
           --
           l_delivery_detail_rec.picked_quantity := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.picked_quantity2 := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.cancelled_quantity := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.cancelled_quantity2 := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.move_order_line_id := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.shipped_quantity :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.shipped_quantity2 :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.delivered_quantity :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.delivered_quantity2 :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.quality_control_quantity :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.quality_control_quantity2 :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.cycle_count_quantity :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.cycle_count_quantity2 :=  FND_API.G_MISS_NUM;
           l_delivery_detail_rec.subinventory := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.revision  := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.lot_number := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.locator_id := FND_API.G_MISS_NUM;

           l_delivery_detail_rec.master_serial_number := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.serial_number := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.to_serial_number := FND_API.G_MISS_CHAR;
           l_delivery_detail_rec.transaction_temp_id := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.transaction_id := FND_API.G_MISS_NUM; -- 2803570

           -- TPW - Distributed Organization Changes - Start
           l_delivery_detail_rec.shipment_batch_id := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.shipment_line_number := FND_API.G_MISS_NUM;
           l_delivery_detail_rec.reference_line_id := FND_API.G_MISS_NUM;
           -- TPW - Distributed Organization Changes - End

           -- bug # 6719369 (replenishment project)
           l_delivery_detail_rec.replenishment_status := FND_API.G_MISS_CHAR;


           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATED MOVE ORDER LINE TO NULL FOR NEW DD '||L_DUMMY_DELIVERY_DETAIL_ID  );
           END IF;
           --

           IF (NVL(old_delivery_detail_rec.released_status, 'N') <> 'N') THEN
            IF (old_delivery_detail_rec.pickable_flag = 'N') THEN
             l_delivery_detail_rec.released_status := 'X';
            ELSE
             l_delivery_detail_rec.released_status := 'R';
            END IF;
           END IF;

           l_dummy_delivery_detail_id := null;
           --
           WSH_DELIVERY_DETAILS_PKG.create_new_detail_from_old(
              p_delivery_detail_rec  =>  l_delivery_detail_rec,
              p_delivery_detail_id    =>   old_delivery_detail_rec.delivery_detail_id,
              x_row_id          =>   l_dummy_rowid,
              x_delivery_detail_id    =>   l_dummy_delivery_detail_id,
              x_return_status      =>  l_return_status);

           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'create_new_detail_from_old l_dummy_rowid,
                                                        l_dummy_delivery_detail_id,l_return_status',l_dummy_rowid||','||
                                                         l_dummy_delivery_detail_id||','||l_return_status);
           END IF;



           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RAISE create_detail_failure;
           END IF;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'CREATED DETAIL ID',L_DUMMY_DELIVERY_DETAIL_ID);
                   WSH_DEBUG_SV.log(l_module_name,'New_DD.req_qty2', l_delivery_detail_rec.requested_quantity2);
          END IF;
          --


           -- for each delivery detail, there is at least one delivery
           -- assignment

           l_delivery_assignments_info.delivery_detail_id := l_dummy_delivery_detail_id;
           l_delivery_assignments_info.delivery_id := NULL;
           l_delivery_assignments_info.parent_delivery_detail_id := NULL;

           WSH_DELIVERY_DETAILS_PKG.Create_delivery_assignments(
           p_delivery_assignments_info   =>  l_delivery_assignments_info,
           x_rowid             =>  l_dummy_rowid,
           x_delivery_assignment_id   =>  l_dummy_id,
           x_return_status         =>  l_return_status);

           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Create_delivery_assignments l_dummy_rowid,
                                                        l_dummy_id,l_return_status',l_dummy_rowid||','||
                                                         l_dummy_id||','||l_return_status);
           END IF;

           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RAISE create_assignment_failure;
           END IF;

            -- Bug 2349276 recalculate wt/vol if qty. changes - ignore return_status
                                   WSH_WV_UTILS.Detail_Weight_Volume
                                             (p_delivery_detail_id => l_dummy_delivery_detail_id,
                                              p_update_flag => 'Y',
                                              x_net_weight => l_net_weight,
                                              x_volume => l_volume,
                                              x_return_status => l_rs_ignored);
           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Detail_Weight_Volume l_net_weight,l_volume,
                                                      l_rs_ignored',l_net_weight||','||l_volume||','||l_rs_ignored);
           END IF;
           -- J: W/V Changes
           IF l_rs_ignored = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             x_return_status := l_rs_ignored;
             IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             return;
           END IF;
           -- End of W/V Changes

	   --OTM R12, call to delivery detail splitter, process one record at a time here.
	   IF (l_gc3_is_installed = 'Y') THEN

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'delivery detail id',l_dummy_delivery_detail_id);
               WSH_DEBUG_SV.log(l_module_name,'inventory item id',old_delivery_detail_rec.inventory_item_id);
               WSH_DEBUG_SV.log(l_module_name,'net weight',l_net_weight);
               WSH_DEBUG_SV.log(l_module_name,'organization id',old_delivery_detail_rec.organization_id);
               WSH_DEBUG_SV.log(l_module_name,'weight uom code',old_delivery_detail_rec.weight_uom_code);
               WSH_DEBUG_SV.log(l_module_name,'requested quantity',l_changed_detail_quantity);
               WSH_DEBUG_SV.log(l_module_name,'ship from location id',old_delivery_detail_rec.ship_from_location_id);
               WSH_DEBUG_SV.log(l_module_name,'requested quantity uom',old_delivery_detail_rec.requested_quantity_uom);
             END IF;

             --prepare table of delivery detail information to call splitter
             l_split_delivery_detail_tab(1) := WSH_ENTITY_INFO_REC(
		l_dummy_delivery_detail_id,
		NULL,
		old_delivery_detail_rec.inventory_item_id,
		l_net_weight,
		0,
		old_delivery_detail_rec.organization_id,
		old_delivery_detail_rec.weight_uom_code,
		l_changed_detail_quantity,
		old_delivery_detail_rec.ship_from_location_id,
		NULL);
             l_item_quantity_uom_tab(1)   := old_delivery_detail_rec.requested_quantity_uom;

             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split(
	       	  	p_detail_tab            => l_split_delivery_detail_tab,
			p_item_quantity_uom_tab => l_item_quantity_uom_tab,
	   		x_return_status         => l_return_status);

             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split: ' || l_return_status);
             END IF;

             -- we will not fail based on l_return_status here because
             -- we do not want to stop the flow
             -- if the detail doesn't split, it will be caught later in
             -- delivery splitting and will have exception on the detail
             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery detail split failed for ' || l_dummy_delivery_detail_id );
               END IF;
             END IF;

           END IF;
           --END OTM R12


      END IF; -- Released status Not D
    END IF; -- Case I / Case II

    /* LG for OPM need to update the inv*/
--HW OPMCONV - Removed code forking

    EXIT;   --  Exit delivery details loop as for increase in order line quantity the first detail obtained for the
      --  source line will be sufficient to define the course of action

   -- Decrease in order quantity

  ELSIF (l_changed_line_quantity < 0) THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_LINE_QUANTITY < 0 '  );
    END IF;
    --

     /* H Projects: pricing integration csun, added the delivery id here */
     IF old_delivery_detail_rec.delivery_id is not NULL THEN
     i := i+1;
     l_del_tab(i) := old_delivery_detail_rec.delivery_id;
     END IF;


    IF ((old_delivery_detail_rec.status_code IN ('OP', 'NO', 'SA')) ) THEN -- Include unassigned lines here
                                        -- sperera 940/945


-- Case I : Delvry Stat = OP Packed = N Planned = N

     IF (old_delivery_detail_rec.parent_delivery_detail_id IS NULL)  -- Packed = N
      AND ( NVL(old_delivery_detail_rec.planned_flag,'N') = 'N') -- Planned = N
-- Released Status = N/R/B/X/S

      AND (NVL(old_delivery_detail_rec.released_status,'N') = 'N' or
         NVL(old_delivery_detail_rec.released_status,'N') = 'R' or
         NVL(old_delivery_detail_rec.released_status,'N') = 'X' or
         NVL(old_delivery_detail_rec.released_status,'N') = 'B' or
         NVL(old_delivery_detail_rec.released_status,'N') = 'S') THEN
                        -- Bug 2531155: quantity changes can cause data corruption in WMS
                        -- Bug 2779304: allow full cancellation if released to warehouse in WMS
                        -- X-dock lines with MOL null can be processed, but not if progressed
                        -- to Released to warehouse.
                        IF     NVL(old_delivery_detail_rec.released_status,'N') = 'S'
                           AND old_delivery_detail_rec.move_order_line_id IS NOT NULL
                           AND p_wms_flag = 'Y'
                           AND p_changed_attribute.ordered_quantity > 0 THEN
                           ROLLBACK TO SAVEPOINT startloop;
                           FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_UPDATE_NOT_ALLOWED');
                           RAISE reject_update;
                        END IF;
      cancel_quantity(
                                                 p_inventory_item_id => NULL,
                                                 p_subinventory => NULL,
                                                 p_revision=> NULL,
                                                 p_lot_number => NULL,
                                                 p_locator_id => NULL,
-- HW OPMCONV - Removed populating process_flag

             p_source_code        =>  p_source_code,
             p_source_header_id      => p_changed_attribute.source_header_id,
             p_source_line_id      => old_delivery_detail_rec.source_line_id,
             p_delivery_detail_id    => old_delivery_detail_rec.delivery_detail_id,
             p_serial_number        =>  old_delivery_detail_rec.serial_number,
             p_transaction_temp_id    =>  old_delivery_detail_rec.transaction_temp_id,
             p_released_status      =>  old_delivery_detail_rec.released_status,
             p_move_order_line_id    => old_delivery_detail_rec.move_order_line_id,
             p_organization_id      =>  old_delivery_detail_rec.organization_id,
             p_ordered_quantity      => p_changed_attribute.ordered_quantity,
             p_requested_quantity    => old_delivery_detail_rec.requested_quantity,
             p_requested_quantity2    =>  old_delivery_detail_rec.requested_quantity2,
             p_picked_quantity      =>  old_delivery_detail_rec.picked_quantity,
             p_picked_quantity2      => old_delivery_detail_rec.picked_quantity2,
             p_shipped_quantity      => old_delivery_detail_rec.shipped_quantity,
             p_shipped_quantity2      =>  old_delivery_detail_rec.shipped_quantity2,
             p_changed_detail_quantity  =>  l_changed_detail_quantity,
             p_changed_detail_quantity2   =>  l_changed_line_quantity2, -- OPM B2187389,
             p_ship_tolerance_above    =>   old_delivery_detail_rec.ship_tolerance_above,
             p_serial_quantity         =>           old_delivery_detail_rec.serial_quantity,
             p_replenishment_status    => old_delivery_detail_rec.replenishment_status, --bug# 6689448 (replenishment project)
             x_return_status        =>  l_return_status);

                  IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name, 'l_return_status',l_return_status);
                  END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLING QUANTITY FAILED FOR DETAIL '||OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
         END IF;
         --
         x_return_status := l_return_status;
         IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
         ELSE
          wsh_util_core.default_handler('WSH_USA_QUANTITY_PVT.cancel_quantity',l_module_name);
         END IF;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
      END IF;

     IF old_delivery_detail_rec.released_status in ('N','R','B')  THEN
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'L_READY_RELEASE_CHANGE_QTY :'||L_READY_RELEASE_CHANGE_QTY  );
       WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_DETAIL_QUANTITY :'||L_CHANGED_DETAIL_QUANTITY  );
      END IF;


      l_ready_release_change_qty := l_ready_release_change_qty + least(l_changed_detail_quantity, old_delivery_detail_rec.requested_quantity) ;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REQUESTED_QTY:'||OLD_DELIVERY_DETAIL_REC.REQUESTED_QUANTITY);
        WSH_DEBUG_SV.logmsg(l_module_name,'L_READY_RELEASE_CHANGE_QTY :'||L_READY_RELEASE_CHANGE_QTY  );
        WSH_DEBUG_SV.logmsg(l_module_name,'BEFORE  L_READY_RELEASE_CHANGE_QTY2 :'||L_READY_RELEASE_CHANGE_QTY2  );
        WSH_DEBUG_SV.logmsg(l_module_name,'BEFORE  old_delivery_detail_rec.requested_quantity2 :'||old_delivery_detail_rec.requested_quantity2  );
      END IF;

-- HW OPMCONV - Calculate Qty2 similar to Qty1
      l_ready_release_change_qty2 := l_ready_release_change_qty2 + least(l_changed_line_quantity2, old_delivery_detail_rec.requested_quantity2) ;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REQUESTED_QTY2:'||OLD_DELIVERY_DETAIL_REC.REQUESTED_QUANTITY2);
        WSH_DEBUG_SV.logmsg(l_module_name,'IN ONE L_READY_RELEASE_CHANGE_QTY2 :'||L_READY_RELEASE_CHANGE_QTY2  );
        WSH_DEBUG_SV.logmsg(l_module_name,'IN ONE l_changed_line_quantity2 :'||l_changed_line_quantity2  );
      END IF;
     END IF;

     -- when we have consumed the quantity to cancel, exit the loop.
     IF (old_delivery_detail_rec.requested_quantity >= ABS(l_changed_detail_quantity)) THEN
          Handle_Overpick_cancelled(
              p_source_line_id =>   p_changed_attribute.source_line_id,
              p_source_code    =>   p_source_code,
              p_context        =>   p_context,
              x_return_status  =>   l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Handle_Overpick_cancelled l_return_status',l_return_status);
          END IF;
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATING OVERPICKED LINES API FAILED '  );
            END IF;
            --
            x_return_status := l_return_status;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            return;
          END IF;
       EXIT;
     END IF;


     l_changed_detail_quantity := l_changed_detail_quantity - old_delivery_detail_rec.requested_quantity;
     l_changed_detail_quantity2 := l_changed_detail_quantity2 - old_delivery_detail_rec.requested_quantity2;

       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_DETAIL_QUANTITY :'||L_CHANGED_DETAIL_QUANTITY  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_DETAIL_QUANTITY2 :'||L_CHANGED_DETAIL_QUANTITY2  );
       END IF;
       --

     ELSE  -- Everything else
      -- WMS check for released to warehouse or staged lines
                        -- bug 2779304: if released to warehouse, disallow partial cancellation
                        --              and allow full cancellation
      IF p_wms_flag = 'Y'
                           AND (   NVL(old_delivery_detail_rec.released_status,'N') = 'Y'
                                OR (    NVL(old_delivery_detail_rec.released_status,'N') = 'S'
                                    AND p_changed_attribute.ordered_quantity > 0))  THEN
         ROLLBACK TO SAVEPOINT startloop;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_UPDATE_NOT_ALLOWED');
         RAISE reject_update;
      END IF;

      IF (old_delivery_detail_rec.parent_delivery_detail_id IS NOT NULL) THEN  -- Packed = Y
         l_reason := 'WSH_CANCELLED_PACKED';
      ELSIF ( NVL(old_delivery_detail_rec.planned_flag,'N') IN ('Y','F')) THEN -- Planned =Y
         l_reason := 'WSH_CANCELLED_PLANNED';
      ELSIF (NVL(old_delivery_detail_rec.released_status,'N') = 'Y') THEN  -- Released Status = Y :
         l_reason := 'WSH_CANCELLED_RELEASED';
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'LOGGING EXCEPTION FOR DETAIL: '|| OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
      END IF;
      --
      log_exception(
           p_ship_from_location_id   =>  old_delivery_detail_rec.ship_from_location_id,
           p_delivery_id       =>  old_delivery_detail_rec.delivery_id,
           p_delivery_detail_id   =>   old_delivery_detail_rec.delivery_detail_id,
           p_parent_delivery_detail_id   =>  old_delivery_detail_rec.parent_delivery_detail_id,
           p_delivery_assignment_id  =>  old_delivery_detail_rec.delivery_assignment_id,
           p_inventory_item_id     =>  old_delivery_detail_rec.inventory_item_id,
           p_reason         =>   l_reason,
           x_return_status       =>  l_return_status);
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'log_exception l_return_status',l_return_status);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'LOGGING EXCEPTION FAILED WITH '||L_RETURN_STATUS  );
         END IF;
         --
         x_return_status := l_return_status;
         IF (l_return_status IN (FND_API.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
          FND_MESSAGE.SET_NAME('WSH', 'Error in logging exception');
          WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
         ELSE
          wsh_util_core.default_handler('WSH_USA_QUANTITY_PVT.log_exception',l_module_name);
         END IF;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING CANCEL_QUANTITY FOR DETAIL '||OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
      END IF;
      --

-- HW OPMCONV - Removed l_process_flag parameter
      cancel_quantity(
             p_source_code        =>  p_source_code,
             p_source_header_id      => p_changed_attribute.source_header_id,
             p_source_line_id      => old_delivery_detail_rec.source_line_id,
             p_delivery_detail_id    => old_delivery_detail_rec.delivery_detail_id,
             p_parent_delivery_detail_id  =>  old_delivery_detail_rec.parent_delivery_detail_id,
             p_serial_number        =>  old_delivery_detail_rec.serial_number,
             p_transaction_temp_id    =>  old_delivery_detail_rec.transaction_temp_id,
             p_released_status      =>  old_delivery_detail_rec.released_status,
             p_move_order_line_id    => old_delivery_detail_rec.move_order_line_id,
             p_organization_id      =>  old_delivery_detail_rec.organization_id,
             p_inventory_item_id      =>  old_delivery_detail_rec.inventory_item_id,
             p_subinventory        => old_delivery_detail_rec.subinventory,
             p_revision          => old_delivery_detail_rec.revision,
             p_lot_number        => old_delivery_detail_rec.lot_number,
             p_locator_id        => old_delivery_detail_rec.locator_id,
             p_ordered_quantity      => p_changed_attribute.ordered_quantity,
             p_requested_quantity    => old_delivery_detail_rec.requested_quantity,
             p_requested_quantity2    =>  old_delivery_detail_rec.requested_quantity2,
             p_picked_quantity      =>  old_delivery_detail_rec.picked_quantity,
             p_picked_quantity2      => old_delivery_detail_rec.picked_quantity2,
             p_shipped_quantity      => old_delivery_detail_rec.shipped_quantity,
             p_shipped_quantity2      =>  old_delivery_detail_rec.shipped_quantity2,
             p_changed_detail_quantity  =>  l_changed_detail_quantity,
             p_changed_detail_quantity2   =>  l_changed_line_quantity2,  -- OPM B2187389
             p_ship_tolerance_above    =>   old_delivery_detail_rec.ship_tolerance_above,
             p_serial_quantity         =>           old_delivery_detail_rec.serial_quantity,
             p_replenishment_status    => old_delivery_detail_rec.replenishment_status, --bug# 6689448 (replenishment project)
                 x_return_status        =>  l_return_status);
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'cancel_quantity l_return_status',l_return_status);
      END IF;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLING QUANTITY FAILED FOR DETAIL '||OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
        END IF;
        --
        x_return_status := l_return_status;
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
        ELSE
        wsh_util_core.default_handler('WSH_USA_QUANTITY_PVT.cancel_quantity',l_module_name);
        END IF;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
      END IF;

        IF old_delivery_detail_rec.released_status in ('N','R','B')  THEN
          l_ready_release_change_qty := l_ready_release_change_qty + LEAST(l_changed_detail_quantity, old_delivery_detail_rec.requested_quantity) ;
--HW OPMCONV Let's treat Qty2 similar to Qty1
          l_ready_release_change_qty2 := l_ready_release_change_qty2 + LEAST(l_changed_detail_quantity2,old_delivery_detail_rec.requested_quantity2) ;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'REQUESTED_QTY2:'||OLD_DELIVERY_DETAIL_REC.REQUESTED_QUANTITY2);
            WSH_DEBUG_SV.logmsg(l_module_name,'IN TWO L_READY_RELEASE_CHANGE_QTY2 :'||L_READY_RELEASE_CHANGE_QTY2  );
          END IF;

        END IF;

        -- when we have consumed the quantity to cancel, exit the loop.
        IF (old_delivery_detail_rec.requested_quantity >= ABS(l_changed_detail_quantity))  THEN

         Handle_Overpick_cancelled(
             p_source_line_id   =>   p_changed_attribute.source_line_id,
             p_source_code      =>   p_source_code,
             p_context          =>   p_context,
             x_return_status    =>   l_return_status);
         IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Handle_Overpick_cancelled l_return_status',l_return_status);
         END IF;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATING OVERPICKED LINES API FAILED '  );
          END IF;
          --
          x_return_status := l_return_status;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          return;
         END IF;
         EXIT;
       END IF;

       l_changed_detail_quantity := l_changed_detail_quantity - old_delivery_detail_rec.requested_quantity;
       l_changed_detail_quantity2 := l_changed_detail_quantity2 - old_delivery_detail_rec.requested_quantity2;
     END IF;
    ELSIF (old_delivery_detail_rec.status_code = 'CO' or
    old_delivery_detail_rec.status_code = 'IT' or
    old_delivery_detail_rec.status_code = 'CL' or
    old_delivery_detail_rec.status_code = 'SC' or -- sperera 940/945
    old_delivery_detail_rec.status_code = 'SR')  THEN
    l_ship_status := 'confirmed, in-transit or closed';
    l_valid_update_quantity := ABS(l_changed_line_quantity) - ABS(l_changed_detail_quantity);
    ROLLBACK TO SAVEPOINT startloop;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'REJECT REQUEST AS DELIVERY IS '||L_SHIP_STATUS  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'VALID UPDATE QUANTITY '||L_VALID_UPDATE_QUANTITY  );
    END IF;

    IF l_valid_update_quantity > 0 THEN
       -- Throw message saying the quantity that can be cancelled
         FND_MESSAGE.Set_Name('WSH', 'WSH_VALID_UPDATE_QUANTITY');
         FND_MESSAGE.Set_Token('UPDATE_QUANTITY',l_valid_update_quantity);
    ELSE
      FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_QUANTITY');
    END IF;
      RAISE reject_update;
    END IF; -- Delivery Status
   -- END IF; -- Changed Quantity moved lower down  OPM B2187389
    ELSIF (l_changed_line_quantity2 < 0) and (l_changed_line_quantity = 0)  THEN  -- OPM B2187389 - decrease on qty2
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'OPM L_CHANGED_LINE_QUANTITY2 < 0 AND L_CHANGED_LINE_QUANTITY = 0 '  );
            END IF;
            --


     update wsh_delivery_details set
      requested_quantity2 = old_delivery_detail_rec.requested_quantity2 - ABS(l_changed_detail_quantity2),
      last_update_date     = SYSDATE,
                        last_updated_by      = FND_GLOBAL.USER_ID,
                        last_update_login    = FND_GLOBAL.LOGIN_ID
      where delivery_detail_id = old_delivery_detail_rec.delivery_detail_id;


    END IF; -- Changed Quantity -- OPM B2187389

   END IF; -- Action Flag = U/D

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'DONE C_OLD_LINE LOOP FOR : DEL DET: '|| OLD_DELIVERY_DETAIL_REC.DELIVERY_DETAIL_ID  );
       WSH_DEBUG_SV.logmsg(l_module_name, 'L_READY_RELEASE_CHANGE_QTY :'||L_READY_RELEASE_CHANGE_QTY  );
       WSH_DEBUG_SV.logmsg(l_module_name, 'L_CHANGED_DETAIL_QUANTITY :'||L_CHANGED_DETAIL_QUANTITY  );
   END IF;

  END LOOP;
  IF l_ser_control = 1 THEN
         CLOSE C_Old_line;
  ELSE
         CLOSE C_Old_line_ser;
  END IF;


 IF l_changed_line_quantity <> 0 THEN
    -- delete or update all the move order lines

  IF p_changed_attribute.ordered_quantity = 0 THEN

    WSH_USA_INV_PVT.query_reservations  (
    p_source_code         => p_source_code,
    p_source_header_id         => p_changed_attribute.source_header_id,
    p_source_line_id         => p_changed_attribute.source_line_id,
    p_organization_id       => old_delivery_detail_rec.organization_id,
    p_lock_records           => fnd_api.g_true,
    p_cancel_order_mode       => inv_reservation_global.g_cancel_order_yes,
    p_delivery_detail_id      => null, -- X-dock
    x_mtl_reservation_tbl     => l_rsv_array,
    x_mtl_reservation_tbl_count   => l_size,
    x_return_status         => l_return_status);

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'query_reservations l_return_status',l_return_status);
    END IF;

    FOR l_counter in  1..l_size
    LOOP

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT.DELETE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_USA_INV_PVT.delete_reservation(      --  For that source header and line id
      p_query_input     =>   l_rsv_array(l_counter),
      x_return_status   =>   l_return_status);

          IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'delete_reservation l_return_status',l_return_status);
          END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'DELETE RESERVATION FAILED FOR SOURCE LINE '||P_CHANGED_ATTRIBUTE.SOURCE_LINE_ID  );
      END IF;
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       --WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.delete_reservation',l_module_name);
      --END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
    END LOOP;

  ELSE

   -- Cancel reservation for non S,Y,X  delivery lines
   -- No longer calls INV s  process_move_order_line  and process_move_order_header
   -- Need to call only if l_ready_release_change_qty > 0
   IF l_ready_release_change_qty > 0 THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'IN CANCELLING NON STAGED RESERVATION FOR SOURCE '||P_CHANGED_ATTRIBUTE.SOURCE_LINE_ID  );
     END IF;
     --
     WSH_USA_INV_PVT.cancel_nonstaged_reservation (
      p_source_code          =>  p_source_code,
      p_source_header_id        =>  p_changed_attribute.source_header_id,
      p_source_line_id        =>  p_changed_attribute.source_line_id,
      p_delivery_detail_id    =>  old_delivery_detail_rec.delivery_detail_id, --Bug3012297
      p_organization_id        =>  old_delivery_detail_rec.organization_id,
      p_cancellation_quantity    =>  l_ready_release_change_qty,
      p_cancellation_quantity2    =>  l_ready_release_change_qty2, -- OPM may need to change this
      x_return_status        =>  l_return_status);

          IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'cancel_nonstaged_reservation l_return_status',l_return_status);
          END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLING NON STAGED RESERVATION FAILED FOR SOURCE LINE '||P_CHANGED_ATTRIBUTE.SOURCE_LINE_ID  );
      END IF;
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       --WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.cancel_nonstaged_reservation',l_module_name);
      --END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
   END IF;   -- l_ready_release_change_qty > 0

  END IF;  -- p_changed_attribute.ordered_quantity = 0
 END IF;  -- l_changed_line_quantity <> 0

 IF l_del_tab.count > 0 THEN

    /*  H integration: Pricing integration csun
      when plan a delivery
    */
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Mark_Reprice_Required l_return_status',l_return_status);
    END IF;

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
    END IF;

    -- deliveryMerge
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
          p_delivery_ids          => l_del_tab,
          p_caller                => 'WSH_DLMG',
          p_force_appending_limit => 'N',
          p_call_lcss             => 'Y',
          p_event                 => NULL,
          x_return_status         => l_return_status);
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag l_return_status',l_return_status);
    END IF;

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise Adjust_Planned_Flag_Err;
    END IF;


 END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
    WHEN reject_update THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REJECT_UPDATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REJECT_UPDATE');
     END IF;
     --
    WHEN reject_delete THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'REJECT_DELETE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REJECT_DELETE');
     END IF;
    WHEN create_assignment_failure THEN
     FND_MESSAGE.Set_Name('WSH', 'WSH_DET_CREATE_AS_FAILED');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_ASSIGNMENT_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREATE_ASSIGNMENT_FAILURE');
     END IF;
     --
    WHEN create_detail_failure THEN
     FND_MESSAGE.Set_Name('WSH', 'WSH_DET_CREATE_DET_FAILED');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_DETAIL_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREATE_DETAIL_FAILURE');
                 END IF;
    WHEN delete_detail_failure THEN
     FND_MESSAGE.Set_Name('WSH', 'WSH_DET_DELETE_DET_FAILED');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'DELETE_DETAIL_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELETE_DETAIL_FAILURE');
     END IF;
    WHEN   mark_reprice_error THEN
       FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
       x_return_status := l_return_status;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
     END IF;
     --
          WHEN invalid_ship_set THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: INVALID SHIP SET'  );
           END IF;
           fnd_message.set_name('WSH', 'WSH_INVALID_SET_CHANGE');
           fnd_message.set_token('SHIP_SET',l_ship_set_name);
           fnd_message.set_token('LINE_NUMBER',p_changed_attribute.line_number);
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
         WHEN invalid_smc_model_change THEN
            fnd_message.set_name('WSH', 'WSH_INVALID_SMC_CHANGE');
            fnd_message.set_token('LINE_NUMBER',l_top_model_line_id);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'DELETE_DETAIL_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELETE_DETAIL_FAILURE');
           END IF;



    WHEN Adjust_Planned_Flag_Err THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_ADJUST_PLANNED_FLAG_ERR');
          WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
          x_return_status := l_return_status;

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_Planned_Flag_Err exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Adjust_Planned_Flag_Err');
          END IF;


    WHEN others THEN

     IF (c_old_line%ISOPEN) THEN
       CLOSE c_old_line;
     END IF;

     IF (c_old_line_ser%ISOPEN) THEN
       CLOSE c_old_line_ser;
     END IF;

     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     wsh_util_core.default_handler('WSH_USA_QUANTITY_PVT.Update_Ordered_Quantity',l_module_name);
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END Update_Ordered_Quantity;


PROCEDURE Handle_Overpick_cancelled(
  p_source_line_id    IN  NUMBER,
  p_source_code       IN  VARCHAR2,
  p_context           IN  VARCHAR2,
  x_return_status     OUT NOCOPY    VARCHAR2)
IS
CURSOR C_overpick is
SELECT   wdd.delivery_detail_id
    ,wdd.released_status
    ,wdd.move_order_line_id
    ,wdd.serial_number,transaction_temp_id
    ,wdd.organization_id
      ,wda.delivery_id
      ,wdd.inventory_item_id
      ,wdd.subinventory
      ,wdd.revision
      ,wdd.lot_number
      ,wdd.locator_id
      ,wdd.source_header_id
      ,wdd.picked_quantity
      ,wdd.picked_quantity2
FROM   wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
WHERE  wdd.source_line_id = p_source_line_id
AND wdd.source_code = p_source_code
AND wdd.released_status IN ('S','Y')
AND wdd.requested_quantity = 0
AND wdd.picked_quantity > 0
AND wda.delivery_detail_id = wdd.delivery_detail_id;

l_released_status VARCHAR2(1);
l_move_order_line_id NUMBER;
l_delivery_detail_id NUMBER;
l_serial_number   VARCHAR2(30);
l_txn_temp_id   NUMBER;
l_organization_id   NUMBER;
l_delivery_id      NUMBER;

l_source_header_id      WSH_DELIVERY_DETAILS.SOURCE_HEADER_ID%TYPE;
l_inventory_item_id      WSH_DELIVERY_DETAILS.INVENTORY_ITEM_ID%TYPE;
l_subinventory      WSH_DELIVERY_DETAILS.SUBINVENTORY%TYPE;
l_revision      WSH_DELIVERY_DETAILS.REVISION%TYPE;
l_lot_number      WSH_DELIVERY_DETAILS.LOT_NUMBER%TYPE;
l_locator_id      WSH_DELIVERY_DETAILS.LOCATOR_ID%TYPE;
l_picked_quantity   WSH_DELIVERY_DETAILS.PICKED_QUANTITY%TYPE;
l_picked_quantity2  WSH_DELIVERY_DETAILS.PICKED_QUANTITY2%TYPE;
l_delivery_detail_split_rec   WSH_USA_INV_PVT.DeliveryDetailInvRecType;
l_cancel_quantity NUMBER;
l_cancel_quantity2 NUMBER;

l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
l_error_text  VARCHAR2(6000);

l_num_warn NUMBER := 0;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'HANDLE_OVERPICK_CANCELLED';
--
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTEXT',P_CONTEXT);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bug 2942655 / 2936559
  --   overpick normalization should skip the lines pending overpick
  --   because their requested quantities (0) are not taken.
  --   This allows the picker to fully stage the quantities entered.
  IF (p_context = 'OVERPICK')  THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Returning because of overpick normalization');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;


  OPEN C_overpick;
  LOOP
    FETCH C_overpick INTO l_delivery_detail_id,l_released_status,
              l_move_order_line_id,l_serial_number,
              l_txn_temp_id,l_organization_id, l_delivery_id,
              l_inventory_item_id,
              l_subinventory,
              l_revision,
              l_lot_number,
              l_locator_id,
              l_source_header_id,
              l_picked_quantity,
              l_picked_quantity2;
    EXIT WHEN C_overpick%NOTFOUND;

-- Bug 2896572
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Dd id-'||l_delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'Rel Status-'||l_released_status);
      WSH_DEBUG_SV.log(l_module_name,'Serial Number-'||l_serial_number);
    END IF;

    IF l_released_status = 'Y' THEN
      l_delivery_detail_split_rec.delivery_detail_id := l_delivery_detail_id;
      l_delivery_detail_split_rec.released_status  := l_released_status;
      l_delivery_detail_split_rec.move_order_line_id := l_move_order_line_id;
      l_delivery_detail_split_rec.organization_id  := l_organization_id;
      l_delivery_detail_split_rec.inventory_item_id  := l_inventory_item_id;
      l_delivery_detail_split_rec.subinventory    := l_subinventory;
      l_delivery_detail_split_rec.revision      := l_revision;
      l_delivery_detail_split_rec.lot_number    := l_lot_number;
      l_delivery_detail_split_rec.locator_id    := l_locator_id;
-- Cancel Quantity is not used in this API,so passing as non-zero value
      l_cancel_quantity := l_picked_quantity;
      l_cancel_quantity2 := l_picked_quantity2;

      WSH_USA_INV_PVT.cancel_staged_reservation(
        p_source_code        =>   p_source_code,
        p_source_header_id      => l_source_header_id,
        p_source_line_id      =>   p_source_line_id,
        p_delivery_detail_split_rec  => l_delivery_detail_split_rec,
        p_cancellation_quantity    =>  l_cancel_quantity,
        p_cancellation_quantity2  =>   l_cancel_quantity2,
        x_return_status        =>   x_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'WSH_USA_INV_PVT.CANCEL_STAGED_RESERVATION',x_return_status);
      END IF;
      IF x_return_status IN (fnd_api.g_ret_sts_error,
                             fnd_api.g_ret_sts_unexp_error) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_USA_INV_PVT.CANCEL_STAGED_RESERVATION ') ;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;

      END IF;
-- End of Bug 2896572

     ELSIF l_released_status = 'S' THEN
     --
     -- Debug Statements
     --
-- HW OPMCONV - Removed code forking

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      INV_MO_Cancel_PVT.Cancel_Move_Order_Line(
              x_return_status   =>  x_return_status
               ,x_msg_count     =>  l_msg_count
               ,x_msg_data       =>  l_msg_data
               ,p_line_id       =>  l_move_order_line_id
               ,p_delete_reservations  =>  'Y'
               ,p_txn_source_line_id   =>  p_source_line_id
               ,p_delivery_detail_id   =>  l_delivery_detail_id -- X-dock
               );
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Cancel_Move_Order_Line x_return_status',x_return_status);
      END IF;
--HW OPMCONV - Removed branching
     IF x_return_status = fnd_api.g_ret_sts_success THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLED MOLINE '||L_MOVE_ORDER_LINE_ID  );
      END IF;
      --
     ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE '  );
      END IF;
      --
      FND_MESSAGE.Set_Name('WSH', 'WSH_CANCEL_MO_LINE');
      IF l_msg_count = 1 THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
         END IF;
         --
         FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
      ELSE
         FOR l_index IN 1..l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
           END IF;
           --
           l_error_text := l_error_text || l_msg_data;
         END LOOP;
         FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
         l_error_text := '';
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
     END IF;
    END IF;
    --
    -- Debug Statements
    --
--HW OPMCONV - Removed branching

     WSH_USA_INV_PVT.update_serial_numbers(
            p_delivery_detail_id     => l_delivery_detail_id,
            p_serial_number       =>  l_serial_number,
            p_transaction_temp_id   =>  l_txn_temp_id,
            x_return_status       =>  x_return_status);
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'update_serial_numbers x_return_status',x_return_status);
      END IF;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
     END IF;

    IF l_delivery_id IS NOT NULL THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_details_actions.Unassign_Detail_from_delivery
              (l_delivery_detail_id, x_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Unassign_Detail_from_delivery x_return_status',x_return_status);
    END IF;

      IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
      END IF;

    END IF;
  END LOOP;
  CLOSE C_overpick;

  UPDATE wsh_delivery_details set
           requested_quantity =  0,
           requested_quantity2 =  0,
           picked_quantity =  NULL,
           picked_quantity2 =  NULL,
           src_requested_quantity =  0,
           src_requested_quantity2 =  0,
           shipped_quantity =  0,
           shipped_quantity2 =  0,
           delivered_quantity =  0,
           delivered_quantity2 =  0,
           quality_control_quantity =  0,
           quality_control_quantity2 =  0,
           cycle_count_quantity =  0,
           cycle_count_quantity2 =  0,
           released_status = 'D',
           subinventory = NULL,
           revision  = NULL,
           lot_number = NULL,
           locator_id = NULL,
           cancelled_quantity = 0,
           cancelled_quantity2 = 0,
           last_update_date  = SYSDATE,
           last_updated_by    = FND_GLOBAL.USER_ID,
           last_update_login  = FND_GLOBAL.LOGIN_ID
           WHERE   source_line_id = p_source_line_id
           AND     source_code = p_source_code
           AND     released_status in ('S','Y')
           AND     requested_quantity = 0
           AND     picked_quantity > 0
         RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab; -- Added for DBI Project
    --
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- DBI API will check if DBI is installed
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_detail_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_detail_tab,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    -- Only Handle Unexpected error
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
    -- End of Code for DBI Project
    --

/* Bug 2310456 warning handling */
   IF l_num_warn > 0 THEN
     --x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
-- in this API we treat warning as success as of now
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN NO_DATA_FOUND THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'NO OVERPICKED LINES REMAINING TO BE CANCELLED'  );
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.default_handler('WSH_INTERFACE.Handle_Overpick_cancelled',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Handle_Overpick_cancelled;


PROCEDURE log_exception(
  p_ship_from_location_id   IN   NUMBER,
  p_delivery_id       IN   NUMBER DEFAULT NULL,
  p_delivery_detail_id     IN  NUMBER,
  p_parent_delivery_detail_id  IN  NUMBER DEFAULT NULL,
  p_delivery_assignment_id   IN  NUMBER,
  p_inventory_item_id     IN   NUMBER,
  p_reason           IN  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2)
IS
l_exception_location_id        NUMBER;
l_exception_error_message        VARCHAR2(2000) := NULL;
l_exception_msg_count          NUMBER;
l_dummy_exception_id          NUMBER;
l_delivery_assignment_id        NUMBER;
l_delivery_detail_id           NUMBER;
l_delivery_id           NUMBER;
l_exception_msg_data          VARCHAR2(4000) := NULL;
l_msg                  VARCHAR2(2000):=NULL;

logging_exception_failure        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'LOG_EXCEPTION';
--
BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION_ID',P_SHIP_FROM_LOCATION_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DELIVERY_DETAIL_ID',P_PARENT_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ASSIGNMENT_ID',P_DELIVERY_ASSIGNMENT_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_REASON',P_REASON);
  END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Get p_reason here which is passed as the message name
 FND_MESSAGE.SET_NAME('WSH',p_reason);
 FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',p_delivery_detail_id);
 IF p_reason = 'WSH_CANCELLED_PLANNED' THEN
  FND_MESSAGE.SET_TOKEN('DELIVERY_ID',p_delivery_id);
 END IF;

 l_msg := FND_MESSAGE.GET;
 l_exception_location_id := p_ship_from_location_id;

 IF p_reason = 'WSH_CANCELLED_PACKED' THEN
  l_delivery_id := NULL;
  l_delivery_assignment_id := NULL;
 ELSE
  -- Bug 3302632
  -- In the case of cancelling a line in a planned
  -- delivery, log bug against delivery.
  l_delivery_id := p_delivery_id;
  l_delivery_assignment_id := p_delivery_assignment_id;
 END IF;

 WSH_XC_UTIL.log_exception(
   p_api_version       => 1.0,
   x_return_status       => x_return_status,
   x_msg_count         => l_exception_msg_count,
   x_msg_data       => l_exception_msg_data,
   x_exception_id     => l_dummy_exception_id ,
   p_logged_at_location_id   => l_exception_location_id,
   p_exception_location_id   => l_exception_location_id,
   p_logging_entity     => 'SHIPPER',
   p_logging_entity_id     => FND_GLOBAL.USER_ID,
   p_exception_name     => 'WSH_CHANGED_QUANTITY',
   p_message         => l_msg,
   p_delivery_detail_id   => nvl(p_parent_delivery_detail_id,p_delivery_detail_id),
   p_delivery_assignment_id  => l_delivery_assignment_id,
   p_delivery_id  => l_delivery_id,
   p_inventory_item_id     => p_inventory_item_id,
   p_error_message       => l_exception_error_message
   );

  IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION ID: '|| L_DUMMY_EXCEPTION_ID  );
       WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION MSG DATA: '|| L_EXCEPTION_MSG_DATA  );
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE logging_exception_failure;
  END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
--
EXCEPTION
    WHEN logging_exception_failure THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'LOGGING_EXCEPTION_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:LOGGING_EXCEPTION_FAILURE');
     END IF;
     --
    WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END log_exception;


-- HW OPMCONV - Removed l_process_flag parameter

PROCEDURE cancel_quantity(
  p_source_code       IN  VARCHAR2,
  p_source_header_id       IN NUMBER,   --  New
  p_source_line_id       IN NUMBER,
  p_delivery_detail_id     IN NUMBER,
  p_parent_delivery_detail_id  IN NUMBER DEFAULT NULL,
  p_serial_number       IN  VARCHAR2,
  p_transaction_temp_id   IN  NUMBER,
  p_released_status     IN  VARCHAR2,
  p_move_order_line_id     IN NUMBER,
  p_organization_id     IN  NUMBER,
  p_inventory_item_id     IN  NUMBER ,
  p_subinventory         IN VARCHAR2 ,
  p_revision           IN VARCHAR2 ,
  p_lot_number         IN VARCHAR2 ,
  p_locator_id         IN NUMBER ,
  p_ordered_quantity       IN NUMBER,
  p_requested_quantity     IN NUMBER,
  p_requested_quantity2   IN  NUMBER,
  p_picked_quantity     IN  NUMBER DEFAULT NULL,
  p_picked_quantity2       IN NUMBER DEFAULT NULL,
  p_shipped_quantity       IN NUMBER,
  p_shipped_quantity2     IN  NUMBER,
  p_changed_detail_quantity IN  NUMBER,
  p_changed_detail_quantity2   IN NUMBER,
  p_ship_tolerance_above     IN    NUMBER,
  p_serial_quantity        IN    NUMBER,
  p_replenishment_status   IN   VARCHAR2 DEFAULT NULL,  --bug# 6689448 (replenishment project)
  x_return_status       OUT NOCOPY    VARCHAR2)
IS

-- Bug fix 2864546. Added planned_flag in the select
CURSOR c_check_del_assign(p_del_det IN NUMBER) is
SELECT wda.delivery_id, wnd.planned_flag,
       wnd.ignore_for_planning,  -- OTM R12 : cancel quantity
       wnd.tms_interface_flag    -- OTM R12 : cancel quantity
FROM wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd
WHERE wda.delivery_id is not null
AND wda.delivery_detail_id = p_del_det
AND wda.delivery_id = wnd.delivery_id;

l_delivery_detail_split_rec   WSH_USA_INV_PVT.DeliveryDetailInvRecType;
l_picked_quantity   NUMBER;
l_picked_quantity2  NUMBER;
l_excess_picked_quantity  NUMBER;
-- HW OPMCONV - Added new variables
l_excess_picked_quantity2 NUMBER;
l_change_reservation_quantity  NUMBER;
l_change_reservation_quantity2  NUMBER;
l_delivery_id  NUMBER;
l_msg_count  NUMBER;
l_msg_data  VARCHAR2(240);
l_error_text  VARCHAR2(6000);

/*Bug 2136603 - added variables */
l_gross NUMBER;
l_net NUMBER;
l_volume NUMBER;
l_fill NUMBER;
l_cont_name VARCHAR2(30);
l_num_warn NUMBER := 0;

l_serial_quantity   NUMBER := 0;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

/*2729687 Added l_details_id and l_return_status */

l_details_id  WSH_UTIL_CORE.Id_Tab_Type;

l_return_status VARCHAR2(30);

l_planned_flag VARCHAR2(1);  -- Bug fix 2864546

-- OTM R12 : cancel quantity
l_ignore              WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
l_tms_interface_flag  WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
l_delivery_id_tab     WSH_UTIL_CORE.ID_TAB_TYPE;
l_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_call_update         VARCHAR2(1);
l_del_assigned        VARCHAR2(1);
l_gc3_is_installed    VARCHAR2(1);
-- OTM R12 : cancel quantity

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CANCEL_QUANTITY';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DELIVERY_DETAIL_ID',P_PARENT_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TEMP_ID',P_TRANSACTION_TEMP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RELEASED_STATUS',P_RELEASED_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_MOVE_ORDER_LINE_ID',P_MOVE_ORDER_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
      WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
      WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORDERED_QUANTITY',P_ORDERED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',P_REQUESTED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY2',P_REQUESTED_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKED_QUANTITY',P_PICKED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKED_QUANTITY2',P_PICKED_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY2',P_SHIPPED_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_CHANGED_DETAIL_QUANTITY',P_CHANGED_DETAIL_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_CHANGED_DETAIL_QUANTITY2',P_CHANGED_DETAIL_QUANTITY2);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TOLERANCE_ABOVE',P_SHIP_TOLERANCE_ABOVE);
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_QUANTITY',P_SERIAL_QUANTITY);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_QUANTITY_PVT.CANCEL_QUANTITY '  );
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- End of OTM R12

  -- Overpicking creates extra reservations.
  -- Therefore, when quantity is reduced or cancelled,
  -- we need to purge the extra reservations.

  l_excess_picked_quantity := p_picked_quantity - p_requested_quantity;
-- HW OPMCONV - Calculate l_excess_picked_quantity2
  l_excess_picked_quantity2 := p_picked_quantity2 - p_requested_quantity2;

-- HW OPMCONV - Remove checking for process
  IF (l_excess_picked_quantity > 0)  THEN

    -- HW OPMCONV - Pass l_excess_picked_quantity2

    wsh_delivery_details_actions.unreserve_delivery_detail(
       p_delivery_Detail_id => p_delivery_detail_id,
       p_unreserve_mode   => 'UNRESERVE',
       p_quantity_to_unreserve => l_excess_picked_quantity,
       p_quantity2_to_unreserve => l_excess_picked_quantity2,
       p_override_retain_ato_rsv => 'Y',
       x_return_status     => x_return_status );

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'unreserve_delivery_detail x_return_status',x_return_status);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;
  END IF;

  IF (p_requested_quantity > ABS(p_changed_detail_quantity) ) THEN
   l_change_reservation_quantity := p_changed_detail_quantity;
   l_change_reservation_quantity2 := p_changed_detail_quantity2;

   IF (p_released_status = 'Y') THEN
    l_picked_quantity := p_requested_quantity - p_changed_detail_quantity;
    l_picked_quantity2 := p_requested_quantity2 - ABS(p_changed_detail_quantity2); -- OPM Bug 5648794
    -- Bug 5648794 ABS is required due to code changes for Bug fix 2187389 send changed_line_quantity
    -- changed_line_quantity Unlike p_changed_detail_quantity could be positive or negative.
    -- Picked quantity2 can only be reduced never increased.
   ELSE
    l_picked_quantity  := p_picked_quantity;
    l_picked_quantity2 := p_picked_quantity2;
   END IF;

   IF ( (p_requested_quantity - ABS(p_changed_detail_quantity)) >= nvl(p_shipped_quantity,0) ) THEN
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'CASE 1 '  );
     END IF;
    UPDATE wsh_delivery_details SET
       requested_quantity    = p_requested_quantity - ABS(p_changed_detail_quantity),
       requested_quantity2     = p_requested_quantity2 - ABS(p_changed_detail_quantity2),
-- HW OPMCONV - Update Qty2 similar to Qty1
--       requested_quantity2     = p_requested_quantity2 + p_changed_detail_quantity2, -- OPM B2187389
       picked_quantity      =  l_picked_quantity,
       picked_quantity2      =  l_picked_quantity2,
       cycle_count_quantity    = decode(cycle_count_quantity,null,null,0,0,(p_requested_quantity - nvl(p_shipped_quantity,0)) - ABS(p_changed_detail_quantity)),
       cycle_count_quantity2    = decode(cycle_count_quantity2,null,null,0,0,(p_requested_quantity2 - nvl(p_shipped_quantity2,0)) - ABS(p_changed_detail_quantity2)),
       cancelled_quantity    = nvl(cancelled_quantity,0) + ABS(p_changed_detail_quantity),
       cancelled_quantity2    = nvl(cancelled_quantity2,0) + ABS(p_changed_detail_quantity2),
       last_update_date      = SYSDATE,
       last_updated_by      = FND_GLOBAL.USER_ID,
       last_update_login      = FND_GLOBAL.LOGIN_ID
    where delivery_detail_id = p_delivery_detail_id;
   ELSE
    UPDATE wsh_delivery_details SET
       requested_quantity    = p_requested_quantity - ABS(p_changed_detail_quantity),
       requested_quantity2    = p_requested_quantity2 - ABS(p_changed_detail_quantity2),
-- HW OPMCONV - Update Qty2 similar to Qty1
--       requested_quantity2    = p_requested_quantity2 + p_changed_detail_quantity2, -- OPM B2187389
       picked_quantity      =  l_picked_quantity,
       picked_quantity2      =  l_picked_quantity2,
       shipped_quantity      = p_requested_quantity - ABS(p_changed_detail_quantity),
       shipped_quantity2      = p_requested_quantity2 - ABS(p_changed_detail_quantity2),
       cycle_count_quantity    = decode(cycle_count_quantity,null,null,0),
       cycle_count_quantity2    = decode(cycle_count_quantity2,null,null,0),
       cancelled_quantity    = nvl(cancelled_quantity,0) + ABS(p_changed_detail_quantity),
       cancelled_quantity2    = nvl(cancelled_quantity2,0) + ABS(p_changed_detail_quantity2),
       last_update_date      = SYSDATE,
       last_updated_by      = FND_GLOBAL.USER_ID,
       last_update_login      = FND_GLOBAL.LOGIN_ID
    WHERE delivery_detail_id = p_delivery_detail_id;
   --
   END IF; -- end of comparison between requested - detail with shipped quantity

    --bug# 6689448 (replenishment project) (Begin) : added the code to call WMS api for replenshment requested
    -- delivery detail lines to decrease the qty from replenishment tables.
    IF (p_replenishment_status = 'R' and p_released_status in ('R','B')) THEN
    --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL (
                    p_delivery_detail_id => p_delivery_detail_id,
                    p_primary_quantity   => (p_requested_quantity - ABS(p_changed_detail_quantity)),
	            x_return_status      => x_return_status);
             IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             --{
                 IF l_debug_on THEN
       	             WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
 	             WSH_DEBUG_SV.pop(l_module_name);
  	         END IF;
	         RETURN;
	      --}
             END IF;
    --}
    END IF;
    --bug# 6689448 (replenishment project):end

   -- OTM R12 : cancel quantity
   IF (nvl(p_changed_detail_quantity, 0) <> 0 AND l_gc3_is_installed = 'Y') THEN
     l_call_update := 'Y';
     l_ignore := 'Y';
     l_del_assigned := 'N';

     OPEN  c_check_del_assign(p_delivery_detail_id);
     FETCH c_check_del_assign INTO l_delivery_id, l_planned_flag, l_ignore, l_tms_interface_flag;

     IF (c_check_del_assign%FOUND AND nvl(l_ignore, 'N') = 'N') THEN
       l_del_assigned := 'Y';
     END IF;

     CLOSE c_check_del_assign;

     IF (l_del_assigned = 'Y') THEN
       l_delivery_id_tab.DELETE;
       l_interface_flag_tab.DELETE;

       l_delivery_id_tab(1) := l_delivery_id;

       --calculate the interface flag to be updated
       IF l_tms_interface_flag IN
          (WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED,
           WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
           WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
           WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS) THEN
         l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
       ELSE
         l_call_update := 'N';
       END IF;

       IF (l_call_update = 'Y') THEN
         WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                 p_delivery_id_tab        => l_delivery_id_tab,
                 p_tms_interface_flag_tab => l_interface_flag_tab,
                 x_return_status          => l_return_status);

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

           x_return_status := l_return_status;
           return;
         END IF;
       END IF;
     END IF;
   END IF;
   -- End of OTM R12 : cancel quantity

   -- DBI Project
   -- Update of wsh_delivery_details where requested_quantity/released_status
   -- are changed, call DBI API after the update.
   -- Either of the above 2 updates will be executed for same delivery detail id
   -- hence have one call to DBI wrapper and not 2,this will cover for both
   -- This API will also check for DBI Installed or not
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_delivery_detail_id);
   END IF;
   l_detail_tab(1) := p_delivery_detail_id;
   WSH_INTEGRATION.DBI_Update_Detail_Log
     (p_delivery_detail_id_tab => l_detail_tab,
      p_dml_type               => 'UPDATE',
      x_return_status          => l_dbi_rs);

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
   END IF;
   IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     x_return_status := l_dbi_rs;
     -- just pass this return status to caller API
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;
   -- End of Code for DBI Project
   --

-- HW OPMCONV - Added the following check
-- If Qty1 and Qty2 are increased on sales order
-- Update Qty2 correctly
   IF ( ( (p_requested_quantity2 - ABS(p_changed_detail_quantity2)) >= nvl(p_shipped_quantity2,0)
         AND (p_requested_quantity - ABS(p_changed_detail_quantity)) >= nvl(p_shipped_quantity,0)) ) THEN
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'CASE 2 '  );
     END IF;
    UPDATE wsh_delivery_details SET
       requested_quantity2     = p_requested_quantity2 + p_changed_detail_quantity2 -- OPM B2187389
    WHERE delivery_detail_id = p_delivery_detail_id;
   END IF;

   -- J: W/V Changes
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   WSH_WV_UTILS.Detail_Weight_Volume(
     p_delivery_detail_id  => p_delivery_detail_id,
     p_update_flag         => 'Y',
     p_post_process_flag   => 'Y',
     p_calc_wv_if_frozen   => 'N',
     x_net_weight          => l_net,
     x_volume              => l_volume,
     x_return_status       => l_return_status);

   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
   END IF;

   IF p_released_status = 'S' THEN
   --{
-- HW OPMCONV - Removed code forking
           -- bug 2186091: it is better to always reduce move order
           --   quantity than to allow subsequent overpicking.
           --   That way, default pick confirm will match the
           --   updated ordered quantity.
           --   INV has bug 2168209 to investigate allowing
           --   overpicking after reducing move order quantity.

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.REDUCE_MOVE_ORDER_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);

         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'p_changed_detail_quantity',p_changed_detail_quantity);
         WSH_DEBUG_SV.log(l_module_name,'p_changed_detail_quantity2',ABS(p_changed_detail_quantity2));
       END IF;
       --
-- HW OPMCONV - Pass Qty2
       INV_MO_Cancel_PVT.Reduce_Move_Order_Quantity(
         x_return_status            => x_return_status,
         x_msg_count                =>  l_msg_count,
         x_msg_data                 => l_msg_data,
         p_line_id                  =>  p_move_order_line_id,
         p_reduction_quantity       =>  p_changed_detail_quantity,
         p_sec_reduction_quantity   =>  ABS(p_changed_detail_quantity2),
         p_txn_source_line_id       =>  p_source_line_id,
         p_delivery_detail_id       => p_delivery_detail_id  -- X-dock changes
        );

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Reduce_Move_Order_Quantity x_return_status',x_return_status);
       END IF;
       IF x_return_status = fnd_api.g_ret_sts_success THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'REDUCED QUANTITY FOR MOLINE '||P_MOVE_ORDER_LINE_ID ||' BY '|| P_CHANGED_DETAIL_QUANTITY  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN INV_MO_CANCEL_PVT.REDUCE_MOVE_ORDER_QUANTITY '  );
         END IF;
       --
       ELSE
         FND_MESSAGE.Set_Name('WSH', 'WSH_REDUCE_MO_QUANTITY');
         IF l_msg_count = 1 THEN
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
           END IF;
           --
           FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
         ELSE
           FOR l_index IN 1..l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
           END IF;
           --
           l_error_text := l_error_text || l_msg_data;
           END LOOP;
           FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
           l_error_text := '';
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
       END IF;   -- end of return_status handling
--HW OPMCONV - Removed branching
   --}
   END IF;

  ELSE
   l_change_reservation_quantity := p_requested_quantity;
   l_change_reservation_quantity2 := p_requested_quantity2;

   update wsh_delivery_details set
     requested_quantity    =  0,
     requested_quantity2    =  0,
     picked_quantity      =  NULL,
     picked_quantity2      =  NULL,
     src_requested_quantity  =  0,
     src_requested_quantity2  =  0,
     shipped_quantity      =  0,
     shipped_quantity2      =  0,
     delivered_quantity    =  0,
     delivered_quantity2    =  0,
     quality_control_quantity   =  0,
     quality_control_quantity2  =  0,
     cycle_count_quantity    =  0,
     cycle_count_quantity2    =  0,
     released_status      = 'D',
     subinventory        = NULL,
     revision          = NULL,
     lot_number        = NULL,
     locator_id        = NULL,
     cancelled_quantity    = nvl(cancelled_quantity,0) + p_requested_quantity,
     cancelled_quantity2    = nvl(cancelled_quantity2,0) + p_requested_quantity2,
     last_update_date      = SYSDATE,
     last_updated_by      = FND_GLOBAL.USER_ID,
     last_update_login      = FND_GLOBAL.LOGIN_ID
   where delivery_detail_id = p_delivery_detail_id;

    --bug# 6689448 (replenishment project) (Begin) : added the code to call WMS api for replenshment requested delivery
    -- detail lines with zeqo qty so that WMS deletes the replenishment record.
    IF (p_replenishment_status = 'R' and p_released_status in ('R','B')) THEN
    --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL (
                    p_delivery_detail_id => p_delivery_detail_id,
                    p_primary_quantity  => 0,
                    x_return_status => x_return_status);
             IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             --{
                 IF l_debug_on THEN
       	            WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
 	                WSH_DEBUG_SV.pop(l_module_name);
  	         END IF;
	         RETURN;
	     --}
             END IF;
   --}
   END IF;
   --bug# 6689448 (replenishment project):end


   -- DBI Project
   -- Update of wsh_delivery_details where requested_quantity/released_status
   -- are changed, call DBI API after the update.
   -- This API will also check for DBI Installed or not
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_delivery_detail_id);
   END IF;
   l_detail_tab(1) := p_delivery_detail_id;
   WSH_INTEGRATION.DBI_Update_Detail_Log
     (p_delivery_detail_id_tab => l_detail_tab,
      p_dml_type               => 'UPDATE',
      x_return_status          => l_dbi_rs);

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
   END IF;
   IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     x_return_status := l_dbi_rs;
     -- just pass this return status to caller API
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;
   -- End of Code for DBI Project
   --

   -- J: W/V Changes
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling Detail_Weight_Volume to reset W/V for cancelled dd');
   END IF;
   WSH_WV_UTILS.Detail_Weight_Volume(
     p_delivery_detail_id  => p_delivery_detail_id,
     p_update_flag         => 'Y',
     p_post_process_flag   => 'Y',
     x_net_weight          => l_net,
     x_volume              => l_volume,
     x_return_status       => l_return_status);
   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;

     open  c_check_del_assign(p_delivery_detail_id);
     FETCH c_check_del_assign INTO l_delivery_id, l_planned_flag, l_ignore, l_tms_interface_flag;       -- OTM R12 : cancel quantity, cursor is changed

       IF c_check_del_assign%found THEN
             --
/*Start of bug 2729687*/
          -- Bug fix 2864546. Need to call unassign procedure only when the
          -- delivery is not planned
          -- Per discussion with PM, the cancelled lines should be left
          -- assigned to the delivery if the delivery is planned
          IF nvl(l_planned_flag, 'N') = 'N' THEN

            l_details_id(1) := p_delivery_detail_id;
            WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont (
              p_ids_tobe_unassigned  => l_details_id ,
              p_validate_flag => 'Y',
              x_return_status   => x_return_status);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Unassign_Unpack_Empty_cont x_return_status',x_return_status);
            END IF;

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              return;
            END IF;

          END IF; --nvl(l_planned_flag, 'N') = 'N'
        END IF;

/* End of bug 2729687*/

        close c_check_del_assign;


   IF p_parent_delivery_detail_id IS NOT NULL THEN

    WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont(p_delivery_detail_id,x_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Unassign_Detail_from_Cont x_return_status',x_return_status);
    END IF;
          IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
          END IF;

   END IF;

   IF p_released_status = 'S' THEN
    IF p_ordered_quantity <> 0 THEN
      --
-- HW OPMCONV - Removded code forking
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      INV_MO_Cancel_PVT.Cancel_Move_Order_Line(
         x_return_status        =>  x_return_status
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,p_line_id              =>  p_move_order_line_id
        ,p_delete_reservations  =>  'Y'
        ,p_txn_source_line_id   =>  p_source_line_id
        ,p_delivery_detail_id   => p_delivery_detail_id --X-dock
        );
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'INV_MO_Cancel_PVT.Cancel_Move_Order_Line x_return_status',x_return_status);
      END IF;
--HW OPMCONV. Removed code forking
      IF x_return_status = fnd_api.g_ret_sts_success THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLED MOLINE '||P_MOVE_ORDER_LINE_ID  );
       END IF;
       --
      ELSE
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE '  );
       END IF;
       --
       FND_MESSAGE.Set_Name('WSH', 'WSH_CANCEL_MO_LINE');
       IF l_msg_count = 1 THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
        END IF;
        --
        FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
       ELSE
        FOR l_index IN 1..l_msg_count LOOP
          l_msg_data := fnd_msg_pub.get;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
          END IF;
          --
          l_error_text := l_error_text || l_msg_data;
        END LOOP;
        FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
        l_error_text := '';
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
      END IF;
    ELSE

-- HW OPMCONV - Removed forking the code
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      INV_MO_Cancel_PVT.Cancel_Move_Order_Line(
         x_return_status        =>  x_return_status
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,p_line_id              =>  p_move_order_line_id
        ,p_delete_reservations  =>  'N'
        ,p_txn_source_line_id   =>  p_source_line_id
        ,p_delivery_detail_id   =>  p_delivery_detail_id -- X-dock
        );

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'INV_MO_Cancel_PVT.Cancel_Move_Order_Line x_return_status',x_return_status);
      END IF;
--HW OPMCONV - Removed code forking

      IF x_return_status = fnd_api.g_ret_sts_success THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLED MOLINE '||P_MOVE_ORDER_LINE_ID  );
      END IF;
      --
      ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE '  );
      END IF;
      --
      FND_MESSAGE.Set_Name('WSH', 'WSH_CANCEL_MO_LINE');
      IF l_msg_count = 1 THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
         END IF;
         --
         FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
      ELSE
         FOR l_index IN 1..l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
           END IF;
           --
           l_error_text := l_error_text || l_msg_data;
         END LOOP;
         FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;
    END IF;
   END IF;
  END IF;
  IF p_released_status = 'Y' THEN
   IF p_ordered_quantity <> 0 THEN

     l_delivery_detail_split_rec.delivery_detail_id := p_delivery_detail_id;
     l_delivery_detail_split_rec.released_status  := p_released_status;
     l_delivery_detail_split_rec.move_order_line_id := p_move_order_line_id;
     l_delivery_detail_split_rec.organization_id  := p_organization_id;
     l_delivery_detail_split_rec.inventory_item_id  := p_inventory_item_id;
     l_delivery_detail_split_rec.subinventory    := p_subinventory;
     l_delivery_detail_split_rec.revision      := p_revision;
     l_delivery_detail_split_rec.lot_number    := p_lot_number;
     l_delivery_detail_split_rec.locator_id    := p_locator_id;

     WSH_USA_INV_PVT.cancel_staged_reservation(
         p_source_code        =>   p_source_code,
         p_source_header_id      =>   p_source_header_id,
         p_source_line_id      =>   p_source_line_id,
         p_delivery_detail_split_rec  =>   l_delivery_detail_split_rec, -- New need to build up
         p_cancellation_quantity    =>   l_change_reservation_quantity,
         p_cancellation_quantity2  =>   l_change_reservation_quantity2,
         x_return_status        =>   x_return_status);
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'WSH_USA_INV_PVT.CANCEL_STAGED_RESERVATION',x_return_status);
     END IF;

       IF x_return_status = fnd_api.g_ret_sts_success THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CANCELLED STAGED RESERVATION FOR DETAIL '||P_DELIVERY_DETAIL_ID ||'BY QTY '|| L_CHANGE_RESERVATION_QUANTITY  );
       END IF;
       --
       ELSE
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_USA_INV_PVT.CANCEL_STAGED_RESERVATION '  );
       END IF;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
       END IF;
   END IF;
  END IF;

  -- Debug Statements

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS; --Bug# 3542353
  --
-- HW OPMCONV - Removed code forking

     IF p_ordered_quantity <> 0 THEN

        l_serial_quantity := nvl(p_serial_quantity,0);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Serial Numbers deletion check -
                                                transaction_temp_id, serial_number, serial_quantity : '||
                                                p_transaction_temp_id||', '||p_serial_number||', '||l_serial_quantity);
        END IF;
        --
        IF  ( p_transaction_temp_id IS NOT NULL ) AND ( l_serial_quantity > 0 ) AND
            ( l_serial_quantity > (p_requested_quantity - ABS(p_changed_detail_quantity)) ) THEN

               IF (p_requested_quantity - ABS(p_changed_detail_quantity)) > 0 THEN
                  l_serial_quantity := l_serial_quantity - (p_requested_quantity - ABS(p_changed_detail_quantity));
               END IF;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, l_serial_quantity||' Serial Number(s) have to be deleted for dd '
                                                                       ||p_delivery_detail_id);
               END IF;
               --
               FND_MESSAGE.SET_NAME('WSH','WSH_STAGED_SERIAL_EXISTS');
               FND_MESSAGE.SET_TOKEN('SERIAL_QUANTITY',l_serial_quantity);
               FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',p_delivery_detail_id);
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;

        ELSIF (p_serial_number IS NOT NULL ) AND (p_requested_quantity - ABS(p_changed_detail_quantity) <= 0) THEN
               l_serial_quantity := 1;
               --
               -- Debug Statements
               --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, l_serial_quantity||' Serial Number(s) have to be deleted for dd '
                                                                       ||p_delivery_detail_id);
         END IF;
         --
               FND_MESSAGE.SET_NAME('WSH','WSH_STAGED_SERIAL_EXISTS');
               FND_MESSAGE.SET_TOKEN('SERIAL_QUANTITY',l_serial_quantity);
               FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',p_delivery_detail_id);
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
        END IF;

     ELSIF p_ordered_quantity = 0 AND (p_transaction_temp_id IS NOT NULL OR p_serial_number IS NOT NULL ) THEN
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Complete Order Qty Cancelation - all serial numbers will be unmarked',WSH_DEBUG_SV.C_PROC_LEVEL);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT.UPDATE_SERIAL_NUMBERS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_USA_INV_PVT.update_serial_numbers(
              p_delivery_detail_id     => p_delivery_detail_id,
              p_serial_number          => p_serial_number,
              p_transaction_temp_id    => p_transaction_temp_id,
              x_return_status          => x_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Update_Serial_Numbers x_return_status',x_return_status);
       END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;
       END IF;
     END IF;

/* Bug 2310456 warning handling */

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_USA_INV_PVT.UPDATE_SERIAL_NUMBERS '  );
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  ELSIF l_num_warn > 0 THEN
-- in this API we treat warning as success as of now
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN others THEN
     IF c_check_del_assign%ISOPEN THEN
       CLOSE c_check_del_assign;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, SQLCODE || ' : ' || SQLERRM  );
     END IF;
     --
     wsh_util_core.default_handler('WSH_USA_QUANTITY_PVT.CANCEL_QUANTITY',l_module_name);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END cancel_quantity;


END WSH_USA_QUANTITY_PVT;

/
