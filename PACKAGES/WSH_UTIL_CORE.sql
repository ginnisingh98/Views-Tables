--------------------------------------------------------
--  DDL for Package WSH_UTIL_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_UTIL_CORE" AUTHID CURRENT_USER as
/* $Header: WSHUTCOS.pls 120.6.12010000.4 2009/12/03 10:34:53 mvudugul ship $ */

  --
  -- PACKAGE TYPES
  --

  --  Description:	Generic tab of numbers for passing _id information
  TYPE Id_Tab_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  --  Description:      Generic tab of varchar2 for passing column information
  TYPE Column_Tab_Type IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;

  --  Description:      Generic tab of date for passing column information
  TYPE Date_Tab_Type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  TYPE Loc_Info_rec  IS REcord (
            wsh_location_id             NUMBER
           ,source_location_id          NUMBER
           ,location_source_code        wsh_locations.location_source_code%TYPE
           ,location_code               wsh_locations.location_code%TYPE
           ,address1                    wsh_locations.address1%TYPE
           ,city                        wsh_locations.city%TYPE
           ,state                       wsh_locations.state%TYPE
           ,country                     wsh_locations.country%TYPE
           ,postal_code                 wsh_locations.postal_code%TYPE
           ,ui_location_code            wsh_locations.ui_location_code%TYPE
           ,hr_location_code            hr_locations_all.location_code%TYPE
  );
  TYPE Loc_Info_Tab IS TABLE OF Loc_Info_rec INDEX BY BINARY_INTEGER;

  -- Description:  record of number of errors, warning, unexpected errors, and successes
  TYPE MsgCountType is RECORD (
       e_count NUMBER,
       u_count NUMBER,
       w_count NUMBER,
       s_count NUMBER
       );

   TYPE key_value_rec_type IS RECORD(
      key  NUMBER,
      value NUMBER
   );

   TYPE key_char500_rec_type IS RECORD(
      key  NUMBER,
      value VARCHAR2(500)
   );

   TYPE key_boolean_rec_type IS RECORD(
      key  NUMBER,
      value BOOLEAN
   );

   TYPE key_value_tab_type IS TABLE OF key_value_rec_type INDEX BY BINARY_INTEGER;
   TYPE char500_tab_type IS TABLE OF key_char500_rec_type INDEX BY
                                                                BINARY_INTEGER;
   TYPE boolean_tab_type IS TABLE OF key_boolean_rec_type INDEX
                                                              BY BINARY_INTEGER;
   -- HVOP heali
   TYPE tbl_varchar IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
   TYPE RefCurType IS REF CURSOR;
   -- HVOP heali

   TYPE operating_unit_info_rec_type IS RECORD(
      org_id NUMBER,
      ledger_id NUMBER,  -- LE Uptake
      currency_code VARCHAR2(15)
      --currency_code gl_ledgers_public_v.currency_code%TYPE
   );

   -- cached global variables
   G_OPERATING_UNIT_INFO operating_unit_info_rec_type;
  --

  -- cached global variables for Bugfix 4070732
      G_START_OF_SESSION_API         VARCHAR2(1000);
      G_CALL_FTE_LOAD_TENDER_API     BOOLEAN;
      G_STOP_IDS_STOP_IDS_CACHE      WSH_UTIL_CORE.key_value_tab_type;
      G_STOP_IDS_STOP_IDS_EXT_CACHE  WSH_UTIL_CORE.key_value_tab_type;
  --

  --
  -- PACKAGE CONSTANTS
  --

  -- Description:	Constants used to allow the user to differentiate
  --			between errors, warning and success
  G_RET_STS_SUCCESS	CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_WARNING	CONSTANT VARCHAR2(1) := 'W';
  G_RET_STS_ERROR	CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  --
  --
  -- Description:       This exception can be used to raise when the return
  --                    is a warning and if the api needs to exit out
  --                    immediately.
  --
  G_EXC_WARNING         EXCEPTION;
  --
  C_HASH_BASE CONSTANT NUMBER := 1;
  C_HASH_SIZE CONSTANT NUMBER := 33554432 ; -- power(2, 25)
  C_INDEX_LIMIT CONSTANT NUMBER := 2147483648; -- power(2,31)

  -- OTM R12
  G_GC3_IS_INSTALLED VARCHAR2(1) := NULL;
  -- End of OTM R12

  --
  --
  -- J-IB-NPARIKH-{

  C_NULL_SF_LOCN_ID           CONSTANT NUMBER       := -1;
  C_NOTNULL_SF_LOCN_ID        CONSTANT NUMBER       := -2;
  C_SPLIT_DLVY_SUFFIX         CONSTANT VARCHAR2(30) := '_SPLIT_DLVY';
  C_IB_ASN_PREFIX             CONSTANT VARCHAR2(30) := 'WSH_IB_ASN';
  C_IB_RECEIPT_PREFIX         CONSTANT VARCHAR2(30) := 'WSH_IB_RECEIPT';
  C_IB_PO_PREFIX              CONSTANT VARCHAR2(30) := 'WSH_IB_PO';

  e_not_allowed               EXCEPTION;
  e_not_allowed_warning       EXCEPTION;

  -- J-IB-NPARIKH-}


  C_MAX_DECIMAL_DIGITS           CONSTANT NUMBER       := 38;
  C_MAX_DECIMAL_DIGITS_INV       CONSTANT NUMBER       := 5;
  C_MAX_REAL_DIGITS              CONSTANT NUMBER       := 10;

-- HW OPMCONV - No need for OPM specific precision
--C_MAX_DECIMAL_DIGITS_OPM       CONSTANT NUMBER       := 9;

  --
  -- FUNCTION:		Get_Location_Description
  -- Purpose:		Function gives a description of the location
  --			based on the location_id
  -- Arguments:		p_location_id - Location identifier
  --			p_format - Format for description
  -- Return Values:     Returns a description of the location in VARCHAR2
  -- Notes:		p_format supports the following:
  --

  FUNCTION Get_Location_Description (
		p_location_id	IN	NUMBER,
		p_format	IN	VARCHAR2
		) RETURN VARCHAR2;


 --
 -- PROCEDURE: Site_Code_to_Site_id
 -- PURPOSE  : Maps site_code to site_id
 -- ARGUMENTS : p_site_code - site code that needs to be mapped
 --             p_site_id - site id for the code
 --             x_return_status - WSH_UTIL_CORE.G_RET_STS_SUCCESS or NOT
 --

  PROCEDURE Site_Code_to_Site_id(p_site_code            IN      VARCHAR2,
                                 p_site_id              OUT NOCOPY      NUMBER,
                                 x_return_status        OUT NOCOPY      VARCHAR2);

  --
  -- PROCEDURE:		Get_Location_Id
  -- Purpose:		Convert Organization_id or ship_to_site_id to
  --			a location_id
  -- Arguments:		p_mode - 'CUSTOMER SITE', 'VENDOR SITE' or 'ORG'
  --			p_source_id - organization_id or site_id to convert
  --				      based on p_mode
  --			x_location_id - Converted to location_id
  --			x_api_status -	FND_API.G_RET_STS_SUCCESS
  --					FND_API.G_RET_STS_ERROR
  --			If Error message can be retrieved using FND_MESSAGE.GET
  -- Description:	Gets location information for a particular inventory
  --			organization using hr_locations view
  --

  PROCEDURE Get_Location_Id (
		p_mode		IN	VARCHAR2,
		p_source_id	IN	NUMBER,
		x_location_id	OUT NOCOPY 	NUMBER,
		x_api_status	OUT NOCOPY 	VARCHAR2,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		);

  --
  -- PROCEDURE:		get_master_from_org
  -- PURPOSE:		Obtain master organization id for an organization_id
  -- Arguments:		p_org_id - organization_id
  --			x_master_org_id - Master organization id for input organization_id
  --			x_return_status -
  --                    WSH_UTIL_CORE.G_RET_STS_SUCCESS
  --                    WSH_UTIL_CORE.G_RET_STS_ERROR
  -- Notes:		Throws exception when fails
  --

  PROCEDURE get_master_from_org(
              p_org_id         IN  NUMBER,
              x_master_org_id  OUT NOCOPY NUMBER,
              x_return_status  OUT NOCOPY VARCHAR2);

  --
  -- FUNCTION:		Org_To_Location
  -- PURPOSE:		Convert organization_id to location_id
  -- Arguments:		p_org_id - organization_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Org_To_Location (
		p_org_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT FALSE
		) RETURN NUMBER;

  --
  -- FUNCTION:		Cust_Site_To_Location
  -- PURPOSE:		Convert customer site_id to location_id
  -- Arguments:		p_site_id - site_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Cust_Site_To_Location (
		p_site_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		) RETURN NUMBER;

  --
  -- FUNCTION:		Vendor_Site_To_Location
  -- PURPOSE:		Convert Vendor site_id to location_id
  -- Arguments:		p_site_id - site_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Vendor_Site_To_Location (
		p_site_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		) RETURN NUMBER;

  --
  -- FUNCTION:		Ship_Method_To_Freight
  -- PURPOSE:		Convert Ship_Method_Code to Freight_Code
  -- Arguments:	p_ship_method_code, p_organization_id
  -- Return Values:	Freight_Code
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Ship_Method_To_Freight (
		p_ship_method_code	IN	VARCHAR2,
		p_organization_id   IN   NUMBER
		) RETURN VARCHAR2;

  --  PRAGMA RESTRICT_REFERENCES (Ship_Method_To_Freight, WNDS);

  --
  -- This set of functions and procedures can be used by the concurrent
  -- programs to print messages to the log file. The following are
  -- supported:
  --


  --
  -- Procedure:		Enable_Concurrent_Log_Print
  -- Purpose:		Enable printing of log messages to concurrent
  --			program log files
  -- Arguments:		None
  --

  PROCEDURE Enable_Concurrent_Log_Print;

  --
  -- Procedure:	Set_Log_Level
  -- Purpose:       Set Appropriate log level to print
  --                debug messages to the concurrent program log file
  -- Arguments:	p_log_level
  --

  PROCEDURE Set_Log_Level(
	p_log_level  IN  NUMBER
  );



  --
  -- Procedure:		Print
  -- Purpose:		Prints a line of message text to the log file
  --			and does not insert a new line at the end
  --			program log files
  -- Arguments:		p_msg - message text to print
  --

  PROCEDURE Print(
	p_msg	IN	VARCHAR2
  );

  --
  -- Procedure:		Println
  -- Purpose:		Prints a line of message text to the log file
  --			and inserts a new line at the end
  --			program log files
  -- Arguments:		p_msg - message text to print
  --

  PROCEDURE Println(
	p_msg	IN	VARCHAR2
  );

  --
  -- Procedure:		Println
  -- Purpose:		Prints a new line character to the log file
  --			program log files
  -- Arguments:		None
  --

  PROCEDURE Println;



  --
  -- Procedure:          PrintMsg
  -- Purpose:       Prints a line of message text to the log file
  --           and inserts a new line at the end
  --           program log files irrespective of the debug level
  --           Should be used for the debug messages which need to
  --           printed always
  -- Arguments:          p_msg - message text to print
  --

  PROCEDURE PrintMsg(
	p_msg     IN   VARCHAR2
  );

  --
  -- Procedure:          PrintMsg
  -- Purpose:       Prints a new line character to the log file
  --           program log files irrespective of the Debug Level
  -- Arguments:          None
  --

  PROCEDURE PrintMsg;

  --
  -- Procedure:		PrintDateTime
  -- Purpose:		Prints system date and time to the log file
  -- Arguments:		None
  --

  PROCEDURE PrintDateTime;

  --
  -- Name
  --   Gen_Check_Unique
  -- Purpose
  --   Checks for duplicates in database
  -- Arguments
  --   query_text             query to execute to test for uniqueness
  --   prod_name         	product name to send message for
  --   msg_name               message to print if duplicate found
  --
  -- Notes
  --   uses DBMS_SQL package

		 PROCEDURE Gen_Check_Unique
                            (p_table_name IN VARCHAR2,
                             p_pkey1 IN VARCHAR2 DEFAULT NULL,
                             p_pkey1_value IN VARCHAR2 DEFAULT NULL,
                             p_is_1_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey2 IN VARCHAR2 DEFAULT NULL,
                             p_pkey2_value IN VARCHAR2 DEFAULT NULL,
                             p_is_2_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey3 IN VARCHAR2 DEFAULT NULL,
                             p_pkey3_value IN VARCHAR2 DEFAULT NULL,
                             p_is_3_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey4 IN VARCHAR2 DEFAULT NULL,
                             p_pkey4_value IN VARCHAR2 DEFAULT NULL,
                             p_is_4_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey5 IN VARCHAR2 DEFAULT NULL,
                             p_pkey5_value IN VARCHAR2 DEFAULT NULL,
                             p_is_5_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey6 IN VARCHAR2 DEFAULT NULL,
                             p_pkey6_value IN VARCHAR2 DEFAULT NULL,
                             p_is_6_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey7 IN VARCHAR2 DEFAULT NULL,
                             p_pkey7_value IN VARCHAR2 DEFAULT NULL,
                             p_is_7_char  IN VARCHAR2 DEFAULT NULL,
                             p_pkey8 IN VARCHAR2 DEFAULT NULL,
                             p_pkey8_value IN VARCHAR2 DEFAULT NULL,
                             p_is_8_char  IN VARCHAR2 DEFAULT NULL,
                             p_row_id IN VARCHAR2 DEFAULT NULL,
                             p_prod_name IN VARCHAR2,
                             p_msg_name IN VARCHAR2);


PROCEDURE GET_ACTIVE_DATE(P_TABLE_NAME  IN       varchar2,
                          P_COLUMN_NAME  IN        varchar2,
                          P_ROW_ID       IN       varchar2,
                          X_DATE_FETCHED OUT NOCOPY DATE);

  PROCEDURE Get_Active_Date(	query_text       IN   VARCHAR2,
					    	date_fetched    OUT NOCOPY   DATE);

  --
  -- Name
  --   Add_Message
  -- Purpose
  --   Adds a message to the FND_MSG_PUB table of messages. Also,
  --   concatenates a message type of 'Warning:', 'Error:' or 'Unexpected Error:'
  --   to the translated message and sets it back on the stack.
  -- Arguments
  --   p_message_type   -  values are
  --					'S'	- if successful
  --					'W'	- if warning
  --					'E'  - if error
  --					'U'  - if unexpected error
  --

-- Overloaded the procedure to set message and tokens
-- Harmonization Project I **heali
  PROCEDURE Add_Message (
	p_message_type IN     VARCHAR2,
	p_module_name IN      VARCHAR2,
        p_error_name  IN      VARCHAR2,
        p_token1      IN      VARCHAR2 DEFAULT NULL,
        p_value1      IN      VARCHAR2 DEFAULT NULL,
        p_token2      IN      VARCHAR2 DEFAULT NULL,
        p_value2      IN      VARCHAR2 DEFAULT NULL,
        p_token3      IN      VARCHAR2 DEFAULT NULL,
        p_value3      IN      VARCHAR2 DEFAULT NULL,
        p_token4      IN      VARCHAR2 DEFAULT NULL,
        p_value4      IN      VARCHAR2 DEFAULT NULL,
        p_token5      IN      VARCHAR2 DEFAULT NULL,
        p_value5      IN      VARCHAR2 DEFAULT NULL,
        p_token6      IN      VARCHAR2 DEFAULT NULL,
        p_value6      IN      VARCHAR2 DEFAULT NULL,
        p_token7      IN      VARCHAR2 DEFAULT NULL,
        p_value7      IN      VARCHAR2 DEFAULT NULL,
        p_token8      IN      VARCHAR2 DEFAULT NULL,
        p_value8      IN      VARCHAR2 DEFAULT NULL);
-- Harmonization Project I **heali

-- Overloaded the procedure to log messages to debug file as well.
  PROCEDURE Add_Message ( p_message_type IN VARCHAR2,
		          p_module_name IN VARCHAR2
			 );
  PROCEDURE Add_Message ( p_message_type IN VARCHAR2 := NULL
			 );


  --
  -- Name
  --   Add_Summary_Message
  -- Purpose
  --   Adds a summary message.
  --
  -- Arguments
  --   p_message	  Summary message, which should have tokens for
  --			    successes, warnings, and errors.
  --   p_total		  Total number of entities processed.
  --   p_warnings	  Number of entities with warnings.
  --   p_errors		  Number of entities with errors.
  --   p_return_status    Return status derived from warnings and errors.
  --

-- Overloaded the procedure to log messages to debug file as well.
  PROCEDURE Add_Summary_Message(
	p_message	      fnd_new_messages.message_name%type,
	p_total		      number,
	p_warnings	      number,
	p_errors	      number,
	p_return_status	      out NOCOPY  varchar2,
	p_module_name         in  varchar2
	);
  PROCEDURE Add_Summary_Message(
	p_message	      fnd_new_messages.message_name%type,
	p_total		      number,
	p_warnings	      number,
	p_errors	      number,
	p_return_status	      out NOCOPY  varchar2
	);


  --
  -- Name
  --   Get_Messages
  -- Purpose
  --   Gets messages from the FND_MSG_PUB table, in the form of a
  --   concatenated string with separators.
  -- Arguments
  --   p_init_msg_list  - initializes the FND_MSG_PUB table
  --   x_summary        - summary message (topmost)
  --   x_details        - concatenated messages (excluding summary)
  --   x_count          - total messages (including summary)
  --

  PROCEDURE Get_Messages ( p_init_msg_list IN VARCHAR2,
				  	x_summary OUT NOCOPY  VARCHAR2,
					  x_details  OUT NOCOPY  VARCHAR2,
					  x_count   OUT NOCOPY  NUMBER);

  --
  -- Name
  --   Default_Handler
  -- Purpose
  --   Sets message for an unexpected error in a procedure
  -- Arguments
  --   p_routine_name   - name of package.procedure where failure occurs
  --

-- Overloaded the procedure to log messages to debug file as well.
  PROCEDURE Default_Handler ( p_routine_name IN VARCHAR2,
		              p_module_name IN VARCHAR2
			     );
  PROCEDURE Default_Handler ( p_routine_name IN VARCHAR2
			     );

  --
  -- Name
  --   Clear_FND_Messages
  -- Purpose
  --   Clears the server-side FND message stack.
  -- Arguments
  --   None.
  --

  PROCEDURE Clear_FND_Messages;

--
--  Function:		Get_Org_Name
--  Parameters:	p_organization_id
--  Description:	This procedure will return Organization Name for a Org Id
--

  FUNCTION Get_Org_Name
		(p_organization_id		IN	NUMBER
		 ) RETURN VARCHAR2;


--
--  Function:		Get_Item_Name
--  Parameters:	p_item_id, p_organization_id, p_flex_code, p_struct_num
--  Description:	This procedure will return Item Name for a Item Id
--
-- LSP PROJECT : Added new parameter p_remove_client_code which specify
--          whether client code value from item name should be removed or not.
--          Parameter value 'Y' means remove and 'N' means not.
--          This parameter value is being considered only when the deployment mode
--          is LSP.
--          This parameter is required as the this API is being called from
--          many reports out of which some needs client code some or not.

  FUNCTION Get_Item_Name
		(p_item_id		IN	NUMBER,
		 p_organization_id	IN 	NUMBER,
		 p_flex_code        IN   VARCHAR2 := 'MSTK',
		 p_struct_num       IN   NUMBER := 101,
                 p_remove_client_code IN VARCHAR2 DEFAULT 'N'
		 ) RETURN VARCHAR2;


-- Name  generic_flex_name
-- Purpose    converts entity_id into its name
-- Arguments
--      entity_id
--      warehouse_id
--      app_name  (short app name; e.g. 'INV')
--      k_flex_code    (key flexfield code; e.g., 'MSTK')
--      struct_num     (structure number; e.g., 101)
-- Assumption  The parameters are valid.
--       RETURN VARCHAR2    if name not found, '?' will be returned.


FUNCTION generic_flex_name
  (entity_id IN NUMBER,
   warehouse_id   IN NUMBER,
   app_name  IN VARCHAR2,
   k_flex_code    IN VARCHAR2,
   struct_num     IN NUMBER)
  RETURN VARCHAR2;



--
-- Procedure:	Delete
--
-- Parameters:  p_type - type of entities to delete
--		p_del_rows   - ids to be deleted
--		  When returned, id is negated if the delete failed
--		x_return_status - status of procedure call
--
-- Description: Deletes multiple entities
--

  PROCEDURE Delete(
	p_type			    wsh_saved_queries_vl.entity_type%type,
	p_rows		  IN OUT NOCOPY     wsh_util_core.id_tab_type,
        p_caller          IN VARCHAR2  DEFAULT NULL,
	x_return_status	  OUT NOCOPY 	    VARCHAR2);


  -- Name	 city_region_postal
  -- Purpose	 concatenates the three fields for the reports
  -- Input Arguments
  --             p_city
  --             p_region (state)
  --             p_postal_code (zip)
  -- RETURN VARCHAR2
  --

  FUNCTION  city_region_postal(
               p_city        in varchar2,
               p_region      in varchar2,
               p_postal_code in varchar2)
  RETURN VARCHAR2;

  -- Name	 derive_shipment_priority
  -- Purpose	 returns the shipment priority code
  -- Input Arguments
  --             p_delivery_id
  -- RETURN VARCHAR2
  --

  FUNCTION  derive_shipment_priority(p_delivery_id IN NUMBER)
  RETURN VARCHAR2;


  --     changes / additional function added due to Bug: 2120604
  -- Name	     Get_Ledger_id_func_currency
  -- Purpose	 Gets the Ledger id, by passing the Org id
  --             And also get the Functional Currency corresponding to this Ledger_id
  -- Input Arguments
  --             p_org_id   (Org Id)
  --
  PROCEDURE Get_Ledger_id_Func_Currency(
               p_org_id          IN  NUMBER,
               x_ledger_id          OUT NOCOPY      NUMBER ,
               x_func_currency   OUT NOCOPY      VARCHAR2 ,
               x_return_status   OUT NOCOPY      VARCHAR2);


--
-- Name        Print_Label
-- Purpose     This procedure takes a table of delivery ids or
--             trip stop ids and print label for these deliveries
--
-- Input Arguments
--   p_delivery
--
  PROCEDURE Print_Label(
               p_delivery_ids    IN     WSH_UTIL_CORE.Id_Tab_Type,
               p_stop_ids        IN     WSH_UTIL_CORE.Id_Tab_Type,
               x_return_status   OUT NOCOPY     VARCHAR2);

/*  H integration: Pricing integration csun
*/
--
-- Name		FTE_Is_Installed
-- Purpose	 This procedure check whether FTE is installed.
--			 It returns 'Y' if FTE is installed, 'N' if FTE
--			 is not installed
--
-- Input Arguments
--	   No input argument
--
  FUNCTION FTE_Is_Installed  return VARCHAR2;

--
-- Name		TP_Is_Installed
-- Purpose	 This procedure check whether TP is installed.
--			 It returns 'Y' if TP is installed, 'N' if TP
--			 is not installed
--
-- Input Arguments
--	   No input argument
--
  FUNCTION TP_Is_Installed RETURN VARCHAR2;

--
-- Name		Get_Trip_Name
-- Purpose	 This procedure gets the trip name from a delivery leg id
-- Input Arguments
--	   delivery_leg_id
--
   PROCEDURE Get_Trip_Name_by_Leg(
               p_delivery_leg_id    IN     NUMBER,
               x_trip_name          OUT NOCOPY     VARCHAR2,
               x_reprice_required   OUT NOCOPY     VARCHAR2,
               x_return_status   OUT NOCOPY     VARCHAR2);

--Harmonization Project I
  PROCEDURE  api_post_call(
               p_return_status IN VARCHAR2,
               x_num_warnings  IN OUT NOCOPY NUMBER,
               x_num_errors    IN OUT NOCOPY NUMBER,
               p_msg_data      IN  VARCHAR2 DEFAULT NULL,
               p_raise_error_flag IN BOOLEAN DEFAULT TRUE
               );

--Harmonization Project I **heali
PROCEDURE api_post_call(
        p_return_status IN VARCHAR2,
        x_num_warnings  IN OUT NOCOPY NUMBER,
        x_num_errors    IN OUT NOCOPY NUMBER,
        p_module_name   IN VARCHAR2,
        p_msg_data      IN VARCHAR2,
        p_token1        IN VARCHAR2 DEFAULT NULL,
        p_value1        IN VARCHAR2 DEFAULT NULL,
        p_token2        IN VARCHAR2 DEFAULT NULL,
        p_value2        IN VARCHAR2 DEFAULT NULL,
        p_token3        IN VARCHAR2 DEFAULT NULL,
        p_value3        IN VARCHAR2 DEFAULT NULL,
        p_token4        IN VARCHAR2 DEFAULT NULL,
        p_value4        IN VARCHAR2 DEFAULT NULL,
        p_token5        IN VARCHAR2 DEFAULT NULL,
        p_value5        IN VARCHAR2 DEFAULT NULL,
        p_token6        IN VARCHAR2 DEFAULT NULL,
        p_value6        IN VARCHAR2 DEFAULT NULL,
        p_token7        IN VARCHAR2 DEFAULT NULL,
        p_value7        IN VARCHAR2 DEFAULT NULL,
        p_token8        IN VARCHAR2 DEFAULT NULL,
        p_value8        IN VARCHAR2 DEFAULT NULL,
        p_raise_error_flag IN BOOLEAN DEFAULT TRUE );
--Harmonization Project I **heali

  FUNCTION get_operatingUnit_id ( p_delivery_id      IN   NUMBER )
  RETURN  NUMBER;

  --
  -- Name        Store_Msg_In_Table
  -- Purpose     This procedure takes a table of messages and push
  --             them to the FND stack and also returns number of errors,
  --             warns, unexpected errors, and successes.
  --
  -- Input Arguments
  --   p_store_flag
  --
  PROCEDURE Store_Msg_In_Table (
               p_store_flag      IN     Boolean,
               x_msg_rec_count   OUT NOCOPY     WSH_UTIL_CORE.MsgCountType,
               x_return_status   OUT NOCOPY     VARCHAR2);


--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing integer values)
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================

  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY key_value_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY key_value_tab_type,
                             p_value IN OUT NOCOPY NUMBER,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           ) ;


--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing varchar2(500))
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================

  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY char500_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY char500_tab_type,
                             p_value IN OUT NOCOPY VARCHAR2,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           ) ;

--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing boolean)
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================

  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY boolean_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY boolean_tab_type,
                             p_value IN OUT NOCOPY boolean,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           ) ;


--========================================================================
-- PROCEDURE : OpenDynamicCursor
--
-- PARAMETERS: p_cursor		Ref cursor to the SQL query
--	       p_statement	SQL statement to be executed
--	       p_dynamic_tab    Table containing bind variables.
--
--========================================================================
  PROCEDURE OpenDynamicCursor(
       p_cursor         IN OUT NOCOPY RefCurType,
       p_statement      IN VARCHAR2,
       p_dynamic_tab    IN tbl_varchar);



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
FUNCTION Get_Lookup_Meaning(p_lookup_type 	IN 	VARCHAR2,
			    P_lookup_code	IN	VARCHAR2)
return VARCHAR2;


-- Start of comments
-- API name : Get_Action_Meaning
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to get meaning for action code and type.
-- Parameters :
-- IN:
--        p_entity                    IN      Entity DLVB/DLVY/STOP/TRIP.
--        P_action_code               IN      Action Code.
-- OUT:
--        Api return meaning for lookup code and type.
-- End of comments

FUNCTION Get_Action_Meaning(p_entity            IN      VARCHAR2,
                            p_action_code       IN      VARCHAR2)
return VARCHAR2;


--Sbakshi
--
-- Procedure : Get_string_from_idtab
-- Purpose   : Used to convert a PL/SQL table of numbers to comma-separated list of form '1,2,3,4'
--

PROCEDURE get_string_from_idtab(
	p_id_tab	 IN 	WSH_UTIL_CORE.ID_TAB_TYPE,
	x_string	 OUT 	NOCOPY  VARCHAR2,
	x_return_status  OUT	NOCOPY  VARCHAR2);

--
--Procedure    : Get_idtab_from_string
--Purpose      : Is used to Convert a comma-separated list of Ids of form '1,2,3,4'to
--		     a PL/SQL table numbers;

PROCEDURE get_idtab_from_string(
	p_string	 IN	VARCHAR2,
	x_id_tab	 OUT	NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
	x_return_status  OUT	NOCOPY  VARCHAR2);

-- Bug#3947506: Adding a new procedure Get_Entity_name
--========================================================================
-- PROCEDURE : Get_entity_name
--
-- COMMENT   : This procedure will return the entity name for Trip, Stop,
--             Delivery. For Line, Line_id will be returned.
--========================================================================

  PROCEDURE Get_Entity_name
        (p_in_entity_id         in  NUMBER,
         p_in_entity_name       in  VARCHAR2,
         p_out_entity_id        out NOCOPY VARCHAR2,
         p_out_entity_name      out NOCOPY VARCHAR2,
         p_return_status        out NOCOPY VARCHAR2);


--Bug 4070732 : The following two prcoedures added for this Bugfix

--========================================================================
-- PROCEDURE : Process_stops_for_load_tender
--
-- COMMENT   : This procedure will call the WSH_TRIPS_ACTIONS.Fte_Load_Tender
--             for the Stop ID's present in the global cache table
--             G_STOP_IDS_STOP_IDS_CACHE and G_STOP_IDS_STOP_IDS_EXT_CACHE.
--             Once processed, this will call the API Reset_stops_for_load_tender
--             to reset the global variables.
--========================================================================


  PROCEDURE Process_stops_for_load_tender(p_reset_flags IN BOOLEAN,x_return_status OUT NOCOPY VARCHAR2);


--========================================================================
-- PROCEDURE : Reset_stops_for_load_tender
--
-- COMMENT   : This procedure will delete the contents of the gloabal cache
--             tables  G_STOP_IDS_STOP_IDS_CACHE and G_STOP_IDS_STOP_IDS_EXT_CACHE
--             and also set the Boolean Global Variable G_CALL_FTE_LOAD_TENDER_API
--             to TRUE.
--========================================================================

  PROCEDURE Reset_stops_for_load_tender (p_reset_flags IN BOOLEAN,x_return_status OUT NOCOPY VARCHAR2);


/*======================================================================
FUNCTION : ValidateActualDepartureDate

COMMENT : This function is called from
          - WSHASCSRS concurrent program
          - WSHPSRS concurrent program
          - WSHPRREL library

          This function checks whether users can enter a future date for
          the Actual Departure Date parameter/field.
          This function returns
          - FALSE : if Global parameter Allow Future Ship Date = 'N'
                and Ship Confirm Rule indicates Set Delivery Intransit
                and Actual Departure Date is > SYSDATE
          - TRUE : under all other conditions

HISTORY : rlanka    03/01/2005    Created
=======================================================================*/
FUNCTION ValidateActualDepartureDate(p_ship_confirm_rule_id IN NUMBER,
                                     p_actual_departure_date IN DATE)
RETURN BOOLEAN;


/*======================================================================
FUNCTION : GetShipConfirmRule

COMMENT : This function is called from the
          - WSHPSRS concurrent program

          This function is used to obtain the Ship Confirm Rule tied
          to a particular picking rule.  This function is used to
          populate a hidden parameter "Ship Confirm Rule ID" in WSHPSRS
          concurrent program.

HISTORY : rlanka    03/01/2005    Created
=======================================================================*/
FUNCTION GetShipConfirmRule(p_picking_rule_id IN NUMBER) RETURN NUMBER;

--
-- Name		WMS_Is_Installed
-- Purpose	 This procedure check whether WMS is installed.
--			 It returns 'Y' if WMS is installed, 'N' if WMS
--			 is not installed
--
-- Input Arguments
--	   No input argument
--
  FUNCTION WMS_Is_Installed  return VARCHAR2;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_customer_from_loc      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_customer_id_tab          List of customers at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the customer id of the customer
-- having a location at input wsh location id
--========================================================================

PROCEDURE get_customer_from_loc(
              p_location_id    IN  NUMBER,
              x_customer_id_tab     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
              x_return_status  OUT NOCOPY  VARCHAR2);

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_org_from_location      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_organization_tab         List of Organizations for the input location
--             x_return_status            Return status
-- COMMENT   :
--             Returns table of organizations for location.
--========================================================================
PROCEDURE get_org_from_location(
         p_location_id         IN  NUMBER,
         x_organization_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
         x_return_status       OUT NOCOPY  VARCHAR2);
--***************************************************************************--
  --========================================================================
  -- PROCEDURE : Get_Delivery_Status    PRIVATE
  --
  -- PARAMETERS:
  --     p_entity_type         either DELIVERY/DELIVERY DETAIL/LPN
  --     p_entity_id           either delivery_id/delivery_detail_id/lpn_id
  --     x_status_code         Status of delivery for the entity_type and
  --                           entity id passed
  --     x_return_status       return status
  --========================================================================
  -- API added for bug 4632726
  PROCEDURE Get_Delivery_Status (
            p_entity_type    IN   VARCHAR2,
            p_entity_id      IN   NUMBER,
            x_status_code    OUT NOCOPY VARCHAR2,
            x_return_status  OUT NOCOPY VARCHAR2 );

-- OTM R12
--***************************************************************************--
--
-- Name         Get_Otm_Install_Profile_Value
-- Purpose      This function returns the value of
--                            profile WSH_OTM_INSTALLED
--              It returns 'P' if OTM is integrated for Inbound Purchasing
--                         'O' if OTM is integrated for Outbound Sales Order
--                         'Y' if OTM is integrated for both of the above
--                         'N' if OTM is integrated for non of the above
--                             or if the profile value is NULL
--
-- Input Arguments
--              No input argument
--
--***************************************************************************--

  FUNCTION Get_Otm_Install_Profile_Value return VARCHAR2;

--***************************************************************************--
--
-- Name         GC3_Is_Installed
-- Purpose      This function returns whether OTM is integrated for
--                            Outbound Sales Order flow by looking at the
--                            value of profile WSH_OTM_INSTALLED
--              It returns 'Y' if OTM is integrated for Outbound Sales Order
--                         'N' otherwise
--
-- Input Arguments
--              No input argument
--
--***************************************************************************--

  FUNCTION GC3_Is_Installed  return VARCHAR2;

--
  --========================================================================
  -- PROCEDURE : GET_CURRENCY_CONVERSION_TYPE
  --
  --             API added for R12 Glog Integration Currency Conversion ECO
  --
  -- PURPOSE :   To get the value for profile option WSH_OTM_CURR_CONV_TYPE
  --             (WSH: Currency Conversion Type for OTM)
  --             It returns the cached value if it is avaiable, otherwise
  --             fnd_profile.value api is called to get the profile value
  -- PARAMETERS:
  --     x_curr_conv_type      currency conversion type
  --     x_return_status       return status
  --========================================================================
  PROCEDURE Get_Currency_Conversion_Type (
            x_curr_conv_type OUT NOCOPY VARCHAR2,
            x_return_status  OUT NOCOPY VARCHAR2 );

/*
--========================================================================
-- FUNCTION : get_trip_organization
--
-- PARAMETERS: p_trip_id                  Input Trip Id
--
-- COMMENT   :
--      This procedure returns back organiation id that is associated with the trip.
--              Steps
--              For Outbound and Mixed trip's see if there is a organization at the location of first stop
--              For inbound see if there is a organization at the location of the last stop.
--              If there are no organizations associated then get the organization id of the delivery with
--              least delivery id
--========================================================================
*/

FUNCTION GET_TRIP_ORGANIZATION_ID(p_trip_id                  NUMBER) RETURN NUMBER;

/*
--========================================================================
-- PROCEDURE : GET_FIRST_LAST_STOP_INFO
--
-- PARAMETERS: p_trip_id                  Input Trip id
--             x_arrival_date             Last Stop's Arrival Date
--             x_departure_date           First Stop's Departure Date
--             x_first_stop_id            First Stop Id
--             x_last_stop_id             Last Stop Id
--             x_first_stop_loc_id        First Stop Location Id
--             x_last_stop_loc_id         Last Stop Location Id
--             x_return_status            Return status
-- COMMENT   :
--             Returns the first and the last Stop's information of a trip
--========================================================================
*/

PROCEDURE GET_FIRST_LAST_STOP_INFO(x_return_status          OUT NOCOPY  VARCHAR2,
            x_arrival_date              OUT NOCOPY              DATE,
            x_departure_date        OUT NOCOPY          DATE,
            x_first_stop_id             OUT NOCOPY              NUMBER,
            x_last_stop_id              OUT NOCOPY              NUMBER,
            x_first_stop_loc_id     OUT NOCOPY          NUMBER,
            x_last_stop_loc_id      OUT NOCOPY          NUMBER,
            p_trip_id                                   NUMBER);


-- End of OTM R12

-- Standalone Project - Start
--
--=============================================================================
-- PUBLIC FUNCTION :
--       Get_Operating_Unit
--
-- PARAMETERS:
--       p_organization_id => Organization Id
--
-- COMMENT:
--       Function to return Operating Unit corresponding to organization passed.
-- HISTORY :
--       ueshanka    10/Feb/2009    Created
--=============================================================================
--
FUNCTION Get_Operating_Unit( p_organization_id NUMBER) RETURN NUMBER;
--
-- Standalone Project - End

--Added for bug 9011125
--========================================================================
-- PROCEDURE : SET_FND_PROFILE
--
-- PARAMETERS: p_name   - Name of the profile to be set.
--             p_value  - Value for the profile to be set.
-- COMMENT   :
--             This will set the FND_PROFILE for the DB cache.
--========================================================================

PROCEDURE SET_FND_PROFILE(p_name IN VARCHAR2,
                          p_value IN VARCHAR2);

END WSH_UTIL_CORE;

/
