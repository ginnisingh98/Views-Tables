--------------------------------------------------------
--  DDL for Package AP_WEB_POLICY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_POLICY_UTILS" AUTHID CURRENT_USER AS
/* $Header: apwpolus.pls 120.16.12010000.3 2010/04/22 13:09:38 meesubra ship $ */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


/*=======================================================================+
 | List of possible AP_POL_HEADERS.CATEGORY_CODE (OIE_EXPENSE_CATEGORY)
 +=======================================================================*/
 c_ACCOMMODATIONS               CONSTANT        VARCHAR2(20) := 'ACCOMMODATIONS';
 c_AIRFARE                      CONSTANT        VARCHAR2(20) := 'AIRFARE';
 c_CAR_RENTAL                   CONSTANT        VARCHAR2(20) := 'CAR_RENTAL';
 c_MEALS                        CONSTANT        VARCHAR2(20) := 'MEALS';
 c_MILEAGE                      CONSTANT        VARCHAR2(20) := 'MILEAGE';
 c_MISC                         CONSTANT        VARCHAR2(20) := 'MISC';
 c_PER_DIEM                     CONSTANT        VARCHAR2(20) := 'PER_DIEM';
/*=======================================================================+
 | List of possible AP_POL_LINES.STATUS (OIE_POLICY_LINE_STATUS)
 +=======================================================================*/
 c_SAVED                     	CONSTANT        VARCHAR2(20) := 'SAVED';
 c_DUPLICATED                   CONSTANT        VARCHAR2(20) := 'DUPLICATED';
 c_ACTIVE                     	CONSTANT        VARCHAR2(20) := 'ACTIVE';
 c_INACTIVE                     CONSTANT        VARCHAR2(20) := 'INACTIVE';
 c_ARCHIVED                     CONSTANT        VARCHAR2(20) := 'ARCHIVED';
/*=======================================================================+
 | List of possible AP_POL_SCHEDULE_OPTIONS.OPTION_TYPE
 +=======================================================================*/
 c_LOCATION			CONSTANT	VARCHAR2(20) := 'LOCATION';
 c_EMPLOYEE_ROLE		CONSTANT	VARCHAR2(20) := 'EMPLOYEE_ROLE';
 c_CURRENCY			CONSTANT	VARCHAR2(20) := 'CURRENCY';
 c_VEHICLE_CATEGORY		CONSTANT	VARCHAR2(20) := 'OIE_VEHICLE_CATEGORY';
 c_VEHICLE_TYPE			CONSTANT	VARCHAR2(20) := 'OIE_VEHICLE_TYPE';
 c_FUEL_TYPE			CONSTANT	VARCHAR2(20) := 'OIE_FUEL_TYPE';
 c_DISTANCE_THRESHOLD		CONSTANT	VARCHAR2(20) := 'DISTANCE_THRESHOLD';
 c_TIME_THRESHOLD		CONSTANT	VARCHAR2(20) := 'TIME_THRESHOLD';
 c_ADDON_RATES                  CONSTANT        VARCHAR2(30) := 'OIE_ADDON_MILEAGE_RATES';
 c_NIGHT_RATES                  CONSTANT        VARCHAR2(30) := 'OIE_NIGHT_RATES';
/*=======================================================================+
 | c_THRESHOLD means (OPTION_TYPE  = c_DISTANCE_THRESHOLD or OPTION_TYPE = c_TIME_THRESHOLD)
 | c_THRESHOLD is used only in this package and is not stored in db
 | as a valid AP_POL_SCHEDULE_OPTIONS.OPTION_TYPE
 +=======================================================================*/
 c_THRESHOLD			CONSTANT	VARCHAR2(20) := 'THRESHOLD';
/*=======================================================================+
 | List of possible AP_POL_HEADERS.CURRENCY_PREFERENCE (OIE_POL_CUR_RULES)
 +=======================================================================*/
 c_LCR				CONSTANT	VARCHAR2(20) := 'LCR';
 c_MRC				CONSTANT	VARCHAR2(20) := 'MRC';
 c_SRC				CONSTANT	VARCHAR2(20) := 'SRC';
/*=======================================================================+
 | List of possible OIE_ROUNDING_RULE
 +=======================================================================*/
 c_WHOLE_NUMBER                 CONSTANT        VARCHAR2(20) := 'WHOLE_NUMBER';
 c_NEAREST_FIVE                 CONSTANT        VARCHAR2(20) := 'NEAREST_FIVE';
 c_NEAREST_TEN                  CONSTANT        VARCHAR2(20) := 'NEAREST_TEN';
 c_1_DECIMALS                   CONSTANT        VARCHAR2(20) := '1_DECIMALS';
 c_2_DECIMALS                   CONSTANT        VARCHAR2(20) := '2_DECIMALS';
 c_3_DECIMALS                   CONSTANT        VARCHAR2(20) := '3_DECIMALS';

 TYPE t_lookups_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
 pg_lookups_rec t_lookups_table;

 TYPE t_thresholds_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 pg_thresholds_rec t_thresholds_table;

/*========================================================================
 | PUBLIC FUNCTION get_schedule_status
 |
 | DESCRIPTION
 |   This function fetches the status for a given schedule id.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_policy_id   IN      policy id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Sep-2002           V Nama            Created
 |
 *=======================================================================*/
FUNCTION get_schedule_status(p_policy_id   IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_lookup_meaning
 |
 | DESCRIPTION
 |   This function fetches the meaning for a given lookup type and code
 |   combination. The values are cached, so the SQL is executed only
 |   once for the session.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |   p_lookup_code   IN      Lookup code, which is part of the lookup
 |                           type in previous parameter
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_lookup_meaning(p_lookup_type  IN VARCHAR2,
                            p_lookup_code  IN VARCHAR2) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION get_lookup_description
 |
 | DESCRIPTION
 |   This function fetches the instruction
 |   for a given lookup type and code  combination.
 |   The values are cached, so the SQL is executed only
 |   once for the session.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |   p_lookup_code   IN      Lookup code, which is part of the lookup
 |                           type in previous parameter
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 27-Oct-2003           R Langi           Created
 |
 *=======================================================================*/
FUNCTION get_lookup_description(p_lookup_type  IN VARCHAR2,
                                p_lookup_code  IN VARCHAR2) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION get_high_threshold
 |
 | DESCRIPTION
 |   This function return high threshold for a given low value.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_high_threshold(p_policy_id     IN NUMBER,
                            p_lookup_type   IN VARCHAR2,
                            p_low_threshold IN NUMBER) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION get_single_org_context
 |
 | DESCRIPTION
 |   This function returns whether user is working in single org context.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J on a logic deciding switcher bean behaviour
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y  If user is working in single org context
 |   N  If user is working in single org context
 |
 | PARAMETERS
 |   p_user_id   IN      User Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_single_org_context(p_user_id IN NUMBER) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC PROCEDURE initialize_user_cat_options
 |
 | DESCRIPTION
 |   This procedure creates category options user context.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_user_id       IN      User Id
 |   p_category_code IN  Category Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE initialize_user_cat_options(p_user_id       IN NUMBER,
                                      p_category_code IN VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION location_translation_complete
 |
 | DESCRIPTION
 |   This function returns whether all locations have been translated
 |   for a given language.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y  If location has been translated for the given language
 |   N  If location has not been translated for the given language
 |
 | PARAMETERS
 |   p_language_code IN  Language Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION location_translation_complete(p_language_code IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_employee_name
 |
 | DESCRIPTION
 |   This function returns the employee name for a given user.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for the LineHistoryVO, which cannot have joins
 |   due to connect by clause.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   The employee name for the given user. If employee ID is not defined for
 |   the user, then the username is returned.
 |
 | PARAMETERS
 |   p_user_id IN  User identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_employee_name(p_user_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_location
 |
 | DESCRIPTION
 |   This function returns location.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for the LineHistoryVO, which cannot have joins
 |   due to connect by clause.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Location
 |
 | PARAMETERS
 |   p_location_id IN  Location identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_location(p_location_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_currency_display
 |
 | DESCRIPTION
 |   This function returns currency display.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for
 |   PolicyLinesVO/PolicyLinesAdvancedSearchCriteriaVO/CurrencyScheduleOptionsVO
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Currency Name||' - '||Currency Code
 |
 | PARAMETERS
 |   p_currency_code IN  Currency Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-June-2002          R Langi           Created
 |
 *=======================================================================*/
FUNCTION get_currency_display(p_currency_code IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_role
 |
 | DESCRIPTION
 |   This function returns role.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for the LineHistoryVO, which cannot have joins
 |   due to connect by clause.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Role
 |
 | PARAMETERS
 |   p_policy_line_id IN  Policy Line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_role(p_policy_line_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_role_for_so
 |
 | DESCRIPTION
 |   This function returns role for a schedule option.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for RoleScheduleOptionsVO/PolicyLinesAdvancedSearchVO
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Role
 |
 | PARAMETERS
 |   p_policy_schedule_option_id IN  Policy Schedule Option identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-June-2002          R Langi           Created
 |
 *=======================================================================*/
FUNCTION get_role_for_so(p_policy_schedule_option_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_role
 |
 | DESCRIPTION
 |   This function returns role.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from local overloaded get_role function
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Role
 |
 | PARAMETERS
 |   p_role_code IN  Role Code, one of the following: GRADE, JOB_GROUP, POSITION
 |   p_role_id   IN  Location identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_role(p_role_code VARCHAR2, p_role_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_threshold
 |
 | DESCRIPTION
 |   This function returns threshold string.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J, needed for the LineHistoryVO, which cannot have joins
 |   due to connect by clause.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Threshold
 |
 | PARAMETERS
 |   p_range_low  IN  Range low threshold
 |   p_range_high IN  Range high threshold
 |   p_category_code  IN  Cagetory Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_threshold(p_range_low  IN NUMBER,
                       p_range_high IN NUMBER,
                       p_category_code IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE initialize_user_exrate_options
 |
 | DESCRIPTION
 |   This procedure creates category options user context.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_user_id       IN      User Id
 |   p_category_code IN  Category Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-May-2002           V Nama            Created
 |
 *=======================================================================*/
PROCEDURE initialize_user_exrate_options(p_user_id       IN NUMBER);

/*========================================================================
 | PUBLIC FUNCTION get_context_tab_enabled
 |
 | DESCRIPTION
 |   This function returns whether context tab should be shown or hidden.
 |   Context tab is not showed if:
 |     - Single org installation
 |     - Functional security does not allow it
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from TabCO.java
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   'Y' If policy tab should be displayed
 |   'N' If policy tab should be displayed
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jun-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_context_tab_enabled RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION getHighEndOfThreshold
 |
 | DESCRIPTION
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 | p_policy_id IN Policy Identifier
 | p_threshold IN Threshold
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION getHighEndOfThreshold(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_threshold  IN ap_pol_schedule_options.threshold%TYPE) RETURN ap_pol_schedule_options.threshold%TYPE;

/*========================================================================
 | PUBLIC FUNCTION getHighEndOfThreshold
 |
 | DESCRIPTION
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 | p_policy_id IN Policy Identifier
 | p_threshold IN Threshold
 | p_rate_type IN Rate Type (STANDARD, FIRST, LAST)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION getHighEndOfThreshold(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_threshold  IN ap_pol_schedule_options.threshold%TYPE,
                               p_rate_type  IN ap_pol_schedule_options.rate_type_code%TYPE) RETURN ap_pol_schedule_options.threshold%TYPE;

/*========================================================================
 | PUBLIC FUNCTION getPolicyCategoryCode
 |
 | DESCRIPTION
 | Returns the Category Code for a Policy
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 | p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION getPolicyCategoryCode(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN ap_pol_headers.category_code%TYPE;

/*========================================================================
 | PUBLIC FUNCTION checkRuleOption
 |
 | DESCRIPTION
 | Checks to see if a Rule is enabled for a Schedule and an Option defined
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   isLocationEnabled
 |   isRoleEnabled
 |   isCurrencyEnabled
 |   isVehicleCategoryEnabled
 |   isVehicleTypeEnabled
 |   isFuelTypeEnabled
 |   isThresholdsEnabled
 |
 | PARAMETERS
 |
 | RETURNS
 |   'Y' If a Rule is enabled for a Schedule and an Option defined
 |   'N' If a Rule is not enabled for a Schedule or an Option not defined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION checkRuleOption(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                         p_rule     IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION getUnionStmtForRuleOption
 |
 | DESCRIPTION
 | If a Rule is not enabled or Schedule Option not defined for an enabled Rule
 | this will return a UNION null statement which is used for perumutatePolicyLines()
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id IN Policy Identifier
 |   p_rule IN Schedule Option Type
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION getUnionStmtForRuleOption(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                   p_rule     IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE permutatePolicyLines
 |
 | DESCRIPTION
 | - if a Rule is not enabled or Schedule Option not defined for an enabled Rule then remove the
 |   obsoleted Policy Line
 | - this will never recreate permutated lines based on existing option (rerunnable)
 | - if option doesn't exist then creates permutation for new option
 | - if option end dated then set Policy Line status to inactive
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE permutatePolicyLines(p_user_id IN NUMBER,
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE removeObsoletedPolicyLines
 |
 | DESCRIPTION
 | - if a Rule is not enabled or Schedule Option not defined for an enabled Rule then remove the
 |   obsoleted Policy Line
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE removeObsoletedPolicyLines(p_policy_id  IN ap_pol_headers.policy_id%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE updateInactivePolicyLines
 |
 | DESCRIPTION
 | - if option end dated then set Policy Line status to inactive
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE updateInactivePolicyLines(p_policy_id  IN ap_pol_headers.policy_id%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE duplicatePolicyLines
 |
 | DESCRIPTION
 |  Duplicates Policy Lines from one Policy Schedule Period to another
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_from_policy_id IN Policy Identifier to duplicate From
 |  p_from_schedule_period_id IN Policy Schedule Period Identifier to duplicate From
 |  p_to_policy_id IN Policy Identifier to duplicate To
 |  p_to_schedule_period_id IN Policy Schedule Period Identifier to duplicate To
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE duplicatePolicyLines(p_user_id IN NUMBER,
                               p_from_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_from_schedule_period_id  IN ap_pol_schedule_periods.schedule_period_id%TYPE,
                               p_to_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_to_schedule_period_id  IN ap_pol_schedule_periods.schedule_period_id%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE preservePolicyLine
 |
 | DESCRIPTION
 |  Preserve a modified Active Policy Line
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_policy_id IN Policy Identifier
 |  p_schedule_period_id IN Policy Schedule Period Identifier
 |  p_policy_line_id IN Policy Line Identifier to preserve
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE preservePolicyLine(p_user_id IN NUMBER,
                             p_policy_id  IN ap_pol_lines.policy_id%TYPE,
                             p_schedule_period_id  IN ap_pol_lines.schedule_period_id%TYPE,
                             p_policy_line_id  IN ap_pol_lines.policy_line_id%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE archivePreservedPolicyLines
 |
 | DESCRIPTION
 |  Archive and remove a preserved Active Policy Line after it has been reactivated
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE archivePreservedPolicyLines(p_user_id IN NUMBER,
                                      p_policy_id  IN ap_pol_lines.policy_id%TYPE);

/*========================================================================
 | PUBLIC FUNCTION createSchedulePeriod
 |
 | DESCRIPTION
 |  Creates a new Policy Schedule Period
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_policy_id IN Policy Identifier
 |  p_schedule_period_name IN Schedule Period Name
 |  p_start_date IN Start Date
 |  p_end_date IN End Date
 |  p_rate_per_passenger IN Rate Per Passenger
 |  p_min_days IN Minimum Number of Days
 |  p_tolerance IN Tolerance
 |  p_min_rate_per_period         IN Minimum Rate per Period
 |  p_max_breakfast_deduction     IN Maximum Breakfast Deduction Allowed per Period
 |  p_max_lunch_deduction         IN Maximum Lunch Deduction Allowed per Period
 |  p_max_dinner_deduction        IN Maximum Dinner Deduction Allowed per Period
 |  p_first_day_rate              IN First day rate
 |  p_last_day_rate               IN Last day rate
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION createSchedulePeriod(p_user_id IN NUMBER,
                              p_policy_id  IN ap_pol_schedule_periods.policy_id%TYPE,
                              p_schedule_period_name  IN ap_pol_schedule_periods.schedule_period_name%TYPE,
                              p_start_date  IN ap_pol_schedule_periods.start_date%TYPE,
                              p_end_date  IN ap_pol_schedule_periods.end_date%TYPE DEFAULT NULL,
                              p_rate_per_passenger  IN ap_pol_schedule_periods.rate_per_passenger%TYPE,
                              p_min_days  IN ap_pol_schedule_periods.min_days%TYPE,
                              p_tolerance  IN ap_pol_schedule_periods.tolerance%TYPE,
                              p_min_rate_per_period  IN ap_pol_schedule_periods.min_rate_per_period%TYPE,
                              p_max_breakfast_deduction IN ap_pol_schedule_periods.max_breakfast_deduction_amt%TYPE,
                              p_max_lunch_deduction  IN ap_pol_schedule_periods.max_lunch_deduction_amt%TYPE,
                              p_max_dinner_deduction IN ap_pol_schedule_periods.max_dinner_deduction_amt%TYPE,
                              p_first_day_rate IN ap_pol_schedule_periods.first_day_rate%TYPE,
                              p_last_day_rate IN ap_pol_schedule_periods.last_day_rate%TYPE) RETURN ap_pol_schedule_periods.schedule_period_id%TYPE;

/*========================================================================
 | PUBLIC FUNCTION massUpdateValue
 |
 | DESCRIPTION
 |  Using a rounding rule and percentage to update by, a value is returned
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_value IN Value to perform an update on
 |  p_update_by IN Percentage to update the value by
 |  p_rounding_rule IN Rounding rule to use after the value has been updated
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
FUNCTION massUpdateValue(p_value  IN NUMBER,
                         p_update_by  IN NUMBER,
                         p_rounding_rule     IN VARCHAR2) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE duplicatePolicy
 |
 | DESCRIPTION
 |  Duplicates a Policy Schedule (General Information/Options/Periods/Lines)
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |  createSchedulePeriod
 |  duplicatePolicyLines
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |  duplicatePolicyHeader
 |  duplicatePolicyScheduleOptions
 |
 | PARAMETERS
 |  p_user_id IN User Identifier
 |  p_from_policy_id IN Policy Identifier to duplicate From
 |  p_new_policy_id IN New Policy Identifier containing the duplicated Policy
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE duplicatePolicy(p_user_id IN NUMBER,
                          p_from_policy_id  IN  ap_pol_headers.policy_id%TYPE,
                          p_new_policy_id   OUT NOCOPY ap_pol_headers.policy_id%TYPE);

/*========================================================================
 | PUBLIC FUNCTION active_option_exists
 |
 | DESCRIPTION
 |  Checks whether a active schedule option exists for a option
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_option_type   IN Option type, required
 |  p_option_code   IN Option code, optional
 |  p_threshold     IN Threshold, optional
 |  p_role_id       IN Role Id, optional
 |  p_location_id   IN Location Id, optional
 |  p_currency_code IN Currency Code, optional
 |  p_end_date      IN End Date, optional
 |
 | RETURNS
 |  Y If active option exists
 |  N If active option does not exist
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Jun-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION active_option_exists(p_option_type   IN VARCHAR2,
                              p_option_code   IN VARCHAR2,
                              p_threshold     IN NUMBER,
                              p_role_id       IN NUMBER,
                              p_location_id   IN NUMBER,
                              p_currency_code IN VARCHAR2,
                              p_end_date      IN DATE) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC PROCEDURE end_date_active_loc_options
 |
 | DESCRIPTION
 |  If locations are end dated on location definitions then corresponding
 |  active locations on schedule options should be end dated provided the
 |  location option's end date is null or later than the defined end date.
 |
 | NOTES
 |  Created vide bug 2560275
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Feb-2004           V Nama            Created
 |
 *=======================================================================*/
PROCEDURE end_date_active_loc_options;

/*========================================================================
 | PUBLIC FUNCTION does_location_exist
 |
 | DESCRIPTION
 |  Checks whether a locations exists
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  NONE
 |
 | RETURNS
 |  Y If locations exist
 |  N If locations does not exist
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Jun-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION does_location_exist RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE status_saved_sched_opts
 |
 | DESCRIPTION
 |   This procedure sets status of schedule options to 'SAVED' for
 |   the given policy_id
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id       IN      Policy Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 17-JUL-2002           Mohammad Shoaib Jamall     Created
 |
 *=======================================================================*/
PROCEDURE status_saved_sched_opts(p_policy_id       IN NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE status_active_sched_opts
 |
 | DESCRIPTION
 |   This procedure sets status of schedule options to 'ACTIVE' for
 |   the given policy_id
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id       IN      Policy Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 17-JUL-2002           Mohammad Shoaib Jamall     Created
 |
 *=======================================================================*/
PROCEDURE status_active_sched_opts(p_policy_id       IN NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE set_status_pol_sched_opts
 |
 | DESCRIPTION
 |   This procedure sets status of schedule options for the given policy_id
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id       IN      Policy Id
 |   p_status_code     IN      Status Code
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 17-JUL-2002           Mohammad Shoaib Jamall     Created
 |
 *=======================================================================*/
PROCEDURE set_status_pol_sched_opts(p_policy_id       IN NUMBER,
                                    p_status_code     IN VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION are_exp_type_enddates_capped
 |
 | DESCRIPTION
 |  Checks to see if end dates on expense templates are capped
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_policy_id IN Policy Identifier
 |  p_end_date IN End Date
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 31-JUL-2002           Mohammad Shoaib Jamall     Created
 |
 *=======================================================================*/
FUNCTION are_exp_type_enddates_capped(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                      p_end_date  IN ap_pol_headers.end_date%TYPE DEFAULT NULL) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION cap_expense_type_enddates
 |
 | DESCRIPTION
 |  Caps end dates on expense type with p_end_date
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |  p_policy_id IN Policy Identifier
 |  p_end_date IN End Date
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 31-JUL-2002           Mohammad Shoaib Jamall     Created
 |
 *=======================================================================*/
PROCEDURE cap_expense_type_enddates(p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                    p_end_date  IN ap_pol_headers.end_date%TYPE DEFAULT NULL);


/*========================================================================
 | PUBLIC PROCEDURE initialize_user_expense_options
 |
 | DESCRIPTION
 |   This procedure creates expense options for user context.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_user_id       IN      User Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE init_user_expense_options(p_user_id       IN NUMBER);

/*========================================================================
 | PUBLIC FUNCTION format_minutes_to_hour_minutes
 |
 | DESCRIPTION
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION format_minutes_to_hour_minutes(p_minutes IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_hours_from_threshold
 |
 | DESCRIPTION
 |   gets hours from the threshold value stored in minutes
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_hours_from_threshold(p_threshold IN NUMBER) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION get_minutes_threshold
 |
 | DESCRIPTION
 |   converts threshold stored in minutes to hours:mins and returns mins
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_lookup_type   IN      lookup type
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_minutes_from_threshold(p_threshold IN NUMBER) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE deletePolicySchedule
 |
 | DESCRIPTION
 |   This procedure deletes a Policy Schedule
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id       IN     Policy ID
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Jul-2005         Sameer Saxena       Created
 |
 *=======================================================================*/
PROCEDURE deletePolicySchedule(p_policy_id       IN NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE getPolicyLinesCount
 |
 | DESCRIPTION
 |   This procedure returns the number of lines for a policy schedule
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J to prevent querying large number of rows
 |   during initialization.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_schedule_period_id       IN     Policy Schedule Period ID
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Oct-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION getPolicyLinesCount(p_schedule_period_id       IN NUMBER) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE getSingleTokenMessage
 |
 | DESCRIPTION
 |   This function returns the fnd message which has a single token
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and is used in the JRAD for setting column headers
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_message_name       IN     FND Message Name
 |   p_token              IN     FND Message Token
 |   p_token_value        IN     FND Message Token Value
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Oct-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION getSingleTokenMessage( p_message_name   IN VARCHAR2,
                                p_token          IN VARCHAR2,
                                p_token_value    IN VARCHAR2 ) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION get_per_diem_type_meaning
 |
 | DESCRIPTION
 |   This function fetches the meaning for a given lookup type and code
 |   combination. The values are cached, so the SQL is executed only
 |   once for the session.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   BC4J objects
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   DBMS_UTILITY.get_hash_value
 |
 | PARAMETERS
 |   p_source        IN      Source (NULL, CONUS)
 |   p_lookup_code   IN      Lookup code, which is part of the lookup
 |                           type in previous parameter
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_per_diem_type_meaning(p_source  IN VARCHAR2,
                                   p_lookup_code  IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION isFirstPeriodRatesEnabled
 |
 | DESCRIPTION
 | Checks to see if a Rule is enabled for a Schedule and an Option defined
 |
 | CALLED FROM PROCEDURES/FUNCTIONS this package and from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |    p_policy_id  IN   Policy Id
 | RETURNS
 |   TRUE If a Rule is enabled for a Schedule and an Option defined
 |   FALSE If a Rule is not enabled for a Schedule or an Option not defined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION isFirstPeriodRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION isLastPeriodRatesEnabled
 |
 | DESCRIPTION
 | Checks to see if a Rule is enabled for a Schedule and an Option defined
 |
 | CALLED FROM PROCEDURES/FUNCTIONS this package and from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |    p_policy_id  IN   Policy Id
 | RETURNS
 |   TRUE If a Rule is enabled for a Schedule and an Option defined
 |   FALSE If a Rule is not enabled for a Schedule or an Option not defined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION isLastPeriodRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION isSameDayRatesEnabled
 |
 | DESCRIPTION
 | Checks to see if a Rule is enabled for a Schedule and an Option defined
 |
 | CALLED FROM PROCEDURES/FUNCTIONS this package and from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |    p_policy_id  IN   Policy Id
 | RETURNS
 |   TRUE If a Rule is enabled for a Schedule and an Option defined
 |   FALSE If a Rule is not enabled for a Schedule or an Option not defined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION isSameDayRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION isNightRatesEnabled
 |
 | DESCRIPTION
 | Checks to see if a Rule is enabled for a Schedule and an Option defined
 |
 | CALLED FROM PROCEDURES/FUNCTIONS this package and from BC4J
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |    p_policy_id  IN   Policy Id
 | RETURNS
 |   TRUE If a Rule is enabled for a Schedule and an Option defined
 |   FALSE If a Rule is not enabled for a Schedule or an Option not defined
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
FUNCTION isNightRatesEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION isDateInSeason
 |
 | DESCRIPTION
 | Helper function to determine if a date is contained within a season.
 |
 | PARAMETERS
 |    p_date             -- Expense Date in question
 |    p_start_of_season  -- Season Start (mm/dd)
 |    p_end_of_season    -- Season End   (mm/dd)
 | RETURNS
 |   'Y'   if date within season.
 |   'N'   otherwise.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2006           albowicz          Created
 |
 *=======================================================================*/
FUNCTION isDateInSeason (p_date IN DATE,
                         p_start_of_season IN ap_pol_lines.start_of_season%TYPE,
                         p_end_of_season   IN ap_pol_lines.end_of_season%TYPE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION getPolicyLineId
 |
 | DESCRIPTION
 | Determines the applicable policy line given basic expense info.
 |
 | PARAMETERS
 |    p_person_id        -- Person id for whom the expense belongs.
 |    p_expense_type_id  -- Expense Type ID associated to the expense
 |    p_expense_date     -- Expense Start Date
 |    p_location_id      -- Expense Location
 |    p_currency_code    -- Reimbursement Currency Code
 | RETURNS
 |   Policy Line Id    -- if an applicable policy line can be found.
 |   null              -- otherwise.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2006           albowicz          Created
 |
 *=======================================================================*/
FUNCTION getPolicyLineId(p_person_id       IN NUMBER,
                         p_expense_type_id IN NUMBER,
                         p_expense_date    IN DATE,
                         p_location_id     IN NUMBER,
                         p_currency_code   IN VARCHAR2 ) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE getHrAssignment
 |
 | DESCRIPTION
 | Public helper procedure to retrieve HR assignment.
 |
 | PARAMETERS
 |    p_person_id   -- Expense Type ID associated to the expense
 |    p_date        -- Assignment date.
 |    p_grade_id    -- Returns grade id.
 |    p_position_id -- Returns position id.
 |    p_job_id      -- Returns job id.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Feb-2006           albowicz          Created
 |
 *=======================================================================*/

PROCEDURE getHrAssignment(p_person_id   IN   per_employees_x.employee_id%type,
                          p_date        IN   DATE,
                          p_grade_id    OUT  NOCOPY per_all_assignments_f.grade_id%type,
                          p_position_id OUT  NOCOPY per_all_assignments_f.position_id%type,
                          p_job_id      OUT  NOCOPY per_all_assignments_f.job_id%type);


/*========================================================================
 | PUBLIC FUNCTION checkForInvalidLines
 |
 | DESCRIPTION
 | Public helper procedure to validate policy lines.
 |
 | PARAMETERS
 |    p_policy_id     IN    Policy Id
 |    p_schedule_id   IN    Policy Schedule Id.
 |    p_rate_type     IN    Rate Type (STANDARD, SAME_DAY, FIRST_PERIOD,
 |                                     LAST_PERIOD, NIGHT_RATE, ADDON)
 |    p_std_invalid   OUT   Count of invalid standard lines
 |    p_first_invalid OUT   Count of invalid first period lines
 |    p_last_invalid  OUT   Count of invalid last period lines
 |    p_same_invalid  OUT   Count of invalid same day rate lines
 |    p_night_invalid OUT   Count of invalid night rate lines
 |    p_addon_invalid OUT   Count of invalid addon lines
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-Jun-2006           krmenon           Created
 |
 *=======================================================================*/
FUNCTION checkForInvalidLines(p_policy_id     IN ap_pol_lines.POLICY_ID%type,
                              p_schedule_id   IN ap_pol_lines.SCHEDULE_PERIOD_ID%type,
                              p_std_invalid   OUT NOCOPY NUMBER,
                              p_first_invalid OUT NOCOPY NUMBER,
                              p_last_invalid  OUT NOCOPY NUMBER,
                              p_same_invalid  OUT NOCOPY NUMBER,
                              p_night_invalid OUT NOCOPY NUMBER,
                              p_addon_invalid OUT NOCOPY NUMBER) RETURN VARCHAR2;
/*========================================================================
 | PUBLIC FUNCTION activatePolicyLines
 |
 | DESCRIPTION
 | Public helper procedure to activate policy lines for the case where there
 | are more than 300 lines.
 |
 | PARAMETERS
 |    p_policy_id     IN    Policy Id
 |    p_schedule_id   IN    Policy Schedule Id
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-Jun-2006           krmenon           Created
 |
 *=======================================================================*/
PROCEDURE activatePolicyLines(p_policy_id     IN ap_pol_lines.POLICY_ID%type,
                              p_schedule_id   IN ap_pol_lines.SCHEDULE_PERIOD_ID%type);

/*========================================================================
 | PUBLIC FUNCTION get_dup_rule_assignment_exists
 |
 | DESCRIPTION
 |   This function checks whether assignments exist for a given duplicate detection rule.
 |
 | RETURNS
 |   Y / N depending whether assignment exists for the rule
 |
 | PARAMETERS
 |   p_rule_id IN  Rule Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 15-Feb-2010           Dharma Theja Reddy S     Created
 |
 *=======================================================================*/
FUNCTION get_dup_rule_assignment_exists(p_rule_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_dup_rs_assignment_exists
 |
 | DESCRIPTION
 |   This function checks whether assignments exist for a given duplicate detection rule set.
 |
 | RETURNS
 |   Y / N depending whether assignment exists for the rule set
 |
 | PARAMETERS
 |   p_rule_set_id IN  Rule Set Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 17-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION get_dup_rs_assignment_exists(p_rule_set_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_dup_detect_rule_name
 |
 | DESCRIPTION
 |   This function returns duplicate detection rule name using rule id.
 |
 | RETURNS
 |   Duplicate detection rule name.
 |
 | PARAMETERS
 |   p_rule_id IN  Rule Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION get_dup_detect_rule_name(p_rule_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_dup_detect_rs_name
 |
 | DESCRIPTION
 |   This function returns duplicate detection rule set name using rule set id.
 |
 | RETURNS
 |   Duplicate Detection Rule Set name
 |
 | PARAMETERS
 |   p_rule_set_id  IN    Rule Set Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION get_dup_detect_rs_name(p_rule_set_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION validate_dup_detect_rule_name
 |
 | DESCRIPTION
 |   This function validates the duplicate detection rule name.
 |
 | RETURNS
 |   Y / N depending whether the rule name already exists
 |
 | PARAMETERS
 |   p_rule_name  IN    Rule Name
 |   p_rule_id    IN    Rule Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION validate_dup_detect_rule_name(p_rule_name IN VARCHAR2, p_rule_id IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION validate_dup_detect_rs_name
 |
 | DESCRIPTION
 |   This function validates the duplicate detection rule set name.
 |
 | RETURNS
 |   Y / N depending whether the rule set name already exists
 |
 | PARAMETERS
 |   p_rule_set_name  IN    Rule Set Name
 |   p_rule_set_id    IN    Rule Set Id
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION validate_dup_detect_rs_name(p_rule_set_name IN VARCHAR2, p_rule_set_id IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION getDuplicateDetectionRule
 |
 | DESCRIPTION
 |   This function returns the duplicate detection rule id.
 |
 | RETURNS
 |   Duplicate detection rule id
 |
 | PARAMETERS
 |   p_org_id           IN    Org Id
 |   p_category_code    IN    Category Code
 |   p_start_date       IN    Expense Start Date
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION getDuplicateDetectionRule(p_org_id IN ap_expense_report_lines_all.ORG_ID%TYPE,
                                   p_category_code IN ap_expense_report_lines_all.CATEGORY_CODE%TYPE,
                                   p_start_date IN ap_expense_report_lines_all.START_EXPENSE_DATE%TYPE) RETURN NUMBER;

/*========================================================================
 | PUBLIC FUNCTION isDupDetectExists
 |
 | DESCRIPTION
 |   This function validates whether the duplicate detection violation exists
 |   for the expense line.
 |
 | RETURNS
 |   Duplicate Detection Action
 |
 | PARAMETERS
 |   p_report_header_id     IN    Report Header Id
 |   p_dist_line_number     IN    Distribution Line Number
 |   p_org_id               IN    Org Id
 |   p_category_code        IN    Category Code
 |   p_start_date           IN    Expense Start Date
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION isDupDetectExists(p_report_header_id ap_expense_report_lines_all.REPORT_HEADER_ID%TYPE,
                           p_dist_line_number ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE,
                           p_org_id IN ap_expense_report_lines_all.ORG_ID%TYPE,
                           p_category_code IN ap_expense_report_lines_all.CATEGORY_CODE%TYPE,
                           p_start_date IN ap_expense_report_lines_all.START_EXPENSE_DATE%TYPE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION getDistLineNumber
 |
 | DESCRIPTION
 |   This function gets the distribution line number.
 |
 | RETURNS
 |   Distribution Line Number
 |
 | PARAMETERS
 |   p_report_header_id    IN    Report Header Id
 |   p_dist_line_number    IN    Distribution Line Number
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION getDistLineNumber(p_report_header_id IN ap_expense_report_lines_all.REPORT_HEADER_ID%TYPE,
                           p_dist_line_number IN ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE removeDupViolations
 |
 | DESCRIPTION
 |   This procedure removes the duplicate detection violations for the expense line.
 |
 | PARAMETERS
 |   p_report_header_id    IN    Report Header Id
 |   p_dist_line_number    IN    Distribution Line Number
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
PROCEDURE removeDupViolations(p_report_header_id IN ap_expense_report_lines_all.REPORT_HEADER_ID%TYPE,
                              p_dist_line_number IN ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE getDistNumber
 |
 | DESCRIPTION
 |   This procedure gets the distribution line number depending on the expense category.
 |
 | PARAMETERS
 |   p_report_line_id    IN     Report Line Id
 |   p_category          OUT    Expense Category
 |   p_dist_num          OUT    Distribution Number
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
PROCEDURE getDistNumber(p_report_line_id IN ap_pol_violations_all.DUP_REPORT_LINE_ID%TYPE,
                        p_category OUT NOCOPY VARCHAR2,
                        p_dist_num OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION getMaxDistLineNumber
 |
 | DESCRIPTION
 |   This function returns the maximum distribution line number for that expense line.
 |
 | RETURNS
 |   Maximum Distribution Line Number
 |
 | PARAMETERS
 |   p_report_header_id    IN    Report Header Id
 |   p_dist_line_number    IN    Distribution Line Number
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
FUNCTION getMaxDistLineNumber(p_report_header_id IN ap_pol_violations_all.REPORT_HEADER_ID%TYPE,
                              p_dist_line_number IN ap_pol_violations_all.DISTRIBUTION_LINE_NUMBER%TYPE) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE performDuplicateDetection
 |
 | DESCRIPTION
 |   This procedure performs the duplicate detection for the expense line and
 |   inserts the violations on to the table ap_pol_violations_all.
 |
 | MODIFICATION HISTORY
 | Date                  Author                   Description of Changes
 | 23-Feb-2010           Dharma Theja Reddy S        Created
 |
 *=======================================================================*/
PROCEDURE performDuplicateDetection(p_employee_id                 IN            VARCHAR2,
                                    p_report_header_id            IN            VARCHAR2,
                                    p_distribution_line_number    IN            VARCHAR2,
                                    p_org_id                      IN            VARCHAR2,
                                    p_start_date                  IN            DATE,
                                    p_end_date                    IN            DATE,
                                    p_receipt_currency_code       IN            VARCHAR2,
                                    p_daily_amount                IN            NUMBER,
                                    p_receipt_currency_amount     IN            NUMBER,
                                    p_web_parameter_id            IN            VARCHAR2,
                                    p_merchant_name               IN            VARCHAR2,
                                    p_daily_distance              IN            NUMBER,
                                    p_distance_unit_code          IN            VARCHAR2,
                                    p_destination_from            IN            VARCHAR2,
                                    p_destination_to              IN            VARCHAR2,
                                    p_trip_distance               IN            NUMBER,
                                    p_license_plate_number        IN            VARCHAR2,
                                    p_attendes                    IN            VARCHAR2,
                                    p_number_attendes             IN            NUMBER,
                                    p_ticket_class_code           IN            VARCHAR2,
                                    p_ticket_number               IN            VARCHAR2,
                                    p_itemization_parent_id       IN            NUMBER,
                                    p_category_code               IN            VARCHAR2,
                                    p_report_line_id              IN            NUMBER,
                                    p_max_violation_number        IN OUT NOCOPY NUMBER,
                                    p_dup_detect_action           OUT NOCOPY    VARCHAR2,
                                    p_created_by                  IN            NUMBER,
                                    p_creation_date               IN            DATE,
                                    p_last_updated_by             IN            NUMBER,
                                    p_last_update_login           IN            NUMBER,
                                    p_last_update_date            IN            DATE);

/*========================================================================
| PUBLIC FUNCTION massUpdatePolicyLines
|
| DESCRIPTION
| Public helper procedure to Mass Update policy lines for the case where there
| are more than 200 lines.
|
| PARAMETERS
|    l_mass_update_type
|    l_rate
|    l_meal_limit
|    l_calculation_method
|    l_accommodation_calc_method
|    l_breakfast_deduction
|    l_lunch_deduction
|    l_dinner_deduction
|    l_accommodation_adjustment
|    l_meals_deduction
|    l_tolerance
|    l_rate_per_passenger
|    l_one_meal_deduction_amt
|    l_two_meals_deduction_amt
|    l_three_meals_deduction_amt
|    l_rounding_rule
|    l_where_clause
|
|
| MODIFICATION HISTORY
| Date                  Author            Description of Changes
| 06-MAR-2009           meesubra           Created
|
*=======================================================================*/

PROCEDURE massUpdatePolicyLines(l_mass_update_type IN VARCHAR2,
                                l_rate IN VARCHAR2,
                                l_meal_limit IN VARCHAR2,
                                l_calculation_method IN VARCHAR2,
                                l_accommodation_calc_method IN VARCHAR2,
                                l_breakfast_deduction IN VARCHAR2,
                                l_lunch_deduction IN VARCHAR2,
                                l_dinner_deduction IN VARCHAR2,
                                l_accommodation_adjustment IN VARCHAR2,
                                l_meals_deduction IN VARCHAR2,
                                l_tolerance IN VARCHAR2,
                                l_rate_per_passenger IN VARCHAR2,
                                l_one_meal_deduction_amt IN VARCHAR2,
                                l_two_meals_deduction_amt IN VARCHAR2,
                                l_three_meals_deduction_amt IN VARCHAR2,
                                l_rounding_rule IN VARCHAR2,
                                l_where_clause IN VARCHAR2);



END AP_WEB_POLICY_UTILS;

/
