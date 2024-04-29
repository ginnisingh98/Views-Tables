--------------------------------------------------------
--  DDL for Package Body WSH_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIPS_PVT" AS
/* $Header: WSHTRTHB.pls 120.3 2007/01/05 00:26:34 anxsharm ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRIPS_PVT';
--
PROCEDURE Create_Trip(
  p_trip_info		IN  trip_rec_type,
  x_rowid			OUT NOCOPY  varchar2,
  x_trip_id		OUT NOCOPY  NUMBER,
  x_name			OUT NOCOPY  VARCHAR2,
  x_return_status	OUT NOCOPY  VARCHAR2
)
IS

  CURSOR get_next_trip IS
    SELECT wsh_trips_s.nextval
    FROM sys.dual;

 -- Remove cursor get_row_id  for Bug 3821688

  CURSOR check_trip_names (v_trip_name   VARCHAR2) IS
  SELECT trip_id FROM wsh_trips
  WHERE name = v_trip_name;

  CURSOR check_trip_ids (v_trip_id   NUMBER) IS
  SELECT trip_id FROM wsh_trips
  WHERE trip_id = v_trip_id;

  l_name	        WSH_TRIPS.NAME%TYPE;
  l_row_check	        NUMBER;
  l_temp_id             NUMBER;

  l_tmp_count           NUMBER := 0;

  wsh_duplicate_name    EXCEPTION;
  others                EXCEPTION;

  l_ignore_for_planning WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;
  l_gc3_is_installed    VARCHAR2(1); -- OTM R12, glog proj
--
--/== Workflow Changes
l_process_started VARCHAR2(1);
l_return_status VARCHAR2(1);
l_wf_rs VARCHAR2(1);
--==/

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_TRIP';
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
  END IF;
  --

  x_trip_id          := p_trip_info.trip_id;
  x_name             := p_trip_info.name;

  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  IF l_gc3_is_installed = 'Y' THEN
    l_ignore_for_planning := 'Y';
  ELSE
    l_ignore_for_planning := 'N';
  END IF;
  -- end of OTM R12, glog proj



  IF (x_trip_id IS NULL) THEN

     LOOP

       OPEN get_next_trip;
       FETCH get_next_trip INTO x_trip_id;
       CLOSE get_next_trip;

	  IF (x_trip_id IS NULL) THEN
		raise others;
       END IF;

       l_row_check := NULL;

       OPEN  check_trip_ids(x_trip_id);
       FETCH check_trip_ids INTO l_row_check;

       IF (check_trip_ids%NOTFOUND) THEN
          CLOSE check_trip_ids;
	     EXIT;
       END IF;

       CLOSE check_trip_ids;

     END LOOP;


  END IF;

  IF (x_name IS NULL) THEN

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CUSTOM_PUB.TRIP_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_name := wsh_custom_pub.trip_name(x_trip_id, p_trip_info);

     -- shipping default make sure the delivery name is not duplicate
     IF ( l_name = to_char(x_trip_id) ) THEN

        l_temp_id := x_trip_id;

--l_name := to_char(l_temp_id);

        LOOP
              l_name := to_char(l_temp_id);

              OPEN check_trip_names( l_name);
              FETCH check_trip_names INTO l_row_check;

              IF (check_trip_names%NOTFOUND) THEN
                 CLOSE check_trip_names;
                 EXIT;
              END IF;

              CLOSE check_trip_names;

              OPEN get_next_trip;
              FETCH get_next_trip INTO l_temp_id;
              CLOSE get_next_trip;

		    IF (l_temp_id IS NULL) THEN
			  raise others;
              END IF;

        END LOOP;

        x_trip_id := l_temp_id;

     END IF;

     x_name := l_name;

  ELSE
        OPEN check_trip_names( x_name);
        FETCH check_trip_names INTO l_row_check;

        IF (check_trip_names%FOUND) THEN
           CLOSE check_trip_names;
           RAISE wsh_duplicate_name;
        END IF;

        CLOSE check_trip_names;

  END IF;


  INSERT INTO wsh_trips(
    trip_id,
    name,
    planned_flag,
    arrive_after_trip_id,
    status_code,
    vehicle_item_id,
    vehicle_organization_id,
    vehicle_number,
    vehicle_num_prefix,
    carrier_id,
    ship_method_code,
    route_id,
    routing_instructions,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_application_id,
    program_id,
    program_update_date,
    request_id,
/* H Integration: datamodel changes wrudge */
    service_level,
    mode_of_transport,
    freight_terms_code,
    consolidation_allowed,
    load_tender_status,
    load_tender_number,
    wf_name,
    wf_process_name,
    wf_item_key,
    carrier_contact_id,
    shipper_wait_time,
    wait_time_uom,
    load_tendered_time,
    vessel,
    voyage_number,
    port_of_loading,
    port_of_discharge,
    carrier_response,
    route_lane_id,
    lane_id,
    schedule_id,
    booking_number,
    shipments_type_flag,
/* J TP Release : ttrichy */
    ignore_for_planning,
    tp_plan_name,
    tp_trip_number,
    seal_code,
    operator,
/* R12 attributes */
    carrier_reference_number,
    rank_id,
    consignee_carrier_ac_no,
    routing_rule_id,
    append_flag
  ) VALUES(
    x_trip_id,
    x_name,
    nvl(p_trip_info.planned_flag, 'N'),
    p_trip_info.arrive_after_trip_id,
    nvl(p_trip_info.status_code,'OP'),
    p_trip_info.vehicle_item_id,
    p_trip_info.vehicle_organization_id,
    p_trip_info.vehicle_number,
    p_trip_info.vehicle_num_prefix,
    p_trip_info.carrier_id,
    p_trip_info.ship_method_code,
    p_trip_info.route_id,
    p_trip_info.routing_instructions,
    p_trip_info.attribute_category,
    p_trip_info.attribute1,
    p_trip_info.attribute2,
    p_trip_info.attribute3,
    p_trip_info.attribute4,
    p_trip_info.attribute5,
    p_trip_info.attribute6,
    p_trip_info.attribute7,
    p_trip_info.attribute8,
    p_trip_info.attribute9,
    p_trip_info.attribute10,
    p_trip_info.attribute11,
    p_trip_info.attribute12,
    p_trip_info.attribute13,
    p_trip_info.attribute14,
    p_trip_info.attribute15,
    nvl(p_trip_info.creation_date, SYSDATE),
    nvl(p_trip_info.created_by, FND_GLOBAL.USER_ID),
    nvl(p_trip_info.last_update_date, SYSDATE),
    nvl(p_trip_info.last_updated_by, FND_GLOBAL.USER_ID),
    nvl(p_trip_info.last_update_login, FND_GLOBAL.LOGIN_ID),
    p_trip_info.program_application_id,
    p_trip_info.program_id,
    p_trip_info.program_update_date,
    p_trip_info.request_id,
/* H Integration: datamodel changes wrudge */
    p_trip_info.service_level,
    p_trip_info.mode_of_transport,
    p_trip_info.freight_terms_code,
    p_trip_info.consolidation_allowed,
    p_trip_info.load_tender_status,
    p_trip_info.load_tender_number,
    p_trip_info.wf_name,
    p_trip_info.wf_process_name,
    p_trip_info.wf_item_key,
    p_trip_info.carrier_contact_id,
    p_trip_info.shipper_wait_time,
    p_trip_info.wait_time_uom,
    p_trip_info.load_tendered_time,
    p_trip_info.vessel,
    p_trip_info.voyage_number,
    p_trip_info.port_of_loading,
    p_trip_info.port_of_discharge,
    p_trip_info.carrier_response,
    p_trip_info.route_lane_id,
    p_trip_info.lane_id,
    p_trip_info.schedule_id,
    p_trip_info.booking_number,
    nvl(p_trip_info.shipments_type_flag, 'O'),
/* J TP Release : ttrichy */
    --OTM R12, glog proj
    NVL(p_trip_info.ignore_for_planning, l_ignore_for_planning),
    p_trip_info.tp_plan_name,
    p_trip_info.tp_trip_number,
    p_trip_info.seal_code,
    p_trip_info.operator,
    p_trip_info.carrier_reference_number,
    p_trip_info.rank_id,
    p_trip_info.consignee_carrier_ac_no,
    p_trip_info.routing_rule_id,
    p_trip_info.append_flag
  )RETURNING rowid -- Bug 3821688
     INTO x_rowid;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --/== Workflow Changes
  IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.START_WF_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_WF_STD.start_wf_process(p_entity_type     => 'TRIP',
                              p_entity_id       => x_trip_id,
			      p_organization_id => NULL,
			      x_process_started => l_process_started,
			      x_return_status   => l_return_status);
  IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'L_PROCESS_STARTED',l_process_started);
	WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
  END IF;
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	NULL;
	-- x_return_status := l_return_status;
	-- Log an exception
  END IF;


  IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_WF_STD.RAISE_EVENT(p_entity_type   =>  'TRIP',
		       p_entity_id     =>  x_trip_id,
		       p_event         =>  'oracle.apps.wsh.trip.gen.create',
		       x_return_status =>  l_wf_rs
		      );

  IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
  END IF;
  -- Workflow Changes ==/


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN wsh_duplicate_name THEN
      -- OTM R12,glog proj, close any open cursor
      IF get_next_trip%ISOPEN THEN
        CLOSE get_next_trip;
      END IF;
      IF check_trip_names%ISOPEN THEN
        CLOSE check_trip_names;
      END IF;
      IF check_trip_ids%ISOPEN THEN
        CLOSE check_trip_ids;
      END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DUPLICATE_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DUPLICATE_NAME');
	   END IF;
	   --
     WHEN others THEN
      -- OTM R12,glog proj, close any open cursor
      IF get_next_trip%ISOPEN THEN
        CLOSE get_next_trip;
      END IF;
      IF check_trip_names%ISOPEN THEN
        CLOSE check_trip_names;
      END IF;
      IF check_trip_ids%ISOPEN THEN
        CLOSE check_trip_ids;
      END IF;
      wsh_util_core.default_handler('WSH_TRIPS_PVT.CREATE_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Create_Trip;

PROCEDURE Delete_Trip(
  p_rowid			IN	VARCHAR2,
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY 	VARCHAR2,
  p_validate_flag   IN   VARCHAR2,
--tkt
  p_caller        IN      VARCHAR2) IS

  CURSOR get_trip_id_rowid (v_rowid VARCHAR2) IS
  SELECT trip_id
  FROM   wsh_trips
  WHERE  rowid = v_rowid;

  CURSOR trip_deliveries (l_trip_id IN NUMBER) IS
  SELECT delivery_id
  FROM wsh_delivery_legs wdl,
       wsh_trip_stops wts
  WHERE wts.trip_id = l_trip_id
  AND wdl.pick_up_stop_id = wts.stop_id;

  CURSOR get_trip_stops ( c_trip_id IN NUMBER) IS
  SELECT stop_id FROM wsh_trip_stops WHERE trip_id = c_trip_id;

  --OTM R12, glog proj
  CURSOR c_get_trip_status (p_trip_id IN NUMBER) IS
  SELECT NVL(ignore_for_planning, 'N'),
         tp_plan_name
    FROM WSH_TRIPS
   WHERE trip_id = p_trip_id;

  l_ignore            WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;
  l_tp_plan_name      WSH_TRIPS.TP_PLAN_NAME%TYPE;
  l_gc3_is_installed  VARCHAR2(1);
  e_gc3_trip          EXCEPTION;
  --


  l_stop_id           NUMBER;
  l_trip_id	      NUMBER;
  l_del_ids           WSH_UTIL_CORE.ID_TAB_TYPE;
  l_return_status     VARCHAR2(1);

  cannot_delete_trip  EXCEPTION;
  others              EXCEPTION;

  l_stop_tab          WSH_UTIL_CORE.id_tab_type;  -- DBI Project
  l_dbi_rs            VARCHAR2(1);      -- DBI Project
  l_debug_on          BOOLEAN;

--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_TRIP';
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
       WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
   END IF;
   --
   x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_trip_id := p_trip_id;

   IF p_rowid IS NOT NULL THEN
      OPEN  get_trip_id_rowid(p_rowid);
      FETCH get_trip_id_rowid INTO l_trip_id;
      CLOSE get_trip_id_rowid;
   END IF;

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;

   IF l_gc3_is_installed = 'Y' THEN
     OPEN c_get_trip_status(l_trip_id);
     FETCH c_get_trip_status INTO l_ignore, l_tp_plan_name;
     IF c_get_trip_status%NOTFOUND THEN
       CLOSE c_get_trip_status;
       RAISE no_data_found;
     END IF;
     CLOSE c_get_trip_status;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Ignore for Planning',l_ignore);
       WSH_DEBUG_SV.log(l_module_name,'Tp Plan Name',l_tp_plan_name);
       WSH_DEBUG_SV.log(l_module_name,'GC3 is installed',l_gc3_is_installed);
     END IF;

     -- Do not allow user to delete a trip if it is include for Planning and created by OTM
     IF (l_ignore = 'N' AND l_tp_plan_name IS NOT NULL) THEN
       l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       RAISE e_gc3_trip;
     END IF;
   END IF;
   -- end of OTM R12, glog proj

   IF (p_validate_flag = 'Y') THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.CHECK_TRIP_DELETE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_trip_validations.check_trip_delete(l_trip_id, l_return_status, p_caller);

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE cannot_delete_trip;
      ELSE
	    x_return_status := l_return_status;
      END IF;
   END IF;

   IF l_trip_id IS NOT NULL THEN

	 FOR del IN trip_deliveries(l_trip_id) LOOP
	    l_del_ids(l_del_ids.count + 1) := del.delivery_id;
      END LOOP;

	 IF (l_del_ids.count > 0) THEN

	    SAVEPOINT unassign_del;

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.UNASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    wsh_delivery_legs_actions.unassign_deliveries(l_del_ids, l_trip_id, NULL, NULL, l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

		  ROLLBACK TO SAVEPOINT unassign_del;
	       RAISE cannot_delete_trip;

         END IF;

      END IF;

	 DELETE FROM wsh_freight_costs
	 WHERE  trip_id = l_trip_id;

	 open get_trip_stops(l_trip_id);
	 loop
	   fetch get_trip_stops into l_stop_id;
	   l_stop_tab(l_stop_tab.count+1) := l_stop_id;  -- DBI project
	   exit when get_trip_stops%NOTFOUND ;
	   DELETE FROM wsh_freight_costs WHERE  stop_id = l_stop_id;
	 end loop;
	 close get_trip_stops;

	 DELETE FROM wsh_trip_stops
	 WHERE  trip_id = l_trip_id;

 --
        -- DBI Project
        -- DELETE from  WSH_TRIP_STOPS.
        -- Call DBI API after the DELETE.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'DELETE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          rollback;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
 --

      DELETE FROM wsh_trips
      WHERE trip_id = l_trip_id;

	 IF (SQL%NOTFOUND) THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      END IF;
   ELSE
	 raise others;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     --OTM R12, glog proj
     WHEN e_gc3_trip THEN
       IF c_get_trip_status%ISOPEN THEN
         CLOSE c_get_trip_status;
       END IF;
       FND_MESSAGE.SET_NAME('WSH','WSH_OTM_TRIP_DELETE_ERROR');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'E_GC3_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_GC3_TRIP');
       END IF;
       --

     --OTM R12, glog proj
     WHEN no_data_found THEN
       IF c_get_trip_status%ISOPEN THEN
         CLOSE c_get_trip_status;
       END IF;
       FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
       END IF;
       --


       WHEN cannot_delete_trip THEN
         IF c_get_trip_status%ISOPEN THEN
           CLOSE c_get_trip_status;
         END IF;
	 FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_DELETE_ERROR');
         FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'CANNOT_DELETE_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANNOT_DELETE_TRIP');
	 END IF;
	 --
       WHEN others THEN
         -- OTM R12, glog proj
         IF c_get_trip_status%ISOPEN THEN
           CLOSE c_get_trip_status;
         END IF;
	 wsh_util_core.default_handler('WSH_TRIPS_PVT.DELETE_TRIP');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Delete_Trip;

PROCEDURE Update_Trip(
	p_rowid			IN	VARCHAR2,
	p_trip_info		IN	trip_rec_type,
	x_return_status 	OUT NOCOPY  	VARCHAR2) IS

CURSOR get_row_id IS
  SELECT rowid
  FROM wsh_trips
  WHERE trip_id = p_trip_info.trip_id;

l_rowid VARCHAR2(30);

  CURSOR c_iscarriersmcchanged IS
  SELECT wnd.organization_id, wnd.name
  FROM wsh_new_deliveries wnd, wsh_trip_stops wts, wsh_delivery_legs wdl
  WHERE wnd.delivery_id=wdl.delivery_id
      and wdl.pick_up_stop_id=wts.stop_id
      and wts.trip_id = p_trip_info.trip_id
      and (carrier_id <> p_trip_info.carrier_id
       OR ship_method_code <> p_trip_info.ship_method_code);

l_return_status    VARCHAR2 (1);
l_wh_type VARCHAR2(3);

--WF: CMR
l_wf_rs VARCHAR2(1);
l_del_ids WSH_UTIL_CORE.ID_TAB_TYPE;
l_del_old_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TRIP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'trip_id', p_trip_info.trip_id);
      WSH_DEBUG_SV.log(l_module_name,'name', p_trip_info.name);
      WSH_DEBUG_SV.log(l_module_name,'planned_flag', p_trip_info.planned_flag);
      WSH_DEBUG_SV.log(l_module_name,'arrive_after_trip_id', p_trip_info.arrive_after_trip_id);
      WSH_DEBUG_SV.log(l_module_name,'status_code', p_trip_info.status_code);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_item_id', p_trip_info.vehicle_item_id);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_organization_id', p_trip_info.vehicle_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_number', p_trip_info.vehicle_number);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_num_prefix', p_trip_info.vehicle_num_prefix);
      WSH_DEBUG_SV.log(l_module_name,'carrier_id', p_trip_info.carrier_id);
      WSH_DEBUG_SV.log(l_module_name,'ship_method_code', p_trip_info.ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'route_id', p_trip_info.route_id);
      WSH_DEBUG_SV.log(l_module_name,'routing_instructions', p_trip_info.routing_instructions);
      WSH_DEBUG_SV.log(l_module_name,'service_level', p_trip_info.service_level);
      WSH_DEBUG_SV.log(l_module_name,'mode_of_transport', p_trip_info.mode_of_transport);
      WSH_DEBUG_SV.log(l_module_name,'freight_terms_code', p_trip_info.freight_terms_code);
      WSH_DEBUG_SV.log(l_module_name,'consolidation_allowed', p_trip_info.consolidation_allowed);
      WSH_DEBUG_SV.log(l_module_name,'load_tender_status', p_trip_info.load_tender_status);
      WSH_DEBUG_SV.log(l_module_name,'load_tender_number', p_trip_info.load_tender_number);
      WSH_DEBUG_SV.log(l_module_name,'wf_name', p_trip_info.wf_name);
      WSH_DEBUG_SV.log(l_module_name,'wf_process_name', p_trip_info.wf_process_name);
      WSH_DEBUG_SV.log(l_module_name,'wf_item_key', p_trip_info.wf_item_key);
      WSH_DEBUG_SV.log(l_module_name,'carrier_contact_id', p_trip_info.carrier_contact_id);
      WSH_DEBUG_SV.log(l_module_name,'shipper_wait_time', p_trip_info.shipper_wait_time);
      WSH_DEBUG_SV.log(l_module_name,'wait_time_uom', p_trip_info.wait_time_uom);
      WSH_DEBUG_SV.log(l_module_name,'vessel', p_trip_info.vessel);
      WSH_DEBUG_SV.log(l_module_name,'voyage_number', p_trip_info.voyage_number);
      WSH_DEBUG_SV.log(l_module_name,'port_of_loading', p_trip_info.port_of_loading);
      WSH_DEBUG_SV.log(l_module_name,'port_of_discharge', p_trip_info.port_of_discharge);
      WSH_DEBUG_SV.log(l_module_name,'carrier_response', p_trip_info.carrier_response);
      WSH_DEBUG_SV.log(l_module_name,'route_lane_id', p_trip_info.route_lane_id);
      WSH_DEBUG_SV.log(l_module_name,'lane_id', p_trip_info.lane_id);
      WSH_DEBUG_SV.log(l_module_name,'schedule_id', p_trip_info.schedule_id);
      WSH_DEBUG_SV.log(l_module_name,'booking_number', p_trip_info.booking_number);

      WSH_DEBUG_SV.log(l_module_name,'carrier_reference_number', p_trip_info.carrier_reference_number);
      WSH_DEBUG_SV.log(l_module_name,'rank_id', p_trip_info.rank_id);
      WSH_DEBUG_SV.log(l_module_name,'consignee_carrier_ac_no', p_trip_info.consignee_carrier_ac_no);
      WSH_DEBUG_SV.log(l_module_name,'routing_rule_id', p_trip_info.routing_rule_id);
      WSH_DEBUG_SV.log(l_module_name,'append_flag', p_trip_info.append_flag);
  END IF;
  --
  IF (p_rowid IS NULL) THEN
     OPEN get_row_id;
     FETCH get_row_id INTO l_rowid;

     IF (get_row_id%NOTFOUND) THEN
        CLOSE get_row_id;
	   RAISE no_data_found;
     END IF;

     CLOSE get_row_id;
  ELSE
	l_rowid := p_rowid;
  END IF;

  /*CURRENTLY NOT IN USE
  --WF: CMR
  WSH_WF_STD.Get_Deliveries(p_trip_id => p_trip_info.trip_id,
                            x_del_ids => l_del_ids,
			    x_return_status => l_wf_rs);
  IF l_del_ids.COUNT > 0 THEN
    WSH_WF_STD.Get_Carrier(p_del_ids => l_del_ids,
                           x_del_old_carrier_ids => l_del_old_carrier_ids,
                           x_return_status => l_wf_rs);
  END IF;
  */

  UPDATE wsh_trips SET
    trip_id			= p_trip_info.trip_id,
    name				= p_trip_info.name,
    planned_flag		= p_trip_info.planned_flag,
    arrive_after_trip_id	= p_trip_info.arrive_after_trip_id,
    status_code		= p_trip_info.status_code,
    vehicle_item_id		= p_trip_info.vehicle_item_id,
    vehicle_organization_id     = p_trip_info.vehicle_organization_id,
    vehicle_number		= p_trip_info.vehicle_number,
    vehicle_num_prefix	= p_trip_info.vehicle_num_prefix,
    carrier_id			= p_trip_info.carrier_id,
    ship_method_code	= p_trip_info.ship_method_code,
    route_id			= p_trip_info.route_id,
    routing_instructions	= p_trip_info.routing_instructions,
    attribute_category	= p_trip_info.attribute_category,
    attribute1			= p_trip_info.attribute1,
    attribute2			= p_trip_info.attribute2,
    attribute3			= p_trip_info.attribute3,
    attribute4			= p_trip_info.attribute4,
    attribute5			= p_trip_info.attribute5,
    attribute6			= p_trip_info.attribute6,
    attribute7			= p_trip_info.attribute7,
    attribute8			= p_trip_info.attribute8,
    attribute9			= p_trip_info.attribute9,
    attribute10		= p_trip_info.attribute10,
    attribute11		= p_trip_info.attribute11,
    attribute12		= p_trip_info.attribute12,
    attribute13		= p_trip_info.attribute13,
    attribute14		= p_trip_info.attribute14,
    attribute15		= p_trip_info.attribute15,
    last_update_date	= p_trip_info.last_update_date,
    last_updated_by		= p_trip_info.last_updated_by,
    last_update_login		= p_trip_info.last_update_login,
    program_application_id	= p_trip_info.program_application_id,
    program_id			= p_trip_info.program_id,
    program_update_date	= p_trip_info.program_update_date,
    request_id			= p_trip_info.request_id,
/* H Integration: datamodel changes wrudge */
    service_level		= p_trip_info.service_level,
    mode_of_transport		= p_trip_info.mode_of_transport,
    freight_terms_code		= p_trip_info.freight_terms_code,
    consolidation_allowed	= p_trip_info.consolidation_allowed,
    load_tender_status		= p_trip_info.load_tender_status,
    load_tender_number		= p_trip_info.load_tender_number,
    wf_name		        = p_trip_info.wf_name,
    wf_process_name		= p_trip_info.wf_process_name,
    wf_item_key		        = p_trip_info.wf_item_key,
    carrier_contact_id		= p_trip_info.carrier_contact_id,
    shipper_wait_time		= p_trip_info.shipper_wait_time,
    wait_time_uom		= p_trip_info.wait_time_uom,
    load_tendered_time		= p_trip_info.load_tendered_time,
    vessel		        = p_trip_info.vessel,
    voyage_number		= p_trip_info.voyage_number,
    port_of_loading		= p_trip_info.port_of_loading,
    port_of_discharge		= p_trip_info.port_of_discharge,
    carrier_response		= p_trip_info.carrier_response,
    route_lane_id		= p_trip_info.route_lane_id,
    lane_id			= p_trip_info.lane_id,
    schedule_id			= p_trip_info.schedule_id,
    booking_number		= p_trip_info.booking_number,
/* J Inbound Logistics: new columns jckwok */
    shipments_type_flag         = nvl(p_trip_info.shipments_type_flag, 'O'),
/* J TP Release : ttrichy */
 IGNORE_FOR_PLANNING    = nvl(p_trip_info.IGNORE_FOR_PLANNING, 'N'),
 TP_PLAN_NAME           = p_trip_info.TP_PLAN_NAME,
 TP_TRIP_NUMBER         = p_trip_info.TP_TRIP_NUMBER,
    seal_code           = p_trip_info.seal_code,
    operator           = p_trip_info.operator,
    carrier_reference_number = p_trip_info.carrier_reference_number,
    rank_id                  = p_trip_info.rank_id,
    consignee_carrier_ac_no  = p_trip_info.consignee_carrier_ac_no,
    routing_rule_id          = p_trip_info.routing_rule_id,
    append_flag              = p_trip_info.append_flag
  WHERE rowid = l_rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
  END IF;

  /*CURRENTLY NOT IN USE
  --WF: CMR
  IF l_del_ids.COUNT > 0 THEN
  WSH_WF_STD.Handle_Trip_Carriers(p_trip_id => p_trip_info.trip_id,
			          p_del_ids => l_del_ids,
			          p_del_old_carrier_ids => l_del_old_carrier_ids,
			          x_return_status => l_wf_rs);
  END IF;
  */
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
	   END IF;
	   --
     --Bug # 3268641
     WHEN DUP_VAL_ON_INDEX THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_ASSIGN_NEW_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

	   IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'DUP_VAL_ON_INDEX exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DUP_VAL_ON_INDEX');
	   END IF;
     --


     WHEN others THEN
	   wsh_util_core.default_handler('WSH_TRIPS_PVT.UPDATE_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Trip;


PROCEDURE Lock_Trip (
	p_rowid                 IN   VARCHAR2,
	p_trip_info             IN   trip_rec_type
	) IS

CURSOR lock_row IS
SELECT
       TRIP_ID,
       NAME,
       PLANNED_FLAG,
       ARRIVE_AFTER_TRIP_ID,
       STATUS_CODE,
       VEHICLE_ITEM_ID,
       VEHICLE_ORGANIZATION_ID,
       VEHICLE_NUMBER,
       VEHICLE_NUM_PREFIX,
       CARRIER_ID,
       SHIP_METHOD_CODE,
       ROUTE_ID,
       ROUTING_INSTRUCTIONS,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       REQUEST_ID,
/* H Integration: datamodel changes wrudge */
       SERVICE_LEVEL,
       MODE_OF_TRANSPORT,
       FREIGHT_TERMS_CODE,
       CONSOLIDATION_ALLOWED,
       LOAD_TENDER_STATUS,
       ROUTE_LANE_ID,
       LANE_ID,
       SCHEDULE_ID,
       BOOKING_NUMBER,
/* I WSH-FTE Load Tender Integration */
       LOAD_TENDER_NUMBER,
       VESSEL,
       VOYAGE_NUMBER,
       PORT_OF_LOADING,
       PORT_OF_DISCHARGE,
       WF_NAME,
       WF_PROCESS_NAME,
       WF_ITEM_KEY,
       CARRIER_CONTACT_ID,
       SHIPPER_WAIT_TIME,
       WAIT_TIME_UOM,
       LOAD_TENDERED_TIME,
       CARRIER_RESPONSE,
/* J Inbound Logistics: new columns */
       SHIPMENTS_TYPE_FLAG,
/* J TP Release : ttrichy */
       IGNORE_FOR_PLANNING,
       TP_PLAN_NAME,
       TP_TRIP_NUMBER,
       SEAL_CODE,
       OPERATOR,
/* R12 attributes */
       CARRIER_REFERENCE_NUMBER,
       RANK_ID,
       CONSIGNEE_CARRIER_AC_NO,
       ROUTING_RULE_ID,
       APPEND_FLAG
FROM wsh_trips
WHERE rowid = p_rowid
FOR UPDATE OF trip_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

  l_gc3_is_installed    VARCHAR2(1); -- OTM R12, glog proj
  l_ignore_flag         WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;--OTM R12, glog proj

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_TRIP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'trip_id', p_trip_info.trip_id);
      WSH_DEBUG_SV.log(l_module_name,'name', p_trip_info.name);
      WSH_DEBUG_SV.log(l_module_name,'planned_flag', p_trip_info.planned_flag);
      WSH_DEBUG_SV.log(l_module_name,'arrive_after_trip_id', p_trip_info.arrive_after_trip_id);
      WSH_DEBUG_SV.log(l_module_name,'status_code', p_trip_info.status_code);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_item_id', p_trip_info.vehicle_item_id);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_organization_id', p_trip_info.vehicle_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_number', p_trip_info.vehicle_number);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_num_prefix', p_trip_info.vehicle_num_prefix);
      WSH_DEBUG_SV.log(l_module_name,'carrier_id', p_trip_info.carrier_id);
      WSH_DEBUG_SV.log(l_module_name,'ship_method_code', p_trip_info.ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'route_id', p_trip_info.route_id);
      WSH_DEBUG_SV.log(l_module_name,'routing_instructions', p_trip_info.routing_instructions);
      WSH_DEBUG_SV.log(l_module_name,'service_level', p_trip_info.service_level);
      WSH_DEBUG_SV.log(l_module_name,'mode_of_transport', p_trip_info.mode_of_transport);
      WSH_DEBUG_SV.log(l_module_name,'freight_terms_code', p_trip_info.freight_terms_code);
      WSH_DEBUG_SV.log(l_module_name,'consolidation_allowed', p_trip_info.consolidation_allowed);
      WSH_DEBUG_SV.log(l_module_name,'load_tender_status', p_trip_info.load_tender_status);
      WSH_DEBUG_SV.log(l_module_name,'route_lane_id', p_trip_info.route_lane_id);
      WSH_DEBUG_SV.log(l_module_name,'lane_id', p_trip_info.lane_id);
      WSH_DEBUG_SV.log(l_module_name,'schedule_id', p_trip_info.schedule_id);
      WSH_DEBUG_SV.log(l_module_name,'booking_number', p_trip_info.booking_number);

      WSH_DEBUG_SV.log(l_module_name,'carrier_reference_number', p_trip_info.carrier_reference_number);
      WSH_DEBUG_SV.log(l_module_name,'consignee_carrier_ac_no', p_trip_info.consignee_carrier_ac_no);
      WSH_DEBUG_SV.log(l_module_name,'rank_id', p_trip_info.rank_id);
      WSH_DEBUG_SV.log(l_module_name,'routing_rule_id', p_trip_info.routing_rule_id);
      WSH_DEBUG_SV.log(l_module_name,'append_flag', p_trip_info.append_flag);
   END IF;
   --

  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;

  IF l_gc3_is_installed = 'Y' THEN
    l_ignore_flag := 'Y';
  ELSE
    l_ignore_flag := 'N';
  END IF;
  -- end of OTM R12, glog proj


   OPEN  lock_row;
   FETCH lock_row INTO Recinfo;

   IF (lock_row%NOTFOUND) THEN
      CLOSE lock_row;
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
      IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:app_exception');
      END IF;
      app_exception.raise_exception;
   END IF;

   CLOSE lock_row;

   IF (
              (Recinfo.Trip_Id = p_trip_info.Trip_Id)
       AND    (Recinfo.Name = p_trip_info.Name)
       AND    (Recinfo.Planned_Flag = p_trip_info.Planned_Flag)
       AND 	 (Recinfo.Status_Code = p_trip_info.Status_Code)
       AND (  (Recinfo.Arrive_After_Trip_Id = p_trip_info.Arrive_After_Trip_Id)
              OR (  (Recinfo.Arrive_After_Trip_Id IS NULL)
                  AND  (p_trip_info.Arrive_After_Trip_Id IS NULL)))
       AND (  (Recinfo.Vehicle_Item_Id = p_trip_info.Vehicle_Item_Id)
              OR (  (Recinfo.Vehicle_Item_Id IS NULL)
                  AND  (p_trip_info.Vehicle_Item_Id IS NULL)))
       AND (  (Recinfo.Vehicle_Organization_Id = p_trip_info.Vehicle_Organization_Id)
              OR (  (Recinfo.Vehicle_Organization_Id IS NULL)
                  AND  (p_trip_info.Vehicle_Organization_Id IS NULL)))
       AND (  (Recinfo.Vehicle_Number = p_trip_info.Vehicle_Number)
              OR (  (Recinfo.Vehicle_Number IS NULL)
                AND  (p_trip_info.Vehicle_Number IS NULL)))
       AND (  (Recinfo.Vehicle_Num_Prefix = p_trip_info.Vehicle_Num_Prefix)
              OR (  (Recinfo.Vehicle_Num_Prefix IS NULL)
                AND  (p_trip_info.Vehicle_Num_Prefix IS NULL)))
       AND (  (Recinfo.Carrier_Id = p_trip_info.Carrier_Id)
            OR (  (Recinfo.Carrier_Id IS NULL)
                AND  (p_trip_info.Carrier_Id IS NULL)))
       AND (  (Recinfo.Ship_Method_Code = p_trip_info.Ship_Method_Code)
            OR (  (Recinfo.Ship_Method_Code IS NULL)
                AND  (p_trip_info.Ship_Method_Code IS NULL)))
       AND (  (Recinfo.Route_Id = p_trip_info.Route_Id)
            OR (  (Recinfo.Route_Id IS NULL)
                AND  (p_trip_info.Route_Id IS NULL)))
       AND (  (Recinfo.Routing_Instructions = p_trip_info.Routing_Instructions)
            OR (  (Recinfo.Routing_Instructions IS NULL)
                AND  (p_trip_info.Routing_Instructions IS NULL)))
       AND (  (Recinfo.Creation_Date = p_trip_info.Creation_Date)
            OR (  (Recinfo.Creation_Date IS NULL)
                AND  (p_trip_info.Creation_Date IS NULL)))
       AND (  (Recinfo.Created_By = p_trip_info.Created_By)
            OR (  (Recinfo.Created_By IS NULL)
                AND  (p_trip_info.Created_By IS NULL)))
       AND (  (Recinfo.Last_Update_Date = p_trip_info.Last_Update_Date)
            OR (  (Recinfo.Last_Update_Date IS NULL)
                AND  (p_trip_info.Last_Update_Date IS NULL)))
       AND (  (Recinfo.Last_Updated_By = p_trip_info.Last_Updated_By)
            OR (  (Recinfo.Last_Updated_By IS NULL)
                AND  (p_trip_info.Last_Updated_By IS NULL)))
       AND (  (Recinfo.Last_Update_Login = p_trip_info.Last_Update_Login)
            OR (  (Recinfo.Last_Update_Login IS NULL)
                AND  (p_trip_info.Last_Update_Login IS NULL)))
       AND (  (Recinfo.Program_Application_Id = p_trip_info.Program_Application_Id)
            OR (  (Recinfo.Program_Application_Id IS NULL)
                AND  (p_trip_info.Program_Application_Id IS NULL)))
       AND (  (Recinfo.Program_Id = p_trip_info.Program_Id)
            OR (  (Recinfo.Program_Id IS NULL)
                AND  (p_trip_info.Program_Id IS NULL)))
       AND (  (Recinfo.Program_Update_Date = p_trip_info.Program_Update_Date)
            OR (  (Recinfo.Program_Update_Date IS NULL)
                AND  (p_trip_info.Program_Update_Date IS NULL)))
       AND (  (Recinfo.Request_Id = p_trip_info.Request_Id)
            OR (  (Recinfo.Request_Id IS NULL)
                AND  (p_trip_info.Request_Id IS NULL)))
       AND (  (Recinfo.Attribute_Category = p_trip_info.Attribute_Category)
            OR (  (Recinfo.Attribute_Category IS NULL)
                AND  (p_trip_info.Attribute_Category IS NULL)))
       AND (  (Recinfo.Attribute1 = p_trip_info.Attribute1)
            OR (  (Recinfo.Attribute1 IS NULL)
                AND  (p_trip_info.Attribute1 IS NULL)))
       AND (  (Recinfo.Attribute2 = p_trip_info.Attribute2)
            OR (  (Recinfo.Attribute2 IS NULL)
                AND  (p_trip_info.Attribute2 IS NULL)))
       AND (  (Recinfo.Attribute3 = p_trip_info.Attribute3)
            OR (  (Recinfo.Attribute3 IS NULL)
                AND  (p_trip_info.Attribute3 IS NULL)))
       AND (  (Recinfo.Attribute4 = p_trip_info.Attribute4)
            OR (  (Recinfo.Attribute4 IS NULL)
                AND  (p_trip_info.Attribute4 IS NULL)))
       AND (  (Recinfo.Attribute5 = p_trip_info.Attribute5)
            OR (  (Recinfo.Attribute5 IS NULL)
                AND  (p_trip_info.Attribute5 IS NULL)))
       AND (  (Recinfo.Attribute6 = p_trip_info.Attribute6)
            OR (  (Recinfo.Attribute6 IS NULL)
                AND  (p_trip_info.Attribute6 IS NULL)))
       AND (  (Recinfo.Attribute7 = p_trip_info.Attribute7)
            OR (  (Recinfo.Attribute7 IS NULL)
                AND  (p_trip_info.Attribute7 IS NULL)))
       AND (  (Recinfo.Attribute8 = p_trip_info.Attribute8)
            OR (  (Recinfo.Attribute8 IS NULL)
                AND  (p_trip_info.Attribute8 IS NULL)))
       AND (  (Recinfo.Attribute9 = p_trip_info.Attribute9)
            OR (  (Recinfo.Attribute9 IS NULL)
                AND  (p_trip_info.Attribute9 IS NULL)))
       AND (  (Recinfo.Attribute10 = p_trip_info.Attribute10)
            OR (  (Recinfo.Attribute10 IS NULL)
                AND  (p_trip_info.Attribute10 IS NULL)))
       AND (  (Recinfo.Attribute11 = p_trip_info.Attribute11)
            OR (  (Recinfo.Attribute11 IS NULL)
                AND  (p_trip_info.Attribute11 IS NULL)))
       AND (  (Recinfo.Attribute12 = p_trip_info.Attribute12)
            OR (  (Recinfo.Attribute12 IS NULL)
                AND  (p_trip_info.Attribute12 IS NULL)))
       AND (  (Recinfo.Attribute13 = p_trip_info.Attribute13)
            OR (  (Recinfo.Attribute13 IS NULL)
                AND  (p_trip_info.Attribute13 IS NULL)))
       AND (  (Recinfo.Attribute14 = p_trip_info.Attribute14)
            OR (  (Recinfo.Attribute14 IS NULL)
                AND  (p_trip_info.Attribute14 IS NULL)))
       AND (  (Recinfo.Attribute15 = p_trip_info.Attribute15)
            OR (  (Recinfo.Attribute15 IS NULL)
                AND  (p_trip_info.Attribute15 IS NULL)))
/* H Integration: datamodel changes wrudge */
       AND (  (Recinfo.service_level = p_trip_info.service_level)
            OR (  (Recinfo.service_level IS NULL)
                AND  (p_trip_info.service_level IS NULL)))
       AND (  (Recinfo.mode_of_transport = p_trip_info.mode_of_transport)
            OR (  (Recinfo.mode_of_transport IS NULL)
                AND  (p_trip_info.mode_of_transport IS NULL)))
       AND (  (Recinfo.freight_terms_code = p_trip_info.freight_terms_code)
            OR (  (Recinfo.freight_terms_code IS NULL)
                AND  (p_trip_info.freight_terms_code IS NULL)))
       AND (  (Recinfo.consolidation_allowed = p_trip_info.consolidation_allowed)
            OR (  (Recinfo.consolidation_allowed IS NULL)
                AND  (p_trip_info.consolidation_allowed IS NULL)))
       AND (  (Recinfo.load_tender_status = p_trip_info.load_tender_status)
            OR (  (Recinfo.load_tender_status IS NULL)
                AND  (p_trip_info.load_tender_status IS NULL)))
       AND (  (Recinfo.route_lane_id = p_trip_info.route_lane_id)
            OR (  (Recinfo.route_lane_id IS NULL)
                AND  (p_trip_info.route_lane_id IS NULL)))
       AND (  (Recinfo.lane_id = p_trip_info.lane_id)
            OR (  (Recinfo.lane_id IS NULL)
                AND  (p_trip_info.lane_id IS NULL)))
       AND (  (Recinfo.schedule_id = p_trip_info.schedule_id)
            OR (  (Recinfo.schedule_id IS NULL)
                AND  (p_trip_info.schedule_id IS NULL)))
       AND (  (Recinfo.booking_number = p_trip_info.booking_number)
            OR (  (Recinfo.booking_number IS NULL)
                AND  (p_trip_info.booking_number IS NULL)))
       AND (  (nvl(Recinfo.shipments_type_flag, 'O') = nvl(p_trip_info.shipments_type_flag,'O') )
            OR (  (Recinfo.shipments_type_flag IS NULL)
                AND  (p_trip_info.shipments_type_flag IS NULL)))
/* J TP Release : ttrichy */
       -- OTM R12, glog project, for l_ignore_flag
       AND (nvl(Recinfo.IGNORE_FOR_PLANNING, l_ignore_flag) = nvl(p_trip_info.ignore_for_planning,l_ignore_flag))
       AND (  (Recinfo.TP_PLAN_NAME = p_trip_info.TP_PLAN_NAME)
            OR (  (Recinfo.TP_PLAN_NAME IS NULL)
                AND  (p_trip_info.TP_PLAN_NAME IS NULL)))
       AND (  (Recinfo.TP_TRIP_NUMBER = p_trip_info.TP_TRIP_NUMBER )
            OR (  (Recinfo.TP_TRIP_NUMBER IS NULL)
                AND  (p_trip_info.TP_TRIP_NUMBER IS NULL)))
       AND (  (Recinfo.seal_code = p_trip_info.seal_code )
            OR (  (Recinfo.seal_code IS NULL)
                AND  (p_trip_info.seal_code IS NULL)))
       AND (  (Recinfo.operator = p_trip_info.operator )
            OR (  (Recinfo.operator IS NULL)
                AND  (p_trip_info.operator IS NULL)))
       AND (  (Recinfo.carrier_reference_number = p_trip_info.carrier_reference_number )
            OR (  (Recinfo.carrier_reference_number IS NULL)
                AND  (p_trip_info.carrier_reference_number IS NULL)))
       AND (  (Recinfo.consignee_carrier_ac_no = p_trip_info.consignee_carrier_ac_no )
            OR (  (Recinfo.consignee_carrier_ac_no IS NULL)
                AND  (p_trip_info.consignee_carrier_ac_no IS NULL)))
       -- do not check these columns because they are not in WSH UI
       --    ROUTING_RULE_ID
       --    APPEND_FLAG
       --    RANK_ID
   ) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:app_exception');
      END IF;
      app_exception.raise_exception;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
      if (lock_row%ISOPEN) then
	close lock_row;
      end if;
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
      END IF;
      --
      RAISE;
      --
    WHEN others THEN
      --
      if (lock_row%ISOPEN) then
	close lock_row;
      end if;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      raise;
      --
END Lock_Trip;

Procedure Populate_Record(
	p_trip_id           IN   NUMBER,
	x_trip_info         OUT NOCOPY   trip_rec_type,
	x_return_status     OUT NOCOPY   VARCHAR2) IS

CURSOR trip_record(p_ignore_flag IN VARCHAR2) IS
SELECT
       TRIP_ID,
       NAME,
       PLANNED_FLAG,
       ARRIVE_AFTER_TRIP_ID,
       STATUS_CODE,
       VEHICLE_ITEM_ID,
       VEHICLE_ORGANIZATION_ID,
       VEHICLE_NUMBER,
       VEHICLE_NUM_PREFIX,
       CARRIER_ID,
       SHIP_METHOD_CODE,
       ROUTE_ID,
       ROUTING_INSTRUCTIONS,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       REQUEST_ID,
/* H Integration: datamodel changes wrudge */
       SERVICE_LEVEL,
       MODE_OF_TRANSPORT,
       FREIGHT_TERMS_CODE,
       CONSOLIDATION_ALLOWED,
       LOAD_TENDER_STATUS,
       ROUTE_LANE_ID,
       LANE_ID,
       SCHEDULE_ID,
       BOOKING_NUMBER,
/* I Harmonization: Nondatabase Columns Added rvishnuv */
       ROWID,
       NULL,
       NULL,
       NULL,
       NULL,
/* I WSH-FTE Load Tender Integration */
       LOAD_TENDER_NUMBER,
       VESSEL,
       VOYAGE_NUMBER,
       PORT_OF_LOADING,
       PORT_OF_DISCHARGE,
       WF_NAME,
       WF_PROCESS_NAME,
       WF_ITEM_KEY,
       CARRIER_CONTACT_ID,
       SHIPPER_WAIT_TIME,
       WAIT_TIME_UOM,
       LOAD_TENDERED_TIME,
       CARRIER_RESPONSE,
/* J Inbound Logistics: new columns */
       SHIPMENTS_TYPE_FLAG,
/* J TP Release : ttrichy */
        --OTM R12,glog proj
        NVL(ignore_for_planning, p_ignore_flag),
       TP_PLAN_NAME,
       TP_TRIP_NUMBER,
       SEAL_CODE,
       OPERATOR,
/* R12 attributes */
       CARRIER_REFERENCE_NUMBER,
       RANK_ID,
       CONSIGNEE_CARRIER_AC_NO,
       ROUTING_RULE_ID,
       APPEND_FLAG
FROM   wsh_trips
WHERE  trip_id = p_trip_id;

others EXCEPTION;

  l_ignore_for_planning WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;
  l_gc3_is_installed    VARCHAR2(1); -- OTM R12, glog proj

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_RECORD';
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
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   IF (p_trip_id IS NULL) THEN
	 raise others;
   END IF;

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   IF l_gc3_is_installed = 'Y' THEN
     l_ignore_for_planning := 'Y';
   ELSE
     l_ignore_for_planning := 'N';
   END IF;
   -- end of OTM R12, glog proj

   OPEN  trip_record(l_ignore_for_planning);
   FETCH trip_record INTO x_trip_info;

   IF (trip_record%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
   ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

   CLOSE trip_record;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
      WHEN others THEN
	    wsh_util_core.default_handler('WSH_TRIPS_PVT.POPULATE_RECORD');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Populate_Record;



  FUNCTION Get_Name
		(p_trip_id		IN	NUMBER
		 ) RETURN VARCHAR2 IS

  CURSOR get_name IS
  SELECT name
  FROM   wsh_trips
  WHERE  trip_id = p_trip_id;

  x_name VARCHAR2(30);

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_NAME';
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
         WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
     END IF;
     --
     IF (p_trip_id IS NULL) THEN
        raise others;
     END IF;

     OPEN  get_name;
     FETCH get_name INTO x_name;
     CLOSE get_name;

     IF (x_name IS NULL) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN null;
     END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN x_name;

     EXCEPTION

        WHEN others THEN
	      wsh_util_core.default_handler('WSH_TRIPS_PVT.GET_NAME');
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.pop(l_module_name);
		 END IF;
		 --
		 RETURN null;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Get_Name;

procedure Lock_Trip(
	p_rec_attr_tab		IN		Trip_Attr_Tbl_Type,
        p_caller		IN		VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
	x_return_status		OUT		NOCOPY VARCHAR2
)
IS
--
--
l_index NUMBER := 0;
l_num_errors NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_TRIP_WRAPPER';
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
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'Total Number of Trip Records being locked',p_valid_index_tab.COUNT);
  END IF;
  --
  --
  l_index := p_valid_index_tab.FIRST;
  --
  while l_index is not null loop
    begin
      --
      savepoint lock_trip_loop;
      --
      IF p_caller = 'WSH_FSTRX' THEN
         lock_trip(p_rowid	    => p_rec_attr_tab(l_index).rowid,
  	           p_trip_info => p_rec_attr_tab(l_index)
                  );
      ELSE
         lock_trip_no_compare(p_rec_attr_tab(l_index).trip_id);
      END IF;

      IF nvl(p_caller,FND_API.G_MISS_CHAR) <> 'WSH_FSTRX' THEN
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := p_rec_attr_tab(l_index).trip_id;
      ELSE
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := l_index;
      END IF;
      --
    exception
      --
      WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
        rollback to lock_trip_loop;
       IF nvl(p_caller,FND_API.G_MISS_CHAR) = 'WSH_PUB'
          OR nvl(p_caller, '!') like 'FTE%' THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_LOCK_FAILED');
          FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_rec_attr_tab(l_index).name);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        END IF;

        l_num_errors := l_num_errors + 1;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Unable to obtain lock on the Trip Id',p_rec_attr_tab(l_index).trip_id);
      END IF;
      --
      WHEN others THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    --
    l_index := p_valid_index_tab.NEXT(l_index);
    --
  end loop;

  IF p_valid_index_tab.COUNT = 0 THEN
    x_return_status := wsh_util_core.g_ret_sts_success;
  ELSIF l_num_errors = p_valid_index_tab.COUNT THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PERFORMED');
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PERFORMED');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_num_errors > 0 THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PROCESSED');
    x_return_status := wsh_util_core.g_ret_sts_warning;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PROCESSED');
    END IF;
    raise wsh_util_core.g_exc_warning;
  ELSE
    x_return_status := wsh_util_core.g_ret_sts_success;
  END IF;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  --
  WHEN FND_API.G_EXC_ERROR THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
  --
  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
    x_return_status := wsh_util_core.g_ret_sts_warning;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
    END IF;
  --
  WHEN OTHERS THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.LOCK_TRIP_WRAPPER',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
  --
END Lock_Trip;


PROCEDURE lock_trip_no_compare (p_trip_id IN NUMBER)
IS
   l_trip_id  NUMBER;
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                || 'lock_trip_no_compare';
   CURSOR c_lock_trip IS
   SELECT trip_id
   FROM wsh_trips
   WHERE trip_id = p_trip_id
   FOR UPDATE NOWAIT;

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
      WSH_DEBUG_SV.log(l_module_name,'p_trip_id',p_trip_id);
  END IF;

  OPEN c_lock_trip;
  FETCH c_lock_trip INTO l_trip_id;
  CLOSE c_lock_trip;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'trip id is locked',l_trip_id);
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN app_exception.application_exception
     OR app_exception.record_lock_exception THEN
       IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Could not lock trip', p_trip_id);
           WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:APPLICTION_EXCEPTION');
       END IF;
       --
       RAISE;

   WHEN OTHERS THEN
      --
      wsh_util_core.default_handler('WSH_TRIPS_PVT.lock_trip_no_compare',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RAISE;
END lock_trip_no_compare;

END WSH_TRIPS_PVT;

/
