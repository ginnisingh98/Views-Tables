--------------------------------------------------------
--  DDL for Package Body WSH_FTE_TP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_TP_INTEGRATION" as
/* $Header: WSHFTPIB.pls 115.3 2003/09/05 19:01:02 wrudge noship $ */

 --
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FTE_TP_INTEGRATION';
 --

--
--  Procedure:          lookup_cm_info
--  Parameters:
--               p_trip_id             trip_id to look up its continuous move segment
--               x_cm_info_rec         attributes of continuous move and segment
--               x_return_status       return status
--
--  Description:
--               Wrapper for FTE api:
--               Looks up continuous move information associated with the trip
--               to be displayed in shipping UIs.
--
--

PROCEDURE lookup_cm_info (
        p_trip_id              IN            NUMBER,
        x_cm_info_rec          OUT    NOCOPY cm_info_rec_type,
        x_return_status        OUT    NOCOPY VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'lookup_cm_info';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.lookup_cm_info (
        p_trip_id       => p_trip_id,
        x_cm_info_rec   => x_cm_info_rec,
        x_return_status => x_return_status);
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.lookup_cm_info',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END lookup_cm_info;



--
--  Procedure:          trip_callback
--  Parameters:
--               p_api_version_number  known api version (1.0)
--               p_init_msg_list       FND_API.G_TRUE to reset list
--               x_return_status       return status
--               x_msg_count           number of messages in the list
--               x_msg_data            text of messages
--               p_actions_prms        action parameters record
--                                          used to identify the action triggering
--                                          the callback to FTE.
--               p_rec_attr_tab        table of trip records to process
--
--  Description:
--               Wrapper for FTE api:
--               take care of continuous moves based on the action being
--               performed on the trips.
--

PROCEDURE trip_callback (
    p_api_version_number     IN             NUMBER,
    p_init_msg_list          IN             VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    p_action_prms            IN             WSH_TRIPS_GRP.action_parameters_rectype,
    p_rec_attr_tab           IN             WSH_TRIPS_PVT.Trip_Attr_Tbl_Type)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'trip_callback';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.trip_callback(
      p_api_version_number  => p_api_version_number,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_action_prms         => p_action_prms,
      p_rec_attr_tab        => p_rec_attr_tab);
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.trip_callback',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END trip_callback;



--
--  Procedure:          stop_callback
--  Parameters:
--               p_api_version_number  known api version (1.0)
--               p_init_msg_list       FND_API.G_TRUE to reset list
--               x_return_status       return status
--               x_msg_count           number of messages in the list
--               x_msg_data            text of messages
--               p_actions_prms        action parameters record
--                                          used to identify the action triggering
--                                          the callback to FTE.
--               p_rec_attr_tab        table of stop records to process
--
--  Description:
--               Wrapper for FTE api:
--               take care of continuous moves based on the action being performed
--               on the stops.
--

PROCEDURE stop_callback (
    p_api_version_number     IN             NUMBER,
    p_init_msg_list          IN             VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    p_action_prms            IN             WSH_TRIP_STOPS_GRP.action_parameters_rectype,
    p_rec_attr_tab           IN             WSH_TRIP_STOPS_PVT.stop_attr_tbl_type)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'stop_callback';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.stop_callback(
      p_api_version_number  => p_api_version_number,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_action_prms         => p_action_prms,
      p_rec_attr_tab        => p_rec_attr_tab);
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.stop_callback',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END stop_callback;



--
--  Procedure:          map_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Wrapper for FTE api:
--               Part of TP release process
--               Maps the plan's continuous moves: generate and lock candidates
--               x_obsoleted_trip_moves will have the obsoleted move segments.
--

PROCEDURE map_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'map_moves';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.map_moves(
           x_context              => x_context,
           x_plan_trips           => x_plan_trips,
           x_plan_trip_moves      => x_plan_trip_moves,
           x_plan_moves           => x_plan_moves,
           x_obsoleted_trip_moves => x_obsoleted_trip_moves,
           x_errors_tab           => x_errors_tab,
           x_return_status        => x_return_status
          );
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.map_moves',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END map_moves;



--
--  Procedure:          reconciliate_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Wrapper for FTE api:
--               Part of TP release process
--               Create or update continous moves and their segments, delete obsoleted segments.
--

PROCEDURE reconciliate_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'reconciliate_moves';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.reconciliate_moves(
           x_context              => x_context,
           x_plan_trips           => x_plan_trips,
           x_plan_trip_moves      => x_plan_trip_moves,
           x_plan_moves           => x_plan_moves,
           x_obsoleted_trip_moves => x_obsoleted_trip_moves,
           x_errors_tab           => x_errors_tab,
           x_return_status        => x_return_status
          );
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.reconciliate_moves',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END reconciliate_moves;


--
--  Procedure:          tp_firm_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Wrapper for FTE api:
--               Part of TP release process
--               Upgrade continuous moves' PLANNED_FLAG based on the plan
--

PROCEDURE tp_firm_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_moves               IN OUT NOCOPY plan_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'tp_firm_moves';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.tp_firm_moves(
           x_context              => x_context,
           x_plan_moves           => x_plan_moves,
           x_errors_tab           => x_errors_tab,
           x_return_status        => x_return_status
          );
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.tp_firm_moves',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END tp_firm_moves;



--
--  Procedure:          purge_interface_tables
--  Parameters:
--               p_group_ids           list of group_ids to purge
--                                     FTE interface tables (based on WSH_TRIPS_INTERFACE.GROUP_ID)
--               x_return_status       return status
--
--  Description:
--               Wrapper for FTE api:
--               Part of TP release process
--               Delete the records from FTE interface tables:
--                   FTE_MOVES_INTERFACE
--                   FTE_TRIP_MOVES_INTERFACE
--
PROCEDURE purge_interface_tables(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.ID_TAB_TYPE,
  x_return_status          OUT NOCOPY    VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'purge_interface_tables';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' THEN
    FTE_TP_GRP.purge_interface_tables(
           p_group_ids            => p_group_ids,
           x_return_status        => x_return_status
          );
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_FTE_TP_INTEGRATION.purge_interface_tables',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END purge_interface_tables;




END WSH_FTE_TP_INTEGRATION;

/
