--------------------------------------------------------
--  DDL for Package Body WMS_RFID_DEVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RFID_DEVICE_PUB" AS
--/* $Header: WMSRFIDB.pls 120.10 2006/11/02 10:01:14 ashchand ship $ */

l_ship_confirm_pkg_mesg VARCHAR2(2000) := null;
l_device_req_id_pkg NUMBER;

-----------------------------------------------------
-- trace
-----------------------------------------------------
PROCEDURE trace(p_msg IN VARCHAR2,p_level IN NUMBER DEFAULT 1 ) IS

   l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF l_debug = 1 THEN
      inv_trx_util_pub.trace(p_msg, 'WMS_RFID_DEVICE_PUB', P_LEVEL);
   END IF;
END trace;


---------------------------------------------------------
--   Populate History
--This API transfer data from WDR to WDRH irrespective of whether txn
--succeed OR fails, It is always called after the call to autonomous
--PROCEDURE generate_xml_csv_api()
---------------------------------------------------------
PROCEDURE populate_history(p_device_id IN NUMBER)
  IS
     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     --might need to change this to transfer only required columns
     CURSOR cur_dev IS SELECT * FROM wms_device_requests where device_id = p_device_id;

     l_cnt NUMBER := 0;
BEGIN

   IF (l_debug = 1) THEN
      trace('Inside populate_history device_id:'||p_device_id);
   END IF;


   FOR l_rec IN cur_dev LOOP

      IF (l_debug = 1) THEN
	 trace('count record in the populate hist:'|| l_cnt);
      END IF;

      l_cnt :=  l_cnt +1;


      INSERT INTO wms_device_requests_hist
	(request_id,
	 business_event_id,
	 organization_id,
	 lpn_id,
	 device_id,
	 subinventory_code,
	 locator_id,
	 status_code,
	 status_msg,
	 task_summary,
	 requested_by,
	 responsibility_application_id,
	 responsibility_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 REQUEST_DATE
	 )VALUES(
		 l_rec.request_id,
		 l_rec.business_event_id,
		 l_rec.organization_id,
		 l_rec.lpn_id,
		 l_rec.device_id,
		 l_rec.subinventory_code,
		 l_rec.locator_id,
		 Nvl(l_rec.status_code,'S'),
		 l_rec.status_msg,
		 'Y',
		 fnd_global.user_id,
		 FND_GLOBAL.RESP_APPL_ID,
		 FND_GLOBAL.RESP_ID,
		 l_rec.last_update_date,
		 fnd_global.user_id,
		 l_rec.last_update_date,
		 fnd_global.user_id,
		 l_rec.last_update_date);

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     IF (l_debug = 1) THEN
	trace('Other errror: populate_history');
	trace('SQL error :'||substr(sqlerrm, 1, 240));
     END IF;
END;

  -------------------------------------------------------
  --generate_xml_csv_api.generates XML/CSV or calls API
  --after inserting records into WDR
  -------------------------------------------------------

PROCEDURE generate_xml_csv_api(p_device_id IN NUMBER,
			       p_business_event_id IN NUMBER,
			       P_organization_id IN NUMBER,
			       p_lpn_id IN NUMBER,
			       p_output_method_id IN NUMBER,
			       p_subinventory_code IN VARCHAR2,
			       p_locator_id IN NUMBER,
			       p_status_code IN VARCHAR2,
			       p_event_date IN DATE,
			       x_request_id  OUT NOCOPY NUMBER,
			       x_return_status OUT NOCOPY VARCHAR2)

  IS
     PRAGMA AUTONOMOUS_TRANSACTION;

     l_request_id NUMBER;
     l_msg_data VARCHAR2(240);
     l_xml_stat VARCHAR2(1);
     l_return_status VARCHAR2(1);
     l_dev_stat varchar2(255);
     l_retval NUMBER;
     l_msg_count NUMBER;
     l_count NUMBER;
     l_tmp_out NUMBER;
     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SAVEPOINT generate_xml_csv_sp;

   x_return_status := FND_API.g_ret_sts_success;


   IF (l_debug = 1) THEN
      trace('generate_xml_csv_api ::DEVICE::OUT_METHOD:status_code:p_event_date');
      trace('generate_xml_csv_api ::'||p_device_id ||'::'||p_output_method_id||'::'||p_status_code||'::'||p_event_date);

   END IF;

   --populate the WDR table
   IF l_device_req_id_pkg IS NULL THEN
      SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
      l_device_req_id_pkg := l_request_id;
    ELSE
      l_request_id := l_device_req_id_pkg;
   END IF;


   IF p_business_event_id = wms_device_integration_pvt.wms_be_truck_load_ship THEN
       l_msg_data := l_ship_confirm_pkg_mesg;
    else
      l_msg_data := fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');

   END IF;


    IF (l_debug = 1) THEN
      trace('generate_xml_csv_api ::l_msg_data::'||l_msg_data);

   END IF;


   INSERT INTO wms_device_requests  (request_id,
				     business_event_id,
				     organization_id,
				     lpn_id,
				     device_id,
				     subinventory_code,
				     locator_id,
				     status_code,
				     status_msg,
				     last_update_date,
				     last_updated_by
				     ) VALUES
     (l_request_id,
      p_business_event_id,
      p_organization_id,
      p_lpn_id,
      p_device_id,
      p_subinventory_code,
      p_locator_id,
      p_status_code,
      l_msg_data,
      p_event_date,
      fnd_global.user_id);


   --generate XML/CSV/API

   IF (l_debug = 1) THEN
      trace('generate_xml_csv_api:Inserted record into WDR');
   END IF;


   -- Generate XML,CSV if configured for it
   IF (( p_output_method_id= wms_device_integration_pvt.WMS_DEV_IO_XML) OR (p_output_method_id = wms_device_integration_pvt.WMS_DEV_IO_CSV)) then
      IF (l_debug = 1) THEN
	 trace('going to call wms_device_integration_pvt.generate_xml_csv');
      END IF;

      BEGIN
	 l_retval := wms_device_integration_pvt.generate_xml_csv(p_device_id,p_output_method_id);

	 IF l_retval <> 0 THEN
	 l_xml_stat := 'E';
	  ELSE
	 l_xml_stat := 'S';
	 END IF;
	 IF (l_debug = 1) THEN
	    trace(' Done with generate xml , retval '||l_retval ||' status_code: '||l_xml_stat);
	 END IF;

      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       trace(' Exception in call to wms_device_integration_pvt.generate_xml_csv');
	    END IF;
	    l_xml_stat := 'E';
      END;


      --Update WDR since error while generating the XML
      IF l_xml_stat <> 'S' THEN

	 l_msg_data :=  fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');--only last message

	 UPDATE wms_device_requests
	   SET status_code = l_xml_stat,
	   status_msg = l_msg_data
	   WHERE device_id = p_device_id;
      END IF;


    ELSIF (p_output_method_id = wms_device_integration_pvt.WMS_DEV_IO_API) then
      IF (l_debug = 1) THEN
	 trace(' generate_xml_csv_api: Submit sync_device_request');
      END IF;


      BEGIN
	 WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST(
							p_request_id    => l_request_id,
							p_device_id     => p_device_id,
							p_resubmit_flag => 'N',
							x_status_code   => l_return_status,
							x_device_status => l_dev_stat,
							x_status_msg    => l_msg_data );

      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       trace(' EXCEPTION from call to SYNC_DEVICE_REQUEST');
	    END IF;
	    l_return_status := 'E';
      END;


      IF (l_debug = 1) THEN
	 trace(' After call to SYNC_DEVICE_REQUEST l_return_status:'||l_return_status);
      END IF;


      IF (l_return_status<> FND_API.g_ret_sts_success) THEN

	 l_msg_data :=  fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');--only last message

	 UPDATE wms_device_requests
	   SET status_code = l_return_status,
	   status_msg = l_msg_data
	   WHERE device_id = p_device_id;

      END IF;

   END IF;


   IF p_business_event_id <> wms_device_integration_pvt.wms_be_rfid_error THEN
      IF (l_debug = 1) THEN
	 trace(' generate_xml_csv_api: Calling populate_history');
      END IF;

      trace('before calling populate_hist');


      populate_history(p_device_id);

   END IF;

   COMMIT;

   IF (l_debug = 1) THEN
      trace(' generate_xml_csv_api: Returning::'||x_return_status);
   END IF;

EXCEPTION

   WHEN others THEN
      x_return_status := 'E';
      ROLLBACK TO generate_xml_csv_sp;
      IF (l_debug = 1) THEN
         trace('Other error in  generate_xml_csv_api');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END generate_xml_csv_api;




FUNCTION  is_last_lpn_load(p_lpn_id IN NUMBER)
  RETURN NUMBER

  IS
     --x_is_last_lpn ::
     --0 : can't find/Error
     --1 : NO
     --2 : Yes, for the delivery
     --3 : Yes, for the trip;
     l_trip_id NUMBER;
     l_delivery_id NUMBER;
     x_is_last_lpn NUMBER;
     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      trace('Inside is_last_lpn_load');
   END IF;

   --defaulting it to be NOT the last one
   x_is_last_lpn := 1;

   --get the delivery_id
   -- After staging and before Truck Load, there might not be any delivery attached to the LPN
 begin
    select distinct wda.delivery_id INTO l_delivery_id
      from wsh_delivery_details wdd, wsh_delivery_assignments_v wda, wms_license_plate_numbers lpn,
      wsh_delivery_details wdd2
      where lpn.outermost_lpn_id = p_lpn_id
      and wdd2.lpn_id = lpn.lpn_id
      and wdd2.lpn_id is not null
	and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
	and wdd.delivery_detail_id = wda.delivery_detail_id;
 EXCEPTION
    WHEN no_data_found THEN
       IF (l_debug = 1) THEN
	  trace('No delivery found');
       END IF;
       x_is_last_lpn :=0;
       RETURN x_is_last_lpn;
 END;

 IF (l_debug = 1) THEN
    trace(' is_last_lpn_load: l_delivery_id::'||l_delivery_id);
 END IF;

 IF l_delivery_id IS NOT NULL THEN
    --get the trip if any associated with the delivery
    begin
       select wts.trip_id
	 into l_trip_id
	 from wsh_delivery_legs wdl, wsh_trip_stops wts
	 where wdl.delivery_id = l_delivery_id
	 and wdl.pick_up_stop_id = wts.stop_id;
    EXCEPTION
       WHEN no_data_found THEN
	  l_trip_id := NULL;
    END;

 END IF;
  IF (l_debug = 1) THEN
     trace('is_last_lpn_load: l_trip_id ::'||l_trip_id);
  END IF;

  IF l_trip_id IS NULL THEN

     IF (l_debug = 1) THEN
	trace('is_last_lpn_load: Inside l_trip_id is null');
     END IF;


    --check whether all the lines in the delivery are loaded
       begin
	  SELECT -1 INTO x_is_last_lpn FROM dual WHERE exists
	    ( select wlpn.license_plate_number --distinct wlpn.license_plate_number
	      from wsh_delivery_details wdd, wsh_delivery_assignments_v wda, wms_license_plate_numbers lpn,
	      wsh_delivery_details wdd2,wms_license_plate_numbers wlpn
	      where wdd2.delivery_detail_id = wda.parent_delivery_detail_id
	      and   wdd.delivery_detail_id = wda.delivery_detail_id
	      and   wdd2.lpn_id is not null
	      and   wdd2.lpn_id = lpn.lpn_id
	      and   lpn.outermost_lpn_id = wlpn.lpn_id
	      AND   wlpn.lpn_id <> P_LPN_ID
	      and   wlpn.lpn_context <> 9
	      and   lpn.organization_id = wdd2.organization_id
	      and   nvl(wdd.released_status,'N') = 'Y'
	      and   (wdd.inv_interfaced_flag <> 'Y' or wdd.inv_interfaced_flag is null )
	      and   wda.delivery_id = l_delivery_id
	      );



       EXCEPTION
	  WHEN no_data_found THEN
	     x_is_last_lpn := 2;

       END;

       IF x_is_last_lpn <> -1 THEN
	  x_is_last_lpn := 2; --last LPN to be loaded for the delivery
       END IF;

   ELSE
	     IF (l_debug = 1) THEN
		trace('is_last_lpn_load: Inside l_trip_id is NOT null');
	     END IF;
	     --get all the lines of the all deliveries in the trip are loaded
     begin

	SELECT -1 INTO x_is_last_lpn FROM dual WHERE exists
	  (
	   select wlpn.license_plate_number --distinct wlpn.license_plate_number
	   from
	   wms_license_plate_numbers lpn,
	   wms_license_plate_numbers wlpn,
	   wsh_new_deliveries wnd,
	   wsh_delivery_legs wdl,
	   wsh_delivery_details wdd,
	   wsh_delivery_assignments_v wda,
	   wsh_delivery_details wdd2,
	   wsh_trip_stops pickup_stop,
	   wsh_trip_stops dropoff_stop
	   where pickup_stop.trip_id = l_trip_id
	   and  wdl.pick_up_stop_id = pickup_stop.stop_id
	   and   wdl.drop_off_stop_id = dropoff_stop.stop_id
	   and   pickup_stop.trip_id = dropoff_stop.trip_id
	   and  wdl.delivery_id = wnd.delivery_id
	   and wnd.status_code in ('OP', 'PA')
	   and wnd.delivery_id = wda.delivery_id
	   and wdd.delivery_detail_id = wda.delivery_detail_id
	   and wdd2.delivery_detail_id = wda.parent_delivery_detail_id
	   and wdd2.lpn_id is not null
	   and wdd2.lpn_id = lpn.lpn_id
	   and lpn.outermost_lpn_id = wlpn.lpn_id
	   AND   wlpn.lpn_id <> P_LPN_ID
	   and wlpn.lpn_context <> 9
	     and wdd.released_status = 'Y'
	     and (wdd.inv_interfaced_flag <> 'Y' )
	     );



     EXCEPTION
	WHEN no_data_found THEN
	   x_is_last_lpn := 3;
     END;


     IF x_is_last_lpn <> -1 THEN
	x_is_last_lpn := 3;  --last LPN to be loaded for the trip
     END IF;

 END IF;
 IF (l_debug = 1) THEN
    trace('returning: 2-last from deliv; 3-last for trip:: Value'|| x_is_last_lpn);
 END IF;
 RETURN x_is_last_lpn;

END;



--To find out whether the device has been set up to perfomr the valid transactions
--x_out_business_event_id will return whether Truck_Load ot Truck_load_ship
procedure is_valid_txn_device(p_device_id   IN NUMBER,
			      p_lpn_context IN NUMBER,
			      p_organization_id IN NUMBER,
			      x_out_business_event_id OUT nocopy NUMBER,
			      x_valid_device_for_txn  OUT nocopy NUMBER,
			      x_verif_req OUT nocopy VARCHAR2)
  IS
     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_count NUMBER :=0;

BEGIN

   IF (l_debug = 1) THEN
      trace('Inside is_valid_txn_device');
   END IF;


   IF (p_lpn_context = wms_container_pub.lpn_context_picked OR
       p_lpn_context = wms_container_pub.lpn_context_inv) THEN

    BEGIN
       SELECT business_event_id,verification_required INTO x_out_business_event_id,x_verif_req FROM wms_bus_event_devices
	 WHERE  device_id = p_device_id
	 AND ENABLED_FLAG = 'Y'
	 AND organization_id = p_organization_id
	 AND (business_event_id = wms_device_integration_pvt.wms_be_truck_load
	      OR  business_event_id = wms_device_integration_pvt.wms_be_truck_load_ship);

       x_valid_device_for_txn := 1;

    EXCEPTION
       WHEN no_data_found THEN
	  x_valid_device_for_txn := 0;
       WHEN too_many_rows THEN
	  --Must be a unique record in the organization
	  --return error, can not have both bus event Truck Load as well as Truck Load and ship
	  x_valid_device_for_txn := -1;
    END;


    ELSIF (p_lpn_context = wms_container_pub.lpn_context_intransit OR p_lpn_context = wms_container_pub.lpn_context_vendor) THEN

          BEGIN
	     SELECT business_event_id,verification_required INTO x_out_business_event_id,X_VERIF_REQ FROM wms_bus_event_devices
	       WHERE  device_id = p_device_id
	       AND ENABLED_FLAG = 'Y'
	       AND organization_id = p_organization_id
	       AND business_event_id IN
	       (wms_device_integration_pvt.wms_be_std_insp_receipt,wms_device_integration_pvt.wms_be_direct_receipt);

	     x_valid_device_for_txn := 1;

	  EXCEPTION
	     WHEN no_data_found THEN
		x_valid_device_for_txn := 0;
	     WHEN too_many_rows THEN
		--Must be a unique record in this organization
		--return error, can not have both bus event direct rcv as well
		--as std/insp associated WITH the same device
		x_valid_device_for_txn := -2;
	  END;

    ELSE --Invalid LPN context
		x_valid_device_for_txn :=  -3;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_valid_device_for_txn := -999;
      IF (l_debug = 1) THEN
         trace('Other errror: is_valid_txn_device');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END;


 -- Here if we find missing LPNs, We do not return, rather we unassign these
 --missing lines from the delivery
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
                               x_deli_count OUT NOCOPY NUMBER)
  IS

 cursor delivery_for_trip is
    select distinct delivery_id
    from WMS_SHIPPING_TRANSACTION_TEMP
    where organization_id = p_organization_id
      and dock_door_id = p_dock_door_id
      and trip_id = p_trip_id;

    cursor delivery_for_dock is
    select distinct delivery_id
    from WMS_SHIPPING_TRANSACTION_TEMP
    where organization_id = p_organization_id
      and dock_door_id = p_dock_door_id
      and dock_appoint_flag = 'N';

   l_missing_exists  NUMBER;
   l_return_status VARCHAR2(1);
   l_error_msg   VARCHAR2(240);
   l_delivery_id   NUMBER;
   l_dock_appoint_flag VARCHAR2(1);
   temp_val   NUMBER;
   l_subinventory_code VARCHAR2(30);
   l_license_plate_number VARCHAR2(30);
   l_lpn_id NUMBER ;
   l_delivery_detail_id NUMBER;
   l_locator_id NUMBER;
   l_concatenated_segments VARCHAR2(120);
   l_del_name VARCHAR2(30);


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


BEGIN
   IF (l_debug = 1) THEN
      trace('Inside CHECK_LPN_DELIVERIES::'||p_trip_id ||'::'|| p_organization_id ||'::'|| p_dock_door_id||'::'||p_outermost_lpn_id||'::'||p_delivery_id);
   END IF;

   x_error_code := 0;

   -- check if there is anything loaded
   --RFID does not care about dock-appointment, if there is LPN just ship
   --it, so passing  p_dock_appoint_flag = 'N'
   if (wms_shipping_transaction_pub.is_loaded(p_organization_id,p_dock_door_id,'N') = 'N') then
      x_error_code := 5;
      return;
   end if;

   -- check missing item first
   IF (l_debug = 1) THEN
      trace('CHECK_LPN_DELIVERIES: Checking missing items');
   END IF;
   wms_shipping_transaction_pub.MISSING_ITEM_CHECK( x_missing_item,
						    p_trip_id,
						    p_dock_door_id,
						    p_organization_id,
						    l_missing_exists);
   if (l_missing_exists > 0) then
      x_error_code := 1;
      return;
   end if;


   -- check ship set
   wms_shipping_transaction_pub.SHIP_SET_CHECK(p_trip_id,
					       p_dock_door_id,
					       p_organization_id,
					       x_ship_set,
					       l_return_status,
					       l_error_msg);
   if l_return_status = 'E' then
      x_error_code := 3;
      return;
   end if;


    -- check missing LPNs
    IF (l_debug = 1) THEN
       trace('CHECK_LPN_DELIVERIES: Checking missing LPNs');
    END IF;
    wms_shipping_transaction_pub.MISSING_LPN_CHECK( x_missing_lpns,
						    p_trip_id,
						    p_dock_door_id,
						    p_organization_id,
						    l_missing_exists);
    if (l_missing_exists > 0) then
       --x_error_code := 2;
       --return; do not return, Rather unassign these lines from the delivery

       IF (l_debug = 1) THEN

	  trace('CHECK_LPN_DELIVERIES : Unassigning LPNs that are not loaded to the truck');
	  trace('CHECK_LPN_DELIVERIES :l_license_plate_number::l_lpn_id::l_delivery_detail_id');
       END IF;

       LOOP

	  FETCH x_missing_lpns INTO
	    l_license_plate_number,l_lpn_id,l_delivery_detail_id,
	    l_subinventory_code, l_locator_id, l_concatenated_segments,l_del_name;
	  EXIT WHEN x_missing_lpns%NOTFOUND;

	  IF (l_debug = 1) THEN
	     trace('CHECK_LPN_DELIVERIES :unassigning delivery'||l_license_plate_number||'::'||l_lpn_id||'::'||l_delivery_detail_id);
	  END IF;

	  WMS_SHIPPING_TRANSACTION_PUB.unassign_delivery_line
	    (p_delivery_detail_id =>l_delivery_detail_id,
	     x_return_status => l_return_status,
	     p_commit_flag   =>  fnd_api.g_true --Committed
	     );

       END LOOP;


    END IF;

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

   -- create delivery for LPNs without delivery
   l_return_status := 'S';
   if p_trip_id = 0 then
      wms_shipping_transaction_pub.CREATE_DELIVERY(p_outermost_lpn_id,
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
   end if;

   if p_delivery_id >0 then l_delivery_id := p_delivery_id;
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

   x_deli_count := 0;
   if p_trip_id >0 then
      select count(distinct delivery_id)
	into x_deli_count
	from WMS_SHIPPING_TRANSACTION_TEMP
	where organization_id = p_organization_id
	and dock_door_id = p_dock_door_id
	and trip_id = p_trip_id;
    else
      select count(distinct delivery_id)
	into x_deli_count
    from WMS_SHIPPING_TRANSACTION_TEMP
	where organization_id = p_organization_id
	and dock_door_id = p_dock_door_id
	and dock_appoint_flag = 'N';
   end if;

   -- Query the delivery
    wms_shipping_transaction_pub.get_delivery_info(x_delivery_info,
                     l_delivery_id);


EXCEPTION
   WHEN OTHERS THEN
      x_error_code := 9999;

      IF x_missing_lpns%isopen  then
	 CLOSE x_missing_lpns;
      END IF;

END CHECK_LPN_DELIVERIES;


/* To process Normal Truck Load Txn */
procedure process_normal_truck_load(p_lpn_id IN NUMBER,
				    p_org_id IN NUMBER,
				    p_dock_door_id IN NUMBER,
				    x_is_last_lpn_load OUT nocopy NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2)
  IS
   l_error_code  NUMBER;
   l_outermost_lpn_id NUMBER;
   l_outermost_lpn varchar2(30);
   l_parent_lpn_id NUMBER;
   l_parent_lpn varchar2(30);
   l_inventory_item_id NUMBER;
   l_quantity NUMBER;
   l_requested_quantity NUMBER;
   l_delivery_detail_id NUMBER;
   l_transaction_Temp_id NUMBER;
   l_item_name varchar2(50);
   l_subinventory_code varchar2(30);
   l_revision varchar2(1);
   l_locator_id NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number varchar2(80);
   l_loaded_dock_door varchar2(50);
   l_delivery_name varchar2(50);
   l_trip_name varchar2(50);
   l_delivery_detail_ids varchar2(50);
   l_serial_at_issue NUMBER;
   l_is_last_lpn_load NUMBER;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(250);
   l_catch_wt_check NUMBER;
   l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   --l_return_status varchar2;
BEGIN
   IF (l_debug = 1) THEN
      trace('Inside process_normal_truck_load');
   END IF;

   X_return_status := 'S';

   --Check that for all items in the LPN, either catch weights are
   --defaulted OR defaulting is enabled so that shipping can default them
   --if the following api returns 0 it is fine


   l_catch_wt_check := WMS_CATCH_WEIGHT_PVT.Check_LPN_Secondary_Quantity
     ( p_api_version      => 1.0
       , x_return_status  => x_return_status
       , x_msg_count      => l_msg_COUNT
       , x_msg_data       => l_msg_DATA
       , p_organization_id  => p_org_id
       , p_outermost_lpn_id =>  p_lpn_id
       );


   IF (l_debug = 1) THEN
      trace('Check for catch wt: l_catch_wt_check :: '|| l_catch_wt_check||'::return_status::'||x_return_status);
   END IF;


   IF l_catch_wt_check <> 0 THEN
      IF (l_debug = 1) THEN
	 trace('catch wt validation failed');
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CTWT_DEFAULT_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

     --make sure that the LPN does not have any Serial item which is defined as
     --"Serials at SO issue
     begin
	SELECT 1 INTO l_serial_at_issue FROM dual WHERE exists
	  (SELECT wlpn.lpn_id
	   FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn, mtl_system_items msi
	   WHERE wlpn.lpn_id = wlc.parent_lpn_id
	   AND msi.inventory_item_id = wlc.inventory_item_id
	   AND msi.organization_id = wlc.organization_id
	   and wlc.organization_id = p_org_id
	   AND MSI.SERIAL_NUMBER_CONTROL_CODE = 6
	   AND wlpn.outermost_lpn_id = p_lpn_id
	   AND wlpn.organization_id = p_org_id
	   );
     EXCEPTION
	WHEN no_data_found THEN
	   l_serial_at_issue := 0;
     END;


     --l_serial_at_issue := 0;
     IF (l_debug = 1) THEN
	trace('l_serial_at_issue::'||l_serial_at_issue);
     END IF;


     IF l_serial_at_issue = 1 THEN
	-- it should return error not possible to process through RFID Txn
	IF (l_debug = 1) THEN
	   trace('Error: LPN contains Serials at SO Issue');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_SERIAL_ISSUE');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;

     END IF;


     IF (l_debug = 1) THEN
	trace('Calling WMS_SHIPPING_TRANSACTION_PUB.LPN_SUBMIT');
     END IF;
     -- Load the LPN on the dock door
     -- this call commits inside

     WMS_SHIPPING_TRANSACTION_PUB.LPN_SUBMIT
       ( p_outermost_lpn_id  => p_lpn_id,--Outermost LPN only
	 p_trip_id           => 0,--equivalent to LPN Ship Page
	 p_organization_id   => p_org_id,
	 p_dock_door_id      => p_dock_door_id,
	 x_error_code        => l_error_code, --out
	 x_outermost_lpn     => l_outermost_lpn,
	 x_outermost_lpn_id  => l_outermost_lpn_id,
	 x_parent_lpn_id     => l_parent_lpn_id,
	 x_parent_lpn        => l_parent_lpn,
	 x_inventory_item_id => l_inventory_item_id,
	 x_quantity          => l_quantity,
	 x_requested_quantity  => l_requested_quantity ,
	 x_delivery_detail_id  => l_delivery_detail_id,
	 x_transaction_Temp_id => l_transaction_Temp_id,
	 x_item_name           => l_item_name,
	 x_subinventory_code   => l_subinventory_code,
	 x_revision            => l_revision,
	 x_locator_id          => l_locator_id,
	 x_lot_number          => l_lot_number,
	 x_loaded_dock_door    => l_loaded_dock_door,
	 x_delivery_name       => l_delivery_name,
	 x_trip_name           => l_trip_name ,
	 x_delivery_detail_ids => l_delivery_detail_ids,
         p_is_rfid_call    =>     'Y'
       );



     IF (l_debug = 1) THEN
	trace('value of l_error_code :'|| l_error_code);
     END IF;

     IF l_error_code <> 0 AND l_error_code <> 6 THEN--l_error_code <> 6 because RFID does not
	   --care about dock appointment, if LPN is there process it

	x_return_status := 'E';

	IF l_error_code = 5  THEN

	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LPN_OTH_DOCK');
	   FND_MESSAGE.SET_TOKEN('DOCK', l_loaded_dock_door);
	   FND_MSG_PUB.ADD;
	 else
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_TRUCK_LOAD_FAIL');
	   FND_MSG_PUB.ADD;
	END IF;

	RAISE FND_API.G_EXC_ERROR;

      ELSE

	IF (l_debug = 1) THEN
	   trace('call to LPN_SUBMIT success: Checking whether it is last LPN');
	END IF;

	--Load_SHIP will use the value of l_is_last_lpn_load to know
	--whether TO call ship confirm.
	l_is_last_lpn_load := is_last_lpn_load(p_lpn_id);


	--Setting mesg for last lpn
	IF  l_is_last_lpn_load  = 2 THEN
	   IF (l_debug = 1) THEN
	      trace('last LPN to be loaded for delivery');
	   END IF;
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LAST_LPN_DELIVERY');
	   FND_MSG_PUB.ADD;
	 ELSIF l_is_last_lpn_load = 3 THEN
	   IF (l_debug = 1) THEN
	      trace('last LPN to be loaded for trip');
	   END IF;
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LAST_LPN_TRIP');
	   FND_MSG_PUB.ADD;
	 ELSE
	   IF (l_debug = 1) THEN
	      trace('Truck Load Successful');
	   END IF;
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_TRUCK_LOAD_SUCCESS');
	   FND_MSG_PUB.ADD;

	END IF;

     END IF;

     x_is_last_lpn_load := l_is_last_lpn_load;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      x_is_last_lpn_load := 0;
      IF (l_debug = 1) THEN
         trace('Other errror: process_normal_truck_load');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END process_normal_truck_load;



/* To process Normal Truck Load and ship Txn */
procedure process_normal_truck_load_ship(p_lpn_id IN NUMBER,
					 p_org_id IN NUMBER,
					 p_dock_door_id IN NUMBER,
					 x_return_status OUT NOCOPY VARCHAR2)

  IS
   l_error_code  NUMBER;
   l_msg_data VARCHAR2(2000);
   l_return_status varchar2(1);
   l_missing_item t_genref;
   l_missing_lpns  t_genref;
   l_ship_set VARCHAR2(30);
   l_delivery_info t_genref;
   l_deli_count NUMBER;
   l_msg_count NUMBER;
   l_trip_id NUMBER;
   l_is_last_lpn_load NUMBER;
   l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
     trace('Inside process_normal_truck_load_ship');
   END IF;
x_return_status := FND_API.g_ret_sts_success;


--First Load the LPN
process_normal_truck_load(p_lpn_id             => p_lpn_id,
			  p_org_id             => p_org_id,
			  p_dock_door_id       => p_dock_door_id,
			  x_is_last_lpn_load   => l_is_last_lpn_load,
			  x_return_status      => l_return_status);


IF l_return_status IS NULL OR l_return_status = 'E' OR l_return_status = 'U' THEN
   IF (l_debug = 1) THEN
      trace('process_normal_truck_load_ship: Truck load failed');
   END IF;
   RAISE FND_API.G_EXC_ERROR;

 ELSE

   IF (l_debug = 1) THEN
      trace('process_normal_truck_load_ship: Truck Load Successful');
   END IF;


   --Checking whether the last LPN for delivery or Trip (if exists)

   IF l_is_last_lpn_load IN (2,3) THEN
      IF (l_debug = 1) THEN
	 trace('Last LPN in the trip or delivery: Calling ship confirm');
      END IF;

       WMS_SHIPPING_TRANSACTION_PUB.close_truck
	( P_dock_door_id    => p_dock_door_id,
	  P_organization_id => p_org_id,
	  p_shipping_mode   => 'NORMAL',
	  p_commit_flag     => fnd_api.g_false,
	  x_return_status   => l_return_status,
	  x_return_msg      => l_msg_data
	  );


      IF (l_debug = 1) THEN
	 trace('process_normal_truck_load_ship: l_return_status ::' ||l_return_status);
      END IF;

      l_ship_confirm_pkg_mesg := substr(l_msg_data,1,240);

      if x_return_status in ('S','W') THEN

	 COMMIT;
	 IF (l_debug = 1) THEN
	    trace('process_normal_truck_load_ship return Success/Warning: Commit Done');
	 END IF;
       ELSE
	 RAISE FND_API.G_EXC_ERROR;
      END IF;


    ELSE
      IF (l_debug = 1) THEN
	 trace('process_normal_truck_load_ship: Not the last LPN in the trip or delivery:So DO not Ship Confirm');

	 l_ship_confirm_pkg_mesg :=fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');

      END IF;

   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other errror: process_normal_truck_load_ship');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END process_normal_truck_load_ship;


PROCEDURE  process_direct_truck_load( p_lpn_id IN NUMBER,
				      p_org_id IN NUMBER,
				      p_dock_door_id IN NUMBER,
				      x_is_last_lpn_load OUT nocopy NUMBER,
				      x_return_status OUT NOCOPY VARCHAR2)
  IS

     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(250);
     l_remaining_qty NUMBER;
     l_is_last_lpn_load NUMBER;

     l_num_line_processed  NUMBER;
     l_project_id          NUMBER;
     l_task_id             NUMBER;
     l_cross_project_allowed   VARCHAR2(1);
     l_cross_unit_allowed      VARCHAR2(1);
     l_group_by_customer_flag  VARCHAR2(1);
     l_group_by_fob_flag       VARCHAR2(1);
     l_group_by_freight_terms_flag  VARCHAR2(1);
     l_group_by_intmed_ship_flag    VARCHAR2(1);
     l_group_by_ship_method_flag    VARCHAR2(1);
     l_group_by_ship_to_loc_value   VARCHAR2(100);
     l_group_by_ship_from_loc_value VARCHAR2(100);
     l_group_by_customer_value      VARCHAR2(100);
     l_group_by_fob_value           VARCHAR2(100);
     l_group_by_freight_terms_value VARCHAR2(100);
     l_group_by_intmed_value        VARCHAR2(100);
     l_group_by_ship_method_value   VARCHAR2(100);
     l_serial_at_issue NUMBER;
     l_ct_wt_enabled NUMBER;
     l_catch_wt_check NUMBER;
     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('Inside PROCESS_DIRECT_TRUCK_LOAD');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --Jason will provide this API
   --Check that for all items in the LPN, either catch weights are
   --defaulted OR defaulting is enabled so that shipping can default them
   --if the following api returns 0 it is fine

   l_catch_wt_check := WMS_CATCH_WEIGHT_PVT.Check_LPN_Secondary_Quantity
     ( p_api_version      => 1.0
       , x_return_status  => x_return_status
       , x_msg_count      => l_msg_count
       , x_msg_data       => l_msg_data
       , p_organization_id  => p_org_id
       , p_outermost_lpn_id =>  p_lpn_id
       );

   IF (l_debug = 1) THEN
      trace('Check for catch wt: l_catch_wt_check ::'||l_catch_wt_check||'::return_status::'||x_return_status);
     END IF;

     IF l_catch_wt_check <> 0 THEN
      IF (l_debug = 1) THEN
	 trace('catch wt validation failed');
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CTWT_DEFAULT_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   --make sure that the LPN does not have any Serial item which is defined as
   --"Serials at SO issue
     begin
	SELECT 1 INTO l_serial_at_issue FROM dual WHERE exists
	  (SELECT wlpn.lpn_id
	   FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn, mtl_system_items msi
	   WHERE wlpn.lpn_id = wlc.parent_lpn_id
	   AND msi.inventory_item_id = wlc.inventory_item_id
	   AND msi.organization_id = wlc.organization_id
	   and wlc.organization_id = p_org_id
	   AND MSI.SERIAL_NUMBER_CONTROL_CODE = 6 --Serials at SO issue
	   AND wlpn.outermost_lpn_id = p_lpn_id
	   AND wlpn.organization_id = p_org_id
	   );
     EXCEPTION
	WHEN no_data_found THEN
	   l_serial_at_issue := 0;
     END;

     --l_serial_at_issue := 0;
     IF (l_debug = 1) THEN
	trace('l_serial_at_issue::'||l_serial_at_issue);
     END IF;


     IF l_serial_at_issue = 1 THEN
	-- it should return error not possible to process through RFID Txn
	IF (l_debug = 1) THEN
	   trace('Error: LPN contains Serials at SO Issue');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_SERIAL_ISSUE');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;

     END IF;


     IF (l_debug = 1) THEN
	trace('Processing direct truck load');
     END IF;


     INV_PROJECT.SET_SESSION_PARAMETERS(l_return_status,l_msg_count,l_msg_data,p_org_id);

     IF (l_debug = 1) THEN
	trace('after setting::'||l_return_status||':'||l_msg_data||':'||l_msg_count);
	trace('calling wms_direct_ship_pvt.process_lpn');
     END IF;


     -- Load the LPN on the dock door
     wms_direct_ship_pvt.process_lpn
	(p_lpn_id                => p_lpn_id,
	 p_org_id                => p_org_id,
	 p_dock_door_id          => p_dock_door_id,
	 x_remaining_qty         => l_remaining_qty,
	 x_num_line_processed    => l_num_line_processed,
	 x_project_id            => l_project_id,
	 x_task_id               => l_task_id,
	 x_cross_project_allowed  => l_cross_project_allowed,
	 x_cross_unit_allowed     => l_cross_unit_allowed,
	 x_group_by_customer_flag => l_group_by_customer_flag,
	 x_group_by_fob_flag      => l_group_by_fob_flag,
	 x_group_by_freight_terms_flag  => l_group_by_freight_terms_flag,
	 x_group_by_intmed_ship_flag    => l_group_by_intmed_ship_flag,
	 x_group_by_ship_method_flag    => l_group_by_ship_method_flag,
	 x_group_by_ship_to_loc_value   => l_group_by_ship_to_loc_value,
	 x_group_by_ship_from_loc_value => l_group_by_ship_from_loc_value,
	 x_group_by_customer_value      => l_group_by_customer_value,
	 x_group_by_fob_value           => l_group_by_fob_value,
	 x_group_by_freight_terms_value => l_group_by_freight_terms_value,
	 x_group_by_intmed_value        => l_group_by_intmed_value,
	 x_group_by_ship_method_value   => l_group_by_ship_method_value,
         x_ct_wt_enabled                => l_ct_wt_enabled,
         x_return_status                => l_return_status,
	 x_msg_count                    => l_msg_data,
	 x_msg_data                     => l_msg_count
	);

     IF (l_debug = 1) THEN
	trace('Process_lpn returned l_return_status::l_remaining_qty::'||l_return_status||'::'||l_remaining_qty);
     END IF;

     IF l_return_status IS NULL OR  l_return_status = 'E'  OR
       l_return_status = 'U' THEN
	FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_TRUCK_LOAD_FAIL');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;

      ELSE

	if l_remaining_qty <> 0 then
	   --LPN should be totally consumed for RFID transactions,so fail the transaction
	   IF (l_debug = 1) THEN
	      trace('ERROR: LPN not Totally Consumed');
	   END IF;
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LPN_NOT_CONSUMED');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;

	 else
	   IF (l_debug = 1) THEN
	      trace('Load the LPN');
	   END IF;

	   wms_direct_ship_pvt.Load_LPN
	     ( x_return_status => l_return_status,
	       x_msg_count     => l_msg_count,
	       x_msg_data      => l_msg_data,
	       p_lpn_id        => p_lpn_id,
	       p_org_id        => p_org_id,
	       p_dock_door_id  => p_dock_door_id);

	   IF (l_debug = 1) THEN
	      trace('After Loading the LPN');
	      trace(l_group_by_ship_method_value||':'||l_return_status||':'||l_msg_data||':'||l_msg_count);
	   END IF;

	   IF l_return_status IS NULL OR  l_return_status = 'E'  OR
	     l_return_status = 'U' THEN
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_TRUCK_LOAD_FAIL');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;

	    ELSE
	      IF (l_debug = 1) THEN
		 trace('Load LPN success: Checking whether the last LPN for truck Load only');
	      END IF;

	      --check it only for Truck Load Business event and not for Load_SHIP
	      l_is_last_lpn_load := is_last_lpn_load(p_lpn_id);

	      IF  l_is_last_lpn_load  = 2 THEN
		 IF (l_debug = 1) THEN
		    trace('last LPN to be loaded for delivery');
		 END IF;

		 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LAST_LPN_DELIVERY');
		 FND_MSG_PUB.ADD;
	       ELSIF l_is_last_lpn_load = 3 THEN
		 IF (l_debug = 1) THEN
		    trace('last LPN to be loaded for trip');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_LAST_LPN_TRIP');
		 FND_MSG_PUB.ADD;
	       ELSE
		 IF (l_debug = 1) THEN
		    trace('Truck Load Successful');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_TRUCK_LOAD_SUCCESS');
		 FND_MSG_PUB.ADD;

	      END IF;

	      --Must Commit here
	      Commit;

	   END IF;--success from Load_LPN

	END IF;--l_remaining_qty <> 0

     END IF;--for Process_lpn success

     x_is_last_lpn_load :=  l_is_last_lpn_load;

exception
   when OTHERS then
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other errror: process_direct_truck_load');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END process_direct_truck_load;



PROCEDURE  process_direct_truck_load_ship( p_lpn_id IN NUMBER,
					   p_org_id IN NUMBER,
					   p_dock_door_id IN NUMBER,
					   x_return_status OUT NOCOPY VARCHAR2)
  IS
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     l_delivery_id NUMBER;
     l_trip_id NUMBER;
     l_error_code NUMBER;
     l_vehicle_item_id NUMBER;
     l_vehicle_num_prefix VARCHAR2(30);
     l_vehicle_num        VARCHAR2(30);
     l_seal_code          VARCHAR2(30);
     l_document_set_id  NUMBER;
     l_missing_item_cur t_genref;

     l_is_last_lpn_load NUMBER;

     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
   IF (l_debug = 1) THEN
      trace('Inside process_direct_truck_load_ship');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   process_direct_truck_load( p_lpn_id => p_lpn_id,
			      p_org_id => p_org_id,
			      p_dock_door_id  => p_dock_door_id,
			      x_is_last_lpn_load => l_is_last_lpn_load,
			      x_return_status => l_return_status);


   IF (l_debug = 1) THEN
      trace('After calling process_direct_truck_load l_return_status::'||l_return_status);
   END IF;

   IF l_return_status IS NULL OR l_return_status = 'E' OR l_return_status ='U' THEN

      RAISE FND_API.G_EXC_ERROR;
      IF (l_debug = 1) THEN
	 trace('process_direct_truck_load_ship::Truck Load failed');
      END IF;

    ELSE

      IF (l_debug = 1) THEN
	 trace('Inside process_direct_truck_load_ship:: Truck Load Successful');
      END IF;


      --Checking whether the last LPN for delivery or Trip (if exists)

      IF l_is_last_lpn_load IN (2,3) THEN
	 IF (l_debug = 1) THEN
	    trace('Last LPN in the trip or delivery: Calling ship confirm');
	 END IF;

	  WMS_SHIPPING_TRANSACTION_PUB.close_truck
	   ( P_dock_door_id    => p_dock_door_id,
	     P_organization_id => p_org_id,
	     p_shipping_mode   => 'DIRECT',
	     p_commit_flag     => fnd_api.g_false,
	     x_return_status   => l_return_status,
	     x_return_msg      => l_msg_data
	     );

	  IF (l_debug = 1) THEN
	     trace('process_direct_truck_load_ship l_return_status :'||l_return_status);
	  END IF;

	  fnd_msg_pub.Count_And_Get
	    (p_encoded	=> FND_API.g_false,
	     p_count => l_msg_count,
	     p_data => l_msg_data
	     );

	  IF l_msg_count > 1 THEN
	     FOR i IN 1..l_msg_count LOOP
		l_ship_confirm_pkg_mesg := substr((l_msg_data || '|' || FND_MSG_PUB.GET(p_msg_index => l_msg_count - i + 1,	p_encoded	=> FND_API.g_false)),1,240);
	     END LOOP;
	   ELSE

	     l_ship_confirm_pkg_mesg :=substr(l_msg_data,1,240);

	  END IF;

	  fnd_msg_pub.delete_msg;


	  IF (l_debug = 1) THEN
	     trace('process_direct_truck_load_ship SHP_msg_data ::'||l_ship_confirm_pkg_mesg);
	  END IF;

	  if x_return_status in ('S','W') THEN

	     COMMIT;

	     IF (l_debug = 1) THEN
		trace('process_direct_truck_load_ship return Success/Warning: Commit Done');
	     END IF;

	     --do not need to update the msg here, it is already in the stack
	     --l_msg_data is returned as nulll

	  END IF;

       ELSE
	 IF (l_debug = 1) THEN
	    trace('process_direct_truck_load_ship: Not the last LPN in the trip or delivery: DO not Ship Confirm');
	 END IF;
	 l_ship_confirm_pkg_mesg :=fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');
      END IF;

   END IF;

  exception
     when OTHERS then
	x_return_status := 'E';
	IF (l_debug = 1) THEN
	   trace('Other errror: process_direct_truck_load_ship');
	   trace('SQL error :'||substr(sqlerrm, 1, 240));
	END IF;
END process_direct_truck_load_ship;




PROCEDURE  process_rfid_receiving_txn(p_lpn_id IN NUMBER,
				      p_device_id IN NUMBER,
				      p_dest_org_id IN NUMBER,
				      p_lpn_context IN NUMBER,
				      p_routing_id IN NUMBER,
				      p_shipment_header_id IN NUMBER,
				      p_direct_putaway_sub IN VARCHAR2,
				      p_direct_putaway_loc IN NUMBER,
				      x_return_status OUT nocopy VARCHAR2)
  IS

     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(250);
     l_move_order_header_id number;
     l_lot_ser_flag VARCHAR2(1) := NULL;
     l_inspect NUMBER;
     l_shipment_header_id NUMBER := p_shipment_header_id;
     l_org_id number;
     l_org_location VARCHAR2(60);
     l_org_locator_control NUMBER;
     l_manual_po_num_type  VARCHAR2(25);
     l_wms_install_status  VARCHAR2(1);
     l_wms_purchased       VARCHAR2(1);
     l_receipt_num VARCHAR2(30);
     l_shipment_num VARCHAR2(30);
     l_source_type VARCHAR2(30);
     l_shipment_hdr_id_dummy NUMBER;
     l_vendor_id NUMBER;

     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('process_rfid_receiving_txn:l_shipment_header_id:p_routing_id:p_lpn_id:p_lpn_context');
      trace('process_rfid_receiving_txn:'||l_shipment_header_id||'::'||p_routing_id||'::'||p_lpn_id||'::'|| p_lpn_context);
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   if p_routing_id IS NOT NULL THEN

      if p_routing_id = 2 then --inspection
	 l_inspect := 1;
      end if;

      IF (l_debug = 1) THEN
	 trace('calling  inv_rcv_common_apis.init_startup_values ');
      END IF;

      inv_rcv_common_apis.init_rcv_ui_startup_values
	( p_organization_id     => p_dest_org_id, --destination_org
	  x_org_id              => l_org_id,
	  x_org_location        => l_org_location,
	  x_org_locator_control => l_org_locator_control,
          x_manual_po_num_type  => l_manual_po_num_type,
	  x_wms_install_status  => l_wms_install_status,
	  x_wms_purchased       => l_wms_purchased,
	  x_return_status       => l_return_status,
	  x_msg_data            => l_msg_data );

      IF (l_debug = 1) THEN
	 trace('process_rfid_receiving_txn:l_org_id,l_org_location,l_org_locator_control,l_return_status,l_msg_data');
	 trace(l_org_id||'::'||l_org_location||'::'||l_org_locator_control||'::'||l_return_status||'::'||l_msg_data);
      END IF;


    --`Check for lot serial flag between both org

      INV_RCV_COMMON_APIS.check_lot_serial_codes
	(
	 p_lpn_id                => p_lpn_id,
	 p_req_header_id         => null,
	 p_shipment_header_id    => l_shipment_header_id,
	 x_lot_ser_flag          => l_lot_ser_flag,
	 x_return_status         => l_return_status,
	 x_msg_count             => l_msg_count,
	 x_msg_data              => l_msg_data);
      IF (l_debug = 1) THEN
	 trace('process_rfid_receiving_txn:l_lot_ser_flag,l_return_status,l_msg_data');
	 trace(l_lot_ser_flag||'::'||l_return_status||'::'||l_msg_data);
      END IF;

      IF l_lot_ser_flag = 'N' THEN
	 IF (l_debug = 1) THEN
	    trace('l_lot_ser_flag is N');
	 END IF;

	 --Fail the transaction, it can not be performed by RFID
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_ITEM_CTRL_ERROR');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;

       ELSE
	 IF (l_debug = 1) THEN
	    trace('process_rfid_receiving_txn:l_lot_ser_code test passed');
	 END IF;

	 IF p_routing_id in (1,2) then

	    IF p_lpn_context = 6 THEN
	       l_source_type := 'REQEXP';--Internal requisition
	     ELSIF p_lpn_context = 7 THEN
	       l_source_type := 'ASNEXP';-- ASN
	    END IF;

	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: Standard routing/inspection,insert into interface TABLE');
	       trace('l_move_order_header_id :'||l_move_order_header_id);
	       trace('p_dest_org_id :'|| p_dest_org_id);
	       trace('l_shipment_header_id :'||l_shipment_header_id);
	       trace('ASN/Internal Req l_source_type'||l_source_type);
	       trace('p_lpn_id :'||p_lpn_id);
	       trace('l_inspect :'||l_inspect);
	       trace('p_direct_putaway_sub :'||p_direct_putaway_sub);
	       trace('p_direct_putaway_loc :'||p_direct_putaway_loc);
	    END IF;


	    INV_RCV_STD_RCPT_APIS.create_std_rcpt_intf_rec
	      (
	       p_move_order_header_id => l_move_order_header_id,
	       p_organization_id      => p_dest_org_id,-- destination Org
	       p_po_header_id         => null,
	       p_po_release_number_id => null,
	       p_po_line_id           => null,
	       p_shipment_header_id   => l_shipment_header_id,
	       p_req_header_id        => null,
	       p_oe_order_header_id   => null,
	       p_item_id              => null,
	       p_location_id          => null,--it defaults from the backend
	       p_rcv_qty              => null,
	       p_rcv_uom              => null,
	       p_rcv_uom_code         => null,
	       p_source_type          => l_source_type,
	       p_from_lpn_id          => p_lpn_id,
	       p_lpn_id               => NULL,
	       p_lot_control_code     => null,
	       p_revision             => null,
	       p_inspect              => l_inspect,
	       p_rcv_subinventory_code => p_direct_putaway_sub,
	       p_rcv_locator_id        => p_direct_putaway_loc,
	       x_status                => l_return_status,
	       x_message               => l_msg_data
	      );


	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: l_return_status, l_msg_data, l_move_order_header_id');
	       trace('process_rfid_receiving_txn:'||l_return_status||'::'||l_msg_data||'::'||l_move_order_header_id);
	    END IF;

	  elsif p_routing_id = 3  then

	    IF p_lpn_context = 6 THEN
	       l_source_type := 'REQEXP';
	     ELSIF  p_lpn_context = 7 THEN
	       l_source_type := 'ASNEXP';
	    END IF;

	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: Direct routing, insert into interface table');
	       trace('l_move_order_header_id :'||l_move_order_header_id);
	       trace('p_dest_org_id :'|| p_dest_org_id);
	       trace('l_shipment_header_id :'||l_shipment_header_id);
	       trace('ASN/Internal Req l_source_type'||l_source_type);
	       trace('p_direct_putaway_sub :'||p_direct_putaway_sub);
	       trace('p_direct_putaway_loc :'||p_direct_putaway_loc);
	       trace('p_lpn_id :'||p_lpn_id);
	    END IF;

	    inv_rcv_dir_rcpt_apis.create_direct_rti_rec
	      (
	       p_move_order_header_id => l_move_order_header_id,
	       p_organization_id      => p_dest_org_id ,-- destination Org
	       p_po_header_id         => NULL,
	       p_po_release_id        => NULL,
	       p_po_line_id           => NULL,
	       p_shipment_header_id   => l_shipment_header_id,
	       p_oe_order_header_id   => NULL,
	       p_item_id              => NULL,
	       p_rcv_qty              => NULL,
	       p_rcv_uom 	      => NULL,
	       p_rcv_uom_code 	      => NULL,
	       p_source_type 	      => l_source_type,
	       p_subinventory 	      => p_direct_putaway_sub,
	       p_locator_id 	      => p_direct_putaway_loc,
	       p_transaction_temp_id  => NULL,
	       p_lot_control_code     => NULL,
	       p_serial_control_code  => NULL,
	       p_lpn_id               => p_lpn_id,
	       p_revision             => NULL,
	       x_status               => l_return_status,
	       x_message              => l_msg_data);


	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: l_return_status, l_msg_data, l_move_order_header_id');
	       trace('process_rfid_receiving_txn:'||l_return_status||'::'||l_msg_data||'::'||l_move_order_header_id);
	    END IF;

	 END IF;


	 IF (l_debug = 1) THEN
	    trace('Calling rcv_gen_receipt_num');
	 END IF;

	 inv_rcv_common_apis.rcv_gen_receipt_num(
						 x_receipt_num     => l_receipt_num,
						 p_organization_id => p_dest_org_id,--destination Org
						 x_return_status   => l_return_status,
						 x_msg_count       => l_msg_count,
						 x_msg_data        => l_msg_data);

	 IF (l_debug = 1) THEN
	    trace('process_rfid_receiving_txn: l_receipt_num,l_return_status, l_msg_data, l_msg_count');
	    trace('process_rfid_receiving_txn:'||l_receipt_num||'::'||l_return_status||'::'||l_msg_data||'::'||l_msg_count);
	 END IF;

	 IF l_return_status IS NULL OR l_return_status = 'E' THEN

	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: Error: Rcpt generation failed');
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;

	  ELSE

	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: Calling rcv_insert_update_header');
	    END IF;

	    IF p_lpn_context = 6 THEN
	       l_source_type :='INTERNAL ORDER';--Internal requisition
	     ELSIF p_lpn_context = 7 THEN
	       l_source_type := 'VENDOR';--ASN
	    END IF;

	    SELECT shipment_num,vendor_id
	      INTO l_shipment_num,l_vendor_id
	      FROM rcv_shipment_headers
	      WHERE shipment_header_id = l_shipment_header_id;

	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: ASN/Inernal req l_source_type'|| l_source_type);
	       trace('p_dest_org_id :'||p_dest_org_id);
	       trace('l_source_type :'||l_source_type);
	       trace('l_receipt_num :'||l_receipt_num);
	       trace('l_shipment_num :'||l_shipment_num);
	       trace('l_vendor_id    :'||l_vendor_id);
	    END IF;

	    l_shipment_hdr_id_dummy := NULL;

	    INV_RCV_STD_RCPT_APIS.rcv_insert_update_header
	      (p_organization_id        => p_dest_org_id, --destination Org ,
	       p_shipment_header_id     => l_shipment_hdr_id_dummy,  --IN OUT parameter
	       p_source_type            => l_source_type,
	       p_receipt_num            => l_receipt_num,
	       p_vendor_id              => l_vendor_id,
	       p_vendor_site_id         => null,
	       p_shipment_num           => l_shipment_num,
	       p_ship_to_location_id    => null,
	       p_bill_of_lading         => null,
	       p_packing_slip           => null,
	       p_shipped_date           => null,
	       p_freight_carrier_code   => null,
	       p_expected_receipt_date  => null,
	       p_num_of_containers      => null,
	       p_waybill_airbill_num    => null,
	       p_comments               => null,
	       p_ussgl_transaction_code => null,
	       p_government_context     => null,
	       p_request_id             => null,
	       p_program_application_id => null,
	       p_program_id             => null,
	       p_program_update_date    => null,
	      p_customer_id            => null,
	      p_customer_site_id       => null,
	      x_return_status       => l_return_status,
	      x_msg_count           => l_msg_count,
	      x_msg_data            => l_msg_data
	      );



	    IF (l_debug = 1) THEN
	       trace('process_rfid_receiving_txn: l_return_status,l_msg_data::'||l_return_status||'::'||l_msg_data);
	    END IF;

	    if l_return_status IS NULL OR l_return_status = 'E' THEN

	       IF (l_debug = 1) THEN
		  trace('process_rfid_receiving_txn: Error: rcv_insert_update_header failed');
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;

	     ELSE

	       IF (l_debug = 1) THEN
		  trace('process_rfid_receiving_txn: Calling RCV TM');
	       END IF;


	       INV_RCV_MOBILE_PROCESS_TXN.rcv_process_receive_txn
		 ( x_return_status => l_return_status,
		   x_msg_data      => l_msg_data
		   );


	       IF (l_debug = 1) THEN
		  trace('process_rfid_receiving_txn: l_return_status, l_msg_data::'||l_return_status||'::'||l_msg_data);
	       END IF;

	       inv_rcv_common_apis.rcv_clear_global;

	       IF l_return_status = 'S' THEN
		  FND_MESSAGE.SET_NAME('WMS', 'WMS_TXN_SUCCESS');
		  FND_MSG_PUB.ADD;
	       END IF;

	       x_return_status := l_return_status;

	    end if;--INSERT UPDATE HEADR

	 END IF; --RCPT GENERATION

      end if; --l_lot_ser_flag

   end if; --p_routing_id is not null

   IF (l_debug = 1) THEN
      trace('RETURNING::'||x_return_status);
   END IF;

exception
   when OTHERS THEN
      IF l_lot_ser_flag = 'N' THEN --return other status to avoid overwrite
	 --OF standard RCV failure mesg
	 x_return_status := 'N';
       ELSE
	 x_return_status := 'E';
      END IF;

      IF (l_debug = 1) THEN
         trace('Other errror: process_rfid_receiving_txn');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END process_rfid_receiving_txn;



PROCEDURE parse_read_tags(p_tagid              IN      WMS_EPC_TAGID_TYPE,
			  p_org_id             IN      NUMBER,
			  x_tag_info           OUT     nocopy tag_info_tbl,
			  x_pallet_lpn_id      OUT     nocopy NUMBER,
			  x_pallet_lpn_context OUT     nocopy NUMBER,
			  x_tag_count          OUT     nocopy NUMBER,
			  x_return_status      out     nocopy VARCHAR2)  --S/E
  IS


     l_PARENT_lpn_id NUMBER;
     --l_tag_info tag_info_tbl;
     l_index NUMBER;
     l_parent_row_id NUMBER;
     L_pallet_lpn_context NUMBER;
     l_outermost_lpn_id  NUMBER;
     l_is_error NUMBER := 0;
     l_prev_serial_pallet_id NUMBER;
     l_serial_pallet_id NUMBER;
     l_lpn_pallet_id NUMBER;
     l_prev_lpn_pallet_id NUMBER;
     l_gtin NUMBER;
     l_gtin_serial NUMBER;

     l_cnt NUMBER;

     l_cross_ref_type NUMBER;
     l_lpn_id NUMBER;
     l_item_id NUMBER;
     l_serial_number VARCHAR2(30);


    l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN


   x_return_status := 'S';

   IF (l_debug = 1) THEN
      trace('Inside parse_read_tags');
   END IF;

   ---get all the values from the tagid LOV  and tagdata LOV


   IF p_tagid IS NOT null THEN

      l_index := 1;

      IF (l_debug = 1) THEN
	 trace('Get all values of the EPC tags ######');
      END IF;

      FOR i IN p_tagid.FIRST .. p_tagid.LAST
	LOOP
	   IF (l_debug = 1) THEN
	      trace('Tag values = ' || p_tagid(i));
	   END IF;

	   x_tag_info(l_index).tag_id := to_CHAR(Ltrim(Rtrim(p_tagid(i))));
	   l_index :=    l_index +1;

	END LOOP;

	--Return the tag count
	x_tag_count := x_tag_info.COUNT;

	IF (l_debug = 1) THEN
	   trace (' x_tag_count :'|| x_tag_count);
	END IF;



	IF x_tag_count = 1 THEN

	 -- It can be LPN Name String OR EPC

         BEGIN
	    SELECT  wlpn.lpn_id,wlpn.lpn_context,outermost_lpn_id INTO
	      x_pallet_lpn_id,x_pallet_lpn_context,l_outermost_lpn_id
	      FROM wms_license_plate_numbers wlpn,
	      wms_epc we
	      WHERE we.lpn_id = wlpn.lpn_id
	      AND we.cross_ref_type =1 --LPN-EPC type
	      AND we.epc = x_tag_info(1).tag_id
	      AND ((wlpn.parent_lpn_id = wlpn.outermost_lpn_id AND wlpn.parent_lpn_id IS NOT null) OR
		     ( wlpn.parent_lpn_id IS NULL AND wlpn.lpn_id =  wlpn.outermost_lpn_id ));

		     --process only the pallet LPN
		     IF l_outermost_lpn_id <> x_pallet_lpn_id THEN

			IF (l_debug = 1) THEN
			   trace('parse_read_tags : read EPC must be outer LPN');
			END IF;

			x_pallet_lpn_id := NULL;
			x_pallet_lpn_context := NULL;
			x_return_status    := 'E';
			FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_INNER_LPN_READ');--Already seeded
			FND_MSG_PUB.ADD;

		     END IF;


	 EXCEPTION
	    WHEN no_data_found THEN

	       --this value is not in the the cross reference table,  try to see
	       --IF the passed value is lpn name string instead

                BEGIN
		   SELECT  wlpn.lpn_id,wlpn.lpn_context,wlpn.outermost_lpn_id INTO
		     x_pallet_lpn_id,x_pallet_lpn_context,l_outermost_lpn_id
		     FROM wms_license_plate_numbers wlpn
		     WHERE wlpn.license_plate_number  = x_tag_info(1).tag_id
		     AND ((wlpn.parent_lpn_id = wlpn.outermost_lpn_id AND wlpn.parent_lpn_id IS NOT null) OR
			  ( wlpn.parent_lpn_id IS NULL AND wlpn.lpn_id =  wlpn.outermost_lpn_id ));


		     --process only the pallet LPN
		     --Be it Shipping or Receiving only the outer LPN is needed

		     --Receiving can take inner LPN for receiving
		     --partially though, so we have TO stop it here

		     --However Shipping does not support processing inner
		     --lpn, so we have to discard those reads

		     IF l_outermost_lpn_id <> x_pallet_lpn_id THEN

			IF (l_debug = 1) THEN
			   trace('parse_read_tags : read LPN must be outer LPN');
			END IF;

			x_pallet_lpn_id := NULL;
			x_pallet_lpn_context := NULL;
			x_return_status    := 'E';
			FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_INNER_LPN_READ');
			FND_MSG_PUB.ADD;

		     END IF;

	      EXCEPTION
		 WHEN no_data_found THEN
		 x_pallet_lpn_id := NULL;
		 x_pallet_lpn_context := NULL;
		 x_return_status    := 'E';
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
		 FND_MSG_PUB.ADD;

		 RETURN;

	      END;

	 END;

       ELSE --means x_tag_count > 1
		    --Assumption: if it is coming as list of values using pallet filter from
		    --edgeserver, it has to be list of EPCs and not list of LPN Names strings

		    l_prev_serial_pallet_id := -99;
		    l_prev_lpn_pallet_id  := -99;


	   FOR i IN 1..x_tag_info.COUNT LOOP

	      --CODE LOGIC
	      --1- get the cross_ref_type and all relevant value for
	      --cross-reference from wms_epc table based on EPC
	      --2-Query respective tables to ensure that cross-referenced
	      --object IS indeed correct and get other relevant parameter values


	      BEGIN

		 SELECT cross_ref_type , lpn_id , inventory_item_id, serial_number, gtin, gtin_serial
		   INTO l_cross_ref_type , l_lpn_id , l_item_id, l_serial_number, l_gtin, l_gtin_serial
		   FROM wms_epc we
		   WHERE we.epc = x_tag_info(i).tag_id;



		 IF (l_debug = 1) THEN
		    trace('l_cross_ref_type :'||l_cross_ref_type );
		    trace('l_lpn_id        :'||l_lpn_id);
		    trace('l_item_id       :'||l_item_id );
		    trace('l_serial_number :'||l_serial_number);
		    trace('l_gtin_serial   :'||l_gtin_serial);

		 END IF;


	      EXCEPTION
		 WHEN no_data_found THEN

		    --Extraneous read, NOT a cross-referenced EPC read

		    IF (l_debug = 1) THEN
		       trace('when no data found');
		    END IF;


		    x_pallet_lpn_id := NULL;
		    x_pallet_lpn_context := NULL;
		    x_return_status    := fnd_api.g_ret_sts_error;
		    FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_READ');
		    FND_MSG_PUB.ADD;

		    l_is_error :=1;
		    EXIT; --exit the loop

		 WHEN too_many_rows THEN
		    --THIS SHOULD NEVER HAPPEN AS EPC IS UNIQUE COLUMN IN THE TABLE
		    x_pallet_lpn_id := NULL;
		    x_pallet_lpn_context := NULL;
		    x_return_status    := fnd_api.g_ret_sts_error;
		    FND_MESSAGE.SET_NAME('WMS', 'WMS_DUPLICATE_EPC');
		    FND_MSG_PUB.ADD;

		    l_is_error :=1;
		    EXIT; --exit the loop
		 WHEN OTHERS THEN
		    IF (l_debug = 1) THEN
		       trace('WHEN OTHERS EXCEPTION OF QUERY ........');
		    END IF;

		    x_pallet_lpn_id := NULL;
		    x_pallet_lpn_context := NULL;
		    x_return_status    :=  fnd_api.g_ret_sts_error;
		    FND_MESSAGE.SET_NAME('WMS', 'WMS_UNEXPECTED_ERR');
		    FND_MSG_PUB.ADD;

		    l_is_error :=1;

		    EXIT; --exit the loop

	      END;



	      --2-see whether it is cross-referenced to LPN, serial_number or
	      --to GTIN

	      IF l_cross_ref_type = 1 OR l_cross_ref_type IS NULL THEN
		 --LPN-EPC cross reference
		 --NULL TO SUPPORT OLD VALUES OF 11.5.10
                 BEGIN
		    -- This will match only for pallets and cases

		    SELECT wlpn.parent_lpn_id, wlpn.LPN_CONTEXT INTO
		      l_parent_lpn_id,l_PALLET_LPN_CONTEXT
		      FROM wms_license_plate_numbers wlpn
		      WHERE wlpn.lpn_id = L_LPN_ID
		      AND ((wlpn.parent_lpn_id = wlpn.outermost_lpn_id AND
			    wlpn.parent_lpn_id IS NOT null)
			   OR
			   ( wlpn.parent_lpn_id IS NULL AND wlpn.lpn_id =  wlpn.outermost_lpn_id ));
		 EXCEPTION
		    WHEN no_data_found THEN

		       --handle it but do not do anything here. leave it.In the verification part because
		       --lpn_id, parent_lpn_id, item_id , serial_number,
		       --GTIN ALL WILL BE  null for
		       --that entry in the x_tag_info pl/sql table,

			 NULL;
		 END;
		 --find if multiple pallet. irrespective of whether user
		 --wants the verification OR NOT there should NOT be two
		 --pallets IN the list OF EPCs.
		 --Also if the somehow the pallet did not get read but if
		 --ALL cases point TO the same Pallet, it should still PASS


		 IF  l_parent_lpn_id IS NULL THEN --this is pallet
		    l_lpn_pallet_id := l_lpn_id;
		  ELSE --this IS case
		    l_lpn_pallet_id := l_parent_lpn_id;
		 END IF;

		 IF l_lpn_pallet_id <> l_prev_lpn_pallet_id AND  l_prev_lpn_pallet_id <> -99 THEN--this is to ensure this

		    --Error;

		    --Cases were read before the pallet and the Pallet
		    --does not match WITH parent LPN of cases
		    -------------------OR----------------
		    -- Case belongs to multiple Pallet or there are
		    --multiple Pallets

		    IF (l_debug = 1) THEN
		       trace('Error: Multiple Pallets OR Cases belongs to multiple Pallets');
		    END IF;
		    x_return_status    := 'E';
		    FND_MESSAGE.SET_NAME('WMS','WMS_RFID_MULTIPLE_PALLET');
		    FND_MSG_PUB.ADD;

		    l_is_error := 1;
		    EXIT; --exit the loop

		 END IF;


		 l_prev_lpn_pallet_id := l_lpn_pallet_id;

		 x_tag_info(i).lpn_id := l_lpn_id;
		 x_tag_info(i).parent_lpn_id := l_parent_lpn_id;


	    ELSIF l_cross_ref_type = 2 THEN

		       --Serial_Number-EPC cross reference
		       --Serial can be inside inner-pack (modeled as LPN) also
		       --with NO tagging of inner-pack LPN  so more than 1 level of
		       --nesting and still valid scenario

                 BEGIN
		    select MSN.LPN_ID,WLPN.outermost_LPN_ID
		      INTO l_lpn_id, l_serial_pallet_id
		      from mtl_serial_numbers MSN,
		      WMS_LICENSE_PLATE_NUMBERS wlpn
		      WHERE  MSN.inventory_item_id = l_item_id
		      AND  MSN.serial_number = l_SERIAL_NUMBER
		      AND MSN.lpn_id = WLPN.LPN_ID;
		 EXCEPTION
		    WHEN no_data_found THEN

                  --handle it but do not do anything here. leave it.In the verification part because
                  --lpn_id, parent_lpn_id, item_id , serial_number,
                  --GTIN ALL WILL BE  null for
                  --that entry in the x_tag_info pl/sql table,

                    NULL;
		 END;

		 --Serial-tag might get read first or LPN-EPC (pallet or CASE)

		 IF l_prev_serial_pallet_id = -99 THEN
		    IF l_serial_pallet_id IS NULL THEN
		       --Error;
		       --Serial has to be inside an outer pallet at any
		       --LEVEL OF nesting
		       IF (l_debug = 1) THEN
			  trace('Error: There IS NO PALLET for Serial');
		      END IF;
		      x_return_status    := 'E';
		      FND_MESSAGE.SET_NAME('WMS','WMS_RFID_NO_PALLET');
		      FND_MSG_PUB.ADD;

		      l_is_error := 1;
		      EXIT; --exit the loop

		    END IF ;

		  ELSE --means l_prev_serial_pallet_id <> -99
		    IF  l_serial_pallet_id <>  l_prev_serial_pallet_id THEN

		       --Error;
		       --Error: Serials BELONG TO MULTIPLE PALLET
		       IF (l_debug = 1) THEN
			  trace('Error: Serials belong to multiple Pallet');
		       END IF;
		       x_return_status    := 'E';
		       FND_MESSAGE.SET_NAME('WMS','WMS_RFID_MULTIPLE_PALLET');
		       FND_MSG_PUB.ADD;

		       l_is_error := 1;
		      EXIT; --exit the loop

		    END IF;

		 END IF;

		 l_prev_serial_pallet_id :=  l_serial_pallet_id;

		 --Assign values
		 x_tag_info(i).item_id := l_item_id ;
		 x_tag_info(i).serial_number := l_serial_number;
		 x_tag_info(i).lpn_id := NULL; --since it can be CASE or inner lpn
		x_tag_info(i).parent_lpn_id := l_serial_pallet_id;


	       ELSIF l_cross_ref_type = 3 THEN
		      --GTIN-EPC cross reference

		      --since there is no connection between GTIN and LPN,
		      --we can NOT validate anything here

		      x_tag_info(i).gtin := l_gtin;
		      x_tag_info(i).gtin_serial := l_gtin_serial;

	       ELSE

		      --Error-UNIDENTIFIED CROSS-REFERENCE TYPE

		      IF (l_debug = 1) THEN
			 trace('Error:UNIDENTIFIED CROSS-REFERENCE TYPE');
		      END IF;
		      x_return_status    := 'E';
		      FND_MESSAGE.SET_NAME('WMS','WMS_RFID_INVALID_READ');
		      FND_MSG_PUB.ADD;

		      l_is_error := 1;
		      EXIT; --exit the loop
	      END IF;


	   END LOOP;

	   --LPNs at all level will have same LPN context, picking last one
	   x_pallet_lpn_context  := l_pallet_lpn_context;



	     --if the somehow the pallet did not get read but if
	     --ALL cases point TO the same Pallet, it should still PASS

	   IF l_serial_pallet_id <> l_lpn_pallet_id AND
	     l_serial_pallet_id <> -99 THEN
	      --LPN-EPC PALLET
	      --AND serial-epc pallet DO NOT MATCH and there is at least
	      --one serial epc also (There has to be one LPN pallet, NO
	      --consideration OF l_lpn_pallet_id)

	      x_pallet_lpn_id := NULL;
	      x_pallet_lpn_context := NULL;
	      x_return_status    := 'E';
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_MULTIPLE_PALLET');
	      FND_MSG_PUB.ADD;

	      l_is_error :=1;

	    ELSE
	      x_pallet_lpn_id := l_lpn_pallet_id;

	   END IF;


	END IF;--corresponding to x_tag_count > 1


    ELSE  --means p_tagid IS null

		 --NO EPC/LPN VALUE PASSED, just return Error
		 x_pallet_lpn_id := NULL;
		 x_pallet_lpn_context := NULL;
		 x_return_status    := 'E';
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_READ');
		 FND_MSG_PUB.ADD;

		 RETURN;

   END IF;


   -- IF there is error then update wms_epc
   -- No need to insert into wms_device_Requests, as transaction is going
   --TO fail because OF the multiple palletS

   IF l_is_error = 1 THEN

      FOR j IN 1..x_tag_info.COUNT LOOP
	 UPDATE wms_epc
	   SET status =  substr(fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F'),1,240),
	   status_code = 'E'
	   WHERE EPC  = x_tag_info(j).TAG_id;

      END LOOP;

   END IF;

  --Commit is done in the calling API


EXCEPTION
   WHEN OTHERS THEN
	 x_pallet_lpn_id := NULL;
	 x_pallet_lpn_context := NULL;
	 x_return_status    := 'E';
	 FND_MESSAGE.SET_NAME('WMS', 'UNEXPECTED ERROR');
	 FND_MSG_PUB.ADD;
	 IF (l_debug = 1) THEN
	    trace ('parse_read_tags :Inside when others exception');
	    trace ('SQL ERROR :'||SQLCODE);
	    trace ('SQL ERROR :'||Sqlerrm);
	 END IF;

END parse_read_tags;




PROCEDURE verify_load
  (
   p_org_id          IN       NUMBER,
   p_device_id       IN       NUMBER,
   p_tag_info        IN       tag_info_tbl,
   p_pallet_lpn_id   IN       NUMBER,
   p_bus_event_id    IN       NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_locator_id        IN NUMBER,
   p_event_date        IN DATE,
   x_return_status     out      nocopy  VARCHAR2  --S/E
   ) AS

l_expected_case_cnt NUMBER;
l_expected_ser_cnt NUMBER;

l_cur_percent NUMBER;
l_cur_case_cnt NUMBER;

l_load_verify_threshold NUMBER ; --get it from org setup
l_error_code NUMBER;
l_msg_data VARCHAR2(240);
l_request_id NUMBER;

l_case_cnt NUMBER;
l_serial_cnt NUMBER;
l_gtin_cnt  NUMBER;

l_lpn_item_id NUMBER;
l_total_qty NUMBER :=0;
l_uom_code VARCHAR2(3);
l_single_item BOOLEAN := TRUE;
l_total_gtin_qty NUMBER := 0;
l_total_lpn_qty NUMBER  := 0;
l_total_temp_qty NUMBER := 0;

l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
--Assumption All cases in the pallet will use same rule and
--threshold_percentage including the pallet
G_PROFILE_GTIN   VARCHAR2(100) := FND_PROFILE.value('INV:GTIN_CROSS_REFERENCE_TYPE');
BEGIN

   x_return_status := 'S';

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   l_device_req_id_pkg := l_request_id; --to  be used for the pallet record


   --By the time this API is called
   --1. it has been ensured that only one
   --pallet IS IN the list OF epc's. There might be cases from multiple
   --pallets though. that IS part FOR the verifiaction TO ensure

   --2. LPN_id and prent_lpn_id has been set for each read in the p_tag_info table

   --3. More than one tag is present
   IF (l_debug = 1) THEN
      trace('p_tag_count :'|| p_tag_info.COUNT);
   END IF;

   /****************************************/
   /*
   ERROR code for verification
     0- VERIFIED
     1- ERROR_INVALID_PALLET_CASE
     2- ERROR_MIXED_CASES
     3- ERROR_UNDER_THRESHOL
     4- ERROR_UNDER_THRESHOLD
     5- ERROR_EXTRA_CASE
     */
     /****************************************/


     --See if the PALLET lpn has single item
     BEGIN
	SELECT SUM(WLC.primary_quantity),wlc.inventory_item_id
	  INTO l_total_lpn_qty, l_lpn_item_id
	  FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
	  WHERE wlpn.outermost_lpn_id = p_pallet_lpn_id
	  AND wlpn.lpn_id = wlc.parent_lpn_id
	  --AND wlc.organization_id = p_org_id
	  AND wlc.organization_id = wlpn.organization_id
	  GROUP BY WLC.inventory_item_id;

     EXCEPTION
	WHEN too_many_rows THEN
	   l_SINGLE_ITEM := FALSE;

	WHEN OTHERS THEN

	   x_return_status := 'E';
	   FND_MESSAGE.SET_NAME('WMS', 'UNEXPECTED_ERROR');
	   FND_MSG_PUB.ADD;

	   IF l_debug = 1 then
	    trace('ERROR CODE = ' || SQLCODE);
	    trace('ERROR MESSAGE = ' || SQLERRM);
	   END IF;

     END;



   --Process them against our WMS_EPC table shipment verification
   l_case_cnt :=0;
   l_serial_cnt := 0;

   FOR i IN 1..p_tag_info.COUNT LOOP


      --Search for any extraneous read
      IF p_tag_info(i).lpn_id IS NULL AND p_tag_info(i).parent_lpn_id IS NULL
	AND p_tag_info(i).serial_number IS NULL
	  AND p_tag_info(i).gtin IS NULL AND p_tag_info(i).gtin_serial IS NULL THEN

	 IF (l_debug = 1) THEN
	    trace('Extraneous read  ERROR');
	 END IF;

	 l_error_code := 1;
	 --mark all read EPC as invalid in EPC table
	 x_return_status := 'E';
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_READ');
	 FND_MSG_PUB.ADD;

	 EXIT;

      END IF;


      IF  p_tag_info(i).parent_lpn_id IS NOT NULL AND  P_pallet_lpn_id <> p_tag_info(i).parent_lpn_id THEN
	 --Cases from different pallet are in this set of tags

	 x_return_status := 'E';
 	 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_MIXED_CASES');
	 FND_MSG_PUB.ADD;
	 EXIT;
      END IF;


      IF p_tag_info(i).LPN_ID IS NOT NULL AND p_tag_info(i).PARENT_LPN_ID IS NOT NULL THEN --CASE
	 l_case_cnt   := l_case_cnt +1;
       ELSIF p_tag_info(i).serial_number IS NOT NULL AND p_tag_info(i).PARENT_LPN_ID IS NOT NULL THEN --Serial
	 l_serial_cnt :=  l_serial_cnt +1;
       ELSIF p_tag_info(i).gtin IS NOT NULL AND p_tag_info(i).gtin_serial IS NOT NULL THEN


	 --ONLY FOR SINLGE ITEM IN PALLET WE DO THIS VALIDATION
	 IF l_single_item THEN
           BEGIN
	      --Assumption is that given a GTIN + Item_id + org_id , the set
	      --up for cross reference will return only one record
	      select uom_code INTO l_uom_code FROM mtl_cross_references mcr
		 WHERE mcr.inventory_item_id = L_LPN_ITEM_ID
		 AND mcr.CROSS_REFERENCE = To_char(p_tag_info(i).gtin)
		 AND mcr.CROSS_REFERENCE_TYPE = G_PROFILE_GTIN
	       AND (( mcr.org_independent_flag = 'Y' AND mcr.organization_id IS NULL) OR
		    (mcr.org_independent_flag = 'N' AND mcr.organization_id = p_org_id ));

	    EXCEPTION
	       WHEN too_many_rows THEN
		  x_return_status := 'E';
		  IF (l_debug = 1) THEN
		     trace ('Validating GTIN: Inside too_many_rows for GTIN :'||p_tag_info(i).gtin);
		  END IF;

		  EXIT;

	      WHEN OTHERS THEN
		 x_return_status := 'E';
		 IF (l_debug = 1) THEN
		    trace ('Validating GTIN: Inside when others exception');
		    trace ('SQL ERROR :'||SQLCODE);
		    trace ('SQL ERROR :'||Sqlerrm);
		 END IF;

		 EXIT;

	    END;


	    SELECT conversion_rate INTO l_total_temp_qty FROM mtl_uom_conversions_view mucv
	      where organization_id =  p_org_id
	      and uom_code = l_uom_code
	      AND INVENTORY_ITEM_ID = l_lpn_item_id;

	    l_total_gtin_qty := l_total_temp_qty + l_total_gtin_qty;


	 END IF; --single item


      END IF;

   END LOOP;

   IF (l_debug = 1) THEN
      trace('CASE COUNT ::'|| l_case_cnt);
      trace('SERIAL COUNT ::'|| l_serial_cnt);
      trace ('Total_gtin_qty :'||l_total_gtin_qty);
   END IF;


   IF x_return_status = 'S' THEN

      BEGIN
      wms_rfid_ext_pub.get_new_load_verif_threshold(p_org_id => p_org_id,
						    p_pallet_lpn_id => p_pallet_lpn_id,
						    x_new_load_verif_threshold => l_load_verify_threshold,
						    x_return_status => x_return_status);
      EXCEPTION
	 WHEN OTHERS THEN
	    x_return_status := 'E' ;
      END;

      IF  x_return_status = 'S' THEN

	 IF l_load_verify_threshold IS NULL THEN
	    --DO NOT OVERRIDE
	    SELECT Nvl(rfid_verif_pcnt_threshold,0) INTO l_load_verify_threshold
	      FROM  mtl_parameters WHERE organization_id = p_org_id;
	 END IF;

       ELSE
	 x_return_status := 'S';

	 SELECT Nvl(rfid_verif_pcnt_threshold,0) INTO l_load_verify_threshold
	   FROM  mtl_parameters WHERE organization_id = p_org_id;

      END IF;


      IF (l_debug = 1) THEN
	 trace('l_load_verify_threshold :'||l_load_verify_threshold);
      END IF;

      SELECT COUNT(1) INTO l_expected_case_cnt
	FROM wms_license_plate_numbers wlpn
	WHERE  parent_lpn_id = p_pallet_lpn_id
	AND wlpn.parent_lpn_id = wlpn.outermost_lpn_id
	AND wlpn.parent_lpn_id IS NOT NULL;


	SELECT COUNT(1) INTO l_expected_ser_cnt
	  FROM mtl_serial_numbers msn, wms_license_plate_numbers wlpn
	  WHERE msn.lpn_id = wlpn.lpn_id
	  and wlpn.outermost_lpn_id = p_pallet_lpn_id;

	IF (l_debug = 1) THEN
	   trace('l_expected_case_cnt :'||l_expected_case_cnt);
	   trace('l_expected_SER_cnt :' ||l_expected_ser_cnt);

	END IF;


	IF l_expected_case_cnt <> 0 THEN

	   l_cur_percent := ((l_case_cnt + l_serial_cnt)/(l_expected_case_cnt+l_expected_ser_cnt))*100;
	 ELSE
	   l_cur_percent := 0;
	END IF;

	IF (l_debug = 1) THEN
	   trace('l_cur_percent :'|| l_cur_percent);
	END IF;
	--Bug 5636478 - Moving the condition l_load_verify_threshold=0 to the IF condition
	--from ELSIF as the Verification is failing if Required Percentage of Load = 0
	--In this case it must succeed
	IF l_cur_percent = 100 OR
	  ( l_load_verify_threshold <> 0 AND l_cur_percent >=
	    l_load_verify_threshold AND l_cur_percent < 100 ) OR
	   l_load_verify_threshold = 0 THEN

	   --verification SUCCEEDED....update associated case records amd
	   --CURRENT pallet with STATUS='VALID'

	   --update all the CASE + PALLET set recods as VALID, including
	   --the unread ones
	   IF (l_debug = 1) THEN
	      trace(' sucessful validation');
	   END IF;

	   x_return_status := 'S';
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_VERIFY_COMPLETE');
	   FND_MSG_PUB.ADD;

	 ELSIF l_cur_percent < l_load_verify_threshold THEN

	   IF (l_debug = 1) THEN
	      trace('Failed validation');
	   END IF;
	   x_return_status := 'E';

	   FND_MESSAGE.SET_NAME('WMS', 'WMS_VERIF_UNDER_THRESHOLD');
	   FND_MSG_PUB.ADD;


	 ELSIF l_cur_percent > 100 THEN --case when there are more cases on
	   --the pallet the expected, amy be OF other pallet

	   x_return_status := 'E';
	   FND_MESSAGE.SET_NAME('WMS','WMS_VERIF_EXTRA_CASE');
	   FND_MSG_PUB.ADD;
	END IF;

   END IF; -- x_return_status = 'S'


   --Now check for GTIN tag failure condition
   --this check condition is applied only if the LPN has single items.


   IF l_single_item AND x_return_status = 'S' THEN -- VALIDATE FOR GTIN

      IF (l_debug = 1) THEN
	 trace('***** Total LPN qty :'||l_total_lpn_qty);
      END IF;

      IF l_total_lpn_qty < l_total_gtin_qty THEN
	 x_return_status := 'E';
	 FND_MESSAGE.SET_NAME('WMS','WMS_VERIF_EXTRA_GTIN_PACK');
	 FND_MSG_PUB.ADD;

      END IF;

    ELSE
      IF (l_debug = 1) THEN
	 trace('No GTIN level validation is needed for Multi-Item Pallet');
      END IF;

   END IF;


   --Update appropriate tables with verification result

   --get the failue/success meag
   l_msg_data := substr(fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F'),1,240);

   IF 	x_return_status = 'E' THEN

      --1. UPDATE WMS_EPC TABLE FOR FAILURE FOR ALL READS
      --2. INSERT INTO WMS_DEVICE_REQUESTs TABLE FOR READ CASE TAGS, NOT THE PALLET
      -- pallet will be transferred in the process_rfid_txn table and all
      -- above records will be moved TO the wms_device_request_hist table

      /* we can not use the group_id to update wms_epc table in one shot
      here as all records of the group_id might not be read. I have to
	update only those records which have been read by the reader.
	*/

      IF l_error_code = 1 THEN --Extraneous read

	 FOR j IN 1..p_tag_info.COUNT LOOP
	    UPDATE wms_epc
	      SET status = l_msg_data,
	      status_code = x_return_status
	      WHERE EPC  = p_tag_info(j).tag_id;--Since no LPN
	    --corredponding TO the extraneous read


	    IF p_tag_info(j).parent_lpn_id IS NOT NULL THEN --Pallet rec
	       --will be handled later

	       INSERT INTO wms_device_requests  (request_id,
						 business_event_id,
						 organization_id,
						 lpn_id,
						 device_id,
						 subinventory_code,
						 locator_id,
						 status_code,
						 status_msg,
						 last_update_date,
						 last_updated_by
						 ) VALUES
		 (l_request_id,
		  p_bus_event_id ,
		  p_org_id,
		  p_tag_info(j).LPN_id,
		  p_device_id,
		  p_subinventory_code,
		  p_locator_id,
		  x_return_status,
		  l_msg_data,
		  p_event_date,
		  fnd_global.user_id);

	    END IF;

 	 END LOOP;

       ELSE

	 FOR j IN 1..p_tag_info.COUNT LOOP
	    UPDATE wms_epc
	      SET status = l_msg_data,
	      status_code = x_return_status
	      WHERE lpn_id  = p_tag_info(j).lpn_id;

	    IF p_tag_info(j).parent_lpn_id IS NOT NULL THEN --Pallet rec
	       --will be handled later

	       INSERT INTO wms_device_requests  (request_id,
						 business_event_id,
						 organization_id,
						 lpn_id,
						 device_id,
						 subinventory_code,
						 locator_id,
						 status_code,
						 status_msg,
						 last_update_date,
						 last_updated_by
					      ) VALUES
		 (l_request_id,
		  p_bus_event_id ,
		  p_org_id,
		  p_tag_info(j).LPN_id,
		  p_device_id,
		  p_subinventory_code,
		  p_locator_id,
		  x_return_status,
		  l_msg_data,
		  p_event_date,
		  fnd_global.user_id);

	    END IF;

	 END LOOP;

      END IF;

    ELSIF x_return_status= 'S' THEN

      --1. UPDATE WMS_EPC TABLE FOR VERIFICATION SUCESSSFUL FOR ALL READS
      --NOTHING IN THE WMS_DEVICE_REQUEST table, no case records in the wms
      --device history TABLE IN successful scenario

      FOR j IN 1..p_tag_info.COUNT LOOP
	 UPDATE wms_epc
	   SET status = l_msg_data,
	   status_code = x_return_status
	   WHERE EPC  = p_tag_info(j).tag_id;

      END LOOP;

   END IF;


   --Commit is done in the calling API


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
	 trace ('verify_load : Inside when others exception');
	 trace ('SQL ERROR :'||SQLCODE);
	 trace ('SQL ERROR :'||Sqlerrm);
      END IF;

END verify_load;



procedure process_rfid_txn
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE,  -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE,-- ANY ADDITIONAL DATA IN VARRAY
   p_portalid        in      VARCHAR2,
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     out     nocopy varchar2
   ) IS

      end_processing EXCEPTION;--Exception to stop processing

      l_tag_info tag_info_tbl;
      l_device_enabled VARCHAR2(1);
      l_lpn_context NUMBER;
      l_lpn_id NUMBER;
      l_device_id NUMBER;
      l_organization_id NUMBER;
      l_subinventory_code VARCHAR2(30);
      l_locator_id NUMBER;
      l_outermost_lpn_id NUMBER;
      l_output_method_id NUMBER;
      l_request_id NUMBER;
      l_return_status VARCHAR2(1);
      l_shipment_header_id NUMBER;
      l_routing_id NUMBER;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(500);
      l_is_expense VARCHAR2(1);
      l_is_valid_txn_device NUMBER;
      l_progress VARCHAR2(8);
      l_out_business_event_id NUMBER;
      l_is_last_lpn_load NUMBER;
      l_user_id NUMBER;
      l_resp_appl_id NUMBER;
      l_resp_id NUMBER;

      l_tagid VARCHAR2(500);
      l_tag_len NUMBER;
      l_tag_count NUMBER;
      l_verif_req VARCHAR2(1);

      l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   x_return_value := 'success';


   IF (l_debug = 1) THEN
      trace('Entering the call process_rfid_txn ');
   END IF;

   IF fnd_global.user_id = -1 OR fnd_global.user_id IS NULL THEN

      l_user_id := fnd_profile.value('WMS_RFID_USER');
      select APPLICATION_ID INTO l_resp_appl_id from fnd_application where
	APPLICATION_SHORT_NAME = 'WMS' AND ROWNUM <2;
      l_resp_id := 21676; --Corresponding to "Warehouse Manager" responsibility

      fnd_global.apps_initialize(l_user_id,l_resp_id,l_resp_appl_id);
      IF (l_debug = 1) THEN
	 trace('Setting the user context for RFID Txn');
      END IF;
   END IF;


   FND_MSG_PUB.initialize;

   IF (l_debug = 1) THEN
      trace('Inside process_rfid_txn  rfid_user_id   :'||l_user_id||
      --', LPN/EPC name   :'||l_tagid||
      ', device_id      :'||p_portalid||
      ', p_event_date   :'||p_event_date||
      ', p_system_id    :'||p_system_id||
      ', p_statuschange :'||p_statuschange||
      ', p_datachange   :'||p_datachange);
   END IF;


  l_progress := '10';

 BEGIN
    SELECT
      device_id,enabled_flag,organization_id,subinventory_code,locator_id,output_method_id
      INTO l_device_id,l_device_enabled,l_organization_id,l_subinventory_code,l_locator_id,l_output_method_id
      FROM wms_devices_vl
      WHERE name = p_portalid; --Device Name
 EXCEPTION
    WHEN no_data_found THEN
       IF (l_debug = 1) THEN
	  trace('process_rfid_txn :No device defined');
	  --Can not generate xml since organization_id is required
	  --column IN the wdr AND we have no information about it here
       END IF;
       FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_DEVICE_FOUND');
       FND_MSG_PUB.ADD;
       raise end_processing;

    WHEN too_many_rows THEN
       IF (l_debug = 1) THEN
	  trace('Error :Multiple devices with same device_name');
       END IF;
       FND_MESSAGE.SET_NAME('WMS', 'DUPLICATE_DEVICE_ENTRY');
       FND_MSG_PUB.ADD;
       raise end_processing;

    WHEN OTHERS then
       IF (l_debug = 1) THEN
	  trace('Other error in finding device');
	  trace('SQL error :'||substr(sqlerrm, 1, 240));

       END IF;
       raise end_processing;
 END;

  l_progress := '20';

  IF (l_debug = 1) THEN
     trace('process_rfid_txn :device_id,locator_id::Org_id::'||l_device_id||'::'||l_locator_id||'::'||l_organization_id);
  END IF;

  --parse tags, get the pallet info
  --get appropriate bus event
  --process verification, if needed
  --process transaction

  --PARSE READ TAGS
  parse_read_tags(p_tagid              => p_tagid,
		  p_org_id             => l_organization_id,
		  x_tag_info           => l_tag_info,
		  x_pallet_lpn_id      => l_lpn_id,
		  x_pallet_lpn_context => l_lpn_context,
		  x_tag_count          => l_tag_count,
		  x_return_status      => l_return_status);


  --Committing the update of failue cases in parse_read_tags
  COMMIT;

  IF (l_debug = 1) THEN
     trace('process_rfid_txn Pallet_lpn_id :'||l_lpn_id);
     trace('process_rfid_txn l_lpn_context :'||l_lpn_context);
  END IF;


  IF L_return_status <> 'S'  THEN

     generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_rfid_error,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E',p_event_date,l_request_id,l_return_status);
     raise end_processing;

  END IF;


  --Create a save point here
  SAVEPOINT wms_rfid_sp;


  l_progress := '30';

  IF (l_debug = 1) THEN
     trace('process_rfid_txn:LPN is good l_lpn_context::'||l_lpn_context);
  END IF;


  --make sure that the the context of LPN is eligible for devices set up in
  --the device assignment form

  is_valid_txn_device(p_device_id       => l_device_id,
		      p_lpn_context     => l_lpn_context,
		      p_organization_id => l_organization_id,
		      x_out_business_event_id  => l_out_business_event_id,--to distinguish truck_load
		      --Vs truck_load_ship and Direct rcv Vs Std/Insp rcv
		      x_valid_device_for_txn   => l_is_valid_txn_device,
		      x_verif_req              => l_verif_req );



  IF (l_debug = 1) THEN
     trace('process_rfid_txn:l_out_business_event_id::l_is_valid_txn_device ::'||l_out_business_event_id||'::'||l_is_valid_txn_device);
  END IF;


  IF l_is_valid_txn_device <> 1  THEN
     IF (l_debug = 1) THEN
	trace('process_rfid_txn :Error:No or Multiple valid business events in the set up');
     END IF;

     IF l_is_valid_txn_device = 0 THEN
	FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_NO_ELIGIBLE_BUS_EVENT');
	FND_MSG_PUB.ADD;
      ELSIF l_is_valid_txn_device = -1 THEN
	IF (l_debug = 1) THEN
	   trace('process_rfid_txn : Error: Both Truck_load  and Truck_load_ship are associated');
	END IF;
	   FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_BUS_ASSOC');
	FND_MSG_PUB.ADD;
      ELSIF l_is_valid_txn_device = -2 THEN
	IF (l_debug = 1) THEN
	   trace('process_rfid_txn : Error: Direct rcv and Std/Insp both with same device');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_BUS_ASSOC');
	FND_MSG_PUB.ADD;
      ELSIF l_is_valid_txn_device = -3 THEN
	IF (l_debug = 1) THEN
	   trace('process_rfid_txn : Error: Invalid LPN context');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
	FND_MSG_PUB.ADD;

     END IF;

     --Insert generate XML/CSV or Call API for wms_be_rfid_error bus
     --event
     ROLLBACK TO wms_rfid_sp;
     generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_rfid_error,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E',p_event_date,l_request_id,l_return_status);
     raise end_processing;


   ELSE --is_transaction_valid

  l_progress := '30.5';
  IF (l_debug = 1) THEN
     trace('process_rfid_txn : valid business events have been set up');
     trace('l_out_business_event_id :'|| l_out_business_event_id);
     trace('l_verif_req  :'||l_verif_req );
  END IF;


     --PERFORM THE VERIFICATION only if tag count > 1
  IF l_verif_req = 'Y' THEN
     IF l_tag_count > 1 THEN
	IF (l_debug = 1) THEN
	   trace('Starting the verification process.....');
	END IF;

	verify_load
	  (
	   p_org_id     => l_organization_id,
	   p_device_id  => l_device_id,
	   p_tag_info   => l_tag_info,
	   p_pallet_lpn_id => l_lpn_id,
	   p_bus_event_id  => l_out_business_event_id,
	   p_subinventory_code => l_subinventory_code,
	   p_locator_id        => l_locator_id,
	   p_event_date        =>   p_event_date,
	   x_return_status     => l_return_status
	   );

      ELSIF l_tag_count = 1 THEN

	IF (l_debug = 1) THEN
	   trace('Error: Verification of a Single LPN');
	END IF;

	FND_MESSAGE.SET_NAME('WMS', 'WMS_VERIF_UNDER_THRESHOLD');
	FND_MSG_PUB.ADD;
	l_return_status:= 'E';

     END IF;


  END IF;


  trace(' verify_load returned status:'||l_return_status);

  --Whatever happens in verification later, result of verficiation needs to be commited
  -- commit all the changes in the WMS_EPC table
  COMMIT;


     IF l_return_status <> 'S' THEN
	IF (l_debug = 1) THEN
	   trace(' INSIDE VERIFY FAILURE, CALLING GENERATE xml api');
	END IF;
	generate_xml_csv_api(l_device_id,l_out_business_event_id,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E',p_event_date,l_request_id,l_return_status);
	raise end_processing;

     END IF;


     l_progress := '30.7';


     --define a new savepoint for further processing
     SAVEPOINT wms_rfid_sp1;

     IF (l_debug = 1) THEN
	trace('AFTER VALIDATION l_return_status::'||l_return_status);
     END IF;

     --PROCESS THE ACTUAL TRANSACTION
     IF  l_return_status ='S' THEN  --Verification successful

	IF (l_lpn_context = wms_container_pub.lpn_context_inv) THEN

	   IF (l_debug = 1) THEN
	      trace('process_rfid_txn :Direct Ship');
	   END IF;


	   IF l_out_business_event_id= wms_device_integration_pvt.wms_be_TRUCK_LOAD THEN

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn :Processing Direct Truck Load');
	      END IF;

	      l_progress := '40';

	      --process truck_load txn
	      process_direct_truck_load(p_lpn_id             => l_lpn_id,
					p_org_id             => l_organization_id,
					p_dock_door_id       => l_locator_id,
					x_is_last_lpn_load   => l_is_last_lpn_load,
					x_return_status      => l_return_status
					);

	      l_progress := '50';

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn:After process_direct_truck_load:l_return_status:"'||l_return_status);
	      END IF;

	      IF l_return_status IS NULL OR l_return_status = 'E' OR l_return_status = 'U'THEN

		 --Error mesg should have been at the point of failure

		 --Insert record into the WMS_DEVICE_REQUESTS table
		 --Generate xml/call API for truck_load  business event
		 --populate in the history table
		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 x_return_value := 'error';

	       ELSE
		 --Truck Load Txn Successful
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);

	      END IF;


	    elsif l_out_business_event_id = wms_device_integration_pvt.wms_be_truck_load_ship THEN

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn :Processing Direct Truck Load and SHIP');
	      END IF;

	      --process truck_load_ship txn and inside make sure that the
	      --lpn is COMPLETELY reserved against a SO
	      l_progress := '40';

	      process_direct_truck_load_SHIP(p_lpn_id             => l_lpn_id,
					     p_org_id             => l_organization_id,
					     p_dock_door_id       => l_locator_id,
					     x_return_status      => l_return_status
					     );

	      l_progress := '50';


	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn:After process_direct_truck_load_SHIP:l_return_status:'||l_return_status);
		 trace('process_rfid_txn: message stored'||l_ship_confirm_pkg_mesg);
	      END IF;

	      IF l_return_status IS NULL OR l_return_status = 'E' OR
		l_return_status = 'U' THEN

		 --Error mesg should have been at the point of failure

		 --Insert record into the WMS_DEVICE_REQUESTS table
		 --Generate xml/call API for truck_load  business event
		 --populate in the history table
		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD_SHIP,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 x_return_value := 'error';

	       ELSE
		 --Truck Load Txn Successful
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD_SHIP,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);

	 END IF;

	   END IF; --FOR l_out_business_event_id


	 ELSIF (l_lpn_context = wms_container_pub.lpn_context_picked ) THEN
	   IF (l_debug = 1) THEN
	      trace('process_rfid_txn :Normal LPN Ship');
	   END IF;

	   IF l_out_business_event_id= wms_device_integration_pvt.wms_be_TRUCK_LOAD THEN

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn :Processing Normal Truck Load');
	      END IF;


	      --dock-door for the device is locator of the device
	      --The device assignment form will make sure that only those devices
	      --are associated with Truck_load AND Truck_Load_Ship business events
	      --for which Sub/Loc are defined.So if it comes here l_locator_id
	      --will have value.

	      l_progress := '40';

	      process_normal_truck_load(p_lpn_id             => l_lpn_id,
					p_org_id             => l_organization_id,
					p_dock_door_id       => l_locator_id,
					x_is_last_lpn_load   => l_is_last_lpn_load,
					x_return_status      => l_return_status);

	      l_progress := '50';


	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn:After process_normal_truck_load:l_return_status:"'||l_return_status);
	      END IF;

	      IF l_return_status IS NULL OR l_return_status = 'E' THEN

		 --Error mesg should have been at the point of failure

		 --Insert record into the WMS_DEVICE_REQUESTS table
		 --Generate xml/call API for truck_load  business event
		 --populate in the history table

		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 x_return_value := 'error';
	       ELSE
		 --Truck Load Txn Successful
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);

	      END IF;


	    ELSIF l_out_business_event_id= wms_device_integration_pvt.wms_be_TRUCK_LOAD_ship THEN

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn :Processing Normal Truck Load and SHIP');
	      END IF;

	      --dock-door for the device is locator of the device
	      --The device assignment form will make sure that only those devices
	      --are associated with Truck_load AND Truck_Load_Ship business events
	      --for which Sub/Loc are defined.So if it comes here l_locator_id
	      --will have value.
	      l_progress := '40';

	      process_normal_truck_load_ship(p_lpn_id             => l_lpn_id,
					     p_org_id             => l_organization_id,
					     p_dock_door_id       => l_locator_id,
					     x_return_status      => l_return_status
					     );

	      l_progress := '50';

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn:After process_normal_truck_load_ship:l_return_status:'||l_return_status);
		 trace('process_rfid_txn:Return Message::'||l_ship_confirm_pkg_mesg);
	      END IF;



	      IF l_return_status IS NULL OR l_return_status = 'E' THEN

		 --Insert record into the WMS_DEVICE_REQUESTS table
		 --Generate xml/call API for truck_load  business event
		 --populate in the history table

		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD_ship,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 x_return_value := 'error';
	       ELSE

		 --Truck Load ship Txn Successful
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_TRUCK_LOAD_ship,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);

	      END IF;

	   END IF;

	 ELSIF (l_lpn_context = wms_container_pub.lpn_context_intransit OR
		l_lpn_context = wms_container_pub.lpn_context_vendor) THEN

	   IF (l_debug = 1) THEN
	      trace('process_rfid_txn : processing receiving txn');
	   END IF;

	   --Only possible transactions with these LPN conexts can be
	   --receiving
	   l_progress := '40';
           BEGIN
	      select rsh.shipment_header_id into l_shipment_header_id from
		rcv_shipment_headers rsh ,wms_license_plate_numbers wlpn where wlpn.lpn_id = l_lpn_id
		and wlpn.lpn_context IN (6,7) --for ASN 7, blocked for ASN in patch set J
		and (rsh.shipment_num = Nvl(wlpn.source_name,'@#$@')
		     or rsh.shipment_header_id = Nvl(wlpn.source_header_id, -1));

	      l_progress := '50';

	   exception
	      when no_data_found then
		 IF (l_debug = 1) THEN
		    trace('process_rfid_txn:No record found with LPN ::'||l_lpn_id);
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_INVALID_RCV_LPN ');
		 FND_MSG_PUB.ADD;
		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_rfid_error,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 raise end_processing;
	   end;

	   IF (l_debug = 1) THEN
	      trace('process_rfid_txn:for internal req/ASN  shipment_header_id::'||l_shipment_header_id);
	   END IF;

	   if l_shipment_header_id is not null then

	      l_progress := '60';

	      IF l_lpn_context = 7 THEN

		 inv_rcv_common_apis.get_asn_routing_id
		   (x_asn_routing_id   => l_routing_id
		    , x_return_status  => l_return_status
		    , x_msg_count      => l_msg_count
		    , x_msg_data       => l_msg_data
		    , p_shipment_header_id => l_shipment_header_id
		    , p_lpn_id             => l_lpn_id
		    , p_po_header_id       => NULL);

	       ELSE

		 inv_rcv_common_apis.get_routing_id
		   (
		    x_routing_id         => l_routing_id,
		    x_return_status      => l_return_status,
		    x_msg_count          => l_msg_count,
		    x_msg_data           => l_msg_data,
		    x_is_expense         => l_is_expense,
		    p_po_header_id       => null,
		    p_po_release_id      => null,
		    p_po_line_id         => null,
		    p_shipment_header_id => l_shipment_header_id,
		    p_oe_order_header_id => null,
		    p_item_id            => null,
		    p_organization_id    => l_organization_id,
		    p_vendor_id          => null,
		    p_lpn_id             => l_lpn_id);

	      END IF;

	      l_progress := '70';

	      IF (l_debug = 1) THEN
		 trace('process_rfid_txn:p_routing_id,l_return_status,l_msg_count,l_msg_data');

		 trace('process_rfid_txn:'||l_routing_id||'::'||l_return_status||'::'||l_msg_count||'::'||l_msg_data);
	      END IF;


	      IF l_return_status <> fnd_api.g_ret_sts_success THEN

		 IF (l_debug = 1) THEN
		    trace(' Error : inv_rcv_common_apis.failed in getting _routing_id');
		 END IF;
		 ROLLBACK TO wms_rfid_sp1;
		 generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_rfid_error,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		 raise end_processing;

	       ELSE -- get_routing_id succeeded


		 --make sure that the returned routing_id matches with the
		 --device setup for business event
		 --possible case: if the transaction record for rcv gives Direct
		 --routing whereas the device_id passed is setup for Std/Insp
		 --business event this transaction should fail

		 IF ((l_routing_id = 3 AND  l_out_business_event_id = wms_device_integration_pvt.wms_be_direct_receipt) OR
		     (l_routing_id IN (1,2)
		 AND l_out_business_event_id = wms_device_integration_pvt.wms_be_std_insp_receipt)) THEN

		    IF (l_debug = 1) THEN
		       trace('process_rfid_txn: Processing receiving txn');
		    END IF;
		    l_progress := '80';

		    process_rfid_receiving_txn(p_lpn_id     => l_lpn_id,
					       p_device_id   => l_device_id,
					       p_dest_org_id => l_organization_id,
					       p_lpn_context => l_lpn_context,
					       p_routing_id  => l_routing_id,
					       p_shipment_header_id => l_shipment_header_id,
					       p_direct_putaway_sub => l_subinventory_code,
					       p_direct_putaway_loc => l_locator_id,
					       x_return_status      => l_return_status);

		    l_progress := '90';

		    IF l_return_status <> fnd_api.g_ret_sts_success THEN--failed transaction

		       IF (l_debug = 1) THEN
			  trace('process_rfid_txn: Receiving txn failed');
		       END IF;

		       IF l_routing_id = 1 OR  l_routing_id = 2 THEN
			  --Standard/inspection routing
			  IF l_return_status <> 'N' THEN --avoid overwriting of mesg SET IN the API call
			     FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_STD_INSP_RCV_FAIL');
			     FND_MSG_PUB.ADD;
			  END IF;

			  ROLLBACK TO wms_rfid_sp1;
			  generate_xml_csv_api(l_device_id,wms_device_integration_pvt.WMS_BE_STD_INSP_RECEIPT,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		     x_return_value := 'error';

			ELSIF l_routing_id = 3 THEN
			  -- direct routing
			  IF l_return_status <> 'N' THEN--avoid overwriting of mesg set in the API call
			     FND_MESSAGE.SET_NAME('WMS', 'WMS_RFID_DIR_RCV_FAIL');
			     FND_MSG_PUB.ADD;
			  END IF;
			  ROLLBACK TO wms_rfid_sp1;
			  generate_xml_csv_api(l_device_id,wms_device_integration_pvt.WMS_BE_DIRECT_RECEIPT,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
			  x_return_value := 'error';

		       END IF;

		     ELSE--transaction succeeded

		       IF (l_debug = 1) THEN
			  trace('process_rfid_txn: Receiving txn succeeded');
		       END IF;

		       IF l_routing_id = 1 OR  l_routing_id = 2 THEN
			  --Standard/inspection routing
			  generate_xml_csv_api(l_device_id,wms_device_integration_pvt.WMS_BE_STD_INSP_RECEIPT,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);


			ELSIF l_routing_id = 3 THEN
			  -- direct routing
			  generate_xml_csv_api(l_device_id,wms_device_integration_pvt.WMS_BE_DIRECT_RECEIPT,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'S', p_event_date,l_request_id,l_return_status);

		       END IF;


		    END IF;--TXN SUCCEEDED

		  ELSE --matching routing_id and l_out_business_event_id

		    IF (l_debug = 1) THEN
		       trace('Error: Device set up and returned txn routing does not match');
		    END IF;
		    FND_MESSAGE.SET_NAME('WMS','WMS_RFID_NO_ELIGIBLE_BUS_EVENT');
		    FND_MSG_PUB.ADD;
		    ROLLBACK TO wms_rfid_sp1;
		    generate_xml_csv_api(l_device_id,wms_device_integration_pvt.wms_be_rfid_error,l_organization_id,l_lpn_id,l_output_method_id,l_subinventory_code,l_locator_id,'E', p_event_date,l_request_id,l_return_status);
		    raise end_processing;

	    END IF; --matching routing_id and l_out_business_event_id

	      END IF;-- get_routing_id succeeded

	   END IF;-- L_shipmet_header_id is not null

	END IF;--l_lpn_context

     END IF; --Verification successful


  END IF;--is_valid_txn_device


  l_progress := '100';

  IF (l_debug = 1) THEN
     trace('process_rfid_txn:Delete requested rows from WDR');
  END IF;
  delete from wms_device_requests;--since temp table is session specific

  IF (l_debug = 1) THEN
     trace('process_rfid_txn :End of processing for current read');
  END IF;

  --commiting the reansaction
  COMMIT;

  --We do populate mesg in case of succes too.
  --when the delivery or trip is complete.

  --returning message
  IF l_out_business_event_id = wms_device_integration_pvt.wms_be_truck_load_ship THEN
     x_return_mesg := l_ship_confirm_pkg_mesg;
   else
      x_return_mesg := fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');
  END IF;

EXCEPTION
   WHEN end_processing THEN
      x_return_value := 'error';

      /*  somehow it does not retrieve all mesg
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      x_return_mesg := l_msg_data;
      */

      x_return_mesg := fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');

      IF (l_debug = 1) THEN
	 trace('process_rfid_txn:throwing Exception:end_processing, Delete requested rows from WDR');
	 trace('x_return_mesg :' || x_return_mesg);
      END IF;


      delete from wms_device_requests;--since temp table is session specific
      COMMIT;

   WHEN OTHERS THEN
       ROLLBACK TO wms_rfid_sp1;
       x_return_value := 'error';
       x_return_mesg := fnd_msg_pub.get(fnd_msg_pub.G_LAST,'F');
       IF (l_debug = 1) THEN
         trace('Other error in process_rfid_txn  l_progress:;'|| l_progress);
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END;


Procedure WMS_READ_EVENT
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE, -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE, -- ANY ADDITIONAL DATA IN VARRAY
   p_portalid        in      VARCHAR2,
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT null,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     out     nocopy varchar2
   ) IS


BEGIN

   x_return_value := 'read';
   x_return_mesg := 'Data Read';

END WMS_READ_EVENT;


procedure process_rfid_txn
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE, -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE, -- ANY ADDITIONAL DATA IN VARRAY
   p_portalid        in      VARCHAR2,--Device name as varchar2
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     OUT     nocopy VARCHAR2,
   x_request_id      OUT     nocopy NUMBER
   ) IS
      l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('process_rfid_txn :Calling parent process_rfid_txn');
   END IF;

 process_rfid_txn
  (
   p_tagid            => p_tagid,
   p_tagdata          => p_tagdata,
   p_portalid         => p_portalid,
   p_event_date       => p_event_date,
   p_system_id        => p_system_id,
   p_statuschange     => p_statuschange,
   p_datachange       => p_datachange,
   p_status           => p_status,
   p_x                => p_x,
   p_y                => p_y,
   x_return_value     =>  x_return_value,
   x_return_mesg      =>  x_return_mesg);

 x_request_id := l_device_req_id_pkg;

 IF (l_debug = 1) THEN
      trace('process_rfid_txn :value of request_id '||l_device_req_id_pkg);
 END IF;


END  process_rfid_txn;




--Internal Wrapper API for testing purpose only using Mobile
--Not to be touched by customer
--it just convertes the type of  p_tagid form Clob to varray and calls the
--main API

procedure MobTest_process_rfid_txn
  (
   p_tagid           in      clob, -- EPC tag ID
   p_tagdata         IN      clob, -- Any additional value with EPC tag
   p_portalid        in      varchar2,--reader name
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     OUT     nocopy varchar2)

  IS
     l_start_pos NUMBER;
     l_first_pos NUMBER;
     l_second_pos NUMBER;
     l_index NUMBER;

     l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     epc_tag_id     wms_epc_tagid_type;
     epc_tag_data   wms_epc_tagdata_type;


BEGIN


   IF (l_debug = 1) THEN
      trace('Inside MobTest_process_rfid_txn');
   END IF;

   --Initialize the varray
   epc_tag_id   :=   wms_epc_tagid_type('S');
   epc_tag_data :=   wms_epc_tagdata_type('S');


   IF p_tagid IS NOT null then
      IF (l_debug = 1) THEN
	 trace('tagid is NOT null');
      END IF;

      l_start_pos := 1;
      l_first_pos := 1;
      l_second_pos := 1;

      l_index := 1;


      WHILE l_second_pos <> 0 LOOP

	 --trace('Inside outer loop index :'||l_index);


	 l_first_pos := Instr(p_tagid,',',l_start_pos,1);
	 l_second_pos := Instr(p_tagid,',',l_start_pos,2);


	 --trace('l_first_pos , l_second_pos :'||l_first_pos||','||l_second_pos );

	 l_start_pos := l_second_pos;

	 IF l_index = 1 THEN

	    IF l_first_pos = 0 THEN -- only one value is present in the list
	       --trace('only one value case tag');
	       epc_tag_id(l_index) := Ltrim(Rtrim(p_tagid));

	       EXIT;

	     ELSE --for first AND SECOND value in the list of values

	       --trace('first value in list of many case');
	       epc_tag_id(l_index) := Substr(p_tagid,1,l_first_pos-1);

	       IF l_second_pos <> 0 THEN

		  l_index :=  l_index+1;
		 -- trace('second value in list of many case');
		  epc_tag_id.extend;
		  epc_tag_id(l_index) :=Substr(p_tagid,l_first_pos+1,l_second_pos-l_first_pos-1);

		ELSE
		  l_index :=  l_index+1;
		  epc_tag_id.extend;
		  epc_tag_id(l_index) :=Substr(p_tagid,l_first_pos+1);

	       END IF;
	    END IF;

	  ELSIF l_second_pos = 0 THEN --FOR last value

	    IF (l_debug = 1) THEN
	       trace('Last value in list of many epc');
	    END IF;
	    epc_tag_id.extend;
	    epc_tag_id(l_index) := Ltrim(Rtrim(Substr(p_tagid,l_first_pos+1)));

	  ELSE --for in-between values
	    --trace('In between val in list of many epc');
	    epc_tag_id.extend;
	    epc_tag_id(l_index) := Ltrim(Rtrim(Substr(p_tagid,l_first_pos+1,l_second_pos-l_first_pos-1)));

	 END IF;
	 l_index := l_index +1 ;

      END LOOP;

      --call the main API
      process_rfid_txn
	(
	 p_tagid            => epc_tag_id,
	 p_tagdata          => epc_tag_data,
	 p_portalid         => p_portalid,
	 p_event_date       => p_event_date,
	 p_system_id        => p_system_id,
	 p_statuschange     => p_statuschange,
	 p_datachange       => p_datachange,
	 p_status           => p_status,
	 p_x                => p_x,
	 p_y                => p_y,
	 x_return_value     =>  x_return_value,
	 x_return_mesg      =>  x_return_mesg);


    ELSE
      IF (l_debug = 1) THEN
	 trace('tagid is NULL');
      END IF;
      x_return_value := 'error';
      x_return_mesg := 'No EPC passed';

   END IF;

END  MobTest_process_rfid_txn;


END WMS_RFID_DEVICE_PUB;

/
