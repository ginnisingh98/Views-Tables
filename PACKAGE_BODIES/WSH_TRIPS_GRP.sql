--------------------------------------------------------
--  DDL for Package Body WSH_TRIPS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIPS_GRP" as
/* $Header: WSHTRGPB.pls 120.7 2007/01/05 19:23:14 parkhj noship $ */


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_TRIPS_GRP';
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
--             p_trip_info             Attributes for the trip entity
--             p_trip_IN_rec           Input Attributes for the trip entity
--             p_trip_OUT_rec          Output Attributes for the trip entity
--             p_action_code           Trip action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing trip identified by p_trip_id or trip_name
--
--========================================================================
  PROCEDURE Trip_Action_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_trip_info          IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_IN_rec            IN  tripActionInRecType,
    p_trip_OUT_rec           OUT NOCOPY  tripActionOutRecType) IS


  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Trip_Action';

  l_action_prms        WSH_TRIPS_GRP.action_parameters_rectype;
  l_entity_id_tab      wsh_util_core.id_tab_type;
  -- <insert here your local variables declaration>
  trip_action_error EXCEPTION;

  l_trip_id               NUMBER := p_trip_info.trip_id;

  l_return_status VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION_NEW';
--
  BEGIN
  --  Standard call to check for call compatibility
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
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_trip_info.trip_id);
         WSH_DEBUG_SV.log(l_module_name,'NAME',p_trip_info.name);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ITEM_ID',p_trip_info.vehicle_item_id);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ORGANIZATION_ID',p_trip_info.vehicle_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',p_trip_info.carrier_id);
         WSH_DEBUG_SV.log(l_module_name,'SHIP_METHOD_CODE',p_trip_info.ship_method_code);
         WSH_DEBUG_SV.log(l_module_name,'SERVICE_LEVEL',p_trip_info.service_level);
         WSH_DEBUG_SV.log(l_module_name,'MODE_OF_TRANSPORT',p_trip_info.mode_of_transport);
         WSH_DEBUG_SV.log(l_module_name,'CONSOLIDATION_ALLOWED',p_trip_info.consolidation_allowed);
         WSH_DEBUG_SV.log(l_module_name,'PLANNED_FLAG',p_trip_info.planned_flag);
         WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_trip_info.status_code);
         WSH_DEBUG_SV.log(l_module_name,'FREIGHT_TERMS_CODE',p_trip_info.freight_terms_code);
         WSH_DEBUG_SV.log(l_module_name,'LANE_ID',p_trip_info.lane_id);
     END IF;
     --
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
                                              p_trip_info.name,
                                              x_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        raise trip_action_error;
     END IF;

     l_action_prms.caller                  := 'WSH_API';
     l_action_prms.action_code             := p_trip_IN_rec.action_code;
     l_action_prms.organization_id      := p_trip_info.VEHICLE_ORGANIZATION_ID;
     --l_action_prms.report_set_id        ??
     l_action_prms.override_flag        := p_trip_IN_rec.wv_override_flag;
     --bms
     l_entity_id_tab(1) :=  l_trip_id;

     WSH_INTERFACE_GRP.Trip_Action
      ( p_api_version_number =>  p_api_version_number,
        p_init_msg_list      =>  FND_API.G_FALSE,
        p_commit             =>  FND_API.G_TRUE,
        p_entity_id_tab      =>  l_entity_id_tab,
        p_action_prms        =>  l_action_prms,
        x_trip_out_rec       =>  p_trip_OUT_rec,
        x_return_status      =>  x_return_status,
        x_msg_count          =>  x_msg_count,
        x_msg_data           =>  x_msg_data);


     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,p_encoded => FND_API.G_FALSE
     );
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION

  WHEN trip_action_error THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_OI_TRIP_ACTION_ERROR');
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('TRIP_NAME', wsh_trips_pvt.get_name(l_trip_id));
     FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('TRIP',p_trip_IN_rec.action_code));
     wsh_util_core.add_message(x_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_ACTION_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_ACTION_ERROR');
END IF;
--
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
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
        );

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Trip_Action_New;
/*** OLD VERSIONS **/


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
--         p_trip_id               Trip identifier
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
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N') IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Trip_Action';

  -- <insert here your local variables declaration>
  trip_action_error EXCEPTION;

  l_trip_rows  wsh_util_core.id_tab_type;
  l_action_prms        WSH_TRIPS_GRP.action_parameters_rectype;
  l_trip_out_rec       WSH_TRIPS_GRP.tripActionOutRecType;


  l_trip_id               NUMBER := p_trip_id;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION';
--
  BEGIN
  --  Standard call to check for call compatibility
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
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'P_ACTION_CODE',P_ACTION_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_TRIP_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_WV_OVERRIDE_FLAG',P_WV_OVERRIDE_FLAG);
     END IF;
     --
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

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_TRIP_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_validate.validate_trip_name( l_trip_id, p_trip_name, x_return_status);

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     raise trip_action_error;
        END IF;

  l_trip_rows(1) := l_trip_id;
  l_action_prms.caller                  := 'WSH_API';
  l_action_prms.action_code             := p_action_code;
  l_action_prms.override_flag        := p_wv_override_flag;

  WSH_INTERFACE_GRP.Trip_Action
      ( p_api_version_number =>  p_api_version_number,
        p_init_msg_list      =>  FND_API.G_FALSE,
        p_commit             =>  FND_API.G_TRUE,
        p_entity_id_tab      =>  l_trip_rows,
        p_action_prms        =>  l_action_prms,
        x_trip_out_rec       =>  l_trip_out_rec,
        x_return_status      =>  x_return_status,
        x_msg_count          =>  x_msg_count,
        x_msg_data           =>  x_msg_data);

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,p_encoded => FND_API.G_FALSE
     );
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION

  WHEN trip_action_error THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_OI_TRIP_ACTION_ERROR');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('TRIP_NAME', wsh_trips_pvt.get_name(l_trip_id));
     FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('TRIP',p_action_code));
     wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_ACTION_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_ACTION_ERROR');
END IF;
--
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
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

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Trip_Action;


PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_action_prms            IN   action_parameters_rectype,
    p_rec_attr_tab           IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
    x_trip_out_rec           OUT  NOCOPY tripActionOutRecType,
    x_def_rec                OUT  NOCOPY   default_parameters_rectype,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)

IS
  l_trip_id_tab             wsh_util_core.id_tab_type;
  l_trip_rec_tab            WSH_TRIP_VALIDATIONS.trip_rec_tab_type;
  l_valid_id_tab            wsh_util_core.id_tab_type;
  l_dummy_ids               wsh_util_core.id_tab_type;
  l_valid_index_tab         wsh_util_core.id_tab_type;
  l_error_ids               wsh_util_core.id_tab_type;
  l_trip_rec                WSH_TRIPS_PVT.trip_rec_type;
  l_stop_rec                WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_dummy_doc_param         WSH_DOCUMENT_SETS.DOCUMENT_SET_TAB_TYPE;
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30):= 'Trip_Action';
  l_first                   NUMBER;
  l_index                   NUMBER;
  l_last                    NUMBER;
  l_counter                 NUMBER;
  l_num_warning             NUMBER := 0;
  l_num_errors              NUMBER := 0;
  l_trip_id                 NUMBER;
  l_num                     NUMBER;
  l_return_status           VARCHAR2(500);
  l_report_set_id           NUMBER := p_action_prms.report_set_id;
  l_trip_org                NUMBER;
  l_temp_trip_id_tab        wsh_util_core.id_tab_type;
  l_mbol_error_count        number;
  l_unassign_all            VARCHAR2(1);

--Compatibility Changes
    l_cc_validate_result		VARCHAR2(1);
    l_cc_failed_records			WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_group_info			WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_cc_line_groups			WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_msg_count				NUMBER;
    l_msg_data				VARCHAR2(2000);

    l_trip_info_tab			WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_trip_id_tab_temp  		wsh_util_core.id_tab_type;
    l_cc_count_success			NUMBER;
    b_cc_linefailed			BOOLEAN;

    --dummy tables for calling validate_constraint_wrapper
    l_cc_del_attr_tab	        WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab	        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab	        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab	        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids		        wsh_util_core.id_tab_type;
    l_cc_fail_ids		wsh_util_core.id_tab_type;

--Compatibility Changes

l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                            || 'TRIP_ACTION';
  e_req_field                EXCEPTION;
  --
  --
  -- J-IB-NPARIKH-{
  CURSOR dlvy_csr(p_trip_id NUMBER)
  IS
    SELECT  wdl.delivery_id, wt.name
    FROM    wsh_trip_stops wts,
            wsh_Delivery_legs wdl,
            wsh_new_deliveries wnd,
            wsh_trips wt
    WHERE   wt.trip_id                      = p_trip_id
    AND     wts.trip_id                     = p_trip_id
    AND     wdl.pick_up_stop_id             = wts.stop_id
    AND     wnd.delivery_id                 = wdl.delivery_id
    AND     wnd.initial_pickup_location_id  = wts.stop_location_id;
  --

  -- Cursor c_mbol_doc_set added for bug 4493263
   CURSOR c_mbol_doc_set IS
   SELECT WRS.Report_Set_Id
   FROM   Wsh_Report_Sets Wrs,
          Wsh_Report_Set_Lines Wrsl
   WHERE  Wrsl.Report_Set_Id = Wrs.Report_Set_Id
   AND    Wrs.Name = 'Master Bill of Lading';

-- Added for bug 4493263
   l_dummy_doc_set_params  wsh_document_sets.document_set_tab_type;
   l_dummy_id_tab          wsh_util_core.id_tab_type;
   l_pmbol_trip_id_tab     wsh_util_core.id_tab_type;
   l_doc_set_id            NUMBER;


  -- J - MBOL
  l_document_number VARCHAR2(50);
  --
  l_action_prms wsh_deliveries_grp.action_parameters_rectype;
  l_del_action_out_rec wsh_deliveries_grp.Delivery_Action_Out_Rec_Type;
  l_delivery_id_tab             wsh_util_core.id_tab_type;
  l_trip_name                   VARCHAR2(30);
  l_cnt                         NUMBER;
  e_end_of_api                  EXCEPTION;
  -- J-IB-NPARIKH-}

  -- Bug 3877951
  l_intransit_flag VARCHAR2(1);
  --Bugfix 4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

  -- K LPN CONV. rv
  l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  -- K LPN CONV. rv

  -- OTM R12 : packing ECO
  l_gc3_is_installed  VARCHAR2(1);
  -- End of OTM R12 : packing ECO

BEGIN
-- Bugfix 4070732
	IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
	THEN
		WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
		WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
	END IF;
	-- End of Code Bugfix 4070732
--
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   SAVEPOINT s_trip_action_grp;

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
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- J-IB-NPARIKH-{
    --
    --
    IF p_action_prms.action_code = 'GENERATE-ROUTING-RESPONSE'
    THEN
    --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.generateRoutingResponse',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIPS_ACTIONS.generateRoutingResponse
            (
              p_action_prms            => p_action_prms,
              p_rec_attr_tab           => p_rec_attr_tab,
              x_return_status          => l_return_status
            );
           --
            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling generate_routing_response',l_return_status);
            END IF;
            --
            wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warning,
            x_num_errors       => l_num_errors);
        --
        RAISE e_end_of_Api;
    --}
    END IF;
    --
    --
    -- J-IB-NPARIKH-}

   l_index := p_rec_attr_tab.FIRST;

   WHILE l_index IS NOT NULL LOOP
      l_trip_id_tab(l_index) := p_rec_attr_tab(l_index).trip_id;
      l_trip_rec_tab(l_index).trip_id := p_rec_attr_tab(l_index).trip_id;
      l_trip_rec_tab(l_index).status_code := p_rec_attr_tab(l_index).status_code;
-- J inbound logistics. populate new column shipments_type_flag jckwok
      l_trip_rec_tab(l_index).shipments_type_flag := p_rec_attr_tab(l_index).shipments_type_flag;
-- R12 Select Carrier
      l_trip_rec_tab(l_index).planned_flag := p_rec_attr_tab(l_index).planned_flag;
      l_trip_rec_tab(l_index).load_tender_status := p_rec_attr_tab(l_index).load_tender_status;
      l_trip_rec_tab(l_index).lane_id := p_rec_attr_tab(l_index).lane_id;

      --OTM R12, glog proj
      l_trip_rec_tab(l_index).ignore_for_planning := p_rec_attr_tab(l_index).ignore_for_planning;
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'trip_id',
                                            p_rec_attr_tab(l_index).trip_id);
        wsh_debug_sv.log (l_module_name,'status_code',
                                       p_rec_attr_tab(l_index).status_code);
      END IF;
      l_index := p_rec_attr_tab.NEXT(l_index);
   END LOOP;

   WSH_ACTIONS_LEVELS.set_validation_level (
                                  p_entity   =>  'TRIP',
                                  p_caller   =>  p_action_prms.caller,
                                  p_phase    =>  p_action_prms.phase,
                                  p_action   =>p_action_prms.action_code ,
                                  x_return_status => l_return_status);



   wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
-- R12 Select Carrier
-- Changes inside Is_Action_Enabled

      WSH_TRIP_VALIDATIONS.Is_Action_Enabled(
                p_trip_rec_tab            => l_trip_rec_tab,
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
     IF  NOT ( p_action_prms.caller = 'WSH_FSTRX'
              AND p_action_prms.action_code =  'DELETE'
             ) THEN  --BUG 4354579
       WSH_TRIPS_PVT.lock_trip(p_rec_attr_tab => p_rec_attr_tab,
                           p_caller       => p_action_prms.caller,
                           p_valid_index_tab  => l_valid_index_tab,
                           x_valid_ids_tab    => x_trip_out_rec.valid_ids_tab,
                           x_return_status => l_return_status);

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors,
                                   p_msg_data         => NULL,
                                   p_raise_error_flag => FALSE);

    END IF;
   END IF;

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_CONFIRM_DEFAULT_LVL) = 1  THEN

      WSH_TRIPS_ACTIONS.Get_Trip_Defaults(p_trip_id => l_trip_id_tab(1),
                                         p_trip_name => p_action_prms.trip_name,
                                         x_def_rec => x_def_rec,
                                         x_return_status => l_return_status);

      wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors,
                                   p_msg_data         => NULL,
                                   p_raise_error_flag => FALSE);


   END IF;


   IF(l_num_errors >0 ) THEN
     --
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
     --
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_num_warning',l_num_warning);
   END IF;


   IF l_num_warning > 0 AND p_action_prms.caller = 'WSH_FSTRX' THEN
         x_trip_out_rec.selection_issue_flag := 'Y';
   END IF;

   IF l_num_warning > 0 THEN
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
      --
   END IF;

   l_trip_id := p_rec_attr_tab(p_rec_attr_tab.FIRST).trip_id;

   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_trip_id', l_trip_id);
   END IF;

   IF p_action_prms.action_code in  ('PRINT-DOC-SETS', 'TRIP-CONFIRM')
   AND nvl(p_action_prms.phase,1) = 1
   AND p_action_prms.caller = 'WSH_FSTRX'
   THEN

     x_return_status := wsh_util_core.g_ret_sts_success;
		--
		-- Start code for Bugfix 4070732
		--
		   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
		      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
			 IF l_debug_on THEN
			       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;


                        WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
			 IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
			 END IF;
		         -- x_return_status is set to Success already, so
                         -- it will get the value for l_return_status
                         x_return_status := l_return_status;
		      END IF;
		   END IF;
		-- End of Code Bugfix 4070732
		--
     RETURN; -- Non-Generic Actions.
   END IF;



   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'C_TRIP_STOP_VALIDATION_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL));
   END IF;

   IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL) = 1 )
      AND ( p_action_prms.action_code IN ( 'FIRM', 'PLAN' , 'UNPLAN'))
      AND (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y')
   THEN
      FOR i IN l_trip_id_tab.FIRST..l_trip_id_tab.last LOOP
        BEGIN

          SAVEPOINT s_clean_loop_grp;

          WSH_TRIPS_GRP.get_trip_details_pvt(
                  p_trip_id       => l_trip_id_tab(i),
                  x_trip_rec      => l_trip_rec,
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

      IF l_num_errors >= l_trip_id_tab.COUNT THEN
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


    IF p_action_prms.action_code IN ('FIRM','PLAN','UNPLAN') THEN

      WSH_TRIPS_ACTIONS.plan (
              p_trip_rows      => l_trip_id_tab,
              p_action         => p_action_prms.action_code,
              x_return_status  => l_return_status
       );

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);

    /* J TP Release */
    ELSIF p_action_prms.action_code in ('IGNORE_PLAN', 'INCLUDE_PLAN') then
        Wsh_tp_release.change_ignoreplan_status
                   (p_entity        =>'TRIP',
                    p_in_ids        => l_trip_id_tab,
                    p_action_code   => p_action_prms.action_code,
                    x_return_status => l_return_status);
        --
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_status ',l_return_status);
        END IF;
         --
        wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warning,
           x_num_errors       => l_num_errors);
         --

    ELSIF p_action_prms.action_code = 'PICK-RELEASE' THEN

       WSH_PICK_LIST.Launch_Pick_Release(
              p_trip_ids       => l_trip_id_tab,
              p_stop_ids       => l_dummy_ids,
              p_delivery_ids   => l_dummy_ids,
              p_detail_ids     => l_dummy_ids,
              x_request_ids    => x_trip_out_rec.result_id_tab,
              x_return_status  => l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);


    ELSIF p_action_prms.action_code = 'TRIP-CONFIRM' THEN

        -- Bug 3877951
        IF p_action_prms.autoclose_flag = 'Y' THEN
           l_intransit_flag := 'Y';
        ELSE
           l_intransit_flag := p_action_prms.autointransit_flag;
        END IF;

        WSH_TRIPS_ACTIONS.Confirm_Trip(
			   p_trip_id               => l_trip_id_tab(1),
		  	   p_action_flag	   => p_action_prms.action_flag,
                           p_intransit_flag	   => p_action_prms.autointransit_flag,
                           p_close_flag		   => p_action_prms.autoclose_flag,
                           p_stage_del_flag        => p_action_prms.stage_del_flag,
			   p_report_set_id	   => p_action_prms.report_set_id,
			   p_ship_method	   => p_action_prms.ship_method,
                           p_actual_dep_date       => p_action_prms.actual_departure_date,
			   p_bol_flag		   => p_action_prms.bill_of_lading_flag,
			   p_defer_interface_flag  => p_action_prms.defer_interface_flag,
			   p_mbol_flag             => p_action_prms.mbol_flag, -- Added for MBOL
			   x_return_status	   => l_return_status);

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
               p_trip_ids            =>  l_trip_id_tab,
               p_stop_ids            =>  l_dummy_ids,
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
        -- before calling trip_weight_volume so the procedure will know
        -- to invoke update tms_interface_flag process.

        l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
        IF l_gc3_is_installed IS NULL THEN
          l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
        END IF;

        IF l_gc3_is_installed = 'Y' THEN
          WSH_WV_UTILS.G_RESET_WV := 'Y'; -- set to Y to enable the update
        END IF;
        -- End of OTM R12 : packing ECO

        WSH_TRIPS_ACTIONS.Trip_weight_volume(
               p_trip_rows      => l_trip_id_tab,
               p_override_flag  => p_action_prms.override_flag,
               p_start_departure_date => p_action_prms.actual_date,
               x_return_status  => l_return_status,
--tkt
               p_caller        => p_action_prms.caller
        );
        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);

        -- OTM R12 : packing ECO
        IF l_gc3_is_installed = 'Y' THEN
          WSH_WV_UTILS.G_RESET_WV := 'N'; -- after call, set it back to 'N'
        END IF;
        -- End of OTM R12 : packing ECO

    ELSIF p_action_prms.action_code = 'DELETE' THEN
        WSH_UTIL_CORE.delete(
                  p_type                => 'TRIP',
                  p_rows                => l_trip_id_tab,
                  x_return_status       => l_return_status
        );
        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);

    ELSIF p_action_prms.action_code IN ('PICK-RELEASE-UI' ,'RESOLVE-EXCEPTIONS-UI','FREIGHT-COSTS-UI')  THEN
       IF p_rec_attr_tab.COUNT > 1 THEN
           --bms set the message given in DLD
           FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
           FND_MSG_PUB.ADD;
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
--  Modified by 4493263
    ELSIF p_action_prms.action_code in ( 'GENERATE-PACK-SLIP', 'PRINT-PACK-SLIP' ) THEN

	l_cnt := 0;
        --
        FOR dlvy_rec IN dlvy_csr(p_rec_attr_tab(p_rec_attr_tab.FIRST).trip_id)
        LOOP
        --{
            l_trip_name := dlvy_rec.name;
            l_cnt       := l_cnt + 1;
            --
            l_delivery_id_tab(l_cnt) := dlvy_rec.delivery_id;
        --}
        END LOOP;
        --
        IF l_cnt = 0
        THEN
        --{
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NO_PICKUP_ERROR');
              FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
              x_return_status := wsh_util_core.g_ret_sts_error;
              wsh_util_core.add_message(x_return_status,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
        --}
        ELSE
            l_action_prms.caller        := 'WSH_GRP';
            l_action_prms.phase         := p_action_prms.phase;
            l_action_prms.action_code   := p_action_prms.action_code;
            --
            wsh_interface_grp.Delivery_Action(
              p_api_version_number     =>  p_api_version_number,
              p_init_msg_list          =>  FND_API.G_FALSE,
              p_commit                 =>  FND_API.G_FALSE,
              p_action_prms            =>  l_action_prms,
              p_delivery_id_tab        =>  l_delivery_id_tab,
              x_delivery_out_rec       =>  l_del_action_out_rec,
              x_return_status          =>  l_return_status,
              x_msg_count              =>  l_msg_count,
              x_msg_data               =>  l_msg_data);
            --
            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling delivery_action',l_return_status);
            END IF;

           wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);
        END IF;
--  Modified by 4493263
    ELSIF p_action_prms.action_code in ( 'GENERATE-BOL', 'PRINT-BOL' ) THEN

        l_cnt := 0;
        --
        FOR dlvy_rec IN dlvy_csr(p_rec_attr_tab(p_rec_attr_tab.FIRST).trip_id)
        LOOP
        --{
            l_trip_name := dlvy_rec.name;
            l_cnt       := l_cnt + 1;
            --
            l_delivery_id_tab(l_cnt) := dlvy_rec.delivery_id;
        --}
        END LOOP;
        --
        IF l_cnt = 0
        THEN
        --{
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NO_PICKUP_ERROR');
              FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
              x_return_status := wsh_util_core.g_ret_sts_error;
              wsh_util_core.add_message(x_return_status,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
        --}
        ELSE
            l_action_prms.caller        := 'WSH_GRP';
            l_action_prms.phase         := p_action_prms.phase;
            l_action_prms.action_code   := p_action_prms.action_code;
            --
            wsh_interface_grp.Delivery_Action(
              p_api_version_number     =>  p_api_version_number,
              p_init_msg_list          =>  FND_API.G_FALSE,
              p_commit                 =>  FND_API.G_FALSE,
              p_action_prms            =>  l_action_prms,
              p_delivery_id_tab        =>  l_delivery_id_tab,
              x_delivery_out_rec       =>  l_del_action_out_rec,
              x_return_status          =>  l_return_status,
              x_msg_count              =>  l_msg_count,
              x_msg_data               =>  l_msg_data);
            --
            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling delivery_action',l_return_status);
            END IF;


             wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                    x_num_warnings     =>l_num_warning,
                                    x_num_errors       =>l_num_errors);
        END IF;

    ELSIF p_action_prms.action_code = 'PRINT-MBOL' THEN
    --Bug 4493263
    --Instead of calling the PRINT_MBOL, we need to now trigger the document set.

      l_mbol_error_count := 0 ;
      --4493263 : Get the document set id for MBOL

      OPEN  c_mbol_doc_set;
      FETCH c_mbol_doc_set into l_doc_set_id;
      CLOSE c_mbol_doc_set;

      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_doc_set_id is', l_doc_set_id);
      END IF;

      FOR i IN l_trip_id_tab.FIRST..l_trip_id_tab.last LOOP

	WSH_MBOLS_PVT.Generate_MBOL(
                     p_trip_id          => l_trip_id_tab(i),
  		     x_sequence_number  => l_document_number,
		     x_return_status    => l_return_status );

        -- 4493263
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  l_mbol_error_count := l_mbol_error_count + 1;
	ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  -- Need to add another trip id tab which will have the trip ids for which generate mbol
	  -- was successful.And then use this for print Document sets.
	  l_pmbol_trip_id_tab(l_pmbol_trip_id_tab.COUNT +1) := l_trip_id_tab(i);
	END IF;

      END LOOP;

      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'l_pmbol_trip_id_tab.COUNT is', l_pmbol_trip_id_tab.COUNT );
      END IF;
      --Bug 4494236 : call Print doc set only if l_pmbol_trip_id_tab.count is > 0

      IF ( l_doc_set_id IS NOT NULL  AND l_pmbol_trip_id_tab.COUNT > 0 ) THEN
--         l_delivery_id_tab(1) := x_action_out_rec.x_delivery_id;

          WSH_DOCUMENT_SETS.Print_Document_Sets(
                      p_report_set_id       => l_doc_set_id,
                      p_organization_id     => p_action_prms.organization_id,
                      p_trip_ids            => l_pmbol_trip_id_tab,
                      p_stop_ids            => l_dummy_id_tab,
                      p_delivery_ids        => l_dummy_id_tab,
                      p_document_param_info => l_dummy_doc_set_params,
                      x_return_status       => l_return_status);
      END IF;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           l_mbol_error_count := l_mbol_error_count + 1;
      END IF;

      WSH_UTIL_CORE.api_post_call(
                     p_return_status    => l_return_status,
                     x_num_warnings     => l_num_warning,
                     x_num_errors       => l_num_errors,
		     p_raise_error_flag => FALSE );

      IF l_mbol_error_count > 0 THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINT_MBOL_ERROR');
        WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      ELSIF l_mbol_error_count = 0 THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINT_MBOL_SUCCESS');
        WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      END IF;

/*
-- Hiding project
-- R12 Select Carrier

    ELSIF p_action_prms.action_code = 'SELECT-CARRIER'  THEN
     IF wsh_util_core.fte_is_installed = 'Y' THEN
       IF p_rec_attr_tab.COUNT > 1 AND p_action_prms.caller = 'WSH_FSTRX' THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
           x_return_status := wsh_util_core.g_ret_sts_error;
           wsh_util_core.add_message(x_return_status,l_module_name);
           --FND_MSG_PUB.ADD;
           IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       WSH_TRIPS_ACTIONS.PROCESS_CARRIER_SELECTION(
              p_init_msg_list          =>  FND_API.G_FALSE,
              p_trip_id_tab            => l_trip_id_tab,
              p_caller                 => p_action_prms.caller, -- WSH_FSTRX / WSH_PUB /  WSH_GROUP/ FTE
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              x_return_status          => l_return_status );

       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);

     ELSE
        FND_MESSAGE.SET_NAME('WSH', 'FTE_NOT_INSTALLED');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,'FTE_NOT_INSTALLED');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

*/ -- Hiding project
    ELSIF p_action_prms.action_code IN ('REMOVE-CONSOL', 'UNASSIGN-ALL') THEN

       IF p_action_prms.action_code = 'UNASSIGN-ALL' THEN

          l_unassign_all := 'Y';

       ELSE

          l_unassign_all := 'N';

       END IF;


       WSH_TRIPS_ACTIONS.Remove_Consolidation(
                p_trip_id_tab   => l_trip_id_tab,
                p_unassign_all  => l_unassign_all,
                p_caller        => p_action_prms.caller,
                x_return_status => l_return_status);

       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Remove_Consolidation',l_return_status);
       END IF;
       wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                   x_num_warnings     =>l_num_warning,
                                   x_num_errors       =>l_num_errors);


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
           WSH_FTE_TP_INTEGRATION.trip_callback (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_TRUE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_prms            => p_action_prms,
                p_rec_attr_tab           => p_rec_attr_tab);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'after calling trip_callback l_return_status',l_return_status);
          END IF;

          wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warning,
               x_num_errors    => l_num_errors
               );
    END IF;--tp_is_installed


    --
    RAISE e_end_of_api;

EXCEPTION
    -- J-IB-NPARIKH-{
   WHEN e_end_of_api THEN
    IF l_num_warning > 0 THEN
        --RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

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
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
        END IF;

    --}
    END IF;
    --
    --
    -- K LPN CONV. rv

    IF p_commit = FND_API.G_TRUE THEN
	--
	-- Start code for Bugfix 4070732 for commit
	--
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
           -- The x_return_status at this point is either success or warning
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
           END IF;

	END IF;

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
          OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          COMMIT;
        ELSE
          ROLLBACK TO s_trip_action_grp;
        END IF;
	--
	-- End of Code Bugfix 4070732
	--
    END IF;

    --
    --Bugfix 4070732 { logical end of the API
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
    THEN --{
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
                 ROLLBACK TO s_trip_action_grp;
	    END IF;

	 END IF;
         --
      END IF;
    END IF; --}

    --}
    --End of bug 4070732
    --
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    ,p_encoded => FND_API.G_FALSE
    );

    IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    -- J-IB-NPARIKH-}

   WHEN e_req_field THEN
      ROLLBACK TO s_trip_action_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);

		--
		-- Start code for Bugfix 4070732
		--
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
		         IF l_return_status =
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                            x_return_status := l_return_status;
                         END IF;
		      END IF;
		   END IF;
		--
		-- End of Code Bugfix 4070732
		--

      FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
      , p_data  => x_msg_data
      ,p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;


   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO s_trip_action_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

		--
		-- Start code for Bugfix 4070732
		--
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

		         IF l_return_status =
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                            x_return_status := l_return_status;
                         END IF;
		      END IF;
		   END IF;
		--
		-- End of Code Bugfix 4070732
		--
      FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
      , p_data  => x_msg_data
      ,p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO s_trip_action_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

		--
		-- Start code for Bugfix 4070732
		--
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

		--
		-- End of Code Bugfix 4070732
		--
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      ,p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_UNEXPECTED_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
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

		--
		-- Start code for Bugfix 4070732
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
		         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                         THEN
                            x_return_status := l_return_status;
                         END IF;
		      END IF;
		   END IF;

         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
         OR  l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	 THEN
                 ROLLBACK TO s_trip_action_grp;
	 END IF;
		--
		-- End of Code Bugfix 4070732
		--
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      ,p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_WARNING');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN OTHERS THEN
      ROLLBACK TO s_trip_action_grp;
     wsh_util_core.default_handler('WSH_TRIPS_GRP.TRIP_ACTION',
                                                            l_module_name);


      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

		--
		-- Start code for Bugfix 4070732
		--
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

		--
		-- End of Code Bugfix 4070732
		--

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


--Harmonization Project **heali
PROCEDURE map_tripgrp_to_pvt(
   p_grp_trip_rec IN TRIP_PUB_REC_TYPE,
   x_pvt_trip_rec OUT NOCOPY WSH_TRIPS_PVT.TRIP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_TRIPPUB_TO_GRP';
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
       WSH_DEBUG_SV.log(l_module_name,'p_grp_trip_rec.TRIP_ID',p_grp_trip_rec.TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_grp_trip_rec.NAME',p_grp_trip_rec.NAME);
   END IF;
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_trip_rec.TRIP_ID			 := p_grp_trip_rec.TRIP_ID;
  x_pvt_trip_rec.NAME				 := p_grp_trip_rec.NAME;
  x_pvt_trip_rec.PLANNED_FLAG			 := p_grp_trip_rec.PLANNED_FLAG;
  x_pvt_trip_rec.ARRIVE_AFTER_TRIP_ID		 := p_grp_trip_rec.ARRIVE_AFTER_TRIP_ID;
  x_pvt_trip_rec.STATUS_CODE			 := p_grp_trip_rec.STATUS_CODE;
  x_pvt_trip_rec.VEHICLE_ITEM_ID		 := p_grp_trip_rec.VEHICLE_ITEM_ID;
  x_pvt_trip_rec.VEHICLE_ORGANIZATION_ID	 := p_grp_trip_rec.VEHICLE_ORGANIZATION_ID;
  x_pvt_trip_rec.VEHICLE_NUMBER			 := p_grp_trip_rec.VEHICLE_NUMBER;
  x_pvt_trip_rec.VEHICLE_NUM_PREFIX		 := p_grp_trip_rec.VEHICLE_NUM_PREFIX;
  x_pvt_trip_rec.CARRIER_ID			 := p_grp_trip_rec.CARRIER_ID;
  x_pvt_trip_rec.SHIP_METHOD_CODE		 := p_grp_trip_rec.SHIP_METHOD_CODE;
  x_pvt_trip_rec.ROUTE_ID			 := p_grp_trip_rec.ROUTE_ID;
  x_pvt_trip_rec.ROUTING_INSTRUCTIONS		 := p_grp_trip_rec.ROUTING_INSTRUCTIONS;
  x_pvt_trip_rec.ATTRIBUTE_CATEGORY		 := p_grp_trip_rec.ATTRIBUTE_CATEGORY;
  x_pvt_trip_rec.ATTRIBUTE1			 := p_grp_trip_rec.ATTRIBUTE1;
  x_pvt_trip_rec.ATTRIBUTE2			 := p_grp_trip_rec.ATTRIBUTE2;
  x_pvt_trip_rec.ATTRIBUTE3			 := p_grp_trip_rec.ATTRIBUTE3;
  x_pvt_trip_rec.ATTRIBUTE4			 := p_grp_trip_rec.ATTRIBUTE4;
  x_pvt_trip_rec.ATTRIBUTE5			 := p_grp_trip_rec.ATTRIBUTE5;
  x_pvt_trip_rec.ATTRIBUTE6			 := p_grp_trip_rec.ATTRIBUTE6;
  x_pvt_trip_rec.ATTRIBUTE7			 := p_grp_trip_rec.ATTRIBUTE7;
  x_pvt_trip_rec.ATTRIBUTE8			 := p_grp_trip_rec.ATTRIBUTE8;
  x_pvt_trip_rec.ATTRIBUTE9			 := p_grp_trip_rec.ATTRIBUTE9;
  x_pvt_trip_rec.ATTRIBUTE10			 := p_grp_trip_rec.ATTRIBUTE10;
  x_pvt_trip_rec.ATTRIBUTE11			 := p_grp_trip_rec.ATTRIBUTE11;
  x_pvt_trip_rec.ATTRIBUTE12			 := p_grp_trip_rec.ATTRIBUTE12;
  x_pvt_trip_rec.ATTRIBUTE13			 := p_grp_trip_rec.ATTRIBUTE13;
  x_pvt_trip_rec.ATTRIBUTE14			 := p_grp_trip_rec.ATTRIBUTE14;
  x_pvt_trip_rec.ATTRIBUTE15			 := p_grp_trip_rec.ATTRIBUTE15;
  x_pvt_trip_rec.CREATION_DATE			 := p_grp_trip_rec.CREATION_DATE;
  x_pvt_trip_rec.CREATED_BY			 := p_grp_trip_rec.CREATED_BY;
  x_pvt_trip_rec.LAST_UPDATE_DATE		 := p_grp_trip_rec.LAST_UPDATE_DATE;
  x_pvt_trip_rec.LAST_UPDATED_BY		 := p_grp_trip_rec.LAST_UPDATED_BY;
  x_pvt_trip_rec.LAST_UPDATE_LOGIN		 := p_grp_trip_rec.LAST_UPDATE_LOGIN;
  x_pvt_trip_rec.PROGRAM_APPLICATION_ID	         := p_grp_trip_rec.PROGRAM_APPLICATION_ID;
  x_pvt_trip_rec.PROGRAM_ID			 := p_grp_trip_rec.PROGRAM_ID;
  x_pvt_trip_rec.PROGRAM_UPDATE_DATE		 := p_grp_trip_rec.PROGRAM_UPDATE_DATE;
  x_pvt_trip_rec.REQUEST_ID			 := p_grp_trip_rec.REQUEST_ID;
  x_pvt_trip_rec.SERVICE_LEVEL			 := p_grp_trip_rec.SERVICE_LEVEL;
  x_pvt_trip_rec.MODE_OF_TRANSPORT		 := p_grp_trip_rec.MODE_OF_TRANSPORT;
  x_pvt_trip_rec.FREIGHT_TERMS_CODE		 := p_grp_trip_rec.FREIGHT_TERMS_CODE;
  x_pvt_trip_rec.CONSOLIDATION_ALLOWED		 := p_grp_trip_rec.CONSOLIDATION_ALLOWED;
  x_pvt_trip_rec.LOAD_TENDER_STATUS		 := p_grp_trip_rec.LOAD_TENDER_STATUS;
  x_pvt_trip_rec.ROUTE_LANE_ID			 := p_grp_trip_rec.ROUTE_LANE_ID;
  x_pvt_trip_rec.LANE_ID			 := p_grp_trip_rec.LANE_ID;
  x_pvt_trip_rec.SCHEDULE_ID			 := p_grp_trip_rec.SCHEDULE_ID;
  x_pvt_trip_rec.BOOKING_NUMBER			 := p_grp_trip_rec.BOOKING_NUMBER;
  x_pvt_trip_rec.ARRIVE_AFTER_TRIP_NAME	   	 := p_grp_trip_rec.ARRIVE_AFTER_TRIP_NAME;
  x_pvt_trip_rec.SHIP_METHOD_NAME		 := p_grp_trip_rec.SHIP_METHOD_NAME;
  x_pvt_trip_rec.VEHICLE_ITEM_DESC		 := p_grp_trip_rec.VEHICLE_ITEM_DESC;
  x_pvt_trip_rec.VEHICLE_ORGANIZATION_CODE	 := p_grp_trip_rec.VEHICLE_ORGANIZATION_CODE;
  x_pvt_trip_rec.CARRIER_REFERENCE_NUMBER        := p_grp_trip_rec.CARRIER_REFERENCE_NUMBER;
  x_pvt_trip_rec.CONSIGNEE_CARRIER_AC_NO         := p_grp_trip_rec.CONSIGNEE_CARRIER_AC_NO;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_tripgrp_to_pvt',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END map_tripgrp_to_pvt;

PROCEDURE Validate_Trip
	   (p_trip_info_tab		IN OUT 	NOCOPY WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
	    p_action_code           	IN     	VARCHAR2,
            x_valid_index_tab 		OUT 	NOCOPY wsh_util_core.id_tab_type,
	    x_return_status         	OUT    	NOCOPY VARCHAR2,
            p_caller                    IN      VARCHAR2 DEFAULT NULL) IS

l_debug_on BOOLEAN;
l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TRIP';

 CURSOR get_trip_info(p_trip_id NUMBER) IS
 SELECT consolidation_allowed, vehicle_item_id, vehicle_organization_id, ship_method_code, carrier_id, service_level, mode_of_transport, lane_id
 FROM	wsh_trips
 WHERE	trip_id= p_trip_id;

 l_db_trip_info        WSH_TRIPS_PVT.trip_rec_type;

l_ship_method_code	varchar2(32764);
l_num_errors 		NUMBER := 0;
l_num_warnings 		NUMBER := 0;
l_action 		VARCHAR2(100);
l_return_status		VARCHAR2(1);
x_msg_count 		NUMBER;
l_index			NUMBER;
x_msg_data  		varchar2(32764);
l_stop_rec 		WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
l_dummy 		VARCHAR2(3000);
l_dummy_master_org_id   NUMBER;
l_seg_array     	FND_FLEX_EXT.SegmentArray;
l_vehicle_org_id        NUMBER;

e_mixed_trip_error      EXCEPTION;   -- J-IB-NPARIKH

l_vehicle_name          VARCHAR2(2000); --Bug# 3565374
l_vehicle_org_name      VARCHAR2(240);
l_vehicle_type          NUMBER := 0;

--OTM R12, glog proj
l_gc3_is_installed      VARCHAR2(1);


BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --

  --OTM R12, glog proj
  x_return_status    := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- end of OTM R12, glog proj

  SAVEPOINT validate_trip_grp;
  IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code );
  END IF;


 l_index := p_trip_info_tab.FIRST;
 WHILE l_index IS NOT NULL LOOP
 BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'trip_id',p_trip_info_tab(l_index).trip_id);
      WSH_DEBUG_SV.log(l_module_name,'name',p_trip_info_tab(l_index).name);
      WSH_DEBUG_SV.log(l_module_name,'arrive_after_trip_id',p_trip_info_tab(l_index).arrive_after_trip_id);
      WSH_DEBUG_SV.log(l_module_name,'arrive_after_trip_name',p_trip_info_tab(l_index).arrive_after_trip_name);
      WSH_DEBUG_SV.log(l_module_name,'ship_method_name',p_trip_info_tab(l_index).ship_method_name);
      WSH_DEBUG_SV.log(l_module_name,'ship_method_code',p_trip_info_tab(l_index).ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'carrier_id',p_trip_info_tab(l_index).carrier_id);
      WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',p_trip_info_tab(l_index).mode_of_transport);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_organization_id',p_trip_info_tab(l_index).vehicle_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_organization_code',p_trip_info_tab(l_index).vehicle_organization_code);
      WSH_DEBUG_SV.log(l_module_name,'vehicle_item_id',p_trip_info_tab(l_index).vehicle_item_id);
      WSH_DEBUG_SV.log(l_module_name,'consolidation_allowed',p_trip_info_tab(l_index).consolidation_allowed);
      WSH_DEBUG_SV.log(l_module_name,'freight_terms_code',p_trip_info_tab(l_index).freight_Terms_code);
    END IF;

    SAVEPOINT validate_trip_loop_grp;

    IF p_action_code = 'UPDATE' THEN
	l_action := 'UPDATE';
    ELSE
	l_action := 'ADD';
    END IF;

    -- J-IB-NPARIKH-{
    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CREATE_MIXED_TRIP_LVL) = 1 )
    THEN
    --{
        IF p_trip_info_tab(l_index).shipments_type_flag = 'M'
        THEN
            -- You cannot create mixed trips through API
            --
            RAISE e_mixed_trip_error;
        END IF;
    --}
    END IF;
    --
    -- J-IB-NPARIKH-}

    --get the trip info from db for these specific validations
    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CARRIER_LVL) = 1 )
        OR ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VEH_ORG_LVL) = 1
	     AND p_trip_info_tab(l_index).vehicle_organization_id = fnd_api.G_MISS_NUM )
        OR ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONSOL_ALLW_LVL) = 1 )  THEN

		OPEN get_trip_info(p_trip_info_tab(l_index).trip_id);
		FETCH get_trip_info INTO
                                 l_db_trip_info.consolidation_allowed,
                                 l_db_trip_info.vehicle_item_id,
                                 l_db_trip_info.vehicle_organization_id,
                                 l_db_trip_info.ship_method_code,
                                 l_db_trip_info.carrier_id,
                                 l_db_trip_info.service_level,
                                 l_db_trip_info.mode_of_transport,
                                 l_db_trip_info.lane_id ;
	        CLOSE get_trip_info;
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_NAME_LVL) = 1 )  THEN
       IF (p_trip_info_tab(l_index).trip_id IS NOT NULL ) THEN
          l_dummy := NULL;
       ELSE
          l_dummy := p_trip_info_tab(l_index).name;
       END IF;

       WSH_UTIL_VALIDATE.Validate_Trip_Name (
 		p_trip_id       => p_trip_info_tab(l_index).trip_id,
		p_trip_name     => l_dummy,
		x_return_status => l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Trip_Name l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ARR_AFTER_TRIP_LVL) = 1 )  THEN
       WSH_TRIP_VALIDATIONS.Validate_Arrive_after_trip (
 		p_trip_id       	=> p_trip_info_tab(l_index).trip_id,
 		p_arr_after_trip_id	=> p_trip_info_tab(l_index).arrive_after_trip_id,
		p_arr_after_trip_name	=> p_trip_info_tab(l_index).arrive_after_trip_name,
		x_return_status 	=> l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_TRIP_VALIDATIONS.Validate_Arrive_after_trip l_return_status',
                                          l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CARRIER_LVL) = 1 )  THEN
       WSH_UTIL_VALIDATE.validate_freight_carrier(
            p_ship_method_name     => p_trip_info_tab(l_index).ship_method_name,
            x_ship_method_code     => p_trip_info_tab(l_index).ship_method_code,
            p_carrier_name         => NULL,
            x_carrier_id           => p_trip_info_tab(l_index).carrier_id,
            x_service_level        => p_trip_info_tab(l_index).service_level,
            x_mode_of_transport    => p_trip_info_tab(l_index).mode_of_transport,
            p_entity_type          => 'TRIP',
            p_entity_id            => p_trip_info_tab(l_index).trip_id,
            p_organization_id      => NULL,
            x_return_status        => l_return_status,
            p_caller               => p_caller);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Freight_Carrier l_return_status',l_return_status);
       END IF;

       -- OTM R12, glog project
       -- To handle the warning about Invalid Ship Method when the
       -- components are valid - Mode,Service and Carrier
       -- In 11.5.10, the Input parameter is p_in_rec, here it is p_caller
       -- Warning is converted to error when caller is FTE_TMS_INTEGRATION
       -- For Inbound messages, there is no way to warn user.
       IF (l_gc3_is_installed = 'Y' AND
           p_caller = 'FTE_TMS_INTEGRATION' AND
           l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Convert l_return_status',l_return_status);
         END IF;
         l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       END IF;
       -- OTM R12, end of glog project

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


       IF (nvl(l_db_trip_info.ship_method_code,FND_API.G_MISS_CHAR) <>
            nvl( p_trip_info_tab(l_index).ship_method_code,FND_API.G_MISS_CHAR) ) THEN
          WSH_BOLS_PVT.cancel_bol
             (  p_trip_id                    => p_trip_info_tab(l_index).trip_id
               ,p_old_ship_method_code       => l_db_trip_info.ship_method_code
               ,p_new_ship_method_code       => p_trip_info_tab(l_index).ship_method_code
               ,x_return_status              => l_return_status );

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_BOLS_PVT.cancel_bol l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
          WSH_MBOLS_PVT.cancel_mbol
             (  p_trip_id                    => p_trip_info_tab(l_index).trip_id
               ,x_return_status              => l_return_status );

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_MBOLS_PVT.cancel_mbol l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
       END IF;
    END IF;

   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_TERMS_LVL) = 1 THEN
      --
      wsh_util_validate.validate_freight_terms(
        p_freight_terms_code  => p_trip_info_tab(l_index).freight_terms_code,
        p_freight_terms_name  => NULL,
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
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VEH_ITEM_LVL) = 1 )  THEN
       IF (p_trip_info_tab(l_index).vehicle_item_id IS NOT NULL ) THEN
          l_dummy := NULL;
       ELSE
          l_dummy := p_trip_info_tab(l_index).vehicle_item_desc;
       END IF;

       IF  (p_trip_info_tab(l_index).vehicle_organization_id IS NULL
            AND  p_trip_info_tab(l_index).vehicle_item_id IS NOT NULL) THEN
          --removed get_vehicle_item_id cursor as this was not being used

          FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','vehicle_organization_id');
          wsh_util_core.add_message(l_return_status,l_module_name);
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       ELSE
          WSH_UTIL_VALIDATE.validate_item(
 		p_inventory_item_id 	=> p_trip_info_tab(l_index).vehicle_item_id,
 		p_inventory_item 	=> p_trip_info_tab(l_index).vehicle_item_desc,
 		p_organization_id	=> p_trip_info_tab(l_index).vehicle_organization_id,
 		p_seg_array		=> l_seg_array,
 		p_item_type		=> 'VEH_ITEM' ,
		x_return_status 	=> l_return_status);
       --Bug# 3565374 - Start
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_VEHICLE');
          wsh_util_core.add_message(l_return_status,l_module_name);
       END IF;
       --Bug# 3565374 - End

       END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_item -vehicle  l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);

    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VEH_ORG_LVL) = 1 )  THEN

	IF (p_trip_info_tab(l_index).vehicle_organization_id = fnd_api.G_MISS_NUM ) THEN      --Bug 3534623
                p_trip_info_tab(l_index).vehicle_organization_id:=l_db_trip_info.vehicle_organization_id;
	END IF;

       IF (p_trip_info_tab(l_index).vehicle_organization_id IS NOT NULL ) THEN
          l_dummy := NULL;
       ELSE
          l_dummy := p_trip_info_tab(l_index).vehicle_organization_code;
       END IF;
       WSH_UTIL_VALIDATE.validate_org(
 		p_org_id       => p_trip_info_tab(l_index).vehicle_organization_id,
		p_org_code     => p_trip_info_tab(l_index).vehicle_organization_code,
		x_return_status => l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_org l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


      -- Pack J, if FTE is installed, make sure this is a master organization.
      IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') AND  (p_trip_info_tab(l_index).vehicle_organization_id IS NOT NULL) THEN
         WSH_UTIL_CORE.get_master_from_org(
              p_org_id         => p_trip_info_tab(l_index).vehicle_organization_id,
              x_master_org_id  => l_dummy_master_org_id,
              x_return_status  => l_return_status);

              WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                          x_num_warnings     =>l_num_warnings,
                                          x_num_errors       =>l_num_errors);


         IF (p_trip_info_tab(l_index).vehicle_item_id IS NOT NULL) THEN
              IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'calling get_vehicle_org_id');
              END IF;

              WSH_FTE_INTEGRATION.GET_VEHICLE_ORG_ID
                (p_inventory_item_id         => p_trip_info_tab(l_index).vehicle_item_id,
                 x_vehicle_org_id            => l_vehicle_org_id,
                 x_return_status             => l_return_status);

        --Bug# 3565374 - Start
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;
		       l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => p_trip_info_tab(l_index).VEHICLE_ITEM_ID,
								   p_organization_id => p_trip_info_tab(l_index).VEHICLE_ORGANIZATION_ID);
		       l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => p_trip_info_tab(l_index).VEHICLE_ORGANIZATION_ID);
		       FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
		       FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
		       FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
		       FND_MSG_PUB.ADD;
		     END IF;
		  END IF;
        --Bug# 3565374 - End
              WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                          x_num_warnings     =>l_num_warnings,
                                          x_num_errors       =>l_num_errors);

         ELSE
              --populate with master org
              l_vehicle_org_id:=l_dummy_master_org_id;
         END IF;

         IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'vehicle org passed in: '|| p_trip_info_tab(l_index).vehicle_organization_id||'  master org: '|| l_dummy_master_org_id||' vehicle org found: '||l_vehicle_org_id);
         END IF;

         --bug 3437995 - if master org is not passed, do not error out, get
         --the master org and populate vehicle org with that
         p_trip_info_tab(l_index).vehicle_organization_id:=l_vehicle_org_id;
      END IF;

    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_SMC_LVL) = 1 )  THEN
       IF (p_trip_info_tab(l_index).ship_method_code IS NOT NULL ) THEN
          l_dummy := NULL;
       ELSE
          l_dummy := p_trip_info_tab(l_index).ship_method_name;
       END IF;
       WSH_UTIL_VALIDATE.validate_ship_method(
 		p_ship_method_code	=> p_trip_info_tab(l_index).ship_method_code,
		p_ship_method_name	=> l_dummy,
		x_return_status 	=> l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.validate_ship_method l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONSOL_ALLW_LVL) = 1 )  THEN
       WSH_TRIP_VALIDATIONS.Validate_Consol_Allowed(
 		p_trip_info       	=> p_trip_info_tab(l_index),
                p_db_trip_info          => l_db_trip_info,
		x_return_status 	=> l_return_status);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_TRIP_VALIDATIONS.Validate_Consol_Allowed l_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    END IF;

    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
       IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STOP_VALIDATION_LVL) = 1 )  THEN

         -- 4106444 -skattama
         -- After Trip is modified
         -- If mode is other than TRUCK, the stops should not be greater than 2
         WSH_UTIL_VALIDATE.Validate_Trip_MultiStops (
              p_trip_id            => p_trip_info_tab(l_index).trip_id,
              p_mode_of_transport  => p_trip_info_tab(l_index).mode_of_transport,
              x_return_status      => l_return_status);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_MultiStops l_return_status',l_return_status);
         END IF;
         WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                     x_num_warnings     =>l_num_warnings,
                                     x_num_errors       =>l_num_errors);

         -- end 4106444

          WSH_FTE_INTEGRATION.trip_stop_validations
               (p_stop_rec		=> l_stop_rec,
                p_trip_rec		=> p_trip_info_tab(l_index),
                p_action		=> l_action,
                x_return_status		=> l_return_status);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_FTE_INTEGRATION.trip_stop_validations l_return_status',l_return_status);
          END IF;
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
       END IF;
    END IF;

    x_valid_index_tab(x_valid_index_tab.COUNT + 1) := l_index;

 EXCEPTION
     -- J-IB-NPARIKH-{
     WHEN e_mixed_trip_error THEN
        ROLLBACK TO validate_trip_loop_grp;
        l_num_errors := l_num_errors + 1;
        FND_MESSAGE.SET_NAME('WSH', 'WSH_MIXED_TRIP_ERROR');
        WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'e_mixed_trip_error  exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        END IF;
        -- J-IB-NPARIKH-}

    WHEN fnd_api.g_exc_error THEN
       Rollback to validate_trip_loop_grp;

    WHEN fnd_api.g_exc_unexpected_error THEN
       Rollback to validate_trip_loop_grp;

    WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       ROLLBACK TO SAVEPOINT validate_trip_loop_grp;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END;
 l_index := p_trip_info_tab.NEXT(l_index);
 END LOOP;

 IF (l_num_errors = p_trip_info_tab.count ) THEN
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
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     ROLLBACK TO SAVEPOINT validate_trip_grp;

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
     ROLLBACK TO SAVEPOINT validate_trip_grp;

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
     -- Bug 2741482
     --ROLLBACK TO SAVEPOINT validate_trip_grp;

  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.Validate_Trip');
      FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
     ROLLBACK TO SAVEPOINT validate_trip_grp;

END Validate_Trip;


--========================================================================
-- PROCEDURE : Create_Update_Trip      CORE API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_trip_info_tab         Table of Attributes for the trip entity
--             p_IN_rec                Input Attributes for the trip entity
--             p_OUT_rec               Table of output Attributes for the trip entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Core procedure to perform Create and Update action on Trip. This is called by all Wrapper Procedures
--========================================================================
PROCEDURE Create_Update_Trip(
        p_api_version_number     IN      NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        p_trip_info_tab          IN     WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
        p_In_rec                 IN     tripInRecType,
        x_Out_Tab                OUT    NOCOPY trip_Out_Tab_Type,
        x_return_status          OUT    NOCOPY  VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY  VARCHAR2) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Update_Trip';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP';

RECORD_LOCKED          EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

l_num_errors 		NUMBER :=0;
l_num_warnings 		NUMBER :=0;
l_index			NUMBER;
l_sp_disabled_list      VARCHAR2(30) := 'get_disabled_list';
l_return_status 	VARCHAR2(1);

x_valid_index_tab	wsh_util_core.id_tab_type;
l_p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_trip_info_tab		WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_pvt_trip_rec          WSH_TRIPS_PVT.TRIP_REC_TYPE;

--Compatibility Changes
    l_cc_validate_result		VARCHAR2(1);
    l_cc_failed_records			WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_group_info			WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_cc_line_groups			WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_msg_count				NUMBER;
    l_msg_data				VARCHAR2(2000);

    l_trip_info_tab_temp		WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_count_success			NUMBER;
    b_cc_linefailed			BOOLEAN;

    --dummy tables for calling validate_constraint_wrapper
    l_cc_del_attr_tab	        WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab	        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab	        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab	        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids		        wsh_util_core.id_tab_type;
    l_cc_fail_ids		wsh_util_core.id_tab_type;

--Compatibility Changes
  CURSOR c_getorgcarriersmc (p_tripid NUMBER) IS
  SELECT wnd.organization_id, wnd.name, wt.ship_method_code, wt.carrier_id
  FROM wsh_new_deliveries wnd, wsh_trip_stops wts, wsh_delivery_legs wdl, wsh_trips wt
  WHERE wnd.delivery_id=wdl.delivery_id
      and wdl.pick_up_stop_id=wts.stop_id
      and wt.trip_id = p_tripid
      and wt.trip_id=wts.trip_id
      and wt.ignore_for_planning<>'Y'
      and rownum=1;

 l_wh_type VARCHAR2(3);
 l_organization_id     wsh_new_deliveries.organization_id%TYPE;
 l_smc                 wsh_trips.ship_method_code%TYPE;
 l_carrier_id          wsh_trips.carrier_id%TYPE;
 l_param_info          WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
 l_autofirm_loadtender_trip Varchar2(10) := null;

 l_action_prms        WSH_TRIPS_GRP.action_parameters_rectype;
 l_action VARCHAR2(20);
 l_trip_ids wsh_util_core.id_tab_type;

BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 SAVEPOINT create_update_trip_grp;
 IF l_debug_on THEN
    wsh_debug_sv.push (l_module_name, 'Create_Update_Trip');
    wsh_debug_sv.log (l_module_name,'p_in_rec.action_code',p_in_rec.action_code);
 END IF;

 IF l_debug_on THEN
   FOR i in 1..p_trip_info_tab.count
   LOOP
     wsh_debug_sv.log (l_module_name,'p_shipmethod_code',p_trip_info_tab(i).ship_method_code);
   END LOOP;
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

 IF (p_in_rec.caller IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.caller');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

-- for Load Tender
 IF (p_in_rec.action_code IS NULL OR p_in_rec.action_code NOT IN ('CREATE','UPDATE','FTE_LOAD_TENDER') ) THEN
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

 IF (p_trip_info_tab.count = 0 ) THEN
    l_p_trip_info_tab(1):=l_pvt_trip_rec;
 ELSE
    l_p_trip_info_tab:=p_trip_info_tab;
 END IF;


 WSH_ACTIONS_LEVELS.set_validation_level (
        p_entity                => 'TRIP',
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
    l_index := l_p_trip_info_tab.FIRST;
    WHILE l_index IS NOT NULL LOOP
    BEGIN
       SAVEPOINT l_sp_disabled_list;
       WSH_TRIP_VALIDATIONS.get_disabled_list(
	p_trip_rec			=>   	l_p_trip_info_tab(l_index),
	p_in_rec			=>   	p_in_rec,
	x_return_status			=> 	l_return_status,
	x_msg_count			=>   	x_msg_count,
	x_msg_data			=>	x_msg_data,
	x_trip_rec	  		=> 	l_trip_info_tab(l_index));

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          Rollback to l_sp_disabled_list;

       WHEN fnd_api.g_exc_unexpected_error THEN
          Rollback to l_sp_disabled_list;

       WHEN others THEN
          Rollback to l_sp_disabled_list;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    l_index := l_p_trip_info_tab.NEXT(l_index);
    END LOOP;

    IF (l_num_errors = l_p_trip_info_tab.COUNT) THEN
       raise fnd_api.g_exc_error;
    END IF;
 ELSE
    l_trip_info_tab := l_p_trip_info_tab;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'count, l_num_errors',l_trip_info_tab.COUNT ||','||l_num_errors);
 END IF;

  IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_CONSTRAINTS_LVL) = 1  THEN --{
    --Compatiblity Changes
    IF (wsh_util_core.fte_is_installed = 'Y')  THEN

      WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
         p_api_version_number   =>  p_api_version_number,
         p_init_msg_list        =>  p_init_msg_list,
         p_entity_type          =>  'T',
         p_target_id            =>  null,
         p_action_code          =>  p_in_rec.action_code,
         p_del_attr_tab         =>  l_cc_del_attr_tab,
         p_det_attr_tab         =>  l_cc_det_attr_tab,
         p_trip_attr_tab        =>  l_trip_info_tab,
         p_stop_attr_tab        =>  l_cc_stop_attr_tab,
         p_in_ids               =>  l_cc_in_ids,
         x_fail_ids             =>  l_cc_fail_ids,
         x_validate_result          =>  l_cc_validate_result,
         x_failed_lines             =>  l_cc_failed_records,
         x_line_groups              =>  l_cc_line_groups,
         x_group_info               =>  l_cc_group_info,
         x_msg_count                =>  l_msg_count,
         x_msg_data                 =>  l_msg_data,
         x_return_status            =>  l_return_status);


      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_wrap',l_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_wrap',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_wrap',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_wrap',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_wrap',l_cc_failed_records.COUNT);
        wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_wrap',l_cc_line_groups.COUNT);
        wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_wrap',l_cc_group_info.COUNT);
      END IF;
      --

    IF l_return_status=wsh_util_core.g_ret_sts_error THEN
      --fix p_rec_attr_tab to have only successful records
        l_cc_count_success:=1;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'trip_info_tab count before removing failed lines',l_trip_info_tab.COUNT);
        END IF;

     IF l_cc_fail_ids.COUNT>0 AND l_trip_info_tab.COUNT>0 THEN
       FOR i in l_trip_info_tab.FIRST..l_trip_info_tab.LAST LOOP
        b_cc_linefailed:=FALSE;
        FOR j in l_cc_fail_ids.FIRST..l_cc_fail_ids.LAST LOOP
           IF (l_trip_info_tab(i).trip_id=l_cc_fail_ids(j)) THEN
            b_cc_linefailed:=TRUE;
           END IF;
        END LOOP;
        IF (NOT(b_cc_linefailed)) THEN
            l_trip_info_tab_temp(l_cc_count_success):=l_trip_info_tab(i);
            l_cc_count_success:=l_cc_count_success+1;
        END IF;
       END LOOP;
     END IF;

      IF l_trip_info_tab_temp.COUNT>0 THEN
        l_trip_info_tab:=l_trip_info_tab_temp;
      END IF;

      IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'trip_info_tab count after removing failed lines',l_trip_info_tab.COUNT);
      END IF;

   END IF;


    IF l_return_status=wsh_util_core.g_ret_sts_error and l_cc_fail_ids.COUNT<>l_trip_info_tab.COUNT THEN
       l_return_status:=wsh_util_core.g_ret_sts_warning;
    END IF;

      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);


  END IF;
    --Compatiblity Changes
 END IF;--}

 l_num_errors:= 0;

IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name,'p_in_rec.caller',p_in_rec.caller);
END IF;

 Validate_Trip(
	p_trip_info_tab		=> l_trip_info_tab,
	p_action_code		=> p_in_rec.action_code,
	x_valid_index_tab	=> x_valid_index_tab,
	x_return_status		=> l_return_status,
        p_caller                => p_in_rec.caller);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Validate_trip l_return_status',l_return_status);
 END IF;

 WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


 l_index := x_valid_index_tab.FIRST;
 WHILE l_index IS NOT NULL LOOP
 BEGIN
    SAVEPOINT l_trip;
    IF (p_in_rec.action_code = 'CREATE' ) THEN
       WSH_TRIPS_PVT.CREATE_TRIP (
	p_trip_info     	=>	l_trip_info_tab(x_valid_index_tab(l_index)),
	x_rowid                 => 	x_out_Tab(l_index).rowid,
	x_trip_id             	=>	x_out_Tab(l_index).trip_id,
	x_name             	=>	x_out_Tab(l_index).trip_name,
	x_return_status      	=>	l_return_status);

        WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
    ELSIF (p_in_rec.action_code = 'UPDATE' ) THEN

       IF p_in_rec.caller = 'WSH_FSTRX' THEN
          -- fill in the columns not queried into STF or QSUI
         SELECT
            ROUTING_RULE_ID,
            APPEND_FLAG,
            RANK_ID
         INTO
            l_trip_info_tab(x_valid_index_tab(l_index)).ROUTING_RULE_ID,
            l_trip_info_tab(x_valid_index_tab(l_index)).APPEND_FLAG,
            l_trip_info_tab(x_valid_index_tab(l_index)).RANK_ID
         FROM WSH_TRIPS
         WHERE ROWID = l_trip_info_tab(x_valid_index_tab(l_index)).rowid;
       END IF;

       WSH_TRIPS_PVT.UPDATE_TRIP(
	p_rowid                 =>	l_trip_info_tab(x_valid_index_tab(l_index)).rowid,
	p_trip_info     	=>      l_trip_info_tab(x_valid_index_tab(l_index)),
	x_return_status      	=> 	l_return_status);

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);

       --J TP Release : firm/plan/unplan trip based on parameter for load tender update
       -- moved update statement  from previous release to table handler
       IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;

       WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(
                        x_Param_Info    => l_param_info,
                        x_return_status => l_return_status);

       WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);

       l_autofirm_loadtender_trip:=l_param_info.AUTOFIRM_LOAD_TENDERED_TRIPS;


       IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.log(l_module_name,'load_tender_status',l_trip_info_tab(x_valid_index_tab(l_index)).load_tender_status);
               WSH_DEBUG_SV.log(l_module_name,'l_autofirm_loadtender_trip',l_autofirm_loadtender_trip);
       END IF;
       IF l_trip_info_tab(x_valid_index_tab(l_index)).load_tender_status is not null AND l_autofirm_loadtender_trip IN ('Y','F') THEN
         IF l_trip_info_tab(x_valid_index_tab(l_index)).load_tender_status IN ('TENDERED','ACCEPTED','RETENDERED', 'AUTO_ACCEPTED') THEN
           IF l_autofirm_loadtender_trip='Y' THEN
              l_action:='PLAN';
           ELSE
              l_action:='FIRM';
           END IF;
         ELSIF l_trip_info_tab(x_valid_index_tab(l_index)).load_tender_status IN ('REJECTED','SHIPPER_CANCELLED') THEN
           l_action:='UNPLAN';
         END IF;
         IF l_action is not null THEN
            l_trip_ids(1):=l_trip_info_tab(x_valid_index_tab(l_index)).trip_id;
            wsh_trips_actions.Plan(p_trip_rows   => l_trip_ids,
                                p_action         => l_action,
                                x_return_status  => l_return_status);

             WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);
         END IF;
      END IF;--call is for load tender update

       /***TP Release**/
       --TP Release : if carrier or smc is changed, if they are CMS/TPW, call change_ignoreplan_status
       l_smc:=l_trip_info_tab(x_valid_index_tab(l_index)).ship_method_code;
       l_carrier_id:=l_trip_info_tab(x_valid_index_tab(l_index)).carrier_id;
       IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'smc',l_smc);
               WSH_DEBUG_SV.log(l_module_name,'carrier_id',l_carrier_id);
       END IF;
       IF (l_carrier_id is not null OR l_smc is not null)
           AND WSH_UTIL_CORE.TP_Is_Installed = 'Y' THEN

             FOR cur in c_getorgcarriersmc (l_trip_info_tab(x_valid_index_tab(l_index)).trip_id) LOOP
                   l_organization_id:=cur.organization_id;
                   IF l_smc is null THEN
                       l_smc:=cur.ship_method_code;
                   END IF;
                   IF l_carrier_id is null THEN
                       l_carrier_id:=cur.carrier_id;
                   END IF;
                   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
				(p_organization_id => l_organization_id,
				 x_return_status   => l_return_status,
				 p_carrier_id	   => l_carrier_id,
				 p_ship_method_code=> l_smc,
				 p_msg_display	   => 'N');

                   IF l_debug_on THEN
		         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type organization_id,l_wh_type,l_return_status',l_organization_id||l_wh_type||l_return_status);
		         WSH_DEBUG_SV.log(l_module_name,'carrier_id',l_carrier_id);
		         WSH_DEBUG_SV.log(l_module_name,'smc',l_smc);
          	   END IF;

                   WSH_UTIL_CORE.api_post_call(
                       p_return_status    => l_return_status,
                       x_num_warnings     => l_num_warnings,
                       x_num_errors       => l_num_errors);

                   --if org is a tpw/cms and current ignore plan is 'N', change ignore plan by
                   --calling api.

                   IF nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS') THEN
                        l_trip_ids(1):=l_trip_info_tab(x_valid_index_tab(l_index)).trip_id;
                        wsh_tp_release.change_ignoreplan_status
                                     (p_entity         => 'TRIP',
                                      p_in_ids         => l_trip_ids,
                                      p_action_code    => 'IGNORE_PLAN',
                                      x_return_status  => l_return_status);
                       IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_sttatus',l_return_status);
                       END IF;
                       WSH_UTIL_CORE.api_post_call(
                         p_return_status    => l_return_status,
                         x_num_warnings     => l_num_warnings,
                         x_num_errors       => l_num_errors);
                   END IF;
             END LOOP;

             -- TP call back to unfirm continuous move or delete continuous move or
             -- any other action that will be done in the future based on the action performed
             IF  WSH_UTIL_CORE.TP_IS_INSTALLED='Y' THEN
                 l_action_prms.action_code:=p_in_rec.action_code;
                 l_action_prms.caller:=p_in_rec.caller;
                 WSH_FTE_TP_INTEGRATION.trip_callback (
                     p_api_version_number     => 1.0,
                     p_init_msg_list          => FND_API.G_TRUE,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data,
                     p_action_prms            => l_action_prms,
                     p_rec_attr_tab           => l_trip_info_tab);

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'after calling trip_callback l_return_status',l_return_status);
                 END IF;

                 wsh_util_core.api_post_call(
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                     );
             END IF;--tp_is_installed

          END IF;
          /***TP Release**/

    END IF;--create or update

 EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          Rollback to l_trip;

       WHEN fnd_api.g_exc_unexpected_error THEN
          Rollback to l_trip;

       WHEN others THEN
          Rollback to l_trip;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    l_index := x_valid_index_tab.NEXT(l_index);
 END LOOP;

 IF (l_num_errors = l_trip_info_tab.count ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF (l_num_errors > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSIF (l_num_warnings > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;

 IF FND_API.To_Boolean( p_commit ) THEN
  COMMIT WORK;
 END IF;

 FND_MSG_PUB.Count_And_Get
     ( p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE );

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN RECORD_LOCKED THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
     wsh_util_core.add_message(x_return_status,l_module_name);
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
     END IF;
     ROLLBACK TO create_update_trip_grp;

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
     ROLLBACK TO create_update_trip_grp;

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
     ROLLBACK TO create_update_trip_grp;

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
     -- Bug 2741482
     --ROLLBACK TO create_update_trip_grp;

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
     ROLLBACK TO create_update_trip_grp;

END CREATE_UPDATE_TRIP;

--========================================================================
-- PROCEDURE : Create_Update_Trip      Wrapper
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_trip_info             Attributes for the trip entity
--             p_trip_IN_rec           Input Attributes for the trip entity
--             p_trip_OUT_rec          Output Attributes for the trip entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trips table with information
--             specified in p_trip_info
--========================================================================

PROCEDURE Create_Update_Trip_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_trip_info          IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_IN_rec            IN  tripInRecType,
    p_trip_OUT_rec           OUT NOCOPY  tripOutRecType) IS

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Trip';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP_NEW';

l_num_errors NUMBER;
l_num_warnings NUMBER;
l_pvt_trip_rec 		WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_trip_info_tab         WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_out_tab		trip_out_tab_type;
l_commit		VARCHAR2(1):='F';
BEGIN
  --  Standard call to check for call compatibility
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
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_trip_info.trip_id);
         WSH_DEBUG_SV.log(l_module_name,'NAME',p_trip_info.name);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ITEM_ID',p_trip_info.vehicle_item_id);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ORGANIZATION_ID',p_trip_info.vehicle_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',p_trip_info.carrier_id);
         WSH_DEBUG_SV.log(l_module_name,'SHIP_METHOD_CODE',p_trip_info.ship_method_code);
         WSH_DEBUG_SV.log(l_module_name,'SERVICE_LEVEL',p_trip_info.service_level);
         WSH_DEBUG_SV.log(l_module_name,'MODE_OF_TRANSPORT',p_trip_info.mode_of_transport);
         WSH_DEBUG_SV.log(l_module_name,'CONSOLIDATION_ALLOWED',p_trip_info.consolidation_allowed);
         WSH_DEBUG_SV.log(l_module_name,'PLANNED_FLAG',p_trip_info.planned_flag);
         WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_trip_info.status_code);
         WSH_DEBUG_SV.log(l_module_name,'FREIGHT_TERMS_CODE',p_trip_info.freight_terms_code);
         WSH_DEBUG_SV.log(l_module_name,'LANE_ID',p_trip_info.lane_id);
     END IF;
     --

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_tripgrp_to_pvt (
                p_grp_trip_rec => p_trip_info,
                x_pvt_trip_rec => l_pvt_trip_rec,
                x_return_status => x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'map_tripgrp_to_pvt x_return_status',x_return_status);
   END IF;
   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
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
        p_In_rec                 => p_trip_In_rec,
        x_Out_tab                => l_Out_Tab);

    IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'In Wrapper Create_Update_Trip x_return_status',x_return_status);
    END IF;

    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings,
      p_msg_data      => x_msg_data);

    IF l_Out_Tab.COUNT <> 0 THEN
      p_trip_out_rec := l_out_tab(l_out_tab.FIRST);
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success;
    END IF;

   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data);

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
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_TRIP_NEW');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Create_Update_Trip_New;


--========================================================================
-- PROCEDURE : Create_Update_Trip      Wrapper
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         p_trip_info             Attributes for the trip entity
--             p_trip_name             Trip name for update
--              x_trip_id               Trip id of new trip
--              x_trip_name             Trip name of new trip
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
    p_trip_info              IN OUT NOCOPY  Trip_Pub_Rec_Type,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_trip_id                OUT NOCOPY   NUMBER,
    x_trip_name              OUT NOCOPY   VARCHAR2) IS

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Trip';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP';

l_num_errors NUMBER;
l_num_warnings NUMBER;
l_pvt_trip_rec          WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_trip_info_tab         WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_out_tab               trip_out_tab_type;
l_in_rec		TripInRecType;
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
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'P_ACTION_CODE',P_ACTION_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_TRIP_NAME);
         WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_trip_info.trip_id);
         WSH_DEBUG_SV.log(l_module_name,'NAME',p_trip_info.name);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ITEM_ID',p_trip_info.vehicle_item_id);
         WSH_DEBUG_SV.log(l_module_name,'VEHICLE_ORGANIZATION_ID',p_trip_info.vehicle_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',p_trip_info.carrier_id);
         WSH_DEBUG_SV.log(l_module_name,'SHIP_METHOD_CODE',p_trip_info.ship_method_code);
         WSH_DEBUG_SV.log(l_module_name,'SERVICE_LEVEL',p_trip_info.service_level);
         WSH_DEBUG_SV.log(l_module_name,'MODE_OF_TRANSPORT',p_trip_info.mode_of_transport);
         WSH_DEBUG_SV.log(l_module_name,'CONSOLIDATION_ALLOWED',p_trip_info.consolidation_allowed);
         WSH_DEBUG_SV.log(l_module_name,'PLANNED_FLAG',p_trip_info.planned_flag);
         WSH_DEBUG_SV.log(l_module_name,'STATUS_CODE',p_trip_info.status_code);
         WSH_DEBUG_SV.log(l_module_name,'FREIGHT_TERMS_CODE',p_trip_info.freight_terms_code);
         WSH_DEBUG_SV.log(l_module_name,'LANE_ID',p_trip_info.lane_id);
     END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_tripgrp_to_pvt (
                p_grp_trip_rec => p_trip_info,
                x_pvt_trip_rec => l_pvt_trip_rec,
                x_return_status => x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'map_tripgrp_to_pvt x_return_status',x_return_status);
   END IF;
   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trip_name IS NOT NULL) AND (p_trip_name <> FND_API.G_MISS_CHAR) THEN
      l_pvt_trip_rec.name := p_trip_name;
   END IF;

   l_in_rec.caller:='WSH_GRP';
   l_in_rec.phase:= 1;
   l_in_rec.action_code:= p_action_code;

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
       wsh_debug_sv.log (l_module_name,'In Wrapper Create_Update_Trip x_return_status',x_return_status);
    END IF;
    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings,
      p_msg_data      => x_msg_data);

    IF l_Out_Tab.COUNT <> 0 THEN
       x_trip_id := l_out_tab(l_out_tab.FIRST).trip_id;
       x_trip_name := l_out_tab(l_out_tab.FIRST).trip_name;
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success;
    END IF;

   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data);

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
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_TRIP_NEW');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Create_Update_Trip;
--Harmonization Project **heali

-- API to get Trip Details
PROCEDURE get_trip_details_pvt
  (p_trip_id IN NUMBER,
   x_trip_rec OUT NOCOPY WSH_TRIPS_PVT.TRIP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_old_trip_details(v_trip_id IN NUMBER) IS
  SELECT TRIP_ID,
	  NAME,
	  ARRIVE_AFTER_TRIP_ID,
	  --FND_API.G_MISS_CHAR,  -- ARRIVE_AFTER_TRIP_NAME
	  VEHICLE_ITEM_ID,
	  --FND_API.G_MISS_CHAR,  -- VEHICLE_ITEM_DESC
	  VEHICLE_ORGANIZATION_ID,
	  --FND_API.G_MISS_CHAR,  -- VEHICLE_ORGANIZATION_CODE
	  VEHICLE_NUMBER,
	  VEHICLE_NUM_PREFIX,
	  CARRIER_ID,
	  SHIP_METHOD_CODE,
	  --FND_API.G_MISS_CHAR,  -- SHIP_METHOD_NAME
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
	  SERVICE_LEVEL,
	  MODE_OF_TRANSPORT,
	  CONSOLIDATION_ALLOWED,   --H integration
	  PLANNED_FLAG,
	  STATUS_CODE,
	  FREIGHT_TERMS_CODE,
	  LOAD_TENDER_STATUS,
	  ROUTE_LANE_ID,
	  LANE_ID,
	  SCHEDULE_ID,
	  BOOKING_NUMBER,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  REQUEST_ID,
          nvl(SHIPMENTS_TYPE_FLAG, 'O'),  -- J inbound logistics jckwok
          OPERATOR
	FROM wsh_trips
   WHERE trip_id = v_trip_id;

  l_stops_trip_rec WSH_TRIPS_PVT.trip_rec_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRIP_DETAILS_PVT';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
	END IF;
	--
	OPEN c_old_trip_details(p_trip_id);
	FETCH c_old_trip_details
	 INTO
	l_stops_trip_rec.TRIP_ID,
		l_stops_trip_rec.NAME,
		l_stops_trip_rec.ARRIVE_AFTER_TRIP_ID,
		--l_stops_trip_rec.ARRIVE_AFTER_TRIP_NAME,
		l_stops_trip_rec.VEHICLE_ITEM_ID,
		--l_stops_trip_rec.VEHICLE_ITEM_DESC,
		l_stops_trip_rec.VEHICLE_ORGANIZATION_ID,
		--l_stops_trip_rec.VEHICLE_ORGANIZATION_CODE,
		l_stops_trip_rec.VEHICLE_NUMBER,
		l_stops_trip_rec.VEHICLE_NUM_PREFIX,
		l_stops_trip_rec.CARRIER_ID,
		l_stops_trip_rec.SHIP_METHOD_CODE,
		--l_stops_trip_rec.SHIP_METHOD_NAME,
		l_stops_trip_rec.ROUTE_ID,
		l_stops_trip_rec.ROUTING_INSTRUCTIONS,
		l_stops_trip_rec.ATTRIBUTE_CATEGORY,
		l_stops_trip_rec.ATTRIBUTE1,
		l_stops_trip_rec.ATTRIBUTE2,
		l_stops_trip_rec.ATTRIBUTE3,
		l_stops_trip_rec.ATTRIBUTE4,
		l_stops_trip_rec.ATTRIBUTE5,
		l_stops_trip_rec.ATTRIBUTE6,
		l_stops_trip_rec.ATTRIBUTE7,
		l_stops_trip_rec.ATTRIBUTE8,
		l_stops_trip_rec.ATTRIBUTE9,
		l_stops_trip_rec.ATTRIBUTE10,
		l_stops_trip_rec.ATTRIBUTE11,
		l_stops_trip_rec.ATTRIBUTE12,
		l_stops_trip_rec.ATTRIBUTE13,
		l_stops_trip_rec.ATTRIBUTE14,
		l_stops_trip_rec.ATTRIBUTE15,
		l_stops_trip_rec.SERVICE_LEVEL,
		l_stops_trip_rec.MODE_OF_TRANSPORT,
		l_stops_trip_rec.CONSOLIDATION_ALLOWED,   --H integration
		l_stops_trip_rec.PLANNED_FLAG,
		l_stops_trip_rec.STATUS_CODE,
		l_stops_trip_rec.FREIGHT_TERMS_CODE,
		l_stops_trip_rec.LOAD_TENDER_STATUS,
		l_stops_trip_rec.ROUTE_LANE_ID,
		l_stops_trip_rec.LANE_ID,
		l_stops_trip_rec.SCHEDULE_ID,
		l_stops_trip_rec.BOOKING_NUMBER,
		l_stops_trip_rec.CREATION_DATE,
		l_stops_trip_rec.CREATED_BY,
		l_stops_trip_rec.LAST_UPDATE_DATE,
		l_stops_trip_rec.LAST_UPDATED_BY,
		l_stops_trip_rec.LAST_UPDATE_LOGIN,
		l_stops_trip_rec.PROGRAM_APPLICATION_ID,
		l_stops_trip_rec.PROGRAM_ID,
		l_stops_trip_rec.PROGRAM_UPDATE_DATE,
		l_stops_trip_rec.REQUEST_ID,
                l_stops_trip_rec.SHIPMENTS_TYPE_FLAG, -- J Inbound Logistics jckwok
                l_stops_trip_rec.OPERATOR;
	CLOSE c_old_trip_details;

	x_trip_rec := l_stops_trip_rec;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
        IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_stops_trip_rec.TRIP_ID',l_stops_trip_rec.TRIP_ID);
             WSH_DEBUG_SV.log(l_module_name,'l_stops_trip_rec.NAME',l_stops_trip_rec.NAME);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIPS_GRP.get_trip_details_pvt',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;

END WSH_TRIPS_GRP;

/
