--------------------------------------------------------
--  DDL for Package AMS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: amsvutls.pls 120.0 2005/05/31 14:31:02 appldev noship $ */

------------------------------------------------------------------------------
-- HISTORY
--    15-Jun-2000  HOLIU     Added procedures to get qp details
--    15-Jun-2000  PTENDULK  Commented the function is_in_my_area
--                           as it will be released in R2
--    07-Jul-2000  KHUNG     Un-commented for R2
--    13-Jul-2000  choang    Added get_resource_id
--    07-Aug-2000  ptendulk  Added procedure to write Concurrent Programs logs.
--    14-Sep-2000  holiu     Added check_status_change, get_default_user_status,
--                           get_system_status_type, get_system_status_code.
--   03/27/2001    MPANDE    MOved 4 Procedures from OZF to AMS
--   04/13/2001    FELIU     Modify create_log procedure by adding threshold_id
--                           and budget_id
--   04/23/2001    FELIU     Modify create_log procedure by adding p_transaction_id,
--                           p_notification_creat_date.
--   05/24/2001    FELIU     Modify create_log procedure by adding p_activity_log_id.
--   16-Jun-2001   ptendulk  Added check_new_status_change procedure to obsolute
--                           the old check_status_change api
--   09-Jul-2001   ptendulk  Added new function Check_Status_Change
--   13-Aug-2001   slkrishn  Added a new function for currency rounding
--   05-Nov-2001   sveerave  Added specs for rec and table type of delete dependencies.
--   14-Jan-2001   sveerave  Added send_wf_standalone_message procedure, and
--                           Get_Resource_Role procedures for sending standalone mesages.
--   06-Jun-2002   sveerave  Added overloaded check_lookup_exists
--                            which accepts view_application_id, and query from fnd_lookups
-- 19-Dec-2002    mayjain     Added get_install_info
------------------------------------------------------------------------------

g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
g_ams_lookups  CONSTANT VARCHAR2(12) :=  'AMS_LOOKUPS';

resource_locked EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);

G_RCS_ID  CONSTANT VARCHAR2(80) :=  'RCS_ID';
G_OBJ_ID  CONSTANT VARCHAR2(80) :=  'OBJECT_ID';
G_OBJ_TYPE  CONSTANT VARCHAR2(80) :=  'OBJECT_TYPE';
G_ERRNO  CONSTANT VARCHAR2(80) :=  'ERROR_NUMBER';
G_REASON  CONSTANT VARCHAR2(80) :=  'REASON';
G_METHOD_NAME  CONSTANT VARCHAR2(80) :=  'METHOD_NAME';
G_LABEL  CONSTANT VARCHAR2(80) :=  'LABEL';
G_MODULE_NAME  CONSTANT VARCHAR2(80) :=  'MODULE_NAME';

--======================================================================
-- PROCEDURE
--    debug_message
--
-- PURPOSE
--    Writes the message to the log file for the spec'd level and module
--    if logging is enabled for this level and module
--
-- HISTORY
--    01-Oct-2003  huili  Create.
--======================================================================
   PROCEDURE debug_message (p_log_level IN NUMBER,
                       p_module_name    IN VARCHAR2,
                       p_text   IN VARCHAR2);

--======================================================================
-- PROCEDURE
--    log_message
--
-- PURPOSE
--    Writes a message to the log file if this level and module is enabled
--    The message gets set previously with FND_MESSAGE.SET_NAME,
--    SET_TOKEN, etc.
--    The message is popped off the message dictionary stack, if POP_MESSAGE
--    is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
--    displayed to the user later.
--    Example usage:
--    FND_MESSAGE.SET_NAME(...);    -- Set message
--    FND_MESSAGE.SET_TOKEN(...);   -- Set token in message
--    AMS_Utility_PVT.log_message(..., FALSE);  -- Log message
--
-- HISTORY
--    01-Oct-2003  huili  Create.
--======================================================================

   PROCEDURE log_message(p_log_level   IN NUMBER,
                         p_module_name IN VARCHAR2,
                         p_RCS_ID      IN VARCHAR2 := NULL,
                         p_pop_message IN BOOLEAN DEFAULT NULL);

--======================================================================
-- FUNCTION
--    logging_enabled
--
-- PURPOSE
--    Return whether logging is enabled for a particular level
--
-- HISTORY
--    03-Oct-2003  huili  Create.
--======================================================================
   FUNCTION logging_enabled (p_log_level IN NUMBER)
      RETURN BOOLEAN;


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
   p_lookup_table_name  IN VARCHAR2 := g_ams_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2;  -- FND_API.g_true/g_false

---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
-- PURPOSE
--    This function checks if a lookup_code is valid from fnd_lookups when
--    view_application_id is passed in.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_type          IN  VARCHAR2,
   p_lookup_code          IN  VARCHAR2,
   p_view_application_id  IN  NUMBER
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
--    get_qual_table_name_and_pk
--
-- PURPOSE
--    This procedure will return the table name and the primary key
--    field which are associated with each System Qualifer values.
--    The will allow for easier FK validation.
---------------------------------------------------------------------
PROCEDURE get_qual_table_name_and_pk(
   p_sys_qual      IN    VARCHAR2,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_table_name    OUT NOCOPY   VARCHAR2,
   x_pk_name       OUT NOCOPY   VARCHAR2
);


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
   p_message_level  IN  NUMBER := NULL
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


---------------------------------------------------------------
-- PROCEDURE
--    create_log
--
-- PURPOSE
--    This procedure is to create a row in ams_act_logs table
--    to record the log
---------------------------------------------------------------
PROCEDURE create_log(
   x_return_status    OUT NOCOPY VARCHAR2,
   p_arc_log_used_by  IN  VARCHAR2,
   p_log_used_by_id   IN  VARCHAR2,
   p_msg_data         IN  VARCHAR2,
   p_msg_level        IN  NUMBER    DEFAULT NULL,
   p_msg_type         IN  VARCHAR2  DEFAULT NULL,
   p_desc             IN  VARCHAR2  DEFAULT NULL,
   p_budget_id        IN  NUMBER    DEFAULT NULL,
   p_threshold_id     IN  NUMBER    DEFAULT NULL,
   p_transaction_id   IN  NUMBER    DEFAULT NULL,
   p_notification_creat_date    IN DATE DEFAULT NULL,
   p_activity_log_id   IN  NUMBER    DEFAULT NULL
);


---------------------------------------------------------------------
-- FUNCTION
--   get_object_name
--
-- PURPOSE
--    Return the name of the object identified by the four-letter
--    p_sys_arc_qualifier and the p_object_id.
---------------------------------------------------------------------
FUNCTION get_object_name(
   p_sys_arc_qualifier IN VARCHAR2,
   p_object_id         IN NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_object_name, WNDS, WNPS, RNPS);


---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- PURPOSE
--    Call the GL API to convert one currency to another, which
--    has a different currency code.
---------------------------------------------------------------------
PROCEDURE Convert_Currency (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_lookup_meaning
--
-- PURPOSE
--    This procedure will return the meaning from ams_lookups if
--  you pass the right lookup_type and lookup_code
---------------------------------------------------------------------
PROCEDURE get_lookup_meaning(
   p_lookup_type      IN    VARCHAR2,
   p_lookup_code      IN   VARCHAR2,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_meaning       OUT NOCOPY   VARCHAR2
);

---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
-- DESCRIPTION
--    Given a lookup_type and lookup_code, return the meaning from
--    AMS_LOOKUPS.
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
-- HISTORY   created    04/24/2000 sugupta
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
-- HISTORY   created    04/24/2000 sugupta
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
-- HISTORY
--     04/24/2000    sugupta    created
--     04/26/2000    ptendulk   Modified Added a parameter which will tell
--                              which timezone to convert time into
--                              If the convert type is 'SYS' then input time will be
--                              converted into system timezone else it will be
--                              converted to user timezone sent.
--     06-sep-2001   choang     set default for p_user_tz_id for bug 1857131.
---------------------------------------------------------------------
PROCEDURE Convert_Timezone(
  p_init_msg_list       IN     VARCHAR2	:= FND_API.G_FALSE,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_user_tz_id          IN     NUMBER := null,
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


---------------------------------------------------------------------
-- PROCEDURE
--    get_source_code
--
-- PURPOSE
--    Returns The Source Code for The Activity Type specified by the
--    p_activity_type parameter.
---------------------------------------------------------------------
PROCEDURE get_source_code(
   p_activity_type IN    VARCHAR2,
   p_activity_id   IN    NUMBER,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_source_code   OUT NOCOPY   VARCHAR2,
   x_source_id     OUT NOCOPY   NUMBER
);

-----------------------------------------------------------------------
-- FUNCTION
--    is_in_my_division
--
-- PURPOSE
--    Check if the object is running within the same division
--    as the specified country.
--    -> 'Y' : the object is within my division
--    -> 'N' : the object is not within my division
--
-- PARAMETERS
--    p_object_id:      (10001)
--    p_object_type:    ('CAMP')
--    p_country_id:     (location_hierarchy_id of the country)
-----------------------------------------------------------------------
FUNCTION is_in_my_division(
   p_object_type   IN  VARCHAR2,
   p_object_id     IN  NUMBER,
   p_country_id    IN  NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(is_in_my_division, WNDS);

---------------------------------------------------------------------
-- FUNCTION
--    get_product_name
-- DESCRIPTION
--    Get the product or product family name.
---------------------------------------------------------------------
FUNCTION get_product_name(
   p_prod_level IN  VARCHAR2,
   p_prod_id    IN  NUMBER,
   p_org_id     IN  NUMBER := NULL
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_product_name, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--    get_price_list_name
-- DESCRIPTION
--    Get the price list name for a given price list line.
---------------------------------------------------------------------
FUNCTION get_price_list_name(
   p_price_list_line_id   IN  NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_price_list_name, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--    get_uom_name
-- DESCRIPTION
--    Get the uom name for a given uom code.
---------------------------------------------------------------------
FUNCTION get_uom_name(
   p_uom_code  IN  VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_uom_name, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--    get_qp_lookup_meaning
-- DESCRIPTION
--    Get the meaning of the given lookup code in qp_lookups.
---------------------------------------------------------------------
FUNCTION get_qp_lookup_meaning(
   p_lookup_type  IN  VARCHAR2,
   p_lookup_code  IN  VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_qp_lookup_meaning, WNDS);

---------------------------------------------------------------------
-- FUNCTION
--   get_resource_id
-- DESCRIPTION
--   Returns resource_id from the JTF Resource module given
--   an AOL user_id.
-- NOTE
--   Calling programs should check if the returned resource_id
--   is -1, which indicates an error in resource setup.  Usually,
--   this means either the user does not have an associated resource
--   or the resource import was done before the association was made
--   between the user and the employee.
---------------------------------------------------------------------
FUNCTION get_resource_id (
   p_user_id IN NUMBER
)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (get_resource_id, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--   Write_Conc_Log
-- DESCRIPTION
--   Writes the log for Concurrent programs
-- History
--   07-Aug-2000   PTENDULK    Created
-- NOTE
--   If the parameter p_text is passed then the value sent will be printed
--   as log else the messages in the stack are printed.
---------------------------------------------------------------------
PROCEDURE Write_Conc_Log
(   p_text            IN     VARCHAR2 := NULL)
 ;


-----------------------------------------------------------------------
-- FUNCTION
--    get_system_status_type
--
-- PURPOSE
--    Return the system_status_type in ams_status_order_rules table
--    for an object.
-----------------------------------------------------------------------
FUNCTION get_system_status_type(
   p_object  IN  VARCHAR2
)
RETURN VARCHAR2;


-----------------------------------------------------------------------
-- FUNCTION
--    get_system_status_code
--
-- PURPOSE
--    Return the system_status_code based on user_status_id.
-----------------------------------------------------------------------
FUNCTION get_system_status_code(
   p_user_status_id   IN  NUMBER
)
RETURN VARCHAR2;


-----------------------------------------------------------------------
-- FUNCTION
--    get_default_user_status
--
-- PURPOSE
--    Return the default user_status_id based on system_status_type
--    and system_status_code.
-----------------------------------------------------------------------
FUNCTION get_default_user_status(
   p_status_type  IN  VARCHAR2,
   p_status_code  IN  VARCHAR2
)
RETURN VARCHAR2;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_status_change
--
-- PURPOSE
--    Check if approval is needed when changing status.
-----------------------------------------------------------------------
PROCEDURE check_status_change(
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_old_status_id    IN  NUMBER,
   p_new_status_id    IN  NUMBER,
   x_approval_type    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    check_new_status_change
--
-- PURPOSE
--    Check if approval is needed when changing status. This will override the
--    previous procedure as the object attribute table is obsoleted now.
--
-- History
--  16-Jun-2001   ptendulk     Created to replace the old check_status_change
--
-----------------------------------------------------------------------
PROCEDURE Check_New_Status_Change(
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_old_status_id    IN  NUMBER,
   p_new_status_id    IN  NUMBER,
   p_custom_setup_id  IN  NUMBER,
   x_approval_type    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE
--  Moved from OZF
---------------------------------------------------------------------

PROCEDURE convert_currency(
   p_set_of_books_id   IN       NUMBER
  ,p_from_currency     IN       VARCHAR2
  ,p_conversion_date   IN       DATE
  ,p_conversion_type   IN       VARCHAR2
  ,p_conversion_rate   IN       NUMBER
  ,p_amount            IN       NUMBER
  ,x_return_status     OUT NOCOPY      VARCHAR2
  ,x_acc_amount        OUT NOCOPY      NUMBER
  ,x_rate              OUT NOCOPY      NUMBER);
---------------------------------------------------------------------
-- PROCEDURE
--    get_code_combinations
--
-- PURPOSE
--      get code_combination concacnenated segments and ids
-- 20-Sep-2000    slkrishn       Created
-- NOTE
--  Moved from OZF
---------------------------------------------------------------------
FUNCTION get_code_combinations(
   p_code_combination_id    IN   NUMBER
  ,p_chart_of_accounts_id   IN   NUMBER)
   RETURN VARCHAR2;


---------------------------------------------------------------------
-- PROCEDURE
--    Convert_functional_Curr
-- NOTE
--This procedures takes in amount and converts it to the functional currency and returns
--the converted amount,exchange_rate,set_of_book_id,f-nctional_currency_code,exchange_rate_date

-- HISTORY
-- 20-Jul-2000 mpande        Created.
-- 02/23/2001    MPAnde     Updated for getting org id query
-- 01/13/2003    yzhao      fix bug BUG 2750841(same as 2741039) - add org_id, default to null
--parameter x_Amount1 IN OUT NUMBER -- reqd Parameter -- amount to be converted
--   x_TC_CURRENCY_CODE IN OUT VARCHAR2,
--   x_Set_of_books_id OUT NUMBER,
--   x_MRC_SOB_TYPE_CODE OUT NUMBER, 'P' and 'R' - We only do it for primary ('P' because we donot supprot MRC)
--   x_FC_CURRENCY_CODE OUT VARCHAR2,
--   x_EXCHANGE_RATE_TYPE OUT VARCHAR2,-- comes from a AMS profile  or what ever is passed
--   x_EXCHANGE_RATE_DATE  OUT DATE, -- could come from a AMS profile but right now is sysdate
--   x_EXCHANGE_RATE       OUT VARCHAR2,
--   x_return_status      OUT VARCHAR2
-- The following is the rule in the GL API
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required
-- NOTE
--  Moved from OZF
---------------------------------------------------------------------

PROCEDURE calculate_functional_curr(
   p_from_amount          IN       NUMBER
  ,p_conv_date            IN       DATE DEFAULT SYSDATE
  ,p_tc_currency_code     IN       VARCHAR2
  ,p_org_id               IN       NUMBER DEFAULT NULL
  ,x_to_amount            OUT NOCOPY      NUMBER
  ,x_set_of_books_id      OUT NOCOPY      NUMBER
  ,x_mrc_sob_type_code    OUT NOCOPY      VARCHAR2
  ,x_fc_currency_code     OUT NOCOPY      VARCHAR2
  ,x_exchange_rate_type   IN OUT NOCOPY   VARCHAR2
  ,x_exchange_rate        IN OUT NOCOPY   NUMBER
  ,x_return_status        OUT NOCOPY      VARCHAR2);
---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE

-- HISTORY
-- 20-Jul-2000 mpande        Created.
--parameter p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_conv_date          IN  DATE DEFAULT SYSDATE,
--   p_from_amount        IN  NUMBER,
--   x_to_amount          OUT NUMBER
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required

-- 02/23/2001    MPAnde     Updated for getting org id query
-- 04/07/2001    slkrishn   Added p_conv_type and p_conv_rate with defaults
---------------------------------------------------------------------
PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER);

/*============================================================================*/
-- Start of Comments
-- NAME
--   Get_Resource_Role
--
-- PURPOSE
--   This Procedure will be return the workflow user role for
--   the resourceid sent
-- Called By
-- NOTES
-- End of Comments

/*============================================================================*/

PROCEDURE Get_Resource_Role
   ( p_resource_id            IN     NUMBER,
      x_role_name          OUT NOCOPY    VARCHAR2,
      x_role_display_name  OUT NOCOPY    VARCHAR2 ,
      x_return_status      OUT NOCOPY    VARCHAR2
);

--======================================================================
-- Procedure Name: send_wf_standalone_message
-- Type          : Generic utility
-- Pre-Req :
-- Notes:
--    Common utility to send standalone message without initiating
--    process using workflow.
-- Parameters:
--    IN:
--    p_item_type          IN  VARCHAR2   Required   Default =  'MAPGUTIL'
--                               item type for the workflow utility.
--    p_message_name       IN  VARCHAR2   Required   Default =  'GEN_STDLN_MESG'
--                               Internal name for standalone message name
--    p_subject            IN  VARCHAR2   Required
--                             Subject for the message
--    p_body               IN  VARCHAR2   Optional
--                             Body for the message
--    p_send_to_role_name  IN  VARCHAR2   Optional
--                             Role name to whom message is to be sent.
--                             Instead of this, one can send even p_send_to_res_id
--    p_send_to_res_id     IN   NUMBER   Optional
--                             Resource Id that will be used to get role name from WF_DIRECTORY.
--                             This is required if role name is not passed.

--   OUT:
--    x_notif_id           OUT  NUMBER
--                             Notification Id created that is being sent to recipient.
--    x_return_status      OUT   VARCHAR2
--                             Return status. If it is error, messages will be put in mesg pub.
-- History:
-- 11-Jan-2002 sveerave        Created.
--======================================================================

PROCEDURE send_wf_standalone_message(
   p_item_type          IN       VARCHAR2 := 'MAPGUTIL'
  ,p_message_name       IN       VARCHAR2 := 'GEN_STDLN_MESG'
  ,p_subject            IN       VARCHAR2
  ,p_body               IN       VARCHAR2 := NULL
  ,p_send_to_role_name  IN       VARCHAR2  := NULL
  ,p_send_to_res_id     IN       NUMBER := NULL
  ,x_notif_id           OUT NOCOPY      NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  );

--======================================================================
-- FUNCTION
--    Check_Status_Change
--
-- PURPOSE
--    Created to check if the status change is valid or not.
--    Returns FND_API.G_TRUE if it is valid status change
--          or will return FND_API.G_FALSE
--
-- HISTORY
--    09-Jul-2001  ptendulk  Create.
--======================================================================
FUNCTION Check_Status_Change(
   p_status_type      IN  VARCHAR2,
   p_current_status   IN  VARCHAR2,
   p_next_status      IN  VARCHAR2
)
RETURN VARCHAR2;

--======================================================================
-- FUNCTION
--    CurrRound
--
-- PURPOSE
--    Returns the round value for an amount based on the currency
--
-- HISTORY
--    13-Sep-2001  slkrishn  Create.
--======================================================================
FUNCTION CurrRound(
    p_amount IN NUMBER,
    p_currency_code IN VARCHAR2
)
RETURN NUMBER;

--======================================================================
-- PROCEDURE
--    get_install_info
--
-- PURPOSE
--    Gets the installation information for an application
--    with application_id p_dep_appl_id
--
-- HISTORY
--    19-Dec-2002  mayjain  Create.
--======================================================================
procedure get_install_info(p_appl_id     in  number,
			   p_dep_appl_id in  number,
			   x_status	 out nocopy varchar2,
			   x_industry	 out nocopy varchar2,
			   x_installed   out nocopy number);

--======================================================================
-- PROCEDURE
--    Get_Object_Name
--
-- PURPOSE
--    Callback method for IBC to get the Associated Object name for an
--    Electronic Deliverable Attachment.
--
-- HISTORY
--    3/7/2003  mayjain  Create.
--======================================================================
PROCEDURE Get_Object_Name(
	 p_association_type_code 	IN		VARCHAR2
	,p_associated_object_val1 	IN 		VARCHAR2
	,p_associated_object_val2  	IN 		VARCHAR2
	,p_associated_object_val3  	IN 		VARCHAR2 DEFAULT NULL
	,p_associated_object_val4  	IN 		VARCHAR2 DEFAULT NULL
	,p_associated_object_val5  	IN 		VARCHAR2 DEFAULT NULL
	,x_object_name 	  		OUT NOCOPY	VARCHAR2
	,x_object_code 	  		OUT NOCOPY	VARCHAR2
	,x_return_status		OUT NOCOPY	VARCHAR2
	,x_msg_count			OUT NOCOPY	NUMBER
	,x_msg_data			OUT NOCOPY	VARCHAR2
);


--======================================================================
-- PL/SQL RECORD
--    dependent_objects_rec_type
--
-- PURPOSE
--    Dependent Objects Record definition so that it can be used
--    across all objects for delete.
--    This stores details of all the dependent objects for the object to
--    be deleted.
--
-- HISTORY
--    05-Nov-2001  sveerave  Create.
--======================================================================
TYPE dependent_objects_rec_type IS RECORD
(
 name                  VARCHAR2(240)
,type                  VARCHAR2(30)
,status                VARCHAR2(30)
,owner                 VARCHAR2(240)
,deletable_flag        VARCHAR2(1)
);

--======================================================================
-- PL/SQL TABLE OF RECORDS
--    dependent_objects_tbl_type
--
-- PURPOSE
--    Dependent Objects table definition which holds dependent objects rec
--    so that it can be used   across all objects for delete.
--    This stores details of all the dependent objects for the object to
--    be deleted.
--
-- HISTORY
--    05-Nov-2001  sveerave  Create.
--======================================================================

TYPE dependent_objects_tbl_type IS TABLE OF dependent_objects_rec_type INDEX BY BINARY_INTEGER;



--========================================================================
-- PROCEDURE
--    get_user_id
--
-- PURPOSE
--    This api will take a resource id and give the corresponding user_id
--
-- NOTE
--
-- HISTORY
--  19-mar-2002    soagrawa    Created
--========================================================================


FUNCTION get_user_id (
   p_resource_id IN NUMBER
)
RETURN NUMBER ;



---------------------------------------------------------------------
-- FUNCTION
--    validate_locking_rules
--
-- PURPOSE
--    This function to validate locking rules
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE validate_locking_rules(
   p_app_short_name             IN VARCHAR2,
   p_obj_type                   IN VARCHAR2,
   p_obj_attribute              IN VARCHAR2,
   p_obj_status                 IN VARCHAR2,
   p_fileld_ak_name_array       IN JTF_VARCHAR2_TABLE_100,
   p_change_indicator_array     IN JTF_VARCHAR2_TABLE_100,
   x_return_status              OUT NOCOPY VARCHAR2
);

END AMS_Utility_PVT;

 

/
