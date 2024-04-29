--------------------------------------------------------
--  DDL for Package Body WSH_OTM_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_OUTBOUND" as
/* $Header: WSHOTOIB.pls 120.8.12010000.5 2010/04/27 11:02:35 anvarshn ship $ */

--===================
-- CONSTANTS
--===================
-- declare debug variables
l_debug_on BOOLEAN;
l_debugfile     varchar2(2000);



PROCEDURE GET_DEL_DETAILS( 	p_all_details 	IN 	WSH_OTM_DET_TAB,
				p_delivery_id	IN 	NUMBER,
				x_del_details	IN OUT	NOCOPY WSH_OTM_DET_TAB) IS

l_sub_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DEL_DETAILS';

BEGIN
  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_sub_module_name);
  END IF;

  FOR i in 1..p_all_details.COUNT LOOP
  --{
	IF p_all_details(i).delivery_id = p_delivery_id THEN
		x_del_details.extend;
		x_del_details(x_del_details.COUNT) := p_all_details(i);
	END IF;
	IF x_del_details.COUNT >0 AND  p_all_details(i).delivery_id <> p_delivery_id THEN
		EXIT;
	END IF;
  --}
  END LOOP;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_sub_module_name);
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_sub_module_name,' FND_API.G_EXC_ERROR',sqlerrm);
          WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
       END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_sub_module_name,' FND_API.G_EXC_UNEXPECTED_ERROR',sqlerrm);
          WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
       END IF;
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_OTM_OUTBOUND.GET_DEL_DETAILS',l_sub_module_name);
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_sub_module_name,' OTHERS',sqlerrm);
          WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:OTHERS');
       END IF;
END;



-- +==========================================================================================+
--   Procedure : GET_TRIP_OBJECTS
--   Description:
--     	Procedure to get the Trip, Trip Stop, delivery,delivery details and Lpn info
--      in the form of objects (WSH_OTM_TRIP_TAB)

--   Inputs/Outputs:
--            p_trip_id_tab - id table (list of Trip Ids)
--            p_user_id  	- User Id to set the context
--            p_resp_id  	- Resp Id to set the context
--            p_resp_appl_id  	- Resp Appl Id to set the context
--   Output:
--            x_domain_name 		- domain name
--            x_otm_user_name 		- otm User Name
-- 	      x_otm_pwd    		- otm Password
-- 	      x_otm_pwd    		- otm Password
-- 	      x_trip_tab    		- Nested Table which contains the trip info
-- 	      x_error_trip_id_tab 	- List of ids for which the data could not be retrieved
--            x_return_status
-- +==========================================================================================+

PROCEDURE GET_TRIP_OBJECTS(p_trip_id_tab 		IN OUT NOCOPY	WSH_OTM_ID_TAB,
			       p_user_id		IN		NUMBER,
			       p_resp_id		IN		NUMBER,
			       p_resp_appl_id		IN		NUMBER,
			       x_domain_name    	OUT NOCOPY	VARCHAR2,
			       x_otm_user_name 		OUT NOCOPY	VARCHAR2,
			       x_otm_pwd		OUT NOCOPY	VARCHAR2,
			       x_server_tz_code		OUT NOCOPY	VARCHAR2,
			       x_trip_tab 		OUT NOCOPY 	WSH_OTM_TRIP_TAB,
			       x_dlv_tab		OUT NOCOPY	WSH_OTM_DLV_TAB,
			       x_error_trip_id_tab	OUT NOCOPY 	WSH_OTM_ID_TAB,
			       x_return_status 		OUT NOCOPY 	VARCHAR2)IS

-- Declare local variables

l_sub_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRIP_OBJECTS';

l_trip_tab		WSH_OTM_TRIP_TAB;
l_stops_tab		WSH_OTM_STOP_TAB;
--lpn_tab		WSH_OTM_LPN_TAB;
l_dlv_tab 		WSH_OTM_DLV_TAB;
l_dlv_ids		WSH_OTM_ID_TAB;
l_vol			NUMBER;
l_gross_weight		NUMBER;
l_net_weight		NUMBER;
l_total_gross_wt	NUMBER;
l_total_net_wt 		NUMBER;
l_total_vol		NUMBER;
l_delivery_id		NUMBER;
l_vol_uom		VARCHAR2(150);
l_weight_uom		VARCHAR2(150);
x_base_wt_uom		VARCHAR2(150);
x_base_vol_uom		VARCHAR2(150);
l_lpn_count		NUMBER;
l_stop_details  	WSH_OTM_STOP_DET_TAB;
l_new_stop_details  	WSH_OTM_STOP_DET_TAB;
l_lpns			WSH_OTM_LPN_TAB;
l_pick_up_flag		VARCHAR2(1);
l_drop_off_flag		VARCHAR2(1);
l_trips_sql 		VARCHAR2(2000);
l_trip_obj		WSH_OTM_TRIP_OBJ;
l_stop_obj		WSH_OTM_STOP_OBJ;
c_trips         	WSH_UTIL_CORE.RefCurType;
bind_col_tab    	WSH_UTIL_CORE.tbl_varchar;
i			NUMBER;
i1 			NUMBER;
l_lpn_tab		WSH_OTM_LPN_TAB;
l_organization_id	NUMBER;
l_return_status		VARCHAr2(10);
l_all_dlv_tab		WSH_OTM_DLV_TAB;
l_total_freight_cost    NUMBER;
l_currency_code		VARCHAR2(15);
l_sob_id		NUMBER;
l_car_type 		VARCHAR2(5) := 'CAR-';

-- Define cursor to get the deliveries picked at a stop
CURSOR get_deliveries_picked (p_stop_id NUMBER) IS
select delivery_id
from
wsh_delivery_legs
where pick_up_stop_id = p_stop_id;

-- Define cursor to get the deliveries dropped at a stop
CURSOR get_deliveries_dropped (p_stop_id NUMBER) IS
select delivery_id
from
wsh_delivery_legs
where drop_off_stop_id = p_stop_id;

--bug# 6497991 (begin) : Update tms_interface_flag for error trip stops back to 'ASR'.
CURSOR get_trip_stops(c_trip_id NUMBER) IS
SELECT stop_id,'ASR' tms_iface_new_status
FROM wsh_trip_stops
WHERE trip_id = c_trip_id;

x_error_dlv_id_tab	WSH_OTM_ID_TAB;
l_upd_trip_stops    WSH_UTIL_CORE.ID_TAB_TYPE;
l_upd_tms_interface_flags WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_old_trip_id NUMBER;
l_del_trip_rec                  NUMBER := NULL;
l_num_error                     NUMBER;
--bug# 6497991 (end)

TYPE dlv_in_tab_type is TABLE Of wsh_otm_dlv_obj INDEX BY BINARY_INTEGER;
dlv_in_tab dlv_in_tab_type;

GET_DELIVERY_OBJECTS_FALIED 	EXCEPTION;
GET_DEAFULT_UOMS_FALIED		EXCEPTION;
GET_FREIGHT_COST_ERROR		EXCEPTION;

BEGIN


  --  Initialize API return status to success

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_sub_module_name);
  END IF;

  -- Setting the apps context
  --Bug8231371 calling WSH_OTM_APPS_INITIALIZE to set apps context
  WSH_OTM_APPS_INITIALIZE(p_user_id => p_user_id,
 			  p_resp_id =>p_resp_id,
 			  p_resp_appl_id => p_resp_appl_id);

  IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_sub_module_name,'Building the dymanic sql to fetch Trips');
  END IF;

   --dbms_output.put_line('Building the sql');
   -- Bug 6732184: Added null values for dock_dook_xid, start_time and end_time of WSH_OTM_STOP_OBJ
  l_trips_sql :=
	'select '||
	'WSH_OTM_TRIP_OBJ(WT.TP_PLAN_NAME,  '||
	'NAME    ,'||
	'null,'||
	'''RC'','||
	'WT.carrier_id,'||
	'null,'||
	'WT.MODE_OF_TRANSPORT,'||
	'null,'||
	'null,'|| --weight_uom
	'null,'|| --Volume
	'null,'|| -- volume_uom
	'null,'|| --lpn count
	'WT.FREIGHT_TERMS_CODE,'||
	'null,'|| -- stop count
	'null,'|| -- release count
	'null,'||
	'null,'||
	'WT.VEHICLE_ITEM_ID,'||
	'WT.VEHICLE_NUM_PREFIX,'||
	'WT.VEHICLE_NUMBER,'||
	'null,'||
	'WT.VEHICLE_ORGANIZATION_ID,'||
	'null,'||
	'WT.SEAL_CODE,'||
	'sequence_number,'|| -- master_bol_number
	'WT.PLANNED_FLAG,'||
	'WT.ROUTING_INSTRUCTIONS,'||
	'null, '||-- gross weight
	'null, '||-- net_weight
	'wt.BOOKING_NUMBER    ,    '||
	'null,'||
	'WT.TRIP_ID,'||
	'nvl(WT.IGNORE_FOR_PLANNING,''N''),'||
	'WT.OPERATOR,'||
	'null,'|| -- Manual Freight cost
	'null,'|| -- Currency Code
	'null, '||
	'''TRIP_ID'','||
	'''MBOL_NUMBER'','||
	'''PLANNED_TRIP'','||
	'''MANUAL_FREIGHT_COSTS'','||
	'''MAN_FREIGHT_COST_CUR'','||
	'''OPERATOR'','||
	'''ROUTING_INSTR'','||
	'null,'|| -- Stops
	'null ,null,null,null,null), '||
	'WSH_OTM_STOP_OBJ(wts.STOP_ID , '||
		'WTS.STOP_SEQUENCE_NUMBER,null,null,'||
		'TO_CHAR(WTS.PLANNED_ARRIVAL_DATE,''YYYYMMDDHH24MISS''),'||
		'TO_CHAR(WTS.PLANNED_DEPARTURE_DATE,''YYYYMMDDHH24MISS''),'||
		'TO_CHAR(WTS.ACTUAL_ARRIVAL_DATE,''YYYYMMDDHH24MISS''),'||
		'TO_CHAR(WTS.ACTUAL_DEPARTURE_DATE,''YYYYMMDDHH24MISS''),'||
--		'TO_CHAR(WTS.PLANNED_ARRIVAL_DATE,''DD-MON-YYYY HH24:MI:SS''),'||
--		'TO_CHAR(WTS.PLANNED_DEPARTURE_DATE,''DD-MON-YYYY HH24:MI:SS''),'||
--		'TO_CHAR(WTS.ACTUAL_ARRIVAL_DATE,''DD-MON-YYYY HH24:MI:SS''),'||
--		'TO_CHAR(WTS.ACTUAL_DEPARTURE_DATE,''DD-MON-YYYY HH24:MI:SS''),'||
		'WTS.loading_end_datetime -  WTS.loading_start_datetime,'||
		'WTS.DEPARTURE_SEAL_CODE,''DEPARTURE_SEAL_CODE'', null, null, null, null, null), '||
		'nvl(WTS.DEPARTURE_GROSS_WEIGHT,0),'||
		'nvl(WTS.DEPARTURE_NET_WEIGHT,0),'||
		'nvl(WTS.DEPARTURE_VOLUME,0),	'||
		'WTS.WEIGHT_UOM_CODE,'||
		'WTS.VOLUME_UOM_CODE '||
  ' from wsh_trips wt , wsh_document_instances wdi, wsh_trip_stops wts '||
  ' where wt.trip_id = wts.trip_id '||
  ' and wdi.entity_name(+) = ''WSH_TRIPS'''||
  ' and wdi.entity_id(+) = wt.trip_id '||
  ' and wts.physical_stop_id is null '||
  ' and wts.tms_interface_flag = ''ASP'''||
  ' and wt.trip_id in (';


   FOR i in 1..p_trip_id_tab.COUNT LOOP
   --{
   	if i <> 1 then
   		l_trips_sql := l_trips_sql || ',';
   	end if;
   	l_trips_sql := l_trips_sql || ':' || i;
   	bind_col_tab(bind_col_tab.COUNT+1) := to_char(p_trip_id_tab(i));
   --}
   END LOOP;
   l_trips_sql := l_trips_sql || ')';
   l_trips_sql := l_trips_sql || ' ORDER BY WT.TRIP_ID,WTS.STOP_SEQUENCE_NUMBER';   --bug#5975661 : order by sequence num.

   i:=1;

   WSH_UTIL_CORE.OpenDynamicCursor(c_trips, l_trips_sql, bind_col_tab);
   x_trip_tab := WSH_OTM_TRIP_TAB();
   l_trip_tab := WSH_OTM_TRIP_TAB();
   l_stops_tab := WSH_OTM_STOP_TAB();
   l_stop_details := WSH_OTM_STOP_DET_TAB();
   l_all_dlv_tab := WSH_OTM_DLV_TAB();
   -- Bug 6497991: Populating error trips
   x_error_trip_id_tab := WSH_OTM_ID_TAB();
   l_old_trip_id := -1;
   -- Bug 6497991:end
   LOOP
   --{
   -- Bug 6497991: The Defined exception for a trip should not stop processing of other trips
   BEGIN
   --{
     	FETCH c_trips INTO l_trip_obj,l_stop_obj,l_gross_weight,l_net_weight, l_vol, l_weight_uom, l_vol_uom;
  	EXIT  WHEN (c_trips%NOTFOUND);
    IF ( l_old_trip_id <> l_trip_obj.trip_id )  THEN
  	--{
        l_old_trip_id := l_trip_obj.trip_id;
    	l_trip_tab.extend;
  		l_trip_tab(l_trip_tab.COUNT) := l_trip_obj;
  		l_trip_tab(l_trip_tab.COUNT).shipment_stops := WSH_OTM_STOP_TAB();

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Fetch Trip Id', l_trip_obj.trip_id);
		END IF;


		-- Get the OrganizationId of Trip
  		l_organization_id := WSH_UTIL_CORE.GET_TRIP_ORGANIZATION_ID(l_trip_obj.trip_id);
  		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.log(l_sub_module_name,' Organization Id after calling GET_TRIP_ORGANIZATION_ID ' ,
						l_organization_id);
		END IF;
		--If Vehicle_organization_id is null then take the trip Organization_id
		IF l_trip_tab(l_trip_tab.COUNT).EQUIPMENT_GROUP_XID IS NULL THEN
			l_trip_tab(l_trip_tab.COUNT).EQUIPMENT_GROUP_XID := l_organization_id;
		END IF;


		-- Get the Default UOMS based on the Organization Id
		wsh_wv_utils.get_default_uoms(l_organization_id, x_base_wt_uom, x_base_vol_uom, x_return_status);
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
                --{
	           -- Bug 6497991: Deleting the trip record before raising exception
                   IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_sub_module_name,'failed in get_default_uoms' ,x_return_status);
	  	   END IF;
		   l_del_trip_rec := l_trip_tab(l_trip_tab.COUNT).trip_id;
                   x_error_trip_id_tab.extend;
		   x_error_trip_id_tab(x_error_trip_id_tab.COUNT) := l_trip_tab(l_trip_tab.COUNT).trip_id;
		   l_trip_tab.TRIM;
		   raise GET_DEAFULT_UOMS_FALIED;
		--}
                END IF;
		WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
			p_uom=>x_base_wt_uom,
			x_uom=>l_trip_tab(l_trip_tab.COUNT).WEIGHT_UOM_XID ,
			x_return_status=>l_return_status);

                IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
                 --{
	            IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
	            END IF;
		    -- Bug 6497991: Deleting the trip record before raising exception
		    l_del_trip_rec := l_trip_tab(l_trip_tab.COUNT).trip_id;
                    x_error_trip_id_tab.extend;
		    x_error_trip_id_tab(x_error_trip_id_tab.COUNT) := l_trip_tab(l_trip_tab.COUNT).trip_id;
		    l_trip_tab.TRIM;
		    raise FND_API.G_EXC_ERROR;
	        --}
                END IF;

		WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
			p_uom=>x_base_vol_uom,
			x_uom=>l_trip_tab(l_trip_tab.COUNT).VOLUME_UOM_XID ,
			x_return_status=>l_return_status);

                IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
			END IF;
                    -- Bug 6497991: Deleting the trip record before raising exception
		    --l_trip_tab.delete(l_trip_tab.COUNT);
                    l_del_trip_rec := l_trip_tab(l_trip_tab.COUNT).trip_id;
                    x_error_trip_id_tab.extend;
		    x_error_trip_id_tab(x_error_trip_id_tab.COUNT) := l_trip_tab(l_trip_tab.COUNT).trip_id;
		    l_trip_tab.TRIM;
                    raise FND_API.G_EXC_ERROR;
		END IF;

  		l_total_gross_wt := 0;
  		l_total_net_wt := 0;
  		l_total_vol := 0;
	--}
  	END IF;

    --Bug 6497991: Need to add stop details ONLY IF the trip is not having any error.
	IF (NVL(l_del_trip_rec,-1) <> l_trip_obj.trip_id) THEN
  	l_trip_tab(l_trip_tab.COUNT).shipment_stops.extend;
  	l_trip_tab(l_trip_tab.COUNT).shipment_stops(l_trip_tab(l_trip_tab.COUNT).shipment_stops.COUNT) := l_stop_obj;

  	IF x_base_wt_uom <> l_weight_uom THEN
  	--{
  		l_total_gross_wt := l_total_gross_wt + WSH_WV_UTILS.CONVERT_UOM(l_weight_uom,
  										x_base_wt_uom,
  										l_gross_weight,null);
  		l_total_net_wt := l_total_net_wt + WSH_WV_UTILS.CONVERT_UOM(l_weight_uom,
  									x_base_wt_uom,
  									l_net_weight,null);
  	--}
  	ELSE
  	--{
  		l_total_gross_wt := l_total_gross_wt + l_gross_weight;
  		l_total_net_wt := l_total_net_wt + l_net_weight;
  	--}
  	END IF;

  	IF x_base_vol_uom <> l_vol_uom THEN
  		l_total_vol := l_total_vol + WSH_WV_UTILS.CONVERT_UOM(l_vol_uom,
									x_base_vol_uom,
									l_vol,null);
  	ELSE
  		l_total_vol := l_total_vol + l_vol;
  	END IF;

  	l_trip_tab(l_trip_tab.COUNT).GROSS_WEIGHT := l_total_gross_wt;
  	l_trip_tab(l_trip_tab.COUNT).NET_WEIGHT := l_total_net_wt;
  	l_trip_tab(l_trip_tab.COUNT).VOLUME := l_total_vol;
   END IF;

   EXCEPTION
     WHEN GET_DEAFULT_UOMS_FALIED THEN
	  l_num_error := l_num_error + 1;
          IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_sub_module_name,' GET_DEAFULT_UOMS_FALIED',sqlerrm);
             WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:GET_DEAFULT_UOMS_FALIED');
          END IF;

     WHEN FND_API.G_EXC_ERROR THEN
	  l_num_error := l_num_error + 1;
          IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_sub_module_name,' FND_API.G_EXC_ERROR',sqlerrm);
             WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
          END IF;

   END;
 --}
 END LOOP;

 IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_sub_module_name,'Number of Trips Fetched' , l_trip_tab.COUNT);
    FOR i in 1..l_trip_tab.COUNT LOOP
        WSH_DEBUG_SV.log(l_sub_module_name,'Fetched Trips' , l_trip_tab(i).trip_id);
    END LOOP;
 END IF;

 IF  l_trip_tab.COUNT >0 THEN
 --{
  FOR i in 1..l_trip_tab.COUNT LOOP
  --{
  --bug 6497991 Added iF l_trip_tab.EXISTS(i): if trip errors in this loop.
  IF l_trip_tab.EXISTS(i) THEN
  BEGIN
  --{
  	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_sub_module_name,'Processing Trip with Id ' , l_trip_tab(i).trip_id);
	END IF;

  	l_dlv_ids := WSH_OTM_ID_TAB();
	l_stops_tab := l_trip_tab(i).shipment_stops;



  	IF l_trip_tab(i).ignore_for_planning = 'Y' THEN
  		l_trip_tab(i).SHIPMENT_XID := 'WSH-' || l_trip_tab(i).TRIP_ID ;
		l_trip_tab(i).STOP_COUNT := l_stops_tab.COUNT;
	ELSE
  		l_trip_tab(i).SERVICE_PROVIDER_XID := '';
  		l_trip_tab(i).TRANSPORT_MODE_XID := '';
  		l_trip_tab(i).PAYMENT_CODE_XID := '';
  		l_trip_tab(i).BOOKING_NUMBER := '';
  	END IF;


  	IF l_trip_tab(i).SERVICE_PROVIDER_XID IS NOT NULL THEN
  		l_trip_tab(i).SERVICE_PROVIDER_XID := l_car_type || l_trip_tab(i).SERVICE_PROVIDER_XID;
  	END IF;

  	IF l_trip_tab(i).EQUIPMENT_XID IS NOT NULL THEN
		l_trip_tab(i).EQUIPMENT_XID := wsh_util_core.get_item_name(
						p_item_id =>to_number(l_trip_tab(i).EQUIPMENT_XID),
						p_organization_id =>l_trip_tab(i).EQUIPMENT_GROUP_XID);
	END IF;


	-- Get the curreny code from GL_SETS_OF_BOOKS
	l_sob_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
	SELECT currency_code INTO l_currency_code
	FROM GL_SETS_OF_BOOKS
	WHERE set_of_books_id = l_sob_id;

	WSH_FREIGHT_COSTS_PVT.Get_Trip_Manual_Freight_Cost(l_trip_tab(i).TRIP_ID,
								l_currency_code,
								l_total_freight_cost,
								l_return_status);

        IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --{
		   -- Bug 6497991: Deleting the trip record before raising exception
           IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Get_Trip_Manual_Freight_Cost Failed');
           END IF;
            x_error_trip_id_tab.extend;
            x_error_trip_id_tab(x_error_trip_id_tab.COUNT) := l_trip_tab(i).trip_id;
	    l_trip_tab.delete(i);
	    raise GET_FREIGHT_COST_ERROR;
        ELSIF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	          x_return_status:=l_return_status;
        --}
        END IF;

	l_trip_tab(i).MANUAL_FREIGHT_COSTS := l_total_freight_cost;
	l_trip_tab(i).CURRENCY_CODE := l_currency_code;



  	FOR i1 in 1..l_stops_tab.COUNT LOOP
  	--{

	  IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_sub_module_name,'Processing Stop with Id ' , l_stops_tab(i1).STOP_LOCATION_XID);
	  END IF;

	  l_stop_details := WSH_OTM_STOP_DET_TAB();



	  OPEN get_deliveries_picked(l_stops_tab(i1).STOP_LOCATION_XID);
	  LOOP
	  --{
		fetch get_deliveries_picked into l_delivery_id;
		EXIT  WHEN (get_deliveries_picked%NOTFOUND);
		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Delivery being Picked up  ' , l_delivery_id);
		END IF;
		l_dlv_ids.extend;
		l_dlv_ids(l_dlv_ids.COUNT) := l_delivery_id;
		-- Pick Up Stop
		l_pick_up_flag := 'Y';
		l_stop_details.extend;
		l_stop_details(l_stop_details.COUNT) := WSH_OTM_STOP_DET_OBJ('P',l_delivery_id);
	  --}
	  END LOOP;

	  OPEN get_deliveries_dropped(l_stops_tab(i1).STOP_LOCATION_XID);
	  LOOP
	  --{
		fetch get_deliveries_dropped into l_delivery_id;
		EXIT  WHEN (get_deliveries_dropped%NOTFOUND);
		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Delivery being Dropped off  ' , l_delivery_id);
		END IF;

		-- Drop Off Stop
		l_drop_off_flag := 'Y';
		l_stop_details.extend;
		l_stop_details(l_stop_details.COUNT) := WSH_OTM_STOP_DET_OBJ('D',l_delivery_id);
	  --}
	  END LOOP;


	  IF l_trip_tab(i).IGNORE_FOR_PLANNING = 'N' THEN
	  	l_stops_tab(i1).stop_duration := null;
	  END IF;

          --bug#5975661: Changing the stop sequence numbers for non planned trips as OTM expects sequence
          --             numbers starting from 1 (instead of stop sequence number (WTS.STOP_SEQUENCE_NUMBER)).
          IF l_trip_tab(i).IGNORE_FOR_PLANNING = 'Y' THEN
	  	l_stops_tab(i1).stop_sequence_number := i1;
	  END IF;
          --bug#597566:end
	  -- Drop off Stop
	  IF l_drop_off_flag = 'Y' THEN
	  --{
	  	l_stops_tab(i1).stop_duration := null;
	  	IF l_trip_tab(i).IGNORE_FOR_PLANNING = 'Y' THEN
	  		l_stops_tab(i1).ACTUAL_ARRIVAL_TIME := nvl(l_stops_tab(i1).ACTUAL_ARRIVAL_TIME,l_stops_tab(i1).PLANNED_ARRIVAL_TIME) ;
	  		l_stops_tab(i1).ACTUAL_DEPARTURE_TIME := nvl(l_stops_tab(i1).ACTUAL_DEPARTURE_TIME,l_stops_tab(i1).PLANNED_DEPARTURE_TIME);
	  	END IF;
	  --}
	  END IF;

	  CLOSE get_deliveries_picked;
	  CLOSE get_deliveries_dropped;
   	  IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Assigning the stop Details');
	  END IF;
  	  l_stops_tab(i1).stop_details := l_stop_details;

  	  l_stops_tab(i1).STOP_LOCATION_XID :=  WSH_OTM_REF_DATA_GEN_PKG.GET_STOP_LOCATION_XID(l_stops_tab(i1).STOP_LOCATION_XID);
  	--}
  	END LOOP;




	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_sub_module_name,'List of delivery Ids passed to GET_DELIVERY_OBJECTS');
	END IF;
  	FOR i in 1..l_dlv_ids.COUNT LOOP
  	--{
  		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'dlv_ids' ,l_dlv_ids(i));
	  	END IF;
 	--}
  	END LOOP;

  	-- Bug 6497991: Changed the parameter from x_error_trip_id_tab to x_error_dlv_id_tab
    --              After the call, deleting the trip record before raising exception
    --Bug 7408338 Added trip_id parameter
  	Get_Delivery_objects(l_dlv_ids,p_user_id,p_resp_id, p_resp_appl_id,'A',l_trip_tab(i).trip_id,x_domain_name,x_otm_user_name,
  				x_otm_pwd,x_server_tz_code, l_dlv_tab,x_error_dlv_id_tab,x_return_status);

        IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
        --{
          IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_sub_module_name,'failed in Get_Delivery_objects' ,x_return_status);
  	  END IF;
          x_error_trip_id_tab.extend;
          x_error_trip_id_tab(x_error_trip_id_tab.COUNT) := l_trip_tab(i).trip_id;
	  l_trip_tab.delete(i);
	  raise GET_DELIVERY_OBJECTS_FALIED;
       --}
       END IF;

  	l_lpn_tab := WSH_OTM_LPN_TAB();

  	FOR i2 in 1..l_dlv_tab.COUNT LOOP
  	--{
  		l_lpn_count := l_lpn_count + l_dlv_tab(i2).lpn.COUNT;
  		FOR j in 1..l_dlv_tab(i2).lpn.COUNT LOOP
  		--{
			l_lpn_tab.extend;
			l_lpn_tab(l_lpn_tab.COUNT) := l_dlv_tab(i2).lpn(j);
			l_lpn_tab(l_lpn_tab.COUNT).EQUIPMENT_XID := l_trip_tab(i).EQUIPMENT_XID;
  		--}
  		END LOOP;
  		dlv_in_tab(l_dlv_tab(i2).delivery_id) := l_dlv_tab(i2);
  		l_all_dlv_tab.extend;
  		l_all_dlv_tab(l_all_dlv_tab.COUNT) := l_dlv_tab(i2);
  	--}
  	END LOOP;

  	-- Populating the Stop Details
  	FOR i in 1..l_stops_tab.COUNT LOOP
  	--{
		l_stop_details := l_stops_tab(i).stop_details;
		l_stops_tab(i).stop_details := null;
		l_new_stop_details := WSH_OTM_STOP_DET_TAB();
			for j in 1..l_stop_details.COUNT loop
			--{
				l_lpns := dlv_in_tab(l_stop_details(j).lpn_id).lpn;
				for k in 1..l_lpns.COUNT LOOP
				--{
					l_new_stop_details.extend;
					l_new_stop_details(l_new_stop_details.COUNT) := WSH_OTM_STOP_DET_OBJ(l_stop_details(j).activity,l_lpns(k).lpn_id);
				--}
				end loop;
			--}
			end loop;
		l_stops_tab(i).stop_details := l_new_stop_details;
	--}
  	end loop;

  	l_trip_tab(i).LPNS		 := l_lpn_tab;
  	l_trip_tab(i).SHIPMENT_STOPS	 := l_stops_tab;
  	l_trip_tab(i).shipunit_count	 := l_lpn_count ;
  	--l_trip_tab(i).shipment_deliveries:= l_dlv_tab;
    --}
  --Bug 6497991: The Exceptions need to be handled inside the loop.
  --Exception for 1 trip should not affect other trips.
  EXCEPTION
    WHEN GET_FREIGHT_COST_ERROR THEN
         l_num_error := l_num_error + 1;
         IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_sub_module_name,' GET_FREIGHT_COST_ERROR',sqlerrm);
            WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:GET_FREIGHT_COST_ERROR');
         END IF;

    WHEN GET_DELIVERY_OBJECTS_FALIED THEN
	 l_num_error := l_num_error + 1;
         IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_sub_module_name,' GET_DELIVERY_OBJECTS_FALIED',sqlerrm);
            WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:GET_DELIVERY_OBJECTS_FALIED');
         END IF;

  END;
  END IF;
  --}
  END LOOP;
  -- Bug 6497991: the cursor needs to be closed if the last trip in the above loop throws any exception.
  IF get_deliveries_picked%ISOPEN THEN
    CLOSE get_deliveries_picked;
  END IF;

  IF get_deliveries_dropped%ISOPEN THEN
    CLOSE get_deliveries_dropped;
  END IF;
  x_trip_tab := l_trip_tab;
  x_dlv_tab  := l_all_dlv_tab;
   -- Bug 6497991(begin): Only Trips sucessfully processed to be sent.
  --                     for error trips, update tms_interface_flag back to 'ASR'
  IF (l_trip_tab.count > 0) THEN
  --{
     p_trip_id_tab.TRIM(p_trip_id_tab.count);
     i := l_trip_tab.first;
     WHILE (i is NOT NULL) LOOP
     --{
       p_trip_id_tab.extend;
       p_trip_id_tab(p_trip_id_tab.COUNT) := l_trip_tab(i).trip_id;
       i := l_trip_tab.NEXT(i);
     --}
     END LOOP;
  --}
  END IF;
  -- Bug 6497991(end):

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --}
 ELSE
 --{
   x_return_status := FND_API.G_RET_STS_ERROR;
 --}
 END IF;
 --
 -- Bug 6497991(begin): for error trips, update tms_interface_flag back to 'ASR'
 --
  IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_sub_module_name,'ERROR TRIP ids Count',x_error_trip_id_tab.count);
  END IF;
  IF ( x_error_trip_id_tab.count > 0 ) THEN
  --{
     i := x_error_trip_id_tab.first;
     WHILE (i is not NULL) LOOP
     --{
        OPEN get_trip_stops(x_error_trip_id_tab(i));
        FETCH  get_trip_stops BULK COLLECT INTO l_upd_trip_stops,l_upd_tms_interface_flags;
        CLOSE get_trip_stops;
        IF l_upd_trip_stops.COUNT > 0 THEN
        --{
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_sub_module_name,'Calling WSH_TRIP_STOPS_PVT.UPDATE_TMS_INTERFACE_FLAG Total stops ids',l_upd_trip_stops.COUNT);
           END IF;
           --
           WSH_TRIP_STOPS_PVT.UPDATE_TMS_INTERFACE_FLAG
                    (P_STOP_ID_TAB=>l_upd_trip_stops,
                     P_TMS_INTERFACE_FLAG_TAB =>l_upd_tms_interface_flags,
                     X_RETURN_STATUS   =>l_return_status);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_sub_module_name,'failed in UPDATE_TMS_INTERFACE_FLAG');
                END IF;
                raise FND_API.G_EXC_ERROR;
           END IF;
        --}
        END IF;
     i := x_error_trip_id_tab.NEXT(i);
     --}
     END LOOP;
  --}
  END IF;
  -- Bug 6497991(end)
 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_sub_module_name);
 END IF;
 --
EXCEPTION
-- Bug 6497991: Defined exceptions to be handled inside the LOOP
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_OTM_OUTBOUND.GET_TRIP_OBJECTS',l_sub_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF get_deliveries_picked%ISOPEN THEN
          CLOSE get_deliveries_picked;
       END IF;
       IF get_deliveries_dropped%ISOPEN THEN
          CLOSE get_deliveries_dropped;
       END IF;
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_sub_module_name,' OTHERS',sqlerrm);
          WSH_DEBUG_SV.pop(l_sub_module_name,'EXCEPTION:OTHERS');
       END IF;
END GET_TRIP_OBJECTS;



-- +==================================================================================================+
--   Procedure : GET_DELIVERY_OBJECTS
--   Description:
--     	Procedure to get the delivery,delivery details and Lpn info
--      in the form of objects (WSH_OTM_DLV_TAB)

--   Inputs/Outputs:
--            p_dlv_id_tab 	- id table (list of delivery Ids)
--            p_user_id  	- User Id to set the context
--            p_resp_id  	- Resp Id to set the context
--            p_resp_appl_id  	- Resp Appl Id to set the context
--            p_caller   	- When passed from GET_TRIP_OBJECTS this will have a
--				value of 'A' else default 'D'
--            p_trip_id         -  When passed from GET_TRIP_OBJECTS this will have trip_id else dafault -1
--
--   Output:
--            x_domain_name 	- domain name
--            x_otm_user_name 	- otm User Name
-- 	      x_otm_pwd    	- otm Password
-- 	      x_otm_pwd    	- otm Password
-- 	      x_dlv_tab    	- Nested Table which contains the delivery info
-- 	      x_error_dlv_id_tab - List of ids for which the data could not be retrieved
--            x_return_status
-- +==================================================================================================+



PROCEDURE GET_DELIVERY_OBJECTS(p_dlv_id_tab 		IN OUT NOCOPY	WSH_OTM_ID_TAB,
			       p_user_id		IN		NUMBER,
			       p_resp_id		IN		NUMBER,
			       p_resp_appl_id		IN		NUMBER,
			       p_caller			IN		VARCHAR2 DEFAULT 'D',
             p_trip_id		IN		NUMBER DEFAULT -1, --Bug7408338
			       x_domain_name    	OUT NOCOPY	VARCHAR2,
			       x_otm_user_name 		OUT NOCOPY	VARCHAR2,
			       x_otm_pwd		OUT NOCOPY	VARCHAR2,
			       x_server_tz_code		OUT NOCOPY	VARCHAR2,
			       x_dlv_tab 		OUT NOCOPY 	WSH_OTM_DLV_TAB,
			       x_error_dlv_id_tab	OUT NOCOPY 	WSH_OTM_ID_TAB,
			       x_return_status 		OUT NOCOPY 	VARCHAR2  ) IS

-- Declare local variables

  l_sub_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_OBJECTS';
  l_dlv_tab 	  	wsh_otm_dlv_tab;
  l_all_details 	wsh_otm_det_tab;
  l_del_details 	wsh_otm_det_tab;
  l_rl_details	  	wsh_otm_det_tab;
  l_lpn_tab         	wsh_otm_lpn_tab;
  l_packed_items  	WSH_OTM_LPN_CONT_TAB;
  l_loose_items_ids  	WSH_OTM_ID_TAB;
  l_dlv_obj		wsh_otm_dlv_obj;
  l_det_obj		wsh_otm_det_obj;
  l_weight        	NUMBER;
  l_dlv_id_tab		WSH_OTM_ID_TAB;
  l_error_dlv_id_tab	WSH_OTM_ID_TAB;


  c_deliveries          WSH_UTIL_CORE.RefCurType;
  bind_col_tab          WSH_UTIL_CORE.tbl_varchar;
  otm_uom_tab           WSH_UTIL_CORE.tbl_varchar;
  l_deliveries_sql 	VARCHAR2(2000);
  l_count		NUMBER;
  l_customer_id		NUMBER;
  l_cnt			NUMBER;
  i 			NUMBER;
  l			NUMBER;
  x			NUMBER;
  l_total_quantity 	NUMBER;
  l_cont_type		VARCHAR2(30);
  l_length		NUMBER;
  l_height		NUMBER;
  l_width		NUMBER;
  l_uom			VARCHAR2(150);
  l_organization_code   VARCHAR2(30);
  l_internal_org_location_id	VARCHAR2(150);
  l_dropoff_location_id		NUMBER;
  l_return_status		VARCHAR2(10);
  position			NUMBER;
  l_found			BOOLEAN;
  l_quantity			NUMBER;
  l_delivery_id			NUMBER;
  l_inventory_item		VARCHAR2(30);
  l_otm_dimen_uom		VARCHAR2(150);
  l_cust_type 			VARCHAR2(5) := 'CUS-';
  l_org_type			VARCHAR2(5) := 'ORG-';
  l_car_type			VARCHAR2(5) := 'CAR-';
  l_organization_id		NUMBER;
  x_base_wt_uom			VARCHAR2(150);
  x_base_vol_uom		VARCHAR2(150);

  CONVERT_INT_LOC_FALIED	EXCEPTION;
  GET_DEAFULT_UOMS_FAILED	EXCEPTION;

  TYPE All_LPNS  is TABLE of  wsh_otm_lpn_obj INDEX BY BINARY_INTEGER;
  l_all_lpn_tab 		All_LPNS;
  l_dummy_lpn_tab		All_LPNS;

  TYPE all_lpn_rec_type IS RECORD(
  lpn_id			NUMBER,
  lpn_type			VARCHAR2(100),
  gross_weight			NUMBER,
  net_weight			NUMBER,
  weight_uom_code		varchar2(150),
  volume_uom_code		varchar2(150),
  seal_code			varchar2(30),
  packed_items			WSH_OTM_LPN_CONT_TAB,
  parent_delivery_detail_id     NUMBER);

  -- Bug 7207835
  l_p_caller VARCHAR2(10);
  -- 6922924
  l_good_dlv_tab                wsh_otm_dlv_tab;
  l_upd_tms_interface_flags     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_upd_err_dlvys               WSH_UTIL_CORE.ID_TAB_TYPE;


  CURSOR get_customer_id (p_delivery_id NUMBER) IS
   SELECT wdd.customer_id, count(*) cnt
   FROM   wsh_delivery_assignments wda,
          wsh_delivery_details wdd
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
   AND    wda.delivery_id        =  p_delivery_id
   AND    wdd.container_flag     = 'N'
   GROUP BY customer_id
   ORDER BY cnt DESC;

   CURSOR get_organization_code( p_location_id NUMBER) IS
   SELECT organization_code
   FROM   mtl_parameters mp, hr_organization_units hou
   WHERE  mp.organization_id = hou.organization_id
   AND    hou.location_id = p_location_id;


 -- Bug#5746380 Added p_organization_id in the Cursor.
 CURSOR get_container_details ( p_inventory_item_id NUMBER, p_organization_id NUMBER) IS
 SELECT CONTAINER_TYPE_CODE,
	UNIT_LENGTH ,
	UNIT_HEIGHT  ,
	UNIT_WIDTH   ,
	DIMENSION_UOM_CODE
 FROM mtl_system_items
 WHERE inventory_item_id = p_inventory_item_id
 AND   organization_id = p_organization_id;

--6922924 : (begin) : Update tms_interface_flag for error Deliveries
CURSOR get_errored_dlvys(c_dlvy_id NUMBER) IS
 SELECT delivery_id, decode(tms_interface_flag, 'CP', 'CR', 'UP', 'UR', 'DP',
  'DR', tms_interface_flag )  tms_iface_new_status
  FROM wsh_new_deliveries
  WHERE delivery_id = c_dlvy_id
 FOR UPDATE OF tms_interface_flag NOWAIT;

begin
--{
  --  Initialize API return status to success

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_sub_module_name);
  END IF;

  IF l_debug_on THEN
	  FOR i in 1..p_dlv_id_tab.COUNT LOOP
		 WSH_DEBUG_SV.log(l_sub_module_name,'Dlv Id : ' , p_dlv_id_tab(i));
	  END LOOP;
	  WSH_DEBUG_SV.log(l_sub_module_name,'p_user_id' , p_user_id);
	  WSH_DEBUG_SV.log(l_sub_module_name,'p_resp_id' , p_resp_id);
	  WSH_DEBUG_SV.log(l_sub_module_name,'p_resp_appl_id' , p_resp_appl_id);
	  WSH_DEBUG_SV.log(l_sub_module_name,'p_caller' , p_caller);
  END IF ;
  -- Bug 7207835 p_caller value not defaulting to 'D' when passed as NULL.
  l_p_caller := NVL(p_caller,'D');
  -- End Bug 7207835
 -- Setting the apps context
 --Bug8231371 calling WSH_OTM_APPS_INITIALIZE to set apps context
 WSH_OTM_APPS_INITIALIZE(p_user_id => p_user_id,
 			 p_resp_id =>p_resp_id,
 			 p_resp_appl_id => p_resp_appl_id);


 -- Getting the profile values
 fnd_profile.get('WSH_OTM_DOMAIN_NAME',x_domain_name);
 fnd_profile.get('WSH_OTM_USER_ID',x_otm_user_name);
 fnd_profile.get('WSH_OTM_PASSWORD',x_otm_pwd);
 x_server_tz_code := FND_TIMEZONES.get_server_timezone_code();

 IF l_debug_on THEN
 	WSH_DEBUG_SV.log(l_sub_module_name,'Building the dymanic sql to fetch Deliveries');
 END IF;

 l_deliveries_sql :=
 'select '
 ||'wsh_otm_dlv_obj( '
 ||'decode(wnd.tms_interface_flag,''CP'',''RC'',''UP'',''RC'',''DP'',''D''),'
 --||'''RC'','
 ||'wnd.delivery_id,'
 ||'wnd.name,'
 ||'wnd.freight_terms_code,'
 ||'wnd.fob_code,'
 ||'wnd.carrier_id,'
 ||'wnd.service_level,'
 ||'wnd.mode_of_transport,'
 ||'wnd.organization_id||''-''|| wnd.INITIAL_PICKUP_LOCATION_ID,'
 ||'wnd.customer_id ||''-''||wnd.ULTIMATE_DROPOFF_LOCATION_ID,'
 ||'wnd.EARLIEST_PICKUP_DATE,'
 ||'wnd.LATEST_PICKUP_DATE,'
 ||'wnd.EARLIEST_DROPOFF_DATE,'
 ||'wnd.LATEST_DROPOFF_DATE,'
 ||'nvl(wnd.GROSS_WEIGHT,0),'
 ||'wnd.WEIGHT_UOM_CODE,'
 ||'nvl(wnd.VOLUME,0),'
 ||'wnd.VOLUME_UOM_CODE,'
 ||'nvl(wnd.NET_WEIGHT,0),'
 ||'wnd.TMS_VERSION_NUMBER,'   -- revision number
 ||'wnd.REASON_OF_TRANSPORT,'
 ||'wnd.DESCRIPTION,'
 ||'wnd.ADDITIONAL_SHIPMENT_INFO,'
 ||'wnd.ROUTING_INSTRUCTIONS,'
 ||'null,''REVNUM'',''TRSP_REASON'',''DEL_DESCRIPTION'',''ADD_INFOS'',''ROUTING_INSTR'',null,null),'
 ||' wsh_otm_det_obj(wdd.delivery_detail_id,'
   		||'wdd.lot_number,'
     		||'wdd.serial_number,'
     		||'wdd.to_serial_number,'
   		||'nvl(wdd.GROSS_WEIGHT,0),'
   		||'wdd.WEIGHT_UOM_CODE	,'
   		||'nvl(wdd.VOLUME,0)	,'
   		||'wdd.VOLUME_UOM_CODE,'
   		||'nvl(wdd.picked_quantity,wdd.requested_quantity),' --Bug9503264
   		||'wdd.SHIPPED_QUANTITY,'
   		||'wdd.organization_id || ''-'' || wdd.INVENTORY_ITEM_ID,'
   		||'wdd.container_flag,'
   		||'wda.parent_delivery_detail_id,'
   		||'wdd.cust_po_number,'
  		||'wdd.source_header_number,''CUST_PO'',''SO_NUM'', wda.delivery_id,nvl(wdd.NET_WEIGHT,0))'
 ||'  from wsh_new_deliveries wnd, wsh_delivery_details wdd  , wsh_delivery_assignments wda'
 ||' where wdd.delivery_detail_id(+) = wda.delivery_detail_id '
 ||' and wnd.delivery_id = wda.delivery_id(+) '
 ||' and wnd.delivery_id in (';
--Bug 7408338
 IF (l_p_caller = 'A') THEN
 --{
     l_deliveries_sql := l_deliveries_sql ||' select wdl.delivery_id from wsh_delivery_legs wdl, wsh_trip_stops wts where wdl.pick_up_stop_id = wts.stop_id and wts.trip_id = :1 ' ;
     bind_col_tab(bind_col_tab.COUNT+1) := to_char(p_trip_id);
 ELSE
     FOR i in 1..p_dlv_id_tab.COUNT LOOP
     --{
 	     IF i <> 1 THEN
 		     l_deliveries_sql := l_deliveries_sql || ',';
 	     END IF;
 	     l_deliveries_sql := l_deliveries_sql || ':' || i;
 	     bind_col_tab(bind_col_tab.COUNT+1) := to_char(p_dlv_id_tab(i));
     --}
     END LOOP;
 --}
 END IF;

 l_deliveries_sql := l_deliveries_sql || ')';
 IF l_p_caller <> 'A' THEN
 	l_deliveries_sql := l_deliveries_sql || ' and wnd.tms_interface_flag in (''CP'',''DP'',''UP'') ';
 END IF;
 --bug # 7150082: Deliveries need to be passed in the order of delete,update and create to OTM
 l_deliveries_sql := l_deliveries_sql || 'order by decode(wnd.tms_interface_flag,''CP'',''3'',''UP'',''2'',''DP'',''1''),wda.delivery_id, wdd.container_flag desc';

 i:=1;

 WSH_UTIL_CORE.OpenDynamicCursor(c_deliveries, l_deliveries_sql, bind_col_tab);
 l_count := 1;
 l_dlv_tab := wsh_otm_dlv_tab();
 --l_all_details - contains the delivery details of all the deliveries queried.
 l_all_details := wsh_otm_det_tab();
 -- 6922924
 l_good_dlv_tab := wsh_otm_dlv_tab();

 --l_dlv_obj := wsh_otm_dlv_obj();
l_dlv_id_tab := WSH_OTM_ID_TAB();
 LOOP
 --{
	FETCH c_deliveries INTO l_dlv_obj,l_det_obj;
	EXIT  WHEN (c_deliveries%NOTFOUND);
	IF ( l_dlv_tab.COUNT = 0  OR l_dlv_tab(l_dlv_tab.COUNT).delivery_id <> l_dlv_obj.delivery_id) THEN
		l_dlv_tab.extend;
		l_dlv_tab(l_dlv_tab.COUNT) := l_dlv_obj;
	END IF;
	l_all_details.extend;
	l_all_details(l_all_details.COUNT) := l_det_obj;
	l_count := l_count+1;
 --}
 END LOOP;

IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_sub_module_name,'count of deliveries ' , l_dlv_tab.COUNT);
END IF;


IF  l_dlv_tab.COUNT >0 THEN
--{   when l_dlv_tab count > 0

  l_error_dlv_id_tab := WSH_OTM_ID_TAB();
  FOR i in 1..l_dlv_tab.COUNT LOOP
  --{   -- 6922924  Loop Start
  BEGIN

  	l_delivery_id := l_dlv_tab(i).delivery_id;

  	IF l_p_caller = 'A' THEN
  		l_dlv_tab(i).transaction_code := 'RC';
  	END IF;


  	IF l_dlv_tab(i).CARRIER_ID IS NOT NULL THEN
  		l_dlv_tab(i).CARRIER_ID := l_car_type || l_dlv_tab(i).CARRIER_ID;
  	END IF;

  	-- Getting the organization_id
    	position := instr(l_dlv_tab(i).INITIAL_PICKUP_LOCATION_ID,'-');
    	l_organization_id := substr(l_dlv_tab(i).INITIAL_PICKUP_LOCATION_ID,1, position-1);


  	IF l_dlv_tab(i).INITIAL_PICKUP_LOCATION_ID IS NOT NULL THEN
  		l_dlv_tab(i).INITIAL_PICKUP_LOCATION_ID := l_org_type || l_dlv_tab(i).INITIAL_PICKUP_LOCATION_ID;
  	END IF;

	-- Populating the ULTIMATE_DROPOFF_LOCATION_ID based on whether it is internal or external location.
    	position := instr(l_dlv_tab(i).ULTIMATE_DROPOFF_LOCATION_ID,'-');
    	l_customer_id := substr(l_dlv_tab(i).ULTIMATE_DROPOFF_LOCATION_ID,1, position-1);
    	l_dropoff_location_id := substr(l_dlv_tab(i).ULTIMATE_DROPOFF_LOCATION_ID,position+1);

    	WSH_OTM_REF_DATA_GEN_PKG.GET_INT_LOCATION_XID(
    				p_location_id => l_dropoff_location_id,
    				x_location_xid  => l_internal_org_location_id,
    				x_return_status =>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
           raise CONVERT_INT_LOC_FALIED;
        END IF;
	IF l_internal_org_location_id is NOT NULL THEN
		l_dlv_tab(i).ULTIMATE_DROPOFF_LOCATION_ID := l_internal_org_location_id;
	ELSE
	--{
    		-- If customer_id is null in wsh_new_deliveries
		IF l_customer_id is NULL THEN
			open get_customer_id(l_dlv_tab(i).delivery_id);
			fetch get_customer_id into l_customer_id,l_cnt;
			close get_customer_id;
		END IF;
		l_dlv_tab(i).ULTIMATE_DROPOFF_LOCATION_ID := l_cust_type
								|| l_customer_id  || '-'
								|| l_dropoff_location_id;
	--}
	END IF;

	WSH_WV_UTILS.GET_DEFAULT_UOMS(l_organization_id, x_base_wt_uom, x_base_vol_uom, x_return_status);
	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
	   raise GET_DEAFULT_UOMS_FAILED;
	END IF;

	IF l_dlv_tab(i).WEIGHT_UOM_CODE is null THEN
		l_dlv_tab(i).WEIGHT_UOM_CODE := x_base_wt_uom;
	END IF;
	IF l_dlv_tab(i).VOLUME_UOM_CODE is null THEN
		l_dlv_tab(i).VOLUME_UOM_CODE := x_base_vol_uom;
	END IF;

	WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
		p_uom=>l_dlv_tab(i).WEIGHT_UOM_CODE,
		x_uom=>l_dlv_tab(i).WEIGHT_UOM_CODE,
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;

	WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
		p_uom=>l_dlv_tab(i).VOLUME_UOM_CODE,
		x_uom=>l_dlv_tab(i).VOLUME_UOM_CODE,
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;





   	--l_del_details - contains the delivery details of the delivery l_dlv_tab(i).delivery_id

    	l_del_details := wsh_otm_det_tab();
    	get_del_details(l_all_details,l_dlv_tab(i).delivery_id,l_del_details);




	l_rl_details := wsh_otm_det_tab();
	l_lpn_tab := wsh_otm_lpn_tab();
	l_all_lpn_tab := l_dummy_lpn_tab;
	l_total_quantity := 0;

	-- Loop through l_del_details to create the following
	-- l_rl_details  -- Basically all the release lines of this delivery
	-- l_loose_items   -- All the loose items in l_del_details
	-- lpn_tab       -- All the Outmost lpns in l_del_details + Lpns for Loose Items
	-- l_all_lpn_tab   -- All the lpns in l_del_details
	FOR i in 1..l_del_details.COUNT LOOP
	--{
		IF l_del_details(i).WEIGHT_UOM_CODE is null THEN
			l_del_details(i).WEIGHT_UOM_CODE := x_base_wt_uom;
		END IF;
		IF l_del_details(i).VOLUME_UOM_CODE is null THEN
			l_del_details(i).VOLUME_UOM_CODE := x_base_vol_uom;
		END IF;


		WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
			p_uom=>l_del_details(i).WEIGHT_UOM_CODE,
			x_uom=>l_del_details(i).WEIGHT_UOM_CODE,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

		WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
			p_uom=>l_del_details(i).VOLUME_UOM_CODE,
			x_uom=>l_del_details(i).VOLUME_UOM_CODE,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;





		IF l_del_details(i).container_flag = 'N'THEN
		--{
			l_rl_details.extend;
			l_rl_details(l_rl_details.COUNT ) := l_del_details(i);
			IF l_p_caller = 'A' THEN
				l_quantity := l_del_details(i).SHIPPED_QUANTITY;
			ELSE
				l_quantity := l_del_details(i).REQUESTED_QUANTITY;
			END IF;
			l_total_quantity := l_total_quantity + l_quantity;

			IF l_del_details(i).parent_delivery_detail_id is null THEN
			--{

				l_packed_items := WSH_OTM_LPN_CONT_TAB();
				l_packed_items.extend;
				l_packed_items(l_packed_items.COUNT) := WSH_OTM_LPN_CONT_OBJ(l_del_details(i).delivery_detail_id,1,
										l_del_details(i).inventory_item_id,
										CEIL(l_quantity),
										l_del_details(i).delivery_detail_id,
										l_delivery_id,
										l_del_details(i).gross_weight,
										l_del_details(i).net_weight,
										l_del_details(i).weight_uom_code,
										l_del_details(i).volume,
										l_del_details(i).volume_uom_code
										);
				-- Creating a dummy lpn for the loose item
				l_lpn_tab.extend;

                                -- Getting Item Dimensions for Loose Item
				l_inventory_item := l_del_details(i).inventory_item_id;
                                --Bug 5746380
                                open get_container_details(substr(l_inventory_item,instr(l_inventory_item,'-') + 1),
                                                           l_organization_id);
				fetch get_container_details into l_cont_type, l_length, l_height, l_width, l_uom;
				close get_container_details;
        			IF l_debug_on THEN
        		           WSH_DEBUG_SV.log(l_sub_module_name,'Calling Get_EBS_To_OTM_UOM Weight for Loose Item : '||substr(l_inventory_item,instr(l_inventory_item,'-') + 1));
                                END IF;
			        WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
        				p_uom=>l_uom,
        				x_uom=>l_otm_dimen_uom ,
        				x_return_status=>l_return_status);
        			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
        				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
        				IF l_debug_on
        				THEN
        				   WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed for Loose Item');
        				END IF;
        				raise FND_API.G_EXC_ERROR;
        			END IF;

				l_lpn_tab(l_lpn_tab.COUNT) := wsh_otm_lpn_obj(l_del_details(i).delivery_detail_id,null,l_del_details(i).gross_weight,l_del_details(i).net_weight,
								l_del_details(i).weight_uom_code,l_del_details(i).volume_uom_code,
								null,l_packed_items,null,
								null,l_length,l_height,l_width,l_otm_dimen_uom,l_del_details(i).volume,null);
			--}
			ELSE
			--{
				x := l_del_details(i).parent_delivery_detail_id;
				LOOP
				--{
					IF l_all_lpn_tab(x).parent_delivery_detail_id is null then
						l_all_lpn_tab(x).packed_items.extend;
						l_all_lpn_tab(x).packed_items(l_all_lpn_tab(x).packed_items.COUNT)
									:= WSH_OTM_LPN_CONT_OBJ(
									l_del_details(i).delivery_detail_id,
									l_all_lpn_tab(x).packed_items.COUNT,
									l_del_details(i).inventory_item_id,
									CEIL(l_quantity),
									l_all_lpn_tab(x).lpn_id,
									l_delivery_id,
									l_del_details(i).gross_weight,
									l_del_details(i).net_weight,
									l_del_details(i).weight_uom_code,
									l_del_details(i).volume,
									l_del_details(i).volume_uom_code
									);
						exit;
					ELSE
						x:= l_all_lpn_tab(x).parent_delivery_detail_id;
					END IF;
				--}
				END LOOP;
			--}
			END IF;
		--}
		ELSE
		--{
			IF l_del_details(i).parent_delivery_detail_id is null THEN
				l_inventory_item := l_del_details(i).inventory_item_id;
                                --Bug 5746380
                                open get_container_details(substr(l_inventory_item,instr(l_inventory_item,'-') + 1),
                                                           l_organization_id);
				fetch get_container_details into l_cont_type, l_length, l_height, l_width, l_uom;
				close get_container_details;
			END IF;

			WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM(
				p_uom=>l_uom,
				x_uom=>l_otm_dimen_uom ,
				x_return_status=>l_return_status);
			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_sub_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;


			l_all_lpn_tab(l_del_details(i).delivery_detail_id) :=
								wsh_otm_lpn_obj(l_del_details(i).delivery_detail_id,
								null,
								l_del_details(i).gross_weight,
								l_del_details(i).net_weight,
								l_del_details(i).weight_uom_code,
								l_del_details(i).volume_uom_code,
								null,
								null,
								l_del_details(i).parent_delivery_detail_id,
								l_cont_type, l_length, l_height, l_width, l_otm_dimen_uom,l_del_details(i).volume,null);
			l_all_lpn_tab(l_del_details(i).delivery_detail_id).packed_items := WSH_OTM_LPN_CONT_TAB();
		--}
		END IF;
	--}
	END LOOP;

        -- ECO 5768287
	-- Populating the lpn_tab with only non-empty outermost Lpns in l_all_lpn_tab

	IF l_all_lpn_tab.COUNT >0 THEN
	--{
		l := l_all_lpn_tab.FIRST;
		WHILE l is not NULL
		LOOP
		--{
			IF l_all_lpn_tab(l).parent_delivery_detail_id is null AND l_all_lpn_tab(l).packed_items.count > 0 THEN
				l_lpn_tab.EXTEND;
				l_lpn_tab(l_lpn_tab.COUNT) := l_all_lpn_tab(l);

			END IF;
			l := l_all_lpn_tab.NEXT(l);
		--}
		END LOOP;
	--}
	END IF;

	l_dlv_tab(i).lpn :=  l_lpn_tab;
	l_dlv_tab(i).rl_details := l_rl_details;
	l_dlv_tab(i).TOTAL_ITEM_COUNT := CEIL(l_total_quantity);

        -- 6922924
        l_dlv_id_tab.extend;
        l_dlv_id_tab(l_dlv_id_tab.COUNT) := l_dlv_tab(i).delivery_id;
        l_good_dlv_tab.extend;
        l_good_dlv_tab(l_good_dlv_tab.COUNT) := l_dlv_tab(i);
        --
   EXCEPTION
 	WHEN GET_DEAFULT_UOMS_FAILED THEN
       	-- 6830854
       	    IF l_debug_on
              THEN
               WSH_DEBUG_SV.log(l_sub_module_name,'GET_DEAFULT_UOMS_FALIED',sqlerrm);
               WSH_DEBUG_SV.log(l_sub_module_name,'Delivery id: '||l_delivery_id);
              END IF;

 	WHEN CONVERT_INT_LOC_FALIED THEN
       -- 6830854
             IF l_debug_on
              THEN
               WSH_DEBUG_SV.log(l_sub_module_name,'CONVERT_INT_LOC_FALIED',sqlerrm);
               WSH_DEBUG_SV.log(l_sub_module_name,'Delivery id: '||l_delivery_id);
             END IF;

 	WHEN FND_API.G_EXC_ERROR THEN
       -- 6830854
             IF l_debug_on
              THEN
               WSH_DEBUG_SV.log(l_sub_module_name,' FND_API.G_EXC_ERROR',sqlerrm);
               WSH_DEBUG_SV.log(l_sub_module_name,'Delivery id: '||l_delivery_id);
             END IF;

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- 6830854
       	     IF l_debug_on
       	      THEN
       	       WSH_DEBUG_SV.log(l_sub_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR',sqlerrm);
       	       WSH_DEBUG_SV.log(l_sub_module_name,'Delivery id: '||l_delivery_id);
       	     END IF;

   	WHEN OTHERS THEN
       	wsh_util_core.default_handler('WSH_OTM_OUTBOUND.GET_DELIVERY_OBJECTS',l_sub_module_name);
        -- 6922924 Note : Removed all ref: to x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --  in this Exception and above Exceptions
              IF l_debug_on
               THEN
                WSH_DEBUG_SV.log(l_sub_module_name,'WHEN OTHERS inside Get Delivery Loop',sqlerrm);
                WSH_DEBUG_SV.log(l_sub_module_name,'Delivery id: '||l_delivery_id);
              END IF;
     END;

     -- 6922924
     IF get_customer_id%ISOPEN THEN
         CLOSE get_customer_id;
     END IF;
     IF get_container_details%ISOPEN THEN
         CLOSE get_container_details;
     END IF;
     --}   --- 6922924 End Loop
    END LOOP;

  -- If all the deliveries in the input parameter p_dlv_id_tab where not queried
  -- Put those id's in the error_dlv_id_list
  IF l_dlv_id_tab.COUNT <> p_dlv_id_tab.COUNT THEN
  --{
    FOR i in 1..p_dlv_id_tab.COUNT LOOP
    --{
    	l_found := FALSE;
  	FOR j in 1..l_dlv_id_tab.COUNT LOOP
	--{
		IF l_dlv_id_tab(j) = p_dlv_id_tab(i) THEN
			l_found := TRUE;
			EXIT;
		END IF;
		IF l_dlv_id_tab(j) > p_dlv_id_tab(i) THEN
			EXIT;
		END IF;
	--}
    	END LOOP;
    	IF l_found = FALSE THEN
    		l_error_dlv_id_tab.extend;
    		l_error_dlv_id_tab(l_error_dlv_id_tab.COUNT) := p_dlv_id_tab(i);
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_sub_module_name,'Errored Delivery id: ' , p_dlv_id_tab(i) );
                     WSH_DEBUG_SV.log(l_sub_module_name,'Count of i' , i);
                 END IF;
    	END IF;
    --}
    END LOOP;
  --}
  END IF;

 -- 6922924
  x_dlv_tab := l_good_dlv_tab;
  p_dlv_id_tab := l_dlv_id_tab;
  x_error_dlv_id_tab := l_error_dlv_id_tab;


 --6922924
 -- Update the tms_interface_flag to 'CR' and Print the List of Errored Delivery Ids
  IF ( x_error_dlv_id_tab.count > 0 ) THEN
    IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_sub_module_name,'ERROR DELIVERY ids Count',x_error_dlv_id_tab.count);
    END IF;
  --{
     i := x_error_dlv_id_tab.first;
     WHILE (i is not NULL) LOOP
     --{
        OPEN get_errored_dlvys(x_error_dlv_id_tab(i));
        FETCH  get_errored_dlvys INTO l_upd_err_dlvys(1), l_upd_tms_interface_flags(1);
        CLOSE get_errored_dlvys;
        IF l_upd_err_dlvys.COUNT > 0 THEN
        --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_sub_module_name,'Calling WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
            END IF;
            --
             WSH_NEW_DELIVERIES_PVT.Update_Tms_interface_flag
                ( p_delivery_id_tab        => l_upd_err_dlvys,
                  p_tms_interface_flag_tab => l_upd_tms_interface_flags,
                  x_return_status          => l_return_status );
          --
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_sub_module_name,'failed in WND_PVT.UPDATE_TMS_INTERFACE_FLAG');
                     END IF;
                     -- 6830854  raise FND_API.G_EXC_ERROR;
                     -- removing the above as Error can occur in Validation again
             END IF;
        --}
        END IF;
        i := x_error_dlv_id_tab.NEXT(i);
     --}
     END LOOP;
   -- }
  END IF;


  --------- Printing the complete structure------------
  IF l_debug_on THEN
  --{
    FOR k in 1..x_dlv_tab.COUNT LOOP
    --{
   	WSH_DEBUG_SV.log(l_sub_module_name,'dlv_id' , x_dlv_tab(k).delivery_id);
	FOR i in 1..x_dlv_tab(k).rl_details.COUNT LOOP
          WSH_DEBUG_SV.log(l_sub_module_name,'DD  ' , x_dlv_tab(k).rl_details(i).delivery_detail_id);
  	END LOOP;
  	WSH_DEBUG_SV.log(l_sub_module_name,'Ship Units Count' , x_dlv_tab(k).lpn.COUNT);
  	FOR i in 1..x_dlv_tab(k).lpn.COUNT LOOP
  	--{
          WSH_DEBUG_SV.log(l_sub_module_name,'Lpn Id ' , x_dlv_tab(k).lpn(i).lpn_id);
          FOR j in 1..x_dlv_tab(k).lpn(i).packed_items.COUNT LOOP
                 WSH_DEBUG_SV.log(l_sub_module_name,'Content  ' ,x_dlv_tab(k).lpn(i).packed_items(j).content_id);
		 WSH_DEBUG_SV.log(l_sub_module_name,'Content  ' ,x_dlv_tab(k).lpn(i).packed_items(j).line_number);
          END LOOP;
        --}
  	END LOOP;
    --}
    END LOOP;
  --}
  END IF;
  --------- End of Printing the complete structure------------
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
ELSE
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_sub_module_name,'Else error');
    END IF;
    x_error_dlv_id_tab := p_dlv_id_tab;
    p_dlv_id_tab := l_dlv_id_tab;
    x_dlv_tab := l_dlv_tab;
    x_return_status := FND_API.G_RET_STS_ERROR;
END IF;
-- }  Main IF -  when l_dlv_tab count > 0
 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_sub_module_name);
 END IF;
 --
EXCEPTION
-- 6922924 removeing all Exceptions to Inside the Loop as in above
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_OTM_OUTBOUND.GET_DELIVERY_OBJECTS',l_sub_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF get_customer_id%ISOPEN THEN
          CLOSE get_customer_id;
       END IF;
       IF get_container_details%ISOPEN THEN
          CLOSE get_container_details;
       END IF;
       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_sub_module_name,'When Others');
       END IF;
end GET_DELIVERY_OBJECTS;



-- +======================================================================+
--   Procedure : UPDATE_ENTITY_INTF_STATUS
--   Description:
--     	This procedure will be used to upate the interface flag status on the delivery or trip stop.
--
--   Inputs/Outputs:
--            p_entity_type - Valid values are "DELIVERY",  "TRIP"
--            p_entity_id_tab  - id table  (IN / OUT) -- List of Delivery id or Trip id
--            p_new_intf_status - Delivery or Trip Stop Status
--             Valid values of this parameter are "IN_PROCESS", "COMPLETE"
--
--                       Trip Stop Interface Flag values (internal):
--                       ASR - ACTUAL_SHIP_REQUIRED
--                       ASP - ACTUAL_IN_PROCESS
--                       CMP - COMPLETE
--
--                       Delivery Interface Flag values (internal):
--                       NS - NOT TO BE SENT
--                       CR - CREATE_REQUIRED
--                       UR - UPDATE_REQUIRED
--                       DR - DELETE_REQUIRED
--                       CP - CREATE_IN_PROCESS
--                       UP- UPDATE_IN_PROCESS
--                       DP - DELETE_IN_PROCESS
--                       AW - AWAITING_ANSWER
--                       AR - ANSWER_RECEIVED
--                       CMP - COMPLETE
--            p_user_Id  - user id ( application user id )
--            p_resp_Id - responsibility id
--            p_resp_appl_Id - resp application id ( Application Responsibility Id)
--   Output:
--            p_error_id_tab - erred entity id table  -- list of ERRORed delivery id or tripd id
--            p_entity_id_tab  - id table  (IN / OUT) - list of SUCCESS delivery id or trip id
--            x_return_status - "S"-Success, "E"-Error, "U"-Unexpected Error
--   API is called from the following phases / API
/*
1.Concurrent Request --TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = X_IN_PROCESS.
2.WSH_GLOG_OUTBOUND.GET_TRIP_OBJECTS - TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = AWAITING_ANSWER.
3.WSH_GLOG_OUTBOUND.GET_DELIVERY_OBJECTS - TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = AWAITING_ANSWER.
*/



-- +======================================================================+
PROCEDURE UPDATE_ENTITY_INTF_STATUS(
           x_return_status   OUT NOCOPY   VARCHAR2,
           p_entity_type     IN VARCHAR2,
           p_new_intf_status IN VARCHAR2,
           p_userId          IN    NUMBER DEFAULT NULL,
           p_respId          IN    NUMBER DEFAULT NULL,
           p_resp_appl_Id    IN    NUMBER DEFAULT NULL,
           p_entity_id_tab   IN OUT NOCOPY WSH_OTM_ID_TAB,
           p_error_id_tab    IN OUT NOCOPY WSH_OTM_ID_TAB
      ) IS

-- Declare local variables

l_sub_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ENTITY_INTF_STATUS';
l_entity_id_out_tab WSH_OTM_ID_TAB :=WSH_OTM_ID_TAB();
l_error_id_out_tab WSH_OTM_ID_TAB := WSH_OTM_ID_TAB();
l_id_tab WSH_UTIL_CORE.ID_TAB_TYPE;
l_status_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_del_current_status varchar2(3);
l_del_id_error_flag VARCHAR2(1) := 'N';
l_stop_id_tab WSH_UTIL_CORE.ID_TAB_TYPE;
l_stop_status_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_return_status VARCHAR2(1);
l_del_status_code varchar2(30);
l_ignore_for_planning  VARCHAR2(1);
l_is_delivery_empty       VARCHAR2(1);
i NUMBER;
j NUMBER;
k NUMBER;
-- Define Exception variables
UPD_DEL_INTF_FLAG_API_FALIED EXCEPTION;
UPD_STOP_INTF_FLAG_API_FALIED EXCEPTION;
INVALID_ENTITY_TYPE EXCEPTION;
INVALID_NEW_INTF_STATUS EXCEPTION;

-- define the cursor to get the current TMS_INTERFACE_FLAG  status of delivery
cursor get_del_tms_interface_flag(c_delivery_id NUMBER) IS
       select TMS_INTERFACE_FLAG,status_code,nvl(ignore_for_planning,'N') from wsh_new_deliveries
       where delivery_id = c_delivery_id;

-- define the cursor to get all trip stops for the given trip id.
cursor get_trip_stops(c_trip_id NUMBER) IS
       select stop_id,TMS_INTERFACE_FLAG from wsh_trip_stops
       where trip_id = c_trip_id;
      -- and (TMS_INTERFACE_FLAG ='ASR' or TMS_INTERFACE_FLAG ='ASP');
BEGIN
  -- save point
  SAVEPOINT  UPDATE_ENTITY_INTF_STATUS;

  --  Initialize API return status to success
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- initialize Apps variables
  --Bug8231371 calling WSH_OTM_APPS_INITIALIZE to set apps context
  IF p_userid is NOT NULL THEN
     WSH_OTM_APPS_INITIALIZE(p_user_id => p_userid,
			     p_resp_id => p_respid,
			     p_resp_appl_id => p_resp_appl_id);

  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     --{
     fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
     l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

     WSH_DEBUG_SV.push(l_sub_module_name);
     WSH_DEBUG_SV.log(l_sub_module_name,'Begin of the process ',l_debugfile);
     WSH_DEBUG_SV.log(l_sub_module_name,'p_entity_type ',p_entity_type);
     WSH_DEBUG_SV.log(l_sub_module_name,'p_new_intf_status ',p_new_intf_status);
    --}
  END IF;
  --
  --Validations
  IF p_new_intf_status NOT IN ('IN_PROCESS','COMPLETE') THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_sub_module_name,'Invalid p_new_intf_status',p_new_intf_status);
     END IF;
     RAISE INVALID_NEW_INTF_STATUS;
  END IF;
  -- General Process
  -- Move all entity id ( trip / delivery ) to Error id table, if there is any error in "U" or "E"
  -- Process for DELIVERY
  -- if the input - p_new_intf_status is "IN_PROCESS"
  -- Query the delivery for the give delivery id
  -- if the current interface flag 'CR', need to update the status as "CP"
  -- if the current interface flag 'UR', need to update the status as "UP"
  -- if the current interface flag 'DR', need to update the status as "DP"
  -- if the current interface flag is 'CP,UP,DP', no update required,
  --                    For all other cases, move the delivery id to error id table.
  -- if the input - p_new_intf_status is "COMPLETE"
  -- if the current interface flag is CP, DP, or UP -> update to status AW
  -- if the current interface flag not in CP, DP, UP , add to ErrorId List
  k := 0;
  IF p_entity_type = 'DELIVERY' THEN
     --{
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery Count',p_entity_id_tab.COUNT);
     END IF;
     --
     FOR i IN 1..p_entity_id_tab.COUNT
     LOOP
        l_del_id_error_flag := 'N';
        open get_del_tms_interface_flag(p_entity_id_tab(i));
        fetch get_del_tms_interface_flag into l_del_current_status,l_del_status_code,l_ignore_for_planning;
        --
        IF get_del_tms_interface_flag%NOTFOUND then
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery Not found',p_entity_id_tab(i));
           END IF;
           -- Move delivery id to  error table - p_error_id_tab
             l_del_id_error_flag := 'Y';
        END IF;
        --
        close get_del_tms_interface_flag;
        --
        IF p_new_intf_status = 'IN_PROCESS' then
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery - Status',p_new_intf_status);
           END IF;
           --{
           -- Query the delivery for the given delivery id list and
           -- if the current interface flag is not in 'CR,UR,DR',
           -- no update required, move the delivery id to error id table.
           --
           IF l_del_current_status = 'CR' then
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_sub_module_name,'value of k1 '|| k);
              END IF;
              l_status_tab(k) := 'CP' ;
              l_id_tab(k) := p_entity_id_tab(i);
              k := k+ 1;
           ELSIF l_del_current_status = 'UR' then
              l_status_tab(k) := 'UP';
              l_id_tab(k) := p_entity_id_tab(i);
              k := k+ 1;
           ELSIF l_del_current_status = 'DR' then
              l_status_tab(k) := 'DP';
              l_id_tab(k) := p_entity_id_tab(i);
              k := k+ 1;
           elsif l_del_current_status in ('CP','DP','UP') then
              -- no change to the status since the delivery is in process
              null;
           else
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery - Error ',p_entity_id_tab(i));
              END IF;
              -- set l_del_id_error_flag to "YES" to move this del-id to error table.
              l_del_id_error_flag := 'Y';
           end if;
           --
           --}End of p_new_intf_status = 'IN_PROCESS'
           --
        ELSIF p_new_intf_status = 'COMPLETE' then
          --{
          -- if the current interface flag is CP, or UP -> update to status AW
          -- if the current interface flag is DP -> update to status 'CMP' ( if del-status is "CL")
          -- if the current interface flag is DP -> update to status 'CR' (if del-status is "OP"
          --                                   and Include for Planning and the del is not empty)
          -- if the current interface flag is DP -> update to status 'NS' ( if del-status is not "CL")
          -- if the current interface flag not in CP, DP, UP , add to ErrorId List
          if l_del_current_status in ('CP', 'UP') then
             l_status_tab(k) := 'AW';
             l_id_tab(k) := p_entity_id_tab(i);
             k := k+ 1;
          elsif l_del_current_status = 'DP' then
             if l_del_status_code = 'CL' then
                l_status_tab(k) := 'CMP';
             -- Added new validation in R12
             -- If delivery is Open and Include for planning, and the delivery is not empty
             -- set status to "CR"
             elsif (l_del_status_code = 'OP' and l_ignore_for_planning = 'N') then
                -- check if the delivery is empty or not. If it not empty, set the status to "CR"
                l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(p_entity_id_tab(i));
                IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_sub_module_name,'Error from wsh_new_delivery_actions.is_delivery_empty API for Delivery '||p_entity_id_tab(i));
                   END IF;
                   -- Setting this delivery to Error List since it is failed to process
                    l_del_id_error_flag := 'Y';
                END IF;
                --
                -- if the delivery is not empty, set the status to "CR"
                IF (l_is_delivery_empty = 'N') THEN
                  l_status_tab(k) := 'CR';
                else
                  l_status_tab(k) := 'NS';
                end if;
             else
               l_status_tab(k) := 'NS';
             end if;
             --
             l_id_tab(k) := p_entity_id_tab(i);
             k := k+ 1;
          else
             l_del_id_error_flag := 'Y';
          end if;
          --}
        END IF;
        IF l_del_id_error_flag = 'Y' THEN
           --{
              -- Move delivery id to  error table - p_error_id_tab
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery ID-Moving to error table ');
              END IF;
              l_error_id_out_tab.extend;
              l_error_id_out_tab(l_error_id_out_tab.COUNT):=p_entity_id_tab(i);
              --
           --}
        ELSE
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery ID-Success to table ',p_entity_id_tab(i));
           END IF;

           -- Move delivery id to  success table - l_entity_id_out_tab
           l_entity_id_out_tab.extend;
           l_entity_id_out_tab(l_entity_id_out_tab.COUNT):=p_entity_id_tab(i);
        END IF;
        --
     END LOOP;
     IF l_id_tab.COUNT > 0 THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery Calling WSH API to update status-Del-Count',l_id_tab.COUNT);
        END IF;
        --{
        --Call WSH API to update the new status
        WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG
              (P_DELIVERY_ID_TAB=>l_id_tab,
               P_TMS_INTERFACE_FLAG_TAB =>l_status_tab,
               X_RETURN_STATUS   =>l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
           raise UPD_DEL_INTF_FLAG_API_FALIED;
        END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Processing Delivery Calling WSH API to update status-Success-Del-Count',l_id_tab.COUNT);
        END IF;
        --}
     END IF;
     --}
  ELSIF p_entity_type = 'TRIP' THEN
     --{
     -- Process for TRIP
     -- For each Trip ID, need to query the trip stops
     -- IF p_new_intf_status is 'IN_PROCESS' and the current status is "ASR"
     --    update the status to "ASP"
     -- Otherwise no change.
     -- IF p_new_intf_status is 'COMPLETE' and the current status is "ASP"
     --    update the status to "CMP"
     -- Otherwise no change.
     -- if there is no trip stops for the give trip id, move the trip id to error id table.
     k := 0;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_sub_module_name,'Trip Count ',p_entity_id_tab.COUNT);
     END IF;
     --{
     FOR i IN 1..p_entity_id_tab.COUNT
     LOOP
        --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Trip Stop ID  ',p_entity_id_tab(i));
        END IF;
        OPEN get_trip_stops(p_entity_id_tab(i));
        FETCH get_trip_stops BULK COLLECT into l_stop_id_tab,l_stop_status_tab;
        CLOSE get_trip_stops;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Trip Stps count  ',l_stop_id_tab.COUNT);
        END IF;
        IF l_stop_id_tab.COUNT > 0 THEN
           --{
           j := l_stop_id_tab.FIRST;
           WHILE j IS NOT NULL
           LOOP
              --{
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_sub_module_name,'Processing Trip STOP ID  ',l_stop_id_tab(j) ||'-'||l_stop_status_tab(j));
              END IF;
              --
              IF p_new_intf_status = 'IN_PROCESS' THEN
                 --
                 --IF l_stop_status_tab(j) = 'ASR' then
                    l_status_tab(k) := 'ASP' ;
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_sub_module_name,'Processing Trip STOP ID -New Status  ',l_status_tab(k));
                    END IF;
                    l_id_tab(k) := l_stop_id_tab(j);
                    k := k + 1;
                 --end if ;
                 --
              ELSIF p_new_intf_status = 'COMPLETE' THEN
                 --
                 --IF l_stop_status_tab(j) = 'ASP' then
                    l_status_tab(k) := 'CMP';
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_sub_module_name,'Processing Trip STOP ID -New Status  ',l_status_tab(k));
                    END IF;
                    l_id_tab(k) := l_stop_id_tab(j);
                    k := k + 1;
                 --END IF;
                 --
              END IF;
              --
              j := l_stop_id_tab.NEXT(j);
              --}
           END LOOP;
           -- Move delivery id to  success table - l_entity_id_out_tab
           l_entity_id_out_tab.extend;
           l_entity_id_out_tab(l_entity_id_out_tab.COUNT):=p_entity_id_tab(i);
           --}
        ELSE
           --{
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_sub_module_name,'Moving to Error table for Trip id',p_entity_id_tab(i));
           END IF;
           -- Move the Trip Id into error table
           l_error_id_out_tab.extend;
           l_error_id_out_tab(l_error_id_out_tab.COUNT):=p_entity_id_tab(i);
           --}
        END IF;
        --}
     END LOOP;
     --Call WSH API to update the new status in Trip Stops
     IF l_id_tab.COUNT > 0 THEN
        --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Calling WSH API-UPDATE_TMS_INTERFACE_FLAG Total stops ids',l_id_tab.COUNT);
        END IF;
        --
        WSH_TRIP_STOPS_PVT.UPDATE_TMS_INTERFACE_FLAG
            (P_STOP_ID_TAB=>l_id_tab,
             P_TMS_INTERFACE_FLAG_TAB =>l_status_tab,
             X_RETURN_STATUS   =>l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS then
           raise UPD_STOP_INTF_FLAG_API_FALIED;
        END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Processing Trip Calling WSH API to update status-Success-Trip-Stops-Count',l_id_tab.COUNT);
        END IF;
        --}
     END IF;
     --}
  ELSE
     RAISE INVALID_ENTITY_TYPE;
  END IF;
  -- store the success deliveries/trips back to p_entity_id_tab table
  -- store the error deliveries/trips tp_error_id_tab table
  p_entity_id_tab := l_entity_id_out_tab;
  p_error_id_tab := l_error_id_out_tab;
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_sub_module_name,'End of Process - Delivery/Trip Success',p_entity_id_tab.COUNT);
     WSH_DEBUG_SV.log(l_sub_module_name,'End of Process - Delivery/Trip Error',p_error_id_tab.COUNT);
  END IF;
--
EXCEPTION
   WHEN UPD_DEL_INTF_FLAG_API_FALIED THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'UPD_DEL_INTF_FLAG_API_FALIED',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN UPD_STOP_INTF_FLAG_API_FALIED THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'UPD_STOP_INTF_FLAG_API_FALIED',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN INVALID_ENTITY_TYPE THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'INVALID_ENTITY_TYPE',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN INVALID_NEW_INTF_STATUS THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'INVALID_NEW_INTF_STATUS',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,' FND_API.G_EXC_ERROR',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR',sqlerrm);
        END IF;
        ROLLBACK TO UPDATE_ENTITY_INTF_STATUS;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS then
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'OTHERS - ERROR',sqlerrm);
        END IF;
        -- returning all entitiy id to error id table
        p_error_id_tab := p_entity_id_tab;
        x_return_status := FND_API.G_RET_STS_ERROR;
        wsh_util_core.default_handler('WSH_OTM_OUTBOUND.UPDATE_ENTITY_INTF_STATUS');
END;

-- +======================================================================+
--   Procedure : WSH_OTM_APPS_INITIALIZE
--   Description:
--      This procedure may be called to initialize the global security
--      context for a database session in an Autonomus transaction. This should
--      only be done when the session is established outside of a normal forms or
--      concurrent program connection
--
--   Inputs:
--            p_user_id  - FND User ID
--            p_resp_id  - FND Responsibility ID
--            p_resp_appl_id - FND Responsibility Application ID
--   API is called from the following
/*
1.WSH_OTM_OUTBOUND.GET_TRIP_OBJECTS
2.WSH_GLOG_OUTBOUND.GET_DELIVERY_OBJECTS
3.GET_TRIP_OBJECTS.UPDATE_ENTITY_INTF_STATUS
*/
-- +======================================================================+
PROCEDURE WSH_OTM_APPS_INITIALIZE(
           p_user_id      IN NUMBER,
           p_resp_id      IN NUMBER,
           p_resp_appl_id IN NUMBER
         ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sub_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WSH_OTM_APPS_INITIALIZE';
BEGIN
  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_sub_module_name);
      WSH_DEBUG_SV.log(l_sub_module_name,'calling FND_GLOBAL.apps_initialize');
  END IF;

  FND_GLOBAL.apps_initialize(user_id => p_user_id,
      resp_id =>p_resp_id,
      resp_appl_id => p_resp_appl_id);

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_sub_module_name,'issuing commit');
  END IF;

  COMMIT;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_sub_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_OTM_OUTBOUND.WSH_OTM_APPS_INITIALIZE',l_sub_module_name);
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'OTHERS - ERROR',sqlerrm);
       END IF;
END;

END WSH_OTM_OUTBOUND;


/
