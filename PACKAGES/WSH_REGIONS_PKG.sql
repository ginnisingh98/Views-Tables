--------------------------------------------------------
--  DDL for Package WSH_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_REGIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHRETHS.pls 120.1 2005/07/05 00:17:27 pkaliyam noship $ */

  --
  -- Package
  --   	WSH_REGIONS_PKG
  --
  -- Purpose
  --

  --
  -- PACKAGE TYPES
  --

     TYPE tab_region_id           is TABLE OF WSH_REGIONS.Region_Id%TYPE           index by binary_integer;
     TYPE tab_country_code        is TABLE OF WSH_REGIONS.Country_Code%TYPE        index by binary_integer;
     TYPE tab_country_region_code is TABLE OF WSH_REGIONS.Country_Region_Code%TYPE index by binary_integer;
     TYPE tab_state_code          is TABLE OF WSH_REGIONS.State_Code%TYPE          index by binary_integer;
     TYPE tab_city_code           is TABLE OF WSH_REGIONS.City_Code%TYPE           index by binary_integer;
     TYPE tab_port_flag           is TABLE OF WSH_REGIONS.Port_Flag%TYPE           index by binary_integer;
     TYPE tab_airport_flag        is TABLE OF WSH_REGIONS.Airport_Flag%TYPE        index by binary_integer;
     TYPE tab_road_terminal_flag  is TABLE OF WSH_REGIONS.Road_Terminal_Flag%TYPE  index by binary_integer;
     TYPE tab_rail_terminal_flag  is TABLE OF WSH_REGIONS.Rail_Terminal_Flag%TYPE  index by binary_integer;
     TYPE tab_longitude           is TABLE OF WSH_REGIONS.Longitude%TYPE           index by binary_integer;
     TYPE tab_latitude            is TABLE OF WSH_REGIONS.Latitude%TYPE            index by binary_integer;
     TYPE tab_timezone            is TABLE OF WSH_REGIONS.Timezone%TYPE            index by binary_integer;
     TYPE tab_continent           is TABLE OF WSH_REGIONS_TL.Continent%TYPE        index by binary_integer;
     TYPE tab_country             is TABLE OF WSH_REGIONS_TL.Country%TYPE          index by binary_integer;
     TYPE tab_country_region      is TABLE OF WSH_REGIONS_TL.Country_Region%TYPE   index by binary_integer;
     TYPE tab_state               is TABLE OF WSH_REGIONS_TL.State%TYPE            index by binary_integer;
     TYPE tab_city                is TABLE OF WSH_REGIONS_TL.City%TYPE             index by binary_integer;
     TYPE tab_alternate_name      is TABLE OF WSH_REGIONS_TL.Alternate_Name%TYPE   index by binary_integer;
     TYPE tab_county              is TABLE OF WSH_REGIONS_TL.County%TYPE           index by binary_integer;
     TYPE tab_postal_code_from    is TABLE OF WSH_REGIONS_TL.Postal_Code_From%TYPE index by binary_integer;
     TYPE tab_postal_code_to      is TABLE OF WSH_REGIONS_TL.Postal_Code_To%TYPE   index by binary_integer;
     TYPE tab_language            is TABLE OF WSH_REGIONS_TL.Language%TYPE         index by binary_integer;

  --
  -- PUBLIC VARIABLES
  --

  --
  --RECORD TO STORE DFF FIELD VALUES
  --

  TYPE REGION_DFF_REC IS RECORD(
  ATTRIBUTE_CATEGORY             VARCHAR2(150),
  ATTRIBUTE1		         VARCHAR2(150),
  ATTRIBUTE2                     VARCHAR2(150),
  ATTRIBUTE3                     VARCHAR2(150),
  ATTRIBUTE4                     VARCHAR2(150),
  ATTRIBUTE5                     VARCHAR2(150),
  ATTRIBUTE6                     VARCHAR2(150),
  ATTRIBUTE7                     VARCHAR2(150),
  ATTRIBUTE8                     VARCHAR2(150),
  ATTRIBUTE9                     VARCHAR2(150),
  ATTRIBUTE10                    VARCHAR2(150),
  ATTRIBUTE11                    VARCHAR2(150),
  ATTRIBUTE12                    VARCHAR2(150),
  ATTRIBUTE13                    VARCHAR2(150),
  ATTRIBUTE14                    VARCHAR2(150),
  ATTRIBUTE15                    VARCHAR2(150)
  );

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Procedure: Get_Parent_Region_Info
  --
  -- Purpose:   Retrieves all region info of the region passed in, and if it
  -- 		does not exist and p_parent_insert_flag = 'Y' , inserts into the database
  --
  --

  PROCEDURE Get_Parent_Region_Info(
	p_parent_region_type	IN	NUMBER,
	p_country_code		IN	VARCHAR2,
	p_country_region_code	IN	VARCHAR2,
	p_state_code		IN	VARCHAR2,
	p_city_code		IN	VARCHAR2,
	p_country		IN	VARCHAR2,
	p_country_region	IN	VARCHAR2,
	p_state			IN	VARCHAR2,
	p_city			IN	VARCHAR2,
	p_lang_code		IN	VARCHAR2,
	p_interface_flag	IN	VARCHAR2,
	p_user_id		IN	NUMBER,
	p_insert_parent_flag	IN	VARCHAR2,
	x_parent_region_info	OUT NOCOPY 	wsh_regions_search_pkg.region_rec,
   p_conc_request_flag     IN VARCHAR2 DEFAULT 'N');

  --
  -- Procedure: Add_Region
  --
  -- Purpose:   Inserts the region with appropriate data and returns the
  --  		region_id
  --

  PROCEDURE Add_Region (
	p_country_code 		IN 	VARCHAR2,
	p_country_region_code 	IN 	VARCHAR2,
	p_state_code 		IN 	VARCHAR2,
	p_city_code 		IN 	VARCHAR2,
	p_port_flag 		IN 	VARCHAR2,
	p_airport_flag 		IN 	VARCHAR2,
	p_road_terminal_flag 	IN 	VARCHAR2,
	p_rail_terminal_flag 	IN 	VARCHAR2,
	p_longitude 		IN 	NUMBER,
	p_latitude 		IN 	NUMBER,
	p_timezone 		IN 	VARCHAR2,
	p_continent 		IN 	VARCHAR2,
	p_country 		IN 	VARCHAR2,
	p_country_region 	IN 	VARCHAR2,
	p_state 		IN 	VARCHAR2,
	p_city 			IN 	VARCHAR2,
	p_alternate_name 	IN 	VARCHAR2,
	p_county 		IN 	VARCHAR2,
	p_postal_code_from	IN 	VARCHAR2,
	p_postal_code_to	IN 	VARCHAR2,
	p_lang_code		IN	VARCHAR2,
        p_region_type		IN	NUMBER,
	p_parent_region_id	IN	NUMBER,
	p_interface_flag	IN	VARCHAR2,
	p_tl_only_flag		IN	VARCHAR2,
	p_region_id		IN	NUMBER,
	p_region_dff		IN	REGION_DFF_REC DEFAULT NULL,
	x_region_id		OUT NOCOPY 	NUMBER,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL);

  --
  -- Procedure: Insert_Region
  --
  -- Purpose:   Inserts the region with appropriate data, and recursively inserts
  -- 		the parent region if it doesn't exist thru Get_Parent_Region_Id
  --

  PROCEDURE Insert_Region (
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_port_flag 			IN 	VARCHAR2,
	p_airport_flag 			IN 	VARCHAR2,
	p_road_terminal_flag 	        IN 	VARCHAR2,
	p_rail_terminal_flag 		IN 	VARCHAR2,
	p_longitude 			IN 	NUMBER,
	p_latitude 			IN 	NUMBER,
	p_timezone 			IN 	VARCHAR2,
	p_continent 			IN 	VARCHAR2,
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_alternate_name 		IN 	VARCHAR2,
	p_county 			IN 	VARCHAR2,
	p_postal_code_from 		IN 	VARCHAR2,
	p_postal_code_to 		IN 	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_interface_flag		IN	VARCHAR2,
	p_tl_only_flag			IN	VARCHAR2,
	p_region_id			IN	NUMBER,
	p_parent_region_id		IN	NUMBER,
	p_user_id			IN	NUMBER,
	p_insert_parent_flag		IN	VARCHAR2,
	p_region_dff			IN	REGION_DFF_REC DEFAULT NULL,
	x_region_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL,
        p_conc_request_flag     IN VARCHAR2 DEFAULT 'N');

  --
  -- Procedure: Update_Region
  --
  -- Purpose:   Updates a region with new information if the region exists,
  -- 		otherwise calls Insert_Region to insert the region.
  --

  PROCEDURE Update_Region (
	p_insert_type			IN	VARCHAR2,
	p_region_id			IN	NUMBER,
	p_parent_region_id		IN	NUMBER,
	p_continent 			IN 	VARCHAR2,
	p_country 			IN 	VARCHAR2,
	p_country_region 		IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_alternate_name 		IN 	VARCHAR2,
	p_county 			IN 	VARCHAR2,
	p_postal_code_from		IN 	VARCHAR2,
	p_postal_code_to		IN 	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_country_region_code 		IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_port_flag 			IN 	VARCHAR2,
	p_airport_flag 			IN 	VARCHAR2,
	p_road_terminal_flag 		IN 	VARCHAR2,
	p_rail_terminal_flag 		IN 	VARCHAR2,
	p_longitude 			IN 	NUMBER,
	p_latitude 			IN 	NUMBER,
	p_timezone 			IN 	VARCHAR2,
	p_interface_flag		IN	VARCHAR2,
	p_user_id			IN	NUMBER,
	p_insert_parent_flag		IN	VARCHAR2 DEFAULT 'N',
	p_region_dff			IN	REGION_DFF_REC DEFAULT NULL,
        x_region_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL,
   p_conc_request_flag     IN VARCHAR2 DEFAULT 'N');

  --
  -- Procedure: Delete_Region
  --
  -- Purpose:   Deletes a region (for interface use only)
  --

  PROCEDURE Delete_Region (
	p_region_id			IN	NUMBER,
	p_lang_code			IN	VARCHAR2,
	p_interface_flag		IN	VARCHAR2,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2);

--
--  Procedure:		Lock_Region
--  Parameters:		p_region_id - region_id for region to be locked
--			x_return_status - Status of procedure call
--  Description:	This procedure will lock a region record. It is
--			specifically designed for use by the form.
--

  PROCEDURE Lock_Region
	(p_region_id			IN	NUMBER,
	p_lang_code			IN	VARCHAR2,
	p_country 			IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from		IN 	VARCHAR2,
	p_postal_code_to		IN 	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_region_dff			IN	REGION_DFF_REC DEFAULT NULL,
	x_status			OUT NOCOPY 	NUMBER,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL);


--
--  Procedure:		Lock_Region_Interface
--  Parameters:		p_region_id - region_id for region to be locked
--				x_return_status - Status of procedure call
--  Description:		This procedure will lock a region record. It is
--				specifically designed for use by the form.
--

  PROCEDURE Lock_Region_Interface
	(p_region_id			IN	NUMBER,
	p_lang_code			IN	VARCHAR2,
	p_country 			IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from		IN 	VARCHAR2,
	p_postal_code_to		IN 	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	x_status			OUT NOCOPY 	NUMBER);

  --
  -- Procedure: Update_Zone (this is called from the Regions and Zones form)
  --
  -- Purpose:   Updates or inserts a new zone
  --

  PROCEDURE Update_Zone (
	p_insert_type			IN	VARCHAR2,
	p_zone_id			IN	NUMBER,
	p_zone_name 			IN 	VARCHAR2,
	p_zone_level			IN 	NUMBER,
	p_lang_code			IN 	VARCHAR2,
	p_user_id			IN	NUMBER,
	p_zone_dff			IN       REGION_DFF_REC DEFAULT NULL,
	x_zone_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2,
        p_deconsol_location_id          IN NUMBER DEFAULT NULL);

  --
  -- Procedure: Update_Zone
  --
  -- Purpose:   Updates or inserts a new zone
  --

  PROCEDURE Update_Zone (
	p_insert_type			IN	VARCHAR2,
	p_zone_id			IN	NUMBER,
	p_zone_name 			IN 	VARCHAR2,
	p_zone_level			IN 	NUMBER,
	p_zone_type			IN	NUMBER,
	p_lang_code			IN 	VARCHAR2,
	p_user_id			IN	NUMBER,
	p_zone_dff			IN      REGION_DFF_REC DEFAULT NULL,
	x_zone_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2,
        p_deconsol_location_id          IN NUMBER DEFAULT NULL);

--
--  Procedure:		Lock_Zone
--  Parameters:		p_zone_id - zone_id for zone to be locked
--			x_return_status - Status of procedure call
--  Description:	This procedure will lock a zone record. It is
--			specifically designed for use by the form.
--

  PROCEDURE Lock_Zone
	(p_zone_id			IN	NUMBER,
	p_lang_code			IN	VARCHAR2,
	p_zone_name 			IN 	VARCHAR2,
	p_zone_level 			IN 	VARCHAR2,
	x_status			OUT NOCOPY 	NUMBER);

  --
  -- Procedure: Update_Zone_Region
  --
  -- Purpose:   Updates or inserts a new zone region
  --		Has one more parameter P_ZONE_TYPE which indicates
  --		whether it's a normal zone(10) or a pricing zone(11)

  PROCEDURE Update_Zone_Region (
	p_insert_type			IN	VARCHAR2,
	p_zone_region_id		IN	NUMBER,
	p_zone_id			IN	NUMBER,
	p_region_id			IN	NUMBER,
	p_country 			IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from		IN 	VARCHAR2,
	p_postal_code_to		IN 	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_user_id			IN	NUMBER,
	p_zone_type			IN	VARCHAR2,
	x_zone_region_id		OUT NOCOPY 	NUMBER,
	x_region_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2);
  --

  -- Procedure: Update_Zone_Region
  --
  -- Purpose:   Updates or inserts a new zone region
  --		Call another Update_Zone_Region with default p_zone_type='10'

  PROCEDURE Update_Zone_Region (
	p_insert_type			IN	VARCHAR2,
	p_zone_region_id		IN	NUMBER,
	p_zone_id			IN	NUMBER,
	p_country 			IN 	VARCHAR2,
	p_state 			IN 	VARCHAR2,
	p_city 				IN 	VARCHAR2,
	p_postal_code_from		IN 	VARCHAR2,
	p_postal_code_to		IN 	VARCHAR2,
	p_lang_code			IN	VARCHAR2,
	p_country_code 			IN 	VARCHAR2,
	p_state_code 			IN 	VARCHAR2,
	p_city_code 			IN 	VARCHAR2,
	p_user_id			IN	NUMBER,
	x_zone_region_id		OUT NOCOPY 	NUMBER,
	x_region_id			OUT NOCOPY 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER,
	x_error_msg			OUT NOCOPY 	VARCHAR2);

--
--  Procedure:		Lock_Zone_Region
--  Parameters:		p_zone_region_id - zone_region_id for zone region to be locked
--			p_zone_id - zone id
--			p_region_id - zone component region id
--			x_return_status - Status of procedure call
--  Description:	This procedure will lock a zone component record. It is
--			specifically designed for use by the form.
--

  PROCEDURE Lock_Zone_Region
	(p_zone_region_id		IN	NUMBER,
	p_zone_id 			IN 	NUMBER,
	p_region_id 			IN 	NUMBER,
	x_status			OUT NOCOPY 	NUMBER);

  --
  -- Procedure: Load_Region
  --
  -- Purpose:   Loads the region information into interface tables
  -- 		without any validation.
  --

  PROCEDURE Load_Region (
	p_country_code 		IN 	VARCHAR2,
	p_country_region_code 	IN 	VARCHAR2,
	p_state_code 		IN 	VARCHAR2,
	p_city_code 		IN 	VARCHAR2,
	p_port_flag 		IN 	VARCHAR2,
	p_airport_flag 		IN 	VARCHAR2,
	p_road_terminal_flag 	IN 	VARCHAR2,
	p_rail_terminal_flag 	IN 	VARCHAR2,
	p_longitude 		IN 	NUMBER,
	p_latitude 		IN 	NUMBER,
	p_timezone 		IN 	VARCHAR2,
	p_continent 		IN 	VARCHAR2,
	p_country 		IN 	VARCHAR2,
	p_country_region 	IN 	VARCHAR2,
	p_state 		IN 	VARCHAR2,
	p_city 			IN 	VARCHAR2,
	p_alternate_name	IN 	VARCHAR2,
	p_county 		IN 	VARCHAR2,
	p_postal_code_from 	IN 	VARCHAR2,
	p_postal_code_to 	IN 	VARCHAR2,
	p_lang_code		IN	VARCHAR2,
        p_deconsol_location_id          IN  NUMBER DEFAULT NULL);

  --
  -- Procedure: Default_Regions
  --
  -- Purpose:   Copies regions from the interface tables to
  --		the real regions tables
  --

  PROCEDURE Default_Regions (
	x_status		OUT NOCOPY 	NUMBER,
	x_regions_processed	OUT NOCOPY 	NUMBER,
	x_error_msg_text 	OUT NOCOPY  	VARCHAR2);

  --
  -- Procedure: Default_Regions (for concurrent program usage)
  --
  -- Purpose:   Copies regions from the interface tables to
  --		the real regions tables
  --

  PROCEDURE Default_Regions (
	p_dummy1 	IN 	VARCHAR2,
	p_dummy2	IN	VARCHAR2);

  -- This method in only for the purpose of submitting a request from the form

  FUNCTION Load_All_Regions RETURN NUMBER;

  --
  -- Function: getZoneRegions
  --
  -- Purpose:  used by FTE_CAT_ZONE_LOV
  --            to show regions that belong to a zone
  --

  FUNCTION getZoneRegions (
        p_zoneId        IN NUMBER,
        p_lang	        IN VARCHAR2) return VARCHAR2;

/*----------------------------------------------------------*/
   /* Add_Language Procedure                                     */
    /*--------------------------------------------------------_-*/
procedure ADD_LANGUAGE;

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
            x_error_msg    OUT NOCOPY      VARCHAR2 );

  --
  -- PROCEDURE : Init_Global_Table
  --
  -- PURPOSE   : Populates the data in Global Temp tables(Wsh_Regions_Global
  --             and Wsh_Regions_Global_Data) fetched from Wsh_Regions and
  --             Wsh_Regions_Tl based on parameter p_populate_type.
  --
  PROCEDURE Init_global_table (
            p_country           IN  VARCHAR2,
            p_state             IN  VARCHAR2,
            p_city              IN  VARCHAR2,
            p_country_code      IN  VARCHAR2,
            p_state_code        IN  VARCHAR2,
            p_city_code         IN  VARCHAR2,
            p_country_flag      IN  VARCHAR2,
            p_state_flag        IN  VARCHAR2,
            p_city_flag         IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2 );

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
            x_return_status OUT NOCOPY VARCHAR2 );

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
            x_return_status OUT NOCOPY VARCHAR2 );

END WSH_REGIONS_PKG;


 

/
