--------------------------------------------------------
--  DDL for Package AHL_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: AHLVUTLS.pls 120.1 2006/01/31 03:44:24 tamdas noship $ */
--
g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
g_ahl_lookups  CONSTANT VARCHAR2(20) :=  'FND_LOOKUP_VALUES';

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
--    3. p_pk_data_type can be AMS_Global_PVT.g_number/g_varchar2.
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
--    check_lookup_exists
--
-- PURPOSE
--    This function checks if a lookup_code is valid.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_ahl_lookups,
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

--======================================================================
-- FUNCTION
--    Check_Status_Change
--
-- PURPOSE
--    Created to check if the status change is valid and allowed or not.
--    Returns success, if it is valid allowed status change
--
--======================================================================

PROCEDURE Check_status_change (
   p_object_type      IN  VARCHAR2,
   p_user_status_id   IN  NUMBER,
   p_status_type      IN  VARCHAR2,
   p_current_status   IN  VARCHAR2,
   p_next_status      IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2);

--======================================================================
-- FUNCTION
--    Check_Status_Order_Change
--
-- PURPOSE
--    Created to check if the status change is valid and allowed or not.
--    Returns success, if it is valid allowed status change
--
--======================================================================

PROCEDURE check_status_order_change (
   p_status_type      IN    VARCHAR2,
   p_current_status   IN    VARCHAR2,
   p_next_status      IN    VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2);


PROCEDURE Get_WF_Process_Name (
   p_object         IN  VARCHAR2,
   p_application_usg_code IN VARCHAR2 DEFAULT 'AHL',
   x_active         OUT NOCOPY VARCHAR2,
   x_process_name   OUT NOCOPY VARCHAR2,
   x_item_type      OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2);

FUNCTION    Get_Unit_Name( p_instance_id in Number)
Return varchar2;

--======================================================================
-- FUNCTION
--    Is_Org_In_User_Ou
--
-- PURPOSE
--    Created to check if the Organization is in users operating unit or not.
--    Returns FND_API.G_TRUE if the org belongs to user's operating unit
--    Returns FND_API.G_FALSE if the org doesnt belong to user's operating unit
--    Returns 'X' on error.
--======================================================================
FUNCTION IS_ORG_IN_USER_OU
(
p_org_id      	IN     		NUMBER,
p_org_name    	IN   		VARCHAR2,
x_return_status OUT NOCOPY 	VARCHAR2,
x_msg_data	OUT NOCOPY	VARCHAR2
)
RETURN VARCHAR2;

--======================================================================
-- FUNCTION
--    GET_LOOKUP_MEANING
--
-- PURPOSE
--    Return fnd_lookup_values_vl.meaning, given lookup_type & lookup_code.
--    This function will either return the correct meaning, or return null.
--    This function also will not raise any error.
--======================================================================
FUNCTION GET_LOOKUP_MEANING
(
    p_lookup_type   IN  VARCHAR2,
    p_lookup_code   IN  VARCHAR2
)
RETURN VARCHAR2;

END AHL_Utility_PVT;

 

/
