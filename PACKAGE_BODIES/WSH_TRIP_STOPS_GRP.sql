--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_STOPS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_STOPS_GRP" as
/* $Header: WSHSTGPB.pls 120.6 2007/01/05 19:24:49 parkhj noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_TRIP_STOPS_GRP';
-- add your constants here if any

-- Forward declaration
  PROCEDURE Lock_Related_Entity
  (
    p_action_prms            IN   action_parameters_rectype,
    p_stop_attr_tab          IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    x_valid_ids_tab          OUT  NOCOPY WSH_UTIL_CORE.id_Tab_Type,
    x_return_status          OUT  NOCOPY VARCHAR2
   );

 PROCEDURE Add_to_Delete_List(
    p_stop_tab          IN  WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab,
    p_caller            IN VARCHAR2,
    x_stop_delete_tab   OUT NOCOPY wsh_util_core.id_tab_type,
    x_trip_affected_tab OUT NOCOPY wsh_util_core.id_tab_type,
    x_return_status     OUT NOCOPY VARCHAR2) ;
--===================
-- PROCEDURES
--===================

--========================================================================
-- THIS PROCEDURE WOULD BE OBSOLETE SOON
--
-- PROCEDURE : Stop_Action_new         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_stop_info             Attributes for the stop entity
--             p_stop_IN_rec           Input Attributes for the stop entity
--             p_stop_OUT_rec          Output Attributes for the stop entity
--             p_action_code           Stop action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'ARRIVE','CLOSE'
--                                     'PICK-RELEASE'
--                                     'DELETE'
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing stop identified by p_stop_id or a unique combination of
--             trip_id/trip_name, stop_location_id/stop_location_code or planned_departure_date.These are part of p_stop_info
--
--========================================================================

  PROCEDURE Stop_Action_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_stop_info              IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_stop_IN_rec            IN  stopActionInRecType,
    x_stop_OUT_rec           OUT NOCOPY  stopActionOutRecType) IS


  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Stop_Action';
  l_stop_id               NUMBER := p_stop_info.stop_id;
  l_trip_id               NUMBER := p_stop_info.trip_id;
  l_stop_location_id      NUMBER := p_stop_info.stop_location_id;
  l_return_status         varchar2(1);
  l_num_errors            NUMBER;
  l_num_warning           NUMBER;


  -- <insert here your local variables declaration>

  l_stop_rows  wsh_util_core.id_tab_type;
  l_action_prms  WSH_TRIP_STOPS_GRP.action_parameters_rectype;

  l_encoded VARCHAR2(1) := 'F';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'STOP_ACTION_NEW';
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
    wsh_debug_sv.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'action_code',p_stop_IN_rec.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list );
    WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
    WSH_DEBUG_SV.log(l_module_name,'trip_id', p_stop_info.trip_id);
    WSH_DEBUG_SV.log(l_module_name,'trip_id', p_stop_info.trip_id);
    WSH_DEBUG_SV.log(l_module_name,'stop_location_id', p_stop_info.stop_location_id);
    WSH_DEBUG_SV.log(l_module_name,'planned_arrival_date', p_stop_info.planned_arrival_date);
    WSH_DEBUG_SV.log(l_module_name,'planned_departure_date', p_stop_info.planned_departure_date);
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

     wsh_util_validate.validate_trip_name(
                                          l_trip_id,
                                          p_stop_info.trip_name,
                                          l_return_status);

    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

      -- Stop location id can be -1 for inbound stops
      -- in such case, we do not need to call validate location, as it wil fail
      -- in turn preventing any action on stops
      --
      IF l_stop_location_id  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID   -- J-IB-NPARIKH
      OR l_stop_location_id  IS NULL
      THEN
          wsh_util_validate.validate_location(
                                        l_stop_location_id,
                                        p_stop_info.stop_location_code,
                                        l_return_status);

          wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
      END IF;

    wsh_util_validate.validate_stop_name(
                                          l_stop_id,
                                          l_trip_id,
                                          l_stop_location_id,
                                          p_stop_info.planned_departure_date,
                                          l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_stop_id', l_stop_id);
    END IF;

    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

    IF (l_stop_id IS NULL) THEN
         raise FND_API.G_EXC_ERROR;
    END IF;

     l_stop_rows(1) := p_stop_info.stop_id;
     l_action_prms.caller := 'WSH_API';
     l_action_prms.action_code := p_stop_IN_rec.action_code;
     --l_action_prms.status_code := p_stop_info.STATUS_CODE;
     l_action_prms.actual_date    := p_stop_IN_rec.actual_date;
     l_action_prms.defer_interface_flag := p_stop_IN_rec.defer_interface_flag;

     wsh_interface_grp.stop_action(
        p_api_version_number  => p_api_version_number,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => p_commit,
        p_entity_id_tab       => l_stop_rows,
        p_action_prms         => l_action_prms,
        x_stop_out_rec        => x_stop_OUT_rec,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);

     FND_MSG_PUB.Count_And_Get
     ( p_encoded => l_encoded
     , p_count => x_msg_count
     , p_data  => x_msg_data
     );
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
     END IF;
  EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
	   FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
	   FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_stop_IN_rec.action_code));
	   wsh_util_core.add_message(x_return_status,l_module_name);
           FND_MSG_PUB.Count_And_Get
            ( p_encoded => l_encoded
            , p_count => x_msg_count
            , p_data  => x_msg_data
            );
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_stop_id', l_stop_id);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_EXC_ERROR ');
           END IF;


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
        FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
	FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_stop_IN_rec.action_code));
        wsh_util_core.add_message(x_return_status,l_module_name);
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
         ( p_encoded => l_encoded
         , p_count => x_msg_count
         , p_data  => x_msg_data
         );
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
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
         ( p_encoded => l_encoded
         , p_count => x_msg_count
         , p_data  => x_msg_data
         );
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
  END Stop_Action_New;


--========================================================================
-- PROCEDURE : Stop_Action         PUBLIC
-- THIS PROCEDURE WOULD BE OBSOLETE SOON
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

  -- <insert here your local variables declaration>

  l_stop_rows  wsh_util_core.id_tab_type;


  l_stop_id               NUMBER := p_stop_id;
  l_trip_id               NUMBER := p_trip_id;
  l_stop_location_id      NUMBER := p_stop_location_id;

  l_return_status         VARCHAR2(1);
  l_num_errors            NUMBER;
  l_num_warning           NUMBER;

  l_stop_OUT_rec          stopActionOutRecType;
  l_action_prms  WSH_TRIP_STOPS_GRP.action_parameters_rectype;

  l_encoded VARCHAR2(1) := 'F';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'STOP_ACTION';
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
     wsh_debug_sv.push (l_module_name);
     wsh_debug_sv.log (l_module_name,'p_action_code',p_action_code);
     wsh_debug_sv.log (l_module_name,'p_stop_id',p_stop_id);
     wsh_debug_sv.log (l_module_name,'p_trip_id',p_trip_id);
     wsh_debug_sv.log (l_module_name,'p_trip_name',p_trip_name);
     wsh_debug_sv.log (l_module_name,'p_stop_location_id',p_stop_location_id);
     wsh_debug_sv.log (l_module_name,'p_stop_location_code',p_stop_location_code);
     wsh_debug_sv.log (l_module_name,'p_planned_dep_date',p_planned_dep_date);
     wsh_debug_sv.log (l_module_name,'p_actual_date',p_actual_date);
     wsh_debug_sv.log (l_module_name,'p_defer_interface_flag',p_defer_interface_flag);
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

     wsh_util_validate.validate_trip_name(
                                          l_trip_id,
                                          p_trip_name,
                                          l_return_status);

    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

      -- Stop location id can be -1 for inbound stops
      -- in such case, we do not need to call validate location, as it wil fail
      -- in turn preventing any action on stops
      --
      IF l_stop_location_id  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID   -- J-IB-NPARIKH
      OR l_stop_location_id  IS NULL
      THEN
          wsh_util_validate.validate_location(
                                        l_stop_location_id,
                                        p_stop_location_code,
                                        l_return_status);

          wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
      END IF;

    wsh_util_validate.validate_stop_name(
                                          l_stop_id,
                                          l_trip_id,
                                          l_stop_location_id,
                                          p_planned_dep_date,
                                          l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_stop_id', l_stop_id);
    END IF;

    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

    IF (l_stop_id IS NULL) THEN
         raise FND_API.G_EXC_ERROR;
    END IF;
     l_stop_rows(1) := p_stop_id;
     l_action_prms.caller := 'WSH_API';
     l_action_prms.action_code := p_action_code;
     l_action_prms.actual_date    := p_actual_date;
     l_action_prms.defer_interface_flag := p_defer_interface_flag;

     wsh_interface_grp.stop_action(
        p_api_version_number  => p_api_version_number,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_TRUE,
        p_entity_id_tab       => l_stop_rows,
        p_action_prms         => l_action_prms,
        x_stop_out_rec        => l_stop_OUT_rec,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);


     FND_MSG_PUB.Count_And_Get
     ( p_encoded => l_encoded
     , p_count => x_msg_count
     , p_data  => x_msg_data
     );
     IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
     END IF;
  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
        FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
        FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_action_code));
        wsh_util_core.add_message(x_return_status,l_module_name);
        FND_MSG_PUB.Count_And_Get
        ( p_encoded => l_encoded
        , p_count => x_msg_count
        , p_data  => x_msg_data
        );
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
         END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_STOP_ACTION_ERROR');
        FND_MESSAGE.SET_TOKEN('STOP_NAME', wsh_trip_stops_pvt.get_name(l_stop_id));
        FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('STOP',p_action_code));
        wsh_util_core.add_message(x_return_status,l_module_name);
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_encoded => l_encoded
        , p_count => x_msg_count
        , p_data  => x_msg_data
        );
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
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
        ( p_encoded => l_encoded
        , p_count => x_msg_count
        , p_data  => x_msg_data
        );
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

  END Stop_Action;

/*-----------------------------------------------

  PROCEDURE Stop_Action
  This is the internal group API

-----------------------------------------------*/

PROCEDURE Stop_Action
(   p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_action_prms            IN   action_parameters_rectype,
    p_rec_attr_tab           IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    x_stop_out_rec           OUT  NOCOPY stopActionOutRecType,
    x_def_rec                OUT  NOCOPY   default_parameters_rectype,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)

IS
  l_stop_id_tab             wsh_util_core.id_tab_type;
-- for load tender add l_trip_id_tab
  l_trip_id_tab             wsh_util_core.id_tab_type;
  l_error_ids               wsh_util_core.id_tab_type;
  l_dummy_ids               wsh_util_core.id_tab_type;
  l_dummy_doc_param         WSH_DOCUMENT_SETS.DOCUMENT_SET_TAB_TYPE;
  l_num                     NUMBER;
  l_stop_rec_tab            wsh_trip_stops_validations.stop_rec_tab_type;
  l_first                   NUMBER;
  l_next                    NUMBER;
  l_last                    NUMBER;
  l_stop_id                 NUMBER;
  l_is_installed            VARCHAR2(10);
  l_valid_index_tab         wsh_util_core.id_tab_type;
  l_valid_id_tab            wsh_util_core.id_tab_type;
  l_valid_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
  l_num_warning             NUMBER := 0;
  l_num_errors              NUMBER := 0;
  l_return_status           VARCHAR2(500);
  l_trip_rec                WSH_TRIPS_PVT.trip_rec_type;
  l_stop_rec                WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30):= 'Stop_Action';
  l_counter                 NUMBER;
  l_report_set_id           NUMBER := p_action_prms.report_set_id;
  l_status_code             VARCHAR2(50)  := 'OP' ;

l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                            || 'STOP_ACTION';
  l_isWshLocation           BOOLEAN DEFAULT FALSE;
  e_req_field               EXCEPTION;
  --Bugfix 4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags BOOLEAN;


--Compatibility Changes
    l_cc_validate_result          VARCHAR2(1);
    l_cc_failed_records           WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_line_groups              WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_cc_group_info               WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    b_cc_linefailed               boolean;
    l_stop_id_tab_t               wsh_util_core.id_tab_type;
    l_cc_stop_id_tab              wsh_util_core.id_tab_type;
    l_cc_count_success            NUMBER;
    l_cc_del_attr_tab             WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab             wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab            WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab            WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids                   wsh_util_core.id_tab_type;
    l_cc_fail_ids                 wsh_util_core.id_tab_type;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
--Compatibility Changes
    l_stop_delete_tab             wsh_util_core.id_tab_type;
    l_trip_affected_tab           wsh_util_core.id_tab_type;
    l_success_trip_tab            wsh_util_core.id_tab_type;
    l_delete_tmp_tab              WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab;
    l_delete_t                    WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab;

    CURSOR c_check_trip_close (p_trip_id IN NUMBER) IS
    SELECT trip_id
    FROM WSH_TRIPS
    WHERE trip_id=p_trip_id
    AND status_code='IT'
    AND NOT EXISTS (select 'x'
                    from wsh_trip_stops
                    where trip_id=p_trip_id
                    and status_code IN ('OP', 'AR')
                    and rownum=1);
    l_trip_in_rec WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type;

-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
-- K LPN CONV. rv

 l_actual_date  Date;

 -- OTM R12 : packing ECO
 l_gc3_is_installed  VARCHAR2(1);
 -- End of OTM R12 : packing ECO


BEGIN
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
     WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
     WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   SAVEPOINT s_stop_action_grp;
   IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.log (l_module_name,'p_api_version_number',
                                                        p_api_version_number);
       wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
       wsh_debug_sv.log (l_module_name,'p_commit',p_commit);
       wsh_debug_sv.log (l_module_name,'action_code',p_action_prms.action_code);
       wsh_debug_sv.log (l_module_name,'caller',p_action_prms.caller);
       wsh_debug_sv.log (l_module_name,'COUNT',p_rec_attr_tab.COUNT);
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
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


   IF p_action_prms.action_code IS NULL THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_action_prms.action_code');
       RAISE e_req_field;
   ELSIF p_action_prms.caller IS NULL  THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_action_prms.caller');
       RAISE e_req_field;
   ELSIF p_rec_attr_tab.COUNT = 0  THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_rec_attr_tab.COUNT');
       RAISE e_req_field;
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_action_prms.caller IN ( 'WSH_FSTRX', 'WSH_TPW_INBOUND')
     OR p_action_prms.caller LIKE 'FTE%' THEN
       l_isWshLocation := TRUE;
   END IF;

   l_next := p_rec_attr_tab.FIRST;

   WHILE l_next IS NOT NULL LOOP
      l_stop_id_tab(l_next) := p_rec_attr_tab(l_next).stop_id;
      l_stop_rec_tab(l_next).stop_id := p_rec_attr_tab(l_next).stop_id;
      l_stop_rec_tab(l_next).status_code := p_rec_attr_tab(l_next).status_code;
-- J inbound logistics. populate new column shipments_type_flag jckwok
      l_stop_rec_tab(l_next).shipments_type_flag := p_rec_attr_tab(l_next).shipments_type_flag;
-- csun 10+ internal location change
      l_delete_tmp_tab(l_next).stop_id := p_rec_attr_tab(l_next).stop_id;
      l_delete_tmp_tab(l_next).trip_id := p_rec_attr_tab(l_next).trip_id;

/* If one of the lines has status code of 'AR' then this is going to be
   used for defaulting, else if there are lines with status code of 'OP' Then
   Use thar for defaulting
   bsadri
*/
      IF l_status_code <> 'AR' THEN
         --
         IF p_rec_attr_tab(l_next).status_code = 'AR' OR
            p_rec_attr_tab(l_next).status_code = 'OP' THEN
             --
             l_status_code := p_rec_attr_tab(l_next).status_code;
             --
         END IF;
         --
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'stop_id',
                                              p_rec_attr_tab(l_next).stop_id);
        wsh_debug_sv.log (l_module_name,'status_code',
                                          p_rec_attr_tab(l_next).status_code);
      END IF;
      l_next := p_rec_attr_tab.NEXT(l_next);
   END LOOP;


   WSH_ACTIONS_LEVELS.set_validation_level (
                                  p_entity   =>  'STOP',
                                  p_caller   =>  p_action_prms.caller,
                                  p_phase    =>  p_action_prms.phase,
                                  p_action   =>p_action_prms.action_code ,
                                  x_return_status => l_return_status);


   wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_STOP_NAME_LVL) = 1  THEN
     -- validate the stops are eligible for action.
     l_next := p_rec_attr_tab.FIRST;
     --
     WHILE l_next IS NOT NULL LOOP
       l_stop_id := p_rec_attr_tab(l_next).stop_id;
       WSH_UTIL_VALIDATE.Validate_Stop_Name (
                p_stop_id       => l_stop_id,
 		p_trip_id       => p_rec_attr_tab(l_next).trip_id,
                p_stop_location_id => NULL,  -- not needed
                p_planned_dep_date => NULL,  -- not needed
		x_return_status => l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Stop_Name l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);

       l_next := p_rec_attr_tab.NEXT(l_next);
     END LOOP;
     --
   END IF;

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
      WSH_TRIP_STOPS_validations.Is_Action_Enabled(
                p_stop_rec_tab            => l_stop_rec_tab,
                p_action                  => p_action_prms.action_code,
                p_caller                  => p_action_prms.caller,
                x_return_status           => l_return_status,
                x_valid_ids               => l_valid_id_tab ,
                x_error_ids               => l_error_ids ,
                x_valid_index_tab         => l_valid_index_tab);
      wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                  x_num_warnings     =>l_num_warning,
                                  x_num_errors       =>l_num_errors,
                                  p_msg_data         => NULL,
                                  p_raise_error_flag => FALSE);

   END IF;
   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RECORDS_LVL) = 1  THEN
    IF  NOT (    p_action_prms.caller = 'WSH_FSTRX'
              AND p_action_prms.action_code =  'DELETE'
             )  THEN --BUG 4354579
      WSH_TRIP_STOPS_PVT.Lock_Trip_Stop(
                             p_rec_attr_tab=>p_rec_attr_tab,
                             p_caller=>p_action_prms.caller,
                             p_valid_index_tab  =>l_valid_index_tab,
                             x_valid_ids_tab    =>x_stop_out_rec.valid_ids_tab,
                             x_return_status=>l_return_status);

      wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors,
                                   p_msg_data         => NULL,
                                   p_raise_error_flag => FALSE);
    END IF;
   END IF;



   IF(l_num_errors >0 ) THEN
     --{
     x_return_status := wsh_util_core.g_ret_sts_error;
     --
     IF (p_action_prms.caller = 'WSH_FSTRX') THEN
       FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION');
       wsh_util_core.add_message(x_return_status,l_module_name);
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION');
     END IF;
     --
     RAISE FND_API.G_EXC_ERROR;
     --}
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_num_warning',l_num_warning);
   END IF;


   IF l_num_warning > 0 AND p_action_prms.caller = 'WSH_FSTRX' THEN
         x_stop_out_rec.selection_issue_flag := 'Y';
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'C_STOP_DEFAULTS_LVL', WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_STOP_DEFAULTS_LVL));
   END IF;

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_STOP_DEFAULTS_LVL)=1 THEN
      IF l_status_code = 'OP' THEN
        x_def_rec.date_field := 'STOP.ACTUAL_ARRIVAL_DATE';
        x_def_rec.status_code := 'AR';
        x_def_rec.status_name := 'Arrived';
        x_def_rec.stop_action := 'ARRIVE';
        IF l_num_warning > 0 THEN
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSE
           --Bugfix 4070732 {      Phase 1 just call the rest API
           IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                  IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => x_return_status);

                  IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
                  END IF;
               END IF;
           END IF;
           --}
           IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
        END IF;
      ELSIF l_status_code = 'AR' THEN
        x_def_rec.date_field := 'STOP.ACTUAL_DEPARTURE_DATE';
        x_def_rec.status_code := 'CL';
        x_def_rec.status_name := 'Closed';
        x_def_rec.stop_action := 'CLOSE';
        IF l_num_warning > 0 THEN
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSE
           --Bugfix 4070732 {       Phase one just call the reset API
           IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                  IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => x_return_status);

                  IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
                  END IF;

               END IF;
           END IF;
           --}
           IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
        END IF;
      END IF;
    END IF;

    IF l_num_warning > 0 THEN
       --{
       x_return_status := wsh_util_core.g_ret_sts_warning;
       --
       FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION_WARN');
       wsh_util_core.add_message(x_return_status,l_module_name);
       --
       IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION_WARN');
       END IF;
       --
       IF p_action_prms.caller = 'WSH_FSTRX' THEN
         RAISE WSH_UTIL_CORE.G_EXC_WARNING;
       ELSE
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       --}
    END IF;

    l_stop_id := p_rec_attr_tab(p_rec_attr_tab.first).stop_id;

    IF p_action_prms.action_code IN ('UPDATE-STATUS', 'PRINT-DOC-SETS')
    AND nvl(p_action_prms.phase,1) = 1
    AND p_action_prms.caller = 'WSH_FSTRX'
    THEN
      --Bugfix 4070732 {       Phase 1 need to call the reset API only
      l_return_status := NULL;
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => x_return_status);

            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
            END IF;

         END IF;
      END IF;
      --}
      x_return_status := NVL(l_return_status, WSH_UTIL_CORE.G_RET_STS_SUCCESS);
      RETURN; -- Non-Generic Actions.
    END IF;


   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_CONSTRAINTS_LVL) = 1  THEN --{
    --Compatiblity Changes
    --for autocreatetrip or if assign trip and caller is STF, phase=2



    IF wsh_util_core.fte_is_installed='Y' THEN

      WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
       p_api_version_number =>  p_api_version_number,
       p_init_msg_list      =>  FND_API.G_FALSE,
       p_entity_type        =>  'S',
       p_target_id          =>  null,
       p_action_code        =>  p_action_prms.action_code,
       p_del_attr_tab       =>  l_cc_del_attr_tab,
       p_det_attr_tab       =>  l_cc_det_attr_tab,
       p_trip_attr_tab      =>  l_cc_trip_attr_tab,
       p_stop_attr_tab      =>  p_rec_attr_tab,
       p_in_ids             =>  l_cc_stop_id_tab,
       x_fail_ids           =>  l_cc_fail_ids,
       x_validate_result    =>  l_cc_validate_result,
       x_failed_lines       =>  l_cc_failed_records,
       x_line_groups        =>  l_cc_line_groups,
       x_group_info         =>  l_cc_group_info,
       x_msg_count          =>  l_msg_count,
       x_msg_data           =>  l_msg_data,
       x_return_status      =>  l_return_status);


      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_fail_ids.COUNT);
      END IF;
      --

      IF l_return_status=wsh_util_core.g_ret_sts_error THEN
        --fix l_rec_attr_tab to have only successful records
        l_cc_count_success:=1;

        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'l_stop_id_tab.count before removing failed lines',l_stop_id_tab.COUNT);
        END IF;

        IF l_cc_fail_ids.COUNT>0 AND l_stop_id_tab.COUNT>0 THEN

          --set return_status as warning
          IF l_cc_fail_ids.COUNT<>l_stop_id_tab.COUNT THEN
             l_return_status:=wsh_util_core.g_ret_sts_warning;
          END IF;

          FOR i in l_stop_id_tab.FIRST..l_stop_id_tab.LAST LOOP
            b_cc_linefailed:=FALSE;

            FOR j in l_cc_fail_ids.FIRST..l_cc_fail_ids.LAST LOOP
              IF (l_stop_id_tab(i)=l_cc_fail_ids(j)) THEN
                b_cc_linefailed:=TRUE;
                FND_MESSAGE.SET_NAME('WSH','WSH_STOP_DELETE_ERROR');
                --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	        END IF;
--tkt
                FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(l_cc_fail_ids(j),p_action_prms.caller));
                wsh_util_core.add_message(l_return_status);
              END IF;
            END LOOP;

            IF (NOT(b_cc_linefailed)) THEN
              l_stop_id_tab_t(l_cc_count_success):=l_stop_id_tab(i);
              l_cc_count_success:=l_cc_count_success+1;

              -- csun 10+ internal location change
              l_delete_t(l_cc_count_success).stop_id := l_delete_tmp_tab(i).stop_id;
              l_delete_t(l_cc_count_success).trip_id := l_delete_tmp_tab(i).trip_id;
            END IF;
          END LOOP;

          IF l_stop_id_tab_t.COUNT>0 THEN
            l_stop_id_tab:=l_stop_id_tab_t;
            -- csun 10+ internal location change
            l_delete_tmp_tab := l_delete_t;
          ELSE
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'all lines errored in compatibility check');
            END IF;
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warning,
              x_num_errors       => l_num_errors,
              p_msg_data         => l_msg_data);

          END IF;
        END IF;

      ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
        wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warning,
           x_num_errors       => l_num_errors,
           p_msg_data         => l_msg_data);
      END IF;

      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warning,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data,
        p_raise_error_flag => FALSE);
    END IF;
    --Compatiblity Changes
   END IF ; --}

    -- jckwok: Bug 2684692 added the below case
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RELATED_ENTITIES_LVL) = 1
      AND p_action_prms.stop_action = 'CLOSE'
    THEN

          Lock_Related_Entity(
             p_action_prms            => p_action_prms,
             p_stop_attr_tab          => p_rec_attr_tab,
             x_valid_ids_tab          => l_stop_id_tab,
             x_return_status          => l_return_status);

       if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'l_stop_id_tab count', l_stop_id_tab.count);
       end if;

        wsh_util_core.api_post_call(  p_return_status  =>l_return_status,
                                      x_num_warnings   =>l_num_warning,
                                      x_num_errors     =>l_num_errors);

   END IF;

    IF p_action_prms.action_code = 'PLAN' THEN
       WSH_TRIP_STOPS_ACTIONS.plan (
              p_stop_rows      => l_stop_id_tab,
              p_action         => 'PLAN',
--tkt
              p_caller         => p_action_prms.caller,
              x_return_status  => l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);
    ELSIF p_action_prms.action_code = 'UNPLAN' THEN
       WSH_TRIP_STOPS_ACTIONS.plan (
              p_stop_rows      => l_stop_id_tab,
              p_action         => 'UNPLAN',
--tkt
              p_caller         => p_action_prms.caller,
              x_return_status  => l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);

    ELSIF p_action_prms.action_code = 'PICK-RELEASE' THEN
       WSH_PICK_LIST.Launch_Pick_Release(
              p_trip_ids       => l_dummy_ids,
              p_stop_ids       => l_stop_id_tab,
              p_delivery_ids   => l_dummy_ids,
              p_detail_ids     => l_dummy_ids,
              x_request_ids    => x_stop_out_rec.result_id_tab,
              x_return_status  => l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);

    ELSIF p_action_prms.action_code = 'PRINT-DOC-SETS' THEN
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DOCUMENT_SETS_LVL)=1 THEN
           IF l_report_set_id IS NULL THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_DOC_MISSING');
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
             IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name,'WSH_DOC_MISSING');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          WSH_UTIL_VALIDATE.validate_report_set(
                           p_report_set_id   => l_report_set_id,
                           p_report_set_name => NULL,
                           x_return_status   => l_return_status);
          wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);
       END IF;
       WSH_DOCUMENT_SETS.print_document_sets(
               p_report_set_id       =>  p_action_prms.report_set_id,
               p_organization_id     =>  p_action_prms.organization_id,
               p_trip_ids            =>  l_dummy_ids,
               p_stop_ids            =>  l_stop_id_tab,
               p_delivery_ids        =>  l_dummy_ids,
               p_document_param_info =>  l_dummy_doc_param,
               x_return_status       =>  l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);
    ELSIF p_action_prms.action_code = 'WT-VOL' THEN

        -- OTM R12 : packing ECO
	-- This change was introduced to mark the G_RESET_WV flag
        -- before calling calc_stop_weight_volume so the procedure will know
        -- to invoke update tms_interface_flag process.

        l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
        IF l_gc3_is_installed IS NULL THEN
          l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
        END IF;

        IF l_gc3_is_installed = 'Y' THEN
          WSH_WV_UTILS.G_RESET_WV := 'Y'; -- set to Y to enable the update
        END IF;
        -- End of OTM R12 : packing ECO

        WSH_TRIP_STOPS_ACTIONS.calc_stop_weight_volume(
               p_stop_rows      => l_stop_id_tab,
               p_override_flag  => p_action_prms.override_flag,
               x_return_status  => l_return_status,
--tkt
               p_caller         => p_action_prms.caller
        );
        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);

        -- OTM R12 : packing ECO
        IF l_gc3_is_installed = 'Y' THEN
          WSH_WV_UTILS.G_RESET_WV := 'N'; -- after call, set it back to 'N'
        END IF;
        -- End of OTM R12 : packing ECO

      -- for Load Tender
      -- above call calls FTE
      -- for any update to a stop
      -- end of Load Tender

    ELSIF p_action_prms.action_code = 'UPDATE-STATUS' THEN

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'stop_action',
                                                    p_action_prms.stop_action);
           wsh_debug_sv.log (l_module_name,'actual_date',
                                                    p_action_prms.actual_date);
           wsh_debug_sv.log (l_module_name,'defer_interface_flag',
                                            p_action_prms.defer_interface_flag);
           wsh_debug_sv.log (l_module_name,'C_TRIP_STOP_VALIDATION_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL));
        END IF;

        -- BUG 4247388 - FP:11I10-12.0: if actual date is NULL, always default to SYSDATE here
        -- (whether updating status to Arrived or Closed) to ensure that
        -- the default date will be passed internally.
        -- For example, deliveries' initial pick up date must be in sync
        -- with their initial pick up stops' actual departure dates.
        l_actual_date := NVL(p_action_prms.actual_date, SYSDATE);

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'l_actual_date', l_actual_date);
        END IF;


        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL) = 1
        THEN
          --
          l_is_installed := WSH_UTIL_CORE.FTE_Is_Installed ;
          IF l_is_installed = 'Y' THEN
            --
            FOR i IN l_stop_id_tab.FIRST..l_stop_id_tab.last LOOP
              BEGIN

                SAVEPOINT s_clean_loop_grp;

                WSH_TRIP_STOPS_GRP.get_stop_details_pvt(
                        p_stop_id       => l_stop_id_tab(i),
                        x_stop_rec      => l_stop_rec,
                        x_return_status => l_return_status
                );
                wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);


                WSH_FTE_INTEGRATION.trip_stop_validations(
                         p_stop_rec     => l_stop_rec,
                         p_trip_rec     => l_trip_rec,
                         p_action       => 'UPDATE',
                         x_return_status => l_return_status
                );
                wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);
              EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO s_clean_loop_grp;
                  IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'G_EXC_ERROR in the loop');
                  END IF;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO s_clean_loop_grp;
                  IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,
                                          'G_EXC_UNEXPECTED_ERROR in the loop');
                  END IF;
              END;
            END LOOP;

            IF l_num_errors >= l_stop_id_tab.COUNT THEN
               IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name,'All failed in the loop');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_num_errors >0 THEN
                 IF l_debug_on THEN
                    wsh_debug_sv.log (l_module_name,'l_num_errors',l_num_errors);
                 END IF;
                 l_num_warning := l_num_warning + l_num_errors;
                 l_num_errors := 0;
            END IF;
            --
          END IF;
          --
        END IF;
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CHK_UPDATE_STATUS_LVL) = 1 THEN
       if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'l_stop_id_tab count', l_stop_id_tab.count);
       end if;
           WSH_TRIP_STOPS_ACTIONS.Check_Update_Stops(
                    p_stop_rows      => l_stop_id_tab,
                    p_action               => p_action_prms.stop_action,
--tkt
                    p_caller         => p_action_prms.caller,
                    x_return_status  => l_return_status
           );
           wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                       x_num_warnings     =>l_num_warning,
                                       x_num_errors       =>l_num_errors);
        END IF;

        WSH_TRIP_STOPS_ACTIONS.Change_Status(
                 p_stop_rows            => l_stop_id_tab,
                 p_action               => p_action_prms.stop_action,
                 p_actual_date          => l_actual_date,
                 p_defer_interface_flag => p_action_prms.defer_interface_flag,
                 x_return_status        => l_return_status,
                 p_caller               => p_action_prms.caller
        );
        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);

    ELSIF p_action_prms.action_code = 'DELETE' THEN

        --TL Rating
        IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
          IF l_stop_id_tab.count > 0 THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
              p_entity_type => 'STOP',
              p_entity_ids   => l_stop_id_tab,
              x_return_status => l_return_status
              );

            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warning,
               x_num_errors    => l_num_errors
               );

          END IF;
        END IF;
        --TL Rating
        --

        Add_to_Delete_List(
            p_stop_tab        => l_delete_tmp_tab,
            p_caller          => p_action_prms.caller,
            x_stop_delete_tab => l_stop_delete_tab,
            x_trip_affected_tab => l_trip_affected_tab,
            x_return_status   => l_return_status);


        WSH_UTIL_CORE.delete(
                  p_type                => 'STOP',
                  p_rows                => l_stop_delete_tab,
                  x_return_status       => l_return_status,
--tkt
                  p_caller              => p_action_prms.caller
        );
        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);


        WSH_TRIPS_ACTIONS.Handle_Internal_Stops(
           p_trip_ids          => l_trip_affected_tab,
           p_caller            => p_action_prms.caller,
           x_success_trip_ids  => l_success_trip_tab,
           x_return_status     => l_return_status);

        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);

        --update status of trip to close if already in-transit
        --and all other stops are closed
        IF l_trip_affected_tab IS NOT NULL AND l_trip_affected_tab.COUNT>0 THEN
         FOR i IN l_trip_affected_tab.FIRST..l_trip_affected_tab.LAST LOOP
           l_trip_in_rec.new_status_code    := 'CL';
           l_trip_in_rec.put_messages       := TRUE; --p_in_rec.put_messages;
           l_trip_in_rec.manual_flag        := 'N';
           l_trip_in_rec.caller             := p_action_prms.caller;
           OPEN c_check_trip_close(l_trip_affected_tab(i));
           FETCH c_check_trip_close INTO l_trip_in_rec.trip_id;
           IF c_check_trip_close%FOUND THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.CHANGESTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
                 WSH_DEBUG_SV.log(l_module_name,'Trip',l_trip_in_rec.trip_id);
              END IF;

              wsh_trips_actions.changeStatus
               (
                p_in_rec        => l_trip_in_rec,
                x_return_status => l_return_status
               );

              wsh_util_core.api_post_call
               (
                p_return_status     => l_return_status,
                x_num_warnings      => l_num_warning,
                x_num_errors        => l_num_errors
               );
           END IF;
           CLOSE c_check_trip_close;
         END LOOP;
        END IF;

    ELSIF p_action_prms.action_code IN ( 'PICK-RELEASE-UI', 'RESOLVE-EXCEPTIONS-UI', 'FREIGHT-COSTS-UI')  THEN
       IF p_rec_attr_tab.COUNT > 1 THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
           IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       ELSIF p_rec_attr_tab.COUNT = 1
         AND p_action_prms.caller <> 'WSH_FSTRX' THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
         FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_prms.action_code );
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'WSH_INVALID_ACTION_CODE COUNT');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSE
       -- give message for invalid action
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
       FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_prms.action_code );
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
       IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_INVALID_ACTION_CODE');
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- TP call back to unfirm continuous move or delete continuous move or
    -- any other action that will be done in the future based on the action performed
    IF WSH_UTIL_CORE.TP_IS_INSTALLED='Y' THEN
           WSH_FTE_TP_INTEGRATION.stop_callback (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_TRUE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_prms            => p_action_prms,
                p_rec_attr_tab           => p_rec_attr_tab);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'after calling stop_callback l_return_status',l_return_status);
          END IF;

          wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warning,
               x_num_errors    => l_num_errors
               );
    END IF;--tp_is_installed

    --
    -- K LPN CONV. rv
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
        END IF;
        --
        --
        WSH_UTIL_CORE.API_POST_CALL
          (
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warning,
            x_num_errors       => l_num_errors
          );
    --}
    END IF;
    --
    -- K LPN CONV. rv


    IF l_num_warning > 0 THEN
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    IF p_commit = FND_API.G_TRUE THEN
       --Bugfix 4070732 {
       l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN

          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => FALSE,
                                                   x_return_status => l_return_status);

          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

       END IF;

       --}
       IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        OR (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
          COMMIT;
       END IF;
       --if return status is not success rollback in the exception
       -- handling block
       wsh_util_core.api_post_call
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warning,
                 x_num_errors    => l_num_errors
                );
      x_return_status := l_return_status ; --x_return_status was success g
                                           -- set it to l_return_status for
                                           -- when l_return_status = warning
    END IF;
   --
    --Bugfix 4070732 { logical end of the API
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)    THEN --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN

        IF p_commit = FND_API.G_TRUE THEN

         IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
        ELSE

         IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         WSH_UTIL_CORE.Process_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
        END IF;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         --
         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
         THEN --{
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
         THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;
         END IF; --}
         IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
         OR  x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
         THEN
            IF p_commit = FND_API.G_TRUE THEN
                 null;
            ELSE
                 ROLLBACK TO s_stop_action_grp;
            END IF;

         END IF;
         --
      END IF;
    END IF; --}

    --}
    --End of bug 4070732
    --
--
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
      ROLLBACK TO s_stop_action_grp;
      IF c_check_trip_close%ISOPEN THEN
         CLOSE c_check_trip_close;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            END IF;

         END IF;
      END IF;
      --}
      FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN e_req_field THEN
      ROLLBACK TO s_stop_action_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            END IF;
         END IF;
      END IF;
      --}
      FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO s_stop_action_grp;
      IF c_check_trip_close%ISOPEN THEN
         CLOSE c_check_trip_close;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

         END IF;
      END IF;
      --}

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_UNEXPECTED_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --Bugfix 4070732 {
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
              OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
               ROLLBACK TO s_stop_action_grp;
               x_return_status := l_return_status;
            END IF;

         END IF;
      END IF;
      --}
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_WARNING');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN OTHERS THEN
      ROLLBACK TO s_stop_action_grp;
      IF c_check_trip_close%ISOPEN THEN
         CLOSE c_check_trip_close;
      END IF;
     wsh_util_core.default_handler('WSH_TRIP_STOPS_GRP.STOP_ACTION',
                                                            l_module_name);


      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

         END IF;
      END IF;
      --}
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Others',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END Stop_Action;


--Harmonizing Project **heali
--========================================================================
-- PROCEDURE : map_stopgrp_to_pvt	PRIVATE
--
-- PARAMETERS: p_grp_stop_rec	IN	WSH_TRIP_STOPS_GRP.TRIP_STOP_PUB_REC_TYPE
--             x_pvt_stop_rec	OUT	WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE
--             x_return_status         return status
-- COMMENT   : This procedure maps Group API record type to Private API record type for Stop.
--========================================================================
PROCEDURE map_stopgrp_to_pvt(
   p_grp_stop_rec 	IN WSH_TRIP_STOPS_GRP.TRIP_STOP_PUB_REC_TYPE,
   x_pvt_stop_rec 	OUT NOCOPY WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE,
   x_return_status 	OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_STOPGRP_TO_PVT';
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
       WSH_DEBUG_SV.log(l_module_name,'p_grp_stop_rec.STOP_ID',p_grp_stop_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_grp_stop_rec.TRIP_ID',p_grp_stop_rec.TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_grp_stop_rec.TRIP_NAME',p_grp_stop_rec.TRIP_NAME);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_stop_rec.STOP_ID			:= p_grp_stop_rec.STOP_ID;
  x_pvt_stop_rec.TRIP_ID			:= p_grp_stop_rec.TRIP_ID;
  x_pvt_stop_rec.STOP_LOCATION_ID	 	:= p_grp_stop_rec.STOP_LOCATION_ID;
  x_pvt_stop_rec.STATUS_CODE			:= p_grp_stop_rec.STATUS_CODE;
  x_pvt_stop_rec.STOP_SEQUENCE_NUMBER		:= p_grp_stop_rec.STOP_SEQUENCE_NUMBER;
  x_pvt_stop_rec.PLANNED_ARRIVAL_DATE	 	:= p_grp_stop_rec.PLANNED_ARRIVAL_DATE;
  x_pvt_stop_rec.PLANNED_DEPARTURE_DATE   	:= p_grp_stop_rec.PLANNED_DEPARTURE_DATE;
  x_pvt_stop_rec.ACTUAL_ARRIVAL_DATE	  	:= p_grp_stop_rec.ACTUAL_ARRIVAL_DATE;
  x_pvt_stop_rec.ACTUAL_DEPARTURE_DATE		:= p_grp_stop_rec.ACTUAL_DEPARTURE_DATE;
  x_pvt_stop_rec.DEPARTURE_GROSS_WEIGHT  	:= p_grp_stop_rec.DEPARTURE_GROSS_WEIGHT;
  x_pvt_stop_rec.DEPARTURE_NET_WEIGHT	 	:= p_grp_stop_rec.DEPARTURE_NET_WEIGHT;
  x_pvt_stop_rec.WEIGHT_UOM_CODE	  	:= p_grp_stop_rec.WEIGHT_UOM_CODE;
  x_pvt_stop_rec.DEPARTURE_VOLUME		:= p_grp_stop_rec.DEPARTURE_VOLUME;
  x_pvt_stop_rec.VOLUME_UOM_CODE		:= p_grp_stop_rec.VOLUME_UOM_CODE;
  x_pvt_stop_rec.DEPARTURE_SEAL_CODE	  	:= p_grp_stop_rec.DEPARTURE_SEAL_CODE;
  x_pvt_stop_rec.DEPARTURE_FILL_PERCENT   	:= p_grp_stop_rec.DEPARTURE_FILL_PERCENT;
  x_pvt_stop_rec.TP_ATTRIBUTE_CATEGORY		:= p_grp_stop_rec.TP_ATTRIBUTE_CATEGORY;
  x_pvt_stop_rec.TP_ATTRIBUTE1			:= p_grp_stop_rec.TP_ATTRIBUTE1;
  x_pvt_stop_rec.TP_ATTRIBUTE2			:= p_grp_stop_rec.TP_ATTRIBUTE2;
  x_pvt_stop_rec.TP_ATTRIBUTE3			:= p_grp_stop_rec.TP_ATTRIBUTE3;
  x_pvt_stop_rec.TP_ATTRIBUTE4			:= p_grp_stop_rec.TP_ATTRIBUTE4;
  x_pvt_stop_rec.TP_ATTRIBUTE5			:= p_grp_stop_rec.TP_ATTRIBUTE5;
  x_pvt_stop_rec.TP_ATTRIBUTE6			:= p_grp_stop_rec.TP_ATTRIBUTE6;
  x_pvt_stop_rec.TP_ATTRIBUTE7			:= p_grp_stop_rec.TP_ATTRIBUTE7;
  x_pvt_stop_rec.TP_ATTRIBUTE8			:= p_grp_stop_rec.TP_ATTRIBUTE8;
  x_pvt_stop_rec.TP_ATTRIBUTE9			:= p_grp_stop_rec.TP_ATTRIBUTE9;
  x_pvt_stop_rec.TP_ATTRIBUTE10		   	:= p_grp_stop_rec.TP_ATTRIBUTE10;
  x_pvt_stop_rec.TP_ATTRIBUTE11		   	:= p_grp_stop_rec.TP_ATTRIBUTE11;
  x_pvt_stop_rec.TP_ATTRIBUTE12		   	:= p_grp_stop_rec.TP_ATTRIBUTE12;
  x_pvt_stop_rec.TP_ATTRIBUTE13		   	:= p_grp_stop_rec.TP_ATTRIBUTE13;
  x_pvt_stop_rec.TP_ATTRIBUTE14		   	:= p_grp_stop_rec.TP_ATTRIBUTE14;
  x_pvt_stop_rec.TP_ATTRIBUTE15		   	:= p_grp_stop_rec.TP_ATTRIBUTE15;
  x_pvt_stop_rec.ATTRIBUTE_CATEGORY	   	:= p_grp_stop_rec.ATTRIBUTE_CATEGORY;
  x_pvt_stop_rec.ATTRIBUTE1			:= p_grp_stop_rec.ATTRIBUTE1;
  x_pvt_stop_rec.ATTRIBUTE2			:= p_grp_stop_rec.ATTRIBUTE2;
  x_pvt_stop_rec.ATTRIBUTE3			:= p_grp_stop_rec.ATTRIBUTE3;
  x_pvt_stop_rec.ATTRIBUTE4			:= p_grp_stop_rec.ATTRIBUTE4;
  x_pvt_stop_rec.ATTRIBUTE5			:= p_grp_stop_rec.ATTRIBUTE5;
  x_pvt_stop_rec.ATTRIBUTE6			:= p_grp_stop_rec.ATTRIBUTE6;
  x_pvt_stop_rec.ATTRIBUTE7			:= p_grp_stop_rec.ATTRIBUTE7;
  x_pvt_stop_rec.ATTRIBUTE8			:= p_grp_stop_rec.ATTRIBUTE8;
  x_pvt_stop_rec.ATTRIBUTE9			:= p_grp_stop_rec.ATTRIBUTE9;
  x_pvt_stop_rec.ATTRIBUTE10			:= p_grp_stop_rec.ATTRIBUTE10;
  x_pvt_stop_rec.ATTRIBUTE11			:= p_grp_stop_rec.ATTRIBUTE11;
  x_pvt_stop_rec.ATTRIBUTE12			:= p_grp_stop_rec.ATTRIBUTE12;
  x_pvt_stop_rec.ATTRIBUTE13			:= p_grp_stop_rec.ATTRIBUTE13;
  x_pvt_stop_rec.ATTRIBUTE14			:= p_grp_stop_rec.ATTRIBUTE14;
  x_pvt_stop_rec.ATTRIBUTE15			:= p_grp_stop_rec.ATTRIBUTE15;
  x_pvt_stop_rec.CREATION_DATE			:= p_grp_stop_rec.CREATION_DATE;
  x_pvt_stop_rec.CREATED_BY			:= p_grp_stop_rec.CREATED_BY;
  x_pvt_stop_rec.LAST_UPDATE_DATE		:= p_grp_stop_rec.LAST_UPDATE_DATE;
  x_pvt_stop_rec.LAST_UPDATED_BY		:= p_grp_stop_rec.LAST_UPDATED_BY;
  x_pvt_stop_rec.LAST_UPDATE_LOGIN		:= p_grp_stop_rec.LAST_UPDATE_LOGIN;
  x_pvt_stop_rec.PROGRAM_APPLICATION_ID   	:= p_grp_stop_rec.PROGRAM_APPLICATION_ID;
  x_pvt_stop_rec.PROGRAM_ID			:= p_grp_stop_rec.PROGRAM_ID;
  x_pvt_stop_rec.PROGRAM_UPDATE_DATE	  	:= p_grp_stop_rec.PROGRAM_UPDATE_DATE;
  x_pvt_stop_rec.REQUEST_ID			:= p_grp_stop_rec.REQUEST_ID;
  x_pvt_stop_rec.WSH_LOCATION_ID		:= p_grp_stop_rec.WSH_LOCATION_ID;
  x_pvt_stop_rec.TRACKING_DRILLDOWN_FLAG  	:= p_grp_stop_rec.TRACKING_DRILLDOWN_FLAG;
  x_pvt_stop_rec.TRACKING_REMARKS		:= p_grp_stop_rec.TRACKING_REMARKS;
  x_pvt_stop_rec.CARRIER_EST_DEPARTURE_DATE 	:= p_grp_stop_rec.CARRIER_EST_DEPARTURE_DATE;
  x_pvt_stop_rec.CARRIER_EST_ARRIVAL_DATE   	:= p_grp_stop_rec.CARRIER_EST_ARRIVAL_DATE;
  x_pvt_stop_rec.LOADING_START_DATETIME   	:= p_grp_stop_rec.LOADING_START_DATETIME;
  x_pvt_stop_rec.LOADING_END_DATETIME	 	:= p_grp_stop_rec.LOADING_END_DATETIME;
  x_pvt_stop_rec.UNLOADING_START_DATETIME 	:= p_grp_stop_rec.UNLOADING_START_DATETIME;
  x_pvt_stop_rec.UNLOADING_END_DATETIME   	:= p_grp_stop_rec.UNLOADING_END_DATETIME;
  x_pvt_stop_rec.TRIP_NAME			:= p_grp_stop_rec.TRIP_NAME;
  x_pvt_stop_rec.STOP_LOCATION_CODE	   	:= p_grp_stop_rec.STOP_LOCATION_CODE;
  x_pvt_stop_rec.WEIGHT_UOM_DESC		:= p_grp_stop_rec.WEIGHT_UOM_DESC;
  x_pvt_stop_rec.VOLUME_UOM_DESC		:= p_grp_stop_rec.VOLUME_UOM_DESC;
  x_pvt_stop_rec.LOCK_STOP_ID			:= p_grp_stop_rec.LOCK_STOP_ID;
  x_pvt_stop_rec.PENDING_INTERFACE_FLAG   	:= p_grp_stop_rec.PENDING_INTERFACE_FLAG;
  x_pvt_stop_rec.TRANSACTION_HEADER_ID		:= p_grp_stop_rec.TRANSACTION_HEADER_ID;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_stopgrp_to_pvt',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                               SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END map_stopgrp_to_pvt;

--========================================================================
-- PROCEDURE : Validate_Stop		PRIVATE
--
-- PARAMETERS: p_rec_attr_tab	IN OUT	stop_attr_tab_type
--             p_action_code	IN	'CREATE', 'UPDATE'
--             x_valid_id_index_tab OUT	wsh_util_core.id_tab_type
--             x_return_status         return status
-- COMMENT   : This procedure takes tabe of Stops and validate them and return the validate stops in x_valid_id_index_tab.
--========================================================================
PROCEDURE Validate_Stop
	   (p_rec_attr_tab		IN OUT 	NOCOPY WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
	    p_action_code           	IN     	VARCHAR2,
            p_caller                    IN      VARCHAR2,
            x_valid_id_index_tab 	OUT 	NOCOPY wsh_util_core.id_tab_type,
	    x_return_status         	OUT    	NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_STOP';

l_num_errors 		NUMBER := 0;
l_num_warnings 		NUMBER := 0;
l_index                 NUMBER;
l_status_code 		VARCHAR2(100);
l_action 		VARCHAR2(100);
l_return_status		VARCHAR2(1);
x_msg_count 		NUMBER;
x_msg_data  		varchar2(3000);
l_trip_rec 		WSH_TRIPS_PVT.trip_rec_type;
l_isWshLocation         BOOLEAN DEFAULT FALSE;

WSH_STOP_VALIDATION 	EXCEPTION;
e_mixed_stop_error      EXCEPTION;

-- J-Stop Sequence Change-CSUN
l_stop_details_rec   WSH_TRIP_STOPS_VALIDATIONS.stop_details;

l_stop_id            NUMBER;

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  SAVEPOINT validate_stop_grp;
  IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code );
  END IF;

 IF p_caller IN ( 'WSH_FSTRX','WSH_TPW_INBOUND')
   OR p_caller LIKE 'FTE%' THEN
     l_isWshLocation := TRUE;
 END IF;
 l_index := p_rec_attr_tab.FIRST;
 WHILE l_index IS NOT NULL LOOP
 BEGIN
    SAVEPOINT validate_stop_loop_grp;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'status_code',p_rec_attr_tab(l_index).status_code);
       WSH_DEBUG_SV.log(l_module_name,'stop_id',p_rec_attr_tab(l_index).stop_id);
       WSH_DEBUG_SV.log(l_module_name,'trip_id',p_rec_attr_tab(l_index).trip_id);
       WSH_DEBUG_SV.log(l_module_name,'trip_name',p_rec_attr_tab(l_index).trip_name);
       WSH_DEBUG_SV.log(l_module_name,'stop_location_id',p_rec_attr_tab(l_index).stop_location_id);
       WSH_DEBUG_SV.log(l_module_name,'stop_location_code',p_rec_attr_tab(l_index).stop_location_code);
       WSH_DEBUG_SV.log(l_module_name,'stop_sequence_number',p_rec_attr_tab(l_index).stop_sequence_number);
       WSH_DEBUG_SV.log(l_module_name,'weight_uom_code',p_rec_attr_tab(l_index).weight_uom_code);
       WSH_DEBUG_SV.log(l_module_name,'volume_uom_code',p_rec_attr_tab(l_index).volume_uom_code);
       WSH_DEBUG_SV.log(l_module_name,'planned_arrival_date',p_rec_attr_tab(l_index).planned_arrival_date);
       WSH_DEBUG_SV.log(l_module_name,'planned_departure_date',p_rec_attr_tab(l_index).planned_departure_date);
    END IF;

    IF p_action_code = 'UPDATE' THEN
	l_status_code := p_rec_attr_tab(l_index).status_code;
	l_action := 'UPDATE';
    ELSE
	l_status_code := 'OP';
	l_action := 'ADD';
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_STOP_NAME_LVL) = 1)  THEN
       l_stop_id := p_rec_attr_tab(l_index).stop_id;
       WSH_UTIL_VALIDATE.Validate_Stop_Name (
                p_stop_id       => l_stop_id,
 		p_trip_id       => p_rec_attr_tab(l_index).trip_id,
                p_stop_location_id => NULL,  -- not needed
                p_planned_dep_date => NULL,  -- not needed
		x_return_status => l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Stop_Name l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);

    END IF;

    -- J-IB-NPARIKH-{
    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CREATE_MIXED_STOP_LVL) = 1 )
    THEN
    --{
        IF p_rec_attr_tab(l_index).shipments_type_flag = 'M'
        THEN
            -- You cannot create mixed stops through API
            --
            RAISE e_mixed_stop_error;
        END IF;
    --}
    END IF;
    --
    -- J-IB-NPARIKH-}

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_NAME_LVL) = 1 )  THEN
       WSH_UTIL_VALIDATE.Validate_Trip_Name (
 		p_trip_id       => p_rec_attr_tab(l_index).trip_id,
		p_trip_name     => p_rec_attr_tab(l_index).trip_name,
		x_return_status => l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Trip_Name l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STATUS_LVL) = 1 )  THEN
       WSH_UTIL_VALIDATE.Validate_Trip_status (
				p_trip_id		=> p_rec_attr_tab(l_index).trip_id,
				p_action		=> p_action_code,
				x_return_status		=> l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Trip_status l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCATION_LVL) = 1 )  THEN

      -- Stop location id can be -1 for inbound stops
      -- in such case, we do not need to call validate location, as it wil fail
      -- in turn preventing any update of stop attributes
      --
      IF p_rec_attr_tab(l_index).stop_location_id  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID   -- J-IB-NPARIKH
      OR p_rec_attr_tab(l_index).stop_location_id  IS NULL
      THEN
       WSH_UTIL_VALIDATE.Validate_Location (
		p_location_id	=> p_rec_attr_tab(l_index).stop_location_id,
		p_location_code	=> p_rec_attr_tab(l_index).stop_location_code,
		x_return_status	=> l_return_status,
                p_isWshLocation => l_isWshLocation);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Location l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
     END IF;
    END IF;


    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PLANNED_TRIP_LVL) = 1 )  THEN
      wsh_trip_validations.validate_planned_trip
       (p_stop_id		=> p_rec_attr_tab(l_index).stop_id,
        p_stop_sequence_number	=> p_rec_attr_tab(l_index).stop_sequence_number,
        x_return_status		=> l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_planned_trip l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_WEIGHT_UOM_LVL) = 1 )  THEN
       wsh_util_validate.validate_uom (
				'WEIGHT',
				NULL,
				p_rec_attr_tab(l_index).weight_uom_code,
				p_rec_attr_tab(l_index).weight_uom_desc,
				l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_uom-WEIGHT l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VOLUME_UOM_LVL) = 1 )  THEN
       wsh_util_validate.validate_uom (
					'VOLUME',
					NULL,
					p_rec_attr_tab(l_index).volume_uom_code,
					p_rec_attr_tab(l_index).volume_uom_desc,
					l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_uom-VOLUME l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;


    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ARR_DEP_DATES_LVL) = 1 )  THEN
       WSH_UTIL_VALIDATE.validate_from_to_dates (
			p_from_date		=> p_rec_attr_tab(l_index).planned_arrival_date,
			p_to_date		=>p_rec_attr_tab(l_index).planned_departure_date,
			x_return_status		=> l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_from_to_dates l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    -- SSN change
    -- Add conditional validation for stop sequence number
    IF (WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE  = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN) AND
       (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_SEQ_NUM_LVL) = 1 )  THEN

      IF (l_status_code = 'OP') THEN
        WSH_TRIP_STOPS_validations.validate_sequence_number  (
          p_stop_id                =>  p_rec_attr_tab(l_index).stop_id,
          p_stop_sequence_number   =>  p_rec_attr_tab(l_index).stop_sequence_number,
          p_trip_id                =>  p_rec_attr_tab(l_index).trip_id,
          p_status_code            =>  l_status_code,
          x_return_status          =>  l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_SSN l_return_status',l_return_status);
        END IF;
        WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                    x_num_warnings     =>l_num_warnings,
                                    x_num_errors       =>l_num_errors);
      END IF;
    END IF;

    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
       IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL) = 1 )  THEN
          WSH_FTE_INTEGRATION.trip_stop_validations
               (p_stop_rec		=> p_rec_attr_tab(l_index),
                p_trip_rec		=> l_trip_rec,
                p_action		=> l_action,
                x_return_status		=> l_return_status);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Trip_Name l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
       END IF;
    END IF;
    --Bug 4140359
    IF NVL(p_caller, '-1') <> 'WSH_FSTRX' THEN --{
       IF nvl(p_rec_attr_tab(l_index).DEPARTURE_GROSS_WEIGHT,0) > 0
        OR
          nvl(p_rec_attr_tab(l_index).DEPARTURE_NET_WEIGHT,0) > 0 THEN
          IF p_rec_attr_tab(l_index). WEIGHT_UOM_CODE IS NULL THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_WTVOL_NULL');
             WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
             RAISE fnd_api.g_exc_error;
          END IF;
       END IF;
       --Bug 4140359
       IF nvl(p_rec_attr_tab(l_index).DEPARTURE_VOLUME,0) > 0
        AND p_rec_attr_tab(l_index).VOLUME_UOM_CODE IS NULL THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_WTVOL_NULL');
          WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
          RAISE fnd_api.g_exc_error;
       END IF;
    END IF; --}
    x_valid_id_index_tab(x_valid_id_index_tab.COUNT + 1) := l_index;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_num_errors',l_num_errors);
       WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
    END IF;
 EXCEPTION
     -- J-IB-NPARIKH-{
     WHEN e_mixed_Stop_error THEN
        ROLLBACK TO validate_stop_loop_grp;
        l_num_errors := l_num_errors + 1;
        FND_MESSAGE.SET_NAME('WSH', 'WSH_MIXED_STOP_ERROR');
        WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'e_mixed_Stop_error  exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        END IF;
        -- J-IB-NPARIKH-}

    WHEN fnd_api.g_exc_error THEN
       Rollback to validate_stop_loop_grp;

    WHEN fnd_api.g_exc_unexpected_error THEN
       Rollback to validate_stop_loop_grp;

    WHEN others THEN
       ROLLBACK TO SAVEPOINT validate_stop_loop_grp;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END;
 l_index := p_rec_attr_tab.NEXT(l_index);
 END LOOP;

 IF (l_num_errors = p_rec_attr_tab.count ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF (l_num_errors > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSIF (l_num_warnings > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;


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
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     ROLLBACK TO SAVEPOINT validate_stop_grp;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;
     ROLLBACK TO SAVEPOINT validate_stop_grp;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
     END IF;

   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.Validate_Stop');
      FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
     ROLLBACK TO SAVEPOINT validate_stop_grp;
END Validate_Stop;

--========================================================================
-- PROCEDURE : Create_Update_Stop      CORE API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_commit                'T'/'F'
--             p_in_rec                stopInRecType
--             p_rec_attr_tab	       Table of Attributes for the stop entity
--             p_stop_OUT_tab          Table of Output Attributes for the stop entity
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This is the core CREATE_UPDATE_STOP procedure introduce as a part of Harmonizing Project in patchset I.
--             All other CREATE_UPDATE_STOP procedures will call this one only.
--========================================================================
PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN stopInRecType,
        p_rec_attr_tab          IN WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY  stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_stop_wt_vol_out_tab   OUT NOCOPY Stop_Wt_Vol_tab_type --bug 2796095
     ) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Update_Stop';
l_debug_on BOOLEAN;
l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP';
RECORD_LOCKED          	EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

l_trip_id		NUMBER;
i                       NUMBER;
l_num_errors 		NUMBER := 0;
l_num_warnings 		NUMBER := 0;
l_return_status 	VARCHAR2(1);
l_index                 NUMBER;
l_rec_attr_tab		WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
x_index_id_tab		wsh_util_core.id_tab_type;

--Compatibility Changes
    l_cc_validate_result		VARCHAR2(1);
    l_cc_failed_records			WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_line_groups			WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_cc_group_info			WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;

    l_rec_attr_tab_temp			WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_count_success			NUMBER;
    b_cc_linefailed			BOOLEAN;
    l_msg_count				NUMBER;
    l_msg_data				VARCHAR2(2000);

    --dummy tables for calling validate_constraint_mainper
    l_cc_del_attr_tab	        WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab	        wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab	        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab	        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids		        wsh_util_core.id_tab_type;
    l_cc_fail_ids		wsh_util_core.id_tab_type;

--Compatibility Changes
-- csun 10+
    l_trip_id_tab               wsh_util_core.id_tab_type;
    l_success_trip_ids          wsh_util_core.id_tab_type;
    l_trips                     wsh_util_core.id_tab_type;
    l_found                     BOOLEAN;

--TL Rating
   l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;
--TL Rating

   l_action_prms                action_parameters_rectype;
   l_stop_rec                WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
   l_internal_stop_rec      WSH_TRIP_STOPS_PVT.trip_stop_rec_type;

--bug 2796095
  CURSOR c_get_all_trip_stops (p_trip_id IN NUMBER) IS
  SELECT stop_id,
	 departure_gross_weight,
	 departure_net_weight,
	 departure_volume,
	 departure_fill_percent
  FROM  wsh_trip_stops
  WHERE trip_id = p_trip_id ;

  -- bug 3848771
  CURSOR c_trip_info (p_trip_id in number) is
  SELECT mode_of_transport,
         NVL(ignore_for_planning,'N'), -- OTM R12,glog project
         tp_plan_name
  FROM wsh_trips
  WHERE trip_id = p_trip_id;

  --OTM R12, glog proj
  l_ignore                WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;
  l_tp_plan_name          WSH_TRIPS.TP_PLAN_NAME%TYPE;
  l_gc3_is_installed      VARCHAR2(1);
  e_gc3_trip_exception    EXCEPTION;
  --OTM R12, end of glog proj


  l_stop_id                NUMBER;
  l_stop_index 	           NUMBER :=0;
  --bug 2796095
  l_status_code            VARCHAR2(100);
  l_stop_details_rec       WSH_TRIP_STOPS_VALIDATIONS.stop_details;
  l_handle_internal_stops  BOOLEAN;
  l_reset_stop_sequence    BOOLEAN;

  get_physical_loc_err     EXCEPTION;

  -- bug 3848771
  l_mode_of_transport      WSH_TRIPS.MODE_OF_TRANSPORT%TYPE;
  --Bugfix 4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags            BOOLEAN;

  l_stop_seq_mode          NUMBER; -- SSN change

  -- K LPN CONV. rv
  l_lpn_in_sync_comm_rec   WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec  WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  -- K LPN CONV. rv

BEGIN
 IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
    WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
    WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
 END IF;
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 l_stop_seq_mode := WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE; -- SSN change

 SAVEPOINT create_update_stop_grp;

 l_trips.delete;

 IF l_debug_on THEN
    wsh_debug_sv.push (l_module_name, 'Create_Update_Stop');
    wsh_debug_sv.log (l_module_name,'p_in_rec.action_code',p_in_rec.action_code);
    wsh_debug_sv.log (l_module_name,'p_in_rec.caller',p_in_rec.caller);
    wsh_debug_sv.log (l_module_name,'p_in_rec.phase',p_in_rec.phase);
    wsh_debug_sv.log (l_module_name,'(p_rec_attr_tab.count',p_rec_attr_tab.count);
 END IF;

 IF NOT FND_API.Compatible_API_Call(l_api_version_number, p_api_version_number,l_api_name,G_PKG_NAME) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Not compatible');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
 END IF;

 -- Initialize the Variables
 x_return_status    := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 --OTM R12, glog proj, use Global Variable
 l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

 -- If null, call the function
 IF l_gc3_is_installed IS NULL THEN
   l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
 END IF;
 -- end of OTM R12, glog proj



 IF (p_in_rec.caller IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.caller');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;
 IF (p_in_rec.action_code IS NULL OR p_in_rec.action_code NOT IN ('CREATE','UPDATE') ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.action_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (nvl(p_in_rec.phase,1) < 1) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.phase');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (p_rec_attr_tab.count < 0 ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_rec_attr_tab.count');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 WSH_ACTIONS_LEVELS.set_validation_level (
        p_entity                => 'STOP',
        p_caller                => p_in_rec.caller,
        p_phase                 => p_in_rec.phase,
        p_action                => p_in_rec.action_code,
        x_return_status         => l_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'WSH_ACTIONS_LEVELS.set_validation_level l_return_status',l_return_status);
 END IF;

 WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


 IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DISABLED_LIST_LVL) = 1 )  THEN
    l_index := p_rec_attr_tab.FIRST;
    WHILE l_index IS NOT NULL LOOP
    BEGIN
       SAVEPOINT s_stop_disabled_list_grp;
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'stop_id,trip_id',p_rec_attr_tab(l_index).stop_id||','||
                                                                                      p_rec_attr_tab(l_index).trip_id);
       END IF;

       WSH_TRIP_STOPS_validations.get_disabled_list(
	p_stop_rec			=>   	p_rec_attr_tab(l_index),
	p_parent_entity_id		=>  	p_rec_attr_tab(l_index).trip_id,
        p_in_rec			=>	p_in_rec,
	x_return_status			=> 	l_return_status,
	x_msg_count			=>   	x_msg_count,
	x_msg_data			=>	x_msg_data,
	x_stop_rec	  		=> 	l_rec_attr_tab(l_index));

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);

    EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       Rollback to s_stop_disabled_list_grp;

    WHEN fnd_api.g_exc_unexpected_error THEN
       Rollback to s_stop_disabled_list_grp;

    WHEN others THEN
       Rollback to s_stop_disabled_list_grp;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_index := p_rec_attr_tab.NEXT(l_index);
    END LOOP;

    IF (l_num_errors = p_rec_attr_tab.count ) THEN
       raise fnd_api.g_exc_error;
    END IF;

 ELSE
    l_rec_attr_tab := p_rec_attr_tab;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'count, l_num_errors',l_rec_attr_tab.COUNT ||','||l_num_errors);
 END IF;

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_CONSTRAINTS_LVL) = 1  THEN --{
    --Compatiblity Changes
    IF (wsh_util_core.fte_is_installed = 'Y') THEN

       -- populate physical_location_id before validate_constraint_main
       i := l_rec_attr_tab.first;
       WHILE i is NOT NULL LOOP

	  WSH_LOCATIONS_PKG.Convert_internal_cust_location(
            p_internal_cust_location_id => l_rec_attr_tab(i).stop_location_id,
            x_internal_org_location_id  => l_rec_attr_tab(i).physical_location_id,
            x_return_status             => l_return_status);

          IF l_return_status in (FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR) THEN
            RAISE get_physical_loc_err;
          END IF;
       i := l_rec_attr_tab.next(i);
       END LOOP;


       WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
         p_api_version_number   =>  p_api_version_number,
         p_init_msg_list        =>  FND_API.G_FALSE,
         p_entity_type          =>  'S',
         p_target_id            =>  null,
         p_action_code          =>  p_in_rec.action_code,
         p_del_attr_tab         =>  l_cc_del_attr_tab,
         p_det_attr_tab         =>  l_cc_det_attr_tab,
         p_trip_attr_tab        =>  l_cc_trip_attr_tab,
         p_stop_attr_tab        =>  l_rec_attr_tab,
         p_in_ids               =>  l_cc_in_ids,
         x_fail_ids             =>  l_cc_fail_ids,
         x_validate_result      =>  l_cc_validate_result,
         x_failed_lines         =>  l_cc_failed_records,
         x_line_groups          =>  l_cc_line_groups,
         x_group_info           =>  l_cc_group_info,
         x_msg_count            =>  l_msg_count,
         x_msg_data             =>  l_msg_data,
         x_return_status        =>  l_return_status);

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_fail_ids.COUNT);
        wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
        wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
      END IF;
      --

      --fix p_rec_attr_tab to have only successful records if there are some failed lines
      IF l_return_status=wsh_util_core.g_ret_sts_error THEN
       l_cc_count_success:=1;

       IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_rec_attr_tab count before removing failed lines',l_rec_attr_tab.COUNT);
       END IF;

       IF l_cc_fail_ids.COUNT>0 AND l_rec_attr_tab.COUNT>0 THEN
         IF l_cc_fail_ids.COUNT=l_rec_attr_tab.COUNT THEN
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'all stops failed compatibility check');
            END IF;
            FND_MESSAGE.SET_NAME('WSH','WSH_STOP_COMP_FAILED');
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors,
              p_msg_data         => l_msg_data);
         ELSE
            l_return_status:=wsh_util_core.g_ret_sts_warning;
         END IF;

         FOR i in l_rec_attr_tab.FIRST..l_rec_attr_tab.LAST LOOP
           b_cc_linefailed:=FALSE;

           FOR j in l_cc_fail_ids.FIRST..l_cc_fail_ids.LAST LOOP
             --for create, in WSHFTCCB, dummy stop_id (index of l_rec_attr_tab)
             --is passed so use that to remove rec
             IF (p_in_rec.action_code='CREATE' AND l_rec_attr_tab(i).stop_id is null
               AND i=l_cc_fail_ids(j)) THEN
                 b_cc_linefailed:=TRUE;
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name,'compatibility check failed for stop create');
                 END IF;
                 FND_MESSAGE.SET_NAME('WSH','WSH_STOP_COMP_FAILED');
             ELSIF (l_rec_attr_tab(i).stop_id=l_cc_fail_ids(j)) THEN
                 b_cc_linefailed:=TRUE;
                 FND_MESSAGE.SET_NAME('WSH','WSH_STOP_COMP_FAILED');
                 FND_MESSAGE.SET_TOKEN('STOP_ID',l_cc_fail_ids(j));
             END IF;
           END LOOP;--fail_ids

           IF (NOT(b_cc_linefailed)) THEN
              l_rec_attr_tab_temp(l_cc_count_success):=l_rec_attr_tab(i);
              l_cc_count_success:=l_cc_count_success+1;
           END IF;
         END LOOP;--l_rec_attr_tab

         IF l_rec_attr_tab_temp.COUNT>0 THEN
           l_rec_attr_tab:=l_rec_attr_tab_temp;
         END IF;

       ELSE
          l_return_status:=wsh_util_core.g_ret_sts_warning;
       END IF; --fail_ids count>0


       IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_rec_attr_tab count after removing failed lines',l_rec_attr_tab.COUNT);
       END IF;

     END IF;--error

      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);

    END IF;
    --Compatiblity Changes
   END IF; --}

 l_num_errors :=0;

 Validate_Stop(
	p_rec_attr_tab		=> l_rec_attr_tab,
	p_action_code		=> p_in_rec.action_code,
        p_caller                => p_in_rec.caller,
	x_valid_id_index_tab	=> x_index_id_tab,
	x_return_status		=> l_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Validate_stop l_return_status',l_return_status);
 END IF;

 WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


 l_index        := x_index_id_tab.FIRST;

 WHILE l_index IS NOT NULL LOOP
 BEGIN--{
   SAVEPOINT s_trip_stop_grp;

   OPEN c_trip_info(l_rec_attr_tab(x_index_id_tab(l_index)).trip_id);
   -- OTM R12, glog proj
   FETCH c_trip_info INTO l_mode_of_transport,l_ignore,l_tp_plan_name;
   IF c_trip_info%NOTFOUND THEN
     CLOSE c_trip_info;
     RAISE no_data_found;
   END IF;
   CLOSE c_trip_info;
    IF (p_in_rec.action_code = 'CREATE' ) THEN

      -- OTM R12, glog project
      -- Do not allow creation of Trip Stop for GC3 created trips
      -- from UI or Public API, only allowed from Inbound Message
      -- received from GC3
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_ignore',l_ignore);
        WSH_DEBUG_SV.log(l_module_name,'l_tp_plan_name',l_tp_plan_name);
        WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed',l_gc3_is_installed);
      END IF;

      IF (l_ignore = 'N' AND
          l_tp_plan_name IS NOT NULL AND
          l_gc3_is_installed = 'Y' AND
          p_in_rec.caller <> 'FTE_TMS_INTEGRATION') THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        RAISE e_gc3_trip_exception;
      END IF;
      --

       WSH_TRIP_STOPS_PVT.create_trip_stop (
	p_trip_stop_info     	=>	l_rec_attr_tab(x_index_id_tab(l_index)),
	x_rowid                 => 	x_stop_out_tab(l_index).rowid,
	x_stop_id             	=>	x_stop_out_tab(l_index).stop_id,
	x_return_status      	=>	l_return_status);

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings  =>l_num_warnings,
                                   x_num_errors    =>l_num_errors);


       IF l_rec_attr_tab(x_index_id_tab(l_index)).trip_id is not NULL THEN
          l_trips(1) :=  l_rec_attr_tab(x_index_id_tab(l_index)).trip_id;
          WSH_TRIPS_ACTIONS.Handle_Internal_Stops(
            p_trip_ids          => l_trips,
            p_caller            => 'WSH_CREATE_TRIP_STOP',
            x_success_trip_ids  => l_success_trip_ids,
            x_return_status     => l_return_status);

          wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors);

          -- 4106444 -skattama
          -- After Trip is created and internal location is linked
          -- If mode is other than TRUCK, the stops should not be greater than 2
          IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
            WSH_UTIL_VALIDATE.Validate_Trip_MultiStops (
              p_trip_id           => l_rec_attr_tab(x_index_id_tab(l_index)).trip_id,
              p_mode_of_transport => l_mode_of_transport,
              x_return_status     => l_return_status);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_MultiStops l_return_status',l_return_status);
            END IF;
            WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                     x_num_warnings     =>l_num_warnings,
                                     x_num_errors       =>l_num_errors);
          END IF;
         -- end 4106444
       END IF;

    ELSIF (p_in_rec.action_code = 'UPDATE' ) THEN
       -- csun start of stop sequence change
       l_handle_internal_stops := FALSE;
       l_reset_stop_sequence := FALSE;
       get_stop_details_pvt
         (p_stop_id => l_rec_attr_tab(x_index_id_tab(l_index)).stop_id,
          x_stop_rec => l_stop_rec,
          x_return_status => l_return_status);

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings  =>l_num_warnings,
                                    x_num_errors    =>l_num_errors);

       -- begin csun 10+ internal location
       IF l_stop_rec.stop_location_id <> l_rec_attr_tab(x_index_id_tab(l_index)).stop_location_id THEN
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'stop location id has been changed');
          END IF;
          WSH_LOCATIONS_PKG.Convert_internal_cust_location(
            p_internal_cust_location_id => l_rec_attr_tab(x_index_id_tab(l_index)).stop_location_id,
            x_internal_org_location_id  => l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id,
            x_return_status             => l_return_status);

          IF l_return_status in (FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR) THEN
            RAISE get_physical_loc_err;
          END IF;
          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'l_stop_rec.physical_location_id' , l_stop_rec.physical_location_id);
             wsh_debug_sv.log(l_module_name,'l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id' ,l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id);
          END IF;
          -- delink the physical stop id
          IF nvl(l_stop_rec.physical_location_id, -99) <> nvl(l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id, -99) THEN
             l_stop_rec.physical_stop_id := NULL;
             l_rec_attr_tab(x_index_id_tab(l_index)).physical_stop_id := NULL;
             l_stop_rec.physical_location_id := l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id;
	  END IF;
	  l_handle_internal_stops := TRUE;
       END IF;

       -- end csun 10+ internal location

       WSH_TRIP_STOPS_PVT.UPDATE_TRIP_STOP (
	p_rowid                 =>	l_rec_attr_tab(x_index_id_tab(l_index)).rowid,
	p_stop_info     	=>      l_rec_attr_tab(x_index_id_tab(l_index)),
	x_return_status      	=> 	l_return_status);

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings  =>l_num_warnings,
                                    x_num_errors    =>l_num_errors);

       -- bug 4253803: change in planned departure date needs to be validated.
       IF (l_stop_rec.planned_arrival_date <> l_rec_attr_tab(x_index_id_tab(l_index)).planned_arrival_date)
          OR (l_stop_rec.planned_departure_date <> l_rec_attr_tab(x_index_id_tab(l_index)).planned_departure_date) THEN

          -- if mode is PAD, changing PAD may resequence.
          -- if mode is SSN, linked dummy stop's planned dates have
          -- to be synchronized (which will also take care of SSN changes).

          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'PAD or PDD has been changed');
             wsh_debug_sv.logmsg(l_module_name,'Physical Loc'||l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id);
          END IF;

          -- begin csun 10+ internal location
          -- if the dates of physical stop is changed, change the dates of
          -- corresponding internal stop
          -- Always set handle_internal_stops to TRUE
          -- this calls reset/validate APIs as well
          -- Try updating planned arrival dates for both physical/dummy
          -- stop while testing this piece of code
          l_handle_internal_stops := TRUE;
          -- end csun 10+ internal location
       ELSIF (l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN
           AND l_stop_rec.stop_sequence_number <> l_rec_attr_tab(x_index_id_tab(l_index)).stop_sequence_number) THEN
          -- if mode is SSN and SSN alone is changed,
          --   need to synchronize linked dummy stops.

          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'SSN has been changed');
             wsh_debug_sv.logmsg(l_module_name,'Physical Loc'||l_rec_attr_tab(x_index_id_tab(l_index)).physical_location_id);
          END IF;

          -- if the SSN of physical stop is changed, change the SSN of
          -- corresponding internal stop
          -- Always set handle_internal_stops to TRUE
          -- Try updating SSN for both physical/dummy
          -- stop while testing this piece of code
          l_handle_internal_stops := TRUE;
       END IF;

       IF l_handle_internal_stops  THEN
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'handle internal stop TRUE');
          END IF;
          l_trips(1) := l_rec_attr_tab(x_index_id_tab(l_index)).trip_id;

          WSH_TRIPS_ACTIONS.Handle_Internal_Stops(
             p_trip_ids          => l_trips,
             p_caller            => p_in_rec.caller,
             x_success_trip_ids  => l_success_trip_ids,
             x_return_status     => l_return_status);

          wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors);

       END IF;
       -- csun end of stop sequence change
       -- 4106444 - skattama
       -- After Trip is updated with stop and internal location is linked/delinked
       -- If mode is other than TRUCK, the stops of the trip should not be greater than 2
       IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
         WSH_UTIL_VALIDATE.Validate_Trip_MultiStops (
              p_trip_id               => l_rec_attr_tab(x_index_id_tab(l_index)).trip_id,
              p_mode_of_transport     => l_mode_of_transport,
              x_return_status         => l_return_status);
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_MultiStops l_return_status',l_return_status);
         END IF;
         WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                     x_num_warnings     =>l_num_warnings,
                                     x_num_errors       =>l_num_errors);
        END IF;
      -- end 4106444
    END IF;


    /* moved validate_squence_number here */
    IF p_in_rec.action_code = 'UPDATE' THEN
       l_status_code := l_rec_attr_tab(l_index).status_code;
    ELSE
       l_status_code := 'OP';
    END IF;

    IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name,p_in_rec.action_code);
        wsh_debug_sv.log(l_module_name,'WSH_UTIL_CORE.FTE_Is_Installed', WSH_UTIL_CORE.FTE_Is_Installed);
    END IF;

    --TL Rating
    IF (p_in_rec.action_code = 'CREATE' ) THEN
       l_details_marked(l_details_marked.COUNT+1):=x_stop_out_tab(l_index).stop_id;
    ELSIF (p_in_rec.action_code = 'UPDATE' ) THEN

     IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
        -- Bug 3848771
        -- Mark as reprice required only when certain conditions are met
        -- during update.

        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'l_rec_attr_tab(x_index_id_tab(l_index)).planned_arrival_date', l_rec_attr_tab(x_index_id_tab(l_index)).planned_arrival_date);
           wsh_debug_sv.log(l_module_name,'l_rec_attr_tab(x_index_id_tab(l_index)).planned_departure_date', l_rec_attr_tab(x_index_id_tab(l_index)).planned_departure_date);
           wsh_debug_sv.log(l_module_name,'l_stop_rec.planned_arrival_date', l_stop_rec.planned_arrival_date);
           wsh_debug_sv.log(l_module_name,'l_stop_rec.planned_departure_date', l_stop_rec.planned_departure_date);
        END IF;


        IF (NVL(l_rec_attr_tab(x_index_id_tab(l_index)).planned_arrival_date, FND_API.G_MISS_DATE) <>
            NVL(l_stop_rec.planned_arrival_date, FND_API.G_MISS_DATE))
        OR (NVL(l_rec_attr_tab(x_index_id_tab(l_index)).planned_departure_date, FND_API.G_MISS_DATE) <>
            NVL(l_stop_rec.planned_departure_date, FND_API.G_MISS_DATE))
        OR (NVL(l_rec_attr_tab(x_index_id_tab(l_index)).stop_location_id, FND_API.G_MISS_NUM) <>
            NVL(l_stop_rec.stop_location_id, FND_API.G_MISS_NUM)) THEN

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'details marked count', l_details_marked.COUNT);
          END IF;

          l_details_marked(l_details_marked.COUNT+1):=l_rec_attr_tab(x_index_id_tab(l_index)).stop_id;

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'details marked count', l_details_marked.COUNT);
          END IF;

        ELSIF NVL(l_rec_attr_tab(x_index_id_tab(l_index)).WKEND_LAYOVER_STOPS, FND_API.G_MISS_NUM) <>
              NVL(l_stop_rec.WKEND_LAYOVER_STOPS, FND_API.G_MISS_NUM)
        OR    NVL(l_rec_attr_tab(x_index_id_tab(l_index)).WKDAY_LAYOVER_STOPS, FND_API.G_MISS_NUM) <>
              NVL(l_stop_rec.WKDAY_LAYOVER_STOPS, FND_API.G_MISS_NUM) THEN

           IF l_mode_of_transport = 'TRUCK' THEN

              l_details_marked(l_details_marked.COUNT+1):=l_rec_attr_tab(x_index_id_tab(l_index)).stop_id;

           END IF;

        END IF;

      END IF;

    END IF;
    --TL Rating



 EXCEPTION
    WHEN get_physical_loc_err THEN
       Rollback to s_trip_stop_grp;
       --OTM R12, glog proj
       IF c_trip_info%ISOPEN THEN
         CLOSE c_trip_info;
       END IF;
       l_num_errors := l_num_errors + 1;
       fnd_message.set_name('WSH', 'WSH_LOCATION_CONVERT_ERR');
       fnd_message.set_token('LOCATION_NAME',
         SUBSTRB(WSH_UTIL_CORE.get_location_description(l_rec_attr_tab(x_index_id_tab(l_index)).stop_location_id,'NEW UI CODE'), 1, 60));
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);

    -- OTM R12, glog proj
    WHEN e_gc3_trip_exception THEN
       Rollback to s_trip_stop_grp;
       --OTM R12, glog proj
       IF c_trip_info%ISOPEN THEN
         CLOSE c_trip_info;
       END IF;
       l_num_errors := l_num_errors + 1;
       FND_MESSAGE.SET_NAME('WSH','WSH_OTM_TRIP_STOP_CR_ERROR');
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'GC3_TRIP exception has occured.');
       END IF;
       --

     --OTM R12, glog proj, other cursors are closed in OUTER exception
     WHEN no_data_found THEN
       Rollback to s_trip_stop_grp;
       -- Cursor is already closed, before raising this exception
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


    WHEN fnd_api.g_exc_error THEN
       Rollback to s_trip_stop_grp;
       --OTM R12, glog proj
       IF c_trip_info%ISOPEN THEN
         CLOSE c_trip_info;
       END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
       Rollback to s_trip_stop_grp;
       --OTM R12, glog proj
       IF c_trip_info%ISOPEN THEN
         CLOSE c_trip_info;
       END IF;

    WHEN others THEN
       Rollback to s_trip_stop_grp;
       --OTM R12, glog proj
       IF c_trip_info%ISOPEN THEN
         CLOSE c_trip_info;
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
 END;
 l_index := x_index_id_tab.NEXT(l_index);
 END LOOP;


    -- TP call back to unfirm continuous move or delete continuous move or
    -- any other action that will be done in the future based on the action performed
    IF WSH_UTIL_CORE.TP_IS_INSTALLED='Y' THEN
           l_action_prms.action_code:=p_in_rec.action_code;
           l_action_prms.caller:=p_in_rec.caller;
           WSH_FTE_TP_INTEGRATION.stop_callback (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_TRUE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_prms            => l_action_prms,
                p_rec_attr_tab           => l_rec_attr_tab);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'after calling stop_callback l_return_status',l_return_status);
          END IF;

          wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors
               );
    END IF;--tp_is_installed

    --TL Rating mark trip as needing reprice
    IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
      IF l_details_marked.count > 0 THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
          p_entity_type => 'STOP',
          p_entity_ids   => l_details_marked,
          x_return_status => l_return_status);

        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors
           );

      END IF;
    END IF;
    --TL Rating


 --bug 2796095
 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_trip_id_tab.count',l_trip_id_tab.count);
 END IF;
 IF ( l_trip_id_tab.count > 0 ) THEN

    l_index := l_trip_id_tab.FIRST;
    WHILE l_index IS NOT NULL LOOP
       FOR stop_rec IN c_get_all_trip_stops(l_trip_id_tab(l_index)) LOOP
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Stop_id',stop_rec.stop_id);
         END IF;

         x_stop_wt_vol_out_tab(l_stop_index).stop_id := stop_rec.stop_id;
	 x_stop_wt_vol_out_tab(l_stop_index).departure_gross_weight :=stop_rec.departure_gross_weight;
	 x_stop_wt_vol_out_tab(l_stop_index).departure_net_weight :=stop_rec.departure_net_weight;
	 x_stop_wt_vol_out_tab(l_stop_index).departure_volume :=stop_rec.departure_volume;
	 x_stop_wt_vol_out_tab(l_stop_index).departure_fill_percent  :=stop_rec.departure_fill_percent;

         l_stop_index := l_stop_index +1;
       END LOOP;

    l_index := l_trip_id_tab.NEXT(l_index);
    END LOOP;
 END IF;
 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_stop_wt_vol_out_tab.count',x_stop_wt_vol_out_tab.count);
 END IF;
 --bug 2796095
 --
 -- K LPN CONV. rv
 --
 IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
 THEN
 --{
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;


     WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
       (
         p_in_rec             => l_lpn_in_sync_comm_rec,
         x_return_status      => l_return_status,
         x_out_rec            => l_lpn_out_sync_comm_rec
       );
     --
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
     END IF;
     --
     --
     WSH_UTIL_CORE.API_POST_CALL
       (
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors
       );
 --}
 END IF;
 --
 -- K LPN CONV. rv


 IF (l_num_errors = l_rec_attr_tab.count ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF (l_num_errors > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSIF (l_num_warnings > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;


 IF FND_API.To_Boolean( p_commit ) THEN
    --Bugfix 4070732 {
    l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN

       IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => FALSE,
                                                   x_return_status => l_return_status);

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;
    END IF;
    --}
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
      (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       ROLLBACK to create_update_stop_grp;
    ELSE
       COMMIT WORK;
    END IF;
    wsh_util_core.api_post_call
            (
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors
             );
   --if l_return_status = warning
   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
   END IF;
 END IF;

   --Bugfix 4070732 {
  IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN --{
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN

     IF FND_API.TO_BOOLEAN(p_commit) THEN

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
     ELSE

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.Process_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
     END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF NOT(FND_API.TO_BOOLEAN(p_commit)) THEN
                   rollback to create_update_stop_grp;
                end if;
              END IF;

       IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
          OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
       THEN --{
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
       THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;
       END IF; --}

    END IF;
  END IF; --}
  --}
  --End of bug 4070732

 FND_MSG_PUB.Count_And_Get
     ( p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE );


 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;


EXCEPTION
  WHEN RECORD_LOCKED THEN
     -- OTM R12, glog proj, close cursors
     IF c_get_all_trip_stops%ISOPEN THEN
       CLOSE c_get_all_trip_stops;
     END IF;
     IF c_trip_info%ISOPEN THEN
        CLOSE c_trip_info;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
     wsh_util_core.add_message(x_return_status,l_module_name);
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            END IF;
         END IF;
      END IF;
      --}
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
     END IF;
     ROLLBACK TO create_update_stop_grp;

  WHEN FND_API.G_EXC_ERROR THEN
     -- OTM R12, glog proj, close cursors
     IF c_get_all_trip_stops%ISOPEN THEN
       CLOSE c_get_all_trip_stops;
     END IF;
     IF c_trip_info%ISOPEN THEN
        CLOSE c_trip_info;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            END IF;

         END IF;
      END IF;
      --}
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     ROLLBACK TO create_update_stop_grp;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     -- OTM R12, glog proj, close cursors
     IF c_get_all_trip_stops%ISOPEN THEN
       CLOSE c_get_all_trip_stops;
     END IF;
     IF c_trip_info%ISOPEN THEN
        CLOSE c_trip_info;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

         END IF;
      END IF;
      --}
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;
     ROLLBACK TO create_update_stop_grp;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     -- OTM R12, glog proj, close cursors
     IF c_get_all_trip_stops%ISOPEN THEN
       CLOSE c_get_all_trip_stops;
     END IF;
     IF c_trip_info%ISOPEN THEN
        CLOSE c_trip_info;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
              OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                rollback to create_update_stop_grp;
                X_return_status := l_return_status;
            END IF;
         END IF;
      END IF;
      --}
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
     END IF;

  WHEN OTHERS THEN
     -- OTM R12, glog proj, close cursors
     IF c_get_all_trip_stops%ISOPEN THEN
       CLOSE c_get_all_trip_stops;
     END IF;
     IF c_trip_info%ISOPEN THEN
        CLOSE c_trip_info;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

         END IF;
      END IF;
      --}
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     ROLLBACK TO create_update_stop_grp;

END CREATE_UPDATE_STOP;

--========================================================================
-- PROCEDURE : Create_Update_Stop      Wrapper API
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
    p_stop_info	             IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_trip_id                IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_stop_location_id       IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_stop_location_code     IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_planned_dep_date       IN   DATE DEFAULT FND_API.G_MISS_DATE,
    x_stop_id                OUT NOCOPY   NUMBER) IS

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Stop';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP';

l_in_rec        	stopInRecType;
l_pvt_stop_rec  	WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;

l_rec_attr_tab		WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_stop_out_tab  	stop_out_tab_type;

l_commit        	VARCHAR2(1):='F';

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
     wsh_debug_sv.log (l_module_name,'p_action_code',p_action_code);
     wsh_debug_sv.log (l_module_name,'p_stop_info.trip_id',p_stop_info.trip_id);
     wsh_debug_sv.log (l_module_name,'p_stop_info.trip_name',p_trip_name);
     wsh_debug_sv.log (l_module_name,'p_stop_info.stop_id',p_stop_info.stop_id);
     wsh_debug_sv.log (l_module_name,'p_stop_info.stop_location_id',p_stop_info.stop_location_id);
     wsh_debug_sv.log (l_module_name,'p_stop_info.stop_location_code',p_stop_info.stop_location_code);
     wsh_debug_sv.log (l_module_name,'p_stop_location_code',p_stop_location_code);
     wsh_debug_sv.log (l_module_name,'p_stop_info.stop_sequence_number',p_stop_info.stop_sequence_number);
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Create_Update_Stop');
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_stopgrp_to_pvt (
                p_grp_stop_rec => p_stop_info,
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

   l_in_rec.caller :='WSH_GRP';
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
      WSH_DEBUG_SV.log(l_module_name,'WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP x_return_status',x_return_status);
   END IF;

   IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_stop_out_tab.count > 0) THEN
       x_stop_id := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;
   END IF;

   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       , p_encoded => FND_API.G_FALSE);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END CREATE_UPDATE_STOP;


--========================================================================
-- PROCEDURE : Create_Update_Stop_New      Wrapper API   PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_stop_info             Attributes for the stop entity
--             p_stop_IN_rec           Input Attributes for the stop entity
--             p_stop_OUT_rec          Output Attributes for the stop entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trip_stops table with information
--             specified in p_stop_info. Use p_trip_id, p_trip_name, p_stop_location_id,
--             p_stop_location_code or p_planned_dep_date to update these values
--             on an existing stop.
--========================================================================
  PROCEDURE Create_Update_Stop_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_stop_info              IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_stop_IN_rec            IN  stopInRecType,
    x_stop_OUT_rec           OUT NOCOPY  stopOutRecType) IS

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Stop';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP_NEW';

l_in_rec                stopInRecType;
l_pvt_stop_rec          WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;

l_rec_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_stop_out_tab          stop_out_tab_type;

l_commit                VARCHAR2(1):='F';
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
    wsh_debug_sv.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'action_code',p_stop_IN_rec.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list );
    WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
    WSH_DEBUG_SV.log(l_module_name,'trip_id', p_stop_info.trip_id);
    WSH_DEBUG_SV.log(l_module_name,'stop_location_id', p_stop_info.stop_location_id);
    WSH_DEBUG_SV.log(l_module_name,'stop_sequence_number', p_stop_info.stop_sequence_number);
    WSH_DEBUG_SV.log(l_module_name,'planned_arrival_date', p_stop_info.planned_arrival_date);
    WSH_DEBUG_SV.log(l_module_name,'planned_departure_date', p_stop_info.planned_departure_date);
    WSH_DEBUG_SV.log(l_module_name,'actual_arrival_date', p_stop_info.actual_arrival_date);
    WSH_DEBUG_SV.log(l_module_name,'actual_departure_date', p_stop_info.actual_departure_date);
    WSH_DEBUG_SV.log(l_module_name,'departure_gross_weight', p_stop_info.departure_gross_weight);
    WSH_DEBUG_SV.log(l_module_name,'departure_net_weight', p_stop_info.departure_net_weight);
    WSH_DEBUG_SV.log(l_module_name,'weight_uom_code', p_stop_info.weight_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'departure_volume', p_stop_info.departure_volume);
    WSH_DEBUG_SV.log(l_module_name,'volume_uom_code', p_stop_info.volume_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'departure_seal_code', p_stop_info.departure_seal_code);
    WSH_DEBUG_SV.log(l_module_name,'departure_fill_percent', p_stop_info.departure_fill_percent);
    WSH_DEBUG_SV.log(l_module_name,'lock_stop_id', p_stop_info.departure_fill_percent);
    WSH_DEBUG_SV.log(l_module_name,'pending_interface_flag', p_stop_info.pending_interface_flag);
    WSH_DEBUG_SV.log(l_module_name,'transaction_header_id', p_stop_info.transaction_header_id);
    WSH_DEBUG_SV.log(l_module_name,'wsh_location_id', p_stop_info.wsh_location_id);
    WSH_DEBUG_SV.log(l_module_name,'tracking_drilldown_flag', p_stop_info.tracking_drilldown_flag);
    WSH_DEBUG_SV.log(l_module_name,'tracking_remarks', p_stop_info.tracking_remarks);
    WSH_DEBUG_SV.log(l_module_name,'carrier_est_departure_date', p_stop_info.carrier_est_departure_date);
    WSH_DEBUG_SV.log(l_module_name,'carrier_est_arrival_date', p_stop_info.carrier_est_arrival_date);
    WSH_DEBUG_SV.log(l_module_name,'loading_start_datetime', p_stop_info.loading_start_datetime);
    WSH_DEBUG_SV.log(l_module_name,'loading_end_datetime', p_stop_info.loading_end_datetime);
    WSH_DEBUG_SV.log(l_module_name,'unloading_start_datetime', p_stop_info.unloading_start_datetime);
    WSH_DEBUG_SV.log(l_module_name,'unloading_end_datetime', p_stop_info.unloading_end_datetime);
  END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_stopgrp_to_pvt (
                p_grp_stop_rec => p_stop_info,
                x_pvt_stop_rec => l_pvt_stop_rec,
                x_return_status => x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'map_stoppub_to_pvt x_return_status',x_return_status);
   END IF;
   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   l_rec_attr_tab(1):= l_pvt_stop_rec;

   WSH_INTERFACE_GRP.CREATE_UPDATE_STOP(
        p_api_version_number    => p_api_version_number,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => l_commit,
        p_in_rec                => p_stop_in_rec,
        p_rec_attr_tab          => l_rec_attr_tab,
        x_stop_out_tab          => l_stop_out_tab,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP x_return_status',x_return_status);
   END IF;

   IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_stop_out_tab.count > 0) THEN
       x_stop_out_rec := l_stop_out_tab(l_stop_out_tab.FIRST);
   END IF;

   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       , p_encoded => FND_API.G_FALSE);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END CREATE_UPDATE_STOP_NEW;
--Harmonizing Project **heali

-- API to get Stop Details
-- OTM R12, glog proj, removed the cursor to call populate_record API from WSHSTTHS/B
PROCEDURE get_stop_details_pvt
  (p_stop_id IN NUMBER,
   x_stop_rec OUT NOCOPY WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2) IS

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STOP_DETAILS_PVT';
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
     WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   WSH_TRIP_STOPS_PVT.Populate_Record(
     p_stop_id       => p_stop_id,
     x_stop_info     => x_stop_rec,
     x_return_status => x_return_status);

   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOPS_GRP.get_stop_details_pvt',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END get_stop_details_pvt;

--========================================================================
-- PROCEDURE : Lock_Related_Entity
--
--
-- PARAMETERS:
--             p_stop_attr_tab
--             x_return_status         return status
--             x_eligible_stop_id_tab
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   :  Procedure introduced through bug fix : BUG 2684692  by jckwok. code reviewed:
--========================================================================

  PROCEDURE Lock_Related_Entity
  (
    p_action_prms            IN   action_parameters_rectype,
    p_stop_attr_tab          IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    x_valid_ids_tab          OUT  NOCOPY WSH_UTIL_CORE.id_Tab_Type,
    x_return_status          OUT  NOCOPY VARCHAR2
   )
  IS
  --
  CURSOR c_pickup_deliveries(p_stop_id NUMBER, p_stop_loc_id NUMBER) IS
  SELECT wnd.delivery_id
  FROM wsh_new_deliveries wnd, wsh_delivery_legs wdl
  WHERE wnd.delivery_id = wdl.delivery_id
  AND wdl.pick_up_stop_id = p_stop_id
  AND wnd.initial_pickup_location_id = p_stop_loc_id;
  --
  CURSOR c_dropoff_deliveries(p_stop_id NUMBER, p_stop_loc_id NUMBER) IS
  SELECT wnd.delivery_id
  FROM wsh_new_deliveries wnd, wsh_delivery_legs wdl
  WHERE wnd.delivery_id = wdl.delivery_id
  AND wdl.drop_off_stop_id = p_stop_id
  AND wnd.ultimate_dropoff_location_id = p_stop_loc_id;
  --
  CURSOR c_stop_trip_info(p_stop_id NUMBER) IS
  SELECT wts.trip_id, wts.stop_location_id, wt.status_code
  FROM wsh_trip_stops wts, wsh_trips wt
  WHERE wts.stop_id = p_stop_id
  AND wts.trip_id = wt.trip_id;
--
  CURSOR c_unclosed_other_stops(p_trip_id NUMBER, p_stop_id NUMBER) IS
  SELECT wts.stop_id
  FROM wsh_trip_stops wts
  WHERE wts.trip_id = p_trip_id
  AND wts.status_code <> 'CL'
  AND wts.stop_id <> p_stop_id;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_RELATED_ENTITY';
--
l_count NUMBER := 1;
l_index NUMBER;
l_trip_id NUMBER;
l_stop_location_id NUMBER;
l_trip_status VARCHAR2(30);
l_dummy_stop_id NUMBER;

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name, 'Action_Code', p_action_prms.action_code);
       WSH_DEBUG_SV.log(l_module_name, 'Stop Action', p_action_prms.stop_action);
       WSH_DEBUG_SV.log(l_module_name, 'Phase ', p_action_prms.phase);
    END IF;

    IF p_action_prms.action_code = 'UPDATE-STATUS'
       AND p_action_prms.stop_action = 'CLOSE'
     THEN
    --{
     --need to loop through each record in p_stop_attr_tab
     l_index := p_stop_attr_tab.FIRST;
     WHILE l_index IS NOT NULL LOOP
        BEGIN
            SAVEPOINT LOCK_RELATED_ENTITY_GRP_LOOP;
            --
          OPEN c_stop_trip_info(p_stop_attr_tab(l_index).stop_id);
          FETCH c_stop_trip_info
          INTO l_trip_id, l_stop_location_id, l_trip_status;
          CLOSE c_stop_trip_info;

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Trip Id', l_trip_id);
             wsh_debug_sv.log(l_module_name, 'Trip Status', l_trip_status);
          END IF;

          /* With inbound logistics changes, New logic to lock trip is as follows:
           If trip is open, closing any stop requires trip status to be updated and hence trip's lock is needed.
           If trip is In-Transit, then lock the trip only if all other stops have been closed already.
          */

          IF l_trip_status = 'OP'
          THEN
          -- {
               WSH_TRIPS_PVT.lock_trip_no_compare(
                  p_trip_id => l_trip_id
               );

          ELSIF l_trip_status = 'IT'
          THEN
               OPEN c_unclosed_other_stops(l_trip_id, p_stop_attr_tab(l_index).stop_id);
               FETCH c_unclosed_other_stops INTO l_dummy_stop_id;
               IF c_unclosed_other_stops%NOTFOUND
               THEN
                   CLOSE c_unclosed_other_stops;

                   WSH_TRIPS_PVT.lock_trip_no_compare(
                        p_trip_id => l_trip_id
                        );
               ELSE
                 IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name, 'Atleast one Other stop not closed', l_dummy_stop_id);
                 END IF;
                  CLOSE c_unclosed_other_stops;
               END IF;
          -- }
          END IF;

         FOR c_pickup_del_rec IN c_pickup_deliveries(p_stop_attr_tab(l_index).stop_id, l_stop_location_id)
             LOOP
            -- {
                -- lock delivery
                WSH_NEW_DELIVERIES_PVT.lock_dlvy_no_compare(
                  p_delivery_id => c_pickup_del_rec.delivery_id
                  );
            -- }
             END LOOP;

         FOR c_dropoff_del_rec IN c_dropoff_deliveries(p_stop_attr_tab(l_index).stop_id, l_stop_location_id)
             LOOP
            -- {
                -- lock delivery
                WSH_NEW_DELIVERIES_PVT.lock_dlvy_no_compare(
                  p_delivery_id => c_dropoff_del_rec.delivery_id
                );

           --  }
             END LOOP;

      x_valid_ids_tab(l_count) := p_stop_attr_tab(l_index).stop_id;

      l_count := l_count + 1;

      EXCEPTION
        --
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION OR APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
          ROLLBACK TO LOCK_RELATED_ENTITY_GRP_LOOP;
          FND_MESSAGE.SET_NAME('WSH', 'WSH_STOP_DLVY_TRIP_LOCK');
         -- set token
          FND_MESSAGE.SET_TOKEN('STOP_ID', p_stop_attr_tab(l_index).stop_id);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO LOCK_RELATED_ENTITY_GRP_LOOP;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO LOCK_RELATED_ENTITY_GRP_LOOP;
        WHEN OTHERS THEN
          ROLLBACK TO LOCK_RELATED_ENTITY_GRP_LOOP;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --
      END;
        --
          l_index := p_stop_attr_tab.NEXT(l_index);
        END LOOP;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'Valid ids count', x_valid_ids_tab.count);
        END IF;

        -- Check for valid_ids_tab count.
        -- If valid ids count > 0 ,but less than the input table count, then return warning
        -- If valid ids count = 0, then return error
        IF p_stop_attr_tab.count > 0
        THEN
        -- {
            IF x_valid_ids_tab.count = 0
            THEN
            -- {
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_valid_ids_tab.count >0
               AND x_valid_ids_tab.count < p_stop_attr_tab.count
            THEN
               RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            -- }
            END IF;
        -- }
        END IF;

     --}
      END IF;



     IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
     END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
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
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERIES_GRP.LOCK_RELATED_ENTITY');

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

   END Lock_Related_Entity;



PROCEDURE Add_to_Delete_List(
    p_stop_tab          IN  WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab,
    p_caller            IN VARCHAR2,
    x_stop_delete_tab   OUT NOCOPY wsh_util_core.id_tab_type,
    x_trip_affected_tab OUT NOCOPY wsh_util_core.id_tab_type,
    x_return_status     OUT NOCOPY VARCHAR2)

IS

  CURSOR c_linked_stop(c_stop_id IN NUMBER, c_trip_id NUMBER)  IS
  SELECT physical_stop_id linked_stop_id,
       1 link_type ,
       trip_id
  FROM wsh_trip_stops
  WHERE  stop_id = c_stop_id
  AND    physical_stop_id IS NOT NULL
  AND    trip_id = c_trip_id
  UNION
  SELECT stop_id linked_stop_id,
       2 link_type ,
       trip_id
  FROM wsh_trip_stops
  WHERE  physical_stop_id = c_stop_id
  AND    status_code = 'OP'
  AND    trip_id = c_trip_id;

  i          NUMBER;
  j          NUMBER;
  k          NUMBER;
  l_stop_delete_tab   wsh_util_core.id_tab_type;

  l_tmp      NUMBER;

  l_stop_exist    BOOLEAN;
  l_trip_exist BOOLEAN;
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Add_to_Delete_List';

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
     wsh_debug_sv.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_stop_tab.count', p_stop_tab.count);
     WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller );
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_stop_delete_tab.delete;
  l_stop_delete_tab.delete;
  x_trip_affected_tab.delete;


  IF p_caller like 'FTE%' THEN
     i := p_stop_tab.first;

     WHILE i is not NULL LOOP

        l_stop_exist := FALSE;
        j :=  l_stop_delete_tab.first;
        WHILE j is not NULL LOOP
          IF l_stop_delete_tab(j) = p_stop_tab(i).stop_id THEN
            l_stop_exist := TRUE;
            EXIT;
          END IF;
          j := l_stop_delete_tab.next(j);
        END LOOP;

        IF not l_stop_exist THEN
          l_stop_delete_tab(l_stop_delete_tab.count+1) := p_stop_tab(i).stop_id;
          l_trip_exist := FALSE;
          k := x_trip_affected_tab.first;
          WHILE k is not NULL LOOP
             IF x_trip_affected_tab(k) = p_stop_tab(i).trip_id THEN
                l_trip_exist := TRUE;
                EXIT;
             END IF;
          k := x_trip_affected_tab.next(k);
          END LOOP;
          IF NOT l_trip_exist THEN
             x_trip_affected_tab(x_trip_affected_tab.count+1) := p_stop_tab(i).trip_id;
          END IF;

        END IF;

        FOR l_linked_stop IN c_linked_stop(p_stop_tab(i).stop_id, p_stop_tab(i).trip_id) LOOP
           l_stop_exist := FALSE;
           j :=  l_stop_delete_tab.first;
           WHILE j is not NULL LOOP
             IF l_stop_delete_tab(j) = l_linked_stop.linked_stop_id THEN
               l_stop_exist := TRUE;
               EXIT;
             END IF;
             j := l_stop_delete_tab.next(j);
           END LOOP;

           IF not l_stop_exist THEN
             l_stop_delete_tab(l_stop_delete_tab.count+1) := l_linked_stop.linked_stop_id;
           END IF;
        END LOOP;
     i :=  p_stop_tab.next(i);
     END LOOP;
  ELSE

     i := p_stop_tab.first;
     WHILE i is not NULL LOOP

        l_stop_delete_tab(l_stop_delete_tab.count+1) := p_stop_tab(i).stop_id;
        l_trip_exist := FALSE;
        k := x_trip_affected_tab.first;
        WHILE k is not NULL LOOP
           IF x_trip_affected_tab(k) = p_stop_tab(i).trip_id THEN
              l_trip_exist := TRUE;
              EXIT;
           END IF;
        k :=  x_trip_affected_tab.next(k);
        END LOOP;
        IF NOT l_trip_exist THEN
           x_trip_affected_tab(x_trip_affected_tab.count+1) := p_stop_tab(i).trip_id;
        END IF;
     i := p_stop_tab.next(i);
     END LOOP;
  END IF;

  x_stop_delete_tab := l_stop_delete_tab;


  IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

   WHEN Others THEN
      IF c_linked_stop%ISOPEN THEN
        close c_linked_stop;
      END IF;

      wsh_util_core.default_handler('WSH_TRIP_STOPS_VALIDATIONS.Add_to_Delete_List',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Add_to_Delete_List;

 -- end csun 10+ internal location

END WSH_TRIP_STOPS_GRP;

/
