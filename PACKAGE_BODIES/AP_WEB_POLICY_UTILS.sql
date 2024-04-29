--------------------------------------------------------
--  DDL for Package Body AP_WEB_POLICY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_POLICY_UTILS" AS
/* $Header: apwpolub.pls 120.62.12010000.13 2010/06/23 09:29:58 dsadipir ship $ */

  -- Max Length for Policy Schedule Name and Policy Schedule Period Name
  C_PolicyNameMaxLength          CONSTANT NUMBER := 60;

    TYPE hr_assignment_rec IS RECORD (person_id    per_employees_x.employee_id%type,
                                      eff_start_date per_all_assignments_f.effective_start_date%type,
                                      eff_end_date   per_all_assignments_f.effective_end_date%type,
                                      grade_id       per_all_assignments_f.grade_id%type,
                                      job_id         per_all_assignments_f.job_id%type,
                                      position_id    per_all_assignments_f.position_id%type);

    TYPE hr_assignment_cache_type IS TABLE OF hr_assignment_rec;
    hr_assignment_cache hr_assignment_cache_type;


/*========================================================================
 | PRIVATE FUNCTION getHrAssignmentFromDB
 |
 | DESCRIPTION
 | Helper function to retrieve HR assignment info from HR tables.
 |
 | PARAMETERS
 |    p_person_id  -- Expense Type ID associated to the expense
 |    p_date       -- Assignment date.
 | RETURNS
 |   hr_assignment_rec  -- A record of the employee's assignment
 |                      -- as of the given date.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2006           albowicz          Created
 |
 *=======================================================================*/
    FUNCTION getHrAssignmentFromDB(p_person_id IN per_employees_x.employee_id%type,
                                   p_date      IN DATE) RETURN hr_assignment_rec IS
        ret_val hr_assignment_rec;
    BEGIN
        -- Bug: 8449406
        SELECT * INTO ret_val FROM (
            SELECT p_person_id, effective_start_date, effective_end_date, grade_id, job_id, position_id
            FROM per_all_assignments_f ass,
                 per_employees_x P
            WHERE P.EMPLOYEE_ID = p_person_id
              AND ass.person_id = P.employee_id
              AND NOT AP_WEB_DB_HR_INT_PKG.isPersonCwk(P.employee_id)='Y'
              AND p_date >= effective_start_date and p_date <= effective_end_date
              AND ass.assignment_type = 'E'
            UNION ALL
            SELECT p_person_id, effective_start_date, effective_end_date, grade_id, job_id, position_id
            FROM per_all_assignments_f ass,
                 per_cont_workers_x P
            WHERE P.PERSON_ID = p_person_id
              AND ass.person_id = p.person_id
              AND p_date >= effective_start_date and p_date <= effective_end_date
              AND ass.assignment_type = 'C')
        WHERE ROWNUM = 1;

        RETURN ret_val;
    END getHrAssignmentFromDB;


/*========================================================================
 | PRIVATE FUNCTION getHrAssignment
 |
 | DESCRIPTION
 | Helper function to retrieve HR assignment.
 |
 | PARAMETERS
 |    p_person_id  -- Expense Type ID associated to the expense
 |    p_date       -- Assignment date.
 | RETURNS
 |   hr_assignment_rec  -- A record of the employee's assignment
 |                      -- as of the given date.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2006           albowicz          Created
 |
 *=======================================================================*/
    FUNCTION getHrAssignment(p_person_id IN per_employees_x.employee_id%type,
                             p_date      IN DATE) RETURN hr_assignment_rec IS
        l_ret_val hr_assignment_rec;
        l_temp hr_assignment_rec;
        l_index INTEGER;
    BEGIN

        -- First look for the assignment in the session specific cache
        IF(hr_assignment_cache IS NOT NULL) THEN
            FOR i IN hr_assignment_cache.FIRST..hr_assignment_cache.LAST LOOP
                l_temp := hr_assignment_cache(i);
                IF(l_temp.person_id = p_person_id AND p_date between l_temp.eff_start_date and l_temp.eff_end_date) THEN
                    l_ret_val := l_temp;
                    exit;
                END IF;
            END LOOP;
        END IF;

        -- If not found, the lookup from HR tables.
        IF(l_ret_val.person_id IS NULL) THEN
            l_ret_val := getHrAssignmentFromDB(p_person_id,p_date);

            IF(l_ret_val.person_id IS NOT NULL) THEN
                -- Create session specific cache if necessary.
                IF(hr_assignment_cache IS NULL) THEN
                    hr_assignment_cache := hr_assignment_cache_type(l_ret_val);
                ELSE
                    l_index := hr_assignment_cache.LAST +1;
                    hr_assignment_cache.EXTEND;
                    hr_assignment_cache(l_index) := l_ret_val;
                END IF;
            END IF;
        END IF;

        RETURN l_ret_val;
    END getHrAssignment;


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
                              p_job_id      OUT  NOCOPY per_all_assignments_f.job_id%type) IS

    l_hr_assignment hr_assignment_rec;
    BEGIN

    l_hr_assignment := getHrAssignment(p_person_id, p_date);

    IF (l_hr_assignment.person_id IS NOT NULL) THEN
        p_grade_id    := l_hr_assignment.grade_id;
        p_position_id := l_hr_assignment.position_id;
        p_job_id      := l_hr_assignment.job_id;
    END IF;

    END getHrAssignment;


  -- Delcare the private method upfront so that it can be used
  -- before the definition.

  PROCEDURE permutatePolicyLines(p_user_id    IN NUMBER,
                                 p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                 p_rate_type  IN ap_pol_schedule_options.rate_type_code%TYPE);

  PROCEDURE permutateAddonRates( p_user_id IN NUMBER,
                                 p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                 p_schedule_period_id IN ap_pol_lines.schedule_period_id%TYPE );

  PROCEDURE permutateNightRates( p_user_id IN NUMBER,
                                 p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                 p_schedule_period_id IN ap_pol_lines.schedule_period_id%TYPE );

  PROCEDURE permutateConusLines( p_user_id IN NUMBER,
                                 p_policy_id  IN ap_pol_headers.policy_id%TYPE);

  FUNCTION get_hash_value(p_component1    IN VARCHAR2,
                          p_component2    IN VARCHAR2,
                          p_component3    IN VARCHAR2) RETURN NUMBER;

  -- ------------------------ END PRIVATE METHOD DECLARATION ---------------------

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
 | 26-Sep-2002           V Nama            Created w.r.t. bug 2480382
 | 04-Feb-2004           V Nama            Changed w.r.t. bug 2480382
 |                                         accounts new lines after activation
 |
 *=======================================================================*/
FUNCTION get_schedule_status(p_policy_id   IN NUMBER) RETURN VARCHAR2 IS

  l_meaning      fnd_lookups.meaning%TYPE := '';
  l_lookup_code  fnd_lookups.lookup_code%TYPE;
  l_sch_end_date ap_pol_headers.end_date%TYPE;
  l_no__saved_or_duplicated NUMBER;
  l_no__active_or_inactive NUMBER;
  l_no__need_activation NUMBER;

BEGIN

  IF p_policy_id IS NOT NULL THEN

    SELECT end_date
    INTO   l_sch_end_date
    FROM   ap_pol_headers
    WHERE  policy_id = p_policy_id;


    IF ( l_sch_end_date IS NOT NULL ) AND ( l_sch_end_date < sysdate ) THEN

      l_lookup_code := 'INACTIVE';

    ELSE

      --get count of lines for various statuses
      SELECT count(status)
      INTO   l_no__saved_or_duplicated
      FROM   ap_pol_lines
      WHERE  policy_id = p_policy_id
      AND    ( status = 'SAVED' OR status = 'DUPLICATED' or status ='INVALID' or status = 'NEW' or status = 'VALID');


      SELECT count(status)
      INTO   l_no__active_or_inactive
      FROM   ap_pol_lines
      WHERE  policy_id = p_policy_id
      AND    ( status = 'ACTIVE' OR status = 'INACTIVE' );


      --if schedule was activated earlier
      --then atleast one line is active and/or inactive
      --under such case all saved / duplicated lines require activation
      --there are two source for lines requiring activation
      --1) new and never activated lines (will have parent_line_id null)
      --2) old, activated and edited lines (will have parent_line_id not null)
      --however the breakup is not relevant for this api
      IF ( l_no__active_or_inactive > 0 ) THEN

          l_no__need_activation := l_no__saved_or_duplicated;

      ELSE --no lines require activation

          l_no__need_activation := 0;

      END IF;



      --if schedule was activated earlier and requires activation
      IF ( l_no__need_activation > 0 ) THEN

          l_lookup_code := 'PARTIALLY_ACTIVE';

      --if schedule was activated earlier and does NOT require activation
      ELSIF ( l_no__active_or_inactive > 0 ) THEN

          l_lookup_code := 'FULLY_ACTIVE';

      --default schedule was never activated
      ELSE

          l_lookup_code := 'SAVED';

      END IF;


    END IF;

    l_meaning := get_lookup_meaning('OIE_POLICY_SCHEDULE_STATUS',l_lookup_code);

  END IF;

 return(l_meaning);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END get_schedule_status;

/*========================================================================
 | PUBLIC FUNCTION get_lookup_meaning
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
                            p_lookup_code  IN VARCHAR2) RETURN VARCHAR2 IS
  l_meaning fnd_lookups.meaning%TYPE;
  l_hash_value NUMBER;
BEGIN

  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(p_lookup_type||'@*?'||p_lookup_code,
                                                1000,
                                                25000);

    IF pg_lookups_rec.EXISTS(l_hash_value) THEN
        l_meaning := pg_lookups_rec(l_hash_value);
    ELSE

      SELECT meaning
      INTO   l_meaning
      FROM   fnd_lookup_values_vl
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code = p_lookup_code ;

      pg_lookups_rec(l_hash_value) := l_meaning;

    END IF;
  END IF;

  return(l_meaning);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END get_lookup_meaning;

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
                                p_lookup_code  IN VARCHAR2) RETURN VARCHAR2 IS
  l_description fnd_lookups.description%TYPE;
BEGIN

  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

      SELECT description
      INTO   l_description
      FROM   fnd_lookup_values_vl
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code = p_lookup_code ;

  END IF;

  return(l_description);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END get_lookup_description;


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
                            p_low_threshold IN NUMBER) RETURN NUMBER IS

 CURSOR threshold_c IS
  SELECT threshold
  FROM ap_pol_schedule_options
  WHERE option_type = p_lookup_type
  AND   policy_id   = p_policy_id
  ORDER BY threshold;

  previous_threshold NUMBER;
  counter NUMBER := 0;
  l_hash_value     NUMBER;
  l_hash_value2    NUMBER;
  l_result         NUMBER;

BEGIN

  IF p_policy_id IS NOT NULL AND
     p_lookup_type IS NOT NULL AND
     p_low_threshold IS NOT NULL THEN

    l_hash_value := get_hash_value(to_char(p_policy_id),
                                   p_lookup_type,
                                   to_char(p_low_threshold));

    IF pg_thresholds_rec.EXISTS(l_hash_value) THEN
      return pg_thresholds_rec(l_hash_value);
    ELSE
      FOR threshold_rec IN threshold_c LOOP
        IF counter > 0 THEN

          l_hash_value2 := get_hash_value(to_char(p_policy_id),
                                          p_lookup_type,
                                          to_char(previous_threshold));

          pg_thresholds_rec(l_hash_value2) := threshold_rec.threshold;
        END IF;
        counter := counter + 1;
        previous_threshold := threshold_rec.threshold;
      END LOOP;

      l_hash_value2 := get_hash_value(to_char(p_policy_id),
                                      p_lookup_type,
                                      to_char(previous_threshold));
      pg_thresholds_rec(l_hash_value2) := NULL;

    END IF;
  END IF;

  IF pg_thresholds_rec.EXISTS(l_hash_value) THEN
    l_result := pg_thresholds_rec(l_hash_value);
    return l_result;
  ELSE
    return to_number(l_result);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END get_high_threshold;

FUNCTION get_hash_value(p_component1    IN VARCHAR2,
                        p_component2    IN VARCHAR2,
                        p_component3    IN VARCHAR2) RETURN NUMBER IS
BEGIN
  RETURN DBMS_UTILITY.get_hash_value(p_component1||'@*?'||p_component2||'@*?'||p_component3,
                                     1000,
                                     25000);

EXCEPTION
 WHEN OTHERS THEN
  raise;
END get_hash_value;

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
FUNCTION get_single_org_context(p_user_id IN NUMBER) RETURN VARCHAR2 IS

  l_count NUMBER;
BEGIN
  SELECT count(1)
  INTO l_count
  FROM AP_POL_CONTEXT
  WHERE user_id = p_user_id;

 /*-----------------------------------------------------------------*
  | The query should never return 0, however if 0 is returned it is |
  | considered as 'N'. This is because the switcher bean will show  |
  | enterable fields in 'Y' case. If no orgs have been defined to   |
  | the user we show an empty table for the user is not allowed to  |
  | enter context information on the fields page.                   |
  *-----------------------------------------------------------------*/
  IF l_count = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END get_single_org_context;


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
                                      p_category_code IN VARCHAR2) IS

  CURSOR user_cat_options_c IS
    SELECT pco.CATEGORY_OPTION_ID,
           pco.CATEGORY_CODE,
           pco.ORG_ID,
           pc.user_id,
           pc.selected_org_id
    FROM AP_POL_CAT_OPTIONS_ALL pco,
         AP_POL_CONTEXT         pc
    WHERE pco.org_id(+)        = pc.selected_org_id
    AND   pco.category_code(+) = p_category_code
    AND   pc.user_id           = p_user_id;

BEGIN
  FOR user_cat_options_rec IN user_cat_options_c LOOP
    IF user_cat_options_rec.category_option_id is null THEN
      INSERT INTO ap_pol_cat_options_all
             (category_option_id,
              category_code,
              org_id,
              distance_uom,
              distance_field,
              destination_field,
              license_plate_field,
              attendees_field,
              attendees_number_field,
              end_date_field,
              merchant_field,
              ticket_class_field,
              ticket_number_field,
              location_to_field,
              location_from_field,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by)
      VALUES (AP_POL_CAT_OPTIONS_S.nextval,
              p_category_code,
              user_cat_options_rec.selected_org_id,
              DECODE(p_category_code,
                     'MILEAGE','KM',
                     NULL), --distance_uom
              DECODE(p_category_code,
                     'MILEAGE','TRIP_DISTANCE',
                     NULL), --distance_field,
              DECODE(p_category_code,
                     'MILEAGE','ENABLED',
                     NULL), --destination_field,
              DECODE(p_category_code,
                     'MILEAGE','DISABLED',
                     NULL), --license_plate_field,
              DECODE(p_category_code,
                     'MEALS','ENABLED',
                     NULL), --attendees_field,
              DECODE(p_category_code,
                     'MEALS','ENABLED',
                     NULL), --attendees_number_field,
              DECODE(p_category_code,
                     'ACCOMMODATIONS','ENABLED',
                     NULL), --end_date_field,
              DECODE(p_category_code,
                     'ACCOMMODATIONS','ENABLED',
                     'AIRFARE','ENABLED',
                     'CAR_RENTAL','ENABLED',
                     NULL), --merchant_field,
              DECODE(p_category_code,
                     'AIRFARE','ENABLED',
                     NULL), --ticket_class_field,
              DECODE(p_category_code,
                     'AIRFARE','ENABLED',
                     NULL), --ticket_number_field,
              DECODE(p_category_code,
                     'AIRFARE','ENABLED',
                     NULL), --location_to_field,
              DECODE(p_category_code,
                     'AIRFARE','ENABLED',
                     NULL), --location_from_field,
              SYSDATE,
              p_user_id,
              NULL,
              SYSDATE,
              p_user_id);
    END IF;
  END LOOP;

END initialize_user_cat_options;

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
 | 28-Oct-2002           V Nama            bug 2632830
 |                                         If no loc defined return N
 |
 *=======================================================================*/
FUNCTION location_translation_complete(p_language_code IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR locations_defined_cur IS
    SELECT 'Y'
    FROM dual
    WHERE exists (select 'x' from ap_pol_locations_b);
  l_locations_defined VARCHAR2(1);

  CURSOR missing_translations_cur IS
    SELECT count(1) missing_translation_count
    FROM ap_pol_locations_tl
    WHERE language = p_language_code
    AND   language <> source_lang;

  missing_translations_rec missing_translations_cur%ROWTYPE;

BEGIN

--vnama bug 2632830: check if no locations have been defined
  l_locations_defined:='N';

  OPEN locations_defined_cur;
  FETCH locations_defined_cur INTO l_locations_defined;
  CLOSE locations_defined_cur;

  IF (l_locations_defined = 'N') THEN
    RETURN 'N';
  END IF; --ELSE continue
--vnama bug 2632830


  OPEN missing_translations_cur;
  FETCH missing_translations_cur INTO missing_translations_rec;
  CLOSE missing_translations_cur;

  IF (missing_translations_rec.missing_translation_count = 0) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END location_translation_complete;

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
 | 19-Aug-2004           skoukunt          3838623:replace per_workforce_x
 |                                         with per_people_x
 |
 *=======================================================================*/
FUNCTION get_employee_name(p_user_id IN NUMBER) RETURN VARCHAR2 IS

 /* 2-Oct-2003 J Rautiainen Contingent project changes
  * This function is used to fetch the name of a employee, regardless of
  * the status of the employee.
  * So in this case we need to use per_workforce_x.
  */
  CURSOR user_cur IS
    select DECODE(per.PERSON_ID,
                  null, usr.USER_NAME,
                  per.full_name) employee_name
    from fnd_user usr, per_people_x per
    where usr.user_id     = p_user_id
    and   usr.employee_id = per.person_id(+);

  user_rec user_cur%ROWTYPE;

BEGIN
  IF p_user_id is null THEN
    return null;
  END IF;

  OPEN user_cur;
  FETCH user_cur INTO user_rec;
  CLOSE user_cur;

  return user_rec.employee_name;

END get_employee_name;

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
FUNCTION get_location(p_location_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR loc_cur IS
    select location
    from   ap_pol_locations_vl
    where  location_id = p_location_id;

  loc_rec loc_cur%ROWTYPE;

BEGIN
  IF p_location_id is null THEN
    return null;
  END IF;

  OPEN loc_cur;
  FETCH loc_cur INTO loc_rec;
  CLOSE loc_cur;

  return loc_rec.location;

END get_location;

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
FUNCTION get_currency_display(p_currency_code IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR currency_cur IS
    select name||' - '||currency_code currency_display
    from   fnd_currencies_vl
    where  currency_code = p_currency_code;

  currency_rec currency_cur%ROWTYPE;

BEGIN
  IF p_currency_code is null THEN
    return null;
  END IF;

  OPEN currency_cur;
  FETCH currency_cur INTO currency_rec;
  CLOSE currency_cur;

  return currency_rec.currency_display;

END get_currency_display;

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
FUNCTION get_role(p_policy_line_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR policy_cur IS
    select ph.role_code,
           pl.role_id
    from ap_pol_headers ph,
         ap_pol_lines   pl
    where pl.policy_id = ph.policy_id
    and   pl.policy_line_id = p_policy_line_id;

  policy_rec policy_cur%ROWTYPE;

BEGIN
  IF p_policy_line_id is null THEN
    return null;
  END IF;

  OPEN  policy_cur;
  FETCH policy_cur INTO policy_rec;
  CLOSE policy_cur;

  return get_role(policy_rec.role_code, policy_rec.role_id);

END get_role;

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
FUNCTION get_role_for_so(p_policy_schedule_option_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR policy_cur IS
    select ph.role_code,
           pso.role_id
    from ap_pol_headers ph,
         ap_pol_schedule_options   pso
    where ph.policy_id = pso.policy_id
    and   pso.schedule_option_id = p_policy_schedule_option_id;

  policy_rec policy_cur%ROWTYPE;

BEGIN
  IF p_policy_schedule_option_id is null THEN
    return null;
  END IF;

  OPEN  policy_cur;
  FETCH policy_cur INTO policy_rec;
  CLOSE policy_cur;

  return get_role(policy_rec.role_code, policy_rec.role_id);

END get_role_for_so;

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
FUNCTION get_role(p_role_code VARCHAR2, p_role_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR job_cur IS
    select name,
           substrb(name,instrb(name,'.',-1)+1) parsed_name
    from   per_jobs
    where  job_id = p_role_id;

  CURSOR grade_cur IS
    select name,
           substrb(name,instrb(name,'.',-1)+1) parsed_name
    from   per_grades
    where  grade_id = p_role_id;

  CURSOR position_cur IS
    select name,
           substrb(name,instrb(name,'.',-1)+1) parsed_name
    from   hr_all_positions_f
    where  position_id = p_role_id;

  job_rec      job_cur%ROWTYPE;
  grade_rec    grade_cur%ROWTYPE;
  position_rec position_cur%ROWTYPE;

BEGIN

  IF p_role_id is null or p_role_code is null THEN
    return null;
  END IF;

  IF p_role_id = -1 THEN
    return fnd_message.GET_STRING('SQLAP','OIE_ALL_OTHER');
  END IF;

  IF p_role_code = 'JOB_GROUP' THEN

    OPEN  job_cur;
    FETCH job_cur INTO job_rec;
    CLOSE job_cur;

    return job_rec.name;

  ELSIF p_role_code = 'GRADE' THEN

    OPEN  grade_cur;
    FETCH grade_cur INTO grade_rec;
    CLOSE grade_cur;

    return grade_rec.name;

  ELSIF p_role_code = 'POSITION' THEN

    OPEN  position_cur;
    FETCH position_cur INTO position_rec;
    CLOSE position_cur;

    return position_rec.name;

  ELSE
    return null;
  END IF;

END get_role;

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
 |   p_category_code IN  Category Code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_threshold(p_range_low  IN NUMBER,
                       p_range_high IN NUMBER,
                       p_category_code IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  IF     p_range_low is not null
     AND p_range_high is not null THEN

   /*------------------------------------------------------------+
    | Fetch the message "Between RANGE_LOW and RANGE_HIGH"       |
    +------------------------------------------------------------*/
    FND_MESSAGE.SET_NAME ('SQLAP', 'OIE_POL_THRESHOLD_BETWEEN');

   /*-------------------------------------------------------+
    | Replace tokens with the values passed in as parameter |
    +-------------------------------------------------------*/
    if (p_category_code = c_MILEAGE and p_range_low <> 0) then
      FND_MESSAGE.SET_TOKEN ('RANGE_LOW', p_range_low+.1);
    elsif (p_category_code = c_PER_DIEM and p_range_low <> 0) then
--      FND_MESSAGE.SET_TOKEN ('RANGE_LOW', p_range_low+.01);
      FND_MESSAGE.SET_TOKEN ('RANGE_LOW',
			     format_minutes_to_hour_minutes(p_range_low+1));
    else
      FND_MESSAGE.SET_TOKEN ('RANGE_LOW', p_range_low);
    end if;

--    FND_MESSAGE.SET_TOKEN ('RANGE_HIGH' , p_range_high);
    if (p_category_code = c_PER_DIEM) then
      FND_MESSAGE.SET_TOKEN ('RANGE_HIGH',
			     format_minutes_to_hour_minutes(p_range_high));
    else
      FND_MESSAGE.SET_TOKEN ('RANGE_HIGH' , p_range_high);
    end if;

    return FND_MESSAGE.get;
  ELSIF p_range_low is not null THEN

   /*--------------------------------------------------+
    | Fetch the message "Greater Than RANGE_LOW"       |
    +--------------------------------------------------*/
    FND_MESSAGE.SET_NAME ('SQLAP', 'OIE_POL_THRESHOLD_GREATER');

   /*-------------------------------------------------------+
    | Replace tokens with the values passed in as parameter |
    +-------------------------------------------------------*/
    if (p_category_code = c_PER_DIEM) then
      FND_MESSAGE.SET_TOKEN ('RANGE_LOW',
			     format_minutes_to_hour_minutes(p_range_low));
    else
      FND_MESSAGE.SET_TOKEN ('RANGE_LOW', p_range_low);
    end if;
    return FND_MESSAGE.get;

  ELSE
    return null;
  END IF;

END get_threshold;

/*========================================================================
 | PUBLIC PROCEDURE initialize_user_exrate_options
 |
 | DESCRIPTION
 |   This procedure creates exchange rate options user context.
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
 | 30-May-2002           V Nama            Created
 | 30-Jul-2002           V Nama            Altered defaults to null for
 |                                         exchange_rate_allowance and
 |                                         overall_tolerance
 |
 *=======================================================================*/
PROCEDURE initialize_user_exrate_options(p_user_id       IN NUMBER) IS

  CURSOR user_exrate_options_c IS
    SELECT ex.EXCHANGE_RATE_ID,
           ex.ORG_ID,
           pc.user_id,
           pc.selected_org_id
    FROM AP_POL_EXRATE_OPTIONS_ALL ex,
         AP_POL_CONTEXT         pc
    WHERE ex.org_id(+)        = pc.selected_org_id
    AND   pc.user_id          = p_user_id;

BEGIN
  FOR user_exrate_options_rec IN user_exrate_options_c LOOP
    IF user_exrate_options_rec.exchange_rate_id is null THEN
      INSERT INTO ap_pol_exrate_options_all
             (exchange_rate_id,
              enabled,
              default_exchange_rates,
              exchange_rate_type,
              exchange_rate_allowance,
              overall_tolerance,
              org_id,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by)
      VALUES (AP_POL_EXRATE_OPTIONS_S.nextval,
              'N',
              'N',
              'Corporate',
              null,
              null,
              user_exrate_options_rec.selected_org_id,
              SYSDATE,
              p_user_id,
              NULL,
              SYSDATE,
              p_user_id);
    END IF;
  END LOOP;

END initialize_user_exrate_options;

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
FUNCTION get_context_tab_enabled RETURN VARCHAR2 IS

  CURSOR multi_org_c IS
    SELECT nvl(multi_org_flag, 'N') multi_org_flag
    FROM fnd_product_groups;

  multi_org_rec multi_org_c%ROWTYPE;

BEGIN
  OPEN multi_org_c;
  FETCH multi_org_c INTO multi_org_rec;
  CLOSE multi_org_c;

  IF multi_org_rec.multi_org_flag = 'N' THEN
    return 'N';
  END IF;

  IF not fnd_function.test('OIE_POL_ALLOW_MULTI_ORG_SETUP') THEN
    return 'N';
  END IF;

  return 'Y';

END get_context_tab_enabled;


/*========================================================================
 | PUBLIC FUNCTION getHighEndOfThreshold
 |
 | DESCRIPTION
 |    This function internally calls the new function which has an additional
 |    parameter. This function was kept for backward compatibility reasons.
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
                               p_threshold  IN ap_pol_schedule_options.threshold%TYPE) RETURN ap_pol_schedule_options.threshold%TYPE IS
BEGIN

   RETURN getHighEndOfThreshold(p_policy_id, p_threshold, 'STANDARD');

END getHighEndOfThreshold;

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
                               p_rate_type  IN ap_pol_schedule_options.rate_type_code%TYPE) RETURN ap_pol_schedule_options.threshold%TYPE IS

  l_high_end_of_threshold ap_pol_schedule_options.threshold%TYPE;

  CURSOR c_threshold IS
    SELECT threshold
    FROM   ap_pol_schedule_options
    WHERE  policy_id = p_policy_id
    AND    threshold is not null
    AND    nvl(rate_type_code, 'STANDARD') = p_rate_type
    ORDER BY threshold;

BEGIN

    open c_threshold;
    loop
      fetch c_threshold into l_high_end_of_threshold;
      exit when c_threshold%NOTFOUND;

      if l_high_end_of_threshold > p_threshold then
        exit;
      end if;

    end loop;
    close c_threshold;

    if p_threshold = l_high_end_of_threshold then
      l_high_end_of_threshold := null;
    end if;

    return(l_high_end_of_threshold);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END getHighEndOfThreshold;


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
FUNCTION getPolicyCategoryCode(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN ap_pol_headers.category_code%TYPE IS

  l_category_code ap_pol_headers.category_code%TYPE;

BEGIN

  select category_code
  into   l_category_code
  from   ap_pol_headers
  where  policy_id = p_policy_id;

  return l_category_code;

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END getPolicyCategoryCode;


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
 |   isTimeThresholdsEnabled
 |   isDistanceThresholdsEnabled
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
FUNCTION checkRuleOption(p_policy_id IN ap_pol_headers.policy_id%TYPE,
                         p_rule IN VARCHAR2) RETURN VARCHAR2 IS


  FUNCTION isLocationEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_location_flag			ap_pol_headers.location_flag%TYPE;
    l_location_count			number := 0;

  BEGIN
    select location_flag
    into   l_location_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(location_id)
    into   l_location_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type = c_LOCATION
    and    location_id is not null;

    if (l_location_flag = 'Y' and l_location_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isLocationEnabled;

  FUNCTION isRoleEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_employee_role_flag			ap_pol_headers.employee_role_flag%TYPE;
    l_role_count				number := 0;

  BEGIN
    select employee_role_flag
    into   l_employee_role_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(role_id)
    into   l_role_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type = c_EMPLOYEE_ROLE
    and    role_id is not null;

    if (l_employee_role_flag = 'Y' and l_role_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isRoleEnabled;

  FUNCTION isCurrencyEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_currency_preference		ap_pol_headers.currency_preference%TYPE;
    l_currency_count			number := 0;

  BEGIN
    select currency_preference
    into   l_currency_preference
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(currency_code)
    into   l_currency_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type = c_CURRENCY
    and    currency_code is not null;

    if (l_currency_preference = c_MRC and l_currency_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isCurrencyEnabled;

  FUNCTION isVehicleCategoryEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_vehicle_category_flag		ap_pol_headers.vehicle_category_flag%TYPE;
    l_vehicle_category_count		number := 0;

  BEGIN
    select vehicle_category_flag
    into   l_vehicle_category_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(option_code)
    into   l_vehicle_category_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type  = c_VEHICLE_CATEGORY
    and    option_code is not null;

    if (l_vehicle_category_flag = 'Y' and l_vehicle_category_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isVehicleCategoryEnabled;

  FUNCTION isVehicleTypeEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_vehicle_type_flag             ap_pol_headers.vehicle_type_flag%TYPE;
    l_vehicle_type_count            number := 0;

  BEGIN
    select vehicle_type_flag
    into   l_vehicle_type_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(option_code)
    into   l_vehicle_type_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type  = c_VEHICLE_TYPE
    and    option_code is not null;

    if (l_vehicle_type_flag = 'Y' and l_vehicle_type_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isVehicleTypeEnabled;

  FUNCTION isFuelTypeEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_fuel_type_flag             ap_pol_headers.fuel_type_flag%TYPE;
    l_fuel_type_count            number := 0;

  BEGIN
    select fuel_type_flag
    into   l_fuel_type_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(option_code)
    into   l_fuel_type_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    option_type  = c_FUEL_TYPE
    and    option_code is not null;

    if (l_fuel_type_flag = 'Y' and l_fuel_type_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isFuelTypeEnabled;

  FUNCTION isTimeThresholdsEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_time_based_entry_flag		ap_pol_headers.time_based_entry_flag%TYPE;
    l_thresholds_count			number := 0;

  BEGIN
    select nvl(time_based_entry_flag, 'N')
    into   l_time_based_entry_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(threshold)
    into   l_thresholds_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    (option_type = c_TIME_THRESHOLD)
    and    threshold is not null;

    if (l_time_based_entry_flag = 'Y' and l_thresholds_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isTimeThresholdsEnabled;

  FUNCTION isDistanceThresholdsEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_distance_thresholds_flag		ap_pol_headers.distance_thresholds_flag%TYPE;
    l_thresholds_count			number := 0;

  BEGIN
    select nvl2(distance_thresholds_flag, 'Y', 'N')
    into   l_distance_thresholds_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(threshold)
    into   l_thresholds_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    (option_type  = c_DISTANCE_THRESHOLD)
    and    threshold is not null;

    if (l_distance_thresholds_flag = 'Y' and l_thresholds_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN no_data_found  THEN
    return(null);
   WHEN OTHERS THEN
    raise;
  END isDistanceThresholdsEnabled;

  FUNCTION isThresholdsEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS

    l_distance_thresholds_flag		ap_pol_headers.distance_thresholds_flag%TYPE;
    l_time_thresholds_flag		ap_pol_headers.time_based_entry_flag%TYPE;

  BEGIN

    l_distance_thresholds_flag := isDistanceThresholdsEnabled(p_policy_id);
    l_time_thresholds_flag := isTimeThresholdsEnabled(p_policy_id);

    if (l_distance_thresholds_flag IS NULL and l_time_thresholds_flag IS NULL)
    then
      return (null);
    elsif (l_distance_thresholds_flag = 'Y' or l_time_thresholds_flag = 'Y')
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN OTHERS THEN
    raise;
  END isThresholdsEnabled;

  FUNCTION isAddonRatesEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS
    l_addon_mileage_rates_flag		ap_pol_headers.addon_mileage_rates_flag%TYPE;
    l_addon_rates_count			number := 0;
  BEGIN

    select nvl(addon_mileage_rates_flag, 'N')
    into   l_addon_mileage_rates_flag
    from   ap_pol_headers
    where  policy_id = p_policy_id;

    select count(1)
    into   l_addon_rates_count
    from   ap_pol_schedule_options
    where  policy_id = p_policy_id
    and    (option_type  = c_ADDON_RATES)
    and    option_code is not null;

    if (l_addon_mileage_rates_flag = 'Y' and l_addon_rates_count > 0)
    then
      return 'Y';
    else
      return 'N';
    end if;

  EXCEPTION
   WHEN OTHERS THEN
    raise;

  END isAddonRatesEnabled;

BEGIN

  if (p_rule = c_LOCATION) then return isLocationEnabled(p_policy_id); end if;
  if (p_rule = c_EMPLOYEE_ROLE) then return isRoleEnabled(p_policy_id); end if;
  if (p_rule = c_CURRENCY) then return isCurrencyEnabled(p_policy_id); end if;
  if (p_rule = c_VEHICLE_CATEGORY) then return isVehicleCategoryEnabled(p_policy_id); end if;
  if (p_rule = c_VEHICLE_TYPE) then return isVehicleTypeEnabled(p_policy_id); end if;
  if (p_rule = c_FUEL_TYPE) then return isFuelTypeEnabled(p_policy_id); end if;
  if (p_rule = c_TIME_THRESHOLD) then return isTimeThresholdsEnabled(p_policy_id); end if;
  if (p_rule = c_DISTANCE_THRESHOLD) then return isDistanceThresholdsEnabled(p_policy_id); end if;
  if (p_rule = c_THRESHOLD) then return isThresholdsEnabled(p_policy_id); end if;
  if (p_rule = c_ADDON_RATES) then return isAddonRatesEnabled(p_policy_id); end if;

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END checkRuleOption;


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
FUNCTION getUnionStmtForRuleOption(p_policy_id IN ap_pol_headers.policy_id%TYPE,
                                   p_rule IN VARCHAR2) RETURN VARCHAR2 IS

  l_currency_preference               ap_pol_headers.currency_preference%TYPE;

  l_src_stmt			VARCHAR2(160) := 'union all select CURRENCY_CODE from ap_pol_headers where POLICY_ID = :p_policy_id';

  l_vc_stmt			VARCHAR2(80) := 'union all select to_char(null), to_char(null), to_char(null) from sys.dual';
  l_number_stmt			VARCHAR2(80) := 'union all select to_number(null) from sys.dual';
  l_varchar2_stmt		VARCHAR2(80) := 'union all select to_char(null) from sys.dual';

BEGIN

  select currency_preference
  into   l_currency_preference
  from   ap_pol_headers
  where  policy_id = p_policy_id;

  if (checkRuleOption(p_policy_id, p_rule) = 'Y')
  then
    return '';
  else
    if (p_rule = c_CURRENCY) then
      if (l_currency_preference = c_SRC) then
      /*
        if Single Rate Currency there will be no records in ap_pol_schedule_options
        we must still permutate using ap_pol_headers.currency_code
      */
        return l_src_stmt;
      else
      /*
        if Location Currency Rate there will be no records in ap_pol_schedule_options
        if Airfare there will be no records in ap_pol_schedule_options
      */
        return l_varchar2_stmt;
      end if;
    elsif (p_rule = c_VEHICLE_CATEGORY) then
      /*
        if Vehicle Category is not selected
        then return 3 nulls (option_code, vehicle_type_code, fuel_type_code)
      */
      return l_vc_stmt;
    elsif (p_rule = c_LOCATION or p_rule = c_EMPLOYEE_ROLE or p_rule = c_THRESHOLD) then
      return l_number_stmt;
    elsif (p_rule = c_VEHICLE_TYPE or p_rule = c_FUEL_TYPE) then
      return l_varchar2_stmt;
    else
      return '';
    end if;
  end if;

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END getUnionStmtForRuleOption;


/*========================================================================
 | PRIVATE PROCEDURE checkAirfarePolicyLines
 |
 | DESCRIPTION
 | If Airfare Policy Lines, default TICKET_CLASS_DOMESTIC/TICKET_CLASS_INTERNATIONAL
 | to 'COACH'.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_policy_id IN Policy Identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-Dec-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE checkAirfarePolicyLines(p_policy_id IN ap_pol_headers.policy_id%TYPE) IS

BEGIN

  if (getPolicyCategoryCode(p_policy_id) <> 'AIRFARE')
  then
    return;
  else
    update ap_pol_lines
    set    ticket_class_domestic = 'COACH'
    where  policy_id = p_policy_id
    and    ticket_class_domestic is null;

    update ap_pol_lines
    set    ticket_class_international = 'COACH'
    where  policy_id = p_policy_id
    and    ticket_class_international is null;
  end if;

EXCEPTION
 WHEN no_data_found  THEN
  return;
 WHEN OTHERS THEN
  raise;
END checkAirfarePolicyLines;


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
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE) IS

  l_schedule_period_id		ap_pol_schedule_periods.schedule_period_id%TYPE;
  l_permutate_curref		INTEGER;
  l_rows_permutated		NUMBER := 0;

  l_policy_line_count		NUMBER := 0;

  l_insert_sql_stmt		VARCHAR2(4000);
  l_where_sql_stmt		VARCHAR2(4000);
  l_not_exists_sql_stmt		VARCHAR2(4000);

  l_l_sql_stmt			VARCHAR2(4000);
  l_r_sql_stmt			VARCHAR2(4000);
  l_c_sql_stmt			VARCHAR2(4000);
  l_vc_sql_stmt			VARCHAR2(4000);
  l_vt_sql_stmt			VARCHAR2(4000);
  l_ft_sql_stmt			VARCHAR2(4000);
  l_dt_sql_stmt			VARCHAR2(4000);

  l_location_enabled            VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_LOCATION);
  l_role_enabled                VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_EMPLOYEE_ROLE);
  l_currency_enabled            VARCHAR2(160) := getUnionStmtForRuleOption(p_policy_id, c_CURRENCY);
  l_vehicle_category_enabled    VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_VEHICLE_CATEGORY);
  l_vehicle_type_enabled        VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_VEHICLE_TYPE);
  l_fuel_type_enabled           VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_FUEL_TYPE);
  l_thresholds_enabled          VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_THRESHOLD);
  l_addon_rates_enabled         VARCHAR2(1) := checkRuleOption(p_policy_id, c_ADDON_RATES);
  l_night_rates_enabled         VARCHAR2(1) := isNightRatesEnabled(p_policy_id);

  l_schedule_option_rec         ap_pol_schedule_options%ROWTYPE;
  l_zero_threshold_count        NUMBER;
  l_category_code               ap_pol_headers.category_code%TYPE;
  l_rate_type_code              ap_pol_schedule_options.rate_type_code%TYPE;
  l_schedule_type                ap_pol_headers.schedule_type_code%TYPE;
  l_source                      ap_pol_headers.source%TYPE;

---------------------------------------
-- cursor for schedule periods
---------------------------------------
cursor c_schedule_period_id is
  select schedule_period_id
  from   ap_pol_schedule_periods
  where  policy_id = p_policy_id;

---------------------------------------------------
-- cursor for first last and same day  rate periods
--------------------------------------------------
cursor c_rate_types is
  select distinct rate_type_code
  from   ap_pol_schedule_options
  where  policy_id = p_policy_id
  and    rate_type_code in ('FIRST_PERIOD', 'LAST_PERIOD', 'SAME_DAY')
  and    option_type = 'TIME_THRESHOLD';

---------------------------------------
-- cursor for insert/select
---------------------------------------
cursor l_insert_cursor is
select
'
  insert into AP_POL_LINES
        (
         POLICY_LINE_ID,
         POLICY_ID,
         SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         VEHICLE_CATEGORY,
         VEHICLE_TYPE,
         FUEL_TYPE,
         RANGE_LOW,
         RANGE_HIGH,
         RATE_TYPE_CODE,
         STATUS,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
         :p_policy_id AS POLICY_ID,
         :p_schedule_period_id AS SCHEDULE_PERIOD_ID,
         NEW_LOCATION_ID AS LOCATION_ID,
         NEW_ROLE_ID AS ROLE_ID,
         NEW_CURRENCY_CODE AS CURRENCY_CODE,
         NEW_VEHICLE_CATEGORY AS VEHICLE_CATEGORY,
         NEW_VEHICLE_TYPE AS VEHICLE_TYPE,
         NEW_FUEL_TYPE AS FUEL_TYPE,
         NEW_RANGE_LOW AS RANGE_LOW,
         NEW_RANGE_HIGH AS RANGE_HIGH,
         NEW_RATE_TYPE_CODE AS RATE_TYPE_CODE,
         ''NEW'' AS STATUS,
         sysdate AS CREATION_DATE,
         :p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         :p_user_id AS LAST_UPDATED_BY
  from
  (
  select distinct
         NEW_LOCATION_ID,
         NEW_ROLE_ID,
         NEW_CURRENCY_CODE,
         NEW_VEHICLE_CATEGORY,
         NEW_VEHICLE_TYPE,
         NEW_FUEL_TYPE,
         NEW_RANGE_LOW,
         NEW_RANGE_HIGH,
         NEW_RATE_TYPE_CODE
  from
  (
  select
          l.LOCATION_ID AS NEW_LOCATION_ID,
          r.ROLE_ID AS NEW_ROLE_ID,
          c.CURRENCY_CODE AS NEW_CURRENCY_CODE,
         vc.OPTION_CODE AS NEW_VEHICLE_CATEGORY,
         decode(vc.OPTION_CODE, null, vt.OPTION_CODE, decode(vc.VEHICLE_TYPE_CODE, ''R'', vt.OPTION_CODE, null)) AS NEW_VEHICLE_TYPE,
         decode(vc.OPTION_CODE, null, ft.OPTION_CODE, decode(vc.FUEL_TYPE_CODE, ''R'', ft.OPTION_CODE, null)) AS NEW_FUEL_TYPE,
         dt.THRESHOLD AS NEW_RANGE_LOW,
         ap_web_policy_UTILS.getHighEndOfThreshold(:p_policy_id, dt.THRESHOLD) AS NEW_RANGE_HIGH,
         :p_rate_type AS NEW_RATE_TYPE_CODE
  from
'
from sys.dual; /* l_insert_cursor */

---------------------------------------
-- cursor for all locations to use
---------------------------------------
cursor l_l_cursor is
select
'
      (select LOCATION_ID
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_LOCATION
       and    LOCATION_ID IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_location_enabled||'
      ) l,
'
from sys.dual; /* l_l_cursor */

---------------------------------------
-- cursor for all roles to use
---------------------------------------
cursor l_r_cursor is
select
'
      (select ROLE_ID
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_EMPLOYEE_ROLE
       and    ROLE_ID IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_role_enabled||'
      ) r,
'
from sys.dual; /* l_r_cursor */

---------------------------------------
-- cursor for all currency codes to use
---------------------------------------
cursor l_c_cursor is
select
'
      (select CURRENCY_CODE
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_CURRENCY
       and    CURRENCY_CODE IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_currency_enabled||'
      ) c,
'
from sys.dual; /* l_c_cursor */

---------------------------------------
-- cursor for all vehicle categories to use
---------------------------------------
cursor l_vc_cursor is
select
'
      (select OPTION_CODE, VEHICLE_TYPE_CODE, FUEL_TYPE_CODE
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_VEHICLE_CATEGORY
       and    OPTION_CODE IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_vehicle_category_enabled||'
      ) vc,
'
from sys.dual; /* l_vc_cursor */

---------------------------------------
-- cursor for all vehicle types to use
---------------------------------------
cursor l_vt_cursor is
select
'
      (select OPTION_CODE
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_VEHICLE_TYPE
       and    OPTION_CODE IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_vehicle_type_enabled||'
      ) vt,
'
from sys.dual; /* l_vt_cursor */

---------------------------------------
-- cursor for all fuel types to use
---------------------------------------
cursor l_ft_cursor is
select
'
      (select OPTION_CODE
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_FUEL_TYPE
       and    OPTION_CODE IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_fuel_type_enabled||'
      ) ft,
'
from sys.dual; /* l_ft_cursor */

---------------------------------------
-- cursor for all thresholds to use
---------------------------------------
cursor l_dt_cursor is
select
'
      (select THRESHOLD
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    (OPTION_TYPE = :c_DISTANCE_THRESHOLD or OPTION_TYPE = :c_TIME_THRESHOLD)
       and    THRESHOLD IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
       and    nvl(rate_type_code, ''NULL'') = nvl(:p_rate_type, ''NULL'')
         '||l_thresholds_enabled||'
      ) dt
'
from sys.dual; /* l_dt_cursor */


---------------------------------------
-- cursor for where rows
---------------------------------------
cursor l_where_cursor is
select
'
  )
  where
        (
         NEW_LOCATION_ID is not null
  or     NEW_ROLE_ID is not null
  or     NEW_CURRENCY_CODE is not null
  or     NEW_VEHICLE_CATEGORY is not null
  or     NEW_VEHICLE_TYPE is not null
  or     NEW_FUEL_TYPE is not null
  or     NEW_RANGE_LOW is not null
  or     NEW_RANGE_HIGH is not null
        )
  )
'
from sys.dual; /* l_where_cursor */


---------------------------------------
-- cursor for adding new rules/options
---------------------------------------
cursor l_not_exists_cursor is
select
'
  )
  where
        (
         NEW_LOCATION_ID is not null
  or     NEW_ROLE_ID is not null
  or     NEW_CURRENCY_CODE is not null
  or     NEW_VEHICLE_CATEGORY is not null
  or     NEW_VEHICLE_TYPE is not null
  or     NEW_FUEL_TYPE is not null
  or     NEW_RANGE_LOW is not null
  or     NEW_RANGE_HIGH is not null
        )
  and
  not exists
        (
         select epl.POLICY_LINE_ID
         from   AP_POL_LINES epl
         where  epl.POLICY_ID = :p_policy_id
         and    epl.SCHEDULE_PERIOD_ID = :p_schedule_period_id
         and    nvl(epl.LOCATION_ID, :dummy_number) = nvl(NEW_LOCATION_ID, :dummy_number)
         and    nvl(epl.ROLE_ID, :dummy_number) = nvl(NEW_ROLE_ID, :dummy_number)
         and
               (
                (nvl(epl.CURRENCY_CODE, :dummy_varchar2) = nvl(NEW_CURRENCY_CODE, :dummy_varchar2))
                or
                (epl.CURRENCY_CODE is not null and NEW_CURRENCY_CODE is null)
               )
         and    nvl(epl.VEHICLE_CATEGORY, :dummy_varchar2) = nvl(NEW_VEHICLE_CATEGORY, :dummy_varchar2)
         and    nvl(epl.VEHICLE_TYPE, :dummy_varchar2) = nvl(NEW_VEHICLE_TYPE, :dummy_varchar2)
         and    nvl(epl.FUEL_TYPE, :dummy_varchar2) = nvl(NEW_FUEL_TYPE, :dummy_varchar2)
         and    nvl(epl.RANGE_LOW, :dummy_number) = nvl(NEW_RANGE_LOW, :dummy_number)
         and    nvl(epl.RANGE_HIGH, :dummy_number) = nvl(NEW_RANGE_HIGH, :dummy_number)
         and    nvl(epl.RATE_TYPE_CODE, :dummy_varchar2) = nvl(NEW_RATE_TYPE_CODE, :dummy_varchar2)
        )
  )
'
from sys.dual; /* l_not_exists_cursor */




BEGIN

  select category_code, schedule_type_code, source
  into   l_category_code, l_schedule_type, l_source
  from   ap_pol_headers
  where  policy_id = p_policy_id;

  -- ---------------------------------------------------------------
  -- If this is a CONUS/OCONUS policy then call the appropriate
  -- procedure and return
  -- ---------------------------------------------------------------
  IF ( l_source = 'CONUS' ) THEN
    BEGIN
      permutateConusLines(p_user_id, p_policy_id);
      return;
    END;
  END IF;
  -- ----------------------------------------------------------
  -- Insert zero row threshold before generating permutations
  -- ----------------------------------------------------------
  IF ( l_category_code = 'PER_DIEM' ) THEN
  BEGIN
    -- Delete zero threshold rows where not needed
    delete from ap_pol_schedule_options
    where policy_id = p_policy_id
    and   option_type = 'TIME_THRESHOLD'
    and   threshold = 0
    and   rate_type_code not in
          (  select distinct rate_type_code
             from   ap_pol_schedule_options
             where  policy_id = p_policy_id
             and    rate_type_code in ('FIRST_PERIOD', 'LAST_PERIOD', 'SAME_DAY')
             and    option_type = 'TIME_THRESHOLD'
             and    threshold > 0 )
    and rate_type_code <> 'STANDARD';

    FOR rate_type_cur in c_rate_types
    LOOP
      select count(1)
       into  l_zero_threshold_count
       from  ap_pol_schedule_options
      where  policy_id = p_policy_id
        and  rate_type_code = rate_type_cur.rate_type_code
        and  threshold = 0;

      IF ( l_zero_threshold_count = 0 ) THEN
        BEGIN
          SELECT ap_pol_schedule_options_s.NEXTVAL
          INTO   l_schedule_option_rec.schedule_option_id
          FROM   DUAL;

          INSERT INTO ap_pol_schedule_options
             (
              policy_id,
              schedule_option_id,
              option_type,
              threshold,
              status,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              rate_type_code
             )
          VALUES
             (
              p_policy_id,
              l_schedule_option_rec.schedule_option_id,
              'TIME_THRESHOLD',
              0,
              'SAVED',
              sysdate,
              p_user_id,
              sysdate,
              p_user_id,
              rate_type_cur.rate_type_code
             );

          /*--------- COMMENTING THIS CODE SINCE GSCC NOT FIXED FOR REC TYPE --------------
          l_schedule_option_rec.policy_id        := p_policy_id;
          l_schedule_option_rec.option_type      := 'TIME_THRESHOLD';
          l_schedule_option_rec.threshold        := 0;
          l_schedule_option_rec.status           := 'SAVED';
          l_schedule_option_rec.creation_date    := sysdate;
          l_schedule_option_rec.created_by       := p_user_id;
          l_schedule_option_rec.last_update_date := sysdate;
          l_schedule_option_rec.last_updated_by  := p_user_id;
          l_schedule_option_rec.rate_type_code   := rate_type_cur.rate_type_code;

          INSERT INTO ap_pol_schedule_options values  l_schedule_option_rec;
          ----------------------------------------------------------------------------------*/
        END;
      END IF;
    END LOOP;

    -- Standard rate is a special case. Should not insert 0 record
    -- for midnight to midnight schedules which have first and last rates
    -- or for allowance schedules with time rule of start and end times
    select  count(1)
      into  l_zero_threshold_count
      from  ap_pol_headers
     where  policy_id = p_policy_id
       and  time_based_entry_flag = 'Y'
       and  ( day_period_code <> 'MIDNIGHT' or
             (nvl(rate_period_type_code, 'STANDARD') = 'STANDARD' and  schedule_type_code = 'PER_DIEM') or
             ( schedule_type_code = 'ALLOWANCE' and allowance_time_rule_code = 'TIME_THRESHOLD' )
             );

    IF ( l_zero_threshold_count = 1 ) THEN
      BEGIN
        select  count(1)
          into  l_zero_threshold_count
          from  ap_pol_schedule_options
         where  policy_id = p_policy_id
           and  rate_type_code = 'STANDARD'
           and  threshold = 0;

        IF ( l_zero_threshold_count = 0 ) THEN
          BEGIN
            SELECT ap_pol_schedule_options_s.NEXTVAL
            INTO   l_schedule_option_rec.schedule_option_id
            FROM   DUAL;

            INSERT INTO ap_pol_schedule_options
             (
              policy_id,
              schedule_option_id,
              option_type,
              threshold,
              status,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              rate_type_code
             )
            VALUES
             (
              p_policy_id,
              l_schedule_option_rec.schedule_option_id,
              'TIME_THRESHOLD',
              0,
              'SAVED',
              sysdate,
              p_user_id,
              sysdate,
              p_user_id,
              'STANDARD'
             );

          /*--------- COMMENTING THIS CODE SINCE GSCC NOT FIXED FOR REC TYPE --------------
             l_schedule_option_rec.policy_id        := p_policy_id;
            l_schedule_option_rec.option_type      := 'TIME_THRESHOLD';
            l_schedule_option_rec.threshold        := 0;
            l_schedule_option_rec.status           := 'SAVED';
            l_schedule_option_rec.creation_date    := sysdate;
            l_schedule_option_rec.created_by       := p_user_id;
            l_schedule_option_rec.last_update_date := sysdate;
            l_schedule_option_rec.last_updated_by  := p_user_id;
            l_schedule_option_rec.rate_type_code   := 'STANDARD';

            INSERT INTO ap_pol_schedule_options values  l_schedule_option_rec;
          ---------------------------------------------------------------------------------*/

          END;
        END IF;

      END;
    ELSE
     -- ---------------------------------------------------------------------
     -- This means that we should not have a zero row for standard rate type
     -- So delete any such rows
     -- ---------------------------------------------------------------------
     delete from ap_pol_schedule_options
     where  policy_id = p_policy_id
     and    rate_type_code = 'STANDARD'
     and    threshold      = 0;

    END IF;

    l_rate_type_code := 'STANDARD';
  END;
  ELSE
    l_rate_type_code := null;
  END IF;



  removeObsoletedPolicyLines(p_policy_id);

  open l_insert_cursor;
  open l_where_cursor;
  open l_not_exists_cursor;

  open l_l_cursor;
  open l_r_cursor;
  open l_c_cursor;
  open l_vc_cursor;
  open l_vt_cursor;
  open l_ft_cursor;
  open l_dt_cursor;

  fetch l_insert_cursor into l_insert_sql_stmt;
  fetch l_where_cursor into l_where_sql_stmt;
  fetch l_not_exists_cursor into l_not_exists_sql_stmt;

  fetch l_l_cursor into l_l_sql_stmt;
  fetch l_r_cursor into l_r_sql_stmt;
  fetch l_c_cursor into l_c_sql_stmt;
  fetch l_vc_cursor into l_vc_sql_stmt;
  fetch l_vt_cursor into l_vt_sql_stmt;
  fetch l_ft_cursor into l_ft_sql_stmt;
  fetch l_dt_cursor into l_dt_sql_stmt;

  --------------
  -- open cursor
  --------------
  l_permutate_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- begin loop thru all periods
  --------------
  open c_schedule_period_id;
  loop

  fetch c_schedule_period_id into l_schedule_period_id;
  exit when c_schedule_period_id%NOTFOUND;

  select count(policy_line_id)
  into   l_policy_line_count
  from   ap_pol_lines
  where  policy_id = p_policy_id
  and    schedule_period_id = l_schedule_period_id;

  if (l_policy_line_count = 0) then
    --------------
    -- parse cursor
    --------------
    DBMS_SQL.PARSE(l_permutate_curref,
                      l_insert_sql_stmt||
                      l_l_sql_stmt||
                      l_r_sql_stmt||
                      l_c_sql_stmt||
                      l_vc_sql_stmt||
                      l_vt_sql_stmt||
                      l_ft_sql_stmt||
                      l_dt_sql_stmt||
                      l_where_sql_stmt, DBMS_SQL.NATIVE);
  else
    --------------
    -- parse cursor
    --------------
    DBMS_SQL.PARSE(l_permutate_curref,
                      l_insert_sql_stmt||
                      l_l_sql_stmt||
                      l_r_sql_stmt||
                      l_c_sql_stmt||
                      l_vc_sql_stmt||
                      l_vt_sql_stmt||
                      l_ft_sql_stmt||
                      l_dt_sql_stmt||
                      l_not_exists_sql_stmt, DBMS_SQL.NATIVE);
    --------------
    -- supply binds specific to this case
    --------------
    DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':dummy_number', -11);
    DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':dummy_varchar2', '-11');

  end if;

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_policy_id', p_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_schedule_period_id', l_schedule_period_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_user_id', p_user_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_LOCATION', c_LOCATION);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_EMPLOYEE_ROLE', c_EMPLOYEE_ROLE);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_CURRENCY', c_CURRENCY);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_VEHICLE_CATEGORY', c_VEHICLE_CATEGORY);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_VEHICLE_TYPE', c_VEHICLE_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_FUEL_TYPE', c_FUEL_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_DISTANCE_THRESHOLD', c_DISTANCE_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_TIME_THRESHOLD', c_TIME_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_rate_type', l_rate_type_code);
  --------------
  -- execute cursor
  --------------
  l_rows_permutated := DBMS_SQL.EXECUTE(l_permutate_curref);

  end loop;
  close c_schedule_period_id;
  --------------
  -- end loop thru all periods
  --------------

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_permutate_curref);

  close l_insert_cursor;
  close l_where_cursor;
  close l_not_exists_cursor;

  close l_l_cursor;
  close l_r_cursor;
  close l_c_cursor;
  close l_vc_cursor;
  close l_vt_cursor;
  close l_ft_cursor;
  close l_dt_cursor;

  ----------------------------------------------------------------------
  -- Permutate First Period, Last Period and Same Day Rates if implemented
  ----------------------------------------------------------------------
  BEGIN

    FOR rate_type_cur in c_rate_types
    LOOP
       permutatePolicyLines(p_user_id,
                            p_policy_id,
                            rate_type_cur.rate_type_code);
    END LOOP;
  END;

  -------------------------------------------------------------------------------
  -- Insert addon mileage rate permutations if addon rates have been enabled
  -------------------------------------------------------------------------------
  IF ( l_addon_rates_enabled = 'Y' ) THEN
     permutateAddonRates(p_user_id,
                         p_policy_id,
                         l_schedule_period_id);
  END IF;

  -------------------------------------------------------------------------------
  -- Insert addon mileage rate permutations if addon rates have been enabled
  -------------------------------------------------------------------------------
  IF ( l_night_rates_enabled = 'Y' ) THEN
     permutateNightRates(p_user_id,
                         p_policy_id,
                         l_schedule_period_id);
  END IF;

  -- -----------------------------------------------------------------------
  -- If this is an allowance schedule set the calculation methods to AMOUNT
  -- -----------------------------------------------------------------------
  IF ( l_schedule_type = 'ALLOWANCE' ) THEN
     update ap_pol_lines
     set    calculation_method = 'AMOUNT',
            accommodation_calc_method = 'AMOUNT'
     where  policy_id = p_policy_id
     and    nvl(calculation_method, 'X') <> 'AMOUNT';
  END IF;

  updateInactivePolicyLines(p_policy_id);
  checkAirfarePolicyLines(p_policy_id);

  status_saved_sched_opts(p_policy_id);


EXCEPTION
 WHEN OTHERS THEN
  raise;
END permutatePolicyLines;


/*========================================================================
 | PUBLIC PROCEDURE removeObsoletedPolicyLines
 |
 | DESCRIPTION
 | - a policy line is obsolete if:
 |   1. if a rule has become disabled for an option already permutated
 |   2. if an option has been removed for an enabled rule
 |   3. if a new rule has been added then existing blank permutations becomes invalid
 |   4. if a new threshold has been added then existing threshold range becomes invalid
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
PROCEDURE removeObsoletedPolicyLines(p_policy_id  IN ap_pol_headers.policy_id%TYPE) IS

  l_obsolete_curref		INTEGER;
  l_rows_obsoleted		NUMBER := 0;

  l_obsolete_sql_stmt		VARCHAR2(4000);
  l_l_sql_stmt                  VARCHAR2(4000);
  l_r_sql_stmt                  VARCHAR2(4000);
  l_c_sql_stmt                  VARCHAR2(4000);
  l_vc_sql_stmt                 VARCHAR2(4000);
  l_vt_sql_stmt                 VARCHAR2(4000);
  l_ft_sql_stmt                 VARCHAR2(4000);
  l_dt_sql_stmt                 VARCHAR2(4000);
  l_amr_sql_stmt                VARCHAR2(4000);

  l_currency_preference		ap_pol_headers.currency_preference%TYPE;
  l_currency_code		ap_pol_headers.currency_code%TYPE;

cursor l_l_cursor is
select
'
  delete
  from   AP_POL_LINES pl
  where  pl.POLICY_ID = :p_policy_id
  and    ((pl.LOCATION_ID is not null
           and not exists
             (select pso.LOCATION_ID
              from   AP_POL_SCHEDULE_OPTIONS pso
              where  pso.POLICY_ID = pl.POLICY_ID
              and    pso.OPTION_TYPE = :c_LOCATION
              and    pso.LOCATION_ID is not null
              and    pso.LOCATION_ID = pl.LOCATION_ID
             )
          )
          or
          (pl.LOCATION_ID is null
           and exists
             (select pso.LOCATION_ID
              from   AP_POL_SCHEDULE_OPTIONS pso
              where  pso.POLICY_ID = pl.POLICY_ID
              and    pso.OPTION_TYPE = :c_LOCATION
              and    pso.LOCATION_ID is not null
             )
          )
'
from sys.dual; /* l_l_cursor */

cursor l_r_cursor is
select
'
         or
         (pl.ROLE_ID is not null
          and not exists
            (select pso.ROLE_ID
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_EMPLOYEE_ROLE
             and    pso.ROLE_ID is not null
             and    pso.ROLE_ID = pl.ROLE_ID
            )
         )
         or
         (pl.ROLE_ID is null
          and exists
            (select pso.ROLE_ID
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_EMPLOYEE_ROLE
             and    pso.ROLE_ID is not null
            )
         )
'
from sys.dual; /* l_r_cursor */

cursor l_c_cursor is
select
'
          or
          (pl.CURRENCY_CODE is not null
           and
           (not exists
             (select pso.CURRENCY_CODE
              from   AP_POL_SCHEDULE_OPTIONS pso
              where  pso.POLICY_ID = pl.POLICY_ID
              and    pso.OPTION_TYPE = :c_CURRENCY
              and    pso.CURRENCY_CODE is not null
              and    pso.CURRENCY_CODE = pl.CURRENCY_CODE
             )
            and
            not exists
             (select ph.CURRENCY_PREFERENCE
              from   AP_POL_HEADERS ph
              where  ph.POLICY_ID = pl.POLICY_ID
              and    (ph.CURRENCY_PREFERENCE = :c_SRC
                      or
                      ph.CURRENCY_PREFERENCE = :c_LCR
                     )
             )
           )
          )
          or
          (pl.CURRENCY_CODE is not null
           and
           exists
             (select ph.CURRENCY_PREFERENCE
              from   AP_POL_HEADERS ph
              where  ph.POLICY_ID = pl.POLICY_ID
              and    ph.CURRENCY_PREFERENCE = :c_SRC
             )
           and
           not exists
             (select ph.CURRENCY_CODE
              from   AP_POL_HEADERS ph
              where  ph.POLICY_ID = pl.POLICY_ID
              and    ph.CURRENCY_CODE = pl.CURRENCY_CODE
             )
          )
'
from sys.dual; /* l_c_cursor */

cursor l_vc_cursor is
select
'
          or
          (pl.VEHICLE_CATEGORY is not null
           and not exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
           )
          )
          or
          (pl.VEHICLE_CATEGORY is null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE is not null
           )
          )
'
from sys.dual; /* l_vc_cursor */

cursor l_vt_cursor is
select
'
          or
          (pl.VEHICLE_TYPE is not null
           and
           (not exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_TYPE
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.VEHICLE_TYPE
           )
           or exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
            and    pso.VEHICLE_TYPE_CODE <> ''R''
           ))
          )
          or
          (pl.VEHICLE_TYPE is null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_TYPE
            and    pso.OPTION_CODE is not null
           )
           and not exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
            and    pso.VEHICLE_TYPE_CODE <> ''R''
           )
          )
'
from sys.dual; /* l_vt_cursor */

cursor l_ft_cursor is
select
'
          or
          (pl.FUEL_TYPE is not null
           and
           (not exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_FUEL_TYPE
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.FUEL_TYPE
           )
           or exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
            and    pso.FUEL_TYPE_CODE <> ''R''
           ))
          )
          or
          (pl.FUEL_TYPE is null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_FUEL_TYPE
            and    pso.OPTION_CODE is not null
           )
           and not exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
            and    pso.FUEL_TYPE_CODE <> ''R''
           )
          )
'
from sys.dual; /* l_ft_cursor */

cursor l_dt_cursor is
select
'
          or
          (pl.RANGE_LOW is not null
           and not exists
           (select pso.THRESHOLD
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    (pso.OPTION_TYPE = :c_DISTANCE_THRESHOLD or pso.OPTION_TYPE = :c_TIME_THRESHOLD)
            and    pso.THRESHOLD is not null
            and    pso.THRESHOLD = pl.RANGE_LOW
            and    nvl(pso.rate_type_code, ''NULL'') = nvl(pl.rate_type_code, ''NULL'')
           )
          )
          or
          (pl.RANGE_HIGH is not null
           and not exists
           (select pso.THRESHOLD
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    (pso.OPTION_TYPE = :c_DISTANCE_THRESHOLD or pso.OPTION_TYPE = :c_TIME_THRESHOLD)
            and    pso.THRESHOLD is not null
            and    pso.THRESHOLD = pl.RANGE_HIGH
            and    nvl(pso.rate_type_code, ''NULL'') = nvl(pl.rate_type_code, ''NULL'')
           )
          )
          or
          (pl.RANGE_LOW is null
           and exists
           (select pso.THRESHOLD
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    (pso.OPTION_TYPE = :c_DISTANCE_THRESHOLD or pso.OPTION_TYPE = :c_TIME_THRESHOLD)
            and    pso.THRESHOLD is not null
            and    nvl(pso.rate_type_code, ''NULL'') = nvl(pl.rate_type_code, ''NULL'')
           )
          )
          or
          (pl.RANGE_LOW is not null
           and
           nvl(pl.RANGE_HIGH, :dummy_number) <>
                 nvl(AP_WEB_POLICY_UTILS.getHighEndOfThreshold(pl.POLICY_ID,
                                                               pl.RANGE_LOW,
                                                               nvl(pl.rate_type_code,''STANDARD'')), :dummy_number)
          )
'
from sys.dual; /* l_dt_cursor */

---------------------------------------
-- cursor for addon mileage rates
-- Note: we do not need to remove any addon rate lines
-- for the case of new addon rate rule since these lines
-- would never have existed.
---------------------------------------
cursor l_amr_cursor is
select
'       or
        (pl.ADDON_MILEAGE_RATE_CODE is not null
           and not exists
             (select pso.OPTION_CODE
              from   AP_POL_SCHEDULE_OPTIONS pso
              where  pso.POLICY_ID = pl.POLICY_ID
              and    pso.OPTION_TYPE = :c_ADDON_RATES
              and    pso.OPTION_CODE is not null
              and    pso.OPTION_CODE = pl.ADDON_MILEAGE_RATE_CODE
             )
          )

       )
'
from sys.dual; /* l_amr_cursor */


BEGIN

  open l_l_cursor;
  open l_r_cursor;
  open l_c_cursor;
  open l_vc_cursor;
  open l_vt_cursor;
  open l_ft_cursor;
  open l_dt_cursor;
  open l_amr_cursor;

  fetch l_l_cursor into l_l_sql_stmt;
  fetch l_r_cursor into l_r_sql_stmt;
  fetch l_c_cursor into l_c_sql_stmt;
  fetch l_vc_cursor into l_vc_sql_stmt;
  fetch l_vt_cursor into l_vt_sql_stmt;
  fetch l_ft_cursor into l_ft_sql_stmt;
  fetch l_dt_cursor into l_dt_sql_stmt;
  fetch l_amr_cursor into l_amr_sql_stmt;


  --------------
  -- open cursor
  --------------
  l_obsolete_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- parse cursor
  --------------
  DBMS_SQL.PARSE(l_obsolete_curref,
                 l_l_sql_stmt||
                 l_r_sql_stmt||
                 l_c_sql_stmt||
                 l_vc_sql_stmt||
                 l_vt_sql_stmt||
                 l_ft_sql_stmt||
                 l_dt_sql_stmt||
                 l_amr_sql_stmt,
                 DBMS_SQL.NATIVE);

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':p_policy_id', p_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_LOCATION', c_LOCATION);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_EMPLOYEE_ROLE', c_EMPLOYEE_ROLE);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_CURRENCY', c_CURRENCY);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_LCR', c_LCR);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_SRC', c_SRC);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_VEHICLE_CATEGORY', c_VEHICLE_CATEGORY);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_VEHICLE_TYPE', c_VEHICLE_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_FUEL_TYPE', c_FUEL_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_DISTANCE_THRESHOLD', c_DISTANCE_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_TIME_THRESHOLD', c_TIME_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':c_ADDON_RATES', c_ADDON_RATES);
  DBMS_SQL.BIND_VARIABLE(l_obsolete_curref, ':dummy_number', -11);

  --------------
  -- execute cursor
  --------------
  l_rows_obsoleted := DBMS_SQL.EXECUTE(l_obsolete_curref);

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_obsolete_curref);


  close l_l_cursor;
  close l_r_cursor;
  close l_c_cursor;
  close l_vc_cursor;
  close l_vt_cursor;
  close l_ft_cursor;
  close l_dt_cursor;
  close l_amr_cursor;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END removeObsoletedPolicyLines;


/*========================================================================
 | PUBLIC PROCEDURE updateInactivePolicyLines
 |
 | DESCRIPTION
 | - if option end dated then set Policy Line status to inactive
 | - reactivate inactive lines if end date updated
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
PROCEDURE updateInactivePolicyLines(p_policy_id  IN ap_pol_headers.policy_id%TYPE) IS

  l_inactive_curref		INTEGER;
  l_rows_inactivated		NUMBER := 0;

  l_active_curref		INTEGER;
  l_rows_activated		NUMBER := 0;

  l_inactive_sql_stmt		VARCHAR2(4000);
  l_active_sql_stmt		VARCHAR2(4000);


cursor l_inactive_cursor is
select
'
  update AP_POL_LINES pl
  set    pl.STATUS = :c_INACTIVE
  where  pl.POLICY_ID = :p_policy_id
  and    pl.STATUS = :c_ACTIVE
  and    ((pl.LOCATION_ID is not null
           and exists
           (select pso.LOCATION_ID
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_LOCATION
            and    pso.LOCATION_ID is not null
            and    pso.LOCATION_ID = pl.LOCATION_ID
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.ROLE_ID is not null
           and exists
           (select pso.ROLE_ID
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_EMPLOYEE_ROLE
            and    pso.ROLE_ID is not null
            and    pso.ROLE_ID = pl.ROLE_ID
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.CURRENCY_CODE is not null
           and exists
           (select pso.CURRENCY_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_CURRENCY
            and    pso.CURRENCY_CODE is not null
            and    pso.CURRENCY_CODE = pl.CURRENCY_CODE
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.VEHICLE_CATEGORY is not null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.VEHICLE_TYPE is not null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_VEHICLE_TYPE
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.VEHICLE_TYPE
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.FUEL_TYPE is not null
           and exists
           (select pso.OPTION_CODE
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    pso.OPTION_TYPE = :c_FUEL_TYPE
            and    pso.OPTION_CODE is not null
            and    pso.OPTION_CODE = pl.FUEL_TYPE
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
          or
          (pl.RANGE_LOW is not null
           and exists
           (select pso.THRESHOLD
            from   AP_POL_SCHEDULE_OPTIONS pso
            where  pso.POLICY_ID = pl.POLICY_ID
            and    (pso.OPTION_TYPE = :c_DISTANCE_THRESHOLD or pso.OPTION_TYPE = :c_TIME_THRESHOLD)
            and    pso.THRESHOLD is not null
            and    pso.THRESHOLD = pl.RANGE_LOW
            and    nvl(pso.END_DATE, SYSDATE+1) < SYSDATE
           )
          )
         )
'
from sys.dual; /* l_inactive_cursor */


cursor l_active_cursor is
select
'
  update AP_POL_LINES pl
  set    pl.STATUS = :c_ACTIVE
  where  pl.POLICY_ID = :p_policy_id
  and    pl.STATUS = :c_INACTIVE
  and    (((pl.LOCATION_ID is not null
            and exists
            (select pso.LOCATION_ID
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_LOCATION
             and    pso.LOCATION_ID is not null
             and    pso.LOCATION_ID = pl.LOCATION_ID
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            )
           ) or pl.LOCATION_ID is null
          )
          and
          ((pl.ROLE_ID is not null
            and exists
            (select pso.ROLE_ID
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_EMPLOYEE_ROLE
             and    pso.ROLE_ID is not null
             and    pso.ROLE_ID = pl.ROLE_ID
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            )
           ) or pl.ROLE_ID is null
          )
          and
          ((pl.CURRENCY_CODE is not null
            and
            (exists
              (select pso.CURRENCY_CODE
               from   AP_POL_SCHEDULE_OPTIONS pso
               where  pso.POLICY_ID = pl.POLICY_ID
               and    pso.OPTION_TYPE = :c_CURRENCY
               and    pso.CURRENCY_CODE is not null
               and    pso.CURRENCY_CODE = pl.CURRENCY_CODE
               and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
              )
             or exists
              (select ph.CURRENCY_CODE
               from   AP_POL_HEADERS ph
               where  ph.POLICY_ID = pl.POLICY_ID
               and    ((ph.CURRENCY_CODE is not null and ph.CURRENCY_CODE = pl.CURRENCY_CODE)
                      or
                       (ph.CURRENCY_CODE is null and ph.CURRENCY_PREFERENCE <> :c_SRC)))
            )
           )
           or pl.CURRENCY_CODE is null
          )
          and
          ((pl.VEHICLE_CATEGORY is not null
            and exists
            (select pso.OPTION_CODE
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_VEHICLE_CATEGORY
             and    pso.OPTION_CODE is not null
             and    pso.OPTION_CODE = pl.VEHICLE_CATEGORY
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            )
           ) or pl.VEHICLE_CATEGORY is null
          )
          and
          ((pl.VEHICLE_TYPE is not null
            and exists
            (select pso.OPTION_CODE
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_VEHICLE_TYPE
             and    pso.OPTION_CODE is not null
             and    pso.OPTION_CODE = pl.VEHICLE_TYPE
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            ) or pl.VEHICLE_TYPE is null
           )
          )
          and
          ((pl.FUEL_TYPE is not null
            and exists
            (select pso.OPTION_CODE
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    pso.OPTION_TYPE = :c_FUEL_TYPE
             and    pso.OPTION_CODE is not null
             and    pso.OPTION_CODE = pl.FUEL_TYPE
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            )
           ) or pl.FUEL_TYPE is null
          )
          and
          ((pl.RANGE_LOW is not null
            and exists
            (select pso.THRESHOLD
             from   AP_POL_SCHEDULE_OPTIONS pso
             where  pso.POLICY_ID = pl.POLICY_ID
             and    (pso.OPTION_TYPE = :c_DISTANCE_THRESHOLD or pso.OPTION_TYPE = :c_TIME_THRESHOLD)
             and    pso.THRESHOLD is not null
             and    pso.THRESHOLD = pl.RANGE_LOW
             and    nvl(pso.END_DATE, SYSDATE+1) > SYSDATE
            )
           ) or pl.RANGE_LOW is null
          )
         )
'
from sys.dual; /* l_active_cursor */

BEGIN

  --------------------------------------------------------------
  -- if option end dated then set Policy Line status to inactive
  --------------------------------------------------------------
  open l_inactive_cursor;
  fetch l_inactive_cursor into l_inactive_sql_stmt;

  --------------
  -- open cursor
  --------------
  l_inactive_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- parse cursor
  --------------
  DBMS_SQL.PARSE(l_inactive_curref,
                 l_inactive_sql_stmt,
                 DBMS_SQL.NATIVE);

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':p_policy_id', p_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_INACTIVE', c_INACTIVE);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_ACTIVE', c_ACTIVE);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_LOCATION', c_LOCATION);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_EMPLOYEE_ROLE', c_EMPLOYEE_ROLE);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_CURRENCY', c_CURRENCY);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_VEHICLE_CATEGORY', c_VEHICLE_CATEGORY);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_VEHICLE_TYPE', c_VEHICLE_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_FUEL_TYPE', c_FUEL_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_DISTANCE_THRESHOLD', c_DISTANCE_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_inactive_curref, ':c_TIME_THRESHOLD', c_TIME_THRESHOLD);

  --------------
  -- execute cursor
  --------------
  l_rows_inactivated := DBMS_SQL.EXECUTE(l_inactive_curref);

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_inactive_curref);

  close l_inactive_cursor;


  --------------------------------------------------------------
  -- reactivate inactive lines if end date updated
  --------------------------------------------------------------
  open l_active_cursor;
  fetch l_active_cursor into l_active_sql_stmt;

  --------------
  -- open cursor
  --------------
  l_active_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- parse cursor
  --------------
  DBMS_SQL.PARSE(l_active_curref,
                 l_active_sql_stmt,
                 DBMS_SQL.NATIVE);

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':p_policy_id', p_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_INACTIVE', c_INACTIVE);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_ACTIVE', c_ACTIVE);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_LOCATION', c_LOCATION);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_EMPLOYEE_ROLE', c_EMPLOYEE_ROLE);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_CURRENCY', c_CURRENCY);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_SRC', c_SRC);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_VEHICLE_CATEGORY', c_VEHICLE_CATEGORY);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_VEHICLE_TYPE', c_VEHICLE_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_FUEL_TYPE', c_FUEL_TYPE);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_DISTANCE_THRESHOLD', c_DISTANCE_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_active_curref, ':c_TIME_THRESHOLD', c_TIME_THRESHOLD);

  --------------
  -- execute cursor
  --------------
  l_rows_activated := DBMS_SQL.EXECUTE(l_active_curref);

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_active_curref);

  close l_active_cursor;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END updateInactivePolicyLines;


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
                               p_to_schedule_period_id  IN ap_pol_schedule_periods.schedule_period_id%TYPE) IS

  l_duplicate_curref		INTEGER;
  l_rows_duplicated		NUMBER := 0;

  l_duplicate_sql_stmt		VARCHAR2(4000);

cursor l_duplicate_cursor is
select
'
  insert into AP_POL_LINES
        (
         POLICY_LINE_ID,
         POLICY_ID,
         SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         VEHICLE_CATEGORY,
         VEHICLE_TYPE,
         FUEL_TYPE,
         RANGE_LOW,
         RANGE_HIGH,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         START_OF_SEASON,
         END_OF_SEASON,
         MAX_LODGING_AMT,
         NO_GOVT_MEALS_AMT,
         PROP_MEALS_AMT,
         OFF_BASE_INC_AMT,
         FOOTNOTE_AMT,
         FOOTNOTE_RATE_AMT,
         MAX_PER_DIEM_AMT,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE,
         STATUS,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
         :p_to_policy_id AS POLICY_ID,
         :p_to_schedule_period_id AS SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         VEHICLE_CATEGORY,
         VEHICLE_TYPE,
         FUEL_TYPE,
         RANGE_LOW,
         RANGE_HIGH,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         START_OF_SEASON,
         END_OF_SEASON,
         MAX_LODGING_AMT,
         NO_GOVT_MEALS_AMT,
         PROP_MEALS_AMT,
         OFF_BASE_INC_AMT,
         FOOTNOTE_AMT,
         FOOTNOTE_RATE_AMT,
         MAX_PER_DIEM_AMT,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE,
         decode(status, ''ACTIVE'', ''VALID'', ''VALID'', ''VALID'', :c_DUPLICATED) AS STATUS,
         sysdate AS CREATION_DATE,
         :p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         :p_user_id AS LAST_UPDATED_BY
  from
         AP_POL_LINES
  where  POLICY_ID = :p_from_policy_id
  and    SCHEDULE_PERIOD_ID = :p_from_schedule_period_id
  and    PARENT_LINE_ID is null
'
from sys.dual; /* l_duplicate_cursor */


BEGIN

  open l_duplicate_cursor;
  fetch l_duplicate_cursor into l_duplicate_sql_stmt;

  --------------
  -- open cursor
  --------------
  l_duplicate_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- parse cursor
  --------------
  DBMS_SQL.PARSE(l_duplicate_curref,
                 l_duplicate_sql_stmt,
                 DBMS_SQL.NATIVE);

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':p_from_policy_id', p_from_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':p_from_schedule_period_id', p_from_schedule_period_id);
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':p_to_policy_id', p_to_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':p_to_schedule_period_id', p_to_schedule_period_id);
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':p_user_id', p_user_id);
  DBMS_SQL.BIND_VARIABLE(l_duplicate_curref, ':c_DUPLICATED', c_DUPLICATED);

  --------------
  -- execute cursor
  --------------
  l_rows_duplicated := DBMS_SQL.EXECUTE(l_duplicate_curref);

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_duplicate_curref);

  close l_duplicate_cursor;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END duplicatePolicyLines;



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
                             p_policy_line_id  IN ap_pol_lines.policy_line_id%TYPE) IS

  l_preserve_count 	NUMBER := 0;

BEGIN

  ---------------------------------------
  -- sanity check if modified Active policy
  -- line is already preserved
  ---------------------------------------
  select count(*)
  into   l_preserve_count
  from   AP_POL_LINES
  where  parent_line_id = p_policy_line_id
  and    policy_id = p_policy_id
  and    schedule_period_id = p_schedule_period_id;

  if (l_preserve_count > 0) then
    return;
  end if;

  ---------------------------------------
  -- preserve modified Active policy line
  ---------------------------------------
  insert into AP_POL_LINES
        (
         PARENT_LINE_ID,
         POLICY_LINE_ID,
         POLICY_ID,
         SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         VEHICLE_CATEGORY,
         VEHICLE_TYPE,
         FUEL_TYPE,
         RANGE_LOW,
         RANGE_HIGH,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         STATUS,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         p_policy_line_id AS PARENT_LINE_ID,
         AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
         p_policy_id AS POLICY_ID,
         p_schedule_period_id AS SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         VEHICLE_CATEGORY,
         VEHICLE_TYPE,
         FUEL_TYPE,
         RANGE_LOW,
         RANGE_HIGH,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         STATUS,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
  from
         AP_POL_LINES
  where  POLICY_ID = p_policy_id
  and    SCHEDULE_PERIOD_ID = p_schedule_period_id
  and    POLICY_LINE_ID = p_policy_line_id;


EXCEPTION
 WHEN OTHERS THEN
  raise;
END preservePolicyLine;


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
                                      p_policy_id  IN ap_pol_lines.policy_id%TYPE) IS

BEGIN

  ---------------------------------------
  -- archive preserved Active policy lines
  ---------------------------------------
  insert into AP_POL_LINES_HISTORY
        (
         POLICY_LINE_HISTORY_ID,
         POLICY_LINE_ID,
         SCHEDULE_PERIOD_ID,
         --CURRENCY_CODE, -- need to add CURRENCY_CODE to AP_POL_LINES_HISTORY because of LCR
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         AP_POL_LINES_HISTORY_S.NEXTVAL AS POLICY_LINE_HISTORY_ID,
         PARENT_LINE_ID AS POLICY_LINE_ID,
         SCHEDULE_PERIOD_ID,
         --CURRENCY_CODE,
         MEAL_LIMIT,
         RATE,
         TOLERANCE,
         TICKET_CLASS_DOMESTIC,
         TICKET_CLASS_INTERNATIONAL,
         CALCULATION_METHOD,
         MEALS_DEDUCTION,
         BREAKFAST_DEDUCTION,
         LUNCH_DEDUCTION,
         DINNER_DEDUCTION,
         ACCOMMODATION_ADJUSTMENT,
         ADDON_MILEAGE_RATE_CODE,
         RATE_PER_PASSENGER,
         RATE_TYPE_CODE,
         ONE_MEAL_DEDUCTION_AMT,
         TWO_MEALS_DEDUCTION_AMT,
         THREE_MEALS_DEDUCTION_AMT,
         NIGHT_RATE_TYPE_CODE,
         ACCOMMODATION_CALC_METHOD,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
  from
         AP_POL_LINES
  where  POLICY_ID = p_policy_id
  and    PARENT_LINE_ID is not null;

  ---------------------------------------
  -- remove preserved Active Policy Lines
  ---------------------------------------
  delete
  from
         AP_POL_LINES
  where  POLICY_ID = p_policy_id
  and    PARENT_LINE_ID is not null;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END archivePreservedPolicyLines;


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
                              p_end_date  IN ap_pol_schedule_periods.end_date%TYPE,
                              p_rate_per_passenger  IN ap_pol_schedule_periods.rate_per_passenger%TYPE,
                              p_min_days  IN ap_pol_schedule_periods.min_days%TYPE,
                              p_tolerance  IN ap_pol_schedule_periods.tolerance%TYPE,
                              p_min_rate_per_period  IN ap_pol_schedule_periods.min_rate_per_period%TYPE,
                              p_max_breakfast_deduction IN ap_pol_schedule_periods.max_breakfast_deduction_amt%TYPE,
                              p_max_lunch_deduction  IN ap_pol_schedule_periods.max_lunch_deduction_amt%TYPE,
                              p_max_dinner_deduction IN ap_pol_schedule_periods.max_dinner_deduction_amt%TYPE,
                              p_first_day_rate IN ap_pol_schedule_periods.first_day_rate%TYPE,
                              p_last_day_rate IN ap_pol_schedule_periods.last_day_rate%TYPE) RETURN ap_pol_schedule_periods.schedule_period_id%TYPE IS

  l_schedule_period_id			ap_pol_schedule_periods.schedule_period_id%TYPE;

BEGIN

  select AP_POL_SCHEDULE_PERIODS_S.NEXTVAL
  into   l_schedule_period_id
  from   sys.dual;

  insert into AP_POL_SCHEDULE_PERIODS
        (
         SCHEDULE_PERIOD_ID,
         SCHEDULE_PERIOD_NAME,
         POLICY_ID,
         START_DATE,
         END_DATE,
         RATE_PER_PASSENGER,
         MIN_DAYS,
         TOLERANCE,
         MIN_RATE_PER_PERIOD,
         MAX_BREAKFAST_DEDUCTION_AMT,
         MAX_LUNCH_DEDUCTION_AMT,
         MAX_DINNER_DEDUCTION_AMT,
         FIRST_DAY_RATE,
         LAST_DAY_RATE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         l_schedule_period_id AS SCHEDULE_PERIOD_ID,
         decode(p_schedule_period_name, null, fnd_message.GET_STRING('SQLAP','OIE_POL_PERIODS_NEW_PERIOD'), substrb(fnd_message.GET_STRING('SQLAP','OIE_POL_COPY_OF')||' '||p_schedule_period_name, 1, C_PolicyNameMaxLength)) AS SCHEDULE_PERIOD_NAME,
         p_policy_id AS POLICY_ID,
         p_start_date AS START_DATE,
         p_end_date AS END_DATE,
         p_rate_per_passenger AS RATE_PER_PASSENGER,
         p_min_days AS MIN_DAYS,
         p_tolerance AS TOLERANCE,
         p_min_rate_per_period as MIN_RATE_PER_PERIOD,
         p_max_breakfast_deduction as MAX_BREAKFAST_DEDUCTION,
         p_max_lunch_deduction as MAX_LUNCH_DEDUCTION,
         p_max_dinner_deduction as MAX_DINNER_DEDUCTION,
         p_first_day_rate as FIRST_DAY_RATE,
         p_last_day_rate as LAST_DAY_RATE,
         sysdate AS CREATION_DATE,
         p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         p_user_id AS LAST_UPDATED_BY
  from
         sys.dual;

  return l_schedule_period_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END createSchedulePeriod;


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
                         p_rounding_rule     IN VARCHAR2) RETURN NUMBER IS

  l_new_value 		NUMBER := 0;

BEGIN

  select decode(p_rounding_rule,
                '1_DECIMALS', nvl(p_value, 0) + ROUND(nvl(p_value, 0) * (p_update_by/100), 1),
                '2_DECIMALS', nvl(p_value, 0) + ROUND(nvl(p_value, 0) * (p_update_by/100), 2),
                '3_DECIMALS', nvl(p_value, 0) + ROUND(nvl(p_value, 0) * (p_update_by/100), 3),
                              nvl(p_value, 0) + ROUND(nvl(p_value, 0) * (p_update_by/100)))
  into   l_new_value
  from   sys.dual;

  if (p_rounding_rule = c_NEAREST_FIVE) then
    if (mod(l_new_value, 5) >= 2.5) then
      l_new_value := l_new_value - mod(l_new_value, 5) + 5;
    else
      l_new_value := l_new_value - mod(l_new_value, 5);
    end if;
  end if;
  if (p_rounding_rule = c_NEAREST_TEN) then
    if (mod(l_new_value, 10) >= 5) then
      l_new_value := l_new_value - mod(l_new_value, 10) + 10;
    else
      l_new_value := l_new_value - mod(l_new_value, 10);
    end if;
  end if;

  return l_new_value;

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END massUpdateValue;

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
 | 09-Mar-2004           sasaxena          Bug 2847928: clear out schedule end
 |                                         date when a schedule is duplicated.
 |
 *=======================================================================*/
PROCEDURE duplicatePolicy(p_user_id IN NUMBER,
                          p_from_policy_id  IN  ap_pol_headers.policy_id%TYPE,
                          p_new_policy_id   OUT NOCOPY ap_pol_headers.policy_id%TYPE) IS

  l_duplicate_header_sql_stmt           VARCHAR2(4000);
  l_duplicate_options_sql_stmt          VARCHAR2(4000);

  l_from_policy_id			ap_pol_headers.policy_id%TYPE;
  l_to_policy_id			ap_pol_headers.policy_id%TYPE;

  l_from_schedule_period_id		ap_pol_schedule_periods.schedule_period_id%TYPE;
  l_to_schedule_period_id		ap_pol_schedule_periods.schedule_period_id%TYPE;

  l_schedule_period_name		ap_pol_schedule_periods.schedule_period_name%TYPE;
  l_start_date				ap_pol_schedule_periods.start_date%TYPE;
  l_end_date				ap_pol_schedule_periods.end_date%TYPE;
  l_rate_per_passenger			ap_pol_schedule_periods.rate_per_passenger%TYPE;
  l_min_days				ap_pol_schedule_periods.min_days%TYPE;
  l_tolerance				ap_pol_schedule_periods.tolerance%TYPE;
  l_min_rate_per_period     ap_pol_schedule_periods.min_rate_per_period%TYPE;
  l_max_breakfast_deduction ap_pol_schedule_periods.max_breakfast_deduction_amt%TYPE;
  l_max_lunch_deduction     ap_pol_schedule_periods.max_lunch_deduction_amt%TYPE;
  l_max_dinner_deduction    ap_pol_schedule_periods.max_dinner_deduction_amt%TYPE;
  l_first_day_rate          ap_pol_schedule_periods.first_day_rate%TYPE;
  l_last_day_rate           ap_pol_schedule_periods.last_day_rate%TYPE;

cursor l_duplicate_periods_cursor
is
  select
         SCHEDULE_PERIOD_ID,
         SCHEDULE_PERIOD_NAME,
         START_DATE,
         END_DATE,
         RATE_PER_PASSENGER,
         MIN_DAYS,
         TOLERANCE,
         MIN_RATE_PER_PERIOD,
         MAX_BREAKFAST_DEDUCTION_AMT,
         MAX_LUNCH_DEDUCTION_AMT,
         MAX_DINNER_DEDUCTION_AMT,
         FIRST_DAY_RATE,
         LAST_DAY_RATE
  from   AP_POL_SCHEDULE_PERIODS
  where  POLICY_ID = p_from_policy_id; /* l_duplicate_periods_cursor */



  PROCEDURE duplicatePolicyHeader(p_user_id IN NUMBER,
                                  p_from_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                  p_to_policy_id  OUT NOCOPY ap_pol_headers.policy_id%TYPE) IS

  BEGIN

    select AP_POL_HEADERS_S.NEXTVAL
    into   p_to_policy_id
    from   sys.dual;


    insert into AP_POL_HEADERS
          (
           POLICY_ID,
           CATEGORY_CODE,
           POLICY_NAME,
           DESCRIPTION,
           CURRENCY_CODE,
           BUSINESS_GROUP_ID,
           JOB_GROUP_ID,
           ROLE_CODE,
           DISTANCE_UOM,
           CURRENCY_PREFERENCE,
           ALLOW_RATE_CONVERSION_CODE,
           DAILY_LIMITS_CODE,
           START_DATE,
           END_DATE,
           DISTANCE_THRESHOLDS_FLAG,
           VEHICLE_CATEGORY_FLAG,
           VEHICLE_TYPE_FLAG,
           FUEL_TYPE_FLAG,
           PASSENGERS_FLAG,
           EMPLOYEE_ROLE_FLAG,
           TIME_BASED_ENTRY_FLAG,
           FREE_MEALS_FLAG,
           FREE_ACCOMMODATIONS_FLAG,
           TOLERANCE_LIMITS_FLAG,
           DAILY_LIMITS_FLAG,
           LOCATION_FLAG,
           TOLERANCE_LIMIT_CODE,
           FREE_MEALS_CODE,
           FREE_ACCOMMODATIONS_CODE,
           DAY_PERIOD_CODE,
           ADDON_MILEAGE_RATES_FLAG,
           SCHEDULE_TYPE_CODE,
           MIN_TRIP_DURATION,
           SAME_DAY_RATE_CODE,
           NIGHT_RATES_CODE,
           NIGHT_RATE_ELIGIBILITY,
           NIGHT_RATE_START_TIME,
           NIGHT_RATE_END_TIME,
           MULTI_DEST_RULE_CODE,
           MULTI_DEST_START_TIME,
           MULTI_DEST_END_TIME,
           PER_DIEM_TYPE_CODE,
           SOURCE,
           RATE_PERIOD_TYPE_CODE,
           MEALS_TYPE_CODE,
           ALLOWANCE_TIME_RULE_CODE,
           BREAKFAST_START_TIME,
           BREAKFAST_END_TIME,
           LUNCH_START_TIME,
           LUNCH_END_TIME,
           DINNER_START_TIME,
           DINNER_END_TIME,
           USE_MAX_DEST_RATE_FLAG,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
    select
           p_to_policy_id AS POLICY_ID,
           CATEGORY_CODE,
           substrb(fnd_message.GET_STRING('SQLAP','OIE_POL_COPY_OF')||' '||POLICY_NAME, 1, C_PolicyNameMaxLength) AS POLICY_NAME,
           DESCRIPTION,
           CURRENCY_CODE,
           BUSINESS_GROUP_ID,
           JOB_GROUP_ID,
           ROLE_CODE,
           DISTANCE_UOM,
           CURRENCY_PREFERENCE,
           ALLOW_RATE_CONVERSION_CODE,
           DAILY_LIMITS_CODE,
           START_DATE,
           null, -- Bug 2847928
           DISTANCE_THRESHOLDS_FLAG,
           VEHICLE_CATEGORY_FLAG,
           VEHICLE_TYPE_FLAG,
           FUEL_TYPE_FLAG,
           PASSENGERS_FLAG,
           EMPLOYEE_ROLE_FLAG,
           TIME_BASED_ENTRY_FLAG,
           FREE_MEALS_FLAG,
           FREE_ACCOMMODATIONS_FLAG,
           TOLERANCE_LIMITS_FLAG,
           DAILY_LIMITS_FLAG,
           LOCATION_FLAG,
           TOLERANCE_LIMIT_CODE,
           FREE_MEALS_CODE,
           FREE_ACCOMMODATIONS_CODE,
           DAY_PERIOD_CODE,
           ADDON_MILEAGE_RATES_FLAG,
           SCHEDULE_TYPE_CODE,
           MIN_TRIP_DURATION,
           SAME_DAY_RATE_CODE,
           NIGHT_RATES_CODE,
           NIGHT_RATE_ELIGIBILITY,
           NIGHT_RATE_START_TIME,
           NIGHT_RATE_END_TIME,
           MULTI_DEST_RULE_CODE,
           MULTI_DEST_START_TIME,
           MULTI_DEST_END_TIME,
           PER_DIEM_TYPE_CODE,
           SOURCE,
           RATE_PERIOD_TYPE_CODE,
           MEALS_TYPE_CODE,
           ALLOWANCE_TIME_RULE_CODE,
           BREAKFAST_START_TIME,
           BREAKFAST_END_TIME,
           LUNCH_START_TIME,
           LUNCH_END_TIME,
           DINNER_START_TIME,
           DINNER_END_TIME,
           USE_MAX_DEST_RATE_FLAG,
           sysdate AS CREATION_DATE,
           p_user_id AS CREATED_BY,
           null AS LAST_UPDATE_LOGIN,
           sysdate AS LAST_UPDATE_DATE,
           p_user_id AS LAST_UPDATED_BY
    from
           AP_POL_HEADERS
    where  POLICY_ID = p_from_policy_id;

  EXCEPTION
   WHEN OTHERS THEN
    raise;
  END duplicatePolicyHeader;


  PROCEDURE duplicatePolicyScheduleOptions(p_user_id IN NUMBER,
                                           p_from_policy_id  IN ap_pol_headers.policy_id%TYPE,
                                           p_to_policy_id  IN ap_pol_headers.policy_id%TYPE) IS

  BEGIN

    insert into AP_POL_SCHEDULE_OPTIONS
          (
           SCHEDULE_OPTION_ID,
           POLICY_ID,
           OPTION_TYPE,
           OPTION_CODE,
           THRESHOLD,
           ROLE_ID,
           LOCATION_ID,
           CURRENCY_CODE,
           END_DATE,
           VEHICLE_TYPE_CODE,
           FUEL_TYPE_CODE,
           RATE_TYPE_CODE,
           STATUS,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
    select
           AP_POL_SCHEDULE_OPTIONS_S.NEXTVAL AS SCHEDULE_OPTION_ID,
           p_to_policy_id AS POLICY_ID,
           OPTION_TYPE,
           OPTION_CODE,
           THRESHOLD,
           ROLE_ID,
           LOCATION_ID,
           CURRENCY_CODE,
           END_DATE,
           VEHICLE_TYPE_CODE,
           FUEL_TYPE_CODE,
           RATE_TYPE_CODE,
           STATUS,
           sysdate AS CREATION_DATE,
           p_user_id AS CREATED_BY,
           null AS LAST_UPDATE_LOGIN,
           sysdate AS LAST_UPDATE_DATE,
           p_user_id AS LAST_UPDATED_BY
    from
           AP_POL_SCHEDULE_OPTIONS
    where  POLICY_ID = p_from_policy_id;

  EXCEPTION
   WHEN OTHERS THEN
    raise;
  END duplicatePolicyScheduleOptions;


BEGIN

  l_from_policy_id := p_from_policy_id;

  duplicatePolicyHeader(p_user_id => p_user_id,
                        p_from_policy_id => l_from_policy_id,
                        p_to_policy_id => l_to_policy_id);

  duplicatePolicyScheduleOptions(p_user_id => p_user_id,
                                 p_from_policy_id => l_from_policy_id,
                                 p_to_policy_id => l_to_policy_id);


  open l_duplicate_periods_cursor;
  loop
    fetch l_duplicate_periods_cursor into
                           l_from_schedule_period_id,
                           l_schedule_period_name,
                           l_start_date,
                           l_end_date,
                           l_rate_per_passenger,
                           l_min_days,
                           l_tolerance,
                           l_min_rate_per_period,
                           l_max_breakfast_deduction,
                           l_max_lunch_deduction,
                           l_max_dinner_deduction,
                           l_first_day_rate,
                           l_last_day_rate;

    exit when l_duplicate_periods_cursor%NOTFOUND;

    l_to_schedule_period_id := createSchedulePeriod(p_user_id => p_user_id,
                                                    p_policy_id => l_to_policy_id,
                                                    p_schedule_period_name => l_schedule_period_name,
                                                    p_start_date => l_start_date,
                                                    p_end_date => l_end_date,
                                                    p_rate_per_passenger => l_rate_per_passenger,
                                                    p_min_days => l_min_days,
                                                    p_tolerance => l_tolerance,
                                                    p_min_rate_per_period => l_min_rate_per_period,
                                                    p_max_breakfast_deduction => l_max_breakfast_deduction,
                                                    p_max_lunch_deduction => l_max_lunch_deduction,
                                                    p_max_dinner_deduction => l_max_dinner_deduction,
                                                    p_first_day_rate => l_first_day_rate,
                                                    p_last_day_rate => l_last_day_rate);

    duplicatePolicyLines(p_user_id => p_user_id,
                         p_from_policy_id => l_from_policy_id,
                         p_from_schedule_period_id => l_from_schedule_period_id,
                         p_to_policy_id => l_to_policy_id,
                         p_to_schedule_period_id => l_to_schedule_period_id);


  end loop;
  close l_duplicate_periods_cursor;

  p_new_policy_id := l_to_policy_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;
END duplicatePolicy;


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
                              p_end_date      IN DATE) RETURN VARCHAR2 IS
  CURSOR active_cur IS
    select schedule_option_id
    from ap_pol_schedule_options
    where option_type   = p_option_type
    and   NVL(option_code,9.99E125)      =  NVL(p_option_code,9.99E125)
    and   NVL(threshold,9.99E125)        =  NVL(p_threshold,9.99E125)
    and   NVL(role_id,9.99E125)          =  NVL(p_role_id,9.99E125)
    and   NVL(location_id,9.99E125)      =  NVL(p_location_id,9.99E125)
    and   NVL(currency_code,chr(0))      =  NVL(p_currency_code, chr(0))
    and   NVL(end_date,TO_DATE('1','j')) >= DECODE(p_end_date,
                                                   null, TO_DATE('1','j'),
                                                   DECODE(end_date,
                                                          null, TO_DATE('1','j'),
                                                          p_end_date));


  active_rec active_cur%ROWTYPE;

BEGIN
  OPEN active_cur;
  FETCH active_cur INTO active_rec;
  IF active_cur%FOUND THEN
    CLOSE active_cur;
    RETURN 'Y';
  END IF;

  CLOSE active_cur;
  RETURN 'N';

END active_option_exists;

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
PROCEDURE end_date_active_loc_options IS

  CURSOR loc_def_cur IS
  select location_id, end_date
    from ap_pol_locations_vl
   where end_date is not null;

  l_location_id NUMBER;
  l_end_date DATE;
  loc_def_rec loc_def_cur%ROWTYPE;

BEGIN

  FOR loc_def_rec IN loc_def_cur LOOP

    l_location_id := loc_def_rec.location_id;
    l_end_date := loc_def_rec.end_date;

    IF ( l_end_date is not null )
    THEN

      update ap_pol_schedule_options
         set end_date = l_end_date
       where option_type = 'LOCATION'
         and location_id = l_location_id
         and NVL(end_date,TO_DATE('1','j')) >=
               DECODE(l_end_date,
                      null, TO_DATE('1','j'),
                      DECODE(end_date,
                             null, TO_DATE('1','j'),
                             l_end_date));
    END IF;
  END LOOP;

END end_date_active_loc_options;

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
FUNCTION does_location_exist RETURN VARCHAR2 IS

  CURSOR location_cur IS
    select 1 location_count
    from dual
    where exists
    (select 1
     from ap_pol_locations_b);

  location_rec location_cur%ROWTYPE;
BEGIN

  OPEN location_cur;
  FETCH location_cur INTO location_rec;
  CLOSE location_cur;

  IF location_rec.location_count = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('N');
 WHEN OTHERS THEN
  raise;
END does_location_exist;

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
PROCEDURE status_saved_sched_opts(p_policy_id       IN NUMBER) IS
BEGIN
  IF p_policy_id IS NOT NULL THEN
    update AP_POL_SCHEDULE_OPTIONS set STATUS = 'SAVED' where POLICY_ID = p_policy_id and nvl(STATUS, '~') <> 'ACTIVE';
   END IF;
END status_saved_sched_opts;

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
PROCEDURE status_active_sched_opts(p_policy_id       IN NUMBER) IS
BEGIN
  set_status_pol_sched_opts(p_policy_id, 'ACTIVE');
END status_active_sched_opts;

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
                                    p_status_code     IN VARCHAR2) IS
BEGIN
  IF p_policy_id IS NOT NULL AND
     p_status_code IS NOT NULL THEN
    update AP_POL_SCHEDULE_OPTIONS set STATUS = p_status_code where POLICY_ID = p_policy_id;
   END IF;
END set_status_pol_sched_opts;

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
                                      p_end_date  IN ap_pol_headers.end_date%TYPE) RETURN VARCHAR2 IS
  l_count_rows NUMBER := 0;
  l_return_val VARCHAR2(1);
BEGIN

  l_count_rows :=0;
  IF p_policy_id IS NOT NULL AND
     p_end_date IS NOT NULL THEN

    SELECT 1 INTO l_count_rows
    FROM dual
    WHERE exists
    (select 1
     from   ap_expense_report_params_all
     where  company_policy_id = p_policy_id and nvl(end_date,p_end_date+1) > p_end_date);

  END IF;

  IF (l_count_rows = 1) THEN
    l_return_val := 'N';
  ELSE
    l_return_val := 'Y';
  END IF;

  RETURN l_return_val;

EXCEPTION
 WHEN no_data_found  THEN
  l_return_val := 'Y';
  RETURN l_return_val;
 WHEN OTHERS THEN
  raise;
END are_exp_type_enddates_capped;

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
                                   p_end_date  IN ap_pol_headers.end_date%TYPE) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_are_enddates_capped VARCHAR2(1);
BEGIN
  l_are_enddates_capped := are_exp_type_enddates_capped(p_policy_id, p_end_date);

  IF (l_are_enddates_capped = 'N') THEN
    UPDATE ap_expense_report_params_all SET end_date = p_end_date
    WHERE company_policy_id = p_policy_id and nvl(end_date,p_end_date+1) > p_end_date;
    commit;
  END IF;

END cap_expense_type_enddates;

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
PROCEDURE init_user_expense_options(p_user_id       IN NUMBER) IS

  CURSOR user_exp_options_c IS
    SELECT ep.ORG_ID,
           pc.user_id,
           pc.selected_org_id
    FROM AP_EXPENSE_PARAMS_ALL ep,
         AP_POL_CONTEXT         pc
    WHERE ep.org_id(+)        = pc.selected_org_id
    AND   pc.user_id          = p_user_id;

BEGIN
  FOR user_exp_options_rec IN user_exp_options_c LOOP

    IF user_exp_options_rec.org_id is null THEN
      INSERT INTO AP_EXPENSE_PARAMS_ALL
             (prevent_cash_cc_age_limit,
              prevent_future_dated_day_limit,
              enforce_cc_acc_limit,
              enforce_cc_air_limit,
              enforce_cc_car_limit,
              enforce_cc_meal_limit,
              enforce_cc_misc_limit,
              org_id,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by)
      VALUES (null,
              null,
              null,
              null,
              null,
              null,
              null,
              user_exp_options_rec.selected_org_id,
              SYSDATE,
              p_user_id,
              NULL,
              SYSDATE,
              p_user_id);
    END IF;
  END LOOP;

END init_user_expense_options;

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
FUNCTION format_minutes_to_hour_minutes(p_minutes IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  RETURN lpad(to_char(get_hours_from_threshold(p_minutes)), 2, 0)
	 || ':' ||
	 lpad(to_char(get_minutes_from_threshold(p_minutes)), 2, 0);
EXCEPTION
 WHEN OTHERS THEN
  raise;
END format_minutes_to_hour_minutes;

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
FUNCTION get_hours_from_threshold(p_threshold IN NUMBER) RETURN NUMBER IS
BEGIN
  IF p_threshold IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN trunc(p_threshold/60);
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  raise;
END get_hours_from_threshold;

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
FUNCTION get_minutes_from_threshold(p_threshold IN NUMBER) RETURN NUMBER IS
BEGIN
  IF p_threshold IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN mod(p_threshold,60);
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  raise;
END get_minutes_from_threshold;


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
PROCEDURE deletePolicySchedule(p_policy_id       IN NUMBER) IS

BEGIN

  DELETE FROM AP_POL_SCHEDULE_OPTIONS WHERE POLICY_ID = p_policy_id;

  DELETE FROM AP_POL_SCHEDULE_PERIODS WHERE POLICY_ID = p_policy_id;

  DELETE FROM AP_POL_LINES WHERE POLICY_ID = p_policy_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END deletePolicySchedule;


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
FUNCTION getPolicyLinesCount(p_schedule_period_id       IN NUMBER) RETURN NUMBER IS
  l_count NUMBER;
BEGIN

  SELECT count(1)
  INTO   l_count
  FROM   ap_pol_lines
  WHERE  schedule_period_id = p_schedule_period_id;

  RETURN nvl(l_count, 0 );

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END getPolicyLinesCount;

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
                                p_token_value    IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN

  IF ( p_message_name IS NULL OR p_token IS NULL ) THEN
    RETURN NULL;
  END IF;

  fnd_message.set_name('SQLAP', p_message_name);
  fnd_message.set_token( p_token, p_token_value);

  RETURN fnd_message.get;

END getSingleTokenMessage;


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
                                   p_lookup_code  IN VARCHAR2) RETURN VARCHAR2 IS
   l_lookup_type fnd_lookups.lookup_type%TYPE;
BEGIN

   IF ( p_source = 'CONUS' ) THEN
     l_lookup_type := 'OIE_PER_DIEM_UPLOAD_TYPES';
   ELSE
     l_lookup_type := 'OIE_PER_DIEM_TYPES';
   END IF;

   RETURN get_lookup_meaning( l_lookup_type, p_lookup_code);

END get_per_diem_type_meaning;


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
 |  p_rate_type IN Rate Type (FIRST/LAST)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-May-2002           R Langi           Created
 |
 *=======================================================================*/
PROCEDURE permutatePolicyLines(p_user_id    IN NUMBER,
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_rate_type  IN ap_pol_schedule_options.rate_type_code%TYPE) IS

  l_schedule_period_id		ap_pol_schedule_periods.schedule_period_id%TYPE;
  l_permutate_curref		INTEGER;
  l_rows_permutated		    NUMBER := 0;
  l_policy_line_count		NUMBER := 0;
  l_insert_sql_stmt		    VARCHAR2(4000);
  l_where_sql_stmt		    VARCHAR2(4000);
  l_not_exists_sql_stmt		VARCHAR2(4000);

  l_l_sql_stmt			VARCHAR2(4000);
  l_r_sql_stmt			VARCHAR2(4000);
  l_c_sql_stmt			VARCHAR2(4000);
  l_dt_sql_stmt			VARCHAR2(4000);


  l_location_enabled            VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_LOCATION);
  l_role_enabled                VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_EMPLOYEE_ROLE);
  l_currency_enabled            VARCHAR2(160) := getUnionStmtForRuleOption(p_policy_id, c_CURRENCY);
  l_thresholds_enabled          VARCHAR2(80) := getUnionStmtForRuleOption(p_policy_id, c_THRESHOLD);

---------------------------------------
-- cursor for schedule periods
---------------------------------------
cursor c_schedule_period_id is
  select schedule_period_id
  from   ap_pol_schedule_periods
  where  policy_id = p_policy_id;

---------------------------------------
-- cursor for insert/select
---------------------------------------
cursor l_insert_cursor is
select
'
  insert into AP_POL_LINES
        (
         POLICY_LINE_ID,
         POLICY_ID,
         SCHEDULE_PERIOD_ID,
         LOCATION_ID,
         ROLE_ID,
         CURRENCY_CODE,
         RANGE_LOW,
         RANGE_HIGH,
         RATE_TYPE_CODE,
         STATUS,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
        )
  select
         AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
         :p_policy_id AS POLICY_ID,
         :p_schedule_period_id AS SCHEDULE_PERIOD_ID,
         NEW_LOCATION_ID AS LOCATION_ID,
         NEW_ROLE_ID AS ROLE_ID,
         NEW_CURRENCY_CODE AS CURRENCY_CODE,
         NEW_RANGE_LOW AS RANGE_LOW,
         NEW_RANGE_HIGH AS RANGE_HIGH,
         NEW_RATE_TYPE_CODE AS RATE_TYPE_CODE,
         ''NEW'' AS STATUS,
         sysdate AS CREATION_DATE,
         :p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         :p_user_id AS LAST_UPDATED_BY
  from
  (
  select distinct
         NEW_LOCATION_ID,
         NEW_ROLE_ID,
         NEW_CURRENCY_CODE,
         NEW_RANGE_LOW,
         NEW_RANGE_HIGH,
         NEW_RATE_TYPE_CODE
  from
  (
  select
          l.LOCATION_ID AS NEW_LOCATION_ID,
          r.ROLE_ID AS NEW_ROLE_ID,
          c.CURRENCY_CODE AS NEW_CURRENCY_CODE,
         dt.THRESHOLD AS NEW_RANGE_LOW,
         ap_web_policy_UTILS.getHighEndOfThreshold(:p_policy_id, dt.THRESHOLD, :p_rate_type) AS NEW_RANGE_HIGH,
         :p_rate_type AS NEW_RATE_TYPE_CODE
  from
'
from sys.dual; /* l_insert_cursor */

---------------------------------------
-- cursor for all locations to use
---------------------------------------
cursor l_l_cursor is
select
'
      (select LOCATION_ID
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_LOCATION
       and    LOCATION_ID IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_location_enabled||'
      ) l,
'
from sys.dual; /* l_l_cursor */

---------------------------------------
-- cursor for all roles to use
---------------------------------------
cursor l_r_cursor is
select
'
      (select ROLE_ID
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_EMPLOYEE_ROLE
       and    ROLE_ID IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_role_enabled||'
      ) r,
'
from sys.dual; /* l_r_cursor */

---------------------------------------
-- cursor for all currency codes to use
---------------------------------------
cursor l_c_cursor is
select
'
      (select CURRENCY_CODE
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    OPTION_TYPE = :c_CURRENCY
       and    CURRENCY_CODE IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
         '||l_currency_enabled||'
      ) c,
'
from sys.dual; /* l_c_cursor */

---------------------------------------
-- cursor for all thresholds to use
---------------------------------------
cursor l_dt_cursor is
select
'
      (select THRESHOLD
       from   AP_POL_SCHEDULE_OPTIONS pso
       where
              POLICY_ID = :p_policy_id
       and    (OPTION_TYPE = :c_DISTANCE_THRESHOLD or OPTION_TYPE = :c_TIME_THRESHOLD)
       and    THRESHOLD IS NOT NULL
       and    nvl(END_DATE, SYSDATE+1) > SYSDATE
       and    nvl(rate_type_code, :p_rate_type) = :p_rate_type
         '||l_thresholds_enabled||'
      ) dt
'
from sys.dual; /* l_dt_cursor */

---------------------------------------
-- cursor for where rows
---------------------------------------
cursor l_where_cursor is
select
'
  )
  where
        (
         NEW_LOCATION_ID is not null
  or     NEW_ROLE_ID is not null
  or     NEW_CURRENCY_CODE is not null
  or     NEW_RANGE_LOW is not null
  or     NEW_RANGE_HIGH is not null
        )
  )
'
from sys.dual; /* l_where_cursor */


---------------------------------------
-- cursor for adding new rules/options
---------------------------------------
cursor l_not_exists_cursor is
select
'
  )
  where
        (
         NEW_LOCATION_ID is not null
  or     NEW_ROLE_ID is not null
  or     NEW_CURRENCY_CODE is not null
  or     NEW_RANGE_LOW is not null
  or     NEW_RANGE_HIGH is not null
        )
  and
  not exists
        (
         select epl.POLICY_LINE_ID
         from   AP_POL_LINES epl
         where  epl.POLICY_ID = :p_policy_id
         and    epl.SCHEDULE_PERIOD_ID = :p_schedule_period_id
         and    nvl(epl.LOCATION_ID, :dummy_number) = nvl(NEW_LOCATION_ID, :dummy_number)
         and    nvl(epl.ROLE_ID, :dummy_number) = nvl(NEW_ROLE_ID, :dummy_number)
         and
               (
                (nvl(epl.CURRENCY_CODE, :dummy_varchar2) = nvl(NEW_CURRENCY_CODE, :dummy_varchar2))
                or
                (epl.CURRENCY_CODE is not null and NEW_CURRENCY_CODE is null)
               )
         and    nvl(epl.RANGE_LOW, :dummy_number) = nvl(NEW_RANGE_LOW, :dummy_number)
         and    nvl(epl.RANGE_HIGH, :dummy_number) = nvl(NEW_RANGE_HIGH, :dummy_number)
         and    nvl(epl.RATE_TYPE_CODE, :dummy_varchar2) = nvl(NEW_RATE_TYPE_CODE, :dummy_varchar2)
        )
  )
'
from sys.dual; /* l_not_exists_cursor */


BEGIN

  --removeObsoletedPolicyLines(p_policy_id);

  open l_insert_cursor;
  open l_where_cursor;
  open l_not_exists_cursor;

  open l_l_cursor;
  open l_r_cursor;
  open l_c_cursor;
  open l_dt_cursor;

  fetch l_insert_cursor into l_insert_sql_stmt;
  fetch l_where_cursor into l_where_sql_stmt;
  fetch l_not_exists_cursor into l_not_exists_sql_stmt;

  fetch l_l_cursor into l_l_sql_stmt;
  fetch l_r_cursor into l_r_sql_stmt;
  fetch l_c_cursor into l_c_sql_stmt;
  fetch l_dt_cursor into l_dt_sql_stmt;

  --------------
  -- open cursor
  --------------
  l_permutate_curref := DBMS_SQL.OPEN_CURSOR;

  --------------
  -- begin loop thru all periods
  --------------
  open c_schedule_period_id;
  loop

  fetch c_schedule_period_id into l_schedule_period_id;
  exit when c_schedule_period_id%NOTFOUND;

  select count(policy_line_id)
  into   l_policy_line_count
  from   ap_pol_lines
  where  policy_id = p_policy_id
  and    schedule_period_id = l_schedule_period_id;

  if (l_policy_line_count = 0) then
    --------------
    -- parse cursor
    --------------
    DBMS_SQL.PARSE(l_permutate_curref,
                      l_insert_sql_stmt||
                      l_l_sql_stmt||
                      l_r_sql_stmt||
                      l_c_sql_stmt||
                      l_dt_sql_stmt||
                      l_where_sql_stmt, DBMS_SQL.NATIVE);
  else
    --------------
    -- parse cursor
    --------------
    DBMS_SQL.PARSE(l_permutate_curref,
                      l_insert_sql_stmt||
                      l_l_sql_stmt||
                      l_r_sql_stmt||
                      l_c_sql_stmt||
                      l_dt_sql_stmt||
                      l_not_exists_sql_stmt, DBMS_SQL.NATIVE);
    --------------
    -- supply binds specific to this case
    --------------
    DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':dummy_number', -11);
    DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':dummy_varchar2', '-11');

  end if;

  --------------
  -- supply binds
  --------------
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_policy_id', p_policy_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_schedule_period_id', l_schedule_period_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_user_id', p_user_id);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_LOCATION', c_LOCATION);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_EMPLOYEE_ROLE', c_EMPLOYEE_ROLE);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_CURRENCY', c_CURRENCY);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_DISTANCE_THRESHOLD', c_DISTANCE_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':c_TIME_THRESHOLD', c_TIME_THRESHOLD);
  DBMS_SQL.BIND_VARIABLE(l_permutate_curref, ':p_rate_type', p_rate_type);

  --------------
  -- execute cursor
  --------------
  l_rows_permutated := DBMS_SQL.EXECUTE(l_permutate_curref);

  end loop;
  close c_schedule_period_id;
  --------------
  -- end loop thru all periods
  --------------

  --------------
  -- close cursor
  --------------
  DBMS_SQL.CLOSE_CURSOR(l_permutate_curref);

  close l_insert_cursor;
  close l_where_cursor;
  close l_not_exists_cursor;

  close l_l_cursor;
  close l_r_cursor;
  close l_c_cursor;
  close l_dt_cursor;

  updateInactivePolicyLines(p_policy_id);
  status_saved_sched_opts(p_policy_id);


EXCEPTION
 WHEN OTHERS THEN
  raise;
END permutatePolicyLines;

/*========================================================================
 | PUBLIC PROCEDURE permutateAddonRates
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
 |  p_schedule_period_id IN Policy Schedule Period Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
PROCEDURE permutateAddonRates( p_user_id IN NUMBER,
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_schedule_period_id IN ap_pol_lines.schedule_period_id%TYPE ) IS

   l_policy_line_count NUMBER;

BEGIN

   BEGIN
      select count(policy_line_id)
      into   l_policy_line_count
      from   ap_pol_lines
      where  policy_id = p_policy_id
      and    schedule_period_id = p_schedule_period_id
      and    addon_mileage_rate_code is not null;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
   END;

    IF (l_policy_line_count = 0) THEN
        -- No policy lines, so genera all permutations
        insert into AP_POL_LINES
            (
             POLICY_LINE_ID,
             POLICY_ID,
             SCHEDULE_PERIOD_ID,
             LOCATION_ID,
             ROLE_ID,
             CURRENCY_CODE,
             VEHICLE_CATEGORY,
             VEHICLE_TYPE,
             FUEL_TYPE,
             RANGE_LOW,
             RANGE_HIGH,
             ADDON_MILEAGE_RATE_CODE,
             STATUS,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
            )
        select
             AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
             apl.POLICY_ID,
             apl.SCHEDULE_PERIOD_ID,
             apl.location_id,
             apl.role_id,
             apl.currency_code,
             vehicle_category,
             vehicle_type,
             fuel_type,
             range_low,
             range_high,
             option_code as addon_mileage_rate_code,
             'NEW' AS STATUS,
             sysdate AS CREATION_DATE,
             apl.CREATED_BY,
             sysdate AS LAST_UPDATE_DATE,
             apl.LAST_UPDATED_BY
        from ap_pol_lines apl,
             ap_pol_schedule_options pso
        where apl.POLICY_ID = p_policy_id
          and pso.policy_id = apl.policy_id
          and OPTION_TYPE = 'OIE_ADDON_MILEAGE_RATES'
          and OPTION_CODE IS NOT NULL
          and nvl(END_DATE, SYSDATE+1) > SYSDATE
          and apl.addon_mileage_rate_code is null;

    ELSE
       -- ---------------------------------------------------------
       -- Delete all obsolete addon mileage rate lines
       -- ---------------------------------------------------------
       delete from   ap_pol_lines pl
       where  policy_id   = p_policy_id
         and  addon_mileage_rate_code is not null
         and  not exists
              (
                select 1
                  from ap_pol_schedule_options pso
                 where pso.policy_id   = pl.policy_id
                   and pso.option_code = pl.addon_mileage_rate_code
              );
        -- ---------------------------------------------------------
        -- Policy lines exist so make sure to only generate
        -- new permutations for non-existing lines.
        -- ---------------------------------------------------------
       insert into AP_POL_LINES
            (
             POLICY_LINE_ID,
             POLICY_ID,
             SCHEDULE_PERIOD_ID,
             LOCATION_ID,
             ROLE_ID,
             CURRENCY_CODE,
             VEHICLE_CATEGORY,
             VEHICLE_TYPE,
             FUEL_TYPE,
             RANGE_LOW,
             RANGE_HIGH,
             ADDON_MILEAGE_RATE_CODE,
             STATUS,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
            )
        select
             AP_POL_LINES_S.NEXTVAL AS POLICY_LINE_ID,
             apl.POLICY_ID,
             apl.SCHEDULE_PERIOD_ID,
             apl.location_id,
             apl.role_id,
             apl.currency_code,
             apl.vehicle_category,
             apl.vehicle_type,
             apl.fuel_type,
             apl.range_low,
             apl.range_high,
             option_code as addon_mileage_rate_code,
             'NEW' AS STATUS,
             sysdate AS CREATION_DATE,
             apl.CREATED_BY,
             sysdate AS LAST_UPDATE_DATE,
             apl.LAST_UPDATED_BY
        from ap_pol_lines apl,
             ap_pol_schedule_options pso
        where apl.POLICY_ID = p_policy_id
          and pso.policy_id = apl.policy_id
          and OPTION_TYPE = 'OIE_ADDON_MILEAGE_RATES'
          and OPTION_CODE IS NOT NULL
          and nvl(END_DATE, SYSDATE+1) > SYSDATE
          and apl.addon_mileage_rate_code is null
          and not exists
          ( select 1
            from   ap_pol_lines epl
            where  epl.POLICY_ID = apl.policy_id
              and  epl.SCHEDULE_PERIOD_ID = apl.schedule_period_id
              and  nvl(epl.LOCATION_ID, -1) = nvl(apl.location_id, -1)
              and  nvl(epl.ROLE_ID, -1) = nvl(apl.role_id, -1)
              and  ((nvl(epl.CURRENCY_CODE, 'NULL') = nvl(apl.currency_code, 'NULL'))
                     or
                    (epl.CURRENCY_CODE is not null and apl.currency_code is null)
                   )
              and  nvl(epl.VEHICLE_CATEGORY, 'NULL') = nvl(apl.vehicle_category, 'NULL')
              and  nvl(epl.VEHICLE_TYPE, 'NULL') = nvl(apl.vehicle_type, 'NULL')
              and  nvl(epl.FUEL_TYPE, 'NULL') = nvl(apl.fuel_type, 'NULL')
              and  nvl(epl.RANGE_LOW, -1) = nvl(apl.range_low, -1)
              and  nvl(epl.RANGE_HIGH, -1) = nvl(apl.range_high, -1)
              and  epl.addon_mileage_rate_code = pso.option_code
          );


        END IF;


END permutateAddonRates;

/*========================================================================
 | PUBLIC PROCEDURE permutateNightRates
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
 |  p_schedule_period_id IN Policy Schedule Period Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2005           krmenon           Created
 |
 *=======================================================================*/
PROCEDURE permutateNightRates( p_user_id IN NUMBER,
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE,
                               p_schedule_period_id IN ap_pol_lines.schedule_period_id%TYPE ) IS

-- -------------------------------------
-- Cursor for inserting new permutation
-- -------------------------------------
cursor c_insert_nighrates is
   select distinct
          apl.POLICY_ID,
          apl.SCHEDULE_PERIOD_ID,
          apl.location_id,
          apl.role_id,
          apl.currency_code,
          option_code as night_rate_type_code,
          'NEW' AS STATUS
     from ap_pol_lines apl,
          ap_pol_schedule_options pso
     where apl.POLICY_ID = p_policy_id
       and pso.policy_id(+) = apl.policy_id
       and OPTION_TYPE(+) = 'OIE_NIGHT_RATES'
       and OPTION_CODE(+) IS NOT NULL
       and nvl(END_DATE(+), SYSDATE+1) > SYSDATE
       and nvl(apl.rate_type_code, 'STANDARD') = 'STANDARD';

-- -------------------------------------
-- Cursor for updating permutations
-- -------------------------------------
cursor c_update_nightrates is
   select
          distinct
          apl.POLICY_ID,
          apl.SCHEDULE_PERIOD_ID,
          apl.location_id,
          apl.role_id,
          apl.currency_code,
          option_code as night_rate_type_code,
          'NEW' AS STATUS
     from ap_pol_lines apl,
          ap_pol_schedule_options pso,
          ap_pol_lines epl
     where apl.POLICY_ID = p_policy_id
       and pso.policy_id(+) = apl.policy_id
       and OPTION_TYPE(+) = 'OIE_NIGHT_RATES'
       and OPTION_CODE(+) IS NOT NULL
       and nvl(END_DATE(+), SYSDATE+1) > SYSDATE
       and nvl(apl.rate_type_code, 'STANDARD') = 'STANDARD'
       and not exists
       ( select 1
         from   ap_pol_lines epl
         where  epl.POLICY_ID = apl.policy_id
         and    epl.SCHEDULE_PERIOD_ID = apl.schedule_period_id
         and    nvl(epl.LOCATION_ID, -1) = nvl(apl.location_id, -1)
         and    nvl(epl.ROLE_ID, -1) = nvl(apl.role_id, -1)
         and    ((nvl(epl.CURRENCY_CODE, 'NULL') = nvl(apl.currency_code, 'NULL'))
                 or
                 (epl.CURRENCY_CODE is not null and apl.currency_code is null)
                )
         and    epl.rate_type_code = 'NIGHT_RATE'
         and    ( epl.night_rate_type_code is null or
                  ( epl.night_rate_type_code is not null and epl.night_rate_type_code = pso.option_code )
                )
        );

-- ------------------------------------
-- Local variables
-- ------------------------------------
   l_policy_line_count NUMBER;
   l_night_rates_code  ap_pol_headers.night_rates_code%TYPE;

BEGIN

   BEGIN
      select count(policy_line_id)
      into   l_policy_line_count
      from   ap_pol_lines
      where  policy_id = p_policy_id
      and    schedule_period_id = p_schedule_period_id
      and    rate_type_code = 'NIGHT_RATE';

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
   END;

    IF (l_policy_line_count = 0) THEN
        -- No policy lines, so generate all permutations
       FOR c_nightrate IN c_insert_nighrates
       LOOP
          insert into AP_POL_LINES
             (
              POLICY_LINE_ID,
              POLICY_ID,
              SCHEDULE_PERIOD_ID,
              LOCATION_ID,
              ROLE_ID,
              CURRENCY_CODE,
              RATE_TYPE_CODE,
              NIGHT_RATE_TYPE_CODE,
              STATUS,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
             )
           values
             (
              AP_POL_LINES_S.NEXTVAL,
              c_nightrate.POLICY_ID,
              c_nightrate.SCHEDULE_PERIOD_ID,
              c_nightrate.LOCATION_ID,
              c_nightrate.ROLE_ID,
              c_nightrate.CURRENCY_CODE,
              'NIGHT_RATE',
              c_nightrate.NIGHT_RATE_TYPE_CODE,
              c_nightrate.STATUS,
              sysdate,
              p_user_id,
              sysdate,
              p_user_id
             );
       END LOOP;

    ELSE

       -- ----------------------------------------------------------------
       -- Delete all obsolete lines based on the night rates code
       --    - If code is single remove rows whic have not null type code
       --    - If code is multiple remove rows which have null type code
       -- ----------------------------------------------------------------
       BEGIN
          select night_rates_code
          into   l_night_rates_code
          from   ap_pol_headers
          where  policy_id = p_policy_id;
          EXCEPTION WHEN OTHERS THEN
             raise;
       END;

       IF ( l_night_rates_code = 'SINGLE' ) THEN
          -- Delete all policy lines which have night rate type code value
          delete from   ap_pol_lines
          where  policy_id      = p_policy_id
          and    rate_type_code = 'NIGHT_RATE'
          and    night_rate_type_code is not null;

       ELSIF ( l_night_rates_code = 'MULTIPLE' ) THEN
          -- Delete all policy lines which have night rate type code is null
      	  /* delete from   ap_pol_lines
             where  policy_id      = p_policy_id
             and    rate_type_code = 'NIGHT_RATE'
             and    night_rate_type_code is NULL ; */

          -- Modified since deselecting night_rate_types retains values
          delete from   ap_pol_lines
          where  policy_id      = p_policy_id
          and    rate_type_code = 'NIGHT_RATE'
          and    (night_rate_type_code is NULL
                 or night_rate_type_code not in(select option_code
                                               from ap_pol_schedule_options
                                               where policy_id = p_policy_id));
       END IF;

       -- ---------------------------------------------------------
        -- Policy lines exist so make sure to only generate
        -- new permutations for non-existing lines.
       -- ---------------------------------------------------------
       FOR c_nightrate IN c_update_nightrates
       LOOP
          insert into AP_POL_LINES
             (
              POLICY_LINE_ID,
              POLICY_ID,
              SCHEDULE_PERIOD_ID,
              LOCATION_ID,
              ROLE_ID,
              CURRENCY_CODE,
              RATE_TYPE_CODE,
              NIGHT_RATE_TYPE_CODE,
              STATUS,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
             )
           values
             (
              AP_POL_LINES_S.NEXTVAL,
              c_nightrate.POLICY_ID,
              c_nightrate.SCHEDULE_PERIOD_ID,
              c_nightrate.LOCATION_ID,
              c_nightrate.ROLE_ID,
              c_nightrate.CURRENCY_CODE,
              'NIGHT_RATE',
              c_nightrate.NIGHT_RATE_TYPE_CODE,
              c_nightrate.STATUS,
              sysdate,
              p_user_id,
              sysdate,
              p_user_id
             );
       END LOOP;

        END IF;


END permutateNightRates;

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
FUNCTION isNightRatesEnabled(p_policy_id IN ap_pol_headers.policy_id%TYPE) RETURN VARCHAR2 IS
  l_night_rate_flag VARCHAR2(1) := 'N';
BEGIN

   select nvl2(night_rates_code, 'Y', 'N' )
   into   l_night_rate_flag
   from   ap_pol_headers
   where  policy_id = p_policy_id;

   return l_night_rate_flag;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return l_night_rate_flag;
   WHEN OTHERS THEN
     raise;

END isNightRatesEnabled;

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
FUNCTION isFirstPeriodRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2 IS
    l_rate_period_type_code		ap_pol_headers.night_rates_code%TYPE;
    l_first_period_count		number := 0;
BEGIN

   select nvl(rate_period_type_code, 'STANDARD')
   into   l_rate_period_type_code
   from   ap_pol_headers
   where  policy_id = p_policy_id;

   select count(1)
   into   l_first_period_count
   from   ap_pol_schedule_options
   where  policy_id = p_policy_id
   and    rate_type_code= 'FIRST_PERIOD';

   if (l_rate_period_type_code = 'STANDARD_FIRST_LAST' and l_first_period_count > 0)
   then
     return 'Y';
   else
     return 'N';
   end if;

  EXCEPTION
   WHEN OTHERS THEN
    raise;

END isFirstPeriodRatesEnabled;


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
FUNCTION isLastPeriodRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2 IS
    l_rate_period_type_code		ap_pol_headers.night_rates_code%TYPE;
    l_last_period_count		number := 0;
BEGIN

   select nvl(rate_period_type_code, 'STANDARD')
   into   l_rate_period_type_code
   from   ap_pol_headers
   where  policy_id = p_policy_id;

   select count(1)
   into   l_last_period_count
   from   ap_pol_schedule_options
   where  policy_id = p_policy_id
   and    rate_type_code= 'LAST_PERIOD';

   if (l_rate_period_type_code = 'STANDARD_FIRST_LAST' and l_last_period_count > 0)
   then
     return 'Y';
   else
     return 'N';
   end if;

  EXCEPTION
   WHEN OTHERS THEN
    raise;

END isLastPeriodRatesEnabled;

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
FUNCTION isSameDayRatesEnabled ( p_policy_id    ap_pol_headers.policy_id%TYPE ) RETURN VARCHAR2 IS
    l_same_day_rate_code		ap_pol_headers.night_rates_code%TYPE;
    l_same_day_count		number := 0;
BEGIN

   select nvl(same_day_rate_code, 'NULL')
   into   l_same_day_rate_code
   from   ap_pol_headers
   where  policy_id = p_policy_id;

   select count(1)
   into   l_same_day_count
   from   ap_pol_schedule_options
   where  policy_id = p_policy_id
   and    rate_type_code= 'SAME_DAY';

   if (l_same_day_rate_code = 'DEFINED' and l_same_day_count > 0)
   then
     return 'Y';
   else
     return 'N';
   end if;

  EXCEPTION
   WHEN OTHERS THEN
    raise;

END isSameDayRatesEnabled;


/*========================================================================
 | PRIVATE FUNCTION permutateConusLines
 |
 | DESCRIPTION
 |   This procedure will permutate the conus/oconus based policies lines
 |   in case where roles have been added as a schedule option
 |     - Re-runnable (will not create new permuations for existing options
 |     - Creates permutation only for new options
 |     - If option end dated then set Policy Line status to inactive
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
 | 07-Dec-2005           krmenon           Created |
 *=======================================================================*/
PROCEDURE permutateConusLines( p_user_id IN NUMBER,
                               p_policy_id  IN ap_pol_headers.policy_id%TYPE) IS

   l_role_enabled VARCHAR2(1);
BEGIN

   -- Check if roles rule is enabled for this schedule
   l_role_enabled := checkRuleOption(p_policy_id, c_EMPLOYEE_ROLE);

   -- ------------------------------------------------------
   -- Remove all obsolete role permutations
   -- ------------------------------------------------------
   DELETE FROM ap_pol_lines pl
   WHERE  pl.policy_id = p_policy_id
   AND    NVL(role_id, -1) <> -1
   AND    NOT EXISTS
          ( SELECT 1
            FROM   ap_pol_schedule_options pso
            WHERE  pso.policy_id = pl.policy_id
            AND    pso.option_type = 'EMPLOYEE_ROLE'
            AND    pso.option_code = pl.role_id
          );

   IF ( l_role_enabled = 'Y' ) THEN
      BEGIN
         -- ----------------------------------------------------------
         -- Update all lines which has a null value for the role id
         -- as the default All Others row.
         -- ----------------------------------------------------------
         UPDATE ap_pol_lines
         SET    role_id = -1
         WHERE  policy_id = p_policy_id
         AND    role_id IS NULL;

         -- ---------------------------------------------
         -- Insert new permutations
         -- ---------------------------------------------
         INSERT INTO ap_pol_lines
            (   POLICY_LINE_ID,
                POLICY_ID,
                SCHEDULE_PERIOD_ID,
                RATE_TYPE_CODE,
                STATUS,
                ROLE_ID,
                LOCATION_ID,
                CURRENCY_CODE,
                RATE,
                TOLERANCE,
                CALCULATION_METHOD,
                MEALS_DEDUCTION,
                BREAKFAST_DEDUCTION,
                LUNCH_DEDUCTION,
                DINNER_DEDUCTION,
                ONE_MEAL_DEDUCTION_AMT,
                TWO_MEALS_DEDUCTION_AMT,
                THREE_MEALS_DEDUCTION_AMT,
                ACCOMMODATION_ADJUSTMENT,
                ACCOMMODATION_CALC_METHOD,
                NIGHT_RATE_TYPE_CODE,
                START_OF_SEASON,
                END_OF_SEASON,
                MAX_LODGING_AMT,
                NO_GOVT_MEALS_AMT,
                PROP_MEALS_AMT,
                OFF_BASE_INC_AMT,
                FOOTNOTE_AMT,
                FOOTNOTE_RATE_AMT,
                MAX_PER_DIEM_AMT,
                EFFECTIVE_START_DATE,
                EFFECTIVE_END_DATE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY
             )
         SELECT AP_POL_LINES_S.NEXTVAL,
                apl.POLICY_ID,
                apl.SCHEDULE_PERIOD_ID,
                apl.RATE_TYPE_CODE,
                'NEW' as STATUS,
                pso.option_code as ROLE_ID,
                apl.LOCATION_ID,
                apl.CURRENCY_CODE,
                apl.RATE,
                apl.TOLERANCE,
                apl.CALCULATION_METHOD,
                apl.MEALS_DEDUCTION,
                apl.BREAKFAST_DEDUCTION,
                apl.LUNCH_DEDUCTION,
                apl.DINNER_DEDUCTION,
                apl.ONE_MEAL_DEDUCTION_AMT,
                apl.TWO_MEALS_DEDUCTION_AMT,
                apl.THREE_MEALS_DEDUCTION_AMT,
                apl.ACCOMMODATION_ADJUSTMENT,
                apl.ACCOMMODATION_CALC_METHOD,
                apl.NIGHT_RATE_TYPE_CODE,
                apl.START_OF_SEASON,
                apl.END_OF_SEASON,
                apl.MAX_LODGING_AMT,
                apl.NO_GOVT_MEALS_AMT,
                apl.PROP_MEALS_AMT,
                apl.OFF_BASE_INC_AMT,
                apl.FOOTNOTE_AMT,
                apl.FOOTNOTE_RATE_AMT,
                apl.MAX_PER_DIEM_AMT,
                apl.EFFECTIVE_START_DATE,
                apl.EFFECTIVE_END_DATE,
                sysdate as CREATION_DATE,
                p_user_id as CREATED_BY,
                p_user_id LAST_UPDATE_LOGIN,
                sysdate as LAST_UPDATE_DATE,
                p_user_id as LAST_UPDATED_BY
         FROM   ap_pol_lines apl,
                ap_pol_schedule_options pso
         WHERE  apl.policy_id   = pso.policy_id
         AND    apl.role_id     = -1
         AND    pso.option_type = 'EMPLOYEE_ROLE'
         AND    pso.role_id IS NOT NULL
         AND    pso.role_id <> -1
         AND    nvl(pso.end_date, SYSDATE+1) > SYSDATE
         AND NOT EXISTS
          ( SELECT 1
            FROM   ap_pol_lines epl
            WHERE  epl.POLICY_ID = apl.policy_id
              AND  epl.SCHEDULE_PERIOD_ID = apl.schedule_period_id
              AND  nvl(epl.LOCATION_ID, -1) = nvl(apl.location_id, -1)
              AND  nvl(epl.ROLE_ID, -1) = pso.option_code
              AND  nvl(epl.CURRENCY_CODE, 'NULL') = nvl(apl.currency_code, 'NULL')
          );
      END;
   ELSE
      BEGIN
         -- ----------------------------------------------------------
         -- Update all lines which has a -1 for the role id to null
         -- since there are no roles implemented
         -- ----------------------------------------------------------
         UPDATE ap_pol_lines
         SET    role_id = NULL
         WHERE  policy_id = p_policy_id
         AND    role_id IS NOT NULL;

      END;
   END IF;

END permutateConusLines;


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
FUNCTION isDateInSeason (p_date DATE,
                         p_start_of_season ap_pol_lines.start_of_season%TYPE,
                         p_end_of_season   ap_pol_lines.end_of_season%TYPE) RETURN VARCHAR2 IS
  l_start_month INTEGER;
  l_start_day   INTEGER;
  l_end_month   INTEGER;
  l_end_day     INTEGER;
  l_start_date  DATE;
  l_end_date    DATE;
BEGIN

  IF(p_date IS NULL OR p_start_of_season IS NULL OR p_end_of_season IS NULL) THEN
    RETURN 'N';
  END IF;

  l_start_month := substr(p_start_of_season, 1, 2) -1;
  l_start_day   := substr(p_start_of_season, 4, 5) -1;
  l_end_month   := substr(p_end_of_season, 1, 2) -1;
  l_end_day     := substr(p_end_of_season, 4, 5) -1;

  l_start_date := TRUNC(p_date, 'YEAR');
  l_end_date   := l_start_date;

  l_start_date := ADD_MONTHS(l_start_date, l_start_month) +l_start_day;
  l_end_date   := ADD_MONTHS(l_end_date, l_end_month) +l_end_day;

  -- Check if the season wraps the end of the year.
  IF(l_start_month > l_end_month) THEN
    IF(p_date >= l_start_date OR p_date <= l_end_date) THEN
        RETURN 'Y';
    END IF;
  ELSE
    IF(p_date >= l_start_date AND p_date <= l_end_date) THEN
        RETURN 'Y';
    END IF;
  END IF;

  RETURN 'N';

  EXCEPTION
   WHEN OTHERS THEN
    raise;

END isDateInSeason;

/*========================================================================
 | PUBLIC FUNCTION getPolicyLocationId
 |
 | DESCRIPTION
 | Helper function to determine the applicable policy location.
 |
 | PARAMETERS
 |    p_expense_type_id  -- Expense Type ID associated to the expense
 |    p_expense_date     -- Expense Start Date
 |    p_location_id      -- Expense Location
 | RETURNS
 |   Location Id   -- Location ID to use when selecting the policy line.
 |   null          -- otherwise.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2006           albowicz          Created
 |
 *=======================================================================*/

FUNCTION getPolicyLocationId( p_expense_type_id    IN NUMBER,
                              p_expense_date       IN DATE,
                              p_location_id        IN NUMBER ) RETURN NUMBER IS

l_location_id AP_POL_SCHEDULE_OPTIONS.location_id%type;

BEGIN
    SELECT LOCATION_ID
    INTO l_location_id
    FROM (
      -- This query verifies that a given location is active within a policy
      select location_id
      from AP_POL_SCHEDULE_OPTIONS opts, ap_expense_report_params_all p
      where p.parameter_id = p_expense_type_id
        AND policy_id = p.company_policy_id
        AND option_type = 'LOCATION'
        AND status      = 'ACTIVE'
        AND (opts.end_date is null OR opts.end_date >= p_expense_date)
        AND LOCATION_ID = p_location_id
      UNION ALL
      select opts.location_id
      from AP_POL_SCHEDULE_OPTIONS opts, AP_POL_LOCATIONS_B loc1, AP_POL_LOCATIONS_B loc2, ap_expense_report_params_all p
      where p.parameter_id = p_expense_type_id
        AND policy_id = p.company_policy_id
        AND opts.option_type = 'LOCATION'
        AND opts.status      = 'ACTIVE'
        AND (opts.end_date is null OR opts.end_date >= p_expense_date)
        AND loc1.location_id = opts.location_id
        AND loc1.location_type = 'COUNTRY'
        AND loc2.territory_code = loc1.territory_code
        AND loc2.location_type <> 'COUNTRY'
        AND loc2.location_id = p_location_id
      UNION ALL
      -- Will find the all other location for a given policy
      select loc.location_id
      from AP_POL_SCHEDULE_OPTIONS opts, AP_POL_LOCATIONS_B loc, ap_expense_report_params_all p
      where p.parameter_id = p_expense_type_id
        AND opts.policy_id = p.company_policy_id
        AND opts.option_type = 'LOCATION'
        AND opts.status      = 'ACTIVE'
        AND (opts.end_date is null OR opts.end_date >= p_expense_date)
        AND loc.location_id = opts.location_id
        AND loc.undefined_location_flag = 'Y'
    )
    WHERE ROWNUM = 1;

return l_location_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
    begin
        return l_location_id;
    end;

END getPolicyLocationId;



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
                         p_currency_code   IN VARCHAR2) RETURN NUMBER IS

l_policy_line_id AP_POL_LINES.policy_line_id%type;
l_hr_assignment hr_assignment_rec;
l_location_id NUMBER;
BEGIN

l_hr_assignment := getHrAssignment(p_person_id, p_expense_date);
l_location_id   := getPolicyLocationId(p_expense_type_id, p_expense_date, p_location_id);

select l.POLICY_LINE_ID
INTO l_policy_line_id
from AP_POL_HEADERS h, AP_POL_LINES l, AP_POL_SCHEDULE_PERIODS sp, AP_SYSTEM_PARAMETERS sys, AP_POL_EXRATE_OPTIONS rate_opts, ap_expense_report_params_all p
where p.parameter_id = p_expense_type_id
AND   h.policy_id = p.company_policy_id
AND   h.category_code <> 'MILEAGE'
AND   h.category_code <> 'PER_DIEM'
AND   p_expense_date between h.start_date and nvl(h.end_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))
AND   l.policy_id = h.policy_id
AND   l.status = 'ACTIVE'
AND   l.SCHEDULE_PERIOD_ID = sp.SCHEDULE_PERIOD_ID
AND   p_expense_date between sp.start_date and nvl(sp.end_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))
AND   sys.org_id = rate_opts.org_id(+)
AND   (nvl(h.employee_role_flag, 'N') = 'N' OR
       l.role_id = nvl((select ROLE_ID
                         from AP_POL_SCHEDULE_OPTIONS
                         where policy_id = h.policy_id
                         AND option_type = 'EMPLOYEE_ROLE'
                         AND status      = 'ACTIVE'
                         AND (end_date is null OR end_date >= p_expense_date)
                         AND ROLE_ID = decode(h.role_code, 'JOB_GROUP', l_hr_assignment.job_id, 'POSITION', l_hr_assignment.position_id, 'GRADE', l_hr_assignment.grade_id, -1)), -1))
AND   (nvl(h.location_flag, 'N') = 'N' OR
       l.location_id = l_location_id)
AND ( (h.category_code = 'AIRFARE') OR
      (l.currency_code = p_currency_code) OR
      (nvl(h.allow_rate_conversion_code, 'NO_CONVERSION') = 'NO_CONVERSION' AND h.currency_code = p_currency_code) OR
      (h.currency_preference = 'SRC' AND h.allow_rate_conversion_code = 'ALLOW_CONVERSION' AND
         ('Y' = GL_CURRENCY_API.rate_exists(p_currency_code, l.currency_code, p_expense_date, rate_opts.exchange_rate_type) OR
         ('Y' = GL_CURRENCY_API.rate_exists(p_currency_code, sys.base_currency_code, p_expense_date, rate_opts.exchange_rate_type) AND
          'Y' = GL_CURRENCY_API.rate_exists(sys.base_currency_code, l.currency_code, p_expense_date, rate_opts.exchange_rate_type)))
      ) OR
      (nvl(h.currency_preference, 'LCR') = 'LCR' AND ('Y' = GL_CURRENCY_API.rate_exists(p_currency_code, l.currency_code, p_expense_date, rate_opts.exchange_rate_type) OR
      ('Y' = GL_CURRENCY_API.rate_exists(p_currency_code, sys.base_currency_code, p_expense_date, rate_opts.exchange_rate_type) AND 'Y' = GL_CURRENCY_API.rate_exists(sys.base_currency_code, l.currency_code, p_expense_date, rate_opts.exchange_rate_type)))
      )
    )
-- ACC Seasonality condition.
AND (h.category_code <> 'ACCOMMODATIONS' OR l.start_of_season IS NULL OR l.end_of_season IS NULL OR
     'Y' = AP_WEB_POLICY_UTILS.isDateInSeason(p_expense_date, l.start_of_season, l.end_of_season))
AND l.parent_line_id is null -- Bug: 6866388, Too Many rows fetched
AND p_expense_date between nvl(l.effective_start_date, p_expense_date) and nvl(l.effective_end_date, p_expense_date+1); -- 6994883

return l_policy_line_id;


    EXCEPTION WHEN NO_DATA_FOUND THEN
    begin
        return l_policy_line_id;
    end;


END getPolicyLineId;


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
                              p_addon_invalid OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

-- Cursor to check for invalid lines based on status
cursor c_invalid_policy_lines is
   select nvl(rate_type_code, 'STANDARD') rate_type_code, count(1) as number_of_lines
   from   ap_pol_lines
   where  policy_id = p_policy_id
   and    schedule_period_id = p_schedule_id
   and    (status <>  'VALID' and status <> 'ACTIVE')
   and    addon_mileage_rate_code is null
   group by rate_type_code
   union all
   select nvl(rate_type_code, 'ADDON') rate_type_code,  count(1) as number_of_lines
   from   ap_pol_lines
   where  policy_id = p_policy_id
   and    schedule_period_id = p_schedule_id
   and    (status <> 'VALID' and status <> 'ACITVE')
   and    addon_mileage_rate_code is not null
   group by rate_type_code;

l_std_invalid   NUMBER;
l_first_invalid NUMBER;
l_last_invalid  NUMBER;
l_same_invalid  NUMBER;
l_night_invalid NUMBER;
l_addon_invalid NUMBER;

BEGIN

   -- Initialized
   p_std_invalid   :=0;
   p_first_invalid :=0;
   p_last_invalid  :=0;
   p_same_invalid  :=0;
   p_night_invalid :=0;
   p_addon_invalid :=0;

   -- Loop through the cursor
   FOR invalidLines in c_invalid_policy_lines
   LOOP
      IF ( invalidLines.rate_type_code = 'STANDARD' ) THEN
        p_std_invalid := invalidLines.number_of_lines;
      ELSIF ( invalidLines.rate_type_code = 'FIRST_PERIOD' ) THEN
        p_first_invalid := invalidLines.number_of_lines;
      ELSIF ( invalidLines.rate_type_code = 'LAST_PERIOD' ) THEN
        p_last_invalid := invalidLines.number_of_lines;
      ELSIF ( invalidLines.rate_type_code = 'SAME_DAY' ) THEN
        p_same_invalid := invalidLines.number_of_lines;
      ELSIF ( invalidLines.rate_type_code = 'NIGHT_RATE' ) THEN
        p_night_invalid := invalidLines.number_of_lines;
      ELSIF ( invalidLines.rate_type_code = 'ADDON' ) THEN
        p_addon_invalid := invalidLines.number_of_lines;
      END IF;

   END LOOP;

   IF ( (p_std_invalid + p_first_invalid + p_last_invalid +
         p_same_invalid + p_night_invalid + p_addon_invalid) > 0 ) THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

END checkForInvalidLines;

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
                              p_schedule_id   IN ap_pol_lines.SCHEDULE_PERIOD_ID%type) IS
BEGIN

   UPDATE ap_pol_lines
   SET    status = 'ACTIVE'
   WHERE  policy_id = p_policy_id
   AND    schedule_period_id = p_schedule_id
   AND    status = 'VALID';

END activatePolicyLines;

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
                               l_where_clause IN VARCHAR2
) IS

l_stmt VARCHAR2(4000);
BEGIN
  l_stmt := null;

    IF(l_mass_update_type = 'AMOUNT') THEN
      l_stmt := ' Update ap_pol_lines set ' ||
               ' rate = Nvl('|| l_rate || ', rate),' ||
               ' meal_limit = Nvl('|| l_meal_limit || ', meal_limit),' ||
               ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
               ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
               ' breakfast_deduction = Nvl('|| l_breakfast_deduction|| ', breakfast_deduction),' ||
               ' lunch_deduction = Nvl('|| l_lunch_deduction|| ',lunch_deduction),' ||
               ' dinner_deduction = Nvl('|| l_dinner_deduction|| ',dinner_deduction),' ||
               ' accommodation_adjustment = Nvl('|| l_accommodation_adjustment|| ',accommodation_adjustment),' ||
               ' meals_deduction = Nvl('|| l_meals_deduction|| ', meals_deduction),' ||
               ' tolerance = Nvl('|| l_tolerance|| ', tolerance),' ||
               ' rate_per_passenger = Nvl('|| l_rate_per_passenger|| ', rate_per_passenger),' ||
               ' one_meal_deduction_amt = Nvl('|| l_one_meal_deduction_amt|| ', one_meal_deduction_amt),' ||
               ' two_meals_deduction_amt = Nvl('|| l_two_meals_deduction_amt|| ', two_meals_deduction_amt),' ||
               ' three_meals_deduction_amt = Nvl('|| l_three_meals_deduction_amt|| ',three_meals_deduction_amt)' ||
               ' WHERE ' || l_where_clause;

    ELSIF(l_mass_update_type = 'PERCENT') THEN
      CASE l_rounding_rule

	WHEN 'WHOLE_NUMBER' THEN
            l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl(Round(Rate + (('||l_rate ||' * Rate)/100), 0), rate),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' meal_limit = Nvl(Round(meal_limit + (('||l_meal_limit  ||' * meal_limit)/100), 0), meal_limit),' ||
                     ' breakfast_deduction = Nvl(Round(breakfast_deduction + (('||l_breakfast_deduction ||' * breakfast_deduction)/100), 0), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl(Round(lunch_deduction + (('||l_lunch_deduction ||' * lunch_deduction)/100), 0), lunch_deduction),' ||
                     ' dinner_deduction = Nvl(Round(dinner_deduction + (('||l_dinner_deduction ||' * dinner_deduction)/100), 0), dinner_deduction), ' ||
                     ' accommodation_adjustment = Nvl(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||' * accommodation_adjustment)/100), 0), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl(Round(meals_deduction + (('||l_meals_deduction ||' * meals_deduction)/100), 0), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance ||', tolerance),' ||
                     ' rate_per_passenger = Nvl(Round(rate_per_passenger + (('||l_rate_per_passenger ||' * rate_per_passenger)/100), 0),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||' * one_meal_deduction_amt)/100), 0), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||' * two_meals_deduction_amt)/100), 0), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||' * three_meals_deduction_amt)/100), 0), three_meals_deduction_amt)' ||
                     ' WHERE ' || l_where_clause;

        WHEN '1_DECIMALS' THEN

            l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl(Round(Rate + (('||l_rate ||' * Rate)/100), 1), rate),' ||
                     ' meal_limit = Nvl(Round(meal_limit + (('||l_meal_limit  ||' * meal_limit)/100), 1), meal_limit),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' breakfast_deduction = Nvl(Round(breakfast_deduction + (('||l_breakfast_deduction ||' * breakfast_deduction)/100), 1), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl(Round(lunch_deduction + (('||l_lunch_deduction ||' * lunch_deduction)/100), 1), lunch_deduction),' ||
                     ' dinner_deduction = Nvl(Round(dinner_deduction + (('||l_dinner_deduction ||' * dinner_deduction)/100), 1), dinner_deduction), ' ||
                     ' accommodation_adjustment = Nvl(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||' * accommodation_adjustment)/100), 1), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl(Round(meals_deduction + (('||l_meals_deduction ||' * meals_deduction)/100), 1), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance ||', tolerance),' ||
                     ' rate_per_passenger = Nvl(Round(rate_per_passenger + (('||l_rate_per_passenger ||' * rate_per_passenger)/100), 1),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||' * one_meal_deduction_amt)/100), 1), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||' * two_meals_deduction_amt)/100), 1), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||' * three_meals_deduction_amt)/100), 1), three_meals_deduction_amt)' ||
                     ' WHERE ' || l_where_clause;

        WHEN '2_DECIMALS' THEN

            l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl(Round(Rate + (('||l_rate ||' * Rate)/100), 2), rate),' ||
                     ' meal_limit = Nvl(Round(meal_limit + (('||l_meal_limit  ||' * meal_limit)/100), 2), meal_limit),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' breakfast_deduction = Nvl(Round(breakfast_deduction + (('||l_breakfast_deduction ||' * breakfast_deduction)/100), 2), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl(Round(lunch_deduction + (('||l_lunch_deduction ||' * lunch_deduction)/100), 2), lunch_deduction),' ||
                     ' dinner_deduction = Nvl(Round(dinner_deduction + (('||l_dinner_deduction ||' * dinner_deduction)/100), 2), dinner_deduction), ' ||
                     ' accommodation_adjustment = Nvl(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||' * accommodation_adjustment)/100), 2), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl(Round(meals_deduction + (('||l_meals_deduction ||' * meals_deduction)/100), 2), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance ||', tolerance),' ||
                     ' rate_per_passenger = Nvl(Round(rate_per_passenger + (('||l_rate_per_passenger ||' * rate_per_passenger)/100), 2),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||' * one_meal_deduction_amt)/100), 2), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||' * two_meals_deduction_amt)/100), 2), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||' * three_meals_deduction_amt)/100), 2), three_meals_deduction_amt)' ||
                     ' WHERE ' || l_where_clause;

        WHEN '3_DECIMALS' THEN

	    l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl(Round(Rate + (('||l_rate ||' * Rate)/100), 3), rate),' ||
                     ' meal_limit = Nvl(Round(meal_limit + (('||l_meal_limit  ||' * meal_limit)/100), 3), meal_limit),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' breakfast_deduction = Nvl(Round(breakfast_deduction + (('||l_breakfast_deduction ||' * breakfast_deduction)/100), 3), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl(Round(lunch_deduction + (('||l_lunch_deduction ||' * lunch_deduction)/100), 3), lunch_deduction),' ||
                     ' dinner_deduction = Nvl(Round(dinner_deduction + (('||l_dinner_deduction ||' * dinner_deduction)/100), 3), dinner_deduction), ' ||
                     ' accommodation_adjustment = Nvl(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||' * accommodation_adjustment)/100), 3), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl(Round(meals_deduction + (('||l_meals_deduction ||' * meals_deduction)/100), 3), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance ||', tolerance),' ||
                     ' rate_per_passenger = Nvl(Round(rate_per_passenger + (('||l_rate_per_passenger ||' * rate_per_passenger)/100), 3),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||' * one_meal_deduction_amt)/100), 3), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||' * two_meals_deduction_amt)/100), 3), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||' * three_meals_deduction_amt)/100), 3), three_meals_deduction_amt)' ||
                     ' WHERE ' || l_where_clause;

        WHEN 'NEAREST_FIVE' THEN

            l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl((Round(Round(Rate + (('||l_rate ||'* Rate)/100), 0)/5)*5), Rate), ' ||
                     ' meal_limit = Nvl((Round(Round(meal_limit + (('||l_meal_limit ||'* meal_limit)/100), 0)/5)*5), meal_limit),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' breakfast_deduction = Nvl((Round(Round(breakfast_deduction + (('||l_breakfast_deduction ||'* breakfast_deduction)/100), 0)/5)*5), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl((Round(Round(lunch_deduction + (('||l_lunch_deduction ||'* lunch_deduction)/100), 0)/5)*5), lunch_deduction),' ||
                     ' dinner_deduction = Nvl((Round(Round(dinner_deduction + (('||l_dinner_deduction ||'* dinner_deduction)/100), 0)/5)*5), dinner_deduction),' ||
                     ' accommodation_adjustment = Nvl((Round(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||'* accommodation_adjustment)/100), 0)/5)*5), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl((Round(Round(meals_deduction + (('||l_meals_deduction ||'* meals_deduction)/100), 0)/5)*5), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance||' , tolerance),' ||
                     ' rate_per_passenger = Nvl((Round(Round(rate_per_passenger + (('||l_rate_per_passenger ||'* rate_per_passenger)/100), 0)/5)*5),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl((Round(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||'* one_meal_deduction_amt)/100), 0)/5)*5), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl((Round(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||'* two_meals_deduction_amt)/100), 0)/5)*5), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl((Round(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||'* three_meals_deduction_amt)/100), 0)/5)*5), three_meals_deduction_amt)' ||
		     ' WHERE ' || l_where_clause;

      WHEN 'NEAREST_TEN' THEN

            l_stmt := ' Update ap_pol_lines set ' ||
                     ' Rate = Nvl((Round(Round(Rate + (('||l_rate ||'* Rate)/100), 0)/10)*10), Rate), ' ||
                     ' meal_limit = Nvl((Round(Round(meal_limit + (('||l_meal_limit ||'* meal_limit)/100), 0)/10)*10), meal_limit),' ||
                     ' calculation_method = decode('''|| l_calculation_method|| ''',''NULL'',calculation_method,'''||l_calculation_method||'''),' ||
                     ' accommodation_calc_method = decode('''|| l_accommodation_calc_method|| ''',''NULL'',accommodation_calc_method,'''||l_accommodation_calc_method||'''),' ||
                     ' breakfast_deduction = Nvl((Round(Round(breakfast_deduction + (('||l_breakfast_deduction ||'* breakfast_deduction)/100), 0)/10)*10), breakfast_deduction),' ||
                     ' lunch_deduction = Nvl((Round(Round(lunch_deduction + (('||l_lunch_deduction ||'* lunch_deduction)/100), 0)/10)*10), lunch_deduction),' ||
                     ' dinner_deduction = Nvl((Round(Round(dinner_deduction + (('||l_dinner_deduction ||'* dinner_deduction)/100), 0)/10)*10), dinner_deduction),' ||
                     ' accommodation_adjustment = Nvl((Round(Round(accommodation_adjustment + (('||l_accommodation_adjustment ||'* accommodation_adjustment)/100), 0)/10)*10), accommodation_adjustment),' ||
                     ' meals_deduction = Nvl((Round(Round(meals_deduction + (('||l_meals_deduction ||'* meals_deduction)/100), 0)/10)*10), meals_deduction),' ||
                     ' tolerance = Nvl('||l_tolerance||' , tolerance),' ||
                     ' rate_per_passenger = Nvl((Round(Round(rate_per_passenger + (('||l_rate_per_passenger ||'* rate_per_passenger)/100), 0)/10)*10),rate_per_passenger),' ||
                     ' one_meal_deduction_amt = Nvl((Round(Round(one_meal_deduction_amt + (('||l_one_meal_deduction_amt ||'* one_meal_deduction_amt)/100), 0)/10)*10), one_meal_deduction_amt),' ||
                     ' two_meals_deduction_amt = Nvl((Round(Round(two_meals_deduction_amt + (('||l_two_meals_deduction_amt ||'* two_meals_deduction_amt)/100), 0)/10)*10), two_meals_deduction_amt),' ||
                     ' three_meals_deduction_amt = Nvl((Round(Round(three_meals_deduction_amt + (('||l_three_meals_deduction_amt ||'* three_meals_deduction_amt)/100), 0)/10)*10), three_meals_deduction_amt)' ||
                     ' WHERE ' || l_where_clause;
    END CASE;
  END IF;

  IF (l_stmt IS NOT NULL) THEN
    execute immediate l_stmt;
    COMMIT;
  END IF;

END massUpdatePolicyLines;

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
FUNCTION get_dup_rule_assignment_exists(p_rule_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR assignment_rule_cur IS
    SELECT Count(rsa.rule_assignment_id) assignment_count
    FROM oie_dup_detect_rules rule,
         oie_dup_detect_rs_detail rs,
         oie_dup_rule_assignments_all rsa
    WHERE rule.rule_id = p_rule_id
    AND ((rsa.rule_id = rule.rule_id)
        OR (rs.rule_id = rule.rule_id));

  assignment_rule_rec assignment_rule_cur%ROWTYPE;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start get_dup_rule_assignment_exists');

    IF p_rule_id IS NULL THEN
      RETURN 'N';
    END IF;

    OPEN assignment_rule_cur;
    FETCH assignment_rule_cur INTO assignment_rule_rec;
    CLOSE assignment_rule_cur;

    IF (assignment_rule_rec.assignment_count > 0) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

END get_dup_rule_assignment_exists;

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
FUNCTION get_dup_rs_assignment_exists(p_rule_set_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR assignment_rule_set_cur IS
    SELECT Count(rule_assignment_id) assignment_count
    FROM oie_dup_rule_assignments_all
    WHERE rule_set_id = p_rule_set_id;

  assignment_rule_set_rec assignment_rule_set_cur%ROWTYPE;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start get_dup_rs_assignment_exists');

    IF p_rule_set_id IS NULL THEN
      RETURN 'N';
    END IF;

    OPEN assignment_rule_set_cur;
    FETCH assignment_rule_set_cur INTO assignment_rule_set_rec;
    CLOSE assignment_rule_set_cur;

    IF (assignment_rule_set_rec.assignment_count > 0) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

END get_dup_rs_assignment_exists;

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
FUNCTION get_dup_detect_rule_name(p_rule_id IN NUMBER) RETURN VARCHAR2 IS

  l_rule_name oie_dup_detect_rules.rule_name%TYPE;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start get_dup_detect_rule_name');

    IF p_rule_id IS NULL THEN
      RETURN NULL;
    END IF;

    IF p_rule_id = -1 THEN
      SELECT displayed_field INTO l_rule_name FROM ap_lookup_codes
      WHERE lookup_type = 'OIE_DISABLE_DUP_DETECTION' AND lookup_code = 'DISABLE_DUPLICATE_DETECTION';
    ELSE
      SELECT rule_name INTO l_rule_name FROM oie_dup_detect_rules
      WHERE rule_id = p_rule_id;
    END IF;

    RETURN l_rule_name;

  EXCEPTION
    WHEN No_Data_Found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;

END get_dup_detect_rule_name;

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
FUNCTION get_dup_detect_rs_name(p_rule_set_id IN NUMBER) RETURN VARCHAR2 IS

  l_rule_set_name oie_dup_detect_rs_summary.rule_set_name%TYPE;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start get_dup_detect_rs_name');

    IF p_rule_set_id IS NULL THEN
      RETURN NULL;
    END IF;

    SELECT rule_set_name INTO l_rule_set_name FROM oie_dup_detect_rs_summary
    WHERE rule_set_id = p_rule_set_id;

    RETURN l_rule_set_name;

  EXCEPTION
    WHEN No_Data_Found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;

END get_dup_detect_rs_name;

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
FUNCTION validate_dup_detect_rule_name(p_rule_name IN VARCHAR2, p_rule_id IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR rule_names_cur IS
    SELECT rule_name
    FROM oie_dup_detect_rules
    WHERE rule_id <> p_rule_id;

  rule_names_rec rule_names_cur%ROWTYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start validate_dup_detect_rule_name');

  IF p_rule_name IS NULL THEN
    RETURN 'N';
  END IF;

  FOR rule_names_rec IN rule_names_cur LOOP
    IF p_rule_name = rule_names_rec.rule_name THEN
      RETURN 'Y';
    END IF;
  END LOOP;

  RETURN 'N';

END validate_dup_detect_rule_name;

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
FUNCTION validate_dup_detect_rs_name(p_rule_set_name IN VARCHAR2, p_rule_set_id IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR rs_names_cur IS
    SELECT rule_set_name
    FROM oie_dup_detect_rs_summary
    WHERE rule_set_id <> p_rule_set_id;

  rs_names_rec rs_names_cur%ROWTYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start validate_dup_detect_rs_name');

  IF p_rule_set_name IS NULL THEN
    RETURN 'N';
  END IF;

  FOR rs_names_rec IN rs_names_cur LOOP
    IF p_rule_set_name = rs_names_rec.rule_set_name THEN
      RETURN 'Y';
    END IF;
  END LOOP;

  RETURN 'N';

END validate_dup_detect_rs_name;

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
                                   p_start_date IN ap_expense_report_lines_all.START_EXPENSE_DATE%TYPE) RETURN NUMBER IS

  l_rule_id  oie_dup_detect_rules.RULE_ID%TYPE := NULL;
  l_rule_set_id  oie_dup_detect_rs_summary.RULE_SET_ID%TYPE := NULL;
  l_category_code VARCHAR2(30) := NULL;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start getDuplicateDetectionRule');

  BEGIN

  SELECT rule_id, rule_set_id INTO l_rule_id, l_rule_set_id
  FROM oie_dup_rule_assignments_all
  WHERE org_id = p_org_id AND Trunc(p_start_date) BETWEEN Trunc(start_date) AND Trunc(Nvl(end_date,p_start_date));

  EXCEPTION
  WHEN No_Data_Found THEN
    BEGIN

      SELECT rule_id, rule_set_id INTO l_rule_id, l_rule_set_id
      FROM oie_dup_rule_assignments_all
      WHERE org_id = -1 AND Trunc(p_start_date) BETWEEN Trunc(start_date) AND Trunc(Nvl(end_date,p_start_date));

    EXCEPTION
      WHEN No_Data_Found THEN
        RETURN NULL;
      WHEN OTHERS THEN
        RETURN NULL;

    END;
  WHEN OTHERS THEN
    RETURN NULL;

  END;

  IF l_rule_id IS NOT NULL THEN
    RETURN l_rule_id;
  END IF;

  IF l_rule_set_id IS NOT NULL THEN
    BEGIN

      SELECT displayed_field INTO l_category_code
      FROM ap_lookup_codes WHERE lookup_type = 'OIE_EXPENSE_CATEGORY'
      AND lookup_code = p_category_code;

      SELECT rule_id INTO l_rule_id
      FROM oie_dup_detect_rs_detail
      WHERE rule_set_id = l_rule_set_id AND category_code = l_category_code;

    EXCEPTION
      WHEN No_Data_Found THEN
        BEGIN

          SELECT rule_id INTO l_rule_id
          FROM oie_dup_detect_rs_detail
          WHERE rule_set_id = l_rule_set_id AND category_code = 'All';

        EXCEPTION
          WHEN No_Data_Found THEN
            RETURN NULL;
          WHEN OTHERS THEN
            RETURN NULL;

        END;
      WHEN OTHERS THEN
        RETURN NULL;

    END;
  END IF;

  RETURN l_rule_id;

END getDuplicateDetectionRule;

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
                           p_start_date IN ap_expense_report_lines_all.START_EXPENSE_DATE%TYPE) RETURN VARCHAR2 IS

  l_rule_id oie_dup_detect_rules.rule_id%TYPE := NULL;
  l_dup_detect_action oie_dup_detect_rules.duplicate_detection_action%TYPE := NULL;
  l_count NUMBER := 0;

  BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start isDupDetectExists');

  IF p_report_header_id =0  OR p_dist_line_number =0  OR p_org_id = 0 OR p_category_code IS NULL OR p_start_date IS NULL THEN
    RETURN NULL;
  END IF;

  l_rule_id := getDuplicateDetectionRule(p_org_id, p_category_code, p_start_date);

  IF l_rule_id IS NOT NULL AND l_rule_id <> -1 THEN
    SELECT duplicate_detection_action INTO l_dup_detect_action
    FROM oie_dup_detect_rules WHERE rule_id = l_rule_id;
  END IF;

  IF l_dup_detect_action = 'PREVENT_SUBMISSION' THEN
    BEGIN
      SELECT Count(*) INTO l_count FROM ap_pol_violations_all
      WHERE report_header_id = p_report_header_id AND distribution_line_number = p_dist_line_number
      AND violation_type = 'DUPLICATE_DETECTION';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_count := 0;
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count > 0 THEN
      RETURN l_dup_detect_action;
    END IF;
  END IF;

  RETURN NULL;

END isDupDetectExists;

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
                           p_dist_line_number IN ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE) RETURN VARCHAR2 IS

  CURSOR dist_num_cur IS
    SELECT distribution_line_number, itemization_parent_id
    FROM ap_expense_report_lines_all
    WHERE report_header_id = p_report_header_id
    AND (itemization_parent_id IS NULL OR itemization_parent_id <> -1)
    ORDER BY distribution_line_number, itemization_parent_id;

  dist_num_rec dist_num_cur%ROWTYPE;
  l_primary_number NUMBER := 0;
  l_sub_number NUMBER := 0;
  l_prev_parent_id NUMBER := 0;
  l_dist_line_number VARCHAR2(10) := NULL;
  BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start getDistLineNumber');

  FOR dist_num_rec IN dist_num_cur LOOP

    IF dist_num_rec.itemization_parent_id IS NULL THEN
      l_primary_number := l_primary_number + 1;
      l_sub_number := 0;
    ELSE
      IF l_prev_parent_id <> dist_num_rec.itemization_parent_id THEN
        l_primary_number := l_primary_number + 1;
        l_sub_number := 1;
      ELSE
        l_sub_number := l_sub_number + 1;
      END IF;
      l_prev_parent_id := dist_num_rec.itemization_parent_id;
    END IF;

    IF dist_num_rec.distribution_line_number = p_dist_line_number THEN
      EXIT;
    END IF;

  END LOOP;

  IF l_sub_number = 0 THEN
    l_dist_line_number := To_Char(l_primary_number);
  ELSE
    l_dist_line_number := To_Char(l_primary_number) || '-' || To_Char(l_sub_number);
  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'end getDistLineNumber');

  RETURN l_dist_line_number;

END getDistLineNumber;

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
                              p_dist_line_number IN ap_pol_violations_all.DISTRIBUTION_LINE_NUMBER%TYPE) RETURN NUMBER IS

  l_max_violation_number ap_pol_violations_all.VIOLATION_NUMBER%TYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start getMaxDistLineNumber');

  SELECT Max(violation_number) INTO l_max_violation_number
  FROM ap_pol_violations_all
  WHERE report_header_id = p_report_header_id
  AND distribution_line_number = p_dist_line_number
  AND violation_type = 'DUPLICATE_DETECTION';

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'end getMaxDistLineNumber');

  RETURN l_max_violation_number;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;

END getMaxDistLineNumber;

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
                                    p_last_update_date            IN            DATE) IS


  TYPE expense_lines IS REF CURSOR;

  expense_lines_cur expense_lines;

  expense_lines_rec ap_expense_report_lines_all%ROWTYPE;

  l_debug_info		VARCHAR2(1000);
  current_calling_sequence varchar2(100) := 'performDuplicateDetection';
  l_stmt  VARCHAR2(2000);
  l_att_stmt	VARCHAR2(2000);
  l_where_clause  VARCHAR2(2000) := NULL;
  l_rule_id oie_dup_detect_rules.rule_id%TYPE := NULL;
  l_exp_duplicates_allowed  NUMBER := 0;
  l_duplicates_allowed  NUMBER := 0;
  l_count NUMBER := 0;
  l_row_count NUMBER := 0;
  l_violation_number NUMBER := p_max_violation_number;
  l_dup_detect_action VARCHAR2(30) := NULL;
  l_report_prefix VARCHAR2(10);
  l_dist_line_number VARCHAR2(10);
  l_reimbcurr_format 	VARCHAR2(80);
  l_receipt_amount VARCHAR2(50);
  l_receipt_amt NUMBER;

  CURSOR dup_detect_rule_cur(p_rule_id IN NUMBER) IS
    SELECT * FROM oie_dup_detect_rules
    WHERE rule_id = p_rule_id;

  dup_detect_rule_rec dup_detect_rule_cur%ROWTYPE;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start performDuplicateDetection');

    IF l_violation_number = -1 THEN
      SELECT  Decode(Max(violation_number), NULL, 0, Max(violation_number)) INTO l_violation_number
      FROM ap_pol_violations_all WHERE report_header_id = p_report_header_id;
    END IF;

    DELETE FROM ap_pol_violations_all
    WHERE report_header_id = p_report_header_id
    AND distribution_line_number = p_distribution_line_number
    AND violation_type = 'DUPLICATE_DETECTION';

    p_dup_detect_action := NULL;

    l_rule_id := getDuplicateDetectionRule(p_org_id, p_category_code, p_start_date);

    FND_PROFILE.GET('AP_WEB_REPNUM_PREFIX', l_report_prefix);

    IF l_rule_id IS NOT NULL AND l_rule_id <> -1 THEN

      OPEN dup_detect_rule_cur(l_rule_id);
      FETCH dup_detect_rule_cur INTO dup_detect_rule_rec;
      CLOSE dup_detect_rule_cur;

      l_stmt := 'SELECT * FROM ap_expense_report_lines_all WHERE (((report_header_id IN
                (SELECT report_header_id FROM ap_expense_report_headers_all WHERE employee_id = ' || p_employee_id ||
                ' AND AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(source, workflow_approved_flag, report_header_id)
                  NOT IN (''REJECTED'', ''SAVED'', ''INPROGRESS'', ''WITHDRAWN''))) AND report_header_id <> ' || p_report_header_id ||
                  ') OR (report_header_id = ' || p_report_header_id || ' AND distribution_line_number < ' || p_distribution_line_number ||
                  ' AND report_line_id <> ' || p_report_line_id || ')) AND (itemization_parent_id is NULL OR itemization_parent_id <> -1)
                  AND start_expense_date = ''' || p_start_date || ''' AND category_code = ''' || p_category_code|| '''';

      IF dup_detect_rule_rec.detect_attendee_flag = 'Y' THEN
        l_att_stmt := 'SELECT * FROM ap_expense_report_lines_all WHERE (((report_header_id IN
                (SELECT report_header_id FROM ap_expense_report_headers_all
                WHERE AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(source, workflow_approved_flag, report_header_id)
                  NOT IN (''REJECTED'', ''SAVED'', ''INPROGRESS'', ''WITHDRAWN''))) AND report_header_id <> ' || p_report_header_id ||
                  ') OR (report_header_id = ' || p_report_header_id || ' AND distribution_line_number < ' || p_distribution_line_number ||
                  ' AND report_line_id <> ' || p_report_line_id || ')) AND (itemization_parent_id is NULL OR itemization_parent_id <> -1)
                AND start_expense_date = ''' || p_start_date || ''' AND category_code = ''' || p_category_code|| '''
                AND EXISTS (SELECT 1 FROM oie_attendees_all atts WHERE atts.report_line_id = report_line_id AND
                atts.employee_flag = ''Y'' AND atts.employee_id = ' || p_employee_id || ')';

	OPEN expense_lines_cur FOR l_att_stmt;
	LOOP
	  FETCH expense_lines_cur INTO expense_lines_rec;
	  EXIT WHEN expense_lines_cur%NOTFOUND;

	  l_row_count := l_row_count + 1;
	END LOOP;
	CLOSE expense_lines_cur;

	IF l_row_count > 0 THEN
	  l_stmt := l_att_stmt;
	END IF;
      END IF;

      IF dup_detect_rule_rec.detect_expense_type_flag = 'Y' THEN
        l_where_clause := ' AND web_parameter_id = ' || p_web_parameter_id;
      END IF;

      IF dup_detect_rule_rec.detect_receipt_amt_flag = 'Y' THEN
        l_where_clause := l_where_clause || ' AND receipt_currency_amount IN (SELECT receipt_currency_amount FROM ap_expense_report_lines_all
                          WHERE report_line_id = ' || p_report_line_id || ') AND receipt_currency_code = ''' || p_receipt_currency_code || '''';
      END IF;

      IF dup_detect_rule_rec.rule_type <> 'Generic' THEN

        IF p_category_code = 'ACCOMMODATIONS' THEN
          IF dup_detect_rule_rec.detect_end_date_flag = 'Y' THEN
            l_where_clause := l_where_clause || ' AND end_expense_date = ''' || p_end_date || '''';
          END IF;
        END IF;

        IF (dup_detect_rule_rec.detect_merchant_flag = 'Y' AND p_merchant_name IS NOT NULL) THEN
          l_where_clause := l_where_clause || ' AND merchant_name = ''' || p_merchant_name || '''';
        END IF;

        IF p_category_code = 'AIRFARE' THEN
          IF (dup_detect_rule_rec.detect_class_of_ticket_flag = 'Y' AND p_ticket_class_code IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND ticket_class_code = ''' || p_ticket_class_code || '''';
          END IF;

          IF (dup_detect_rule_rec.detect_ticket_num_flag = 'Y' AND p_ticket_number IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND ticket_number = ''' || p_ticket_number || '''';
          END IF;

          IF (dup_detect_rule_rec.detect_from_location_flag = 'Y' AND p_destination_from IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND destination_from = ''' || p_destination_from || '''';
          END IF;

          IF (dup_detect_rule_rec.detect_to_location_flag = 'Y' AND p_destination_to IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND destination_to = ''' || p_destination_to || '''';
          END IF;
        END IF;

        IF p_category_code = 'MILEAGE' THEN
          IF (dup_detect_rule_rec.detect_distance_uom_flag = 'Y' AND p_distance_unit_code IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND distance_unit_code = ''' || p_distance_unit_code || '''';
          END IF;

          IF dup_detect_rule_rec.detect_daily_trip_dist_flag = 'Y' THEN
            l_where_clause := l_where_clause || ' AND daily_distance = ' || p_daily_distance;
          END IF;

          IF (dup_detect_rule_rec.detect_vlp_num_flag = 'Y' AND p_license_plate_number IS NOT NULL) THEN
            l_where_clause := l_where_clause || ' AND license_plate_number = ''' || p_license_plate_number || '''';
          END IF;
        END IF;

      END IF;

      OPEN expense_lines_cur FOR l_stmt || l_where_clause;
      LOOP
        FETCH expense_lines_cur INTO expense_lines_rec;
        EXIT WHEN expense_lines_cur%NOTFOUND;

        l_count := l_count+1;
      END LOOP;
      CLOSE expense_lines_cur;

      IF l_count > 0 THEN
        BEGIN
          SELECT duplicates_allowed INTO l_exp_duplicates_allowed
          FROM ap_expense_report_params_all WHERE parameter_id = p_web_parameter_id;
        EXCEPTION
        WHEN OTHERS THEN
          l_exp_duplicates_allowed := -1;
        END;

        IF l_exp_duplicates_allowed IS NULL THEN
          l_exp_duplicates_allowed := -1;
        END IF;

        IF l_exp_duplicates_allowed <> -1 THEN
          l_duplicates_allowed := l_exp_duplicates_allowed;
        ELSE
          l_duplicates_allowed := dup_detect_rule_rec.duplicates_allowed;
        END IF;

        IF l_count > l_duplicates_allowed THEN

          OPEN expense_lines_cur FOR l_stmt || l_where_clause;
          LOOP
            FETCH expense_lines_cur INTO expense_lines_rec;
            EXIT WHEN expense_lines_cur%NOTFOUND;

            l_violation_number := l_violation_number + 1;
            l_dist_line_number := getDistLineNumber(expense_lines_rec.report_header_id, expense_lines_rec.distribution_line_number);

            INSERT INTO ap_pol_violations_all (
                      REPORT_HEADER_ID,
                      DISTRIBUTION_LINE_NUMBER,
                      VIOLATION_NUMBER,
                      VIOLATION_TYPE,
                      ORG_ID,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      LAST_UPDATE_DATE,
                      VIOLATION_DATE,
                      DUP_REPORT_HEADER_ID,
                      DUP_REPORT_LINE_ID,
                      DUP_DIST_LINE_NUMBER
                    )
                    VALUES (
                      p_report_header_id,
                      p_distribution_line_number,
                      l_violation_number,
                      'DUPLICATE_DETECTION',
                      p_org_id,
                      p_created_by,
                      p_creation_date,
                      p_last_updated_by,
                      p_last_update_login,
                      p_last_update_date,
                      p_start_date,
                      l_report_prefix || expense_lines_rec.report_header_id,
                      expense_lines_rec.report_line_id,
                      l_dist_line_number
                    );

          END LOOP;
          CLOSE expense_lines_cur;
          p_max_violation_number := l_violation_number;
          p_dup_detect_action := dup_detect_rule_rec.duplicate_detection_action;

        END IF;

      END IF;

    END IF;

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'end performDuplicateDetection');

  EXCEPTION
   WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

END performDuplicateDetection;

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
                              p_dist_line_number IN ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE) IS

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start removeDupViolations');

    IF ((p_report_header_id IS NOT NULL) AND (p_dist_line_number IS NOT NULL)) THEN

      DELETE FROM ap_pol_violations_all WHERE report_header_id = p_report_header_id
      AND distribution_line_number = p_dist_line_number AND violation_type = 'DUPLICATE_DETECTION';

    END IF;

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'end removeDupViolations');

END removeDupViolations;

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
                        p_dist_num OUT NOCOPY VARCHAR2) IS

  TYPE dist_lines IS REF CURSOR;
  dist_lines_cur dist_lines;
  dist_lines_rec ap_expense_report_lines_all%ROWTYPE;

  l_report_header_id ap_expense_report_lines_all.REPORT_HEADER_ID%TYPE;
  l_category_code ap_expense_report_lines_all.CATEGORY_CODE%TYPE;
  l_credit_card_trx_id ap_expense_report_lines_all.CREDIT_CARD_TRX_ID%TYPE;
  l_dist_line_number ap_expense_report_lines_all.DISTRIBUTION_LINE_NUMBER%TYPE;
  l_stmt  VARCHAR2(2000);
  l_primary_number NUMBER := 0;
  l_sub_number NUMBER := 0;
  l_prev_parent_id NUMBER := 0;

  BEGIN

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'start getDistNumber');

    IF p_report_line_id IS NULL THEN
      p_category := NULL;
      p_dist_num := NULL;
    END IF;

    SELECT report_header_id, category_code, credit_card_trx_id, distribution_line_number
    INTO l_report_header_id, l_category_code, l_credit_card_trx_id, l_dist_line_number
    FROM ap_expense_report_lines_all WHERE report_line_id = p_report_line_id;

    IF l_category_code = 'PER_DIEM' OR l_category_code = 'MILEAGE' THEN
      p_category := l_category_code;
      l_stmt := 'SELECT * FROM ap_expense_report_lines_all
                 WHERE report_header_id = ' || l_report_header_id || ' AND category_code = ''' || l_category_code ||
                 ''' ORDER by distribution_line_number, itemization_parent_id';
    ELSE
      IF l_credit_card_trx_id IS NOT NULL THEN
        p_category := 'CREDIT';
        l_stmt := 'SELECT * FROM ap_expense_report_lines_all
                   WHERE report_header_id = ' || l_report_header_id || ' AND credit_card_trx_id IS NOT NULL
                   AND (itemization_parent_id IS NULL OR itemization_parent_id <> -1) AND category_code NOT IN (''PER_DIEM'', ''MILEAGE'')
                   ORDER by distribution_line_number, itemization_parent_id';
      ELSE
        p_category := 'CASH';
        l_stmt := 'SELECT * FROM ap_expense_report_lines_all
                   WHERE report_header_id = ' || l_report_header_id || ' AND credit_card_trx_id IS NULL
                   AND (itemization_parent_id IS NULL OR itemization_parent_id <> -1) AND category_code NOT IN (''PER_DIEM'', ''MILEAGE'')
                   ORDER by distribution_line_number, itemization_parent_id';
      END IF;
    END IF;

    OPEN dist_lines_cur FOR l_stmt;
    LOOP
      FETCH dist_lines_cur INTO dist_lines_rec;
      EXIT WHEN dist_lines_cur%NOTFOUND;

      IF dist_lines_rec.itemization_parent_id IS NULL THEN
        l_primary_number := l_primary_number + 1;
        l_sub_number := 0;
      ELSE
        IF l_prev_parent_id <> dist_lines_rec.itemization_parent_id THEN
          l_primary_number := l_primary_number + 1;
          l_sub_number := 1;
        ELSE
          l_sub_number := l_sub_number + 1;
        END IF;
        l_prev_parent_id := dist_lines_rec.itemization_parent_id;
      END IF;

      IF dist_lines_rec.distribution_line_number = l_dist_line_number THEN
        EXIT;
      END IF;
    END LOOP;

    IF l_sub_number = 0 THEN
      p_dist_num := To_Char(l_primary_number);
    ELSE
      p_dist_num := To_Char(l_primary_number) || '-' || To_Char(l_sub_number);
    END IF;

    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_POLICY_UTILS', 'end getDistNumber');

END getDistNumber;


END AP_WEB_POLICY_UTILS;

/
