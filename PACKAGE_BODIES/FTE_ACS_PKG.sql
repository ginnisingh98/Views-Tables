--------------------------------------------------------
--  DDL for Package Body FTE_ACS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ACS_PKG" AS
/* $Header: FTEACSMB.pls 120.6 2005/09/28 05:01:57 alksharm ship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_ACS_PKG                                                  --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains core procedures for carrier selection module         --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
-- Global Package Variables                                                   --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --

g_message_tab         FTE_ACS_PKG.fte_cs_output_message_tab;

-- -------------------------------------------------------------------------- --
-- R12 Enhancement
-- Local data structues
-- -------------------------------------------------------------------------- --
TYPE FTE_CS_ENTITY_RULE_REC  IS RECORD (entity_id_tab	WSH_UTIL_CORE.ID_TAB_TYPE,
				        rule_id_tab	WSH_UTIL_CORE.ID_TAB_TYPE);

TYPE FTE_CS_TEMP_ENTITY_REC IS RECORD(  delivery_id		  NUMBER,
		 		        trip_id			  NUMBER,
				        rule_id			  NUMBER,
				        organization_id		  NUMBER,
					initial_pickup_loc_id	  NUMBER,
					ultimate_dropoff_loc_id   NUMBER,
					initial_pickup_date	  DATE,
					ultimate_dropoff_date	  DATE);

TYPE FTE_CS_TEMP_ENTITY_TAB IS TABLE OF FTE_CS_TEMP_ENTITY_REC INDEX BY BINARY_INTEGER;

-- -------------------------------------------------------------------------- --
--                                                                            --
-- PRIVATE PROCEDURE DEFINITIONS                                              --
-- -----------------------------                                              --
--                                                                            --
-- -------------------------------------------------------------------------- --
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_ACS_PKG';

--
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                LOG_CS_MESSAGES                                       --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN):     p_query_id           IN NUMBER                        --
--                                                                            --
-- PARAMETERS (OUT):    x_return_status      OUT NOCOPY VARCHAR2              --
--                      x_return_message     OUT NOCOPY VARCHAR2              --
--                                                                            --
-- PARAMETERS (IN OUT): p_message_type_tab   IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_flag_tab_type          --
--                      p_message_code_tab   IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_tmp_code_table --
--                      p_message_text_tab   IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_msg_table      --
--                      p_level_tab          IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_tmp_num_table  --
--                      p_group_id_tab       IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_tmp_num_table  --
--                      p_rule_id_tab        IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_tmp_num_table  --
--                      p_result_id_tab      IN OUT NOCOPY                    --
--                                     FTE_ACS_PKG.fte_car_sel_tmp_num_table  --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         This procedure takes in tables of messages and rule/  --
--                      result information and adds them to the global        --
--                      message table which is returned to the calling API    --
--                      at the end of the Carrier Selection Engine execution. --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2002/12/15  I        ABLUNDEL  -------  Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE LOG_CS_MESSAGES(p_message_type_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_flag_tab_type,
                          p_message_code_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_code_table,
                          p_message_text_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_msg_table,
                          p_level_tab          IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_query_id           IN NUMBER,
                          p_group_id_tab       IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_rule_id_tab        IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_result_id_tab      IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_return_message     OUT NOCOPY VARCHAR2) IS


l_error_text VARCHAR2(2000);
l_cs_message VARCHAR2(2000);
l_rec_count  PLS_INTEGER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_CS_MESSAGES';
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
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_QUERY_ID',P_QUERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message := null;


   FOR abcd IN p_message_text_tab.FIRST..p_message_text_tab.LAST LOOP

      l_rec_count := g_message_tab.count + 1;

      g_message_tab(l_rec_count).sequence_number := l_rec_count;
      g_message_tab(l_rec_count).message_type    := p_message_type_tab(abcd);

      IF (p_message_code_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).message_code := p_message_code_tab(abcd);
      ELSE
        g_message_tab(l_rec_count).message_code := null;
      END IF;

      g_message_tab(l_rec_count).message_text    := p_message_text_tab(abcd);


      IF (p_level_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).level        := p_level_tab(abcd);
      ELSE
          g_message_tab(l_rec_count).level       := null;
      END IF;

      IF (p_query_id is not null) THEN
         g_message_tab(l_rec_count).query_id     := p_query_id;
      ELSE
         g_message_tab(l_rec_count).query_id     := null;
      END IF;

      IF (p_group_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).group_id     := p_group_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).group_id     := null;
      END IF;

      IF (p_rule_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).rule_id      := p_rule_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).rule_id      := null;
      END IF;

      IF (p_result_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).result_id    := p_result_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).result_id    := null;
      END IF;

   END LOOP;

   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message := null;
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
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN OTHERS THEN
      l_error_text := SQLERRM;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_ACS_PKG.LOG_CS_MESSAGES IS ' ||L_ERROR_TEXT  );
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_ACS_PKG.LOG_CS_MESSAGES');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := ('FTE_ACS_PKG.LOG_CS_MESSAGES '||l_error_text);
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
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END LOG_CS_MESSAGES;

--***************************************************************************--
--========================================================================
-- PROCEDURE   : LOG_EXCEPTIONS			Private
--
-- PARAMETERS: p_caller			IN		Calling API
--	       p_entity			IN		Entity to be used - Trip / Dlvy
--  	       p_use_gtt		IN		Flag indicates whether GTT should be used.
--	       p_single_rec		IN 		Single Record
--	       x_cs_output_message_tab	OUT		Output Message Tab
--	       x_return_status		OUT		Return Status
--
-- COMMENT   : This API logs exceptions for entites for which routing rules could not be found.
--***************************************************************************--

PROCEDURE LOG_EXCEPTIONS( p_caller			IN		 VARCHAR2,
			  p_entity			IN		 VARCHAR2,
			  p_use_gtt			IN		 BOOLEAN,
			  p_single_rec			IN 		 FTE_ACS_PKG.fte_cs_entity_rec_type DEFAULT NULL,
			  x_cs_output_message_tab	OUT NOCOPY	 FTE_ACS_PKG.fte_cs_output_message_tab,
			  x_return_status		OUT NOCOPY VARCHAR2)
IS

CURSOR	c_get_failed_entities  IS
SELECT  delivery_id,
        trip_id,
        rule_id,
        organization_id,
	    initial_pickup_loc_id,
        ultimate_dropoff_loc_id,
        initial_pickup_date,
        ultimate_dropoff_date
FROM    FTE_SEL_SEARCH_ENTITIES_TMP
WHERE   rule_id IS NULL;


l_failed_entity_tab		FTE_CS_TEMP_ENTITY_TAB;
l_fnd_message_name		VARCHAR2(60);
l_exception_name  		VARCHAR2(60);
l_exception_message		VARCHAR2(5000);

l_exception_id			NUMBER;
itr				NUMBER;
l_return_status			VARCHAR2(1);
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);

l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'log_exceptions';

BEGIN

	IF l_debug_on THEN
	      WSH_DEBUG_SV.PUSH(l_module_name);
	      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
	      WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
          WSH_DEBUG_SV.log(l_module_name,'p_use_gtt',p_use_gtt);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_use_gtt) THEN

		OPEN  c_get_failed_entities;
		FETCH c_get_failed_entities BULK COLLECT INTO l_failed_entity_tab;
		CLOSE c_get_failed_entities;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Number of Failed Entites'||l_failed_entity_tab.COUNT);
		END IF;

		IF (l_failed_entity_tab.COUNT > 0) THEN

			IF (p_entity = 'DLVY') THEN

				IF p_caller = 'WSH_DLMG' THEN
					l_fnd_message_name := 'WSH_SELECT_CARRIER_FAIL';
					l_exception_name := 'WSH_SELECT_CARRIER_FAIL';
				ELSIF p_caller in ('WSH_AUTO_CREATE_DEL','WSH_PICK_RELEASE','WSH_AUTO_CREATE_DEL_TRIP') THEN
					l_fnd_message_name := 'WSH_CARRIER_CREATE_DEL';
			        l_exception_name := 'WSH_CARRIER_CREATE_DEL';
			    END IF;

				-- Start Logging exceptions.
				itr := l_failed_entity_tab.FIRST;
				LOOP
					l_exception_id := NULL;
					FND_MESSAGE.SET_NAME('WSH',l_fnd_message_name);
					FND_MESSAGE.SET_TOKEN('DELIVERY_ID' ,l_failed_entity_tab(itr).delivery_id);
					l_exception_message := FND_MESSAGE.Get;

					wsh_xc_util.log_exception(p_api_version           => 1.0,
						                x_return_status            => l_return_status,
                                        x_msg_count                => l_msg_count,
                                        x_msg_data                 => l_msg_data,
                                        x_exception_id             => l_exception_id,
                                        p_exception_location_id    => l_failed_entity_tab(itr).initial_pickup_loc_id,
                                        p_logged_at_location_id    => l_failed_entity_tab(itr).initial_pickup_loc_id,
                                        p_logging_entity           => 'SHIPPER',
                                        p_logging_entity_id        => FND_GLOBAL.USER_ID,
                                        p_exception_name           => l_exception_name ,
                                        p_message                  => substrb(l_exception_message,1,2000),
                                        p_delivery_id              => l_failed_entity_tab(itr).delivery_id);

					IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
				        raise FND_API.G_EXC_UNEXPECTED_ERROR;
				    END IF;

				 EXIT WHEN itr = l_failed_entity_tab.LAST;
				 itr := l_failed_entity_tab.NEXT(itr);
				 END LOOP;


			ELSIF (p_entity = 'TRIP') THEN

				l_fnd_message_name := 'WSH_ROUTE_TRIP_FAIL';
				l_exception_name   := 'WSH_ROUTE_TRIP_FAIL';
				itr := l_failed_entity_tab.FIRST;

				LOOP
					l_exception_id	   :=  NULL;
					FND_MESSAGE.SET_NAME('WSH',l_fnd_message_name);
					FND_MESSAGE.SET_TOKEN('TRIP_ID' ,l_failed_entity_tab(itr).trip_id);
					l_exception_message := FND_MESSAGE.Get;

					wsh_xc_util.log_exception(p_api_version           => 1.0,
						               x_return_status            => l_return_status,
							       x_msg_count                => l_msg_count,
						               x_msg_data                 => l_msg_data,
							       x_exception_id             => l_exception_id,
							       p_exception_location_id    => l_failed_entity_tab(itr).initial_pickup_loc_id,
						               p_logged_at_location_id    => l_failed_entity_tab(itr).initial_pickup_loc_id,
							       p_logging_entity           => 'SHIPPER',
							       p_logging_entity_id        => FND_GLOBAL.USER_ID,
							       p_exception_name           => l_exception_name ,
						               p_message                  => substrb(l_exception_message,1,2000),
						               p_trip_id                  => l_failed_entity_tab(itr).trip_id);

					 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
				              raise FND_API.G_EXC_UNEXPECTED_ERROR;
				         END IF;

				EXIT WHEN itr = l_failed_entity_tab.LAST;
				itr := l_failed_entity_tab.NEXT(itr);
				END LOOP;
			END IF;
		END IF;
	ELSE

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_single_rec.rule_id ',p_single_rec.rule_id);
        END IF;

		-- Only if the rule id is NULL, we need to log exception.
		IF (p_single_rec.rule_id IS NULL) THEN
			-- Result could not be found
			IF (p_entity = 'DLVY') THEN

				IF p_caller = 'WSH_DLMG' THEN
					FND_MESSAGE.SET_NAME('WSH', 'WSH_SELECT_CARRIER_FAIL');
					l_exception_name := 'WSH_SELECT_CARRIER_FAIL';
				ELSIF p_caller in ('WSH_AUTO_CREATE_DEL','WSH_PICK_RELEASE','WSH_AUTO_CREATE_DEL_TRIP') THEN
				    FND_MESSAGE.SET_NAME('WSH', 'WSH_CARRIER_CREATE_DEL');
			        l_exception_name := 'WSH_CARRIER_CREATE_DEL';
			    END IF;

				FND_MESSAGE.SET_TOKEN('DELIVERY_ID' ,p_single_rec.delivery_id);
			    l_exception_message := FND_MESSAGE.Get;
                l_exception_id := NULL;

				wsh_xc_util.log_exception(
			               p_api_version           => 1.0,
			               x_return_status         => l_return_status,
				           x_msg_count             => l_msg_count,
			               x_msg_data              => l_msg_data,
				           x_exception_id          => l_exception_id,
				           p_exception_location_id => p_single_rec.initial_pickup_loc_id,
			               p_logged_at_location_id => p_single_rec.initial_pickup_loc_id,
			               p_logging_entity        => 'SHIPPER',
			               p_logging_entity_id     => FND_GLOBAL.USER_ID,
			               p_exception_name        => l_exception_name ,
			               p_message               => substrb(l_exception_message,1,2000),
			               p_delivery_id           => p_single_rec.delivery_id);


			ELSIF (p_entity = 'TRIP') THEN
				--
				-- For Trip we need to log the exception
				--
				FND_MESSAGE.SET_NAME('WSH','WSH_ROUTE_TRIP_FAIL');
				FND_MESSAGE.SET_TOKEN('TRIP_NAME',p_single_rec.trip_name);
				-- Seed this exception
				l_exception_name := 'WSH_ROUTE_TRIP_FAIL';
				l_exception_message := FND_MESSAGE.GET;
				l_exception_id	:= NULL;

				wsh_xc_util.log_exception(
				       p_api_version           => 1.0,
			               x_return_status         => l_return_status,
				       x_msg_count             => l_msg_count,
			               x_msg_data              => l_msg_data,
				       x_exception_id          => l_exception_id,
				       p_exception_location_id => p_single_rec.initial_pickup_loc_id,
			               p_logged_at_location_id => p_single_rec.initial_pickup_loc_id,
			               p_logging_entity        => 'SHIPPER',
			               p_logging_entity_id     => FND_GLOBAL.USER_ID,
			               p_exception_name        => l_exception_name ,
			               p_message               => substrb(l_exception_message,1,2000),
			               p_trip_id               => p_single_rec.trip_id);

			END IF;

		END IF; --IF (p_single_rec.rule_id IS NULL) THEN
	END IF;

	IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Logged the Exceptions');
	       WSH_DEBUG_SV.POP (l_module_name);
        END IF;

EXCEPTION
WHEN OTHERS THEN

      IF c_get_failed_entities%ISOPEN THEN
 	 CLOSE c_get_failed_entities;
      END IF;

      WSH_UTIL_CORE.default_handler('FTE_ACS_PKG.log_exceptions');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END LOG_EXCEPTIONS;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_format_results			Private
--
-- PARAMETERS: p_caller			IN		Calling API
--  	       p_use_gtt		IN		Flag indicates whether GTT should be used.
--	       p_single_rec		IN 		Single Record
--	       x_cs_output_message_tab	OUT		Output Message Tab
--	       x_return_status		OUT		Return Status
--
-- COMMENT   : The API returns the results assoociated with a particular rule.
--	       In case of multi records GTT is used. For single record p_single_rec is used.
--***************************************************************************--
PROCEDURE GET_FORMAT_RESULTS( p_caller		IN	    VARCHAR2,
			      p_use_gtt		IN	    BOOLEAN,
			      p_single_rec	IN	    FTE_ACS_PKG.FTE_CS_ENTITY_REC_TYPE,
			      x_cs_output_tab   OUT NOCOPY  FTE_ACS_PKG.FTE_CS_RESULT_TAB_TYPE,
			      x_return_status	OUT NOCOPY  VARCHAR2)
IS

CURSOR c_get_rules_for_entity IS
SELECT delivery_id,
       trip_id,
       rule_id,
       organization_id,
       initial_pickup_loc_id,
       ultimate_dropoff_loc_id,
       initial_pickup_date,
       ultimate_dropoff_date
FROM   FTE_SEL_SEARCH_ENTITIES_TMP
WHERE  rule_id IS NOT NULL;

CURSOR	c_get_transit_time_for_rule(p_rule_id IN NUMBER) IS
SELECT	attribute_value_from_number,
	attribute_value_to_number
FROM	FTE_SEL_RULE_RESTRICTIONS
WHERE   rule_id	= p_rule_id
AND	attribute_name = 'TRANSIT_TIME';

CURSOR c_get_rule_name(p_rule_id IN NUMBER) IS
SELECT name
FROM   FTE_SEL_RULES
WHERE  rule_id = p_rule_id;

l_entity_tab		  fte_cs_temp_entity_tab;
l_result_tab		  fte_acs_cache_pkg.fte_cs_result_attr_tab;
itr			  NUMBER;
l_itr			  NUMBER;
l_cnt			  NUMBER;
l_return_status		  VARCHAR2(1);
l_return_message	  VARCHAR2(2000);

l_rule_name		  VARCHAR2(30);
l_prev_leg_destination_id NUMBER;

l_min_transit_time	  NUMBER;
l_max_transit_time	  NUMBER;

l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_FORMAT_RESULTS';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
		wsh_debug_sv.push (l_module_name);
	END IF;

	IF (p_use_gtt) THEN

		--Depending on the entity we need to fetch the records.
		OPEN  c_get_rules_for_entity;
		FETCH c_get_rules_for_entity BULK COLLECT INTO l_entity_tab;
		CLOSE c_get_rules_for_entity;

	ELSE
		l_entity_tab(1).delivery_id		  := p_single_rec.delivery_id;
		l_entity_tab(1).trip_id			  := p_single_rec.trip_id;
		l_entity_tab(1).rule_id			  := p_single_rec.rule_id;
		l_entity_tab(1).organization_id		  := p_single_rec.organization_id;
		l_entity_tab(1).initial_pickup_loc_id     := p_single_rec.initial_pickup_loc_id;
		l_entity_tab(1).ultimate_dropoff_loc_id   := p_single_rec.ultimate_dropoff_loc_id;
		l_entity_tab(1).initial_pickup_date	  := p_single_rec.initial_pickup_date;
		l_entity_tab(1).ultimate_dropoff_date     := p_single_rec.ultimate_dropoff_date;

	END IF;

	--
	-- At this stage we have the association to a common tab.
	-- l_entity_tab has the records present in it.
	--
	itr := l_entity_tab.FIRST;

	IF (itr IS NOT NULL) THEN
	LOOP

		OPEN  c_get_rule_name(l_entity_tab(itr).rule_id);
		FETCH c_get_rule_name INTO l_rule_name;
		CLOSE c_get_rule_name;

		IF (p_caller = 'ORDER_MGMT') THEN
			OPEN  c_get_transit_time_for_rule(l_entity_tab(itr).rule_id);
			FETCH c_get_transit_time_for_rule INTO l_min_transit_time,l_max_transit_time;
			IF   (c_get_transit_time_for_rule%NOTFOUND) THEN
				l_min_transit_time := NULL;
				l_max_transit_time := NULL;
			END IF;
			CLOSE c_get_transit_time_for_rule;
		END IF;

		--
		--	get_result_for_rule will return results in sorted fashion.
		--	Multileg  result -> A  B  C
		--	Ranked results will be in order 1,2,3
		--      (This procedure wont return any other thing)
		--      Reason for doing this : Only this information can be cached.
		--      Other information will not be cached.
		--

		FTE_ACS_CACHE_PKG.get_results_for_rule(p_rule_id	=> l_entity_tab(itr).rule_id,
						       x_result_tab     => l_result_tab,
						       x_return_status  => l_return_status);

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
		END IF;

		IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		--
		-- Generate the result tab using it.
		--
		l_itr := l_result_tab.FIRST;

		--
		-- Copy the result in the output format.
		--
		IF (l_itr IS NOT NULL) THEN
		LOOP
			-- Initally count will be zero.
			l_cnt :=  x_cs_output_tab.COUNT;
			x_cs_output_tab(l_cnt).rule_id			:= l_entity_tab(itr).rule_id;
			x_cs_output_tab(l_cnt).rule_name		:= l_rule_name;
			x_cs_output_tab(l_cnt).delivery_id		:= l_entity_tab(itr).delivery_id;
                        -- AG add organization_id to output
			x_cs_output_tab(l_cnt).organization_id		:= l_entity_tab(itr).organization_id;
			x_cs_output_tab(l_cnt).trip_id			:= l_entity_tab(itr).trip_id;
			--
			-- Procedure get_result_for_rule returns the following
			-- It returns us the ship methods also. Need to check if there are any issues.
			--
			x_cs_output_tab(l_cnt).result_type		:= l_result_tab(l_itr).result_type;
			x_cs_output_tab(l_cnt).rank			:= l_result_tab(l_itr).rank;
			x_cs_output_tab(l_cnt).leg_destination		:= l_result_tab(l_itr).leg_destination;
			x_cs_output_tab(l_cnt).leg_sequence		:= l_result_tab(l_itr).leg_sequence;
--			x_cs_output_tab(l_cnt).itinerary_id		:= l_result_tab(l_itr).itinerary_id;
			x_cs_output_tab(l_cnt).carrier_id		:= l_result_tab(l_itr).carrier_id;
			x_cs_output_tab(l_cnt).mode_of_transport	:= l_result_tab(l_itr).mode_of_transport;
			x_cs_output_tab(l_cnt).service_level		:= l_result_tab(l_itr).service_level;

			--
			-- Other Get_Result_for_rule will not return the ship method.
			-- Get_Result_for_rule will have caching.
			--

			FTE_ACS_RULE_UTIL_PKG.GET_SHIP_METHOD_CODE( p_carrier_id         => l_result_tab(l_itr).carrier_id,
								    p_service_level      => l_result_tab(l_itr).service_level,
							            p_mode_of_transport  => l_result_tab(l_itr).mode_of_transport,
								    p_org_id             => l_entity_tab(itr).organization_id,
								    x_ship_method_code   => x_cs_output_tab(l_cnt).ship_method_code ,
				                                    x_return_status      => l_return_status,
				                                    x_return_message     => l_return_message);

			 IF l_debug_on THEN
			          WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
			 END IF;

			 IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			 END IF;

			 x_cs_output_tab(l_cnt).freight_terms_code	:= l_result_tab(l_itr).freight_terms_code;
			 x_cs_output_tab(l_cnt).consignee_carrier_ac_no	:= l_result_tab(l_itr).consignee_carrier_ac_no;
--			 x_cs_output_tab(l_cnt).track_only_flag		:= l_result_tab(l_itr).track_only_flag;
			 x_cs_output_tab(l_cnt).result_level		:= l_result_tab(l_itr).result_level;

			 --If Caller is Order Management, then pass the transit time
			 IF (p_caller = 'ORDER_MGMT') THEN
				x_cs_output_tab(l_cnt).min_transit_time := l_min_transit_time;
				x_cs_output_tab(l_cnt).max_transit_time	:= l_max_transit_time;
			 END IF;

			--
			-- Modify the dates
			--

			IF (l_result_tab(l_itr).result_type ='RANK') THEN

				--
				--Result Format is : Delivery ID - Rank 1 - Carrier 1 - pick up date - drop off date
				--
				x_cs_output_tab(l_cnt).initial_pickup_location_id   := l_entity_tab(itr).initial_pickup_loc_id;
				x_cs_output_tab(l_cnt).ultimate_dropoff_location_id := l_entity_tab(itr).ultimate_dropoff_loc_id;
				x_cs_output_tab(l_cnt).pickup_date		    := l_entity_tab(itr).initial_pickup_date;
				x_cs_output_tab(l_cnt).dropoff_date		    := l_entity_tab(itr).ultimate_dropoff_date;

			ELSIF (l_result_tab(l_itr).result_type = 'MULTILEG') THEN

				--
				-- ask whether 	multileg trips should give error here or at some other point.
				-- result Format is : Delivery ID - Pickup A - Dropoff B - pickup date - NULL
				-- 		      Delivery ID - Pickup B - Dropoff C - NULL	 - drop off date
				-- Finish general coding first - Later think of exceptional cases.

				--IF (l_result_tab(l_itr).leg_sequence = 1) THEN
                                IF l_itr = l_result_tab.FIRST THEN
				   x_cs_output_tab(l_cnt).pickup_date		     := l_entity_tab(itr).initial_pickup_date;
				   x_cs_output_tab(l_cnt).initial_pickup_location_id := l_entity_tab(itr).initial_pickup_loc_id;
				ELSE
				   x_cs_output_tab(l_cnt).initial_pickup_location_id := l_prev_leg_destination_id;
				END IF;

				x_cs_output_tab(l_cnt).ultimate_dropoff_location_id :=  l_result_tab(l_itr).leg_destination;
				l_prev_leg_destination_id			    :=  l_result_tab(l_itr).leg_destination;

				IF (l_itr = l_result_tab.LAST) THEN
					-- Last stop we need to populate the ulitmate drop off location also.
					x_cs_output_tab(l_cnt).dropoff_date := l_entity_tab(itr).ultimate_dropoff_date;
			        	x_cs_output_tab(l_cnt).ultimate_dropoff_location_id := l_entity_tab(itr).ultimate_dropoff_loc_id;
				END IF;
			 END IF;

			 EXIT WHEN l_itr = l_result_tab.LAST;
			 l_itr := l_result_tab.NEXT(l_itr);

		END LOOP;
		END IF;

		EXIT WHEN itr = l_entity_tab.LAST;
		itr :=  l_entity_tab.NEXT(itr);
	END LOOP;
	END IF;

	IF l_debug_on THEN

		itr := x_cs_output_tab.FIRST;
		IF (itr IS NOT NULL) THEN
		LOOP
			WSH_DEBUG_SV.logmsg(l_module_name,'****NEW RECORD ******');
			WSH_DEBUG_SV.log(l_module_name,'Rule_id   ',x_cs_output_tab(itr).rule_id);
			WSH_DEBUG_SV.log(l_module_name,'Rule_name ',x_cs_output_tab(itr).rule_name);
			WSH_DEBUG_SV.log(l_module_name,'Delivery_id ',x_cs_output_tab(itr).delivery_id);
			WSH_DEBUG_SV.log(l_module_name,'Initial_pickup_location_id ',x_cs_output_tab(itr).initial_pickup_location_id);
			WSH_DEBUG_SV.log(l_module_name,'Ultimate_dropoff_location_id	',x_cs_output_tab(itr).ultimate_dropoff_location_id);
			WSH_DEBUG_SV.log(l_module_name,'Trip_id  ',x_cs_output_tab(itr).trip_id);
			WSH_DEBUG_SV.log(l_module_name,'Result_type ',x_cs_output_tab(itr).result_type);
			WSH_DEBUG_SV.log(l_module_name,'Rank ',x_cs_output_tab(itr).rank);
			WSH_DEBUG_SV.log(l_module_name,'Leg_destination ',x_cs_output_tab(itr).leg_destination);
			WSH_DEBUG_SV.log(l_module_name,'Leg_sequence ',x_cs_output_tab(itr).leg_sequence);
			WSH_DEBUG_SV.log(l_module_name,'Carrier_id ',x_cs_output_tab(itr).carrier_id);
			WSH_DEBUG_SV.log(l_module_name,'Mode_of_transport ',x_cs_output_tab(itr).mode_of_transport);
			WSH_DEBUG_SV.log(l_module_name,'Service_level ',x_cs_output_tab(itr).service_level);
			WSH_DEBUG_SV.log(l_module_name,'Ship_method_code ',x_cs_output_tab(itr).ship_method_code);
			WSH_DEBUG_SV.log(l_module_name,'Freight_terms_code ',x_cs_output_tab(itr).freight_terms_code);
			WSH_DEBUG_SV.log(l_module_name,'Consignee_carrier_ac_no ',x_cs_output_tab(itr).consignee_carrier_ac_no);
			WSH_DEBUG_SV.log(l_module_name,'Result_level ',x_cs_output_tab(itr).result_level);
			WSH_DEBUG_SV.log(l_module_name,'Pickup_date ',x_cs_output_tab(itr).pickup_date);
			WSH_DEBUG_SV.log(l_module_name,'Dropoff_date ',x_cs_output_tab(itr).dropoff_date);
			WSH_DEBUG_SV.log(l_module_name,'Min_transit_time ',x_cs_output_tab(itr).min_transit_time);
			WSH_DEBUG_SV.log(l_module_name,'Max_transit_time ',x_cs_output_tab(itr).max_transit_time);
			WSH_DEBUG_SV.log(l_module_name,'Append_flag ',x_cs_output_tab(itr).append_flag);
			--WSH_DEBUG_SV.log(l_module_name,'Routing_rule_id ',x_cs_output_tab(itr).routing_rule_id);

			EXIT WHEN itr = x_cs_output_tab.LAST;
			itr := x_cs_output_tab.NEXT(itr);
		END LOOP;
		END IF;
		wsh_debug_sv.pop(l_module_name);
	END IF;
EXCEPTION
WHEN OTHERS THEN
	IF (c_get_rules_for_entity%ISOPEN) THEN
		CLOSE c_get_rules_for_entity;
	END IF;

	IF (c_get_transit_time_for_rule%ISOPEN) THEN
		CLOSE c_get_transit_time_for_rule;
	END IF;

	IF (c_get_rule_name%ISOPEN) THEN
		CLOSE c_get_rule_name;
	END IF;

	WSH_UTIL_CORE.default_handler('FTE_ACS_PKG.get_routing_rules');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
       END IF;
END GET_FORMAT_RESULTS;


--***************************************************************************--
--========================================================================
-- PROCEDURE   : get_routing_results		PUBLIC
--
-- PARAMETERS: p_start_search_level_flag	IN	Default Start Search level flag
--	       p_format_cs_tab			IN	Input table of record
--  	       p_entity				IN	Entity for which routing rules are being found out
--	       p_messaging_yn			IN	Flag indicating whether messaging has to be done or not
--	       p_caller				IN	Caller of routing rules engine
--	       x_cs_output_tab			OUT	Result Table
--	       x_cs_output_message_tab		OUT	Output message table
--	       x_return_message			OUT	Return message
--	       x_return_status			OUT	Return Status
--
-- COMMENT   : Returns the routing results associated with a given rule
--***************************************************************************--
PROCEDURE GET_ROUTING_RESULTS( --p_start_search_level_flag IN		VARCHAR2,
			       p_format_cs_tab		 IN OUT NOCOPY	FTE_ACS_PKG.FTE_CS_ENTITY_TAB_TYPE,
			       p_entity			 IN		VARCHAR2,
			       p_messaging_yn		 IN		VARCHAR2,
			       p_caller			 IN		VARCHAR2,
			       x_cs_output_tab		 OUT	NOCOPY	FTE_ACS_PKG.FTE_CS_RESULT_TAB_TYPE,
		               x_cs_output_message_tab	 OUT	NOCOPY	FTE_ACS_PKG.FTE_CS_OUTPUT_MESSAGE_TAB,
			       x_return_message		 OUT	NOCOPY	VARCHAR2,
			       x_return_status		 OUT	NOCOPY	VARCHAR2)
IS

      l_entities_left	  NUMBER;
      l_single_entity	  BOOLEAN;
      l_use_gtt		  BOOLEAN;

      l_entity_rec	  FTE_ACS_PKG.fte_cs_entity_rec_type;
      l_search_level_tab  WSH_UTIL_CORE.column_tab_type;

      l_output_tab	  FTE_ACS_CACHE_PKG.fte_cs_entity_attr_tab;
      l_entity_info	  FTE_ACS_CACHE_PKG.fte_cs_entity_attr_rec;

      l_entity_rule_rec	  fte_cs_entity_rule_rec;
      l_entity_cnt	  NUMBER;
      l_return_status	  VARCHAR2(1);
      l_first		  NUMBER;
      l_last		  NUMBER;
      itr		  NUMBER;

      l_rule_id		  NUMBER;
      l_cnt		  NUMBER;

      l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ROUTING_RESULTS';
BEGIN

	IF l_debug_on THEN
		wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
	--  Format the data.
	--	a) Determine Freight Term code levels
	--	b) Get the Transit Time.
	--

	FTE_ACS_RULE_UTIL_PKG.FORMAT_ENTITY_INFO( p_input_cs_tab  => p_format_cs_tab,
		  			          p_entity	  => p_entity,
						  x_return_status => l_return_status);

	IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
        END IF;

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
	END IF;

	l_entities_left	:= p_format_cs_tab.COUNT;

      IF (p_format_cs_tab.COUNT= 1) THEN

		l_entity_rec      := p_format_cs_tab(p_format_cs_tab.FIRST);
		l_single_entity   := TRUE;
		l_use_gtt	  := FALSE;

            l_cnt := 1;
            IF (p_entity='TRIP') THEN
                        -- 'I' means Organization id of the first stop
               -- AG trip's origin org
               IF l_entity_rec.triporigin_internalorg_id IS NOT NULL THEN
                        l_search_level_tab(l_cnt) := 'I';
                        l_cnt := l_cnt+1;
               END IF;
            END IF;
            IF l_entity_rec.customer_site_id IS NOT NULL THEN
                    l_search_level_tab(l_cnt)   := 'S'; -- Customer Site
                    l_cnt := l_cnt+1;
            END IF;
            IF l_entity_rec.customer_id IS NOT NULL THEN
                l_search_level_tab(l_cnt)       := 'C'; -- Customer
                    l_cnt := l_cnt+1;
            END IF;
            IF l_entity_rec.organization_id IS NOT NULL THEN
                l_search_level_tab(l_cnt)       := 'O'; -- Organization
                    l_cnt := l_cnt+1;
            END IF;
            l_search_level_tab(l_cnt)       := 'E'; -- Enterprise
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'***NEW RECORD ********');
                WSH_DEBUG_SV.log(l_module_name,'delivery_id ',l_entity_rec.delivery_id);
                WSH_DEBUG_SV.log(l_module_name,'trip_id ',l_entity_rec.trip_id);
                WSH_DEBUG_SV.log(l_module_name,'delivery_name ',l_entity_rec.delivery_name);
                WSH_DEBUG_SV.log(l_module_name,'trip_name ',l_entity_rec.trip_name);
                WSH_DEBUG_SV.log(l_module_name,'organization_id ',l_entity_rec.organization_id);
                WSH_DEBUG_SV.log(l_module_name,'triporigin_internalorg_id ',l_entity_rec.triporigin_internalorg_id);
                WSH_DEBUG_SV.log(l_module_name,'customer_id ',l_entity_rec.customer_id);
                WSH_DEBUG_SV.log(l_module_name,'customer_site_id ',l_entity_rec.customer_site_id);
                WSH_DEBUG_SV.log(l_module_name,'gross_weight ', l_entity_rec.gross_weight);
                WSH_DEBUG_SV.log(l_module_name,'weight_uom_code ',l_entity_rec.weight_uom_code);
                WSH_DEBUG_SV.log(l_module_name,'volume ', l_entity_rec.volume);
                WSH_DEBUG_SV.log(l_module_name,'volume_uom_code ', l_entity_rec.volume_uom_code);
                WSH_DEBUG_SV.log(l_module_name,'initial_pickup_loc_id ', l_entity_rec.initial_pickup_loc_id);
                WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_loc_id ', l_entity_rec.ultimate_dropoff_loc_id);
                WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date ', nvl(l_entity_rec.initial_pickup_date,SYSDATE));
                WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_date ', l_entity_rec.ultimate_dropoff_date);
                WSH_DEBUG_SV.log(l_module_name,'freight_terms_code ',l_entity_rec.freight_terms_code);
                WSH_DEBUG_SV.log(l_module_name,'fob_code ',l_entity_rec.fob_code);
                WSH_DEBUG_SV.log(l_module_name,'start_search_level ',l_entity_rec.start_search_level);
                WSH_DEBUG_SV.log(l_module_name,'transit_time ',l_entity_rec.transit_time);
           END IF;
     ELSE

        /*
        l_cnt := 1;
        IF (p_entity='TRIP') THEN
            -- 'I' means Organization id of the first stop
            l_search_level_tab(l_cnt) := 'I';
            l_cnt := l_cnt+1;
        END IF;
        l_search_level_tab(l_cnt)	:= 'S'; -- Customer Site
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'C'; -- Customer
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'O'; -- Organization
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'E'; -- Enterprise
        */

		FTE_ACS_RULE_UTIL_PKG.INSERT_INTO_GTT( p_input_data	=> p_format_cs_tab,
						       x_return_status  => l_return_status);

		IF l_debug_on THEN
	             WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
		END IF;

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
		END IF;

		l_single_entity	  := FALSE;
		l_use_gtt	  := TRUE;

        -- AG moved here from above
        l_cnt := 1;
        IF (p_entity='TRIP') THEN
            -- 'I' means Organization id of the first stop
            l_search_level_tab(l_cnt) := 'I';
            l_cnt := l_cnt+1;
        END IF;
        l_search_level_tab(l_cnt)	:= 'S'; -- Customer Site
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'C'; -- Customer
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'O'; -- Organization
        l_cnt := l_cnt+1;
        l_search_level_tab(l_cnt)	:= 'E'; -- Enterprise

      END IF;

	--
	-- Data has been inserted into the GTT or it is there in the record.
	-- For every level - Query the database or use the record.
	--

	--
	-- For a trip sequence followed is-Organization of first stop,Customer Site,Customer,Organization of last stop,Enterprise
	-- For a delivery sequence is - Customer Site, Customer , Organization and Enterprise
	--

	/*l_cnt := 1;
	IF (p_entity='TRIP') THEN
		-- 'I' means Organization id of the first stop
		l_search_level_tab(l_cnt) := 'I';
	        l_cnt := l_cnt+1;
	END IF;
	l_search_level_tab(l_cnt)	:= 'S'; -- Customer Site
	l_cnt := l_cnt+1;
	l_search_level_tab(l_cnt)	:= 'C'; -- Customer
	l_cnt := l_cnt+1;
	l_search_level_tab(l_cnt)	:= 'O'; -- Organization
	l_cnt := l_cnt+1;
	l_search_level_tab(l_cnt)	:= 'E'; -- Enterprise */

	--
	--  Loop condition is when all entities have been exhausted or all levels have been.
	--  a) Whenever a result is found - decrement it.
	--	l_entities_left-1, Exit when l_entities_left is 0
	--  b) All levels exhausted.

	FOR  i IN l_search_level_tab.FIRST ..l_search_level_tab.LAST
	LOOP

	    --
	    -- If we have 1 record then p_single_rec will be populated
	    -- Query Global Temporary table only if p_use_gtt IS TRUE ;
	    --

	    FTE_ACS_RULE_UTIL_PKG.GET_CANDIDATE_RECORDS( p_search_level	  => l_search_level_tab(i),
                                    p_query_gtt	  => l_use_gtt,
                                    p_single_rec	  => l_entity_rec,
                                    x_output_tab	  => l_output_tab,
                                    x_return_status  => l_return_status);

	    IF l_debug_on THEN
	          WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	    END IF;

	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;
	    END IF;

	    itr := l_output_tab.FIRST;

	    IF (itr IS NOT NULL) THEN

		l_entity_rule_rec.entity_id_tab.DELETE;
		l_entity_rule_rec.rule_id_tab.DELETE;

		l_entity_cnt := 0;
		-- l_first is index used while doing bulk update
		l_first := l_entity_cnt;

		LOOP

			l_entity_info	:= l_output_tab(itr);

			FTE_ACS_CACHE_PKG.GET_MATCHING_RULE( p_info		=> l_entity_info,
							     x_rule_id		    => l_rule_id,
							     x_return_status	=> l_return_status);

			IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_rule_id ',l_rule_id);
            END IF;

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF (l_rule_id <> FTE_ACS_CACHE_PKG.g_rule_not_found) THEN

				l_entities_left := l_entities_left - 1;

				IF NOT(l_single_entity) THEN
				  	 --Input will be either delivery or trip.
					 IF  (p_entity IN ('DLVY','PSEUDO_DLVY')) THEN
						l_entity_rule_rec.entity_id_tab(l_entity_cnt) := l_output_tab(itr).delivery_id;
					 ELSIF (p_entity = 'TRIP') THEN
						l_entity_rule_rec.entity_id_tab(l_entity_cnt) := l_output_tab(itr).trip_id;
					 END IF;
					 l_entity_rule_rec.rule_id_tab(l_entity_cnt)    := l_rule_id;
					 l_entity_cnt := l_entity_cnt + 1;
				ELSE
					l_entity_rec.rule_id := l_rule_id;
				END IF;

			END IF;

			EXIT WHEN itr = l_output_tab.LAST;
			itr:= l_output_tab.NEXT(itr);

		 END LOOP;
          -- We have incremented l_entity_cnt extra by 1
		 l_last := l_entity_cnt-1;
	    END IF; --   IF (itr IS NOT NULL) THEN --}

	    --
	    --  Update the GTT with the rule id
	    --
	    IF NOT(l_single_entity) THEN

		IF (p_entity = 'TRIP') THEN
			 FORALL j in l_first .. l_last
				UPDATE FTE_SEL_SEARCH_ENTITIES_TMP
				SET   rule_id  = l_entity_rule_rec.rule_id_tab(j)
				WHERE trip_id  = l_entity_rule_rec.entity_id_tab(j);

		ELSIF (p_entity IN ('DLVY','PSEUDO_DLVY')) THEN
			FORALL j in l_first .. l_last
				UPDATE FTE_SEL_SEARCH_ENTITIES_TMP
				SET    rule_id     = l_entity_rule_rec.rule_id_tab(j)
				WHERE  delivery_id = l_entity_rule_rec.entity_id_tab(j);
		END IF;
	    END IF;

	    IF (l_entities_left = 0 ) THEN
		EXIT ;
	    END IF;

	END LOOP;--FOR  i IN l_search_level_tab.FIRST ..l_search_level_tab.LAST
	--
	-- Search over : Get Formatted Results for the entites.
	--		  If data not there then log exceptions.
	--

	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'l_entities_left ',l_entities_left);
	END IF;

	--
	-- In case of single records need to call get_format_resutls only when entity is
	-- associated with a result.
	-- In case of multirecords call is made to check if resutls are present there for
	-- any of the records.

	IF ((l_single_entity AND (l_entities_left=0))
	     OR NOT l_single_entity)
        THEN
		GET_FORMAT_RESULTS( p_caller	    => p_caller,
				    p_use_gtt	    => l_use_gtt,
				    p_single_rec    => l_entity_rec,
				    x_cs_output_tab => x_cs_output_tab,
			            x_return_status => l_return_status);

		IF l_debug_on THEN
		  WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
		END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	END IF;

	IF (l_entities_left <> 0 ) THEN

	  --
	  -- Exceptions are not logged when the action is Select Carrier from Shipping
	  -- Transactions form or Apply Routing Rules from FTE. Only a warning message is shown.
	  --
          IF (p_caller NOT IN('WSH_FSTRX','FTE_MLS_WRAPPER','ORDER_MGMT')) THEN

		LOG_EXCEPTIONS( p_caller     => p_caller,
		 	        p_entity     => p_entity,
 			        p_use_gtt    => l_use_gtt,
 			        p_single_rec => l_entity_rec,
			        x_cs_output_message_tab => x_cs_output_message_tab,
				x_return_status => l_return_status);

		IF l_debug_on THEN
		          WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
		END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	   ELSE
		--
		-- Put Message on the stack and return
		-- We can have multirecords in this case
		--

		FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_NO_CARRIER_SELECTED');
                x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
                WSH_UTIL_CORE.add_message(x_return_status);

	   END IF;

	END IF;

	IF l_debug_on THEN
		wsh_debug_sv.pop (l_module_name);
	END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--
	WSH_UTIL_CORE.default_handler('FTE_ACS_PKG.get_routing_rules');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
       END IF;

WHEN OTHERS THEN
	--
	WSH_UTIL_CORE.default_handler('FTE_ACS_PKG.get_routing_rules');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
       END IF;

END GET_ROUTING_RESULTS;

END FTE_ACS_PKG;

/
