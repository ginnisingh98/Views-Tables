--------------------------------------------------------
--  DDL for Package Body FTE_MLS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_MLS_UTIL" AS
/* $Header: FTEMLUTB.pls 120.6 2006/05/11 17:10:51 nltan ship $ */
--{

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_MLS_UTIL';

    --
    --
    PROCEDURE api_post_call
		(
		  p_api_name           IN     VARCHAR2,
		  p_api_return_status  IN     VARCHAR2,
		  p_message_name       IN     VARCHAR2,
		  p_trip_segment_id    IN     VARCHAR2 DEFAULT NULL,
		  p_trip_segment_name  IN     VARCHAR2 DEFAULT NULL,
		  p_trip_stop_id       IN     NUMBER DEFAULT NULL,
		  p_stop_seq_number    IN     NUMBER DEFAULT NULL,
		  p_trip_id            IN     VARCHAR2 DEFAULT NULL,
		  p_trip_name          IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_id        IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_name      IN     VARCHAR2 DEFAULT NULL,
		  x_number_of_errors   IN OUT NOCOPY  NUMBER,
		  x_number_of_warnings IN OUT NOCOPY  NUMBER,
		  x_return_status      OUT NOCOPY     VARCHAR2
		)
    IS
    BEGIN
    --{
	    IF p_api_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        IF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
	        THEN
	        --{
		    x_number_of_warnings := x_number_of_warnings + 1;
	        --}
	        ELSE
	        --{
	            IF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
		    THEN
		    --{
		        FND_MESSAGE.SET_NAME('FTE', p_message_name );
		        FND_MESSAGE.SET_TOKEN('PROGRAM_UNIT_NAME', p_api_name);
			--
			--
			IF p_trip_segment_id IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID', p_trip_segment_id);
			END IF;
			--
			--
			IF p_trip_segment_name IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', p_trip_segment_name);
			END IF;
			--
			--
			IF p_trip_stop_id IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('STOP_ID', p_trip_stop_id);
			END IF;
			--
			--
			IF p_stop_seq_number IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('STOP_SEQUENCE_NUMBER', p_stop_seq_number);
			END IF;
			--
			--
			IF p_trip_id IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('TRIP_ID', p_trip_id);
			END IF;
			--
			--
			IF p_trip_name IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('TRIP_NAME', p_trip_name);
			END IF;
			--
			--
			IF p_delivery_id IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
			END IF;
			--
			--
			IF p_delivery_name IS NOT NULL
			THEN
		            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', p_delivery_name);
			END IF;
			--
			--
	                WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
		        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			RETURN;
		    --}
		    ELSE
		        x_number_of_errors := x_number_of_errors + 1;
		    END IF;
	        --}
	        END IF;
	    --}
	    END IF;
    --}
    EXCEPTION
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.API_POST_CALL');
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END api_post_call;
    --
    --
    PROCEDURE get_trip_segment_name
		(
		  p_trip_segment_id                 IN     NUMBER,
	          x_trip_segment_name      	    OUT NOCOPY 	   VARCHAR2,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_trip_segment_name   VARCHAR2(32767);
	--
	--
	CURSOR get_trip_segment_cur
	IS
	SELECT name
	FROM   wsh_trips
	WHERE  trip_id = p_trip_segment_id;
    --}
    BEGIN
    --{
	l_trip_segment_name := NULL;
	--
	FOR get_trip_segment_rec IN get_trip_segment_cur
	LOOP
	--{
	    l_trip_segment_name := get_trip_segment_rec.name;
	--}
	END LOOP;
	--
	--
	IF l_trip_segment_name IS NULL
	THEN
	    RAISE NO_DATA_FOUND;
	END IF;
	--
	--
	x_trip_segment_name     := l_trip_segment_name;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_TRIP_SEGMENT_NAME');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_TRIP_SEG_NAME_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID',p_trip_segment_id);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_trip_segment_name;
    --
    --
    FUNCTION all_other_segments_closed
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_trip_id                 IN     NUMBER
		)
    RETURN BOOLEAN
    IS
    --{
	CURSOR check_other_segments_cur
	IS
	SELECT 1
	FROM   fte_wsh_trips a, wsh_trips b
	WHERE  a.fte_trip_id = p_trip_id
	AND    a.wsh_trip_id <> p_trip_segment_id
	AND    a.wsh_trip_id = b.trip_id
	AND    b.status_code IN ('OP','IT');
    --}
    BEGIN
    --{
	FOR check_other_segments_rec IN check_other_segments_cur
	LOOP
	--{
	    RETURN(FALSE);
	--}
	END LOOP;
	--
	--
	RETURN(TRUE);
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	    RAISE;
    --}
    END all_other_segments_closed;
    --
    --
    --IF x_next_segment_id IS NULL, it implies there is no next segment
    --
    --


    PROCEDURE get_next_segment_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_trip_id                 IN     NUMBER,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_next_segment_id	    OUT NOCOPY 	   NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_next_segment_cur
	IS
	SELECT wsh_trip_id
	FROM   fte_wsh_trips
	WHERE  fte_trip_id = p_trip_id
	AND    sequence_number = ( select min(sequence_number)
				   from fte_wsh_trips
				   where fte_trip_id = p_trip_id
				   and   sequence_number > p_sequence_number );
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_name IS NULL
	THEN
	--{
	    fte_trips_pvt.get_trip_name
	      (
	        p_trip_id         => p_trip_id,
	        x_trip_name       => x_trip_name,
	        x_return_status	  => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	x_next_segment_id := NULL;
	--
	FOR get_next_segment_rec IN get_next_segment_cur
	LOOP
	--{
	    x_next_segment_id := get_next_segment_rec.wsh_trip_id;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('WSH_MLS_UTIL.GET_NEXT_SEGMENT_ID');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_NEXT_SEGMENT_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',x_trip_name);
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_next_segment_id;
    --
    --
    --IF x_previous_segment_id IS NULL, it implies there is no previous segment
    --
    --
    PROCEDURE get_previous_segment_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_trip_id                 IN     NUMBER,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_previous_segment_id	    OUT NOCOPY 	   NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_previous_segment_cur
	IS
	SELECT wsh_trip_id
	FROM   fte_wsh_trips
	WHERE  fte_trip_id = p_trip_id
	AND    sequence_number = ( select max(sequence_number)
				   from fte_wsh_trips
				   where fte_trip_id = p_trip_id
				   and   sequence_number < p_sequence_number );
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_name IS NULL
	THEN
	--{
	    fte_trips_pvt.get_trip_name
	      (
	        p_trip_id         => p_trip_id,
	        x_trip_name       => x_trip_name,
	        x_return_status	  => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	x_previous_segment_id := NULL;
	--
	--
	FOR get_previous_segment_rec IN get_previous_segment_cur
	LOOP
	--{
	    x_previous_segment_id := get_previous_segment_rec.wsh_trip_id;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_PREVIOUS_SEGMENT_ID');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_NEXT_SEGMENT_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',x_trip_name);
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_previous_segment_id;
    --
    --
    --IF x_first_stop_location_id IS NULL, it implies there are no stops
    --
    --
    PROCEDURE get_first_stop_location_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
		  x_first_stop_location_id  OUT NOCOPY     NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_first_stop_cur
		(
		  p_segment_id IN NUMBER
		)
	IS
	SELECT stop_id, stop_location_id
	FROM   wsh_trip_stops
	WHERE  trip_id =  p_segment_id
	AND    stop_sequence_number = ( select min(stop_sequence_number)
				   from wsh_trip_stops
				   where trip_id = p_segment_id );
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	x_first_stop_location_id := NULL;
	--
	--
	FOR get_first_stop_rec IN get_first_stop_cur ( p_trip_segment_id )
	LOOP
	--{
	    x_first_stop_location_id := get_first_stop_rec.stop_location_id;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_FIRST_STOP_LOCATION_ID');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_FIRST_STOP_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_first_stop_location_id;
    --
    --
    --IF x_last_stop_location_id IS NULL, it implies there are no stops
    --
    --
    PROCEDURE get_last_stop_location_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
		  x_last_stop_location_id   OUT NOCOPY      NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_last_stop_cur
		(
		  p_segment_id IN NUMBER
		)
	IS
	SELECT stop_id, stop_location_id
	FROM   wsh_trip_stops
	WHERE  trip_id =  p_segment_id
	AND    stop_sequence_number = ( select max(stop_sequence_number)
				   from wsh_trip_stops
				   where trip_id = p_segment_id );

    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	x_last_stop_location_id := NULL;
	--
	FOR get_last_stop_rec IN get_last_stop_cur ( p_trip_Segment_id )
	LOOP
	--{
	    x_last_stop_location_id := get_last_stop_rec.stop_location_id;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_LAST_STOP_LOCATION_ID');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_LAST_STOP_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_last_stop_location_id;
    --
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_id         : WSH Trip ID
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_last_stop_location_id   : Last Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    --
    PROCEDURE check_next_segment
		(
		  p_trip_id                 IN     NUMBER,
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_last_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status           VARCHAR2(32767);
	l_next_segment_id         NUMBER;
	l_next_segment_name       VARCHAR2(32767);
	l_first_stop_location_id  NUMBER;
	l_last_stop_location_id   NUMBER;
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_name IS NULL
	THEN
	--{
	    fte_trips_pvt.get_trip_name
	      (
	        p_trip_id         => p_trip_id,
	        x_trip_name       => x_trip_name,
	        x_return_status	  => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	-- Get Next Segment in the Trip
	--
	get_next_segment_id
	  (
	    P_trip_segment_id     => p_trip_segment_id ,
	    p_sequence_number     => p_sequence_number,
	    p_trip_id             => p_trip_id,
	    x_trip_name           => x_trip_name,
	    x_trip_segment_name   => x_trip_segment_name,
	    x_next_segment_id	  => l_next_segment_id,
	    x_return_status	  => l_return_status
	  );
	--
	--
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	--{
	    x_return_status := l_return_status;
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--dbms_output.put_line('l_next_segment_id='||l_next_segment_id);
	--
	IF l_next_segment_id IS NOT NULL
	THEN
	--{
	    --
	    -- Get First stop of the Next Segment in the Trip
	    --
	    get_first_stop_location_id
	      (
	        P_trip_segment_id        => l_next_segment_id,
	        x_trip_segment_name      => l_next_segment_name,
	        x_first_stop_location_id => l_first_stop_location_id,
	        x_return_status	         => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	    --
	--dbms_output.put_line('l_first_stop_location_id='||l_first_stop_location_id);
	    --
	    IF l_first_stop_location_id IS NULL
	    THEN
		x_connected := FALSE;
		RETURN;
	    END IF;
	    --
	    --
	    IF p_last_stop_location_id IS NULL
	    THEN
	    --{
	        -- Get Last stop of the current Segment
	        --
	        get_last_stop_location_id
	          (
	            P_trip_segment_id        => p_trip_segment_id,
	            x_trip_segment_name      => x_trip_segment_name,
	            x_last_stop_location_id  => l_last_stop_location_id,
	            x_return_status	     => l_return_status
	          );
	    --}
	    ELSE
	    --{
	        l_last_stop_location_id := p_last_stop_location_id;
	    --}
	    END IF;
	    --
	    --
	    IF l_last_stop_location_id IS NULL
	    THEN
		x_connected := FALSE;
		RETURN;
	    END IF;
	    --
	    --
	    IF l_first_stop_location_id <> l_last_stop_location_id
	    THEN
	    --{
		x_connected := FALSE;
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.CHECK_NEXT_SEGMENT');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END check_next_segment;
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_rec        : WSH Trip REcord
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_last_stop_location_id   : Last Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    PROCEDURE check_next_segment
		(
		  p_trip_id                 IN     NUMBER,
	          p_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_sequence_number         IN     NUMBER,
		  p_last_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_trip_segment_name       VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_trip_segment_name := p_trip_segment_rec.name;
	--
	--
	check_next_segment
	  (
	    p_trip_id                => p_trip_id,
	    P_trip_segment_id        => p_trip_segment_rec.trip_id ,
	    p_sequence_number        => p_sequence_number,
	    p_last_stop_location_id  => p_last_stop_location_id,
	    x_trip_name              => x_trip_name,
	    x_trip_segment_name      => l_trip_segment_name,
            x_connected	             => x_connected,
	    x_return_status	     => x_return_status
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.CHECK_NEXT_SEGMENT');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END check_next_segment;
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_id         : WSH Trip ID
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_first_stop_location_id  : First Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    PROCEDURE check_previous_segment
		(
		  p_trip_id                 IN     NUMBER,
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_first_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_return_status           VARCHAR2(32767);
	l_previous_segment_id     NUMBER;
	l_prev_segment_name       VARCHAR2(32767);
	l_first_stop_location_id  NUMBER;
	l_last_stop_location_id   NUMBER;
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_name IS NULL
	THEN
	--{
	    fte_trips_pvt.get_trip_name
	      (
	        p_trip_id         => p_trip_id,
	        x_trip_name       => x_trip_name,
	        x_return_status	  => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
	        p_trip_segment_id         => p_trip_segment_id,
	        x_trip_segment_name       => x_trip_segment_name,
	        x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
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
	-- Get previous Segment in the Trip
	--
	get_previous_segment_id
	  (
	    P_trip_segment_id     => p_trip_segment_id ,
	    p_sequence_number     => p_sequence_number,
	    p_trip_id             => p_trip_id,
	    x_trip_name           => x_trip_name,
	    x_trip_segment_name   => x_trip_segment_name,
	    x_previous_segment_id	  => l_previous_segment_id,
	    x_return_status	  => l_return_status
	  );
	--
	--
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	--{
	    x_return_status := l_return_status;
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	    THEN
	    --{
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_previous_segment_id IS NOT NULL
	THEN
	--{
	    --
	    -- Get last stop of the previous Segment in the Trip
	    --
	    get_last_stop_location_id
	      (
	        P_trip_segment_id        => l_previous_segment_id,
	        x_trip_segment_name       => l_prev_segment_name,
	        x_last_stop_location_id => l_last_stop_location_id,
	        x_return_status	         => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
	        x_return_status := l_return_status;
	        --
	        --
	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	        THEN
	        --{
		    RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	    --
	    --
	    IF l_last_stop_location_id IS NULL
	    THEN
		x_connected := FALSE;
		RETURN;
	    END IF;
	    --
	    --
	    IF p_first_stop_location_id IS NULL
	    THEN
	    --{
	        -- Get first stop of the current Segment
	        --
	        get_first_stop_location_id
	          (
	            P_trip_segment_id        => p_trip_segment_id,
	            x_trip_segment_name      => x_trip_segment_name,
	            x_first_stop_location_id  => l_first_stop_location_id,
	            x_return_status	     => l_return_status
	          );
	    --}
	    ELSE
	    --{
	        l_first_stop_location_id := p_first_stop_location_id;
	    --}
	    END IF;
	    --
	    --
	    IF l_first_stop_location_id IS NULL
	    THEN
		x_connected := FALSE;
		RETURN;
	    END IF;
	    --
	    --
	    IF l_first_stop_location_id <> l_last_stop_location_id
	    THEN
	    --{
		x_connected := FALSE;
		RETURN;
	    --}
	    END IF;
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.CHECK_PREVIOUS_SEGMENT');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END check_previous_segment;
    --
    --
    PROCEDURE check_previous_segment
		(
		  p_trip_id                 IN     NUMBER,
	          p_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_sequence_number         IN     NUMBER,
		  p_first_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		)
    IS
    --{
	l_trip_segment_name       VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_trip_segment_name := p_trip_segment_rec.name;
	--
	--
	check_previous_segment
	  (
	    p_trip_id                => p_trip_id,
	    P_trip_segment_id        => p_trip_segment_rec.trip_id ,
	    p_sequence_number        => p_sequence_number,
	    p_first_stop_location_id  => p_first_stop_location_id,
	    x_trip_name              => x_trip_name,
	    x_trip_segment_name      => l_trip_segment_name,
            x_connected	             => x_connected,
	    x_return_status	     => x_return_status
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.CHECK_PREVIOUS_SEGMENT');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END check_previous_segment;
    --
    --
    FUNCTION segment_has_intransit_dlvy
		(
	          P_trip_segment_rec        IN	   WSH_TRIPS_GRP.Trip_Pub_Rec_Type
		)
    RETURN BOOLEAN
    IS
    --{
	CURSOR intransit_deliveries_cur
	IS
	SELECT 'x'
	FROM   wsh_trip_stops WTS,
	       wsh_delivery_legs  WDL,
	       wsh_new_deliveries WND
	WHERE  WTS.trip_id      = p_trip_segment_rec.trip_id
	AND    WND.delivery_id  = WDL.delivery_id
	AND    WND.status_code IN ( 'IT', 'CL' )
	AND    (
		    WDL.pick_up_stop_id  = WTS.STOP_ID
	         OR WDL.drop_off_stop_id = WTS.STOP_ID
	       );
    --}
    BEGIN
    --{
	FOR intransit_deliveries_rec IN intransit_deliveries_cur
	LOOP
	--{
	    RETURN TRUE;
	--}
	END LOOP;
	--
	--
	RETURN FALSE;
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.SEGMENT_HAS_INTRANSIT_DLVY');
	    RAISE;
    --}
    END segment_has_intransit_dlvy;
    --
    --
    FUNCTION segment_has_other_deliveries
		(
	          P_trip_segment_id        IN	   NUMBER,
		  p_delivery_id            IN      NUMBER
		)
    RETURN BOOLEAN
    IS
    --{
	CURSOR deliveries_cur
	IS
	SELECT 'x'
	FROM   wsh_trip_stops WTS,
	       wsh_delivery_legs  WDL
	WHERE  WTS.trip_id       = p_trip_segment_id
	AND    WDL.delivery_id  <> p_delivery_id
	AND    (
		    WDL.pick_up_stop_id  = WTS.STOP_ID
	         OR WDL.drop_off_stop_id = WTS.STOP_ID
	       );
    --}
    BEGIN
    --{
	FOR deliveries_rec IN deliveries_cur
	LOOP
	--{
	    RETURN TRUE;
	--}
	END LOOP;
	--
	--
	RETURN FALSE;
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.SEGMENT_HAS_OTHER_DELIVERIES');
	    RAISE;
    --}
    END segment_has_other_deliveries;
    --
    --
    FUNCTION stop_has_intransit_dlvy
		(
	          P_trip_stop_rec        IN	   WSH_TRIP_STOPS_GRP.Trip_stop_Pub_Rec_Type
		)
    RETURN BOOLEAN
    IS
    --{
    --}
    BEGIN
    --{
        RETURN
	  (
	    stop_has_intransit_dlvy
	      (
		p_trip_stop_id => p_trip_stop_rec.stop_id
	      )
	  );
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.STOP_HAS_INTRANSIT_DLVY');
	    RAISE;
    --}
    END stop_has_intransit_dlvy;
    --
    --
    FUNCTION stop_has_intransit_dlvy
		(
	          P_trip_stop_id        IN	   NUMBER
		)
    RETURN BOOLEAN
    IS
    --{
	CURSOR intransit_deliveries_cur
	IS
	SELECT 'x'
	FROM   wsh_delivery_legs  WDL,
	       wsh_new_deliveries WND
	WHERE  WND.delivery_id  = WDL.delivery_id
	AND    WND.status_code IN ( 'IT', 'CL' )
	AND    (
		    WDL.pick_up_stop_id  = p_trip_stop_id
	         OR WDL.drop_off_stop_id = p_trip_stop_id
	       );
    --}
    BEGIN
    --{
	FOR intransit_deliveries_rec IN intransit_deliveries_cur
	LOOP
	--{
	    RETURN TRUE;
	--}
	END LOOP;
	--
	--
	RETURN FALSE;
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.STOP_HAS_INTRANSIT_DLVY');
	    RAISE;
    --}
    END stop_has_intransit_dlvy;
    --
    --
    PROCEDURE derive_ship_method
		(
		  p_carrier_id                IN     NUMBER,
		  p_mode_of_transport         IN     VARCHAR2,
		  p_service_level             IN     VARCHAR2,
		  p_carrier_name              IN     VARCHAR2,
		  p_mode_of_transport_meaning IN     VARCHAR2,
		  p_service_level_meaning     IN     VARCHAR2,
		  x_ship_method_code          OUT NOCOPY     VARCHAR2,
	          x_return_status	      OUT NOCOPY     VARCHAR2
		)
    IS
    --{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_ship_method_cur
	IS
	SELECT ship_method_code
	FROM   wsh_carrier_services
	WHERE  carrier_id     = p_carrier_id
	AND    enabled_flag   = 'Y'
	AND    (
		  (
		         p_mode_of_transport IS NULL
		     AND mode_of_transport   IS NULL
		  )
		  OR
		  (
		         p_mode_of_transport IS NOT NULL
		     AND mode_of_transport = p_mode_of_transport
		  )
	       )
	AND    (
		  (
		         p_service_level IS NULL
		     AND service_level   IS NULL
		  )
		  OR
		  (
		          p_service_level IS NOT NULL
		     AND service_level = p_service_level
		  )
	       );
    --}
    BEGIN
    --{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	x_ship_method_code := NULL;
	--
	--
	IF p_carrier_id         IS NULL
	AND p_mode_of_transport IS NULL
	AND p_service_level     IS NULL
	THEN
	    RETURN;
	END IF;
	--
	--
	FOR get_ship_method_rec IN get_ship_method_cur
	LOOP
	--{
	    x_ship_method_code := get_ship_method_rec.ship_method_code;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.DERIVE_SHIP_METHOD_CODE');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_SHIPMETHOD_UNEXP_ERROR');
	    FND_MESSAGE.SET_TOKEN('CARRIER_NAME',p_carrier_name);
	    FND_MESSAGE.SET_TOKEN('MODE_OF_TRANSPORT',NVL(p_mode_of_transport_meaning,'NULL'));
	    FND_MESSAGE.SET_TOKEN('SERVICE_LEVEL',NVL(p_service_level_meaning,'NULL'));
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END derive_ship_method;
    --
    --
    --
    PROCEDURE get_location_info
		(
	          p_location_id		IN	NUMBER,
	          x_location		OUT NOCOPY 	VARCHAR2,
	          x_csz			OUT NOCOPY 	VARCHAR2,
	          x_country		OUT NOCOPY 	VARCHAR2,
	          x_return_status	OUT NOCOPY 	VARCHAR2
		)
    AS
    --{

	CURSOR get_location_cur (c_location_id NUMBER)
	IS
        SELECT  ui_location_code, address1,address2,
                address3,city,state,country,postal_code
        FROM    wsh_locations
        WHERE   wsh_location_id = c_location_id;

    --}
    BEGIN
    	x_location  := null;
    	x_csz	    := null;
    	x_country   := null;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --{
	FOR get_location_rec IN get_location_cur(p_location_id)
	LOOP
	--{
		IF ((get_location_rec.ui_location_code = '')
			OR (get_location_rec.ui_location_code IS NULL)) THEN
			x_location := nvl(get_location_rec.address1,'') ||
				nvl(', ' || get_location_rec.city, '') ||
				nvl(', ' || get_location_rec.state, '') ||
				nvl(', ' || get_location_rec.postal_code, '') ||
				nvl(', ' || get_location_rec.country,'');
		ELSE
			x_location := get_location_rec.ui_location_code;
		END IF;

		x_csz	   :=   nvl(get_location_rec.city, '') ||
				nvl(', ' || get_location_rec.state, '') ||
				nvl(', ' || get_location_rec.postal_code, '');

		x_country  := get_location_rec.country;
	--}
	END LOOP;
	--
	--
        IF get_location_cur%ISOPEN THEN
          CLOSE get_location_cur;
	END IF;
	--
	--
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_LOCATION');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_LOCATION_UNEXP_ERROR');
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_location_info;
    --
    --
    FUNCTION get_carrier_name
		(
	          p_carrier_id        IN	   NUMBER
		)
    RETURN VARCHAR2
    IS
    	l_carrier_name VARCHAR(200) := NULL;
    --{
	CURSOR get_carrier_name_cur(c_carrier_id NUMBER)
	IS
	SELECT hz.party_name name
	FROM   hz_parties hz, wsh_carriers wc
	WHERE  hz.party_id = wc.carrier_id
	AND    wc.carrier_id =  c_carrier_id;
    --}
    BEGIN
    --{
	FOR get_carrier_name_rec IN get_carrier_name_cur(p_carrier_id)
	LOOP
	--{
	     l_carrier_name := get_carrier_name_rec.name;
	--}
	END LOOP;
	--
        IF get_carrier_name_cur%ISOPEN THEN
          CLOSE get_carrier_name_cur;
	END IF;
	--
	RETURN l_carrier_name;
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_CARRIER_NAME');
	    RAISE;
    --}
    END get_carrier_name;
    --
    --
    FUNCTION get_delivery_legs
		(
	          P_trip_segment_id         IN	   NUMBER
		)
    RETURN VARCHAR2
    IS
    --{
	x_return	VARCHAR2(32767);

	CURSOR get_deliveries_cur(c_trip_segment_id	NUMBER)
	IS
	   Select delivery_leg_id
	   from   wsh_delivery_legs wdl, wsh_trip_stops wts1, wsh_trip_stops wts2,wsh_trips wt
	   where  wdl.pick_up_stop_id    = wts1.stop_id
	   and    wdl.drop_off_stop_id   = wts2.stop_id
	   and    wts1.trip_id           = wt.trip_id
	   and    wts2.trip_id           = wt.trip_id
	   and    wt.trip_id             = c_trip_segment_id;
    --}
    BEGIN
    --{
    	x_return := null;

	FOR get_deliveries_rec IN get_deliveries_cur(P_trip_segment_id)
	LOOP
	--{
	    x_return := ''' || get_deliveries_rec.delivery_leg_id || '',' || x_return;
	--}
	END LOOP;
	--
	IF get_deliveries_cur%ISOPEN THEN
          CLOSE get_deliveries_cur;
	END IF;
	--
	RETURN x_return;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	    RAISE;
    --}
    END get_delivery_legs;
    --
    --
    FUNCTION get_message
		(
	          p_msg_count         IN	   NUMBER,
		  p_msg_data          IN     	   VARCHAR2
		)
    RETURN VARCHAR2
    IS

	l_msg	VARCHAR2(32767);
	l_msg_string	VARCHAR(32767);
    --{
    BEGIN

		IF ( p_msg_count > 1)
		THEN

		    FOR l_count IN 1..NVL(p_msg_count,0)
		    LOOP
		    --{
			 l_msg := substrb(FND_MSG_PUB.GET( p_encoded => FND_API.G_FALSE ),1,240);
			 l_msg_string := l_msg_string || ' : ' || l_msg;
		     --}
		     END LOOP;
		ELSE
		     l_msg_string := p_msg_data;
		END IF;

    		return l_msg_string;
    --}
    EXCEPTION
    --{
    	WHEN OTHERS THEN
    		RAISE;
    --}
    END get_message;
    --
    --
    FUNCTION GET_MODE_OF_TRANSPORT
		(
	          p_mode_code         IN	   VARCHAR2
		)
    RETURN VARCHAR2
    IS

	l_mode_meaning	VARCHAR(80) := NULL;

	CURSOR get_mode_of_transport_cur (c_mode_code VARCHAR2)
	IS
	SELECT meaning mode_of_transport_meaning
	FROM fnd_lookup_values_vl
	WHERE lookup_type = 'WSH_MODE_OF_TRANSPORT'
	AND lookup_code = c_mode_code;

    --{
    BEGIN

	--GET MODE OF TRANSPORT CODE
	--
		FOR get_mode_of_transport_rec IN get_mode_of_transport_cur(p_mode_code)
		LOOP
		--{
			l_mode_meaning := get_mode_of_transport_rec.mode_of_transport_meaning;
		--}
		END LOOP;
	--
	-- END OF MODE OF TRANSPORT

        IF get_mode_of_transport_cur%ISOPEN THEN
          CLOSE get_mode_of_transport_cur;
	END IF;

	return l_mode_meaning;
    --}
    EXCEPTION
    --{
    	WHEN OTHERS THEN
    		RAISE;
    --}
    END GET_MODE_OF_TRANSPORT;
    --
    --
    FUNCTION GET_SERVICE_LEVEL
		(
	          p_service_level         IN	   VARCHAR2
		)
    RETURN VARCHAR2
    IS

	l_service_level	VARCHAR(80) := NULL;

	-- GET Service Level
	--
	CURSOR get_service_level_cur (c_service_code VARCHAR2)
	IS
	SELECT meaning service_type_meaning
	FROM fnd_lookup_values_vl
	WHERE lookup_type = 'WSH_SERVICE_LEVELS'
	AND lookup_code = c_service_code;
	--

    --{
    BEGIN

	-- GET SERVICE LEVEL
	--
		FOR get_service_level_rec IN get_service_level_cur(p_service_level)
		LOOP
		--{
			l_service_level := get_service_level_rec.service_type_meaning;
		--}
		END LOOP;
	--
	-- END OF SERVICE LEVEL

        IF get_service_level_cur%ISOPEN THEN
          CLOSE get_service_level_cur;
	END IF;

	return l_service_level;
    --}
    EXCEPTION
    --{
    	WHEN OTHERS THEN
    		RAISE;
    --}
    END GET_SERVICE_LEVEL;
    --
    --
    --
    PROCEDURE get_location_info
		(
	          p_location_id		IN	NUMBER,
	          x_location		OUT NOCOPY 	VARCHAR2,
	          x_return_status	OUT NOCOPY 	VARCHAR2
		)
    AS
    --{

    	/**
    	PACK I -WSH_HR_LOCATION_V SHOULD NOT BE USED
    	USE WSH_LOCATIONS
	CURSOR get_location_cur (c_location_id NUMBER)
	IS
	SELECT  address_line_1,address_line_2,
		address_line_3,town_or_city,
		region_1,region_2,region_3,
		country,postal_code
	FROM	wsh_hr_locations_v
	WHERE  	location_id = c_location_id;
	**/
	CURSOR get_location_cur (c_location_id NUMBER)
	IS
	SELECT  address1,address2,
		address3,city,state,country,postal_code
	FROM	wsh_locations
	WHERE  	wsh_location_id = c_location_id;


    --}
    BEGIN
    	x_location  := null;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --{
	FOR get_location_rec IN get_location_cur(p_location_id)
	LOOP
	--{
		x_location := nvl(get_location_rec.address1,'') ||
				nvl(', ' || get_location_rec.city, '') ||
				nvl(', ' || get_location_rec.state, '') ||
				nvl(', ' || get_location_rec.postal_code, '') ||
				nvl(', ' || get_location_rec.country,'');
	--}
	END LOOP;
	--
	--
        IF get_location_cur%ISOPEN THEN
          CLOSE get_location_cur;
	END IF;
	--
	--
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_MLS_UTIL.GET_LOCATION');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_LOCATION_UNEXP_ERROR');
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --}
    END get_location_info;
    --


-- get the carrier information
PROCEDURE GET_CARRIER_CONTACT_INFO
		(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_tender_number		  IN	 NUMBER,
		x_return_status           OUT NOCOPY     VARCHAR2,
		x_msg_count               OUT NOCOPY     NUMBER,
		x_msg_data                OUT NOCOPY     VARCHAR2,
		x_contact_email		  OUT NOCOPY 	 VARCHAR2,
		x_contact_fax	  	  OUT NOCOPY 	 VARCHAR2,
		x_contact_phone		  OUT NOCOPY 	 VARCHAR2,
		x_contact_name		  OUT NOCOPY 	 VARCHAR2)
IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'GET_CARRIER_CONTACT_INFO';
        l_api_version           CONSTANT NUMBER         := 1.0;
	l_na_mssg		VARCHAR2(200);

	--}

	l_contact_id	NUMBER;

	-- cursor to get the contact id from the trip table
	CURSOR get_contact_id_cur (c_tender_number NUMBER)
	IS
	SELECT carrier_contact_id
	FROM wsh_trips
	WHERE load_tender_number = c_tender_number;
	---
	--Cursor to get the contact information
	CURSOR get_contact_info_cur (c_contact_id NUMBER)
	IS
	SELECT 	party_rel.party_name ContactName,
		hcp.email_address ContactEmail,
		hcp.contact_point_type ContactPointType
	FROM
		hz_relationships rel,
		hz_party_sites hps,
		hz_org_contacts hoc,
		hz_contact_points hcp,
		hz_parties party_rel
	WHERE
		hps.party_id = rel.object_id and
		hps.party_site_id = hoc.party_site_id and
		hoc.party_relationship_id = rel.relationship_id and
		party_rel.party_id = rel.subject_id and
		hcp.owner_table_id = rel.party_id and
		hcp.owner_table_name = 'HZ_PARTIES' and
		rel.party_id = c_contact_id;

	--{
	BEGIN
		--
	        -- Standard Start of API savepoint
	        SAVEPOINT   GET_CARRIER_CONTACT_INFO_PUB;
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
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		-- get default no contact info message
		FND_MESSAGE.SET_NAME('FTE', 'FTE_DELIVERIES_MULTIPLE_NA');
		l_na_mssg := FND_MESSAGE.GET;

		-- get contact id
		FOR get_contact_id_rec IN get_contact_id_cur(p_tender_number)
		LOOP
		--{
			l_contact_id := get_contact_id_rec.carrier_contact_id;
		--}
		END LOOP;

		-- END OF  get_contact_id_cur
		IF get_contact_id_cur%ISOPEN THEN
		  CLOSE get_contact_id_cur;
		END IF;
		--
		IF (l_contact_id IS NULL)
		THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_CARRIER_CONTACT');
			FND_MESSAGE.SET_TOKEN('TENDER_NUMBER',p_tender_number);
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		---
		-- get the contact info
		FOR get_contact_info_rec IN get_contact_info_cur(l_contact_id)
		LOOP
			--{
			x_contact_email := get_contact_info_rec.ContactEmail;
			x_contact_fax	:= l_na_mssg;
			x_contact_phone	:= l_na_mssg;
			x_contact_name	:= get_contact_info_rec.ContactName;
			--}
		END LOOP;
		-- END OF  get_contact_info_cur


		IF get_contact_info_cur%ISOPEN THEN
		  CLOSE get_contact_info_cur;
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




	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_CARRIER_CONTACT_INFO_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_CARRIER_CONTACT_INFO_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
       WHEN OTHERS THEN
                ROLLBACK TO GET_CARRIER_CONTACT_INFO_PUB;
                wsh_util_core.default_handler('FTE_MLS_UTIL.GET_CARRIER_CONTACT_INFO');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END GET_CARRIER_CONTACT_INFO;


-- get the carrier information
FUNCTION GET_ORG_NAME_BY_FIRSTSTOP
		(p_stop_id	IN	NUMBER)
RETURN VARCHAR2
IS
	--{
	--}

        CURSOR get_org_info_cur (c_stop_id IN NUMBER)
        IS
        SELECT distinct(org.name) org_name
        FROM wsh_delivery_legs dlegs, wsh_new_deliveries dlvy,
                wsh_trip_stops stops, hr_organization_units  org
        WHERE dlegs.delivery_id = dlvy.delivery_id
        AND dlegs.pick_up_stop_id  = stops.stop_id
        AND org.organization_id = dlvy.organization_id
        AND stops.stop_id = c_stop_id;

	l_org_name	VARCHAR2(1000);

	--{
	BEGIN
		--

		OPEN	get_org_info_cur(p_stop_id);
		FETCH get_org_info_cur
		INTO l_org_name;

		RETURN l_org_name;

	--}
	EXCEPTION
       WHEN OTHERS THEN
                wsh_util_core.default_handler('FTE_MLS_UTIL.GET_ORG_NAME_BY_FIRSTSTOP');
                RAISE;
	--}

END GET_ORG_NAME_BY_FIRSTSTOP;


-- get the carrier information
FUNCTION GET_PICKUP_DLVY_ORG_BY_TRIP
		(p_trip_id	IN	NUMBER)
RETURN VARCHAR2
IS
	--{
	--}

        CURSOR get_org_info_cur (c_trip_id IN NUMBER)
        IS
        SELECT distinct(org.name) org_name
        FROM wsh_delivery_legs dlegs, wsh_new_deliveries dlvy,
                wsh_trip_stops stops, hr_organization_units  org,
				wsh_trips trips
        WHERE dlegs.delivery_id = dlvy.delivery_id
        AND dlegs.pick_up_stop_id  = stops.stop_id
        AND org.organization_id = dlvy.organization_id
        AND stops.trip_id = trips.trip_id
	AND trips.trip_id = c_trip_id;

	l_org_name	VARCHAR2(1000);

	--{
	BEGIN
		--

		OPEN	get_org_info_cur(p_trip_id);
		FETCH get_org_info_cur
		INTO l_org_name;

		RETURN l_org_name;

	--}
	EXCEPTION
       WHEN OTHERS THEN
                wsh_util_core.default_handler('FTE_MLS_UTIL.GET_PICKUP_DLVY_ORG_BY_TRIP');
                RAISE;
	--}

END GET_PICKUP_DLVY_ORG_BY_TRIP;


-- get the carrier information
FUNCTION GET_PICKUP_DLVY_ORGID_BY_TRIP
		(p_trip_id	IN	NUMBER)
RETURN NUMBER
IS
	--{
	--}

        CURSOR get_org_info_cur (c_trip_id IN NUMBER)
        IS
        SELECT distinct(dlvy.organization_id) org_id
        FROM wsh_delivery_legs dlegs, wsh_new_deliveries dlvy,
                wsh_trip_stops stops, wsh_trips trips
        WHERE dlegs.delivery_id = dlvy.delivery_id
        AND dlegs.pick_up_stop_id  = stops.stop_id
        AND stops.trip_id = trips.trip_id
	AND trips.trip_id = c_trip_id;

	l_org_id	NUMBER;

	--{
	BEGIN
		--

		OPEN	get_org_info_cur(p_trip_id);
		FETCH get_org_info_cur
		INTO l_org_id;

		RETURN l_org_id;

	--}
	EXCEPTION
       WHEN OTHERS THEN
                wsh_util_core.default_handler('FTE_MLS_UTIL.GET_PICKUP_DLVY_ORGID_BY_TRIP');
                RAISE;
	--}

END GET_PICKUP_DLVY_ORGID_BY_TRIP;

    PROCEDURE GET_SHIPPER_CONTACT_INFO
		(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_shipper_name	  IN	 VARCHAR2,
		x_return_status           OUT NOCOPY     VARCHAR2,
		x_msg_count               OUT NOCOPY     NUMBER,
		x_msg_data                OUT NOCOPY     VARCHAR2,
		x_shipper_name		  OUT NOCOPY 	 VARCHAR2,
		x_contact_email		  OUT NOCOPY 	 VARCHAR2,
		x_contact_phone		  OUT NOCOPY 	 VARCHAR2,
		x_contact_fax		  OUT NOCOPY 	 VARCHAR2)
IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'GET_SHIPPER_CONTACT_INFO';
        l_api_version           CONSTANT NUMBER         := 1.0;
	l_na_mssg		VARCHAR2(200);
	l_shipper_email		VARCHAR2(200);
	l_shipper_fax 		VARCHAR2(200);
	l_shipper_name          VARCHAR2(200);
	l_shipper_phone         VARCHAR2(40);

	--}

	-- cursor to get the shipper email address and fax number
	CURSOR get_shipper_contact_cur (c_shipper_username VARCHAR2)
	IS
	SELECT fu.email_address as email,
	       fu.fax as fax,
	       nvl(hp.party_name,fu.user_name) as name,
	       hp.primary_phone_number as phone
	FROM   fnd_user fu,
	       hz_parties hp
	WHERE  fu.person_party_id = hp.party_id(+)
	and    fu.user_name = c_shipper_username;

	--{
	BEGIN
		--
	        -- Standard Start of API savepoint
	        SAVEPOINT  GET_SHIPPER_CONTACT_INFO_PUB;
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
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		-- get default no contact info message
		FND_MESSAGE.SET_NAME('FTE', 'FTE_DELIVERIES_MULTIPLE_NA');
		l_na_mssg := FND_MESSAGE.GET;

		-- get contact inf

		FOR get_shipper_contact_rec IN get_shipper_contact_cur(p_shipper_name)
		LOOP
		--{
			l_shipper_email := get_shipper_contact_rec.email;
			l_shipper_fax   := get_shipper_contact_rec.fax;
			l_shipper_phone := get_shipper_contact_rec.phone;
			l_shipper_name  := get_shipper_contact_rec.name;
		--}
		END LOOP;

		-- END OF  get_shipper_contact_cur

		IF get_shipper_contact_cur%ISOPEN THEN
		  CLOSE get_shipper_contact_cur;
		END IF;

		IF (l_shipper_email IS NULL)
		THEN
			l_shipper_email := l_na_mssg;
		END IF;

		IF (l_shipper_fax IS NULL)
		THEN
			l_shipper_fax := l_na_mssg;
		END IF;


		x_shipper_name  := l_shipper_name;
		x_contact_email := l_shipper_email;
		x_contact_fax   := l_shipper_fax;
		x_contact_phone := l_shipper_phone;



--		x_shipper_contact := p_shipper_name||', '||l_shipper_email||', '||l_shipper_fax;

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
		     	ROLLBACK TO GET_SHIPPER_CONTACT_INFO_PUB;
		     x_return_status := FND_API.G_RET_STS_ERROR ;
		     FND_MSG_PUB.Count_And_Get
		      (
		           p_count  => x_msg_count,
		           p_data  =>  x_msg_data,
			   p_encoded => FND_API.G_FALSE
		      );
		      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		         ROLLBACK TO GET_SHIPPER_CONTACT_INFO_PUB;
		      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		      FND_MSG_PUB.Count_And_Get
		       (
		            p_count  => x_msg_count,
		            p_data  =>  x_msg_data,
			    p_encoded => FND_API.G_FALSE
		       );
		      WHEN OTHERS THEN
		       	 ROLLBACK TO GET_SHIPPER_CONTACT_INFO_PUB;
		      wsh_util_core.default_handler('FTE_MLS_UTIL.GET_SHIPPER_CONTACT_INFO');
		      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		      FND_MSG_PUB.Count_And_Get
		       (
		             p_count  => x_msg_count,
		             p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
		       );

		--}

END GET_SHIPPER_CONTACT_INFO;



--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                GET_CARRIER_ID                    	              	   --
-- TYPE:                FUNCTION                                                   --
-- PARAMETERS (IN):     p_tender_id	NUMBER				           --
--                                                                                 --
-- PARAMETERS (OUT):    none                                                       --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              x_return	NUMBER                                     --
-- DESCRIPTION:         This procedure will fetch the carrier_id for the           --
--			corresponding load tender.	     			   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK            Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

FUNCTION GET_CARRIER_ID (
			p_tender_id IN NUMBER
			)
RETURN NUMBER
IS
--{
--{
	CURSOR get_carrier_id_cur(tender_id NUMBER) IS
	SELECT carrier_id
	FROM
	wsh_trips
	where load_tender_number = tender_id;

	l_carrier_id NUMBER;

--}
BEGIN
--{
        OPEN  get_carrier_id_cur(p_tender_id);
        FETCH get_carrier_id_cur into l_carrier_id;
	CLOSE get_carrier_id_cur;

	RETURN l_carrier_id;

--}

EXCEPTION
--{
	WHEN OTHERS THEN
	       wsh_util_core.default_handler('FTE_MLS_UTIL.GET_CARRIER_ID');
	RAISE;
--}

END GET_CARRIER_ID;

--}


--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                FTE_UOM_CONV                    	              	   --
-- TYPE:                FUNCTION                                                   --
-- PARAMETERS (IN):     p_from_quantity		NUMBER				   --
--			p_from_uom	VARCHAR2				   --
--			p_to_uom          VARCHAR2
--                                                                                 --
-- PARAMETERS (OUT):    none                                                       --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              x_return	NUMBER                                     --
-- DESCRIPTION:         This procedure will convert from_uom to milliseconds       --
--                      as a medium, then convert it to to_uom.                    --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   NLTAN               Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --
FUNCTION FTE_UOM_CONV
		(
	          p_from_quantity	IN NUMBER,
	          p_from_uom	IN VARCHAR2,
	          p_to_uom	IN VARCHAR2
		)
RETURN NUMBER
IS
--{
	x_return	NUMBER;
	l_time		NUMBER; -- medium converted value
	l_upper_from_uom	VARCHAR2(200); -- change to upper
	l_upper_to_uom		VARCHAR2(200); -- change to upper
--}
BEGIN
--{
	x_return := p_from_quantity;

	-- If zero quantity, then return zero
	IF (p_from_quantity = 0)
	THEN
		RETURN x_return;
	ELSE
	 --{
		-- Convert p_from_quantity to milliseconds
		l_upper_from_uom := upper(p_from_uom);
		IF (l_upper_from_uom = 'SEC') THEN
			l_time := p_from_quantity*1000;
		ELSIF (l_upper_from_uom = 'MIN') THEN
			l_time := p_from_quantity*60*1000;
		ELSIF (l_upper_from_uom = 'HR') THEN
			l_time := p_from_quantity*60*60*1000;
		ELSIF (l_upper_from_uom = 'DAY') THEN
			l_time := p_from_quantity*60*60*24*1000;
		ELSIF (l_upper_from_uom = 'WK') THEN
			l_time := p_from_quantity*60*60*24*7*1000;
		ELSIF (l_upper_from_uom = 'MTH') THEN
			l_time := p_from_quantity*60*60*24*(365/12)*1000;
		ELSIF (l_upper_from_uom = 'QRT') THEN
			l_time := p_from_quantity*60*60*24*(365/4)*1000;
		ELSIF (l_upper_from_uom = 'YR') THEN
			l_time := p_from_quantity*60*60*24*365*1000;
		ELSE
			x_return := -9999;
		END IF;

		-- Convert time to p_to_uom value
		l_upper_to_uom := upper(p_to_uom);
		IF (l_upper_to_uom = 'SEC') THEN
			x_return := l_time/1000;
		ELSIF (l_upper_to_uom = 'MIN') THEN
			x_return := l_time/(60*1000);
		ELSIF (l_upper_to_uom = 'HR') THEN
			x_return := l_time/(60*60*1000);
		ELSIF (l_upper_to_uom = 'DAY') THEN
			x_return := l_time/(60*60*24*1000);
		ELSIF (l_upper_to_uom = 'WK') THEN
			x_return := l_time/(60*60*24*7*1000);
		ELSIF (l_upper_to_uom = 'MTH') THEN
			x_return := l_time/(60*60*24*(365/12)*1000);
		ELSIF (l_upper_to_uom = 'QRT') THEN
			x_return := l_time/(60*60*24*(365/4)*1000);
		ELSIF (l_upper_to_uom = 'YR') THEN
			x_return := l_time/(60*60*24*365*1000);
		ELSE
			x_return := -9999;
		END IF;
	 --}
	END IF;

	RETURN x_return;
--}

EXCEPTION
--{
	WHEN OTHERS THEN
	       wsh_util_core.default_handler('FTE_MLS_UTIL.FTE_UOM_CONV');
	RAISE;
--}

END FTE_UOM_CONV;

    --
    --========================================================================
    -- PROCEDURE : COPY_FTE_ID_TO_WSH_ID
    --
    -- PARAMETERS: p_fte_id_tab		IN		FTE_ID_TAB_TYPE
    --             x_wsh_id_tab		OUT NOCOPY 	WSH_UTIL_CORE.id_tab_type
    -- VERSION   : current version      1.0
    --             initial version      1.0
    --========================================================================

PROCEDURE COPY_FTE_ID_TO_WSH_ID (p_fte_id_tab	IN	FTE_ID_TAB_TYPE,
				 x_wsh_id_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE)
AS

  	l_debug_on 	CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name 	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'COPY_FTE_ID_TO_WSH_ID';


BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


	IF (p_fte_id_tab.count > 0) THEN
		FOR i in 1..p_fte_id_tab.count LOOP
			x_wsh_id_tab(i) := p_fte_id_tab(i);
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' Copying Id ' || x_wsh_id_tab(i));
			END IF;
		END LOOP;
	END IF;

	IF l_debug_on THEN
	      wsh_debug_sv.pop(l_module_name);
	END IF;


EXCEPTION
	WHEN OTHERS THEN
		IF l_debug_on THEN
	              wsh_debug_sv.log (l_module_name,'UTIL ERROR',substr(sqlerrm,1,200));
		      wsh_debug_sv.pop(l_module_name);
		END IF;
	RAISE;
END COPY_FTE_ID_TO_WSH_ID;
--}
--{


    --
    --========================================================================
    -- PROCEDURE : COPY_WSH_ID_TO_FTE_ID
    --
    -- PARAMETERS: p_wsh_id_tab		IN		WSH_UTIL_CORE.id_tab_type
    -- 		   x_fte_id_tab		OUT NOCOPY	FTE_ID_TAB_TYPE
    --
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================

PROCEDURE COPY_WSH_ID_TO_FTE_ID (p_wsh_id_tab	IN WSH_UTIL_CORE.ID_TAB_TYPE,
				 x_fte_id_tab	IN OUT NOCOPY FTE_ID_TAB_TYPE)
AS

	l_debug_on 	CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name 	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'COPY_FTE_ID_TO_WSH_ID';


BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


	IF (p_wsh_id_tab.count > 0) THEN
		FOR i in 1..p_wsh_id_tab.count LOOP
			x_fte_id_tab.EXTEND;
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' Copying Id ' || p_wsh_id_tab(i));
			END IF;
			x_fte_id_tab(i) := p_wsh_id_tab(i);
		END LOOP;
	END IF;

	IF l_debug_on THEN
	      wsh_debug_sv.pop(l_module_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF l_debug_on THEN
	              wsh_debug_sv.log (l_module_name,'UTIL ERROR',substr(sqlerrm,1,200));
		      wsh_debug_sv.pop(l_module_name);
		END IF;
	RAISE;
END COPY_WSH_ID_TO_FTE_ID;



--{Rel 12 HBHAGAVA


    --

PROCEDURE GET_MESSAGE_MEANING(p_message_name	IN	VARCHAR2,
				x_message_text	OUT NOCOPY VARCHAR2)
AS

BEGIN

	SELECT message_text INTO x_message_text
	FROM FND_NEW_MESSAGES
	WHERE message_name = p_message_name
	AND LANGUAGE_CODE = userenv('LANG')
	AND APPLICATION_ID = 716;

	IF (SQL%NOTFOUND) THEN
		x_message_text := 'Message Not seeded ' || p_message_name;
        END IF;
EXCEPTION
	WHEN OTHERS THEN
		x_message_text := 'Message Not seeded ' || p_message_name;
--	RAISE;
END GET_MESSAGE_MEANING;


-- Rel 12
-- Start of comments
-- API name : Get_Lookup_Meaning
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to get meaning for lookup code and type.
-- Parameters :
-- IN:
--        p_lookup_type               IN      Lookup Type.
--        P_lookup_code               IN      Lookup Code.
-- OUT:
--        Api return meaning for lookup code and type.
-- End of comments
FUNCTION Get_Lookup_Meaning(p_lookup_type       IN      VARCHAR2,
                            P_lookup_code       IN      VARCHAR2)
RETURN VARCHAR2
IS

CURSOR get_meaning IS
  SELECT meaning
  FROM Fnd_lookup_values_vl
  WHERE LOOKUP_TYPE = p_lookup_type
  AND LOOKUP_CODE = P_lookup_code;

l_meaning			VARCHAR2(80);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_MLS_UTIL' || '.' || 'GET_LOOKUP_MEANING';
--
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_lookup_type',p_lookup_type);
      WSH_DEBUG_SV.log(l_module_name,'P_lookup_code',P_lookup_code);
   END IF;

   OPEN get_meaning;
   FETCH get_meaning INTO l_meaning;
   CLOSE get_meaning;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_meaning',l_meaning);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   IF (l_meaning IS NULL) THEN
      l_meaning := P_lookup_code;
   ELSE
      l_meaning := l_meaning;
   END IF;

   RETURN l_meaning;

EXCEPTION
  WHEN others THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   RETURN P_lookup_code;
END Get_Lookup_Meaning;



--{
--========================================================================
-- PROCEDURE : GET_CURRENCY_CODE
--
-- COMMENT   : Return back carrier currency code for a give trip id.
-- CREATED BY: HBHAGAVA
-- MODIFIED :
-- DESC:       This procedure returns back carrier currency code for a given trip id.
--		Carrier on the trip will be used.
--		Steps
--		First get the organization associated with the trip.
--		Then get the vendor site that is associated with this orgnization
--		for the carrier on the trip.
--		If there is no supplier link then use carrier default currency.
--========================================================================


PROCEDURE GET_CURRENCY_CODE(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_currency_code	     OUT NOCOPY		VARCHAR2,
	    p_entity_type	     IN			VARCHAR2,
	    p_entity_id		     IN			NUMBER,
	    p_carrier_id	     IN			NUMBER)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_CURRENCY_CODE';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_vendor_site_id	    NUMBER;
l_vendor_id		    NUMBER;
l_carrier_currency	    VARCHAR2(15);

l_organization_id	    NUMBER;
l_currency_code		    VARCHAR2(15);
l_carrier_site_id	    NUMBER;
l_carrier_id		    NUMBER;


CURSOR GET_VENDOR_SITE_ID_FOR_TRIP(l_organization_id NUMBER) IS
	SELECT decode(sites.supplier_site_id,null,car.supplier_site_id,
		sites.supplier_site_id), car.currency_code
	FROM WSH_ORG_CARRIER_SITES org_sites,
		 WSH_CARRIER_SITES sites,
		 WSH_CARRIERS car, wsh_trips trips
	WHERE org_sites.ORGANIZATION_ID = l_organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND car.CARRIER_ID = trips.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	and trips.trip_id = P_ENTITY_ID;


CURSOR GET_VENDOR_SITE_ID_FOR_DLVY IS
	SELECT decode(sites.supplier_site_id,null,car.supplier_site_id,
	sites.supplier_site_id), car.currency_code FROM WSH_ORG_CARRIER_SITES org_sites,
		 WSH_CARRIER_SITES sites,
		 WSH_CARRIERS car, wsh_new_deliveries del
	WHERE org_sites.ORGANIZATION_ID = del.organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND car.CARRIER_ID = del.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	AND del.delivery_id = P_ENTITY_ID;


CURSOR GET_VENDOR_SITE_ID_FOR_CARRIER(l_organization_id NUMBER, l_carrier_id NUMBER) IS
	SELECT decode(sites.supplier_site_id,null,car.supplier_site_id,
		sites.supplier_site_id), car.currency_code
	FROM WSH_ORG_CARRIER_SITES org_sites,
		 WSH_CARRIER_SITES sites,
		 WSH_CARRIERS car
	WHERE org_sites.ORGANIZATION_ID = l_organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	AND car.carrier_id = l_carrier_id;


CURSOR GET_CARRIER_SITE(l_organization_id NUMBER, l_carrier_id NUMBER) IS
	SELECT sites.carrier_site_id, sites.supplier_site_id
	FROM WSH_CARRIER_SITES sites,
		WSH_ORG_CARRIER_SITES org_sites,
		WSH_CARRIERS car
	WHERE org_sites.ORGANIZATION_ID = l_organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	AND car.carrier_id = l_carrier_id;

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

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' ENTITY TYPE ' || P_ENTITY_TYPE,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' ENTITY ID ' || P_ENTITY_ID,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;



	IF (UPPER(P_ENTITY_TYPE) = 'TRIP')
	THEN
	--{

		-- first get the organization id for the trip
		l_organization_id := GET_TRIP_ORGANIZATION_ID(P_ENTITY_ID);

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Organization Id after calling GET_TRIP_ORGANIZATION_ID ' ||
						l_organization_id,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		IF (l_organization_id IS NOT NULL)
		THEN
			IF (p_carrier_id IS NOT NULL)
			THEN
				l_carrier_id := p_carrier_id;
			ELSE
				SELECT CARRIER_ID INTO l_carrier_id
				FROM WSH_TRIPS
				WHERE TRIP_ID = p_entity_id;
			END IF;

		END IF;


	--}
	ELSIF (UPPER(P_ENTITY_TYPE) = 'DELIVERY')
	THEN
	--{

		IF (p_carrier_id IS NOT NULL)
		THEN
		--{
			l_carrier_id := p_carrier_id;
		--}
		ELSE
			SELECT CARRIER_ID INTO l_carrier_id
			FROM WSH_NEW_DELIVERIES
			WHERE DELIVERY_ID = p_entity_id;
		END IF;


		SELECT ORGANIZATION_ID INTO l_organization_id FROM WSH_NEW_DELIVERIES
		WHERE DELIVERY_ID = p_entity_id;

	--}
	ELSIF (UPPER(P_ENTITY_TYPE) = 'LOCATION')
	THEN
	--{
		-- first get the organization id for the location id
		BEGIN

			SELECT mp. organization_id
			INTO l_organization_id
			FROM   hr_organization_units hou,mtl_parameters mp
			WHERE  hou.organization_id = mp.organization_id
			AND  hou.location_id  = p_entity_id
			AND  trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));


			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_ORG_NOTFOUND');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				wsh_util_core.add_message(x_return_status);
		END;

		l_carrier_id := p_carrier_id;

	--}
	END IF;


	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Organization Id ' ||
					l_organization_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF (l_organization_id IS NOT NULL AND
		l_carrier_id IS NOT NULL)
	THEN


		OPEN  GET_CARRIER_SITE(l_organization_id,l_carrier_id);
		FETCH GET_CARRIER_SITE INTO l_carrier_site_id, l_vendor_site_id;

		IF (GET_CARRIER_SITE%NOTFOUND)
		THEN
			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Carrier site not found ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


		ELSE
			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Found carrier site id ' || l_carrier_site_id,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			      WSH_DEBUG_SV.logmsg(l_module_name,' Found Supplier site id ' || l_vendor_site_id,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
		END IF;

		IF (l_vendor_site_id IS NULL)
		THEN
			-- Get the default supplier and supplier site
			SELECT SUPPLIER_ID,SUPPLIER_SITE_ID,CURRENCY_CODE
			INTO l_vendor_id,l_vendor_site_id,l_carrier_currency
			FROM WSH_CARRIERS WHERE CARRIER_ID = l_carrier_id;
		END IF;


		IF (l_vendor_site_id IS NOT NULL)
		THEN

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,'Using Vendor Site to get currency Vendor Site Id ' ||
						l_vendor_site_id,WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			-- Now get teh currency code

			SELECT PAYMENT_CURRENCY_CODE INTO X_CURRENCY_CODE
			FROM po_vendor_sites_all
			WHERE vendor_site_id = l_vendor_site_id
			AND PAY_SITE_FLAG = 'Y';
		ELSIF (l_vendor_id IS NOT NULL)
		THEN
			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Using Vendor Id to get currency Vendor Id ' || l_vendor_id,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			-- Now get teh currency code

			SELECT PAYMENT_CURRENCY_CODE INTO X_CURRENCY_CODE
			FROM po_vendors
			WHERE vendor_id = l_vendor_id;
		ELSE
			X_CURRENCY_CODE := l_carrier_currency;

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
	wsh_util_core.default_handler('FTE_MLS_UTIL.GET_CURRENCY_CODE');
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

END GET_CURRENCY_CODE;



--}

PROCEDURE GET_SUPPLIER_INFO(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_currency_code	     OUT NOCOPY		VARCHAR2,
	    x_supplier_id	     OUT NOCOPY		NUMBER,
	    x_supplier_site_id	     OUT NOCOPY		NUMBER,
	    x_carrier_site_id	     OUT NOCOPY		NUMBER,
	    p_entity_type	     IN			VARCHAR2,
	    p_entity_id		     IN			NUMBER)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_SUPPLIER_INFO';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_vendor_site_id	    NUMBER;
l_vendor_id		    NUMBER;
l_carrier_site_id	    NUMBER;
l_organization_id	    NUMBER;
l_currency_code		    VARCHAR2(15);

CURSOR GET_VENDOR_SITE_ID_FOR_TRIP(l_organization_id NUMBER,l_entity_id NUMBER) IS
	SELECT decode(sites.supplier_site_id,null,car.supplier_site_id,
		sites.supplier_site_id), car.currency_code,
		car.supplier_id,sites.carrier_site_id
	FROM WSH_ORG_CARRIER_SITES org_sites,
		 WSH_CARRIER_SITES sites,
		 WSH_CARRIERS car, wsh_trips trips
	WHERE org_sites.ORGANIZATION_ID = l_organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND car.CARRIER_ID = trips.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	and trips.trip_id = l_entity_id;


CURSOR GET_VENDOR_SITE_ID_FOR_DLVY(l_entity_id NUMBER) IS
	SELECT decode(sites.supplier_site_id,null,car.supplier_site_id,
	sites.supplier_site_id), car.currency_code,car.supplier_id,
	sites.carrier_site_id
	FROM WSH_ORG_CARRIER_SITES org_sites,
		 WSH_CARRIER_SITES sites,
		 WSH_CARRIERS car, wsh_new_deliveries del
	WHERE org_sites.ORGANIZATION_ID = del.organization_id
	AND sites.carrier_site_id = org_sites.carrier_site_id
	AND sites.carrier_id = car.carrier_id
	AND car.CARRIER_ID = del.carrier_id
	AND org_sites.ENABLED_FLAG = 'Y'
	AND del.delivery_id = l_entity_id;


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



	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' ENTITY TYPE ' || P_ENTITY_TYPE,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' ENTITY ID ' || P_ENTITY_ID,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;



	IF (UPPER(P_ENTITY_TYPE) = 'TRIP')
	THEN
	--{

		-- first get the organization id for the trip
		l_organization_id := GET_TRIP_ORGANIZATION_ID(P_ENTITY_ID);

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Organization Id after calling GET_TRIP_ORGANIZATION_ID ' ||
						l_organization_id,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		IF (l_organization_id IS NOT NULL)
		THEN

			-- Since user did not pass in carrier id we can use
			-- carrier id on the trip

			OPEN  GET_VENDOR_SITE_ID_FOR_TRIP(l_organization_id,p_entity_id);
			FETCH GET_VENDOR_SITE_ID_FOR_TRIP INTO l_vendor_site_id, l_currency_code,
				l_vendor_id,l_carrier_site_id;

			IF (GET_VENDOR_SITE_ID_FOR_TRIP%NOTFOUND) THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_VENDORSITE_NOT_FOUND');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				wsh_util_core.add_message(x_return_status);
			END IF;

			CLOSE GET_VENDOR_SITE_ID_FOR_TRIP;

		END IF;


	--}
	ELSIF (UPPER(P_ENTITY_TYPE) = 'DELIVERY')
	THEN
	--{
		-- Since user did not pass in carrier id, we are going to use carrier
		-- id from delivery.



		OPEN  GET_VENDOR_SITE_ID_FOR_DLVY(p_entity_id);
		FETCH GET_VENDOR_SITE_ID_FOR_DLVY INTO l_vendor_site_id, l_currency_code,
			l_vendor_id,l_carrier_site_id;



		IF (GET_VENDOR_SITE_ID_FOR_DLVY%NOTFOUND) THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_VENDORSITE_NOT_FOUND');
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			wsh_util_core.add_message(x_return_status);
		END IF;

		CLOSE GET_VENDOR_SITE_ID_FOR_DLVY;

	--}
	END IF;

	IF (l_vendor_site_id IS NOT NULL)
	THEN

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Vendor Site Id ' || l_vendor_site_id,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		-- Now get teh currency code

		SELECT PAYMENT_CURRENCY_CODE INTO X_CURRENCY_CODE
		FROM po_vendor_sites_all
		WHERE vendor_site_id = l_vendor_site_id
		AND PAY_SITE_FLAG = 'Y';

		X_SUPPLIER_ID := l_vendor_id;
		X_SUPPLIER_SITE_ID := l_vendor_site_id;
		X_CARRIER_SITE_ID := l_carrier_site_id;

	END IF;

	IF (X_CURRENCY_CODE IS NULL)
	THEN
		X_CURRENCY_CODE := l_currency_code;
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
	wsh_util_core.default_handler('FTE_MLS_UTIL.GET_SUPPLIER_INFO');
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

END GET_SUPPLIER_INFO;


--{
--========================================================================
-- PROCEDURE : GET_TRIP_ORGANIZATION_ID
--
-- COMMENT   : Return back organization id that is associated with the trip..
-- CREATED BY: HBHAGAVA
-- MODIFIED :
-- DESC:       This procedure returns back organiation id that is associated with the trip.
--		Steps
--		For Outbound and Mixed trip's see if there is a organization at the location of first stop
--		For inbound see if there is a organization at the location of the last stop.
--		If there are no organizations associated then get the organization id of the delivery with
--		least delivery id
--========================================================================

FUNCTION GET_TRIP_ORGANIZATION_ID (p_trip_id	NUMBER)
RETURN NUMBER
IS

--{

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_TRIP_ORGANIZATION_ID';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_first_stop_loc_id	NUMBER;
l_last_stop_loc_id	NUMBER;
l_first_stop_id		NUMBER;
l_last_stop_id		NUMBER;
l_arrival_date		DATE;
l_dept_date		DATE;
l_sel_stop_loc_id	NUMBER;

l_typeflag		VARCHAR2(1);
l_organization_id	NUMBER;

l_return_status		VARCHAR2(1);

l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;

CURSOR GET_ORG_ID_BY_LOCATION (l_stop_loc_id NUMBER) IS
	SELECT mp. organization_id
	FROM   hr_organization_units hou,mtl_parameters mp
	WHERE  hou.organization_id = mp.organization_id
	AND  hou.location_id  = l_stop_loc_id
	AND  trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));

CURSOR GET_ORG_ID_BY_DELIVERY (l_stop_id NUMBER) IS
	SELECT dlvy.ORGANIZATION_ID
	FROM WSH_TRIP_STOPS stops, WSH_DELIVERY_LEGS leg,
		WSH_NEW_DELIVERIES dlvy
	WHERE stops.stop_id = leg.pick_up_stop_id
	AND leg.delivery_id = dlvy.delivery_id
	AND stops.stop_id = l_stop_id;

BEGIN

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	l_sel_stop_loc_id := null;
	l_organization_id := null;


	-- First get the type of trip. Depending on this we can get the
	-- location, Org Id and the there by carrier site.

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Getting trip stop information ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	GET_FIRST_LAST_STOP_INFO(x_return_status          => l_return_status,
			    x_arrival_date	     => l_arrival_date,
			    x_departure_date	     => l_dept_date,
			    x_first_stop_id	     => l_first_stop_id,
			    x_last_stop_id	     => l_last_stop_id,
			    x_first_stop_loc_id	     => l_first_stop_loc_id,
			    x_last_stop_loc_id	     => l_last_stop_loc_id,
			    p_trip_id		     => p_trip_id);


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	SELECT shipments_type_flag  INTO l_typeflag
	FROM WSH_TRIPS
	WHERE TRIP_ID = p_trip_id;


	IF (l_typeflag = 'O' OR l_typeflag = 'M')
	THEN
		-- outbound or mixed use first stop location id
		l_sel_stop_loc_id := l_first_stop_loc_id;

	ELSE
		-- inbound so use last stop
		l_sel_stop_loc_id := l_last_stop_loc_id;

	END IF;

	IF (l_sel_stop_loc_id IS NOT NULL)
	THEN
		OPEN  GET_ORG_ID_BY_LOCATION(l_sel_stop_loc_id);
		FETCH GET_ORG_ID_BY_LOCATION INTO l_organization_id;

		IF (GET_ORG_ID_BY_LOCATION%NOTFOUND) THEN
			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Stop Loc Id ' || l_sel_stop_loc_id
	      			   || ' has no organization. Checking Delivery ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
		END IF;
		CLOSE GET_ORG_ID_BY_LOCATION;
	END IF;
	--
	--

	-- if organization id is null then we should get org id from the
	-- delivery that is getting picked up at the first stop

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Before Checking Delivery Org: Organizaton Id ' || l_organization_id ||
    			          ' First Stop Id '||l_first_stop_id,
				  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF (l_organization_id IS NULL
	    AND l_first_stop_id IS NOT NULL)
	THEN
		OPEN  GET_ORG_ID_BY_DELIVERY(l_first_stop_id);
		FETCH GET_ORG_ID_BY_DELIVERY INTO l_organization_id;

		IF (GET_ORG_ID_BY_DELIVERY%NOTFOUND) THEN
			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Delivery has no OrgId!',
					WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
		END IF;
		CLOSE GET_ORG_ID_BY_DELIVERY;

	END IF;

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' After Checking Delivery Org Organizaton Id ' || l_organization_id ||
    			          ' First Stop Id '||l_first_stop_id,
				  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	return l_organization_id;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	return null;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	return null;

WHEN OTHERS THEN
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	return null;

END GET_TRIP_ORGANIZATION_ID;

--{
--========================================================================
-- PROCEDURE : GET_FIRST_LAST_STOP_INFO
--
-- COMMENT   : Return back first stop and last stop information..
-- CREATED BY: HBHAGAVA
-- MODIFIED :
--========================================================================

PROCEDURE GET_FIRST_LAST_STOP_INFO(x_return_status          OUT NOCOPY 	VARCHAR2,
			    x_arrival_date	     OUT NOCOPY		DATE,
			    x_departure_date	     OUT NOCOPY		DATE,
			    x_first_stop_id	     OUT NOCOPY		NUMBER,
			    x_last_stop_id	     OUT NOCOPY		NUMBER,
			    x_first_stop_loc_id	     OUT NOCOPY		NUMBER,
			    x_last_stop_loc_id	     OUT NOCOPY		NUMBER,
			    p_trip_id		     NUMBER)
IS
--{
CURSOR GET_TRIP_STOPS IS
SELECT stop_location_id, planned_arrival_date, planned_departure_date ,
	stops.stop_id
FROM wsh_trip_stops stops, wsh_trips trips
WHERE trips.trip_id = p_trip_id
	and trips.trip_id = stops.trip_id
ORDER BY PLANNED_ARRIVAL_DATE,
	 STOP_SEQUENCE_NUMBER;
--}

--{

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_FIRST_LAST_STOP_INFO';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_stop_loc_id_tbl	FTE_ID_TAB_TYPE;
l_stop_id_tbl		FTE_ID_TAB_TYPE;

l_typeflag		VARCHAR2(1);
l_first_stop		NUMBER;
l_idx			NUMBER;

BEGIN


	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Getting trip stop information ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	l_idx := 0;

	FOR GET_TRIP_STOPS_REC IN GET_TRIP_STOPS
	LOOP
		IF (l_idx = 0)
		THEN
			-- This is first stop
			x_first_stop_id := GET_TRIP_STOPS_REC.STOP_ID;
			x_first_stop_loc_id := GET_TRIP_STOPS_REC.STOP_LOCATION_ID;
			x_departure_date := GET_TRIP_STOPS_REC.PLANNED_DEPARTURE_DATE;
		ELSE
			-- Need to find out if there is a way to go to last stop directly
			x_last_stop_id := GET_TRIP_STOPS_REC.STOP_ID;
			x_last_stop_loc_id := GET_TRIP_STOPS_REC.STOP_LOCATION_ID;
			x_arrival_date := GET_TRIP_STOPS_REC.PLANNED_ARRIVAL_DATE;
		END IF;
		l_idx := l_idx+1;

	END LOOP;

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' First stop STOP_ID ' || x_first_stop_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' First stop Stop Loc Id ' || x_first_stop_loc_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' First stop departure date ' || x_departure_date,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' Last stop STOP_ID ' || x_last_stop_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' Last stop Stop loc id ' || x_last_stop_loc_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      WSH_DEBUG_SV.logmsg(l_module_name,' Last stop arrival date ' || x_arrival_date,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;



	IF GET_TRIP_STOPS%ISOPEN THEN
	  CLOSE GET_TRIP_STOPS;
	END IF;


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_ERROR;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_ERROR;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;



END GET_FIRST_LAST_STOP_INFO;


END FTE_MLS_UTIL;

/
