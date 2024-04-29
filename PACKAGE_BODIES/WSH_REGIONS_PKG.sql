--------------------------------------------------------
--  DDL for Package Body WSH_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_REGIONS_PKG" AS
/* $Header: WSHRETHB.pls 120.2.12010000.2 2009/06/04 13:41:40 gbhargav ship $ */

  --
  -- Package
  --    WSH_REGIONS_PKG
  --
  -- Purpose
  --

  --
  -- PACKAGE TYPES
  --

  --
  -- PUBLIC VARIABLES
  --

  --
  -- PRIVATE FUNCTIONS/PROCEDURES
  --

  --
  -- Procedure: Add_Region
  --
  -- Purpose:   Inserts the region with appropriate data and returns the
  --        region_id
  --

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_REGIONS_PKG';
  --
  PROCEDURE Add_Region (
    p_country_code          IN  VARCHAR2,
    p_country_region_code       IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_port_flag             IN  VARCHAR2,
    p_airport_flag          IN  VARCHAR2,
    p_road_terminal_flag        IN  VARCHAR2,
    p_rail_terminal_flag        IN  VARCHAR2,
    p_longitude             IN  NUMBER,
    p_latitude          IN  NUMBER,
    p_timezone          IN  VARCHAR2,
    p_continent             IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_country_region        IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_alternate_name        IN  VARCHAR2,
    p_county            IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
        p_region_type           IN  NUMBER,
    p_parent_region_id      IN  NUMBER,
    p_interface_flag        IN  VARCHAR2,
    p_tl_only_flag          IN  VARCHAR2,
    p_region_id         IN  NUMBER,
    p_region_dff            IN  REGION_DFF_REC DEFAULT NULL,
    x_region_id         OUT NOCOPY  NUMBER,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL) IS


  CURSOR get_region_id IS
  SELECT WSH_REGIONS_s.nextval from dual;

  CURSOR get_interface_region_id IS
  SELECT WSH_REGIONS_INTERFACE_S.nextval from dual;

  l_region_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_PORT_FLAG',P_PORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_AIRPORT_FLAG',P_AIRPORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_ROAD_TERMINAL_FLAG',P_ROAD_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_RAIL_TERMINAL_FLAG',P_RAIL_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_LONGITUDE',P_LONGITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_LATITUDE',P_LATITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_TIMEZONE',P_TIMEZONE);
         WSH_DEBUG_SV.log(l_module_name,'P_CONTINENT',P_CONTINENT);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_NAME',P_ALTERNATE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_TYPE',P_REGION_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_PARENT_REGION_ID',P_PARENT_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_TL_ONLY_FLAG',P_TL_ONLY_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE_CATEGORY',P_REGION_DFF.ATTRIBUTE_CATEGORY);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE1',P_REGION_DFF.ATTRIBUTE1);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE2',P_REGION_DFF.ATTRIBUTE2);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE3',P_REGION_DFF.ATTRIBUTE3);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE4',P_REGION_DFF.ATTRIBUTE4);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE5',P_REGION_DFF.ATTRIBUTE5);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE6',P_REGION_DFF.ATTRIBUTE6);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE7',P_REGION_DFF.ATTRIBUTE7);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE8',P_REGION_DFF.ATTRIBUTE8);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE9',P_REGION_DFF.ATTRIBUTE9);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE10',P_REGION_DFF.ATTRIBUTE10);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE11',P_REGION_DFF.ATTRIBUTE11);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE12',P_REGION_DFF.ATTRIBUTE12);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE13',P_REGION_DFF.ATTRIBUTE13);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE14',P_REGION_DFF.ATTRIBUTE14);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE15',P_REGION_DFF.ATTRIBUTE15);
         WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);
     END IF;
     --
     IF (p_tl_only_flag = 'Y') THEN

    l_region_id := p_region_id;

     ELSE

    IF (p_interface_flag = 'Y') THEN

       OPEN get_interface_region_id;
       FETCH get_interface_region_id INTO l_region_id;
       CLOSE get_interface_region_id;

    ELSE

       OPEN get_region_id;
       FETCH get_region_id INTO l_region_id;
       CLOSE get_region_id;

    END IF;

     END IF;

     IF (p_interface_flag = 'Y') THEN

    IF (p_tl_only_flag <> 'Y') THEN

 -- fnd_file.put_line(fnd_file.Log, 'inserting into fte regions interface, interface and tl only flag both = Y');

       INSERT INTO WSH_REGIONS_INTERFACE (
        REGION_ID,
        REGION_TYPE,
        PARENT_REGION_ID,
        COUNTRY_CODE,
        COUNTRY_REGION_CODE,
        STATE_CODE,
        CITY_CODE,
        PORT_FLAG,
        AIRPORT_FLAG,
        ROAD_TERMINAL_FLAG,
        RAIL_TERMINAL_FLAG,
        LONGITUDE,
        LATITUDE,
        TIMEZONE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
       VALUES (
        l_region_id,
        p_region_type,
        p_parent_region_id,
        p_country_code,
        p_country_region_code,
        p_state_code,
        p_city_code,
        p_port_flag,
        p_airport_flag,
        p_road_terminal_flag,
        p_rail_terminal_flag,
        p_longitude,
        p_latitude,
        p_timezone,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

    END IF;

    INSERT INTO WSH_REGIONS_TL_INTERFACE (
        LANGUAGE,
        REGION_ID,
        CONTINENT,
        COUNTRY,
        COUNTRY_REGION,
        STATE,
        CITY,
        ALTERNATE_NAME,
        COUNTY,
        POSTAL_CODE_FROM,
        POSTAL_CODE_TO,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES (
        p_lang_code,
        l_region_id,
        p_continent,
        p_country,
        p_country_region,
        p_state,
        p_city,
        p_alternate_name,
        p_county,
        p_postal_code_from,
        p_postal_code_to,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

     ELSE

    IF (p_tl_only_flag <> 'Y') THEN

       INSERT INTO WSH_REGIONS (
        REGION_ID,
        REGION_TYPE,
        PARENT_REGION_ID,
        COUNTRY_CODE,
        COUNTRY_REGION_CODE,
        STATE_CODE,
        CITY_CODE,
        PORT_FLAG,
        AIRPORT_FLAG,
        ROAD_TERMINAL_FLAG,
        RAIL_TERMINAL_FLAG,
        LONGITUDE,
        LATITUDE,
        TIMEZONE,
        ZONE_LEVEL,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
                DECONSOL_LOCATION_ID )
       VALUES (
        l_region_id,
        p_region_type,
        p_parent_region_id,
        p_country_code,
        p_country_region_code,
        p_state_code,
        p_city_code,
        p_port_flag,
        p_airport_flag,
        p_road_terminal_flag,
        p_rail_terminal_flag,
        p_longitude,
        p_latitude,
        p_timezone,
        p_region_type,
        p_region_dff.attribute_category,
        p_region_dff.attribute1,
        p_region_dff.attribute2,
        p_region_dff.attribute3,
        p_region_dff.attribute4,
        p_region_dff.attribute5,
        p_region_dff.attribute6,
        p_region_dff.attribute7,
        p_region_dff.attribute8,
        p_region_dff.attribute9,
        p_region_dff.attribute10,
        p_region_dff.attribute11,
        p_region_dff.attribute12,
        p_region_dff.attribute13,
        p_region_dff.attribute14,
        p_region_dff.attribute15,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id,
                p_deconsol_location_id);

    END IF;

        -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'inserting region '||l_region_id);
    END IF;

    INSERT INTO WSH_REGIONS_TL (
        LANGUAGE,
        REGION_ID,
        CONTINENT,
        COUNTRY,
        COUNTRY_REGION,
        STATE,
        CITY,
        ALTERNATE_NAME,
        COUNTY,
        POSTAL_CODE_FROM,
        POSTAL_CODE_TO,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES (
        p_lang_code,
        l_region_id,
        p_continent,
        p_country,
        p_country_region,
        p_state,
        p_city,
        p_alternate_name,
        p_county,
        p_postal_code_from,
        p_postal_code_to,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

     END IF;

     x_region_id := l_region_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Add_Region;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Procedure: Get_Parent_Region_Info
  --
  -- Purpose:   Retrieves the region Id of the region passed in, and if it
  --        does not exist, inserts into the database.
  --
  --

  PROCEDURE Get_Parent_Region_Info(
    p_parent_region_type        IN  NUMBER,
    p_country_code          IN  VARCHAR2,
    p_country_region_code       IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code         IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_country_region        IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
    p_interface_flag        IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    p_insert_parent_flag        IN  VARCHAR2,
            x_parent_region_info     OUT    NOCOPY   wsh_regions_search_pkg.region_rec,
            p_conc_request_flag      IN     VARCHAR2 DEFAULT 'N')
IS
  l_parent_region_id_non_tl number;
  l_parent_region_id_tl number;
  l_check_tl_id number;
  l_existing_parent_region_id number;
  l_tl_only_flag varchar2(1);
  l_status varchar2(1);
  l_error_msg varchar2(200);
  l_region_info wsh_regions_search_pkg.region_rec;
   l_return_status              varchar2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PARENT_REGION_INFO';
--
  BEGIN

    -- fnd_file.put_line(fnd_file.Log, 'in Get_Parent_Region_Id '||p_parent_region_type);

    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_PARENT_REGION_TYPE',P_PARENT_REGION_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
        WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_INSERT_PARENT_FLAG',P_INSERT_PARENT_FLAG);
        WSH_DEBUG_SV.log(l_module_name, 'P_CONC_REQUEST_FLAG', P_CONC_REQUEST_FLAG);
    END IF;
    --
    l_tl_only_flag := 'N';
    l_existing_parent_region_id := -1;

   IF ( p_conc_request_flag = 'Y' ) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_INFO_CODE', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_REGIONS_SEARCH_PKG.Check_Region_Info_Code(
            p_country          =>  p_country,
            p_state            =>  p_state,
            p_city             =>  p_city,
            p_country_code     =>  p_country_code,
            p_state_code       =>  p_state_code,
            p_city_code        =>  p_city_code,
            p_region_type      =>  p_parent_region_type,
            p_search_flag      =>  'N',
            p_lang_code        =>  p_lang_code,
            x_return_status    =>  l_return_status,
            x_region_info      =>  l_region_info);

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         fnd_file.put_line(fnd_file.log,'Error Occured in WSH_REGIONS_SEARCH_PKG.Check_Region_Info_Code');
         fnd_file.put_line(fnd_file.log,'Error Message : '|| fnd_message.get_string('WSH', 'WSH_UTIL_MESSAGE_U') );
         l_region_info.region_id := -1;
         return;
      END IF;
   ELSE
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Wsh_Regions_Search_Pkg.Get_Region_Info(
            p_country       =>  p_country,
            p_country_region    =>  p_country_region,
            p_state         =>  p_state,
            p_city          =>  p_city,
            p_postal_code_from  =>  null,
            p_postal_code_to    =>  null,
            p_zone          =>  null,
            p_lang_code     =>  p_lang_code,
            p_country_code      =>  p_country_code,
            p_country_region_code   =>  p_country_region_code,
            p_state_code        =>  p_state_code,
            p_city_code     =>  p_city_code,
                p_region_type       =>  p_parent_region_type,
            p_interface_flag    =>  p_interface_flag,
            x_region_info       =>  l_region_info);
   END IF;

                -- Debug Statements
            --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, ' got parent id '||l_region_info.region_id);
    END IF;

    l_parent_region_id_non_tl := l_region_info.region_id;

    l_parent_region_id_tl := l_parent_region_id_non_tl;

     IF (l_parent_region_id_non_tl = -1) THEN

          IF ((p_city_code IS NULL OR p_city IS NOT NULL) AND
           (p_state_code IS NULL OR p_state IS NOT NULL) AND
           (p_country_code IS NULL OR p_country IS NOT NULL)) THEN

                    IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                        fnd_file.put_line(fnd_file.log,'1. Error Occured in WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only');
                        fnd_file.put_line(fnd_file.log,'1. Error Message : '|| fnd_message.get_string('WSH', 'WSH_UTIL_MESSAGE_U') );
                        l_region_info.region_id := -1;
                        return;
                    END IF;

                    IF (l_parent_region_id_non_tl <> -1) THEN
                           --
                           -- Debug Statements
                           --
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_ID_CODES_ONLY WITH LANGUAGE', WSH_DEBUG_SV.C_PROC_LEVEL);
                           END IF;
                       --
                           WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only(
                                       p_country_code       =>   p_country_code,
                                       p_state_code         =>   p_state_code,
                                       p_city_code          =>   p_city_code,
                                       p_postal_code_from   =>   null,
                                       p_postal_code_to     =>   null,
                                       p_region_type        =>   p_parent_region_type,
                                       p_language_code      =>   p_lang_code,
                                       x_return_status      =>   l_return_status,
                                       x_region_id          =>   l_check_tl_id);

                       IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                          fnd_file.put_line(fnd_file.log,'2. Error Occured in WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only');
                          fnd_file.put_line(fnd_file.log,'2. Error Message : '|| fnd_message.get_string('WSH', 'WSH_UTIL_MESSAGE_U') );
                          l_region_info.region_id := -1;
                          return;
                       END IF;
                    END IF;
          ELSE
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_ID_CODES_ONLY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Wsh_Regions_Search_Pkg.Get_Region_Id_Codes_Only(
                p_country_code      =>  p_country_code,
                p_country_region_code   =>  p_country_region_code,
                p_state_code        =>  p_state_code,
                p_city_code     =>  p_city_code,
                p_postal_code_from  =>  null,
                p_postal_code_to    =>  null,
                    p_region_type       =>  p_parent_region_type,
                p_interface_flag    =>  p_interface_flag,
                p_lang_code     =>  p_lang_code,
                x_region_id_non_tl  =>  l_parent_region_id_non_tl,
                x_region_id_with_tl =>  l_check_tl_id);
          END IF;

        l_region_info.country_code := p_country_code;
        l_region_info.country_region_code := p_country_region_code;
        l_region_info.state_code := p_state_code;
        l_region_info.city_code := p_city_code;

     END IF;

     IF (l_parent_region_id_non_tl <> -1 AND l_check_tl_id <> -1) THEN
-- fnd_file.put_line(fnd_file.log,'parent region exists in tl table. cannot insert new one '||l_parent_region_id_non_tl||' x '||l_check_tl_id);
         x_parent_region_info.region_id := -1;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
      END IF;

      IF (l_parent_region_id_non_tl <> -1) THEN

             -- Debug Statements
         --
         IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'region exists in tl table');
         END IF;

         l_tl_only_flag := 'Y';
         l_existing_parent_region_id := l_parent_region_id_non_tl;
      END IF;


        -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'in Get_Parent_Region_Id_tl id = ' || l_parent_region_id_tl);
    END IF;

    IF (l_parent_region_id_non_tl <> -1) THEN

        l_tl_only_flag := 'Y';
        l_existing_parent_region_id := l_parent_region_id_non_tl;

    END IF;

    IF (l_parent_region_id_tl = -1 AND p_interface_flag <> 'Y' AND p_insert_parent_flag = 'Y') THEN


       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'inserting parent');
       END IF;

       -- insert this parent region
       INSERT_REGION(
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  p_country_region_code,
        p_state_code        =>  p_state_code,
        p_city_code     =>  p_city_code,
        p_port_flag     =>  null,
        p_airport_flag      =>  null,
        p_road_terminal_flag    =>  null,
        p_rail_terminal_flag    =>  null,
        p_longitude     =>  null,
        p_latitude      =>  null,
        p_timezone      =>  null,
        p_continent     =>  null,
        p_country       =>  p_country,
        p_country_region    =>  p_country_region,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_alternate_name    =>  null,
        p_county        =>  null,
        p_postal_code_from  =>  null,
        p_postal_code_to    =>  null,
        p_lang_code     =>  p_lang_code,
        p_interface_flag    =>  p_interface_flag,
        p_tl_only_flag      =>  l_tl_only_flag,
        p_region_id     =>  l_existing_parent_region_id,
        p_parent_region_id  =>  null,
        p_user_id       =>  p_user_id,
        p_insert_parent_flag    =>  p_insert_parent_flag,
        x_region_id     =>  l_parent_region_id_non_tl,
        x_status        =>  l_status,
             x_error_msg             =>     l_error_msg,
             p_conc_request_flag     =>     p_conc_request_flag);

       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'inserted parent id: '||l_parent_region_id_non_tl);
       END IF;

    END IF;

        l_region_info.region_id := l_parent_region_id_non_tl;
    x_parent_region_info := l_region_info;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Get_Parent_Region_Info;

  --
  -- Procedure: Insert_Region
  --
  -- Purpose:   Inserts the region with appropriate data, and recursively inserts
  --        the parent region if it doesn't exist thru Get_Parent_Region_Info
  --
  --            Parameter P_CONC_REQUEST_FLAG added for "Regions Interface"
  --            performance issue.

  PROCEDURE Insert_Region (
    p_country_code          IN  VARCHAR2,
    p_country_region_code       IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_port_flag             IN  VARCHAR2,
    p_airport_flag          IN  VARCHAR2,
    p_road_terminal_flag        IN  VARCHAR2,
    p_rail_terminal_flag        IN  VARCHAR2,
    p_longitude             IN  NUMBER,
    p_latitude          IN  NUMBER,
    p_timezone          IN  VARCHAR2,
    p_continent             IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_country_region        IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_alternate_name        IN  VARCHAR2,
    p_county            IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
    p_interface_flag        IN  VARCHAR2,
    p_tl_only_flag          IN  VARCHAR2,
    p_region_id         IN  NUMBER,
    p_parent_region_id      IN  NUMBER,
    p_user_id           IN  NUMBER,
    p_insert_parent_flag        IN  VARCHAR2,
    p_region_dff            IN      REGION_DFF_REC DEFAULT NULL,
    x_region_id         OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL,
            p_conc_request_flag     IN    VARCHAR2 DEFAULT 'N')
IS
  l_region_type NUMBER := 0;
  l_parent_offset NUMBER := 1;
  l_parent_region_type NUMBER := 0;
  l_parent_region_info wsh_regions_search_pkg.region_rec;
  l_region_id NUMBER;
   l_return_status      VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_PORT_FLAG',P_PORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_AIRPORT_FLAG',P_AIRPORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_ROAD_TERMINAL_FLAG',P_ROAD_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_RAIL_TERMINAL_FLAG',P_RAIL_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_LONGITUDE',P_LONGITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_LATITUDE',P_LATITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_TIMEZONE',P_TIMEZONE);
         WSH_DEBUG_SV.log(l_module_name,'P_CONTINENT',P_CONTINENT);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_NAME',P_ALTERNATE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_TL_ONLY_FLAG',P_TL_ONLY_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_PARENT_REGION_ID',P_PARENT_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_INSERT_PARENT_FLAG',P_INSERT_PARENT_FLAG);
      WSH_DEBUG_SV.log(l_module_name, 'P_CONC_REQUEST_FLAG', P_CONC_REQUEST_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE_CATEGORY',P_REGION_DFF.ATTRIBUTE_CATEGORY);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE1',P_REGION_DFF.ATTRIBUTE1);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE2',P_REGION_DFF.ATTRIBUTE2);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE3',P_REGION_DFF.ATTRIBUTE3);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE4',P_REGION_DFF.ATTRIBUTE4);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE5',P_REGION_DFF.ATTRIBUTE5);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE6',P_REGION_DFF.ATTRIBUTE6);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE7',P_REGION_DFF.ATTRIBUTE7);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE8',P_REGION_DFF.ATTRIBUTE8);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE9',P_REGION_DFF.ATTRIBUTE9);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE10',P_REGION_DFF.ATTRIBUTE10);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE11',P_REGION_DFF.ATTRIBUTE11);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE12',P_REGION_DFF.ATTRIBUTE12);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE13',P_REGION_DFF.ATTRIBUTE13);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE14',P_REGION_DFF.ATTRIBUTE14);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE15',P_REGION_DFF.ATTRIBUTE15);
         WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);
     END IF;
     --
     l_parent_region_info.region_id := -1;
     x_status := 0;
     x_region_id := -1;
     x_error_msg := NULL;

     -- figure out region type
     IF (p_postal_code_from IS NOT NULL) THEN
       l_region_type := 3;

     ELSIF (p_city_code IS NOT NULL OR p_city IS NOT NULL) THEN
       l_region_type := 2;

     ELSIF (p_state_code IS NOT NULL OR p_state IS NOT NULL) THEN
       l_region_type := 1;

     END IF;

     -- figure out the parent region offset
     IF (l_region_type > 0) THEN

       IF (l_region_type = 2 AND
               p_state IS NULL AND
               p_state_code IS NULL) THEN
          l_parent_offset := l_parent_offset + 1;

       ELSE
              IF (l_region_type = 3 AND
            p_city IS NULL AND
            p_city_code IS NULL) THEN
          l_parent_offset := l_parent_offset + 1;

             IF (p_state IS NULL AND
             p_state_code IS NULL) THEN
             l_parent_offset := l_parent_offset + 1;
             END IF;

          END IF;

           END IF;

     END IF;

   IF (p_parent_region_id IS NULL OR p_parent_region_id = -1)
   THEN
      IF (l_region_type > 0)
      THEN
         BEGIN  -- { Begin
       l_parent_region_type := l_region_type - l_parent_offset;

       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'parent region type '||l_parent_region_type);
       END IF;

       IF (l_parent_region_type = 2) THEN

           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'getting parent for postal code');
           END IF;

               Get_Parent_Region_Info(
          p_parent_region_type      =>  l_parent_region_type,
          p_country_code        =>  p_country_code,
          p_country_region_code     =>  p_country_region_code,
          p_state_code          =>  p_state_code,
          p_city_code           =>  p_city_code,
          p_country         =>  p_country,
          p_country_region      =>  p_country_region,
          p_state           =>  p_state,
          p_city            =>  p_city,
          p_lang_code           =>  p_lang_code,
          p_interface_flag      =>  p_interface_flag,
          p_user_id         =>  p_user_id,
          p_insert_parent_flag      =>  p_insert_parent_flag,
                   x_parent_region_info    =>   l_parent_region_info,
                   p_conc_request_flag     =>   p_conc_request_flag);
       ELSIF (l_parent_region_type = 1) THEN

           -- Debug Statements
           --
           IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'getting parent for city');
           END IF;


           Get_Parent_Region_Info(
          p_parent_region_type      =>  l_parent_region_type,
          p_country_code        =>  p_country_code,
          p_country_region_code     =>  p_country_region_code,
          p_state_code          =>  p_state_code,
          p_city_code           =>  null,
          p_country         =>  p_country,
          p_country_region      =>  p_country_region,
          p_state           =>  p_state,
          p_city            =>  null,
          p_lang_code           =>  p_lang_code,
          p_interface_flag      =>  p_interface_flag,
          p_user_id         =>  p_user_id,
          p_insert_parent_flag      =>  p_insert_parent_flag,
                   x_parent_region_info    =>   l_parent_region_info,
                   p_conc_request_flag     =>   p_conc_request_flag);
       ELSIF (l_parent_region_type = 0) THEN

           -- Debug Statements
           --
           IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'getting parent for state');
           END IF;

        Get_Parent_Region_Info(
          p_parent_region_type      =>  l_parent_region_type,
          p_country_code        =>  p_country_code,
          p_country_region_code     =>  null,
          p_state_code          =>  null,
          p_city_code           =>  null,
          p_country         =>  p_country,
          p_country_region      =>  null,
          p_state           =>  null,
          p_city            =>  null,
          p_lang_code           =>  p_lang_code,
          p_interface_flag      =>  p_interface_flag,
          p_user_id         =>  p_user_id,
          p_insert_parent_flag      =>  p_insert_parent_flag,
                   x_parent_region_info    =>   l_parent_region_info,
                   p_conc_request_flag     =>   p_conc_request_flag);
        END IF;

       END;

    END IF;


    --make sure country code and name is populated
    IF (p_country_code IS NULL AND l_region_type = 0) THEN

        x_status := 2;
        x_error_msg := 'WSH_CAT_COUNTRY_CODE_REQUIRED';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;

    END IF;

    IF ((p_country IS NULL AND l_region_type = 0) OR (p_country IS NULL AND p_country_code IS NULL)) THEN

        x_status := 2;
        x_error_msg := 'WSH_CAT_COUNTRY_REQUIRED';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;

    END IF;

     ELSE
    l_parent_region_info.region_id := p_parent_region_id;

     END IF;

     -- Debug Statements
     --
     IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'add region with codes '||p_country_code||', '||p_state_code||', '||p_city_code);
    WSH_DEBUG_SV.logmsg(l_module_name, 'and name '||p_country||', '||p_state||', '||p_city||', '||p_postal_code_from);
    WSH_DEBUG_SV.logmsg(l_module_name, 'and type '||l_region_type||', parent ID '||l_parent_region_info.region_id);
     END IF;

    IF ((l_parent_region_info.region_id <> -1 OR l_region_type = 0)) OR p_interface_flag = 'Y'
    THEN

     Add_Region (
            p_country_code      =>  nvl(l_parent_region_info.country_code,p_country_code),
                p_country_region_code   =>  p_country_region_code,
                p_state_code        =>  p_state_code,
            p_city_code     =>  p_city_code,
                p_port_flag     =>  p_port_flag,
                p_airport_flag      =>  p_airport_flag,
                p_road_terminal_flag    =>  p_road_terminal_flag,
                p_rail_terminal_flag    =>  p_rail_terminal_flag,
            p_longitude     =>  p_longitude,
                p_latitude      =>  p_latitude,
                p_timezone      =>  p_timezone,
                p_continent     =>  p_continent,
                p_country       =>  p_country,
                p_country_region    =>  p_country_region,
                p_state         =>  p_state,
                p_city          =>  p_city,
                p_alternate_name    =>  p_alternate_name,
                p_county        =>  p_county,
                p_postal_code_from  =>  p_postal_code_from,
                    p_postal_code_to    =>  p_postal_code_to,
            p_lang_code     =>  p_lang_code,
                p_region_type       =>  l_region_type,
                p_parent_region_id  =>  l_parent_region_info.region_id,
                p_interface_flag    =>  p_interface_flag,
            p_tl_only_flag      =>  p_tl_only_flag,
            p_region_id     =>  p_region_id,
            p_region_dff        =>  p_region_dff,
            x_region_id     =>  l_region_id,
                        p_deconsol_location_id  =>      p_deconsol_location_id);

      -- To insert the same in Global Temp Tables
      IF ( p_conc_request_flag = 'Y' )
      THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.INSERT_GLOBAL_TABLE', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Insert_Global_Table(
                p_country          =>  p_country,
                p_state            =>  p_state,
                p_city             =>  p_city,
                p_country_code     =>  p_country_code,
                p_state_code       =>  p_state_code,
                p_city_code        =>  p_city_code,
                p_region_id        =>  l_region_id,
                p_region_type      =>  l_region_type,
                p_parent_region_id =>  l_parent_region_info.region_id,
                p_postal_code_from =>  p_postal_code_from,
                p_postal_code_to   =>  p_postal_code_to,
                p_tl_only_flag     =>  p_tl_only_flag,
                p_lang_code        =>  p_lang_code,
                x_return_status    =>  l_return_status );

         -- Error Handling Part
         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            x_status    := 2;
            x_error_msg := 'WSH_UTIL_MESSAGE_U';
         END IF;
      END IF;
      ELSE
         if nvl(p_interface_flag, 'N') = 'N' then
       x_status := 2;
       x_error_msg := 'WSH_CAT_PARENT_NOT_FOUND';
     end if;

      END IF;

      x_region_id := l_region_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Insert_Region;

  --
  -- Procedure: Update_Region
  --
  -- Purpose:   Updates a region with new information if the region exists,
  --        otherwise calls Insert_Region to insert the region.
  --

  PROCEDURE Update_Region (
    p_insert_type           IN  VARCHAR2,
    p_region_id         IN  NUMBER,
    p_parent_region_id      IN  NUMBER,
    p_continent             IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_country_region        IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_alternate_name        IN  VARCHAR2,
    p_county            IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_country_region_code       IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_port_flag             IN  VARCHAR2,
    p_airport_flag          IN  VARCHAR2,
    p_road_terminal_flag        IN  VARCHAR2,
    p_rail_terminal_flag        IN  VARCHAR2,
    p_longitude             IN  NUMBER,
    p_latitude          IN  NUMBER,
    p_timezone          IN  VARCHAR2,
    p_interface_flag        IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    p_insert_parent_flag        IN  VARCHAR2,
    p_region_dff            IN      REGION_DFF_REC DEFAULT NULL,
    x_region_id         OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL,
          p_conc_request_flag     IN       VARCHAR2 DEFAULT 'N')
IS
  CURSOR child_regions(l_region_id NUMBER) IS
  SELECT region_id, zone_level, parent_region_id
  FROM   wsh_regions
  START WITH region_id = l_region_id
  CONNECT BY PRIOR region_id = parent_region_id;
--  WHERE  region_id = l_region_id
--  FOR UPDATE NOWAIT;

   CURSOR get_state_code(l_region_id NUMBER) IS
      SELECT state_code, city_code
  FROM wsh_regions
  WHERE region_id =l_region_id;

  CURSOR get_zone_level(l_region_id NUMBER) IS
  SELECT zone_level
  FROM wsh_regions
  WHERE region_id = l_region_id;

  l_region_id number;
  l_region_type number;
  l_check_tl_id number;
  l_existing_region_id number;
  l_tl_only_flag varchar2(1);
  l_status number;
  l_error_msg varchar2(200);
  l_region_info wsh_regions_search_pkg.region_rec;
  l_parent_zone_level number;
  l_update_state_code wsh_regions.state_code%type;
   l_update_city_code   wsh_regions.city_code%type;
   l_return_status      VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_REGION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_INSERT_TYPE',P_INSERT_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_PARENT_REGION_ID',P_PARENT_REGION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CONTINENT',P_CONTINENT);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
        WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_NAME',P_ALTERNATE_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
        WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
        WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
        WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION_CODE',P_COUNTRY_REGION_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_PORT_FLAG',P_PORT_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_AIRPORT_FLAG',P_AIRPORT_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_ROAD_TERMINAL_FLAG',P_ROAD_TERMINAL_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_RAIL_TERMINAL_FLAG',P_RAIL_TERMINAL_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_LONGITUDE',P_LONGITUDE);
        WSH_DEBUG_SV.log(l_module_name,'P_LATITUDE',P_LATITUDE);
        WSH_DEBUG_SV.log(l_module_name,'P_TIMEZONE',P_TIMEZONE);
        WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_INSERT_PARENT_FLAG',P_INSERT_PARENT_FLAG);
            WSH_DEBUG_SV.log(l_module_name, 'P_CONC_REQUEST_FLAG', P_CONC_REQUEST_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE_CATEGORY',P_REGION_DFF.ATTRIBUTE_CATEGORY);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE1',P_REGION_DFF.ATTRIBUTE1);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE2',P_REGION_DFF.ATTRIBUTE2);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE3',P_REGION_DFF.ATTRIBUTE3);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE4',P_REGION_DFF.ATTRIBUTE4);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE5',P_REGION_DFF.ATTRIBUTE5);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE6',P_REGION_DFF.ATTRIBUTE6);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE7',P_REGION_DFF.ATTRIBUTE7);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE8',P_REGION_DFF.ATTRIBUTE8);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE9',P_REGION_DFF.ATTRIBUTE9);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE10',P_REGION_DFF.ATTRIBUTE10);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE11',P_REGION_DFF.ATTRIBUTE11);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE12',P_REGION_DFF.ATTRIBUTE12);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE13',P_REGION_DFF.ATTRIBUTE13);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE14',P_REGION_DFF.ATTRIBUTE14);
        WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE15',P_REGION_DFF.ATTRIBUTE15);
            WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);

    END IF;
    --
    l_tl_only_flag := 'N';
    l_status := 0;
    l_error_msg := NULL;
    l_existing_region_id := -1;

        IF (p_postal_code_from IS NOT NULL OR p_postal_code_to IS NOT NULL) THEN
          l_region_type := 3;
        ELSIF (p_city IS NOT NULL OR p_city_code IS NOT NULL) THEN
          l_region_type := 2;
        ELSIF (p_state IS NOT NULL OR p_state_code IS NOT NULL) THEN
          l_region_type := 1;
        ELSE
              l_region_type := 0;
        END IF;

        /*
          --  Validation regarding missing parameters or wrong format
          --  Same validatin are in the When-Validate_Record trigger on the Region block
          --  In WSHRGZON.fmb form
        */
   -- Same validation is already in API Default_Regions for p_conc_request_flag = 'Y'
   IF ( p_conc_request_flag = 'N' )
   THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.VALIDATE_REGION', WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
      Validate_Region( p_country          => p_country,
                       p_state            => p_state,
                       p_city             => p_city,
                       p_country_code     => p_country_code,
                       p_state_code       => p_state_code,
                       p_city_code        => p_city_code,
                       p_postal_code_from => p_postal_code_from,
                       p_postal_code_to   => p_postal_code_to,
                       x_status           => l_status,
                       x_error_msg        => l_error_msg );

      IF ( l_status = 2 ) THEN
         x_status    := l_status;
         x_error_msg := l_error_msg;
         x_region_id := -1;
       return;
        END IF;
   END IF;

   -- Bug 3396077 : Validation not done for country code combination in Regions interface program
   IF (p_interface_flag<>'Y') THEN
      IF ( p_conc_request_flag = 'Y' )
      THEN  -- { Concurrent Request
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
         WSH_REGIONS_SEARCH_PKG.Check_Region_Info(
               p_country          =>  p_country,
               p_state            =>  null,
               p_city             =>  null,
               p_postal_code_from =>  null,
               p_postal_code_to   =>  null,
               p_region_type      =>  0,
               p_search_flag      =>  'N',
               p_lang_code        =>  p_lang_code,
               x_return_status    =>  l_return_status,
               x_region_info      =>  l_region_info);

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
           x_status := 2;
            x_error_msg := 'WSH_UTIL_MESSAGE_U';
           x_region_id := -1;
        END IF;

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_ID_CODES_ONLY', WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
         WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only(
               p_country_code          =>   p_country_code,
               p_state_code            =>   null,
               p_city_code             =>   null,
               p_postal_code_from      =>   null,
               p_postal_code_to        =>   null,
               p_region_type           =>   0,
               p_language_code         =>   null,
               x_return_status         =>   l_return_status,
               x_region_id             =>   l_region_id);

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
       x_status := 2;
            x_error_msg := 'WSH_UTIL_MESSAGE_U';
       x_region_id := -1;
        END IF;

         IF (l_region_id <> -1) THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_ID_CODES_ONLY WITH LANGUAGE', WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
            WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only(
                  p_country_code          =>   p_country_code,
                  p_state_code            =>   null,
                  p_city_code             =>   null,
                  p_postal_code_from      =>   null,
                  p_postal_code_to        =>   null,
                  p_region_type           =>   0,
                  p_language_code         =>   p_lang_code,
                  x_return_status         =>   l_return_status,
                  x_region_id             =>   l_check_tl_id);

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
       x_status := 2;
               x_error_msg := 'WSH_UTIL_MESSAGE_U';
       x_region_id := -1;

       END IF;
         ELSE
            l_check_tl_id := -1;
        END IF;

      ELSE
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Wsh_Regions_Search_Pkg.Get_Region_Info(
  p_country     =>  p_country,
  p_country_region  =>  null,
  p_state       =>  null,
  p_city        =>  null,
  p_postal_code_from    =>  null,
  p_postal_code_to  =>  null,
  p_zone        =>  null,
  p_lang_code       =>  p_lang_code,
  p_country_code    =>  null,
  p_country_region_code =>  null,
  p_state_code      =>  null,
  p_city_code       =>  null,
  p_region_type     =>  0,
  p_interface_flag  =>  p_interface_flag,
  x_region_info     =>  l_region_info);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_ID_CODES_ONLY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Wsh_Regions_Search_Pkg.Get_Region_Id_Codes_Only(
    p_country_code      =>  p_country_code,
    p_country_region_code   =>  null,
    p_state_code        =>  null,
    p_city_code         =>  null,
    p_postal_code_from      =>  null,
    p_postal_code_to        =>  null,
    p_region_type       =>  0,
    p_interface_flag        =>  p_interface_flag,
    p_lang_code         =>  p_lang_code,
    x_region_id_non_tl      =>  l_region_id,
    x_region_id_with_tl     =>  l_check_tl_id);
      END IF;  -- } Concurrent Request

   IF (nvl(l_region_id,-1) <> -1 AND nvl(l_check_tl_id,-1) <> -1 AND nvl(l_region_info.region_id,-1) = -1 ) OR
        -- Both country and country code are present.
    (nvl(l_region_id,-1) =-1 AND nvl(l_check_tl_id,-1) = -1 AND nvl(l_region_info.region_id,-1) <> -1 )
    --Both country and country code are not present.
   THEN
         x_status := 2;
         x_error_msg := 'WSH_CAT_REGION_EXISTS';
         x_region_id := -1;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return;
    END IF;
   END IF;

--End of Fix for  Bug 3396077

    IF (p_insert_type IN ('ADD','INSERT')) THEN

      --
      --BUG NUMBER : 3222165
      --Unique region validation not done for data entered using Regions Interface Form.
      --

        IF (p_interface_flag<>'Y') THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Wsh_Regions_Search_Pkg.Get_Region_Info(
        p_country       =>  p_country,
        p_country_region    =>  p_country_region,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
        p_zone          =>  null,
        p_lang_code     =>  p_lang_code,
        p_country_code      =>  null,
        p_country_region_code   =>  null,
        p_state_code        =>  null,
        p_city_code     =>  null,
            p_region_type       =>  l_region_type,
        p_interface_flag    =>  p_interface_flag,
        x_region_info       =>  l_region_info);


        l_region_id := l_region_info.region_id;

          IF (l_region_id = -1) THEN

          IF ((p_city_code IS NULL OR p_city IS NOT NULL) AND
           (p_state_code IS NULL OR p_state IS NOT NULL) AND
           (p_country_code IS NULL OR p_country IS NOT NULL)) THEN

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_ID_CODES_ONLY',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Wsh_Regions_Search_Pkg.Get_Region_Id_Codes_Only(
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  p_country_region_code,
        p_state_code        =>  p_state_code,
        p_city_code     =>  p_city_code,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
            p_region_type       =>  l_region_type,
        p_interface_flag    =>  p_interface_flag,
        p_lang_code     =>  p_lang_code,
        x_region_id_non_tl  =>  l_region_id,
        x_region_id_with_tl =>  l_check_tl_id);

 -- fnd_file.put_line(fnd_file.log,'after region id codes 1 '||l_region_id||' x '||l_check_tl_id);
                IF (l_region_id <> -1 AND l_check_tl_id <> -1) THEN
           x_status := 2;
           x_error_msg := 'WSH_CAT_REGION_EXISTS';
               x_region_id := -1;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return;
                END IF;

          END IF;

              IF (l_region_id <> -1) THEN

                 -- Debug Statements
             --
             IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'region exists in tl table');
             END IF;

             l_tl_only_flag := 'Y';
             l_existing_region_id := l_region_id;
              END IF;

      ELSE
          x_status := 2;
          x_error_msg := 'WSH_CAT_REGION_EXISTS';
          x_region_id := -1;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          return;

      END IF;

    END IF;

    INSERT_REGION(
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  p_country_region_code,
        p_state_code        =>  p_state_code,
        p_city_code     =>  p_city_code,
        p_port_flag     =>  p_port_flag,
        p_airport_flag      =>  p_airport_flag,
        p_road_terminal_flag    =>  p_road_terminal_flag,
        p_rail_terminal_flag    =>  p_rail_terminal_flag,
        p_longitude     =>  p_longitude,
        p_latitude      =>  p_latitude,
        p_timezone      =>  p_timezone,
        p_continent     =>  p_continent,
        p_country       =>  p_country,
        p_country_region    =>  p_country_region,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_alternate_name    =>  p_alternate_name,
        p_county        =>  p_county,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
        p_lang_code     =>  p_lang_code,
        p_interface_flag    =>  p_interface_flag,
        p_tl_only_flag      =>  l_tl_only_flag,
        p_region_id     =>  l_existing_region_id,
        p_parent_region_id  =>  p_parent_region_id,
        p_user_id       =>  p_user_id,
        p_insert_parent_flag    =>  p_insert_parent_flag,
        p_region_dff        =>  p_region_dff,
        x_region_id     =>  l_region_id,
        x_status        =>  l_status,
        x_error_msg     =>  l_error_msg,
                p_deconsol_location_id  =>   p_deconsol_location_id);

       x_region_id := l_region_id;
       x_status := l_status;
       x_error_msg := l_error_msg;
   ELSE
      IF (p_region_id = -1 OR p_region_id IS NULL)
      THEN
         IF ( p_conc_request_flag = 'Y' )
         THEN  -- { Concurrent Request
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_REGIONS_SEARCH_PKG.Check_Region_Info(
                  p_country          =>  p_country,
                  p_state            =>  p_state,
                  p_city             =>  p_city,
                  p_postal_code_from =>  p_postal_code_from,
                  p_postal_code_to   =>  p_postal_code_to,
                  p_region_type      =>  l_region_type,
                  p_search_flag      =>  'N',
                  p_lang_code        =>  p_lang_code,
                  x_return_status    =>  l_return_status,
                  x_region_info      =>  l_region_info);

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               x_status := 2;
               x_error_msg := 'WSH_UTIL_MESSAGE_U';
               x_region_id := -1;
            END IF;
         ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      Wsh_Regions_Search_Pkg.Get_Region_Info(
        p_country       =>  p_country,
        p_country_region    =>  p_country_region,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
        p_zone          =>  null,
        p_lang_code     =>  p_lang_code,
        p_country_code      =>  null,
        p_country_region_code   =>  null,
        p_state_code        =>  null,
        p_city_code     =>  null,
            p_region_type       =>  l_region_type,
        p_interface_flag    =>  p_interface_flag,
        x_region_info       =>  l_region_info);
         END IF;

       l_region_id := l_region_info.region_id;

       IF (l_region_id = -1 AND
        (p_city_code IS NULL OR p_city IS NOT NULL) AND
        (p_state_code IS NULL OR p_state IS NOT NULL) AND
            (p_country_code IS NULL OR p_country IS NOT NULL))
         THEN
            IF ( p_conc_request_flag = 'Y' )
            THEN  -- { p_conc_request_flag
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_ID_CODES_ONLY', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only(
                     p_country_code          =>   p_country_code,
                     p_state_code            =>   p_state_code,
                     p_city_code             =>   p_city_code,
                     p_postal_code_from      =>   p_postal_code_from,
                     p_postal_code_to        =>   p_postal_code_to,
                     p_region_type           =>   l_region_type,
                     p_language_code         =>   null,
                     x_return_status         =>   l_return_status,
                     x_region_id             =>   l_region_id);

               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  x_status := 2;
                  x_error_msg := 'WSH_UTIL_MESSAGE_U';
                  x_region_id := -1;
               END IF;

               IF (l_region_id <> -1) THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.CHECK_REGION_ID_CODES_ONLY WITH LANGUAGE', WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  WSH_REGIONS_SEARCH_PKG.Check_Region_Id_Codes_Only(
                        p_country_code          =>   p_country_code,
                        p_state_code            =>   p_state_code,
                        p_city_code             =>   p_city_code,
                        p_postal_code_from      =>   p_postal_code_from,
                        p_postal_code_to        =>   p_postal_code_to,
                        p_region_type           =>   l_region_type,
                        p_language_code         =>   p_lang_code,
                        x_return_status         =>   l_return_status,
                        x_region_id             =>   l_check_tl_id);

                  IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
                  THEN
                     x_status := 2;
                     x_error_msg := 'WSH_UTIL_MESSAGE_U';
                     x_region_id := -1;
                  END IF;
               END IF;
            ELSE
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_ID_CODES_ONLY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
     Wsh_Regions_Search_Pkg.Get_Region_Id_Codes_Only(
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  p_country_region_code,
        p_state_code        =>  p_state_code,
        p_city_code     =>  p_city_code,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
            p_region_type       =>  l_region_type,
        p_interface_flag    =>  p_interface_flag,
        p_lang_code     =>  p_lang_code,
        x_region_id_non_tl  =>  l_region_id,
        x_region_id_with_tl =>  l_check_tl_id);
            END IF;

-- fnd_file.put_line(fnd_file.log,'after region id codes 2 '||l_region_id||' x '||l_check_tl_id);
              IF (l_region_id <> -1 AND l_check_tl_id <> -1) THEN
             x_status := 2;
             x_error_msg := 'WSH_CAT_DUPLICATE_REGION';
             x_region_id := -1;
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             return;
              END IF;

       END IF;
      ELSE
       l_region_id := p_region_id;
      END IF;

      IF (l_region_id <> -1) THEN
        x_region_id := l_region_id;

            IF (p_interface_flag = 'Y') THEN
            UPDATE WSH_REGIONS_INTERFACE
            SET    COUNTRY_CODE = p_country_code,
               COUNTRY_REGION_CODE = p_country_region_code,
               STATE_CODE = p_state_code,
               CITY_CODE = p_city_code,
               PORT_FLAG = p_port_flag,
                   AIRPORT_FLAG = p_airport_flag,
                   ROAD_TERMINAL_FLAG = p_road_terminal_flag,
                   RAIL_TERMINAL_FLAG = p_rail_terminal_flag,
               PROCESSED_FLAG = null,
               LAST_UPDATE_DATE = sysdate,
               LAST_UPDATED_BY = p_user_id
            WHERE REGION_ID = l_region_id;

            UPDATE WSH_REGIONS_TL_INTERFACE
            SET    CONTINENT = p_continent,
               COUNTRY = p_country,
                   COUNTRY_REGION = p_country_region,
               STATE = p_state,
               CITY = p_city,
               ALTERNATE_NAME = p_alternate_name,
               COUNTY = p_county,
               POSTAL_CODE_FROM = p_postal_code_from,
               POSTAL_CODE_TO = p_postal_code_to,
               LAST_UPDATE_DATE = sysdate,
               LAST_UPDATED_BY = p_user_id
            WHERE REGION_ID = l_region_id
            AND   LANGUAGE = p_lang_code;

            IF (SQL%NOTFOUND) THEN
                  INSERT INTO WSH_REGIONS_TL_INTERFACE (
              LANGUAGE,
              REGION_ID,
              CONTINENT,
              COUNTRY,
              COUNTRY_REGION,
              STATE,
              CITY,
              ALTERNATE_NAME,
              COUNTY,
              POSTAL_CODE_FROM,
              POSTAL_CODE_TO,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN)
                  VALUES (
              p_lang_code,
              l_region_id,
              p_continent,
              p_country,
              p_country_region,
              p_state,
              p_city,
              p_alternate_name,
              p_county,
              p_postal_code_from,
              p_postal_code_to,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              p_user_id);
            END IF;
         ELSE
          --
          -- Update the DFF attributes for the passed region.
          --
            UPDATE WSH_REGIONS
            SET    ATTRIBUTE_CATEGORY = p_region_dff.attribute_category,
            ATTRIBUTE1 = p_region_dff.attribute1,
            ATTRIBUTE2 = p_region_dff.attribute2,
            ATTRIBUTE3 = p_region_dff.attribute3,
            ATTRIBUTE4 = p_region_dff.attribute4,
            ATTRIBUTE5 = p_region_dff.attribute5,
            ATTRIBUTE6 = p_region_dff.attribute6,
            ATTRIBUTE7 = p_region_dff.attribute7,
            ATTRIBUTE8 = p_region_dff.attribute8,
            ATTRIBUTE9 = p_region_dff.attribute9,
            ATTRIBUTE10 = p_region_dff.attribute10,
            ATTRIBUTE11 = p_region_dff.attribute11,
            ATTRIBUTE12 = p_region_dff.attribute12,
            ATTRIBUTE13 = p_region_dff.attribute13,
            ATTRIBUTE14 = p_region_dff.attribute14,
            ATTRIBUTE15 = p_region_dff.attribute15
            WHERE region_id = l_region_id;

/*
        SELECT zone_level INTO l_parent_zone_level
        FROM wsh_regions WHERE region_id = l_region_id;
*/
        -- Bug 3364618 : Replaced select statement by a cursor.

                OPEN get_zone_level(l_region_id);
        FETCH get_zone_level INTO l_parent_zone_level;
        CLOSE get_zone_level;

        --              --
        -- Update values for the other attributes. Update the value of child records
        --


        FOR reg IN child_regions(l_region_id) LOOP

               -- Debug Statements
               --
               IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, ' updating region '||reg.region_id);
               END IF;

/*         select state_code
           into   l_update_state_code
           from   wsh_regions
           where  region_id = reg.parent_region_id ;
*/

                   --Bug 3364618 : Replaced select statement by a cursor.

           OPEN get_state_code(reg.parent_region_id);
               FETCH get_state_code INTO l_update_state_code, l_update_city_code;
           CLOSE get_state_code;

           update WSH_REGIONS set
               COUNTRY_CODE = nvl(p_country_code, COUNTRY_CODE),
               COUNTRY_REGION_CODE = nvl(p_country_region_code, COUNTRY_REGION_CODE),
               STATE_CODE = decode(reg.zone_level, 2, l_update_state_code, 3, l_update_state_code,
                       decode(l_parent_zone_level, 1, p_state_code, nvl(p_state_code, STATE_CODE))),
               CITY_CODE = decode(l_parent_zone_level, 2, p_city_code, nvl(p_city_code, CITY_CODE)),
               PORT_FLAG = nvl(p_port_flag,PORT_FLAG),
                   AIRPORT_FLAG = nvl(p_airport_flag,AIRPORT_FLAG),
                   ROAD_TERMINAL_FLAG = nvl(p_road_terminal_flag, ROAD_TERMINAL_FLAG),
                   RAIL_TERMINAL_FLAG = nvl(p_rail_terminal_flag, RAIL_TERMINAL_FLAG),
               LAST_UPDATE_DATE = sysdate,
               LAST_UPDATED_BY = p_user_id,

               -- bug 4509707 : deconsol_location_id should not be propagated to sub-regions, update it only for the current region (l_region_id)
               -- deconsol_location_id = p_deconsol_location_id
               deconsol_location_id = decode(reg.region_id, l_region_id, p_deconsol_location_id, deconsol_location_id)
           where REGION_ID = reg.region_id;

           update WSH_REGIONS_TL set
               CONTINENT = nvl(p_continent, CONTINENT),
               COUNTRY = nvl(p_country, COUNTRY),
                   COUNTRY_REGION = nvl(p_country_region, COUNTRY_REGION),
               STATE = nvl(p_state, STATE),
               CITY = nvl(p_city, CITY),
               ALTERNATE_NAME = nvl(p_alternate_name, ALTERNATE_NAME),
               COUNTY = nvl(p_county, COUNTY),
               POSTAL_CODE_FROM = nvl(p_postal_code_from, POSTAL_CODE_FROM),
               POSTAL_CODE_TO = nvl(p_postal_code_to, POSTAL_CODE_TO),
               LAST_UPDATE_DATE = sysdate,
               LAST_UPDATED_BY = p_user_id
           where REGION_ID = reg.region_id and
               LANGUAGE = p_lang_code;

                END LOOP;

            IF (SQL%NOTFOUND) THEN
               IF (p_insert_type = 'SYNC') THEN
                  INSERT INTO WSH_REGIONS_TL (
              LANGUAGE,
              REGION_ID,
              CONTINENT,
              COUNTRY,
              COUNTRY_REGION,
              STATE,
              CITY,
              ALTERNATE_NAME,
              COUNTY,
              POSTAL_CODE_FROM,
              POSTAL_CODE_TO,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN)
                  VALUES (
              p_lang_code,
              l_region_id,
              p_continent,
              p_country,
              p_country_region,
              p_state,
              p_city,
              p_alternate_name,
              p_county,
              p_postal_code_from,
              p_postal_code_to,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              p_user_id);

          else --could not find the region to update
             x_status := 2;
             x_error_msg := 'WSH_CAT_CANNOT_UPDATE_REGION';
             x_region_id := -1;
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             return;
               END IF;
             END IF;

            IF ( p_conc_request_flag = 'Y' )
            THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.UPDATE_GLOBAL_TABLE', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               Update_Global_Table(
                        p_country           =>  p_country,
                        p_state             =>  p_state,
                        p_city              =>  p_city,
                        p_country_code      =>  p_country_code,
                        p_state_code        =>  p_state_code,
                        p_city_code         =>  p_city_code,
                        p_region_id         =>  l_region_id,
                        p_postal_code_from  =>  p_postal_code_from,
                        p_postal_code_to    =>  p_postal_code_to,
                        p_parent_zone_level =>  l_parent_zone_level,
                        p_lang_code         =>  p_lang_code,
                        x_return_status     =>  l_return_status );

               -- Error Handling Part
               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  x_status := 2;
                  x_error_msg := 'WSH_UTIL_MESSAGE_U';
                  x_region_id := -1;
               END IF;
            END IF;
         END IF;
      ELSE
         IF (p_insert_type = 'SYNC') THEN

           INSERT_REGION(
            p_country_code      =>  p_country_code,
            p_country_region_code   =>  p_country_region_code,
            p_state_code        =>  p_state_code,
            p_city_code     =>  p_city_code,
            p_port_flag     =>  p_port_flag,
            p_airport_flag      =>  p_airport_flag,
            p_road_terminal_flag    =>  p_road_terminal_flag,
            p_rail_terminal_flag    =>  p_rail_terminal_flag,
            p_longitude     =>  p_longitude,
            p_latitude      =>  p_latitude,
            p_timezone      =>  p_timezone,
            p_continent     =>  p_continent,
            p_country       =>  p_country,
            p_country_region    =>  p_country_region,
            p_state         =>  p_state,
            p_city          =>  p_city,
            p_alternate_name    =>  p_alternate_name,
            p_county        =>  p_county,
            p_postal_code_from  =>  p_postal_code_from,
            p_postal_code_to    =>  p_postal_code_to,
            p_lang_code     =>  p_lang_code,
            p_interface_flag    =>  p_interface_flag,
            p_tl_only_flag      =>  l_tl_only_flag,
            p_region_id     =>  l_existing_region_id,
            p_parent_region_id  =>  p_parent_region_id,
            p_user_id       =>  p_user_id,
            p_insert_parent_flag    =>  p_insert_parent_flag,
            p_region_dff        =>  p_region_dff,
            x_region_id     =>  l_region_id,
            x_status        =>  l_status,
            x_error_msg     =>  l_error_msg,
                        p_deconsol_location_id  =>   p_deconsol_location_id,
                  p_conc_request_flag    =>   p_conc_request_flag);

           x_region_id := l_region_id;
           x_status := l_status;
           x_error_msg := l_error_msg;
         ELSE
           x_region_id := -1;
           x_status := 2;
           x_error_msg := 'WSH_CAT_CANNOT_UPDATE_REGION';
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return;
         END IF;
      END IF;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Update_Region;

  --
  -- Procedure: Delete_Region
  --
  -- Purpose:   Deletes a region (for interface use only)
  --

  PROCEDURE Delete_Region (
    p_region_id         IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_interface_flag        IN  VARCHAR2,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2) IS

  CURSOR lock_rows IS
  SELECT r.region_id
  FROM   wsh_regions_interface r, wsh_regions_tl_interface t
  WHERE  r.region_id = t.region_id AND
     r.region_id = p_region_id AND
     t.language = nvl(p_lang_code, t.language)
  FOR UPDATE OF r.region_id NOWAIT;

  l_region_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
     END IF;
     --
     IF (p_interface_flag = 'Y') THEN

        OPEN lock_rows;
    FETCH lock_rows INTO l_region_id;
    CLOSE lock_rows;

    DELETE FROM wsh_regions_tl_interface WHERE region_id = l_region_id AND language= nvl(p_lang_code, language);
    DELETE FROM wsh_regions_interface WHERE region_id = l_region_id;

     ELSE
    x_status := 2;
    x_error_msg := 'Cannot delete region';
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Delete_Region;


--
--  Procedure:      Lock_Region
--  Parameters:     p_region_id - region_id for region to be locked
--          x_return_status - Status of procedure call
--  Description:    This procedure will lock a region record. It is
--          specifically designed for use by the form.
--

  PROCEDURE Lock_Region
     (  p_region_id         IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_region_dff            IN  REGION_DFF_REC DEFAULT NULL,
    x_status            OUT NOCOPY  NUMBER,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL) IS

  record_locked  EXCEPTION;
  PRAGMA EXCEPTION_INIT(record_locked, -54);

  CURSOR lock_row IS
  SELECT w.region_id, w.country_code, w.state_code,w.city_code,w.attribute_category,
         w.attribute1,w.attribute2,w.attribute3,w.attribute4,w.attribute5,
         w.attribute6,w.attribute7,w.attribute8,w.attribute9,w.attribute10,
     w.attribute11,w.attribute12,w.attribute13,w.attribute14,w.attribute15,
         w.deconsol_location_id
  FROM  wsh_regions w
  WHERE w.region_id = p_region_id
  FOR UPDATE OF w.region_id NOWAIT;

  CURSOR lock_row_tl IS
  SELECT t.region_id, t.country, t.state, t.city, t.postal_code_from, t.postal_code_to
  FROM  wsh_regions_tl t
  WHERE t.language = p_lang_code
    AND t.region_id = p_region_id
  FOR UPDATE OF t.region_id NOWAIT;

  Recinfo lock_row%ROWTYPE;
  Recinfo_tl lock_row_tl%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE_CATEGORY',P_REGION_DFF.ATTRIBUTE_CATEGORY);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE1',P_REGION_DFF.ATTRIBUTE1);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE2',P_REGION_DFF.ATTRIBUTE2);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE3',P_REGION_DFF.ATTRIBUTE3);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE4',P_REGION_DFF.ATTRIBUTE4);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE5',P_REGION_DFF.ATTRIBUTE5);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE6',P_REGION_DFF.ATTRIBUTE6);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE7',P_REGION_DFF.ATTRIBUTE7);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE8',P_REGION_DFF.ATTRIBUTE8);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE9',P_REGION_DFF.ATTRIBUTE9);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE10',P_REGION_DFF.ATTRIBUTE10);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE11',P_REGION_DFF.ATTRIBUTE11);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE12',P_REGION_DFF.ATTRIBUTE12);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE13',P_REGION_DFF.ATTRIBUTE13);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE14',P_REGION_DFF.ATTRIBUTE14);
     WSH_DEBUG_SV.log(l_module_name,'P_REGION_DFF.ATTRIBUTE15',P_REGION_DFF.ATTRIBUTE15);
         WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);
     END IF;
     --
     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;

     IF (lock_row%NOTFOUND) THEN
    CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
               (Recinfo.region_id = p_region_id)
         AND (  (Recinfo.country_code = p_country_code)
              OR ( (Recinfo.country_code IS NULL) AND (p_country_code IS NULL)))
         AND (  (Recinfo.state_code = p_state_code)
              OR (  (Recinfo.state_code IS NULL) AND  (p_state_code IS NULL)))
         AND (  (Recinfo.city_code = p_city_code)
              OR (  (Recinfo.city_code IS NULL) AND  (p_city_code IS NULL)))
     AND (   (Recinfo.attribute_category = p_region_dff.attribute_category)
              OR  ((Recinfo.attribute_category IS NULL) AND (p_region_dff.attribute_category IS NULL)))
     AND (   (Recinfo.attribute1 = p_region_dff.attribute1)
              OR  ((Recinfo.attribute1 IS NULL) AND (p_region_dff.attribute1 IS NULL)))
     AND (   (Recinfo.attribute2 = p_region_dff.attribute2)
              OR  ((Recinfo.attribute2 IS NULL) AND (p_region_dff.attribute2 IS NULL)))
     AND (   (Recinfo.attribute3 = p_region_dff.attribute3)
              OR  ((Recinfo.attribute3 IS NULL) AND (p_region_dff.attribute3 IS NULL)))
         AND (   (Recinfo.attribute4 = p_region_dff.attribute4)
              OR  ((Recinfo.attribute4 IS NULL) AND (p_region_dff.attribute4 IS NULL)))
     AND (   (Recinfo.attribute5 = p_region_dff.attribute5)
              OR  ((Recinfo.attribute5 IS NULL) AND (p_region_dff.attribute5 IS NULL)))
     AND (   (Recinfo.attribute6 = p_region_dff.attribute6)
              OR  ((Recinfo.attribute6 IS NULL) AND (p_region_dff.attribute6 IS NULL)))
     AND (   (Recinfo.attribute7 = p_region_dff.attribute7)
              OR  ((Recinfo.attribute7 IS NULL) AND (p_region_dff.attribute7 IS NULL)))
         AND (   (Recinfo.attribute8 = p_region_dff.attribute8)
              OR  ((Recinfo.attribute8 IS NULL) AND (p_region_dff.attribute8 IS NULL)))
     AND (   (Recinfo.attribute9 = p_region_dff.attribute9)
              OR  ((Recinfo.attribute9 IS NULL) AND (p_region_dff.attribute9 IS NULL)))
     AND (   (Recinfo.attribute10 = p_region_dff.attribute10)
              OR  ((Recinfo.attribute10 IS NULL) AND (p_region_dff.attribute10 IS NULL)))
     AND (   (Recinfo.attribute11 = p_region_dff.attribute11)
              OR  ((Recinfo.attribute11 IS NULL) AND (p_region_dff.attribute11 IS NULL)))
     AND (   (Recinfo.attribute12 = p_region_dff.attribute12)
              OR  ((Recinfo.attribute12 IS NULL) AND (p_region_dff.attribute12 IS NULL)))
     AND (   (Recinfo.attribute13 = p_region_dff.attribute13)
              OR  ((Recinfo.attribute13 IS NULL) AND (p_region_dff.attribute13 IS NULL)))
         AND (   (Recinfo.attribute14 = p_region_dff.attribute14)
              OR  ((Recinfo.attribute14 IS NULL) AND (p_region_dff.attribute14 IS NULL)))
     AND (   (Recinfo.attribute15 = p_region_dff.attribute15)
              OR  ((Recinfo.attribute15 IS NULL) AND (p_region_dff.attribute15 IS NULL)))
     AND (   (Recinfo.deconsol_location_id = p_deconsol_location_id)
              OR  ((Recinfo.deconsol_location_id IS NULL) AND (p_deconsol_location_id IS NULL)))

       ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

     OPEN  lock_row_tl;
     FETCH lock_row_tl INTO Recinfo_tl;

     IF (lock_row_tl%NOTFOUND) THEN
    CLOSE lock_row_tl;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row_tl;

     IF (
                (Recinfo_tl.region_id = p_region_id)
         AND (  (Recinfo_tl.country = p_country)
              OR (  (Recinfo_tl.country IS NULL) AND  (p_country IS NULL)))
         AND (  (Recinfo_tl.state = p_state)
              OR (  (Recinfo_tl.state IS NULL) AND  (p_state IS NULL)))
         AND (  (Recinfo_tl.city = p_city)
              OR (  (Recinfo_tl.city IS NULL) AND  (p_city IS NULL)))
         AND (  (Recinfo_tl.postal_code_from = p_postal_code_from)
              OR (  (Recinfo_tl.postal_code_from IS NULL) AND  (p_postal_code_from IS NULL)))
         AND (  (Recinfo_tl.postal_code_to = p_postal_code_to)
              OR (  (Recinfo_tl.postal_code_to IS NULL) AND  (p_postal_code_to IS NULL)))
     ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN RECORD_LOCKED THEN
    if (lock_row%ISOPEN) then
       close lock_row;
    end if;

    if (lock_row_tl%ISOPEN) then
       close lock_row_tl;
    end if;
        -- Fixing Lock message bug
        fnd_message.set_name('WSH', 'WSH_FORM_RECORD_IS_CHANGED');
        app_exception.raise_exception;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
        --
     WHEN others THEN
    if (lock_row%ISOPEN) then
       close lock_row;
    end if;

    if (lock_row_tl%ISOPEN) then
       close lock_row_tl;
    end if;

    --raise;
        app_exception.raise_exception;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Lock_Region;

--
--  Procedure:      Lock_Region_Interface
--  Parameters:     p_region_id - region_id for region to be locked
--          x_return_status - Status of procedure call
--  Description:    This procedure will lock a region interface record. It is
--          specifically designed for use by the form.
--

  PROCEDURE Lock_Region_Interface
     (  p_region_id         IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    x_status            OUT NOCOPY  NUMBER) IS


  CURSOR lock_row IS
  SELECT w.region_id, w.country_code, w.state_code, w.city_code
  FROM  wsh_regions_interface w
  WHERE w.region_id = p_region_id
  FOR UPDATE OF w.region_id NOWAIT;

  CURSOR lock_row_tl IS
  SELECT t.region_id, t.country, t.state, t.city, t.postal_code_from, t.postal_code_to
  FROM  wsh_regions_tl_interface t
  WHERE t.language = p_lang_code
    AND t.region_id = p_region_id
  FOR UPDATE OF t.region_id NOWAIT;

  Recinfo lock_row%ROWTYPE;
  Recinfo_tl lock_row_tl%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_REGION_INTERFACE';
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
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
     END IF;
     --
     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;

     IF (lock_row%NOTFOUND) THEN
    CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
                (Recinfo.region_id = p_region_id)
         AND (  (Recinfo.country_code = p_country_code)
              OR (  (Recinfo.country_code IS NULL) AND  (p_country_code IS NULL)))
         AND (  (Recinfo.state_code = p_state_code)
              OR (  (Recinfo.state_code IS NULL) AND  (p_state_code IS NULL)))
         AND (  (Recinfo.city_code = p_city_code)
              OR (  (Recinfo.city_code IS NULL) AND  (p_city_code IS NULL)))
     ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

     OPEN  lock_row_tl;
     FETCH lock_row_tl INTO Recinfo_tl;

     IF (lock_row_tl%NOTFOUND) THEN
    CLOSE lock_row_tl;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row_tl;

     IF (
                (Recinfo_tl.region_id = p_region_id)
         AND (  (Recinfo_tl.country = p_country)
              OR (  (Recinfo_tl.country IS NULL) AND  (p_country IS NULL)))
         AND (  (Recinfo_tl.state = p_state)
              OR (  (Recinfo_tl.state IS NULL) AND  (p_state IS NULL)))
         AND (  (Recinfo_tl.city = p_city)
              OR (  (Recinfo_tl.city IS NULL) AND  (p_city IS NULL)))
         AND (  (Recinfo_tl.postal_code_from = p_postal_code_from)
              OR (  (Recinfo_tl.postal_code_from IS NULL) AND  (p_postal_code_from IS NULL)))
         AND (  (Recinfo_tl.postal_code_to = p_postal_code_to)
              OR (  (Recinfo_tl.postal_code_to IS NULL) AND  (p_postal_code_to IS NULL)))
     ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN others THEN
    if (lock_row%ISOPEN) then
       close lock_row;
    end if;

    if (lock_row_tl%ISOPEN) then
       close lock_row_tl;
    end if;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    raise;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Lock_Region_Interface;

  --
  -- Procedure: Update_Zone (this is called from the Regions and Zones form)
  --
  -- Purpose:   Updates or inserts a new zone
  --

  PROCEDURE Update_Zone (
    p_insert_type           IN  VARCHAR2,
    p_zone_id           IN  NUMBER,
    p_zone_name             IN  VARCHAR2,
    p_zone_level            IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    p_zone_dff          IN      REGION_DFF_REC DEFAULT NULL,
    x_zone_id           OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg     OUT NOCOPY  VARCHAR2,
        p_deconsol_location_id          IN NUMBER DEFAULT NULL) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ZONE';
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
          WSH_DEBUG_SV.log(l_module_name,'P_INSERT_TYPE',P_INSERT_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ZONE_NAME',P_ZONE_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_ZONE_LEVEL',P_ZONE_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE_CATEGORY',P_ZONE_DFF.ATTRIBUTE_CATEGORY);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE1',P_ZONE_DFF.ATTRIBUTE1);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE2',P_ZONE_DFF.ATTRIBUTE2);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE3',P_ZONE_DFF.ATTRIBUTE3);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE4',P_ZONE_DFF.ATTRIBUTE4);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE5',P_ZONE_DFF.ATTRIBUTE5);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE6',P_ZONE_DFF.ATTRIBUTE6);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE7',P_ZONE_DFF.ATTRIBUTE7);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE8',P_ZONE_DFF.ATTRIBUTE8);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE9',P_ZONE_DFF.ATTRIBUTE9);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE10',P_ZONE_DFF.ATTRIBUTE10);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE11',P_ZONE_DFF.ATTRIBUTE11);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE12',P_ZONE_DFF.ATTRIBUTE12);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE13',P_ZONE_DFF.ATTRIBUTE13);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE14',P_ZONE_DFF.ATTRIBUTE14);
      WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE15',P_ZONE_DFF.ATTRIBUTE15);
      END IF;
      --
      Update_Zone (
    p_insert_type   => p_insert_type,
    p_zone_id   => p_zone_id,
    p_zone_name     => p_zone_name,
    p_zone_level    => p_zone_level,
    p_zone_type     => 10,
    p_lang_code     => p_lang_code,
    p_user_id       => p_user_id,
    p_zone_dff  => p_zone_dff,
    x_zone_id   => x_zone_id,
    x_status    => x_status,
    x_error_msg     => x_error_msg,
        p_deconsol_location_id => p_deconsol_location_id);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END;


  --
  -- Procedure: Update_Zone
  --
  -- Purpose:   Updates or inserts a new zone
  --

  PROCEDURE Update_Zone (
    p_insert_type           IN  VARCHAR2,
    p_zone_id           IN  NUMBER,
    p_zone_name             IN  VARCHAR2,
    p_zone_level            IN  NUMBER,
    p_zone_type         IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    p_zone_dff          IN      REGION_DFF_REC DEFAULT NULL,
    x_zone_id           OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL) IS

  CURSOR check_zone IS
  SELECT region_id
  FROM   wsh_regions_tl
  WHERE  zone = p_zone_name AND
     language = p_lang_code;

  l_zone_id NUMBER;

--
  l_debug_on BOOLEAN;
--
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ZONE';
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
         WSH_DEBUG_SV.log(l_module_name,'P_INSERT_TYPE',P_INSERT_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_NAME',P_ZONE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_LEVEL',P_ZONE_LEVEL);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_TYPE',P_ZONE_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE_CATEGORY',P_ZONE_DFF.ATTRIBUTE_CATEGORY);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE1',P_ZONE_DFF.ATTRIBUTE1);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE2',P_ZONE_DFF.ATTRIBUTE2);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE3',P_ZONE_DFF.ATTRIBUTE3);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE4',P_ZONE_DFF.ATTRIBUTE4);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE5',P_ZONE_DFF.ATTRIBUTE5);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE6',P_ZONE_DFF.ATTRIBUTE6);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE7',P_ZONE_DFF.ATTRIBUTE7);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE8',P_ZONE_DFF.ATTRIBUTE8);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE9',P_ZONE_DFF.ATTRIBUTE9);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE10',P_ZONE_DFF.ATTRIBUTE10);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE11',P_ZONE_DFF.ATTRIBUTE11);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE12',P_ZONE_DFF.ATTRIBUTE12);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE13',P_ZONE_DFF.ATTRIBUTE13);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE14',P_ZONE_DFF.ATTRIBUTE14);
     WSH_DEBUG_SV.log(l_module_name,'P_ZONE_DFF.ATTRIBUTE15',P_ZONE_DFF.ATTRIBUTE15);
         WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);

     END IF;
     --
     OPEN check_zone;
     FETCH check_zone INTO l_zone_id;
     CLOSE check_zone;

     IF (p_insert_type IN ('ADD','INSERT')) THEN

        IF (l_zone_id <> 0) THEN
        x_status := 2;
        x_error_msg := 'WSH_CAT_ZONE_EXISTS';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
        END IF;

    INSERT INTO WSH_REGIONS (
        REGION_ID,
        REGION_TYPE,
        PARENT_REGION_ID,
        ZONE_LEVEL,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
                DECONSOL_LOCATION_ID)
    VALUES (
        wsh_regions_s.nextval,
        p_zone_type,
        -1,
        p_zone_level,
        p_zone_dff.attribute_category,
        p_zone_dff.attribute1,
        p_zone_dff.attribute2,
        p_zone_dff.attribute3,
        p_zone_dff.attribute4,
        p_zone_dff.attribute5,
        p_zone_dff.attribute6,
        p_zone_dff.attribute7,
        p_zone_dff.attribute8,
        p_zone_dff.attribute9,
        p_zone_dff.attribute10,
        p_zone_dff.attribute11,
        p_zone_dff.attribute12,
        p_zone_dff.attribute13,
        p_zone_dff.attribute14,
        p_zone_dff.attribute15,
        p_user_id,
        sysdate,
        p_user_id,
        sysdate,
        p_user_id,
                p_deconsol_location_id)
    RETURNING region_id
    INTO l_zone_id;

    INSERT INTO WSH_REGIONS_TL (
        LANGUAGE,
        REGION_ID,
        ZONE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES (
        p_lang_code,
        l_zone_id,
        p_zone_name,
        p_user_id,
        sysdate,
        p_user_id,
        sysdate,
        p_user_id);
     ELSE  -- for update

        IF (l_zone_id >= 0 AND l_zone_id <> p_zone_id) THEN
        x_status := 2;
        x_error_msg := 'WSH_CAT_ZONE_EXISTS';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
        END IF;

    UPDATE wsh_regions
    SET zone_level = p_zone_level,
        attribute_category = p_zone_dff.attribute_category,
        attribute1 = p_zone_dff.attribute1,
        attribute2 = p_zone_dff.attribute2,
        attribute3 = p_zone_dff.attribute3,
        attribute4 = p_zone_dff.attribute4,
        attribute5 = p_zone_dff.attribute5,
        attribute6 = p_zone_dff.attribute6,
        attribute7 = p_zone_dff.attribute7,
        attribute8 = p_zone_dff.attribute8,
        attribute9 = p_zone_dff.attribute9,
        attribute10 = p_zone_dff.attribute10,
        attribute11 = p_zone_dff.attribute11,
        attribute12 = p_zone_dff.attribute12,
        attribute13 = p_zone_dff.attribute13,
        attribute14 = p_zone_dff.attribute14,
        attribute15 = p_zone_dff.attribute15,
        last_updated_by = p_user_id,
            last_update_date = sysdate,
                deconsol_location_id = p_deconsol_location_id
        WHERE  region_id = p_zone_id;

    UPDATE wsh_regions_tl
    SET    zone = p_zone_name,
           --language = p_lang_code,--bug 8513956 moved language in where clause
           last_updated_by = p_user_id,
           last_update_date = sysdate
        WHERE  region_id = p_zone_id
        AND    language = p_lang_code;--bug 8513956

    l_zone_id := p_zone_id;

     END IF;

     x_zone_id := l_zone_id;

--
-- Debug Statements
--
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
  END Update_Zone;

--
--  Procedure:      Lock_Zone
--  Parameters:     p_zone_id - zone_id for zone to be locked
--          x_return_status - Status of procedure call
--  Description:    This procedure will lock a zone record. It is
--          specifically designed for use by the form.
--

  PROCEDURE Lock_Zone
    (p_zone_id          IN  NUMBER,
    p_lang_code         IN  VARCHAR2,
    p_zone_name             IN  VARCHAR2,
    p_zone_level            IN  VARCHAR2,
    x_status            OUT NOCOPY  NUMBER) IS

  CURSOR lock_row IS
  SELECT w.region_id, t.zone, w.zone_level
  FROM  wsh_regions w, wsh_regions_tl t
  WHERE w.region_id = t.region_id
    AND t.language = p_lang_code
  FOR UPDATE OF w.region_id, t.region_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ZONE';
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
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_NAME',P_ZONE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_LEVEL',P_ZONE_LEVEL);
     END IF;
     --
     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;

     IF (lock_row%NOTFOUND) THEN
    CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
                (Recinfo.region_id = p_zone_id)
         AND    (Recinfo.zone = p_zone_name)
         AND (  (Recinfo.zone_level = p_zone_level)
              OR (  (Recinfo.zone_level IS NULL) AND  (p_zone_level IS NULL)))
     ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN others THEN
    if (lock_row%ISOPEN) then
       close lock_row;
    end if;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    raise;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Lock_Zone;

  --
  -- Procedure: Update_Zone_Region
  --
  -- Purpose:   Updates or inserts a new zone region
  --        Call another Update_Zone_Region with default p_zone_type='10'

  PROCEDURE Update_Zone_Region (
    p_insert_type           IN  VARCHAR2,
    p_zone_region_id        IN  NUMBER,
    p_zone_id           IN  NUMBER,
    p_country           IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    x_zone_region_id        OUT NOCOPY  NUMBER,
    x_region_id         OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2) IS
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ZONE_REGION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_INSERT_TYPE',P_INSERT_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_ZONE_REGION_ID',P_ZONE_REGION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
        WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
        WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
        WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
    END IF;
    --
    Update_Zone_Region(
        p_insert_type       => p_insert_type,
        p_zone_region_id    => p_zone_region_id,
        p_zone_id       => p_zone_id,
        p_region_id     => null,
        p_country       => p_country,
        p_state         => p_state,
        p_city          => p_city,
        p_postal_code_from  => p_postal_code_from,
        p_postal_code_to    => p_postal_code_to,
        p_lang_code     => p_lang_code,
        p_country_code      => p_country_code,
        p_state_code        => p_state_code,
        p_city_code         => p_city_code,
        p_user_id       => p_user_id,
        p_zone_type     => '10',
        x_zone_region_id    => x_zone_region_id,
        x_region_id     => x_region_id,
        x_status        => x_status,
        x_error_msg     => x_error_msg);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Update_Zone_Region;

  --
  -- Procedure: Update_Zone_Region
  --
  -- Purpose:   Updates or inserts a new zone region
  --

  PROCEDURE Update_Zone_Region (
    p_insert_type           IN  VARCHAR2,
    p_zone_region_id        IN  NUMBER,
    p_zone_id           IN  NUMBER,
    p_region_id         IN  NUMBER,
    p_country           IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
    p_country_code          IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_user_id           IN  NUMBER,
    p_zone_type         IN  VARCHAR2,
    x_zone_region_id        OUT NOCOPY  NUMBER,
    x_region_id         OUT NOCOPY  NUMBER,
    x_status            OUT NOCOPY  NUMBER,
    x_error_msg         OUT NOCOPY  VARCHAR2) IS

  CURSOR check_regions_in_zone(l_region_id NUMBER, l_codeFrom VARCHAR2, l_codeTo VARCHAR2) IS
  SELECT region_id
  FROM   wsh_zone_regions z
  WHERE  z.region_id in (
         SELECT region_id
         FROM   wsh_regions
         START WITH region_id = l_region_id
         CONNECT BY PRIOR parent_region_id = region_id) AND
         z.parent_region_id = p_zone_id
         and ( nvl(l_codeFrom,'0') between nvl(z.postal_code_from,'0') and nvl(z.postal_code_to,'ZZZZZZZZZZZZZ')
         or nvl(l_codeTo,'0') between nvl(z.postal_code_from,'0') and nvl(z.postal_code_to,'ZZZZZZZZZZZZZZ')
         or nvl(z.postal_code_from,'0') between nvl(l_codeFrom,'0') and nvl(l_codeTo,'ZZZZZZZZZZZZ'));

  CURSOR check_regions_in_zone_down(l_region_id NUMBER) IS
  SELECT region_id
  FROM   wsh_regions r
  WHERE  region_id = l_region_id
  START WITH  r.region_id in (
         SELECT region_id
         FROM   wsh_zone_regions
     WHERE  parent_region_id = p_zone_id)
  CONNECT BY PRIOR parent_region_id = region_id;

  CURSOR check_same_region_in_zone(l_region_id NUMBER, l_codeFrom VARCHAR2, l_codeTo VARCHAR2) IS
  SELECT region_id
  FROM   wsh_zone_regions z
  WHERE  z.region_id in (
         SELECT region_id
         FROM   wsh_regions
         START WITH region_id = l_region_id
         CONNECT BY PRIOR parent_region_id = region_id) AND
         z.parent_region_id = p_zone_id AND
         l_codeFrom = z.postal_code_from AND
         l_codeTo = z.postal_code_to;

  CURSOR get_zone_level IS
  SELECT zone_level
  FROM   wsh_regions
  WHERE  region_id = p_zone_id;

  CURSOR get_region_type IS
  SELECT region_type
  FROM   wsh_regions
  WHERE region_id = p_region_id;

  l_region_info wsh_regions_search_pkg.region_rec;
  l_existing_region_id NUMBER;
  l_zone_level NUMBER;
  l_region_count NUMBER;

  l_region_id NUMBER;
  l_region_type NUMBER;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ZONE_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_INSERT_TYPE',P_INSERT_TYPE);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_REGION_ID',P_ZONE_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE_CODE',P_STATE_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY_CODE',P_CITY_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_TYPE',P_ZONE_TYPE);
     END IF;
     --
     IF (p_zone_type = '10')
     THEN
    IF (p_region_id is null OR p_region_id = -1)
    THEN
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Wsh_Regions_Search_Pkg.Get_Region_Info(
        p_country       =>  p_country,
        p_country_region    =>  null,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
        p_zone          =>  null,
        p_lang_code     =>  p_lang_code,
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  null,
        p_state_code        =>  p_state_code,
        p_city_code         =>  p_city_code,
        p_region_type       =>  null,
        p_interface_flag    =>  'N',
        p_search_flag       =>  'Y',
        x_region_info       =>  l_region_info);

        l_region_id := l_region_info.region_id;
        l_region_type := l_region_info.region_type;

    ELSE -- already have region_id, need to get region_type

        OPEN get_region_type;
        FETCH get_region_type INTO l_region_type;
        CLOSE get_region_type;

        l_region_id := p_region_id;

    END IF;

     ELSIF (p_zone_type = '11')
     THEN
        -- Bug 2418745
        -- For the zone of rating zone chart,
        -- Region_Id of the included postal code region should be of Country.
        -- If it is of State or city, the Parcel Carrier lanes can't be searched
        -- with postal codes.

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_REGION_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Wsh_Regions_Search_Pkg.Get_Region_Info(
        p_country       =>  p_country,
        p_country_region    =>  null,
        p_state         =>  null,
        p_city          =>  null,
        p_postal_code_from  =>  null,
        p_postal_code_to    =>  null,
        p_zone          =>  null,
        p_lang_code     =>  p_lang_code,
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  null,
        p_state_code        =>  null,
        p_city_code         =>  null,
        p_region_type       =>  0,
        p_interface_flag    =>  'N',
        x_region_info       =>  l_region_info);

    l_region_id := l_region_info.region_id;
    l_region_type := l_region_info.region_type;

     END IF;

     x_region_id := l_region_id;

     IF (l_region_id <= 0) THEN

    x_status := 1;
    x_error_msg := 'WSH_REGION_NOT_FOUND';
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
     END IF;

     IF (p_zone_region_id > 0 AND p_insert_type = 'DELETE') THEN

    SELECT count(*)
    INTO   l_region_count
    FROM   wsh_zone_regions
    WHERE  parent_region_id = p_zone_id;

    IF (l_region_count = 1) THEN

       x_status := 1;
       x_error_msg := 'WSH_ZONE_NO_REGIONS';
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
        END IF;

    DELETE FROM wsh_zone_regions
        WHERE  zone_region_id = p_zone_region_id;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;

     END IF;

     -- check to make sure this region and parents of this region
     -- are not already in this zone

     OPEN check_regions_in_zone(l_region_id, p_postal_code_from, p_postal_code_to);
     FETCH check_regions_in_zone INTO l_existing_region_id;
     CLOSE check_regions_in_zone;

     IF (l_existing_region_id IS NULL AND p_postal_code_from IS NULL) THEN

        OPEN check_regions_in_zone_down(l_region_id);
        FETCH check_regions_in_zone_down INTO l_existing_region_id;
        CLOSE check_regions_in_zone_down;

    IF (l_existing_region_id > 0) THEN
       x_status := 1;
       x_error_msg := 'WSH_REGION_EXISTS_IN_ZONE';
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
        END IF;

     END IF;

     IF (l_existing_region_id >= 0) THEN
    x_status := 1;
    x_error_msg := 'WSH_REGION_EXISTS_IN_ZONE';

        -- check if the region is exactly same with the existing one
    -- if it's the case, the error will be ignored in ZoneLoader
        -- to let the user load the same file without error (SYNC)

        IF (p_postal_code_from IS NOT NULL) THEN
           l_existing_region_id := -1;
           OPEN check_same_region_in_zone(l_region_id,p_postal_code_from,p_postal_code_to );
           FETCH check_same_region_in_zone INTO l_existing_region_id;
           CLOSE check_same_region_in_zone;

           IF (l_existing_region_id >= 0) THEN
          x_status := 1;
          x_error_msg := 'WSH_SAME_REGION_IN_ZONE';
           END IF;
        END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
     END IF;

     IF (p_insert_type IN ('ADD','INSERT')) THEN
    INSERT INTO WSH_ZONE_REGIONS (
        ZONE_REGION_ID,
        REGION_ID,
        PARENT_REGION_ID,
        POSTAL_CODE_FROM,
        POSTAL_CODE_TO,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        ZONE_FLAG,
        PARTY_ID)
    VALUES (
        wsh_zone_regions_s.nextval,
        l_region_id,
        p_zone_id,
        p_postal_code_from,
        p_postal_code_to,
        p_user_id,
        sysdate,
        p_user_id,
        sysdate,
        p_user_id,
        'Y',
        -1)
    RETURNING zone_region_id
    INTO x_zone_region_id;

    IF (x_zone_region_id IS NOT NULL) THEN

       OPEN get_zone_level;
       FETCH get_zone_level INTO l_zone_level;
       CLOSE get_zone_level;

       IF (l_region_type < nvl(l_zone_level,10000)) THEN

          UPDATE wsh_regions
          SET    zone_level = l_region_type
          WHERE  region_id = p_zone_id;

           END IF;

    END IF;

     ELSIF (p_zone_region_id > 0 AND p_insert_type IN ('UPDATE','SYNC')) THEN

    UPDATE wsh_zone_regions
    SET    region_id = l_region_id,
           postal_code_from = p_postal_code_from,
           postal_code_to = p_postal_code_to,
           last_updated_by = p_user_id,
           last_update_date = sysdate
        WHERE  zone_region_id = p_zone_region_id;

     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Update_Zone_Region;

--
--  Procedure:      Lock_Zone_Region
--  Parameters:     p_zone_region_id - zone_region_id for zone region to be locked
--          p_zone_id - zone id
--          p_region_id - zone component region id
--          x_return_status - Status of procedure call
--  Description:    This procedure will lock a zone component record. It is
--          specifically designed for use by the form.
--

  PROCEDURE Lock_Zone_Region
    (p_zone_region_id       IN  NUMBER,
    p_zone_id           IN  NUMBER,
    p_region_id             IN  NUMBER,
    x_status            OUT NOCOPY  NUMBER) IS

  CURSOR lock_row IS
  SELECT zone_region_id, parent_region_id , region_id
  FROM  wsh_zone_regions
  WHERE zone_region_id = p_zone_region_id
  FOR UPDATE OF zone_region_id NOWAIT;

  Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ZONE_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_REGION_ID',P_ZONE_REGION_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_ZONE_ID',P_ZONE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_REGION_ID',P_REGION_ID);
     END IF;
     --
     OPEN  lock_row;
     FETCH lock_row INTO Recinfo;

     IF (lock_row%NOTFOUND) THEN
    CLOSE lock_row;
        FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
     END IF;

     CLOSE lock_row;

     IF (
                (Recinfo.zone_region_id = p_zone_region_id)
         AND    (Recinfo.parent_region_id = p_zone_id)
         AND    (Recinfo.region_id = p_region_id)
     ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN others THEN
    if (lock_row%ISOPEN) then
       close lock_row;
    end if;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    raise;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Lock_Zone_Region;


  --
  -- Procedure: Load_Region
  --
  -- Purpose:   Loads the region information into interface tables
  --        without any validation.
  --

  PROCEDURE Load_Region (
    p_country_code          IN  VARCHAR2,
    p_country_region_code       IN  VARCHAR2,
    p_state_code            IN  VARCHAR2,
    p_city_code             IN  VARCHAR2,
    p_port_flag             IN  VARCHAR2,
    p_airport_flag          IN  VARCHAR2,
    p_road_terminal_flag        IN  VARCHAR2,
    p_rail_terminal_flag        IN  VARCHAR2,
    p_longitude             IN  NUMBER,
    p_latitude          IN  NUMBER,
    p_timezone          IN  VARCHAR2,
    p_continent             IN  VARCHAR2,
    p_country           IN  VARCHAR2,
    p_country_region        IN  VARCHAR2,
    p_state             IN  VARCHAR2,
    p_city              IN  VARCHAR2,
    p_alternate_name        IN  VARCHAR2,
    p_county            IN  VARCHAR2,
    p_postal_code_from      IN  VARCHAR2,
    p_postal_code_to        IN  VARCHAR2,
    p_lang_code         IN  VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL) IS

  l_region_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOAD_REGION';
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
         WSH_DEBUG_SV.log(l_module_name,'P_PORT_FLAG',P_PORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_AIRPORT_FLAG',P_AIRPORT_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_ROAD_TERMINAL_FLAG',P_ROAD_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_RAIL_TERMINAL_FLAG',P_RAIL_TERMINAL_FLAG);
         WSH_DEBUG_SV.log(l_module_name,'P_LONGITUDE',P_LONGITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_LATITUDE',P_LATITUDE);
         WSH_DEBUG_SV.log(l_module_name,'P_TIMEZONE',P_TIMEZONE);
         WSH_DEBUG_SV.log(l_module_name,'P_CONTINENT',P_CONTINENT);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_REGION',P_COUNTRY_REGION);
         WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
         WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
         WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_NAME',P_ALTERNATE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_FROM',P_POSTAL_CODE_FROM);
         WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE_TO',P_POSTAL_CODE_TO);
         WSH_DEBUG_SV.log(l_module_name,'P_LANG_CODE',P_LANG_CODE);
         WSH_DEBUG_SV.log(l_module_name, 'P_DECONSOL_LOCATION_ID', P_DECONSOL_LOCATION_ID);
     END IF;
     --
     Add_Region(
        p_country_code      =>  p_country_code,
        p_country_region_code   =>  p_country_region_code,
        p_state_code        =>  p_state_code,
        p_city_code     =>  p_city_code,
        p_port_flag     =>  p_port_flag,
        p_airport_flag      =>  p_airport_flag,
        p_road_terminal_flag    =>  p_road_terminal_flag,
        p_rail_terminal_flag    =>  p_rail_terminal_flag,
        p_longitude     =>  p_longitude,
        p_latitude      =>  p_latitude,
        p_timezone      =>  p_timezone,
        p_continent     =>  p_continent,
        p_country       =>  p_country,
        p_country_region    =>  p_country_region,
        p_state         =>  p_state,
        p_city          =>  p_city,
        p_alternate_name    =>  p_alternate_name,
        p_county        =>  p_county,
        p_postal_code_from  =>  p_postal_code_from,
        p_postal_code_to    =>  p_postal_code_to,
        p_lang_code     =>  p_lang_code,
        p_region_type       =>  null,
        p_parent_region_id  =>  null,
        p_interface_flag    =>  'Y',
        p_tl_only_flag      =>  'N',
        p_region_id     =>  null,
        x_region_id     =>      l_region_id,
                p_deconsol_location_id  =>    p_deconsol_location_id);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Load_Region;


  --
  -- Procedure: Default_Regions
  --
  -- Purpose:   Select all the entries from the interface tables and
  --        call Update_Region on each entry to do validation
  --

  PROCEDURE Default_Regions (
    x_status        OUT NOCOPY  NUMBER,
    x_regions_processed OUT NOCOPY  NUMBER,
           x_error_msg_text    OUT NOCOPY  VARCHAR2 )
IS
  CURSOR get_all_regions IS
   SELECT  R.REGION_ID,
      R.COUNTRY_CODE,
      R.COUNTRY_REGION_CODE,
      R.STATE_CODE,
      R.CITY_CODE,
      R.PORT_FLAG,
      R.AIRPORT_FLAG,
      R.ROAD_TERMINAL_FLAG,
      R.RAIL_TERMINAL_FLAG,
      R.LONGITUDE,
      R.LATITUDE,
      R.TIMEZONE,
      TL.CONTINENT,
      TL.COUNTRY,
      TL.COUNTRY_REGION,
      TL.STATE,
      TL.CITY,
      TL.ALTERNATE_NAME,
      TL.COUNTY,
      TL.POSTAL_CODE_FROM,
      TL.POSTAL_CODE_TO,
      TL.LANGUAGE
   FROM    WSH_REGIONS_INTERFACE R,
           WSH_REGIONS_TL_INTERFACE TL
   WHERE   R.REGION_ID = TL.REGION_ID
   AND     TL.ZONE IS NULL -- We are not processing zones here .
   AND     PROCESSED_FLAG is null
   ORDER BY TL.COUNTRY, R.COUNTRY_CODE,
            NVL(TL.STATE, 1), NVL(R.STATE_CODE, 1),
            NVL(TL.CITY, 1),  NVL(R.CITY_CODE, 1),
            NVL(TL.POSTAL_CODE_FROM, 1);

  Rec_Region    get_all_regions%ROWTYPE;

  l_region_id NUMBER;
  l_num_regions NUMBER;
  l_status NUMBER;
  l_error_msg VARCHAR2(200);
  l_regions_processed NUMBER;

   l_region_id_rec           tab_region_id;
   l_country_code_rec        tab_country_code;
   l_country_region_code_rec tab_country_region_code;
   l_state_code_rec          tab_state_code;
   l_city_code_rec           tab_city_code;
   l_port_flag_rec           tab_port_flag;
   l_airport_flag_rec        tab_airport_flag;
   l_road_terminal_flag_rec  tab_road_terminal_flag;
   l_rail_terminal_flag_rec  tab_rail_terminal_flag;
   l_longitude_rec           tab_longitude;
   l_latitude_rec            tab_latitude;
   l_timezone_rec            tab_timezone;
   l_continent_rec           tab_continent;
   l_country_rec             tab_country;
   l_country_region_rec      tab_country_region;
   l_state_rec               tab_state;
   l_city_rec                tab_city;
   l_alternate_name_rec      tab_alternate_name;
   l_county_rec              tab_county;
   l_postal_code_from_rec    tab_postal_code_from;
   l_postal_code_to_rec      tab_postal_code_to;
   l_language_rec            tab_language;

   l_prev_country            WSH_REGIONS_TL.Country%TYPE;
   l_prev_state              WSH_REGIONS_TL.State%TYPE;
   l_prev_city               WSH_REGIONS_TL.City%TYPE;
   l_prev_country_code       WSH_REGIONS.Country_Code%Type;
   l_prev_state_code         WSH_REGIONS.State_Code%Type;
   l_prev_city_code          WSH_REGIONS.City_Code%Type;

   -- Variables for Updating and Deleting regions from Interface table in Bulk
   l_upd_region_id           WSH_UTIL_CORE.Id_Tab_Type;
   l_del_region_id           WSH_UTIL_CORE.Id_Tab_Type;
   l_upd_count               NUMBER DEFAULT 0;
   l_del_count               NUMBER DEFAULT 0;

   l_return_status           VARCHAR2(1);
   l_country_flag            VARCHAR2(1);
   l_state_flag              VARCHAR2(1);
   l_city_flag               VARCHAR2(1);
   t1                        NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_REGIONS';
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
    END IF;
    --
    x_status := 0;
    l_regions_processed := 0;

   -- populate previous values to some impossible data ... like G_MISS..something.
   l_prev_country      := FND_API.G_MISS_CHAR;
   l_prev_state        := FND_API.G_MISS_CHAR;
   l_prev_city         := FND_API.G_MISS_CHAR;
   l_prev_country_code := FND_API.G_MISS_CHAR;
   l_prev_state_code   := FND_API.G_MISS_CHAR;
   l_prev_city_code    := FND_API.G_MISS_CHAR;

    OPEN get_all_regions;
    LOOP
      -- Fetching regions in bulk from Interface table (limit is 1000).
      FETCH get_all_regions BULK COLLECT INTO
            l_region_id_rec,
            l_country_code_rec,
            l_country_region_code_rec,
            l_state_code_rec,
            l_city_code_rec,
            l_port_flag_rec,
            l_airport_flag_rec,
            l_road_terminal_flag_rec,
            l_rail_terminal_flag_rec,
            l_longitude_rec,
            l_latitude_rec,
            l_timezone_rec,
            l_continent_rec,
            l_country_rec,
            l_country_region_rec,
            l_state_rec,
            l_city_rec,
            l_alternate_name_rec,
            l_county_rec,
            l_postal_code_from_rec,
            l_postal_code_to_rec,
            l_language_rec
      LIMIT 1000;

      t1 := dbms_utility.get_time;

      FOR I IN 1..l_region_id_rec.COUNT
      LOOP
         /*
            --  Validation regarding missing parameters or wrong format
            --  Same validatin are in the When-Validate-Record trigger on the Region block
            --  In WSHRGZON.fmb form
         */
               --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.VALIDATE_REGION', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         Validate_Region( p_country          => l_country_rec(i),
                          p_state            => l_state_rec(i),
                          p_city             => l_city_rec(i),
                          p_country_code     => l_country_code_rec(i),
                          p_state_code       => l_state_code_rec(i),
                          p_city_code        => l_city_code_rec(i),
                          p_postal_code_from => l_postal_code_from_rec(i),
                          p_postal_code_to   => l_postal_code_to_rec(i),
                          x_status           => l_status,
                          x_error_msg        => l_error_msg);

         IF ( l_status = 0 ) THEN -- { IF VALIDATION SUCCESS
            l_country_flag := 'N';
            l_state_flag   := 'N';
            l_city_flag    := 'N';

            -- Compare current values with previous values
            -- Current Country/Country_Code value is different from previous value
            IF ( nvl(l_prev_country, '-1')      <> nvl(l_country_rec(i), '-1')      OR
                 nvl(l_prev_country_code, '-1') <> nvl(l_country_code_rec(i), '-1') )
            THEN
               l_country_flag := 'Y';
               -- Populate details of country, state and city in Global temp table
               -- if city or postal code is not null
               IF ( l_city_rec(i)  is not null OR
                    l_postal_code_from_rec(i) is not null )
               THEN
                  l_state_flag := 'Y';
                  l_city_flag  := 'Y';
               ELSIF ( l_state_rec(i) is not null )
               THEN
                  -- Populate details of country and state in Global temp table
                  -- if state is not null
                  l_state_flag := 'Y';
               END IF;
            -- Current State/State_Code value is different from previous value
            ELSIF ( nvl(l_prev_state, '-1')      <> nvl(l_state_rec(i), '-1')      OR
                    nvl(l_prev_state_code, '-1') <> nvl(l_state_code_rec(i), '-1') )
            THEN
               l_state_flag := 'Y';
               -- Populate details of state and city in Global temp table
               -- if city or postal code is not null
               IF ( l_city_rec(i)  is not null OR
                    l_postal_code_from_rec(i) is not null )
               THEN
                  l_city_flag := 'Y';
               END IF;
            -- Current City/City_Code value is different from previous value
            ELSIF ( nvl(l_prev_city, '-1')      <> nvl(l_city_rec(i), '-1') OR
                    nvl(l_prev_city_code, '-1') <> nvl(l_city_code_rec(i), '-1') )
            THEN
               -- Populate details of city in Global temp table
               l_city_flag := 'Y';
            END IF;

            IF ( l_country_flag = 'Y' OR
                 l_state_flag   = 'Y' OR
                 l_city_flag    = 'Y' )
            THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.INIT_GLOBAL_TABLE', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               -- To popualte Global temp tables
               Init_Global_Table(
                        p_country        =>  l_country_rec(i),
                        p_state          =>  l_state_rec(i),
                        p_city           =>  l_city_rec(i),
                        p_country_code   =>  l_country_code_rec(i),
                        p_state_code     =>  l_state_code_rec(i),
                        p_city_code      =>  l_city_code_rec(i),
                        p_country_flag   =>  l_country_flag,
                        p_state_flag     =>  l_state_flag,
                        p_city_flag      =>  l_city_flag,
                        x_return_status  =>  l_return_status );

               -- Error Handling Part
               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  l_status    := 2;
                  l_error_msg := 'WSH_UTIL_MESSAGE_U';
               END IF;
            END IF;

            IF ( l_status = 0 )
            THEN
               -- Storing current value into temp variable
               l_prev_country      :=  l_country_rec(i);
               l_prev_state        :=  l_state_rec(i);
               l_prev_city         :=  l_city_rec(i);
               l_prev_country_code :=  l_country_code_rec(i);
               l_prev_state_code   :=  l_state_code_rec(i);
               l_prev_city_code    :=  l_city_code_rec(i);

               --
       -- Debug Statements
       --
       IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_PKG.UPDATE_REGION', WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       Update_Region(
            p_insert_type       =>  'SYNC',
            p_region_id     =>  -1,
            p_parent_region_id  =>  -1,
                      p_continent             =>      l_continent_rec(i),
                      p_country               =>      l_country_rec(i),
                      p_country_region        =>      l_country_region_rec(i),
                      p_state                 =>      l_state_rec(i),
                      p_city                  =>      l_city_rec(i),
                      p_alternate_name        =>      l_alternate_name_rec(i),
                      p_county                =>      l_county_rec(i),
                      p_postal_code_from      =>      l_postal_code_from_rec(i),
                      p_postal_code_to        =>      l_postal_code_to_rec(i),
                      p_lang_code             =>      l_language_rec(i),
                      p_country_code          =>      l_country_code_rec(i),
                      p_country_region_code   =>      l_country_region_code_rec(i),
                      p_state_code            =>      l_state_code_rec(i),
                      p_city_code             =>      l_city_code_rec(i),
                      p_port_flag             =>      l_port_flag_rec(i),
                      p_airport_flag          =>      l_airport_flag_rec(i),
                      p_road_terminal_flag    =>      l_road_terminal_flag_rec(i),
                      p_rail_terminal_flag    =>      l_rail_terminal_flag_rec(i),
                      p_longitude             =>      l_longitude_rec(i),
                      p_latitude              =>      l_latitude_rec(i),
                      p_timezone              =>      l_timezone_rec(i),
            p_interface_flag    =>  'N',
            p_user_id       =>  -1,
            p_insert_parent_flag    =>  'Y',
            x_region_id     =>  l_region_id,
            x_status        =>  l_status,
                      x_error_msg             =>      l_error_msg,
                      p_conc_request_flag     =>      'Y');  -- p_conc_request_flag

            END IF;
         END IF; -- } IF VALIDATION SUCCESS

    IF (l_status = 2) THEN
       x_status := 2;
       x_error_msg_text := l_error_msg;

            fnd_file.put_line(fnd_file.log,'ERROR processing region: ' || l_country_rec(i) ||', '|| l_state_rec(i) || ', ' || l_city_rec(i) || ', ' || l_postal_code_from_rec(i));
       fnd_file.put_line(fnd_file.log,' error message: '||fnd_message.get_string('WSH',l_error_msg));

            -- Bulk Update has to be done after processing 1000 records
            l_upd_count := l_upd_count + 1;
            l_upd_region_id(l_upd_count) := l_region_id_rec(i);
         ELSE
            l_regions_processed := l_regions_processed + 1;

            -- Bulk Delete has to be done after processing 1000 records
            l_del_count := l_del_count + 1;
            l_del_region_id(l_del_count) := l_region_id_rec(i);
         END IF;
      END LOOP;

      -- Bulk Updation in WSH_REGIONS_INTERFACE table
      IF ( l_upd_count > 0 ) THEN
         l_upd_count := 0;

         FORALL i in l_upd_region_id.first..l_upd_region_id.last
           UPDATE wsh_regions_interface
       SET    processed_flag = 'Y'
            WHERE  region_id = l_upd_region_id(i);

         -- Deleting region ids from array
         l_upd_region_id.DELETE;
      END IF;

      -- Bulk Deletion in WSH_REGIONS_INTERFACE table
      IF ( l_del_count > 0 ) THEN
         l_del_count := 0;
         FORALL i in l_del_region_id.first..l_del_region_id.last
            DELETE FROM WSH_REGIONS_INTERFACE WHERE REGION_ID = l_del_region_id(i);

         FORALL i in l_del_region_id.first..l_del_region_id.last
            DELETE FROM WSH_REGIONS_TL_INTERFACE WHERE REGION_ID = l_del_region_id(i);

         -- Deleting region ids from array
         l_del_region_id.DELETE;
    END IF;

      fnd_file.put_line(fnd_file.log, 'TIME TAKEN FOR PROCESSING 1000 RECORDS : ' || ((dbms_utility.get_time - t1)/100));

      COMMIT;
      EXIT WHEN get_all_regions%NOTFOUND;
    END LOOP;

    CLOSE get_all_regions;

   x_regions_processed := l_regions_processed;

   -- Truncating records from Global Temp Tables
   delete from wsh_regions_global_data;
   delete from wsh_regions_global;
    COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
       x_status := 2;
       x_error_msg_text := 'Error ' || sqlcode || ': ' || sqlerrm;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Default_Regions;

  --
  -- Procedure: Default_Regions (for concurrent program usage)
  --
  -- Purpose:   Copies regions from the interface tables to
  --        the real regions tables
  --

  PROCEDURE Default_Regions (
    p_dummy1    IN  VARCHAR2,
          p_dummy2    IN   VARCHAR2 )
IS
  l_status NUMBER;
  l_regions_processed NUMBER;
  l_error_msg_text VARCHAR2(1000);

  CURSOR total_regions IS
  SELECT count(*)
  FROM   wsh_Regions_interface
  WHERE  processed_flag is null;

  CURSOR more_regions IS
  SELECT 1
  FROM   wsh_Regions_interface
  WHERE  processed_flag is null;

  l_tmp NUMBER;
  l_good_count NUMBER := 0;
  l_bad_count NUMBER := 0;
  l_total_regions NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_REGIONS';
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
          WSH_DEBUG_SV.log(l_module_name,'P_DUMMY1',P_DUMMY1);
          WSH_DEBUG_SV.log(l_module_name,'P_DUMMY2',P_DUMMY2);
      END IF;
      --

      OPEN total_regions;
      FETCH total_regions INTO l_total_regions;
      CLOSE total_regions;
      fnd_file.put_line(fnd_file.log,'Started the region upload process...');

      IF (l_total_regions > 0) THEN
         Default_Regions(l_status, l_regions_processed, l_error_msg_text);

      l_good_count := l_regions_processed;
      l_bad_count  := l_total_regions - l_regions_processed;

       fnd_file.put_line(fnd_file.log,'Summary: Total regions processed = '||l_total_regions);
       fnd_file.put_line(fnd_file.log,'Summary: Number of new regions = '||l_good_count);
       fnd_file.put_line(fnd_file.log,'Summary: Number of regions with errors (not interfaced) = '||l_bad_count);

       fnd_file.put_line(fnd_file.log,'Ended the region upload process.');
      ELSE
       fnd_file.put_line(fnd_file.log,'There are no valid regions in interface table. If any regions exist please correct them and resubmit the concurrent program.');

      END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Default_Regions;


  -- This method in only for the purpose of submitting a request from the form

  FUNCTION Load_All_Regions RETURN NUMBER IS

  l_request_id NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOAD_ALL_REGIONS';
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
     END IF;
     --
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return fnd_request.submit_request('WSH','WSHRGINT','','',FALSE);

  END Load_All_Regions;


  -- used by FTE_CAT_ZONE_LOV to display Regions that belong to a Zone

  FUNCTION getZoneRegions(p_zoneId IN NUMBER, p_lang IN VARCHAR2)
       return VARCHAR2
  AS
    CURSOR zoneRegion_cur (p_zoneId number, p_lang varchar2)
    IS
    SELECT T.REGION_ID REGION_ID, T.COUNTRY COUNTRY, T.STATE STATE, T.CITY CITY,
       ltrim(P.POSTAL_CODE_FROM,'0') PCODE_FROM,
       ltrim(P.POSTAL_CODE_TO,'0') PCODE_TO
    FROM   WSH_REGIONS_TL T, WSH_ZONE_REGIONS P
    WHERE  T.LANGUAGE = p_lang
    AND    T.REGION_ID = P.REGION_ID
    AND    P.PARENT_REGION_ID = p_zoneId;

    regions VARCHAR2(100) := null;

    t_region        VARCHAR2(300);
    t_region_list       VARCHAR2(300);
    t_region_id         VARCHAR2(10);
    t_country       VARCHAR2(100);
    t_state     VARCHAR2(100);
    t_city      VARCHAR2(100);
    t_pcode_from    VARCHAR2(100);
    t_pcode_to      VARCHAR2(100);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GETZONEREGIONS';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ZONEID',P_ZONEID);
        WSH_DEBUG_SV.log(l_module_name,'P_LANG',P_LANG);
    END IF;
    --
    for c1 in zoneRegion_cur(p_zoneId, p_lang) loop

    t_region_id     := trim(c1.region_id);
    t_country   := trim(c1.country);
    t_state     := trim(c1.state);
    t_city      := trim(c1.city);
    t_pcode_from    := trim(c1.pcode_from);
    t_pcode_to  := trim(c1.pcode_to);

    t_region    := null;
        t_region_list   := t_region_list || ':' || t_region_id;

    if (t_country is not null) then
        t_region := t_country;
    end if;

    if (t_state is not null) then
        t_region := t_region||' - '||t_state;
    end if;

    if (t_city is not null) then
        t_region := t_region||' - '||t_city;
    end if;

    if (t_pcode_from is not null) then
        t_region := t_region||' - '||t_pcode_from;
    end if;

    if (t_pcode_to is not null) then
        t_region := t_region||' - '||t_pcode_to;
    end if;

    if (t_region is not null) then
        if (regions is null) then
        regions := t_region;
        else
        regions := regions||', '||t_region;
        end if;
    end if;
    end loop;

    if (p_lang <> 'US') then

      for c1 in zoneRegion_cur(p_zoneId, 'US') loop

    t_region_id     := trim(c1.region_id);
    t_country   := trim(c1.country);
    t_state     := trim(c1.state);
    t_city      := trim(c1.city);
    t_pcode_from    := trim(c1.pcode_from);
    t_pcode_to  := trim(c1.pcode_to);

    t_region    := null;

    -- only if the region for p_lang is not there
        if (t_region_list is null OR
        instr(t_region_list, ':'||t_region_id) = 0)
        then

      if (t_country is not null) then
        t_region := t_country;
      end if;

      if (t_state is not null) then
        t_region := t_region||' - '||t_state;
      end if;

      if (t_city is not null) then
        t_region := t_region||' - '||t_city;
      end if;

      if (t_pcode_from is not null) then
        t_region := t_region||' - '||t_pcode_from;
      end if;

      if (t_pcode_to is not null) then
        t_region := t_region||' - '||t_pcode_to;
      end if;

      if (t_region is not null) then
        if (regions is null) then
        regions := t_region;
        else
        regions := regions||', '||t_region;
        end if;
      end if;

        end if;

      end loop;

    end if;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN  regions;
  EXCEPTION when OTHERS then
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return regions||' ...';
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
  END;

 /*----------------------------------------------------------*/
 /* Add_Language Procedure                                     */
 /*----------------------------------------------------------*/
procedure ADD_LANGUAGE
is
begin
  delete from WSH_REGIONS_TL T
  where not exists
    (select NULL
    from WSH_REGIONS B
    where B.REGION_ID = T.REGION_ID
    );

  update WSH_REGIONS_TL T set (
      CONTINENT,
      COUNTRY,
      COUNTRY_REGION,
      STATE,
      CITY,
      ZONE,
      POSTAL_CODE_FROM,
      POSTAL_CODE_TO,
      ALTERNATE_NAME,
      COUNTY
    ) = (select
      B.CONTINENT,
      B.COUNTRY,
      B.COUNTRY_REGION,
      B.STATE,
      B.CITY,
      B.ZONE,
      B.POSTAL_CODE_FROM,
      B.POSTAL_CODE_TO,
      B.ALTERNATE_NAME,
      B.COUNTY
    from WSH_REGIONS_TL B
    where B.REGION_ID = T.REGION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REGION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REGION_ID,
      SUBT.LANGUAGE
    from WSH_REGIONS_TL SUBB, WSH_REGIONS_TL SUBT
    where SUBB.REGION_ID = SUBT.REGION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CONTINENT <> SUBT.CONTINENT
      or (SUBB.CONTINENT is null and SUBT.CONTINENT is not null)
      or (SUBB.CONTINENT is not null and SUBT.CONTINENT is null)
      or SUBB.COUNTRY <> SUBT.COUNTRY
      or (SUBB.COUNTRY is null and SUBT.COUNTRY is not null)
      or (SUBB.COUNTRY is not null and SUBT.COUNTRY is null)
      or SUBB.COUNTRY_REGION <> SUBT.COUNTRY_REGION
      or (SUBB.COUNTRY_REGION is null and SUBT.COUNTRY_REGION is not null)
      or (SUBB.COUNTRY_REGION is not null and SUBT.COUNTRY_REGION is null)
      or SUBB.STATE <> SUBT.STATE
      or (SUBB.STATE is null and SUBT.STATE is not null)
      or (SUBB.STATE is not null and SUBT.STATE is null)
      or SUBB.CITY <> SUBT.CITY
      or (SUBB.CITY is null and SUBT.CITY is not null)
      or (SUBB.CITY is not null and SUBT.CITY is null)
      or SUBB.ZONE <> SUBT.ZONE
      or (SUBB.ZONE is null and SUBT.ZONE is not null)
      or (SUBB.ZONE is not null and SUBT.ZONE is null)
      or SUBB.POSTAL_CODE_FROM <> SUBT.POSTAL_CODE_FROM
      or (SUBB.POSTAL_CODE_FROM is null and SUBT.POSTAL_CODE_FROM is not null)
      or (SUBB.POSTAL_CODE_FROM is not null and SUBT.POSTAL_CODE_FROM is null)
      or SUBB.POSTAL_CODE_TO <> SUBT.POSTAL_CODE_TO
      or (SUBB.POSTAL_CODE_TO is null and SUBT.POSTAL_CODE_TO is not null)
      or (SUBB.POSTAL_CODE_TO is not null and SUBT.POSTAL_CODE_TO is null)
      or SUBB.ALTERNATE_NAME <> SUBT.ALTERNATE_NAME
      or (SUBB.ALTERNATE_NAME is null and SUBT.ALTERNATE_NAME is not null)
      or (SUBB.ALTERNATE_NAME is not null and SUBT.ALTERNATE_NAME is null)
      or SUBB.COUNTY <> SUBT.COUNTY
      or (SUBB.COUNTY is null and SUBT.COUNTY is not null)
      or (SUBB.COUNTY is not null and SUBT.COUNTY is null)
  ));

  insert into WSH_REGIONS_TL (
    REGION_ID,
      CONTINENT,
      COUNTRY,
      COUNTRY_REGION,
      STATE,
      CITY,
      ZONE,
      POSTAL_CODE_FROM,
      POSTAL_CODE_TO,
      ALTERNATE_NAME,
      COUNTY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.REGION_ID,
      B.CONTINENT,
      B.COUNTRY,
      B.COUNTRY_REGION,
      B.STATE,
      B.CITY,
      B.ZONE,
      B.POSTAL_CODE_FROM,
      B.POSTAL_CODE_TO,
      B.ALTERNATE_NAME,
      B.COUNTY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WSH_REGIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WSH_REGIONS_TL T
    where T.REGION_ID = B.REGION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- Following procedure are added for Regions Interface Performance

  --
  -- PROCEDURE : Validate_Region
  --
  -- PURPOSE   : Validation regarding missing parameters or wrong format
  --             Same validatin are in the When-Validate-Record trigger
  --             on the Region block in WSHRGZON.fmb form
PROCEDURE Validate_Region (
     p_country              IN      VARCHAR2,
     p_state                IN      VARCHAR2,
     p_city                 IN      VARCHAR2,
     p_country_code         IN      VARCHAR2,
     p_state_code           IN      VARCHAR2,
     p_city_code            IN      VARCHAR2,
     p_postal_code_from     IN      VARCHAR2,
     p_postal_code_to       IN      VARCHAR2,
     x_status       OUT NOCOPY      NUMBER  ,
     x_error_msg    OUT NOCOPY      VARCHAR2 )
IS
   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_REGION';
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
      WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_CODE', P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_FROM', P_POSTAL_CODE_FROM);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_TO', P_POSTAL_CODE_TO);
   END IF;
   --

   IF (length(p_postal_code_from) <> length(p_postal_code_to)) THEN
      x_status := 2;
      x_error_msg := 'WSH_POSTAL_CODE_WRONG_FORMAT';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (p_postal_code_from > p_postal_code_to) THEN
      x_status := 2;
      x_error_msg := 'WSH_POSTAL_CODE_RANGE_ERR';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF ( ( (p_postal_code_from is not null) AND (p_postal_code_to is null) ) OR
        ( (p_postal_code_from is null) AND (p_postal_code_to is not null) ) ) -- Same bug fixed in Pack J.
   THEN
      x_status := 2;
      x_error_msg := 'WSH_CAT_P_CODE_RANGE_INCOMP';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (p_country is null and p_country_code is not null ) THEN
      x_status := 2;
      x_error_msg := 'WSH_COUNTRY_OR_CODE_MISSING';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (p_state is null and p_state_code is not null ) THEN
      x_status := 2;
      x_error_msg := 'WSH_STATE_OR_CODE_MISSING';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (p_city is null and p_city_code is not null ) THEN
      x_status := 2;
      x_error_msg := 'WSH_CITY_OR_CODE_MISSING';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

   x_status := 0;

   -- Exception Handling part
   EXCEPTION
      WHEN OTHERS THEN
         x_status := 2;
         x_error_msg := 'WSH_UTIL_MESSAGE_U';
         fnd_message.set_name('WSH', 'WSH_UTIL_MESSAGE_U');
         fnd_message.set_token('MSG_TEXT', SQLERRM);
         fnd_file.put_line(fnd_file.log, 'INSIDE VALIDATE_REGION EXCEPTION : ' || sqlerrm);
END Validate_Region;

  --
  -- PROCEDURE : Init_Global_Table
  --
  -- PURPOSE   : Populates the data in Global Temp tables(Wsh_Regions_Global
  --             and Wsh_Regions_Global_Data) fetched from Wsh_Regions and
  --             Wsh_Regions_Tl based on parameter p_populate_type.
  --

PROCEDURE Init_Global_Table (
            p_country           IN  VARCHAR2,
            p_state             IN  VARCHAR2,
            p_city              IN  VARCHAR2,
            p_country_code      IN  VARCHAR2,
            p_state_code        IN  VARCHAR2,
            p_city_code         IN  VARCHAR2,
            p_country_flag      IN  VARCHAR2,
            p_state_flag        IN  VARCHAR2,
            p_city_flag         IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2 )
AS

   CURSOR city_cur IS
      SELECT DISTINCT UPPER(STATE)
      FROM   WSH_REGIONS_TL
      WHERE  UPPER(CITY) = UPPER(p_city)
      AND    UPPER(COUNTRY) = UPPER(p_country);
--      AND    LANGUAGE       = p_lang_code;

   CURSOR city_cur_code IS
      SELECT DISTINCT UPPER(R.STATE_CODE)
      FROM   WSH_REGIONS R
      WHERE  ( UPPER(R.CITY_CODE) = UPPER(p_city_code) OR p_city_code is null )
      AND    UPPER(R.COUNTRY_CODE) = UPPER(p_country_code)
      AND    REGION_TYPE = 2;

   TYPE tab_code is TABLE OF VARCHAR2(10) index by BINARY_INTEGER;
   TYPE tab_desc is TABLE OF VARCHAR2(60) index by BINARY_INTEGER;

   tab_tmp_state           tab_desc;
   tab_tmp_state_code      tab_code;

   l_tmp_state             VARCHAR2(3000);
   l_tmp_state_code        VARCHAR2(500);
   t1                      NUMBER;

   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_GLOBAL_TABLE';
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
      WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_CODE', P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_FLAG', P_COUNTRY_FLAG);
      WSH_DEBUG_SV.log(l_module_name, 'P_STATE_FLAG', P_STATE_FLAG);
      WSH_DEBUG_SV.log(l_module_name, 'P_CITY_FLAG', P_CITY_FLAG);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   t1 := dbms_utility.get_time;

   IF ( p_country_flag = 'Y' ) THEN -- { Region type 0 i.e., Country
      DELETE FROM WSH_REGIONS_GLOBAL_DATA;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global_data
           ( REGION_ID,
             REGION_TYPE,
             PARENT_REGION_ID,
             COUNTRY,
             STATE,
             CITY,
             COUNTRY_CODE,
             STATE_CODE,
             CITY_CODE,
             POSTAL_CODE_FROM,
             POSTAL_CODE_TO,
             LANGUAGE )
      SELECT R.REGION_ID,
             R.REGION_TYPE,
             R.PARENT_REGION_ID,
             UPPER(TL.COUNTRY),
             UPPER(TL.STATE),
             UPPER(TL.CITY),
             UPPER(R.COUNTRY_CODE),
             UPPER(R.STATE_CODE),
             UPPER(R.CITY_CODE),
             TL.POSTAL_CODE_FROM,
             TL.POSTAL_CODE_TO,
             TL.LANGUAGE
      FROM   WSH_REGIONS R,
             WSH_REGIONS_TL TL
      WHERE  R.REGION_ID  = TL.REGION_ID
      AND    R.REGION_TYPE = 0
      AND (  UPPER(R.COUNTRY_CODE) = UPPER(p_country_code)
          OR UPPER(TL.COUNTRY)  = UPPER(p_country) );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      DELETE FROM WSH_REGIONS_GLOBAL;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global
           ( REGION_ID,
             REGION_TYPE,
             COUNTRY_CODE,
             STATE_CODE,
             CITY_CODE )
      SELECT R.REGION_ID,
             R.REGION_TYPE,
             UPPER(R.COUNTRY_CODE),
             UPPER(R.STATE_CODE),
             UPPER(R.CITY_CODE)
      FROM   WSH_REGIONS R
      WHERE  R.REGION_TYPE = 0
      AND    UPPER(R.COUNTRY_CODE) = UPPER(p_country_code);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global', sql%rowcount);
      END IF;
      --
   END IF; -- } Region Type 0 ie., Country

   IF ( p_state_flag = 'Y' ) THEN -- { Region type 1 i.e., State

      -- If State is NULL and City is NOT NULL then we need get States
      -- corresponding to City passed.
      IF ( (p_city is not null and p_state is null) )
      THEN
         OPEN  city_cur;
         FETCH city_cur BULK COLLECT INTO tab_tmp_state;
         CLOSE city_cur;

         FOR i in 1..tab_tmp_state.COUNT
         LOOP
            IF ( i = 1 ) THEN
               l_tmp_state := tab_tmp_state(i);
            ELSE
               l_tmp_state := l_tmp_state || ', ' || tab_tmp_state(i);
            END IF;
         END LOOP;
      END IF;

      -- If State_Code is NULL and City_Code is NOT NULL then we need get
      --  State_Codes corresponding to City_Code passed.
      IF ( (p_city_code is not null and p_state_code is null) )
      THEN
         OPEN  city_cur_code;
         FETCH city_cur_code BULK COLLECT INTO tab_tmp_state_code;
         CLOSE city_cur_code;

         FOR i in 1..tab_tmp_state_code.COUNT
         LOOP
            IF ( i = 1 ) THEN
               l_tmp_state_code := tab_tmp_state_code(i);
            ELSE
               l_tmp_state_code := l_tmp_state_code || ', ' || tab_tmp_state_code(i);
            END IF;
         END LOOP;
      END IF;

      DELETE FROM WSH_REGIONS_GLOBAL_DATA
      WHERE  REGION_TYPE in ( 1, 2, 3 );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global_data
             ( REGION_ID,
               REGION_TYPE,
               PARENT_REGION_ID,
               COUNTRY,
               STATE,
               CITY,
               COUNTRY_CODE,
               STATE_CODE,
               CITY_CODE,
               POSTAL_CODE_FROM,
               POSTAL_CODE_TO,
               LANGUAGE )
        SELECT R.REGION_ID,
               R.REGION_TYPE,
               R.PARENT_REGION_ID,
               UPPER(TL.COUNTRY),
               UPPER(TL.STATE),
               UPPER(TL.CITY),
               UPPER(R.COUNTRY_CODE),
               UPPER(R.STATE_CODE),
               UPPER(R.CITY_CODE),
               TL.POSTAL_CODE_FROM,
               TL.POSTAL_CODE_TO,
               TL.LANGUAGE
        FROM   WSH_REGIONS R,
               WSH_REGIONS_TL TL
        WHERE  R.REGION_ID  = TL.REGION_ID
        AND    R.REGION_TYPE = 1
        AND  (
               ( ( UPPER(R.STATE_CODE) = UPPER(p_state_code)
              OR ( UPPER(R.STATE_CODE) in ( l_tmp_state_code ) )
              OR ( p_state_code is NULL and p_city_code is null ) ) )
           OR  ( ( UPPER(TL.STATE) = UPPER(p_state)
              OR ( UPPER(TL.STATE) in ( l_tmp_state ) )
              OR ( p_state is null and p_city is null) ) )
             )
        AND  ( UPPER(R.COUNTRY_CODE) = UPPER(p_country_code)
           OR  UPPER(TL.COUNTRY)  = UPPER(p_country) );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      DELETE FROM WSH_REGIONS_GLOBAL
      WHERE  REGION_TYPE in ( 1, 2, 3 );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global
             ( REGION_ID,
               REGION_TYPE,
               COUNTRY_CODE,
               STATE_CODE,
               CITY_CODE )
        SELECT R.REGION_ID,
               R.REGION_TYPE,
               UPPER(R.COUNTRY_CODE),
               UPPER(R.STATE_CODE),
               UPPER(R.CITY_CODE)
        FROM   WSH_REGIONS R
        WHERE  R.REGION_TYPE = 1
        AND  ( UPPER(R.STATE_CODE) = UPPER(p_state_code)
          OR ( UPPER(R.STATE_CODE) in ( l_tmp_state_code ) )
          OR ( p_state_code is NULL and p_city_code is null) )
        AND    UPPER(R.COUNTRY_CODE) = UPPER(p_country_code);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global', sql%rowcount);
      END IF;
      --

   END IF; -- } Region type 1 i.e., State

   IF ( p_city_flag = 'Y' ) THEN -- { Region type 2,3 i.e., City, Postal Codes

      DELETE FROM WSH_REGIONS_GLOBAL_DATA
      WHERE  REGION_TYPE in ( 2, 3 );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global_data
             ( REGION_ID,
               REGION_TYPE,
               PARENT_REGION_ID,
               COUNTRY,
               STATE,
               CITY,
               COUNTRY_CODE,
               STATE_CODE,
               CITY_CODE,
               POSTAL_CODE_FROM,
               POSTAL_CODE_TO,
               LANGUAGE )
        SELECT R.REGION_ID,
               R.REGION_TYPE,
               R.PARENT_REGION_ID,
               UPPER(TL.COUNTRY),
               UPPER(TL.STATE),
               UPPER(TL.CITY),
               UPPER(R.COUNTRY_CODE),
               UPPER(R.STATE_CODE),
               UPPER(R.CITY_CODE),
               TL.POSTAL_CODE_FROM,
               TL.POSTAL_CODE_TO,
               TL.LANGUAGE
        FROM   WSH_REGIONS R,
               WSH_REGIONS_TL TL
        WHERE  R.REGION_ID  = TL.REGION_ID
        AND  (
               ( ( UPPER(R.CITY_CODE)  = UPPER(p_city_code)  OR p_city_code  is NULL )
            AND  ( decode(p_city_code, null, UPPER(R.STATE_CODE), NVL(UPPER(R.STATE_CODE), UPPER(p_state_code) )) = UPPER(p_state_code)
              OR ( p_state_code is NULL ) ) )
            OR ( ( UPPER(TL.CITY)  = UPPER(p_city)  OR ( p_city  is NULL ) )
            AND  ( decode( p_city, null, UPPER(TL.STATE), NVL(UPPER(TL.STATE), UPPER(p_state) )) = UPPER(p_state)
              OR ( p_state is null ) ) )
             )
        AND  ( UPPER(R.COUNTRY_CODE) = UPPER(p_country_code)
           OR  UPPER(TL.COUNTRY)  = UPPER(p_country) );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global_data', sql%rowcount);
      END IF;
      --

      DELETE FROM WSH_REGIONS_GLOBAL
      WHERE  REGION_TYPE in ( 2, 3 );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows deleted from wsh_regions_global', sql%rowcount);
      END IF;
      --

      INSERT INTO wsh_regions_global
             ( REGION_ID,
               REGION_TYPE,
               COUNTRY_CODE,
               STATE_CODE,
               CITY_CODE )
        SELECT R.REGION_ID,
               R.REGION_TYPE,
               UPPER(R.COUNTRY_CODE),
               UPPER(R.STATE_CODE),
               UPPER(R.CITY_CODE)
        FROM   WSH_REGIONS R
        WHERE  R.REGION_TYPE = 2
        AND  ( UPPER(R.CITY_CODE)  = UPPER(p_city_code)
          OR ( p_city_code  is NULL ) )
        AND  ( decode(p_city_code, null, UPPER(R.STATE_CODE), NVL(UPPER(R.STATE_CODE), UPPER(p_state_code) )) = UPPER(p_state_code)
          OR ( p_state_code is NULL ) )
        AND     UPPER(R.COUNTRY_CODE) = UPPER(p_country_code);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global', sql%rowcount);
      END IF;
      --

   END IF;  -- } Region type 2,3 i.e., City, Postal Codes

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
         fnd_file.put_line(fnd_file.log, 'Init_Global_Table EXCEPTION : ' || sqlerrm);
END Init_Global_Table;

  --
  -- PROCEDURE : Insert_Global_Table
  --
  -- PURPOSE   : Inserts the data in Global Temp tables
  --             ( Wsh_Regions_Global_Data and Wsh_Regions_Global tables )

PROCEDURE Insert_Global_Table (
            p_country           IN  VARCHAR2,
            p_state             IN  VARCHAR2,
            p_city              IN  VARCHAR2,
            p_country_code      IN  VARCHAR2,
            p_state_code        IN  VARCHAR2,
            p_city_code         IN  VARCHAR2,
            p_region_id         IN  NUMBER  ,
            p_region_type       IN  NUMBER  ,
            p_parent_region_id  IN  NUMBER  ,
            p_postal_code_from  IN  VARCHAR2,
            p_postal_code_to    IN  VARCHAR2,
            p_tl_only_flag      IN  VARCHAR2,
            p_lang_code         IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2 )
AS

   CURSOR parent_region IS
      SELECT parent_region_id
      FROM   WSH_REGIONS
      WHERE  REGION_ID = p_region_id;

   l_region_id             NUMBER;
   l_parent_region_id      NUMBER;
   t1                      NUMBER;

   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_GLOBAL_TABLE';
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
      WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_CODE', P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_REGION_ID', P_REGION_ID);
      WSH_DEBUG_SV.log(l_module_name, 'P_REGION_TYPE', P_REGION_TYPE);
      WSH_DEBUG_SV.log(l_module_name, 'P_PARENT_REGION_ID', P_PARENT_REGION_ID);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_FROM', P_POSTAL_CODE_FROM);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_TO', P_POSTAL_CODE_TO);
      WSH_DEBUG_SV.log(l_module_name, 'P_TL_ONLY_FLAG', P_TL_ONLY_FLAG);
      WSH_DEBUG_SV.log(l_module_name, 'P_LANG_CODE', P_LANG_CODE);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   t1 := dbms_utility.get_time;
   IF ( p_parent_region_id is null AND
        p_region_type = 0 )
   THEN
      l_parent_region_id := -1;
   ELSIF ( p_parent_region_id is null )
   THEN
      OPEN  parent_region;
      FETCH parent_region INTO l_parent_region_id;
      CLOSE parent_region;
   ELSE
      l_parent_region_id := p_parent_region_id;
   END IF;

   INSERT INTO wsh_regions_global_data
         ( REGION_ID,
           REGION_TYPE,
           PARENT_REGION_ID,
           COUNTRY,
           STATE,
           CITY,
           COUNTRY_CODE,
           STATE_CODE,
           CITY_CODE,
           POSTAL_CODE_FROM,
           POSTAL_CODE_TO,
           LANGUAGE )
   VALUES
         ( p_region_id,
           p_region_type,
           l_parent_region_id,
           UPPER(p_country),
           UPPER(p_state),
           UPPER(p_city),
           UPPER(p_country_code),
           UPPER(p_state_code),
           UPPER(p_city_code),
           p_postal_code_from,
           p_postal_code_to,
           p_lang_code );

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global_data', sql%rowcount);
   END IF;
   --

   IF ( p_tl_only_flag <> 'Y' AND
        p_region_type in ( 0, 1, 2 ) )
   THEN
      INSERT INTO wsh_regions_global
            ( REGION_ID,
              REGION_TYPE,
              COUNTRY_CODE,
              STATE_CODE,
              CITY_CODE )
      VALUES
            ( p_region_id,
              p_region_type,
              UPPER(p_country_code),
              UPPER(p_state_code),
              UPPER(p_city_code) );
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global', sql%rowcount);
      END IF;
      --
   END IF;

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
         fnd_file.put_line(fnd_file.log, 'INSERT_GLOBAL_TABLE EXCEPTION : ' || sqlerrm);
END Insert_Global_Table;

  --
  -- PROCEDURE : Update_Global_Table
  --
  -- PURPOSE   : Updates the data in Global Temp tables
  --             ( Wsh_Regions_Global_Data and Wsh_Regions_Global tables )

PROCEDURE Update_Global_Table (
            p_country           IN  VARCHAR2,
            p_state             IN  VARCHAR2,
            p_city              IN  VARCHAR2,
            p_country_code      IN  VARCHAR2,
            p_state_code        IN  VARCHAR2,
            p_city_code         IN  VARCHAR2,
            p_region_id         IN  NUMBER  ,
            p_postal_code_from  IN  VARCHAR2,
            p_postal_code_to    IN  VARCHAR2,
            p_parent_zone_level IN  NUMBER,
            p_lang_code         IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2 )
AS

   CURSOR child_regions IS
      SELECT  region_id, region_type, parent_region_id
      FROM    wsh_regions_global_data
      START   WITH     region_id = p_region_id
      CONNECT BY PRIOR region_id = parent_region_id;

   CURSOR get_state_code(l_region_id NUMBER) IS
      SELECT state_code, city_code
      FROM   wsh_regions
      WHERE  region_id = l_region_id;

   l_region_id             NUMBER;
   l_parent_region_id      NUMBER;
   l_region_upd_cnt        NUMBER;
   l_region_data_upd_cnt   NUMBER;
   l_region_ins_cnt        NUMBER;
   l_region_data_ins_cnt   NUMBER;
   l_update_state_code     WSH_REGIONS.State_Code%TYPE;
   l_update_city_code      WSH_REGIONS.City_Code%TYPE;
   t1                      NUMBER;
   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_GLOBAL_TABLE';
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
      WSH_DEBUG_SV.log(l_module_name, 'P_COUNTRY_CODE', P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_STATE_CODE', P_STATE_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_CITY_CODE', P_CITY_CODE);
      WSH_DEBUG_SV.log(l_module_name, 'P_REGION_ID', P_REGION_ID);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_FROM', P_POSTAL_CODE_FROM);
      WSH_DEBUG_SV.log(l_module_name, 'P_POSTAL_CODE_TO', P_POSTAL_CODE_TO);
      WSH_DEBUG_SV.log(l_module_name, 'P_PARENT_ZONE_LEVEL', P_PARENT_ZONE_LEVEL);
      WSH_DEBUG_SV.log(l_module_name, 'P_LANG_CODE', P_LANG_CODE);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_region_upd_cnt      := 0;
   l_region_ins_cnt      := 0;
   l_region_data_upd_cnt := 0;
   l_region_data_ins_cnt := 0;
   t1 := dbms_utility.get_time;

   FOR i in child_regions
   LOOP

      OPEN get_state_code(i.parent_region_id);
      FETCH get_state_code INTO l_update_state_code, l_update_city_code;
      CLOSE get_state_code;

      IF ( i.region_type in ( 0, 1, 2 ) )
      THEN
         UPDATE wsh_regions_global
         SET    COUNTRY_CODE = nvl(UPPER(p_country_code), COUNTRY_CODE),
                state_code   = decode(i.region_type,
                                   2, UPPER(l_update_state_code),
                                   3, UPPER(l_update_state_code),
                                   decode(p_parent_zone_level,
                                          1, UPPER(p_state_code),
                                          nvl(UPPER(p_state_code), state_code))),
                city_code    = decode(p_parent_zone_level,
                                   2, UPPER(p_city_code),
                                   nvl(UPPER(p_city_code), city_code))
         WHERE  REGION_ID    = i.region_id;

         l_region_upd_cnt := l_region_upd_cnt + sql%rowcount;

         IF ( sql%rowcount = 0  )
         THEN
            INSERT INTO wsh_regions_global
                  ( REGION_ID,
                    REGION_TYPE,
                    COUNTRY_CODE,
                    STATE_CODE,
                    CITY_CODE )
            SELECT  REGION_ID,
                    REGION_TYPE,
                    COUNTRY_CODE,
                    STATE_CODE,
                    CITY_CODE
            FROM    WSH_REGIONS
            WHERE   REGION_ID = i.region_id;

            l_region_ins_cnt := l_region_ins_cnt + sql%rowcount;
         END IF;
      END IF;

      UPDATE wsh_regions_global_data
      SET    country          = nvl(UPPER(p_country), country),
             state            = nvl(UPPER(p_state), state),
             city             = nvl(UPPER(p_city), city),
             country_code     = nvl(UPPER(p_country_code), country_code),
             state_code       = decode(i.region_type,
                                       2, UPPER(l_update_state_code),
                                       3, UPPER(l_update_state_code),
                                       decode(p_parent_zone_level,
                                              1, UPPER(p_state_code),
                                              nvl(UPPER(p_state_code), state_code))),
             city_code        = decode(p_parent_zone_level,
                                       2, UPPER(p_city_code),
                                       nvl(UPPER(p_city_code), city_code)),
             postal_code_from = nvl(p_postal_code_from, postal_code_from),
             postal_code_to   = nvl(p_postal_code_to, postal_code_to)
      WHERE  region_id = i.region_id
      AND    language  = p_lang_code;

      l_region_data_upd_cnt := l_region_data_upd_cnt + sql%rowcount;

      IF ( sql%rowcount = 0 )
      THEN
         INSERT INTO wsh_regions_global_data
               ( REGION_ID,
                 REGION_TYPE,
                 PARENT_REGION_ID,
                 COUNTRY,
                 STATE,
                 CITY,
                 COUNTRY_CODE,
                 STATE_CODE,
                 CITY_CODE,
                 POSTAL_CODE_FROM,
                 POSTAL_CODE_TO,
                 LANGUAGE )
         SELECT  R.REGION_ID,
                 R.REGION_TYPE,
                 R.PARENT_REGION_ID,
                 TL.COUNTRY,
                 TL.STATE,
                 TL.CITY,
                 R.COUNTRY_CODE,
                 R.STATE_CODE,
                 R.CITY_CODE,
                 TL.POSTAL_CODE_FROM,
                 TL.POSTAL_CODE_TO,
                 TL.LANGUAGE
         FROM    WSH_REGIONS R,
                 WSH_REGIONS_TL TL
         WHERE   TL.LANGUAGE  = p_lang_code
         AND     TL.REGION_ID = R.REGION_ID
         AND     R.REGION_ID  = i.region_id;

         l_region_data_ins_cnt := l_region_data_ins_cnt + sql%rowcount;
      END IF;

   END LOOP;

   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'No of rows updated  in wsh_regions_global', l_region_upd_cnt);
      WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global', l_region_ins_cnt);
      WSH_DEBUG_SV.log(l_module_name, 'No of rows updated  in wsh_regions_global_data', l_region_data_upd_cnt);
      WSH_DEBUG_SV.log(l_module_name, 'No of rows inserted in wsh_regions_global_data', l_region_data_ins_cnt);
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
         fnd_file.put_line(fnd_file.log, 'UPDATE_GLOBAL_TABLE EXCEPTION : ' || sqlerrm);
END Update_Global_Table;

END WSH_REGIONS_PKG;


/
