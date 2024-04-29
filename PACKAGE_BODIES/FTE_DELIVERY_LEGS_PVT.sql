--------------------------------------------------------
--  DDL for Package Body FTE_DELIVERY_LEGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DELIVERY_LEGS_PVT" as
/* $Header: FTEVDLGB.pls 120.3 2005/07/28 12:34:44 nltan ship $ */
--{
  PROCEDURE search_segment_save
	      (
	        P_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status           OUT NOCOPY    VARCHAR2,
	        X_msg_count               OUT NOCOPY    NUMBER,
	        X_msg_data                OUT NOCOPY    VARCHAR2,
		p_delivery_id             IN     NUMBER,
		p_delivery_name           IN     VARCHAR2 DEFAULT NULL,
		p_wsh_trip_id             IN     NUMBER,
		p_wsh_trip_name           IN     VARCHAR2,
		p_pickup_stop_id          IN     NUMBER,
		p_pickup_location_id      IN     NUMBER,
		p_pickup_stop_seq         IN     NUMBER,
		p_pickup_departure_date   IN     DATE,
		p_pickup_arrival_date     IN     DATE,
		p_dropoff_stop_id         IN     NUMBER,
		p_dropoff_location_id     IN     NUMBER,
		p_dropoff_stop_seq        IN     NUMBER,
		p_dropoff_departure_date  IN     DATE,
		p_dropoff_arrival_date    IN     DATE,
		p_move_stop_seq_start     IN     NUMBER,
		p_move_stop_seq_to        IN     NUMBER,
		p_fte_trip_id             IN     NUMBER,
		p_pricing_request_id      IN     NUMBER,
		p_lane_id                 IN     NUMBER,
		p_schedule_id             IN     NUMBER,
		p_ignore_for_planning	  IN     VARCHAR2 DEFAULT NULL,
		x_pickup_stop_id          OUT NOCOPY    NUMBER,
		x_dropoff_stop_id         OUT NOCOPY    NUMBER,
		x_delivery_leg_id         OUT NOCOPY    NUMBER,
		x_delivery_leg_seq        OUT NOCOPY    NUMBER,
		x_pickup_stop_seq         OUT NOCOPY    NUMBER,
		x_dropoff_stop_seq        OUT NOCOPY    NUMBER
	      )
  IS
  --{
        l_api_name              CONSTANT VARCHAR2(30)   := 'search_segment_save';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
	p_action_type               VARCHAR2(32767);
	--
	--
        l_pickup_stop_id       NUMBER;
        l_pickup_stop_seq      NUMBER;
        l_stop_id              NUMBER;
        l_dropoff_stop_id      NUMBER;
        l_dropoff_stop_seq     NUMBER;
        l_index                NUMBER;
        l_stop_new_seq         NUMBER;
        l_delivery_leg_id      NUMBER;
        l_delivery_leg_seq     NUMBER;
        l_wsh_trip_id          NUMBER;
        l_fte_trip_id          NUMBER;
        l_wsh_trip_name        VARCHAR2(32767);
        l_fte_trip_name        VARCHAR2(32767);
        l_fte_wsh_trip_seq     NUMBER;
        l_trip_id              NUMBER;
        l_trip_name            VARCHAR2(32767);
        l_ship_method_code     VARCHAR2(32767);
        --
        --
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
  --}
  BEGIN
  --{
	--
        -- Standard Start of API savepoint
        SAVEPOINT   SEARCH_SEGMENT_SAVE_PUB;
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
	l_number_of_errors := 0;
	l_number_of_warnings := 0;
	--

	--
        process_delivery_leg
	  (
	    X_return_status            => x_return_status,
	    X_msg_count                => x_msg_count,
	    X_msg_data                 => x_msg_data,
	    p_ui_page_name             => GK_SEARCH_SEGMENTS_PAGE,
	    p_delivery_id              => p_delivery_id,
	    p_delivery_name            => p_delivery_name,
	    p_wsh_trip_id              => p_wsh_trip_id,
	    p_wsh_trip_name            => p_wsh_trip_name,
	    p_lane_id                  => p_lane_id,
	    p_schedule_id              => p_schedule_id,
	    p_pickup_stop_id           => p_pickup_stop_id,
	    p_pickup_stop_seq          => p_pickup_stop_seq,
	    p_pickup_location_id       => p_pickup_location_id,
	    p_pickup_departure_date    => p_pickup_departure_date,
	    p_pickup_arrival_date      => p_pickup_arrival_date,
	    p_dropoff_stop_id          => p_dropoff_stop_id,
	    p_dropoff_stop_seq         => p_dropoff_stop_seq,
	    p_dropoff_location_id      => p_dropoff_location_id,
	    p_dropoff_departure_date   => p_dropoff_departure_date,
	    p_dropoff_arrival_date     => p_dropoff_arrival_date,
	    p_fte_trip_id              => p_fte_trip_id,
	    p_pricing_request_id       => p_pricing_request_id,
	    p_move_stop_seq_start      => p_move_stop_seq_start,
	    p_move_stop_seq_to         => p_move_stop_seq_to,
	    p_ignore_for_planning      => p_ignore_for_planning,
	    x_wsh_trip_id              => l_wsh_trip_id,
	    x_wsh_trip_name            => l_wsh_trip_name,
	    x_ship_method_code         => l_ship_method_code,
	    x_fte_trip_id              => l_fte_trip_id,
	    x_fte_trip_name            => l_fte_trip_name,
	    x_pickup_stop_id           => x_pickup_stop_id ,
	    x_dropoff_stop_id          => x_dropoff_stop_id,
	    x_delivery_leg_id          => x_delivery_leg_id,
	    x_delivery_leg_seq         => x_delivery_leg_seq,
	    x_pickup_stop_seq          => x_pickup_stop_seq,
	    x_dropoff_stop_seq         => x_dropoff_stop_seq
	  );
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO SEARCH_SEGMENT_SAVE_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO SEARCH_SEGMENT_SAVE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO SEARCH_SEGMENT_SAVE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--
		--
               wsh_util_core.default_handler('FTE_DELIVERY_LEGS_PVT.search_segment_save');
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
  END search_segment_save;
  --
  --
  PROCEDURE process_delivery_leg
	      (
	        P_init_msg_list             IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status             OUT NOCOPY    VARCHAR2,
	        X_msg_count                 OUT NOCOPY    NUMBER,
	        X_msg_data                  OUT NOCOPY    VARCHAR2,
		p_ui_page_name              IN     VARCHAR2 DEFAULT GK_DLEG_WB_PAGE,
		p_delivery_id               IN     NUMBER,
		p_delivery_name             IN     VARCHAR2 DEFAULT NULL,
		p_delivery_leg_id           IN     NUMBER   DEFAULT NULL,
		p_delivery_leg_seq          IN     NUMBER   DEFAULT NULL,
		p_wsh_trip_id               IN     NUMBER   DEFAULT NULL,
		p_wsh_trip_name             IN     VARCHAR2 DEFAULT NULL,
		p_lane_id                   IN     NUMBER   DEFAULT NULL,
		p_schedule_id               IN     NUMBER   DEFAULT NULL,
		p_carrier_id                IN     NUMBER   DEFAULT NULL,
		p_mode_of_transport         IN     VARCHAR2 DEFAULT NULL,
		p_service_level             IN     VARCHAR2 DEFAULT NULL,
		p_carrier_name              IN     VARCHAR2 DEFAULT NULL,
		p_mode_of_transport_meaning IN     VARCHAR2 DEFAULT NULL,
		p_service_level_meaning     IN     VARCHAR2 DEFAULT NULL,
		p_pickup_stop_id            IN     NUMBER   DEFAULT NULL,
		p_pickup_stop_seq           IN     NUMBER   DEFAULT NULL,
		p_pickup_location_id        IN     NUMBER   DEFAULT NULL,
		p_pickup_departure_date     IN     DATE     DEFAULT NULL,
		p_pickup_arrival_date       IN     DATE     DEFAULT NULL,
		p_dropoff_stop_id           IN     NUMBER   DEFAULT NULL,
		p_dropoff_stop_seq          IN     NUMBER   DEFAULT NULL,
		p_dropoff_location_id       IN     NUMBER   DEFAULT NULL,
		p_dropoff_departure_date    IN     DATE     DEFAULT NULL,
		p_dropoff_arrival_date      IN     DATE     DEFAULT NULL,
		p_fte_trip_id               IN     NUMBER   DEFAULT NULL,
		p_fte_trip_name             IN     VARCHAR2 DEFAULT NULL,
		p_pricing_request_id        IN     NUMBER   DEFAULT NULL,
		p_move_stop_seq_start       IN     NUMBER   DEFAULT NULL,
		p_move_stop_seq_to          IN     NUMBER   DEFAULT NULL,
		p_first_stop_id             IN     NUMBER   DEFAULT NULL,
		p_first_stop_location_id    IN     NUMBER   DEFAULT NULL,
		p_first_stop_seq            IN     NUMBER   DEFAULT NULL,
		p_first_stop_departure_date IN     DATE     DEFAULT NULL,
		p_first_stop_arrival_date   IN     DATE     DEFAULT NULL,
		p_last_stop_id              IN     NUMBER   DEFAULT NULL,
		p_last_stop_location_id     IN     NUMBER   DEFAULT NULL,
		p_last_stop_seq             IN     NUMBER   DEFAULT NULL,
		p_last_stop_departure_date  IN     DATE     DEFAULT NULL,
		p_last_stop_arrival_date    IN     DATE     DEFAULT NULL,
		p_veh_org_id		    IN 	   NUMBER   DEFAULT NULL,
		p_veh_num		    IN 	   NUMBER   DEFAULT NULL,
		p_veh_num_pre		    IN 	   NUMBER   DEFAULT NULL,
                p_ignore_for_planning	    IN VARCHAR2 DEFAULT NULL,
                p_veh_item_id		    IN     NUMBER   DEFAULT NULL,
                x_wsh_trip_id               OUT NOCOPY    NUMBER,
		x_wsh_trip_name             OUT NOCOPY    VARCHAR2,
		x_ship_method_code          OUT NOCOPY    VARCHAR2,
		x_fte_trip_id               OUT NOCOPY    NUMBER,
		x_fte_trip_name             OUT NOCOPY    VARCHAR2,
		x_pickup_stop_id            OUT NOCOPY    NUMBER,
		x_dropoff_stop_id           OUT NOCOPY    NUMBER,
		x_delivery_leg_id           OUT NOCOPY    NUMBER,
		x_delivery_leg_seq           OUT NOCOPY    NUMBER,
		x_pickup_stop_seq           OUT NOCOPY    NUMBER,
		x_dropoff_stop_seq          OUT NOCOPY    NUMBER
	      )
  IS
  --{
        l_api_name              CONSTANT VARCHAR2(30)   := 'process_delivery_leg';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
        K_UPDATE              CONSTANT VARCHAR2(30)   := 'UPDATE';
        K_CREATE              CONSTANT VARCHAR2(30)   := 'CREATE';
        K_NO_ACTION           CONSTANT VARCHAR2(30)   := 'NO_ACTION';
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
      l_pickup_stop_id       NUMBER;
      l_pickup_stop_seq      NUMBER;
      l_stop_id              NUMBER;
      l_dropoff_stop_id      NUMBER;
      l_dropoff_stop_seq     NUMBER;
      l_index                NUMBER;
      l_stop_new_seq         NUMBER;
      l_delivery_leg_id      NUMBER;
      l_delivery_leg_seq     NUMBER;
      l_wsh_trip_id          NUMBER;
      l_fte_trip_id          NUMBER;
      l_wsh_trip_name        VARCHAR2(32767);
      l_fte_trip_name        VARCHAR2(32767);
      l_fte_wsh_trip_seq     NUMBER;
      l_trip_id              NUMBER;
      l_trip_name            VARCHAR2(32767);
      l_ship_method_code     VARCHAR2(32767);
      l_first_stop_new_location_id NUMBER;
      l_last_stop_new_location_id  NUMBER;
      --
      --
      l_wsh_trip_action      VARCHAR2(32767);
      l_fte_trip_action      VARCHAR2(32767);
      l_pickup_stop_action   VARCHAR2(32767);
      l_delivery_leg_action  VARCHAR2(32767);
      l_dropoff_stop_action  VARCHAR2(32767);
      --
      --
      l_old_lane_id           NUMBER;
      l_old_schedule_id       NUMBER;
      l_old_carrier_id        NUMBER;
      l_old_mode_of_transport VARCHAR2(32767);
      l_old_service_level     VARCHAR2(32767);
      l_old_stop_location_id  NUMBER;
      --
      --
      l_reprice_required             VARCHAR2(32767);
      l_segment_has_other_deliveries BOOLEAN;
      --
	return_dropoff_stop_id	NUMBER;
	return_pickup_stop_id	NUMBER;


      --PACK I
      l_dlvy_weight_uom		VARCHAR2(10);
      l_dlvy_volume_uom		VARCHAR2(10);
      --
      CURSOR wsh_trip_cur (p_trip_id NUMBER)
      IS
	SELECT lane_id, schedule_id,
	       carrier_id, mode_of_transport, service_level,
	       NVL(consolidation_allowed,'N') consolidation_allowed
	FROM   wsh_trips
	WHERE  trip_id = p_trip_id;
      --
      --
      CURSOR stop_location_cur (p_stop_id NUMBER)
      IS
	SELECT stop_location_id
	FROM   wsh_trip_stops
	WHERE  stop_id = p_stop_id;
      --
      --
      CURSOR stop_cur (p_trip_id NUMBER, p_stop_seq NUMBER)
      IS
	SELECT stop_id, stop_sequence_number, stop_location_id
	FROM   wsh_trip_stops
	WHERE  trip_id = p_trip_id
	AND    stop_sequence_number >= p_stop_seq
	order by stop_sequence_number desc;

      CURSOR dlvy_weight_volume_cur (p_dlvy_id NUMBER)
      IS
	SELECT weight_uom_code,volume_uom_code
	FROM wsh_new_deliveries
	WHERE  delivery_id = p_dlvy_id;


	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

  --}
  BEGIN
  --{

	IF l_debug_on THEN
	     wsh_debug_sv.push(l_api_name);
        END IF;
        --
        -- Standard Start of API savepoint
        SAVEPOINT   PROCESS_DELIVERY_LEG_PUB;
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
	l_number_of_errors := 0;
	l_number_of_warnings := 0;
	--
	IF p_ui_page_name = GK_DLEG_WB_PAGE
	THEN
	   null; --RETURN;
	END IF;
	--
	l_pickup_stop_id       := p_pickup_stop_id;
	l_dropoff_stop_id      := p_dropoff_stop_id;
	l_pickup_stop_seq      := p_pickup_stop_seq;
	l_dropoff_stop_seq     := p_dropoff_stop_seq;
	l_wsh_trip_id          := p_wsh_trip_id;
	l_wsh_trip_name        := p_wsh_trip_name;
	l_fte_trip_id          := p_fte_trip_id;
	l_fte_trip_name        := p_fte_trip_name;
	l_delivery_leg_id      := p_delivery_leg_id;
	l_delivery_leg_seq     := p_delivery_leg_seq;
	l_wsh_trip_action      := K_NO_ACTION;
	l_fte_trip_action      := K_NO_ACTION;
	l_pickup_stop_action   := K_NO_ACTION;
	l_dropoff_stop_action  := K_NO_ACTION;
	l_delivery_leg_action  := K_NO_ACTION;
        l_first_stop_new_location_id := NULL;
        l_last_stop_new_location_id  := NULL;
	--
	--
	-- Null implies that this flag is not required to be updated.
	l_reprice_required           := NULL;
	--
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, 'BEFORE CALLING FREIGHT RATE:ReqId:laneId:Veh:VOrgId:'||
	   	p_pricing_request_id||':'||p_lane_id||':'||p_veh_item_id||':'||p_veh_org_id,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_api_name, ' 1 p_delivery_leg_id ' || p_delivery_leg_id,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	IF  p_delivery_leg_id IS NULL
	THEN
	--{
	    l_delivery_leg_action   := K_CREATE;
	    --
	    --
	    IF  p_wsh_trip_id IS NULL  -- Auto-create segment
	    THEN
	    --{
	        l_wsh_trip_action      := K_CREATE;
	        l_pickup_stop_seq      := 10;
	        l_dropoff_stop_seq     := 20;
	        l_pickup_stop_action   := K_CREATE;
	        l_dropoff_stop_action  := K_CREATE;
	    --}
	    ELSE --- coming from search segments
	    --{
	        IF  l_pickup_stop_id IS NULL
	        THEN
	        --{
	            l_pickup_stop_action   := K_CREATE;
	        --}
	        END IF;
		--
		--
	        IF  l_dropoff_stop_id IS NULL
	        THEN
	        --{
	            l_dropoff_stop_action   := K_CREATE;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 2 p_wsh_trip_id ' || p_wsh_trip_id,
		        		     WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF  p_wsh_trip_id IS NOT NULL
	THEN
	--{
	    IF
	       (
	              p_ui_page_name = GK_DLEG_WB_PAGE
                 AND  (
		           p_lane_id           IS NOT NULL
                        OR p_carrier_id        IS NOT NULL
                        OR p_mode_of_transport IS NOT NULL
                        OR p_service_level     IS NOT NULL
		      ) -- Need to check if ship method is to be updated.
	       )
	       OR p_ui_page_name = GK_SEARCH_SEGMENTS_PAGE
	    THEN
	    --{
		l_old_lane_id            := FND_API.G_MISS_NUM;
		l_old_schedule_id        := FND_API.G_MISS_NUM;
		l_old_carrier_id         := FND_API.G_MISS_NUM;
		l_old_mode_of_transport  := FND_API.G_MISS_CHAR;
		l_old_service_level      := FND_API.G_MISS_CHAR;
		--
		--
		FOR wsh_trip_rec IN wsh_trip_cur
		                      (
					p_trip_id => p_wsh_trip_id
				      )
		LOOP
		--{
		    l_old_lane_id
		    := NVL(wsh_trip_rec.lane_id,FND_API.G_MISS_NUM);
		    --
		    l_old_schedule_id
		    := NVL(wsh_trip_rec.schedule_id,FND_API.G_MISS_NUM);
		    --
		    l_old_carrier_id
		    := NVL(wsh_trip_rec.carrier_id,FND_API.G_MISS_NUM);
		    --
		    l_old_mode_of_transport
		    := NVL(wsh_trip_rec.mode_of_transport,FND_API.G_MISS_CHAR);
		    --
		    l_old_service_level
		    := NVL(wsh_trip_rec.service_level,FND_API.G_MISS_CHAR);
		    --
		    --
		    IF  wsh_trip_rec.consolidation_allowed = 'Y'
	            AND p_pricing_request_id IS NOT NULL
	            AND p_pricing_request_id > 0
		    THEN
		    --{
	                l_segment_has_other_deliveries := FALSE;
			--
			--
		        l_segment_has_other_deliveries
		        := FTE_MLS_UTIL.segment_has_other_deliveries
		             (
		               p_trip_segment_id => p_wsh_trip_id,
		               p_delivery_id     => p_delivery_id
		             );
	                --
	                --
			IF (l_segment_has_other_deliveries)
			THEN
			    l_reprice_required := 'Y';
			END IF;
		    --}
		    END IF;
		    --
		--}
		END LOOP;
		--
		--
		IF (
			p_lane_id           <> l_old_lane_id
		     OR p_schedule_id       <> l_old_schedule_id
		     OR p_carrier_id        <> l_old_carrier_id
		     OR p_mode_of_transport <> l_old_mode_of_transport
		     OR p_service_level     <> l_old_service_level
		   )
                AND p_ui_page_name = GK_DLEG_WB_PAGE
		THEN
		    l_wsh_trip_action      := K_UPDATE;
		    --
		    --
		END IF;
	    --}
	    END IF;
	    --
	    --
	    IF l_pickup_stop_id IS NOT NULL
	    THEN
	    --{
		l_old_stop_location_id := FND_API.G_MISS_NUM;
		--
		--
		FOR stop_location_rec IN stop_location_cur
		                           (
					     p_stop_id => l_pickup_stop_id
				           )
		LOOP
		--{
		    l_old_stop_location_id := stop_location_rec.stop_location_id;
		--}
		END LOOP;
		--
		--
		IF p_pickup_location_id <> l_old_stop_location_id
		THEN
		    IF l_pickup_stop_id = p_first_stop_id
		    AND l_wsh_trip_action = K_UPDATE
		    THEN
			l_first_stop_new_location_id := p_pickup_location_id;
		    ELSE
		        l_pickup_stop_action := K_UPDATE;
		    END IF;
		END IF;
	    --}
	    END IF;
	    --
	    --
	    IF l_dropoff_stop_id IS NOT NULL
	    THEN
	    --{
		l_old_stop_location_id := FND_API.G_MISS_NUM;
		--
		--
		FOR stop_location_rec IN stop_location_cur
		                           (
					     p_stop_id => l_dropoff_stop_id
				           )
		LOOP
		--{
		    l_old_stop_location_id := stop_location_rec.stop_location_id;
		--}
		END LOOP;
		--
		--
		IF p_dropoff_location_id <> l_old_stop_location_id
		THEN
		    IF l_dropoff_stop_id = p_last_stop_id
		    AND l_wsh_trip_action = K_UPDATE
		    THEN
		       l_last_stop_new_location_id := p_dropoff_location_id;
		    ELSE
		        l_dropoff_stop_action := K_UPDATE;
		    END IF;
		END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF  l_fte_trip_id IS NULL
	AND l_fte_trip_name IS NOT NULL
	THEN
	--{
	    l_fte_trip_action  := K_CREATE;
	    l_fte_wsh_trip_seq := 10;
	--}
	END IF;
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 3 l_wsh_trip_action ' || l_wsh_trip_action,
		        		     WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF l_wsh_trip_action IN ( K_CREATE, K_UPDATE )
	THEN
	--{
	    fte_mls_util.derive_ship_method
	      (
	        p_carrier_id                => p_carrier_id,
	        p_mode_of_transport         => p_mode_of_transport,
	        p_service_level             => p_service_level,
	        p_carrier_name              => p_carrier_name,
	        p_mode_of_transport_meaning => p_mode_of_transport_meaning,
	        p_service_level_meaning     => p_service_level_meaning,
	        x_ship_method_code          => l_ship_method_code,
	        x_return_status             => l_return_status
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	      (
		p_api_name           => 'FTE_MLS_UTIL.DERIVE_SHIP_METHOD',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		p_delivery_id       => p_delivery_id,
		p_delivery_name       => p_delivery_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
      	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 4 l_pickup_stop_id ' || l_pickup_stop_id
	   	||'/ l_dropoff_stopId'|| l_dropoff_stop_id, WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF l_pickup_stop_id IS NULL
	OR l_dropoff_stop_id IS NULL
	THEN
	--{
	    IF p_move_stop_seq_start IS NOT NULL
	    AND p_move_stop_seq_to IS NOT NULL
	    THEN
	    --{
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 5 p_move_stop_seq_start ' || p_move_stop_seq_start,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

		FOR stop_rec IN stop_cur
				(
				  p_trip_id => p_wsh_trip_id,
				  p_stop_seq => p_move_stop_seq_start
				)
		LOOP
		--{
		    l_stop_new_seq := stop_rec.stop_sequence_number
				      + p_move_stop_seq_to
				      - p_move_stop_seq_start;
		    --
		    --
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 6 l_stop_new_seq ' || l_stop_new_seq
	   	||'/ l_stop_id'|| l_stop_id, WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
		    fte_mls_wrapper.create_update_stop
		      (
                         p_api_version_number     => 1.0,
                         p_init_msg_list          => FND_API.G_FALSE,
                         x_return_status          => l_return_status,
                         x_msg_count              => l_msg_count,
                         x_msg_data               => l_msg_data,
                         p_action_code            => K_UPDATE,
                         p_trip_id                => p_wsh_trip_id,
                         p_stop_location_id       => stop_rec.stop_location_id,
                         pp_stop_location_id      => stop_rec.stop_location_id,
	                 pp_STOP_ID               => stop_rec.stop_id,
 	                 pp_TRIP_ID               => p_wsh_trip_id,
 	                 pp_STOP_SEQUENCE_NUMBER  => FND_API.G_MISS_NUM,
			 x_stop_id                => l_stop_id
		      );
		    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_WRAPPER.UPDATE_STOP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => p_wsh_trip_id,
		          p_trip_segment_name  => p_wsh_trip_name,
		          p_trip_stop_id       => stop_rec.stop_id,
		          p_stop_seq_number    => stop_rec.stop_sequence_number,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	            THEN
	            --{
                        RAISE FND_API.G_EXC_ERROR;
	                --RETURN;
	            --}
	            END IF;
		    --
		    --
		    IF stop_rec.stop_id = l_pickup_stop_id
		    THEN
		    --{
			l_pickup_stop_seq := l_stop_new_seq;
		    --}
		    END IF;
		    --
		    --
		    IF stop_rec.stop_id = l_dropoff_stop_id
		    THEN
		    --{
			l_dropoff_stop_seq := l_stop_new_seq;
		    --}
		    END IF;
		--}
		END LOOP;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, ' 7 l_wsh_trip_action ' || l_wsh_trip_action,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	IF  l_wsh_trip_action = K_CREATE
	THEN
	--{
	    fte_mls_wrapper.create_update_trip
	      (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_FALSE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_code            => l_wsh_trip_action,
                p_rec_TRIP_ID            => l_wsh_trip_id,
                p_rec_NAME               => p_wsh_trip_name,
  -- adding vehicle info
  		p_rec_VEHICLE_ORGANIZATION_ID => p_veh_org_id,
                p_rec_VEHICLE_NUMBER	 => p_veh_num,
                p_rec_VEHICLE_NUM_PREFIX => p_veh_num_pre,
                p_rec_VEHICLE_ITEM_ID	 => p_veh_item_id,
  -- end adding vehicle info
    		p_rec_CARRIER_ID         => p_carrier_id,
                p_rec_SHIP_METHOD_CODE   => l_ship_method_code,
                p_rec_SERVICE_LEVEL      => p_service_level,
                p_rec_MODE_OF_TRANSPORT  => p_mode_of_transport,
 	        p_rec_LANE_ID            => p_lane_id,
 	        p_rec_SCHEDULE_ID        => p_schedule_id,
		p_rec_CONSOLIDATION_ALLOWED => 'N',
		p_rec_APPEND_FLAG	 => 'N',
                p_trip_name              => l_wsh_trip_name,
                x_trip_id                => l_wsh_trip_id,
                x_trip_name              => l_wsh_trip_name,
                p_rec_IGNORE_FOR_PLANNING => p_ignore_for_planning
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	      (
	        p_api_name           => 'FTE_MLS_WRAPPER.CREATE_UPDATE_TRIP',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		p_delivery_id        => p_delivery_id,
		p_delivery_name     => p_delivery_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	ELSIF  l_wsh_trip_action = K_UPDATE
	THEN
	--{
	    assign_service_to_segment
	      (
                p_init_msg_list             => FND_API.G_FALSE,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data,
		p_wsh_trip_id               => l_wsh_trip_id,
		p_wsh_trip_name             => l_wsh_trip_name,
		p_lane_id                   => p_lane_id,
		p_schedule_id               => p_schedule_id,
	        p_carrier_id                => p_carrier_id,
	        p_mode_of_transport         => p_mode_of_transport,
	        p_service_level             => p_service_level,
	        p_carrier_name              => p_carrier_name,
	        p_mode_of_transport_meaning => p_mode_of_transport_meaning,
	        p_service_level_meaning     => p_service_level_meaning,
	        p_ship_method_code          => l_ship_method_code,
		p_first_stop_id             => p_first_stop_id,
		p_first_stop_seq            => p_first_stop_seq,
		p_first_stop_location_id    => p_first_stop_location_id,
		p_first_stop_new_location_id => l_first_stop_new_location_id,
		p_first_stop_departure_date => p_first_stop_departure_date,
		p_first_stop_arrival_date   => p_first_stop_arrival_date,
		p_last_stop_id              => p_last_stop_id,
		p_last_stop_seq             => p_last_stop_seq,
		p_last_stop_location_id     => p_last_stop_location_id,
		p_last_stop_new_location_id => l_last_stop_new_location_id,
		p_last_stop_departure_date  => p_last_stop_departure_date,
		p_last_stop_arrival_date    => p_last_stop_arrival_date,
		p_veh_org_id		    => p_veh_org_id,
		p_veh_item_id		    => p_veh_item_id
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	      (
		p_api_name           => 'FTE_DELIVERY_LEGS_PVT.ASSIGN_SERVICE_TO_SEGMENT',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		p_delivery_id        => p_delivery_id,
		p_delivery_name      => p_delivery_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
      	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, '8 l_pickup_stop_id ' || l_pickup_stop_id
	   	|| '/l_pickup_stop_action '||l_pickup_stop_action,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--IF l_pickup_stop_id IS NULL
	IF l_pickup_stop_action IN ( K_CREATE, K_UPDATE )
	THEN
	--{
		    -- PACK I : HBHAGAVA
		    -- Check if stop is getting created. If yes the
		    -- get the weight volume uom of delivery and
		    -- assign that to stop.
		    IF (l_pickup_stop_action = K_CREATE)
		    THEN
			    OPEN dlvy_weight_volume_cur(p_delivery_id);
			    FETCH dlvy_weight_volume_cur
			    INTO l_dlvy_weight_uom,
				 l_dlvy_volume_uom;
			    CLOSE dlvy_weight_volume_cur;
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, '9 l_pickup_stop_seq ' || l_pickup_stop_seq
	   	|| '/l_pickup_stop_id '||l_pickup_stop_id,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
			    fte_mls_wrapper.create_update_stop
			      (
				 p_api_version_number     => 1.0,
				 p_init_msg_list          => FND_API.G_FALSE,
				 x_return_status          => l_return_status,
				 x_msg_count              => l_msg_count,
				 x_msg_data               => l_msg_data,
				 p_action_code            => l_pickup_stop_action,
				 p_trip_id                => l_wsh_trip_id,
				 p_stop_location_id       => p_pickup_location_id,
				 p_planned_dep_date       => p_pickup_departure_date,
				 pp_TRIP_ID               => l_wsh_trip_id,
				 pp_STOP_SEQUENCE_NUMBER  => FND_API.G_MISS_NUM,
				 pp_STOP_LOCATION_ID      => p_pickup_location_id,
				 pp_PLANNED_ARRIVAL_DATE  => p_pickup_arrival_date,
				 pp_PLANNED_DEPARTURE_DATE  => p_pickup_departure_date,
				 pp_WEIGHT_UOM_CODE       => l_dlvy_weight_uom,
				 pp_VOLUME_UOM_CODE       => l_dlvy_volume_uom,
				 x_stop_id                => l_pickup_stop_id
			      );

		    ELSE
			    fte_mls_wrapper.create_update_stop
			      (
				 p_api_version_number     => 1.0,
				 p_init_msg_list          => FND_API.G_FALSE,
				 x_return_status          => l_return_status,
				 x_msg_count              => l_msg_count,
				 x_msg_data               => l_msg_data,
				 p_action_code            => l_pickup_stop_action,
				 p_trip_id                => l_wsh_trip_id,
				 p_stop_location_id       => p_pickup_location_id,
				 p_planned_dep_date       => p_pickup_departure_date,
				 pp_TRIP_ID               => l_wsh_trip_id,
				 pp_STOP_ID               => l_pickup_stop_id,
				 pp_STOP_SEQUENCE_NUMBER  => l_pickup_stop_seq,
				 pp_STOP_LOCATION_ID      => p_pickup_location_id,
				 pp_PLANNED_ARRIVAL_DATE  => p_pickup_arrival_date,
				 pp_PLANNED_DEPARTURE_DATE  => p_pickup_departure_date,
				 x_stop_id                => return_pickup_stop_id
			      );
		    END IF;

		    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => l_wsh_trip_id,
		          p_trip_segment_name  => l_wsh_trip_name,
		          p_trip_stop_id       => l_pickup_stop_id,
		          p_stop_seq_number    => l_pickup_stop_seq,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	            THEN
	            --{
                        RAISE FND_API.G_EXC_ERROR;
	                --RETURN;
	            --}
	            END IF;
	--}
	END IF;
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name, '10 l_dropoff_stop_id ' || l_dropoff_stop_id
	   	|| '/l_dropoff_stop_action '||l_dropoff_stop_action,
	   	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	--IF l_dropoff_stop_id IS NULL
	IF l_dropoff_stop_action IN ( K_CREATE, K_UPDATE )
	THEN
	--{

		    IF (l_dropoff_stop_action = K_CREATE)
		    THEN
			    OPEN dlvy_weight_volume_cur(p_delivery_id);
			    FETCH dlvy_weight_volume_cur
			    INTO l_dlvy_weight_uom,
				 l_dlvy_volume_uom;
			    CLOSE dlvy_weight_volume_cur;
			    fte_mls_wrapper.create_update_stop
			      (
				 p_api_version_number     => 1.0,
				 p_init_msg_list          => FND_API.G_FALSE,
				 x_return_status          => l_return_status,
				 x_msg_count              => l_msg_count,
				 x_msg_data               => l_msg_data,
				 p_action_code            => l_dropoff_stop_action,
				 p_trip_id                => l_wsh_trip_id,
				 p_stop_location_id       => p_dropoff_location_id,
				 p_planned_dep_date       => p_dropoff_departure_date,
				 pp_TRIP_ID               => l_wsh_trip_id,
				 pp_STOP_SEQUENCE_NUMBER  => FND_API.G_MISS_NUM,
				 pp_STOP_LOCATION_ID      => p_dropoff_location_id,
				 pp_PLANNED_ARRIVAL_DATE  => p_dropoff_arrival_date,
				 pp_PLANNED_DEPARTURE_DATE  => p_dropoff_departure_date,
				 pp_WEIGHT_UOM_CODE       => l_dlvy_weight_uom,
				 pp_VOLUME_UOM_CODE       => l_dlvy_volume_uom,
				 x_stop_id                => l_dropoff_stop_id
			      );

		    ELSE
			    fte_mls_wrapper.create_update_stop
			      (
				 p_api_version_number     => 1.0,
				 p_init_msg_list          => FND_API.G_FALSE,
				 x_return_status          => l_return_status,
				 x_msg_count              => l_msg_count,
				 x_msg_data               => l_msg_data,
				 p_action_code            => l_dropoff_stop_action,
				 p_trip_id                => l_wsh_trip_id,
				 p_stop_location_id       => p_dropoff_location_id,
				 p_planned_dep_date       => p_dropoff_departure_date,
				 pp_TRIP_ID               => l_wsh_trip_id,
				 pp_STOP_ID               => l_dropoff_stop_id,
				 pp_STOP_SEQUENCE_NUMBER  => l_dropoff_stop_seq,
				 pp_STOP_LOCATION_ID      => p_dropoff_location_id,
				 pp_PLANNED_ARRIVAL_DATE  => p_dropoff_arrival_date,
				 pp_PLANNED_DEPARTURE_DATE  => p_dropoff_departure_date,
				 pp_WEIGHT_UOM_CODE       => l_dlvy_weight_uom,
				 pp_VOLUME_UOM_CODE       => l_dlvy_volume_uom,
				 x_stop_id                => return_dropoff_stop_id
			      );

		    END IF;


		    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => l_wsh_trip_id,
		          p_trip_segment_name  => l_wsh_trip_name,
		          p_trip_stop_id       => l_dropoff_stop_id,
		          p_stop_seq_number    => l_dropoff_stop_seq,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	            THEN
	            --{
                        RAISE FND_API.G_EXC_ERROR;
	                --RETURN;
	            --}
	            END IF;
	--}
	END IF;
	--
	--
	IF l_delivery_leg_action IN ( K_CREATE )
	THEN
	--{
            fte_mls_wrapper.Delivery_Action
            (
              p_api_version_number     => 1.0,
              p_init_msg_list          => FND_API.G_FALSE,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              p_action_code            => 'ASSIGN-TRIP',
              p_delivery_id            => p_delivery_id,
              p_asg_trip_id            => l_wsh_trip_id,
              p_asg_trip_name          => l_wsh_trip_name,
              p_asg_pickup_stop_id     => l_pickup_stop_id,
              p_asg_pickup_loc_id      => p_pickup_location_id,
              p_asg_pickup_arr_date    => p_pickup_arrival_date,
              p_asg_pickup_dep_date    => p_pickup_departure_date,
              p_asg_dropoff_stop_id    => l_dropoff_stop_id,
              p_asg_dropoff_loc_id     => p_dropoff_location_id,
              p_asg_dropoff_arr_date   => p_dropoff_arrival_date,
              p_asg_dropoff_dep_date   => p_dropoff_departure_date,
              x_trip_id                => l_trip_id,
              x_trip_name              => l_trip_name,
              x_delivery_leg_id        => l_delivery_leg_id,
              x_delivery_leg_seq       => l_delivery_leg_seq
	    ) ;
	    --
	    --
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_api_name, ' DELIVERY Action  RETURN VALUE ' || l_return_status,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

            FTE_MLS_UTIL.api_post_call
	           (
		     p_api_name           => 'FTE_MLS_WRAPPER.DELIVERY_ACTION',
		     p_api_return_status  => l_return_status,
		     p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		     p_trip_segment_id    => p_wsh_trip_id,
		     p_trip_segment_name  => p_wsh_trip_name,
		     p_trip_stop_id       => l_pickup_stop_id,
		     p_stop_seq_number    => p_pickup_stop_seq,
		     x_number_of_errors   => l_number_of_errors,
		     x_number_of_warnings => l_number_of_warnings,
		     x_return_status      => x_return_status
	           );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_fte_trip_action = K_CREATE
	THEN
	--{
	    fte_trips_pvt.Create_Update_Delete_Fte_Trip
	      (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_FALSE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_code            => l_fte_trip_action,
                pp_fte_trip_id           => l_fte_trip_id,
                pp_NAME                  => l_fte_trip_name,
                pp_private_trip          => 'N',
                pp_validation_required   => 'Y',
                x_trip_id                => l_fte_trip_id,
                x_name                   => l_fte_trip_name
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	      (
	        p_api_name           => 'FTE_TRIPS_PVT.CREATE_UPDATE_DELETE_FTE_TRIP',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		p_delivery_id        => p_delivery_id,
		p_delivery_name     => p_delivery_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	    --
	    --
	    fte_wsh_trips_pvt.Create_Update_Trip_Wrapper
	      (
                p_init_msg_list          => FND_API.G_FALSE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_code            => l_fte_trip_action,
                pp_fte_trip_id           => l_fte_trip_id,
                pp_wsh_trip_id           => l_wsh_trip_id,
		pp_sequence_number       => l_fte_wsh_trip_seq,
                p_validate_flag          => 'N'
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	      (
	        p_api_name           => 'FTE_WSH_TRIPS_PVT.CREATE_UPDATE_TRIP_WRAPPER',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		p_delivery_id        => p_delivery_id,
		p_delivery_name     => p_delivery_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	--IF p_fte_trip_id IS NOT NULL
	IF l_fte_trip_action = K_CREATE
	OR (
	     p_ui_page_name = GK_SEARCH_SEGMENTS_PAGE
	     AND l_fte_trip_id IS NOT NULL
	   )
	THEN
	--{
	    UPDATE wsh_delivery_legs
	    SET    fte_trip_id        = l_fte_trip_id,
		   LAST_UPDATE_DATE   = SYSDATE,
		   LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
		   LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
	    WHERE  delivery_leg_id    = l_delivery_leg_id;
	    --
	    --
	    IF SQL%NOTFOUND
	    THEN
	    --{
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		--
		--
                FTE_MLS_UTIL.api_post_call
	          (
	            p_api_name           => 'FTE_DELIVERY_LEGS_PVT.UPDATE_DLEG_FTE_TRIP',
		    p_api_return_status  => l_return_status,
		    p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		    p_delivery_id        => p_delivery_id,
		    p_delivery_name     => p_delivery_name,
		    x_number_of_errors   => l_number_of_errors,
		    x_number_of_warnings => l_number_of_warnings,
		    x_return_status      => x_return_status
	          );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	        THEN
	        --{
                    RAISE FND_API.G_EXC_ERROR;
	            --RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	IF l_reprice_required = 'Y'
	THEN
	--{
	    UPDATE wsh_delivery_legs
	    SET    reprice_required   = l_reprice_required,
		   LAST_UPDATE_DATE   = SYSDATE,
		   LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
		   LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
	    WHERE  delivery_leg_id    IN
		     ( SELECT delivery_leg_id
		       FROM   wsh_trip_stops wts,
			      wsh_delivery_legs wdl
                       WHERE  wts.trip_id         = p_wsh_trip_id
		       AND    wdl.pick_up_stop_id = wts.stop_id
		     );
	    --
	    --
	    IF SQL%NOTFOUND
	    THEN
	    --{
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		--
		--
                FTE_MLS_UTIL.api_post_call
	          (
	            p_api_name           => 'FTE_DELIVERY_LEGS_PVT.UPDATE_DLEG_REPRICE',
		    p_api_return_status  => l_return_status,
		    p_message_name       => 'FTE_DELIVERY_LEG_UNEXP_ERROR',
		    p_delivery_id        => p_delivery_id,
		    p_delivery_name     => p_delivery_name,
		    x_number_of_errors   => l_number_of_errors,
		    x_number_of_warnings => l_number_of_warnings,
		    x_return_status      => x_return_status
	          );
	        --
	        --
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	        OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	        THEN
	        --{
                    RAISE FND_API.G_EXC_ERROR;
	            --RETURN;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_api_name,'BEFORE CALLING FREIGHT RATE:PriReqId:laneId:'||
	   	p_pricing_request_id||':'||p_lane_id, WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF p_pricing_request_id IS NOT NULL
	AND p_pricing_request_id > 0
	AND p_lane_id IS NOT NULL
	THEN
	--{
	    FTE_FREIGHT_PRICING.MOVE_FC_TEMP_TO_MAIN
	      (
                p_init_msg_list   => FND_API.G_FALSE,
		x_return_status   => l_return_status,
		p_delivery_leg_id => l_delivery_leg_id,
		p_lane_id         => p_lane_id,
		p_schedule_id     => p_schedule_id,
		p_request_id      => p_pricing_request_id,
		p_service_type_code => p_service_level
	      );
	    --
	    --
            FTE_MLS_UTIL.api_post_call
	           (
		     p_api_name           => 'FTE_FREIGHT_PRICING.MOVE_FC_TEMP_TO_MAIN',
		     p_api_return_status  => l_return_status,
		     p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		     p_trip_segment_id    => p_wsh_trip_id,
		     p_trip_segment_name  => p_wsh_trip_name,
		     p_trip_stop_id       => l_pickup_stop_id,
		     p_stop_seq_number    => p_pickup_stop_seq,
		     x_number_of_errors   => l_number_of_errors,
		     x_number_of_warnings => l_number_of_warnings,
		     x_return_status      => x_return_status
	           );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
        x_ship_method_code := l_ship_method_code;
	x_delivery_leg_id  := l_delivery_leg_id;
	x_delivery_leg_seq := l_delivery_leg_seq;
	x_pickup_stop_id   := l_pickup_stop_id;
	x_dropoff_stop_id  := l_dropoff_stop_id;
	x_pickup_stop_seq  := l_pickup_stop_seq;
	x_dropoff_stop_seq := l_dropoff_stop_seq;
	x_wsh_trip_id      := l_wsh_trip_id;
	x_wsh_trip_name    := l_wsh_trip_name;
	x_fte_trip_id      := l_fte_trip_id;
	x_fte_trip_name    := l_fte_trip_name;
	--
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_api_name, ' RETURN VALUE ' || l_number_of_errors,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	IF l_number_of_errors > 0
	THEN
            ROLLBACK TO PROCESS_DELIVERY_LEG_PUB;
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
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
                ROLLBACK TO PROCESS_DELIVERY_LEG_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO PROCESS_DELIVERY_LEG_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO PROCESS_DELIVERY_LEG_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--
		--
/*  commented to be consistent with error handling as in WSH.
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
*/
               wsh_util_core.default_handler('FTE_DELIVERY_LEGS_PVT.PROCESS_DELIVERY_LEG');
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
  END process_delivery_leg;
  --
  --
  PROCEDURE assign_service_to_segment
	      (
	        P_init_msg_list             IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status             OUT NOCOPY    VARCHAR2,
	        X_msg_count                 OUT NOCOPY    NUMBER,
	        X_msg_data                  OUT NOCOPY    VARCHAR2,
		p_ui_page_name              IN     VARCHAR2 DEFAULT GK_DLEG_WB_PAGE,
		p_wsh_trip_id               IN     NUMBER,
		p_wsh_trip_name             IN     VARCHAR2,
		p_lane_id                   IN     NUMBER,
		p_carrier_id                IN     NUMBER,
		p_mode_of_transport         IN     VARCHAR2,
		p_service_level             IN     VARCHAR2,
		p_carrier_name              IN     VARCHAR2,
		p_mode_of_transport_meaning IN     VARCHAR2,
		p_service_level_meaning     IN     VARCHAR2,
		p_ship_method_code          IN     VARCHAR2 DEFAULT NULL,
		p_schedule_id               IN     NUMBER   DEFAULT NULL,
		p_first_stop_id             IN     NUMBER   DEFAULT NULL,
		p_first_stop_seq            IN     NUMBER   DEFAULT NULL,
		p_first_stop_location_id    IN     NUMBER   DEFAULT NULL,
		p_first_stop_new_location_id IN    NUMBER   DEFAULT NULL,
		p_first_stop_departure_date IN     DATE     DEFAULT NULL,
		p_first_stop_arrival_date   IN     DATE     DEFAULT NULL,
		p_last_stop_id              IN     NUMBER   DEFAULT NULL,
		p_last_stop_seq             IN     NUMBER   DEFAULT NULL,
		p_last_stop_location_id     IN     NUMBER   DEFAULT NULL,
		p_last_stop_new_location_id IN     NUMBER   DEFAULT NULL,
		p_last_stop_departure_date  IN     DATE     DEFAULT NULL,
		p_last_stop_arrival_date    IN     DATE     DEFAULT NULL,
		p_veh_org_id		    IN     NUMBER   DEFAULT NULL,
		p_veh_item_id		    IN     NUMBER   DEFAULT NULL
	      )
  IS
  --{
        l_api_name              CONSTANT VARCHAR2(30)   := 'assign_service_to_segment';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
	p_action_type               VARCHAR2(32767);
        l_stop_id                   NUMBER;
        l_trip_id                   NUMBER;
	l_wsh_trip_name             VARCHAR2(32767);
	--
	--
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
        l_first_stop_id             NUMBER;
        l_first_stop_location_id    NUMBER;
        l_first_stop_seq            NUMBER;
        l_first_stop_dep_date       DATE;
        l_first_stop_arr_date       DATE;
	--
        l_last_stop_id             NUMBER;
        l_last_stop_location_id    NUMBER;
        l_last_stop_seq            NUMBER;
        l_last_stop_dep_date       DATE;
        l_last_stop_arr_date       DATE;
	--
	--
        l_stop_location_id    NUMBER;
      --
      --
      CURSOR stop_cur (p_trip_id NUMBER)
      IS
	SELECT stop_id, stop_location_id, stop_sequence_number
	FROM   wsh_trip_stops
	WHERE  trip_id = p_trip_id
	order by stop_sequence_number;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTEVDLGB' || '.' || 'assign_service_to_segment';

  --}
  BEGIN
  --{
	--
        -- Standard Start of API savepoint
        SAVEPOINT   ASSIGN_SERVICE_TO_SEGMENT_PUB;
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
	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);

		WSH_DEBUG_SV.logmsg(l_module_name,' Trip Name => '  ||
					p_wsh_trip_name ,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	--
	IF p_schedule_id IS NOT NULL
	THEN
	--{
	    IF  (
		     p_first_stop_id             IS NULL
                  OR p_first_stop_location_id    IS NULL
                  OR p_first_stop_departure_date IS NULL
                  --OR p_first_stop_arrival_date   IS NULL
		  OR p_last_stop_id              IS NULL
                  OR p_last_stop_location_id     IS NULL
                  --OR p_last_stop_departure_date  IS NULL
                  OR p_last_stop_arrival_date    IS NULL
	        )
	    THEN
	    --{
                FTE_MLS_UTIL.api_post_call
	          (
	            p_api_name           => 'FIRST_LAST_ID_DATES_NULL',
		    p_api_return_status  => WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
		    p_message_name       => 'FTE_SEGMENT_UNEXP_ERROR',
		    p_trip_segment_id    => p_wsh_trip_id,
		    p_trip_segment_name  => p_wsh_trip_name,
		    x_number_of_errors   => l_number_of_errors,
		    x_number_of_warnings => l_number_of_warnings,
		    x_return_status      => x_return_status
	          );
	        --
	        --
                RAISE FND_API.G_EXC_ERROR;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
        --  Initialize API return status to success
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors    := 0;
	l_number_of_warnings  := 0;
	l_first_stop_id       := NULL;
	l_last_stop_id        := NULL;
	--
	--
	IF p_schedule_id IS NOT NULL
	OR p_first_stop_new_location_id IS NOT NULL
	OR p_last_stop_new_location_id IS NOT NULL
	THEN
	--{
	    /*
	    FOR stop_rec IN stop_cur (p_trip_id => p_wsh_trip_id)
	    LOOP
	    --{
	        IF l_first_stop_id IS NULL
	        THEN
	        --{
		    l_first_stop_id          := stop_rec.stop_id;
		    l_first_stop_location_id := NVL(
						     p_first_stop_location_id,
						     stop_rec.stop_location_id
					            );
		    l_first_stop_seq         := stop_rec.stop_sequence_number;
		    l_first_stop_dep_date    := NVL(
						     l_schedule_departure_date,
		                                     stop_rec.planned_departure_date;
					           );
		    l_first_stop_arr_date    := LEAST
						  (
						     NVL
						      (
							l_schedule_departure_date,
							stop_rec.planned_arrival_date
						      ),

						     stop_rec.planned_arrival_date;

						   );
	        --}
	        END IF;
	        --
	        --
	        l_last_stop_id          := stop_rec.stop_id;
	        l_last_stop_location_id := NVL(
					         p_last_stop_location_id,
					         stop_rec.stop_location_id
				              );
	        l_last_stop_seq         := stop_rec.stop_sequence_number;
	        l_last_stop_dep_date    := GREATEST
		                             (
                                               NVL
		                                (
		                                  l_schedule_arrival_date,
		                                  stop_rec.planned_departure_date;
		                                ),
		                               stop_rec.planned_departure_date;
		                             );
	        l_last_stop_arr_date    := NVL(
					         l_schedule_arrival_date,
					         stop_rec.planned_arrival_date;
					      );

	    --}
	    END LOOP;
	    */
	    --
	    --
	    --IF l_first_stop_id IS NOT NULL
	    IF p_schedule_id IS NOT NULL
	    OR p_first_stop_new_location_id IS NOT NULL
	    THEN
	    --{
		l_stop_location_id := NVL(p_first_stop_new_location_id,p_first_stop_location_id);
		--
		--
		    fte_mls_wrapper.create_update_stop
		      (
                         p_api_version_number     => 1.0,
                         p_init_msg_list          => FND_API.G_FALSE,
                         x_return_status          => l_return_status,
                         x_msg_count              => l_msg_count,
                         x_msg_data               => l_msg_data,
                         p_action_code            => 'UPDATE',
                         p_trip_id                => p_wsh_trip_id,
                         p_stop_location_id       => l_stop_location_id,
                         p_planned_dep_date       => p_first_stop_departure_date,
                         pp_stop_location_id      => l_stop_location_id,
	                 pp_STOP_ID               => p_first_stop_id,
 	                 pp_TRIP_ID               => p_wsh_trip_id,
 	                 pp_STOP_SEQUENCE_NUMBER  => p_first_stop_seq,
 	                 pp_PLANNED_ARRIVAL_DATE   => p_first_stop_arrival_date,
 	                 pp_PLANNED_DEPARTURE_DATE => p_first_stop_departure_date,
			 x_stop_id                => l_stop_id
		      );
		    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_WRAPPER.UPDATE_STOP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => p_wsh_trip_id,
		          p_trip_segment_name  => p_wsh_trip_name,
		          p_trip_stop_id       => p_first_stop_id,
		          p_stop_seq_number    => p_first_stop_seq,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	            THEN
	            --{
                        RAISE FND_API.G_EXC_ERROR;
	                --RETURN;
	            --}
	            END IF;
	    --}
	    END IF;
	    --
	    --
	    --IF l_last_stop_id IS NOT NULL
	    IF p_schedule_id IS NOT NULL
	    OR p_last_stop_new_location_id IS NOT NULL
	    THEN
	    --{
		l_stop_location_id := NVL(p_last_stop_new_location_id,p_last_stop_location_id);
		--
		--
		    fte_mls_wrapper.create_update_stop
		      (
                         p_api_version_number     => 1.0,
                         p_init_msg_list          => FND_API.G_FALSE,
                         x_return_status          => l_return_status,
                         x_msg_count              => l_msg_count,
                         x_msg_data               => l_msg_data,
                         p_action_code            => 'UPDATE',
                         p_trip_id                => p_wsh_trip_id,
                         p_stop_location_id       => l_stop_location_id,
                         p_planned_dep_date       => p_last_stop_departure_date,
                         pp_stop_location_id      => l_stop_location_id,
	                 pp_STOP_ID               => p_last_stop_id,
 	                 pp_TRIP_ID               => p_wsh_trip_id,
 	                 pp_STOP_SEQUENCE_NUMBER  => p_last_stop_seq,
 	                 pp_PLANNED_ARRIVAL_DATE   => p_last_stop_arrival_date,
 	                 pp_PLANNED_DEPARTURE_DATE => p_last_stop_departure_date,
			 x_stop_id                => l_stop_id
		      );
		    --
		    --
                    FTE_MLS_UTIL.api_post_call
		        (
		          p_api_name           => 'FTE_MLS_WRAPPER.UPDATE_STOP',
		          p_api_return_status  => l_return_status,
		          p_message_name       => 'FTE_SEGMENT_STOP_UNEXP_ERROR',
		          p_trip_segment_id    => p_wsh_trip_id,
		          p_trip_segment_name  => p_wsh_trip_name,
		          p_trip_stop_id       => p_last_stop_id,
		          p_stop_seq_number    => p_last_stop_seq,
		          x_number_of_errors   => l_number_of_errors,
		          x_number_of_warnings => l_number_of_warnings,
		          x_return_status      => x_return_status
		        );
	            --
	            --
	            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	            OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	            THEN
	            --{
                        RAISE FND_API.G_EXC_ERROR;
	                --RETURN;
	            --}
	            END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	--{
	    fte_mls_wrapper.create_update_trip
	      (
                p_api_version_number     => 1.0,
                p_init_msg_list          => FND_API.G_FALSE,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_action_code            => 'UPDATE',
                p_rec_TRIP_ID            => p_wsh_trip_id,
                p_rec_NAME               => p_wsh_trip_name,
                p_rec_CARRIER_ID         => p_carrier_id,
                p_rec_SHIP_METHOD_CODE   => p_ship_method_code,
                p_rec_SERVICE_LEVEL      => p_service_level,
                p_rec_MODE_OF_TRANSPORT  => p_mode_of_transport,
 	        p_rec_LANE_ID            => p_lane_id,
 	        p_rec_SCHEDULE_ID        => p_schedule_id,
                p_trip_name              => p_wsh_trip_name,
    		p_rec_VEHICLE_ORGANIZATION_ID => p_veh_org_id,
                p_rec_VEHICLE_ITEM_ID	 => p_veh_item_id,
                x_trip_id                => l_trip_id,
                x_trip_name              => l_wsh_trip_name
	      );
	    --
	/*
	-- Need to add action code CREATE, leg/delivery/vehicle/vehOrg
	FTE_MLS_TEST_NT.UPDATE_SERVICE_ON_TRIP(
	  p_API_VERSION_NUMBER	=> 1.0,
	  p_INIT_MSG_LIST	=> FND_API.G_TRUE,
	  p_COMMIT		=> FND_API.G_FALSE,
	  p_CALLER		=> 'FTE',
	  p_SERVICE_ACTION	=> 'UPDATE',
	  p_DELIVERY_ID		=> p_delivery_id,
	  p_DELIVERY_LEG_ID	=> p_delivery_leg_id,
	  p_TRIP_ID		=> p_wsh_trip_id,
	  p_LANE_ID		=> p_lane_id,
	  p_SCHEDULE_ID		=> p_schedule_id,
	  p_CARRIER_ID		=> p_carrier_id,
	  p_SERVICE_LEVEL	=> p_service_level,
	  p_MODE_OF_TRANSPORT	=> p_mode_of_transport,
	  p_VEHICLE_ITEM_ID	=> p_vehicle_item_id,
	  p_VEHICLE_ORG_ID	=> p_vehicle_org_id,
	  p_RANK_ID		=> null,
	  x_RETURN_STATUS	=> l_return_status,
	  x_MSG_COUNT		=> l_msg_count,
	  x_MSG_DATA		=> l_msg_data);
	    --
        */
	 FTE_MLS_UTIL.api_post_call
	      (
	        p_api_name           => 'FTE_MLS_WRAPPER.CREATE_UPDATE_TRIP',
		p_api_return_status  => l_return_status,
		p_message_name       => 'FTE_SEGMENT_UNEXP_ERROR',
		p_trip_segment_id    => p_wsh_trip_id,
		p_trip_segment_name  => p_wsh_trip_name,
		x_number_of_errors   => l_number_of_errors,
		x_number_of_warnings => l_number_of_warnings,
		x_return_status      => x_return_status
	      );
	    --
	    --
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	    OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
	    THEN
	    --{
                RAISE FND_API.G_EXC_ERROR;
	        --RETURN;
	    --}
	    END IF;
	--}
	--
	--
	IF l_number_of_errors > 0
	THEN
            ROLLBACK TO ASSIGN_SERVICE_TO_SEGMENT_PUB;
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
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
                ROLLBACK TO ASSIGN_SERVICE_TO_SEGMENT_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO ASSIGN_SERVICE_TO_SEGMENT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO ASSIGN_SERVICE_TO_SEGMENT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--
		--
               wsh_util_core.default_handler('FTE_DELIVERY_LEGS_PVT.assign_service_to_segment');
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
  END assign_service_to_segment;
  --
  --
    PROCEDURE build_delivery_leg_info
    		(
		  P_init_msg_list               IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
		  X_return_status               OUT NOCOPY     VARCHAR2,
		  X_msg_count                   OUT NOCOPY     NUMBER,
		  X_msg_data                    OUT NOCOPY     VARCHAR2,
    		  p_dleg_id		        IN      NUMBER,
    		  x_PUStopId			OUT NOCOPY	NUMBER,
    		  x_PUStopLocationId		OUT NOCOPY	NUMBER,
    		  x_PUStopLocation		OUT NOCOPY	VARCHAR2,
    		  x_PUStopCSZ			OUT NOCOPY	VARCHAR2,
    		  x_PUStopCountry		OUT NOCOPY	VARCHAR2,
    		  x_PUStopActualArrivalDate	OUT NOCOPY	DATE,
    		  x_PUStopActualDepartureDate	OUT NOCOPY	DATE,
    		  x_PUStopPlannedArrivalDate	OUT NOCOPY	DATE,
    		  x_PUStopPlannedDepartureDate	OUT NOCOPY	DATE,
    		  x_PUStopSequenceNumber	OUT NOCOPY	NUMBER,
    		  x_PUStopStatusCode		OUT NOCOPY	VARCHAR2,
    		  x_PUStopTripId		OUT NOCOPY	NUMBER,
    		  x_DOStopId			OUT NOCOPY	NUMBER,
    		  x_DOStopLocationId		OUT NOCOPY	NUMBER,
    		  x_DOStopLocation		OUT NOCOPY	VARCHAR2,
    		  x_DOStopCSZ			OUT NOCOPY	VARCHAR2,
    		  x_DOStopCountry		OUT NOCOPY	VARCHAR2,
    		  x_DOStopActualArrivalDate	OUT NOCOPY	DATE,
    		  x_DOStopActualDepartureDate	OUT NOCOPY	DATE,
    		  x_DOStopPlannedArrivalDate	OUT NOCOPY	DATE,
    		  x_DOStopPlannedDepartureDate	OUT NOCOPY	DATE,
    		  x_DOStopSequenceNumber	OUT NOCOPY	NUMBER,
    		  x_DOStopStatusCode		OUT NOCOPY	VARCHAR2,
    		  x_DOStopTripId		OUT NOCOPY	NUMBER,
		  x_CarrierId			OUT NOCOPY	NUMBER,
		  x_CarrierName			OUT NOCOPY	VARCHAR2,
		  x_LaneId			OUT NOCOPY	NUMBER,
		  x_LaneNumber			OUT NOCOPY	VARCHAR2,
		  x_ScheduleId			OUT NOCOPY	NUMBER,
		  x_ModeOfTransport		OUT NOCOPY	VARCHAR2,
		  x_ModeOfTransportMeaning	OUT NOCOPY	VARCHAR2,
		  x_ServiceLevel		OUT NOCOPY	VARCHAR2,
		  x_ServiceLevelMeaning		OUT NOCOPY	VARCHAR2,
		  x_ShipMethodCode		OUT NOCOPY	VARCHAR2,
		  x_TripSegmentId		OUT NOCOPY	NUMBER,
		  x_TripSegmentName		OUT NOCOPY	VARCHAR2,
		  x_TripSegmentStatusCode	OUT NOCOPY	VARCHAR2,
		  x_Price			OUT NOCOPY	NUMBER,
		  x_Currency			OUT NOCOPY	VARCHAR2,
		  x_OriginStopId		OUT NOCOPY	NUMBER,
		  x_OriginStopStatusCode	OUT NOCOPY	VARCHAR2,
		  x_OriginStopSequenceNumber	OUT NOCOPY	NUMBER,
		  x_OriginStopLocationId	OUT NOCOPY	NUMBER,
		  x_OriginLocation		OUT NOCOPY	VARCHAR2,
		  x_OriginCSZ			OUT NOCOPY	VARCHAR2,
		  x_OriginCountry		OUT NOCOPY	VARCHAR2,
		  x_OriginDepartureDate		OUT NOCOPY	DATE,
		  x_OriginArrivalDate		OUT NOCOPY	DATE,
		  x_DestStopId			OUT NOCOPY	NUMBER,
		  x_DestStopStatusCode		OUT NOCOPY	VARCHAR2,
		  x_DestStopSequenceNumber	OUT NOCOPY	NUMBER,
		  x_DestStopLocationId		OUT NOCOPY	NUMBER,
		  x_DestLocation		OUT NOCOPY	VARCHAR2,
		  x_DestCSZ			OUT NOCOPY	VARCHAR2,
		  x_DestCountry			OUT NOCOPY	VARCHAR2,
		  x_DestDepartureDate		OUT NOCOPY	DATE,
		  x_DestArrivalDate		OUT NOCOPY	DATE,
		  x_TenderStatus                OUT NOCOPY      VARCHAR2,
		  x_TripPlannedFlag             OUT NOCOPY      VARCHAR2,
		  x_TripShipmentsTypeFlag       OUT NOCOPY      VARCHAR2,
		  x_DOStopPhysLocationId        OUT NOCOPY      NUMBER,
		  x_DestStopPhysLocationId      OUT NOCOPY      NUMBER,
		  x_BolNumber                   OUT NOCOPY      VARCHAR2,
		  x_VehicleOrgId		OUT NOCOPY	NUMBER,
		  x_VehicleItemId		OUT NOCOPY	NUMBER,
		  x_ParentDLegId		OUT NOCOPY	NUMBER,
		  x_RankId			OUT NOCOPY	NUMBER,
		  x_RoutingRuleId		OUT NOCOPY	NUMBER,
		  x_AppendFlag			OUT NOCOPY	VARCHAR2,
		  x_ParentDlvyName		OUT NOCOPY	VARCHAR2
		 )
    IS
    --{
	--
	--
        l_api_name              CONSTANT VARCHAR2(30)   := 'build_delivery_leg_info';
        l_api_version           CONSTANT NUMBER         := 1.0;

        --
        --

	l_return_status VARCHAR2(32767);

        -- Added l_location_id for 11.5.10+ TP ER Locations
	l_location_id	NUMBER;

	l_location	VARCHAR2(1000);
	l_csz		VARCHAR2(1000);
	l_country	VARCHAR2(100);
	--
	--PICKUP CURSOR
	CURSOR get_pickup_info_cur (dLegId NUMBER)
	IS
	SELECT	st.actual_arrival_date,st.actual_departure_date,
		st.planned_arrival_date,st.planned_departure_date,
	   	st.stop_sequence_number, st.status_code,
	   	st.stop_location_id, st.trip_id, st.stop_id,
		t.carrier_id carrier_id, t.lane_id lane_id,
		t.schedule_id schedule_id, t.mode_of_transport mode_of_transport,
		t.service_level service_level, t.ship_method_code ship_method_code,
		t.name name, t.status_code trip_status,
		t.load_tender_status, -- new 11/6 added by dmlewis
		t.planned_flag, t.shipments_type_flag, t.vehicle_item_id,
		t.vehicle_organization_id, dl.parent_delivery_leg_id,
		t.rank_id, t.routing_rule_id, t.append_flag
	FROM    wsh_delivery_legs dl, wsh_trip_stops st, wsh_trips t
	WHERE	dl.delivery_leg_id = dLegId
	AND	dl.pick_up_stop_id = st.stop_id
	AND	t.trip_id = st.trip_id;
	--
	--
	--DROPOFF CURSOR
        --Modified for 11.5.10+ TP ER Locations
	--
	CURSOR get_dropoff_info_cur (dLegId NUMBER)
	IS
	SELECT	st.stop_id, st.physical_stop_id, st.trip_id,
	        st.stop_location_id, st.physical_location_id,
	        st.actual_arrival_date, st.actual_departure_date,
	        st.planned_arrival_date, st.planned_departure_date,
	        st.stop_sequence_number, st.status_code
	FROM wsh_trip_stops st
	WHERE physical_stop_id IS NULL
	START WITH stop_id IN
	  (SELECT stop_id FROM wsh_trip_stops, wsh_delivery_legs
	   WHERE drop_off_stop_id = stop_id
	   AND delivery_leg_id = dlegId)
	   CONNECT BY PRIOR physical_stop_id = stop_id;
	--
	-- GET PRICE CURSOR
	CURSOR get_price_info_cur (dLegId NUMBER)
	IS
	SELECT TOTAL_AMOUNT,CURRENCY_CODE FROM WSH_FREIGHT_COSTS
		WHERE DELIVERY_LEG_ID = dLegId
		AND LINE_TYPE_CODE = 'SUMMARY'
		AND DELIVERY_DETAIL_ID IS NULL;
	--
	--
	--
	-- GET TRIP SEGMENT ORIGIN DESTINATION CURSOR
	CURSOR get_trip_seg_origin_cur (trip_seg_Id NUMBER)
	IS
	SELECT stop_id, status_code, stop_sequence_number,
	       stop_location_id,planned_departure_date,
	       planned_arrival_date
	FROM   wsh_trip_stops where trip_id = trip_seg_id
	AND    stop_sequence_number = (
		SELECT min(stop_sequence_number)
		FROM   wsh_trip_stops where trip_id = trip_seg_id);
	--
	--
	-- GET TRIP SEGMENT ORIGIN DESTINATION CURSOR
	CURSOR get_trip_seg_dest_cur (trip_seg_Id NUMBER)
	IS
	SELECT stop_id, status_code, stop_sequence_number,
	       stop_location_id,planned_departure_date,
	       planned_arrival_date, physical_location_id
	FROM   wsh_trip_stops where trip_id = trip_seg_id
	AND    stop_sequence_number = (
		SELECT max(stop_sequence_number)
		FROM   wsh_trip_stops where trip_id = trip_seg_id);
	--
	-- GET Mode Of Transport
	--
	CURSOR get_mode_of_transport_cur (c_mode_code VARCHAR2)
	IS
	SELECT meaning mode_of_transport_meaning
	FROM fnd_lookup_values_vl
	WHERE lookup_type = 'WSH_MODE_OF_TRANSPORT'
	AND lookup_code = c_mode_code;
	--
	--
	-- GET Service Level
	--
	CURSOR get_service_level_cur (c_service_code VARCHAR2)
	IS
	SELECT meaning service_type_meaning
	FROM fnd_lookup_values_vl
	WHERE lookup_type = 'WSH_SERVICE_LEVELS'
	AND lookup_code = c_service_code;
	--
	CURSOR get_lane_cur (c_lane_id VARCHAR2)
        IS
        SELECT lane_number
        FROM fte_lanes
        WHERE lane_id = c_lane_id;
        --
        -- GET BOL Number
        CURSOR get_bol_number_cur (dLegId NUMBER)
	IS
	SELECT sequence_number
	FROM wsh_document_instances
        WHERE entity_id = dLegId
        AND entity_name = 'WSH_DELIVERY_LEGS'
        AND document_type = 'BOL'
        AND status = 'PLANNED';
	--
	-- GET PARENT DELIVERY INFO
        CURSOR get_parent_dlvy_info_cur (c_parentDLegId NUMBER)
	IS
	SELECT wnd.delivery_id, wnd.name
	FROM wsh_new_deliveries wnd, wsh_delivery_legs wdl
        WHERE wdl.delivery_leg_id = c_parentDLegId
        AND wdl.delivery_id = wnd.delivery_id;
--
--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_DELIVERY_LEGS_PVT' || '.' || l_api_name;



    --}
    BEGIN
    --{
	X_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- INITIALIZATION

      IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
      END IF;

	--
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;
	--
	--
	-- PICKUP STOP INFORMATION
	x_PUStopId			:= NULL;
	x_PUStopLocationId		:= NULL;
	x_PUStopLocation		:= NULL;
	x_PUStopCSZ			:= NULL;
	x_PUStopCountry			:= NULL;
	x_PUStopActualArrivalDate	:= NULL;
	x_PUStopActualDepartureDate	:= NULL;
	x_PUStopPlannedArrivalDate	:= NULL;
	x_PUStopPlannedDepartureDate	:= NULL;
	x_PUStopSequenceNumber		:= NULL;
	x_PUStopStatusCode		:= NULL;
	x_PUStopTripId			:= NULL;
	x_CarrierId			:= NULL;
	x_LaneId			:= NULL;
	x_ScheduleId			:= NULL;
	x_ModeOfTransport		:= NULL;
	x_ServiceLevel			:= NULL;
	x_ShipMethodCode		:= NULL;
	x_TripSegmentId			:= NULL;
	x_TripSegmentName		:= NULL;
	x_TripSegmentStatusCode		:= NULL;
	x_TenderStatus			:= NULL;
	x_TripPlannedFlag		:= NULL;
	x_TripShipmentsTypeFlag         := NULL;
	x_VehicleOrgId			:= NULL;
	x_VehicleItemId			:= NULL;
	x_ParentDLegId			:= NULL;
	x_RankId			:= NULL;
	x_RoutingRuleId			:= NULL;
	x_AppendFlag			:= NULL;
	--

	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 1 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;


	--
	FOR get_pickup_info_rec IN get_pickup_info_cur(p_dLeg_id)
	LOOP
	--{
		l_location	:=null;
		l_csz		:=null;
		l_country	:=null;
		l_return_status :=null;
		fte_mls_util.get_location_info(
			     p_location_id 	=> get_pickup_info_rec.stop_location_id,
			     x_location	   	=> l_location,
			     x_csz	   	=> l_csz,
			     x_country		=> l_country,
			     x_return_status	=> l_return_status);

		x_PUStopId			:= get_pickup_info_rec.stop_id;
		x_PUStopLocationId		:= get_pickup_info_rec.stop_location_id;
		x_PUStopLocation		:= l_location;
		x_PUStopCSZ			:= l_csz;
		x_PUStopCountry			:= l_country;
		x_PUStopActualArrivalDate	:= get_pickup_info_rec.actual_arrival_date;
		x_PUStopActualDepartureDate	:= get_pickup_info_rec.actual_departure_date;
		x_PUStopPlannedArrivalDate	:= get_pickup_info_rec.planned_arrival_date;
		x_PUStopPlannedDepartureDate	:= get_pickup_info_rec.planned_departure_date;
		x_PUStopSequenceNumber		:= get_pickup_info_rec.stop_sequence_number;
		x_PUStopStatusCode		:= get_pickup_info_rec.status_code;
		x_PUStopTripId			:= get_pickup_info_rec.trip_id;
		x_CarrierId			:= get_pickup_info_rec.carrier_id;
		x_LaneId			:= get_pickup_info_rec.lane_id;
		x_ScheduleId			:= get_pickup_info_rec.schedule_id;
		x_ModeOfTransport		:= get_pickup_info_rec.mode_of_transport;
		x_ServiceLevel			:= get_pickup_info_rec.service_level;
		x_ShipMethodCode		:= get_pickup_info_rec.ship_method_code;
		x_TripSegmentId			:= get_pickup_info_rec.trip_id;
		x_TripSegmentName		:= get_pickup_info_rec.name;
		x_TripSegmentStatusCode		:= get_pickup_info_rec.trip_status;
		x_TenderStatus			:= get_pickup_info_rec.load_tender_status;
		x_TripPlannedFlag		:= get_pickup_info_rec.planned_flag;
		x_TripShipmentsTypeFlag         := get_pickup_info_rec.shipments_type_flag;
		x_VehicleOrgId			:= get_pickup_info_rec.vehicle_organization_id;
		x_VehicleItemId			:= get_pickup_info_rec.vehicle_item_id;
		x_ParentDLegId			:= get_pickup_info_rec.parent_delivery_leg_id;
		x_RankId			:= get_pickup_info_rec.rank_id;
		x_RoutingRuleId			:= get_pickup_info_rec.routing_rule_id;
		x_AppendFlag			:= get_pickup_info_rec.append_flag;

	--}
	END LOOP;
	-- END OF PICKUP STOP INFORMATION
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 2 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;


	--
        IF get_pickup_info_cur%ISOPEN THEN
          CLOSE get_pickup_info_cur;
	END IF;
	--
	--
	-- DROPOFF STOP INFORMATION
	x_DOStopId			:= NULL;
	x_DOStopLocationId		:= NULL;
	x_DOStopLocation		:= NULL;
	x_DOStopCSZ			:= NULL;
	x_DOStopCountry			:= NULL;
	x_DOStopActualArrivalDate	:= NULL;
	x_DOStopActualDepartureDate	:= NULL;
	x_DOStopPlannedArrivalDate	:= NULL;
	x_DOStopPlannedDepartureDate	:= NULL;
	x_DOStopSequenceNumber		:= NULL;
	x_DOStopStatusCode		:= NULL;
	x_DOStopTripId			:= NULL;
	x_DOStopPhysLocationId          := NULL;
	--
	--
	--
        -- Modified for 11.5.10+ Locations: Check if the stop has a physical location id.
        -- If yes, use physical_location_id; if no, use stop_location_id.
	--
	FOR get_dropoff_info_rec IN get_dropoff_info_cur(p_dLeg_id)
	LOOP
	--{
		l_location_id	:=null;
		l_location	:=null;
		l_csz		:=null;
		l_country	:=null;
		l_return_status :=null;

		IF (get_dropoff_info_rec.physical_location_id IS NULL)
		THEN
			l_location_id := get_dropoff_info_rec.stop_location_id;
		ELSE
			l_location_id := get_dropoff_info_rec.physical_location_id;
		END IF;

		fte_mls_util.get_location_info(
			     p_location_id 	=> l_location_id,
			     x_location	   	=> l_location,
			     x_csz	   	=> l_csz,
			     x_country		=> l_country,
			     x_return_status	=> l_return_status);

		x_DOStopId			:= get_dropoff_info_rec.stop_id;
		x_DOStopLocationId		:= get_dropoff_info_rec.stop_location_id;
		x_DOStopLocation		:= l_location;
		x_DOStopCSZ			:= l_csz;
		x_DOStopCountry			:= l_country;
		x_DOStopActualArrivalDate	:= get_dropoff_info_rec.actual_arrival_date;
		x_DOStopActualDepartureDate	:= get_dropoff_info_rec.actual_departure_date;
		x_DOStopPlannedArrivalDate	:= get_dropoff_info_rec.planned_arrival_date;
		x_DOStopPlannedDepartureDate	:= get_dropoff_info_rec.planned_departure_date;
		x_DOStopSequenceNumber		:= get_dropoff_info_rec.stop_sequence_number;
		x_DOStopStatusCode		:= get_dropoff_info_rec.status_code;
		x_DOStopTripId			:= get_dropoff_info_rec.trip_id;
		x_DOStopPhysLocationId          := get_dropoff_info_rec.physical_location_id;
	--}
	END LOOP;
	-- END OF DROPOFF STOP INFORMATION
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 3 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	--
        IF get_dropoff_info_cur%ISOPEN THEN
          CLOSE get_dropoff_info_cur;
	END IF;
	--
	--
	-- PRICE INFORMATION
	x_Price		:= NULL;
	x_Currency	:= NULL;
	--
	--
	FOR get_price_info_rec IN get_price_info_cur(p_dLeg_id)
	LOOP
	--{
		x_price			:= get_price_info_rec.total_amount;
		x_currency		:= get_price_info_rec.currency_code;
	--}
	END LOOP;
	-- END OF PRICE INFORMATION
	--
	--
        IF get_price_info_cur%ISOPEN THEN
          CLOSE get_price_info_cur;
	END IF;
	--
	--
	-- Trip Segment Origin information
	--
	x_OriginStopId		:=NULL;
	x_OriginStopStatusCode	:=NULL;
	x_OriginStopSequenceNumber	:=NULL;
	x_OriginStopLocationId	:=NULL;
	x_OriginLocation	:=NULL;
	x_OriginCSZ		:=NULL;
	x_OriginDepartureDate	:=NULL;
	x_OriginArrivalDate	:=NULL;
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 4 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	--
	FOR get_trip_seg_origin_rec IN get_trip_seg_origin_cur(x_TripSegmentId)
	LOOP
	--{
		l_location	:=null;
		l_csz		:=null;
		l_country	:=null;
		l_return_status :=null;

		fte_mls_util.get_location_info(
			     p_location_id 	=> get_trip_seg_origin_rec.stop_location_id,
			     x_location	   	=> l_location,
			     x_csz	   	=> l_csz,
			     x_country		=> l_country,
			     x_return_status	=> l_return_status);


		x_OriginStopId		:=	get_trip_seg_origin_rec.stop_id;
		x_OriginStopStatusCode	:=	get_trip_seg_origin_rec.status_code;
		x_OriginStopSequenceNumber	:=	get_trip_seg_origin_rec.stop_sequence_number;
		x_OriginStopLocationId	:=	get_trip_seg_origin_rec.stop_location_id;
		x_OriginLocation	:=	l_location;
		x_OriginCSZ		:=	l_csz;
		x_OriginCountry		:=	l_country;
		x_OriginDepartureDate	:=	get_trip_seg_origin_rec.planned_departure_date;
		x_OriginArrivalDate	:=	get_trip_seg_origin_rec.planned_arrival_date;
	--}
	END LOOP;
	-- END OF Trip Segment Origin INFORMATION
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 5 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	--
	-- Trip Segment Dest information
	--
	x_DestStopId		:=NULL;
	x_DestStopStatusCode	:=NULL;
	x_DestStopSequenceNumber	:=NULL;
	x_DestStopLocationId	:=NULL;
	x_DestLocation	:=NULL;
	x_DestCSZ		:=NULL;
	x_DestDepartureDate	:=NULL;
	x_DestArrivalDate	:=NULL;
        x_DestStopPhysLocationId :=NULL;
        x_BolNumber		:=NULL;
	--
	--
	FOR get_trip_seg_dest_rec IN get_trip_seg_dest_cur(x_TripSegmentId)
	LOOP
	--{
                l_location_id    :=null;
		l_location	:=null;
		l_csz		:=null;
		l_country	:=null;
		l_return_status :=null;

		IF (get_trip_seg_dest_rec.physical_location_id IS NULL)
		THEN
			l_location_id := get_trip_seg_dest_rec.stop_location_id;
		ELSE
			l_location_id := get_trip_seg_dest_rec.physical_location_id;
		END IF;


		fte_mls_util.get_location_info(
			     p_location_id 	=> l_location_id,
			     x_location	   	=> l_location,
			     x_csz	   	=> l_csz,
			     x_country		=> l_country,
			     x_return_status	=> l_return_status);


		x_DestStopId		:=	get_trip_seg_dest_rec.stop_id;
		x_DestStopStatusCode	:=	get_trip_seg_dest_rec.status_code;
		x_DestStopSequenceNumber	:=	get_trip_seg_dest_rec.stop_sequence_number;
		x_DestStopLocationId	:=	get_trip_seg_dest_rec.stop_location_id;
		x_DestLocation	:=	l_location;
		x_DestCSZ		:=	l_csz;
		x_DestCountry		:=	l_country;
		x_DestDepartureDate	:=	get_trip_seg_dest_rec.planned_departure_date;
		x_DestArrivalDate	:=	get_trip_seg_dest_rec.planned_arrival_date;
		x_DestStopPhysLocationId  :=      get_trip_seg_dest_rec.physical_location_id;
	--}
	END LOOP;
	-- END OF Trip Segment Dest INFORMATION
	--
	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Exiting out of dleg info 6 ',
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	--
        IF get_trip_seg_dest_cur%ISOPEN THEN
          CLOSE get_trip_seg_dest_cur;
	END IF;
	--
	--
	--GET CARRIER INFO
	--
		IF (x_CarrierId IS NOT NULL)
		THEN
			x_CarrierName := fte_mls_util.get_carrier_name(x_CarrierId);
		END IF;
	--
	-- END OF GET CARRIER NAME
	--

	--
	--GET MODE OF TRANSPORT CODE
	--
		IF (x_ModeOfTransport IS NOT NULL)
		THEN
			FOR get_mode_of_transport_rec IN get_mode_of_transport_cur(x_ModeOfTransport)
			LOOP
			--{
				x_ModeOfTransportMeaning := get_mode_of_transport_rec.mode_of_transport_meaning;
			--}
			END LOOP;
			-- END OF MODE OF TRANSPORT
		END IF;
	--
	-- END OF MODE OF TRANSPORT
	--
	--
	-- GET SERVICE LEVEL
	--
		IF (x_ServiceLevel IS NOT NULL)
		THEN
			FOR get_service_level_rec IN get_service_level_cur(x_ServiceLevel)
			LOOP
			--{
				x_ServiceLevelMeaning := get_service_level_rec.service_type_meaning;
			--}
			END LOOP;
			-- END OF SERVICE LEVEL
		END IF;
	--
	-- END OF SERVICE LEVEL
	--
        IF get_service_level_cur%ISOPEN THEN
          CLOSE get_service_level_cur;
	END IF;
	--
	IF (x_LaneId IS NOT NULL)
        THEN
           FOR get_lane_rec IN get_lane_cur(x_LaneId)
           LOOP
           --{
               x_LaneNumber := get_lane_rec.lane_number;
           --}
           END LOOP;
           -- END OF LANE INFO
        END IF;
        --
        -- END OF LANE_INFO
        --
        IF get_lane_cur%ISOPEN THEN
            CLOSE get_lane_cur;
        END IF;
	--
	--
	IF (p_dLeg_Id IS NOT NULL)
        THEN
           FOR get_bol_number_rec IN get_bol_number_cur(p_dLeg_Id)
           LOOP
           --{
               x_BolNumber := get_bol_number_rec.sequence_number;
           --}
           END LOOP;
           -- END OF BOL NUMBER INFO
        END IF;
        --
        -- END OF BOL NUMBER INFO
        --
        IF get_bol_number_cur%ISOPEN THEN
            CLOSE get_bol_number_cur;
        END IF;
	--
	--
	IF (x_ParentDLegId IS NOT NULL)
        THEN
           FOR get_parent_dlvy_info_rec IN get_parent_dlvy_info_cur(x_ParentDLegId)
           LOOP
           --{
               x_ParentDlvyName := get_parent_dlvy_info_rec.name;
           --}
           END LOOP;
           -- END OF PARENT DLVY INFO
        END IF;
        --
        -- END OF PARENT DLVY INFO
        --
        IF get_parent_dlvy_info_cur%ISOPEN THEN
            CLOSE get_parent_dlvy_info_cur;
        END IF;
	--
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Before existing ' || x_return_status,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;


       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;


    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_DELIVERY_LEGS.build_delivery_leg_info');
	    FND_MESSAGE.SET_NAME('FTE','FTE_BLD_DLEG_UNEXP_ERROR');
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' In Exception ' || x_return_status,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' In Exception ' || SQLERRM,WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
    --}
    END build_delivery_leg_info;
--}
END FTE_DELIVERY_LEGS_PVT;

/
