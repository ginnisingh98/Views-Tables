--------------------------------------------------------
--  DDL for Package Body INV_SHIPPING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHIPPING_TRANSACTION_PUB" AS
/* $Header: INVPWSHB.pls 120.15.12010000.8 2013/01/29 13:27:07 ssingams ship $ */

G_Debug BOOLEAN := TRUE;

G_RET_STS_SUCCESS      VARCHAR2(1) := FND_API.g_ret_sts_success;
G_RET_STS_ERROR        VARCHAR2(1) := FND_API.g_ret_sts_error;
G_RET_STS_UNEXP_ERROR  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_FALSE                VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE                 VARCHAR2(1) := FND_API.G_TRUE;

--Inline branching
g_wms_current_release_level NUMBER := wms_control.g_current_release_level;
g_inv_current_release_level NUMBER := inv_control.g_current_release_level;
g_j_release_level           NUMBER := inv_release.g_j_release_level;


PROCEDURE DEBUG(p_message       IN VARCHAR2,
                p_module        IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   if( G_Debug = TRUE ) then
--       inv_debug.message('wshtxn', p_message);
      IF (l_debug = 1) THEN
         inv_trx_util_pub.trace(p_message, 'SHPTRX.'||p_module, 1);
      END IF;
--       inv_pick_wave_pick_confirm_pub.tracelog(p_message, 'SHPTRX.'||p_module);
--     dbms_output.put_line(p_message);
-- null;
   end if;
END;


--transportation enhancement for patchset I only
--customer will need to be on shipping's I code
--check whether ship method can be used to ship the delivery
PROCEDURE validate_ship_method(p_shipmethod_code IN  VARCHAR2,
			       p_delivery_id     IN  NUMBER,
			       x_return_status   OUT nocopy VARCHAR2,
			       x_msg_count       OUT nocopy NUMBER,
			       x_msg_data        OUT nocopy varchar2) IS

   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   l_entity_table             WSH_FTE_COMP_CONSTRAINT_GRP.wshfte_ccin_tab_type;
   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_fte_install_status       VARCHAR2(30);
   l_industry                 VARCHAR2(30);
   l_install_return_val       BOOLEAN;

   l_details                  VARCHAR2(4000);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF l_debug = 1 THEN
      debug('Start of validate_ship_method','VALIDATE_SHIP_METHOD');
   END IF;

   --check if FTE installed; only need to validate if FTE installed
   inv_check_product_install.check_fte_installed(x_fte_installed   => l_fte_install_status
					       , x_industry      => l_industry
					       , x_return_status => l_return_status
					       , x_msg_count     => l_msg_count
						 , x_msg_data      =>
						 l_msg_data);
   IF (l_fte_install_status = 'I') THEN
      IF l_debug = 1 THEN
	 debug('delivery_id : ' || p_delivery_id, 'VALIDATE_SHIP_METHOD');
	 debug('shipMethod code: ' || p_shipmethod_code, 'VALIDATE_SHIP_METHOD');
      END IF;

      --query the fields needed to pass into
      --wsh_fte_comp_constraint_grp.validate_constraint
      SELECT organization_id,
	customer_id,
	initial_pickup_location_id,
	ultimate_dropoff_location_id,
	intmed_ship_to_location_id,
	planned_flag,
	status_code
	INTO
	l_entity_table(1).p_organization_id,
	l_entity_table(1).p_customer_id,
	l_entity_table(1).p_ship_from_location_id,
	l_entity_table(1).p_ship_to_location_id,
	l_entity_table(1).p_intmed_location_id,
	l_entity_table(1).p_planned_flag,
	l_entity_table(1).p_status_code
	FROM wsh_new_deliveries_ob_grp_v wnd
	WHERE wnd.delivery_id = p_delivery_id;

      --for validation, 'UPDATE' is the action code
      l_entity_table(1).p_action_code := wsh_fte_comp_constraint_grp.g_action_update;
      l_entity_table(1).p_entity_type := wsh_fte_comp_constraint_grp.g_delivery;
      l_entity_table(1).p_entity_id   := p_delivery_id;
      l_entity_table(1).p_shipmethod_code := p_shipmethod_code;

      wsh_fte_comp_constraint_grp.validate_constraint(p_api_version_number => 1.0,
						      p_init_msg_list      => FND_API.G_TRUE,
						      p_entity_tab         => l_entity_table,
						      x_msg_count          => l_msg_count,
						      x_msg_data           => l_msg_data,
						      x_return_status      => l_return_status);

      IF l_debug = 1 THEN
	 debug('Validate constraint returned with status: ' || l_return_status,'VALIDATE_SHIP_METHOD');
	 debug('Message count is : ' || l_msg_count,'VALIDATE_SHIP_METHOD');
      END IF;

      --treating warnings as errors also
      IF l_return_status <>  WSH_UTIL_CORE.g_ret_sts_success THEN
	 l_return_status := FND_API.g_ret_sts_error;
	 wsh_util_core.get_messages(
				    p_init_msg_list => 'Y',
				    x_summary       => l_msg_data,
				    x_details       => l_details,
				    x_count         => l_msg_count);

	 IF l_debug = 1 THEN
	    	 debug('message from wsh_util_core.get_messages: ' || l_msg_data, 'VALIDATE_SHIP_METHOD');
		 debug('l_msg_count : ' || l_msg_count,
		       'VALIDATE_SHIP_METHOD');
	 END IF;
      END IF;

      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      x_return_status := l_return_status;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug=1 THEN
	 debug('Unexpected error!', 'VALIDATE_SHIP_METHOD');
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END VALIDATE_SHIP_METHOD;
--

FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2)
  RETURN  VARCHAR2  IS
     l_ship_method_meaning VARCHAR2(80);
BEGIN
   if p_ship_method_code is null then
      return '';
    else
      select meaning
	into l_ship_method_meaning
	from fnd_lookup_values_vl
	where lookup_type = 'SHIP_METHOD'
	and view_application_id = 3
	and lookup_code = p_ship_method_code;
   end if;
   return l_ship_method_meaning;
EXCEPTION
   WHEN OTHERS THEN
      return '';
END GET_SHIPMETHOD_MEANING;

PROCEDURE GET_VALID_DELIVERY(x_deliveryLOV OUT NOCOPY t_genref,
			     p_delivery_name IN VARCHAR2,
			     p_organization_id IN NUMBER) IS
BEGIN
   --inv_debug.message('ssia', 'get_valid_delivery');
   OPEN x_deliveryLOV for
     SELECT distinct wnd.name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
     wnd.waybill,
     GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
     FROM wsh_new_deliveries_ob_grp_v wnd, wsh_delivery_assignments_v wda,wsh_delivery_details_ob_grp_v wdd
     WHERE wda.delivery_Detail_id = wdd.delivery_Detail_id
     AND   wda.delivery_id = wnd.delivery_id
     and   ( wdd.released_status = 'Y'
               OR (wdd.released_status='X' and wdd.source_code='RTV') --RTV Change 16197273
	     OR ( wdd.released_status = 'X' and
	       exists (select 1
		       from mtl_system_items_b msi
		       where msi.organization_id = wdd.organization_id
		       and msi.inventory_item_id = wdd.inventory_item_id
		       and msi.mtl_transactions_enabled_flag = 'N'))  -- for nontransactable items
	     )
     and   wdd.organization_id = p_organization_id
     and   wnd.name like (p_delivery_name)
     AND status_code not in ('CO', 'CL', 'IT');
END GET_VALID_DELIVERY;

PROCEDURE GET_VALID_DELIVERY_VIA_LPN(x_deliveryLOV OUT NOCOPY t_genref,
				     p_delivery_name IN VARCHAR2,
				     p_organization_id IN NUMBER,
				     p_lpn_id IN NUMBER) IS
BEGIN

   IF (p_lpn_id = 0) THEN
      OPEN x_deliveryLOV for
	SELECT distinct wnd.name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
	wnd.waybill,
	GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
	FROM wsh_new_deliveries_ob_grp_v wnd, wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd
	WHERE wda.delivery_Detail_id = wdd.delivery_Detail_id
	AND   wda.delivery_id = wnd.delivery_id
	and   wdd.organization_id = p_organization_id
	and   wnd.name like (p_delivery_name);


    ELSE
      OPEN x_deliveryLOV for
        /* Commented for the Bug#4331183
         * This query was a three level nested query, replaced the lowest level of
	 * nesting with a join clause.
	select wnd.name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
	wnd.waybill,
	GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
	from wsh_new_deliveries_ob_grp_v wnd
	where wnd.delivery_id IN -- bug 2326192
	( select wda.delivery_id
	  from wsh_delivery_assignments_v wda
	  where parent_delivery_detail_id =
	  ( select wdd.delivery_detail_id
	    from wsh_delivery_details_ob_grp_v wdd
	    where wdd.lpn_id = p_lpn_id
	    and wdd.organization_id = p_organization_id
	    )
	  )
	and   wnd.name like (p_delivery_name);
	*/
	-- Added for Bug#4331183
	-- Replaced nested sub query by a join condition
	SELECT wnd.name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
	wnd.waybill,
        GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
	FROM wsh_new_deliveries wnd
        WHERE wnd.delivery_id IN
	     ( SELECT wda.delivery_id
	       FROM wsh_delivery_details wdd,
		    wsh_delivery_assignments wda
	       WHERE wdd.lpn_id = p_lpn_id
	       AND wdd.organization_id = p_organization_id
	       AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
	      -- AND wdd.released_status = 'X'    -- For LPN reuse ER : 6845650  -- Commented to display the closed deliveries for bug#13990462
	      )
	AND wnd.name like (p_delivery_name);
   END IF;
END GET_VALID_DELIVERY_VIA_LPN;



PROCEDURE GET_VALID_DELIVERY_LINE(x_deliveryLineLOV OUT NOCOPY t_genref,
				  p_delivery_id IN NUMBER,
				  p_inventory_item_id IN NUMBER) IS
BEGIN
   OPEN x_deliveryLineLOV for
     SELECT wdd.delivery_detail_id
     FROM wsh_delivery_details_ob_grp_v wdd,
     wsh_delivery_assignments_v wda,
     wsh_new_deliveries_ob_grp_v wnd
     WHERE wdd.delivery_detail_id = wda.delivery_detail_id
     AND   wda.delivery_id = wnd.delivery_id
     AND   wnd.delivery_id = p_delivery_id
     AND   wdd.inventory_item_id = nvl(p_inventory_item_id, wdd.inventory_item_id)
     AND   wdd.released_status = 'Y';
END GET_VALID_DELIVERY_LINE;

PROCEDURE GET_VALID_CARRIER(x_carrierLOV OUT NOCOPY t_genref,
			    p_carrier_name IN VARCHAR2) IS
BEGIN
/*
   OPEN x_carrierLOV for
     SELECT   distinct PV.vendor_name, WCSM.carrier_id,
     WCSM.ship_method_code
     FROM     WSH_CARRIER_SHIP_METHODS_V WCSM,
     PO_VENDORS   PV
     WHERE     PV.vendor_name like (p_carrier_name)
     AND      WCSM.carrier_id is not null
     AND      PV.vendor_id = WCSM.carrier_id;
     */
     null;
END GET_VALID_CARRIER;

PROCEDURE GET_SHIP_METHOD_LOV(x_shipMethodLOV OUT NOCOPY t_genref,
			      p_organization_id  IN NUMBER,
			      p_ship_method_name IN VARCHAR2) IS
BEGIN
   OPEN x_shipMethodLOV for
     select
     meaning,
     description,
     lookup_code ship_method_code
     from fnd_lookup_values_vl flv
     where lookup_type = 'SHIP_METHOD'
     and view_application_id = 3
     and nvl(start_date_active,sysdate)<=sysdate
     AND nvl(end_date_active,sysdate)>=sysdate
     AND enabled_flag = 'Y'
     AND meaning like ( p_ship_method_name)
     AND lookup_code in (select ship_method_code
			 from wsh_carrier_services wcs, wsh_org_carrier_services wocs,
			 wsh_carriers wc
			 where  wocs.organization_id = p_organization_id
			 AND wcs.ship_method_code = flv.lookup_code
			 AND wcs.enabled_flag = 'Y'
			 AND wocs.enabled_flag = 'Y'
			 AND wcs.carrier_service_id = wocs.carrier_service_id
			 and wcs.carrier_id = wc.carrier_id
			 AND NVL(wc.generic_flag, 'N') = 'N')
     order by meaning;
END GET_SHIP_METHOD_LOV;

PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
			    p_delivery_id IN NUMBER)  IS
BEGIN
   open x_delivery_info for
     SELECT wnd.name, wnd.delivery_id, nvl(wnd.gross_weight, 0), wnd.weight_uom_code,
     wnd.waybill,' ',
     GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
     FROM wsh_new_deliveries_ob_grp_v wnd
     WHERE wnd.delivery_id = p_delivery_id;
END GET_DELIVERY_INFO;


PROCEDURE INV_DELIVERY_LINE_INFO(x_deliveryLineInfo OUT NOCOPY t_genref,
				 p_delivery_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_serial_flag   IN VARCHAR2,
				 x_return_Status OUT NOCOPY VARCHAR2) IS
BEGIN
   /** ssia 10/17/2002 Add nvl(transaction_temp_id, 0) in the select statement
   For serial - shipping enhancement project
     **/
    /*Bug#5612236. In the below queries, replaced 'MTL_SYSTEM_ITEMS_KFV' with
      'MTL_SYSTEM_ITEMS_VL'.*/
     x_return_Status := 'C';
   if( p_serial_flag = 'N' ) then
      OPEN x_deliveryLineInfo FOR
	SELECT ' ',del.name delivery_name, dd.delivery_detail_id,
	dd.inventory_item_id,msiv.concatenated_segments, msiv.description,
	dd.requested_quantity, dd.requested_quantity_uom,
	dd.serial_number, del.waybill, Nvl(msiv.serial_number_control_code, 1),
	dd.subinventory, Nvl(dd.locator_id,0),dd.tracking_number,
	nvl(dd.transaction_temp_id,0),
	--3348813
	--Adding picked_quantity as part of the return cursor.
	dd.picked_quantity,
	dd.shipped_quantity,
        --Bug 3952081
        --add DUOM values
        REQUESTED_QUANTITY_UOM2,
        REQUESTED_QUANTITY2,
        PICKED_QUANTITY2,
        SHIPPED_QUANTITY2
	FROM wsh_new_deliveries_ob_grp_v del, wsh_delivery_details_ob_grp_v dd,
	wsh_delivery_assignments_v da, mtl_system_items_vl msiv
	WHERE da.delivery_id = del.delivery_id
	AND   da.delivery_detail_id = dd.delivery_detail_id
	AND   ( dd.inventory_item_id = p_inventory_item_id or p_inventory_item_id = -1 )
	AND   NVL( dd.inv_interfaced_flag, 'N') = 'N'
	AND   dd.released_status = 'Y'
	AND   del.delivery_id = p_delivery_id
	AND   msiv.inventory_item_id(+) = dd.inventory_item_id
	AND   msiv.organization_id(+) = dd.organization_id
	ORDER BY dd.subinventory,dd.locator_id, msiv.concatenated_segments;

    else
      OPEN x_deliveryLineInfo FOR
	SELECT ' ',del.name delivery_name, dd.delivery_detail_id, dd.inventory_item_id,
	msiv.concatenated_segments, msiv.description,
	dd.requested_quantity, dd.requested_quantity_uom,
	dd.serial_number, del.waybill, Nvl(msiv.serial_number_control_code, 1),
	dd.subinventory, Nvl(dd.locator_id,0),dd.tracking_number,
	nvl(dd.transaction_temp_id,0),
	--3348813
	--Adding picked_quantity as part of the return cursor.
	dd.picked_quantity,
	dd.shipped_quantity
	FROM wsh_new_deliveries_ob_grp_v del,
	wsh_delivery_details_ob_grp_v dd,
	wsh_delivery_assignments_v da,
	mtl_system_items_vl msiv
	WHERE da.delivery_id = del.delivery_id
	AND   da.delivery_detail_id = dd.delivery_detail_id
	AND   ( dd.inventory_item_id = p_inventory_item_id
		or p_inventory_item_id = -1 )
	AND   NVL( dd.inv_interfaced_flag, 'N') = 'N'
	AND   dd.released_status = 'Y'
	AND   del.delivery_id = p_delivery_id
	AND   msiv.inventory_item_id(+) = dd.inventory_item_id
	AND   msiv.organization_id(+) = dd.organization_id
	AND   msiv.serial_number_control_code = 6
	ORDER BY dd.subinventory, dd.locator_id,msiv.concatenated_segments;

   end if;
EXCEPTION
   when others then
      x_return_Status := 'E';
END INV_DELIVERY_LINE_INFO;

PROCEDURE SERIAL_AT_SALES_CHECK(x_result OUT NOCOPY NUMBER,
				x_item_name  OUT NOCOPY VARCHAR2,
				p_delivery_id IN NUMBER)
  IS
     l_item_name  VARCHAR2(40);
     all_items    VARCHAR2(20000) := NULL;
     cursor item_name is
	select msik.concatenated_segments
	  from wsh_new_deliveries_ob_grp_v del,
	  wsh_delivery_details_ob_grp_v dd,
	  wsh_delivery_assignments_v da,
	  mtl_system_items_kfv msik
	  where da.delivery_id = del.delivery_id
	  AND   da.delivery_detail_id = dd.delivery_detail_id
	  AND   del.delivery_id = p_delivery_id
	  AND   msik.inventory_item_id(+) = dd.inventory_item_id
	  AND   msik.organization_id(+) = dd.organization_id
	  AND   msik.serial_number_control_code = 6;
BEGIN
   OPEN item_name;
   loop
      FETCH item_name into l_item_name;
      EXIT WHEN item_name%NOTFOUND;
      if all_items is null then
	 all_items := l_item_name;
       else
	 all_items := all_items||', '||l_item_name;
      end if;
   end loop;
   CLOSE item_name;
   if  all_items is null then
      x_result := 0;
    else
      x_result := 1;
      x_item_name := all_items;
   end if;
EXCEPTION
   WHEN OTHERS THEN
      x_result := 9999;

END SERIAL_AT_SALES_CHECK;

/** add out parameter x_num_serial_record for serial shipping enhancement project **/
/** Dependencies: in DeliveryLineFListener.java                                   **/
PROCEDURE GET_DELIVERY_LINE_SERIAL_INFO(
					p_delivery_detail_id IN NUMBER,
					x_return_Status OUT NOCOPY VARCHAR2,
					x_inventory_item_id OUT NOCOPY NUMBER,
					x_transaction_Temp_id OUT NOCOPY NUMBER,
					x_subinventory_code OUT NOCOPY VARCHAR2,
					x_revision OUT NOCOPY VARCHAR2,
					x_locator_id OUT NOCOPY NUMBER,
					x_lot_number OUT NOCOPY VARCHAR2,
					x_num_serial_record OUT NOCOPY NUMBER
					) IS

     l_transaction_temp_id NUMBER;
     l_inventory_item_id NUMBER := 0;
     l_subinventory_code VARCHAR2(30);
     l_revision VARCHAR2(10);
     l_locator_id NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number VARCHAR2(80);
     l_serial_number VARCHAR2(30);
     l_num_serial_record NUMBER := 0;

     l_detail_attributes wsh_interface.ChangedAttributeTabType;
     l_InvPCInRecType    wsh_integration.InvPCInRecType;
     l_return_status     VARCHAR2(1);
     l_msg_count         NUMBER;
     l_msg_data          VARCHAR2(2000);

     l_picked_quantity NUMBER := 0;
BEGIN
   --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
   l_InvPCInRecType.transaction_id := NULL;
   l_InvPCInRecType.transaction_temp_id := NULL;
   l_InvPCInRecType.source_code :='INV';
   l_InvPCInRecType.api_version_number :=1.0;

   x_return_Status := 'C';
   select inventory_item_id, subinventory, revision, locator_id,lot_number, transaction_temp_id, serial_number,picked_quantity
     into l_inventory_item_id, l_subinventory_code, l_revision, l_locator_id, l_lot_number,
     l_transaction_temp_id, l_serial_number,l_picked_quantity
     from wsh_delivery_details_ob_grp_v
     where delivery_detail_id = p_delivery_detail_id;

   IF ( l_serial_number IS NULL ) THEN
     IF ( l_transaction_temp_id IS NULL ) THEN
       select mtl_material_Transactions_s.nextval
         into l_InvPCInRecType.transaction_temp_id
         from dual;

       l_transaction_temp_id := l_InvPCInRecType.transaction_temp_id;

       debug('About to call wsh_integration.Set_Inv_PC_Attributes tempid='||l_transaction_temp_id, 'GET_DELIVERY_LINE_SERIAL_INFO');

       wsh_integration.Set_Inv_PC_Attributes
	 (p_in_attributes => l_InvPCInRecType,
	  x_return_status => l_return_status,
	  x_msg_count     => l_msg_count,
	  x_msg_data      => l_msg_data);

       IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
	  debug('wsh_integration.set_inv_pc_attributes failed'
		|| ' with status: ' || l_return_status,'GET_DELIVERY_LINE_SERIAL_INFO');
	  --check where to handle this error
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       l_detail_attributes(1).action_flag := 'U';
       l_detail_attributes(1).delivery_detail_id :=
	 p_delivery_detail_id;
       --Passing picked_quantity also because wsh_interface.update_shipping_attributes
       --will null it out if we do not
       l_detail_attributes(1).picked_quantity := l_picked_quantity;

       debug('About to call wsh_interface.update_shipping_attributes',
	     'GET_DELIVERY_LINE_SERIAL_INFO');
       debug('picked_quantity: ' || l_picked_quantity,'GET_DELIVERY_LINE_SERIAL_INFO');

       wsh_interface.update_shipping_attributes
	 (x_return_status      => l_return_status,
	  p_changed_attributes => l_detail_attributes,
	  p_source_code        => 'INV');

       IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
	  debug('wsh_interface.update_shipping_attributes failed'
		|| ' with status: ' || l_return_status,'GET_DELIVERY_LINE_SERIAL_INFO');
	  --check where to handle this error
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;
      ELSE
	select count(*)
	  into l_num_serial_record
	  From mtl_serial_numbers_temp
	  where transaction_temp_id = l_transaction_temp_id;

	debug('Found '||l_num_serial_record||' lines for tempid '||l_transaction_temp_id,'GET_DELIVERY_LINE_SERIAL_INFO');
     END IF;
   END IF;

   x_inventory_item_id := l_inventory_item_id;
   x_transaction_temp_id := l_transaction_Temp_id;
   x_subinventory_code := l_subinventory_code;
   x_locator_id := l_locator_id;
   x_revision := l_revision;
   x_lot_number := l_lot_number;
   x_num_serial_record := l_num_serial_record;
EXCEPTION
   when NO_DATA_FOUND then
      x_return_Status := 'E';

END GET_DELIVERY_LINE_SERIAL_INFO;

PROCEDURE GET_TRIP_NAME(p_delivery_id IN NUMBER,
			x_trip_name OUT NOCOPY VARCHAR2,
			x_trip_id OUT NOCOPY NUMBER) IS
   l_trip_name VARCHAR2(80);
   l_trip_id NUMBER;
BEGIN
   select trip.name, trip.trip_id
     into l_trip_name, l_trip_id
     from wsh_trips_ob_grp_v trip,
     wsh_trip_stops_ob_grp_v pickup_stop,
     wsh_trip_stops_ob_grp_v dropoff_stop,
     wsh_delivery_legs_ob_grp_v wdl,
     wsh_new_deliveries_ob_grp_v wnd
     where wdl.delivery_id = wnd.delivery_id(+)
     and wdl.delivery_id = p_delivery_id
     and pickup_stop.stop_id = wdl.pick_up_stop_id
     and dropoff_stop.stop_id = wdl.drop_off_stop_id
     and pickup_stop.trip_id = trip.trip_id(+)
     and wnd.delivery_id = p_delivery_id;
EXCEPTION
   when no_data_found THEN
      l_trip_name := 'NONE';
      l_trip_id := -99999;
END GET_TRIP_NAME;

PROCEDURE GET_TRIP_LOV(x_trip_lov OUT NOCOPY t_genref,
		       p_trip_name IN VARCHAR2) IS
BEGIN
   open x_trip_lov for
     select name, trip_id, ship_method_code, carrier_id
     from wsh_trips_ob_grp_v
     where name like p_trip_name
     and status_code = 'OP';
end GET_TRIP_LOV;

procedure get_dock_door(x_dock_door OUT NOCOPY t_genref,
			p_trip_id   IN NUMBER) IS
BEGIN
   open x_dock_door for
     select hrl.location_code
     from wsh_trip_stops_ob_grp_v wts, hr_locations hrl
     where wts.stop_location_id = hrl.location_id
     and wts.trip_id = p_trip_id;
END get_dock_door;

procedure get_items_in_lpn(x_items OUT NOCOPY t_genref,
			   p_lpn_id IN NUMBER) IS
BEGIN
   open x_items for
     select wlpn.inventory_item_id, msik.concatenated_segments
     from wms_license_plate_numbers wlpn, mtl_system_items_kfv msik
     where wlpn.lpn_id = p_lpn_id
     and wlpn.inventory_item_id = msik.inventory_item_id(+);
END get_items_in_lpn;


--Returns an entire delivery to stock.  No partial shipment
PROCEDURE INV_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
			      x_msg_data OUT NOCOPY VARCHAR2,
			      x_msg_count OUT NOCOPY NUMBER) IS

    cursor delivery_details_ids(p_delivery_id NUMBER) is
       select dd.delivery_detail_id
	 from wsh_delivery_assignments_v da,wsh_delivery_details_ob_grp_v dd
	 where da.delivery_id = p_delivery_id
	 and da.delivery_detail_id = dd.delivery_detail_id
	 and dd.container_flag <>'Y';

    cursor lpn_csr(p_delivery_detail_id in NUMBER) is
       select wdd.delivery_detail_id, wda.delivery_assignment_id,wda2.delivery_assignment_id
	 from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd2
	 , wsh_delivery_assignments_v wda2
	 where wdd.delivery_detail_id = wda.parent_delivery_detail_id
	 and wda.delivery_detail_id = wdd2.delivery_detail_id
	 and wdd2.delivery_detail_id = p_delivery_detail_id
	 and wda2.delivery_detail_id = wdd.delivery_detail_id;

    CURSOR nested_parent_lpn_cursor(l_inner_lpn_id NUMBER) is
       SELECT lpn_id
	 FROM WMS_LICENSE_PLATE_NUMBERS
	 START WITH lpn_id = l_inner_lpn_id
	 CONNECT BY lpn_id = PRIOR parent_lpn_id;

    l_return_status  VARCHAR2(1);
    l_delivery_id NUMBER := p_delivery_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_requested_quantity          NUMBER;
    l_requested_quantity2         NUMBER;
    l_picked_quantity             NUMBER;

    l_out_rows                    WSH_UTIL_CORE.ID_TAB_TYPE;
    l_delivery_details_id_table   WSH_UTIL_CORE.ID_TAB_TYPE;
    l_backorder_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
    l_requested_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
    l_overpicked_quantities_table WSH_UTIL_CORE.ID_TAB_TYPE;
    l_dummy_table                 wsh_util_core.id_tab_type;
    l_table_index                 NUMBER := 1;

    l_parent_delivery_detail_id          NUMBER;
    l_delivery_assignment_id      	      NUMBER;
    l_par_delivery_assignment_id         NUMBER;
    l_lpn_id                             NUMBER;

    l_lpn_tbl                     WMS_Data_Type_Definitions_PUB.LPNTableType;
    l_lpn_rec                     WMS_Data_Type_Definitions_PUB.LPNRecordType;

    CURSOR lpn_cur(p_delivery_id NUMBER) IS
    SELECT wdd.lpn_id, wdd.organization_id
    FROM (SELECT delivery_detail_id
          FROM wsh_delivery_assignments_v wda
          WHERE wda.delivery_id = p_delivery_id ) wda
         , wsh_delivery_details_ob_grp_v wdd
    WHERE wda.delivery_detail_id = wdd.delivery_detail_id
    AND   wdd.lpn_id IS NOT NULL;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      debug('Entering the new return_to_stock ','wshtxn');
   END IF;

   OPEN delivery_details_ids(l_delivery_id);
   LOOP
      FETCH delivery_details_ids INTO
	l_delivery_details_id_table(l_table_index);
      EXIT WHEN delivery_details_ids%NOTFOUND;
      IF (l_debug = 1) THEN
	 debug('Return to stock for delivery line '||to_char(l_delivery_details_id_table(l_table_index)),'wshtxn');
      END IF;

      select  dd.requested_quantity, dd.picked_quantity,dd.requested_quantity2
	INTO l_requested_quantity, l_picked_quantity, l_requested_quantity2
	from wsh_delivery_details_ob_grp_v dd
	where
	dd.delivery_detail_id = l_delivery_details_id_table(l_table_index);

      l_backorder_quantities_table(l_table_index) :=
	l_requested_quantity;
      l_requested_quantities_table(l_table_index) :=
	l_requested_quantity;
      l_dummy_table(l_table_index) := l_requested_quantity2;

      IF l_picked_quantity > l_requested_quantity THEN
	 l_overpicked_quantities_table(l_table_index) :=
	   l_picked_quantity - l_requested_quantity;
       ELSE
	 l_overpicked_quantities_table(l_table_index) := 0;
      END IF;

      -- Release 12: LPN SyncUP
      -- In addition to the LPN context update
      -- WDD records also need to be removed
      -- This is done by calling wms_container_pvt.modify_lpn API
      -- Remove the direct update here
      -- Call modify_lpn API after backorder
      /*open lpn_csr(l_delivery_details_id_table(l_table_index));
      LOOP
	 fetch lpn_csr into l_parent_delivery_detail_id,l_delivery_assignment_id,
	   l_par_delivery_assignment_id;
	 exit when lpn_csr%NOTFOUND;

	 -- change the LPN context first since we changed the LPN context to
	 -- picked after pick confirm
	 select lpn_id
	   into l_lpn_id
	   from wsh_delivery_details_ob_grp_v
	   where delivery_detail_id = l_parent_delivery_detail_id;

	 IF (l_debug = 1) THEN
	    debug('Change the context of LPNs to 1:'||l_lpn_id,'wshtxn');
	 END IF;
	 -- change the LPN and parent LPN context
	 FOR l_par_lpn_id IN nested_parent_lpn_cursor(l_lpn_id) LOOP
	    IF (l_debug = 1) THEN
	       debug('LPN ID'||l_par_lpn_id.lpn_id,'wshtxn');
	    END IF;
	    UPDATE WMS_LICENSE_PLATE_NUMBERS
	      SET lpn_context = 1,
	      last_update_date  =  SYSDATE,
	      last_updated_by   =  FND_GLOBAL.USER_ID
	      where lpn_id = l_par_lpn_id.lpn_id;
	 END LOOP;
      END LOOP;
      close lpn_csr;*/

      l_table_index := l_table_index + 1;
   END LOOP;
   CLOSE delivery_details_ids;

   -- Release 12: LPN SyncUP
   -- Populate the lpn_tbl to call modify_lpn API
   -- Call modify_lpn API after backorder
   l_lpn_tbl.delete;
   FOR l_lpn IN lpn_cur(p_delivery_id) LOOP
        l_lpn_rec.organization_id := l_lpn.organization_id;
        l_lpn_rec.lpn_id := l_lpn.lpn_id;
        l_lpn_rec.lpn_context := 1;
        l_lpn_tbl(nvl(l_lpn_tbl.last, 0)+1) := l_lpn_rec;
        IF (l_debug = 1) THEN
           debug('Add to l_lpn_tbl with lpn_rec of org_id'||l_lpn_rec.organization_id
                  ||', lpn_id '||l_lpn_rec.lpn_id||', lpn_context '||l_lpn_rec.lpn_context, 'INV_RETURN_TO_STOCK');
        END IF;
   END LOOP;



   IF (l_debug = 1) THEN
      debug('calling wsh_ship_confirm_actions2.backorder','INV_RETURN_TO_STOCK');
   END IF;
   WSH_SHIP_CONFIRM_ACTIONS2.Backorder(p_detail_ids     => l_delivery_details_id_table,
				       p_bo_qtys        => l_backorder_quantities_table,
				       p_req_qtys       => l_requested_quantities_table,
				       p_bo_qtys2       => l_dummy_table,
				       p_overpick_qtys  => l_overpicked_quantities_table,
				       p_overpick_qtys2 => l_dummy_table,
				       p_bo_mode        => 'UNRESERVE',
				       x_out_rows       => l_out_rows,
				       x_return_status  => l_return_status
				       );

   IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      IF (l_debug = 1) THEN
	 DEBUG('return error from shipping Backorder', 'INV_RETURN_TO_STOCK');
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
	 DEBUG('return error from shipping Backorder', 'INV_RETURN_TO_STOCK');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_success THEN
      COMMIT;
   END IF;



   -- Release 12: LPN SyncUP
   -- Call modify_lpn API to update lpn context to 1
   --  and remove associated WDD lines
   IF(l_debug = 1) THEN
      DEBUG('Calling WMS_CONTAINER_PVT.Modify_LPNs with caller WMS_SHIPPING','INV_RETURN_TO_STOCK');
   END IF;

   WMS_CONTAINER_PVT.Modify_LPNs(
   	  p_api_version           => 1.0
   	, p_init_msg_list         => fnd_api.g_true
   	, p_commit                => fnd_api.g_false
   	, x_return_status         => l_return_status
   	, x_msg_count             => x_msg_count
   	, x_msg_data              => x_msg_data
   	, p_caller                => 'WMS_SHIPPING'
   	, p_lpn_table             => l_lpn_tbl
   );
   IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
   	 DEBUG('return error from WMS_CONTAINER_PVT.Modify_LPNs', 'INV_RETURN_TO_STOCK');
        END IF;
        RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
   	 DEBUG('return error from WMS_CONTAINER_PVT.Modify_LPNs', 'INV_RETURN_TO_STOCK');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_success THEN
        null;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INV_RETURN_TO_STOCK');
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
END INV_RETURN_TO_STOCK;


PROCEDURE INV_DELAY_SHIPMENT(p_delivery_id IN NUMBER,
			     p_delivery_line_id IN NUMBER,
			     p_shipped_quantity IN NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2,
			     x_msg_data OUT NOCOPY VARCHAR2,
			     x_msg_count OUT NOCOPY NUMBER) IS
       l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       l_detail_attributes WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
       l_details VARCHAR2(2000);
BEGIN

   --null;
   -- need to split the delivery line
   -- the delivery line is split during the om interface, so
   -- all we need to do here is to update the shipped_quantity of the delivery line
   -- so later when shipping interface to OM, the delivery line will be split
   l_detail_attributes(1).cycle_count_quantity := 0; /* Bug 5466481 */
   l_detail_attributes(1).shipped_quantity := p_shipped_quantity;
   l_detail_attributes(1).delivery_detail_id := p_delivery_line_id;

   IF l_debug = 1 THEN
      debug('About to call Shipping ' ||
	    'wsh_delivery_details_pub.update_shipping_attributes', 'INV_DELAY_SHIPMENT');
   END IF;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF x_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
	 debug('wsh_delivery_details_pub.update_shipping_attributes failed'
	       || ' with status: ' || x_return_status, 'INV_DELAY_SHIPMENT');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);
   when no_data_found then
      -- put error message on the stack
      null;

END INV_DELAY_SHIPMENT;

PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
				   p_delivery_line_id IN NUMBER,
				   p_shipped_quantity IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2,
				   x_msg_data OUT NOCOPY VARCHAR2,
				   x_msg_count OUT NOCOPY NUMBER,
				   p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_true,
				   p_relieve_rsv  IN VARCHAR2 DEFAULT 'Y')
IS
     cursor delivery_line(p_delivery_detail_id NUMBER) is
	select dd.delivery_detail_id, dd.requested_quantity, dd.picked_quantity
	  from wsh_delivery_details_ob_grp_v dd
	  WHERE dd.delivery_detail_id = p_delivery_detail_id;

     cursor lpn_csr(p_delivery_detail_id in NUMBER) is
	select wdd.delivery_detail_id, wda.delivery_assignment_id,wda2.delivery_assignment_id
	  from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd2
	  , wsh_delivery_assignments_v wda2
	  where wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  and wda.delivery_detail_id = wdd2.delivery_detail_id
	  and wdd2.delivery_detail_id = p_delivery_detail_id
	  and wda2.delivery_detail_id = wdd.delivery_detail_id;

     CURSOR nested_parent_lpn_cursor(l_inner_lpn_id NUMBER) is
	SELECT lpn_id
	  FROM WMS_LICENSE_PLATE_NUMBERS
	  START WITH lpn_id = l_inner_lpn_id
	  CONNECT BY lpn_id = PRIOR parent_lpn_id;

     l_delivery_details_id_table   WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_requested_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_overpicked_quantities_table WSH_UTIL_CORE.ID_TAB_TYPE;
     l_dummy_table                 wsh_util_core.id_tab_type;
     l_out_rows                    wsh_util_core.id_tab_type;
     l_detail_attributes           wsh_delivery_details_pub.ChangedAttributeTabType;
     l_dummy_num_var               NUMBER := NULL;
     l_table_index                 NUMBER := 1;

     l_picked_quantity             NUMBER;
     l_parent_delivery_detail_id   NUMBER;
     l_bo_delivery_detail_id      NUMBER;
     l_delivery_assignment_id      NUMBER;
     l_par_delivery_assignment_id  NUMBER;
     l_lpn_id                      NUMBER;

     l_more_detail                 NUMBER;

     l_return_status               VARCHAR2(1);
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(2000);

     l_bo_mode                     VARCHAR2(10);

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
	 l_global_param_rec	WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;   --6607967 --FP6922321
     l_return_shipping_status				VARCHAR2(30);  --6607967--FP6922321
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   --this cursor only returns 1 record because delivery_line_id is an
   --unique key

   IF l_debug = 1 THEN
      debug('Entered INV_LINE_RETURN_TO_STOCK ', 'INV_LINE_RETURN_TO_STOCK');
      debug('p_delivery_line_id: ' || p_delivery_line_id, 'INV_LINE_RETURN_TO_STOCK');
      debug('p_delivery_id: ' || p_delivery_id , 'INV_LINE_RETURN_TO_STOCK');
      debug('p_shipped_quantity: ' ||p_shipped_quantity , 'INV_LINE_RETURN_TO_STOCK');
      debug('p_commit_flag: ' || p_commit_flag , 'INV_LINE_RETURN_TO_STOCK');
      debug('p_relieve_rsv: ' || p_relieve_rsv, 'INV_LINE_RETURN_TO_STOCK');
   END IF;

   OPEN delivery_line(p_delivery_line_id);

   FETCH delivery_line INTO
     l_delivery_details_id_table(1),
     l_requested_quantities_table(1),
     l_picked_quantity;

     IF l_debug = 1 THEN
         debug('fetched : l_delivery_details_id_table(1): '||  l_delivery_details_id_table(1), 'INV_LINE_RETURN_TO_STOCK');
         debug('fetched : l_requested_quantities_table(1): '||  l_requested_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
         debug('fetched : l_picked_quantity: '||  l_picked_quantity, 'INV_LINE_RETURN_TO_STOCK');
     END IF;
	       --6607967  start --FP 6922321
      WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(l_global_param_rec, l_return_shipping_status);
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           debug('ERROR WHILE FETCHING SHIPPING GLOBAL PARAMETERS l_return_shipping_status'||l_return_shipping_status, 'INV_LINE_RETURN_TO_STOCK');
      END IF;

      debug('fetched : l_global_param_rec.consolidate_bo_lines: '||  l_global_param_rec.consolidate_bo_lines, 'INV_LINE_RETURN_TO_STOCK');

	  IF ( l_global_param_rec.consolidate_bo_lines = 'Y' ) THEN
	    l_backorder_quantities_table(1) :=l_requested_quantities_table(1) - p_shipped_quantity;

	    IF l_picked_quantity > l_requested_quantities_table(1) THEN
	      l_overpicked_quantities_table(1) :=l_picked_quantity - l_requested_quantities_table(1);
	    ELSE
	      l_overpicked_quantities_table(1) := 0;
	    END IF;
	  ELSE
	    IF (l_picked_quantity > l_requested_quantities_table(1)) THEN
	      l_backorder_quantities_table(1)  :=l_picked_quantity - p_shipped_quantity;
	      l_overpicked_quantities_table(1) :=l_picked_quantity - l_requested_quantities_table(1);
	    ELSE
	      l_backorder_quantities_table(1) := l_requested_quantities_table(1) - p_shipped_quantity;
	      l_overpicked_quantities_table(1) := 0;
	    END IF;
	  END IF;

       debug('fetched : new l_requested_quantities_table(1):  '||  l_requested_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
       debug('fetched : new l_picked_quantity: '||  l_picked_quantity, 'INV_LINE_RETURN_TO_STOCK');
       debug('fetched : new l_backorder_quantities_table(1): '||  l_backorder_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
       --6607967  end  --FP 6922321 END

   l_dummy_table(1) := NULL;

   CLOSE delivery_line;
   IF l_debug = 1 THEN
      debug('l_overpicked_quantities_table(1): '||  l_overpicked_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
      debug('l_backorder_quantities_table(1): '||  l_backorder_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
      debug('l_requested_quantities_table(1): '||  l_requested_quantities_table(1), 'INV_LINE_RETURN_TO_STOCK');
   END IF;

   IF p_shipped_quantity = 0 THEN
      IF l_debug = 1 THEN
         debug('Before lpn_csr(l_delivery_details_id_table(1)): '||  l_delivery_details_id_table(1), 'INV_LINE_RETURN_TO_STOCK');
      END IF;

      -- Release 12: LPN SyncUP
      -- In addition to the LPN context update
      -- WDD records also need to be removed
      -- This is done by calling wms_container_pvt.modify_lpn API
      --  in WMS_DIRECT_SHIP_PVT.UNLOAD_TRUCK
      -- Remove the direct update here
      /*OPEN lpn_csr(l_delivery_details_id_table(1));
      LOOP
	 FETCH lpn_csr INTO
	   l_parent_delivery_detail_id, l_delivery_assignment_id,
	   l_par_delivery_assignment_id;

	 EXIT WHEN lpn_csr%NOTFOUND;

         IF l_debug = 1 THEN
            debug('l_parent_delivery_detail_id: '||  l_parent_delivery_detail_id, 'INV_LINE_RETURN_TO_STOCK');
            debug('l_delivery_assignment_id: '||  l_delivery_assignment_id, 'INV_LINE_RETURN_TO_STOCK');
            debug('l_par_delivery_assignment_id: '||  l_par_delivery_assignment_id, 'INV_LINE_RETURN_TO_STOCK');
         END IF;

	 SELECT lpn_id
	   INTO l_lpn_id
	   FROM wsh_delivery_details_ob_grp_v wdd
	   WHERE delivery_detail_id = l_parent_delivery_detail_id;

         IF l_debug = 1 THEN
            debug('l_lpn_id: '||  l_lpn_id, 'INV_LINE_RETURN_TO_STOCK');
         END IF;

	 --update LPN(s) context to Resides in Inventory

	 FOR l_par_lpn_id IN nested_parent_lpn_cursor(l_lpn_id) LOOP
         IF l_debug = 1 THEN
            debug('l_par_lpn_id.lpn_id: '||  l_par_lpn_id.lpn_id, 'INV_LINE_RETURN_TO_STOCK');
         END IF;
	    UPDATE wms_license_plate_numbers
	      SET lpn_context = 1,
	      last_update_date = SYSDATE,
	      last_updated_by   = fnd_global.user_id
	      WHERE lpn_id = l_par_lpn_id.lpn_id;
         IF l_debug = 1 THEN
            debug('Updated wms_license_plate_numbers context 1: ', 'INV_LINE_RETURN_TO_STOCK');
         END IF;
	 END LOOP;

	 --**Check whether Shipping's backorder API does
	 --1.  Unassign the delivery line from container
	 --2.  if container becomes empty, unassign the container from
	 --    delivery
      END LOOP;

      CLOSE lpn_csr;*/
      -- End of release 12 change

    ELSE --corresponding if: p_shipped_quantity = 0

	    IF l_debug = 1 THEN
	       debug('Backordering part of delivery line: '|| l_delivery_details_id_table(1),
		     'INV_LINE_RETURN_TO_STOCK');
	       debug('Splitting the delivery line into ship: '
		     || p_shipped_quantity || ' backorder : '
		     || l_backorder_quantities_table(1)
		     || ' requested : ' || l_requested_quantities_table(1)
		     , 'INV_LINE_RETURN_TO_STOCK');
	    END IF;

	    WSH_DELIVERY_DETAILS_PUB.split_line
	      (p_api_version   => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit        => p_commit_flag,
	       x_return_status => l_return_status,
	       x_msg_count     => l_msg_count,
	       x_msg_data      => l_msg_data,
	       p_from_detail_id => l_delivery_details_id_table(1),
	       x_new_detail_id => l_bo_delivery_detail_id,
	       x_split_quantity => l_backorder_quantities_table(1),
	       x_split_quantity2 => l_dummy_num_var);

	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
	       IF l_debug = 1 THEN
		  debug('WSH_DELIVERY_DETAILS_PUB.split_line failed',
			'INV_LINE_RETURN_TO_STOCK');
	       END IF;

	       RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_detail_attributes(1).delivery_detail_id :=
	     l_delivery_details_id_table(1);
	   l_detail_attributes(1).shipped_quantity := p_shipped_quantity;

	   wsh_delivery_details_pub.update_shipping_attributes
	     (p_api_version_number   => 1.0,
	      p_init_msg_list        => fnd_api.g_false,
	      p_commit               => p_commit_flag,
	      x_return_status        => l_return_status,
	      x_msg_count            => l_msg_count,
	      x_msg_data             => l_msg_data,
	      p_changed_attributes   => l_detail_attributes,
	      p_source_code          => 'OE');

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	      IF l_debug = 1 THEN
		 debug('wsh_delivery_details_pub.update_shipping_attributesfailed',
		       'INV_LINE_RETURN_TO_STOCK');
	      END IF;

	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_delivery_details_id_table(1) := l_bo_delivery_detail_id;
   END IF;

   IF l_debug = 1 THEN
      debug('Calling wsh_ship_confirm_actions2.backorder' ,'INV_LINE_RETURN_TO_STOCK');
      debug('delivery line being backorder : '|| l_delivery_details_id_table(1), 'INV_LINE_RETURN_TO_STOCK');
      debug(' backorder quantity : ' || l_backorder_quantities_table(1),'INV_LINE_RETURN_TO_STOCK');
      debug(' requested quantity : ' || l_requested_quantities_table(1),'INV_LINE_RETURN_TO_STOCK');
      debug(' overpick quantity : ' || l_overpicked_quantities_table(1) ,'INV_LINE_RETURN_TO_STOCK');
   END IF;

   --bug3564157: Shipping's API require the dummy_table to be initialized
   l_dummy_table(1) := 0;

   /* -- MRANA : bug:4594831-- Added the following setup, if p_relieve_rsv = 'Y',
   then we want reservations to be deleted after backorder, if it is N, then we
   want to retain reservations. Note that the overpicked reservations will not be
   retained.
   p_relieve_rsv is set by the unload page (UnloadTruckPage.java) using the value
   passed in the form function parameter- RELIEVE_RSV */
   IF nvl(p_relieve_rsv,'Y') = 'Y' THEN
      l_bo_mode := 'UNRESERVE';
   ELSE
      l_bo_mode := 'RETAIN_RSV'; -- suggested by shipping
   END IF;

   wsh_ship_confirm_actions2.backorder
     (p_detail_ids => l_delivery_details_id_table,
      p_bo_qtys    => l_backorder_quantities_table,
      p_req_qtys   => l_requested_quantities_table, --BUG15854656
      p_bo_qtys2    => l_dummy_table,
      p_overpick_qtys => l_overpicked_quantities_table,
      p_overpick_qtys2 => l_dummy_table,
      p_bo_mode => l_bo_mode, -- MRANA : bug:4594831-- 'UNRESERVE',
      x_out_rows => l_out_rows,
      x_return_status => l_return_status);


   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
	 debug('wsh_ship_confirm_actions2.backorder failed',
	       'INV_LINE_RETURN_TO_STOCK');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF p_commit_flag = fnd_api.g_true THEN
      IF l_debug = 1 THEN
	 debug('Successful, so commit everything','INV_LINE_RETURN_TO_STOCK');
      END IF;
      commit;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INV_LINE_RETURN_TO_STOCK');
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);

END INV_LINE_RETURN_TO_STOCK;

  /**
   Bug No 3952081
   Override INV_LINE_RETURN_TO_STOCK to include DUOM attributes
  **/
PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
				   p_delivery_line_id IN NUMBER,
				   p_shipped_quantity IN NUMBER,
                                   p_sec_shipped_quantity IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2,
				   x_msg_data OUT NOCOPY VARCHAR2,
				   x_msg_count OUT NOCOPY NUMBER,
				   p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_true,
				   p_relieve_rsv  IN VARCHAR2 DEFAULT 'Y')
IS

   /* Change the cursor to pick up secondary picked and requested quantities */
   cursor delivery_line(p_delivery_detail_id NUMBER) is
   select dd.delivery_detail_id, dd.requested_quantity, dd.picked_quantity,
          PICKED_QUANTITY2, REQUESTED_QUANTITY2
       from wsh_delivery_details_ob_grp_v dd
       WHERE dd.delivery_detail_id = p_delivery_detail_id;

     cursor lpn_csr(p_delivery_detail_id in NUMBER) is
	select wdd.delivery_detail_id, wda.delivery_assignment_id,wda2.delivery_assignment_id
	  from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd2
	  , wsh_delivery_assignments_v wda2
	  where wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  and wda.delivery_detail_id = wdd2.delivery_detail_id
	  and wdd2.delivery_detail_id = p_delivery_detail_id
	  and wda2.delivery_detail_id = wdd.delivery_detail_id;

     CURSOR nested_parent_lpn_cursor(l_inner_lpn_id NUMBER) is
	SELECT lpn_id
	  FROM WMS_LICENSE_PLATE_NUMBERS
	  START WITH lpn_id = l_inner_lpn_id
	  CONNECT BY lpn_id = PRIOR parent_lpn_id;

     l_delivery_details_id_table   WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_requested_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_overpicked_quantities_table WSH_UTIL_CORE.ID_TAB_TYPE;
     l_sec_bck_qtys_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_sec_req_qtys_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_sec_ovpk_qtys_table WSH_UTIL_CORE.ID_TAB_TYPE;
     l_dummy_table                 wsh_util_core.id_tab_type;
     l_out_rows                    wsh_util_core.id_tab_type;
     l_detail_attributes           wsh_delivery_details_pub.ChangedAttributeTabType;
     l_dummy_num_var               NUMBER := NULL;
     l_table_index                 NUMBER := 1;

     l_picked_quantity             NUMBER;
     l_sec_picked_quantity             NUMBER;
     l_parent_delivery_detail_id   NUMBER;
     l_bo_delivery_detail_id      NUMBER;
     l_delivery_assignment_id      NUMBER;
     l_par_delivery_assignment_id  NUMBER;
     l_lpn_id                      NUMBER;

     l_more_detail                 NUMBER;

     l_return_status               VARCHAR2(1);
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(2000);

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   --this cursor only returns 1 record because delivery_line_id is an
   --unique key
   OPEN delivery_line(p_delivery_line_id);

   FETCH delivery_line INTO
     l_delivery_details_id_table(1),
     l_requested_quantities_table(1),
     l_picked_quantity,
     l_sec_picked_quantity,
     l_sec_req_qtys_table(1);


   IF l_picked_quantity > l_requested_quantities_table(1) THEN
      l_backorder_quantities_table(1) :=
	l_picked_quantity - p_shipped_quantity;

      l_overpicked_quantities_table(1) :=
	l_picked_quantity - l_requested_quantities_table(1);

      l_sec_bck_qtys_table(1) := l_sec_picked_quantity - p_sec_shipped_quantity;

      l_sec_ovpk_qtys_table(1) := l_sec_picked_quantity - l_sec_req_qtys_table(1);

    ELSE
      l_backorder_quantities_table(1) := l_requested_quantities_table(1) - p_shipped_quantity;

      l_overpicked_quantities_table(1) := 0;

      l_sec_bck_qtys_table(1) := l_sec_req_qtys_table(1) - p_sec_shipped_quantity;

      l_sec_ovpk_qtys_table(1) := 0;
   END IF;

   l_dummy_table(1) := NULL;

   CLOSE delivery_line;

   IF p_shipped_quantity = 0 THEN
      IF l_debug = 1 THEN
	 debug('Backordering the entire delivery line: '
	       || l_delivery_details_id_table(1), 'INV_LINE_RETURN_TO_STOCK');
      END IF;

      -- Release 12: LPN SyncUP
      -- In addition to the LPN context update
      -- WDD records also need to be removed
      -- This is done by calling wms_container_pvt.modify_lpn API
      --  in WMS_DIRECT_SHIP_PVT.UNLOAD_TRUCK
      -- Remove the direct update here
      /*OPEN lpn_csr(l_delivery_details_id_table(1));
      LOOP
	 FETCH lpn_csr INTO
	   l_parent_delivery_detail_id, l_delivery_assignment_id,
	   l_par_delivery_assignment_id;

	 EXIT WHEN lpn_csr%NOTFOUND;

	 SELECT lpn_id
	   INTO l_lpn_id
	   FROM wsh_delivery_details_ob_grp_v wdd
	   WHERE delivery_detail_id = l_parent_delivery_detail_id;

	 --update LPN(s) context to Resides in Inventory
	 FOR l_par_lpn_id IN nested_parent_lpn_cursor(l_lpn_id) LOOP
	    UPDATE wms_license_plate_numbers
	      SET lpn_context = 1,
	      last_update_date = SYSDATE,
	      last_updated_by   = fnd_global.user_id
	      WHERE lpn_id = l_par_lpn_id.lpn_id;
	 END LOOP;

	 --**Check whether Shipping's backorder API does
	 --1.  Unassign the delivery line from container
	 --2.  if container becomes empty, unassign the container from
	 --    delivery
      END LOOP;

      CLOSE lpn_csr;*/

    ELSE --corresponding if: p_shipped_quantity = 0

	    IF l_debug = 1 THEN
	       debug('Backordering part of delivery line: '|| l_delivery_details_id_table(1),
		     'INV_LINE_RETURN_TO_STOCK');
	       debug('Splitting the delivery line into ship: '
		     || p_shipped_quantity || ' backorder : '
		     || l_backorder_quantities_table(1)
		     || ' requested : ' || l_requested_quantities_table(1)
		     , 'INV_LINE_RETURN_TO_STOCK');
	    END IF;

	    WSH_DELIVERY_DETAILS_PUB.split_line
	      (p_api_version   => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit        => p_commit_flag,
	       x_return_status => l_return_status,
	       x_msg_count     => l_msg_count,
	       x_msg_data      => l_msg_data,
	       p_from_detail_id => l_delivery_details_id_table(1),
	       x_new_detail_id => l_bo_delivery_detail_id,
	       x_split_quantity => l_backorder_quantities_table(1),
	       x_split_quantity2 => l_sec_bck_qtys_table(1));

	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
	       IF l_debug = 1 THEN
		  debug('WSH_DELIVERY_DETAILS_PUB.split_line failed',
			'INV_LINE_RETURN_TO_STOCK');
	       END IF;

	       RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_detail_attributes(1).delivery_detail_id :=
	     l_delivery_details_id_table(1);
	   l_detail_attributes(1).shipped_quantity := p_shipped_quantity;

           /* set secondary shipped quantity into the delivery details attribute set */
           l_detail_attributes(1).shipped_quantity2 := p_sec_shipped_quantity;

	   wsh_delivery_details_pub.update_shipping_attributes
	     (p_api_version_number   => 1.0,
	      p_init_msg_list        => fnd_api.g_false,
	      p_commit               => p_commit_flag,
	      x_return_status        => l_return_status,
	      x_msg_count            => l_msg_count,
	      x_msg_data             => l_msg_data,
	      p_changed_attributes   => l_detail_attributes,
	      p_source_code          => 'OE');

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	      IF l_debug = 1 THEN
		 debug('wsh_delivery_details_pub.update_shipping_attributesfailed',
		       'INV_LINE_RETURN_TO_STOCK');
	      END IF;

	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_delivery_details_id_table(1) := l_bo_delivery_detail_id;
   END IF;

   IF l_debug = 1 THEN
      debug('Calling wsh_ship_confirm_actions2.backorder'
	    ,'INV_LINE_RETURN_TO_STOCK');
      debug('delivery line being backorder : '|| l_delivery_details_id_table(1)
	    || ' backorder quantity : ' || l_backorder_quantities_table(1)
	    || ' requested quantity : ' || l_requested_quantities_table(1)
	    || ' overpick quantity : ' || l_overpicked_quantities_table(1)
	    ,'INV_LINE_RETURN_TO_STOCK');
   END IF;

   --bug3564157: Shipping's API require the dummy_table to be initialized
   l_dummy_table(1) := 0;
   wsh_ship_confirm_actions2.backorder
     (p_detail_ids => l_delivery_details_id_table,
      p_bo_qtys    => l_backorder_quantities_table,
      p_req_qtys   => l_requested_quantities_table, --BUG15854656
      p_bo_qtys2    =>l_sec_bck_qtys_table,
      p_overpick_qtys => l_overpicked_quantities_table,
      p_overpick_qtys2 => l_sec_ovpk_qtys_table,
      p_bo_mode => 'UNRESERVE',
      x_out_rows => l_out_rows,
      x_return_status => l_return_status);


   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
	 debug('wsh_ship_confirm_actions2.backorder failed',
	       'INV_LINE_RETURN_TO_STOCK');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF p_commit_flag = fnd_api.g_true THEN
      IF l_debug = 1 THEN
	 debug('Successful, so commit everything','INV_LINE_RETURN_TO_STOCK');
      END IF;
      commit;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INV_LINE_RETURN_TO_STOCK');
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);

END INV_LINE_RETURN_TO_STOCK;

PROCEDURE INV_REPORT_MISSING_QTY(
				 p_delivery_line_id IN NUMBER,
				 p_missing_quantity IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
    l_details      VARCHAR2(2000);
BEGIN
   l_detail_attributes(1).cycle_count_quantity := p_missing_quantity;
   l_detail_attributes(1).delivery_detail_id   := p_delivery_line_id;

   IF l_debug = 1 THEN
      debug('About to call wsh_delivery_details_pub.update_shipping_attributes',
	    'INV_REPORT_MISSING_QTY');
   END IF;
   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF x_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
	 debug('wsh_delivery_details_pub.update_shipping_attributes failed'
	       || ' with status: ' || x_return_status, 'INV_REPORT_MISSING_QTY');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);
   when no_data_found then
      -- do nothing for now
      null;

END INV_REPORT_MISSING_QTY;

  /**
   Bug No 3952081
   Overiding method INV_REPORT_MISSINg_QTY to include DUOM
   attributes as part of input arguments
  **/
PROCEDURE INV_REPORT_MISSING_QTY(
				 p_delivery_line_id IN NUMBER,
				 p_missing_quantity IN NUMBER,
                                 p_sec_missing_quantity IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
    l_details      VARCHAR2(2000);
BEGIN
   l_detail_attributes(1).cycle_count_quantity := p_missing_quantity;

   /* Set cycle_count_quantity2 using argument p_sec_missing_quantity */
   l_detail_attributes(1).cycle_count_quantity2 := p_sec_missing_quantity;

   l_detail_attributes(1).delivery_detail_id   := p_delivery_line_id;

   IF l_debug = 1 THEN
      debug('After setting l_detail_attributes(1).cycle_count_quantity2 is '|| l_detail_attributes(1).cycle_count_quantity2,
	    'INV_REPORT_MISSING_QTY');
   END IF;

   IF l_debug = 1 THEN
      debug('About to call wsh_delivery_details_pub.update_shipping_attributes',
	    'INV_REPORT_MISSING_QTY');
   END IF;
   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF x_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
	 debug('wsh_delivery_details_pub.update_shipping_attributes failed'
	       || ' with status: ' || x_return_status, 'INV_REPORT_MISSING_QTY');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);
   when no_data_found then
      -- do nothing for now
      null;

END INV_REPORT_MISSING_QTY;

PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
			       p_quantity IN NUMBER,
			       p_trackingNumber IN VARCHAR2,
			       x_return_status OUT NOCOPY VARCHAR2,
			       x_msg_data OUT NOCOPY VARCHAR2,
			       x_msg_count OUT NOCOPY NUMBER ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;


    l_details      VARCHAR2(2000);

    CURSOR c_weight_vol_info IS
       SELECT unit_weight,
              unit_volume,
              nvl(wv_frozen_flag ,'N') wv_frozen_flag
       FROM WSH_DELIVERY_DETAILS_OB_GRP_V
       WHERE delivery_detail_id = p_delivery_line_id;

    l_weight_vol_info c_weight_vol_info%ROWTYPE;

    l_gross_weight NUMBER;

    l_net_weight NUMBER;

    l_total_volume NUMBER;

BEGIN
   IF l_debug = 1 THEN
      debug('p_quantity passed in: ' || p_quantity,'SUBMIT_DELIVERY_LINE');
      debug('p_trackingNumber: ' ||p_trackingNumber,'SUMBIT_DELIVERY_LINE');
      debug('p_deliery_line_id: ' || p_delivery_line_id,'SUBMIT_DELIVERY_LINE');
   END IF;

   IF p_quantity IS NOT NULL then
     if p_quantity > 0 then /* Bug 5466481 */
       l_detail_attributes(1).shipped_quantity := p_quantity;
     end if;

      OPEN c_weight_vol_info;

      FETCH c_weight_vol_info INTO l_weight_vol_info;

      CLOSE c_weight_vol_info;

      IF (l_debug =1) THEN
         debug('Unit Weight :'||l_weight_vol_info.unit_weight||l_weight_vol_info.unit_volume,'SUBMIT_DELIVERY_LINE');
         debug('Unit Volume  are :'||l_weight_vol_info.unit_weight||l_weight_vol_info.unit_volume,'SUBMIT_DELIVERY_LINE');
      END IF;

      IF (l_weight_vol_info.wv_frozen_flag='N' AND (l_weight_vol_info.unit_weight IS NOT NULL OR l_weight_vol_info.unit_volume IS NOT NULL))  THEN

      IF l_weight_vol_info.unit_weight IS NOT NULL THEN
       l_detail_attributes(1).gross_weight := p_quantity*l_weight_vol_info.unit_weight;
       l_detail_attributes(1).net_weight   := p_quantity*l_weight_vol_info.unit_weight;
      END IF;

      IF l_weight_vol_info.unit_volume IS NOT NULL  THEN
             l_detail_attributes(1).volume       := p_quantity*l_weight_vol_info.unit_volume;
      END IF;

       IF (l_debug=1) THEN
          debug('The Gross weight calcuated is '||l_detail_attributes(1).gross_weight,'SUBMIT_DELIVERY_LINE');
          debug('The Net weight calcuated is '||l_detail_attributes(1).net_weight,'SUBMIT_DELIVERY_LINE');
          debug('The Volume calcuated is '||l_detail_attributes(1).volume,'SUBMIT_DELIVERY_LINE');
       END IF;
      END IF;
   END IF;

   IF p_trackingNumber IS NOT NULL THEN
      IF l_debug = 1 THEN
	 debug('updating tracking number to: ' || p_trackingNumber,'SUBMIT_DELIVERY_LINE');
      END IF;
      l_detail_attributes(1).tracking_number := p_trackingNumber;
   END IF;

   l_detail_attributes(1).delivery_detail_id := p_delivery_line_id;

   IF l_debug = 1 THEN
      debug('About to call wsh_delivery_details_pub.update_shipping_attributes',
	    'SUBMIT_DELIVERY_LINE');
   END IF;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_TRUE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF l_debug = 1 THEN
      debug('return stat: ' || x_return_status,'SUBMIT_DELIVERY_LINE');
   END IF;

   IF x_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
	 debug('wsh_delivery_details_pub.update_shipping_attributes failed'
	       || ' with status: ' || x_return_status, 'SUBMIT_DELIVERY_LINE');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);

      IF l_debug = 1 THEN
	 debug('x_summary: ' || x_msg_data,'SUBMIT_DELIVERY_LINE');
	 debug('x_details: ' || l_details, 'SUBMIT_DELIVERY_LINE');
      END IF;
   when no_data_found then
      -- do nothing for now
      null;
END SUBMIT_DELIVERY_LINE;

--Bug 3952081
--Override SUBMIT_DELIVERY_LINE to include secondary qty as
-- parameter
PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
			       p_quantity IN NUMBER,
                               p_sec_quantity IN NUMBER,
			       p_trackingNumber IN VARCHAR2,
			       x_return_status OUT NOCOPY VARCHAR2,
			       x_msg_data OUT NOCOPY VARCHAR2,
			       x_msg_count OUT NOCOPY NUMBER ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;


    l_details      VARCHAR2(2000);

    CURSOR c_weight_vol_info IS
       SELECT unit_weight,
              unit_volume,
              nvl(wv_frozen_flag ,'N') wv_frozen_flag
       FROM WSH_DELIVERY_DETAILS_OB_GRP_V
       WHERE delivery_detail_id = p_delivery_line_id;

    l_weight_vol_info c_weight_vol_info%ROWTYPE;

    l_gross_weight NUMBER;

    l_net_weight NUMBER;

    l_total_volume NUMBER;

BEGIN
   IF l_debug = 1 THEN
      debug('p_quantity passed in: ' || p_quantity,'SUBMIT_DELIVERY_LINE');
      debug('p_trackingNumber: ' ||p_trackingNumber,'SUMBIT_DELIVERY_LINE');
      debug('p_deliery_line_id: ' || p_delivery_line_id,'SUBMIT_DELIVERY_LINE');
   END IF;

   IF p_quantity IS NOT NULL then
     if p_quantity > 0 then /* Bug 5466481 */
       l_detail_attributes(1).shipped_quantity := p_quantity;
     end if;

      OPEN c_weight_vol_info;

      FETCH c_weight_vol_info INTO l_weight_vol_info;

      CLOSE c_weight_vol_info;

      IF (l_debug =1) THEN
         debug('Unit Weight :'||l_weight_vol_info.unit_weight||l_weight_vol_info.unit_volume,'SUBMIT_DELIVERY_LINE');
         debug('Unit Volume  are :'||l_weight_vol_info.unit_weight||l_weight_vol_info.unit_volume,'SUBMIT_DELIVERY_LINE');
      END IF;

      IF (l_weight_vol_info.wv_frozen_flag='N' AND (l_weight_vol_info.unit_weight IS NOT NULL OR l_weight_vol_info.unit_volume IS NOT NULL))  THEN

      IF l_weight_vol_info.unit_weight IS NOT NULL THEN
       l_detail_attributes(1).gross_weight := p_quantity*l_weight_vol_info.unit_weight;
       l_detail_attributes(1).net_weight   := p_quantity*l_weight_vol_info.unit_weight;
      END IF;

      IF l_weight_vol_info.unit_volume IS NOT NULL  THEN
             l_detail_attributes(1).volume       := p_quantity*l_weight_vol_info.unit_volume;
      END IF;

       IF (l_debug=1) THEN
          debug('The Gross weight calcuated is '||l_detail_attributes(1).gross_weight,'SUBMIT_DELIVERY_LINE');
          debug('The Net weight calcuated is '||l_detail_attributes(1).net_weight,'SUBMIT_DELIVERY_LINE');
          debug('The Volume calcuated is '||l_detail_attributes(1).volume,'SUBMIT_DELIVERY_LINE');
       END IF;
      END IF;
   END IF;

   IF p_sec_quantity IS NOT NULL THEN
      IF l_debug = 1 THEN
	 debug('updating Secondary Quantity: ' || p_sec_quantity,'SUBMIT_DELIVERY_LINE');
      END IF;
      if p_sec_quantity > 0 then /* Bug 5466481 */
        l_detail_attributes(1).shipped_quantity2 := p_sec_quantity;
      end if;
   END IF;

   IF p_trackingNumber IS NOT NULL THEN
      IF l_debug = 1 THEN
	 debug('updating tracking number to: ' || p_trackingNumber,'SUBMIT_DELIVERY_LINE');
      END IF;
      l_detail_attributes(1).tracking_number := p_trackingNumber;
   END IF;

   l_detail_attributes(1).delivery_detail_id := p_delivery_line_id;

   IF l_debug = 1 THEN
      debug('About to call wsh_delivery_details_pub.update_shipping_attributes',
	    'SUBMIT_DELIVERY_LINE');
   END IF;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_TRUE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF l_debug = 1 THEN
      debug('return stat: ' || x_return_status,'SUBMIT_DELIVERY_LINE');
   END IF;

   IF x_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
	 debug('wsh_delivery_details_pub.update_shipping_attributes failed'
	       || ' with status: ' || x_return_status, 'SUBMIT_DELIVERY_LINE');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);

      IF l_debug = 1 THEN
	 debug('x_summary: ' || x_msg_data,'SUBMIT_DELIVERY_LINE');
	 debug('x_details: ' || l_details, 'SUBMIT_DELIVERY_LINE');
      END IF;
   when no_data_found then
      -- do nothing for now
      null;
END SUBMIT_DELIVERY_LINE;

FUNCTION GET_LINE_TRANSACTION_TYPE(
				   p_order_line_id   IN NUMBER,
				   x_trx_source_type_id   OUT NOCOPY NUMBER,
				   x_trx_Action_id        OUT NOCOPY NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2 )
  return NUMBER IS

     CURSOR c_order_line_info(c_order_line_id number) is
	SELECT source_document_type_id, source_document_id, source_document_line_id
	  from   oe_order_lines_all
	  where  line_id = c_order_line_id;

     l_order_line_info c_order_line_info%ROWTYPE;

     CURSOR c_po_info(c_po_line_id NUMBER, c_order_line_id NUMBER) is
	SELECT  destination_type_code,
	  destination_subinventory,
	  source_organization_id,
	  destination_organization_id,
	  deliver_to_location_id,
	  pl.requisition_line_id
	  from    po_requisition_lines_all pl,
	  oe_order_lines_all ol
	  where   ol.source_document_type_id = 10
	  AND     ol.line_id = c_order_line_id
	  and     pl.requisition_line_id = c_po_line_id
	  and     pl.requisition_line_id = ol.source_document_line_id
	  and     pl.requisition_header_id = ol.source_document_id;

     l_po_info c_po_info%ROWTYPE;

     l_source_line_id        NUMBER;
     l_trx_type_code         NUMBER;
     l_trx_src_type		NUMBER;
     l_trx_act_id		NUMBER;
     l_intransit_type        NUMBER;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := 'C';
   l_trx_type_code := -1;

   OPEN c_order_line_info(p_order_line_id);
   FETCH c_order_line_info into l_order_line_info;
   if (c_order_line_info%NOTFOUND) THEN
      CLOSE c_order_line_info;
      x_return_status := 'E';
      return -1;
   END if;
   CLOSE c_order_line_info;

         if (l_order_line_info.source_document_type_id = 10) THEN /* internal order */
	    /* only for internal purchase orders, we need to fetch the po info */
	    OPEN c_po_info(l_order_line_info.source_document_line_id,p_order_line_id);
	    FETCH c_po_info into l_po_info;
	    if c_po_info%NOTFOUND then
	       CLOSE c_po_info;
	       x_return_status :=  'E';
	       return -1;
	    end if;
	    CLOSE c_po_info;

	    if (l_po_info.destination_type_code = 'EXPENSE') THEN
	       l_trx_type_code := 34;   /* Store Issue   */
             elsif (l_po_info.destination_type_code = 'INVENTORY') THEN
	       if (l_po_info.source_organization_id = l_po_info.destination_organization_id) then
		  l_trx_type_code := 50 /* Subinv_xfer */;
		else
                     BEGIN
			SELECT intransit_type
			  INTO l_intransit_type
			  FROM mtl_interorg_parameters
			  WHERE from_organization_id = l_po_info.source_organization_id
			  and to_organization_id = l_po_info.destination_organization_id;

			if (l_intransit_type =1) then
			   l_trx_type_code := 54 /* Direct shipment */;
			 else
			   l_trx_type_code := 62 /* intransit_shpmnt */;
			end if;
                     EXCEPTION WHEN NO_DATA_FOUND THEN
			l_trx_type_code := 62;
                     END;
	       end if;
	    end if;
	  else /* not internal order */
	       l_trx_type_code := 33;
         END if;

         if l_trx_type_code = -1 then
	    x_trx_source_type_id := -1;
	    x_trx_action_id := -1;
	    return -1;
         end if;        -- if there is no any type matching, don't need to
	 -- check status

	 select TRANSACTION_ACTION_ID, TRANSACTION_SOURCE_TYPE_ID
	   into l_trx_act_id, l_trx_src_type
	   from mtl_transaction_Types
	   where transaction_type_id = l_trx_type_code;

	 x_trx_source_type_id := l_trx_src_type;
	 x_trx_action_id      := l_trx_act_id;
         return l_trx_type_code;

EXCEPTION
   when no_data_found then
      x_return_status := 'E';
      x_trx_source_type_id := -1;
      x_trx_action_id := -1;
      return -1;
END GET_LINE_TRANSACTION_TYPE;

FUNCTION GET_DELIVERY_TRANSACTION_TYPE(
				       p_delivery_detail_id   IN NUMBER,
				       x_trx_source_type_id   OUT NOCOPY NUMBER,
				       x_trx_Action_id        OUT NOCOPY NUMBER,
				       x_return_status OUT NOCOPY VARCHAR2 )
  return NUMBER IS

     l_source_line_id number;

BEGIN

   SELECT source_line_id
     INTO l_source_line_id
     FROM wsh_delivery_details_ob_grp_v
     WHERE delivery_detail_id = p_delivery_detail_id;

   RETURN GET_LINE_TRANSACTION_TYPE(l_source_line_id,x_trx_source_type_id,
				    x_trx_action_id,x_return_status);

EXCEPTION
   when no_data_found then
      x_return_status := 'E';
      x_trx_source_type_id := -1;
      x_trx_action_id := -1;
      return -1;

END GET_DELIVERY_TRANSACTION_TYPE;

PROCEDURE CHECK_DELIVERY_STATUS(
				p_delivery_id 	IN NUMBER,
				x_return_Status     OUT NOCOPY VARCHAR2,
				x_error_msg 	OUT NOCOPY VARCHAR2)
  IS

     CURSOR c_delivery_details is
	SELECT dd.*
	  from wsh_delivery_details_ob_grp_v dd,
	  wsh_delivery_assignments_v da
	  where
          da.delivery_id = p_delivery_id
	  and da.delivery_detail_id = dd.delivery_detail_id
	  and dd.lpn_id is null;
	  l_detail_rec c_delivery_details%ROWTYPE;

	  l_org_id         NUMBER;
	  l_trx_type_code  NUMBER;
	  l_status_enabled NUMBER;
	  l_trx_src_type_id NUMBER;
	  l_trx_act_id     NUMBER;
	  l_status_applicable     VARCHAR2(1);

	  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   FOR l_detail_rec IN c_delivery_details LOOP
      l_trx_type_code := GET_DELIVERY_TRANSACTION_TYPE(l_detail_rec.delivery_detail_id,
						       l_trx_src_type_id,
						       l_trx_act_id,
						       x_return_Status);
      --inv_debug.message('jali','Transaction Type'||to_char(l_trx_type_code));
      if (l_trx_type_code = -1) then
	 x_error_msg := 'Cannot find the transaction type for delivery line:'
	   ||to_char(l_detail_rec.delivery_detail_id);
	 x_return_status := 'C';
	 return;
      end if;

      select status_control_flag
	into l_status_enabled
	from mtl_transaction_types
	where transaction_type_id = l_trx_type_code;

      l_org_id := l_detail_rec.organization_id;

      if (l_status_enabled = 1) then
	 -- check subinventory
                if (l_detail_rec.subinventory is not NULL) then
		   l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(
										       p_wms_installed		=> 'TRUE'
										       , p_trx_status_enabled  => l_status_enabled
										       , p_trx_type_id		=> l_trx_type_code
										       , p_organization_id     => l_org_id
										       , p_sub_code      	=> l_detail_rec.subinventory
										       , p_object_type		=> 'Z' );
		   if (l_status_applicable = 'N') then
		      x_error_msg := 'Subinventory '||l_detail_rec.subinventory||
			' does not allow Ship Confirm';
		      x_return_status := 'E';
		      return;
		   end if;
                end if;
                -- check locator
                if (l_detail_rec.locator_id is not NULL) then
		   l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(
										       p_wms_installed         => 'TRUE'
										       , p_trx_status_enabled  => l_status_enabled
										       , p_trx_type_id         => l_trx_type_code
										       , p_organization_id     => l_org_id
										       , p_locator_id          => l_detail_rec.locator_id
										       , p_object_type         => 'L' );
		   if (l_status_applicable = 'N') then
		      x_error_msg := 'Staging Lane '||' does not allow Ship Confirm';
		      x_return_status := 'E';
		      return ;
		   end if;
                end if;
                -- check lot
                if (l_detail_rec.lot_number is not NULL) then
		   l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(
										       p_wms_installed         => 'TRUE'
										       , p_trx_status_enabled  => l_status_enabled
										       , p_trx_type_id         => l_trx_type_code
										       , p_organization_id     => l_org_id
										       , p_inventory_item_id   => l_detail_rec.inventory_item_id
										       , p_lot_number		=> l_detail_rec.lot_number
										       , p_object_type         => 'O' );
		   if (l_status_applicable = 'N') then
		      x_error_msg := 'Lot '||l_detail_rec.lot_number||
			' does not allow Ship Confirm';
		      x_return_status := 'E';
		      return;
		   end if;
                end if;
                -- check serial
                if (l_detail_rec.serial_number is not NULL) then
		   l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(
										       p_wms_installed         => 'TRUE'
										       , p_trx_status_enabled  => l_status_enabled
										       , p_trx_type_id         => l_trx_type_code
										       , p_organization_id     => l_org_id
										       , p_inventory_item_id   => l_detail_rec.inventory_item_id
										       , p_serial_number       => l_detail_rec.serial_number
										       , p_object_type         => 'S' );
		   if (l_status_applicable = 'N') then
		      x_error_msg := 'Serial '||l_detail_rec.serial_number||
			' does not allow Ship Confirm';
		      x_return_status := 'E';
		      return;
		   end if;
                end if;
      end if;
   end LOOP;
   x_return_status := 'C';
   return;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'C';
      return;
END CHECK_DELIVERY_STATUS;

PROCEDURE CHECK_SHIP_SET(
			 p_delivery_id IN NUMBER,
			 x_ship_set      OUT NOCOPY VARCHAR2,
			 x_return_Status OUT NOCOPY VARCHAR2,
			 x_error_msg     OUT NOCOPY VARCHAR2)
  IS
     l_ship_set VARCHAR2(2000) := NULL;
     l_ship_set_id   NUMBER;
     l_ship_set_name VARCHAR2(30);
     unshipped_count NUMBER;

     CURSOR specified_ship_set  IS
	SELECT wdd.ship_set_id
	  FROM wsh_delivery_details_ob_grp_v wdd,
	  wsh_delivery_assignments_v  wda
	  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
	  AND EXISTS (SELECT 'x'
		      FROM wsh_delivery_details_ob_grp_v  wdd2
		      WHERE wdd2.delivery_detail_id = wdd.delivery_detail_id
		      AND wdd2.ship_set_id      is not null
		      AND wdd2.shipped_quantity is not null)
			AND wda.delivery_id        = p_delivery_id;

BEGIN
   x_return_status := 'C';
   OPEN  specified_ship_set;
   loop
      FETCH specified_ship_set INTO l_ship_set_id;
      EXIT WHEN specified_ship_set%NOTFOUND;
      SELECT count(*)
	INTO unshipped_count
	FROM wsh_delivery_details_ob_grp_v wdd,
	wsh_delivery_assignments_v wda,
	wsh_new_deliveries_ob_grp_v wnd
	WHERE wdd.delivery_detail_id = wda.delivery_detail_id
	AND   wda.delivery_id = wnd.delivery_id
	AND   wnd.delivery_id = p_delivery_id
	AND   wdd.ship_set_id = l_ship_set_id
	AND   wdd.shipped_quantity is null;
	if (unshipped_count >0 ) then
	   select set_name
	     into l_ship_set_name
	     from oe_sets
	     where set_id = l_ship_set_id;
	   if (l_ship_set is null) then
	      l_ship_set := l_ship_set_name;
	    else l_ship_set := l_ship_set ||', '||l_ship_set_name;
	   end if;
	end if;
   end loop;
   close specified_ship_set;
   if l_ship_set is null then
      x_return_status := 'C';
    else
      x_return_status := 'E';
      x_ship_set := l_ship_set;
   end if;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END CHECK_SHIP_SET;

PROCEDURE CHECK_COMPLETE_DELVIERY(
				  p_delivery_id IN NUMBER,
				  x_return_Status OUT NOCOPY VARCHAR2,
				  x_error_msg     OUT NOCOPY VARCHAR2) IS
    exist_unspecified  NUMBER;
BEGIN
   x_return_Status := 'C';
   select 1
     into exist_unspecified
     from dual
     where exists (select 1
		   from wsh_delivery_details_ob_grp_v wdd,
		   wsh_delivery_assignments_v wda
		   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
		   AND  wdd.shipped_quantity is null
                   AND  wdd.container_flag = 'N'
		   AND  wda.delivery_id = p_delivery_id
		   );
		   if exist_unspecified = 1 then x_return_Status := 'E'; end if;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_Status := 'C';
   WHEN OTHERS THEN
      x_return_Status := 'U';
END CHECK_COMPLETE_DELVIERY;

PROCEDURE UNASSIGN_DELIVERY_LINES(
				  p_delivery_id IN NUMBER,
				  x_return_Status OUT NOCOPY VARCHAR2,
				  x_error_msg     OUT NOCOPY VARCHAR2) IS
   l_return_status          VARCHAR2(1);

   CURSOR delivery_details IS
      select wdd.delivery_detail_id
	from wsh_delivery_details_ob_grp_v wdd,
	wsh_delivery_assignments_v wda,
	wsh_new_deliveries_ob_grp_v wnd
	where wdd.delivery_detail_id = wda.delivery_detail_id
	AND   wda.delivery_id = wnd.delivery_id
	AND   wnd.delivery_id = p_delivery_id
	AND   wdd.shipped_quantity is null
        AND   wdd.container_flag = 'N';  --Bug 5971499

   l_delivery_detail_id delivery_details%ROWTYPE;
BEGIN
   for l_delivery_detail_id in delivery_details
     loop
	WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Delivery(
								   l_delivery_detail_id.delivery_detail_id,
								   l_return_status);
	exit when l_return_status<>FND_API.G_RET_STS_SUCCESS;
     end loop;
     x_return_Status := l_return_status;
END UNASSIGN_DELIVERY_LINES;

PROCEDURE CHECK_ENTIRE_EZ_DELIVERY(
				   p_delivery_id IN NUMBER,
				   x_return_Status OUT NOCOPY VARCHAR2,
				   x_error_msg     OUT NOCOPY VARCHAR2) IS
				      exist_unqualified  NUMBER := 0;
BEGIN
   x_return_Status := 'Y';
   select 1
     into exist_unqualified
     from dual
     where exists (select 1
		   from wsh_delivery_details_ob_grp_v wdd,
		   wsh_delivery_assignments_v wda
		   WHERE wdd.delivery_detail_id = wda.delivery_detail_id
		   AND   wda.delivery_id = p_delivery_id
		   AND   wdd.container_flag='N'
		   AND   ( wdd.released_status not in ('X', 'Y')  OR  --'X' for nontransactable item
			   wdd.cycle_count_quantity > 0 OR
			   wdd.shipped_quantity < wdd.requested_quantity )
		   );
   if exist_unqualified = 1 then x_return_Status := 'N'; end if;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_Status := 'Y';
   WHEN OTHERS THEN
      x_return_Status := 'N';
END CHECK_ENTIRE_EZ_DELIVERY;

PROCEDURE CHECK_DELIVERY_LOADED(
				p_delivery_id IN NUMBER,
				x_return_Status OUT NOCOPY VARCHAR2) IS
    l_loaded VARCHAR2(1) := 'N';
BEGIN
   select 'Y'
     into l_loaded
     from dual
     where exists (select 1
		   from wms_shipping_transaction_temp
		   where delivery_id = p_delivery_id);
   x_return_Status := l_loaded;
EXCEPTION
   WHEN NO_DATA_FOUND then
      x_return_Status := 'N';
END CHECK_DELIVERY_LOADED;

/*bug13581767
 Check whether the Delivery (with the p_delivery_id) is the last delivery with status=Open on corresponding Trip.
 If any other delivery exists with status = OPEN in the trip ,then x_return_Status will be 'N'
 If no other open deliveries exist or the delivery is not assigned to any Trip, then x_return_Status will be 'Y'
 This procudure must be accordant with WSH_NEW_DELIVERY_ACTIONS.check_last_del_trip.
*/
PROCEDURE CHECK_LAST_DEL_TRIP(
			p_delivery_id IN NUMBER,
			x_return_Status OUT NOCOPY VARCHAR2) IS
	l_is_last VARCHAR2(1) := 'N';
	l_trip_id NUMBER;
	CURSOR Check_Last_Trip (l_delivery_id NUMBER) IS
		SELECT s1.trip_id
		FROM wsh_trip_stops s1,
			 wsh_delivery_legs dl1,
			 wsh_new_deliveries d1,
			 wsh_trip_stops s2,
			 wsh_delivery_legs dl2
		WHERE d1.delivery_id <> l_delivery_id
		 AND s1.stop_id = dl1.pick_up_stop_id
		 AND d1.delivery_id = dl1.delivery_id
		 AND d1.status_code = 'OP'
		 AND d1.delivery_type = 'STANDARD'
		 AND s2.trip_id = s1.trip_id
		 AND s2.stop_id = dl2.pick_up_stop_id
		 AND dl2.delivery_id = l_delivery_id
		 AND rownum = 1;
BEGIN

	OPEN check_last_trip(p_delivery_id);

	FETCH check_last_trip
	   INTO l_trip_id;
	CLOSE check_last_trip;

	IF 	l_trip_id IS NOT NULL THEN
		debug('The delivery-'||p_delivery_id||' is not the last delivery on Trip-'||l_trip_id, 'CHECK_LAST_DEL_TRIP');
		l_is_last := 'N';
	ELSE
		debug('The delivery-'||p_delivery_id||' is the last Open delivery', 'CHECK_LAST_DEL_TRIP');
		l_is_last := 'Y';
	END IF;
	x_return_Status := l_is_last;
EXCEPTION
 WHEN OTHERS THEN
	debug('EXCEPTION:OTHERS.', 'CHECK_LAST_DEL_TRIP');
	x_return_Status := 'N';

END CHECK_LAST_DEL_TRIP;
--end bug13581767
PROCEDURE CHECK_EZ_SHIP_DELIVERY(p_delivery_id IN NUMBER,
				 x_item_name     OUT NOCOPY VARCHAR2,
				 x_return_Status OUT NOCOPY VARCHAR2,
				 x_error_code    OUT NOCOPY NUMBER,
				 x_error_msg     OUT NOCOPY VARCHAR2) IS

   l_return_status    VARCHAR2(1);
   l_result           NUMBER;
   l_item_name        VARCHAR2(2000);
   l_organization_id  NUMBER;
   l_allow_shipping   VARCHAR2(1);

   l_msg_count        NUMBER;

   l_wms_org_flag     BOOLEAN;
   l_action_prms      wsh_interface_ext_grp.del_action_parameters_rectype;
   l_delivery_id_tab  wsh_util_core.id_tab_type;
   l_delivery_out_rec wsh_interface_ext_grp.del_action_out_rec_type;

    --Added for Bug 14696492
 CURSOR get_dlvy_trip(p_delivery_id NUMBER) IS
 SELECT wts.trip_id, wt.name
 FROM wsh_trip_stops wts, wsh_trips wt, wsh_delivery_legs wdl
 WHERE wdl.delivery_id = p_delivery_id
 AND wdl.pick_up_stop_id = wts.stop_id
 AND wts.trip_id = wt.trip_id;
 l_mul_del_trip VARCHAR2(1) := 'N';
 l_trip_id NUMBER;
 l_trip_name VARCHAR2(30);
 l_del_leg_count    NUMBER := 0;
 -- End for Bug 14696492

BEGIN
   x_return_Status := 'Y';
   x_error_code := 0;  -- everything is fine
   -- Locked the record first, so that others will not able to ship the same delivery
   BEGIN
      select organization_id
	into l_organization_id
	from wsh_new_deliveries_ob_grp_v
	where delivery_id = p_delivery_id
	for update NOWAIT;
   EXCEPTION WHEN others THEN
      x_return_Status := 'N';
      x_error_code := 5;
      return;
   END;

    -- Fix for Bug 14696492
   -- Check if delivery is assigned to trip which has additional deliveries
   BEGIN
    SELECT count(*) INTO l_del_leg_count
     FROM wsh_delivery_legs
     WHERE delivery_id = p_delivery_id;
	 IF l_del_leg_count > 1 THEN
	  x_return_Status := 'N';
      x_error_code := 8;
      return;
     ELSIF l_del_leg_count = 1 THEN
      OPEN get_dlvy_trip(p_delivery_id);
      FETCH get_dlvy_trip INTO l_trip_id, l_trip_name;
      CLOSE get_dlvy_trip;

	BEGIN
   SELECT 'Y'
   INTO l_mul_del_trip
   FROM wsh_trip_stops wts, wsh_delivery_legs wdl
   WHERE wts.trip_id = l_trip_id
   AND wdl.pick_up_stop_id = wts.stop_id
   AND wdl.delivery_id <> p_delivery_id;
  EXCEPTION
   WHEN NO_DATA_FOUND  THEN
    l_mul_del_trip := 'N';
   WHEN TOO_MANY_ROWS THEN
    l_mul_del_trip := 'Y';
   END;
   IF l_mul_del_trip = 'Y' THEN
    x_return_Status := 'N';
      x_error_code := 7;
      return;
	  END IF;
	 END IF;
   END;
   -- End of fix for Bug 14696492

   -- First check if the entire delivery is ready to be ship confirmed
   CHECK_ENTIRE_EZ_DELIVERY(
			    p_delivery_id,
			    x_return_Status,
			    x_error_msg);
   if x_return_Status = 'N' then
      x_return_Status := 'N';
      x_error_code := 1; -- not entire delivery is ready
      return;
   end if;
   -- check if this delivery is loaded to any dock and delivery status
   if (inv_install.adv_inv_installed(p_organization_id=>null) = TRUE ) then
      CHECK_DELIVERY_LOADED(p_delivery_id => p_delivery_id,
			    x_return_Status => l_return_status);
      if l_return_status = 'Y' then
	 x_return_Status := 'N';
	 x_error_code := 4;
      end if;

      CHECK_DELIVERY_STATUS(p_delivery_id => p_delivery_id,
			    x_return_Status => l_return_status,
			    x_error_msg => x_error_msg );
      if l_return_status = 'E' then
	 x_return_Status := 'N';
	 x_error_code := 2; -- status doesn't allow ship confirm
	 return;
      end if;
   end if;

   -- check serial control at sales issue
   SERIAL_AT_SALES_CHECK(x_result => l_result,
			 x_item_name => l_item_name,
			 p_delivery_id => p_delivery_id );
   if (l_result = 1) then
      x_return_Status := 'N';
      x_error_code := 3; -- serial control at issue
      x_item_name := l_item_name;
      return;
   end if;

   -- Check if the LPN which this delivery is contained in has material for
   -- other deliveries
   wms_mdc_pvt.can_ship_delivery(p_delivery_id    => p_delivery_id,
                                 x_allow_shipping => l_allow_shipping,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => l_msg_count,
                                 x_msg_data       => x_error_msg);

   IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_allow_shipping <> 'Y' THEN
      x_error_code := 6; -- Delivery is a part of consol delivery
      x_return_Status := 'N';
      RETURN;
   END IF;

   --- <Changes for Delivery Merge>
   l_wms_org_flag := wms_install.check_install(x_return_status   => x_return_status,
					       x_msg_count       => l_msg_count,
					       x_msg_data        => x_error_msg,
					       p_organization_id => l_organization_id);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (NOT l_wms_org_flag AND g_inv_current_release_level >= g_j_release_level)
     OR (l_wms_org_flag AND g_wms_current_release_level >= g_j_release_level) THEN
      l_action_prms.caller := 'WMS_DLMG';
      l_action_prms.event := wsh_interface_ext_grp.g_start_of_shipping;
      l_action_prms.action_code := 'ADJUST-PLANNED-FLAG';

      l_delivery_id_tab(1) := p_delivery_id;

      wsh_interface_ext_grp.Delivery_Action
	(p_api_version_number     => 1.0,
	 p_init_msg_list          => fnd_api.g_false,
	 p_commit                 => fnd_api.g_false,
	 p_action_prms            => l_action_prms,
	 p_delivery_id_tab        => l_delivery_id_tab,
	 x_delivery_out_rec       => l_delivery_out_rec,
	 x_return_status          => l_return_status,
	 x_msg_count              => l_msg_count,
	 x_msg_data               => x_error_msg);
      -- We do not error out even if the API returns failure
   END IF;
   -- </Changes for delivery merge>

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_Status := 'Y';
   WHEN OTHERS THEN
      x_return_Status := 'N';
END CHECK_EZ_SHIP_DELIVERY;



PROCEDURE CONFIRM_DELIVERY (
			    p_ship_delivery     IN  VARCHAR2  DEFAULT NULL,
			    p_delivery_id       IN  NUMBER,
			    p_organization_id   IN  NUMBER,
			    p_delivery_name     IN  VARCHAR2,
			    p_carrier_id        IN  NUMBER,
			    p_ship_method_code  IN  VARCHAR2,
			    p_gross_weight      IN  NUMBER,
			    p_gross_weight_uom  IN  VARCHAR2,
			    p_bol               IN  VARCHAR2,
			    p_waybill           IN  VARCHAR2,
			    p_action_flag       IN  VARCHAR2,
			    x_return_status     OUT NOCOPY VARCHAR2,
			    x_ret_code          OUT NOCOPY NUMBER,
			    x_msg_data          OUT NOCOPY VARCHAR2,
			    x_msg_count         OUT NOCOPY NUMBER) IS

   l_ship_set   VARCHAR2(2000) := NULL;
   l_error_msg  VARCHAR2(2000) := NULL;

   unspec_ship_set_exists  EXCEPTION;
   incomplete_delivery     EXCEPTION;

   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_ret_code := 0;
   fnd_msg_pub.initialize;

   IF l_debug=1 THEN
      debug('INV_SHIPPING_TRANSACTION_PUB.CONFIRM_DELIVERY..delivery_id: ' || p_delivery_id, 'confirm_delivery');
   END IF;

   IF p_ship_delivery = 'YES' THEN
      INV_SHIPPING_TRANSACTION_PUB.CHECK_SHIP_SET(
						  p_delivery_id    => p_delivery_id,
						  x_ship_set       => l_ship_set,
						  x_return_Status  => x_return_status,
						  x_error_msg      => l_error_msg);
      IF x_return_status = 'E' THEN
	 FND_MESSAGE.SET_NAME('INV', 'WMS_WSH_SHIPSET_FORCED');
	 FND_MESSAGE.SET_TOKEN('SHIP_SET_NAME', l_ship_set);
	 FND_MSG_PUB.ADD;
	 RAISE unspec_ship_set_exists;
       ELSIF x_return_status = 'U' THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      INV_SHIPPING_TRANSACTION_PUB.CHECK_COMPLETE_DELVIERY(
							   p_delivery_id    => p_delivery_id,
							   x_return_Status  => x_return_status,
							   x_error_msg      => l_error_msg);
      IF x_return_status = 'E' THEN
	 FND_MESSAGE.SET_NAME('INV', 'WMS_INCOMPLETE_DELI');
	 FND_MSG_PUB.ADD;
	 IF l_debug = 1 THEN
	    debug('check_complete_delivery failed with status E','CONFIRM_DELIVERY');
	 END IF;
	 RAISE incomplete_delivery;
       ELSIF x_return_status = 'U' THEN
	 IF l_debug = 1 THEN
	    debug('check_complete_deliery failed with status U','CONFIRM_DELIVERY');
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM_ALL(
						    p_delivery_id       => p_delivery_id,
						    p_organization_id   => p_organization_id,
						    p_delivery_name     => p_delivery_name,
						    p_carrier_id        => p_carrier_id,
						    p_ship_method_code  => p_ship_method_code,
						    p_gross_weight      => p_gross_weight,
						    p_gross_weight_uom  => p_gross_weight_uom,
						    p_bol               => p_bol,
						    p_waybill           => p_waybill,
						    p_action_flag       => p_action_flag,
						    x_return_status     => x_return_status,
						    x_msg_data          => x_msg_data,
						    x_msg_count         => x_msg_count);

    ELSE
      WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM(
						p_delivery_id       => p_delivery_id,
						p_organization_id   => p_organization_id,
						p_delivery_name     => p_delivery_name,
						p_carrier_id        => p_carrier_id,
						p_ship_method_code  => p_ship_method_code,
						p_gross_weight      => p_gross_weight,
						p_gross_weight_uom  => p_gross_weight_uom,
						p_bol               => p_bol,
						p_waybill           => p_waybill,
						p_action_flag       => p_action_flag,
						x_return_status     => x_return_status,
						x_msg_data          => x_msg_data,
						x_msg_count         => x_msg_count);
   END IF;

   IF x_return_status not in ('S','W') THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN unspec_ship_set_exists THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_ret_code := 1;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count => x_msg_count
	   , p_data  => x_msg_data
	   );

   WHEN incomplete_delivery THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_ret_code := 2;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count => x_msg_count
	   , p_data  => x_msg_data
	   );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END CONFIRM_DELIVERY;


PROCEDURE UNASSIGN_LINES_AND_CONFIRM (
				      p_delivery_id       IN  NUMBER,
				      p_organization_id   IN  NUMBER,
				      p_delivery_name     IN  VARCHAR2,
				      p_carrier_id        IN  NUMBER,
				      p_ship_method_code  IN  VARCHAR2,
				      p_gross_weight      IN  NUMBER,
				      p_gross_weight_uom  IN  VARCHAR2,
				      p_bol               IN  VARCHAR2,
				      p_waybill           IN  VARCHAR2,
				      p_action_flag       IN  VARCHAR2,
				      x_return_status     OUT NOCOPY VARCHAR2,
				      x_msg_data          OUT NOCOPY VARCHAR2,
				      x_msg_count         OUT NOCOPY NUMBER) IS
   l_error_msg  VARCHAR2(2000) := NULL;
   unassign_lines_exc   EXCEPTION;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   fnd_msg_pub.initialize;

   INV_SHIPPING_TRANSACTION_PUB.UNASSIGN_DELIVERY_LINES(
							p_delivery_id    => p_delivery_id,
							x_return_Status  => x_return_status,
							x_error_msg      => l_error_msg);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE unassign_lines_exc;
        END IF;

        WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM_ALL(
						      p_delivery_id       => p_delivery_id,
						      p_organization_id   => p_organization_id,
						      p_delivery_name     => p_delivery_name,
						      p_carrier_id        => p_carrier_id,
						      p_ship_method_code  => p_ship_method_code,
						      p_gross_weight      => p_gross_weight,
						      p_gross_weight_uom  => p_gross_weight_uom,
						      p_bol               => p_bol,
						      p_waybill           => p_waybill,
						      p_action_flag       => p_action_flag,
						      x_return_status     => x_return_status,
						      x_msg_data          => x_msg_data,
						      x_msg_count         => x_msg_count);

        IF l_debug = 1 THEN
	    debug('Return status after SHIP_CONFIRM_ALL :' || x_return_status ,'UNASSIGN_LINES_AND_CONFIRM ');
	 END IF;

	IF x_return_status not in ('S','W') THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;

EXCEPTION
   WHEN unassign_lines_exc THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count => x_msg_count
	   , p_data  => x_msg_data
	   );

END UNASSIGN_LINES_AND_CONFIRM;

PROCEDURE INV_SPLIT_DELIVERY_LINE(
				  p_delivery_detail_id            IN NUMBER,
				  p_ship_quantity                 IN NUMBER,
				  p_requested_quantity            IN NUMBER,
				  x_return_status                 OUT NOCOPY VARCHAR2,
				  x_msg_count                     OUT NOCOPY NUMBER,
				  x_msg_data                      OUT NOCOPY VARCHAR2,
				  x_new_delivery_detail_id        OUT NOCOPY NUMBER,
				  x_new_transaction_temp_id       OUT NOCOPY NUMBER)
  IS
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);

     l_new_transaction_temp_id NUMBER;
     l_delivery_detail_id NUMBER := p_delivery_detail_id;
     l_shipped_quantity NUMBER := p_ship_quantity;
     l_requested_quantity NUMBER := p_requested_quantity;
     l_new_delivery_line_id NUMBER;
     l_transaction_temp_id NUMBER;
     l_delivery_id NUMBER;
     l_delay_quantity NUMBER;


     l_detail_attributes wsh_interface.ChangedAttributeTabType;
     l_InvPCInRecType    wsh_integration.InvPCInRecType;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF l_debug = 1 THEN
      debug('Entered procedure','INV_SPLIT_DELIVERY_LINE');
      debug('p_delivery_detail_id: ' || p_delivery_detail_id,'INV_SPLIT_DELIVERY_LINE');
      debug('p_ship_quantity: ' || p_ship_quantity,'INV_SPLIT_DELIVERY_LINE');
      debug('p_requested_quantity: ' || p_requested_quantity,'INV_SPLIT_DELIVERY_LINE');
   END IF;

   --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
   l_InvPCInRecType.transaction_id := NULL;
   l_InvPCInRecType.transaction_temp_id := NULL;
   l_InvPCInRecType.source_code :='INV';
   l_InvPCInRecType.api_version_number :=1.0;

   l_return_status := 'S';

   select transaction_temp_id
     into l_transaction_temp_id
     From wsh_delivery_details_ob_grp_v
     where delivery_detail_id = l_delivery_detail_id;

   l_delay_quantity := l_requested_quantity - l_shipped_quantity;

   WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details
     (p_from_detail_id => l_delivery_detail_id,
	  p_req_quantity => l_delay_quantity,
      x_new_detail_id => l_new_delivery_line_id,
      x_return_status => l_return_status
      );
   if l_return_status <> fnd_api.g_ret_sts_success THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   select transaction_temp_id
     into l_new_transaction_temp_id
     from wsh_delivery_details_ob_grp_v
     where delivery_detail_id = l_new_delivery_line_id;

   IF (l_debug = 1) THEN
      debug('new transaction_temp_id is ' || l_new_transaction_temp_id,
	    'INV_SPLIT_DELIVERY_LINE');
      debug('old transaction_temp_id is ' ||
	    l_transaction_temp_id,'INV_SPLIT_DELIVERY_LINE');
   END IF;

   if( l_transaction_temp_id = l_new_transaction_temp_id) then
      select mtl_material_transactions_s.nextval
	into l_new_transaction_temp_id
	from dual;
      if( l_debug = 1 ) then
	 debug('new transaction_temp_id is ' || l_new_transaction_temp_id, 'split_Delivery');
      end if;
   end if;

   IF l_debug =1 THEN
      debug('Setting WDD attributes of new line with following:','INV_SPLIT_DELIVERY_LINE');
      debug('delivery_detail_id ' || l_new_delivery_line_id,'INV_SPLIT_DELIVERY_LINE');
      debug('transaction_temp_id ' || l_new_transaction_temp_id,'INV_SPLIT_DELIVERY_LINE');
      debug('shipped_quantity 0','INV_SPLIT_DELIVERY_LINE');
   END IF;

   l_InvPCInRecType.transaction_temp_id := l_new_transaction_temp_id;

   wsh_integration.Set_Inv_PC_Attributes
     (p_in_attributes => l_InvPCInRecType,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
      IF l_debug = 1 THEN
	 debug('wsh_integration.set_inv_pc_attributes failed'
	       || ' with status: ' || l_return_status,'INV_SPLIT_DELIVERY_LINE');
      END IF;
      --check where to handle this error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_detail_attributes(1).shipped_quantity := 0;
   l_detail_attributes(1).delivery_detail_id := l_new_delivery_line_id;
   l_detail_attributes(1).action_flag      := 'U';

   wsh_interface.update_shipping_attributes
     (x_return_status      => l_return_status,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'INV');

   IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
      IF l_debug = 1 THEN
	 debug('wsh_interface.update_shipping_attributes failed'
	       || ' with status: ' || l_return_status,'INV_SPLIT_DELIVERY_LINE');
      END IF;
      --check where to handle this error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_new_delivery_detail_id := l_new_delivery_line_id;
   x_new_transaction_temp_id := l_new_transaction_temp_id;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END INV_SPLIT_DELIVERY_LINE;


 /**
  Bug no 3952081
  Overriding the procedure INV_SPLIT_DELIVERY_LINE to include
  DUOM attributes as input arguments
 **/
PROCEDURE INV_SPLIT_DELIVERY_LINE(
				  p_delivery_detail_id            IN NUMBER,
				  p_ship_quantity                 IN NUMBER,
				  p_requested_quantity            IN NUMBER,
                                  p_sec_ship_quantity             IN NUMBER,
                                  p_sec_requested_quantity        IN NUMBER,
				  x_return_status                 OUT NOCOPY VARCHAR2,
				  x_msg_count                     OUT NOCOPY NUMBER,
				  x_msg_data                      OUT NOCOPY VARCHAR2,
				  x_new_delivery_detail_id        OUT NOCOPY NUMBER,
				  x_new_transaction_temp_id       OUT NOCOPY NUMBER)
  IS
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);

     l_new_transaction_temp_id NUMBER;
     l_delivery_detail_id NUMBER := p_delivery_detail_id;
     l_shipped_quantity NUMBER := p_ship_quantity;
     l_requested_quantity NUMBER := p_requested_quantity;
     l_new_delivery_line_id NUMBER;
     l_transaction_temp_id NUMBER;
     l_delivery_id NUMBER;
     l_delay_quantity NUMBER;


     l_detail_attributes wsh_interface.ChangedAttributeTabType;
     l_InvPCInRecType    wsh_integration.InvPCInRecType;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     --Bug No 3952081
     --New field to hol sec delay qty
     l_sec_delay_quantity NUMBER;
BEGIN
   IF l_debug = 1 THEN
      debug('Entered procedure','INV_SPLIT_DELIVERY_LINE');
      debug('p_delivery_detail_id: ' || p_delivery_detail_id,'INV_SPLIT_DELIVERY_LINE');
      debug('p_ship_quantity: ' || p_ship_quantity,'INV_SPLIT_DELIVERY_LINE');
      debug('p_requested_quantity: ' || p_requested_quantity,'INV_SPLIT_DELIVERY_LINE');
   END IF;

   --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
   l_InvPCInRecType.transaction_id := NULL;
   l_InvPCInRecType.transaction_temp_id := NULL;
   l_InvPCInRecType.source_code :='INV';
   l_InvPCInRecType.api_version_number :=1.0;

   l_return_status := 'S';

   select transaction_temp_id
     into l_transaction_temp_id
     From wsh_delivery_details_ob_grp_v
     where delivery_detail_id = l_delivery_detail_id;

   l_delay_quantity := l_requested_quantity - l_shipped_quantity;

   /* Calculate the value for l_sec_delay_quantity */
   l_sec_delay_quantity := p_sec_requested_quantity - p_sec_ship_quantity;

   /* Changes in call to WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details */
   IF l_sec_delay_quantity IS NOT NULL THEN
      IF l_debug = 1 THEN
	 debug('Setting Secondary Delay Quantity: ' || l_sec_delay_quantity,'INV_SPLIT_DELIVERY_LINE');
      END IF;

   /* pass on the secondary delay quantity to WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details */

      WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details
         (p_from_detail_id => l_delivery_detail_id,
	  p_req_quantity => l_delay_quantity,
          p_req_quantity2 => l_sec_delay_quantity,
         x_new_detail_id => l_new_delivery_line_id,
         x_return_status => l_return_status
      );
   ELSE
      /* call WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details  without secondary delay quantity */
      WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details
         (p_from_detail_id => l_delivery_detail_id,
	  p_req_quantity => l_delay_quantity,
         x_new_detail_id => l_new_delivery_line_id,
         x_return_status => l_return_status
      );
   END IF;


   if l_return_status <> fnd_api.g_ret_sts_success THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   select transaction_temp_id
     into l_new_transaction_temp_id
     from wsh_delivery_details_ob_grp_v
     where delivery_detail_id = l_new_delivery_line_id;

   IF (l_debug = 1) THEN
      debug('new transaction_temp_id is ' || l_new_transaction_temp_id,
	    'INV_SPLIT_DELIVERY_LINE');
      debug('old transaction_temp_id is ' ||
	    l_transaction_temp_id,'INV_SPLIT_DELIVERY_LINE');
   END IF;

   if( l_transaction_temp_id = l_new_transaction_temp_id) then
      select mtl_material_transactions_s.nextval
	into l_new_transaction_temp_id
	from dual;
      if( l_debug = 1 ) then
	 debug('new transaction_temp_id is ' || l_new_transaction_temp_id, 'split_Delivery');
      end if;
   end if;

   IF l_debug =1 THEN
      debug('Setting WDD attributes of new line with following:','INV_SPLIT_DELIVERY_LINE');
      debug('delivery_detail_id ' || l_new_delivery_line_id,'INV_SPLIT_DELIVERY_LINE');
      debug('transaction_temp_id ' || l_new_transaction_temp_id,'INV_SPLIT_DELIVERY_LINE');
      debug('shipped_quantity 0','INV_SPLIT_DELIVERY_LINE');
   END IF;

   l_InvPCInRecType.transaction_temp_id := l_new_transaction_temp_id;

   wsh_integration.Set_Inv_PC_Attributes
     (p_in_attributes => l_InvPCInRecType,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
      IF l_debug = 1 THEN
	 debug('wsh_integration.set_inv_pc_attributes failed'
	       || ' with status: ' || l_return_status,'INV_SPLIT_DELIVERY_LINE');
      END IF;
      --check where to handle this error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_detail_attributes(1).shipped_quantity := 0;
   l_detail_attributes(1).delivery_detail_id := l_new_delivery_line_id;
   l_detail_attributes(1).action_flag      := 'U';

   wsh_interface.update_shipping_attributes
     (x_return_status      => l_return_status,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'INV');

   IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
      IF l_debug = 1 THEN
	 debug('wsh_interface.update_shipping_attributes failed'
	       || ' with status: ' || l_return_status,'INV_SPLIT_DELIVERY_LINE');
      END IF;
      --check where to handle this error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_new_delivery_detail_id := l_new_delivery_line_id;
   x_new_transaction_temp_id := l_new_transaction_temp_id;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END INV_SPLIT_DELIVERY_LINE;

PROCEDURE INV_PROCESS_SERIALS(
			      p_transaction_temp_id   IN NUMBER,
			      p_delivery_detail_id    IN NUMBER,
			      x_return_status         OUT NOCOPY VARCHAR2,
			      x_msg_count             OUT NOCOPY NUMBER,
			      x_msg_data              OUT NOCOPY VARCHAR2)
  IS
     l_transaction_temp_id NUMBER := p_transaction_temp_id;
     l_delivery_detail_id NUMBER := p_delivery_detail_id;
     l_count NUMBER;
BEGIN
   select count(*)
     into l_count
     from mtl_serial_numbers_temp msnt, wsh_delivery_details_ob_grp_v wdd
     where msnt.transaction_temp_id = wdd.transaction_temp_id
     and wdd.delivery_detail_id = l_delivery_detail_id
     and wdd.transaction_temp_id = l_transaction_temp_id;

   if( l_count > 0 ) then
      delete from mtl_serial_numbers_temp
	where transaction_temp_id in (select transaction_temp_id
				      From wsh_delivery_details_ob_grp_v
				      where transaction_temp_id = l_transaction_temp_id
				      And delivery_detail_id = l_delivery_detail_id);
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
   when FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END INV_PROCESS_SERIALS;


PROCEDURE get_enforce_ship(p_org_id        IN  NUMBER,
			   x_enforce_ship  OUT NOCOPY VARCHAR2,
			   x_return_status OUT nocopy VARCHAR2,
			   x_msg_data      OUT nocopy VARCHAR,
			   x_msg_count     OUT nocopy NUMBER) IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_shipping_params WSH_SHIPPING_PARAMS_GRP.Global_Params_Rec;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Changed to call Shipping's API because they
   --moved a few columns from wsh_shipping_parameters
   --to a new table called wsh_global_parameters in patchset J.
   WSH_SHIPPING_PARAMS_GRP.get_global_parameters
     (x_global_param_info=>l_shipping_params,
      x_return_status => x_return_status);

   x_enforce_ship := l_shipping_params.ENFORCE_SHIP_METHOD;

   IF x_enforce_ship IS NULL THEN
      x_enforce_ship := 'N';
   END IF;

   IF (l_debug = 1) THEN
      debug('Shipping API returned status: ' || x_return_status,'get_enforce_ship');
      debug('Enforce ship Y/N : ' || x_enforce_ship, 'get_enforce_ship');
   END IF;
EXCEPTION
   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_enforce_ship := 'N';
END get_enforce_ship;

/** This procedure gets the enforce_ship_method parameter from shipping
 *       and Ship Method at trip level, if trip exists for this Delivery**/
PROCEDURE get_shipmethod_details
                               (p_org_id                IN  NUMBER,
				p_delivery_id           IN  NUMBER,
				p_enforce_shipmethod    IN  OUT NOCOPY VARCHAR2,
				p_trip_id               IN  OUT NOCOPY NUMBER,
				x_trip_shipmethod_code    OUT NOCOPY VARCHAR2,
				x_trip_shipmethod_meaning OUT NOCOPY VARCHAR2,
				x_return_status         OUT NOCOPY VARCHAR2,
				x_msg_data              OUT NOCOPY VARCHAR,
				x_msg_count             OUT NOCOPY NUMBER) IS
	l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     BEGIN
	IF (l_debug = 1) THEN
	    debug('inside get_shipmethod_details  ' , 'get_shipmethod_details');
	    debug('p_org_id : ' || p_org_id, 'get_shipmethod_details');
	    debug('p_delivery_id : ' || p_delivery_id, 'get_shipmethod_details');
	    debug('p_enforce_shipmethod : ' || p_enforce_shipmethod, 'get_shipmethod_details');
	    debug('p_trip_id : ' || p_trip_id, 'get_shipmethod_details');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_enforce_shipmethod is NULL THEN
	   SELECT enforce_ship_method
	     INTO p_enforce_shipmethod
	     FROM wsh_global_parameters	  ;  -- changed from wsh_shipping_parameters
	END IF;

        IF p_enforce_shipmethod IS NULL THEN p_enforce_shipmethod := 'N' ; END IF;

	IF (l_debug = 1) THEN
	    debug('Enforce ship Y/N : ' || p_enforce_shipmethod, 'get_shipmethod_details');
	END IF;

        BEGIN
           SELECT wt.ship_method_code,
                  wt.trip_id
           INTO   x_trip_shipmethod_code,
                  p_trip_id
           FROM   wsh_new_deliveries del,
                  wsh_delivery_legs dlg,
                  wsh_trip_stops st,
                  wsh_trips wt
           WHERE del.delivery_id = dlg.delivery_id
           AND dlg.pick_up_stop_id = st.stop_id
           AND del.initial_pickup_location_id = st.stop_location_id
           AND st.trip_id = wt.trip_id
           AND del.delivery_id = p_delivery_id
           AND rownum = 1;

           x_trip_shipmethod_meaning := GET_SHIPMETHOD_MEANING(x_trip_shipmethod_code);
           IF (l_debug = 1) THEN
              debug('x_tripshipmethod_code : ' || x_trip_shipmethod_code, 'get_shipmethod_details');
              debug('x_tripshipmethod_meaning : ' || x_trip_shipmethod_meaning, 'get_shipmethod_details');
              debug('p_trip_id : ' || p_trip_id, 'get_shipmethod_details');
           END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_trip_shipmethod_code := NULL;
          p_trip_id := NULL;
          IF (l_debug = 1) THEN
              debug('Trip Not found for this Delivery  ' , 'get_shipmethod_details');
              debug('x_trip_shipmethod_code : ' || x_trip_shipmethod_code, 'get_shipmethod_details');
              debug('p_trip_id : ' || p_trip_id, 'get_shipmethod_details');
          END IF;
        END ;

        IF (l_debug = 1) THEN
	   debug('Going ou  ' , 'get_shipmethod_details');
        END IF;
END  get_shipmethod_details;

-- Start of fix for 4629955
FUNCTION GET_FREIGHT_CODE(p_carrier_id  IN  NUMBER)
  RETURN  VARCHAR2 IS
     l_freight_code wsh_carriers.freight_code%TYPE;
BEGIN
   if p_carrier_id is null then
      return null;
   else
      select freight_code
      into l_freight_code
      from wsh_carriers
      where carrier_id=p_carrier_id;
   end if;
   return l_freight_code;
EXCEPTION
   WHEN OTHERS THEN
      return null;
END GET_FREIGHT_CODE;
-- End of fix for 4629955

/* The following API will get the secondary shipped qty
   by taking the lot specific conversion defined, if any, into account
   Return values and meanings :
   -1  - No conversion defined
   Any 0 or +ve value - The secondary qty
*/

FUNCTION is_lotspec_conv(p_delivery_detail_id IN NUMBER, x_lot_number OUT NOCOPY VARCHAR2) RETURN NUMBER IS
	l_lot_number	VARCHAR2(80) := null;
BEGIN

	SELECT lot_number INTO l_lot_number
	FROM wsh_delivery_details
	WHERE delivery_detail_id = p_delivery_detail_id
	AND lot_number IS NOT NULL;

	BEGIN
		/* If this returns values, that means no lot_specific conversion defined, so return 0*/
		SELECT wdd.lot_number INTO l_lot_number
		FROM mtl_lot_uom_class_conversions lsc
		  , mtl_uom_class_conversions uc
		  , wsh_delivery_details wdd
		WHERE lsc.inventory_item_id = uc.inventory_item_id
			AND uc.from_uom_code = lsc.from_uom_code
			AND uc.to_uom_code = lsc.to_uom_code
			AND uc.conversion_rate = lsc.conversion_rate
			AND wdd.organization_id = lsc.organization_id
			AND wdd.inventory_item_id = lsc.inventory_item_id
			AND wdd.lot_number = lsc.lot_number
			AND wdd.delivery_detail_id = p_delivery_detail_id
			AND wdd.lot_number IS NOT NULL;

		x_lot_number := l_lot_number;
		return 0;
	EXCEPTION
		WHEN no_data_found THEN
			x_lot_number := l_lot_number;
			return 1;
	END;
EXCEPTION

	WHEN no_data_found THEN /* This means No lot item, so return 0*/
		return 0;
	WHEN others THEN
		return 0;
END is_lotspec_conv;

END INV_SHIPPING_TRANSACTION_PUB;

/
