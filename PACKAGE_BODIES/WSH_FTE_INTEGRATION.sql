--------------------------------------------------------
--  DDL for Package Body WSH_FTE_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_INTEGRATION" as
/* $Header: WSHFTEIB.pls 120.8.12000000.2 2007/02/15 00:54:23 parkhj ship $ */

 --
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FTE_INTEGRATION';
 --

  PROCEDURE Rate_Delivery  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_in_param_rec		IN rate_del_in_param_rec,
			     x_out_param_rec		OUT NOCOPY  rate_del_out_param_rec,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2)
  IS

   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000);

   l_in_param_rec	FTE_FREIGHT_RATING_DLVY_GRP.rate_del_in_param_rec;
   l_out_param_rec	FTE_FREIGHT_RATING_DLVY_GRP.rate_del_out_param_rec;
   --
   l_debug_on BOOLEAN;

   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RATE_DELIVERY';
   --
 BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERION',p_api_version);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',p_commit);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT WSH_Rate_Delivery;

  IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          ((p_in_param_rec.delivery_id_list.COUNT > 0) AND p_in_param_rec.action is NOT null) THEN

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_RATING_DLVY_GRP.RATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

	l_in_param_rec.delivery_id_list := p_in_param_rec.delivery_id_list;
	l_in_param_rec.action := p_in_param_rec.action;
	l_in_param_rec.seq_tender_flag := p_in_param_rec.seq_tender_flag;

        FTE_FREIGHT_RATING_DLVY_GRP.Rate_Delivery (
                                                 p_api_version          => p_api_version,
                                                 p_init_msg_list        => p_init_msg_list,
                                                 p_commit                 => p_commit,
						 p_in_param_rec		  => l_in_param_rec,
						 x_out_param_rec	  => l_out_param_rec,
                                                 x_return_status          => l_return_status,
                                                 x_msg_count              => l_msg_count,
                                                 x_msg_data               => l_msg_data);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
          END IF;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
	  x_out_param_rec.failed_delivery_id_list := l_out_param_rec.failed_delivery_id_list;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN others THEN
          ROLLBACK TO WSH_Rate_Delivery;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          wsh_util_core.default_handler('WSH_FTE_INTEGRATION.Rate_Delivery',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
 END Rate_Delivery;

-- WSH get_rate_from_FTE demo flow (multiple deliveries)
  PROCEDURE Cancel_Service  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_delivery_list            IN  WSH_UTIL_CORE.id_tab_type,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2)
  IS

   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000);

   --
   l_debug_on BOOLEAN;

   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_SERVICE';
   --
 BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LIST.COUNT',p_delivery_list.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION',p_action);
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERION',p_api_version);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',p_commit);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT WSH_Cancel_Service;

  IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          (p_delivery_list.COUNT > 0 AND p_action is NOT null) THEN

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_RATING_DLVY_GRP.CANCEL_SERVICE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        FTE_FREIGHT_RATING_DLVY_GRP.Cancel_Service (
                                                 p_api_version          => p_api_version,
                                                 p_init_msg_list        => p_init_msg_list,
                                                 p_delivery_list         => p_delivery_list,
                                                 p_action                 => p_action,
                                                 p_commit                 => p_commit,
                                                 x_return_status          => l_return_status,
                                                 x_msg_count              => l_msg_count,
                                                 x_msg_data               => l_msg_data);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
          END IF;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN others THEN
          ROLLBACK TO WSH_Cancel_Service;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          wsh_util_core.default_handler('WSH_FTE_INTEGRATION.Cancel_Service',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
 END Cancel_Service;

  PROCEDURE Cancel_Service  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_delivery_id              IN  NUMBER,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2)
  IS

   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000);

   --
   l_debug_on BOOLEAN;

   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_SERVICE';
   --
 BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION',p_action);
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERION',p_api_version);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',p_commit);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT WSH_Cancel_Service_2;

  IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          (p_delivery_id is NOT null AND p_action is NOT null) THEN

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_RATING_DLVY_GRP.CANCEL_SERVICE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        FTE_FREIGHT_RATING_DLVY_GRP.Cancel_Service (
                                                 p_api_version          => p_api_version,
                                                 p_init_msg_list        => p_init_msg_list,
                                                 p_delivery_id         => p_delivery_id,
                                                 p_action                 => p_action,
                                                 p_commit                 => p_commit,
                                                 x_return_status          => l_return_status,
                                                 x_msg_count              => l_msg_count,
                                                 x_msg_data               => l_msg_data);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
          END IF;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN others THEN
          ROLLBACK TO WSH_Cancel_Service_2;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          wsh_util_core.default_handler('WSH_FTE_INTEGRATION.Cancel_Service',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
 END Cancel_Service;

 PROCEDURE Shipment_Price_Consolidate (
                          p_delivery_leg_id     IN NUMBER DEFAULT NULL,
                          p_trip_id             IN NUMBER DEFAULT NULL,
                          x_return_status       OUT NOCOPY VARCHAR2 )  IS
   l_return_status   VARCHAR2(1);
   l_in_attributes   FTE_FREIGHT_PRICING.FtePricingInRecType;
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000);

   --
l_debug_on BOOLEAN;


   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SHIPMENT_PRICE_CONSOLIDATE';
   --
 BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT before_changes;

  IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          (p_delivery_leg_id is NOT null OR p_trip_id is NOT null) THEN

        l_in_attributes.api_version_number := 1.0;
        l_in_attributes.delivery_leg_id := p_delivery_leg_id;
        l_in_attributes.segment_id := p_trip_id;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_PRICING.SHIPMENT_PRICE_CONSOLIDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_FREIGHT_PRICING.shipment_price_consolidate (
                p_init_msg_list   =>  fnd_api.g_false,
                p_in_attributes   =>  l_in_attributes,
                x_return_status   =>  l_return_status,
                x_msg_count       =>  l_msg_count,
                x_msg_data        =>  l_msg_data );
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
          END IF;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN others THEN
          ROLLBACK TO before_changes;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          wsh_util_core.default_handler('WSH_FTE_INTEGRATION.Shipment_Price_Consolidate',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
 END Shipment_Price_Consolidate;

/*
Parameters :
          p_stop_rec - record to be inserted/updated/deleted from wsh_trip_stops
          p_trip_rec - record to be inserted/updated/deleted from wsh_trips
          p_action         - Action called
Values of p_action are
ADD
UPDATE
DELETE
TRIP_SEGMENT_DELETE

*/

PROCEDURE trip_stop_validations
        ( p_stop_rec  IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
          p_trip_rec IN WSH_TRIPS_PVT.trip_rec_type,
          p_action              IN VARCHAR2,
          x_return_status OUT NOCOPY VARCHAR2
        ) IS

  l_stop_rec_old WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_stop_rec_new WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_stop_rec_null WSH_TRIP_STOPS_PVT.trip_stop_rec_type;

  l_trip_rec_old WSH_TRIPS_PVT.trip_rec_type;
  l_trip_rec_new WSH_TRIPS_PVT.trip_rec_type;
  l_trip_rec_null WSH_TRIPS_PVT.trip_rec_type;
  l_stops_trip_rec WSH_TRIPS_PVT.trip_rec_type;

  l_stop_seg_IN FTE_WSH_INTERFACE_PKG.segmentStopChangeInRecType;
  l_stop_seg_OUT FTE_WSH_INTERFACE_PKG.segmentStopChangeOutRecType;
  l_trip_seg_IN FTE_WSH_INTERFACE_PKG.tripSegmentChangeInRecType;
  l_trip_seg_OUT FTE_WSH_INTERFACE_PKG.tripSegmentChangeOutRecType;


  l_msg_count    NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_return_status VARCHAR2(30):= WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRIP_STOP_VALIDATIONS';
--
BEGIN

/* Input is of type WSH_TRIPS_PVT or WSH_TRIP_STOPS_PVT api */
/* l_stop_rec and l_trip_rec are of type as per WSH_TRIPS_GRP api */
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
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
  END IF;
  --
  l_stop_rec_old := l_stop_rec_null;
  l_stop_rec_new := l_stop_rec_null;

  l_trip_rec_old := l_trip_rec_null;
  l_trip_rec_new := l_trip_rec_null;
  l_stops_trip_rec := l_trip_rec_null;
/* NEW MESSAGE here */
  IF (WSH_UTIL_CORE.FTE_IS_INSTALLED <> 'Y') THEN
        FND_MESSAGE.SET_NAME('WSH','FTE NOT INSTALLED');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'FTE NOT INSTALLE');
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
  END IF;


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--1. Creating Stop
  IF (p_action = 'ADD'
          AND (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM)
          ) THEN
-- Group API Call
        l_stop_seg_IN.action_type := p_action;
        IF (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM
                AND p_stop_rec.stop_location_id IS NOT NULL
           ) THEN

-- old record
-- New values are passed, so map them into l_stop_rec_new
        l_stop_rec_new := p_stop_rec;
-- Get trip details into l_stops_trip_rec FOR GROUP
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.GET_TRIP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_trips_grp.get_trip_details_pvt(p_trip_id => p_stop_rec.trip_id,
                                                 x_trip_rec => l_stops_trip_rec,
                                                 x_return_status => l_return_status);

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WSH_INTERFACE_PKG.SEGMENT_STOP_CHANGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_WSH_INTERFACE_PKG.segment_stop_change
        ( p_api_version  => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_trip_segment_rec => l_stops_trip_rec,
          p_old_segment_stop_rec => l_stop_rec_null,
          p_new_segment_stop_rec => l_stop_rec_new,
          p_segmentStopChangeInRec => l_stop_seg_IN,
          p_segmentStopChangeOutRec => l_stop_seg_OUT
        );
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
        END IF;

--2. Updating Stop
  ELSIF (p_action = 'UPDATE'
                 AND (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM)
                ) THEN

        l_stop_seg_IN.action_type := p_action;
-- Group API Call
        IF (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM
                   AND p_stop_rec.stop_location_id IS NOT NULL
                  )THEN

-- Get details of existing stop from database into l_stop_rec_old
        wsh_trip_stops_grp.get_stop_details_pvt(
          p_stop_id => p_stop_rec.stop_id,
          x_stop_rec => l_stop_rec_old,
          x_return_status => l_return_status
          );
        l_stop_rec_new := p_stop_rec;

-- Get trip details into l_stops_trip_rec FOR GROUP
        wsh_trips_grp.get_trip_details_pvt(p_trip_id => p_stop_rec.trip_id,
                                                 x_trip_rec => l_stops_trip_rec,
                                                 x_return_status => l_return_status);

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WSH_INTERFACE_PKG.SEGMENT_STOP_CHANGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_WSH_INTERFACE_PKG.segment_stop_change
        ( p_api_version  => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_trip_segment_rec => l_stops_trip_rec,
          p_old_segment_stop_rec => l_stop_rec_old,
          p_new_segment_stop_rec => l_stop_rec_new,
          p_segmentStopChangeInRec => l_stop_seg_IN,
          p_segmentStopChangeOutRec => l_stop_seg_OUT
        );
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;
        END IF;
--3. Deleting Stop
  ELSIF (p_action = 'DELETE'
                 AND (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM)
                ) THEN

        l_stop_seg_IN.action_type := p_action;
-- Group API Call
        IF (p_stop_rec.stop_location_id <> FND_API.G_MISS_NUM
                AND p_stop_rec.stop_location_id IS NOT NULL
          ) THEN
        l_stop_rec_old := p_stop_rec;
-- Get trip details into l_stops_trip_rec FOR GROUP
        --
        wsh_trips_grp.get_trip_details_pvt(
           p_trip_id => p_stop_rec.trip_id,
                                                 x_trip_rec => l_stops_trip_rec,
                                                 x_return_status => l_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WSH_INTERFACE_PKG.SEGMENT_STOP_CHANGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_WSH_INTERFACE_PKG.segment_stop_change
        ( p_api_version  => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_trip_segment_rec => l_stops_trip_rec,
          p_old_segment_stop_rec => l_stop_rec_old,
          p_new_segment_stop_rec => l_stop_rec_null,
          p_segmentStopChangeInRec => l_stop_seg_IN,
          p_segmentStopChangeOutRec => l_stop_seg_OUT
        );
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
        END IF;
--4. Updating Trip
  ELSIF (p_action = 'UPDATE'
                 AND (p_trip_rec.trip_id <> FND_API.G_MISS_NUM)
                ) THEN

        l_trip_seg_IN.action_type := p_action;

        IF (p_trip_rec.trip_id <> FND_API.G_MISS_NUM
                AND p_trip_rec.trip_id IS NOT NULL
                )THEN

-- Get the details of the trip as in the database in l_trip_rec_old
-- Get trip details into l_stops_trip_rec FOR GROUP
        wsh_trips_grp.get_trip_details_pvt(
          p_trip_id => p_trip_rec.trip_id,
                                                 x_trip_rec => l_trip_rec_old,
                                                 x_return_status => l_return_status);

-- Map the new values to the record l_trip_rec_new
        l_trip_rec_new := p_trip_rec;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WSH_INTERFACE_PKG.TRIP_SEGMENT_CHANGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_WSH_INTERFACE_PKG.trip_segment_change
        ( p_api_version  => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_old_trip_segment_rec => l_trip_rec_old,
          p_new_trip_segment_rec => l_trip_rec_new,
          p_tripSegmentChangeInRec => l_trip_seg_IN,
          p_tripSegmentChangeOutRec => l_trip_seg_OUT
         );
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
        END IF;

--5. Deleting Trip
/* anxsharm - as per talk with Nikhil ,WSH will not call FTE for Deletion
   of Stops within a trip.WSH will call FTE for individual stop deletion
   and individual trip deletion */
  ELSIF (p_action = 'DELETE'
                 AND (p_trip_rec.trip_id <> FND_API.G_MISS_NUM)
                ) THEN
        l_trip_seg_IN.action_type := p_action;
-- Group API Call
        IF (p_trip_rec.trip_id <> FND_API.G_MISS_NUM
                AND p_trip_rec.trip_id IS NOT NULL
          ) THEN

        l_trip_rec_old := p_trip_rec;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WSH_INTERFACE_PKG.TRIP_SEGMENT_CHANGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FTE_WSH_INTERFACE_PKG.trip_segment_change
        ( p_api_version  => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_old_trip_segment_rec => l_trip_rec_old,
          p_new_trip_segment_rec => l_trip_rec_null,
          p_tripSegmentChangeInRec => l_trip_seg_IN,
          p_tripSegmentChangeOutRec => l_trip_seg_OUT
         );
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
        END IF;

  ELSE
        IF p_action NOT IN ('ADD','UPDATE','DELETE') THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CALL_TO_FTE');
           wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
           l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSE
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'WSH_INVALID_CALL_TO_FTE');
           END IF;
        END IF;
  END IF;

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
  END IF;

  --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
        WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.trip_stop_validations',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END trip_stop_validations;

-- To be called only by the constraints private API
-- Not to be called by anyone else

FUNCTION get_cc_object_name(
             p_object_type             IN      VARCHAR2,
             p_object_value_num        IN NUMBER DEFAULT NULL,
             p_object_parent_id        IN NUMBER DEFAULT NULL,
             p_object_value_char       IN VARCHAR2 DEFAULT NULL,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY  VARCHAR2 ) RETURN VARCHAR2

IS

--
-- Local Variable Declarations
--
l_result                    VARCHAR2(2000);
l_unexp_char                VARCHAR2(30) := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;


--
-- Variables used for error handling
--
l_error_code                NUMBER;          -- Oracle SQL Error Number
l_error_text                VARCHAR2(2000);  -- Oracle SQL Error Text


--
-- Variables used for debugging
--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_cc_object_name';
--

others        EXCEPTION;

BEGIN

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_COMP_CONSTRAINT_UTIL.get_object_name',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   l_result :=  FTE_COMP_CONSTRAINT_UTIL.get_object_name(
                   p_object_type             =>      p_object_type,
                   p_object_value_num        =>      p_object_value_num,
                   p_object_parent_id        =>      p_object_parent_id,
                   p_object_value_char       =>      p_object_value_char,
                   x_fac_company_name        =>      x_fac_company_name,
                   x_fac_company_type        =>      x_fac_company_type );

   IF l_result = l_unexp_char THEN
      raise others;
   END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Returning object_name : ',l_result);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN l_result;

EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      --WSH_UTIL_CORE.default_handler('WSH_FTE_INTEGRATION.get_cc_object_name');
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_FTE_INTEGRATION.get_cc_object_name IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RETURN l_unexp_char;

END get_cc_object_name ;


--  Procedure : Get_Vehicle_Type
--  Purpose   : Gets vehicle type ID from FTE_VEHICLE_TYPES

PROCEDURE Get_Vehicle_Type(
             p_vehicle_item_id     IN  NUMBER,
             p_vehicle_org_id      IN  NUMBER,
             x_vehicle_type_id     OUT NOCOPY  NUMBER,
             x_return_status       OUT NOCOPY VARCHAR2) IS

CURSOR get_vehicle_type IS
SELECT vehicle_type_id
FROM   fte_vehicle_types
WHERE  inventory_item_id = p_vehicle_item_id AND
       organization_id = p_vehicle_org_id;

BEGIN

   OPEN get_vehicle_type;
   FETCH get_vehicle_type INTO x_vehicle_type_id;
   CLOSE get_vehicle_type;

   IF (x_vehicle_type_id IS NOT NULL) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   EXCEPTION WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END;

PROCEDURE GET_VEHICLE_ORG_ID
   (p_inventory_item_id         IN NUMBER,
    x_vehicle_org_id            OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2) IS

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   x_vehicle_org_id:=FTE_VEHICLE_PKG.GET_VEHICLE_ORG_ID
                            (p_inventory_item_id  => p_inventory_item_id);

   IF (x_vehicle_org_id IS NULL OR x_vehicle_org_id=-1) THEN
     x_return_status:= WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   EXCEPTION WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE Rate_Trip (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_action_params            IN  rating_action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2)
IS
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(4000);
   i                 NUMBER;
   --
   l_debug_on BOOLEAN;

   l_action_param_rec FTE_TRIP_RATING_GRP.action_param_rec;


   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RATE_TRIP';
   --
 BEGIN
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
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
          l_module_name,
          'p_action_params.trip_id_list.COUNT '|| p_action_params.trip_id_list.COUNT,
          WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
          l_module_name,
          'p_action_params.caller '|| p_action_params.caller,
          WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
          l_module_name,
          'p_action_params.event '|| p_action_params.event,
          WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
          l_module_name,
          'p_action_params.action '|| p_action_params.action,
          WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
          l_module_name,
          'p_commit '|| p_commit,
          WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT WSH_Rate_Trip;

  IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          (p_action_params.event is not null AND p_action_params.caller ='WSH'
           AND p_action_params.action is not null) THEN

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_TRIP_RATING_GRP.RATE_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_action_param_rec.caller := p_action_params.caller;
        l_action_param_rec.event  := p_action_params.event;
        l_action_param_rec.action := p_action_params.action;
        l_action_param_rec.trip_id_list := p_action_params.trip_id_list;

        --if the event is TP release and lane_id is not null, mark legs for reprice
        IF l_action_param_rec.event='TP-RELEASE' THEN

             --bug 3413328 update all legs reprice_required to Y if lane_id is present
             --in trip this needs to be done only for TP release as for other cases,
             --there will be no scenario in which a lane id will exist for a trip
             --which has not been priced

           FORALL i IN l_action_param_rec.trip_id_list.FIRST..l_action_param_rec.trip_id_list.LAST
             UPDATE wsh_delivery_legs
             SET reprice_required='Y',
                 last_update_date = SYSDATE,
                 last_updated_by =  FND_GLOBAL.USER_ID,
                 last_update_login =  FND_GLOBAL.LOGIN_ID
             WHERE NVL(reprice_required, 'N') ='N'
               and pick_up_stop_id IN
                    (select stop_id
                     from wsh_trip_stops wts, wsh_trips wt
                     where wts.trip_id=wt.trip_id
                     and wt.trip_id=l_action_param_rec.trip_id_list(i)
                     and wt.lane_id is not null
                    );

        END IF;

        FTE_TRIP_RATING_GRP.Rate_Trip (
             p_api_version              => p_api_version,
             p_init_msg_list            => p_init_msg_list,
             p_action_params            => l_action_param_rec,
             p_commit                   => p_commit,
             x_return_status            => l_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);


          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
          END IF;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN others THEN
          ROLLBACK TO WSH_Rate_Trip;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          wsh_util_core.default_handler('WSH_FTE_INTEGRATION.RATE_TRIP',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
 END Rate_Trip;

-- +====================================================+
-- Name - Trip_Action
-- Parameters - (as required by FTE API)
--
-- Trip_Action API added for J+ project to handle action
-- code = Auto Tender
-- This API should be called only when p_trip_id_tab.count
-- is greater than zero
--
-- +====================================================+
PROCEDURE  Trip_Action (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_trip_id_tab              IN  WSH_UTIL_CORE.id_tab_type,
             p_action_params            IN  wsh_trip_action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_action_out_rec           OUT NOCOPY wsh_trip_action_out_rec,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2) IS

-- FTE Datatypes which need to be passed to FTE API
  l_fte_trip_action_param_rec FTE_TRIP_ACTION_PARAM_REC;
  l_fte_action_out_rec        FTE_ACTION_OUT_REC;
  l_fte_trip_id_tab           FTE_ID_TAB_TYPE; -- :=  FTE_ID_TAB_TYPE(41343);

  l_wsh_result_id_tab         WSH_UTIL_CORE.ID_TAB_TYPE;
  l_wsh_valid_id_tab          WSH_UTIL_CORE.ID_TAB_TYPE;

  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER := 0;
  l_msg_data        VARCHAR2(4000);
  --
  l_debug_on BOOLEAN;

  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION';
  --
BEGIN
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
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(
         l_module_name,
         'p_trip_id_tab.COUNT '|| p_trip_id_tab.COUNT,
         WSH_DEBUG_SV.C_PROC_LEVEL);
    WSH_DEBUG_SV.logmsg(
         l_module_name,
         'p_action_params.action_code '|| p_action_params.action_code,
         WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT WSH_Trip_Action;

  -- Check if FTE is installed
  -- J+ project for Auto Tender
  IF  (WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND
          p_action_params.action_code = 'TENDER') THEN

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_fte_trip_id_tab := FTE_ID_TAB_TYPE();
    -- Convert Variables required as Input for FTE API
    FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID (p_wsh_id_tab   => p_trip_id_tab,
                                        x_fte_id_tab  => l_fte_trip_id_tab);

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After Calling program unit FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg( l_module_name, 'trip_id_tab.COUNT '|| l_fte_trip_id_tab.COUNT,
         WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    -- As agreed with Harish, only populating the action code 'TENDER'
    -- other parameters are left null
    l_fte_trip_action_param_rec := FTE_TRIP_ACTION_PARAM_REC(null,'TENDER',
                                        null,null,null,null,null,null,
                                        null,null,null,null,null,null,
                                        null,null);
    l_fte_trip_action_param_rec.action_code := p_action_params.action_code;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After populating FTE_TRIP_ACTION_PARAM_REC',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_MLS_WRAPPER.TRIP_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --

    -- Call FTE API
    FTE_MLS_WRAPPER.Trip_Action
      (p_api_version_number     => p_api_version,
       p_init_msg_list          => p_init_msg_list,
       p_trip_id_tab            => l_fte_trip_id_tab,
       p_action_prms            => l_fte_trip_action_param_rec,
       x_action_out_rec         => l_fte_action_out_rec,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data
      );

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
    END IF;

    x_msg_count := l_msg_count;
    x_msg_data  := l_msg_data;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_MLS_UTIL.COPY_FTE_ID_TO_WSH_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Convert Variables which are Output from FTE API
    FTE_MLS_UTIL.COPY_FTE_ID_TO_WSH_ID (p_fte_id_tab   => l_fte_action_out_rec.result_id_tab,
                                        x_wsh_id_tab   => l_wsh_result_id_tab);

    FTE_MLS_UTIL.COPY_FTE_ID_TO_WSH_ID (p_fte_id_tab   => l_fte_action_out_rec.valid_ids_tab,
                                        x_wsh_id_tab   => l_wsh_valid_id_tab);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'Result id tab Count',l_wsh_result_id_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'Valid id tab Count',l_wsh_valid_id_tab.count);
    END IF;
    --

    -- Transfer the ids to Output Data Structure
    x_action_out_rec.result_id_tab := l_wsh_result_id_tab;
    x_action_out_rec.valid_ids_tab := l_wsh_valid_id_tab; -- Success ids

    -- LOGIC TO DETERMINE FAILED TRIPS to reside in FTE

  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN others THEN
    ROLLBACK TO WSH_Trip_Action;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_FTE_INTEGRATION.TRIP_ACTION',l_module_name);
    --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;

END Trip_Action;

--
-- SBAKSHI
--

PROCEDURE CARRIER_SELECTION( p_format_cs_tab		IN  OUT  NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_entity_tab_type,
			     p_messaging_yn		IN			VARCHAR2,
			     p_caller			IN			VARCHAR2,
                             p_entity                   IN                      VARCHAR2,
			     x_cs_output_tab		OUT	NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_result_tab_type,
		             x_cs_output_message_tab	OUT	NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_output_message_tab,
			     x_return_message		OUT	NOCOPY		VARCHAR2,
			     x_return_status		OUT	NOCOPY		VARCHAR2) IS

--
-- Local Variable Declarations
--
l_fte_format_cs_tab		FTE_ACS_PKG.fte_cs_entity_tab_type;
l_fte_cs_result_tab		FTE_ACS_PKG.fte_cs_result_tab_type;
l_fte_cs_output_message_tab	FTE_ACS_PKG.fte_cs_output_message_tab;

l_start_search_level		VARCHAR2(10) := 'SCOE';
l_return_message	        VARCHAR2(2000);                        -- output result message
l_return_status		        VARCHAR2(1);                           -- output status

--
-- Variables used for error handling
--
l_error_code                NUMBER;                                -- Oracle SQL Error Number
l_error_text                VARCHAR2(2000);                        -- Oracle SQL Error Text

j			    NUMBER;

--
-- Variables used for debugging
--
l_debug_on		     BOOLEAN;

--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CARRIER_SELECTION';
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
   END IF;

   --
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message := null;

   IF  WSH_UTIL_CORE.FTE_Is_Installed <> 'Y' THEN
     return;
   END IF;

   --
   -- Map input WSH record/tables to FTE record/tables
   --
   IF (p_format_cs_tab.COUNT > 0 ) THEN

    FOR i IN p_format_cs_tab.FIRST..p_format_cs_tab.LAST LOOP
	j := l_fte_format_cs_tab.COUNT;

	l_fte_format_cs_tab(j).delivery_id               := p_format_cs_tab(i).delivery_id;
	l_fte_format_cs_tab(j).delivery_name             := p_format_cs_tab(i).delivery_name;
	l_fte_format_cs_tab(j).trip_id                   := p_format_cs_tab(i).trip_id;
	l_fte_format_cs_tab(j).trip_name                 := p_format_cs_tab(i).trip_name;
	l_fte_format_cs_tab(j).organization_id           := p_format_cs_tab(i).organization_id;
	l_fte_format_cs_tab(j).triporigin_internalorg_id := p_format_cs_tab(i).triporigin_internalorg_id;
	l_fte_format_cs_tab(j).gross_weight              := p_format_cs_tab(i).gross_weight;
	l_fte_format_cs_tab(j).weight_uom_code           := p_format_cs_tab(i).weight_uom_code;
	l_fte_format_cs_tab(j).volume                    := p_format_cs_tab(i).volume;
	l_fte_format_cs_tab(j).volume_uom_code           := p_format_cs_tab(i).volume_uom_code;
	l_fte_format_cs_tab(j).initial_pickup_loc_id     := p_format_cs_tab(i).initial_pickup_loc_id;
	l_fte_format_cs_tab(j).ultimate_dropoff_loc_id   := p_format_cs_tab(i).ultimate_dropoff_loc_id;
	l_fte_format_cs_tab(j).customer_id	         := p_format_cs_tab(i).customer_id;
	l_fte_format_cs_tab(j).customer_site_id		 := p_format_cs_tab(i).customer_site_id;
	l_fte_format_cs_tab(j).freight_terms_code	 := p_format_cs_tab(i).freight_terms_code;
	l_fte_format_cs_tab(j).initial_pickup_date       := p_format_cs_tab(i).initial_pickup_date;
	l_fte_format_cs_tab(j).ultimate_dropoff_date     := p_format_cs_tab(i).ultimate_dropoff_date;
	l_fte_format_cs_tab(j).fob_code                  := p_format_cs_tab(i).fob_code;
--      These fields are just placeholders
--	l_fte_format_cs_tab(j).start_search_level        := p_format_cs_tab(i).start_search_level;
	l_fte_format_cs_tab(j).transit_time		 := p_format_cs_tab(i).transit_time;
--	l_fte_fromat_cs_tab(j).rule_id			 := p_fromat_cs_tab(i).rule_id;
--	l_fte_format_cs_tab(j).result_found_flag         := p_format_cs_tab(i).result_found_flag;

     END LOOP;
   END IF;
   --
   -- Call carrier selection module
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_ACS_PKG.START_ACS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   FTE_ACS_PKG.GET_ROUTING_RESULTS(   --p_start_search_level_flag	=> p_start_search_level_flag,
				      p_format_cs_tab		=> l_fte_format_cs_tab,
				      p_messaging_yn		=> p_messaging_yn,
				      p_caller			=> p_caller,
                                      p_entity                  => p_entity,
			  	      x_cs_output_tab		=> l_fte_cs_result_tab,
		                      x_cs_output_message_tab	=> l_fte_cs_output_message_tab,
			 	      x_return_message		=> l_return_message,
			   	      x_return_status		=> l_return_status);

   --
   -- Map the result FTE tables back to WSH tables
   --

   IF (l_fte_cs_result_tab.COUNT > 0) THEN

      FOR i IN l_fte_cs_result_tab.FIRST..l_fte_cs_result_tab.LAST LOOP

	j:= x_cs_output_tab.COUNT;
	x_cs_output_tab(j).rule_id			:= l_fte_cs_result_tab(i).rule_id;
        x_cs_output_tab(j).rule_name			:= l_fte_cs_result_tab(i).rule_name;
	x_cs_output_tab(j).delivery_id			:= l_fte_cs_result_tab(i).delivery_id;
	x_cs_output_tab(j).organization_id		:= l_fte_cs_result_tab(i).organization_id;
	x_cs_output_tab(j).initial_pickup_location_id	:= l_fte_cs_result_tab(i).initial_pickup_location_id;
	x_cs_output_tab(j).ultimate_dropoff_location_id	:= l_fte_cs_result_tab(i).ultimate_dropoff_location_id;
	x_cs_output_tab(j).trip_id			:= l_fte_cs_result_tab(i).trip_id;
	x_cs_output_tab(j).result_type			:= l_fte_cs_result_tab(i).result_type;
	x_cs_output_tab(j).rank				:= l_fte_cs_result_tab(i).rank;
	x_cs_output_tab(j).leg_destination		:= l_fte_cs_result_tab(i).leg_destination;
	x_cs_output_tab(j).leg_sequence			:= l_fte_cs_result_tab(i).leg_sequence;
--	x_cs_output_tab(j).itinerary_id			:= l_fte_cs_result_tab(i).itinerary_id;
	x_cs_output_tab(j).carrier_id			:= l_fte_cs_result_tab(i).carrier_id;
	x_cs_output_tab(j).mode_of_transport		:= l_fte_cs_result_tab(i).mode_of_transport;
	x_cs_output_tab(j).service_level		:= l_fte_cs_result_tab(i).service_level;
	x_cs_output_tab(j).ship_method_code		:= l_fte_cs_result_tab(i).ship_method_code;
	x_cs_output_tab(j).freight_terms_code		:= l_fte_cs_result_tab(i).freight_terms_code;
	x_cs_output_tab(j).consignee_carrier_ac_no	:= l_fte_cs_result_tab(i).consignee_carrier_ac_no;
--	x_cs_output_tab(j).track_only_flag		:= l_fte_cs_result_tab(i).track_only_flag;
	x_cs_output_tab(j).result_level			:= l_fte_cs_result_tab(i).result_level;
	x_cs_output_tab(j).pickup_date			:= l_fte_cs_result_tab(i).pickup_date;
	x_cs_output_tab(j).dropoff_date			:= l_fte_cs_result_tab(i).dropoff_date;
	x_cs_output_tab(j).min_transit_time		:= l_fte_cs_result_tab(i).min_transit_time;
	x_cs_output_tab(j).max_transit_time		:= l_fte_cs_result_tab(i).max_transit_time;
	x_cs_output_tab(j).append_flag			:= l_fte_cs_result_tab(i).append_flag;
	--x_cs_output_tab(j).routing_rule_id	     	:= l_fte_cs_result_tab(i).routing_rule_id;

      END LOOP;
   END IF;


   IF (l_fte_cs_output_message_tab.COUNT > 0) THEN
      FOR i IN l_fte_cs_output_message_tab.FIRST..l_fte_cs_output_message_tab.LAST LOOP
	 j := x_cs_output_message_tab.COUNT;

	 x_cs_output_message_tab(j).sequence_number := l_fte_cs_output_message_tab(i).sequence_number;
         x_cs_output_message_tab(j).message_type    := l_fte_cs_output_message_tab(i).message_type;
         x_cs_output_message_tab(j).message_code    := l_fte_cs_output_message_tab(i).message_code;
         x_cs_output_message_tab(j).message_text    := l_fte_cs_output_message_tab(i).message_text;
         x_cs_output_message_tab(j).level	    := l_fte_cs_output_message_tab(i).level;
         x_cs_output_message_tab(j).query_id        := l_fte_cs_output_message_tab(i).query_id;
         x_cs_output_message_tab(j).group_id        := l_fte_cs_output_message_tab(i).group_id;

      END LOOP;
   END IF;

   x_return_message       := l_return_message;
   x_return_status        := l_return_status;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_FTE_INTEGRATION.CARRIER_SELECTION IS ' ||L_ERROR_TEXT  );
     END IF;
     --
      WSH_UTIL_CORE.default_handler('WSH_FTE_INTEGRATION.CARRIER_SELECTION');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := l_error_text;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RETURN;
END CARRIER_SELECTION;


PROCEDURE RANK_LIST_ACTION(
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2,
             p_action_code              IN  VARCHAR2,
             p_ranklist                 IN OUT NOCOPY CARRIER_RANK_LIST_TBL_TYPE,
             p_trip_id                  IN  NUMBER,
             p_rank_id                  IN  NUMBER
             --x_ranklist                 OUT NOCOPY CARRIER_RANK_LIST_TBL_TYPE
             )
IS

  l_ranked_list     FTE_CARRIER_RANK_LIST_PVT.CARRIER_RANK_LIST_TBL_TYPE;
  l_rank_id         NUMBER := NULL;
  list_cnt          NUMBER := 0;

  l_error_code                NUMBER;                                -- Oracle SQL Error Number
  l_error_text                VARCHAR2(2000);                        -- Oracle SQL Error Text

  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER := 0;
  l_msg_data        VARCHAR2(4000);
  --
  l_debug_on BOOLEAN;

  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RANK_LIST_ACTION';
  --
BEGIN
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

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  (WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN

    -- Copy p_ranked_list to FTE_CARRIER_RANK_LIST_PVT.CARRIER_RANK_LIST_TBL_TYPE

    list_cnt := p_ranklist.FIRST;
    IF list_cnt IS NOT NULL THEN
    LOOP

    l_ranked_list(list_cnt).TRIP_ID := p_ranklist(list_cnt).TRIP_ID;
    l_ranked_list(list_cnt).RANK_SEQUENCE := p_ranklist(list_cnt).RANK_SEQUENCE;
    l_ranked_list(list_cnt).CARRIER_ID := p_ranklist(list_cnt).CARRIER_ID;
    l_ranked_list(list_cnt).SERVICE_LEVEL := p_ranklist(list_cnt).SERVICE_LEVEL;
    l_ranked_list(list_cnt).MODE_OF_TRANSPORT := p_ranklist(list_cnt).MODE_OF_TRANSPORT;
    l_ranked_list(list_cnt).consignee_carrier_ac_no := p_ranklist(list_cnt).consignee_carrier_ac_no;
    l_ranked_list(list_cnt).freight_terms_code := p_ranklist(list_cnt).freight_terms_code;
    l_ranked_list(list_cnt).IS_CURRENT := p_ranklist(list_cnt).IS_CURRENT;
    l_ranked_list(list_cnt).CALL_RG_FLAG := p_ranklist(list_cnt).CALL_RG_FLAG;
    l_ranked_list(list_cnt).SOURCE := p_ranklist(list_cnt).SOURCE;

    EXIT WHEN list_cnt = p_ranklist.LAST;
    list_cnt := p_ranklist.NEXT(list_cnt);

    END LOOP;
    END IF;

    FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(
                        p_api_version_number =>  1.0,
                        p_init_msg_list      =>  p_init_msg_list,
                        x_return_status      =>  l_return_status,
                        x_msg_count          =>  x_msg_count,
                        x_msg_data           =>  x_msg_data,
                        --x_ranklist           =>  l_ranked_list,
                        p_action_code        =>  p_action_code,
                        p_ranklist           =>  l_ranked_list,
                        p_trip_id             =>  p_trip_id,
                        p_rank_id            =>  l_rank_id);

    -- Copy l_ranked_list to WSH_FTE_INTEGRATION.CARRIER_RANK_LIST_TBL_TYPE

    list_cnt := l_ranked_list.FIRST;
    IF list_cnt IS NOT NULL THEN
    LOOP

    p_ranklist(list_cnt).TRIP_ID := l_ranked_list(list_cnt).TRIP_ID;
    p_ranklist(list_cnt).RANK_SEQUENCE := l_ranked_list(list_cnt).RANK_SEQUENCE;
    p_ranklist(list_cnt).CARRIER_ID := l_ranked_list(list_cnt).CARRIER_ID;
    p_ranklist(list_cnt).SERVICE_LEVEL := l_ranked_list(list_cnt).SERVICE_LEVEL;
    p_ranklist(list_cnt).MODE_OF_TRANSPORT := l_ranked_list(list_cnt).MODE_OF_TRANSPORT;
    p_ranklist(list_cnt).consignee_carrier_ac_no := l_ranked_list(list_cnt).consignee_carrier_ac_no;
    p_ranklist(list_cnt).freight_terms_code := l_ranked_list(list_cnt).freight_terms_code;
    p_ranklist(list_cnt).IS_CURRENT := l_ranked_list(list_cnt).IS_CURRENT;
    p_ranklist(list_cnt).CALL_RG_FLAG := l_ranked_list(list_cnt).CALL_RG_FLAG;
    p_ranklist(list_cnt).SOURCE := l_ranked_list(list_cnt).SOURCE;
    p_ranklist(list_cnt).rank_id := l_ranked_list(list_cnt).rank_id;

    EXIT WHEN list_cnt = l_ranked_list.LAST;
    list_cnt := l_ranked_list.NEXT(list_cnt);

    END LOOP;
    END IF;


    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
    END IF;

    x_msg_count := l_msg_count;
    x_msg_data  := l_msg_data;

  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_FTE_INTEGRATION.RANK_LIST_ACTION IS ' ||L_ERROR_TEXT  );
     END IF;
     --
      WSH_UTIL_CORE.default_handler('WSH_FTE_INTEGRATION.RANK_LIST_ACTION');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_msg_data := l_error_text;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END RANK_LIST_ACTION;

FUNCTION GET_TRIP_MOVE(
             p_trip_id                   IN  NUMBER) RETURN NUMBER

IS
    CURSOR c_get_trip_cmove(c_trip_id IN NUMBER) IS
    SELECT MOVE_ID
    FROM   FTE_TRIP_MOVES
    WHERE  TRIP_ID = c_trip_id;

  l_move_id   NUMBER := -1;

  l_error_code                NUMBER;                                -- Oracle SQL Error Number
  l_error_text                VARCHAR2(2000);                        -- Oracle SQL Error Text

  --
  l_debug_on BOOLEAN;

  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRIP_MOVE';
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
    WSH_DEBUG_SV.logmsg(l_module_name,  'trip id : ' ||p_trip_id  );
  END IF;
  --

  IF  (WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN

            OPEN c_get_trip_cmove(p_trip_id);
            --LOOP
            FETCH c_get_trip_cmove INTO l_move_id;
            --EXIT WHEN c_get_trip_cmove%NOTFOUND;
            --END LOOP;
            IF c_get_trip_cmove%NOTFOUND THEN
               l_move_id := -1;
            END IF;
            CLOSE c_get_trip_cmove;

/*
            IF c_get_trip_cmove%ROWCOUNT = 0 THEN
               l_move_id := -1;
            END IF;
*/
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_move_id;

EXCEPTION
  WHEN OTHERS THEN
      IF c_get_trip_cmove%ISOPEN THEN
         CLOSE c_get_trip_cmove;
      END IF;
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_FTE_INTEGRATION.GET_TRIP_MOVE IS ' ||L_ERROR_TEXT  );
     END IF;
     --
      WSH_UTIL_CORE.default_handler('WSH_FTE_INTEGRATION.GET_TRIP_MOVE');
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RETURN -1;
END GET_TRIP_MOVE;


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
--             This procedure is a wrapper for FTE_ACS_TRIP_PKG.CARRIER_SEL_CREATE_TRIP
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

l_debug_on		     BOOLEAN;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CARRIER_SEL_CREATE_TRIP';


BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    FTE_ACS_TRIP_PKG.CARRIER_SEL_CREATE_TRIP(
       p_delivery_id               => p_delivery_id,
       p_carrier_sel_result_rec    => p_carrier_sel_result_rec,
       x_trip_id                   => x_trip_id,
       x_trip_name                 => x_trip_name,
       x_return_message            => x_return_message,
       x_return_status             => x_return_status);

    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_FTE_INTEGRATION.CARRIER_SEL_CREATE_TRIP',l_module_name);

       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'When Others');
       END IF;

END CARRIER_SEL_CREATE_TRIP;





-- ----------------------------------------------------------------------
-- Procedure:   GET_ORG_ORGANIZATION_INFO
--
-- Parameters:
--              p_init_msg_list             Flag to initialize message stack
--              x_return_message            Return Message
--              x_msg_count                 count of messages
--              p_msg_data                  message text
--              x_organization_id           inventory organization identifier
--              x_org_id                    operating unit identifier
--              p_entity_id                 entity identifier
--              p_entity_type               'TRIP' or 'DELIVERY'
--              p_org_id_flag               flag to optionally get x_org_id
--                                             FND_API.G_TRUE -> yes
--                                             FND_API.G_FALSE -> no
--
--
-- COMMENT   : This procedure calls FTE to associate a trip with
--             inventory organization and optionally the operating unit.
--
--             This procedure is a wrapper for
--             FTE_WSH_INTEGRATION_PKG.GET_ORG_ORGANIZATION_INFO
--
--             FTE will always be called regardless of
--             WSH_UTIL_CORE.FTE_Is_Installed value.
--
--  ----------------------------------------------------------------------
PROCEDURE GET_ORG_ORGANIZATION_INFO(
       p_init_msg_list    IN             VARCHAR2,
       x_return_status       OUT NOCOPY  VARCHAR2,
       x_msg_count           OUT NOCOPY  NUMBER,
       x_msg_data            OUT NOCOPY  VARCHAR2,
       x_organization_id     OUT NOCOPY  NUMBER,
       x_org_id              OUT NOCOPY  NUMBER,
       p_entity_id        IN             NUMBER,
       p_entity_type      IN             VARCHAR2,
       p_org_id_flag      IN             VARCHAR2)
IS

  l_debug_on  BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
        'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORG_ORGANIZATION_INFO';
BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_init_msg_list', p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name, 'p_entity_id', p_entity_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_entity_type', p_entity_type);
      WSH_DEBUG_SV.log(l_module_name, 'p_org_id_flag', p_org_id_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,
           'Calling FTE_WSH_INTEGRATION_PKG.GET_ORG_ORGANIZATION_INFO',
           WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    FTE_WSH_INTERFACE_PKG.GET_ORG_ORGANIZATION_INFO(
       p_init_msg_list    => p_init_msg_list,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       x_organization_id  => x_organization_id,
       x_org_id           => x_org_id,
       p_entity_id        => p_entity_id,
       p_entity_type      => p_entity_type,
       p_org_id_flag      => p_org_id_flag
    );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'x_msg_count', x_msg_count);
      WSH_DEBUG_SV.log(l_module_name, 'x_msg_data', x_msg_data);
      WSH_DEBUG_SV.log(l_module_name, 'x_organization_id', x_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_org_id', x_org_id);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler(
          'WSH_FTE_INTEGRATION.GET_ORG_ORGANIZATION_INFO',
          l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,
              'Unexpected error has occured. Oracle error message is '
              || SQLERRM,
              WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END GET_ORG_ORGANIZATION_INFO;



-- ----------------------------------------------------------------------
-- Procedure:   CREATE_RANK_LIST_BULK
--
-- Parameters:
--              p_api_version_number        API version number (1)
--              p_init_msg_list             Flag to initialize message stack
--              x_return_message            Return Message
--              x_msg_count                 count of messages
--              p_msg_data                  message text
--              p_source                    source of call; valid values:
--                                            C_RANKLIST_SOURCE_%
--              p_trip_id_tab               table of trip identifiers
--
--
-- COMMENT   : This procedure calls FTE to perform a bulk operation
--             on ranking carriers in trips.
--
--             This procedure is a wrapper for
--             FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST_BULK
--
--             It will pull the required values from WSH_TRIPS to
--             build the rank list for the FTE API.
--
--  ----------------------------------------------------------------------
PROCEDURE CREATE_RANK_LIST_BULK(
    p_api_version_number IN            NUMBER,
    p_init_msg_list      IN            VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_source             IN            VARCHAR2,
    p_trip_id_tab        IN            WSH_UTIL_CORE.ID_TAB_TYPE)
IS

  l_debug_on  BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
        'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_RANK_LIST_BULK';
  --
  l_index    NUMBER;
  i          NUMBER;
  l_ranklist FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_bulk_rec;
BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_api_version_number',
                                       p_api_version_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_init_msg_list',
                                       p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name, 'p_source',
                                       p_source);
      WSH_DEBUG_SV.log(l_module_name, 'p_trip_id_tab.COUNT',
                                       p_trip_id_tab.COUNT);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF p_trip_id_tab.COUNT > 0
       AND (WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Selecting WSH_TRIPS into rank list');
      END IF;

      FOR i IN p_trip_id_tab.FIRST .. p_trip_id_tab.LAST LOOP
        SELECT
               p_source         SOURCE,
               1                RANK_SEQUENCE,
               TO_CHAR(NULL)    CALL_RG_FLAG,
               TO_DATE(NULL)    SCHEDULE_FROM,
               TO_DATE(NULL)    SCHEDULE_TO,
               TO_NUMBER(NULL)  ESTIMATED_RATE,
               TO_CHAR(NULL)    CURRENCY_CODE,
               TO_NUMBER(NULL)  ESTIMATED_TRANSIT_TIME,
               TO_CHAR(NULL)    TRANSIT_TIME_UOM,
               wt.TRIP_ID,
               wt.RANK_ID,
               wt.LANE_ID,
               wt.CARRIER_ID,
               wt.SERVICE_LEVEL,
               wt.MODE_OF_TRANSPORT,
               wt.VEHICLE_ORGANIZATION_ID  VEHICLE_ORG_ID,
               wt.VEHICLE_ITEM_ID,
               wt.CONSIGNEE_CARRIER_AC_NO,
               wt.FREIGHT_TERMS_CODE,
               wt.SCHEDULE_ID,
               wt.ATTRIBUTE_CATEGORY,
               wt.ATTRIBUTE1,
               wt.ATTRIBUTE2,
               wt.ATTRIBUTE3,
               wt.ATTRIBUTE4,
               wt.ATTRIBUTE5,
               wt.ATTRIBUTE6,
               wt.ATTRIBUTE7,
               wt.ATTRIBUTE8,
               wt.ATTRIBUTE9,
               wt.ATTRIBUTE10,
               wt.ATTRIBUTE11,
               wt.ATTRIBUTE12,
               wt.ATTRIBUTE13,
               wt.ATTRIBUTE14,
               wt.ATTRIBUTE15
        INTO
               l_ranklist.SOURCE(i),
               l_ranklist.RANK_SEQUENCE(i),
               l_ranklist.CALL_RG_FLAG(i),
               l_ranklist.SCHEDULE_FROM(i),
               l_ranklist.SCHEDULE_TO(i),
               l_ranklist.ESTIMATED_RATE(i),
               l_ranklist.CURRENCY_CODE(i),
               l_ranklist.ESTIMATED_TRANSIT_TIME(i),
               l_ranklist.TRANSIT_TIME_UOM(i),
               l_ranklist.TRIP_ID(i),
               l_ranklist.RANK_ID(i),
               l_ranklist.LANE_ID(i),
               l_ranklist.CARRIER_ID(i),
               l_ranklist.SERVICE_LEVEL(i),
               l_ranklist.MODE_OF_TRANSPORT(i),
               l_ranklist.VEHICLE_ORG_ID(i),
               l_ranklist.VEHICLE_ITEM_ID(i),
               l_ranklist.CONSIGNEE_CARRIER_AC_NO(i),
               l_ranklist.FREIGHT_TERMS_CODE(i),
               l_ranklist.SCHEDULE_ID(i),
               l_ranklist.ATTRIBUTE_CATEGORY(i),
               l_ranklist.ATTRIBUTE1(i),
               l_ranklist.ATTRIBUTE2(i),
               l_ranklist.ATTRIBUTE3(i),
               l_ranklist.ATTRIBUTE4(i),
               l_ranklist.ATTRIBUTE5(i),
               l_ranklist.ATTRIBUTE6(i),
               l_ranklist.ATTRIBUTE7(i),
               l_ranklist.ATTRIBUTE8(i),
               l_ranklist.ATTRIBUTE9(i),
               l_ranklist.ATTRIBUTE10(i),
               l_ranklist.ATTRIBUTE11(i),
               l_ranklist.ATTRIBUTE12(i),
               l_ranklist.ATTRIBUTE13(i),
               l_ranklist.ATTRIBUTE14(i),
               l_ranklist.ATTRIBUTE15(i)
        FROM   wsh_trips wt
        WHERE  trip_id = p_trip_id_tab(i);
      END LOOP;

      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'l_ranklist.trip_id.COUNT',
                                        l_ranklist.trip_id.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,
             'Calling FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST_BULK',
             WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST_BULK(
        p_api_version_number => p_api_version_number,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_ranklist           => l_ranklist
      );

    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status',
                                       x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'l_ranklist.trip_id.COUNT',
                                       l_ranklist.trip_id.count);
      WSH_DEBUG_SV.log(l_module_name, 'x_msg_count', x_msg_count);
      WSH_DEBUG_SV.log(l_module_name, 'x_msg_data', x_msg_data);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler(
          'WSH_FTE_INTEGRATION.CREATE_RANK_LIST_BULK',
          l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,
              'Unexpected error has occured. Oracle error message is '
              || SQLERRM,
              WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;


END CREATE_RANK_LIST_BULK;


END WSH_FTE_INTEGRATION;

/
