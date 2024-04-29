--------------------------------------------------------
--  DDL for Package Body WSH_EXTREPS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_EXTREPS_MLS_LANG" AS
/* $Header: WSHMLSLB.pls 120.1.12000000.4 2007/06/14 07:00:06 jnpinto ship $ */

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_EXTREPS_MLS_LANG';
   --

   /*  This local function is created so that the call is common from
       Function Get_Lang and Procedure Get_NLS_Lang
       This function takes the input Parameter Record and the Concurrent
       Program Name and returns the String of Languages for which the
       Concurrent Program Needs to be run
   */
   FUNCTION GET_LANG_STRING (
                              p_prog_name IN VARCHAR2,
                              p_doc_param_info IN WSH_DOCUMENT_SETS.document_set_rec_type
                            )
                              RETURN VARCHAR2 IS

   l_CursorID           INTEGER;
   v_SelectStmt         VARCHAR2(3000);
   l_lang                       VARCHAR2(30);
   l_base_lang          VARCHAR2(30);
   l_dummy                      INTEGER;
   l_lang_str           VARCHAR2(500) := NULL;
   v_FROM               VARCHAR2(500);       -- 4497301

   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LANG_STRING';
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
      END IF;
      --

      -- Get base language
      SELECT language_code INTO l_base_lang FROM fnd_languages
      WHERE installed_flag = 'B';

 -- 4497301 :  creating the v_FROM depending on whether a Trip is there or not
 -- 4248303 : Making use of hz_locations for language field.

      IF ( (p_doc_param_info.p_trip_id IS NOT NULL) OR
           (p_doc_param_info.p_trip_stop_id IS NOT NULL) OR
           (p_doc_param_info.p_departure_date_low IS NOT NULL or
                   p_doc_param_info.p_departure_date_high IS NOT NULL) OR
            (p_prog_name = 'WSHRDBOL' AND p_doc_param_info.p_delivery_leg_id is NOT NULL))
       THEN
	  v_FROM := 'FROM hz_locations loc,' ||
             ' wsh_new_deliveries wnd,' ||
             ' wsh_delivery_legs  wdl,' ||
             ' wsh_delivery_assignments_v wda ' ||
             ' WHERE wdl.delivery_id = wnd.delivery_id ';
      ELSE
	  v_FROM := 'FROM hz_locations loc,' ||
             ' wsh_new_deliveries wnd,' ||
             ' wsh_delivery_assignments_v wda ' ||
             ' WHERE 1 = 1 ';
      END IF;

      -- 4497301 : Commented the follwoing SELECT stmt.Re written the same below the commented code.
      -- Create a query string to get languages based on the parameters
/*      v_SelectStmt := 'SELECT DISTINCT hcas.language ' ||
         'FROM hz_cust_acct_sites_all hcas,' ||
             ' hz_party_sites hps,'||
             ' wsh_new_deliveries wnd,' ||
             ' wsh_delivery_legs  wdl,' ||
             ' wsh_delivery_assignments_v wda, ' ||
             ' wsh_locations wl ' ||
         'WHERE wdl.delivery_id(+) = wnd.delivery_id ' ||
         'AND   wnd.delivery_id = wda.delivery_id '||
         'AND   wl.wsh_location_id = wnd.ultimate_dropoff_location_id ' ||
         'AND   wl.location_source_code = ''HZ'' ' ||
         'AND   hps.location_id = wl.source_location_id ' ||
         'AND   hcas.party_site_id = hps.party_site_id ' ||
         'AND   nvl(wnd.SHIPMENT_DIRECTION , ''O'') IN (''O'', ''IO'') ' ;  -- J inbound logistics jckwok*/

-- 4497301 : Create a query string to get languages based on the parameters
-- 4248303 : Making use of hz_locations.language.
      v_SelectStmt := 'SELECT DISTINCT loc.language ' ||
          v_FROM ||
         'AND   loc.location_id = wnd.ultimate_dropoff_location_id ' ||
	 'AND   wnd.delivery_id = wda.delivery_id '||
         'AND   nvl(wnd.SHIPMENT_DIRECTION , ''O'') IN (''O'', ''IO'') ' ;  -- J inbound logistics jckwok

      IF p_doc_param_info.p_organization_id IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt|| ' AND   wnd.organization_id = :p_organization_id ';
      END IF;

      IF p_prog_name <> 'WSHRDPAK' THEN
         v_SelectStmt := v_SelectStmt||
           ' AND wda.delivery_detail_id IS NOT NULL';
      END IF;

      -- add to where clause if other parameters are specified
      IF p_doc_param_info.p_trip_id IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt||' AND wdl.delivery_leg_id in '||
                   '(select distinct delivery_leg_id from wsh_delivery_legs '||
                   'where pick_up_stop_id in (select stop_id from '||
                   'wsh_trip_stops where trip_id  = :p_trip_id))';
      END IF;

      IF p_doc_param_info.p_trip_stop_id IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt||' AND wdl.pick_up_stop_id = :p_trip_stop_id';
      END IF;

      -- 5723547 : Removed Connect By clause in the Dynamic SQL
      IF p_doc_param_info.p_delivery_id IS NOT NULL THEN
         --Bug 6074735, Removed IF p_prog_name = 'WSHRDPAK' condition
         v_SelectStmt := v_SelectStmt||' AND wnd.delivery_id = :p_delivery_id';
      END IF;

      IF p_doc_param_info.p_freight_carrier IS NOT NULL AND p_prog_name <> 'WSHRDPAK' THEN
         -- bug 1562990: wsh_new_deliveries doesn't have freight_carrier_code
         -- Since the value set WSH_SRS_FREIGHT_CARRIERS actually look at
         -- Ship Method, using ship_method_code will fix this bug.
         v_SelectStmt := v_SelectStmt||' AND wnd.ship_method_code = :p_freight_carrier';
      END IF;

      IF p_doc_param_info.p_departure_date_low IS NOT NULL OR p_doc_param_info.p_departure_date_high IS NOT NULL
      THEN
         IF p_doc_param_info.p_departure_date_low IS NULL THEN
            v_SelectStmt := v_SelectStmt||' AND wdl.delivery_leg_id IN '||
                   '(select distinct delivery_leg_id from wsh_delivery_legs '||
                   'where pick_up_stop_id in (select stop_id from '||
                   'wsh_trip_stops where planned_departure_date '||
                   '<= :p_departure_date_high))'; -- bug 1566422
         ELSIF p_doc_param_info.p_departure_date_high IS NULL THEN
            v_SelectStmt := v_SelectStmt||' AND wdl.delivery_leg_id IN '||
                   '(select distinct delivery_leg_id from wsh_delivery_legs '||
                   'where pick_up_stop_id in (select stop_id from '||
                   'wsh_trip_stops where planned_departure_date '||
                   '>= :p_departure_date_low))'; -- bug 1566422
         ELSE
            v_SelectStmt := v_SelectStmt||' AND wdl.delivery_leg_id in '||
                   '(select distinct delivery_leg_id from wsh_delivery_legs '||
                   'where pick_up_stop_id in (select stop_id from '||
                   'wsh_trip_stops where planned_departure_date '||
                   'BETWEEN :p_departure_date_low AND :p_departure_date_high))'; -- bug 1566422
         END IF;
      END IF;

      IF p_prog_name = 'WSHRDPAK' AND ( p_doc_param_info.p_delivery_date_low IS NOT NULL OR
                                        p_doc_param_info.p_delivery_date_high IS NOT NULL )  THEN
        IF p_doc_param_info.p_delivery_date_low IS NULL THEN
           v_SelectStmt := v_SelectStmt||' AND nvl(wnd.confirm_date,sysdate) <= p_doc_param_info.p_delivery_date_high ';        ELSIF p_doc_param_info.p_delivery_date_high IS NULL THEN
           v_SelectStmt := v_SelectStmt||' AND nvl(wnd.confirm_date,sysdate) >= p_doc_param_info.p_delivery_date_low ';
        ELSE
           v_SelectStmt := v_SelectStmt||' AND nvl(wnd.confirm_date,sysdate) '||
                            'between :p_delivery_date_low AND :p_delivery_date_high ';
        END IF;
      END IF;

      --  Bug: 1520197, Done only for Bill Of Lading Report (WSHRDBOL)
      IF (p_prog_name = 'WSHRDBOL'  AND  p_doc_param_info.p_delivery_leg_id is NOT NULL) THEN
          v_SelectStmt := v_SelectStmt||' AND wdl.delivery_leg_id = :p_delivery_leg_id';
      END IF;

      -- Open the cursor for processing
      l_CursorID := DBMS_SQL.OPEN_CURSOR;

      -- Parse the query
      DBMS_SQL.PARSE(l_CursorID, v_SelectStmt, DBMS_SQL.V7);

      -- Bind input variables
      IF p_doc_param_info.p_organization_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_organization_id',p_doc_param_info.p_organization_id);
      END IF;
      IF p_doc_param_info.p_trip_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_trip_id',p_doc_param_info.p_trip_id);
      END IF;
      IF p_doc_param_info.p_trip_stop_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_trip_stop_id',p_doc_param_info.p_trip_stop_id);
      END IF;
      IF p_doc_param_info.p_departure_date_low IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_departure_date_low',p_doc_param_info.p_departure_date_low);
      END IF;
      IF p_doc_param_info.p_departure_date_high IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_departure_date_high',p_doc_param_info.p_departure_date_high);
      END IF;
      IF p_doc_param_info.p_freight_carrier IS NOT NULL AND p_prog_name <> 'WSHRDPAK' THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_freight_carrier',p_doc_param_info.p_freight_carrier);
      END IF;
      IF p_doc_param_info.p_delivery_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_delivery_id',p_doc_param_info.p_delivery_id);
      END IF;
      IF p_prog_name = 'WSHRDPAK' THEN
         IF p_doc_param_info.p_delivery_date_low IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_delivery_date_low',p_doc_param_info.p_delivery_date_low);
         END IF;
         IF p_doc_param_info.p_delivery_date_high IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_delivery_date_high',p_doc_param_info.p_delivery_date_high);
         END IF;
      END IF;
      -- Bug: 1520197
      IF ( p_prog_name = 'WSHRDBOL'  AND p_doc_param_info.p_delivery_leg_id IS NOT NULL ) THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':p_delivery_leg_id',p_doc_param_info.p_delivery_leg_id);
      END IF;

      -- Define the output variable
      DBMS_SQL.DEFINE_COLUMN(l_CursorID,1,l_lang,30);
      -- Execute the query
      l_dummy := DBMS_SQL.EXECUTE(l_CursorID);

      -- Create string of languages to be returned
      LOOP
         IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
            EXIT;
         END IF;

         -- Fetch language into variable
         DBMS_SQL.COLUMN_VALUE(l_CursorID,1,l_lang);

         IF (l_lang IS NOT NULL) THEN
            IF (l_lang_str IS NULL) THEN
               l_lang_str := l_lang;
            ELSE
               l_lang_str := l_lang_str||','||l_lang;
            END IF;
         ELSE
            IF (l_lang_str IS NULL) THEN
               -- Use base language if none is specified
               l_lang_str := l_base_lang;
            ELSE
               -- Make sure base language is not already in string
               IF instr(l_lang_str,l_base_lang) = 0 THEN
                  l_lang_str := l_lang_str||','||l_base_lang;
               END IF;
            END IF;
         END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

      IF (l_lang_str IS NULL) THEN
         -- Function must not return an empty string
         l_lang_str := l_base_lang;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

      RETURN (l_lang_str);

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_SQL.CLOSE_CURSOR(l_CursorID);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
         RAISE;

   END GET_LANG_STRING;


   FUNCTION GET_LANG RETURN VARCHAR2 IS

      l_doc_param_info   WSH_DOCUMENT_SETS.document_set_rec_type;

      ret_val                   NUMBER;
      l_parm_num                NUMBER;
      l_lang_str		VARCHAR2(500) := NULL;
      l_prog_app_name		VARCHAR2(30);
      l_prog_name		VARCHAR2(30);
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LANG';
      --
   BEGIN
      -- PROGRAM NAME
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
      END IF;
      --
      FND_REQUEST_INFO.GET_PROGRAM(l_prog_name, l_prog_app_name);

      -- TRIP ID
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Trip Name', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_trip_id := NULL;
      ELSE
         l_doc_param_info.p_trip_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- STOP ID
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Trip Stop', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_trip_stop_id := NULL;
      ELSE
         l_doc_param_info.p_trip_stop_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- DEPARTURE DATE LOW
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Departure Date (Low)', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_departure_date_low := NULL;
      ELSE
         l_doc_param_info.p_departure_date_low := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- DEPARTURE DATE HIGH
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Departure Date (High)', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_departure_date_high := NULL;
      ELSE
         l_doc_param_info.p_departure_date_high := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- DELIVERY DATE LOW
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Delivery Date (Low)', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_delivery_date_low := NULL;
      ELSE
         l_doc_param_info.p_delivery_date_low := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));      END IF;

      -- DELIVERY DATE HIGH
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Delivery Date (High)', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_delivery_date_high := NULL;
      ELSE
         l_doc_param_info.p_delivery_date_high := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- FREIGHT CARRIER
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Freight Carrier', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_freight_carrier := NULL;
      ELSE
         l_doc_param_info.p_freight_carrier := FND_REQUEST_INFO.GET_PARAMETER(l_parm_num);
      END IF;

      -- DELIVERY
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Delivery Name', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_delivery_id := NULL;
      ELSE
         l_doc_param_info.p_delivery_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- ORGANIZATION
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Warehouse', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_organization_id := NULL;
      ELSE
         l_doc_param_info.p_organization_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- DELIVERY LEG ID           Bug: 1520197
      ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Bill of Lading Number', l_parm_num);
      IF (ret_val = -1) THEN
         l_doc_param_info.p_delivery_leg_id  := NULL;
      ELSE
         l_doc_param_info.p_delivery_leg_id  := to_number(FND_REQUEST_INFO.GET_PARAMETER(l_parm_num));
      END IF;

      -- Calling Get_Lang_String
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling Get_Lang_String ');
      END IF;

      l_lang_str := Get_Lang_String ( p_prog_name => l_prog_name,  p_doc_param_info => l_doc_param_info );

      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN (l_lang_str);

   EXCEPTION
      WHEN OTHERS THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
         RAISE;
   END GET_LANG;


  /*  This procedure is called from WSH_DOCUMENT_SETS.Print_Document_Set to get the
       NLS languages for which the concurrent report needs to be run, if it is
       MLS Compliant (MLS function is defined for that report)
   */

   PROCEDURE GET_NLS_LANG (
                              p_prog_name IN VARCHAR2,
                              p_doc_param_info IN  WSH_DOCUMENT_SETS.document_set_rec_type,
                              p_nls_comp       IN  VARCHAR2,
                              x_nls_lang       OUT NOCOPY lang_tab_type,
                              x_return_status  OUT NOCOPY VARCHAR2
                          )
   IS

     l_lang_str            VARCHAR2(500) := NULL;

     p_lcount          NUMBER;
     endloc            NUMBER;
     startloc          NUMBER;

     --
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_NLS_LANG';
     --
  BEGIN
    -- PROGRAM NAME
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
    END IF;
    --

    x_return_status := fnd_api.g_ret_sts_success;

    -- Call Get_Lang_String to get the Language String
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling Get_Lang_String ');
    END IF;

    l_lang_str := Get_Lang_String ( p_prog_name => p_prog_name,  p_doc_param_info => p_doc_param_info );

    /* Parse p_lang_str to get nls_languages  */
    startloc := 1;
    endloc   := 1;
    p_lcount := 0;

    /* Parse p_lang_str to get nls_languages  */
    startloc := 1;
    endloc   := 1;
    p_lcount := 0;

    if (l_lang_str is null ) then
       -- Return error
       x_return_status := fnd_api.g_ret_sts_error;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Get_Lang_String returns NULL');
       END IF;
       raise no_data_found ;
    end if;

    if ( l_lang_str is not null ) then
      loop
        endloc := instr( l_lang_str, ',', startloc );
        p_lcount := p_lcount + 1;
        if ( endloc = 0 ) then
            x_nls_lang(p_lcount).lang_code := LTRIM(RTRIM( substr( l_lang_str, startloc,
                                                          length(l_lang_str) -
                                                            startloc + 1
                                                         )
                                                     )
                                                 );
            exit;
         else
            x_nls_lang(p_lcount).lang_code := LTRIM(RTRIM( substr( l_lang_str, startloc,
                                                          endloc - startloc
                                                         )
                                                     )
                                                 );
         end if;
         startloc := endloc + 1;
      end loop;
    end if;

    /* get nls_language and nls_territory for each language_code  */
    for i in 1..p_lcount loop
        /* if program is nls_compliant then use the default territory from fnd_languages,
           otherwise use user environment */
        if ( p_nls_comp  = 'Y' ) then
           begin
                select nls_language, nls_territory
                  into x_nls_lang(i).nls_language, x_nls_lang(i).nls_territory
                  from fnd_languages
                 where language_code = x_nls_lang(i).lang_code;
           exception
                when no_data_found then
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'No data found in fnd_languages for :'|| x_nls_lang(i).lang_code);
                   END IF;
                   raise ;
           end;
        else
           /* use territory from the user environment which is parent_id's nls_territory */
           begin
                select nls_language
                  into x_nls_lang(i).nls_language
                  from fnd_languages
                 where language_code = x_nls_lang(i).lang_code;
           exception
                when no_data_found then
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'No data found in fnd_languages for :'|| x_nls_lang(i).lang_code);
                   END IF;
                   raise ;
           end;

           x_nls_lang(i).nls_territory := fnd_request_info.get_territory;

        end if;
     end loop;

    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status);
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'No Data Found error has occured.');
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --

    WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_EXTREPS_MLS_LANG.GET_NLS_LANG');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END GET_NLS_LANG;


END WSH_EXTREPS_MLS_LANG;

/
