--------------------------------------------------------
--  DDL for Package PVX_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvutls.pls 120.4 2006/01/25 15:43:14 ktsao ship $ */


g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
g_pv_lookups  CONSTANT VARCHAR2(12) :=  'PV_LOOKUPS';

G_INTERACTION_LEVEL_10 CONSTANT NUMBER := 10;
G_INTERACTION_LEVEL_20 CONSTANT NUMBER := 20;
G_INTERACTION_LEVEL_30 CONSTANT NUMBER := 30;
G_INTERACTION_LEVEL_40 CONSTANT NUMBER := 40;
G_INTERACTION_LEVEL_50 CONSTANT NUMBER := 50;

resource_locked EXCEPTION;
API_RECORD_CHANGED EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);

/* Param record */

TYPE log_params_rec_type IS RECORD
(
 param_name                  VARCHAR2(30)
 ,param_value                VARCHAR2(2000)
 ,param_type                 VARCHAR2(50)
 ,param_lookup_type          VARCHAR2(100)
);

TYPE log_params_tbl_type IS TABLE OF log_params_rec_type INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--    check_fk_exists
--
-- PURPOSE
--    This function checks if a foreign key is valid.
--
-- NOTES
--    1. It will return FND_API.g_true/g_false.
--    2. Exception encountered will be raised to the caller.
--    4. Please don't put 'AND' at the beginning of your additional
--       where clause.
---------------------------------------------------------------------
FUNCTION check_fk_exists(
   p_table_name   IN VARCHAR2,
   p_pk_name      IN VARCHAR2,
   p_pk_value     IN VARCHAR2,
   p_pk_data_type IN NUMBER := g_number,
   p_additional_where_clause  IN VARCHAR2 := NULL
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false

---------------------------------------------------------------------
-- FUNCTION
--    is_vendor_admin_user
--
-- PURPOSE
--    This function checks whether the user is vendor administrator
--
-- NOTES
--    1. It will return FND_API.g_true/g_false.
--    2. No exception block.
---------------------------------------------------------------------
FUNCTION is_vendor_admin_user(
   p_resource_id   IN NUMBER
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false
---------------------------------------------------------------------

-- FUNCTION
--    check_lookup_exists
--
-- PURPOSE
--    This function checks if a lookup_code is valid.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_pv_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    check_uniqueness
--
-- PURPOSE
--    This function is to check the uniqueness of the keys.
--    In order to make this function more flexible, you need to
--    pass in where clause of your unique key's check.
---------------------------------------------------------------------
FUNCTION check_uniqueness(
   p_table_name    IN VARCHAR2,
   p_where_clause  IN VARCHAR2
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    is_Y_or_N
--
-- PURPOSE
--    Return FND_API.g_true if p_value='Y' or p_value='N';
--    return FND_API.g_flase otherwise.
---------------------------------------------------------------------
FUNCTION is_Y_or_N(
   p_value  IN  VARCHAR2
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- PROCEDURE
--    debug_message
--
-- PURPOSE
--    This procedure will check the message level and try to add a
--    debug message into the message table of FND_MSG_API package.
--    Note that this debug message won't be translated.
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := FND_MSG_PUB.g_msg_lvl_debug_high
);


---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
-- PURPOSE
--    Add an error message to the message_list for an expected error.
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
);


---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
--
-- PURPOSE
--    This procedure will display all messages in the message list
--    using DBMS_OUTPUT.put_line( ) .
---------------------------------------------------------------------
PROCEDURE display_messages;


---------------------------------------------------------------------
-- PROCEDURE
--    get_lookup_meaning
--
-- PURPOSE
--    This procedure will return the meaning from pvx_lookups if
--    you pass the right lookup_type and lookup_code
---------------------------------------------------------------------
PROCEDURE get_lookup_meaning(
   p_lookup_type      IN    VARCHAR2,
   p_lookup_code      IN    VARCHAR2,
   x_return_status    OUT NOCOPY   VARCHAR2,
   x_meaning          OUT NOCOPY   VARCHAR2
);

---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
-- DESCRIPTION
--    Given a lookup_type and lookup_code, return the meaning from
--    PVX_LOOKUPS.
---------------------------------------------------------------------
FUNCTION get_lookup_meaning (
   p_lookup_type IN VARCHAR2,
   p_lookup_code IN VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_lookup_meaning, WNDS);

---------------------------------------------------------------------
-- PROCEDURE
--    get_System_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the System Timezone profile option
---------------------------------------------------------------------
PROCEDURE get_System_Timezone(
x_return_status   OUT NOCOPY VARCHAR2,
x_sys_time_id     OUT NOCOPY NUMBER,
x_sys_time_name	  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    get_User_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the User Timezone profile option
---------------------------------------------------------------------
PROCEDURE get_User_Timezone(
x_return_status   OUT NOCOPY VARCHAR2,
x_user_time_id    OUT NOCOPY NUMBER,
x_user_time_name  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Timezone
--
-- PURPOSE
--    This procedure will take the user timezone and the input time, depending on the parameter
--    p_convert_type it will convert the input time to System timezone or sent Usertimezone
---------------------------------------------------------------------
PROCEDURE Convert_Timezone(
  p_init_msg_list       IN     VARCHAR2	:= FND_API.G_FALSE,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_user_tz_id          IN     NUMBER,  -- required
  p_in_time             IN     DATE,  -- required
  p_convert_type        IN     VARCHAR2 := 'SYS' , --  (SYS/USER)

  x_out_time            OUT NOCOPY    DATE
);


---------------------------------------------------------------------
-- FUNCTION
--    get_resource_name
-- DESCRIPTION
--    Given a resource ID, returns the full_name from
--    JTF_RS_RES_EMP_VL.
---------------------------------------------------------------------
FUNCTION get_resource_name (
   p_resource_id IN VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_resource_name, WNDS);


-- FUNCTION
--    get_contact_account_id
--
-- PURPOSE
--    This function gets partner contact account ID
--
-- NOTES
--    1. It will return partner contact account ID
--    2. No exception block.
---------------------------------------------------------------------
FUNCTION get_contact_account_id(
   p_contact_rel_party_id   IN NUMBER
)
RETURN NUMBER;
---------------------------------------------------------------------


-------------------------------------------------------------------------------
-- PROCEDURE
--	create_history_log
-- DESCRIPTION
--	Creates a history log
-------------------------------------------------------------------------------
PROCEDURE create_history_log(
  p_arc_history_for_entity_code  	IN	VARCHAR2,
  p_history_for_entity_id  	      IN	NUMBER,
  p_history_category_code		      IN	VARCHAR2	DEFAULT NULL,
  p_message_code			            IN	VARCHAR2,
  p_partner_id                      IN  NUMBER,
  p_access_level_flag               IN  VARCHAR2 DEFAULT  'V',
  p_interaction_level               IN  NUMBER   DEFAULT G_INTERACTION_LEVEL_10,
  p_comments			               IN	VARCHAR2	DEFAULT NULL,
  p_log_params_tbl		            IN	PVX_UTILITY_PVT.log_params_tbl_type,
  p_init_msg_list                   IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_commit                          IN   VARCHAR2     := Fnd_Api.G_FALSE,
  x_return_status    	            OUT NOCOPY 	  VARCHAR2,
  x_msg_count                       OUT NOCOPY    NUMBER,
  x_msg_data                        OUT NOCOPY    VARCHAR2
);

---------------------------------------------------------------------
-- FUNCTION
--    get_business_days
-- DESCRIPTION
--    Gets number of business days between two dates
---------------------------------------------------------------------
PROCEDURE get_business_days
(
    p_from_date         IN  DATE,
    p_to_date           IN  DATE,
    x_bus_days         OUT  NOCOPY NUMBER

);


---------------------------------------------------------------------
-- FUNCTION
--    add_business_days
-- DESCRIPTION
--    Given the interval in business days, this procedure will return
--    the date that is past the interval from current date excluding weekends
---------------------------------------------------------------------
PROCEDURE add_business_days
(
    p_no_of_days         IN  NUMBER,
    x_business_date      OUT NOCOPY DATE

);

END PVX_Utility_PVT;

 

/
