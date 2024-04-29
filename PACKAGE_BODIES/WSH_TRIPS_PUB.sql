--------------------------------------------------------
--  DDL for Package Body WSH_TRIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIPS_PUB" as
/* $Header: WSHTRPBB.pls 120.1 2005/07/28 10:26:15 parkhj noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_TRIPS_PUB';
-- add your constants here if any

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Trip_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Trip action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--		     p_trip_id               Trip identifier
--             p_trip_name             Trip name
--             p_wv_override_flag      Override flag for weight/volume calc
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing trip identified by p_trip_id or trip_name
--
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    p_report_set_name        IN   varchar2 ) IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Trip_Action';
  l_trip_out_rec       WSH_TRIPS_GRP.tripActionOutRecType;
  l_action_prms        WSH_TRIPS_GRP.action_parameters_rectype;
  l_entity_id_tab      wsh_util_core.id_tab_type;
  l_num_warning        NUMBER := 0;
  l_num_errors         NUMBER := 0;
  l_return_status      varchar2(1000);
  l_report_set_id      NUMBER;

l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                            || 'TRIP_ACTION';
  trip_action_error EXCEPTION;

  l_trip_id               NUMBER := p_trip_id;

  BEGIN
  --  Standard call to check for call compatibility
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
        wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
        wsh_debug_sv.log (l_module_name,'p_action_code',p_action_code);
        wsh_debug_sv.log (l_module_name,'p_trip_id',p_trip_id);
        wsh_debug_sv.log (l_module_name,'p_trip_name',p_trip_name);
        wsh_debug_sv.log (l_module_name,'p_wv_override_flag',
                                                      p_wv_override_flag);
        wsh_debug_sv.log (l_module_name,'p_report_set_name',
                                                      p_report_set_name);
     END IF;

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

  -- <begin procedure logic>


     wsh_util_validate.validate_trip_name( l_trip_id,
                                           p_trip_name,
                                           x_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        raise trip_action_error;
     END IF;

     IF p_report_set_name IS NOT NULL
      AND p_report_set_name <> fnd_api.G_MISS_CHAR
      AND p_action_code = 'PRINT-DOC-SETS' THEN
        WSH_UTIL_VALIDATE.validate_report_set(
                                p_report_set_id   => l_report_set_id,
                                p_report_set_name => p_report_set_name,
                                x_return_status   => x_return_status);

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'l_report_set_id',l_report_set_id);
        END IF;

        IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           raise trip_action_error;
        END IF;

        l_action_prms.report_set_id  := l_report_set_id;

     END IF;

     l_entity_id_tab(1) := l_trip_id;

     l_action_prms.action_code := p_action_code;
     l_action_prms.caller      := 'WSH_API';

     l_action_prms.override_flag      := p_wv_override_flag;

     WSH_INTERFACE_GRP.Trip_Action(
                      p_api_version_number => 1.0,
                      p_init_msg_list      => FND_API.G_FALSE,
                      p_commit             => FND_API.G_TRUE,
                      p_entity_id_tab      => l_entity_id_tab,
                      p_action_prms        => l_action_prms,
                      x_trip_out_rec       => l_trip_out_rec,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);

     wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

     x_return_status := l_return_status;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,p_encoded => FND_API.G_FALSE
     );

    IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
    END IF;


  EXCEPTION

	WHEN trip_action_error THEN
	   FND_MESSAGE.SET_NAME('WSH','WSH_OI_TRIP_ACTION_ERROR');
	   FND_MESSAGE.SET_TOKEN('TRIP_NAME', wsh_trips_pvt.get_name(l_trip_id));
	   FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('TRIP',p_action_code));
	   wsh_util_core.add_message(x_return_status,l_module_name);
           FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count
           , p_data  => x_msg_data
           ,p_encoded => FND_API.G_FALSE
           );
           IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name,'EXCEPTION:trip_action_error');
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;

     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_ERROR');
             WSH_DEBUG_SV.pop(l_module_name);
        END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_RET_STS_UNEXP_ERROR');
             WSH_DEBUG_SV.pop(l_module_name);
        END IF;

     WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_RET_STS_WARNING');
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
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Others',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  END Trip_Action;


--========================================================================
-- PROCEDURE : Trip_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_commit                FND_API.G_TRUE to commit
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_param_rec      Action Parameters Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--                                     'TRIP-CONFIRM'
--	       p_trip_id               Trip identifier
--             p_trip_name             Trip name
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_param_rec
--             on an existing trip identified by p_trip_id or trip_name
--
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    p_action_param_rec       IN   WSH_TRIPS_PUB.Action_Param_Rectype,
    p_trip_id                IN   NUMBER ,
    p_trip_name              IN   VARCHAR2 ) IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Trip_Action';
  l_trip_out_rec       WSH_TRIPS_GRP.tripActionOutRecType;
  l_action_prms        WSH_TRIPS_GRP.action_parameters_rectype;
  l_entity_id_tab      wsh_util_core.id_tab_type;
  l_num_warning        NUMBER := 0;
  l_num_errors         NUMBER := 0;
  l_return_status      varchar2(1000);
  l_report_set_id      NUMBER;

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                            || 'TRIP_ACTION';
  trip_action_error EXCEPTION;

  l_trip_id               NUMBER := p_trip_id;

  BEGIN
  --  Standard call to check for call compatibility
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
        wsh_debug_sv.log (l_module_name,'p_api_version_number', p_api_version_number);
        wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
        wsh_debug_sv.log (l_module_name,'p_commit',p_commit);
        wsh_debug_sv.log (l_module_name,'action_code',p_action_param_rec.action_code);
        wsh_debug_sv.log (l_module_name,'organization_id',p_action_param_rec.organization_id);
        wsh_debug_sv.log (l_module_name,'report_set_name',p_action_param_rec.report_set_name);
        wsh_debug_sv.log (l_module_name,'report_set_id',p_action_param_rec.report_set_id);
        wsh_debug_sv.log (l_module_name,'override_flag',p_action_param_rec.override_flag);
        wsh_debug_sv.log (l_module_name,'actual_date',p_action_param_rec.actual_date);
        wsh_debug_sv.log (l_module_name,'action_flag',p_action_param_rec.action_flag);
        wsh_debug_sv.log (l_module_name,'autointransit_flag',p_action_param_rec.autointransit_flag);
        wsh_debug_sv.log (l_module_name,'autoclose_flag',p_action_param_rec.autoclose_flag);
        wsh_debug_sv.log (l_module_name,'stage_del_flag',p_action_param_rec.stage_del_flag);
        wsh_debug_sv.log (l_module_name,'ship_method',p_action_param_rec.ship_method);
        wsh_debug_sv.log (l_module_name,'bill_of_lading_flag',p_action_param_rec.bill_of_lading_flag);
        wsh_debug_sv.log (l_module_name,'defer_interface_flag',p_action_param_rec.defer_interface_flag);
        wsh_debug_sv.log (l_module_name,'actual_departure_date',p_action_param_rec.actual_departure_date);
        wsh_debug_sv.log (l_module_name,'p_trip_id',p_trip_id);
        wsh_debug_sv.log (l_module_name,'p_trip_name',p_trip_name);
     END IF;

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

  -- <begin procedure logic>


     wsh_util_validate.validate_trip_name( l_trip_id,
                                           p_trip_name,
                                           x_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        raise trip_action_error;
     END IF;


     IF p_action_param_rec.report_set_name IS NOT NULL
      AND p_action_param_rec.report_set_name <> fnd_api.G_MISS_CHAR
      AND p_action_param_rec.action_code = 'PRINT-DOC-SETS' THEN
        WSH_UTIL_VALIDATE.validate_report_set(
                                p_report_set_id   => l_report_set_id,
                                p_report_set_name => p_action_param_rec.report_set_name,
                                x_return_status   => x_return_status);


        IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           raise trip_action_error;
        END IF;

        l_action_prms.report_set_id  := l_report_set_id;

     ELSE

        l_action_prms.report_set_id  := p_action_param_rec.report_set_id;

     END IF;

     IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_report_set_id',l_report_set_id);
     END IF;

     l_entity_id_tab(1) := l_trip_id;
     l_action_prms.action_code := p_action_param_rec.action_code;
     l_action_prms.caller      := 'WSH_API';

     l_action_prms.organization_id       := p_action_param_rec.organization_id;
     l_action_prms.override_flag         := p_action_param_rec.override_flag;
     l_action_prms.actual_date           := p_action_param_rec.actual_date;
     l_action_prms.action_flag           := p_action_param_rec.action_flag;
     l_action_prms.autointransit_flag    := p_action_param_rec.autointransit_flag;
     l_action_prms.autoclose_flag        := p_action_param_rec.autoclose_flag;
     l_action_prms.stage_del_flag        := p_action_param_rec.stage_del_flag;
     l_action_prms.ship_method           := p_action_param_rec.ship_method;
     l_action_prms.bill_of_lading_flag   := p_action_param_rec.bill_of_lading_flag;
     l_action_prms.defer_interface_flag  := p_action_param_rec.defer_interface_flag;
     l_action_prms.actual_departure_date := p_action_param_rec.actual_departure_date;

     WSH_INTERFACE_GRP.Trip_Action(
                      p_api_version_number => 1.0,
                      p_init_msg_list      => FND_API.G_FALSE,
                      p_commit             => FND_API.G_FALSE,
                      p_entity_id_tab      => l_entity_id_tab,
                      p_action_prms        => l_action_prms,
                      x_trip_out_rec       => l_trip_out_rec,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);

     wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

     x_return_status := l_return_status;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,p_encoded => FND_API.G_FALSE
     );

    IF FND_API.to_boolean(p_commit) AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       COMMIT;
    END IF;

    IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
    END IF;


  EXCEPTION

	WHEN trip_action_error THEN
	   FND_MESSAGE.SET_NAME('WSH','WSH_OI_TRIP_ACTION_ERROR');
	   FND_MESSAGE.SET_TOKEN('TRIP_NAME', wsh_trips_pvt.get_name(l_trip_id));
	   FND_MESSAGE.SET_TOKEN('ACTION',wsh_util_core.get_action_meaning('TRIP', p_action_param_rec.action_code));
	   wsh_util_core.add_message(x_return_status,l_module_name);
           FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count
           , p_data  => x_msg_data
           ,p_encoded => FND_API.G_FALSE
           );
           IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name,'EXCEPTION:trip_action_error');
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;

     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_ERROR');
             WSH_DEBUG_SV.pop(l_module_name);
        END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_RET_STS_UNEXP_ERROR');
             WSH_DEBUG_SV.pop(l_module_name);
        END IF;

     WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'EXCEPTION:G_RET_STS_WARNING');
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
        ,p_encoded => FND_API.G_FALSE
        );
        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Others',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  END Trip_Action;


--Harmonizing Project **heali
PROCEDURE map_trippub_to_pvt(
   p_pub_trip_rec IN WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE,
   x_pvt_trip_rec OUT NOCOPY WSH_TRIPS_PVT.TRIP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_TRIPPUB_TO_GRP';

l_return_status VARCHAR2(1);
l_num_warnings NUMBER;
l_num_errors   NUMBER;
l_freight_terms_code  VARCHAR2(30);

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
       WSH_DEBUG_SV.log(l_module_name,'p_pub_trip_rec.TRIP_ID',p_pub_trip_rec.TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_pub_trip_rec.NAME',p_pub_trip_rec.NAME);
   END IF;
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_trip_rec.TRIP_ID					  := p_pub_trip_rec.TRIP_ID;
  x_pvt_trip_rec.NAME						 := p_pub_trip_rec.NAME;
  x_pvt_trip_rec.PLANNED_FLAG				 := FND_API.G_MISS_CHAR;
  x_pvt_trip_rec.ARRIVE_AFTER_TRIP_ID		 := p_pub_trip_rec.ARRIVE_AFTER_TRIP_ID;
  x_pvt_trip_rec.STATUS_CODE				  := FND_API.G_MISS_CHAR;
  x_pvt_trip_rec.VEHICLE_ITEM_ID			  := p_pub_trip_rec.VEHICLE_ITEM_ID;
  x_pvt_trip_rec.VEHICLE_ORGANIZATION_ID	  := p_pub_trip_rec.VEHICLE_ORGANIZATION_ID;
  x_pvt_trip_rec.VEHICLE_NUMBER			   := p_pub_trip_rec.VEHICLE_NUMBER;
  x_pvt_trip_rec.VEHICLE_NUM_PREFIX		   := p_pub_trip_rec.VEHICLE_NUM_PREFIX;
  x_pvt_trip_rec.CARRIER_ID				   := p_pub_trip_rec.CARRIER_ID;
  x_pvt_trip_rec.SHIP_METHOD_CODE			 := p_pub_trip_rec.SHIP_METHOD_CODE;
  x_pvt_trip_rec.ROUTE_ID					 := p_pub_trip_rec.ROUTE_ID;
  x_pvt_trip_rec.ROUTING_INSTRUCTIONS		 := p_pub_trip_rec.ROUTING_INSTRUCTIONS;
  x_pvt_trip_rec.ATTRIBUTE_CATEGORY		   := p_pub_trip_rec.ATTRIBUTE_CATEGORY;
  x_pvt_trip_rec.ATTRIBUTE1				   := p_pub_trip_rec.ATTRIBUTE1;
  x_pvt_trip_rec.ATTRIBUTE2				   := p_pub_trip_rec.ATTRIBUTE2;
  x_pvt_trip_rec.ATTRIBUTE3				   := p_pub_trip_rec.ATTRIBUTE3;
  x_pvt_trip_rec.ATTRIBUTE4				   := p_pub_trip_rec.ATTRIBUTE4;
  x_pvt_trip_rec.ATTRIBUTE5				   := p_pub_trip_rec.ATTRIBUTE5;
  x_pvt_trip_rec.ATTRIBUTE6				   := p_pub_trip_rec.ATTRIBUTE6;
  x_pvt_trip_rec.ATTRIBUTE7				   := p_pub_trip_rec.ATTRIBUTE7;
  x_pvt_trip_rec.ATTRIBUTE8				   := p_pub_trip_rec.ATTRIBUTE8;
  x_pvt_trip_rec.ATTRIBUTE9				   := p_pub_trip_rec.ATTRIBUTE9;
  x_pvt_trip_rec.ATTRIBUTE10				  := p_pub_trip_rec.ATTRIBUTE10;
  x_pvt_trip_rec.ATTRIBUTE11				  := p_pub_trip_rec.ATTRIBUTE11;
  x_pvt_trip_rec.ATTRIBUTE12				  := p_pub_trip_rec.ATTRIBUTE12;
  x_pvt_trip_rec.ATTRIBUTE13				  := p_pub_trip_rec.ATTRIBUTE13;
  x_pvt_trip_rec.ATTRIBUTE14				  := p_pub_trip_rec.ATTRIBUTE14;
  x_pvt_trip_rec.ATTRIBUTE15				  := p_pub_trip_rec.ATTRIBUTE15;
  x_pvt_trip_rec.CREATION_DATE				:= p_pub_trip_rec.CREATION_DATE;
  x_pvt_trip_rec.CREATED_BY				   := p_pub_trip_rec.CREATED_BY;
  x_pvt_trip_rec.LAST_UPDATE_DATE			 := p_pub_trip_rec.LAST_UPDATE_DATE;
  x_pvt_trip_rec.LAST_UPDATED_BY			  := p_pub_trip_rec.LAST_UPDATED_BY;
  x_pvt_trip_rec.LAST_UPDATE_LOGIN			:= p_pub_trip_rec.LAST_UPDATE_LOGIN;
  x_pvt_trip_rec.PROGRAM_APPLICATION_ID	   := p_pub_trip_rec.PROGRAM_APPLICATION_ID;
  x_pvt_trip_rec.PROGRAM_ID				   := p_pub_trip_rec.PROGRAM_ID;
  x_pvt_trip_rec.PROGRAM_UPDATE_DATE		  := p_pub_trip_rec.PROGRAM_UPDATE_DATE;
  x_pvt_trip_rec.REQUEST_ID				   := p_pub_trip_rec.REQUEST_ID;
  x_pvt_trip_rec.SERVICE_LEVEL				:= p_pub_trip_rec.SERVICE_LEVEL;
  x_pvt_trip_rec.MODE_OF_TRANSPORT			:= p_pub_trip_rec.MODE_OF_TRANSPORT;

  IF p_pub_trip_rec.freight_terms_name <> FND_API.G_MISS_CHAR
     AND p_pub_trip_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
           --
      l_freight_terms_code := NULL;
      wsh_util_validate.validate_freight_terms(
        p_freight_terms_code  => l_freight_terms_code,
        p_freight_terms_name  => p_pub_trip_rec.freight_terms_name,
        x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_freight_terms',l_return_status);
      END IF;
      --
      WSH_UTIL_CORE.api_post_call(
        p_return_status     => l_return_status,
        x_num_warnings      => l_num_warnings,
        x_num_errors        => l_num_errors);
      --
  ELSE
     IF p_pub_trip_rec.freight_terms_name IS NULL
        AND p_pub_trip_rec.freight_Terms_code = FND_API.G_MISS_CHAR THEN
       l_freight_terms_code := NULL;
     ELSE
       l_freight_terms_code := p_pub_trip_rec.freight_terms_code;
     END IF;
  END IF;

  x_pvt_trip_rec.FREIGHT_TERMS_CODE		   := l_freight_terms_code;
  x_pvt_trip_rec.CONSOLIDATION_ALLOWED		:= FND_API.G_MISS_CHAR;
  x_pvt_trip_rec.LOAD_TENDER_STATUS		   := FND_API.G_MISS_CHAR;
  x_pvt_trip_rec.ROUTE_LANE_ID				:= FND_API.G_MISS_NUM;
  x_pvt_trip_rec.LANE_ID					  := FND_API.G_MISS_NUM;
  x_pvt_trip_rec.SCHEDULE_ID				  := FND_API.G_MISS_NUM;
  x_pvt_trip_rec.BOOKING_NUMBER			   := FND_API.G_MISS_CHAR;
  --x_pvt_trip_rec.ROWID				:= FND_API.G_MISS_CHAR;
  x_pvt_trip_rec.ARRIVE_AFTER_TRIP_NAME	   := p_pub_trip_rec.ARRIVE_AFTER_TRIP_NAME;
  x_pvt_trip_rec.SHIP_METHOD_NAME			 := p_pub_trip_rec.SHIP_METHOD_NAME;
  x_pvt_trip_rec.VEHICLE_ITEM_DESC			:= p_pub_trip_rec.VEHICLE_ITEM_DESC;
  x_pvt_trip_rec.VEHICLE_ORGANIZATION_CODE	:= p_pub_trip_rec.VEHICLE_ORGANIZATION_CODE;
  x_pvt_trip_rec.OPERATOR	:= p_pub_trip_rec.OPERATOR;
  x_pvt_trip_rec.SEAL_CODE      := p_pub_trip_rec.SEAL_CODE;
  x_pvt_trip_rec.CARRIER_REFERENCE_NUMBER := p_pub_trip_rec.CARRIER_REFERENCE_NUMBER;
  x_pvt_trip_rec.CONSIGNEE_CARRIER_AC_NO := p_pub_trip_rec.CONSIGNEE_CARRIER_AC_NO;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- caller will handle this exception
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        -- caller will handle this exception

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
--

  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_trippub_to_pvt',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END;


--========================================================================
-- PROCEDURE : Create_Update_Trip      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--		     p_trip_info             Attributes for the trip entity
--             p_trip_name             Trip name for update
--  	          x_trip_id               Trip id of new trip
--  	          x_trip_name             Trip name of new trip
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trips table with information
--             specified in p_trip_info
--========================================================================

PROCEDURE Create_Update_Trip
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_info          IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_trip_id                OUT NOCOPY   NUMBER,
    x_trip_name              OUT NOCOPY   VARCHAR2) IS

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Trip';

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Update_Trip';

l_commit	VARCHAR2(1):='F';

l_pvt_trip_rec          WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_trip_info_tab         WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_out_tab               WSH_TRIPS_GRP.trip_out_tab_type;
l_in_rec                WSH_TRIPS_GRP.TripInRecType;

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
      wsh_debug_sv.push (l_module_name, 'Create_Update_Trip');
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_trippub_to_pvt (
                p_pub_trip_rec => p_trip_info,
                x_pvt_trip_rec => l_pvt_trip_rec,
                x_return_status => x_return_status);

   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   l_in_rec.caller:='WSH_PUB';
   l_in_rec.phase:= 1;
   l_in_rec.action_code:= p_action_code;

   IF (p_trip_name IS NOT NULL) AND (p_trip_name <> FND_API.G_MISS_CHAR) THEN
      l_pvt_trip_rec.name := p_trip_name;
   END IF;

   IF (l_pvt_trip_rec.name IS NOT NULL AND l_pvt_trip_rec.name <>  FND_API.G_MISS_CHAR
                                       and l_in_rec.action_code <> 'CREATE') THEN
      wsh_util_validate.validate_trip_name( l_pvt_trip_rec.trip_id,
                                         l_pvt_trip_rec.name,
                                         x_return_status);

       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;
   END IF;

   IF (l_pvt_trip_rec.arrive_after_trip_name IS NOT NULL
                                         AND l_pvt_trip_rec.arrive_after_trip_name <> FND_API.G_MISS_CHAR) THEN
      wsh_util_validate.validate_trip_name( l_pvt_trip_rec.arrive_after_trip_id,
                                         l_pvt_trip_rec.arrive_after_trip_name,
                                         x_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_trip_info_tab(1):= l_pvt_trip_rec;

   WSH_INTERFACE_GRP.Create_Update_Trip(
        p_api_version_number     => p_api_version_number,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => l_commit,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_trip_info_tab          => l_trip_info_tab,
        p_In_rec                 => l_In_rec,
        x_Out_tab                => l_Out_Tab);

    IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'WSH_INTERFACE_GRP.Create_Update_Trip x_return_status',x_return_status);
    END IF;
    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS and l_Out_Tab.count > 0) THEN
       x_trip_id := l_out_tab(l_out_tab.FIRST).trip_id;
       x_trip_name := l_out_tab(l_out_tab.FIRST).trip_name;
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

END Create_Update_Trip;
--Harmonizing Project **heali


END WSH_TRIPS_PUB;

/
