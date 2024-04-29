--------------------------------------------------------
--  DDL for Package Body FTE_ACS_TRIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ACS_TRIP_PKG" as
/* $Header: FTEACSTB.pls 120.4 2005/12/12 02:59:41 alksharm noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_ACS_TRIP_PKG';
--

--
-- ----------------------------------------------------------------------
-- Procedure:   CARRIER_SEL_CREATE_TRIP
--
-- Parameters:  p_delivery_id               Delivery ID
--              p_carrier_sel_result_rec    WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE
--              x_trip_id                   Trip Id
--              x_trip_name                 Trip Name
--              x_return_message            Return Message
--              x_return_status             Return Status
--
-- COMMENT   : This procedure is called from Process Carrier Selection API
--             in order to create trip for deliveries not assigned to trips
--
--             It performs the following steps:
--             01. Create trip.
--             02. Create Pick Up and Drop Off Stops for trip created above
--             03. Assign delivery to trip
--
--  ----------------------------------------------------------------------

PROCEDURE CARRIER_SEL_CREATE_TRIP( p_delivery_id               IN NUMBER,
                                   --p_initial_pickup_loc_id     IN NUMBER,
                                   --p_ultimate_dropoff_loc_id   IN NUMBER,
                                   --p_initial_pickup_date       IN DATE,
                                   --p_ultimate_dropoff_date     IN DATE,
                                   p_carrier_sel_result_rec    IN WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE,
                                   x_trip_id                   OUT NOCOPY NUMBER,
                                   x_trip_name                 OUT NOCOPY VARCHAR2,
                                   x_return_message            OUT NOCOPY VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2
)IS
l_trip_id               NUMBER;
l_trip_name             VARCHAR2(30);
l_return_status         VARCHAR2(1);
l_msg_data              VARCHAR2(2000);
l_msg_count             NUMBER;
p_api_version_number    NUMBER;
p_action_code           VARCHAR2(10);
l_trip_in_rec           WSH_TRIPS_GRP.tripInRecType;
l_stop_in_rec           WSH_TRIP_STOPS_GRP.stopInRecType;
l_trip_info_tab	        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_trip_out_rec_tab      WSH_TRIPS_GRP.Trip_Out_Tab_Type;
l_pickup_stop_out_tab	WSH_TRIP_STOPS_GRP.stop_out_tab_type;
l_pickup_rec_attr_tab	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_dropoff_stop_out_tab	WSH_TRIP_STOPS_GRP.stop_out_tab_type;
l_dropoff_rec_attr_tab	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_pickup_stop_info      WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
l_dropoff_stop_info 	WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
x_delivery_out_rec      WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
l_defaults_rec          WSH_DELIVERIES_GRP.default_parameters_rectype;
l_stop_wt_vol_out_tab	WSH_TRIP_STOPS_GRP.Stop_Wt_Vol_tab_type;
l_action_prms           WSH_DELIVERIES_GRP.action_parameters_rectype;
l_rec_attr_tab          WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
K_CREATE                CONSTANT VARCHAR2(30)   := 'CREATE';
l_commit                VARCHAR2(100) := FND_API.G_FALSE;
l_init_msg_list         VARCHAR2(100) := FND_API.G_FALSE;
l_api_version_number	NUMBER := 1.0;
--l_delivery_id_tab       WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
l_index                 NUMBER;
l_pickup_stop_seq       NUMBER;
l_dropoff_stop_seq      NUMBER;
l_initial_pickup_loc_id NUMBER;
l_ultimate_dropoff_loc_id   NUMBER;
l_initial_pickup_date   DATE;
l_ultimate_dropoff_date DATE;
l_dlvy_weight_uom		VARCHAR2(10);
l_dlvy_volume_uom		VARCHAR2(10);
l_ignore_for_planning   wsh_trips.ignore_for_planning%TYPE;
l_caller                VARCHAR2(30) := 'FTE_ROUTING_GUIDE';
l_debug_on              BOOLEAN;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CARRIER_SEL_CREATE_TRIP';

CURSOR c_dlvy_attr_csr( p_delivery_id IN NUMBER ) IS
    SELECT
        DELIVERY_ID
      , ORGANIZATION_ID
      , STATUS_CODE
      , PLANNED_FLAG
      , NAME
      , INITIAL_PICKUP_DATE
      , INITIAL_PICKUP_LOCATION_ID
      , ULTIMATE_DROPOFF_LOCATION_ID
      , ULTIMATE_DROPOFF_DATE
      , CUSTOMER_ID
      , INTMED_SHIP_TO_LOCATION_ID
      , SHIP_METHOD_CODE
      , DELIVERY_TYPE
      , CARRIER_ID
      , SERVICE_LEVEL
      , MODE_OF_TRANSPORT
      , shipment_direction
      , party_id
      , shipping_control
      , weight_uom_code
      , volume_uom_code
      , nvl(ignore_for_planning,'N') ignore_for_planning
    FROM WSH_NEW_DELIVERIES
    WHERE delivery_id = p_delivery_id;

/*CURSOR c_dlvy_weight_volume_csr (p_delivery_id IN NUMBER) IS
	SELECT weight_uom_code
        ,volume_uom_code
	FROM wsh_new_deliveries
	WHERE  delivery_id = p_delivery_id;*/
BEGIN
--{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

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

    l_initial_pickup_loc_id     :=  p_carrier_sel_result_rec.initial_pickup_location_id;
    l_ultimate_dropoff_loc_id   :=  p_carrier_sel_result_rec.ultimate_dropoff_location_id;
    l_initial_pickup_date       :=  p_carrier_sel_result_rec.pickup_date;
    l_ultimate_dropoff_date     :=  p_carrier_sel_result_rec.dropoff_date;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_id :'||p_delivery_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_initial_pickup_loc_id :'||l_initial_pickup_loc_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_ultimate_dropoff_loc_id :'||l_ultimate_dropoff_loc_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_initial_pickup_date :'||l_initial_pickup_date);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_ultimate_dropoff_date :'||l_ultimate_dropoff_date);
    END IF;

    l_index := 1;

    OPEN  c_dlvy_attr_csr(p_delivery_id);

        FETCH c_dlvy_attr_csr
            INTO  l_rec_attr_tab(l_index).delivery_id,
            l_rec_attr_tab(l_index).organization_id,
            l_rec_attr_tab(l_index).status_code,
            l_rec_attr_tab(l_index).planned_flag,
            l_rec_attr_tab(l_index).NAME,
            l_rec_attr_tab(l_index).INITIAL_PICKUP_DATE,
            l_rec_attr_tab(l_index).INITIAL_PICKUP_LOCATION_ID,
            l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_LOCATION_ID,
            l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_DATE,
            l_rec_attr_tab(l_index).CUSTOMER_ID,
            l_rec_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_ID,
            l_rec_attr_tab(l_index).SHIP_METHOD_CODE,
            l_rec_attr_tab(l_index).DELIVERY_TYPE,
            l_rec_attr_tab(l_index).CARRIER_ID,
            l_rec_attr_tab(l_index).SERVICE_LEVEL,
            l_rec_attr_tab(l_index).MODE_OF_TRANSPORT,
            l_rec_attr_tab(l_index).shipment_direction,
            l_rec_attr_tab(l_index).party_id,
            l_rec_attr_tab(l_index).shipping_control,
            l_dlvy_weight_uom,
            l_dlvy_volume_uom,
            l_ignore_for_planning;

    CLOSE c_dlvy_attr_csr;

    p_action_code := K_CREATE;
    l_trip_in_rec.caller := l_caller;
    l_pickup_stop_seq      := 10;
    l_dropoff_stop_seq     := 20;
    l_trip_in_rec.phase := NULL;
    l_trip_in_rec.action_code := p_action_code;

    -- 01. Create Trip

    l_trip_info_tab(1).NAME                    := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).PLANNED_FLAG            := 'N';
    l_trip_info_tab(1).ARRIVE_AFTER_TRIP_ID    := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).STATUS_CODE             := 'OP';
    l_trip_info_tab(1).VEHICLE_ITEM_ID         := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).VEHICLE_ORGANIZATION_ID := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).VEHICLE_NUMBER          := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).VEHICLE_NUM_PREFIX      := FND_API.G_MISS_CHAR;

    IF (p_carrier_sel_result_rec.carrier_id is null) THEN
      l_trip_info_tab(1).CARRIER_ID             := FND_API.G_MISS_NUM;
    ELSE
      l_trip_info_tab(1).CARRIER_ID             := p_carrier_sel_result_rec.carrier_id;
    END IF;

    IF (p_carrier_sel_result_rec.ship_method_code is null) THEN
      l_trip_info_tab(1).SHIP_METHOD_CODE       := FND_API.G_MISS_CHAR;
    ELSE
      l_trip_info_tab(1).SHIP_METHOD_CODE       := p_carrier_sel_result_rec.ship_method_code;
    END IF;


    IF (p_carrier_sel_result_rec.consignee_carrier_ac_no is null) THEN
        l_trip_info_tab(1).CONSIGNEE_CARRIER_AC_NO := FND_API.G_MISS_CHAR;
    ELSE
        l_trip_info_tab(1).CONSIGNEE_CARRIER_AC_NO := p_carrier_sel_result_rec.consignee_carrier_ac_no;
    END IF;

-- AG
-- cs_result_tab.rank stores rank_sequence
-- It is not same as trip's rank_id which has already been updated by FTE
-- rank_list_action API
    l_trip_info_tab(1).RANK_ID := FND_API.G_MISS_NUM;

    IF (p_carrier_sel_result_rec.append_flag is null) THEN
      l_trip_info_tab(1).APPEND_FLAG        := FND_API.G_MISS_CHAR;
    ELSE
      l_trip_info_tab(1).APPEND_FLAG        := p_carrier_sel_result_rec.append_flag;
    END IF;

-- AG Use rule_id from p_cs_result_tab and not routing_rule_id

    IF (p_carrier_sel_result_rec.rule_id  is null) THEN
      l_trip_info_tab(1).ROUTING_RULE_ID    := FND_API.G_MISS_NUM;
    ELSE
      l_trip_info_tab(1).ROUTING_RULE_ID    := p_carrier_sel_result_rec.rule_id ;
    END IF;

    l_trip_info_tab(1).ROUTE_ID              := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).ROUTING_INSTRUCTIONS  := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE_CATEGORY    := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE1            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE2            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE3            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE4            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE5            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE6            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE7            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE8            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE9            := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE10           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE11           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE12           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE13           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE14           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ATTRIBUTE15           := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).IGNORE_FOR_PLANNING   := l_ignore_for_planning;
    l_trip_info_tab(1).CREATION_DATE         := SYSDATE;
    l_trip_info_tab(1).CREATED_BY            := fnd_global.user_id;
    l_trip_info_tab(1).LAST_UPDATE_DATE      := SYSDATE;
    l_trip_info_tab(1).LAST_UPDATED_BY       := fnd_global.user_id;
    l_trip_info_tab(1).LAST_UPDATE_LOGIN     := fnd_global.login_id;
    l_trip_info_tab(1).PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).PROGRAM_ID            := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).PROGRAM_UPDATE_DATE   := FND_API.G_MISS_DATE;
    l_trip_info_tab(1).REQUEST_ID            := FND_API.G_MISS_NUM;

    IF (p_carrier_sel_result_rec.service_level is null) THEN
      l_trip_info_tab(1).SERVICE_LEVEL := FND_API.G_MISS_CHAR;
    ELSE
      l_trip_info_tab(1).SERVICE_LEVEL       := p_carrier_sel_result_rec.service_level;
    END IF;

    IF (p_carrier_sel_result_rec.mode_of_transport is null) THEN
      l_trip_info_tab(1).MODE_OF_TRANSPORT  := FND_API.G_MISS_CHAR;
    ELSE
      l_trip_info_tab(1).MODE_OF_TRANSPORT  := p_carrier_sel_result_rec.mode_of_transport;
    END IF;

    IF (p_carrier_sel_result_rec.freight_terms_code is null) THEN
      l_trip_info_tab(1).FREIGHT_TERMS_CODE     := FND_API.G_MISS_CHAR;
    ELSE
      l_trip_info_tab(1).FREIGHT_TERMS_CODE     := p_carrier_sel_result_rec.freight_terms_code;
    END IF;

    l_trip_info_tab(1).CONSOLIDATION_ALLOWED	:= FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).LOAD_TENDER_STATUS	    := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ROUTE_LANE_ID		    := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).LANE_ID		            := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).SCHEDULE_ID		        := FND_API.G_MISS_NUM;
    l_trip_info_tab(1).BOOKING_NUMBER	        := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).ARRIVE_AFTER_TRIP_NAME   := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).SHIP_METHOD_NAME	        := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).VEHICLE_ITEM_DESC	    := FND_API.G_MISS_CHAR;
    l_trip_info_tab(1).VEHICLE_ORGANIZATION_CODE := FND_API.G_MISS_CHAR;

    WSH_TRIPS_GRP.Create_Update_Trip(
       p_api_version_number => l_api_version_number,
       p_init_msg_list      => l_init_msg_list,
       p_commit             => l_commit,
       x_return_status      => l_return_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_trip_info_tab      => l_trip_info_tab,
       p_in_rec             => l_trip_in_rec,
       x_out_tab            => l_trip_out_rec_tab);

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_trip_id := l_trip_out_rec_tab(1).trip_id;
     l_trip_name := l_trip_out_rec_tab(1).trip_name;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Trip Created: l_trip_id :'||l_trip_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Trip Created: l_trip_name :'||l_trip_name);
     END IF;

     IF l_initial_pickup_date IS NULL AND l_ultimate_dropoff_date IS NULL THEN
        l_initial_pickup_date   := sysdate;
        l_ultimate_dropoff_date := l_initial_pickup_date + WSH_TRIPS_ACTIONS.C_TEN_MINUTES;
     ELSIF l_initial_pickup_date IS NULL AND l_ultimate_dropoff_date IS NOT NULL THEN
        l_initial_pickup_date := l_ultimate_dropoff_date - WSH_TRIPS_ACTIONS.C_TEN_MINUTES;
     ELSIF l_initial_pickup_date IS NOT NULL AND l_ultimate_dropoff_date IS NULL THEN
        l_ultimate_dropoff_date := l_initial_pickup_date + WSH_TRIPS_ACTIONS.C_TEN_MINUTES;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_initial_pickup_date :'||l_initial_pickup_date);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_ultimate_dropoff_date :'||l_ultimate_dropoff_date);
    END IF;

     l_pickup_stop_info.TRIP_ID             := l_trip_id;
     l_pickup_stop_info.STOP_LOCATION_ID    :=  l_initial_pickup_loc_id;
     l_pickup_stop_info.planned_arrival_date := l_initial_pickup_date;
     l_pickup_stop_info.planned_departure_date := l_initial_pickup_date;
     l_pickup_stop_info.weight_uom_code     := l_dlvy_weight_uom;
     l_pickup_stop_info.volume_uom_code     := l_dlvy_volume_uom;

     l_pickup_rec_attr_tab(1):= l_pickup_stop_info;

     l_stop_in_rec.action_code := p_action_code;
     l_stop_in_rec.caller := l_caller;

    -- Create Pick Up Stop

     WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP(
           p_api_version_number    => l_api_version_number,
           p_init_msg_list         => l_init_msg_list,
           p_commit                => l_commit,
           p_in_rec                => l_stop_in_rec,
           p_rec_attr_tab          => l_pickup_rec_attr_tab,
           x_stop_out_tab          => l_pickup_stop_out_tab,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           x_stop_wt_vol_out_tab   => l_stop_wt_vol_out_tab);

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Stop1: stop_id :'||l_pickup_stop_out_tab(1).stop_id);
     END IF;

     l_dropoff_stop_info.TRIP_ID                :=  l_trip_id;
     l_dropoff_stop_info.STOP_LOCATION_ID       :=  l_ultimate_dropoff_loc_id ;
     l_dropoff_stop_info.planned_arrival_date   :=  l_ultimate_dropoff_date;
     l_dropoff_stop_info.planned_departure_date :=  l_ultimate_dropoff_date;
     l_dropoff_stop_info.weight_uom_code        := l_dlvy_weight_uom;
     l_dropoff_stop_info.volume_uom_code        := l_dlvy_volume_uom;

     l_dropoff_rec_attr_tab(1)                  := l_dropoff_stop_info;

    -- Create Drop Off Stop

     WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP(
           p_api_version_number    => l_api_version_number,
           p_init_msg_list         => l_init_msg_list,
           p_commit                => l_commit,
           p_in_rec                => l_stop_in_rec,
           p_rec_attr_tab          => l_dropoff_rec_attr_tab,
           x_stop_out_tab          => l_dropoff_stop_out_tab,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           x_stop_wt_vol_out_tab   => l_stop_wt_vol_out_tab);

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Stop2: stop_id :'||l_dropoff_stop_out_tab(1).stop_id);
     END IF;

    l_action_prms.caller := l_caller;
	l_action_prms.phase :=NULL ;

	l_action_prms.action_code           := 'ASSIGN-TRIP';
	l_action_prms.trip_id               := l_trip_id;
	l_action_prms.trip_name             := l_trip_name;
	l_action_prms.pickup_stop_id        := l_pickup_stop_out_tab(1).stop_id;
	l_action_prms.pickup_loc_id         := l_initial_pickup_loc_id;

	l_action_prms.pickup_arr_date       := l_pickup_stop_info.planned_arrival_date;
	l_action_prms.pickup_dep_date       := l_pickup_stop_info.planned_departure_date;


	l_action_prms.dropoff_stop_id       := l_dropoff_stop_out_tab(1).stop_id;
	l_action_prms.dropoff_loc_id        := l_ultimate_dropoff_loc_id;

    l_action_prms.dropoff_arr_date      := l_dropoff_stop_info.planned_arrival_date;
	l_action_prms.dropoff_dep_date      := l_dropoff_stop_info.planned_departure_date;
	--l_delivery_id_tab(1)                := p_delivery_id;

    /*l_index := l_delivery_id_tab.FIRST;

    while l_index is not null LOOP
    --{
            open  c_dlvy_attr_csr(l_delivery_id_tab(l_index));

                fetch c_dlvy_attr_csr
                into  l_rec_attr_tab(l_index).delivery_id,
                l_rec_attr_tab(l_index).organization_id,
                l_rec_attr_tab(l_index).status_code,
                l_rec_attr_tab(l_index).planned_flag,
                l_rec_attr_tab(l_index).NAME,
                l_rec_attr_tab(l_index).INITIAL_PICKUP_DATE,
                l_rec_attr_tab(l_index).INITIAL_PICKUP_LOCATION_ID,
                l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_LOCATION_ID,
                l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_DATE,
                l_rec_attr_tab(l_index).CUSTOMER_ID,
                l_rec_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_ID,
                l_rec_attr_tab(l_index).SHIP_METHOD_CODE,
                l_rec_attr_tab(l_index).DELIVERY_TYPE,
                l_rec_attr_tab(l_index).CARRIER_ID,
                l_rec_attr_tab(l_index).SERVICE_LEVEL,
                l_rec_attr_tab(l_index).MODE_OF_TRANSPORT,
                l_rec_attr_tab(l_index).shipment_direction,
                l_rec_attr_tab(l_index).party_id,
                l_rec_attr_tab(l_index).shipping_control;

            close c_dlvy_attr_csr;
            l_index := l_delivery_id_tab.NEXT(l_index);
    --}
    END LOOP;*/

    -- Assign Delivery to trip

    WSH_DELIVERIES_GRP.Delivery_Action(
        p_api_version_number     =>  l_api_version_number,
        p_init_msg_list          =>  l_init_msg_list,
        p_commit                 =>  l_commit,
        p_action_prms            =>  l_action_prms,
        p_rec_attr_tab           =>  l_rec_attr_tab,
        x_delivery_out_rec       =>  x_delivery_out_rec,
        x_defaults_rec           =>  l_defaults_rec,
        x_return_status          =>  l_return_status,
        x_msg_count              =>  l_msg_count,
        x_msg_data               =>  l_msg_data);

    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    x_trip_id := l_trip_id;
    x_trip_name := l_trip_name;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION

  WHEN OTHERS THEN
       wsh_util_core.default_handler('FTE_ACS_TRIP_PKG.CARRIER_SEL_CREATE_TRIP',l_module_name);

       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       IF c_dlvy_attr_csr%ISOPEN THEN
          CLOSE c_dlvy_attr_csr;
       END IF;

       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'When Others');
       END IF;

END CARRIER_SEL_CREATE_TRIP;

--
-- ----------------------------------------------------------------------
-- Procedure:   GET_RANKED_RESULTS
--
-- Parameters:  p_rule_id		    Rule ID
--		x_routing_results	    Ranked list of carriers,mode and service levels
--              x_return_status             Return Status
--
-- COMMENT   :  The procedure queries FTE_SEL_RESULT_ASSIGNMENTS to return results for the given
--              rule id. The API returns does not return multileg results.
--  ----------------------------------------------------------------------
PROCEDURE GET_RANKED_RESULTS(  p_rule_id 	  IN NUMBER,
			       x_routing_results  OUT NOCOPY  FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
			       x_return_status    OUT NOCOPY VARCHAR2)
IS


CURSOR get_rule_name IS
SELECT name
FROM   FTE_SEL_RULES
WHERE  RULE_ID = p_rule_id;

l_result_tab		FTE_ACS_CACHE_PKG.fte_cs_result_attr_tab;
itr			NUMBER;
l_debug_on              BOOLEAN;
l_rule_name		VARCHAR2(30);
l_count			NUMBER;

CS_MULTILEG_RESULT	EXCEPTION;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'GET_RANKED_RESULTS';

BEGIN
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_RULE_ID',P_RULE_ID);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_ACS_CACHE_PKG.GET_RESULTS_FOR_RULE( p_rule_id	=> p_rule_id,
						x_result_tab	=> l_result_tab,
						x_return_status => x_return_status);


	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		           raise FND_API.G_EXC_UNEXPECTED_ERROR;
		       END IF;
	END IF;

	itr := l_result_tab.FIRST;

	IF (itr IS NOT NULL)THEN

		IF (l_result_tab(itr).result_type='RANK') THEN
			LOOP
				l_count := x_routing_results.COUNT;
				x_routing_results(l_count).rank_sequence	   := l_result_tab(itr).rank;
				x_routing_results(l_count).carrier_id		   := l_result_tab(itr).carrier_id;
				x_routing_results(l_count).service_level	   := l_result_tab(itr).service_level;
				x_routing_results(l_count).mode_of_transport       := l_result_tab(itr).mode_of_transport;
				x_routing_results(l_count).consignee_carrier_ac_no := l_result_tab(itr).consignee_carrier_ac_no;
				x_routing_results(l_count).freight_terms_code      := l_result_tab(itr).freight_terms_code;

				EXIT WHEN itr = l_result_tab.LAST;
				itr := l_result_tab.NEXT(itr);
			END LOOP;
		ELSE
			RAISE CS_MULTILEG_RESULT;
		END IF ;
	END IF;

	IF l_debug_on THEN
          WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION

WHEN CS_MULTILEG_RESULT	THEN

	x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;

	OPEN get_rule_name;
	FETCH get_rule_name INTO l_rule_name;
	CLOSE get_rule_name;

	--Routing Gide Rule RULE_NAME has changed, and the given Rule Detail cant be found.

	FND_MESSAGE.SET_NAME('FTE','FTE_CS_INVALID_RULE');
	FND_MESSAGE.SET_TOKEN('RULE_NAME',l_rule_name);
	wsh_util_core.add_message(x_return_status);

	IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
      	END IF;

WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_TRIP_PKG.GET_RANKED_RESULTS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END GET_RANKED_RESULTS;

END FTE_ACS_TRIP_PKG;

/
