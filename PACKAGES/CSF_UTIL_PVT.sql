--------------------------------------------------------
--  DDL for Package CSF_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: CSFVUTLS.pls 120.4 2006/05/22 11:28:16 venjayar noship $ */

  g_timing_activated   BOOLEAN;
  g_logging_activated  BOOLEAN;

  /**
   * Returns the Address of a Location given the Location ID.
   * <br>
   * Supports two formats of Addresses - Default being Complete
   *   1. Complete Address - Address 1, 2, 3, 4, ZIP, City, State, Country
   *   2. Short Address    - ZIP, City, State / Province
   *
   * @param p_location_id     Location ID corresponding to the Address desired
   * @param p_small_flag      Short ('Y') / Complete ('N') Address (Optional)
   */
  FUNCTION get_address(p_location_id NUMBER, p_small_flag VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

  /**
   * Adds a Timing Mark in the CSR_TIMERS_B so that we can assess the performance of
   * each operation.
   *
   * @param p_seq   Sequence Number of the Timer
   * @param p_name  Name of the Timing Mark Logged
   * @param p_type
   * @param p_descr Description of the Timing Mark Logged for better information.
   */
  PROCEDURE add_timer(p_seq NUMBER, p_name VARCHAR2, p_type NUMBER, p_descr VARCHAR2);

  /**
   * Checks whether the given Territory ID is one among the Selected Territories
   * of the given user. If no user is no given, then it checks using the signed
   * in user (FND_GLOBAL.USER_ID).
   *
   * @param p_terr_id        Territory ID of the Territory to be checked.
   * @param p_user_id        User ID of the user whose list of Territories is used.
   */
  FUNCTION is_terr_selected(p_terr_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL)
    RETURN NUMBER;

  /**
   * Retuns the list of Territories added to the given User.
   *
   * @param p_user_id        User ID of the user to get the list of User's Territories
   */
  FUNCTION get_selected_terr(p_user_id NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /**
   * Gets the List of Territories selected as a PLSQL Table
   *
   * @param p_user_id        User ID of the user to get the list of User's Territories
   */
  FUNCTION get_selected_terr_table(p_user_id NUMBER DEFAULT NULL)
    RETURN jtf_number_table;

  /**
   * Sets the List of Territories which will be valid for the User.
   *
   * @param p_selected_terr  List of Territories
   * @param p_user_id        User ID of the user to set the new list of Territories
   */
  PROCEDURE set_selected_terr(
    p_selected_terr   IN   VARCHAR2 DEFAULT NULL
  , p_user_id         IN   NUMBER DEFAULT NULL
  );

  /**
   * Returns the Object Name given the Object Type Code and Object ID.
   * <p>
   * This procedure is very useful so that the TABLE NAME is not hardcoded to get
   * the Object Name for a given Object ID. Rather it uses the table JTF_OBJECTS
   * to get the SQL that should be used and forms a Dynamic SQL to get the Object
   * Name
   *
   * @param p_object_type_code    Type Code of the Object whose Name is required
   * @param p_object_id           Identifier of the Object whose Name is required
   */
  FUNCTION get_object_name(p_object_type_code IN VARCHAR2, p_object_id IN NUMBER)
    RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_MISS_NUM - FND API Constant
   * to return INVALID / MISSING NUMBER (9.99E125).
   *
   * @return FND_API.G_MISS_NUM
   */
  FUNCTION get_miss_num RETURN NUMBER;

  /**
   * Utility Function to return FND_API.G_MISS_CHAR - FND API Constant
   * to return INVALID / MISSING CHARACTER (CHR(0))
   *
   * @return FND_API.G_MISS_CHAR
   */
  FUNCTION get_miss_char RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_MISS_DATE - FND API Constant
   * to return INVALID / MISSING DATE (TO_DATE('1','j')).
   *
   * @return FND_API.G_MISS_DATE
   */
  FUNCTION get_miss_date RETURN DATE;

  /**
   * Utility Function to return FND_API.G_VALID_LEVEL_NONE - FND API Constant
   * to denote NO VALIDATION.
   *
   * @return FND_API.G_VALID_LEVEL_NONE
   */
  FUNCTION get_valid_level_none RETURN NUMBER;

  /**
   * Utility Function to return FND_API.G_VALID_LEVEL_FULL - FND API Constant
   * to denote FULL VALIDATION.
   *
   * @return FND_API.G_VALID_LEVEL_FULL
   */
  FUNCTION get_valid_level_full RETURN NUMBER;

  /**
   * Utility Function to return FND_API.G_RET_STS_SUCCESS - FND API Constant for
   * Return Status being SUCCESS ('S').
   *
   * @return FND_API.G_RET_STS_SUCCESS
   */
  FUNCTION get_ret_sts_success RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_RET_STS_ERROR - FND API Constant for
   * Return Status being ERROR ('E').
   *
   * @return FND_API.G_RET_STS_ERROR
   */
  FUNCTION get_ret_sts_error RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_RET_STS_UNEXP_ERROR - FND API Constant for
   * Return Status being UNEXPECTED ERROR ('U').
   *
   * @return FND_API.G_RET_STS_UNEXP_ERROR
   */
  FUNCTION get_ret_sts_unexp_error RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_TRUE - FND API Constant for
   * TRUE ('T').
   *
   * @return FND_API.G_TRUE
   */
  FUNCTION get_true RETURN VARCHAR2;

  /**
   * Utility Function to return FND_API.G_FALSE - FND API Constant for
   * FALSE ('F').
   *
   * @return FND_API.G_FALSE
   */
  FUNCTION get_false RETURN VARCHAR2;

  /**
   * Utility Function to return FND_MSG_PUB.G_FIRST - FND Message Constant for
   * First Message (-1)
   *
   * @return FND_MSG_PUB.G_FIRST
   */
  FUNCTION get_first RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_NEXT - FND Message Constant for
   * Next Message (-2)
   *
   * @return FND_MSG_PUB.G_NEXT
   */
  FUNCTION get_next RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_LAST - FND Message Constant for
   * Last Message (-3)
   *
   * @return FND_MSG_PUB.G_LAST
   */
  FUNCTION get_last RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_PREVIOUS - FND Message Constant for
   * Previous Message (-1)
   *
   * @return FND_MSG_PUB.G_PREVIOUS
   */
  FUNCTION get_previous RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR.
   * FND Message Constant for to get Unexpected Error Message Level (60)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
   */
  FUNCTION get_msg_lvl_unexp_error RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_ERROR.
   * FND Message Constant for to get Error Message Level (50)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_ERROR
   */
  FUNCTION get_msg_lvl_error RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_SUCCESS.
   * FND Message Constant for to get Success Error Message Level (40)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_SUCCESS
   */
  FUNCTION get_msg_lvl_success RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH.
   * FND Message Constant for to get High Priority Debug Message Level (30)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
   */
  FUNCTION get_msg_lvl_debug_high RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM.
   * FND Message Constant for to get Medium Priority Debug Message Level (20)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM
   */
  FUNCTION get_msg_lvl_debug_medium RETURN NUMBER;

  /**
   * Utility Function to return FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW.
   * FND Message Constant for to get Low Priority Debug Message Level (10)
   *
   * @return FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
   */
  FUNCTION get_msg_lvl_debug_low RETURN NUMBER;

  /**
   * Returns the UOM Description / Name for the given UOM Code
   *
   * @param  p_code   Code of the UOM for which Name is desired.
   */
  FUNCTION get_uom(p_code VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Checks whether the given UOM is valid
   *
   * @return TRUE/FALSE depending on whether UOM is valid/invalid.
   */
  FUNCTION is_uom_valid(p_value VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Returns the Default UOM (in Minutes) profile by reading the profile
   * "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES).
   *
   * @return Value of "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES)
   */
  FUNCTION get_uom_minutes RETURN VARCHAR2;

  /**
   * Converts the given Duration in the given Duration UOM to the UOM as defined by the
   * profile "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES) there by
   * converting the value to Minutes.
   *
   * @param   p_duration      Duration to be converted to Minutes UOM
   * @param   p_duration_uom  Source UOM
   */
  FUNCTION convert_to_minutes(p_duration IN NUMBER, p_duration_uom IN VARCHAR2)
    RETURN NUMBER;

  /**
   * Gets the Task Effort along with the UOM after converting the effort so
   * as to represent it in the Default UOM "CSF: Default Effort UOM".
   * <br>
   * Its better for this API to be called only for Child Tasks so that they
   * are appropriately represented in a better UOM rather than the UOM used by
   * Scheduler (Minutes) to create the Child Task.
   * For Parent Tasks / Normal Tasks, the effort and its UOM should not be
   * converted as they are entered by the Teleservice Operators.
   * <br>
   * Suppose the effort cannot be represented as a Whole Number in the Default
   * UOM then the effort will be represented as a combination of many UOMs.
   * <br>
   * Examples
   * --------
   * CSF: Default Effort UOM - HR.
   *
   *    -------------------------------------------------------
   *    |  Input Effort  |  Input UOM  |       Output         |
   *    -------------------------------------------------------
   *    |                |             |                      |
   *    |  50            |     MIN     |   50 Minute          |
   *    |  60            |     MIN     |   1 Hour             |
   *    |  70            |     MIN     |   1 Hour 10 Minute   |
   *    |  1500          |     MIN     |   25 Hour            |
   *    |  2             |     HR      |   2 Hour             |
   *    |  2             |     DAY     |   48 Hour            |
   *    -------------------------------------------------------
   *
   * <br>
   * @param p_effort      Effort which needs to be converted
   * @param p_effort_uom  Effort UOM of the above Task Effort
   *
   * @return Effort appro converted to Default UOM followed by "UOM Full Form"
   */
  FUNCTION get_effort_in_default_uom(p_effort NUMBER, p_effort_uom VARCHAR2)
    RETURN VARCHAR2;

  /**
   * (<b>Deprecated</b>) Retained because Service Team is still using it.
   * Returns the Qualifier Table having the list of valid Qualifiers
   * based on the Task Information of the given Task ID.
   *
   * @deprecated Use CSF_RESOURCE_PUB.GET_RES_QUALIFIER_TABLE
   */
  FUNCTION get_qualifier_table ( p_task_id NUMBER )
    RETURN csf_resource_pub.resource_qualifier_tbl_type;

  /**
   * Returns the WHERE CLAUSE of the given Query ID properly augmented
   * with Owner Restrictions if Owner Restriction is Enabled for the Current User
   * and the given Query.
   *
   * @param p_query_id  Query ID for which Where Clause has to be returned
   *
   * @return Where Clause of the Desired Query
   */
  FUNCTION get_query_where ( p_query_id NUMBER )
    RETURN VARCHAR2;

END csf_util_pvt;

 

/
