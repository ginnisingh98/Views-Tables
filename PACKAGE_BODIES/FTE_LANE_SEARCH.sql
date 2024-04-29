--------------------------------------------------------
--  DDL for Package Body FTE_LANE_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LANE_SEARCH" AS
/* $Header: FTELNSEB.pls 120.2 2006/05/02 00:51:21 jnpinto ship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_LANE_SEARCH';
  --

  g_message     VARCHAR2(12000);

  -- ----------------------------------------------------------------
  -- Name:              Set_Up_Regions
  -- Type:              Procedure
  --
  -- Description:       This procedure calls
  --                    WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches
  --                    with location_id and/or regions information
  --                    and obtains all the regions and parent regions
  --                    that match.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Set_Up_Regions(p_loc_id             IN      NUMBER,
                           p_country            IN      VARCHAR2,
                           p_state              IN      VARCHAR2,
                           p_city               IN      VARCHAR2,
                           p_zip                IN OUT  NOCOPY  VARCHAR2,
                           x_regions            OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                           x_parent_regions     OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab) IS

  l_region_and_type FTE_LANE_SEARCH_QUERY_GEN.fte_regions_types;
  l_country             VARCHAR2(60) := null;
  l_country_code        VARCHAR2(10) := null;
  l_state               VARCHAR2(60) := null;
  l_state_code          VARCHAR2(10) := null;
  l_city                VARCHAR2(60) := null;
  l_city_code           VARCHAR2(10) := null;

  l_status              NUMBER;
  l_regions_temp        WSH_REGIONS_SEARCH_PKG.region_table;
  l_region              WSH_REGIONS_SEARCH_PKG.region_rec;

  l_regions             FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_regions      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;

  CURSOR get_postal_code(p_loc_id NUMBER) IS
  SELECT postal_code  FROM wsh_locations
  WHERE wsh_location_id = p_loc_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_UP_REGIONS';
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
            WSH_DEBUG_SV.log(l_module_name,'P_LOC_ID',P_LOC_ID);
            WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
            WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
            WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
            WSH_DEBUG_SV.log(l_module_name,'P_ZIP',P_ZIP);
        END IF;
        --

        IF (p_loc_id is null AND p_country is null AND
            p_state is null AND p_city is null AND
            p_zip is null) THEN

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'no region information passed in',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           l_region_and_type.region_id := NULL;
           l_region_and_type.region_type := NULL;
           l_regions(1) := l_region_and_type;

           x_regions := l_regions;

           RETURN;

        END IF;

        IF (LENGTH(p_country) <= 3) THEN
            l_country_code := p_country;
        ELSE
            l_country := p_country;
        END IF;

        IF (LENGTH(p_state) <= 3) THEN
            l_state_code := p_state;
        ELSE
            l_state := p_state;
        END IF;

        IF (LENGTH(p_city) <= 3) THEN
            l_city_code := p_city;
        ELSE
            l_city := p_city;
        END IF;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_ALL_REGION_MATCHES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        BEGIN
          WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches(p_country              => l_country,
                                                        p_country_region       => null,
                                                        p_state                => l_state,
                                                        p_city                 => l_city,
                                                        p_postal_code_from     => p_zip,
                                                        p_postal_code_to       => p_zip,
                                                        p_country_code         => l_country_code,
                                                        p_country_region_code  => null,
                                                        p_state_code           => l_state_code,
                                                        p_city_code            => l_city_code,
                                                        p_lang_code            => userenv('LANG'),
                                                        p_location_id          => p_loc_id,
                                                        p_zone_flag            => 'N',
                                                        p_more_matches         => TRUE,
                                                        x_status               => l_status,
                                                        x_regions              => l_regions_temp);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'No Region Found for ' || l_country || ', ' || l_state || ', ' || l_city);
            END IF;
        END;

        -- using city field as a state if region obtained is a country
        -- this is due to ambiguous free text input, so cannot
        -- distinguish whether single input is city or state
        IF (l_regions_temp.COUNT <= 1 AND
            (l_city is not null OR l_city_code is not null) AND
            (l_state is null AND l_state_code is null)) THEN
            l_state := l_city;
            l_state_code := l_city_code;
            l_city := null;
            l_city_code := null;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_ALL_REGION_MATCHES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            BEGIN
              WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches(p_country             => l_country,
                                                            p_country_region      => null,
                                                            p_state               => l_state,
                                                            p_city                => l_city,
                                                            p_postal_code_from    => p_zip,
                                                            p_postal_code_to      => p_zip,
                                                            p_country_code        => l_country_code,
                                                            p_country_region_code => null,
                                                            p_state_code          => l_state_code,
                                                            p_city_code           => l_city_code,
                                                            p_lang_code           => userenv('LANG'),
                                                            p_location_id         => p_loc_id,
                                                            p_zone_flag           => 'N',
                                                            p_more_matches        => TRUE,
                                                            x_status              => l_status,
                                                            x_regions             => l_regions_temp);

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'No Region Found for ' || l_country || ', ' || l_state || ', ' || l_city);
               END IF;
           END;
        END IF;

        -- set up array of base regions and parent regions
        -- Parent regions contains all the regions found.  The base regions
        -- are all the regions that have the same input type as the passed in
        -- criteria region type.
        IF (l_regions_temp.COUNT > 0) THEN
            FOR i IN l_regions_temp.FIRST..l_regions_temp.LAST LOOP
                l_region := l_regions_temp(i);
                l_region_and_type.region_id := l_region.region_id;
                l_region_and_type.region_type := l_region.region_type;

                l_region_and_type.STATE := l_region.STATE;
                l_region_and_type.STATE_CODE := l_region.STATE_CODE;
                l_region_and_type.CITY := l_region.CITY;
                l_region_and_type.CITY_CODE := l_region.CITY_CODE;

                IF (l_region.is_input_type ='Y') THEN
                   l_regions(l_regions.count +1) := l_region_and_type;
                END IF;

                l_parent_regions(l_parent_regions.count +1) := l_region_and_type;
            END LOOP;
        END IF;

        -- if location id was passed in, obtain zip from wsh_locations API
        IF (p_loc_id is not null AND p_zip is null) THEN
            OPEN get_postal_code(p_loc_id);
            FETCH get_postal_code INTO p_zip;
            CLOSE get_postal_code;
        END IF;

        x_regions := l_regions;
        x_parent_regions := l_parent_regions;

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
  END Set_Up_Regions;


  -- ----------------------------------------------------------------------------
  -- Name:           Is_Vehicle_Available
  -- Type:           Function
  --
  -- Description:    This procedure takes in a lane id, and checks to see
  --                 if the carrier has vehicles available for the lane on the
  --                 specified date.
  -- -----------------------------------------------------------------------------
  FUNCTION Is_Vehicle_Available(p_vehicle_id        IN     NUMBER, --fte_vehicle_type_id
                                p_carrier_id        IN     NUMBER,
                                p_origin_id         IN     NUMBER,
                                p_dest_id           IN     NUMBER,
                                p_mode              IN     VARCHAR2,
                                p_date              IN     DATE,
                                x_return_message    OUT    NOCOPY VARCHAR2) RETURN BOOLEAN IS

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Is_Vehicle_Available';

  l_id  NUMBER;
  l_available   BOOLEAN;

  cursor c_vehicle_available IS
    select 1
    from  wsh_carrier_vehicle_types
    where carrier_id = p_carrier_id
    and   vehicle_type_id = p_vehicle_id
    and   assigned_flag = 'Y'
    and not exists
           (select 1 from fte_lane_vehicles
            where quantity = 0
            and   origin_id = p_origin_id
            and   destination_id = p_dest_id
            and   carrier_id = p_carrier_id
            and   nvl(effective_start_date, nvl(p_date, sysdate)) <= nvl(p_date, sysdate)
            and   nvl(effective_end_date, nvl(p_date, sysdate)) >= nvl(p_date, sysdate)
            UNION
            select 1 from fte_lane_group_components c, fte_lane_vehicles l
            where  l.quantity = 0
            and    c.lane_group_id = l.lane_group_id
            and    c.origin_id = p_origin_id
            and    c.destination_id = p_dest_id
            and    l.carrier_id = p_carrier_id
            and    nvl(effective_start_date, nvl(p_date, sysdate)) <= nvl(p_date, sysdate)
            and    nvl(effective_end_date, nvl(p_date, sysdate)) >= nvl(p_date, sysdate));


  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_vehicle_id',p_vehicle_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_origin_id', p_origin_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_destination_id', p_dest_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_carrier_id', p_carrier_id);
    END IF;

    open c_vehicle_available;
    fetch c_vehicle_available into l_id;
    l_available := c_vehicle_available%FOUND;
    close c_vehicle_available;

    --If we don't find a row for the carrier, origin and destination
    --with zero quantity in fte_lane_vehicles, then the vehicle is available
    --only if it is assigned to the carrier.  This means that the vehicle HAS
    --to be assigned to the carrier in order for the lane to be used.
    IF (NOT l_available) THEN
      x_return_message := 'The vehicle is either not assigned to the carrier ' ||
                          'or has an availability of 0 on the specified date.';
    END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

     return l_available;

  END Is_Vehicle_Available;





  -- ----------------------------------------------------------------
  -- Name:              Bind_Vars
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in a bind variable array
  --                    and binds the variables according to the
  --                    bind variable index and bind variable type
  --                    using dbms_sql, given a cursor_id.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Bind_Vars(p_cursor_id       IN      NUMBER,
                      p_bindvars        IN      FTE_LANE_SEARCH_QUERY_GEN.bindvars) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BIND_VARS';
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
            WSH_DEBUG_SV.log(l_module_name,'P_CURSOR_ID',P_CURSOR_ID);
        END IF;
        --
        IF (p_bindvars.COUNT > 0) THEN

            FOR l_counter IN p_bindvars.FIRST..p_bindvars.LAST LOOP

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'bind var ' || p_bindvars(l_counter).bindvarindex || ' = ' || p_bindvars(l_counter).bindvar,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

                IF (p_bindvars(l_counter).bindtype = 'NUMBER') THEN
                    dbms_sql.BIND_VARIABLE(p_cursor_id, ':' || p_bindvars(l_counter).bindvarindex, to_number(p_bindvars(l_counter).bindvar));
                    --g_message := g_message || 'bind ' || p_bindvars(l_counter).bindvarindex || ' = ' || p_bindvars(l_counter).bindvar;
                ELSIF (p_bindvars(l_counter).bindtype = 'DATE') THEN
                    dbms_sql.BIND_VARIABLE(p_cursor_id, ':' || p_bindvars(l_counter).bindvarindex, to_date(p_bindvars(l_counter).bindvar, 'mm-dd-yyyy hh24:mi'));
                    --g_message := g_message || 'bind ' || p_bindvars(l_counter).bindvarindex || ' = ' || 'to_date(''' || p_bindvars(l_counter).bindvar||''', ''mm-dd-yyyy hh24:mi'')';
                ELSE
                    dbms_sql.BIND_VARIABLE(p_cursor_id, ':' || p_bindvars(l_counter).bindvarindex, p_bindvars(l_counter).bindvar);
                    --g_message := g_message || 'bind ' || p_bindvars(l_counter).bindvarindex || ' = ''' || p_bindvars(l_counter).bindvar || '''';
                END IF;
            END LOOP;

        END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Bind_Vars;


  -- ----------------------------------------------------------------
  -- Name:              Get_Transit_Time (Pack J)
  -- Type:              Procedure
  --
  -- Description:       This procedure checks whether for the ship method
  --                    passed in, transit time already exists in the
  --                    cache.  If not, obtains the transit time from
  --                    ATP if the transit time passed in is null,
  --                    otherwise, converts the transit time passed
  --                    in into DAYS
  --
  -- Input:             p_ship_from_loc_id
  --                    p_ship_to_site_id
  --                    p_carrier_id
  --                    p_service_code
  --                    p_mode_code
  --                    x_transit_time
  --                    x_transit_time_uom
  -- ----------------------------------------------------------------
  PROCEDURE Get_Transit_Time(p_ship_from_loc_id IN      NUMBER,
                             p_ship_to_site_id  IN      NUMBER,
                             p_carrier_id       IN      NUMBER,
                             p_service_code     IN      VARCHAR2,
                             p_mode_code        IN      VARCHAR2,
                             p_from             IN      VARCHAR2,
                             x_transit_time     OUT NOCOPY NUMBER,
                             x_return_status    OUT NOCOPY VARCHAR2) IS

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRANSIT_TIME';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOC_ID',P_SHIP_FROM_LOC_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_SITE_ID',P_SHIP_TO_SITE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SERVICE_CODE',P_SERVICE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_MODE_CODE',P_MODE_CODE);
    END IF;
    --

    x_return_status := WSH_UTIL_CORE.g_ret_sts_success;
   --Logic for calculating Transit time is in  WSH_MAP_LOCATION_REGION_PKG Bug 4653381
    WSH_MAP_LOCATION_REGION_PKG.Get_Transit_Time(
              p_ship_from_loc_id => p_ship_from_loc_id ,
              p_ship_to_site_id=>p_ship_to_site_id,
              p_ship_method_code=>null,
              p_carrier_id=>p_carrier_id,
              p_service_code=>p_service_code,
              p_mode_code=>p_mode_code,
              p_from=>p_from,
              x_transit_time=>x_transit_time,
              x_return_status=>x_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Transit Time: ', x_transit_time);
      WSH_DEBUG_SV.log(l_module_name,'x_return_status', x_return_status);
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

 END Get_Transit_Time;

-- ----------------------------------------------------------------
-- Name:		Search_Lanes
-- Type:		Procedure
--
-- Description:	OverLoaded method for the search_lanes API. This
-- will be called if we have more than one set of search criteria
-- Duplicate fetches in the search would be removed
-- p_search_type	'L' - Lanes
--                'S' - Scheduldes
-- Limitations:
--     and p_source_type = 'R'
-- -----------------------------------------------------------------
PROCEDURE Search_Lanes( p_search_criteria      IN      fte_search_criteria_tab,
                        p_num_results          IN      NUMBER,
                        p_search_type          IN      VARCHAR2,
                        x_lane_results         OUT NOCOPY      fte_lane_tab,
                        x_schedule_results     OUT NOCOPY      fte_schedule_tab,
                        x_return_message       OUT NOCOPY      VARCHAR2,
                        x_return_status        OUT NOCOPY      VARCHAR2) IS


type t_result_ids is table of NUMBER index by binary_integer;

l_lane_results fte_lane_tab;
l_lane_id NUMBER;
l_schedule_id NUMBER;
i NUMBER;
j NUMBER;
l_result_ids     t_result_ids;

x_count NUMBER := 1;
l_schedule_results fte_schedule_tab;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEARCH_LANES(Multi)';
--

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  x_return_message := WSH_UTIL_CORE.g_ret_sts_success;
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
    WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.COUNT',p_search_criteria.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'P_NUM_RESULTS',P_NUM_RESULTS);
  END IF;
  --
x_lane_results:=  fte_lane_tab();
x_schedule_results := fte_schedule_tab();
i := p_search_criteria.FIRST;
WHILE i is not null LOOP
   l_lane_results :=  fte_lane_tab();
   l_schedule_results := fte_schedule_tab();
   Search_Lanes( p_search_criteria => p_search_criteria(i),
                 p_search_type     => p_search_type,
                 p_source_type     => 'R',
                 p_num_results     => (p_num_results-x_count),
                 x_lane_results    => l_lane_results,
                 x_schedule_results => l_schedule_results,
                 x_return_message  =>  x_return_message,
                 x_return_status   =>  x_return_status);
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      x_return_message := FND_MESSAGE.GET;
      return;
    END IF;
    IF p_search_type = 'L' THEN
      IF(l_lane_results.COUNT > 0 ) THEN
        j:=l_lane_results.FIRST;
        WHILE j is not NULL LOOP
          l_lane_id := l_lane_results(j).LANE_ID;
          IF (NOT (l_result_ids.EXISTS(l_lane_id))) THEN
            x_lane_results.EXTEND;
            x_lane_results(x_count) := l_lane_results(j);
            x_count := x_count + 1;
            l_result_ids(l_lane_id) := l_lane_id;
          END IF;
          j := l_lane_results.NEXT(j);
        END LOOP;
      END IF;
    ELSIF p_search_type = 'S' THEN
      IF(l_schedule_results.COUNT > 0 ) THEN
        j:=l_schedule_results.FIRST;
        WHILE j is not NULL LOOP
          l_schedule_id := l_schedule_results(j).SCHEDULE_ID;
          IF (NOT (l_result_ids.EXISTS(l_schedule_id))) THEN
            x_schedule_results.EXTEND;
            x_schedule_results(x_count) := l_schedule_results(j);
            x_count := x_count + 1;
            l_result_ids(l_schedule_id) := l_schedule_id;
          END IF;
          j := l_schedule_results.NEXT(j);
        END LOOP;
      END IF;
    END IF;
   IF (x_count >= p_num_results) THEN
    EXIT;
   END IF;
    i := p_search_criteria.NEXT(i);
 END LOOP;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_lane_results.COUNT',x_count);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN OTHERS THEN
      x_return_message := g_message || 'Unexpected Error in Search_Lanes Package: ' || sqlerrm;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END Search_Lanes;

  -- ----------------------------------------------------------------
  -- Name:              Search_Lanes
  -- Type:              Procedure
  --
  -- Description:       This procedure calls FTE_LANE_SEARCH_QUERY_GEN
  --                    procedures to create the dynamic SQL.
  --                    Binds the variables, executes the query, and
  --                    prepares the results in SQL records and SQL
  --                    types for returning to the calling procedure.
  --                    Constraints checking is done for lanes if
  --                    a delivery_id or delivery_leg_id is present.
  --
  --                    Pack J:
  --                    Transit time info is obtained from ATP if
  --                    p_source_type = 'R' (for OM-freigh rating
  --                    integration)
  --
  -- Input:             p_search_type   'L' = lanes; 'S' = schedules
  --                    p_source_type   'L' = lanes; 'R' = rating
  --                    p_source_type   'T' = Lane Group , Commitment
  --                    p_num_results   maximum number of results
  --                                    desired (OA should be 200)
  -- -----------------------------------------------------------------
  PROCEDURE Search_Lanes(p_search_criteria      IN      fte_search_criteria_rec,
                         p_search_type          IN      VARCHAR2, -- 'L' for lanes, 'S' for schedules
                         p_source_type          IN      VARCHAR2,
                         p_num_results          IN      NUMBER,
                         x_lane_results         OUT NOCOPY      fte_lane_tab,
                         x_schedule_results     OUT NOCOPY      fte_schedule_tab,
                         x_return_message       OUT NOCOPY      VARCHAR2,
                         x_return_status        OUT NOCOPY      VARCHAR2) IS

  l_search_criteria FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_criteria_rec;
  l_origin_zip      VARCHAR2(30) := null;
  l_destination_zip VARCHAR2(30) := null;

  l_origins         FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_destinations    FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_origins  FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_dests    FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;


  l_query1          VARCHAR2(32000);
  l_query2          VARCHAR2(32000);

  l_bindvars1       FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars2       FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars3       FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars4       FTE_LANE_SEARCH_QUERY_GEN.bindvars;

  l_status          VARCHAR2(1);
  l_msg             VARCHAR2(2000);

  l_cursor_id           NUMBER;
  l_counter             NUMBER;
  l_rows_affected       NUMBER;
  l_rows_fetched        NUMBER := 0;
  l_offset              NUMBER := 0;
  l_vehicles_discarded  VARCHAR2(12000);

  -- variables of column type for binding sql stmt for lanes
  v_lane_id             dbms_sql.NUMBER_TABLE;
  v_lane_number         dbms_sql.VARCHAR2_TABLE;
  v_party_name          dbms_sql.VARCHAR2_TABLE;
  v_origin_id           dbms_sql.NUMBER_TABLE;
  v_destination_id      dbms_sql.NUMBER_TABLE;
  v_mode                dbms_sql.VARCHAR2_TABLE;
  v_service             dbms_sql.VARCHAR2_TABLE;
  v_commodity           dbms_sql.VARCHAR2_TABLE;
  --v_equipment           dbms_sql.VARCHAR2_TABLE;
  v_schedules_flag      dbms_sql.VARCHAR2_TABLE;
  v_distance            dbms_sql.NUMBER_TABLE;
  v_port_of_loading     dbms_sql.VARCHAR2_TABLE;
  v_port_of_discharge   dbms_sql.VARCHAR2_TABLE;
  v_transit_time        dbms_sql.NUMBER_TABLE;
  v_rate_chart_name     dbms_sql.VARCHAR2_TABLE;
  v_basis               dbms_sql.VARCHAR2_TABLE;
  v_owner_id            dbms_sql.NUMBER_TABLE;
  v_carrier_id          dbms_sql.NUMBER_TABLE;
  v_mode_code           dbms_sql.VARCHAR2_TABLE;
  v_transit_time_uom    dbms_sql.VARCHAR2_TABLE;
  v_special_handling    dbms_sql.VARCHAR2_TABLE;
  v_addl_instr          dbms_sql.VARCHAR2_TABLE;
  v_commodity_flag      dbms_sql.VARCHAR2_TABLE;
  --v_equipment_flag      dbms_sql.VARCHAR2_TABLE;
  v_service_flag        dbms_sql.VARCHAR2_TABLE;
  v_comm_catg_id        dbms_sql.NUMBER_TABLE;
  --v_equipment_code      dbms_sql.VARCHAR2_TABLE;
  v_service_code        dbms_sql.VARCHAR2_TABLE;
  v_distance_uom        dbms_sql.VARCHAR2_TABLE;
  v_rate_chart_id       dbms_sql.NUMBER_TABLE;
  v_rate_chart_view_flag        dbms_sql.VARCHAR2_TABLE;
  v_effective_date      dbms_sql.DATE_TABLE;
  v_expiry_date         dbms_sql.DATE_TABLE;
  v_origin_region_type  dbms_sql.NUMBER_TABLE;
  v_dest_region_type    dbms_sql.NUMBER_TABLE;
  v_comm_class_code     dbms_sql.VARCHAR2_TABLE;
  v_schedules_flag_code dbms_sql.VARCHAR2_TABLE;
  v_lane_service_id     dbms_sql.NUMBER_TABLE;
  v_tariff_name         dbms_sql.VARCHAR2_TABLE;
  v_lane_type		dbms_sql.VARCHAR2_TABLE;

  -- variables for keeping track of transit time info
  l_transit_time        NUMBER;
  l_transit_time_uom    VARCHAR2(30);

  -- variables of column type for binding sql stmt for schedules
  s_schedule_id         dbms_sql.NUMBER_TABLE;
  s_lane_id             dbms_sql.NUMBER_TABLE;
  s_lane_number         dbms_sql.VARCHAR2_TABLE;
  s_dep_date            dbms_sql.DATE_TABLE;
  s_arr_date            dbms_sql.DATE_TABLE;
  s_transit_time        dbms_sql.NUMBER_TABLE;
  s_frequency           dbms_sql.VARCHAR2_TABLE;
  s_effective_date      dbms_sql.DATE_TABLE;
  s_port_of_loading     dbms_sql.VARCHAR2_TABLE;
  s_port_of_discharge   dbms_sql.VARCHAR2_TABLE;
  s_expiry_date         dbms_sql.DATE_TABLE;
  s_arr_date_indicator  dbms_sql.NUMBER_TABLE;
  s_frequency_arrival   dbms_sql.VARCHAR2_TABLE;
  s_origin_id           dbms_sql.NUMBER_TABLE;
  s_destination_id      dbms_sql.NUMBER_TABLE;
  s_mode                dbms_sql.VARCHAR2_TABLE;
  s_carrier_id          dbms_sql.NUMBER_TABLE;
  s_carrier_name        dbms_sql.VARCHAR2_TABLE;
  s_dep_time            dbms_sql.VARCHAR2_TABLE;
  s_arr_time            dbms_sql.VARCHAR2_TABLE;
  s_frequency_type      dbms_sql.VARCHAR2_TABLE;
  s_transit_time_uom    dbms_sql.VARCHAR2_TABLE;
  s_vessel_type         dbms_sql.VARCHAR2_TABLE;
  s_vessel_name         dbms_sql.VARCHAR2_TABLE;
  s_voyage_number       dbms_sql.VARCHAR2_TABLE;
  s_arr_time_w_ind      dbms_sql.VARCHAR2_TABLE;
  s_mode_code           dbms_sql.VARCHAR2_TABLE;
  s_service_code        dbms_sql.VARCHAR2_TABLE;
  s_service             dbms_sql.VARCHAR2_TABLE;
  s_frequency_type_code dbms_sql.VARCHAR2_TABLE;
  s_active_flag         dbms_sql.VARCHAR2_TABLE;

  l_num_rows            NUMBER := 0;
  l_lanes_rec           fte_lane_rec;
  l_lanes_tab           fte_lane_tab;
  l_schedules_rec       fte_schedule_rec;
  l_schedules_tab       fte_schedule_tab;

  -- similar to hash table to keep track of unique lane ids
  type t_result_ids is table of NUMBER index by binary_integer;
  l_result_lane_ids     t_result_ids;
  l_result_service_ids  t_result_ids;

  -- constraints variables
  l_shipping_control    VARCHAR2(30);
  l_dleg_info_rec       WSH_FTE_CONSTRAINT_FRAMEWORK.dleg_ccinfo_rec_type;
  l_lane_info_rec       WSH_FTE_CONSTRAINT_FRAMEWORK.lane_ccinfo_rec_type;
  l_lane_info_tab       WSH_FTE_CONSTRAINT_FRAMEWORK.lane_ccinfo_tab_type;
  l_success_trips       WSH_UTIL_CORE.id_tab_type;
  l_success_lanes       WSH_UTIL_CORE.id_tab_type;
  l_validate_result     VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(400);
  l_good_lane           VARCHAR2(1);
  l_dummy_exception     WSH_UTIL_CORE.Column_Tab_Type;
  l_dummy_trips         WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_tab_type;

  l_cc_lane_counter     NUMBER;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEARCH_LANES';
  --

  -- [11/11] Add query type for Lane Group and Commitment -> 'T'
  l_source_type         VARCHAR2(3);


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
      WSH_DEBUG_SV.log(l_module_name,'P_SEARCH_TYPE',P_SEARCH_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_TYPE',P_SOURCE_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_NUM_RESULTS',P_NUM_RESULTS);
    END IF;
    --

    -- get origin and parents set up
    l_origin_zip := p_search_criteria.origin_zip;
    Set_Up_Regions(p_loc_id         => p_search_criteria.origin_loc_id,
                   p_country        => p_search_criteria.origin_country,
                   p_state          => p_search_criteria.origin_state,
                   p_city           => p_search_criteria.origin_city,
                   p_zip            => l_origin_zip,
                   x_regions        => l_origins,
                   x_parent_regions => l_parent_origins);


    -- get destination and parents set up
    l_destination_zip := p_search_criteria.destination_zip;
    Set_Up_Regions(p_loc_id         => p_search_criteria.destination_loc_id,
                   p_country        => p_search_criteria.destination_country,
                   p_state          => p_search_criteria.destination_state,
                   p_city           => p_search_criteria.destination_city,
                   p_zip            => l_destination_zip,
                   x_regions        => l_destinations,
                   x_parent_regions => l_parent_dests);


     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Number of base origins', l_origins.count);
       WSH_DEBUG_SV.log(l_module_name,'Number of base destinations',l_destinations.count);
       WSH_DEBUG_SV.log(l_module_name,'Number of parent origins', l_parent_origins.count);
       WSH_DEBUG_SV.log(l_module_name,'Number of parent dests',l_parent_dests.count);
     END IF;

     --g_message := g_message || 'Number of base origins' || l_origins.count;
     --g_message := g_message || 'Number of base destinations' || l_destinations.count;
     --g_message := g_message || 'Number of parent origins' || l_parent_origins.count;
     --g_message := g_message || 'Number of parent dests' || l_parent_dests.count;

     --If no regions are found, return.
     IF (l_parent_dests IS NULL OR l_parent_dests.COUNT <= 0 OR
         l_parent_origins IS NULL OR l_parent_origins.COUNT <= 0) THEN

          x_lane_results := fte_lane_tab();
          x_schedule_results := fte_schedule_tab();

          x_return_message := x_return_message || 'No regions found for search criteria';

          IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
          END IF;
       --
        RETURN;
     END IF;

     IF (l_origins.COUNT > 1) THEN
         x_lane_results := fte_lane_tab();
         x_schedule_results := fte_schedule_tab();
         x_return_message := x_return_message || 'Ambiguous origin input -- ' || Fnd_Global.NewLine;

         FOR i IN l_origins.FIRST .. l_origins.LAST LOOP
           x_return_message := x_return_message || l_origins(i).CITY||','||
                               nvl(l_origins(i).STATE, l_origins(i).STATE_CODE) ||'; ' || Fnd_Global.NewLine;
         END LOOP;
         x_return_status := 'A';
         RETURN;
     END IF;

     IF (l_destinations.COUNT > 1) THEN
         x_lane_results := fte_lane_tab();
         x_schedule_results := fte_schedule_tab();
         x_return_message := x_return_message || 'Ambiguous destination input -- ' || Fnd_Global.NewLine;

         FOR i IN l_destinations.FIRST .. l_destinations.LAST LOOP
           x_return_message := x_return_message || l_destinations(i).CITY||','||
                               nvl(l_destinations(i).STATE, l_destinations(i).STATE_CODE) || '; '||Fnd_Global.NewLine;
         END LOOP;
         x_return_status := 'A';
         RETURN;

     END IF;

    -- set up rest of parameters
    l_search_criteria.relax_flag := p_search_criteria.relax_flag;
    l_search_criteria.origin_zip_request := l_origin_zip;
    l_search_criteria.dest_zip_request := l_destination_zip;
    l_search_criteria.mode_of_transport := p_search_criteria.mode_of_transport;
    l_search_criteria.lane_number := p_search_criteria.lane_number;
    l_search_criteria.carrier_id := p_search_criteria.carrier_id;
    l_search_criteria.carrier_name := p_search_criteria.carrier_name;
    l_search_criteria.commodity_catg_id := p_search_criteria.commodity_catg_id;
    l_search_criteria.commodity := p_search_criteria.commodity;
    l_search_criteria.service_code := p_search_criteria.service_code;
    l_search_criteria.service := p_search_criteria.service;
    --l_search_criteria.equipment_code := p_search_criteria.equipment_code;
    --l_search_criteria.equipment := p_search_criteria.equipment;
    l_search_criteria.schedule_only_flag := p_search_criteria.schedule_only_flag;
    l_search_criteria.dep_date_from := p_search_criteria.dep_date_from;
    l_search_criteria.dep_date_to := p_search_criteria.dep_date_to;
    l_search_criteria.arr_date_from := p_search_criteria.arr_date_from;
    l_search_criteria.arr_date_to := p_search_criteria.arr_date_to;
    l_search_criteria.lane_ids_list := p_search_criteria.lane_ids_string;
    l_search_criteria.tariff_name := p_search_criteria.tariff_name;

    IF (l_search_criteria.dep_date_from IS NOT NULL) then
      l_search_criteria.dep_date_from := to_date(to_char(l_search_criteria.dep_date_from,'mm-dd-yyyy hh24:mi'),
                                                 'mm-dd-yyyy hh24:mi');
    END IF;

    IF (l_search_criteria.dep_date_to IS NOT NULL) then
      l_search_criteria.dep_date_to := to_date(to_char(l_search_criteria.dep_date_to,'mm-dd-yyyy hh24:mi'),
                                                 'mm-dd-yyyy hh24:mi');
    END IF;

    IF (l_search_criteria.arr_date_from IS NOT NULL) then
      l_search_criteria.arr_date_from := to_date(to_char(l_search_criteria.arr_date_from,'mm-dd-yyyy hh24:mi'),
                                                 'mm-dd-yyyy hh24:mi');
    END IF;

    IF (l_search_criteria.arr_date_to IS NOT NULL) then
      l_search_criteria.arr_date_to := to_date(to_char(l_search_criteria.arr_date_to,'mm-dd-yyyy hh24:mi'),
                                                 'mm-dd-yyyy hh24:mi');
    END IF;

    -- [08/30] Add check for Vehicle_id
    -- [11/21] Get the vehicle_id from the inventory_item_id
    --l_search_criteria.vehicle_id := p_search_criteria.vehicle_id;
    IF (p_search_criteria.vehicle_id IS NOT NULL) THEN
      l_search_criteria.vehicle_id := FTE_VEHICLE_PKG.Get_Vehicle_Type_Id(p_search_criteria.vehicle_id);
    ELSE
      l_search_criteria.vehicle_id := NULL;
    END IF;

    -- glami added for effective date
    IF (p_search_criteria.effective_date IS NOT NULL) then
      l_search_criteria.effective_date := to_date(to_char(p_search_criteria.effective_date,'mm-dd-yyyy hh24:mi'),
                                                 'mm-dd-yyyy hh24:mi');
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.relax_flag', p_search_criteria.relax_flag);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.origin_zip', p_search_criteria.origin_zip);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.destination_zip', p_search_criteria.destination_zip);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.mode_of_transport', p_search_criteria.mode_of_transport);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.lane_number', p_search_criteria.lane_number);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.carrier_id', p_search_criteria.carrier_id);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.carrier_name', p_search_criteria.carrier_name);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.commodity_catg_id', p_search_criteria.commodity_catg_id);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.commodity', p_search_criteria.commodity);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.service_code', p_search_criteria.service_code);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.service', p_search_criteria.service);
       --WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.equipment_code', p_search_criteria.equipment_code);
       --WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.equipment', p_search_criteria.equipment);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.schedule_only_flag', p_search_criteria.schedule_only_flag);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.dep_date_from', p_search_criteria.dep_date_from);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.dep_date_to', p_search_criteria.dep_date_to);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.arr_date_to', p_search_criteria.arr_date_to);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.arr_date_to', p_search_criteria.arr_date_to);
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.lane_ids_string', substr(p_search_criteria.lane_ids_string, 0, 15) || '...');
       WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.vehicle_id', p_search_criteria.vehicle_id);
       WSH_DEBUG_SV.log(l_module_name,'New Vehicle ID ', l_search_criteria.vehicle_id);
    -- glami added for effective date
       WSH_DEBUG_SV.log(l_module_name,'Effective Date ', l_search_criteria.effective_date);
       WSH_DEBUG_SV.log(l_module_name,'Effective Date Type ', l_search_criteria.effective_date_type);
       WSH_DEBUG_SV.log(l_module_name,'Tariff Name ', l_search_criteria.tariff_name);
    END IF;

    -- [11/11] Add query type for Lane Group and Commitment -> 'T'
    l_source_type := p_source_type;

    IF (p_search_type = 'L') THEN
        l_lanes_tab := fte_lane_tab();

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_LANE_SEARCH_QUERY_GEN.CREATE_LANE_QUERY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
        FTE_LANE_SEARCH_QUERY_GEN.Create_Lane_Query(p_search_criteria      => l_search_criteria,
                                                    p_origins              => l_origins,
                                                    p_destinations         => l_destinations,
                                                    p_parent_origins       => l_parent_origins,
                                                    p_parent_destinations  => l_parent_dests,
                                                    p_source_type          => l_source_type,
                                                    x_query1               => l_query1,
                                                    x_query2               => l_query2,
                                                    x_bindvars1            => l_bindvars1,
                                                    x_bindvars2            => l_bindvars2,
                                                    x_bindvars_common      => l_bindvars3,
                                                    x_bindvars_orderby     => l_bindvars4,
                                                    x_return_message       => l_msg,
                                                    x_return_status        => l_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'query:' || l_query1,WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        l_cursor_id := dbms_sql.OPEN_CURSOR;
        dbms_sql.PARSE(l_cursor_id, l_query1, DBMS_SQL.V7);

        Bind_Vars(l_cursor_id, l_bindvars1);
        Bind_Vars(l_cursor_id, l_bindvars3);
        Bind_Vars(l_cursor_id, l_bindvars4);

        -- [11/11] Add query type for Lane Group and Commitment -> 'T'
        if (p_source_type ='T') THEN

          dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, v_party_name, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 2, v_carrier_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 3, v_origin_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 4, v_destination_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 5, v_mode, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 6, v_mode_code, p_num_results, 1);
	  dbms_sql.DEFINE_ARRAY(l_cursor_id, 7, v_origin_region_type, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 8, v_lane_id, p_num_results, 1);

        else

          dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, v_lane_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 2, v_lane_number, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 3, v_party_name, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 4, v_origin_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 5, v_destination_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 6, v_mode, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 7, v_service, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 8, v_commodity, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 9, v_schedules_flag, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 10, v_distance, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 11, v_port_of_loading, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 12, v_port_of_discharge, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 13, v_transit_time, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 14, v_rate_chart_name, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 15, v_basis, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 16, v_owner_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 17, v_carrier_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 18, v_mode_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 19, v_transit_time_uom, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 20, v_special_handling, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 21, v_addl_instr, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 22, v_commodity_flag, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 23, v_service_flag, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 24, v_comm_catg_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 25, v_service_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 26, v_distance_uom, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 27, v_rate_chart_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 28, v_rate_chart_view_flag, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 29, v_effective_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 30, v_expiry_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 31, v_origin_region_type, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 32, v_dest_region_type, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 33, v_comm_class_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 34, v_schedules_flag_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 35, v_lane_service_id, p_num_results, 1);
	  dbms_sql.DEFINE_ARRAY(l_cursor_id, 36, v_tariff_name, p_num_results, 1);
	  dbms_sql.DEFINE_ARRAY(l_cursor_id, 37, v_lane_type, p_num_results, 1);

        end if;

       l_rows_affected := dbms_sql.EXECUTE(l_cursor_id);

        LOOP
            l_rows_fetched := dbms_sql.FETCH_ROWS(l_cursor_id);
            IF (l_rows_fetched = 0) THEN
              EXIT;
            END IF;

            -- [11/11] Add query type for Lane Group and Commitment -> 'T'
            if (p_source_type ='T') THEN

              dbms_sql.COLUMN_VALUE(l_cursor_id, 1, v_party_name);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 2, v_carrier_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 3, v_origin_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 4, v_destination_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 5, v_mode);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 6, v_mode_code);
	      dbms_sql.COLUMN_VALUE(l_cursor_id, 7, v_origin_region_type);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 8, v_lane_id);


            else

              dbms_sql.COLUMN_VALUE(l_cursor_id, 1, v_lane_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 2, v_lane_number);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 3, v_party_name);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 4, v_origin_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 5, v_destination_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 6, v_mode);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 7, v_service);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 8, v_commodity);
	      dbms_sql.COLUMN_VALUE(l_cursor_id, 9, v_schedules_flag);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 10, v_distance);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 11, v_port_of_loading);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 12, v_port_of_discharge);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 13, v_transit_time);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 14, v_rate_chart_name);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 15, v_basis);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 16, v_owner_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 17, v_carrier_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 18, v_mode_code);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 19, v_transit_time_uom);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 20, v_special_handling);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 21, v_addl_instr);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 22, v_commodity_flag);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 23, v_service_flag);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 24, v_comm_catg_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 25, v_service_code);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 26, v_distance_uom);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 27, v_rate_chart_id);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 28, v_rate_chart_view_flag);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 29, v_effective_date);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 30, v_expiry_date);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 31, v_origin_region_type);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 32, v_dest_region_type);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 33, v_comm_class_code);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 34, v_schedules_flag_code);
              dbms_sql.COLUMN_VALUE(l_cursor_id, 35, v_lane_service_id);
	      dbms_sql.COLUMN_VALUE(l_cursor_id, 36, v_tariff_name);
	      dbms_sql.COLUMN_VALUE(l_cursor_id, 37, v_lane_type);
            end if;

            FOR n IN 1..l_rows_fetched LOOP

                -- if this lane is not already there OR
                -- if this lane is already there, but the lane service is not already there
                IF ((NOT l_result_lane_ids.EXISTS(v_lane_id(n + l_offset)))
                     OR (l_result_lane_ids.EXISTS(v_lane_id(n + l_offset)) AND
                         v_lane_service_id(n + l_offset) is not null AND
                         NOT l_result_service_ids.EXISTS(v_lane_service_id(n + l_offset)))) THEN

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Seeking Transit Time');
                    END IF;

                    l_transit_time := null; -- v_transit_time(n + l_offset); -- this is what's on the lane
                    l_transit_time_uom := 'DAY';

                    -- obtain transit time from ATP if transit time on lane is null
                    -- convert transit time on lane to DAYS if necessary

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'p_source_type:'||p_source_type );
                      WSH_DEBUG_SV.logmsg(l_module_name,'p_search_criteria.pickupstop_location_id  :'||p_search_criteria.pickupstop_location_id );
                      WSH_DEBUG_SV.logmsg(l_module_name,' p_search_criteria.ship_to_site_id        :'|| p_search_criteria.ship_to_site_id );
                      WSH_DEBUG_SV.logmsg(l_module_name,' p_search_criteria.dropoffstop_location_id:'|| p_search_criteria.dropoffstop_location_id );
                    END IF;

                    IF (p_source_type = 'R' AND
                        p_search_criteria.pickupstop_location_id is not null AND
                        p_search_criteria.ship_to_site_id is not null) THEN


                        IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Transit_Time for OM:' );
                        END IF;
                        Get_Transit_Time(p_ship_from_loc_id =>      p_search_criteria.pickupstop_location_id,
                                         p_ship_to_site_id  =>      p_search_criteria.ship_to_site_id,
                                         p_carrier_id       =>      v_carrier_id(n + l_offset),
                                         p_service_code     =>      v_service_code(n + l_offset),
                                         p_mode_code        =>      v_mode_code(n + l_offset),
                                         p_from             =>      'OM',
                                         x_transit_time     =>      l_transit_time,
                                         x_return_status    =>      l_status);


                    ELSE IF (p_source_type = 'R' AND p_search_criteria.pickupstop_location_id is not null ) THEN

                        IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Transit_Time for Trips / deliveries' );
                        END IF;
                        Get_Transit_Time(p_ship_from_loc_id =>      p_search_criteria.pickupstop_location_id,
                                         p_ship_to_site_id  =>      p_search_criteria.dropoffstop_location_id,
                                         p_carrier_id       =>      v_carrier_id(n + l_offset),
                                         p_service_code     =>      v_service_code(n + l_offset),
                                         p_mode_code        =>      v_mode_code(n + l_offset),
                                         p_from             =>      null,
                                         x_transit_time     =>      l_transit_time,
                                         x_return_status    =>      l_status);
                        End IF;
                    END IF;

                        IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                            x_return_status := l_status;
                            FND_MESSAGE.SET_NAME('FTE', 'FTE_CANNOT_GET_TRANSIT_TIME');
                            FND_MESSAGE.SET_TOKEN('LANE_NUMBER', v_lane_number(n + l_offset));
                            x_return_message := FND_MESSAGE.GET;
                            return;
                        END IF;
                    --END IF;

                    -- bug 3357370 - on 1/8/2004 by hjpark
                    -- if transit_time is null, set transit_time_uom to null
                    if (l_transit_time is null or l_transit_time = '') then
                      l_transit_time_uom := null;
                    end if;

                    -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                    if (p_source_type ='T') THEN

                      l_lanes_rec := fte_lane_rec(v_lane_id(n + l_offset),
                                                '',
                                                v_origin_id(n + l_offset),
                                                v_destination_id(n + l_offset),
                                                v_carrier_id(n + l_offset),
                                                v_mode_code(n + l_offset),
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                v_party_name(n + l_offset),
                                                v_mode(n + l_offset),
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                v_origin_region_type(n + l_offset),
                                                '',
						'',
						'');

                    else

                      l_lanes_rec := fte_lane_rec(v_lane_id(n + l_offset),
                                                v_lane_number(n + l_offset),
                                                v_origin_id(n + l_offset),
                                                v_destination_id(n + l_offset),
                                                v_carrier_id(n + l_offset),
                                                v_mode_code(n + l_offset),
                                                v_comm_class_code(n + l_offset),
                                                v_comm_catg_id(n + l_offset),
                                                v_service_code(n + l_offset),
                                                v_schedules_flag_code(n + l_offset),
                                                v_rate_chart_id(n + l_offset),
                                                v_basis(n + l_offset),
                                                l_transit_time,
                                                l_transit_time_uom,
                                                v_distance(n + l_offset),
                                                v_distance_uom(n + l_offset),
                                                v_party_name(n + l_offset),
                                                v_mode(n + l_offset),
                                                v_commodity(n + l_offset),
                                                v_service(n + l_offset),
                                                v_schedules_flag(n + l_offset),
                                                v_port_of_loading(n + l_offset),
                                                v_port_of_discharge(n + l_offset),
                                                v_rate_chart_name(n + l_offset),
                                                v_owner_id(n + l_offset),
                                                v_special_handling(n + l_offset),
                                                v_addl_instr(n + l_offset),
                                                v_commodity_flag(n + l_offset),
                                                v_service_flag(n + l_offset),
                                                v_rate_chart_view_flag(n + l_offset),
                                                v_effective_date(n + l_offset),
                                                v_expiry_date(n + l_offset),
                                                v_origin_region_type(n + l_offset),
                                                v_dest_region_type(n + l_offset),
						v_tariff_name(n + l_offset),
						v_lane_type(n + l_offset));

                    end if;

                    -- [08/30] Add check for Vehicle_id
                    -- only if the Lane has TL as Mode of Transport
                    IF (l_search_criteria.vehicle_id is not null AND v_mode_code(n + l_offset) ='TRUCK') THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,
                                          'Check Vehicle Availability for Lane ' || v_lane_number(n + l_offset));

                      IF( Is_Vehicle_Available(p_vehicle_id      => l_search_criteria.vehicle_id,
                                               p_carrier_id      => v_carrier_id(n + l_offset),
                                               p_origin_id       => v_origin_id(n + l_offset),
                                               p_dest_id         => v_destination_id(n + l_offset),
                                               p_mode            => v_mode(n + l_offset),
                                               p_date            => l_search_criteria.dep_date_from,
                                               x_return_message  => x_return_message) ) THEN

                          --g_message := g_message || ';  keep ' || v_lane_id(n + l_offset);
                          l_lanes_tab.EXTEND;
                          l_lanes_tab(l_num_rows + 1)                := l_lanes_rec;
                          l_num_rows                                 := l_num_rows + 1;
                          l_result_lane_ids(v_lane_id(n + l_offset)) := v_lane_id(n + l_offset);

                          -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                          IF (p_source_type <> 'T' and v_lane_service_id(n + l_offset) is not null ) THEN
                             l_result_service_ids(v_lane_service_id(n + l_offset)) := v_lane_service_id(n + l_offset);
                          END IF;
                      ELSE
                        l_vehicles_discarded := l_vehicles_discarded  || v_lane_id(n+l_offset) || ', ';

                        WSH_DEBUG_SV.logmsg(l_module_name, x_return_message);
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Vehicle unavailable for lane ' || v_lane_number(n+l_offset));

                      END IF;
                    ELSE
                      --g_message := g_message || ' Not TL  or vehicle null ' || v_lane_id(n + l_offset);
                      l_lanes_tab.EXTEND;
                      l_lanes_tab(l_num_rows + 1)                := l_lanes_rec;
                      l_num_rows                                 := l_num_rows + 1;
                      l_result_lane_ids(v_lane_id(n + l_offset)) := v_lane_id(n + l_offset);

                      -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                      IF (p_source_type <>'T' and v_lane_service_id(n + l_offset) is not null ) THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Point 1.1',WSH_DEBUG_SV.C_PROC_LEVEL);
                         l_result_service_ids(v_lane_service_id(n + l_offset)) := v_lane_service_id(n + l_offset);
                      END IF;

                    END IF;

                END IF;

            END LOOP;

            l_offset := l_offset + l_rows_fetched;

            EXIT WHEN (l_rows_fetched < p_num_results OR l_lanes_tab.COUNT >= p_num_results);
        END LOOP;

        x_return_message := x_return_message || l_msg;

        -- GLAMI
        -- MAKE CHANGES FOR TENNESSEE TO NEW YORK ISSUE
        -- If there is not a Match we have to set l_search_criteria.relax_flag to 'N' so that will avoid
        -- to relax down
        IF (l_origins.COUNT = 0 or l_destinations.count =0) THEN
          l_search_criteria.relax_flag :='N';
          x_return_message := x_return_message || ' No exact match found for search criteria. ' ||
                              '=> Cannot relax down.';
        END IF;

       -- relax down only if want to relax and not enough results yet
        IF (l_search_criteria.relax_flag = 'Y' AND l_query2 is not null AND
            l_lanes_tab.COUNT < p_num_results AND l_lanes_tab.COUNT < 20) THEN

            --g_message := g_message || 'Relaxing Down ...';

            l_offset := 0; -- reset the offset

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'query2:' || l_query2,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            dbms_sql.PARSE(l_cursor_id, l_query2, DBMS_SQL.V7);

            Bind_Vars(l_cursor_id, l_bindvars2);
            Bind_Vars(l_cursor_id, l_bindvars3);
            WSH_DEBUG_SV.logmsg(l_module_name,'Query^^^^^^^^ :'||l_query2 );
            -- [11/11] Add query type for Lane Group and Commitment -> 'T'
            if (p_source_type ='T') THEN

              dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, v_party_name, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 2, v_carrier_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 3, v_origin_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 4, v_destination_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 5, v_mode, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 6, v_mode_code, p_num_results, 1);
	      dbms_sql.DEFINE_ARRAY(l_cursor_id, 7, v_origin_region_type, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 8, v_lane_id, p_num_results, 1);

            else

              dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, v_lane_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 2, v_lane_number, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 3, v_party_name, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 4, v_origin_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 5, v_destination_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 6, v_mode, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 7, v_service, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 8, v_commodity, p_num_results, 1);
	      dbms_sql.DEFINE_ARRAY(l_cursor_id, 9, v_schedules_flag, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 10, v_distance, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 11, v_port_of_loading, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 12, v_port_of_discharge, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 13, v_transit_time, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 14, v_rate_chart_name, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 15, v_basis, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 16, v_owner_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 17, v_carrier_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 18, v_mode_code, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 19, v_transit_time_uom, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 20, v_special_handling, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 21, v_addl_instr, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 22, v_commodity_flag, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 23, v_service_flag, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 24, v_comm_catg_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 25, v_service_code, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 26, v_distance_uom, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 27, v_rate_chart_id, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 28, v_rate_chart_view_flag, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 29, v_effective_date, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 30, v_expiry_date, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 31, v_origin_region_type, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 32, v_dest_region_type, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 33, v_comm_class_code, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 34, v_schedules_flag_code, p_num_results, 1);
              dbms_sql.DEFINE_ARRAY(l_cursor_id, 35, v_lane_service_id, p_num_results, 1);
	      dbms_sql.DEFINE_ARRAY(l_cursor_id, 36, v_tariff_name, p_num_results, 1);
	      dbms_sql.DEFINE_ARRAY(l_cursor_id, 37, v_lane_type, p_num_results, 1);
            end if;

            l_rows_affected := dbms_sql.EXECUTE(l_cursor_id);
            LOOP
                l_rows_fetched := dbms_sql.FETCH_ROWS(l_cursor_id);
                IF (l_rows_fetched = 0) THEN
                   EXIT;
                END IF;

                -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                if (p_source_type ='T') THEN

                  dbms_sql.COLUMN_VALUE(l_cursor_id, 1, v_party_name);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 2, v_carrier_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 3, v_origin_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 4, v_destination_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 5, v_mode);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 6, v_mode_code);
	 	  dbms_sql.COLUMN_VALUE(l_cursor_id, 7, v_origin_region_type);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 8, v_lane_id);

                else

                  dbms_sql.COLUMN_VALUE(l_cursor_id, 1, v_lane_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 2, v_lane_number);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 3, v_party_name);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 4, v_origin_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 5, v_destination_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 6, v_mode);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 7, v_service);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 8, v_commodity);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 9, v_schedules_flag);
		  dbms_sql.COLUMN_VALUE(l_cursor_id, 10, v_distance);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 11, v_port_of_loading);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 12, v_port_of_discharge);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 13, v_transit_time);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 14, v_rate_chart_name);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 15, v_basis);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 16, v_owner_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 17, v_carrier_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 18, v_mode_code);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 19, v_transit_time_uom);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 20, v_special_handling);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 21, v_addl_instr);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 22, v_commodity_flag);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 23, v_service_flag);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 24, v_comm_catg_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 25, v_service_code);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 26, v_distance_uom);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 27, v_rate_chart_id);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 28, v_rate_chart_view_flag);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 29, v_effective_date);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 30, v_expiry_date);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 31, v_origin_region_type);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 32, v_dest_region_type);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 33, v_comm_class_code);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 34, v_schedules_flag_code);
                  dbms_sql.COLUMN_VALUE(l_cursor_id, 35, v_lane_service_id);
		  dbms_sql.COLUMN_VALUE(l_cursor_id, 36, v_tariff_name);
		  dbms_sql.COLUMN_VALUE(l_cursor_id, 37, v_lane_type);

                end if;

                FOR n IN 1..l_rows_fetched LOOP

                    -- if this lane is not already there OR
                    -- if this lane is already there, but the lane service is not already there

                    -- [11/11] Add query type for Lane Group and Commitment -> 'T'

                    IF ((NOT l_result_lane_ids.EXISTS(v_lane_id(n + l_offset)))
                         OR (l_result_lane_ids.EXISTS(v_lane_id(n + l_offset))
                         AND p_source_type <> 'T' and v_lane_service_id(n + l_offset) is not null AND
                             NOT l_result_service_ids.EXISTS(v_lane_service_id(n + l_offset)))) THEN


                        l_transit_time := null; -- v_transit_time(n + l_offset); -- this is what's on the lane
                        l_transit_time_uom := 'DAY';

                        -- obtain transit time from ATP if transit time on lane is null
                        -- convert transit time on lane to DAYS if necessary

                        IF (p_source_type = 'R' AND
                          p_search_criteria.pickupstop_location_id is not null AND
                          p_search_criteria.ship_to_site_id is not null) THEN

                          IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Get_Transit_Time for OM:' );
                          END IF;

                          Get_Transit_Time(p_ship_from_loc_id =>  p_search_criteria.pickupstop_location_id,
                                           p_ship_to_site_id  =>  p_search_criteria.ship_to_site_id,
                                           p_carrier_id       =>  v_carrier_id(n + l_offset),
                                           p_service_code     =>  v_service_code(n + l_offset),
                                           p_mode_code        =>  v_mode_code(n + l_offset),
                                           p_from             =>  'OM',
                                           x_transit_time     =>  l_transit_time,
                                           x_return_status    =>  l_status);


                        ELSE IF (p_source_type = 'R' AND p_search_criteria.pickupstop_location_id is not null ) THEN

                          IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Get_Transit_Time for Trips / deliveries' );
                          END IF;

                          Get_Transit_Time(p_ship_from_loc_id =>  p_search_criteria.pickupstop_location_id,
                                           p_ship_to_site_id  =>  p_search_criteria.dropoffstop_location_id,
                                           p_carrier_id       =>  v_carrier_id(n + l_offset),
                                           p_service_code     =>  v_service_code(n + l_offset),
                                           p_mode_code        =>  v_mode_code(n + l_offset),
                                           p_from             =>  null,
                                           x_transit_time     =>  l_transit_time,
                                           x_return_status    =>  l_status);
                          End IF;
                      END IF;


                      IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                        x_return_status := l_status;
                        FND_MESSAGE.SET_NAME('FTE', 'FTE_CANNOT_GET_TRANSIT_TIME');
                        FND_MESSAGE.SET_TOKEN('LANE_NUMBER', v_lane_number(n + l_offset));
                        x_return_message := FND_MESSAGE.GET;
                        return;
                     END IF;

                    -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                    if (p_source_type ='T') THEN

                      l_lanes_rec := fte_lane_rec(v_lane_id(n + l_offset),
                                                '',
                                                v_origin_id(n + l_offset),
                                                v_destination_id(n + l_offset),
                                                v_carrier_id(n + l_offset),
                                                v_mode_code(n + l_offset),
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                v_party_name(n + l_offset),
                                                v_mode(n + l_offset),
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                v_origin_region_type(n + l_offset),
                                                '',
						'',
						'');

                        else

                          l_lanes_rec := fte_lane_rec(v_lane_id(n + l_offset),
                                                    v_lane_number(n + l_offset),
                                                    v_origin_id(n + l_offset),
                                                    v_destination_id(n + l_offset),
                                                    v_carrier_id(n + l_offset),
                                                    v_mode_code(n + l_offset),
                                                    v_comm_class_code(n + l_offset),
                                                    v_comm_catg_id(n + l_offset),
                                                    v_service_code(n + l_offset),
                                                    v_schedules_flag_code(n + l_offset),
                                                    v_rate_chart_id(n + l_offset),
                                                    v_basis(n + l_offset),
                                                    l_transit_time,
                                                    l_transit_time_uom,
                                                    v_distance(n + l_offset),
                                                    v_distance_uom(n + l_offset),
                                                    v_party_name(n + l_offset),
                                                    v_mode(n + l_offset),
                                                    v_commodity(n + l_offset),
                                                    v_service(n + l_offset),
                                                    v_schedules_flag(n + l_offset),
                                                    v_port_of_loading(n + l_offset),
                                                    v_port_of_discharge(n + l_offset),
                                                    v_rate_chart_name(n + l_offset),
                                                    v_owner_id(n + l_offset),
                                                    v_special_handling(n + l_offset),
                                                    v_addl_instr(n + l_offset),
                                                    v_commodity_flag(n + l_offset),
                                                    v_service_flag(n + l_offset),
                                                    v_rate_chart_view_flag(n + l_offset),
                                                    v_effective_date(n + l_offset),
                                                    v_expiry_date(n + l_offset),
                                                    v_origin_region_type(n + l_offset),
                                                    v_dest_region_type(n + l_offset),
                                                    v_tariff_name(n + l_offset),
						    v_lane_type(n + l_offset));
                    end if;

                    IF (l_search_criteria.vehicle_id is not null AND v_mode_code(n + l_offset) ='TRUCK') THEN

                      WSH_DEBUG_SV.logmsg(l_module_name,
                                          'Check Vehicle Availability for Lane ' || v_lane_number(n + l_offset));

                      IF( Is_Vehicle_Available(p_vehicle_id      => l_search_criteria.vehicle_id,
                                               p_carrier_id      => v_carrier_id(n + l_offset),
                                               p_origin_id       => v_origin_id(n + l_offset),
                                               p_dest_id         => v_destination_id(n + l_offset),
                                               p_mode            => v_mode(n + l_offset),
                                               p_date            => l_search_criteria.dep_date_from,
                                               x_return_message  => x_return_message) ) THEN

                         --g_message := g_message || '; Keep ' || v_lane_id(n + l_offset);
                         l_lanes_tab.EXTEND;
                         l_lanes_tab(l_num_rows + 1)                := l_lanes_rec;
                         l_num_rows                                 := l_num_rows + 1;
                         l_result_lane_ids(v_lane_id(n + l_offset)) := v_lane_id(n + l_offset);

                         -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                         IF (p_source_type <>'T' AND v_lane_service_id(n + l_offset) is not null) THEN
                            l_result_service_ids(v_lane_service_id(n + l_offset)) := v_lane_service_id(n + l_offset);
                         END IF;
                      ELSE
                        l_vehicles_discarded := l_vehicles_discarded || v_lane_id(n+l_offset) || ',';

                        WSH_DEBUG_SV.logmsg(l_module_name, 'Vehicle unavailable for lane ' || v_lane_number(n+l_offset));
                        WSH_DEBUG_SV.logmsg(l_module_name, x_return_message);
                      END IF;

                    ELSE
                      --g_message := g_message || '; Not a TL ' || v_lane_id(n + l_offset);
                      l_lanes_tab.EXTEND;
                      l_lanes_tab(l_num_rows + 1)                := l_lanes_rec;
                      l_num_rows                                 := l_num_rows + 1;
                      l_result_lane_ids(v_lane_id(n + l_offset)) := v_lane_id(n + l_offset);

                      -- [11/11] Add query type for Lane Group and Commitment -> 'T'
                      IF (p_source_type <>'T' AND v_lane_service_id(n + l_offset) is not null) THEN
                         l_result_service_ids(v_lane_service_id(n + l_offset)) := v_lane_service_id(n + l_offset);
                      END IF;

                    END IF;

                    END IF;

                END LOOP;

                l_offset := l_offset + l_rows_fetched;

                EXIT WHEN (l_rows_fetched < p_num_results OR l_lanes_tab.COUNT >= p_num_results);

            END LOOP;
            dbms_sql.CLOSE_CURSOR(l_cursor_id);

        END IF;
        -- call constraints API

    ELSE -- p_search_type = 'S'

          l_schedules_tab := fte_schedule_tab();

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_LANE_SEARCH_QUERY_GEN.CREATE_SCHEDULE_QUERY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FTE_LANE_SEARCH_QUERY_GEN.Create_Schedule_Query(p_search_criteria      => l_search_criteria,
                                                          p_origins              => l_origins,
                                                          p_destinations         => l_destinations,
                                                          p_parent_origins       => l_parent_origins,
                                                          p_parent_destinations  => l_parent_dests,
                                                          x_query                => l_query1,
                                                          x_bindvars             => l_bindvars1,
                                                          x_return_message       => l_msg,
                                                          x_return_status        => l_status);

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'schedule query: ' || l_query1,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          l_cursor_id := dbms_sql.OPEN_CURSOR;
          dbms_sql.PARSE(l_cursor_id, l_query1, DBMS_SQL.V7);

          Bind_Vars(l_cursor_id, l_bindvars1);

          dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, s_schedule_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 2, s_lane_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 3, s_lane_number, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 4, s_dep_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 5, s_arr_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 6, s_transit_time, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 7, s_frequency, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 8, s_effective_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 9, s_port_of_loading, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 10, s_port_of_discharge, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 11, s_expiry_date, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 12, s_arr_date_indicator, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 13, s_frequency_arrival, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 14, s_origin_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 15, s_destination_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 16, s_mode, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 17, s_carrier_id, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 18, s_carrier_name, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 19, s_dep_time, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 20, s_arr_time, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 21, s_frequency_type, p_num_results, 1); -- meaning
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 22, s_transit_time_uom, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 23, s_vessel_type, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 24, s_vessel_name, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 25, s_voyage_number, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 26, s_arr_time_w_ind, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 27, s_mode_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 28, s_service_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 29, s_service, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 30, s_frequency_type_code, p_num_results, 1);
          dbms_sql.DEFINE_ARRAY(l_cursor_id, 31, s_active_flag, p_num_results, 1);

          l_rows_affected := dbms_sql.EXECUTE(l_cursor_id);

          LOOP
            l_rows_fetched := dbms_sql.FETCH_ROWS(l_cursor_id);
            IF (l_rows_fetched = 0) THEN
                EXIT;
            END IF;

            dbms_sql.COLUMN_VALUE(l_cursor_id, 1, s_schedule_id);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 2, s_lane_id);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 3, s_lane_number);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 4, s_dep_date);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 5, s_arr_date);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 6, s_transit_time);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 7, s_frequency);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 8, s_effective_date);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 9, s_port_of_loading);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 10, s_port_of_discharge);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 11, s_expiry_date);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 12, s_arr_date_indicator);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 13, s_frequency_arrival);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 14, s_origin_id);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 15, s_destination_id);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 16, s_mode);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 17, s_carrier_id);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 18, s_carrier_name);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 19, s_dep_time);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 20, s_arr_time);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 21, s_frequency_type);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 22, s_transit_time_uom);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 23, s_vessel_type);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 24, s_vessel_name);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 25, s_voyage_number);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 26, s_arr_time_w_ind);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 27, s_mode_code);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 28, s_service_code);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 29, s_service);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 30, s_frequency_type_code);
            dbms_sql.COLUMN_VALUE(l_cursor_id, 31, s_active_flag);

            FOR n IN 1..l_rows_fetched LOOP
              l_schedules_rec := fte_schedule_rec(s_schedule_id(n + l_offset),
                                                  s_lane_id(n + l_offset),
                                                  s_lane_number(n + l_offset),
                                                  s_dep_date(n + l_offset),
                                                  s_arr_date(n + l_offset),
                                                  s_dep_time(n + l_offset),
                                                  s_arr_time(n + l_offset),
                                                  s_arr_time_w_ind(n + l_offset),
                                                  s_frequency_type_code(n + l_offset),
                                                  s_frequency_type(n + l_offset),
                                                  s_frequency(n + l_offset),
                                                  s_arr_date_indicator(n + l_offset),
                                                  s_frequency_arrival(n + l_offset),
                                                  s_transit_time(n + l_offset),
                                                  s_transit_time_uom(n + l_offset),
                                                  s_effective_date(n + l_offset),
                                                  s_expiry_date(n + l_offset),
                                                  s_port_of_loading(n + l_offset),
                                                  s_port_of_discharge(n + l_offset),
                                                  s_origin_id(n + l_offset),
                                                  s_destination_id(n + l_offset),
                                                  s_mode(n + l_offset),
                                                  s_carrier_id(n + l_offset),
                                                  s_carrier_name(n + l_offset),
                                                  s_vessel_type(n + l_offset),
                                                  s_vessel_name(n + l_offset),
                                                  s_voyage_number(n + l_offset),
                                                  s_mode_code(n + l_offset),
                                                  s_service_code(n + l_offset),
                                                  s_service(n + l_offset),
                                                  s_active_flag(n + l_offset)
                                                  );

              l_schedules_tab.EXTEND;
              l_schedules_tab(l_num_rows + 1) := l_schedules_rec;
              l_num_rows := l_num_rows + 1;
            END LOOP;

            l_offset := l_offset + l_rows_fetched;

            -- have enough rows, exit loop
            IF (l_num_rows >= p_num_results OR l_rows_fetched < p_num_results) THEN
              EXIT;
            END IF;

          END LOOP;

          dbms_sql.CLOSE_CURSOR(l_cursor_id);

        END IF; -- end if p_search_type = 'L'

        --
        -- Debug Statements
        --
        IF (l_debug_on AND p_search_type = 'L') THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'lanes obtained = ' || l_lanes_tab.COUNT,WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.logmsg(l_module_name,'lane ids returned: ',WSH_DEBUG_SV.C_PROC_LEVEL);

            IF (l_lanes_tab.count > 0) THEN
            FOR k IN l_lanes_tab.FIRST..l_lanes_tab.LAST LOOP
                WSH_DEBUG_SV.logmsg(l_module_name,l_lanes_tab(k).lane_id,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,l_lanes_tab(k).tariff_name,WSH_DEBUG_SV.C_PROC_LEVEL);
            END LOOP;
            END IF;
        END IF;

        -- check constraints if delivery leg search
        IF (p_search_type = 'L' AND l_lanes_tab.COUNT > 0 AND
            (p_search_criteria.delivery_id is not null OR
            p_search_criteria.delivery_leg_id is not null)) THEN

          SELECT shipping_control INTO l_shipping_control
          FROM wsh_new_deliveries
          WHERE delivery_id = p_search_criteria.delivery_id;

          -- only perform constraints checking if supplier does not manage freight for delivery
          IF (l_shipping_control is null OR l_shipping_control <> 'SUPPLIER') THEN

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Leg Lane Search.  Performing constraints checking',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            -- setup delivery record for constraints check
            l_dleg_info_rec.delivery_leg_id := p_search_criteria.delivery_leg_id;
            l_dleg_info_rec.exists_in_database := p_search_criteria.exists_in_database;
            l_dleg_info_rec.delivery_id := p_search_criteria.delivery_id;
            l_dleg_info_rec.sequence_number := p_search_criteria.sequence_number;
            l_dleg_info_rec.pick_up_stop_id := p_search_criteria.pick_up_stop_id;
            l_dleg_info_rec.drop_off_stop_id := p_search_criteria.drop_off_stop_id;
            l_dleg_info_rec.pickupstop_location_id := p_search_criteria.pickupstop_location_id;
            l_dleg_info_rec.dropoffstop_location_id := p_search_criteria.dropoffstop_location_id;

            -- setup lanes table of record for constraints check
            FOR j IN l_lanes_tab.FIRST..l_lanes_tab.LAST LOOP

                l_lane_info_rec.lane_id := l_lanes_tab(j).lane_id;
                l_lane_info_rec.lane_number := l_lanes_tab(j).lane_number;
                l_lane_info_rec.owner_id := l_lanes_tab(j).owner_id;
                l_lane_info_rec.carrier_id := l_lanes_tab(j).carrier_id;
                l_lane_info_rec.origin_id := l_lanes_tab(j).origin_id;
                l_lane_info_rec.destination_id := l_lanes_tab(j).destination_id;
                l_lane_info_rec.mode_of_transportation_code := l_lanes_tab(j).mode_of_transport_code;

                l_lane_info_tab(j) := l_lane_info_rec;

            END LOOP;

            -- call constraints API
            WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dleg(
                                        p_init_msg_list         => fnd_api.g_true,
                                        p_action_code           => WSH_FTE_CONSTRAINT_FRAMEWORK.G_DLEG_LANE_SEARCH,
                                        p_exception_list        => l_dummy_exception,
                                        p_delivery_leg_rec      => l_dleg_info_rec,
                                        p_target_trip           => l_dummy_trips,
                                        p_target_lane           => l_lane_info_tab,
                                        x_succ_trips            => l_success_trips,
                                        x_succ_lanes            => l_success_lanes,
                                        x_validate_result       => l_validate_result,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        x_return_status         => l_status);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'After calling WSH_FTE_COMP_CONSTRAINT_ENGINE.validate_constraint_dleg. Messages:',WSH_DEBUG_SV.C_PROC_LEVEL);
                IF (l_msg_count > 1) THEN
                  FOR m IN 1..l_msg_count LOOP
                    l_msg_data := FND_MSG_PUB.GET(m, 'T');
                    WSH_DEBUG_SV.logmsg(l_module_name,l_msg_data,WSH_DEBUG_SV.C_PROC_LEVEL);
                  END LOOP;
                ELSE
                  WSH_DEBUG_SV.logmsg(l_module_name,l_msg_data,WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

            END IF;
            --

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'validate result = ' || l_validate_result,WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.logmsg(l_module_name,'lane ids returned by constraints ' || l_success_lanes.COUNT,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            -- loop thru l_lanes_tab and for each lane_id, check to see if in l_success_lanes
            -- if not in there, then delete from l_lanes_tab
            IF (l_validate_result = 'F') THEN
                FOR k IN l_lanes_tab.FIRST..l_lanes_tab.LAST LOOP
                    l_good_lane := 'N';
                    l_cc_lane_counter := l_success_lanes.FIRST;
                    WHILE l_cc_lane_counter <= l_success_lanes.LAST LOOP
                      IF (l_lanes_tab(k).lane_id = l_success_lanes(l_cc_lane_counter)) THEN
                        l_good_lane := 'Y';
                        GOTO end_lane_loop;
                      END IF;
                      l_cc_lane_counter := l_success_lanes.NEXT(l_cc_lane_counter);
                    END LOOP;

                    <<end_lane_loop>>
                    NULL;

                    IF (l_good_lane <> 'Y') THEN
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'removing lane ' || l_lanes_tab(k).lane_id,WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;

                        l_lanes_tab.DELETE(k);

                    END IF;
                END LOOP;

            END IF; -- end l_validate_result = 'F'

          ELSE

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Supplier manages freight.  Skipping constraints checking.', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

          END IF; -- end if <> supplier managing freight

        END IF;  -- end constraints checking

        x_lane_results := l_lanes_tab;
        x_schedule_results := l_schedules_tab;
        IF (l_vehicles_discarded IS NOT NULL) THEN
          x_return_message := x_return_message || 'The ff. lanes were discarded because vehicles are unavailable: ' ||
                              l_vehicles_discarded;
        END IF;

        x_return_message := x_return_message || g_message;

        g_message := null;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
  EXCEPTION
    WHEN OTHERS THEN
      x_return_message := g_message || 'Unexpected Error in Search_Lanes Package: ' || sqlerrm;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
  END Search_Lanes;


  -- ----------------------------------------------------------------
  -- Name:              Get_Rate_Chart_Ids
  -- Type:              Procedure
  --
  -- Description:       This procedure returns a SQL table of rate
  --                    chart ids that match the regions and carrier
  --                    information.
  --                    Called by Rate Chart Search to prevent
  --                    duplication in the relax up regions query.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Get_Rate_Chart_Ids(p_search_criteria IN  fte_search_criteria_rec,
                               p_num_results     IN  NUMBER,
                               x_rate_chart_ids  OUT NOCOPY      STRINGARRAY,
                               x_return_status   OUT NOCOPY      VARCHAR2) IS

  l_origin_zip      VARCHAR2(30) := null;
  l_destination_zip VARCHAR2(30) := null;
  l_carrier_name    VARCHAR2(30) := null;
  l_tariff_name    VARCHAR2(80) := null;
  l_origins         FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_destinations    FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_origins  FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_dests    FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;

  l_query       VARCHAR2(5000);
  l_bindvars    FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_cursor_id   NUMBER;
  l_counter     NUMBER;
  l_rows_affected NUMBER;
  l_rows_fetched        NUMBER := 0;
  l_num_rows            NUMBER := 0;
  l_rate_chart_tab      STRINGARRAY;

  v_rate_chart_id       dbms_sql.VARCHAR2_TABLE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_RATE_CHART_IDS';
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
  END IF;
  --

        l_rate_chart_tab := STRINGARRAY();

        -- get carrier name
        l_carrier_name := p_search_criteria.carrier_name;
        l_tariff_name  := p_search_criteria.tariff_name;
        WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.tariff_name', p_search_criteria.tariff_name);
        -- get origin and parents set up
        l_origin_zip := p_search_criteria.origin_zip;
        Set_Up_Regions(p_search_criteria.origin_loc_id,
                       p_search_criteria.origin_country,
                       p_search_criteria.origin_state,
                       p_search_criteria.origin_city,
                       l_origin_zip,
                       l_origins,
                       l_parent_origins);

        -- get destination and parents set up
        l_destination_zip := p_search_criteria.destination_zip;
        Set_Up_Regions(p_search_criteria.destination_loc_id,
                       p_search_criteria.destination_country,
                       p_search_criteria.destination_state,
                       p_search_criteria.destination_city,
                       l_destination_zip,
                       l_destinations,
                       l_parent_dests);


       IF (( l_parent_dests IS NULL OR l_parent_dests.COUNT <= 0 OR
             l_parent_origins IS NULL OR l_parent_origins.COUNT <= 0) AND
             (l_tariff_name is NULL ))
             THEN
          x_rate_chart_ids := l_rate_chart_tab;
          RETURN;
       END IF;
        FTE_LANE_SEARCH_QUERY_GEN.Create_Rate_Chart_Query(
                      p_parent_origins     =>l_parent_origins,
                      p_parent_destinations  =>l_parent_dests,
                      p_origin_zip_request   =>l_origin_zip,
                      p_dest_zip_request     =>l_destination_zip,
                      p_carrier_name         =>l_carrier_name,
                      p_tariff_name          => l_tariff_name,
                      x_query                => l_query,
                      x_bindvars             => l_bindvars);


            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'rate chart query:' || l_query,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;


        l_cursor_id := dbms_sql.OPEN_CURSOR;
        dbms_sql.PARSE(l_cursor_id, l_query, DBMS_SQL.V7);

        Bind_Vars(l_cursor_id, l_bindvars);

        dbms_sql.DEFINE_ARRAY(l_cursor_id, 1, v_rate_chart_id, p_num_results, 1);

        l_rows_affected := dbms_sql.EXECUTE(l_cursor_id);
        LOOP
            l_rows_fetched := dbms_sql.FETCH_ROWS(l_cursor_id);
            IF (l_rows_fetched = 0) THEN
                EXIT;
            END IF;
            dbms_sql.COLUMN_VALUE(l_cursor_id, 1, v_rate_chart_id);

            FOR n IN 1..l_rows_fetched LOOP
                l_rate_chart_tab.EXTEND;
                l_rate_chart_tab(l_num_rows + 1) := v_rate_chart_id(n);
                l_num_rows := l_num_rows + 1;
            END LOOP;

            -- have enough rows, exit loop
            IF (l_num_rows >= p_num_results OR l_rows_fetched < p_num_results) THEN
                EXIT;
            END IF;

        END LOOP;
	dbms_sql.CLOSE_CURSOR(l_cursor_id);
        x_rate_chart_ids := l_rate_chart_tab;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Get_Rate_Chart_Ids;

END FTE_LANE_SEARCH;

/
