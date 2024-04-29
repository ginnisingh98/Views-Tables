--------------------------------------------------------
--  DDL for Package WSH_REGIONS_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_REGIONS_SEARCH_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHRESES.pls 120.3.12010000.3 2009/08/04 09:38:33 gbhargav ship $ */

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
  g_mode     VARCHAR2(30) := 'CREATE';

  TYPE region_rec IS RECORD (
	region_id		NUMBER,
	region_type		NUMBER,
	country 		VARCHAR2(80),
	country_region 		VARCHAR2(60),
	state 			VARCHAR2(120), --bug 8687139 length increased to 120 from 60
	city 			VARCHAR2(60),
	postal_code_from  	VARCHAR2(60),
	postal_code_to 		VARCHAR2(60),
	zone			VARCHAR2(60),
	zone_level		NUMBER,
	country_code 	 	VARCHAR2(10),
	country_region_code  	VARCHAR2(10),
	state_code 	 	VARCHAR2(10),
	city_code 	 	VARCHAR2(10),
	is_input_type           VARCHAR2(1)
   );

  TYPE region_table IS TABLE OF region_rec INDEX BY BINARY_INTEGER;

  TYPE  region_deconsol_rec_type IS RECORD (
	          Region_id NUMBER,
	          Region_type NUMBER,
	          Deconsol_location NUMBER);

  TYPE  region_deconsol_tab_type IS TABLE OF region_deconsol_rec_type INDEX BY BINARY_INTEGER;

  TYPE  region_zone_deconsol_tab_type IS TABLE OF region_deconsol_tab_type INDEX BY BINARY_INTEGER;

  TYPE  loc_region_deconsol_tab_type IS TABLE OF region_deconsol_tab_type INDEX BY BINARY_INTEGER;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   Obtains information of the region by matching all non-null
  -- 		parameters that are passed in.  If none, returns null in x_region_info
  --		Has one more parameter P_SEARCH_FLAG for Postal Code Regions
  --		'Y' search for the exactly same region
  -- 		'N' search for the overlapping regions as well

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
	x_region_info			OUT NOCOPY 	region_rec);

  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   Obtains region_id only of the region by matching all non-null
  -- 		parameters that are passed in.  If none, returns -1 in x_region_id
  --		Has one more parameter P_SEARCH_FLAG for Postal Code Regions
  --		'Y' search for the exactly same region
  -- 		'N' search for the overlapping regions as well
  -- 		P_RECURSIVELY_FLAG will remove postal code from criteria and search
  -- 		again

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
	x_region_id			OUT NOCOPY 	NUMBER);


  --
  -- Procedure: Get_Region_Info
  --
  -- Purpose:   Obtains information of the region by matching all non-null
  -- 		parameters that are passed in.  If none, returns null in x_region_info
  --		Call another Get_Region_Info with default p_search_flag='N'

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
	x_region_info			OUT NOCOPY 	region_rec);


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
	p_search_flag			IN	VARCHAR2 DEFAULT 'N',
	x_regions			OUT NOCOPY 	region_table);
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
	p_lang_code			IN	VARCHAR2,
	x_region_id_non_tl		OUT NOCOPY 	NUMBER,
	x_region_id_with_tl		OUT NOCOPY 	NUMBER);

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
	p_insert_flag			IN	VARCHAR2) RETURN NUMBER;

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
    p_end_date          IN  VARCHAR2);

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
    );

  --
  -- Procedure: Get_Child_Requests_Status
  --
  -- Purpose:   Obtains the completion status of all the child requests
  --            and sets x_completion_status accordingly
  --

  PROCEDURE Get_Child_Requests_Status
  (
    x_completion_status OUT NOCOPY    VARCHAR2
  );

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
	x_regions			OUT NOCOPY 	region_table);

  --
  -- Procedure: Get_All_Zone_Matches
  --
  -- Purpose  : The API derives Zones for an input Region .
  --	        A cache is used for the region to zone mapping.
  --

  PROCEDURE Get_All_Zone_Matches(
	p_region_id		IN	    NUMBER,
	x_zone_tab		OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
	x_return_status         OUT NOCOPY  VARCHAR2);


  --
  -- Procedure: Get_All_RegionId_Matches
  --
  -- Purpose  : The API derives Region id for an input location,
  --	        using table WSH_REGION_LOCATIONS
  --	        Cache is used for storing and retriving location region mappings.
  --	        when p_use_cache is FALSE

  PROCEDURE Get_All_RegionId_Matches(
	 p_location_id		IN	    NUMBER,
	 p_use_cache		IN	    BOOLEAN	DEFAULT FALSE,
	 p_lang_code		IN	    VARCHAR2,
	 x_region_tab		OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
	 x_return_status        OUT NOCOPY  VARCHAR2);

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
         x_return_status        OUT NOCOPY  VARCHAR2);

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
            x_region_info    OUT NOCOPY   WSH_REGIONS_SEARCH_PKG.region_rec);

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
            x_region_info    OUT NOCOPY   WSH_REGIONS_SEARCH_PKG.region_rec);

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
            x_region_id      OUT NOCOPY   NUMBER );

  --
  -- PROCEDURE : Map_Location_Region_Child
  --
  -- PURPOSE   : Child program to Location to Region Mapping Concurrent request.
  --             Calls appropriate procedure depending upon value of mode parameter.

   PROCEDURE Map_Location_Region_Child(
    p_errbuf           OUT NOCOPY   VARCHAR2,
    p_retcode          OUT NOCOPY   NUMBER,
    p_mode             IN   VARCHAR2,
    p_location_type    IN   VARCHAR2,
    p_from_value       IN   NUMBER,
    p_to_value         IN   NUMBER,
    p_start_date       IN   VARCHAR2,
    p_end_date         IN   VARCHAR2,
    p_insert_flag      IN   VARCHAR2);


END WSH_REGIONS_SEARCH_PKG;


/
