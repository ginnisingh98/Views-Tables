--------------------------------------------------------
--  DDL for Package Body WSH_REGIONS_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_REGIONS_SEARCH_PKG" AS
/* $Header: WSHRESEB.pls 120.12.12010000.2 2008/08/29 13:21:51 selsubra ship $ */

  --
  -- Package
  --   	WSH_REGIONS_SEARCH_PKG
  --
  -- Purpose
  --

  --
  -- PACKAGE TYPES
  --

  --
  -- PUBLIC VARIABLES
  --

  --Global cache for regions and locations.
   g_region_zone_tab			WSH_UTIL_CORE.tbl_varchar;
   g_location_region_tab		WSH_UTIL_CORE.tbl_varchar;

   g_loc_region_deconsol_tab          loc_region_deconsol_tab_type;
   g_loc_region_zone_deconsol_tab          loc_region_deconsol_tab_type;
   g_region_zone_deconsol_tab         region_zone_deconsol_tab_type;

   -- Bug - 4722963
   -- constants defined to be used in regions cache g_regions_info_tab
   TYPE regions_info_tab_type IS TABLE OF region_table INDEX BY VARCHAR2(32767);

   g_regions_info_tab       regions_info_tab_type;
   g_emp_reg_info_tab       regions_info_tab_type;  --Bug 7313093
   g_int_mask              VARCHAR2(12) := 'S00000000000';
   g_lpad_char             VARCHAR2(1)  := '0';
   g_lpad_length           NUMBER       := 120;  --Bug 7313093
   g_lpad_code_length      NUMBER       := 5;
   g_session_id            NUMBER;
   g_country_code          VARCHAR2(2);
  -- Bug - 4722963 end

  --Cache size constant
    g_cache_max_size		NUMBER := power(2,31);
  --

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   call another Get_Region_Info with p_search_flag ='N'
  --
  --
  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_REGIONS_SEARCH_PKG';
  --

  --
  -- PROCEDURE : get_key
  -- ACESS LEVEL : PRIVATE
  --
  -- PURPOSE   : This procedure returns cache key in the following format
  --             region type-country-country code-state-state code-city-city code-postal code from-postal code to-zone-lang code

  PROCEDURE get_key (
    p_country               IN  VARCHAR2,
    p_state                 IN  VARCHAR2,
    p_city                  IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_zone                  IN  VARCHAR2,
    p_lang_code             IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_region_type           IN  NUMBER,
    x_key                   OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2) IS

    --
    l_debug_on BOOLEAN;
    l_key       VARCHAR2(32767);
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_KEY';
    l_return_status VARCHAR2(10);
    BEGIN

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        l_return_status :=  FND_API.G_RET_STS_SUCCESS;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
            WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
            WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
            WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
            WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
            WSH_DEBUG_SV.log(l_module_name,'P_ZONE',P_ZONE);
            WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
        END IF;
        l_key := TO_CHAR(P_REGION_TYPE,  g_int_mask) ||'-'||
                LPAD(P_COUNTRY, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_COUNTRY_CODE, g_lpad_code_length, g_lpad_char) ||'-'||
                LPAD(P_STATE, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_STATE_CODE, g_lpad_code_length, g_lpad_char) ||'-'||
                LPAD(P_CITY, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_CITY_CODE, g_lpad_code_length, g_lpad_char) ||'-'||
                LPAD(P_POSTAL_CODE_FROM, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_POSTAL_CODE_TO, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_ZONE, g_lpad_length, g_lpad_char) ||'-'||
                LPAD(P_LANG_CODE, g_lpad_code_length, g_lpad_char) ;

        x_key := l_key;

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        x_return_status := l_return_status;
  EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.get_key');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
 END get_key;

  PROCEDURE Get_Region_Info (
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_zone				IN	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	x_region_info			OUT NOCOPY 	region_rec) IS
	--
	l_debug_on BOOLEAN;
    l_regions region_table;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_REGION_INFO';
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
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
  	    WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
  	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
  	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
  	    WSH_DEBUG_SV.log(l_module_name,'P_ZONE',P_ZONE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
  	END IF;
  	--

    Get_Region_Info (
        p_country           => p_country,
        p_country_region    => p_country_region,
        p_state             => p_state,
        p_city              => p_city,
        p_postal_code_from  => p_postal_code_from,
        p_postal_code_to    => p_postal_code_to,
        p_zone              => p_zone,
        p_lang_code         => p_lang_code,
        p_country_code      => p_country_code,
        p_country_region_code=> p_country_region_code,
        p_state_code         => p_state_code,
        p_city_code          => p_city_code,
        p_region_type        => p_region_type,
        p_interface_flag     => p_interface_flag,
        p_search_flag        => 'N',
        x_region_info        => x_region_info);

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
  END Get_Region_Info;



  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   Obtains information of the region by matching all non-null
  -- 		parameters that are passed in.  If none, returns null in x_region_info
  --

  PROCEDURE Get_Region_Info (
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_zone				IN	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	p_search_flag			IN	VARCHAR2,
	x_regions			OUT NOCOPY 	region_table) IS

  sql_string VARCHAR2(4000);
  l_key       VARCHAR2(32767);
  v_dummy INTEGER;
  l_region_info region_rec;
  TYPE region_bind_type IS VARRAY(15) OF VARCHAR2(100);
  region_bind region_bind_type := region_bind_type('','','','','','','','','','','','','','','');
  cnt NUMBER := 0;

  TYPE RegCurTyp IS REF CURSOR;
  l_region_cur RegCurTyp;
  l_return_status      VARCHAR2(10);
  l_region_type NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_REGION_INFO';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
	    WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
	    WSH_DEBUG_SV.log(l_module_name,'P_ZONE',P_ZONE);
	    WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
	    WSH_DEBUG_SV.log(l_module_name,'P_SEARCH_FLAG',P_SEARCH_FLAG);
	END IF;
	--
    get_key(
        p_country 			=> 	p_country,
        p_state 			=> 	p_state,
        p_city 			    => 	p_city,
        p_postal_code_from 	=> 	p_postal_code_from,
        p_postal_code_to 	=> 	p_postal_code_to,
        p_zone			    =>	p_zone,
        p_lang_code			=>	p_lang_code,
        p_country_code 		=> 	p_country_code,
        p_state_code 		=> 	p_state_code,
        p_city_code 		=> 	p_city_code,
        p_region_type		=> 	l_region_type,
        x_key		        =>	l_key,
        x_return_status     => l_return_status);

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from get_key : '|| l_return_status);
    END IF;

    IF g_regions_info_tab.EXISTS(l_key) THEN
        x_regions := g_regions_info_tab(l_key);
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'used cache for key', l_key);
            wsh_debug_sv.log(l_module_name, 'x_regions.count', x_regions.count);
        END IF;
    ELSE

        IF (p_region_type IS NULL) THEN

               IF (p_postal_code_from IS NOT NULL OR p_postal_code_to IS NOT NULL) THEN
              l_region_type := 3;
               ELSIF (p_city IS NOT NULL OR p_city_code IS NOT NULL) THEN
              l_region_type := 2;
               ELSIF (p_state IS NOT NULL OR p_state_code IS NOT NULL) THEN
              l_region_type := 1;
               ELSIF (p_zone IS NOT NULL) THEN
              l_region_type := 10;
               END IF;
            ELSE
           l_region_type := p_region_type;
        END IF;

        sql_string := 'select R.REGION_ID,
                      R.REGION_TYPE,
                      TL.COUNTRY,
                      TL.COUNTRY_REGION,
                      TL.STATE,
                      TL.CITY,
                      TL.POSTAL_CODE_FROM,
                      TL.POSTAL_CODE_TO,
                      TL.ZONE,
                      R.ZONE_LEVEL,
                      R.COUNTRY_CODE,
                      R.COUNTRY_REGION_CODE,
                      R.STATE_CODE,
                      R.CITY_CODE,
                      ''N'' ';

        IF (p_interface_flag = 'Y') THEN
           sql_string := sql_string ||
                     ' from WSH_REGIONS_INTERFACE R, WSH_REGIONS_TL_INTERFACE TL';
        ELSE
           sql_string := sql_string ||
                     ' from WSH_REGIONS R, WSH_REGIONS_TL TL';
        END IF;

    --	sql_string := sql_string ||
        --	      ' where R.REGION_ID = TL.REGION_ID and ROWNUM < 2 ';
        sql_string := sql_string ||
                  ' where R.REGION_ID = TL.REGION_ID ';

        sql_string := sql_string ||
                  ' and R.REGION_TYPE = :region_type ';
            cnt := cnt + 1;
            region_bind(cnt) := l_region_type;

            IF (p_country_code IS NOT NULL) THEN
               sql_string := sql_string ||
                             ' AND UPPER(R.COUNTRY_CODE) = UPPER(:country_code)';
               cnt := cnt + 1;
               region_bind(cnt) := p_country_code;
            END IF;

            IF (p_state_code IS NOT NULL) THEN

               --Bugfix 2877445 adding nvl for state when searching for city regions

           IF (p_city_code IS NOT NULL OR p_city IS NOT NULL) THEN
            sql_string := sql_string ||
                  ' and NVL(UPPER(R.STATE_CODE),UPPER(:state_code)) = UPPER(:state_code)';
                cnt := cnt + 1;
                region_bind(cnt) := p_state_code;
               ELSE
            sql_string := sql_string ||
                  ' and UPPER(R.STATE_CODE) = UPPER(:state_code)';
               END IF;

               -- sql_string := sql_string ||
               --               ' and UPPER(R.STATE_CODE) = UPPER(:state_code)';
               cnt := cnt + 1;
               region_bind(cnt) := p_state_code;

            END IF;

        IF (p_city_code IS NOT NULL) THEN


           sql_string := sql_string ||
                 ' and UPPER(R.CITY_CODE) = UPPER(:city_code)';
               cnt := cnt + 1;
               region_bind(cnt) := p_city_code;
            END IF;

        IF (p_country IS NOT NULL) THEN

           sql_string := sql_string ||
                 ' and UPPER(TL.COUNTRY) = UPPER(:country)';
           cnt := cnt + 1;
               region_bind(cnt) := p_country;

        END IF;

        IF (p_state IS NOT NULL) THEN


               --Bugfix 2877445 adding nvl for state when searching for city regions

           IF (p_city_code IS NOT NULL OR p_city IS NOT NULL) THEN
            sql_string := sql_string ||
                  ' and NVL(UPPER(TL.state), UPPER(:state)) = UPPER(:state)';
            cnt := cnt + 1;
                region_bind(cnt) := p_state;
               ELSE
            sql_string := sql_string ||
                  ' and UPPER(TL.state) = UPPER(:state)';
               END IF;

           -- sql_string := sql_string ||
           --		 ' and UPPER(TL.state) = UPPER(:state)';
           cnt := cnt + 1;
               region_bind(cnt) := p_state;

        END IF;

        IF (p_city IS NOT NULL) THEN


           sql_string := sql_string ||
                 ' and UPPER(TL.CITY) = UPPER(:city)';
           cnt := cnt + 1;
               region_bind(cnt) := p_city;
        END IF;

            -- both from and to have to be populated

        IF (p_postal_code_from IS NOT NULL) THEN

           -- check overlapping regions as well
           IF (p_search_flag = 'N') THEN

            sql_string := sql_string ||
                 ' and (( :postal_code_from between TL.POSTAL_CODE_FROM and TL.POSTAL_CODE_TO) '||
                 ' or ( :postal_code_to between TL.POSTAL_CODE_FROM and TL.POSTAL_CODE_TO ) '||
                 ' or (TL.POSTAL_CODE_FROM between :postal_code_from AND :postal_code_to)) ';

                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_from;
                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_to;
                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_from;
                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_to;
           ELSE
           -- check only the exactly matching regions
            sql_string := sql_string ||
                 ' and ( :postal_code_from = TL.POSTAL_CODE_FROM and :postal_code_to = TL.POSTAL_CODE_TO) ';

                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_from;
                cnt := cnt + 1;
                    region_bind(cnt) := p_postal_code_to;
           END IF;

        END IF;

        IF (p_zone IS NOT NULL) THEN

           sql_string := sql_string ||
                 ' and TL.zone = :zone';

           cnt := cnt + 1;
               region_bind(cnt) := p_zone;
        END IF;

        IF (p_lang_code IS NOT NULL) THEN

           sql_string := sql_string ||
                 ' and TL.LANGUAGE = :lang_code ';
           cnt := cnt + 1;
               region_bind(cnt) := p_lang_code;

        END IF;

            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Get_Region_Id:: sql_string_length: ' || length(sql_string));
           for i IN 1..length(sql_string) loop
             if mod(i,100) = 0 then
                    WSH_DEBUG_SV.logmsg(l_module_name, substr(sql_string,i, 100));
                 end if;
           end loop;
            END IF;
          IF (cnt = 0) THEN
               OPEN l_region_cur FOR  sql_string;
          ELSIF (cnt = 1) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1);

          ELSIF (cnt = 2) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2);

            ELSIF (cnt = 3) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3);

            ELSIF (cnt = 4) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4);

            ELSIF (cnt = 5) THEN
              OPEN l_region_cur FOR  sql_string
         USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5);

            ELSIF (cnt = 6) THEN
              OPEN l_region_cur FOR  sql_string
         USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6);

            ELSIF (cnt = 7) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7);

            ELSIF (cnt = 8) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8);

            ELSIF (cnt = 9) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9);

            ELSIF (cnt = 10) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9),region_bind(10);

            ELSIF (cnt = 11) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9),region_bind(10), region_bind(11);

            ELSIF (cnt = 12) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9),region_bind(10), region_bind(11), region_bind(12);

            ELSIF (cnt = 13) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9),region_bind(10), region_bind(11), region_bind(12), region_bind(13);

            ELSIF (cnt = 14) THEN
               OPEN l_region_cur FOR  sql_string
           USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9),region_bind(10), region_bind(11), region_bind(12), region_bind(13), region_bind(14);

            END IF;
            cnt:=0;
          LOOP
           FETCH l_region_cur INTO l_region_info;
           EXIT WHEN l_region_cur%NOTFOUND;
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, ' fetching region info of '||l_region_info.region_id);
              WSH_DEBUG_SV.logmsg(l_module_name, ' inserting into region table at '||cnt);
           END IF;
           x_regions(cnt) := l_region_info;
           cnt :=cnt + 1;

            -- process record
          END LOOP;
        CLOSE l_region_cur;
        IF x_regions.count = 0 THEN
          l_region_info.region_id := -1;
          x_regions(0) := l_region_info;
        END IF;
        g_regions_info_tab(l_key) := x_regions;
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
	      l_region_info.region_id := -1;
	      x_regions(0) := l_region_info;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    --Bug 4775798
    ELSE
    WSH_UTIL_CORE.printmsg('Unexpected error has occured in Get_Region_Info');
    WSH_UTIL_CORE.printmsg('Oracle error message is '|| SQLERRM);
END IF;
--
  END Get_Region_Info;

 PROCEDURE Get_Region_Info (
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_zone				IN	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	p_search_flag			IN	VARCHAR2,
	x_region_info			OUT NOCOPY 	region_rec) IS

   p_region_info region_table;

  BEGIN
    Get_Region_Info (
      p_country 		=> p_country,
      p_country_region 	=> p_country_region,
      p_state 		=> p_state,
      p_city 			=> p_city,
      p_postal_code_from 	=> p_postal_code_from,
      p_postal_code_to 	=> p_postal_code_to,
      p_zone			=> p_zone,
      p_lang_code		=> p_lang_code,
      p_country_code 		=> p_country_code,
      p_country_region_code	=> p_country_region_code,
      p_state_code 		=> p_state_code,
      p_city_code 		=> p_city_code,
      p_region_type		=> p_region_type,
      p_interface_flag	=> p_interface_flag,
      p_search_flag		=> p_search_flag,
      x_regions		=> p_region_info);

      x_region_info := p_region_info(0);

  END;



  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   Obtains region_id only of the region by matching all non-null
  -- 		parameters that are passed in.  If none, returns -1 in x_region_id
  --

  PROCEDURE Get_Region_Info (
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_zone				IN	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	p_search_flag			IN	VARCHAR2,
	p_recursively_flag		IN	VARCHAR2,
	x_region_id			OUT NOCOPY 	NUMBER) IS

  l_region_info region_rec;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_REGION_INFO';
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
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
  	    WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
  	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
  	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
  	    WSH_DEBUG_SV.log(l_module_name,'P_ZONE',P_ZONE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
  	    WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
  	    WSH_DEBUG_SV.log(l_module_name,'P_SEARCH_FLAG',P_SEARCH_FLAG);
  	    WSH_DEBUG_SV.log(l_module_name,'P_RECURSIVELY_FLAG',P_RECURSIVELY_FLAG);
  	END IF;
  	--
  	Get_Region_Info (
		p_country 		=> p_country,
		p_country_region 	=> p_country_region,
		p_state 		=> p_state,
		p_city 			=> p_city,
		p_postal_code_from 	=> p_postal_code_from,
		p_postal_code_to 	=> p_postal_code_to,
		p_zone			=> p_zone,
		p_lang_code		=> p_lang_code,
		p_country_code 		=> p_country_code,
		p_country_region_code	=> p_country_region_code,
		p_state_code 		=> p_state_code,
		p_city_code 		=> p_city_code,
		p_region_type		=> p_region_type,
		p_interface_flag	=> p_interface_flag,
		p_search_flag		=> p_search_flag,
		x_region_info		=> l_region_info);

	IF (l_region_info.region_id is not null AND l_region_info.region_id <> -1) THEN
	    x_region_id := l_region_info.region_id;
	ELSE
	    x_region_id := -1;
	END IF;

	-- if cannot find region and recursively, remove postal code and call again
	-- if postal codes exist, otherwise, do nothing
	IF (x_region_id = -1 AND p_recursively_flag = 'Y' AND p_postal_code_from is not null) THEN

	    Get_Region_Info (
		p_country 		=> p_country,
		p_country_region 	=> p_country_region,
		p_state 		=> p_state,
		p_city 			=> p_city,
		p_postal_code_from 	=> null,
		p_postal_code_to 	=> null,
		p_zone			=> p_zone,
		p_lang_code		=> p_lang_code,
		p_country_code 		=> p_country_code,
		p_country_region_code	=> p_country_region_code,
		p_state_code 		=> p_state_code,
		p_city_code 		=> p_city_code,
		p_region_type		=> null,
		p_interface_flag	=> p_interface_flag,
		p_search_flag		=> p_search_flag,
		x_region_info		=> l_region_info);

	    IF (l_region_info.region_id is not null AND l_region_info.region_id <> -1) THEN
	    	x_region_id := l_region_info.region_id;
	    ELSE
	    	x_region_id := -1;
	    END IF;

	END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Get_Region_Info;

  --
  -- Procedure: Get_Region_Id_Codes_Only
  --
  -- Purpose:   Obtains information for the region by matching all non-null
  -- 		parameters that are passed in, against the non-tl table.
  --            If no region found, returns null in x_region_info
  --

  PROCEDURE Get_Region_Id_Codes_Only (
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_postal_code_from		IN	VARCHAR2,
	p_postal_code_to		IN	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	p_language_code                 IN      VARCHAR2 DEFAULT NULL,
	x_region_id			OUT NOCOPY 	NUMBER) IS

  TYPE C_TYPE IS REF CURSOR;
  c_region C_TYPE;

  sql_string VARCHAR2(4000);

  l_region_id NUMBER;

  TYPE region_bind_type IS VARRAY(15) OF VARCHAR2(100);
  region_bind region_bind_type := region_bind_type('','','','','','','','','','','','','','','');
  cnt NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_REGION_ID_CODES_ONLY';
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
            WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
            WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
            WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
            WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_LANGUAGE_CODE',P_LANGUAGE_CODE);
        END IF;
        --
        IF (p_country_code IS NULL AND p_state_code IS NULL AND p_city_code IS NULL ) THEN
	   l_region_id := -1;
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
        END IF;

   	sql_string := 'select R.REGION_ID';

	IF (p_interface_flag = 'Y') THEN
	   sql_string := sql_string ||
		         ' from WSH_REGIONS_INTERFACE R ';
	ELSE
	   sql_string := sql_string ||
		         ' from WSH_REGIONS R ';
	END IF;


	IF (p_postal_code_from IS NOT NULL OR p_language_code IS NOT NULL) THEN

	   IF (p_interface_flag = 'Y') THEN

	      sql_string := sql_string ||
			    ', WSH_REGIONS_TL_INTERFACE TL ';

	   ELSE

	      sql_string := sql_string ||
			    ', WSH_REGIONS_TL TL ';

	   END IF;

	END IF;

	sql_string := sql_string ||
		      ' where R.REGION_TYPE = :region_type ';
        cnt := cnt + 1;
        region_bind(cnt) := p_region_type;

	IF (p_postal_code_from IS NOT NULL OR p_language_code IS NOT NULL) THEN
	   sql_string := sql_string ||
		      ' and R.REGION_ID = TL.REGION_ID ';
        END IF;

        IF (p_country_code IS NOT NULL) THEN
           sql_string := sql_string ||
                         ' AND UPPER(R.COUNTRY_CODE) = UPPER(:country_code)';
           cnt := cnt + 1;
           region_bind(cnt) := p_country_code;
        END IF;

        IF (p_state_code IS NOT NULL) THEN

           --Bugfix 2877445 adding nvl for state when searching for city regions

	   IF (p_city_code IS NOT NULL) THEN
	    sql_string := sql_string ||
			  ' and NVL(UPPER(R.STATE_CODE),UPPER(:state_code)) = UPPER(:state_code)';
            cnt := cnt + 1;
            region_bind(cnt) := p_state_code;
           ELSE
	    sql_string := sql_string ||
			  ' and UPPER(R.STATE_CODE) = UPPER(:state_code)';
           END IF;

           -- sql_string := sql_string ||
           --               ' and UPPER(R.STATE_CODE) = UPPER(:state_code)';
           cnt := cnt + 1;
           region_bind(cnt) := p_state_code;

        END IF;

	IF (p_city_code IS NOT NULL) THEN

	   sql_string := sql_string ||
			 ' and UPPER(R.CITY_CODE) = UPPER(:city_code)';
           cnt := cnt + 1;
           region_bind(cnt) := p_city_code;
        END IF;

        -- both from and to have to be populated

	IF (p_postal_code_from IS NOT NULL) THEN

	   -- check overlapping regions as well
	  	sql_string := sql_string ||
			 ' and (( :postal_code_from between TL.POSTAL_CODE_FROM and TL.POSTAL_CODE_TO) '||
			 ' or ( :postal_code_to between TL.POSTAL_CODE_FROM and TL.POSTAL_CODE_TO ) '||
			 ' or (TL.POSTAL_CODE_FROM between :postal_code_from AND :postal_code_to)) ';

	        cnt := cnt + 1;
                region_bind(cnt) := p_postal_code_from;
	        cnt := cnt + 1;
                region_bind(cnt) := p_postal_code_to;
	        cnt := cnt + 1;
                region_bind(cnt) := p_postal_code_from;
	        cnt := cnt + 1;
                region_bind(cnt) := p_postal_code_to;

	END IF;

	IF (p_language_code IS NOT NULL) THEN

	   sql_string := sql_string ||
			 ' and TL.LANGUAGE = :lang_code ';
	   cnt := cnt + 1;
           region_bind(cnt) := p_language_code;

	END IF;

        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Get_Region_Id:: sql_string_length: ' || length(sql_string));
           WSH_DEBUG_SV.logmsg(l_module_name, substr(sql_string,101, 200));
        END IF;

	IF (cnt = 0) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id;

        ELSIF (cnt = 1) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1);

        ELSIF (cnt = 2) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2);

        ELSIF (cnt = 3) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3);

        ELSIF (cnt = 4) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4);

        ELSIF (cnt = 5) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5);

        ELSIF (cnt = 6) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6);

        ELSIF (cnt = 7) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7);

        ELSIF (cnt = 8) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8);

        ELSIF (cnt = 9) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9);

        ELSIF (cnt = 10) THEN
           EXECUTE IMMEDIATE sql_string
	   INTO  l_region_id
	   USING region_bind(1), region_bind(2), region_bind(3), region_bind(4), region_bind(5), region_bind(6), region_bind(7), region_bind(8), region_bind(9), region_bind(10);

	END IF;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'sql_string:: ' || sql_string);
	    WSH_DEBUG_SV.logmsg(l_module_name, 'region_id = ' || l_region_id);
	END IF;

	x_region_id := l_region_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	EXCEPTION
	   WHEN OTHERS THEN
	      x_region_id := -1;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Get_Region_Id_Codes_Only;

  --
  -- Procedure: Get_Region_Id_Codes_Only
  --
  -- Purpose:   Obtains information for the region by calling overloaded get_regioN_id_codes_only
  --            method which matches all non-null parameters that are passed in, against the non-tl table.
  --            If region found, it checks if a tl entry exists in that language
  --            This is so that uniqueness is held for a region_id and language combination
  --

  PROCEDURE Get_Region_Id_Codes_Only (
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_postal_code_from		IN	VARCHAR2,
	p_postal_code_to		IN	VARCHAR2,
	p_region_type			IN 	NUMBER,
	p_interface_flag		IN	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	x_region_id_non_tl		OUT NOCOPY 	NUMBER,
	x_region_id_with_tl		OUT NOCOPY 	NUMBER) IS

  TYPE C_TYPE IS REF CURSOR;
  c_region C_TYPE;

  sql_string VARCHAR2(4000);

  l_region_id NUMBER;
  l_region_type NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_REGION_ID_CODES_ONLY';
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
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
     END IF;
     --
     IF ((p_country_code IS NULL AND p_state_code IS NULL AND p_city_code IS NULL ) OR ( p_region_type = 2 AND p_city_code IS NULL) OR (p_region_type=1 and p_state_code IS NULL) OR (p_region_type = 0 AND p_country_code IS NULL)) THEN
	   l_region_id := -1;
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
     END IF;

     IF (p_region_type IS NULL) THEN

        IF (p_postal_code_from IS NOT NULL OR p_postal_code_to IS NOT NULL) THEN
	      l_region_type := 3;
        ELSIF (p_city_code IS NOT NULL) THEN
	      l_region_type := 2;
        ELSIF (p_state_code IS NOT NULL) THEN
	      l_region_type := 1;
        END IF;
     ELSE
	   l_region_type := p_region_type;
     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name, 'getting non-tl id '||x_region_id_non_tl);
	WSH_DEBUG_SV.logmsg(l_module_name, 'country code '||p_country_code);
     END IF;

      Get_Region_Id_Codes_Only (
	p_country_code 			=> 	p_country_code,
	p_country_region_code 		=> 	p_country_region_code,
	p_state_code 			=> 	p_state_code,
	p_city_code 			=> 	p_city_code,
	p_postal_code_from		=>	p_postal_code_from,
	p_postal_code_to		=>	p_postal_code_to,
	p_region_type			=> 	l_region_type,
	p_interface_flag		=>	p_interface_flag,
	x_region_id			=>	x_region_id_non_tl);

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name, 'got non-tl id '||x_region_id_non_tl);
	WSH_DEBUG_SV.logmsg(l_module_name, 'for region type '||l_region_type);
     END IF;

      IF (x_region_id_non_tl = -1) THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 return;
      END IF;

      Get_Region_Id_Codes_Only (
	p_country_code 			=> 	p_country_code,
	p_country_region_code 		=> 	p_country_region_code,
	p_state_code 			=> 	p_state_code,
	p_city_code 			=> 	p_city_code,
	p_postal_code_from		=>	p_postal_code_from,
	p_postal_code_to		=>	p_postal_code_to,
	p_region_type			=> 	l_region_type,
	p_interface_flag		=>	p_interface_flag,
	p_language_code                 =>      p_lang_code,
	x_region_id			=>	x_region_id_with_tl);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'checking tl id '||x_region_id_with_tl);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Get_Region_Id_Codes_Only;


  --
  -- Function: Match_Location_Region
  --
  -- Purpose:   Returns region id for region found when matching location
  -- 		to region
  --

  FUNCTION Match_Location_Region (
	p_country 			IN 	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code			IN 	VARCHAR2,
	p_insert_flag			IN	VARCHAR2) RETURN NUMBER IS

  l_region_info region_rec;
  l_region_type NUMBER := 0;
  l_region_rec1 region_rec;
  l_region_rec2 region_rec;
  l_country l_region_info.country%TYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCH_LOCATION_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE',P_POSTAL_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_INSERT_FLAG',P_INSERT_FLAG);
     END IF;
     --
     l_region_info.country_code := p_country_code;
     l_region_info.country := p_country;

     -- this is done so that both country and country_code are not sent at same time
     IF (p_country_code IS NULL) THEN
	l_country := p_country;
     END IF;

     --Bug 6670302 Removed the restriction on length of state and city
     l_region_info.state := p_state;
     l_region_info.city := p_city;


     l_region_info.postal_code_from := p_postal_code;
     l_region_info.postal_code_to := p_postal_code;

     IF (p_postal_code IS NOT NULL) THEN
	l_region_type := 3;
     ELSIF (p_city IS NOT NULL) THEN
	l_region_type := 2;
     ELSIF (p_state IS NOT NULL) THEN
	l_region_type := 1;
     END IF;

     Get_Region_Info (
	   p_country 			=> 	l_country,
	   p_country_region 		=> 	l_region_info.country_region,
	   p_state 			=> 	l_region_info.state,
	   p_city 			=> 	l_region_info.city,
	   p_postal_code_from 		=> 	l_region_info.postal_code_from,
	   p_postal_code_to 		=> 	l_region_info.postal_code_to,
	   p_zone			=>	null,
	   --p_lang_code			=>	null,
	   p_lang_code			=>	USERENV('LANG'),
	   p_country_code 		=> 	l_region_info.country_code,
	   p_country_region_code 	=> 	l_region_info.country_region_code,
	   p_state_code 		=> 	l_region_info.state_code,
	   p_city_code 			=> 	l_region_info.city_code,
	   p_region_type		=> 	l_region_type,
	   p_interface_flag		=>	'N',
	   x_region_info		=>	l_region_rec1);

     IF (l_region_rec1.region_id = -1) THEN

	IF (p_insert_flag = 'Y') THEN

           Get_Region_Info (
	   p_country 			=> 	l_region_info.country,
	   p_country_region 		=> 	l_region_info.country_region,
	   p_state 			=> 	l_region_info.state,
	   p_city 			=> 	l_region_info.city,
	   p_postal_code_from 		=> 	l_region_info.postal_code_from,
	   p_postal_code_to 		=> 	l_region_info.postal_code_to,
	   p_zone			=>	null,
	   --p_lang_code			=>	null,
       p_lang_code			=>	USERENV('LANG'),
	   p_country_code 		=> 	l_region_info.country_code,
	   p_country_region_code 	=> 	l_region_info.country_region_code,
	   p_state_code 		=> 	l_region_info.state_code,
	   p_city_code 			=> 	l_region_info.city_code,
	   p_region_type		=> 	l_region_type,
	   p_interface_flag		=>	'Y',
	   x_region_info		=>	l_region_rec2);

       IF (l_region_rec2.region_id = -1) THEN

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,nvl(l_region_info.country,l_region_info.country_code)||'	'||nvl(l_region_info.state,l_region_info.state_code)||'	'||nvl(l_region_info.city,l_region_info.city_code)||'	'||l_region_info.postal_code_from);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.ADD_REGION',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
              --
          Wsh_Regions_Pkg.Add_Region(
	      p_country_code		=>	l_region_info.country_code,
	      p_country_region_code	=>	l_region_info.country_region_code,
	      p_state_code		=>	l_region_info.state_code,
	      p_city_code		=>	l_region_info.city_code,
	      p_port_flag		=>	null,
	      p_airport_flag		=>	null,
	      p_road_terminal_flag	=>	null,
	      p_rail_terminal_flag	=>	null,
	      p_longitude		=>	null,
	      p_latitude		=>	null,
	      p_timezone		=>	null,
	      p_continent		=>	null,
	      p_country			=>	l_region_info.country,
	      p_country_region		=>	nvl(l_region_info.country_region, l_region_info.country_region_code),
	      p_state			=>	nvl(l_region_info.state,l_region_info.state_code),
	      p_city			=>	nvl(l_region_info.city,l_region_info.city_code),
	      p_alternate_name		=>	null,
	      p_county			=>	null,
	      p_postal_code_from	=>	l_region_info.postal_code_from,
	      p_postal_code_to		=>	l_region_info.postal_code_to,
	      p_lang_code		=>	nvl(userenv('LANG'),'US'),
	      p_region_type		=>	l_region_type,
	      p_parent_region_id	=>	null,
	      p_interface_flag		=>	'Y',
	      p_tl_only_flag		=>	'N',
	      p_region_id		=>	null,
	      x_region_id		=>	l_region_info.region_id);

       END IF;

	END IF;

	IF (l_region_rec1.region_id = -1 AND p_insert_flag <> 'Y') THEN
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,nvl(l_region_info.country,l_region_info.country_code)
              ||'			'
              ||nvl(l_region_info.state,l_region_info.state_code)
              ||'			'
              ||nvl(l_region_info.city,l_region_info.city_code)
              ||'				'
              ||l_region_info.postal_code_from);
           END IF;
        END IF;

        IF (l_region_rec2.region_id is not null) then
 	   l_region_rec1.region_id := l_region_rec2.region_id;
	END IF;

     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN l_region_rec1.region_id;

  END Match_Location_Region;

 --
 -- PROCEDURE : Map_Location_Region_Child
 --
 -- PURPOSE   : Child program to Location to Region Mapping Concurrent request.
 --             Calls appropriate procedure depending upon value of mode parameter.
 --             New API added as a part of ECO - 4740786

 PROCEDURE Map_Location_Region_Child(
    p_errbuf           OUT NOCOPY   VARCHAR2,
    p_retcode          OUT NOCOPY   NUMBER,
    p_mode             IN   VARCHAR2,
    p_location_type    IN   VARCHAR2,
    p_from_value       IN   NUMBER,
    p_to_value         IN   NUMBER,
    p_start_date       IN   VARCHAR2,
    p_end_date         IN   VARCHAR2,
    p_insert_flag      IN   VARCHAR2) IS


  CURSOR get_region_info(l_processing_date DATE) IS
  SELECT nvl(country, country_code) country,
	 nvl(state,state_code) state,
	 nvl(city,city_code) city,
	 postal_code_from
  FROM wsh_regions_interface r, wsh_regions_tl_interface t
  WHERE r.region_id = t.region_id and r.creation_date >= l_processing_date
  ORDER BY country, state, city, postal_code_from;

  CURSOR get_loc_info (l_start_date DATE, l_end_date DATE) IS
  SELECT t.territory_short_name, t.territory_code, nvl(l.state, l.province) state, l.city, l.postal_code
  FROM hz_locations l, fnd_territories_tl t
  WHERE t.territory_code = l.country and
	t.language = userenv('LANG') and
	l.last_update_date >= nvl(l_start_date, l.last_update_date) and
	l.last_update_date < nvl(l_end_date, l.last_update_date+1);

l_worker_min_tab         WSH_UTIL_CORE.id_tab_type;
l_worker_max_tab         WSH_UTIL_CORE.id_tab_type;
l_new_request_id     NUMBER := 0;
i                    NUMBER := 0;
l_worker_min         NUMBER := 0;
l_worker_max         NUMBER := 0;
l_min                NUMBER := 0;
l_max                NUMBER := 0;
l_sqlcode            NUMBER;
l_sqlerr             VARCHAR2(2000);
l_return_status      VARCHAR2(10);
l_completion_status  VARCHAR2(30);
l_temp               BOOLEAN;
l_retcode            NUMBER;
l_errbuf             VARCHAR2(2000);
l_log_level          NUMBER;
l_num_of_instances   NUMBER;
l_location_type      VARCHAR2(10);
l_region_id   NUMBER;
l_num         NUMBER;-- := p_number_processed;
l_count       NUMBER := 0;
l_processing_date DATE;
l_start_date            DATE;
l_end_date              DATE;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_LOCATION_REGION_CHILD';

 BEGIN
    WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

--bug 4775798
--changed WSH_UTIL_CORE.println to WSH_DEBUG_SV.log
    IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
         WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
    END IF;

    IF p_location_type IS NULL THEN
        l_location_type := 'BOTH';
    ELSE
        l_location_type := p_location_type;
    END IF;

    l_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
    l_end_date   := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS') +1;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_START_DATE',l_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'l_END_DATE',l_END_DATE);
    END IF;

    IF p_mode = 'CREATE' THEN

        l_processing_date := sysdate;
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name,'Processing locations. Following locations could not be mapped to existing regions.');
        END IF;

        IF (p_insert_flag = 'Y') THEN
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'These have been inserted in the regions interface tables');
           END IF;

        ELSE
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'---------------------------------------------------------------');
               wsh_debug_sv.logmsg(l_module_name,'Country              State               City                Postal Code');
               wsh_debug_sv.logmsg(l_module_name,'-------              -----               ----                ------ ----');
          END IF;

        END IF;

        FOR loc IN get_loc_info (l_start_date, l_end_date) LOOP

           --
           -- Debug Statements
           --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.MATCH_LOCATION_REGION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
               --
            l_region_id := Wsh_Regions_Search_Pkg.Match_Location_Region (
                p_country       =>      loc.territory_short_name,
                p_country_code  =>      loc.territory_code,
                p_state         =>      loc.state,
                p_city          =>      loc.city,
                p_postal_code   =>      loc.postal_code,
                p_insert_flag   =>      p_insert_flag);

            IF (l_region_id = -1) THEN
                l_count := l_count + 1;
            END IF;

        END LOOP;

        IF (p_insert_flag = 'Y') THEN
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'Total number of interfaced regions '||l_count);

               wsh_debug_sv.logmsg(l_module_name,'---------------------------------------------------------------');
               wsh_debug_sv.logmsg(l_module_name,'Country              State               City                Postal Code');
               wsh_debug_sv.logmsg(l_module_name,'-------              -----               ----                ------ ----');
               FOR loc IN get_region_info(l_processing_date) LOOP
                  wsh_debug_sv.logmsg(l_module_name,loc.country||'         '||loc.state||'         '||loc.city||'              '||loc.postal_code_from);
               END LOOP;
            END IF;
        END IF;

    ELSIF p_mode = 'MAP' THEN

        WSH_MAP_LOCATION_REGION_PKG.Mapping_Regions_Main (
            p_location_type    => l_location_type,
            p_from_location    => p_from_value,
            p_to_location      => p_to_value,
            p_start_date       => p_start_date,
            p_end_date         => p_end_date,
            p_insert_flag      => FALSE,
            x_return_status    => l_return_status,
            x_sqlcode          => l_sqlcode,
            x_sqlerr           => l_sqlerr);


       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from Mapping_Regions_Main : '|| l_return_status);
       END IF;

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS  THEN

          WSH_UTIL_CORE.printmsg('Failed in Procedure Mapping_Regions_Main');
          WSH_UTIL_CORE.printmsg(l_sqlcode);
          WSH_UTIL_CORE.printmsg(l_sqlerr);
          l_completion_status := 'ERROR';
        END IF;
   END IF;
   l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'ERRBUF',p_errbuf);
      WSH_DEBUG_SV.log(l_module_name,'RETCODE',p_retcode);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

 EXCEPTION

     WHEN No_Data_Found THEN

       WSH_UTIL_CORE.printmsg('No matching records for the entered parameters');
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
       END IF;

     WHEN others THEN
       l_sqlcode := SQLCODE;
       l_sqlerr  := SQLERRM;

       WSH_UTIL_CORE.printmsg('Exception occurred in Map_Location_Region_Child Program');
       WSH_UTIL_CORE.printmsg('SQLCODE : ' || l_sqlcode);
       WSH_UTIL_CORE.printmsg('SQLERRM : '  || l_sqlerr);

       l_completion_status := 'ERROR';
       l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       p_errbuf := 'Exception occurred in Map_Location_Region_Child Program';
       p_retcode := '2';


       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

 END Map_Location_Region_Child;

 --
 -- Procedure: Get_Child_Requests_Status
 --
 -- Purpose:   Obtains the completion status of all the child requests
 --             and sets x_completion_status accordingly
 --

 PROCEDURE Get_Child_Requests_Status
 (
    x_completion_status OUT NOCOPY    VARCHAR2
 )  IS

    CURSOR c_requests (p_parent_request_id NUMBER) IS
      SELECT request_id
      FROM   FND_CONCURRENT_REQUESTS
      WHERE  parent_request_id = p_parent_request_id
      AND    NVL(is_sub_request, 'N') = 'Y';

    l_child_req_ids         WSH_UTIL_CORE.Id_Tab_Type;
    l_this_request          NUMBER;
    l_errors                NUMBER := 0;
    l_warnings              NUMBER := 0;
    l_phase                 VARCHAR2(100);
    l_status                VARCHAR2(100);
    l_dev_phase             VARCHAR2(100);
    l_dev_status            VARCHAR2(100);
    l_dummy                 BOOLEAN;
    j                       NUMBER;
    l_message               VARCHAR2(2000);
    l_completion_status     VARCHAR2(30);
    l_debug_on              BOOLEAN;
    l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CHILD_REQUESTS_STATUS';
  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;

    FND_PROFILE.Get('CONC_REQUEST_ID', l_this_request);

    OPEN  c_requests(l_this_request);
    FETCH c_requests BULK COLLECT INTO l_child_req_ids;
    CLOSE c_requests;
    l_errors   := 0;
    l_warnings := 0;
    j := l_child_req_ids.FIRST;
    WHILE j IS NOT NULL LOOP
       l_dev_status := NULL;
       l_dummy := FND_CONCURRENT.get_request_status(
                                 request_id => l_child_req_ids(j),
                                 phase      => l_phase,
                                 status     => l_status,
                                 dev_phase  => l_dev_phase,
                                 dev_status => l_dev_status,
                                 message    => l_message);

       IF l_dev_status = 'WARNING' THEN
          l_warnings:= l_warnings + 1;
       ELSIF l_dev_status <> 'NORMAL' THEN
          l_errors := l_errors + 1;
       END IF;

       FND_MESSAGE.SET_NAME('WSH','WSH_CHILD_REQ_STATUS');
       FND_MESSAGE.SET_TOKEN('REQ_ID', to_char(l_child_req_ids(j)));
       FND_MESSAGE.SET_TOKEN('STATUS', l_status);
       WSH_UTIL_CORE.PrintMsg(FND_MESSAGE.GET);
       j := l_child_req_ids.NEXT(j);
    END LOOP;

    IF l_errors = 0  AND l_warnings = 0 THEN
       l_completion_status := 'NORMAL';
    ELSIF (l_errors > 0 ) THEN
       l_completion_status := 'ERROR';
    ELSE
       l_completion_status := 'WARNING';
    END IF;
    x_completion_status := l_completion_status;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
 EXCEPTION
    WHEN others THEN
        WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Get_Child_Requests_Status');
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;

 END Get_Child_Requests_Status;

  --
  -- Procedure: Process_All_Locations
  --
  -- Purpose:   Calls Process_All_Locations with l_location_type='BOTH'
  --
  --

  PROCEDURE Process_All_Locations (
    p_dummy1            IN  VARCHAR2,
    p_dummy2            IN  VARCHAR2,
    p_mode              IN  VARCHAR2 default g_mode,
    p_num_of_instances  IN  NUMBER,
    p_insert_flag       IN  VARCHAR2,
    p_start_date        IN  VARCHAR2,
    p_end_date          IN  VARCHAR2) IS

    l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_ALL_LOCATIONS';
    l_debug_on              BOOLEAN;

    BEGIN

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;

            --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_DUMMY1',P_DUMMY1);
            WSH_DEBUG_SV.log(l_module_name,'P_DUMMY2',P_DUMMY2);
            WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
            WSH_DEBUG_SV.log(l_module_name,'P_NUM_OF_INSTANCES',p_num_of_instances);
            WSH_DEBUG_SV.log(l_module_name,'P_INSERT_FLAG',p_insert_flag);
            WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
            WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING PROCESS_ALL_LOCATIONS API with location_type=BOTH' ,WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_REGIONS_SEARCH_PKG.Process_All_Locations(
           p_dummy1             => NULL,
           p_dummy2             => NULL,
           p_mode               => p_mode,
           p_insert_flag        => p_insert_flag,
           p_location_type      => 'BOTH',
           p_start_date         => p_start_date,
           p_end_date           => p_end_date,
           p_num_of_instances   => p_num_of_instances
           );

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN others THEN
          WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Process_All_Locations');
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
          END IF;

    END Process_All_Locations;


  --
  -- Procedure: Process_All_Locations
  --
  -- Purpose:   Overloaded procedure introduced as a part of ECO - 4740786.
  --            Returns region id for region found when matching location
  --            to region
  --

  PROCEDURE Process_All_Locations (
    p_dummy1            IN  VARCHAR2,
    p_dummy2            IN  VARCHAR2,
    p_mode              IN  VARCHAR2 default g_mode,
    p_num_of_instances  IN  NUMBER,
    p_insert_flag       IN  VARCHAR2,
    p_location_type     IN  VARCHAR2,
    p_start_date        IN  VARCHAR2,
    p_end_date          IN  VARCHAR2
    ) IS

--
l_debug_on           BOOLEAN;
l_return_status      VARCHAR2(10);
l_completion_status  VARCHAR2(30);

l_worker_min_tab     WSH_UTIL_CORE.id_tab_type;
l_worker_max_tab     WSH_UTIL_CORE.id_tab_type;
l_new_request_id     NUMBER := 0;
i                    NUMBER := 0;
l_temp               BOOLEAN;
l_retcode            NUMBER;
l_errbuf             VARCHAR2(2000);
l_num_of_instances   NUMBER;
l_req_data           VARCHAR2(50);
l_start_date         DATE;
l_end_date           DATE;
l_import_start_date  DATE;
l_start_date1        VARCHAR2(50);
l_end_date1          VARCHAR2(50);

--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_ALL_LOCATIONS1';
--
  BEGIN

    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;


    WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
    l_completion_status := 'NORMAL';
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'P_DUMMY1',P_DUMMY1);
        WSH_DEBUG_SV.log(l_module_name,'P_DUMMY2',P_DUMMY2);
        WSH_DEBUG_SV.log(l_module_name,'P_INSERT_FLAG',P_INSERT_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
        WSH_DEBUG_SV.log(l_module_name,'P_NUM_OF_INSTANCES',p_num_of_instances);
    END IF;
    --
    l_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
    l_end_date   := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS') +1;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_START_DATE',l_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'l_END_DATE',l_END_DATE);
    END IF;

    IF p_num_of_instances is null or p_num_of_instances = 0 then
        l_num_of_instances := 1;
    ELSE
        l_num_of_instances := p_num_of_instances;
    END IF;

    -- ECO - 4740786 - based on the mode, obtain sets of records to be processed by the workers based on num_instances
    -- parameter
    IF p_mode = 'CREATE' THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Location_Region_Child',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Map_Location_Region_Child (
          p_errbuf            => l_errbuf,
          p_retcode           => l_retcode,
          p_mode              => p_mode,
          p_location_type     => p_location_type,
          p_from_value        => NULL,
          p_to_value          => NULL,
          p_start_date        => p_start_date,
          p_end_date          => p_end_date,
          p_insert_flag       => p_insert_flag);

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Return Code from Map_Location_Region_Child : '||l_retcode);
        END IF;

        IF l_retcode = '2' THEN
            l_completion_status := 'ERROR';
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_retcode = '1' THEN
            l_completion_status := 'WARNING';
            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
    --}
    ELSIF p_mode = 'MAP' THEN
    --{
       l_req_data := fnd_conc_global.request_data;

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  ' l_req_data', l_req_data);
       END IF;

       IF l_req_data IS NOT NULL THEN
           l_import_start_date := to_date(SUBSTR(l_req_data, INSTR(l_req_data,':',1,1)+1, LENGTH(l_req_data)),'YYYY/MM/DD HH24:MI:SS');
           l_req_data          := SUBSTR(l_req_data, 1,1);
       END IF;


       IF l_import_start_date IS NOT NULL THEN
            l_start_date1 := to_char(l_import_start_date,'YYYY/MM/DD HH24:MI:SS');
            l_end_date1   := to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');
       ELSE
            l_start_date1 := p_start_date;
            l_end_date1   := p_end_date;
       END IF;

       IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'l_req_data 1', l_req_data);
           wsh_debug_sv.log(l_module_name, 'l_start_date1', l_start_date1);
           wsh_debug_sv.log(l_module_name, 'l_end_date1', l_end_date1);
       END IF;

       IF l_req_data IS NULL OR l_req_data = '1' THEN
       --{
            IF p_location_type = 'EXTERNAL'  THEN
            --{
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is External');
                END IF;

                EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                                   FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                            FROM   HZ_LOCATIONS
                                            WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                            AND    last_update_date < nvl(:end_date, last_update_date+1)
                                          )
                                   GROUP BY WORKER'
                BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
                USING l_num_of_instances, l_start_date, l_end_date;

            ELSIF p_location_type = 'INTERNAL'  THEN

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Internal');
                END IF;

                 EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                                   FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                            FROM   HR_LOCATIONS_ALL
                                            WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                            AND    last_update_date < nvl(:end_date, last_update_date+1)
                                          )
                                   GROUP BY WORKER'
                BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
                USING l_num_of_instances, l_start_date, l_end_date;

            ELSIF p_location_type = 'BOTH'  THEN

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Both');
                END IF;

                EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                                   FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                            FROM   WSH_HR_LOCATIONS_V
                                            WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                            AND    last_update_date < nvl(:end_date, last_update_date+1)
                                          )
                                   GROUP BY WORKER'
                BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
                USING l_num_of_instances, l_start_date, l_end_date;

            --}
            END IF;

            IF l_worker_min_tab.count <>0 and p_num_of_instances > 0 THEN
            --{
                FOR i in 1..l_worker_min_tab.count
                 LOOP

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Value of i : '|| i ||' l_worker_min : '||l_worker_min_tab(i)||
                                                      ' l_worker_max : '||l_worker_max_tab(i));
                    END IF;


                    l_new_request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                                           application   =>  'WSH',
                                           program       =>  'WSHLRMCD',
                                           description   =>  'Location To Region Mapping - Child '||to_char(i),
                                           start_time    =>   NULL,
                                           sub_request   =>   TRUE,
                                           argument1     =>   p_mode,
                                           argument2     =>   p_location_type,
                                           argument3     =>   l_worker_min_tab(i),
                                           argument4     =>   l_worker_max_tab(i),
                                           argument5     =>   l_start_date1,
                                           argument6     =>   l_end_date1,
                                           argument7     =>   p_insert_flag);

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'Child request ID ', l_new_request_id);
                    END IF;

                    IF l_new_request_id = 0 THEN
                        IF l_debug_on THEN
                            WSH_debug_sv.logmsg(l_module_name,'Error Submitting concurrent request for worker : '||i);
                        END IF;
                        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    END IF;

                  END LOOP;
                  FND_CONC_GLOBAL.Set_Req_Globals ( Conc_Status => 'PAUSED', Request_Data => to_char(2) );
            --}
            ELSIF l_worker_min_tab.count <>0 AND nvl(p_num_of_instances,0) = 0 THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Location_Region_Child',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                Map_Location_Region_Child (
                  p_errbuf            => l_errbuf,
                  p_retcode           => l_retcode,
                  p_mode              => p_mode,
                  p_location_type     => p_location_type,
                  p_from_value        => l_worker_min_tab(1),
                  p_to_value          => l_worker_max_tab(1),
                  p_start_date        => l_start_date1,
                  p_end_date          => l_end_date1,
                  p_insert_flag       => p_insert_flag);

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Return Code from Map_Location_Region_Child : '||l_retcode);
                END IF;

                IF l_retcode = '2' THEN
                    l_completion_status := 'ERROR';
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                ELSIF l_retcode = '1' THEN
                    l_completion_status := 'WARNING';
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                END IF;
           --}
           END IF;
      --}
      ELSE
        get_child_requests_status(x_completion_status =>  l_completion_status);
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      END IF;
    --}
    END IF;

    IF l_completion_status = 'NORMAL' THEN
       l_errbuf := 'Location To Region Mapping Program completed successfully';
       l_retcode := '0';
    ELSIF l_completion_status = 'WARNING' THEN
       l_errbuf := 'Location To Region Mapping Program is completed with warning';
       l_retcode := '1';
    ELSIF l_completion_status = 'ERROR' THEN
       l_errbuf := 'Location To Region Mapping Program is completed with error';
       l_retcode := '2';
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'ERRBUF', l_errbuf);
      WSH_DEBUG_SV.log(l_module_name,'RETCODE',l_retcode);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    EXCEPTION
        WHEN others THEN
          WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Process_All_Locations');
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
          END IF;

 END Process_All_Locations;

--
-- PROCEDURE : refresh_cache
--
-- PURPOSE   : Clears regions cache g_regions_info_tab if session id changes
--

 PROCEDURE refresh_cache (
             p_country_code     IN VARCHAR2,
             x_return_status    OUT  NOCOPY  VARCHAR2 )
 IS

    l_session_id        NUMBER  := 0;
    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'refresh_cache';

 BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --

    l_session_id := userenv('sessionid');

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name,'g_regions_info_tab count : '||g_regions_info_tab.COUNT);
       wsh_debug_sv.logmsg(l_module_name,'g_session_id : '||g_session_id||' Current session id : '||l_session_id);
    END IF;

    IF g_session_id IS NULL OR l_session_id <> g_session_id
                OR g_country_code <> p_country_code OR g_regions_info_tab.count > 5000 THEN
       g_regions_info_tab := g_emp_reg_info_tab  ;  --Bug 7313093 Instead of deleting assigning empty table
       g_country_code   := p_country_code;
       g_session_id     := l_session_id;

       IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name,'Regions Cache cleared');
       END IF;

    END IF;

    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --

 EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.refresh_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
 END refresh_cache;


  --
  -- Procedure: Get_All_Region_Matches
  --
  -- Purpose:   Obtains all information for a region, and its parents
  -- 		and the zones it belongs to
  --

  PROCEDURE Get_All_Region_Matches (
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
    p_location_id                   IN      NUMBER,
    p_zone_flag                     IN      VARCHAR2,
	p_more_matches                  IN      BOOLEAN  DEFAULT FALSE,
	x_status			OUT NOCOPY 	NUMBER,
	x_regions			OUT NOCOPY 	region_table
	) IS


  CURSOR region_details(l_region_id NUMBER,l_location_id NUMBER,l_lang_code IN VARCHAR2) IS
  SELECT wr.region_id,
	 wr.region_type,
	 wrt.country,
	 wrt.country_region,
	 wrt.state,
	 wrt.city,
	 wrt.postal_code_from,
	 wrt.postal_code_to,
	 wrt.zone,
	 wr.zone_level,
	 wr.country_code,
	 wr.country_region_code,
	 wr.state_code,
	 wr.city_code,
         decode(loc.parent_region_flag,'Y','N','N','Y')
  FROM   wsh_regions wr,
         wsh_regions_tl wrt,
	 wsh_region_locations loc
  WHERE  wr.region_id = l_region_id  AND
         loc.location_id = l_location_id  AND
	 wr.region_id = loc.region_id    AND
	 wrt.region_id = wr.region_id  AND
	 wrt.language = nvl(l_lang_code,wrt.language);

  CURSOR zone_info(l_region_id NUMBER, l_lang_code IN VARCHAR2) IS
  SELECT distinct r.region_id,
	 r.region_type,
	 null,
	 null,
	 null,
	 null,
	 null,
	 null,
	 rt.zone,
	 r.zone_level,
	 null,
	 null,
	 null,
	 null,
         'N'
  FROM   wsh_regions r,
         wsh_regions_tl rt,
         wsh_zone_regions z
  WHERE  r.region_id = z.parent_region_id AND
	 z.region_id = l_region_id AND
	 r.region_type = 10  AND
	 rt.region_id = r.region_id  AND
	 rt.language = nvl(l_lang_code,rt.language);

  CURSOR Check_Location_Exists(c_location_id IN NUMBER,c_lang_code IN VARCHAR2) IS
  SELECT  'exists'
  FROM    wsh_region_locations wrl, wsh_regions_tl wrt,
          wsh_regions wr
  WHERE   wrl.region_id is not null
  AND     wrl.location_id = c_location_id
  AND     wrl.region_id = wrt.region_id
  AND     wrt.language = nvl(c_lang_code,wrt.language)
  AND     wrt.region_id = wr.region_id
  AND     rownum = 1;

  -- TODO
  -- get rid of wsh_hr_locations_v

  -- Bugfix 2877445
  -- Added NVL function to region_1
  -- region_1 : County
  -- region_2 : State
  -- region_3 : Province
  /*
  CURSOR get_location_data IS
  SELECT  country, nvl(region_2, region_3), town_or_city, postal_code
  FROM    wsh_hr_locations_v
  WHERE   location_id = p_location_id;
  */

  -- TODO
  -- check against definition of wsh_hr_locations_v
  CURSOR get_location_data(c_location_id IN NUMBER) IS
  SELECT  country, nvl(state, province), city, postal_code
  FROM    wsh_locations
  WHERE   wsh_location_id = c_location_id;


  j   NUMBER := 0;
  i   NUMBER := 0;
  cnt NUMBER := 0;
  cnt_region NUMBER := 0;
  l_region_info region_rec;
  l_region_rec1 region_rec;
  l_region_rec2 region_rec;
  l_region_rec3 region_rec;
  l_region_type NUMBER := 0;
  l_parent_offset NUMBER ;
  l_exists      VARCHAR2(10) := NULL;
  l_rgid_tab    WSH_UTIL_CORE.Id_Tab_Type;
  is_first BOOLEAN := true;
  l_regions region_table;
  l_return_status VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ALL_REGION_MATCHES';
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
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
       WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
       WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
       WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
       WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ZONE_FLAG',P_ZONE_FLAG);
   END IF;


    IF g_regions_info_tab.count = 0 THEN
        g_country_code := p_country_code;
    END IF;
   --
   refresh_cache( p_country_code  => p_country_code,
                  x_return_status => l_return_status);

 -- TODO
 -- should use p_location_id if passed in and should not
 -- search regions in that case

   IF p_location_id IS NOT NULL THEN
      OPEN Check_Location_Exists(p_location_id,p_lang_code);
      FETCH Check_Location_Exists INTO l_exists;
      CLOSE Check_Location_Exists;
   END IF;

   IF l_exists IS NOT NULL THEN
      /*
       SELECT wrl.region_id
       BULK COLLECT INTO l_rgid_tab
       FROM  wsh_region_locations wrl,wsh_regions_tl wrt,wsh_regions wr
       WHERE wrl.location_id = p_location_id
       AND   wrl.region_id is not null
       AND   wrl.region_id = wrt.region_id
       AND   wrt.language = nvl(p_lang_code,wrt.language)
       AND   wrt.region_id = wr.region_id
       ORDER BY wrl.region_type DESC;
     */

      Get_All_RegionId_Matches(
         p_location_id      => p_location_id,
         p_use_cache        => FALSE,
         p_lang_code        => p_lang_code,
         x_region_tab       => l_rgid_tab,
         x_return_status    => l_return_status);

       IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Number of regions found in wrl : ',l_rgid_tab.COUNT);
       END IF;
       --

       IF l_rgid_tab.COUNT > 0 THEN
         j := l_rgid_tab.FIRST;
         LOOP
           OPEN region_details(l_rgid_tab(j),p_location_id,p_lang_code);
            FETCH region_details INTO l_region_info;
           CLOSE region_details;

	   --
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_rgid_tab(j) : ',l_rgid_tab(j));
               WSH_DEBUG_SV.log(l_module_name,'l_region_info.region_id : ',l_region_info.region_id);
               WSH_DEBUG_SV.log(l_module_name,'l_region_info.region_type : ',l_region_info.region_type);
               WSH_DEBUG_SV.log(l_module_name,'cnt_region : ',cnt_region);
           END IF;
           --

           cnt_region :=  cnt_region + 1;
           x_regions(cnt_region) := l_region_info;

  	   -- for every region, find any zone it belongs in

           IF p_zone_flag = 'Y' THEN

                OPEN zone_info(l_region_info.region_id,p_lang_code);
                LOOP
                    FETCH zone_info INTO l_region_rec3;

                    EXIT WHEN zone_info%NOTFOUND;

                    IF (l_region_rec3.region_id > 0) THEN
                        cnt_region := cnt_region + 1;

                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name, ' fetching zone info of '||l_region_rec3.region_id);
                         WSH_DEBUG_SV.logmsg(l_module_name, ' inserting into region table at '||cnt_region);
                        END IF;

                        x_regions(cnt_region) := l_region_rec3;

                    END IF;

                    l_region_rec3.region_id := 0;

                END LOOP;

              CLOSE zone_info;

           END IF;

           EXIT WHEN j=l_rgid_tab.LAST;
           j := l_rgid_tab.NEXT(j);
         END LOOP;
      END IF;

   ELSE -- if l_exists is null
     l_region_rec2.country := p_country;
     l_region_rec2.country_code := p_country_code;
     l_region_rec2.state := p_state;
     l_region_rec2.state_code := p_state_code;
     l_region_rec2.city := p_city;
     l_region_rec2.city_code := p_city_code;
     l_region_rec2.country_region := p_country_region;
     l_region_rec2.country_region_code := p_country_region_code;
     l_region_rec2.postal_code_from := p_postal_code_from;
     l_region_rec2.postal_code_to := p_postal_code_to;

     IF (p_location_id is not null and p_country is null and p_country_code is null) THEN

        OPEN get_location_data(p_location_id);
        FETCH get_location_data INTO l_region_rec2.country_code, l_region_rec2.state, l_region_rec2.city, l_region_rec2.postal_code_from;

            l_region_rec2.postal_code_to := l_region_rec2.postal_code_from;

        CLOSE get_location_data;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, ' fetched location data city '||l_region_rec2.city||' country code '||l_region_rec2.country_code||'State '||l_region_rec2.state||' postal_code '||l_region_rec2.postal_code_from);
        END IF;

     END IF;

     -- TODO
     -- check that only one of country/state/city value
     -- OR code is passed always

     IF (length(l_region_rec2.country) <= 3 AND l_region_rec2.country_code IS NULL) THEN
        l_region_rec2.country_code := l_region_rec2.country;
        l_region_rec2.country := null;
     END IF;

     --Bug 6670302 Removed validations on the length of names of city and state

     IF (l_region_rec2.postal_code_from IS NOT NULL OR l_region_rec2.postal_code_to IS NOT NULL) THEN
        l_region_type := 3;
     ELSIF (l_region_rec2.city IS NOT NULL OR l_region_rec2.city_code IS NOT NULL) THEN
        l_region_type := 2;
     ELSIF (l_region_rec2.state IS NOT NULL OR l_region_rec2.state_code IS NOT NULL) THEN
        l_region_type := 1;
     END IF;

     LOOP
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, ' region type '||l_region_type);
            WSH_DEBUG_SV.logmsg(l_module_name, ' city: '||l_region_rec2.city||' code: '||l_region_rec2.city_code);
            WSH_DEBUG_SV.logmsg(l_module_name, ' state: '||l_region_rec2.state||' code: '||l_region_rec2.state_code);
            WSH_DEBUG_SV.logmsg(l_module_name, ' country: '||l_region_rec2.country||' code: '||l_region_rec2.country_code);
       END IF;

       cnt := cnt + 1;

       -- Debug Statements
       --
       IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name, 'number in loop '||cnt);
       END IF;

       -- Bugfix 2877445 if region type is postal code then dont search with
       -- city and state information. This is under the assumption that postal
       -- codes are unique in a country.

       -- Bug 4722963
       -- If key exists region info in cache, fetch regions info from there
       -- otherwise call get_region_info API.

       IF (l_region_type = 3) then

            Get_Region_Info (
               p_country            =>  l_region_rec2.country,
               p_country_region     =>  l_region_rec2.country_region,
               p_state              =>  null,
               p_city               =>  null,
               p_postal_code_from   =>  l_region_rec2.postal_code_from,
               p_postal_code_to     =>  l_region_rec2.postal_code_to,
               p_zone               =>  null,
               p_lang_code          =>  p_lang_code,
               p_country_code       =>  l_region_rec2.country_code,
               p_country_region_code=>  l_region_rec2.country_region_code,
               p_state_code         =>  null,
               p_city_code          =>  null,
               p_region_type        =>  l_region_type,
               p_interface_flag     =>  'N',
               x_regions            =>  l_regions);

       ELSE

            Get_Region_Info (
               p_country 			=> 	l_region_rec2.country,
               p_country_region 		=> 	l_region_rec2.country_region,
               p_state 			=> 	l_region_rec2.state,
               p_city 			=> 	l_region_rec2.city,
               p_postal_code_from 		=> 	l_region_rec2.postal_code_from,
               p_postal_code_to 		=> 	l_region_rec2.postal_code_to,
               p_zone			=>	null,
               p_lang_code			=>	p_lang_code,
               p_country_code 		=> 	l_region_rec2.country_code,
               p_country_region_code 	=> 	l_region_rec2.country_region_code,
               p_state_code 		=> 	l_region_rec2.state_code,
               p_city_code 			=> 	l_region_rec2.city_code,
               p_region_type		=> 	l_region_type,
               p_interface_flag		=>	'N',
               x_regions		    =>   l_regions);


        END IF;

        l_region_rec1 := l_regions(0);
        l_parent_offset := 1;

         -- TODO
         -- Will call get_region_info for all address components always

         IF (l_region_type > 0) THEN

            -- figure out the parent region offset
            -- IF (l_region_type > 0) THEN

              IF (l_region_type = 2 AND
                      l_region_rec2.state IS NULL AND
                      l_region_rec2.state_code IS NULL) THEN
                      l_parent_offset := l_parent_offset + 1;

              ELSE
                IF (l_region_type = 3 AND
                l_region_rec2.city IS NULL AND
                l_region_rec2.city_code IS NULL) THEN
                    l_parent_offset := l_parent_offset + 1;

                    IF (l_region_rec2.state IS NULL AND
                       l_region_rec2.state_code IS NULL) THEN
                       l_parent_offset := l_parent_offset + 1;
                    END IF;

                 END IF;

              END IF;

            -- END IF;

            IF (l_region_type = 3) THEN
                l_region_rec2.postal_code_from := null;
                l_region_rec2.postal_code_to := null;
            ELSIF (l_region_type = 2) THEN
                l_region_rec2.city := null;
                l_region_rec2.city_code := null;
            ELSIF (l_region_type = 1) THEN
                l_region_rec2.state := null;
                l_region_rec2.state_code := null;
            END IF;

                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, ' parent offset '||l_parent_offset);
                END IF;

         END IF;

        l_region_type := l_region_type - l_parent_offset;

         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'got region id '||l_region_rec1.region_id);
         END IF;

         IF l_region_rec1.region_id > 0 THEN

           cnt_region := cnt_region + 1;
           -- Debug Statements
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, ' Using region info of '||l_region_rec1.region_id);
             WSH_DEBUG_SV.logmsg(l_module_name, ' inserting into region table at '||cnt_region);
           END IF;

           IF  is_first THEN
            l_region_rec1.is_input_type := 'Y'; -- Record is fetched based on the exact input match.

            IF(l_regions.count > 1 AND p_more_matches) THEN

              -- Populating the output table x_regions such that the index starts from '1' not from '0'.
              FOR  i  IN  l_regions.FIRST.. l_regions.LAST
                  LOOP
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, ' Using region info of '||l_regions(i).region_id);
                       WSH_DEBUG_SV.logmsg(l_module_name, ' inserting into region table at '||cnt_region);
                    END IF;
                    l_regions(i).is_input_type := 'Y';
                    x_regions(cnt_region) := l_regions(i);
                    cnt_region := cnt_region + 1;
              END LOOP;

              IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
              END IF;

              RETURN;
            END IF;

       END IF;
   	   x_regions(cnt_region) := l_region_rec1;

  	   -- for every region, find any zone it belongs in
       IF p_zone_flag = 'Y' THEN

  	    OPEN zone_info(l_region_rec1.region_id,p_lang_code);

        LOOP
            FETCH zone_info INTO l_region_rec3;

            EXIT WHEN zone_info%NOTFOUND;

                 IF (l_region_rec3.region_id > 0) THEN
                    cnt_region := cnt_region + 1;

                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, ' fetching zone info of '||l_region_rec3.region_id);
                        WSH_DEBUG_SV.logmsg(l_module_name, ' inserting into region table at '||cnt_region);
                    END IF;

                    x_regions(cnt_region) := l_region_rec3;

                 END IF;

                 l_region_rec3.region_id := 0;

            END LOOP;

            CLOSE zone_info;

           END IF;

         END IF;

         -- TODO
         -- Will call get_region_info for all address components always
        IF (l_region_type < 0) THEN
	        EXIT;
        END IF;
         is_first := false;
      END LOOP;

   END IF;  -- l_exists is not null

   IF (x_regions.COUNT = 0) THEN
	   x_status := 1;
   ELSE
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, ' x_regions.COUNT '||x_regions.COUNT);
       END IF;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--Bug 4775798
EXCEPTION
  WHEN OTHERS THEN
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      ELSE
        WSH_UTIL_CORE.printmsg('Unexpected error has occured in WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches');
        WSH_UTIL_CORE.printmsg(SQLERRM);
      END IF;
END Get_All_Region_Matches;


--
-- Procedure: Get_All_RegionId_Matches
--
-- Purpose  : The API derives Region id for an input location,
--	      using table WSH_REGION_LOCATIONS
--	      Cache is used for storing and retriving location region mappings.
--	      when p_use_cache is FALSE

PROCEDURE Get_All_RegionId_Matches(
	 p_location_id		IN	    NUMBER,
	 p_use_cache		IN	    BOOLEAN	DEFAULT FALSE,
	 p_lang_code		IN	    VARCHAR2,
	 x_region_tab		OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
	 x_return_status        OUT NOCOPY  VARCHAR2) IS


  CURSOR c_get_all_region_id(l_location_id IN NUMBER, l_lang_code IN VARCHAR2) IS
  SELECT wrl.region_id
  FROM  wsh_region_locations wrl,wsh_regions_tl wrt,wsh_regions wr
  WHERE wrl.location_id = l_location_id
  AND   wrl.region_id is not null
  AND   wrl.region_id = wrt.region_id
  AND   wrt.language = nvl(l_lang_code,wrt.language)
  AND   wrt.region_id = wr.region_id
  ORDER BY wrl.region_type DESC;

  --
  l_region_id_tab	WSH_UTIL_CORE.Id_Tab_Type;
  itr			NUMBER;
  l_region_id_string	VARCHAR2(32767);
  --

  l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_All_RegionId_Matches';
  l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_return_status	VARCHAR2(1);

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
  END IF;

  IF (p_use_cache)  and (p_location_id < g_cache_max_size) THEN

     IF (g_location_region_tab.EXISTS(p_location_id)) THEN


        WSH_UTIL_CORE.get_idtab_from_string(
            p_string	 => g_location_region_tab(p_location_id),
            x_id_tab	 => l_region_id_tab,
            x_return_status  => l_return_status);

        itr := l_region_id_tab.FIRST;

        IF (l_region_id_tab(itr)<>-1) THEN
           x_region_tab := l_region_id_tab;
        END IF;
	    IF l_debug_on THEN
	        wsh_debug_sv.pop(l_module_name);
        END IF;
	    RETURN;
     END IF;
  END IF;

  --Location not present in the cache or p_use_cache is false.
  --Use cursor to get details.

  OPEN  c_get_all_region_id(p_location_id,p_lang_code);
  FETCH c_get_all_region_id BULK COLLECT INTO l_region_id_tab;
  CLOSE c_get_all_region_id;

  x_region_tab := l_region_id_tab;
  --
  -- If p_use_cache is True then add to  g_location_region_tab
  -- Return l_region_id_tab.
  --

  IF (p_use_cache) and (p_location_id < g_cache_max_size) THEN

	itr := l_region_id_tab.FIRST;

	IF (itr ) IS NULL THEN
          -- Table contains no value,Set l_region_id_string to -1
          -- Do not return l_region_id_tab;
	     l_region_id_string := '-1';

	ELSE
	  -- Return l_region_id_tab
          WSH_UTIL_CORE.get_string_from_idtab(
		p_id_tab	 => l_region_id_tab,
		x_string	 => l_region_id_string,
		x_return_status  => l_return_status);
	END IF;
	 g_location_region_tab(p_location_id) := l_region_id_string;
  END IF;

  IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
WHEN others THEN
      IF c_get_all_region_id%ISOPEN THEN
         CLOSE c_get_all_region_id;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
       --Bug 4775798
	ELSE
        WSH_UTIL_CORE.printmsg('Unexpected error has occured in Get_All_RegionId_Matches');
        WSH_UTIL_CORE.printmsg('Oracle error message is '|| SQLERRM);

      END IF;
      --
END Get_All_RegionId_Matches;

--
-- Procedure: Get_All_Zone_Matches
--
-- Purpose  : The API derives Zones for an input Region .
--	      A cache is used for the region to zone mapping.
--

PROCEDURE Get_All_Zone_Matches(
  p_region_id		IN	    NUMBER,
  x_zone_tab		OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status       OUT NOCOPY  VARCHAR2) IS

  CURSOR c_get_zone_for_region(c_region_id IN NUMBER) IS
  SELECT wr.region_id
  FROM   wsh_zone_regions wzr,wsh_regions wr
  WHERE  wzr.region_id = c_region_id
  AND    zone_flag = 'Y'
  AND    wzr.parent_region_id = wr.region_id
  AND    wr.region_type=10;

  --
  l_zone_tab	   WSH_UTIL_CORE.Id_Tab_Type;
  l_zone_id_string VARCHAR2(32767);
  itr		   NUMBER;
  l_return_status  VARCHAR2(1);

  --

  l_module_name	 CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_All_Zone_Matches';
  l_debug_on	 CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
  END IF;

  IF (p_region_id < g_cache_max_size AND g_region_zone_tab.EXISTS(p_region_id)) THEN

		WSH_UTIL_CORE.get_idtab_from_string(
			p_string	 => g_region_zone_tab(p_region_id),
			x_id_tab	 => l_zone_tab,
			x_return_status  => l_return_status);

		itr := l_zone_tab.FIRST;

		IF (l_zone_tab(itr) <> -1) THEN
			x_zone_tab := l_zone_tab;
		END IF;

		IF l_debug_on THEN
		    wsh_debug_sv.pop(l_module_name);
	        END IF;
		RETURN;
  END IF;

  OPEN c_get_zone_for_region(p_region_id);
  FETCH c_get_zone_for_region BULK COLLECT INTO l_zone_tab;
  CLOSE c_get_zone_for_region;

  x_zone_tab := l_zone_tab;

  --
  -- Add zones to the global cache.
  -- If no zones are associated with the region
  --	1) Store -1 in the cache.
  --    2) x_zone_tab is NULL.


  IF (p_region_id < g_cache_max_size ) THEN

    itr := l_zone_tab.FIRST;

    IF (itr ) IS NULL THEN
        l_zone_id_string := '-1';
    ELSE

      WSH_UTIL_CORE.get_string_from_idtab(
    	  p_id_tab	 => l_zone_tab,
	  x_string	 => l_zone_id_string,
	  x_return_status  => l_return_status);

    END IF;

    g_region_zone_tab(p_region_id) := l_zone_id_string;

  END IF;

  IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
WHEN others THEN
      IF c_get_zone_for_region%ISOPEN THEN
         CLOSE c_get_zone_for_region;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END Get_All_Zone_Matches;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_all_region_deconsols
--
-- PARAMETERS: p_location_id                   Input delivery record
--             p_use_cache                     Whether to use cache
--             p_lang_code                     Language Code
--             p_zone_flag                     Whether to perform search at zone level as well
--             p_rule_to_zone_id               zone id specified in the consolidation rule
--             p_caller                        Caller of API
--             x_region_consol_tab             Table of regions containing info
--                                             about deconsol locations for given location
--             x_return_status                 Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes input location id
--             Finds deconsolidation location for the location as defined on Regions and
--             zones form
--========================================================================

PROCEDURE get_all_region_deconsols (
	         p_location_id          IN          NUMBER,
	         p_use_cache            IN          BOOLEAN     DEFAULT FALSE,
	         p_lang_code            IN          VARCHAR2,
	         p_zone_flag            IN          BOOLEAN     DEFAULT FALSE,
             p_rule_to_zone_id      IN          NUMBER      DEFAULT  NULL,
                 p_caller               IN          VARCHAR2    DEFAULT NULL,
	         x_region_consol_tab    OUT NOCOPY  region_deconsol_Tab_Type,
	         x_return_status        OUT NOCOPY  VARCHAR2)
IS

        l_region_id             NUMBER;
        itr                     NUMBER;
        r_itr                   NUMBER;
        l_region_tab   region_deconsol_Tab_Type;
        l_region_deconsol_tab   region_deconsol_Tab_Type;
        l_zone_deconsol_tab     region_deconsol_Tab_Type;
        l_reg_zon_deconsol_tab  region_deconsol_Tab_Type;
        l_return_status		    VARCHAR2(1);
        z_itr                   NUMBER;
        rg_itr                  NUMBER;
        r_nrec                  NUMBER;
        i                       NUMBER;
        l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_all_region_deconsols';
        l_debug_on              CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

        CURSOR c_get_all_regions_loc(c_location_id IN NUMBER, c_lang_code IN VARCHAR2) IS
        SELECT wrl.region_id,
        wr.region_type,
        wr.deconsol_location_id
        FROM  wsh_region_locations wrl,wsh_regions_tl wrt,wsh_regions wr
        WHERE wrl.location_id = c_location_id
        AND   wrl.region_id IS NOT NULL
        AND   wrl.region_id = wrt.region_id
        AND   wrt.language = nvl('US',wrt.language)
        AND   wrt.region_id = wr.region_id
        --AND   wr.deconsol_location_id IS NOT NULL
        ORDER BY wr.region_type DESC;

        CURSOR c_get_zone_for_region(c_region_id IN NUMBER) IS
        SELECT wr.region_id,
        --null,
        wr.region_type,
        wr.deconsol_location_id
        FROM   wsh_zone_regions wzr,wsh_regions wr
        WHERE  wzr.region_id = c_region_id
        AND    zone_flag = 'Y'
        AND    wzr.parent_region_id = wr.region_id
        AND    wr.region_type=10
        AND    wr.deconsol_location_id IS NOT NULL
        ORDER BY wr.region_type DESC;
BEGIN
----{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_location_id: '|| p_location_id);
    END IF;

    -- If region deconsolidation location tab exists in cache, return
    -- else query database through c_get_all_regions_loc cursor

    IF p_use_cache = TRUE AND p_location_id < g_cache_max_size THEN

        IF p_zone_flag = TRUE AND g_loc_region_zone_deconsol_tab.EXISTS(p_location_id) THEN
            x_region_consol_tab :=  g_loc_region_zone_deconsol_tab(p_location_id);
            IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
            return;
        ELSIF g_loc_region_deconsol_tab.EXISTS(p_location_id) THEN
            x_region_consol_tab :=  g_loc_region_deconsol_tab(p_location_id);
            IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
            return;
        ELSE
            OPEN  c_get_all_regions_loc(p_location_id,p_lang_code);
                FETCH c_get_all_regions_loc BULK COLLECT INTO l_region_tab;
            CLOSE c_get_all_regions_loc;
        END IF;
    ELSIF  (NOT g_loc_region_deconsol_tab.EXISTS(p_location_id)) OR p_use_cache = FALSE THEN

        OPEN  c_get_all_regions_loc(p_location_id,p_lang_code);
            FETCH c_get_all_regions_loc BULK COLLECT INTO l_region_tab;
        CLOSE c_get_all_regions_loc;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_region_tab.COUNT: '|| l_region_tab.COUNT);
    END IF;

    i := 1;
    IF p_use_cache = TRUE THEN
        itr := l_region_tab.FIRST;
        IF itr IS NOT NULL THEN
            LOOP
                IF l_region_tab(itr).Deconsol_location IS NOT NULL THEN
                    l_region_deconsol_tab(i) :=  l_region_tab(itr);
                END IF;

                EXIT WHEN itr = l_region_tab.LAST;
                itr := l_region_tab.NEXT(itr);
                i := i+1;
            END LOOP;
        END IF;
        g_loc_region_deconsol_tab(p_location_id) := l_region_deconsol_tab;
    END IF;


    -- If search for zone level deconsolidation locations is true
    -- Loop through regions tab to find corresponding zone level deconsolidation locations

    IF p_zone_flag = TRUE THEN
        rg_itr := 0;
        r_itr := l_region_tab.FIRST;
        IF r_itr IS NOT NULL THEN
            LOOP
                rg_itr := rg_itr+1;
                l_region_id := l_region_tab(r_itr).region_id;

                -- If deconsol location exists for region, then add it to deconsol_tab
                IF l_region_tab(r_itr).Deconsol_location IS NOT NULL THEN
                    l_reg_zon_deconsol_tab(rg_itr) :=  l_region_tab(r_itr);
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).region_id: '|| l_reg_zon_deconsol_tab(rg_itr).region_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).deconsol_location: '|| l_reg_zon_deconsol_tab(rg_itr).Deconsol_location);
                    END IF;
                END IF;

                IF p_use_cache = TRUE AND l_region_id < g_cache_max_size THEN
                     IF (g_region_zone_deconsol_tab.EXISTS(l_region_id)) THEN
                           l_zone_deconsol_tab := g_region_zone_deconsol_tab(l_region_id);
                           --g_region_zone_deconsol_tab(l_region_id) := l_zone_deconsol_tab;
                     ELSE
                        OPEN c_get_zone_for_region(l_region_id);
                            FETCH c_get_zone_for_region BULK COLLECT INTO l_zone_deconsol_tab;
                        CLOSE c_get_zone_for_region;
                     END IF;

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_deconsol_tab.COUNT: '|| l_zone_deconsol_tab.COUNT);
                     END IF;
                ELSIF NOT (g_region_zone_deconsol_tab.EXISTS(l_region_id)) OR p_use_cache = FALSE THEN
                    OPEN c_get_zone_for_region(l_region_id);
                        FETCH c_get_zone_for_region BULK COLLECT INTO l_zone_deconsol_tab;
                    CLOSE c_get_zone_for_region;
                END IF;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_deconsol_tab.COUNT: '|| l_zone_deconsol_tab.COUNT);
                END IF;
                -- IF p_rule_to_zone_id IS NOT NULL:
                -- If caller is not WMS: If at any level of regions the zone(s) obtained do not match
                -- with input p_rule_to_zone_id, that level of zone should be skipped.
                --
                -- If caller is WMS: the zone level should be skipped completely if multiple
                -- zones found for any region.
                --
                IF p_rule_to_zone_id IS NOT NULL THEN
                    IF NOT (p_caller like 'WMS%' AND l_zone_deconsol_tab.COUNT >1) THEN
                        z_itr := l_zone_deconsol_tab.FIRST;
                        IF z_itr IS NOT NULL THEN
                            LOOP
                                IF l_zone_deconsol_tab(z_itr).region_id = p_rule_to_zone_id THEN
                                    rg_itr := rg_itr+1;
                                    l_reg_zon_deconsol_tab(rg_itr) := l_zone_deconsol_tab(z_itr);
                                    IF l_debug_on THEN
                                        WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).region_id: '|| l_reg_zon_deconsol_tab(rg_itr).region_id);
                                        WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).deconsol_location: '|| l_reg_zon_deconsol_tab(rg_itr).Deconsol_location);
                                    END IF;
                                    EXIT;
                                END IF;

                                EXIT WHEN z_itr = l_zone_deconsol_tab.LAST;
                                z_itr:= l_zone_deconsol_tab.NEXT(z_itr);
                            END LOOP;
                        END IF;
                    END IF;
                ELSE
                    z_itr := l_zone_deconsol_tab.FIRST;
                    IF z_itr IS NOT NULL THEN
                        LOOP
                            rg_itr := rg_itr+1;
                            l_reg_zon_deconsol_tab(rg_itr) := l_zone_deconsol_tab(z_itr);
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).region_id: '|| l_reg_zon_deconsol_tab(rg_itr).region_id);
                                WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_zon_deconsol_tab(rg_itr).deconsol_location: '|| l_reg_zon_deconsol_tab(rg_itr).Deconsol_location);
                            END IF;

                            EXIT WHEN z_itr = l_zone_deconsol_tab.LAST;
                            z_itr:= l_zone_deconsol_tab.NEXT(z_itr);
                        END LOOP;
                    END IF;
                END IF;

                EXIT WHEN r_itr = l_region_tab.LAST;
                r_itr:= l_region_tab.NEXT(r_itr);
            END LOOP;

       END IF;
       x_region_consol_tab := l_reg_zon_deconsol_tab;

       IF p_zone_flag THEN
            g_loc_region_zone_deconsol_tab(p_location_id) := l_reg_zon_deconsol_tab;
       END IF;
    ELSE
       x_region_consol_tab := l_region_deconsol_tab;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'x_region_consol_tab.COUNT: '|| x_region_consol_tab.COUNT);
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status: '|| x_return_status);
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
----}

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

WHEN OTHERS THEN
      IF c_get_all_regions_loc%ISOPEN THEN
         CLOSE c_get_all_regions_loc;
      END IF;
      IF c_get_zone_for_region%ISOPEN THEN
         CLOSE c_get_zone_for_region;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_REGIONS_SEARCH_PKG.get_all_region_deconsols');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END get_all_region_deconsols;

-- Following procedure are added for Regions Interface Performance

  --
  -- PROCEDURE : Check_Region_Info
  --
  -- PURPOSE   : Checks whether region exists in Wsh_Regions_Global_Data
  --             table based on parameters passed to it.
  PROCEDURE Check_Region_Info (
       p_country                IN   VARCHAR2,
       p_state                  IN   VARCHAR2,
       p_city                   IN   VARCHAR2,
       p_postal_code_from       IN   VARCHAR2,
       p_postal_code_to         IN   VARCHAR2,
       p_region_type            IN   NUMBER,
       p_search_flag            IN   VARCHAR2,
       p_lang_code              IN   VARCHAR2,
       x_return_status  OUT NOCOPY   VARCHAR2,
       x_region_info    OUT NOCOPY   WSH_REGIONS_SEARCH_PKG.region_rec)
  IS

     CURSOR C1 IS
       SELECT REGION_ID
       FROM   WSH_REGIONS_GLOBAL_DATA
       WHERE  ( city  = UPPER(p_city) or p_city is null )
       AND    ( state = UPPER(p_state) or p_state is null )
       AND    country = UPPER(p_country)
       AND    ( p_postal_code_from is null
          OR  ( ( p_postal_code_from between postal_code_from and postal_code_to )
             OR ( p_postal_code_to between postal_code_from and postal_code_to ) ) )
       AND    region_type = p_region_type
       AND    language    = p_lang_code;

     CURSOR C2 IS
       SELECT REGION_ID
       FROM   WSH_REGIONS_GLOBAL_DATA
       WHERE  ( city  = UPPER(p_city) )
       AND    ( nvl(state, UPPER(p_state)) = UPPER(p_state) )
       AND    country = UPPER(p_country)
       AND    ( p_postal_code_from is null
          OR  ( ( p_postal_code_from between postal_code_from and postal_code_to )
             OR ( p_postal_code_to between postal_code_from and postal_code_to ) ) )
       AND    region_type = p_region_type
       AND    language    = p_lang_code;

     TYPE tmp_table is table of NUMBER index by binary_integer;
     tmp_region_id  tmp_table;
     t1                        NUMBER;

     --
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_REGION_INFO';
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
        WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY', P_COUNTRY);
        WSH_DEBUG_SV.log(l_module_name, 'P_STATE', P_STATE);
        WSH_DEBUG_SV.log(l_module_name, 'P_CITY', P_CITY);
        WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_FROM', P_POSTAL_CODE_FROM);
        WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_TO', P_POSTAL_CODE_TO);
        WSH_DEBUG_SV.log(l_module_name, 'P_REGION_TYPE', P_REGION_TYPE);
        WSH_DEBUG_SV.log(l_module_name, 'P_SEARCH_FLAG', P_SEARCH_FLAG);
        WSH_DEBUG_SV.log(l_module_name, 'P_LANG_CODE', P_LANG_CODE);
     END IF;
     --

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     t1 := dbms_utility.get_time;

     IF ( p_state is not null and p_city is not null )
     THEN
        OPEN  C2;
        FETCH C2 BULK COLLECT INTO TMP_REGION_ID;
        CLOSE C2;
     ELSE
        OPEN  C1;
        FETCH C1 BULK COLLECT INTO TMP_REGION_ID;
        CLOSE C1;
     END IF;

     IF ( TMP_REGION_ID.COUNT > 0 ) THEN
        x_region_info.region_id := TMP_REGION_ID(1);
     ELSE
        x_region_info.region_id := -1;
     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Region_Id Fetched', x_region_info.region_id);
     END IF;
     --

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --

  -- Exception Handling part
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WSH', 'WSH_UTIL_MESSAGE_U');
        fnd_message.set_token('MSG_TEXT', SQLERRM);
        IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'CHECK_REGION_INFO EXCEPTION : ' || sqlerrm);
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  END;

  --
  -- PROCEDURE : Check_Region_Info_Code
  --
  -- PURPOSE   : Checks whether region exists in Wsh_Regions_Global_Data
  --             table based on parameters passed to it.
  PROCEDURE Check_Region_Info_Code (
       p_country                IN   VARCHAR2,
       p_state                  IN   VARCHAR2,
       p_city                   IN   VARCHAR2,
       p_country_code           IN   VARCHAR2,
       p_state_code             IN   VARCHAR2,
       p_city_code              IN   VARCHAR2,
       p_region_type            IN   NUMBER,
       p_search_flag            IN   VARCHAR2,
       p_lang_code              IN   VARCHAR2,
       x_return_status  OUT NOCOPY   VARCHAR2,
       x_region_info    OUT NOCOPY   WSH_REGIONS_SEARCH_PKG.region_rec)
  IS

     CURSOR C1 IS
       SELECT REGION_ID
       FROM   WSH_REGIONS_GLOBAL_DATA
       WHERE  ( city  = UPPER(p_city) or p_city is null )
       AND    ( decode(p_city, null, state, nvl(state, UPPER(p_state))) = UPPER(p_state)
          OR  ( p_state is null ) )
       AND    country = UPPER(p_country)
       AND    ( city_code  = UPPER(p_city_code) or p_city_code is null )
       AND    ( decode(p_city_code, null, state_code, nvl(state_code, UPPER(p_state_code))) = UPPER(p_state_code)
          OR  ( p_state_code is null ) )
       AND    country_code = UPPER(p_country_code)
       AND    region_type = p_region_type
       AND    language    = p_lang_code;

     TYPE tmp_table is table of NUMBER index by binary_integer;
     tmp_region_id  tmp_table;

     t1                        NUMBER;

     --
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_REGION_INFO_CODE';
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
        WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY', P_COUNTRY);
        WSH_DEBUG_SV.log(l_module_name, 'P_STATE', P_STATE);
        WSH_DEBUG_SV.log(l_module_name, 'P_CITY', P_CITY);
        WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY-CODE', P_COUNTRY_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_REGION_TYPE', P_REGION_TYPE);
        WSH_DEBUG_SV.log(l_module_name, 'P_SEARCH_FLAG', P_SEARCH_FLAG);
        WSH_DEBUG_SV.log(l_module_name, 'P_LANG_CODE', P_LANG_CODE);
     END IF;
     --

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     t1 := dbms_utility.get_time;
     OPEN  C1;
     FETCH C1 BULK COLLECT INTO TMP_REGION_ID;
     CLOSE C1;

     IF ( TMP_REGION_ID.COUNT > 0 ) THEN
        x_region_info.region_id := TMP_REGION_ID(1);
     ELSE
        x_region_info.region_id := -1;
     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Region_Id Fetched', x_region_info.region_id);
     END IF;
     --

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --

  -- Exception Handling part
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WSH', 'WSH_UTIL_MESSAGE_U');
        fnd_message.set_token('MSG_TEXT', SQLERRM);
        IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'CHECK_REGION_INFO_CODE EXCEPTION : ' || SUBSTR(SQLERRM,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  END;

  --
  -- PROCEDURE : Check_Region_Id_Codes_Only
  --
  -- PURPOSE   : Checks whether region exists in Wsh_Regions_Global_Data/
  --             Wsh_Regions_Global table based on parameters passed to it.

  PROCEDURE Check_Region_Id_Codes_Only (
       p_country_code           IN   VARCHAR2,
       p_state_code             IN   VARCHAR2,
       p_city_code              IN   VARCHAR2,
       p_postal_code_from       IN   VARCHAR2,
       p_postal_code_to         IN   VARCHAR2,
       p_region_type            IN   NUMBER,
       p_language_code          IN   VARCHAR2 DEFAULT NULL,
       x_return_status  OUT NOCOPY   VARCHAR2,
       x_region_id      OUT NOCOPY   NUMBER )
  IS
     CURSOR C1 IS
       SELECT REGION_ID
       FROM   WSH_REGIONS_GLOBAL_DATA
       WHERE  ( city_code  = UPPER(p_city_code) or p_city_code is null )
       AND    ( decode(p_city_code, null, state_code, nvl(state_code, UPPER(p_state_code))) = UPPER(p_state_code)
          OR  ( p_state_code is null ) )
       AND    country_code = UPPER(p_country_code)
       AND    ( p_postal_code_from is null
          OR  ( ( p_postal_code_from between postal_code_from and postal_code_to )
             OR ( p_postal_code_to between postal_code_from and postal_code_to ) ) )
       AND    region_type = p_region_type
       AND    language    = nvl(p_language_code, language);

     CURSOR C2 IS
       SELECT REGION_ID
       FROM   WSH_REGIONS_GLOBAL
       WHERE  ( city_code  = UPPER(p_city_code) or p_city_code is null )
       AND    ( decode(p_city_code, null, state_code, nvl(state_code, UPPER(p_state_code))) = UPPER(p_state_code)
          OR  ( p_state_code is null ) )
       AND    country_code = UPPER(p_country_code)
       AND    region_type = p_region_type;

     TYPE tmp_table is table of NUMBER index by binary_integer;
     tmp_region_id  tmp_table;

     l_with_tl_flag            BOOLEAN DEFAULT FALSE;
     l_non_tl_flag             BOOLEAN DEFAULT FALSE;
     t1                        NUMBER;

     --
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_REGION_ID_CODES_ONLY';
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
        WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_CODE', P_COUNTRY_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
        WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_FROM', P_POSTAL_CODE_FROM);
        WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_TO', P_POSTAL_CODE_TO);
        WSH_DEBUG_SV.log(l_module_name, 'P_REGION_TYPE', P_REGION_TYPE);
        WSH_DEBUG_SV.log(l_module_name, 'P_LANGUAGE_CODE', P_LANGUAGE_CODE);
     END IF;
     --

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF ( ( p_country_code is null and p_state_code is null and p_city_code is null)
       OR ( p_region_type = 2 and p_city_code is null )
       OR ( p_region_type = 1 and p_state_code is null )
       OR ( p_region_type = 0 and p_country_code is null ) )
     THEN
        x_region_id := -1;
        return;
     END IF;

     IF ( p_postal_code_from is not null or p_language_code is not null ) THEN
        l_with_tl_flag := TRUE;
     ELSE
        l_non_tl_flag := TRUE;
     END IF;

     IF ( l_with_tl_flag ) THEN
        t1 := dbms_utility.get_time;
        OPEN  C1;
        FETCH C1 BULK COLLECT INTO TMP_REGION_ID;
        CLOSE C1;

        IF ( TMP_REGION_ID.COUNT > 0 ) THEN
           x_region_id := TMP_REGION_ID(1);
        ELSE
           x_region_id := -1;
        END IF;
     ELSE
        t1 := dbms_utility.get_time;
        OPEN  C2;
        FETCH C2 BULK COLLECT INTO TMP_REGION_ID;
        CLOSE C2;

        IF ( TMP_REGION_ID.COUNT > 0 ) THEN
           x_region_id := TMP_REGION_ID(1);
        ELSE
           x_region_id := -1;
        END IF;

     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Region_Id Fetched', x_region_id);
     END IF;
     --

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --

     --wsh_debug_sv.logmsg(l_module_name, 'TOTAL TIME TAKEN FOR CHECK_REGION_ID_CODES_ONLY : ' || ((dbms_utility.get_time - t1)/100));
  -- Exception Handling part
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('WSH', 'WSH_UTIL_MESSAGE_U');
        fnd_message.set_token('MSG_TEXT', SQLERRM);
        IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'CHECK_REGION_ID_CODES_ONLY EXCEPTION : ' || SUBSTR(SQLERRM,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  END;


END WSH_REGIONS_SEARCH_PKG;

/
