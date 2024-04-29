--------------------------------------------------------
--  DDL for Package Body CSF_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_UTIL_PVT" AS
/* $Header: CSFVUTLB.pls 120.11 2007/12/18 06:23:53 ipananil ship $ */

  g_pkg_name     CONSTANT VARCHAR2(30)  := 'CSF_UTIL_PVT';

  g_hsecs_old             NUMBER;
  g_seq_old               NUMBER;
  g_type_old              NUMBER;
  g_uom_minutes  CONSTANT VARCHAR2(3) := fnd_profile.VALUE('CSF_UOM_MINUTES');
  g_default_uom  CONSTANT VARCHAR2(3) := fnd_profile.value('CSF_DEFAULT_EFFORT_UOM');


  /****************************************************************
  *                        FND API Constants                      *
  *****************************************************************/

  FUNCTION get_miss_num RETURN NUMBER IS
  BEGIN
    RETURN fnd_api.g_miss_num;
  END get_miss_num;

  FUNCTION get_miss_char RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_miss_char;
  END get_miss_char;

  FUNCTION get_miss_date RETURN DATE IS
  BEGIN
    RETURN fnd_api.g_miss_date;
  END get_miss_date;

  FUNCTION get_valid_level_none RETURN NUMBER IS
  BEGIN
    RETURN fnd_api.g_valid_level_none;
  END get_valid_level_none;

  FUNCTION get_valid_level_full RETURN NUMBER IS
  BEGIN
    RETURN fnd_api.g_valid_level_full;
  END get_valid_level_full;

  FUNCTION get_ret_sts_success RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_ret_sts_success;
  END get_ret_sts_success;

  FUNCTION get_ret_sts_error RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_ret_sts_error;
  END get_ret_sts_error;

  FUNCTION get_ret_sts_unexp_error RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_ret_sts_unexp_error;
  END get_ret_sts_unexp_error;

  FUNCTION get_true RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_true;
  END get_true;

  FUNCTION get_false RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_false;
  END get_false;

  FUNCTION get_first RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_first;
  END get_first;

  FUNCTION get_next RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_next;
  END get_next;

  FUNCTION get_last RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_last;
  END get_last;

  FUNCTION get_previous RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_previous;
  END get_previous;

  FUNCTION get_msg_lvl_unexp_error RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_unexp_error;
  END get_msg_lvl_unexp_error;

  FUNCTION get_msg_lvl_error RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_error;
  END get_msg_lvl_error;

  FUNCTION get_msg_lvl_success RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_success;
  END get_msg_lvl_success;

  FUNCTION get_msg_lvl_debug_high RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_debug_high;
  END get_msg_lvl_debug_high;

  FUNCTION get_msg_lvl_debug_medium RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_debug_medium;
  END get_msg_lvl_debug_medium;

  FUNCTION get_msg_lvl_debug_low RETURN NUMBER IS
  BEGIN
    RETURN fnd_msg_pub.g_msg_lvl_debug_low;
  END get_msg_lvl_debug_low;

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
    RETURN VARCHAR2 IS
  BEGIN
    RETURN csf_tasks_pub.get_task_address(NULL, NULL, p_location_id, p_small_flag);
  END get_address;


  /**
   * Adds a Timing Mark in the CSR_TIMERS_B so that we can assess the performance of
   * each operation.
   *
   * @param p_seq   Sequence Number of the Timer
   * @param p_name  Name of the Timing Mark Logged
   * @param p_type
   * @param p_descr Description of the Timing Mark Logged for better information.
   */
  PROCEDURE add_timer(p_seq NUMBER, p_name VARCHAR2, p_type NUMBER, p_descr VARCHAR2) IS
    CURSOR c_timer IS
      SELECT hsecs FROM v$timer;
    l_idx     NUMBER;
    l_hsecs   NUMBER;
  BEGIN
    OPEN c_timer;
    FETCH c_timer INTO l_hsecs;
    CLOSE c_timer;

    IF p_type = 0 THEN
      g_hsecs_old := l_hsecs;
      g_seq_old := p_seq;
      g_type_old := 0;
    ELSIF p_type = 1 AND p_seq = g_seq_old THEN
      -- found timing pair
      -- insert directly into table, this is a quick-and-dirty solution, this
      -- has to be replaced by storage into pl/sql table which will be copied
      -- to csr_timers_b when Get Results button is pushed on Timing Tests
      -- Management UI
      BEGIN
        INSERT INTO csr_timers_b (seq, NAME, VALUE, meaning, description)
             VALUES (p_seq, p_name, (l_hsecs - g_hsecs_old) * 10, 'TIME', p_descr);

        COMMIT WORK;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      g_hsecs_old := NULL;
      g_seq_old := NULL;
      g_type_old := NULL;
    END IF;
  END add_timer;

  /**
   * Checks whether the given Territory ID is one among the Selected Territories
   * of the given user. If no user is given, then it checks using the signed
   * in user (FND_GLOBAL.USER_ID)
   *
   * @param p_terr_id        Territory ID of the Territory to be checked
   * @param p_user_id        User ID of the user whose list of Territories is used
   */
  FUNCTION is_terr_selected( p_terr_id IN NUMBER
                           , p_user_id IN NUMBER DEFAULT NULL ) RETURN NUMBER
  IS
    l_selected_terr   VARCHAR2(4000) := NULL;
    l_return_value    NUMBER         := 0;
  BEGIN
    l_selected_terr := get_selected_terr(p_user_id);

    IF l_selected_terr IS NULL THEN
      l_return_value := -1;
    ELSE
      l_return_value := INSTR(',' || l_selected_terr || ',', ',' || TO_CHAR(p_terr_id) || ',');
    END IF;

    RETURN l_return_value;
  END is_terr_selected;

  /**
   * Returns the list of Territories added to the given User.
   *
   * @param p_user_id        User ID of the user to get the list of User's Territories
   */
  FUNCTION get_selected_terr( p_user_id NUMBER DEFAULT NULL ) RETURN VARCHAR2
  IS
    l_selected_terr   VARCHAR2(4000);
    l_terr_table      jtf_number_table;
  BEGIN
    l_terr_table := get_selected_terr_table(p_user_id);

    FOR i IN 1..l_terr_table.COUNT LOOP
      -- Maximum permissible size of a database column of type VARCHAR2 is 4000
      IF LENGTH(l_selected_terr || ',' || l_terr_table(i)) > 4000 THEN
        RETURN SUBSTR(l_selected_terr,2);
      END IF;
      l_selected_terr := l_selected_terr || ',' || l_terr_table(i);
    END LOOP;

    RETURN SUBSTR(l_selected_terr, 2);
  END get_selected_terr;

  /**
   * Gets the List of Territories selected as a PLSQL Table
   *
   * @param p_user_id   User ID of the user to get the list of User's Territories
   */
  FUNCTION get_selected_terr_table( p_user_id NUMBER DEFAULT NULL )
  RETURN jtf_number_table
  IS
    l_selected_terr VARCHAR2(4000);
    l_terr_table    jtf_number_table;
    i               PLS_INTEGER;
    l_user_id       NUMBER DEFAULT NULL;

    CURSOR c_selected_terr( b_user_id NUMBER ) IS
      SELECT terr_id
        from csf_user_selected_terrs
       WHERE user_id = b_user_id;

    CURSOR c_plan_terr(b_resource_id NUMBER) IS
      SELECT DISTINCT pt.terr_id
        FROM csf_plan_terrs pt
           , jtf_rs_group_members m
       WHERE m.resource_id = b_resource_id
         AND NVL(m.delete_flag, 'N') <> 'Y'
         AND pt.group_id = m.group_id;

    CURSOR c_service_terr IS
      SELECT DISTINCT tq.terr_id
        FROM jtf_qual_type_usgs q
           , jtf_terr_qtype_usgs_all tq
       WHERE q.source_id = -1002
         AND tq.qual_type_usg_id = q.qual_type_usg_id;
  BEGIN
    l_terr_table := jtf_number_table();

    -- Use the logged in user's ID if no USER ID is passed to this function
    IF p_user_id IS NULL THEN
      l_user_id := fnd_global.user_id;
    ELSE
      l_user_id := p_user_id;
    END IF;

    -- Get the list of selected territories corresponding to the USER ID
    OPEN c_selected_terr( l_user_id );
    FETCH c_selected_terr INTO l_selected_terr;
    CLOSE c_selected_terr;

    -- If the user has selected territories.. then return those.
    IF l_selected_terr IS NOT NULL THEN
      LOOP
        i := INSTR(l_selected_terr, ',');
        EXIT WHEN i = 0;
        l_terr_table.extend(1);
        l_terr_table(l_terr_table.LAST) := SUBSTR(l_selected_terr, 1, i-1);
        l_selected_terr := SUBSTR(l_selected_terr, i+1);
      END LOOP;
      IF l_selected_terr IS NOT NULL AND LENGTH(TRIM(l_selected_terr)) > 0 THEN
        l_terr_table.extend(1);
        l_terr_table(l_terr_table.LAST) := l_selected_terr;
      END IF;
    ELSE
      -- If the user has selected territories.. then return those.
      OPEN c_plan_terr(csf_resource_pub.resource_id(l_user_id));
      FETCH c_plan_terr BULK COLLECT INTO l_terr_table;
      CLOSE c_plan_terr;

      -- The given user is not attached to any Planner Group.
      -- Return all territories under Oracle Service.
      IF l_terr_table.COUNT = 0 THEN
        OPEN c_service_terr;
        FETCH c_service_terr BULK COLLECT INTO l_terr_table;
        CLOSE c_service_terr;
      END IF;
    END IF;

    RETURN l_terr_table;
  END get_selected_terr_table;


  /**
   * Saves the list of selected territories to the database
   *
   * @param p_selected_terr  List of Territories to be stored
   * @param p_user_id        User ID of the user for whom we are storing the list
   */
  PROCEDURE set_selected_terr( p_selected_terr IN VARCHAR2 DEFAULT NULL
                             , p_user_id       IN NUMBER   DEFAULT NULL )
  IS
    l_user_id NUMBER DEFAULT NULL;
  BEGIN
    IF p_user_id IS NULL THEN
      l_user_id := fnd_global.user_id;
    ELSE
      l_user_id := p_user_id;
    END IF;

    IF p_selected_terr IS NOT NULL THEN
      UPDATE csf_user_selected_terrs
         SET terr_id               = p_selected_terr
           , last_updated_by       = fnd_global.user_id
           , last_update_date      = SYSDATE
           , last_update_login     = fnd_global.login_id
           , object_version_number = object_version_number + 1
       WHERE user_id = l_user_id;

      IF sql%NOTFOUND THEN
        INSERT INTO csf_user_selected_terrs (
                           user_id
                         , terr_id
                         , last_updated_by
                         , last_update_date
                         , last_update_login
                         , created_by
                         , creation_date
                         , object_version_number
               ) VALUES (
                           l_user_id
                         , p_selected_terr
                         , fnd_global.user_id
                         , SYSDATE
                         , fnd_global.login_id
                         , fnd_global.user_id
                         , SYSDATE
                         , 1);
      END IF;
    END IF;
  END set_selected_terr;

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
    RETURN VARCHAR2 IS
    CURSOR c_ref IS
      SELECT select_id
           , select_name
           , from_table
           , where_clause
        FROM jtf_objects_vl
       WHERE object_code = p_object_type_code;
    l_rec    c_ref%ROWTYPE;
    -- max data from jtf_objects_vl can be about 2600
    l_stmt   VARCHAR2(3000);
    -- highest max col length found in dom1151 = 421
    l_name   VARCHAR2(500)   := NULL;
  BEGIN
    OPEN c_ref;
    FETCH c_ref INTO l_rec;
    IF c_ref%NOTFOUND THEN
      CLOSE c_ref;
      RETURN NULL;
    END IF;
    CLOSE c_ref;

    l_stmt := 'SELECT ' || l_rec.select_name || ' FROM ' || l_rec.from_table || ' WHERE ';
    IF l_rec.where_clause IS NOT NULL THEN
      l_stmt := l_stmt || l_rec.where_clause || ' AND ';
    END IF;
    l_stmt := l_stmt || l_rec.select_id || ' = :object_id';

    EXECUTE IMMEDIATE l_stmt INTO l_name USING p_object_id;

    RETURN l_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_object_name;

  /**
   * Returns the Descrption/Name of the given UOM Code
   */
  FUNCTION get_uom(p_code VARCHAR2)
    RETURN VARCHAR2 IS
    l_uom   VARCHAR2(2000) := NULL;
    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;
  BEGIN
    OPEN c_uom(p_code);
    FETCH c_uom INTO l_uom;
    CLOSE c_uom;
    RETURN NVL(l_uom, p_code);
  END get_uom;

  FUNCTION is_uom_valid(p_value VARCHAR2)
    RETURN VARCHAR2 IS
    CURSOR c_uom(p_value VARCHAR2) IS
      SELECT 'TRUE'
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_value AND(TRUNC(disable_date) >= TRUNC(SYSDATE) OR disable_date IS NULL);
    l_ret   VARCHAR2(5);
  BEGIN
    OPEN c_uom(p_value);
    FETCH c_uom INTO l_ret;
    IF c_uom%NOTFOUND THEN
      l_ret := 'FALSE';
    END IF;
    CLOSE c_uom;
    RETURN l_ret;
  END is_uom_valid;

  /**
   * Returns the Default UOM (in Minutes) profile by reading the profile
   * "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES).
   *
   * @return Value of "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES)
   */
  FUNCTION get_uom_minutes RETURN VARCHAR2 AS
  BEGIN
    RETURN g_uom_minutes;
  END get_uom_minutes;

  /**
   * Converts the given Duration in the given Duration UOM to the UOM as defined by the
   * profile "CSF: The unit of measure for minutes" (CSF_UOM_MINUTES) there by
   * converting the value to Minutes.
   *
   * @param   p_duration      Duration to be converted to Minutes UOM
   * @param   p_duration_uom  Source UOM
   */
  FUNCTION convert_to_minutes(p_duration IN NUMBER, p_duration_uom IN VARCHAR2)
    RETURN NUMBER AS
    l_duration      NUMBER;
    l_uom_minutes   VARCHAR2(30);
  BEGIN
    l_duration    := p_duration;
    l_uom_minutes := get_uom_minutes;
    IF l_uom_minutes IS NOT NULL AND p_duration_uom IS NOT NULL THEN
      l_duration :=
            inv_convert.inv_um_convert(0, 0, p_duration, p_duration_uom, l_uom_minutes, NULL, NULL);
      IF l_duration < 0 THEN
        l_duration := p_duration;
      END IF;
    END IF;
    RETURN l_duration;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_duration;
  END convert_to_minutes;

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
    RETURN VARCHAR2 IS
    l_result               VARCHAR2(100);
    l_converted_effort     NUMBER;
    l_remaining_effort     NUMBER;
    l_uom_rate             NUMBER;
  BEGIN

    IF p_effort_uom = g_default_uom THEN
      l_result := p_effort || ' ' || csf_util_pvt.get_uom(p_effort_uom);
    ELSE
      inv_convert.inv_um_conversion(p_effort_uom, g_default_uom, NULL, l_uom_rate);

      l_converted_effort := TRUNC(ROUND(p_effort * l_uom_rate, 5));
      l_remaining_effort := TRUNC(p_effort - ROUND(l_converted_effort/l_uom_rate, 5));

      IF l_converted_effort <> 0 THEN
        l_result := l_converted_effort || ' ' || csf_util_pvt.get_uom(g_default_uom);
      END IF;

      IF l_remaining_effort <> 0 THEN
        IF l_result IS NOT NULL THEN
          l_result := l_result || ' ';
        END IF;
        l_result := l_result || l_remaining_effort || ' ' || csf_util_pvt.get_uom(p_effort_uom);
      END IF;
    END IF;

    RETURN l_result;
  END get_effort_in_default_uom;

  /**
   * (<b>Deprecated</b>) Retained because Service Team is still using it.
   * Returns the Qualifier Table having the list of valid Qualifiers
   * based on the Task Information of the given Task ID.
   *
   * @deprecated Use CSF_RESOURCE_PUB.GET_RES_QUALIFIER_TABLE
   */
  FUNCTION get_qualifier_table ( p_task_id NUMBER )
    RETURN csf_resource_pub.resource_qualifier_tbl_type IS
  BEGIN
    RETURN csf_resource_pub.get_res_qualifier_table(p_task_id);
  END get_qualifier_table;

  FUNCTION get_query_where(p_query_id NUMBER)
    RETURN VARCHAR2 IS
    l_where             csf_dc_queries_b.where_clause%TYPE;
    l_enabled_flag      VARCHAR2(1);
    l_owner_id          NUMBER;
    l_owner_type        VARCHAR2(30);

    CURSOR c_query_info IS
      SELECT q.where_clause
           , NVL(qe.owner_enabled_flag, 'N') owner_enabled_flag
           , ( SELECT COUNT(*)
                 FROM csf_plan_task_owners
                WHERE user_id = fnd_global.user_id
             ) owners_count
        FROM csf_dc_queries_b q
           , csf_dc_query_extns qe
       WHERE q.query_id  = p_query_id
         AND qe.user_id(+) = fnd_global.user_id
         AND qe.query_id(+) = q.query_id;

    l_query_info     c_query_info%ROWTYPE;
  BEGIN
    -- query the where clause corresponding to list value
    OPEN c_query_info;
    FETCH c_query_info INTO l_query_info;
    CLOSE c_query_info;

    IF (l_query_info.owner_enabled_flag IN ('Y', 'y')) THEN
      IF (l_query_info.owners_count = 0) THEN
        l_query_info.where_clause :=
              l_query_info.where_clause
           || ' and owner_id = ' || csf_resource_pub.resource_id
           || ' and owner_type_code = ''' || csf_resource_pub.resource_type || '''';
      ELSE
        l_query_info.where_clause :=
              l_query_info.where_clause
           || ' AND (owner_id, owner_type_code)
                       IN (SELECT owner_id, owner_type_code
                             FROM csf_plan_task_owners
                            WHERE user_id=fnd_global.user_id) ';
      END IF;
    END IF;
    RETURN l_query_info.where_clause;
  END get_query_where;

BEGIN
  g_timing_activated  := fnd_profile.value('LOGACTIVATED') = 'Y';
  g_logging_activated := fnd_profile.value('AFLOG_ENABLED') = 'Y';
END csf_util_pvt;

/
