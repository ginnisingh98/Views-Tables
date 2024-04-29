--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_STOPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_STOPS_PUB" as
/* $Header: WSHSTPBB.pls 120.0 2005/05/26 18:12:14 appldev noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_TRIP_STOPS_PUB';
-- add your constants here if any

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Stop_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Stop action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'ARRIVE','CLOSE'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--		     p_stop_id               Stop identifier
--             p_trip_id               Stop identifier - trip id it belongs to
--             p_trip_name             Stop identifier - trip name it belongs to
--             p_stop_location_id      Stop identifier - stop location id
--             p_stop_location_code    Stop identifier - stop location code
--             p_planned_dep_date      Stop identifier - stop planned dep date
--             p_actual_date           Actual arrival/departure date of the stop
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing stop identified by p_stop_id or a unique combination of
--             trip_id/trip_name, stop_location_id/stop_location_code or planned_departure_date.
--
--========================================================================

  PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_id                IN   NUMBER DEFAULT NULL,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_stop_location_id       IN   NUMBER DEFAULT NULL,
    p_stop_location_code     IN   VARCHAR2 DEFAULT NULL,
    p_planned_dep_date       IN   DATE   DEFAULT NULL,
    p_actual_date            IN   DATE   DEFAULT NULL,
    p_defer_interface_flag   IN   VARCHAR2 DEFAULT 'Y') IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Stop_Action';
  l_entity_id_tab      wsh_util_core.id_tab_type;
  l_action_prms        WSH_TRIP_STOPS_GRP.action_parameters_rectype;
  l_stop_out_rec       WSH_TRIP_STOPS_GRP.stopActionOutRecType;

  -- <insert here your local variables declaration>
  stop_action_error EXCEPTION;



  l_stop_id               NUMBER := p_stop_id;
  l_trip_id               NUMBER := p_trip_id;
  l_stop_location_id      NUMBER := p_stop_location_id;
  l_return_status         VARCHAR2(1);
  l_num_warning           NUMBER;
  l_num_errors            NUMBER;

l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                       || 'STOP_ACTION PUBLIC';


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
         wsh_debug_sv.push (l_module_name);
         wsh_debug_sv.log (l_module_name,'p_api_version_number',
                                                       p_api_version_number);
         wsh_debug_sv.log (l_module_name,'p_init_msg_list', p_init_msg_list);
         wsh_debug_sv.log (l_module_name,'p_action_code', p_action_code);
         wsh_debug_sv.log (l_module_name,'p_stop_id', p_stop_id);
         wsh_debug_sv.log (l_module_name,'p_trip_id', p_trip_id);
         wsh_debug_sv.log (l_module_name,'p_trip_name', p_trip_name);
         wsh_debug_sv.log (l_module_name,'p_stop_location_id',
                                                         p_stop_location_id);
         wsh_debug_sv.log (l_module_name,'p_stop_location_code',
                                               p_stop_location_code);
         wsh_debug_sv.log (l_module_name,'p_planned_dep_date',
                                                 p_planned_dep_date);
         wsh_debug_sv.log (l_module_name,'p_actual_date', p_actual_date);
         wsh_debug_sv.log (l_module_name,'p_defer_interface_flag',
                                                  p_defer_interface_flag);
     END IF;

  --  Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         , G_PKG_NAME
         )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --  Initialize message stack if required
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;


     wsh_util_validate.validate_trip_name( l_trip_id,
                                           p_trip_name,
                                           l_return_status);

     wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

     IF ((l_stop_location_id IS NOT NULL)
         AND (l_stop_location_id <> FND_API.G_MISS_NUM))
      OR ((p_stop_location_code IS NOT NULL)
         AND (p_stop_location_code <> FND_API.G_MISS_CHAR)) THEN

        wsh_util_validate.validate_location( l_stop_location_id,
                                             p_stop_location_code,
                                             l_return_status);

        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                  x_num_warnings     =>l_num_warning,
                                  x_num_errors       =>l_num_errors);

     END IF;
     wsh_util_validate.validate_stop_name( l_stop_id,
                                          l_trip_id,
                                          l_stop_location_id,
                                          p_planned_dep_date,
                                          l_return_status);

     wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

     IF (l_stop_id IS NULL) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

    l_action_prms.caller := 'WSH_PUB';
    IF UPPER(p_action_code) IN ('CLOSE','ARRIVE') THEN
       l_action_prms.action_code := 'UPDATE-STATUS';
       l_action_prms.stop_action := p_action_code;
    ELSE
       l_action_prms.action_code := p_action_code;
    END IF;
    l_action_prms.actual_date := p_actual_date;
    l_action_prms.defer_interface_flag := p_defer_interface_flag;
    l_entity_id_tab(1) := l_stop_id;

    WSH_INTERFACE_GRP.Stop_Action (
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_TRUE,
        p_entity_id_tab         => l_entity_id_tab,
        p_action_prms           => l_action_prms,
        x_stop_out_rec          => l_stop_out_rec,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

     IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
	   FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
	   FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_action_code));
	   wsh_util_core.add_message(x_return_status,l_module_name);

           IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_ERROR');
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
        FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
	FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_action_code));
        wsh_util_core.add_message(x_return_status,l_module_name);
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_UNEXPECTED_ERROR');
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );

        IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
  END Stop_Action;

--Harmonizing Project **heali
PROCEDURE map_stoppub_to_pvt(
   p_pub_stop_rec IN WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE,
   x_pvt_stop_rec OUT NOCOPY WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_STOPPUB_TO_PVT';
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
       WSH_DEBUG_SV.log(l_module_name,'p_pub_stop_rec.STOP_ID',p_pub_stop_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_pub_stop_rec.TRIP_ID',p_pub_stop_rec.TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_pub_stop_rec.TRIP_NAME',p_pub_stop_rec.TRIP_NAME);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_stop_rec.STOP_ID			:= p_pub_stop_rec.STOP_ID;
  x_pvt_stop_rec.TRIP_ID			:= p_pub_stop_rec.TRIP_ID;
  x_pvt_stop_rec.STOP_LOCATION_ID	 	:= p_pub_stop_rec.STOP_LOCATION_ID;
  x_pvt_stop_rec.STATUS_CODE			:= FND_API.G_MISS_CHAR;
  x_pvt_stop_rec.STOP_SEQUENCE_NUMBER		:= p_pub_stop_rec.STOP_SEQUENCE_NUMBER;
  x_pvt_stop_rec.PLANNED_ARRIVAL_DATE	 	:= p_pub_stop_rec.PLANNED_ARRIVAL_DATE;
  x_pvt_stop_rec.PLANNED_DEPARTURE_DATE   	:= p_pub_stop_rec.PLANNED_DEPARTURE_DATE;
  x_pvt_stop_rec.ACTUAL_ARRIVAL_DATE	  	:= p_pub_stop_rec.ACTUAL_ARRIVAL_DATE;
  x_pvt_stop_rec.ACTUAL_DEPARTURE_DATE		:= p_pub_stop_rec.ACTUAL_DEPARTURE_DATE;
  x_pvt_stop_rec.DEPARTURE_GROSS_WEIGHT  	:= p_pub_stop_rec.DEPARTURE_GROSS_WEIGHT;
  x_pvt_stop_rec.DEPARTURE_NET_WEIGHT	 	:= p_pub_stop_rec.DEPARTURE_NET_WEIGHT;
  x_pvt_stop_rec.WEIGHT_UOM_CODE	  	:= p_pub_stop_rec.WEIGHT_UOM_CODE;
  x_pvt_stop_rec.DEPARTURE_VOLUME		:= p_pub_stop_rec.DEPARTURE_VOLUME;
  x_pvt_stop_rec.VOLUME_UOM_CODE		:= p_pub_stop_rec.VOLUME_UOM_CODE;
  x_pvt_stop_rec.DEPARTURE_SEAL_CODE	  	:= p_pub_stop_rec.DEPARTURE_SEAL_CODE;
  x_pvt_stop_rec.DEPARTURE_FILL_PERCENT   	:= p_pub_stop_rec.DEPARTURE_FILL_PERCENT;
  x_pvt_stop_rec.TP_ATTRIBUTE_CATEGORY		:= p_pub_stop_rec.TP_ATTRIBUTE_CATEGORY;
  x_pvt_stop_rec.TP_ATTRIBUTE1			:= p_pub_stop_rec.TP_ATTRIBUTE1;
  x_pvt_stop_rec.TP_ATTRIBUTE2			:= p_pub_stop_rec.TP_ATTRIBUTE2;
  x_pvt_stop_rec.TP_ATTRIBUTE3			:= p_pub_stop_rec.TP_ATTRIBUTE3;
  x_pvt_stop_rec.TP_ATTRIBUTE4			:= p_pub_stop_rec.TP_ATTRIBUTE4;
  x_pvt_stop_rec.TP_ATTRIBUTE5			:= p_pub_stop_rec.TP_ATTRIBUTE5;
  x_pvt_stop_rec.TP_ATTRIBUTE6			:= p_pub_stop_rec.TP_ATTRIBUTE6;
  x_pvt_stop_rec.TP_ATTRIBUTE7			:= p_pub_stop_rec.TP_ATTRIBUTE7;
  x_pvt_stop_rec.TP_ATTRIBUTE8			:= p_pub_stop_rec.TP_ATTRIBUTE8;
  x_pvt_stop_rec.TP_ATTRIBUTE9			:= p_pub_stop_rec.TP_ATTRIBUTE9;
  x_pvt_stop_rec.TP_ATTRIBUTE10		   	:= p_pub_stop_rec.TP_ATTRIBUTE10;
  x_pvt_stop_rec.TP_ATTRIBUTE11		   	:= p_pub_stop_rec.TP_ATTRIBUTE11;
  x_pvt_stop_rec.TP_ATTRIBUTE12		   	:= p_pub_stop_rec.TP_ATTRIBUTE12;
  x_pvt_stop_rec.TP_ATTRIBUTE13		   	:= p_pub_stop_rec.TP_ATTRIBUTE13;
  x_pvt_stop_rec.TP_ATTRIBUTE14		   	:= p_pub_stop_rec.TP_ATTRIBUTE14;
  x_pvt_stop_rec.TP_ATTRIBUTE15		   	:= p_pub_stop_rec.TP_ATTRIBUTE15;
  x_pvt_stop_rec.ATTRIBUTE_CATEGORY	   	:= p_pub_stop_rec.ATTRIBUTE_CATEGORY;
  x_pvt_stop_rec.ATTRIBUTE1			:= p_pub_stop_rec.ATTRIBUTE1;
  x_pvt_stop_rec.ATTRIBUTE2			:= p_pub_stop_rec.ATTRIBUTE2;
  x_pvt_stop_rec.ATTRIBUTE3			:= p_pub_stop_rec.ATTRIBUTE3;
  x_pvt_stop_rec.ATTRIBUTE4			:= p_pub_stop_rec.ATTRIBUTE4;
  x_pvt_stop_rec.ATTRIBUTE5			:= p_pub_stop_rec.ATTRIBUTE5;
  x_pvt_stop_rec.ATTRIBUTE6			:= p_pub_stop_rec.ATTRIBUTE6;
  x_pvt_stop_rec.ATTRIBUTE7			:= p_pub_stop_rec.ATTRIBUTE7;
  x_pvt_stop_rec.ATTRIBUTE8			:= p_pub_stop_rec.ATTRIBUTE8;
  x_pvt_stop_rec.ATTRIBUTE9			:= p_pub_stop_rec.ATTRIBUTE9;
  x_pvt_stop_rec.ATTRIBUTE10			:= p_pub_stop_rec.ATTRIBUTE10;
  x_pvt_stop_rec.ATTRIBUTE11			:= p_pub_stop_rec.ATTRIBUTE11;
  x_pvt_stop_rec.ATTRIBUTE12			:= p_pub_stop_rec.ATTRIBUTE12;
  x_pvt_stop_rec.ATTRIBUTE13			:= p_pub_stop_rec.ATTRIBUTE13;
  x_pvt_stop_rec.ATTRIBUTE14			:= p_pub_stop_rec.ATTRIBUTE14;
  x_pvt_stop_rec.ATTRIBUTE15			:= p_pub_stop_rec.ATTRIBUTE15;
  x_pvt_stop_rec.CREATION_DATE			:= p_pub_stop_rec.CREATION_DATE;
  x_pvt_stop_rec.CREATED_BY			:= p_pub_stop_rec.CREATED_BY;
  x_pvt_stop_rec.LAST_UPDATE_DATE		:= p_pub_stop_rec.LAST_UPDATE_DATE;
  x_pvt_stop_rec.LAST_UPDATED_BY		:= p_pub_stop_rec.LAST_UPDATED_BY;
  x_pvt_stop_rec.LAST_UPDATE_LOGIN		:= p_pub_stop_rec.LAST_UPDATE_LOGIN;
  x_pvt_stop_rec.PROGRAM_APPLICATION_ID   	:= p_pub_stop_rec.PROGRAM_APPLICATION_ID;
  x_pvt_stop_rec.PROGRAM_ID			:= p_pub_stop_rec.PROGRAM_ID;
  x_pvt_stop_rec.PROGRAM_UPDATE_DATE	  	:= p_pub_stop_rec.PROGRAM_UPDATE_DATE;
  x_pvt_stop_rec.REQUEST_ID			:= p_pub_stop_rec.REQUEST_ID;
  x_pvt_stop_rec.WSH_LOCATION_ID		:= FND_API.G_MISS_NUM;
  x_pvt_stop_rec.TRACKING_DRILLDOWN_FLAG  	:= FND_API.G_MISS_CHAR;
  x_pvt_stop_rec.TRACKING_REMARKS		:= FND_API.G_MISS_CHAR;
  x_pvt_stop_rec.CARRIER_EST_DEPARTURE_DATE 	:= FND_API.G_MISS_DATE;
  x_pvt_stop_rec.CARRIER_EST_ARRIVAL_DATE   	:= FND_API.G_MISS_DATE;
  x_pvt_stop_rec.LOADING_START_DATETIME   	:= FND_API.G_MISS_DATE;
  x_pvt_stop_rec.LOADING_END_DATETIME	 	:= FND_API.G_MISS_DATE;
  x_pvt_stop_rec.UNLOADING_START_DATETIME 	:= FND_API.G_MISS_DATE;
  x_pvt_stop_rec.UNLOADING_END_DATETIME   	:= FND_API.G_MISS_DATE;

  --x_pvt_stop_rec.ROWID				:= FND_API.G_MISS_CHAR;
  x_pvt_stop_rec.TRIP_NAME			:= p_pub_stop_rec.TRIP_NAME;
  x_pvt_stop_rec.STOP_LOCATION_CODE	   	:= p_pub_stop_rec.STOP_LOCATION_CODE;
  x_pvt_stop_rec.WEIGHT_UOM_DESC		:= p_pub_stop_rec.WEIGHT_UOM_DESC;
  x_pvt_stop_rec.VOLUME_UOM_DESC		:= p_pub_stop_rec.VOLUME_UOM_DESC;
  x_pvt_stop_rec.LOCK_STOP_ID			:= FND_API.G_MISS_NUM;
  x_pvt_stop_rec.PENDING_INTERFACE_FLAG   	:= FND_API.G_MISS_CHAR;
  x_pvt_stop_rec.TRANSACTION_HEADER_ID		:= FND_API.G_MISS_NUM;

  -- csun 10+ internal location change
  x_pvt_stop_rec.PHYSICAL_STOP_ID		:= p_pub_stop_rec.PHYSICAL_STOP_ID;
  x_pvt_stop_rec.PHYSICAL_LOCATION_ID		:= p_pub_stop_rec.PHYSICAL_LOCATION_ID;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_stoppub_to_grp',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                               SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END;


--========================================================================
-- PROCEDURE : Create_Update_Stop         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--		     p_stop_info             Attributes for the stop entity
--             p_trip_id               Trip id for update
--             p_trip_name             Trip name for update
--             p_stop_location_id      Stop location id for update
--             p_stop_location_code    Stop location code for update
--             p_planned_dep_date      Planned departure date for update
--  	          x_stop_id - stop id of new stop
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trip_stops table with information
--             specified in p_stop_info. Use p_trip_id, p_trip_name, p_stop_location_id,
--             p_stop_location_code or p_planned_dep_date to update these values
--             on an existing stop.
--========================================================================
PROCEDURE Create_Update_Stop
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_info	         IN OUT NOCOPY   Trip_Stop_Pub_Rec_Type,
    p_trip_id                IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_stop_location_id       IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_stop_location_code     IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_planned_dep_date       IN   DATE DEFAULT FND_API.G_MISS_DATE,
    x_stop_id                OUT NOCOPY   NUMBER) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Update_Stop';

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Stop';

l_pvt_stop_rec          WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;

l_in_rec   		WSH_TRIP_STOPS_GRP.stopInRecType;
l_rec_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_stop_out_tab          WSH_TRIP_STOPS_GRP.stop_out_tab_type;

l_commit	VARCHAR2(1):='F';
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
      wsh_debug_sv.push (l_module_name, 'Create_Update_Stop');
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_stoppub_to_pvt (
		p_pub_stop_rec => p_stop_info,
                x_pvt_stop_rec => l_pvt_stop_rec,
                x_return_status => x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'map_stoppub_to_pvt x_return_status',x_return_status);
   END IF;
   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trip_id IS NOT NULL) AND (p_trip_id <> FND_API.G_MISS_NUM) THEN
      l_pvt_stop_rec.trip_id := p_trip_id;
   END IF;

   IF (p_trip_name IS NOT NULL) AND (p_trip_name <> FND_API.G_MISS_CHAR) THEN
      l_pvt_stop_rec.trip_name := p_trip_name;
   END IF;

   IF (p_stop_location_id IS NOT NULL) AND (p_stop_location_id <> FND_API.G_MISS_NUM) THEN
      l_pvt_stop_rec.stop_location_id := p_stop_location_id;
   END IF;

   IF (p_stop_location_code IS NOT NULL) AND (p_stop_location_code <> FND_API.G_MISS_CHAR) THEN
      l_pvt_stop_rec.stop_location_code := p_stop_location_code;
   END IF;

   IF (p_planned_dep_date IS NOT NULL) AND (p_planned_dep_date <> FND_API.G_MISS_DATE)THEN
      l_pvt_stop_rec.planned_departure_date := p_planned_dep_date;
   END IF;

   -- bug 3666967 - treating non-passed parameters as FND_API.G_MISS_NUM
   IF (p_action_code = 'CREATE') THEN
      IF (l_pvt_stop_rec.departure_gross_weight = FND_API.G_MISS_NUM AND
          l_pvt_stop_rec.departure_net_weight = FND_API.G_MISS_NUM AND
          l_pvt_stop_rec.departure_volume = FND_API.G_MISS_NUM AND
          l_pvt_stop_rec.departure_fill_percent = FND_API.G_MISS_NUM) THEN
         l_pvt_stop_rec.wv_frozen_flag := 'N';
      ELSE
         l_pvt_stop_rec.wv_frozen_flag := 'Y';
      END IF;
   END IF;
   -- end bug 3666967

   l_in_rec.caller :='WSH_PUB';
   l_in_rec.phase  := 1;
   l_in_rec.action_code := p_action_code;

   l_rec_attr_tab(1):= l_pvt_stop_rec;

   WSH_INTERFACE_GRP.CREATE_UPDATE_STOP(
        p_api_version_number    => p_api_version_number,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => l_commit,
        p_in_rec                => l_in_rec,
        p_rec_attr_tab          => l_rec_attr_tab,
        x_stop_out_tab          => l_stop_out_tab,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'WSH_INTERFACE_GRP.CREATE_UPDATE_STOP x_return_status',x_return_status);
   END IF;

   IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_stop_out_tab.count > 0) THEN
       x_stop_id := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;
   END IF;


   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
     END IF;

  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
      FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Create_Update_Stop;

--Harmonizing Project **heali

END WSH_TRIP_STOPS_PUB;

/
