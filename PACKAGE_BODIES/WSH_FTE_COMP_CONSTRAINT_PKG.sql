--------------------------------------------------------
--  DDL for Package Body WSH_FTE_COMP_CONSTRAINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_COMP_CONSTRAINT_PKG" as
/* $Header: WSHFTCCB.pls 120.0 2005/05/26 18:23:00 appldev noship $ */

-- Global Variables
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_FTE_COMP_CONSTRAINT_PKG';


-- Wrapper for calling validate_constraint_dlvy with approp. parameters populated for diff. actions
-- For compatibility constraints project
-- auto pack, auto pack master do not have any constraints which are implemented in I so they will not be used as of now


PROCEDURE validate_constraint_main
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_entity_type	     IN	  VARCHAR2,
    p_target_id		     IN   NUMBER,
    p_action_code            IN   VARCHAR2,
    p_del_attr_tab	     IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type ,
    p_det_attr_tab	     IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
    p_trip_attr_tab	     IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
    p_stop_attr_tab	     IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    p_in_ids		     IN   wsh_util_core.id_tab_type,
    p_pickup_stop_id         IN   NUMBER DEFAULT NULL,
    p_pickup_loc_id          IN   NUMBER DEFAULT NULL,
    p_pickup_stop_seq        IN   NUMBER DEFAULT NULL,
    p_dropoff_stop_id        IN   NUMBER DEFAULT NULL,
    p_dropoff_loc_id         IN   NUMBER DEFAULT NULL,
    p_dropoff_stop_seq       IN   NUMBER DEFAULT NULL,
    p_pickup_arr_date        IN   DATE DEFAULT NULL,
    p_pickup_dep_date        IN   DATE DEFAULT NULL,
    p_dropoff_arr_date       IN   DATE DEFAULT NULL,
    p_dropoff_dep_date       IN   DATE DEFAULT NULL,
    x_validate_result        OUT  NOCOPY VARCHAR2,
    x_failed_lines           OUT  NOCOPY failed_line_tab_type,
    x_line_groups            OUT  NOCOPY line_group_tab_type,
    x_group_info             OUT  NOCOPY cc_group_tab_type,
    x_fail_ids	     	     OUT  NOCOPY wsh_util_core.id_tab_type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
  )
  IS

    l_api_version_number      CONSTANT NUMBER := 1.0;
    l_api_name                CONSTANT VARCHAR2(30):= 'validate_constraint_main';

    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(200) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_main';
    --
    l_cc_action_code			VARCHAR2(3);
    l_cc_count				NUMBER;
    l_cc_count_dd			NUMBER;
    l_cc_count_del			NUMBER;
    l_cc_count_stop			NUMBER;
    l_cc_count_trip			NUMBER;

    l_cc_delivery_info			    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_cc_dlvy_assigned_lines		WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_cc_target_trip			    WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
    l_cc_target_trip_assign_dels	WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_cc_target_trip_dlvy_lines		WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_cc_target_trip_incl_stops		WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;

    l_cc_del_detail_info                WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_cc_target_delivery                WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type;
    l_cc_target_container               WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_rec_type;

    l_cc_trip_info                      WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_tab_type;
    l_cc_trip_assigned_dels             WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_cc_trip_dlvy_lines                WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_cc_trip_incl_stops                WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;

    l_cc_stop_info		                WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;
    l_cc_parent_trip_info               WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_tab_type;
    l_cc_parent_trip_assign_dels        WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_cc_parent_trip_dlvy_lines         WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;

    l_cc_exception_list			        WSH_UTIL_CORE.Column_Tab_Type;
    l_id_tab                            WSH_UTIL_CORE.id_tab_type;
    l_in_ids                            WSH_UTIL_CORE.id_tab_type;

    l_index                             NUMBER := 1;
    l_index2                            NUMBER := 1;
    j                                   NUMBER;
    l_initial_pickup_location_id        NUMBER;
    l_ship_from_location_id             NUMBER;
    l_max_line_group_id                 NUMBER := 0;
    l_shipping_control                  wsh_delivery_details.shipping_control%TYPE;
    l_cc_target_tripstops               WSH_FTE_CONSTRAINT_FRAMEWORK.target_tripstop_cc_rec_type;
    l_delivery_type                     VARCHAR2(30);

    CURSOR c_shipping_control(l_detail_id NUMBER )  IS
    SELECT NVL(shipping_control,'BUYER'), ship_from_location_id,
           line_direction, released_status
    FROM wsh_delivery_details
    WHERE delivery_detail_Id = l_detail_id;

    CURSOR c_delivery_shipping_control (l_delivery_id NUMBER) IS
    SELECT NVL(shipping_control, 'BUYER'),
           INITIAL_PICKUP_LOCATION_ID,
           status_code,
           shipment_direction
    FROM wsh_new_deliveries
    WHERE delivery_Id = l_delivery_id;

    cursor c_gettrip(l_deliveryid IN NUMBER) is
    select wts.TRIP_ID
    from wsh_trip_stops wts, wsh_delivery_legs wdl
    where wdl.delivery_id =l_deliveryid AND
    wdl.pick_up_stop_id = wts.stop_id;

    cursor c_getdeliverytype(l_deliveryid IN NUMBER) is
    select delivery_type
    from wsh_new_deliveries
    WHERE delivery_Id = l_deliveryid;

    cursor c_getdeliveryid(l_deldetailid IN NUMBER) is
    select wda.delivery_id
    from wsh_delivery_assignments_v wda
    where wda.delivery_detail_id=l_deldetailid;


    cursor c_get_const_count IS
    select compatibility_id
    from   wsh_fte_comp_constraints
    where  EFFECTIVE_DATE_FROM <= sysdate
    and    nvl(EFFECTIVE_DATE_TO,sysdate) >= sysdate
    and    rownum = 1;


    l_compatibility_id     NUMBER:= -999;
    l_return_status        VARCHAR2(1);

    e_handle_supplier_managed EXCEPTION;

    l_msg_details VARCHAR2(4000);
    l_status_code          VARCHAR2(2);
    l_shipment_direction   VARCHAR2(30);
    l_line_direction       VARCHAR2(30);
    l_released_status      VARCHAR2(1);

BEGIN

    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

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
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'p_action_code',p_action_code);
      wsh_debug_sv.log (l_module_name,'p_entity_type',p_entity_type);
      wsh_debug_sv.log (l_module_name,'p_pickup_dep_date',p_pickup_dep_date);
      wsh_debug_sv.log (l_module_name,'p_pickup_arr_date',p_pickup_arr_date);
      wsh_debug_sv.log (l_module_name,'p_dropoff_arr_date',p_dropoff_arr_date);
      wsh_debug_sv.log (l_module_name,'p_dropoff_dep_date',p_dropoff_dep_date);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --#DUM_LOC(S)
    IF (g_valid_const_cache.valid_const_present IS NULL OR g_valid_const_cache.cache_date <> SYSDATE) THEN

	    OPEN  c_get_const_count;
	    FETCH c_get_const_count INTO l_compatibility_id;

	    IF (c_get_const_count%ROWCOUNT = 0)THEN
	        --Constraint not found
		g_valid_const_cache.valid_const_present := FALSE;
		g_valid_const_cache.cache_date := SYSDATE;

		IF l_debug_on THEN
		        wsh_debug_sv.log(l_module_name,'Returning as no constraints are defined ',x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_',x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
	        --
		CLOSE c_get_const_count;
		RETURN;

	    END IF;

	    --Constraint Found;
	    g_valid_const_cache.valid_const_present := TRUE;
	    g_valid_const_cache.cache_date := SYSDATE;

	    IF l_debug_on THEN
		wsh_debug_sv.log(l_module_name,'Atleast one effective constraint defined ');
	    END IF;

	    CLOSE c_get_const_count;

     ELSIF (g_valid_const_cache.valid_const_present = FALSE ) THEN

	    IF l_debug_on THEN
	        wsh_debug_sv.log(l_module_name,'Returning as no constraints are defined ',x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
	        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_',x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name);
	    END IF;

	    RETURN;

     ELSE

	    IF l_debug_on THEN
	        wsh_debug_sv.log(l_module_name,'Atleast one effective constraint defined ');
	    END IF;

     END IF;
     --DUM_LOC(E)

  IF p_entity_type='D' THEN

	IF p_action_code = 'UPDATE' THEN
		l_cc_action_code:='UPD';
      	ELSIF p_action_code = 'CREATE' THEN
		l_cc_action_code:='CRD';
	ELSIF p_action_code = 'ASSIGN-TRIP' THEN
		l_cc_action_code:='ADT';
		--populate target trip with id
		l_cc_target_trip.TRIP_ID:=p_target_id;
	ELSIF p_action_code IN ('AUTO-PACK','AUTO-PACK-MASTER') THEN
		l_cc_action_code:='PKG';
        --
        -- rlanka-Pack J : Treat trip-consolidation just like autocreate-trip
        -- for entity = 'D'
	ELSIF p_action_code IN ('AUTOCREATE-TRIP', 'TRIP-CONSOLIDATION') THEN
		l_cc_action_code:='ACT';
	ELSIF p_action_code = 'SELECT-CARRIER' THEN
		l_cc_action_code:='ACS';
	END IF;


     IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'l_cc_action_code',l_cc_action_code);
     END IF;

     IF l_cc_action_code is not null THEN --{
	--initialize the delivery record and the lines assigned to it

	IF p_del_attr_tab.COUNT>0 THEN --{
	FOR i IN p_del_attr_tab.FIRST..p_del_attr_tab.LAST LOOP --{
           /* only pass the lines that are not managed by supplier
              to the constraint engine
           */
           IF (NVL(p_del_attr_tab(i).shipping_control,'BUYER') = 'SUPPLIER')
            OR (p_del_attr_tab(i).INITIAL_PICKUP_LOCATION_ID
                                 = wsh_util_core.C_NULL_SF_LOCN_ID)
            OR(( p_action_code = 'ASSIGN-TRIP' )
              AND ( p_del_attr_tab(i).shipment_direction NOT in ('O','IO'))
              AND (p_del_attr_tab(i).status_code IN ('IT','CL')))
           THEN --{
              l_id_tab(l_index) := p_del_attr_tab(i).delivery_id;
              l_index := l_index + 1;
           ELSE --}{
                --for create stop id is null, so just pass in dummy ids
                IF l_cc_action_code ='CRD' AND p_del_attr_tab(i).DELIVERY_ID IS NULL THEN
                    l_cc_delivery_info(l_index2).DELIVERY_ID     := i;
                ELSE
                    l_cc_delivery_info(l_index2).DELIVERY_ID	:= p_del_attr_tab(i).DELIVERY_ID;
                END IF;

		IF l_cc_action_code='CRD' THEN
                    l_cc_delivery_info(l_index2).exists_in_database      :='N';
                ELSE
                    l_cc_delivery_info(l_index2).exists_in_database      :='Y';
                END IF;

		l_cc_delivery_info(l_index2).NAME := p_del_attr_tab(i).NAME;
        	l_cc_delivery_info(l_index2).PLANNED_FLAG := p_del_attr_tab(i).PLANNED_FLAG;
        	l_cc_delivery_info(l_index2).STATUS_CODE := p_del_attr_tab(i).STATUS_CODE;
        	l_cc_delivery_info(l_index2).INITIAL_PICKUP_DATE := p_del_attr_tab(i).INITIAL_PICKUP_DATE;
        	l_cc_delivery_info(l_index2).INITIAL_PICKUP_LOCATION_ID	:= p_del_attr_tab(i).INITIAL_PICKUP_LOCATION_ID;
        	l_cc_delivery_info(l_index2).ULTIMATE_DROPOFF_LOCATION_ID := p_del_attr_tab(i).ULTIMATE_DROPOFF_LOCATION_ID;
        	l_cc_delivery_info(l_index2).ULTIMATE_DROPOFF_DATE := p_del_attr_tab(i).ULTIMATE_DROPOFF_DATE;
        	l_cc_delivery_info(l_index2).CUSTOMER_ID := p_del_attr_tab(i).CUSTOMER_ID;
        	l_cc_delivery_info(l_index2).INTMED_SHIP_TO_LOCATION_ID	:= p_del_attr_tab(i).INTMED_SHIP_TO_LOCATION_ID;
        	l_cc_delivery_info(l_index2).SHIP_METHOD_CODE := p_del_attr_tab(i).SHIP_METHOD_CODE;
        	l_cc_delivery_info(l_index2).CARRIER_ID	:= p_del_attr_tab(i).CARRIER_ID;
        	l_cc_delivery_info(l_index2).ORGANIZATION_ID := p_del_attr_tab(i).ORGANIZATION_ID;
        	l_cc_delivery_info(l_index2).SERVICE_LEVEL := p_del_attr_tab(i).SERVICE_LEVEL;
       		l_cc_delivery_info(l_index2).MODE_OF_TRANSPORT	:= p_del_attr_tab(i).MODE_OF_TRANSPORT;
       		l_cc_delivery_info(l_index2).party_id := p_del_attr_tab(i).party_id;
       		l_cc_delivery_info(l_index2).shipment_direction	:= p_del_attr_tab(i).shipment_direction;
       		l_cc_delivery_info(l_index2).shipping_control := p_del_attr_tab(i).shipping_control;
            --alksharm
            OPEN c_getdeliverytype(p_del_attr_tab(i).DELIVERY_ID);
                FETCH c_getdeliverytype INTO l_delivery_type;
                IF c_getdeliverytype%NOTFOUND THEN
                    l_delivery_type := NULL;
                END IF;
            CLOSE c_getdeliverytype;
            l_cc_delivery_info(l_index2).delivery_type := l_delivery_type;


		-- populate trip id for delivery (if any)
                -- bsadri why do we need a loop here where we store all
                -- the values in  l_cc_delivery_info(l_index2).TRIP_ID ?
		FOR c_tripcur in c_gettrip(p_del_attr_tab(i).DELIVERY_ID) LOOP
			l_cc_delivery_info(l_index2).TRIP_ID:=c_tripcur.TRIP_ID;
		END LOOP;
                l_index2 := l_index2 + 1;
           END IF;--}
	 END LOOP; --}
         IF l_cc_delivery_info.COUNT = 0 THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            RAISE e_handle_supplier_managed;
         END IF;
        --
        -- rlanka-Pack J : Treat trip-consolidation just like autocreate-trip
        -- for entity = 'D'
        ELSIF   p_action_code IN ('AUTOCREATE-TRIP', 'TRIP-CONSOLIDATION') AND p_in_ids.COUNT > 0 THEN--}{

           /* only pass the lines that are not managed by supplier
              to the constraint engine
           */

           j := p_in_ids.first;

	   WHILE j IS NOT NULL LOOP
              OPEN c_delivery_shipping_control(p_in_ids(j));
              FETCH c_delivery_shipping_control into l_shipping_control,
                    l_initial_pickup_location_id, l_status_code,
                    l_shipment_direction;

              CLOSE c_delivery_shipping_control;

	      IF (l_shipping_control = 'SUPPLIER' )
		 OR
                 (l_initial_pickup_location_id = wsh_util_core.C_NULL_SF_LOCN_ID )
                 OR (( l_shipment_direction  NOT in ('O','IO'))
                 AND (l_status_code IN ('IT','CL')))

              THEN
                 l_id_tab(l_index) := p_in_ids(j);
                 l_index := l_index + 1;
              ELSE
                 l_in_ids(l_index2) := p_in_ids(j);
                 l_index2 := l_index2 + 1;
              END IF;
              j := p_in_ids.NEXT(j);
           END LOOP;
           IF l_in_ids.COUNT = 0 THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
              RAISE e_handle_supplier_managed;
           END IF;
        ELSE --}{
           l_in_ids := p_in_ids;
        END IF;--}

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'before calling validate_constraint_dlvy',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

        l_cc_target_tripstops.pickup_stop_id := p_pickup_stop_id;
        l_cc_target_tripstops.pickup_stop_seq := p_pickup_stop_seq;
        l_cc_target_tripstops.dropoff_stop_id := p_dropoff_stop_id;
        l_cc_target_tripstops.dropoff_stop_seq := p_dropoff_stop_seq;
        l_cc_target_tripstops.pickup_location_id :=  p_pickup_loc_id;
        l_cc_target_tripstops.dropoff_location_id := p_dropoff_loc_id;
        l_cc_target_tripstops.PICKUP_STOP_PA_DATE := p_pickup_arr_date;
        l_cc_target_tripstops.PICKUP_STOP_PD_DATE := p_pickup_dep_date;
        l_cc_target_tripstops.DROPOFF_STOP_PA_DATE := p_dropoff_arr_date;
        l_cc_target_tripstops.DROPOFF_STOP_PD_DATE := p_dropoff_dep_date;

	WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy(
             p_init_msg_list            =>	p_init_msg_list,
             p_action_code              =>	l_cc_action_code,
             p_exception_list           =>	l_cc_exception_list,
             p_delivery_info            =>	l_cc_delivery_info,
	         p_in_ids			        =>	l_in_ids,
             p_dlvy_assigned_lines      =>	l_cc_dlvy_assigned_lines,
             p_target_trip              =>	l_cc_target_trip,
             p_target_tripstops         =>  l_cc_target_tripstops,
             p_target_trip_assign_dels  =>	l_cc_target_trip_assign_dels,
             p_target_trip_dlvy_lines   =>	l_cc_target_trip_dlvy_lines,
             p_target_trip_incl_stops   =>	l_cc_target_trip_incl_stops,
             x_validate_result          =>	x_validate_result,
             x_failed_lines             =>	x_failed_lines,
             x_line_groups              =>	x_line_groups,
             x_group_info               =>	x_group_info,
             x_msg_count                =>	x_msg_count,
             x_msg_data                 =>	x_msg_data,
             x_return_status            =>	x_return_status);


      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'after calling validate_constraint_dlvy',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
   END IF;-- l_cc_action_code is not null}
  --check for delivery is over
  ELSIF p_entity_type='L' THEN
   	--following check for update deldetail is not needed as of now
	IF p_action_code='UPDATE' THEN
		l_cc_action_code:='UPD';
	ELSIF p_action_code='AUTOCREATE-DEL' THEN
		l_cc_action_code:='ACD';
   	ELSIF p_action_code IN ('AUTO-PACK','AUTO-PACK-MASTER') THEN
		l_cc_action_code:='PKG';
	ELSIF p_action_code = 'ASSIGN' THEN
		l_cc_action_code:='ADD';
		--populate target container/delivery with id
		l_cc_target_delivery.DELIVERY_ID :=p_target_id;
	ELSIF p_action_code = 'PACK' THEN
		l_cc_action_code:='PKG';
		--populate target container/delivery with id
		l_cc_target_container.DELIVERY_DETAIL_ID:=p_target_id;
	ELSIF p_action_code IN ('AUTO-PACK','AUTO-PACK-MASTER') THEN
		l_cc_action_code:='PKG';
	ELSIF p_action_code = 'AUTOCREATE-TRIP' THEN
		l_cc_action_code:='ACT';
	ELSIF p_action_code = 'AUTOCREATE-DEL' THEN
		l_cc_action_code:='ACD';
	END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_cc_action_code',l_cc_action_code);
    END IF;

     IF l_cc_action_code is not null THEN
	--initialize the delivery detail record

	IF p_det_attr_tab.COUNT>0 THEN --{
	FOR i IN p_det_attr_tab.FIRST..p_det_attr_tab.LAST LOOP --{
            IF ((NVL(p_det_attr_tab(i).shipping_control,'BUYER') = 'SUPPLIER')
              OR (p_det_attr_tab(i).ship_from_location_id =
                                          wsh_util_core.C_NULL_SF_LOCN_ID)
              OR ((p_det_attr_tab(i).line_direction NOT IN ('O','IO'))
                  AND (p_det_attr_tab(i).released_status IN ('C','L','P'))
                  AND (p_action_code = 'AUTOCREATE-DEL')))
            THEN --{
               l_id_tab(l_index) := p_det_attr_tab(i).delivery_detail_id;
               l_index := l_index + 1;
            ELSE --}{
        	l_cc_del_detail_info(l_index2).DELIVERY_DETAIL_ID       := p_det_attr_tab(i).DELIVERY_DETAIL_ID;
      		l_cc_del_detail_info(l_index2).exists_in_database       := 'Y';
      		l_cc_del_detail_info(l_index2).CUSTOMER_ID              := p_det_attr_tab(i).CUSTOMER_ID;
      		l_cc_del_detail_info(l_index2).INVENTORY_ITEM_ID        := p_det_attr_tab(i).INVENTORY_ITEM_ID;
      		l_cc_del_detail_info(l_index2).SHIP_FROM_LOCATION_ID    := p_det_attr_tab(i).SHIP_FROM_LOCATION_ID;
      		l_cc_del_detail_info(l_index2).ORGANIZATION_ID          := p_det_attr_tab(i).ORGANIZATION_ID;
      		l_cc_del_detail_info(l_index2).SHIP_TO_LOCATION_ID      := p_det_attr_tab(i).SHIP_TO_LOCATION_ID;
      		l_cc_del_detail_info(l_index2).INTMED_SHIP_TO_LOCATION_ID := p_det_attr_tab(i).INTMED_SHIP_TO_LOCATION_ID;
      		l_cc_del_detail_info(l_index2).RELEASED_STATUS          := p_det_attr_tab(i).RELEASED_STATUS;
      		l_cc_del_detail_info(l_index2).CONTAINER_FLAG           := p_det_attr_tab(i).CONTAINER_FLAG;
      		l_cc_del_detail_info(l_index2).DATE_REQUESTED           := p_det_attr_tab(i).DATE_REQUESTED;
      		l_cc_del_detail_info(l_index2).DATE_SCHEDULED           := p_det_attr_tab(i).DATE_SCHEDULED;
      		l_cc_del_detail_info(l_index2).SHIP_METHOD_CODE         := p_det_attr_tab(i).SHIP_METHOD_CODE;
      		l_cc_del_detail_info(l_index2).CARRIER_ID               := p_det_attr_tab(i).CARRIER_ID;
      		l_cc_del_detail_info(l_index2).shipping_control         := p_det_attr_tab(i).shipping_control;
      		l_cc_del_detail_info(l_index2).party_id                 := p_det_attr_tab(i).party_id;
      		l_cc_del_detail_info(l_index2).line_direction           := p_det_attr_tab(i).line_direction;

                --bsadri why do we need a loop here where we store all
                -- the values in  l_cc_del_detail_info(l_index2).DELIVERY_ID ?
		--populate delivery id for detail (if any)

		FOR cur_getdeliveryid in c_getdeliveryid(p_det_attr_tab(i).DELIVERY_DETAIL_ID) LOOP
			l_cc_del_detail_info(l_index2).DELIVERY_ID  := cur_getdeliveryid.DELIVERY_ID;
		END LOOP;
                l_index2 := l_index2 + 1;

	   END IF; --}

	  END LOOP; --}
          IF l_cc_del_detail_info.COUNT = 0 THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            RAISE e_handle_supplier_managed;
          END IF;
        ELSIF   p_action_code = 'AUTOCREATE-DEL' AND p_in_ids.COUNT > 0 THEN--}{

           /* only pass the lines that are not managed by supplier
              to the constraint engine
           */

           j := p_in_ids.first;
           WHILE j IS NOT NULL LOOP
              OPEN  c_shipping_control(p_in_ids(j));
              FETCH c_shipping_control into l_shipping_control,
		    l_ship_from_location_id,
                    l_line_direction,
                    l_released_status;
              CLOSE c_shipping_control;
              IF ((l_shipping_control = 'SUPPLIER')
                  OR (l_ship_from_location_id=wsh_util_core.C_NULL_SF_LOCN_ID)
                  OR ((l_line_direction NOT IN ('O','IO'))
                    AND (l_released_status IN ('C','L','P'))))
              THEN
                 l_id_tab(l_index) := p_in_ids(j);
                 l_index := l_index + 1;
              ELSE
                 l_in_ids(l_index2) := p_in_ids(j);
                 l_index2 := l_index2 + 1;
              END IF;
              j := p_in_ids.NEXT(j);
           END LOOP;

           IF l_in_ids.COUNT = 0 THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
              RAISE e_handle_supplier_managed;
           END IF;
        ELSE --}{
           l_in_ids := p_in_ids;
        END IF; --}

        IF l_debug_on THEN
	      wsh_debug_sv.logmsg(l_module_name,'before calling validate_constraint_dlvb',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvb(
             p_init_msg_list            =>	p_init_msg_list,
             p_action_code              =>	l_cc_action_code,
             p_exception_list           =>	l_cc_exception_list,
             p_del_detail_info          =>	l_cc_del_detail_info,
	         p_in_ids			        =>	l_in_ids,
             p_target_delivery          =>	l_cc_target_delivery,
             p_target_container         =>	l_cc_target_container,
             p_dlvy_assigned_lines      =>	l_cc_dlvy_assigned_lines,
             x_validate_result          =>	x_validate_result,
             x_failed_lines             =>	x_failed_lines,
             x_line_groups              =>	x_line_groups,
             x_group_info               =>	x_group_info,
             x_msg_count                =>	x_msg_count,
             x_msg_data                 =>	x_msg_data,
             x_return_status            =>	x_return_status);

	 IF l_debug_on THEN
		 wsh_debug_sv.logmsg(l_module_name,'after calling validate_constraint_dlvb',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;

       END IF;-- l_cc_action_code is not null

  --check for line is over
  ELSIF p_entity_type='T' THEN

	IF p_action_code ='UPDATE' THEN
	   l_cc_action_code:='UPT';
	END IF;

        IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name,'l_cc_action_code',l_cc_action_code);
	END IF;

     IF l_cc_action_code is not null THEN
	--initialize the delivery record and the lines assigned to it
	l_cc_count_stop:=1;
	l_cc_count_del:=1;
	l_cc_count_dd:=1;

	IF p_trip_attr_tab.COUNT>0 THEN

	FOR i IN p_trip_attr_tab.FIRST..p_trip_attr_tab.LAST LOOP
		l_cc_trip_info(i).TRIP_ID			:= p_trip_attr_tab(i).TRIP_ID;
     		l_cc_trip_info(i).exists_in_database		:='Y';
     		l_cc_trip_info(i).NAME				:= p_trip_attr_tab(i).NAME;
     		l_cc_trip_info(i).PLANNED_FLAG			:= p_trip_attr_tab(i).PLANNED_FLAG;
     		l_cc_trip_info(i).STATUS_CODE			:= p_trip_attr_tab(i).STATUS_CODE;
     		l_cc_trip_info(i).VEHICLE_ITEM_ID		:= p_trip_attr_tab(i).VEHICLE_ITEM_ID;
     		l_cc_trip_info(i).VEHICLE_NUMBER		:= p_trip_attr_tab(i).VEHICLE_NUMBER;
     		l_cc_trip_info(i).CARRIER_ID			:= p_trip_attr_tab(i).CARRIER_ID;
     		l_cc_trip_info(i).SHIP_METHOD_CODE		:= p_trip_attr_tab(i).SHIP_METHOD_CODE;
     		l_cc_trip_info(i).VEHICLE_ORGANIZATION_ID	:= p_trip_attr_tab(i).VEHICLE_ORGANIZATION_ID;
     		l_cc_trip_info(i).VEHICLE_NUM_PREFIX		:= p_trip_attr_tab(i).VEHICLE_NUM_PREFIX;
     		l_cc_trip_info(i).SERVICE_LEVEL			:= p_trip_attr_tab(i).SERVICE_LEVEL;
     		l_cc_trip_info(i).MODE_OF_TRANSPORT		:= p_trip_attr_tab(i).MODE_OF_TRANSPORT;
	END LOOP;
        END IF;

	IF l_debug_on THEN
	   wsh_debug_sv.logmsg(l_module_name,'before calling validate_constraint_trip',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_trip(
             p_init_msg_list            =>	p_init_msg_list,
             p_action_code              =>	l_cc_action_code,
             p_exception_list           =>	l_cc_exception_list,
             p_trip_info                =>      l_cc_trip_info,
             p_trip_assigned_dels       =>      l_cc_trip_assigned_dels,
             p_trip_dlvy_lines          =>	l_cc_trip_dlvy_lines,
             p_trip_incl_stops          =>      l_cc_trip_incl_stops,
             x_validate_result          =>	x_validate_result,
             x_fail_trips	        =>	x_fail_ids,
             x_msg_count                =>	x_msg_count,
             x_msg_data                 =>	x_msg_data,
             x_return_status            =>	x_return_status);

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'after calling validate_constraint_trip',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
     END IF;-- l_cc_action_code is not null

  --check for trip is over
  ELSIF p_entity_type='S' THEN

	IF p_action_code ='UPDATE' THEN
		l_cc_action_code:='UPS';
	ELSIF p_action_code ='DELETE' THEN
		l_cc_action_code:='DTS';
	ELSIF p_action_code ='CREATE' THEN
		l_cc_action_code:='CTS';
	END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_cc_action_code',l_cc_action_code);
    END IF;

     IF l_cc_action_code is not null THEN
	--initialize the delivery record and the lines assigned to it
	l_cc_count_trip:=1;
	l_cc_count_del:=1;
	l_cc_count_dd:=1;

	IF p_stop_attr_tab.COUNT>0 THEN
            FOR i IN p_stop_attr_tab.FIRST..p_stop_attr_tab.LAST LOOP
                --for create stop id is null, so just pass in dummy ids

		IF l_cc_action_code ='CTS' AND p_stop_attr_tab(i).STOP_ID IS NULL THEN
                    l_cc_stop_info(i).STOP_ID  := i;
                ELSE
                    l_cc_stop_info(i).STOP_ID  := p_stop_attr_tab(i).STOP_ID;
                END IF;

		--if create, set flag to N
		IF l_cc_action_code ='CTS' THEN
	        	l_cc_stop_info(i).exists_in_database	:='N';
		ELSE
	 		l_cc_stop_info(i).exists_in_database    :='Y';
		END IF;

		l_cc_stop_info(i).TRIP_ID                       := p_stop_attr_tab(i).TRIP_ID;
     		l_cc_stop_info(i).STOP_LOCATION_ID              := p_stop_attr_tab(i).STOP_LOCATION_ID;
     		l_cc_stop_info(i).STATUS_CODE                   := p_stop_attr_tab(i).STATUS_CODE;
     		l_cc_stop_info(i).STOP_SEQUENCE_NUMBER          := p_stop_attr_tab(i).STOP_SEQUENCE_NUMBER;
     		l_cc_stop_info(i).PLANNED_ARRIVAL_DATE          := p_stop_attr_tab(i).PLANNED_ARRIVAL_DATE;
     		l_cc_stop_info(i).PLANNED_DEPARTURE_DATE        := p_stop_attr_tab(i).PLANNED_DEPARTURE_DATE;
     		l_cc_stop_info(i).ACTUAL_ARRIVAL_DATE           := p_stop_attr_tab(i).ACTUAL_ARRIVAL_DATE;
     		l_cc_stop_info(i).ACTUAL_DEPARTURE_DATE		:= p_stop_attr_tab(i).ACTUAL_DEPARTURE_DATE;
		-- DUM_LOC(Q)
		-- The  Physical Location Id/Stop Id will be passed in using the Input record.
		l_cc_stop_info(i).PHYSICAL_LOCATION_ID          := p_stop_attr_tab(i).PHYSICAL_LOCATION_ID;
		l_cc_stop_info(i).PHYSICAL_STOP_ID		:= p_stop_attr_tab(i).PHYSICAL_STOP_ID;
		-- DUM_LOC(E)
	    END LOOP;
        ELSIF p_in_ids.COUNT>0 THEN
           IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'p_in_ids.COUNT passed for stops',p_in_ids.COUNT);
           END IF;
           FOR i IN p_in_ids.FIRST..p_in_ids.LAST LOOP
		l_cc_stop_info(i).STOP_ID      	:= p_in_ids(i);
           END LOOP;
        END IF;
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'before calling validate_constraint_stop',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

	WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_stop(
             p_init_msg_list            =>	p_init_msg_list,
             p_action_code              =>	l_cc_action_code,
             p_exception_list           =>	l_cc_exception_list,
             p_stop_info                =>	l_cc_stop_info,
             p_parent_trip_info         =>	l_cc_parent_trip_info,
             x_validate_result          =>	x_validate_result,
             x_fail_stops               =>	x_fail_ids,
             x_msg_count                =>	x_msg_count,
             x_msg_data                 =>	x_msg_data,
             x_return_status            =>	x_return_status);

      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name,'after calling validate_constraint_stop',WSH_DEBUG_SV.C_PROC_LEVEL);

      END IF;
     END IF;-- l_cc_action_code is not null
  --check for stop is over
  END IF;-- entity_type

  IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'l_id_tab.count',l_id_tab.count);
  END IF;
  IF l_id_tab.COUNT > 0 THEN
     RAISE e_handle_supplier_managed;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_',x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
   --
   --

   --Compatiblity Changes

  EXCEPTION
    WHEN e_handle_supplier_managed THEN
      --
      IF (p_entity_type IN ('L','D')) AND (l_id_tab.COUNT > 0 )
       AND ( p_action_code NOT IN ('ASSIGN','ASSIGN-TRIP'))
      THEN --{
         /* If some of deliveres or delivery details where managed by
            supplier, and if some of the lines that were not managed by
            supplier have failed the constraint validation, then return
            the supplier managed lines as success group
         */

         --get the highest group_line_id and index
         l_index := x_line_groups.LAST;
         IF l_index IS NOT NULL THEN
            l_max_line_group_id := NVL(x_line_groups(l_index).line_group_id,0)
                                                                           + 1;
         ELSE
            l_max_line_group_id := 1;
            l_index := 0;
         END IF;

         --enter the supplier managed lines as success records
         j := l_id_tab.first;
         WHILE j IS NOT NULL LOOP
            x_line_groups(l_index + j).line_group_id := l_max_line_group_id;
            x_line_groups(l_index + j).entity_line_id := l_id_tab(j);
            j := l_id_tab.NEXT(j);
         END LOOP;

      END IF; --}
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      IF c_get_const_count%ISOPEN THEN
         CLOSE c_get_const_count;
      END IF;
      wsh_util_core.default_handler('validate_constraint_main');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
  END validate_constraint_main;

--   To be called from UI directly for
--   DCE, DST
--   For DST (Search trip for a delivery leg) pass the target trip id
--   For DCE, pass dleg details

PROCEDURE validate_constraint_dleg(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2,
             p_delivery_leg_id          IN      NUMBER DEFAULT NULL,
             p_delivery_id              IN      NUMBER,
             p_sequence_num             IN      NUMBER DEFAULT NULL,
             p_location1_id             IN      NUMBER DEFAULT NULL,
             p_location2_id             IN      NUMBER DEFAULT NULL,
             p_stop1_id                 IN      NUMBER DEFAULT NULL,
             p_stop2_id                 IN      NUMBER DEFAULT NULL,
             p_date_1                   IN      DATE DEFAULT NULL,
             p_date_2                   IN      DATE DEFAULT NULL,
             p_target_trip_id           IN      NUMBER DEFAULT NULL, -- For DST
             p_carrier_id               IN      NUMBER DEFAULT NULL, -- Following 3 for DCE
             p_mode_code                IN      VARCHAR2 DEFAULT NULL,
             p_service_level            IN      VARCHAR2 DEFAULT NULL,
             x_validate_result          OUT NOCOPY    VARCHAR2, --  Constraint Validation result : S / F
             x_msg_count                OUT NOCOPY    NUMBER,      -- Standard FND functionality
             x_msg_data                 OUT NOCOPY    VARCHAR2,  -- Will return message text only if number of messages = 1
             x_return_status            OUT NOCOPY    VARCHAR2)
IS

    -- TODO Replace with global cursor
    CURSOR c_get_trip_detail(c_trip_id IN NUMBER) IS
    SELECT TRIP_ID
     , 'Y'
     , NAME
     , PLANNED_FLAG
     , STATUS_CODE
     , VEHICLE_ITEM_ID
     , VEHICLE_NUMBER
     , CARRIER_ID
     , SHIP_METHOD_CODE
     , VEHICLE_ORGANIZATION_ID
     , VEHICLE_NUM_PREFIX
     , SERVICE_LEVEL
     , MODE_OF_TRANSPORT
    FROM wsh_trips
    WHERE trip_id = c_trip_id;

    CURSOR c_get_parent_delivery_leg(c_del_id NUMBER, c_del_leg_id NUMBER) IS
    SELECT PARENT_DELIVERY_LEG_ID
    FROM wsh_delivery_legs
    WHERE DELIVERY_LEG_ID = c_del_leg_id
    AND DELIVERY_ID = c_del_id;

    l_return_status              VARCHAR2(1);
    l_validate_result            VARCHAR2(1) := 'S';
    l_succ_trips                 WSH_UTIL_CORE.id_tab_type;
    l_dummy_succ_lanes           WSH_UTIL_CORE.id_tab_type;
    l_dummy_exception_list       WSH_UTIL_CORE.Column_Tab_Type;
    l_delivery_leg_rec           WSH_FTE_CONSTRAINT_FRAMEWORK.dleg_ccinfo_rec_type;
    l_target_trip                WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
    l_target_trip_tab            WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_tab_type;
    l_dummy_target_lane          WSH_FTE_CONSTRAINT_FRAMEWORK.lane_ccinfo_tab_type;
    l_parent_delivery_leg_id     NUMBER;

    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_dlegui';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      OPEN c_get_parent_delivery_leg(p_delivery_id, p_delivery_leg_id);
        FETCH c_get_parent_delivery_leg INTO l_parent_delivery_leg_id;
        IF c_get_parent_delivery_leg %NOTFOUND THEN
            l_parent_delivery_leg_id := NULL;
        END IF;
      CLOSE c_get_parent_delivery_leg;

      IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_action_code : '||p_action_code);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_leg_id : '||p_delivery_leg_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_id : '||p_delivery_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_sequence_num : '||p_sequence_num);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_location1_id : '||p_location1_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_location2_id : '||p_location2_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_stop1_id : '||p_stop1_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_stop2_id : '||p_stop2_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_date_1 : '||p_date_1);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_date_2 : '||p_date_2);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_trip_id : '||p_target_trip_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_carrier_id : '||p_carrier_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_mode_code : '||p_mode_code);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_service_level : '||p_service_level);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_parent_delivery_leg_id : '||l_parent_delivery_leg_id);
      END IF;

    l_delivery_leg_rec.DELIVERY_LEG_ID := p_delivery_leg_id;
    l_delivery_leg_rec.DELIVERY_ID := p_delivery_id;
    l_delivery_leg_rec.SEQUENCE_NUMBER := p_sequence_num;
    l_delivery_leg_rec.CARRIER_ID := p_carrier_id;
    l_delivery_leg_rec.SERVICE_LEVEL := p_service_level;
    l_delivery_leg_rec.MODE_OF_TRANSPORT := p_mode_code;
    l_delivery_leg_rec.PICK_UP_STOP_ID := p_stop1_id;
    l_delivery_leg_rec.DROP_OFF_STOP_ID := p_stop2_id;
    l_delivery_leg_rec.PICKUPSTOP_LOCATION_ID := p_location1_id ;
    l_delivery_leg_rec.DROPOFFSTOP_LOCATION_ID := p_location2_id;
    -- AG 10+
    l_delivery_leg_rec.pickup_stop_pa_date := p_date_1;
    l_delivery_leg_rec.dropoff_stop_pa_date := p_date_2;
    -- AG
    -- How is delivery_type being handled -- no delivery type present in dleg_ccinfo_rec_type

    l_delivery_leg_rec.PARENT_DELIVERY_LEG_ID := l_parent_delivery_leg_id;

    IF l_delivery_leg_rec.DELIVERY_LEG_ID IS NOT NULL THEN
       l_delivery_leg_rec.exists_in_database := 'Y';
    ELSE
       l_delivery_leg_rec.exists_in_database := 'N';
    END IF;

    IF p_action_code = WSH_FTE_CONSTRAINT_FRAMEWORK.G_DLEG_TRIP_SEARCH THEN

      OPEN c_get_trip_detail(p_target_trip_id);
      FETCH c_get_trip_detail INTO l_target_trip;
      CLOSE c_get_trip_detail;

      l_target_trip_tab(1) := l_target_trip;

    END IF;

    WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dleg(
             p_init_msg_list            =>    p_init_msg_list,
             p_action_code              =>    p_action_code,
             p_exception_list           =>    l_dummy_exception_list,
             p_delivery_leg_rec         =>    l_delivery_leg_rec,
             p_target_trip              =>    l_target_trip_tab, -- Either of the next two
             p_target_lane              =>    l_dummy_target_lane,
             x_succ_trips               =>    l_succ_trips,
             x_succ_lanes               =>    l_dummy_succ_lanes,
             x_validate_result          =>    x_validate_result, --  Constraint Validation result : S / F
             x_msg_count                =>    x_msg_count,      -- Standard FND functionality
             x_msg_data                 =>    x_msg_data,  -- Will return message text only if number of messages = 1
             x_return_status            =>    l_return_status);

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN

            raise FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         x_return_status := l_return_status;
      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END validate_constraint_dleg;

END WSH_FTE_COMP_CONSTRAINT_PKG;


/
