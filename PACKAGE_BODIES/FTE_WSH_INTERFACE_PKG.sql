--------------------------------------------------------
--  DDL for Package Body FTE_WSH_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_WSH_INTERFACE_PKG" AS
/* $Header: FTEWSHIB.pls 120.5 2005/07/28 17:07:24 nltan ship $ */
--{
    G_PREVIOUS  CONSTANT VARCHAR2(30) := 'PREVIOUS';
    G_NEXT      CONSTANT VARCHAR2(30) := 'NEXT';
    G_BOTH      CONSTANT VARCHAR2(30) := 'BOTH';
    --
    -- These constants indicate position of a stop before insert/update/delete.
    --
    G_FIRST        CONSTANT VARCHAR2(30) := 'FIRST';
    G_LAST         CONSTANT VARCHAR2(30) := 'LAST';
    G_INTERMEDIATE CONSTANT VARCHAR2(30) := 'INTERMEDIATE';
    G_NONE         CONSTANT VARCHAR2(30) := 'NONE';   -- meaningful for insert opeation
    --
    --
    TYPE stop_validation_ctrl_rec_type
    IS
    RECORD
      (
        LOCATION_LANE_CHECK       BOOLEAN DEFAULT FALSE,
        DATETIME_SCHEDULE_CHECK   BOOLEAN DEFAULT FALSE,
        SEGMENT_CONNECTED_CHECK   BOOLEAN DEFAULT FALSE,
        DLVY_IN_TRANSIT_CHECK     BOOLEAN DEFAULT FALSE
      );
    --
    --
    --
    --
    TYPE Trip_Stop_Rec_Type
    IS
    RECORD
      (
        STOP_ID                    NUMBER          DEFAULT NULL,
        STOP_LOCATION_ID           NUMBER          DEFAULT NULL,
        STATUS_CODE                VARCHAR2(30)    DEFAULT NULL,
        STOP_SEQUENCE_NUMBER       NUMBER          DEFAULT NULL,
        PLANNED_ARRIVAL_DATE       DATE            DEFAULT NULL,
        PLANNED_DEPARTURE_DATE     DATE            DEFAULT NULL,
        ACTION_TYPE                VARCHAR2(30)    DEFAULT G_ADD
      );
    --
    --
    TYPE Trip_Stop_tab_Type
    IS
    TABLE OF trip_stop_rec_type INDEX BY BINARY_INTEGER;
    --
    --
    FUNCTION get_stop_full_validn_ctrl_rec
    RETURN stop_validation_ctrl_rec_type
    IS
       l_stop_validation_ctrl_rec stop_validation_ctrl_rec_type;
    BEGIN
    --{
        l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
        l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
        l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
        l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := TRUE;
	--
	--
	RETURN(l_stop_validation_ctrl_rec);
    --}
    END get_stop_full_validn_ctrl_rec;
    --
    --
    PROCEDURE get_segment_stops
		(
	          P_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          p_current_stop_rec        IN     WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
		  p_action_type             IN     VARCHAR2,
		  x_trip_stop_tab           OUT NOCOPY trip_stop_tab_type,
	          x_current_stop_index	    OUT NOCOPY	   NUMBER,
	          x_curr_stop_old_position  OUT NOCOPY	   VARCHAR2,
	          x_schedule_start_datetime OUT NOCOPY	   DATE,
	          x_schedule_end_datetime   OUT NOCOPY	   DATE,
	          X_return_status	    OUT NOCOPY	   VARCHAR2
		)
    IS
    --{
	l_trip_stop_tab             Trip_Stop_tab_Type;
	l_trip_stop_rec             Trip_Stop_rec_Type;
	l_current_trip_stop_rec     Trip_Stop_rec_Type;
	--
	--
	l_current_stop_id     NUMBER := 0;
	l_old_first_stop_id     NUMBER := 0;
	l_old_last_stop_id      NUMBER := 0;
	l_trip_stop_tab_count   NUMBER := 0;
	l_curr_stop_old_position VARCHAR2(30);
	--
	--
	CURSOR get_segment_stops_cur
		(
		  p_segment_id IN NUMBER
		)
	IS
	SELECT
               STOP_ID,
               STOP_LOCATION_ID,
	       STOP_SEQUENCE_NUMBER,
               PLANNED_ARRIVAL_DATE,
               PLANNED_DEPARTURE_DATE,
	       G_NO_CHANGE ACTION_TYPE
	FROM   wsh_trip_stops
	WHERE  trip_id = p_segment_id
	UNION ALL
	SELECT
               l_current_stop_id stop_id,
               p_current_stop_rec.STOP_LOCATION_ID stop_location_id,
	       p_current_stop_rec.STOP_SEQUENCE_NUMBER stop_sequencE_number,
               p_current_stop_rec.PLANNED_ARRIVAL_DATE planned_arrival_date,
               p_current_stop_rec.PLANNED_DEPARTURE_DATE planned_departure_date,
	       p_action_type action_type
	FROM   DUAL
	order by 3;
    --}
    BEGIN
    --{
	l_current_stop_id        := NVL(p_current_stop_rec.STOP_ID,FND_API.G_MISS_NUM);
        l_curr_stop_old_position := G_NONE;
	l_trip_stop_tab_count    := 0;
	l_old_first_stop_id      := NULL;
	l_old_last_stop_id      := NULL;
	--
	--
	FOR get_segment_stops_rec IN get_segment_stops_cur
				     (
				       p_segment_id => p_trip_segment_rec.trip_id
				     )
	LOOP
	--{
	    l_trip_stop_Rec.stop_id                := get_segment_stops_rec.stop_id;
	    l_trip_stop_Rec.stop_location_id       := get_segment_stops_rec.stop_location_id;
	    l_trip_stop_Rec.stop_sequence_number   := get_segment_stops_rec.stop_sequence_number;
	    l_trip_stop_Rec.planned_departure_date := get_segment_stops_rec.planned_departure_date;
	    l_trip_stop_Rec.planned_arrival_date   := get_segment_stops_rec.planned_arrival_date;
	    l_trip_stop_Rec.action_type            := get_segment_stops_rec.action_type;
	    --
	    --
	    IF  l_trip_stop_rec.stop_id     = l_current_stop_id
	    AND l_trip_stop_rec.action_type = G_NO_CHANGE
	    THEN
	    --{
		    l_curr_stop_old_position := G_INTERMEDIATE;
	    --}
	    ELSE
	    --{
		l_trip_stop_tab_count := l_trip_stop_tab_count + 1;
		l_trip_stop_tab(l_trip_stop_tab_count) := l_trip_stop_rec;
	    --}
	    END IF;
	    --
	    --
	    IF  l_trip_stop_rec.action_type = G_NO_CHANGE
	    THEN
	    --{
		l_old_last_stop_id := l_trip_stop_rec.stop_id;
		x_schedule_end_datetime := l_trip_stop_rec.planned_arrival_date;
		--
		--
		IF l_old_first_stop_id IS NULL
		THEN
		    l_old_first_stop_id := l_trip_stop_rec.stop_id;
		    x_schedule_start_datetime := l_trip_stop_rec.planned_departure_date;
		END IF;
	    --}
	    END IF;
	    --
	    --
	    IF  l_trip_stop_rec.stop_id      = l_current_stop_id
	    AND l_trip_stop_rec.action_type <> G_NO_CHANGE
	    THEN
	    --{
		x_current_stop_index  := l_trip_stop_tab_count;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	IF l_current_stop_id      = l_old_first_stop_id
	THEN
		    l_curr_stop_old_position := G_FIRST;
	ELSIF l_current_stop_id      = l_old_last_stop_id
	THEN
		    l_curr_stop_old_position := G_LAST;
	END IF;
	--
	--
        x_curr_stop_old_position := l_curr_stop_old_position;
	x_trip_stop_tab := l_trip_stop_tab;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.GET_SEGMENT_STOPS');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_segment_stops;
    --
    --
    --
    PROCEDURE validate_first_stop
		(
	          P_trip_segment_rec          IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_current_stop_rec          IN   trip_stop_rec_type,
		  p_stop_validation_ctrl_rec  IN   stop_validation_ctrl_rec_type,
	          p_schedule_start_datetime   IN  DATE,
	          p_schedule_end_datetime     IN  DATE,
	          X_return_status	      OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	--
	--
	l_trip_count                NUMBER;
	l_dep_match_flag            NUMBER;
	l_arr_match_flag            NUMBER;
	l_lane_valid_flag           VARCHAR2(32767);
	l_connected                 BOOLEAN;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
    --}
    BEGIN
    --{
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	--
	--
	IF p_trip_segment_rec.schedule_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.datetime_schedule_check
	THEN
	--{
	    /*
            FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_schedule_id	    => p_trip_segment_rec.schedule_id,
                p_departure_date    => p_current_stop_rec.planned_departure_date,
                p_arrival_date	    => p_current_stop_rec.planned_arrival_date,
                x_return_status     => l_return_status,
                x_dep_match_flag    => l_dep_match_flag,
                x_arr_match_flag    => l_arr_match_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    */
	    --
	    --
	    --IF l_dep_match_flag <> FTE_CAT_VALIDATE_PKG.G_MATCH_WITH_DEP_DATE
	    IF p_current_stop_rec.planned_departure_date
	    <> p_schedule_start_datetime
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_FIRST_STOP_DATE_MATCH_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		FND_MESSAGE.SET_TOKEN('SCHED_DEPARTURE_DATE', fnd_date.date_to_displayDT(p_schedule_start_datetime));
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_trip_segment_rec.lane_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.location_lane_check
	THEN
	--{
            FTE_CAT_VALIDATE_PKG.Validate_Loc_To_Region
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_location_id	    => p_current_stop_rec.stop_location_id,
                p_search_criteria   => 'O',
                x_return_status     => l_return_status,
                x_valid_flag        => l_lane_valid_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_Loc_to_Region',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    --
	    --
	    IF l_lane_valid_flag = 'N'
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_LOCN_LANE_ORIG_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	--{
	    l_trip_count := 0;
	    --
	    --
	    --
	    --  FOLLOWING IF CLAUSE SHOULD BE COMMENTED IF
	    --  CODE TO CHECK SEGMENT_HAS_INTRANSIT_DELIVERIES IS UNCOMMENTED.
	    --  ONCE, THIS IF CLAUSE IS COMMENTED, ANOTHER IF INSIDE THE LOOP,
	    --  WILL PERFORM THE NECESSARY CHECK.
	    --
	    --
	        IF p_stop_validation_ctrl_rec.segment_connected_check
	        THEN
	        --{
	    FOR get_segment_trips_rec IN get_segment_trips_cur
	    LOOP
	    --{
		l_trip_count := l_trip_count + 1;
                --
		--
	        IF p_stop_validation_ctrl_rec.segment_connected_check
	        THEN
	        --{
                    fte_mls_util.check_previous_segment
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_rec        => p_trip_segment_rec,
		        p_sequence_number         => get_segment_trips_rec.sequence_number,
		        p_first_stop_location_id  => p_current_stop_rec.stop_location_id,
		        x_trip_name               => get_segment_trips_rec.fte_trip_name,
	                x_connected    	      => l_connected,
	                x_return_status	      => l_return_status
		      );
                    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_UTIL.CHECK_PREVIOUS_SEGMENT',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_TRIP_SEG_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => p_trip_segment_rec.trip_id,
		          p_trip_segment_name  => p_trip_segment_rec.name,
		          p_trip_stop_id       => p_current_stop_rec.stop_id,
		          p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		          p_trip_id            => get_segment_trips_rec.fte_trip_id,
		          p_trip_name          => get_segment_trips_rec.fte_trip_name,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            THEN
	            --{
		        RETURN;
	            --}
	            END IF;
	            --
	            --
		    IF NOT(l_connected)
		    THEN
		    --{
		        FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_PREV_CONNECT_ERROR');
		        FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		        FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	                WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		        l_number_of_warnings := l_number_of_warnings + 1;
		        --
		        --
	                UPDATE fte_trips
	                SET    validation_required = 'Y'
	                WHERE  fte_trip_id         = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
		--}
		END IF;
	    --}
	    END LOOP;
		--}
		END IF;
	    --
	    --
	    /* Please see the comment above the previous IF Clause.
	    --
	    IF l_trip_count > 0
            AND p_stop_validation_ctrl_rec.dlvy_in_transit_check
	    THEN
	    --{
		IF segment_has_intransit_dlvy( P_trip_segment_rec => p_trip_segment_rec )
		THEN
		    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_DLVY_INTRANSIT_ERR');
		    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		    FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		    l_number_of_warnings := l_number_of_warnings + 1;
		END IF;
	    --}
	    END IF;
	    */
	    --
	    --
	--}
	--END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_FIRST_STOP');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_first_stop;
    --
    --
    PROCEDURE validate_last_stop
		(
	          P_trip_segment_rec          IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_current_stop_rec          IN   trip_stop_rec_type,
		  p_stop_validation_ctrl_rec  IN   stop_validation_ctrl_rec_type,
	          p_schedule_start_datetime   IN  DATE,
	          p_schedule_end_datetime     IN  DATE,
	          X_return_status	      OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	--
	--
	l_trip_count                NUMBER;
	l_dep_match_flag            NUMBER;
	l_arr_match_flag            NUMBER;
	l_lane_valid_flag           VARCHAR2(32767);
	l_connected                 BOOLEAN;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
    --}
    BEGIN
    --{
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	--
	--
	IF p_trip_segment_rec.schedule_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.datetime_schedule_check
	THEN
	--{
	    /*
            FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_schedule_id	    => p_trip_segment_rec.schedule_id,
                p_departure_date    => p_current_stop_rec.planned_departure_date,
                p_arrival_date	    => p_current_stop_rec.planned_arrival_date,
                x_return_status     => l_return_status,
                x_dep_match_flag    => l_dep_match_flag,
                x_arr_match_flag    => l_arr_match_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    */
	    --
	    --
	    --IF l_arr_match_flag <> FTE_CAT_VALIDATE_PKG.G_MATCH_WITH_ARR_DATE
	    IF p_current_stop_rec.planned_arrival_date
	    <> p_schedule_end_datetime
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_LAST_STOP_DATE_MATCH_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		FND_MESSAGE.SET_TOKEN('SCHED_ARRIVAL_DATE', fnd_date.date_to_displayDT(p_schedule_end_datetime));
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_trip_segment_rec.lane_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.location_lane_check
	THEN
	--{
            FTE_CAT_VALIDATE_PKG.Validate_Loc_To_Region
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_location_id	    => p_current_stop_rec.stop_location_id,
                p_search_criteria   => 'D',
                x_return_status     => l_return_status,
                x_valid_flag        => l_lane_valid_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_Loc_to_Region',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    --
	    --
	    l_lane_valid_flag := 'Y';
	    IF l_lane_valid_flag = 'N'
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_LOCN_LANE_DEST_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	--{
	    l_trip_count := 0;
	    --
	    --
	    --  FOLLOWING IF CLAUSE SHOULD BE COMMENTED IF
	    --  CODE TO CHECK SEGMENT_HAS_INTRANSIT_DELIVERIES IS UNCOMMENTED.
	    --  ONCE, THIS IF CLAUSE IS COMMENTED, ANOTHER IF INSIDE THE LOOP,
	    --  WILL PERFORM THE NECESSARY CHECK.
	    --
	    --
	        IF p_stop_validation_ctrl_rec.segment_connected_check
	        THEN
	        --{
	    FOR get_segment_trips_rec IN get_segment_trips_cur
	    LOOP
	    --{
		l_trip_count := l_trip_count + 1;
                --
		--
	        IF p_stop_validation_ctrl_rec.segment_connected_check
	        THEN
	        --{
                    fte_mls_util.check_next_segment
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_rec        => p_trip_segment_rec,
		        p_sequence_number         => get_segment_trips_rec.sequence_number,
		        p_last_stop_location_id   => p_current_stop_rec.stop_location_id,
		        x_trip_name               => get_segment_trips_rec.fte_trip_name,
	                x_connected    	      => l_connected,
	                x_return_status	      => l_return_status
		      );
                    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_UTIL.CHECK_NEXT_SEGMENT',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_TRIP_SEG_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => p_trip_segment_rec.trip_id,
		          p_trip_segment_name  => p_trip_segment_rec.name,
		          p_trip_stop_id       => p_current_stop_rec.stop_id,
		          p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		          p_trip_id            => get_segment_trips_rec.fte_trip_id,
		          p_trip_name          => get_segment_trips_rec.fte_trip_name,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            THEN
	            --{
		        RETURN;
	            --}
	            END IF;
	            --
	            --
		    IF NOT(l_connected)
		    THEN
		    --{
		        FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_NEXT_CONNECT_ERROR');
		        FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		        FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	                WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		        l_number_of_warnings := l_number_of_warnings + 1;
		        --
		        --
	                UPDATE fte_trips
	                SET    validation_required = 'Y'
	                WHERE  fte_trip_id         = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
		--}
		END IF;
	    --}
	    END LOOP;
		--}
		END IF;
	    --
	    --
	    /* Please see the comment above the previous IF Clause.
	    --
	    IF l_trip_count > 0
            AND p_stop_validation_ctrl_rec.dlvy_in_transit_check
	    THEN
	    --{
		IF segment_has_intransit_dlvy( P_trip_segment_rec => p_trip_segment_rec )
		THEN
		    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_DLVY_INTRANSIT_ERR');
		    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		    FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		    l_number_of_warnings := l_number_of_warnings + 1;
		END IF;
	    --}
	    END IF;
	    */
	    --
	    --
	--}
	--END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_LAST_STOP');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_last_stop;
    --
    --
    PROCEDURE validate_intermediate_stop
		(
	          P_trip_segment_rec          IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_current_stop_rec          IN   Trip_Stop_Rec_Type,
		  p_stop_validation_ctrl_rec  IN   stop_validation_ctrl_rec_type,
	          p_schedule_start_datetime   IN   DATE,
	          p_schedule_end_datetime     IN   DATE,
	          X_return_status	      OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	--
	--
	l_dep_match_flag            NUMBER;
	l_arr_match_flag            NUMBER;
	l_lane_valid_flag           VARCHAR2(32767);
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
    --}
    BEGIN
    --{
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	--
	--
	IF p_trip_segment_rec.schedule_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.datetime_schedule_check
	THEN
	--{
	    /*
            FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_schedule_id	    => p_trip_segment_rec.schedule_id,
                p_departure_date    => p_current_stop_rec.planned_departure_date,
                p_arrival_date	    => p_current_stop_rec.planned_arrival_date,
                x_return_status     => l_return_status,
                x_dep_match_flag    => l_dep_match_flag,
                x_arr_match_flag    => l_arr_match_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_Schedule_Date',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    */
	    --
	    --
	    --IF l_dep_match_flag <> FTE_CAT_VALIDATE_PKG.G_BETWEEN_DATES
	    IF p_current_stop_rec.planned_departure_date
	    NOT BETWEEN p_schedule_start_datetime
	           AND     p_schedule_end_datetime
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_DEP_DATE_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		FND_MESSAGE.SET_TOKEN('STOP_SEQUENCE_NUMBER', p_current_stop_rec.stop_sequence_number);
		FND_MESSAGE.SET_TOKEN('SCHED_DEPARTURE_DATE', fnd_date.date_to_displayDT(p_schedule_start_datetime));
		FND_MESSAGE.SET_TOKEN('SCHED_ARRIVAL_DATE', fnd_date.date_to_displayDT(p_schedule_end_datetime));
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		l_number_of_warnings := l_number_of_warnings + 1;
		--
		-- Not setting as error due to timezone issues.
		-- It will be a warning until timezone issues are resolved.
		--
	        --WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		--l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	    --
	    --
	    --IF l_arr_match_flag <> FTE_CAT_VALIDATE_PKG.G_BETWEEN_DATES
	    IF p_current_stop_rec.planned_arrival_date
	    NOT BETWEEN p_schedule_start_datetime
	           AND     p_schedule_end_datetime
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_ARR_DATE_ERR');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		FND_MESSAGE.SET_TOKEN('STOP_SEQUENCE_NUMBER', p_current_stop_rec.stop_sequence_number);
		FND_MESSAGE.SET_TOKEN('SCHED_DEPARTURE_DATE', fnd_date.date_to_displayDT(p_schedule_start_datetime));
		FND_MESSAGE.SET_TOKEN('SCHED_ARRIVAL_DATE', fnd_date.date_to_displayDT(p_schedule_end_datetime));
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		l_number_of_warnings := l_number_of_warnings + 1;
		--
		-- Not setting as error due to timezone issues.
		-- It will be a warning until timezone issues are resolved.
		--
	        --WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		--l_number_of_errors := l_number_of_errors + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_trip_segment_rec.lane_id IS NOT NULL
	AND p_stop_validation_ctrl_rec.location_lane_check
	THEN
	--{
            FTE_CAT_VALIDATE_PKG.Validate_Loc_To_Region
	      (
                p_lane_id	    => p_trip_segment_rec.lane_id,
                p_location_id	    => p_current_stop_rec.stop_location_id,
                p_search_criteria   => 'A',
                x_return_status     => l_return_status,
                x_valid_flag        => l_lane_valid_flag
               );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_CAT_VALIDATE_PKG.Validate_loc_to_region',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => p_current_stop_rec.stop_id,
		  p_stop_seq_number    => p_current_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	    --
	    --
	    IF l_lane_valid_flag = 'N'
	    THEN
	    --{
		FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_LOCN_LANE_WARN');
		FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
	        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		l_number_of_warnings := l_number_of_warnings + 1;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_INTERMEDIATE_STOP');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_intermediate_stop;
    --
    --
    PROCEDURE validate_stop_add
		(
	          P_trip_segment_rec       IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_trip_stop_tab          IN   Trip_Stop_Tab_type,
		  p_current_stop_index     IN   NUMBER,
	          p_stop_validation_ctrl_rec  IN stop_validation_ctrl_rec_type,
	          p_schedule_start_datetime   IN   DATE,
	          p_schedule_end_datetime     IN   DATE,
	          X_return_status	   OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	--
	--
	l_trip_stop_rec              trip_stop_rec_type;
	--l_stop_validation_ctrl_rec stop_validation_ctrl_rec_type;
	--
	l_trip_count                NUMBER;
	l_return_status             VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
	--
	--
	l_first BOOLEAN := FALSE;
	l_last BOOLEAN := FALSE;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
	--

    --}
    BEGIN
    --{
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	l_first               := FALSE;
	l_last                := FALSE;
	--
	--
	l_trip_stop_rec := p_trip_stop_tab(p_current_stop_index);
	--
	--
	--l_stop_validation_ctrl_rec := get_stop_full_validation_ctrl_rec;
	--
	--
	IF p_current_stop_index = p_trip_stop_tab.FIRST
	THEN
	--{
	    l_first := TRUE;
	    --
            validate_first_stop
		(
	          P_trip_segment_rec             => p_trip_segment_rec,
	          P_current_stop_rec             => l_trip_stop_rec,
		  p_stop_validation_ctrl_rec     => p_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	         => l_return_status
		);
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_WSH_INTERFACE_PKG.Validate_first_stop',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_trip_stop_rec.stop_id,
		  p_stop_seq_number    => l_trip_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_current_stop_index = p_trip_stop_tab.LAST
	AND p_current_stop_index <> p_trip_stop_tab.FIRST
	THEN
	--{
	    l_last := TRUE;
	    --
            validate_last_stop
		(
	          P_trip_segment_rec             => p_trip_segment_rec,
	          P_current_stop_rec             => l_trip_stop_rec,
		  p_stop_validation_ctrl_rec  => p_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	         => l_return_status
		);
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_WSH_INTERFACE_PKG.Validate_last_stop',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_trip_stop_rec.stop_id,
		  p_stop_seq_number    => l_trip_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF NOT(l_first) AND NOT(l_last)
	THEN
	--{
            validate_intermediate_stop
		(
	          P_trip_segment_rec             => p_trip_segment_rec,
	          P_current_stop_rec             => l_trip_stop_rec,
		  p_stop_validation_ctrl_rec  => p_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	         => l_return_status
		);
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_WSH_INTERFACE_PKG.Validate_intermediate_stop',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_trip_stop_rec.stop_id,
		  p_stop_seq_number    => l_trip_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_stop_add;
    --
    --
    PROCEDURE validate_stop_update
		(
	          P_trip_segment_rec       IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_trip_stop_tab          IN   Trip_Stop_Tab_type,
		  p_current_stop_index     IN   NUMBER,
		  p_curr_stop_old_position IN   VARCHAR2,
		  p_old_stop_rec           IN   WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
	          p_schedule_start_datetime   IN   DATE,
	          p_schedule_end_datetime     IN   DATE,
	          x_return_status	   OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	--
	--
	l_new_stop_rec              trip_stop_rec_type;
	l_validate_stop_rec         trip_stop_rec_type;
	l_stop_validation_ctrl_rec stop_validation_ctrl_rec_type;
	l_stop_full_valid_ctrl_rec stop_validation_ctrl_rec_type;
	--
	l_validate_stop_index       NUMBER;
	l_trip_count                NUMBER;
	l_return_status             VARCHAR2(32767);
	l_validation_required       BOOLEAN := FALSE;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
        CURSOR pickup_deliveries_cur (p_stop_id NUMBER) IS
        SELECT
               dg.delivery_id, dl.name
        FROM   wsh_new_deliveries dl,
               wsh_delivery_legs dg,
               wsh_trip_stops st
        WHERE  dg.delivery_id      = dl.delivery_id
        AND    st.stop_location_id = dl.initial_pickup_location_id
        AND    st.stop_id          = dg.pick_up_stop_id
        AND    st.stop_id          = p_stop_id;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	--
	--
	l_new_stop_rec   := p_trip_stop_tab(p_current_stop_index);
	--
	--
	--l_stop_full_valid_ctrl_rec := get_stop_full_validation_ctrl_rec;
	--
	--
	l_validation_required := FALSE;
	--
	--
	IF p_old_stop_rec.stop_sequence_number <> l_new_stop_rec.stop_sequence_number
	THEN
	--{
	    l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
            l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := TRUE;
            l_validation_required                                := TRUE;
	--}
	ELSIF p_old_stop_rec.stop_location_id <> l_new_stop_rec.stop_location_id
	THEN
	--{
	    l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
            l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;

	    IF p_old_stop_rec.planned_departure_date <> l_new_stop_rec.planned_departure_date
	    OR p_old_stop_rec.planned_arrival_date   <> l_new_stop_rec.planned_arrival_date
	    THEN
                l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
	    END IF;
	    --
	    --
            l_validation_required                                := TRUE;
	--}
	ELSIF p_old_stop_rec.planned_departure_date <> l_new_stop_rec.planned_departure_date
	OR p_old_stop_rec.planned_arrival_date   <> l_new_stop_rec.planned_arrival_date
	THEN
	--{
	    l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := FALSE;
            l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := FALSE;
            l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;
            l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
            l_validation_required                                := TRUE;
	--}
	END IF;
	--
	IF l_validation_required
	THEN
	--{
	    validate_stop_add
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
	          P_trip_stop_tab          => p_trip_stop_tab,
		  p_current_stop_index     => p_current_stop_index,
	          p_stop_validation_ctrl_rec  => l_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_new_stop_rec.stop_id,
		  p_stop_seq_number    => l_new_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_old_stop_rec.stop_sequence_number <> l_new_stop_rec.stop_sequence_number
	THEN
	--{
	    --If user increased the sequence number, validate the first stop again.
	    --
	    --
	    IF l_new_stop_rec.stop_sequence_number > p_old_stop_rec.stop_sequence_number
	    AND p_curr_stop_old_position           = G_FIRST
	    THEN
	    --{
	        l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
                l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
                l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
                l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;
		--
		--
	        l_validate_stop_index := p_trip_stop_tab.FIRST;
	        l_validate_stop_rec   := p_trip_stop_tab(l_validate_stop_index);
		--
		--
	        validate_stop_add
	          (
	              P_trip_segment_rec       => p_trip_segment_rec,
	              P_trip_stop_tab          => p_trip_stop_tab,
		      p_current_stop_index     => p_trip_stop_tab.FIRST,
	              p_stop_validation_ctrl_rec  => l_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	              X_return_status	   => l_return_status
	          );
	        --
	        --
                FTE_MLS_UTIL.api_post_call
		    (
		      p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		      p_api_return_status  => l_return_status,
		      p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		      p_trip_segment_id    => p_trip_segment_rec.trip_id,
		      p_trip_segment_name  => p_trip_segment_rec.name,
		      p_trip_stop_id       => l_validate_stop_rec.stop_id,
		      p_stop_seq_number    => l_validate_stop_rec.stop_sequence_number,
		      x_number_of_errors   => l_number_of_errors,
		      x_number_of_warnings => l_number_of_warnings,
		      x_return_status      => x_return_status
		    );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	    --
	    --
	    --If user decreased the sequence number, validate the last stop again.
	    --
	    --
	    IF l_new_stop_rec.stop_sequence_number < p_old_stop_rec.stop_sequence_number
	    AND p_curr_stop_old_position           = G_LAST
	    THEN
	    --{
	        l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
                l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
                l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
                l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;
		--
		--
	        l_validate_stop_index := p_trip_stop_tab.LAST;
	        l_validate_stop_rec   := p_trip_stop_tab(l_validate_stop_index);
		--
		--
	        validate_stop_add
	          (
	              P_trip_segment_rec       => p_trip_segment_rec,
	              P_trip_stop_tab          => p_trip_stop_tab,
		      p_current_stop_index     => p_trip_stop_tab.LAST,
	              p_stop_validation_ctrl_rec  => l_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	              X_return_status	   => l_return_status
	          );
	        --
	        --
                FTE_MLS_UTIL.api_post_call
		    (
		      p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		      p_api_return_status  => l_return_status,
		      p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		      p_trip_segment_id    => p_trip_segment_rec.trip_id,
		      p_trip_segment_name  => p_trip_segment_rec.name,
		      p_trip_stop_id       => l_validate_stop_rec.stop_id,
		      p_stop_seq_number    => l_validate_stop_rec.stop_sequence_number,
		      x_number_of_errors   => l_number_of_errors,
		      x_number_of_warnings => l_number_of_warnings,
		      x_return_status      => x_return_status
		    );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF p_old_stop_rec.status_code <> l_new_stop_rec.status_code
	AND l_new_stop_rec.status_code = 'CL'
	THEN
	--{
	    NULL;
            FOR pickup_deliveries_rec IN pickup_deliveries_cur (p_stop_id => l_new_stop_rec.stop_id)
	    LOOP
	    --{
		fte_freight_pricing.shipment_reprice2
		  (
		    p_delivery_id => pickup_deliveries_rec.delivery_id,
		    x_return_status => l_return_status
		  );
		--
	        --
                FTE_MLS_UTIL.api_post_call
		    (
		      p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		      p_api_return_status  => l_return_status,
		      p_message_name       => 'FTE_STOP_REPRICING_UNEXP_ERROR',
		      p_trip_segment_id    => p_trip_segment_rec.trip_id,
		      p_trip_segment_name  => p_trip_segment_rec.name,
		      p_trip_stop_id       => l_new_stop_rec.stop_id,
		      p_stop_seq_number    => l_new_stop_rec.stop_sequence_number,
		      p_delivery_id        => pickup_deliveries_rec.delivery_id,
		      p_delivery_name      => pickup_deliveries_rec.name,
		      x_number_of_errors   => l_number_of_errors,
		      x_number_of_warnings => l_number_of_warnings,
		      x_return_status      => x_return_status
		    );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END LOOP;
	    --
	    --
	    /*
            FOR get_segment_trips_rec IN get_segment_trips_cur
	    LOOP
	    --{
		fte_trips_pvt.validate_trip
		  (
		    p_trip_id => get_segment_trips_rec.fte_trip_id,
		    x_return_status => l_return_status
		  );
	        --
	        --
                FTE_MLS_UTIL.api_post_call
		    (
		      p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		      p_api_return_status  => l_return_status,
		      p_message_name       => 'FTE_TRIP_SEG_STOP_UNEXP_ERROR',
		      p_trip_segment_id    => p_trip_segment_rec.trip_id,
		      p_trip_segment_name  => p_trip_segment_rec.name,
		      p_trip_stop_id       => l_validate_stop_rec.stop_id,
		      p_stop_seq_number    => l_validate_stop_rec.stop_sequence_number,
		      p_trip_id            => get_segment_trips_rec.fte_trip_id,
		      p_trip_name          => get_segment_trips_rec.fte_trip_name,
		      x_number_of_errors   => l_number_of_errors,
		      x_number_of_warnings => l_number_of_warnings,
		      x_return_status      => x_return_status
		    );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END LOOP;
	    */
	--}
	END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_UPDATE');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_stop_update;
    --
    --
    PROCEDURE validate_stop_delete
		(
	          P_trip_segment_rec       IN   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_trip_stop_tab          IN   Trip_Stop_Tab_type,
		  p_current_stop_index     IN   NUMBER,
	          p_schedule_start_datetime   IN   DATE,
	          p_schedule_end_datetime     IN   DATE,
	          x_return_status	   OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	l_deleted_stop_rec              trip_stop_rec_type;
	l_validate_stop_rec         trip_stop_rec_type;
	l_stop_validation_ctrl_rec stop_validation_ctrl_rec_type;
	l_stop_full_valid_ctrl_rec stop_validation_ctrl_rec_type;
	--
	l_validate_stop_index       NUMBER;
	l_trip_count                NUMBER;
	l_return_status             VARCHAR2(32767);
	l_validation_required       BOOLEAN := FALSE;
	l_previous_segment_id       NUMBER;
	l_next_segment_id           NUMBER;
	l_trip_name             VARCHAR2(32767);
	l_trip_segment_name             VARCHAR2(32767);
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
	l_first BOOLEAN := FALSE;
	l_last BOOLEAN := FALSE;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
    --}
    BEGIN
    --{
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	l_trip_count          := 0;
	l_first               := FALSE;
	l_last                := FALSE;
	l_trip_segment_name   := p_trip_segment_rec.name;
	--
	--
	l_deleted_stop_rec   := p_trip_stop_tab(p_current_stop_index);
	--
	--
	--l_stop_full_valid_ctrl_rec := get_stop_full_validation_ctrl_rec;
	--
	--
	IF p_trip_stop_tab.FIRST = p_current_stop_index
	THEN
	--{
	    l_first := TRUE;
	--}
	END IF;
	--
	--
	IF p_trip_stop_tab.LAST = p_current_stop_index
	THEN
	--{
	    l_last := TRUE;
	--}
	END IF;
	--
	--
	FOR get_segment_trips_rec IN get_segment_trips_cur
	LOOP
	--{
	    l_trip_count := l_trip_count + 1;
	    EXIT;
	    -- rest of the code in this for loop is redundant
	    --
	    --
	    l_trip_name := get_segment_trips_rec.fte_trip_name;
	    --
	    --
	    IF l_first
	    THEN
	    --{
                    fte_mls_util.get_previous_segment_id
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_id         => p_trip_segment_rec.trip_id,
		        p_sequence_number         => get_segment_trips_rec.sequence_number,
		        x_trip_name               => l_trip_name,
		        x_trip_segment_name       => l_trip_segment_name,
		        x_previous_segment_id     => l_previous_segment_id,
	                x_return_status	          => l_return_status
		      );
                    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_UTIL.GET_PREVIOUS_SEGMENT_ID',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_TRIP_SEGMENT_UNEXP_ERROR',
		          p_trip_segment_id    => p_trip_segment_rec.trip_id,
		          p_trip_segment_name  => p_trip_segment_rec.name,
		          p_trip_id            => get_segment_trips_rec.fte_trip_id,
		          p_trip_name          => get_segment_trips_rec.fte_trip_name,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            THEN
	            --{
		        RETURN;
	            --}
	            END IF;
		    --
		    --
		    IF l_previous_segment_id IS NOT NULL
		    THEN
		    --{
		            FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_PREV_CONNECT_ERROR');
		            FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		            FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	                    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		            l_number_of_warnings := l_number_of_warnings + 1;
		            --
		            --
	                    UPDATE fte_trips
	                    SET    validation_required = 'Y'
	                    WHERE  fte_trip_id         = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
	    --}
	    END IF;
	    --
	    --
	    IF l_last
	    THEN
	    --{
                    fte_mls_util.get_next_segment_id
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_id         => p_trip_segment_rec.trip_id,
		        p_sequence_number         => get_segment_trips_rec.sequence_number,
		        x_trip_name               => l_trip_name,
		        x_trip_segment_name       => l_trip_segment_name,
		        x_next_segment_id     => l_next_segment_id,
	                x_return_status	          => l_return_status
		      );
                    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_UTIL.GET_NEXT_SEGMENT_ID',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_TRIP_SEGMENT_UNEXP_ERROR',
		          p_trip_segment_id    => p_trip_segment_rec.trip_id,
		          p_trip_segment_name  => p_trip_segment_rec.name,
		          p_trip_id            => get_segment_trips_rec.fte_trip_id,
		          p_trip_name          => get_segment_trips_rec.fte_trip_name,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            THEN
	            --{
		        RETURN;
	            --}
	            END IF;
		    --
		    --
		    IF l_next_segment_id IS NOT NULL
		    THEN
		    --{
		            FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_NEXT_CONNECT_ERROR');
		            FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
		            FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	                    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		            l_number_of_warnings := l_number_of_warnings + 1;
		            --
		            --
	                    UPDATE fte_trips
	                    SET    validation_required = 'Y'
	                    WHERE  fte_trip_id         = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	IF p_trip_stop_tab.COUNT <= 2
	AND (
	       p_trip_segment_rec.lane_id IS NOT NULL
	       OR
	       l_trip_count > 0
	    )
	THEN
	--{
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_STOP_DELETE_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_rec.name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RETURN;
	--}
	END IF;
	--
	--
	l_validation_required := FALSE;
	--
	--
	IF l_first
	AND p_trip_stop_tab.COUNT >= 2
	THEN
	--{
	    l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
            l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;
            l_validation_required                                := TRUE;
	    --
	    --
	    l_validate_stop_index  := p_current_stop_index+1;
	    l_validate_stop_rec    := p_trip_stop_tab(l_validate_stop_index);
	    --
	    --
	    validate_first_stop
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
		  p_current_stop_rec     => l_validate_stop_rec,
	          p_stop_validation_ctrl_rec  => l_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );
	--}
	END IF;
	--
	--
	IF l_last
	AND p_trip_stop_tab.COUNT >= 2
	THEN
	--{
	    l_stop_validation_ctrl_rec.LOCATION_LANE_CHECK       := TRUE;
            l_stop_validation_ctrl_rec.DATETIME_SCHEDULE_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.SEGMENT_CONNECTED_CHECK   := TRUE;
            l_stop_validation_ctrl_rec.DLVY_IN_TRANSIT_CHECK     := FALSE;
            l_validation_required                                := TRUE;
	    --
	    --
	    l_validate_stop_index  := p_current_stop_index-1;
	    l_validate_stop_rec    := p_trip_stop_tab(l_validate_stop_index);
	    --
	    --
	    validate_last_stop
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
		  p_current_stop_rec     => l_validate_stop_rec,
	          p_stop_validation_ctrl_rec  => l_stop_validation_ctrl_rec,
	          p_schedule_start_datetime      => p_schedule_start_datetime,
	          p_schedule_end_datetime        => p_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );
	--}
	END IF;
	--
	--
	IF l_validation_required
	THEN
	--{
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_validate_stop_rec.stop_id,
		  p_stop_seq_number    => l_validate_stop_rec.stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_DELETE');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_stop_delete;
    --
    --

-------------
--========================================================================
-- PROCEDURE : SEGMENT_STOP_CHANGE
--
-- COMMENT   : When ever a stop is added, updated or delete, this procedure is
--		called to validate if the stop can be inserted
-- CREATED BY: NPARIKH
-- MODIFIED :  HBHAGAVA 11/24/2002
-- DESC:       Additional check to see if adding a new stop, or updating stop
--	       has changed the weight/volume. If it is changed over the carrier threshold
--	       value then an update notification will be send to carrier.
--
--========================================================================


    PROCEDURE segment_stop_change
		(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          P_commit		    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT NOCOPY	   VARCHAR2,
	          X_msg_count		    OUT NOCOPY	   NUMBER,
	          X_msg_data		    OUT NOCOPY	   VARCHAR2,
	          P_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_old_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
	          P_new_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
		  p_segmentStopChangeInRec  IN     segmentStopChangeInRecType,
		  p_segmentStopChangeOutRec OUT NOCOPY    segmentStopChangeOutRecType
		)
    IS
    --{
        l_api_name              CONSTANT VARCHAR2(30)   := 'SEGMENT_STOP_CHANGE';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	l_trip_stop_tab         Trip_Stop_tab_Type;
	l_current_stop_rec      WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
	l_stop_full_valid_ctrl_rec stop_validation_ctrl_rec_type;
	--
	--
	l_current_stop_index        NUMBER;
	l_curr_stop_old_position    VARCHAR2(32767);
	l_schedule_start_datetime   DATE;
	l_schedule_end_datetime     DATE;
	--
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_index                     NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
	p_action_type               VARCHAR2(32767);
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_WSH_INTERFACE_PKG' || '.' || 'segment_stop_change';

	--
    --}
    BEGIN
    --{
	--
	--
        -- Standard Start of API savepoint
        SAVEPOINT   SEGMENT_STOP_CHANGE_PUB;
	--
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
		IF l_debug_on THEN
		      wsh_debug_sv.push(l_module_name);
		END IF;


        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;
	--
	--
        --  Initialize API return status to success
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	p_action_type         := p_segmentStopChangeInRec.action_type;
	--
	--
        -- Start of API body.
	--
	IF p_action_type IN ( G_ADD, G_UPDATE )
	THEN
	    l_current_stop_rec := p_new_segment_stop_rec;
	ELSIF p_action_type  = G_DELETE
	THEN
	    l_current_stop_rec := p_old_segment_stop_rec;
	ELSIF p_action_type  = G_TRIP_SEGMENT_DELETE
	THEN
	    NULL;
	ELSE
	--{
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_WSH_IF_INVALID_ACTION');
	    FND_MESSAGE.SET_TOKEN('ACTION_TYPE', p_action_type);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
	    --RETURN;
	--}
	END IF;
	--
	--
        get_segment_stops
	  (
	    P_trip_segment_rec          => p_trip_segment_rec,
	    P_current_stop_rec          => l_current_stop_rec,
	    p_action_type               => p_action_type,
	    x_trip_stop_tab             => l_trip_stop_tab,
	    x_current_stop_index        => l_current_stop_index,
            x_curr_stop_old_position    => l_curr_stop_old_position,
	    x_schedule_start_datetime   => l_schedule_start_datetime,
	    x_schedule_end_datetime     => l_schedule_end_datetime,
	    X_return_status	        => l_return_status
	  );
	--
	--
        FTE_MLS_UTIL.api_post_call
	  (
	    p_api_name           => 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD',
	    p_api_return_status  => l_return_status,
	    p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
	    p_trip_segment_id    => p_trip_segment_rec.trip_id,
	    p_trip_segment_name  => p_trip_segment_rec.name,
	    p_trip_stop_id       => l_current_stop_rec.stop_id,
	    p_stop_seq_number    => l_current_stop_rec.stop_sequence_number,
	    x_number_of_errors   => l_number_of_errors,
	    x_number_of_warnings => l_number_of_warnings,
	    x_return_status      => x_return_status
	  );
	 --
	 --
	 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	 THEN
	 --{
             RAISE FND_API.G_EXC_ERROR;
	     --RETURN;
	 --}
	 END IF;
	--
	--
	-- debugging statments
	--
	--
	--
	IF p_action_type = G_ADD
	THEN
	--{

		IF l_debug_on THEN

			WSH_DEBUG_SV.logmsg(l_module_name,'Adding Stop',
				    WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	    l_program_name := 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_ADD';
	    --
	    --
	    l_stop_full_valid_ctrl_rec := get_stop_full_validn_ctrl_rec;
	    --
	    --
	    IF l_trip_stop_tab.COUNT <= 2
	    THEN
	    --{
	         l_stop_full_valid_ctrl_rec.DATETIME_SCHEDULE_CHECK :=  FALSE;
	         l_stop_full_valid_ctrl_rec.LOCATION_LANE_CHECK     :=  FALSE;
	    --}
	    END IF;
	    --
	    --
	    validate_stop_add
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
	          P_trip_stop_tab          => l_trip_stop_tab,
		  p_current_stop_index     => l_current_stop_index,
	          p_stop_validation_ctrl_rec  => l_stop_full_valid_ctrl_rec,
	          p_schedule_start_datetime   => l_schedule_start_datetime,
	          p_schedule_end_datetime     => l_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );


	    wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors);

	    --
	    -- Check for the threshold value if this stop belongs to a trip
	    -- which is TENDERED or ACCEPTED PACK I
	    --
		IF l_debug_on THEN

			WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_TENDER_PVT.CHECK_THRESHOLD_FOR_STOP',
				    WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	    FTE_TENDER_PVT.CHECK_THRESHOLD_FOR_STOP(
	          P_api_version		    => 1.0,
	          P_init_msg_list	    => FND_API.G_FALSE,
	          X_return_status	    => l_return_status,
	          X_msg_count		    => l_msg_count,
	          X_msg_data		    => l_msg_data,
	          P_trip_segment_rec        => p_trip_segment_rec,
	          P_new_segment_stop_rec    => l_current_stop_rec);

	    wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	--}
	ELSIF p_action_type =  G_UPDATE
	THEN
	--{
	    l_program_name := 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_UPDATE';

		IF l_debug_on THEN

			WSH_DEBUG_SV.logmsg(l_module_name,'Updating Stop',
				    WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
	    --
	    --
	    validate_stop_update
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
	          P_trip_stop_tab          => l_trip_stop_tab,
		  p_current_stop_index     => l_current_stop_index,
                  p_curr_stop_old_position => l_curr_stop_old_position,
		  p_old_stop_rec           => p_old_segment_stop_rec,
	          p_schedule_start_datetime   => l_schedule_start_datetime,
	          p_schedule_end_datetime     => l_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );


	    wsh_util_core.api_post_call(
	      p_return_status    => l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors);


		IF l_debug_on THEN
			wsh_debug_sv.log (l_module_name,' After validate stop update');
			wsh_debug_sv.log (l_module_name,' l_return_status ' || l_return_status);
		END IF;

	    --
	    -- Check for the threshold value if this stop belongs to a trip
	    -- which is TENDERED or ACCEPTED PACK I
	    --
		IF l_debug_on THEN

			WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_TENDER_PVT.CHECK_THRESHOLD_FOR_STOP',
				    WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


	    FTE_TENDER_PVT.CHECK_THRESHOLD_FOR_STOP(
	          P_api_version		    => 1.0,
	          P_init_msg_list	    => FND_API.G_FALSE,
	          X_return_status	    => l_return_status,
	          X_msg_count		    => l_msg_count,
	          X_msg_data		    => l_msg_data,
	          P_trip_segment_rec        => p_trip_segment_rec,
	          P_new_segment_stop_rec    => l_current_stop_rec);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' return status from CHECK_THRESHOLD_FOR_STOP ' ||
				    l_return_status,
				    WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' message count  ' || l_msg_count,
				    WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' message data  ' || l_msg_data,
				    WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	        wsh_util_core.api_post_call(
	      	      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


	--}
	ELSIF p_action_type =  G_DELETE
	THEN
	--{
	    l_program_name := 'FTE_WSH_INTERFACE_PKG.VALIDATE_STOP_DELETE';
	    --
	    --
	    validate_stop_delete
	      (
	          P_trip_segment_rec       => p_trip_segment_rec,
	          P_trip_stop_tab          => l_trip_stop_tab,
		  p_current_stop_index     => l_current_stop_index,
	          p_schedule_start_datetime   => l_schedule_start_datetime,
	          p_schedule_end_datetime     => l_schedule_end_datetime,
	          X_return_status	   => l_return_status
	      );

	--}
	END IF;
	--
	--
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => l_program_name,
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		  p_trip_segment_id    => p_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_trip_segment_rec.name,
		  p_trip_stop_id       => l_trip_stop_tab(l_current_stop_index).stop_id,
		  p_stop_seq_number    => l_trip_stop_tab(l_current_stop_index).stop_sequence_number,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--
	--
	--
	--
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
	--
	--
	--
	--
        -- End of API body.
	--
	--
        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
	--
	--
        -- Standard call to get message count and if count is 1,get message info.
	--

        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
          --fnd_message.set_name('WSH','END');
	--

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	--
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO SEGMENT_STOP_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO SEGMENT_STOP_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        WHEN OTHERS THEN
                ROLLBACK TO SEGMENT_STOP_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF l_debug_on THEN
			wsh_debug_sv.log (l_module_name,' Unexpected error ');
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
                wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.segment_stop_change SEGMENT');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	       --
	       --
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
    --}
    END segment_stop_change;
    --
    --
    PROCEDURE validate_segment_update
		(
	          P_new_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_old_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          x_return_status	   OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	--
	--
	l_next_segment_id       NUMBER;
	l_previous_segment_id       NUMBER;
	l_trip_name             VARCHAR2(32767);
	l_trip_segment_name             VARCHAR2(32767);
	--
	l_validate_stop_index       NUMBER;
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_trip_count                NUMBER;
	l_return_status             VARCHAR2(32767);
	l_validation_required       BOOLEAN := FALSE;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_new_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
	--
	CURSOR get_prev_segments_cur
		(
		  p_trip_id IN NUMBER,
		  p_sequencE_number IN NUMBER
		)
	IS
	SELECT b.status_code, b.trip_id, b.name wsh_trip_name
	FROM   fte_wsh_trips a, wsh_trips b
	WHERE  a.fte_trip_id = p_trip_id
	AND    a.sequence_number < p_sequence_number
	AND    a.wsh_trip_id = b.trip_id;
	--
	--
	--
	CURSOR get_segment_info_cur
		 (
		   p_segment_id IN NUMBER
		 )
	IS
	SELECT status_code, name
	FROM   wsh_trips
	WHERE  trip_id = p_segment_id;
	--
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	l_trip_segment_name := p_new_trip_segment_rec.name;
	--
	--
	--
	IF
	   (
             (
	        p_old_trip_segment_rec.carrier_id IS NOT NULL
		AND p_old_trip_segment_rec.carrier_id <> NVL(p_new_trip_segment_rec.carrier_id,-999)
	     )
	     OR
             (
	        p_old_trip_segment_rec.mode_of_transport IS NOT NULL
		AND p_old_trip_segment_rec.mode_of_transport <> NVL(p_new_trip_segment_rec.mode_of_transport,'!-')
	     )
	     OR
             (
	        p_old_trip_segment_rec.service_level IS NOT NULL
		AND p_old_trip_segment_rec.service_level <> NVL(p_new_trip_segment_rec.service_level,'!-')
	     )
	   )
	THEN
	--{
	    IF p_new_trip_segment_rec.lane_id IS NOT NULL
	    AND p_old_trip_segment_rec.lane_id IS NOT NULL
	    THEN
	    --{
	    	-- Release 12: Added so that FTE can update lane_id without first having to null out lane_id
	    	IF p_new_trip_segment_rec.lane_id = p_old_trip_segment_rec.lane_id
	    	AND NVL(p_new_trip_segment_rec.ship_method_code, '!-') <> NVL(p_old_trip_segment_rec.ship_method_code,'!-')
	    	THEN
  		  FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_CSM_CHANGE_ERROR');
		  FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_new_trip_segment_rec.name);
	          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		  l_number_of_errors := l_number_of_errors + 1;
		END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	--
	IF p_old_trip_segment_rec.status_code <> p_new_trip_segment_rec.status_code
	THEN
	--{
            FOR get_segment_trips_rec IN get_segment_trips_cur
	    LOOP
	    --{
		l_trip_name := get_segment_trips_rec.fte_trip_name;
		--
		--
		IF p_new_trip_segment_rec.status_code = 'IT'
		THEN
		--{
		    FOR get_prev_segments_rec
		    IN get_prev_segments_cur
			  (
			    p_trip_id => get_segment_trips_rec.fte_trip_id,
		            p_sequence_number => get_segment_trips_rec.sequence_number
			  )
		    LOOP
		    --{
			    IF get_prev_segments_rec.status_code <> 'CL'
			    THEN
			    --{
		                FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_PREV_CLOSE_ERROR');
		                FND_MESSAGE.SET_TOKEN('PREV_TRIP_SEG_NAME', get_prev_segments_rec.wsh_trip_name);
		                FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_new_trip_segment_rec.name);
		                FND_MESSAGE.SET_TOKEN('TRIP_NAME', get_segment_trips_rec.fte_trip_name);
	                        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
		                l_number_of_warnings := l_number_of_warnings + 1;
			    --}
			    END IF;
		    --}
		    END LOOP;
		    --
		    --
		    UPDATE fte_trips
		    SET    status_code = 'IT',
			   last_update_date = sysdate,
			   last_updated_by = FND_GLOBAL.USER_ID,
			   last_update_login = FND_GLOBAL.LOGIN_ID
		    WHERE  fte_trip_id = get_segment_trips_rec.fte_trip_id
		    AND    status_code = 'OP';
		    --
		    --
		    IF SQL%ROWCOUNT > 0
		    THEN
		    --{
		        --
		        --
		        fte_trips_pvt.validate_trip
		          (
		            p_trip_id => get_segment_trips_rec.fte_trip_id,
		            x_return_status => l_return_status,
			    x_msg_count => l_msg_count,
			    x_msg_data => l_msg_data
		          );
	                --
	                --
                        FTE_MLS_UTIL.api_post_call
		            (
		              p_api_name           => 'FTE_TRIPS_PVT.VALIDATE_TRIP',
		              p_api_return_status  => l_return_status,
		              p_message_name       => 'FTE_TRIP_SEGMENT_UNEXP_ERROR',
		              p_trip_segment_id    => p_new_trip_segment_rec.trip_id,
		              p_trip_segment_name  => p_new_trip_segment_rec.name,
		              p_trip_id            => get_segment_trips_rec.fte_trip_id,
		              p_trip_name          => get_segment_trips_rec.fte_trip_name,
		              x_number_of_errors   => l_number_of_errors,
		              x_number_of_warnings => l_number_of_warnings,
		              x_return_status      => x_return_status
		            );
	                --
	                --
	                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	                THEN
	                --{
		            RETURN;
	                --}
	                END IF;
		    --}
		    END IF;
		--}
		ELSIF p_new_trip_segment_rec.status_code = 'CL'
		THEN
		--{
		    IF
		    (
                      fte_mls_util.all_other_segments_closed
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_id         => p_new_trip_segment_rec.trip_id
		      )
		    )
		    THEN
		    --{
		        UPDATE fte_trips
		        SET    status_code = 'CL',
			       last_update_date = sysdate,
			       last_updated_by = FND_GLOBAL.USER_ID,
			       last_update_login = FND_GLOBAL.LOGIN_ID
		        WHERE  fte_trip_id = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
		--}
		END IF;
	    --}
	    END LOOP;
	--}
	END IF;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_SEGMENT_UPDATE');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_segment_update;
    --
    --
    PROCEDURE validate_segment_delete
		(
	          P_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          x_return_status	   OUT NOCOPY  VARCHAR2
		)
    IS
    --{
	--
	l_next_segment_id       NUMBER;
	l_previous_segment_id       NUMBER;
	l_trip_name             VARCHAR2(32767);
	l_trip_segment_name             VARCHAR2(32767);
	--
	--
	l_trip_count                NUMBER;
	l_msg_count                NUMBER;
	l_msg_data                varchar2(32767);
	l_return_status             VARCHAR2(32767);
	l_validation_required       BOOLEAN := FALSE;
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
	CURSOR get_segment_trips_cur
	IS
	SELECT b.fte_trip_id, sequence_number, b.name fte_trip_name
	FROM   fte_wsh_trips a, fte_trips b
	WHERE  a.wsh_trip_id = p_trip_segment_rec.trip_id
	AND    a.fte_trip_id = b.fte_trip_id;
	--
	--
	--
	CURSOR get_segment_info_cur
		 (
		   p_segment_id IN NUMBER
		 )
	IS
	SELECT status_code, name
	FROM   wsh_trips
	WHERE  trip_id = p_segment_id;
	--
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	l_trip_segment_name := p_trip_segment_rec.name;
	--
	--
	--
            FOR get_segment_trips_rec IN get_segment_trips_cur
	    LOOP
	    --{
		l_trip_name := get_segment_trips_rec.fte_trip_name;
		--
		--
		--{
                    fte_wsh_trips_pvt.delete_trip
		      (
		        p_fte_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_wsh_trip_id         => p_trip_segment_rec.trip_id,
	                x_return_status	          => l_return_status,
			    x_msg_count => l_msg_count,
			    x_msg_data => l_msg_data
		      );
                    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_WSH_TRIPS_PUB.DELETE_TRIP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_TRIP_SEGMENT_UNEXP_ERROR',
		          p_trip_segment_id    => p_trip_segment_rec.trip_id,
		          p_trip_segment_name  => p_trip_segment_rec.name,
		          p_trip_id            => get_segment_trips_rec.fte_trip_id,
		          p_trip_name          => get_segment_trips_rec.fte_trip_name,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            THEN
	            --{
		        RETURN;
	            --}
	            END IF;
		    --
		    --
		    IF
		    (
                      fte_mls_util.all_other_segments_closed
		      (
		        p_trip_id                 => get_segment_trips_rec.fte_trip_id,
	                P_trip_segment_id         => p_trip_segment_rec.trip_id
		      )
		    )
		    THEN
		    --{
		         UPDATE fte_trips
		         SET    status_code = 'CL',
			        last_update_date = sysdate,
			        last_updated_by = FND_GLOBAL.USER_ID,
			        last_update_login = FND_GLOBAL.LOGIN_ID
		        WHERE  fte_trip_id = get_segment_trips_rec.fte_trip_id;
		    --}
		    END IF;
		--}
	    --}
	    END LOOP;
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.VALIDATE_SEGMENT_DELETE');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END validate_segment_delete;
    --
    --
    PROCEDURE trip_segment_change
		(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          P_commit		    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT NOCOPY	   VARCHAR2,
	          X_msg_count		    OUT NOCOPY	   NUMBER,
	          X_msg_data		    OUT NOCOPY	   VARCHAR2,
	          P_old_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_new_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_tripSegmentChangeInRec  IN     tripSegmentChangeInRecType,
		  p_tripSegmentChangeOutRec OUT NOCOPY    tripSegmentChangeOutRecType
		)
    IS
    --{
        l_api_name              CONSTANT VARCHAR2(30)   := 'TRIP_SEGMENT_CHANGE';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
	p_action_type               VARCHAR2(32767);
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
	--
    --}
    BEGIN
    --{
	--
	--
        -- Standard Start of API savepoint
        SAVEPOINT   TRIP_SEGMENT_CHANGE_PUB;
	--
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	--
	--
        -- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;
	--
	--
        --  Initialize API return status to success
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	p_action_type := p_tripSegmentChangeInRec.action_type;
	--
	--
        -- Start of API body.
	--
	--
	--
	IF p_action_type = G_ADD
	THEN
	--{
	    NULL;
	--}
	ELSIF p_action_type =  G_UPDATE
	THEN
	--{
	    l_program_name := 'FTE_WSH_INTERFACE_PKG.VALIDATE_SEGMENT_UPDATE';
	    --
	    --
	    validate_segment_update
	      (
	          P_old_trip_segment_rec       => p_old_trip_segment_rec,
	          P_new_trip_segment_rec       => p_new_trip_segment_rec,
	          X_return_status	   => l_return_status
	      );
	--}
	ELSIF p_action_type =  G_DELETE
	THEN
	--{
	    l_program_name := 'FTE_WSH_INTERFACE_PKG.VALIDATE_SEGMENT_DELETE';
	    --
	    --
	    validate_segment_delete
	      (
	          P_trip_segment_rec       => p_old_trip_segment_rec,
	          X_return_status	   => l_return_status
	      );
	--}
	ELSE
	--{
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_WSH_IF_INVALID_ACTION');
	    FND_MESSAGE.SET_TOKEN('ACTION_TYPE', p_action_type);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
	    --RETURN;
	--}
	END IF;
	--
	--
            FTE_MLS_UTIL.api_post_call
		(
		  p_api_name           => l_program_name,
		  p_api_return_status  => l_return_status,
		  p_message_name       => 'FTE_SEGMENT_UNEXP_ERROR',
		  p_trip_segment_id    => p_old_trip_segment_rec.trip_id,
		  p_trip_segment_name  => p_old_trip_segment_rec.name,
		  x_number_of_errors   => l_number_of_errors,
		  x_number_of_warnings => l_number_of_warnings,
		  x_return_status      => x_return_status
		);
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--
	--
	--
	--
	--
	--
	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
	--
	--
	--
	--
        -- End of API body.
	--
	--
        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
	--
	--
        -- Standard call to get message count and if count is 1,get message info.
	--
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
	--
	--
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO TRIP_SEGMENT_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO TRIP_SEGMENT_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO TRIP_SEGMENT_CHANGE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.TRIP_SEGMENT_CHANGE');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	       --
	       --
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
    --}
    END trip_segment_change;
    --
    --
--}
--{
-- Rel12 HBHAGAVA

-------------
--========================================================================
-- PROCEDURE : GET_ORG_ORGANIZATION_INFO
--
-- COMMENT   : Return back org id and organization id associated with an
--              entity: TRIP, STOP, DELIVERY, or DETAIL.
-- CREATED BY: HBHAGAVA
-- MODIFIED :
-- DESC:       This procedure returns back org and organization id for the
--             entity.
--	       To get org id, calling API has to set P_ORG_ID_FLAG
--                 to FND_API.G_TRUE
--========================================================================


PROCEDURE GET_ORG_ORGANIZATION_INFO(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_organization_id	     OUT NOCOPY		NUMBER,
	    x_org_id		     OUT NOCOPY		NUMBER,
	    p_entity_id	     	     IN			NUMBER,
	    p_entity_type	     IN			VARCHAR2,
	    p_org_id_flag	     IN			VARCHAR2 DEFAULT FND_API.G_FALSE)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_TRIP_ORG_ORGANIZATION';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_trip_id                   NUMBER;
l_org_id		    NUMBER;



CURSOR GET_ORG_ID(c_organization_id NUMBER) IS
	SELECT DECODE(FPG.MULTI_ORG_FLAG,'Y',
		DECODE(HOI2.ORG_INFORMATION_CONTEXT,'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION3),
			TO_NUMBER(NULL)),
			TO_NUMBER(NULL)) OPERATING_UNIT
	FROM HR_ORGANIZATION_UNITS HOU,
		HR_ORGANIZATION_INFORMATION HOI2,
		FND_PRODUCT_GROUPS FPG
	WHERE HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
	AND( HOI2.ORG_INFORMATION_CONTEXT || '')='Accounting Information'
	AND HOU.ORGANIZATION_ID =c_organization_id;

BEGIN


	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;
	l_trip_id               := NULL;
        l_org_id                := NULL;

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' FTE_MLS_UTIL.GET_TRIP_ORGANIZATION_ID for entity ' ||
						p_entity_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF (p_entity_type IN ('TRIP', 'STOP'))
	THEN
        --{
           IF (p_entity_type = 'TRIP')  THEN
              l_trip_id := p_entity_id;
           ELSIF (p_entity_type = 'STOP')
	   THEN
		BEGIN
			SELECT TRIP_ID INTO l_trip_id
			FROM WSH_TRIP_STOPS
			WHERE STOP_ID = p_entity_id;

			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_STOP');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				wsh_util_core.add_message(x_return_status);
				RAISE FND_API.G_EXC_ERROR;
		END;
           END IF;

	   x_organization_id := FTE_MLS_UTIL.GET_TRIP_ORGANIZATION_ID(l_trip_id);

	--}
	ELSIF (p_entity_type = 'DELIVERY')
	THEN
		BEGIN

			SELECT ORGANIZATION_ID INTO X_ORGANIZATION_ID
			FROM WSH_NEW_DELIVERIES
			WHERE DELIVERY_ID = p_entity_id;

			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_DLVY');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				wsh_util_core.add_message(x_return_status);
				RAISE FND_API.G_EXC_ERROR;
		END;
	ELSIF (p_entity_type = 'DETAIL')
	THEN
		BEGIN

			SELECT ORGANIZATION_ID,
                               ORG_ID INTO X_ORGANIZATION_ID, L_ORG_ID
			FROM WSH_DELIVERY_DETAILS
			WHERE DELIVERY_DETAIL_ID = p_entity_id;

			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_DETAIL');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				wsh_util_core.add_message(x_return_status);
				RAISE FND_API.G_EXC_ERROR;
		END;
	END IF;


	IF ( (X_ORGANIZATION_ID IS NOT NULL)
	   AND (p_org_id_flag = FND_API.G_TRUE))
	THEN
	     IF (l_org_id IS NOT NULL)  THEN
               x_org_id := l_org_id;
             ELSE
			OPEN  GET_ORG_ID(x_organization_id);
			FETCH GET_ORG_ID INTO x_org_id;

			IF (GET_ORG_ID%NOTFOUND) THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_ORG_ID_NOTFOUND');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				wsh_util_core.add_message(x_return_status);
			END IF;

			CLOSE GET_ORG_ID;
             END IF;

	END IF;

	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	wsh_util_core.default_handler('FTE_WSH_INTERFACE_PKG.GET_TRIP_ORG_ORGANIZATION');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

END GET_ORG_ORGANIZATION_INFO;

--}

END FTE_WSH_INTERFACE_PKG;

/
