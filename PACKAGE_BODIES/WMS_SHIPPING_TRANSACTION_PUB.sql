--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_TRANSACTION_PUB" AS
/* $Header: WMSPSHPB.pls 120.35.12010000.8 2009/10/09 05:41:17 kjujjuru ship $ */
G_Debug NUMBER;

G_RET_STS_SUCCESS      VARCHAR2(1) := FND_API.g_ret_sts_success;
G_RET_STS_ERROR        VARCHAR2(1) := FND_API.g_ret_sts_error;
G_RET_STS_UNEXP_ERROR  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_FALSE                VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE                 VARCHAR2(1) := FND_API.G_TRUE;

--Inline branching
G_WMS_CURRENT_RELEASE_LEVEL NUMBER := wms_control.g_current_release_level;
G_J_RELEASE_LEVEL           NUMBER := inv_release.g_j_release_level;
G_PACKAGE_VERSION           VARCHAR2(100) :=
'$Header: WMSPSHPB.pls 120.35.12010000.8 2009/10/09 05:41:17 kjujjuru ship $' ;

PROCEDURE DEBUG(p_message       IN VARCHAR2,
                p_module        IN VARCHAR2) IS
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   if g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   end if;
   if( g_debug = 1 ) then
       inv_trx_util_pub.trace(p_message, 'WMS_SHPTRX.'||p_module, 1);
    end if;
END;

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

      IF (l_msg_name <> 'WSH_DET_INV_INT_SUBMITTED') THEN
         fnd_msg_pub.delete_msg(p_msg_index=>i);
         debug('Deleted message at position: ' || i,'process_mobile_msg');
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      debug('Exception raised!','process_mobile_msg');
      NULL;
END process_mobile_msg;

--Patchset J LPN hierarchy
--This procedure will populate Shipping with the LPN hierarchy.
--It can be broken down into 3 major steps:
--1.  Create container records in Shipping.  Reuse existing container
--records if possible.
--2.  Create the nesting of these containers just created
--3.  Update the attribute of these newly created containers
--Assumptions:
--1.  When this procedure is called, Shipping knows of only inner most LPN

-- Release 12: lpn_hierarchy_actions is removed because it is not needed.
-- LPN hierarchy information will be in sync before the shipping stage.
/* PROCEDURE lpn_hierarchy_actions
  (x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2,
   p_organization_id IN NUMBER,
   p_outermost_lpn_id IN NUMBER,
   p_inner_most_lpn_wdd IN NUMBER DEFAULT NULL)
  IS*/

FUNCTION IS_LOADED(p_organization_id IN NUMBER,
                   p_dock_door_id   IN NUMBER,
                   p_dock_appoint_flag   IN VARCHAR2,
                   p_direct_ship_flag    IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2  IS
   lpn_loaded VARCHAR2(1) := 'N';
BEGIN
   select 'Y'
   into lpn_loaded
   from dual
   where exists (select 1
                 from wms_shipping_transaction_temp
                 where dock_door_id      = p_dock_door_id
                   and dock_appoint_flag = p_dock_appoint_flag
                   and organization_id   = p_organization_id
                   and nvl(direct_ship_flag,'N')  = p_direct_ship_flag );
   return lpn_loaded;
   EXCEPTION
       WHEN NO_DATA_FOUND then
          return 'N';
END IS_LOADED;

PROCEDURE GET_DOCK_DOORS(x_dock_door_LOV   OUT NOCOPY t_genref,
                         p_txn_dock_app    IN VARCHAR2,
                         p_organization_id in NUMBER,
                         p_dock_door       IN VARCHAR2) IS

  --Bug#6018835.Added following cursor.
  --cursor to check if any apptmts within the current time window.
  CURSOR current_schedule_cur IS
     SELECT 1
     FROM wms_dock_appointments_b wda, mtl_item_locations_kfv milk,
          wsh_delivery_legs_ob_grp_v wdl, wsh_Trip_stops_ob_grp_v wts, mtl_item_locations_kfv milk1,wsh_trips wt
     WHERE wda.dock_id = milk.inventory_location_id (+)
     and   wda.organization_id = milk.organization_id (+)
     and   wda.trip_stop = wdl.pick_up_stop_id (+)
     and   wdl.pick_up_stop_id = wts.stop_id (+)
     and   wt.trip_id (+) = wts.trip_id
     and   wda.start_time <= SYSDATE
     and   wda.end_time > SYSDATE
     and   wts.status_code <> 'CL' /*6634322*/
     and   milk.organization_id = p_organization_id
     and   milk1.organization_id (+) = wda.organization_id
     and   milk1.inventory_location_id (+) = wda.staging_Lane_Id
     and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
     and   nvl(milk.disable_date,sysdate+1) > sysdate
     and   rownum<2; --We need to just make sure that there exists a row, atleast.

  --Bug#6018835.Added following cursor.
  --cursor to check if any apptmts missed to be used in the past.
 CURSOR last_recent_schedule_cur IS
  SELECT 1
     FROM wms_dock_appointments_b wda, mtl_item_locations_kfv milk,
          wsh_delivery_legs_ob_grp_v wdl,wsh_Trip_stops_ob_grp_v wts, mtl_item_locations_kfv milk1,wsh_trips wt
     WHERE wda.dock_id = milk.inventory_location_id (+)
     and   wda.organization_id = milk.organization_id (+)
     and   wda.trip_stop = wdl.pick_up_stop_id (+)
     and   wdl.pick_up_stop_id = wts.stop_id (+)
     and   wt.trip_id (+) = wts.trip_id
     and   wda.end_time <= SYSDATE
     and   wts.status_code <> 'CL' /*6634322*/
     and   milk.organization_id = p_organization_id
     and   milk1.organization_id (+) = wda.organization_id
     and   milk1.inventory_location_id (+) = wda.staging_Lane_Id
     and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
     AND   nvl(milk.disable_date,sysdate+1) > sysdate
     ANd   rownum<2; --Just Checking the existance.

  l_available_appt    NUMBER := 0 ;

BEGIN
  -- 4539200 dherring: trip name added to following query. SELECT,FROM and WHERE affected.
  -- need to modify to check if the dock door has the valid status.
if (p_txn_dock_app = 'Y') then

 --Bug#6018835.Need to check if there is a row
  OPEN current_schedule_cur;
  FETCH current_schedule_cur into l_available_appt;
  CLOSE current_schedule_cur;

  IF (l_available_appt = 1 ) then --There is an apptmt in the current time window.
  --Bug# 2780663:
  --  Dock Door LOV should show only physical locators. (.)s at the positions of Project and Task
  --  segments should be suppressed from the KFV in the LOV. Alias "milk_concatenated_segments"
  --  is used to avoid "unambiguous column name" error
  open x_dock_door_lov for
     select distinct
             wda.dock_id
           , inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id)
             milk_concatenated_segments
           , wda.dock_appointment_id
           , wda.organization_id
           , wda.trip_stop
           , wts.trip_id
           , milk1.subinventory_code
           , milk1.concatenated_segments
           , is_loaded(p_organization_id,wda.dock_id,'Y')
           , wt.name trip_name
     from wms_dock_appointments_b wda
        , mtl_item_locations_kfv milk
        , wsh_delivery_legs_ob_grp_v wdl
        , wsh_Trip_stops_ob_grp_v wts
        , mtl_item_locations_kfv milk1
        ,wsh_trips wt
     where wda.dock_id = milk.inventory_location_id (+)
     and   wda.organization_id = milk.organization_id (+)
     and   wda.trip_stop = wdl.pick_up_stop_id (+)
     and   wdl.pick_up_stop_id = wts.stop_id (+)
     and   wt.trip_id (+) = wts.trip_id
     and   wda.start_time <= SYSDATE
     and   wda.end_time > SYSDATE
     and   wts.status_code <> 'CL' /*6634322*/
     and   milk.organization_id = p_organization_id
     and   milk1.organization_id (+) = wda.organization_id
     and   milk1.inventory_location_id (+) = wda.staging_Lane_Id
     and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
     AND   nvl(milk.disable_date,sysdate+1) > sysdate
     order by milk_concatenated_segments;

  --Bug#6018835.Ends.
  ELSE
     OPEN last_recent_schedule_cur;
     FETCH last_recent_schedule_cur INTO l_available_appt;
     CLOSE last_recent_schedule_cur;

     IF (l_available_appt=1) THEN  --There is an unused apptmt in the past.

       OPEN x_dock_door_lov FOR
	     SELECT dock_id , milk_concatenated_segments, dock_appointment_id,organization_id,
		   trip_stop, trip_id, subinventory_code,concatenated_segments , is_loaded , trip_name
		 FROM  (
		     SELECT distinct wda.dock_id,
		           inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) milk_concatenated_segments,
		           wda.dock_appointment_id,  wda.organization_id, wda.trip_stop, wts.trip_id,
		           milk1.subinventory_code,  milk1.concatenated_segments ,
		           WMS_SHIPPING_TRANSACTION_PUB.is_loaded(p_organization_id,wda.dock_id,'Y') is_loaded ,
		           wt.name trip_name , ( SYSDATE - wda.end_time ) last_schedule_time_diff
		    FROM wms_dock_appointments_b wda, mtl_item_locations_kfv milk, wsh_delivery_legs_ob_grp_v wdl,
		         wsh_Trip_stops_ob_grp_v wts, mtl_item_locations_kfv milk1,wsh_trips wt
		    WHERE wda.dock_id = milk.inventory_location_id (+)
		    and   wda.organization_id = milk.organization_id (+)
		    and   wda.trip_stop = wdl.pick_up_stop_id (+)
		    and   wdl.pick_up_stop_id = wts.stop_id (+)
		    and   wt.trip_id (+) = wts.trip_id
		    and   wda.end_time <= SYSDATE
		    and   wts.status_code <> 'CL' /*6634322*/
		    and   milk.organization_id = p_organization_id
		    and   milk1.organization_id (+) = wda.organization_id
		    and   milk1.inventory_location_id (+) = wda.staging_Lane_Id
		    and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
		    and   nvl(milk.disable_date,sysdate+1) > sysdate
		    ORDER BY  11 ASC
		        )
		WHERE ROWNUM<2;  --We need only the last recent apptmt.

    ELSE   --No apptmt in the past , so look for the furture ones.
     OPEN x_dock_door_lov FOR
	SELECT dock_id , milk_concatenated_segments, dock_appointment_id,organization_id,
	       trip_stop, trip_id, subinventory_code,concatenated_segments , is_loaded , trip_name
	FROM  (
		SELECT distinct wda.dock_id,
		       inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) milk_concatenated_segments,
		       wda.dock_appointment_id,  wda.organization_id, wda.trip_stop, wts.trip_id,
		       milk1.subinventory_code,  milk1.concatenated_segments ,
		       WMS_SHIPPING_TRANSACTION_PUB.is_loaded(p_organization_id,wda.dock_id,'Y') is_loaded ,
		       wt.name trip_name , ( wda.start_time - SYSDATE) next_schedule_time_diff
		FROM  wms_dock_appointments_b wda, mtl_item_locations_kfv milk, wsh_delivery_legs_ob_grp_v wdl,
		      wsh_Trip_stops_ob_grp_v wts, mtl_item_locations_kfv milk1,wsh_trips wt
		WHERE wda.dock_id = milk.inventory_location_id (+)
		and   wda.organization_id = milk.organization_id (+)
		and   wda.trip_stop = wdl.pick_up_stop_id (+)
		and   wdl.pick_up_stop_id = wts.stop_id (+)
		and   wt.trip_id (+) = wts.trip_id
		and   wda.start_time > SYSDATE
		and   wts.status_code <> 'CL' /*6634322*/
		and   milk.organization_id = p_organization_id
		and   milk1.organization_id (+) = wda.organization_id
		and   milk1.inventory_location_id (+) = wda.staging_Lane_Id
		and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
		and   nvl(milk.disable_date,sysdate+1) > sysdate
		ORDER BY  11 ASC
	       )
	WHERE ROWNUM<2; --We need only one (the immediate next apptmt).
    END IF;
 END IF;
 --Bug#6018835.Ends.
else
--Bug# 2780663:
--  Dock Door LOV should show only physical locators. (.)s at the positions of Project and Task
--  segments should be suppressed from the KFV in the LOV. Alias "milk_concatenated_segments"
--  is used to avoid "unambiguous column name" error
   open x_dock_door_lov for
    select milk.inventory_location_id,
           inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id)
           milk_concatenated_segments
           ,0, milk.organization_id,
           0,0,'','',is_loaded(p_organization_id,milk.inventory_location_id,'N')
           ,''
    from mtl_item_locations_kfv milk
    where inventory_location_type = 1
     AND  milk.organization_id = p_organization_id
     AND   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
     --AND   segment19 IS NULL -- Bug 5336849, As a release policy
     --      the code should not depend on FF view during patch installation
     --      so changing the logic
     AND nvl(milk.physical_location_id,milk.inventory_location_id) = milk.inventory_location_id
     AND nvl(milk.disable_date,sysdate+1) > sysdate
     ORDER BY milk_concatenated_segments;
end if;

END GET_DOCK_DOORS;

PROCEDURE validate_lpn_status
  (x_result             OUT NOCOPY NUMBER,
   x_msg_code   OUT NOCOPY VARCHAR2,
   p_trip_id    IN NUMBER,
   p_organization_id IN NUMBER,
   p_lpn_id             IN NUMBER ) IS

      l_delivery_detail_id NUMBER;
      l_transaction_Type_id NUMBER := -1;
      l_transaction_source_type_id NUMBER;
      l_transaction_action_id NUMBER;
      l_return_status VARCHAR2(1);
      l_result NUMBER;
      l_lpn_status VARCHAR2(1);
      l_wms_installed VARCHAR2(10);
      l_wms_installed_flag boolean;
      l_inventory_item_id  number;
      l_subinventory    varchar2(10);
      l_locator_id   number;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number   varchar2(80);
      l_serial_number varchar2(30);
      l_transaction_temp_id NUMBER;
      l_trx_status_enabled   number := 1;
      --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_debug number;

      CURSOR serial_numbers(p_transaction_temp_id NUMBER) IS
         SELECT msnt.fm_serial_number
           FROM mtl_serial_numbers_temp msnt
           WHERE transaction_temp_id = p_transaction_temp_id;

      cursor delivery_details(p_lpn_id NUMBER) is
         select wdd.delivery_detail_id
              , wdd.inventory_item_id
              , wdd.subinventory
              , wdd.locator_id
              , wdd.lot_number
              , wdd.serial_number
              , wdd.transaction_temp_id
           from wms_license_plate_numbers wlpn
              , wsh_delivery_details_ob_grp_v wdd
              , wsh_delivery_assignments_v wda
              , wsh_delivery_details_ob_grp_v wdd2
           where wlpn.lpn_id = wdd2.lpn_id
           and wlpn.outermost_lpn_id = p_lpn_id
           and wdd2.lpn_id is not null     -- for performance, bug 2418639
             and wda.parent_delivery_detail_id = wdd2.delivery_detail_id
             and wda.delivery_detail_id = wdd.delivery_detail_id
	   order by wdd.source_code; --bug7601434;

BEGIN
   if g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   end if;
   l_debug := g_debug;

   -- validate the status of item, sub, locator of the content of the lpn
   IF (l_debug = 1) THEN
      debug('In validate_lpn_status', 'ValidateLPN');
      debug('p_trip_id : ' || p_trip_id, 'ValidateLPN');
      debug('p_organization_id : ' || p_organization_id, 'ValidateLPN');
      debug('p_lpn_id : ' || p_lpn_id, 'ValidateLPN');
   END IF;

     x_result := 0;
   l_result := 0;
   open delivery_details(p_lpn_id);
   <<delivery_line_item_loop>>
     LOOP
        fetch delivery_details into l_delivery_detail_id,l_inventory_item_id,l_subinventory,l_locator_id
          ,l_lot_number, l_serial_number, l_transaction_temp_id;
        exit when delivery_details%NOTFOUND;

        IF (l_debug = 1) THEN
           debug('In validate_lpn_status', 'ValidateLPN');
           debug( 'l_delivery_detail_id is ' || l_delivery_detail_id, 'ValidateLPN');
        END IF;
        if (l_transaction_type_id = -1) then
           l_transaction_type_id :=
               INV_SHIPPING_TRANSACTION_PUB.GET_DELIVERY_TRANSACTION_TYPE(
                         l_delivery_detail_id,
                         l_transaction_source_type_id,
                         l_transaction_action_id,
                         l_return_status);
           IF (l_debug = 1) THEN
              debug( 'l_transaction_type_id is ' || l_transaction_type_id, 'ValidateLPN');
              debug( 'l_return_status is ' || l_return_status, 'ValidateLPN');
           END IF;
           if( l_return_Status <> 'C' ) then
              IF (l_debug = 1) THEN
                 debug( 'inv_shipping_transaction.get_Delivery_transaction_type', 'ValidateLPN');
              END IF;
              x_result := 1;
              x_msg_code := 'INV_INT_TRXTYPCODE';
              return;
           end if;

           -- check if the transaction_type is status control enabled
           select status_control_flag
             into l_trx_status_enabled
             from mtl_transaction_types
             where transaction_type_id = l_transaction_type_id;
           if l_trx_status_enabled = 2 then x_result := 0;  return; end if;

        end if;


        IF l_transaction_temp_id IS NULL THEN
           -- If the serial number is stamped on the WDD or the item is not serial controlled

           -- call is_status_applicable directly
           IF (l_debug = 1) THEN
              debug( 'call inv_material_status_grp.is_status_applicable', 'ValidateLPN');
           END IF;
           l_lpn_status := inv_material_status_grp.is_status_applicable
                                 (p_wms_installed      => 'TRUE',
                                  p_trx_status_enabled => l_trx_status_enabled,
                                  p_trx_type_id        => l_transaction_type_id,
                                  p_organization_id    => p_organization_id,
                                  p_inventory_item_id  => l_inventory_item_id,
                                  p_sub_code           => l_subinventory,
                                  p_locator_id         => l_locator_id,
                                  p_lot_number         => l_lot_number,
                                  p_serial_number      => l_serial_number,
                                  p_object_type        => 'A',
				  p_lpn_id             => p_lpn_id);
           IF (l_debug = 1) THEN
              debug( 'l_lpn_status is ' || l_lpn_status, 'ValidateLPN');
           END IF;

           IF l_lpn_status = 'Y' then
              l_result := 0;
              x_msg_code := 'NULL';
            ELSE
              l_result := 1;
              x_msg_code := 'WMS_CONT_INVALID_LPN';
              EXIT delivery_line_item_loop;
              -- populate error message accordingly
           END IF;
         ELSE
           -- If the serial numbers are stored in MSNT
           FOR l_serial_rec IN serial_numbers(l_transaction_temp_id) LOOP
              l_serial_number := l_serial_rec.fm_serial_number;
              IF (l_debug = 1) THEN
                 debug( 'call inv_material_status_grp.is_status_applicable', 'ValidateLPN');
              END IF;

              l_lpn_status := inv_material_status_grp.is_status_applicable
                                    (p_wms_installed      => 'TRUE',
                                     p_trx_status_enabled => l_trx_status_enabled,
                                     p_trx_type_id        => l_transaction_type_id,
                                     p_organization_id    => p_organization_id,
                                     p_inventory_item_id  => l_inventory_item_id,
                                     p_sub_code           => l_subinventory,
                                     p_locator_id         => l_locator_id,
                                     p_lot_number         => l_lot_number,
                                     p_serial_number      => l_serial_number,
                                     p_object_type        => 'A');
              IF (l_debug = 1) THEN
                 debug( 'l_lpn_status is ' || l_lpn_status, 'ValidateLPN');
              END IF;

              IF l_lpn_status = 'Y' then
                 l_result := 0;
                 x_msg_code := 'NULL';
               ELSE
                 l_result := 1;
                 x_msg_code := 'WMS_CONT_INVALID_LPN';
                 EXIT delivery_line_item_loop;
                 -- populate error message accordingly
              END IF;
           END LOOP;

        END IF;

     END LOOP;
     close delivery_details;

     IF (l_debug = 1) THEN
        debug( 'l_result is ' || l_result, 'ValidateLPN');
     END IF;
     x_result := l_result;
END validate_lpn_status;

procedure get_deliveries( x_delivery_lov OUT NOCOPY t_genref,
                          p_trip_id IN NUMBER) IS
BEGIN
   open x_delivery_lov FOR
     select wdl.delivery_id
     from wsh_delivery_legs_ob_grp_v wdl
        , wsh_trip_stops_ob_grp_v pickup_stop
        , wsh_trip_stops_ob_grp_v dropoff_stop
     where wdl.pick_up_stop_id = pickup_stop.stop_id
     and   wdl.drop_off_stop_id = dropoff_stop.stop_id
     and   pickup_stop.trip_id = dropoff_stop.trip_id
     and   pickup_stop.trip_id = p_trip_id;
END get_deliveries;

procedure get_delivery_info(x_delivery_info OUT NOCOPY t_genref,
                            p_delivery_id IN NUMBER) IS
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug( 'inside get_delivery_info', 'Get_Delivery_Info');
      debug(' p_delivery_id is ' || p_delivery_id, 'Get_Delivery_Info');
   END IF;
   open x_delivery_info for
     SELECT wnd.name
           , wnd.delivery_id
           , nvl(wnd.gross_weight, 0)
           , wnd.weight_uom_code
           , wnd.waybill
           , ' ' trip_name,
     INV_SHIPPING_TRANSACTION_PUB.GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
     FROM wsh_new_deliveries_ob_grp_v wnd
     WHERE wnd.delivery_id = p_delivery_id;
END get_delivery_info;

PROCEDURE GET_STAGING_LANE(x_staging_lane_LOV    OUT NOCOPY t_genref,
                           p_txn_dock            IN  VARCHAR2,
                           p_organization_id     IN NUMBER,
                           p_sub_code            IN VARCHAR2,
                           p_dock_appointment_id IN NUMBER,
                           p_staging_lane IN VARCHAR2) IS
BEGIN
   if( p_txn_dock = 'Y' ) then
      open x_staging_lane_lov for
        select distinct wda.staging_lane_id, milk.concatenated_segments
        from wms_dock_appointments_b wda
           , mtl_item_locations_kfv milk
           , wsh_trip_Stops_ob_grp_v pickup_stop
        where milk.inventory_location_id(+) = wda.staging_lane_id
        and   milk.organization_id(+) = wda.organization_id
        and   milk.organization_id = p_organization_id
        and   milk.subinventory_code = p_sub_code
        and   wda.dock_appointment_id = p_dock_appointment_id
        and   wda.trip_stop = pickup_stop.stop_id(+)
        and   milk.concatenated_segments like (p_staging_lane);
    elsif( p_txn_dock = 'N' ) then
      open x_staging_lane_lov for
        select distinct milk.inventory_location_id, milk.concatenated_segments
        from mtl_item_locations_kfv milk
           , wms_license_plate_numbers lpn
        where milk.inventory_location_id (+)  = lpn.locator_id
        and   milk.organization_id (+) = lpn.organization_id
        and   milk.organization_id = p_organization_id
        and   milk.subinventory_code = p_sub_code
        and   (lpn.lpn_context = wms_globals.lpn_context_inv OR lpn.lpn_context = wms_globals.lpn_context_picked)
        and   milk.concatenated_segments like (p_staging_lane);
   end if;
END GET_STAGING_LANE;


PROCEDURE GET_DELIVERY_DETAIL_ID(x_delivery_detail_id OUT NOCOPY t_genref,
                                 p_organization_id    IN NUMBER,
                                 p_locator_id         IN NUMBER,
                                 p_trip_id            IN NUMBER) IS
BEGIN
    open x_delivery_detail_id for
      select wdd.delivery_detail_id, wdd.lpn_id
      from wsh_delivery_details_ob_grp_v wdd
           , wsh_delivery_assignments_v wda
           , wsh_delivery_legs_ob_grp_v wdl
           , wsh_trip_stops_ob_grp_v pickup_stop
           , wsh_trip_stops_ob_grp_v dropoff_stop
      where wdd.delivery_detail_id = wda.delivery_detail_id
      and   wda.delivery_id = wdl.delivery_id
      and   wdl.pick_up_stop_id = pickup_stop.stop_id
      and   wdl.drop_off_Stop_id = dropoff_stop.stop_id
      and   pickup_stop.trip_id = dropoff_Stop.trip_id
      and   pickup_stop.trip_id = p_trip_id
      and   wdd.locator_id = p_locator_id
      and   wdd.organization_id = p_organization_id
      and   wdd.released_status = 'Y';
END GET_DELIVERY_DETAIL_ID;

PROCEDURE POPULATE_WSTT(x_return           OUT NOCOPY NUMBER,
                        x_msg_code         OUT NOCOPY VARCHAR2,
                        p_organization_id  IN NUMBER,
                        p_lpn_id           IN NUMBER,
                        p_trip_id          IN NUMBER,
                        p_dock_door_id     IN NUMBER,
                        p_direct_ship_flag IN VARCHAR2 DEFAULT 'N') IS
    cursor delivery_details(p_lpn_id NUMBER) is
       select wdd.delivery_detail_id
            , lpn.lpn_id
            , wdd.inventory_item_id
            , wdd.requested_quantity
            , wda.delivery_id
            , lpn.license_plate_number
            , wdd.locator_id
            , wdd.released_status
         from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            , wsh_delivery_details_ob_grp_v wdd2
         where wdd2.lpn_id = lpn.lpn_id
           and wdd2.lpn_id is not null
  	        and wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
           and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
           and wdd.delivery_detail_id = wda.delivery_detail_id
           AND nvl(wdd.container_flag,'N')='N'
           AND lpn.outermost_lpn_id = p_lpn_id;

      /* Bug: 4691277:
       * Added the join between wnd and wda to check the status of the delivery.
       * We should load only those deliveries that are still open */

         l_delivery_detail_id NUMBER;
         l_parent_lpn_id      NUMBER;
         l_parent_lpn         VARCHAR2(30);
         l_outermost_lpn_id   NUMBER;
         l_outermost_lpn      VARCHAR2(30);
         l_trip_name          VARCHAR2(30);
         l_delivery_id        NUMBER;
         l_delivery_name      VARCHAR2(30);
         l_inventory_item_id  NUMBER;
         l_requested_quantity NUMBER;
         l_locator_id         NUMBER;
         l_return_Status      VARCHAR2(1);
         l_trip_id            NUMBER;
         l_dock_appoint_flag  VARCHAR2(1);
         l_released_status    VARCHAR2(1);
         l_delivery_status_code VARCHAR2(2);

         l_msg_count          NUMBER;
         l_msg_data           VARCHAR2(2000);
         l_action_prms      wsh_interface_ext_grp.del_action_parameters_rectype;
         l_delivery_id_tab  wsh_util_core.id_tab_type;
         l_delivery_out_rec wsh_interface_ext_grp.del_action_out_rec_type;

         --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
         l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug( 'INSIDE populate_wstt', 'Populate_WSTT');
      debug('open delivery_details', 'Populate_WSTT');
      debug('p_organization_id = ' || p_organization_id, 'Populate_WSTT');
      debug('P_trip_id ' || p_trip_id, 'Populate_WSTT');
      debug('p_lpn_id ' || p_lpn_id, 'Populate_WSTT');
   END IF;

   open delivery_details(p_lpn_id);

   if p_trip_id <> 0 then
      l_trip_id := p_trip_id;
      l_dock_appoint_flag := 'Y';
    else
      l_dock_appoint_flag := 'N';
   end if;
   LOOP
      FETCH delivery_details
      INTO l_delivery_detail_id
         , l_parent_lpn_id
         , l_inventory_item_id
         , l_requested_quantity
         , l_delivery_id
         , l_parent_lpn
         , l_locator_id
         , l_released_status;
      EXIT WHEN delivery_details%NOTFOUND;

        l_released_status := 'R';
        -- Direct Ship
        -- Since Shipping is logging exception when staging a delivery line which is already packed
        -- I changed a call to stage during packing itself, so at the time of call populate_wstt
        -- delivery_line would have got staged. So hardcoding ORIG_RELEASE_STATUS = 'R' for now
        -- Aslam


        IF (l_debug = 1) THEN
           debug( 'l_delivery_detail_id is ' || l_delivery_detail_id, 'Populate_WSTT');
           debug( 'l_inventory_item_id is ' || l_inventory_item_id, 'Populate_WSTT');
           debug( 'l_requested_quantity is ' || l_requested_quantity, 'Populate_WSTT');
           debug( 'l_delivery_id is ' || l_delivery_id, 'Populate_WSTT');
           debug( 'l_parent_lpn_id is ' || l_parent_lpn_id, 'Populate_WSTT');
           debug( 'l_parent_lpn is ' || l_parent_lpn, 'Populate_WSTT');
        END IF;


        select outermost_lpn_id
          into l_outermost_lpn_id
          from wms_license_plate_numbers
          where lpn_id = l_parent_lpn_id;

        IF (l_debug = 1) THEN
           debug( 'l_outermost_lpn_id is ' || l_outermost_lpn_id, 'Populate_WSTT');
        END IF;
        BEGIN
           select license_plate_number
             into l_outermost_lpn
             from wms_license_plate_numbers
             where lpn_id = l_outermost_lpn_id;
        EXCEPTION
           when no_data_found then
              IF (l_debug = 1) THEN
                 debug('GOT Error: WMS_CONT_INVALID_LPN', 'Populate_WSTT');
              END IF;
              x_msg_code := 'WMS_CONT_INVALID_LPN';
        END;
        IF (l_debug = 1) THEN
           debug( 'l_outermost_lpn is ' || l_outermost_lpn, 'Populate_WSTT');
        END IF;

        BEGIN
           IF (l_delivery_id is not null) then
              SELECT name, status_code
                INTO l_delivery_name, l_delivery_status_code
                FROM wsh_new_deliveries_ob_grp_v
                WHERE delivery_id = l_delivery_id;
            ELSE
                 l_delivery_name := NULL;
                 l_delivery_status_code := NULL;
           END IF;

        EXCEPTION
           WHEN no_data_found then
              RAISE no_data_found;
        END;

        IF (l_debug = 1) THEN
           debug( 'l_delivery_name:  ' || l_delivery_name, 'Populate_WSTT');
           debug( 'l_delivery_status_code:  ' || l_delivery_status_code, 'Populate_WSTT');
        END IF;

        l_trip_id := null;
        IF (l_delivery_id IS NOT NULL AND
            (l_delivery_status_code = 'OP' OR
             l_delivery_status_code = 'PA'))
        THEN
           -- get the trip id if there is a trip associated with the delivery
              BEGIN
                 SELECT wts.trip_id
                   INTO l_trip_id
                   FROM   wsh_delivery_legs_ob_grp_v wdl
                        , wsh_trip_stops_ob_grp_v wts
                   WHERE wdl.delivery_id = l_delivery_id
                   AND wdl.pick_up_stop_id = wts.stop_id;

              EXCEPTION
                 WHEN no_data_found THEN
                      l_trip_id := NULL;
              END;

            IF (l_debug = 1) THEN
               debug( 'l_trip_id : ' || l_trip_id, 'Populate_WSTT');
            END IF;
        END IF;

        IF (l_delivery_id IS NULL)
           OR
             ((l_delivery_id IS NOT NULL)
              AND
               (l_delivery_status_code = 'OP' OR
                l_delivery_status_code = 'PA'))
        THEN
            IF (l_debug = 1) THEN
                debug( 'inserting WSTT.. ', 'Populate_WSTT');
            END IF;

            INSERT INTO wms_shipping_transaction_temp
             (organization_id,
              dock_door_id,
              trip_id,
              trip_name,
              delivery_id,
              delivery_name,
              delivery_detail_id,
              parent_lpn_id,
              parent_lpn,
              outermost_lpn_id,
              outermost_lpn,
              inventory_item_id,
              staging_lane_id,
              requested_quantity,
              dock_appoint_flag,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              ORIG_RELEASE_STATUS,
              DIRECT_SHIP_FLAG
              ) values
             (
              p_organization_id,
              p_dock_door_id,
              l_trip_id,
              null,
              l_delivery_id,
              l_delivery_name,
              l_delivery_detail_id,
              l_parent_lpn_id,
              l_parent_lpn,
              l_outermost_lpn_id,
              l_outermost_lpn,
              l_inventory_item_id,
              l_locator_id,
              l_requested_quantity,
              l_dock_appoint_flag,
              sysdate,
              FND_GLOBAL.USER_ID,
              sysdate,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.LOGIN_ID,
              l_released_status,
              p_direct_ship_flag
              );
        -- Mrana : 8/30/06: No need to call delivery merge, if the delivery is not open anymore
        --- <Changes for Delivery Merge>
           IF g_wms_current_release_level >= g_j_release_level AND
              l_delivery_id IS NOT NULL THEN  -- mrana: 8/30/06: added this condition
               IF (l_debug = 1) THEN
                   debug( 'Delivery merge call..wsh_interface_ext_grp.delivery_action ',
                          'Populate_WSTT');
               END IF;
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
                   debug( 'x_return_status : ' || l_return_status, 'Populate_WSTT');
                   debug( 'x_msg_count : ' || l_msg_count, 'Populate_WSTT');
                   debug( 'x_msg_data : ' || l_msg_data, 'Populate_WSTT');
               END IF;

               --Do not error out even if the API returns an error.
           END IF;
        -- </Changes for delivery merge>
        ELSE
            IF (l_debug = 1) THEN
               debug( 'Delivery status is not open  ..not insertingWSTT ', 'Populate_WSTT');
            END IF;
        END IF;

   END LOOP;
   close delivery_details;
   x_return := 0;
   x_msg_code := 'NULL';
EXCEPTION
   when others then
      x_return := 1;
      x_msg_code := 'WMS_ERROR_POPULATE_TEMP';
      -- populate error message
END POPULATE_WSTT;

FUNCTION GET_DELIVERY_NAME(p_delivery_id   IN NUMBER)
  RETURN VARCHAR2   IS
     p_name VARCHAR2(30);
BEGIN
   if p_delivery_id is null then return ' ';
    else
      select name
        into p_name
        from wsh_new_deliveries_ob_grp_v
        where delivery_id = p_delivery_id;
   end if;
   return p_name;
EXCEPTION
   when no_data_found then
      return ' ';
END GET_DELIVERY_NAME;

PROCEDURE GET_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
                      p_organization_id         IN NUMBER,
                      p_locator_id              IN NUMBER,
                      p_trip_id                 IN NUMBER,
                      p_trip_stop_id            IN NUMBER,
                      p_lpn                     IN VARCHAR2) is

   l_count NUMBER;
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug( 'Entered..opening the x_lpn_lov', 'GET_LPN_LOV');
      debug( 'p_organization_id is ' || p_organization_id, 'GET_LPN_LOV');
      debug( 'p_locator_id is ' || p_locator_id, 'GET_LPN_LOV');
      debug( 'p_trip_id is ' || p_trip_id, 'GET_LPN_LOV');
      debug( 'p_trip_stop_id is ' || p_trip_stop_id, 'GET_LPN_LOV');
      debug( 'p_lpn is ' || p_lpn, 'GET_LPN_LOV');
   END IF;

   --Start Added for bug 6717052
   IF WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
      if (p_trip_id <> 0) then
         -- to support loading while picking
         open  x_lpn_lov for
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number
            , wnd.delivery_id,wnd.name
            , nvl(wdd.load_seq_number,0) as load_seq_num
            from wms_license_plate_numbers lpn
            , wms_license_plate_numbers wlpn
            , wsh_new_deliveries_ob_grp_v wnd
            , wsh_delivery_legs_ob_grp_v wdl
            , wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wsh_delivery_details_ob_grp_v wdd2
            where wdl.pick_up_stop_id = p_trip_stop_id
            and wdl.delivery_id = wnd.delivery_id
            and wnd.status_code in ('OP', 'PA')
            and wnd.delivery_id = wda.delivery_id
            and wdd.delivery_detail_id = wda.delivery_detail_id
            and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
            and wdd2.lpn_id is not null     -- for performance, bug 2418639
            and wdd2.lpn_id = lpn.lpn_id
            and lpn.outermost_lpn_id = wlpn.lpn_id
            and (    wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and wnd.status_code in ('OP', 'PA')
            and wdd.released_status = 'Y'
            and (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and wlpn.license_plate_number like (p_lpn)
            order by load_seq_num, wlpn.license_plate_number;

      else
         open  x_lpn_lov for
             select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            , nvl(wdd.load_seq_number,0) as load_seq_num
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            ,wsh_new_deliveries_ob_grp_v wndv
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null
            and   wdd.lpn_id = lpn.outermost_lpn_id
	         and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            and   wda.delivery_id IS NOT NULL
            and   wda.delivery_id = wndv.delivery_id
            and   wndv.status_code in ('OP', 'PA')

            UNION
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            , nvl(wdd.load_seq_number,0) as load_seq_num
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            , wms_license_plate_numbers wlpn
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null
            and   wdd.lpn_id = lpn.outermost_lpn_id
 	         and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            and   wda.delivery_id IS NULL

            UNION
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            , nvl(wdd.load_seq_number,0) as load_seq_num
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            ,wsh_new_deliveries_ob_grp_v wndv
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null
            and   wdd.lpn_id = lpn.lpn_id
            and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            and   wda.delivery_id IS NOT NULL
            and   wda.delivery_id = wndv.delivery_id
            and   wndv.status_code in ('OP', 'PA')

            UNION
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            , nvl(wdd.load_seq_number,0) as load_seq_num
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null
            and   wdd.lpn_id = lpn.lpn_id
 	         and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            and   wda.delivery_id IS NULL
            order by load_seq_num, license_plate_number;
      end if;
   ELSE
   --END Added for bug 6717052
      if (p_trip_id <> 0) then
         -- to support loading while picking
         open  x_lpn_lov for
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number
            , wnd.delivery_id,wnd.name
            from wms_license_plate_numbers lpn
            , wms_license_plate_numbers wlpn
            , wsh_new_deliveries_ob_grp_v wnd
            , wsh_delivery_legs_ob_grp_v wdl
            , wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wsh_delivery_details_ob_grp_v wdd2
            where wdl.pick_up_stop_id = p_trip_stop_id
            and wdl.delivery_id = wnd.delivery_id
            --and wdl.PARENT_DELIVERY_LEG_ID IS NULL  -- Added for MDC : if delivery
            --is associated to a consol delivery, do not allow to select here
            and wnd.status_code in ('OP', 'PA')
            and wnd.delivery_id = wda.delivery_id
            and wdd.delivery_detail_id = wda.delivery_detail_id
            and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
            and wdd2.lpn_id is not null     -- for performance, bug 2418639
            and wdd2.lpn_id = lpn.lpn_id
            and lpn.outermost_lpn_id = wlpn.lpn_id
            --MR-MDC wlpn.lpn_context <> wms_globals.lpn_loaded_for_shipment
            and (    wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            -- 5582189 dherring additional criteria added to ensure ship confirmed deliveries
            -- do not appear in the lov
            and wnd.status_code in ('OP', 'PA')
            and wdd.released_status = 'Y'
            and (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and wlpn.license_plate_number like (p_lpn)
            order by wlpn.license_plate_number;

      else
         open  x_lpn_lov for
             select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            ,wsh_new_deliveries_ob_grp_v wndv
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null     -- for performance, bug 2418639
            and   wdd.lpn_id = lpn.outermost_lpn_id
            and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            -- 5582189 dherring UNION introduced to avoid cartesian join
            and   wda.delivery_id IS NOT NULL
            and   wda.delivery_id = wndv.delivery_id
            and   wndv.status_code in ('OP', 'PA')

            UNION
            select distinct lpn.outermost_lpn_id
            , wlpn.license_plate_number as license_plate_number
            , nvl(wda.delivery_id,0)
            , get_delivery_name(wda.delivery_id)
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            where wdd.delivery_detail_id = wda.delivery_detail_id
            and   wdd.lpn_id is not null     -- for performance, bug 2418639
            and   wdd.lpn_id = lpn.outermost_lpn_id
            and   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
            and   lpn.outermost_lpn_id = wlpn.lpn_id
            and   (wlpn.lpn_context = wms_container_pvt.lpn_context_picked
            OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
            and   lpn.organization_id = p_organization_id
            and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
            and   wlpn.license_plate_number like (p_lpn)
            -- 5582189 dherring UNION introduced to avoid cartesian join
            and   wda.delivery_id IS NULL
            order by license_plate_number;
      end if;
   --Start Added for bug 6717052
   END IF;
   --END Added for bug 6717052

END get_lpn_lov;

procedure nested_serial_check(x_result OUT NOCOPY NUMBER,
                              x_outermost_lpn OUT NOCOPY VARCHAR2,
                              x_outermost_lpn_id OUT NOCOPY NUMBER,
                              x_parent_lpn_id OUT NOCOPY NUMBER,
                              x_parent_lpn OUT NOCOPY VARCHAR2,
                              x_inventory_item_id OUT NOCOPY NUMBER,
                              x_quantity OUT NOCOPY NUMBER,
                              x_requested_quantity OUT NOCOPY NUMBER,
                              x_delivery_detail_id OUT NOCOPY NUMBER,
                              x_transaction_Temp_id OUT NOCOPY NUMBER,
                              x_item_name OUT NOCOPY VARCHAR2,
                              x_subinventory_code OUT NOCOPY VARCHAR2,
                              x_revision OUT NOCOPY VARCHAR2,
                              x_locator_id OUT NOCOPY NUMBER,
                              x_lot_number OUT NOCOPY VARCHAR2,
                              p_trip_id IN NUMBER,
                              p_outermost_lpn_id IN NUMBER) IS
cursor delivery_details(p_outermost_lpn_id IN NUMBER) is
/*    select wstt.trip_id, wstt.delivery_id, wstt.delivery_detail_id, wstt.inventory_item_id, wstt.quantity, wstt.outermost_lpn,
           wstt.parent_lpn_id, wstt.parent_lpn, wdd.serial_number,
           msik.concatenated_segments, msik.serial_number_control_code, wdd.requested_quantity,
           wdd.subinventory, wdd.revision, wdd.locator_id, wdd.lot_number
    from wms_shipping_transaction_temp wstt, wsh_delivery_details_ob_grp_v wdd, mtl_system_items_kfv msik
    where wstt.delivery_detail_id = wdd.delivery_detail_id
    and wstt.outermost_lpn_id = p_outermost_lpn_id
    and msik.inventory_item_id = wdd.inventory_item_id
    and msik.organization_id = wdd.organization_id
    and msik.serial_number_control_code = 6; */
-- The above cursor is very time consuming, so replace it with the following one.
    select 0,wda.delivery_id, wdd.delivery_detail_id, wdd.inventory_item_id,wdd.requested_quantity,
           wlpn2.license_plate_number,wlpn.lpn_id, wlpn.license_plate_number,wdd.serial_number,
           msik.concatenated_segments,
            msik.serial_number_control_code, wdd.requested_quantity,wdd.subinventory, wdd.revision,
            wdd.locator_id, wdd.lot_number,wdd.picked_quantity
    from wms_license_plate_numbers wlpn, wms_license_plate_numbers wlpn2, wsh_delivery_details_ob_grp_v wdd,
         mtl_system_items_kfv msik,
         wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd2
    where wlpn.outermost_lpn_id = p_outermost_lpn_id
      and wlpn.lpn_id = wdd2.lpn_id
      and wdd2.lpn_id is not null     -- for performance, bug 2418639
      and wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
      and wlpn.outermost_lpn_id = wlpn2.lpn_id
      and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
      and wda.delivery_detail_id = wdd.delivery_detail_id
      and wdd.organization_id = msik.organization_id
      and wdd.inventory_item_id = msik.inventory_item_id
      and msik.serial_number_control_code = 6
      and wdd.transaction_temp_id is null;

l_transaction_temp_id NUMBER;
l_trip_id NUMBER := p_trip_id;
l_delivery_id NUMBER := 0;
l_delivery_detail_id NUMBER := 0;
l_inventory_item_id NUMBER := 0;
l_quantity NUMBER := 0;
l_outermost_lpn VARCHAR2(30) := null;
l_parent_lpn_id NUMBER := 0;
l_parent_lpn VARCHAR2(30) := null;
l_serial_number varchar2(30) := null;
l_serial_number_control_code NUMBER := 0;
l_result NUMBER := 1;
l_requested_quantity NUMBER := 0;
l_item_name VARCHAR2(80);
l_outermost_lpn_id NUMBER := p_outermost_lpn_id;
l_subinventory_code VARCHAR2(30);
l_revision VARCHAR2(10);
l_locator_id NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
l_lot_number VARCHAR2(80);
l_picked_quantity NUMBER := 0;

l_detail_attributes wsh_interface.ChangedAttributeTabType;
l_InvPCInRecType    wsh_integration.InvPCInRecType;
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);

BEGIN
   debug('inside nested_serial_check', 'NESTED_SERIAL_CHECK');
   debug( 'p_trip_id is ' || p_trip_id, 'NESTED_SERIAL_CHECK');
   debug( 'p_outermost_lpn_id is ' || p_outermost_lpn_id, 'NESTED_SERIAL_CHECK');
   debug( 'openning delivery_details cursor', 'NESTED_SERIAL_CHECK');

   --patchset J.  Shipping API cleanup
   --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
   l_InvPCInRecType.transaction_id := NULL;
   l_InvPCInRecType.transaction_temp_id := NULL;
   l_InvPCInRecType.source_code :='INV';
   l_InvPCInRecType.api_version_number :=1.0;
   --\Shipping API cleanup

   open delivery_details( p_outermost_lpn_id);

   <<delivery_details_loop>>
     LOOP
        fetch delivery_details into l_trip_id, l_delivery_id, l_delivery_detail_id,
          l_inventory_item_id, l_quantity, l_outermost_lpn, l_parent_lpn_id,
          l_parent_lpn, l_serial_number, l_item_name, l_serial_number_control_code,
          l_requested_quantity,
          l_subinventory_code, l_revision, l_locator_id, l_lot_number,l_picked_quantity;
        exit when delivery_details%NOTFOUND;

        debug('l_serial_control_code is ' || l_serial_number_control_code, 'NESTED_SERIAL_CHECK');
        debug('l_requested_quantity is ' || l_quantity,'NESTED_SERIAL_CHECK');
        debug('l_picked_quantity is ' || l_picked_quantity,'NESTED_SERIAL_CHECK');

        if( l_serial_number_control_code = 6 AND l_serial_number is NULL) then
           l_result := 0;

           select transaction_temp_id
             into l_transaction_temp_id
             from wsh_delivery_details_ob_grp_v
             where delivery_detail_id = l_delivery_detail_id;

           if( l_transaction_temp_id is null ) then
              select mtl_material_Transactions_s.nextval
                into l_InvPCInRecType.transaction_temp_id
                from dual;

              l_transaction_temp_id := l_InvPCInRecType.transaction_temp_id;

              debug('About to call wsh_integration.Set_Inv_PC_Attributes','nested_serial_check');
              debug('transaction_temp_id set to: ' ||
                    l_InvPCInRecType.transaction_temp_id,
                    'nested_serial_check');

              --patchset J. Shipping API cleanup
              --call to set the global variable in preparation to update transaction_temp_id
              wsh_integration.Set_Inv_PC_Attributes
                (p_in_attributes => l_InvPCInRecType,
                 x_return_status => l_return_status,
                 x_msg_count     => l_msg_count,
                 x_msg_data      => l_msg_data);

              IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
                 debug('wsh_integration.set_inv_pc_attributes failed'
                       || ' with status: ' || l_return_status,'nested_serial_check');
                 --check where to handle this error
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;


              l_detail_attributes(1).delivery_detail_id :=
                l_delivery_detail_id;
              l_detail_attributes(1).action_flag := 'U';
              --Passing picked_quantity also because wsh_interface.update_shipping_attributes
              --will null it out if we do not
              l_detail_attributes(1).picked_quantity := l_picked_quantity;

              debug('About to call wsh_interface.update_shipping_attributes','nested_serial_check');
              debug('delivery_detail_id : ' ||
                    l_detail_attributes(1).delivery_detail_id,
                    'nested_serial_check');

              --update transaction_temp_id in WDD
              wsh_interface.update_shipping_attributes
                (x_return_status      => l_return_status,
                 p_changed_attributes => l_detail_attributes,
                 p_source_code        => 'INV');
              --\Shipping API cleanup
              IF l_return_status IN  (G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR)  THEN
                 debug('wsh_interface.update_shipping_attributes failed'
                       || ' with status: ' || l_return_status,'nested_serial_check');
                 --check where to handle this error
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
           END IF;
           exit delivery_details_loop;

         elsif( l_serial_number_control_code <> 6
                OR (l_serial_number_control_code = 6 AND l_serial_number is not null )) then
           l_result := 1;
        end if;
     END LOOP;

     x_result := l_result;
     x_outermost_lpn := l_outermost_lpn;
     x_outermost_lpn_id := l_outermost_lpn_id;
     x_parent_lpn_id := l_parent_lpn_id;
     x_parent_lpn := l_parent_lpn;
     x_inventory_item_id := l_inventory_item_id;
     --The number of serial numbers expected should be the picked_quantity
     --as user could have overpicked.
     x_quantity := l_picked_quantity;
     x_requested_quantity := l_requested_quantity;
     x_delivery_detail_id := l_delivery_detail_id;
     x_item_name := l_item_name;
     x_transaction_temp_id := l_transaction_Temp_id;
     x_subinventory_code := l_subinventory_code;
     x_locator_id := l_locator_id;
     x_revision := l_revision;
     x_lot_number := l_lot_number;

     Debug( 'l_result is ' || x_result, 'NESTED_SERIAL_CHECK');

END NESTED_SERIAL_CHECK;

/* the following procedure will not be used any more */
PROCEDURE LPN_DISCREPANCY_CHECK( x_result OUT NOCOPY NUMBER,
                                 x_parent_lpn_id OUT NOCOPY NUMBER,
                                 x_parent_lpn OUT NOCOPY VARCHAR2,
                                 x_inventory_item_id OUT NOCOPY NUMBER,
                                 x_quantity OUT NOCOPY NUMBER,
                                 x_requested_quantity OUT NOCOPY NUMBER,
                                 x_item_name OUT NOCOPY VARCHAR2,
                                 p_trip_id IN NUMBER,
                                 p_delivery_id IN NUMBER,
                                 p_outermost_lpn_id IN NUMBER) IS

cursor sum_delivery_details(p_outermost_lpn_id IN NUMBER, p_delivery_id IN NUMBER) is
    select sum(wdd.requested_quantity), sum(wlc.quantity), wda.delivery_id, wlc.inventory_item_id, wlc.parent_lpn_id
    from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd2,
         wms_license_plate_numbers lpn, wms_lpn_contents wlc
    where wdd.delivery_detail_id = wda.delivery_detail_id
    and   wdd2.delivery_detail_id = wda.parent_delivery_detail_id
    and   wdd2.lpn_id = lpn.lpn_id
    and   wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
    and   wlc.parent_lpn_id = lpn.lpn_id
    and   lpn.outermost_lpn_id = p_outermost_lpn_id
    and   wlc.inventory_item_id = wdd.inventory_item_id
--    and   (wda.delivery_id = p_delivery_id or wda.delivery_id is null)
    group by wda.delivery_id, wlc.inventory_item_id, wlc.parent_lpn_id;

l_delivery_detail_id NUMBER;
l_inventory_item_id NUMBER;
l_sum_quantity NUMBER;
l_parent_lpn_id NUMBER;
l_parent_lpn VARCHAR2(30);
l_result NUMBER;
l_sum_requested_quantity NUMBER;
l_item_name VARCHAR2(80);
l_delivery_id NUMBER;
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
    IF g_debug IS NULL THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF (l_debug = 1) THEN
       Debug( 'inside lpn_discrency_check', 'LPN_DISCREPANCY_CHECK');
    END IF;
    open sum_delivery_details(p_outermost_lpn_id, p_delivery_id);

    <<sum_delivery_details_loop>>
    LOOP
        fetch sum_delivery_details into l_sum_requested_quantity, l_sum_quantity,
                l_delivery_id, l_inventory_item_id, l_parent_lpn_id;
        IF (l_debug = 1) THEN
        Debug( 'l_sum_quantity is ' || l_sum_quantity, 'LPN_DISCREPANCY_CHECK');
        Debug( 'l_sum_requested_quantity is ' || l_sum_requested_quantity, 'LPN_DISCREPANCY_CHECK');
        END IF;
        exit when sum_delivery_details%NOTFOUND;

        if( l_sum_quantity < l_sum_requested_quantity ) then
            l_result := 0;
            select distinct wstt.parent_lpn
            into l_parent_lpn
            from wms_shipping_transaction_Temp wstt
            where wstt.parent_lpn_id = l_parent_lpn_id
            and   wstt.inventory_item_id = l_inventory_item_id;

            select distinct msik.concatenated_segments
            into l_item_name
            from mtl_system_items_kfv msik
            where msik.inventory_item_id = l_inventory_item_id;

            exit sum_delivery_details_loop;
        else
            l_result := 1;
        end if;

    END LOOP;

    x_result := l_result;
    x_parent_lpn_id := l_parent_lpn_id;
    x_parent_lpn := l_parent_lpn;
    x_inventory_item_id := l_inventory_item_id;
    x_quantity := l_sum_quantity;
    x_requested_quantity := l_sum_requested_quantity;
    x_item_name := l_item_name;
END LPN_DISCREPANCY_CHECK;

PROCEDURE check_lpn_in_diff_ship_method(p_outermost_lpn_id IN NUMBER,
                                        p_organization_id IN NUMBER,
                                        x_result OUT NOCOPY NUMBER) IS
    l_delivery_id   NUMBER;
    l_trip_id    NUMBER;
    cursor deliveries_in_lpn is
       select distinct wda.delivery_id
         from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wms_license_plate_numbers lpn,
         wsh_delivery_details_ob_grp_v wdd2
         where lpn.outermost_lpn_id = p_outermost_lpn_id
         and wdd2.lpn_id = lpn.lpn_id
         and wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
         and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
         and wdd.delivery_detail_id = wda.delivery_detail_id;

BEGIN
   x_result := 0;
     Debug( 'Entered check_lpn_in_diff_ship_method : ' , 'check_lpn_in_diff_ship_method');
     Debug( 'p_outermost_lpn_id:  ' || p_outermost_lpn_id, 'check_lpn_in_diff_ship_method');
     Debug( 'p_organization_id:  ' || p_organization_id, 'check_lpn_in_diff_ship_method');
   OPEN deliveries_in_lpn;
   LOOP
      fetch deliveries_in_lpn into l_delivery_id;
      exit When deliveries_in_lpn%NOTFOUND;

      BEGIN
         select 1
           into x_result
           from dual
           where exists (select 1
                         from wms_shipping_transaction_temp
                         where delivery_id = l_delivery_id
                         and direct_ship_flag='Y');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              Debug( 'No delivery id data for direct_ship_flag=Y in WSTT:  ' , 'check_lpn_in_diff_ship_method');
             BEGIN
                -- check the trip
                select wts.trip_id
                  into l_trip_id
                  from wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
                  where wdl.delivery_id = l_delivery_id
                  and wdl.pick_up_stop_id = wts.stop_id;

                select 1
                  into x_result
                  from dual
                  where exists (select 1
                                from wms_shipping_transaction_temp
                                where trip_id = l_trip_id
                                and direct_ship_flag='Y');
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
              Debug( 'No Trip data for direct_ship_flag=Y in WSTT:  ' , 'check_lpn_in_diff_ship_method');
                null;
             END;
      END;
   END LOOP;
   close deliveries_in_lpn;

      Debug( ' x_result :  ' || x_result , 'check_lpn_in_diff_ship_method');
EXCEPTION
   when others then null;
END check_lpn_in_diff_ship_method;


PROCEDURE check_lpn_in_same_trip(p_outermost_lpn_id IN NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_dock_door_id IN NUMBER,
                                 x_result OUT NOCOPY NUMBER,
                                 x_loaded_dock_door OUT NOCOPY VARCHAR2,
                                 x_delivery_name OUT NOCOPY VARCHAR2,
                                 x_trip_name     OUT NOCOPY VARCHAR2) IS
   l_delivery_id   NUMBER;
   l_trip_id    NUMBER;
   cursor deliveries_in_lpn is
      select distinct wda.delivery_id
        from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda, wms_license_plate_numbers lpn,
        wsh_delivery_details_ob_grp_v wdd2
        where lpn.outermost_lpn_id = p_outermost_lpn_id
        and wdd2.lpn_id = lpn.lpn_id
	     and wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
        and wdd2.lpn_id is not null     -- for performance, bug 2418639
          and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
          and wdd.delivery_detail_id = wda.delivery_detail_id;

   cursor lpn_in_other_dock(p_delivery_id  NUMBER) is
      select distinct milk.concatenated_segments
        from mtl_item_locations_kfv milk,wms_shipping_transaction_temp wstt
        where wstt.delivery_id           = p_delivery_id
        and wstt.organization_id       = p_organization_id
        and wstt.dock_appoint_flag     = 'N'
        and wstt.dock_door_id          <> p_dock_door_id
        and milk.organization_id        = p_organization_id
        and milk.inventory_location_id  =wstt.dock_door_id;

   cursor lpn_in_other_dock2(p_trip_id  NUMBER) is
      select distinct milk.concatenated_segments
        from mtl_item_locations_kfv milk,wms_shipping_transaction_temp wstt
        where wstt.trip_id           = p_trip_id
        and wstt.organization_id   = p_organization_id
        and wstt.dock_appoint_flag = 'N'
        and wstt.dock_door_id      <> p_dock_door_id
        and milk.organization_id    = p_organization_id
        and milk.inventory_location_id     =wstt.dock_door_id;

BEGIN
   x_result := 0;
   x_delivery_name := '';
   x_trip_name := '';

   OPEN deliveries_in_lpn;
   LOOP
      fetch deliveries_in_lpn into l_delivery_id;
      exit When deliveries_in_lpn%NOTFOUND;
      if l_delivery_id is not null then
         -- First check if this delivery have trip which is scheduled
         BEGIN
            select wt.name, milk.concatenated_segments
              into x_trip_name, x_loaded_dock_door
              from wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts,wms_dock_appointments_b wda,
              mtl_item_locations_kfv milk, wsh_trips_ob_grp_v wt
              where wdl.delivery_id = l_delivery_id
              and wdl.pick_up_stop_id = wts.stop_id
              and wda.trip_stop = wts.stop_id
              and wda.organization_id = p_organization_id
              and wda.organization_id = milk.organization_id
              and wda.dock_id = milk.inventory_location_id
              and wt.trip_id = wts.trip_id;
            x_result := 2;
            close deliveries_in_lpn;
            return;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN null;
         END;

         -- check if there are LPNs loaded from the same delivery
         OPEN lpn_in_other_dock(l_delivery_id);
         fetch lpn_in_other_dock into   x_loaded_dock_door;
         if lpn_in_other_dock%FOUND then
            select name
              into x_delivery_name
              from wsh_new_deliveries_ob_grp_v
              where delivery_id = l_delivery_id;
            x_result :=  1;
            close lpn_in_other_dock;
            close deliveries_in_lpn;
            return;
         end if;
         close lpn_in_other_dock;

         -- check the corresponding trip if any
         BEGIN
            select wts.trip_id
              into l_trip_id
              from wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
              where wdl.delivery_id = l_delivery_id
              and wdl.pick_up_stop_id = wts.stop_id;

            OPEN lpn_in_other_dock2(l_trip_id);
            fetch lpn_in_other_dock2 into   x_loaded_dock_door;
            if lpn_in_other_dock2%FOUND then
               select name
                 into x_trip_name
                 from wsh_trips_ob_grp_v
                 where trip_id = l_trip_id;
               x_result :=  1;
               close lpn_in_other_dock2;
               close deliveries_in_lpn;
               return;
            end if;
            close lpn_in_other_dock2;

         EXCEPTION
            when no_data_found then
               null;
         END;
      end if;
   END LOOP;
   close deliveries_in_lpn;

EXCEPTION
   when others then null;

END check_lpn_in_same_trip;

procedure check_credit_hold(x_result OUT NOCOPY NUMBER,
                     x_delivery_detail_ids OUT NOCOPY VARCHAR2,
                     p_outermost_lpn_id IN NUMBER) IS

   l_delivery_detail_id NUMBER;
   l_source_header_id NUMBER;
   l_source_line_id NUMBER;
   l_delivery_detail_ids VARCHAR2(1024):= NULL;
   l_return_status VARCHAR2(1);
   l_prev_hdr_id NUMBER;
   l_prev_line_id NUMBER;
   cursor delivery_details( p_outermost_lpn_id NUMBER) is
      select wdd.delivery_detail_id, wdd.source_header_id, wdd.source_line_id
        from wms_license_plate_numbers wlpn, wsh_delivery_details_ob_grp_v wdd0, wsh_delivery_assignments_v wda,
        wsh_delivery_details_ob_grp_v wdd
        where
        wlpn.outermost_lpn_id = p_outermost_lpn_id
        and wlpn.lpn_id = wdd0.lpn_id
        and wdd0.released_status = 'X'  -- For LPN reuse ER : 6845650
        and wdd0.delivery_detail_id = wda.parent_delivery_detail_id
        and wdd.delivery_detail_id = wda.delivery_detail_id
        and wdd.lpn_id is null
        order by wdd.source_header_id, wdd.source_line_id;
        -- Bug 4559904, WDD line with lpn does not have source_header_id and source_line_id
        -- populated correctly, do credit hold check will fail with those WDD lines.
        -- Added above to not pickup WDD records with lpn_id
        -- Also added order by so that the check_credit_holds only needs to be called when
        -- header or line is different.
     --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_debug number;

begin
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;
   x_result := 0;
   l_prev_hdr_id := -999;
   l_prev_line_id := -999;
   FOR a_delivery_detail IN delivery_details(p_outermost_lpn_id)  LOOP
      IF (l_prev_hdr_id <> nvl(a_delivery_detail.source_header_id, -999)) OR
         (l_prev_line_id <> nvl(a_delivery_detail.source_line_id, -999)) THEN
          IF (l_debug = 1) THEN
            Debug('Prev Header ID '||l_prev_hdr_id||' different from current Header ID '
                   ||a_delivery_detail.source_header_id||' OR', 'check_credit_hold');
            Debug('Prev Line ID '||l_prev_line_id||' different from current Line ID '
                   ||a_delivery_detail.source_line_id, 'check_credit_hold');
            Debug('Calling wsh_details_validations.check_credit_holds with ', 'check_credit_hold');
            Debug('   p_detail_id = '||a_delivery_detail.delivery_detail_id, 'check_credit_hold');
            Debug('   p_source_line_id = '||a_delivery_detail.source_line_id, 'check_credit_hold');
            Debug('   p_source_header_id = '||a_delivery_detail.source_header_id, 'check_credit_hold');
          END IF;
          wsh_details_validations.check_credit_holds
            (p_detail_id             => a_delivery_detail.delivery_detail_id,
             p_activity_type         => 'SHIP',
             p_source_line_id        => a_delivery_detail.source_line_id,
             p_source_header_id      => a_delivery_detail.source_header_id,
             p_source_code           => 'OE',
             p_init_flag             => 'Y',
             x_return_status         => l_return_status);

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             x_result :=  1;
             l_delivery_detail_ids := l_delivery_detail_ids || ' ' || a_delivery_detail.delivery_detail_id;
          END IF;

          l_prev_hdr_id := a_delivery_detail.source_header_id;
          l_prev_line_id := a_delivery_detail.source_line_id;
      ELSE
          IF (l_debug = 1) THEN
            Debug('Prev Header ID '||l_prev_hdr_id||' equals to current Header ID '
                   ||a_delivery_detail.source_header_id||' AND', 'check_credit_hold');
            Debug('Prev Line ID '||l_prev_line_id||' equals to current Line ID '
                   ||a_delivery_detail.source_line_id||', no need to call ' ||
                   ' wsh_details_validations.check_credit_holds', 'check_credit_hold');
          END IF;
      END IF;
   END LOOP;
   x_delivery_detail_ids := l_delivery_detail_ids;

end check_credit_hold;


PROCEDURE LPN_SUBMIT(
                     p_outermost_lpn_id IN NUMBER,
                     p_trip_id         IN NUMBER,
                     p_organization_id IN NUMBER,
                     p_dock_door_id    IN NUMBER,
                     x_error_code         OUT NOCOPY NUMBER,
                     x_outermost_lpn OUT NOCOPY VARCHAR2,
                     x_outermost_lpn_id OUT NOCOPY NUMBER,
                     x_parent_lpn_id OUT NOCOPY NUMBER,
                     x_parent_lpn OUT NOCOPY VARCHAR2,
                     x_inventory_item_id OUT NOCOPY NUMBER,
                     x_quantity OUT NOCOPY NUMBER,
                     x_requested_quantity OUT NOCOPY NUMBER,
                     x_delivery_detail_id OUT NOCOPY NUMBER,
                     x_transaction_Temp_id OUT NOCOPY NUMBER,
                     x_item_name OUT NOCOPY VARCHAR2,
                     x_subinventory_code OUT NOCOPY VARCHAR2,
                     x_revision OUT NOCOPY VARCHAR2,
                     x_locator_id OUT NOCOPY NUMBER,
                     x_lot_number OUT NOCOPY VARCHAR2,
                     x_loaded_dock_door OUT NOCOPY VARCHAR2,
                     x_delivery_name OUT NOCOPY VARCHAR2,
                     x_trip_name     OUT NOCOPY VARCHAR2,
                     x_delivery_detail_ids OUT NOCOPY VARCHAR2,
                     p_is_rfid_call  IN VARCHAR2 DEFAULT 'N'
                     ) IS

   cursor delivery_details( p_outermost_lpn_id NUMBER) is
      select delivery_detail_id, requested_quantity
        from wms_shipping_transaction_Temp
        where
        outermost_lpn_id = p_outermost_lpn_id;

   CURSOR nested_children_lpn_cursor IS
      SELECT lpn_id
        FROM WMS_LICENSE_PLATE_NUMBERS
        START WITH lpn_id = p_outermost_lpn_id
        CONNECT BY parent_lpn_id = PRIOR lpn_id;

   l_delivery_detail_id NUMBER;
   l_outer_cont_instance_id NUMBER;
   l_quantity NUMBER;
   l_load_before NUMBER := 0;
   l_result NUMBER;
   l_msg_code VARCHAR2(248);
   l_loaded_dock_door VARCHAR2(2000);
   l_delivery_count   NUMBER;
   l_delivery_detail_ids VARCHAR2(1024);

   l_detail_attributes wsh_delivery_details_pub.ChangedAttributeTabType;

   l_index NUMBER := 1;
   l_return_status VARCHAR2(1);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);

   l_consol_delivery_id NUMBER;  --mdc
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;
   x_error_code := 0;
   IF (l_debug = 1) THEN
      Debug( 'Entered lpn_submit ' , 'LPN_SUBMIT');
      Debug( 'p_outermost_lpn_id : ' || p_outermost_lpn_id, 'LPN_SUBMIT');
      Debug( 'p_trip_id : ' || p_trip_id, 'LPN_SUBMIT');
      Debug( 'p_organization_id : ' || p_organization_id, 'LPN_SUBMIT');
      Debug( 'p_dock_door_id : ' || p_dock_door_id, 'LPN_SUBMIT');
      Debug( 'p_is_rfid_call : ' || p_is_rfid_call, 'LPN_SUBMIT');
   END IF;


   -- First check if the lpn has been loaded before
    BEGIN
       select 1
         into l_load_before
         from DUAL
         where exists (
                       select 1
                       from wms_shipping_transaction_temp
                       where outermost_lpn_id = p_outermost_lpn_id
                       );

       if l_load_before = 1 then
          x_error_code := 1;
          return;
       end if;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN null;
    END;

    IF (l_debug = 1) THEN
       Debug('Check if any other LPNs in the same delivery is loaded by other ship ' ||
              'method such as direct ship','LPN_SUBMIT');
    END IF;
    check_lpn_in_diff_ship_method(p_outermost_lpn_id,
                                  p_organization_id,
                                  l_result);
    if l_result = 1 then
       x_error_code := 8;
       return;
    end if;

    IF (l_debug = 1) THEN
       Debug('Check if any other LPNs in teh same delivery or same trip is ' ||
              'loaded to another dock door', 'LPN_SUBMIT');
    END IF;
    -- check if any other LPNs in teh same delivery or same trip is loaded to another dock door
    -- Only need to check for LPN Ship Page
    if (p_trip_id = 0) then
       check_lpn_in_same_trip(p_outermost_lpn_id,
                              p_organization_id,
                              p_dock_door_id,
                              l_result,
                              l_loaded_dock_door,
                              x_delivery_name,
                              x_trip_name);
       if l_result = 1 then
          x_error_code := 5;
          x_loaded_dock_door := l_loaded_dock_door;
          return;
        elsif l_result = 2 then
          x_error_code := 6;
          x_loaded_dock_door := l_loaded_dock_door;
          IF p_is_rfid_call = 'N' then--we do want to proceed for RFID call
             return;
          END IF;
       end if;

    end if;

    IF (l_debug = 1) THEN
       Debug('check if there is any delivery line on credit check hold, p_outer_most_lpn_id='
               ||p_outermost_lpn_id,'LPN_SUBMIT');
    END IF;
    check_credit_hold(l_result,
                      l_delivery_detail_ids,
                      p_outermost_lpn_id);
    if l_result = 1 then
       x_error_code := 9;
       x_delivery_detail_ids := l_delivery_detail_ids;
       return;
    end if;


    IF (l_debug = 1) THEN
       Debug('Check LPN STATUS','LPN_SUBMIT');
    END IF;
    -- Second check if the LPN's status is correct
    Validate_LPN_Status(l_result,
                        l_msg_code,
                        p_trip_id,
                        p_organization_id,
                        p_outermost_lpn_id);
    if l_result = 1 then
       x_error_code := 2;
       return;
    end if;

    /* R12 MDC  : This is not required any more
    -- check if the outermost LPN contains multiple delivery
    if p_trip_id = 0 then
       select count(distinct wda.delivery_id)
         into l_delivery_count
         from wsh_delivery_assignments_v wda, wsh_delivery_details_ob_grp_v wdd
         , wms_license_plate_numbers wlpn
         where wlpn.outermost_lpn_id = p_outermost_lpn_id
         and wlpn.lpn_id = wdd.lpn_id
         and wdd.lpn_id is not null     -- for performance, bug 2418639
           and wda.parent_delivery_detail_id = wdd.delivery_detail_id
           and wda.delivery_id is not null;
      if l_delivery_count >1 then
         x_error_code := 7;
         return;
      end if;
    end if; */

    IF (l_debug = 1) THEN
       Debug('Populate record','LPN_SUBMIT');
    END IF;
    -- Populate the lpn info to the temp table
    POPULATE_WSTT(l_result,
                  l_msg_code,
                  p_organization_id,
                  p_outermost_lpn_id,
                  p_trip_id,
                  p_dock_door_id);
    if l_result = 1 then
       x_error_code := 3;
       return;
    end if;

    IF (l_debug = 1) THEN
       debug('Returned successfully from populate_wstt','LPN_SUBMIT');
    END IF;

    --MRANA : MDC :
    IF (l_debug = 1) THEN
        debug('About to delete mmtt/wdt with task type=7 and LPN: ' ||
              p_outermost_lpn_id,'LPN_SUBMIT');
    END IF;

    BEGIN
      DELETE wms_dispatched_tasks wdt
      WHERE  task_type = 7
      AND    organization_id = p_organization_id
      AND    transfer_lpn_id = p_outermost_lpn_id;
      IF (l_debug = 1) THEN debug('DELETED WDT FOR LPN: ' || p_outermost_lpn_id,'LPN_SUBMIT'); END IF;

      DELETE mtl_material_transactions_temp  mmtt
      WHERE  wms_task_type = 7
      AND    organization_id = p_organization_id
      AND    content_lpn_id = p_outermost_lpn_id;
      IF (l_debug = 1) THEN debug('DELETED WDT FOR LPN: ' || p_outermost_lpn_id,'LPN_SUBMIT'); END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN debug('NO Data found to delete MMTT/WDT : ','LPN_SUBMIT' ); END IF;
        NULL;
    END ;


    --patchset J.  Shipping API cleanup
    -- Update the shipping quantity
    l_index :=1;
    l_detail_attributes.DELETE;
    open delivery_details(p_outermost_lpn_id);
    LOOP
       fetch delivery_details
         into l_delivery_detail_id,l_quantity;

       exit when delivery_details%NOTFOUND;

       l_detail_attributes(l_index).delivery_detail_id :=
         l_delivery_detail_id;
       l_detail_attributes(l_index).shipped_quantity := l_quantity;

       IF (l_debug = 1) THEN
          Debug( 'Update line '||l_detail_attributes(l_index).delivery_detail_id||
                 ' with shipped quantity '|| l_detail_attributes(l_index).shipped_quantity,
                'LPN_SUBMIT');
       END IF;

       l_index := l_index + 1;
    END LOOP;
    close delivery_details;

     IF (l_debug = 1) THEN
        debug('l_detail_attributes count : ' || l_detail_attributes.COUNT ,
              'LPN_SUBMIT');
        Debug('About to call Shipping API to update the shipped quantity','LPN_SUBMIT');
    END IF;

    wsh_delivery_details_pub.update_shipping_attributes
      (p_api_version_number => 1.0,
       p_init_msg_list      => G_TRUE,
       p_commit             => G_FALSE,
       x_return_status      => l_return_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_changed_attributes => l_detail_attributes,
       p_source_code        => 'OE');

   IF l_return_status <> G_RET_STS_SUCCESS THEN
      IF l_debug = 1 THEN
         debug('wsh_delivery_details_pub.update_shipping_attributes failed'
               || ' with status: ' || l_return_status, 'LPN_SUBMIT');
         debug('l_msg_count: ' || l_msg_count,'LPN_SUBMIT');
         debug('l_msg_data: ' || l_msg_data,'LPN_SUBMIT');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --\Shipping API cleanup

   -- change the LPN context
   UPDATE WMS_LICENSE_PLATE_NUMBERS
     SET lpn_context                =  WMS_Container_PUB.LPN_LOADED_FOR_SHIPMENT,
     last_update_date             =  SYSDATE,
     last_updated_by              =  FND_GLOBAL.USER_ID
     where lpn_id = p_outermost_lpn_id;

   -- update the lpn context for all children lpns
   FOR l_lpn_id IN nested_children_lpn_cursor LOOP
      UPDATE WMS_LICENSE_PLATE_NUMBERS
        SET lpn_context                  =  WMS_Container_PUB.LPN_LOADED_FOR_SHIPMENT,
        last_update_date             =  SYSDATE,
        last_updated_by              =  FND_GLOBAL.USER_ID
        where lpn_id = l_lpn_id.lpn_id;
   END LOOP;

   --Patchset J LPN hierarchy
   --Populate Shipping with LPN hierarchy

   --Release 12: LPN Synchronize
   -- The following code of populating shipping with LPN hierarchy
   -- is not necessary because LPN hierarchy is in sync between WMS and WSH
   -- Removed the call to lpn_hierarchy_actions

   -- check serial numbers at sale order issue
   nested_serial_check(l_result,
                       x_outermost_lpn,
                       x_outermost_lpn_id,
                       x_parent_lpn_id,
                       x_parent_lpn,
                       x_inventory_item_id,
                       x_quantity,
                       x_requested_quantity,
                       x_delivery_detail_id,
                       x_transaction_Temp_id,
                       x_item_name,
                       x_subinventory_code,
                       x_revision,
                       x_locator_id,
                       x_lot_number,
                       p_trip_id,
                       p_outermost_lpn_id);
    if l_result = 0 then
        x_error_code :=  4;
        return;
    end if;

    -- to let other people know this LPN is loaded
    commit;
EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      --if keep current structure of returning error_code
      --no need to get message from stack as java side does it
      fnd_msg_pub.count_and_get(p_count => l_msg_count,
                        p_data  => l_msg_data);
      IF l_debug = 1 THEN
         debug('LPN_SUBMIT raised unexpected error','LPN_SUBMIT');
         debug('msg_stack: ' || l_msg_data,'LPN_SUBMIT');
      END IF;
      x_error_code := 9999; --check what java side does with this error_code
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
         debug('Other exception raised: ' || SQLERRM, 'LPN_SUBMIT');
      END IF;
      x_error_code := 9999;
END LPN_SUBMIT;

PROCEDURE CHECK_LPN_DELIVERIES(p_trip_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_dock_door_id IN NUMBER,
                               p_outermost_lpn_id  IN NUMBER,
                               p_delivery_id       IN NUMBER,
                               x_error_code OUT NOCOPY NUMBER,
                               x_missing_item OUT NOCOPY t_genref,
                               x_missing_lpns OUT NOCOPY t_genref,
                               x_ship_set     OUT NOCOPY VARCHAR2,
                               x_delivery_info OUT NOCOPY t_genref,
                               x_deli_count OUT NOCOPY NUMBER,
                               p_rfid_call IN VARCHAR2 DEFAULT 'N')
  IS
     l_missing_exists  NUMBER;
     l_return_status VARCHAR2(1);
     l_error_msg   VARCHAR2(240);
     l_delivery_id   NUMBER;
     l_dock_appoint_flag VARCHAR2(1);
     temp_val   NUMBER;

     l_action_prms      wsh_interface_ext_grp.del_action_parameters_rectype; --g-log
     l_delivery_id_tab  wsh_util_core.id_tab_type;
     l_delivery_out_rec wsh_interface_ext_grp.del_action_out_rec_type;
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(2000);

     /**********************************
     * variable to hold the ignore_for_planning flag of WDD.
       * Added for g-log changes
       **********************************/


     l_ignore_for_planning        wsh_delivery_details.ignore_for_planning%type;
     l_tms_interface_flag         wsh_new_deliveries.TMS_INTERFACE_FLAG%TYPE;


     cursor delivery_for_trip is
        select distinct delivery_id
          from WMS_SHIPPING_TRANSACTION_TEMP
          where organization_id = p_organization_id
          and dock_door_id = p_dock_door_id
          and trip_id = p_trip_id
          AND nvl(direct_ship_flag,'N')='N';

     cursor delivery_for_dock is
        select distinct delivery_id
          from WMS_SHIPPING_TRANSACTION_TEMP
          where organization_id = p_organization_id
          and dock_door_id = p_dock_door_id
          and dock_appoint_flag = 'N'
          AND nvl(direct_ship_flag,'N')='N';

     CURSOR c_get_otm_flags IS
	SELECT ignore_for_planning, tms_interface_flag
	  FROM wsh_new_deliveries_ob_grp_v
	  WHERE delivery_id = l_delivery_id;

     --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_debug number;

      l_delivery_type  VARCHAR2(30);  -- MDC : 5239774
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   x_error_code := 0;

   IF (l_debug = 1) THEN
      DEbug('Entered LPN CHECK ....with ','LPN_CHECK');
      DEbug('p_trip_id : ' || p_trip_id , 'LPN_CHECK');
      DEbug('p_dock_door_id: ' || p_dock_door_id, 'LPN_CHECK');
      DEbug('p_outermost_lpn_id: ' || p_outermost_lpn_id, 'LPN_CHECK');
      DEbug('p_delivery_id: ' || p_delivery_id, 'LPN_CHECK');
      DEbug('p_rfid_call : ' || p_rfid_call , 'LPN_CHECK');
   END IF;
   IF  p_rfid_call = 'N' then
      -- check if there is anything loaded
      if (p_trip_id = 0) then l_dock_appoint_flag := 'N';
       else l_dock_appoint_flag := 'Y'; end if;

       if (is_loaded(p_organization_id,p_dock_door_id,l_dock_appoint_flag) = 'N') then
          x_error_code := 5;
          return;
       end if;
    ELSE
      IF (l_debug = 1) THEN
         DEbug('No Check of Dock-appointment for RFID','LPN_CHECK');
      END IF;
   END IF;

    -- check missing item first
   IF (l_debug = 1) THEN
      DEbug('Checking missing items','LPN_CHECK');
   END IF;
   MISSING_ITEM_CHECK( x_missing_item,
                       p_trip_id,
                       p_dock_door_id,
                       p_organization_id,
                       l_missing_exists);
   if (l_missing_exists > 0) then
       x_error_code := 1;
       return;
    end if;

    -- check missing LPNs
    IF (l_debug = 1) THEN
       DEbug('Checking missing LPNs','LPN_CHECK');
    END IF;
    MISSING_LPN_CHECK( x_missing_lpns,
                       p_trip_id,
                       p_dock_door_id,
                       p_organization_id,
                       l_missing_exists);
   IF (l_debug = 1) THEN
      DEbug('l_missing_exists: ' || l_missing_exists,'LPN_CHECK');
   end if;
    if (l_missing_exists > 0) then
        x_error_code := 2;
        return;
    end if;

    -- check ship set
    SHIP_SET_CHECK(p_trip_id,
                   p_dock_door_id,
                   p_organization_id,
                   x_ship_set,
                   l_return_status,
                   l_error_msg);
   IF (l_debug = 1) THEN
      DEbug('x_ship_set: ' || x_ship_set,'LPN_CHECK');
      DEbug('l_return_status: ' || l_return_status,'LPN_CHECK');
      DEbug('l_error_msg: ' || l_error_msg,'LPN_CHECK');
   end if;
    if l_return_status = 'E' then
       x_error_code := 3;
--       return;
    end if;


    -- Locked the record first to avoid conccurent process error

   BEGIN
      if p_trip_id >0 then
         select 1
           into temp_val
           from WMS_SHIPPING_TRANSACTION_TEMP
           where organization_id = p_organization_id
           and dock_door_id = p_dock_door_id
           and trip_id = p_trip_id
           and rownum = 1
           for update NOWAIT;
       else
         select 1
           into temp_val
           from WMS_SHIPPING_TRANSACTION_TEMP
           where organization_id = p_organization_id
           and dock_door_id = p_dock_door_id
           and dock_appoint_flag = 'N'
           and rownum = 1
           for update NOWAIT;
      end if;
   EXCEPTION WHEN others THEN
      x_error_code := 6;
      return;
   END;
   IF (l_debug = 1) THEN
      DEbug('temp_val: ' || temp_val,'LPN_CHECK');
   end if;

   -- create delviery for LPNs without delivery
   l_return_status := 'S';
   if p_trip_id = 0 then
      CREATE_DELIVERY(p_outermost_lpn_id,
                      p_trip_id,
                      p_organization_id,
                      p_dock_door_id,
                      l_delivery_id,
                      l_return_status,
                      l_error_msg);
      if ( l_return_status <> 'S') then
         x_error_code := 4;
         return;
      end if;
      IF (l_debug = 1) THEN
         DEbug('l_delivery_id: ' || l_delivery_id,'LPN_CHECK');
         DEbug('l_return_status: ' || l_return_status,'LPN_CHECK');
         DEbug('l_error_msg: ' || l_error_msg,'LPN_CHECK');
      end if;


      --Add G-log code here -START
      IF l_delivery_id > 0 AND WSH_UTIL_CORE.GC3_IS_INSTALLED = 'Y' THEN
	 IF (l_debug = 1) THEN
	    debug('G-Log Changes: G-Log installed', 'LPN_CHECK');
	 END IF;


	 OPEN c_get_otm_flags;
	 FETCH c_get_otm_flags INTO l_ignore_for_planning, l_tms_interface_flag ;

	 IF (c_get_otm_flags%NOTFOUND) THEN
	    IF (l_debug = 1) THEN
	       debug('No WDDs found for the delivery created ', 'LPN_CHECK');
	    END IF;
	 END IF;
	 CLOSE c_get_otm_flags;

	 --Important Note: Irrespective of the severity level of 'CR' exception for the delivery just
	 --created, we have to mark the delivery to ignore_for_planning so that the
	 --transaction goes through fine.
	 -- Hence there is no call to WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM().
	 -- Here delivery was created in the backend for the line that the use
	 -- chose to ship confirm. it IS ALL happening in the backend.


	 IF l_ignore_for_planning = 'N' AND l_tms_interface_flag = 'CR' THEN
	    IF (l_debug = 1) THEN
	       debug('ignore_for_planning of WDD is N ', 'LPN_CHECK');
	    END IF;
	    l_delivery_id_tab(1) := l_delivery_id;
	    l_action_prms.caller := 'WMS_LPNSHP';
	    l_action_prms.event := wsh_interface_ext_grp.g_start_of_shipping;
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
	       debug('Called wsh_interface_ext_grp.delivery_action with action_code IGNORE_PLAN and return status: ' || l_return_status, 'LPN_CHECK');
	    END IF;
	    IF l_return_status = fnd_api.g_ret_sts_error THEN
	       x_error_code := 7;
	       return;
	    END IF;
	 END IF;
      END IF;
      --Add G-log code here -END

   end if;

   l_delivery_type := NULL;
   if p_delivery_id >0 then

     /* Bug: 5239774 : If p_delivery_id is a Consolidation_delivery (MDC)
 *      then, we should not use this as the first delivery displayed
 *      on ship confirm page . We will use the one returned from
 *      create_delvery API for the LastLPN*/
     SELECT wnd.delivery_type
     INTO l_delivery_type
     FROM wsh_new_deliveries_ob_grp_v wnd
     WHERE wnd.delivery_id = p_delivery_id;

     IF l_delivery_type = 'CONSOLIDATION' THEN
        NULL ; --we will pick up the first delivery of the outermost LPN
     ELSE
        l_delivery_id := p_delivery_id;
     END IF;
     IF (l_debug = 1) THEN
        Debug('l_delivery_type: ' || l_delivery_type,'LPN_CHECK');
        Debug('l_delivery_id: ' || l_delivery_id,'LPN_CHECK');
     END IF;
    elsif p_outermost_lpn_id = 0 then
      if p_trip_id >0 then
         open delivery_for_trip;
         fetch delivery_for_trip into l_delivery_id;
         close delivery_for_trip;
       else
         open delivery_for_dock;
         fetch delivery_for_dock into l_delivery_id;
         close delivery_for_dock;
      end if;
   end if;
IF (l_debug = 1) THEN
      DEbug('l_delivery_id: ' || l_delivery_id,'LPN_CHECK');
   end if;


   x_deli_count := 0;
   if p_trip_id >0 then
      select count(distinct delivery_id)
        into x_deli_count
        from WMS_SHIPPING_TRANSACTION_TEMP
        where organization_id = p_organization_id
        and dock_door_id = p_dock_door_id
        and trip_id = p_trip_id
        AND nvl(direct_ship_flag,'N')='N';
    else
      select count(distinct delivery_id)
        into x_deli_count
        from WMS_SHIPPING_TRANSACTION_TEMP
        where organization_id = p_organization_id
        and dock_door_id = p_dock_door_id
        and dock_appoint_flag = 'N'
        AND nvl(direct_ship_flag,'N')='N';
   end if;
   IF (l_debug = 1) THEN
      DEbug('l_delivery_id: ' || l_delivery_id,'LPN_CHECK');
      DEbug('x_deli_count: ' || x_deli_count,'LPN_CHECK');
   end if;


   -- Query the delivery
   get_delivery_info(x_delivery_info,
                     l_delivery_id);
EXCEPTION
   WHEN OTHERS THEN
      x_error_code := 9999;
END CHECK_LPN_DELIVERIES;




PROCEDURE CREATE_DELIVERY(p_outermost_lpn_id IN NUMBER,
                          p_trip_id          IN NUMBER,
                          p_organization_id  IN NUMBER,
                          p_dock_door_id     IN NUMBER,
                          x_delivery_id      OUT NOCOPY NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_message          OUT NOCOPY VARCHAR2,
                          p_direct_ship_flag IN  VARCHAR2 DEFAULT 'N') IS

  cursor delivery_details  is
     select delivery_detail_id,OUTERMOST_LPN_ID
       from WMS_SHIPPING_TRANSACTION_TEMP
       where organization_id    = p_organization_id
       and dock_door_id       = p_dock_door_id
       and dock_appoint_flag  = 'N'
       and delivery_id        is null
         and nvl(direct_ship_flag,'N')  = p_direct_ship_flag
         ORDER BY OUTERMOST_LPN_ID;

  cursor delivery_for_lpn(p_lpn_id NUMBER) is
     select distinct delivery_id
       from WMS_SHIPPING_TRANSACTION_TEMP
       where outermost_lpn_id = p_lpn_id;

  cursor open_deliveries_cur is
     select DISTINCT WSTT.delivery_id
       from WMS_SHIPPING_TRANSACTION_TEMP wstt
       ,wsh_new_deliveries_ob_grp_v wnd
       where wstt.delivery_id = wnd.delivery_id
       AND wnd.status_code ='OP'
       AND WSTT.organization_id    = p_organization_id
       and WSTT.dock_door_id       = p_dock_door_id
       and wstt.dock_appoint_flag  = 'N'
       and nvl(wstt.direct_ship_flag,'N')  = 'Y';

  l_open_deliveries_cur open_deliveries_cur%ROWTYPE;
  k NUMBER:=0;

  l_delivery_id        NUMBER;
  l_delivery_name      VARCHAR2(30);
  l_delivery_detail_id NUMBER;
  l_del_rows           WSH_UTIL_CORE.ID_TAB_TYPE;
  l_delivery_ids       WSH_UTIL_CORE.ID_TAB_TYPE;
  l_open_del_ids       WSH_UTIL_CORE.ID_TAB_TYPE;
  l_new_del_id         WSH_UTIL_CORE.ID_TAB_TYPE;
  l_del_detail_id      WSH_DELIVERY_DETAILS_PUB.ID_TAB_TYPE;
  l_return_Status      VARCHAR2(1);
  l_grouping_rows      WSH_UTIL_CORE.ID_TAB_TYPE;
  l_del_index          NUMBER;
  l_del_count          NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_previous_lpn_id    NUMBER;
  l_outermost_lpn_id   NUMBER;

  --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   x_return_status:= 'S';
   IF (l_debug = 1) THEN
      debug( 'Entering Create_Delivery ' , 'Create_Delivery');
      debug( 'p_outermost_lpn_id : ' || p_outermost_lpn_id , 'Create_Delivery');
      debug( 'p_trip_id          : ' || p_trip_id          , 'Create_Delivery');
      debug( 'p_organization_id  : ' || p_organization_id  , 'Create_Delivery');
      debug( 'p_dock_door_id     : ' || p_dock_door_id     , 'Create_Delivery');
      debug( 'p_direct_ship_flag : ' || p_direct_ship_flag , 'Create_Delivery');
   END IF;
   open delivery_details;
   l_del_index := 1;
   LOOP
      fetch delivery_details into l_delivery_detail_id,l_outermost_lpn_id;
      exit when delivery_details%NOTFOUND;
      IF (l_debug = 1) THEN
         debug( 'l_delivery_detail_id is ' || l_delivery_detail_id,'Create_Delivery');
      END IF;
      BEGIN
         -- Add the following code in case user created delivery manually from
         -- desktop
         select wda.delivery_id, wnd.name
           into l_delivery_id, l_delivery_name
           from wsh_delivery_assignments_v wda, wsh_new_deliveries_ob_grp_v wnd
           where wda.delivery_id = wnd.delivery_id
           and   wda.delivery_detail_id = l_delivery_detail_id;

         update wms_shipping_transaction_temp
           set delivery_id = l_delivery_id,
           delivery_name = l_delivery_name,
           last_update_date =  SYSDATE,
           last_updated_by  =  FND_GLOBAL.USER_ID
           where delivery_detail_id = l_delivery_detail_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               DEBUG('In no data found '||l_previous_lpn_id,'CREATE_DELIVERY');
            END IF;
            IF nvl(l_previous_lpn_id,0) <>l_outermost_lpn_id THEN
               IF l_previous_lpn_id is null THEN
                  l_previous_lpn_id := l_outermost_lpn_id;
               END IF;
               IF (l_debug = 1) THEN
                  debug('Outermost_LPN has changed. Previous LPN id was  '||l_previous_lpn_id,'CREATE_DELIVERY');
                  DEBUG('Outermost LPN id is  '||l_outermost_lpn_id,'CREATE_DELIVERY');
                  DEBUG('tHE VALUE OD DELIVERY_DETAIL_ID IS '||l_delivery_detail_id,'CREATE_DELIVERY');
               END IF;
               l_del_rows(l_del_index) := l_delivery_detail_id;
               l_del_index := l_del_index + 1;
            END IF;
      END;
      l_previous_lpn_id := l_outermost_lpn_id;
   END LOOP;
   close delivery_details;

   -- commit the update for the delivery
   IF p_direct_ship_flag<>'Y' THEN
      commit;
   END IF;

   IF l_del_rows.count >0 THEN
      OPEN open_deliveries_cur;
      LOOP
         FETCH open_deliveries_cur INTO l_open_deliveries_cur;
         EXIT WHEN open_deliveries_cur%notfound;
         l_open_del_ids(open_deliveries_cur%rowcount) :=l_open_deliveries_cur.delivery_id ;
      END LOOP;
      CLOSE open_deliveries_cur;
   END IF;

   if( l_del_rows.COUNT > 0 ) then
      IF (l_debug = 1) THEN
         debug('The number of open deliveries are '||l_open_del_ids.count,'MOB_SHIP');
      END IF;
      FOR i IN 1..l_del_rows.COUNT LOOP
         FOR j IN 1..l_open_del_ids.count LOOP
            l_del_detail_id.DELETE;
            l_del_detail_id(1) := l_del_rows(i);
            IF (l_debug = 1) THEN
               DEBUG('The value of del_row is '||l_del_detail_id(1),'mob_ship');
               DEBUG('The value of del_id is '||l_open_del_ids(j),'mob_ship');
            END IF;
            WSH_DELIVERY_DETAILS_PUB.detail_to_delivery
              (p_api_version    =>1.0
               ,x_return_status  =>l_return_status
               ,x_msg_count      =>l_msg_count
               ,x_msg_data       =>l_msg_data
               ,p_TabOfDelDets   => l_del_detail_id
               ,p_action         =>'ASSIGN'
               ,p_delivery_id    => l_open_del_ids(j));

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               IF (l_debug = 1) THEN
                  DEBUG('Found an open delivery satisfying '||l_open_del_ids(j),'MOB_SHIP');
               END IF;
               EXIT;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF (l_debug = 1) THEN
                  DEBUG('expected error','MOB_SHIP');
               END IF;
               NULL;
             ELSIF l_return_status =FND_API.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               EXIT;
            END IF;
         END LOOP;
         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            x_message := l_msg_data;
            IF (l_debug = 1) THEN
               DEBUG('Failed while assigning the delivery lines to the delivery '||l_del_rows(i)||' - '||l_msg_data,'MOB_SHIP');
            END IF;
            RETURN;
          ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
            k := k+1;
            l_new_del_id(k) :=l_del_rows(i);
         END IF;
      END LOOP;
      IF (l_debug = 1) THEN
         debug('Calling shipping api to create deliveries.','MOB_SHIP');
      END IF;

        -- Call Shipping's public API
        IF  (l_new_del_id.count >0 ) THEN
           IF (l_debug = 1) THEN
              DEBUG('Calling Auto Create Deliveries - ASSIGNMENT UNSUCCESSFUL','mob_ship');
           END IF;

           WSH_DELIVERY_DETAILS_PUB.autocreate_deliveries
             (p_api_version_number    =>1.0
              ,  p_init_msg_list         =>FND_API.G_FALSE
              ,  p_commit                =>FND_API.G_FALSE
              ,  x_return_status         =>l_return_status
              ,  x_msg_count             =>l_msg_count
              ,  x_msg_data              =>l_msg_data
              ,  p_line_rows             =>l_new_del_id
              ,  x_del_rows              =>l_delivery_ids);
         ELSIF l_open_del_ids.count =0 THEN
           IF (l_debug = 1) THEN
              DEBUG('cALLING aUTO CREATE DELIVIERIES -No open deliveries','mob_ship');
           END IF;
           WSH_DELIVERY_DETAILS_PUB.autocreate_deliveries
             (p_api_version_number    =>1.0
              ,  p_init_msg_list         =>FND_API.G_FALSE
              ,  p_commit                =>FND_API.G_FALSE
              ,  x_return_status         =>l_return_status
              ,  x_msg_count             =>l_msg_count
              ,  x_msg_data              =>l_msg_data
              ,  p_line_rows             =>l_del_rows
              ,  x_del_rows              =>l_delivery_ids);
        END IF;

        x_return_status := l_return_status;

        IF( l_return_status = 'W' ) then
           IF (l_debug = 1) THEN
              debug('Warning from creating deliveries API.','MOB_SHIP');
              debug('Warning:'||l_msg_data,'MOB_SHIP');
           END IF;

           x_message := l_msg_data;
         ELSIF  ( l_return_status in ('E','U') ) then
           IF (l_debug = 1) THEN
              debug('Failed from creating deliveries API.','MOB_SHIP');
              debug('Error:'||l_msg_data,'MOB_SHIP');
           END IF;

           x_message := l_msg_data;
           return;
        END IF;

        IF (l_debug = 1) THEN
           debug('Updating the temp table','MOB_SHIP');
        END IF;

        for l_del_count in 1..l_del_rows.COUNT LOOP
           select wda.delivery_id, wnd.name
           into l_delivery_id, l_delivery_name
             from wsh_delivery_assignments_v wda, wsh_new_deliveries_ob_grp_v wnd
             where wda.delivery_id = wnd.delivery_id
             and   wda.delivery_detail_id = l_del_rows(l_del_count);

           update wms_shipping_transaction_temp
             set delivery_id = l_delivery_id,
             delivery_name = l_delivery_name,
             last_update_date =  SYSDATE,
             last_updated_by  =  FND_GLOBAL.USER_ID
             where outermost_lpn_id = (SELECT outermost_lpn_id FROM wms_shipping_transaction_temp
                                       WHERE delivery_detail_id = l_del_rows(l_del_count));
        end loop;
   end if;

   IF (l_debug = 1) THEN
      debug('get the delivery for the current LPN','MOB_SHIP');
   END IF;

   -- get the first delivery for the current lpn
   open delivery_for_lpn(p_outermost_lpn_id);
   fetch delivery_for_lpn into l_delivery_id;
   if  delivery_for_lpn%NOTFOUND then l_delivery_id := -1; end if;
   close delivery_for_lpn;
   x_delivery_id := l_delivery_id;
   IF (l_debug = 1) THEN
      debug('The delivery is '||to_char(l_delivery_id),'MOB_SHIP');
   END IF;

EXCEPTION
   When others then
      IF (l_debug = 1) THEN
         debug('Exception in creating deliveries','MOB_SHIP');
      END IF;

      x_return_status :='U';

END CREATE_DELIVERY;

PROCEDURE GET_LPN_DELIVERY(x_deliveryLOV OUT NOCOPY t_genref,
                           p_trip_id       IN NUMBER,
                             p_organization_id  IN NUMBER,
                             p_dock_door_id  IN NUMBER,
                             p_delivery_name IN VARCHAR2) IS
BEGIN
   if p_trip_id <> 0 then
      OPEN x_deliveryLOV for
        SELECT distinct wstt.delivery_name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
        wnd.waybill,
        INV_SHIPPING_TRANSACTION_PUB.GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
        FROM wsh_new_deliveries wnd,wms_shipping_transaction_temp wstt
        WHERE wnd.delivery_id = wstt.delivery_id
        and wstt.trip_id = p_trip_id
        and wstt.dock_door_id = p_dock_door_id
        and wstt.organization_id = p_organization_id
        and nvl(wstt.direct_ship_flag,'N') = 'N'
        and wstt.delivery_name like (p_delivery_name)
        order by wstt.delivery_name;
    else
      OPEN x_deliveryLOV for
        SELECT distinct wstt.delivery_name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,
        wnd.waybill,
        INV_SHIPPING_TRANSACTION_PUB.GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
        FROM wsh_new_deliveries wnd,wms_shipping_transaction_temp wstt
        WHERE wnd.delivery_id = wstt.delivery_id
        and wstt.dock_appoint_flag = 'N'
        and nvl(wstt.direct_ship_flag,'N') = 'N'
        and wstt.dock_door_id = p_dock_door_id
        and wstt.organization_id = p_organization_id
        and wstt.delivery_name like (p_delivery_name)
        order by wstt.delivery_name;
   end if;
END GET_LPN_DELIVERY;

PROCEDURE update_trip(p_delivery_id IN NUMBER DEFAULT NULL
                      ,p_trip_id    IN NUMBER DEFAULT NULL
                      ,p_ship_method_code IN VARCHAR2
                      ,x_return_status    OUT nocopy VARCHAR2
                      ,x_msg_data         OUT nocopy VARCHAR2
                      ,x_msg_count        OUT nocopy number) IS

  l_trip_id                NUMBER := null;
  l_trip_name              VARCHAR2(30);
  l_trip_info                    WSH_TRIPS_PUB.Trip_Pub_Rec_Type;
BEGIN
   x_return_status := 'S';

   debug('p_delivery_id: ' || p_delivery_id
         || ' p_trip_id: ' || p_trip_id
         || ' p_ship_method_code: ' || p_ship_method_code,'update_trip');

   IF p_delivery_id IS NULL AND p_trip_id IS NULL THEN
      x_return_status := 'E';

      debug('delivery_id and trip_id both null.  Need one of them to update a trip','update_trip');

      RETURN;
   END IF;

   IF p_ship_method_code IS NOT NULL THEN
      IF p_trip_id IS NULL OR
        p_trip_id = 0 THEN
         begin
            SELECT wts.trip_id
              INTO l_trip_id
              FROM wsh_delivery_legs_ob_grp_v wdl,
              wsh_trip_stops_ob_grp_v wts
              WHERE wdl.delivery_id=p_delivery_id
              AND wdl.pick_up_stop_id=wts.stop_id
              AND ROWNUM=1;
         EXCEPTION
            WHEN no_data_found THEN
               debug('Cannot find trip to update','update_trip');

               x_return_status := 'E';
               RETURN;
         END;
       ELSE
         l_trip_id := p_trip_id;
      END IF;

      debug('Trip id to be updated: ' || l_trip_id,'update_trip');
      debug('ship method code: ' || p_ship_method_code,'update_trip');
      debug('Calling WSH_TRIPS_PUB.create_update_trip','update_trip');

      l_trip_info.trip_id                    := l_trip_id;
      l_trip_info.last_update_date           := SYSDATE;
      l_trip_info.last_updated_by            :=FND_GLOBAL.USER_ID;
      l_trip_info.last_update_login          :=FND_GLOBAL.USER_ID;
      l_trip_info.ship_method_code           :=p_ship_method_code;

      WSH_TRIPS_PUB.Create_Update_Trip
        (p_api_version_number        => 1.0
         ,p_init_msg_list            => FND_API.G_TRUE
         ,x_return_status            => x_return_status
         ,x_msg_count                => x_msg_count
         ,x_msg_data                 => x_msg_data
         ,p_action_code              => 'UPDATE'
         ,p_trip_info                => l_trip_info
         ,x_trip_id                  => l_trip_id
         ,x_trip_name                => l_trip_name);

      debug('return status from WSH_TRIPS_PUB.create_update_trip: ' || x_return_status,'update_trip');

      IF x_return_status NOT IN ('S','W') THEN
         debug('Shipping msg count: ' || x_msg_count,'update_trip');
         debug('Shipping error msg: ' || x_msg_data,'update_trip');
       ELSE
         debug('Committing change','update_trip');
         COMMIT;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      debug('Other exceptions raised!','update_trip');
      debug('SQLERRM: ' || SQLERRM,'update_trip');
      x_return_status := 'U';
END update_trip;

--patchset J.  Shipping API cleanup
--previously, this procedure updated shipping table directly
--For Ship Method, this procedure will first determine if the delivery belongs to a trip
--If it does:
--  1.  Determine if ship method = ship method on trip
--  2.  Update trip's ship method if it was null before
--  3.  Return 'W' as return status if trip's ship method different from one passed in
PROCEDURE UPDATE_DELIVERY(p_delivery_id      IN NUMBER,
                          p_gross_weight     IN NUMBER,
                          p_weight_uom       IN VARCHAR2,
                          p_waybill          IN VARCHAR2,
                          p_bol              IN VARCHAR2,
                          p_ship_method_code IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2) IS

  --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_debug number;

  l_delivery_info     wsh_deliveries_pub.delivery_pub_rec_type;
  l_delivery_id       NUMBER;
  l_delivery_name     VARCHAR2(30);

  l_trip_id                NUMBER := null;
  l_trip_ship_method_code  VARCHAR2(30) := null;
  l_trip_name              VARCHAR2(30);
  l_trip_info                    WSH_TRIPS_PUB.Trip_Pub_Rec_Type;

  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_summary_buffer   VARCHAR2(2000);

  l_ignore_for_planning        wsh_delivery_details.ignore_for_planning%TYPE;
  l_tms_interface_flag         wsh_new_deliveries.TMS_INTERFACE_FLAG%TYPE;

CURSOR c_get_otm_flags is
   SELECT ignore_for_planning, tms_interface_flag
     FROM   wsh_new_deliveries_ob_grp_v
     WHERE  delivery_id = p_delivery_id;



BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF l_debug = 1 THEN
      debug('Inside update_delivery','UPDATE_DELIVERY');
   END IF;

   x_return_status := 'S';

   IF p_gross_weight IS NOT NULL then
      l_delivery_info.gross_weight := p_gross_weight;
   END IF;

   IF p_weight_uom IS NOT NULL then
      l_delivery_info.weight_uom_code := p_weight_uom;
   END IF;

   IF p_waybill IS NOT NULL then
      l_delivery_info.waybill := p_waybill;
   END IF;


   /*  G-LOG integration Starts
   *    Cases where G-LOG is installed, and the delivery is planned,
     *    We cannot update the ship method.
     *    For non-G-LOG cases also,
     *    We need not pass the new ship method to this API for an UPDATE,
     *    instead we will pass it to the ship confirm API and that will take care of
     *    updating it at all levels, as the case may be.
     *    BUT, we need to update it at delivery level for LPN Ship, where
     *    API: SHIP_CONFIRM_LPN_DELIVERIES depends on the delivery level shipmenthod
     */

     IF wsh_util_core.gc3_is_installed = 'Y'  THEN
	IF (l_debug = 1) THEN
	   debug('G-Log Changes: G-Log installed', 'update_delivery');
	END IF;

	OPEN c_get_otm_flags;
	FETCH c_get_otm_flags INTO l_ignore_for_planning, l_tms_interface_flag ;

	IF (c_get_otm_flags%NOTFOUND) THEN
	   IF (l_debug = 1) THEN
	      debug('No WDDs found for the delivery created ', 'update_delivery');
	   END IF;
	END IF;

        CLOSE c_get_otm_flags;

     END IF ;
     IF (l_debug = 1) THEN
	debug('l_ignore_for_planning : ' || l_ignore_for_planning, 'update_delivery');
	debug('l_tms_interface_flag  : ' || l_tms_interface_flag, 'update_delivery');
     END IF;

     IF l_ignore_for_planning IS NULL OR  l_ignore_for_planning = 'Y'  THEN
	l_delivery_info.ship_method_code := p_ship_method_code;
	l_delivery_info.ship_method_name := p_ship_method_code;
     END IF;

     IF l_debug = 1 THEN
	debug('l_delivery_info.ship_method_code ' || l_delivery_info.ship_method_code,'UPDATE_DELIVERY');
	debug('l_delivery_info.ship_method_name ' || l_delivery_info.ship_method_name,'UPDATE_DELIVERY');
     END IF;

     /*  G-LOG integration Starts Ends */


   IF p_ship_method_code IS NOT NULL then
      BEGIN

         SELECT wts.trip_id,wt.ship_method_code
           INTO l_trip_id,l_trip_ship_method_code
           FROM wsh_delivery_legs_ob_grp_v wdl,
           wsh_trip_stops_ob_grp_v wts,
           wsh_trips_ob_grp_v wt
           WHERE wdl.delivery_id=p_delivery_id
           AND wdl.pick_up_stop_id=wts.stop_id
           AND wt.trip_id=wts.trip_id
           AND ROWNUM=1;
      EXCEPTION
         WHEN no_data_found THEN
            IF l_debug = 1 THEN
               debug('Delivery does not belong to any trip','UPDATE_DELIVERY');
            END IF;
      END;
   END IF;

   l_delivery_info.delivery_id := p_delivery_id;

   IF (l_debug=1) THEN
      debug('About to call wsh_deliveries_pub.create_update_delivery with'
            || ' gross_weight: '     || l_delivery_info.gross_weight
            || ' waybill     : '     || l_delivery_info.waybill
            || ' ship method code: ' || l_delivery_info.ship_method_code
            || ' weight uom code: '  || l_delivery_info.weight_uom_code
            || ' delivery ID: '      || l_delivery_info.delivery_id, 'UPDATE_DELIVERY');
   END IF;

   wsh_deliveries_pub.create_update_delivery
     (p_api_version_number => 1.0,
      p_init_msg_list      => fnd_api.g_false,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      p_action_code        => 'UPDATE',
      p_delivery_info      => l_delivery_info,
      x_delivery_id        => l_delivery_id,
      x_name               => l_delivery_name);

   IF l_debug = 1 then
      debug('return_status from WSH_DELIVERIES_PUB.create_update_delivery: '
            || x_return_status,'UPDATE_DELIVERY');
   END IF;


   IF x_return_status IN ('E','U') THEN
      --no need to proceed to update trip if update to delivery failed
      RETURN;
    ELSE
      -- commit for each delivery, so that we will not lose any data
      debug('commiting...','UPDATE_DELIVERY');
      commit;
   END IF;

   --delivery belongs to a trip.  see if we can propagate the ship method
   IF l_trip_id IS NOT NULL THEN
      debug('Delivery belongs to trip: ' || l_trip_id
            || '   trip ship method: ' || l_trip_ship_method_code,'UPDATE_DELIVERY');


      IF l_trip_ship_method_code IS NULL THEN
         debug('Calling update_trip','UPDATE_DELIVERY');

         update_trip(p_trip_id => l_trip_id
                     ,p_ship_method_code => p_ship_method_code
                     ,x_return_status => x_return_status
                     ,x_msg_count     => l_msg_count
                     ,x_msg_data      => l_msg_data);

         debug('return status from update_trip: ' || x_return_status,'UPDATE_DELIVERY');

         IF x_return_status NOT IN ('S','W') THEN
            debug('Shipping msg count: ' || l_msg_count,'UPDATE_DELIVERY');
            debug('Shipping error msg: ' || l_msg_data,'UPDATE_DELIVERY');
         END IF;

       ELSIF l_trip_ship_method_code <> p_ship_method_code THEN
         x_return_status := 'W';
         debug('Dlvy belong to trip with different ship method.'
               || '  Returning W so user can be prompted if necessary.','UPDATE_DELIVERY');
      END IF;
   END IF;


EXCEPTION
    WHEN others THEN
    x_return_status := 'E';
END UPDATE_DELIVERY;
--\Shipping API cleanup

PROCEDURE GET_MISSING_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
                           p_organization_id         IN NUMBER,
                           p_dock_door_id            IN NUMBER,
                           p_trip_id                 IN NUMBER,
                           p_lpn                     IN VARCHAR2) IS

BEGIN
   if (p_trip_id <> 0 ) then
      open x_lpn_lov for
        select DISTINCT wlpn.license_plate_number,
        lpn.subinventory_code,
        milk.concatenated_segments,
        wnd.name
        from wms_license_plate_numbers lpn, mtl_item_locations_kfv milk,wsh_trip_stops_ob_grp_v pickup_stop,
        wsh_delivery_legs_ob_grp_v wdl,wsh_delivery_assignments_v wda,wsh_delivery_details_ob_grp_v wdd,
        wsh_delivery_details_ob_grp_v wdd2,wsh_new_deliveries_ob_grp_v wnd,wms_license_plate_numbers wlpn
        where wdd.delivery_detail_id = wda.delivery_detail_id
        and   wdd.released_status = 'Y'
        and   wdd2.delivery_detail_id = wda.parent_delivery_detail_id
        and   wda.delivery_id = wdl.delivery_id
        and   wdl.delivery_id = wnd.delivery_id
        and   wdl.pick_up_stop_id = pickup_stop.stop_id
        and   pickup_stop.trip_id = p_trip_id
        and   lpn.lpn_id  = wdd2.lpn_id
        and   lpn.outermost_lpn_id = wlpn.lpn_id
        and   wlpn.lpn_context <> wms_globals.lpn_loaded_for_shipment
        and   lpn.locator_id = milk.inventory_location_id
        and   lpn.organization_id = milk.organization_id
        and   wlpn.license_plate_number like (p_lpn)
        order by wlpn.license_plate_number;
    else
      open x_lpn_lov for
        select DISTINCT wlpn.license_plate_number,
        lpn.subinventory_code,
        milk.concatenated_segments,
        wnd.name
        from wms_license_plate_numbers lpn, mtl_item_locations_kfv milk,
        wsh_delivery_assignments_v wda,wsh_delivery_details_ob_grp_v wdd,
        wsh_delivery_details_ob_grp_v wdd2,wsh_new_deliveries_ob_grp_v wnd,wms_license_plate_numbers wlpn
        where wdd.delivery_detail_id = wda.delivery_detail_id
        and   wdd.released_status = 'Y'
        and   wdd2.delivery_detail_id = wda.parent_delivery_detail_id
        and   wda.delivery_id in ( select distinct delivery_id
                                   from wms_shipping_transaction_temp
                                   where organization_id = p_organization_id
                                   and dock_appoint_flag = 'N'
                                   and dock_door_id = p_dock_door_id
                                   and delivery_id is not null
                                   UNION
                                   select distinct wdl.delivery_id
                                   from wsh_delivery_legs_ob_grp_v wdl,wms_shipping_transaction_temp wstt,
                                   wsh_trip_stops_ob_grp_v wts
                                   where wdl.pick_up_stop_id = wts.stop_id
                                   and wts.trip_id  = wstt.trip_id
                                   and wstt.dock_door_id = p_dock_door_id
                                   and wstt.organization_id = p_organization_id
                                   and wstt.dock_appoint_flag = 'N' )
                                     and   wda.delivery_id = wnd.delivery_id
                                     and   lpn.lpn_id  = wdd2.lpn_id
                                     and   lpn.outermost_lpn_id = wlpn.lpn_id
                                     and   wlpn.lpn_context <> wms_globals.lpn_loaded_for_shipment
                                     and   lpn.locator_id = milk.inventory_location_id
                                     and   lpn.organization_id = milk.organization_id
                                     and   wlpn.license_plate_number like (p_lpn)
                                     order by wlpn.license_plate_number;
   end if;
END GET_MISSING_LPN_LOV;

PROCEDURE MISSING_LPN_CHECK(x_missing_lpns OUT NOCOPY t_genref,
                            p_trip_id IN NUMBER,
                            p_dock_door_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            x_missing_count OUT NOCOPY NUMBER) IS
   l_count NUMBER;
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      Debug( 'in missing lpn_check', 'MISSING_LPN_CHECK');
      Debug( 'p_trip_id is ' || p_trip_id, 'MISSING_LPN_CHECK');
      Debug( 'p_dock_door_id is ' || p_dock_door_id, 'MISSING_LPN_CHECK');
      Debug( 'p_organization_id is ' || p_organization_id, 'MISSING_LPN_CHECK');
   END IF;
   x_missing_count := 0;
   l_count := 0;
   if (p_trip_id <> 0) then
   BEGIN
      select count(distinct lpn.outermost_lpn_id)
        into l_count
        from wsh_trip_stops_ob_grp_v pickup_stop
            ,wsh_delivery_legs_ob_grp_v wdl
            ,wsh_delivery_assignments_v wda
            ,wsh_delivery_details_ob_grp_v wdd
            ,wsh_delivery_details_ob_grp_v wdd2
            ,wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
            -- 5582189 dherring added table in from clause so that
            -- the status code can be checked
            ,wsh_new_deliveries_ob_grp_v wnd
        Where pickup_stop.trip_id = p_trip_id
        and wdl.pick_up_stop_id = pickup_stop.stop_id
        and wda.delivery_id = wdl.delivery_id
        and wdd.delivery_detail_id = wda.delivery_detail_id
        and wdd.released_status = 'Y'
        and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
        and wdd2.lpn_id = lpn.lpn_id
        and lpn.outermost_lpn_id = wlpn.lpn_id
        AND wdd.organization_id = p_organization_id
        and (    wlpn.lpn_context = wms_container_pvt.lpn_context_picked
             OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
        -- 5582189 dherring changed code to select picked lpns
        and wnd.status_code in ('OP', 'PA');
        --and wlpn.lpn_context <> 9;
      if l_count > 0 then
         x_missing_count := l_count;
      end if;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         open x_missing_lpns FOR select 1 from dual;
         return;
   END;
   open x_missing_lpns FOR
     select wlpn.license_plate_number
            , wlpn.lpn_id
            , wdd.delivery_detail_id
            , lpn.subinventory_code
            , lpn.locator_id
            , milk.concatenated_segments
            , wnd.name
     from     wms_license_plate_numbers lpn
            , mtl_item_locations_kfv milk
            , wsh_trip_stops_ob_grp_v pickup_stop
            , wsh_delivery_legs_ob_grp_v wdl
            , wsh_delivery_assignments_v wda
            , wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_details_ob_grp_v wdd2
            , wsh_new_deliveries_ob_grp_v wnd
            , wms_license_plate_numbers wlpn
     where wdd.delivery_detail_id = wda.delivery_detail_id
     and   wdd.released_status = 'Y'
     and   wdd2.delivery_detail_id = wda.parent_delivery_detail_id
     and   wda.delivery_id = wdl.delivery_id
     and   wdl.delivery_id = wnd.delivery_id
     and   wdl.pick_up_stop_id = pickup_stop.stop_id
     and   pickup_stop.trip_id = p_trip_id
     and   lpn.lpn_id  = wdd2.lpn_id
     and   lpn.outermost_lpn_id = wlpn.lpn_id
     and (    wlpn.lpn_context = wms_container_pvt.lpn_context_picked
             OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
     --and   wlpn.lpn_context <> 9
     -- 5582189 dherring changed code to select picked lpns
     and   wnd.status_code in ('OP', 'PA')
     and   lpn.locator_id = milk.inventory_location_id
     AND   wdd.organization_id = p_organization_id
     and   lpn.organization_id = milk.organization_id;
    else
      BEGIN
         select count(distinct lpn.outermost_lpn_id)
           into l_count
           from wsh_delivery_assignments_v wda
            ,wsh_new_deliveries_ob_grp_v wnd
            ,wsh_delivery_details_ob_grp_v wdd
            ,wsh_delivery_details_ob_grp_v wdd2
            ,wms_license_plate_numbers lpn
            ,wms_license_plate_numbers wlpn
           where
           wdd.delivery_detail_id = wda.delivery_detail_id
           and   wdd.released_status = 'Y'
           and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
           and wda.delivery_id in ( select distinct delivery_id
                                    from wms_shipping_transaction_temp
                                    where organization_id = p_organization_id
                                    and dock_appoint_flag = 'N'
                                    and dock_door_id = p_dock_door_id
                                    and delivery_id is not null
                                    UNION
                                    select distinct wdl.delivery_id
                                    from wsh_delivery_legs_ob_grp_v wdl
                                        ,wms_shipping_transaction_temp wstt
                                        ,wsh_trip_stops_ob_grp_v wts
                                    where wdl.pick_up_stop_id = wts.stop_id
                                    and wts.trip_id  = wstt.trip_id
                                    and wstt.dock_door_id = p_dock_door_id
                                    and wstt.organization_id = p_organization_id
                                    and wstt.dock_appoint_flag = 'N')
                                    and wdd2.lpn_id = lpn.lpn_id
                                    and wlpn.lpn_id = lpn.outermost_lpn_id
                                    AND wdd.organization_id = p_organization_id
                                    and (    wlpn.lpn_context =
                                                  wms_container_pvt.lpn_context_picked
                                         OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
                                    -- 5582189 dherring changed code to select picked lpns
                                    and wda.delivery_id = wnd.delivery_id
                                    and wnd.status_code in ('OP', 'PA');
                                    --and wlpn.lpn_context <> 9;
      if l_count > 0  then
         x_missing_count := l_count;
      end if;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            open x_missing_lpns FOR select 1 from dual;
            return;
      END;


      open x_missing_lpns FOR
        select wlpn.license_plate_number
            ,  wlpn.lpn_id
            , wdd.delivery_detail_id
            , lpn.subinventory_code
            , lpn.locator_id
            , milk.concatenated_segments
            , wnd.name
        from wms_license_plate_numbers lpn
            , mtl_item_locations_kfv milk
            , wsh_delivery_assignments_v wda
            , wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_details_ob_grp_v wdd2
            , wsh_new_deliveries_ob_grp_v wnd
            , wms_license_plate_numbers wlpn
        where wdd.delivery_detail_id = wda.delivery_detail_id
        and   wdd.released_status = 'Y'
        and   wdd2.delivery_detail_id = wda.parent_delivery_detail_id
        and   wda.delivery_id in ( select distinct delivery_id
                                   from wms_shipping_transaction_temp
                                   where organization_id = p_organization_id
                                   and dock_appoint_flag = 'N'
                                   and nvl(direct_ship_flag,'N') = 'N'
                                   and dock_door_id = p_dock_door_id
                                   and delivery_id is not null
                                   UNION
                                   select distinct wdl.delivery_id
                                   from wsh_delivery_legs_ob_grp_v wdl
                                       ,wms_shipping_transaction_temp wstt
                                       ,wsh_trip_stops_ob_grp_v wts
                                   where wdl.pick_up_stop_id = wts.stop_id
                                   and wts.trip_id  = wstt.trip_id
                                   and wstt.dock_door_id = p_dock_door_id
                                   and wstt.organization_id = p_organization_id
                                   and wstt.dock_appoint_flag = 'N'
                                   and nvl(direct_ship_flag,'N') = 'N')
                                   and wda.delivery_id = wnd.delivery_id
                                   and lpn.lpn_id  = wdd2.lpn_id
                                   and lpn.outermost_lpn_id = wlpn.lpn_id
                                   and (    wlpn.lpn_context = wms_container_pvt.lpn_context_picked
                                        OR  wlpn.lpn_context = wms_container_pvt.lpn_loaded_in_stage)
                                   --and wlpn.lpn_context <> 9
                                   -- 5582189 dherring changed code to select picked lpns
                                   and wnd.status_code in ('OP', 'PA')
                                   and lpn.locator_id = milk.inventory_location_id
                                   AND wdd.organization_id = p_organization_id
                                   and lpn.organization_id = milk.organization_id;
   end if;

END MISSING_LPN_CHECK;

PROCEDURE MISSING_ITEM_CHECK( x_missing_item OUT NOCOPY t_genref,
                              p_trip_id IN NUMBER,
                              p_dock_door_id IN NUMBER,
                              p_organization_id IN NUMBER,
                              x_missing_count     OUT NOCOPY NUMBER) IS
    l_count NUMBER;
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      Debug( ' in missing_item_check', 'MISSING_ITEM_CHECK');
      Debug( 'p_trip_id is ' || p_trip_id, 'MISSING_ITEM_CHECK');
      Debug( 'p_dock_door_id is ' || p_dock_door_id, 'MISSING_ITEM_CHECK');
      Debug( 'p_organization_id is ' || p_organization_id, 'MISSING_ITEM_CHECK');
   END IF;
   x_missing_count := 0;
   l_count := 0;

   if( p_trip_id <> 0 ) then
       BEGIN
          select count(*)
            into l_count
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wsh_delivery_legs_ob_grp_v wdl
            , wsh_Trip_stops_ob_grp_v pickup_stop
            , mtl_system_items_kfv msik
            where
            wda.delivery_id = wdl.delivery_id
            AND   wda.delivery_detail_id = wdd.delivery_detail_id
            and   wdl.pick_up_stop_id = pickup_stop.stop_id
            and   pickup_stop.trip_id = p_trip_id
            AND   wdd.inventory_item_id = msik.inventory_item_id
            AND   wdd.organization_id = msik.organization_id
            AND   wdd.organization_id = p_organization_id
            and   wdd.lpn_id is null
            and   ((wda.parent_delivery_detail_id is null
                     AND msik.mtl_transactions_enabled_flag <> 'N')
                     OR wdd.released_status is null
                     OR wdd.released_status NOT IN ('X', 'Y'));
            if l_count > 0 then
               x_missing_count := l_count;
            end if;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             open x_missing_item FOR select 1 from dual;
             return;
       END;
       open x_missing_item FOR
         select wnd.name
            ,wdd.delivery_detail_id
            , wdd.inventory_item_id
            , wdd.requested_quantity
            , msik.concatenated_segments
            , msik.description
         from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , wsh_new_deliveries_ob_grp_v wnd
            , wsh_delivery_legs_ob_grp_v wdl
            , wsh_trip_Stops_ob_grp_v pickup_stop
            , mtl_system_items_kfv msik
         where wnd.delivery_id = wda.delivery_id
         AND   wda.delivery_id = wdl.delivery_id
         AND   wda.delivery_detail_id = wdd.delivery_detail_id
         and   wdl.pick_up_stop_id = pickup_stop.stop_id
         and   pickup_stop.trip_id = p_trip_id
         and   wdd.lpn_id is null
         and   wdd.inventory_item_id = msik.inventory_item_id
         AND wdd.organization_id = p_organization_id
         and   wdd.organization_id = msik.organization_id
         and   ((wda.parent_delivery_detail_id is null
                   AND msik.mtl_transactions_enabled_flag <> 'N')
                  OR wdd.released_status is null
                  OR wdd.released_status NOT IN ('X', 'Y'));
    else
       BEGIN
          select count(*)
            into l_count
            from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , mtl_system_items_kfv msik
            where
            wda.delivery_detail_id = wdd.delivery_detail_id
            and   wda.delivery_id in (select distinct delivery_id
                                      from wms_shipping_transaction_temp
                                      where dock_door_id = p_dock_door_id
                                      and organization_id = p_organization_id
                                      and dock_appoint_flag = 'N'
                                      and nvl(direct_ship_flag,'N') = 'N'
                                      and delivery_id is not null
                                      UNION
                                      select distinct wdl.delivery_id
                                      from wsh_delivery_legs_ob_grp_v wdl
                                          ,wms_shipping_transaction_temp wstt
                                          ,wsh_trip_stops_ob_grp_v wts
                                      where wdl.pick_up_stop_id = wts.stop_id
                                      and wts.trip_id  = wstt.trip_id
                                      and wstt.dock_door_id = p_dock_door_id
                                      and wstt.organization_id = p_organization_id
                                      and wstt.dock_appoint_flag = 'N'
                                      and nvl(direct_ship_flag,'N') = 'N')
                                      and   wdd.lpn_id is NULL
                                      AND   wdd.inventory_item_id = msik.inventory_item_id
                                      AND   wdd.organization_id = msik.organization_id
                                      AND wdd.organization_id = p_organization_id
                                      and   ((wda.parent_delivery_detail_id is null
                                                AND msik.mtl_transactions_enabled_flag <> 'N')
                                                 OR wdd.released_status is null
                                                 OR wdd.released_status NOT IN ('X', 'Y'));
             if l_count >0  then
               x_missing_count := l_count;
             end if;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             open x_missing_item FOR select 1 from dual;
             return;
       END;

        /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
         'MTL_SYSTEM_ITEMS_VL'.*/
       open x_missing_item FOR
         select wnd.name
            ,wdd.delivery_detail_id
            , wdd.inventory_item_id
            , wdd.requested_quantity
            , msiv.concatenated_segments
            , msiv.description
         from wsh_delivery_details_ob_grp_v wdd
            , wsh_delivery_assignments_v wda
            , mtl_system_items_vl msiv
            , wsh_new_deliveries_ob_grp_v wnd
         where wda.delivery_detail_id = wdd.delivery_detail_id
         and   wdd.lpn_id is null
         and   wda.delivery_id in (select distinct delivery_id
                                     from wms_shipping_transaction_temp
                                     where dock_door_id = p_dock_door_id
                                     and organization_id = p_organization_id
                                     and dock_appoint_flag = 'N'
                                     and nvl(direct_ship_flag,'N') = 'N'
                                     and delivery_id is not null
                                     UNION
                                     select distinct wdl.delivery_id
                                     from wsh_delivery_legs_ob_grp_v wdl
                                         ,wms_shipping_transaction_temp wstt
                                         ,wsh_trip_stops_ob_grp_v wts
                                     where wdl.pick_up_stop_id = wts.stop_id
                                     and wts.trip_id  = wstt.trip_id
                                     and wstt.dock_door_id = p_dock_door_id
                                     and wstt.organization_id = p_organization_id
                                     and wstt.dock_appoint_flag = 'N'
                                     and nvl(direct_ship_flag,'N') = 'N')
                                     and   wda.delivery_id = wnd.delivery_id
                                     and   wdd.organization_id = p_organization_id
                                     and   wdd.inventory_item_id = msiv.inventory_item_id
                                     and   wdd.organization_id = msiv.organization_id
                                     AND wdd.organization_id = p_organization_id
                                     and   ((wda.parent_delivery_detail_id IS NULL
                                             AND msiv.mtl_transactions_enabled_flag <> 'N')
                                              OR wdd.released_status is NULL
                                              OR wdd.released_status NOT IN ('X', 'Y'));
   END IF;
END MISSING_ITEM_CHECK;

PROCEDURE SHIP_SET_CHECK( p_trip_id IN NUMBER,
                          p_dock_door_id IN NUMBER,
                          p_organization_id IN NUMBER,
                          x_ship_set      OUT NOCOPY VARCHAR2,
                          x_return_Status OUT NOCOPY VARCHAR2,
                          x_error_msg     OUT NOCOPY VARCHAR2,
                          p_direct_ship_flag IN varchar2 default 'N') IS
    l_ship_set VARCHAR2(2000) := NULL;
    l_ship_set_id   NUMBER;
    l_ship_set_name VARCHAR2(30);
    unshipped_count NUMBER := 0;
    l_source_header_id NUMBER;
    CURSOR ship_set_in_trip(p_trip_id NUMBER)  IS
       SELECT distinct wdd.ship_set_id
       FROM wsh_delivery_details_ob_grp_v wdd,wms_shipping_transaction_temp wstt
       WHERE wdd.delivery_detail_id = wstt.delivery_detail_id
       AND   wdd.ship_set_id is not null
       AND   wstt.organization_id = p_organization_id
       AND   wstt.trip_id = p_trip_id
       AND   wstt.dock_door_id = p_dock_door_id
       AND   nvl(wstt.direct_ship_flag,'N') = 'N';

    CURSOR delivered_ship_set  IS
       SELECT distinct wdd.ship_set_id, wdd.source_header_id
       FROM wsh_delivery_details_ob_grp_v wdd,wms_shipping_transaction_temp wstt
       WHERE wdd.delivery_detail_id = wstt.delivery_detail_id
       AND   wdd.ship_set_id is not null
       AND   wstt.organization_id = p_organization_id
       AND   wstt.dock_appoint_flag = 'N'
       AND   nvl(wstt.direct_ship_flag,'N') = p_direct_ship_flag
       AND   wstt.dock_door_id = p_dock_door_id;

    CURSOR c_unshipped_count (p_ship_set_id NUMBER)
    IS
          SELECT 1
          FROM wsh_delivery_details_ob_grp_v wdd,
               oe_order_lines_all oel
          WHERE oel.ship_set_id = p_ship_set_id
          AND   wdd.source_line_id = oel.line_id
          AND   wdd.source_header_id = oel.header_id
          AND   wdd.ship_set_id = p_ship_set_id
          AND   wdd.shipped_quantity is null;

    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   x_return_status := 'C';
   if (p_trip_id <> 0) THEN
      IF l_debug = 1 THEN
         debug('Check ship set for delivery in trip','SHIP_SET_CHECK');
      END IF;

      OPEN  ship_set_in_trip(p_trip_id);
      loop
         FETCH ship_set_in_trip INTO l_ship_set_id;
         EXIT WHEN ship_set_in_trip%NOTFOUND;

         BEGIN
            OPEN c_unshipped_count(l_ship_set_id);
            FETCH c_unshipped_count INTO unshipped_count;
            CLOSE c_unshipped_count;

        if (unshipped_count >0 ) THEN
           IF l_debug = 1 THEN
              debug('Ship set: ' || l_ship_set_id || ' is broken','SHIP_SET_CHECK');
           END IF;
           select set_name
             into l_ship_set_name
             from oe_sets
             where set_id = l_ship_set_id;
           if (l_ship_set is null) then
              l_ship_set := l_ship_set_name;
            else l_ship_set := l_ship_set ||', '||l_ship_set_name;
           end if;
        end if;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN null;
         END;
      end loop;
      close ship_set_in_trip;
    else -- p_trip_id <> 0
      IF l_debug = 1 THEN
         debug('Query for ship set','SHIP_SET_CHECK');
      END IF;
      OPEN  delivered_ship_set;
      loop
         FETCH delivered_ship_set INTO l_ship_set_id,l_source_header_id;
         EXIT WHEN delivered_ship_set%NOTFOUND;
        BEGIN
/*           SELECT 1
             INTO unshipped_count
             FROM DUAL
             WHERE exists (
                           SELECT 1
                           FROM wsh_delivery_details_ob_grp_v wdd
                           WHERE
                           wdd.source_header_id = l_source_header_id
                           AND   wdd.ship_set_id = l_ship_set_id
                           AND   nvl(wdd.shipped_quantity,wdd.picked_quantity) is null
                           );
*/
            -- Bug DHERRING 5758304 changes the way unshipped lines
            -- are determined for deliveries without a trip.
            -- The code excludes lines with the status:
            -- 'C' Already shipped
            -- 'X' Not Applicable
            -- 'D' Cancelled
            -- Lines already loaded onto the dock door do not raise the
            -- unshipped_count flag.
            -- Only lines within the same SO are considered.
            -- Cases where the ship set is split within the same
            -- delivery will be caught by the missing lpn procedure.
             SELECT count(delivery_detail_id)
             INTO unshipped_count
             FROM wsh_delivery_details wdd
             WHERE wdd.released_status NOT IN ('C','X','D')
             AND NOT EXISTS (select 1
                             FROM wms_shipping_transaction_temp wstt
                             WHERE wstt.delivery_detail_id = wdd.delivery_detail_id)
             AND   wdd.source_header_id = l_source_header_id
             AND   wdd.ship_set_id = l_ship_set_id
             AND   wdd.container_flag <> 'Y'
             AND   wdd.organization_id = p_organization_id;

             if (unshipped_count >0 ) THEN
                IF l_debug = 1 THEN
                   debug('Ship set: ' || l_ship_set_id || ' is broken.','SHIP_SET_CHECK');
                END IF;
               select set_name
                 into l_ship_set_name
                 from oe_sets
                 where set_id = l_ship_set_id;
               if (l_ship_set is null) then
                  l_ship_set := l_ship_set_name;
                else l_ship_set := l_ship_set ||', '||l_ship_set_name;
               end if;
            end if;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN null;
        END;
      end loop;
      close delivered_ship_set;
   end if;

   if l_ship_set is null then
      x_return_status := 'C';
    else
      x_return_status := 'E';
      x_ship_set := l_ship_set;
   end if;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END  SHIP_SET_CHECK;


PROCEDURE PRINT_LABEL(p_del_rows         IN      wsh_util_core.id_tab_type,
                      x_return_status    OUT     NOCOPY VARCHAR2) IS
/*
cursor Delivery_Details(p_delivery_id NUMBER) is
    select wdd.delivery_detail_id
    from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda
    where wda.delivery_id = p_delivery_id
      and wda.delivery_detail_id = wdd.delivery_detail_id
      and wdd.lpn_id is NULL;
*/
l_delivery_detail_id       NUMBER;
l_delivery_details_tab     INV_LABEL.transaction_id_rec_type;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_label_status             varchar2(300);

BEGIN
   x_return_status := 'S';
   IF (p_del_rows.count = 0) THEN return; END IF;
   FOR i IN 1..p_del_rows.count LOOP
      l_delivery_details_tab(i) := p_del_rows(i);
   END LOOP;

   inv_label.print_label
     (x_return_status         => x_return_status
      ,       x_msg_count            => l_msg_count
      ,       x_msg_data             => l_msg_data
      ,       x_label_status          => l_label_status
      ,       p_api_version           => 1.0
      ,       p_print_mode            => 1
      ,       p_business_flow_code    => 21
      ,       p_transaction_id        => l_delivery_details_tab
      );
END PRINT_LABEL;

PROCEDURE SHIP_CONFIRM_ALL(p_delivery_id IN NUMBER,
                          p_organization_id IN NUMBER,
                          p_delivery_name IN VARCHAR2,
                          p_carrier_id IN NUMBER,
                          p_ship_method_code IN VARCHAR2,
                          p_gross_weight IN NUMBER,
                          p_gross_weight_uom IN VARCHAR2,
                          p_bol IN VARCHAR2,
                          p_waybill IN VARCHAR2,
                          p_action_flag IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER) IS
   l_del_rows WSH_UTIL_CORE.ID_TAB_TYPE;
   l_report_set_id NUMBER;

   l_actual_dep_date DATE := SYSDATE;
   l_bol_flag VARCHAR2(1) := 'Y';
   l_return_status VARCHAR2(1);

   l_autocreate_flag VARCHAR2(1);
   l_report_set_name VARCHAR2(80);
   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_debug number;

   l_count NUMBER;
   l_tmp_out NUMBER;
   l_tmp_buffer VARCHAR2(2000);

   --Message related variables
   l_dummy_number NUMBER;
   l_summary VARCHAR2(2000);
   l_msg_count NUMBER;

   --Variables added as part of shipping API cleanup project for patchset J
   l_delivery_info     wsh_deliveries_pub.delivery_pub_rec_type;
   l_msg_data          VARCHAR2(2000);
   l_delivery_id       NUMBER;
   l_delivery_name     VARCHAR2(30);
   l_trip_id           VARCHAR2(30);
   l_trip_name         VARCHAR2(30);

   l_wms_enabled_flag  VARCHAR2(1);
   l_outer_cont_instance_id NUMBER;

   -- code added for bug#8596010
        l_allow_ship_set_break   VARCHAR2(1) := 'N';
-- end of code added for bug#8596010

   l_sc_rule_id NUMBER; -- Bug 8250367
   l_close_trip_flag  VARCHAR2(1) ;
   l_sc_intransit_flag VARCHAR2(1) ;
   l_sc_stage_del_flag VARCHAR2(1) ;
   l_sc_defer_interface_flag VARCHAR2(1) ;

   CURSOR outer_lpn(p_delivery_id number) IS
      SELECT DISTINCT wda.parent_delivery_detail_id inner_lpn_wdd,
        wlpn.outermost_lpn_id outermost_lpn_id
        FROM wsh_delivery_details_ob_grp_v wdd,
        wsh_delivery_assignments_v wda,
        wms_license_plate_numbers wlpn
        WHERE wda.delivery_id = p_delivery_id
        AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
        AND wdd.lpn_id = wlpn.lpn_id;

   -- Bug 8250367
   CURSOR ship_confirm_parameters IS
	SELECT wsp.ship_confirm_rule_id, wscr.stage_del_flag,
	wscr.ac_intransit_flag, wscr.ac_close_trip_flag, wscr.ac_defer_interface_flag
	FROM wsh_shipping_parameters wsp,
        wsh_ship_confirm_rules wscr
	WHERE wsp.organization_id = p_organization_id
	AND wscr.ship_confirm_rule_id = wsp.ship_confirm_rule_id;

BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   l_del_rows(1) := p_delivery_id;

   -- get the document set id
   if( nvl(l_report_set_id, -1) = -1) then
     BEGIN
      select delivery_report_set_id
      into l_report_set_id
      from wsh_shipping_parameters
      where organization_id = p_organization_id;
     EXCEPTION
      when no_data_found then
           BEGIN
               select report_set_id
               into l_report_set_id
               from wsh_report_sets
               where usage_code = 'SHIP_CONFIRM'
               and name = 'Ship Confirm Documents';
           EXCEPTION
                when no_data_found then
                    -- put message in the message stack
                    rollback to ship_confirm;
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                when TOO_MANY_ROWS then
                    rollback to ship_confirm;
                    -- put message in the message stack
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
     END;
   end if;

   --patchet J.  Shipping API cleanup
   UPDATE_DELIVERY(p_delivery_id => p_delivery_id,
                   p_gross_weight => p_gross_weight,
                   p_weight_uom   => p_gross_weight_uom,
                   p_waybill      => p_waybill,
                   p_bol          => p_bol,
                   p_ship_method_code => p_ship_method_code,
                   x_return_status    => l_return_status);

   IF l_return_status NOT IN  ('S','W') THEN
      debug('update_delivery failed with status: '
            || l_return_status, 'SHIP_CONFIRM_ALL');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --\Shipping API cleanup

   --patchset J.  LPN hierarchy
   --Populate Shipping with LPN hierarchy.

   --Release 12: LPN Synchronize
   -- The following code of populating shipping with LPN hierarchy
   -- is not necessary because LPN hierarchy is in sync between WMS and WSH
   -- Removed the call to lpn_hiearchy_actions


    --Bug 8250367
    OPEN ship_confirm_parameters;
    FETCH ship_confirm_parameters INTO l_sc_rule_id, l_sc_stage_del_flag,
    l_sc_intransit_flag, l_close_trip_flag, l_sc_defer_interface_flag;

    IF ship_confirm_parameters%NOTFOUND THEN
      IF l_debug = 1 THEN
        debug ('setting hard coded values as ship confirm rule is not present','SHIP_CONFIRM_ALL');
      END IF;
      l_close_trip_flag := 'Y' ;
      l_sc_intransit_flag := 'Y' ;
      l_sc_stage_del_flag := 'Y' ;
      l_sc_defer_interface_flag := 'N' ;
    END IF;
    CLOSE ship_confirm_parameters;

    IF l_debug = 1 THEN
       debug('l_sc_rule_id: ' || l_sc_rule_id,'SHIP_CONFIRM_ALL');
       debug('l_close_trip_flag: ' || l_close_trip_flag,'SHIP_CONFIRM_ALL');
       debug('l_sc_intransit_flag: ' || l_sc_intransit_flag,'SHIP_CONFIRM_ALL');
       debug('l_sc_stage_del_flag: ' || l_sc_stage_del_flag,'SHIP_CONFIRM_ALL');
       debug('l_sc_defer_interface_flag: ' || l_sc_defer_interface_flag,'SHIP_CONFIRM_ALL');
    END IF;


   IF (l_debug = 1) THEN
      debug('About to call wsh_deliveries_pub.delivery_action',
            'SHIP_CONFIRM_ALL');
      debug('delivery_id : ' || p_delivery_id,'SHIP_CONFIRM_ALL');
   END IF;
   --patchset J.  Shipping API cleanup


       --  code added for bug#8596010
         wms_shipping_transaction_pub.g_allow_ship_set_break := l_allow_ship_set_break;
         IF l_debug = 1 THEN
            debug('l_allow_ship_set_break: ' || l_allow_ship_set_break,'SHIP_CONFIRM_ALL');
         END IF;
       -- End of code added for bug#8596010


   wsh_deliveries_pub.delivery_action
     (p_api_version_number      => 1.0,
      p_init_msg_list           => G_TRUE,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      p_action_code             => 'CONFIRM',
      p_delivery_id             => p_delivery_id,
      p_sc_action_flag          => p_action_flag,
      p_sc_intransit_flag       => l_sc_intransit_flag, --Bug 8250367
      p_sc_close_trip_flag      => l_close_trip_flag,
      p_sc_create_bol_flag      => l_bol_flag,  -- BUG 5158964
      p_sc_stage_del_flag       => l_sc_stage_del_flag,
      p_sc_trip_ship_method     => p_ship_method_code,
      p_sc_actual_dep_date      => l_actual_dep_date,
      p_sc_report_set_id        => l_report_set_id,
      p_sc_defer_interface_flag => l_sc_defer_interface_flag,
      x_trip_id                 => l_trip_id,
      x_trip_name               => l_trip_name);
   --\Shipping API cleanup

   IF l_debug = 1 THEN
      debug('wsh_deliveries_pub.delivery_action finished with status: '
            || l_return_status,'SHIP_CONFIRM_ALL');
   END IF;

   if( l_return_status not in ('S', 'W') ) then
      IF (l_debug = 1) THEN
         debug('l_return_status is ' || l_return_status, 'Ship_Confirm');
      END IF;
      rollback;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    else
      x_return_status := l_return_status;
      print_label(l_del_rows, l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         debug('print_label failed','ship_confirm_all');
         FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
         FND_MSG_PUB.ADD;
         x_return_status := 'W';
      END IF;
   end if;

   process_mobile_msg;
   x_msg_count := fnd_msg_pub.count_msg;
   x_msg_data := '';
   FOR i IN 1..x_msg_count LOOP
      fnd_msg_pub.get(p_encoded=>'F'
                      ,p_msg_index      => i
                      ,p_data   => l_msg_data
                      ,p_msg_index_out => l_dummy_number);
      x_msg_data := x_msg_data || l_msg_data;
   END LOOP;
   debug('Actual message pass back to java: ' || x_msg_data,'SHIP_CONFIRM_ALL');
   debug('Msg count passed back: ' || x_msg_count,'SHIP_CONFIRM_ALL');

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      x_return_status := l_return_status;

      --DHERRING Bug#5651219. Fix starts
      x_msg_count := FND_MSG_PUB.Count_msg;
      FOR i in 1..x_msg_count LOOP
        FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE, p_msg_index => i, p_data=> l_tmp_buffer,
                              p_msg_index_out => l_tmp_out);
         x_msg_data:=x_msg_data ||'|'|| l_tmp_buffer;
      END LOOP;

      IF (l_debug = 1) THEN
        debug('inside EXCEPTION, x_msg_count is ' || x_msg_count, 'SHIP_CONFIRM_ALL');
        debug('inside EXCEPTION, x_msg_data is ' || x_msg_data, 'SHIP_CONFIRM_ALL');
      END IF;

     /* commented DHERRING Bug#5651219
      wsh_util_core.get_messages
        (p_init_msg_list => 'Y',
         x_summary       => l_summary,
         x_details       => l_msg_data,
	x_count         => l_msg_count); */

	--DHERRING Bug#5651219.Fix Ends

      IF l_debug = 1 THEN
         debug('SHIP_CONFIRM_ALL raised exception with summary: '
               || l_summary, 'SHIP_CONFIRM_ALL');
         debug('SHIP_CONFIRM_ALL raised exception with messages: '
               || l_msg_data, 'SHIP_CONFIRM_ALL');
         debug('SHIP_CONFIRM_ALL raised exception with msg_count: '
               || l_msg_count, 'SHIP_CONFIRM_ALL');
      END IF;
      IF ship_confirm_parameters%isopen THEN
         CLOSE ship_confirm_parameters;
      END IF;

   WHEN OTHERS THEN
      IF l_debug = 1 THEN
         debug('Others exception raised!','SHIP_CONFIRM_ALL');
         debug(SQLERRM,'SHIP_CONFIRM_ALL');
      END IF;
      IF ship_confirm_parameters%isopen THEN
         CLOSE ship_confirm_parameters;
      END IF;
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END SHIP_CONFIRM_ALL;

PROCEDURE SHIP_CONFIRM(p_delivery_id IN NUMBER,
                       p_organization_id IN NUMBER,
                       p_delivery_name IN VARCHAR2,
                       p_carrier_id IN NUMBER,
                       p_ship_method_code IN VARCHAR2,
                       p_gross_weight IN NUMBER,
                       p_gross_weight_uom IN VARCHAR2,
                       p_bol IN VARCHAR2,
                       p_waybill IN VARCHAR2,
                       p_action_flag IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER) IS

   --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   -- call ship confirm
   WMS_SHIPPING_TRANSACTION_PUB.ship_confirm_all
     (p_delivery_id,
      p_organization_id,
      p_delivery_name,
      p_carrier_id,
      p_ship_method_code,
      p_gross_weight,
      p_gross_weight_uom,
      p_bol,
      p_waybill,
      p_action_flag,
      x_return_status,
      x_msg_data,
      x_msg_count);
   if( x_return_status not in  ('S','W') ) THEN
      IF (l_debug = 1) THEN
         debug('error from confirm_delivery', 'Ship_Confirm');
         debug('return_status is ' || x_return_status, 'Ship_Confirm');
      END IF;
   end if;

END SHIP_CONFIRM;

PROCEDURE SHIP_CONFIRM_LPN_DELIVERIES(x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT NOCOPY NUMBER,
                                      p_trip_stop_id  IN NUMBER,
                                      p_trip_id IN NUMBER,
                                      p_dock_door_id IN NUMBER,
                                      p_organization_id IN NUMBER,
                                      p_verify_only IN VARCHAR2,
                                      p_close_trip_flag IN VARCHAR2 DEFAULT 'N',
                                      p_allow_ship_set_break IN VARCHAR2 DEFAULT 'N') IS
  cursor Deliveries_in_trip is
     select distinct wstt.delivery_id, wnd.ship_method_code
       from wms_shipping_transaction_temp wstt,wsh_new_deliveries_ob_grp_v wnd
       where wstt.trip_id = p_trip_id
       and wstt.dock_door_id = p_dock_door_id
       and wstt.organization_id = p_organization_id
       and nvl(wstt.direct_ship_flag,'N') = 'N'
       AND wstt.delivery_id = wnd.delivery_id;

  cursor Deliveries is
     select distinct wstt.delivery_id,wnd.ship_method_code
       from wms_shipping_transaction_temp wstt,wsh_new_deliveries_ob_grp_v wnd
       where wstt.dock_appoint_flag = 'N'
       and nvl(wstt.direct_ship_flag,'N') = 'N'
       and wstt.dock_door_id = p_dock_door_id
       and wstt.organization_id = p_organization_id
       AND wstt.delivery_id = wnd.delivery_id;

  cursor outermost_lpn_for_trip is
     select distinct outermost_lpn_id
       from wms_shipping_transaction_temp
       where trip_id = p_trip_id
       and nvl(direct_ship_flag,'N') = 'N'
       and organization_id = p_organization_id;

  cursor outermost_lpn_for_dock is
     select distinct outermost_lpn_id
       from wms_shipping_transaction_temp
       where organization_id = p_organization_id
       and  dock_door_id = p_dock_door_id
       and dock_appoint_flag = 'N'
       and nvl(direct_ship_flag,'N') = 'N';

  CURSOR nested_children_lpn_cursor(l_outermost_lpn_id NUMBER) is
     SELECT lpn_id
       FROM WMS_LICENSE_PLATE_NUMBERS
       START WITH lpn_id = l_outermost_lpn_id
       CONNECT BY parent_lpn_id = PRIOR lpn_id;

  cursor Deliveries_without_trip is
     select distinct wstt.delivery_id,wnd.ship_method_code
       from wms_shipping_transaction_temp wstt,wsh_new_deliveries_ob_grp_v wnd
       where wstt.dock_appoint_flag = 'N'
       and nvl(wstt.direct_ship_flag,'N') = 'N'
       and wstt.dock_door_id = p_dock_door_id
       and wstt.trip_id is null
       and wstt.organization_id = p_organization_id
        AND wstt.delivery_id = wnd.delivery_id ;

  cursor Deliveries_with_trip is
     select distinct wstt.delivery_id,wnd.ship_method_code
       from wms_shipping_transaction_temp wstt, wsh_new_deliveries_ob_grp_v wnd
       where wstt.dock_appoint_flag = 'N'
       and nvl(wstt.direct_ship_flag,'N') = 'N'
       and wstt.dock_door_id = p_dock_door_id
       and wstt.trip_id is not null
         and wstt.organization_id = p_organization_id
         AND wstt.delivery_id = wnd.delivery_id;

  cursor pick_up_stops is
     select distinct wdl.pick_up_stop_id,wts.stop_sequence_number
       from wsh_delivery_legs_ob_grp_v wdl,wms_shipping_transaction_temp wstt,
       wsh_trip_stops_ob_grp_v wts
       where wdl.pick_up_stop_id = wts.stop_id
       and wts.trip_id  = wstt.trip_id
       and wstt.dock_door_id = p_dock_door_id
       and wstt.organization_id = p_organization_id
       and wstt.dock_appoint_flag = 'N'
       and nvl(direct_ship_flag,'N') = 'N'
       AND wts.status_code = 'OP'
       ORDER BY wts.stop_sequence_number asc;

  cursor drop_off_stops(p_dock_appoint_flag varchar2) is
     select distinct wdl.drop_off_stop_id
       from wsh_delivery_legs wdl,wms_shipping_transaction_temp wstt,
       wsh_trip_stops wts
       where wdl.drop_off_stop_id = wts.stop_id
       and wts.trip_id  = wstt.trip_id
       and wstt.dock_door_id = p_dock_door_id
       and wstt.organization_id = p_organization_id
       and wstt.dock_appoint_flag = p_dock_appoint_flag
       and nvl(direct_ship_flag,'N') = 'N';


  CURSOR c_get_trip_ship_method(l_delivery_id NUMBER)IS
     SELECT wts.trip_id,
       wt.ship_method_code
       FROM   wsh_delivery_legs_ob_grp_v wdl,
       wsh_trip_stops_ob_grp_v wts,
       wsh_trips_ob_grp_v wt
       WHERE  wdl.delivery_id     = l_delivery_id
       AND    wdl.pick_up_stop_id = wts.stop_id
       AND    wt.trip_id          = wts.trip_id
       AND    ROWNUM              = 1;

  CURSOR C_Ship_Confirm_Parameters IS
     SELECT wsp.ship_confirm_rule_id, wscr.ac_intransit_flag, wscr.ac_close_trip_flag, wscr.ac_defer_interface_flag
     FROM wsh_shipping_parameters wsp, wsh_ship_confirm_rules wscr
     WHERE wsp.organization_id = p_organization_id
     AND wscr.ship_confirm_rule_id = wsp.ship_confirm_rule_id;

 CURSOR Check_Last_Trip (l_delivery_id NUMBER) IS
    SELECT wdt1.trip_id
    FROM wsh_delivery_trips_v wdt1,
         wsh_new_deliveries wnd
    WHERE  wdt1.delivery_id <> l_delivery_id
    AND  wdt1.delivery_id = wnd.delivery_id
    AND  wnd.status_code = 'OP'
    AND  wdt1.trip_id IN (SELECT wdt2.trip_id
                            FROM wsh_delivery_trips_v wdt2
                           WHERE wdt2.delivery_id = l_delivery_id)
    AND  rownum = 1;

  l_delivery_id   NUMBER;
  l_del_index   NUMBER;
  l_del_rows WSH_UTIL_CORE.ID_TAB_TYPE;
  l_stop_rows WSH_UTIL_CORE.ID_TAB_TYPE;
  l_drop_off_stops wsh_util_core.id_tab_type;
  l_report_set_id NUMBER;

  l_sc_rule_id NUMBER;
  l_intransit_flag VARCHAR2(1);
  l_close_trip_flag VARCHAR2(1);
  l_defer_interface_flag VARCHAR2(1);
  l_sc_intransit_flag VARCHAR2(1);
  l_sc_close_trip_flag VARCHAR2(1);
  l_sc_defer_interface_flag VARCHAR2(1);
  l_open_delivery_id NUMBER;

  TYPE ship_method_tbl_type IS TABLE OF wsh_new_deliveries.ship_method_code%TYPE INDEX BY BINARY_INTEGER;
  l_ship_method_tbl ship_method_tbl_type;
  l_ship_method VARCHAR2(30);

  l_actual_dep_date DATE := SYSDATE;
  l_bol_flag VARCHAR2(1) := 'Y';
  l_return_status VARCHAR2(1);
  l_num_warnings NUMBER := 0;

  l_autocreate_flag VARCHAR2(1);
  l_report_set_name VARCHAR2(80);
  l_org_id   NUMBER;
  l_outermost_lpn_id   NUMBER;
  l_pick_up_stop_id   NUMBER;
  l_drop_off_stop_id NUMBER;
  l_stop_sequence_number NUMBER;
  l_pick_up_count NUMBER := 0;

  --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_debug number;

  l_count NUMBER;
  l_tmp_out NUMBER;
  l_tmp_buffer VARCHAR2(2000);

  l_msg_count NUMBER;
  l_dummy_number NUMBER;
  l_summary VARCHAR2(2000);

  --variables added for Shipping API cleanup for patchset J
  l_trip_id           VARCHAR2(30);
  l_trip_name         VARCHAR2(30);
  l_msg_data          VARCHAR2(2000);

  l_trip_trip_id            NUMBER;
  l_trip_ship_method_code   wsh_trips_ob_grp_v.ship_method_code%type    := null;

BEGIN
   savepoint ship_confirm;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF l_debug = 1 THEN
       debug('p_verify_only : ' || p_verify_only
         || ' , p_trip_id : ' || p_trip_id
         || ' , p_trip_stop_id : '|| p_trip_stop_id
         || ' , p_dock_door_id : '|| p_dock_door_id
         || ' , p_organization_id : '|| p_organization_id, 'LPN_SHIP');
      debug('Parameter p_close_trip_flag: ' || p_close_trip_flag,'LPN_SHIP');

      debug('Parameter p_allow_ship_set_break: ' || p_allow_ship_set_break,'LPN_SHIP');
   END IF;
   wms_shipping_transaction_pub.g_allow_ship_set_break := p_allow_ship_set_break;

   IF p_close_trip_flag = 'N' THEN
      OPEN C_Ship_Confirm_Parameters;
      FETCH C_Ship_Confirm_Parameters INTO l_sc_rule_id, l_intransit_flag, l_close_trip_flag, l_defer_interface_flag;
      IF l_debug=1 then
         debug('Ship Confirm Rule ID : '||l_sc_rule_id
             ||' , Intransit Flag : '||l_intransit_flag
             ||' , Close Trip Flag : '||l_close_trip_flag
             ||' , Defer Interface Flag : '||l_defer_interface_flag ,'ship_confirm_lpn_deliveries');
      END IF;
      CLOSE C_Ship_Confirm_Parameters;
   END IF;

   l_del_index := 1;
   if (p_trip_id <> 0 ) THEN
      IF l_debug = 1 then
         debug('p_trip_id: ' || p_trip_id,'ship_confirm_lpn_deliveries');
      END IF;

      open Deliveries_in_trip;
      LOOP
         fetch Deliveries_in_trip into l_delivery_id,l_ship_method;
         EXIT WHEN Deliveries_in_trip%NOTFOUND;

         l_del_rows(l_del_index) := l_delivery_id;
         l_ship_method_tbl(l_del_index) := l_ship_method;

         IF l_debug = 1 then
            debug('delivery id: ' || l_delivery_id || ' ship_method_code: '
                   || l_ship_method,'ship_confirm_lpn_deliveries');
         END IF;

         l_del_index := l_del_index +1;
      END LOOP;
      close Deliveries_in_trip;
    ELSE -- p_trip_id <> 0

      IF l_debug = 1 THEN
        debug('no trip id','ship_confirm_lpn_deliveries');
      END IF;

      open Deliveries;
      LOOP
         fetch Deliveries into l_delivery_id,l_ship_method;
         EXIT WHEN Deliveries%NOTFOUND;

         l_del_rows(l_del_index) := l_delivery_id;
         l_ship_method_tbl(l_del_index) := l_ship_method;

         IF l_debug = 1 then
            debug('delivery id: ' || l_delivery_id || ' ship_method_code: '
                   || l_ship_method,'ship_confirm_lpn_deliveries');
         END IF;

         l_del_index := l_del_index +1;
      END LOOP;
      close Deliveries;
   end if;

   -- get the document set id
   select organization_id
     into l_org_id
     from wsh_new_deliveries_ob_grp_v
     where delivery_id = l_delivery_id;

   if( nvl(l_report_set_id, -1) = -1) then
     BEGIN
        select delivery_report_set_id
          into l_report_set_id
          from wsh_shipping_parameters
          where organization_id = l_org_id;
     EXCEPTION
        when no_data_found then
           BEGIN
              select report_set_id
                into l_report_set_id
                from wsh_report_sets
                where usage_code = 'SHIP_CONFIRM'
                and name = 'Ship Confirm Documents';
           EXCEPTION
              when no_data_found then
                 -- put message in the message stack
                 rollback to ship_confirm;
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              when TOO_MANY_ROWS then
                 rollback to ship_confirm;
                 -- put message in the message stack
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
     END;
   end if;

   IF (l_debug = 1) THEN
      debug('calling wsh_new_delivery_actions.confirm_delivery', 'Ship_Confirm');
   END IF;

   if p_verify_only = 'Y' then
      x_return_status := 'S';
      -- delete the records from the temp table after ship confirm
      if (p_trip_id <> 0 ) then
         -- update the lpn context back to resides in inventory
         open  outermost_lpn_for_trip;
         LOOP
            fetch outermost_lpn_for_trip into l_outermost_lpn_id;
            exit when outermost_lpn_for_trip%NOTFOUND;
            UPDATE WMS_LICENSE_PLATE_NUMBERS
              SET lpn_context                  =  11, --WMS_Container_PUB.LPN_CONTEXT_INV,
              last_update_date             =  SYSDATE,
              last_updated_by              =  FND_GLOBAL.USER_ID
              where lpn_id = l_outermost_lpn_id;

            -- update the lpn context for all children lpns
            FOR l_lpn_id IN nested_children_lpn_cursor(l_outermost_lpn_id) LOOP
               UPDATE WMS_LICENSE_PLATE_NUMBERS
                 SET lpn_context                  =  11, --WMS_Container_PUB.LPN_CONTEXT_INV,
                 last_update_date             =  SYSDATE,
                 last_updated_by              =  FND_GLOBAL.USER_ID
                 where lpn_id = l_lpn_id.lpn_id;
            END LOOP;
         END LOOP;
         close outermost_lpn_for_trip;

         -- delete the record from the temp table

         -- bug 2760062

         DELETE FROM mtl_material_transactions_temp
           WHERE wms_task_type = 7
           AND organization_id = p_organization_id
           AND content_lpn_id IN
           (SELECT outermost_lpn_id
            FROM wms_shipping_transaction_temp
            WHERE organization_id = p_organization_id
            AND    trip_id = p_trip_id);

         delete from wms_shipping_transaction_temp where trip_id = p_trip_id
           and organization_id = p_organization_id;
       ELSE -- p_trip_id <> 0

         -- update the lpn context back to resides in inventory
         open  outermost_lpn_for_dock;
         LOOP
            fetch outermost_lpn_for_dock into l_outermost_lpn_id;
            exit when outermost_lpn_for_dock%NOTFOUND;
            UPDATE WMS_LICENSE_PLATE_NUMBERS
              SET lpn_context                  =  11, --WMS_Container_PUB.LPN_CONTEXT_INV,
              last_update_date             =  SYSDATE,
              last_updated_by              =  FND_GLOBAL.USER_ID
              where lpn_id = l_outermost_lpn_id;

            -- update the lpn context for all children lpns
            FOR l_lpn_id IN nested_children_lpn_cursor(l_outermost_lpn_id) LOOP
               UPDATE WMS_LICENSE_PLATE_NUMBERS
                 SET lpn_context                  =  11, --WMS_Container_PUB.LPN_CONTEXT_INV,
                 last_update_date             =  SYSDATE,
                 last_updated_by              =  FND_GLOBAL.USER_ID
                 where lpn_id = l_lpn_id.lpn_id;
            END LOOP;
         END LOOP;
         close outermost_lpn_for_dock;
         -- delete the record from the temp table

         -- bug 2760062

         DELETE FROM mtl_material_transactions_temp
           WHERE wms_task_type = 7
           AND organization_id = p_organization_id
           AND content_lpn_id IN
           (SELECT outermost_lpn_id
            FROM wms_shipping_transaction_temp
            WHERE organization_id = p_organization_id
            AND  dock_door_id = p_dock_door_id
            AND dock_appoint_flag = 'N'
            AND Nvl(direct_ship_flag,'N') = 'N');

         delete from wms_shipping_transaction_temp
           where organization_id = p_organization_id
           and  dock_door_id = p_dock_door_id
           and dock_appoint_flag = 'N'
           and nvl(direct_ship_flag,'N') = 'N';
      end if;

      -- print the shipping labels
      print_label(l_del_rows, l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         debug('print_label failed','ship_confirm_lpn_deliveries');
         FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
         FND_MSG_PUB.ADD;
         l_num_warnings := l_num_warnings + 1;
      END IF;
    ELSE --corresponding if - p_verify_only = 'Y'
      if p_trip_stop_id =0 then
         -- First ship out the deliveries without trip
         l_del_rows.DELETE;
         l_ship_method_tbl.DELETE;

         open Deliveries_without_trip;
         l_del_index := 1;
         LOOP
            fetch Deliveries_without_trip into l_delivery_id,l_ship_method;
            EXIT WHEN Deliveries_without_trip%NOTFOUND;
            l_del_rows(l_del_index) := l_delivery_id;
            l_ship_method_tbl(l_del_index) := l_ship_method;
            l_del_index := l_del_index +1;
         END LOOP;
         close Deliveries_without_trip;

         --patchset J.  Shipping API cleanup
         FOR i IN 1..l_del_rows.COUNT LOOP
            IF l_debug = 1 THEN
               debug('About to call wsh_deliveries_pub.delivery_action'
                     || ' with delivery_id : ' || l_del_rows(i) || ' ship_method_code: '
                     || l_ship_method_tbl(i),'SHIP_CONFIRM_LPN_DELIVERIES');
            END IF;



	    /*
	    * GLOG-OTM Integration ..that we must pass ship method from Trip, if one
	    * exists, to Delivery_action API */

	    OPEN c_get_trip_ship_method(l_del_rows(i) );
	    FETCH c_get_trip_ship_method INTO l_trip_trip_id, l_trip_ship_method_code;

	    IF (c_get_trip_ship_method%NOTFOUND) THEN
	       l_trip_ship_method_code := l_ship_method_tbl(i);
	       IF l_debug = 1 THEN
		  debug('Delivery does not belong to any trip','SHIP_CONFIRM_LPN_DELIVERIES');
	       END IF;
	    END IF;

	    CLOSE c_get_trip_ship_method;


	    IF l_debug = 1 THEN
	       debug('2:l_del_rows(i) : '              || l_del_rows(i)
		     || ':l_trip_trip_id : '          || l_trip_trip_id
		     || ':l_trip_ship_method_code : ' || l_trip_ship_method_code,
		     'SHIP_CONFIRM_LPN_DELIVERIES');
	    END if;

	    --  If the Ship Confirm Rule id is present, use the values from the ship confirm rule
            IF l_sc_rule_id IS NOT NULL THEN
               l_sc_intransit_flag := l_intransit_flag;
               l_sc_close_trip_flag := l_close_trip_flag;
               l_sc_defer_interface_flag := l_defer_interface_flag;
            ELSE
               l_sc_intransit_flag := 'Y';
               l_sc_close_trip_flag := 'Y';
               l_sc_defer_interface_flag := 'N';
            END IF;

	    wsh_deliveries_pub.delivery_action
		(p_api_version_number      => 1.0,
		 p_init_msg_list           => fnd_api.g_true,
		 x_return_status           => l_return_status,
		 x_msg_count               => l_msg_count,
		 x_msg_data                => l_msg_data,
		 p_action_code             => 'CONFIRM',
		 p_delivery_id             => l_del_rows(i),
		 p_sc_action_flag          => 'A',
                 p_sc_intransit_flag       => l_sc_intransit_flag,
                 p_sc_close_trip_flag      => l_sc_close_trip_flag,
                 p_sc_create_bol_flag      => l_bol_flag,    --Bug 5158964
		 p_sc_stage_del_flag       => 'Y',
		 p_sc_trip_ship_method     => l_trip_ship_method_code, --l_ship_method_tbl(i) for GlogInt
		 p_sc_actual_dep_date      => l_actual_dep_date,
		 p_sc_report_set_id        => l_report_set_id,
                 p_sc_defer_interface_flag => l_sc_defer_interface_flag,
		 x_trip_id                 => l_trip_id,
		 x_trip_name               => l_trip_name);

	      IF (l_return_status NOT IN ('S','W')) THEN
		 IF l_debug = 1 THEN
		    debug('wsh_deliveries_pub.delivery_action failed '
                        || 'with status ' || l_return_status,'SHIP_CONFIRM_LPN_DELIVERIES');
                 END IF;

                 ROLLBACK;
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;

                 ELSIF l_return_status = 'W' THEN
                    l_num_warnings := l_num_warnings + 1;

            END IF;
         END LOOP;
         --\Shipping API cleanup

         -- bug 3805194
         print_label(l_del_rows, l_return_status);
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('print_label failed','SHIP_CONFIRM_LPN_DELIVERIES');
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
            FND_MSG_PUB.ADD;

            l_num_warnings := l_num_warnings + 1;
         END IF;

         -- Then ship out the deliveries with trip
         l_del_rows.DELETE;
         l_ship_method_tbl.DELETE;

         open Deliveries_with_trip;
         l_del_index := 1;
         LOOP
            fetch Deliveries_with_trip into l_delivery_id,l_ship_method;
            EXIT WHEN Deliveries_with_trip%NOTFOUND;
    	    IF l_intransit_flag = 'Y' AND l_open_delivery_id IS NULL THEN
	       OPEN check_last_trip(l_delivery_id);
	       FETCH check_last_trip INTO l_open_delivery_id;
               IF l_debug=1 then
	          debug('Found atleast one open delivery in trip : '||l_open_delivery_id,'ship_confirm_lpn_deliveries');
	       END IF;
	       CLOSE check_last_trip;
	    END IF;
            l_del_rows(l_del_index) := l_delivery_id;
            l_ship_method_tbl(l_del_index) := l_ship_method;
            l_del_index := l_del_index +1;
         END LOOP;
         close Deliveries_with_trip;

         if (l_del_index >1) then
            -- fix bug 2175253, get the pick_up_stop before confirm_delivery
       	    IF p_close_trip_flag = 'Y' OR (l_intransit_flag = 'Y' AND l_open_delivery_id IS NULL) THEN
 	       OPEN pick_up_stops;
                l_del_index := 1;
                LOOP
                  fetch pick_up_stops into l_pick_up_stop_id,l_stop_sequence_number;
                  EXIT WHEN pick_up_stops%NOTFOUND;
                  IF l_debug = 1 THEN
                     debug('pick_up_stop_id: ' || l_pick_up_stop_id || ' stop_sequence_number: ' || l_stop_sequence_number,'LPN_SHIP');
                  END IF;
                  l_stop_rows(l_del_index) := l_pick_up_stop_id;
                  l_del_index := l_del_index +1;
                END LOOP;
                CLOSE pick_up_stops;
 	    END IF;

            IF l_debug = 1 THEN
               debug('Number of pickup stops: ' || l_stop_rows.COUNT,'LPN_SHIP');
            END IF;
            --User specified to have entire trip close
            --Get the drop off stops on the trip as well
            IF (p_close_trip_flag = 'Y' OR (l_close_trip_flag = 'Y' AND l_open_delivery_id IS NULL))
             AND l_stop_rows.COUNT >= 1 THEN
               IF l_debug = 1 then
                  debug('Getting drop-off stops to close','LPN_SHIP');
               END IF;
               OPEN drop_off_stops(p_dock_appoint_flag => 'N');
               l_del_index := 1;
               l_drop_off_stops.DELETE;
               LOOP
                  FETCH drop_off_stops INTO l_drop_off_stop_id;
                  EXIT WHEN drop_off_stops%notfound;
                  l_drop_off_stops(l_del_index) := l_drop_off_stop_id;
                  l_del_index := l_del_index + 1;
               END LOOP;
               IF l_debug = 1 THEN
                  debug('Finished getting drop-off stops','LPN_SHIP');
                  debug('Total drop-off stops for current dock door: ' || l_drop_off_stops.COUNT,'LPN_SHIP');
               END IF;
            END IF;

            --patchset J.  Shipping API cleanup
            FOR i IN 1..l_del_rows.COUNT LOOP
               IF l_debug = 1 THEN
                  debug('Shipping out delivereis that have trip.','SHIP_CONFIRM_LPN_DELIVERIES');
                  debug('About to call wsh_deliveries_pub.delivery_action'
                        || ' with delivery_id : ' || l_del_rows(i) || ' and ship_method_code: '
                        || l_ship_method_tbl(i),'SHIP_CONFIRM_LPN_DELIVERIES');
               END IF;



	       /*
	       * GLOG-OTM Integration ..that we must pass ship method from Trip, if one
		 * exists, to Delivery_action API */

	       OPEN c_get_trip_ship_method(l_del_rows(i) );
	       FETCH c_get_trip_ship_method INTO l_trip_trip_id, l_trip_ship_method_code;

	       IF (c_get_trip_ship_method%NOTFOUND) THEN
		  l_trip_ship_method_code := NULL;
		  IF l_debug = 1 THEN
		     debug('Delivery does not belong to any trip','SHIP_CONFIRM_LPN_DELIVERIES');
		  END IF;
	       END IF;
	       CLOSE c_get_trip_ship_method;

	       IF l_debug = 1 THEN
		  debug('3:l_del_rows(i) : '              || l_del_rows(i)
			|| ':l_trip_trip_id : '           || l_trip_trip_id
			|| ':l_trip_ship_method_code: '   || l_trip_ship_method_code,
			'SHIP_CONFIRM_LPN_DELIVERIES');
	       END IF;


	       wsh_deliveries_pub.delivery_action
		   (p_api_version_number      => 1.0,
		    p_init_msg_list           => fnd_api.g_false,
		    x_return_status           => l_return_status,
		    x_msg_count               => l_msg_count,
		    x_msg_data                => l_msg_data,
		    p_action_code             => 'CONFIRM',
		    p_delivery_id             => l_del_rows(i),
		    p_sc_action_flag          => 'A',
		    p_sc_intransit_flag       => 'N',
		    p_sc_close_trip_flag      => 'N',
		    p_sc_create_bol_flag      => l_bol_flag,  --Bug 5158964
		    p_sc_stage_del_flag       => 'N',
		    p_sc_trip_ship_method     =>  l_trip_ship_method_code, --l_ship_method_tbl(i) for GlogInt
		    p_sc_actual_dep_date      => l_actual_dep_date,
		    p_sc_report_set_id        => l_report_set_id,
		    p_sc_defer_interface_flag => 'Y',
		    x_trip_id                 => l_trip_id,
		    x_trip_name               => l_trip_name);

		 IF (l_return_status NOT IN ('S','W')) THEN
		    IF l_debug = 1 THEN
		       debug('wsh_deliveries_pub.delivery_action failed '
			     || 'with status ' || l_return_status,'SHIP_CONFIRM_LPN_DELIVERIES');
		    END IF;

		    ROLLBACK;
		    raise FND_API.G_EXC_UNEXPECTED_ERROR;

		    ELSIF l_return_status = 'W' THEN
        	l_num_warnings := l_num_warnings + 1;

		 END IF;
            END LOOP;
            --\Shipping API cleanup

            --Bug 5947804 Loop through all the trip stops
 	    IF (p_close_trip_flag = 'Y' OR (l_intransit_flag = 'Y' AND l_open_delivery_id IS NULL))
             AND (l_stop_rows.COUNT >= 1) THEN
		FOR i IN 1..l_stop_rows.COUNT LOOP
			IF l_debug = 1 THEN
			   debug('Calling wsh_trip_stops_pub.stop_action','LPN_SHIP');
			   debug('l_stop_rows(i) ' || l_stop_rows(i),'LPN_SHIP');
			END IF;

			    --patchset J.  Shipping API cleanup
			    wsh_trip_stops_pub.stop_action
			      (p_api_version_number => 1.0,
			       p_init_msg_list      => G_TRUE,
			       x_return_status      => l_return_status,
			       x_msg_count          => l_msg_count,
			       x_msg_data           => l_msg_data,
			       p_action_code        => 'CLOSE',
			       --p_stop_id            => l_stop_rows(1),
			       p_stop_id            => l_stop_rows(i),     --Bug 5947804
			       p_actual_date        => sysdate,
			       p_defer_interface_flag => NVL(l_defer_interface_flag,'N'));

			    IF (l_debug = 1) THEN
			       debug('return status:'||l_return_status, 'LPN_SHIP');
			    END IF;
			    if( l_return_status not in ('S', 'W') ) then
			       IF (l_debug = 1) THEN
				  debug('l_return_status is ' || l_return_status, 'Ship_Confirm');
			       END IF;
			       rollback;
			       raise FND_API.G_EXC_UNEXPECTED_ERROR;

			       ELSIF l_return_status = 'W' THEN
             		l_num_warnings := l_num_warnings + 1;

			    end if;

			END LOOP;
		END IF;
            --\Shipping API cleanup

            --Close the drop-off stops as well
            IF (p_close_trip_flag = 'Y' OR (l_close_trip_flag = 'Y' AND l_open_delivery_id IS NULL))
             AND (l_drop_off_stops.COUNT >= 1) THEN
               IF l_debug = 1 THEN
                  debug('Calling change status for the drop-off stops','LPN_SHIP');
               END IF;

              FOR i IN 1..l_drop_off_stops.COUNT LOOP
                 wsh_trip_stops_pub.stop_action
                   (p_api_version_number => 1.0,
                    p_init_msg_list      => G_TRUE,
                    x_return_status      => l_return_status,
                    x_msg_count          => l_msg_count,
                    x_msg_data           => l_msg_data,
                    p_action_code        => 'CLOSE',
                    p_stop_id            => l_drop_off_stops(i),
                    p_actual_date        => sysdate,
                    p_defer_interface_flag => 'Y');
                 IF l_debug = 1 THEN
                    debug('wsh_trip_stops_actions.change_status return status: ' || l_return_status,'LPN_SHIP');
                    END IF;

                    IF l_return_status NOT IN ('S','W') THEN
                    	IF l_debug = 1 THEN
                       debug('Could not close the drop-off stops.  Let the transaction go through','LPN_SHIP');
                    END IF;

                    ELSIF l_return_status = 'W' THEN
                       l_num_warnings := l_num_warnings + 1;

                 END IF;
              END LOOP;
            END IF;

         end if;  --corresponding if: l_del_index > 1 (there are deliveries with trip)

         -- delete the records from the temp table after ship confirm

         -- bug 2760062

         DELETE FROM mtl_material_transactions_temp
           WHERE wms_task_type = 7
           AND organization_id = p_organization_id
           AND content_lpn_id IN
           (SELECT outermost_lpn_id
            FROM wms_shipping_transaction_temp
            WHERE organization_id = p_organization_id
            AND  dock_door_id = p_dock_door_id
            AND dock_appoint_flag = 'N'
            AND Nvl(direct_ship_flag,'N') = 'N');

         delete from wms_shipping_transaction_temp
           where organization_id = p_organization_id
           and  dock_door_id = p_dock_door_id
           and dock_appoint_flag = 'N'
           and nvl(direct_ship_flag,'N') = 'N';

         print_label(l_del_rows, l_return_status);
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('print_label failed','SHIP_CONFIRM_LPN_DELIVERIES');
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
            FND_MSG_PUB.ADD;

            l_num_warnings := l_num_warnings + 1;
         END IF;

       else  -- close the trip stop corresponding if: p_trip_stop_id = 0
        IF l_debug = 1 THEN
           debug('p_trip_id: ' || p_trip_id, 'LPN_SHIP');
        END IF;

        IF p_close_trip_flag = 'Y' OR l_close_trip_flag = 'Y' THEN
           IF l_debug = 1 THEN
              debug('User wants entire trip close.  Getting drop-off stops','LPN_SHIP');
           END IF;

           SELECT COUNT(DISTINCT wdl.pick_up_stop_id)
             INTO l_pick_up_count
             FROM wsh_trip_stops wts, wsh_delivery_legs wdl
             where wts.stop_id = wdl.pick_up_stop_id
             and wts.trip_id = p_trip_id;

           debug('l_pick_up_count: ' || l_pick_up_count,'LPN_SHIP');
           IF l_pick_up_count = 1 then
              OPEN drop_off_stops(p_dock_appoint_flag => 'Y');
              l_del_index := 1;
              l_drop_off_stops.DELETE;
              LOOP
                 FETCH drop_off_stops INTO l_drop_off_stop_id;
                 EXIT WHEN drop_off_stops%notfound;
                 l_drop_off_stops(l_del_index) := l_drop_off_stop_id;
                 l_del_index := l_del_index + 1;
              END LOOP;

              IF l_debug = 1 THEN
                 debug('Finished getting drop-off stops','LPN_SHIP');
                 debug('Total drop-off stops for current dock door: ' || l_drop_off_stops.COUNT,'LPN_SHIP');
              END IF;
            ELSE
                    debug('Trip contains multiple pick-up stops','LPN_SHIP');
           END IF;
        END IF;

         FOR i IN 1..l_del_rows.COUNT LOOP
            IF l_debug = 1 THEN
               debug('p_trip_stop_id is : ' || p_trip_stop_id, 'SHIP_CONFIRM_LPN_DELIVEREIS');
               debug('About to call wsh_deliveries_pub.delivery_action'
                     || ' with delivery_id : ' || l_del_rows(i) || ' and ship_method_code: '
                     || l_ship_method_tbl(i),'SHIP_CONFIRM_LPN_DELIVERIES');
            END IF;


	    /*
	    * GLOG-OTM Integration ..that we must pass ship method from Trip, if one
	      * exists, to Delivery_action API */


	      OPEN c_get_trip_ship_method(l_del_rows(i) );
	      FETCH c_get_trip_ship_method INTO l_trip_trip_id, l_trip_ship_method_code;

	      IF (c_get_trip_ship_method%NOTFOUND) THEN
		 l_trip_ship_method_code := l_ship_method_tbl(i);
		 IF l_debug = 1 THEN
		    debug('Delivery does not belong to any trip','SHIP_CONFIRM_LPN_DELIVERIES');
		 END IF;
	      END IF;
	      CLOSE c_get_trip_ship_method;


	      IF l_debug = 1 THEN
		 debug('4:l_del_rows(i) : '              || l_del_rows(i)
		       || ':l_trip_trip_id : '           || l_trip_trip_id
		       || ':l_trip_ship_method_code: '   || l_trip_ship_method_code,
		       'SHIP_CONFIRM_LPN_DELIVERIES');
	      END IF;


	      wsh_deliveries_pub.delivery_action
		(p_api_version_number      => 1.0,
		 p_init_msg_list           => fnd_api.g_false,
		 x_return_status           => l_return_status,
		 x_msg_count               => l_msg_count,
		 x_msg_data                => l_msg_data,
		 p_action_code             => 'CONFIRM',
		 p_delivery_id             => l_del_rows(i),
		 p_sc_action_flag          => 'A',
		 p_sc_intransit_flag       => 'N',
		 p_sc_close_trip_flag      => 'N',
		 p_sc_create_bol_flag      => l_bol_flag, --Bug 5158964
		 p_sc_stage_del_flag       => 'N',
		 p_sc_trip_ship_method     =>  l_trip_ship_method_code, --l_ship_method_tbl(i) for GlogInt
		 p_sc_actual_dep_date      => l_actual_dep_date,
		 p_sc_report_set_id        => l_report_set_id,
		 p_sc_defer_interface_flag => 'Y',
		 x_trip_id                 => l_trip_id,
		 x_trip_name               => l_trip_name);

	      IF (l_return_status NOT IN ('S','W')) THEN
		 IF l_debug = 1 THEN
		    debug('wsh_deliveries_pub.delivery_action failed '
			  || 'with status ' || l_return_status,'SHIP_CONFIRM_LPN_DELIVERIES');
		 END IF;

		 ROLLBACK;
		 raise FND_API.G_EXC_UNEXPECTED_ERROR;

		 ELSIF l_return_status = 'W' THEN
                  l_num_warnings := l_num_warnings + 1;

	      END IF;
         END LOOP;

         IF (l_debug = 1) THEN
            debug('Calling change_status','LPN_SHIP');
         END IF;

         l_stop_rows(1) := p_trip_stop_id;
         --patchset J.  Shipping API cleanup
         IF p_close_trip_flag = 'Y' OR l_intransit_flag = 'Y' THEN
             wsh_trip_stops_pub.stop_action
               (p_api_version_number => 1.0,
                p_init_msg_list      => G_TRUE,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_action_code        => 'CLOSE',
                p_stop_id            => p_trip_stop_id,
                p_actual_date        => sysdate,
                p_defer_interface_flag =>NVL(l_defer_interface_flag,'N'));
             --patchset J.  Shipping API cleanup

            IF (l_debug = 1) THEN
               debug('return status:'||l_return_status, 'LPN_SHIP');
            END IF;
            if( l_return_status not in ('S', 'W') ) then
                IF (l_debug = 1) THEN
                   debug('l_return_status is ' || l_return_status, 'Ship_Confirm');
                END IF;
                rollback;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSE -- l_return_status

                IF l_return_status = 'W' THEN
                   l_num_warnings := l_num_warnings + 1;
               END IF;

             IF (p_close_trip_flag = 'Y' OR l_close_trip_flag = 'Y') AND l_pick_up_count = 1 THEN
               IF l_debug = 1 THEN
                  debug('Call Shipping to close drop-off stops','LPN_SHIP');
               END IF;

               FOR i IN 1..l_drop_off_stops.COUNT LOOP
                  wsh_trip_stops_pub.stop_action
                    (p_api_version_number => 1.0,
                     p_init_msg_list      => G_TRUE,
                     x_return_status      => l_return_status,
                     x_msg_count          => l_msg_count,
                     x_msg_data           => l_msg_data,
                     p_action_code        => 'CLOSE',
                     p_stop_id            => l_drop_off_stops(i),
                     p_actual_date        => sysdate,
                     p_defer_interface_flag =>'Y');

               IF l_debug = 1 THEN
                  debug('wsh_trip_stops_actions.change_status return status: ' || l_return_status,'LPN_SHIP');
                END IF;
                  IF l_return_status NOT IN ('S','W') THEN
                  	IF l_debug = 1 THEN
                     debug('Could not close the drop-off stops.  Let the transaction go through','LPN_SHIP');
                  END IF;

                  ELSIF l_return_status = 'W' THEN
                       l_num_warnings := l_num_warnings + 1;

               END IF;

               END LOOP;
            END IF;
          END IF;

        -- delete the records from the temp table after ship confirm
            if (p_trip_id <> 0 ) THEN

               -- bug 2760062

               DELETE FROM mtl_material_transactions_temp
                 WHERE wms_task_type = 7
                 AND organization_id = p_organization_id
                 AND content_lpn_id IN
                 (SELECT outermost_lpn_id
                  FROM wms_shipping_transaction_temp
                  WHERE trip_id = p_trip_id
                  AND organization_id = p_organization_id
                  AND Nvl(direct_ship_flag,'N') = 'N');

               delete from wms_shipping_transaction_temp where trip_id = p_trip_id
                 and organization_id = p_organization_id
                 and nvl(direct_ship_flag,'N') = 'N';
             ELSE --correspndong if: p_trip_id <> 0

               -- bug 2760062

               DELETE FROM mtl_material_transactions_temp
                 WHERE wms_task_type = 7
                 AND organization_id = p_organization_id
                 AND content_lpn_id IN
                 (SELECT outermost_lpn_id
                  FROM wms_shipping_transaction_temp
                  WHERE organization_id = p_organization_id
                  AND  dock_door_id = p_dock_door_id
                  AND dock_appoint_flag = 'N'
                  AND Nvl(direct_ship_flag,'N') = 'N');

               delete from wms_shipping_transaction_temp
                 where organization_id = p_organization_id
                 and  dock_door_id = p_dock_door_id
                 and dock_appoint_flag = 'N'
                 and nvl(direct_ship_flag,'N') = 'N';
            end if;

            -- print the shipping labels
            print_label(l_del_rows, l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               debug('print_label failed','SHIP_CONFIRM_LPN_DELIVERIES');
               FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
               FND_MSG_PUB.ADD;

               l_num_warnings := l_num_warnings + 1;
            END IF;
         end if; -- p_trip_id <> 0
      end if; --l_return_status in ('S','W')
   end if;

	--If last return status is 'S' but there was a warning encountered before, setting x_return_status to 'W'
      IF ((x_return_status = 'S') AND (l_num_warnings > 0)) THEN
         x_return_status := 'W';
      END IF;

   process_mobile_msg;
   x_msg_count := fnd_msg_pub.count_msg;
   x_msg_data := '';
   FOR i IN 1..x_msg_count LOOP
      fnd_msg_pub.get(p_encoded=>'F'
                      ,p_msg_index      => i
                      ,p_data   => l_msg_data
                      ,p_msg_index_out => l_dummy_number);
      IF (l_debug = 1) THEN
             debug('Message ('|| i ||') : '|| l_msg_data,'SHIP_CONFIRM_LPN_DELIVERIES');
      END IF;
      IF length(x_msg_data || ' ' || l_msg_data) < 2000 THEN
           x_msg_data := x_msg_data || ' ' || l_msg_data;
      END IF;
   END LOOP;
   debug('Actual message pass back to java: ' || x_msg_data,'SHIP_CONFIRM_LPN_DELIVERIES');
   debug('Msg count passed back: ' || x_msg_count,'SHIP_CONFIRM_LPN_DELIVERIES');

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      debug('Unexpected error raised: ' || SQLERRM, 'SHIP_CONFIRM_LPN_DELIVERIES');
      x_return_status := l_return_status;

      --DHERRING Bug#5651219. Fix starts
      x_msg_count := FND_MSG_PUB.Count_msg;
      FOR i in 1..x_msg_count LOOP
        FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE, p_msg_index => i, p_data=> l_tmp_buffer,
                              p_msg_index_out => l_tmp_out);
          x_msg_data:=x_msg_data ||'|'|| l_tmp_buffer;
      END LOOP;

      IF (l_debug = 1) THEN
         debug('inside EXCEPTION, l_msg_count is ' || x_msg_count, 'SHIP_CONFIRM_LPN_DELIVERIES');
         debug('inside EXCEPTION, x_msg_data is ' || x_msg_data, 'SHIP_CONFIRM_LPN_DELIVERIES');
      END IF;
      /*  commented for DHERRING Bug#5651219
      wsh_util_core.get_messages
        (p_init_msg_list => 'Y',
         x_summary       => l_msg_data,
         x_details       => l_summary,
	x_count         => l_msg_count);*/
	--DHERRING Bug#5651219. Fix Ends

	debug('SHIP_CONFIRM_LPN_DELIVERIES raised exception with summary: '
            || l_summary, 'SHIP_CONFIRM_LPN_DELIVERIES');
      debug('SHIP_CONFIRM_LPN_DELIVERIES raised exception with messages: '
            || l_msg_data, 'SHIP_CONFIRM_LPN_DELIVERIES');
      debug('SHIP_CONFIRM_LPN_DELIVERIES raised exception with msg_count: '
            || l_msg_count, 'SHIP_CONFIRM_LPN_DELIVERIES');
    WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF l_debug = 1 THEN
          debug('Other exception raised: ' || SQLERRM, 'SHIP_CONFIRM_LPN_DELIVERIES');
       END IF;
END SHIP_CONFIRM_LPN_DELIVERIES;

procedure get_serial_number_for_so(
        x_serial_lov out NOCOPY t_genref,
        p_inventory_item_id IN NUMBER,
        p_organization_id   IN NUMBER,
        p_subinventory_code IN VARCHAR2,
        p_locator_id        IN NUMBER,
        p_revision          IN VARCHAR2,
        p_lot_number        IN VARCHAR2,
        p_serial_number     IN VARCHAR2) IS
BEGIN
   open x_serial_lov for
     select serial_number, current_subinventory_code, current_locator_id, lot_number
     from mtl_serial_numbers
     where inventory_item_id = p_inventory_item_id
     and current_organization_id = p_organization_id
     and (group_mark_id is null or group_mark_id = -1)
       and ((nvl(current_subinventory_code,'@@@') = nvl(p_subinventory_code,'@@@')
             and nvl(current_locator_id,-1) = nvl(p_locator_id,-1)
             and nvl(lot_number,'@@@') = nvl(p_lot_number,'@@@')
             and nvl(revision,'@@@') = nvl(p_revision,'@@@')
             and current_status = 3)
            or current_status = 1)
       and serial_number like (p_serial_number)
       order by lpad(serial_number,20);
END get_serial_number_for_so;

PROCEDURE insert_serial_numbers
  (x_status OUT NOCOPY VARCHAR2,
   p_fm_serial_number  IN VARCHAR2,
   p_to_serial_number  IN VARCHAR2,
   p_transaction_Temp_id IN NUMBER) IS
      l_status VARCHAR2(1) := 'S';
      l_fm_serial_number VARCHAR2(30) := p_fm_serial_number;
      l_to_serial_number VARCHAR2(30) := p_to_serial_number;
      l_serial_prefix    VARCHAR2(30);
      l_user NUMBER;
      l_login_id NUMBER;
BEGIN

   l_user := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   l_serial_prefix := rtrim(l_fm_serial_number, '0123456789');

   insert into mtl_serial_numbers_temp
     (
      transaction_Temp_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_By,
      last_update_login,
      fm_serial_number,
      to_serial_number,
      serial_prefix
      ) values
     (
      p_transaction_temp_id,
      sysdate,
      l_user,
      sysdate,
      l_user,
      l_login_id,
      l_fm_serial_number,
      l_to_serial_number,
      l_serial_prefix
      );

   x_status := l_status;
EXCEPTION
   when others then
      x_status := 'E';
END insert_Serial_Numbers;



procedure wms_installed_status(x_status OUT NOCOPY VARCHAR2) is
   l_wms_application_id constant number := 385;
   l_status     Varchar2(10);
   l_industry   varchar2(10);
   l_return_val boolean;
begin

   l_return_val := fnd_installation.get(
                                        appl_id         => l_wms_application_id,
                                        dep_appl_id     => l_wms_application_id,
                                        status          => l_status,
                                        industry        => l_industry);
   if( l_return_val = TRUE ) then
      x_status := l_status;
    else
      x_status := 'ERROR';
   end if;
end wms_installed_status;

procedure GET_SERIAL_STATUS_CODE(x_serial_status_id OUT NOCOPY NUMBER,
                                 x_serial_status_code OUT NOCOPY VARCHAR2,
                                 p_organization_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER) IS
   l_serial_status_id NUMBER;
   l_serial_status_code VARCHAR2(10);
   l_serial_status_enabled VARCHAR2(1);
begin
   select nvl(msik.serial_status_enabled,'N'), nvl(msik.default_Serial_status_id, -1), mst.status_code
     into l_serial_status_enabled, l_serial_status_id, l_serial_status_code
     from mtl_system_items_kfv msik, mtl_material_statuses_vl mst
     where msik.organization_id = p_organization_id
     and   msik.inventory_item_id = p_inventory_item_id
     and   msik.default_serial_status_id = mst.status_id(+);

   if( l_serial_status_enabled = 'N' ) then
      x_serial_status_id := -1;
      x_serial_status_code := 'NULL';
    else
      x_serial_status_id := l_serial_status_id;
      if( l_serial_status_id = -1 ) then
         x_serial_status_code := 'NULL';
       else
         x_serial_status_code := l_serial_status_code;
      end if;
   end if;
end get_serial_status_code;

--patchset J.  Shipping API cleanup
--Calling procedure/function should get the message stack
--This will only return a status
PROCEDURE UNASSIGN_DELIVERY_LINE(
                                 p_delivery_detail_id IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 p_delivery_id IN NUMBER DEFAULT NULL,
                                 p_commit_flag IN VARCHAR2 DEFAULT fnd_api.g_true) IS
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;

    /* Bug: 5585359: 10/09/06 Start*/
    l_action_prms        wsh_interface_ext_grp.del_action_parameters_rectype;
    l_delivery_id_tab    wsh_util_core.id_tab_type;
    l_delivery_out_rec   wsh_interface_ext_grp.del_action_out_rec_type;
    l_planned_flag       VARCHAR2(1);
    /* Bug: 5585359: 10/09/06 - End*/

    l_delivery_details   wsh_delivery_details_pub.id_tab_type;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   l_delivery_details(1) := p_delivery_detail_id;

   /* Bug: 5585359: 10/09/06 */
   l_delivery_id_tab(1)  := p_delivery_id;

   IF l_debug = 1 THEN
      debug('Calling WSH_DELIVERY_DETAILS_PUB.detail_to_delivery ', 'UNASSIGN_DELIVERY_LINE');
      debug('delivery_detail_id : ' || p_delivery_detail_id, 'UNASSIGN_DELIVERY_LINE');
      debug('delivery_id : ' || p_delivery_id, 'UNASSIGN_DELIVERY_LINE');
   END IF;
   -- {{ Test a case where delivery exist before ship confirm }}


    /* Bug: 5585359: 10/09/06 - Start*/

   IF l_delivery_id_tab(1) is NOT NULL
   THEN
      SELECT PLANNED_FLAG
      INTO   L_PLANNED_FLAG
      FROM   wsh_new_deliveries
      WHERE  delivery_id = l_delivery_id_tab(1);
   ELSE

   -- {{ Test a case where delivery does not exist before ship confirm, to see,}}
   -- {{ if this will return no_data_found?  }}

      -- The following sql is required as it is not possible
      -- to use the unfirm shipping api without the delivery id
      -- being known.

      SELECT delivery_id
      INTO   l_delivery_id_tab(1)
      FROM   wsh_delivery_assignments
      WHERE  delivery_detail_id = l_delivery_details(1);

      BEGIN
      SELECT wnd.planned_flag
      INTO   l_planned_flag
      FROM   wsh_new_deliveries wnd,
             wsh_delivery_details wdd,
             wsh_delivery_assignments wda
      WHERE  wdd.delivery_detail_id = l_delivery_details(1)
      AND    wda.delivery_detail_id = wdd.delivery_detail_id
      AND    wda.delivery_id        = wnd.delivery_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          IF l_debug = 1 THEN
              debug('Calling WSH_DELIVERY_DETAILS_PUB.detail_to_delivery ', 'UNASSIGN_DELIVERY_LINE');
          END IF;
          null; -- It is OK
      END;
   END IF;
   IF l_debug = 1 THEN
      debug('l_planned_flag: ' || l_planned_flag, 'UNASSIGN_DELIVERY_LINE');
   END IF;
   IF l_planned_flag = 'Y' THEN
      l_action_prms.caller := 'WMS';
      l_action_prms.action_code := 'UNPLAN';

      IF l_debug = 1 THEN
         DEBUG('Unfirm delivery for unassignment','UNASSIGN_DELIVERY_LINE');
      END IF;
      wsh_interface_ext_grp.delivery_action
           (p_api_version_number     => 1.0,
            p_init_msg_list          => fnd_api.g_false,
            p_commit                 => fnd_api.g_false,
            p_action_prms            => l_action_prms,
            p_delivery_id_tab        => l_delivery_id_tab,
            x_delivery_out_rec       => l_delivery_out_rec,
            x_return_status          => x_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

      IF x_return_status IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN
         IF l_debug = 1 THEN
            debug('Unfirming delivery failed!','UNASSIGN_DELIVERY_LINE');
            debug('msg_data: ' || l_msg_data,'UNASSIGN_DELIVERY_LINE');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   IF l_debug = 1 THEN
      debug('Unfirmed the Delivery !','UNASSIGN_DELIVERY_LINE');
   END IF;
    /* Bug: 5585359: 10/09/06 - End*/

   WSH_DELIVERY_DETAILS_PUB.detail_to_delivery
     (p_api_version   => 1.0,
      p_init_msg_list => G_FALSE,
      p_commit        => p_commit_flag,
      x_return_status => x_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      p_tabofdeldets  => l_delivery_details,
      p_action        => 'UNASSIGN');

   IF l_debug = 1 THEN
      debug('WSH_DELIVERY_DETAILS_PUB.detail_to_delivery '
            || 'return status: ' || x_return_status
            , 'UNASSIGN_DELIVERY_LINE');

      IF x_return_status <> 'S' THEN
         debug('msg_count : ' || l_msg_count
               || ' msg_data : ' || l_msg_data
               , 'UNASSIGN_DELIVERY_LINE');
      END IF;
   END IF;

   /* Bug: 5585359: 10/09/06 - Start*/

   l_action_prms.caller := 'WMS';
   l_action_prms.action_code := 'PLAN';
   IF l_debug = 1 THEN
      DEBUG('firm delivery after unassignment','UNASSIGN_DELIVERY_LINE');
   END IF;
   wsh_interface_ext_grp.delivery_action
        (p_api_version_number     => 1.0,
         p_init_msg_list          => fnd_api.g_false,
         p_commit                 => p_commit_flag,
         p_action_prms            => l_action_prms,
         p_delivery_id_tab        => l_delivery_id_tab,
         x_delivery_out_rec       => l_delivery_out_rec,
         x_return_status          => x_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data);

   IF l_debug = 1 THEN
      debug('firm delivery after unassignment status := '
            || 'return status: ' || x_return_status
            , 'UNASSIGN_DELIVERY_LINE');

      IF x_return_status <> 'S' THEN
         debug('msg_count : ' || l_msg_count
               || ' msg_data : ' || l_msg_data
               , 'UNASSIGN_DELIVERY_LINE');
      END IF;
   END IF;

   /* Bug: 5585359: 10/09/06 - End*/

END UNASSIGN_DELIVERY_LINE;
--\Shipping API cleanup

-- Update the subinventory and locator for the delivery detail lines
-- within an LPN.
-- Added for LPN consolidation from different staging lanes

PROCEDURE update_wdd_loc_by_lpn
  (x_return_status OUT NOCOPY VARCHAR2,
   p_lpn_id NUMBER,
   p_subinventory_code VARCHAR2,
   p_locator_id NUMBER)
  IS
     l_delivery_detail_id NUMBER;
     l_oe_order_header_id NUMBER;
     l_oe_order_line_id NUMBER;
     l_released_status VARCHAR2(1);
     l_organization_id NUMBER;

     l_shipping_attr_tab  WSH_INTERFACE.ChangedAttributeTabType;
     l_wdd_counter NUMBER := 1;

     l_progress VARCHAR2(10);
     l_return_status VARCHAR2(1);

     CURSOR cur_delivery_details
       IS
          SELECT wdd.delivery_detail_id,
            ol.header_id,
            ol.line_id,
            wdd.released_status,
            mol.organization_id
            FROM wsh_delivery_details_ob_grp_v wdd,
            wsh_delivery_assignments_v wda,
            wsh_delivery_details_ob_grp_v wdd2,
            wms_license_plate_numbers lpn,
            mtl_txn_request_lines mol,
            oe_order_lines_all ol
            WHERE lpn.outermost_lpn_id = p_lpn_id
            AND wdd2.lpn_id = lpn.lpn_id
	         AND wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
            AND wdd2.delivery_detail_id = wda.parent_delivery_detail_id
            AND wdd.delivery_detail_id = wda.delivery_detail_id
            AND mol.line_id = wdd.move_order_line_id
            AND ol.line_id = wdd.source_line_id;


    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   l_progress := '10';
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug('update_wdd_loc_by_lpn  10 -  p_lpn_id = '||p_lpn_id,'WMS_SHIPPING_TRANSACTION_PUB');
      debug('p_subinventory_code = ' || p_subinventory_code, 'WMS_SHIPPING_TRANSACTION_PUB');
      debug('p_locator_id = ' || p_locator_id, 'WMS_SHIPPING_TRANSACTION_PUB');
   END IF;

   SAVEPOINT update_wdd_loc_sp;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN cur_delivery_details;

   l_progress := '20';

   LOOP
      FETCH cur_delivery_details
        INTO
        l_delivery_detail_id,
        l_oe_order_header_id,
        l_oe_order_line_id,
        l_released_status,
        l_organization_id;
      EXIT WHEN cur_delivery_details%notfound;

      l_progress := '30';

      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn  15 - l_delivery_detail_id  = '
                ||l_delivery_detail_id,'WMS_SHIPPING_TRANSACTION_PUB');
         debug('l_oe_order_header_id  = '||l_oe_order_header_id,'WMS_SHIPPING_TRANSACTION_PUB');
         debug('l_oe_order_line_id  = '||l_oe_order_line_id,'WMS_SHIPPING_TRANSACTION_PUB');
         debug('l_organization_id  = '||l_organization_id,'WMS_SHIPPING_TRANSACTION_PUB');
         debug('l_released_status  = '||l_released_status,'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

      l_shipping_attr_tab(l_wdd_counter).source_header_id := l_oe_order_header_id;
      l_shipping_attr_tab(l_wdd_counter).source_line_id := l_oe_order_line_id;
      l_shipping_attr_tab(l_wdd_counter).ship_from_org_id := l_organization_id;
      l_shipping_attr_tab(l_wdd_counter).released_status := l_released_status;
      l_shipping_attr_tab(l_wdd_counter).delivery_detail_id := l_delivery_detail_id;
      l_shipping_attr_tab(l_wdd_counter).action_flag := 'U';
      l_shipping_attr_tab(l_wdd_counter).subinventory := p_subinventory_code;
      l_shipping_attr_tab(l_wdd_counter).locator_id := p_locator_id;
      l_shipping_attr_tab(l_wdd_counter).transfer_lpn_id := p_lpn_id;

      IF (l_debug = 1) THEN
         debug('Disassociate delivery detail with the old lpn, delivery detail id = '
                ||l_shipping_attr_tab(l_wdd_counter).delivery_detail_id, 'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

      WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont
           ( P_DETAIL_ID     => l_shipping_attr_tab(l_wdd_counter).delivery_detail_id,
             X_RETURN_STATUS => l_return_status );
      if (l_return_status <> fnd_api.g_ret_sts_success) then
         IF (l_debug = 1) THEN
         debug('Error Unassign_Detail_from_Cont'|| l_return_status, 'WMS_SHIPPING_TRANSACTION_PUB');
         END IF;
         FND_MESSAGE.SET_NAME('INV', 'INV_UNASSIGN_DEL_FAILURE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      end if;

      l_wdd_counter := l_wdd_counter + 1;
   END LOOP;

   l_progress := '40';

   CLOSE cur_delivery_details;


   IF (l_debug = 1) THEN
      debug('update_wdd_loc_by_lpn  20 - l_wdd_counter = ' || l_wdd_counter, 'WMS_SHIPPING_TRANSACTION_PUB');
   END IF;

   l_progress := '50';

   WSH_INTERFACE.Update_Shipping_Attributes
     (p_source_code               => 'INV',
      p_changed_attributes        => l_shipping_attr_tab,
      x_return_status             => l_return_status
      );

   IF (l_debug = 1) THEN
      debug('update_wdd_loc_by_lpn  25 - WSH_INTERFACE.Update_Shipping_Attributes returns : '
            ||l_return_status, 'WMS_SHIPPING_TRANSACTION_PUB');
   END IF;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn 30 - return expected error from update_shipping_attributes',
               'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

      RAISE FND_API.G_EXC_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn 40 - return unexpected error from update_shipping_attributes',
               'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_progress := '60';

   IF (l_debug = 1) THEN
      debug('update_wdd_loc_by_lpn 50 - complete','WMS_SHIPPING_TRANSACTION_PUB');
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO update_wdd_loc_sp;

      IF cur_delivery_details%isopen THEN
         CLOSE cur_delivery_details;
      END IF;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_UPDATE_WDD_LOC_FAIL');
      FND_MSG_PUB.ADD;

      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn 60 - expected error', 'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO update_wdd_loc_sp;

      IF cur_delivery_details%isopen THEN
         CLOSE cur_delivery_details;
      END IF;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_UPDATE_WDD_LOC_FAIL');
      FND_MSG_PUB.ADD;

      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn 65 - unexpected error', 'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO update_wdd_loc_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF cur_delivery_details%isopen THEN
         CLOSE cur_delivery_details;
      END IF;

      IF (l_debug = 1) THEN
         debug('update_wdd_loc_by_lpn 70 - other error', 'WMS_SHIPPING_TRANSACTION_PUB');
      END IF;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_UPDATE_WDD_LOC_FAIL');
      FND_MSG_PUB.ADD;

      IF SQLCODE IS NOT NULL THEN
         inv_mobile_helper_functions.sql_error('WMS_SHIPPING_TRANSACTION_PUB.update_wdd_loc_by_lpn',
               l_progress, SQLCODE);
      END IF;

END update_wdd_loc_by_lpn;

PROCEDURE GET_LOADED_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
                             p_organization_id         IN NUMBER,
                             p_dock_door_id            IN NUMBER,
                             p_lpn                     IN VARCHAR2)
  IS
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug( 'Org ID : '||p_organization_id||' Dock Door : '||p_dock_door_id, 'get_loaded_lpn_lov');
   END IF;
   open  x_lpn_lov for
     select distinct wlpn.license_plate_number, wlpn.lpn_id,
     wlpn.subinventory_code, milk.concatenated_segments
     from wms_license_plate_numbers wlpn,
     wms_shipping_transaction_temp wstt,
     mtl_item_locations_kfv milk
     WHERE wlpn.organization_id = wstt.organization_id
     AND wlpn.organization_id = p_organization_id
     AND wlpn.lpn_id = wstt.outermost_lpn_id
     and wlpn.lpn_context = wms_globals.lpn_loaded_for_shipment
     AND wstt.dock_door_id = p_dock_door_id
     AND nvl(wstt.direct_ship_flag,'N') = 'N'
     AND milk.organization_id = wlpn.organization_id
     AND milk.inventory_location_id = wlpn.locator_id
     and wlpn.license_plate_number like (p_lpn)
     order by wlpn.license_plate_number;
END get_loaded_lpn_lov;

PROCEDURE GET_LOADED_DOCK_DOORS(x_dock_door_LOV   OUT NOCOPY t_genref,
                                p_organization_id in NUMBER,
                                p_dock_door       IN VARCHAR2) IS
BEGIN
--Bug# 2780663: Dock Door LOV should show only physical locators. (.)s at the positions of Project and Task
--              segments should be suppressed from the KFV in the LOV. Alias "milk_concatenated_segments"
--              is used to avoid "unambiguous column name" error
   open x_dock_door_lov for
     select DISTINCT milk.inventory_location_id,
              inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id)
              milk_concatenated_segments,
              0, milk.organization_id,
              0,0,'','',is_loaded(p_organization_id,milk.inventory_location_id,'N')
              ,''
     from  mtl_item_locations_kfv milk
         , wms_shipping_transaction_temp wstt
     where inventory_location_type = 1
     and  milk.organization_id = p_organization_id
     AND  milk.organization_id = wstt.organization_id
     AND  milk.inventory_location_id = wstt.dock_door_id
     and   inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) like (p_dock_door)
     order by milk_concatenated_segments;

END GET_LOADED_DOCK_DOORS;

PROCEDURE lpn_unload(p_organization_id  IN NUMBER,
                     p_outermost_lpn_id IN NUMBER,
                     x_error_code       OUT NOCOPY NUMBER)
  IS
     l_delivery_detail_id NUMBER;
     CURSOR delivery_details IS
        SELECT delivery_detail_id
          FROM wms_shipping_transaction_temp
          WHERE organization_id = p_organization_id
          AND nvl(direct_ship_flag,'N') = 'N'
          AND outermost_lpn_id = p_outermost_lpn_id;

     l_index              NUMBER;
     l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
     l_return_status      VARCHAR2(1);
     l_msg_data           VARCHAR2(2000);
     l_msg_count          NUMBER;

    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;

BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   x_error_code := 0;
   IF (l_debug = 1) THEN
      debug('In lpn_unload', 'LPN_UNLOAD');
   END IF;

   --update lpn_context
   UPDATE wms_license_plate_numbers
     SET lpn_context = wms_globals.lpn_context_picked,
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id
     WHERE organization_id = p_organization_id
     AND outermost_lpn_id = p_outermost_lpn_id;

   --patchset J.  Shipping API cleanup
   --update shipped_quantity
   l_index := 1;
   l_detail_attributes.DELETE;
   FOR l_delivery_detail_id IN delivery_details LOOP

      l_detail_attributes(l_index).shipped_quantity := NULL;
      l_detail_attributes(l_index).delivery_detail_id :=
        l_delivery_detail_id.delivery_detail_id;

      l_index := l_index + 1;
   END LOOP;

   IF l_debug = 1 THEN
      debug('About to call wsh_delivery_details_pub.update_shipping_attributes','LPN_UNLOAD');
      debug('l_detail_attributes count: ' || l_detail_attributes.COUNT,'LPN_UNLOAD');
   END IF;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => G_TRUE,
      p_commit             => G_FALSE,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF l_return_status <> G_RET_STS_SUCCESS  THEN
      IF l_debug = 1 THEN
         debug('wsh_delivery_details_pub.update_shipping_attributes failed'
               || ' with status: ' || l_return_status, 'LPN_UNLOAD');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --\Shipping API cleanup

   --Patchset J LPN hierarchy

   --Release 12: LPN Synchronize
   -- The following code of populating shipping with LPN hierarchy
   -- is not necessary because LPN hierarchy is in sync between WMS and WSH
   -- before the load/unload stage
   -- Removed the call to container_nesting

   --Clean up data for unloading
   DELETE FROM mtl_material_transactions_temp
     WHERE wms_task_type = 7
     AND organization_id = p_organization_id
     AND content_lpn_id = p_outermost_lpn_id;

   DELETE FROM wms_shipping_transaction_temp
     WHERE organization_id = p_organization_id
     AND outermost_lpn_id = p_outermost_lpn_id
     and nvl(direct_ship_flag,'N') = 'N';

   -- Commit if no errors
   COMMIT;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_error_code := 9999;
      ROLLBACK;
   WHEN OTHERS THEN
      x_error_code := 9999;
      ROLLBACK;
      IF (l_debug = 1) THEN
         debug('Error in lpn_unload : '||SQLERRM, 'LPN_UNLOAD');
      END IF;

END lpn_unload;

PROCEDURE nontransactable_item_check(x_nt_item OUT NOCOPY t_genref,
                                     p_trip_id IN NUMBER,
                                     p_dock_door_id IN NUMBER,
                                     p_organization_id IN NUMBER,
                                     x_nt_count   OUT NOCOPY NUMBER)
  IS
     l_count NUMBER;
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      Debug( 'In Non Transactable Item Check', 'NONTRANSACTABLE_ITEM_CHECK');
   END IF;
   x_nt_count := 0;
   l_count := 0;

   IF (l_debug = 1) THEN
      Debug( 'p_dock_door_id is ' || p_dock_door_id, 'NONTRANSACTABLE_ITEM_CHECK');
      Debug( 'p_organization_id is ' || p_organization_id, 'NONTRANSACTABLE_ITEM_CHECK');
   END IF;

   IF ( p_trip_id <> 0 ) THEN
      IF (l_debug = 1) THEN
         Debug( 'p_trip_id is ' || p_trip_id, 'NONTRANSACTABLE_ITEM_CHECK');
      END IF;
      BEGIN
         SELECT COUNT(*)
           INTO l_count
           FROM  wsh_delivery_details_ob_grp_v wdd,
           wsh_delivery_assignments_v wda,
           wsh_new_deliveries_ob_grp_v wnd,
           wsh_delivery_legs_ob_grp_v wdl,
           wsh_trip_Stops_ob_grp_v pickup_stop,
           mtl_system_items_kfv msik
           WHERE wnd.delivery_id = wda.delivery_id
           AND wda.delivery_id = wdl.delivery_id
           AND wda.delivery_detail_id = wdd.delivery_detail_id
           AND wdl.pick_up_stop_id = pickup_stop.stop_id
           AND pickup_stop.trip_id = p_trip_id
           AND wdd.lpn_id IS NULL
           AND wdd.inventory_item_id = msik.inventory_item_id
           AND wdd.organization_id = p_organization_id
           AND wdd.organization_id = msik.organization_id
           AND msik.mtl_transactions_enabled_flag = 'N';

           IF l_count > 0 THEN
              x_nt_count := l_count;
           END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            OPEN x_nt_item FOR SELECT 1 FROM dual;
            RETURN;
      END;
      OPEN x_nt_item FOR
        SELECT wnd.name,
        wdd.delivery_detail_id,
        wdd.inventory_item_id,
        wdd.requested_quantity,
        wdd.requested_quantity_uom,
        msik.concatenated_segments,
        msik.description
        FROM  wsh_delivery_details_ob_grp_v wdd,
        wsh_delivery_assignments_v wda,
        wsh_new_deliveries_ob_grp_v wnd,
        wsh_delivery_legs_ob_grp_v wdl,
        wsh_trip_stops_ob_grp_v pickup_stop,
        mtl_system_items_kfv msik
        WHERE wnd.delivery_id = wda.delivery_id
        AND wda.delivery_id = wdl.delivery_id
        AND wda.delivery_detail_id = wdd.delivery_detail_id
        AND wdl.pick_up_stop_id = pickup_stop.stop_id
        AND pickup_stop.trip_id = p_trip_id
        AND wdd.lpn_id IS NULL
        AND wdd.inventory_item_id = msik.inventory_item_id
        AND wdd.organization_id = p_organization_id
        AND wdd.organization_id = msik.organization_id
        AND msik.mtl_transactions_enabled_flag = 'N';
    ELSE
      BEGIN
         SELECT COUNT(*)
           INTO l_count
           FROM    wsh_delivery_details_ob_grp_v wdd,
           wsh_delivery_assignments_v wda,
           mtl_system_items_kfv
           msik, wsh_new_deliveries_ob_grp_v wnd
           WHERE   wda.delivery_detail_id = wdd.delivery_detail_id
           AND     wdd.lpn_id IS NULL
           AND     wda.delivery_id IN (SELECT  DISTINCT delivery_id
                                       FROM    wms_shipping_transaction_temp
                                       WHERE   dock_door_id = p_dock_door_id
                                       AND     organization_id = p_organization_id
                                       AND     dock_appoint_flag = 'N'
                                       AND     delivery_id IS NOT NULL
                                       UNION
                                       SELECT  DISTINCT wdl.delivery_id
                                       from    wsh_delivery_legs_ob_grp_v wdl,
                                       wms_shipping_transaction_temp wstt,
                                       wsh_trip_stops_ob_grp_v wts
                                       WHERE   wdl.pick_up_stop_id = wts.stop_id
                                       AND     wts.trip_id  = wstt.trip_id
                                       AND     wstt.dock_door_id = p_dock_door_id
                                       AND     wstt.organization_id = p_organization_id
                                       AND     wstt.dock_appoint_flag = 'N'
                                       AND     nvl(wstt.direct_ship_flag,'N') = 'N')
           AND   wda.delivery_id = wnd.delivery_id
           AND   wdd.organization_id = p_organization_id
           AND   wdd.inventory_item_id = msik.inventory_item_id
           AND   wdd.organization_id = msik.organization_id
           AND   msik.mtl_transactions_enabled_flag = 'N';

           IF l_count > 0 THEN
              x_nt_count := l_count;
           END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            OPEN x_nt_item FOR SELECT 1 FROM dual;
            RETURN;
      END;
      OPEN x_nt_item FOR
      SELECT wnd.name,
        wdd.delivery_detail_id,
        wdd.inventory_item_id,
        wdd.requested_quantity,
        wdd.requested_quantity_uom,
        msik.concatenated_segments,
        msik.description
        FROM wsh_delivery_details_ob_grp_v wdd,
        wsh_delivery_assignments_v wda,
        mtl_system_items_kfv
        msik, wsh_new_deliveries_ob_grp_v wnd
        WHERE   wda.delivery_detail_id = wdd.delivery_detail_id
        AND     wdd.lpn_id IS NULL
        AND     wda.delivery_id IN (SELECT DISTINCT delivery_id
                                      FROM    wms_shipping_transaction_temp
                                      WHERE   dock_door_id = p_dock_door_id
                                      AND     organization_id = p_organization_id
                                      AND     dock_appoint_flag = 'N'
                                      AND     nvl(direct_ship_flag,'N') = 'N'
                                      AND     delivery_id IS NOT NULL
                                      UNION
                                      SELECT DISTINCT wdl.delivery_id
                                      FROM    wsh_delivery_legs_ob_grp_v wdl,
                                      wms_shipping_transaction_temp wstt,
                                      wsh_trip_stops_ob_grp_v wts
                                      WHERE   wdl.pick_up_stop_id = wts.stop_id
                                      AND     wts.trip_id  = wstt.trip_id
                                      AND     wstt.dock_door_id = p_dock_door_id
                                      AND     wstt.organization_id = p_organization_id
                                      AND     wstt.dock_appoint_flag = 'N'
                                      AND     nvl(direct_ship_flag,'N') = 'N')
        AND   wda.delivery_id = wnd.delivery_id
        AND   wdd.organization_id = p_organization_id
        AND   wdd.inventory_item_id = msik.inventory_item_id
        AND   wdd.organization_id = msik.organization_id
        AND   msik.mtl_transactions_enabled_flag = 'N';
   END IF;
END nontransactable_item_check;


/* Direct Shipping */

PROCEDURE get_directshiplpn_lov (
        x_lpn OUT NOCOPY t_genref
  ,     p_organization_id IN NUMBER
  ,     p_lpn IN VARCHAR2)   IS
BEGIN

   OPEN x_lpn FOR
     SELECT     wlpn.license_plate_number
        ,       wlpn.lpn_id
        ,       wlpn.inventory_item_id
        ,       msi.concatenated_segments
        ,       wlpn.gross_weight
        ,       wlpn.gross_weight_uom_code
        ,       wlpn.tare_weight
        ,       wlpn.tare_weight_uom_code
     FROM       wms_license_plate_numbers wlpn
      ,         mtl_system_items_kfv msi
     WHERE     wlpn.organization_id = p_organization_id
     AND       wlpn.license_plate_number LIKE (p_lpn)
     AND       wlpn.lpn_context = 1 /* Resides in Inventory */
     AND       wlpn.parent_lpn_id is null
     AND       wlpn.inventory_item_id = msi.inventory_item_id(+)
     AND       msi.organization_id(+) = wlpn.organization_id
     ORDER BY upper (wlpn.license_plate_number);

 END get_directshiplpn_lov;

/* Bug#
 * In OrderLOV.java setReturnValues(), position 5 is fetched into Customer Id
 * and position 6 is fetched into Customer Number. While here in the
 * Select statement, they are swapped (6, 5 positions).
 * In setReturnValues(), Long.parseLong() is used for 5th position field
 * which is Customer Number-Varchar. This fails if Customer Number has
 * alphanumeric characters. Customer Id is made position 5 and Customer Number
 * for position 6 as the resolution.
 */
 PROCEDURE get_order_lov(
                x_order_lov OUT NOCOPY t_genref
      ,         p_org_id IN NUMBER
      ,         p_order IN VARCHAR2)  IS

 BEGIN
    open x_order_lov FOR
      select distinct   wdd.source_header_number
      ,                 wdd.source_header_id
      ,                 otl.name
      ,                 wdd.source_header_type_id
      ,                 c.party_name
      ,                 hca.cust_account_id
      ,                 c.party_number
      from      wsh_delivery_details_ob_grp_v wdd
      --,  R12 TCA changes     ra_customers c -- added the following tables instead
      ,       hz_parties c , hz_cust_accounts hca
      ,       oe_transaction_types_tl otl
      ,       wms_direct_ship_temp wdst
      where    wdd.customer_id = hca.cust_account_id
      and      c.party_id = hca.party_id
      and      otl.language=userenv('LANG')
      and      wdd.source_header_number like (p_order)
      and      otl.transaction_type_id=wdd.source_header_type_id
      and      wdd.organization_id = p_org_id
      and      wdd.source_code = 'OE'
      and      wdd.date_scheduled is not null
      and      (wdd.released_status  in ('B','R','X')  --Added  bug 4128854
                  or
               (wdst.order_header_id = wdd.source_header_id
                and wdd.released_status  = ('Y')))
      and wdst.organization_id (+) = wdd.organization_id --Added  bug 4128854
      order by 2,1;

 END get_order_lov;


 PROCEDURE get_orderline_lov(
           x_orderline_lov OUT NOCOPY T_GENREF
        ,  p_org_id IN NUMBER
        ,  p_header_id IN NUMBER
        ,  p_order_line IN VARCHAR2
        ,  p_outermost_lpn_id IN NUMBER
        ,  p_cross_proj_flag IN VARCHAR2
        ,  p_project_id  IN NUMBER
        ,  p_task_id IN NUMBER )
 IS
    l_select_stmt VARCHAR2(2000);
    l_prj_where VARCHAR2(2000);
    l_group_by VARCHAR2(2000);
    --l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;

 BEGIN
    IF g_debug IS NULL THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF (l_debug = 1) THEN
       DEBUG('Get orderline lov 1','GET_ORDERLINE_LOV');
       DEBUG('p_org_id= '||p_org_id,'GET_ORDERLINE_LOV');
       DEBUG('p_header_id '||p_header_id,'GET_ORDERLINE_LOV');
       DEBUG('p_order_line '||p_order_line,'GET_ORDERLINE_LOV');
       DEBUG('p_outermost_lpn_id '||p_outermost_lpn_id,'GET_ORDERLINE_LOV');
       DEBUG('p_cross_proj_flag '||p_cross_proj_flag,'GET_ORDERLINE_LOV');
       DEBUG('p_project_id '||p_project_id,'GET_ORDERLINE_LOV');
       DEBUG('p_task_id '||p_task_id,'GET_ORDERLINE_LOV');
    END IF;

    IF (p_cross_proj_flag = 'Y') THEN
       OPEN x_orderline_lov FOR
         SELECT oel.line_id
         ,to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number)) LINE_NUMBER
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.src_requested_quantity --Bug 4169926, sum(wdd.requested_quantity)
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , NVL(wds.processed_flag,'N') processed_flag
         , NVL(wds.processed_quantity,0) processed_quantity
         , wdd.src_requested_quantity_uom
         FROM  oe_order_lines_all oel
         , wsh_delivery_details_ob_grp_v wdd
         , mtl_system_items_kfv msik
         , wms_direct_ship_temp wds
         WHERE   oel.header_id =p_header_id
         and     oel.ship_from_org_id = p_org_id
         and     oel.item_type_code in ('STANDARD','CONFIG','INCLUDED','OPTION')
         and     msik.inventory_item_id = oel.inventory_item_id
         and     msik.organization_id = oel.ship_from_org_id
         and     msik.mtl_transactions_enabled_flag <> 'N'
         and     wdd.source_header_id = oel.header_id
         and     wdd.source_line_id = oel.line_id
         and     wdd.released_status  in ('B','R','X')
         and     wds.lpn_id(+)=p_outermost_lpn_id
         and     oel.LINE_ID=wds.ORDER_LINE_ID (+)
         and     oel.HEADER_ID = wds.order_header_id (+)
         and     oel.ship_from_org_id = wds.organization_id (+)
         and     to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null, '.',null)||
                '.'||to_char(oel.component_number)) like (p_order_line)
         and     exists (select 1
                         from   wms_license_plate_numbers lpn
                         ,      wms_lpn_contents lpc
                         where  lpn.outermost_lpn_id = p_outermost_lpn_id
                         and    lpn.lpn_id = lpc.parent_lpn_id
                         and    lpc.inventory_item_id = oel.inventory_item_id
                         )
         -- Bug# 4258360: Do not include order lines with crossdocked WDD records
         AND NOT EXISTS (SELECT 'xdock'
                         FROM wsh_delivery_details wdd_xdock
                         WHERE wdd_xdock.source_header_id = oel.header_id
                         AND wdd_xdock.source_line_id = oel.line_id
                         AND wdd_xdock.released_status = 'S'
                         AND wdd_xdock.move_order_line_id IS NULL)
         GROUP BY oel.line_id
         , to_char(oel.line_number) ||'.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number))
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , wds.processed_flag
         , wds.processed_quantity
         , wdd.src_requested_quantity --Bug 4169926
         , wdd.src_requested_quantity_uom
         UNION  --Added bug 4128854

         SELECT oel.line_id
         ,to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number)) LINE_NUMBER
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , 0
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , 'N' processed_flag
         , 0 processed_quantity
         , wdd.src_requested_quantity_uom
         FROM  oe_order_lines_all oel
         , wsh_delivery_details_ob_grp_v wdd
         , mtl_system_items_kfv msik
         , wms_direct_ship_temp wds
         WHERE   oel.header_id =p_header_id
         and     oel.ship_from_org_id = p_org_id
         and     oel.item_type_code in ('STANDARD','CONFIG','INCLUDED','OPTION')
         and     msik.inventory_item_id = oel.inventory_item_id
         and     msik.organization_id = oel.ship_from_org_id
         and     msik.mtl_transactions_enabled_flag <> 'N'
         and     wdd.source_header_id = oel.header_id
         and     wdd.source_line_id = oel.line_id
         and     wdd.released_status  in ('Y')
         and not exists (select 1
                         from wsh_delivery_details wdd2
                         where   wdd.source_header_id =wdd2.source_header_id
                         and     wdd.source_line_id = wdd2.source_line_id
                         and     wdd2.released_status in ('B','X','R')
                         )
         and     wds.lpn_id(+)=p_outermost_lpn_id
         and     oel.LINE_ID=wds.ORDER_LINE_ID(+)
         and     oel.HEADER_ID = wds.order_header_id(+)
         and     oel.ship_from_org_id = wds.organization_id(+)
         and     to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null, '.',null)||
                '.'||to_char(oel.component_number)) like (p_order_line)
         and     exists (select 1
                         from   wms_license_plate_numbers lpn
                         ,      wms_lpn_contents lpc
                         where  lpn.outermost_lpn_id = p_outermost_lpn_id
                         and    lpn.lpn_id = lpc.parent_lpn_id
                         and    lpc.inventory_item_id = oel.inventory_item_id
                         )
         -- Bug# 4258360: Do not include order lines with crossdocked WDD records
         AND NOT EXISTS (SELECT 'xdock'
                         FROM wsh_delivery_details wdd_xdock
                         WHERE wdd_xdock.source_header_id = oel.header_id
                         AND wdd_xdock.source_line_id = oel.line_id
                         AND wdd_xdock.released_status = 'S'
                         AND wdd_xdock.move_order_line_id IS NULL)
         GROUP BY oel.line_id
         , to_char(oel.line_number) ||'.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number))
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , wds.processed_flag
         , wds.processed_quantity
         , wdd.src_requested_quantity_uom
         ORDER BY 1,2;

     ELSE

       OPEN x_orderline_lov FOR
         SELECT oel.line_id
         ,to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number)) LINE_NUMBER
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.src_requested_quantity --Bug 4169926, sum(wdd.requested_quantity)
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , NVL(wds.processed_flag,'N') processed_flag
         , NVL(wds.processed_quantity,0) processed_quantity
         , wdd.src_requested_quantity_uom
         FROM  oe_order_lines_all oel
         , wsh_delivery_details_ob_grp_v wdd
         , mtl_system_items_kfv msik
         , wms_direct_ship_temp wds
         WHERE   oel.header_id =p_header_id
         and     oel.ship_from_org_id = p_org_id
         and     oel.item_type_code in ('STANDARD','CONFIG','INCLUDED','OPTION')
         and     msik.inventory_item_id = oel.inventory_item_id
         and     msik.organization_id = oel.ship_from_org_id
         and     msik.mtl_transactions_enabled_flag <> 'N'
         and     wdd.source_header_id = oel.header_id
         and     wdd.source_line_id = oel.line_id
         and     wdd.released_status  in ('B','R','X')
         and     wds.lpn_id(+)=p_outermost_lpn_id
         and     oel.LINE_ID=wds.ORDER_LINE_ID (+)
         and     oel.HEADER_ID = wds.order_header_id (+)
         and     oel.ship_from_org_id = wds.organization_id (+)
         and     to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null, '.',null)||
                '.'||to_char(oel.component_number)) like (p_order_line)
         and     exists (select 1
                         from   wms_license_plate_numbers lpn
                         ,      wms_lpn_contents lpc
                         where  lpn.outermost_lpn_id = p_outermost_lpn_id
                         and    lpn.lpn_id = lpc.parent_lpn_id
                         and    lpc.inventory_item_id = oel.inventory_item_id
                         )
         and NVL(oel.project_id,-1)=NVL(p_project_id,-1) and NVL(oel.task_id,-1)=NVL(p_task_id,-1)
         -- Bug# 4258360: Do not include order lines with crossdocked WDD records
         AND NOT EXISTS (SELECT 'xdock'
                         FROM wsh_delivery_details wdd_xdock
                         WHERE wdd_xdock.source_header_id = oel.header_id
                         AND wdd_xdock.source_line_id = oel.line_id
                         AND wdd_xdock.released_status = 'S'
                         AND wdd_xdock.move_order_line_id IS NULL)
         GROUP BY oel.line_id
         , to_char(oel.line_number) ||'.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number))
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , wds.processed_flag
         , wds.processed_quantity
         , wdd.src_requested_quantity --Bug 4169926
         , wdd.src_requested_quantity_uom
         UNION --Added bug 4128854

         SELECT oel.line_id
         ,to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number)) LINE_NUMBER
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , 0
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , 'N' processed_flag
         , 0 processed_quantity
         , wdd.src_requested_quantity_uom
         FROM  oe_order_lines_all oel
         , wsh_delivery_details_ob_grp_v wdd
         , mtl_system_items_kfv msik
         , wms_direct_ship_temp wds
         WHERE   oel.header_id =p_header_id
         and     oel.ship_from_org_id = p_org_id
         and     oel.item_type_code in ('STANDARD','CONFIG','INCLUDED','OPTION')
         and     msik.inventory_item_id = oel.inventory_item_id
         and     msik.organization_id = oel.ship_from_org_id
         and     msik.mtl_transactions_enabled_flag <> 'N'
         and     wdd.source_header_id = oel.header_id
         and     wdd.source_line_id = oel.line_id
         and     wdd.released_status  in ('Y')
         and not exists (select 1
                         from wsh_delivery_details wdd2
                         where   wdd.source_header_id =wdd2.source_header_id
                         and     wdd.source_line_id = wdd2.source_line_id
                         and     wdd2.released_status in ('B','X','R')
                         )
         and     wds.lpn_id(+)=p_outermost_lpn_id
         and     oel.LINE_ID=wds.ORDER_LINE_ID (+)
         and     oel.HEADER_ID = wds.order_header_id (+)
         and     oel.ship_from_org_id = wds.organization_id (+)
         and     to_char(oel.line_number)||
         '.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null, '.',null)||
                '.'||to_char(oel.component_number)) like (p_order_line)
         and     exists (select 1
                         from   wms_license_plate_numbers lpn
                         ,      wms_lpn_contents lpc
                         where  lpn.outermost_lpn_id = p_outermost_lpn_id
                         and    lpn.lpn_id = lpc.parent_lpn_id
                         and    lpc.inventory_item_id = oel.inventory_item_id
                         )
         and NVL(oel.project_id,-1)=NVL(p_project_id,-1) and NVL(oel.task_id,-1)=NVL(p_task_id,-1)
         -- Bug# 4258360: Do not include order lines with crossdocked WDD records
         AND NOT EXISTS (SELECT 'xdock'
                         FROM wsh_delivery_details wdd_xdock
                         WHERE wdd_xdock.source_header_id = oel.header_id
                         AND wdd_xdock.source_line_id = oel.line_id
                         AND wdd_xdock.released_status = 'S'
                         AND wdd_xdock.move_order_line_id IS NULL)
         GROUP BY oel.line_id
         , to_char(oel.line_number) ||'.'||to_char(oel.shipment_number) ||
         decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
         decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
                '.'||to_char(oel.component_number))
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , wdd.REQUESTED_QUANTITY_UOM
         , wdd.SHIP_FROM_LOCATION_ID
         , wdd.SHIP_TO_LOCATION_ID
         , wdd.CUSTOMER_ID
         , wdd.INTMED_SHIP_TO_LOCATION_ID
         , wdd.SHIP_METHOD_CODE
         , wdd.FOB_CODE
         , wdd.FREIGHT_TERMS_CODE
         , wds.processed_flag
         , wds.processed_quantity
         , wdd.src_requested_quantity_uom
         ORDER BY 1,2;
    END IF;

    IF (l_debug = 1) THEN
       DEBUG('Get orderline lov 2','GET_ORDERLINE_LOV');
    END IF;

 END get_orderline_lov;



PROCEDURE Get_FreightCost_Type
  ( x_freight_type_code   out NOCOPY t_genref
    ,     p_text                in  VARCHAR2) IS
BEGIN
   open x_freight_type_code for
     Select    name
     ,        amount
     ,        currency_code
     ,        freight_cost_type_id
     From     wsh_freight_cost_types
     Where    sysdate between nvl(start_date_active, sysdate) and
     nvl(end_date_active, sysdate)
     And  name like  (p_text)
     Order by name;

END Get_FreightCost_Type;

PROCEDURE Get_Freight_Term
  (x_freight_terms   out NOCOPY t_genref
   ,     p_text            in  varchar2) IS
BEGIN
   open x_freight_terms for
     select freight_terms
     ,      freight_terms_code
     from   oe_frght_terms_active_v
     where  freight_terms like (p_text)
     order by freight_terms_code;

END Get_Freight_Term;


PROCEDURE get_document_set_lov
  (x_report_set out NOCOPY t_genref
   ,     p_text       in  varchar2)  IS
BEGIN
   Open x_report_set for
     Select     report_set_id
     ,  name
     ,  description
     from       wsh_report_sets
     where      usage_code = 'SHIP_CONFIRM'
     and        trunc(nvl(start_date_active, sysdate)) <= trunc(sysdate)
     and        trunc(nvl(end_date_active, sysdate+1)) > trunc(sysdate)
     and    name like (p_text);

END Get_document_set_lov;

PROCEDURE get_conversion_type
  (x_conversion_type out NOCOPY t_genref
   ,     p_text            in  varchar2) IS
BEGIN
   open x_conversion_type for
     Select  conversion_type
     ,       user_conversion_type
     ,       description
     From    gl_daily_conversion_types
     Where   conversion_type <> 'EMU FIXED'
     and     user_conversion_type like (p_text)
     Order by user_conversion_type, description;

END GET_CONVERSION_TYPE;

PROCEDURE get_currency_code
  (x_currency   out NOCOPY t_genref
   ,     p_text       in  varchar2) IS
BEGIN
   open x_currency for
     select   c.currency_code
     ,        c.name currency_name
     ,        c.precision
     from     fnd_currencies_vl c
     where    c.currency_flag='Y'
     and      c.enabled_flag='Y'
     and      trunc(nvl(c.start_date_active,sysdate))<=trunc(sysdate)
     and      trunc(nvl(c.end_date_active,sysdate+1))>trunc(sysdate)
     and      currency_code like (p_text)
     order by c.currency_code;

END GET_CURRENCY_CODE;

Procedure Get_unloadTruck_lpn_lov
  (x_lpn_lov                 out NOCOPY t_genref
   ,     p_organization_id         IN NUMBER
   ,     p_dock_door_id            IN NUMBER
   ,     p_lpn                     IN VARCHAR2) IS

BEGIN
   open  x_lpn_lov for
     select distinct    wlpn.license_plate_number
     ,                 wlpn.lpn_id
     ,                 wlpn.subinventory_code
     ,                 milk.concatenated_segments
     from wms_license_plate_numbers wlpn
     ,   wms_shipping_transaction_temp wstt
     ,   mtl_item_locations_kfv milk
     WHERE  wlpn.organization_id = wstt.organization_id
     AND    wlpn.organization_id = p_organization_id
     AND    wlpn.lpn_id = wstt.outermost_lpn_id
     AND    nvl(wstt.direct_ship_flag,'N') = 'Y'
           /* Uncomment this after this flag is introduced in the table */
     AND    wlpn.lpn_context = 9
     AND    wstt.dock_door_id = p_dock_door_id
     AND    milk.organization_id = wlpn.organization_id
     AND    milk.inventory_location_id = wlpn.locator_id
     AND    wlpn.license_plate_number like (p_lpn)
     order by wlpn.license_plate_number;

END Get_unloadTruck_lpn_lov;

 PROCEDURE GET_LPN_CONTENTS
 (
        x_lpn_contents  OUT NOCOPY t_genref,
        p_lpn_id        IN  NUMBER,
        p_org_id        IN  NUMBER
 )
 IS
   CURSOR lpn_id_cursor IS
    SELECT lpn_id
      FROM wms_license_plate_numbers lpn
      WHERE outermost_lpn_id = p_lpn_id
      AND   organization_id  = p_org_id
      AND   lpn_context      = 1;

   lpn_id_str VARCHAR(2000);
   lpn_contents_select_str VARCHAR2(4000);
   v_lpn_id NUMBER;
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
 BEGIN
    IF g_debug IS NULL THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF (l_debug = 1) THEN
       DEBUG('Starting to get the Contents' , 'GET_LPN_CONTENTS');
    END IF;
    lpn_id_str := '( ';
    lpn_contents_select_str := 'SELECT parent_lpn_id, inventory_item_id, quantity, uom_code, revision ';
    lpn_contents_select_str := lpn_contents_select_str || ' FROM wms_lpn_contents ';
    lpn_contents_select_str := lpn_contents_select_str || ' WHERE parent_lpn_id IN ';

    OPEN lpn_id_cursor;
    FETCH lpn_id_cursor INTO v_lpn_id;
    lpn_id_str := '( ' || to_char(v_lpn_id);
    LOOP
       FETCH lpn_id_cursor INTO v_lpn_id;
       EXIT WHEN lpn_id_cursor%NOTFOUND;
       lpn_id_str := lpn_id_str || ' , ' || v_lpn_id;
    END LOOP;
    CLOSE lpn_id_cursor;
    lpn_id_str := lpn_id_str || ' )';
    lpn_contents_select_str := lpn_contents_select_str || lpn_id_str;

    OPEN x_lpn_contents FOR lpn_contents_select_str;
    IF (l_debug = 1) THEN
       DEBUG('Finihed getting the Contents' , 'GET_LPN_CONTENTS');
    END IF;
 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          DEBUG('Exception Occured' || SQLERRM, 'GET_LPN_CONTENTS');
       END IF;
 END GET_LPN_CONTENTS;

/* Direct Shipping */

/* This function is added as part of bug fix 2529382.
   This function gets the next heigher name of a resuable container
   by which the existing container in shipping is updated.
*/
FUNCTION get_container_name(p_container_name IN VARCHAR2) RETURN VARCHAR2 IS

   CURSOR l_container IS
        select container_name from wsh_delivery_details_ob_grp_v
        where container_name like p_container_name||'-@-%';

   l_num_part_str VARCHAR2(30);

   x VARCHAR2(30);
   to_return NUMBER:=0;

    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug number;
   BEGIN
       IF g_debug IS NULL THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       END IF;
       l_debug := g_debug;

       FOR l_cont_cur IN l_container LOOP
                IF (l_debug = 1) THEN
                   debug('l_cont_cur.container_name = '||l_cont_cur.container_name
                          ||' p_container_name '||p_container_name,'get_container_name');
                END IF;

               l_num_part_str:=substr(l_cont_cur.container_name,length(p_container_name||'-@-')+1);
               begin
                IF (l_debug = 1) THEN
                   debug('Num part value = '||l_num_part_str,'get_container_name');
                END IF;
                x:=to_number(l_num_part_str);
                if x> to_return then
                        to_return:=x;
                end if;
               exception
                  when invalid_number then
                  IF (l_debug = 1) THEN
                     debug('Exception :  Num part value = '||l_num_part_str,'get_container_name');
                  END IF;
                  when value_error then
                  IF (l_debug = 1) THEN
                     debug('Exception :  Num part value = '||l_num_part_str,'get_container_name');
                  END IF;
               end;
       END LOOP;
  IF (l_debug = 1) THEN
     debug('Return value'||l_num_part_str,'get_container_name');
  END IF;
  return p_container_name||'-@-'||to_char(to_return+1);

   EXCEPTION
    when others then
       IF (l_debug = 1) THEN
          debug('Exception occured while getting new container name: '||
                 l_num_part_str,'get_container_name');
       END IF;
  END;



  -- This procedure is introduced for RFID project
/*
API Name:close_truck

Input parameters:
  P_dock_door_id : Shipping dock door id
  P_organization_id : organization_id
  p_shipping_mode : 'NORMAL'--Equivalent to normal LPN ship;
                    'DIRECT'--Equivalent to Direct LPN ship;
                     NULL   --will process both above;
Output parameters:
  x_return_status : 'S' --Sucess,
                    'W' --Warning
                    'E' --ERROR
  x_return_msg   : Returned message

*/

procedure close_truck
  ( P_dock_door_id    IN NUMBER,
    P_organization_id IN NUMBER,
    p_shipping_mode   IN VARCHAR2 DEFAULT null,
    p_commit_flag     IN VARCHAR2 DEFAULT fnd_api.g_true,
    x_return_status   OUT  NOCOPY VARCHAR2,
    x_return_msg      OUT  NOCOPY VARCHAR2
    )
  IS

     --for LPNs loaded through Normal method only
     --for LPNs loaded through direct method, it is handled inside  wms_direct_ship_pvt.close_truck
-- check for missing LPN is done for the delivery

     cursor normal_lpns_for_dock is
    select DISTINCT outermost_lpn_id,Nvl(trip_id,0)
      from WMS_SHIPPING_TRANSACTION_TEMP
      where organization_id = p_organization_id
      and dock_door_id = p_dock_door_id
      and nvl(direct_ship_flag,'N') = 'N';


 l_return_status  VARCHAR2(1);
 l_msg_data       VARCHAR2(2000);
 l_msg_count      NUMBER;
 l_missing_items  t_genref;
 l_error_code     NUMBER;
 l_trip_id        NUMBER;


 l_vehicle_item_id    NUMBER;
 l_vehicle_num_prefix VARCHAR2(30);
 l_vehicle_num        VARCHAR2(30);
 l_seal_code          VARCHAR2(30);
 l_document_set_id    NUMBER;
 l_outermost_lpn_id             NUMBER;
 l_serial_at_issue    NUMBER;
 l_missing_item  t_genref;
 l_missing_lpns  t_genref;
 l_ship_set      VARCHAR2(30);
 l_delivery_info t_genref;
 l_deli_count    NUMBER;
 --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 l_debug number;

BEGIN

   x_return_status :=  FND_API.g_ret_sts_success;
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF (l_debug = 1) THEN
      DEBUG('p_dock_door_id :: P_organization_id :: p_shipping_mode', 'CLOSE_TRUCK');
      DEBUG(''||p_dock_door_id ||'::'|| P_organization_id ||'::'|| p_shipping_mode, 'CLOSE_TRUCK');
   END IF;


   IF p_shipping_mode = 'NORMAL' OR  p_shipping_mode IS NULL THEN

      IF (l_debug = 1) THEN
         debug(' Before calling check_lpn_deliveries : NORMAL', 'CLOSE_TRUCK');
      END IF;


      --since shipping ship-confirms all the staged lines and does not
      --distinguishes between lines that have loaded to the dock-door or just
      --staged, We need to give an option to user whether he would like to
      --unassign ALL unloaded lines automatically or fail the
      --transaction. since there is no UI in rfid txn, it can be done with
      --parameter at Org level. For the Patch set J, We will fail the
      --transaction  IF there are lines which are staged but not loaded to
      --the dock-door. It is done inside following  check_lpn_deliveries API

     BEGIN
        OPEN  normal_lpns_for_dock;
        LOOP
           fetch normal_lpns_for_dock into l_outermost_lpn_id,l_trip_id;
           exit when normal_lpns_for_dock%NOTFOUND;
           IF (l_debug = 1) THEN
              debug(' processing LPNs l_outermost_lpn_id ::'||l_outermost_lpn_id||
                    '::l_trip_id ::'||l_trip_id, 'CLOSE_TRUCK');
           END IF;


         check_lpn_deliveries
           (p_trip_id            => l_trip_id,--relevant for dock
            --appointment, it will have value if loaded with dock appointment
            p_organization_id    => p_organization_id,
            p_dock_door_id       => p_dock_door_id,
            p_outermost_lpn_id   => l_outermost_lpn_id,
            p_delivery_id        => null,
            x_error_code         => l_error_code, -- 0 means success
            x_missing_item       => l_missing_item,
            x_missing_lpns       => l_missing_lpns,
            x_ship_set           => l_ship_set,
            x_delivery_info      => l_delivery_info,
            x_deli_count         => l_deli_count,
            p_rfid_call          => 'Y');

         debug( 'p_error_code:'|| l_error_code, 'CLOSE_TRUCK');

         IF l_error_code <> 0 THEN
            IF (l_debug = 1) THEN
               debug('check_lpn_deliveries delivery failed','CLOSE_TRUCK');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        END LOOP;
        CLOSE normal_lpns_for_dock;
     EXCEPTION
        when no_data_found then
           IF (l_debug = 1) THEN
              debug('check_lpn_deliveries: NO DATA FOUND','CLOSE_TRUCK');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
     END;

     --Following api process ship LPNs with dock-appointment and without dock
      -- appointment, ALL that are loaded TO the dock door

      IF (l_debug = 1) THEN
         debug(' calling ship_confirm_lpn_deliveries()', 'CLOSE_TRUCK');
      END IF;

      ship_confirm_lpn_deliveries
        (x_return_status   => l_return_status,
         x_msg_data        => l_msg_data,
         x_msg_count       => l_msg_count,
         p_trip_stop_id    => 0,
         p_trip_id         => l_trip_id,--relevant for dock appointment
         p_dock_door_id    => p_dock_door_id,
         p_organization_id => p_organization_id,
         p_verify_only     => 'N');

      IF (l_debug = 1) THEN
         debug(' AFTER calling wms_shipping_transaction_pub.ship_confirm_lpn_deliveries()', 'CLOSE_TRUCK');
         debug(' l_return_status::' ||l_return_status, 'CLOSE_TRUCK');
         debug(' l_msg_data::' ||l_msg_data, 'CLOSE_TRUCK');
      END IF;

      IF l_return_status IN  ('S','W') THEN

         IF p_commit_flag = fnd_api.g_true THEN
            IF (l_debug = 1) THEN
               debug(' Commit', 'CLOSE_TRUCK');
            END IF;

            COMMIT;
          else

            IF (l_debug = 1) THEN
               debug(' No Commit', 'CLOSE_TRUCK');
            END IF;

         END IF;

       ELSE

         IF (l_debug = 1) THEN
            debug(' returning Error', 'CLOSE_TRUCK');
         END IF;
         RAISE fnd_api.g_exc_error;

      END IF;
   END IF;

   IF  p_shipping_mode = 'DIRECT' OR  p_shipping_mode IS NULL THEN


      IF (l_debug = 1) THEN
         debug(' Before calling wms_direct_ship_pvt.close_truck : DIRECT', 'CLOSE_TRUCK');
      END IF;

         --handles dircet ship with dock appointment and without dock
         --appointment, inside it does all required validations for LPNs
         --loaded TO the dock door via direct method

         wms_direct_ship_pvt.close_truck(
                                         x_return_status      => l_return_status
                                         , x_msg_data         => l_msg_data
                                         , x_msg_count        => l_msg_count
                                         , x_error_code       => l_error_code
                                         , x_missing_item_cur => l_missing_items
                                         , p_dock_door_id     => p_dock_door_id
                                         , p_group_id         => NULL --no longer needed after I
                                         , p_org_id           => p_organization_id
                                         );

         IF (l_debug = 1) THEN
            debug('  l_return_status, l_msg_data, l_msg_count', 'CLOSE_TRUCK');
            debug(' '||l_return_status||'::'||l_msg_data||'::'||l_msg_count, 'CLOSE_TRUCK');
         END IF;


         IF l_return_status IN  ('S','W') THEN

            IF p_commit_flag = fnd_api.g_true THEN
               IF (l_debug = 1) THEN
                  debug(' Commit', 'CLOSE_TRUCK');
               END IF;

               COMMIT;
             ELSE

               IF (l_debug = 1) THEN
                  debug(' No Commit', 'CLOSE_TRUCK');
               END IF;

            END IF;

          ELSE
            debug(' returning Error', 'CLOSE_TRUCK');
            RAISE fnd_api.g_exc_error;

         END IF;

   END IF;
   debug('Returning from API','CLOSE_TRUCK');
   x_return_msg := l_msg_data;

EXCEPTION
   WHEN OTHERS THEN

      IF normal_lpns_for_dock%ISOPEN THEN
         CLOSE normal_lpns_for_dock;
      END IF;

      x_return_status := 'E';
      IF (l_debug = 1) THEN
         debug('Other error in close_truck()', 'CLOSE_TRUCK');
         debug('SQL error :'||substr(sqlerrm, 1, 240), 'CLOSE_TRUCK');
      END IF;

END close_truck;

--bug3643846: This method will set the serial_number_entry column in WLC
--This is only needed for serial @ SO issue item because
--by the time of ship confirmation, it's only serial @ SO issue items
--that will not have this column set corrected.  This column should be
--set correctly during pack operations of other serial controlled items.
PROCEDURE update_lpn_contents
      (p_outermost_lpn_id IN NUMBER,
       p_org_id           IN NUMBER,
       x_return_status    OUT nocopy VARCHAR2,
       x_msg_count        OUT nocopy NUMBER,
       x_msg_data         OUT nocopy VARCHAR2) IS

          TYPE lpn_id_tbl_type IS TABLE OF wms_lpn_contents.parent_lpn_id%TYPE;
          TYPE inventory_item_id_tbl_type IS TABLE OF wms_lpn_contents.inventory_item_id%TYPE;

          l_parent_lpn_id lpn_id_tbl_type;
          l_inventory_item_id inventory_item_id_tbl_type;

          --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
          l_debug number;
BEGIN
   IF g_debug IS NULL THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   debug('Entered with p_outermost_lpn_id : ' || p_outermost_lpn_id
         || '  p_org_id : ' || p_org_id,'UPDATE_LPN_CONTENTS');

   x_return_status := 'S';

   SELECT wlc.parent_lpn_id, wlc.inventory_item_id
     bulk collect INTO l_parent_lpn_id, l_inventory_item_id
     from wms_lpn_contents wlc, wms_license_plate_numbers wlpn,  mtl_system_items_kfv msik
     where wlc.organization_id = p_org_id
     and msik.organization_id = p_org_id
     and wlpn.organization_id = wlc.organization_id
     AND wlpn.outermost_lpn_id = p_outermost_lpn_id
     and wlpn.lpn_id = wlc.parent_lpn_id
     and wlc.inventory_item_id = msik.inventory_item_id
     and msik.serial_number_control_code = 6
     and wlc.serial_summary_entry <> 1;

   IF l_parent_lpn_id.COUNT > 0 THEN
      IF l_debug = 1 THEN
         debug('Found ' || l_parent_lpn_id.COUNT || ' entries to update','UPDATE_LPN_CONTENTS');
         debug('The list of lpn_id to update:','UPDATE_LPN_CONTENTS');
         FOR j IN l_parent_lpn_id.first .. l_parent_lpn_id.last LOOP
            debug(j || ': ' || l_parent_lpn_id(j),'UPDATE_LPN_CONTENTS');
         END LOOP;
      END IF;

      forall i IN l_parent_lpn_id.first .. l_parent_lpn_id.last
        UPDATE wms_lpn_contents
        SET serial_summary_entry = 1
        WHERE parent_lpn_id = l_parent_lpn_id(i)
        AND inventory_item_id = l_inventory_item_id(i);
    ELSE
      debug('Did not find any content lpn to update','UPDATE_LPN_CONTENTS');
   END IF;

END update_lpn_contents;



END WMS_SHIPPING_TRANSACTION_PUB;

/
