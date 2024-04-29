--------------------------------------------------------
--  DDL for Package Body FTE_WSH_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_WSH_TRIPS_PVT" AS
/* $Header: FTEFWTHB.pls 115.11 2002/12/03 21:48:40 hbhagava noship $ */


procedure set_return_status
(
	p_return_status IN VARCHAR2,
	x_return_status IN OUT NOCOPY VARCHAR2
) is
begin

  if (p_return_status = null or p_return_status = FND_API.G_MISS_CHAR) then
    return;
  end if;

  if (p_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	and p_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
	and p_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	and p_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) then
    return;
  end if;

  if (x_return_status = null or x_return_status = FND_API.G_MISS_CHAR) then
    x_return_status := p_return_status;
    return;
  end if;

  if (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	or x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) then
    return;
  end if;

  if ((x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
	or x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
      and (p_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	or p_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) then
    x_return_status := p_return_status;
    return;
  end if;

  if (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
      and p_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) then
    x_return_status := p_return_status;
    return;
  end if;
end set_return_status;

--
--  Procedure:          Validate_PK Private
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			x_return_status	return_status
--  Description:        This procedure will validate the primary key
--

PROCEDURE Validate_PK
(
	p_fte_trip_id	     	IN	NUMBER,
	p_wsh_trip_id	     	IN	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  CURSOR check_fte_trip_id (v_trip_id   NUMBER) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE fte_trip_id = v_trip_id;

  CURSOR check_wsh_trip_id (v_trip_id   NUMBER) IS
  SELECT trip_id FROM wsh_trips
  WHERE trip_id = v_trip_id;

  invalid_fte_trip_id EXCEPTION;
  invalid_wsh_trip_id EXCEPTION;

  l_number NUMBER;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --validate fte_trip_id

  OPEN check_fte_trip_id(p_fte_trip_id);
  FETCH check_fte_trip_id INTO l_number;

  IF (check_fte_trip_id%NOTFOUND) THEN
    CLOSE check_fte_trip_id;
    RAISE invalid_fte_trip_id;
  END IF;

  CLOSE check_fte_trip_id;

  --validate wsh_trip_id

  OPEN check_wsh_trip_id(p_wsh_trip_id);
  FETCH check_wsh_trip_id INTO l_number;

  IF (check_wsh_trip_id%NOTFOUND) THEN
    CLOSE check_wsh_trip_id;
    RAISE invalid_wsh_trip_id;
  END IF;

  CLOSE check_wsh_trip_id;

  EXCEPTION
    WHEN invalid_fte_trip_id THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_NO_TRIP_ID');
      FND_MESSAGE.SET_TOKEN('TRIP_ID',p_fte_trip_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN invalid_wsh_trip_id THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_NO_TRIP_SEGMENT_ID');
      FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID',p_wsh_trip_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Validate_PK');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

END Validate_PK;

--
--  Procedure:          Validate_Sequence Private
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			p_sequence
--			x_return_status	return_status
--  Description:        This procedure will validate the sequence is unique
--			for the same fte_trip_id and wsh_trip_id
--			assumes PK is valid.
--

PROCEDURE Validate_Sequence
(
	p_fte_trip_id	     	IN	NUMBER,
	p_sequence	     	IN	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  CURSOR check_sequence (v_fte_trip_id NUMBER, v_sequence NUMBER) IS
  SELECT fte_trip_id FROM fte_wsh_trips
  WHERE fte_trip_id = v_fte_trip_id and sequence_number = v_sequence;

  empty_sequence EXCEPTION;
  duplicate_sequence EXCEPTION;

  l_number NUMBER;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --validate sequence

  if (p_sequence = null or p_sequence = FND_API.G_MISS_NUM) then
    RAISE empty_sequence;
  end if;

  OPEN check_sequence(p_fte_trip_id, p_sequence);
  FETCH check_sequence INTO l_number;

  IF (check_sequence%FOUND) THEN
    CLOSE check_sequence;
    RAISE duplicate_sequence;
  END IF;

  CLOSE check_sequence;

  EXCEPTION
    WHEN empty_sequence THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_SEQUENCE_MISSING');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN duplicate_sequence THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_SEQUENCE_DUP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Validate_Sequence');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

END Validate_Sequence;

FUNCTION Get_Fte_Trip_Status
(
	p_trip_id		IN	NUMBER
)
RETURN VARCHAR2
IS

  CURSOR get_status IS
  SELECT status_code
  FROM   fte_trips
  WHERE  fte_trip_id = p_trip_id;

  x_status VARCHAR2(30);

  others EXCEPTION;

BEGIN

     IF (p_trip_id IS NULL) THEN
        raise others;
     END IF;

     OPEN  get_status;
     FETCH get_status INTO x_status;
     CLOSE get_status;

     IF (x_status IS NULL) THEN
         FND_MESSAGE.SET_NAME('FTE','FTE_NO_TRIP_ID');
         FND_MESSAGE.SET_TOKEN('TRIP_ID',p_trip_id);
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    RETURN null;
     END IF;

 	RETURN x_status;

     EXCEPTION

        WHEN others THEN
	      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.GET_FTE_TRIP_STATUS');
		 RETURN null;

END Get_Fte_Trip_Status;

--
--  Procedure:          Validate_Trip
--  Parameters: 	p_trip_info	Trip Record info
--              	p_action_code   'CREATE' or 'UPDATE'
--			x_return_status	return_status
--  Description:        This procedure will validate a fte_wsh_trip.
--

PROCEDURE Validate_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	p_action_code		IN 	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  l_status VARCHAR2(30);
  l_previous_segment_id NUMBER;
  l_previous_sequence_number NUMBER;
  l_next_segment_id NUMBER;
  l_next_sequence_number NUMBER;
  l_trip_name VARCHAR2(30);
  l_trip_segment_name VARCHAR2(30);
  l_first_stop_location_id NUMBER;
  l_last_stop_location_id NUMBER;
  l_stop_count NUMBER;
  l_connected BOOLEAN;
  l_fte_trip_name VARCHAR2(30);
  l_wsh_trip_name VARCHAR2(30);
  l_return_status VARCHAR2(1);

	--l_msg_count NUMBER;
	--l_msg_data VARCHAR2(32767);

  add_segment_to_closed_trip EXCEPTION;
  add_segment_to_in_transit_trip EXCEPTION;
  update_sequence_for_non_open EXCEPTION;
  segment_less_than_2_stops EXCEPTION;

BEGIN

      wsh_debug_sv.dpush (c_sdebug, 'Validate_Trip');

      wsh_debug_sv.dlog (c_debug,'FteTripId ',p_trip_info.fte_trip_id);
      wsh_debug_sv.dlog (c_debug,'WshTripId ',p_trip_info.wsh_trip_id);
      wsh_debug_sv.dlog (c_debug,'SequenceNumber ',p_trip_info.sequence_number);
      wsh_debug_sv.dlog (c_debug,'ActionCode ',p_action_code);

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      wsh_debug_sv.dlog (c_debug,'about to get segment name...');

    fte_mls_util.get_trip_segment_name
		(
		  p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	          x_trip_segment_name => l_wsh_trip_name,
	          x_return_status => x_return_status
		);

      wsh_debug_sv.dlog (c_debug,'segment name',l_wsh_trip_name);
      wsh_debug_sv.dlog (c_debug,'x_return_status',x_return_status);

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'about to get trip name...');

    fte_trips_pvt.get_trip_name
		(
		  p_trip_id => p_trip_info.FTE_TRIP_ID,
	          x_trip_name => l_fte_trip_name,
	          x_return_status => x_return_status
		);

      wsh_debug_sv.dlog (c_debug,'trip name',l_fte_trip_name);
      wsh_debug_sv.dlog (c_debug,'x_return_status',x_return_status);

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'about to validate PK...');

    Validate_PK
    (
	p_trip_info.FTE_TRIP_ID,
	p_trip_info.WSH_TRIP_ID,
	x_return_status
    );

      wsh_debug_sv.dlog (c_debug,'x_return_status',x_return_status);

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'about to validate sequence...');

    Validate_Sequence
    (
	p_trip_info.FTE_TRIP_ID,
	p_trip_info.SEQUENCE_NUMBER,
	x_return_status
    );

      wsh_debug_sv.dlog (c_debug,'x_return_status',x_return_status);

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'about to validate status...');

  -- Segment can only be added to open trip, (insert)
  -- Segment's sequence can only be added to open trip (upadte)
  l_status := Get_Fte_Trip_Status(p_trip_info.FTE_TRIP_ID);

  if (p_action_code = 'CREATE') then

    -- segment can not be added to closed trip
    if (l_status = 'CL') then
      RAISE add_segment_to_closed_trip;
    end if;

    -- segment can only be added to the end of in-transit trip
    if (l_status = 'IT') then
      fte_mls_util.get_next_segment_id
      (
	p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	p_sequence_number => p_trip_info.SEQUENCE_NUMBER,
	p_trip_id => p_trip_info.FTE_TRIP_ID,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_next_segment_id => l_next_segment_id,
	x_return_status => l_return_status
      );

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
        RETURN;
      END IF;

      if (l_next_segment_id is NOT null) then
	RAISE add_segment_to_in_transit_trip;
      end if;

    end if;

  elsif (p_action_code = 'UPDATE') then

    -- sequence can only be updated for open trip
    if (l_status <> 'OP') then
      RAISE update_sequence_for_non_open;
    end if;

  end if; -- p_action_code = 'CREATE' or 'UPDATE'

      wsh_debug_sv.dlog (c_debug,'x_return_status',x_return_status);

      wsh_debug_sv.dlog (c_debug,'about to validate 2 stops...');

  --check at least two stops for the segment
  select count(*) into l_stop_count
  from wsh_trip_stops
  where trip_id = p_trip_info.WSH_TRIP_ID;

      wsh_debug_sv.dlog (c_debug,'wsh_trip_id',p_trip_info.WSH_TRIP_ID);
      wsh_debug_sv.dlog (c_debug,'stop count',l_stop_count);

  if (l_stop_count < 2) then
	update fte_trips
	  set validation_required = 'Y'
	  where fte_trip_id = p_trip_info.FTE_TRIP_ID;

	-- give warning
      wsh_debug_sv.dlog (c_debug,'about to set the warning message...');

      	FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_NO_TWO_STOPS');
      	FND_MESSAGE.SET_TOKEN('WSH_TRIP_NAME',l_wsh_trip_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      	WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);

	return;
  end if;

      wsh_debug_sv.dlog (c_debug,'about to validate connections...');

  --check connections

  l_connected := true;

  if (p_action_code = 'CREATE') then

      wsh_debug_sv.dlog (c_debug,'about to get_previous_segment_id...');

    fte_mls_util.get_previous_segment_id
    (
	p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	p_sequence_number => p_trip_info.SEQUENCE_NUMBER,
	p_trip_id => p_trip_info.FTE_TRIP_ID,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_previous_segment_id => l_previous_segment_id,
	x_return_status => l_return_status
    );

      wsh_debug_sv.dlog (c_debug,'previous segment id', l_previous_segment_id);
      wsh_debug_sv.dlog (c_debug,'return status from get_previous_segment_id', l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

    if (l_previous_segment_id is NOT null) then

      select sequence_number into l_previous_sequence_number
      from fte_wsh_trips
      where fte_trip_id = p_trip_info.FTE_TRIP_ID
        and wsh_trip_id = l_previous_segment_id;

      wsh_debug_sv.dlog (c_debug,'about to get_first_stop_location_id...');

      fte_mls_util.get_first_stop_location_id
      (
	p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	x_trip_segment_name => l_trip_segment_name,
	x_first_stop_location_id => l_first_stop_location_id,
	x_return_status => l_return_status
      );

      wsh_debug_sv.dlog (c_debug,'first stop loc id',l_first_stop_location_id);
      wsh_debug_sv.dlog (c_debug,'return status from get_first_stop_location_id',l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
        RETURN;
      END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

      wsh_debug_sv.dlog (c_debug,'about to check_previous_segment...');

      fte_mls_util.check_previous_segment
      (
	p_trip_id => p_trip_info.FTE_TRIP_ID,
	p_trip_segment_id => l_previous_segment_id,
	p_sequence_number => l_previous_sequence_number,
	p_first_stop_location_id => l_first_stop_location_id,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_connected => l_connected,
	x_return_status => l_return_status
      );

      wsh_debug_sv.dlog (c_debug,'l_connected',l_connected);
      wsh_debug_sv.dlog (c_debug,'return_status from check_previous_segment',l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
        RETURN;
      END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

      if (l_connected is null or l_connected = false) then

      wsh_debug_sv.dlog (c_debug,'about to mark trip invalid...');

	update fte_trips
	  set validation_required = 'Y'
	  where fte_trip_id = p_trip_info.FTE_TRIP_ID;

      wsh_debug_sv.dlog (c_debug,'about to set warning message...');

	-- give warning
      	FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_PREV_CONNECT_ERROR');
      	FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_fte_trip_name);
      	FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',l_wsh_trip_name);
      	WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      end if;

    end if; -- l_previous_segment_id is NOT null

      wsh_debug_sv.dlog (c_debug,'about to get_next_segment_id...');

    fte_mls_util.get_next_segment_id
    (
	p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	p_sequence_number => p_trip_info.SEQUENCE_NUMBER,
	p_trip_id => p_trip_info.FTE_TRIP_ID,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_next_segment_id => l_next_segment_id,
	x_return_status => l_return_status
    );

      wsh_debug_sv.dlog (c_debug,'next segment id', l_next_segment_id);
      wsh_debug_sv.dlog (c_debug,'return status from get_next_segment_id', l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
      RETURN;
    END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

    if (l_next_segment_id is NOT null) then

      select sequence_number into l_next_sequence_number
      from fte_wsh_trips
      where fte_trip_id = p_trip_info.FTE_TRIP_ID
        and wsh_trip_id = l_next_segment_id;

      wsh_debug_sv.dlog (c_debug,'about to get_last_stop_location_id...');

      fte_mls_util.get_last_stop_location_id
      (
	p_trip_segment_id => p_trip_info.WSH_TRIP_ID,
	x_trip_segment_name => l_trip_segment_name,
	x_last_stop_location_id => l_last_stop_location_id,
	x_return_status => l_return_status
      );

      wsh_debug_sv.dlog (c_debug,'last stop loc id',l_last_stop_location_id);
      wsh_debug_sv.dlog (c_debug,'return status from get_last_stop_location_id',l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
        RETURN;
      END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

      wsh_debug_sv.dlog (c_debug,'about to check_next_segment...');

      fte_mls_util.check_next_segment
      (
	p_trip_id => p_trip_info.FTE_TRIP_ID,
	p_trip_segment_id => l_next_segment_id,
	p_sequence_number => l_next_sequence_number,
	p_last_stop_location_id => l_last_stop_location_id,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_connected => l_connected,
	x_return_status => l_return_status
      );

      wsh_debug_sv.dlog (c_debug,'l_connected',l_connected);
      wsh_debug_sv.dlog (c_debug,'return_status from check_next_segment',l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
        RETURN;
      END IF;

      wsh_debug_sv.dlog (c_debug,'return status', x_return_status);

      if (l_connected is null or l_connected = false) then

      wsh_debug_sv.dlog (c_debug,'about to mark trip invalid...');

	update fte_trips
	  set validation_required = 'Y'
	  where fte_trip_id = p_trip_info.FTE_TRIP_ID;

      wsh_debug_sv.dlog (c_debug,'about to set warning message...');

	-- give warning
      	FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_NEXT_CONNECT_ERROR');
      	FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_fte_trip_name);
      	FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',l_wsh_trip_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      end if;

    end if; -- l_next_segment_id is NOT null

  end if; -- p_action_code = 'CREATE'

      wsh_debug_sv.dlog (c_debug,'validate trip done');

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  EXCEPTION
    WHEN add_segment_to_closed_trip THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_INVALID_TRIP_STATUS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

    WHEN add_segment_to_in_transit_trip THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_INVALID_TRIP_STATUS2');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

    WHEN update_sequence_for_non_open THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_INVALID_TRIP_STATUS3');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Validate_Trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

END Validate_Trip;

--
--  Procedure:          Create_Trip
--  Parameters: 	p_trip_info	Trip Record info
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Create_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS
BEGIN

      wsh_debug_sv.dpush (c_sdebug, 'Create_Trip');

      wsh_debug_sv.dlog (c_debug,'FteTripId ',p_trip_info.fte_trip_id);
      wsh_debug_sv.dlog (c_debug,'WshTripId ',p_trip_info.wsh_trip_id);
      wsh_debug_sv.dlog (c_debug,'SequenceNumber ',p_trip_info.sequence_number);

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      wsh_debug_sv.dlog (c_debug,'about to validate trip...');

  Validate_Trip(p_trip_info, 'CREATE', x_return_status);
  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
    AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    RETURN;
  END IF;

      wsh_debug_sv.dlog (c_debug,'about to insert into fte_wsh_trips table...');

  insert into fte_wsh_trips
  (
 FTE_TRIP_ID         ,
 WSH_TRIP_ID         ,
 SEQUENCE_NUMBER     ,
 CREATION_DATE       ,
 CREATED_BY          ,
 LAST_UPDATE_DATE    ,
 LAST_UPDATED_BY     ,
 LAST_UPDATE_LOGIN   ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_UPDATE_DATE    ,
 REQUEST_ID             ,
 ATTRIBUTE_CATEGORY     ,
 ATTRIBUTE1             ,
 ATTRIBUTE2             ,
 ATTRIBUTE3             ,
 ATTRIBUTE4             ,
 ATTRIBUTE5             ,
 ATTRIBUTE6             ,
 ATTRIBUTE7             ,
 ATTRIBUTE8             ,
 ATTRIBUTE9             ,
 ATTRIBUTE10            ,
 ATTRIBUTE11            ,
 ATTRIBUTE12            ,
 ATTRIBUTE13            ,
 ATTRIBUTE14            ,
 ATTRIBUTE15
  )
  values
  (
    decode(p_trip_info.FTE_TRIP_ID, FND_API.G_MISS_NUM, NULL, p_trip_info.FTE_TRIP_ID),
    decode(p_trip_info.WSH_TRIP_ID, FND_API.G_MISS_NUM, NULL, p_trip_info.WSH_TRIP_ID),
    decode(p_trip_info.SEQUENCE_NUMBER, FND_API.G_MISS_NUM, NULL, p_trip_info.SEQUENCE_NUMBER),
    decode(p_trip_info.creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    decode(p_trip_info.created_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.created_by),
    decode(p_trip_info.last_update_date,FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    decode(p_trip_info.last_updated_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.last_updated_by),
    decode(p_trip_info.last_update_login,FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID, NULL, FND_GLOBAL.LOGIN_ID, p_trip_info.last_update_login),
    decode(p_trip_info.program_application_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_application_id),
    decode(p_trip_info.program_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_id),
    decode(p_trip_info.program_update_date, FND_API.G_MISS_DATE, NULL, p_trip_info.program_update_date),
    decode(p_trip_info.request_id, FND_API.G_MISS_NUM, NULL, p_trip_info.request_id),
    decode(p_trip_info.attribute_category, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute_category),
    decode(p_trip_info.attribute1, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute1),
    decode(p_trip_info.attribute2, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute2),
    decode(p_trip_info.attribute3, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute3),
    decode(p_trip_info.attribute4, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute4),
    decode(p_trip_info.attribute5, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute5),
    decode(p_trip_info.attribute6, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute6),
    decode(p_trip_info.attribute7, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute7),
    decode(p_trip_info.attribute8, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute8),
    decode(p_trip_info.attribute9, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute9),
    decode(p_trip_info.attribute10, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute10),
    decode(p_trip_info.attribute11, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute11),
    decode(p_trip_info.attribute12, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute12),
    decode(p_trip_info.attribute13, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute13),
    decode(p_trip_info.attribute14, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute14),
    decode(p_trip_info.attribute15, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute15)
  );

  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

      wsh_debug_sv.dlog (c_debug,'about to mark trip invalid...');

    --mark trip as invalid
    update fte_trips
      set validation_required = 'Y'
      where fte_trip_id = p_trip_info.FTE_TRIP_ID;
  END IF;

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  EXCEPTION
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Create_Trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

END Create_Trip;

--
--  Procedure:          Update_Trip
--  Parameters: 	p_trip_info	Trip Record info
-- 			p_validate_flag	'Y' validate before update
--			x_return_status	return_status
--  Description:        This procedure will update a fte_wsh_trip.
--

PROCEDURE Update_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	p_validate_flag		IN	VARCHAR2 DEFAULT 'Y',
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  no_trip_found EXCEPTION;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  if (p_validate_flag = 'Y') then

    Validate_Trip(p_trip_info, 'UPDATE', x_return_status);
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      RETURN;
    END IF;

  end if;

  update fte_wsh_trips set
    SEQUENCE_NUMBER = decode(p_trip_info.SEQUENCE_NUMBER, FND_API.G_MISS_NUM, NULL, p_trip_info.SEQUENCE_NUMBER),
    creation_date = decode(p_trip_info.creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    created_by = decode(p_trip_info.created_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.created_by),
    last_update_date = decode(p_trip_info.last_update_date,FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    last_updated_by = decode(p_trip_info.last_updated_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.last_updated_by),
    last_update_login = decode(p_trip_info.last_update_login,FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID, NULL, FND_GLOBAL.LOGIN_ID, p_trip_info.last_update_login),
    program_application_id = decode(p_trip_info.program_application_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_application_id),
    program_id = decode(p_trip_info.program_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_id),
    program_update_date = decode(p_trip_info.program_update_date, FND_API.G_MISS_DATE, NULL, p_trip_info.program_update_date),
    request_id = decode(p_trip_info.request_id, FND_API.G_MISS_NUM, NULL, p_trip_info.request_id),
    attribute_category = decode(p_trip_info.attribute_category, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute_category),
    attribute1 = decode(p_trip_info.attribute1, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute1),
    attribute2 = decode(p_trip_info.attribute2, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute2),
    attribute3 = decode(p_trip_info.attribute3, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute3),
    attribute4 = decode(p_trip_info.attribute4, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute4),
    attribute5 = decode(p_trip_info.attribute5, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute5),
    attribute6 = decode(p_trip_info.attribute6, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute6),
    attribute7 = decode(p_trip_info.attribute7, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute7),
    attribute8 = decode(p_trip_info.attribute8, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute8),
    attribute9 = decode(p_trip_info.attribute9, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute9),
    attribute10 = decode(p_trip_info.attribute10, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute10),
    attribute11 = decode(p_trip_info.attribute11, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute11),
    attribute12 = decode(p_trip_info.attribute12, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute12),
    attribute13 = decode(p_trip_info.attribute13, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute13),
    attribute14 = decode(p_trip_info.attribute14, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute14),
    attribute15 = decode(p_trip_info.attribute15, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute15)
  where fte_trip_id = p_trip_info.fte_trip_id and wsh_trip_id = p_trip_info.wsh_trip_id;

  if (SQL%NOTFOUND) then
    RAISE no_trip_found;
  end if;

  EXCEPTION
    WHEN no_trip_found THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_NO_TRIP_SEGMENT_ID');
      FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID',p_trip_info.WSH_TRIP_ID);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Update_Trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

END Update_Trip;

--
--  Procedure:          Delete_Trip
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Validate_Trip_For_Delete
(
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_fte_trip_id	     	IN	NUMBER,
	p_wsh_trip_id	     	IN	NUMBER,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  l_status VARCHAR2(30);
  l_previous_segment_id NUMBER;
  l_next_segment_id NUMBER;
  l_sequence_number NUMBER;
  l_trip_name VARCHAR2(30);
  l_trip_segment_name VARCHAR2(30);
  l_fte_trip_name VARCHAR2(30);
  l_wsh_trip_name VARCHAR2(30);
  l_return_status VARCHAR2(1);

  invalid_trip_status EXCEPTION;

BEGIN

	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    fte_mls_util.get_trip_segment_name
		(
		  p_trip_segment_id => p_wsh_trip_id,
	          x_trip_segment_name => l_wsh_trip_name,
	          x_return_status => x_return_status
		);
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

    fte_trips_pvt.get_trip_name
		(
		  p_trip_id => p_fte_trip_id,
	          x_trip_name => l_fte_trip_name,
	          x_return_status => x_return_status
		);
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;

    Validate_PK
    (
	p_fte_trip_id,
	p_wsh_trip_id,
	x_return_status
    );

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
      RETURN;
    END IF;

  -- Segment can only be removed from open trip, (delete)
  l_status := Get_Fte_Trip_Status(p_fte_trip_id);
  if (l_status <> 'OP') then
    RAISE invalid_trip_status;
  end if;

  -- if removing from middle, giving Warning

    select sequence_number into l_sequence_number
    from fte_wsh_trips
    where fte_trip_id = p_fte_trip_id and wsh_trip_id = p_wsh_trip_id;

    fte_mls_util.get_previous_segment_id
    (
	p_trip_segment_id => p_wsh_trip_id,
	p_sequence_number => l_sequence_number,
	p_trip_id => p_fte_trip_id,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_previous_segment_id => l_previous_segment_id,
	x_return_status => l_return_status
    );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
      RETURN;
    END IF;

    fte_mls_util.get_next_segment_id
    (
	p_trip_segment_id => p_wsh_trip_id,
	p_sequence_number => l_sequence_number,
	p_trip_id => p_fte_trip_id,
	x_trip_name => l_trip_name,
	x_trip_segment_name => l_trip_segment_name,
	x_next_segment_id => l_next_segment_id,
	x_return_status => l_return_status
    );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	set_return_status
	(
	  l_return_status,
	  x_return_status
	);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
      RETURN;
    END IF;

    if ((l_next_segment_id is NOT null) AND
	(l_previous_segment_id is NOT null)) then

	update fte_trips
	  set validation_required = 'Y'
	  where fte_trip_id = p_fte_trip_id;

	-- give warning
      	FND_MESSAGE.SET_NAME('FTE', 'FTE_INVALID_CONNECT_SEGMENT');
      	FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_fte_trip_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

    end if;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

  EXCEPTION
    WHEN invalid_trip_status THEN
      -- cannot add/remove segments from trip with this status
      FND_MESSAGE.SET_NAME('FTE', 'FTE_INVALID_TRIP_STATUS3');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Validate_Trip_For_Delete');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

END Validate_Trip_For_Delete;

--
--  Procedure:          Delete_Trip
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Delete_Trip
(
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_fte_trip_id	     	IN	NUMBER,
	p_wsh_trip_id	     	IN	NUMBER,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  no_trip_found EXCEPTION;

BEGIN

      wsh_debug_sv.start_debug ('FteWshTrip-' || p_fte_trip_id || '-' || p_wsh_trip_id);
      wsh_debug_sv.dpush (c_sdebug, 'Delete_Trip');

	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  Validate_Trip_For_Delete
	(
	p_fte_trip_id => p_fte_trip_id,
	p_wsh_trip_id => p_wsh_trip_id,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data,
	x_return_status => x_return_status);

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
    AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
    RETURN;
  END IF;

  delete from fte_wsh_trips
  where fte_trip_id = p_fte_trip_id and wsh_trip_id = p_wsh_trip_id;

  if (SQL%NOTFOUND) then
    RAISE no_trip_found;
  end if;

  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    --mark trip as invalid
    update fte_trips
      set validation_required = 'Y'
      where fte_trip_id = p_fte_trip_id;
  END IF;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  EXCEPTION
    WHEN no_trip_found THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_NO_TRIP_SEGMENT_ID');
      FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID',p_wsh_trip_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Delete_Trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

END Delete_Trip;

--
--  Procedure:          Create_Update_Trip
--  Description:        Wrapper around Create_Trip and Update_Trip
-- 			depends on the p_action_code 'CREATE' or 'UPDATE'
--

PROCEDURE Validate_Trip_Wrapper
(
 pp_FTE_TRIP_ID			IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_WSH_TRIP_ID                 IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_SEQUENCE_NUMBER             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_CREATION_DATE               IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_CREATED_BY                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_DATE            IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_LAST_UPDATED_BY             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_LOGIN           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_APPLICATION_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_UPDATE_DATE         IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_REQUEST_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_ATTRIBUTE_CATEGORY          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE1                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE2                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE3                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE4                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE5                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE6                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE7                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE8                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE9                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE10                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE11                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE12                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE13                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE14                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE15                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_action_code		IN 	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  p_trip_info  fte_wsh_trip_rec_type;

  invalid_action EXCEPTION;

BEGIN

	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- populate trip record
 p_trip_info.FTE_TRIP_ID		:=pp_FTE_TRIP_ID;
 p_trip_info.WSH_TRIP_ID		:=pp_WSH_TRIP_ID;
 p_trip_info.SEQUENCE_NUMBER		:=pp_SEQUENCE_NUMBER;
 p_trip_info.CREATION_DATE		:=pp_CREATION_DATE;
 p_trip_info.CREATED_BY			:=pp_CREATED_BY;
 p_trip_info.LAST_UPDATE_DATE		:=pp_LAST_UPDATE_DATE;
 p_trip_info.LAST_UPDATED_BY		:=pp_LAST_UPDATED_BY;
 p_trip_info.LAST_UPDATE_LOGIN		:=pp_LAST_UPDATE_LOGIN;
 p_trip_info.PROGRAM_APPLICATION_ID	:=pp_PROGRAM_APPLICATION_ID;
 p_trip_info.PROGRAM_ID			:=pp_PROGRAM_ID;
 p_trip_info.PROGRAM_UPDATE_DATE	:=pp_PROGRAM_UPDATE_DATE;
 p_trip_info.REQUEST_ID			:=pp_REQUEST_ID;
 p_trip_info.ATTRIBUTE_CATEGORY		:=pp_ATTRIBUTE_CATEGORY;
 p_trip_info.ATTRIBUTE1			:=pp_ATTRIBUTE1;
 p_trip_info.ATTRIBUTE2			:=pp_ATTRIBUTE2;
 p_trip_info.ATTRIBUTE3			:=pp_ATTRIBUTE3;
 p_trip_info.ATTRIBUTE4			:=pp_ATTRIBUTE4;
 p_trip_info.ATTRIBUTE5			:=pp_ATTRIBUTE5;
 p_trip_info.ATTRIBUTE6			:=pp_ATTRIBUTE6;
 p_trip_info.ATTRIBUTE7			:=pp_ATTRIBUTE7;
 p_trip_info.ATTRIBUTE8			:=pp_ATTRIBUTE8;
 p_trip_info.ATTRIBUTE9			:=pp_ATTRIBUTE9;
 p_trip_info.ATTRIBUTE10		:=pp_ATTRIBUTE10;
 p_trip_info.ATTRIBUTE11		:=pp_ATTRIBUTE11;
 p_trip_info.ATTRIBUTE12		:=pp_ATTRIBUTE12;
 p_trip_info.ATTRIBUTE13		:=pp_ATTRIBUTE13;
 p_trip_info.ATTRIBUTE14		:=pp_ATTRIBUTE14;
 p_trip_info.ATTRIBUTE15		:=pp_ATTRIBUTE15;

  -- call public API
  if (p_action_code = 'CREATE') then
    Validate_Trip
    (
	p_trip_info => p_trip_info,
	p_action_code => p_action_code,
	x_return_status => x_return_status
    );
  elsif (p_action_code = 'UPDATE') then
    Validate_Trip
    (
	p_trip_info => p_trip_info,
	p_action_code => p_action_code,
	x_return_status => x_return_status
    );
  else
    RAISE invalid_action;
  end if;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

  EXCEPTION
    WHEN invalid_action THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_WSH_TRIPS_WRAPPER_ERR1');
      FND_MESSAGE.SET_TOKEN('ACTION',p_action_code);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );
    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Validate_Trip_Wrapper');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.add_message(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

END Validate_Trip_Wrapper;

--
--  Procedure:          Create_Update_Trip_Wrapper
--  Description:        Wrapper around Create_Trip and Update_Trip
-- 			depends on the p_action_code 'CREATE' or 'UPDATE'
--

PROCEDURE Create_Update_Trip_Wrapper
(
 pp_FTE_TRIP_ID			IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_WSH_TRIP_ID                 IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_SEQUENCE_NUMBER             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_CREATION_DATE               IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_CREATED_BY                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_DATE            IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_LAST_UPDATED_BY             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_LOGIN           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_APPLICATION_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_UPDATE_DATE         IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_REQUEST_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_ATTRIBUTE_CATEGORY          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE1                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE2                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE3                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE4                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE5                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE6                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE7                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE8                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE9                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE10                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE11                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE12                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE13                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE14                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE15                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_action_code		IN 	VARCHAR2,
	p_validate_flag		IN	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  p_trip_info  fte_wsh_trip_rec_type;

  invalid_action EXCEPTION;

BEGIN

      wsh_debug_sv.start_debug ('FteWshTrip-' || pp_fte_trip_id || '-' || pp_wsh_trip_id);
      wsh_debug_sv.dpush (c_sdebug, 'Create_Update_Trip_Wrapper');

      wsh_debug_sv.dlog (c_debug,'FteTripId ',pp_fte_trip_id);
      wsh_debug_sv.dlog (c_debug,'WshTripId ',pp_wsh_trip_id);
      wsh_debug_sv.dlog (c_debug,'SequenceNumber ',pp_sequence_number);
      wsh_debug_sv.dlog (c_debug,'ActionCode ',p_action_code);
      wsh_debug_sv.dlog (c_debug,'ValidateFlag ',p_validate_flag);
	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- populate trip record
 p_trip_info.FTE_TRIP_ID		:=pp_FTE_TRIP_ID;
 p_trip_info.WSH_TRIP_ID		:=pp_WSH_TRIP_ID;
 p_trip_info.SEQUENCE_NUMBER		:=pp_SEQUENCE_NUMBER;
 p_trip_info.CREATION_DATE		:=pp_CREATION_DATE;
 p_trip_info.CREATED_BY			:=pp_CREATED_BY;
 p_trip_info.LAST_UPDATE_DATE		:=pp_LAST_UPDATE_DATE;
 p_trip_info.LAST_UPDATED_BY		:=pp_LAST_UPDATED_BY;
 p_trip_info.LAST_UPDATE_LOGIN		:=pp_LAST_UPDATE_LOGIN;
 p_trip_info.PROGRAM_APPLICATION_ID	:=pp_PROGRAM_APPLICATION_ID;
 p_trip_info.PROGRAM_ID			:=pp_PROGRAM_ID;
 p_trip_info.PROGRAM_UPDATE_DATE	:=pp_PROGRAM_UPDATE_DATE;
 p_trip_info.REQUEST_ID			:=pp_REQUEST_ID;
 p_trip_info.ATTRIBUTE_CATEGORY		:=pp_ATTRIBUTE_CATEGORY;
 p_trip_info.ATTRIBUTE1			:=pp_ATTRIBUTE1;
 p_trip_info.ATTRIBUTE2			:=pp_ATTRIBUTE2;
 p_trip_info.ATTRIBUTE3			:=pp_ATTRIBUTE3;
 p_trip_info.ATTRIBUTE4			:=pp_ATTRIBUTE4;
 p_trip_info.ATTRIBUTE5			:=pp_ATTRIBUTE5;
 p_trip_info.ATTRIBUTE6			:=pp_ATTRIBUTE6;
 p_trip_info.ATTRIBUTE7			:=pp_ATTRIBUTE7;
 p_trip_info.ATTRIBUTE8			:=pp_ATTRIBUTE8;
 p_trip_info.ATTRIBUTE9			:=pp_ATTRIBUTE9;
 p_trip_info.ATTRIBUTE10		:=pp_ATTRIBUTE10;
 p_trip_info.ATTRIBUTE11		:=pp_ATTRIBUTE11;
 p_trip_info.ATTRIBUTE12		:=pp_ATTRIBUTE12;
 p_trip_info.ATTRIBUTE13		:=pp_ATTRIBUTE13;
 p_trip_info.ATTRIBUTE14		:=pp_ATTRIBUTE14;
 p_trip_info.ATTRIBUTE15		:=pp_ATTRIBUTE15;

  -- call public API
  if (p_action_code = 'CREATE') then
    Create_Trip
    (
	p_trip_info => p_trip_info,
	x_return_status => x_return_status
    );
  elsif (p_action_code = 'UPDATE') then
    Update_Trip
    (
	p_trip_info => p_trip_info,
	p_validate_flag => p_validate_flag,
	x_return_status => x_return_status
    );
  else
    RAISE invalid_action;
  end if;

     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  EXCEPTION
    WHEN invalid_action THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_WSH_TRIPS_WRAPPER_ERR1');
      FND_MESSAGE.SET_TOKEN('ACTION',p_action_code);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

    WHEN others THEN
      wsh_util_core.default_handler('FTE_WSH_TRIPS_PUB.Create_Update_Trip_Wrapper');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.add_message(x_return_status);
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     , p_encoded => FND_API.G_FALSE
     );

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

END Create_Update_Trip_Wrapper;

END FTE_WSH_TRIPS_PVT;

/
