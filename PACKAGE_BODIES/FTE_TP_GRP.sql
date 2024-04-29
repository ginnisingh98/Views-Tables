--------------------------------------------------------
--  DDL for Package Body FTE_TP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TP_GRP" as
/* $Header: FTETPGPB.pls 115.10 2004/05/08 00:25:40 sperera noship $ */

G_TP_RELEASE_CODE CONSTANT VARCHAR2(30) := WSH_TP_RELEASE_GRP.G_TP_RELEASE_CODE;

 --
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_TP_GRP';
 --


CURSOR c_cm_info(x_trip_id NUMBER) IS
    SELECT fm.move_id,
           fm.cm_trip_number,
           fm.planned_flag,
           ftm.sequence_number
    FROM   FTE_MOVES      fm,
           FTE_TRIP_MOVES ftm
    WHERE  ftm.trip_id = x_trip_id
    AND    fm.move_id  = ftm.move_id
    AND    fm.move_type_code = 'CONTINUOUS';


--
--  Procedure:          int_lookup_cm_info
--  Parameters:
--               p_trip_id             trip_id to look up its continuous move segment
--               x_int_cm_info_rec         internal attributes of continuous move and segment
--               x_return_status       return status
--
--  Description:
--               Internal API to look up continuous move information associated
--               with the trip for the callers.
--
--

PROCEDURE int_lookup_cm_info (
        p_trip_id              IN            NUMBER,
        x_int_cm_info_rec      OUT    NOCOPY c_cm_info%ROWTYPE,
        x_return_status        OUT    NOCOPY VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'int_lookup_cm_info';
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
    WSH_DEBUG_SV.log(l_module_name, 'p_trip_id', p_trip_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --

  OPEN c_cm_info(p_trip_id);
  FETCH c_cm_info INTO x_int_cm_info_rec;
  IF c_cm_info%NOTFOUND THEN
    x_int_cm_info_rec.move_id         := NULL;
    x_int_cm_info_rec.cm_trip_number  := NULL;
    x_int_cm_info_rec.sequence_number := NULL;
  END IF;
  CLOSE c_cm_info;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'move_id', x_int_cm_info_rec.move_id);
     WSH_DEBUG_SV.log(l_module_name, 'cm_trip_number', x_int_cm_info_rec.cm_trip_number);
     WSH_DEBUG_SV.log(l_module_name, 'sequence_number', x_int_cm_info_rec.sequence_number);
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.int_lookup_cm_info',
                      l_module_name);
    IF c_cm_info%ISOPEN THEN
      CLOSE c_cm_info;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END int_lookup_cm_info;



--
--  Procedure:          lookup_move
--  Parameters:
--               p_move_id             move identifier
--               p_lock_flag           'Y' - lock move and its trip_moves; 'N' - do not lock
--               x_move_rec            record from FTE_MOVES
--               x_locked              'Y' - locked by other session; 'N' - no exception raised
--               x_return_status       return status
--
--  Description:
--               Internal API to lock and populate the move record.
--
--

PROCEDURE lookup_move (
        p_move_id           IN               NUMBER,
        p_lock_flag         IN               VARCHAR2,
        x_move_rec             OUT    NOCOPY FTE_MOVES_PVT.move_rec_type,
        x_locked               OUT    NOCOPY VARCHAR2,
        x_return_status        OUT    NOCOPY VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'lookup_move';
  --
  l_debug_on BOOLEAN;
  --
  CURSOR c_move(x_move_id NUMBER) IS
    SELECT fm.move_id,
           fm.move_type_code,
           fm.lane_id,
           fm.service_level,
           fm.planned_flag,
           fm.cm_trip_number,
           fm.tp_plan_name,
           fm.creation_date,
           fm.created_by,
           fm.last_update_date,
           fm.last_updated_by,
           fm.last_update_login,
           fm.program_application_id,
           fm.program_id,
           fm.program_update_date,
           fm.request_id,
           fm.attribute_category,
           fm.attribute1,
           fm.attribute2,
           fm.attribute3,
           fm.attribute4,
           fm.attribute5,
           fm.attribute6,
           fm.attribute7,
           fm.attribute8,
           fm.attribute9,
           fm.attribute10,
           fm.attribute11,
           fm.attribute12,
           fm.attribute13,
           fm.attribute14,
           fm.attribute15
    FROM   FTE_MOVES fm
    WHERE  fm.move_id = x_move_id;

  CURSOR c_lock_move(x_move_id NUMBER) IS
    SELECT fm.move_id,
           fm.move_type_code,
           fm.lane_id,
           fm.service_level,
           fm.planned_flag,
           fm.cm_trip_number,
           fm.tp_plan_name,
           fm.creation_date,
           fm.created_by,
           fm.last_update_date,
           fm.last_updated_by,
           fm.last_update_login,
           fm.program_application_id,
           fm.program_id,
           fm.program_update_date,
           fm.request_id,
           fm.attribute_category,
           fm.attribute1,
           fm.attribute2,
           fm.attribute3,
           fm.attribute4,
           fm.attribute5,
           fm.attribute6,
           fm.attribute7,
           fm.attribute8,
           fm.attribute9,
           fm.attribute10,
           fm.attribute11,
           fm.attribute12,
           fm.attribute13,
           fm.attribute14,
           fm.attribute15
    FROM   FTE_MOVES fm
    WHERE  fm.move_id = x_move_id
    FOR UPDATE NOWAIT;

    CURSOR c_lock_trip_moves(x_move_id NUMBER) IS
      SELECT ftm.trip_move_id
      FROM   FTE_TRIP_MOVES ftm
      WHERE  ftm.move_id = x_move_id
      FOR UPDATE NOWAIT;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_move_id', p_move_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_locked := 'N';

  --
  --

  IF p_lock_flag = 'Y' THEN
    OPEN  c_lock_move(p_move_id);
    FETCH c_lock_move INTO x_move_rec;
    IF c_lock_move%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_MOVE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('MOVE_ID', p_move_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    END IF;
    CLOSE c_lock_move;

    -- need only to lock the trip moves
    OPEN  c_lock_trip_moves(p_move_id);
    CLOSE c_lock_trip_moves;

  ELSE
    OPEN  c_move(p_move_id);
    FETCH c_move INTO x_move_rec;
    IF c_move%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_MOVE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('MOVE_ID', p_move_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    END IF;
    CLOSE c_move;
  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
    x_locked := 'Y';
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_LOCK');
    FND_MESSAGE.SET_TOKEN('MOVE_ID', p_move_id);
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
    END IF;

  WHEN OTHERS THEN
    IF c_move%ISOPEN THEN
      CLOSE c_move;
    END IF;
    IF c_lock_move%ISOPEN THEN
      CLOSE c_lock_move;
    END IF;
    IF c_lock_trip_moves%ISOPEN THEN
      CLOSE c_lock_trip_moves;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.lookup_move',
                      l_module_name);
    IF c_cm_info%ISOPEN THEN
      CLOSE c_cm_info;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END lookup_move;



--
--  Procedure:          lookup_cm_info
--  Parameters:
--               p_trip_id             trip_id to look up its continuous move segment
--               x_cm_info_rec         attributes of continuous move and segment
--               x_return_status       return status
--
--  Description:
--               Looks up continuous move information associated with the trip
--               to be displayed in shipping UIs.
--
--

PROCEDURE lookup_cm_info (
        p_trip_id              IN            NUMBER,
        x_cm_info_rec          OUT    NOCOPY WSH_FTE_TP_INTEGRATION.cm_info_rec_type,
        x_return_status        OUT    NOCOPY VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'lookup_cm_info';
  --
  l_debug_on BOOLEAN;
  --
  l_int_cm_info_rec c_cm_info%ROWTYPE;

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

  --
  --

  int_lookup_cm_info(
        p_trip_id         => p_trip_id,
        x_int_cm_info_rec => l_int_cm_info_rec,
        x_return_status   => x_return_status);

  IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                         WSH_UTIL_CORE.G_RET_STS_WARNING)  THEN
    x_cm_info_rec.move_id         := l_int_cm_info_rec.move_id;
    x_cm_info_rec.cm_trip_number  := l_int_cm_info_rec.cm_trip_number;
    x_cm_info_rec.sequence_number := l_int_cm_info_rec.sequence_number;
  ELSE
    x_cm_info_rec.move_id         := NULL;
    x_cm_info_rec.cm_trip_number  := NULL;
    x_cm_info_rec.sequence_number := NULL;
  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.lookup_cm_info',
                      l_module_name);
    IF c_cm_info%ISOPEN THEN
      CLOSE c_cm_info;
    END IF;
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
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'trip_callback';
  --
  l_debug_on BOOLEAN;
  --
  i                   NUMBER;
  l_return_status     VARCHAR2(1);
  l_int_cm_info_rec   c_cm_info%ROWTYPE;
  l_move_rec          FTE_MOVES_PVT.move_rec_type;
  l_locked            VARCHAR2(1);
  move_error          EXCEPTION;
BEGIN
  SAVEPOINT before_trip_callback;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'action_code', p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name, 'count of trips', p_rec_attr_tab.COUNT);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  --

  IF p_action_prms.action_code IN ('PLAN', 'UNPLAN', 'DELETE')  THEN

    i := p_rec_attr_tab.FIRST;
    WHILE i IS NOT NULL LOOP

      int_lookup_cm_info(
           p_trip_id          => p_rec_attr_tab(i).trip_id,
           x_int_cm_info_rec  => l_int_cm_info_rec,
           x_return_status    => l_return_status);

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
        ROLLBACK TO before_trip_callback;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;


      IF l_int_cm_info_rec.move_id IS NOT NULL THEN

        IF     (p_action_prms.action_code IN ('UNPLAN'))
           AND (l_int_cm_info_rec.planned_flag <> 'N') THEN
          -- planning or unplanning a trip needs to downgrade its firmed move.

          lookup_move(
              p_move_id       => l_int_cm_info_rec.move_id,
              p_lock_flag     => 'Y',
              x_move_rec      => l_move_rec,
              x_locked        => l_locked,
              x_return_status => l_return_status);

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            RAISE move_error;
          END IF;

          -- unfirm continuous move
          l_move_rec.planned_flag     := 'N';
          l_move_rec.last_updated_by  := FND_GLOBAL.user_id;
          l_move_rec.last_update_date := SYSDATE;

          fte_moves_pvt.update_move(
             p_move_info     => l_move_rec,
             x_return_status => l_return_status);

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            RAISE move_error;
          END IF;

        ELSIF p_action_prms.action_code = 'DELETE' THEN

          lookup_move(
              p_move_id       => l_int_cm_info_rec.move_id,
              p_lock_flag     => 'Y',
              x_move_rec      => l_move_rec,
              x_locked        => l_locked,
              x_return_status => l_return_status);

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            RAISE move_error;
          END IF;

          fte_moves_pvt.delete_move(
                p_move_id       => l_int_cm_info_rec.move_id,
                p_validate_flag => 'Y',
                x_return_status => l_return_status);
          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            RAISE move_error;
          END IF;

        END IF;
      END IF;

      i := p_rec_attr_tab.NEXT(i);
    END LOOP;

  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN move_error THEN
     ROLLBACK TO before_trip_callback;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  WHEN OTHERS THEN
    ROLLBACK TO before_trip_callback;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.trip_callback',
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
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'stop_callback';
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

  --
  --

  NULL;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.stop_callback',
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
--               Part of TP release process
--               Maps the plan's continuous moves: generate and lock candidates
--               x_obsoleted_trip_moves will have the obsoleted move segments.
--

PROCEDURE map_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'map_moves';
  --
  l_debug_on BOOLEAN;
  --
  CURSOR c_tp_interface_moves(x_group_id NUMBER) IS
    SELECT DISTINCT fmi.move_interface_id,
           fmi.move_id,
           NVL(fmi.move_type_code, 'CONTINUOUS') move_type_code,
           fmi.lane_id,
           fmi.service_level,
           fmi.planned_flag,
           fmi.tp_plan_name,
           fmi.cm_trip_number
    FROM  fte_moves_interface      fmi,
          fte_trip_moves_interface ftmi,
          wsh_trips_interface      wti
    WHERE wti.group_id = x_group_id
    AND   wti.interface_action_code = G_TP_RELEASE_CODE
    AND   ftmi.trip_interface_id = wti.trip_interface_id
    AND   ftmi.interface_action_code = G_TP_RELEASE_CODE
    AND   fmi.move_interface_id = ftmi.move_interface_id
    AND   fmi.interface_action_code = G_TP_RELEASE_CODE
    ORDER BY fmi.move_interface_id;

  CURSOR c_tp_interface_trip_moves(x_move_interface_id NUMBER) IS
    SELECT ftmi.trip_move_interface_id,
           ftmi.trip_move_id,
           ftmi.move_interface_id,
           ftmi.move_id,
           ftmi.trip_interface_id,
           ftmi.trip_id,
           ftmi.sequence_number
    FROM   fte_trip_moves_interface ftmi
    WHERE  ftmi.move_interface_id = x_move_interface_id
    AND    ftmi.interface_action_code = G_TP_RELEASE_CODE
    ORDER BY ftmi.sequence_number;

  CURSOR c_trip_moves(x_move_id NUMBER) IS
    SELECT ftm.move_id,
           ftm.trip_move_id,
           ftm.trip_id,
           ftm.sequence_number
    FROM   fte_trip_moves ftm
    WHERE  ftm.move_id = x_move_id
    ORDER BY ftm.sequence_number;


    -- Looks for trips in obsoleted moves.
    CURSOR c_obsoleted_move_trips(x_move_id IN NUMBER) IS
    SELECT trip_id
    FROM   fte_trip_moves
    WHERE  move_id = x_move_id;



  l_move_rec      FTE_MOVES_PVT.move_rec_type;
  l_cm_info       c_cm_info%ROWTYPE;
  l_locked        VARCHAR2(1);
  l_return_status VARCHAR2(1);

  l_unmapped_trip_moves WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type;

  l_new_index  NUMBER := 0;
  l_tm_index   NUMBER := 0;
  l_trip_index NUMBER;
  l_map_index  NUMBER;
  l_mapped     BOOLEAN;



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

  --
  --

  l_new_index := 0;
  FOR imove IN c_tp_interface_moves(x_group_id => x_context.group_id)  LOOP  --{

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,
                       'imove looping: move_interface_id',
                       imove.move_interface_id);
    END IF;

    l_new_index := l_new_index + 1;
    x_plan_moves(l_new_index).move_interface_id    := imove.move_interface_id;
    x_plan_moves(l_new_index).move_id              := imove.move_id;
    x_plan_moves(l_new_index).move_type_code       := imove.move_type_code;
    x_plan_moves(l_new_index).lane_id              := imove.lane_id;
    x_plan_moves(l_new_index).service_level        := imove.service_level;
    x_plan_moves(l_new_index).planned_flag         := imove.planned_flag;
    x_plan_moves(l_new_index).tp_plan_name         := imove.tp_plan_name;
    x_plan_moves(l_new_index).cm_trip_number       := imove.cm_trip_number;
    x_plan_moves(l_new_index).trip_move_base_index := NULL;

    l_unmapped_trip_moves.DELETE;


    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,
                         'x_plan_moves(l_new_index).move_id',
                          x_plan_moves(l_new_index).move_id);
    END IF;

    IF x_plan_moves(l_new_index).move_id IS NOT NULL THEN
      -- if continous move was snapshot, check whether we can lock and update it.
      lookup_move(
          p_move_id       => x_plan_moves(l_new_index).move_id,
          p_lock_flag     => 'Y',
          x_move_rec      => l_move_rec,
          x_locked        => l_locked,
          x_return_status => l_return_status);

      IF    l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
         AND l_locked = 'N' THEN
        -- if move is not found, clear its ID.
        x_plan_moves(l_new_index).move_id := NULL;
      ELSIF  l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        -- move or one of its trip_moves cannot be locked or some other error happened.
        WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'FTE_MOVES_INTERFACE',
                          p_entity_interface_id => imove.move_interface_id,
                          p_message_name        => 'WSH_TP_F_NO_LOCK_MOVE',
                          p_token_1_name        => 'MOVE_ID',
                          p_token_1_value       => x_plan_moves(l_new_index).move_id,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      ELSE
        -- note move's current firm flag
        x_plan_moves(l_new_index).fte_planned_flag  := l_move_rec.planned_flag;

        -- look up its trip moves to map or obsolete.
        l_map_index := 1;
        FOR tm IN c_trip_moves(x_plan_moves(l_new_index).move_id) LOOP
          l_unmapped_trip_moves(l_map_index).move_id         := tm.move_id;
          l_unmapped_trip_moves(l_map_index).trip_move_id    := tm.trip_move_id;
          l_unmapped_trip_moves(l_map_index).trip_id         := tm.trip_id;
          l_unmapped_trip_moves(l_map_index).sequence_number := tm.sequence_number;
          l_map_index := l_map_index + 1;
        END LOOP;
      END IF;
    END IF;

    FOR itripmove IN c_tp_interface_trip_moves(x_move_interface_id => x_plan_moves(l_new_index).move_interface_id) LOOP --[

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'itripmove looping: trip_move_interface_id',
                         itripmove.trip_move_interface_id);
      END IF;

      IF x_plan_moves(l_new_index).trip_move_base_index IS NULL THEN
        IF x_plan_trip_moves.COUNT = 0 THEN
          l_tm_index := 1;
        ELSE
          l_tm_index := x_plan_trip_moves.LAST + 1;
        END IF;
        x_plan_moves(l_new_index).trip_move_base_index := l_tm_index;
      ELSE
        l_tm_index := l_tm_index + 1;
      END IF;

      -- map trip_interface_id to its plan index
      l_trip_index := x_plan_trips.FIRST;
      WHILE l_trip_index IS NOT NULL LOOP
        EXIT WHEN itripmove.trip_interface_id = x_plan_trips(l_trip_index).trip_interface_id;
        l_trip_index := x_plan_trips.NEXT(l_trip_index);
      END LOOP;

      IF l_trip_index IS NULL THEN
        WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'FTE_TRIP_MOVES_INTERFACE',
                          p_entity_interface_id => itripmove.trip_move_interface_id,
                          p_message_name        => 'WSH_TP_F_TRIP_NOT_MAPPED',
                          p_token_1_name        => 'PLAN_CM_NUM',
                          p_token_1_value       => x_plan_moves(l_new_index).cm_trip_number,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      x_plan_trip_moves(l_tm_index).trip_move_interface_id := itripmove.trip_move_interface_id;
      x_plan_trip_moves(l_tm_index).trip_move_id           := itripmove.trip_move_id;
      x_plan_trip_moves(l_tm_index).move_interface_id      := itripmove.move_interface_id;
      x_plan_trip_moves(l_tm_index).move_id                := itripmove.move_id;
      x_plan_trip_moves(l_tm_index).move_index             := l_new_index;
      x_plan_trip_moves(l_tm_index).trip_interface_id      := itripmove.trip_interface_id;
      x_plan_trip_moves(l_tm_index).trip_id                := itripmove.trip_id;
      x_plan_trip_moves(l_tm_index).trip_index             := l_trip_index;
      x_plan_trip_moves(l_tm_index).sequence_number        := itripmove.sequence_number;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'x_plan_trip_moves(l_tm_index).trip_move_id',
                          x_plan_trip_moves(l_tm_index).trip_move_id);
      END IF;
      IF x_plan_moves(l_new_index).move_id IS NULL THEN

        -- if the move is not in FTE data, neither are its trip_move records.
        x_plan_trip_moves(l_tm_index).trip_move_id           := NULL;

      ELSE

        -- check if this record still exists
        -- (if yes, it'll already be locked by looking the move up.)
        l_map_index := NULL;
        l_mapped    := FALSE;

        IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'l_unmapped_trip_moves.COUNT',
                          l_unmapped_trip_moves.COUNT);
        END IF;

        IF l_unmapped_trip_moves.COUNT > 0 THEN
          l_map_index := l_unmapped_trip_moves.FIRST;
          WHILE l_map_index IS NOT NULL LOOP
            -- this is mapped only if key attributes match.
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,
                  'l_unmapped_trip_moves(l_map_index).trip_move_id', l_unmapped_trip_moves(l_map_index).trip_move_id);
               WSH_DEBUG_SV.log(l_module_name,
                  'x_plan_trip_moves(l_tm_index).trip_move_id', x_plan_trip_moves(l_tm_index).trip_move_id);
            END IF;

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,
                  'l_unmapped_trip_moves(l_map_index).trip_id', l_unmapped_trip_moves(l_map_index).trip_id);
               WSH_DEBUG_SV.log(l_module_name,
                  'x_plan_trips(x_plan_trip_moves(l_tm_index).trip_index).trip_id', x_plan_trips(x_plan_trip_moves(l_tm_index).trip_index).trip_id);
               WSH_DEBUG_SV.log(l_module_name,
                  'l_unmapped_trip_moves(l_map_index).sequence_number', l_unmapped_trip_moves(l_map_index).sequence_number);
               WSH_DEBUG_SV.log(l_module_name,
                  'x_plan_trip_moves(l_tm_index).sequence_number', x_plan_trip_moves(l_tm_index).sequence_number);
             END IF;
             IF (l_unmapped_trip_moves(l_map_index).trip_id
                          = x_plan_trips(x_plan_trip_moves(l_tm_index).trip_index).trip_id)
               AND (l_unmapped_trip_moves(l_map_index).sequence_number
                           = x_plan_trip_moves(l_tm_index).sequence_number) THEN
               -- the record matches, so it is mapped
               x_plan_trip_moves(l_tm_index).trip_move_id := l_unmapped_trip_moves(l_map_index).trip_move_id;
               l_unmapped_trip_moves.DELETE(l_map_index);
               EXIT;
             END IF;

            l_map_index := l_unmapped_trip_moves.NEXT(l_map_index);
          END LOOP;
        END IF;

        IF l_map_index IS NULL THEN
          -- being NULL means this record does not exist or is not mapped.
          x_plan_trip_moves(l_tm_index).trip_move_id := NULL;
        END IF;

      END IF;

    END LOOP; --] itripmove

    -- transfer unmapped trip moves to obsoleted trip moves
    IF l_unmapped_trip_moves.COUNT > 0 THEN

      -- is this move currently firmed (so it should have all trip_moves mapped)?
      IF x_plan_moves(l_new_index).fte_planned_flag <> 'N' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'FTE_MOVES_INTERFACE',
                          p_entity_interface_id => x_plan_moves(l_new_index).move_interface_id,
                          p_message_name        => 'WSH_TP_F_FIRM_MOVE_DIFF',
                          p_token_1_name        => 'PLAN_TRIP_NUM',
                          p_token_1_value       => x_plan_trips(1).tp_trip_number,
                          p_token_2_name        => 'MOVE_ID',
                          p_token_2_value       => x_plan_moves(l_new_index).move_id,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;


      l_map_index := l_unmapped_trip_moves.FIRST;
      IF x_obsoleted_trip_moves.COUNT = 0 THEN
        l_tm_index := 1;
      ELSE
        l_tm_index := x_obsoleted_trip_moves.LAST + 1;
      END IF;

      WHILE l_map_index IS NOT NULL LOOP
        x_obsoleted_trip_moves(l_tm_index) := l_unmapped_trip_moves(l_map_index);
        l_tm_index := l_tm_index + 1;
        l_map_index := l_unmapped_trip_moves.NEXT(l_map_index);
      END LOOP;
    END IF;

  END LOOP;  --} imove


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_plan_trips.COUNT to remove unmapped moves', x_plan_trips.COUNT);
  END IF;

  l_map_index := 1;
  l_trip_index := x_plan_trips.FIRST;
  WHILE l_trip_index IS NOT NULL LOOP

    IF x_plan_trips(l_trip_index).trip_id IS NOT NULL THEN

      int_lookup_cm_info (
        p_trip_id         => x_plan_trips(l_trip_index).trip_id,
        x_int_cm_info_rec => l_cm_info,
        x_return_status   => l_return_status);

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                          p_entity_interface_id => x_plan_trips(l_trip_index).trip_interface_id,
                          p_message_name        => 'WSH_TP_F_MOVE_LOOKUP',
                          p_token_1_name        => 'PLAN_TRIP_NUM',
                          p_token_1_value       => x_plan_trips(l_trip_index).tp_trip_number,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      IF l_cm_info.move_id IS NOT NULL THEN

          l_mapped    := FALSE;
          -- check if this move has been added to obsoleted list (or has trip_move record).
          IF x_obsoleted_trip_moves.COUNT > 0 THEN

            l_map_index := x_obsoleted_trip_moves.FIRST;

            WHILE l_map_index IS NOT NULL LOOP--{
              IF x_obsoleted_trip_moves(l_map_index).move_id = l_cm_info.move_id THEN
                IF x_obsoleted_trip_moves(l_map_index).trip_move_id IS NOT NULL THEN
                  -- if this is a trip_move to obsolete, it implies the move is mapped.
                  l_map_index := NULL;
                  l_mapped := TRUE;
                END IF;
                EXIT;
              END IF;
              l_map_index := x_obsoleted_trip_moves.NEXT(l_map_index);
            END LOOP; --}
          ELSE
            l_map_index := NULL;
          END IF;

          -- if not seen before, determine whether this move should be obsoleted.
          IF     l_map_index IS NULL AND NOT l_mapped
             AND x_plan_moves.COUNT > 0 THEN
            l_map_index := x_plan_moves.FIRST;
            WHILE l_map_index IS NOT NULL LOOP
              IF x_plan_moves(l_map_index).move_id = l_cm_info.move_id THEN
                EXIT;
              END IF;
              l_map_index := x_plan_moves.NEXT(l_map_index);
            END LOOP;
          END IF;

          IF l_map_index IS NULL AND NOT l_mapped THEN
            -- lock this move, verify its planned_flag and then add it to the list of obsoleted moves.
            lookup_move(
              p_move_id       => l_cm_info.move_id,
              p_lock_flag     => 'Y',
              x_move_rec      => l_move_rec,
              x_locked        => l_locked,
              x_return_status => l_return_status);

            IF    (l_locked = 'Y')
                 OR (l_return_status IN
                         (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
              -- move or one of its trip_moves cannot be locked or some other error happened.
              WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                          p_entity_interface_id => x_plan_trips(l_trip_index).trip_interface_id,
                          p_message_name        => 'WSH_TP_F_NO_LOCK_OBS_MOVE',
                          p_token_1_name        => 'MOVE_ID',
                          p_token_1_value       => l_cm_info.move_id,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;

            -- we should not obsolete a firmed move.
            IF NVL(l_move_rec.planned_flag, 'N') <> 'N' THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              WSH_TP_RELEASE_INT.stamp_interface_error(
                          p_group_id            => x_context.group_id,
                          p_entity_table_name   => 'WSH_TRIPS_INTERFACE',
                          p_entity_interface_id => x_plan_trips(l_trip_index).trip_interface_id,
                          p_message_name        => 'WSH_TP_F_FIRM_MOVE_NO_MATCH',
                          p_token_1_name        => 'PLAN_TRIP_NUM',
                          p_token_1_value       => x_plan_trips(l_trip_index).tp_trip_number,
                          x_errors_tab          => x_errors_tab,
                          x_return_status       => l_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;

            x_obsoleted_trip_moves(x_obsoleted_trip_moves.COUNT + 1).move_id := l_cm_info.move_id;

            FOR move in c_obsoleted_move_trips(l_cm_info.move_id) LOOP
              -- Keep track of the trips that are in an obsoleted move.
              -- This is used to delete these trips if necessary later.
              -- Only the trip_id is populated in the record.
              -- Lock the trip that might get deleted.
              BEGIN
                 WSH_TRIPS_PVT.lock_trip_no_compare(move.trip_id);
                 x_obsoleted_trip_moves(x_obsoleted_trip_moves.COUNT + 1).trip_id := move.trip_id;
              EXCEPTION
                 WHEN OTHERS THEN
                 -- Do nothing, if it is locked by another process,
                 -- Unlikely that it will need to be deleted.
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'Trip could not be locked: ', move.trip_id);
                 END IF;
              END;

            END LOOP;
          END IF;

      END IF;

    END IF;

    l_trip_index := x_plan_trips.NEXT(l_trip_index);
  END LOOP;

  --
  --


  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF c_tp_interface_moves%ISOPEN THEN
      CLOSE c_tp_interface_moves;
    END IF;
    IF c_tp_interface_trip_moves%ISOPEN THEN
      CLOSE c_tp_interface_trip_moves;
    END IF;
    IF c_trip_moves%ISOPEN THEN
      CLOSE c_trip_moves;
    END IF;

    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.map_moves',
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
--               Part of TP release process
--               Create or update continous moves and their segments, delete obsoleted segments.
--

PROCEDURE reconciliate_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'reconciliate_moves';
  --
  l_debug_on BOOLEAN;
  --

  l_m_index       NUMBER;
  l_tm_index      NUMBER;
  l_id            NUMBER;
  l_return_status VARCHAR2(1);
  l_move_rec      FTE_MOVES_PVT.move_rec_type;
  l_trip_move_rec FTE_TRIP_MOVES_PVT.trip_moves_rec_type;


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


  --
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_obsoleted_trip_moves.COUNT', x_obsoleted_trip_moves.COUNT);
  END IF;

  -- first, remove obsoleted trip moves in order to avoid duplicate data.
  IF x_obsoleted_trip_moves.COUNT > 0 THEN

    l_tm_index := x_obsoleted_trip_moves.FIRST;
    WHILE l_tm_index IS NOT NULL LOOP
      -- x_obsoleted_trip_moves(l_tm_index).move_id would be null in the case when the record contains trips
      -- that belong to an obsoleted move.
      IF x_obsoleted_trip_moves(l_tm_index).trip_move_id IS NULL
      AND x_obsoleted_trip_moves(l_tm_index).move_id IS NOT NULL THEN

        -- delete the move
        fte_moves_pvt.delete_move(
              p_move_id       => x_obsoleted_trip_moves(l_tm_index).move_id,
              p_validate_flag => 'Y',
              x_return_status => l_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_TP_RELEASE_INT.stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'NONE',
                      p_entity_interface_id => -1,
                      p_message_name        => 'WSH_TP_F_DELETE_OBS_MOVE',
                      p_token_1_name        => 'MOVE_ID',
                      p_token_1_value       => x_obsoleted_trip_moves(l_tm_index).move_id,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

      ELSIF x_obsoleted_trip_moves(l_tm_index).move_id IS NOT NULL THEN

        -- delete the trip_move segment
        fte_trip_moves_pvt.delete_trip_moves(
              p_trip_move_id       => x_obsoleted_trip_moves(l_tm_index).trip_move_id,
              x_return_status      => l_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_TP_RELEASE_INT.stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'NONE',
                      p_entity_interface_id => -1,
                      p_message_name        => 'WSH_TP_F_DELETE_OBS_MOVE',
                      p_token_1_name        => 'MOVE_ID',
                      p_token_1_value       => x_obsoleted_trip_moves(l_tm_index).move_id,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

      END IF;

      l_tm_index := x_obsoleted_trip_moves.NEXT(l_tm_index);
    END LOOP;

  END IF;



  IF x_plan_moves.COUNT > 0 THEN

    l_m_index := x_plan_moves.FIRST;
    WHILE l_m_index IS NOT NULL LOOP

      l_move_rec.move_id        := x_plan_moves(l_m_index).move_id;
      l_move_rec.move_type_code := x_plan_moves(l_m_index).move_type_code;
      l_move_rec.lane_id        := x_plan_moves(l_m_index).lane_id;
      l_move_rec.service_level  := x_plan_moves(l_m_index).service_level;
      l_move_rec.planned_flag   := 'N';
      l_move_rec.cm_trip_number := x_plan_moves(l_m_index).cm_trip_number;
      l_move_rec.tp_plan_name   := x_plan_moves(l_m_index).tp_plan_name;

      IF x_plan_moves(l_m_index).move_id IS NULL THEN
        fte_moves_pvt.create_move(
               p_move_info     => l_move_rec,
               x_move_id       => l_id,
               x_return_status => l_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_TP_RELEASE_INT.stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'FTE_MOVES_INTERFACE',
                      p_entity_interface_id => x_plan_moves(l_m_index).move_interface_id,
                      p_message_name        => 'WSH_TP_F_CREATE_MOVE',
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;
        x_plan_moves(l_m_index).move_id := l_id;
      ELSE
        fte_moves_pvt.update_move(
               p_move_info     => l_move_rec,
               x_return_status => l_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_TP_RELEASE_INT.stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'FTE_MOVES_INTERFACE',
                      p_entity_interface_id => x_plan_moves(l_m_index).move_interface_id,
                      p_message_name        => 'WSH_TP_F_UPDATE_MOVE',
                      p_token_1_name        => 'MOVE_ID',
                      p_token_1_value       => x_plan_moves(l_m_index).move_id,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;
      END IF;

      l_tm_index := x_plan_moves(l_m_index).trip_move_base_index;
      WHILE l_tm_index IS NOT NULL LOOP

        l_trip_move_rec.move_id         := x_plan_moves(x_plan_trip_moves(l_tm_index).move_index).move_id;
        l_trip_move_rec.trip_id         := x_plan_trips(x_plan_trip_moves(l_tm_index).trip_index).trip_id;
        l_trip_move_rec.sequence_number := x_plan_trip_moves(l_tm_index).sequence_number;
        l_trip_move_rec.trip_move_id    := x_plan_trip_moves(l_tm_index).trip_move_id;

        IF x_plan_trip_moves(l_tm_index).trip_move_id IS NULL THEN
          fte_trip_moves_pvt.create_trip_moves(
                 p_trip_moves_info => l_trip_move_rec,
                 x_trip_move_id    => l_id,
                 x_return_status   => l_return_status);
          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_TP_RELEASE_INT.stamp_interface_error(
                        p_group_id            => x_context.group_id,
                        p_entity_table_name   => 'FTE_TRIP_MOVES_INTERFACE',
                        p_entity_interface_id => x_plan_trip_moves(l_tm_index).trip_move_interface_id,
                        p_message_name        => 'WSH_TP_F_CREATE_TRIP_MOVE',
                        x_errors_tab          => x_errors_tab,
                        x_return_status       => l_return_status);
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
          END IF;
          x_plan_trip_moves(l_tm_index).trip_move_id := l_id;
        ELSE
          fte_trip_moves_pvt.update_trip_moves(
                 p_trip_moves_info => l_trip_move_rec,
                 x_return_status   => l_return_status);
          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_TP_RELEASE_INT.stamp_interface_error(
                        p_group_id            => x_context.group_id,
                        p_entity_table_name   => 'FTE_TRIP_MOVES_INTERFACE',
                        p_entity_interface_id => x_plan_trip_moves(l_tm_index).trip_move_interface_id,
                        p_message_name        => 'WSH_TP_F_UPDATE_TRIP_MOVE',
                        x_errors_tab          => x_errors_tab,
                        x_return_status       => l_return_status);
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
          END IF;
        END IF;

        l_tm_index := x_plan_trip_moves.NEXT(l_tm_index);
        IF l_tm_index IS NOT NULL THEN
          IF x_plan_trip_moves(l_tm_index).move_interface_id <> x_plan_moves(l_m_index).move_interface_id THEN
            -- finished looping through trip_moves for this move.
            l_tm_index := NULL;
          END IF;
        END IF;
      END LOOP;

      l_m_index := x_plan_moves.NEXT(l_m_index);
    END LOOP;

  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.reconciliate_moves',
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
--               Part of TP release process
--               Upgrade continuous moves' PLANNED_FLAG based on the plan
--

PROCEDURE tp_firm_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          )
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'tp_firm_moves';
  --
  l_debug_on BOOLEAN;
  --
  l_m_index       NUMBER;
  l_return_status VARCHAR2(1);
  l_move_rec      FTE_MOVES_PVT.move_rec_type;

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


  --
  --

  IF x_plan_moves.COUNT > 0 THEN

    l_m_index := x_plan_moves.FIRST;
    WHILE l_m_index IS NOT NULL LOOP

      IF (    (NVL(x_plan_moves(l_m_index).fte_planned_flag, 'N') = 'N')
          AND (x_plan_moves(l_m_index).planned_flag <> 'N'))
        OR
         (    (NVL(x_plan_moves(l_m_index).fte_planned_flag, 'N') = 'Y')
          AND (x_plan_moves(l_m_index).planned_flag = 'F'))  THEN
        l_move_rec.move_id        := x_plan_moves(l_m_index).move_id;
        l_move_rec.move_type_code := x_plan_moves(l_m_index).move_type_code;
        l_move_rec.lane_id        := x_plan_moves(l_m_index).lane_id;
        l_move_rec.service_level  := x_plan_moves(l_m_index).service_level;
        l_move_rec.planned_flag   := x_plan_moves(l_m_index).planned_flag;
        l_move_rec.cm_trip_number := x_plan_moves(l_m_index).cm_trip_number;
        l_move_rec.tp_plan_name   := x_plan_moves(l_m_index).tp_plan_name;

        fte_moves_pvt.update_move(
               p_move_info     => l_move_rec,
               x_return_status => l_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_TP_RELEASE_INT.stamp_interface_error(
                      p_group_id            => x_context.group_id,
                      p_entity_table_name   => 'FTE_MOVES_INTERFACE',
                      p_entity_interface_id => x_plan_moves(l_m_index).move_interface_id,
                      p_message_name        => 'WSH_TP_F_FIRM_MOVE',
                      p_token_1_name        => 'MOVE_ID',
                      p_token_1_value       => x_plan_moves(l_m_index).move_id,
                      x_errors_tab          => x_errors_tab,
                      x_return_status       => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

      END IF;

      l_m_index := x_plan_moves.NEXT(l_m_index);
    END LOOP;

  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.tp_firm_moves',
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
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'purge_interface_tables';
  --
  l_debug_on BOOLEAN;
  --
  i NUMBER;
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


  --
  --

  -- The tables must be deleted in the right order so that their
  -- records can be identified correctly.

  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from fte_moves_interface fmi
    where fmi.move_interface_id in (
      select distinct ftmi.move_interface_id
      from   fte_trip_moves_interface ftmi,
             wsh_trips_interface      wti
      where wti.group_id = p_group_ids(i)
      and   wti.interface_action_code = G_TP_RELEASE_CODE
      and   ftmi.trip_interface_id = wti.trip_interface_id
      and   ftmi.interface_action_code = G_TP_RELEASE_CODE)
    and fmi.interface_action_code = G_TP_RELEASE_CODE;


  FORALL i in p_group_ids.FIRST ..p_group_ids.LAST
    delete from fte_trip_moves_interface ftmi
    where ftmi.trip_move_interface_id in (
      select ftmi2.trip_move_interface_id
      from   fte_trip_moves_interface ftmi2,
             wsh_trips_interface      wti
      where wti.group_id = p_group_ids(i)
      and   wti.interface_action_code = G_TP_RELEASE_CODE
      and   ftmi2.trip_interface_id = wti.trip_interface_id
      and   ftmi2.interface_action_code = G_TP_RELEASE_CODE)
    and ftmi.interface_action_code = G_TP_RELEASE_CODE;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'FTE_TP_GRP.purge_interface_tables',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END purge_interface_tables;



END FTE_TP_GRP;

/
