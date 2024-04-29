--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_STOPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_STOPS_PVT" AS
/* $Header: WSHSTTHB.pls 120.3.12010000.2 2008/08/21 06:04:26 sankarun ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRIP_STOPS_PVT';
--
PROCEDURE Create_Trip_Stop(
  p_trip_stop_info	IN  trip_stop_rec_type,
  x_rowid			OUT NOCOPY  VARCHAR2,
  x_stop_id		OUT NOCOPY  NUMBER,
  x_return_status	OUT NOCOPY  VARCHAR2
)
IS

  CURSOR get_next_stop IS
    SELECT wsh_trip_stops_s.nextval
    FROM sys.dual;

  CURSOR check_stop IS
    SELECT rowid
    FROM wsh_trip_stops
    WHERE stop_id = x_stop_id;

  l_row_count       NUMBER;
  l_temp_id         NUMBER;
  l_physical_loc_id NUMBER;
  l_return_status   VARCHAR2(1);
  l_trips            wsh_util_core.id_tab_type;
  l_success_trip_ids wsh_util_core.id_tab_type;
  others	EXCEPTION;
  get_physical_loc_err  EXCEPTION;

  cursor l_trip_shipments_type_csr(p_trip_id IN NUMBER) is
  select decode(shipments_type_flag, 'M', 'O', shipments_type_flag)
  from   wsh_trips
  where  trip_id = p_trip_id;

  l_shipments_type_flag VARCHAR2(100);

  l_stop_tab WSH_UTIL_CORE.id_tab_type; -- DBI Project
  l_dbi_rs            VARCHAR2(1);      -- DBI Project

  l_wf_rs	VARCHAR2(1);	-- Workflow Project
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_TRIP_STOP';
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
      WSH_DEBUG_SV.log(l_module_name,'STOP_ID',p_trip_stop_info.STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_trip_stop_info.TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'STOP_LOCATION_ID',p_trip_stop_info.STOP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_trip_stop_info.STATUS_CODE);
      WSH_DEBUG_SV.log(l_module_name,'STOP_SEQUENCE_NUMBER',p_trip_stop_info.STOP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_ARRIVAL_DATE',p_trip_stop_info.PLANNED_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_DEPARTURE_DATE',p_trip_stop_info.PLANNED_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_ARRIVAL_DATE',p_trip_stop_info.ACTUAL_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_DEPARTURE_DATE',p_trip_stop_info.ACTUAL_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_GROSS_WEIGHT',p_trip_stop_info.DEPARTURE_GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_NET_WEIGHT',p_trip_stop_info.DEPARTURE_NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'WEIGHT_UOM_CODE',p_trip_stop_info.WEIGHT_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_VOLUME',p_trip_stop_info.DEPARTURE_VOLUME);
      WSH_DEBUG_SV.log(l_module_name,'VOLUME_UOM_CODE',p_trip_stop_info.VOLUME_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_SEAL_CODE',p_trip_stop_info.DEPARTURE_SEAL_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_FILL_PERCENT',p_trip_stop_info.DEPARTURE_FILL_PERCENT);
      WSH_DEBUG_SV.log(l_module_name,'WSH_LOCATION_ID',p_trip_stop_info.WSH_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_DRILLDOWN_FLAG',p_trip_stop_info.TRACKING_DRILLDOWN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_REMARKS',p_trip_stop_info.TRACKING_REMARKS);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_DEPARTURE_DATE',p_trip_stop_info.CARRIER_EST_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_ARRIVAL_DATE',p_trip_stop_info.CARRIER_EST_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_START_DATETIME',p_trip_stop_info.LOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_END_DATETIME',p_trip_stop_info.LOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_START_DATETIME',p_trip_stop_info.UNLOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_END_DATETIME',p_trip_stop_info.UNLOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'SHIPMENTS_TYPE_FLAG',p_trip_stop_info.SHIPMENTS_TYPE_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_trips.DELETE;
  x_stop_id := p_trip_stop_info.stop_id;

  l_shipments_type_flag := p_trip_stop_info.shipments_type_flag;

  IF (l_shipments_type_flag is null) THEN
    open  l_trip_shipments_type_csr(p_trip_stop_info.trip_id);
    fetch l_trip_shipments_type_csr into l_shipments_type_flag;
    close l_trip_shipments_type_csr;
  END IF;


  IF (x_stop_id IS NULL) THEN

    LOOP

       OPEN  get_next_stop;
       FETCH get_next_stop INTO x_stop_id;
       CLOSE get_next_stop;

	  IF (x_stop_id IS NOT NULL) THEN
	     x_rowid := NULL;

  	     OPEN  check_stop;
	     FETCH check_stop INTO x_rowid;
	     CLOSE check_stop;

	     IF ( x_rowid IS NULL ) THEN
		   EXIT;
	     END IF;
       ELSE
		EXIT;
       END IF;

    END LOOP;

  END IF;


  WSH_LOCATIONS_PKG.Convert_internal_cust_location(
                 p_internal_cust_location_id  => p_trip_stop_info.stop_location_id,
                 x_internal_org_location_id   => l_physical_loc_id,
                 x_return_status              => l_return_status );

  IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
     raise get_physical_loc_err;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_physical_loc_id',l_physical_loc_id);
  END IF;

  INSERT INTO wsh_trip_stops(
    stop_id,
    trip_id,
    stop_location_id,
    status_code,
    stop_sequence_number,
    planned_arrival_date,
    planned_departure_date,
    actual_arrival_date,
    actual_departure_date,
    departure_gross_weight,
    departure_net_weight,
    weight_uom_code,
    departure_volume,
    volume_uom_code,
    departure_seal_code,
    departure_fill_percent,
    tp_attribute_category,
    tp_attribute1,
    tp_attribute2,
    tp_attribute3,
    tp_attribute4,
    tp_attribute5,
    tp_attribute6,
    tp_attribute7,
    tp_attribute8,
    tp_attribute9,
    tp_attribute10,
    tp_attribute11,
    tp_attribute12,
    tp_attribute13,
    tp_attribute14,
    tp_attribute15,
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
    wsh_location_id,
    tracking_drilldown_flag,
    tracking_remarks,
    carrier_est_departure_date,
    carrier_est_arrival_date,
    loading_start_datetime,
    loading_end_datetime,
    unloading_start_datetime,
    unloading_end_datetime,
    shipments_type_flag,
    -- J: W/V Changes
    wv_frozen_flag,
    wkend_layover_stops,
    wkday_layover_stops,
    tp_stop_id,
    physical_stop_id,
    physical_location_id,
    tms_interface_flag   -- OTM R12, glog proj
  ) values(

    x_stop_id,
    p_trip_stop_info.trip_id,
    p_trip_stop_info.stop_location_id,
    nvl(p_trip_stop_info.status_code,'OP'),
    nvl(p_trip_stop_info.stop_sequence_number,0),
    nvl(p_trip_stop_info.planned_arrival_date,SYSDATE),
    nvl(p_trip_stop_info.planned_departure_date,SYSDATE),
    p_trip_stop_info.actual_arrival_date,
    p_trip_stop_info.actual_departure_date,
    p_trip_stop_info.departure_gross_weight,
    p_trip_stop_info.departure_net_weight,
    p_trip_stop_info.weight_uom_code,
    p_trip_stop_info.departure_volume,
    p_trip_stop_info.volume_uom_code,
    p_trip_stop_info.departure_seal_code,
    p_trip_stop_info.departure_fill_percent,
    p_trip_stop_info.tp_attribute_category,
    p_trip_stop_info.tp_attribute1,
    p_trip_stop_info.tp_attribute2,
    p_trip_stop_info.tp_attribute3,
    p_trip_stop_info.tp_attribute4,
    p_trip_stop_info.tp_attribute5,
    p_trip_stop_info.tp_attribute6,
    p_trip_stop_info.tp_attribute7,
    p_trip_stop_info.tp_attribute8,
    p_trip_stop_info.tp_attribute9,
    p_trip_stop_info.tp_attribute10,
    p_trip_stop_info.tp_attribute11,
    p_trip_stop_info.tp_attribute12,
    p_trip_stop_info.tp_attribute13,
    p_trip_stop_info.tp_attribute14,
    p_trip_stop_info.tp_attribute15,
    p_trip_stop_info.attribute_category,
    p_trip_stop_info.attribute1,
    p_trip_stop_info.attribute2,
    p_trip_stop_info.attribute3,
    p_trip_stop_info.attribute4,
    p_trip_stop_info.attribute5,
    p_trip_stop_info.attribute6,
    p_trip_stop_info.attribute7,
    p_trip_stop_info.attribute8,
    p_trip_stop_info.attribute9,
    p_trip_stop_info.attribute10,
    p_trip_stop_info.attribute11,
    p_trip_stop_info.attribute12,
    p_trip_stop_info.attribute13,
    p_trip_stop_info.attribute14,
    p_trip_stop_info.attribute15,
    nvl(p_trip_stop_info.creation_date, SYSDATE),
    nvl(p_trip_stop_info.created_by, FND_GLOBAL.USER_ID),
    nvl(p_trip_stop_info.last_update_date, SYSDATE),
    nvl(p_trip_stop_info.last_updated_by, FND_GLOBAL.USER_ID),
    nvl(p_trip_stop_info.last_update_login, FND_GLOBAL.LOGIN_ID),
    p_trip_stop_info.program_application_id,
    p_trip_stop_info.program_id,
    p_trip_stop_info.program_update_date,
    p_trip_stop_info.request_id,
    p_trip_stop_info.wsh_location_id,
    p_trip_stop_info.tracking_drilldown_flag,
    p_trip_stop_info.tracking_remarks,
    p_trip_stop_info.carrier_est_departure_date,
    p_trip_stop_info.carrier_est_arrival_date,
    p_trip_stop_info.loading_start_datetime,
    p_trip_stop_info.loading_end_datetime,
    p_trip_stop_info.unloading_start_datetime,
    p_trip_stop_info.unloading_end_datetime,
    nvl(l_shipments_type_flag, 'O'),
    -- J: W/V Changes
    nvl(p_trip_stop_info.wv_frozen_flag, 'N'),
    p_trip_stop_info.wkend_layover_stops,
    p_trip_stop_info.wkday_layover_stops,
    p_trip_stop_info.tp_stop_id,
    p_trip_stop_info.physical_stop_id,
    nvl(p_trip_stop_info.physical_location_id, l_physical_loc_id),
    NULL  --OTM R12, glog proj , create stops with null value for tms_interface_flag
  );

  --
	-- Workflow Project
	-- Raise Trip Stop Creation business event
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT(	p_entity_type	=>	'STOP',
				p_entity_id	=>	x_stop_id,
				p_event		=>	'oracle.apps.wsh.stop.gen.create',
				x_return_status	=>	l_wf_rs
			     );

	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;
	-- End of code for Workflow project

        -- DBI Project
        -- Insert into WSH_TRIP_STOPS.
        -- Call DBI API after the INSERT.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id-',x_stop_id);
        END IF;
        l_stop_tab(1) := x_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'INSERT',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	 x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;
        -- End of Code for DBI Project
 --


  OPEN check_stop;
  FETCH check_stop INTO x_rowid;

  IF (check_stop%NOTFOUND) THEN
    CLOSE check_stop;
    RAISE others;
  END IF;

  CLOSE check_stop;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION

    WHEN get_physical_loc_err THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fnd_message.set_name('WSH', 'WSH_LOCATION_CONVERT_ERR');
         fnd_message.set_token('LOCATION_NAME',
           SUBSTRB(WSH_UTIL_CORE.get_location_description(p_trip_stop_info.stop_location_id,'NEW UI CODE'), 1, 60));
         wsh_util_core.add_message(x_return_status,l_module_name);

    WHEN others THEN
	   wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.CREATE_TRIP_STOP',l_module_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Trip_Stop;


PROCEDURE Delete_Trip_Stop(
  p_rowid			IN	VARCHAR2,
  p_stop_id		IN	NUMBER,
  x_return_status	OUT NOCOPY 	VARCHAR2,
  p_validate_flag   IN   VARCHAR2 DEFAULT 'Y',
--tkt
  p_caller          IN  VARCHAR2
--tkt
  ) IS

CURSOR get_stop_id_rowid (v_rowid VARCHAR2) IS
SELECT stop_id, trip_id
FROM   wsh_trip_stops
WHERE  rowid = v_rowid;

CURSOR get_trip_id (v_stop_id NUMBER) IS
SELECT trip_id
FROM   wsh_trip_stops
WHERE  stop_id = v_stop_id;

CURSOR get_del_leg_id (cp_stop_id NUMBER) IS
SELECT delivery_leg_id
FROM wsh_delivery_legs
WHERE  pick_up_stop_id = cp_stop_id OR
       drop_off_stop_id = cp_stop_id;

--OTM R12, glog proj
CURSOR c_get_trip_status (p_trip_id IN NUMBER) IS
SELECT NVL(ignore_for_planning, 'N'),
       tp_plan_name
FROM WSH_TRIPS
WHERE trip_id = p_trip_id;
--


l_stop_id		NUMBER;
l_trip_id               NUMBER;
l_trip_id_tab           wsh_util_core.id_tab_type;
others 		        EXCEPTION;

l_return_status         VARCHAR2(1);
l_warn_num              NUMBER := 0;

l_stop_tab WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs                VARCHAR2(1);  -- DBI Project

--OTM R12, glog proj
l_ignore                WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;
l_tp_plan_name          WSH_TRIPS.TP_PLAN_NAME%TYPE;
e_gc3_trip              EXCEPTION;
l_gc3_is_installed      VARCHAR2(1);
--

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_TRIP_STOP';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_VALIDATE_FLAG',P_VALIDATE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
   END IF;
   --
   l_stop_id := p_stop_id;

   x_return_status    := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   -- end of OTM R12, glog proj



   IF p_rowid IS NOT NULL THEN
      OPEN  get_stop_id_rowid(p_rowid);
      FETCH get_stop_id_rowid INTO l_stop_id,l_trip_id;
      CLOSE get_stop_id_rowid;
   ELSIF p_stop_id IS NOT NULL THEN
      OPEN  get_trip_id(p_stop_id);
      FETCH get_trip_id INTO l_trip_id;
      CLOSE get_trip_id;
   END IF;


   -- OTM R12, glog proj
   -- Only allow stops to be deleted from the Gc3 Inbound Message
   -- the caller for Inbound Message=FTE_TMS_INTEGRATION
   -- Not allowed from Form or UI
   IF l_gc3_is_installed = 'Y' AND nvl(p_caller,'@@@') <> 'FTE_TMS_INTEGRATION' THEN
     l_ignore           := 'N';
     l_tp_plan_name     := NULL;

     OPEN c_get_trip_status(l_trip_id);
     FETCH c_get_trip_status INTO l_ignore, l_tp_plan_name;
     IF c_get_trip_status%NOTFOUND THEN
       CLOSE c_get_trip_status;
       RAISE no_data_found;
     END IF;
     CLOSE c_get_trip_status;
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Ignore:'||l_ignore||' Tp Plan:'||l_tp_plan_name);
     END IF;
     IF (l_ignore = 'N' AND l_tp_plan_name IS NOT NULL) THEN
       l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       RAISE e_gc3_trip;
     END IF;
   END IF;
   --


   IF (p_validate_flag = 'Y') THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.CHECK_STOP_DELETE',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 WSH_TRIP_VALIDATIONS.check_stop_delete(
	 p_stop_id => l_stop_id,
	 x_return_status => l_return_status,
         p_caller        => p_caller);
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'CHECK_STOP_DELETE x_return_status',x_return_status);
	 END IF;

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	    x_return_status := l_return_status;
	    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_DELETE_ERROR');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(l_stop_id, p_caller));
	    wsh_util_core.add_message(x_return_status,l_module_name);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         l_warn_num := l_warn_num + 1;

      END IF;
   END IF;


   IF l_stop_id IS NOT NULL THEN
	 DELETE FROM wsh_freight_costs
	 WHERE  stop_id = l_stop_id;


      FOR rec IN get_del_leg_id(l_stop_id) LOOP

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Calling Delete_Delivery_Leg delivery_leg_id',rec.delivery_leg_id);
          END IF;

          WSH_DELIVERY_LEGS_PVT.Delete_Delivery_Leg (
                 p_delivery_leg_id      => rec.delivery_leg_id,
                 x_return_status        => l_return_status);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'After Calling Delete_Delivery_Leg x_return_status',x_return_status);
          END IF;

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 IF l_debug_on THEN
	            WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 x_return_status := l_return_status;
                 RETURN;
          ELSIF  l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_warn_num := l_warn_num + 1;
          END IF;

      END LOOP;


      DELETE FROM wsh_trip_stops
      WHERE stop_id = l_stop_id;

 --
        -- DBI Project
        -- DELETE from WSH_TRIP_STOPS.
        -- Call DBI API after the DELETE.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id-',l_stop_id);
        END IF;
        l_stop_tab(1) := l_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'DELETE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;
        -- End of Code for DBI Project
 --


      IF l_trip_id IS NOT NULL THEN

        -- Need to compute all stops weight/volumes
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.trip_weight_volume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        l_trip_id_tab(1) := l_trip_id;
        WSH_TRIPS_ACTIONS.trip_weight_volume(
          p_trip_rows            => l_trip_id_tab,
          p_override_flag        => 'Y',
          p_calc_wv_if_frozen    => 'N',
          p_start_departure_date => to_date(NULL),
          p_calc_del_wv          => 'N',
          x_return_status        => x_return_status,
          p_suppress_errors      => 'Y');

        IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error calculating trip wt/vol');
          END IF;
        END IF;

      END IF;

   ELSE
      raise others;
   END IF;

   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS and l_warn_num > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
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

     --OTM R12, glog proj
     WHEN e_gc3_trip THEN
       IF c_get_trip_status%ISOPEN THEN
         CLOSE c_get_trip_status;
       END IF;
       FND_MESSAGE.SET_NAME('WSH','WSH_OTM_TRIP_STOP_DEL_ERROR');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'E_GC3_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_GC3_TRIP');
       END IF;
       --

     WHEN others THEN
       IF c_get_trip_status%ISOPEN THEN
         CLOSE c_get_trip_status;
       END IF;
       wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.DELETE_TRIP_STOP',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Delete_Trip_Stop;

procedure Update_Trip_Stop(
	p_rowid			IN	VARCHAR2,
	p_stop_info		IN	trip_stop_rec_type,
	x_return_status	OUT NOCOPY 	VARCHAR2) IS

-- J: W/V Changes
CURSOR get_stop_info IS
SELECT rowid,
       departure_gross_weight,
       departure_net_weight,
       departure_volume,
       weight_uom_code,
       volume_uom_code,
       NVL(wv_frozen_flag,'Y')
FROM   wsh_trip_stops
WHERE  stop_id = p_stop_info.stop_id;

-- J: W/V Changes
l_gross_wt            NUMBER;
l_net_wt              NUMBER;
l_volume              NUMBER;
l_weight_uom_code     VARCHAR2(3);
l_volume_uom_code     VARCHAR2(3);
l_frozen_flag         VARCHAR2(1);
l_return_status       VARCHAR2(1);

l_rowid VARCHAR2(30);

l_stop_tab WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs              VARCHAR2(1);    -- DBI Project

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TRIP_STOP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'STOP_ID',p_stop_info.STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_stop_info.TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'STOP_LOCATION_ID',p_stop_info.STOP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_stop_info.STATUS_CODE);
      WSH_DEBUG_SV.log(l_module_name,'STOP_SEQUENCE_NUMBER',p_stop_info.STOP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_ARRIVAL_DATE',p_stop_info.PLANNED_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_DEPARTURE_DATE',p_stop_info.PLANNED_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_ARRIVAL_DATE',p_stop_info.ACTUAL_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_DEPARTURE_DATE',p_stop_info.ACTUAL_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_GROSS_WEIGHT',p_stop_info.DEPARTURE_GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_NET_WEIGHT',p_stop_info.DEPARTURE_NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'WEIGHT_UOM_CODE',p_stop_info.WEIGHT_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_VOLUME',p_stop_info.DEPARTURE_VOLUME);
      WSH_DEBUG_SV.log(l_module_name,'VOLUME_UOM_CODE',p_stop_info.VOLUME_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_SEAL_CODE',p_stop_info.DEPARTURE_SEAL_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_FILL_PERCENT',p_stop_info.DEPARTURE_FILL_PERCENT);
      WSH_DEBUG_SV.log(l_module_name,'WSH_LOCATION_ID',p_stop_info.WSH_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_DRILLDOWN_FLAG',p_stop_info.TRACKING_DRILLDOWN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_REMARKS',p_stop_info.TRACKING_REMARKS);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_DEPARTURE_DATE',p_stop_info.CARRIER_EST_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_ARRIVAL_DATE',p_stop_info.CARRIER_EST_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_START_DATETIME',p_stop_info.LOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_END_DATETIME',p_stop_info.LOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_START_DATETIME',p_stop_info.UNLOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_END_DATETIME',p_stop_info.UNLOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'PHYSICAL_STOP_ID',p_stop_info.PHYSICAL_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'PHYSICAL_LOCATION_ID',p_stop_info.PHYSICAL_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'TMS_INTERFACE_FLAG',p_stop_info.TMS_INTERFACE_FLAG); --OTM R12,glog proj
  END IF;
   --

-- J: W/V Changes
   OPEN  get_stop_info;
   FETCH get_stop_info INTO l_rowid, l_gross_wt, l_net_wt, l_volume, l_weight_uom_code, l_volume_uom_code, l_frozen_flag;
   IF get_stop_info%NOTFOUND THEN
     CLOSE get_stop_info;
     RAISE no_data_found;
   END IF;
   CLOSE get_stop_info;
   IF p_rowid IS NOT NULL THEN
     l_rowid := p_rowid;
   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_rowid'||l_rowid||' Org Gross '||l_gross_wt||' Org Net '||l_net_wt||' Org Vol '||l_volume||' W Uom '||l_weight_uom_code||' V Uom '||l_volume_uom_code||' frozen '||l_frozen_flag);
   END IF;

   IF l_weight_uom_code <> p_stop_info.weight_uom_code THEN

       l_gross_wt := WSH_WV_UTILS.convert_uom(
                                           from_uom => l_weight_uom_code,
                                           to_uom   => p_stop_info.weight_uom_code,
                                           quantity => l_gross_wt);

       l_net_wt := WSH_WV_UTILS.convert_uom(
                                           from_uom => l_weight_uom_code,
                                           to_uom   => p_stop_info.weight_uom_code,
                                           quantity => l_net_wt);

   END IF;

   IF l_volume_uom_code <> p_stop_info.volume_uom_code THEN


       l_volume   := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_volume_uom_code,
                                           to_uom   => p_stop_info.volume_uom_code,
                                           quantity => l_volume);

   END IF;

   -- Set wv_frozen_flag to Y if W/V info changes
   IF  (NVL(l_gross_wt,-99) <> NVL(p_stop_info.departure_gross_weight,-99)) OR
       (NVL(l_net_wt,-99) <> NVL(p_stop_info.departure_net_weight,-99)) OR
       (NVL(l_volume,-99) <> NVL(p_stop_info.departure_volume,-99)) THEN
     l_frozen_flag := 'Y';
   END IF;


   UPDATE wsh_trip_stops SET
 	 stop_id 				= p_stop_info.stop_id,
 	 trip_id 				= p_stop_info.trip_id,
 	 stop_location_id 		= p_stop_info.stop_location_id,
 	 status_code    		= p_stop_info.status_code,
 	 stop_sequence_number	= p_stop_info.stop_sequence_number,
 	 planned_arrival_date    = p_stop_info.planned_arrival_date,
 	 planned_departure_date  = p_stop_info.planned_departure_date,
 	 actual_arrival_date     = p_stop_info.actual_arrival_date,
	 actual_departure_date   = p_stop_info.actual_departure_date,
 	 departure_gross_weight 	= p_stop_info.departure_gross_weight,
 	 departure_net_weight  	= p_stop_info.departure_net_weight,
 	 weight_uom_code      	= p_stop_info.weight_uom_code,
 	 departure_volume    	= p_stop_info.departure_volume,
 	 volume_uom_code         = p_stop_info.volume_uom_code,
 	 departure_seal_code    	= p_stop_info.departure_seal_code,
 	 departure_fill_percent	= p_stop_info.departure_fill_percent,
 	 tp_attribute_category	= p_stop_info.tp_attribute_category,
 	 tp_attribute1       	= p_stop_info.tp_attribute1,
 	 tp_attribute2      	= p_stop_info.tp_attribute2,
 	 tp_attribute3     		= p_stop_info.tp_attribute3,
 	 tp_attribute4    		= p_stop_info.tp_attribute4,
 	 tp_attribute5   		= p_stop_info.tp_attribute5,
 	 tp_attribute6 		= p_stop_info.tp_attribute6,
 	 tp_attribute7 		= p_stop_info.tp_attribute7,
 	 tp_attribute8           = p_stop_info.tp_attribute8,
 	 tp_attribute9           = p_stop_info.tp_attribute9,
 	 tp_attribute10          = p_stop_info.tp_attribute10,
 	 tp_attribute11          = p_stop_info.tp_attribute11,
 	 tp_attribute12          = p_stop_info.tp_attribute12,
 	 tp_attribute13          = p_stop_info.tp_attribute13,
 	 tp_attribute14          = p_stop_info.tp_attribute14,
 	 tp_attribute15          = p_stop_info.tp_attribute15,
 	 attribute_category     	= p_stop_info.attribute_category,
 	 attribute1            	= p_stop_info.attribute1,
 	 attribute2           	= p_stop_info.attribute2,
 	 attribute3          	= p_stop_info.attribute3,
 	 attribute4         	= p_stop_info.attribute4,
 	 attribute5        		= p_stop_info.attribute5,
 	 attribute6       		= p_stop_info.attribute6,
 	 attribute7      		= p_stop_info.attribute7,
 	 attribute8     		= p_stop_info.attribute8,
 	 attribute9    		= p_stop_info.attribute9,
 	 attribute10             = p_stop_info.attribute10,
 	 attribute11             = p_stop_info.attribute11,
 	 attribute12             = p_stop_info.attribute12,
 	 attribute13             = p_stop_info.attribute13,
 	 attribute14             = p_stop_info.attribute14,
 	 attribute15             = p_stop_info.attribute15,
 	 last_update_date        = p_stop_info.last_update_date,
 	 last_updated_by         = p_stop_info.last_updated_by,
 	 last_update_login       = p_stop_info.last_update_login,
 	 program_application_id  = p_stop_info.program_application_id,
 	 program_id              = p_stop_info.program_id,
 	 program_update_date     = p_stop_info.program_update_date,
  	 request_id             	= p_stop_info.request_id,
	 wsh_location_id		= p_stop_info.wsh_location_id,
	 tracking_drilldown_flag	= p_stop_info.tracking_drilldown_flag,
	 tracking_remarks		= p_stop_info.tracking_remarks,
	 carrier_est_departure_date	= p_stop_info.carrier_est_departure_date,
	 carrier_est_arrival_date	= p_stop_info.carrier_est_arrival_date,
	 loading_start_datetime		= p_stop_info.loading_start_datetime,
	 loading_end_datetime		= p_stop_info.loading_end_datetime,
	 unloading_start_datetime	= p_stop_info.unloading_start_datetime,
	 unloading_end_datetime		= p_stop_info.unloading_end_datetime,
         shipments_type_flag            = nvl(p_stop_info.shipments_type_flag, 'O'),
         -- J: W/V Changes
         wv_frozen_flag                 = l_frozen_flag,
         wkend_layover_stops            = p_stop_info.wkend_layover_stops,
         wkday_layover_stops            = p_stop_info.wkday_layover_stops,
         tp_stop_id                     = p_stop_info.tp_stop_id,
         physical_stop_id               = p_stop_info.physical_stop_id,
         physical_location_id           = p_stop_info.physical_location_id,
         TMS_INTERFACE_FLAG             = p_stop_info.tms_interface_flag  --OTM R12,glog proj
   WHERE rowid = l_rowid;

   IF (SQL%NOTFOUND) THEN
	 raise no_data_found;
   END IF;

  --
        -- DBI Project
        -- Update WSH_TRIP_STOPS.
        -- Call DBI API after the UPDATE.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id-',p_stop_info.stop_id);
        END IF;
        l_stop_tab(1) := p_stop_info.stop_id;
        WSH_INTEGRATION.dbi_update_trip_stop_log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;
        -- End of Code for DBI Project
 --

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
         FND_MESSAGE.Set_Name('WSH','WSH_STOP_NOT_FOUND');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
	    END IF;
	    --
      WHEN others THEN
	    wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.UPDATE_TRIP_STOP',l_module_name);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Trip_Stop;


PROCEDURE Lock_Trip_Stop (
	p_rowid                 	IN   VARCHAR2,
	p_stop_info              IN   trip_stop_rec_type
	) IS

  CURSOR lock_row IS
  SELECT *
  FROM wsh_trip_stops
  WHERE rowid = p_rowid
  FOR UPDATE OF trip_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_TRIP_STOP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'STOP_ID',p_stop_info.STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_stop_info.TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'STOP_LOCATION_ID',p_stop_info.STOP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_stop_info.STATUS_CODE);
      WSH_DEBUG_SV.log(l_module_name,'STOP_SEQUENCE_NUMBER',p_stop_info.STOP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_ARRIVAL_DATE',p_stop_info.PLANNED_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'PLANNED_DEPARTURE_DATE',p_stop_info.PLANNED_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_ARRIVAL_DATE',p_stop_info.ACTUAL_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'ACTUAL_DEPARTURE_DATE',p_stop_info.ACTUAL_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_GROSS_WEIGHT',p_stop_info.DEPARTURE_GROSS_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_NET_WEIGHT',p_stop_info.DEPARTURE_NET_WEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'WEIGHT_UOM_CODE',p_stop_info.WEIGHT_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_VOLUME',p_stop_info.DEPARTURE_VOLUME);
      WSH_DEBUG_SV.log(l_module_name,'VOLUME_UOM_CODE',p_stop_info.VOLUME_UOM_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_SEAL_CODE',p_stop_info.DEPARTURE_SEAL_CODE);
      WSH_DEBUG_SV.log(l_module_name,'DEPARTURE_FILL_PERCENT',p_stop_info.DEPARTURE_FILL_PERCENT);
      WSH_DEBUG_SV.log(l_module_name,'WSH_LOCATION_ID',p_stop_info.WSH_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_DRILLDOWN_FLAG',p_stop_info.TRACKING_DRILLDOWN_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'TRACKING_REMARKS',p_stop_info.TRACKING_REMARKS);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_DEPARTURE_DATE',p_stop_info.CARRIER_EST_DEPARTURE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'CARRIER_EST_ARRIVAL_DATE',p_stop_info.CARRIER_EST_ARRIVAL_DATE);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_START_DATETIME',p_stop_info.LOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'LOADING_END_DATETIME',p_stop_info.LOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_START_DATETIME',p_stop_info.UNLOADING_START_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'UNLOADING_END_DATETIME',p_stop_info.UNLOADING_END_DATETIME);
      WSH_DEBUG_SV.log(l_module_name,'TMS_INTERFACE_FLAG',p_stop_info.TMS_INTERFACE_FLAG); --OTM R12,glog proj
  END IF;

     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;

     IF (lock_row%NOTFOUND) THEN
        CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
                (Recinfo.Stop_Id = p_stop_info.Stop_Id)
         AND    (Recinfo.Trip_Id = p_stop_info.Trip_Id)
         AND    (Recinfo.Stop_Location_Id = p_stop_info.Stop_Location_Id)
         AND 	 (Recinfo.Status_Code = p_stop_info.Status_Code)
         AND 	 (Recinfo.Stop_Sequence_Number = p_stop_info.Stop_Sequence_Number)
         AND (  (Recinfo.Planned_Arrival_Date = p_stop_info.Planned_Arrival_Date)
              OR (  (Recinfo.Planned_Arrival_Date IS NULL)
                  AND  (p_stop_info.Planned_Arrival_Date IS NULL)))
         AND (  (Recinfo.Planned_Departure_Date = p_stop_info.Planned_Departure_Date)
              OR (  (Recinfo.Planned_Departure_Date IS NULL)
                  AND  (p_stop_info.Planned_Departure_Date IS NULL)))
         AND (  (Recinfo.Actual_Arrival_Date = p_stop_info.Actual_Arrival_Date)
              OR (  (Recinfo.Actual_Arrival_Date IS NULL)
                  AND  (p_stop_info.Actual_Arrival_Date IS NULL)))
         AND (  (Recinfo.Actual_Departure_Date = p_stop_info.Actual_Departure_Date)
              OR (  (Recinfo.Actual_Departure_Date IS NULL)
                  AND  (p_stop_info.Actual_Departure_Date IS NULL)))
         AND (  (Recinfo.Departure_Gross_Weight = p_stop_info.Departure_Gross_Weight)
              OR (  (Recinfo.Departure_Gross_Weight IS NULL)
                  AND  (p_stop_info.Departure_Gross_Weight IS NULL)))
         AND (  (Recinfo.Departure_Net_Weight = p_stop_info.Departure_Net_Weight)
              OR (  (Recinfo.Departure_Net_Weight IS NULL)
                  AND  (p_stop_info.Departure_Net_Weight IS NULL)))
         AND (  (Recinfo.Weight_Uom_Code = p_stop_info.Weight_Uom_Code)
              OR (  (Recinfo.Weight_Uom_Code IS NULL)
                  AND  (p_stop_info.Weight_Uom_Code IS NULL)))
         AND (  (Recinfo.Departure_Volume = p_stop_info.Departure_Volume)
              OR (  (Recinfo.Departure_Volume IS NULL)
                  AND  (p_stop_info.Departure_Volume IS NULL)))
         AND (  (Recinfo.Volume_Uom_Code = p_stop_info.Volume_Uom_Code)
              OR (  (Recinfo.Volume_Uom_Code IS NULL)
                  AND  (p_stop_info.Volume_Uom_Code IS NULL)))
         AND (  (Recinfo.Departure_Seal_Code = p_stop_info.Departure_Seal_Code)
              OR (  (Recinfo.Departure_Seal_Code IS NULL)
                  AND  (p_stop_info.Departure_Seal_Code IS NULL)))
         AND (  (Recinfo.Departure_Fill_Percent = p_stop_info.Departure_Fill_Percent)
              OR (  (Recinfo.Departure_Fill_Percent IS NULL)
                  AND  (p_stop_info.Departure_Fill_Percent IS NULL)))
         AND (  (Recinfo.Creation_Date = p_stop_info.Creation_Date)
              OR (  (Recinfo.Creation_Date IS NULL)
                  AND  (p_stop_info.Creation_Date IS NULL)))
         AND (  (Recinfo.Created_By = p_stop_info.Created_By)
              OR (  (Recinfo.Created_By IS NULL)
                  AND  (p_stop_info.Created_By IS NULL)))
         AND (  (Recinfo.Last_Update_Date = p_stop_info.Last_Update_Date)
              OR (  (Recinfo.Last_Update_Date IS NULL)
                  AND  (p_stop_info.Last_Update_Date IS NULL)))
         AND (  (Recinfo.Last_Updated_By = p_stop_info.Last_Updated_By)
              OR (  (Recinfo.Last_Updated_By IS NULL)
                  AND  (p_stop_info.Last_Updated_By IS NULL)))
         AND (  (Recinfo.Last_Update_Login = p_stop_info.Last_Update_Login)
              OR (  (Recinfo.Last_Update_Login IS NULL)
                  AND  (p_stop_info.Last_Update_Login IS NULL)))
         AND (  (Recinfo.Program_Application_Id = p_stop_info.Program_Application_Id)
              OR (  (Recinfo.Program_Application_Id IS NULL)
                  AND  (p_stop_info.Program_Application_Id IS NULL)))
         AND (  (Recinfo.Program_Id = p_stop_info.Program_Id)
              OR (  (Recinfo.Program_Id IS NULL)
                  AND  (p_stop_info.Program_Id IS NULL)))
         AND (  (Recinfo.Program_Update_Date = p_stop_info.Program_Update_Date)
              OR (  (Recinfo.Program_Update_Date IS NULL)
                  AND  (p_stop_info.Program_Update_Date IS NULL)))
         AND (  (Recinfo.Request_Id = p_stop_info.Request_Id)
              OR (  (Recinfo.Request_Id IS NULL)
                  AND  (p_stop_info.Request_Id IS NULL)))
         AND (  (Recinfo.Attribute_Category = p_stop_info.Attribute_Category)
              OR (  (Recinfo.Attribute_Category IS NULL)
                  AND  (p_stop_info.Attribute_Category IS NULL)))
         AND (  (Recinfo.Attribute1 = p_stop_info.Attribute1)
              OR (  (Recinfo.Attribute1 IS NULL)
                  AND  (p_stop_info.Attribute1 IS NULL)))
         AND (  (Recinfo.Attribute2 = p_stop_info.Attribute2)
              OR (  (Recinfo.Attribute2 IS NULL)
                  AND  (p_stop_info.Attribute2 IS NULL)))
         AND (  (Recinfo.Attribute3 = p_stop_info.Attribute3)
              OR (  (Recinfo.Attribute3 IS NULL)
                  AND  (p_stop_info.Attribute3 IS NULL)))
         AND (  (Recinfo.Attribute4 = p_stop_info.Attribute4)
              OR (  (Recinfo.Attribute4 IS NULL)
                  AND  (p_stop_info.Attribute4 IS NULL)))
         AND (  (Recinfo.Attribute5 = p_stop_info.Attribute5)
              OR (  (Recinfo.Attribute5 IS NULL)
                  AND  (p_stop_info.Attribute5 IS NULL)))
         AND (  (Recinfo.Attribute6 = p_stop_info.Attribute6)
              OR (  (Recinfo.Attribute6 IS NULL)
                  AND  (p_stop_info.Attribute6 IS NULL)))
         AND (  (Recinfo.Attribute7 = p_stop_info.Attribute7)
              OR (  (Recinfo.Attribute7 IS NULL)
                  AND  (p_stop_info.Attribute7 IS NULL)))
         AND (  (Recinfo.Attribute8 = p_stop_info.Attribute8)
              OR (  (Recinfo.Attribute8 IS NULL)
                  AND  (p_stop_info.Attribute8 IS NULL)))
         AND (  (Recinfo.Attribute9 = p_stop_info.Attribute9)
              OR (  (Recinfo.Attribute9 IS NULL)
                  AND  (p_stop_info.Attribute9 IS NULL)))
         AND (  (Recinfo.Attribute10 = p_stop_info.Attribute10)
              OR (  (Recinfo.Attribute10 IS NULL)
                  AND  (p_stop_info.Attribute10 IS NULL)))
         AND (  (Recinfo.Attribute11 = p_stop_info.Attribute11)
              OR (  (Recinfo.Attribute11 IS NULL)
                  AND  (p_stop_info.Attribute11 IS NULL)))
         AND (  (Recinfo.Attribute12 = p_stop_info.Attribute12)
              OR (  (Recinfo.Attribute12 IS NULL)
                  AND  (p_stop_info.Attribute12 IS NULL)))
         AND (  (Recinfo.Attribute13 = p_stop_info.Attribute13)
              OR (  (Recinfo.Attribute13 IS NULL)
                  AND  (p_stop_info.Attribute13 IS NULL)))
         AND (  (Recinfo.Attribute14 = p_stop_info.Attribute14)
              OR (  (Recinfo.Attribute14 IS NULL)
                  AND  (p_stop_info.Attribute14 IS NULL)))
         AND (  (Recinfo.Attribute15 = p_stop_info.Attribute15)
              OR (  (Recinfo.Attribute15 IS NULL)
                  AND  (p_stop_info.Attribute15 IS NULL)))
         AND (  (Recinfo.Tp_Attribute_Category = p_stop_info.Tp_Attribute_Category)
              OR (  (Recinfo.Tp_Attribute_Category IS NULL)
                  AND  (p_stop_info.Tp_Attribute_Category IS NULL)))
         AND (  (Recinfo.Tp_Attribute1 = p_stop_info.Tp_Attribute1)
              OR (  (Recinfo.Tp_Attribute1 IS NULL)
                  AND  (p_stop_info.Tp_Attribute1 IS NULL)))
         AND (  (Recinfo.Tp_Attribute2 = p_stop_info.Tp_Attribute2)
              OR (  (Recinfo.Tp_Attribute2 IS NULL)
                  AND  (p_stop_info.Tp_Attribute2 IS NULL)))
         AND (  (Recinfo.Tp_Attribute3 = p_stop_info.Tp_Attribute3)
              OR (  (Recinfo.Tp_Attribute3 IS NULL)
                  AND  (p_stop_info.Tp_Attribute3 IS NULL)))
         AND (  (Recinfo.Tp_Attribute4 = p_stop_info.Tp_Attribute4)
              OR (  (Recinfo.Tp_Attribute4 IS NULL)
                  AND  (p_stop_info.Tp_Attribute4 IS NULL)))
         AND (  (Recinfo.Tp_Attribute5 = p_stop_info.Tp_Attribute5)
              OR (  (Recinfo.Tp_Attribute5 IS NULL)
                  AND  (p_stop_info.Tp_Attribute5 IS NULL)))
         AND (  (Recinfo.Tp_Attribute6 = p_stop_info.Tp_Attribute6)
              OR (  (Recinfo.Tp_Attribute6 IS NULL)
                  AND  (p_stop_info.Tp_Attribute6 IS NULL)))
         AND (  (Recinfo.Tp_Attribute7 = p_stop_info.Tp_Attribute7)
              OR (  (Recinfo.Tp_Attribute7 IS NULL)
                  AND  (p_stop_info.Tp_Attribute7 IS NULL)))
         AND (  (Recinfo.Tp_Attribute8 = p_stop_info.Tp_Attribute8)
              OR (  (Recinfo.Tp_Attribute8 IS NULL)
                  AND  (p_stop_info.Tp_Attribute8 IS NULL)))
         AND (  (Recinfo.Tp_Attribute9 = p_stop_info.Tp_Attribute9)
              OR (  (Recinfo.Tp_Attribute9 IS NULL)
                  AND  (p_stop_info.Tp_Attribute9 IS NULL)))
         AND (  (Recinfo.Tp_Attribute10 = p_stop_info.Tp_Attribute10)
              OR (  (Recinfo.Tp_Attribute10 IS NULL)
                  AND  (p_stop_info.Tp_Attribute10 IS NULL)))
         AND (  (Recinfo.Tp_Attribute11 = p_stop_info.Tp_Attribute11)
              OR (  (Recinfo.Tp_Attribute11 IS NULL)
                  AND  (p_stop_info.Tp_Attribute11 IS NULL)))
         AND (  (Recinfo.Tp_Attribute12 = p_stop_info.Tp_Attribute12)
              OR (  (Recinfo.Tp_Attribute12 IS NULL)
                  AND  (p_stop_info.Tp_Attribute12 IS NULL)))
         AND (  (Recinfo.Tp_Attribute13 = p_stop_info.Tp_Attribute13)
              OR (  (Recinfo.Tp_Attribute13 IS NULL)
                  AND  (p_stop_info.Tp_Attribute13 IS NULL)))
         AND (  (Recinfo.Tp_Attribute14 = p_stop_info.Tp_Attribute14)
              OR (  (Recinfo.Tp_Attribute14 IS NULL)
                  AND  (p_stop_info.Tp_Attribute14 IS NULL)))
         AND (  (Recinfo.Tp_Attribute15 = p_stop_info.Tp_Attribute15)
              OR (  (Recinfo.Tp_Attribute15 IS NULL)
                  AND  (p_stop_info.Tp_Attribute15 IS NULL)))
	 AND (  (Recinfo.wsh_location_id = p_stop_info.wsh_location_id)
              OR (  (Recinfo.wsh_location_id IS NULL)
                  AND  (p_stop_info.wsh_location_id IS NULL)))
	 AND (  (Recinfo.tracking_drilldown_flag = p_stop_info.tracking_drilldown_flag)
              OR (  (Recinfo.tracking_drilldown_flag IS NULL)
                  AND  (p_stop_info.tracking_drilldown_flag IS NULL)))
	 AND (  (Recinfo.tracking_remarks = p_stop_info.tracking_remarks)
              OR (  (Recinfo.tracking_remarks IS NULL)
                  AND  (p_stop_info.tracking_remarks IS NULL)))
	 AND (  (Recinfo.carrier_est_departure_date = p_stop_info.carrier_est_departure_date)
              OR (  (Recinfo.carrier_est_departure_date IS NULL)
                  AND  (p_stop_info.carrier_est_departure_date IS NULL)))
	 AND (  (Recinfo.carrier_est_arrival_date = p_stop_info.carrier_est_arrival_date)
              OR (  (Recinfo.carrier_est_arrival_date IS NULL)
                  AND  (p_stop_info.carrier_est_arrival_date IS NULL)))
	 AND (  (Recinfo.loading_start_datetime = p_stop_info.loading_start_datetime)
              OR (  (Recinfo.loading_start_datetime IS NULL)
                  AND  (p_stop_info.loading_start_datetime IS NULL)))
	 AND (  (Recinfo.loading_end_datetime = p_stop_info.loading_end_datetime)
              OR (  (Recinfo.loading_end_datetime IS NULL)
                  AND  (p_stop_info.loading_end_datetime IS NULL)))
	 AND (  (Recinfo.unloading_start_datetime = p_stop_info.unloading_start_datetime)
              OR (  (Recinfo.unloading_start_datetime IS NULL)
                  AND  (p_stop_info.unloading_start_datetime IS NULL)))
	 AND (  (Recinfo.unloading_end_datetime = p_stop_info.unloading_end_datetime)
              OR (  (Recinfo.unloading_end_datetime IS NULL)
                  AND  (p_stop_info.unloading_end_datetime IS NULL)))
         AND (  (nvl(Recinfo.shipments_type_flag, 'O') = nvl(p_stop_info.shipments_type_flag,'O'))
              OR (  (Recinfo.shipments_type_flag IS NULL)
                  AND  (p_stop_info.shipments_type_flag IS NULL)))
-- J: W/V Changes
         AND (  (Recinfo.wv_frozen_flag = p_stop_info.wv_frozen_flag)
              OR (  (Recinfo.wv_frozen_flag IS NULL)
                  AND  (p_stop_info.wv_frozen_flag IS NULL)))
	 AND (  (Recinfo.tp_stop_id = p_stop_info.tp_stop_id)
              OR (  (Recinfo.tp_stop_id IS NULL)
                  AND  (p_stop_info.tp_stop_id IS NULL)))
	 AND (  (Recinfo.wkend_layover_stops = p_stop_info.wkend_layover_stops)
              OR (  (Recinfo.wkend_layover_stops IS NULL)
                  AND  (p_stop_info.wkend_layover_stops IS NULL)))
	 AND (  (Recinfo.wkday_layover_stops = p_stop_info.wkday_layover_stops)
              OR (  (Recinfo.wkday_layover_stops IS NULL)
                  AND  (p_stop_info.wkday_layover_stops IS NULL)))
         AND (  (Recinfo.physical_stop_id = p_stop_info.physical_stop_id)
              OR (   (Recinfo.physical_stop_id IS NULL)
                  AND  (p_stop_info.physical_stop_id IS NULL)))
         AND (  (Recinfo.physical_location_id = p_stop_info.physical_location_id)
              OR (   (Recinfo.physical_location_id IS NULL)
                  AND  (p_stop_info.physical_location_id IS NULL)))
        -- OTM R12, glog proj
         AND (  (Recinfo.TMS_INTERFACE_FLAG = p_stop_info.TMS_INTERFACE_FLAG)
              OR (   (Recinfo.TMS_INTERFACE_FLAG is NULL)
                  AND  (p_stop_info.TMS_INTERFACE_FLAG is NULL)))

     ) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name,'RETURN');
	END IF;
	--
	return;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
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
  END Lock_Trip_Stop;

Procedure Populate_Record(
	p_stop_id           IN   NUMBER,
	x_stop_info         OUT NOCOPY   trip_stop_rec_type,
	x_return_status     OUT NOCOPY   VARCHAR2) IS

CURSOR stop_record IS
SELECT
       STOP_ID,
       TRIP_ID,
       STOP_LOCATION_ID,
       STATUS_CODE,
       STOP_SEQUENCE_NUMBER,
       PLANNED_ARRIVAL_DATE,
       PLANNED_DEPARTURE_DATE,
       ACTUAL_ARRIVAL_DATE,
       ACTUAL_DEPARTURE_DATE,
       DEPARTURE_GROSS_WEIGHT,
       DEPARTURE_NET_WEIGHT,
       WEIGHT_UOM_CODE,
       DEPARTURE_VOLUME,
       VOLUME_UOM_CODE,
       DEPARTURE_SEAL_CODE,
       DEPARTURE_FILL_PERCENT,
       TP_ATTRIBUTE_CATEGORY,
       TP_ATTRIBUTE1,
       TP_ATTRIBUTE2,
       TP_ATTRIBUTE3,
       TP_ATTRIBUTE4,
       TP_ATTRIBUTE5,
       TP_ATTRIBUTE6,
       TP_ATTRIBUTE7,
       TP_ATTRIBUTE8,
       TP_ATTRIBUTE9,
       TP_ATTRIBUTE10,
       TP_ATTRIBUTE11,
       TP_ATTRIBUTE12,
       TP_ATTRIBUTE13,
       TP_ATTRIBUTE14,
       TP_ATTRIBUTE15,
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
       WSH_LOCATION_ID,
       TRACKING_DRILLDOWN_FLAG,
       TRACKING_REMARKS,
       CARRIER_EST_DEPARTURE_DATE,
       CARRIER_EST_ARRIVAL_DATE,
       LOADING_START_DATETIME,
       LOADING_END_DATETIME,
       UNLOADING_START_DATETIME,
       UNLOADING_END_DATETIME,
       ROWID,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       SHIPMENTS_TYPE_FLAG,
-- J: W/V Changes
       WV_FROZEN_FLAG,
       wkend_layover_stops,
       wkday_layover_stops,
       tp_stop_id,
       physical_stop_id,
       physical_location_id,
       tms_interface_flag -- OTM R12, glog proj
FROM   wsh_trip_stops
WHERE  stop_id = p_stop_id;

others EXCEPTION;

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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
   END IF;
   --
   IF (p_stop_id IS NULL) THEN
	 raise others;
   END IF;

   OPEN  stop_record;
   FETCH stop_record INTO x_stop_info;

   IF (stop_record%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
   ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

   CLOSE stop_record;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
      WHEN others THEN
	    wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.POPULATE_RECORD',l_module_name);
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


--
--  Function:		Get_Name
--  Parameters:		p_stop_id - Id for stop
--  Description:	This procedure will return stop Name for a stop Id
--

  FUNCTION Get_Name
		(p_stop_id		IN	NUMBER,
--tkt
                 p_caller               IN      VARCHAR2
--tkt
		 ) RETURN VARCHAR2 IS

--tkt
  CURSOR get_id IS
  SELECT stop_location_id, physical_location_id
  FROM   wsh_trip_stops
  WHERE  stop_id = p_stop_id;
--tkt
  x_name VARCHAR2(60);
  x_id	 NUMBER;
  l_phys_loc_id NUMBER;

 /* Bug 7325837 Increasing Size of the variable as returned variable from get_location_description
    can be of size upto 185 (location_code and city or address1) */
  --l_name wsh_locations.location_code%TYPE;
  l_name VARCHAR2(185);

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
         WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
--tkt
         WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
--tkt
     END IF;
     --
     IF (p_stop_id IS NULL) THEN
        raise others;
     END IF;

     OPEN  get_id;
     FETCH get_id INTO x_id, l_phys_loc_id;

     IF get_id%NOTFOUND THEN
           CLOSE get_id;
	   FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
	   wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
           IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN null;
     END IF;
     IF get_id%ISOPEN THEN
	   CLOSE get_id;
     END IF;

--tkt
     IF l_phys_loc_id IS NOT NULL
        AND (  nvl(p_caller,'@@@') like 'FTE%'
               OR nvl(p_caller,'@@@') like 'WSH_IB%'
               OR nvl(p_caller,'@@@') like 'WSH_TP_RELEASE%'
             ) THEN
        x_id:=l_phys_loc_id;
     END IF;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name,'x_id',x_id);
     END IF;
     --
     l_name :=  WSH_UTIL_CORE.get_location_description(x_id, 'NEW UI CODE');
     x_name := SUBSTR(l_name,1,60);

     IF (x_name IS NULL) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
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
	      wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.GET_NAME',l_module_name);
		 --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;
		 --
		 RETURN null;

--
  END Get_Name;


-----------------------------------------------------------------------------
--
-- Procedure:     Get_Disabled_List
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Get the disabled columns/fields in a trip
--
-----------------------------------------------------------------------------
PROCEDURE Get_Disabled_List (
						p_stop_id        IN  NUMBER,
						p_parent_entity_id   IN  NUMBER,
						p_list_type		  IN  VARCHAR2,
						x_return_status  OUT NOCOPY  VARCHAR2,
						x_disabled_list  OUT NOCOPY  wsh_util_core.column_tab_type,
						x_msg_count             OUT NOCOPY      NUMBER,
						x_msg_data              OUT NOCOPY      VARCHAR2,
						p_caller IN VARCHAR2 -- DEFAULT NULL, --3509004:public api changes
						) IS

	l_status_code  VARCHAR2(10) := NULL;
	l_planned_flag VARCHAR2(10) := NULL;
 	i NUMBER := 0;
	dummy_id       NUMBER := 0;
        l_msg_summary VARCHAR2(2000);
        l_msg_details VARCHAR2(4000);
	l_shipments_type_flag  VARCHAR(30) := NULL; --3509004:public api changes
	e_all_disabled EXCEPTION ; --3509004:public api changes


CURSOR get_stop_status(x_stop_id NUMBER) IS
  SELECT status_code,
         stop_sequence_number,  -- Bug 3814592
         planned_arrival_date,  -- Bug 3814592
         SHIPMENTS_TYPE_FLAG , --3509004:public api changes
         physical_stop_id -- csun 10+ internal location
  FROM   wsh_trip_stops
  WHERE  stop_id = x_stop_id;

CURSOR c_has_closed_dummy_stop(x_stop_id NUMBER, x_trip_id NUMBER) IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  trip_id = x_trip_id
  AND    status_code = 'CL'
  AND    physical_stop_id = x_stop_id;

--OTM R12, glog proj
CURSOR get_trip_status(p_entity_id IN NUMBER) IS
  SELECT status_code, planned_flag,tp_plan_name
  FROM   wsh_trips
  WHERE  trip_id = p_entity_id;

CURSOR has_pick_up_deliveries(x_stop_id NUMBER) IS
  SELECT delivery_id
  FROM   wsh_delivery_legs
  WHERE  pick_up_stop_id = x_stop_id
  AND    rownum = 1;

CURSOR has_drop_off_deliveries(x_stop_id NUMBER) IS
  SELECT delivery_id
  FROM   wsh_delivery_legs
  WHERE  drop_off_stop_id = x_stop_id
  AND    rownum = 1;


-- Bug 3814592
-- Used for In-transit Mixed trips which can have
-- Open Stops before a closed stop (lower sequence Number)
-- Check if there exists a closed/arrived stop with a sequence
-- number higher than the current open stop(use stop_sequence_number to compare)
CURSOR get_updateable_open_stop (v_stop_sequence_number NUMBER)IS
  SELECT cur.stop_id
    FROM wsh_trip_stops cur
   WHERE cur.trip_id = p_parent_entity_id
     AND cur.stop_id <> p_stop_id
     AND cur.status_code in ('CL','AR')
     AND cur.stop_sequence_number > v_stop_sequence_number;

l_open_stop get_updateable_open_stop%ROWTYPE;
l_stop_sequence_number NUMBER;
l_planned_arrival_date DATE;
l_found BOOLEAN;
-- End of Bug 3814592
l_physical_stop_id NUMBER;
--

WSH_DP_NO_ENTITY         EXCEPTION;
WSH_INV_LIST_TYPE        EXCEPTION;
l_ssn_disabled           BOOLEAN;  -- used only to track this column when stop is OPEN
l_pad_disabled           BOOLEAN;  -- used only to track this column when stop is OPEN

-- OTM R12, glog proj
l_tp_plan_name           WSH_TRIPS.TP_PLAN_NAME%TYPE;
l_gc3_is_installed       VARCHAR2(1);

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ENTITY_ID',P_PARENT_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
   END IF;
   --
   x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --OTM R12, glog proj
   l_tp_plan_name        := NULL;

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   -- end of OTM R12, glog proj

   -- clear up the list table
   x_disabled_list.DELETE;

		OPEN get_stop_status(p_stop_id);
		FETCH get_stop_status
                 INTO l_status_code,
                      l_stop_sequence_number,  -- Bug 3814592
                      l_planned_arrival_date,  -- Bug 3814592
                      l_shipments_type_flag, --3509004:public api changes
                      l_physical_stop_id; -- csun 10+ internal location
		if get_stop_status%NOTFOUND then
			close get_stop_status;
			raise WSH_DP_NO_ENTITY;
      end if;
		CLOSE get_stop_status;
		IF (p_list_type <> 'FORM') THEN
			RAISE WSH_INV_LIST_TYPE;
		END IF;

			IF (l_status_code = 'CL') THEN
			  i:=i+1; x_disabled_list(i) := 'FULL';
			  i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
			  i:=i+1; x_disabled_list(i) := 'DESC_FLEX';

			ELSIF ( l_status_code = 'AR') THEN
-- FRONT PORTING Bug  3134466
                          l_status_code := NULL;
                          OPEN  get_trip_status(p_parent_entity_id);
                          FETCH get_trip_status
                           INTO l_status_code, l_planned_flag,
                                -- OTM R12, glog proj
                                l_tp_plan_name;
                          IF get_trip_status%NOTFOUND THEN
                            CLOSE get_trip_status;
                            FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
                            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                            --
                            RETURN;
                          END IF;
                          CLOSE get_trip_status;

                          IF NVL(p_caller,'!!!') LIKE 'FTE%' AND NVL(p_caller,'!!!') <> 'FTE_TMS_INTEGRATION' THEN --3509004:public api changes
                             i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_ID';
			  ELSE
                             i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_CODE';
			  END IF;
                          i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
                          i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';
			  -- Bug 3282166
			  --
			  i:=i+1; x_disabled_list(i) := 'CARRIER_EST_DEPARTURE_DATE';
			  i:=i+1; x_disabled_list(i) := 'CARRIER_EST_ARRIVAL_DATE';
                          --
                          -- csun 10+ internal location
                          IF l_planned_flag = 'Y'
                             OR l_physical_stop_id is not NULL THEN
                                i:=i+1; x_disabled_list(i) := 'PLANNED_DEPARTURE_DATE';
                          END IF;

			ELSIF (l_status_code = 'OP') THEN
                          l_pad_disabled := FALSE;
                          l_ssn_disabled := FALSE;

			  IF (p_parent_entity_id IS NULL) THEN
						 FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
				 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				 --
				 -- Debug Statements
				 --
				 IF l_debug_on THEN
				     WSH_DEBUG_SV.pop(l_module_name);
				 END IF;
				 --
				 RETURN;
			  END IF;

			  l_status_code := NULL;
			  OPEN  get_trip_status(p_parent_entity_id);
                          FETCH get_trip_status
                           INTO l_status_code, l_planned_flag,
                                -- OTM R12, glog proj
                                l_tp_plan_name;
			  IF get_trip_status%NOTFOUND THEN
			    CLOSE get_trip_status;
			    FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    --
			    -- Debug Statements
			    --
			    IF l_debug_on THEN
			      WSH_DEBUG_SV.pop(l_module_name);
			    END IF;
			    --
			    RETURN;
			  END IF;
			  CLOSE get_trip_status;

			  IF (l_planned_flag IN ('Y','F')) THEN
					-- trip is planned.
                                        IF NVL(p_caller,'!!!') LIKE 'FTE%' AND NVL(p_caller,'!!!') <> 'FTE_TMS_INTEGRATION' THEN --3509004:public api changes
                                           i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_ID';
			                ELSE
                                           i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_CODE';
			                END IF;
                                        l_pad_disabled := TRUE;
					i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
					i:=i+1; x_disabled_list(i) := 'PLANNED_DEPARTURE_DATE';

                                        -- SSN change
                                        -- THIS SHOULD BE TRUE INDEPENDENT OF PROFILE
                                        l_ssn_disabled := TRUE;
                                        i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';

			  ELSE
			       -- ---------------------------------------------------------------
			       -- if trip is not planned, check which condition it is
			       -- 1. has both pick up and drop deliveries
			       -- 2. has only pick up deliveries
			       -- 3. has only drop off deliveries
			       -- 4. none, all the fields are enabled, return empty table
			       -- ---------------------------------------------------------------

			          -- begin csun 10+ internal location
			       IF l_physical_stop_id is not NULL THEN
                                  l_pad_disabled := TRUE;
                                  i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
                                  i:=i+1; x_disabled_list(i) := 'PLANNED_DEPARTURE_DATE';
                                  -- end csun 10+ internal location
                                  -- SSN change
                                  -- THIS SHOULD BE TRUE INDEPENDENT OF PROFILE
                                  l_ssn_disabled := TRUE;
                                  i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';

                               ELSIF l_status_code = 'IT' THEN
                                   -- Bug 3814592, For trips which are in-transit, open stops which lie
                                   -- inbetween closed/arrived stops, planned arrival date should
                                   -- not be updateable (Mixed Trips scenario, combination of Inbound
                                   -- and Outbound).
                                   IF l_debug_on THEN
                                     WSH_DEBUG_SV.log(l_module_name,'Intransit Trip',p_parent_entity_id);
                                   END IF;
                                   -- Check if the current stop being processed lies inbetween stops
                                   -- which are closed/arrived
                                   OPEN get_updateable_open_stop(l_stop_sequence_number);
                                   FETCH get_updateable_open_stop
                                    INTO l_open_stop;

                                   l_found := get_updateable_open_stop%FOUND;

                                   CLOSE get_updateable_open_stop;

                                   IF l_found THEN--Found Arrived/Closed Stop with higher sequence number
                                     l_pad_disabled := TRUE;
                                     i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
                                     --
                                     -- SSN Change
                                     -- THIS SHOULD BE TRUE INDEPENDENT OF PROFILE
                                     l_ssn_disabled := TRUE;
                                     i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';
                                     --

                                     IF l_debug_on THEN
                                       WSH_DEBUG_SV.log(l_module_name,'Mixed Trip Open Stop-',p_stop_id);
                                     END IF;
                                   END IF;
                                 ELSE
                                   -- SSN Change
                                   -- Only for Profile set to PAD and none of the above conditions are met
                                   IF WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE  =
                                       WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN
                                     l_ssn_disabled := TRUE;
                                     i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';
                                   END IF;
                                   --
                                 END IF; -- physical_stop_id is NOT NULL
                                 -- End of Bug 3814592

-- FRONT PORTIN BUG FIX 3134466
                                 OPEN  has_pick_up_deliveries(p_stop_id);
                                 FETCH  has_pick_up_deliveries INTO dummy_id;
                                 IF has_pick_up_deliveries%FOUND THEN
                                        IF NVL(p_caller,'!!!') LIKE 'FTE%' AND NVL(p_caller,'!!!') <> 'FTE_TMS_INTEGRATION' THEN --3509004:public api changes
                                           i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_ID';
			                ELSE
                                           i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_CODE';
			                END IF;
                                   IF l_debug_on THEN
                                     WSH_DEBUG_SV.log(l_module_name,'Pickup Delivery found-',l_planned_flag);
                                   END IF;
                                 ELSE
                                    -- no pick_up deliveries, check if it has drop_off deliveries
                                         OPEN  has_drop_off_deliveries(p_stop_id);
                                         FETCH  has_drop_off_deliveries INTO dummy_id;
                                         IF has_drop_off_deliveries%FOUND THEN
                                            IF NVL(p_caller,'!!!') LIKE 'FTE%' AND NVL(p_caller,'!!!') <> 'FTE_TMS_INTEGRATION' THEN --3509004:public api changes
                                               i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_ID';
			                    ELSE
                                               i:=i+1; x_disabled_list(i) := 'STOP_LOCATION_CODE';
			                    END IF;
                                         END IF;
                                         CLOSE has_drop_off_deliveries;
                                   IF l_debug_on THEN
                                     WSH_DEBUG_SV.log(l_module_name,'Pickup Delivery Not found-',l_planned_flag);
                                   END IF;
                                 END IF;
                                 CLOSE has_pick_up_deliveries;

                                 -- END OF FRONT PORTING BUG FIX 3134466

                                 -- OTM R12, glog project
                                 IF l_debug_on THEN
                                   WSH_DEBUG_SV.log(l_module_name,'Caller--',p_caller);
                                   WSH_DEBUG_SV.log(l_module_name,'Tp Plan Name--',l_tp_plan_name);
                                   WSH_DEBUG_SV.log(l_module_name,'GC3 Installed --',l_gc3_is_installed);
                                 END IF;
                                 -- Disable Stop Location and Stop Sequence Number
                                 -- for GC3 trips (tp_plan_name is not null)
                                 -- For UI, disable Stop_Location_Code, for Inbound message
                                 --(Planned Shipment Interface) from OTM,disable Location id.
                                 IF l_gc3_is_installed = 'Y' AND l_tp_plan_name IS NOT NULL THEN
                                   i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';
                                   -- allow Planned Shipment Interface to Update, else disable
                                   IF nvl(p_caller,'@@@') <> 'FTE_TMS_INTEGRATION' THEN
                                     i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
                                     i:=i+1; x_disabled_list(i) := 'PLANNED_DEPARTURE_DATE';
                                   END IF;
                                 END IF;
                                 -- End of OTM R12, glog project change
      --



			  END IF; /* check if the stop is planned */

                          -- stop is open; check if we need to look for linked, closed stop:
                          --    we are not allowed to resequence the stop
                          --    when its linked dummy stop is closed.
                          --       This will avoid synchronization issues
                          --            in wsh_trip_actions.handle_internal_stops.
                          -- When sequencing mode is PAD, we will disable the planned arrival date.
                          -- When sequencing mode is SSN, we will disable both stop sequence number
                          -- and planned arrival date (because the dummy stop's PAD has to be in sync).
                          --
                          IF (NOT l_ssn_disabled) OR (NOT l_pad_disabled) THEN

                             OPEN c_has_closed_dummy_stop(p_stop_id, p_parent_entity_id);
                             FETCH c_has_closed_dummy_stop INTO dummy_id;
                             IF c_has_closed_dummy_stop%NOTFOUND THEN
                               dummy_id := NULL;
                             END IF;
                             CLOSE c_has_closed_dummy_stop;

                             IF dummy_id IS NOT NULL THEN
                               IF l_debug_on THEN
                                  WSH_DEBUG_SV.log(l_module_name,'Stop has a closed linked dummy stop',dummy_id);
                                  WSH_DEBUG_SV.log(l_module_name,'l_pad_disabled',l_pad_disabled);
                                  WSH_DEBUG_SV.log(l_module_name,'l_ssn_disabled',l_ssn_disabled);
                               END IF;
                               IF NOT l_ssn_disabled THEN
                                 i:=i+1; x_disabled_list(i) := 'STOP_SEQUENCE_NUMBER';
                               END IF;
                               IF NOT l_pad_disabled THEN
                                 i:=i+1; x_disabled_list(i) := 'PLANNED_ARRIVAL_DATE';
                               END IF;
                            END IF;
                          END IF;

		   END IF; /* check status code */

		    -- 3509004:public api changes
		    -- J-IB-NPARIKH-{
		    --
		    --
		    -- Update on inbound trip stops are allowed only if caller
		    -- starts with  one of the following:
		    --     - FTE
		    --     - WSH_IB
		    --     - WSH_PUB
		    --     - WSH_TP_RELEASE
		    --
		    IF  NVL(l_shipments_type_flag,'O') = 'I'
                    AND NVL(p_caller, '!!!')	NOT LIKE 'FTE%'
                    AND NVL(p_caller, '!!!')	NOT LIKE 'WSH_PUB%'
                    AND NVL(p_caller, '!!!')	NOT LIKE 'WSH_IB%'
                    AND NVL(p_caller, '!!!')	NOT LIKE 'WSH_TP_RELEASE%'
		    THEN
			RAISE e_all_disabled;
		    END IF;
		    --
		    --
		    IF   l_status_code IN ( 'CL')
		    AND (
				NVL(l_shipments_type_flag,'O') = 'I'
			 OR (
				    NVL(l_shipments_type_flag,'O') = 'M'
				AND (   NVL(p_caller, '!!!') LIKE 'FTE%'
				     OR NVL(p_caller, '!!!') LIKE 'WSH_PUB%'
				     OR NVL(p_caller, '!!!') LIKE 'WSH_IB%'
				    )
			    )
			)
		    THEN
		    --{
			--
			-- For inbound/mixed stops, weight/volume are updateable even if stop is closed.
			--
			-- For mixed stops, update is allowed only if caller starts with FTE/WSH_PUB/WSH_IB
			--
			IF x_disabled_list(1) = 'FULL'
			THEN
			       i := x_disabled_list.count;
			       --
			       i:=i+1; x_disabled_list(i) := 'DEPARTURE_GROSS_WEIGHT';
			       i:=i+1; x_disabled_list(i) := 'DEPARTURE_NET_WEIGHT';
			       i:=i+1; x_disabled_list(i) := 'DEPARTURE_VOLUME';
			END IF;
		    --}
		    END IF;
		    --
		    -- J-IB-NPARIKH-}
		    --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN e_all_disabled THEN --3509004:public api changes
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
      FND_MESSAGE.Set_Token('ENTITY_ID',p_stop_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        -- Nothing is updateable
        WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
      END IF;

  WHEN WSH_DP_NO_ENTITY THEN
		FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_ENTITY');
		WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR,l_module_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;

  -- invalid list type
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
  END IF;
  --
  WHEN WSH_INV_LIST_TYPE THEN
  		FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
		WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR,l_module_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
END IF;
--
  WHEN OTHERS THEN
    IF get_stop_status%ISOPEN THEN
      CLOSE get_stop_status;
    END IF;
    IF c_has_closed_dummy_stop%ISOPEN THEN
      CLOSE c_has_closed_dummy_stop;
    END IF;
    IF has_pick_up_deliveries%ISOPEN THEN
      CLOSE has_pick_up_deliveries;
    END IF;
    IF has_drop_off_deliveries%ISOPEN THEN
      CLOSE has_drop_off_deliveries;
    END IF;
    -- Bug 3814592
    IF get_updateable_open_stop%ISOPEN THEN
       CLOSE get_updateable_open_stop;
    END IF;
    -- End of Bug 3814592

    IF get_trip_status%ISOPEN THEN
      CLOSE get_trip_status;
    END IF;

    FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END  Get_Disabled_List  ;

PROCEDURE lock_trip_stop_no_compare (p_stop_id IN NUMBER)
IS
   l_stop_id  NUMBER;
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                || 'lock_trip_stop_no_compare';
   CURSOR c_lock_stop IS
   SELECT stop_id
   FROM wsh_trip_stops
   WHERE stop_id = p_stop_id
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
      WSH_DEBUG_SV.log(l_module_name,'p_stop_id',p_stop_id);
  END IF;

  OPEN c_lock_stop;
  FETCH c_lock_stop INTO l_stop_id;
  CLOSE c_lock_stop;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'stop id is locked',l_stop_id);
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN app_exception.application_exception
     OR app_exception.record_lock_exception THEN
       IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Could not lock stop', p_stop_id);
           WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:APPLICTION_EXCEPTION');
       END IF;
       --
       RAISE;

   WHEN OTHERS THEN
      --
      wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.lock_trip_stop_no_compare',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RAISE;
END lock_trip_stop_no_compare;

procedure Lock_Trip_Stop(
	p_rec_attr_tab		IN		Stop_Attr_Tbl_Type,
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
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_TRIP_STOP_WRAPPER';
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
      WSH_DEBUG_SV.log(l_module_name,'Total Number of Stop Records being locked',p_valid_index_tab.COUNT);
  END IF;
  --
  --
  l_index := p_valid_index_tab.FIRST;
  --
  while l_index is not null loop
    begin
      --
      savepoint lock_trip_stop_loop;
      --
      IF p_caller = 'WSH_FSTRX' THEN
         lock_trip_stop(p_rowid => p_rec_attr_tab(l_index).rowid,
  	                p_stop_info => p_rec_attr_tab(l_index)
                       );
      ELSE
         lock_trip_stop_no_compare(p_rec_attr_tab(l_index).stop_id);
      END IF;

      IF nvl(p_caller,'!') <> 'WSH_FSTRX' THEN
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := p_rec_attr_tab(l_index).stop_id;
      ELSE
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := l_index;
      END IF;
      --
    exception
      --
      WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
        rollback to lock_trip_stop_loop;
        IF nvl(p_caller,'!') <> 'WSH_FSTRX' THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_STOP_LOCK_FAILED');
	  FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_rec_attr_tab(l_index).stop_id);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        END IF;
        l_num_errors := l_num_errors + 1;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Unable to obtain lock on the Stop Id',p_rec_attr_tab(l_index).stop_id);
      END IF;
      --
      WHEN others THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    --
    l_index := p_valid_index_tab.NEXT(l_index);
    --
  end loop;
  --
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
    wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.LOCK_TRIP_STOP_WRAPPER',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
  --
END Lock_Trip_Stop;

  --OTM R12, glog proj, new procedure
  ----------------------------------------------------------
  -- PROCEDURE UPDATE_TMS_INTERFACE_FLAG
  --
  -- Parameters:        p_stop_id_tab           table of stop ids to update
  --                    p_tms_interface_flag_tab table of the interface_flag
  --                    for the stop to set to
  --                    x_return_status         return status
  --
  -- Description:       This procedure updates the stop's tms_interface_flag
  --                    according to the flag in the p_tms_interface_flag_tab.
  ----------------------------------------------------------
  Procedure Update_Tms_interface_flag
  (p_stop_id_tab            IN           WSH_UTIL_CORE.ID_TAB_TYPE,
   p_tms_interface_flag_tab IN           WSH_UTIL_CORE.COLUMN_TAB_TYPE,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  l_stop_tab      WSH_UTIL_CORE.id_tab_type; -- DBI Project
  l_dbi_rs        VARCHAR2(1);      -- DBI Project
  l_loop_counter  NUMBER;
  RECORD_LOCKED   EXCEPTION;
  PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TMS_INTERFACE_FLAG';
  --
  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'STOP_Tab Count',p_stop_id_tab.COUNT);
      IF p_stop_id_tab.count > 0 THEN
        l_loop_counter := 0;
        l_loop_counter := p_stop_id_tab.FIRST;
        LOOP--{
          WSH_DEBUG_SV.log(l_module_name,
                           'STOP_ID',p_stop_id_tab(l_loop_counter));
          WSH_DEBUG_SV.log(l_module_name,'TMS_INTERFACE_FLAG',
                           p_tms_interface_flag_tab(l_loop_counter));
          EXIT WHEN l_loop_counter >= p_stop_id_tab.LAST;
          l_loop_counter := p_stop_id_tab.NEXT(l_loop_counter);
        END LOOP;--}
      END IF;
    END IF;
    --
    SAVEPOINT update_tms_interface;

    IF ((p_stop_id_tab.COUNT <> p_tms_interface_flag_tab.COUNT)
       OR (p_stop_id_tab.COUNT=0)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                     'Stop ID and TMS_interface_flag_tab count does not match');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF (p_stop_id_tab.COUNT > 0) THEN--{
      FORALL i in p_stop_id_tab.FIRST..p_stop_id_tab.LAST
       UPDATE wsh_trip_stops
           SET TMS_INTERFACE_FLAG = p_tms_interface_flag_tab(i),
               last_update_date   = SYSDATE,
               last_updated_by    = FND_GLOBAL.USER_ID,
               last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE  STOP_ID = p_stop_id_tab(i);

      --
      -- DBI Project
      -- Update WSH_TRIP_STOPS.
      -- Call DBI API after the UPDATE.
      -- This API will also check for DBI Installed or not
      l_loop_counter := 0;
      l_loop_counter := p_stop_id_tab.FIRST;
      LOOP--{
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                           'Calling DBI API.Stop id-',
                           p_stop_id_tab(l_loop_counter));
        END IF;

        l_dbi_rs        := NULL;
        l_stop_tab(1)   := p_stop_id_tab(l_loop_counter);

        WSH_INTEGRATION.dbi_update_trip_stop_log
          (p_stop_id_tab        => l_stop_tab,
           p_dml_type           => 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                           'Return Status after DBI Call-',
                           l_dbi_rs);
        END IF;

        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,
                         'DBI API Returned Unexpected error '||x_return_status);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN l_loop_counter >= p_stop_id_tab.LAST;
        l_loop_counter := p_stop_id_tab.NEXT(l_loop_counter);
      END LOOP;--}
      -- End of Code for DBI Project
      --

    END IF;--}
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status'||x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tms_interface;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
       'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      ROLLBACK TO update_tms_interface;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
    --

    WHEN RECORD_LOCKED THEN
      ROLLBACK TO update_tms_interface;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Record_locked exception has occured. Cannot update stop tms_interface_flag', WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
      END IF;

    WHEN others THEN
      ROLLBACK TO update_tms_interface;
      wsh_util_core.default_handler('WSH_TRIP_STOPS_PVT.UPDATE_TMS_INTERFACE_FLAG',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END UPDATE_TMS_INTERFACE_FLAG;

END WSH_TRIP_STOPS_PVT;

/
