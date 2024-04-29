--------------------------------------------------------
--  DDL for Package Body PV_CONTEXT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CONTEXT_VALUES" AS
/* $Header: pvxvconb.pls 120.12 2006/01/13 10:00:46 pklin noship $ */



/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_RETCODE                VARCHAR2(10) := '0';
g_common_currency        VARCHAR2(15);
g_module_name            VARCHAR2(48);
g_batch_insert_count     NUMBER;
g_non_batch_insert_count NUMBER;
g_partner_temp_table     VARCHAR2(30) := 'PV_PARTNER_ID_SESSION';
g_log_to_file            VARCHAR2(5)  := 'Y';

g_apps_schema            VARCHAR2(30);


TYPE r_func_perf_attrs_rec IS RECORD (
   performance_flag VARCHAR2(1),
   attribute_type   VARCHAR2(30),
   return_type      VARCHAR2(30),
   sql_text         VARCHAR2(2000)
);

TYPE t_func_perf_attrs_tbl IS TABLE OF r_func_perf_attrs_rec
     INDEX BY BINARY_INTEGER;

g_func_perf_attrs_tbl t_func_perf_attrs_tbl;
g_func_perf_attrs_empty t_func_perf_attrs_tbl;


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                              Exceptions to Catch                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_index_columns_existed    EXCEPTION;
PRAGMA EXCEPTION_INIT(g_index_columns_existed, -1408);

-- -----------------------------------------------------
-- ORA-00955: name is already used by an existing object
-- -----------------------------------------------------
g_name_already_used        EXCEPTION;
PRAGMA EXCEPTION_INIT(g_name_already_used, -955);

g_e_invalid_sql      EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_invalid_sql, -900);

g_e_undeclared_identifier EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_undeclared_identifier, -6550);

g_e_definer_rights EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_definer_rights, -31603);


-- -----------------------------------------------------
-- ORA-00904: invalid column name
-- -----------------------------------------------------
g_e_invliad_column_name EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_invliad_column_name, -904);

-- -----------------------------------------------------
-- ORA-01476: divisor is equal to zero
-- -----------------------------------------------------
g_e_divisor_is_zero EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_divisor_is_zero, -1476);


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
);


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);


FUNCTION Compute_Num_of_Blocks(
   p_num_of_rows   IN NUMBER,
   p_avg_length    IN NUMBER
)
RETURN NUMBER;


PROCEDURE Insert_Functional_Expertise(
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
);

PROCEDURE Insert_Internal(
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
);

PROCEDURE Insert_External(
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
);

PROCEDURE Insert_Function_Perf_Attrs(
   p_refresh_type IN VARCHAR2,
   p_partner_id   IN NUMBER
);

PROCEDURE Upsert_Func_Perf_Attrs (
   p_refresh_type  VARCHAR2,
   p_partner_id    NUMBER,
   p_attribute_id  NUMBER
);

PROCEDURE Update_Timestamp (
   p_attribute_id  IN NUMBER,
   p_timestamp     IN DATE := SYSDATE
);

PROCEDURE Transform_Batch_Sql (
   p_batch_sql_text     IN OUT NOCOPY VARCHAR2,
   p_new_partner_clause IN     VARCHAR2
);

PROCEDURE Recompile_Dependencies(
   p_referenced_type  IN VARCHAR2,
   p_referenced_name1 IN VARCHAR2,
   p_referenced_name2 IN VARCHAR2,
   p_api_package_name IN VARCHAR2
);



--=============================================================================+
--| Public Procedure                                                           |
--|    Exec_Create_Context_Val                                                 |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Exec_Create_Context_Val ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                    RETCODE             OUT  NOCOPY VARCHAR2,
                                    p_new_partners_only IN VARCHAR2 := 'N',
                                    p_log_to_file       IN VARCHAR2 := 'Y')

IS
   -- -----------------------------------------------------------------------
   -- Cursors
   -- -----------------------------------------------------------------------
   CURSOR c_underlying_tables IS
      SELECT synonym_name, table_name
      FROM   dba_synonyms
      WHERE  owner = g_apps_schema AND
             synonym_name IN ('PV_SEARCH_ATTR_VALUES', 'PV_SEARCH_ATTR_MIRROR');

   CURSOR c_pv_schema IS
      SELECT i.tablespace,
             i.index_tablespace,
             u.oracle_username
      FROM   fnd_product_installations i,
             fnd_application a,
             fnd_oracle_userid u
      WHERE  a.application_short_name = 'PV' AND
             a.application_id = i.application_id AND
             u.oracle_id = i.oracle_id;

   CURSOR c_synonyms (pc_synonym_name IN VARCHAR2) IS
      SELECT COUNT(*) count
      FROM   user_synonyms
      WHERE  synonym_name = pc_synonym_name;

   CURSOR c_attribute1_refresh IS
      SELECT COUNT(*) count
         FROM   pv_entity_attrs   b,
                pv_attributes_vl a
         WHERE  a.attribute_id = 1 AND
                a.attribute_id = b.attribute_id AND
                b.entity = 'PARTNER' AND
                a.enabled_flag = 'Y' AND
                b.enabled_flag = 'Y' AND
                a.enable_matching_flag = 'Y' AND
               (b.last_refresh_date IS NULL OR
                b.refresh_frequency IS NULL OR
                b.refresh_frequency_uom IS NULL OR
               (b.last_refresh_date +
                   DECODE(refresh_frequency_uom,
                      'HOUR',  refresh_frequency/24,
                      'DAY',   refresh_frequency,
                      'WEEK',  refresh_frequency * 7,
                      'MONTH', ADD_MONTHS(TRUNC(NVL(b.last_refresh_date, SYSDATE), 'MM'),
                                  b.refresh_frequency)
                               - NVL(b.last_refresh_date, SYSDATE)
                   )
                ) <= SYSDATE);


   -- -----------------------------------------------------------------------
   -- Local Variables
   -- -----------------------------------------------------------------------
   TYPE t_ref_cursor IS REF CURSOR;
   lc_get_partners   t_ref_cursor;

   l_api_package_name       VARCHAR2(30) := 'PV_CONTEXT_VALUES';
   l_refresh_type           VARCHAR2(30);
   l_refresh_type_temp      VARCHAR2(30);
   l_last_incr_refresh_str  VARCHAR2(100);
   l_last_incr_refresh_date DATE;
   l_partner_sql            VARCHAR2(32000);
   l_incr_timestamp         VARCHAR2(50);
   l_mirror_table           VARCHAR2(30);
   l_search_table           VARCHAR2(30);
   l_perf_mirror_table      VARCHAR2(30);
   l_perf_search_table      VARCHAR2(30);
   l_pv_schema_name         VARCHAR2(30);
   l_user_id                NUMBER := FND_GLOBAL.USER_ID();
   l_ret_val                BOOLEAN := FALSE;
   l_total_start            NUMBER;
   l_start                  NUMBER;
   l_elapsed_time           NUMBER;
   l_partner_id             NUMBER;
   l_end_refresh_flag       BOOLEAN;
   l_elapsed_time2          NUMBER;

   -- -------------------------------------------------------------------------
   -- Makeshift variables
   -- -------------------------------------------------------------------------
   l_num_temp               NUMBER;

BEGIN
   -- -----------------------------------------------------------------------
   -- Set variables.
   -- -----------------------------------------------------------------------
   l_total_start := dbms_utility.get_time;

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;

   IF (p_new_partners_only = 'Y') THEN
      l_refresh_type := g_incr_refresh;
   ELSE
      l_refresh_type := g_full_refresh;
   END IF;

   g_module_name := 'Refresh Attribute Texts Concurrent Program: ' ||
                    l_refresh_type;

   g_batch_insert_count     := 0;
   g_non_batch_insert_count := 0;

   -- -----------------------------------------------------------------------
   -- g_apps_schema is introduced to handle Oracle 10g schema swapping.
   -- See bug # 3871688. Reference to schema should not be hard-coded.
   -- -----------------------------------------------------------------------
   IF (g_apps_schema IS NULL) THEN
      FOR x IN (SELECT user FROM dual) LOOP
         g_apps_schema := x.user;
      END LOOP;
   END IF;

   -- -----------------------------------------------------------------------
   -- Exit the program if there is already a session running.
   -- -----------------------------------------------------------------------
   FOR x IN (SELECT COUNT(*) count
             FROM   v$session
             WHERE  module LIKE 'Refresh Attribute Texts Concurrent Program%')
   LOOP
      IF (x.count > 0) THEN
         Debug('There is already a Refresh Attribute Text CC session running.');
         Debug('The program will now exit.');
         RETURN;
      END IF;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Code Instrumentation
   -- -----------------------------------------------------------------------
   dbms_application_info.set_client_info(
      client_info => 'p_new_partners_only = ' || p_new_partners_only || ' | ' ||
                     'p_log_to_file = ' || p_log_to_file
   );

   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'STARTUP'
   );


   -- -----------------------------------------------------------------------
   -- Start time message...
   -- -----------------------------------------------------------------------
   FND_MESSAGE.SET_NAME(application => 'PV',
                        name        => 'PV_CREATE_CONTEXT_START_TIME');
   FND_MESSAGE.SET_TOKEN(token   => 'P_DATE_TIME',
                         value  =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

   IF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

   ELSE
      FND_MSG_PUB.Add;
   END IF;

   -- -----------------------------------------------------------------------
   -- Retrieve the last incremental refresh date from the profile.
   -- An incremental refresh is done when p_new_partners_only is set to 'Y'.
   -- -----------------------------------------------------------------------
   IF (l_refresh_type = g_incr_refresh) THEN
      -- --------------------------------------------------------------------
      -- Retrieve the profile value for incremental refresh
      -- --------------------------------------------------------------------
      FOR x IN (SELECT profile_option_value
                FROM   fnd_profile_options a,
                       fnd_profile_option_values b
                WHERE  a.application_id      = 691 AND
                       a.profile_option_id   = b.profile_option_id AND
                       b.level_id            = 10001 AND  -- site level
                       b.level_value         = 0 AND
                       a.profile_optioN_name = 'PV_REFRESH_ATTRS_LAST_UPDATE')
      LOOP
         l_last_incr_refresh_str := x.profile_option_value;
      END LOOP;

      -- ------------------------------------------------------------------------
      -- Somehow FND_PROFILE.VALUE is not getting the proper value. Use the above
      -- SQL instead.
      -- ------------------------------------------------------------------------
      -- l_last_incr_refresh_str  := FND_PROFILE.VALUE('PV_REFRESH_ATTRS_LAST_UPDATE');
      l_last_incr_refresh_date := NVL(TO_DATE(l_last_incr_refresh_str,
                                        'MM-DD-YYYY HH24:MI:SS'),
                                      TO_DATE('01-01-1900 00:00:00',
                                        'MM-DD-YYYY HH24:MI:SS'));

      Debug('Type of Refresh: INCREMENTAL (New Partners Only)');
      Debug('Initiating incremental refresh...only new partners added to the ');
      Debug('system since the last refresh date will be retrieved and updated.');
      Debug('Last refresh date: ' || NVL(l_last_incr_refresh_str, 'Never'));

   ELSE
      Debug('Type of Refresh: FULL');
   END IF;

   -- -----------------------------------------------------------------------
   -- Retrieve the common currency code from the profile option. This is the
   -- currency in which all the partner's currency attribute values will be
   -- converted to.
   -- -----------------------------------------------------------------------
   g_common_currency := NVL(FND_PROFILE.Value('PV_COMMON_CURRENCY'), 'USD');
   Debug('The common currency is: ' || g_common_currency);


   -- -----------------------------------------------------------------------
   -- Set NLS_NUMERIC_CHARACATERS for the session to '.,' format (US).
   -- This will ensure that numeric data that get stored in a VARCHAR2
   -- column (e.g. currency --> '1234.55:::USD:::030705153540') are stored
   -- in a consistent format.
   -- This is to prevent issues discovered in bug # 4191068.
   -- -----------------------------------------------------------------------
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';


   -- -----------------------------------------------------------------------
   -- "Freeze" the time. The next incremental refresh starts from here.
   -- This is done for both incremental and full refresh.
   -- -----------------------------------------------------------------------
   l_incr_timestamp := TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS');


   -- -----------------------------------------------------------------------
   -- Set the flag to NOT to display message in currency conversion.
   -- -----------------------------------------------------------------------
   pv_check_match_pub.g_display_message := FALSE;
   pv_check_match_pub.g_period_set_name := FND_PROFILE.Value('AS_FORECAST_CALENDAR');
   pv_check_match_pub.g_period_type := FND_PROFILE.Value('AS_DEFAULT_PERIOD_TYPE');

   g_partner_temp_table := 'PV_PARTNER_ID_SESSION';


   -- -----------------------------------------------------------------------
   -- Pre-processing steps including synonym recovery, retrieving PV schema,
   -- retrieving underlying tables for the search and the mirror table,
   -- alter/drop indexes, etc.
   -- -----------------------------------------------------------------------
   l_start := dbms_utility.get_time;
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Pre-Processing....................................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Pre-Processing'
   );

   Pre_Processing (
      p_refresh_type          => l_refresh_type,
      p_synonym_name          => 'PV_SEARCH_ATTR_VALUES',
      p_mirror_synonym_name   => 'PV_SEARCH_ATTR_MIRROR',
      p_temp_synonym_name     => 'PV_SEARCH_ATTR_VALUES_TMP',
      p_partner_id_temp_table => 'PV_PARTNER_ID_SESSION',
      p_temp_table_processed  => TRUE,
      p_last_incr_refresh_str => l_last_incr_refresh_str,
      p_log_to_file           => g_log_to_file,
      p_module_name           => g_module_name,
      p_pv_schema_name        => l_pv_schema_name,
      p_search_table          => l_search_table,
      p_mirror_table          => l_mirror_table,
      p_end_refresh_flag      => l_end_refresh_flag,
      p_out_refresh_type      => l_refresh_type_temp
   );

   l_refresh_type := l_refresh_type_temp;


   -- -----------------------------------------------------------------------
   -- Exit the program when Pre_Processing sets p_end_refresh_flag to FALSE.
   -- This usually happens when the refresh type is g_incr_refresh, but there are
   -- no new partners since the last incremental refresh.
   -- -----------------------------------------------------------------------
   IF (l_refresh_type IN (g_incr_refresh, g_incr_full_refresh) AND l_end_refresh_flag) THEN
      Debug('Update last refresh date...');

      FND_PROFILE.PUT('PV_REFRESH_ATTRS_LAST_UPDATE', l_incr_timestamp);
      l_ret_val := FND_PROFILE.SAVE('PV_REFRESH_ATTRS_LAST_UPDATE',
                                     l_incr_timestamp,
                                    'SITE');

      Debug('The next incremental refresh will start from ' || l_incr_timestamp);

      RETCODE := g_RETCODE;

      RETURN;
   END IF;


   Debug('Elapsed Time (Pre-Processing): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --        Process Attributes That Don't Need to Be Refreshed
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Processing attributes that do not need to be refreshed................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Processing Non-Refreshables'
   );

   IF (l_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
      INSERT /*+ APPEND */ INTO pv_search_attr_mirror
      (SEARCH_ATTR_VALUES_ID,
       PARTY_ID,
       SHORT_NAME,
       ATTR_TEXT,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER,
       LAST_UPDATED_BY,
       SECURITY_GROUP_ID,
       ATTRIBUTE_ID,
       ATTR_VALUE
      )
      SELECT SEARCH_ATTR_VALUES_ID,
             PARTY_ID,
             SHORT_NAME,
             ATTR_TEXT,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER,
             LAST_UPDATED_BY,
             SECURITY_GROUP_ID,
             ATTRIBUTE_ID,
             ATTR_VALUE
      FROM   pv_search_attr_values
      WHERE  attribute_id IN (
                SELECT a.attribute_id
                FROM   pv_attributes_b a,
                       pv_entity_attrs b
                WHERE  a.attribute_id = b.attribute_id AND
                       b.entity = 'PARTNER' AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                      (a.enable_matching_flag = 'Y' OR
                       b.display_external_value_flag = 'Y') AND
                      (b.last_refresh_date +
                          DECODE(refresh_frequency_uom,
                             'HOUR',  refresh_frequency/24,
                             'DAY',   refresh_frequency,
                             'WEEK',  refresh_frequency * 7,
                             'MONTH', ADD_MONTHS(TRUNC(NVL(b.last_refresh_date, SYSDATE), 'MM'),
                                         b.refresh_frequency)
                                      - NVL(b.last_refresh_date, SYSDATE)
                          )
                      ) > SYSDATE);


      Debug(SQL%ROWCOUNT || ' rows inserted.');

      COMMIT;
   END IF;

   Debug('Elapsed Time (Non-Refreshables): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --        Process Attribute ID 1 (Functional Expertise)
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Processing Functional Expertise......................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Functional Attributes'
   );

   FOR x IN c_attribute1_refresh LOOP
      l_num_temp := x.count;
   END LOOP;

   IF (l_num_temp > 0) THEN
      Insert_Functional_Expertise(l_refresh_type, l_user_id);
   END IF;

   Debug('Elapsed Time (Functional Expertise): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --        Process Internal Attributes
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Processing internal attributes.............................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Internal Attributes'
   );

   Insert_Internal(l_refresh_type, l_user_id);

   Debug('Elapsed Time (Internal Attributes): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --        Process Derived/Performance Attributes
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('-- **********************************************************');
   Debug('-- Processing derived/performance attributes.............................');
   Debug('-- **********************************************************');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Derived/Perf Attributes'
   );


   -- Reset
   g_func_perf_attrs_tbl := g_func_perf_attrs_empty;

   -- ------------------------------------------------------------------
   -- This step will process all function attributes in either an
   -- incremental or full refresh.
   -- It will only process performance attributes in an incremental
   -- refresh.
   --
   -- Check if there are any attributes that fall within this category.
   -- If yes, process these attributes partner-by-partner.
   -- ------------------------------------------------------------------
   IF (l_refresh_type <> g_incr_refresh) THEN
      FOR x IN (SELECT COUNT(*) count
             FROM   pv_entity_attrs  a,
                    pv_attributes_vl b
             WHERE  a.attribute_id = b.attribute_id AND
                    a.entity = 'PARTNER' AND
                    a.enabled_flag = 'Y' AND
                    b.enabled_flag = 'Y' AND
                   (b.enable_matching_flag = 'Y' OR
                    a.display_external_value_flag = 'Y') AND
                  ((b.performance_flag = 'Y'  AND
                    l_refresh_type = g_incr_refresh) OR
                    b.attribute_type   = 'FUNCTION') AND
                   (a.last_refresh_date IS NULL OR
                    a.refresh_frequency IS NULL OR
                    a.refresh_frequency_uom IS NULL OR
                   (last_refresh_date +
                      DECODE(refresh_frequency_uom,
                         'HOUR',  refresh_frequency/24,
                         'DAY',   refresh_frequency,
                         'WEEK',  refresh_frequency * 7,
                         'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                     refresh_frequency)
                                  - NVL(last_refresh_date, SYSDATE)
                      )
                   ) <= SYSDATE) )
      LOOP
         l_num_temp := x.count;
      END LOOP;
   END IF;

   -- ----------------------------------------------------------------------------------
   -- Incremental refresh does not consider refresh frequency. Every attribute should
   -- always be updated.
   -- ----------------------------------------------------------------------------------
   IF (l_num_temp > 0 OR l_refresh_type = g_incr_refresh) THEN
      IF (l_refresh_type = g_incr_refresh AND l_last_incr_refresh_date IS NOT NULL) THEN
         OPEN lc_get_partners FOR
            SELECT partner_id
            FROM   pv_partner_id_session;

      ELSE
         -- -----------------------------------------------------------------------------
	 -- Obsolete the use of sales_partner_flag.
	 -- In 11.5.10, an IMP's (indirectly-managed partner) relationship with the VAD
	 -- does not have a partner resource.  We don't want to include these records
	 -- in the refresh.
         -- -----------------------------------------------------------------------------
         OPEN lc_get_partners FOR
            SELECT partner_id
            FROM   pv_partner_profiles
            WHERE  status = 'A' AND
                   --sales_partner_flag = 'Y'
		   partner_resource_id IS NOT NULL;
      END IF;

      LOOP
         FETCH lc_get_partners INTO l_partner_id;
         EXIT WHEN lc_get_partners%NOTFOUND;

         Insert_Function_Perf_Attrs(l_refresh_type, l_partner_id);
      END LOOP;

      CLOSE lc_get_partners;

      IF (l_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
         COMMIT;
      END IF;
   END IF;

   IF (l_refresh_type <> g_incr_refresh) THEN
      FOR x IN (SELECT a.attribute_id
                FROM   pv_entity_attrs  a,
                       pv_attributes_vl b
                WHERE  a.attribute_id = b.attribute_id AND
                       a.entity = 'PARTNER' AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                      (b.enable_matching_flag = 'Y' OR
                       a.display_external_value_flag = 'Y') AND
                     ((b.performance_flag = 'Y'  AND
                       l_refresh_type = g_incr_refresh) OR
                       b.attribute_type   = 'FUNCTION') AND
                      (a.last_refresh_date IS NULL OR
                       a.refresh_frequency IS NULL OR
                       a.refresh_frequency_uom IS NULL OR
                      (last_refresh_date +
                         DECODE(refresh_frequency_uom,
                            'HOUR',  refresh_frequency/24,
                            'DAY',   refresh_frequency,
                            'WEEK',  refresh_frequency * 7,
                            'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                        refresh_frequency)
                                     - NVL(last_refresh_date, SYSDATE)
                         )
                      ) <= SYSDATE) )
      LOOP
         Update_Timestamp (
            p_attribute_id  => x.attribute_id,
            p_timestamp     => SYSDATE
         );
      END LOOP;
   END IF;



   Debug('Total Number of Rows Inserted for this operation: ' || g_non_batch_insert_count);
   Debug('Elapsed Time (Derived/Perf Incr): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

   l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --                Process External Attributes
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Processing external attributes.........................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'External Attributes'
   );

   Insert_External(l_refresh_type, l_user_id);

   Debug('Elapsed Time (External Attributes): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');


   -- *****************************************************************
   -- *****************************************************************
   --                    Post Loading Processing
   -- *****************************************************************
   -- *****************************************************************
   l_start := dbms_utility.get_time;
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Post loading processing...............................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Post Processing'
   );

   Post_Processing (
      p_refresh_type          => l_refresh_type,
      p_synonym_name          => 'PV_SEARCH_ATTR_VALUES',
      p_mirror_synonym_name   => 'PV_SEARCH_ATTR_MIRROR',
      p_temp_synonym_name     => 'PV_SEARCH_ATTR_VALUES_TMP',
      p_pv_schema_name        => l_pv_schema_name,
      p_search_table          => l_search_table,
      p_mirror_table          => l_mirror_table,
      p_incr_timestamp        => l_incr_timestamp,
      p_module_name           => g_module_name,
      p_api_package_name      => l_api_package_name,
      p_log_to_file           => g_log_to_file
   );

   -- --------------------------------------------------------------
   -- Update last refresh date.
   -- --------------------------------------------------------------
   Debug('Update last refresh date...');
   FND_PROFILE.PUT('PV_REFRESH_ATTRS_LAST_UPDATE', l_incr_timestamp);
   l_ret_val := FND_PROFILE.SAVE('PV_REFRESH_ATTRS_LAST_UPDATE',
                                  l_incr_timestamp,
                                 'SITE');

   Debug('The next incremental refresh will start from ' || l_incr_timestamp);

   COMMIT;

   Debug('Elapsed Time (Total Post-Processing): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');



   -- -------------------------------------------------------------------------
   -- Display End Time Message.
   -- -------------------------------------------------------------------------
   Debug('=====================================================================');

   FND_MESSAGE.SET_NAME(application => 'PV',
                        name        => 'PV_CREATE_CONTEXT_END_TIME');
   FND_MESSAGE.SET_TOKEN(token   => 'P_DATE_TIME',
                         value  =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

   IF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

   ELSE
      FND_MSG_PUB.Add;
   END IF;



   l_elapsed_time := DBMS_UTILITY.get_time - l_total_start;
   Debug('=====================================================================');
   Debug('Total Elapsed Time: ' || l_elapsed_time || ' hsec' || ' = ' ||
         ROUND((l_elapsed_time/6000), 2) || ' minutes');
   Debug('=====================================================================');

   RETCODE := g_RETCODE;

   EXCEPTION
      WHEN others THEN
         Debug(SQLCODE || ': ' || SQLERRM);
         RETCODE := '1';

END Exec_Create_Context_Val;
-- ====================End of Exec_Create_Context_Val===========================





--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Pre_Processing                                                          |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Pre_Processing (
   p_refresh_type          IN  VARCHAR2 := g_full_refresh,
   p_synonym_name          IN  VARCHAR2,
   p_mirror_synonym_name   IN  VARCHAR2,
   p_temp_synonym_name     IN  VARCHAR2,
   p_partner_id_temp_table IN  VARCHAR2 := null,
   p_temp_table_processed  IN  BOOLEAN  := FALSE,
   p_last_incr_refresh_str IN  VARCHAR2 := null,
   p_log_to_file           IN  VARCHAR2 := 'Y',
   p_module_name           IN  VARCHAR2,
   p_pv_schema_name        IN  OUT NOCOPY VARCHAR2,
   p_search_table          OUT NOCOPY VARCHAR2,
   p_mirror_table          OUT NOCOPY VARCHAR2,
   p_end_refresh_flag      OUT NOCOPY BOOLEAN,
   p_out_refresh_type      OUT NOCOPY VARCHAR2
)
IS
   -- -----------------------------------------------------------------------
   -- Cursors
   -- -----------------------------------------------------------------------
   CURSOR c_underlying_tables IS
      SELECT synonym_name, table_name
      FROM   dba_synonyms
      WHERE  owner = g_apps_schema AND
             synonym_name IN (p_synonym_name, p_mirror_synonym_name);

   CURSOR c_pv_schema IS
      SELECT i.tablespace,
             i.index_tablespace,
             u.oracle_username
      FROM   fnd_product_installations i,
             fnd_application a,
             fnd_oracle_userid u
      WHERE  a.application_short_name = 'PV' AND
             a.application_id = i.application_id AND
             u.oracle_id = i.oracle_id;

   CURSOR c_synonyms (pc_synonym_name IN VARCHAR2) IS
      SELECT COUNT(*) count
      FROM   user_synonyms
      WHERE  synonym_name = pc_synonym_name;

   -- -----------------------------------------------------------------------
   -- Local Variables
   -- -----------------------------------------------------------------------
   l_partner_sql            VARCHAR2(32000);
   l_num_of_partners        NUMBER;
   l_num_of_blocks          NUMBER;
   l_avg_length             NUMBER;

BEGIN
   p_end_refresh_flag := FALSE;

   IF (p_log_to_file = 'Y') THEN
      g_log_to_file := 'Y';

   ELSE
      g_log_to_file := 'N';
   END IF;


   -- -----------------------------------------------------------------------
   -- Reset the refresh type. If the refresh type is incremental, but the
   -- last incremental refresh timestamp is NULL, set the refresh type to
   -- g_incr_full_refresh ('INCR-FULL').  This means that we will use full
   -- refresh method to perform refresh, but we will still update incremental
   -- refresh timestamp.
   -- -----------------------------------------------------------------------
   IF ((p_refresh_type = g_incr_refresh) AND
       (p_last_incr_refresh_str IS NULL))
   THEN
      Debug('Setting the refresh type to FULL since there is no prior refresh.');
      p_out_refresh_type := g_incr_full_refresh;

   ELSE
      p_out_refresh_type := p_refresh_type;
   END IF;

   -- -----------------------------------------------------------------------
   -- For incremental refresh, an Oracle temporary table must exist.
   -- If it doesn't the refresh type will be changed to a full refresh.
   -- -----------------------------------------------------------------------
   IF ((p_out_refresh_type = g_incr_refresh) AND (p_partner_id_temp_table IS NULL)) THEN
      Debug('-- ************************************************************************ --');
      Debug('-- No Oracle temporary table provided. Incremental refresh will not proceed --');
      Debug('-- A full refresh will be performed instead.                                --');
      Debug('-- ************************************************************************ --');
      p_out_refresh_type := g_full_refresh;
   END IF;


   -- -----------------------------------------------------------------------
   -- Determine "APPS" schema.
   -- -----------------------------------------------------------------------
   IF (g_apps_schema IS NULL) THEN
      FOR x IN (SELECT user FROM dual) LOOP
         g_apps_schema := x.user;
      END LOOP;
   END IF;


   -- -----------------------------------------------------------------------
   -- Determine "PV" schema.
   -- -----------------------------------------------------------------------
   IF (p_pv_schema_name IS NULL) THEN
      FOR x IN c_pv_schema LOOP
         p_pv_schema_name   := x.oracle_username;
      END LOOP;
   END IF;

   -- -----------------------------------------------------------------------
   -- Synonym recovery: recovers the synonyms of the search and the mirror
   -- table in the event of a system crash in the previous concurrent
   -- program run.
   -- -----------------------------------------------------------------------
   Debug('Synonym Recovery..................................................');
   FOR x IN c_synonyms(p_synonym_name) LOOP
      IF (x.count = 0) THEN
         Debug('RENAME ' || p_temp_synonym_name || ' TO ' || p_synonym_name);

         EXECUTE IMMEDIATE
            'RENAME ' || p_temp_synonym_name || ' TO ' || p_synonym_name;
      END IF;
   END LOOP;

   FOR x IN c_synonyms(p_mirror_synonym_name) LOOP
      IF (x.count = 0) THEN
         Debug('RENAME ' || p_temp_synonym_name || ' TO ' || p_mirror_synonym_name);

         EXECUTE IMMEDIATE
            'RENAME ' || p_temp_synonym_name || ' TO ' || p_mirror_synonym_name;
      END IF;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Retrieve the underlying tables of the search and the mirror table.
   -- -----------------------------------------------------------------------
   Debug('Retrieving the underlying tables of the synonyms...................');
   FOR x IN c_underlying_tables LOOP
      IF (x.synonym_name = p_synonym_name) THEN
         p_search_table := x.table_name;

      ELSIF (x.synonym_name = p_mirror_synonym_name) THEN
         p_mirror_table := x.table_name;
      END IF;
   END LOOP;


   -- =======================================================================
   -- Set the appropriate settings/parameters/attributes for different
   -- refresh types.
   -- =======================================================================
   IF ((p_out_refresh_type = g_incr_refresh) AND (p_temp_table_processed)) THEN
      -- ---------------------------------------------------------
      -- Set partner SQL
      -- ---------------------------------------------------------
      l_partner_sql :=
         'SELECT partner_id
          FROM   pv_partner_profiles pvpp
          WHERE  pvpp.status = ''A'' AND
                 partner_resource_id IS NOT NULL AND
                 creation_date >= :last_incr_refresh ';

      -- ---------------------------------------------------------
      -- Insert the list of new partners into the temporary table.
      -- ---------------------------------------------------------
      Debug('Insert the list of new partners into the temporary table.............');
      EXECUTE IMMEDIATE
         'TRUNCATE TABLE ' || p_partner_id_temp_table;

      EXECUTE IMMEDIATE
         'INSERT INTO ' || p_partner_id_temp_table || ' ' ||
         l_partner_sql
      USING TO_DATE(NVL(p_last_incr_refresh_str, '12-31-1900 00:00:01'),
                   'MM-DD-YYYY HH24:MI:SS');

      -- ---------------------------------------------------------
      -- If there are no new partners, mark the flag for exiting
      -- the program.
      -- ---------------------------------------------------------
      IF (SQL%ROWCOUNT = 0) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_NO_NEW_PARTNERS');

         p_end_refresh_flag := TRUE;
         RETURN;

      ELSE
         Debug(SQL%ROWCOUNT || ' new partners found in the system.');

        /* -------------------------------------------------------------
         Debug('.');
         Debug('Partner ID' || ' ' || 'Partner Name');
         Debug('----------' || ' ' || '-------------------------------');

         For x IN (SELECT a.partner_id, c.party_name
                   FROM   pv_partner_id_session a,
                          pv_partner_profiles   b,
                          hz_parties            c
                   WHERE  a.partner_id = b.partner_id AND
                          b.partner_party_id = c.party_id)
         LOOP
            Debug(LPAD(TO_CHAR(x.partner_id), 12) || ' ' || x.party_name);
         END LOOP;
         Debug('.');
         * -------------------------------------------------------------- */
      END IF;


      l_num_of_partners := SQL%ROWCOUNT;
      l_avg_length      := 7;
      l_num_of_blocks   := Compute_Num_of_Blocks(l_num_of_partners, l_avg_length);

      -- -------------------------------------------------------------
      -- Set statistics for the temporary table. Since Oracle 8i does not
      -- generate statistics on a temporary table even if a table is
      -- analyzed.
      -- -------------------------------------------------------------
      Debug('Gathering statistics on the temporary table.........................');
      dbms_stats.set_table_stats(ownname => USER,
                                 tabname => p_partner_id_temp_table,
                                 numrows => l_num_of_partners,
                                 numblks => l_num_of_blocks,
                                 avgrlen => l_avg_length);

   -- =======================================================================
   -- Full or 'INCR-FULL' Refresh
   -- =======================================================================
   ELSE
      Debug('Set the mirror table to NOLOGGING mode.........................');
      EXECUTE IMMEDIATE
         'ALTER TABLE ' || p_pv_schema_name || '.' || p_mirror_table ||
         ' NOLOGGING';

      -- ---------------------------------------------------------
      -- Truncate the mirror table whether it's empty or not.
      -- ---------------------------------------------------------
      Debug('Truncate the mirror table.......................................');
      EXECUTE IMMEDIATE
         'TRUNCATE TABLE ' || p_pv_schema_name || '.' || p_mirror_table;

      -- ---------------------------------------------------------
      -- * Make all non-unique indexes unusable.
      -- * Disable all primary and unique constraints, which,
      --   in effect, drop the associated unique indexes.
      -- * Drop all the remaining unique indexes.
      -- ---------------------------------------------------------
      Debug('Drop unique indexes and make nonunique indexes ' ||
            'unusable on the mirror table...');

      Disable_Drop_Indexes(p_mirror_table, p_pv_schema_name);
   END IF;

END Pre_Processing;
-- ===========================End of Pre_Processing==========================



--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Post_Processing                                                         |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Post_Processing (
   p_refresh_type          IN  VARCHAR2 := g_full_refresh,
   p_synonym_name          IN  VARCHAR2,
   p_mirror_synonym_name   IN  VARCHAR2,
   p_temp_synonym_name     IN  VARCHAR2,
   p_pv_schema_name        IN  VARCHAR2,
   p_search_table          IN  VARCHAR2,
   p_mirror_table          IN  VARCHAR2,
   p_incr_timestamp        IN  VARCHAR2,
   p_api_package_name      IN  VARCHAR2,
   p_module_name           IN  VARCHAR2,
   p_log_to_file           IN  VARCHAR2 := 'Y'
)
IS
   l_start                  NUMBER;
   l_elapsed_time           NUMBER;
   l_ret_val                BOOLEAN := FALSE;

BEGIN
   IF (p_log_to_file = 'Y') THEN
      g_log_to_file := 'Y';

   ELSE
      g_log_to_file := 'N';
   END IF;

   IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
      -- --------------------------------------------------------------
      -- Recreate unique indexes and rebuild nonunique indexes.
      -- --------------------------------------------------------------
      l_start := dbms_utility.get_time;
      dbms_application_info.set_module(
         module_name => p_module_name,
         action_name => 'Post: Rebuild Indexes'
      );
      Debug('Recreate and rebuild indexes on the mirror table AND');
      Debug('Synch up indexes between the search and the mirror table...');

      Enable_Create_Indexes(
         p_search_table,
         p_mirror_table,
         p_pv_schema_name
      );

      -- --------------------------------------------------------------
      -- Analyze the mirror table.
      -- --------------------------------------------------------------
      dbms_application_info.set_module(
         module_name => p_module_name,
         action_name => 'Post: Analyze Tables'
      );
      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
      l_start := dbms_utility.get_time;
      Debug('Analyze the mirror table...');

      dbms_stats.gather_table_stats(
         ownname => p_pv_schema_name,
         tabname => p_mirror_table,
         estimate_percent => 10,
         method_opt => 'FOR ALL INDEXES'
      );

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
      l_start := dbms_utility.get_time;

      -- --------------------------------------------------------------
      -- Rename synonyms.
      -- --------------------------------------------------------------
      dbms_application_info.set_module(
         module_name => p_module_name,
         action_name => 'Post: Swapping Synonyms'
      );
      Debug('Synonym swapping and other post processing activities...');


      EXECUTE IMMEDIATE
        'RENAME ' || p_synonym_name || ' TO ' || p_temp_synonym_name;

      EXECUTE IMMEDIATE
        'RENAME ' || p_mirror_synonym_name || ' TO ' || p_synonym_name;

      EXECUTE IMMEDIATE
        'RENAME ' || p_temp_synonym_name || ' TO ' || p_mirror_synonym_name;

      -- --------------------------------------------------------------
      -- Recompile invalid dependent package bodies.
      -- --------------------------------------------------------------
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Post: Compile Dependencies'
      );
      Debug('Recompile invalid dependent package bodies...');

      Recompile_Dependencies(
         p_referenced_type  => 'SYNONYM',
         p_referenced_name1 => p_synonym_name,
         p_referenced_name2 => p_mirror_synonym_name,
         p_api_package_name => p_api_package_name
      );


      -- --------------------------------------------------------------
      -- Truncate the "search" table.
      -- --------------------------------------------------------------
      dbms_application_info.set_module(
         module_name => p_module_name,
         action_name => 'Post: Truncate Table'
      );
      Debug('Truncate the search table...');

      EXECUTE IMMEDIATE
         'TRUNCATE TABLE ' || p_pv_schema_name || '.' || p_search_table;
   END IF;

END Post_Processing;
-- ===========================End of Post_Processing==========================



-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************




--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token1 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        END IF;

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        IF (g_log_to_file = 'N') THEN
           FND_MSG_PUB.Add;

        ELSIF (g_log_to_file = 'Y') THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
        END IF;
    END IF;
END Set_Message;
-- ==============================End of Set_Message==============================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Compute_Num_of_Blocks                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Compute_Num_of_Blocks(
   p_num_of_rows   IN NUMBER,
   p_avg_length    IN NUMBER
)
RETURN NUMBER
IS
   CURSOR c_block_size IS
      SELECT value
      FROM   v$parameter
      WHERE  name = 'db_block_size';

   l_db_block_size       NUMBER;
   l_data_size           NUMBER;

   -- ----------------------------------------------------------------
   -- The part of the block that is used for block overhead.
   -- Set it to 1/8 --> 0.125. (this is a guestimate value).
   -- ----------------------------------------------------------------
   l_overhead_ratio      NUMBER := 0.125;

BEGIN
   l_data_size := p_num_of_rows * p_avg_length;

   FOR x IN c_block_size LOOP
      l_db_block_size := TO_NUMBER(x.value);
   END LOOP;

   RETURN (l_db_block_size - (l_db_block_size * l_overhead_ratio))/l_data_size;

END Compute_Num_of_Blocks;
-- ===========================End of Compute_Num_of_Blocks=======================






--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Insert_Functional_Expertise                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Insert_Functional_Expertise (
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
)
IS

   l_insert_header VARCHAR2(200);
   l_insert_body   VARCHAR2(1000);
   l_ddl_str       VARCHAR2(4000);

BEGIN
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Inside Attribute ID 1'
   );



   IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
      INSERT /*+ APPEND */
      INTO  pv_search_attr_mirror (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number
      )
      SELECT   pv_search_attr_values_s.nextval,
               entity_id,
               1,
               attr_value,
               SYSDATE,
               p_user_id,
               SYSDATE,
               p_user_id,
               p_user_id,
               1.0
      FROM (
         SELECT   DISTINCT
                  a.entity_id,
                  DENORM.child_id attr_value
         FROM     pv_enty_attr_values a,
                  pv_entity_attrs     b,
                  eni_prod_denorm_hrchy_v DENORM
         WHERE    b.attribute_id = 1 AND
                  a.latest_flag  = 'Y' AND
                  a.entity       = 'PARTNER' AND
                  a.attr_value   = TO_CHAR(DENORM.parent_id) AND
                  a.attribute_id = b.attribute_id AND
                  b.entity       = 'PARTNER' AND
                 (b.last_refresh_date IS NULL OR
                  b.refresh_frequency IS NULL OR
                  b.refresh_frequency_uom IS NULL OR
                 (b.last_refresh_date +
                     DECODE(b.refresh_frequency_uom,
                        'HOUR',  b.refresh_frequency/24,
                        'DAY',   b.refresh_frequency,
                        'WEEK',  b.refresh_frequency * 7,
                        'MONTH', ADD_MONTHS(TRUNC(NVL(b.last_refresh_date, SYSDATE), 'MM'),
                                    b.refresh_frequency)
                                 - NVL(b.last_refresh_date, SYSDATE)
                     )
                  ) <= SYSDATE)
         );


      Debug(SQL%ROWCOUNT || ' rows inserted.');

      -- ---------------------------------------------------------------
      -- Update timestamp
      -- ---------------------------------------------------------------
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Timestamp Attribute ID 1'
      );

      Update_Timestamp (
         p_attribute_id  => 1,
         p_timestamp     => SYSDATE
      );

      COMMIT;

   ELSE
      -- ----------------------------------------------------------------
      -- In an incremental refresh (new partners only refresh), make
      -- sure the records are not already in the search table before
      -- inserting the records.
      -- ----------------------------------------------------------------
      DELETE FROM pv_search_attr_values
      WHERE  attribute_id = 1 AND
             party_id IN (SELECT partner_id FROM pv_partner_id_session);


      INSERT
      INTO  pv_search_attr_values (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number
      )
      SELECT   pv_search_attr_values_s.nextval,
               entity_id,
               1,
               attr_value,
               SYSDATE,
               p_user_id,
               SYSDATE,
               p_user_id,
               p_user_id,
               1.0
      FROM (
         SELECT   DISTINCT
                  a.entity_id,
                  DENORM.child_id attr_value
         FROM     pv_enty_attr_values a,
                  pv_partner_id_session b,
                  eni_prod_denorm_hrchy_v DENORM
         WHERE    a.attribute_id = 1 AND
                  a.latest_flag  = 'Y' AND
                  a.entity       = 'PARTNER' AND
                  a.entity_id    = b.partner_id AND
                  a.attr_value   = TO_CHAR(DENORM.parent_id));

      Debug(SQL%ROWCOUNT || ' rows inserted.');

   END IF;


   EXCEPTION
      WHEN others THEN
         Debug('Exception raised while inserting for "functional expertise" ' ||
               '(Attribute ID = 1)');
         Debug(SQLCODE);
         Debug(SQLERRM);

         g_RETCODE := '1';

END Insert_Functional_Expertise;
-- =======================End of Insert_Functional_Expertise====================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Insert_Internal                                                         |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Insert_Internal (
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
)
IS
   -- ----------------------------------------------------------------------
   -- Local Variables
   -- ----------------------------------------------------------------------
   l_last_message     VARCHAR2(30000);
   l_start            NUMBER;
   l_total_start      NUMBER;
   l_count            NUMBER;

   -- ----------------------------------------------------------------------
   -- Currency Attributes - Internal
   -- ----------------------------------------------------------------------
   CURSOR c_currency_attrs IS
      SELECT a.attribute_id, b.name
      FROM   pv_entity_attrs  a,
             pv_attributes_vl b
      WHERE  b.attribute_id <> 1 AND
             a.attribute_id = b.attribute_id AND
             a.enabled_flag = 'Y' AND
             b.enabled_flag = 'Y' AND
            (b.enable_matching_flag = 'Y' OR
             a.display_external_value_flag = 'Y') AND
             a.entity = 'PARTNER' AND
             a.attr_data_type IN ('INTERNAL', 'INT_EXT')AND
            (a.last_refresh_date IS NULL OR
             a.refresh_frequency IS NULL OR
             a.refresh_frequency_uom IS NULL OR
            (last_refresh_date +
                DECODE(refresh_frequency_uom,
                   'HOUR',  refresh_frequency/24,
                   'DAY',   refresh_frequency,
                   'WEEK',  refresh_frequency * 7,
                   'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                               refresh_frequency)
                            - NVL(last_refresh_date, SYSDATE)
                )
             ) <= SYSDATE) AND
             b.return_type = 'CURRENCY'
      ORDER  BY a.attribute_id;

   i            NUMBER := 1;
   l_total_rows NUMBER := 0;

BEGIN
   -- *****************************************************************
   -- *****************************************************************
   --                   Currency Attributes Refresh
   -- *****************************************************************
   -- *****************************************************************
   l_total_start := dbms_utility.get_time;

   Debug('-- **********************************************************');
   Debug('-- Processing internal CURRENCY attributes...');
   Debug('-- **********************************************************');

   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Internal - CURRENCY'
   );

   -- -----------------------------------------------------------------
   -- Process currency attributes one attribute at a time.
   -- Within each attribute, it's a all-or-nothing operation. If
   -- currency conversion fails for even one record, the whole operation
   -- will be "rolled back".
   -- -----------------------------------------------------------------
   FOR x IN c_currency_attrs LOOP
    BEGIN
      l_start := dbms_utility.get_time;

      -- --------------------------------------------------------------
      -- Full Refresh
      -- --------------------------------------------------------------
      IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
         INSERT /*+ APPEND */
         INTO  pv_search_attr_mirror (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               ATTR_VALUE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
         SELECT pv_search_attr_values_s.nextval,
                entity_id,
                x.attribute_id,
                attr_text,
                attr_value,
                SYSDATE,
                p_user_id,
                SYSDATE,
                p_user_id,
                p_user_id,
                1.0
         FROM (
            SELECT DISTINCT a.entity_id,
                   a.attr_value attr_text,
                   pv_check_match_pub.Currency_Conversion(
                      a.attr_value, g_common_currency) attr_value
            FROM   pv_enty_attr_values a,
                   pv_partner_profiles PV
            WHERE  a.entity       = 'PARTNER' AND
                   a.latest_flag  = 'Y' AND
                   a.entity_id    = PV.partner_id AND
                   PV.partner_resource_id IS NOT NULL AND
                   PV.status = 'A' AND
                   a.attr_value IS NOT NULL AND
                   a.attribute_id = x.attribute_id);

         Debug('Processing Attribute "' || x.name || '" (Attribute ID = ' ||
                x.attribute_id || ')');
         Debug(SQL%ROWCOUNT || ' rows processed.');

         l_total_rows := l_total_rows + SQL%ROWCOUNT;


         Update_Timestamp (
            p_attribute_id  => x.attribute_id,
            p_timestamp     => SYSDATE
         );

         COMMIT;

      -- --------------------------------------------------------------
      -- Partial Refresh
      -- --------------------------------------------------------------
      ELSE
         -- ----------------------------------------------------------------
         -- In an incremental refresh (new partners only refresh), make
         -- sure the records are not already in the search table before
         -- inserting the records.
         -- ----------------------------------------------------------------
         DELETE FROM pv_search_attr_values
         WHERE  attribute_id = x.attribute_id AND
                party_id IN (SELECT partner_id FROM pv_partner_id_session);


         INSERT
         INTO  pv_search_attr_values (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               ATTR_VALUE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
         SELECT pv_search_attr_values_s.nextval,
                entity_id,
                x.attribute_id,
                attr_text,
                attr_value,
                SYSDATE,
                p_user_id,
                SYSDATE,
                p_user_id,
                p_user_id,
                1.0
         FROM (
            SELECT DISTINCT a.entity_id,
                   a.attr_value attr_text,
                   pv_check_match_pub.Currency_Conversion(
                       a.attr_value, g_common_currency) attr_value
            FROM   pv_enty_attr_values a,
                   pv_partner_id_session b
            WHERE  a.entity       = 'PARTNER' AND
                   a.latest_flag  = 'Y' AND
                   a.attr_value IS NOT NULL AND
                   a.entity_id    = b.partner_id AND
                   a.attribute_id = x.attribute_id);

         Debug('Processing Attribute "' || x.name || '" (Attribute ID = ' ||
                x.attribute_id || ')');
         Debug(SQL%ROWCOUNT || ' rows processed.');

         l_total_rows := l_total_rows + SQL%ROWCOUNT;
      END IF;

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            -- -------------------------------------------------------------------
            -- Retrieve the last message from the message queue which
            -- contains the exception raised by the called program
            -- e.g. currency_conversion
            -- -------------------------------------------------------------------
            -- Reset the pointer to the last message of the queue
            fnd_msg_pub.reset(fnd_msg_pub.G_LAST);

            -- -------------------------------------------------------------------
            -- Go back to the second to last message which contains the message
            -- raised by the called program (e.g. currency_conversion)
            -- -------------------------------------------------------------------
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            Debug(l_last_message);

            Debug('Attribute ID: ' || x.attribute_id);
            Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

            g_RETCODE := '1';

            -- -------------------------------------------------------------------
            -- If there is an exception with curreny_conversion, we need to "roll"
            -- back changes. In our case, this means copy from the search table
            -- and insert into the mirror table.
            -- -------------------------------------------------------------------
            IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
               INSERT /*+ APPEND */ INTO pv_search_attr_mirror
                 (SEARCH_ATTR_VALUES_ID,
                  PARTY_ID,
                  SHORT_NAME,
                  ATTR_TEXT,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATED_BY,
                  SECURITY_GROUP_ID,
                  ATTRIBUTE_ID,
                  ATTR_VALUE
                 )
               SELECT SEARCH_ATTR_VALUES_ID,
                  PARTY_ID,
                  SHORT_NAME,
                  ATTR_TEXT,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATED_BY,
                  SECURITY_GROUP_ID,
                  ATTRIBUTE_ID,
                  ATTR_VALUE
               FROM   pv_search_attr_values
               WHERE  attribute_id = x.attribute_id;

               COMMIT;
            END IF;
    END;
   END LOOP;



   -- *****************************************************************
   -- *****************************************************************
   --               Full Refresh - non-Currency Attributes
   -- *****************************************************************
   -- *****************************************************************
   IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
      -- --------------------------------------------------------------------------
      -- Process NUMBER return_type.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('-- **********************************************************');
      Debug('-- Processing Internal Number attributes...');
      Debug('-- **********************************************************');

      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Internal - NUMBER'
      );

      INSERT /*+ APPEND */
      INTO  pv_search_attr_mirror (
            SEARCH_ATTR_VALUES_ID,
            PARTY_ID,
            ATTRIBUTE_ID,
            ATTR_VALUE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN ,
            OBJECT_Version_number)
      SELECT pv_search_attr_values_s.nextval,
             entity_id,
             attribute_id,
             TO_NUMBER(attr_value),
             SYSDATE,
             p_user_id,
             SYSDATE,
             p_user_id,
             p_user_id,
             1.0
      FROM (
      SELECT DISTINCT a.entity_id, a.attr_value attr_value, a.attribute_id
      FROM   pv_enty_attr_values a,
             pv_partner_profiles PV
      WHERE  a.entity      = 'PARTNER' AND
             a.latest_flag = 'Y' AND
             a.attr_value IS NOT NULL AND
             a.entity_id   = PV.partner_id AND
             PV.partner_resource_id IS NOT NULL AND
             PV.status     = 'A' AND
             a.attribute_id IN (
                SELECT a.attribute_id
                FROM   pv_entity_attrs  a,
                       pv_attributes_b  b
                WHERE  b.attribute_id <> 1 AND
                       a.attribute_id = b.attribute_id AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                       b.enable_matching_flag = 'Y' AND
                       a.entity = 'PARTNER' AND
                       a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                      (a.last_refresh_date IS NULL OR
                       a.refresh_frequency IS NULL OR
                       a.refresh_frequency_uom IS NULL OR
                      (last_refresh_date +
                          DECODE(refresh_frequency_uom,
                             'HOUR',  refresh_frequency/24,
                             'DAY',   refresh_frequency,
                             'WEEK',  refresh_frequency * 7,
                             'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                         refresh_frequency)
                                      - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE) AND
                       b.return_type = 'NUMBER'));

      Debug(SQL%ROWCOUNT || ' rows processed.');
      l_total_rows := l_total_rows + SQL%ROWCOUNT;

      -- --------------------------------------------------------------------------
      -- Update timestamp
      -- --------------------------------------------------------------------------
      FOR x IN (SELECT a.attribute_id
                FROM   pv_entity_attrs  a,
                       pv_attributes_b  b
                WHERE  b.attribute_id <> 1 AND
                       a.attribute_id = b.attribute_id AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                      (b.enable_matching_flag = 'Y' OR
                       a.display_external_value_flag = 'Y') AND
                       a.entity = 'PARTNER' AND
                       a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                      (a.last_refresh_date IS NULL OR
                       a.refresh_frequency IS NULL OR
                       a.refresh_frequency_uom IS NULL OR
                      (last_refresh_date +
                          DECODE(refresh_frequency_uom,
                             'HOUR',  refresh_frequency/24,
                             'DAY',   refresh_frequency,
                             'WEEK',  refresh_frequency * 7,
                             'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                         refresh_frequency)
                                      - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE) AND
                       b.return_type = 'NUMBER')
      LOOP
         Update_Timestamp (
            p_attribute_id  => x.attribute_id,
            p_timestamp     => SYSDATE
         );
      END LOOP;

      COMMIT;

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');


      -- --------------------------------------------------------------------------
      -- Process return_types other than NUMBER and CURRENCY.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('-- **********************************************************');
      Debug('-- Processing internal OTHER attributes...');
      Debug('-- **********************************************************');
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Internal - OTHER'
      );

      -- ----------------------------------------------------------------------
      -- In R12, there is a concept of primary partner type and secondary
      -- partner type (attribute_id = 3). A primary partner type is indicated
      -- by marking pv_enty_attr_values.attr_value_extn as 'Y'. Only primary
      -- partner type of a partner needs to be populated in the search table.
      -- ----------------------------------------------------------------------
      INSERT /*+ APPEND */
      INTO  pv_search_attr_mirror (
            SEARCH_ATTR_VALUES_ID,
            PARTY_ID,
            ATTRIBUTE_ID,
            ATTR_TEXT,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN ,
            OBJECT_Version_number)
      SELECT pv_search_attr_values_s.nextval,
             entity_id,
             attribute_id,
             attr_value,
             SYSDATE,
             p_user_id,
             SYSDATE,
             p_user_id,
             p_user_id,
             1.0
      FROM (
      SELECT DISTINCT a.entity_id, a.attr_value attr_value, a.attribute_id
      FROM   pv_enty_attr_values a,
             pv_partner_profiles PV
      WHERE  a.entity      = 'PARTNER' AND
             a.latest_flag = 'Y' AND
             a.attr_value IS NOT NULL AND
             DECODE(a.attribute_id, 3, attr_value_extn, 'Y') = 'Y' AND
             a.entity_id   = PV.partner_id AND
             PV.partner_resource_id IS NOT NULL AND
             PV.status     = 'A' AND
             a.attribute_id IN (
                SELECT a.attribute_id
                FROM   pv_entity_attrs  a,
                       pv_attributes_b  b
                WHERE  b.attribute_id <> 1 AND
                       a.attribute_id = b.attribute_id AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                      (b.enable_matching_flag = 'Y' OR
                       a.display_external_value_flag = 'Y') AND
                       a.entity = 'PARTNER' AND
                       a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                      (a.last_refresh_date IS NULL OR
                       a.refresh_frequency IS NULL OR
                       a.refresh_frequency_uom IS NULL OR
                      (last_refresh_date +
                          DECODE(refresh_frequency_uom,
                             'HOUR',  refresh_frequency/24,
                             'DAY',   refresh_frequency,
                             'WEEK',  refresh_frequency * 7,
                             'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                         refresh_frequency)
                                      - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE) AND
                       b.return_type NOT IN ('NUMBER', 'CURRENCY')));

      Debug(SQL%ROWCOUNT || ' rows processed.');
      l_total_rows := l_total_rows + SQL%ROWCOUNT;

      -- --------------------------------------------------------------------------
      -- Update timestamp
      -- --------------------------------------------------------------------------
      FOR x IN (SELECT a.attribute_id
                FROM   pv_entity_attrs  a,
                       pv_attributes_b  b
                WHERE  b.attribute_id <> 1 AND
                       a.attribute_id = b.attribute_id AND
                       a.enabled_flag = 'Y' AND
                       b.enabled_flag = 'Y' AND
                      (b.enable_matching_flag = 'Y' OR
                       a.display_external_value_flag = 'Y') AND
                       a.entity = 'PARTNER' AND
                       a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                      (a.last_refresh_date IS NULL OR
                       a.refresh_frequency IS NULL OR
                       a.refresh_frequency_uom IS NULL OR
                      (last_refresh_date +
                          DECODE(refresh_frequency_uom,
                             'HOUR',  refresh_frequency/24,
                             'DAY',   refresh_frequency,
                             'WEEK',  refresh_frequency * 7,
                             'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                         refresh_frequency)
                                      - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE) AND
                       b.return_type NOT IN ('NUMBER', 'CURRENCY'))
      LOOP
         Update_Timestamp (
            p_attribute_id  => x.attribute_id,
            p_timestamp     => SYSDATE
         );
      END LOOP;

      COMMIT;

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');



   -- *****************************************************************
   -- *****************************************************************
   --              Partial Refresh - non-Currency Attributes
   -- *****************************************************************
   -- *****************************************************************
   ELSE
      -- --------------------------------------------------------------------------
      -- Process Internal NUMBER return_type.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('-- **********************************************************');
      Debug('-- Processing internal NUMBER attributes...');
      Debug('-- **********************************************************');
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Internal - NUMBER'
      );

      -- ----------------------------------------------------------------
      -- In an incremental refresh (new partners only refresh), make
      -- sure the records are not already in the search table before
      -- inserting the records.
      -- ----------------------------------------------------------------
      DELETE FROM pv_search_attr_values
      WHERE  party_id IN (SELECT partner_id FROM pv_partner_id_session) AND
             attribute_id IN (
                   SELECT a.attribute_id
                   FROM   pv_entity_attrs  a,
                          pv_attributes_b  b
                   WHERE  b.attribute_id <> 1 AND
                          a.attribute_id = b.attribute_id AND
                          a.enabled_flag = 'Y' AND
                          b.enabled_flag = 'Y' AND
                         (b.enable_matching_flag = 'Y' OR
                          a.display_external_value_flag = 'Y') AND
                          a.entity = 'PARTNER' AND
                          a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                          b.return_type = 'NUMBER');


      INSERT
      INTO  pv_search_attr_values (
            SEARCH_ATTR_VALUES_ID,
            PARTY_ID,
            ATTRIBUTE_ID,
            ATTR_VALUE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN ,
            OBJECT_Version_number)
      SELECT pv_search_attr_values_s.nextval,
             entity_id,
             attribute_id,
             TO_NUMBER(attr_value),
             SYSDATE,
             p_user_id,
             SYSDATE,
             p_user_id,
             p_user_id,
             1.0
      FROM (
         SELECT DISTINCT a.entity_id, attr_value attr_value, attribute_id
         FROM   pv_enty_attr_values a,
                pv_partner_id_session b
         WHERE  a.entity = 'PARTNER' AND
                a.entity_id = b.partner_id AND
                latest_flag = 'Y' AND
                attr_value IS NOT NULL AND
                attribute_id IN (
                   SELECT a.attribute_id
                   FROM   pv_entity_attrs  a,
                          pv_attributes_b  b
                   WHERE  b.attribute_id <> 1 AND
                          a.attribute_id = b.attribute_id AND
                          a.enabled_flag = 'Y' AND
                          b.enabled_flag = 'Y' AND
                         (b.enable_matching_flag = 'Y' OR
                          a.display_external_value_flag = 'Y') AND
                          a.entity = 'PARTNER' AND
                          a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                          b.return_type = 'NUMBER'));

      Debug(SQL%ROWCOUNT || ' rows processed.');
      l_total_rows := l_total_rows + SQL%ROWCOUNT;

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');


      -- --------------------------------------------------------------------------
      -- Process return_types other than NUMBER and CURRENCY.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('-- **********************************************************');
      Debug('-- Processing internal OTHER attributes...');
      Debug('-- **********************************************************');
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Internal - OTHER'
      );

      -- ----------------------------------------------------------------
      -- In an incremental refresh (new partners only refresh), make
      -- sure the records are not already in the search table before
      -- inserting the records.
      -- ----------------------------------------------------------------
      DELETE FROM pv_search_attr_values
      WHERE  party_id IN (SELECT partner_id FROM pv_partner_id_session) AND
             attribute_id IN (
                   SELECT a.attribute_id
                   FROM   pv_entity_attrs  a,
                          pv_attributes_b  b
                   WHERE  b.attribute_id <> 1 AND
                          a.attribute_id = b.attribute_id AND
                          a.enabled_flag = 'Y' AND
                          b.enabled_flag = 'Y' AND
                         (b.enable_matching_flag = 'Y' OR
                          a.display_external_value_flag = 'Y') AND
                          a.entity = 'PARTNER' AND
                          a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                          b.return_type NOT IN ('NUMBER', 'CURRENCY'));

      -- ----------------------------------------------------------------------
      -- In R12, there is a concept of primary partner type and secondary
      -- partner type (attribute_id = 3). A primary partner type is indicated
      -- by marking pv_enty_attr_values.attr_value_extn as 'Y'. Only primary
      -- partner type of a partner needs to be populated in the search table.
      -- ----------------------------------------------------------------------

      INSERT
      INTO  pv_search_attr_values (
            SEARCH_ATTR_VALUES_ID,
            PARTY_ID,
            ATTRIBUTE_ID,
            ATTR_TEXT,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN ,
            OBJECT_Version_number)
      SELECT pv_search_attr_values_s.nextval,
             entity_id,
             attribute_id,
             attr_value,
             SYSDATE,
             p_user_id,
             SYSDATE,
             p_user_id,
             p_user_id,
             1.0
      FROM (
         SELECT DISTINCT a.entity_id, attr_value attr_value, attribute_id
         FROM   pv_enty_attr_values a,
                pv_partner_id_session b
         WHERE  a.entity = 'PARTNER' AND
                a.entity_id = b.partner_id AND
                latest_flag = 'Y' AND
                attr_value IS NOT NULL AND
                DECODE(a.attribute_id, 3, attr_value_extn, 'Y') = 'Y' AND
                attribute_id IN (
                   SELECT a.attribute_id
                   FROM   pv_entity_attrs  a,
                          pv_attributes_b  b
                   WHERE  b.attribute_id <> 1 AND
                          a.attribute_id = b.attribute_id AND
                          a.enabled_flag = 'Y' AND
                          b.enabled_flag = 'Y' AND
                         (b.enable_matching_flag = 'Y' OR
                          a.display_external_value_flag = 'Y') AND
                          a.entity = 'PARTNER' AND
                          a.attr_data_type IN ('INTERNAL', 'INT_EXT') AND
                          b.return_type NOT IN ('NUMBER', 'CURRENCY')));

      Debug(SQL%ROWCOUNT || ' rows processed.');
      l_total_rows := l_total_rows + SQL%ROWCOUNT;

      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   END IF;


   Debug('Total Elapsed Time (Internal: ' ||
         (DBMS_UTILITY.get_time - l_total_start) || ' hsec');
   Debug('Total Number of Rows Processed for This Operation: ' || l_total_rows);
   Debug('Throughput: ' ||
           ROUND((l_total_rows/(DBMS_UTILITY.get_time - l_total_start)) * 100, 2) ||
           ' rows/second');

   EXCEPTION
      WHEN others THEN
         Debug('Exception Raised...');
         Debug(SQLCODE);
         Debug(SQLERRM);
         g_RETCODE := '1';

END Insert_Internal;
-- ======================End of Insert_Internal =====================================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Insert_External                                                         |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Insert_External (
   p_refresh_type IN VARCHAR2,
   p_user_id      IN NUMBER
)
IS
   CURSOR c_num_cur_attributes IS
      SELECT a.attribute_id, a.batch_sql_text, b.name, b.return_type,
             b.performance_flag
      FROM   pv_entity_attrs  a,
             pv_attributes_vl b
      WHERE  b.attribute_id <> 1 AND
             a.attribute_id = b.attribute_id AND
             a.enabled_flag = 'Y' AND
             b.enabled_flag = 'Y' AND
            (b.enable_matching_flag = 'Y' OR
             a.display_external_value_flag = 'Y') AND
             a.entity = 'PARTNER' AND
            (a.attr_data_type IN ('EXTERNAL', 'EXT_INT') OR
            (NVL(b.performance_flag, 'N') = 'Y')) AND
             b.attribute_type <> 'FUNCTION' AND
             b.return_type IN ('NUMBER', 'CURRENCY')
      ORDER  BY a.attribute_id;


   CURSOR c_other_attributes IS
      SELECT a.attribute_id, a.batch_sql_text, b.name, b.return_type,
             b.performance_flag
      FROM   pv_entity_attrs  a,
             pv_attributes_vl b
      WHERE  b.attribute_id <> 1 AND
             a.attribute_id = b.attribute_id AND
             a.enabled_flag = 'Y' AND
             b.enabled_flag = 'Y' AND
            (b.enable_matching_flag = 'Y' OR
             a.display_external_value_flag = 'Y') AND
             a.entity = 'PARTNER' AND
            (a.attr_data_type IN ('EXTERNAL', 'EXT_INT') OR
             NVL(b.performance_flag, 'N') = 'Y') AND
             b.attribute_type <> 'FUNCTION' AND
             b.return_type NOT IN ('NUMBER', 'CURRENCY')
      ORDER  BY a.attribute_id;


   TYPE t_ref_cursor IS REF CURSOR;
   lc_currency_att_values  t_ref_cursor;

   l_do_not_process     BOOLEAN := FALSE;

   l_start              NUMBER;
   l_start2             NUMBER;
   l_insert_sql         VARCHAR2(4000);
   l_ddl_sql            VARCHAR2(32000);
   l_batch_sql_text     VARCHAR2(5000);
   l_partner_id         NUMBER;
   l_last_message       VARCHAR2(30000);
   l_new_partner_clause VARCHAR2(100) :=
     ' AND partner_id IN (SELECT partner_id FROM ' || g_partner_temp_table || ')';

BEGIN
      -- *****************************************************************
      -- *****************************************************************
      --         Full/Incr Refresh - External Attributes
      -- *****************************************************************
      -- *****************************************************************
      -- --------------------------------------------------------------------------
      -- Set the insert statement, which will later be appended with batch_sql_text
      -- to create the full insert statment.
      -- --------------------------------------------------------------------------
      l_insert_sql :=
        'INSERT /*+ APPEND */
         INTO  pv_search_attr_mirror (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT_DUMMY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
         SELECT pv_search_attr_values_s.nextval,
                partner_id,
                ATTRIBUTE_ID_DUMMY,
                --attr_value,
                SYSDATE,
                :p_user_id,
                SYSDATE,
                :p_user_id,
                :p_user_id,
                1.0
         FROM (';


      IF (p_refresh_type = g_incr_refresh) THEN
         l_insert_sql := REPLACE(l_insert_sql, '/*+ APPEND */', ' ');
         l_insert_sql := REPLACE(l_insert_sql, 'pv_search_attr_mirror (',
                            'pv_search_attr_values (');
      END IF;

      -- --------------------------------------------------------------------------
      -- Process NUMBER and CURRENCY return_type.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('-- **********************************************************');
      Debug('-- Processing External NUMBER and CURRENCY attributes...');
      Debug('-- **********************************************************');
      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'External - NUM/CURRENCY'
      );


      FOR x IN c_num_cur_attributes LOOP
       l_do_not_process := FALSE;
       -- -----------------------------------------------------------------
       -- Determine the attribute should be refreshed based on refresh
       -- frequency.
       -- -----------------------------------------------------------------
       IF (p_refresh_type <> g_incr_refresh) THEN
          FOR y IN (SELECT COUNT(*) cnt
                    FROM   pv_entity_attrs
                    WHERE  attribute_id = x.attribute_id AND
                           entity       = 'PARTNER' AND
                          (last_refresh_date IS NULL OR
                           refresh_frequency IS NULL OR
                           refresh_frequency_uom IS NULL OR
                           refresh_frequency_uom IS NULL OR
                          (last_refresh_date +
                           DECODE(refresh_frequency_uom,
                                 'HOUR',  refresh_frequency/24,
                                 'DAY',   refresh_frequency,
                                 'WEEK',  refresh_frequency * 7,
                                 'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                             refresh_frequency)
                                          - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE))
          LOOP
             IF (y.cnt = 0) THEN
                l_do_not_process := TRUE;
             END IF;
          END LOOP;
       END IF;

       IF (NOT l_do_not_process) THEN

       IF (p_refresh_type = g_incr_refresh AND x.performance_flag = 'Y') THEN
         -- ---------------------------------------------------------------
         -- Cannot use batch_sql_text to perform refresh for performance
         -- attrubutes in an incremental refresh.
         -- ---------------------------------------------------------------
         null;

       ELSE
         l_start2 := dbms_utility.get_time;

         IF (x.batch_sql_text IS NULL) THEN
            Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name     => 'PV_ABSENT_BATCH_SQL_TEXT',
                        p_token1       => 'Attribute Name',
                        p_token1_value => x.name,
                        p_token2       => 'Attribute ID',
                        p_token2_value => x.attribute_id);

         ELSE


            -- ----------------------------------------------------------------
            -- Replace ATTRIBUTE_ID_DUMMY with the real attribute_id. Also
            -- append the batch_sql_text to the insert statement.
            -- ----------------------------------------------------------------
            IF (x.return_type = 'CURRENCY') THEN
               -- -----------------------------------------------------------------
               -- For performance attributes, we want to change ATTRIBUTE_ID_DUMMY
               -- into:
               -- <attribute_id>,
               -- attr_value attr_text,
               -- SUBSTR(attr_value, 1, INSTR(attr_value, '':::'') - 1) ATTR_VALUE
               --
               -- That is, we want to parse out the currency amount in the currency
               -- string and insert the value into attr_value column in
               -- pv_search_attr_values.
               -- -----------------------------------------------------------------
               IF (x.performance_flag = 'Y') THEN
                  l_ddl_sql := REPLACE(l_insert_sql, 'partner_id', 'entity_id partner_id');

                  l_ddl_sql := REPLACE(l_ddl_sql, 'ATTRIBUTE_ID_DUMMY',
                                       x.attribute_id || ', attr_value ATTR_TEXT, ' ||
                                      'SUBSTR(attr_value, 1, INSTR(attr_value, '':::'') - 1) ATTR_VALUE');

               -- -----------------------------------------------------------------
               -- For non-performance attributes, we want to change
               -- ATTRIBUTE_ID_DUMMY into:
               --
               -- <attribute_id>,
               -- attr_value attr_text,
               -- pv_check_match_pub.currency_conversion(
               --    attr_value, <g_common_currency>, 'Y') ATTR_VALUE
               --
               -- -----------------------------------------------------------------
               ELSE
                  l_ddl_sql := REPLACE(l_insert_sql, 'ATTRIBUTE_ID_DUMMY',
                                       x.attribute_id || ', attr_value ATTR_TEXT, ' ||
                                      'pv_check_match_pub.currency_conversion(' ||
                                      'attr_value, ''' || g_common_currency || ''', ''Y'') ATTR_VALUE');

               END IF;


               l_ddl_sql := REPLACE(l_ddl_sql,
                                   'ATTR_TEXT_DUMMY',
                                   'ATTR_TEXT, ATTR_VALUE');

            -- ----------------------------------------------------------------
            -- Non-Currency Attributes
            -- ----------------------------------------------------------------
            ELSE
               IF (x.performance_flag = 'Y') THEN
                  l_ddl_sql := REPLACE(l_insert_sql, 'partner_id', 'entity_id partner_id');

               ELSE
                  l_ddl_sql := l_insert_sql;
               END IF;

               l_ddl_sql := REPLACE(l_ddl_sql, 'ATTRIBUTE_ID_DUMMY',
                                    x.attribute_id || ', attr_value');

               l_ddl_sql := REPLACE(l_ddl_sql, 'ATTR_TEXT_DUMMY', 'ATTR_VALUE');
            END IF;


            l_batch_sql_text := x.batch_sql_text;


            IF (p_refresh_type = g_incr_refresh) THEN
               -- ----------------------------------------------------------------
               -- In an incremental refresh (new partners only refresh), make
               -- sure the records are not already in the search table before
               -- inserting the records.
               -- ----------------------------------------------------------------
               DELETE FROM pv_search_attr_values
               WHERE  attribute_id = x.attribute_id AND
                      party_id IN (SELECT partner_id FROM pv_partner_id_session);

               -- -------------------------------------------------------------
               -- Include the new partners only clause in the batch_sql_text.
               -- -------------------------------------------------------------
               Transform_Batch_Sql(l_batch_sql_text, l_new_partner_clause);
            END IF;


            l_ddl_sql := l_ddl_sql || l_batch_sql_text || ')';

            -- ----------------------------------------------------------------
            -- Execute the insert.
            -- ----------------------------------------------------------------
            BEGIN
               Debug('Processing Attribute "' || x.name || '" (Attribute ID = ' ||
                  x.attribute_id || ')');

               IF (x.return_type = 'CURRENCY' AND x.performance_flag = 'Y') THEN
                  EXECUTE IMMEDIATE l_ddl_sql
                     USING p_user_id, p_user_id, p_user_id,
		           g_common_currency, pv_check_match_pub.g_period_set_name,
                           x.attribute_id, 'PARTNER';

               ELSE
                  EXECUTE IMMEDIATE l_ddl_sql USING p_user_id, p_user_id, p_user_id,
		                                    x.attribute_id, 'PARTNER';
               END IF;


               Debug(SQL%ROWCOUNT || ' rows processed.');

               IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
                  Update_Timestamp (
                     p_attribute_id  => x.attribute_id,
                     p_timestamp     => SYSDATE
                  );

                  COMMIT;
               END IF;

               Debug('Elapsed Time: ' ||
                  (DBMS_UTILITY.get_time - l_start2) || ' hsec');


               EXCEPTION
                  WHEN FND_API.G_EXC_ERROR THEN
                     Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                     -- -------------------------------------------------------------------
                     -- Retrieve the last message from the message queue which
                     -- contains the exception raised by the called program
                     -- e.g. currency_conversion
                     -- -------------------------------------------------------------------
                     -- Reset the pointer to the last message of the queue
                     fnd_msg_pub.reset(fnd_msg_pub.G_LAST);

                     -- -------------------------------------------------------------------
                     -- Go back to the second to last message which contains the message
                     -- raised by the called program (e.g. currency_conversion)
                     -- -------------------------------------------------------------------
                     l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                                       p_encoded   => FND_API.g_false);
                     l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                                       p_encoded   => FND_API.g_false);
                     Debug(l_last_message);

                     Debug('----------------------------------------------------');
                     Debug('Attribute ID: ' || x.attribute_id);
                     Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');

                     g_RETCODE := '1';


                     -- -------------------------------------------------------------------
                     -- If there is an exception with curreny_conversion, we need to "roll"
                     -- back changes. In our case, this means copy from the search table
                     -- and insert into the mirror table.
                     -- -------------------------------------------------------------------
                     IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
                        INSERT /*+ APPEND */ INTO pv_search_attr_mirror
                         (SEARCH_ATTR_VALUES_ID,
                          PARTY_ID,
                          SHORT_NAME,
                          ATTR_TEXT,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN,
                          OBJECT_VERSION_NUMBER,
                          LAST_UPDATED_BY,
                          SECURITY_GROUP_ID,
                          ATTRIBUTE_ID,
                          ATTR_VALUE
                         )
                        SELECT SEARCH_ATTR_VALUES_ID,
                          PARTY_ID,
                          SHORT_NAME,
                          ATTR_TEXT,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN,
                          OBJECT_VERSION_NUMBER,
                          LAST_UPDATED_BY,
                          SECURITY_GROUP_ID,
                          ATTRIBUTE_ID,
                          ATTR_VALUE
                        FROM   pv_search_attr_values
                        WHERE  attribute_id = x.attribute_id;

                        COMMIT;
                     END IF;

                  WHEN others THEN
                     Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                     Debug('Error executing insert statement for "' || x.name || '"');
                     Debug('Attribute ID: ' || x.attribute_id);
                     Debug(SQLCODE || '==>' || SQLERRM);
                     Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                     g_RETCODE := '1';

                     -- -------------------------------------------------------------------
                     -- If there is an exception with curreny_conversion, we need to "roll"
                     -- back changes. In our case, this means copy from the search table
                     -- and insert into the mirror table.
                     -- -------------------------------------------------------------------
                     IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
                        INSERT /*+ APPEND */ INTO pv_search_attr_mirror
                         (SEARCH_ATTR_VALUES_ID,
                          PARTY_ID,
                          SHORT_NAME,
                          ATTR_TEXT,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN,
                          OBJECT_VERSION_NUMBER,
                          LAST_UPDATED_BY,
                          SECURITY_GROUP_ID,
                          ATTRIBUTE_ID,
                          ATTR_VALUE
                         )
                        SELECT SEARCH_ATTR_VALUES_ID,
                          PARTY_ID,
                          SHORT_NAME,
                          ATTR_TEXT,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN,
                          OBJECT_VERSION_NUMBER,
                          LAST_UPDATED_BY,
                          SECURITY_GROUP_ID,
                          ATTRIBUTE_ID,
                          ATTR_VALUE
                        FROM   pv_search_attr_values
                        WHERE  attribute_id = x.attribute_id;

                        COMMIT;
                     END IF;
            END;
         END IF;
       END IF;
       END IF;
      END LOOP;


      Debug('Elapsed Time (NUMBER/CURRENCY): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

      -- --------------------------------------------------------------------------
      -- Process return_types other than NUMBER and CURRENCY.
      -- --------------------------------------------------------------------------
      l_start := dbms_utility.get_time;
      Debug('___________________________________________________________');
      Debug('-- **********************************************************');
      Debug('-- Processing External OTHER attributes...');
      Debug('-- **********************************************************');

      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'External - OTHER'
      );


      FOR x IN c_other_attributes LOOP
       l_do_not_process := FALSE;
       -- -----------------------------------------------------------------
       -- Determine the attribute should be refreshed based on refresh
       -- frequency.
       -- -----------------------------------------------------------------
       IF (p_refresh_type <> g_incr_refresh) THEN
          FOR y IN (SELECT COUNT(*) cnt
                    FROM   pv_entity_attrs
                    WHERE  attribute_id = x.attribute_id AND
                           entity       = 'PARTNER' AND
                          (last_refresh_date IS NULL OR
                           refresh_frequency IS NULL OR
                           refresh_frequency_uom IS NULL OR
                          (last_refresh_date +
                           DECODE(refresh_frequency_uom,
                                 'HOUR',  refresh_frequency/24,
                                 'DAY',   refresh_frequency,
                                 'WEEK',  refresh_frequency * 7,
                                 'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                             refresh_frequency)
                                          - NVL(last_refresh_date, SYSDATE)
                          )
                       ) <= SYSDATE))
          LOOP
             IF (y.cnt = 0) THEN
                l_do_not_process := TRUE;
             END IF;
          END LOOP;
       END IF;

       IF (NOT l_do_not_process) THEN
       IF (p_refresh_type = g_incr_refresh AND x.performance_flag = 'Y') THEN
         -- ---------------------------------------------------------------
         -- Cannot use batch_sql_text to perform refresh for performance
         -- attrubutes in an incremental refresh.
         -- ---------------------------------------------------------------
         null;

       ELSE

         l_start2 := dbms_utility.get_time;

         IF (x.batch_sql_text IS NULL) THEN
            Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name     => 'PV_ABSENT_BATCH_SQL_TEXT',
                        p_token1       => 'Attribute Name',
                        p_token1_value => x.name,
                        p_token2       => 'Attribute ID',
                        p_token2_value => x.attribute_id);

         ELSE
            -- ----------------------------------------------------------------
            -- Replace ATTRIBUTE_ID_DUMMY with the real attribute_id. Also
            -- append the batch_sql_text to the insert statement.
            -- ----------------------------------------------------------------
            l_ddl_sql := REPLACE(l_insert_sql, 'ATTRIBUTE_ID_DUMMY',
                                 x.attribute_id || ', ATTR_VALUE');

            l_ddl_sql := REPLACE(l_ddl_sql, 'ATTR_TEXT_DUMMY', 'ATTR_TEXT');

            l_batch_sql_text := x.batch_sql_text;

            IF (p_refresh_type = g_incr_refresh) THEN
               -- ----------------------------------------------------------------
               -- In an incremental refresh (new partners only refresh), make
               -- sure the records are not already in the search table before
               -- inserting the records.
               -- ----------------------------------------------------------------
               DELETE FROM pv_search_attr_values
               WHERE  attribute_id = x.attribute_id AND
                      party_id IN (SELECT partner_id FROM pv_partner_id_session);

               -- -------------------------------------------------------------
               -- Include the new partners only clause in the batch_sql_text.
               -- -------------------------------------------------------------
               Transform_Batch_Sql(l_batch_sql_text, l_new_partner_clause);
            END IF;


            l_ddl_sql := l_ddl_sql || l_batch_sql_text || ')';

            -- ----------------------------------------------------------------
            -- Execute the insert.
            -- ----------------------------------------------------------------
            BEGIN
               Debug('Processing Attribute "' || x.name || '" (Attribute ID = ' ||
                  x.attribute_id || ')');

               EXECUTE IMMEDIATE l_ddl_sql USING p_user_id, p_user_id, p_user_id,
	                                         x.attribute_id, 'PARTNER';

               Debug(SQL%ROWCOUNT || ' rows processed.');

               IF (p_refresh_type IN (g_full_refresh, g_incr_full_refresh)) THEN
                  Update_Timestamp (
                     p_attribute_id  => x.attribute_id,
                     p_timestamp     => SYSDATE
                  );

                  COMMIT;
               END IF;

               Debug('Elapsed Time: ' ||
                  (DBMS_UTILITY.get_time - l_start2) || ' hsec');

               EXCEPTION
                  WHEN others THEN
                     Debug('Error executing insert statement for "' || x.name || '"');
                     Debug('Attribute ID: ' || x.attribute_id);
                     Debug(SQLCODE || '==>' || SQLERRM);
                     g_RETCODE := '1';
            END;
         END IF;
       END IF;
       END IF;
      END LOOP;


      Debug('Elapsed Time (Other): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

END Insert_External;
-- ======================End of Insert_External==================================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Insert_Function_Perf_Attrs                                              |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Insert_Function_Perf_Attrs(
   p_refresh_type IN VARCHAR2,
   p_partner_id   IN NUMBER
)
IS
   -- -----------------------------------------------------------------------
   -- Template cursor defined here so we can use %ROWTYPE for x.
   -- -----------------------------------------------------------------------
   CURSOR lc_template IS
      SELECT b.attribute_id, b.performance_flag, b.attribute_type,
             a.sql_text, b.name, b.return_type
      FROM   pv_entity_attrs  a,
             pv_attributes_vl b
      WHERE  a.attribute_id = b.attribute_id;

   x lc_template%ROWTYPE;

   TYPE t_ref_cursor IS REF CURSOR;
   c_func_perf_attrs  t_ref_cursor;

   i NUMBER;
   l_start            NUMBER;

BEGIN
   -- ------------------------------------------------------------------------
   -- The cursor for getting function and performance attributes will only
   -- be open once. At that time, they are fetched to a table of record.
   -- If there are any problem with the sql_text, the exception is caught in
   -- the exception block and the table of record will not have that
   -- particular attribute ID. This ensures that the error message associated
   -- with a particular sql_text will only be displayed once.
   --
   -- Note this cursor is used for function attributes (full and incremental
   -- refresh) and performance attributes (incremental refresh only).
   -- ------------------------------------------------------------------------
   IF (g_func_perf_attrs_tbl.COUNT = 0) THEN
     -- ----------------------------------------------------------------------
     -- Incremental refresh does not consider refresh frequency.
     -- ----------------------------------------------------------------------
     IF (p_refresh_type = g_incr_refresh) THEN
      OPEN c_func_perf_attrs FOR
            SELECT b.attribute_id, b.performance_flag, b.attribute_type,
                   a.sql_text, b.name, b.return_type
            FROM   pv_entity_attrs  a,
                   pv_attributes_vl b
            WHERE  a.attribute_id = b.attribute_id AND
                   a.entity = 'PARTNER' AND
                   a.enabled_flag = 'Y' AND
                   b.enabled_flag = 'Y' AND
                  (b.enable_matching_flag = 'Y' OR
                   a.display_external_value_flag = 'Y') AND
                 ((b.performance_flag = 'Y'  AND
                   p_refresh_type = g_incr_refresh) OR
                   b.attribute_type   = 'FUNCTION')
            ORDER  BY b.attribute_id;

     -- ----------------------------------------------------------------------
     -- Full refresh needs to account for refresh frequency.
     -- ----------------------------------------------------------------------
     ELSE
      OPEN c_func_perf_attrs FOR
            SELECT b.attribute_id, b.performance_flag, b.attribute_type,
                   a.sql_text, b.name, b.return_type
            FROM   pv_entity_attrs  a,
                   pv_attributes_vl b
            WHERE  a.attribute_id = b.attribute_id AND
                   a.entity = 'PARTNER' AND
                   a.enabled_flag = 'Y' AND
                   b.enabled_flag = 'Y' AND
                  (b.enable_matching_flag = 'Y' OR
                   a.display_external_value_flag = 'Y') AND
                 ((b.performance_flag = 'Y'  AND
                   p_refresh_type = g_incr_refresh) OR
                   b.attribute_type   = 'FUNCTION') AND
                  (a.last_refresh_date IS NULL OR
                   a.refresh_frequency IS NULL OR
                   a.refresh_frequency_uom IS NULL OR
                  (last_refresh_date +
                      DECODE(refresh_frequency_uom,
                         'HOUR',  refresh_frequency/24,
                         'DAY',   refresh_frequency,
                         'WEEK',  refresh_frequency * 7,
                         'MONTH', ADD_MONTHS(TRUNC(NVL(last_refresh_date, SYSDATE), 'MM'),
                                     refresh_frequency)
                                  - NVL(last_refresh_date, SYSDATE)
                      )
                   ) <= SYSDATE)
            ORDER  BY b.attribute_id;
      END IF;

      LOOP
         FETCH c_func_perf_attrs INTO x;
         EXIT WHEN c_func_perf_attrs%NOTFOUND;

        BEGIN
         IF (x.sql_text IS NULL OR LENGTH(x.sql_text) = 0) THEN
            Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
            Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name     => 'PV_ABSENT_SQL_TEXT',
                        p_token1       => 'Attribute Name',
                        p_token1_value => x.name,
                        p_token2       => 'Attribute ID',
                        p_token2_value => x.attribute_id);
            Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');

            g_RETCODE := '1';

         ELSE
            -- -----------------------------------------------------------------
            -- Calling UPSERT.
            -- -----------------------------------------------------------------
            g_func_perf_attrs_tbl(x.attribute_id).performance_flag := x.performance_flag;
            g_func_perf_attrs_tbl(x.attribute_id).attribute_type   := x.attribute_type;
            g_func_perf_attrs_tbl(x.attribute_id).return_type      := x.return_type;
            g_func_perf_attrs_tbl(x.attribute_id).sql_text         := x.sql_text;

            Debug('Processing attribute (' || x.name || ') (Attribute ID=' ||
                  x.attribute_id || ')');
            UPSERT_func_perf_attrs(p_refresh_type, p_partner_id, x.attribute_id);

         END IF;

         EXCEPTION
            WHEN g_e_invalid_sql THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute Name: ' || x.name);
               Debug('Attribute ID  : ' || x.attribute_id);
               Debug('The SQL Text for this attribute is invalid.');
               Debug('sql_text = ' || x.sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(x.attribute_id);

            WHEN g_e_undeclared_identifier THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute Name: ' || x.name);
               Debug('Attribute ID  : ' || x.attribute_id);
               Debug('sql_text = ' || x.sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(x.attribute_id);

            WHEN g_e_invliad_column_name THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute Name: ' || x.name);
               Debug('Attribute ID  : ' || x.attribute_id);
               Debug('The SQL has an invalid column name.');
               Debug('sql_text = ' || x.sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(x.attribute_id);

            WHEN g_e_divisor_is_zero THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute Name: ' || x.name);
               Debug('Attribute ID  : ' || x.attribute_id);
               Debug('sql_text = ' || x.sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(x.attribute_id);

            WHEN others THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute Name: ' || x.name);
               Debug('Attribute ID  : ' || x.attribute_id);
               Debug('There is an error with this SQL text.');
               Debug('sql_text = ' || x.sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(x.attribute_id);
        END;
      END LOOP;

   -- ------------------------------------------------------------------------
   -- g_func_perf_attrs PLSQ table already been populated.
   -- ------------------------------------------------------------------------
   ELSE
      i := g_func_perf_attrs_tbl.FIRST;

      WHILE (i <= g_func_perf_attrs_tbl.LAST) LOOP
       BEGIN
         -- -----------------------------------------------------------------
         -- Calling UPSERT.
         -- -----------------------------------------------------------------
         UPSERT_func_perf_attrs(p_refresh_type, p_partner_id, i);

         i := g_func_perf_attrs_tbl.NEXT(i);

         EXCEPTION
            WHEN g_e_divisor_is_zero THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute ID  : ' || i);
               Debug('sql_text = ' || g_func_perf_attrs_tbl(i).sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(i);

               -- --------------------------------------------------------------
               -- It's extremely important to advance the counter (i) here.
               -- Without doing this, this becomes an infinite loop!
               -- --------------------------------------------------------------
               i := g_func_perf_attrs_tbl.NEXT(i);

            WHEN others THEN
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               Debug(SQLCODE);
               Debug(SQLERRM);
               Debug('Attribute ID  : ' || i);
               Debug('There is an error with this SQL text.');
               Debug('sql_text = ' || g_func_perf_attrs_tbl(i).sql_text);
               Debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
               g_RETCODE := '1';

               -- --------------------------------------------------------------
               -- Don't process this attribute again.
               -- --------------------------------------------------------------
               g_func_perf_attrs_tbl.DELETE(i);

               i := g_func_perf_attrs_tbl.NEXT(i);

       END;
      END LOOP;
   END IF;

END Insert_Function_Perf_Attrs;
-- =======================End of Insert_Function_Perf_Attrs====================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Upsert_Func_Perf_Attrs                                                  |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Upsert_Func_Perf_Attrs (
   p_refresh_type  VARCHAR2,
   p_partner_id    NUMBER,
   p_attribute_id  NUMBER
)
IS
   TYPE t_ref_cursor IS REF CURSOR;
   c_perf_attributes  t_ref_cursor;

   l_output_tbl         JTF_VARCHAR2_TABLE_4000;
   l_tmp_tbl            JTF_VARCHAR2_TABLE_4000;
   l_user_id            NUMBER := FND_GLOBAL.USER_ID();
   l_output             VARCHAR2(2000);
   l_attr_text          VARCHAR2(2000);
   l_attr_value         NUMBER;
   l_last_message       VARCHAR2(30000);

BEGIN
   -- ------------------------------------------------------------------------
   -- Function Attributes
   -- ------------------------------------------------------------------------
   IF (g_func_perf_attrs_tbl(p_attribute_id).attribute_type = 'FUNCTION') THEN

      -- ---------------------------------------------------------------------
      -- Execute sql_text to retrieve attribute values.
      -- ---------------------------------------------------------------------
      EXECUTE IMMEDIATE 'BEGIN ' ||
                        g_func_perf_attrs_tbl(p_attribute_id).sql_text ||
                        '; END;'
      USING p_partner_id, OUT l_output_tbl;

      -- ---------------------------------------------------------------------
      -- De-dupe l_output_tbl by "selecting" its distinct values into another
      -- PLSQL table.
      -- ---------------------------------------------------------------------
      SELECT CAST(MULTISET(
                SELECT DISTINCT column_value
                FROM   TABLE (CAST(l_output_tbl AS JTF_VARCHAR2_TABLE_4000)))
             AS JTF_VARCHAR2_TABLE_4000)
      INTO   l_tmp_tbl
      FROM   dual;

      l_output_tbl := l_tmp_tbl;


      -- ---------------------------------------------------------------------
      -- Insert records retrieved from executing the function in the sql_text.
      -- ---------------------------------------------------------------------
      FOR i IN 1..l_output_tbl.COUNT LOOP
       BEGIN
         -- ------------------------------------------------------------------
         -- Make sure that if the currency string is NULL (note:
         -- ':::USD:::20031113094020' is considered as NULL since there is no
         -- amount), set both l_attr_text and l_attr_value to NULL so that the
         -- value won't be inserted into the search table.
         -- ------------------------------------------------------------------
         IF (g_func_perf_attrs_tbl(p_attribute_id).return_type = 'CURRENCY') THEN
            IF (l_output_tbl(i) IS NULL OR
               (SUBSTR(l_output_tbl(i), 1, INSTR(l_output_tbl(i), ':::') - 1)) IS NULL)
            THEN
               l_attr_text  := NULL;
               l_attr_value := NULL;

            ELSE
               l_attr_text  := l_output_tbl(i);
               l_attr_value := pv_check_match_pub.currency_conversion
                               (l_output_tbl(i), g_common_currency);
            END IF;

         ELSIF (g_func_perf_attrs_tbl(p_attribute_id).return_type = 'NUMBER') THEN
            l_attr_text  := NULL;
            l_attr_value := TO_NUMBER(l_output_tbl(i));

         ELSE
            l_attr_text  := l_output_tbl(i);
            l_attr_value := NULL;
         END IF;

         -- ------------------------------------------------------------------
         -- Incremental Refresh
         -- ------------------------------------------------------------------
         IF (p_refresh_type = g_incr_refresh) THEN
            -- ----------------------------------------------------------------
            -- In an incremental refresh (new partners only refresh), make
            -- sure the records are not already in the search table before
            -- inserting the records.
            -- ----------------------------------------------------------------
            DELETE FROM pv_search_attr_values
            WHERE  attribute_id = p_attribute_id AND
                   party_id = p_partner_id;


          IF (l_attr_text IS NOT NULL OR l_attr_value IS NOT NULL) THEN
            INSERT INTO pv_search_attr_values (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               ATTR_VALUE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
            VALUES (
                pv_search_attr_values_s.nextval,
                p_partner_id,
                p_attribute_id,
                l_attr_text,
                l_attr_value,
                SYSDATE,
                l_user_id,
                SYSDATE,
                l_user_id,
                l_user_id,
                1.0
            );

            g_non_batch_insert_count := g_non_batch_insert_count + 1;
          END IF;

         -- ------------------------------------------------------------------
         -- Full Refresh
         -- ------------------------------------------------------------------
         ELSE
          IF (l_attr_text IS NOT NULL OR l_attr_value IS NOT NULL) THEN
            INSERT INTO pv_search_attr_mirror (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               ATTR_VALUE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
            VALUES (
                pv_search_attr_values_s.nextval,
                p_partner_id,
                p_attribute_id,
                l_attr_text,
                l_attr_value,
                SYSDATE,
                l_user_id,
                SYSDATE,
                l_user_id,
                l_user_id,
                1.0
            );

            g_non_batch_insert_count := g_non_batch_insert_count + 1;
          END IF;
         END If;

       EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            -- -------------------------------------------------------------------
            -- Retrieve the last message from the message queue which
            -- contains the exception raised by the called program
            -- e.g. currency_conversion
            -- -------------------------------------------------------------------
            -- Reset the pointer to the last message of the queue
            fnd_msg_pub.reset(fnd_msg_pub.G_LAST);

            -- -------------------------------------------------------------------
            -- Go back to the second to last message which contains the message
            -- raised by the called program (e.g. currency_conversion)
            -- -------------------------------------------------------------------
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            Debug(l_last_message);

            Debug('Attribute ID: ' || p_attribute_id);
            Debug('Partner   ID: ' || p_partner_id);
            Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

            g_RETCODE := '1';

       END;
      END LOOP;

   -- ------------------------------------------------------------------------
   -- Performance Attributes
   -- ------------------------------------------------------------------------
   ELSE
      OPEN c_perf_attributes FOR g_func_perf_attrs_tbl(p_attribute_id).sql_text
      USING p_attribute_id, 'PARTNER', p_partner_id;


      LOOP
         FETCH c_perf_attributes INTO l_output;
         EXIT WHEN c_perf_attributes%NOTFOUND;

       BEGIN

         IF (g_func_perf_attrs_tbl(p_attribute_id).return_type = 'CURRENCY') THEN
            IF (l_output IS NULL OR
               (SUBSTR(l_output, 1, INSTR(l_output, ':::') - 1)) IS NULL)
            THEN
               l_attr_text  := NULL;
               l_attr_value := NULL;

            ELSE
               l_attr_text  := l_output;
               l_attr_value := pv_check_match_pub.currency_conversion
                               (l_output, g_common_currency);
            END IF;

         ELSIF (g_func_perf_attrs_tbl(p_attribute_id).return_type = 'NUMBER') THEN
            l_attr_text  := NULL;
            l_attr_value := TO_NUMBER(l_output);

         ELSE
            l_attr_text  := l_output;
            l_attr_value := NULL;
         END IF;

         -- ------------------------------------------------------------------
         -- Incremental Refresh
         -- ------------------------------------------------------------------
         IF (p_refresh_type = g_incr_refresh) THEN
            -- ----------------------------------------------------------------
            -- In an incremental refresh (new partners only refresh), make
            -- sure the records are not already in the search table before
            -- inserting the records.
            -- ----------------------------------------------------------------
            DELETE FROM pv_search_attr_values
            WHERE  attribute_id = p_attribute_id AND
                   party_id = p_partner_id;

          IF (l_attr_text IS NOT NULL OR l_attr_value IS NOT NULL) THEN
            INSERT INTO pv_search_attr_values (
               SEARCH_ATTR_VALUES_ID,
               PARTY_ID,
               ATTRIBUTE_ID,
               ATTR_TEXT,
               ATTR_VALUE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN ,
               OBJECT_Version_number)
            VALUES (
                pv_search_attr_values_s.nextval,
                p_partner_id,
                p_attribute_id,
                l_attr_text,
                l_attr_value,
                SYSDATE,
                l_user_id,
                SYSDATE,
                l_user_id,
                l_user_id,
                1.0
            );

            g_non_batch_insert_count := g_non_batch_insert_count + 1;
          END IF;

         -- ------------------------------------------------------------------
         -- Full Refresh
         -- ------------------------------------------------------------------
         ELSE
            Debug('Wrong Entry: the codes should never have enter this area.');
            Debug('Full Refresh of performance attributes does not use sql_text.');
         END If;

       EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            -- -------------------------------------------------------------------
            -- Retrieve the last message from the message queue which
            -- contains the exception raised by the called program
            -- e.g. currency_conversion
            -- -------------------------------------------------------------------
            -- Reset the pointer to the last message of the queue
            fnd_msg_pub.reset(fnd_msg_pub.G_LAST);

            -- -------------------------------------------------------------------
            -- Go back to the second to last message which contains the message
            -- raised by the called program (e.g. currency_conversion)
            -- -------------------------------------------------------------------
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            l_last_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_PREVIOUS,
                                              p_encoded   => FND_API.g_false);
            Debug(l_last_message);

            Debug('Attribute ID: ' || p_attribute_id);
            Debug('Partner   ID: ' || p_partner_id);
            Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

            g_RETCODE := '1';

       END;
      END LOOP;

      CLOSE c_perf_attributes;
   END IF;

END Upsert_Func_Perf_Attrs;
-- =======================End of Upsert_Func_Perf_Attrs========================





--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Transform_Batch_Sql                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:  This procedure is only used in the case of a INCR refresh.         |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Transform_Batch_Sql (
   p_batch_sql_text     IN OUT NOCOPY VARCHAR2,
   p_new_partner_clause IN     VARCHAR2
)
IS
   l_group_str VARCHAR2(20) := 'GROUP ';
   l_by_str    VARCHAR2(10) := 'BY';
   l_group_by  VARCHAR2(25);

BEGIN
   FOR i IN 1..10 LOOP
      l_group_by := l_group_str || l_by_str;

      IF (INSTR(UPPER(p_batch_sql_text), l_group_by) > 0) THEN
         p_batch_sql_text :=
            REPLACE(UPPER(p_batch_sql_text), l_group_by,
               p_new_partner_clause || ' ' || l_group_by);

         RETURN;
      END IF;

      l_group_str := l_group_str || ' ';
   END LOOP;

   p_batch_sql_text := p_batch_sql_text || ' ' || p_new_partner_clause;

END Transform_Batch_Sql;
-- ======================End of Transform_Batch_Sql=============================




--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Update_Timestamp                                                        |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:  This procedure is only used in the case of a FULL refresh.         |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Update_Timestamp (
   p_attribute_id  NUMBER,
   p_timestamp     DATE := SYSDATE
)
IS

BEGIN
   UPDATE pv_entity_attrs
   SET    last_refresh_date = p_timestamp
   WHERE  entity = 'PARTNER' AND
          attribute_id = p_attribute_id;

END Update_Timestamp;
-- ======================End of Update_Timestamp================================




--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Disable_Drop_Indexes                                                    |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Disable_Drop_Indexes(
   p_mirror_table    IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
)
IS
   CURSOR c_indexes (pc_mirror_table    IN VARCHAR2,
                     pc_pv_schema_owner IN VARCHAR2,
                     pc_index_type      IN VARCHAR2)
   IS
      SELECT a.index_name
      FROM   dba_indexes a
      WHERE  a.table_name  = pc_mirror_table AND
             a.table_owner = pc_pv_schema_owner AND
             a.uniqueness  = pc_index_type AND
	     a.owner       = pc_pv_schema_owner
      ORDER  BY a.index_name;

   CURSOR c_pk_unique_constraints (pc_mirror_table    IN VARCHAR2,
                                   pc_pv_schema_owner IN VARCHAR2)
   IS
      SELECT constraint_name
      FROM   dba_constraints
      WHERE  table_name = pc_mirror_table AND
             owner      = pc_pv_schema_owner AND
             constraint_type IN ('P', 'U');

BEGIN
   -- ---------------------------------------------------------------------------
   -- Make all non-unique indexes on the mirror table unusable.
   -- ---------------------------------------------------------------------------
   FOR x IN c_indexes(p_mirror_table, p_pv_schema_owner, 'NONUNIQUE') LOOP
      EXECUTE IMMEDIATE
        'ALTER INDEX ' || p_pv_schema_owner || '.' || x.index_name || ' UNUSABLE';
   END LOOP;

   -- ---------------------------------------------------------------------------
   -- Set SKIP_UNUSABLE_INDEXES session variable.
   -- ---------------------------------------------------------------------------
   EXECUTE IMMEDIATE
      'ALTER SESSION SET SKIP_UNUSABLE_INDEXES = TRUE';

   -- ---------------------------------------------------------------------------
   -- On the mirror table:
   -- Disable all primary and unique constraints, which, in effect, drop the
   -- associated unique indexes.
   -- ---------------------------------------------------------------------------
   FOR x IN c_pk_unique_constraints(p_mirror_table, p_pv_schema_owner) LOOP
      EXECUTE IMMEDIATE
        'ALTER TABLE ' || p_pv_schema_owner || '.' || p_mirror_table ||
        ' MODIFY CONSTRAINT ' || x.constraint_name || ' DISABLE';
   END LOOP;

   -- ---------------------------------------------------------------------------
   -- On the mirror table:
   -- Drop all the remaining unique indexes.
   -- ---------------------------------------------------------------------------
   FOR x IN c_indexes(p_mirror_table, p_pv_schema_owner, 'UNIQUE') LOOP
      EXECUTE IMMEDIATE
        'DROP INDEX ' || p_pv_schema_owner || '.' || x.index_name;
   END LOOP;

END Disable_Drop_Indexes;
-- ======================End of Disable_Drop_Indexes============================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Enable_Create_Indexes                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Enable_Create_Indexes(
   p_search_table    IN VARCHAR2,
   p_mirror_table    IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
) IS
   -- ---------------------------------------------------------------------------
   -- Retrieve indexes for a table.
   -- ---------------------------------------------------------------------------
   CURSOR c_indexes (pc_table_name      IN VARCHAR2,
                     pc_pv_schema_owner IN VARCHAR2)
   IS
      SELECT a.index_name, a.owner, a.tablespace_name, a.pct_free,
             a.uniqueness
      FROM   dba_indexes a
      WHERE  a.table_name  = pc_table_name AND
             a.table_owner = pc_pv_schema_owner AND
             a.uniqueness  = 'NONUNIQUE' AND
	     a.owner       = pc_pv_schema_owner
      ORDER  BY a.index_name;

   -- ---------------------------------------------------------------------------
   -- Retrieve primary/unique constraints for a table.
   -- ---------------------------------------------------------------------------
   CURSOR c_pk_unique_constraints (pc_mirror_table    IN VARCHAR2,
                                   pc_pv_schema_owner IN VARCHAR2)
   IS
      SELECT constraint_name
      FROM   dba_constraints
      WHERE  table_name = pc_mirror_table AND
             owner      = pc_pv_schema_owner AND
             constraint_type IN ('P', 'U');


   -- ---------------------------------------------------------------------------
   -- Local Variables.
   -- ---------------------------------------------------------------------------
   l_index_ddl_stmt  VARCHAR2(4000);

BEGIN
   -- ------------------------------------------------------------
   -- Rebuild nonunique indexes.
   -- ------------------------------------------------------------
   FOR x IN c_indexes(p_mirror_table, p_pv_schema_owner) LOOP
      l_index_ddl_stmt := 'ALTER INDEX ' || x.owner || '.' ||
                           x.index_name || ' REBUILD NOLOGGING';

      EXECUTE IMMEDIATE l_index_ddl_stmt;
   END LOOP;

   -- ------------------------------------------------------------
   -- Set SKIP_UNUSABLE_INDEXES back to FALSE.
   -- ------------------------------------------------------------
   EXECUTE IMMEDIATE
     'ALTER SESSION SET SKIP_UNUSABLE_INDEXES = FALSE';

   -- ------------------------------------------------------------------
   -- Recreate indexes. |
   -- ------------------
   -- Note that we only need to create unique indexes for they get
   -- dropped in the beginning of this program. However, there may be
   -- indexes added to the search table since the last refresh. These
   -- new indexes must also be present in the mirror table. To resolve
   -- this problem, we will recreate all the indexes on the search table
   -- on the mirror table. We will use the exception handler,
   -- g_index_columns_existed (ORA-01408) and g_name_already_used
   -- (ORA-00955) to take care of the indexes that already exist.
   --
   -- Since the search and mirror table exchange roles constantly, we
   -- need to do this process both ways by reversing the procedure
   -- described above.
   -- ------------------------------------------------------------------
   Create_Indexes(p_search_table, p_mirror_table, p_pv_schema_owner);
   Create_Indexes(p_mirror_table, p_search_table, p_pv_schema_owner);


   -- ------------------------------------------------------------
   -- Enable primary/unique constraints on the mirror table.
   -- ------------------------------------------------------------
   FOR x IN c_pk_unique_constraints(p_mirror_table, p_pv_schema_owner) LOOP
      l_index_ddl_stmt := 'ALTER TABLE ' || p_pv_schema_owner || '.' ||
                          p_mirror_table || ' MODIFY CONSTRAINT ' ||
                          x.constraint_name || ' ENABLE';

      EXECUTE IMMEDIATE l_index_ddl_stmt;
   END LOOP;
END Enable_Create_Indexes;
-- ======================End of Enable_Create_Indexes============================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Create_Indexes                                                          |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Create_Indexes(
   p_table1          IN VARCHAR2,
   p_table2          IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
)
IS
   -- ---------------------------------------------------------------------------
   -- Retrieve indexes for a table.
   -- ---------------------------------------------------------------------------
   CURSOR c_indexes (pc_table_name      IN VARCHAR2,
                     pc_pv_schema_owner IN VARCHAR2)
   IS
      -- -------------------------------------------------------------------------
      -- The use of dbms_metadata requires invoker rights because roles are not
      -- enabled during the execution of a definer rights procedure.
      -- For this reason, we added "AUTHID CURRENT_USER" to the package
      -- (pvxvcons.pls). If this package is not made invoker rights enabled,
      -- Oracle will produce the following error when dbms_metadata.get_ddl
      -- is trying to extract DDL out of a non-APPS schema.
      --
      -- e.g.
      -- ORA-31603: object "PV_SEARCH_ATTR_VALUES_U1" of type INDEX not found
      -- in schema "PV"
      -- -------------------------------------------------------------------------
      SELECT index_name,
             dbms_metadata.get_ddl('INDEX', index_name, owner) ind_def
      FROM   dba_indexes
      WHERE  table_name  = pc_table_name AND
             table_owner = pc_pv_schema_owner AND
	     owner       = pc_pv_schema_owner
      ORDER  BY index_name;


   l_index_ddl_stmt  VARCHAR2(4000);

BEGIN
   FOR x IN c_indexes(p_table1, p_pv_schema_owner) LOOP
     BEGIN
        l_index_ddl_stmt := REPLACE(x.ind_def, '"' || p_table1 || '"',
                                    '"' || p_table2 || '"');

        IF (INSTR(l_index_ddl_stmt, '_M"') > 0) THEN
           l_index_ddl_stmt := REPLACE(l_index_ddl_stmt, x.index_name,
                                       SUBSTR(x.index_name, 1, LENGTH(x.index_name) - 2));

        ELSE
           l_index_ddl_stmt := REPLACE(l_index_ddl_stmt, x.index_name, x.index_name || '_M');
        END IF;

        EXECUTE IMMEDIATE l_index_ddl_stmt;

      EXCEPTION
         -- ----------------------------------------------------------------
         -- If the index already exists, go to the next index.
         -- ----------------------------------------------------------------
         WHEN g_index_columns_existed THEN
            null;

         WHEN g_name_already_used THEN
            null;

     END;
   END LOOP;


   EXCEPTION
      WHEN g_e_definer_rights THEN
         Debug('Definer Rights.......................................');
         Debug(SQLCODE || ':::' || SQLERRM);


END Create_Indexes;
-- ==========================End of Create_Indexes===============================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Recompile_Dependencies                                                  |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Recompile_Dependencies(
   p_referenced_type  IN VARCHAR2,
   p_referenced_name1 IN VARCHAR2,
   p_referenced_name2 IN VARCHAR2,
   p_api_package_name IN VARCHAR2
)
IS
   CURSOR c IS
      SELECT owner, name, type
             FROM   dba_dependencies
             WHERE  referenced_type = p_referenced_type AND
                    referenced_name IN (p_referenced_name1, p_referenced_name2) AND
		    owner = g_apps_schema;

   l_ddl_str VARCHAR2(300);
   l_start   NUMBER;
   l_start2  NUMBER;

BEGIN
   l_start := dbms_utility.get_time;

   -- -----------------------------------------------------------------------
   -- Determine "APPS" schema.
   -- -----------------------------------------------------------------------
   IF (g_apps_schema IS NULL) THEN
      FOR x IN (SELECT user FROM dual) LOOP
         g_apps_schema := x.user;
      END LOOP;
   END IF;


   FOR x IN C LOOP
      IF (x.name <> p_api_package_name AND
          x.owner = g_apps_schema AND
          x.type  = 'PACKAGE BODY')
      THEN
         FOR y IN (
            SELECT owner, object_name
            FROM   dba_objects
            WHERE  owner = x.owner AND
                   object_name = x.name AND
                   object_type = 'PACKAGE BODY' AND
                   status = 'INVALID')
         LOOP
	    l_start2 := dbms_utility.get_time;
            l_ddl_str := 'ALTER PACKAGE ' || y.owner || '.' || y.object_name ||
                         ' COMPILE BODY';
            Debug(l_ddl_str);

            BEGIN
               EXECUTE IMMEDIATE l_ddl_str;
	       Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start2) || ' hsec');

            EXCEPTION
               WHEN OTHERS THEN
	          Debug(SQLCODE || ':::' || SQLERRM);
		  Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start2) || ' hsec');
	    END;
         END LOOP;
      END IF;
   END LOOP;

   Debug('Elapsed Time (Recompile_Dependencies): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
END Recompile_Dependencies;
-- ==========================End of Recompile_Dependencies=======================


END PV_CONTEXT_VALUES;

/
