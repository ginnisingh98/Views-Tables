--------------------------------------------------------
--  DDL for Package Body WMS_DIRECT_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DIRECT_SHIP_PVT" AS
/* $Header: WMSDSPVB.pls 120.21.12010000.7 2010/04/29 17:11:10 pbonthu ship $ */

        -- standard global constants
        G_PKG_NAME CONSTANT VARCHAR2(30)                := 'WMS_DIRECT_SHIP_PVT';
        p_message_type  CONSTANT VARCHAR2(1)            := 'E';

--Inline branching
G_WMS_CURRENT_RELEASE_LEVEL NUMBER := wms_control.g_current_release_level;
G_J_RELEASE_LEVEL       NUMBER := inv_release.g_j_release_level;

FUNCTION GET_CATCH_WEIGHT
                        (P_ORG_ID IN NUMBER
                        ,P_LPN_ID IN NUMBER
                        ,P_INVENTORY_ITEM_ID IN NUMBER
                        ,P_REVISION IN VARCHAR2
                        ,P_LOT_NUMBER IN VARCHAR2
                        ,P_PICKED_QUANTITY_IN_PRI_UOM IN NUMBER
                        ) RETURN NUMBER;

/* types defined for Patchset I */

-- This record stores the data for one row in lpn_contents.
TYPE lpn_content_rec IS RECORD (lpn_id NUMBER,
                                subinventory_code VARCHAR2(30),
                                locator_id NUMBER,
                                inventory_item_id NUMBER,
                                revision_control BOOLEAN,
                                revision VARCHAR2(3),
                                lot_control BOOLEAN,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
                                lot_number VARCHAR2(80),
                                serial_control_code NUMBER,
                                serial_control BOOLEAN,
                                end_item_unit_number VARCHAR2(30),
                                quantity NUMBER
                                );

-- This table containes records of type lpn_content_rec. The table is
-- constructed from the output of cursor lpn_content_cur
TYPE lpn_contents_tab IS TABLE OF lpn_content_rec INDEX BY BINARY_INTEGER;

-- This record form the lpn_contents_lookup_tab.
-- Here start_index and end_index specify record locations in lpn_contents_tab.
TYPE lpn_contents_lookup_rec IS RECORD (start_index NUMBER, end_index NUMBER);

-- This table stores the lookup index values corresponding to a item in
-- lpn_contents_tab
TYPE lpn_contents_lookup_tab IS TABLE OF lpn_contents_lookup_rec INDEX BY BINARY_INTEGER;

-- This table will stores all the checked deliveries for the current LPN
TYPE checked_delivery_tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

-- for delivery grouping validations
TYPE del_grp_rls_flags IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE del_grp_rls_fld IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
-- table of checked deliveries
TYPE checked_deliveries IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE delivery_detail_rec IS RECORD(
    organization_id            NUMBER
  , dock_door_id               NUMBER
  , lpn_id                     NUMBER
  , order_header_id            NUMBER
  , order_line_id              NUMBER
  , line_item_id               NUMBER
  , transaction_temp_id        NUMBER
  , delivery_detail_id         NUMBER
  , requested_quantity         NUMBER
  , primary_uom_code           VARCHAR2(3)
  , lot_control_code           NUMBER
  , serial_number_control_code NUMBER
  , inventory_item_id          NUMBER
  , ont_pricing_qty_source     VARCHAR2(30)
  ); -- Added bug4128854

TYPE delivery_detail_tab IS TABLE OF delivery_detail_rec
    INDEX BY BINARY_INTEGER; --Added bug 4128854
/* global variables added for Patchset I */

g_lpn_contents_tab lpn_contents_tab;
g_lpn_contents_lookup_tab lpn_contents_lookup_tab;
g_total_lpn_quantity NUMBER;
g_checked_delivery_tab checked_delivery_tab;
g_project_id NUMBER;
g_task_id NUMBER;
g_cross_project_allowed VARCHAR2(1);
g_cross_unit_allowed VARCHAR2(1);
g_subinventory_code VARCHAR2(30);
g_locator_id NUMBER;
g_group_id NUMBER;
-- who columns
g_last_update_date DATE;
g_last_updated_by NUMBER;
g_last_update_login NUMBER;
g_created_by NUMBER;
g_creation_date DATE;
-- used for validating delivery grouping rules
g_del_grp_rls_flags del_grp_rls_flags;
g_del_grp_rls_fld_value del_grp_rls_fld;
g_del_grp_rls_fld_temp del_grp_rls_fld;
-- checked deliveries for lpn
g_checked_deliveries checked_deliveries;

G_RET_STS_SUCCESS      VARCHAR2(1) := FND_API.g_ret_sts_success;
G_RET_STS_ERROR        VARCHAR2(1) := FND_API.g_ret_sts_error;
G_RET_STS_UNEXP_ERROR  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_FALSE                VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE                 VARCHAR2(1) := FND_API.G_TRUE;
G_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

PROCEDURE DEBUG(p_message       IN VARCHAR2,
                p_module   IN VARCHAR2 ,
                p_level         IN VARCHAR2 DEFAULT 9) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

IF (l_debug = 1) THEN
   INV_TRX_UTIL_PUB.TRACE( P_MESG =>P_MESSAGE
                       ,P_MOD => p_module
                       ,p_level => p_level
                       );
END IF;
 --dbms_output.put_line(p_message);
END; -- DEBUG

PROCEDURE process_mobile_msg IS
   l_msg_data VARCHAR2(2000);
   l_msg_count NUMBER;
   l_dummy_number NUMBER;

   l_app_short_name VARCHAR2(20);
   l_msg_name       VARCHAR2(50);
BEGIN
   debug('Entered procedure','process_mobile_msg');

   l_msg_count := fnd_msg_pub.count_msg;
   debug('Msg Count: ' || l_msg_count,'process_mobile_msg');

   FOR i IN 1..l_msg_count LOOP
      fnd_msg_pub.get(p_msg_index => i,
              p_data => l_msg_data,
              p_msg_index_out => l_dummy_number);

      debug('i: ' || i || ' index_out: ' || l_dummy_number || ' encoded_data: ' || l_msg_data,'process_mobile_msg');

      fnd_message.parse_encoded(ENCODED_MESSAGE => l_msg_data,
                APP_SHORT_NAME  => l_app_short_name,
                MESSAGE_NAME    => l_msg_name);

      debug('App_short_name: ' || l_app_short_name || ' Msg_name: ' || l_msg_name,'process_mobile_msg');

      IF ((l_msg_name <> 'WSH_DET_INV_INT_SUBMITTED')) THEN
     fnd_msg_pub.delete_msg(p_msg_index=>i);
     debug('Deleted message at position: ' || i,'process_mobile_msg');
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      debug('Exception raised!','process_mobile_msg');
      NULL;
END process_mobile_msg;

PROCEDURE GET_TRIPSTOP_INFO(x_tripstop_info OUT NOCOPY t_genref
                              ,p_trip_id IN NUMBER
                                ,p_org_id IN NUMBER)  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
/*Bug 2900813: Added code to fetch even Ship Method code and Enforce Ship Method Flag*/
OPEN x_tripstop_info FOR
  SELECT         wt.trip_id
                ,wt.name
                ,wt.vehicle_item_id
                ,msi.concatenated_segments
                ,wt.vehicle_num_prefix
                ,wt.vehicle_number
                ,wts.departure_seal_code
                ,WMS_DIRECT_SHIP_PVT.GET_ENFORCE_SHIP
                ,WMS_DIRECT_SHIP_PVT.GET_SHIPMETHOD_MEANING(wt.ship_method_code)
                ,wt.ship_method_code
    FROM  wsh_trips_ob_grp_v wt
        ,wsh_trip_stops_ob_grp_v wts
        ,mtl_system_items_kfv msi
  WHERE wt.trip_id = p_trip_id
  AND   wt.trip_id = wts.trip_id
  AND   (wt.vehicle_item_id = msi.inventory_item_id(+)
          AND      msi.organization_id(+) = p_org_id)
  AND   ROWNUM < 2;
END GET_TRIPSTOP_INFO;


PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
                           p_delivery_id IN NUMBER,
         p_org_id IN NUMBER)  IS

    l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_trip_id NUMBER;
    l_trip_name wsh_trips.name%TYPE;

BEGIN
open x_delivery_info for
    SELECT wnd.delivery_id
          ,wnd.name
          ,WMS_DIRECT_SHIP_PVT.GET_DELIVERY_LPN(wnd.delivery_id)
          ,nvl(wnd.net_weight, 0)
          ,nvl(wnd.gross_weight, 0)
          ,wnd.weight_uom_code
          ,wnd.waybill
          ,WMS_DIRECT_SHIP_PVT.GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
          ,wnd.ship_method_code
          ,WMS_DIRECT_SHIP_PVT.GET_FOBLOC_CODE_MEANING(wnd.fob_code)
          ,wnd.fob_location_id
          ,WMS_DIRECT_SHIP_PVT.GET_FOB_LOCATION(wnd.fob_location_id)
          ,wnd.freight_terms_code
          ,WMS_DIRECT_SHIP_PVT.GET_FREIGHT_TERM(wnd.freight_terms_code)
          ,WMS_DIRECT_SHIP_PVT.GET_FOB_LOCATION(wnd.INTMED_SHIP_TO_LOCATION_ID)
          ,WMS_DIRECT_SHIP_PVT.GET_BOL(wnd.delivery_id)
          ,nvl(wnd.status_code,'OP')
          ,WMS_DIRECT_SHIP_PVT.GET_ENFORCE_SHIP
          ,wts1.trip_id --2767767
	  ,wnd.fob_code  --Bug#9668537,9668537 and 9399092
FROM wsh_new_deliveries_ob_grp_v wnd,
      -- 2767767
(SELECT wdl.delivery_id,wts.trip_id
        FROM wsh_delivery_legs_ob_grp_v wdl,
             wsh_trip_stops_ob_grp_v wts
        WHERE wdl.delivery_id=p_delivery_id
        AND   wdl.pick_up_stop_id=wts.stop_id
        AND ROWNUM=1) wts1 -- end 2767767
WHERE wnd.delivery_id = p_delivery_id
and   wnd.delivery_id=wts1.delivery_id(+); --2767767

/* bug # 2994098 */
-- If a delivery is ship confirmed from STF without closing the trip
-- then trip id should be updated in wstt because user may try to close the trip from mobile.
BEGIN
    SELECT wts.trip_id,wt.name
    INTO l_trip_id,l_trip_name
        FROM wsh_delivery_legs_ob_grp_v wdl,
             wsh_trip_stops_ob_grp_v wts,
         wsh_trips_ob_grp_v wt
        WHERE wdl.delivery_id=p_delivery_id
        AND wdl.pick_up_stop_id=wts.stop_id
         AND wt.trip_id=wts.trip_id
        AND ROWNUM=1;
    IF l_trip_id IS NOT NULL THEN
        UPDATE wms_shipping_transaction_temp
        SET trip_id=l_trip_id,trip_name=l_trip_name
        WHERE delivery_id=p_delivery_id and trip_id is null;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
    debug('trip_id update on wstt failed','get_delivery_info');
        NULL;
 END;
END GET_DELIVERY_INFO;

-- This Function concatenates all LPN NAME that are part of Delivery
FUNCTION GET_DELIVERY_LPN(p_delivery_id IN NUMBER ) RETURN VARCHAR2 IS
  CURSOR delivery_lpn IS
  SELECT distinct license_plate_number
  FROM  wms_shipping_transaction_temp wstt
       ,wms_license_plate_numbers wlpn
  WHERE wstt.delivery_id = p_delivery_id
  AND   wstt.outermost_lpn_id = wlpn.lpn_id
  AND   wstt.direct_ship_flag = 'Y';
l_lpn_string  VARCHAR2(30);
l_lpn_concat  VARCHAR2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  OPEN delivery_lpn;
  LOOP
    FETCH delivery_lpn into l_lpn_string;
        EXIT WHEN delivery_lpn%NOTFOUND;
   IF delivery_lpn%ROWCOUNT = 1 THEN
     l_lpn_concat := l_lpn_string;
   ELSE
        l_lpn_concat := l_lpn_concat || '|' || l_lpn_string;
   END IF;
  END LOOP;
  CLOSE delivery_lpn;
  RETURN l_lpn_concat;
END;  -- GET_DELIVERY_LPN

FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2)
RETURN  VARCHAR2  IS
l_ship_method_meaning VARCHAR2(80);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_ship_method_code IS NULL THEN
    RETURN '';
  ELSE
     SELECT meaning
     INTO l_ship_method_meaning
     FROM fnd_lookup_values_vl
     WHERE lookup_type = 'SHIP_METHOD'
     AND   view_application_id = 3
     AND   lookup_code = p_ship_method_code;
  END IF;
     RETURN l_ship_method_meaning;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN '';
END GET_SHIPMETHOD_MEANING;

FUNCTION GET_FOBLOC_CODE_MEANING(p_fob_code  IN  VARCHAR2)
RETURN VARCHAR2 IS
 l_fob_loc_meaning  VARCHAR2(80);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_fob_code IS NULL THEN
     RETURN '';
  ELSE
     SELECT meaning
         INTO l_fob_loc_meaning
     FROM  ar_lookups
     WHERE lookup_type = 'FOB'
     AND SYSDATE BETWEEN nvl(start_date_active,sysdate) AND nvl(end_date_active,sysdate)
     AND  enabled_flag = 'Y'
     AND  lookup_code = p_fob_code;
  END IF;
    RETURN l_fob_loc_meaning;
EXCEPTION
     WHEN OTHERS THEN
        RETURN '';
END GET_FOBLOC_CODE_MEANING;

FUNCTION GET_FOB_LOCATION(p_fob_location_id IN NUMBER)
RETURN VARCHAR2  IS
 l_fob_location VARCHAR2(80);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_fob_location_id IS NULL THEN
    RETURN '';
  ELSE
    SELECT description
        INTO l_fob_location
        FROM wsh_hr_locations_v
   WHERE location_id = p_fob_location_id;
  END IF;
    RETURN l_fob_location;
EXCEPTION
    WHEN OTHERS THEN
         RETURN '';
END GET_FOB_LOCATION;

FUNCTION GET_FREIGHT_TERM(p_freight_term_code VARCHAR2)
RETURN VARCHAR2 IS
  l_freight_term  VARCHAR2(80);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_freight_term_code IS NULL THEN
     RETURN '';
  ELSE
    SELECT freight_terms
    INTO l_freight_term
    FROM oe_frght_terms_active_v
    WHERE freight_terms_code = p_freight_term_code;
  END IF;
    RETURN      l_freight_term;
EXCEPTION
    WHEN OTHERS THEN
         RETURN '';
END GET_FREIGHT_TERM;

FUNCTION GET_BOL(p_delivery_id  NUMBER)
RETURN NUMBER IS
  l_BOL         NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_delivery_id IS NULL THEN
     RETURN '';
  ELSE
    SELECT wdi.SEQUENCE_NUMBER
    INTO l_BOL
    FROM wsh_document_instances wdi
            ,wsh_delivery_legs_ob_grp_v      wdl
        WHERE wdl.delivery_id = p_delivery_id
        AND   wdi.entity_id   = wdl.delivery_leg_id
        AND   wdi.entity_name = 'WSH_DELIVERY_LEGS'
        AND   rownum < 2;
        -- Right now datamodel sugget that  WDI - WDL >- WND. So for 1 delivery multiple delivery leg
        -- multiple BOL. Desktop Application does not support this still I would like to show one BOL
  END IF;
    RETURN      l_BOL;
EXCEPTION
    WHEN OTHERS THEN
         RETURN '';
END GET_BOL;

FUNCTION get_enforce_ship RETURN VARCHAR2 IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   x_enforce_ship VARCHAR2(1);
   x_return_status VARCHAR2(1);
   x_param_info WSH_SHIPPING_PARAMS_GRP.Global_Params_Rec;
BEGIN
   IF l_debug = 1 THEN
      debug('Calling Shipping API get_global_parameters','get_enforce_ship');
   END IF;

   WSH_SHIPPING_PARAMS_GRP.get_global_parameters
     (x_global_param_info=>x_param_info,
      x_return_status => x_return_status);

   x_enforce_ship := x_param_info.ENFORCE_SHIP_METHOD;

   IF (l_debug = 1) THEN
      debug('Shipping API returned status: ' || x_return_status,'get_enforce_ship');
      debug('Enforce ship Y/N : ' || x_enforce_ship, 'get_enforce_ship');
   END IF;

   IF x_enforce_ship IS NULL THEN
      x_enforce_ship := 'N';
   END IF;

   RETURN x_enforce_ship;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
     debug('Others exception raised','get_enforce_ship');
      END IF;
      RETURN 'N';
END get_enforce_ship;

PROCEDURE CHECK_DELIVERY(x_return_status        OUT NOCOPY VARCHAR2
                        ,x_msg_count            OUT NOCOPY NUMBER
                        ,x_msg_data             OUT NOCOPY VARCHAR2
                        ,x_error_code           OUT NOCOPY NUMBER
                        ,p_delivery_id          IN  NUMBER
                        ,p_org_id               IN  NUMBER
                        ,p_dock_door_id         IN  NUMBER
                 )
IS
temp_val         NUMBER;
l_ship_set       VARCHAR2(2000) := NULL;
l_error_msg      VARCHAR2(20000) := NULL;
l_return_status  VARCHAR2(1);
l_msg_data       VARCHAR2(3000);
l_msg_count      NUMBER;
x_error_msg      VARCHAR2(20000);
x_delivery_name  VARCHAR2(30);
x_outermost_lpn  VARCHAR2(10);
l_loaded_dock_door  VARCHAR2(2000);
unspec_ship_set_exists  EXCEPTION;
incomplete_delivery     EXCEPTION;
no_ship_method_code     EXCEPTION;
check_ord_line_split    EXCEPTION;
delivery_lines_mix      EXCEPTION;
l_del_name            VARCHAR2(30);
l_enforce_ship_method  VARCHAR2(1);
l_ship_method_code     VARCHAR2(30);
l_missing_count        NUMBER;
CURSOR lpn_in_other_dock(p_delivery_id  NUMBER) IS
  SELECT milk.concatenated_segments
       , wstt.outermost_lpn
  FROM mtl_item_locations_kfv milk
      ,wms_shipping_transaction_temp wstt
  WHERE wstt.delivery_id           = p_delivery_id
  AND   wstt.organization_id       = p_org_id
  AND   wstt.dock_appoint_flag     = 'N'
  AND   wstt.direct_ship_flag      = 'Y'
  AND   wstt.dock_door_id          <> p_dock_door_id
  AND   milk.organization_id       = p_org_id
  AND   milk.inventory_location_id =wstt.dock_door_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      debug('In check deliveries','Check_Delivery');
      debug('p_delivery_id  : ' || p_delivery_id ,'Check_Delivery');
      debug('p_org_id       : ' || p_org_id      ,'Check_Delivery');
      debug('p_dock_door_id : ' || p_dock_door_id,'Check_Delivery');
   END IF;
   x_return_Status := fnd_api.g_ret_sts_success;
   x_error_code := 0;  -- everything is fine
   -- This procedure does all validation for a Delivery before it can be CONFIRMED
   -- x_error_code = 1  Missing Item Calling program should call Missing Item cursor
   -- x_error_code = 2  Material Status does not allow Sales Order Issue transaction
   -- x_error_code = 3  Shipset Validation Failed. x_ship_set will be populated with
   -- Shipset Name, show it on mobile page
   -- x_error_code = 4  For the delivery there are some LPNs loaded on different Dock
   -- x_error_code = 5  Delivery could not be locked. Error
   -- x_error_code = 6  No Ship_method_code is provided when it is required. Error
   -- x_error_code = 7  Lines were split in order management . Error
   --x_error_code  =8   All delivery Delivery Lines are not from the direct_ship source
   -- Locked the record first, so that others will not able to ship the same delivery
   IF p_delivery_id IS NOT NULL THEN
      BEGIN
         SELECT name
         INTO l_del_name
         FROM wsh_new_deliveries_ob_grp_v
         WHERE delivery_id =p_delivery_id;
      EXCEPTION
         WHEN no_data_found THEN
            NULL;
      END;
   END IF;
   BEGIN
      SELECT 1
      INTO temp_val
      FROM wsh_new_deliveries_ob_grp_v
      WHERE delivery_id = p_delivery_id
      FOR UPDATE NOWAIT;
      IF (l_debug = 1) THEN
         debug('Lock delivery successful','Check_Delivery');
      END IF;
   EXCEPTION WHEN others THEN
          x_return_Status := fnd_api.g_ret_sts_error;
          fnd_message.set_name('WMS','WMS_DEL_LOCK_FAILURE');
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
          /*Failed to aquire locks on wsh_new_deliveries for <DELIVERY_NAME>*/
          fnd_msg_pub.add;
          fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                     p_data  => x_msg_data
                                    );
          /*Failed to lock the delivery */
          x_error_code := 5;
          IF (l_debug = 1) THEN
             debug('Lock delivery unsuccessful','Check_Delivery');
          END IF;
          RETURN;
   END;

   -- First check if the entire delivery is ready to be ship confirmed
   -- If No means there are some Missing Item  exists. Show Missing Item page
/*   INV_SHIPPING_TRANSACTION_PUB.CHECK_ENTIRE_EZ_DELIVERY(
                                 p_delivery_id     => p_delivery_id,
                                 x_return_Status   => l_return_status,
                                 x_error_msg       => l_error_msg);*/
     wms_direct_ship_pvt.CHECK_MISSING_ITEM_CUR(
                                 p_delivery_id  => p_delivery_id
                                 ,p_dock_door_id => p_dock_door_id
                                 ,p_organization_id => p_org_id
                                 ,x_return_Status  => l_return_status
                                 ,x_missing_count  => l_missing_count
                              );

        IF l_return_Status =  'S' AND l_missing_count > 0 then
     IF (l_debug = 1) THEN
        debug('There are Missing Items','CHECK_DELIVERY');
     END IF;
     fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data
                                );
     x_return_Status := fnd_api.g_ret_sts_error;
     x_error_code := 1; -- not entire delivery is ready
     rollback;
     return;
   ELSIF l_return_status <> 'S' THEN
     x_return_Status := fnd_api.g_ret_sts_unexp_error;
     rollback;
     return;
   END IF;

   IF (l_debug = 1) THEN
      debug('Call to Iwms_direct_ship_pvt.CHECK_MISSING_ITEM_CUR successful ','Check_Delivery');
   END IF;
        -- Check Delivery Status (Material Status
   INV_SHIPPING_TRANSACTION_PUB.CHECK_DELIVERY_STATUS
             (p_delivery_id    => p_delivery_id
             ,x_return_Status => l_return_status
             ,x_error_msg     => x_error_msg);
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         fnd_message.set_name('WMS','WMS_NO_ISSUE_TRX');
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
         /*Material Status prevents the sales order issue transaction for one
           or more items in the delivery <DELIVERY_NAME>*/
         FND_MSG_PUB.ADD;
         IF (l_debug = 1) THEN
            debug('Call to INV_SHIPPING_TRANSACTION_PUB.CHECK_DELIVERY_STATUS ' ||
                  'returned with Status E '||P_DELIVERY_ID,'Check_Delivery');
         END IF;
         x_error_code := 2;      -- status doesn't allow ship confirm
        RAISE incomplete_delivery;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS','WMS_NO_ISSUE_TRX');
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
         /*Material Status prevents the sales order issue transaction for one or
           more items in the delivery <DELIVERY_NAME>*/
          FND_MSG_PUB.ADD;
          x_error_code := 2;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF (l_debug = 1) THEN
         debug('INV_SHIPPING_TRANSACTION_PUB.CHECK_DELIVERY_STATUS was successful','Check_Delivery');
      END IF;
        -- Check for Ship Set
        -- x_return_status (l_return_status = 'C' then Shipset was Null,
        -- 'E' means Shipset Validation failed. 'U' means Unexpected Error
        WMS_SHIPPING_TRANSACTION_PUB.SHIP_SET_CHECK( p_trip_id => null,
                            p_dock_door_id => p_dock_door_id,
                            p_organization_id => p_org_id,
                            x_ship_set      => l_ship_set,
                            x_return_Status => l_return_status,
                            x_error_msg     => l_error_msg,
                            p_direct_ship_flag => 'Y' );
     IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             debug('WMS_SHIPPING_TRANSACTION_PUB.ship_set_check returned with status' ||
                   ' E- shipset  '||l_ship_set,'Check_Delivery');
          END IF;
          FND_MESSAGE.SET_NAME('INV', 'WMS_WSH_SHIPSET_FORCED');
          FND_MESSAGE.SET_TOKEN('SHIP_SET_NAME', l_ship_set);
          FND_MSG_PUB.ADD;
          RAISE unspec_ship_set_exists;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          FND_MESSAGE.SET_NAME('INV', 'WMS_SHIPSET_FAILED');
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_del_name);
          /*Ship set validation for the delivery <DELIVERY_NAME> has failed*/
          FND_MSG_PUB.ADD;
          IF (l_debug = 1) THEN
             debug('WMS_SHIPPING_TRANSACTION_PUB.ship_set_check returned with status U','Check_Delivery');
          END IF;
           RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF (l_debug = 1) THEN
         debug('Call to WMS_SHIPPING_TRANSACTION_PUB.SHIP_SET_CHECK was successful ','Check_Delivery');
      END IF;
        -- Check if delivery has some delivery_details (LPNs) loaded on different dock door
     OPEN lpn_in_other_dock(p_delivery_id);
     FETCH lpn_in_other_dock INTO l_loaded_dock_door,x_outermost_lpn;
     IF lpn_in_other_dock%FOUND THEN
         IF (l_debug = 1) THEN
            debug('Cursor lpn_in_other_dock returned a row ','Check_Delivery');
         END IF;
         BEGIN
              SELECT name
                 INTO x_delivery_name
                 FROM wsh_new_deliveries_ob_grp_v
                 WHERE delivery_id = p_delivery_id;
              FND_MESSAGE.SET_NAME('WMS','WMS_LPN_OTHER_DOCK');
              FND_MESSAGE.SET_TOKEN('LPN_NAME',x_outermost_lpn);
              FND_MESSAGE.SET_TOKEN('DOCK',l_loaded_dock_door);
              /* LPN <LPN_NAME> in this delivery <DELIVERY_NAME> is loaded at another dock door <DOCK>*/
              FND_MSG_PUB.ADD;
               fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                          p_data  => x_msg_data
                                        );
              l_return_status := fnd_api.g_ret_sts_error;
              x_error_code    :=  4;
              IF (l_debug = 1) THEN
                 debug('lpn is in other dock door lpn,dock_door and del_id are '
                        || x_outermost_lpn ||' - ' ||l_loaded_dock_door || ' - '
                        ||p_delivery_id, 'Check_Delivery');
              END IF;
         EXCEPTION
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                  debug('In No data found -Check_Deliveries','Check_Delivery');
               END IF;
               null;
         END;
     END IF;
     CLOSE lpn_in_other_dock;

     wms_direct_ship_pvt.chk_del_for_direct_ship(x_return_status =>l_return_status
                                                 ,x_msg_count    => l_msg_count
                                                 ,x_msg_data     => l_msg_data
                                                 ,p_delivery_id  => p_delivery_id
                                                    );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         IF (l_debug = 1) THEN
            debug('Call to chk_del_for_direct_ship returned with Status E '||P_DELIVERY_ID,'Check_Delivery');
         END IF;
         RAISE delivery_lines_mix;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             debug('Call to chk_del_for_direct_ship returned with Status U '||P_DELIVERY_ID,'Check_Delivery');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   EXCEPTION
        WHEN unspec_ship_set_exists THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_error_code := 3;
            IF (l_debug = 1) THEN
               debug('In exception unspec_ship_set_exists -Check_Deliveries - errorcode '
                      ||x_error_code,'Check_Delivery');
            END IF;
            --  Get message count and data
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data);

        WHEN incomplete_delivery THEN
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                    p_data  => x_msg_data
                                  );
            x_error_code := 2;
            IF (l_debug = 1) THEN
               debug('In exception incomplete_delivery -Check_Deliveries - errorcode '||x_error_code,'Check_Delivery');
            END IF;

        WHEN no_ship_method_code THEN
           x_return_status := fnd_api.g_ret_sts_error;
           FND_MESSAGE.SET_NAME('WMS','WMS_SHIP_METHOD_CODE');
           FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_del_name);
           /* No Ship method code provided for the delivery DELIVERY_NAME .This is required */
           FND_MSG_PUB.ADD;
           fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                    p_data  => x_msg_data
                                  );
            IF (l_debug = 1) THEN
               debug('In exception no_ship_method_code -Check_Deliveries - errorcode '||x_error_code,'Check_Delivery');
            END IF;
            x_error_code := 6;
        WHEN check_ord_line_split THEN
           x_return_status := fnd_api.g_ret_sts_error;
           x_error_code := 7;
           fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );
        WHEN delivery_lines_mix THEN
           x_return_status := fnd_api.g_ret_sts_error;
           x_error_code := 8;
            FND_MESSAGE.SET_NAME('WMS','WMS_DEL_LINES_MIX');
           FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_del_name);
           /* The Delivery also has lines that were not staged through Direct Ship*/
           FND_MSG_PUB.ADD;
           fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );
        WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
          --  Get message count and data
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );
            IF (l_debug = 1) THEN
               debug('In unexpected  -Check_Deliveries - errorcode '||x_error_code,'Check_Delivery');
            END IF;

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );
               x_error_code := 5;
            IF (l_debug = 1) THEN
               debug('In exception when others -Check_Deliveries - errorcode '||x_error_code,'Check_Delivery');
            END IF;

END CHECK_DELIVERY;

PROCEDURE UPDATE_DELIVERY(
              x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_delivery_id             IN  NUMBER
             ,p_net_weight                 IN  NUMBER
             ,p_gross_weight            IN  NUMBER
             ,p_wt_uom_code             IN  VARCHAR2
             ,p_waybill                    IN  VARCHAR2
             ,p_ship_method_code      IN  VARCHAR2
             ,p_fob_code                   IN  VARCHAR2
             ,p_fob_location_id      IN  NUMBER
             ,p_freight_term_code     IN         VARCHAR2
             ,p_freight_term_name     IN  VARCHAR2
             ,p_intmed_shipto_loc_id  IN  NUMBER
                         )IS

l_init_msg_list                  VARCHAR2(1) :=FND_API.G_TRUE;
l_return_status                  VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
l_msg_count                      NUMBER;
l_msg_data                       VARCHAR2(20000);
l_fob_location_id      NUMBER := P_fob_location_id;
l_intmed_shipto_loc_id NUMBER :=p_intmed_shipto_loc_id;


l_freight_cost_rec                WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType;
l_delivery_info                   WSH_DELIVERIES_PUB.Delivery_Pub_Rec_Type;
l_row_id                          ROWID;
l_delivery_id                     NUMBER;
l_freight_cost_id                 NUMBER;
l_delivery_name                   VARCHAR2(30);
l_name                            VARCHAR2(30);
l_del_name                        VARCHAR2(30); /* fOR MESSAGE TOKEN */
l_status_code                     VARCHAR2(3);
l_trip_id                         NUMBER; -- 2767767

CURSOR delivery_freight IS
SELECT  ROWID
        ,FREIGHT_COST_TYPE_ID
        ,CURRENCY_CODE
                  ,FREIGHT_AMOUNT
                  ,CONVERSION_TYPE
        FROM  WMS_FREIGHT_COST_TEMP
        WHERE delivery_id = p_delivery_id
          AND FREIGHT_COST_ID IS NULL
        FOR UPDATE OF FREIGHT_COST_ID;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

 IF p_delivery_id IS NOT NULL THEN
     SELECT status_code
     INTO l_status_code
     FROM wsh_new_deliveries_ob_grp_v
     WHERE delivery_id = p_delivery_id;

     IF l_status_code IN ('CL','CO','IT') THEN
        RETURN ;
     END IF;
  ELSE
     RETURN;
  END IF;

    IF (l_debug = 1) THEN
       debug('In Update delivery procedure ','update_Delivery');
       DEBUG('p_delivery_id          : '||p_delivery_id,'update_Delivery');
       DEBUG('p_ship_method_code     : '||p_ship_method_code,'update_Delivery');
       DEBUG('p_FREIGHT_TERM_CODE    : '||p_FREIGHT_TERM_CODE,'update_Delivery');
       DEBUG('p_fob_code             : '||p_fob_code,'update_Delivery');
       DEBUG('p_fob_location_id      : '||p_fob_location_id,'update_Delivery');
       DEBUG('p_waybill              : '||p_waybill,'update_Delivery');
       DEBUG('p_net_weight           : '||p_net_weight,'update_Delivery');
       DEBUG('p_gross_weight         : '||p_gross_weight,'update_Delivery');
       DEBUG('p_wt_uom_code          : '||p_wt_uom_code,'update_Delivery');
       DEBUG('p_intmed_shipto_loc_id : '||p_intmed_shipto_loc_id,'update_Delivery');
    END IF;

    IF p_delivery_id IS NOT NULL  THEN
       BEGIN
          SELECT name
             INTO l_del_name
             FROM wsh_new_deliveries_ob_grp_v
             WHERE delivery_id = p_delivery_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
       END;
    END IF;

OPEN delivery_freight;
LOOP
  FETCH delivery_freight into l_row_id
                             ,l_freight_cost_rec.FREIGHT_COST_TYPE_ID
                             ,l_freight_cost_rec.CURRENCY_CODE
                             ,l_freight_cost_rec.UNIT_AMOUNT
                             ,l_freight_cost_rec.CONVERSION_TYPE_CODE;

       l_freight_cost_rec.delivery_ID     :=p_delivery_id;
       l_freight_cost_rec.action_code     := 'CREATE';
  EXIT WHEN delivery_freight%NOTFOUND;

  WSH_FREIGHT_COSTS_PUB.Create_Update_Freight_Costs (
                         p_api_version_number     =>1.0
                       , p_init_msg_list          =>l_init_msg_list
                       , p_commit                 => FND_API.G_FALSE
                       , x_return_status          => l_return_status
                       , x_msg_count              => l_msg_count
                       , x_msg_data               => l_msg_data
                       , p_pub_freight_costs      => l_freight_cost_rec
                       , p_action_code            => 'CREATE'
                       , x_freight_cost_id        => l_freight_cost_id
                       );

  IF( l_return_status IN(fnd_api.g_ret_sts_error)) THEN
     FND_MESSAGE.SET_NAME('WMS','WMS_CREATE_FREIGHT_FAIL');
     FND_MESSAGE.SET_TOKEN('OBJ','Delivery');
     FND_MESSAGE.SET_TOKEN('VAL',l_del_name);
     /* Creation of freight cost for OBJ VAL has failed  */
     fnd_msg_pub.add;
     IF (l_debug = 1) THEN
        debug('Update of Freight Cost for Del is failed ','UPDATE_DELIVERY');
     END IF;
     raise FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = 'U' ) THEN
     FND_MESSAGE.SET_TOKEN('OBJ','Delivery');
     FND_MESSAGE.SET_TOKEN('VAL',l_del_name);
     /* Creation of freight cost for <OBJ> <VAL> has failed  */
      fnd_msg_pub.add;
       IF (l_debug = 1) THEN
          debug('Update of Freight Cost for Del is succ ','UPDATE_DELIVERY');
       END IF;
       raise fnd_api.g_exc_unexpected_error;
  END IF;

  UPDATE WMS_FREIGHT_COST_TEMP
  SET freight_cost_id = l_freight_cost_id,
      last_update_date=  SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID
  WHERE rowid = l_row_id;

END LOOP;
CLOSE delivery_freight;
   IF l_intmed_shipto_loc_id =0 THEN
      l_intmed_shipto_loc_id := NULL;
   END IF;
   IF l_fob_location_id =0  THEN
       l_fob_location_id:=NULL;
   END IF;
   IF (p_net_weight             IS NOT NULL OR
       p_gross_weight           IS NOT NULL OR
       p_wt_uom_code            IS NOT NULL OR
       p_waybill                IS NOT NULL OR
       p_ship_method_code       IS NOT NULL OR
       p_fob_code               IS NOT NULL OR
       p_fob_location_id        IS NOT NULL OR
       p_freight_term_code      IS NOT NULL OR
       p_freight_term_name      IS NOT NULL OR
       p_intmed_shipto_loc_id   IS NOT NULL
          )  THEN

       -- 2767767
       -- if delivery is assigned to trip update of ship method is not allowed
       BEGIN
              SELECT distinct wts.trip_id
              INTO l_trip_id
              FROM wsh_delivery_legs_ob_grp_v wdl,
                   wsh_trip_stops_ob_grp_v wts
              WHERE wdl.delivery_id=p_delivery_id
              AND   wdl.pick_up_stop_id=wts.stop_id
              AND rownum=1;
            IF (l_debug = 1) THEN
                debug('Delivery '||p_delivery_id||' is assigned to trip '||l_trip_id,'Update Delivery');
             END IF;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              l_trip_id:=NULL;
          END;


          l_delivery_info.DELIVERY_ID                            := p_delivery_id;
          -- 2767767
          IF l_trip_id IS  NULL THEN
             l_delivery_info.SHIP_METHOD_CODE                       := p_ship_method_code;
              IF (l_debug = 1) THEN
                debug('Delivery ' ||p_delivery_id||' is assigned to trip '
                      ||l_trip_id ||' and hence not updating ship method','Update Delivery');
              END IF;
          END IF;
          l_delivery_info.FREIGHT_TERMS_CODE        := p_freight_term_code;
          l_delivery_info.FOB_CODE                  := p_fob_code;
          l_delivery_info.FOB_LOCATION_ID           := l_fob_location_id;
          l_delivery_info.WAYBILL                   := p_waybill;
          l_delivery_info.NET_WEIGHT                := p_net_weight;
          l_delivery_info.GROSS_WEIGHT              := p_gross_weight;
          l_delivery_info.WEIGHT_UOM_CODE           := p_wt_uom_code;
          l_delivery_info.INTMED_SHIP_TO_LOCATION_ID:=l_intmed_shipto_loc_id;

           WSH_DELIVERIES_PUB.Create_Update_Delivery(
                       p_api_version_number                => 1.0
                      ,p_init_msg_list                     => l_init_msg_list
                      ,x_return_status                     => l_return_status
                      ,x_msg_count                         => l_msg_count
                      ,x_msg_data                          => l_msg_data
                      ,p_action_code                       => 'UPDATE'
                      ,p_delivery_info                     => l_delivery_info
                      ,p_delivery_name                     => l_delivery_name
                      ,x_delivery_id                       => l_delivery_id
                      ,x_name                              => l_name);

             IF( l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                IF (l_debug = 1) THEN
                   debug('Create _Update_Delivery has errored ','UPDATE_DELIVERY');
                END IF;
                FND_MESSAGE.SET_NAME('WMS','WMS_UPDATE_DELIVERY_FAILED');
                FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
               /* Updation of delivery <DELIVERY_NAME> has failed */
                fnd_msg_pub.add;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status IN (fnd_api.g_ret_sts_error)) THEN
                FND_MESSAGE.SET_NAME('WMS','UPDATE_DELIVERY_FAILED');
                FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
               /* Updation of delivery <DELIVERY_NAME> has failed */
                fnd_msg_pub.add;
                raise FND_API.G_EXC_ERROR;
             END IF;
   END IF;
   IF (l_debug = 1) THEN
      debug('Update delivery completed successfully');
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                  p_data  => x_msg_data
                                  );
      ROLLBACK;

      IF delivery_freight%ISOPEN THEN
             CLOSE delivery_freight;
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                  p_data  => x_msg_data
                                  );
      ROLLBACK;

      IF delivery_freight%ISOPEN THEN
             CLOSE delivery_freight;
      END IF;
      IF (l_debug = 1) THEN
         debug('Update of Delivery has failed :Unexpected Error','Update Delivery');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
        fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                   p_data  => x_msg_data
                                );
      IF delivery_freight%ISOPEN THEN
             CLOSE delivery_freight;
      END IF;
      IF (l_debug = 1) THEN
         debug('Update of Delivery has failed : Unexpected Error '||SQLERRM,'Update_Delivery');
      END IF;

          IF SQLCODE IS NOT NULL THEN
            IF (l_debug = 1) THEN
               debug(SQLCODE,'Update_Delivery');
            END IF;
          END IF;

END; -- UPDATE_DELIVERY

PROCEDURE MISSING_ITEM_CUR( x_missing_item_cur  OUT NOCOPY t_genref
                            ,p_delivery_id         IN  NUMBER
                            ,p_dock_door_id        IN  NUMBER
                           ,p_organization_id   IN  NUMBER
                                   ) IS
l_count NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      Debug( ' in missing_item_check', 'MISSING_ITEM_CUR');
   END IF;
   l_count := 0;

  IF ( p_delivery_id <> 0 ) then
        IF (l_debug = 1) THEN
           Debug( 'p_dock_door_id : ' || p_dock_door_id, 'MISSING_ITEM_CUR');
           Debug( 'p_organization_id : ' || p_organization_id, 'MISSING_ITEM_CUR');
        END IF;
    BEGIN
       OPEN x_missing_item_cur FOR
       select wnd.name,
              wdd.delivery_detail_id,
              wdd.inventory_item_id,
              wdd.requested_quantity,
              msik.concatenated_segments,
              msik.description
       from wsh_delivery_details_ob_grp_v wdd
           ,wsh_delivery_assignments_v wda
           ,wsh_new_deliveries_ob_grp_v wnd
           ,mtl_system_items_kfv msik
       where wnd.delivery_id = p_delivery_id
       AND   wnd.delivery_id = wda.delivery_id
       AND   wda.delivery_detail_id = wdd.delivery_detail_id
       AND   wdd.lpn_id is null
       AND   wdd.inventory_item_id = msik.inventory_item_id
       AND   wdd.organization_id = msik.organization_id
       AND   ((wda.parent_delivery_detail_id is null
               AND msik.mtl_transactions_enabled_flag <> 'N')
               OR wdd.released_status is null
               OR wdd.released_status NOT IN ('X', 'Y'));

        IF (l_debug = 1) THEN
           debug('Right Cur: Delivery Id : '||p_delivery_id||' Org Id '
                  ||p_organization_id||' Dock Door '||p_dock_door_id,'Missing_Item_Cur');
        END IF;
        RETURN;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           debug('Dummy Cur: Delivery Id : '||p_delivery_id||' Org Id '
                  ||p_organization_id||' Dock Door '||p_dock_door_id,'Missing_Item_Cur');
        END IF;
        open x_missing_item_cur FOR select 1 from dual;
        return;
    END;
  END IF;
END MISSING_ITEM_CUR;

PROCEDURE SHIP_CONFIRM(
              x_return_status          OUT  NOCOPY VARCHAR2
              ,x_msg_count             OUT  NOCOPY NUMBER
              ,x_msg_data                   OUT  NOCOPY VARCHAR2
              ,x_missing_item_cur      OUT  NOCOPY t_genref
              ,x_error_code              OUT  NOCOPY NUMBER
              ,p_delivery_id             IN  NUMBER
              ,p_net_weight              IN  NUMBER     DEFAULT NULL
              ,p_gross_weight            IN  NUMBER     DEFAULT NULL
              ,p_wt_uom_code             IN  VARCHAR2   DEFAULT NULL
              ,p_waybill                    IN  VARCHAR2        DEFAULT NULL
              ,p_ship_method_code      IN  VARCHAR2     DEFAULT NULL
              ,p_fob_code                   IN  VARCHAR2        DEFAULT NULL
              ,p_fob_location_id       IN  NUMBER       DEFAULT NULL
              ,p_freight_term_code     IN  VARCHAR2     DEFAULT NULL
              ,p_freight_term_name     IN  VARCHAR2     DEFAULT NULL
              ,p_intmed_shipto_loc_id  IN  NUMBER       DEFAULT NULL
              ,p_org_id                     IN  NUMBER  DEFAULT NULL
              ,p_dock_door_id            IN  NUMBER     DEFAULT NULL
              ) IS
l_init_msg_list                 VARCHAR2(1) :=FND_API.G_TRUE;
l_return_status                 VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(20000);

l_ship_set                      VARCHAR2(2000) := NULL;
l_error_msg                     VARCHAR2(20000) := NULL;
l_trip_id                       NUMBER;
l_trip_name                     VARCHAR2(30);
unspec_ship_set_exists          EXCEPTION;
incomplete_delivery             EXCEPTION;
l_error_code                    NUMBER;
x_ret_code                      number;
l_status_code                   varchar2(3);
l_del_name                      VARCHAR2(30);
l_msg_table                     WSH_INTEGRATION.MSG_TABLE ;
l_count                         NUMBER := 0;

-- varajago: Added the following 3, for 5204686
l_enforce_shipmethod            VARCHAR2(1) ;
l_trip_shipmethod_code          VARCHAR2(30);
l_trip_shipmethod_meaning       VARCHAR2(80);


l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

l_ignore_for_planning     wsh_delivery_details.ignore_for_planning%type;
l_tms_interface_flag      wsh_new_deliveries.TMS_INTERFACE_FLAG%type;
l_otm_trip_id             wsh_trips.trip_id%type;
l_otm_carrier_id          wsh_trips.carrier_id%type;
l_otm_ship_method_code    wsh_trips.ship_method_code%type;
l_otm_mode                wsh_trips.mode_of_transport%type;
l_otm_plan_name           wsh_trips.tp_plan_name%type;

l_severity          WSH_EXCEPTIONS.SEVERITY%TYPE;
l_exception_name    WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE;
l_exception_text    WSH_EXCEPTIONS.MESSAGE%TYPE;

l_otm_ifp_del_ids wsh_util_core.id_tab_type;

l_num_warn         NUMBER :=0;
l_num_error       NUMBER :=0;

  l_allow_ship_set_break   VARCHAR2(1) := 'N';    -- code added for bug#8596010

CURSOR c_Get_Trip(v_del_id NUMBER) IS
   select wt.trip_id , wt.carrier_id, wt.ship_method_code, wt.mode_of_transport,
     wt.tp_plan_name -- glog proj
     from wsh_delivery_legs wdl, wsh_trip_stops wts, wsh_trips wt
     where wdl.pick_up_stop_id=wts.stop_id
     and wdl.delivery_id=v_del_id
     and wts.trip_id=wt.trip_id;

  CURSOR c_get_delivery_info IS
     SELECT status_code,NAME,ignore_for_planning, tms_interface_flag
       FROM wsh_new_deliveries_ob_grp_v
       WHERE delivery_id = p_delivery_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_ret_code := 0;
  IF (l_debug = 1) THEN
     debug('p_delivery_id          : '||p_delivery_id,'ship_confirm');
     debug('p_net_weight           : '||p_net_weight,'ship_confirm');
     debug('p_gross_weight         : '||p_gross_weight,'ship_confirm');
     debug('p_wt_uom_code          : '||p_wt_uom_code,'ship_confirm');
     debug('p_waybill              : '||p_waybill,'ship_confirm');
     debug('p_ship_method_code     : '||p_ship_method_code,'ship_confirm');
     debug('p_fob_code             : '||p_fob_code,'ship_confirm');
     debug('p_fob_location_id      : '||p_fob_location_id,'ship_confirm');
     debug('p_freight_term_code    : '||p_freight_term_code,'ship_confirm');
     debug('p_freight_term_name    : '||p_freight_term_name,'ship_confirm');
     debug('p_intmed_shipto_loc_id : '||p_intmed_shipto_loc_id,'ship_confirm');
     debug('p_org_id               : '||p_org_id,'ship_confirm');
     debug('p_dock_door_id         : '||p_dock_door_id,'ship_confirm');
  END IF;

  IF p_delivery_id IS NOT NULL THEN

     OPEN c_get_delivery_info;
     FETCH c_get_delivery_info INTO l_status_code,l_del_name, l_ignore_for_planning, l_tms_interface_flag;

     IF (c_get_delivery_info%NOTFOUND) THEN
	NULL;
     END IF;

     CLOSE c_get_delivery_info;


     IF l_status_code IN ('CL','CO','IT') THEN
	RETURN ;
     END IF;
   ELSE
     RETURN;
  END IF;

  IF (    p_net_weight          IS NOT NULL OR
	  p_gross_weight        IS NOT NULL OR
	  p_wt_uom_code         IS NOT NULL OR
	  p_waybill             IS NOT NULL OR
	  p_ship_method_code    IS NOT NULL OR
	  p_fob_code    IS NOT NULL OR
	  p_fob_location_id     IS NOT NULL OR
	  p_freight_term_code   IS NOT NULL OR
	  p_freight_term_name   IS NOT NULL OR
	  p_intmed_shipto_loc_id IS NOT NULL
	  )  THEN
     WMS_DIRECT_SHIP_PVT.UPDATE_DELIVERY(
              x_return_status          => l_return_status
              ,x_msg_count             => l_msg_count
              ,x_msg_data              => l_msg_data
              ,p_delivery_id             => p_delivery_id
              ,p_net_weight              => p_net_weight
              ,p_gross_weight            => p_gross_weight
              ,p_wt_uom_code             => p_wt_uom_code
              ,p_waybill                         => p_waybill
              ,p_ship_method_code      => p_ship_method_code
              ,p_fob_code                   => p_fob_code
              ,p_fob_location_id              => p_fob_location_id
              ,p_freight_term_code     => p_freight_term_code
              ,p_freight_term_name     => p_freight_term_name
              ,p_intmed_shipto_loc_id  => p_intmed_shipto_loc_id
              );
     IF l_return_status = fnd_api.g_ret_sts_error THEN
	IF (l_debug = 1) THEN
	   DEBUG('Update Delivery API failed with status E ','SHIP_CONFIRM');
	END IF;
	RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	IF (l_debug = 1) THEN
	   DEBUG('Update Delivery API failed with status U','SHIP_CONFIRM');
	 END IF;
	 raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  -- Check for material status, shipset and missing item
  IF (l_debug = 1) THEN
     debug('WMS_DIRECT_SHIP_PVT.SHIP_CONFIRM. Check the delivery for the correctness ' || ' before Confirming it','Ship_confirm');
  END IF;
  WMS_DIRECT_SHIP_PVT.CHECK_DELIVERY(
				     x_return_status        => l_return_status
				     ,x_msg_count            => l_msg_count
				     ,x_msg_data        => l_msg_data
				     ,x_error_code           => l_error_code
				     ,p_delivery_id          => p_delivery_id
				     ,p_org_id          => p_org_id
				     ,p_dock_door_id         => p_dock_door_id
				     );

  IF l_error_code = 1 THEN  -- Case of Missing Item, Call Missing Item Cursor
     IF (l_debug = 1) THEN
	debug(' Ship_Confirm. Missing Item Error','Ship_Confirm');
     END IF;
     WMS_DIRECT_SHIP_PVT.MISSING_ITEM_CUR(
					  x_missing_item_cur      => x_missing_item_cur
					  ,p_delivery_id            => p_delivery_id
					  ,p_organization_id        => p_org_id
					  ,p_dock_door_id   => p_dock_door_id);
     x_error_code := l_error_code;
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_msg_pub.count_and_get( p_count => x_msg_count,
				p_data  => x_msg_data);
     RETURN;
   ELSIF (l_error_code in (2,3,4,5,6,7,8) ) THEN
     IF (l_debug = 1) THEN
        debug(' Ship_Confirm Error. ShipSet, LPN Loaded on different Dock,ship_method_code ','Ship_Confirm');
     END IF;
     x_error_code := l_error_code;
     x_return_status := l_return_status;
     fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data);
     RETURN;
  END IF ;


  /* Note: We do not need this update to ignore for planning here again becs things are taken care of during
  the stage_lpn() API. At this time, we will always have the delivery - either existing or created in stage_LPN()
    there is no check on exception severity in stage_lpn().

  -- Glog Changes
  IF WSH_UTIL_CORE.GC3_IS_INSTALLED = 'Y' AND nvl(l_ignore_for_planning, 'N') = 'N' THEN

     l_otm_trip_id  := 0;
     l_otm_carrier_id   := 0;
     l_otm_ship_method_code := NULL;
     l_otm_mode     := NULL;
     l_otm_plan_name    := NULL;

     OPEN c_GET_TRIP(p_delivery_id);
     FETCH c_GET_TRIP INTO l_otm_trip_id, l_otm_carrier_id, l_otm_ship_method_code, l_otm_mode, l_otm_plan_name;

     IF (c_GET_TRIP%NOTFOUND) THEN
	l_otm_ship_method_code := p_ship_method_code;
     END IF;

     CLOSE c_GET_TRIP;

     IF l_debug = 1 THEN
	debug(' otm_plan_name : ' || l_otm_plan_name, 'Ship Confirm');
	debug(' otm_trip_id : '|| l_otm_trip_id, 'Ship Confirm');
	debug(' tms_interface_flag : ' ||l_tms_interface_flag, 'Ship Confirm');
     END IF;

     --
     -- The 'null' tp_plan_name indicates that the delivery is not
     -- associated to an OTM plan. Hence ignore the delivery for planning.
     -- (CR->NS and AW->DR for 'Not assigned' to an OTM trip Delivery).
     -- This update for the ignore_for_plan to 'Y' is needed to autocreate the trip
     -- for this delivery during ship conform.
     --

     WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM(
					    p_delivery_id  =>  p_delivery_id,
					    p_tms_interface_flag  => l_tms_interface_flag,
					    p_trip_id   => l_otm_trip_id,
					    x_return_status =>  l_return_status);
  END IF;
*/

  -- Create the Trip for the delivery is it does not exists already
  IF (l_debug = 1) THEN
     debug(' Ship_Confirm. Check Delivery was success, Create Trip if needed for delivery','Ship_Confirm');
  END IF;

  IF (l_debug = 1) THEN
     debug(' Ship_Confirm. Calling CREATE_TRIP','Ship_Confirm');
     debug('p_org_id  '||p_org_id);
     debug('p_dock_door_id '||p_dock_door_id);
  END IF;
   WMS_DIRECT_SHIP_PVT.CREATE_TRIP(
             x_return_status    => l_return_status
             ,p_organization_id  => p_org_id
             ,p_dock_door_id     => p_dock_door_id
       ,p_delivery_id      =>p_delivery_id /* bug 2741857 */
             ,p_direct_ship_flag => 'Y'
             );
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
           debug(' Ship_Confirm. Create Trip Failed','Ship_Confirm');
        END IF;
        fnd_message.set_name('WMS','WMS_CREATE_TRIP_FAIL');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
        /* Failed to create trip for the delivery DELIVERY_NAME */
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS','WMS_CREATE_TRIP_FAIL');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
        FND_MSG_PUB.ADD;
        IF (l_debug = 1) THEN
           debug(' Ship_Confirm. Create Trip Failed Unexpected Error','Ship_Confirm');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
      IF (l_debug = 1) THEN
         debug('before calling Ship Confirm','Ship Confirm');
      END IF;

      INV_SHIPPING_TRANSACTION_PUB.get_shipmethod_details
                    ( p_org_id                  => p_org_id
                     ,p_delivery_id             => p_delivery_id
                     ,p_enforce_shipmethod      => l_enforce_shipmethod
                     ,p_trip_id                 => l_trip_id
                     ,x_trip_shipmethod_code    => l_trip_shipmethod_code
                     ,x_trip_shipmethod_meaning => l_trip_shipmethod_meaning
                     ,x_return_status           => l_return_status
                     ,x_msg_data                => l_msg_data
                     ,x_msg_count               => l_msg_count);

      IF (l_debug = 1) THEN
          debug('get_shipmethod_details.' ,'Ship_Confirm');
          debug('l_return_status: '|| l_return_status,'Ship_Confirm');
          debug('l_msg_data: '     || l_msg_data,     'Ship_Confirm');
          debug('l_msg_count: '    || l_msg_count,    'Ship_Confirm');
          debug('l_enforce_shipmethod: '      || l_enforce_shipmethod,    'Ship_Confirm');
          debug('l_trip_id: '      || l_trip_id,    'Ship_Confirm');
          debug('l_trip_shipmethod_code: '    || l_trip_shipmethod_code,   'Ship_Confirm');
          debug('l_trip_shipmethod_meaning: ' || l_trip_shipmethod_meaning,'Ship_Confirm');
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- If everything is fine then confirm the delivery

      --Set global to say shipping via Direct Ship instead of desktop
      --Added so that WMS_SHIPPING_PUB.DEL_WSTT_RECS_BY_DELIVERY_ID will
      --not fail in Shipping's API.
      wms_globals.g_ship_confirm_method := 'DIRECT';

       -- code added for bug#8596010
            wms_shipping_transaction_pub.g_allow_ship_set_break := l_allow_ship_set_break;

       IF l_debug = 1 THEN

       debug('l_allow_ship_set_break: ' || l_allow_ship_set_break,'Ship Confirm');

       END IF;
       -- End of code added for bug#8596010

      WSH_DELIVERIES_PUB.Delivery_Action ( p_api_version_number     => 1.0
                   ,p_init_msg_list          => l_init_msg_list
                   ,x_return_status          => l_return_status
                    ,x_msg_count              => l_msg_count
                    ,x_msg_data               => l_msg_data
                    ,p_action_code            => 'CONFIRM'
                    ,p_delivery_id            => p_delivery_id
                    ,p_sc_action_flag         => 'S'
                    ,p_sc_intransit_flag      => 'N'
                    ,p_sc_close_trip_flag     => 'N'
                    ,p_sc_create_bol_flag     => 'Y'
                    ,p_sc_stage_del_flag      => 'Y'
                    ,p_sc_defer_interface_flag => 'Y'
		    ,p_sc_trip_ship_method       => l_trip_shipmethod_code -- added for 5204688
                    ,p_wv_override_flag       => 'N'
                    ,x_trip_id                =>  l_trip_id
            ,x_trip_name              =>  l_trip_name);
      wms_globals.g_ship_confirm_method := NULL;

     IF (l_debug = 1) THEN
        debug('after calling Ship confirm','Ship confirm');
     END IF;
     IF (l_return_status=fnd_api.g_ret_sts_success) THEN
     l_count:=0;

     FOR i in 1..WSH_INTEGRATION.G_MSG_TABLE.COUNT LOOP
            IF (WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'W' ) THEN
               l_count := l_count + 1;
               l_msg_table(l_count) := WSH_INTEGRATION.G_MSG_TABLE(i);
            END IF;
    END LOOP;
    IF (l_debug = 1) THEN
       debug('before calling process shipping warning msgs','ship_confirm');
    END IF;
    WMS_SHIPPING_MESSAGES.PROCESS_SHIPPING_WARNING_MSGS(x_return_status  => l_return_status ,
                                                            x_msg_count      => l_msg_count ,
                                                            x_msg_data       => l_msg_data,
                                                            p_commit         => FND_API.g_false,
                                                            x_shipping_msg_tab  => l_msg_table);

    FOR i in 1..l_msg_table.count LOOP
              IF ( l_msg_table(i).MESSAGE_TYPE = 'E' ) THEN
                 --l_error_exists := TRUE;
                l_return_status:=fnd_api.g_ret_sts_error;
                 FOR j in 1..WSH_INTEGRATION.G_MSG_TABLE.COUNT LOOP
                    IF (l_msg_table(i).message_name = WSH_INTEGRATION.G_MSG_TABLE(j).MESSAGE_NAME) THEN
                       WSH_INTEGRATION.G_MSG_TABLE(j).MESSAGE_TYPE := 'E';
                    END IF;
                 END LOOP;
              END IF;
           END LOOP;
           l_msg_table.delete;
     END IF;
    IF( l_return_status IN (fnd_api.g_ret_sts_error)) THEN
       FND_MESSAGE.SET_NAME('WMS','WMS_CONFIRM_DEL_FAIL');
       FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
       -- Ship Confirm of delivey <DELIVERY_NAME> failed
       FND_MSG_PUB.ADD;
       IF (l_debug = 1) THEN
          debug(' Ship_Confirm. Confirm Delivery is failing from WSH_DELIVERY_PUB','Ship_Confirm');
       END IF;
       raise FND_API.G_EXC_ERROR;

    ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
       FND_MESSAGE.SET_NAME('WMS','WMS_CONFIRM_DEL_FAIL');
       FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
       /* cONFIRM DELIVERY FAILED*/
       FND_MSG_PUB.ADD;
       IF (l_debug = 1) THEN
          debug(' Ship_Confirm. Confirm Delivery is failing from WSH_DELIVERY_PUB, Unexpected error','Ship_Confirm');
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Ship confirm successful.  Display only Interface Trip stop message from shipping
    process_mobile_msg;
    x_msg_count := fnd_msg_pub.count_msg;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
         debug('In Exception (expected error) - E ','Ship_Confirm');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
         debug('In Exception (unexpected error) - U ','Ship_Confirm');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
         debug('In Exception (others)' ||SQLERRM,'Ship_Confirm');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );
END;  -- SHIP_CONFIRM

-- Called when User presses Trip Info Button or CLOSE TRUCK Button

PROCEDURE CONFIRM_ALL_DELIVERIES(
              x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_missing_item_cur     OUT NOCOPY t_genref
             ,x_error_code           OUT  NOCOPY NUMBER
             ,p_delivery_id          IN  NUMBER
             ,p_net_weight           IN  NUMBER
             ,p_gross_weight         IN  NUMBER
             ,p_wt_uom_code          IN  VARCHAR2
             ,p_waybill              IN  VARCHAR2
             ,p_ship_method_code     IN  VARCHAR2
             ,p_fob_code             IN  VARCHAR2
             ,p_fob_location_id      IN  NUMBER
             ,p_freight_term_code    IN  VARCHAR2
             ,p_freight_term_name    IN  VARCHAR2
             ,p_intmed_shipto_loc_id IN  NUMBER
             ,p_org_id               IN  NUMBER
             ,p_dock_door_id         IN  NUMBER)IS
l_init_msg_list                                          VARCHAR2(1) :=FND_API.G_TRUE;
l_return_status                                          VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
l_msg_count                                                      NUMBER;
l_msg_data                                                       VARCHAR2(20000);
l_rowid                                                          ROWID;
l_delivery_id                                            NUMBER;
l_delivery_name                                          VARCHAR2(30);
l_name                                                   VARCHAR2(30);
l_ship_set                                               NUMBER;
l_t_genref                                              t_genref;
l_error_code                                             NUMBER;
l_trip_id                                                NUMBER;
l_trip_name                                              VARCHAR2(30);
CURSOR loaded_deliveries IS
  SELECT DISTINCT WSTT.delivery_id
  FROM WMS_SHIPPING_TRANSACTION_TEMP wstt
      ,WSH_NEW_DELIVERIES_OB_GRP_V WND
  WHERE wstt.organization_id = p_org_id
  AND   wstt.dock_door_id = p_dock_door_id
  AND   wstt.dock_appoint_flag = 'N'
  AND   nvl(wstt.direct_ship_flag,'N') = 'Y'
  AND   wstt.delivery_id = wnd.delivery_id
  AND   wnd.status_code = 'OP';

--
CURSOR ALL_DELIVERIES IS
    SELECT DELIVERY_ID FROM WMS_SHIPPING_TRANSACTION_TEMP
    WHERE DELIVERY_ID IS NOT NULL
    AND TRIP_ID IS NULL
    AND ORGANIZATION_ID=P_ORG_ID
    AND DOCK_DOOR_ID=P_DOCK_DOOR_ID
    AND NVL(DIRECT_SHIP_FLAG,'N')='Y';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

-- Call this API from Trip Info page of the Delivery Info. If thats the case
-- then Delivery might have been changed. First update it then Shipconfirm all
-- delivery loaded on the dock.
IF (l_debug = 1) THEN
   debug('Confirm All Deliveries: Begin delivery_id'||to_char(p_delivery_id),'CONFIRM_ALL_DELIVERIES');
END IF;
x_return_status:= FND_API.G_RET_STS_SUCCESS;
       IF (l_debug = 1) THEN
          debug('The value OF p_delivery_id        is '||p_delivery_id,'Confirm_All_Delivery');
          debug('The value OF p_net_weight is '||p_net_weight,'Confirm_All_Delivery');
          debug('The value OF p_gross_weight       is '||p_gross_weight,'Confirm_All_Delivery');
          debug('The value OF p_wt_uom_code        is '||p_wt_uom_code,'Confirm_All_Delivery');
          debug('The value OF p_waybill    is '||p_waybill,'Confirm_All_Delivery');
          debug('The value OF p_ship_method_code   is '||p_ship_method_code,'Confirm_All_Delivery');
          debug('The value OF p_fob_code   is '||p_fob_code,'Confirm_All_Delivery');
          debug('The value OF p_fob_location_id    is '||p_fob_location_id,'Confirm_All_Delivery');
          debug('The value OF p_freight_term_code  is '||p_freight_term_code,'Confirm_All_Delivery');
          debug('The value OF p_freight_term_name  is '||p_freight_term_name,'Confirm_All_Delivery');
          debug('The value OF p_intmed_shipto_loc_id       is '||p_intmed_shipto_loc_id,'Confirm_All_Delivery');
          debug('The value OF p_org_id     is '||p_org_id,'Confirm_All_Delivery');
          debug('The value OF p_dock_door_id       is '||p_dock_door_id,'Confirm_All_Delivery');
       END IF;

 IF (p_net_weight              IS NOT NULL OR
          p_gross_weight       IS NOT NULL OR
          p_wt_uom_code        IS NOT NULL OR
          p_waybill            IS NOT NULL OR
          p_ship_method_code   IS NOT NULL OR
          p_fob_code           IS NOT NULL OR
          p_fob_location_id    IS NOT NULL OR
          p_freight_term_code  IS NOT NULL OR
          p_freight_term_name      IS NOT NULL OR
          p_intmed_shipto_loc_id   IS NOT NULL
          )  THEN
    WMS_DIRECT_SHIP_PVT.UPDATE_DELIVERY(
              x_return_status        => l_return_status
              ,x_msg_count           => l_msg_count
              ,x_msg_data            => l_msg_data
              ,p_delivery_id                     => p_delivery_id
              ,p_net_weight                      => p_net_weight
              ,p_gross_weight               => p_gross_weight
              ,p_wt_uom_code                     => p_wt_uom_code
              ,p_waybill                                 => p_waybill
              ,p_ship_method_code        => p_ship_method_code
              ,p_fob_code                      => p_fob_code
              ,p_fob_location_id                 => p_fob_location_id
              ,p_freight_term_code   => p_freight_term_code
              ,p_freight_term_name   => p_freight_term_name
              ,p_intmed_shipto_loc_id => p_intmed_shipto_loc_id
              );
    IF (l_debug = 1) THEN
       debug('Return Status from Update_Delivery: '||l_return_status, ' Confirm_All_Deliveries');
    END IF;
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                 debug('Update Delivery API failed with status E ','Confirm_All_deliveries');
              END IF;
              RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                 debug('Update Delivery API failed with status U','Confirm_All_Deliveries');
              END IF;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
 END IF;
 /* bug # 2994098 */
    -- If a delivery is ship confirmed from STF without closing the trip
    -- then trip id should be updated in wstt because user may try to close the trip from mobile.
    BEGIN
    FOR l_deliveries IN all_deliveries
    LOOP
       BEGIN
         SELECT wts.trip_id,wt.name
         INTO l_trip_id,l_trip_name
         FROM wsh_delivery_legs_ob_grp_v wdl,
              wsh_trip_stops_ob_grp_v wts,
              wsh_trips_ob_grp_v wt
        WHERE wdl.delivery_id=l_deliveries.delivery_id
        AND   wdl.pick_up_stop_id=wts.stop_id
        AND   wt.trip_id=wts.trip_id
        AND  ROWNUM=1;
        IF l_trip_id IS NOT NULL THEN
            UPDATE wms_shipping_transaction_temp
            SET trip_id=l_trip_id,trip_name=l_trip_name
            WHERE delivery_id=l_deliveries.delivery_id AND trip_id IS NULL;
        END IF;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
        debug('trip_id update on wstt failed','CONFIRM_ALL_DELIVERIES');
         END;
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
         debug('trip_id update on wstt failed','CONFIRM_ALL_DELIVERIES');
    END;


  IF (p_delivery_id IS NOT NULL) THEN
     IF (l_debug = 1) THEN
        debug('P_Delivery_Id is not null ','Confirm_All_Deliveries');
     END IF;
     WMS_DIRECT_SHIP_PVT.SHIP_CONFIRM(
                  x_return_status   =>l_return_status
                  ,x_msg_count       =>l_msg_count
                  ,x_msg_data        =>l_msg_data
                  ,x_missing_item_cur=>l_t_genref
                  ,x_error_code      =>l_error_code
                  ,p_delivery_id     =>p_delivery_id
                  ,p_org_id          =>p_org_id
                  ,p_dock_door_id    =>p_dock_door_id
                  );
      x_missing_item_cur := l_t_genref;
      x_error_code       := l_error_code;

     IF (l_debug = 1) THEN
        debug('Return Status - Error_code from Ship_Confirm 1: '||l_return_status
              ||' - '||l_error_code, ' Confirm_All_Deliveries');
     END IF;
     IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   debug('Ship Confirm API failed with status E ','Confirm_All_deliveries');
                END IF;
                RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   debug('Ship Confirm API failed with status U','Confirm_All_Deliveries');
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;
  IF ((p_org_id IS NOT NULL) AND (p_dock_door_id IS NOT NULL)) THEN
     IF (l_debug = 1) THEN
        debug('Confirm All Deliveries: Org id and Dock Door is not null loop ' ||
              'loaded deliveries','Confirm_All_Deliveries');
     END IF;
   OPEN loaded_deliveries;
   LOOP
     FETCH loaded_deliveries into l_delivery_id;
     EXIT WHEN loaded_deliveries%NOTFOUND;
     IF (l_debug = 1) THEN
        debug('Confirm All Deliveries: Delivery Id '||to_char(l_delivery_id),'Confirm_All_Deliveries');
     END IF;
     WMS_DIRECT_SHIP_PVT.SHIP_CONFIRM(
           x_return_status   =>l_return_status
           ,x_msg_count       =>l_msg_count
           ,x_msg_data       =>l_msg_data
           ,x_missing_item_cur=>l_t_genref
           ,x_error_code      =>l_error_code
           ,p_delivery_id     =>l_delivery_id
           ,p_org_id         =>p_org_id
           ,p_dock_door_id    =>p_dock_door_id
           );
      x_missing_item_cur := l_t_genref;
      x_error_code       := l_error_code;
      IF (l_debug = 1) THEN
         debug('Return Status - Error_code from Ship_Confirm 2: '||l_return_status
               ||' - '||l_error_code, ' Confirm_All_Deliveries');
      END IF;
     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
           debug('Ship Confirm API failed with status E ','Confirm_All_deliveries');
        END IF;
        RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
           debug('Ship Confirm API failed with status U','Confirm_All_Deliveries');
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END LOOP;
   close loaded_deliveries;
END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF loaded_deliveries%isopen THEN
         CLOSE loaded_deliveries;
      END IF ;
      IF (l_debug = 1) THEN
         debug('In Exception (expected error) - E ','Confirm_All_Deliveries');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF loaded_deliveries%isopen THEN
         CLOSE loaded_deliveries;
      END IF ;
      IF (l_debug = 1) THEN
         debug('In Exception (unexpected error) - U ','Confirm_All_Deliveries');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF loaded_deliveries%isopen THEN
         CLOSE loaded_deliveries;
      END IF ;
      IF (l_debug = 1) THEN
         debug('In Exception (others)' ||SQLERRM,'Confirm_All_Deliveries');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
              );

END; -- CONFIRM_DELIVERY

PROCEDURE CREATE_TRIP(x_return_status    OUT NOCOPY VARCHAR2,
                      p_organization_id  IN  NUMBER,
                      p_dock_door_id     IN  NUMBER,
                      p_delivery_id      IN NUMBER,
                      p_direct_ship_flag IN  VARCHAR2 DEFAULT 'N'
                      ) IS
l_del_tab            WSH_UTIL_CORE.ID_TAB_TYPE;
l_auto_trip_del      WSH_UTIL_CORE.ID_TAB_TYPE;
l_auto_trip_index    NUMBER:=1;
--l_delivery_id        NUMBER;
l_return_Status      VARCHAR2(1);
l_del_index          NUMBER;
l_del_count          NUMBER;
l_trip_id                NUMBER;
l_chk_trip_id        NUMBER;
l_trip_name          VARCHAR2(30);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(20000);
l_out_trip_id        VARCHAR2(30);
l_out_trip_name      VARCHAR2(30);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status:= fnd_api.g_ret_sts_success;
   wms_globals.g_ship_confirm_method := 'DIRECT';
   IF (l_debug = 1) THEN
      debug('Begin Create Trip ','CREATE_TRIP');
      debug('p_organization_id  :  ' || p_organization_id,'CREATE_TRIP');
      debug('p_dock_door_id     :  ' || p_dock_door_id,'CREATE_TRIP');
      debug('p_delivery_id      :  ' || p_delivery_id,'CREATE_TRIP');
      debug('p_direct_ship_flag :  ' || p_direct_ship_flag,'CREATE_TRIP');
   END IF;
   l_del_index := 1;
      -- Add the following code in case user created Trip manually from desktop
      BEGIN
         SELECT wts.trip_id
         INTO l_trip_id
         FROM wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
         WHERE wdl.delivery_id = p_delivery_id --l_delivery_id /* bug 2741857 */
           and wdl.pick_up_stop_id = wts.stop_id;

         IF l_trip_id IS NOT NULL THEN
           UPDATE wms_shipping_transaction_temp
            SET    trip_id = l_trip_id,
                   last_update_date =  SYSDATE,
                   last_updated_by  =  FND_GLOBAL.USER_ID
            WHERE  delivery_id = p_delivery_id;--l_delivery_id; /* bug 2741857 */
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         IF (l_debug = 1) THEN
            debug('Exception part: '||p_delivery_id,'CREATE_TRIP');
         END IF;
            l_trip_id := null;
            l_del_tab(l_del_index) := p_delivery_id; --l_delivery_id; /* bug 2741857 */
            l_del_index := l_del_index + 1;
      END;
IF (l_debug = 1) THEN
   debug('End Loop thru all delivery loaded on the dock '||l_del_tab.count,'CREATE_TRIP');
END IF;
   -- Commit the update of delivery with proper trip ids
  BEGIN
     SELECT wt.trip_id
     INTO l_chk_trip_id
     FROM WMS_SHIPPING_TRANSACTION_TEMP wstt
         ,WSH_TRIPS_OB_GRP_V wt
     WHERE
          wt.trip_id = wstt.trip_id
      AND  organization_id    = p_organization_id
      AND status_code         = 'OP'
      AND dock_door_id       = p_dock_door_id
      AND dock_appoint_flag  = 'N'
       AND nvl(direct_ship_flag,'N') = 'Y'
           AND nvl(planned_flag,'N') = 'N'  -- bug 7211509, 7216163. If there are prev unplanned trips available, we shoud utilize it
           AND ROWNUM =1;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_chk_trip_id := NULL;
  END;

  IF l_chk_trip_id IS NOT NULL AND (l_del_tab.COUNT > 0) THEN
      FOR i IN 1..l_del_tab.count LOOP
          IF (l_debug = 1) THEN
             debug('The value of l_chk_trip_id is '||l_chk_trip_id,'create_trip');
          END IF;
         WSH_DELIVERIES_PUB.Delivery_Action
           ( p_api_version_number     => 1.0,
             p_init_msg_list          => FND_API.G_TRUE,
             x_return_status          => l_return_status,
             x_msg_count              => l_msg_count,
             x_msg_data               => l_msg_data,
             p_action_code            => 'ASSIGN-TRIP',
             p_delivery_id            => l_del_tab(i),
             p_asg_trip_id            => l_chk_trip_id ,
             x_trip_id                => l_out_trip_id,
             X_TRIP_NAME              => l_out_trip_name );
         IF l_return_status IN (fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               debug('UPDATE WSTT with the trip_id assigned','CREATE_TRIP');
            END IF;
               UPDATE WMS_SHIPPING_TRANSACTION_TEMP
               SET trip_id   = l_chk_trip_id
               WHERE delivery_id = l_del_tab(i);
         ELSIF l_return_status IN (fnd_api.g_ret_sts_error) THEN
               l_auto_trip_del(l_auto_trip_index) := l_del_tab(i);
               l_auto_trip_index := l_auto_trip_index +1;
         ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF (l_debug = 1) THEN
               debug('Return unexpected error from WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP',
                     'WMS_DIRECT_SHIP_PVT.Create_Trip');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;
  ELSIF l_del_tab.COUNT >0 THEN
      IF (l_debug = 1) THEN
         debug('No open trip exists.Hence auto creating trip ','create_trip');
      END IF;
      WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP(p_del_rows      => l_del_tab,
                                        x_trip_id       => l_trip_id,
                                        x_trip_name     => l_trip_name,
                                        x_return_status => l_return_status);
      IF l_return_status IN (fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
            debug('UPDATE WSTT with the trip created','CREATE_TRIP');
         END IF;
         FOR k in 1..l_del_tab.COUNT LOOP
            UPDATE WMS_SHIPPING_TRANSACTION_TEMP
            SET trip_id   = l_trip_id
            WHERE delivery_id = l_del_tab(k);
         END LOOP;
      ELSIF l_return_status IN (fnd_api.g_ret_sts_error) THEN
         IF (l_debug = 1) THEN
            debug('Return error from WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP','WMS_DIRECT_SHIP_PVT.Create_Trip');
         END IF;
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF (l_debug = 1) THEN
            debug('Return unexpected error from WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP',
                     'WMS_DIRECT_SHIP_PVT.Create_Trip');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
  END IF;

  IF l_auto_trip_del.count >0  THEN
      IF (l_debug = 1) THEN
         debug('Assignment of delivery failed.Hence auto creating trip for the failed deliveries  ',
                     'create_trip');
      END IF;
     WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP(p_del_rows      => l_auto_trip_del,
                                        x_trip_id       => l_trip_id,
                                        x_trip_name     => l_trip_name,
                                        x_return_status => l_return_status);
     IF l_return_status IN (fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
           debug('UPDATE WSTT with the trip for failed assignments','CREATE_TRIP');
        END IF;

        FOR j in 1..l_auto_trip_del.count LOOP
           UPDATE WMS_SHIPPING_TRANSACTION_TEMP
           SET trip_id   = l_trip_id
           WHERE delivery_id = l_auto_trip_del(j);
        END LOOP;

      ELSIF l_return_status IN (fnd_api.g_ret_sts_error) THEN
         IF (l_debug = 1) THEN
            debug('The API WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP returned status E ','WMS_DIRECT_SHIP_PVT.Create_Trip');
         END IF;
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF (l_debug = 1) THEN
            debug('The API WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP returned status U ','WMS_DIRECT_SHIP_PVT.Create_Trip');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
  END IF;

  wms_globals.g_ship_confirm_method := null;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      wms_globals.g_ship_confirm_method := NULL;
      IF (l_debug = 1) THEN
         debug('In Exception (expected error) - E ','CREATE_TRIP');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
              );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      wms_globals.g_ship_confirm_method := NULL;
      IF (l_debug = 1) THEN
         debug('In Exception (unexpected error) - U ','Create_Trip');
      END IF;
         fnd_msg_pub.count_and_get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
              );
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wms_globals.g_ship_confirm_method := NULL;
      IF (l_debug = 1) THEN
     debug('Exception When Others'||SQLERRM,'WMS_DIRECT_SHIP.Create_Trips');
      END IF;
END CREATE_TRIP; -- END CREATE_TRIP

PROCEDURE UPDATE_TRIPSTOP(
              x_return_status        OUT NOCOPY VARCHAR2
              ,x_msg_count            OUT NOCOPY NUMBER
              ,x_msg_data             OUT NOCOPY VARCHAR2
              ,p_trip_id              IN  NUMBER
              ,p_vehicle_item_id      IN  NUMBER
              ,p_vehicle_num_prefix   IN  VARCHAR2
              ,p_vehicle_num          IN  VARCHAR2
              ,p_seal_code            IN  VARCHAR2
              ,p_org_id               IN  NUMBER   DEFAULT NULL
              ,p_dock_door_id         IN  NUMBER   DEFAULT NULL
              ,p_ship_method_code     IN VARCHAR2 DEFAULT NULL)
 IS

l_init_msg_list                VARCHAR2(1) :=FND_API.G_TRUE;
l_return_status                VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(20000);

l_freight_cost_rec             WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType;
l_stop_info                    WSH_TRIP_STOPS_PUB.Trip_Stop_Pub_Rec_Type;
p_trip_info                    WSH_TRIPS_PUB.Trip_Pub_Rec_Type;
l_freight_cost_id              NUMBER;
l_stop_id                      NUMBER;
l_trip_id                      NUMBER;
l_trip_name                    VARCHAR2(30);
counter                        NUMBER;
l_row_id                       rowid;
l_name                         VARCHAR2(30);
l_vehicle_item_id              NUMBER;
l_org_id                       NUMBER;
l_dock_door_id                 NUMBER;

CURSOR trip_freight IS
   SELECT  ROWID
          ,FREIGHT_COST_TYPE_ID
          ,CURRENCY_CODE
          ,FREIGHT_AMOUNT
          ,CONVERSION_TYPE
   FROM  WMS_FREIGHT_COST_TEMP
   WHERE TRIP_ID = p_trip_id
   AND   FREIGHT_COST_ID IS NULL
   FOR UPDATE OF FREIGHT_COST_ID NOWAIT;

 CURSOR stops IS
 SELECT 'x'
 FROM   wsh_trip_stops_ob_grp_v
 WHERE  trip_id = p_trip_id
 FOR UPDATE  NOWAIT;

 CURSOR trips IS
 SELECT 'x'
 FROM   wsh_trips_ob_grp_v
 WHERE trip_id = p_trip_id
 FOR UPDATE NOWAIT;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      debug('Begin UPDATE_TRIPSTOP ','UPDATE_TRIPSTOP');
      debug('p_trip_id            : ' || p_trip_id              , 'UPDATE_TRIPSTOP');
      debug('p_vehicle_item_id    : ' || p_vehicle_item_id      , 'UPDATE_TRIPSTOP');
      debug('p_vehicle_num_prefix : ' || p_vehicle_num_prefix   , 'UPDATE_TRIPSTOP');
      debug('p_vehicle_num        : ' || p_vehicle_num          , 'UPDATE_TRIPSTOP');
      debug('p_seal_code          : ' || p_seal_code            , 'UPDATE_TRIPSTOP');
      debug('p_org_id             : ' || p_org_id               , 'UPDATE_TRIPSTOP');
      debug('p_dock_door_id       : ' || p_dock_door_id         , 'UPDATE_TRIPSTOP');
      debug('p_ship_method_code   : ' || p_ship_method_code     , 'UPDATE_TRIPSTOP');
   END IF;
   IF p_trip_id <>0 THEN
      l_trip_id := p_trip_id;
   END IF;
   IF p_vehicle_item_id <>0 THEN
      l_vehicle_item_id := p_vehicle_item_id;
   END IF;
   IF p_org_id <> 0 THEN
      l_org_id := p_org_id;
   END IF;
   IF p_dock_door_id <> 0 THEN
      l_dock_door_id := p_dock_door_id;
   END IF;

   l_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      debug('In the procedure update trip_stop','trip_Stop');
   END IF;

   IF (l_debug = 1) THEN
     debug('Update Trip Ship method:'||p_ship_method_code,'Update_tripstop');
  END IF;

-- Update_TripStop will be called from the save button of the Trip-Stop info page.
-- It should update the data entered in the page and also update the freight cost entered
-- if any.
-- When updating the frieght cost info ensure that freight is not entered before.

-- Check if there is any frieght cost info entered in the page, update it for trip else --create a new
--IF ( p_trip_id IS NULL ) THEN
   IF (l_trip_id IS NULL) THEN

  IF (l_debug = 1) THEN
     debug('Update Trip No Trip Id is passed','Update_tripstop');
  END IF;
  RETURN;
ELSE
   BEGIN
      SELECT name
         INTO l_name
         FROM wsh_trips_ob_grp_v
       WHERE trip_id=l_trip_id;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN;
   END;
END IF;
OPEN trip_freight;
LOOP
  FETCH trip_freight
   into l_row_id
        ,l_freight_cost_rec.FREIGHT_COST_TYPE_ID
        ,l_freight_cost_rec.CURRENCY_CODE
        ,l_freight_cost_rec.UNIT_AMOUNT
        ,l_freight_cost_rec.CONVERSION_TYPE_CODE;

       --l_freight_cost_rec.TRIP_ID     :=p_trip_id;
    l_freight_cost_rec.TRIP_ID:=l_trip_id;
    l_freight_cost_rec.action_code := 'CREATE';
  EXIT WHEN trip_freight%NOTFOUND;

  --patchst J.  Shipping API cleanup
  WSH_FREIGHT_COSTS_PUB.Create_Update_Freight_Costs
    (p_api_version_number     =>1.0
     , p_init_msg_list          =>l_init_msg_list
     , p_commit                 => FND_API.G_FALSE
     , x_return_status          => l_return_status
     , x_msg_count                      => l_msg_count
     , x_msg_data               => l_msg_DATA
     , p_pub_freight_costs      => l_freight_cost_rec
     , p_action_code            => 'CREATE'
     , x_freight_cost_id        => l_freight_cost_id
     );
  IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
     FND_MESSAGE.SET_NAME('WMS','WMS_CREATE_FREIGHT_FAIL');
     FND_MESSAGE.SET_TOKEN('OBJ','Trip');
     FND_MESSAGE.SET_TOKEN('VAL',l_name);
     /* Creation of freight cost for <OBJ> <VAL> has failed  */

     FND_MSG_PUB.ADD;
     IF (l_debug = 1) THEN
    debug('Create_Update Freight Cost API failed with status E ','Update Trip Stop');
     END IF;
     RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     FND_MESSAGE.SET_NAME('WMS','CREATE_FREIGHT_FAIL');
     FND_MSG_PUB.ADD;
     IF (l_debug = 1) THEN
    debug('Update Freight Cost failed with status U','Update TripStop');
     END IF;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --\Shipping API cleanup

  UPDATE WMS_FREIGHT_COST_TEMP
  SET freight_cost_id   = l_freight_cost_id
      ,last_update_date  =  SYSDATE
      ,last_updated_by   =  FND_GLOBAL.USER_ID
  WHERE rowid = l_row_id;

END LOOP;
CLOSE trip_freight;

-- Freight has been updated/ created. Now Update the Trip Stop info which is being entered by user.
-- Seal Code is store in Trip- Stop so we need to updated it. Rest of the info are stored in Trips


         SELECT stop_id
         INTO   l_stop_id
         FROM   WSH_TRIP_STOPS_OB_GRP_V wts, WSH_DELIVERY_LEGS_OB_GRP_V wdl
        -- WHERE  wts.trip_id = p_trip_id
            WHERE wts.trip_id=l_trip_id
         AND    wts.stop_id = wdl.pick_up_stop_id
       AND ROWNUM <2;



   IF (p_seal_code IS NOT NULL ) THEN
      --patchset J.  Shipping API cleanup
      IF (l_debug = 1) THEN
         debug('Call WSH_TRIP_STOPS_PUB.Create_Update_Stop to Update the Seal Code','Update Trip Stop');
      END IF;
      l_stop_info.stop_id              := l_stop_id;
      l_stop_info.trip_id              :=l_trip_id;
      l_stop_info.DEPARTURE_SEAL_CODE  := p_seal_code;
      WSH_TRIP_STOPS_PUB.Create_Update_Stop(
                         p_api_version_number           => 1.0
                        ,p_init_msg_list            => l_init_msg_list
                        ,x_return_status            => l_return_status
                        ,x_msg_count                => l_msg_count
                        ,x_msg_data                 => l_msg_data
                        ,p_action_code              => 'UPDATE'
                        ,p_stop_info                => l_stop_info
                        ,p_trip_id                  => l_trip_id
                        ,x_stop_id                  => l_stop_id);

         IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
            FND_MESSAGE.SET_NAME('WMS','WMS_UPD_STOP_FAIL');
            FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_name);
          -- Failed to Create/update Trip Stop for the trip <TRIP_NAME>
            fnd_msg_pub.ADD;
            IF (l_debug = 1) THEN
               debug('Create_Update_Stop API failed with status E ','Update Trip Stop');
            END IF;
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FND_MESSAGE.SET_NAME('WMS','WMS_UPD_STOP_FAIL');
            FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_name);
          -- Failed to Create/update Trip Stop for the trip <TRIP_NAME>
            fnd_msg_pub.ADD;
            IF (l_debug = 1) THEN
               debug('Create_Update_Stop failed with status U','Update TripStop');
            END IF;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     --\Shipping API cleanup
  END IF; -- Update Stop

 -- After Updating the Stop with Seal code, Update the Trip with Vehicle_item_id etc.

   IF (l_debug = 1) THEN
       debug('Update Trip also ','Update_Trip_Stop');
    END IF;
  p_trip_info.trip_id                                    :=l_trip_id;
 p_trip_info.VEHICLE_ITEM_ID         :=l_vehicle_item_id;
 p_trip_info.vehicle_organization_id  :=l_org_id;
 p_trip_info.VEHICLE_NUMBER                      := p_vehicle_num;
 p_trip_info.VEHICLE_NUM_PREFIX                  := p_vehicle_num_prefix;
 p_trip_info.last_update_date           := SYSDATE;
 p_trip_info.last_updated_by            :=FND_GLOBAL.USER_ID;
 p_trip_info.last_update_login          := FND_GLOBAL.USER_ID;
 p_trip_info.ship_method_code           :=p_ship_method_code;    --Bug 2980013:Updating the Ship Method Code*/

 IF (l_debug = 1) THEN
    debug('Call to Create_update_Trip','Update_Trip_Stop');
 END IF;

          WSH_TRIPS_PUB.Create_Update_Trip  (
                        p_api_version_number  => 1.0
                       ,p_init_msg_list       => l_init_msg_list
                       ,x_return_status       => l_return_status
                       ,x_msg_count           => l_msg_count
                       ,x_msg_data            => l_msg_data
                       ,p_action_code         => 'UPDATE'
                       ,p_trip_info           => p_trip_info
                       ,x_trip_id             => l_trip_id
                       ,x_trip_name           => l_trip_name);
         IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
               debug('Create_Update_Trip API failed with status E ','Update Trip Stop');
            END IF;
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               debug('Create_Update_Trip failed with status U','Update TripStop');
            END IF;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

    -- Update Trip

COMMIT;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
         debug('In exception (E) ','Update_Trip_Stop');
      END IF;
      ROLLBACK;
      IF trip_freight%ISOPEN THEN
             CLOSE trip_freight;
      END IF;
      fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
         debug('Update of Trip Stop has failed :Unexpected Error','Update_Trip_Stop');
      END IF;
      ROLLBACK;
      IF trip_freight%ISOPEN THEN
             CLOSE trip_freight;
      END IF;
      fnd_msg_pub.count_and_get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (l_debug = 1) THEN
         debug('Update of Trip has failed : Unexpected Error '||SQLERRM,'Update_trip_Stop');
      END IF;
      IF trip_freight%ISOPEN THEN
             CLOSE trip_freight;
      END IF;
          IF SQLCODE IS NOT NULL THEN
            IF (l_debug = 1) THEN
               debug(SQLCODE,'Update_Trip_Stop');
            END IF;
          END IF;

END;

PROCEDURE print_shipping_document(
  x_return_status      OUT NOCOPY    VARCHAR2
, x_msg_count          OUT NOCOPY    NUMBER
, x_msg_data           OUT NOCOPY    VARCHAR2
, p_trip_id            IN            NUMBER
, p_vehicle_item_id    IN            NUMBER
, p_vehicle_num_prefix IN            VARCHAR2
, p_vehicle_num        IN            VARCHAR2
, p_seal_code          IN            VARCHAR2
, p_document_set_id    IN            NUMBER
, p_org_id             IN            NUMBER DEFAULT NULL
, p_dock_door_id       IN            NUMBER DEFAULT NULL
, p_ship_method_code   IN            VARCHAR2 DEFAULT NULL
) IS
  CURSOR stop_cur IS
    SELECT wdl.pick_up_stop_id pick_up_stop_id
      FROM wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
     WHERE wts.trip_id = p_trip_id
       AND wdl.pick_up_stop_id = wts.stop_id;

  CURSOR del_cur IS
    SELECT delivery_id
      FROM wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
     WHERE wts.trip_id = p_trip_id
       AND wdl.pick_up_stop_id = wts.stop_id;

  l_del_cur             del_cur%ROWTYPE;
  l_stop_cur            stop_cur%ROWTYPE;
  l_init_msg_list       VARCHAR2(1)                             := fnd_api.g_true;
  l_return_status       VARCHAR2(1)                             := fnd_api.g_ret_sts_success;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(20000);
  l_report_set_id       NUMBER;
  l_trip_id             wsh_util_core.id_tab_type;
  l_stop_id             wsh_util_core.id_tab_type;
  l_delivery_id         wsh_util_core.id_tab_type;
  l_document_param_info wsh_document_sets.document_set_tab_type;
  l_count1              NUMBER;
  l_count2              NUMBER;
  l_dummy               VARCHAR2(20000);
  l_num                 NUMBER;
  l_debug               NUMBER                                  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
      debug('Begin print_shipping_document ','print_shipping_document');
      debug('p_trip_id            : ' || p_trip_id              , 'print_shipping_document');
      debug('p_vehicle_item_id    : ' || p_vehicle_item_id      , 'print_shipping_document');
      debug('p_vehicle_num_prefix : ' || p_vehicle_num_prefix   , 'print_shipping_document');
      debug('p_vehicle_num        : ' || p_vehicle_num          , 'print_shipping_document');
      debug('p_seal_code          : ' || p_seal_code            , 'print_shipping_document');
      debug('p_document_set_id    : ' || p_document_set_id      , 'print_shipping_document');
      debug('p_org_id             : ' || p_org_id               , 'print_shipping_document');
      debug('p_dock_door_id       : ' || p_dock_door_id         , 'print_shipping_document');
      debug('p_ship_method_code   : ' || p_ship_method_code     , 'print_shipping_document');
  END IF;

  wms_direct_ship_pvt.update_tripstop(
    x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_trip_id                    => p_trip_id
  , p_vehicle_item_id            => p_vehicle_item_id
  , p_vehicle_num_prefix         => p_vehicle_num_prefix
  , p_vehicle_num                => p_vehicle_num
  , p_seal_code                  => p_seal_code
  , p_org_id                     => p_org_id
  , p_dock_door_id               => p_dock_door_id
  , p_ship_method_code           => p_ship_method_code
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Update tripstop API failed with status E ', 'Print_shipping_dcouments');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Update tripstop API failed with status U ', 'Print_shipping_dcouments');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF p_document_set_id = 0 THEN
    l_report_set_id  := NULL;
  ELSE
    l_report_set_id  := p_document_set_id;
  END IF;

  IF (l_report_set_id IS NULL) THEN
     BEGIN
      SELECT delivery_report_set_id
        INTO l_report_set_id
        FROM wsh_shipping_parameters
       WHERE organization_id = p_org_id
         AND ROWNUM < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_report_set_id  := NULL;
    -- Return an error message that says no default Document is defined for the org
    --- So Document printing will not happen
    END;
  END IF;

  IF (l_report_set_id IS NOT NULL) THEN
    OPEN del_cur;

    LOOP
      FETCH del_cur INTO l_del_cur;
      EXIT WHEN del_cur%NOTFOUND;
      l_delivery_id(del_cur%ROWCOUNT)    := l_del_cur.delivery_id;
    END LOOP;

    CLOSE del_cur;

    IF (l_debug = 1) THEN
      DEBUG('Call WSH_DOCUMENT_SETS.Print_Document_Sets  Document Set Id ' ||
             l_report_set_id, 'Print_Shipping_Documents');
    END IF;

    l_count1      := 0;
    l_count2      := 0;
    l_count1      := fnd_msg_pub.count_msg();

    IF (l_debug = 1) THEN
      DEBUG('Call WSH_DOCUMENT_SETS.Print_document_Sets for all the deliveries');
      DEBUG('Msg table count' || l_count1, 'Print_Shipping_document');
    END IF;

    wsh_document_sets.print_document_sets(
      p_report_set_id              => l_report_set_id
    , p_organization_id            => p_org_id
    , p_trip_ids                   => l_trip_id
    , p_stop_ids                   => l_stop_id
    , p_delivery_ids               => l_delivery_id
    , p_document_param_info        => l_document_param_info
    , x_return_status              => l_return_status
    );
    l_count2      := fnd_msg_pub.count_msg();

    IF (l_debug = 1) THEN
      DEBUG('Msg table count' || l_count2, 'Print_Shipping_document');
    END IF;

    IF l_count2 > l_count1 THEN
      l_count1  := l_count1 + 2;

      FOR i IN REVERSE l_count1 .. l_count2 LOOP
        l_dummy  := fnd_msg_pub.get(i, fnd_api.g_true);

        IF (l_debug = 1) THEN
          DEBUG('Messages are' || l_dummy, 'Print_Shipping_document');
        END IF;

        fnd_msg_pub.delete_msg(i);
      END LOOP;
    END IF;

    IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
      fnd_message.set_name('WMS', 'WMS_PRINT_DOC_SET_FAIL');
      /* Failed to print the documents set */
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        DEBUG('Print Document_sets API failed with status E ', 'Print_shipping_dcouments');
      END IF;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('WMS', 'WMS_PRINT_DOC_SET_FAIL');
      /* Failed to print the documents set */
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        DEBUG('Print Document_sets API failed with status U ', 'Print_shipping_dcouments');
      END IF;
    END IF;

  END IF; -- Print report set
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;

    IF (l_debug = 1) THEN
      DEBUG('Print Document has failed :Error', 'Print_shipping_dcouments');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    ROLLBACK;
  -- Think of some messages here.
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Print Document has failed with status U', 'Print_shipping_dcouments');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    -- Think of some messages here.
    IF (l_debug = 1) THEN
      DEBUG('Print Document has failed :Unexpected Error', 'Print_shipping_dcouments');
    END IF;
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('Print Document has failed : Unexpected Error', 'Print_shipping_dcouments');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF SQLCODE IS NOT NULL THEN
      IF (l_debug = 1) THEN
        DEBUG(SQLCODE, 'Print_shipping_dcouments');
      END IF;
    END IF;
END;

  -- PRINT_SHIPPING_DOCUMENT

PROCEDURE close_trip(
  x_return_status      OUT NOCOPY    VARCHAR2
, x_msg_count          OUT NOCOPY    NUMBER
, x_msg_data           OUT NOCOPY    VARCHAR2
, p_trip_id            IN            NUMBER
, p_vehicle_item_id    IN            NUMBER
, p_vehicle_num_prefix IN            VARCHAR2
, p_vehicle_num        IN            VARCHAR2
, p_seal_code          IN            VARCHAR2
, p_document_set_id    IN            NUMBER
, p_org_id             IN            NUMBER DEFAULT NULL
, p_dock_door_id       IN            NUMBER DEFAULT NULL
, p_ship_method_code   IN            VARCHAR2 DEFAULT NULL
) IS
  l_init_msg_list        VARCHAR2(1)               := fnd_api.g_true;
  l_return_status        VARCHAR2(1)               := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(20000);
  l_stop_id              NUMBER;
  l_trip_name            VARCHAR2(30);
  l_trip_id              NUMBER;
  l_outermost_lpn        VARCHAR2(30);
  l_loaded_dock_door     VARCHAR2(2000);
  l_name                 VARCHAR2(30);
  l_delivery_details_tab wsh_util_core.id_tab_type;
  l_delivery_id          NUMBER;
  l_del_index            NUMBER;
  l_enforce_ship_method  VARCHAR2(1);
  no_ship_method_code    EXCEPTION;

  CURSOR lpn_in_other_dock(p_trip_id NUMBER) IS
    SELECT DISTINCT milk.concatenated_segments
                  , wstt.outermost_lpn
               FROM mtl_item_locations_kfv milk, wms_shipping_transaction_temp wstt
              WHERE wstt.trip_id = p_trip_id
                AND wstt.organization_id = p_org_id
                AND wstt.dock_appoint_flag = 'N'
                AND wstt.direct_ship_flag = 'Y'
                AND wstt.dock_door_id <> p_dock_door_id
                AND milk.organization_id = p_org_id
                AND milk.inventory_location_id = wstt.dock_door_id;

  CURSOR closed_trips IS
    SELECT DISTINCT wstt.trip_id
               FROM wms_shipping_transaction_temp wstt, wsh_trips_ob_grp_v wt
              WHERE wstt.organization_id = p_org_id
                AND wstt.dock_door_id = p_dock_door_id
                AND wt.trip_id = wstt.trip_id
                AND wt.status_code IN('CL', 'IT');

  CURSOR delivery_details IS
    SELECT DISTINCT wstt.delivery_id
               FROM wms_shipping_transaction_temp wstt
              WHERE wstt.organization_id = p_org_id
                AND wstt.dock_door_id = p_dock_door_id
                AND wstt.trip_id = p_trip_id;

  l_debug                NUMBER                    := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('p_trip_id            : ' || p_trip_id, 'close_trip');
    DEBUG('p_vehicle_item_id    : ' || p_vehicle_item_id, 'close_trip');
    DEBUG('p_vehicle_num_prefix : ' || p_vehicle_num_prefix, 'close_trip');
    DEBUG('p_vehicle_num        : ' || p_vehicle_num, 'close_trip');
    DEBUG('p_seal_code          : ' || p_seal_code, 'close_trip');
    DEBUG('p_document_set_id    : ' || p_document_set_id, 'close_trip');
    DEBUG('p_org_id             : ' || p_org_id, 'close_trip');
    DEBUG('p_dock_door_id       : ' || p_dock_door_id, 'close_trip');
    DEBUG('p_ship_method_code   : ' || p_ship_method_code, 'close_trip');
  END IF;

  x_return_status  := fnd_api.g_ret_sts_success;
  fnd_msg_pub.initialize;

  IF (l_debug = 1) THEN
    DEBUG('Begin Close Trip ', 'CLOSE_TRIP');
  END IF;

  -- Call Document Printing API which takes care of Updating the delivery and Printing the Doc.
  IF (l_debug = 1) THEN
    DEBUG('Call Print Document ', 'CLOSE_TRIP');
  END IF;

  IF p_trip_id IS NULL
     OR p_trip_id = 0 THEN
    IF (l_debug = 1) THEN
      DEBUG('The value for trip_id passed is zero. Exiting out ', 'close_trip');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSE
    BEGIN
      SELECT NAME
        INTO l_name
        FROM wsh_trips_ob_grp_v
       WHERE trip_id = p_trip_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  IF (l_debug=1) then
     DEBUG('Checking Ship Method Validity.', 'Close_Trip');
  END IF;
  /* Checking if the Ship Method has been entered if the enforce Ship method flag is set to Y*/

  INV_SHIPPING_TRANSACTION_PUB.get_enforce_ship
    (p_org_id         => p_org_id
     ,x_enforce_ship  => l_enforce_ship_method
     ,x_return_status => l_return_status
     ,x_msg_data      => l_msg_data
     ,x_msg_count     => l_msg_count);

  IF (l_debug=1) THEN
     debug('get_enforce_ship returned status: ' || l_return_status,'Close_Trip');
     debug('Enforce_ship_method flag: ' || l_enforce_ship_method,'Close_trip');
  END IF;

  IF l_enforce_ship_method = 'Y'
     AND p_ship_method_code IS NULL THEN
    RAISE no_ship_method_code;
  END IF;

  wms_direct_ship_pvt.print_shipping_document(
    x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_trip_id                    => p_trip_id
  , p_vehicle_item_id            => p_vehicle_item_id
  , p_vehicle_num_prefix         => p_vehicle_num_prefix
  , p_vehicle_num                => p_vehicle_num
  , p_seal_code                  => p_seal_code
  , p_document_set_id            => p_document_set_id
  , p_org_id                     => p_org_id
  , p_dock_door_id               => p_dock_door_id
  , p_ship_method_code           => p_ship_method_code
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Print shipping documents API failed with status E ', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Print shipping documents API failed with status U', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Check if there is an LPN loaded on a different Dock Door for the Trip. If so throw an error
       -- Error code in this case is
  BEGIN
    IF (l_debug = 1) THEN
      DEBUG('Check if there is an LPN loaded on different dock door for the Trip', 'Close_Trip');
    END IF;

    OPEN lpn_in_other_dock(p_trip_id);
    FETCH lpn_in_other_dock INTO l_loaded_dock_door, l_outermost_lpn;

    IF lpn_in_other_dock%FOUND THEN
      SELECT NAME
        INTO l_trip_name
        FROM wsh_trips_ob_grp_v
       WHERE trip_id = p_trip_id;

      -- Raise error and set the message to be shown in Mobile
      fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
      /*LPN LPN_NAME assigned to trip TRIP is loaded on another dock door DOCK . Hence close trip failed.*/
      fnd_message.set_token('LPN_NAME', l_outermost_lpn);
      fnd_message.set_token('TRIP', l_trip_name);
      fnd_message.set_token('DOCK', l_loaded_dock_door);
      /*Close Trip failed */
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_error;
      CLOSE lpn_in_other_dock;
      RETURN;
    END IF;

    CLOSE lpn_in_other_dock;

    IF (l_debug = 1) THEN
      DEBUG('All LPNs for the Trip are loaded on the same dock door', 'Close_Trip');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  -- Get the pickup stop for the trip so  that it may be closed.
  IF (l_debug = 1) THEN
    DEBUG('Close Trip. Get the pickup stop of the trip', 'Close_Trip');
  END IF;

  SELECT stop_id
    INTO l_stop_id
    FROM wsh_trip_stops_ob_grp_v wts, wsh_delivery_legs_ob_grp_v wdl
   WHERE wts.trip_id = p_trip_id
     AND wts.stop_id = wdl.pick_up_stop_id
     AND ROWNUM < 2;

  IF (l_debug = 1) THEN
    DEBUG('Interface the Trip now. Trip Id :' || p_trip_id || '  Pick Up Stop Id: ' || l_stop_id, 'Close_Trip');
  END IF;

  wsh_trip_stops_pub.stop_action(
    p_api_version_number         => 1.0
  , p_init_msg_list              => l_init_msg_list
  , x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_action_code                => 'CLOSE'
  , p_stop_id                    => l_stop_id
  , p_trip_id                    => p_trip_id
  , p_defer_interface_flag       => 'N'
  );

  IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
    fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
    fnd_message.set_token('TRIP_NAME', l_name);
    /*Failed to close the trip TRIP_NAME*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('Stop_Action API failed with status E ', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
    fnd_message.set_token('TRIP_NAME', l_name);
    /*Failed to close the trip TRIP_NAME*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('Stop_Action API failed with status U', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  /*8973130-starts */
  -- Get the drop off stop for the trip so  that it may be closed.
  IF (l_debug = 1) THEN
    DEBUG('Close Trip. Get the drop off stop of the trip', 'Close_Trip');
  END IF;

  SELECT stop_id
    INTO l_stop_id
    FROM wsh_trip_stops_ob_grp_v wts, wsh_delivery_legs_ob_grp_v wdl
   WHERE wts.trip_id = p_trip_id
     AND wts.stop_id = wdl.drop_off_stop_id
     AND ROWNUM < 2;

  IF (l_debug = 1) THEN
    DEBUG(' Trip Id :' || p_trip_id || '  Drop Off Stop Id: ' || l_stop_id, 'Close_Trip');
  END IF;

  wsh_trip_stops_pub.stop_action(
    p_api_version_number         => 1.0
  , p_init_msg_list              => l_init_msg_list
  , x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_action_code                => 'CLOSE'
  , p_stop_id                    => l_stop_id
  , p_trip_id                    => p_trip_id
  , p_defer_interface_flag       => 'N'
  );

  IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
    fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
    fnd_message.set_token('TRIP_NAME', l_name);
    /*Failed to close the trip TRIP_NAME*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('Stop_Action API failed with status E ', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
    fnd_message.set_token('TRIP_NAME', l_name);
    /*Failed to close the trip TRIP_NAME*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('Stop_Action API failed with status U', 'Close_Trip');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  /*8973130-Ends */

  OPEN delivery_details;
  l_del_index      := 1;

  LOOP
    FETCH delivery_details INTO l_delivery_id;
    EXIT WHEN delivery_details%NOTFOUND;
    l_delivery_details_tab(l_del_index)  := l_delivery_id;
    l_del_index                          := l_del_index + 1;
  END LOOP;

  wms_shipping_transaction_pub.print_label(l_delivery_details_tab, l_return_status);

  IF x_return_status <>(fnd_api.g_ret_sts_success) THEN
    fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');

    IF (l_debug = 1) THEN
      DEBUG('Label Printing failed ', 'Close Trip');
    END IF;

    fnd_msg_pub.ADD;
    l_return_status  := 'W';
  END IF;

  -- Clean up trips which are closed
  l_trip_id        := p_trip_id;
  OPEN closed_trips;

  LOOP
    FETCH closed_trips INTO l_trip_id;
    EXIT WHEN closed_trips%NOTFOUND;
    wms_direct_ship_pvt.cleanup_temp_recs(
      x_msg_data                   => x_msg_data
    , x_msg_count                  => x_msg_count
    , x_return_status              => x_return_status
    , p_org_id                     => p_org_id
    , p_outermost_lpn_id           => NULL
    , p_trip_id                    => l_trip_id
    );

    IF l_return_status =(fnd_api.g_ret_sts_error) THEN
      fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
      /*Failed while running cleanup program */
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        DEBUG('CLEANUP_TEMP_RECS API failed with status E ', 'Close_Trip');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('WMS', 'WMS_CLOSE_TRIP_FAIL');
      /*Failed while running cleanup program */
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        DEBUG('CLEANUP_TEMP_RECS API failed with status U', 'Close_Trip');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END LOOP;

  CLOSE closed_trips;
-- Call clean up API at this time. This API will create
EXCEPTION
  WHEN no_ship_method_code THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_SHIP_METHOD_CODE');
    fnd_message.set_token('TRIP_NAME', l_name);
    /* No Ship method code provided for the Trip .This is required */
    fnd_msg_pub.ADD;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    DEBUG('In exception no_ship_method_code - - errorcode ', 'Close Trip');
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    ROLLBACK;

    -- Think of some messages here.
    IF (l_debug = 1) THEN
      DEBUG('Close Trip has failed :Error', 'Close_Trip');
    END IF;
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;

    -- Think of some messages here.
    IF (l_debug = 1) THEN
      DEBUG('Close Trip has failed :Unexpected Error', 'Close_Trip');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('Close Trip has failed : Unexpected Error', 'Close_Trip');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF SQLCODE IS NOT NULL THEN
      IF (l_debug = 1) THEN
        DEBUG(SQLCODE, 'Close_Trip');
      END IF;
    END IF;
END;

  --CLOSE_TRIP

-- API Name         :
-- Type             : Procedure
-- Function         : This procedure does the following:
--                    1.Change LPN context to "Resides in Inventory"
--                    2.Unpack the LPN in Shipping
--                    3.Remove inventory details from Shipping (Sub, Loc, Qty).
--                    4.Remove the Reservation records
--                    5.Reset the serial_number_control_code,current_status
--                     ->if serial control code is "At SO Issue", reset current status to "Defined but not used"
--                     ->if serial control code is "Predefined" or "At Receipt" reset status to "resides in stores"
--                     ->Reset Group Mark Id
-- Input Parameters :
--   p_org_id             Organization Id
--   p_outermost_lpn_id   Outermost LPN Id
-- Output Parameters    :
--   x_return_status      Standard Output Parameter
--   x_msg_count          Standard Output Parameter
--   x_msg_data           Standard Output Parameter

PROCEDURE unload_truck(
  x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    NUMBER
, x_msg_data         OUT NOCOPY    VARCHAR2
, p_org_id           IN            NUMBER
, p_outermost_lpn_id IN            NUMBER
, p_relieve_rsv      IN            VARCHAR2 DEFAULT 'Y'/*added 3396821*/
) IS
  CURSOR wda_del_detail(l_outermost_dd_id NUMBER) IS
    SELECT     delivery_detail_id
          FROM wsh_delivery_assignments_v
    START WITH delivery_detail_id = l_outermost_dd_id
    CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

  CURSOR wdd_del_detail(p_delivery_detail_id IN NUMBER) IS
    SELECT   wdd.delivery_detail_id
           , wdd.inventory_item_id
           , wdd.serial_number
           , wdd.source_line_id
           , wdd.requested_quantity
           , wdd.transaction_temp_id
        FROM wsh_delivery_details_ob_grp_v wdd
       WHERE wdd.organization_id = p_org_id
         AND wdd.container_flag <> 'Y'
         AND wdd.delivery_detail_id = p_delivery_detail_id
    ORDER BY wdd.source_line_id;

  CURSOR del_lpn IS
     SELECT lpn_id
     FROM wms_license_plate_numbers wlpn
     WHERE wlpn.outermost_lpn_id = p_outermost_lpn_id;

  l_del_lpn             del_lpn%ROWTYPE;
  l_del_det_id          NUMBER;
  l_status_code         VARCHAR2(2);
  l_init_msg_list       VARCHAR2(1)                             := fnd_api.g_true;
  l_del_id              NUMBER;
  l_trip_id             NUMBER;
  l_trip_name           VARCHAR2(30);
  l_delivery_detail_id  NUMBER;
  counter               NUMBER;
  x_error_code          NUMBER;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(20000);
  l_serial_ctrl_code    NUMBER                                  := 1;
  l_item_id             NUMBER;
  l_source_line_id      NUMBER;
  l_prev_src_line_id    NUMBER;
  l_min_del_detail_id   NUMBER                                  := 0;
  l_sum_req_qty         NUMBER                                  := 0;
  l_serial_number       mtl_serial_numbers.serial_number%TYPE;
  l_outermost_dd_id     NUMBER;
  l_req_qty             NUMBER;
  l_transaction_temp_id NUMBER;

  /* Mrana: 7/6/06: 5350778 : Added foll. variables */
  l_lot_ctrl_code       NUMBER                                  := 1;
  l_lot_divisible_flag  VARCHAR2(1)                             := NULL;
  l_relieve_rsv         VARCHAR2(1)                             := NULL;

  TYPE delivery_detail_r IS RECORD(
    delivery_detail_id NUMBER
  , source_line_id     NUMBER
  );

  TYPE delivery_detail_t IS TABLE OF delivery_detail_r
    INDEX BY BINARY_INTEGER;

  l_delivery_detail_tab delivery_detail_t;

  l_lpn_del_det_tab wsh_util_core.id_tab_type;

  l_freight_costs      WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType;

  l_debug               NUMBER                                  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_lpn_tbl                     WMS_Data_Type_Definitions_PUB.LPNTableType;
  l_lpn_rec                     WMS_Data_Type_Definitions_PUB.LPNRecordType;

  cursor lpn_cur is
    select lpn_id, organization_id
    from wms_license_plate_numbers
    where outermost_lpn_id = p_outermost_lpn_id;


BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
    DEBUG('p_org_id: ' || p_org_id, 'UNLOAD_TRUCK');
    DEBUG('p_outermost_lpn_id: ' || p_outermost_lpn_id, 'UNLOAD_TRUCK');
    DEBUG('p_relieve_rsv: ' || p_relieve_rsv, 'UNLOAD_TRUCK');
    DEBUG('Before deleting the freight record corresponding to LPN', 'UNLOAD_TRUCK');
  END IF;

  --patchset J.  Shipping API cleanup
  --delete freight costs
  BEGIN
     SELECT wdd.delivery_detail_id, wfc.freight_cost_id
       INTO l_freight_costs.delivery_detail_id,
       l_freight_costs.freight_cost_id
       FROM wsh_delivery_details_ob_grp_v wdd,
       wsh_freight_costs wfc
       WHERE wdd.lpn_id = p_outermost_lpn_id
       AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
       AND wdd.delivery_detail_id = wfc.delivery_detail_id;

     IF l_debug = 1 THEN
    debug('About to call wsh_freight_costs_pub.delete_freight_costs','UNLOAD_TRUCK');
    debug('delivery_detail_id : '|| l_freight_costs.delivery_detail_id,'UNLOAD_TRUCK');
    debug('freight_cost_id    : '|| l_freight_costs.freight_cost_id, 'UNLOAD_TRUCK');
     END IF;
     wsh_freight_costs_pub.delete_freight_costs
       (p_api_version_number  => 1.0,
         p_init_msg_list       => l_init_msg_list,
         p_commit              => fnd_api.g_false,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data,
         p_pub_freight_costs   => l_freight_costs);

  EXCEPTION
     WHEN no_data_found THEN
    IF (l_debug = 1) THEN
      DEBUG('Could not find record in wsh_freight_cost', 'UNLOAD_TRUCK');
       END IF;
  END;
  --\Shipping API cleanup

  BEGIN
    SELECT wstt.delivery_id
         , wnd.status_code
      INTO l_del_id
         , l_status_code
      FROM wms_shipping_transaction_temp wstt, wsh_new_deliveries_ob_grp_v wnd
     WHERE wstt.outermost_lpn_id = p_outermost_lpn_id
       AND wstt.direct_ship_flag = 'Y'
       AND wstt.delivery_id = wnd.delivery_id
       AND ROWNUM = 1;

    IF (l_debug = 1) THEN
      DEBUG('The value of l_del_id and status are ' || l_del_id || '- ' || l_status_code, 'unload_truck');
    END IF;

    IF l_status_code = 'CO' THEN
      wsh_deliveries_pub.delivery_action(
        p_api_version_number         => 1.0
      , p_init_msg_list              => l_init_msg_list
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_action_code                => 'RE-OPEN'
      , p_delivery_id                => l_del_id
      , p_sc_action_flag             => NULL
      , p_sc_intransit_flag          => NULL
      , p_sc_close_trip_flag         => NULL
      , p_sc_create_bol_flag         => NULL
      , p_sc_stage_del_flag          => NULL
      , p_sc_defer_interface_flag    => NULL
      , p_wv_override_flag           => NULL
      , x_trip_id                    => l_trip_id
      , x_trip_name                  => l_trip_name
      );

      IF (l_debug = 1) THEN
        DEBUG('The value of return status of delivery_actions is ' || l_return_status, 'unload_truck');
      END IF;

      IF (l_return_status IN(fnd_api.g_ret_sts_error)) THEN
        IF (l_debug = 1) THEN
          DEBUG('Reopening of delivery failed ' || l_del_id, 'UNLOAD_TRUCK');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        IF (l_debug = 1) THEN
          DEBUG(' Reopening of delivery failed with Unexpected error' || l_del_id, 'UNLOAD_TRUCK');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  --Get the delivery detail id corresponding to the outermost lpn_id
  SELECT wdd.delivery_detail_id
    INTO l_outermost_dd_id
    FROM wsh_delivery_details_ob_grp_v wdd
   WHERE lpn_id = p_outermost_lpn_id
   AND released_status = 'X';  -- For LPN reuse ER : 6845650

  counter          := 0;

  IF (l_debug = 1) THEN
    DEBUG('outermost delivery_detail_id: ' || l_outermost_dd_id, 'Unload Truck');
  END IF;

  --FOR l_delivery_detail_cur IN delivery_details LOOP
   --OPEN delivery_details(l_outermost_dd_id);
  FOR l_wda_del_detail IN wda_del_detail(l_outermost_dd_id) LOOP
    OPEN wdd_del_detail(l_wda_del_detail.delivery_detail_id);

    LOOP
      FETCH wdd_del_detail
      INTO l_delivery_detail_id,
           l_item_id,
           l_serial_number,
           l_source_line_id,
           l_req_qty,
           l_transaction_temp_id;
      EXIT WHEN wdd_del_detail%NOTFOUND;

      IF (l_debug = 1) THEN
        DEBUG('Entered the delivery details loop', 'Unload Truck');
      END IF;

      --Increment the loop counter
      counter                                            := counter + 1;
      l_delivery_detail_tab(counter).delivery_detail_id  := l_delivery_detail_id;
      l_delivery_detail_tab(counter).source_line_id      := l_source_line_id;

     /* Mrana: 7/6/06: 5350778 : Added lot_divisible_flag in the foll. query */

      SELECT serial_number_control_code,
             lot_control_code,
             lot_divisible_flag
        INTO l_serial_ctrl_code,
             l_lot_ctrl_code,
             l_lot_divisible_flag
        FROM mtl_system_items
       WHERE inventory_item_id = l_item_id
         AND organization_id = p_org_id;

      IF (l_debug = 1) THEN
        DEBUG('Serial Control Code of item: ' || l_item_id || ' : is: ' || l_serial_ctrl_code, 'Unload_Truck');
        DEBUG('l_lot_ctrl_code : ' || l_lot_ctrl_code , 'Unload_Truck');
        DEBUG('l_lot_divisible_flag :' || l_lot_divisible_flag , 'Unload_Truck');
        DEBUG('serial #:' || l_serial_number || ' source line id is: ' || l_source_line_id, 'Unload_Truck');
      END IF;

      IF l_serial_ctrl_code IN(2, 5) THEN
        BEGIN
          UPDATE mtl_serial_numbers
             SET current_status = 3
               , group_mark_id = NULL -- -1
           WHERE inventory_item_id = l_item_id
             AND current_organization_id = p_org_id
             AND(serial_number = l_serial_number
                 OR group_mark_id = l_transaction_temp_id); --bug#2829514

          IF (l_debug = 1) THEN
            DEBUG('Group mark id reset for serial with group mark id =' || l_transaction_temp_id, 'Unload_Truck');
            DEBUG('Reset the group mark Id for: ' || SQL%ROWCOUNT || ' serials', 'Unload_truck');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF l_serial_ctrl_code = 6 THEN
        BEGIN
          UPDATE mtl_serial_numbers
             SET current_status = 1
               , group_mark_id = NULL -- -1
           WHERE inventory_item_id = l_item_id
             AND current_organization_id = p_org_id
             AND(serial_number = l_serial_number
                 OR group_mark_id = l_transaction_temp_id); --bug#2829514

          IF (l_debug = 1) THEN
            DEBUG('Group mark id reset for serial with group mark id =' || l_transaction_temp_id, 'Unload_Truck');
            DEBUG('Reset the group mark Id for: ' || SQL%ROWCOUNT || ' serials', 'Unload_truck');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;

      /* Mrana: 7/6/06: 5350778 :
       *  IF lot is not divisible, then we cannot relieve partial reservations,
       *  therefore we will always relieve reservations for suh items,whatever
       *  may be the form function parameter value in p_relieve_rsv */

      IF l_lot_ctrl_code = 2 THEN
         IF l_lot_divisible_flag = 'N' THEN
            l_relieve_rsv := 'Y' ;
         ELSE
            l_relieve_rsv := p_relieve_rsv;
         END IF ;
      ELSE
         l_relieve_rsv := p_relieve_rsv;
      END IF ;

      IF (l_debug = 1) THEN
        DEBUG('The delivery_detail_id is ' || l_delivery_detail_id, 'Unload_truck');
        DEBUG('l_relieve_rsv : ' || l_relieve_rsv, 'Unload_truck');
      END IF;

      --Return the delivery line to stock
      inv_shipping_transaction_pub.inv_line_return_to_stock(
        p_delivery_id                => NULL
      , p_delivery_line_id           => l_delivery_detail_id
      , p_shipped_quantity           => 0
      , x_msg_data                   => x_msg_data
      , x_msg_count                  => x_msg_count
      , x_return_status              => l_return_status
      , p_commit_flag                => fnd_api.g_false
      ,p_relieve_rsv                 => l_relieve_rsv /*added 3396821*/
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_RET_LINE_TO_STOCK');
        /* Failed to unload the delivery line */
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          DEBUG('inv_line_return_to_stock API failed with status E ', 'Unload_Truck');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('inv_line_return_to_stock API failed with status U', 'Unload_Truck');
        END IF;

        fnd_message.set_name('WMS', 'WMS_RET_LINE_TO_STOCK');
        /* Failed to unload the delivery line */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('inv_line_return_to_stock successful for iteration #:' || counter, 'Unload_truck');
      END IF;


      IF (l_debug = 1) THEN
        DEBUG('Update LPN Context to Reside in inventory', 'Unload_truck');
      END IF;


    --Store the source line Id for checking the next delivery detail
    END LOOP;

    CLOSE wdd_del_detail;
  END LOOP;

  /* Release 12 LPN Sync
     Call wms_container_pvt.modify_lpn API
       to update the context and remove the WDD records
       associated with those LPNs  */
  l_lpn_tbl.delete;
  FOR l_lpn IN lpn_cur LOOP
     l_lpn_rec.organization_id := l_lpn.organization_id;
     l_lpn_rec.lpn_id := l_lpn.lpn_id;
     l_lpn_rec.lpn_context := 1;
     l_lpn_tbl(nvl(l_lpn_tbl.last, 0)+1) := l_lpn_rec;
     IF (l_debug = 1) THEN
        debug('Add to l_lpn_tbl with lpn_rec of org_id'||l_lpn_rec.organization_id
               ||', lpn_id '||l_lpn_rec.lpn_id||', lpn_context '||l_lpn_rec.lpn_context, 'Unload_Truck');
     END IF;
  END LOOP;
  IF(l_debug = 1) THEN
     DEBUG('Calling WMS_CONTAINER_PVT.Modify_LPNs with caller WMS_DIRECTSHIP','Unload_Truck');
  END IF;

  WMS_CONTAINER_PVT.Modify_LPNs(
  	  p_api_version           => 1.0
  	, p_init_msg_list         => fnd_api.g_true
  	, p_commit                => fnd_api.g_false
  	, x_return_status         => l_return_status
  	, x_msg_count             => x_msg_count
  	, x_msg_data              => x_msg_data
  	, p_caller                => 'WMS_DIRECTSHIP'
  	, p_lpn_table             => l_lpn_tbl
  );
  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
       IF (l_debug = 1) THEN
  	 DEBUG('return error from WMS_CONTAINER_PVT.Modify_LPNs', 'Unload_Truck');
       END IF;
       RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug = 1) THEN
  	 DEBUG('return error from WMS_CONTAINER_PVT.Modify_LPNs', 'Unload_Truck');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_success THEN
       null;
  END IF;
  -- End of Release 12 change

  --Now, clean up the direct ship records from WSTT, WFCT, MSNT and WDST
  wms_direct_ship_pvt.cleanup_temp_recs(
    x_msg_data                   => x_msg_data
  , x_msg_count                  => x_msg_count
  , x_return_status              => l_return_status
  , p_org_id                     => p_org_id
  , p_outermost_lpn_id           => p_outermost_lpn_id
  , p_trip_id                    => NULL
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    fnd_message.set_name('WMS', 'WMS_CLEANUP_TEMP');
    /*Failed in cleanup program*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('CLEANUP_TEMP_RECS API failed with status E ', 'Unload_truck');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    fnd_message.set_name('WMS', 'WMS_CLEANUP_TEMP');
    /*Failed in cleanup program*/
    fnd_msg_pub.ADD;

    IF (l_debug = 1) THEN
      DEBUG('CLEANUP_TEMP_RECS failed with status U', 'Unload_truck');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1) THEN
     DEBUG('UNLOAD_TRUCK Completed successfully', 'Unload Truck');
  END IF;

  -- Commit if no errors
  COMMIT;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Execution Error in Unload_Truck:' || SUBSTR(SQLERRM, 1, 240), 'Unload_Truck');
    END IF;
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in Unload_Truck:' || SUBSTR(SQLERRM, 1, 240), 'Unload_Truck');
    END IF;
  WHEN OTHERS THEN
    --x_error_code := 9999;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('WMS_DIRECT_SHIP_PVT', 'UNLOAD_TRUCK');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in Unload_Truck:' || SUBSTR(SQLERRM, 1, 240), 'Unload_Truck');
    END IF;
END unload_truck;

PROCEDURE cleanup_temp_recs(
  x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    NUMBER
, x_msg_data         OUT NOCOPY    VARCHAR2
, p_org_id           IN            NUMBER
, p_outermost_lpn_id IN            NUMBER
, p_trip_id          IN            NUMBER
, p_dock_door_id     IN            NUMBER DEFAULT NULL
) IS
  CURSOR outermost_lpn_cur IS
    SELECT DISTINCT outermost_lpn_id
               FROM wms_shipping_transaction_temp
              WHERE organization_id = p_org_id
                AND trip_id = p_trip_id;

  CURSOR delivery_cur IS
    SELECT DISTINCT delivery_id
               FROM wms_shipping_transaction_temp
              WHERE organization_id = p_org_id
                AND trip_id = p_trip_id;

  l_outermost_lpn_id NUMBER;
  l_debug            NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  IF p_trip_id IS NOT NULL THEN
    BEGIN
      --Delete the records for the LPN
      FOR l_lpn IN outermost_lpn_cur LOOP
        l_outermost_lpn_id  := l_lpn.outermost_lpn_id;

        DELETE FROM wms_freight_cost_temp
              WHERE organization_id = p_org_id
                AND lpn_id = l_outermost_lpn_id;

        DELETE FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                             FROM wms_direct_ship_temp
                                            WHERE lpn_id = p_outermost_lpn_id);

        DELETE FROM wms_direct_ship_temp
              WHERE organization_id = p_org_id
                --AND    lpn_id = p_outermost_lpn_id;
                /* part of bug fix 2538703 */
                AND lpn_id = l_outermost_lpn_id;
      /* end of bug fix 2538703 */
      END LOOP;

      --Delete the records for the delivery
      FOR l_delivery IN delivery_cur LOOP
        DELETE FROM wms_freight_cost_temp
              WHERE organization_id = p_org_id
                AND delivery_id = l_delivery.delivery_id;
      END LOOP;

      --Delete the trip records
      DELETE FROM wms_freight_cost_temp
            WHERE organization_id = p_org_id
              AND trip_id = p_trip_id;

      DELETE FROM wms_shipping_transaction_temp
            WHERE organization_id = p_org_id
              AND trip_id = p_trip_id;

      IF (l_debug = 1) THEN
        DEBUG('Deleted temp recs for the case when trip id is not passed', 'CLEANUP_TEMP_RECS');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  ELSE
    --Delete the Shipping transaction and freight entries
    DELETE FROM wms_shipping_transaction_temp
          WHERE organization_id = p_org_id
            AND outermost_lpn_id = p_outermost_lpn_id;

    DELETE FROM wms_freight_cost_temp
          WHERE lpn_id = p_outermost_lpn_id;

    --Delete records from Mtl_Seral_Numbers_Temp if any
    BEGIN
      DELETE FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                           FROM wms_direct_ship_temp
                                          WHERE lpn_id = p_outermost_lpn_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    DELETE FROM wms_direct_ship_temp
          WHERE lpn_id = p_outermost_lpn_id;

    IF (l_debug = 1) THEN
      DEBUG('Deleted temp recs for the case when trip id is not passed', 'CLEANUP_TEMP_RECS');
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    --x_error_code := 9999;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('WMS_DIRECT_SHIP_PVT', 'CLEANUP_TEMP');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in cleanup_temp:' || SUBSTR(SQLERRM, 1, 240), 'CLEANUP_TEMP_RECS');
    END IF;
END cleanup_temp_recs;

PROCEDURE get_global_values(
  x_userid        OUT NOCOPY NUMBER
, x_logonid       OUT NOCOPY NUMBER
, x_last_upd_date OUT NOCOPY DATE
, x_current_date  OUT NOCOPY DATE
) IS
  x_progress VARCHAR2(3) := NULL;
  l_debug    NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_progress       := 10;
  x_userid         := fnd_global.user_id;
  x_progress       := 20;
  x_logonid        := fnd_global.login_id;
  x_progress       := 30;
  x_last_upd_date  := SYSDATE;
  x_progress       := 40;
  x_current_date   := SYSDATE;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Error in WMS_DIRECT_SHIP_PVT.get_global_values: ' || x_progress);
    END IF;
END get_global_values;

PROCEDURE create_resv(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, p_group_id      IN            NUMBER
, p_org_id        IN            NUMBER
) IS
BEGIN
  --bug #2782201
  NULL;
/*
  This method is no more used from I patchset. The corresponding functionality can be found in
  process_lpn and process_line.
 */
END create_resv;

PROCEDURE validate_status_lpn_contents(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, p_lpn_id        IN            NUMBER
, p_org_id        IN            NUMBER
) IS
  CURSOR lpn_contents IS
    SELECT wlpn.lpn_id
         , wlpn.subinventory_code
         , wlpn.locator_id
         , wlc.lot_number
         , wlc.inventory_item_id
         , msn.serial_number
      FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn, mtl_serial_numbers msn
     WHERE wlpn.lpn_id = wlc.parent_lpn_id
       AND msn.lpn_id(+) = wlc.parent_lpn_id
       AND msn.inventory_item_id(+) = wlc.inventory_item_id
       AND msn.current_organization_id(+) = wlc.organization_id
       /* Bug# 3119461 Without the following joins for lot and rev
       ** we would get a cartesian product */
       AND NVL(msn.lot_number(+),'#NULL#') = NVL(wlc.lot_number,'#NULL#')
       AND NVL(msn.revision(+),'#NULL#') = NVL(wlc.revision,'#NULL#')
       AND wlpn.outermost_lpn_id = p_lpn_id
       AND wlpn.organization_id = p_org_id
       AND wlc.organization_id = p_org_id;

  l_lpn_contents       lpn_contents%ROWTYPE;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(20000);
  l_trx_status_enabled NUMBER;
  l_lpn_status         VARCHAR2(1)            := 'Y';
  l_debug              NUMBER                 := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  SELECT status_control_flag
    INTO l_trx_status_enabled
    FROM mtl_transaction_types
   WHERE transaction_type_id = 52;  /* Transaction_type_id is hardcoded to 52 ..sales order staging transfer*/

  OPEN lpn_contents;

  LOOP
    FETCH lpn_contents INTO l_lpn_contents;
    EXIT WHEN lpn_contents%NOTFOUND;
    l_lpn_status  :=
      inv_material_status_grp.is_status_applicable(
        p_wms_installed              => 'TRUE'
      , p_trx_status_enabled         => l_trx_status_enabled
      , p_trx_type_id                => 52
      , p_organization_id            => p_org_id
      , p_inventory_item_id          => l_lpn_contents.inventory_item_id
      , p_sub_code                   => l_lpn_contents.subinventory_code
      , p_locator_id                 => l_lpn_contents.locator_id
      , p_lot_number                 => l_lpn_contents.lot_number
      , p_serial_number              => l_lpn_contents.serial_number
      , p_object_type                => 'A'
      );

    IF l_lpn_status <> 'Y' THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      EXIT;
    END IF;
  END LOOP;

  CLOSE lpn_contents;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('WMS_DIRECT_SHIP_PVT', 'validate_status_lpn_contents');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END validate_status_lpn_contents;

PROCEDURE update_freight_cost(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, p_lpn_id        IN            NUMBER
) IS
  CURSOR lpn_freight IS
    SELECT        ROWID
                , freight_cost_type_id
                , currency_code
                , freight_amount
                , conversion_type
             FROM wms_freight_cost_temp
            WHERE lpn_id = p_lpn_id
              AND freight_cost_id IS NULL
    FOR UPDATE OF freight_cost_id;

  CURSOR delivery_detail IS
    SELECT wdd.delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v wdd
     WHERE lpn_id = p_lpn_id
     AND released_status = 'X';  -- For LPN reuse ER : 6845650

  l_freight_cost_rec wsh_freight_costs_pub.pubfreightcostrectype;
  l_delivery_detail  delivery_detail%ROWTYPE;
  l_lpn_freight      lpn_freight%ROWTYPE;
  l_init_msg_list    VARCHAR2(1)                                 := fnd_api.g_true;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(20000);
  l_freight_cost_id  NUMBER;
  l_debug            NUMBER                                      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;
  SAVEPOINT freight_cost;
  OPEN delivery_detail;

  LOOP
    FETCH delivery_detail INTO l_delivery_detail;
    EXIT WHEN delivery_detail%NOTFOUND;
  END LOOP;

  CLOSE delivery_detail;
  OPEN lpn_freight;

  LOOP
    FETCH lpn_freight INTO l_lpn_freight;
    EXIT WHEN lpn_freight%NOTFOUND;
    l_freight_cost_rec.freight_cost_type_id  := l_lpn_freight.freight_cost_type_id;
    l_freight_cost_rec.currency_code         := l_lpn_freight.currency_code;
    l_freight_cost_rec.unit_amount           := l_lpn_freight.freight_amount;
    l_freight_cost_rec.conversion_type_code  := l_lpn_freight.conversion_type;
    l_freight_cost_rec.delivery_detail_id    := l_delivery_detail.delivery_detail_id;
    l_freight_cost_rec.action_code           := 'CREATE';
    wsh_freight_costs_pub.create_update_freight_costs(
      p_api_version_number         => 1.0
    , p_init_msg_list              => l_init_msg_list
    , p_commit                     => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_pub_freight_costs          => l_freight_cost_rec
    , p_action_code                => 'CREATE'
    , x_freight_cost_id            => l_freight_cost_id
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Create_Update_Freight_Costs API completed status E ', 'update_freight_cost');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Create_Update_Freight_Costs API completed status U ', 'update_freight_cost');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    UPDATE wms_freight_cost_temp
       SET freight_cost_id = l_freight_cost_id
         , last_update_date = SYSDATE
         , last_updated_by = fnd_global.user_id
     WHERE ROWID = l_lpn_freight.ROWID;
  END LOOP;

  CLOSE lpn_freight;

  IF (l_debug = 1) THEN
    DEBUG('Update_Freight cost Update was successful', 'update_freight_cost');
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Update_Freight cost API failed with status (E)', 'update_freight_cost');
    END IF;

    IF lpn_freight%ISOPEN THEN
      CLOSE lpn_freight;
    END IF;

    IF delivery_detail%ISOPEN THEN
      CLOSE delivery_detail;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK TO freight_cost;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF lpn_freight%ISOPEN THEN
      CLOSE lpn_freight;
    END IF;

    IF delivery_detail%ISOPEN THEN
      CLOSE delivery_detail;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('Update_Freight cost API failed with status (U)', 'update_freight_cost');
    END IF;

    ROLLBACK TO freight_cost;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    IF lpn_freight%ISOPEN THEN
      CLOSE lpn_freight;
    END IF;

    IF delivery_detail%ISOPEN THEN
      CLOSE delivery_detail;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('Update_Freight cost API failed with status (U)', 'update_freight_cost');
    END IF;

    ROLLBACK TO freight_cost;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('WMS_DIRECT_SHIP_PVT', 'update_freight_cost');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END update_freight_cost;

/******************************
* Procedure Associates serial numbers with appropriate
* Delivery lines.
* Bug No 3390432 : Fix has changed the functionality for
* Items with Serial numbers @ SO.
* Serials Numbers of Items with Serial control code 6 is picked from
* MSNT and inserted into MSN with appropriate values copied from
* MSNT. When delivery lines are split transaction temp ids are changed
* and appropriately updated into MSNT and into MSN as group mark id.
******************************/
PROCEDURE explode_delivery_details(
  x_return_status              OUT NOCOPY    VARCHAR2
, x_msg_count                  OUT NOCOPY    NUMBER
, x_msg_data                   OUT NOCOPY    VARCHAR2
--Bug No 3390432
, x_transaction_temp_id        OUT NOCOPY    NUMBER
, p_organization_id            IN            NUMBER
, p_lpn_id                     IN            NUMBER
, p_serial_number_control_code IN            NUMBER
, p_delivery_detail_id         IN            NUMBER
, p_quantity                   IN            NUMBER
, p_transaction_temp_id        IN            NUMBER DEFAULT NULL
, p_reservation_id             IN            NUMBER DEFAULT NULL
, p_last_action                IN            VARCHAR2 DEFAULT 'U'
) IS
  l_running_quantity       NUMBER;
  l_split_status           VARCHAR2(30);

  TYPE serial_tab_type IS TABLE OF VARCHAR(30)
    INDEX BY BINARY_INTEGER;

  l_serial_numbers_table   serial_tab_type;

  CURSOR c_explode_detail IS
    SELECT msnt.ROWID
         , dd.requested_quantity
         , msnt.transaction_temp_id
         , dd.delivery_detail_id
         , msnt.fm_serial_number
         , msnt.to_serial_number
         , msnt.serial_prefix
         , dd.organization_id
         , dd.inventory_item_id
         , msnt.serial_attribute_category
         , msnt.origination_date
         , msnt.c_attribute1
         , msnt.c_attribute2
         , msnt.c_attribute3
         , msnt.c_attribute4
         , msnt.c_attribute5
         , msnt.c_attribute6
         , msnt.c_attribute7
         , msnt.c_attribute8
         , msnt.c_attribute9
         , msnt.c_attribute10
         , msnt.c_attribute11
         , msnt.c_attribute12
         , msnt.c_attribute13
         , msnt.c_attribute14
         , msnt.c_attribute15
         , msnt.c_attribute16
         , msnt.c_attribute17
         , msnt.c_attribute18
         , msnt.c_attribute19
         , msnt.c_attribute20
         , msnt.d_attribute1
         , msnt.d_attribute2
         , msnt.d_attribute3
         , msnt.d_attribute4
         , msnt.d_attribute5
         , msnt.d_attribute6
         , msnt.d_attribute7
         , msnt.d_attribute8
         , msnt.d_attribute9
         , msnt.d_attribute10
         , msnt.n_attribute1
         , msnt.n_attribute2
         , msnt.n_attribute3
         , msnt.n_attribute4
         , msnt.n_attribute5
         , msnt.n_attribute6
         , msnt.n_attribute7
         , msnt.n_attribute8
         , msnt.n_attribute9
         , msnt.n_attribute10
         , msnt.status_id
         , msnt.territory_code
         , msnt.time_since_new
         , msnt.cycles_since_new
         , msnt.time_since_overhaul
         , msnt.cycles_since_overhaul
         , msnt.time_since_repair
         , msnt.cycles_since_repair
         , msnt.time_since_visit
         , msnt.cycles_since_visit
         , msnt.time_since_mark
         , msnt.cycles_since_mark
         , msnt.number_of_repairs
      FROM wsh_delivery_details_ob_grp_v dd
         , mtl_serial_numbers_temp msnt
     WHERE delivery_detail_id = p_delivery_detail_id
       AND msnt.transaction_temp_id = p_transaction_temp_id;

  l_explode_detail         c_explode_detail%ROWTYPE;
  l_rowid                  ROWID;

  CURSOR c_serials(
    p_organization_id   NUMBER
  , p_inventory_item_id NUMBER
  , p_fm_serial_number  VARCHAR2
  , p_to_serial_number  VARCHAR2
  , p_serial_length     NUMBER
  ) IS
    SELECT serial_number
      FROM mtl_serial_numbers
     WHERE current_organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND serial_number BETWEEN p_fm_serial_number AND p_to_serial_number
       AND current_status IN(1, 6)
       AND LENGTH(serial_number) = p_serial_length;

  CURSOR c_lpn_serial(p_organization_id NUMBER
                    , p_inventory_item_id NUMBER
                    , p_lpn_id NUMBER) IS
    SELECT serial_number,
           group_mark_id,
           reservation_id
      FROM mtl_serial_numbers a
     WHERE current_organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND lpn_id = p_lpn_id
       AND current_status = 3
       AND (   NVL(group_mark_id, 0) < 1
           OR (NVL(group_mark_id, 0) = p_reservation_id)
           OR (reservation_id = p_reservation_id))
       ORDER BY  a.reservation_id
               , a.serial_number;
           -- Mrana: 08/30/06: bug:5446598
           -- Added or condition for group_mark_id, to honor serial Reservations.
           -- Added order by, so that the ones with group_mark_id are picked
           -- 1st. This is important where LPN qty is > serial_quantity and only
           -- a few serials are reserved.
           -- Note: After backorder with Retain reservations, the group_mark_id on MSN might not
           -- be equal to reservation_id, that is why the check for reservation_id

  -- added for patchset i end_item_unit_validation
  CURSOR c_lpn_serial_e(p_organization_id NUMBER
                      , p_inventory_item_id NUMBER
                      , p_lpn_id NUMBER
                      , p_eiun VARCHAR2) IS
    SELECT serial_number,
           group_mark_id,
           reservation_id
      FROM mtl_serial_numbers a
     WHERE current_organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND lpn_id = p_lpn_id
       AND current_status = 3
       AND NVL(end_item_unit_number, '@@') = NVL(p_eiun, '@@')
       AND (   NVL(group_mark_id, 0) < 1
           OR (NVL(group_mark_id, 0) = p_reservation_id)
           OR (reservation_id = p_reservation_id))
       ORDER BY  a.reservation_id
               , a.serial_number;
           -- Mrana: 08/30/06: bug:5446598
           -- Added or condition for group_mark_id, to honor serial Reservations.
           -- Added order by, so that the ones with group_mark_id are picked
           -- 1st. This is important where LPN qty is > serial_quantity and only
           -- a few serials are reserved.

  l_new_delivery_detail_id NUMBER;
  l_range_serial           BOOLEAN                    := FALSE;
  l_split_const            NUMBER;
  l_real_serial_prefix     VARCHAR2(30);
  l_serial_numeric         NUMBER;
  l_serial_numeric_end     NUMBER;
  l_serial_quantity        NUMBER                     := 0;
  l_new_fm_serial          VARCHAR2(30);
  l_current_to_serial      VARCHAR2(30);
  l_serial_numeric_len     NUMBER;
  l_serial_number_current  VARCHAR2(30);
  l_loop_end               NUMBER;
  l_serial_number          VARCHAR2(30);
  j                        NUMBER;
  m                        NUMBER;
  n                        NUMBER;
  l_transaction_temp_id    NUMBER;
  l_inventory_item_id      NUMBER;
  l_return_status          VARCHAR2(1);
  l_group_mark_id          NUMBER;
  l_succes                 NUMBER;
  l_tot_line_qty           NUMBER;
  l_max_limit              BOOLEAN;
  l_end_item_unit_number   VARCHAR2(30);
  l_debug                  NUMBER                     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_proc_msg               VARCHAR2(300);
  -- Bug No 3390432
  l_serial_number_str      VARCHAR2(3000);
  l_cur_group_mark_id      NUMBER;
  l_cur_reservation_id     NUMBER;
BEGIN
  --x_return_status := fnd_api.g_ret_sts_success;

 IF (l_debug = 1) THEN
    DEBUG('p_organization_id             : ' || p_organization_id, 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_lpn_id                     : ' || p_lpn_id      , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_serial_number_control_code : ' || p_serial_number_control_code , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_delivery_detail_id         : ' || p_delivery_detail_id         , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_quantity                   : ' || p_quantity                   , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_transaction_temp_id        : ' || p_transaction_temp_id        , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_reservation_id             : ' || p_reservation_id             , 'EXPLODE_DELIVERY_DETAILS');
    DEBUG(' p_last_action                : ' || p_last_action   , 'EXPLODE_DELIVERY_DETAILS');
 END IF;

  SELECT SUM(wdd2.requested_quantity)
    INTO l_tot_line_qty
    FROM wsh_delivery_details_ob_grp_v wdd1
       , wsh_delivery_details_ob_grp_v wdd2
   WHERE wdd1.delivery_detail_id = p_delivery_detail_id
     AND wdd2.source_header_id = wdd1.source_header_id
     AND wdd2.source_line_id = wdd1.source_line_id
     AND wdd2.source_code = wdd1.source_code
     AND wdd2.released_status IN('R', 'B', 'X')
     AND wdd2.container_flag = 'N';

  IF l_tot_line_qty > p_quantity THEN
    l_max_limit  := TRUE;
  ELSE
    l_max_limit  := FALSE;
  END IF;

  -- ideally group_mark_id should be equal to transaction_temp_id
  l_group_mark_id  := p_transaction_temp_id;

  IF (l_debug = 1) THEN
    DEBUG('l_group_mark_id=' || l_group_mark_id, 'EXPLODE_DELIVERY_DETAILS');
  END IF;

  IF p_serial_number_control_code = 6 THEN
    /***********************
    * Bug No 3390432
    * Changes are made only for Items with
    * Serial control code 6 (Serial @ SO Items)
    **********************/
    l_serial_quantity  := p_quantity;

    IF (l_debug = 1) THEN
      DEBUG('P_SERIAL_CONTROL_CODE=6', 'EXPLODE_DELIVERY_DETAILS');
    END IF;

    -- Serial Number is lying in MTL_SERIAL_NUMBERS_TEMP
    IF (l_debug = 1) THEN
      DEBUG('EXPLODE delviery detail id ' || TO_CHAR(p_delivery_detail_id), 'EXPLODE_DELIVERY_DETAILS');
    END IF;

    /***********************
    * Bug No 3390432
    * Create a new Transaction Temp Id.
    * This Transaction temp id will be associated
    * with the delivery line id at the end of processing
    * We will use this Transaction temp Id as the group Mark Id aslo.
    ********************/
    SELECT mtl_material_transactions_s.NEXTVAL
      INTO x_transaction_temp_id
      FROM DUAL;

    -- Update group_mark_id to reflect newly created transaction_temp_id
    l_group_mark_id  := x_transaction_temp_id;

    x_return_status    := wsh_util_core.g_ret_sts_success;
    l_split_const      := 1;

    OPEN c_explode_detail;
    m                  := 1;

    LOOP
      FETCH c_explode_detail INTO l_explode_detail;
      EXIT WHEN c_explode_detail%NOTFOUND;

      IF (l_debug = 1) THEN
        DEBUG('Fetch the first serial number' || l_explode_detail.fm_serial_number, 'EXPLODE_DELIVERY_DETAILS');
      END IF;

      IF (l_explode_detail.fm_serial_number = l_explode_detail.to_serial_number) THEN
        IF (l_debug = 1) THEN
          DEBUG('From and To Serial Numbers are Same','EXPLODE_DELIVEY_DETAILS');
        END IF;
        UPDATE mtl_serial_numbers
           SET serial_attribute_category = l_explode_detail.serial_attribute_category
             , origination_date = l_explode_detail.origination_date
             , c_attribute1 = l_explode_detail.c_attribute1
             , c_attribute2 = l_explode_detail.c_attribute2
             , c_attribute3 = l_explode_detail.c_attribute3
             , c_attribute4 = l_explode_detail.c_attribute4
             , c_attribute5 = l_explode_detail.c_attribute5
             , c_attribute6 = l_explode_detail.c_attribute6
             , c_attribute7 = l_explode_detail.c_attribute7
             , c_attribute8 = l_explode_detail.c_attribute8
             , c_attribute9 = l_explode_detail.c_attribute9
             , c_attribute10 = l_explode_detail.c_attribute10
             , c_attribute11 = l_explode_detail.c_attribute11
             , c_attribute12 = l_explode_detail.c_attribute12
             , c_attribute13 = l_explode_detail.c_attribute13
             , c_attribute14 = l_explode_detail.c_attribute14
             , c_attribute15 = l_explode_detail.c_attribute15
             , c_attribute16 = l_explode_detail.c_attribute16
             , c_attribute17 = l_explode_detail.c_attribute17
             , c_attribute18 = l_explode_detail.c_attribute18
             , c_attribute19 = l_explode_detail.c_attribute19
             , c_attribute20 = l_explode_detail.c_attribute20
             , d_attribute1 = l_explode_detail.d_attribute1
             , d_attribute2 = l_explode_detail.d_attribute2
             , d_attribute3 = l_explode_detail.d_attribute3
             , d_attribute4 = l_explode_detail.d_attribute4
             , d_attribute5 = l_explode_detail.d_attribute5
             , d_attribute6 = l_explode_detail.d_attribute6
             , d_attribute7 = l_explode_detail.d_attribute7
             , d_attribute8 = l_explode_detail.d_attribute8
             , d_attribute9 = l_explode_detail.d_attribute9
             , d_attribute10 = l_explode_detail.d_attribute10
             , n_attribute1 = l_explode_detail.n_attribute1
             , n_attribute2 = l_explode_detail.n_attribute2
             , n_attribute3 = l_explode_detail.n_attribute3
             , n_attribute4 = l_explode_detail.n_attribute4
             , n_attribute5 = l_explode_detail.n_attribute5
             , n_attribute6 = l_explode_detail.n_attribute6
             , n_attribute7 = l_explode_detail.n_attribute7
             , n_attribute8 = l_explode_detail.n_attribute8
             , n_attribute9 = l_explode_detail.n_attribute9
             , n_attribute10 = l_explode_detail.n_attribute10
             , status_id = l_explode_detail.status_id
             , territory_code = l_explode_detail.territory_code
             , time_since_new = l_explode_detail.time_since_new
             , cycles_since_new = l_explode_detail.cycles_since_new
             , time_since_overhaul = l_explode_detail.time_since_overhaul
             , cycles_since_overhaul = l_explode_detail.cycles_since_overhaul
             , time_since_repair = l_explode_detail.time_since_repair
             , cycles_since_repair = l_explode_detail.cycles_since_repair
             , time_since_visit = l_explode_detail.time_since_visit
             , cycles_since_visit = l_explode_detail.cycles_since_visit
             , time_since_mark = l_explode_detail.time_since_mark
             , cycles_since_mark = l_explode_detail.cycles_since_mark
             , number_of_repairs = l_explode_detail.number_of_repairs
             , group_mark_id = l_group_mark_id
         WHERE current_organization_id = l_explode_detail.organization_id
           AND inventory_item_id = l_explode_detail.inventory_item_id
           AND serial_number = l_explode_detail.fm_serial_number;

        -- Copy all Processed serial number into the
        -- serial Table.
        l_serial_numbers_table(m)  := l_explode_detail.fm_serial_number;

        IF (l_debug = 1) THEN
          DEBUG(
            'After update mtl_serial_numbers with the attributes: c_attribute1 ' || l_explode_detail.c_attribute1
          , 'EXPLODE_DELIVERY_DETAILS'
          );
        END IF;

        m                          := m + 1;
        IF (l_debug = 1) THEN
          DEBUG('(1)After Updating Serial Number :'||l_serial_number||' m :'||m,'EXPLODE_DELIVEY_DETAILS');
        END IF;
      -- update req.
      ELSE
        l_range_serial        := TRUE;
        -- Get the next serial number
        --m               := m + 1;
        -- Determine the serial number prefix
        l_real_serial_prefix  := RTRIM(l_explode_detail.fm_serial_number, '0123456789');
        -- Determine the base numeric portion
        l_serial_numeric      := TO_NUMBER(SUBSTR(l_explode_detail.fm_serial_number,
                                 NVL(LENGTH(l_real_serial_prefix), 0) + 1));
        l_serial_numeric_end  := TO_NUMBER(SUBSTR(l_explode_detail.to_serial_number,
                                 NVL(LENGTH(l_real_serial_prefix), 0) + 1));

        IF (l_serial_numeric_end - l_serial_numeric) >= p_quantity THEN
          l_new_fm_serial      := l_real_serial_prefix ||(l_serial_numeric + l_serial_quantity);
          l_current_to_serial  := l_real_serial_prefix ||(l_serial_numeric + l_serial_quantity - 1);
          l_rowid              := l_explode_detail.ROWID;

          UPDATE mtl_serial_numbers_temp
             SET fm_serial_number = l_new_fm_serial
           WHERE ROWID = l_rowid;


          IF (l_debug = 1) THEN
            DEBUG( 'Creating New MSNT Record with fm_serial_number :' ||
                    l_explode_detail.fm_serial_number || ', to_serial :' ||
                    l_current_to_serial , 'EXPLODE_DELIVERY_DETAILS');
          END IF;

          l_succes             :=
            inv_trx_util_pub.insert_ser_trx(
              p_trx_tmp_id                 => l_explode_detail.transaction_temp_id
            , p_user_id                    => fnd_global.user_id
            , p_fm_ser_num                 => l_explode_detail.fm_serial_number
            , p_to_ser_num                 => l_current_to_serial
            , p_serial_attribute_category  => l_explode_detail.serial_attribute_category
            , p_orgination_date            => l_explode_detail.origination_date
            , p_c_attribute1               => l_explode_detail.c_attribute1
            , p_c_attribute2               => l_explode_detail.c_attribute2
            , p_c_attribute3               => l_explode_detail.c_attribute3
            , p_c_attribute4               => l_explode_detail.c_attribute4
            , p_c_attribute5               => l_explode_detail.c_attribute5
            , p_c_attribute6               => l_explode_detail.c_attribute6
            , p_c_attribute7               => l_explode_detail.c_attribute7
            , p_c_attribute8               => l_explode_detail.c_attribute8
            , p_c_attribute9               => l_explode_detail.c_attribute9
            , p_c_attribute10              => l_explode_detail.c_attribute10
            , p_c_attribute11              => l_explode_detail.c_attribute11
            , p_c_attribute12              => l_explode_detail.c_attribute12
            , p_c_attribute13              => l_explode_detail.c_attribute13
            , p_c_attribute14              => l_explode_detail.c_attribute14
            , p_c_attribute15              => l_explode_detail.c_attribute15
            , p_c_attribute16              => l_explode_detail.c_attribute16
            , p_c_attribute17              => l_explode_detail.c_attribute17
            , p_c_attribute18              => l_explode_detail.c_attribute18
            , p_c_attribute19              => l_explode_detail.c_attribute19
            , p_c_attribute20              => l_explode_detail.c_attribute20
            , p_d_attribute1               => l_explode_detail.d_attribute1
            , p_d_attribute2               => l_explode_detail.d_attribute2
            , p_d_attribute3               => l_explode_detail.d_attribute3
            , p_d_attribute4               => l_explode_detail.d_attribute4
            , p_d_attribute5               => l_explode_detail.d_attribute5
            , p_d_attribute6               => l_explode_detail.d_attribute6
            , p_d_attribute7               => l_explode_detail.d_attribute7
            , p_d_attribute8               => l_explode_detail.d_attribute8
            , p_d_attribute9               => l_explode_detail.d_attribute9
            , p_d_attribute10              => l_explode_detail.d_attribute10
            , p_n_attribute1               => l_explode_detail.n_attribute1
            , p_n_attribute2               => l_explode_detail.n_attribute2
            , p_n_attribute3               => l_explode_detail.n_attribute3
            , p_n_attribute4               => l_explode_detail.n_attribute4
            , p_n_attribute5               => l_explode_detail.n_attribute5
            , p_n_attribute6               => l_explode_detail.n_attribute6
            , p_n_attribute7               => l_explode_detail.n_attribute7
            , p_n_attribute8               => l_explode_detail.n_attribute8
            , p_n_attribute9               => l_explode_detail.n_attribute9
            , p_n_attribute10              => l_explode_detail.n_attribute10
            , p_status_id                  => l_explode_detail.status_id
            , p_territory_code             => l_explode_detail.territory_code
            , p_time_since_new             => l_explode_detail.time_since_new
            , p_cycles_since_new           => l_explode_detail.cycles_since_new
            , p_time_since_overhaul        => l_explode_detail.time_since_overhaul
            , p_cycles_since_overhaul      => l_explode_detail.cycles_since_overhaul
            , p_time_since_repair          => l_explode_detail.time_since_repair
            , p_cycles_since_repair        => l_explode_detail.cycles_since_repair
            , p_time_since_visit           => l_explode_detail.time_since_visit
            , p_cycles_since_visit         => l_explode_detail.cycles_since_visit
            , p_time_since_mark            => l_explode_detail.time_since_mark
            , p_cycles_since_mark          => l_explode_detail.cycles_since_mark
            , p_number_of_repairs          => l_explode_detail.number_of_repairs
            , x_proc_msg                   => l_proc_msg
            );
        ELSE
          l_serial_quantity    := l_serial_quantity +(l_serial_numeric_end - l_serial_numeric + 1);
          l_current_to_serial  := l_explode_detail.to_serial_number;
        END IF;

        -- Determine length of numeric portion
        l_serial_numeric_len  := LENGTH(SUBSTR(l_explode_detail.fm_serial_number,
                                 NVL(LENGTH(l_real_serial_prefix), 0) + 1));

        -- update the serial attributes in mtl_serial_numbers
        IF (l_debug = 1) THEN
          DEBUG(
               'Before update the mtl_serial_numbers with org '
            || TO_CHAR(l_explode_detail.organization_id)
            || ' item '
            || TO_CHAR(l_explode_detail.inventory_item_id)
            || ' serial '
            || l_explode_detail.fm_serial_number
          , 'EXPLODE_DELIVERY_DETAILS'
          );
        END IF;

        OPEN c_serials(
              l_explode_detail.organization_id
            , l_explode_detail.inventory_item_id
            , l_explode_detail.fm_serial_number
            , l_current_to_serial
            , LENGTH(l_explode_detail.fm_serial_number)
                      );

        -- skip the from serial number
        --FETCH c_serials
         --INTO l_serial_number;
        LOOP
          FETCH c_serials
           INTO l_serial_number;

          EXIT WHEN c_serials%NOTFOUND;

          -- update the serial attributes in mtl_serial_numbers
          UPDATE mtl_serial_numbers
             SET serial_attribute_category = l_explode_detail.serial_attribute_category
               , origination_date = l_explode_detail.origination_date
               , c_attribute1 = l_explode_detail.c_attribute1
               , c_attribute2 = l_explode_detail.c_attribute2
               , c_attribute3 = l_explode_detail.c_attribute3
               , c_attribute4 = l_explode_detail.c_attribute4
               , c_attribute5 = l_explode_detail.c_attribute5
               , c_attribute6 = l_explode_detail.c_attribute6
               , c_attribute7 = l_explode_detail.c_attribute7
               , c_attribute8 = l_explode_detail.c_attribute8
               , c_attribute9 = l_explode_detail.c_attribute9
               , c_attribute10 = l_explode_detail.c_attribute10
               , c_attribute11 = l_explode_detail.c_attribute11
               , c_attribute12 = l_explode_detail.c_attribute12
               , c_attribute13 = l_explode_detail.c_attribute13
               , c_attribute14 = l_explode_detail.c_attribute14
               , c_attribute15 = l_explode_detail.c_attribute15
               , c_attribute16 = l_explode_detail.c_attribute16
               , c_attribute17 = l_explode_detail.c_attribute17
               , c_attribute18 = l_explode_detail.c_attribute18
               , c_attribute19 = l_explode_detail.c_attribute19
               , c_attribute20 = l_explode_detail.c_attribute20
               , d_attribute1 = l_explode_detail.d_attribute1
               , d_attribute2 = l_explode_detail.d_attribute2
               , d_attribute3 = l_explode_detail.d_attribute3
               , d_attribute4 = l_explode_detail.d_attribute4
               , d_attribute5 = l_explode_detail.d_attribute5
               , d_attribute6 = l_explode_detail.d_attribute6
               , d_attribute7 = l_explode_detail.d_attribute7
               , d_attribute8 = l_explode_detail.d_attribute8
               , d_attribute9 = l_explode_detail.d_attribute9
               , d_attribute10 = l_explode_detail.d_attribute10
               , n_attribute1 = l_explode_detail.n_attribute1
               , n_attribute2 = l_explode_detail.n_attribute2
               , n_attribute3 = l_explode_detail.n_attribute3
               , n_attribute4 = l_explode_detail.n_attribute4
               , n_attribute5 = l_explode_detail.n_attribute5
               , n_attribute6 = l_explode_detail.n_attribute6
               , n_attribute7 = l_explode_detail.n_attribute7
               , n_attribute8 = l_explode_detail.n_attribute8
               , n_attribute9 = l_explode_detail.n_attribute9
               , n_attribute10 = l_explode_detail.n_attribute10
               , status_id = l_explode_detail.status_id
               , territory_code = l_explode_detail.territory_code
               , time_since_new = l_explode_detail.time_since_new
               , cycles_since_new = l_explode_detail.cycles_since_new
               , time_since_overhaul = l_explode_detail.time_since_overhaul
               , cycles_since_overhaul = l_explode_detail.cycles_since_overhaul
               , time_since_repair = l_explode_detail.time_since_repair
               , cycles_since_repair = l_explode_detail.cycles_since_repair
               , time_since_visit = l_explode_detail.time_since_visit
               , cycles_since_visit = l_explode_detail.cycles_since_visit
               , time_since_mark = l_explode_detail.time_since_mark
               , cycles_since_mark = l_explode_detail.cycles_since_mark
               , number_of_repairs = l_explode_detail.number_of_repairs
               , group_mark_id = l_group_mark_id
           WHERE current_organization_id = l_explode_detail.organization_id
             AND inventory_item_id = l_explode_detail.inventory_item_id
             AND serial_number = l_serial_number;

          -- Copy all Processed serial number into the
          -- serial Table.
          l_serial_numbers_table(m)  := l_serial_number;
          IF (l_debug = 1) THEN
            DEBUG('(2)After Updating Serial Number :'||l_serial_number||' m :'||m,'EXPLODE_DELIVEY_DETAILS');
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('m=' || m || ' l_serial_number= ' || l_serial_number, 'EXPLODE_DELIVERY_DETAILS');
            DEBUG(' p_quantity= ' || p_quantity, 'EXPLODE_DELIVERY_DETAILS');
          END IF;

          m                          := m + 1;

          IF (m > p_quantity) THEN
            IF (l_debug = 1) THEN
              DEBUG('(1) x_transaction_temp_id= ' || x_transaction_temp_id, 'EXPLODE_DELIVERY_DETAILS');
            END IF;

            EXIT;
          END IF;
        END LOOP;

        CLOSE c_serials;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('(2)m else =' || m || ' l_serial_number= ' || l_serial_number, 'EXPLODE_DELIVERY_DETAILS');
        DEBUG('(2)p_quantity= ' || p_quantity, 'EXPLODE_DELIVERY_DETAILS');
      END IF;

      IF (m > p_quantity) THEN
        IF (l_debug = 1) THEN
          DEBUG('(2) x_transaction_temp_id= ' || x_transaction_temp_id, 'EXPLODE_DELIVERY_DETAILS');
        END IF;

        EXIT;
      END IF;
    END LOOP;


    /***************************
    * Update all the Processed serial numbers
    * with the new already generated transaction
    * temp id
    ****************************/
    l_running_quantity  := l_serial_numbers_table.COUNT;

    FOR j IN 1 .. l_running_quantity LOOP
      UPDATE mtl_serial_numbers_temp
         SET transaction_temp_id = x_transaction_temp_id
       WHERE transaction_temp_id = p_transaction_temp_id
         AND fm_serial_number = l_serial_numbers_table(j);
    END LOOP;

    CLOSE c_explode_detail;
  ELSIF(p_serial_number_control_code IN(2, 5)) THEN
    l_serial_quantity   := p_quantity;

    /******************
    ** Bug No 3678190
    ** Set the out transaction temp value to the current transaction temp value.
    ******************/
    x_transaction_temp_id := p_transaction_temp_id;

    IF (l_debug = 1) THEN
      DEBUG('l_serial_quantity= ' || l_serial_quantity, 'EXPLODE_DELIVERY_DETAILS');
    END IF;

    SELECT inventory_item_id
      INTO l_inventory_item_id
      FROM mtl_reservations
     WHERE reservation_id = p_reservation_id;

    IF (l_debug = 1) THEN
       DEBUG('l_inventory_item_id: ' || l_inventory_item_id, 'EXPLODE_DELIVERY_DETAILS');
    END IF;
    -- added for patchset-i end_item_unit_validation
    IF (g_cross_project_allowed = 'N') THEN
       IF (g_cross_unit_allowed = 'N') THEN
        -- get the end item unit number
          SELECT oel.end_item_unit_number
            INTO l_end_item_unit_number
            FROM oe_order_lines_all oel, wsh_delivery_details_ob_grp_v wdd
           WHERE wdd.delivery_detail_id = p_delivery_detail_id
             AND wdd.source_header_id = oel.header_id
             AND wdd.source_line_id = oel.line_id;

          IF (l_debug = 1) THEN
            DEBUG('EIUN=' || l_end_item_unit_number, 'EXPLODE_DELIVERY_DETAILS');
          END IF;

          OPEN c_lpn_serial_e(p_organization_id, l_inventory_item_id, p_lpn_id, l_end_item_unit_number);
          n  := 1;

          LOOP
            FETCH c_lpn_serial_e
             INTO l_serial_numbers_table(n),
                  l_cur_group_mark_id,
                  l_cur_reservation_id;
            EXIT WHEN c_lpn_serial_e%NOTFOUND;

            IF (l_debug = 1) THEN
               DEBUG('c_lpn_serial_e Cursor (n): ' || n, 'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_serial_numbers_table(n): ' || l_serial_numbers_table(n), 'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_cur_group_mark_id: ' || l_cur_group_mark_id,'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_cur_reservation_id: ' || l_cur_reservation_id, 'EXPLODE_DELIVERY_DETAILS');
            END IF;
            IF n >= l_serial_quantity THEN
              EXIT;
            END IF;

            n  := n + 1;
          END LOOP;

          CLOSE c_lpn_serial_e;
       ELSE

          OPEN c_lpn_serial(p_organization_id, l_inventory_item_id, p_lpn_id);
          n  := 1;

          LOOP
            FETCH c_lpn_serial --INTO l_serial_numbers_table(n);
             INTO l_serial_numbers_table(n),
                  l_cur_group_mark_id,
                  l_cur_reservation_id;

            EXIT WHEN c_lpn_serial%NOTFOUND;

            IF (l_debug = 1) THEN
               DEBUG('c_lpn_serial Cursor (n): ' || n, 'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_serial_numbers_table(n): ' || l_serial_numbers_table(n), 'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_cur_group_mark_id: ' || l_cur_group_mark_id,'EXPLODE_DELIVERY_DETAILS');
               DEBUG('l_cur_reservation_id: ' || l_cur_reservation_id, 'EXPLODE_DELIVERY_DETAILS');
            END IF;
            IF n >= l_serial_quantity THEN
              EXIT;
            END IF;

            n  := n + 1;
          END LOOP;

          CLOSE c_lpn_serial;
       END IF;
    END IF;

    OPEN c_lpn_serial(p_organization_id, l_inventory_item_id, p_lpn_id);
    n                   := 1;

    LOOP
      FETCH c_lpn_serial --INTO l_serial_numbers_table(n);
       INTO l_serial_numbers_table(n),
            l_cur_group_mark_id,
            l_cur_reservation_id;

      EXIT WHEN c_lpn_serial%NOTFOUND;

       IF (l_debug = 1) THEN
          DEBUG('c_lpn_serial Cursor (n): ' || n, 'EXPLODE_DELIVERY_DETAILS');
          DEBUG('l_serial_numbers_table(n): ' || l_serial_numbers_table(n), 'EXPLODE_DELIVERY_DETAILS');
          DEBUG('l_cur_group_mark_id: ' || l_cur_group_mark_id,'EXPLODE_DELIVERY_DETAILS');
          DEBUG('l_cur_reservation_id: ' || l_cur_reservation_id, 'EXPLODE_DELIVERY_DETAILS');
       END IF;


      IF n >= l_serial_quantity THEN
        EXIT;
      END IF;

      n  := n + 1;
    END LOOP;

    CLOSE c_lpn_serial;
    n                   := 1;
    l_running_quantity  := l_serial_numbers_table.COUNT;


    WHILE(l_running_quantity >= 1)
    LOOP
      IF (l_debug = 1) THEN
        DEBUG('Marking serial number ' || l_serial_numbers_table(n), 'EXPLODE_DELIVERY_DETAILS');
      END IF;

     /* 5506223: Because of serial reservations, the following API call to
      *      mark the Serial numbers will not work. It does not allow already
      *      reserved (which are already marked) serials to be remarked with the
      *      new mark id of Transaction_temp_id of MSNT
      serial_check.inv_mark_serial(
        from_serial_number           => l_serial_numbers_table(n)
      , to_serial_number             => l_serial_numbers_table(n)
      , item_id                      => l_inventory_item_id
      , org_id                       => p_organization_id
      , hdr_id                       => l_group_mark_id
      , temp_id                      => NULL
      , lot_temp_id                  => NULL
      , success                      => l_succes
      );

      IF l_succes < 1 THEN
        IF (l_debug = 1) THEN
          DEBUG('inv_mark_serial ended with errors (E) ', 'EXPLODE_DELIVERY_DETAILS');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF; */

      /* 5506223: Because of the above, using direct update to MSN to set the
       *          group_mark_id */

      BEGIN
         UPDATE mtl_serial_numbers
            SET group_mark_id     = l_group_mark_id
          WHERE inventory_item_id = l_inventory_item_id
            AND serial_number     = l_serial_numbers_table(n)
            AND current_organization_id = p_organization_id;

         IF SQL%NOTFOUND THEN
            IF (l_debug = 1) THEN
              DEBUG( 'Error finding serial to mark : '|| l_serial_numbers_table(n) ,
                     'EXPLODE_DELIVERY_DETAILS');
              DEBUG( 'l_inventory_item_id : '|| l_inventory_item_id ,
                     'EXPLODE_DELIVERY_DETAILS');
              DEBUG( 'p_organization_id : '|| p_organization_id ,
                     'EXPLODE_DELIVERY_DETAILS');
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END ;
      IF (l_debug = 1) THEN
        DEBUG( 'inserting serials ' || l_serial_numbers_table(n) || ' into msnt WITH temp_id ='
              || p_transaction_temp_id , 'EXPLODE_DELIVERY_DETAILS');
      END IF;

      l_succes            :=
        inv_trx_util_pub.insert_ser_trx(
          p_trx_tmp_id                 => p_transaction_temp_id
        , p_user_id                    => fnd_global.user_id
        , p_fm_ser_num                 => l_serial_numbers_table(n)
        , p_to_ser_num                 => l_serial_numbers_table(n)
        , x_proc_msg                   => l_proc_msg
        );

      IF (l_succes < 0) THEN
        IF (l_debug = 1) THEN
          DEBUG('insert_ser_trx ended with errors ' || l_proc_msg, 'EXPLODE_DELIVERY_DETAILS');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('l_running_quantity (while_loop)= ' || l_running_quantity, 'EXPLODE_DELIVERY_DETAILS');
      END IF;

      l_running_quantity  := l_running_quantity - 1;
      n                   := n + 1;
    END LOOP;
  END IF; -- Serial Control Code If
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    x_return_status  := wsh_util_core.g_ret_sts_unexp_error;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_ACTIONS.EXPLODE_DELIVERY_DETAILS');
END explode_delivery_details;


/* Function overship_staged_lines
splits a staged line to overship the quantity
and returns the delivery details of the overshipped Lines
Added bug4128854*/

FUNCTION Overship_Staged_Lines(
p_source_header_id IN NUMBER,
p_source_line_id IN NUMBER,
p_lpn_id IN NUMBER,
p_mso_id IN NUMBER,
p_organization_id IN NUMBER,
p_cont_instance_id IN NUMBER,
p_dock_door_id IN NUMBER,
x_return_status   OUT NOCOPY    VARCHAR2,
x_msg_count       OUT NOCOPY    NUMBER,
x_msg_data        OUT NOCOPY    VARCHAR2)
RETURN DELIVERY_DETAIL_TAB IS

--Local Variables
l_reservation_record         inv_reservation_global.mtl_reservation_rec_type;
l_delivery_detail_tab        DELIVERY_DETAIL_TAB;
l_mtl_reservation_tbl        inv_reservation_global.mtl_reservation_tbl_type;
l_mtl_reservation_tbl_count  NUMBER;
l_detail_tab                 WSH_UTIL_CORE.ID_TAB_TYPE;
l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(3000);
l_msg_count                  NUMBER;
l_error_code                 VARCHAR2(20000);
l_debug                      NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_transaction_temp_id        NUMBER;
l_shipping_attr              WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
l_shipping_attr_tab          wsh_interface.changedattributetabtype;
l_delivery_detail_id         NUMBER;
l_picked_qty                 NUMBER;
l_shipped_qty                NUMBER;
l_primary_uom_code           VARCHAR2(3);
l_lot_control_code           NUMBER;
l_serial_number_control_code NUMBER;
l_commit                     VARCHAR2(1) := fnd_api.g_false;
l_new_delivery_detail_id     NUMBER;
l_dummy_num_var              NUMBER;
l_init_msg_list              VARCHAR2(1) := fnd_api.g_false;
l_trip_id                    NUMBER;
BEGIN
       x_return_status  := fnd_api.g_ret_sts_success;
      /*Query Reservations for LPN to be staged*/

      IF (l_debug = 1) THEN
         DEBUG('Inside Overship_Staged_Lines ', 'Overship Staged Lines');
         DEBUG('Source Header: '||p_source_header_id || ' : Line : ' ||
                                  p_source_line_id, 'Overship Staged Lines');
         DEBUG('p_lpn_id: '||p_lpn_id, 'Overship Staged Lines');
         DEBUG('p_mso_id: '||p_mso_id, 'Overship Staged Lines');
         DEBUG('p_organization_id: '||p_organization_id, 'Overship Staged Lines');
         DEBUG('p_cont_instance_id: '||p_cont_instance_id, 'Overship Staged Lines');
         DEBUG('p_dock_door_id: '||p_dock_door_id, 'Overship Staged Lines');
      END IF;


      l_reservation_record.demand_source_header_id  := p_mso_id;
      l_reservation_record.demand_source_line_id    := p_source_line_id;
      l_reservation_record.lpn_id                   := p_lpn_id;
      l_reservation_record.supply_source_type_id    := inv_reservation_global.g_source_type_inv;

      IF (l_debug = 1) THEN
        DEBUG('Before call to reservation for LPN ID'||p_lpn_id, 'Overship Staged Lines');
      END IF;

      inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_reservation_record
        , p_lock_records               => fnd_api.g_false
        , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
        , x_error_code                 => l_error_code
        );

      IF (l_debug = 1) THEN
        DEBUG('After call to reservation for LPN ID'||p_lpn_id ||
              'records retrived'||l_mtl_reservation_tbl_count, 'Overship Staged Lines');
      END IF;


      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
            DEBUG('Validation error during query of Reservations ' || p_source_header_id ||
                  ' ' || p_source_line_id, 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
            DEBUG('Unexpected error during query of Reservations ' || p_source_header_id ||
                  ' ' || p_source_line_id, 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /*Now we have all reservations for the LPN for this sales order and line
        which donot have any open WDDs left, This means we need to split a staged WDD*/

      FOR i in 1..l_mtl_reservation_tbl_count LOOP

      /*Find the parent delivery detail to split from (since all details are staged already)*/
          SELECT  wds.transaction_temp_id
                , wdd.delivery_detail_id
                , wdd.picked_quantity
                , wdd.shipped_quantity
                , msi.primary_uom_code
                , msi.lot_control_code
                , msi.serial_number_control_code
          INTO  l_transaction_temp_id
                , l_delivery_detail_id
                , l_picked_qty
                , l_shipped_qty
                , l_primary_uom_code
                , l_lot_control_code
                , l_serial_number_control_code
          FROM wms_direct_ship_temp wds,
               wsh_delivery_details wdd,
               mtl_system_items msi
          WHERE wds.organization_id = p_organization_id
            AND wds.lpn_id = p_lpn_id
            AND wds.order_header_id = p_source_header_id
            AND wds.order_line_id = p_source_line_id
            AND wdd.organization_id = p_organization_id
            AND wdd.source_header_id = wds.order_header_id
            AND wdd.source_line_id = wds.order_line_id
            AND msi.organization_id = p_organization_id
            AND msi.inventory_item_id = wdd.inventory_item_id
            AND wdd.released_status = 'Y'
            AND wdd.container_flag = 'N'
            --AND wdd.split_from_delivery_detail_id is null
            AND rownum =1;

     /* Now we have the delivery_Detail to split so first update the quantity from
        Reservation on the wdd and then split from it*/

      DEBUG('Before calling Update_shipping_attributes to update qty'||l_picked_qty, 'Overship Staged Lines');
      l_shipping_attr_tab.DELETE;  --Added delete to prevent usage from previous loop bug4128854
      l_shipping_attr_tab(1).delivery_detail_id := l_delivery_detail_id;
      l_shipping_attr_tab(1).action_flag      := 'U';
      l_shipping_attr_tab(1).released_status  := 'R';

      wsh_interface.update_shipping_attributes(p_source_code => 'INV',
       p_changed_attributes         => l_shipping_attr_tab
      ,x_return_status              => l_return_status);

      l_shipping_attr_tab.DELETE;
      l_shipping_attr_tab(1).picked_quantity    := l_picked_qty + l_mtl_reservation_tbl(i).reservation_quantity;
      l_shipping_attr_tab(1).shipped_quantity    := l_picked_qty + l_mtl_reservation_tbl(i).reservation_quantity;
      l_shipping_attr_tab(1).delivery_detail_id := l_delivery_detail_id;
      l_shipping_attr_tab(1).action_flag      := 'U';
      l_shipping_attr_tab(1).released_status  := 'Y';
      DEBUG('Before calling Update_shipping_attributes to update qty'||
             l_shipping_attr_tab(1).shipped_quantity , 'Overship Staged Lines');

      wsh_interface.update_shipping_attributes(p_source_code => 'INV',
       p_changed_attributes         => l_shipping_attr_tab
      ,x_return_status              => l_return_status);

      IF (l_debug = 1) THEN
        DEBUG('After calling Update_shipping_attributes', 'Overship Staged Lines');
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
          DEBUG('Return error from update shipping attributes 2', 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Return unexpected error from update shipping attributes', 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = 'S' THEN
        IF (l_debug = 1) THEN
          DEBUG('Shipping attributes updated successfully','Overship Staged Lines');
        END IF;
      END IF;

     /*At this point we need to split from this delivery detail*/
      DEBUG('Before Split Line'||l_delivery_Detail_id,'Overship Staged Lines');

      WSH_DELIVERY_DETAILS_PUB.split_line
        (p_api_version    => 1.0,
         p_init_msg_list  => fnd_api.g_false,
         p_commit         => fnd_api.g_false,
         x_return_status  => l_return_status,
         x_msg_count      => l_msg_count,
         x_msg_data       => l_msg_data,
         p_from_detail_id => l_delivery_detail_id,
         x_new_detail_id  => l_new_delivery_detail_id,
         x_split_quantity => l_mtl_reservation_tbl(i).reservation_quantity,
         x_split_quantity2=> l_dummy_num_var);

       DEBUG('After Split Line'||l_new_delivery_Detail_id,'Overship Staged Lines');

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
            DEBUG('Return error from split_delivery_details ', 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
            DEBUG('Return unexpected error from split_delivery_details', 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

             /*Unassign from old container*/

      WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont(
        P_DETAIL_ID     => l_new_delivery_detail_id,
        X_RETURN_STATUS => l_return_status);

        DEBUG('After Unassign'|| l_return_status, 'Overship Staged Lines');

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
             DEBUG('Error Unassign_Detail_from_Cont'|| l_return_status, 'Overship Staged Lines');
         END IF;
         FND_MESSAGE.SET_NAME('INV', 'INV_UNASSIGN_DEL_FAILURE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;



      /*Now update the new delivery_Detail with correct attributes*/
      l_shipping_attr_tab.DELETE;
      l_shipping_attr_tab(1).delivery_detail_id   := l_new_delivery_detail_id;
      l_shipping_attr_tab(1).lot_number           := l_mtl_reservation_tbl(i).lot_number;
      l_shipping_attr_tab(1).revision             := l_mtl_reservation_tbl(i).revision;
      l_shipping_attr_tab(1).subinventory         := l_mtl_reservation_tbl(i).subinventory_code;
      l_shipping_attr_tab(1).locator_id           := l_mtl_reservation_tbl(i).locator_id;
      l_shipping_attr_tab(1).ship_from_org_id     := l_mtl_reservation_tbl(i).organization_id;
      l_shipping_attr_tab(1).transfer_lpn_id      := l_mtl_reservation_tbl(i).lpn_id;
      l_shipping_attr_tab(1).picked_quantity      := l_mtl_reservation_tbl(i).reservation_quantity;
      l_shipping_attr_tab(1).shipped_quantity     := l_mtl_reservation_tbl(i).reservation_quantity;
      l_shipping_attr_tab(1).action_flag      := 'U';
      l_shipping_attr_tab(1).released_status  := 'Y';

      IF (l_debug = 1) THEN
         DEBUG('l_shipping_attr_tab(1).delivery_detail_id   '||
                l_shipping_attr_tab(1).delivery_detail_id   ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).lot_number           '||
                l_shipping_attr_tab(1).lot_number           ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).revision             '||
                l_shipping_attr_tab(1).revision             ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).subinventory         '||
                l_shipping_attr_tab(1).subinventory         ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).locator_id           '||
                l_shipping_attr_tab(1).locator_id           ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).ship_from_org_id     '||
                l_shipping_attr_tab(1).ship_from_org_id     ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).transfer_lpn_id      '||
                l_shipping_attr_tab(1).transfer_lpn_id      ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).picked_quantity      '||
                l_shipping_attr_tab(1).picked_quantity      ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).shipped_quantity     '||
                l_shipping_attr_tab(1).shipped_quantity     ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).action_flag      '||
                l_shipping_attr_tab(1).action_flag      ,'Overship Staged Lines');
         DEBUG('l_shipping_attr_tab(1).released_status  '||
                l_shipping_attr_tab(1).released_status  ,'Overship Staged Lines');
      END IF;
      /*Verify the Action Flag*/

      wsh_interface.update_shipping_attributes(
        p_source_code                => 'INV',
        p_changed_attributes         => l_shipping_attr_tab,
        x_return_status              => l_return_status);

      IF (l_debug = 1) THEN
        DEBUG('After update shipping attributes', 'Overship Staged Lines');
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
            DEBUG('Return error from update shipping attributes', 'Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
            DEBUG('Return unexpected error from update shipping attributes','Overship Staged Lines');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      SELECT wds.ORGANIZATION_ID
         ,WDS.DOCK_DOOR_ID
         ,WDS.LPN_ID
         ,WDS.ORDER_HEADER_ID
         ,WDS.ORDER_LINE_ID
         ,WDS.LINE_ITEM_ID
         ,WDS.TRANSACTION_TEMP_ID
         ,WDD.DELIVERY_DETAIL_ID
         ,DECODE(WDD.REQUESTED_QUANTITY_UOM,MSI.PRIMARY_UOM_CODE
                                            ,WDD.REQUESTED_QUANTITY
                                            ,GREATEST(INV_CONVERT.INV_UM_CONVERT(
                                                             null
                                                            ,null
                                                            ,WDD.REQUESTED_QUANTITY
                                                            ,WDD.REQUESTED_QUANTITY_UOM
                                                            ,MSI.PRIMARY_UOM_CODE
                                                            ,null
                                                           ,null),0)) REQUESTED_QUANTITY
        ,MSI.PRIMARY_UOM_CODE
        ,MSI.LOT_CONTROL_CODE
        ,MSI.SERIAL_NUMBER_CONTROL_CODE
    INTO l_delivery_detail_tab(i).ORGANIZATION_ID
         ,l_delivery_detail_tab(i).DOCK_DOOR_ID
         ,l_delivery_detail_tab(i).LPN_ID
         ,l_delivery_detail_tab(i).ORDER_HEADER_ID
         ,l_delivery_detail_tab(i).ORDER_LINE_ID
         ,l_delivery_detail_tab(i).LINE_ITEM_ID
         ,l_delivery_detail_tab(i).TRANSACTION_TEMP_ID
         ,l_delivery_detail_tab(i).DELIVERY_DETAIL_ID
         ,l_delivery_detail_tab(i).REQUESTED_QUANTITY
         ,l_delivery_detail_tab(i).PRIMARY_UOM_CODE
         ,l_delivery_detail_tab(i).LOT_CONTROL_CODE
         ,l_delivery_detail_tab(i).SERIAL_NUMBER_CONTROL_CODE
    FROM WMS_DIRECT_SHIP_TEMP WDS,
         WSH_DELIVERY_DETAILS WDD,
         MTL_SYSTEM_ITEMS MSI
    WHERE WDS.ORGANIZATION_ID           = p_organization_id
       AND WDS.lpn_id                   = p_lpn_id
       AND WDS.ORDER_HEADER_ID          = p_source_header_id
       AND WDS.ORDER_LINE_ID            = p_source_line_id
       AND WDD.ORGANIZATION_ID          = p_organization_id
       AND WDD.SOURCE_HEADER_ID         = WDS.ORDER_HEADER_ID
       AND WDD.SOURCE_LINE_ID           = WDS.ORDER_LINE_ID
       AND MSI.ORGANIZATION_ID          = p_organization_id
       AND MSI.INVENTORY_ITEM_ID        = WDD.INVENTORY_ITEM_ID
       AND WDD.delivery_detail_id       = l_new_delivery_detail_id
       AND rownum = 1
    ORDER BY WDS.LINE_ITEM_ID;
    END LOOP;
    RETURN l_delivery_detail_tab;
END overship_staged_lines;

PROCEDURE stage_lpns(
  x_return_status   OUT NOCOPY    VARCHAR2
, x_msg_count       OUT NOCOPY    NUMBER
, x_msg_data        OUT NOCOPY    VARCHAR2
, p_group_id        IN            NUMBER
, p_organization_id IN            NUMBER
, p_dock_door_id    IN            NUMBER
) IS
  CURSOR outer_lpn IS
    SELECT DISTINCT lpn_id
               FROM wms_direct_ship_temp
              WHERE GROUP_ID = p_group_id
                AND organization_id = p_organization_id
                AND dock_door_id = p_dock_door_id;

  CURSOR inner_lpn(p_lpn_id NUMBER) IS
    SELECT lpn_id
      FROM wms_license_plate_numbers
     WHERE outermost_lpn_id = p_lpn_id;

  CURSOR stage_lines(p_lpn_id NUMBER) IS
    SELECT wds.order_header_id
         , wds.order_line_id
         , sub.reservable_type
         , msi.reservable_type
         , msi.lot_control_code
         , msi.serial_number_control_code
      FROM wms_direct_ship_temp wds
         , wms_license_plate_numbers wlpn
         , mtl_secondary_inventories sub
         , mtl_system_items msi
     WHERE wds.GROUP_ID = p_group_id
       AND wds.organization_id = p_organization_id
       AND wds.dock_door_id = p_dock_door_id
       AND wds.lpn_id = p_lpn_id
       AND wlpn.lpn_id = wds.lpn_id
       AND sub.organization_id = wds.organization_id
       AND wlpn.subinventory_code = sub.secondary_inventory_name
       AND msi.organization_id = wds.organization_id
       AND msi.inventory_item_id = wds.line_item_id;

  CURSOR loaded_trips(p_organization_id NUMBER, p_dock_door_id NUMBER) IS
    SELECT DISTINCT trip_id
               FROM wms_shipping_transaction_temp
              WHERE organization_id = p_organization_id
                AND dock_door_id = p_dock_door_id
                AND dock_appoint_flag = 'N'
                AND direct_ship_flag = 'Y';

  CURSOR trip_for_delivery(p_organization_id NUMBER, p_dock_door_id NUMBER) IS
    SELECT DISTINCT delivery_id
               FROM wms_shipping_transaction_temp
              WHERE organization_id = p_organization_id
                AND dock_door_id = p_dock_door_id
                AND NVL(trip_id, 0) = 0
                AND direct_ship_flag = 'Y';

  CURSOR stage_delivery_detail(p_organization_id NUMBER, p_lpn_id NUMBER) IS
    SELECT wdd.delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v wdd
         , wms_direct_ship_temp wds
     WHERE wds.organization_id = p_organization_id
       AND wds.lpn_id = p_lpn_id
       AND wdd.source_header_id = wds.order_header_id
       AND wdd.source_line_id = wds.order_line_id
       AND wdd.released_status IN('R', 'B')
       AND wdd.picked_quantity > 0;

  /* Bug:2463967 */
  CURSOR delete_details(p_outermost_lpn_id NUMBER) IS
    SELECT delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v wdd
         , wms_license_plate_numbers lpn
     WHERE lpn.outermost_lpn_id = p_outermost_lpn_id
       AND lpn.lpn_id = wdd.lpn_id
       AND wdd.released_status = 'X'; -- For LPN reuse ER : 6845650

  -- bug 4306508
  CURSOR lpn_heirarchy(p_outermost_lpn_id NUMBER) IS
     SELECT lpn_id
       FROM wms_license_plate_numbers
       WHERE outermost_lpn_id = p_outermost_lpn_id
       ORDER BY lpn_id;


  CURSOR c_Get_OTM_flag(v_del_id NUMBER) IS
     SELECT ignore_for_planning, tms_interface_flag
       FROM wsh_new_deliveries_ob_grp_v
       WHERE delivery_id = v_del_id ;

  l_delivery_detail_tab        delivery_detail_tab;
  l_new_delivery_detail_id     NUMBER;
  l_dummy_num_var              NUMBER;

  /* For query reservations */
  l_reservation_record         inv_reservation_global.mtl_reservation_rec_type;
  l_reservation_tbl            inv_reservation_global.mtl_reservation_tbl_type; -- bug 4306508
  l_mtl_reservation_tbl        inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_reservation_tbl_count  NUMBER;
  l_reservation_exists_flag    VARCHAR2(1);
  l_reserved_lpn               NUMBER;
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(20000);
  l_error_code                 NUMBER;
  l_dummy_sn                   inv_reservation_global.serial_number_tbl_type;
  l_outer_lpn                  outer_lpn%ROWTYPE;
  l_inner_lpn                  inner_lpn%ROWTYPE;
  l_mso_id                     NUMBER;
  l_outermost_lpn_id           NUMBER;
  /* For quantity tree declaration */
  l_return_msg                 VARCHAR2(20000);
  l_header_id                  NUMBER;
  l_line_id                    NUMBER;
  l_sub_reservable             NUMBER;
  l_item_reservable            NUMBER;
  l_lot_control_code           NUMBER;
  l_serial_number_control_code NUMBER;
  l_shipping_attr              wsh_interface.changedattributetabtype;
  l_invpcinrectype             wsh_integration.invpcinrectype;
  l_rsv_index                  NUMBER;
  l_rsv_qty                    NUMBER;
  i                            NUMBER;
  l_return                     NUMBER;
  /* Auto Create Trip  */
  l_cont_instance_id           NUMBER;
  l_cont_name                  VARCHAR2(50);
  l_delivery_detail_id         NUMBER;
  l_delivery_id                NUMBER;
  l_delivery_tab               wsh_util_core.id_tab_type;

  l_trip_id                    NUMBER;
  l_trip_name                  VARCHAR2(30);
  /* Patchset I */
  l_last_del_index             NUMBER;
  l_lpn_count                  NUMBER; --Added bug 4212476

  --MR:Added for 4440809
  l_total_lpn_rsv_qty          NUMBER;
  l_processing_staged_Lines    VARCHAR2(1);

  /* Auto Create Deliveries for Delivery Details that has no delivery associated yet */
  /* Check if there is any trip loaded on the dock door, if yes assign new deliveries to it
     else check if existing delivery_details have a trip already associated else
     create new trip
       */

   l_action_prms      wsh_interface_ext_grp.del_action_parameters_rectype;
   l_delivery_id_tab  wsh_util_core.id_tab_type;
   l_delivery_out_rec wsh_interface_ext_grp.del_action_out_rec_type;

   l_debug                      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   -- Bug# 3464013: Replaced the static cursor with dynamic ref cursor
   l_sql_query                  VARCHAR2(10000);
   TYPE delivery_details_type IS REF CURSOR;
   delivery_details           delivery_details_type;

   /******************************
   * Creating an out Parameter in order to comply with the
   * New Signature of Explode_delivery_details
   *******************************/
     l_out_transaction_temp_id    NUMBER;


   /**********************************
   * variable to hold the ignore_for_planning flag of WDD.
   * Added for g-log changes
   **********************************/
   l_ignore_for_planning        wsh_delivery_details.ignore_for_planning%type;
   l_tms_interface_flag         wsh_new_deliveries.TMS_INTERFACE_FLAG%type;



BEGIN

  IF (l_debug = 1) THEN
     DEBUG('Inside Stage LPNs..: ' , 'STAGE_LPN');
     DEBUG('p_group_id: ' || p_group_id , 'STAGE_LPN');
     DEBUG('p_organization_id: ' || p_organization_id , 'STAGE_LPN');
     DEBUG('p_dock_door_id: ' || p_dock_door_id , 'STAGE_LPN');
  END IF;

  --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
  l_invpcinrectype.transaction_id       := NULL;
  l_invpcinrectype.transaction_temp_id  := NULL;
  l_invpcinrectype.source_code          := 'INV';
  l_invpcinrectype.api_version_number   := 1.0;
  OPEN outer_lpn;

  LOOP
    FETCH outer_lpn INTO l_outer_lpn;
    EXIT WHEN outer_lpn%NOTFOUND;
    wms_direct_ship_pvt.create_update_containers(
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_org_id                     => p_organization_id
    , p_outermost_lpn_id           => l_outer_lpn.lpn_id
    );

    IF l_return_status IN(fnd_api.g_ret_sts_error) THEN
      IF (l_debug = 1) THEN
        DEBUG('create_update_containers API failed with status E ', 'STAGE_LPN');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        DEBUG('create_update_containers failed with status U', 'STAGE_LPN');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    SELECT delivery_detail_id
      INTO l_cont_instance_id
      FROM wsh_delivery_details_ob_grp_v
     WHERE lpn_id = l_outer_lpn.lpn_id
     AND released_status = 'X';   -- For LPN reuse ER : 6845650

    SELECT wdd.delivery_detail_id
      INTO l_delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v wdd, wms_direct_ship_temp wds
     WHERE wds.organization_id = p_organization_id
       AND wds.lpn_id = l_outer_lpn.lpn_id
       AND wdd.source_header_id = wds.order_header_id
       AND wdd.source_line_id = wds.order_line_id
       AND wdd.released_status IN('R', 'B', 'Y') --Added 'Y' bug4128854
       AND ROWNUM = 1;

    IF (l_debug = 1) THEN
      DEBUG('The delivery_detail_id for the lpn_Id is ' || l_cont_instance_id, 'STAGE_LPN');
      DEBUG('The delivery_detail_id for the first line is ' || l_delivery_detail_id, 'STAGE_LPN');
    END IF;

    wms_direct_ship_pvt.container_nesting(
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_organization_id            => p_organization_id
    , p_outermost_lpn_id           => l_outer_lpn.lpn_id
    , p_action_code                => 'PACK');

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      IF (l_debug = 1) THEN
        DEBUG('container nesting API failed for outermost_lpn_id ' || l_outer_lpn.lpn_id, 'stage_lpns');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        DEBUG('container nesting API failed with unexpected errors for outermost_lpn_id '
               || l_outer_lpn.lpn_id, 'stage_lpns');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Container nesting completed', 'xxxx');
    END IF;

    wsh_container_actions.update_cont_hierarchy(
      p_del_detail_id              => l_delivery_detail_id
    , p_delivery_id                => NULL
    , p_container_instance_id      => l_cont_instance_id
    , x_return_status              => l_return_status
    );

    IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
      fnd_message.set_name('WSH', 'WSH_CONT_UPD_ATTR_ERROR');
      fnd_message.set_token('CONT_NAME', l_cont_name);
    --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('The Update container_Hierarchy was successful for outer-lpn ' || l_outer_lpn.lpn_id, 'STAGE_LPN');
    END IF;
  END LOOP;

  CLOSE outer_lpn;


  OPEN outer_lpn;

  LOOP
    IF (l_debug = 1) THEN
      DEBUG('Open outer lpn loop', 'Stage_LPNS');
    END IF;

    FETCH outer_lpn INTO l_outer_lpn;
    EXIT WHEN outer_lpn%NOTFOUND;
    OPEN stage_lines(l_outer_lpn.lpn_id);

    IF (l_debug = 1) THEN
      DEBUG('Open stage loop LPN ID: ' || l_outer_lpn.lpn_id, 'Stage_LPNS');
    END IF;

    LOOP
      FETCH stage_lines
      INTO l_header_id
         , l_line_id
         , l_sub_reservable
         , l_item_reservable
         , l_lot_control_code
         , l_serial_number_control_code;
      EXIT WHEN stage_lines%NOTFOUND;

      IF (l_debug = 1) THEN
        DEBUG('Stage Line Loop Line_ID :' || l_line_id, 'Stage_LPNS');
      END IF;

      IF (l_sub_reservable = 1
          AND l_item_reservable = 1) THEN
        l_mso_id                                       := inv_salesorder.get_salesorder_for_oeheader(l_header_id);
        l_reservation_record.demand_source_header_id   := l_mso_id;
        l_reservation_record.demand_source_line_id     := l_line_id;
        l_reservation_record.demand_source_line_detail := NULL;

        --  bug 4306508 : need to handle the case for nested LPNs too
        l_mtl_reservation_tbl.DELETE;
        FOR l_lpn_rec IN lpn_heirarchy(l_outer_lpn.lpn_id) LOOP

           l_reservation_record.lpn_id                   := l_lpn_rec.lpn_id;
           -- bug 4271408
           --l_reservation_record.lpn_id                   := l_outer_lpn.lpn_id;

           IF (l_debug = 1) THEN
              DEBUG('Before call to reservation demand_source_line_id ' || l_line_id, 'STAGE_LPNs');
           END IF;

           inv_reservation_pub.query_reservation
             (p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_query_input                => l_reservation_record
              , p_lock_records               => fnd_api.g_false
              , x_mtl_reservation_tbl        => l_reservation_tbl
              , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
              , x_error_code                 => l_error_code);

           IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('Validation error during query of Reservations ' || l_header_id
                        || ' ' || l_line_id, 'STAGE_LPNS');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('Unexpected error during query of Reservations ' || l_header_id || ' '
                         || l_line_id, 'STAGE_LPNS');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           FOR i IN 1..l_mtl_reservation_tbl_count LOOP

              l_mtl_reservation_tbl(l_mtl_reservation_tbl.COUNT + 1) := l_reservation_tbl(i);

           END LOOP;

        END LOOP;

        l_mtl_reservation_tbl_count := l_mtl_reservation_tbl.COUNT;

      END IF;


      /* For each delivery details get the Reservation details and stage the delivery lines */
      IF (l_debug = 1) THEN
        DEBUG('After call to reservation No of Rsv Records: ' || l_mtl_reservation_tbl_count, 'STAGE_LPNs');
      END IF;

      i                 := 1;
      -- Bug# 3464013: Replaced the static cursor with dynamic ref cursor
      l_sql_query :=
        '    SELECT   wds.organization_id ' ||
        '           , wds.dock_door_id ' ||
        '           , wds.lpn_id ' ||
        '           , wds.order_header_id ' ||
        '           , wds.order_line_id ' ||
        '           , wds.line_item_id ' ||
        '           , wds.transaction_temp_id ' ||
        '           , wdd.delivery_detail_id ' ||
        '           , DECODE( ' ||
        '               wdd.requested_quantity_uom ' ||
        '             , msi.primary_uom_code, wdd.requested_quantity ' ||
        '             , GREATEST( ' ||
        '                        inv_convert.inv_um_convert(NULL, ' ||
        '                        NULL, wdd.requested_quantity, wdd.requested_quantity_uom, ' ||
        '                        msi.primary_uom_code, NULL , NULL) ' ||
        '                     , 0 )) requested_quantity ' ||
        '           , msi.primary_uom_code ' ||
        '           , msi.lot_control_code ' ||
        '           , msi.serial_number_control_code ' ||
        '           , msi.inventory_item_id ';

        IF (G_WMS_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL) THEN
          l_sql_query := l_sql_query || '           , msi.ont_pricing_qty_source ';
        ELSE
          l_sql_query := l_sql_query || '           , NULL ont_pricing_qty_source ';
        END IF;

    l_sql_query := l_sql_query ||
        '        FROM wms_direct_ship_temp wds, ' ||
        '             wsh_delivery_details_ob_grp_v wdd, ' ||
        '             mtl_system_items msi ' ||
        '       WHERE wds.organization_id = :p_organization_id ' ||
        '         AND wds.lpn_id = :p_lpn_id ' ||
        '         AND wds.order_header_id = :p_order_header_id ' ||
        '         AND wds.order_line_id = :p_order_line_id ' ||
        '         AND wdd.organization_id = :p_organization_id ' ||
        '         AND wdd.source_header_id = wds.order_header_id ' ||
        '         AND wdd.source_line_id = wds.order_line_id ' ||
        '         AND msi.organization_id = :p_organization_id ' ||
        '         AND msi.inventory_item_id = wdd.inventory_item_id ' ||
        '         AND wdd.released_status IN (''B'', ''R'') ' ||
        '         AND wdd.container_flag = ''N'' ' ||
        '    ORDER BY wds.line_item_id';

      -- OPEN delivery_details(l_outer_lpn.lpn_id, l_header_id, l_line_id);
      OPEN delivery_details FOR l_sql_query
        USING p_organization_id,
              l_outer_lpn.lpn_id,
              l_header_id,
              l_line_id,
              p_organization_id,
              p_organization_id;

      LOOP
        FETCH delivery_details
         INTO l_delivery_detail_tab(i).organization_id
            , l_delivery_detail_tab(i).dock_door_id
            , l_delivery_detail_tab(i).lpn_id
            , l_delivery_detail_tab(i).order_header_id
            , l_delivery_detail_tab(i).order_line_id
            , l_delivery_detail_tab(i).line_item_id
            , l_delivery_detail_tab(i).transaction_temp_id
            , l_delivery_detail_tab(i).delivery_detail_id
            , l_delivery_detail_tab(i).requested_quantity
            , l_delivery_detail_tab(i).primary_uom_code
            , l_delivery_detail_tab(i).lot_control_code
            , l_delivery_detail_tab(i).serial_number_control_code
            , l_delivery_detail_tab(i).inventory_item_id
            , l_delivery_detail_tab(i).ont_pricing_qty_source;
        EXIT WHEN delivery_details%NOTFOUND;

        IF (l_debug = 1) THEN
           DEBUG('delivery_detail_id: ' || l_delivery_detail_tab(i).delivery_detail_id
                  || ' i: ' || i, 'STAGE_LPNS');
        END IF;

        i  := i + 1;
      END LOOP;

      l_last_del_index  := l_delivery_detail_tab.COUNT;

      IF (l_debug = 1) THEN
        DEBUG('l_last_del_index=' || l_last_del_index, 'STAGE_LPN');
      END IF;

      CLOSE delivery_details;

      l_processing_staged_Lines  := 'N';

      IF i = 1 then  --Added code bug 4128854 to overship a staged line
          l_delivery_detail_tab := Overship_Staged_Lines(
                     p_source_header_id =>l_header_id,
                     p_source_line_id =>l_line_id,
                     p_lpn_id =>l_outer_lpn.lpn_id,
                     p_mso_id =>l_mso_id,
                     p_organization_id => p_organization_id,
                     p_cont_instance_id => l_cont_instance_id,
                     p_dock_door_id => p_dock_door_id,
                     x_return_status   => l_return_status,
                     x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data);

            l_processing_staged_Lines  := 'Y';
            --l_last_del_index  := l_delivery_detail_tab.COUNT;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('No of delivery details for the demand_source: ' || l_delivery_detail_tab.COUNT, 'STAGE_LPN');
      END IF;

      IF (l_sub_reservable = 1
          AND l_item_reservable = 1) THEN
           -- If item = Vanilla or Lot Controlled THEN Query reservation and
           -- stage the delivery lines with the reserved Qty
        i            := 1;
        l_rsv_index  := 1;
        l_rsv_qty    := 0;
        l_total_lpn_rsv_qty    := 0;

        <<delivery_detail_loop>> -- 2529382
        FOR i IN 1 .. l_delivery_detail_tab.COUNT LOOP
          IF (l_debug = 1) THEN
            DEBUG('Clear the change attribute table ', 'Stage_LPNs');
          END IF;

          l_shipping_attr.DELETE;
          l_out_transaction_temp_id := null; --Bug 4592143
          l_lpn_count :=  0; /*Added bug4212476*/
          FOR j IN l_rsv_index .. l_mtl_reservation_tbl.COUNT LOOP
             IF l_mtl_reservation_tbl(j).lpn_id IS NOT NULL THEN
                SELECT outermost_lpn_id
                  INTO l_outermost_lpn_id
                  FROM wms_license_plate_numbers
                  WHERE lpn_id = l_mtl_reservation_tbl(j).lpn_id;

                IF (l_debug = 1) THEN
                   DEBUG('l_outermost_lpn_id: ' || l_outermost_lpn_id, 'Stage_LPNs');
                   DEBUG('l_outer_lpn.lpn_id: ' || l_outer_lpn.lpn_id, 'Stage_LPNs');
                END IF;
                IF l_outer_lpn.lpn_id = l_outermost_lpn_id THEN
                   l_lpn_count := l_lpn_count + 1;
                   IF i = 1 THEN  -- get the total per LPN only once for multiple eligible WDDs
                      l_total_lpn_rsv_qty := l_total_lpn_rsv_qty +
                             l_mtl_reservation_tbl(j).primary_reservation_quantity; --MR:added for 4440809
                   END IF;
                   IF (l_debug = 1) THEN
                      DEBUG('l_total_lpn_rsv_qty : ' || l_total_lpn_rsv_qty || ':I:'|| i ,'Stage_LPNs');
                   END IF;
                END IF;
                IF (l_debug = 1) THEN
                   DEBUG('l_mtl_reservation_tbl(j).lpn_id: ' ||
                          l_mtl_reservation_tbl(j).lpn_id ,'Stage_LPNs');
                END IF;
             END IF;
          END LOOP;     /*Added bug4212476*/
          IF (l_debug = 1) THEN
             DEBUG('l_lpn_count : ' || l_lpn_count ,'Stage_LPNs');
             DEBUG('l_processing_staged_lines : ' || l_processing_staged_lines ,'Stage_LPNs');
          END IF;

          /*  change made for 5377437 to match with 4440809
              l_lpn_count := l_lpn_count + 1;
              IF i = 1 THEN  -- get the total per LPN only once for multiple eligible WDDs
                 l_total_lpn_rsv_qty := l_total_lpn_rsv_qty +
                 l_mtl_reservation_tbl(j).primary_reservation_quantity; --MR:added for 4440809
              END IF;
              ELSE
                   DEBUG('The Outermost LPN do not match ', 'Stage_LPNs');
              END IF;
             END IF;
           END LOOP;    */

          FOR j IN l_rsv_index .. l_mtl_reservation_tbl.COUNT
          LOOP
            l_shipping_attr(1).pending_quantity := 0;
            IF l_mtl_reservation_tbl(j).lpn_id IS NULL THEN
              GOTO next_resv_rec;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('Call the select statement for rsv lpn_id  ' || l_mtl_reservation_tbl(j).lpn_id, 'Stage_LPNs');
            END IF;

            SELECT outermost_lpn_id
              INTO l_outermost_lpn_id
              FROM wms_license_plate_numbers
             WHERE lpn_id = l_mtl_reservation_tbl(j).lpn_id;

            IF l_outer_lpn.lpn_id = l_outermost_lpn_id THEN
              IF (l_debug = 1) THEN
                DEBUG('The Outermost LPN match ', 'Stage_LPNs');
                DEBUG('last index is '||l_last_del_index,'Stage LPNs');
              END IF;
              IF l_last_del_index <> 0 THEN   -- Added bug 4128854

                 l_shipping_attr(1).source_line_id      := l_mtl_reservation_tbl(j).demand_source_line_id;
                 l_shipping_attr(1).ship_from_org_id    := l_mtl_reservation_tbl(j).organization_id;
                 l_shipping_attr(1).subinventory        := l_mtl_reservation_tbl(j).subinventory_code;
                 l_shipping_attr(1).revision            := l_mtl_reservation_tbl(j).revision;
                 l_shipping_attr(1).locator_id          := l_mtl_reservation_tbl(j).locator_id;
                 l_shipping_attr(1).lot_number          := l_mtl_reservation_tbl(j).lot_number;
                 l_shipping_attr(1).transfer_lpn_id     := l_mtl_reservation_tbl(j).lpn_id;
              END IF;
                 l_shipping_attr(1).delivery_detail_id  := l_delivery_detail_tab(i).delivery_detail_id;
                 l_shipping_attr(1).inventory_item_id  := l_delivery_detail_tab(i).inventory_item_id;

            ELSE
             IF (l_debug = 1) THEN
                DEBUG('LPN do not match outerlpn_id  ' || l_outer_lpn.lpn_id, 'Stage_LPNs');
              END IF;

              GOTO next_resv_rec;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('l_rsv_qty ' || l_rsv_qty, 'STAGE_LPN');
            END IF;

            IF l_rsv_qty <= 0 THEN
              l_rsv_qty  := l_mtl_reservation_tbl(j).primary_reservation_quantity;
            END IF;

           -- Added for bug 4440809
            IF l_processing_staged_Lines = 'Y' THEN
               l_total_lpn_rsv_qty := l_rsv_qty;
            END IF;

            IF (l_debug = 1) THEN
                  DEBUG('l_lpn_count: ' || l_lpn_count, 'STAGE_LPNS');
                  DEBUG('i : ' || i || ' :l_last_del_index: ' || l_last_del_index , 'STAGE_LPNS');
                  DEBUG('l_rsv_qty ' || l_rsv_qty , 'STAGE_LPNS');
                  DEBUG('l_total_lpn_rsv_qty ' || l_total_lpn_rsv_qty , 'STAGE_LPNS');
                  DEBUG('l_delivery_detail_tab(i).requested_quantity: '
                           || l_delivery_detail_tab(i).requested_quantity, 'STAGE_LPNS');
            END IF;

            IF l_rsv_qty >= l_delivery_detail_tab(i).requested_quantity THEN
               IF (l_debug = 1) THEN
                  DEBUG('Reservation quantity >= delivery detail quantity', 'STAGE_LPNS');
               END IF;
               -- Bug : 4440809 : Start

               IF l_rsv_qty = l_delivery_detail_tab(i).requested_quantity THEN
                  IF l_rsv_qty < l_total_lpn_rsv_qty  THEN
                     IF (i >= l_last_del_index) THEN
                        l_shipping_attr(1).action_flag      := 'M';
                        l_shipping_attr(1).pending_quantity := (l_total_lpn_rsv_qty - l_rsv_qty);
                     ELSE
                        l_shipping_attr(1).action_flag      := 'U';
                     END IF;
                  ELSIF l_rsv_qty = l_total_lpn_rsv_qty  THEN
                     l_shipping_attr(1).action_flag      := 'U';
                  ELSIF l_rsv_qty > l_total_lpn_rsv_qty  THEN
                     IF (l_debug = 1) THEN
                        DEBUG('l_rsv_qty > l_total_lpn_rsv_qty : ' , 'STAGE_LPNS');
                     END IF;
                     null; -- why shld this condition happen
                  END IF;
               END IF;

               l_shipping_attr(1).picked_quantity := l_rsv_qty;
               l_shipping_attr(1).released_status := 'Y';

               IF l_rsv_qty > l_delivery_detail_tab(i).requested_quantity THEN
                  IF (i >= l_last_del_index) THEN
                     IF l_rsv_qty < l_total_lpn_rsv_qty  THEN
                           l_shipping_attr(1).action_flag      := 'M';
                          l_shipping_attr(1).pending_quantity := (l_total_lpn_rsv_qty - l_rsv_qty);
                     ELSIF l_rsv_qty = l_total_lpn_rsv_qty  THEN
                        l_shipping_attr(1).action_flag      := 'U';
                     ELSIF l_rsv_qty > l_total_lpn_rsv_qty  THEN
                        IF (l_debug = 1) THEN
                           DEBUG('l_rsv_qty > l_total_lpn_rsv_qty : ' , 'STAGE_LPNS');
                        END IF;
                        null; -- why shld this condition happen
                     END IF;
                     l_delivery_detail_tab(i).requested_quantity  := l_rsv_qty; -- **MR 01/04/06
                     l_total_lpn_rsv_qty                := l_total_lpn_rsv_qty - l_rsv_qty;
                     l_rsv_qty := 0;
                  ELSE
                     l_total_lpn_rsv_qty                :=
                         l_total_lpn_rsv_qty - l_delivery_detail_tab(i).requested_quantity;
                     l_shipping_attr(1).picked_quantity := l_delivery_detail_tab(i).requested_quantity;
                     l_rsv_qty := l_rsv_qty - l_delivery_detail_tab(i).requested_quantity ;
                     l_shipping_attr(1).action_flag := 'U';
                     l_delivery_detail_tab(i).requested_quantity  := l_rsv_qty; -- **MR 01/04/06
                  END IF; -- (i >= l_last_del_index) THEN
               ELSIF l_rsv_qty = l_delivery_detail_tab(i).requested_quantity THEN
                  l_total_lpn_rsv_qty                := l_total_lpn_rsv_qty - l_rsv_qty;
                  l_rsv_qty := 0;
               END IF;

               IF (l_debug = 1) THEN
                  DEBUG('l_shipping_attr(1).action_flag: ' || l_shipping_attr(1).action_flag, 'STAGE_LPNS');
                  DEBUG('l_shipping_attr(1).pending_quantity: ' || l_shipping_attr(1).pending_quantity, 'STAGE_LPNS');
                  DEBUG('l_shipping_attr(1).picked_quantity: ' || l_shipping_attr(1).picked_quantity, 'STAGE_LPNS');
                  DEBUG('l_total_lpn_rsv_qty: '|| l_total_lpn_rsv_qty, 'STAGE_LPNS');
                  DEBUG('l_rsv_qty: '|| l_rsv_qty, 'STAGE_LPNS');
                  DEBUG('l_delivery_detail_tab(i).requested_quantity: '||
                         l_delivery_detail_tab(i).requested_quantity, 'STAGE_LPNS');

               END IF;
               -- Bug : 4440809 : End

              IF (l_rsv_qty <= 0) THEN
                l_rsv_index  := j + 1;
              ELSE
                l_rsv_index  := j;
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('J : ' || j  , 'STAGE_LPNS');
                DEBUG('l_rsv_index: ' || l_rsv_index , 'STAGE_LPNS');
                DEBUG('l_rsv_qty: ' || l_rsv_qty, 'STAGE_LPNS');
              END IF;

              IF (l_serial_number_control_code IN(2, 5)) THEN -- Serial in MSN
                IF (l_debug = 1) THEN
                  DEBUG('The serial number control code is in 2,5', 'stage_lpns');
                END IF;

                IF (l_delivery_detail_tab(i).transaction_temp_id IS NULL) THEN
                  SELECT mtl_material_transactions_s.NEXTVAL
                    INTO l_delivery_detail_tab(i).transaction_temp_id
                    FROM DUAL;

                  -- update wds with transaction_temp_id, will be used in unload lpn if required bug# 2829514
                  UPDATE wms_direct_ship_temp
                     SET transaction_temp_id = l_delivery_detail_tab(i).transaction_temp_id
                   WHERE organization_id = l_delivery_detail_tab(i).organization_id
                     AND lpn_id = l_delivery_detail_tab(i).lpn_id
                     AND dock_door_id = l_delivery_detail_tab(i).dock_door_id
                     AND order_header_id = l_delivery_detail_tab(i).order_header_id
                     AND order_line_id = l_delivery_detail_tab(i).order_line_id;

                  IF (l_debug = 1) THEN
                    DEBUG( 'l_delivery_detail_tab(i).transaction_temp_id was null new value=' ||
                            l_delivery_detail_tab(i).transaction_temp_id , 'STAGE_LPNS');
                  END IF;
                END IF;

                -- Mark Serial Numbers
                -- ACTION overship l_delivery_detail_tab(i).requested_quantity >> overship qty
                explode_delivery_details(
                          x_return_status              => l_return_status
                        , x_msg_data                   => l_msg_data
                        , x_msg_count                  => l_msg_count
                          --Bug No 3390432
                        , x_transaction_temp_id        => l_out_transaction_temp_id
                        , p_organization_id            => p_organization_id
                        , p_lpn_id                     => l_mtl_reservation_tbl(j).lpn_id
                        , p_serial_number_control_code => l_serial_number_control_code
                        , p_delivery_detail_id         => l_delivery_detail_tab(i).delivery_detail_id
                        , p_quantity                   => l_delivery_detail_tab(i).requested_quantity
                        , p_transaction_temp_id        => l_delivery_detail_tab(i).transaction_temp_id
                        , p_reservation_id             => l_mtl_reservation_tbl(j).reservation_id
                        , p_last_action                => l_shipping_attr(1).action_flag);

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('CALL TO EXPLODE_DELIVERY_DETAILS api returns status E', 'STAGE_LPNS');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('CALL TO EXPLODE_DELIVERY_DETAILS api returns status U', 'STAGE_LPNS');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              ELSIF(l_serial_number_control_code = 6) THEN -- Serial in MSNT
                IF (l_debug = 1) THEN
                  DEBUG('The serial number control code is 6', 'stage_lpns');
                END IF;

                /*******************************
                 * Adding a new out Parameter to Comply with
                 * New Signature of Explode_delivery_details
                 ********************************/
                explode_delivery_details(
                         x_return_status              => l_return_status
                       , x_msg_data                   => l_msg_data
                       , x_msg_count                  => l_msg_count
                        -- Bug No 3390432
                       , x_transaction_temp_id        => l_out_transaction_temp_id
                       , p_organization_id            => p_organization_id
                       , p_lpn_id                     => l_mtl_reservation_tbl(j).lpn_id
                       , p_serial_number_control_code => l_serial_number_control_code
                       , p_delivery_detail_id         => l_delivery_detail_tab(i).delivery_detail_id
                       , p_quantity                   => l_delivery_detail_tab(i).requested_quantity
                       , p_transaction_temp_id        => l_delivery_detail_tab(i).transaction_temp_id
                       , p_reservation_id             => l_mtl_reservation_tbl(j).reservation_id
                       , p_last_action                => l_shipping_attr(1).action_flag);

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('CALL TO EXPLODE_DELIVERY_DETAILS api returns status E', 'STAGE_LPNS');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('CALL TO EXPLODE_DELIVERY_DETAILS api returns status U', 'STAGE_LPNS');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              END IF;

              l_invpcinrectype.transaction_temp_id         := l_delivery_detail_tab(i).transaction_temp_id;
              l_shipping_attr(1).released_status           := 'Y';

              /*************************************
          * Bug No 3390432
          * Use the new Transaction Temp Id to update WDD
          **************************************/
          IF(l_serial_number_control_code = 6) THEN
                   l_invpcinrectype.transaction_temp_id         := l_out_transaction_temp_id;
            IF (l_debug = 1) THEN
               DEBUG('AFTER updating l_invpcinrectype,  l_invpcinrectype.transaction_temp_id = '
                      || l_invpcinrectype.transaction_temp_id, 'STAGE_LPNS');
            END IF;
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('l_shipping_attr(1).action_flag     :=' || l_shipping_attr(1).action_flag, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).source_line_id     :=' || l_shipping_attr(1).source_line_id, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).transfer_lpn_id    :=' || l_shipping_attr(1).transfer_lpn_id, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).delivery_detail_id :=' || l_shipping_attr(1).delivery_detail_id, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).picked_quantity :=' || l_shipping_attr(1).picked_quantity, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).pending_quantity   :=' || l_shipping_attr(1).pending_quantity, 'STAGE_LPNS');
             DEBUG('l_delivery_detail_tab(i).requested_quantity :=' ||
                       l_delivery_detail_tab(i).requested_quantity, 'STAGE_LPNS');
             DEBUG('l_shipping_attr(1).lot_number : ' || l_shipping_attr(1).lot_number, 'STAGE_LPNS');
             DEBUG('l_InvPCInRecType.transaction_temp_id :=' || l_invpcinrectype.transaction_temp_id, 'STAGE_LPNS');
          END IF;

          --Call shipping api to set transaction_temp_id global variable
          IF (l_invpcinrectype.transaction_temp_id IS NOT NULL) THEN
             IF (l_shipping_attr(1).picked_quantity > 1) THEN
                  l_shipping_attr(1).serial_number  := NULL;

                IF (l_debug = 1) THEN
                   DEBUG('Calling Set_Inv_PC_Attributes transaction_temp_id=' ||
                          l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                END IF;

                  wsh_integration.set_inv_pc_attributes(
                    p_in_attributes              => l_invpcinrectype
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_data
                  , x_msg_data                   => l_msg_count
                  );

                  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error E from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error U from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                ELSE
                  BEGIN
                    SELECT fm_serial_number
                      INTO l_shipping_attr(1).serial_number
                      FROM mtl_serial_numbers_temp
                     WHERE transaction_temp_id = l_invpcinrectype.transaction_temp_id
                       AND ROWNUM < 2;

                    IF (l_debug = 1) THEN
                      DEBUG(
                           'found fm_serial='
                        || l_shipping_attr(1).serial_number
                        || ' for transaction_temp_id='
                        || l_invpcinrectype.transaction_temp_id
                      , 'STAGE_LPN'
                      );
                    END IF;

                    DELETE FROM mtl_serial_numbers_temp
                          WHERE transaction_temp_id = l_invpcinrectype.transaction_temp_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      IF (l_debug = 1) THEN
                        DEBUG('No rows found in MSNT for transaction_temp_id=' ||
                               l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                      END IF;
                  END;
                END IF;
              END IF;
              IF (G_WMS_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
                  l_delivery_detail_tab(i).ont_pricing_qty_source='S')
              THEN
                  l_shipping_attr(1).picked_quantity2 := GET_CATCH_WEIGHT
                                  (l_shipping_attr(1).ship_from_org_id
                                  ,l_shipping_attr(1).transfer_lpn_id
                                  ,l_shipping_attr(1).inventory_item_id
                                  ,l_shipping_attr(1).revision
                                  ,l_shipping_attr(1).lot_number
                                  ,l_shipping_attr(1).picked_quantity);
          END IF;

              wsh_interface.update_shipping_attributes
                    (   p_source_code        => 'INV'
                      , p_changed_attributes => l_shipping_attr
                      , x_return_status      => l_return_status);

              IF (l_debug = 1) THEN
                DEBUG('after update shipping attributes', 'stage_lpns');
              END IF;

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error from update shipping attributes 3', 'STAGE_LPN');
                END IF;

                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('return unexpected error from update shipping attributes', 'STAGE_LPN');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              --EXIT; -- commented in P-I to split on extra reservations
              l_delivery_detail_tab(i).requested_quantity  := 0;

              --
              IF l_delivery_detail_tab(i).requested_quantity = 0
                 AND i < l_last_del_index THEN
                EXIT;
              END IF;
            ----
            ----End of IF-1
            ----Start of IF-2
            ELSIF l_rsv_qty < l_delivery_detail_tab(i).requested_quantity THEN
              IF (l_debug = 1) THEN
                 DEBUG('The l_rsv_qty < requested_quantity ', 'STAGE_LPNs');
                 DEBUG('rsv lpn_id:  ' || l_mtl_reservation_tbl(j).lpn_id, 'Stage_LPNs');
                 DEBUG('l_rsv_qty ' || l_rsv_qty , 'STAGE_LPNS');
                 DEBUG('l_total_lpn_rsv_qty ' || l_total_lpn_rsv_qty , 'STAGE_LPNS');
                 DEBUG('l_delivery_detail_tab(i).requested_quantity: '
                          || l_delivery_detail_tab(i).requested_quantity, 'STAGE_LPNS');
              END IF;

              -- Bug : 4440809 : Start
              IF l_rsv_qty < l_total_lpn_rsv_qty  THEN
                 l_shipping_attr(1).action_flag      := 'M';
                 l_shipping_attr(1).pending_quantity := (l_total_lpn_rsv_qty - l_rsv_qty);
              ELSIF l_rsv_qty = l_total_lpn_rsv_qty  THEN
                 IF l_delivery_detail_tab(i).requested_quantity - l_rsv_qty > 0
                 THEN
                   l_shipping_attr(1).action_flag       := 'M';
                   l_shipping_attr(1).pending_quantity :=
                            l_delivery_detail_tab(i).requested_quantity - l_rsv_qty;
                 ELSE
                    l_shipping_attr(1).action_flag      := 'U';
                 END IF;
              END IF;-- l_rsv_qty and l_total_lpn_rsv_qty  THEN

              l_shipping_attr(1).picked_quantity := l_rsv_qty;
              l_shipping_attr(1).released_status := 'Y';
              l_total_lpn_rsv_qty                := l_total_lpn_rsv_qty - l_rsv_qty;


              /*   4440809
              l_shipping_attr(1).pending_quantity          := 0;
              l_shipping_attr(1).released_status           := 'Y';
              l_shipping_attr(1).picked_quantity           := l_rsv_qty;
              l_shipping_attr(1).action_flag               := 'U'; */

              IF (l_debug = 1) THEN
                 DEBUG('l_total_lpn_rsv_qty ' || l_total_lpn_rsv_qty , 'STAGE_LPNS');
                 DEBUG('i=' || i || ' j= ' || j, 'xxxx');
                 DEBUG(' l_shipping_attr(1).action_flag :' || l_shipping_attr(1).action_flag, 'STAGE_LPNs');
              END IF;

              IF (l_serial_number_control_code IN(2, 5)) THEN -- Serial Control Code
                IF (l_debug = 1) THEN
                  DEBUG('The serial number control code is in 2,5', 'stage_lpns');
                END IF;

                IF (l_delivery_detail_tab(i).transaction_temp_id IS NULL) THEN
                  SELECT mtl_material_transactions_s.NEXTVAL
                    INTO l_delivery_detail_tab(i).transaction_temp_id
                    FROM DUAL;

                    l_invpcinrectype.transaction_temp_id := l_delivery_detail_tab(i).transaction_temp_id;

                  -- update wds with transaction_temp_id, will be used in unload lpn if required bug# 2829514
                  UPDATE wms_direct_ship_temp
                     SET transaction_temp_id = l_delivery_detail_tab(i).transaction_temp_id
                   WHERE organization_id = l_delivery_detail_tab(i).organization_id
                     AND lpn_id = l_delivery_detail_tab(i).lpn_id
                     AND dock_door_id = l_delivery_detail_tab(i).dock_door_id
                     AND order_header_id = l_delivery_detail_tab(i).order_header_id
                     AND order_line_id = l_delivery_detail_tab(i).order_line_id;

                  IF (l_debug = 1) THEN
                    DEBUG( 'l_delivery_detail_tab(i).transaction_temp_id was null new value='
                            || l_delivery_detail_tab(i).transaction_temp_id , 'STAGE_LPNS');
                  END IF;
                END IF;

                /**************************************
                * Adding new out parameter to comply with new signature
                ***************************************/
                -- Mark Serial Numbers
                explode_delivery_details(
                  x_return_status              => l_return_status
                , x_msg_data                   => l_msg_data
                , x_msg_count                  => l_msg_count
                  --Bug No 3390432
                , x_transaction_temp_id        => l_out_transaction_temp_id
                , p_organization_id            => p_organization_id
                , p_lpn_id                     => l_mtl_reservation_tbl(j).lpn_id
                , p_serial_number_control_code => l_serial_number_control_code
                , p_delivery_detail_id         => l_delivery_detail_tab(i).delivery_detail_id
                , p_quantity                   => l_rsv_qty
                , p_transaction_temp_id        => l_delivery_detail_tab(i).transaction_temp_id
                , p_reservation_id             => l_mtl_reservation_tbl(j).reservation_id
                , p_last_action                => l_shipping_attr(1).action_flag
                );

                IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return error from update shipping attributes 3', 'stage_lpns');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return unexpected error from update shipping attributes', 'stage_lpns');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              ELSIF(l_serial_number_control_code = 6) THEN -- Serial in MSNT
                IF (l_debug = 1) THEN
                  DEBUG('The serial number control code is 6', 'stage_lpns');
                END IF;

                /*****************************************
                * Retreving the new Transaction temp id to use in Splitting
                * existing WDD line
                ******************************************/
                explode_delivery_details(
                  x_return_status              => l_return_status
                , x_msg_data                   => l_msg_data
                , x_msg_count                  => l_msg_count
                 --Bug No 3390432
                , x_transaction_temp_id        => l_out_transaction_temp_id
                , p_organization_id            => p_organization_id
                , p_lpn_id                     => l_mtl_reservation_tbl(j).lpn_id
                , p_serial_number_control_code => l_serial_number_control_code
                , p_delivery_detail_id         => l_delivery_detail_tab(i).delivery_detail_id
                , p_quantity                   => l_rsv_qty
                , p_transaction_temp_id        => l_delivery_detail_tab(i).transaction_temp_id
                , p_reservation_id             => l_mtl_reservation_tbl(j).reservation_id
                , p_last_action                => l_shipping_attr(1).action_flag
                );

                IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return error from EXPLODE_DELIVERY_DETAILS 3', 'stage_lpns');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return unexpected error from EXPLODE_DELIVERY_DETAILS 3', 'stage_lpns');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              END IF; -- Serial Control Code

              /*******************************************
          * Bug No 3390432
          * Update WDD with the  newly created Transaction_temp_id
          ********************************************/
              l_invpcinrectype.transaction_temp_id := l_out_transaction_temp_id;
              l_shipping_attr(1).released_status   := 'Y';

              IF (l_debug = 1) THEN
                DEBUG('l_shipping_attr(1).action_flag        =' || l_shipping_attr(1).action_flag, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).source_line_id     =' || l_shipping_attr(1).source_line_id, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).transfer_lpn_id    =' || l_shipping_attr(1).transfer_lpn_id, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).delivery_detail_id =' || l_shipping_attr(1).delivery_detail_id, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).picked_quantity    =' || l_shipping_attr(1).picked_quantity, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).pending_quantity   =' || l_shipping_attr(1).pending_quantity, 'STAGE_LPNS');
                DEBUG('l_delivery_detail_tab(i).requested_quantity =' ||
                       l_delivery_detail_tab(i).requested_quantity, 'STAGE_LPNS');
                DEBUG('l_shipping_attr(1).lot_number : ' || l_shipping_attr(1).lot_number, 'STAGE_LPNS');
                DEBUG('l_InvPCInRecType.transaction_temp_id  =' || l_invpcinrectype.transaction_temp_id, 'STAGE_LPNS');
              END IF;

              --Call shipping api to set transaction_temp_id global variable
              IF ( l_invpcinrectype.transaction_temp_id IS NOT NULL ) THEN
                IF ( l_shipping_attr(1).picked_quantity > 1 ) THEN
                  l_shipping_attr(1).serial_number  := NULL;

                  IF ( l_debug = 1 ) THEN
                    DEBUG('Calling Set_Inv_PC_Attributes transaction_temp_id=' ||
                           l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                  END IF;

                  WSH_INTEGRATION.Set_INV_PC_Attributes(
                    p_in_attributes => l_invpcinrectype
                  , x_return_status => l_return_status
                  , x_msg_count     => l_msg_data
                  , x_msg_data      => l_msg_count );

                  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error E from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error U from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                ELSE
                  BEGIN
                    SELECT fm_serial_number
                      INTO l_shipping_attr(1).serial_number
                      FROM mtl_serial_numbers_temp
                     WHERE transaction_temp_id = l_invpcinrectype.transaction_temp_id
                       AND ROWNUM < 2;

                    IF ( l_debug = 1 ) THEN
                      DEBUG('found fm_serial='|| l_shipping_attr(1).serial_number||
                            ' for transaction_temp_id='||l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                    END IF;

                    DELETE FROM mtl_serial_numbers_temp
                    WHERE  transaction_temp_id = l_invpcinrectype.transaction_temp_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      IF (l_debug = 1) THEN
                        DEBUG('No rows found in MSNT for transaction_temp_id=' ||
                               l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                      END IF;
                  END;
                END IF;
              END IF; -- for serial controlled items

          --patchset J.  Shipping API cleanup
          l_delivery_detail_tab(i).requested_quantity := l_delivery_detail_tab(i).requested_quantity - l_rsv_qty;
          /* 4440809
             WSH_DELIVERY_DETAILS_PUB.split_line
                 (p_api_version   => 1.0,
                  p_init_msg_list => fnd_api.g_false,
                  p_commit        => fnd_api.g_false,
                  x_return_status => l_return_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data,
                  p_from_detail_id => l_delivery_detail_tab(i).delivery_detail_id,
                  x_new_detail_id => l_new_delivery_detail_id,
                  x_split_quantity => l_delivery_detail_tab(i).requested_quantity,
                  x_split_quantity2 => l_dummy_num_var);

                 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                   IF (l_debug = 1) THEN
                     DEBUG('return error from split_delivery_details ', 'stage_lpns');
                   END IF;

                   RAISE fnd_api.g_exc_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF (l_debug = 1) THEN
                     DEBUG('return unexpected error from split_delivery_details', 'stage_lpns');
                   END IF;

                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
             --\Shipping API cleanup

                IF (l_debug = 1) THEN
                      DEBUG('l_new_delivery_detail_id:=' || l_new_delivery_detail_id, 'STAGE_LPNS');
                END IF; 4440809 */

              --Call shipping api to set transaction_temp_id global variable
              IF (l_invpcinrectype.transaction_temp_id IS NOT NULL) THEN
                IF (l_shipping_attr(1).picked_quantity > 1) THEN
                  l_shipping_attr(1).serial_number  := NULL;

                  IF (l_debug = 1) THEN
                    DEBUG('Calling Set_Inv_PC_Attributes transaction_temp_id=' ||
                           l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                  END IF;

                  wsh_integration.set_inv_pc_attributes(
                    p_in_attributes              => l_invpcinrectype
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_data
                  , x_msg_data                   => l_msg_count
                  );

                  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error E from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF (l_debug = 1) THEN
                      DEBUG('return error U from Set_Inv_PC_Attributes', 'STAGE_LPN');
                    END IF;

                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                ELSE
                  BEGIN
                    SELECT fm_serial_number
                      INTO l_shipping_attr(1).serial_number
                      FROM mtl_serial_numbers_temp
                     WHERE transaction_temp_id = l_invpcinrectype.transaction_temp_id
                       AND ROWNUM < 2;

                    IF (l_debug = 1) THEN
                      DEBUG(
                           'found fm_serial='
                        || l_shipping_attr(1).serial_number
                        || ' for transaction_temp_id='
                        || l_invpcinrectype.transaction_temp_id
                      , 'STAGE_LPN'
                      );
                    END IF;

                    DELETE FROM mtl_serial_numbers_temp
                          WHERE transaction_temp_id = l_invpcinrectype.transaction_temp_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      IF (l_debug = 1) THEN
                        DEBUG('No rows found in MSNT for transaction_temp_id=' ||
                               l_invpcinrectype.transaction_temp_id, 'STAGE_LPN');
                      END IF;
                  END;
                END IF;
              END IF;
              IF (G_WMS_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
              l_delivery_detail_tab(i).ont_pricing_qty_source='S') THEN
                 IF (l_debug = 1) THEN
                   DEBUG('Catch Weight updates ', 'stage_lpns');
                 END IF;
                l_shipping_attr(1).picked_quantity2 := GET_CATCH_WEIGHT(l_shipping_attr(1).ship_from_org_id
                                  ,l_shipping_attr(1).transfer_lpn_id
                                  ,l_shipping_attr(1).inventory_item_id
                                  ,l_shipping_attr(1).revision
                                  ,l_shipping_attr(1).lot_number
                                  ,l_shipping_attr(1).picked_quantity);
              END IF;
              IF (l_debug = 1) THEN
                DEBUG('Call  update shipping attributes', 'stage_lpns');
              END IF;
              wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr
              , x_return_status              => l_return_status);

              IF (l_debug = 1) THEN
                DEBUG('after update shipping attributes', 'stage_lpns');
              END IF;

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error from update shipping attributes 2', 'stage_lpns');
                END IF;

                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('return unexpected error from update shipping attributes', 'stage_lpns');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

          --Since we have split the WDD line, we need to process
          --this newly split line also.
          --Setting these variables will process the newly split line
          /* 4440809: l_delivery_detail_tab(i).delivery_detail_id := l_new_delivery_detail_id; */
              /*****************************************
          * Bug No 3390432
          * Only changing the Transaction_temp_id of WDD to Null value when
          * serial control code is 2 or 5
          ******************************************/
          IF(l_serial_number_control_code IN (2,5)) THEN -- Serial NOT in MSNT
            l_delivery_detail_tab(i).transaction_temp_id := NULL;
          END IF;
          l_invpcinrectype.transaction_temp_id :=
        l_delivery_detail_tab(i).transaction_temp_id;


              l_rsv_index                                  := j + 1;
              l_rsv_qty                                    := 0;
            END IF; --Res. Qty Match l_rsv_qty < l_delivery_detail_tab(i).requested_quantity
            -- IF-2

            <<next_resv_rec>>
            IF (l_rsv_index > l_mtl_reservation_tbl.COUNT) THEN
              l_rsv_index  := 0;
              l_rsv_qty    := 0;
              EXIT delivery_detail_loop; -- 2529382
            END IF;

          END LOOP; -- Reservation Loop
        END LOOP; -- Delivery Detail Loop
      ELSE -- Non Reservable
        IF (l_debug = 1) THEN
          DEBUG('Item or Sub in non reservable so stage the line without updating the inventory details');
        END IF;

        FOR i IN 1 .. l_delivery_detail_tab.COUNT LOOP
          l_shipping_attr.DELETE;
          l_shipping_attr(1).delivery_detail_id  := l_delivery_detail_tab(i).delivery_detail_id;
          l_shipping_attr(1).released_status     := 'Y';
          wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr
          , x_return_status              => l_return_status);

          IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
              DEBUG('Non-Reservable: return error from update shipping attributes', 'stage_lpns');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Non-Reservable: return unexpected error from update shipping attributes', 'stage_lpns');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP; -- Non-Reservable delivery_details
      END IF; -- Reservable
    END LOOP; -- STAGE_LINE;

    CLOSE stage_lines;
  END LOOP; -- OUTER LPN

  CLOSE outer_lpn;

  BEGIN
    OPEN outer_lpn;

    LOOP
      FETCH outer_lpn INTO l_outer_lpn;
      EXIT WHEN outer_lpn%NOTFOUND;

      IF (l_debug = 1) THEN
        DEBUG('populate_wstt   ', 'stage_lpns');
      END IF;

      wms_shipping_transaction_pub.populate_wstt(
        x_return                     => l_return
      , x_msg_code                   => x_msg_data
      , p_organization_id            => p_organization_id
      , p_lpn_id                     => l_outer_lpn.lpn_id
      , p_trip_id                    => 0
      , p_dock_door_id               => p_dock_door_id
      , p_direct_ship_flag           => 'Y'
      );

      IF l_return = 1 THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      END IF;

      SELECT COUNT(*)
        INTO l_trip_id
        FROM wms_shipping_transaction_temp
       WHERE outermost_lpn_id = l_outer_lpn.lpn_id;

      IF (l_debug = 1) THEN
        DEBUG('After Populate WSTT, No of LPNs loaded :' || TO_CHAR(l_trip_id), 'stage_lpns');
      END IF;

      -- Update container Hierarchy so that container so that following cols has same value as delivery lines
      -- SHIP_TO_LOCATION_ID, SHIP_TO_LOCATION_ID, DELIVER_TO_LOCATION_ID
      BEGIN
	 IF l_trip_id > 0 THEN
	    UPDATE wms_license_plate_numbers
	      SET lpn_context = 9
	      WHERE outermost_lpn_id = l_outer_lpn.lpn_id;

	    IF (l_debug = 1) THEN
	       DEBUG('Update LPN Context to Loaded to Dock, LPN :' || TO_CHAR(l_outer_lpn.lpn_id), 'Stage_LPNs');
	    END IF;
	 END IF;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
      END;

      wms_shipping_transaction_pub.create_delivery(
						  p_outermost_lpn_id           => l_outer_lpn.lpn_id
						  , p_trip_id                    => NULL
						  , p_organization_id            => p_organization_id
						  , p_dock_door_id               => p_dock_door_id
						  , x_delivery_id                => l_delivery_id
						  , x_return_status              => l_return_status
						  , x_message                    => l_msg_data
						  , p_direct_ship_flag           => 'Y'
						  );

     IF (l_debug = 1) THEN
        DEBUG('Create Delivery  :' || TO_CHAR(l_delivery_id) || ' Return Status ' || l_return_status, 'stage_lpns');
     END IF;

     IF l_return_status IN('S') THEN
	IF (l_debug = 1) THEN
	   DEBUG('return success from create_delivery ', 'stage_lpns');
	END IF;

	x_return_status  := fnd_api.g_ret_sts_success;
      ELSIF l_return_status IN('E') THEN
	IF (l_debug = 1) THEN
	   DEBUG('return error from create_delivery', 'stage_lpns');
	END IF;

	x_return_status  := fnd_api.g_ret_sts_error;
	RAISE fnd_api.g_exc_error;
      ELSE
	IF (l_debug = 1) THEN
	   DEBUG('return unexpected error from create_delivery', 'stage_lpns');
	END IF;

	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     --- <Changes for Delivery Merge>
     IF g_wms_current_release_level >= g_j_release_level THEN

	l_action_prms.caller := 'WMS_DLMG';
	l_action_prms.event := wsh_interface_ext_grp.g_start_of_shipping;
	l_action_prms.action_code := 'ADJUST-PLANNED-FLAG';

	l_delivery_id_tab(1) := l_delivery_id;

	wsh_interface_ext_grp.delivery_action
	  (p_api_version_number     => 1.0,
	   p_init_msg_list          => fnd_api.g_false,
	   p_commit                 => fnd_api.g_false,
	   p_action_prms            => l_action_prms,
	   p_delivery_id_tab        => l_delivery_id_tab,
	   x_delivery_out_rec       => l_delivery_out_rec,
	   x_return_status          => l_return_status,
	   x_msg_count              => l_msg_count,
	   x_msg_data               => l_msg_data);

	IF (l_debug = 1) THEN
	   debug('Called Adjust Planned Status with return status: ' || l_return_status, 'stage_lpns');
	END IF;

	-- Do not error out even if the call fails.


	-- g-log changes

	IF WSH_UTIL_CORE.GC3_IS_INSTALLED = 'Y' THEN
	   IF (l_debug = 1) THEN
	      debug('G-Log Changes: G-Log installed', 'LPN_CHECK');
	   END IF;

	   OPEN c_Get_OTM_flag(l_delivery_id);
	   FETCH c_Get_OTM_flag INTO l_ignore_for_planning, l_tms_interface_flag;
	   IF (l_debug = 1) THEN
	      debug('l_ignore_for_planning : '|| l_ignore_for_planning, 'LPN_CHECK');
	      debug('l_tms_interface_flag : '|| l_tms_interface_flag, 'LPN_CHECK');
	   END IF;

	   IF (c_Get_OTM_flag%NOTFOUND) THEN
	      IF (l_debug = 1) THEN
		 debug('No WDDs found for the delivery created ', 'LPN_CHECK');
	      END IF;
	   END IF;
	   CLOSE c_Get_OTM_flag;

	   --Important Note: Irrespective of the severity level of 'CR' exception for the delivery just
	   --created, we have to mark the delivery to ignore_for_planning so that the
	   --transaction goes through fine.
	   -- Hence there is no call to WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM().
	   -- Here delivery was created in the backend for the line that the use
	   -- chose to ship confirm. it IS ALL happening in the backend.

	   IF l_ignore_for_planning = 'N' AND l_tms_interface_flag = 'CR' THEN
	      l_action_prms.action_code := 'IGNORE_PLAN';
	      wsh_interface_ext_grp.delivery_action
		(p_api_version_number     => 1.0,
		 p_init_msg_list          => fnd_api.g_false,
		 p_commit                 => fnd_api.g_false,
		 p_action_prms            => l_action_prms,
		 p_delivery_id_tab        => l_delivery_id_tab,
		 x_delivery_out_rec       => l_delivery_out_rec,
		 x_return_status          => l_return_status,
		 x_msg_count              => l_msg_count,
		 x_msg_data               => l_msg_data);

	      IF (l_debug = 1) THEN
		 debug('Called wsh_interface_ext_grp.delivery_action with action_code IGNORE_PLAN and return status: ' || l_return_status, 'stage_lpns');
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 x_msg_data := 'WMS_DELIVERY_ACTION_FAIL';
		 RAISE fnd_api.g_exc_error;
	       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 x_msg_data := 'WMS_DELIVERY_ACTION_FAIL';
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	   END IF;

	END IF; --g-log changes

     END IF;
     -- </Changes for delivery merge>

    END LOOP;

    CLOSE outer_lpn;
  END;        -- Populate WSTT and Update the LPN context
              -- Stage the delivery details that have been updated just now
  IF (l_debug = 1) THEN
     DEBUG('Exiting  Stage LPNs..: ' , 'STAGE_LPN');
  END IF;
       --COMMIT;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
	 DEBUG('In exception type E', 'stage_lpns');
      END IF;
      --      ROLLBACK;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
	 DEBUG('In exception type U', 'stage_lpns');
      END IF;

      --      ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status  := wsh_util_core.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
	 DEBUG('Exception When Others ' || SQLERRM, 'Stage_LPNS');
      END IF;
END stage_lpns;

PROCEDURE load_truck(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_data      OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, p_group_id      IN            NUMBER
, p_org_id        IN            NUMBER
, p_dock_door_id  IN            NUMBER
) IS
BEGIN
  --bug #2782201
  NULL;
/*
  This procedure is no more used from Patchset I. For corresponding functionality
  please look load_lpn.
 */
END load_truck;

PROCEDURE close_truck(
  x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_data         OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    NUMBER
, x_error_code       OUT NOCOPY    NUMBER
, x_missing_item_cur OUT NOCOPY    t_genref
, p_dock_door_id     IN            NUMBER
, p_group_id         IN            NUMBER
, p_org_id           IN            NUMBER
) IS
  CURSOR trip_cursor IS
    SELECT DISTINCT trip_id
               FROM wms_shipping_transaction_temp
              WHERE dock_door_id = p_dock_door_id
                AND organization_id = p_org_id
                AND direct_ship_flag = 'Y';

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(20000);
  l_trip_cursor         trip_cursor%ROWTYPE;
  l_vehicle_item_id     NUMBER;   --Bug#6878013
  l_debug               NUMBER                            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_ship_method_code    wsh_trips.ship_method_code%TYPE;
  l_enforce_ship_method VARCHAR2(1);
  l_trip_name           wsh_trips.NAME%TYPE;
  no_ship_method_code   EXCEPTION;

BEGIN
  --SAVEPOINT closetruck;
  x_return_status  := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
    inv_trx_util_pub.TRACE('In close truck program ', 'close_truck', 9);
    inv_trx_util_pub.TRACE('p_dock_door_id     : ' || p_dock_door_id     , 'close_truck', 9);
    inv_trx_util_pub.TRACE('p_group_id         : ' || p_group_id         , 'close_truck', 9);
    inv_trx_util_pub.TRACE('p_org_id           : ' || p_org_id           , 'close_truck', 9);
  END IF;

  IF (l_debug = 1) THEN
    DEBUG('Before call to Confirm All deliveries API close_truck');
  END IF;

  wms_direct_ship_pvt.confirm_all_deliveries(
    x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , x_missing_item_cur           => x_missing_item_cur
  , x_error_code                 => x_error_code
  , p_delivery_id                => NULL
  , p_net_weight                 => NULL
  , p_gross_weight               => NULL
  , p_wt_uom_code                => NULL
  , p_waybill                    => NULL
  , p_ship_method_code           => NULL
  , p_fob_code                   => NULL
  , p_fob_location_id            => NULL
  , p_freight_term_code          => NULL
  , p_freight_term_name          => NULL
  , p_intmed_shipto_loc_id       => NULL
  , p_org_id                     => p_org_id
  , p_dock_door_id               => p_dock_door_id
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('Confirm All deliveries API failed with status E ', 'close_truck', 9);
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Confirm All deliveries API failed with status E close_truck');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('Confirm All deliveries failed with status U', 'close_truck', 9);
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Confirm All deliveries failed with status U close_truck');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1) THEN
    inv_trx_util_pub.TRACE('Confirm All deliveries successfully completed ', 'close_truck', 9);
  END IF;

  IF (l_debug = 1) THEN
     DEBUG('Confirm All deliveries successfully completed  close_truck');
     debug('Get the enforce_ship_method flag','close_truck');
  END IF;

  INV_SHIPPING_TRANSACTION_PUB.get_enforce_ship
    (p_org_id         => p_org_id
     ,x_enforce_ship  => l_enforce_ship_method
     ,x_return_status => l_return_status
     ,x_msg_data      => l_msg_data
     ,x_msg_count     => l_msg_count);

  IF (l_debug=1) THEN
     debug('get_enforce_ship returned status: ' || l_return_status,'Close_truck');
     debug('Enforce_ship_method flag: ' || l_enforce_ship_method,'Close_truck');
  END IF;

  OPEN trip_cursor;

  LOOP
    FETCH trip_cursor INTO l_trip_cursor;
    EXIT WHEN trip_cursor%NOTFOUND;

    IF (l_debug = 1) THEN
      DEBUG('Before call to Close Trip API ', 'close_truck');
    END IF;

    /*Bug 2980013:Check if the Ship method Code is populated if the Enforce Ship method Flag is set to Y*/
    BEGIN
      SELECT ship_method_code
           , NAME
        INTO l_ship_method_code
           , l_trip_name
        FROM wsh_trips_ob_grp_v
       WHERE trip_id = l_trip_cursor.trip_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ship_method_code  := NULL;
    END;

    IF l_enforce_ship_method = 'Y'
       AND l_ship_method_code IS NULL THEN
      RAISE no_ship_method_code;
    END IF;

     /*Bug6878013 If the Vehicle Item Id is not null, pass its value else pass NULL*/
     BEGIN
        SELECT vehicle_item_id
            INTO l_vehicle_item_id
            FROM wsh_trips_ob_grp_v
            WHERE trip_id = l_trip_cursor.trip_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_vehicle_item_id := NULL;
      END;

      wms_direct_ship_pvt.close_trip(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_trip_id                    => l_trip_cursor.trip_id
      , p_vehicle_item_id            => l_vehicle_item_id  --Bug#6878013
      , p_vehicle_num_prefix         => NULL
      , p_vehicle_num                => NULL
      , p_seal_code                  => NULL
      , p_document_set_id            => NULL
      , p_org_id                     => p_org_id
      , p_dock_door_id               => p_dock_door_id
      , p_ship_method_code           => l_ship_method_code
      );

      IF (l_debug = 1) THEN
        DEBUG('After call to Close Trip API close_truck');
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Close trip API failed with status E ', 'close_truck');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Close trip failed with status U', 'close_truck');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('Close trip API completed successfully ', 'close_truck');
      END IF;

  END LOOP;

  CLOSE trip_cursor;

  IF (l_debug = 1) THEN
    DEBUG('End of close truck ', 'close_truck', 9);
  END IF;
EXCEPTION
  WHEN no_ship_method_code THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_SHIP_METHOD_CODE');
    fnd_message.set_token('TRIP_NAME', l_trip_name);
    /* No Ship method code provided for the Trip .This is required */
    fnd_msg_pub.ADD;
    /*fnd_msg_pub.count_and_get( p_count => x_msg_count,
                          p_data  => x_msg_data
                        );*/
    DEBUG('In exception no_ship_method_code ', 'Close Trip');
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK; --TO closetruck;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK; --TO closetruck;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK; --TO closetruck;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END;

  --CLOSE_TRUCK

PROCEDURE get_lpn_available_quantity(
  x_return_status     OUT NOCOPY    VARCHAR2
, x_msg_count         OUT NOCOPY    NUMBER
, x_msg_data          OUT NOCOPY    VARCHAR2
, p_organization_id   IN            NUMBER
, p_lpn_id            IN            NUMBER
, p_inventory_item_id IN            NUMBER
, p_revision          IN            VARCHAR2
, p_line_id           IN            NUMBER
, p_header_id         IN            NUMBER
, x_qoh               OUT NOCOPY    NUMBER
, x_att               OUT NOCOPY    NUMBER
) IS
  CURSOR inner_lpn(p_lpn NUMBER) IS
    SELECT lpn_id
         , subinventory_code
         , locator_id
      FROM wms_license_plate_numbers
     WHERE outermost_lpn_id = p_lpn;

  l_rqoh                  NUMBER;
  l_qr                    NUMBER;
  l_qs                    NUMBER;
  l_atr                   NUMBER;
  l_revision_control      NUMBER;
  l_lot_control           NUMBER;
  l_serial_control        NUMBER;
  l_is_revision_control   BOOLEAN             := FALSE;
  l_is_lot_control        BOOLEAN             := FALSE;
  l_is_serial_control     BOOLEAN             := FALSE;
  l_inner_lpn             inner_lpn%ROWTYPE;
  l_msg_data              VARCHAR2(20000);
  l_order_source_id       NUMBER;
  l_demand_source_type_id NUMBER;
  l_debug                 NUMBER              := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
    DEBUG('The value of lpn_id is ' || p_lpn_id, 'GET_LPN_AVAILABLE_QUANTITY');
    DEBUG('The value of p_inventory_item_id is ' || p_inventory_item_id, 'GET_LPN_AVAILABLE_QUANTITY');
    DEBUG('The value of p_revision is ' || NVL(p_revision, 'A'), 'GET_LPN_AVAILABLE_QUANTITY');
    DEBUG('The value of p_line_id is ' || p_line_id, 'GET_LPN_AVAILABLE_QUANTITY');
    DEBUG('The value of p_header_id is ' || p_header_id, 'GET_LPN_AVAILABLE_QUANTITY');
  END IF;

  inv_quantity_tree_pub.clear_quantity_cache;

  SELECT revision_qty_control_code
       , lot_control_code
       , serial_number_control_code
    INTO l_revision_control
       , l_lot_control
       , l_serial_control
    FROM mtl_system_items
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

  IF (l_revision_control = 2) THEN
    l_is_revision_control  := TRUE;
  END IF;

  IF (l_lot_control = 2) THEN
    l_is_lot_control  := TRUE;
  END IF;

  IF (l_serial_control = 2
      OR l_serial_control = 5
      OR l_serial_control = 6) THEN
    l_is_serial_control  := TRUE;
  END IF;

  SELECT order_source_id
    INTO l_order_source_id
    FROM oe_order_headers_all
   WHERE header_id = p_header_id;

  IF l_order_source_id = 10 THEN
    l_demand_source_type_id  := 8;
  ELSE
    l_demand_source_type_id  := 2;
  END IF;

  x_att            := 0;
  OPEN inner_lpn(p_lpn_id);

  LOOP
    FETCH inner_lpn INTO l_inner_lpn;
    EXIT WHEN inner_lpn%NOTFOUND;
    /* Bug 2440408: All the Trees in the cache have to be cleared so that trees are rebuild */
    inv_quantity_tree_pub.clear_quantity_cache;
    inv_quantity_tree_pub.query_quantities(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_organization_id            => p_organization_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
    , p_is_revision_control        => l_is_revision_control
    , p_is_lot_control             => l_is_lot_control
    , p_is_serial_control          => l_is_serial_control
    , p_demand_source_type_id      => l_demand_source_type_id
    , p_demand_source_header_id    => inv_salesorder.get_salesorder_for_oeheader(p_header_id)
    , p_demand_source_line_id      => p_line_id
    , p_revision                   => p_revision
    , p_lot_number                 => NULL
    , p_subinventory_code          => NULL
    , p_locator_id                 => NULL
    , x_qoh                        => x_qoh
    , x_rqoh                       => l_rqoh
    , x_qr                         => l_qr
    , x_qs                         => l_qs
    , x_att                        => x_att
    , x_atr                        => l_atr
    , p_lpn_id                     => l_inner_lpn.lpn_id
    );

    IF (l_debug = 1) THEN
      DEBUG('The value of x_att is ' || x_att, 'GET_LPN_AVAILABLE_QUANTITY');
    END IF;

    -- If the qty tree returns and error raise an exception.
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Qty Tree Failed' || l_msg_data, 'INV_VMI_VALIDATIONS', 9);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (x_att > 0) THEN
      IF (l_debug = 1) THEN
        DEBUG('The value of x_att is - in if ' || x_att, 'GET_LPN_AVAILABLE_QUANTITY');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;
      EXIT;
    END IF;
  END LOOP;

  x_return_status  := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('When others Exception in get_available_vmi_quantity', 'GET_LPN_AVAILABLE_QUANTITY', 9);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    RETURN;
END get_lpn_available_quantity;

PROCEDURE create_update_containers(
  x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    NUMBER
, x_msg_data         OUT nocopy    VARCHAR2
, p_org_id           IN            NUMBER
, p_outermost_lpn_id IN NUMBER
, p_delivery_id      IN  NUMBER DEFAULT NULL
) IS
  CURSOR lpn_details IS
    SELECT lpn_id
         , license_plate_number
         , subinventory_code
         , locator_id
         , inventory_item_id
         , revision
         , lot_number
         , serial_number
         , gross_weight_uom_code
         , gross_weight
         , tare_weight_uom_code
         , tare_weight
         , content_volume_uom_code
         , content_volume
      -- Release 12 (K): LPN Synchronization
      -- Add following new columns
         , container_volume
         , container_volume_uom
         , organization_id
      FROM wms_license_plate_numbers
     WHERE organization_id = p_org_id
       AND outermost_lpn_id = p_outermost_lpn_id;

  l_lpn_ids            wsh_util_core.id_tab_type;
  l_container_ids      wsh_util_core.id_tab_type;
  l_lpn_id             NUMBER;
  l_segmentarray       fnd_flex_ext.segmentarray;
  l_count              NUMBER                                     := 0;
  l_net_weight         NUMBER;
  l_deliv_det_id       NUMBER;
  l_container_name     wsh_delivery_details.container_name%TYPE;
  l_container_flag     wsh_delivery_details.container_flag%TYPE;
  l_container_rec      wsh_container_grp.changedattributetabtype;
  -- added for bug 2529382
  l_status_code        VARCHAR2(2);
  l_container_new_name VARCHAR2(30);
  --Bug number:2701925:
  l_delivery_detail_id NUMBER;
  l_delivery_name VARCHAR2(30) := NULL;
  l_debug              NUMBER                                     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  -- Release 12 (K): LPN Synchronization/Convergence
  -- Types needed for WSH_WMS_LPN_GRP.Create_Update_Containers
  l_lpn_cur       WMS_Data_Type_Definitions_PUB.LPNRecordType;
  l_wsh_dd_rec    WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  l_wsh_dd_upd_rec  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  wsh_create_tbl  WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
  wsh_update_tbl  WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
  l_IN_rec        WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
  l_OUT_rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;


BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  /* Release 12(K), changed to use l_lpn_cur as type of WMS_Data_Type_Definitions_PUB.LPNRecordType; */
  OPEN lpn_details;
  LOOP
    l_lpn_cur := null;
    FETCH lpn_details INTO
               l_lpn_cur.lpn_id
             , l_lpn_cur.license_plate_number
             , l_lpn_cur.subinventory_code
             , l_lpn_cur.locator_id
             , l_lpn_cur.inventory_item_id
             , l_lpn_cur.revision
             , l_lpn_cur.lot_number
             , l_lpn_cur.serial_number
             , l_lpn_cur.gross_weight_uom_code
             , l_lpn_cur.gross_weight
             , l_lpn_cur.tare_weight_uom_code
             , l_lpn_cur.tare_weight
             , l_lpn_cur.content_volume_uom_code
             , l_lpn_cur.content_volume
             , l_lpn_cur.container_volume
             , l_lpn_cur.container_volume_uom
             , l_lpn_cur.organization_id;

    IF lpn_details%NOTFOUND THEN
      IF (l_debug = 1) THEN
        DEBUG('No more LPNs found from lpn_details to process', 'create_update_containers');
      END IF;
      EXIT;
    ELSE
      IF (l_debug = 1) THEN
        DEBUG('Found from lpn_details lpn '||l_lpn_cur.license_plate_number||', lpn_id='||l_lpn_cur.lpn_id, 'create_update_containers');
      END IF;
    END IF;


  --FOR l_lpn_cur IN lpn_details LOOP -- Changed for Release 12
    --Reset the counter
    l_count                                := 0;
    l_lpn_id                               := l_lpn_cur.lpn_id;

-- commented the below code for -- For LPN reuse ER : 6845650

    /* part of bug fix 2529382 */
/*  BEGIN
      SELECT wdd.released_status
           , wdd.delivery_detail_id
        INTO l_status_code
           , l_delivery_detail_id
        FROM wsh_delivery_details_ob_grp_v wdd
       WHERE wdd.container_name = l_lpn_cur.license_plate_number
       AND wdd.released_status = 'X';  --Bug#6878521 Made change bt need to chk this

      IF l_status_code = 'C' THEN
        /* Release 12(K): LPN Synchronization
           1. Uniqueness constraint on WDD.container_name is removed
              So it is not required to append characters to the LPNs
              to get a new containers name
           2. Replace API call to wsh_container_grp.update_container
              with new API call WSH_WMS_LPN_GRP.Create_Update_Containers
           */
/*
        IF (l_debug = 1) THEN
          DEBUG('Release status is C, Updating delivery detail to NULL out LPN_ID', 'create_update_containers');
          DEBUG(' Calling Create_Update_Containers with caller WMS, action code UPDATE_NULL', 'create_update_containers');
          DEBUG('  delivery_detail_id = '||l_delivery_detail_id);
        END IF;

        l_wsh_dd_upd_rec.delivery_detail_id := l_delivery_detail_id;
        l_wsh_dd_upd_rec.lpn_id := NULL;

        wsh_update_tbl(1) := l_wsh_dd_upd_rec;

        l_IN_rec.caller      := 'WMS';
        l_IN_rec.action_code := 'UPDATE_NULL';

        WSH_WMS_LPN_GRP.Create_Update_Containers (
          p_api_version     => 1.0
        , p_init_msg_list   => fnd_api.g_false
        , p_commit          => fnd_api.g_false
        , x_return_status   => x_return_status
        , x_msg_count       => x_msg_count
        , x_msg_data        => x_msg_data
        , p_detail_info_tab => wsh_update_tbl
        , p_IN_rec          => l_IN_rec
        , x_OUT_rec         => l_OUT_rec );


        IF (x_return_status IN(fnd_api.g_ret_sts_error)) THEN
          IF (l_debug = 1) THEN
            DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns error', 'create_update_containers');
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          IF (l_debug = 1) THEN
            DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns unexpected error', 'create_update_containers');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        ELSE
          l_count  := 0;
          IF (l_debug = 1) THEN
            DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns success, AF Container exists, set lpn_id to NULL', 'create_update_containers');
          END IF;
        END IF;

      ELSE
        l_count  := 1;

        IF (l_debug = 1) THEN
          DEBUG(' LPN with status ' || l_status_code || 'found in wdd. Check for data corruption');
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count  := 0;
    END;

    /* end of bug fix 2529382 */

    IF (l_debug = 1) THEN
      DEBUG('LPN EXISTS: ' || l_count, 'create_update_containers');
    END IF;

    --If the LPN does not exist in in wsh_delivery_details, create a new container
    IF l_count = 0 THEN

      /* Release 12 (K): LPN Synchronization
         Replace the call to wsh_container_grp.create_containers
         with new API call to WSH_WMS_LPN_GRP.Create_Update_Containers

         The pre-R12 code was doing in two steps, create_container then update_container
         With the new API call, it replaces both previous API calls */

      /* Call function to create wsh delivery detail record */
      l_wsh_dd_rec := WMS_CONTAINER_PVT.To_DeliveryDetailsRecType(l_lpn_cur);

      /*Add l_wsh_dd_rec into record table */

      wsh_create_tbl(NVL(wsh_create_tbl.last, 0) + 1) := l_wsh_dd_rec;

    END IF;

  END LOOP;

  IF (l_debug = 1) THEN
    DEBUG('End of Loop of lpn_details, found '||wsh_create_tbl.count||' records in wsh_create_tbl to process', 'create_update_containers');
    DEBUG('Calling WSH_WMS_LPN_GRP.Create_Update_Containers with caller as WMS and CREATE', 'create_update_containers');
  END IF;

  l_IN_rec.caller      := 'WMS';
  l_IN_rec.action_code := 'CREATE';

  WSH_WMS_LPN_GRP.Create_Update_Containers (
    p_api_version     => 1.0
  , p_init_msg_list   => fnd_api.g_false
  , p_commit          => fnd_api.g_false
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  , p_detail_info_tab => wsh_create_tbl
  , p_IN_rec          => l_IN_rec
  , x_OUT_rec         => l_OUT_rec );


  IF (x_return_status IN(fnd_api.g_ret_sts_error)) THEN
    IF (l_debug = 1) THEN
      DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns error', 'create_update_containers');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
    IF (l_debug = 1) THEN
      DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns unexpected error', 'create_update_containers');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  ELSE
    IF (l_debug = 1) THEN
      DEBUG('WSH_WMS_LPN_GRP.Create_Update_Containers returns success', 'create_update_containers');
    END IF;
  END IF;
  -- End of Release 12 change

  IF (l_debug = 1) THEN
    DEBUG('The API return status is ' || x_return_status, 'create_update_containers');
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Execution Error in Create_Update_Container:' || SUBSTR(SQLERRM, 1, 240), 9);
    END IF;
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in Create_Update_Container:' || SUBSTR(SQLERRM, 1, 240), 'create_update_containers');
    END IF;
  WHEN OTHERS THEN
     --x_error_code := 9999;
     IF l_debug = 1 THEN
    debug('Others exception raised: ' ||  SUBSTR(SQLERRM, 1, 240),'create_update_containers');
     END IF;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('WMS_DIRECT_SHIP_PVT', 'create_update_containers');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END create_update_containers;

PROCEDURE update_shipped_quantity(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, p_delivery_id   IN            NUMBER
, p_org_id        IN            NUMBER DEFAULT NULL
) IS
  -- Cursor to get the delivery qty (sum of all the delivery_details )
  -- for the given delivery_id

  CURSOR delivery_item_qty IS
    SELECT   wdd.inventory_item_id
           , wdd.revision
           , wdd.lot_number
           , SUM(wdd.picked_quantity)
        FROM wms_shipping_transaction_temp wstt, wsh_delivery_details_ob_grp_v wdd
       WHERE wstt.delivery_id = p_delivery_id
         AND wdd.delivery_detail_id = wstt.delivery_detail_id
         AND wdd.released_status = 'Y'
    GROUP BY wdd.inventory_item_id, wdd.revision, wdd.lot_number
    ORDER BY wdd.inventory_item_id, wdd.revision, wdd.lot_number;

  -- Cursor to get the item qty in the LPN corresponding to the given delivery_id
  -- and the inventory item,revision
  CURSOR lpn_item_qty(p_delivery_id NUMBER, p_item_id NUMBER, p_revision VARCHAR2, p_lot_number VARCHAR2) IS
    SELECT SUM(wlc.quantity)
      FROM wms_lpn_contents wlc, wms_license_plate_numbers lpn,
      wms_shipping_transaction_temp wstt
      WHERE wlc.parent_lpn_id = lpn.lpn_id
      and wstt.delivery_id = p_delivery_id
      and lpn.outermost_lpn_id = wstt.outermost_lpn_id
      and wstt.inventory_item_id = p_item_id
      AND wstt.inventory_item_id = wlc.inventory_item_id
      AND NVL(wlc.revision, '#') = NVL(p_revision, '#')
      AND NVL(wlc.lot_number, '#') = NVL(p_lot_number, '#');

  l_item_id             NUMBER;
  l_revision            VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  l_lot_number          VARCHAR2(80);
  l_del_qty             NUMBER;
  l_shipping_attr       wsh_delivery_details_pub.changedattributetabtype;
  l_delivery_detail_id  NUMBER;
  l_picked_qty          NUMBER;
  l_extra_qty           NUMBER;
  l_lpn_qty             NUMBER;
  l_lpn_item_count      NUMBER;
  l_delivery_item_count NUMBER;
  l_init_msg_list       VARCHAR2(1)                                      := fnd_api.g_false;
  l_commit              VARCHAR2(1)                                      := fnd_api.g_false;
  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(20000);
  l_msg_count           NUMBER;
  x_error_code          NUMBER;
  l_debug               NUMBER                                           := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  BEGIN
    --Query to get the total no. of distinct items in the lpn to be shipped

    SELECT   COUNT(COUNT(*))
        INTO l_lpn_item_count
        FROM wms_license_plate_numbers wlpn, wms_lpn_contents wlc, wms_shipping_transaction_temp wstt
       WHERE wstt.delivery_id = p_delivery_id
         AND wstt.outermost_lpn_id = wlpn.outermost_lpn_id
         AND wlpn.lpn_id = wlc.parent_lpn_id
    GROUP BY wlc.inventory_item_id, wlc.revision;

    --Query to get the total no. of distinct items in the delivery

    SELECT   COUNT(COUNT(*))
        INTO l_delivery_item_count
        FROM wms_shipping_transaction_temp wstt, wsh_delivery_details_ob_grp_v wdd
       WHERE wstt.delivery_id = p_delivery_id
         AND wdd.delivery_detail_id = wstt.delivery_detail_id
         AND wdd.released_status = 'Y'
    GROUP BY wdd.inventory_item_id, wdd.revision;

    --Check if lpn has items other than those for the delivery

    IF (l_lpn_item_count > l_delivery_item_count) THEN
      IF (l_debug = 1) THEN
        DEBUG('LPN contains items not belonging to the delivery.', 'Update_shipped_Quantity');
        DEBUG('Cannot ship', 'Update_shipped_Quantity');
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- Log a message for item count mismatch
      x_return_status  := fnd_api.g_ret_sts_error;
      x_error_code     := 10;

      IF (l_debug = 1) THEN
        DEBUG('LPN has more items than Delivery Details', 'Update_Shipped_Quantity');
        DEBUG('Some Items are not assigned to delivery details', 'Update_Shipped_Quantity');
      END IF;
  END; -- END Item Count

  OPEN delivery_item_qty;

  LOOP
    FETCH delivery_item_qty INTO l_item_id, l_revision, l_lot_number, l_del_qty;
    EXIT WHEN delivery_item_qty%NOTFOUND;
    OPEN lpn_item_qty(p_delivery_id, l_item_id, l_revision, l_lot_number);
    FETCH lpn_item_qty INTO l_lpn_qty;
    CLOSE lpn_item_qty;

    -- If LPN has more than delivery and we are shipping more.
    -- Update the delivery detail with the extra qty

    IF (l_lpn_qty > l_del_qty) THEN
      l_extra_qty                            := l_lpn_qty - l_del_qty;

      -- SELECT the first DELIVERY LINE returned from WDD

      BEGIN
        SELECT wdd.delivery_detail_id
             , wdd.picked_quantity
          INTO l_delivery_detail_id
             , l_picked_qty
          FROM wms_shipping_transaction_temp wstt, wsh_delivery_details_ob_grp_v wdd
         WHERE wstt.delivery_id = p_delivery_id
           AND wstt.inventory_item_id = l_item_id
           AND wdd.delivery_detail_id = wstt.delivery_detail_id
           AND wdd.inventory_item_id = wstt.inventory_item_id
           AND NVL(wdd.revision, '#') = NVL(l_revision, '#')
           AND NVL(wdd.lot_number, '#') = NVL(l_lot_number, '#')
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      -- Call WSH_DELIVERY_DETAILS to update the shipped_qty
      l_shipping_attr(1).shipped_quantity    := l_picked_qty + l_extra_qty;
      l_shipping_attr(1).delivery_detail_id  := l_delivery_detail_id;
      wsh_delivery_details_pub.update_shipping_attributes(
        p_api_version_number         => 1.0
      , p_source_code                => 'OE'
      , p_init_msg_list              => l_init_msg_list
      , p_commit                     => l_commit
      , p_changed_attributes         => l_shipping_attr
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      IF (l_debug = 1) THEN
        DEBUG('after calling Update_shipping_attributes', 'Update_shipped_Quantity');
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
          DEBUG('return error from update shipping attributes 2', 'Update_shipped_Quantity');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('return unexpected error from update shipping attributes', 'Update_shipped_Quantity');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = 'S' THEN
        IF (l_debug = 1) THEN
          DEBUG('Shipping attributes updated successfully');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_success;
      END IF;
    END IF; -- end if l_lpn_qty > l_del_qty
  END LOOP;

  CLOSE delivery_item_qty;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    x_error_code     := 10;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Execution Error in Update_shipped_Quantity', 'Update_shipped_Quantity');
      DEBUG('Could not update shipping attributes', 'Update_shipped_Quantity');
    END IF;
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    x_error_code     := 20;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in Update_shipped_Quantity:', 'Update_shipped_Quantity');
      DEBUG('Could not update shipping attributes', 'Update_shipped_Quantity');
    END IF;
  WHEN OTHERS THEN
    x_error_code     := 30;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Could not update shipping attributes', 'Update_shipped_Quantity');
    END IF;
END update_shipped_quantity;



PROCEDURE container_nesting(
  x_return_status    OUT NOCOPY    VARCHAR2
, x_msg_count        OUT NOCOPY    VARCHAR2
, x_msg_data         OUT NOCOPY    VARCHAR2
, p_organization_id  IN            NUMBER
, p_outermost_lpn_id IN            NUMBER
, p_action_code      IN            VARCHAR2 DEFAULT 'PACK') IS
  CURSOR lpn_hierarchy IS
    SELECT DISTINCT NVL(parent_lpn_id, outermost_lpn_id)
               FROM wms_license_plate_numbers
              WHERE organization_id = p_organization_id
              AND outermost_lpn_id = p_outermost_lpn_id
              AND outermost_lpn_id <> lpn_id;

  CURSOR lpn_childs(l_parent_lpn_id NUMBER) IS
    SELECT lpn_id
      FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
       AND parent_lpn_id = l_parent_lpn_id;

  CURSOR container_details(p_organization_id NUMBER, l_lpn_id NUMBER) IS
    SELECT delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v
     WHERE organization_id = p_organization_id
       AND lpn_id = l_lpn_id
       AND released_status = 'X';  -- For LPN reuse ER : 6845650

  l_child_lpn_id      NUMBER;
  l_parent_lpn_id     NUMBER;
  l_par_del_det_id    NUMBER;
  l_child_del_det_id  NUMBER;
  l_child_del_det_tab wsh_util_core.id_tab_type;
  l_par_del_det_tab   wsh_util_core.id_tab_type;

  l_count             NUMBER                    := 0;
  l_parent_counter       NUMBER                    := 0;
  l_debug             NUMBER                    := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  l_dummy_number   NUMBER;
  l_container_flag VARCHAR2(1);

  l_delivery_id    NUMBER;
  l_delivery_planned_flag VARCHAR2(1);
  l_action_prms      wsh_interface_ext_grp.del_action_parameters_rectype;
  l_delivery_id_tab  wsh_util_core.id_tab_type;
  l_delivery_out_rec wsh_interface_ext_grp.del_action_out_rec_type;

  l_trip_action_prms WSH_INTERFACE_EXT_GRP.trip_action_parameters_rectype;
  l_trip_out_rec     WSH_INTERFACE_EXT_GRP.tripactionoutrectype;
  l_trip_id_tab      wsh_util_core.id_tab_type;

  -- Release 12 : LPN SyncUp
  l_wsh_lpn_id_tbl wsh_util_core.id_tab_type;
  l_wsh_del_det_id_tbl wsh_util_core.id_tab_type;
  l_wsh_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
  l_wsh_defaults        WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
  l_wsh_action_out_rec  WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  IF l_debug = 1 THEN
     debug('Entered container_nesting with p_action_code: ' ||p_action_code,
       'Container_Nesting');
  END IF;

  IF p_action_code = 'PACK' THEN
     l_container_flag := 'N';
   ELSIF p_action_code = 'UNPACK' THEN
     l_container_flag := 'Y';
   ELSE
     IF l_debug = 1 THEN
    debug('Invalid p_action_code passed in','Container_Nesting');
     END IF;

     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  --Loop through containers that have nested container
  OPEN lpn_hierarchy;

  LOOP
    FETCH lpn_hierarchy INTO l_parent_lpn_id;
    EXIT WHEN lpn_hierarchy%NOTFOUND;



    IF (l_debug = 1) THEN
      DEBUG('lpn:' || l_child_lpn_id || ' parent:' || l_parent_lpn_id, 'Container_Nesting');
    END IF;


    --Get the delivery detail id for the parent lpn
    OPEN container_details(p_organization_id, l_parent_lpn_id);
    FETCH container_details INTO l_par_del_det_id;
    CLOSE container_details;

    BEGIN
       SELECT 1
     INTO l_dummy_number
     FROM wms_shipping_transaction_temp
     WHERE parent_lpn_id = l_parent_lpn_id
     AND ROWNUM = 1;

       IF (l_debug = 1) THEN
      DEBUG('lpn_id ' || l_parent_lpn_id || ' attached to an item line', 'Container_Nesting');
      debug('No need to unassign from delivery','Container_nesting');
       END IF;

    EXCEPTION
       WHEN no_data_found THEN
      IF (l_debug = 1) THEN
         debug('no item line attached to lpn_id: ' || l_parent_lpn_id,'container_nesting');
         debug('put it in to unassign from delivery' || 'Container_nesting');
      END IF;
      l_parent_counter := l_parent_counter + 1;
      l_par_del_det_tab(l_parent_counter) := l_par_del_det_id;
    END;

    IF l_debug = 1 THEN
       debug('Parent lpn delivery_detail_id: ' || l_par_del_det_id, 'Container_Nesting');
    END IF;

    l_count  := 0;

    -- Release 12: Use new API
    --l_child_del_det_tab.DELETE;
    l_wsh_lpn_id_tbl.DELETE;

    --getting all the children containers of current parent container
    OPEN lpn_childs(l_parent_lpn_id);
    LOOP
      FETCH lpn_childs INTO l_child_lpn_id;
      EXIT WHEN lpn_childs%NOTFOUND;
      l_count                       := l_count + 1;
      --Get the delivery detail id for the child lpn
      -- Release 12, do not need to get delivery detail ID for child lpns
      --  use lpn_ids directly
      /*OPEN container_details(p_organization_id, l_child_lpn_id);
      FETCH container_details INTO l_child_del_det_id;
      CLOSE container_details;
      l_child_del_det_tab(l_count)  := l_child_del_det_id;
      IF (l_debug = 1) THEN
        DEBUG('child det:' || l_child_del_det_tab(l_count) || ' parent: ' || l_par_del_det_id, 'Container_Nesting');
      END IF;*/

      l_wsh_lpn_id_tbl(l_count) := l_child_lpn_id;
      IF (l_debug = 1) THEN
        DEBUG('child lpn:' || l_wsh_lpn_id_tbl(l_count) || ' parent: ' || l_par_del_det_id, 'Container_Nesting');
      END IF;

    END LOOP;-- lpn_childs loop

    CLOSE lpn_childs;

    IF l_wsh_lpn_id_tbl.COUNT > 0 THEN
      -- Relase 12: LPN SyncUp
      -- Replaced call to wsh_container_grp.container_actions
      --  with new API call WSH_WMS_LPN_GRP.Delivery_Detail_Action
      l_wsh_action_prms.caller                  := 'WMS';
      l_wsh_action_prms.action_code             := p_action_code;
      l_wsh_action_prms.lpn_rec.organization_id := p_organization_id;
      l_wsh_action_prms.lpn_rec.lpn_id          := l_parent_lpn_id;

      IF (l_debug = 1) THEN
        DEBUG('Calling WSH_WMS_LPN_GRP.Delivery_Detail_Action with ', 'Container_Nesting');
        DEBUG('  Caller: WMS, action_code:'||p_action_code, 'Container_Nesting');
        DEBUG('  organization_id:'||p_organization_id, 'Container_Nesting');
        DEBUG('  p_action_prms.lpn_rec.lpn_id='||l_parent_lpn_id,  'Container_Nesting');
        DEBUG('  p_lpn_id_tbl with '||l_wsh_lpn_id_tbl.count()||' records',  'Container_Nesting');
      END IF;

      WSH_WMS_LPN_GRP.Delivery_Detail_Action(
        p_api_version_number        => 1.0,
        p_init_msg_list             => fnd_api.g_false,
        p_commit                    => fnd_api.g_false,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        p_lpn_id_tbl                => l_wsh_lpn_id_tbl,
        p_del_det_id_tbl            => l_wsh_del_det_id_tbl,
        p_action_prms               => l_wsh_action_prms,
        x_defaults                  => l_wsh_defaults,
        x_action_out_rec            => l_wsh_action_out_rec
      );

      IF (x_return_status IN(fnd_api.g_ret_sts_error)) THEN
        --debug('WSH_Container_Grp.Container_Actions returns an exec. error','Pack_Lpns);
        IF (l_debug = 1) THEN
          DEBUG('Exec. error in packing' || SUBSTR(SQLERRM, 1, 240) || ' ret st:' || x_return_status, 'Container_Nesting');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        --debug('WSH_Container_Grp.Container_Actions returns an unexp. error','Pack_Lpns);
        IF (l_debug = 1) THEN
          DEBUG('Unexp. error in packing', 'Container_Nesting');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        IF (l_debug = 1) THEN
          DEBUG('Nesting is success. Outermost LPN ID: ' || p_outermost_lpn_id, 'Container_Nesting');
        END IF;
      END IF;
    END IF;
  END LOOP; --lpn_hierarchy cursor loop

  CLOSE lpn_hierarchy;


  --if unpacking, also unassign the outer LPNs from delivery so that STF will
  --show the same state as before load.  The inner-most LPN will not be unassigned
  IF p_action_code = 'UNPACK' AND l_par_del_det_tab.COUNT > 0 THEN
       BEGIN
      --make sure delivery is assigned to the LPNs
      --Any of the LPN will do since they should be assigned to the same delivery
      SELECT wda.delivery_id
        INTO l_delivery_id
        FROM wsh_delivery_assignments_v wda
        WHERE wda.delivery_detail_id = l_par_del_det_tab(1)
        AND wda.delivery_id IS NOT NULL;

      DEBUG('Unpack delivery_id is: ' || l_delivery_id, 'Container_Nesting');

      SELECT wnd.planned_flag
        INTO l_delivery_planned_flag
        FROM wsh_new_deliveries_ob_grp_v wnd
        WHERE wnd.delivery_id = l_delivery_id;

      DEBUG('Unpack delivery planned status: ' || l_delivery_planned_flag,'Container_Nesting');
       EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
        DEBUG('Unpack other exception..delivery not assign to LPN? ','Container_Nesting');
        debug(SQLERRM, 'Container_Nesting');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
       END;

       IF l_delivery_planned_flag NOT IN ('Y','F') THEN
      DEBUG('Delivery not planned. Just unassign the outer LPN lines','Container_Nesting');
      wsh_container_grp.container_actions
        (p_api_version => 1.0,
         p_init_msg_list => G_TRUE,
         p_commit => G_FALSE,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_detail_tab => l_par_del_det_tab,
         p_delivery_flag => 'Y',
         p_action_code => 'UNASSIGN');



      IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR)
        THEN
         debug('Unassign from delivery failed' , 'Container_Nesting');
         debug('wsh_container_grp.container_actions returned ' ||
           x_return_status,'Container_Nesting');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      DEBUG('Delivery is planned.','Container_Nesting');
      IF l_delivery_planned_flag = 'F' THEN
         DEBUG('Unfirming trip first','Container_Nesting');
         l_trip_action_prms.caller := 'WMS';
         l_trip_action_prms.action_code := 'UNPLAN';

         BEGIN
        SELECT DISTINCT trip_id
          INTO l_trip_id_tab(1)
          FROM wms_shipping_transaction_temp
          WHERE delivery_id = l_delivery_id;

        debug('Trip id: ' || l_trip_id_tab(1),'Container_Nesting');
         EXCEPTION
        WHEN OTHERS THEN
           debug('Cannot find trip ID?','Container_Nesting');
           debug(SQLERRM,'Container_Nesting');
           RAISE fnd_api.g_exc_unexpected_error;
         END;

         wsh_interface_ext_grp.trip_action
           (p_api_version_number     => 1.0,
        p_init_msg_list          => fnd_api.g_false,
        p_commit                 => fnd_api.g_false,
        p_action_prms            => l_trip_action_prms,
        p_entity_id_tab        => l_trip_id_tab,
        x_trip_out_rec       => l_trip_out_rec,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
        );

         IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
        DEBUG('Unfirming trip failed!','Container_Nesting');
        debug('msg_data: ' || x_msg_data,'Container_Nesting');
        RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      l_action_prms.caller := 'WMS';
      l_action_prms.action_code := 'UNPLAN';

      l_delivery_id_tab(1) := l_delivery_id;

      DEBUG('Unfirm delivery','Container_Nesting');
      wsh_interface_ext_grp.delivery_action
        (p_api_version_number     => 1.0,
         p_init_msg_list          => fnd_api.g_false,
         p_commit                 => fnd_api.g_false,
         p_action_prms            => l_action_prms,
         p_delivery_id_tab        => l_delivery_id_tab,
         x_delivery_out_rec       => l_delivery_out_rec,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);

      IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
         DEBUG('Unfirming delivery failed!','Container_Nesting');
         debug('msg_data: ' || x_msg_data,'Container_Nesting');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      DEBUG('Unassign the lines from delivery','Container_Nesting');
      wsh_container_grp.container_actions
        (p_api_version => 1.0,
         p_init_msg_list => G_TRUE,
         p_commit => G_FALSE,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_detail_tab => l_par_del_det_tab,
         p_delivery_flag => 'Y',
         p_action_code => 'UNASSIGN');

      IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
         DEBUG('Unassigning from delivery failed!','Container_Nesting');
         debug('msg_data: ' || x_msg_data,'Container_Nesting');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_delivery_planned_flag = 'Y' THEN

         l_action_prms.action_code := 'PLAN';
         DEBUG('Planned flag is Y need to firm back the delivery','Container_Nesting');
         wsh_interface_ext_grp.delivery_action
           (p_api_version_number     => 1.0,
        p_init_msg_list          => fnd_api.g_false,
        p_commit                 => fnd_api.g_false,
        p_action_prms            => l_action_prms,
        p_delivery_id_tab        => l_delivery_id_tab,
        x_delivery_out_rec       => l_delivery_out_rec,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data);

         IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
        DEBUG('Firming delivery failed!','Container_Nesting');
        debug('msg_data: ' || x_msg_data,'Container_Nesting');
        RAISE fnd_api.g_exc_unexpected_error;
         END IF;

       else
         debug('Planned flag is F. Firm back the trip: ' || l_trip_id_tab(1),'Container_Nesting');
         l_trip_action_prms.action_code := 'FIRM';

         wsh_interface_ext_grp.trip_action
           (p_api_version_number     => 1.0,
        p_init_msg_list          => fnd_api.g_false,
        p_commit                 => fnd_api.g_false,
        p_action_prms            => l_trip_action_prms,
        p_entity_id_tab        => l_trip_id_tab,
        x_trip_out_rec       => l_trip_out_rec,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
        );

         IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
        DEBUG('Firming trip failed!','Container_Nesting');
        debug('msg_data: ' || x_msg_data,'Container_Nesting');
        RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
       END IF;
  END IF;--p_action_code = 'UNPACK'

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF container_details%ISOPEN THEN
      CLOSE container_details;
    END IF;

    IF lpn_hierarchy%ISOPEN THEN
      CLOSE lpn_hierarchy;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Execution Error in lpn_hiearchy:' || x_msg_data || '-' || SUBSTR(SQLERRM, 1, 240), 'Container_Nesting');
    END IF;
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      DEBUG('Unexpected Error in lpn_hiearchy:' || SUBSTR(SQLERRM, 1, 240) || SQLCODE, 'Container_Nesting');
    END IF;

    IF container_details%ISOPEN THEN
      CLOSE container_details;
    END IF;

    IF lpn_hierarchy%ISOPEN THEN
      CLOSE lpn_hierarchy;
    END IF;
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    ROLLBACK;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    --debug('Unexpected Error in pack_lpns:' || substr(SQLERRM,1,240),9);
    IF (l_debug = 1) THEN
      DEBUG('When others in lpn_hiearchy:' || SUBSTR(SQLERRM, 1, 240) || SQLCODE, 'Container_Nesting');
    END IF;

    IF container_details%ISOPEN THEN
      CLOSE container_details;
    END IF;

    IF lpn_hierarchy%ISOPEN THEN
      CLOSE lpn_hierarchy;
    END IF;
END container_nesting;

PROCEDURE check_order_line_split(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, x_error_code    OUT NOCOPY    NUMBER
, p_delivery_id   IN            NUMBER
) IS
  CURSOR lpn_cur IS
    SELECT   parent_lpn_id
           , COUNT(parent_lpn_id) cnt
        FROM wms_shipping_transaction_temp
       WHERE delivery_id = p_delivery_id
    GROUP BY parent_lpn_id;

  l_lpn_cur          lpn_cur%ROWTYPE;
  l_par_del_det_id   NUMBER;
  l_count_del_assign NUMBER;
  lpn_name           VARCHAR2(30);
  l_debug            NUMBER            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;
  x_error_code     := NULL;
  OPEN lpn_cur;

  LOOP
    FETCH lpn_cur INTO l_lpn_cur;
    EXIT WHEN lpn_cur%NOTFOUND;

    SELECT delivery_detail_id
      INTO l_par_del_det_id
      FROM wsh_delivery_details_ob_grp_v
     WHERE lpn_id = l_lpn_cur.parent_lpn_id
     AND released_status = 'X'; -- For LPN reuse ER : 6845650

    SELECT COUNT(*)
      INTO l_count_del_assign
      FROM wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd
     WHERE wda.parent_delivery_detail_id = l_par_del_det_id
       AND wda.delivery_detail_id = wdd.delivery_detail_id
       AND NVL(wdd.container_flag, 'N') = 'N';

    IF l_count_del_assign <> l_lpn_cur.cnt THEN
      SELECT license_plate_number
        INTO lpn_name
        FROM wms_license_plate_numbers
       WHERE lpn_id = l_lpn_cur.parent_lpn_id;

      fnd_message.set_name('WMS', 'WMS_ORDER_LINE_SPLIT');
      fnd_message.set_token('CONTAINER_NAME', lpn_name);
      fnd_msg_pub.ADD;
      x_error_code  := 7;
      RAISE fnd_api.g_exc_error;

      --dbms_output.put_line('Contents of the container '||lpn_name||' are split in order management');
      IF (l_debug = 1) THEN
        DEBUG('Contents of the container ' || lpn_name || ' are split in order management', 'CHECK_ORDER_LINE_SPLIT');
      END IF;
    END IF;
  END LOOP;

  CLOSE lpn_cur;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;

    IF lpn_cur%ISOPEN THEN
      CLOSE lpn_cur;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('In Exception (expected error) - E ', 'CHECK_ORDER_LINE_SPLIT');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF lpn_cur%ISOPEN THEN
      CLOSE lpn_cur;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('In UnException (unexpected error) - U ', 'CHECK_ORDER_LINE_SPLIT');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF lpn_cur%ISOPEN THEN
      CLOSE lpn_cur;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('In Exception (When others) - U ', 'CHECK_ORDER_LINE_SPLIT');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END check_order_line_split;

PROCEDURE check_missing_item_cur(
  p_delivery_id     IN            NUMBER
, p_dock_door_id    IN            NUMBER
, p_organization_id IN            NUMBER
, x_return_status   OUT NOCOPY    VARCHAR2
, x_missing_count   OUT NOCOPY    NUMBER
) IS
  l_count NUMBER;
  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_missing_count  := 0;
  x_return_status  := fnd_api.g_ret_sts_success;

  SELECT COUNT(*)
    INTO l_count
    FROM wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, mtl_system_items_kfv msik
   WHERE wda.delivery_detail_id = wdd.delivery_detail_id
     AND NVL(wdd.container_flag, 'N') = 'N'
     AND wda.delivery_id = p_delivery_id
     AND wdd.inventory_item_id = msik.inventory_item_id
     AND wdd.organization_id = msik.organization_id
     AND(
         (wda.parent_delivery_detail_id IS NULL
          AND msik.mtl_transactions_enabled_flag <> 'N')
         OR wdd.released_status IS NULL
         OR wdd.released_status NOT IN('X', 'Y')
        );

  IF l_count > 0 THEN
    x_missing_count  := l_count;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_count  := 0;
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('Unexp-Error in missing item procedure ', 'CHECK_MISSING_ITEM_CUR');
    END IF;
END check_missing_item_cur;

PROCEDURE chk_del_for_direct_ship(
  x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
, p_delivery_id   IN            NUMBER
) IS
  l_flag_y                NUMBER;
  l_flag_n                NUMBER;
  l_num                   NUMBER;

  TYPE parent_del_detail_ids IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  l_parent_del_detail_ids parent_del_detail_ids;

  CURSOR parent_del_detail IS
    SELECT delivery_detail_id
      FROM wsh_delivery_details_ob_grp_v
     WHERE lpn_id IN(SELECT parent_lpn_id
                       FROM wms_shipping_transaction_temp
                      WHERE delivery_id = p_delivery_id
                        AND direct_ship_flag = 'Y');

  CURSOR del_detail IS
    SELECT parent_delivery_detail_id
      FROM wsh_delivery_assignments_v
     WHERE delivery_id = p_delivery_id
       AND delivery_detail_id NOT IN(SELECT delivery_detail_id
                                       FROM wsh_delivery_details_ob_grp_v
                                      WHERE lpn_id IN(SELECT parent_lpn_id
                                                        FROM wms_shipping_transaction_temp
                                                       WHERE delivery_id = p_delivery_id
                                                         AND direct_ship_flag = 'Y'));

  l_debug                 NUMBER                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  x_return_status  := fnd_api.g_ret_sts_success;

  BEGIN
    SELECT NVL(SUM(DECODE(direct_ship_flag, 'Y', 1)), 0) l_flag_y
         , NVL(SUM(DECODE(direct_ship_flag, 'N', 1)), 0) l_flag_n
      INTO l_flag_y
         , l_flag_n
      FROM wms_shipping_transaction_temp wstt
     WHERE wstt.delivery_id = p_delivery_id
       AND dock_appoint_flag = 'N';

    IF l_flag_n = 0 THEN
      IF (l_debug = 1) THEN
        DEBUG('No records in wstt for direct ship flag =N', 'chk_del_for_direct_ship');
      END IF;

      RAISE NO_DATA_FOUND;
    ELSIF l_flag_n > 0 THEN
      IF (l_debug = 1) THEN
        DEBUG('Records in wstt for direct ship flag =N', 'chk_del_for_direct_ship');
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;
  --DBMS_OUTPUT.PUT_LINE('tHERE ARE NO LINES WITH DIRECT_FLAG =N');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT 1
          INTO l_num
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd
                  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                    AND wda.delivery_id = p_delivery_id
                    AND wdd.released_status = 'Y'
                    AND NVL(container_flag, 'N') = 'N'
                    AND NOT EXISTS(
                         SELECT 1
                           FROM wms_shipping_transaction_temp wstt
                          WHERE wstt.delivery_detail_id = wdd.delivery_detail_id
                            AND wstt.delivery_id = p_delivery_id
                            AND wstt.direct_ship_flag = 'Y'
                            AND wstt.dock_appoint_flag = 'N'));

        IF (l_debug = 1) THEN
          DEBUG('This delivery has lines from other source othan than direct_ship', 'chk_del_for_direct_ship');
        END IF;

        --dbms_output.put_line('This delivery has lines from other source othan than direct_ship');
        IF (l_debug = 1) THEN
          DEBUG('Checking for line split', 'chk_del_for_direct_ship');
        END IF;

        l_parent_del_detail_ids.DELETE;

        FOR l_p_del_detail IN parent_del_detail LOOP
          l_parent_del_detail_ids(l_p_del_detail.delivery_detail_id)  := 1;
        END LOOP;

        --
        FOR l_del_detail IN del_detail LOOP
          IF NOT l_parent_del_detail_ids.EXISTS(l_del_detail.parent_delivery_detail_id) THEN
            IF (l_debug = 1) THEN
              DEBUG(
                'Delivery line ' || l_del_detail.parent_delivery_detail_id || ' is packed in different container'
              , 'chk_del_for_direct_ship'
              );
              DEBUG('Check failed', 'chk_del_for_direct_ship');
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            DEBUG('This delivery has lines that were loaded through Direct ship ', 'chk_del_for_direct_ship');
          END IF;

          NULL;
      END;
  END;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END chk_del_for_direct_ship;


--Bug#5262108.This is to determine the qty remaining to pick
-- considering the overship tolerance , existing reservation, etc.
FUNCTION Get_qty_to_pick(
   p_order_header_id NUMBER,
   p_order_line_id   NUMBER,
   p_org_id          NUMBER) RETURN NUMBER
IS
  l_allowed_flag              VARCHAR2(1);
  l_max_quantity_allowed      NUMBER := 0 ;
  l_avail_req_quantity        NUMBER := 0 ;
  l_staged_qty                NUMBER := 0 ;
  l_total_resvd_qty           NUMBER := 0 ;
  l_return_status             VARCHAR2(30);
  l_line_set_id               NUMBER  ;
  l_debug                     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN

        IF (l_debug = 1) THEN
                DEBUG('In Get_qty_to_pick  p_order_header_id '|| p_order_header_id , 'Get_qty_to_pick');
                DEBUG('p_order_line_id '|| p_order_line_id ||',org:'||p_org_id, 'Get_qty_to_pick');
        END IF;

         --Call Shipping API to ger the qty remaining to pick
	WSH_DETAILS_VALIDATIONS.Check_Quantity_To_Pick(
               p_order_line_id         =>p_order_line_id,
               p_quantity_to_pick      => 0,
               x_allowed_flag          => l_allowed_flag,
               x_max_quantity_allowed  => l_max_quantity_allowed,
               x_avail_req_quantity    => l_avail_req_quantity,
               x_return_status         => l_return_status) ;

	IF (l_debug = 1) THEN
        	DEBUG('l_allowed_flag='||l_allowed_flag,'Get_qty_to_pick');
          	DEBUG('l_max_quantity_allowed='||l_max_quantity_allowed,'Get_qty_to_pick');
          	DEBUG('l_avail_req_quantity='||l_avail_req_quantity,'Get_qty_to_pick');
          	DEBUG('l_return_status='||l_return_status,'Get_qty_to_pick');
        END IF;
	IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Check_Quantity_To_Pick API failed , ERROR ', 'Get_qty_to_pick');
              END IF;
              RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Check_Quantity_To_Pick API failed,UNEXPECTED ERROR', 'Get_qty_to_pick');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
        END IF;

	BEGIN

         SELECT nvl(wdd.source_line_set_id,wdd.source_line_id) into l_line_set_id
         FROM wsh_delivery_details wdd
	 WHERE wdd.source_header_id = p_order_header_id
         AND wdd.source_line_id= p_order_line_id
	 AND rownum<2;

	 IF (l_debug = 1) THEN
        	DEBUG('l_line_set_id/line_id : '  || l_line_set_id,'Get_qty_to_pick');
         END IF;

          --Calculate the staged qty for the line set which curr line belongs to.
          SELECT  nvl(sum(nvl(picked_quantity,0)),0) INTO l_staged_qty
	  FROM wsh_delivery_details wdd
	  WHERE source_header_id = p_order_header_id
	  AND released_status='Y'
	  AND nvl(source_line_set_id,source_line_id) =  l_line_set_id;

         IF (l_debug = 1) THEN
        	DEBUG('l_staged_qty : '  || l_staged_qty,'Get_qty_to_pick');
         END IF;

          --Calculate the reserved qty for the line set which curr line belongs to.
	  SELECT nvl(SUM(nvl(primary_reservation_quantity,0)),0) INTO l_total_resvd_qty
          FROM mtl_reservations
          WHERE organization_id= p_org_id
	  AND nvl(staged_flag,'N') = 'Y'
	  AND demand_source_line_id in ( SELECT source_line_id
                                         FROM wsh_delivery_details wdd
	                                 WHERE source_header_id = p_order_header_id
	                                 AND released_status='Y'
	                                 AND nvl(source_line_set_id,source_line_id) =  l_line_set_id );


	 IF (l_debug = 1) THEN
        	DEBUG('l_total_resvd_qty : '  || l_total_resvd_qty,'Get_qty_to_pick');
         END IF;
       EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
	    DEBUG(' OTHERS EXCEPTION !!! ' ,'Get_qty_to_pick');
	  END IF;
	  RAISE fnd_api.g_exc_unexpected_error;
          return -1;
       END;

       return ( nvl(l_max_quantity_allowed,0) + nvl(l_staged_qty,0) - nvl(l_total_resvd_qty,0) );

END Get_qty_to_pick;

/* Start of Patchset I procedures */

/* This procedure process all the lines reserved against a LPN passed as parameter.
   Following tasks are performed here
   (a) table lpn_contents_tab is populated from l_lpn_contents_cur;
   (b) lpn material is checked for valid material status
   (c) each reserved line is checked if it is booked or not
   (d) PJM parameters are checked for each reserved line
   (e) delivery grouping rules are checked for each reserved line
   (f) User holds are checked for each reserved line
   (g) WDS is populated for all the reserved lines
 */

PROCEDURE process_lpn(
  p_lpn_id                       IN            NUMBER
, p_org_id                       IN            NUMBER
, p_dock_door_id                               NUMBER
, x_remaining_qty                OUT NOCOPY    NUMBER
, x_num_line_processed           OUT NOCOPY    NUMBER
, x_project_id                   OUT NOCOPY    NUMBER
, x_task_id                      OUT NOCOPY    NUMBER
, x_cross_project_allowed        OUT NOCOPY    VARCHAR2
, x_cross_unit_allowed           OUT NOCOPY    VARCHAR2
, x_group_by_customer_flag       OUT NOCOPY    VARCHAR2
, x_group_by_fob_flag            OUT NOCOPY    VARCHAR2
, x_group_by_freight_terms_flag  OUT NOCOPY    VARCHAR2
, x_group_by_intmed_ship_flag    OUT NOCOPY    VARCHAR2
, x_group_by_ship_method_flag    OUT NOCOPY    VARCHAR2
, x_group_by_ship_to_loc_value   OUT NOCOPY    VARCHAR2
, x_group_by_ship_from_loc_value OUT NOCOPY    VARCHAR2
, x_group_by_customer_value      OUT NOCOPY    VARCHAR2
, x_group_by_fob_value           OUT NOCOPY    VARCHAR2
, x_group_by_freight_terms_value OUT NOCOPY    VARCHAR2
, x_group_by_intmed_value        OUT NOCOPY    VARCHAR2
, x_group_by_ship_method_value   OUT NOCOPY    VARCHAR2
, x_ct_wt_enabled                OUT NOCOPY    NUMBER
, x_return_status                OUT NOCOPY    VARCHAR2
, x_msg_count                    OUT NOCOPY    NUMBER
, x_msg_data                     OUT NOCOPY    VARCHAR2
) IS
  TYPE processed_line_rec IS RECORD(
    header_id            NUMBER
  , line_id              NUMBER
  , inventory_item_id    NUMBER
  , processed_flag       VARCHAR2(1)
  , serial_required_flag VARCHAR(1)
  , processed_quantity   NUMBER
  );

  TYPE order_line_rec IS RECORD(
    header_id            NUMBER
  , line_id              NUMBER
  , inventory_item_id    NUMBER
  , revision             VARCHAR2(3)
  , ordered_quantity     NUMBER
  , project_id           NUMBER
  , task_id              NUMBER
  , serial_control_code  NUMBER
  , end_item_unit_number VARCHAR2(30)
  , flow_status_code     VARCHAR2(30)
  );

  TYPE processed_lines_tab IS TABLE OF processed_line_rec
    INDEX BY BINARY_INTEGER;

  -- local variables
  l_sub_reservable_type         NUMBER;
  l_lpn_contents_lookup_rec     lpn_contents_lookup_rec;
  l_group_by_ship_to_loc_flag   VARCHAR2(1)                                     := 'Y';
  l_group_by_ship_from_loc_flag VARCHAR2(1)                                     := 'Y';

  -- Bug# 3464013
  TYPE l_lpn_content_cur_rec_typ IS RECORD(
    lpn_id                       wms_license_plate_numbers.lpn_id%TYPE
  , subinventory_code            wms_license_plate_numbers.subinventory_code%TYPE
  , locator_id                   wms_license_plate_numbers.locator_id%TYPE
  , inventory_item_id            wms_lpn_contents.inventory_item_id%TYPE
  , revision             wms_lpn_contents.revision%TYPE
  , lot_number                   wms_lpn_contents.lot_number%TYPE
  , quantity                     wms_lpn_contents.quantity%TYPE
  , revision_control             VARCHAR2(5)
  , lot_control                  VARCHAR2(5)
  , serial_control               VARCHAR2(5)
  , serial_control_code          mtl_system_items_b.serial_number_control_code%TYPE
  , reservable_type              mtl_system_items_b.reservable_type%TYPE
  , end_item_unit_number         mtl_serial_numbers.end_item_unit_number%TYPE
  , ont_pricing_qty_source       VARCHAR2(30)
  );
  l_lpn_content_cur_rec l_lpn_content_cur_rec_typ;

  l_qry_reservation_record      inv_reservation_global.mtl_reservation_rec_type;
  l_mtl_reservation_tab         inv_reservation_global.mtl_reservation_tbl_type;

  l_old_upd_resv_rec            inv_reservation_global.mtl_reservation_rec_type; --bug#5262108
  l_new_upd_resv_rec            inv_reservation_global.mtl_reservation_rec_type; --bug#5262108
  l_upd_dummy_sn                inv_reservation_global.serial_number_tbl_type;   --bug#5262108

  l_processed_lines_tab         processed_lines_tab;
  l_order_line_rec              order_line_rec;
  l_start_index                 NUMBER                                          := 1;
  l_end_index                   NUMBER                                          := 1;
  l_prev_item_id                NUMBER                                          := 0;
  l_num_line_processed          NUMBER                                          := 0;
  l_oe_order_header_id          NUMBER;
  l_return_status               VARCHAR2(30);
  l_msg_data                    VARCHAR2(20000);
  l_msg_count                   NUMBER;
  l_error_code                  NUMBER;
  l_temp_index                  NUMBER;
  l_mtl_reservation_tab_count   NUMBER;
  l_trx_temp_id                 NUMBER;
  l_order_line_status           NUMBER;

  -- for end unit validation

  TYPE skipped_line_tab IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  l_skipped_line_tab            skipped_line_tab;
  l_debug                       NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  -- Bug# 3464013: Replaced the static cursor with dynamic ref cursor
  l_sql_query                   VARCHAR2(10000);
  TYPE l_lpn_contents_cur_type IS REF CURSOR;
  l_lpn_contents_cur            l_lpn_contents_cur_type;
  l_qty_to_pick                 NUMBER :=0 ;  --Bug#5262108
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('Process_LPN called with parameters : p_lpn_id = ' || p_lpn_id || ' : p_org_id = ' || p_org_id, 'Process_LPN');
  END IF;

  x_return_status       := fnd_api.g_ret_sts_success;
  x_ct_wt_enabled := 0;
  --clear all cached data structures
  g_lpn_contents_tab.DELETE;
  g_lpn_contents_lookup_tab.DELETE;
  g_total_lpn_quantity  := 0;
  g_checked_delivery_tab.DELETE;
  l_processed_lines_tab.DELETE;
  g_subinventory_code   := NULL;
  g_locator_id          := NULL;
  g_del_grp_rls_flags.DELETE;
  g_del_grp_rls_fld_value.DELETE;
  g_del_grp_rls_fld_temp.DELETE;
  g_checked_deliveries.DELETE;
  l_skipped_line_tab.DELETE;
  -- initializa who columns for session
  g_creation_date       := SYSDATE;
  g_created_by          := fnd_global.user_id;
  g_last_updated_by     := g_created_by;
  g_last_update_login   := fnd_global.login_id;
  g_last_update_date    := g_creation_date;
  -- cleaning temp data if the delivery was backordered for this lpn somethimes in past
  wms_direct_ship_pvt.cleanup_orphan_rec(p_org_id);

  IF (l_debug = 1) THEN
    DEBUG('Corrupted temp data cleaned ', 'Process_LPN');
  END IF;

  -- check if the sub in which lpn resides is reservable or not
  BEGIN
    SELECT sub.reservable_type
      INTO l_sub_reservable_type
      FROM mtl_secondary_inventories sub
     WHERE sub.secondary_inventory_name = (SELECT subinventory_code
                                             FROM wms_license_plate_numbers
                                            WHERE lpn_id = p_lpn_id)
       AND organization_id = p_org_id;

    IF (l_debug = 1) THEN
      DEBUG('l_sub_reservable_type= ' || l_sub_reservable_type, 'Process_LPN');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        DEBUG('Exception getting reservable type of sub', 'Process_LPN');
      END IF;

      RAISE fnd_api.g_exc_error;
  END;

  IF l_sub_reservable_type <> 1 THEN
    IF (l_debug = 1) THEN
      DEBUG('LPN containes non reservable items', 'Process_LPN');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_SUB_NON_RESERVABLE');
    fnd_msg_pub.ADD;
    RETURN;
  ELSE
    IF (l_debug = 1) THEN
      DEBUG('Before getting LPN contents ', 'Process_LPN');
    END IF;

    -- Bug# 3464013: Replaced the static cursor with dynamic ref cursor
    l_sql_query :=
    '    SELECT   wlpn.lpn_id ' ||
    '           , wlpn.subinventory_code ' ||
    '           , wlpn.locator_id ' ||
    '           , wlc.inventory_item_id ' ||
    '           , wlc.revision ' ||
    '           , wlc.lot_number ' ||
    '           , DECODE( ' ||
    '               wlc.uom_code ' ||
    '             , msi.primary_uom_code, NVL(msn.quantity, wlc.quantity) ' ||
    '             , GREATEST(inv_convert.inv_um_convert(NULL, NULL, NVL(msn.quantity, wlc.quantity), wlc.uom_code, msi.primary_uom_code, NULL ' ||
    '                 , NULL) ' ||
    '               , 0) ' ||
    '             ) quantity ' ||
    '           , DECODE(msi.revision_qty_control_code, 2, ''TRUE'', ''FALSE'') revision_control ' ||
    '           , DECODE(msi.lot_control_code, 2, ''TRUE'', ''FALSE'') lot_control ' ||
    '           , DECODE(msi.serial_number_control_code, 1, ''FALSE'', ''TRUE'') serial_control ' ||
    '           , msi.serial_number_control_code serial_control_code ' ||
    '           , msi.reservable_type ' ||
    '           , msn.end_item_unit_number ';

    IF (G_WMS_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL) THEN
      l_sql_query := l_sql_query || '      , msi.ont_pricing_qty_source ';
    ELSE
      l_sql_query := l_sql_query || '      , NULL ont_pricing_qty_source ';
    END IF;

    l_sql_query := l_sql_query ||
    '        FROM wms_lpn_contents wlc ' ||
    '           , wms_license_plate_numbers wlpn ' ||
    '           , mtl_system_items_b msi ' ||
    '           , (SELECT   lpn_id ' ||
    '                , revision ' ||
    '            , lot_number ' ||
    '                     , inventory_item_id ' ||
    '                     , end_item_unit_number ' ||
    '                     , COUNT(1) quantity ' ||
    '                  FROM mtl_serial_numbers ' ||
    '                 WHERE lpn_id IN(SELECT lpn_id ' ||
    '                                   FROM wms_license_plate_numbers ' ||
    '                                  WHERE organization_id = :p_org_id ' ||
    '                                    AND outermost_lpn_id = :p_lpn_id) ' ||
    '              GROUP BY lpn_id, revision, lot_number, inventory_item_id, end_item_unit_number) msn ' ||
    '       WHERE msi.inventory_item_id = wlc.inventory_item_id ' ||
    '         AND wlpn.lpn_id = wlc.parent_lpn_id ' ||
    '         AND wlpn.outermost_lpn_id = :p_lpn_id ' ||
    '         AND wlpn.organization_id = :p_org_id ' ||
    '         AND msi.organization_id = :p_org_id ' ||
    '         AND msn.lpn_id(+) = wlc.parent_lpn_id ' ||
    '         AND msn.inventory_item_id(+) = wlc.inventory_item_id ' ||
    '         AND NVL(msn.lot_number(+),''#NULL#'') = NVL(wlc.lot_number,''#NULL#'') ' ||
    '         AND NVL(msn.revision(+),''#NULL#'') = NVL(wlc.revision,''#NULL#'') ' ||
    '    ORDER BY wlc.inventory_item_id ';

    -- This cursor fetches lpn contents data for all the inner lpns packed into outer lpn.
    OPEN l_lpn_contents_cur FOR l_sql_query USING p_org_id, p_lpn_id, p_lpn_id, p_org_id, p_org_id;
    LOOP
      FETCH l_lpn_contents_cur INTO l_lpn_content_cur_rec;
      EXIT WHEN l_lpn_contents_cur%NOTFOUND;

      -- check if item is no reservable stop processing lpn
      IF l_lpn_content_cur_rec.reservable_type <> 1 THEN
        IF (l_debug = 1) THEN
          DEBUG('LPN containes non reservable items', 'Process_LPN');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('WMS', 'WMS_ITEM_NON_RESERVABLE');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;

      l_end_index                                            := l_lpn_contents_cur%ROWCOUNT;
      g_lpn_contents_tab(l_end_index).lpn_id                 := l_lpn_content_cur_rec.lpn_id;
      g_lpn_contents_tab(l_end_index).subinventory_code      := l_lpn_content_cur_rec.subinventory_code;
      g_lpn_contents_tab(l_end_index).locator_id             := l_lpn_content_cur_rec.locator_id;
      g_lpn_contents_tab(l_end_index).inventory_item_id      := l_lpn_content_cur_rec.inventory_item_id;
      g_lpn_contents_tab(l_end_index).revision               := l_lpn_content_cur_rec.revision;
      g_lpn_contents_tab(l_end_index).lot_number             := l_lpn_content_cur_rec.lot_number;
      g_lpn_contents_tab(l_end_index).serial_control_code    := l_lpn_content_cur_rec.serial_control_code;
      g_lpn_contents_tab(l_end_index).quantity               := l_lpn_content_cur_rec.quantity;
      g_lpn_contents_tab(l_end_index).end_item_unit_number   := l_lpn_content_cur_rec.end_item_unit_number;
      g_total_lpn_quantity                                   := g_total_lpn_quantity + l_lpn_content_cur_rec.quantity;

      -- For Catch Weight
      IF (G_WMS_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
          x_ct_wt_enabled = 0 AND l_lpn_content_cur_rec.ont_pricing_qty_source = 'S') THEN
        x_ct_wt_enabled := 1;
      END IF;

      IF l_lpn_content_cur_rec.serial_control = 'TRUE' THEN
        g_lpn_contents_tab(l_end_index).serial_control  := TRUE;
      ELSE
        g_lpn_contents_tab(l_end_index).serial_control  := FALSE;
      END IF;

      IF l_lpn_content_cur_rec.lot_control = 'TRUE' THEN
        g_lpn_contents_tab(l_end_index).lot_control  := TRUE;
      ELSE
        g_lpn_contents_tab(l_end_index).lot_control  := FALSE;
      END IF;

      IF l_lpn_content_cur_rec.revision_control = 'TRUE' THEN
        g_lpn_contents_tab(l_end_index).revision_control  := TRUE;
      ELSE
        g_lpn_contents_tab(l_end_index).revision_control  := FALSE;
      END IF;

      -- populate l_lpn_contents_lookup_tab
      IF l_prev_item_id = 0 THEN
        l_prev_item_id  := l_lpn_content_cur_rec.inventory_item_id;
      END IF;

      IF (l_prev_item_id <> l_lpn_content_cur_rec.inventory_item_id) THEN
        l_start_index   := l_end_index;
        l_prev_item_id  := l_lpn_content_cur_rec.inventory_item_id;
      END IF;

      g_lpn_contents_lookup_tab(l_prev_item_id).start_index  := l_start_index;
      g_lpn_contents_lookup_tab(l_prev_item_id).end_index    := l_end_index;

      -- add current record quantity to g_total_lpn_quantity
      IF (l_debug = 1) THEN
        DEBUG('LPN_CONTENT_RECORDS', 'Process_LPN');
        DEBUG(
             'LPN_ID='
          || l_lpn_content_cur_rec.lpn_id
          || ' :ITEM_ID= '
          || l_lpn_content_cur_rec.inventory_item_id
          || ' :REVISION= '
          || l_lpn_content_cur_rec.revision
          || ' :LOT_NUMBER '
          || l_lpn_content_cur_rec.lot_number
          || ' :QUANTITY= '
          || l_lpn_content_cur_rec.quantity
          || ' :EIUN= '
          || l_lpn_content_cur_rec.end_item_unit_number
        , 'Process_LPN'
        );
      END IF;
    END LOOP; -- l_lpn_content_cur

    CLOSE l_lpn_contents_cur;

    IF (l_debug = 1) THEN
      DEBUG('Number of LPN content records ' || g_lpn_contents_tab.COUNT, 'Process_LPN');
      DEBUG('G_total_lpn_quantity =' || g_total_lpn_quantity, 'Process_LPN');
    END IF;

    IF g_lpn_contents_tab.COUNT = 0 THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_EMPTY_LPN');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        DEBUG('LPN is empty', 'Process_LPN');
      END IF;

      RETURN;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('After getting LPN contents ', 'Process_LPN');
    END IF;

    -- perform material status check
    IF (l_debug = 1) THEN
      DEBUG('Before call to material status check', 'Process_LPN');
    END IF;

    wms_direct_ship_pvt.validate_status_lpn_contents(x_return_status => l_return_status, x_msg_count => l_msg_count
    , x_msg_data                   => l_msg_data, p_lpn_id => p_lpn_id, p_org_id => p_org_id);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Validate Status LPN Contents procedure failed with error status E ', 'Process_LPN');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_MAT_STATUS');
      fnd_msg_pub.ADD;
      RETURN;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Validate Status LPN Contents procedure failed with error status U ', 'Process_LPN');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_MAT_STATUS');
      fnd_msg_pub.ADD;
      RETURN;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Validate status is success ', 'Process_LPN');
      DEBUG('After call to material status check', 'Process_LPN');
    END IF;

    -- set subinventory and locator
    g_subinventory_code      := g_lpn_contents_tab(1).subinventory_code;
    g_locator_id             := g_lpn_contents_tab(1).locator_id;

    -- get PJM parameters
    BEGIN
      SELECT allow_cross_proj_issues
           , allow_cross_unitnum_issues
        INTO g_cross_project_allowed
           , g_cross_unit_allowed
        FROM pjm_org_parameters
       WHERE organization_id = p_org_id;

      IF (l_debug = 1) THEN
        DEBUG('g_cross_project_allowed= ' || g_cross_project_allowed || ' g_cross_unit_allowed= ' || g_cross_unit_allowed, 'Process_LPN');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_cross_project_allowed  := 'Y';
        g_cross_unit_allowed     := 'Y';
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          DEBUG('Exception getting PJM Parameters ', 'Process_LPN');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
    END;

    x_cross_project_allowed  := g_cross_project_allowed;
    x_cross_unit_allowed     := g_cross_unit_allowed;

    IF (l_debug = 1) THEN
      DEBUG('g_cross_project_allowed= ' || g_cross_project_allowed, 'Process_LPN');
      DEBUG('g_cross_unit_allowed= ' || g_cross_unit_allowed, 'Process_LPN');
    END IF;

    -- get project and task id
    IF g_cross_project_allowed = 'N' THEN
      BEGIN
        SELECT project_id
             , task_id
          INTO g_project_id
             , g_task_id
          FROM mtl_item_locations
         WHERE inventory_location_id = g_lpn_contents_tab(1).locator_id;

        IF (l_debug = 1) THEN
          DEBUG('g_project_id= ' || g_project_id || ' g_task_id= ' || g_task_id, 'Process_LPN');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            DEBUG('Exception getting Project and Task Ids ', 'Process_LPN');
          END IF;

          x_return_status  := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
      END; -- get project and task id

      x_project_id  := g_project_id;
      x_task_id     := g_task_id;
    END IF;

    -- get Delivery Grouping Rule flags
    BEGIN
      SELECT group_by_customer_flag
           , group_by_fob_flag
           , group_by_freight_terms_flag
           , group_by_intmed_ship_to_flag
           , group_by_ship_method_flag
        INTO x_group_by_customer_flag
           , x_group_by_fob_flag
           , x_group_by_freight_terms_flag
           , x_group_by_intmed_ship_flag
           , x_group_by_ship_method_flag
        FROM wsh_shipping_parameters
       WHERE organization_id = p_org_id;

      IF (l_debug = 1) THEN
        DEBUG('l_group_by_customer_flag= ' || x_group_by_customer_flag, 'Process_LPN');
        DEBUG('l_group_by_fob_flag= ' || x_group_by_fob_flag, 'Process_LPN');
        DEBUG('l_group_by_freight_terms_flag= ' || x_group_by_freight_terms_flag, 'Process_LPN');
        DEBUG('l_group_by_intmed_ship_flag= ' || x_group_by_intmed_ship_flag, 'Process_LPN');
        DEBUG('l_group_by_ship_method_flag= ' || x_group_by_ship_method_flag, 'Process_LPN');
      END IF;

      -- populate delivery grouping flags table
      g_del_grp_rls_flags(1)  := l_group_by_ship_from_loc_flag;
      g_del_grp_rls_flags(2)  := l_group_by_ship_to_loc_flag;
      g_del_grp_rls_flags(3)  := x_group_by_customer_flag;
      g_del_grp_rls_flags(4)  := x_group_by_fob_flag;
      g_del_grp_rls_flags(5)  := x_group_by_freight_terms_flag;
      g_del_grp_rls_flags(6)  := x_group_by_intmed_ship_flag;
      g_del_grp_rls_flags(7)  := x_group_by_ship_method_flag;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          DEBUG('No data found for delivery grouping flags', 'Process_LPN');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          DEBUG('Exception getting delivery grouping rule flags', 'Process_LPN');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
    END;

    -- start process lines reserved against this lpn
    IF (l_debug = 1) THEN
      DEBUG('Starting processing of reserved lines', 'Process_LPN');
    END IF;

    FOR c_index IN 1 .. g_lpn_contents_tab.COUNT LOOP
      -- query reservations for a line
      IF (l_debug = 1) THEN
        DEBUG('Querying reservations for lpn_contents_rec ' || c_index, 'Process_LPN');
      END IF;

      l_qry_reservation_record.inventory_item_id      := g_lpn_contents_tab(c_index).inventory_item_id;
      l_qry_reservation_record.revision               := g_lpn_contents_tab(c_index).revision;
      l_qry_reservation_record.lot_number             := g_lpn_contents_tab(c_index).lot_number;
      l_qry_reservation_record.lpn_id                 := g_lpn_contents_tab(c_index).lpn_id;
      l_qry_reservation_record.supply_source_type_id  := inv_reservation_global.g_source_type_inv;
      l_mtl_reservation_tab.DELETE;
      inv_reservation_pub.query_reservation(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_query_input                => l_qry_reservation_record
      , p_lock_records               => fnd_api.g_false
      , x_mtl_reservation_tbl        => l_mtl_reservation_tab
      , x_mtl_reservation_tbl_count  => l_mtl_reservation_tab_count
      , x_error_code                 => l_error_code
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Reservation query api failed', 'Process_LPN');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Reservation query api failed', 'Process_LPN');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('Reservation records found = ' || l_mtl_reservation_tab.COUNT, 'Process_LPN');
      END IF;

      IF l_mtl_reservation_tab.COUNT > 0 THEN
        FOR resv_index IN 1 .. l_mtl_reservation_tab.COUNT LOOP
          --  fetch line data
          BEGIN
            SELECT oel.header_id
                 , oel.line_id
                 , oel.inventory_item_id
                 , oel.item_revision
                 , DECODE(
                     oel.order_quantity_uom
                   , msi.primary_uom_code, oel.ordered_quantity
                   , GREATEST(
                       inv_convert.inv_um_convert(NULL, NULL, oel.ordered_quantity, oel.order_quantity_uom, msi.primary_uom_code, NULL
                       , NULL)
                     , 0
                     )
                   ) ordered_quantity
                 , oel.project_id
                 , oel.task_id
                 , msi.serial_number_control_code
                 , oel.end_item_unit_number
                 , oel.flow_status_code
              INTO l_order_line_rec
              FROM oe_order_lines_all oel, mtl_system_items msi
             WHERE msi.organization_id = p_org_id
               AND oel.inventory_item_id = msi.inventory_item_id
               AND line_id = l_mtl_reservation_tab(resv_index).demand_source_line_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('No data found for line', 'Process_LPN');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                DEBUG('Exception getting data for line ', 'Process_LPN');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
          END;

          IF (l_debug = 1) THEN
            DEBUG('Processing line: ', 'Process_LPN');
            DEBUG('l_order_line_rec.header_id: ' || l_order_line_rec.header_id, 'Process_LPN');
            DEBUG('l_order_line_rec.line_id: ' || l_order_line_rec.line_id, 'Process_LPN');
            DEBUG('l_order_line_rec.inventory_item_id: ' || l_order_line_rec.inventory_item_id, 'Process_LPN');
            --DEBUG('l_order_line_rec.item_revision: ' || l_order_line_rec.item_revision, 'Process_LPN');
            DEBUG('l_order_line_rec.ordered_quantity: ' || l_order_line_rec.ordered_quantity, 'Process_LPN');
            DEBUG('l_order_line_rec.project_id: ' || l_order_line_rec.project_id, 'Process_LPN');
            DEBUG('l_order_line_rec.task_id: ' || l_order_line_rec.task_id, 'Process_LPN');
            --DEBUG('l_order_line_rec.serial_number_control_code: ' ||
                  -- l_order_line_rec.serial_number_control_code, 'Process_LPN');
            DEBUG('l_order_line_rec.end_item_unit_number: ' ||
                   l_order_line_rec.end_item_unit_number, 'Process_LPN');
            DEBUG('l_order_line_rec.flow_status_code: ' ||
                   l_order_line_rec.flow_status_code, 'Process_LPN');

          END IF;

          /*IF l_order_line_rec.flow_status_code NOT IN ('AWAITING_SHIPPING', THEN
             IF (l_debug = 1) THEN
                DEBUG('Order Line not booked','Process_LPN');
             END IF;
             x_return_status:=FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('WMS','WMS_LINE_NOT_BOOKED');
             FND_MSG_PUB.ADD;
             RETURN;
          END IF;*/
          --Bug 2909327:Changed the call to check wsh_delivery_details instead of oel*/
          BEGIN
            SELECT 1
              INTO l_order_line_status
              FROM DUAL
             WHERE EXISTS(SELECT delivery_detail_id
                          FROM wsh_delivery_details_ob_grp_v
                          WHERE released_status IN('R', 'B')
                          AND source_line_id = l_order_line_rec.line_id
                          UNION ALL -- bug 4232713 - Need to consider staged WDD lines for overpicking scenarios
                          SELECT wdd.delivery_detail_id
                          FROM wsh_delivery_details_ob_grp_v wdd, wms_direct_ship_temp wds
                          WHERE wdd.released_status = 'Y'
                          AND wdd.source_line_id = wds.order_line_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('Order Line not booked', 'Process_LPN');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              fnd_message.set_name('WMS', 'WMS_LINE_NOT_BOOKED');
              fnd_msg_pub.ADD;
              RETURN;
          END;
          IF (l_debug = 1) THEN
             DEBUG('l_order_line_status: '|| l_order_line_status, 'Process_LPN');
             DEBUG('g_cross_project_allowed: '|| g_cross_project_allowed, 'Process_LPN');
          END IF;

          -- check PJM Parameters
          IF g_cross_project_allowed <> 'Y' THEN
            IF g_project_id <> l_order_line_rec.project_id
               OR g_task_id <> l_order_line_rec.task_id THEN
              IF (l_debug = 1) THEN
                DEBUG('Validation of PJM parameters failed', 'Process_LPN');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              fnd_message.set_name('WMS', 'WMS_PJM_VALIDATION_FAILED');
              fnd_msg_pub.ADD;
              RETURN;
            END IF;
          END IF;

          IF (l_debug = 1) THEN
              DEBUG('validate_end_unit_num_at ' ,'Process_LPN');
          END IF;
          -- check end_item_unit_num
          IF NOT wms_direct_ship_pvt.validate_end_unit_num_at(c_index, l_order_line_rec.end_item_unit_number) THEN
            l_skipped_line_tab(l_order_line_rec.line_id)  := 1;

            IF (l_debug = 1) THEN
              DEBUG('line ' || l_order_line_rec.line_id || ' put into skipped line', 'Process_LPN');
            END IF;

            GOTO skip_line; -- line
          ELSE
            IF l_skipped_line_tab.EXISTS(l_order_line_rec.line_id) THEN
              l_skipped_line_tab.DELETE(l_order_line_rec.line_id);

              IF (l_debug = 1) THEN
                DEBUG('line ' || l_order_line_rec.line_id || ' removed from skipped lines', 'Process_LPN');
              END IF;

              -- check if lpn has enough quantity to satisfy reservation for end unit num
              IF g_lpn_contents_tab(c_index).quantity < l_mtl_reservation_tab(resv_index).primary_reservation_quantity THEN
                IF (l_debug = 1) THEN
                  DEBUG('LPN quantity is less then the reserved quantity', 'Process_LPN');
                END IF;

                x_return_status  := fnd_api.g_ret_sts_error;
                fnd_message.set_name('WMS', 'WMS_PJM_VALIDATION_FAILED');
                fnd_msg_pub.ADD;
                RETURN;
              END IF;
            END IF;
          END IF;

          -- validate delivery grouping rules
          IF NOT wms_direct_ship_pvt.validate_del_grp_rules(l_num_line_processed, l_order_line_rec.header_id, l_order_line_rec.line_id) THEN
            IF (l_debug = 1) THEN
              DEBUG('Delivery grouping failed', 'Process_LPN');
            END IF;

            x_return_status  := fnd_api.g_ret_sts_error;
            fnd_message.set_name('WMS', 'WMS_DEL_GRP_FAILED');
            fnd_msg_pub.ADD;
            RETURN;
          END IF;

          -- check delivery for direct ship
          IF NOT wms_direct_ship_pvt.validate_del_for_ds(p_lpn_id, p_org_id, p_dock_door_id, l_order_line_rec.header_id
                , l_order_line_rec.line_id) THEN
            IF (l_debug = 1) THEN
              DEBUG('Checl del for direct ship failed', 'Process_LPN');
            END IF;

            x_return_status  := fnd_api.g_ret_sts_error;
            fnd_message.set_name('WMS', 'WMS_DEL_LINES_MIX');
            fnd_msg_pub.ADD;
            RETURN;
          END IF;

          IF l_num_line_processed = 0 THEN                                -- needs to be set only once
                                           -- set out parameters
            x_group_by_ship_from_loc_value  := g_del_grp_rls_fld_temp(1);
            x_group_by_ship_to_loc_value    := g_del_grp_rls_fld_temp(2);
            x_group_by_customer_value       := g_del_grp_rls_fld_temp(3);
            x_group_by_fob_value            := g_del_grp_rls_fld_temp(4);
            x_group_by_freight_terms_value  := g_del_grp_rls_fld_temp(5);
            x_group_by_intmed_value         := g_del_grp_rls_fld_temp(6);
            x_group_by_ship_method_value    := g_del_grp_rls_fld_temp(7);

            IF (l_debug = 1) THEN
              DEBUG('Delivery grouping field values set to return parameters', 'Process_LPN');
            END IF;
          END IF;

          -- check holds
          check_holds(
            p_order_header_id            => l_order_line_rec.header_id
          , p_order_line_id              => l_order_line_rec.line_id
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Check Holds Failed', 'Process_LPN');
            END IF;

            x_return_status  := fnd_api.g_ret_sts_error;
            fnd_message.set_name('WMS', 'WMS_HOLD_APPLIED');
            fnd_msg_pub.ADD;
            RETURN;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Check holds Failed :Unexpected', 'Process_LPN');
            END IF;

            x_return_status  := fnd_api.g_ret_sts_error;
            fnd_message.set_name('WMS', 'WMS_HOLD_APPLIED');
            fnd_msg_pub.ADD;
            RETURN;
          ELSE
            IF (l_debug = 1) THEN
              DEBUG('Check Holds Succeeded', 'Process LPN');
            END IF;
          END IF;

          -- get oe_order_header_id from sales order header id
          inv_salesorder.get_oeheader_for_salesorder(
            p_salesorder_id              => l_mtl_reservation_tab(resv_index).demand_source_header_id
          , x_oe_header_id               => l_oe_order_header_id
          , x_return_status              => l_return_status
          );

          IF (l_debug = 1) THEN
            DEBUG('l_oe_order_header_id = ' || l_oe_order_header_id, 'Process_LPN');
            DEBUG('l_oe_order_line_id = ' || l_mtl_reservation_tab(resv_index).demand_source_line_id, 'Process_LPN');
          END IF;

          --Bug5262108. Begin. Check qty to pick considering overship tolerance.
	  l_qty_to_pick := WMS_DIRECT_SHIP_PVT.Get_qty_to_pick(
	                     l_oe_order_header_id,
		             l_mtl_reservation_tab(resv_index).demand_source_line_id ,
		             p_org_id);
           IF (l_debug = 1) THEN
             DEBUG('l_qty_to_pick = ' || l_qty_to_pick, 'Process_LPN');
	     DEBUG('reservation_id= ' || l_mtl_reservation_tab(resv_index).reservation_id, 'Process_LPN');
             DEBUG('primary_reservation_quantity='||l_mtl_reservation_tab(resv_index).primary_reservation_quantity, 'Process_LPN');

           END IF;

          IF (l_qty_to_pick > 0 ) THEN
	     IF ( l_mtl_reservation_tab(resv_index).primary_reservation_quantity > l_qty_to_pick ) THEN
                 l_mtl_reservation_tab(resv_index).primary_reservation_quantity := l_qty_to_pick ;
		   --Need to update the reservation.
	          l_old_upd_resv_rec.reservation_id               := l_mtl_reservation_tab(resv_index).reservation_id;
                  l_new_upd_resv_rec.primary_reservation_quantity := l_mtl_reservation_tab(resv_index).primary_reservation_quantity ;
                  l_new_upd_resv_rec.reservation_quantity         := l_mtl_reservation_tab(resv_index).primary_reservation_quantity ;
                  l_new_upd_resv_rec.staged_flag                  :='Y';

                  inv_reservation_pub.update_reservation(
		      p_api_version_number         => 1.0
	            , p_init_msg_lst               => fnd_api.g_false
	            , x_return_status              => l_return_status
		    , x_msg_count                  => l_msg_count
	            , x_msg_data                   => l_msg_data
		    , p_original_rsv_rec           => l_old_upd_resv_rec
	            , p_to_rsv_rec                 => l_new_upd_resv_rec
	            , p_original_serial_number     => l_upd_dummy_sn
	            , p_to_serial_number           => l_upd_dummy_sn
	            , p_validation_flag            => fnd_api.g_true
		    );
            ELSE
	          inv_staged_reservation_util.update_staged_flag(
		           x_return_status              => l_return_status,
                           x_msg_count                  => l_msg_count ,
                           x_msg_data                   => l_msg_data,
                           p_reservation_id             => l_mtl_reservation_tab(resv_index).reservation_id ,
                           p_staged_flag                => 'Y'
                  );
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Update reservation failed for reservation_id ' || l_old_upd_resv_rec.reservation_id, 'Process_LPN');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Update reservation failed for reservation_id with status U' ||l_old_upd_resv_rec.reservation_id, 'Process_LPN');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

         ELSE
	   EXIT;
	 END IF;
         --Bug#5262108.ends

          -- update processed quantity
          IF l_processed_lines_tab.EXISTS(l_mtl_reservation_tab(resv_index).demand_source_line_id) THEN
            -- set processed quantity
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_quantity  :=
                 l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_quantity
               + l_mtl_reservation_tab(resv_index).primary_reservation_quantity;
          ELSE
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_quantity  :=
                                                                             l_mtl_reservation_tab(resv_index).primary_reservation_quantity;
            -- set header id
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).header_id           := l_oe_order_header_id;
            -- set line id
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).line_id             :=
                                                                                    l_mtl_reservation_tab(resv_index).demand_source_line_id;
            -- set item id
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).inventory_item_id   :=
                                                                                        l_mtl_reservation_tab(resv_index).inventory_item_id;

            IF g_lpn_contents_tab(c_index).serial_control_code = 6 THEN
              l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).serial_required_flag  := 'Y';

              IF (l_debug = 1) THEN
                DEBUG('Serial control code = ' || g_lpn_contents_tab(c_index).serial_control_code, 'Process_LPN');
              END IF;
            ELSE
              l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).serial_required_flag  := 'N';

              IF (l_debug = 1) THEN
                DEBUG('Serial control code = ' || g_lpn_contents_tab(c_index).serial_control_code, 'Process_LPN');
              END IF;
            END IF;

            -- increment the number of lines processed
            l_num_line_processed                                                                               := l_num_line_processed + 1;
          END IF;

          -- update lpn_content_rec and g_total_lpn_quantity
          g_lpn_contents_tab(c_index).quantity  :=
                                     (
                                      g_lpn_contents_tab(c_index).quantity - l_mtl_reservation_tab(resv_index).primary_reservation_quantity
                                     );
          g_total_lpn_quantity                  :=(g_total_lpn_quantity - l_mtl_reservation_tab(resv_index).primary_reservation_quantity);

          IF l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_quantity =
                                                                                                           l_order_line_rec.ordered_quantity THEN
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_flag  := 'Y';
          ELSE
            l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_flag  := 'N';
          END IF;

          IF (l_debug = 1) THEN
            DEBUG(
              'Processed quantity=' || l_processed_lines_tab(l_mtl_reservation_tab(resv_index).demand_source_line_id).processed_quantity
            , 'Process_LPN'
            );
          END IF;

          <<skip_line>>
          IF (l_debug = 1) THEN
            DEBUG('dummy', 'Process_LPN');
          END IF;
        END LOOP; --l_mtl_reservation_tab.count
      END IF; -- l_mtl_reservation_tab.count>0
    END LOOP;           -- for g_lpn_contents_tab
              -- if there is any record in l_skipped_line_tab then fail because for atleat one line
              -- end unit validation failed

    IF l_skipped_line_tab.COUNT > 0 THEN
      IF (l_debug = 1) THEN
        DEBUG('End item unit validation failed', 'Process_LPN');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_PJM_VALIDATION_FAILED');
      fnd_msg_pub.ADD;
      RETURN;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('All reserved lines processed. Num= ' || l_num_line_processed, 'Process_LPN');
    END IF;

    x_num_line_processed     := l_num_line_processed;
    x_remaining_qty          := g_total_lpn_quantity;

    IF (l_debug = 1) THEN
      DEBUG('G_total_lpn_quantity =' || g_total_lpn_quantity, 'Process_LPN');
    END IF;

    -- get group_id
    BEGIN
      SELECT mtl_material_transactions_s.NEXTVAL
        INTO g_group_id
        FROM DUAL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_group_id  := 0;
    END;

    IF (l_debug = 1) THEN
      DEBUG('Group Id= ' || g_group_id, 'Process_LPN');
    END IF;

    -- insert data into wds
     IF l_num_line_processed > 0 THEN
    IF (l_debug = 1) THEN
      DEBUG('Inserting records into WDS', 'Process_LPN');
    END IF;

       l_temp_index  := l_processed_lines_tab.FIRST;

      WHILE l_temp_index IS NOT NULL LOOP
        IF (l_debug = 1) THEN
          DEBUG('l_temp_index = ' || l_temp_index, 'Process_LPN');
          DEBUG('header_id= ' || l_processed_lines_tab(l_temp_index).header_id, '');
          DEBUG('line_id= ' || l_processed_lines_tab(l_temp_index).line_id, '');
          DEBUG('processed_flag= ' || l_processed_lines_tab(l_temp_index).processed_flag, '');
          DEBUG('processed_quantity= ' || l_processed_lines_tab(l_temp_index).processed_quantity, '');
          DEBUG('serial_required_flag= ' || l_processed_lines_tab(l_temp_index).serial_required_flag, '');
        END IF;

        IF (l_processed_lines_tab(l_temp_index).serial_required_flag = 'Y') THEN
          BEGIN
            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_trx_temp_id
              FROM DUAL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('Unable to get transaction_temp_id', 'Process_LPN');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
          END;
        ELSE
          l_trx_temp_id  := NULL;
        END IF;

        INSERT INTO wms_direct_ship_temp
                    (
                     GROUP_ID
                   , organization_id
                   , dock_door_id
                   , lpn_id
                   , order_header_id
                   , order_line_id
                   , line_item_id
                   , processed_quantity
                   , processed_flag
                   , serial_required_flag
                   , transaction_temp_id
                   , creation_date
                   , created_by
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                    )
             VALUES (
                     g_group_id
                   , p_org_id
                   , p_dock_door_id
                   , p_lpn_id
                   , l_processed_lines_tab(l_temp_index).header_id
                   , l_processed_lines_tab(l_temp_index).line_id
                   , l_processed_lines_tab(l_temp_index).inventory_item_id
                   , l_processed_lines_tab(l_temp_index).processed_quantity
                   , l_processed_lines_tab(l_temp_index).processed_flag
                   , l_processed_lines_tab(l_temp_index).serial_required_flag
                   , l_trx_temp_id
                   , g_creation_date
                   , g_created_by
                   , g_last_update_date
                   , g_last_updated_by
                   , g_last_update_login
                    );

        l_temp_index  := l_processed_lines_tab.NEXT(l_temp_index);
      END LOOP;
    END IF;
  END IF; --l_sub_reservable_type

  IF (l_debug = 1) THEN
    DEBUG('Completed successfully ', 'Process_LPN');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Unexpected error occured: ' || SQLERRM, 'Process_LPN');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_ERROR_LOADING_LPN');
    fnd_msg_pub.ADD;
END process_lpn;

/* This procedure creates reservations for a line if it is not there and
   inserts processed line record into WDS.
*/

PROCEDURE process_line(
  p_lpn_id               IN            NUMBER
, p_org_id               IN            NUMBER
, p_dock_door_id                       NUMBER
, p_order_header_id      IN            NUMBER
, p_order_line_id        IN            NUMBER
, p_inventory_item_id    IN            NUMBER
, p_revision             IN            VARCHAR2
, p_end_item_unit_number IN            VARCHAR2
, p_ordered_quantity     IN            NUMBER
, p_processed_quantity   IN            NUMBER
, p_date_requested       IN            DATE
, p_primary_uom_code     IN            VARCHAR2
, x_remaining_quantity   OUT NOCOPY    NUMBER
, x_return_status        OUT NOCOPY    VARCHAR2
, x_msg_count            OUT NOCOPY    NUMBER
, x_msg_data             OUT NOCOPY    VARCHAR2
) IS
  -- for query reservation
  l_qry_reservation_record    inv_reservation_global.mtl_reservation_rec_type;
  l_mtl_reservation_tab       inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_reservation_tab_temp  inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_reservation_tab_count NUMBER;
  l_mtl_resv_tab_count_temp   NUMBER;
  l_return_status             VARCHAR2(10);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(20000);
  l_error_code                NUMBER;
  -- genaral
  l_resv_rec                  inv_reservation_global.mtl_reservation_rec_type;
  l_demand_source_header_id   NUMBER;
  l_order_source_id           NUMBER;
  l_demand_source_type_id     NUMBER;
  l_quantity_reserved         NUMBER                                          := 0;
  l_quantity_to_transfer_resv NUMBER                                          := 0;
  l_quantity_create_resv      NUMBER                                          := 0;
  l_qty_reserved_tmp          NUMBER                                          := 0;
  l_create_reservation_flag   VARCHAR2(1)                                     := 'N';
  l_reservable_type           NUMBER;
  l_processed_quantity        NUMBER                                          := p_processed_quantity;
  l_start_index               NUMBER;
  l_end_index                 NUMBER;
  l_lpn_cont_rec              lpn_content_rec;
  l_serial_required_flag      VARCHAR2(1)                                     := 'N';
  l_trx_temp_id               NUMBER;
  l_temp_var                  NUMBER;
  -- For quantity tree declaration
  l_transactable_qty          NUMBER;
  l_qoh                       NUMBER;
  l_rqoh                      NUMBER;
  l_qr                        NUMBER;
  l_qs                        NUMBER;
  l_atr                       NUMBER;
  -- For transfer reservation
  l_old_resv_rec              inv_reservation_global.mtl_reservation_rec_type;
  l_new_resv_rec              inv_reservation_global.mtl_reservation_rec_type;
  l_dummy_sn                  inv_reservation_global.serial_number_tbl_type;
  l_new_rsv_id                NUMBER;
  l_current_rsv_rem_qty      NUMBER;
  -- For create_reservation
  l_reservation_record        inv_reservation_global.mtl_reservation_rec_type;
  l_quantity_reserved_tmp     NUMBER;
  l_reservation_id            NUMBER;
  -- For Update reservation
  l_upd_resv_rec              inv_reservation_global.mtl_reservation_rec_type;
  l_old_upd_resv_rec          inv_reservation_global.mtl_reservation_rec_type;
  l_upd_dummy_sn              inv_reservation_global.serial_number_tbl_type;
  l_chk_resv_qty              NUMBER;
  l_resv_id                   NUMBER;
  l_other_resv_qty            NUMBER;
  l_debug                     NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_count_wdst                NUMBER; --Bug#4546137.
  l_overship_case             VARCHAR2(1) := 'N' ;   --Bug#5262108
  l_qty_to_pick               NUMBER; --Bug#5262108.
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('Procedure Process_Line called with parameters....', 'Process_Line');
    DEBUG('p_lpn_id ' || p_lpn_id, 'Process_Line');
    DEBUG('p_org_id ' || p_org_id, 'Process_Line');
    DEBUG('p_order_header_id ' || p_order_header_id, 'Process_Line');
    DEBUG('p_order_line_id ' || p_order_line_id, 'Process_Line');
    DEBUG('p_inventory_item_id ' || p_inventory_item_id, 'Process_Line');
    DEBUG('p_revision ' || p_revision, 'Process_Line');
    DEBUG('p_end_item_unit_number ' || p_end_item_unit_number, 'Process_Line');
    DEBUG('p_ordered_quantity ' || p_ordered_quantity, 'Process_Line');
    DEBUG('p_processed_quantity ' || p_processed_quantity, 'Process_Line');
  END IF;

  -- get start_index and end_index for inventory_item_id in g_lpn_contents_tab
  IF g_lpn_contents_lookup_tab.EXISTS(p_inventory_item_id) THEN
    l_start_index  := g_lpn_contents_lookup_tab(p_inventory_item_id).start_index;
    l_end_index    := g_lpn_contents_lookup_tab(p_inventory_item_id).end_index;

    -- set serial required flag
    IF g_lpn_contents_tab(l_start_index).serial_control_code = 6 THEN
      l_serial_required_flag  := 'Y';

      IF (l_debug = 1) THEN
        DEBUG('Serial control code = ' || g_lpn_contents_tab(l_start_index).serial_control_code, 'Process_Line');
      END IF;
    ELSE
      l_serial_required_flag  := 'N';

      IF (l_debug = 1) THEN
        DEBUG('Serial control code = ' || g_lpn_contents_tab(l_start_index).serial_control_code, 'Process_Line');
      END IF;
    END IF;
  ELSE
    IF (l_debug = 1) THEN
      DEBUG('Line item not found in LPN', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_ITEM_NOT_AVAILABLE');
    fnd_msg_pub.ADD;
    RETURN;
  END IF;

  --ACTION
  -- validate end unit
  IF NOT wms_direct_ship_pvt.validate_end_unit_num(p_inventory_item_id, p_end_item_unit_number) THEN
    IF (l_debug = 1) THEN
      DEBUG('End item unit validation failed', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_PJM_VALIDATION_FAILED');
    fnd_msg_pub.ADD;
    RETURN;
  END IF;

  -- checkk delivery for irect ship
  IF NOT wms_direct_ship_pvt.validate_del_for_ds(p_lpn_id, p_org_id, p_dock_door_id, p_order_line_id, p_order_header_id) THEN
    IF (l_debug = 1) THEN
      DEBUG('Checl del for direct ship failed', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_DEL_LINES_MIX');
    fnd_msg_pub.ADD;
    RETURN;
  END IF;

  -- check holds
  check_holds(
    p_order_header_id            => p_order_header_id
  , p_order_line_id              => p_order_line_id
  , x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Check Holds Failed', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_HOLD_APPLIED');
    fnd_msg_pub.ADD;
    RETURN;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Check Holds Failed', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_HOLD_APPLIED');
    fnd_msg_pub.ADD;
    RETURN;
  ELSE
    IF (l_debug = 1) THEN
      DEBUG('Check Holds Succeeded', 'Process Line');
    END IF;
  END IF;

  -- get demand source type
  BEGIN
    SELECT order_source_id
      INTO l_order_source_id
      FROM oe_order_headers_all
     WHERE header_id = p_order_header_id;

    IF l_order_source_id = 10 THEN
      l_demand_source_type_id  := 8;
    ELSE
      l_demand_source_type_id  := 2;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('l_demand_source_type_id =' || l_demand_source_type_id, 'Process_Line');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        DEBUG('Exception getting l_demand_source_type_id ', 'Process_Line');
      END IF;

      RAISE fnd_api.g_exc_error;
  END;

   --Bug#5262108. This to decide if it is overship or not.
   --If no WDD is present to be staged, the qty will be zero to
   --facilitate overshipping
   IF p_ordered_quantity  = 0 AND p_processed_quantity = 0  THEN
     l_overship_case := 'Y' ;
   END IF;

  -- query reservations for header_id, line_id
  l_demand_source_header_id                         := inv_salesorder.get_salesorder_for_oeheader(p_order_header_id);
  l_qry_reservation_record.demand_source_header_id  := l_demand_source_header_id;
  l_qry_reservation_record.demand_source_line_id    := p_order_line_id;
  l_qry_reservation_record.supply_source_type_id    := inv_reservation_global.g_source_type_inv;

  IF (l_debug = 1) THEN
    DEBUG('Before call to query reservation', 'Prpcess_Line');
  END IF;

  inv_reservation_pub.query_reservation(
    p_api_version_number         => 1.0
  , p_init_msg_lst               => fnd_api.g_false
  , x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_query_input                => l_qry_reservation_record
  , p_lock_records               => fnd_api.g_false
  , x_mtl_reservation_tbl        => l_mtl_reservation_tab_temp
  , x_mtl_reservation_tbl_count  => l_mtl_resv_tab_count_temp
  , x_error_code                 => l_error_code
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Query reservation failed', 'Process_Line');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Query reservation failed', 'Process_Line');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1) THEN
    DEBUG('After call to query reservation', 'Prpcess_Line');
    DEBUG('reservation records before sub and loc filter = ' || l_mtl_resv_tab_count_temp, 'Process_Line');
  END IF;

  -- filter reservation records based on sub and locator
  l_mtl_reservation_tab_count                       := 0;

  IF l_mtl_resv_tab_count_temp > 0 THEN
    l_other_resv_qty  := 0;

    FOR rec IN 1 .. l_mtl_resv_tab_count_temp LOOP
      l_resv_rec  := l_mtl_reservation_tab_temp(rec);

      IF (
          (l_resv_rec.subinventory_code = g_subinventory_code
           OR l_resv_rec.subinventory_code IS NULL)
          AND(l_resv_rec.locator_id = g_locator_id
              OR l_resv_rec.locator_id IS NULL)
         ) THEN
        l_mtl_reservation_tab_count                         := l_mtl_reservation_tab_count + 1;
        l_mtl_reservation_tab(l_mtl_reservation_tab_count)  := l_mtl_reservation_tab_temp(rec);
      ELSE
        l_other_resv_qty  := l_other_resv_qty + l_resv_rec.primary_reservation_quantity;
      END IF;
    END LOOP; -- for rec
  END IF; --l_mtl_reservation_tab_count_temp>0

  IF (l_debug = 1) THEN
    DEBUG('reservation records after sub and loc filter = ' || l_mtl_reservation_tab_count, 'Process_Line');
    DEBUG('l_other_resv_qty=' || l_other_resv_qty, 'Process_Line');
  END IF;

  -- calculate quantity_reserved, quantity_transfer_resv and quantity_create_resv
  IF l_mtl_reservation_tab_count > 0 THEN
    FOR resv_rec IN 1 .. l_mtl_reservation_tab_count LOOP
      IF l_mtl_reservation_tab(resv_rec).lpn_id IS NOT NULL THEN   /* 3322799 */
        IF (l_mtl_reservation_tab(resv_rec).lpn_id = p_lpn_id) THEN
           l_quantity_reserved  := l_quantity_reserved + l_mtl_reservation_tab(resv_rec).primary_reservation_quantity;
        ELSIF l_mtl_reservation_tab(resv_rec).staged_flag='Y' THEN --Bug#5262108. Added ELSE part.
	   l_other_resv_qty := l_other_resv_qty + l_mtl_reservation_tab(resv_rec).primary_reservation_quantity;
        END IF;
      ELSE
        l_quantity_to_transfer_resv  := l_quantity_to_transfer_resv + l_mtl_reservation_tab(resv_rec).primary_reservation_quantity;
      END IF;
    END LOOP; --l_mtl_reservation_tab_count

    IF (l_quantity_to_transfer_resv + l_quantity_reserved) < p_ordered_quantity THEN
      l_quantity_create_resv     := (p_ordered_quantity - l_other_resv_qty) -(l_quantity_to_transfer_resv + l_quantity_reserved);
      l_create_reservation_flag  := 'Y';

      IF  l_quantity_create_resv < 0 THEN --bug5262108. This is because more reservation becoz of overship.
             l_overship_case := 'Y' ;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('Reserved quantity is less than the requeated quantity ', 'Process_Line');
      END IF;
    ELSE
      l_quantity_create_resv     := 0;
      l_create_reservation_flag  := 'N';
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('l_quantity_reserved : ' || l_quantity_reserved, 'Process_Line');
      DEBUG('l_quantity_to_transfer_resv : ' || l_quantity_to_transfer_resv, 'Process_Line');
      DEBUG('l_quantity_create_resv : ' || l_quantity_create_resv, 'Process_Line');
    END IF;
  ELSE -- no reservation found reservation has to be created for all the quantity
    IF (l_debug = 1) THEN
      DEBUG('No reservation record found', 'Process_Line');
      DEBUG('p_ordered_quantity=' || p_ordered_quantity, 'Process_Line');
      DEBUG('l_other_resv_qty=' || l_other_resv_qty, 'Process_Line');
    END IF;

    l_quantity_create_resv     := p_ordered_quantity - NVL(l_other_resv_qty, 0);
    l_create_reservation_flag  := 'Y';

    IF (l_debug = 1) THEN
      DEBUG('l_quantity_create_resv=' || l_quantity_create_resv, 'Process_Line');
    END IF;
  END IF;        --l_mtl_reservation_tab_count>0
          -- transfer reservations

  IF l_mtl_reservation_tab_count > 0 THEN
    FOR resv_rec IN 1 .. l_mtl_reservation_tab_count LOOP
      l_resv_rec  := l_mtl_reservation_tab(resv_rec);

      -- bug 4285681
      l_current_rsv_rem_qty := l_resv_rec.primary_reservation_quantity;

      IF l_resv_rec.lpn_id IS NULL THEN
        FOR lpnc_rec IN l_start_index .. l_end_index LOOP
          l_lpn_cont_rec  := g_lpn_contents_tab(lpnc_rec);

          IF (
              (l_lpn_cont_rec.quantity > 0)
              AND(l_resv_rec.revision = l_lpn_cont_rec.revision
                  OR l_resv_rec.revision IS NULL)
              AND(l_resv_rec.lot_number = l_lpn_cont_rec.lot_number
                  OR l_resv_rec.lot_number IS NULL)
              AND wms_direct_ship_pvt.validate_end_unit_num_at(lpnc_rec, p_end_item_unit_number)
             ) THEN
            -- clear quantity tree cache
            inv_quantity_tree_pub.clear_quantity_cache;

            -- query quantity tree
            IF (l_debug = 1) THEN
              DEBUG('Before query quantity tree ', 'Process_Line');
              DEBUG('l_demand_source_header_id =' || l_demand_source_header_id, 'Process_Line');
              DEBUG('p_order_line_id =' || p_order_line_id, 'Process_Line');
              DEBUG('l_lpn_cont_rec.revision =' || l_lpn_cont_rec.revision, 'Process_Line');
              DEBUG('l_lpn_cont_rec.lot_number =' || l_lpn_cont_rec.lot_number, 'Process_Line');
              DEBUG('l_lpn_cont_rec.subinventory_code =' || l_lpn_cont_rec.subinventory_code, 'Process_Line');
              DEBUG('l_lpn_cont_rec.locator_id =' || l_lpn_cont_rec.locator_id, 'Process_Line');
              DEBUG('l_lpn_cont_rec.lpn_id=' || l_lpn_cont_rec.lpn_id, 'Process_Line');
            END IF;

            inv_quantity_tree_pub.query_quantities(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_transactable_qty
            , x_atr                        => l_atr
            , p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode --inv_quantity_tree_pub.g_reservation_mode  Changed bug 4128854
            , p_is_revision_control        => l_lpn_cont_rec.revision_control
            , p_is_lot_control             => l_lpn_cont_rec.lot_control
            , p_is_serial_control          => l_lpn_cont_rec.serial_control
            , p_demand_source_type_id      => l_demand_source_type_id
            , p_demand_source_header_id    => l_demand_source_header_id
            , p_demand_source_line_id      => p_order_line_id
            , p_revision                   => l_lpn_cont_rec.revision
            , p_lot_number                 => l_lpn_cont_rec.lot_number
            , p_subinventory_code          => l_lpn_cont_rec.subinventory_code
            , p_locator_id                 => l_lpn_cont_rec.locator_id
            , p_lpn_id                     => l_lpn_cont_rec.lpn_id
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG(
                     'Validation failed for inv_quantity_tree_pub.query_quantities for combination of '
                  || p_order_header_id
                  || ' '
                  || p_order_line_id
                , 'Process_Line'
                );
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG(
                     'Validation failed for inv_quantity_tree_pub.query_quantities for combination of '
                  || p_order_header_id
                  || ' '
                  || p_order_line_id
                , 'Process_Line'
                );
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('Query tree Return status is ' || l_return_status, 'Process_Line');
              DEBUG('l_transactable_qty= ' || l_transactable_qty, 'Process_Line');
              DEBUG('After query quantity tree ', 'Process_Line');
            END IF;

            -- bug 4285681
            l_transactable_qty := Least(l_transactable_qty, g_lpn_contents_tab(lpnc_rec).quantity);


            IF l_transactable_qty > 0 THEN
              l_old_resv_rec.reservation_id                := l_resv_rec.reservation_id;

              IF (l_debug = 1) THEN
                DEBUG('The value of old reservation_id is ' || l_old_resv_rec.reservation_id, 'Process_Line');
              END IF;

              l_new_resv_rec.subinventory_code             := g_subinventory_code;
              l_new_resv_rec.locator_id                    := g_locator_id;
              l_new_resv_rec.organization_id               := p_org_id;
              l_new_resv_rec.inventory_item_id             := p_inventory_item_id;
              l_new_resv_rec.lot_number                    := l_lpn_cont_rec.lot_number;
              l_new_resv_rec.revision                      := l_lpn_cont_rec.revision;
              l_new_resv_rec.demand_source_header_id       := l_demand_source_header_id;
              l_new_resv_rec.demand_source_line_id         := p_order_line_id;
              l_new_resv_rec.lpn_id                        := l_lpn_cont_rec.lpn_id;
              l_new_resv_rec.primary_reservation_quantity  :=
                                             LEAST(l_transactable_qty, l_resv_rec.primary_reservation_quantity, l_quantity_to_transfer_resv);
              l_new_resv_rec.reservation_quantity          :=
                                             LEAST(l_transactable_qty, l_resv_rec.primary_reservation_quantity, l_quantity_to_transfer_resv);

	      l_new_resv_rec.staged_flag                   := 'Y' ; --Bug#5262108

              IF (l_debug = 1) THEN
                DEBUG('Reservation transfered for quantity := ' || l_new_resv_rec.primary_reservation_quantity, 'Process_Line');
                DEBUG('Before call to transfer reservation ', 'Process_Line');
              END IF;

              inv_reservation_pub.transfer_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_true
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_is_transfer_supply         => fnd_api.g_true
              , p_original_rsv_rec           => l_old_resv_rec
              , p_to_rsv_rec                 => l_new_resv_rec
              , p_original_serial_number     => l_dummy_sn -- no serial contorl
              , p_to_serial_number           => l_dummy_sn -- no serial control
              , p_validation_flag            => fnd_api.g_true
              , x_to_reservation_id          => l_new_rsv_id
              , p_over_reservation_flag      => 3
              );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                  DEBUG(
                    'Unexpected error during transfer of Reservations, Line_id ' || p_order_line_id || ' LPN_ID= ' || l_lpn_cont_rec.lpn_id
                  , 'Process_Line'
                  );
                END IF;

                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG(
                    'Unexpected error during transfer of Reservations, Line_id ' || p_order_line_id || ' LPN_ID= ' || l_lpn_cont_rec.lpn_id
                  , 'Process_Line'
                  );
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('Transfer reservation successful, reservation_id= ' || l_new_rsv_id, 'Process_Line');
                DEBUG('After call to transfer reservation ', 'Process_Line');
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('l_quantity_to_transfer_resv= ' || l_quantity_to_transfer_resv, 'Process_Line');
                DEBUG('l_current_rsv_rem_qty= ' || l_current_rsv_rem_qty, 'Process_Line');
                DEBUG('g_lpn_contents_tab(lpnc_rec).quantity= ' || g_lpn_contents_tab(lpnc_rec).quantity, 'Process_Line');
                DEBUG('l_new_resv_rec.primary_reservation_quantity= ' || l_new_resv_rec.primary_reservation_quantity, 'Process_Line');
                DEBUG('l_processed_quantity= ' || l_processed_quantity, 'Process_Line');
                DEBUG('g_total_lpn_quantity= ' || g_total_lpn_quantity, 'Process_Line');
              END IF;

              --update quantities
              l_quantity_to_transfer_resv := l_quantity_to_transfer_resv - l_new_resv_rec.primary_reservation_quantity;

              -- bug 4285681
              l_current_rsv_rem_qty := l_current_rsv_rem_qty - l_new_resv_rec.primary_reservation_quantity;

              g_lpn_contents_tab(lpnc_rec).quantity := g_lpn_contents_tab(lpnc_rec).quantity
                - l_new_resv_rec.primary_reservation_quantity;
              g_total_lpn_quantity := g_total_lpn_quantity - l_new_resv_rec.primary_reservation_quantity;
              l_processed_quantity := l_processed_quantity + l_new_resv_rec.primary_reservation_quantity;


              IF (l_debug = 1) THEN
                DEBUG('l_quantity_to_transfer_resv= ' || l_quantity_to_transfer_resv, 'Process_Line');
                DEBUG('l_current_rsv_rem_qty= ' || l_current_rsv_rem_qty, 'Process_Line');
                DEBUG('g_lpn_contents_tab(lpnc_rec).quantity= ' || g_lpn_contents_tab(lpnc_rec).quantity, 'Process_Line');
                DEBUG('l_new_resv_rec.primary_reservation_quantity= ' || l_new_resv_rec.primary_reservation_quantity, 'Process_Line');
                DEBUG('l_processed_quantity= ' || l_processed_quantity, 'Process_Line');
                DEBUG('g_total_lpn_quantity= ' || g_total_lpn_quantity, 'Process_Line');
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('Total pocessed quantity for line:= ' || l_processed_quantity, 'Process_Line');
              END IF;

              -- bug 4285681
              -- if line processed then exit
              IF l_quantity_to_transfer_resv = 0 OR l_current_rsv_rem_qty <= 0 THEN
                EXIT;
              END IF; --l_quantity_to_transfer_resv=0
            END IF; --l_transactable_qty>0
          END IF; -- lpn_cont_rec
        END LOOP; --l_start_index..l_end_index
      END IF; -- lpn_id is null
    END LOOP; --1..l_mtl_reservation_tab_count
  END IF;        --l_mtl_reservation_tab_count>0

  --Bug#5262108.Begin.
  --This is to handle overship case. Once the requested qty for the line is satisfied,
  --we will try to overship against the line.
  IF l_overship_case = 'Y'   THEN
        l_qty_to_pick := WMS_DIRECT_SHIP_PVT.Get_qty_to_pick( p_order_header_id,p_order_line_id,p_org_id);

      IF (l_debug = 1) THEN
	    DEBUG('l_qty_to_pick '||l_qty_to_pick ,'Process_Line');
      END IF;
      --Calculate the quantity to create reservation.
      l_quantity_create_resv :=  least(l_qty_to_pick,g_total_lpn_quantity );
      IF (l_debug = 1) THEN
	    DEBUG('l_quantity_create_resv '||l_quantity_create_resv ,'Process_Line');
      END IF;
  END IF;  --Bug#5262108


          -- update or create reservations
          --IF l_quantity_create_resv>0 OR l_mtl_reservation_tab_count=0 THEN

  IF l_quantity_create_resv > 0 THEN
    FOR lpnc_rec IN l_start_index .. l_end_index LOOP
      IF (l_debug = 1) THEN
        DEBUG('Quantity for create reservation= ' || l_quantity_create_resv, 'Process_Line');
        DEBUG('lpnc_rec=' || lpnc_rec, 'Process_Line');
        DEBUG('p_end_item_unit_number=' || p_end_item_unit_number, 'Process_Line');
      END IF;

      l_lpn_cont_rec  := g_lpn_contents_tab(lpnc_rec);

      IF (
          (l_lpn_cont_rec.quantity > 0)
          AND(p_revision = l_lpn_cont_rec.revision
              OR p_revision IS NULL)
          AND wms_direct_ship_pvt.validate_end_unit_num_at(lpnc_rec, p_end_item_unit_number)
         ) THEN
        -- clear quantity tree cache
        inv_quantity_tree_pub.clear_quantity_cache;

        -- query quantity tree
        IF (l_debug = 1) THEN
          DEBUG('Before query quantity tree ', 'Process_Line');
          DEBUG('l_demand_source_header_id =' || l_demand_source_header_id, 'Process_Line');
          DEBUG('p_order_line_id =' || p_order_line_id, 'Process_Line');
          DEBUG('l_lpn_cont_rec.revision =' || l_lpn_cont_rec.revision, 'Process_Line');
          DEBUG('l_lpn_cont_rec.lot_number =' || l_lpn_cont_rec.lot_number, 'Process_Line');
          DEBUG('l_lpn_cont_rec.subinventory_code =' || l_lpn_cont_rec.subinventory_code, 'Process_Line');
          DEBUG('l_lpn_cont_rec.locator_id =' || l_lpn_cont_rec.locator_id, 'Process_Line');
          DEBUG('l_lpn_cont_rec.lpn_id=' || l_lpn_cont_rec.lpn_id, 'Process_Line');
        END IF;

        inv_quantity_tree_pub.query_quantities(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_transactable_qty
        , x_atr                        => l_atr
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_tree_mode                  => inv_quantity_tree_pub.g_reservation_mode
        , p_is_revision_control        => l_lpn_cont_rec.revision_control
        , p_is_lot_control             => l_lpn_cont_rec.lot_control
        , p_is_serial_control          => l_lpn_cont_rec.serial_control
        , p_demand_source_type_id      => l_demand_source_type_id
        , p_demand_source_header_id    => l_demand_source_header_id
        , p_demand_source_line_id      => p_order_line_id
        , p_revision                   => l_lpn_cont_rec.revision
        , p_lot_number                 => l_lpn_cont_rec.lot_number
        , p_subinventory_code          => l_lpn_cont_rec.subinventory_code
        , p_locator_id                 => l_lpn_cont_rec.locator_id
        , p_lpn_id                     => l_lpn_cont_rec.lpn_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            DEBUG(
              'Validation failed for inv_quantity_tree_pub.query_quantities for combination of ' || p_order_header_id || ' '
              || p_order_line_id
            , 'Process_Line'
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            DEBUG(
              'Validation failed for inv_quantity_tree_pub.query_quantities for combination of ' || p_order_header_id || ' '
              || p_order_line_id
            , 'Process_Line'
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
          DEBUG('Query tree Return status is ' || l_return_status, 'Process_Line');
          DEBUG('l_transactable_qty= ' || l_transactable_qty, 'Process_Line');
          DEBUG('After query quantity tree ', 'Process_Line');
          DEBUG('l_qty_reserved_tmp= ' || l_qty_reserved_tmp, 'Process_Line');
        END IF;

        IF l_transactable_qty > 0 THEN

	 /* Commented for bug 5262108. We have calculated reservation for LPN above.
          -- find out if a reservation for this lpn,rev and lot exists with p_order_line_id
          IF l_quantity_create_resv > 0 THEN
            BEGIN
              SELECT primary_reservation_quantity
                   , reservation_id
                INTO l_chk_resv_qty
                   , l_resv_id
                FROM mtl_reservations
               WHERE demand_source_line_id = p_order_line_id
                 AND lpn_id = l_lpn_cont_rec.lpn_id
                 AND NVL(revision, '@@@') = NVL(l_lpn_cont_rec.revision, '@@@')
                 AND NVL(lot_number, '@@@') = NVL(l_lpn_cont_rec.lot_number, '@@@')
                 AND demand_source_line_detail IS NULL;

              IF (l_debug = 1) THEN
                DEBUG('Prior reservations exists for quantity  ' || l_chk_resv_qty || ' rsv_id ' || l_resv_id, 'Process_Line');
              END IF;

              l_quantity_create_resv  := p_ordered_quantity - l_chk_resv_qty;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_chk_resv_qty  := 0;
            END;
          END IF; --l_quantity_create_resv

          IF (l_debug = 1) THEN
            DEBUG('l_quantity_create_resv:= ' || l_quantity_create_resv, 'Process_Line');
          END IF;

          --   IF l_chk_resv_qty >0 THEN
          l_reservation_record.reservation_quantity          := LEAST(l_transactable_qty, l_quantity_create_resv);
          l_reservation_record.primary_reservation_quantity  := LEAST(l_transactable_qty, l_quantity_create_resv);

          --   ELSE
          --      l_reservation_record.reservation_quantity := least(l_transactable_qty,p_ordered_quantity-l_qty_reserved_tmp);
          --      l_reservation_record.primary_reservation_quantity :=least(l_transactable_qty,p_ordered_quantity-l_qty_reserved_tmp);
          --   END IF;
          IF l_chk_resv_qty > 0 THEN -- update reservation
            IF (l_debug = 1) THEN
              DEBUG('l_chk_resv_qty >0 ', 'Process_Line');
            END IF;

            l_old_upd_resv_rec.reservation_id            := l_resv_id;
            l_upd_resv_rec.primary_reservation_quantity  := l_reservation_record.primary_reservation_quantity + l_chk_resv_qty;
            l_upd_resv_rec.reservation_quantity          := l_reservation_record.reservation_quantity + l_chk_resv_qty;

            IF (l_debug = 1) THEN
              DEBUG('The reservation_id to update = ' || l_old_upd_resv_rec.reservation_id, 'Process_Line');
              DEBUG('Before call to update reservation', 'Process_Line');
              DEBUG('Quantity to update reservation= ' || l_upd_resv_rec.reservation_quantity, 'Process_Line');
            END IF;

            inv_reservation_pub.update_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_original_rsv_rec           => l_old_upd_resv_rec
            , p_to_rsv_rec                 => l_upd_resv_rec
            , p_original_serial_number     => l_upd_dummy_sn
            , p_to_serial_number           => l_upd_dummy_sn
            , p_validation_flag            => fnd_api.g_true
            , p_over_reservation_flag      => 3
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Update reservation failed for reservation_id ' || l_reservation_id, 'Process_Line');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Update reservation failed for reservation_id with status U' || l_reservation_id, 'Process_Line');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('Update reservation is successful ', 'Process_Line');
              DEBUG('After call to update reservation', 'Process_Line');
            END IF;
          ELSE -- create reservation   commented for 5262108 */

            l_reservation_record.reservation_quantity          := LEAST(l_transactable_qty, l_quantity_create_resv); --Bug#5262108
            l_reservation_record.primary_reservation_quantity  := LEAST(l_transactable_qty, l_quantity_create_resv); --Bug#5262108

            IF (l_debug = 1) THEN
              DEBUG('Quantity to create reservation= ' || l_reservation_record.primary_reservation_quantity, 'Process_Line');
            END IF;

            l_reservation_record.organization_id            := p_org_id;
            l_reservation_record.inventory_item_id          := p_inventory_item_id;
            l_reservation_record.demand_source_header_id    := l_demand_source_header_id;
            l_reservation_record.demand_source_line_id      := p_order_line_id;
            l_reservation_record.reservation_uom_id         := NULL;
            l_reservation_record.reservation_uom_code       := p_primary_uom_code;
            l_reservation_record.primary_uom_code           := p_primary_uom_code;
            l_reservation_record.primary_uom_id             := NULL;
            l_reservation_record.supply_source_type_id      := 13;
            l_reservation_record.demand_source_type_id      := l_demand_source_type_id;
            l_reservation_record.ship_ready_flag            := 2;
            l_reservation_record.attribute1                 := NULL;
            l_reservation_record.attribute2                 := NULL;
            l_reservation_record.attribute3                 := NULL;
            l_reservation_record.attribute4                 := NULL;
            l_reservation_record.attribute5                 := NULL;
            l_reservation_record.attribute6                 := NULL;
            l_reservation_record.attribute7                 := NULL;
            l_reservation_record.attribute8                 := NULL;
            l_reservation_record.attribute9                 := NULL;
            l_reservation_record.attribute10                := NULL;
            l_reservation_record.attribute11                := NULL;
            l_reservation_record.attribute12                := NULL;
            l_reservation_record.attribute13                := NULL;
            l_reservation_record.attribute14                := NULL;
            l_reservation_record.attribute15                := NULL;
            l_reservation_record.attribute_category         := NULL;
            l_reservation_record.lpn_id                     := l_lpn_cont_rec.lpn_id;
            l_reservation_record.pick_slip_number           := NULL;
            l_reservation_record.lot_number_id              := NULL;
            l_reservation_record.lot_number                 := l_lpn_cont_rec.lot_number;
            l_reservation_record.locator_id                 := l_lpn_cont_rec.locator_id;
            l_reservation_record.subinventory_id            := NULL;
            l_reservation_record.subinventory_code          := g_subinventory_code;
            l_reservation_record.revision                   := l_lpn_cont_rec.revision;
            l_reservation_record.supply_source_line_detail  := NULL;
            l_reservation_record.supply_source_name         := NULL;
            l_reservation_record.supply_source_line_id      := p_order_line_id;
            l_reservation_record.supply_source_header_id    := l_demand_source_header_id;
            l_reservation_record.external_source_line_id    := NULL;
            l_reservation_record.external_source_code       := NULL;
            l_reservation_record.autodetail_group_id        := NULL;
            l_reservation_record.demand_source_delivery     := NULL;
            l_reservation_record.demand_source_name         := NULL;
            l_reservation_record.requirement_date           := p_date_requested;
            l_reservation_record.staged_flag                := 'Y' ; --Bug#5262108
	    l_reservation_record.secondary_detailed_quantity:= NULL;  -- Bug 7482123
            l_reservation_record.detailed_quantity          := NULL;  -- Bug 7482123


            IF (l_debug = 1) THEN
              DEBUG('Before call to create reservation', 'Process_Line');
            END IF;

            inv_reservation_pub.create_reservation(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , x_serial_number              => l_dummy_sn
            , x_quantity_reserved          => l_quantity_reserved_tmp
            , x_reservation_id             => l_reservation_id
            , p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , p_rsv_rec                    => l_reservation_record
            , p_partial_reservation_flag   => fnd_api.g_true
            , p_force_reservation_flag     => fnd_api.g_true
            , p_serial_number              => l_dummy_sn
            , p_validation_flag            => fnd_api.g_true
            , p_over_reservation_flag      => 3
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Create reservation failed for lpn_id= ' || l_lpn_cont_rec.lpn_id, 'Process_Line');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Unexpected error during create of Reservations lpn_id= ' || l_lpn_cont_rec.lpn_id, 'Process_Line');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
	      DEBUG('Res qty created : '|| l_reservation_record.primary_reservation_quantity , 'Process_Line');
              DEBUG('Create reservations is successful ' || l_reservation_id, 'Process_Line');
              DEBUG('After call to create reservation', 'Process_Line');
            END IF;
        --  END IF;        --l_chk_resv_qty >0 coomented for bug#5262108.
                  -- update quantities

          g_lpn_contents_tab(lpnc_rec).quantity              :=
                                                    g_lpn_contents_tab(lpnc_rec).quantity
                                                    - l_reservation_record.primary_reservation_quantity;
          l_processed_quantity                               := l_processed_quantity + l_reservation_record.primary_reservation_quantity;
          g_total_lpn_quantity                               := g_total_lpn_quantity - l_reservation_record.primary_reservation_quantity;

          IF l_create_reservation_flag = 'Y' THEN
            l_quantity_create_resv  := l_quantity_create_resv - l_reservation_record.primary_reservation_quantity;
          ELSE
            l_qty_reserved_tmp  := l_qty_reserved_tmp + l_reservation_record.primary_reservation_quantity;
          END IF;

          IF l_quantity_create_resv = 0 THEN
            EXIT;
          ELSIF(p_ordered_quantity - l_qty_reserved_tmp) = 0 THEN
            EXIT;
          END IF;
        END IF; --l_transactable_qty > 0
      END IF; -- l_lpn_cont_rec

      IF (l_debug = 1) THEN
        DEBUG('g_lpn_contents_tab(' || lpnc_rec || ').quantity=' || g_lpn_contents_tab(lpnc_rec).quantity, 'Process_Line');
      END IF;
    END LOOP; --lpnc_rec
  END IF; --l_mtl_reservation_tab_count=0

  x_remaining_quantity                              := g_total_lpn_quantity;

  IF (l_debug = 1) THEN
    DEBUG('x_remaining_quantity=' || x_remaining_quantity, 'Process_Line');
  END IF;

  -- INSER DATA INTO WDS
  IF l_processed_quantity > 0 THEN
    IF (l_debug = 1) THEN
      DEBUG('Inserting data into WDS', 'Process_Line');
    END IF;

    -- if record exist then update
    BEGIN
      SELECT order_line_id
        INTO l_temp_var
        FROM wms_direct_ship_temp
       WHERE organization_id = p_org_id
         AND dock_door_id = p_dock_door_id
         AND lpn_id = p_lpn_id
         AND order_header_id = p_order_header_id
         AND order_line_id = p_order_line_id;

      -- no excaption means record exist
      -- update
      UPDATE wms_direct_ship_temp
         SET processed_flag = 'Y'
           , processed_quantity = l_processed_quantity
       WHERE organization_id = p_org_id
         AND dock_door_id = p_dock_door_id
         AND lpn_id = p_lpn_id
         AND order_header_id = p_order_header_id
         AND order_line_id = p_order_line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- first time line is being processed
        -- insert
        IF (l_serial_required_flag = 'Y') THEN
          BEGIN
            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_trx_temp_id
              FROM DUAL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('Error getting transaction_temp_id', 'Process_Line');
              END IF;

              x_return_status  := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
          END;
        ELSE
          l_trx_temp_id  := NULL;
        END IF;

        INSERT INTO wms_direct_ship_temp
                    (
                     GROUP_ID
                   , organization_id
                   , dock_door_id
                   , lpn_id
                   , order_header_id
                   , order_line_id
                   , line_item_id
                   , processed_quantity
                   , processed_flag
                   , serial_required_flag
                   , transaction_temp_id
                   , creation_date
                   , created_by
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                    )
             VALUES (
                     g_group_id
                   , p_org_id
                   , p_dock_door_id
                   , p_lpn_id
                   , p_order_header_id
                   , p_order_line_id
                   , p_inventory_item_id
                   , l_processed_quantity
                   , 'Y'
                   , l_serial_required_flag
                   , l_trx_temp_id
                   , g_creation_date
                   , g_created_by
                   , g_last_update_date
                   , g_last_updated_by
                   , g_last_update_login
                    );
    END; -- update / insert

  /* Bug#5262108. We do not need the following code because we are now creating
 	      reservation as soon as the user selects the order line.So commenting the below code.

  ELSE
   IF l_mtl_resv_tab_count_temp >0 then  Added bug4128854 for overshipping staged lines

    Bug#4349836.Before inserting a dummy record,check if one is already there for the same LPN
    SELECT count(1) INTO l_count_wdst
    FROM wms_direct_ship_temp wdst
    WHERE wdst.group_id = g_group_id
      AND wdst.organization_id=p_org_id
      AND wdst.dock_door_id = p_dock_door_id
      AND wdst.lpn_id=p_lpn_id
      AND wdst.order_header_id = p_order_header_id
      AND wdst.order_line_id = p_order_line_id
      AND wdst.line_item_id = p_inventory_item_id;
   IF (l_count_wdst = 0 ) then  --Bug#4546137 Added IF Block.

       IF (l_debug = 1) THEN
          DEBUG('Processed quantity for line is zero. Record with zero inserted into wds', 'Process_Line');
       END IF;
            INSERT INTO wms_direct_ship_temp
                    (
                     GROUP_ID
                   , organization_id
                   , dock_door_id
                   , lpn_id
                   , order_header_id
                   , order_line_id
                   , line_item_id
                   , processed_quantity
                   , processed_flag
                   , serial_required_flag
                   , transaction_temp_id
                   , creation_date
                   , created_by
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                    )
             VALUES (
                     g_group_id
                   , p_org_id
                   , p_dock_door_id
                   , p_lpn_id
                   , p_order_header_id
                   , p_order_line_id
                   , p_inventory_item_id
                   , l_processed_quantity
                   , 'Y'
                   , l_serial_required_flag
                   , decode(l_serial_required_flag,'Y',mtl_material_transactions_s.NEXTVAL,l_trx_temp_id)
                   , g_creation_date
                   , g_created_by
                   , g_last_update_date
                   , g_last_updated_by
                   , g_last_update_login
                    );
        fnd_msg_pub.Initialize;
      END IF;
    else
        fnd_message.set_name('WMS', 'WMS_ITEM_NOT_AVAILABLE');
        fnd_msg_pub.ADD;
    IF (l_debug = 1) THEN
            DEBUG('Processed quantity for line is zero. Record not inserted into wds', 'Process_Line');
        END IF;
    end if;
    Bug #5262108 . Commented upto here */
  END IF; --l_processed_quantity

  x_return_status                                   := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Unexpected error occured', 'Process_Line');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_ERROR_LOADING_LINE');
    fnd_msg_pub.ADD;
END process_line;

/* This functions validates the line being packect into LPN for
   Delivery grouping rules.
 */

FUNCTION validate_del_grp_rules(p_line_processed IN NUMBER, p_header_id IN NUMBER, p_line_id IN NUMBER)
  RETURN BOOLEAN IS
  CURSOR del_detail IS
    SELECT ship_from_location_id
         , ship_to_location_id
         , customer_id
         , intmed_ship_to_location_id
         , ship_method_code
         , fob_code
         , freight_terms_code
      FROM wsh_delivery_details_ob_grp_v
     WHERE source_header_id = p_header_id
       AND source_line_id = p_line_id;

  l_del_detail_rec del_detail%ROWTYPE;
  l_count          NUMBER               := 0;
  l_debug          NUMBER               := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('p_line_processed= ' || p_line_processed, 'Validate_Del_Grp_Rules');
    DEBUG('p_header_id= ' || p_header_id, 'Validate_Del_Grp_Rules');
    DEBUG('p_line_id= ' || p_line_id, 'Validate_Del_Grp_Rules');
  END IF;

  OPEN del_detail;

  LOOP
    FETCH del_detail INTO l_del_detail_rec;
    EXIT WHEN del_detail%NOTFOUND;
    -- populate delivery grouping fld values into temp table
    g_del_grp_rls_fld_temp(1)  := l_del_detail_rec.ship_from_location_id;
    g_del_grp_rls_fld_temp(2)  := l_del_detail_rec.ship_to_location_id;
    g_del_grp_rls_fld_temp(3)  := l_del_detail_rec.customer_id;
    g_del_grp_rls_fld_temp(4)  := l_del_detail_rec.fob_code;
    g_del_grp_rls_fld_temp(5)  := l_del_detail_rec.freight_terms_code;
    g_del_grp_rls_fld_temp(6)  := l_del_detail_rec.intmed_ship_to_location_id;
    g_del_grp_rls_fld_temp(7)  := l_del_detail_rec.ship_method_code;

    IF (l_debug = 1) THEN
      DEBUG('g_del_grp_rls_fld_temp populated', 'Validate_Del_Grp_Rules');
    END IF;

    l_count                    := l_count + 1;
    EXIT; -- only one records values are enough
  END LOOP;

  IF l_count = 0 THEN
    IF (l_debug = 1) THEN
      DEBUG('Record not found in wdd for line_id=' || p_line_id, 'Validate_Del_Grp_Rules');
    END IF;

    RAISE fnd_api.g_exc_error;
  END IF;

  IF p_line_processed = 0 THEN
    -- loading first line no need to do comparision
    -- just populate g_del_grp_rls_fld_value from
    -- g_del_grp_rls_fld_temp
    g_del_grp_rls_fld_value(1)  := g_del_grp_rls_fld_temp(1);
    g_del_grp_rls_fld_value(2)  := g_del_grp_rls_fld_temp(2);
    g_del_grp_rls_fld_value(3)  := g_del_grp_rls_fld_temp(3);
    g_del_grp_rls_fld_value(4)  := g_del_grp_rls_fld_temp(4);
    g_del_grp_rls_fld_value(5)  := g_del_grp_rls_fld_temp(5);
    g_del_grp_rls_fld_value(6)  := g_del_grp_rls_fld_temp(6);
    g_del_grp_rls_fld_value(7)  := g_del_grp_rls_fld_temp(7);

    IF (l_debug = 1) THEN
      DEBUG('SUCCESS', 'Validate_Del_Grp_Rules');
    END IF;

    RETURN TRUE;
  ELSE
    -- compare values from first line to current line
    FOR l_flag IN 1 .. 7 LOOP
      IF g_del_grp_rls_flags(l_flag) = 'Y' THEN
        -- comparision needed
        IF g_del_grp_rls_fld_value(l_flag) <> g_del_grp_rls_fld_temp(l_flag) THEN
          IF (l_debug = 1) THEN
            DEBUG('g_del_grp_rls_fld_value(l_flag)=' || g_del_grp_rls_fld_value(l_flag), 'Validate_Del_Grp_Rules');
            DEBUG('g_del_grp_rls_fld_temp(l_flag)=' || g_del_grp_rls_fld_temp(l_flag), 'Validate_Del_Grp_Rules');
            DEBUG('FAILURE', 'Validate_Del_Grp_Rules');
          END IF;

          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    IF (l_debug = 1) THEN
      DEBUG('SUCCESS', 'Validate_Del_Grp_Rules');
    END IF;

    RETURN TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception occured', 'Validate_Del_Grp_Rules');
    END IF;

    RAISE fnd_api.g_exc_error;
END validate_del_grp_rules;

/*
  This method checks that there should be no record for this lpn in wstt (delivery)
  having direct_ship_flag N or loaded by some other method than direct ship.
 */

FUNCTION validate_del_for_ds(p_lpn_id IN NUMBER, p_org_id IN NUMBER, p_dock_door_id IN NUMBER, p_header_id IN NUMBER, p_line_id IN NUMBER)
  RETURN BOOLEAN IS
  CURSOR del_cur IS
    SELECT wda.delivery_id
      FROM wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd, wms_direct_ship_temp wds
     WHERE wds.organization_id = p_org_id
       AND wds.dock_door_id = p_dock_door_id
       AND wds.lpn_id = p_lpn_id
       AND wds.order_header_id = p_header_id
       AND wds.order_line_id = p_line_id
       AND wds.order_line_id = wdd.source_line_id
       AND wds.order_header_id = wdd.source_header_id
       AND wdd.delivery_detail_id = wda.delivery_detail_id;

  l_del_cur_rec   del_cur%ROWTYPE;
  l_return_status VARCHAR2(3);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR(20000);
  l_result        BOOLEAN           := TRUE;
  l_debug         NUMBER            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('Checking delivery for direct ship', 'Validate_Del_For_DS');
    DEBUG('delivery id:'||l_del_cur_rec.delivery_id, 'Validate_Del_For_DS');
  END IF;

  OPEN del_cur;

  LOOP
    FETCH del_cur INTO l_del_cur_rec;
    EXIT WHEN del_cur%NOTFOUND;

    -- first checjk cache table
    IF g_checked_deliveries.EXISTS(l_del_cur_rec.delivery_id) THEN
      l_result  := TRUE;
    ELSE -- not already validated go throug normal procedure
      wms_direct_ship_pvt.chk_del_for_direct_ship(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_delivery_id                => l_del_cur_rec.delivery_id
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        -- ACTION
        IF (l_debug = 1) THEN
          DEBUG('Delivery grouping failed', 'Validate_Del_For_DS');
        END IF;

        l_result  := FALSE;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Delivery grouping failed with exception', 'Validate_Del_For_DS');
        END IF;

        l_result  := FALSE;
      END IF;

      -- success
      -- put delivery into cache table
      IF (l_del_cur_rec.delivery_id IS NOT NULL) THEN --Bug#6071394
       g_checked_deliveries(l_del_cur_rec.delivery_id)  := 1;
      END IF;
    END IF;
  END LOOP;

  CLOSE del_cur;
  --      debug('Delivery check result= '||l_result,'Validate_Del_For_DS');
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception occured', 'Validate_Del_For_DS');
    END IF;

    RAISE fnd_api.g_exc_error;
END validate_del_for_ds;

/*
  This procedure perform the following processing for a lpn.
  1. Update staged flag of all reservations for all the lines packed into LPN.
  2. Stage LPN
  3. Update Freight Cost for LPN
 */

 /* bug#2798970 */
 /*
  jaysingh : The initail code of this procedure was doing wrong reservation staging.
             If two different LPNs was reserved against one line and we try to ship
       one LPN through DS, reservations for both the LPNs was staged. We should
       stage reservations only for LPNs which are inner LPNs of the outer LPN
       and the outermost LPN itself.
*/

   PROCEDURE load_lpn(
		      x_return_status OUT NOCOPY    VARCHAR2
		      , x_msg_count     OUT NOCOPY    NUMBER
		      , x_msg_data      OUT NOCOPY    VARCHAR2
		      , p_lpn_id        IN            NUMBER
		      , p_org_id        IN            NUMBER
		      , p_dock_door_id  IN            NUMBER
		      ) IS
 --
  TYPE number_table IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  --
  CURSOR wds_cur IS
    SELECT wds.order_header_id
         , wds.order_line_id
      FROM wms_direct_ship_temp wds
     WHERE wds.organization_id = p_org_id
       AND wds.dock_door_id = p_dock_door_id
       AND wds.lpn_id = p_lpn_id;

  --
  CURSOR lpn_cur IS
    SELECT lpn_id
      FROM wms_license_plate_numbers
     WHERE outermost_lpn_id = p_lpn_id
       AND organization_id = p_org_id;

  -- query reservations
  l_qry_reservation_record    inv_reservation_global.mtl_reservation_rec_type;
  l_mtl_reservation_tab       inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_reservation_tab_count NUMBER;
  l_lpn_ids_tab               number_table;
  l_return_status             VARCHAR2(3);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(20000);
  l_error_code                NUMBER;
  l_debug                     NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('Procedure Load_LPN called with parameters', 'Load_LPN');
    DEBUG('p_org_id=' || p_org_id, 'Load_LPN');
    DEBUG('p_dock_door_id=' || p_dock_door_id, 'Load_LPN');
    DEBUG('p_lpn_id=' || p_lpn_id, 'Load_LPN');
  END IF;

  -- stage reservations
  IF (l_debug = 1) THEN
    DEBUG('Staging reservations', 'Load_LPN');
  END IF;

  -- get all lpn ids.
  IF l_lpn_ids_tab.COUNT > 0 THEN -- clear the cache
    l_lpn_ids_tab.DELETE;
  END IF;

  FOR l_lpn_cur IN lpn_cur LOOP
    l_lpn_ids_tab(l_lpn_cur.lpn_id)  := 0;
  END LOOP;

  -- for each line in WDS from p_lpn_id
  FOR l_wds_cur IN wds_cur LOOP
    l_qry_reservation_record.demand_source_line_id    := l_wds_cur.order_line_id;
    l_qry_reservation_record.demand_source_header_id  := inv_salesorder.get_salesorder_for_oeheader(l_wds_cur.order_header_id);
    l_qry_reservation_record.supply_source_type_id    := inv_reservation_global.g_source_type_inv;

    IF (l_debug = 1) THEN
      DEBUG('Before call to query reservation', 'Load_LPN');
    END IF;

    inv_reservation_pub.query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_query_input                => l_qry_reservation_record
    , p_lock_records               => fnd_api.g_false
    , x_mtl_reservation_tbl        => l_mtl_reservation_tab
    , x_mtl_reservation_tbl_count  => l_mtl_reservation_tab_count
    , x_error_code                 => l_error_code
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Query reservation failed', 'Load_LPN');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        DEBUG('Query reservation failed', 'Load_LPN');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('After call to query reservation', 'Load_LPN');
    END IF;

    -- now stage reservations which has lpn_id present in l_lpn_ids_tab.
    FOR l_rec IN 1 .. l_mtl_reservation_tab_count LOOP
      IF l_lpn_ids_tab.EXISTS(l_mtl_reservation_tab(l_rec).lpn_id) THEN
        -- everything fine stage the reservation
        inv_staged_reservation_util.update_staged_flag(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_reservation_id             => l_mtl_reservation_tab(l_rec).reservation_id
        , p_staged_flag                => 'Y'
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            DEBUG('Update_staged_flag failed with error', 'Load_LPN');
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            DEBUG('Update_staged_flag failed with exception', 'Load_LPN');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
          DEBUG(
               'Reservation staged for resv_id='
            || l_mtl_reservation_tab(l_rec).reservation_id
            || ' : lpn_id='
            || l_mtl_reservation_tab(l_rec).lpn_id
            || ' : line_id='
            || l_mtl_reservation_tab(l_rec).demand_source_line_id
          , 'Load_LPN'
          );
        END IF;
      END IF;
    END LOOP; -- stage
  END LOOP; -- wds_cur

  IF (l_debug = 1) THEN
    DEBUG('Staging reservations completed', 'Load_LPN');
  END IF;

  -- stage lpns
  IF (l_debug = 1) THEN
    DEBUG('Staging LPNs ', 'Load_LPN');
  END IF;

  wms_direct_ship_pvt.stage_lpns(
    x_return_status              => l_return_status
  , x_msg_count                  => l_msg_count
  , x_msg_data                   => l_msg_data
  , p_group_id                   => g_group_id
  , p_organization_id            => p_org_id
  , p_dock_door_id               => p_dock_door_id
  );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
     x_msg_data := l_msg_data;
     IF (l_debug = 1) THEN
	DEBUG('Stage LPN API failed with status E ', 'Load_LPN');
     END IF;

     RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     x_msg_data := l_msg_data;
     IF (l_debug = 1) THEN
	DEBUG('Stage LPN API failed with status U', 'Load_LPN');
     END IF;

     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1) THEN
    DEBUG('Staging LPNs completed', 'Load_LPN');
  END IF;

  -- update freight cost
  IF (l_debug = 1) THEN
    DEBUG('Updating freight cost', 'Load_LPN');
  END IF;

  wms_direct_ship_pvt.update_freight_cost(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data
  , p_lpn_id                     => p_lpn_id);

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Update Freight Cost API failed with status E ', 'Load_LPN');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Update Freight Cost failed with status U', 'Load_LPN');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1) THEN
    DEBUG('Update freight cost completed', 'Load_LPN');
    DEBUG('LPN loaded successfully', 'Load_LPN');
  END IF;

  x_return_status  := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception loading lpn', 'Load_LPN');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_ERROR_LOADING_LPN');
    fnd_msg_pub.ADD;
END load_lpn;

/*
  This procedure distributes the un-used quantity in the lpn among all the loaded lines.
  First it checks if for a lpn_content record a exact matching reservation is found the
  update the existing reservation else create new reservation.
 */

PROCEDURE perform_overship_distribution(
  p_lpn_id        IN            NUMBER
, p_org_id        IN            NUMBER
, p_dock_door_id  IN            NUMBER
, x_return_status OUT NOCOPY    VARCHAR2
, x_msg_count     OUT NOCOPY    NUMBER
, x_msg_data      OUT NOCOPY    VARCHAR2
) IS
  CURSOR loaded_lines(p_item_id IN NUMBER) IS
    SELECT wds.order_header_id
         , wds.order_line_id
         , oel.item_revision revision
         , oel.end_item_unit_number
         , oel.request_date
         , msi.primary_uom_code
      FROM wms_direct_ship_temp wds, oe_order_lines_all oel, mtl_system_items_kfv msi
     WHERE wds.organization_id = p_org_id
       AND wds.GROUP_ID = g_group_id
       AND wds.dock_door_id = p_dock_door_id
       AND wds.lpn_id = p_lpn_id
       AND wds.line_item_id = p_item_id
       AND oel.header_id = wds.order_header_id
       AND oel.line_id = wds.order_line_id
       AND msi.organization_id = wds.organization_id
       AND msi.inventory_item_id = wds.line_item_id;

  -- bug#2830138
  TYPE lpn_cont_qty_used IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  l_lpn_cont_qty_used       lpn_cont_qty_used;
  l_old_total_lpn_qty       NUMBER                                          := g_total_lpn_quantity;
  l_loaded_lines_rec        loaded_lines%ROWTYPE;
  l_lpn_cont_rec            lpn_content_rec;
  -- for query reservation
  l_qry_reservation_record  inv_reservation_global.mtl_reservation_rec_type;
  l_mtl_reservation_tab     inv_reservation_global.mtl_reservation_tbl_type;
  l_mtl_resv_tab_count      NUMBER;
  -- general
  l_order_line_id           NUMBER;
  l_order_header_id         NUMBER;

   /* Commented for bug 5262108
  -- to query tolerance
  l_minmaxinrectype         wsh_integration.minmaxinrectype;
  l_minmaxoutrectype        wsh_integration.minmaxoutrectype;
  l_minmaxinoutrectype      wsh_integration.minmaxinoutrectype; */
  l_max_shippable_quantity  NUMBER;
  l_total_resvd_qty         NUMBER;
  -- For create_reservation
  l_reservation_record      inv_reservation_global.mtl_reservation_rec_type;
  l_quantity_reserved_tmp   NUMBER;
  l_reservation_id          NUMBER;
  l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
  l_demand_source_header_id NUMBER;
  l_demand_source_type_id   NUMBER;
  l_order_source_id         NUMBER;
  -- For Update reservation
  l_upd_resv_rec            inv_reservation_global.mtl_reservation_rec_type;
  l_old_upd_resv_rec        inv_reservation_global.mtl_reservation_rec_type;
  l_upd_dummy_sn            inv_reservation_global.serial_number_tbl_type;
  l_chk_resv_qty            NUMBER;
  l_resv_id                 NUMBER;
  l_qty_updt_resv           NUMBER;
  l_qty_overship            NUMBER;
  -- For quantity tree declaration
  l_transactable_qty        NUMBER;
  l_qoh                     NUMBER;
  l_rqoh                    NUMBER;
  l_qr                      NUMBER;
  l_qs                      NUMBER;
  l_atr                     NUMBER;
  -- for pjm validation
  l_end_item_unit_number    VARCHAR2(30);
  l_return_status           VARCHAR2(10);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(20000);
  l_error_code              NUMBER;
  l_temp_count              NUMBER;
  l_debug                   NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   --Added for bug 5262108
  l_allowed_flag            VARCHAR2(1);
  l_max_quantity_allowed    NUMBER;
  l_avail_req_quantity      NUMBER;
  l_staged_qty              NUMBER := 0 ;  -- Bug#5262108
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('p_lpn_id=' || p_lpn_id, 'Perform_Overship_Distribution');
    DEBUG('p_org_id=' || p_org_id, 'Perform_Overship_Distribution');
    DEBUG('p_dock_door_id=' || p_dock_door_id, 'Perform_Overship_Distribution');
    DEBUG('lpn_content_record count=' || g_lpn_contents_tab.COUNT, 'Perform_Overship_Distribution');
  END IF;

  x_return_status  := fnd_api.g_ret_sts_success;

  -- clear cash
  IF l_lpn_cont_qty_used.COUNT > 0 THEN
    l_lpn_cont_qty_used.DELETE;
  END IF;

  FOR l_index IN 1 .. g_lpn_contents_tab.COUNT LOOP
    l_lpn_cont_rec  := g_lpn_contents_tab(l_index);

    IF (l_debug = 1) THEN
      DEBUG('lpn_id=' || l_lpn_cont_rec.lpn_id, 'Perform_Overship_Distribution');
    END IF;

    IF l_lpn_cont_rec.quantity > 0 THEN -- overship needed
      l_qry_reservation_record.lpn_id                 := l_lpn_cont_rec.lpn_id;
      l_qry_reservation_record.inventory_item_id      := l_lpn_cont_rec.inventory_item_id;
      l_qry_reservation_record.revision               := l_lpn_cont_rec.revision;
      l_qry_reservation_record.lot_number             := l_lpn_cont_rec.lot_number;
      l_qry_reservation_record.supply_source_type_id  := inv_reservation_global.g_source_type_inv;

      IF (l_debug = 1) THEN
        DEBUG('Before call to query reservation', 'Perform_Overship_Distribution');
      END IF;

      inv_reservation_pub.query_reservation(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_query_input                => l_qry_reservation_record
      , p_lock_records               => fnd_api.g_false
      , x_mtl_reservation_tbl        => l_mtl_reservation_tab
      , x_mtl_reservation_tbl_count  => l_mtl_resv_tab_count
      , x_error_code                 => l_error_code
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Query reservation failed', 'Perform_Overship_Distribution');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Query reservation failed', 'Perform_Overship_Distribution');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('After call to query reservation', 'Perform_Overship_Distribution');
      END IF;

      -- if reservation exists try to overship on already reaserved line
      IF (l_debug = 1) THEN
        DEBUG('l_mtl_resv_tab_count= ' || l_mtl_resv_tab_count, 'Perform_Overship_Distribution');
      END IF;

      IF l_mtl_resv_tab_count > 0 THEN
        FOR l_index_r IN 1 .. l_mtl_resv_tab_count LOOP
          l_order_line_id                       := l_mtl_reservation_tab(l_index_r).demand_source_line_id;
          -- get oe_order_header_id from sales order header id
          inv_salesorder.get_oeheader_for_salesorder(
            p_salesorder_id              => l_mtl_reservation_tab(l_index_r).demand_source_header_id
          , x_oe_header_id               => l_order_header_id
          , x_return_status              => l_return_status
          );

          IF (l_debug = 1) THEN
            DEBUG('l_oe_order_header_id = ' || l_order_header_id, 'Perform_Overship_Distribution');
          END IF;

          l_demand_source_header_id             := l_mtl_reservation_tab(l_index_r).demand_source_header_id;

          -- validate end unit
          BEGIN
            SELECT end_item_unit_number
              INTO l_end_item_unit_number
              FROM oe_order_lines_all
             WHERE line_id = l_order_line_id;

            IF (l_debug = 1) THEN
              DEBUG('l_end_item_unit_number=' || l_end_item_unit_number, 'Perform_Overship_Distribution');
            END IF;

            IF NOT wms_direct_ship_pvt.validate_end_unit_num_at(l_index, l_end_item_unit_number) THEN
              IF (l_debug = 1) THEN
                DEBUG('End unit not matching, skipping line', 'Perform_Overship_Distribution');
              END IF;

              EXIT;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('No data found for line=' || l_order_line_id, 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_error;
          END;

          /* Commented for bug  5262108
          -- get tolerance quantity
          l_minmaxinrectype.api_version_number  := 1.0;
          l_minmaxinrectype.source_code         := 'OE';
          l_minmaxinrectype.line_id             := l_order_line_id; */

          IF (l_debug = 1) THEN
            DEBUG('Before call to WSH_DETAILS_VALIDATIONS.Check_Quantity_To_Pick', 'Perform_Overship_Distribution');
            DEBUG('l_order_line_id=' || l_order_line_id, 'Perform_Overship_Distribution');
          END IF;

         /* Commented for bug 5262108
          wsh_integration.get_min_max_tolerance_quantity(
            p_in_attributes              => l_minmaxinrectype
          , p_out_attributes             => l_minmaxoutrectype
          , p_inout_attributes           => l_minmaxinoutrectype
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );  */


	    --Begin Bug 5262108
	  WSH_DETAILS_VALIDATIONS.Check_Quantity_To_Pick(
               p_order_line_id         => l_order_line_id,
               p_quantity_to_pick      => 0,
               x_allowed_flag          => l_allowed_flag,
               x_max_quantity_allowed  => l_max_quantity_allowed,
               x_avail_req_quantity    => l_avail_req_quantity,
               x_return_status         => l_return_status) ;

	 IF (l_debug = 1) THEN
		DEBUG('l_allowed_flag='||l_allowed_flag,'Perform_Overship_Distribution');
          	DEBUG('l_max_quantity_allowed='||l_max_quantity_allowed,'Perform_Overship_Distribution');
          	DEBUG('l_avail_req_quantity='||l_avail_req_quantity,'Perform_Overship_Distribution');
          	DEBUG('l_return_status='||l_return_status,'Perform_Overship_Distribution');
         END IF;

	 --End bug 5262108

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Tolerance API failed', 'Perform_Overship_Distribution');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Tolerance API failed', 'Perform_Overship_Distribution');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;


        -- commented for 5262108  l_max_shippable_quantity := l_minmaxoutrectype.max_remaining_quantity; --Removed trunc bug3994915

	  l_max_shippable_quantity := l_max_quantity_allowed;  -- 5262108

          IF (l_debug = 1) THEN
           --DEBUG('max_remaining_quantity = ' || l_max_shippable_quantity, 'Perform_Overship_Distribution');
	   DEBUG('max_remaining_quantity = ' || l_max_quantity_allowed, 'Perform_Overship_Distribution');
          END IF;

          -- get total reserved quantity for this line
          BEGIN
            SELECT SUM(primary_reservation_quantity)
              INTO l_total_resvd_qty
              FROM mtl_reservations
             WHERE demand_source_header_id = l_mtl_reservation_tab(l_index_r).demand_source_header_id
               AND demand_source_line_id = l_order_line_id
               AND demand_source_line_detail IS NULL
	       AND nvl(staged_flag,'N') = 'Y'; --Bug#5262108
          EXCEPTION
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                DEBUG('Exception getting total reserved quantity for line = ' || l_order_line_id, 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
          END;

          DEBUG('DRH 1 ' || l_order_header_id);
          --
          -- get demand source type
          BEGIN
            SELECT order_source_id
              INTO l_order_source_id
              FROM oe_order_headers_all
      --       WHERE header_id = 64801;
             WHERE header_id = l_order_header_id;

            IF l_order_source_id = 10 THEN
              l_demand_source_type_id  := 8;
            ELSE
              l_demand_source_type_id  := 2;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('l_demand_source_type_id =' || l_demand_source_type_id, 'Perform_Overship_Distribution');
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                DEBUG('Exception getting l_demand_source_type_id ', 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
          END;

          -- clear quantity tree cache
          inv_quantity_tree_pub.clear_quantity_cache;

          -- query quantity tree
          IF (l_debug = 1) THEN
            DEBUG('Before query quantity tree ', 'Perform_Overship_Distribution');
            DEBUG('l_demand_source_header_id =' || l_demand_source_header_id, 'Perform_Overship_Distribution');
            DEBUG('l_order_line_id =' || l_order_line_id, 'Perform_Overship_Distribution');
            DEBUG('l_lpn_cont_rec.revision =' || l_lpn_cont_rec.revision, 'Perform_Overship_Distribution');
            DEBUG('l_lpn_cont_rec.lot_number =' || l_lpn_cont_rec.lot_number, 'Perform_Overship_Distribution');
            DEBUG('l_lpn_cont_rec.subinventory_code =' || l_lpn_cont_rec.subinventory_code, 'Perform_Overship_Distribution');
            DEBUG('l_lpn_cont_rec.locator_id =' || l_lpn_cont_rec.locator_id, 'Perform_Overship_Distribution');
            DEBUG('l_lpn_cont_rec.lpn_id=' || l_lpn_cont_rec.lpn_id, 'Perform_Overship_Distribution');
          END IF;

          inv_quantity_tree_pub.query_quantities(
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_transactable_qty
          , x_atr                        => l_atr
          , p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => l_lpn_cont_rec.inventory_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => l_lpn_cont_rec.revision_control
          , p_is_lot_control             => l_lpn_cont_rec.lot_control
          , p_is_serial_control          => l_lpn_cont_rec.serial_control
          , p_demand_source_type_id      => l_demand_source_type_id
          , p_demand_source_header_id    => l_demand_source_header_id
          , p_demand_source_line_id      => l_order_line_id
          , p_revision                   => l_lpn_cont_rec.revision
          , p_lot_number                 => l_lpn_cont_rec.lot_number
          , p_subinventory_code          => l_lpn_cont_rec.subinventory_code
          , p_locator_id                 => l_lpn_cont_rec.locator_id
          , p_lpn_id                     => l_lpn_cont_rec.lpn_id
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Validation failed for inv_quantity_tree_pub.query_quantities', 'Perform_Overship_Distribution');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Validation failed for inv_quantity_tree_pub.query_quantities', 'Perform_Overship_Distribution');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('Query tree Return status is ' || l_return_status, 'Perform_Overship_Distribution');
            DEBUG('l_transactable_qty= ' || l_transactable_qty, 'Perform_Overship_Distribution');
            DEBUG('After query quantity tree ', 'Perform_Overship_Distribution');
          END IF;

          IF l_transactable_qty > 0 THEN
            -- updating existing reservation record

	    --Bug#5262108.query the staged qty.
 	    SELECT NVL(SUM(picked_quantity),0) INTO l_staged_qty
 	    FROM wsh_delivery_details
 	    WHERE source_header_id = l_order_header_id
 	    AND  source_line_id =l_order_line_id
 	    AND released_status='Y';

            --Bug#5262108.Added l_staged_qty to the following line.
            l_qty_overship   := LEAST(l_lpn_cont_rec.quantity,(l_max_shippable_quantity + l_staged_qty - l_total_resvd_qty), l_transactable_qty);
            l_qty_updt_resv  := l_mtl_reservation_tab(l_index_r).primary_reservation_quantity + l_qty_overship;

            IF (l_debug = 1) THEN
                DEBUG('l_staged_qty  ' || l_staged_qty , 'Perform_Overship_Distribution');
                DEBUG('l_lpn_cont_rec.quantity  ' || l_lpn_cont_rec.quantity, 'Perform_Overship_Distribution');
                DEBUG('l_total_resvd_qty '||l_total_resvd_qty, 'Perform_Overship_Distribution');
                DEBUG('l_qty_overship '||l_qty_overship, 'Perform_Overship_Distribution');
                DEBUG('l_qty_updt_resv '||l_qty_updt_resv, 'Perform_Overship_Distribution');
             END IF;

            IF l_qty_overship > 0 THEN
              l_old_upd_resv_rec.reservation_id            := l_mtl_reservation_tab(l_index_r).reservation_id;
              l_upd_resv_rec.primary_reservation_quantity  := l_qty_updt_resv;
              l_upd_resv_rec.reservation_quantity          := l_qty_updt_resv;

              IF (l_debug = 1) THEN
                DEBUG('Quantity update reservation is ' || l_qty_updt_resv, 'Perform_Overship_Distribution');
                DEBUG('The reservation_id to update = ' || l_old_upd_resv_rec.reservation_id, 'Perform_Overship_Distribution');
                DEBUG('Before call to update reservation', 'Perform_Overship_Distribution');
                DEBUG('Quantity to update reservation= ' || l_upd_resv_rec.reservation_quantity, 'Perform_Overship_Distribution');
              END IF;

              inv_reservation_pub.update_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_original_rsv_rec           => l_old_upd_resv_rec
              , p_to_rsv_rec                 => l_upd_resv_rec
              , p_original_serial_number     => l_upd_dummy_sn
              , p_to_serial_number           => l_upd_dummy_sn
              , p_validation_flag            => fnd_api.g_true
              , p_over_reservation_flag      => 3
              );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('Update reservation failed ', 'Perform_Overship_Distribution');
                END IF;

                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('Update reservation failed', 'Perform_Overship_Distribution');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('Update reservation is successful ', 'Perform_Overship_Distribution');
                DEBUG('After call to update reservation', 'Perform_Overship_Distribution');
              END IF;

              -- update cache quantities
              g_lpn_contents_tab(l_index).quantity         := g_lpn_contents_tab(l_index).quantity - l_qty_overship;
              l_lpn_cont_rec.quantity                      := l_lpn_cont_rec.quantity - l_qty_overship;
              g_total_lpn_quantity                         := g_total_lpn_quantity - l_qty_overship;

              -- bug#2830138
              -- make backup of quantities used
              -- will be used if overship has to be rollbacked
              IF l_lpn_cont_qty_used.EXISTS(l_index) THEN
                l_lpn_cont_qty_used(l_index)  := l_lpn_cont_qty_used(l_index) + l_qty_overship;
              ELSE
                l_lpn_cont_qty_used(l_index)  := l_qty_overship;
              END IF;

              -- update wds for processed_quantity=processed_quantity+g_total_lpn_quantity
              BEGIN
                UPDATE wms_direct_ship_temp
                   SET processed_quantity =(processed_quantity + l_qty_overship)
                 WHERE organization_id = p_org_id
                   AND GROUP_ID = g_group_id
                   AND lpn_id = p_lpn_id
                   AND order_line_id = l_order_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                  IF (l_debug = 1) THEN
                    DEBUG('Exception updating WDS', 'Perform_Overship_Distribution');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
              END;
            END IF;         -- l_qty_overship >0
                    -- if all quantity consumed exit to lpn_content loop

            IF l_lpn_cont_rec.quantity = 0 THEN
              EXIT;
            END IF;
          END IF; --l_transactable_qty>0
        END LOOP; --l_mtl_resv_tab_count
      END IF; --l_mtl_resv_tab_count

      IF (l_debug = 1) THEN
        DEBUG('Reservation update completed', 'Perform_Overship_Distribution');
      END IF;

       /* Bug#6062135. If still qty left in LPN, it may be because of multipple WLC records.
         We have to see if theyc an be over shipped */

      -- if more quantity remaining in lpn_content record the create new reservation
      IF l_lpn_cont_rec.quantity > 0 THEN                                -- create reservation
                                          -- get all lines loaded to this lpn
        OPEN loaded_lines(l_lpn_cont_rec.inventory_item_id);

        LOOP
          FETCH loaded_lines INTO l_loaded_lines_rec;
          EXIT WHEN loaded_lines%NOTFOUND;

          IF (l_debug = 1) THEN
            DEBUG('Inside create reservation part', 'Perform_Overship_Distribution');
          END IF;

          --validate end unit
          IF NOT wms_direct_ship_pvt.validate_end_unit_num_at(l_index, l_loaded_lines_rec.end_item_unit_number) THEN
            IF (l_debug = 1) THEN
              DEBUG('End unit not matching, skipping line', 'Perform_Overship_Distribution');
            END IF;

            EXIT;
          END IF;

          IF (l_loaded_lines_rec.revision = l_lpn_cont_rec.revision
              OR l_loaded_lines_rec.revision IS NULL) THEN
            -- get demand source header id
            l_demand_source_header_id             := inv_salesorder.get_salesorder_for_oeheader(l_loaded_lines_rec.order_header_id);
            l_order_line_id                       := l_loaded_lines_rec.order_line_id;

            -- get total reserved quantity for line
            BEGIN
              SELECT SUM(primary_reservation_quantity)
                INTO l_total_resvd_qty
                FROM mtl_reservations
               WHERE demand_source_header_id = l_demand_source_header_id
                 AND demand_source_line_id = l_order_line_id
                 AND demand_source_line_detail IS NULL
                 AND NVL(staged_flag,'N') = 'Y' ;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  DEBUG('Exception getting total reserved quantity for line = ' || l_order_line_id, 'Perform_Overship_Distribution');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
            END;

            /*Commented for bug 6071394
            -- get max shippble quantity
            l_minmaxinrectype.api_version_number  := 1.0;
            l_minmaxinrectype.source_code         := 'OE';
            l_minmaxinrectype.line_id             := l_loaded_lines_rec.order_line_id;
            wsh_integration.get_min_max_tolerance_quantity(
              p_in_attributes              => l_minmaxinrectype
            , p_out_attributes             => l_minmaxoutrectype
            , p_inout_attributes           => l_minmaxinoutrectype
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            );
            */
          --Begin Bug 4908571
	  WSH_DETAILS_VALIDATIONS.Check_Quantity_To_Pick(
               p_order_line_id         => l_order_line_id,
               p_quantity_to_pick      => 0,
               x_allowed_flag          => l_allowed_flag,
               x_max_quantity_allowed  => l_max_quantity_allowed,
               x_avail_req_quantity    => l_avail_req_quantity,
               x_return_status         => l_return_status) ;

	 IF (l_debug = 1) THEN
		DEBUG('l_allowed_flag='||l_allowed_flag,'Perform_Overship_Distribution');
          	DEBUG('l_max_quantity_allowed='||l_max_quantity_allowed,'Perform_Overship_Distribution');
          	DEBUG('l_avail_req_quantity='||l_avail_req_quantity,'Perform_Overship_Distribution');
          	DEBUG('l_return_status='||l_return_status,'Perform_Overship_Distribution');
         END IF;
	 --End bug 4908571


            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Tolerance API failed', 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Tolerance API failed', 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            -- get demand source type
            BEGIN
              SELECT order_source_id
                INTO l_order_source_id
                FROM oe_order_headers_all
               WHERE header_id = l_loaded_lines_rec.order_header_id;

              IF l_order_source_id = 10 THEN
                l_demand_source_type_id  := 8;
              ELSE
                l_demand_source_type_id  := 2;
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('l_demand_source_type_id =' || l_demand_source_type_id, 'Perform_Overship_Distribution');
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF (l_debug = 1) THEN
                  DEBUG('Exception getting l_demand_source_type_id ', 'Perform_Overship_Distribution');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
            END;

            -- clear quantity tree cache
            inv_quantity_tree_pub.clear_quantity_cache;

            -- query quantity tree
            IF (l_debug = 1) THEN
              DEBUG('Before query quantity tree ', 'Perform_Overship_Distribution');
              DEBUG('l_demand_source_header_id =' || l_demand_source_header_id, 'Perform_Overship_Distribution');
              DEBUG('l_order_line_id =' || l_order_line_id, 'Perform_Overship_Distribution');
              DEBUG('l_lpn_cont_rec.revision =' || l_lpn_cont_rec.revision, 'Perform_Overship_Distribution');
              DEBUG('l_lpn_cont_rec.lot_number =' || l_lpn_cont_rec.lot_number, 'Perform_Overship_Distribution');
              DEBUG('l_lpn_cont_rec.subinventory_code =' || l_lpn_cont_rec.subinventory_code, 'Perform_Overship_Distribution');
              DEBUG('l_lpn_cont_rec.locator_id =' || l_lpn_cont_rec.locator_id, 'Perform_Overship_Distribution');
              DEBUG('l_lpn_cont_rec.lpn_id=' || l_lpn_cont_rec.lpn_id, 'Perform_Overship_Distribution');
            END IF;

            inv_quantity_tree_pub.query_quantities(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_transactable_qty
            , x_atr                        => l_atr
            , p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => l_lpn_cont_rec.inventory_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => l_lpn_cont_rec.revision_control
            , p_is_lot_control             => l_lpn_cont_rec.lot_control
            , p_is_serial_control          => l_lpn_cont_rec.serial_control
            , p_demand_source_type_id      => l_demand_source_type_id
            , p_demand_source_header_id    => l_demand_source_header_id
            , p_demand_source_line_id      => l_order_line_id
            , p_revision                   => l_lpn_cont_rec.revision
            , p_lot_number                 => l_lpn_cont_rec.lot_number
            , p_subinventory_code          => l_lpn_cont_rec.subinventory_code
            , p_locator_id                 => l_lpn_cont_rec.locator_id
            , p_lpn_id                     => l_lpn_cont_rec.lpn_id
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Validation failed for inv_quantity_tree_pub.query_quantities', 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('Validation failed for inv_quantity_tree_pub.query_quantities', 'Perform_Overship_Distribution');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
              DEBUG('Query tree Return status is ' || l_return_status, 'Perform_Overship_Distribution');
              DEBUG('l_transactable_qty= ' || l_transactable_qty, 'Perform_Overship_Distribution');
              DEBUG('After query quantity tree ', 'Perform_Overship_Distribution');
            END IF;

            IF l_transactable_qty > 0 THEN
              l_max_shippable_quantity  := TRUNC(l_max_quantity_allowed);

              IF (l_debug = 1) THEN
                DEBUG('max_remaining_quantity = ' || l_max_quantity_allowed, 'Perform_Overship_Distribution');
              END IF;

             --Bug#6071394.query the staged qty.
             SELECT NVL(SUM(picked_quantity),0) INTO l_staged_qty
	     FROM wsh_delivery_details
	     WHERE source_header_id = l_order_header_id
	     AND  source_line_id =l_order_line_id
	     AND  released_status='Y';

	      IF (l_debug = 1) THEN
                 DEBUG(' l_total_resvd_qty = ' ||  l_total_resvd_qty, 'Perform_Overship_Distribution');
		 DEBUG(' l_staged_qty = ' ||  l_staged_qty, 'Perform_Overship_Distribution');
		 DEBUG(' l_transactable_qty = ' ||  l_transactable_qty, 'Perform_Overship_Distribution');
              END IF;

	     --Bug#6071394.Added l_staged_qty  tothe following line.
             l_qty_overship   := LEAST(l_lpn_cont_rec.quantity,(l_max_shippable_quantity + l_staged_qty - l_total_resvd_qty), l_transactable_qty);
             l_qty_updt_resv           := l_qty_overship;

              IF l_qty_overship > 0 THEN
                -- create reservation
                l_reservation_record.primary_reservation_quantity  := l_qty_overship;
                l_reservation_record.reservation_quantity          := l_qty_overship;

                IF (l_debug = 1) THEN
                  DEBUG(
                    'Quantity to create reservation= ' || l_reservation_record.primary_reservation_quantity
                  , 'Perform_Overship_Distribution'
                  );
                END IF;

                l_reservation_record.organization_id               := p_org_id;
                l_reservation_record.inventory_item_id             := l_lpn_cont_rec.inventory_item_id;
                l_reservation_record.demand_source_header_id       := l_demand_source_header_id;
                l_reservation_record.demand_source_line_id         := l_loaded_lines_rec.order_line_id;
                l_reservation_record.reservation_uom_id            := NULL;
                l_reservation_record.reservation_uom_code          := l_loaded_lines_rec.primary_uom_code;
                l_reservation_record.primary_uom_code              := l_loaded_lines_rec.primary_uom_code;
                l_reservation_record.primary_uom_id                := NULL;
                l_reservation_record.supply_source_type_id         := 13;
                l_reservation_record.demand_source_type_id         := l_demand_source_type_id;
                l_reservation_record.ship_ready_flag               := 2;
                l_reservation_record.attribute1                    := NULL;
                l_reservation_record.attribute2                    := NULL;
                l_reservation_record.attribute3                    := NULL;
                l_reservation_record.attribute4                    := NULL;
                l_reservation_record.attribute5                    := NULL;
                l_reservation_record.attribute6                    := NULL;
                l_reservation_record.attribute7                    := NULL;
                l_reservation_record.attribute8                    := NULL;
                l_reservation_record.attribute9                    := NULL;
                l_reservation_record.attribute10                   := NULL;
                l_reservation_record.attribute11                   := NULL;
                l_reservation_record.attribute12                   := NULL;
                l_reservation_record.attribute13                   := NULL;
                l_reservation_record.attribute14                   := NULL;
                l_reservation_record.attribute15                   := NULL;
                l_reservation_record.attribute_category            := NULL;
                l_reservation_record.lpn_id                        := l_lpn_cont_rec.lpn_id;
                l_reservation_record.pick_slip_number              := NULL;
                l_reservation_record.lot_number_id                 := NULL;
                l_reservation_record.lot_number                    := l_lpn_cont_rec.lot_number;
                l_reservation_record.locator_id                    := l_lpn_cont_rec.locator_id;
                l_reservation_record.subinventory_id               := NULL;
                l_reservation_record.subinventory_code             := g_subinventory_code;
                l_reservation_record.revision                      := l_lpn_cont_rec.revision;
                l_reservation_record.supply_source_line_detail     := NULL;
                l_reservation_record.supply_source_name            := NULL;
                l_reservation_record.supply_source_line_id         := l_loaded_lines_rec.order_line_id;
                l_reservation_record.supply_source_header_id       := l_demand_source_header_id;
                l_reservation_record.external_source_line_id       := NULL;
                l_reservation_record.external_source_code          := NULL;
                l_reservation_record.autodetail_group_id           := NULL;
                l_reservation_record.demand_source_delivery        := NULL;
                l_reservation_record.demand_source_name            := NULL;
                l_reservation_record.requirement_date              := l_loaded_lines_rec.request_date;

                IF (l_debug = 1) THEN
                  DEBUG('Before call to create reservation', 'Perform_Overship_Distribution');
                END IF;

                inv_reservation_pub.create_reservation(
                  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , x_serial_number              => l_dummy_sn
                , x_quantity_reserved          => l_quantity_reserved_tmp
                , x_reservation_id             => l_reservation_id
                , p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , p_rsv_rec                    => l_reservation_record
                , p_partial_reservation_flag   => fnd_api.g_true
                , p_force_reservation_flag     => fnd_api.g_true
                , p_serial_number              => l_dummy_sn
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 3
                );

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('Create reservation failed for lpn_id= ' || l_lpn_cont_rec.lpn_id, 'Perform_Overship_Distribution');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('Unexpected error during create of Reservations lpn_id= ' || l_lpn_cont_rec.lpn_id
                    , 'Perform_Overship_Distribution');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF (l_debug = 1) THEN
                  DEBUG('Create reservations is successful ' || l_reservation_id, 'Perform_Overship_Distribution');
                  DEBUG('After call to create reservation', 'Perform_Overship_Distribution');
                END IF;

                -- update cache quantities
                g_lpn_contents_tab(l_index).quantity               := g_lpn_contents_tab(l_index).quantity - l_qty_overship;
                l_lpn_cont_rec.quantity                            := l_lpn_cont_rec.quantity - l_qty_overship;
                g_total_lpn_quantity                               := g_total_lpn_quantity - l_qty_overship;

                -- bug#2830138
                -- make backup of quantities used
                -- will be used if overship has to be rollbacked
                IF l_lpn_cont_qty_used.EXISTS(l_index) THEN
                  l_lpn_cont_qty_used(l_index)  := l_lpn_cont_qty_used(l_index) + l_qty_overship;
                ELSE
                  l_lpn_cont_qty_used(l_index)  := l_qty_overship;
                END IF;

                -- debug('Line '||l_loaded_lines_rec.order_line_id||'overshipped for quantity '||l_qty_updt_resv,'Perform_Overship_Distribution');
                 -- if all quantity consumed exit to lpn_content loop
                 -- update wds for processed_quantity=processed_quantity+g_total_lpn_quantity
                BEGIN
                  UPDATE wms_direct_ship_temp
                     SET processed_quantity =(processed_quantity + l_qty_overship)
                   WHERE organization_id = p_org_id
                     AND GROUP_ID = g_group_id
                     AND lpn_id = p_lpn_id
                     AND order_line_id = l_order_line_id;
                EXCEPTION
                  WHEN OTHERS THEN
                    IF (l_debug = 1) THEN
                      DEBUG('Exception updating WDS', 'Perform_Overship_Distribution');
                    END IF;

                    RAISE fnd_api.g_exc_unexpected_error;
                END;
              END IF; -- l_qty_overship>0
            END IF; -- l_transactable_qty>0

            IF l_lpn_cont_rec.quantity = 0 THEN
              EXIT;
            END IF;
          END IF; --revision
        END LOOP; -- loaded lines

        CLOSE loaded_lines;
      END IF;        -- quantity>0

          -- if still more quantity left lpn canot be loaded

      IF (l_debug = 1) THEN
        DEBUG('l_lpn_cont_rec.quantity=' || l_lpn_cont_rec.quantity, 'Perform_Overship_Distribution');
      END IF;

      IF l_lpn_cont_rec.quantity > 0 THEN
        IF (l_debug = 1) THEN
          DEBUG('Lpn cannot be loaded, unused quantity found', 'Perform_Overship_Distribution');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_error;

        -- bug#2830138
        -- revert back the changes to lpn_contents from backup
        IF l_lpn_cont_qty_used.COUNT > 0 THEN
          l_temp_count          := l_lpn_cont_qty_used.FIRST;

          WHILE l_temp_count IS NOT NULL LOOP
            g_lpn_contents_tab(l_temp_count).quantity  := g_lpn_contents_tab(l_temp_count).quantity + l_lpn_cont_qty_used(l_temp_count);
            l_temp_count                               := l_lpn_cont_qty_used.NEXT(l_temp_count);
          END LOOP; --while

          g_total_lpn_quantity  := l_old_total_lpn_qty;

          IF (l_debug = 1) THEN
            DEBUG('lpn contents restored from backup', 'Perform_Overship_Distribution');
            DEBUG('g_total_lpn_quantity=' || g_total_lpn_quantity, 'Perform_Overship_Distribution');
          END IF;
        END IF;

        fnd_message.set_name('WMS', 'WMS_LPN_NOT_CONSUMED');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;
    END IF; -- quantity>0

    IF (l_debug = 1) THEN
      DEBUG('l_index= ' || l_index, 'Perform_Overship_Distribution');
    END IF;
  END LOOP; -- g_lpn_contents_tab

  x_return_status  := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception occured', 'Perform_Overship_Distribution');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_ERROR_LOADING_LPN');
    fnd_msg_pub.ADD;
END perform_overship_distribution;

/*
   This procedure checks any type of hold applied on the order line.
 */

PROCEDURE check_holds(
  p_order_header_id IN            NUMBER
, p_order_line_id   IN            NUMBER
, x_return_status   OUT NOCOPY    VARCHAR2
, x_msg_count       OUT NOCOPY    NUMBER
, x_msg_data        OUT NOCOPY    VARCHAR2
) IS
  l_delivery_detail_id NUMBER;
  l_return_status      VARCHAR2(10);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(20000);
  l_debug              NUMBER          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('In the check holds procedure', 'Check_holds');
    DEBUG('header id:' || p_order_header_id, 'Check_holds');
    DEBUG('line id:' || p_order_line_id, 'Check_Holds');
  END IF;

  x_return_status  := fnd_api.g_ret_sts_success;

  SELECT delivery_detail_id
    INTO l_delivery_detail_id
    FROM wsh_delivery_details_ob_grp_v
   WHERE source_header_id = p_order_header_id
     AND source_line_id = p_order_line_id
     AND ROWNUM = 1;

  IF (l_debug = 1) THEN
    DEBUG('delivery detial id:' || l_delivery_detail_id, 'Check_Holds');
  END IF;

  wsh_details_validations.check_credit_holds(p_detail_id => l_delivery_detail_id, p_activity_type => 'PICK', p_source_code => 'OE'
  , x_return_status              => l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Credit Check holds API failed with status E ', 'Check_holds');
    END IF;

    RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    IF (l_debug = 1) THEN
      DEBUG('Check Credit Holds API failed with status U', 'Check_holds');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status  := fnd_api.g_ret_sts_error;

    IF (l_debug = 1) THEN
      DEBUG('fnd_api.g_exe_error ' || SQLERRM, 'Check_holds');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('FND_API.G_UNEXPECTED_ERR' || SQLERRM, 'check_holds');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF (l_debug = 1) THEN
      DEBUG('FND_API.G_UNEXPECTED_ERR' || SQLERRM, 'check_holds');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END check_holds;

/* Bug 2994099:This procedure cleanup all the temp data for a backordered delivery for this lpn */

PROCEDURE cleanup_orphan_rec(p_org_id IN NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR wstt_del IS
    SELECT DISTINCT delivery_id
               FROM wms_shipping_transaction_temp
              WHERE /*direct_ship_flag = 'Y'
                AND*/ organization_id = p_org_id;

  --
  CURSOR closed_del(p_del_id NUMBER) IS
    SELECT delivery_id
      FROM wsh_new_deliveries_ob_grp_v
     WHERE delivery_id = p_del_id
       AND status_code IN('CL', 'IT');

  --
  CURSOR lpn_cur(p_del_id NUMBER) IS
    SELECT lpn_id
      FROM wms_license_plate_numbers
     WHERE lpn_id IN(SELECT outermost_lpn_id
                       FROM wms_shipping_transaction_temp
                      WHERE delivery_id = p_del_id);

      -- AND LPN_CONTEXT=1;   As even during Ship Confirm the records werent gettng deleted
  --
  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  FOR l_wstt_del IN wstt_del LOOP
    FOR l_closed_del IN closed_del(l_wstt_del.delivery_id) LOOP
      FOR l_lpn_cur IN lpn_cur(l_closed_del.delivery_id) LOOP
        IF (l_debug = 1) THEN
          DEBUG('Clean up bad data for lpn=' || l_lpn_cur.lpn_id, 'Cleanup_Orphan_Rec');
        END IF;

        DELETE      wms_direct_ship_temp
              WHERE lpn_id = l_lpn_cur.lpn_id;

        DELETE      wms_freight_cost_temp
              WHERE lpn_id = l_lpn_cur.lpn_id;

        DELETE      wms_freight_cost_temp
              WHERE delivery_id = l_closed_del.delivery_id;

        DELETE      wms_freight_cost_temp
              WHERE trip_id IN(SELECT DISTINCT trip_id
                                          FROM wms_shipping_transaction_temp
                                         WHERE outermost_lpn_id = l_lpn_cur.lpn_id);

        DELETE      wms_shipping_transaction_temp
              WHERE outermost_lpn_id = l_lpn_cur.lpn_id;
      END LOOP;
    END LOOP;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception occured', 'Cleanup_Orphan_Rec');
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;
END cleanup_orphan_rec;

/*
 This function finds out if there is any record in lpn contents having
 available quantity >0 and end_item_unit_number=p_end_unit_number
 */

FUNCTION validate_end_unit_num(p_item_id IN NUMBER, p_end_unit_number IN VARCHAR2)
  RETURN BOOLEAN IS
  l_start_index NUMBER;
  l_end_index   NUMBER;
  l_result      BOOLEAN := FALSE;
  l_debug       NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('p_item_id=' || p_item_id, 'Validate_End_Unit_Num');
    DEBUG('p_end_unit_number=' || p_end_unit_number, 'Validate_End_Unit_Num');
  END IF;

  l_start_index  := g_lpn_contents_lookup_tab(p_item_id).start_index;
  l_end_index    := g_lpn_contents_lookup_tab(p_item_id).end_index;

  IF g_lpn_contents_tab(l_start_index).serial_control_code NOT IN(2, 5) THEN
    IF (l_debug = 1) THEN
      DEBUG('SUCCESS', 'Validate_End_Unit_Num');
    END IF;

    RETURN TRUE;
  ELSE
    IF g_cross_unit_allowed = 'Y' THEN
      IF (l_debug = 1) THEN
        DEBUG('SUCCESS', 'Validate_End_Unit_Num');
      END IF;

      RETURN TRUE;
    ELSE
      FOR l_rec IN l_start_index .. l_end_index LOOP
        IF (l_debug = 1) THEN
          DEBUG('EIUN lpn=' || g_lpn_contents_tab(l_rec).end_item_unit_number, 'Validate_End_Unit_Num');
        END IF;

        IF g_lpn_contents_tab(l_rec).quantity > 0 THEN
          IF NVL(g_lpn_contents_tab(l_rec).end_item_unit_number, '@@') = NVL(p_end_unit_number, '@@') THEN
            IF (l_debug = 1) THEN
              DEBUG('SUCCESS', 'Validate_End_Unit_Num');
            END IF;

            l_result  := TRUE;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

  RETURN l_result;
END validate_end_unit_num;

/* This function finds out that the item in g_lpn_contents_tab at index is having available quantity
   and its end_item_unit_number matches p_end_unit_number.
*/

FUNCTION validate_end_unit_num_at(p_index IN NUMBER, p_end_unit_number IN VARCHAR2)
  RETURN BOOLEAN IS
  l_result BOOLEAN := FALSE;
  l_debug  NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  IF (l_debug = 1) THEN
    DEBUG('p_index=' || p_index, 'Validate_End_Unit_Num_At');
    DEBUG('p_end_unit_number=' || p_end_unit_number, 'Validate_End_Unit_Num_At');
  END IF;

  IF g_lpn_contents_tab(p_index).serial_control_code NOT IN(2, 5) THEN
    IF (l_debug = 1) THEN
      DEBUG('SUCCESS', 'Validate_End_Unit_Num_At');
    END IF;

    RETURN TRUE;
  ELSE
    IF g_cross_unit_allowed = 'Y' THEN
      IF (l_debug = 1) THEN
        DEBUG('SUCCESS', 'Validate_End_Unit_Num_At');
      END IF;

      RETURN TRUE;
    ELSE
      IF g_lpn_contents_tab(p_index).quantity > 0 THEN
        IF NVL(g_lpn_contents_tab(p_index).end_item_unit_number, '@@') = NVL(p_end_unit_number, '@@') THEN
          IF (l_debug = 1) THEN
            DEBUG('SUCCESS', 'Validate_End_Unit_Num_At');
          END IF;

          l_result  := TRUE;
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN l_result;
END validate_end_unit_num_at;

/* End of Patchset I procedures */

FUNCTION GET_CATCH_WEIGHT
                        (P_ORG_ID IN NUMBER
                        ,P_LPN_ID IN NUMBER
                        ,P_INVENTORY_ITEM_ID IN NUMBER
                        ,P_REVISION IN VARCHAR2
                        ,P_LOT_NUMBER IN VARCHAR2
                        ,P_PICKED_QUANTITY_IN_PRI_UOM IN NUMBER
                        ) RETURN NUMBER IS
CURSOR C        (C_ORG_ID IN NUMBER
                ,C_LPN_ID IN NUMBER
                ,C_INVENTORY_ITEM_ID IN NUMBER
                ,C_REVISION IN VARCHAR2
                ,C_LOT_NUMBER IN VARCHAR2)
        IS
        SELECT
                t.ORG_ID
                ,t.LPN_ID
                ,t.INNER_LPN_ID
                ,t.INVENTORY_ITEM_ID
                ,t.REVISION
                ,t.LOT_NUMBER
                ,DECODE(t.PICKED_UOM_CODE, msi.primary_uom_code, t.PICKED_QUANTITY
                ,GREATEST(inv_convert.inv_um_convert(NULL, NULL,
                  t.PICKED_QUANTITY, t.PICKED_UOM_CODE, msi.primary_uom_code,
                  NULL, NULL), 0)) PICKED_QUANTITY_IN_PRI_UOM
                ,t.SECONDARY_UOM_CODE
                ,t.SECONDARY_QUANTITY
        FROM mtl_system_items msi, WMS_DS_CT_WT_GTEMP t
        WHERE t.INVENTORY_ITEM_ID = C_INVENTORY_ITEM_ID /* THIS HAS INDEX */
        AND t.ORG_ID = C_ORG_ID
        AND msi.INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
        AND msi.ORGANIZATION_ID = t.ORG_ID
        AND NVL(t.INNER_LPN_ID, t.LPN_ID) = C_LPN_ID
        AND NVL(t.REVISION,'#NULL#') = NVL(C_REVISION,'#NULL#')
        AND NVL(t.LOT_NUMBER,'#NULL#') = NVL(C_LOT_NUMBER,'#NULL#')
        AND t.SECONDARY_QUANTITY IS NOT NULL;
  CTWT_REC C%rowtype;
  RET_VAL NUMBER := NULL;
BEGIN
  IF (G_debug=1) THEN
    debug('P_ORG_ID = ' || P_ORG_ID, 'GET_CATCH_WEIGHT');
    debug('P_LPN_ID = ' || P_LPN_ID, 'GET_CATCH_WEIGHT');
    debug('P_INVENTORY_ITEM_ID = ' || P_INVENTORY_ITEM_ID, 'GET_CATCH_WEIGHT');
    debug('P_REVISION = ' || P_REVISION, 'GET_CATCH_WEIGHT');
    debug('P_LOT_NUMBER = ' || P_LOT_NUMBER, 'GET_CATCH_WEIGHT');
    debug('P_PICKED_QUANTITY_IN_PRI_UOM = ' || P_PICKED_QUANTITY_IN_PRI_UOM, 'GET_CATCH_WEIGHT');
  END IF;
  OPEN C (P_ORG_ID, P_LPN_ID, P_INVENTORY_ITEM_ID, P_REVISION, P_LOT_NUMBER);
  FETCH C INTO CTWT_REC;
  IF C%NOTFOUND THEN
    ret_val := null;
  ELSE
    IF P_PICKED_QUANTITY_IN_PRI_UOM = CTWT_REC.PICKED_QUANTITY_IN_PRI_UOM  THEN
      -- LPN Qty and Delivery Detail Line Qty matches
      RET_VAL := CTWT_REC.SECONDARY_QUANTITY;
    ELSE
      -- LPN Qty and Delivery Detail Line Qty doesn't match.
      -- Hence calculate/derive the
      -- Delivery Line's sec_qty as follows
      RET_VAL  := ((P_PICKED_QUANTITY_IN_PRI_UOM / CTWT_REC.PICKED_QUANTITY_IN_PRI_UOM) * CTWT_REC.SECONDARY_QUANTITY);
    END IF;
  END IF;

  IF ( RET_VAL < 0 ) THEN
    RET_VAL := NULL;
  END IF;
  IF (G_debug=1) THEN
    debug('Calculated SECONDARY_QUANTITY = ' || RET_VAL, 'GET_CATCH_WEIGHT');
  END IF;
  RETURN RET_VAL;
END GET_CATCH_WEIGHT;

END WMS_DIRECT_SHIP_PVT;

/
