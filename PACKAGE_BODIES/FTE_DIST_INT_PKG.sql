--------------------------------------------------------
--  DDL for Package Body FTE_DIST_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DIST_INT_PKG" AS
/* $Header: FTEDISIB.pls 120.2 2006/04/12 15:42:25 susurend noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_DISTANCE_INT_PKG                                          --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains core procedures for accessing and retrieving distance--
--              and transit time information from FTE_LOCATION_MILEAGES table --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/14  J        ABLUNDEL           Created.                           --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
-- Global Package Variables                                                   --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --

--
-- Global flag constants for location and region flags
--
g_location_search_flag  CONSTANT VARCHAR2(1) := 'L';
g_region_search_flag    CONSTANT VARCHAR2(1) := 'R';

--
-- Global table for storing messages found during execution of the API
--
g_message_tab           FTE_DIST_INT_PKG.fte_dist_output_message_tab;


--
-- For debug
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_DIST_INT_PKG';


-- -------------------------------------------------------------------------- --
--                                                                            --
-- PRIVATE PROCEDURE DEFINITIONS                                              --
-- -----------------------------                                              --
-- Described in Procedure code below                                          --
-- -------------------------------------------------------------------------- --
PROCEDURE DISTANCE_SEARCH(p_location_region_flag IN VARCHAR2,
                          p_messaging_yn         IN VARCHAR2,
                          p_level                IN VARCHAR2,
                          p_search_tab           IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_search_tab,
                          p_origin_reg_loc_tab   IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                          p_dest_reg_loc_tab     IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                          x_result_found         OUT NOCOPY VARCHAR2,
                          x_result_table         OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_tab,
                          x_return_message       OUT NOCOPY VARCHAR2,
                          x_return_status        OUT NOCOPY VARCHAR2);




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                GET_DISTANCE_TIME                                     --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_distance_input_tab   IN  OUT NOCOPY                 --
--                                    FTE_DIST_INT_PKG.fte_distance_input_tab --
--                      p_location_region_flag IN  VARCHAR2                   --
--                      p_messaging_yn         IN  VARCHAR2                   --
--                      p_api_version          IN  VARCHAR2                   --
--                                                                            --
-- PARAMETERS (OUT):    x_distance_output_tab  OUT NOCOPY                     --
--                                   FTE_DIST_INT_PKG.fte_distance_output_tab --
--                      x_distance_message_tab OUT NOCOPY                     --
--                           FTE_DIST_INT_PKG.fte_distance_output_message_tab --
--                      x_return_message         OUT VARCHAR2,                --
--                      x_return_status          OUT VARCHAR2                 --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         This procedure initiates the search for distance and  --
--                      Transit times for given location or region origin/    --
--                      destination id pairs.                                 --
--                                                                            --
--                      The input table, p_distance_input_tab, contains the   --
--                      combination of origin and destination ids for which   --
--                      the search is to be conducted.                        --
--                                                                            --
--                      p_location_region_flag can have a value of 'L' (for   --
--                      Location) or 'R' (for Region). This flag dictates the --
--                      id pairs in the input table as whether they are region--
--                      (WSH_REGIONS.REGION_ID) or locations                  --
--                      (WSH_LOCATIONS.LOCATION_ID). As the origin/destination--
--                      pairs in FTE_LOCATION_MILEAGES are stored as region   --
--                      ids, if a table of locations is passed in then the    --
--                      associated regions will need to be found for those    --
--                      locations before the search/retrieval can be conducted--
--                                                                            --
--                      p_messaging_yn indicates if messaging is to be enabled--
--                      or not, in the case that a result is not found for a  --
--                      OD pair a message can be logged indicating this to the--
--                      calling API, can also be used for other forms of      --
--                      messaging back to the calling API                     --
--                                                                            --
--                      p_api_version is the version of the API? not used     --
--                                                                            --
--                      x_distance_output_tab is the output table of origin/  --
--                      destination pairs and the found distance and transit  --
--                      times associated with those pairs.                    --
--                                                                            --
--                      x_distance_message_tab is a table of messages that    --
--                      were logged during the search (only if p_messaging_yn --
--                      = Y)                                                  --
--                                                                            --
--                      x_return_message and x_return_status standard status  --
--                      and message return parameters                         --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/14  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE GET_DISTANCE_TIME(p_distance_input_tab   IN  OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_input_tab,
                            p_location_region_flag IN  VARCHAR2,
                            p_messaging_yn         IN  VARCHAR2,
                            p_api_version          IN  VARCHAR2,
                            p_command              IN  VARCHAR2,
                            x_distance_output_tab  OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_tab,
                            x_distance_message_tab OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_message_tab,
                            x_return_message       OUT NOCOPY VARCHAR2,
                            x_return_status        OUT NOCOPY VARCHAR2) IS


--
-- Local Variable Definitions
--
l_distance_profile  VARCHAR2(30);         -- holds the FTE_DISTANCE_LVL profile option value
l_region_type       NUMBER;               -- holds the region type based on the profile value
l_ctr               PLS_INTEGER;          -- counter for populating the search table index
l_msg_ctr           PLS_INTEGER;          -- counter for populating message table index
l_result_found_flag VARCHAR2(1);          -- Indicates if at least 1 OD pair found a distance
l_return_message    VARCHAR2(2000);       -- Return message from API (if error in API)
l_return_status     VARCHAR2(1);          -- Return Status from called API (values = S,E,W,U)
l_error_text        VARCHAR2(2000);       -- Holds the unexpected error text

--
-- Exception Handlers
--
FTE_DIST_NO_INPUT_DATA        EXCEPTION;
FTE_DIST_INVALID_LOC_REG_FLAG EXCEPTION;
FTE_DIST_DISTANCE_SEARCH_ERR  EXCEPTION;
FTE_DIST_INVALID_PROFILE      EXCEPTION;
FTE_DIST_NULL_PROFILE         EXCEPTION;
FTE_DIST_NO_REGS_FOR_ANY_LOCS EXCEPTION;
FTE_DIST_NO_REGS_IN_SEARCH    EXCEPTION;
FTE_DIST_NULL_REGION_TYPE     EXCEPTION;


--
-- Local Record and Table Definitions
--
l_origin_location_id_tab      FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_origin_region_id_tab        FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_loc_region_id_origin_tab    FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_destination_location_id_tab FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_destination_region_id_tab   FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_loc_region_id_dest_tab      FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_region_idx_loc_orig_tab     FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_region_idx_loc_dest_tab     FTE_DIST_INT_PKG.fte_dist_tmp_num_table;

l_search_tab                  FTE_DIST_INT_PKG.fte_dist_search_tab;

l_result_table                FTE_DIST_INT_PKG.fte_dist_output_tab;

--
-- Message logging tables
--
msg_message_type_tab          FTE_DIST_INT_PKG.fte_dist_tmp_flag_table;
msg_message_code_tab          FTE_DIST_INT_PKG.fte_dist_tmp_code_table;
msg_message_text_tab          FTE_DIST_INT_PKG.fte_dist_tmp_msg_table;
msg_location_region_flag_tab  FTE_DIST_INT_PKG.fte_dist_tmp_flag_table;
msg_level_tab                 FTE_DIST_INT_PKG.fte_dist_tmp_code_table;
msg_table_origin_id_tab       FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_table_destination_id_tab  FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_input_origin_id_tab       FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_input_destination_tab     FTE_DIST_INT_PKG.fte_dist_tmp_num_table;



--
-- Cursor Definitions
--
-- ---------------------------------------------------------
-- Cursor to retrieve region ids from location ids
-- ---------------------------------------------------------
cursor c_get_regions_for_locs(cp_loc_id             NUMBER,
                              cp_region_type        NUMBER) IS
select wrl.location_id,
       wrl.region_id
from   wsh_region_locations wrl
where  wrl.location_id = cp_loc_id
and    wrl.region_type = cp_region_type;


--
-- Local Debug Variable Definitions
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISTANCE_TIME';


BEGIN

   --
   -- set the debug flag
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
       WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
       WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_REGION_FLAG',p_location_region_flag);
       WSH_DEBUG_SV.log(l_module_name,'P_MESSAGING_YN',p_messaging_yn);
       WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',p_api_version);
       WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
       WSH_DEBUG_SV.logmsg(l_module_name,'-------- p_distance_input_tab ------');

       IF (p_distance_input_tab.COUNT > 0) THEN
          FOR dbdit IN p_distance_input_tab.FIRST..p_distance_input_tab.LAST LOOP
             WSH_DEBUG_SV.log(l_module_name,'origin_id', p_distance_input_tab(dbdit).origin_id);
             WSH_DEBUG_SV.log(l_module_name,'destination_id',p_distance_input_tab(dbdit).destination_id);
          END LOOP;
       ELSE
          WSH_DEBUG_SV.logmsg(l_module_name,'NO INPUT ATTRIBUTES IN p_distance_input_tab INPUT TABLE');
       END IF;
       WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');


   END IF;

   --
   -- Set the return flags for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   -- Clear the message tab
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'resetting the global message table');
   END IF;

   g_message_tab.DELETE;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'resetting the local tables');
   END IF;
   --
   -- Reset the local tables
   --
   l_origin_location_id_tab.DELETE;
   l_origin_region_id_tab.DELETE;
   l_loc_region_id_origin_tab.DELETE;
   l_destination_location_id_tab.DELETE;
   l_destination_region_id_tab.DELETE;
   l_loc_region_id_dest_tab.DELETE;
   l_region_idx_loc_orig_tab.DELETE;
   l_region_idx_loc_dest_tab.DELETE;
   l_search_tab.DELETE;
   l_result_table.DELETE;


   --
   -- Reset the message tables
   --
   msg_message_type_tab.DELETE;
   msg_message_code_tab.DELETE;
   msg_message_text_tab.DELETE;
   msg_location_region_flag_tab.DELETE;
   msg_level_tab.DELETE;
   msg_table_origin_id_tab.DELETE;
   msg_table_destination_id_tab.DELETE;
   msg_input_origin_id_tab.DELETE;
   msg_input_destination_tab.DELETE;


   --
   -- Check that the input table has records, otherwise we cannot do a search
   --
   IF (p_distance_input_tab.COUNT < 1) THEN
      --
      -- No input data exists  - return back an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,' Input table has no data - p_distance_input_tab.COUNT',p_distance_input_tab.COUNT);
      END IF;

      RAISE FTE_DIST_NO_INPUT_DATA;

   END IF;


   --
   -- Check that the location_region flag is correctly marked
   -- otherwise we dont know what to search for
   --
   IF ((p_location_region_flag is null) OR
       ((p_location_region_flag <> g_location_search_flag) AND
        (p_location_region_flag <> g_region_search_flag))) THEN
      --
      -- Invalid location_region_flag, raise an error
      --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'location region input flag is invalid - p_location_region_flag',p_location_region_flag);
      END IF;

      RAISE FTE_DIST_INVALID_LOC_REG_FLAG;

   END IF;


   --
   -- Get the profile option of the distance stuff to
   -- see what region level we should be searching for
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'getting the distance profile valie fnd_profile.get(FTE_DISTANCE_LVL)');
   END IF;

   fnd_profile.get('FTE_DISTANCE_LVL',l_distance_profile);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'fnd_profile.get(FTE_DISTANCE_LVL)= ',l_distance_profile);
   END IF;

   IF (l_distance_profile is null) THEN
      --
      -- The profile option is null - raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'distance profile is null raise FTE_DIST_NULL_PROFILE exception');
      END IF;
      RAISE FTE_DIST_NULL_PROFILE;

   END IF;


   --
   -- Got the profile option value now get the corresponding region type
   -- so that we can use it in our query to get the regions for the
   -- locations - if the input is a table of location id OD pairs
   --
   -- Region Types to Profile Types
   --
   -- REGION TYPE     PROFILE TYPE   DESC
   -- ------------    ------------   --------
   -- 0               n/a            COUNTRY
   -- 1               n/a            STATE
   -- 2               CITYSTATE      CITY
   -- 3               ZIP            ZIP/POSTAL
   -- ???? (4)        COUNTY         COUNTY

   IF (l_distance_profile = 'CITYSTATE') THEN
      --
      -- region type is city level
      --
      l_region_type := 2;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is CITYSTATE - region type = ',l_region_type);
      END IF;
   ELSIF (l_distance_profile = 'ZIP') THEN
      --
      -- region type is zip/postal level
      --
      l_region_type := 3;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is ZIP - region type = ',l_region_type);
      END IF;
   ELSIF (l_distance_profile = 'COUNTY') THEN
      --
      -- region type is county level
      --
      l_region_type := 4;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is COUNTY - region type = ',l_region_type);
      END IF;
   ELSE
      --
      -- The profile option has an invalid value - raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The profile option has an invalid value - raise an error RAISE FTE_DIST_INVALID_PROFILE');
      END IF;

      RAISE FTE_DIST_INVALID_PROFILE;

   END IF;


   IF (l_region_type is null) THEN
      --
      -- region type is null cannot have that Raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'region type is null - raise an error FTE_DIST_NULL_REGION_TYPE');
      END IF;
      RAISE FTE_DIST_NULL_REGION_TYPE;

   END IF;


   --
   -- Input data seems to be OK, now its time to rock and roll!!!
   --
   IF (p_location_region_flag = g_location_search_flag) THEN
      --
      -- The input is in location id form - convert the
      -- locations to regions
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The input is in location id form going to get region mappings');
         WSH_DEBUG_SV.log(l_module_name,'l_region_type = ',l_region_type);
      END IF;

      --
      -- Search for origin region ids from the origin location id
      --
      -- reset the origin result tables
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,' Search for origin region ids from the origin location id - reset the origin result tables');
      END IF;

      l_origin_location_id_tab.DELETE;
      l_origin_region_id_tab.DELETE;
      l_loc_region_id_origin_tab.DELETE;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'LOOPING and opening cursor c_get_regions_for_locs(orig)');
      END IF;


      --
      -- execute the query to get all the region ids for the passed in origin locations
      --
      FOR aaa IN p_distance_input_tab.FIRST..p_distance_input_tab.LAST LOOP
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Open c_get_regions_for_locs (orig) with ...');
            WSH_DEBUG_SV.log(l_module_name,'aaa p_distance_input_tab(aaa).origin_id = ',p_distance_input_tab(aaa).origin_id);
            WSH_DEBUG_SV.log(l_module_name,'l_region_type = ',l_region_type);
         END IF;

         OPEN c_get_regions_for_locs(p_distance_input_tab(aaa).origin_id,
                                     l_region_type);
         FETCH c_get_regions_for_locs BULK COLLECT INTO
            l_origin_location_id_tab,
            l_origin_region_id_tab;
         CLOSE c_get_regions_for_locs;



         IF (l_origin_location_id_tab.COUNT > 0) THEN
            --
            -- Origin regions and locations were returned by the query, now we create mapping
            -- tables of locations to regions
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id_tab.COUNT = ',l_origin_location_id_tab.COUNT);
            END IF;

            FOR bbb in l_origin_location_id_tab.FIRST..l_origin_location_id_tab.LAST LOOP
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id_tab(bbb) = ',l_origin_location_id_tab(bbb));
               END IF;

               l_loc_region_id_origin_tab(l_origin_location_id_tab(bbb)) := l_origin_region_id_tab(bbb);
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_loc_region_id_origin_tab(l_origin_location_id_tab(bbb)) =',l_loc_region_id_origin_tab(l_origin_location_id_tab(bbb)));
               END IF;
            END LOOP;
         END IF;

      END LOOP;

      --
      -- Search for destination region ids from the destination location id
      --
      -- Reset the destination result tables
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,' Search for destination region ids from the destination location id - reset the destination result tables');
      END IF;

      l_destination_location_id_tab.DELETE;
      l_destination_region_id_tab.DELETE;
      l_loc_region_id_dest_tab.DELETE;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'LOOPING and opening cursor c_get_regions_for_locs (dest)');
      END IF;


      --
      -- Run the query to get the locations and regions for the input destination
      -- locations
      --
      FOR ccc IN p_distance_input_tab.FIRST..p_distance_input_tab.LAST LOOP

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Open c_get_regions_for_locs (dest) with ...');
            WSH_DEBUG_SV.log(l_module_name,'aaa p_distance_input_tab(ccc).destination_id = ',p_distance_input_tab(ccc).destination_id);
            WSH_DEBUG_SV.log(l_module_name,'l_region_type = ',l_region_type);
         END IF;

         OPEN c_get_regions_for_locs(p_distance_input_tab(ccc).destination_id,
                                     l_region_type);
            FETCH c_get_regions_for_locs BULK COLLECT INTO
               l_destination_location_id_tab,
               l_destination_region_id_tab;
         CLOSE c_get_regions_for_locs;


         IF (l_destination_location_id_tab.COUNT > 0) THEN
            --
            -- The query returned some records now create mapping tables of locations
            -- to regions
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id_tab.COUNT = ',l_destination_location_id_tab.COUNT);
            END IF;


            FOR ddd in l_destination_location_id_tab.FIRST..l_destination_location_id_tab.LAST LOOP
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id_tab(ddd) = ',l_destination_location_id_tab(ddd));
               END IF;

               l_loc_region_id_dest_tab(l_destination_location_id_tab(ddd)) := l_destination_region_id_tab(ddd);

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_loc_region_id_dest_tab(l_destination_location_id_tab(ddd)) =',l_loc_region_id_dest_tab(l_destination_location_id_tab(ddd)));
               END IF;
            END LOOP;
         END IF;
      END LOOP;



      --
      -- Populate the search table with OD pairs and  Check if
      -- any input locations do not have regions, i.e. were not
      -- found during the search
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Populate the search table with OD pairs and  Check ifany input locations do not have regions');
      END IF;

      --
      -- reset the search table index
      --
      l_ctr := 0;
      FOR eee IN p_distance_input_tab.FIRST..p_distance_input_tab.LAST LOOP

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_distance_input_tab(eee).origin_id = ',p_distance_input_tab(eee).origin_id);
           WSH_DEBUG_SV.log(l_module_name,'p_distance_input_tab(eee).destination_id = ',p_distance_input_tab(eee).destination_id);
         END IF;


         IF (l_loc_region_id_origin_tab.EXISTS(p_distance_input_tab(eee).origin_id)) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'A region for the location exists p_distance_input_tab(eee).origin_id = ',p_distance_input_tab(eee).origin_id);
            END IF;

            --
            -- origin exists, check the destination
            --
            IF (l_loc_region_id_dest_tab.EXISTS(p_distance_input_tab(eee).destination_id)) THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'A region for the destination location exists p_distance_input_tab(eee).destination_id = ',p_distance_input_tab(eee).destination_id);
               END IF;

               --
               -- destination exists put it in the search tab
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Add the OD pair to the search table');
               END IF;

               --
               -- increment the index counter
               --
               l_ctr := l_ctr + 1;
               l_search_tab(l_ctr).origin_id := l_loc_region_id_origin_tab(p_distance_input_tab(eee).origin_id);
               l_search_tab(l_ctr).destination_id := l_loc_region_id_dest_tab(p_distance_input_tab(eee).destination_id);

l_search_tab(l_ctr).origin_loc_id := p_distance_input_tab(eee).origin_id;
l_search_tab(l_ctr).dest_loc_id := p_distance_input_tab(eee).destination_id;

               --
               -- populate the region to location origin and destination tables
               -- to use in the distance search procdeure  to detemine the mapping
               -- for locations that are not found in the search
               --
               l_region_idx_loc_orig_tab(l_search_tab(l_ctr).origin_id) := p_distance_input_tab(eee).origin_id;
               l_region_idx_loc_dest_tab(l_search_tab(l_ctr).destination_id) := p_distance_input_tab(eee).destination_id;
            ELSE
               --
               -- The destination location has no region
               -- log a message do not include it in the search
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'The destination location has no region log a message do not include it in the search');
               END IF;


               IF (p_messaging_yn = 'Y') THEN
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'logging to the message table NO_REGION_MAP_D');
                  END IF;

                  l_msg_ctr := msg_message_text_tab.COUNT + 1;
                  FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_REGN_MAP_DEST_LOC');
                  FND_MESSAGE.SET_TOKEN('LOCATION_ID',to_char(p_distance_input_tab(eee).destination_id));
                  msg_message_text_tab(l_msg_ctr)         := FND_MESSAGE.GET;
                  msg_message_type_tab(l_msg_ctr)         := WSH_UTIL_CORE.G_RET_STS_WARNING;
                  msg_message_code_tab(l_msg_ctr)         := 'NO_REGION_MAP_D';
                  msg_location_region_flag_tab(l_msg_ctr) := p_location_region_flag;
                  msg_level_tab(l_msg_ctr)                := l_distance_profile;
                  msg_table_origin_id_tab(l_msg_ctr)      := null;
                  msg_table_destination_id_tab(l_msg_ctr) := null;
                  msg_input_origin_id_tab(l_msg_ctr)      := p_distance_input_tab(eee).origin_id;
                  msg_input_destination_tab(l_msg_ctr)    := p_distance_input_tab(eee).destination_id;
               END IF;
            END IF;
         ELSE
            --
            -- The origin location has no region
            -- log a message - do not include it in the search
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'The origin location has no region log a message do not include it in the search');
            END IF;


            IF (p_messaging_yn = 'Y') THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'logging to the message table NO_REGION_MAP_O');
               END IF;

               l_msg_ctr := msg_message_text_tab.COUNT + 1;
               FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_REGN_MAP_ORIG_LOC');
               FND_MESSAGE.SET_TOKEN('LOCATION_ID',to_char(p_distance_input_tab(eee).origin_id));
               msg_message_text_tab(l_msg_ctr)         := FND_MESSAGE.GET;
               msg_message_type_tab(l_msg_ctr)         := WSH_UTIL_CORE.G_RET_STS_WARNING;
               msg_message_code_tab(l_msg_ctr)         := 'NO_REGION_MAP_O';
               msg_location_region_flag_tab(l_msg_ctr) := p_location_region_flag;
               msg_level_tab(l_msg_ctr)                := l_distance_profile;
               msg_table_origin_id_tab(l_msg_ctr)      := null;
               msg_table_destination_id_tab(l_msg_ctr) := null;
               msg_input_origin_id_tab(l_msg_ctr)      := p_distance_input_tab(eee).origin_id;
               msg_input_destination_tab(l_msg_ctr)    := p_distance_input_tab(eee).destination_id;
            END IF;
         END IF;
      END LOOP;


      IF ((p_messaging_yn = 'Y') AND
          (msg_message_text_tab.COUNT > 0)) THEN
         --
         -- All messages have been logged in the temp tables now add the messages to
         -- the global tables
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Messaging is on and nessages exist Log the messages in the global message table');
         END IF;

         --
         -- Log the messages in the global message table
         --
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES(p_message_type_tab         => msg_message_type_tab,
                                                p_message_code_tab         => msg_message_code_tab,
                                                p_message_text_tab         => msg_message_text_tab,
                                                p_location_region_flag_tab => msg_location_region_flag_tab,
                                                p_level_tab                => msg_level_tab,
                                                p_table_origin_id_tab      => msg_table_origin_id_tab,
                                                p_table_destination_id_tab => msg_table_destination_id_tab,
                                                p_input_origin_id_tab      => msg_input_origin_id_tab,
                                                p_input_destination_tab    => msg_input_destination_tab,
                                                x_return_status            => l_return_status,
                                                x_return_message           => l_return_message);
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Back from calling FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES');
         END IF;
      END IF;



      --
      -- So now we have a search table of origin and destination regions
      -- and two tables of locations and regions for origin and destination
      -- indexed by region id, the search by flag and the messaging flag,
      -- now we can call the search procedure
      --
      -- l_search_tab
      -- l_region_idx_loc_orig_tab
      -- l_region_idx_loc_dest_tab
      -- p_location_region_flag
      -- p_messaging_yn


   ELSIF (p_location_region_flag = g_region_search_flag) THEN
      --
      -- The input is in region id form which means that we can go ahead
      -- and search without converting
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Input IDs are in region form, no need to convert just add to the search table');
      END IF;


      --
      -- Put the origin and destination into the search table
      --
      -- Reset the search table index counter
      --
      l_ctr := 0;
      FOR fff IN p_distance_input_tab.FIRST..p_distance_input_tab.LAST LOOP
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Adding to the search table');
            WSH_DEBUG_SV.log(l_module_name,'p_distance_input_tab(fff).origin_id = ',p_distance_input_tab(fff).origin_id);
            WSH_DEBUG_SV.log(l_module_name,'p_distance_input_tab(fff).destination_id = ',p_distance_input_tab(fff).destination_id);
         END IF;


         l_ctr := l_ctr + 1;
         l_search_tab(l_ctr).origin_id      := p_distance_input_tab(fff).origin_id;
         l_search_tab(l_ctr).destination_id := p_distance_input_tab(fff).destination_id;

l_search_tab(l_ctr).origin_loc_id := null;
l_search_tab(l_ctr).dest_loc_id := null;

      END LOOP;

      --
      -- So now we have a search table of regions now we can call the search
      -- procedure
      --
      -- l_search_tab
      -- p_location_region_flag
      -- p_messaging_yn

   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Check the search table is populated');
   END IF;


   IF (l_search_tab.COUNT > 0) THEN
      --
      -- We have O/D pairs to search with
      -- Call the Distance search procedure
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'records exist in search table l_search_tab.COUNT = ',l_search_tab.COUNT);
      END IF;


      --
      -- reset the result table and result found flag
      --
      l_result_table.DELETE;
      l_result_found_flag := 'N';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_DIST_INT_PKG.DISTANCE_SEARCH',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name,'---------- INPUT PARAMETERS -------------');
         WSH_DEBUG_SV.log(l_module_name,'p_location_region_flag',p_location_region_flag);
         WSH_DEBUG_SV.log(l_module_name,'p_messaging_yn',p_messaging_yn);
         WSH_DEBUG_SV.log(l_module_name,'p_search_tab count = ', l_search_tab.COUNT);
         IF (l_search_tab.COUNT > 0) THEN
            FOR dbst IN l_search_tab.FIRST..l_search_tab.LAST LOOP
                WSH_DEBUG_SV.log(l_module_name,'l_search_tab(dbst).origin_id', l_search_tab(dbst).origin_id);
                WSH_DEBUG_SV.log(l_module_name,'l_search_tab(dbst).destination_id', l_search_tab(dbst).destination_id);
WSH_DEBUG_SV.log(l_module_name,'l_search_tab(dbst).origin_loc_id',l_search_tab(dbst).origin_loc_id);
WSH_DEBUG_SV.log(l_module_name,'l_search_tab(dbst).dest_loc_id',l_search_tab(dbst).dest_loc_id);
            END LOOP;
         END IF;
         WSH_DEBUG_SV.log(l_module_name,'p_origin_reg_loc_tab count = ', l_region_idx_loc_orig_tab.COUNT);
         IF (l_region_idx_loc_orig_tab.COUNT > 0) THEN
            FOR dbrilo IN l_region_idx_loc_orig_tab.FIRST..l_region_idx_loc_orig_tab.LAST LOOP
               IF (l_region_idx_loc_orig_tab.EXISTS(dbrilo)) THEN
                  WSH_DEBUG_SV.log(l_module_name,'(dbrilo)',dbrilo);
                  WSH_DEBUG_SV.log(l_module_name,'l_region_idx_loc_orig_tab(dbrilo)',l_region_idx_loc_orig_tab(dbrilo));
               END IF;
            END LOOP;
         END IF;
         WSH_DEBUG_SV.log(l_module_name,'p_dest_reg_loc_tab count = ', l_region_idx_loc_dest_tab.COUNT);
         IF (l_region_idx_loc_dest_tab.COUNT > 0) THEN
            FOR dbrild IN l_region_idx_loc_dest_tab.FIRST..l_region_idx_loc_dest_tab.LAST LOOP
               IF (l_region_idx_loc_dest_tab.EXISTS(dbrild)) THEN
                  WSH_DEBUG_SV.log(l_module_name,'(dbrild)',dbrild);
                  WSH_DEBUG_SV.log(l_module_name,'l_region_idx_loc_dest_tab(dbrild)',l_region_idx_loc_dest_tab(dbrild));
               END IF;
            END LOOP;
         END IF;
      END IF;


      FTE_DIST_INT_PKG.DISTANCE_SEARCH(p_location_region_flag  => p_location_region_flag,
                                       p_messaging_yn          => p_messaging_yn,
                                       p_level                 => l_distance_profile,
                                       p_search_tab            => l_search_tab,
                                       p_origin_reg_loc_tab    => l_region_idx_loc_orig_tab,
                                       p_dest_reg_loc_tab      => l_region_idx_loc_dest_tab,
                                       x_result_found          => l_result_found_flag,
                                       x_result_table          => l_result_table,
                                       x_return_message        => l_return_message,
                                       x_return_status         => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'------- back from FTE_DIST_INT_PKG.DISTANCE_SEARCH -----');
         WSH_DEBUG_SV.logmsg(l_module_name,'---------- OUTPUT PARAMETERS -------------');
         WSH_DEBUG_SV.log(l_module_name,'x_result_found',l_result_found_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_result_table count = ',l_result_table.COUNT);
         WSH_DEBUG_SV.log(l_module_name,'x_return_message',l_return_message);
         WSH_DEBUG_SV.log(l_module_name,'x_return_status',l_return_status);
      END IF;


      IF ((l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
          (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         --
         -- A serious error occurred performing the search
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'A serious error occurred performing the search - RAISE FTE_DIST_DISTANCE_SEARCH_ERR');
         END IF;


         RAISE FTE_DIST_DISTANCE_SEARCH_ERR;

      END IF;

   ELSE
      --
      -- The search table is empty which means that there are no regions to search for
      -- at all
      -- Raise an error and return
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The search table is empty which means that there are no regions to search for');

      END IF;


      IF (p_location_region_flag = g_location_search_flag) THEN
         --
         -- No regions were found for any location ids - raise an error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'No regions were found for any location ids - raise an error FTE_DIST_NO_REGS_FOR_ANY_LOCS');
         END IF;

         RAISE FTE_DIST_NO_REGS_FOR_ANY_LOCS;

      ELSIF (p_location_region_flag = g_region_search_flag) THEN
         --
         -- something went horribly wrong, none of the regions populated
         -- in the search table!
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'something went horribly wrong, none of the regions populatedin the search table - RAISE FTE_DIST_NO_REGS_IN_SEARCH');
         END IF;

         RAISE FTE_DIST_NO_REGS_IN_SEARCH;

      END IF;

   END IF;


   IF (l_result_found_flag = 'Y') THEN
      --
      -- a result has been found return to the calling program
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The search executed successfully and at least 1 result was found');
        IF (l_result_table.COUNT > 0) THEN
           FOR sss in l_result_table.FIRST..l_result_table.LAST LOOP
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).location_region_flag = ',l_result_table(sss).location_region_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).origin_location_id = ',l_result_table(sss).origin_location_id);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).destination_location_id = ',l_result_table(sss).destination_location_id);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).origin_region_id = ',l_result_table(sss).origin_region_id);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).destination_region_id = ',l_result_table(sss).destination_region_id);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).type = ',l_result_table(sss).type);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).distance = ',l_result_table(sss).distance);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).distance_uom = ',l_result_table(sss).distance_uom);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).transit_time = ',l_result_table(sss).transit_time);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).transit_time_uom = ',l_result_table(sss).transit_time_uom);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).status = ',l_result_table(sss).status);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).error_msg = ',l_result_table(sss).error_msg);
              WSH_DEBUG_SV.log(l_module_name,'l_result_table(sss).msg_id = ',l_result_table(sss).msg_id);
           END LOOP;
        END IF;
      END IF;


      x_distance_output_tab  := l_result_table;
      x_return_status        := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      x_return_message       := null;
      x_distance_message_tab := g_message_tab;
      g_message_tab.DELETE;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   ELSE
      --
      -- If here, no errors, but no result found - return a warning indicator
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The search executed successfully but no records were found - return with a warning status');
      END IF;

      x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
      x_return_message := WSH_UTIL_CORE.G_RET_STS_WARNING;
      x_distance_message_tab := g_message_tab;
      g_message_tab.DELETE;

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
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --


EXCEPTION
   WHEN FTE_DIST_NO_INPUT_DATA THEN
      --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_INPUT_DATA');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_NO_INPUT_DATA';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NO_INPUT_DATA RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_INPUT_DATA exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_INPUT_DATA');
      END IF;

   WHEN FTE_DIST_INVALID_LOC_REG_FLAG THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_LOC_REG_FLAG');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_INVALID_LOC_REG_FLAG';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_ACS_PKG.START_ACS FTE_DIST_INVALID_LOC_REG_FLAG RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_LOC_REG_FLAG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_LOC_REG_FLAG');
      END IF;

   WHEN FTE_DIST_DISTANCE_SEARCH_ERR THEN
      x_return_status  := l_return_status;
      x_return_message := l_return_message;

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_INT_PKG.GET_DISTANCE_TIME ( FTE_DIST_DISTANCE_SEARCH_ERR ) IS '||L_RETURN_STATUS||': '||L_RETURN_MESSAGE  );
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_DISTANCE_SEARCH_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_DISTANCE_SEARCH_ERR');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_INT.GET_DISTANCE_TIME');

   WHEN FTE_DIST_INVALID_PROFILE THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_PROFILE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_INVALID_PROFILE';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_INVALID_PROFILE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_PROFILE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_PROFILE');
      END IF;

   WHEN FTE_DIST_NULL_PROFILE THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_PROFILE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_NULL_PROFILE';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NULL_PROFILE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_PROFILE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_PROFILE');
      END IF;

   WHEN FTE_DIST_NO_REGS_FOR_ANY_LOCS THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_REGS_FOR_ANY_LOCS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_NO_REGS_FOR_ANY_LOCS';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NO_REGS_FOR_ANY_LOCS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_REGS_FOR_ANY_LOCS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_REGS_FOR_ANY_LOCS');
      END IF;

   WHEN FTE_DIST_NO_REGS_IN_SEARCH THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_REGS_IN_SEARCH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_NO_REGS_IN_SEARCH';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NO_REGS_IN_SEARCH RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_REGS_IN_SEARCH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_REGS_IN_SEARCH');
      END IF;

   WHEN FTE_DIST_NULL_REGION_TYPE THEN
   --5067249
      --FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_REGION_TYPE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'FTE_DIST_NULL_REGION_TYPE';
      --WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NULL_REGION_TYPE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_REGION_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_REGION_TYPE');
      END IF;

   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Close any open cursors
      --
      IF (c_get_regions_for_locs%ISOPEN) THEN
         CLOSE c_get_regions_for_locs;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_INT_PKG.GET_DISTANCE_TIME IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_INT_PKG.GET_DISTANCE_TIME');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := l_error_text;

END GET_DISTANCE_TIME;




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                DISTANCE_SEARCH                                       --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_search_tab       IN OUT NOCOPY                      --
--                                         FTE_DIST_INT.fte_dist_search_table --
--                      p_messaging_yn     IN  VARCHAR2                       --
--                                                                            --
-- PARAMETERS (OUT):    x_result_found   OUT VARCHAR2                         --
--                      x_result_table   OUT NOCOPY                           --
--                                       FTE_DIST_INT_PKG.fte_dist_output_tab --
--                      x_return_message OUT VARCHAR2,                        --
--                      x_return_status  OUT VARCHAR2                         --
--                                                                            --
-- PARAMETERS (IN OUT): none                                                  --
--                                                                            --
-- RETURN:              none                                                  --
--                                                                            --
-- DESCRIPTION:         This procedure performs the distance and transit time --
--                      search for each set of OD pairs passed in in the      --
--                      search table. It returns any found results in the     --
--                      result table output parameter. If no results are      --
--                      found at all a warning is returned. If any OD pairs   --
--                      are not found they will be added to the message table --
--                      as no recods found                                    --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/14  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE DISTANCE_SEARCH(p_location_region_flag IN VARCHAR2,
                          p_messaging_yn         IN VARCHAR2,
                          p_level                IN VARCHAR2,
                          p_search_tab           IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_search_tab,
                          p_origin_reg_loc_tab   IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                          p_dest_reg_loc_tab     IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                          x_result_found         OUT NOCOPY VARCHAR2,
                          x_result_table         OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_tab,
                          x_return_message       OUT NOCOPY VARCHAR2,
                          x_return_status        OUT NOCOPY VARCHAR2) IS


--
-- Local Variable definitions
--
l_msg_ctr           PLS_INTEGER;          -- counter for populating message table index
l_ctr               PLS_INTEGER;          -- counter for populating result table index
l_return_message    VARCHAR2(2000);       -- Return message from API (if error in API)
l_return_status     VARCHAR2(1);          -- Return Status from called API (values = S,E,W,U)
l_error_text        VARCHAR2(2000);       -- holds th unexpected error message text
l_msg_no_rcds_fnd   VARCHAR2(2000);       -- holds the message text of no records found msg

--
-- Local records/tables
--
l_rslt_origin_id_tab         FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_rslt_destination_id_tab    FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_rslt_identifier_type_tab   FTE_DIST_INT_PKG.fte_dist_tmp_code_table;
l_rslt_distance_tab          FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_rslt_distance_uom_tab      FTE_DIST_INT_PKG.fte_dist_tmp_uom_table;
l_rslt_transit_time_tab      FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
l_rslt_transit_time_uom_tab  FTE_DIST_INT_PKG.fte_dist_tmp_uom_table;

l_result_table               FTE_DIST_INT_PKG.fte_dist_output_tab;


--
-- Message logging tables
--
msg_message_type_tab          FTE_DIST_INT_PKG.fte_dist_tmp_flag_table;
msg_message_code_tab          FTE_DIST_INT_PKG.fte_dist_tmp_code_table;
msg_message_text_tab          FTE_DIST_INT_PKG.fte_dist_tmp_msg_table;
msg_location_region_flag_tab  FTE_DIST_INT_PKG.fte_dist_tmp_flag_table;
msg_level_tab                 FTE_DIST_INT_PKG.fte_dist_tmp_code_table;
msg_table_origin_id_tab       FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_table_destination_id_tab  FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_input_origin_id_tab       FTE_DIST_INT_PKG.fte_dist_tmp_num_table;
msg_input_destination_tab     FTE_DIST_INT_PKG.fte_dist_tmp_num_table;



--
-- Cursor Definitions
--
-- -----------------------------------------------------------------
-- Distance and transit time search query
-- -----------------------------------------------------------------
--
cursor c_perform_distance_search(cp_origin_id       NUMBER,
                                 cp_destination_id  NUMBER,
                                 cp_identifier_type VARCHAR2) IS
select flm.origin_id,
       flm.destination_id,
       flm.identifier_type,
       flm.distance,
       flm.distance_uom,
       flm.transit_time,
       flm.transit_time_uom
from   fte_location_mileages flm
where  flm.origin_id       = cp_origin_id
and    flm.destination_id  = cp_destination_id
and    flm.identifier_type = cp_identifier_type;



--
-- Debug Local Variables
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DISTANCE_SEARCH';


BEGIN

   --
   -- Set the procedure debug stuff
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   --
   -- Debug Statements for input parameters
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'------- DISTANCE SEARCH INPUT PARAMETERS ------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-----------------------------------------------');
      WSH_DEBUG_SV.log(l_module_name,'p_location_region_flag',p_location_region_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_messaging_yn',p_messaging_yn);
      WSH_DEBUG_SV.log(l_module_name,'p_search_tab count = ', p_search_tab.COUNT);
      IF (p_search_tab.COUNT > 0) THEN
         FOR dbst IN p_search_tab.FIRST..p_search_tab.LAST LOOP
            WSH_DEBUG_SV.log(l_module_name,'p_search_tab(dbst).origin_id', p_search_tab(dbst).origin_id);
            WSH_DEBUG_SV.log(l_module_name,'p_search_tab(dbst).destination_id', p_search_tab(dbst).destination_id);
WSH_DEBUG_SV.log(l_module_name,'p_search_tab(dbst).origin_loc_id',p_search_tab(dbst).origin_loc_id);
WSH_DEBUG_SV.log(l_module_name,'p_search_tab(dbst).dest_loc_id',p_search_tab(dbst).dest_loc_id);
         END LOOP;
      END IF;
      WSH_DEBUG_SV.log(l_module_name,'p_origin_reg_loc_tab count = ', p_origin_reg_loc_tab.COUNT);
      IF (p_origin_reg_loc_tab.COUNT > 0) THEN
         FOR dbrilo IN p_origin_reg_loc_tab.FIRST..p_origin_reg_loc_tab.LAST LOOP
            IF (p_origin_reg_loc_tab.EXISTS(dbrilo)) THEN
               WSH_DEBUG_SV.log(l_module_name,'(dbrilo)',dbrilo);
               WSH_DEBUG_SV.log(l_module_name,'p_origin_reg_loc_tab(dbrilo)',p_origin_reg_loc_tab(dbrilo));
            END IF;
         END LOOP;
      END IF;
      WSH_DEBUG_SV.log(l_module_name,'p_dest_reg_loc_tab count = ', p_dest_reg_loc_tab.COUNT);
      IF (p_dest_reg_loc_tab.COUNT > 0) THEN
         FOR dbrild IN p_dest_reg_loc_tab.FIRST..p_dest_reg_loc_tab.LAST LOOP
            IF (p_dest_reg_loc_tab.EXISTS(dbrild)) THEN
               WSH_DEBUG_SV.log(l_module_name,'(dbrild)',dbrild);
               WSH_DEBUG_SV.log(l_module_name,'p_dest_reg_loc_tab(dbrild)',p_dest_reg_loc_tab(dbrild));
            END IF;
         END LOOP;
      END IF;
   END IF;


   --
   -- Set the return parameters for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   l_ctr := 0;
   --
   -- we are going to loop through each OD pair and try and find
   -- a matching distance record
   --
   --
   -- Clean out the local tables
   --
   l_rslt_origin_id_tab.DELETE;
   l_rslt_destination_id_tab.DELETE;
   l_rslt_identifier_type_tab.DELETE;
   l_rslt_distance_tab.DELETE;
   l_rslt_distance_uom_tab.DELETE;
   l_rslt_transit_time_tab.DELETE;
   l_rslt_transit_time_uom_tab.DELETE;
   l_result_table.DELETE;


   --
   -- Reset the message tables
   --
   msg_message_type_tab.DELETE;
   msg_message_code_tab.DELETE;
   msg_message_text_tab.DELETE;
   msg_location_region_flag_tab.DELETE;
   msg_level_tab.DELETE;
   msg_table_origin_id_tab.DELETE;
   msg_table_destination_id_tab.DELETE;
   msg_input_origin_id_tab.DELETE;
   msg_input_destination_tab.DELETE;


   IF (p_messaging_yn = 'Y') THEN
      --
      -- Set the no records found error message in case we need to log it
      --
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RECORDS_FOUND');
      l_msg_no_rcds_fnd := FND_MESSAGE.GET;
   END IF;



   FOR ggg IN p_search_tab.FIRST..p_search_tab.LAST LOOP
      --
      -- Perform the search to find matching rules
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'-----------------------------------------');
         WSH_DEBUG_SV.logmsg(l_module_name,'RUNNING cursor c_perform_distance_search:');
         WSH_DEBUG_SV.log(l_module_name,'p_search_tab(ggg).origin_id',p_search_tab(ggg).origin_id);
         WSH_DEBUG_SV.log(l_module_name,'p_search_tab(ggg).destination_id',p_search_tab(ggg).destination_id);
         WSH_DEBUG_SV.log(l_module_name,'p_level',p_level);
         WSH_DEBUG_SV.logmsg(l_module_name,'-----------------------------------------');
      END IF;

      OPEN c_perform_distance_search(p_search_tab(ggg).origin_id,
                                     p_search_tab(ggg).destination_id,
                                     p_level);
         FETCH c_perform_distance_search BULK COLLECT INTO
            l_rslt_origin_id_tab,
            l_rslt_destination_id_tab,
            l_rslt_identifier_type_tab,
            l_rslt_distance_tab,
            l_rslt_distance_uom_tab,
            l_rslt_transit_time_tab,
            l_rslt_transit_time_uom_tab;
      CLOSE c_perform_distance_search;




   --
   -- Search completed for OD pair see if theres any
   -- results found and load up the output table with the data
   -- if so
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_rslt_origin_id_tab.COUNT = ',l_rslt_origin_id_tab.COUNT);
   END IF;

   IF (l_rslt_origin_id_tab.COUNT > 0) THEN
      --
      -- Results exist - set the result found flag
      --
      x_result_found := 'Y';

      --
      -- Loop through the results and populate the result table
      --
      FOR hhh in l_rslt_origin_id_tab.FIRST..l_rslt_origin_id_tab.LAST LOOP
         --
         -- increment the index counter for the result table
         --
         l_ctr := l_ctr + 1;

         l_result_table(l_ctr).location_region_flag := p_location_region_flag;

         IF (p_location_region_flag = g_location_search_flag) THEN
            --
            -- The search was for locations - get the corresponding location for the
            -- region found
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'The search was for locations - get the corresponding location for the region found');
            END IF;

-- AXE
--            l_result_table(l_ctr).origin_location_id := p_origin_reg_loc_tab(l_rslt_origin_id_tab(hhh));
--            l_result_table(l_ctr).destination_location_id := p_dest_reg_loc_tab(l_rslt_destination_id_tab(hhh));

l_result_table(l_ctr).origin_location_id := p_search_tab(ggg).origin_loc_id;
l_result_table(l_ctr).destination_location_id := p_search_tab(ggg).dest_loc_id;


            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_result_table(l_ctr).origin_location_id = ',p_origin_reg_loc_tab(l_rslt_origin_id_tab(hhh)));
               WSH_DEBUG_SV.log(l_module_name,'l_result_table(l_ctr).destination_location_id = ',p_dest_reg_loc_tab(l_rslt_destination_id_tab(hhh)));
            END IF;

         ELSIF (p_location_region_flag = g_region_search_flag) THEN
            --
            -- The search was for Regions - populate the result table
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'The search was for Regions - populate the result table');
            END IF;

            l_result_table(l_ctr).origin_location_id      := null;
            l_result_table(l_ctr).destination_location_id := null;
         END IF;

         l_result_table(l_ctr).origin_region_id      := l_rslt_origin_id_tab(hhh);
         l_result_table(l_ctr).destination_region_id := l_rslt_destination_id_tab(hhh);
         l_result_table(l_ctr).type                  := p_level;
         l_result_table(l_ctr).distance              := l_rslt_distance_tab(hhh);
         l_result_table(l_ctr).distance_uom          := l_rslt_distance_uom_tab(hhh);
         l_result_table(l_ctr).transit_time          := l_rslt_transit_time_tab(hhh);
         l_result_table(l_ctr).transit_time_uom      := l_rslt_transit_time_uom_tab(hhh);
         l_result_table(l_ctr).status                := null;
         l_result_table(l_ctr).error_msg             := null;
         l_result_table(l_ctr).msg_id                := null;
      END LOOP;
   ELSE
      --
      -- Nothing was found - log a message
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'No result was found for the OD pair');
      END IF;

      IF (p_messaging_yn = 'Y') THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'No result was found for the OD pair - log a NO_RECORDS_FOUND log message');
         END IF;

         l_msg_ctr := msg_message_text_tab.COUNT + 1;
         msg_message_text_tab(l_msg_ctr)         := l_msg_no_rcds_fnd;
         msg_message_type_tab(l_msg_ctr)         := WSH_UTIL_CORE.G_RET_STS_WARNING;
         msg_message_code_tab(l_msg_ctr)         := 'NO_RECORDS_FOUND';
         msg_location_region_flag_tab(l_msg_ctr) := p_location_region_flag;
         msg_level_tab(l_msg_ctr)                := p_level;
         msg_table_origin_id_tab(l_msg_ctr)      := null;
         msg_table_destination_id_tab(l_msg_ctr) := null;
         IF (p_location_region_flag = g_location_search_flag) THEN
            msg_input_origin_id_tab(l_msg_ctr)      := p_origin_reg_loc_tab(p_search_tab(ggg).origin_id);
            msg_input_destination_tab(l_msg_ctr)    := p_dest_reg_loc_tab(p_search_tab(ggg).destination_id);
        ELSIF (p_location_region_flag = g_region_search_flag) THEN
            msg_input_origin_id_tab(l_msg_ctr)      := p_search_tab(ggg).origin_id;
            msg_input_destination_tab(l_msg_ctr)    := p_search_tab(ggg).destination_id;
        END IF;

      END IF;



      --
      -- set the return status to a warning
      --
      x_return_message := null;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      -- IF l_debug_on THEN
      --    WSH_DEBUG_SV.pop(l_module_name);
      -- END IF;
      --
   END IF;

   END LOOP; -- search loop


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Search is completed');
   END IF;


   --
   -- So we are here, this means that we either have a result or we do not!
   -- aahh, who cares.. just return back
   --
   IF (x_result_found = 'Y') THEN
      --
      -- We hava winner!!!!
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'We have a winner');
      END IF;
      x_result_table   := l_result_table;
      x_return_message := null;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

      IF ((p_messaging_yn = 'Y') AND
          (msg_message_type_tab.COUNT > 0)) THEN
         --
         -- There are messages write them to the log
         --
         FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES(p_message_type_tab         => msg_message_type_tab,
                                                p_message_code_tab         => msg_message_code_tab,
                                                p_message_text_tab         => msg_message_text_tab,
                                                p_location_region_flag_tab => msg_location_region_flag_tab,
                                                p_level_tab                => msg_level_tab,
                                                p_table_origin_id_tab      => msg_table_origin_id_tab,
                                                p_table_destination_id_tab => msg_table_destination_id_tab,
                                                p_input_origin_id_tab      => msg_input_origin_id_tab,
                                                p_input_destination_tab    => msg_input_destination_tab,
                                                x_return_status            => l_return_status,
                                                x_return_message           => l_return_message);
      END IF;

      RETURN;
   ELSE
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'no result just return a warning');
      END IF;

      IF (p_messaging_yn = 'Y') THEN
         --
         -- no result just return a warning
         --
         l_msg_ctr := msg_message_text_tab.COUNT + 1;
         msg_message_text_tab(l_msg_ctr)         := l_msg_no_rcds_fnd;
         msg_message_type_tab(l_msg_ctr)         := WSH_UTIL_CORE.G_RET_STS_WARNING;
         msg_message_code_tab(l_msg_ctr)         := 'NO_RECORDS_FOUND';
         msg_location_region_flag_tab(l_msg_ctr) := p_location_region_flag;
         msg_level_tab(l_msg_ctr)                := p_level;
         msg_table_origin_id_tab(l_msg_ctr)      := null;
         msg_table_destination_id_tab(l_msg_ctr) := null;
         msg_input_origin_id_tab(l_msg_ctr)      := null;
         msg_input_destination_tab(l_msg_ctr)    := null;


         FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES(p_message_type_tab         => msg_message_type_tab,
                                                p_message_code_tab         => msg_message_code_tab,
                                                p_message_text_tab         => msg_message_text_tab,
                                                p_location_region_flag_tab => msg_location_region_flag_tab,
                                                p_level_tab                => msg_level_tab,
                                                p_table_origin_id_tab      => msg_table_origin_id_tab,
                                                p_table_destination_id_tab => msg_table_destination_id_tab,
                                                p_input_origin_id_tab      => msg_input_origin_id_tab,
                                                p_input_destination_tab    => msg_input_destination_tab,
                                                x_return_status            => l_return_status,
                                                x_return_message           => l_return_message);

      END IF;

      x_result_found := 'N';
      x_return_message := null;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
      -- Close any open cursors
      --
      IF (c_perform_distance_search%ISOPEN) THEN
         CLOSE c_perform_distance_search;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_INT_PKG.DISTANCE_SEARCH IS ' ||L_ERROR_TEXT  );
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_INT_PKG.DISTANCE_SEARCH');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := ('FTE_DIST_INT_PKG.DISTANCE_SEARCH '||l_error_text);
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

END DISTANCE_SEARCH;





-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                LOG_DISTANCE_MESSAGES                                 --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_message_type_tab         IN OUT NOCOPY              --
--                                   FTE_DIST_INT_PKG.fte_dist_tmp_flag_table --
--                      p_message_code_tab         IN OUT NOCOPY              --
--                                   FTE_DIST_INT_PKG.fte_dist_tmp_code_table --
--                      p_message_text_tab         IN OUT NOCOPY              --
--                                    FTE_DIST_INT_PKG.fte_dist_tmp_msg_table --
--                      p_location_region_flag_tab IN OUT NOCOPY              --
--                                   FTE_DIST_INT_PKG.fte_dist_tmp_flag_table --
--                      p_level_tab                IN OUT NOCOPY              --
--                                   FTE_DIST_INT_PKG.fte_dist_tmp_code_table --
--                      p_table_origin_id_tab      IN OUT NOCOPY              --
--                                    FTE_DIST_INT_PKG.fte_dist_tmp_num_table --
--                      p_table_destination_id_tab IN OUT NOCOPY              --
--                                    FTE_DIST_INT_PKG.fte_dist_tmp_num_table --
--                      p_input_origin_id_tab      IN OUT NOCOPY              --
--                                    FTE_DIST_INT_PKG.fte_dist_tmp_num_table --
--                      p_input_destination_tab    IN OUT NOCOPY              --
--                                    FTE_DIST_INT_PKG.fte_dist_tmp_num_table --
--                                                                            --
-- PARAMETERS (OUT):    x_return_status      OUT NOCOPY VARCHAR2              --
--                      x_return_message     OUT NOCOPY VARCHAR2              --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         This procedure takes in tables of messages and rule/  --
--                      result information and adds them to the global        --
--                      message table which is returned to the calling API    --
--                      at the end of the distance search Engine execution.   --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/14  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE LOG_DISTANCE_MESSAGES(p_message_type_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_flag_table,
                            p_message_code_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_code_table,
                            p_message_text_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_msg_table,
                            p_location_region_flag_tab IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_flag_table,
                            p_level_tab                IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_code_table,
                            p_table_origin_id_tab      IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                            p_table_destination_id_tab IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                            p_input_origin_id_tab      IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                            p_input_destination_tab    IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                            x_return_status            OUT NOCOPY VARCHAR2,
                            x_return_message           OUT NOCOPY VARCHAR2) IS




l_error_text VARCHAR2(2000);
l_cs_message VARCHAR2(2000);
l_rec_count  PLS_INTEGER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_DISTANCE_MESSAGES';
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

   -- Bug 4996745
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message := null;


   FOR abcd IN p_message_type_tab.FIRST..p_message_type_tab.LAST LOOP

      l_rec_count := g_message_tab.count + 1;

      g_message_tab(l_rec_count).sequence_number := l_rec_count;
      g_message_tab(l_rec_count).message_type    := p_message_type_tab(abcd);

      IF (p_message_code_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).message_code := p_message_code_tab(abcd);
      ELSE
        g_message_tab(l_rec_count).message_code := null;
      END IF;

      IF (p_message_text_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).message_text    := p_message_text_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).message_text := null;
      END IF;

      IF (p_location_region_flag_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).location_region_flag := p_location_region_flag_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).location_region_flag := null;
      END IF;

      IF (p_level_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).level        := p_level_tab(abcd);
      ELSE
          g_message_tab(l_rec_count).level       := null;
      END IF;

      IF (p_table_origin_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).table_origin_id     := p_table_origin_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).table_origin_id     := null;
      END IF;

      IF (p_table_destination_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).table_destination_id     := p_table_destination_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).table_destination_id     := null;
      END IF;

      IF (p_input_origin_id_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).input_origin_id      := p_input_origin_id_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).input_origin_id      := null;
      END IF;

      IF (p_input_destination_tab.EXISTS(abcd)) THEN
         g_message_tab(l_rec_count).input_destination_id    := p_input_destination_tab(abcd);
      ELSE
         g_message_tab(l_rec_count).input_destination_id    := null;
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

EXCEPTION
   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES IS ' ||L_ERROR_TEXT  );
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := ('FTE_DIST_INT_PKG.LOG_DISTANCE_MESSAGES '||l_error_text);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

      RETURN;

END LOG_DISTANCE_MESSAGES;


END FTE_DIST_INT_PKG;

/
