--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_STOPS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_STOPS_VALIDATIONS" as
/* $Header: WSHSTVLB.pls 120.8.12010000.2 2009/12/03 13:06:24 mvudugul ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRIP_STOPS_VALIDATIONS';

--3509004 :public api changes
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
      p_out_rec         IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
      p_in_rec          IN WSH_TRIP_STOPS_GRP.stopInRecType,
      x_return_status   OUT NOCOPY    VARCHAR2);


/*
 For every New stop entered or Updated
1. Check if stop sequence number is positive integer
2. Check if stop status is OPEN for update,OPEN for insert as well
3. Check if the new planned arrival date is greater than the planned arrival date of
   arrived or closed stop
FP Bug 425334,per bug 4245339, validation of uniqueness is deferred to handle_internal_stops in WSHTRACB.pls.
*/
-- Stop id is there as of now,but no validation,in case required later
PROCEDURE validate_sequence_number
  (p_stop_id IN NUMBER,
   p_stop_sequence_number IN NUMBER,
   p_trip_id IN NUMBER,
   p_status_code IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2
   )
  IS

CURSOR c_lock_trip IS
  SELECT trip_id
    FROM wsh_trips
   WHERE trip_id = p_trip_id
  FOR UPDATE NOWAIT;


 l_return_status VARCHAR2(30);
 l_trip_id NUMBER;
 l_del_to_unassign WSH_UTIL_CORE.id_tab_type;

  RECORD_LOCKED          EXCEPTION;
  PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SEQUENCE_NUMBER';
--
BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_SEQUENCE_NUMBER',P_STOP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS_CODE',P_STATUS_CODE);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN c_lock_trip;
  FETCH c_lock_trip
   INTO l_trip_id;
  CLOSE c_lock_trip;

  IF p_stop_sequence_number IS NULL THEN
    -- Harmonization Project I heali
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

-- Check if sequence number is positive
  check_for_negative_number(
    p_stop_sequence_number => p_stop_sequence_number,
    x_return_status => l_return_status);
  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_STOP_SEQUENCE');
    wsh_util_core.add_message(x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

-- Check if stop status is Open
-- For new records pass this as OP as well
  validate_stop_status(
    p_stop_status => p_status_code,
    x_return_status => l_return_status);
  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_INVALID_STATUS');
    x_return_status := l_return_status;
    wsh_util_core.add_message(x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

-- validate for sequence number of closed stop,the new sequencenumber should
-- be greater than stop sequence number of closed stop
  validate_closed_stop_seq
    (p_trip_id => p_trip_id,
     p_stop_sequence_number => p_stop_sequence_number,
     x_return_status => l_return_status);
  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_SEQUENCE_LOWER');
    x_return_status := l_return_status;
    wsh_util_core.add_message(x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;
--
-- Check if update of Sequence Number is going to unassign a delivery from
-- the trip
-- Delivery D1 - Stop S1(10 as pickup) and Stop S2(25 as dropoff) on Trip T1
-- Example, updating of stop sequence from 10 to 50 would invalidate this
-- delivery on the trip.

-- This check is only for update
  IF p_stop_id IS NOT NULL THEN
    valid_delivery_on_trip
     (p_stop_id => p_stop_id,
      p_trip_id => p_trip_id,
      p_stop_sequence_number => p_stop_sequence_number,
      x_del_to_unassign => l_del_to_unassign,
      x_return_status => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status := l_return_status;
      ELSE
        x_return_status := l_return_status;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      END IF;
    END IF; --If return status is not success from API
  END IF; -- if p_stop_id is not null

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN RECORD_LOCKED THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
    WSH_UTIL_CORE.add_message (x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
END IF;
--
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.validate_sequence_number');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END validate_sequence_number;


PROCEDURE validate_closed_stop_seq
    (p_trip_id IN NUMBER,
     p_stop_sequence_number IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2) IS

-- nvl is if no records exist
  CURSOR c_check_max IS
    SELECT nvl(max(stop_sequence_number),0) stop_sequence_number
      FROM wsh_trip_stops
     WHERE trip_id = p_trip_id
       AND status_code IN ('AR','CL');

  l_max_sequence NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CLOSED_STOP_SEQ';
--
BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_SEQUENCE_NUMBER',P_STOP_SEQUENCE_NUMBER);
  END IF;
  --
  OPEN c_check_max;
  FETCH c_check_max
   INTO l_max_sequence;

  IF (c_check_max%NOTFOUND or l_max_sequence = 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSIF (l_max_sequence > p_stop_sequence_number) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  CLOSE c_check_max;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.validate_closed_stop_seq');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;
/* p_stop id will be null for new records
   for update it will be populated
*/
PROCEDURE validate_unique_sequence
    (p_trip_id IN NUMBER,
     p_stop_id IN NUMBER,
     p_stop_sequence_number IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR c_check_unique IS
    SELECT stop_id
      FROM wsh_trip_stops
     WHERE trip_id = p_trip_id
       AND stop_sequence_number = p_stop_sequence_number
       AND rownum = 1 ;

  l_check_flag VARCHAR2(1) := 'N';
  l_stop_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_UNIQUE_SEQUENCE';
--
BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_SEQUENCE_NUMBER',P_STOP_SEQUENCE_NUMBER);
  END IF;
  --
  OPEN c_check_unique;
  FETCH c_check_unique
   INTO l_stop_id;

/* for update check if the new sequence number is same as existing value
   then success */
  IF (
      (p_stop_id IS NOT NULL
       AND l_stop_id = p_stop_id
       )  OR
      (c_check_unique%NOTFOUND) OR
      (l_stop_id IS NULL)
    )THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
-- l_stop_id is not null and <> p_stop_id
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;
/*
-- no records exist
  IF (l_check_flag = 'N' OR c_check_unique%NOTFOUND) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSIF l_check_flag = 'Y' THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;
*/

  CLOSE c_check_unique;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.validate_unique_sequence');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;

PROCEDURE check_for_negative_number
  (p_stop_sequence_number IN NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_FOR_NEGATIVE_NUMBER';
   --
BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_SEQUENCE_NUMBER',P_STOP_SEQUENCE_NUMBER);
  END IF;
  --
  IF p_stop_sequence_number > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.check_for_negative_number');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END ;

PROCEDURE validate_stop_status
  (p_stop_status IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_STOP_STATUS';
   --
BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_STATUS',P_STOP_STATUS);
  END IF;
  --
  IF p_stop_status = 'OP' THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.validate_stop_status');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;
/** Logic used here
  For this trip_id and stop_id, find all the deliveries associated
   which means find deliveries which will be OPEN and have this stop location
   as either their pickup location or drop off location.

  If yes then
    evaluate with the new stop sequence to see if the original pickup or dropoff
    plans for delivery is not altered by updating this stop sequence.
  End if;

  x_del_to_unassign returns the list of deliveries which have to be unassigned

**/
PROCEDURE valid_delivery_on_trip
     (p_stop_id IN NUMBER,
      p_trip_id IN NUMBER,
      p_stop_sequence_number IN NUMBER,
      x_del_to_unassign OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
      x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR c_stop_details IS
  SELECT stop_sequence_number,
         stop_id
    FROM wsh_trip_stops
   WHERE trip_id = p_trip_id
     AND status_code = 'OP'  -- this is a case only for Open stops
     AND stop_id <> p_stop_id ;

l_rec_stop WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab;

-- Question , Can there be multiple record with same stop id as pickup
CURSOR c_wdl_details1 IS
  SELECT pick_up_stop_id,
         drop_off_stop_id,
         wdl.delivery_id
    FROM wsh_delivery_legs wdl
   WHERE (pick_up_stop_id = p_stop_id
          OR drop_off_stop_id = p_stop_id);

CURSOR c_wdl_details2 IS
  SELECT pick_up_stop_id,
         drop_off_stop_id,
         delivery_id
    FROM wsh_delivery_legs
   WHERE drop_off_stop_id = p_stop_id;

l_rec_wdl1 WSH_TRIP_STOPS_VALIDATIONS.dleg_details_tab;
--l_rec_wdl2 c_wdl_details%TYPE;

stop_count NUMBER := 0;
dleg_count NUMBER := 0;
l_num_warn NUMBER := 0;

--this will be used to unassign deliveries from trip
l_del_to_unassign WSH_UTIL_CORE.id_tab_type;
l_return_status VARCHAR2(30) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALID_DELIVERY_ON_TRIP';
--
BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_SEQUENCE_NUMBER',P_STOP_SEQUENCE_NUMBER);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FOR rec in c_stop_details
  LOOP
    stop_count := stop_count + 1;
    l_rec_stop(stop_count).stop_sequence_number := rec.stop_sequence_number;
    l_rec_stop(stop_count).stop_id := rec.stop_id;

  END LOOP;


-- If no records are found means,there is no delivery associated
-- with the stops and the sequence numbers can be updated

-- for the stop ,find delivery legs where this stop is pickup or dropoff

  FOR rec IN c_wdl_details1
  LOOP
    dleg_count := dleg_count + 1;
    l_rec_wdl1(dleg_count).pick_up_stop_id := rec.pick_up_stop_id;
    l_rec_wdl1(dleg_count).drop_off_stop_id := rec.drop_off_stop_id;
    l_rec_wdl1(dleg_count).delivery_id := rec.delivery_id;

  END LOOP;


/*
-- for the stop ,find delivery legs where this stop is drop off

  OPEN   c_wdl_details2;
  FETCH  c_wdl_details2
   INTO  l_rec_wdl2;
  CLOSE  c_wdl_details2;
*/

-- Warning will be that some of the deliveries will be unassigned
-- from the trip

  FOR i in 1..l_rec_stop.count
  LOOP
    FOR j in 1..l_rec_wdl1.count
    LOOP
      IF l_rec_wdl1(j).pick_up_stop_id = l_rec_stop(i).stop_id THEN
         --compare with new stop sequence number
         -- If new stop is earlier than the pick up - then message
        IF p_stop_sequence_number < l_rec_stop(i).stop_sequence_number THEN
          l_del_to_unassign(l_del_to_unassign.count + 1) :=
             l_rec_wdl1(j).delivery_id;
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_TRIP');
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
                            WSH_NEW_DELIVERIES_PVT.get_name(l_rec_wdl1(j).delivery_id));
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FND_MESSAGE.SET_TOKEN('TRIP_NAME',
                            WSH_TRIPS_PVT.get_name(p_trip_id));
          l_num_warn := l_num_warn + 1;
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);

        END IF;

-- Both cases for pickup and drop off cannot be true separately at the same time
-- It can be either pickup or drop off ,as we match with the stop id when
-- creating l_rec_wdl1 and there is no existing record in l_rec_stop for p_stop_id

      ELSIF l_rec_wdl1(j).drop_off_stop_id = l_rec_stop(i).stop_id THEN
         --compare with new stop sequence number
         -- If new stop is later than the dropoff - then message
        IF p_stop_sequence_number > l_rec_stop(i).stop_sequence_number THEN
          l_del_to_unassign(l_del_to_unassign.count + 1) :=
             l_rec_wdl1(j).delivery_id;
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_TRIP');
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
                            WSH_NEW_DELIVERIES_PVT.get_name(l_rec_wdl1(j).delivery_id));
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FND_MESSAGE.SET_TOKEN('TRIP_NAME',
                            WSH_TRIPS_PVT.get_name(p_trip_id));
          l_num_warn := l_num_warn + 1;
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);

        END IF;

      END IF;
    END LOOP;
  END LOOP;
-- as of now ,keep error
  IF (l_num_warn > 0 AND l_del_to_unassign.count > 0) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.UNASSIGN_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_TRIPS_ACTIONS.unassign_trip
          (p_del_rows => l_del_to_unassign,
           p_trip_id  => p_trip_id,
           x_return_status => l_return_status);
  END IF;


  IF l_num_warn > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSIF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
  END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.valid_delivery_on_trip');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;
/*
This is called from Assign to Trip
Case1 - Use pickup and dropoff locations on delivery to create new stops.
        In this case, stop sequence number has to be generated and then
        validated
Case2 - Use new pickup and dropoff locations specified.In this case just
        validate the new pickup and stop sequence number.
Case3 - Use new pickup and the drop off on the delivery.In this case, validate
        the new pickup stop sequence and generate and validate for
        dropoff (as per delivery).
        Test the case, where there are multiple deliveries.
        In that case,since new Pickup or Dropoff takes precedence, so
        in this case the dropoff locations on all the deliveries will have
        new stops created but only 1 pickup will be created.

Case4 - Use pickup on the delivery and new drop off location.In this case,
        validate the new dropoff stop sequence number and generate
        and validate for the pickup exisitng on the delivery.

*/
PROCEDURE get_new_sequence_number
  (x_stop_sequence_number IN OUT NOCOPY  NUMBER,
   p_trip_id              IN NUMBER,
   p_status_code          IN VARCHAR2,
   p_stop_id              IN NUMBER,
   p_new_flag             IN VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2
   ) IS

CURSOR c_get_max_sequence IS
  SELECT nvl(max(stop_sequence_number),0) stop_sequence_number
    FROM wsh_trip_stops
   WHERE trip_id = p_trip_id;

  l_stop_sequence_number NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_NEW_SEQUENCE_NUMBER';
--
BEGIN
-- The processing is for each stop and not the combination
-- It can be a new Pickup
-- or New Dropoff
-- or as per Delivery

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
      WSH_DEBUG_SV.log(l_module_name,'X_STOP_SEQUENCE_NUMBER',X_STOP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS_CODE',P_STATUS_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_NEW_FLAG',P_NEW_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_stop_sequence_number := 0;

-- new pickup or dropoff
  IF (p_new_flag IN ('PICKUP','DROPOFF')) THEN /* pickup or dropoff */

    validate_sequence_number
      (p_stop_id => p_stop_id,
       p_stop_sequence_number => x_stop_sequence_number,
       p_trip_id => p_trip_id,
       p_status_code => p_status_code,
       x_return_status => x_return_status);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

-- no new pickup or dropoff
-- use delivery level information
  ELSIF p_new_flag = 'DELIVERY' THEN /* delivery */
/* For an existing delivery and matching stops ,if any ,will have a stop sequence
   number - in that case the flow will not come to this place.
   For this code ,So p_stop_sequence_number cannot be populated for an existing delivery.
*/
    IF (nvl(x_stop_sequence_number,0) = 0 )THEN
      OPEN c_get_max_sequence;
      FETCH c_get_max_sequence
       INTO l_stop_sequence_number;
      CLOSE c_get_max_sequence;
    END IF;
-- First time x_stop_sequence will be null then use l_stop_sequence
-- Else use x_stop_sequence when this API is called by itself
-- SSN change
-- Add 10 to derive next SSN
    l_stop_sequence_number := nvl(x_stop_sequence_number,l_stop_sequence_number) + 10;

-- Generate Logic here
    validate_sequence_number
      (p_stop_id => p_stop_id,
       p_stop_sequence_number => l_stop_sequence_number,
       p_trip_id => p_trip_id,
       p_status_code => p_status_code,
       x_return_status => x_return_status);

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      -- try another number,append by 10 more
      get_new_sequence_number
        (x_stop_sequence_number => l_stop_sequence_number,
         p_trip_id              => p_trip_id,
         p_status_code          => p_status_code,
         p_stop_id              => p_stop_id,
         p_new_flag             => p_new_flag,
         x_return_status        => x_return_status);

    END IF; /* not success */

    x_stop_sequence_number := l_stop_sequence_number;

  END IF; /* End of flag */
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_TRIP_STOP_VALIDATIONS.get_new_sequence_number');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;


PROCEDURE Is_Action_Enabled(
                p_stop_rec_tab          IN      stop_rec_tab_type,
                p_action                IN      VARCHAR2,
                p_caller                IN      VARCHAR2,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_valid_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_error_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_valid_index_tab       OUT NOCOPY      wsh_util_core.id_tab_type
          ) IS


cursor  stop_to_del_cur( p_stop_id IN NUMBER ) is
select  wnd.delivery_id,
        wnd.organization_id,
        wnd.status_code,
        wnd.planned_flag,
/*J inbound logistics new column jckwok*/
        NVL(wnd.shipment_direction, 'O') shipment_direction,
        wnd.delivery_type, --MDC
        NVL(wnd.ignore_for_planning, 'N') ignore_for_planning,  --OTM R12, glog proj
        NVL(wnd.tms_interface_flag,WSH_TRIP_STOPS_PVT.C_TMS_NOT_TO_BE_SENT) tms_interface_flag, -- OTM R12, glog proj
        NVL(mcp.otm_enabled,wsp.otm_enabled) otm_enabled, -- LSP PROJECT : checking OTM enabled flag on client parameters.
        wnd.client_id -- LSP PROJECT
from    wsh_new_deliveries wnd,
        wsh_delivery_legs wdl,
        wsh_shipping_parameters wsp,
        mtl_client_parameters_v mcp
where   wnd.delivery_id = wdl.delivery_id
and     (wdl.pick_up_stop_id = p_stop_id
         OR wdl.drop_off_stop_id = p_stop_id )
and     wnd.organization_id = wsp.organization_id
and     wnd.client_id = mcp.client_id (+);

cursor  stop_to_det_cur( p_stop_id IN NUMBER ) is
select  distinct 'X'
from    wsh_delivery_details wdd,
        wsh_new_deliveries wnd,
        wsh_delivery_assignments_v wda,
        wsh_delivery_legs wdl
where   (wdl.pick_up_stop_id = p_stop_id OR  wdl.drop_off_stop_id = p_stop_id)
and     wnd.delivery_id = wdl.delivery_id
and     wda.delivery_id = wnd.delivery_id
and     wdd.delivery_detail_id = wda.delivery_detail_id
and     wdd.source_code = 'WSH'
and     wdd.container_flag = 'N';

--/== Workflow Changes
cursor  stop_del_cur_wf( p_stop_id IN NUMBER ) is
select  wnd.delivery_id,
	wnd.delivery_scpod_wf_process,
        wnd.del_wf_intransit_attr,
	wnd.del_wf_close_attr,
	decode(p_stop_id,wdl.drop_off_stop_id,'D',wdl.pick_up_stop_id,'P','X') stop_type
from    wsh_new_deliveries wnd,
        wsh_delivery_legs wdl
where   wnd.delivery_id = wdl.delivery_id
and    (wdl.pick_up_stop_id = p_stop_id  OR
        wdl.drop_off_stop_id = p_stop_id );

l_override_wf    VARCHAR2(1);
l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
l_purged_count   NUMBER;
l_wf_rs          VARCHAR2(1);
e_scpod_wf_inprogress EXCEPTION;
--==/

l_stop_actions_tab 	StopActionsTabType;
l_valid_ids             wsh_util_core.id_tab_type;
l_error_ids             wsh_util_core.id_tab_type;
l_valid_index_tab       wsh_util_core.id_tab_type;
l_dlvy_rec_tab          WSH_DELIVERY_VALIDATIONS.dlvy_rec_tab_type;

l_tpw_temp 		VARCHAR2(1);
l_return_status 	VARCHAR2(1);
error_in_init_actions   EXCEPTION;
e_set_messages          EXCEPTION;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_ACTION_ENABLED';
--
l_caller                VARCHAR2(100);

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
     WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
     WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
 END IF;

 Init_Stop_Actions_Tbl(
	p_action => p_action,
	x_stop_actions_tab => l_stop_actions_tab,
	x_return_status => x_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Init_Detail_Actions_Tbl x_return_status',x_return_status);
 END IF;

 IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
    raise error_in_init_actions;
 END IF;

 FOR j IN p_stop_rec_tab.FIRST..p_stop_rec_tab.LAST LOOP
 BEGIN

     -- J-IB-NPARIKH-{
     --
     l_caller           := p_caller;
     --
     --
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_caller', l_caller);
     END IF;
        --
        --
        -- Actions on inbound trip-stops are allowed only if caller
        -- starts with  one of the following:
        --     - FTE
        --     - WSH_IB
        --     - WSH_PUB
        --     - WSH_TP_RELEASE
        -- For any other callers, set l_caller to WSH_FSTRX
        -- Since for caller, WSH_FSTRX, all actions are disabled
        -- on inbound trip stops
        --
        --
        --
        IF  nvl(p_stop_rec_tab(j).shipments_type_flag,'O') = 'I'
        THEN
        --{
            IF l_caller LIKE 'FTE%'
            OR l_caller LIKE 'WSH_PUB%'
            OR l_caller LIKE 'WSH_IB%'
            OR l_caller LIKE 'WSH_TP_RELEASE%'
            THEN
                NULL;
            ELSE
                l_caller := 'WSH_FSTRX';
            END IF;
        --}
        END IF;
     --
     --
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_caller-modified', l_caller);
     END IF;
     -- J-IB-NPARIKH-}
     --

    IF (l_stop_actions_tab.COUNT > 0) THEN
       For k in l_stop_actions_tab.FIRST..l_stop_actions_tab.LAST LOOP
          IF(nvl(l_stop_actions_tab(k).status_code,p_stop_rec_tab(j).status_code) = p_stop_rec_tab(j).status_code
             AND nvl(l_stop_actions_tab(k).caller,p_caller) = p_caller
	     AND l_stop_actions_tab(k).action_not_allowed = p_action
-- add check to compare shipments_type_flag jckwok
             AND nvl(l_stop_actions_tab(k).shipments_type_flag, nvl(p_stop_rec_tab(j).shipments_type_flag,'O')) = nvl(p_stop_rec_tab(j).shipments_type_flag,'O')) THEN
             RAISE e_set_messages;
          END IF;
       END LOOP;
    END IF;

    IF ( p_action ='PICK-RELEASE') THEN
       FOR cur_rec IN stop_to_del_cur(p_stop_rec_tab(j).stop_id) LOOP
          l_dlvy_rec_tab(l_dlvy_rec_tab.count+1) := cur_rec;
       END LOOP;

       WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
                p_dlvy_rec_tab          => l_dlvy_rec_tab,
                p_action                => p_action,
                p_caller                => p_caller,
                x_return_status         => l_return_status,
                x_valid_ids             => l_valid_ids,
                x_error_ids             => l_error_ids,
                x_valid_index_tab       => l_valid_index_tab);

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',l_return_status);
       END IF;

       IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
         AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          RAISE e_set_messages;
       ELSE
          x_valid_ids(x_valid_ids.COUNT + 1) := p_stop_rec_tab(j).stop_id;
          x_valid_index_tab(j) := j;
       END IF;

    ELSIF ( p_action IN ('PLAN', 'UNPLAN' )) THEN
	  open stop_to_det_cur( p_stop_rec_tab(j).stop_id);
	  Fetch stop_to_det_cur into l_tpw_temp;
	  close stop_to_det_cur;

	  IF ( l_tpw_temp is not null ) THEN
             x_valid_ids(x_valid_ids.COUNT + 1) := p_stop_rec_tab(j).stop_id;
             x_valid_index_tab(j) := j;
	  ELSE
             FOR cur_rec IN stop_to_del_cur(p_stop_rec_tab(j).stop_id) LOOP
                l_dlvy_rec_tab(l_dlvy_rec_tab.count+1) := cur_rec;
             END LOOP;

             WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
                p_dlvy_rec_tab          => l_dlvy_rec_tab,
                p_action                => p_action,
                p_caller                => p_caller,
                x_return_status         => l_return_status,
                x_valid_ids             => l_valid_ids,
                x_error_ids             => l_error_ids,
                x_valid_index_tab       => l_valid_index_tab);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',
                                                l_return_status);
             END IF;

             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                RAISE e_set_messages;
             ELSE
                x_valid_ids(x_valid_ids.COUNT + 1) := p_stop_rec_tab(j).stop_id;
                x_valid_index_tab(j) := j;
             END IF;
          END IF;
    --/== Workflow Changes
    ELSIF (p_action IN('UPDATE-STATUS')) THEN
    	l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
	IF (nvl(l_override_wf,'N') = 'N') THEN
  	    FOR cur_rec IN stop_del_cur_wf(p_stop_rec_tab(j).stop_id) LOOP
		IF (cur_rec.delivery_scpod_wf_process is not null and
		      ( ( cur_rec.stop_type='P' and cur_rec.del_wf_intransit_attr = 'I')
                         or ( cur_rec.stop_type='D' and cur_rec.del_wf_close_attr = 'I') ) )THEN
		    RAISE e_scpod_wf_inprogress;
		END IF;
	    END LOOP;
	END IF;
        x_valid_ids(x_valid_ids.COUNT + 1) := p_stop_rec_tab(j).stop_id;
        x_valid_index_tab(j) := j;     -- Workflow Changes ==/
    ELSE
	  x_valid_ids(x_valid_ids.COUNT + 1) := p_stop_rec_tab(j).stop_id;
          x_valid_index_tab(j) := j;
    END IF;
 EXCEPTION
    WHEN e_scpod_wf_inprogress THEN     --/== Workflow Changes
       x_error_ids(x_error_ids.count +1) := p_stop_rec_tab(j).stop_id;
       FND_MESSAGE.SET_NAME('WSH','WSH_WF_STOP_ACTION_INELIGIBLE');
       FND_MESSAGE.Set_Token('STOP_ID',x_error_ids(x_error_ids.count));
       FND_MESSAGE.Set_Token('ACTION',wsh_util_core.get_action_meaning('STOP', p_action));
       wsh_util_core.add_message('E',l_module_name);         --==/
    WHEN e_set_messages THEN
       x_error_ids(x_error_ids.count +1) := p_stop_rec_tab(j).stop_id;
       IF p_caller = 'WSH_PUB'
          OR p_caller like 'FTE%' THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_STOP_ACTION_INELIGIBLE');
          FND_MESSAGE.Set_Token('STOP_ID',x_error_ids(x_error_ids.count));
          FND_MESSAGE.Set_Token('ACTION',wsh_util_core.get_action_meaning('STOP', p_action));
          wsh_util_core.add_message('E',l_module_name);
       END IF;
 END;
 END LOOP;

 IF (x_valid_ids.COUNT = 0 ) THEN
    --{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF NOT (l_caller = 'WSH_PUB' OR l_caller LIKE 'FTE%') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --}
 ELSIF (x_valid_ids.COUNT = p_stop_rec_tab.COUNT) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 ELSIF (x_valid_ids.COUNT < p_stop_rec_tab.COUNT ) THEN
    --{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    IF NOT (l_caller = 'WSH_PUB' OR l_caller LIKE 'FTE%') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED_WARN');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --}
 ELSE
    --{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF NOT (l_caller = 'WSH_PUB' OR l_caller LIKE 'FTE%') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --}
 END IF;

 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN error_in_init_actions THEN
   -- OTM R12, glog proj, other cursors are not using OPEN/FETCH
   IF stop_to_det_cur%ISOPEN THEN
     CLOSE stop_to_det_cur;
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'error_in_init_actions exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:error_in_init_actions');
   END IF;

  WHEN OTHERS THEN
   -- OTM R12, glog proj, other cursors are not using OPEN/FETCH
   IF stop_to_det_cur%ISOPEN THEN
     CLOSE stop_to_det_cur;
   END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                          SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
END Is_Action_Enabled;


/*
   Procedure populate_external_edf is called from
   eliminate_displayonly_fields to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_edf(
  p_internal        IN   NUMBER
, p_external        IN   VARCHAR2
, x_internal        IN OUT  NOCOPY NUMBER
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
      x_internal := p_internal;
      IF p_internal IS NULL THEN
         x_external := NULL;
      ELSE
         x_external := p_external;
      END IF;
   ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
      x_external := p_external;
      IF x_external IS NULL THEN
         x_internal := NULL;
      ELSE
         x_internal := p_internal;
      END IF;
   END IF;

END populate_external_edf;


/*
   Procedure populate_external_edf is called from
   eliminate_displayonly_fields to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_edf(
  p_internal        IN   VARCHAR2
, p_external        IN   VARCHAR2
, x_internal        IN OUT  NOCOPY VARCHAR2
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
      x_internal := p_internal;
      IF p_internal IS NULL THEN
         x_external := NULL;
      ELSE
         x_external := p_external;
      END IF;
   ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
      x_external := p_external;
      IF x_external IS NULL THEN
         x_internal := NULL;
      ELSE
         x_internal := p_internal;
      END IF;
   END IF;

END populate_external_edf;



PROCEDURE eliminate_displayonly_fields (
  p_stop_rec   IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, p_in_rec		  IN  WSH_TRIP_STOPS_GRP.stopInRecType
, x_stop_rec   IN OUT NOCOPY WSH_TRIP_STOPS_PVT.trip_stop_rec_type
)
IS
BEGIN

    /*
       Enable the x_delivery_detail_rec, with the columns that are not
       permanently  disabled.
    */
    populate_external_edf(p_stop_rec.STOP_LOCATION_ID,
                          p_stop_rec.stop_location_code,
                          x_stop_rec.STOP_LOCATION_ID,
                          x_stop_rec.stop_location_code);

/*
    populate_external_edf(p_stop_rec.trip_id,
                          p_stop_rec.trip_name,
                          x_stop_rec.trip_id,
                          x_stop_rec.trip_name);

*/
    IF p_stop_rec.DEPARTURE_SEAL_CODE <> FND_API.G_MISS_CHAR
      OR p_stop_rec.DEPARTURE_SEAL_CODE IS NULL THEN
      x_stop_rec.DEPARTURE_SEAL_CODE :=
                          p_stop_rec.DEPARTURE_SEAL_CODE;
    END IF;

-- SSN change
-- For mode=PAD, Stop_sequence_number would be null when user tries to create a stop
    IF ((p_in_rec.action_code =  'CREATE')
       AND
       (WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD))
    THEN
       -- csun stop sequence enhancement for 11.5.10, the stop sequence number for a
       -- trip stop is set to -99 initially since it is a required filed in the table,
       -- it will be re-sequenced  in WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP right after
       -- it is created.
       x_stop_rec.STOP_SEQUENCE_NUMBER := -99;
-- but for mode = SSN, stop_sequence_number field would always have to be specified
-- when creating a stop
    ELSIF p_stop_rec.STOP_SEQUENCE_NUMBER <> FND_API.G_MISS_NUM
      OR p_stop_rec.STOP_SEQUENCE_NUMBER IS NULL THEN
      x_stop_rec.STOP_SEQUENCE_NUMBER :=
                          p_stop_rec.STOP_SEQUENCE_NUMBER;
    END IF;
-- end of SSN change

    IF p_stop_rec.PLANNED_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      OR p_stop_rec.PLANNED_ARRIVAL_DATE IS NULL THEN
      x_stop_rec.PLANNED_ARRIVAL_DATE :=
                          p_stop_rec.PLANNED_ARRIVAL_DATE;
    END IF;
    IF p_stop_rec.PLANNED_DEPARTURE_DATE <> FND_API.G_MISS_DATE
      OR p_stop_rec.PLANNED_DEPARTURE_DATE IS NULL THEN
      x_stop_rec.PLANNED_DEPARTURE_DATE :=
                          p_stop_rec.PLANNED_DEPARTURE_DATE;
    END IF;
    IF p_stop_rec.DEPARTURE_GROSS_WEIGHT <> FND_API.G_MISS_NUM
      OR p_stop_rec.DEPARTURE_GROSS_WEIGHT IS NULL THEN
      x_stop_rec.DEPARTURE_GROSS_WEIGHT :=
                          p_stop_rec.DEPARTURE_GROSS_WEIGHT;
    END IF;
    IF p_stop_rec.DEPARTURE_NET_WEIGHT <> FND_API.G_MISS_NUM
      OR p_stop_rec.DEPARTURE_NET_WEIGHT IS NULL THEN
      x_stop_rec.DEPARTURE_NET_WEIGHT :=
                          p_stop_rec.DEPARTURE_NET_WEIGHT;
    END IF;

    populate_external_edf(p_stop_rec.WEIGHT_UOM_CODE,
                          p_stop_rec.WEIGHT_UOM_DESC,
                          x_stop_rec.WEIGHT_UOM_CODE,
                          x_stop_rec.WEIGHT_UOM_DESC);

    IF p_stop_rec.DEPARTURE_VOLUME <> FND_API.G_MISS_NUM
      OR p_stop_rec.DEPARTURE_VOLUME IS NULL THEN
      x_stop_rec.DEPARTURE_VOLUME :=
                          p_stop_rec.DEPARTURE_VOLUME;
    END IF;

    populate_external_edf(p_stop_rec.VOLUME_UOM_CODE,
                          p_stop_rec.VOLUME_UOM_DESC,
                          x_stop_rec.VOLUME_UOM_CODE,
                          x_stop_rec.VOLUME_UOM_DESC);

    -- bug 3666967 - need wv_frozen_flag when creating new stop through public api.
    IF p_stop_rec.wv_frozen_flag <> FND_API.G_MISS_CHAR THEN
      x_stop_rec.wv_frozen_flag :=
                          p_stop_rec.wv_frozen_flag;
    END IF;
    -- end bug 3666967

    IF p_stop_rec.DEPARTURE_FILL_PERCENT <> FND_API.G_MISS_NUM
      OR p_stop_rec.DEPARTURE_FILL_PERCENT IS NULL THEN
      x_stop_rec.DEPARTURE_FILL_PERCENT :=
                          p_stop_rec.DEPARTURE_FILL_PERCENT;
    END IF;
    IF p_stop_rec.attribute1 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute1 IS NULL THEN
      x_stop_rec.attribute1 :=
                          p_stop_rec.attribute1;
    END IF;
    IF p_stop_rec.attribute2 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute2 IS NULL THEN
      x_stop_rec.attribute2 :=
                          p_stop_rec.attribute2;
    END IF;
    IF p_stop_rec.attribute3 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute3 IS NULL THEN
      x_stop_rec.attribute3 :=
                          p_stop_rec.attribute3;
    END IF;
    IF p_stop_rec.attribute4 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute4 IS NULL THEN
      x_stop_rec.attribute4 :=
                          p_stop_rec.attribute4;
    END IF;
    IF p_stop_rec.attribute5 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute5 IS NULL THEN
      x_stop_rec.attribute5 :=
                          p_stop_rec.attribute5;
    END IF;
    IF p_stop_rec.attribute6 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute6 IS NULL THEN
      x_stop_rec.attribute6 :=
                          p_stop_rec.attribute6;
    END IF;
    IF p_stop_rec.attribute7 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute7 IS NULL THEN
      x_stop_rec.attribute7 :=
                          p_stop_rec.attribute7;
    END IF;
    IF p_stop_rec.attribute8 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute8 IS NULL THEN
      x_stop_rec.attribute8 :=
                          p_stop_rec.attribute8;
    END IF;
    IF p_stop_rec.attribute9 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute9 IS NULL THEN
      x_stop_rec.attribute9 :=
                          p_stop_rec.attribute9;
    END IF;
    IF p_stop_rec.attribute10 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute10 IS NULL THEN
      x_stop_rec.attribute10 :=
                          p_stop_rec.attribute10;
    END IF;
    IF p_stop_rec.attribute11 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute11 IS NULL THEN
      x_stop_rec.attribute11 :=
                          p_stop_rec.attribute11;
    END IF;
    IF p_stop_rec.attribute12 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute12 IS NULL THEN
      x_stop_rec.attribute12 :=
                          p_stop_rec.attribute12;
    END IF;
    IF p_stop_rec.attribute13 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute13 IS NULL THEN
      x_stop_rec.attribute13 :=
                          p_stop_rec.attribute13;
    END IF;
    IF p_stop_rec.attribute14 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute14 IS NULL THEN
      x_stop_rec.attribute14 :=
                          p_stop_rec.attribute14;
    END IF;
    IF p_stop_rec.attribute15 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.attribute15 IS NULL THEN
      x_stop_rec.attribute15 :=
                          p_stop_rec.attribute15;
    END IF;
    IF p_stop_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      OR p_stop_rec.ATTRIBUTE_CATEGORY IS NULL THEN
      x_stop_rec.ATTRIBUTE_CATEGORY :=
                          p_stop_rec.ATTRIBUTE_CATEGORY;
    END IF;
    IF p_stop_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute1 IS NULL THEN
      x_stop_rec.tp_attribute1 :=
                          p_stop_rec.tp_attribute1;
    END IF;
    IF p_stop_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute2 IS NULL THEN
      x_stop_rec.tp_attribute2 :=
                          p_stop_rec.tp_attribute2;
    END IF;
    IF p_stop_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute3 IS NULL THEN
      x_stop_rec.tp_attribute3 :=
                          p_stop_rec.tp_attribute3;
    END IF;
    IF p_stop_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute4 IS NULL THEN
      x_stop_rec.tp_attribute4 :=
                          p_stop_rec.tp_attribute4;
    END IF;
    IF p_stop_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute5 IS NULL THEN
      x_stop_rec.tp_attribute5 :=
                          p_stop_rec.tp_attribute5;
    END IF;
    IF p_stop_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute6 IS NULL THEN
      x_stop_rec.tp_attribute6 :=
                          p_stop_rec.tp_attribute6;
    END IF;
    IF p_stop_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute7 IS NULL THEN
      x_stop_rec.tp_attribute7 :=
                          p_stop_rec.tp_attribute7;
    END IF;
    IF p_stop_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute8 IS NULL THEN
      x_stop_rec.tp_attribute8 :=
                          p_stop_rec.tp_attribute8;
    END IF;
    IF p_stop_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute9 IS NULL THEN
      x_stop_rec.tp_attribute9 :=
                          p_stop_rec.tp_attribute9;
    END IF;
    IF p_stop_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute10 IS NULL THEN
      x_stop_rec.tp_attribute10 :=
                          p_stop_rec.tp_attribute10;
    END IF;
    IF p_stop_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute11 IS NULL THEN
      x_stop_rec.tp_attribute11 :=
                          p_stop_rec.tp_attribute11;
    END IF;
    IF p_stop_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute12 IS NULL THEN
      x_stop_rec.tp_attribute12 :=
                          p_stop_rec.tp_attribute12;
    END IF;
    IF p_stop_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute13 IS NULL THEN
      x_stop_rec.tp_attribute13 :=
                          p_stop_rec.tp_attribute13;
    END IF;
    IF p_stop_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute14 IS NULL THEN
      x_stop_rec.tp_attribute14 :=
                          p_stop_rec.tp_attribute14;
    END IF;
    IF p_stop_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
      OR p_stop_rec.tp_attribute15 IS NULL THEN
      x_stop_rec.tp_attribute15 :=
                          p_stop_rec.tp_attribute15;
    END IF;
    IF p_stop_rec.TP_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      OR p_stop_rec.TP_ATTRIBUTE_CATEGORY IS NULL THEN
      x_stop_rec.TP_ATTRIBUTE_CATEGORY :=
                          p_stop_rec.TP_ATTRIBUTE_CATEGORY;
    END IF;

    IF p_in_rec.caller IN ('FTEMLWRB','WSH_TP_RELEASE') THEN
      IF p_stop_rec.wkday_layover_stops <> FND_API.G_MISS_NUM
         OR p_stop_rec.wkday_layover_stops IS NULL THEN
          x_stop_rec.wkday_layover_stops :=
                          p_stop_rec.wkday_layover_stops;
      END IF;
      IF p_stop_rec.wkend_layover_stops <> FND_API.G_MISS_NUM
         OR p_stop_rec.wkend_layover_stops IS NULL THEN
          x_stop_rec.wkend_layover_stops :=
                          p_stop_rec.wkend_layover_stops;
      END IF;
    END IF;
    IF p_in_rec.caller='WSH_TP_RELEASE' THEN
      IF p_stop_rec.tp_stop_id <> FND_API.G_MISS_NUM
         OR p_stop_rec.tp_stop_id IS NULL THEN
          x_stop_rec.tp_stop_id :=
                          p_stop_rec.tp_stop_id;
      END IF;
    END IF;
    --Bug 3282166
    --
    IF p_in_rec.caller like 'FTE%'  THEN
      IF p_stop_rec.CARRIER_EST_DEPARTURE_DATE <> FND_API.G_MISS_DATE
         OR p_stop_rec.CARRIER_EST_DEPARTURE_DATE IS NULL  THEN
          x_stop_rec.CARRIER_EST_DEPARTURE_DATE := p_stop_rec.CARRIER_EST_DEPARTURE_DATE;

      END IF;
      IF p_stop_rec.CARRIER_EST_ARRIVAL_DATE <> FND_API.G_MISS_DATE
         OR p_stop_rec.CARRIER_EST_ARRIVAL_DATE IS NULL THEN
          x_stop_rec.CARRIER_EST_ARRIVAL_DATE := p_stop_rec.CARRIER_EST_ARRIVAL_DATE;

      END IF;
    END IF;
    --


END eliminate_displayonly_fields;

/*----------------------------------------------------------
-- Procedure disable_from_list will update the record x_out_rec
-- and disables the field contained in p_disabled_list.
-----------------------------------------------------------*/

PROCEDURE disable_from_list(
  p_disabled_list IN         WSH_UTIL_CORE.column_tab_type
, p_in_rec        IN         WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, x_out_rec       IN OUT NOCOPY WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, x_return_status OUT NOCOPY        VARCHAR2
, x_field_name    OUT NOCOPY        VARCHAR2

) IS
BEGIN
  FOR i IN 1..p_disabled_list.COUNT
  LOOP
    IF p_disabled_list(i)  = 'STOP_LOCATION_CODE' THEN
      x_out_rec.STOP_LOCATION_ID := p_in_rec.STOP_LOCATION_ID ;
      x_out_rec.STOP_LOCATION_CODE := FND_API.G_MISS_CHAR ;
    ELSIF p_disabled_list(i)  = 'STOP_SEQUENCE_NUMBER' THEN
      x_out_rec.STOP_SEQUENCE_NUMBER := p_in_rec.STOP_SEQUENCE_NUMBER;
    ELSIF p_disabled_list(i)  = 'PLANNED_ARRIVAL_DATE' THEN
      x_out_rec.PLANNED_ARRIVAL_DATE := p_in_rec.PLANNED_ARRIVAL_DATE ;
    ELSIF p_disabled_list(i)  = 'PLANNED_DEPARTURE_DATE' THEN
      x_out_rec.PLANNED_DEPARTURE_DATE := p_in_rec.PLANNED_DEPARTURE_DATE ;

    --Bug 3282166
    --
    ELSIF p_disabled_list(i)  = 'CARRIER_EST_DEPARTURE_DATE' THEN
      x_out_rec.CARRIER_EST_DEPARTURE_DATE := p_in_rec.CARRIER_EST_DEPARTURE_DATE ;
    ELSIF p_disabled_list(i)  = 'CARRIER_EST_ARRIVAL_DATE' THEN
      x_out_rec.CARRIER_EST_ARRIVAL_DATE := p_in_rec.CARRIER_EST_ARRIVAL_DATE ;
    --
    ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
      x_out_rec.attribute1 := p_in_rec.attribute1 ;
      x_out_rec.attribute2 := p_in_rec.attribute2 ;
      x_out_rec.attribute3 := p_in_rec.attribute3 ;
      x_out_rec.attribute4 := p_in_rec.attribute4 ;
      x_out_rec.attribute5 := p_in_rec.attribute5 ;
      x_out_rec.attribute6 := p_in_rec.attribute6 ;
      x_out_rec.attribute7 := p_in_rec.attribute7 ;
      x_out_rec.attribute8 := p_in_rec.attribute8 ;
      x_out_rec.attribute9 := p_in_rec.attribute9 ;
      x_out_rec.attribute10 := p_in_rec.attribute10 ;
      x_out_rec.attribute11 := p_in_rec.attribute11 ;
      x_out_rec.attribute12 := p_in_rec.attribute12 ;
      x_out_rec.attribute13 := p_in_rec.attribute13 ;
      x_out_rec.attribute14 := p_in_rec.attribute14 ;
      x_out_rec.attribute15 := p_in_rec.attribute15 ;
      x_out_rec.attribute_category := p_in_rec.attribute_category ;
    ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
      x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
      x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
      x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
      x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
      x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
      x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
      x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
      x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
      x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
      x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
      x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
      x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
      x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
      x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
      x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
      x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
    ELSIF  p_disabled_list(i)  = 'FULL' THEN
      NULL;
    ELSE
      -- invalid name
      x_field_name := p_disabled_list(i);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RETURN;
      --
    END IF;
  END LOOP;
END disable_from_list;


/*
   Procedure populate_external_efl is called from
   enable_from_list to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_efl(
  p_internal        IN   NUMBER
, p_external        IN   VARCHAR2
, x_internal        IN OUT  NOCOPY NUMBER
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF x_internal IS NULL THEN
      IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
         x_internal := p_internal ;
         IF p_internal IS NULL THEN
            x_external := NULL;
         ELSE
            x_external := p_external;
         END IF;
      ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
         x_external := p_external;
         IF p_external IS NULL THEN
            x_internal := NULL;
         ELSE
            x_internal := p_internal;
         END IF;
      END IF;
   END IF;
   IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
      x_internal := p_internal ;
      IF p_internal IS NULL THEN
         x_external := NULL;
      ELSE
         x_external := p_external;
      END IF;
   ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
      x_external := p_external;
      IF p_external IS NULL THEN
         x_internal := NULL;
      ELSE
         x_internal := p_internal;
      END IF;
   END IF;

END populate_external_efl;

/*
   Procedure populate_external_efl is called from
   enable_from_list to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_efl(
  p_internal        IN   VARCHAR2
, p_external        IN   VARCHAR2
, p_mode            IN   VARCHAR2
, x_internal        IN OUT  NOCOPY VARCHAR2
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_mode = '+' THEN
      IF x_internal IS NULL THEN
         IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
            x_internal := p_internal ;
            IF p_internal IS NULL THEN
               x_external := NULL;
            ELSE
               x_external := p_external;
            END IF;
         ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
            x_external := p_external;
            IF p_external IS NULL THEN
               x_internal := NULL;
            ELSE
               x_internal := p_internal;
            END IF;
         END IF;
      END IF;
   ELSE --p_mode <> +
      IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
         x_internal := p_internal ;
         IF p_internal IS NULL THEN
            x_external := NULL;
         ELSE
            x_external := p_external;
         END IF;
      ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
         x_external := p_external;
         IF p_external IS NULL THEN
            x_internal := NULL;
         ELSE
            x_internal := p_internal;
         END IF;
      END IF;
   END IF;

END populate_external_efl;



/*----------------------------------------------------------
-- Procedure enable_from_list will update the record x_out_rec for the fields
--   included in p_disabled_list and will enable them
-----------------------------------------------------------*/

PROCEDURE enable_from_list(
  p_disabled_list IN         WSH_UTIL_CORE.column_tab_type
, p_in_rec        IN         WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, x_out_rec       IN OUT NOCOPY WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, x_return_status OUT NOCOPY        VARCHAR2
, x_field_name    OUT NOCOPY        VARCHAR2

) IS
BEGIN
  FOR i IN 2..p_disabled_list.COUNT
  LOOP
    IF p_disabled_list(i)  = 'STOP_LOCATION_CODE' THEN

      populate_external_efl(p_in_rec.STOP_LOCATION_ID,
                            p_in_rec.stop_location_code,
                            x_out_rec.STOP_LOCATION_ID,
                            x_out_rec.stop_location_code);

    ELSIF p_disabled_list(i)  = 'STOP_SEQUENCE_NUMBER' THEN
     IF p_in_rec.STOP_SEQUENCE_NUMBER <> FND_API.G_MISS_NUM
      OR p_in_rec.STOP_SEQUENCE_NUMBER IS NULL THEN
      x_out_rec.STOP_SEQUENCE_NUMBER := p_in_rec.STOP_SEQUENCE_NUMBER;
     END IF;
    ELSIF p_disabled_list(i)  = 'PLANNED_ARRIVAL_DATE' THEN
     IF p_in_rec.PLANNED_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.PLANNED_ARRIVAL_DATE IS NULL THEN
      x_out_rec.PLANNED_ARRIVAL_DATE := p_in_rec.PLANNED_ARRIVAL_DATE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'PLANNED_DEPARTURE_DATE' THEN
     IF p_in_rec.PLANNED_DEPARTURE_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.PLANNED_DEPARTURE_DATE IS NULL THEN
       x_out_rec.PLANNED_DEPARTURE_DATE := p_in_rec.PLANNED_DEPARTURE_DATE ;
     END IF;
    -- J-IB-NPARIKH-{
    ELSIF p_disabled_list(i)  = 'DEPARTURE_GROSS_WEIGHT' THEN
     IF p_in_rec.DEPARTURE_GROSS_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.DEPARTURE_GROSS_WEIGHT IS NULL THEN
         x_out_rec.DEPARTURE_GROSS_WEIGHT := p_in_rec.DEPARTURE_GROSS_WEIGHT ;
     END IF;
    ELSIF p_disabled_list(i)  = 'DEPARTURE_NET_WEIGHT' THEN
     IF p_in_rec.DEPARTURE_NET_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.DEPARTURE_NET_WEIGHT IS NULL THEN
         x_out_rec.DEPARTURE_NET_WEIGHT := p_in_rec.DEPARTURE_NET_WEIGHT ;
     END IF;
    ELSIF p_disabled_list(i)  = 'WEIGHT_UOM_CODE' THEN
     populate_external_efl(p_in_rec.WEIGHT_UOM_CODE,
                           p_in_rec.WEIGHT_UOM_DESC,
                           NULL,
                           x_out_rec.WEIGHT_UOM_CODE,
                           x_out_rec.WEIGHT_UOM_DESC);
    ELSIF p_disabled_list(i)  = 'DEPARTURE_VOLUME' THEN
     IF p_in_rec.DEPARTURE_VOLUME <> FND_API.G_MISS_NUM
      OR p_in_rec.DEPARTURE_VOLUME IS NULL THEN
         x_out_rec.DEPARTURE_VOLUME := p_in_rec.DEPARTURE_VOLUME ;
     END IF;
    ELSIF p_disabled_list(i)  = 'VOLUME_UOM_CODE' THEN
     populate_external_efl(p_in_rec.VOLUME_UOM_CODE,
                           p_in_rec.VOLUME_UOM_DESC,
                           NULL,
                           x_out_rec.VOLUME_UOM_CODE,
                           x_out_rec.VOLUME_UOM_DESC);
    -- J-IB-NPARIKH-}

    ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
     IF p_in_rec.attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute1 IS NULL THEN
      x_out_rec.attribute1 := p_in_rec.attribute1 ;
     END IF;
     IF p_in_rec.attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute2 IS NULL THEN
      x_out_rec.attribute2 := p_in_rec.attribute2 ;
     END IF;
     IF p_in_rec.attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute3 IS NULL THEN
      x_out_rec.attribute3 := p_in_rec.attribute3 ;
     END IF;
     IF p_in_rec.attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute4 IS NULL THEN
      x_out_rec.attribute4 := p_in_rec.attribute4 ;
     END IF;
     IF p_in_rec.attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute5 IS NULL THEN
      x_out_rec.attribute5 := p_in_rec.attribute5 ;
     END IF;
     IF p_in_rec.attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute6 IS NULL THEN
      x_out_rec.attribute6 := p_in_rec.attribute6 ;
     END IF;
     IF p_in_rec.attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute7 IS NULL THEN
      x_out_rec.attribute7 := p_in_rec.attribute7 ;
     END IF;
     IF p_in_rec.attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute8 IS NULL THEN
      x_out_rec.attribute8 := p_in_rec.attribute8 ;
     END IF;
     IF p_in_rec.attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute9 IS NULL THEN
      x_out_rec.attribute9 := p_in_rec.attribute9 ;
     END IF;
     IF p_in_rec.attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute10 IS NULL THEN
      x_out_rec.attribute10 := p_in_rec.attribute10 ;
     END IF;
     IF p_in_rec.attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute11 IS NULL THEN
      x_out_rec.attribute11 := p_in_rec.attribute11 ;
     END IF;
     IF p_in_rec.attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute12 IS NULL THEN
      x_out_rec.attribute12 := p_in_rec.attribute12 ;
     END IF;
     IF p_in_rec.attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute13 IS NULL THEN
      x_out_rec.attribute13 := p_in_rec.attribute13 ;
     END IF;
     IF p_in_rec.attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute14 IS NULL THEN
      x_out_rec.attribute14 := p_in_rec.attribute14 ;
     END IF;
     IF p_in_rec.attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute15 IS NULL THEN
      x_out_rec.attribute15 := p_in_rec.attribute15 ;
     END IF;
     IF p_in_rec.attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute_category IS NULL THEN
      x_out_rec.attribute_category := p_in_rec.attribute_category ;
     END IF;
    ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
     IF p_in_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute1 IS NULL THEN
      x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
     END IF;
     IF p_in_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute2 IS NULL THEN
      x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
     END IF;
     IF p_in_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute3 IS NULL THEN
      x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
     END IF;
     IF p_in_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute4 IS NULL THEN
      x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
     END IF;
     IF p_in_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute5 IS NULL THEN
      x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
     END IF;
     IF p_in_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute6 IS NULL THEN
      x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
     END IF;
     IF p_in_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute7 IS NULL THEN
      x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
     END IF;
     IF p_in_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute8 IS NULL THEN
      x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
     END IF;
     IF p_in_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute9 IS NULL THEN
      x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
     END IF;
     IF p_in_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute10 IS NULL THEN
      x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
     END IF;
     IF p_in_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute11 IS NULL THEN
      x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
     END IF;
     IF p_in_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute12 IS NULL THEN
      x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
     END IF;
     IF p_in_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute13 IS NULL THEN
      x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
     END IF;
     IF p_in_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute14 IS NULL THEN
      x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
     END IF;
     IF p_in_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute15 IS NULL THEN
      x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
     END IF;
     IF p_in_rec.tp_attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute_category IS NULL THEN
      x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
     END IF;
    --ELSIF  p_disabled_list(i)  = 'FULL'  THEN
      --NULL;
    ELSE
      -- invalid name
      x_field_name := p_disabled_list(i);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RETURN;
      --
    END IF;
  END LOOP;
END enable_from_list;

--
-- Bug 2678363 - Added p_in_rec as a parameter instead of p_action
--
PROCEDURE Get_Disabled_List  (
  p_stop_rec              IN  WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, p_parent_entity_id      IN  NUMBER
, p_in_rec		  IN  WSH_TRIP_STOPS_GRP.stopInRecType
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_stop_rec              OUT NOCOPY WSH_TRIP_STOPS_PVT.trip_stop_rec_type
)
IS
  l_disabled_list               WSH_UTIL_CORE.column_tab_type;
  l_db_col_rec                  WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_return_status               VARCHAR2(30);
  l_field_name                  VARCHAR2(100);
  l_parent_entity_id            NUMBER;
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
             'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';

  CURSOR get_trip_id(p_stop_id NUMBER) IS
  SELECT trip_id
  FROM   wsh_trip_stops
  WHERE  stop_id = p_stop_rec.STOP_ID;

  CURSOR c_tbl_rec IS
  SELECT STOP_ID
        ,TRIP_ID
        ,STOP_LOCATION_ID
        ,STATUS_CODE
        ,STOP_SEQUENCE_NUMBER
        ,PLANNED_ARRIVAL_DATE
        ,PLANNED_DEPARTURE_DATE
        ,ACTUAL_ARRIVAL_DATE
        ,ACTUAL_DEPARTURE_DATE
        ,DEPARTURE_GROSS_WEIGHT
        ,DEPARTURE_NET_WEIGHT
        ,WEIGHT_UOM_CODE
        ,DEPARTURE_VOLUME
        ,VOLUME_UOM_CODE
        ,DEPARTURE_SEAL_CODE
        ,DEPARTURE_FILL_PERCENT
        ,TP_ATTRIBUTE_CATEGORY
        ,TP_ATTRIBUTE1
        ,TP_ATTRIBUTE2
        ,TP_ATTRIBUTE3
        ,TP_ATTRIBUTE4
        ,TP_ATTRIBUTE5
        ,TP_ATTRIBUTE6
        ,TP_ATTRIBUTE7
        ,TP_ATTRIBUTE8
        ,TP_ATTRIBUTE9
        ,TP_ATTRIBUTE10
        ,TP_ATTRIBUTE11
        ,TP_ATTRIBUTE12
        ,TP_ATTRIBUTE13
        ,TP_ATTRIBUTE14
        ,TP_ATTRIBUTE15
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,CREATION_DATE
        ,CREATED_BY
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        ,REQUEST_ID
        ,WSH_LOCATION_ID
        ,TRACKING_DRILLDOWN_FLAG
        ,TRACKING_REMARKS
        ,CARRIER_EST_DEPARTURE_DATE
        ,CARRIER_EST_ARRIVAL_DATE
        ,LOADING_START_DATETIME
        ,LOADING_END_DATETIME
        ,UNLOADING_START_DATETIME
        ,UNLOADING_END_DATETIME
        ,p_stop_rec.ROWID
        ,p_stop_rec.TRIP_NAME
        ,p_stop_rec.STOP_LOCATION_CODE
        ,p_stop_rec.WEIGHT_UOM_DESC
        ,p_stop_rec.VOLUME_UOM_DESC
        ,p_stop_rec.LOCK_STOP_ID
        ,p_stop_rec.PENDING_INTERFACE_FLAG
        ,p_stop_rec.TRANSACTION_HEADER_ID
/*J inbound logistics jckwok */
        ,nvl(SHIPMENTS_TYPE_FLAG, 'O') SHIPMENTS_TYPE_FLAG
-- J: W/V Changes
        ,WV_FROZEN_FLAG
/* J TL/TP ttrichy */
        , wkend_layover_stops
        , wkday_layover_stops
        , tp_stop_id
        , physical_stop_id
        , physical_location_id
        , TMS_INTERFACE_FLAG -- OTM R12, glog proj
  FROM wsh_trip_stops
  WHERE stop_id = p_stop_rec.STOP_ID;

  e_dp_no_entity EXCEPTION;
  e_bad_field    EXCEPTION;
  e_all_disabled EXCEPTION ;
  --
  l_caller       VARCHAR2(32767);
  --
  i              NUMBER;

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
      --
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'stop_id', p_stop_rec.stop_id);
      WSH_DEBUG_SV.log(l_module_name,'p_parent_entity_id', p_parent_entity_id);
      WSH_DEBUG_SV.log(l_module_name, 'Action', p_in_rec.action_code);
      WSH_DEBUG_SV.log(l_module_name, 'Caller', p_in_rec.caller);
      --
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF p_in_rec.action_code = 'CREATE' THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
     END IF;
     --
     -- nothing else need to be disabled
     --
     eliminate_displayonly_fields (p_stop_rec,p_in_rec, x_stop_rec);
     --
     IF (p_stop_rec.trip_name <>  FND_API.G_MISS_CHAR) THEN
        x_stop_rec.trip_name := p_stop_rec.trip_name;
     END IF;
     --
     IF (p_parent_entity_id <>  FND_API.G_MISS_NUM) THEN
        x_stop_rec.trip_id := p_parent_entity_id;
     END IF;
     --
     --3509004: public api changes, commented the following code.
    /* IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
     -- */
  ELSIF p_in_rec.action_code = 'UPDATE' THEN
    --
    l_parent_entity_id := p_parent_entity_id;
    --
    IF (l_parent_entity_id IS NULL ) OR l_parent_entity_id = FND_API.G_MISS_NUM THEN
     --
     OPEN get_trip_id(p_stop_rec.stop_id);
     FETCH get_trip_id INTO l_parent_entity_id;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'trip_id',l_parent_entity_id);
     END IF;
     --
     IF (get_trip_id%NOTFOUND OR l_parent_entity_id IS NULL) THEN
         CLOSE get_trip_id;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     CLOSE get_trip_id;
      --
    END IF;
    --
    l_caller := p_in_rec.caller;
    IF (l_caller like 'FTE%' AND l_caller <> 'FTE_TMS_INTEGRATION') THEN
      l_caller := 'WSH_PUB';
    END IF;
    WSH_TRIP_STOPS_PVT.Get_Disabled_List( p_stop_rec.stop_id
                     ,l_parent_entity_id
                     , 'FORM'
                     , x_return_status
                     , l_disabled_list
                     , x_msg_count
                     , x_msg_data
		     , l_caller --3509004:public api changes
                     );
    --
    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR OR
       x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
    THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
      --
    END IF;
    --
    IF l_disabled_list.COUNT = 1 THEN
      IF l_disabled_list(1) = 'FULL' THEN
        RAISE e_all_disabled;
        --Everything  is disabled
      END IF;
    END IF;
    --
    OPEN c_tbl_rec;
    FETCH c_tbl_rec INTO x_stop_rec;
    IF c_tbl_rec%NOTFOUND THEN
       --
       CLOSE c_tbl_rec;
       RAISE e_dp_no_entity;
       --
    END IF;
    CLOSE c_tbl_rec;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'list.COUNT',l_disabled_list.COUNT);
    END IF;
    --
    IF l_disabled_list.COUNT = 0 THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
     END IF;
     --
     -- nothing else need to be disabled
     --
     eliminate_displayonly_fields (p_stop_rec,p_in_rec,x_stop_rec);

    ELSIF l_disabled_list(1) = 'FULL' THEN
      --
      IF l_disabled_list.COUNT > 1 THEN
       --
       IF l_debug_on THEN
          FOR i in 1..l_disabled_list.COUNT
          LOOP
            WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
          END LOOP;
          WSH_DEBUG_SV.log(l_module_name,'calling enable_from_list');
       END IF;
       --enable the columns matching the l_disabled_list
       enable_from_list(l_disabled_list,
                      p_stop_rec,
                      x_stop_rec,
                      l_return_status,
                      l_field_name);
       --
       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
         RAISE e_bad_field;
       END IF;
       --
      END IF;
      --
    ELSE -- list.count > 1 and list(1) <> 'FULL'
      --
      l_db_col_rec := x_stop_rec ;
      --
      IF l_debug_on THEN
        FOR i in 1..l_disabled_list.COUNT
        LOOP
          WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
        END LOOP;
        WSH_DEBUG_SV.log(l_module_name,'First element is not FULL');
        WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
      END IF;
      --
      eliminate_displayonly_fields (p_stop_rec,p_in_rec,x_stop_rec);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'calling disable_from_list');
      END IF;
      -- The fileds in the list are getting disabled
      disable_from_list(l_disabled_list,
                      l_db_col_rec,
                      x_stop_rec,
                      l_return_status,
                      l_field_name
                      );
      --
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       RAISE e_bad_field;
      END IF;
      --
    END IF;
    --
  END IF; /* if action = 'UPDATE' */
  --
  --3509004:public api changes
  --bug 3613650
  IF (nvl(p_in_rec.caller,'''') <> 'WSH_FSTRX' AND
      nvl(p_in_rec.caller,'''') NOT LIKE 'FTE%') THEN
    --
    user_non_updatable_columns
       (p_user_in_rec   => p_stop_rec,
        p_out_rec       => x_stop_rec,
        p_in_rec        => p_in_rec,
        x_return_status => l_return_status);
    --
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       x_return_status := l_return_status;
    END IF;
    --
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN e_all_disabled THEN
      -- OTM R12, glog proj, close open cursors
      IF get_trip_id%ISOPEN THEN
        CLOSE get_trip_id;
      END IF;
      IF c_tbl_rec%ISOPEN THEN
        CLOSE c_tbl_rec;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
      FND_MESSAGE.Set_Token('ENTITY_ID',p_stop_rec.stop_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        -- Nothing is updateable
        WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
      END IF;
    WHEN e_dp_no_entity THEN
      -- OTM R12, glog proj, close open cursors
      IF get_trip_id%ISOPEN THEN
        CLOSE get_trip_id;
      END IF;
      IF c_tbl_rec%ISOPEN THEN
        CLOSE c_tbl_rec;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      -- the message for this is set in original get_disabled_list
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'e_dp_no_entity');
      END IF;
    WHEN e_bad_field THEN
      -- OTM R12, glog proj, close open cursors
      IF get_trip_id%ISOPEN THEN
        CLOSE get_trip_id;
      END IF;
      IF c_tbl_rec%ISOPEN THEN
        CLOSE c_tbl_rec;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_BAD_FIELD_NAME');
      FND_MESSAGE.Set_Token('FIELD_NAME',l_field_name);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Bad field name passed to the list:'
                                                        ,l_field_name);
        WSH_DEBUG_SV.pop(l_module_name,'e_bad_field');
      END IF;

    WHEN OTHERS THEN
      -- OTM R12, glog proj, close open cursors
      IF get_trip_id%ISOPEN THEN
        CLOSE get_trip_id;
      END IF;
      IF c_tbl_rec%ISOPEN THEN
        CLOSE c_tbl_rec;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_TRIP_STOPS_VALIDATIONS.get_disabled_list', l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get_Disabled_List;




PROCEDURE Init_Stop_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_stop_actions_tab         OUT    NOCOPY           StopActionsTabType
, x_return_status            OUT    NOCOPY           VARCHAR2
)

IS
l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
         'wsh.plsql.' || G_PKG_NAME || '.' || 'Init_Stop_Actions_Tbl';
  i     number := 0;
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
      WSH_DEBUG_SV.log(l_module_name,'p_action', p_action);
  END IF;
  --
  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  -- J-IB-NPARIKH-{
  --
  -- Disable all actions on inbound stops when called from transactions form
  --
    i := i+1;
    x_stop_actions_tab(i).shipments_type_flag    := 'I';
    x_stop_actions_tab(i).caller             := 'WSH_FSTRX';
    x_stop_actions_tab(i).action_not_allowed := p_action;
  -- J-IB-NPARIKH-}
  --

  --Replaced 'ARRIVE' and 'CLOSED' with 'UPDATE-STATUS' for bug 2748983

  IF p_action IN ('PLAN','UNPLAN','UPDATE-STATUS','PICK-RELEASE',
                  'PICK-RELEASE-UI','DELETE')
  THEN
    i := i+1;
     x_stop_actions_tab(i).status_code := 'CL';
     x_stop_actions_tab(i).action_not_allowed := p_action;
/* J inbound logistics jckwok */
     IF p_action IN ('PICK-RELEASE',
                  'PICK-RELEASE-UI')
                  --removed 'UPDATE-STATUS' for    -- J-IB-NPARIKH
     THEN
         i := i + 1;
         x_stop_actions_tab(i).shipments_type_flag := 'I';
         x_stop_actions_tab(i).action_not_allowed := p_action;
     END IF;

     --HVOP heali
     IF p_action IN ('PICK-RELEASE','PICK-RELEASE-UI') THEN
         i := i + 1;
         x_stop_actions_tab(i).status_code := 'AR';
         x_stop_actions_tab(i).action_not_allowed := p_action;
     END IF;
     --HVOP heali
  --J-IB-JCKWOK
  ELSIF p_action IN ('ASSIGN-FREIGHT-COSTS','PRINT-DOC-SETS','RESOLVE-EXCEPTIONS-UI') THEN
         i := i + 1;
         x_stop_actions_tab(i).action_not_allowed := p_action;
         x_stop_actions_tab(i).shipments_type_flag := 'I';
  --J-IB-JCKWOK
  -- J-IB-NPARIKH-{
  ELSIF p_action = 'WT-VOL'
  THEN
    --
    -- Calculate weight/volume action is
    --  - always allowed for inbound stop
    --  - not allowed for outbound stop, once closed.
    --  - not allowed for mixed closed stop, if called from transactions form
    --
    i := i + 1;
    x_stop_actions_tab(i).action_not_allowed := p_action;
    x_stop_actions_tab(i).shipments_type_flag := 'O';   -- J-IB-NPARIKH
    x_stop_actions_tab(i).status_code := 'CL';
    i := i + 1;
    x_stop_actions_tab(i).action_not_allowed := p_action;
    x_stop_actions_tab(i).shipments_type_flag := 'M';
    x_stop_actions_tab(i).caller := 'WSH_FSTRX';
    x_stop_actions_tab(i).status_code := 'CL';
  END IF;
  -- J-IB-NPARIKH-}

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_TRIP_STOPS_VALIDATIONS.get_disabled_list', l_module_name);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Init_Stop_Actions_Tbl;

-- J-IB-NPARIKH-{
--
--========================================================================
-- PROCEDURE : refreshShipmentsTypeFlag
--
-- PARAMETERS: p_trip_id               Trip ID (Required)
--             p_stop_id               Stop ID (Required)
--             p_action                ASSIGN/UNASSIGN
--             p_shipment_direction    Direction of delivery being assigned/unassigned
--             x_shipments_type_flag   Shipments type flag for stop
--             x_return_status         Return status of API
--
-- ASSUMPTION: Caller passes x_shipments_type_flag with database(current) value
--             of the flag for trip stop.
--
-- PRE-REQ   : This procedure should be called BEFORE performing the ASSIGNment operation.
--             This procedure should be called AFTER performing the UNASSIGNment operation.
--
-- COMMENT   : This function re-calculates value of shipments type flag for the
--             trip stop as a result of a delivery being assigned/unassigned.
--
--             For action ASSIGN
--               - If current value of shipments type flag is I
--                   - If delivery being assigned is outbound (O/IO)
--                       - Check if stop has any inbound delivery
--                           - If yes, set x_shipments_type_flag to M
--                           - If no, set x_shipments_type_flag to O
--                   - If delivery being assigned is inbound (not O/IO)
--                       - re-calculation is not required. Return
--
--               - If current value of shipments type flag is O
--                   - If delivery being assigned is inbound (not O/IO)
--                       - Check if stop has any outbound delivery
--                           - If yes, set x_shipments_type_flag to M
--                           - If no, set x_shipments_type_flag to I
--                   - If delivery being assigned is outbound (O/IO)
--                       - re-calculation is not required. Return
--
--               - If current value of shipments type flag is M
--                       - re-calculation is not required. Return
--
--             For action UNASSIGN
--               - If current value of shipments type flag is M
--                   - If delivery being unassigned is outbound (O/IO)
--                       - Check if stop has any outbound delivery
--                           - If no, set x_shipments_type_flag to I
--                           - If yes, re-calculation is not required. Return
--                   - If delivery being assigned is inbound (not O/IO)
--                       - Check if stop has any inbound delivery
--                           - If no, set x_shipments_type_flag to O
--                           - If yes, re-calculation is not required. Return
--
--               - If current value of shipments type flag is O/I
--                       - re-calculation is not required. Return
--
--========================================================================
--
PROCEDURE refreshShipmentsTypeFlag
    (
      p_trip_id              IN            NUMBER,
      p_stop_id              IN            NUMBER,
      p_action               IN            VARCHAR2 DEFAULT 'ASSIGN',
      p_shipment_direction   IN            VARCHAR2 DEFAULT 'O' ,
      x_shipments_type_flag  IN OUT NOCOPY VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2
    )
IS
--{
    --
    l_debug_on BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'refreshShipmentsTypeFlag';
--}
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'p_trip_id',p_trip_id);
        WSH_DEBUG_SV.log(l_module_name,'p_stop_id',p_stop_id);
        WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
        WSH_DEBUG_SV.log(l_module_name,'p_shipment_direction',p_shipment_direction);
        WSH_DEBUG_SV.log(l_module_name,'x_shipments_type_flag',x_shipments_type_flag);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF p_trip_id IS NULL
    THEN
    --{
          --
          -- Trip ID is a required parameter. Raise error.
          --
          FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_trip_id');
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    IF p_stop_id IS NULL
    THEN
    --{
          --
          -- Stop ID is a required parameter. Raise error.
          --
          FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
          FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_stop_id');
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF p_action = 'ASSIGN'
    THEN
    --{
        IF NVL(x_shipments_type_flag,'O') = 'I'
        THEN
        --{
            IF NVL(p_shipment_direction,'O') IN ('O','IO')
            THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_inbound_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF
                    WSH_TRIP_VALIDATIONS.has_inbound_deliveries
                        (
                          p_trip_id => p_trip_id,
                          p_stop_id => p_stop_id
                        )
                    = 'Y'
                THEN
                    x_shipments_type_flag := 'M';
                ELSE
                    x_shipments_type_flag := 'O';
                END IF;
            --}
            END IF;
        --}
        ELSIF NVL(x_shipments_type_flag,'O') = 'O'
        THEN
        --{
            IF NVL(p_shipment_direction,'O') NOT IN ('O','IO')
            THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_outbound_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF
                    WSH_TRIP_VALIDATIONS.has_outbound_deliveries
                        (
                          p_trip_id => p_trip_id,
                          p_stop_id => p_stop_id
                        )
                    = 'Y'
                THEN
                    x_shipments_type_flag := 'M';
                ELSE
                    x_shipments_type_flag := 'I';
                END IF;
            --}
            END IF;
        --}
        END IF;
    --}
    ELSIF p_action = 'UNASSIGN'
    THEN
    --{
        IF NVL(x_shipments_type_flag,'O') = 'M'
        THEN
        --{
            IF NVL(p_shipment_direction,'O') IN ('O','IO')
            THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_outbound_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF
                    WSH_TRIP_VALIDATIONS.has_outbound_deliveries
                        (
                          p_trip_id => p_trip_id,
                          p_stop_id => p_stop_id
                        )
                    = 'Y'
                THEN
                    x_shipments_type_flag := 'M';
                ELSE
                    x_shipments_type_flag := 'I';
                END IF;
            --}
            ELSE
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_inbound_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF
                    WSH_TRIP_VALIDATIONS.has_inbound_deliveries
                        (
                          p_trip_id => p_trip_id,
                          p_stop_id => p_stop_id
                        )
                    = 'Y'
                THEN
                    x_shipments_type_flag := 'M';
                ELSE
                    x_shipments_type_flag := 'O';
                END IF;
            --}
            END IF;
        --}
        END IF;
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_shipments_type_flag',x_shipments_type_flag);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
--{
      --
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
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
--}
END refreshShipmentsTypeFlag;
--
--
--
--========================================================================
-- PROCEDURE : Check_Stop_Close
--
-- PARAMETERS: p_in_rec                Input Record  (Refer to WSHSTVLS.pls for description)
--             p_out_rec               Output record (Refer to WSHSTVLS.pls for description)
--             x_return_status         Return status of API
--
--
-- COMMENT   : This function checks if stop can be closed or not.
--             Result is indicated via out parameter p_out_rec.close_allowed
--
--             When FTE or Inbound caller wants to close the physical stop, we will
--             perform validation on both linked dummy and physical stops, in which
--             case, both stops are treated as one virtual stop.
--
--             In below steps, linked internal stops are included(+).
--
--             It performs following steps:
--             01. To determine, if stop can be closed,
--                 01.01. It checks status of all prior stops on same trip.(+)
--                 01.02. It checks status of deliveries being picked up/droppped of at the stop.(+)
--                 01.03. It checks status of all prior legs for the deliveries.(+)
--             02. Validate stop close date as per shipping parameter "Allow future date"
--             03. Validate stop close date against inventory open periods
--             04. Check if deliveries (Starting from this stop) can be set to in-transit.
--                    (Internal stops cannot be used as pick up.)
--             05. Check if deliveries (Ending at this stop) can be closed.(+)
--             06. Check if trip can be set to in-transit or closed.
--
--========================================================================
--
PROCEDURE Check_Stop_Close -----trvlb
            (
              p_in_rec                   IN          chkClose_in_rec_type,
              x_out_rec                  OUT NOCOPY  chkClose_out_rec_type,
              x_return_status            OUT NOCOPY  VARCHAR2
            )
IS
--{

    l_dummy NUMBER;
    --
    -- Get trip and stop information
    --
    CURSOR stop_info_csr (p_stop_id IN NUMBER) IS
    SELECT stop_sequence_number,
           wts.status_code,
           wts.trip_id,
           nvl(wts.shipments_type_flag,'O') shipments_Type_flag,
           stop_location_id,
           wt.ship_method_code,
           wt.carrier_id,
           wt.mode_of_transport,
           wt.service_level,
           wt.status_code trip_status_code,
           wt.seal_code trip_seal_Code,
           wt.name trip_name,
           -- J: W/V Changes
           wts.departure_gross_weight,
           wts.departure_volume,
           wts.physical_location_id
    FROM   wsh_trip_stops wts,
           wsh_trips wt
    WHERE  stop_id     = p_stop_id
    AND    wts.trip_id = wt.trip_id;
    --
    --
    l_stop_info_rec stop_info_csr%ROWTYPE;
    --
    --
    -- Get linked internal stop information
    -- If the linked stop is already closed,
    -- we do not need to validate it anymore.
    -- If the caller passes the dummy stop, we will not use the physical
    -- stop.
    --    Linked internal stop can be closed separately;
    --    if it is already closed, we do not need to validate it.
    --
    -- FTE is expected to pass only the physical stop,
    -- and Inbound can pass either dummy stop (corner-case) or physical stop (typical).
    --
    CURSOR linked_stop_info_csr (p_stop_id IN NUMBER,
                                 p_trip_id IN NUMBER) IS
    SELECT wts.stop_id,
           wts.stop_sequence_number,
           wts.status_code,
           nvl(wts.shipments_type_flag,'O') shipments_Type_flag,
           wts.stop_location_id,
           wts.departure_gross_weight,
           wts.departure_volume
    FROM   wsh_trip_stops wts
    WHERE  wts.physical_stop_id     = p_stop_id
    AND    wts.trip_id              = p_trip_id
    AND    wts.status_code IN ('OP', 'AR');
    --
    --
    -- Get linked internal inbound stop for normal WSH callers
    -- because the linked dummy stop is not shown in
    -- FTE workbenches and the inbound stop is not visible
    -- to WSH.
    --  This resolves an issue with the case of
    --  drop-ship to internal location, along with
    --  inbound and outbound deliveries to the same physical
    --  location.
    --  We need to ensure that if the physical stop
    --  gets closed from WSH side, the linked inbound stop
    --  will get Closed.
    CURSOR wsh_linked_stop_csr (p_stop_id IN NUMBER,
                                p_trip_id IN NUMBER) IS
    SELECT wts.stop_id,
           wts.stop_sequence_number,
           wts.status_code,
           wts.shipments_type_flag shipments_Type_flag,
           wts.stop_location_id,
           wts.departure_gross_weight,
           wts.departure_volume
    FROM   wsh_trip_stops wts
    WHERE  wts.physical_stop_id     = p_stop_id
    AND    wts.trip_id              = p_trip_id
    AND    wts.status_code IN ('OP', 'AR')
    AND    wts.shipments_type_flag = 'I';
    --
    --
    l_linked_stop_info_rec linked_stop_info_csr%ROWTYPE;
    --
    -- in case of -99 it will be equal
    --
    --
    -- Get all previous stop on the same trip which are not closed.
    -- Ignore the linked internal stop if specified.
    --   If not specified, its value will be -1 which should not be matched.
    --
    CURSOR prev_stop_csr
            (
              p_trip_id IN NUMBER,
              p_linked_stop_id IN NUMBER,
              p_stop_sequence IN NUMBER
            )
     IS
     SELECT nvl(shipments_type_flag,'O') shipments_Type_flag,
            stop_location_id
       FROM wsh_trip_stops
      WHERE trip_id              = p_trip_id
        AND status_code         IN ('OP','AR')
        AND stop_sequence_number < p_stop_sequence
        AND stop_id <> NVL(p_linked_stop_id, -1)
        order by stop_sequence_number;
        --AND rownum = 1;
    --
    --
    -- Get all open deliveries being picked up at the current stop,
    -- sorted by outbound first then inbound.
    --    linked internal stop is not included because it cannot be
    --    used as pick up.
    --
    CURSOR open_pickup_dlvy_csr (p_stop_id NUMBER) IS
    SELECT nvl(shipment_direction,'O') shipment_direction
    FROM   wsh_new_deliveries wnd,
           wsh_delivery_legs  wdl
    WHERE  wdl.pick_up_stop_id = p_stop_id
    AND    wnd.delivery_id     = wdl.delivery_id
    AND    wnd.status_code    IN ('OP', 'PA')
    ORDER BY DECODE( NVL(wnd.shipment_direction,'O'), 'O', 1, 'IO', 1, 'I', 2, 'D', 2, 2 );
    --AND    rownum              = 1;
    --
    --
    --
    -- Get deliveries being dropped off at the current stop
    --    and its linked dummy stop,
    -- sorted by outbound first then inbound.
    -- based on shipment direction, their status must be:
    --       * outbound/internal outbound: open or confirmed.
    --       * inbound, etc.: open or in-transit
    --
    CURSOR open_dropoff_dlvy_csr (p_stop_id NUMBER, p_stop_location_id NUMBER,
                                  p_dummy_stop_id NUMBER, p_dummy_location_id NUMBER) IS
    SELECT NVL(wnd.shipment_direction,'O') shipment_direction,
           wnd.ultimate_dropoff_location_id,
           wnd.status_code,
           DECODE(wnd.ultimate_dropoff_location_id,p_stop_location_id,1,
                  (DECODE(wnd.ultimate_dropoff_location_id,p_dummy_location_id,1, 2))
                 ) last_stop,
           wdl.drop_off_stop_id   drop_off_stop_id
    FROM   wsh_new_deliveries wnd,
           wsh_delivery_legs  wdl
    WHERE  wdl.drop_off_stop_id IN (p_stop_id, p_dummy_stop_id)
    AND    wnd.delivery_id      = wdl.delivery_id
    AND    (
              (
                    NVL(wnd.shipment_direction,'O') IN ('O','IO')
                AND wnd.status_code    IN ('OP', 'PA', 'CO' )
              )
              OR
              (
                    NVL(wnd.shipment_direction,'O') NOT IN ('O','IO')
                AND wnd.status_code    IN ('OP', 'IT' )
              )
           )
    ORDER BY DECODE( NVL(wnd.shipment_direction,'O'), 'O', 1, 'IO', 1, 'I', 2, 'D', 2, 2 ) ASC, wnd.status_code DESC, last_stop ASC;
    --AND    rownum              = 1;
    --
    --
    -- Get previous leg for delivery (or all deliveries if p_delivery_id is null)
    -- being picked up at the current stop (indicated by p_stop_id)
    --
    --   Linked internal stop is not included because it cannot have pick-ups.
    --
    -- results sorted by outbound first then inbound.
    --
    CURSOR prev_leg_csr (p_stop_id IN NUMBER, p_delivery_id IN NUMBER) IS
    SELECT prev_leg_do_stop.status_code                  do_stop_status_code,
           NVL(prev_leg_do_stop.shipments_type_flag,'O') do_stop_shipments_type_flag,
           prev_leg_do_stop.stop_location_id             do_stop_locationId,
           prev_leg_do_stop.stop_id                      do_stop_id,
           prev_leg_do_stop.stop_sequence_number         do_stop_sequence_number,
           prev_leg_pu_stop.status_code                  pu_stop_status_code,
           NVL(prev_leg_pu_stop.shipments_type_flag,'O') pu_stop_shipments_type_flag,
           prev_leg_pu_stop.stop_location_id             pu_stop_locationId,
           prev_leg_pu_stop.stop_id                      pu_stop_id,
           NVL(wnd.shipment_direction,'O')               shipment_direction,
           wnd.status_code                               dlvy_status_code,
           wnd.delivery_id                               delivery_id,
           wnd.initial_pickup_location_id                dlvy_initialPULocationId,
           wnd.name                                      dlvy_name,
           DECODE(prev_leg_do_stop.status_code,'OP','OP','XX') do_stop_status_code_ord,
           DECODE(prev_leg_pu_stop.status_code,'OP','OP','XX') pu_stop_status_code_ord,
           prev_leg_do_stop.trip_id                       prev_leg_trip_id,
           wt.name                                        prev_leg_trip_name
    FROM   wsh_trip_stops prev_leg_do_stop,
           wsh_trip_stops prev_leg_pu_stop,
           wsh_trip_stops curr_leg_pu_stop,
           wsh_delivery_legs prev_leg,
           wsh_delivery_legs curr_leg,
           wsh_new_deliveries wnd,
           wsh_trips wt
    WHERE  prev_leg.drop_off_stop_id         = prev_leg_do_stop.stop_id
    --AND    st1.status_code = 'OP'
    AND    prev_leg.pick_up_stop_id          = prev_leg_pu_stop.stop_id
    AND    prev_leg_do_stop.stop_location_id = curr_leg_pu_stop.stop_location_id
    AND    prev_leg_do_stop.trip_id          = wt.trip_id
    AND    prev_leg.delivery_id              = curr_leg.delivery_id
    AND    curr_leg_pu_stop.stop_id          = p_stop_id
    AND    curr_leg.pick_up_stop_id          = p_stop_id
    AND    wnd.delivery_id                   = curr_leg.delivery_id
    AND    (
             p_delivery_id IS NULL
             OR
             wnd.delivery_id = p_delivery_id
           )
    ORDER BY DECODE( NVL(wnd.shipment_direction,'O'), 'O', 1, 'IO', 1, 'I', 2, 'D', 2, 2 ), do_stop_status_code_ord, pu_stop_status_code_ord, wnd.delivery_id;
    --AND    rownum = 1;
    --
    --
    --
    -- Get previous leg for delivery (or all deliveries if p_delivery_id is null)
    -- being picked up at the current stop (indicated by p_stop_id)
    --
    --   Linked internal stop is not included because it cannot have pick-ups.
    --
    -- results sorted by outbound first then inbound.
    --
    -- This is same as prev_leg_csr but copied once again
        -- as we need to open this cursor in nested fashion.
        -- (I know this is not very good coding practice
        -- but it is a compromise considering the time constraints
        -- need to fix this in next release)
    --
    CURSOR prev_leg_csr1 (p_stop_id IN NUMBER, p_delivery_id IN NUMBER) IS
    SELECT prev_leg_do_stop.status_code                  do_stop_status_code,
           NVL(prev_leg_do_stop.shipments_type_flag,'O') do_stop_shipments_type_flag,
           prev_leg_do_stop.stop_location_id             do_stop_locationId,
           prev_leg_do_stop.stop_id                      do_stop_id,
           prev_leg_do_stop.stop_sequence_number         do_stop_sequence_number,
           prev_leg_pu_stop.status_code                  pu_stop_status_code,
           NVL(prev_leg_pu_stop.shipments_type_flag,'O') pu_stop_shipments_type_flag,
           prev_leg_pu_stop.stop_location_id             pu_stop_locationId,
           prev_leg_pu_stop.stop_id                      pu_stop_id,
           NVL(wnd.shipment_direction,'O')               shipment_direction,
           wnd.status_code                               dlvy_status_code,
           wnd.delivery_id                               delivery_id,
           wnd.initial_pickup_location_id                dlvy_initialPULocationId,
           wnd.name                                      dlvy_name,
           DECODE(prev_leg_do_stop.status_code,'OP','OP','XX') do_stop_status_code_ord,
           DECODE(prev_leg_pu_stop.status_code,'OP','OP','XX') pu_stop_status_code_ord,
           prev_leg_do_stop.trip_id                       prev_leg_trip_id,
           wt.name                                        prev_leg_trip_name
    FROM   wsh_trip_stops prev_leg_do_stop,
           wsh_trip_stops prev_leg_pu_stop,
           wsh_trip_stops curr_leg_pu_stop,
           wsh_delivery_legs prev_leg,
           wsh_delivery_legs curr_leg,
           wsh_new_deliveries wnd,
           wsh_trips wt
    WHERE  prev_leg.drop_off_stop_id         = prev_leg_do_stop.stop_id
    --AND    st1.status_code = 'OP'
    AND    prev_leg.pick_up_stop_id          = prev_leg_pu_stop.stop_id
    AND    prev_leg_do_stop.stop_location_id = curr_leg_pu_stop.stop_location_id
    AND    prev_leg_do_stop.trip_id          = wt.trip_id
    AND    prev_leg.delivery_id              = curr_leg.delivery_id
    AND    curr_leg_pu_stop.stop_id          = p_stop_id
    AND    curr_leg.pick_up_stop_id          = p_stop_id
    AND    wnd.delivery_id                   = curr_leg.delivery_id
    AND    (
             p_delivery_id IS NULL
             OR
             wnd.delivery_id = p_delivery_id
           )
    ORDER BY DECODE( NVL(wnd.shipment_direction,'O'), 'O', 1, 'IO', 1, 'I', 2, 'D', 2, 2 ), do_stop_status_code_ord, pu_stop_status_code_ord, wnd.delivery_id;
    --AND    rownum = 1;
    --
    --
    --
    -- Get pickup stop information for an inbound  delivery, given its drop-off stop.
    --    drop-off stop can be physical or linked internal.
    -- Pick up stops must be closed.
    --
    CURSOR ib_pickup_csr (p_stop_id IN NUMBER,
                          p_linked_stop_id IN NUMBER) IS
    SELECT NVL(st1.shipments_type_flag,'O') pu_shipments_type_flag,
           st1.status_code pu_stop_statusCode,
           st1.stop_location_id pu_stop_locationId,
           st1.stop_id          pu_stop_id,
           wnd.delivery_id      delivery_id,
           wnd.status_code delivery_statusCode,
           wnd.initial_pickup_location_id dlvy_initialPULocationId
    FROM   wsh_trip_stops st1,
           wsh_delivery_legs dl2,
           wsh_new_deliveries wnd
    WHERE  dl2.pick_up_stop_id                  = st1.stop_id
    AND    st1.status_code                      = 'CL'
    AND    dl2.drop_off_stop_id   IN (p_stop_id, p_linked_stop_id)
    AND    wnd.delivery_id                      = dl2.delivery_id
    AND    nvl(wnd.shipment_direction,'O') NOT IN ('O','IO');
    --
    --
    -- Get all deliveries which start(initial pickup location) at current stop,
    -- sorted by organization id
    --     linked internal stop is not included because it cannot have pick-ups.
    --
    CURSOR initial_pu_dlvy_csr (p_stop_id NUMBER) IS
    SELECT dl.delivery_id,
           dl.organization_id,
	   DECODE(NVL(dl.shipment_direction,'O'), 'IO', dl.ultimate_dropoff_location_id, NULL) io_location_id,
           dl.name,
           dl.status_code
    FROM   wsh_new_deliveries dl,
           wsh_delivery_legs dg,
           wsh_trip_stops st
    WHERE  dg.delivery_id      = dl.delivery_id
    AND    st.stop_location_id = dl.initial_pickup_location_id
    AND    st.stop_id          = dg.pick_up_stop_id
    AND    st.stop_id          = p_stop_id
    AND    NVL(dl.shipment_direction,'O')  IN ('O','IO')
    ORDER BY organization_id;
    --AND    rownum              = 1;
    --
    --
    -- Get all deliveries which end(ultimate dropoff location) at current stop
    -- or its linked internal stop,
    -- sorted by organization id
    --
    CURSOR ultimate_do_dlvy_csr (p_stop_id NUMBER,
                                 p_dummy_stop_id NUMBER) IS
    SELECT dl.delivery_id,
           dl.organization_id,
           dl.name,
           dl.status_code,
           dg.drop_off_stop_id
    FROM   wsh_new_deliveries dl,
           wsh_delivery_legs dg,
           wsh_trip_stops st
    WHERE  dg.delivery_id      = dl.delivery_id
    AND    st.stop_location_id = dl.ultimate_dropoff_location_id
    AND    st.stop_id          = dg.drop_off_stop_id
    AND    st.stop_id          IN (p_stop_id, p_dummy_stop_id)
    AND    NVL(dl.shipment_direction,'O')  IN ('O','IO')
    AND    dl.status_code      = 'IT'
    ORDER BY organization_id;
    --AND    rownum              = 1;
    --
    --
       -- Need to get receiving organization_id and destination type code for location
    CURSOR get_org_id (c_delivery_id NUMBER) IS
    SELECT pl.destination_organization_id, pl.destination_type_code
    FROM   wsh_delivery_assignments wda, wsh_delivery_details wdd,
           oe_order_lines_all oel, po_requisition_lines_all pl
    WHERE  wda.delivery_id = c_delivery_id
    AND    wda.delivery_detail_id = wdd.delivery_detail_id
    AND    wdd.source_document_type_id = 10
    AND    wdd.source_line_id = oel.line_id
    AND    wdd.source_code = 'OE'
    AND    pl.requisition_line_id = oel.source_document_line_id
    AND    pl.destination_organization_id <> pl.source_organization_id;

    -- Need to get intransit type from Shipping Networks
    CURSOR c_mtl_interorg_parameters (c_from_organization_id NUMBER, c_to_organization_id NUMBER) IS
    SELECT intransit_type
    FROM   mtl_interorg_parameters
    WHERE  from_organization_id = c_from_organization_id
    AND    to_organization_id = c_to_organization_id;

    l_prev_dropoff_location_id  NUMBER;
    l_rec_organization_id       NUMBER;
    l_dest_type_code            VARCHAR2(30);
    l_intransit_type            NUMBER;
    l_validate_rec_org          BOOLEAN;
    l_org_name                  VARCHAR2(240);
    l_err_dlvy_cnt          NUMBER;
    l_dlvy_cnt              NUMBER;
    l_prev_org_dlvy_cnt     NUMBER;
    l_prev_org_id           NUMBER;
    l_stop_warnings         NUMBER;
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_return_status         VARCHAR2(30);
    l_stop_name             VARCHAR2(60);
    l_prev_stop_name        VARCHAR2(60);
    l_message_name          VARCHAR2(100);
    l_allowed               VARCHAR2(10);
    --

    l_param_info            WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
    -- Bug 3346237 : Parameters Enforce Ship Method and Allow future ship date
    --               should use values present in Global Parameters table.
    l_global_info      WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

    l_itm_mark_dels         wsh_util_core.id_tab_type;
    l_exceptions_tab        wsh_delivery_validations.exception_rec_tab_type;
    l_exceptions_exist      VARCHAR2(1);
    l_period_id             NUMBER;
    l_open_past_period      BOOLEAN;
    l_stop_Id               NUMBER;
    l_stop_locationId       NUMBER;
    l_dlvy_initialPULocationId NUMBER;
    --
    l_in_rec                WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type;
    l_trip_in_rec           WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type;
    l_wv_check_done         BOOLEAN;

    -- Exception variables
    l_exceptions_tbl  wsh_xc_util.XC_TAB_TYPE;
    l_exp_logged      BOOLEAN := FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    --
    l_location_id NUMBER;

    --
    l_virtual_shipments_type_flag  WSH_TRIP_STOPS.SHIPMENTS_TYPE_FLAG%TYPE;

-- Following three variables are added for BufFix #3947506
    l_out_entity_id     VARCHAR2(100);
    l_out_entity_name   VARCHAR2(100);
    l_out_status        VARCHAR2(1);

    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_STOP_CLOSE';

--}
BEGIN
--{
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
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.STOP_ID',P_in_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.put_messages',P_in_rec.put_messages);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.caller',P_in_rec.caller);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.actual_date',P_in_rec.actual_date);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_stop_warnings := 0;
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    x_out_rec.initial_pu_dlvy_recTbl.id_tbl.DELETE;
    x_out_rec.initial_pu_dlvy_recTbl.name_tbl.DELETE;
    x_out_rec.initial_pu_dlvy_recTbl.statusCode_tbl.DELETE;
    x_out_rec.initial_pu_dlvy_recTbl.orgId_tbl.DELETE;
    --
    x_out_rec.ultimate_do_dlvy_recTbl.id_tbl.DELETE;
    x_out_rec.ultimate_do_dlvy_recTbl.name_tbl.DELETE;
    x_out_rec.ultimate_do_dlvy_recTbl.statusCode_tbl.DELETE;
    x_out_rec.ultimate_do_dlvy_recTbl.orgId_tbl.DELETE;
    --
    x_out_rec.initial_pu_err_dlvy_id_tbl.DELETE;
    --
    --
    -- Get Stop  Info
    --
    OPEN stop_info_csr (p_in_rec.stop_id);
    FETCH stop_info_csr INTO l_stop_info_rec;
    --
    IF stop_info_csr%NOTFOUND
    THEN
    --{
      --CLOSE stop_info_csr;
      FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('STOP_ID',p_in_rec.stop_id);
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    CLOSE stop_info_csr;
    --
    --
    l_virtual_shipments_type_flag := l_stop_info_rec.shipments_type_flag;
    --
    --
    -- we check for FTE because only FTE user can close both linked stops.
    -- we check for INBOUND because only Inbound user can close both linked stops.
    -- WSH users must close one stop at a time in the proper sequence
    -- on the same trip.
    --
    -- If caller passes the dummy stop, we will not look up the physical stop.
    --
    IF (p_in_rec.caller LIKE 'FTE%'
        OR p_in_rec.caller LIKE 'WSH_IB%' -- Inbound Changes 10+ Internal Locations
        )  THEN
      OPEN linked_stop_info_csr(p_in_rec.stop_id,
                                l_stop_info_rec.trip_id);
      FETCH linked_stop_info_csr INTO l_linked_stop_info_rec;
      IF linked_stop_info_csr%NOTFOUND THEN
         -- use -1 or 'x' instead of NULL to avoid need for NVL in SQLs and conditions.
         l_linked_stop_info_rec.stop_id          := -1;
         l_linked_stop_info_rec.stop_location_id := -1;
         l_linked_stop_info_rec.shipments_type_flag := 'x';
         x_out_rec.linked_stop_id := NULL;
      ELSE
         x_out_rec.linked_stop_id := l_linked_stop_info_rec.stop_id;

         --
         -- In this API, if the stops are linked and both are not closed, they
         -- represent a virtual stop and we need to determine its shipments type.
         --
         --       linked dummy stop (OP, AR)    physical stop         virtual stop
         --       shipments type flag           shipments type flag   shipments type flag
         --       -------------------------     --------------------  -------------------
         --             O                               O                     O
         --             I                               I                     I
         --             O                               I                     M
         --             I                               O                     M
         --             M                               *                     M
         --             *                               M                     M
         --
         -- If there is no non-closed linked dummy stop, the virtual flag will have the
         -- main stop's flag value.

	 IF     l_virtual_shipments_type_flag <> 'M'
            AND l_stop_info_rec.shipments_type_flag <> l_linked_stop_info_rec.shipments_type_flag THEN
           l_virtual_shipments_type_flag := 'M';
         END IF;

      END IF;
      CLOSE linked_stop_info_csr;
    ELSE
      -- normal WSH cases need to close linked inbound internal stop;
      -- if the linked stop is outbound or mixed, it is visible to WSH
      -- and should normally be closed first.
      OPEN wsh_linked_stop_csr(p_in_rec.stop_id,
                               l_stop_info_rec.trip_id);
      FETCH wsh_linked_stop_csr INTO l_linked_stop_info_rec;
      IF wsh_linked_stop_csr%NOTFOUND THEN
        -- use -1 or 'x' instead of NULL to avoid need for NVL in SQLs and conditions.
        l_linked_stop_info_rec.stop_id          := -1;
        l_linked_stop_info_rec.stop_location_id := -1;
        x_out_rec.linked_stop_id := NULL;
      ELSE
        -- this case is always Mixed.
        x_out_rec.linked_stop_id := l_linked_stop_info_rec.stop_id;
        l_virtual_shipments_type_flag := 'M';
      END IF;
      CLOSE wsh_linked_stop_csr;
    END IF;
    --
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_linked_stop_info_rec.stop_id',l_linked_stop_info_rec.stop_id);
       WSH_DEBUG_SV.log(l_module_name,'l_linked_stop_info_rec.stop_location_id',l_linked_stop_info_rec.stop_location_id);
    END IF;

    IF (p_in_rec.caller LIKE 'FTE%'
        OR p_in_rec.caller LIKE 'WSH_IB%')
       AND l_stop_info_rec.physical_location_id IS NOT NULL THEN
      l_location_id := l_stop_info_rec.physical_location_id;
    ELSE
      l_location_id := l_stop_info_rec.stop_location_id;
    END IF;

        l_stop_name := SUBSTRB(
                                WSH_UTIL_CORE.get_location_description
                                  (
                                    l_location_id,
                                    'NEW UI CODE'
                                  ),
                                1,
                                60
                              );
    --
    x_out_rec.stop_name              := l_stop_name;
    x_out_rec.stop_Sequence_number   := l_stop_info_rec.stop_Sequence_number;
    x_out_rec.trip_id                := l_stop_info_rec.trip_id;
    x_out_rec.ship_method_code       := l_stop_info_rec.ship_method_code;
    x_out_rec.carrier_id             := l_stop_info_rec.carrier_id;
    x_out_rec.mode_of_transport      := l_stop_info_rec.mode_of_transport;
    x_out_rec.service_level          := l_stop_info_rec.service_level;
    x_out_rec.trip_Status_code       := l_stop_info_Rec.trip_Status_Code;
    x_out_rec.trip_new_Status_code   := l_stop_info_Rec.trip_Status_Code;
    x_out_rec.trip_seal_code         := l_stop_info_rec.trip_seal_code;
    x_out_rec.trip_name              := l_stop_info_rec.trip_name;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_stop_info_rec.stop_Sequence_number',l_stop_info_rec.stop_Sequence_number);
       WSH_DEBUG_SV.log(l_module_name,'l_stop_info_rec.trip_id',l_stop_info_rec.trip_id);
       WSH_DEBUG_SV.log(l_module_name,'l_stop_info_Rec.trip_Status_Code',l_stop_info_Rec.trip_Status_Code);
       WSH_DEBUG_SV.log(l_module_name,'l_stop_info_Rec.shipments_Type_flag',l_stop_info_Rec.shipments_Type_flag);
       WSH_DEBUG_SV.log(l_module_name,'l_linked_stop_info_Rec.shipments_Type_flag',l_linked_stop_info_Rec.shipments_Type_flag);
       WSH_DEBUG_SV.log(l_module_name,'l_virtual_shipments_Type_flag',l_virtual_shipments_Type_flag);
    END IF;
    --

    -- Check for Exceptions against Trip Stop and its Contents
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
    l_exceptions_tbl.delete;
    l_exp_logged      := FALSE;
    WSH_XC_UTIL.Check_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_in_rec.stop_id,
                                     p_logging_entity_name   => 'STOP',
                                     p_consider_content      => 'Y',
                                     x_exceptions_tab        => l_exceptions_tbl,
--tkt
                                     p_caller                => p_in_rec.caller
                                   );
    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR exp_cnt in 1..l_exceptions_tbl.COUNT LOOP
         IF l_exceptions_tbl(exp_cnt).exception_behavior = 'ERROR' THEN
            IF l_exceptions_tbl(exp_cnt).entity_name = 'STOP' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
            ELSE
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
            END IF;

            -- BugFix #3947506
            WSH_UTIL_CORE.Get_Entity_Name
                ( l_exceptions_tbl(exp_cnt).entity_id,
                  l_exceptions_tbl(exp_cnt).entity_name,
                  l_out_entity_id,
                  l_out_entity_name,
                  l_out_status);

            IF ( l_out_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
                 wsh_util_core.add_message(l_out_status);
                 RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- End of code BugFix #3947506

            FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_out_entity_name); -- BugFix #3947506
            FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_out_entity_id); -- BugFix #3947506
            FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Error');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            l_stop_warnings := l_stop_warnings + 1;
            RAISE wsh_util_core.e_not_allowed;
         ELSIF l_exceptions_tbl(exp_cnt).exception_behavior = 'WARNING' THEN
            IF l_exceptions_tbl(exp_cnt).entity_name = 'STOP' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Stop');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',wsh_trip_stops_pvt.get_name(l_exceptions_tbl(exp_cnt).entity_id)); --BugFix #3925590
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               wsh_util_core.add_message(x_return_status);
               l_stop_warnings := l_stop_warnings + 1;
            ELSIF NOT (l_exp_logged) THEN
               -- BugFix #3947506
               WSH_UTIL_CORE.Get_Entity_Name
                ( l_exceptions_tbl(exp_cnt).entity_id,
                  l_exceptions_tbl(exp_cnt).entity_name,
                  l_out_entity_id,
                  l_out_entity_name,
                  l_out_status);

               IF ( l_out_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
                 wsh_util_core.add_message(l_out_status);
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
               -- End of code BugFix #3947506
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_out_entity_name); -- BugFix #3947506
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_out_entity_id); -- BugFix #3947506
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               l_exp_logged := TRUE;
               wsh_util_core.add_message(x_return_status);
               l_stop_warnings := l_stop_warnings + 1;
            END IF;
         END IF;
    END LOOP;

    --
    --
    -- Get all previous stop on the same trip which are not closed.
    -- All prior outbound/mixed stops must be closed.
    --
    -- If current stop is inbound, then all prior inbound stops must be closed as well.
    --
    -- If current stop is not inbound, then give a warning if any prior inbound stop is open.
    --
    -- Following loop for cursor prev_stop_csr validates the above.
    --
    FOR prev_stop_rec IN prev_stop_csr
                          (
                            p_trip_id        => l_stop_info_rec.trip_id,
                            p_linked_stop_id => l_linked_stop_info_rec.stop_id,
                            p_stop_sequence  => l_stop_info_rec.stop_sequence_number
                          )
    LOOP
    --{
        IF p_in_rec.put_messages
        THEN
        --{
            FND_MESSAGE.SET_NAME('WSH','WSH_PREV_STOP_NOT_CLOSED');
            FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
            --
            l_prev_stop_name := SUBSTRB(
                                        WSH_UTIL_CORE.get_location_description
                                          (
                                            prev_stop_rec.stop_location_id,
                                            'NEW UI CODE'
                                          ),
                                        1,
                                        60
                                     );
            --
            FND_MESSAGE.SET_TOKEN('PREV_STOP_NAME',l_prev_stop_name);
            FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_stop_info_rec.trip_name);
            FND_MESSAGE.SET_TOKEN('PREV_TRIP_NAME',l_stop_info_rec.trip_name);
        --}
        END IF;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.shipments_type_flag',prev_stop_rec.shipments_type_flag);
           WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.stop_location_id',prev_stop_rec.stop_location_id);
        END IF;
        --
        --
        IF l_virtual_shipments_type_flag IN ( 'M' , 'O' )
        AND prev_stop_rec.shipments_type_flag = 'I'
        THEN
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
            END IF;
            --
            l_stop_warnings := l_stop_warnings + 1;
        --}
        ELSE
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --}
            END IF;
            --
            --CLOSE prev_stop_csr;
            --
            RAISE wsh_util_core.e_not_allowed;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    -- bug 1550824: check for deliveries not ready to pick up
    --
    --
    -- Check if there are any open deliveries to be picked up at the stop.
    -- All outbound (O/IO) deliveries must be at least ship-confirmed.
    --
    -- If current stop is inbound, then all inbound deliveries (not O/IO) must be in-transit.
    --
    -- If current stop is mixed one, then give a warning if any open inbound delivery (not O/IO)
    --
    -- Following loop for cursor open_pickup_dlvy_csr validates the above.
    --
    FOR open_pickup_dlvy_rec IN open_pickup_dlvy_csr (p_in_rec.stop_id)
    LOOP
    --{
        IF p_in_rec.put_messages
        THEN
        --{
            IF open_pickup_dlvy_rec.shipment_direction IN ( 'O', 'IO' )
            THEN
                l_message_name := 'WSH_STOP_CLOSE_OP_PA_ERROR';
            ELSE
                l_message_name := 'WSH_STOP_CLOSE_OP_IT_ERROR';
            END IF;
            --
            FND_MESSAGE.SET_NAME('WSH', l_message_name);
            FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
        --}
        END IF;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'open_pickup_dlvy_rec.shipment_direction',open_pickup_dlvy_rec.shipment_direction);
        END IF;
        --
        --
        IF open_pickup_dlvy_rec.shipment_direction IN ( 'O', 'IO' )
        OR l_virtual_shipments_Type_flag      = 'I'
        THEN
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --}
            END IF;
            --
            --CLOSE open_pickup_dlvy_csr;
            --
            RAISE wsh_util_core.e_not_allowed;
        --}
        ELSE
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
            END IF;
            --
            --CLOSE open_pickup_dlvy_csr;
            --
            l_stop_warnings := l_stop_warnings + 1;
            --
            EXIT;
        --}
        END IF;
        --CLOSE open_pickup_dlvy_csr;
    --}
    END LOOP;
    --
    --
    -- Check if there are any OP/CO/IT deliveries being dropped off at the stop.
    -- All outbound (O/IO) deliveries must be at least set to in-transit.
    -- All inbound (not O/IO) deliveries must be at least set to in-transit.
    --
    -- If current stop is inbound and it is the last stop for delivery, then delivery
        -- must be closed.
    --
    -- If current stop is mixed one, then give a warning
    --    - if any inbound delivery (not O/IO) which is not in-transit
    --    - if any inbound delivery (not O/IO) which is not closed and this is the
    --      last stop for the delivery
    --
    -- Following loop for cursor open_dropoff_dlvy_csr validates the above.
    --
    FOR open_dropoff_dlvy_rec IN open_dropoff_dlvy_csr (p_in_rec.stop_id,l_stop_info_rec.stop_location_id,
                                                        l_linked_stop_info_rec.stop_id, l_linked_stop_info_rec.stop_location_id)
    LOOP
    --{
        IF p_in_rec.put_messages
        THEN
        --{
            IF open_dropoff_dlvy_rec.shipment_direction IN ( 'O', 'IO' )
            OR open_dropoff_dlvy_rec.status_Code IN ( 'OP', 'PA','CO' )
            THEN
                l_message_name := 'WSH_DO_STOP_CLOSE_ERROR';
            ELSE
                l_message_name := 'WSH_DO_IB_STOP_CLOSE_ERROR';
            END IF;
            --
            FND_MESSAGE.SET_NAME('WSH', l_message_name);
            FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
        --}
        END IF;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'open_dropoff_dlvy_rec.shipment_direction',open_dropoff_dlvy_rec.shipment_direction);
           WSH_DEBUG_SV.log(l_module_name,'open_dropoff_dlvy_rec.status_Code',open_dropoff_dlvy_rec.status_Code);
           WSH_DEBUG_SV.log(l_module_name,'open_dropoff_dlvy_rec.ultimate_Dropoff_location_id',open_dropoff_dlvy_rec.ultimate_Dropoff_location_id);
        END IF;
        --
        --
        -- note that open_dropoff_dlvy_csr filters the deliveries by status,
        -- so that this code will see
        --       *  outbound and outbound internal deliveries
        --              in status Open or Confirmed
        --       *  inbound deliveries in status Open or In-Transit.
        --
        -- validate that the outbound or internal outbound deliveries being dropped off
        -- are not open or confirmed.
        --
        -- validate that the inbound deliveries are:
        --              * neither open
        --              * nor in-transit if its main/internal stop is inbound only
        --                and at its ultimate drop off location.
        --
        -- give warning in the event that the drop-off stop has mixed shipments
        -- if either condition is met:
        --              * the inbound delivery is open
        --              * the inbound delivery is in transit
        --
        -- In other words:
        --
        -- 1. Outbound deliveries must be in transit or closed
        --    for both cases of outbound and mixed stops
        --    (i.e., neither open nor confirmed).
        --
        -- 2. If the stop is Inbound only, inbound deliveries must be:
        --       * in-transit if not ultimate drop-off
        --       * or closed if ultimate drop-off.
        --
        -- 3. If the stop is mixed, give warning when inbound deliveries
        --    are open or in-transit.
        --
        IF
            -- outbound [open/confirmed] delivery is dropped off at either main or linked stop
           open_dropoff_dlvy_rec.shipment_direction IN ( 'O', 'IO' )
        OR (     -- inbound delivery at either main or linked stop
                 l_virtual_shipments_Type_flag       = 'I'
             AND (
                      open_dropoff_dlvy_rec.status_Code =  'OP'
                   OR (
                            open_dropoff_dlvy_rec.status_Code =  'IT'
                        AND open_dropoff_dlvy_rec.last_stop   = 1
                      )
                 )
           )
        THEN
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --}
            END IF;
            --
            --CLOSE open_dropoff_dlvy_csr;
            --
            RAISE wsh_util_core.e_not_allowed;
        --}
        --ELSE
        ELSIF
             -- stop's shipments type flag is mixed; checking status of inbound deliveries
             (
                      open_dropoff_dlvy_rec.status_Code =  'OP'
                   OR (     -- at the main stop
                            open_dropoff_dlvy_rec.status_Code =  'IT'
                        AND open_dropoff_dlvy_rec.last_stop   = 1
                      )
             )
                THEN
        --{
            IF p_in_rec.put_messages
            THEN
            --{
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
            END IF;
            --
            --CLOSE open_dropoff_dlvy_csr;
            --
            l_stop_warnings := l_stop_warnings + 1;
            --
            EXIT;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    -- If any delivery is being picked up at current stop, then check previous leg
    -- for each such delivery.
    --
    -- (Linked internal stop is not checked because it cannot be used as pick up.)
    --
    -- If drop-off stop of previous leg is open and delivery involved is outbound (O/IO),
    -- it is an error.
    --
    -- If drop-off stop of previous leg is open and delivery involved is inbound (not O/IO),
    -- it is an error if current stop is also inbound else it is warning.
    --
    -- If drop-off stop of previous leg is not open and delivery involved is inbound (not O/IO),
    -- it is an error, if delivery is not closed.
    --
    -- Following loop for cursor prev_leg_csr validates the above.
    --
    FOR prev_leg_rec IN prev_leg_csr
                            (
                                p_stop_id     => p_in_rec.stop_id,
                                p_delivery_id => NULL
                            )
    LOOP
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_shipments_type_flag',prev_leg_rec.do_stop_shipments_type_flag);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_status_code',prev_leg_rec.do_stop_status_code);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_locationId',prev_leg_rec.do_stop_locationId);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_id',prev_leg_rec.do_stop_id);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_shipments_type_flag',prev_leg_rec.pu_stop_shipments_type_flag);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_status_code',prev_leg_rec.pu_stop_status_code);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_locationId',prev_leg_rec.pu_stop_locationId);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_id',prev_leg_rec.pu_stop_id);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.shipment_direction',prev_leg_rec.shipment_direction);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.dlvy_status_code',prev_leg_rec.dlvy_status_code);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.delivery_id',prev_leg_rec.delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.dlvy_initialPULocationId',prev_leg_rec.dlvy_initialPULocationId);
        END IF;
        --
        IF prev_leg_rec.do_stop_status_code = 'OP'
        THEN
        --{
            IF p_in_rec.put_messages
            THEN
            --{
              FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_DLEG_ERROR');
              FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
            --}
            END IF;
            --
            IF l_virtual_shipments_Type_flag     <> 'M'
            OR prev_leg_rec.do_stop_shipments_type_flag = 'O'
            OR prev_leg_rec.shipment_direction         IN ( 'O', 'IO' )
            THEN
            --{
                IF p_in_rec.put_messages
                THEN
                --{
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                --}
                END IF;
                --
                --CLOSE prev_leg_csr;
                --
                RAISE wsh_util_core.e_not_allowed;
            --}
            ELSE
            --{
                IF p_in_rec.put_messages
                THEN
                --{
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                --}
                END IF;
                --
                --CLOSE prev_leg_csr;
                --
                l_stop_warnings := l_stop_warnings + 1;
                --
                EXIT;
            --}
            END IF;
        --}
        ELSIF prev_leg_rec.do_stop_status_code     IN ('AR','CL')
        AND   prev_leg_rec.shipment_direction  NOT IN ( 'O', 'IO' )
        AND   prev_leg_rec.dlvy_status_code        <> 'OP'
        --AND   prev_leg_rec.dlvy_status_code        <> 'CL'
        THEN
        --{
            FOR prev_stop_rec IN prev_stop_csr
                                  (
                                    p_trip_id       => prev_leg_rec.prev_leg_trip_id,
                                    p_linked_stop_id => l_linked_stop_info_rec.stop_id,
                                    p_stop_sequence => prev_leg_rec.do_stop_sequence_number
                                  )
            LOOP
            --{
                IF p_in_rec.put_messages
                THEN
                --{
                    FND_MESSAGE.SET_NAME('WSH','WSH_PREV_STOP_NOT_CLOSED');
                    FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                    --
                    l_prev_stop_name := SUBSTRB(
                                                WSH_UTIL_CORE.get_location_description
                                                  (
                                                    prev_stop_rec.stop_location_id,
                                                    'NEW UI CODE'
                                                  ),
                                                1,
                                                60
                                             );
                    --
                    FND_MESSAGE.SET_TOKEN('PREV_STOP_NAME',l_prev_stop_name);
                    FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_stop_info_rec.trip_name);
                    FND_MESSAGE.SET_TOKEN('PREV_TRIP_NAME',prev_leg_rec.prev_leg_trip_name);
                --}
                END IF;
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.shipments_type_flag',prev_stop_rec.shipments_type_flag);
                   WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.stop_location_id',prev_stop_rec.stop_location_id);
                END IF;
                --
                --
                IF l_virtual_shipments_Type_flag      = 'I'
                THEN
                --{
                    IF p_in_rec.put_messages
                    THEN
                    --{
                        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    --}
                    END IF;
                    --
                    --CLOSE prev_leg_csr;
                    --
                    RAISE wsh_util_core.e_not_allowed;
                --}
                ELSE
                --{
                    IF p_in_rec.put_messages
                    THEN
                    --{
                        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                    --}
                    END IF;
                    --
                    --CLOSE prev_leg_csr;
                    --
                    l_stop_warnings := l_stop_warnings + 1;
                    --
                    EXIT;
                --}
                END IF;
            --}
            END LOOP;
            --
            IF prev_leg_rec.pu_stop_status_code = 'OP'
            THEN
            --{
                null;
            --}
            ELSE
            --{
                l_stop_locationId := prev_leg_rec.pu_stop_locationId;
                l_stop_Id         := prev_leg_rec.pu_stop_Id;
                l_dlvy_initialPULocationId := prev_leg_rec.dlvy_initialPULocationId;
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Checking all prior legs-1');
                END IF;
                --
                WHILE l_stop_locationId <> l_dlvy_initialPULocationId
                LOOP
                --{
                    FOR prev_leg_rec1 IN prev_leg_csr1
                                            (
                                                p_stop_id     => l_stop_id,
                                                p_delivery_id => prev_leg_Rec.delivery_id
                                            )
                    LOOP
                    --{

                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.do_stop_shipments_type_flag',prev_leg_rec1.do_stop_shipments_type_flag);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.do_stop_status_code',prev_leg_rec1.do_stop_status_code);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.do_stop_locationId',prev_leg_rec1.do_stop_locationId);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.do_stop_id',prev_leg_rec1.do_stop_id);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.pu_stop_shipments_type_flag',prev_leg_rec1.pu_stop_shipments_type_flag);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.pu_stop_status_code',prev_leg_rec1.pu_stop_status_code);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.pu_stop_locationId',prev_leg_rec1.pu_stop_locationId);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.pu_stop_id',prev_leg_rec1.pu_stop_id);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.shipment_direction',prev_leg_rec1.shipment_direction);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec1.dlvy_status_code',prev_leg_rec1.dlvy_status_code);
                        END IF;
                        --
                        IF prev_leg_rec1.do_stop_status_code = 'OP'
                        THEN
                        --{
                            IF p_in_rec.put_messages
                            THEN
                            --{
                              FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_DLEG_ERROR');
                              FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                              --wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                            --}
                            END IF;
                            --
                            IF l_virtual_shipments_Type_flag  = 'I'
                            THEN
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                RAISE wsh_util_core.e_not_allowed;
                            --}
                            ELSE
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                l_stop_warnings := l_stop_warnings + 1;
                                --
                                --EXIT;
                            --}
                            END IF;
                        --}
                        END IF;
                        --
                        --
                        FOR prev_stop_rec IN prev_stop_csr
                                              (
                                                p_trip_id       => prev_leg_rec1.prev_leg_trip_id,
                                                p_linked_stop_id => l_linked_stop_info_rec.stop_id,

                                                p_stop_sequence => prev_leg_rec1.do_stop_sequence_number
                                              )
                        LOOP
                        --{
                            IF p_in_rec.put_messages
                            THEN
                            --{
                                FND_MESSAGE.SET_NAME('WSH','WSH_PREV_STOP_NOT_CLOSED');
                                FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                                --
                                l_prev_stop_name := SUBSTRB(
                                                            WSH_UTIL_CORE.get_location_description
                                                              (
                                                                prev_stop_rec.stop_location_id,
                                                                'NEW UI CODE'
                                                              ),
                                                            1,
                                                            60
                                                         );
                                --
                                FND_MESSAGE.SET_TOKEN('PREV_STOP_NAME',l_prev_stop_name);
                                FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_stop_info_rec.trip_name);
                                FND_MESSAGE.SET_TOKEN('PREV_TRIP_NAME',prev_leg_rec1.prev_leg_trip_name);
                            --}
                            END IF;
                            --
                            IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.shipments_type_flag',prev_stop_rec.shipments_type_flag);
                               WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.stop_location_id',prev_stop_rec.stop_location_id);
                            END IF;
                            --
                            --
                            IF l_virtual_shipments_Type_flag      = 'I'
                            THEN
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                RAISE wsh_util_core.e_not_allowed;
                            --}
                            ELSE
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                l_stop_warnings := l_stop_warnings + 1;
                                --
                                EXIT;
                            --}
                            END IF;
                        --}
                        END LOOP;
                        --
                        --
                        --
                        l_stop_locationId := prev_leg_rec1.pu_stop_locationId;
                        l_stop_Id         := prev_leg_rec1.pu_stop_Id;
                    --}
                    END LOOP;
                --}
                END LOOP;
            --}
            END IF;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    -- If current stop is drop-off for any inbound (not O/IO) delivery,
    -- check all its prior stops.
    --
    -- If any prior stop is open then
    --   if current stop is inbound or prior stop is mixed
    --   then error
    --   else warning.
    --
    -- Following loop for cursor ib_pickup_csr validates the above.
    -- It first finds pickup stop for the delivery on current trip.
    -- Then it recursively traverses prior legs for the delivery (By passing pickup stop found above
    -- to prev_leg_csr), until it reaches starting(initial)
    -- pickup stop for the delivery.
    --
    FOR ib_pickup_rec IN ib_pickup_csr (p_in_rec.stop_id,
                                        l_linked_stop_info_rec.stop_id)
    LOOP
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.pu_stop_statusCode',ib_pickup_rec.pu_stop_statusCode);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.pu_shipments_type_flag',ib_pickup_rec.pu_shipments_type_flag);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.delivery_statusCode',ib_pickup_rec.delivery_statusCode);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.pu_stop_locationId',ib_pickup_rec.pu_stop_locationId);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.pu_stop_id',ib_pickup_rec.pu_stop_id);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.delivery_id',ib_pickup_rec.delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'ib_pickup_rec.dlvy_initialPULocationId',ib_pickup_rec.dlvy_initialPULocationId);
        END IF;
        --
        IF ib_pickup_rec.pu_stop_statusCode in ('OP','AR')
        THEN
        --{
	  null;
        --}
        ELSE --- stop is closed, check all prev. legs
        --{
            --IF ib_pickup_rec.delivery_statusCode = 'CL'
            IF ib_pickup_rec.delivery_statusCode in ('IT', 'CL')
            THEN
            --{
                l_stop_locationId := ib_pickup_rec.pu_stop_locationId;
                l_stop_Id         := ib_pickup_rec.pu_stop_Id;
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Checking all prior legs');
                END IF;
                --
                WHILE l_stop_locationId <> ib_pickup_rec.dlvy_initialPULocationId
                LOOP
                --{
                    FOR prev_leg_rec IN prev_leg_csr
                                            (
                                                p_stop_id     => l_stop_id,
                                                p_delivery_id => ib_pickup_rec.delivery_id
                                            )
                    LOOP
                    --{

                        IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_shipments_type_flag',prev_leg_rec.do_stop_shipments_type_flag);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_status_code',prev_leg_rec.do_stop_status_code);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_locationId',prev_leg_rec.do_stop_locationId);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.do_stop_id',prev_leg_rec.do_stop_id);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_shipments_type_flag',prev_leg_rec.pu_stop_shipments_type_flag);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_status_code',prev_leg_rec.pu_stop_status_code);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_locationId',prev_leg_rec.pu_stop_locationId);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.pu_stop_id',prev_leg_rec.pu_stop_id);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.shipment_direction',prev_leg_rec.shipment_direction);
                           WSH_DEBUG_SV.log(l_module_name,'prev_leg_rec.dlvy_status_code',prev_leg_rec.dlvy_status_code);
                        END IF;
                        --
                        --IF prev_leg_rec.do_stop_status_code in ('OP','AR')
                        IF prev_leg_rec.do_stop_status_code in ('OP')
                        THEN
                        --{
                            IF p_in_rec.put_messages
                            THEN
                            --{
                              FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_DO_DO_ERROR');
                              FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                              --wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                            --}
                            END IF;
                            --
                            IF l_virtual_shipments_Type_flag  = 'I'
                            THEN
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                RAISE wsh_util_core.e_not_allowed;
                            --}
                            ELSE
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                l_stop_warnings := l_stop_warnings + 1;
                                --
                                --EXIT;
                            --}
                            END IF;
                        --}
                        END IF;
                        --
                        --
                        FOR prev_stop_rec IN prev_stop_csr
                                              (
                                                p_trip_id       => prev_leg_rec.prev_leg_trip_id,
                                                p_linked_stop_id => l_linked_stop_info_rec.stop_id,

                                                p_stop_sequence => prev_leg_rec.do_stop_sequence_number
                                              )
                        LOOP
                        --{
                            IF p_in_rec.put_messages
                            THEN
                            --{
                                FND_MESSAGE.SET_NAME('WSH','WSH_PREV_STOP_NOT_CLOSED');
                                FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                                --
                                l_prev_stop_name := SUBSTRB(
                                                            WSH_UTIL_CORE.get_location_description
                                                              (
                                                                prev_stop_rec.stop_location_id,
                                                                'NEW UI CODE'
                                                              ),
                                                            1,
                                                            60
                                                         );
                                --
                                FND_MESSAGE.SET_TOKEN('PREV_STOP_NAME',l_prev_stop_name);
                                FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_stop_info_rec.trip_name);
                                FND_MESSAGE.SET_TOKEN('PREV_TRIP_NAME',prev_leg_rec.prev_leg_trip_name);
                            --}
                            END IF;
                            --
                            IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.shipments_type_flag',prev_stop_rec.shipments_type_flag);
                               WSH_DEBUG_SV.log(l_module_name,'prev_stop_rec.stop_location_id',prev_stop_rec.stop_location_id);
                            END IF;
                            --
                            --
                            IF l_virtual_shipments_Type_flag      = 'I'
                            THEN
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                RAISE wsh_util_core.e_not_allowed;
                            --}
                            ELSE
                            --{
                                IF p_in_rec.put_messages
                                THEN
                                --{
                                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                                --}
                                END IF;
                                --
                                --CLOSE prev_leg_csr;
                                --
                                l_stop_warnings := l_stop_warnings + 1;
                                --
                                EXIT;
                            --}
                            END IF;
                        --}
                        END LOOP;
                        --
                        --
                        l_stop_locationId := prev_leg_rec.pu_stop_locationId;
                        l_stop_Id         := prev_leg_rec.pu_stop_Id;
                    --}
                    END LOOP;
                --}
                END LOOP;
            --}
            END IF;
        --}
        END IF;
        --
        --CLOSE ib_pickup_csr;
    --}
    END LOOP;
    --
    --
    -- Initialize loop variables
    --
    l_prev_org_id  := -999;
    l_err_dlvy_cnt := 0;
    l_dlvy_cnt     := 0;
    -- J: W/V Changes
    l_wv_check_done := FALSE;
    --
    -- Get all deliveries which start(initial pickup location) at current stop,
    -- sorted by organization id
    --
    FOR l_initial_pu_dlvy_rec IN initial_pu_dlvy_csr(p_in_rec.stop_id)
    LOOP
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_initial_pu_dlvy_rec.organization_id',l_initial_pu_dlvy_rec.organization_id);
           WSH_DEBUG_SV.log(l_module_name,'l_prev_org_id',l_prev_org_id);
        END IF;
        --
        -- Since deliveries are sorted by organization_id,
        -- peform organization specific checks only when organization id changes
        --
        IF l_initial_pu_dlvy_rec.organization_id <> l_prev_org_id
        THEN
        --{
               l_prev_org_dlvy_cnt := l_dlvy_cnt;
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_prev_org_dlvy_cnt',l_prev_org_dlvy_cnt);
                   WSH_DEBUG_SV.log(l_module_name,'l_dlvy_cnt',l_dlvy_cnt);
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               WSH_SHIPPING_PARAMS_PVT.Get
                (
                  p_organization_id => l_initial_pu_dlvy_rec.organization_id,
                  x_param_info      => l_param_info,
                  x_return_status   => l_return_status
                );
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               END IF;
               --
               WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );

          IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

         --Bug 3346237: Allow future date and enforce ship method should take values from
         --             Global parameters table.

         WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters
                (
                  x_param_info      => l_global_info,
                  x_return_status   => l_return_status
                );
               --

         IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               END IF;
               --

         WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );

         --
               --
               -- J: W/V Changes
               IF NOT l_wv_check_done THEN
                 l_wv_check_done := TRUE;

                 IF (l_param_info.percent_fill_basis_flag = 'W' and l_stop_info_rec.departure_gross_weight is NULL) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WV');
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   FND_MESSAGE.SET_TOKEN('ENTITY_TYPE','Stop');
                   FND_MESSAGE.SET_TOKEN('ENTITY_NAME',wsh_trip_stops_pvt.get_name(p_in_rec.stop_id,p_in_rec.caller));
                   FND_MESSAGE.SET_TOKEN('WV','Weight');
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                   wsh_util_core.add_message(x_return_status);
                   l_stop_warnings := l_stop_warnings + 1;
                 END IF;

                 IF (l_param_info.percent_fill_basis_flag = 'V' and l_stop_info_rec.departure_volume is NULL) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WV');
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   FND_MESSAGE.SET_TOKEN('ENTITY_TYPE','Stop');
                   FND_MESSAGE.SET_TOKEN('ENTITY_NAME',wsh_trip_stops_pvt.get_name(p_in_rec.stop_id,p_in_rec.caller));
                   FND_MESSAGE.SET_TOKEN('WV','Volume');
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                   wsh_util_core.add_message(x_return_status);
                   l_stop_warnings := l_stop_warnings + 1;
                 END IF;
               END IF;
               --
               --
               -- Validate stop close date against today's date.
               -- Generate error/warning depending on shipping parameter "Allow future date"
               --
               IF p_in_rec.actual_date > sysdate THEN
               --{
                   IF p_in_rec.put_messages
                   THEN
                      FND_MESSAGE.SET_NAME('WSH','WSH_ADEP_DATE_FUTURE');
                   END IF;
                   --
                   IF (NVL(l_global_info.allow_future_ship_date, 'N') = 'Y')
                   THEN
                   --{
                        IF p_in_rec.put_messages
                        THEN
                        --{
                            WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                        --}
                        END IF;
                        --
                        l_stop_warnings := l_stop_warnings + 1;
                   --}
                   ELSE
                   --{
                        IF p_in_rec.put_messages
                        THEN
                        --{
                            WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                        --}
                        END IF;
                        --
                        --CLOSE initial_pu_dlvy_csr;
                        RAISE wsh_util_core.e_not_allowed;
                   --}
                   END IF;
               --}
               END IF;
               --
               --
               -- Check for open inventory period
               -- Error, if inventory period (corresponding to stop close date) is not open
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INVTTMTX.TDATECHK',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               invttmtx.tdatechk(l_initial_pu_dlvy_rec.organization_id, p_in_rec.actual_date, l_period_id, l_open_past_period);

               IF (l_period_id <= 0)
               THEN
               --{
                      IF p_in_rec.put_messages
                      THEN
                      --{
                            FND_MESSAGE.SET_NAME('WSH','WSH_STOP_DATE_UNOPEN_PERIOD');
                            FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
			    l_org_name := WSH_UTIL_CORE.Get_Org_Name(l_initial_pu_dlvy_rec.organization_id);
                            FND_MESSAGE.SET_TOKEN('ORG_NAME', l_org_name );
                            WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                      --}
                      END IF;
                      --
                      --CLOSE initial_pu_dlvy_csr;
                      RAISE wsh_util_core.e_not_allowed;
               --}
               END IF;
        --}
        END IF;

	 -- Added check for ultimate dropoff location for internal orders, if it changes
        IF NVL(l_initial_pu_dlvy_rec.io_location_id, NVL(l_prev_dropoff_location_id, -99))
        <> NVL(l_prev_dropoff_location_id, -99) THEN --{
           l_prev_dropoff_location_id := l_initial_pu_dlvy_rec.io_location_id;

           OPEN get_org_id(l_initial_pu_dlvy_rec.delivery_id);
           FETCH get_org_id INTO l_rec_organization_id, l_dest_type_code;
           IF get_org_id%NOTFOUND THEN
              l_rec_organization_id := NULL;
              l_dest_type_code      := NULL;
           END IF;
           CLOSE get_org_id;

           IF l_rec_organization_id IS NOT NULL THEN --{
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Receiving Organization_id : '|| l_rec_organization_id ||
                                                   ' , Destination Source Code : '|| l_dest_type_code);
              END IF;
              -- Validate Accounting Period Open only if its a Direct Transfer or InTransit Shipment to Expense Destination
              l_intransit_type   := NULL;
              IF l_dest_type_code = 'EXPENSE' THEN
                 l_validate_rec_org := TRUE;
              ELSE --{
                 l_validate_rec_org := FALSE;
                 -- Check Shipping Networks to find the Transit Type
                 OPEN c_mtl_interorg_parameters( l_initial_pu_dlvy_rec.organization_id, l_rec_organization_id);
                 FETCH c_mtl_interorg_parameters INTO l_intransit_type;
                 IF c_mtl_interorg_parameters%FOUND THEN
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'Intransit Type', l_intransit_type);
                    END IF;
                    IF l_intransit_type = 1 THEN
                       l_validate_rec_org := TRUE;
                    END IF;
                 END IF;
                 CLOSE c_mtl_interorg_parameters; --}
              END IF;

              IF l_validate_rec_org THEN --{
                 -- Check for open inventory period
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INVTTMTX.TDATECHK',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 invttmtx.tdatechk(l_rec_organization_id, p_in_rec.actual_date, l_period_id, l_open_past_period);

                 IF (l_period_id <= 0) THEN
                    IF p_in_rec.put_messages THEN
                       FND_MESSAGE.SET_NAME('WSH','WSH_STOP_DATE_UNOPEN_PERIOD');
                       FND_MESSAGE.SET_TOKEN('STOP_NAME', l_stop_name );
                       l_org_name := WSH_UTIL_CORE.Get_Org_Name(l_rec_organization_id);
                       FND_MESSAGE.SET_TOKEN('ORG_NAME', l_org_name );
                       WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    END IF;
                    RAISE wsh_util_core.e_not_allowed;
                 END IF;
              END IF; --}
           END IF; --}
        END IF; --}
        --
        --
        -- Check if export compliance check is reqd. for this delivery org.
        --
        IF l_param_info.export_screening_flag in ('C', 'S', 'A')
        THEN
        --{
             l_itm_mark_dels(1) :=  l_initial_pu_dlvy_rec.delivery_id;
             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_delivery_validations.check_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_delivery_validations.check_exception(
                  p_deliveries_tab => l_itm_mark_dels,
                  x_exceptions_exist => l_exceptions_exist,
                  x_exceptions_tab => l_exceptions_tab,
                  x_return_status => l_return_status);
             --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               END IF;
               --
             WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );
             --
             IF  l_exceptions_exist = 'Y'
             AND l_exceptions_tab(1).severity in ('HIGH', 'MEDIUM')
             THEN
             --{
                    IF p_in_rec.caller = 'SHIP_CONFIRM'
                    THEN
                    --{
                        IF p_in_rec.put_messages
                        THEN
                        --{
                             FND_MESSAGE.SET_NAME('WSH','WSH_ITM_COMPLIANCE_WARN');
                             FND_MESSAGE.SET_TOKEN('DEL_NAME', l_initial_pu_dlvy_rec.name);
                             WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                        --}
                        END IF;
                        --
                        --CLOSE initial_pu_dlvy_csr;
                        RAISE wsh_util_core.e_not_allowed_warning;
                    --}
                    ELSE
                    --{
                        IF p_in_rec.put_messages
                        THEN
                        --{
                             FND_MESSAGE.SET_NAME('WSH','WSH_ITM_ERROR_STOP');
                             FND_MESSAGE.SET_TOKEN('DEL_NAME', l_initial_pu_dlvy_rec.name);
                             WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                        --}
                        END IF;
                        --
                        --CLOSE initial_pu_dlvy_csr;
                        RAISE wsh_util_core.e_not_allowed;
                    --}
                    END IF;
             --}
             END IF;
        --}
        END IF;
        --
        --
        l_in_rec.delivery_id    := l_initial_pu_dlvy_rec.delivery_id;
        l_in_rec.name           := l_initial_pu_dlvy_rec.name;
        l_in_rec.status_code    := l_initial_pu_dlvy_rec.status_code;
        l_in_rec.put_messages   := p_in_rec.put_messages;
        l_in_rec.actual_date    := p_in_rec.actual_date;
        l_in_rec.manual_flag    := 'N';
        l_in_rec.caller         := p_in_rec.caller;
        l_in_rec.stop_id        := p_in_Rec.stop_id;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.check_inTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        -- Check if deliveries can be set to in-transit.
        -- If allowed, add delivery to output parameter x_out_rec.initial_pu_dlvy_recTbl
        -- If not allowed, add delivery to output parameter x_out_rec.initial_pu_err_dlvy_id_tbl
        --
        WSH_DELIVERY_VALIDATIONS.check_inTransit
            (
               p_in_rec         => l_in_rec,
               x_return_status  => l_return_status,
               x_allowed        => l_Allowed
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
        END IF;
        --
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        IF l_Allowed IN ( 'YW', 'NW' )
        THEN
            l_num_warnings := l_num_warnings + 1;
        END IF;
        --
        IF l_allowed      NOT IN ('Y', 'YW')
        THEN
        --{
            -- If not allowed, add delivery to output parameter x_out_rec.initial_pu_err_dlvy_id_tbl
            --
            l_err_dlvy_cnt := l_err_dlvy_cnt + 1;
            x_out_rec.initial_pu_err_dlvy_id_tbl(l_err_dlvy_cnt) := l_initial_pu_dlvy_rec.delivery_id;
        --}
        ELSE
        --{
            -- If allowed, add delivery to output parameter x_out_rec.initial_pu_dlvy_recTbl
            --
            l_dlvy_cnt := l_dlvy_cnt + 1;
            --
            x_out_rec.initial_pu_dlvy_recTbl.id_tbl(l_dlvy_cnt)            := l_initial_pu_dlvy_rec.delivery_id;
            x_out_rec.initial_pu_dlvy_recTbl.name_tbl(l_dlvy_cnt)       := l_initial_pu_dlvy_rec.name;
            x_out_rec.initial_pu_dlvy_recTbl.orgId_tbl(l_dlvy_cnt)      := l_initial_pu_dlvy_rec.organization_id;
            x_out_rec.initial_pu_dlvy_recTbl.statusCode_tbl(l_dlvy_cnt) := l_initial_pu_dlvy_rec.status_code;
        --}
        END IF;
        --
        --
        --IF l_dlvy_cnt > l_prev_org_dlvy_cnt
        --
        -- Condition below indicates first delivery being processed for an organization
        --
        IF l_dlvy_cnt = l_prev_org_dlvy_cnt+1
        THEN
        --{
               --
               -- If shipping parameter "Enforce ship method" is true
               -- and ship method is null on the trip,  stop close cannot be allowed.
               --
               IF  l_global_info.enforce_ship_method = 'Y'
               AND l_stop_info_rec.ship_method_code IS NULL
               THEN
               --{
                    IF p_in_rec.put_messages
                    THEN
                    --{
                        FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_SM_NOT_FOUND');
                        WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    --}
                    END IF;
                    --
                    --CLOSE initial_pu_dlvy_csr;
                    RAISE wsh_util_core.e_not_allowed;
               --}
               END IF;
        --}
        END IF;
        --
        --
        l_prev_org_id := l_initial_pu_dlvy_rec.organization_id;
    --}
    END LOOP;
    --
    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_dlvy_cnt',l_dlvy_cnt);
           WSH_DEBUG_SV.log(l_module_name,'l_err_dlvy_cnt',l_err_dlvy_cnt);
    END IF;
    --
    -- IF all deliveries errored out, stop close cannot be allowed.
    --
    IF l_dlvy_cnt = 0 AND l_err_dlvy_cnt > 0
    THEN
    --{
          RAISE wsh_util_core.e_not_allowed;
    --}
    END IF;
    --
    --
    l_dlvy_cnt := 0;
    --
    -- Get all deliveries which end(ultimate dropoff location) at current stop,
    -- sorted by organization id
    --
    FOR l_ultimate_do_dlvy_rec IN ultimate_do_dlvy_csr(p_in_rec.stop_id,
                                                       l_linked_stop_info_rec.stop_id)
    LOOP
    --{
        --
        l_in_rec.delivery_id    := l_ultimate_do_dlvy_rec.delivery_id;
        l_in_rec.name           := l_ultimate_do_dlvy_rec.name;
        l_in_rec.status_code    := l_ultimate_do_dlvy_rec.status_code;
        l_in_rec.put_messages   := p_in_rec.put_messages;
        l_in_rec.actual_date    := p_in_rec.actual_date;
        l_in_rec.manual_flag    := 'N';
        l_in_rec.caller         := p_in_rec.caller;
        l_in_rec.stop_id        := l_ultimate_do_dlvy_rec.drop_off_stop_id;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.check_close',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Check if delivery can be closed.
        -- If so, add it to out parameter x_out_rec.ultimate_do_dlvy_recTbl
        --
        WSH_DELIVERY_VALIDATIONS.check_close
            (
               p_in_rec         => l_in_rec,
               x_return_status  => l_return_status,
               x_allowed        => l_Allowed
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
        END IF;
        --
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        IF l_Allowed IN ( 'YW', 'NW' )
        THEN
            l_num_warnings := l_num_warnings + 1;
        END IF;
        --
        IF l_allowed      NOT IN ('Y', 'YW')
        THEN
        --{
            NULL;
        --}
        ELSE
        --{
            l_dlvy_cnt := l_dlvy_cnt + 1;
            --
            x_out_rec.ultimate_do_dlvy_recTbl.id_tbl(l_dlvy_cnt)            := l_ultimate_do_dlvy_rec.delivery_id;
            x_out_rec.ultimate_do_dlvy_recTbl.name_tbl(l_dlvy_cnt)       := l_ultimate_do_dlvy_rec.name;
            x_out_rec.ultimate_do_dlvy_recTbl.orgId_tbl(l_dlvy_cnt)      := l_ultimate_do_dlvy_rec.organization_id;
            x_out_rec.ultimate_do_dlvy_recTbl.statusCode_tbl(l_dlvy_cnt) := l_ultimate_do_dlvy_rec.status_code;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    l_trip_in_rec.trip_id        := l_stop_info_rec.trip_id;
    l_trip_in_rec.put_messages   := p_in_rec.put_messages;
    l_trip_in_rec.actual_date    := p_in_rec.actual_date;
    l_trip_in_rec.manual_flag    := 'N';
    l_trip_in_rec.caller         := p_in_rec.caller;
    l_trip_in_rec.stop_id        := p_in_Rec.stop_id;
    l_trip_in_rec.name           := l_stop_info_rec.trip_name;
    l_trip_in_rec.linked_stop_id := l_linked_stop_info_rec.stop_id;
    --
    IF l_stop_info_rec.trip_status_code = 'OP'
    THEN
    --{
        -- Trip is set to in-transit, whenever any stop closes.
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.check_inTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Check if trip can be set to In-Transit.
        --
        WSH_TRIP_VALIDATIONS.check_inTransit
            (
               p_in_rec         => l_trip_in_rec,
               x_return_status  => l_return_status,
               x_allowed        => l_Allowed
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
        END IF;
        --
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        IF l_Allowed = 'N'
        THEN
            -- If trip cannot be set to In-transit, the stop cannot be closed
            l_num_warnings := l_num_warnings + 1;
            RAISE wsh_util_core.e_not_allowed;
        END IF;
        --
        IF l_Allowed IN ( 'YW', 'NW' )
        THEN
            l_num_warnings := l_num_warnings + 1;
        END IF;
        --
        IF l_allowed IN ('Y', 'YW')
        THEN
        --{
            -- If trip can be set to In-transit, set out parameter x_out_rec.trip_new_status_code to 'IT'
            x_out_rec.trip_new_status_code := 'IT';
        --}
        END IF;
    --}
    ELSIF l_stop_info_rec.trip_status_code = 'IT'
    THEN
    --{
        l_trip_in_rec.new_Status_code := 'CL';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.check_close',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Check if trip can be closed.
        --
        WSH_TRIP_VALIDATIONS.check_close
            (
               p_in_rec         => l_trip_in_rec,
               x_return_status  => l_return_status,
               x_allowed        => l_Allowed
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
        END IF;
        --
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        IF l_Allowed = 'N'
        THEN
            -- If trip cannot be closed, the stop cannot be closed
            l_num_warnings := l_num_warnings + 1;
            RAISE wsh_util_core.e_not_allowed;
        END IF;
        --
        IF l_Allowed IN ( 'YW', 'NW' )
        THEN
            l_num_warnings := l_num_warnings + 1;
        END IF;
        --
        IF l_allowed IN ('Y', 'YW')
        THEN
        --{
            -- If trip can be closed, set out parameter x_out_rec.trip_new_status_code to 'CL'
            --
            x_out_rec.trip_new_status_code := l_trip_in_rec.new_Status_code;
        --}
        END IF;
    --}
    END IF;
    --
    --
    IF l_num_errors > 0
    THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_out_rec.close_allowed := 'N';
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    --
    IF l_stop_warnings > 0
    THEN
        x_out_rec.close_allowed := 'YW';
    ELSE
        x_out_rec.close_allowed := 'Y';
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
    WHEN wsh_util_core.e_not_allowed THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_out_rec.close_allowed       := 'N';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.e_not_allowed exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.e_not_allowed');
      END IF;
      --
    WHEN wsh_util_core.e_not_allowed_warning THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_out_Rec.close_allowed := 'NW';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
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
      IF linked_stop_info_csr%ISOPEN THEN
         CLOSE linked_stop_info_csr;
      END IF;
      IF wsh_linked_stop_csr%ISOPEN THEN
         CLOSE wsh_linked_stop_csr;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_TRIP_VALIDATIONS.CHECK_STOP_CLOSE',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END Check_Stop_Close;
--
--
--
--========================================================================
-- PROCEDURE : get_stop_close_date
--
-- PARAMETERS: p_in_rec                Input Record  (Refer to WSHSTVLS.pls for description)
--             p_out_rec               Output record (Refer to WSHSTVLS.pls for description)
--             x_return_status         Return status of API
--
--
-- COMMENT   : This procedure calculate stop close date.
--             This is to be used only for inbound logistics project.
--             This is called when automatically closing stops while processing ASN/Receipt.
--
--             The calculation is as follows:
--             01. Find all deliveries associated with the input stop.
--                 - Deliveries are sorted and grouped as per following order
--                   1. Deliveries starting from this stop. (consider initial pickup date)
--                   2. Deliveries ending at this stop. (consider ultimate dropoff date)
--                   3. Deliveries being picked up at this stop. (consider initial pickup date)
--                   4. Deliveries being dropped of at this stop. (consider ultimate dropoff date)
--             02. API tries to find maximum date within a group.
--             03. Once a date is found, it skips remaining groups.
--             04. If calculated date is less than close date of previous stop,
--                 set it to  close date of previous stop.
--             05. If calculated date is greater than close date of next stop,
--                 set it to  close date of next stop.
--========================================================================
--
PROCEDURE get_stop_close_date
    (
        p_trip_id               IN          NUMBER,
        p_stop_id               IN          NUMBER,
        p_stop_sequence_number  IN          NUMBER,
        x_stop_close_date       OUT NOCOPY  DATE,
        x_return_status         OUT NOCOPY  VARCHAR2
    )
IS
--{
    --  Find all deliveries associated with the input stop.
    --  - Deliveries are sorted and grouped as per following order
    --    1. Deliveries starting from this stop. (consider initial pickup date)
    --    2. Deliveries ending at this stop. (consider ultimate dropoff date)
    --    3. Deliveries being picked up at this stop. (consider initial pickup date)
    --    4. Deliveries being dropped of at this stop. (consider ultimate dropoff date)
    --
    CURSOR ib_dlvy_cur (p_stop_id IN NUMBER)
    IS
        SELECT  wnd.initial_pickup_date delivery_Date,
                DECODE(wts.stop_location_id,wnd.initial_pickup_location_id,1,3) order_seq
        FROM    wsh_new_deliveries  wnd,
                wsh_delivery_legs   wdl,
                wsh_trip_stops      wts
        WHERE   wts.stop_id             = p_stop_id
        AND     wdl.pick_up_stop_id     = wts.stop_id
        AND     wdl.delivery_id         = wnd.delivery_id
        UNION
        SELECT  wnd.ultimate_dropoff_date   delivery_Date,
                DECODE(wts.stop_location_id,wnd.ultimate_dropoff_location_id,2,4) order_seq
        FROM    wsh_new_deliveries  wnd,
                wsh_delivery_legs   wdl,
                wsh_trip_stops      wts
        WHERE   wts.stop_id             = p_stop_id
        AND     wdl.drop_off_stop_id    = wts.stop_id
        AND     wdl.delivery_id         = wnd.delivery_id
        ORDER BY order_seq ASC;
    --
    CURSOR prev_stop_cur (p_trip_id IN NUMBER, p_stop_sequence_number IN NUMBER)
    IS
        SELECT actual_departure_date
        FROM   wsh_trip_stops
        WHERE  trip_id                      = p_trip_id
        AND    stop_sequence_number         < p_stop_sequence_number
        ORDER BY stop_sequence_number DESC;
    --
    CURSOR next_stop_cur (p_trip_id IN NUMBER, p_stop_sequence_number IN NUMBER)
    IS
        SELECT actual_departure_date
        FROM   wsh_trip_stops
        WHERE  trip_id                      = p_trip_id
        AND    stop_sequence_number         > p_stop_sequence_number
        ORDER BY stop_sequence_number ASC;
    --
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --
    l_actual_date           DATE    := NULL;
    l_prev_order_seq        NUMBER  := 0;
    --
    l_prevStop_departure_date   DATE;
    l_nextStop_departure_date   DATE;
    --
    l_debug_on              BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_stop_close_date';
    --
--}
BEGIN
--{
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
       WSH_DEBUG_SV.log(l_module_name,'p_trip_id',p_trip_id);
       WSH_DEBUG_SV.log(l_module_name,'p_stop_id',p_stop_id);
       WSH_DEBUG_SV.log(l_module_name,'p_stop_sequence_number',p_stop_sequence_number);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    FOR ib_dlvy_rec IN ib_dlvy_cur(p_stop_id)
    LOOP
    --{
        IF l_prev_order_seq <> ib_dlvy_rec.order_seq
        AND l_actual_date   IS NOT NULL
        THEN
            EXIT;
        END IF;
        --
        IF l_actual_date IS NULL
        OR l_actual_date < ib_dlvy_rec.delivery_date
        THEN
            l_actual_date   := ib_dlvy_rec.delivery_date;
        END IF ;
        --
        l_prev_order_seq    := ib_dlvy_rec.order_seq;
    --}
    END LOOP;
    --
    --
    l_actual_date := NVL(l_actual_date,SYSDATE);
    --
    l_prevStop_departure_date   := NULL;
    l_nextStop_departure_date   := NULL;
    --
    OPEN prev_stop_cur
         (
            p_trip_id               => p_trip_id,
            p_stop_sequence_number  => p_stop_sequence_number
         );
    --
    FETCH prev_stop_cur INTO l_prevStop_departure_date;
    CLOSE prev_stop_cur;
    --
    IF l_actual_date < l_prevStop_departure_date
    THEN
        l_actual_date := l_prevStop_departure_date;
    END IF;
    --
    OPEN next_stop_cur
         (
            p_trip_id               => p_trip_id,
            p_stop_sequence_number  => p_stop_sequence_number
         );
    --
    FETCH next_stop_cur INTO l_nextStop_departure_date;
    CLOSE next_stop_cur;
    --
    IF l_actual_date > l_nextStop_departure_date
    THEN
        l_actual_date := l_nextStop_departure_date;
    END IF;
    --
    x_stop_close_date   := l_actual_date;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_actual_date',l_actual_date);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
      --
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
        wsh_util_core.default_handler('WSH_TRIP_STOPS_VALIDATIONS.get_stop_close_date', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END get_stop_close_date;



-- J-IB-NPARIKH-}


--3509004:public api change
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
      p_out_rec         IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
      p_in_rec          IN WSH_TRIP_STOPS_GRP.stopInRecType,
      x_return_status   OUT NOCOPY    VARCHAR2)

IS
l_attributes VARCHAR2(2500) ;
k         number;
l_return_status VARCHAR2(1);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'user_non_updatable_columns';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.caller',p_in_rec.caller);
    --
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF     p_user_in_rec.STOP_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.STOP_ID,-99) <> NVL(p_out_rec.STOP_ID,-99)
  THEN
       l_attributes := l_attributes || 'STOP_ID, ';
  END IF;

  IF     p_user_in_rec.TRIP_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TRIP_ID,-99) <> NVL(p_out_rec.TRIP_ID,-99)
  THEN
       l_attributes := l_attributes || 'TRIP_ID, ';
  END IF;

  IF     p_user_in_rec.STOP_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.STOP_LOCATION_ID,-99) <> NVL(p_out_rec.STOP_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'STOP_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.STATUS_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.STATUS_CODE,'!!!') <> NVL(p_out_rec.STATUS_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'STATUS_CODE, ';
  END IF;

  IF     p_user_in_rec.STOP_SEQUENCE_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.STOP_SEQUENCE_NUMBER,-99) <> NVL(p_out_rec.STOP_SEQUENCE_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'STOP_SEQUENCE_NUMBER, ';
  END IF;

  IF     p_user_in_rec.PLANNED_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.PLANNED_ARRIVAL_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.PLANNED_ARRIVAL_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'PLANNED_ARRIVAL_DATE, ';
  END IF;

  IF     p_user_in_rec.PLANNED_DEPARTURE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.PLANNED_DEPARTURE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.PLANNED_DEPARTURE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'PLANNED_DEPARTURE_DATE, ';
  END IF;

  IF     p_user_in_rec.ACTUAL_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.ACTUAL_ARRIVAL_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.ACTUAL_ARRIVAL_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'ACTUAL_ARRIVAL_DATE, ';
  END IF;

  IF     p_user_in_rec.ACTUAL_DEPARTURE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.ACTUAL_DEPARTURE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.ACTUAL_DEPARTURE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'ACTUAL_DEPARTURE_DATE, ';
  END IF;

  IF     p_user_in_rec.DEPARTURE_GROSS_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DEPARTURE_GROSS_WEIGHT,-99) <> NVL(p_out_rec.DEPARTURE_GROSS_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'DEPARTURE_GROSS_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.DEPARTURE_NET_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DEPARTURE_NET_WEIGHT,-99) <> NVL(p_out_rec.DEPARTURE_NET_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'DEPARTURE_NET_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.WEIGHT_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WEIGHT_UOM_CODE,'!!!') <> NVL(p_out_rec.WEIGHT_UOM_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'WEIGHT_UOM_CODE, ';
  END IF;

  IF     p_user_in_rec.DEPARTURE_VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DEPARTURE_VOLUME,-99) <> NVL(p_out_rec.DEPARTURE_VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'DEPARTURE_VOLUME, ';
  END IF;

  IF     p_user_in_rec.VOLUME_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.VOLUME_UOM_CODE,'!!!') <> NVL(p_out_rec.VOLUME_UOM_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'VOLUME_UOM_CODE, ';
  END IF;

  IF     p_user_in_rec.DEPARTURE_SEAL_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.DEPARTURE_SEAL_CODE,'!!!') <> NVL(p_out_rec.DEPARTURE_SEAL_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'DEPARTURE_SEAL_CODE, ';
  END IF;

  IF     p_user_in_rec.DEPARTURE_FILL_PERCENT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DEPARTURE_FILL_PERCENT,-99) <> NVL(p_out_rec.DEPARTURE_FILL_PERCENT,-99)
  THEN
       l_attributes := l_attributes || 'DEPARTURE_FILL_PERCENT, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE1,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE2,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE3,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE4,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE5,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE6,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE7,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE8,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE9,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE10,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE11,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE12,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE13,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE14,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE15,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE15, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE1,'!!!') <> NVL(p_out_rec.ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE2,'!!!') <> NVL(p_out_rec.ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE3,'!!!') <> NVL(p_out_rec.ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE4,'!!!') <> NVL(p_out_rec.ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE5,'!!!') <> NVL(p_out_rec.ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE6,'!!!') <> NVL(p_out_rec.ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE7,'!!!') <> NVL(p_out_rec.ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE8,'!!!') <> NVL(p_out_rec.ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE9,'!!!') <> NVL(p_out_rec.ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE10,'!!!') <> NVL(p_out_rec.ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE11,'!!!') <> NVL(p_out_rec.ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE12,'!!!') <> NVL(p_out_rec.ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE13,'!!!') <> NVL(p_out_rec.ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE14,'!!!') <> NVL(p_out_rec.ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE15,'!!!') <> NVL(p_out_rec.ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE15, ';
  END IF;

  /**
  -- Bug 3613650
  -- Need not compare against WHO columns
  IF     p_user_in_rec.CREATION_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CREATION_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CREATION_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CREATION_DATE, ';
  END IF;

  IF     p_user_in_rec.CREATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CREATED_BY,-99) <> NVL(p_out_rec.CREATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'CREATED_BY, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LAST_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LAST_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATED_BY,-99) <> NVL(p_out_rec.LAST_UPDATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATED_BY, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_LOGIN <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATE_LOGIN,-99) <> NVL(p_out_rec.LAST_UPDATE_LOGIN,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_LOGIN, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_APPLICATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_APPLICATION_ID,-99) <> NVL(p_out_rec.PROGRAM_APPLICATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_APPLICATION_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_ID,-99) <> NVL(p_out_rec.PROGRAM_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'PROGRAM_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.REQUEST_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.REQUEST_ID,-99) <> NVL(p_out_rec.REQUEST_ID,-99)
  THEN
       l_attributes := l_attributes || 'REQUEST_ID, ';
  END IF;

bug 3613650 */

  IF     p_user_in_rec.WSH_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.WSH_LOCATION_ID,-99) <> NVL(p_out_rec.WSH_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'WSH_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.TRACKING_DRILLDOWN_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TRACKING_DRILLDOWN_FLAG,'!!!') <> NVL(p_out_rec.TRACKING_DRILLDOWN_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'TRACKING_DRILLDOWN_FLAG, ';
  END IF;

  IF     p_user_in_rec.TRACKING_REMARKS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TRACKING_REMARKS,'!!!') <> NVL(p_out_rec.TRACKING_REMARKS,'!!!')
  THEN
       l_attributes := l_attributes || 'TRACKING_REMARKS, ';
  END IF;

  IF     p_user_in_rec.CARRIER_EST_DEPARTURE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CARRIER_EST_DEPARTURE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CARRIER_EST_DEPARTURE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CARRIER_EST_DEPARTURE_DATE, ';
  END IF;

  IF     p_user_in_rec.CARRIER_EST_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CARRIER_EST_ARRIVAL_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CARRIER_EST_ARRIVAL_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CARRIER_EST_ARRIVAL_DATE, ';
  END IF;

  IF     p_user_in_rec.LOADING_START_DATETIME <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LOADING_START_DATETIME,TO_DATE('2','j')) <> NVL(p_out_rec.LOADING_START_DATETIME,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LOADING_START_DATETIME, ';
  END IF;

  IF     p_user_in_rec.LOADING_END_DATETIME <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LOADING_END_DATETIME,TO_DATE('2','j')) <> NVL(p_out_rec.LOADING_END_DATETIME,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LOADING_END_DATETIME, ';
  END IF;

  IF     p_user_in_rec.UNLOADING_START_DATETIME <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.UNLOADING_START_DATETIME,TO_DATE('2','j')) <> NVL(p_out_rec.UNLOADING_START_DATETIME,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'UNLOADING_START_DATETIME, ';
  END IF;

  IF     p_user_in_rec.UNLOADING_END_DATETIME <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.UNLOADING_END_DATETIME,TO_DATE('2','j')) <> NVL(p_out_rec.UNLOADING_END_DATETIME,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'UNLOADING_END_DATETIME, ';
  END IF;

  IF     p_user_in_rec.ROWID <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ROWID,'!!!') <> NVL(p_out_rec.ROWID,'!!!')
  THEN
       l_attributes := l_attributes || 'ROWID, ';
  END IF;

  IF     p_user_in_rec.TRIP_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TRIP_NAME,'!!!') <> NVL(p_out_rec.TRIP_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'TRIP_NAME, ';
  END IF;

  IF     p_user_in_rec.STOP_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.STOP_LOCATION_CODE,'!!!') <> NVL(p_out_rec.STOP_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'STOP_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.WEIGHT_UOM_DESC <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WEIGHT_UOM_DESC,'!!!') <> NVL(p_out_rec.WEIGHT_UOM_DESC,'!!!')
  THEN
       l_attributes := l_attributes || 'WEIGHT_UOM_DESC, ';
  END IF;

  IF     p_user_in_rec.VOLUME_UOM_DESC <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.VOLUME_UOM_DESC,'!!!') <> NVL(p_out_rec.VOLUME_UOM_DESC,'!!!')
  THEN
       l_attributes := l_attributes || 'VOLUME_UOM_DESC, ';
  END IF;

  IF     p_user_in_rec.LOCK_STOP_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LOCK_STOP_ID,-99) <> NVL(p_out_rec.LOCK_STOP_ID,-99)
  THEN
       l_attributes := l_attributes || 'LOCK_STOP_ID, ';
  END IF;

  IF     p_user_in_rec.PENDING_INTERFACE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PENDING_INTERFACE_FLAG,'!!!') <> NVL(p_out_rec.PENDING_INTERFACE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'PENDING_INTERFACE_FLAG, ';
  END IF;

  IF     p_user_in_rec.TRANSACTION_HEADER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TRANSACTION_HEADER_ID,-99) <> NVL(p_out_rec.TRANSACTION_HEADER_ID,-99)
  THEN
       l_attributes := l_attributes || 'TRANSACTION_HEADER_ID, ';
  END IF;

  IF     p_user_in_rec.SHIPMENTS_TYPE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPMENTS_TYPE_FLAG,'!!!') <> NVL(p_out_rec.SHIPMENTS_TYPE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPMENTS_TYPE_FLAG, ';
  END IF;

  IF     p_user_in_rec.WV_FROZEN_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WV_FROZEN_FLAG,'!!!') <> NVL(p_out_rec.WV_FROZEN_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'WV_FROZEN_FLAG, ';
  END IF;

  IF     p_user_in_rec.WKEND_LAYOVER_STOPS <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.WKEND_LAYOVER_STOPS,-99) <> NVL(p_out_rec.WKEND_LAYOVER_STOPS,-99)
  THEN
       l_attributes := l_attributes || 'WKEND_LAYOVER_STOPS, ';
  END IF;

  IF     p_user_in_rec.WKDAY_LAYOVER_STOPS <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.WKDAY_LAYOVER_STOPS,-99) <> NVL(p_out_rec.WKDAY_LAYOVER_STOPS,-99)
  THEN
       l_attributes := l_attributes || 'WKDAY_LAYOVER_STOPS, ';
  END IF;

  IF     p_user_in_rec.TP_STOP_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TP_STOP_ID,-99) <> NVL(p_out_rec.TP_STOP_ID,-99)
  THEN
       l_attributes := l_attributes || 'TP_STOP_ID, ';
  END IF;

  IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_attributes',l_attributes);
       WSH_DEBUG_SV.log(l_module_name,'length(l_attributes)',length(l_attributes));
  END IF;


  IF l_attributes IS NULL    THEN
     --no message to be shown to the user
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  ELSE
     Wsh_Utilities.process_message(
                                    p_entity => 'STOP',
                                    p_entity_name => p_out_rec.STOP_ID,
                                    p_attributes => l_attributes,
                                    x_return_status => l_return_status
				  );

     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
     THEN
       x_return_status := l_return_status;
       IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'Error returned by wsh_utilities.process_message',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         wsh_debug_sv.pop(l_module_name);
       END IF;
       return;
     ELSE
       x_return_status := wsh_util_core.G_RET_STS_WARNING;
     END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END user_non_updatable_columns;


END WSH_TRIP_STOPS_VALIDATIONS;

/
