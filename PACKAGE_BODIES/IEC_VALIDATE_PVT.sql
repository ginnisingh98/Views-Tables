--------------------------------------------------------
--  DDL for Package Body IEC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_VALIDATE_PVT" AS
/* $Header: IECVALB.pls 120.7.12010000.5 2010/01/15 04:32:32 svidiyal ship $ */



g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_VALIDATE_PVT';



TYPE varchar_idx_tbl_type IS TABLE OF VARCHAR2(500)

   INDEX BY BINARY_INTEGER;

TYPE number_idx_tbl_type IS TABLE OF NUMBER(15)

   INDEX BY BINARY_INTEGER;



g_cc_cc_lookup_tbl    varchar_idx_tbl_type;

g_cc_tc_lookup_tbl    varchar_idx_tbl_type;

g_cc_ac_tc_lookup_tbl varchar_idx_tbl_type;

g_ac_length_tbl       varchar_idx_tbl_type;

g_pn_length_tbl       varchar_idx_tbl_type;

g_tz_lookup_tbl       varchar_idx_tbl_type;



-- Bulk Collect Batch Size

g_row_increment CONSTANT NUMBER(9) := 10000;



-- Logging variables

g_fnd_log_enabled BOOLEAN := TRUE;

g_status          VARCHAR2(32) := NULl;

g_method          VARCHAR2(4000) := NULL;

g_sub_method      VARCHAR2(4000) := NULL;

g_encoded_message VARCHAR2(4000) := NULL;

g_module          VARCHAR2(4000) := NULL;

g_message         VARCHAR2(4000) := NULL;

g_message_prefix  VARCHAR2(4000) := NULL;

g_start_time      DATE := NULL;

g_end_time        DATE := NULL;

g_ignore          VARCHAR2(4000);



-- Validation rule configuration variables, set in Init_Rules

g_enable_zc_lookups BOOLEAN;

g_enable_tz_map_ovrd BOOLEAN;

g_enable_cell_phone_val BOOLEAN;

g_phone_country_code VARCHAR2(60);

g_territory_code VARCHAR2(2);

g_enable_ac_incr_parse BOOLEAN;

g_enable_cc_incr_parse BOOLEAN;

g_timezone_id NUMBER(15);

g_region_id NUMBER(15);

g_require_regions BOOLEAN;

g_enable_pn_length_val BOOLEAN;

g_enable_ac_length_val BOOLEAN;



PROCEDURE Set_LoggingGlobals

   ( p_status         IN VARCHAR2

   , p_method         IN VARCHAR2

   , p_sub_method     IN VARCHAR2

   )

IS

BEGIN



   g_status := p_status; -- used to create validation history report, not general logging

   g_method := p_method;

   g_sub_method := p_sub_method;



   IEC_OCS_LOG_PVT.Get_EncodedMessage(g_message, g_encoded_message);



   IF g_message_prefix IS NOT NULL THEN

      g_module := 'iec.plsql.' || UPPER('IEC_VALIDATE_PVT') || '.' || UPPER(g_method) || '.' || LOWER(g_sub_method) || '.' || LOWER(g_message_prefix);

   ELSE

      g_module := 'iec.plsql.' || UPPER('IEC_VALIDATE_PVT') || '.' || UPPER(g_method) || '.' || LOWER(g_sub_method);

   END IF;



END Set_LoggingGlobals;



FUNCTION Get_TranslatedErrorMessage

RETURN VARCHAR2

IS

BEGIN

   RETURN g_module || ': ' || g_message;

END Get_TranslatedErrorMessage;



PROCEDURE Set_MessagePrefix

   ( p_action IN VARCHAR2 )

IS

BEGIN

   g_message_prefix := p_action;

END Set_MessagePrefix;



PROCEDURE Disable_FndLogging

IS

BEGIN

   g_fnd_log_enabled := FALSE;

END Disable_FndLogging;



PROCEDURE Enable_FndLogging

IS

BEGIN

   g_fnd_log_enabled := TRUE;

END Enable_FndLogging;



FUNCTION Is_FndLoggingEnabled

RETURN BOOLEAN

IS

BEGIN

   RETURN g_fnd_log_enabled;

END Is_FndLoggingEnabled;



-- Creates generic translatable error message using the

-- SQLERRM parameter.  You should not pass non-translatable

-- strings (other than SQLERRM) into this procedure b/c

-- all logs and validation history records must be translatable.

-- The translatable error message is logged if Immediate Logging

-- Enabled (Main validation procedure defers logging until

-- validation history record is created)

PROCEDURE Log ( p_method        IN VARCHAR2

              , p_sub_method    IN VARCHAR2

              , p_sqlerrm       IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_ValidationSqlErrmMsg

      ( p_sqlerrm

      , p_method || '.' || p_sub_method

      , g_message

      , g_encoded_message

      );



   Set_LoggingGlobals

      ( 'FAILED_VALIDATION'

      , p_method

      , p_sub_method

      );



   IF g_fnd_log_enabled THEN

      IEC_OCS_LOG_PVT.Log_Message(g_module);

   END IF;



END Log;


PROCEDURE Log_msg
(
  p_method_name   IN VARCHAR2,
  p_sql_errmsg    IN VARCHAR2
)
IS
  l_error_msg VARCHAR2(2048);
BEGIN

  IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
  (
    'IEC_VALIDATE_PVT',
     p_method_name,
     '',
     p_sql_errmsg,
     l_error_msg
  );

END Log_msg;

-- Logs a previously initialized translatable error message

-- in FND_MESSAGE.

-- The translatable error message is logged if Immediate Logging

-- Enabled (Main validation procedure defers logging until

-- validation history record is created)

PROCEDURE Log ( p_method        IN VARCHAR2

              , p_sub_method    IN VARCHAR2)

IS

BEGIN



   -- The message object should already be initialized

   -- prior to calling this Log procedure

   Set_LoggingGlobals

      ( 'FAILED_VALIDATION'

      , p_method

      , p_sub_method

      );



   IF g_fnd_log_enabled THEN

      IEC_OCS_LOG_PVT.Log_Message(g_module);

   END IF;



END Log;



PROCEDURE Log_SchemaNameNotFound

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_appl_short_name    IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_SqlErrmMsg

      ( p_appl_short_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_SchemaNameNotFound;



FUNCTION Get_AppsSchemaName

RETURN VARCHAR2

IS

   l_schema_name VARCHAR2(30);

BEGIN



   SELECT ORACLE_USERNAME

   INTO l_schema_name

   FROM FND_ORACLE_USERID

   WHERE READ_ONLY_FLAG = 'U';



   RETURN l_schema_name;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Get_AppsSchemaName'

         , 'MAIN'

         , SQLERRM);

      RAISE fnd_api.g_exc_unexpected_error;



END Get_AppsSchemaName;



FUNCTION Get_IecSchemaName

RETURN VARCHAR2

IS

   l_return BOOLEAN;

   l_status VARCHAR2(1);

   l_industry VARCHAR2(1);

   l_schema_name VARCHAR2(30);

BEGIN

   l_return := FND_INSTALLATION.GET_APP_INFO

      ( 'IEC'

      , l_status

      , l_industry

      , l_schema_name

      );



   IF NOT l_return THEN

      Log_SchemaNameNotFound

         ( 'Get_IecSchemaName'

         , 'CALL_FND_INSTALLATION.GET_APP_INFO'

         , 'IEC');

      RAISE fnd_api.g_exc_unexpected_error;

   END IF;



   RETURN l_schema_name;



END Get_IecSchemaName;



PROCEDURE Log_TerritoryNotFound

   ( p_method         IN VARCHAR2

   , p_sub_method     IN VARCHAR2

   , p_territory_code IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_TerritoryNotFoundMsg

      ( p_territory_code

      , 'HZ_PHONE_COUNTRY_CODES'

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_TerritoryNotFound;



PROCEDURE Log_TerritoryNotUnique

   ( p_method         IN VARCHAR2

   , p_sub_method     IN VARCHAR2

   , p_territory_code IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_TerritoryNotUniqueMsg

      ( p_territory_code

      , 'HZ_PHONE_COUNTRY_CODES'

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_TerritoryNotUnique;



PROCEDURE Log_GetSubsetViewError

   ( p_method         IN VARCHAR2

   , p_sub_method     IN VARCHAR2

   , p_subset_name    IN VARCHAR2

   , p_list_name      IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_GetSubsetViewErrorMsg

      ( p_subset_name

      , p_list_name

      , 'IEC_SUBSET_PVT.GET_SUBSET_VIEW'

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_GetSubsetViewError;



PROCEDURE Log_SubsetViewDoesNotExist

   ( p_method         IN VARCHAR2

   , p_sub_method     IN VARCHAR2

   , p_subset_name    IN VARCHAR2

   , p_list_name      IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_SubsetViewDoesNotExistMsg

      ( p_subset_name

      , p_list_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_SubsetViewDoesNotExist;



PROCEDURE Log_SourceTypeMismatchAll

   ( p_method           IN VARCHAR2

   , p_sub_method       IN VARCHAR2

   , p_source_type      IN VARCHAR2

   , p_source_type_dist IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_SourceTypeMismatchAllMsg

      ( p_source_type

      , p_source_type_dist

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_SourceTypeMismatchAll;



PROCEDURE Log_SourceTypeMismatchSome

   ( p_method           IN VARCHAR2

   , p_sub_method       IN VARCHAR2

   , p_source_type      IN VARCHAR2

   , p_source_type_dist IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_SourceTypeMismatchSomeMsg

      ( p_source_type

      , p_source_type_dist

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_SourceTypeMismatchSome;



PROCEDURE Log_NoEntriesFound

   ( p_method           IN VARCHAR2

   , p_sub_method       IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_NoEntriesFoundMsg

      ( g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_NoEntriesFound;



PROCEDURE Log_ValidationSuccess

   ( p_method           IN VARCHAR2

   , p_sub_method       IN VARCHAR2

   , p_total_count      IN VARCHAR2

   , p_valid_count      IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_ValidationSuccessMsg

      ( p_total_count

      , p_valid_count

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Set_LoggingGlobals('VALIDATED', p_method, p_sub_method);



END Log_ValidationSuccess;



PROCEDURE Log_StatusUpdateError

   ( p_method           IN VARCHAR2

   , p_sub_method       IN VARCHAR2

   , p_list_name        IN VARCHAR2)

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_StatusUpdateErrorMsg

      ( p_list_name

      , 'IEC_STATUS_PVT.UPDATE_LIST_STATUS'

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_StatusUpdateError;



FUNCTION Contains

   ( p_list  IN SYSTEM.varchar_tbl_type

   , p_value IN VARCHAR2

   )

RETURN BOOLEAN

IS

BEGIN



   IF p_list IS NOT NULL AND p_list.COUNT > 0 THEN

      FOR i IN p_list.FIRST..p_list.LAST LOOP

         IF p_list(i) = p_value THEN

            RETURN TRUE;

         END IF;

      END LOOP;

   END IF;

   RETURN FALSE;



END Contains;



PROCEDURE Log_MissingSourceTypeColumns

   ( p_list_id          IN            NUMBER

   , p_source_type_view IN            VARCHAR2

   , p_source_type_code IN            VARCHAR2

   , p_method           IN            VARCHAR2

   , p_sub_method       IN            VARCHAR2

   )

IS

   l_curr         VARCHAR2(32);

   l_columns      SYSTEM.varchar_tbl_type;

   l_missing_cols VARCHAR2(4000);

   l_ignore       VARCHAR2(4000);

   l_table_owner  VARCHAR2(30);

BEGIN



   l_table_owner := Get_AppsSchemaName;



   -- Change to ALL_TAB_COLS for performance reasons when 9i db becomes prereq

   SELECT COLUMN_NAME

   BULK COLLECT INTO l_columns

   FROM ALL_TAB_COLUMNS

   WHERE TABLE_NAME = p_source_type_view

   AND OWNER = l_table_owner;



   l_curr := 'LIST_ENTRY_ID';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'POSTAL_CODE';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'DO_NOT_USE_FLAG';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'DO_NOT_USE_REASON';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'NEWLY_UPDATED_FLAG';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;



   IF l_missing_cols IS NOT NULL THEN



      IEC_OCS_LOG_PVT.Init_SourceTypeMissingColsMsg

         ( p_source_type_code

         , l_missing_cols

         , g_message

         , g_encoded_message

         );



      -- References FND_MESSAGE object initialized above

      Log(p_method, p_sub_method);



   END IF;



END Log_MissingSourceTypeColumns;



PROCEDURE Log_CopyDestListInvalidStaMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopyDestListInvalidStaMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopyDestListInvalidStaMsg;



PROCEDURE Log_CopyDestListNotCCRMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopyDestListNotCCRMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopyDestListNotCCRMsg;



PROCEDURE Log_CopyDestListNotValMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopyDestListNotValMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopyDestListNotValMsg;



PROCEDURE Log_CopyDestListNullMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopyDestListNullMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopyDestListNullMsg;



PROCEDURE Log_CopySrcListInvalidStatMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopySrcListInvalidStatMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopySrcListInvalidStatMsg;



PROCEDURE Log_CopySrcListNotCCRMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopySrcListNotCCRMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopySrcListNotCCRMsg;



PROCEDURE Log_CopySrcListNotValMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopySrcListNotValMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopySrcListNotValMsg;



PROCEDURE Log_CopySrcListNullMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_src_schedule_name  IN VARCHAR2

   , p_dest_schedule_name IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_CopySrcListNullMsg

      ( p_src_schedule_name

      , p_dest_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_CopySrcListNullMsg;



PROCEDURE Log_ListRtInfoDNE

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_schedule_name      IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_ListRtInfoDNEMsg

      ( p_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_ListRtInfoDNE;



PROCEDURE Log_PurgeListStatusInvMsg

   ( p_method             IN VARCHAR2

   , p_sub_method         IN VARCHAR2

   , p_schedule_name      IN VARCHAR2

   )

IS

BEGIN



   IEC_OCS_LOG_PVT.Init_PurgeListStatusInvMsg

      ( p_schedule_name

      , g_message

      , g_encoded_message

      );



   -- References FND_MESSAGE object initialized above

   Log(p_method, p_sub_method);



END Log_PurgeListStatusInvMsg;



FUNCTION Get_ListName

   (p_list_id IN NUMBER)

RETURN VARCHAR2

IS

   l_name VARCHAR2(240);

BEGIN



   IEC_COMMON_UTIL_PVT.Get_ListName(p_list_id, l_name);



   RETURN l_name;

EXCEPTION

   WHEN OTHERS THEN

      Log('Get_ListName', 'MAIN');

      RAISE fnd_api.g_exc_unexpected_error;

END Get_ListName;



FUNCTION Get_ScheduleName

   (p_schedule_id IN NUMBER)

RETURN VARCHAR2

IS

   l_name VARCHAR2(240);

BEGIN



   IEC_COMMON_UTIL_PVT.Get_ScheduleName(p_schedule_id, l_name);



   RETURN l_name;

EXCEPTION

   WHEN OTHERS THEN

      Log('Get_ScheduleName', 'MAIN');

      RAISE fnd_api.g_exc_unexpected_error;

END Get_ScheduleName;



FUNCTION Get_SubsetName

   (p_subset_id IN NUMBER)

RETURN VARCHAR2

IS

   l_name VARCHAR2(240);

BEGIN



   IEC_COMMON_UTIL_PVT.Get_SubsetName(p_subset_id, l_name);



   RETURN l_name;

EXCEPTION

   WHEN OTHERS THEN

      Log('Get_ListName', 'MAIN');

      RAISE fnd_api.g_exc_unexpected_error;

END Get_SubsetName;



FUNCTION Get_SourceType

   (p_list_id IN NUMBER)

RETURN VARCHAR2

IS

   l_source_type VARCHAR2(500);

BEGIN



   BEGIN

      EXECUTE IMMEDIATE

         'SELECT LIST_SOURCE_TYPE

          FROM AMS_LIST_HEADERS_ALL

          WHERE LIST_HEADER_ID = :list_id'

      INTO l_source_type

      USING IN p_list_id;



   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Get_SourceType'

            , 'MAIN'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   RETURN l_source_type;



END Get_SourceType;



FUNCTION Get_SourceTypeView

   (p_list_id IN NUMBER)

RETURN VARCHAR2

IS

   l_source_type_view VARCHAR2(500);

BEGIN



   -- Get Source Type of List

   BEGIN

      IEC_COMMON_UTIL_PVT.Get_SourceTypeView(p_list_id, l_source_type_view);

   EXCEPTION

      WHEN OTHERS THEN

         -- FND_MESSAGE is initialized but not logged in Get_SourceTypeView

         -- if an exception is thrown, so we log it here with current

         -- module

         Log('Get_SourceTypeView', 'MAIN');

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   RETURN l_source_type_view;



END Get_SourceTypeView;



PROCEDURE Truncate_IecValEntryCache

IS

/* Start of fix for bug7622572 */

 /*  CURSOR l_trunc_temp_tbles_csr(table_owner VARCHAR2) IS

      SELECT 'TRUNCATE TABLE ' || OWNER || '.' || TABLE_NAME SQLSTMT

      FROM ALL_TABLES

      WHERE TABLE_NAME = 'IEC_VAL_ENTRY_CACHE'

      AND OWNER = table_owner;



   l_ddl_csr INTEGER; */



  -- PRAGMA AUTONOMOUS_TRANSACTION;
  -- commented the above line as part of re-fix for the same bug7622572 FP - 8319163

   /* End of fix for bug7622572 */



BEGIN

/* Start of fix for bug7622572 */

/*   l_ddl_csr := DBMS_SQL.OPEN_CURSOR;



   FOR l_rec IN l_trunc_temp_tbles_csr(Get_AppsSchemaName) LOOP

     DBMS_SQL.PARSE(l_ddl_csr, l_rec.SQLSTMT, DBMS_SQL.NATIVE);

   END LOOP;



   DBMS_SQL.CLOSE_CURSOR(l_ddl_csr);



   COMMIT;   */

   delete from IEC_VAL_ENTRY_CACHE;

 --  COMMIT;
 -- commented the above line as part of re-fix for the same bug7622572 FP - 8319163

   /* End of fix for bug7622572 */

EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK;

      RAISE;



END Truncate_IecValEntryCache;



PROCEDURE Truncate_Temporary_Tables

IS

/* Start of fix for bug7622572 */

/*   CURSOR l_trunc_temp_tbles_csr(table_owner VARCHAR2) IS

      SELECT 'TRUNCATE TABLE ' || OWNER || '.' || TABLE_NAME SQLSTMT

      FROM ALL_TABLES

      WHERE TABLE_NAME IN ('IEC_TC_TZ_PAIRS_CACHE', 'IEC_TZ_MAPPING_CACHE', 'IEC_TZ_OFFSET_MAP_CACHE', 'IEC_VAL_ENTRY_CACHE')

      AND OWNER = table_owner;



   l_ddl_csr INTEGER;  */

/* End of fix for bug7622572 */

 --  PRAGMA AUTONOMOUS_TRANSACTION;

-- commented the above line as part of re-fix for the same bug7622572 FP - 8319163


BEGIN

/* Start of fix for bug7622572 */

/*   l_ddl_csr := DBMS_SQL.OPEN_CURSOR;



   FOR l_rec IN l_trunc_temp_tbles_csr(Get_AppsSchemaName) LOOP

     DBMS_SQL.PARSE(l_ddl_csr, l_rec.SQLSTMT, DBMS_SQL.NATIVE);

   END LOOP;



   DBMS_SQL.CLOSE_CURSOR(l_ddl_csr);  */

delete from IEC_TC_TZ_PAIRS_CACHE;

delete from IEC_TZ_MAPPING_CACHE;

delete from IEC_TZ_OFFSET_MAP_CACHE;

delete from IEC_VAL_ENTRY_CACHE;

 --  COMMIT;
-- commented the above line as part of re-fix for the same bug7622572 FP - 8319163

EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK;

      RAISE;



END Truncate_Temporary_Tables;



PROCEDURE Refresh_MViews

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

   CURSOR Get_MaterializedViews(mview_owner VARCHAR2) IS

      SELECT OWNER || '.' || MVIEW_NAME MVIEW_LNAME

      FROM ALL_MVIEWS

      WHERE MVIEW_NAME IN ('IEC_O_VAL_DNU_S1_COUNTS_MV', 'IEC_O_VAL_DNU_S2_COUNTS_MV', 'IEC_O_VAL_DNU_S3_COUNTS_MV', 'IEC_O_VAL_DNU_S4_COUNTS_MV', 'IEC_O_VAL_DNU_S5_COUNTS_MV', 'IEC_O_VAL_DNU_S6_COUNTS_MV')

      AND OWNER = mview_owner;



BEGIN



   FOR rec IN Get_MaterializedViews(Get_IecSchemaName) LOOP

      DBMS_MVIEW.REFRESH(rec.MVIEW_LNAME, 'C');

   END LOOP;



   COMMIT;

EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK;

      RAISE;

END Refresh_MViews;



PROCEDURE Init_GlobalVariables

IS

BEGIN



   g_enable_zc_lookups := FALSE;

   g_enable_tz_map_ovrd := FALSE;

   g_enable_cell_phone_val := TRUE;

   g_phone_country_code := NULL;

   g_territory_code := NULL;

   g_enable_ac_incr_parse := FALSE;

   g_enable_cc_incr_parse := FALSE;

   g_timezone_id := NULL;

   g_region_id := NULL;

   g_enable_ac_length_val := TRUE;

   g_enable_pn_length_val := TRUE;



END Init_GlobalVariables;



PROCEDURE Init_LoggingVariables

IS

BEGIN



   g_fnd_log_enabled := TRUE;

   g_status          := NULl;

   g_method          := NULL;

   g_sub_method      := NULL;

   g_message         := NULL;

   g_encoded_message := NULL;

   g_module          := NULL;

   g_start_time      := NULL;

   g_end_time        := NULL;



END Init_LoggingVariables;



PROCEDURE Init_LookupTables

IS

BEGIN



   FOR cc_rec IN (SELECT DISTINCT B.PHONE_COUNTRY_CODE, B.AREA_CODE_LENGTH

                  FROM HZ_PHONE_COUNTRY_CODES B

                  WHERE B.AREA_CODE_LENGTH IS NOT NULL

                  AND (1, B.PHONE_COUNTRY_CODE) = (SELECT COUNT(*) COUNT, PHONE_COUNTRY_CODE

                                                   FROM (SELECT DISTINCT PHONE_COUNTRY_CODE, AREA_CODE_LENGTH

                                                         FROM HZ_PHONE_COUNTRY_CODES

                                                         WHERE AREA_CODE_LENGTH IS NOT NULL)

                                                   WHERE PHONE_COUNTRY_CODE = B.PHONE_COUNTRY_CODE GROUP BY PHONE_COUNTRY_CODE))

   LOOP

      g_ac_length_tbl(cc_rec.PHONE_COUNTRY_CODE) := cc_rec.AREA_CODE_LENGTH;

   END LOOP;



   FOR cc_rec IN (SELECT DISTINCT B.PHONE_COUNTRY_CODE, (B.PHONE_LENGTH - B.AREA_CODE_LENGTH) PN_LENGTH

                  FROM HZ_PHONE_COUNTRY_CODES B

                  WHERE B.PHONE_LENGTH IS NOT NULL

                  AND (1, B.PHONE_COUNTRY_CODE) = (SELECT COUNT(*) COUNT, PHONE_COUNTRY_CODE

                                                   FROM (SELECT DISTINCT PHONE_COUNTRY_CODE, PHONE_LENGTH

                                                         FROM HZ_PHONE_COUNTRY_CODES

                                                         WHERE PHONE_LENGTH IS NOT NULL)

                                                   WHERE PHONE_COUNTRY_CODE = B.PHONE_COUNTRY_CODE GROUP BY PHONE_COUNTRY_CODE))

   LOOP

      g_pn_length_tbl(cc_rec.PHONE_COUNTRY_CODE) := cc_rec.PN_LENGTH;

   END LOOP;



   FOR cc_rec IN (SELECT DISTINCT PHONE_COUNTRY_CODE, TERRITORY_CODE

                  FROM HZ_PHONE_COUNTRY_CODES A WHERE 1 = (SELECT COUNT(*)

                                                           FROM HZ_PHONE_COUNTRY_CODES

                                                           WHERE PHONE_COUNTRY_CODE = A.PHONE_COUNTRY_CODE))

   LOOP

      g_cc_tc_lookup_tbl(cc_rec.PHONE_COUNTRY_CODE) := cc_rec.TERRITORY_CODE;

   END LOOP;



   FOR cc_rec IN (SELECT DISTINCT PHONE_COUNTRY_CODE

                  FROM HZ_PHONE_COUNTRY_CODES)

   LOOP

      g_cc_cc_lookup_tbl(cc_rec.PHONE_COUNTRY_CODE) := cc_rec.PHONE_COUNTRY_CODE;

   END LOOP;



   FOR cc_rec IN (SELECT DISTINCT PHONE_COUNTRY_CODE, AREA_CODE, TERRITORY_CODE

                  FROM HZ_PHONE_AREA_CODES)

   LOOP

      g_cc_ac_tc_lookup_tbl(cc_rec.PHONE_COUNTRY_CODE || cc_rec.AREA_CODE) := cc_rec.TERRITORY_CODE;

   END LOOP;



  -- FOR cc_rec IN (SELECT TIMEZONE_ID FROM HZ_TIMEZONES_VL) //bug6449880
    FOR cc_rec IN (SELECT UPGRADE_TZ_ID FROM FND_TIMEZONES_VL)  -- bug6449880
   LOOP

     -- g_tz_lookup_tbl(cc_rec.TIMEZONE_ID) := cc_rec.TIMEZONE_ID; //bug6449880
      g_tz_lookup_tbl(cc_rec.UPGRADE_TZ_ID) := cc_rec.UPGRADE_TZ_ID; --bug6449880

   END LOOP;



END Init_LookupTables;



PROCEDURE Init_Rules

   (p_list_id IN NUMBER)

IS

   l_rule_block_id   NUMBER(15);

   l_action_id       NUMBER(15);

   l_action_code     VARCHAR2(500);

   l_data_code       VARCHAR2(500);

   l_data_code_col   SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();

   l_data_value_col  SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();



   l_count           PLS_INTEGER;

BEGIN



   BEGIN

      EXECUTE IMMEDIATE

         'SELECT VALIDATION_ACTION_BLOCK_ID

          FROM IEC_G_LIST_RT_INFO

          WHERE LIST_HEADER_ID = :list_id'

      INTO l_rule_block_id

      USING p_list_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         l_rule_block_id := NULL;

      WHEN OTHERS THEN

         Log( 'INIT_RULES'

            , 'GET_RULE_BLOCK_ID'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   IF l_rule_block_id IS NOT NULL THEN



      -- ENABLE TIME ZONE MAPPING WITH ZIPCODE?

      l_action_id := NULL;

      l_action_code := 'TIMEZONE_MAPPING_WITH_ZIP';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_zc_lookups := FALSE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_zc_lookups := TRUE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_zc_lookups := TRUE;

      END IF;



      -- ENABLE TIME ZONE MAPPINGS TO OVER RIDE PROVIDED DATA

      l_action_id := NULL;

      l_action_code := 'TZ_MAP_OVR_RIDE';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_tz_map_ovrd := FALSE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_tz_map_ovrd := TRUE;

      END;



      IF l_action_id IS NOT NULL THEN

        g_enable_tz_map_ovrd := TRUE;

      END IF;



      -- ENABLE INCREMENTAL PARSING OF AREA CODE FROM PHONE NUMBER FIELD

      l_action_id := NULL;

      l_action_code := 'INCR_PARSE_AC';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_ac_incr_parse := FALSE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_ac_incr_parse := TRUE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_ac_incr_parse := TRUE;

      END IF;



      -- ENABLE INCREMENTAL PARSING OF COUNTRY CODE FROM PHONE NUMBER FIELD

      l_action_id := NULL;

      l_action_code := 'INCR_PARSE_CC';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_cc_incr_parse := FALSE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_cc_incr_parse := TRUE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_cc_incr_parse := TRUE;

      END IF;



      -- DISABLE VALIDATION OF CELL PHONE NUMBERS

      l_action_id := NULL;

      l_action_code := 'CELL_PHONE_DISABLE';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_cell_phone_val := TRUE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_cell_phone_val := FALSE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_cell_phone_val := FALSE;

      END IF;



      -- Fail entries when the region cannot be determined

      l_action_id := NULL;

      l_action_code := 'REQUIRE_REGION';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_require_regions := FALSE;

         WHEN TOO_MANY_ROWS THEN

            g_require_regions := TRUE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_require_regions := TRUE;

      END IF;



      -- GET RULE SPECIFIED TIMEZONE ID

      l_action_code := 'TIMEZONE';

      l_data_code := 'TIMEZONE';



      EXECUTE IMMEDIATE

         'BEGIN

          SELECT B.DATA_VALUE BULK COLLECT INTO :data_value_col

          FROM IEC_O_ALG_ACTIONS A, IEC_O_ALG_DATA B

          WHERE A.ACTION_ID = B.OWNER_ID

          AND PARENT_BLOCK_ID = :rule_block_id

          AND ACTION_CODE = :action_code AND DATA_CODE = :data_code

          AND ROWNUM = 1;

          END;'

      USING OUT l_data_value_col, IN l_rule_block_id, IN l_action_code, IN l_data_code;



      IF l_data_value_col IS NOT NULL AND l_data_value_col.COUNT > 0 THEN

         g_timezone_id := l_data_value_col(1);

      END IF;



      -- GET RULE SPECIFIED TERRITORY CODE

      l_action_code := 'TERRITORY_CODE';

      l_data_code := 'TERRITORY_CODE';



      EXECUTE IMMEDIATE

         'BEGIN

          SELECT B.DATA_VALUE BULK COLLECT INTO :data_value_col

          FROM IEC_O_ALG_ACTIONS A, IEC_O_ALG_DATA B

          WHERE A.ACTION_ID = B.OWNER_ID

          AND PARENT_BLOCK_ID = :rule_block_id

          AND ACTION_CODE = :action_code AND DATA_CODE = :data_code

          AND ROWNUM = 1;

          END;'

      USING OUT l_data_value_col, IN l_rule_block_id, IN l_action_code, IN l_data_code;



      IF l_data_value_col IS NOT NULL AND l_data_value_col.COUNT > 0 THEN

         g_territory_code := l_data_value_col(1);



         BEGIN

            EXECUTE IMMEDIATE

               'SELECT PHONE_COUNTRY_CODE

                FROM HZ_PHONE_COUNTRY_CODES

                WHERE TERRITORY_CODE = :territory_code'

            INTO g_phone_country_code

            USING g_territory_code;

         EXCEPTION

            WHEN NO_DATA_FOUND THEN

               Log_TerritoryNotFound('Init_Rules', 'MAP_TERRITORY_CODE_TO_PHONE_COUNTRY_CODE', g_territory_code);

               RAISE fnd_api.g_exc_unexpected_error;

            WHEN TOO_MANY_ROWS THEN

               Log_TerritoryNotUnique('Init_Rules', 'MAP_TERRITORY_CODE_TO_PHONE_COUNTRY_CODE', g_territory_code);

               RAISE fnd_api.g_exc_unexpected_error;

         END;

      END IF;



      -- GET RULE SPECIFIED PHONE COUNTRY CODE IF TERRITORY_CODE WAS NOT ALREADY SPECIFIED

      IF g_phone_country_code IS NULL THEN



         l_action_code := 'PHONE_COUNTRY_CODE';

         l_data_code := 'PHONE_COUNTRY_CODE';



         EXECUTE IMMEDIATE

            'BEGIN

             SELECT B.DATA_VALUE BULK COLLECT INTO :data_value_col

             FROM IEC_O_ALG_ACTIONS A, IEC_O_ALG_DATA B

             WHERE A.ACTION_ID = B.OWNER_ID

             AND PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code AND DATA_CODE = :data_code

             AND ROWNUM = 1;

             END;'

         USING OUT l_data_value_col, IN l_rule_block_id, IN l_action_code, IN l_data_code;



         IF l_data_value_col IS NOT NULL AND l_data_value_col.COUNT > 0 THEN

           g_phone_country_code := l_data_value_col(1);

         END IF;

      END IF;



      -- GET RULE SPECIFIED REGION ID

      l_action_code := 'REGION';

      l_data_code := 'REGION';



      EXECUTE IMMEDIATE

         'BEGIN

          SELECT B.DATA_VALUE BULK COLLECT INTO :data_value_col

          FROM IEC_O_ALG_ACTIONS A, IEC_O_ALG_DATA B

          WHERE A.ACTION_ID = B.OWNER_ID

          AND PARENT_BLOCK_ID = :rule_block_id

          AND ACTION_CODE = :action_code AND DATA_CODE = :data_code

          AND ROWNUM = 1;

          END;'

      USING OUT l_data_value_col, IN l_rule_block_id, IN l_action_code, IN l_data_code;



      IF l_data_value_col IS NOT NULL AND l_data_value_col.COUNT > 0 THEN

         g_region_id := l_data_value_col(1);

      END IF;



      -- Disable validation of phone number length

      l_action_id := NULL;

      l_action_code := 'PN_LENGTH_VAL_DISABLE';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_pn_length_val := TRUE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_pn_length_val := FALSE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_pn_length_val := FALSE;

      END IF;



      -- Disable validation of area code length

      l_action_id := NULL;

      l_action_code := 'AC_LENGTH_VAL_DISABLE';

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT ACTION_ID

             FROM IEC_O_ALG_ACTIONS

             WHERE PARENT_BLOCK_ID = :rule_block_id

             AND ACTION_CODE = :action_code'

         INTO l_action_id

         USING l_rule_block_id, l_action_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            g_enable_ac_length_val := TRUE;

         WHEN TOO_MANY_ROWS THEN

            g_enable_ac_length_val := FALSE;

      END;



      IF l_action_id IS NOT NULL THEN

         g_enable_ac_length_val := FALSE;

      END IF;



      -- LOAD TZ OFFSET OR NAME MAPPINGS AS DEFINED IN RULES

      l_action_code := 'TIMEZONE_MAPPING';

      l_data_code := 'TIMEZONE_CODE';



      EXECUTE IMMEDIATE

         'BEGIN

          SELECT B.DATA_CODE, B.DATA_VALUE BULK COLLECT INTO :data_code_col, :data_value_col

          FROM IEC_O_ALG_ACTIONS A, IEC_O_ALG_DATA B

          WHERE A.ACTION_ID = B.OWNER_ID

          AND PARENT_BLOCK_ID = :rule_block_id

          AND ACTION_CODE = :action_code

          AND DATA_CODE IN (:data_code, ''TIMEZONE_VALUE'')

          ORDER BY A.ACTION_ID, B.DATA_CODE;

          END;'

      USING OUT l_data_code_col, OUT l_data_value_col, IN l_rule_block_id, IN l_action_code, IN l_data_code;



      IF l_data_code_col IS NOT NULL AND l_data_code_col.COUNT > 0 THEN



         l_count := 1;

         WHILE l_count < l_data_code_col.COUNT LOOP



            BEGIN

               EXECUTE IMMEDIATE

                  'INSERT INTO IEC_TZ_OFFSET_MAP_CACHE (OFFSET, TIMEZONE_ID) VALUES (:timezone_offset, :timezone)'

               USING l_data_value_col(l_count), l_data_value_col(l_count + 1);

            EXCEPTION

               WHEN DUP_VAL_ON_INDEX THEN

                  NULL;

            END;



            l_count := l_count + 2;

         END LOOP;

      END IF;



   END IF;



   -- LOAD TZ MAPPING CACHE



   IF g_enable_zc_lookups THEN

      INSERT INTO IEC_TZ_MAPPING_CACHE

         (TERRITORY_CODE, AREA_CODE, POSTAL_CODE, TIMEZONE_ID)

         SELECT DISTINCT TERRITORY_CODE, PHONE_AREA_CODE, POSTAL_CODE, TIMEZONE_ID

         FROM IEC_G_TIMEZONE_MAPPINGS;

   ELSE

      INSERT INTO IEC_TZ_MAPPING_CACHE

         (TERRITORY_CODE, AREA_CODE, POSTAL_CODE, TIMEZONE_ID)

         SELECT DISTINCT TERRITORY_CODE, PHONE_AREA_CODE, NULL, TIMEZONE_ID

         FROM IEC_G_TIMEZONE_MAPPINGS;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'INIT_RULES'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Init_Rules;



PROCEDURE Update_ReportCounts

   ( p_campaign_id              IN NUMBER

   , p_schedule_id              IN NUMBER

   , p_list_id                  IN NUMBER

   , p_subset_id_col            IN SYSTEM.number_tbl_type

   , p_sub_rec_loaded_incr_col  IN SYSTEM.number_tbl_type)

IS

   l_rec_count                    NUMBER;

BEGIN



   -- Create/Update subset records in IEC_G_REP_SUBSET_COUNTS

   IF p_subset_id_col IS NOT NULL AND p_subset_id_col.COUNT > 0 THEN



      FOR i IN 1..p_subset_id_col.LAST LOOP



         -- Check for existence of record for the current subset

         EXECUTE IMMEDIATE

            'SELECT COUNT(*)

             FROM IEC_G_REP_SUBSET_COUNTS

             WHERE SUBSET_ID = :subset_id'

         INTO l_rec_count

         USING p_subset_id_col(i);



         -- If record does not exist, create record and initialize counts

         IF l_rec_count = 0 THEN



            EXECUTE IMMEDIATE

               'INSERT INTO IEC_G_REP_SUBSET_COUNTS

                ( SUBSET_COUNT_ID

                , CAMPAIGN_ID

                , SCHEDULE_ID

                , LIST_HEADER_ID

                , SUBSET_ID

                , RECORD_LOADED

                , RECORD_CALLED_ONCE

                , RECORD_CALLED_AND_REMOVED

                , RECORD_CALLED_AND_REMOVED_COPY

                , LAST_COPY_TIME

                , CREATED_BY

                , CREATION_DATE

                , LAST_UPDATE_LOGIN

                , LAST_UPDATE_DATE

                , LAST_UPDATED_BY

                , OBJECT_VERSION_NUMBER

                )

                VALUES

                (IEC_G_REP_SUBSET_COUNTS_S.NEXTVAL

                , :campaign_id

                , :schedule_id

                , :list_id

                , :subset_id

                , :records_loaded

                , 0

                , 0

                , 0

                , SYSDATE

                , 1

                , SYSDATE

                , 1

                , SYSDATE

                , 0

                , 0)'

            USING p_campaign_id

                , p_schedule_id

                , p_list_id

                , p_subset_id_col(i)

                , p_sub_rec_loaded_incr_col(i);



         ELSE



            -- If record exists, simply update counts by appropriate increment

            EXECUTE IMMEDIATE

               'UPDATE IEC_G_REP_SUBSET_COUNTS

                   SET RECORD_LOADED = RECORD_LOADED + :records_loaded

                     , LAST_UPDATE_DATE = SYSDATE

                WHERE SUBSET_ID = :subset_id'

            USING p_sub_rec_loaded_incr_col(i)

                , p_subset_id_col(i);



         END IF;



      END LOOP;



   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Update_ReportCounts'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_ReportCounts;



PROCEDURE Update_Status

   ( p_list_id IN NUMBER

   , p_status  IN VARCHAR2)

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN



   IF p_status = 'VALIDATED' THEN



      BEGIN

         g_end_time := SYSDATE;



         EXECUTE IMMEDIATE

            'UPDATE IEC_O_VALIDATION_STATUS

                SET VALIDATED_ONCE_FLAG = ''Y''

                  , VALIDATION_END_TIME = :end_time

                  , LAST_UPDATE_DATE = SYSDATE

                WHERE LIST_HEADER_ID = :list_id'

         USING g_end_time, p_list_id;

      EXCEPTION

         WHEN OTHERS THEN

            Log('UPDATE_STATUS', 'DO_IEC_STAT_UPD_VALIDATED', SQLERRM);

            RAISE fnd_api.g_exc_unexpected_error;

      END;



   ELSIF p_status = 'VALIDATING' THEN



      BEGIN

         g_start_time := SYSDATE;



         EXECUTE IMMEDIATE

            'UPDATE IEC_O_VALIDATION_STATUS

                SET SCHEDULED_EXECUTION_TIME = NULL

                  , USER_SCHEDULED_EXECUTION_TIME = NULL

                  , USER_TIMEZONE_ID = NULL

                  , VALIDATION_START_TIME = :start_time

                  , VALIDATION_END_TIME = NULL

                  , LAST_UPDATE_DATE = SYSDATE

                WHERE LIST_HEADER_ID = :list_id'

         USING g_start_time, p_list_id;

      EXCEPTION

         WHEN OTHERS THEN

            Log('UPDATE_STATUS', 'DO_IEC_STAT_UPD_VALIDATING', SQLERRM);

            RAISE fnd_api.g_exc_unexpected_error;

      END;



   ELSIF p_status = 'FAILED_VALIDATION' THEN



      BEGIN

         g_end_time := SYSDATE;



         EXECUTE IMMEDIATE

            'UPDATE IEC_O_VALIDATION_STATUS

                SET VALIDATION_END_TIME = SYSDATE

                  , LAST_UPDATE_DATE = SYSDATE

                WHERE LIST_HEADER_ID = :list_id'

         USING p_list_id;

      EXCEPTION

         WHEN OTHERS THEN

            Log('UPDATE_STATUS', 'DO_IEC_STAT_UPD_FAILED_VALIDATION', SQLERRM);

            RAISE fnd_api.g_exc_unexpected_error;

      END;

   ELSE

      -- must log start/end time if status code is invalid

      -- for validation history logging purposes

      IF g_start_time IS NULL THEN

         g_start_time := SYSDATE;

      END IF;

      IF g_end_time IS NULL THEN

         g_end_time := SYSDATE;

      END IF;

   END IF;



   -- Update the Marketing list status

   BEGIN

      Iec_Status_Pvt.Update_List_Status(p_list_id, p_status);

   EXCEPTION

      WHEN OTHERS THEN

         Log_StatusUpdateError('Update_Status', 'DO_MKT_STATUS_UPDATE', Get_ListName(p_list_id));

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   COMMIT;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK;

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE;

      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK;

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE;

      END IF;

   WHEN OTHERS THEN

      ROLLBACK;

      Log('UPDATE_STATUS', 'MAIN', SQLERRM);

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE fnd_api.g_exc_unexpected_error;

      END IF;



END Update_Status;



PROCEDURE Update_AmsListHeaderCounts

   ( p_list_id           IN NUMBER

   , p_rows_in_list_incr IN NUMBER

   , p_rows_active_incr  IN NUMBER

   )

IS
  l_api_version     CONSTANT NUMBER   := 1.0;
  l_init_msg_list		VARCHAR2(1);
  l_return_status		VARCHAR2(1);
  l_msg_count			  NUMBER;
  l_msg_data			  VARCHAR2(2000);

  l_no_of_rows_in_list NUMBER;
  l_no_of_rows_active  NUMBER;

BEGIN
  l_init_msg_list		:=FND_API.G_TRUE;

  IF(G_LISTHEADER_REC_INITIAL = 0 ) THEN

      l_listheader_rec.last_update_date := FND_API.g_miss_date;
      l_listheader_rec.last_updated_by := FND_API.g_miss_num;
      l_listheader_rec.creation_date := FND_API.g_miss_date;
      l_listheader_rec.created_by := FND_API.g_miss_num;
      l_listheader_rec.last_update_login := FND_API.g_miss_num;
      l_listheader_rec.object_version_number := FND_API.g_miss_num;
      l_listheader_rec.request_id := FND_API.g_miss_num;
      l_listheader_rec.program_id := FND_API.g_miss_num;
      l_listheader_rec.program_application_id := FND_API.g_miss_num;
      l_listheader_rec.program_update_date := FND_API.g_miss_date;
      l_listheader_rec.view_application_id := FND_API.g_miss_num;
      l_listheader_rec.list_name := FND_API.g_miss_char;
      l_listheader_rec.list_used_by_id := FND_API.g_miss_num;
      l_listheader_rec.arc_list_used_by := FND_API.g_miss_char;
      l_listheader_rec.list_type := FND_API.g_miss_char;
      l_listheader_rec.status_code := FND_API.g_miss_char;
      l_listheader_rec.status_date := FND_API.g_miss_date;
      l_listheader_rec.generation_type := FND_API.g_miss_char;
      l_listheader_rec.repeat_exclude_type := FND_API.g_miss_char;
      l_listheader_rec.row_selection_type := FND_API.g_miss_char;
      l_listheader_rec.owner_user_id := FND_API.g_miss_num;
      l_listheader_rec.access_level := FND_API.g_miss_char;
      l_listheader_rec.enable_log_flag :=FND_API.g_miss_char;
      l_listheader_rec.enable_word_replacement_flag := FND_API.g_miss_char;
      l_listheader_rec.enable_parallel_dml_flag := FND_API.g_miss_char;
      l_listheader_rec.dedupe_during_generation_flag := FND_API.g_miss_char;
      l_listheader_rec.generate_control_group_flag := FND_API.g_miss_char;
      l_listheader_rec.last_generation_success_flag := FND_API.g_miss_char;
      l_listheader_rec.forecasted_start_date := FND_API.g_miss_date;
      l_listheader_rec.forecasted_end_date := FND_API.g_miss_date;
      l_listheader_rec.actual_end_date := FND_API.g_miss_date;
      l_listheader_rec.sent_out_date := FND_API.g_miss_date;
      l_listheader_rec.dedupe_start_date := FND_API.g_miss_date;
      l_listheader_rec.last_dedupe_date := FND_API.g_miss_date;
      l_listheader_rec.last_deduped_by_user_id := FND_API.g_miss_num;
      l_listheader_rec.workflow_item_key := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_duplicates := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_min_requested := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_max_requested := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_in_list := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_in_ctrl_group := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_active := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_inactive := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_manually_entered := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_do_not_call := FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_do_not_mail :=FND_API.g_miss_num;
      l_listheader_rec.no_of_rows_random := FND_API.g_miss_num;
      l_listheader_rec.org_id := FND_API.g_miss_num;
      l_listheader_rec.main_gen_start_time := FND_API.g_miss_date;
      l_listheader_rec.main_gen_end_time := FND_API.g_miss_date;
      l_listheader_rec.main_random_nth_row_selection := FND_API.g_miss_num;
      l_listheader_rec.main_random_pct_row_selection := FND_API.g_miss_num;
      l_listheader_rec.ctrl_random_nth_row_selection := FND_API.g_miss_num;
      l_listheader_rec.ctrl_random_pct_row_selection := FND_API.g_miss_num;
      l_listheader_rec.repeat_source_list_header_id := FND_API.g_miss_char;
      l_listheader_rec.result_text := FND_API.g_miss_char;
      l_listheader_rec.keywords := FND_API.g_miss_char;
      l_listheader_rec.description := FND_API.g_miss_char;
      l_listheader_rec.list_priority := FND_API.g_miss_num;
      l_listheader_rec.assign_person_id := FND_API.g_miss_num;
      l_listheader_rec.list_source := FND_API.g_miss_char;
      l_listheader_rec.list_source_type := FND_API.g_miss_char;
      l_listheader_rec.list_online_flag := FND_API.g_miss_char;
      l_listheader_rec.random_list_id := FND_API.g_miss_num;
      l_listheader_rec.enabled_flag := FND_API.g_miss_char;
      l_listheader_rec.assigned_to := FND_API.g_miss_num;
      l_listheader_rec.query_id := FND_API.g_miss_num;
      l_listheader_rec.owner_person_id := FND_API.g_miss_num;
      l_listheader_rec.archived_by := FND_API.g_miss_num;
      l_listheader_rec.archived_date := FND_API.g_miss_date;
      l_listheader_rec.attribute_category := FND_API.g_miss_char;
      l_listheader_rec.attribute1 := FND_API.g_miss_char;
      l_listheader_rec.attribute2 := FND_API.g_miss_char;
      l_listheader_rec.attribute3 := FND_API.g_miss_char;
      l_listheader_rec.attribute4 := FND_API.g_miss_char;
      l_listheader_rec.attribute5 := FND_API.g_miss_char;
      l_listheader_rec.attribute6 := FND_API.g_miss_char;
      l_listheader_rec.attribute7 := FND_API.g_miss_char;
      l_listheader_rec.attribute8 := FND_API.g_miss_char;
      l_listheader_rec.attribute9 := FND_API.g_miss_char;
      l_listheader_rec.attribute10 := FND_API.g_miss_char;
      l_listheader_rec.attribute11 := FND_API.g_miss_char;
      l_listheader_rec.attribute12 := FND_API.g_miss_char;
      l_listheader_rec.attribute13 := FND_API.g_miss_char;
      l_listheader_rec.attribute14 := FND_API.g_miss_char;
      l_listheader_rec.attribute15 := FND_API.g_miss_char;
      l_listheader_rec.timezone_id := FND_API.g_miss_num;
      l_listheader_rec.user_entered_start_time := FND_API.g_miss_date;
      l_listheader_rec.user_status_id := FND_API.g_miss_num;
      l_listheader_rec.quantum := FND_API.g_miss_num;
      l_listheader_rec.release_control_alg_id := FND_API.g_miss_num;
      l_listheader_rec.dialing_method := FND_API.g_miss_char;
      l_listheader_rec.calling_calendar_id := FND_API.g_miss_num;
      l_listheader_rec.release_strategy := FND_API.g_miss_char;
      l_listheader_rec.custom_setup_id := FND_API.g_miss_num;
      l_listheader_rec.country := FND_API.g_miss_num;
      l_listheader_rec.callback_priority_flag := FND_API.g_miss_char;
      l_listheader_rec.call_center_ready_flag := FND_API.g_miss_char;
      l_listheader_rec.language := FND_API.g_miss_char;
      l_listheader_rec.purge_flag := FND_API.g_miss_char;
      l_listheader_rec.public_flag := FND_API.g_miss_char;
      l_listheader_rec.list_category := FND_API.g_miss_char;
      l_listheader_rec.quota := FND_API.g_miss_num;
      l_listheader_rec.quota_reset := FND_API.g_miss_num;
      l_listheader_rec.recycling_alg_id := FND_API.g_miss_num;
      l_listheader_rec.source_lang := FND_API.g_miss_char;

    G_LISTHEADER_REC_INITIAL := 1;
  END IF;

  select nvl(no_of_rows_in_list,0), nvl(no_of_rows_active,0) into l_no_of_rows_in_list, l_no_of_rows_active from
  AMS_LIST_HEADERS_ALL where list_header_id = p_list_id;
  l_listheader_rec.list_header_id := p_list_id;
  l_listheader_rec.no_of_rows_in_list := l_no_of_rows_in_list + p_rows_in_list_incr;
  l_listheader_rec.no_of_rows_active := l_no_of_rows_active + p_rows_active_incr;

  AMS_LISTHEADER_PUB.Update_ListHeader
  (   p_api_version => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_listheader_rec => l_listheader_rec);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Log_msg('AMS_LISTHEADER_PUB.Update_ListHeader', l_msg_data);
  END IF;

/*
   EXECUTE IMMEDIATE

      'UPDATE AMS_LIST_HEADERS_ALL

       SET NO_OF_ROWS_IN_LIST = NVL(NO_OF_ROWS_IN_LIST, 0) + :rows_incr

         , NO_OF_ROWS_ACTIVE = NVL(NO_OF_ROWS_ACTIVE, 0) + :active_incr

       WHERE LIST_HEADER_ID = :list_id'

   USING IN p_rows_in_list_incr

       , IN p_rows_active_incr

       , IN p_list_id;

*/

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Update_AmsListHeaderCounts'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_AmsListHeaderCounts;



PROCEDURE Update_MoveEntriesStatusCounts

   ( p_from_list_id    IN NUMBER

   , p_records_moved   IN NUMBER

   , p_records_updated IN NUMBER

   )

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN



   -- Update counts relative to current values

   EXECUTE IMMEDIATE

      'UPDATE IEC_O_MOVE_RECORDS_STATUS

          SET RECORDS_MOVED = NVL(RECORDS_MOVED, 0) + :records_moved

          ,   RECORDS_UPDATED = NVL(RECORDS_UPDATED, 0) + :records_updated

          , LAST_UPDATE_DATE = SYSDATE

       WHERE FROM_LIST_HEADER_ID = :from_list_id'

   USING p_records_moved, p_records_updated, p_from_list_id;



   COMMIT;

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Update_MoveEntriesStatusCounts'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK;

      RAISE fnd_api.g_exc_unexpected_error;



END Update_MoveEntriesStatusCounts;



PROCEDURE Update_MoveEntriesStatus

   ( p_from_list_id  IN NUMBER

   , p_to_list_id    IN NUMBER

   , p_status        IN VARCHAR2

   , p_api_initiated IN BOOLEAN)

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

   l_count NUMBER;

   l_user_id NUMBER;

   l_login_id NUMBER;

   l_api_init_flag VARCHAR2(1);



   l_sequence NUMBER(15);

BEGIN



   l_user_id := nvl(FND_GLOBAL.user_id, -1);

   l_login_id := nvl(FND_GLOBAL.conc_login_id, -1);



   IF p_status = 'MOVING' AND p_api_initiated THEN

      l_api_init_flag := 'Y';

   ELSE

      l_api_init_flag := NULL;

   END IF;



   -- Verify that record exists in IEC_O_MOVE_RECORDS_STATUS

   -- We need to do this now that we are providing an api

   -- and we can't rely on the admin screens to create this record

   EXECUTE IMMEDIATE

      'SELECT COUNT(*)

       FROM IEC_O_MOVE_RECORDS_STATUS

       WHERE FROM_LIST_HEADER_ID = :from_list_id'

   INTO l_count

   USING p_from_list_id;



   IF l_count = 0 THEN

      EXECUTE IMMEDIATE

         'SELECT IEC_O_MOVE_RECORDS_STATUS_S.NEXTVAL FROM DUAL'

      INTO l_sequence;

      EXECUTE IMMEDIATE

         'INSERT INTO IEC_O_MOVE_RECORDS_STATUS

          ( MOVE_RECORDS_STATUS_ID

          , FROM_LIST_HEADER_ID

          , TO_LIST_HEADER_ID

          , MOVE_RECORDS_STATUS_CODE

          , API_INITIATED_FLAG

          , RECORDS_MOVED

          , RECORDS_UPDATED

          , CREATED_BY

          , CREATION_DATE

          , LAST_UPDATED_BY

          , LAST_UPDATE_DATE

          , LAST_UPDATE_LOGIN

          , OBJECT_VERSION_NUMBER

          )

          VALUES

          ( :move_records_status_id

          , :from_list_header_id

          , :to_list_header_id

          , ''PENDING_MOVE''

          , :api_init_flag

          , 0

          , 0

          , :user_id

          , SYSDATE

          , :user_id

          , SYSDATE

          , :login_id

          , 0

          )'

      USING l_sequence

          , p_from_list_id

          , p_to_list_id

          , l_api_init_flag

          , l_user_id

          , l_user_id

          , l_login_id;

   END IF;



   IF p_status = 'MOVED' THEN

      EXECUTE IMMEDIATE

         'UPDATE IEC_O_MOVE_RECORDS_STATUS

             SET MOVE_RECORDS_STATUS_CODE = :status

               , API_INITIATED_FLAG = NULL

               , SCHEDULED_EXECUTION_TIME = NULL

               , USER_SCHEDULED_EXECUTION_TIME = NULL

               , USER_TIMEZONE_ID = NULL

               , MOVE_RECORDS_END_TIME = SYSDATE

               , LAST_UPDATE_DATE = SYSDATE

             WHERE FROM_LIST_HEADER_ID = :from_list_id'

      USING p_status, p_from_list_id;

   ELSIF p_status = 'MOVING' THEN

      EXECUTE IMMEDIATE

         'UPDATE IEC_O_MOVE_RECORDS_STATUS

             SET MOVE_RECORDS_STATUS_CODE = :status

               , TO_LIST_HEADER_ID = :to_list_id

               , API_INITIATED_FLAG = :api_init_flag

               , RECORDS_MOVED = 0

               , RECORDS_UPDATED = 0

               , SCHEDULED_EXECUTION_TIME = NULL

               , USER_SCHEDULED_EXECUTION_TIME = NULL

               , USER_TIMEZONE_ID = NULL

               , MOVE_RECORDS_START_TIME = SYSDATE

               , MOVE_RECORDS_END_TIME = NULL

               , LAST_UPDATE_DATE = SYSDATE

             WHERE FROM_LIST_HEADER_ID = :from_list_id'

      USING p_status, p_to_list_id, l_api_init_flag, p_from_list_id;

   ELSE

      EXECUTE IMMEDIATE

         'UPDATE IEC_O_MOVE_RECORDS_STATUS

             SET MOVE_RECORDS_STATUS_CODE = :status

               , API_INITIATED_FLAG = NULL

               , SCHEDULED_EXECUTION_TIME = NULL

               , USER_SCHEDULED_EXECUTION_TIME = NULL

               , USER_TIMEZONE_ID = NULL

               , MOVE_RECORDS_END_TIME = SYSDATE

               , LAST_UPDATE_DATE = SYSDATE

             WHERE FROM_LIST_HEADER_ID = :from_list_id'

      USING p_status, p_from_list_id;

   END IF;



   COMMIT;

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Update_MoveEntriesStatus'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK;

      RAISE fnd_api.g_exc_unexpected_error;



END Update_MoveEntriesStatus;



PROCEDURE Update_PurgeStatus

   ( p_list_id       IN NUMBER

   , p_schedule_id   IN NUMBER

   , p_status        IN VARCHAR2

   , p_api_initiated IN BOOLEAN)

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

   l_count NUMBER;

   l_api_init_flag VARCHAR2(1);

BEGIN



   -- We will assume that the rt info record exists

   -- If not, we will simply throw an exception

   -- b/c I don't think we should be in the business of creating

   -- that here

   EXECUTE IMMEDIATE

      'SELECT COUNT(*)

       FROM IEC_G_LIST_RT_INFO

       WHERE LIST_HEADER_ID = :list_id'

   INTO l_count

   USING p_list_id;



   IF l_count = 0 THEN

      Log_ListRtInfoDNE('Update_PurgeStatus', 'CHECK_LIST_RT_INFO', Get_ScheduleName(p_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   IF p_status = 'PURGING' AND p_api_initiated THEN

      l_api_init_flag := 'Y';

   ELSE

      l_api_init_flag := NULL;

   END IF;



   -- Update the Marketing list status

   BEGIN

      Iec_Status_Pvt.Update_List_Status(p_list_id, p_status, l_api_init_flag);

   EXCEPTION

      WHEN OTHERS THEN

         Log_StatusUpdateError('Update_PurgeStatus', 'DO_MKT_STATUS_UPDATE', Get_ListName(p_list_id));

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   COMMIT;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK;

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE;

      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK;

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE;

      END IF;

   WHEN OTHERS THEN

      ROLLBACK;

      Log('UPDATE_STATUS', 'MAIN', SQLERRM);

      IF p_status <> 'FAILED_VALIDATION' THEN

         RAISE fnd_api.g_exc_unexpected_error;

      END IF;



END Update_PurgeStatus;



PROCEDURE Update_AmsListEntries

   ( p_list_id IN NUMBER

   , p_source_type_view IN VARCHAR2)

IS

      -- UPDATE ALE

      BEGIN

         EXECUTE IMMEDIATE

            'BEGIN

                UPDATE ' || p_source_type_view || ' A' ||

                ' SET

                ( DO_NOT_USE_FLAG,

                  DO_NOT_USE_REASON,

                  NEWLY_UPDATED_FLAG,

                  CONTACT_POINT_ID_S1, TIME_ZONE_S1, PHONE_COUNTRY_CODE_S1, PHONE_AREA_CODE_S1, PHONE_NUMBER_S1, RAW_PHONE_NUMBER_S1, REASON_CODE_S1,

                  CONTACT_POINT_ID_S2, TIME_ZONE_S2, PHONE_COUNTRY_CODE_S2, PHONE_AREA_CODE_S2, PHONE_NUMBER_S2, RAW_PHONE_NUMBER_S2, REASON_CODE_S2,

                  CONTACT_POINT_ID_S3, TIME_ZONE_S3, PHONE_COUNTRY_CODE_S3, PHONE_AREA_CODE_S3, PHONE_NUMBER_S3, RAW_PHONE_NUMBER_S3, REASON_CODE_S3,

                  CONTACT_POINT_ID_S4, TIME_ZONE_S4, PHONE_COUNTRY_CODE_S4, PHONE_AREA_CODE_S4, PHONE_NUMBER_S4, RAW_PHONE_NUMBER_S4, REASON_CODE_S4,

                  CONTACT_POINT_ID_S5, TIME_ZONE_S5, PHONE_COUNTRY_CODE_S5, PHONE_AREA_CODE_S5, PHONE_NUMBER_S5, RAW_PHONE_NUMBER_S5, REASON_CODE_S5,

                  CONTACT_POINT_ID_S6, TIME_ZONE_S6, PHONE_COUNTRY_CODE_S6, PHONE_AREA_CODE_S6, PHONE_NUMBER_S6, RAW_PHONE_NUMBER_S6, REASON_CODE_S6

                ) =

                ( SELECT DO_NOT_USE_FLAG,

                         DO_NOT_USE_REASON,

                         ''N'',

                         CONTACT_POINT_ID_S1, TIME_ZONE_S1, PHONE_COUNTRY_CODE_S1, PHONE_AREA_CODE_S1, PHONE_NUMBER_S1, RAW_PHONE_NUMBER_S1, MKTG_ITEM_CC_TZS_ID_S1,

                         CONTACT_POINT_ID_S2, TIME_ZONE_S2, PHONE_COUNTRY_CODE_S2, PHONE_AREA_CODE_S2, PHONE_NUMBER_S2, RAW_PHONE_NUMBER_S2, MKTG_ITEM_CC_TZS_ID_S2,

                         CONTACT_POINT_ID_S3, TIME_ZONE_S3, PHONE_COUNTRY_CODE_S3, PHONE_AREA_CODE_S3, PHONE_NUMBER_S3, RAW_PHONE_NUMBER_S3, MKTG_ITEM_CC_TZS_ID_S3,

                         CONTACT_POINT_ID_S4, TIME_ZONE_S4, PHONE_COUNTRY_CODE_S4, PHONE_AREA_CODE_S4, PHONE_NUMBER_S4, RAW_PHONE_NUMBER_S4, MKTG_ITEM_CC_TZS_ID_S4,

                         CONTACT_POINT_ID_S5, TIME_ZONE_S5, PHONE_COUNTRY_CODE_S5, PHONE_AREA_CODE_S5, PHONE_NUMBER_S5, RAW_PHONE_NUMBER_S5, MKTG_ITEM_CC_TZS_ID_S5,

                         CONTACT_POINT_ID_S6, TIME_ZONE_S6, PHONE_COUNTRY_CODE_S6, PHONE_AREA_CODE_S6, PHONE_NUMBER_S6, RAW_PHONE_NUMBER_S6, MKTG_ITEM_CC_TZS_ID_S6

                  FROM IEC_VAL_ENTRY_CACHE B WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID

                )

             WHERE LIST_HEADER_ID = :list_id AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE);

             END;'

          USING p_list_id;



EXCEPTION

   WHEN OTHERS THEN

      IF SQLCODE = -904 THEN

         Log_MissingSourceTypeColumns(p_list_id, p_source_type_view, Get_SourceType(p_list_id), 'UPDATE_AMS_LIST_ENTRIES', 'UPDATE_LIST_ENTRIES');

         RAISE fnd_api.g_exc_unexpected_error;

      ELSE

         Log( 'Update_AmsListEntries'

            , 'MAIN'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

      END IF;

END Update_AmsListEntries;



PROCEDURE Update_ValidationReportDetails

   (p_list_id IN NUMBER)

IS



   l_user_id NUMBER;

   l_login_id NUMBER;



   L_TEMP VARCHAR2(4000);

BEGIN

   l_user_id := nvl(FND_GLOBAL.user_id, -1);

   l_login_id := nvl(FND_GLOBAL.conc_login_id, -1);



   BEGIN

      EXECUTE IMMEDIATE

         'UPDATE IEC_O_VALIDATION_REPORT_DETS A

             SET

                ( DO_NOT_USE_REASON_S1

                , DO_NOT_USE_REASON_S2

                , DO_NOT_USE_REASON_S3

                , DO_NOT_USE_REASON_S4

                , DO_NOT_USE_REASON_S5

                , DO_NOT_USE_REASON_S6

                ) =

                ( SELECT

                         DO_NOT_USE_REASON_S1

                       , DO_NOT_USE_REASON_S2

                       , DO_NOT_USE_REASON_S3

                       , DO_NOT_USE_REASON_S4

                       , DO_NOT_USE_REASON_S5

                       , DO_NOT_USE_REASON_S6

                  FROM IEC_VAL_ENTRY_CACHE B WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID

                )

              , LAST_UPDATED_BY = :login_id

              , LAST_UPDATE_DATE = SYSDATE

              , LAST_UPDATE_LOGIN = :login_id

          WHERE A.LIST_HEADER_ID = :list_id

          AND A.LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE)'

      USING l_login_id, l_login_id, p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_ValidationReportDetails'

            , 'UPDATE_EXISTING_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   BEGIN

      EXECUTE IMMEDIATE

         'DELETE IEC_O_VALIDATION_REPORT_DETS

          WHERE LIST_HEADER_ID = :list_id

          AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE)

          AND DO_NOT_USE_REASON_S1 IS NULL

          AND DO_NOT_USE_REASON_S2 IS NULL

          AND DO_NOT_USE_REASON_S3 IS NULL

          AND DO_NOT_USE_REASON_S4 IS NULL

          AND DO_NOT_USE_REASON_S5 IS NULL

          AND DO_NOT_USE_REASON_S6 IS NULL'

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_ValidationReportDetails'

            , 'DELETE_UNNECESSARY_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   BEGIN

      EXECUTE IMMEDIATE

         'INSERT INTO IEC_O_VALIDATION_REPORT_DETS

                ( LIST_HEADER_ID

                , LIST_ENTRY_ID

                , DO_NOT_USE_REASON_S1

                , DO_NOT_USE_REASON_S2

                , DO_NOT_USE_REASON_S3

                , DO_NOT_USE_REASON_S4

                , DO_NOT_USE_REASON_S5

                , DO_NOT_USE_REASON_S6

                , CREATED_BY

                , CREATION_DATE

                , LAST_UPDATED_BY

                , LAST_UPDATE_DATE

                , LAST_UPDATE_LOGIN )

          SELECT  :list_id

                , LIST_ENTRY_ID

                , DO_NOT_USE_REASON_S1

                , DO_NOT_USE_REASON_S2

                , DO_NOT_USE_REASON_S3

                , DO_NOT_USE_REASON_S4

                , DO_NOT_USE_REASON_S5

                , DO_NOT_USE_REASON_S6

                , :user_id

                , sysdate

                , :login_id

                , sysdate

                , :login_id

          FROM IEC_VAL_ENTRY_CACHE

          WHERE LIST_ENTRY_ID NOT IN (SELECT LIST_ENTRY_ID FROM IEC_O_VALIDATION_REPORT_DETS WHERE LIST_HEADER_ID = :list_id)

          AND (   DO_NOT_USE_REASON_S1 IS NOT NULL

               OR DO_NOT_USE_REASON_S2 IS NOT NULL

               OR DO_NOT_USE_REASON_S3 IS NOT NULL

               OR DO_NOT_USE_REASON_S4 IS NOT NULL

               OR DO_NOT_USE_REASON_S5 IS NOT NULL

               OR DO_NOT_USE_REASON_S6 IS NOT NULL

              )'

      USING p_list_id, l_user_id, l_login_id, l_login_id, p_list_id;



   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_ValidationReportDetails'

            , 'INSERTING_NEW_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK;

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK;

      RAISE;

   WHEN OTHERS THEN

      ROLLBACK;

      Log( 'Update_ValidationReportDetails'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_ValidationReportDetails;



PROCEDURE Update_CallableZones

   (p_list_id IN NUMBER)

IS

   l_cp_postfix SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();



   TYPE ref_csr_type IS REF CURSOR;

   l_callable_zone_csr ref_csr_type;



   l_tc_tz_pair_id  NUMBER(15);

   l_subset_id      NUMBER(15);

   l_territory_code VARCHAR2(2);

   l_region_id      NUMBER(15);

   l_timezone_id    NUMBER(15);



BEGIN



   -- Update IEC_TC_TZ_PAIRS_CACHE for current contact point (increment record counts)



   FOR subset_rec IN (SELECT   SUBSET_ID              SUBSET_ID

                             , CURR_CP_TERRITORY_CODE TERRITORY_CODE

                             , CURR_CP_REGION_ID      REGION_ID

                             , CURR_CP_TIME_ZONE      TIME_ZONE

                             , COUNT(*)               RECORD_COUNT

                      FROM IEC_VAL_ENTRY_CACHE

                      WHERE DO_NOT_USE_FLAG = 'N'

                      GROUP BY SUBSET_ID

                             , CURR_CP_TERRITORY_CODE

                             , CURR_CP_REGION_ID

                             , CURR_CP_TIME_ZONE)

   LOOP



      l_tc_tz_pair_id := NULL;



      IF subset_rec.REGION_ID IS NULL THEN



            EXECUTE IMMEDIATE

               'UPDATE IEC_TC_TZ_PAIRS_CACHE

                SET RECORD_COUNT = NVL(RECORD_COUNT, 0) + :record_count_incr

                WHERE SUBSET_ID = :subset_id

                AND TERRITORY_CODE = :territory_code

                AND TIMEZONE_ID = :timezone_id

                AND REGION_ID IS NULL

                AND CACHE_ONLY_FLAG <> ''O''

                RETURNING TC_TZ_PAIR_ID INTO :tc_tz_pair_id'

            USING subset_rec.RECORD_COUNT

                , subset_rec.SUBSET_ID

                , subset_rec.TERRITORY_CODE

                , subset_rec.TIME_ZONE

                , OUT l_tc_tz_pair_id;



      ELSE

            EXECUTE IMMEDIATE

               'UPDATE IEC_TC_TZ_PAIRS_CACHE

                SET RECORD_COUNT = NVL(RECORD_COUNT, 0) + :record_count_incr

                WHERE SUBSET_ID = :subset_id

                AND TERRITORY_CODE = :territory_code

                AND TIMEZONE_ID = :timezone_id

                AND REGION_ID = :region_id

                AND CACHE_ONLY_FLAG <> ''O''

                RETURNING TC_TZ_PAIR_ID INTO :tc_tz_pair_id'

            USING subset_rec.RECORD_COUNT

                , subset_rec.SUBSET_ID

                , subset_rec.TERRITORY_CODE

                , subset_rec.TIME_ZONE

                , subset_rec.REGION_ID

                , OUT l_tc_tz_pair_id;



      END IF;



      IF SQL%ROWCOUNT = 0 THEN



         -- Create record and initialize RECORD_COUNT

         EXECUTE IMMEDIATE

            'SELECT IEC_G_MKTG_ITEM_CC_TZS_S.NEXTVAL FROM DUAL'

         INTO l_tc_tz_pair_id;



         EXECUTE IMMEDIATE

            'INSERT INTO IEC_TC_TZ_PAIRS_CACHE

                    ( SUBSET_ID

                    , TERRITORY_CODE

                    , REGION_ID

                    , TIMEZONE_ID

                    , TC_TZ_PAIR_ID

                    , RECORD_COUNT

                    , CACHE_ONLY_FLAG)

             VALUES ( :subset_id

                    , :territory_code

                    , :region_id

                    , :timezone_id

                    , :tc_tz_pair_id

                    , :init_record_count

                    , ''Y'')'

         USING subset_rec.SUBSET_ID

             , subset_rec.TERRITORY_CODE

             , subset_rec.REGION_ID

             , subset_rec.TIME_ZONE

             , l_tc_tz_pair_id

             , subset_rec.RECORD_COUNT;



      END IF;



   END LOOP;



   -- Update IEC_TC_TZ_PAIRS_CACHE for contact points 1 through 6 (do not increment record counts)

   l_cp_postfix.EXTEND(6);

   l_cp_postfix(1) := '_S1';

   l_cp_postfix(2) := '_S2';

   l_cp_postfix(3) := '_S3';

   l_cp_postfix(4) := '_S4';

   l_cp_postfix(5) := '_S5';

   l_cp_postfix(6) := '_S6';



   FOR i IN 1..l_cp_postfix.COUNT LOOP



      OPEN l_callable_zone_csr FOR

         'SELECT DISTINCT SUBSET_ID                               SUBSET_ID

                        , TERRITORY_CODE' || l_cp_postfix(i) || ' TERRITORY_CODE

                        , REGION_ID'      || l_cp_postfix(i) || ' REGION_ID

                        , TIME_ZONE'      || l_cp_postfix(i) || ' TIME_ZONE

          FROM IEC_VAL_ENTRY_CACHE

          WHERE DO_NOT_USE_FLAG = ''N''

          AND VALID_FLAG' || l_cp_postfix(i) || ' = ''Y''';



      LOOP



         l_tc_tz_pair_id := NULL;



         FETCH l_callable_zone_csr INTO l_subset_id, l_territory_code, l_region_id, l_timezone_id;



         EXIT WHEN l_callable_zone_csr%NOTFOUND;



         BEGIN

            IF l_region_id IS NULL THEN



               EXECUTE IMMEDIATE

                  'SELECT TC_TZ_PAIR_ID

                   FROM IEC_TC_TZ_PAIRS_CACHE

                   WHERE SUBSET_ID = :subset_id

                   AND TERRITORY_CODE = :territory_code

                   AND TIMEZONE_ID = :timezone_id

                   AND REGION_ID IS NULL

                   AND CACHE_ONLY_FLAG <> ''O'''

               INTO l_tc_tz_pair_id

               USING l_subset_id

                   , l_territory_code

                   , l_timezone_id;

            ELSE



               EXECUTE IMMEDIATE

                  'SELECT TC_TZ_PAIR_ID

                   FROM IEC_TC_TZ_PAIRS_CACHE

                   WHERE SUBSET_ID = :subset_id

                   AND TERRITORY_CODE = :territory_code

                   AND TIMEZONE_ID = :timezone_id

                   AND REGION_ID = :region_id

                   AND CACHE_ONLY_FLAG <> ''O'''

               INTO l_tc_tz_pair_id

               USING l_subset_id

                   , l_territory_code

                   , l_timezone_id

                   , l_region_id;



            END IF;



         EXCEPTION

            WHEN NO_DATA_FOUND THEN



               -- Create record and initialize RECORD_COUNT to 0

               EXECUTE IMMEDIATE

                  'SELECT IEC_G_MKTG_ITEM_CC_TZS_S.NEXTVAL FROM DUAL'

               INTO l_tc_tz_pair_id;



               EXECUTE IMMEDIATE

                  'INSERT INTO IEC_TC_TZ_PAIRS_CACHE

                          ( SUBSET_ID

                          , TERRITORY_CODE

                          , REGION_ID

                          , TIMEZONE_ID

                          , TC_TZ_PAIR_ID

                          , RECORD_COUNT

                          , CACHE_ONLY_FLAG)

                   VALUES ( :subset_id

                          , :territory_code

                          , :region_id

                          , :timezone_id

                          , :tc_tz_pair_id

                          , :init_record_count

                          , ''Y'')'

               USING l_subset_id

                   , l_territory_code

                   , l_region_id

                   , l_timezone_id

                   , l_tc_tz_pair_id

                   , 0;



            WHEN OTHERS THEN

               RAISE;

         END;



      END LOOP;



      CLOSE l_callable_zone_csr;



   END LOOP;



   -- Update IEC_VAL_ENTRY_CACHE with the MKTG_ITEM_CC_TZ_ID

   EXECUTE IMMEDIATE

      'UPDATE IEC_VAL_ENTRY_CACHE A

       SET A.MKTG_ITEM_CC_TZS_ID_S1 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S1

                                       AND TIMEZONE_ID = A.TIME_ZONE_S1

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S1, -1)

                                       AND A.VALID_FLAG_S1 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.MKTG_ITEM_CC_TZS_ID_S2 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S2

                                       AND TIMEZONE_ID = A.TIME_ZONE_S2

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S2, -1)

                                       AND A.VALID_FLAG_S2 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.MKTG_ITEM_CC_TZS_ID_S3 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S3

                                       AND TIMEZONE_ID = A.TIME_ZONE_S3

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S3, -1)

                                       AND A.VALID_FLAG_S3 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.MKTG_ITEM_CC_TZS_ID_S4 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S4

                                       AND TIMEZONE_ID = A.TIME_ZONE_S4

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S4, -1)

                                       AND A.VALID_FLAG_S4 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.MKTG_ITEM_CC_TZS_ID_S5 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S5

                                       AND TIMEZONE_ID = A.TIME_ZONE_S5

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S5, -1)

                                       AND A.VALID_FLAG_S5 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.MKTG_ITEM_CC_TZS_ID_S6 = (SELECT TC_TZ_PAIR_ID

                                       FROM IEC_TC_TZ_PAIRS_CACHE

                                       WHERE SUBSET_ID = A.SUBSET_ID

                                       AND TERRITORY_CODE = A.TERRITORY_CODE_S6

                                       AND TIMEZONE_ID = A.TIME_ZONE_S6

                                       AND NVL(REGION_ID, -1) = NVL(A.REGION_ID_S6, -1)

                                       AND A.VALID_FLAG_S6 = ''Y''

                                       AND CACHE_ONLY_FLAG <> ''O'')

         , A.CURR_CP_MKTG_ITEM_CC_TZS_ID = (SELECT TC_TZ_PAIR_ID

                                            FROM IEC_TC_TZ_PAIRS_CACHE

                                            WHERE SUBSET_ID = A.SUBSET_ID

                                            AND TERRITORY_CODE = A.CURR_CP_TERRITORY_CODE

                                            AND TIMEZONE_ID = A.CURR_CP_TIME_ZONE

                                            AND NVL(REGION_ID, -1) = NVL(A.CURR_CP_REGION_ID, -1)

                                            AND CACHE_ONLY_FLAG <> ''O'')

      WHERE A.DO_NOT_USE_FLAG = ''N''';



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Update_CallableZones'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_CallableZones;



PROCEDURE Incr_RecordsLoadedCounts

   ( p_schedule_id              IN NUMBER

   , p_list_id                  IN NUMBER

   , p_subset_id_col            IN SYSTEM.number_tbl_type

   , p_incr_amount_col          IN SYSTEM.number_tbl_type

   )

IS

BEGIN



   IF p_subset_id_col.COUNT > 0 THEN

      FORALL i IN p_subset_id_col.FIRST..p_subset_id_col.LAST

         UPDATE IEC_G_REP_SUBSET_COUNTS

         SET RECORD_LOADED = NVL(RECORD_LOADED, 0) + p_incr_amount_col(i)

         WHERE SCHEDULE_ID = p_schedule_id

         AND LIST_HEADER_ID = p_list_id

         AND SUBSET_ID = p_subset_id_col(i);

   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Incr_RecordsLoadedCounts'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Incr_RecordsLoadedCounts;



PROCEDURE Incr_CallableZoneCounts

   ( p_callable_zone_id_col IN SYSTEM.number_tbl_type

   , p_incr_amount_col      IN SYSTEM.number_tbl_type

   )

IS

BEGIN



   IF p_callable_zone_id_col.COUNT > 0 THEN

      FORALL i IN p_callable_zone_id_col.FIRST..p_callable_zone_id_col.LAST

         UPDATE IEC_G_MKTG_ITEM_CC_TZS

         SET RECORD_COUNT = NVL(RECORD_COUNT, 0) + p_incr_amount_col(i)

         WHERE ITM_CC_TZ_ID = p_callable_zone_id_col(i);

   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Incr_CallableZoneCounts'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Incr_CallableZoneCounts;



PROCEDURE Incr_CallableZoneCounts_Cache

   ( p_callable_zone_id_col IN SYSTEM.number_tbl_type

   , p_incr_amount_col      IN SYSTEM.number_tbl_type

   )

IS

BEGIN



   IF p_callable_zone_id_col.COUNT > 0 THEN

      FORALL i IN p_callable_zone_id_col.FIRST..p_callable_zone_id_col.LAST

         UPDATE IEC_TC_TZ_PAIRS_CACHE

         SET RECORD_COUNT = NVL(RECORD_COUNT, 0) + p_incr_amount_col(i)

         WHERE TC_TZ_PAIR_ID = p_callable_zone_id_col(i);

   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Incr_CallableZoneCounts_Cache'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Incr_CallableZoneCounts_Cache;



PROCEDURE Load_CallableZones

   (p_list_id IN NUMBER)

IS

BEGIN



   -- LOAD IEC_G_MKTG_ITEM_CC_TZS RECORDS FOR CURRENT LIST INTO CACHE

   EXECUTE IMMEDIATE

         'INSERT INTO IEC_TC_TZ_PAIRS_CACHE (SUBSET_ID, TERRITORY_CODE, REGION_ID, TIMEZONE_ID, TC_TZ_PAIR_ID, RECORD_COUNT, CACHE_ONLY_FLAG)

          SELECT SUBSET_ID, TERRITORY_CODE, REGION_ID, TIMEZONE_ID, ITM_CC_TZ_ID, 0, ''N''

          FROM IEC_G_MKTG_ITEM_CC_TZS

          WHERE LIST_HEADER_ID = :list_id'

   USING p_list_id;



END Load_CallableZones;



PROCEDURE Get_CallableZoneDetail

   ( p_cc_tz_id       IN            NUMBER

   , x_territory_code    OUT NOCOPY VARCHAR2   -- OUT

   , x_region_id         OUT NOCOPY NUMBER     -- OUT

   , x_time_zone_id      OUT NOCOPY NUMBER     -- OUT

   , x_valid_flag        OUT NOCOPY VARCHAR2)  -- OUT

IS

   l_territory_code VARCHAR2(2);

   l_region_id NUMBER;

   l_time_zone_id NUMBER;

   l_valid_flag VARCHAR2(1);

BEGIN



   IF p_cc_tz_id IS NOT NULL THEN

      EXECUTE IMMEDIATE

         'SELECT TERRITORY_CODE, REGION_ID, TIMEZONE_ID

          FROM IEC_G_MKTG_ITEM_CC_TZS

          WHERE ITM_CC_TZ_ID = :cc_tz_id'

      INTO l_territory_code, l_region_id, l_time_zone_id

      USING p_cc_tz_id;

      l_valid_flag := 'Y';

   ELSE

      l_territory_code := NULL;

      l_region_id := NULL;

      l_time_zone_id := NULL;

      l_valid_flag := 'N';

   END IF;



   x_territory_code := l_territory_code;

   x_region_id := l_region_id;

   x_time_zone_id := l_time_zone_id;

   x_valid_flag := l_valid_flag;



EXCEPTION

   WHEN NO_DATA_FOUND THEN

      x_territory_code := NULL;

      x_region_id := NULL;

      x_time_zone_id := NULL;

      x_valid_flag := 'N';

   WHEN OTHERS THEN

      Log( 'Get_CallableZoneDetail'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Get_CallableZoneDetail;



PROCEDURE Get_CallableZoneDetail_Cache

   ( p_cc_tz_id       IN            NUMBER

   , x_territory_code    OUT NOCOPY VARCHAR2   -- OUT

   , x_region_id         OUT NOCOPY NUMBER     -- OUT

   , x_time_zone_id      OUT NOCOPY NUMBER     -- OUT

   , x_valid_flag        OUT NOCOPY VARCHAR2)  -- OUT

IS

   l_territory_code VARCHAR2(2);

   l_region_id NUMBER;

   l_time_zone_id NUMBER;

   l_valid_flag VARCHAR2(1);

BEGIN



   IF p_cc_tz_id IS NOT NULL THEN



      EXECUTE IMMEDIATE

         'SELECT TERRITORY_CODE, REGION_ID, TIMEZONE_ID

          FROM IEC_TC_TZ_PAIRS_CACHE

          WHERE TC_TZ_PAIR_ID = :cc_tz_id'

      INTO l_territory_code, l_region_id, l_time_zone_id

      USING p_cc_tz_id;

      l_valid_flag := 'Y';

   ELSE

      l_territory_code := NULL;

      l_region_id := NULL;

      l_time_zone_id := NULL;

      l_valid_flag := 'N';

   END IF;



   x_territory_code := l_territory_code;

   x_region_id := l_region_id;

   x_time_zone_id := l_time_zone_id;

   x_valid_flag := l_valid_flag;



EXCEPTION

   WHEN NO_DATA_FOUND THEN

      x_territory_code := NULL;

      x_region_id := NULL;

      x_time_zone_id := NULL;

      x_valid_flag := 'N';

   WHEN OTHERS THEN

      Log( 'Get_CallableZoneDetail_Cache'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Get_CallableZoneDetail_Cache;



PROCEDURE Delete_CallableZones

   (p_list_id IN NUMBER)

IS

BEGIN



   EXECUTE IMMEDIATE

         'DELETE IEC_G_MKTG_ITEM_CC_TZS

          WHERE LIST_HEADER_ID = :list_id'

   USING p_list_id;



END Delete_CallableZones;



PROCEDURE Purge_CallableZones

   ( p_list_id              IN NUMBER

   , p_campaign_schedule_id IN NUMBER)

IS

   l_subset_id_col      SYSTEM.number_tbl_type;

   l_territory_code_col SYSTEM.varchar_tbl_type;

   l_region_col         SYSTEM.varchar_tbl_type;

   l_timezone_col       SYSTEM.number_tbl_type;

   l_tc_tz_pair_id_col  SYSTEM.number_tbl_type;

   l_record_count_col   SYSTEM.number_tbl_type;



BEGIN



   -- Create new tc/tz pairs in IEC_G_MKTG_ITEM_CC_TZS for those tc/tz pairs only existing in cache

   SELECT SUBSET_ID, TERRITORY_CODE, REGION_ID, TIMEZONE_ID, TC_TZ_PAIR_ID, RECORD_COUNT

   BULK COLLECT INTO l_subset_id_col, l_territory_code_col, l_region_col, l_timezone_col, l_tc_tz_pair_id_col, l_record_count_col

   FROM IEC_TC_TZ_PAIRS_CACHE

   WHERE CACHE_ONLY_FLAG = 'Y';



   IF l_territory_code_col IS NOT NULL AND l_territory_code_col.COUNT > 0 THEN



      FORALL I IN l_territory_code_col.FIRST..l_territory_code_col.LAST

         INSERT INTO IEC_G_MKTG_ITEM_CC_TZS ( ITM_CC_TZ_ID

                                            , SUBSET_ID

                                            , LIST_HEADER_ID

                                            , CAMPAIGN_SCHEDULE_ID

                                            , TERRITORY_CODE

                                            , REGION_ID

                                            , TIMEZONE_ID

                                            , LAST_CALLABLE_TIME

                                            , CALLABLE_FLAG

                                            , RECORD_COUNT

                                            , OBJECT_VERSION_NUMBER

                                            , LAST_UPDATE_DATE)

                                     VALUES ( l_tc_tz_pair_id_col(I)

                                            , l_subset_id_col(I)

                                            , p_list_id

                                            , p_campaign_schedule_id

                                            , l_territory_code_col(I)

                                            , l_region_col(I)

                                            , l_timezone_col(I)

                                            , NULL

                                            , NULL

                                            , l_record_count_col(I)

                                            , 1

                                            , SYSDATE);

   END IF;



   -- Only update the RECORD_COUNT column for those tc/tz pairs that already exist in the db (outside of cache)

   SELECT TC_TZ_PAIR_ID, RECORD_COUNT

   BULK COLLECT INTO l_tc_tz_pair_id_col, l_record_count_col

   FROM IEC_TC_TZ_PAIRS_CACHE

   WHERE CACHE_ONLY_FLAG = 'N';



   IF l_tc_tz_pair_id_col IS NOT NULL AND l_tc_tz_pair_id_col.COUNT > 0 THEN



      FORALL I IN l_tc_tz_pair_id_col.FIRST..l_tc_tz_pair_id_col.LAST

         UPDATE IEC_G_MKTG_ITEM_CC_TZS

         SET RECORD_COUNT = RECORD_COUNT + l_record_count_col(I)

           , LAST_UPDATE_DATE = SYSDATE

         WHERE ITM_CC_TZ_ID = l_tc_tz_pair_id_col(I);

   END IF;



   -- Update these records to reflect the fact that they now exist outside of the cache

   UPDATE IEC_TC_TZ_PAIRS_CACHE

   SET CACHE_ONLY_FLAG = 'N'

   WHERE CACHE_ONLY_FLAG = 'Y';



   -- Clear record counts in cache to start fresh for next batch

   UPDATE IEC_TC_TZ_PAIRS_CACHE

   SET RECORD_COUNT = 0;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Purge_CallableZones'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Purge_CallableZones;



PROCEDURE Update_IecReturnEntries

   ( p_list_id              IN NUMBER

   , p_campaign_schedule_id IN NUMBER

   , p_campaign_id          IN NUMBER

   , p_source_type_view     IN VARCHAR2)

IS

   l_user_id NUMBER;

   l_login_id NUMBER;

BEGIN

   l_user_id := nvl(FND_GLOBAL.user_id, -1);

   l_login_id := nvl(FND_GLOBAL.conc_login_id, -1);



   BEGIN

      EXECUTE IMMEDIATE

         'UPDATE IEC_G_RETURN_ENTRIES A

          SET ( A.SUBSET_ID

              , A.DO_NOT_USE_FLAG

              , A.DO_NOT_USE_REASON

              , A.CONTACT_POINT_ID

              , A.CONTACT_POINT_INDEX

              , A.COUNTRY_CODE

              , A.AREA_CODE

              , A.PHONE_NUMBER

              , A.RAW_PHONE_NUMBER

              , A.TIME_ZONE

              , A.ITM_CC_TZ_ID

			  , A.PHONE_LINE_TYPE

			  , A.CONTACT_POINT_PURPOSE )

             =

              ( SELECT B.SUBSET_ID

              , B.DO_NOT_USE_FLAG

              , B.DO_NOT_USE_REASON

              , B.CURR_CP_ID

              , B.CURR_CP_INDEX

              , B.CURR_CP_COUNTRY_CODE

              , B.CURR_CP_AREA_CODE

              , B.CURR_CP_PHONE_NUMBER

              , B.CURR_CP_RAW_PHONE_NUMBER

              , B.CURR_CP_TIME_ZONE

              , B.CURR_CP_MKTG_ITEM_CC_TZS_ID

              , B.CURR_CP_PHONE_LINE_TYPE

              , B.CURR_CP_CONTACT_POINT_PURPOSE

              FROM IEC_VAL_ENTRY_CACHE B

              WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID)

           , LAST_UPDATED_BY = :login_id

           , LAST_UPDATE_DATE = SYSDATE

           , LAST_UPDATE_LOGIN = :login_id

           WHERE A.LIST_HEADER_ID = :list_id

           AND A.LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE)'

      USING l_login_id, l_login_id, p_list_id;



   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_IecReturnEntries'

            , 'UPDATE_EXISTING_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   BEGIN

      EXECUTE IMMEDIATE

         'DELETE IEC_G_RETURN_ENTRIES A

          WHERE A.LIST_HEADER_ID = :list_id

          AND A.LIST_ENTRY_ID IN

              ( SELECT LIST_ENTRY_ID

                FROM IEC_VAL_ENTRY_CACHE

                WHERE DO_NOT_USE_FLAG = ''Y''

                AND DO_NOT_USE_REASON = ''4'')'

      USING p_list_id;



   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_IecReturnEntries'

            , 'DELETE_INVALIDATED_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   BEGIN

      EXECUTE IMMEDIATE

         'INSERT INTO IEC_G_RETURN_ENTRIES

                ( RETURNS_ID

                , CAMPAIGN_ID

                , CAMPAIGN_SCHEDULE_ID

                , LIST_VIEW_NAME

                , LIST_HEADER_ID

                , LIST_ENTRY_ID

                , SUBSET_ID

                , OUTCOME_ID

                , RESULT_ID

                , REASON_ID

                , DELIVER_IH_FLAG

                , RECYCLE_FLAG

                , DO_NOT_USE_FLAG

                , CALLBACK_FLAG

                , RECORD_OUT_FLAG

                , RECORD_RELEASE_TIME

                , CONTACT_POINT_ID

                , CONTACT_POINT_INDEX

                , COUNTRY_CODE

                , AREA_CODE

                , PHONE_NUMBER

                , RAW_PHONE_NUMBER

                , TIME_ZONE

                , PHONE_LINE_TYPE

                , CONTACT_POINT_PURPOSE

                , ITM_CC_TZ_ID

                , CREATED_BY

                , CREATION_DATE

                , LAST_UPDATED_BY

                , LAST_UPDATE_DATE

                , LAST_UPDATE_LOGIN )

          SELECT  IEC_G_RETURN_ENTRIES_S.NEXTVAL

                , :campaign_id

                , :campaign_schedule_id

                , :source_type_view

                , :list_id

                , LIST_ENTRY_ID

                , SUBSET_ID

                , -1

                , -1

                , -1

                , ''N''

                , ''N''

                , ''N''

                , ''N''

                , ''N''

                , SYSDATE

                , CURR_CP_ID

                , CURR_CP_INDEX

                , CURR_CP_COUNTRY_CODE

                , CURR_CP_AREA_CODE

                , CURR_CP_PHONE_NUMBER

                , CURR_CP_RAW_PHONE_NUMBER

                , CURR_CP_TIME_ZONE

                , CURR_CP_PHONE_LINE_TYPE

                , CURR_CP_CONTACT_POINT_PURPOSE

                , CURR_CP_MKTG_ITEM_CC_TZS_ID

                , :user_id

                , sysdate

                , :login_id

                , sysdate

                , :login_id

          FROM IEC_VAL_ENTRY_CACHE

          WHERE DO_NOT_USE_FLAG = ''N''

          AND LIST_ENTRY_ID NOT IN (SELECT LIST_ENTRY_ID FROM IEC_G_RETURN_ENTRIES WHERE LIST_HEADER_ID = :list_id)'

      USING p_campaign_id, p_campaign_schedule_id, p_source_type_view, p_list_id, l_user_id, l_login_id, l_login_id, p_list_id;



   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Update_IecReturnEntries'

            , 'INSERTING_NEW_ENTRIES'

            , SQLERRM

            );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Update_IecReturnEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_IecReturnEntries;



PROCEDURE Init_SubsetRtInfo

   ( p_list_id          IN            NUMBER

   , p_source_type_view IN            VARCHAR2

   , x_subset_id_col       OUT NOCOPY SYSTEM.number_tbl_type    -- OUT

   , x_subset_view_col     OUT NOCOPY SYSTEM.varchar_tbl_type)  -- OUT

IS

   l_subset_id   NUMBER(15);

   l_return_code VARCHAR2(1);

   l_validated_once VARCHAR2(1);

BEGIN



   x_subset_id_col := SYSTEM.number_tbl_type();

   x_subset_view_col := SYSTEM.varchar_tbl_type();



   BEGIN

      EXECUTE IMMEDIATE

         'SELECT VALIDATED_ONCE_FLAG

          FROM IEC_O_VALIDATION_STATUS

       WHERE LIST_HEADER_ID = :list_id'

      INTO  l_validated_once

      USING p_list_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         l_validated_once := 'N';

      WHEN OTHERS THEN

         RAISE;

   END;



   IF l_validated_once = 'Y' THEN



      -- Loop through each subset (in order of priority, default subset assumed to have lowest load priority)

      FOR subset_rec IN (SELECT   A.LIST_SUBSET_ID

                        ,         A.LOAD_PRIORITY

                        ,         NVL(B.DEFAULT_SUBSET_FLAG, 'N') SUBSET_FLAG

                        FROM      IEC_G_SUBSET_RT_INFO A, IEC_G_LIST_SUBSETS B

                        WHERE     A.LIST_SUBSET_ID = B.LIST_SUBSET_ID

                        AND       B.LIST_HEADER_ID = p_list_id

                        AND       A.STATUS_CODE <> 'DELETED'

                        ORDER BY  NVL(B.DEFAULT_SUBSET_FLAG, 'N') ASC, A.LOAD_PRIORITY)

      LOOP

         l_subset_id := subset_rec.LIST_SUBSET_ID;



         x_subset_id_col.EXTEND(1);

         x_subset_view_col.EXTEND(1);



         x_subset_id_col(x_subset_id_col.LAST) := l_subset_id;



         -- Retrieve Subset View (Created if necessary, but should already exist)

         x_subset_view_col(x_subset_view_col.LAST) := IEC_SUBSET_PVT.GET_SUBSET_VIEW

                                                      ( 0

                                                      , p_list_id

                                                      , subset_rec.LIST_SUBSET_ID

                                                      , subset_rec.SUBSET_FLAG

                                                      , p_source_type_view

                                                      , l_return_code);



         IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN

            Log_GetSubsetViewError('Init_SubsetRtInfo', 'GET_SUBSET_VIEW', Get_SubsetName(l_subset_id), Get_ListName(p_list_id));

            RAISE fnd_api.g_exc_unexpected_error;

         END IF;



      END LOOP;



   ELSE



      -- Loop through each subset (in order of priority, default subset assumed to have lowest load priority)

      FOR subset_rec IN (SELECT   LIST_SUBSET_ID

                        ,         LOAD_PRIORITY

                        ,         NVL(DEFAULT_SUBSET_FLAG, 'N') SUBSET_FLAG

                        FROM      IEC_G_LIST_SUBSETS

                        WHERE     LIST_HEADER_ID = p_list_id

                        AND       STATUS_CODE <> 'DELETED'

                        ORDER BY  NVL(DEFAULT_SUBSET_FLAG, 'N') ASC, LOAD_PRIORITY)

      LOOP

         l_subset_id := subset_rec.LIST_SUBSET_ID;



         x_subset_id_col.EXTEND(1);

         x_subset_view_col.EXTEND(1);



         x_subset_id_col(x_subset_id_col.LAST) := l_subset_id;



         -- Retrieve Subset View (Created if necessary)

         x_subset_view_col(x_subset_view_col.LAST) := IEC_SUBSET_PVT.GET_SUBSET_VIEW

                                                      ( 0

                                                      , p_list_id

                                                      , subset_rec.LIST_SUBSET_ID

                                                      , subset_rec.SUBSET_FLAG

                                                      , p_source_type_view

                                                      , l_return_code);



         IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN

            Log_GetSubsetViewError('Init_SubsetRtInfo', 'GET_SUBSET_VIEW', Get_SubsetName(l_subset_id), Get_ListName(p_list_id));

            Log('Init_SubsetRtInfo', 'GET_SUBSET_VIEW');

            RAISE fnd_api.g_exc_unexpected_error;

         END IF;



         IEC_SUBSET_PVT.CREATE_SUBSET_RT_INFO(l_subset_id);



      END LOOP;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Init_SubsetRtInfo'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Init_SubsetRtInfo;



PROCEDURE Partition_SubsetEntries

   ( p_list_id               IN            NUMBER

   , p_subset_id_col         IN            SYSTEM.number_tbl_type

   , p_subset_view_col       IN            SYSTEM.varchar_tbl_type

   , x_subset_rec_loaded_col    OUT NOCOPY SYSTEM.number_tbl_type)   -- OUT

IS

BEGIN



   x_subset_rec_loaded_col := SYSTEM.number_tbl_type();



   IF p_subset_id_col IS NOT NULL AND p_subset_id_col.COUNT > 1 THEN



      -- Loop through each subset (in order of priority, excluding default subset)

      FOR i IN 1..(p_subset_id_col.COUNT - 1) LOOP



         IF p_subset_view_col(i) IS NOT NULL THEN

            EXECUTE IMMEDIATE

               'UPDATE IEC_VAL_ENTRY_CACHE

                SET SUBSET_ID = :subset_id

                WHERE SUBSET_ID IS NULL

                AND DO_NOT_USE_FLAG = ''N''

                AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM ' || p_subset_view_col(i) || ')'

            USING p_subset_id_col(i);



            x_subset_rec_loaded_col.EXTEND(1);

            x_subset_rec_loaded_col(i) := SQL%ROWCOUNT;



         ELSE

            Log_SubsetViewDoesNotExist('Partition_SubsetEntries', 'ASSIGN_ENTRIES_TO_SUBSET', Get_SubsetName(p_subset_id_col(i)), Get_ListName(p_list_id));

            RAISE fnd_api.g_exc_unexpected_error;

         END IF;



      END LOOP;



      -- Assign all remaining entries to default subset

      EXECUTE IMMEDIATE

         'UPDATE IEC_VAL_ENTRY_CACHE

          SET SUBSET_ID = :subset_id

          WHERE SUBSET_ID IS NULL

          AND DO_NOT_USE_FLAG = ''N'''

      USING p_subset_id_col(p_subset_id_col.LAST);



      x_subset_rec_loaded_col.EXTEND(1);

      x_subset_rec_loaded_col(x_subset_rec_loaded_col.LAST) := SQL%ROWCOUNT;



   ELSIF p_subset_id_col IS NOT NULL AND p_subset_id_col.COUNT = 1 THEN



      -- No user-defined subsets exist, assign all entries to default subset

      EXECUTE IMMEDIATE

         'UPDATE IEC_VAL_ENTRY_CACHE

          SET SUBSET_ID = :subset_id

          WHERE SUBSET_ID IS NULL

          AND DO_NOT_USE_FLAG = ''N'''

      USING p_subset_id_col(p_subset_id_col.LAST);



      x_subset_rec_loaded_col.EXTEND(1);

      x_subset_rec_loaded_col(x_subset_rec_loaded_col.LAST) := SQL%ROWCOUNT;



   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Partition_SubsetEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Partition_SubsetEntries;



FUNCTION Parse_Country_Code

   (x_phone_number IN OUT NOCOPY VARCHAR2) -- IN OUT

RETURN VARCHAR2

IS

   l_country_code         VARCHAR2(9);

   l_country_code_col     SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();

   l_cc_substr            VARCHAR2(500);



BEGIN



   x_phone_number := TRANSLATE( UPPER(x_phone_number)

                              , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                              , '0123456789');



   IF x_phone_number IS NOT NULL AND g_enable_cc_incr_parse THEN



      IF g_cc_cc_lookup_tbl IS NOT NULL THEN

         FOR I IN 1..LENGTH(x_phone_number) LOOP

            l_cc_substr := SUBSTR(x_phone_number, 1, I);

            FOR J IN g_cc_cc_lookup_tbl.FIRST..g_cc_cc_lookup_tbl.LAST LOOP

               IF g_cc_cc_lookup_tbl.EXISTS(J) AND l_cc_substr = g_cc_cc_lookup_tbl(J) THEN

                  l_country_code := g_cc_cc_lookup_tbl(J);

                  GOTO Done;

               END IF;

            END LOOP;

         END LOOP;

      END IF;

   END IF;



<<Done>>

   IF l_country_code IS NOT NULL THEN

      x_phone_number := SUBSTR(x_phone_number, LENGTH(l_country_code) + 1);

   END IF;

   RETURN l_country_code;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Parse_Country_Code'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Parse_Country_Code;



PROCEDURE Parse_Area_Code

   ( x_phone_number       IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_country_code       IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_territory_code     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_area_code             OUT NOCOPY VARCHAR2   -- OUT

   , x_area_code_req_flag    OUT NOCOPY BOOLEAN)   -- OUT

IS

   l_area_code          VARCHAR2(9);

   l_area_code_size     NUMBER(9);

   l_area_code_col      SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();

   l_ac_substr          VARCHAR2(500);

BEGIN



   -- Assume that a 0 length area code is invalid, until we find a phone format

   -- specifying an area code length of 0

   x_area_code_req_flag := TRUE;



   x_phone_number := TRANSLATE( x_phone_number

                              , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                              , '0123456789');



   -- Attempt to parse area code

   -- Use phone format defined for country code

   -- Look for fixed length area code size

   IF x_country_code IS NOT NULL AND g_ac_length_tbl.EXISTS(x_country_code)

   THEN

      l_area_code_size := g_ac_length_tbl(x_country_code);

      IF l_area_code_size IS NOT NULL THEN

         GOTO Done;  -- Found area code size, finish up

      END IF;

   END IF;



   -- Attempt to parse area code

   -- Using phone format defined for territory code

   -- Look for matching variable length area code size

   IF l_area_code IS NULL AND x_territory_code IS NOT NULL THEN



      BEGIN

         EXECUTE IMMEDIATE

            'SELECT DISTINCT AREA_CODE_SIZE

             FROM HZ_PHONE_FORMATS

             WHERE TERRITORY_CODE = :territory_code

             AND LENGTH(TRIM(TRANSLATE( UPPER(PHONE_FORMAT_STYLE)

                                      , ''9012345678ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., ''

                                      , ''9''

                                      ))) = LENGTH(:phone_number)

             AND ROWNUM = 1'

         INTO l_area_code_size

         USING x_territory_code, x_phone_number;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            NULL;

         WHEN OTHERS THEN

            Log( 'Parse_Area_Code'

               , 'GET_VARIABLE_AREA_CODE_LENGTH_TC'

               , SQLERRM

               );

            RAISE fnd_api.g_exc_unexpected_error;

      END;



      IF l_area_code_size IS NOT NULL THEN

         GOTO Done;  -- Found area code size, finish up

      END IF;



   END IF;



   -- Attempt to parse area code

   -- Use phone format defined for country code

   -- Look for matching variable length area code size

   IF l_area_code IS NULL AND x_country_code IS NOT NULL

   THEN

     -- Get area code size for phone country code (area code not fixed length)

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT DISTINCT A.AREA_CODE_SIZE

             FROM HZ_PHONE_FORMATS A, HZ_PHONE_COUNTRY_CODES B

             WHERE A.TERRITORY_CODE = B.TERRITORY_CODE AND B.PHONE_COUNTRY_CODE = :country_code

             AND LENGTH(TRIM(TRANSLATE( UPPER(PHONE_FORMAT_STYLE)

                                      , ''9012345678ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., ''

                                      , ''9''))) = LENGTH(:phone_number)

             AND ROWNUM = 1'

         INTO l_area_code_size

         USING x_country_code, x_phone_number;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            NULL;

         WHEN OTHERS THEN

            Log( 'Parse_Area_Code'

               , 'GET_VARIABLE_AREA_CODE_LENGTH_CC'

               , SQLERRM

               );

            RAISE fnd_api.g_exc_unexpected_error;

      END;



      IF l_area_code_size IS NOT NULL THEN

         GOTO Done;  -- Found area code size, finish up

      END IF;



   END IF;



   -- Attempt incremental parsing of area code

   IF  l_area_code IS NULL

   AND x_country_code IS NOT NULL

   AND g_enable_ac_incr_parse

   THEN

      l_area_code_size := NULL;  -- Size not relevant to incremental parsing



      BEGIN

         EXECUTE IMMEDIATE

            'BEGIN

             SELECT DISTINCT AREA_CODE BULK COLLECT INTO :area_code_col

             FROM HZ_PHONE_AREA_CODES

             WHERE PHONE_COUNTRY_CODE = :country_code

             AND AREA_CODE LIKE CONCAT(SUBSTR(:phone_number, 1, 1), ''%'')

             ORDER BY AREA_CODE;

             END;'

         USING OUT l_area_code_col, IN x_country_code, IN x_phone_number;



         IF l_area_code_col IS NOT NULL AND l_area_code_col.COUNT > 0 THEN

            FOR I IN 1..LENGTH(x_phone_number) LOOP

               l_ac_substr := SUBSTR(x_phone_number, 1, I);

               FOR J IN 1..l_area_code_col.LAST LOOP

                  IF l_ac_substr = l_area_code_col(J) THEN

                     l_area_code := l_area_code_col(J);

                     GOTO DONE;

                  END IF;

               END LOOP;

            END LOOP;

         END IF;

      EXCEPTION

         WHEN OTHERS THEN

            Log( 'Parse_Area_Code'

               , 'PARSE_AREA_CODE_INCR'

               , SQLERRM

               );

            RAISE fnd_api.g_exc_unexpected_error;

      END;

   END IF;



<<Done>>



   -- Only use size to parse area code if not already parsed incrementally

   IF l_area_code_size IS NOT NULL THEN



      IF l_area_code_size = 0 THEN

         x_area_code_req_flag := FALSE;

      END IF;



      l_area_code := SUBSTR(x_phone_number, 1, l_area_code_size);

   END IF;



   IF l_area_code IS NOT NULL THEN

      x_phone_number := SUBSTR(x_phone_number, LENGTH(l_area_code) + 1);

   END IF;



   x_area_code := l_area_code;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Parse_Area_Code'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Parse_Area_Code;



FUNCTION Create_Canonical_Number ( p_country_code IN VARCHAR2

                                 , p_area_code    IN VARCHAR2

                                 , p_phone_number IN VARCHAR2)

RETURN VARCHAR2

IS

BEGIN



   RETURN '+' || p_country_code || ' (' || p_area_code || ') ' || p_phone_number;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Create_Canonical_Number'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Create_Canonical_Number;



PROCEDURE Get_Territory_Code ( p_country_code   IN            VARCHAR2

                             , p_area_code      IN            VARCHAR2

                             , x_territory_code    OUT NOCOPY VARCHAR2   -- OUT

                             , x_region            OUT NOCOPY VARCHAR2)  -- OUT

IS

BEGIN



   IF x_territory_code IS NULL AND g_territory_code IS NOT NULL THEN

      x_territory_code := g_territory_code;

   ELSIF x_territory_code IS NULL AND p_country_code IS NOT NULL THEN



      -- Look for territory with dedicated phone country code

      IF g_cc_tc_lookup_tbl.EXISTS(p_country_code) THEN

         x_territory_code := g_cc_tc_lookup_tbl(p_country_code);

      END IF;



      -- Look for territory using both the phone country code and area code

      -- Applies to territories that do not have a dedicated phone country code

      IF x_territory_code IS NULL AND p_country_code IS NOT NULL AND p_area_code IS NOT NULL THEN

         IF g_cc_ac_tc_lookup_tbl.EXISTS(p_country_code || p_area_code) THEN

            x_territory_code := g_cc_ac_tc_lookup_tbl(p_country_code || p_area_code);

         END IF;

      END IF;



   END IF;



   -- Derive region

   IF g_region_id IS NOT NULL THEN

      x_region := g_region_id;

   ELSIF x_territory_code IS NOT NULL AND p_area_code IS NOT NULL THEN

      -- determine corresponding region code

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT REGION_ID

             FROM IEC_G_REGION_MAPPINGS

             WHERE TERRITORY_CODE = :territory_code AND PHONE_AREA_CODE = :area_code'

         INTO x_region

         USING x_territory_code, p_area_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            NULL;

         WHEN OTHERS THEN

            Log( 'GET_TERRITORY_CODE'

               , 'GET_REGION_MAPPING'

               , SQLERRM

               );

            RAISE fnd_api.g_exc_unexpected_error;

      END;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Get_Territory_Code'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Get_Territory_Code;



FUNCTION Get_Timezone_Id ( p_territory_code IN            VARCHAR2

                         , p_area_code      IN            VARCHAR2

                         , p_postal_code    IN            VARCHAR2

                         , p_timezone       IN            VARCHAR2

                         , x_dnu_reason        OUT NOCOPY NUMBER)   -- OUT



RETURN NUMBER

IS

   l_timezone_id    NUMBER(15);

   l_timezone       VARCHAR2(500);

   l_timezone_clean VARCHAR2(500);

   l_alt_timezone   VARCHAR2(500);

   l_count          NUMBER(9);

   l_index          PLS_INTEGER;

BEGIN



   IF g_timezone_id IS NOT NULL THEN

      l_timezone_id := g_timezone_ID;

   END IF;



   IF l_timezone_id IS NULL AND (p_timezone IS NULL OR g_enable_tz_map_ovrd) THEN

      BEGIN

         EXECUTE IMMEDIATE

            'SELECT DISTINCT TIMEZONE_ID

             FROM IEC_TZ_MAPPING_CACHE

             WHERE TERRITORY_CODE = :territory_code

             AND (AREA_CODE = :area_code OR AREA_CODE IS NULL)'

         INTO l_timezone_id

         USING p_territory_code, p_area_code;

      EXCEPTION

         WHEN TOO_MANY_ROWS THEN

            NULL;

         WHEN NO_DATA_FOUND THEN

            NULL;

         WHEN OTHERS THEN

            Log( 'Get_Timezone_Id'

               , 'MAP_TC_AC_WITH_TIMEZONE'

               , SQLERRM

               );

            RAISE fnd_api.g_exc_unexpected_error;

      END;



      IF l_timezone_id IS NULL AND g_enable_zc_lookups THEN

         BEGIN

            EXECUTE IMMEDIATE

               'SELECT DISTINCT TIMEZONE_ID

                FROM IEC_TZ_MAPPING_CACHE

                WHERE TERRITORY_CODE = :territory_code

                AND AREA_CODE = :area_code

                AND POSTAL_CODE = :postal_code'

            INTO l_timezone_id

            USING p_territory_code, p_area_code, p_postal_code;

         EXCEPTION

            WHEN TOO_MANY_ROWS THEN

               NULL;

            WHEN NO_DATA_FOUND THEN

               NULL;

            WHEN OTHERS THEN

               Log( 'Get_Timezone_Id'

                  , 'MAP_TC_AC_PC_WITH_TIMEZONE'

                  , SQLERRM

                  );

               RAISE fnd_api.g_exc_unexpected_error;

         END;

      END IF;

   END IF;



   -- Try to interpret time zone data provided as id, gmt offset, or descriptive name

   IF l_timezone_id IS NULL AND p_timezone IS NOT NULL THEN



      l_timezone := UPPER(TRIM(p_timezone));



      l_timezone_clean := TRANSLATE( l_timezone

                                   , '0123456789+-ABCDEFGHIJKLMNOPQRSTUVWXYZ/=()*&^%$#@!~`[]{}|\:;?><., '

                                   , '0123456789+-');



      -- Time zone is provided in numeric format (gmt offset, id)

      IF l_timezone_clean = l_timezone THEN



         -- Time zone is specified as an offset

         IF SUBSTR(l_timezone, 1, 1) = '+' OR SUBSTR(l_timezone, 1, 1) = '-' THEN



            BEGIN

               EXECUTE IMMEDIATE

                  'SELECT TIMEZONE_ID

                   FROM IEC_TZ_OFFSET_MAP_CACHE

                   WHERE OFFSET = :timezone

                   AND ROWNUM = 1'

               INTO l_timezone_id

               USING l_timezone;

            EXCEPTION

               WHEN NO_DATA_FOUND THEN

                  x_dnu_reason := 409;

               WHEN OTHERS THEN

                  Log( 'Get_Timezone_Id'

                     , 'MAP_GMT_OFFSET_WITH_TIMEZONE'

                     , SQLERRM

                     );

                  RAISE fnd_api.g_exc_unexpected_error;

            END;



         -- Time zone is specified as an id

         ELSE

            IF g_tz_lookup_tbl.EXISTS(l_timezone) THEN

               l_timezone_id := l_timezone;

            END IF;

         END IF;



      -- Time zone contains non-numeric characters, indicating descriptive name

      ELSE



         l_timezone := p_timezone;

         BEGIN

            BEGIN

               EXECUTE IMMEDIATE

                  'SELECT TIMEZONE_ID

                   FROM IEC_TZ_OFFSET_MAP_CACHE

                   WHERE UPPER(OFFSET) = :timezone

                   AND ROWNUM = 1'

               INTO l_timezone_id

               USING l_timezone;

            EXCEPTION

               WHEN NO_DATA_FOUND THEN

                  NULL;

               WHEN OTHERS THEN

                  RAISE;

            END;



            IF l_timezone_id IS NULL THEN



               -- Assume time zone name is specified in long format ('America/New_York')

               l_timezone := REPLACE(l_timezone, ' ', '_');

               BEGIN

                  EXECUTE IMMEDIATE   ---- bug6449880

                     'SELECT UPGRADE_TZ_ID

                      FROM FND_TIMEZONES_VL

                      WHERE UPPER(NAME) = :timezone_name

                      AND ROWNUM = 1'

                  INTO l_timezone_id

                  USING l_timezone;

               EXCEPTION

                  WHEN NO_DATA_FOUND THEN

                     x_dnu_reason := 430;

                  WHEN OTHERS THEN

                     RAISE;

               END;

            END IF;



         EXCEPTION

            WHEN OTHERS THEN

               Log( 'Get_Timezone_Id'

                  , 'MAP_NAME_WITH_TIMEZONE'

                  , SQLERRM

                  );

               RAISE fnd_api.g_exc_unexpected_error;

         END;

      END IF;



   END IF;



   IF l_timezone_id IS NOT NULL THEN

      x_dnu_reason := NULL;

   ELSIF x_dnu_reason IS NULL THEN

      x_dnu_reason := 404;

   END IF;



   RETURN l_timezone_id;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Get_Timezone_Id'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Get_Timezone_Id;



FUNCTION Validate_Canonical_Number

   ( p_raw_phone_number IN            VARCHAR2

   , x_country_code     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_area_code        IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_phone_number     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_dnu_reason          OUT NOCOPY NUMBER)    -- OUT

RETURN BOOLEAN

IS

   l_cc_index  PLS_INTEGER;

   l_ac_index  PLS_INTEGER;

   l_pn_index  PLS_INTEGER;

   l_validated BOOLEAN := FALSE;



   l_area_code_clean VARCHAR2(500);

   l_country_code_clean VARCHAR2(500);

BEGIN



   l_cc_index := INSTR(p_raw_phone_number, '+');

   l_ac_index := INSTR(p_raw_phone_number, ' (');

   l_pn_index := INSTR(p_raw_phone_number, ') ');



   IF l_cc_index = 1 AND l_ac_index <> 0 AND l_pn_index <> 0 THEN



      x_country_code := SUBSTR(p_raw_phone_number, l_cc_index + 1, (l_ac_index - l_cc_index - 1));



      l_country_code_clean := TRANSLATE( UPPER(x_country_code)

                                       , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                       , '0123456789');



      -- Invalidate record if country code contains non-numeric characters

      IF l_country_code_clean <> x_country_code THEN

         x_country_code := NULL;

         x_dnu_reason := 423;

         RETURN l_validated;

      END IF;



      x_area_code := SUBSTR(p_raw_phone_number, l_ac_index + 2, (l_pn_index - l_ac_index - 2));



      l_area_code_clean := TRANSLATE( UPPER(x_area_code)

                                    , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                    , '0123456789');



      -- Invalidate record if area code contains non-numeric characters

      IF l_area_code_clean <> x_area_code THEN

         x_area_code := NULL;

         x_dnu_reason := 424;

         RETURN l_validated;

      END IF;



      x_phone_number := SUBSTR(p_raw_phone_number, l_pn_index + 2

                              , (LENGTH(p_raw_phone_number) - l_pn_index - 1));



      x_phone_number := TRANSLATE( UPPER(x_phone_number)

                                 , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                 , '0123456789');



      IF x_country_code IS NOT NULL AND x_area_code IS NOT NULL AND x_phone_number IS NOT NULL THEN

         l_validated := TRUE;

      END IF;



   END IF;



   RETURN l_validated;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_Canonical_Number'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_Canonical_Number;



FUNCTION Validate_Non_Canonical_Number

   ( x_raw_phone_number IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_country_code     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_area_code        IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_phone_number     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_territory_code   IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_dnu_reason          OUT NOCOPY NUMBER)    -- OUT

RETURN BOOLEAN

IS

   l_validated BOOLEAN := FALSE;

   l_area_code_req_flag BOOLEAN;

BEGIN



   x_raw_phone_number := TRANSLATE( x_raw_phone_number

                                  , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                  , '0123456789');



   IF g_territory_code IS NOT NULL THEN

      x_territory_code := g_territory_code;

      x_country_code := g_phone_country_code;

      IF INSTR(x_raw_phone_number, x_country_code) = 1 THEN

         x_raw_phone_number := SUBSTR(x_raw_phone_number, LENGTH(x_country_code) + 1);

      END IF;

   ELSIF g_phone_country_code IS NOT NULL THEN

      x_country_code := g_phone_country_code;

      IF INSTR(x_raw_phone_number, x_country_code) = 1 THEN

         x_raw_phone_number := SUBSTR(x_raw_phone_number, LENGTH(x_country_code) + 1);

      END IF;

   ELSIF x_country_code IS NULL THEN

      x_country_code := Parse_Country_Code(x_raw_phone_number);

   END IF;



   IF x_country_code IS NULL THEN

      x_dnu_reason := 420;

      GOTO Done;

   END IF;



   Parse_Area_Code(x_raw_phone_number, x_country_code, x_territory_code, x_area_code, l_area_code_req_flag);

   IF x_area_code IS NULL AND l_area_code_req_flag THEN

      x_dnu_reason := 421;

      GOTO DONE;

   END IF;



   x_phone_number := x_raw_phone_number;

   IF x_phone_number IS NULL THEN

      x_dnu_reason := 422;

      GOTO Done;

   END IF;



   l_validated := TRUE;



<<Done>>

   RETURN l_validated;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_Non_Canonical_Number'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_Non_Canonical_Number;



FUNCTION Validate_Composite_Number

   ( x_country_code       IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_area_code          IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_phone_number       IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_territory_code     IN OUT NOCOPY VARCHAR2   -- IN OUT

   , x_cp_dnu_reason         OUT NOCOPY NUMBER)    -- OUT

RETURN BOOLEAN

IS

   l_validated BOOLEAN := FALSE;



   l_country_code_clean VARCHAR2(500);

   l_area_code_clean    VARCHAR2(500);

   l_area_code_req_flag BOOLEAN;



BEGIN



   IF g_territory_code IS NOT NULL THEN

      x_territory_code := g_territory_code;

      x_country_code := g_phone_country_code;

   ELSIF g_phone_country_code IS NOT NULL THEN

      x_country_code := g_phone_country_code;

   ELSIF x_country_code IS NULL THEN

      x_cp_dnu_reason := 410;

      GOTO Done;

   END IF;



   x_country_code := TRANSLATE( UPPER(x_country_code)

                              , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                              , '0123456789');



   l_country_code_clean := TRANSLATE( UPPER(x_country_code)

                                    , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                    , '0123456789');



   -- Invalidate record if country code contains non-numeric characters

   IF l_country_code_clean <> x_country_code THEN

      x_country_code := NULL;

      x_cp_dnu_reason := 413;

      GOTO Done;

   END IF;



   IF x_area_code IS NULL THEN

      Parse_Area_Code(x_phone_number, x_country_code, x_territory_code, x_area_code, l_area_code_req_flag);

      IF x_area_code IS NULL AND l_area_code_req_flag THEN

         x_cp_dnu_reason := 411;

         GOTO Done;

      END IF;

   END IF;



   l_area_code_clean := TRANSLATE( UPPER(x_area_code)

                                 , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                                 , '0123456789');



   -- Invalidate record if area code contains non-numeric characters

   IF l_area_code_clean <> x_area_code THEN

      x_area_code := NULL;

      x_cp_dnu_reason := 414;

      GOTO Done;

   END IF;



   IF x_phone_number IS NULL THEN

      x_cp_dnu_reason := 412;

      GOTO Done;

   END IF;



   x_phone_number := TRANSLATE( UPPER(x_phone_number)

                              , '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-+/=()*&^%$#@!~`[]{}|\:;?><., '

                              , '0123456789');



   l_validated := TRUE;



<<Done>>

   RETURN l_validated;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_Composite_Number'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_Composite_Number;



PROCEDURE Init_ContactPointRecord

   ( x_contact_point IN OUT NOCOPY ContactPoint)   -- IN OUT

IS

BEGIN



   x_contact_point.id                 := NULL;

   x_contact_point.phone_country_code := NULL;

   x_contact_point.phone_area_code    := NULL;

   x_contact_point.phone_number       := NULL;

   x_contact_point.raw_phone_number   := NULL;

   x_contact_point.time_zone          := NULL;

   x_contact_point.territory_code     := NULL;

   x_contact_point.region_id          := NULL;

   x_contact_point.cc_tz_id           := NULL;

   x_contact_point.valid_flag         := NULL;

   x_contact_point.dnu_reason         := NULL;



END Init_ContactPointRecord;



PROCEDURE Validate_ContactPointRecord

   ( p_postal_code   IN            VARCHAR2

   , x_contact_point IN OUT NOCOPY ContactPoint)   -- IN OUT

IS

   l_contact_point ContactPoint;



   l_already_validated BOOLEAN := FALSE;

   l_rpn_exists        BOOLEAN := FALSE;

   l_pn_exists         BOOLEAN := FALSE;

   l_tz_dnu_reason     NUMBER;



   -- Variables for mobile phone check (TCA procedure call)

   l_mobile_flag       VARCHAR2(1);

   l_return_status     VARCHAR2(1);

   l_msg_count         NUMBER;

   l_msg_data          VARCHAR2(4000);

BEGIN



   -- Copy In Out Parameters into local variables

   -- Contact Point Paramater will not be updated unless contact point is valid

   -- Prevents overwriting data in AMS_LIST_ENTRIES for invalid contact points

   l_contact_point := x_contact_point;



   -- Assume that contact point is invalid

   x_contact_point.valid_flag := 'N';



   IF l_contact_point.phone_number IS NULL AND l_contact_point.raw_phone_number IS NULL THEN

      x_contact_point.dnu_reason := 400;

      GOTO Done;

   END IF;



   IF l_contact_point.raw_phone_number IS NOT NULL THEN

      l_rpn_exists := TRUE;

   END IF;



   IF l_contact_point.phone_number IS NOT NULL THEN

      l_pn_exists := TRUE;

   END IF;



   IF l_rpn_exists THEN



      -- ATTEMPT TO VALIDATE RAW_PHONE_NUMBER FIELD (IN CANONICAL FORM)

      l_already_validated := Validate_Canonical_Number( l_contact_point.raw_phone_number

                                                      , l_contact_point.phone_country_code

                                                      , l_contact_point.phone_area_code

                                                      , l_contact_point.phone_number

                                                      , x_contact_point.dnu_reason);

   END IF;



   IF l_pn_exists AND NOT l_already_validated THEN



      -- ATTEMPT TO VALIDATE SEPERATE PHONE_NUMBER, AREA_CODE, COUNTRY_CODE FIELDS

      l_already_validated := Validate_Composite_Number( l_contact_point.phone_country_code

                                                      , l_contact_point.phone_area_code

                                                      , l_contact_point.phone_number

                                                      , l_contact_point.territory_code

                                                      , x_contact_point.dnu_reason);



   END IF;



   IF l_rpn_exists

      AND NOT l_already_validated

      AND (x_contact_point.dnu_reason IS NULL

           OR (x_contact_point.dnu_reason <> 423        -- Ensure that record did not already fail as a result of having

               AND x_contact_point.dnu_reason <> 424))  -- non-numeric characters in country or area code in canonical form

   THEN



      -- ATTEMPT TO VALIDATE RAW_PHONE_NUMBER FIELD (NOT IN CANONICAL FORM)

      l_already_validated := Validate_Non_Canonical_Number( l_contact_point.raw_phone_number

                                                          , l_contact_point.phone_country_code

                                                          , l_contact_point.phone_area_code

                                                          , l_contact_point.phone_number

                                                          , l_contact_point.territory_code

                                                          , x_contact_point.dnu_reason);

   END IF;



   -- COULD NOT VALIDATE NUMBER USING ANY METHOD

   IF NOT l_already_validated THEN

      GOTO Done;

   END IF;



   -- If this phone country code has a fixed area code length

   -- Verify that area code is of correct length

   -- Only enforce this if rule is set!

   IF  g_enable_ac_length_val

   AND g_ac_length_tbl.EXISTS(l_contact_point.phone_country_code)

   AND LENGTH(l_contact_point.phone_area_code) <> g_ac_length_tbl(l_contact_point.phone_country_code)

   THEN

      x_contact_point.dnu_reason := 407;

      Goto Done;

   END IF;



   -- If this phone country code has a fixed phone number length

   -- Verify that phone number is of correct length

   -- Only enforce this if rule is set!

   IF  g_enable_pn_length_val

   AND g_pn_length_tbl.EXISTS(l_contact_point.phone_country_code)

   AND LENGTH(l_contact_point.phone_number) <> g_pn_length_tbl(l_contact_point.phone_country_code)

   THEN

      x_contact_point.dnu_reason := 406;

      Goto Done;

   END IF;



   l_contact_point.raw_phone_number := Create_Canonical_Number(l_contact_point.phone_country_code, l_contact_point.phone_area_code, l_contact_point.phone_number);

   IF l_contact_point.raw_phone_number IS NULL OR LENGTH(l_contact_point.raw_phone_number) > 240 THEN

      x_contact_point.dnu_reason := 402;

      GOTO Done;

   END IF;



   -- If not validating cell phones, check if number if mobile number

   IF g_enable_cell_phone_val = FALSE THEN



      HZ_FORMAT_PHONE_V2PUB.check_mobile_phone

         ( 'T'

         , l_contact_point.phone_country_code

         , l_contact_point.phone_area_code

         , l_contact_point.phone_number

         , l_mobile_flag

         , l_return_status

         , l_msg_count

         , l_msg_data);



      IF l_return_status <> 'S' THEN

         Log( 'Validate_Contact_Point'

            , 'CHECK_MOBILE_PHONE'

            , l_msg_data

            );

        RAISE fnd_api.g_exc_unexpected_error;

      END IF;



      IF l_mobile_flag = 'Y' THEN

         x_contact_point.dnu_reason := 408;

         GOTO Done;

      END IF;

   END IF;



   Get_Territory_Code(l_contact_point.phone_country_code, l_contact_point.phone_area_code, l_contact_point.territory_code, l_contact_point.region_id);

   IF l_contact_point.territory_code IS NULL OR LENGTH(l_contact_point.territory_code) > 30 THEN

      x_contact_point.dnu_reason := 403;

      GOTO Done;

   END IF;



   IF l_contact_point.region_id IS NULL AND g_require_regions THEN

      x_contact_point.dnu_reason := 405;

      GOTO Done;

   END IF;



   l_contact_point.time_zone := Get_Timezone_Id(l_contact_point.territory_code, l_contact_point.phone_area_code, p_postal_code, l_contact_point.time_zone, l_tz_dnu_reason);

   IF l_contact_point.time_zone IS NULL THEN

      x_contact_point.dnu_reason := l_tz_dnu_reason;

      GOTO Done;

   END IF;



   -- Contact Point is Valid

   -- Overwrite Contact Point with validated Contact Point

   x_contact_point := l_contact_point;

   x_contact_point.valid_flag := 'Y';

   x_contact_point.dnu_reason := NULL;



<<Done>>

   NULL;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_ContactPointRecord'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_ContactPointRecord;



PROCEDURE Validate_List_Entry

   ( p_list_entry_id             IN            NUMBER

   , p_postal_code               IN            VARCHAR2

   , x_contact_points            IN OUT NOCOPY ContactPointList   -- IN OUT

   , x_current_contact_point        OUT NOCOPY ContactPoint       -- OUT

   , x_current_contact_point_idx IN OUT NOCOPY NUMBER)            -- IN OUT

IS

   l_found_current_cp       BOOLEAN := FALSE;

   l_save_contact_point_idx NUMBER;

BEGIN



   Init_ContactPointRecord(x_current_contact_point);

   l_save_contact_point_idx := x_current_contact_point_idx;

   x_current_contact_point_idx := NULL;



   FOR i IN 1..G_NUM_CONTACT_POINTS LOOP



      -- Validate contact points that are invalid

      -- invalid if no cc_tz_id has been assigned

      IF  x_contact_points(i).cc_tz_id IS NULL THEN

         Validate_ContactPointRecord( p_postal_code

                                    , x_contact_points(i));

      ELSE

         x_contact_points(i).valid_flag := 'Y';

      END IF;



      IF (NOT l_found_current_cp) AND (x_contact_points(i).valid_flag = 'Y') THEN

         x_current_contact_point := x_contact_points(i);

         x_current_contact_point_idx := i;

         l_found_current_cp := TRUE;

      END IF;



   END LOOP;



   -- We want to preserve the current contact point for records that

   -- already have some valid contact points since recycling algs

   -- may have changed the current contact point during execution.

   -- must make sure that this contact point is still valid

   IF     l_save_contact_point_idx IS NOT NULL

      AND l_save_contact_point_idx <> x_current_contact_point_idx

      AND x_contact_points(l_save_contact_point_idx).valid_flag = 'Y'

   THEN

      x_current_contact_point := x_contact_points(l_save_contact_point_idx);

      x_current_contact_point_idx := l_save_contact_point_idx;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error OR fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_List_Entry'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_List_Entry;



PROCEDURE Remove_Entries_Pvt

   ( p_list_id              IN NUMBER

   , p_schedule_id          IN NUMBER

   , p_returns_id_col       IN SYSTEM.number_tbl_type

   )

IS

   l_returns_id_col         SYSTEM.number_tbl_type;

   l_subset_id_col          SYSTEM.number_tbl_type;

   l_list_entry_id_col      SYSTEM.number_tbl_type;

   l_callable_zone_id_col   SYSTEM.number_tbl_type;

   l_do_not_use_col         SYSTEM.varchar_tbl_type;

   l_rl_incr_amount_col     SYSTEM.number_tbl_type;

   l_cz_incr_amount_col     SYSTEM.number_tbl_type;

BEGIN



   -- Delete specified records in IEC_G_RETURN_ENTRIES

   -- Retrieving information to clean up other tables

   DELETE IEC_G_RETURN_ENTRIES A

   WHERE A.LIST_HEADER_ID = p_list_id

   AND A.RETURNS_ID IN (SELECT * FROM TABLE(CAST(p_returns_id_col AS SYSTEM.NUMBER_TBL_TYPE)))
   RETURNING A.RETURNS_ID, A.SUBSET_ID, A.LIST_ENTRY_ID, A.ITM_CC_TZ_ID, A.DO_NOT_USE_FLAG
   BULK COLLECT INTO l_returns_id_col, l_subset_id_col, l_list_entry_id_col, l_callable_zone_id_col, l_do_not_use_col;



   IF l_returns_id_col IS NOT NULL AND l_returns_id_col.COUNT > 0 THEN



      -- Delete call history

      EXECUTE IMMEDIATE

         'BEGIN

          FORALL i IN :first .. :last

             DELETE IEC_O_RCY_CALL_HISTORIES

             WHERE RETURNS_ID = :returns_id(i);

          END;'

      USING IN l_returns_id_col.FIRST

          , IN l_returns_id_col.LAST

          , IN l_returns_id_col;



      -- Delete IEC_O_VALIDATION_REPORT_DETS

      EXECUTE IMMEDIATE

         'BEGIN

          FORALL i IN :first .. :last

             DELETE IEC_O_VALIDATION_REPORT_DETS

             WHERE LIST_HEADER_ID = :list_id

             AND LIST_ENTRY_ID = :list_entry_id(i);

          END;'

      USING IN l_list_entry_id_col.FIRST

          , IN l_list_entry_id_col.LAST

          , IN p_list_id

          , IN l_list_entry_id_col;



      l_cz_incr_amount_col := SYSTEM.number_tbl_type();

      l_rl_incr_amount_col := SYSTEM.number_tbl_type();

      FOR i IN 1..l_do_not_use_col.LAST LOOP

         l_cz_incr_amount_col.EXTEND;

         l_rl_incr_amount_col.EXTEND;

         l_rl_incr_amount_col(i) := -1;

         IF l_do_not_use_col(i) = 'N' THEN

            l_cz_incr_amount_col(i) := -1;

         ELSE

            l_cz_incr_amount_col(i) := 0;

         END IF;

      END LOOP;



      -- Decrement callable zone count to indicate that these records have been removed

      Incr_CallableZoneCounts( l_callable_zone_id_col

                             , l_cz_incr_amount_col);



      Purge_CallableZones(p_list_id, p_schedule_id);



      -- Decrement records loaded count to indicate that these records have been removed

      Incr_RecordsLoadedCounts( p_schedule_id

                              , p_list_id

                              , l_subset_id_col

                              , l_rl_incr_amount_col);

   END IF;

EXCEPTION

   WHEN OTHERS THEN

         Log( 'Remove_Entries_Pvt'

            , 'MAIN'

            , SQLERRM

            );

      RAISE fnd_api.g_exc_unexpected_error;



END Remove_Entries_Pvt;



PROCEDURE Remove_DeletedRecords

   ( p_list_id     IN NUMBER

   , p_schedule_id IN NUMBER

   )

IS

   l_returns_id_col         SYSTEM.number_tbl_type;

BEGIN



   -- Look for records that have been deleted from

   -- AMS_LIST_ENTRIES

   EXECUTE IMMEDIATE

      'BEGIN

          SELECT A.RETURNS_ID

          BULK COLLECT INTO :returns_id_col

          FROM IEC_G_RETURN_ENTRIES A

          WHERE A.LIST_HEADER_ID = :list_id

          AND NOT EXISTS (SELECT LIST_ENTRY_ID

                          FROM AMS_LIST_ENTRIES

                          WHERE A.LIST_HEADER_ID = LIST_HEADER_ID

                          AND A.LIST_ENTRY_ID = LIST_ENTRY_ID

                          AND ENABLED_FLAG = ''Y'');

       END;'

    USING OUT l_returns_id_col

        , IN  p_list_id;



   IF l_returns_id_col IS NOT NULL AND l_returns_id_col.COUNT > 0 THEN



      Remove_Entries_Pvt

         ( p_list_id

         , p_schedule_id

         , l_returns_id_col

         );



   END IF;



   -- Also need to delete records from IEC_O_VALIDATION_REPORT_DETS

   -- when all contact points were invalid and there is no corresponding

   -- entry in return entries

   EXECUTE IMMEDIATE

      'DELETE IEC_O_VALIDATION_REPORT_DETS

       WHERE LIST_HEADER_ID = :list_id

       AND DO_NOT_USE_REASON_S1 IS NOT NULL

       AND DO_NOT_USE_REASON_S2 IS NOT NULL

       AND DO_NOT_USE_REASON_S3 IS NOT NULL

       AND DO_NOT_USE_REASON_S4 IS NOT NULL

       AND DO_NOT_USE_REASON_S5 IS NOT NULL

       AND DO_NOT_USE_REASON_S6 IS NOT NULL

       AND LIST_ENTRY_ID NOT IN

          (SELECT LIST_ENTRY_ID

           FROM AMS_LIST_ENTRIES

           WHERE LIST_HEADER_ID = :list_id

           AND ENABLED_FLAG = ''Y'')'

   USING IN p_list_id

       , IN p_list_id;



EXCEPTION

   WHEN OTHERS THEN

         Log( 'Remove_DeletedRecords'

            , 'MAIN'

            , SQLERRM

            );

      RAISE fnd_api.g_exc_unexpected_error;



END Remove_DeletedRecords;



PROCEDURE Purge_ScheduleEntries_Pvt

   ( p_schedule_id   IN            NUMBER

   , p_api_initiated IN            BOOLEAN

   , p_commit_flag   IN            BOOLEAN)

IS

   l_api_initiated     BOOLEAN;

   l_list_id           NUMBER(15);

   l_returns_id_col    SYSTEM.number_tbl_type;

   l_list_entry_id_col SYSTEM.number_tbl_type;

   l_status_code       VARCHAR2(30);

BEGIN



   SAVEPOINT purge_schedule_entries;



   -- Logging initialization

   Init_LoggingVariables;

   Set_MessagePrefix('purge_schedule_' || p_schedule_id);



   l_api_initiated := FALSE; -- Default value

   IF p_api_initiated IS NOT NULL THEN

      l_api_initiated := p_api_initiated;

   END IF;



   -- get list header id corresponding to schedule id

   BEGIN

      IEC_COMMON_UTIL_PVT.Get_ListId(p_schedule_id, l_list_id);

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Purge_ScheduleEntries_Pub'

            , 'GET_LIST_HEADER_ID'

            );

   END;



   -- check list status - needs to be Inactive, Validated, Purged, Failed Purge

   EXECUTE IMMEDIATE

      'SELECT A.STATUS_CODE

       FROM IEC_G_AO_LISTS_V A

       WHERE A.LIST_HEADER_ID = :list_id

       AND LANGUAGE = USERENV(''LANG'')'

   INTO l_status_code

   USING l_list_id;



   IF l_status_code <> 'INACTIVE' AND

      l_status_code <> 'VALIDATED' AND

      l_status_code <> 'PURGING' AND

      l_status_code <> 'PURGED' AND

      l_status_code <> 'FAILED_PURGE'

   THEN

      Log_PurgeListStatusInvMsg('Purge_ScheduleEntries_Pvt','CHECK_SCHEDULE_STATUS', Get_ScheduleName(p_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   Update_PurgeStatus(l_list_id, p_schedule_id, 'PURGING', l_api_initiated);



   -- Look for records that have been marked as do not use

   EXECUTE IMMEDIATE

      'BEGIN

       SELECT A.RETURNS_ID, A.LIST_ENTRY_ID

       BULK COLLECT INTO :returns_id_col, :list_entry_id_col

       FROM IEC_G_RETURN_ENTRIES A

       WHERE A.LIST_HEADER_ID = :list_id

       AND A.DO_NOT_USE_FLAG = ''Y'';

       END;'

   USING OUT l_returns_id_col

       , OUT l_list_entry_id_col

       , IN  l_list_id;



   IF l_returns_id_col IS NOT NULL AND l_returns_id_col.COUNT > 0 THEN



      -- Remove_Entries_Pvt expects certain temporary tables

      -- to be initialized

      Truncate_Temporary_Tables;

      Load_CallableZones(l_list_id);



      Remove_Entries_Pvt

         ( l_list_id

         , p_schedule_id

         , l_returns_id_col

         );



      EXECUTE IMMEDIATE

         'BEGIN

          UPDATE ' || Get_SourceTypeView(l_list_id) || '

          SET REASON_CODE_S1 = NULL

            , REASON_CODE_S2 = NULL

            , REASON_CODE_S3 = NULL

            , REASON_CODE_S4 = NULL

            , REASON_CODE_S5 = NULL

            , REASON_CODE_S6 = NULL

          WHERE LIST_HEADER_ID = :list_id

          AND LIST_ENTRY_ID IN (SELECT * FROM TABLE(CAST(:list_entry_id_col AS SYSTEM.NUMBER_TBL_TYPE)));
          END;'
      USING IN l_list_id

          , IN l_list_entry_id_col;



      Refresh_MViews;

      Truncate_Temporary_Tables;



   END IF;



--   Update_PurgeStatus(l_list_id, p_schedule_id, 'PURGED', l_api_initiated);

   Update_PurgeStatus(l_list_id, p_schedule_id, l_status_code, l_api_initiated);



   IF p_commit_flag THEN

      COMMIT;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO purge_schedule_entries;

--      Update_PurgeStatus(l_list_id, p_schedule_id, 'FAILED_PURGE', l_api_initiated);

      Update_PurgeStatus(l_list_id, p_schedule_id, l_status_code, l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO purge_schedule_entries;

--      Update_PurgeStatus(l_list_id, p_schedule_id, 'FAILED_PURGE', l_api_initiated);

      Update_PurgeStatus(l_list_id, p_schedule_id, l_status_code, l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN OTHERS THEN

      ROLLBACK TO purge_schedule_entries;

      Log( 'Purge_ScheduleEntries_Pvt'

         , 'MAIN'

         , SQLERRM

         );

--      Update_PurgeStatus(l_list_id, p_schedule_id, 'FAILED_PURGE', l_api_initiated);

      Update_PurgeStatus(l_list_id, p_schedule_id, l_status_code, l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Purge_ScheduleEntries_Pvt;



-- Procedure to be called by public api to purge schedule

-- entries

PROCEDURE Purge_ScheduleEntries_Pub

   ( p_schedule_id   IN            NUMBER

   , p_commit        IN            BOOLEAN

   , x_return_status    OUT NOCOPY VARCHAR2)

IS

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   Purge_ScheduleEntries_Pvt

      ( p_schedule_id

      , TRUE

      , p_commit

      );



EXCEPTION

   WHEN OTHERS THEN

      FND_MSG_PUB.ADD;

      x_return_status := FND_API.G_RET_STS_ERROR;

END Purge_ScheduleEntries_Pub;



PROCEDURE Validate_List_Pvt

   ( p_list_id               IN            NUMBER

   , p_campaign_schedule_id  IN            NUMBER

   , p_campaign_id           IN            NUMBER

   , p_source_type_view      IN            VARCHAR2

   , p_list_entry_csr        IN            ListEntryCsrType

   , p_commit_flag           IN            VARCHAR2

   )

IS

   l_list_entry_id            NUMBER;

   l_postal_code              VARCHAR2(100);

   l_do_not_use_flag          VARCHAR2(1);

   l_do_not_use_reason        VARCHAR2(30);

   l_newly_updated_flag       VARCHAR2(1);

   l_prev_callable_zone_id    NUMBER(15);

   l_prev_subset_id           NUMBER(15);



   l_contact_points           ContactPointList := ContactPointList();



   l_curr_contact_point       ContactPoint;

   l_curr_contact_point_idx   NUMBER;



   l_prev_record_status       VARCHAR2(32);



   l_entry_count              NUMBER;



   l_subset_id_col            SYSTEM.number_tbl_type;

   l_subset_view_col          SYSTEM.varchar_tbl_type;

   l_subset_rec_loaded_col    SYSTEM.number_tbl_type;



   l_callable_zone_id_col       SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

   l_callable_zone_incr_col     SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

   l_subset_rec_loaded_id_col   SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

   l_subset_rec_loaded_incr_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();



BEGIN

   Init_SubsetRtInfo(p_list_id, p_source_type_view, l_subset_id_col, l_subset_view_col);



   l_contact_points.EXTEND(G_NUM_CONTACT_POINTS);

   LOOP



      l_callable_zone_id_col.DELETE;

      l_callable_zone_incr_col.DELETE;

      l_subset_rec_loaded_id_col.DELETE;

      l_subset_rec_loaded_incr_col.DELETE;



      FOR I IN 1..g_row_increment LOOP



         -- Initialize Contact Point Record Attributes

         Init_ContactPointRecord(l_curr_contact_point);

         l_curr_contact_point_idx := NULL;



         FOR i IN 1..G_NUM_CONTACT_POINTS LOOP

            Init_ContactPointRecord(l_contact_points(i));

         END LOOP;



         FETCH p_list_entry_csr INTO l_list_entry_id, l_postal_code, l_do_not_use_flag, l_do_not_use_reason, l_newly_updated_flag, l_prev_subset_id, l_prev_callable_zone_id, l_curr_contact_point_idx,

               l_contact_points(1).id, l_contact_points(1).time_zone, l_contact_points(1).phone_country_code, l_contact_points(1).phone_area_code, l_contact_points(1).phone_number,

			   l_contact_points(1).raw_phone_number, l_contact_points(1).cc_tz_id, l_contact_points(1).phone_line_type, l_contact_points(1).purpose,

               l_contact_points(2).id, l_contact_points(2).time_zone, l_contact_points(2).phone_country_code, l_contact_points(2).phone_area_code, l_contact_points(2).phone_number,

			   l_contact_points(2).raw_phone_number, l_contact_points(2).cc_tz_id, l_contact_points(2).phone_line_type, l_contact_points(2).purpose,

               l_contact_points(3).id, l_contact_points(3).time_zone, l_contact_points(3).phone_country_code, l_contact_points(3).phone_area_code, l_contact_points(3).phone_number,

			   l_contact_points(3).raw_phone_number, l_contact_points(3).cc_tz_id, l_contact_points(3).phone_line_type, l_contact_points(3).purpose,

               l_contact_points(4).id, l_contact_points(4).time_zone, l_contact_points(4).phone_country_code, l_contact_points(4).phone_area_code, l_contact_points(4).phone_number,

			   l_contact_points(4).raw_phone_number, l_contact_points(4).cc_tz_id, l_contact_points(4).phone_line_type, l_contact_points(4).purpose,

               l_contact_points(5).id, l_contact_points(5).time_zone, l_contact_points(5).phone_country_code, l_contact_points(5).phone_area_code, l_contact_points(5).phone_number,

			   l_contact_points(5).raw_phone_number, l_contact_points(5).cc_tz_id, l_contact_points(5).phone_line_type, l_contact_points(5).purpose,

               l_contact_points(6).id, l_contact_points(6).time_zone, l_contact_points(6).phone_country_code, l_contact_points(6).phone_area_code, l_contact_points(6).phone_number,

			   l_contact_points(6).raw_phone_number, l_contact_points(6).cc_tz_id, l_contact_points(6).phone_line_type, l_contact_points(6).purpose;



         EXIT WHEN p_list_entry_csr%NOTFOUND;



         BEGIN



            IF l_do_not_use_flag = 'Y' AND l_do_not_use_reason = 4 THEN

               l_prev_record_status := 'INVALID';           -- invalid record

            ELSIF l_do_not_use_flag = 'N' THEN

               l_prev_record_status := 'VALID_ALL';         -- valid record - all contact points valid

               FOR i IN 1..G_NUM_CONTACT_POINTS LOOP

                  IF  l_contact_points(i).cc_tz_id IS NULL AND

                     (l_contact_points(i).phone_number IS NOT NULL OR

                      l_contact_points(i).raw_phone_number IS NOT NULL)

                  THEN

                     l_prev_record_status := 'VALID_SOME';  -- valid record - at least one invalid contact point

                     EXIT;

                  END IF;

               END LOOP;

            ELSE

               l_prev_record_status := 'NEW';               -- new record (never been validated)

            END IF;



            -- If record was previously valid, we must decrement the

            -- records loaded report count for the previous subset id

            IF    (l_prev_record_status = 'VALID_ALL'

               OR l_prev_record_status = 'VALID_SOME')

               AND l_prev_subset_id IS NOT NULL

            THEN

               l_subset_rec_loaded_id_col.EXTEND;

               l_subset_rec_loaded_id_col(l_subset_rec_loaded_id_col.LAST) := l_prev_subset_id;

               l_subset_rec_loaded_incr_col.EXTEND;

               l_subset_rec_loaded_incr_col(l_subset_rec_loaded_incr_col.LAST) := -1;

            END IF;



            -- If record had a previous current contact point, we must

            -- decrement callable zone count for previous current contact point

            -- since current contact point may change if the record has been

            -- updated, the current contact point changes, or the subset is changed

            IF l_prev_callable_zone_id IS NOT NULL THEN

               l_callable_zone_id_col.EXTEND;

               l_callable_zone_id_col(l_callable_zone_id_col.LAST) := l_prev_callable_zone_id;

               l_callable_zone_incr_col.EXTEND;

               l_callable_zone_incr_col(l_callable_zone_incr_col.LAST) := -1;

            END IF;



            -- If record has been updated, nullify the current cc_tz_id to force

            -- revalidation of the contact point

            IF l_newly_updated_flag = 'Y' THEN

               FOR i IN 1..G_NUM_CONTACT_POINTS LOOP

                  l_contact_points(i).cc_tz_id := NULL;

               END LOOP;

            ELSE

               FOR i IN 1..G_NUM_CONTACT_POINTS LOOP

                  IF l_contact_points(i).cc_tz_id IS NOT NULL THEN



                     Get_CallableZoneDetail_Cache

                        ( l_contact_points(i).cc_tz_id

                        , l_contact_points(i).territory_code

                        , l_contact_points(i).region_id

                        , l_contact_points(i).time_zone

                        , l_contact_points(i).valid_flag

                        );



                     -- If the callable zone id is not associated with this list,

                     -- map the callable zone id to the territory_code, region_id,

                     -- and time_zone, then delete the callable zone id so

                     -- that record will be validated and assigned a new

                     -- callable zone id that is associated with this list

                     IF l_contact_points(i).valid_flag = 'N' THEN

                        Get_CallableZoneDetail

                           ( l_contact_points(i).cc_tz_id

                           , l_contact_points(i).territory_code

                           , l_contact_points(i).region_id

                           , l_contact_points(i).time_zone

                           , l_contact_points(i).valid_flag

                           );

                        l_contact_points(i).cc_tz_id := NULL;

                     END IF;

                  END IF;

               END LOOP;

            END IF;



            Validate_List_Entry ( l_list_entry_id

                                , l_postal_code

                                , l_contact_points

                                , l_curr_contact_point

                                , l_curr_contact_point_idx);



            IF l_curr_contact_point_idx IS NULL THEN

               -- Indicates entry failed validation

               l_do_not_use_flag := 'Y';

               l_do_not_use_reason := 4;



            ELSE

               -- Indicates entry passed validation

               l_do_not_use_flag := 'N';

               l_do_not_use_reason := NULL;



            END IF;

         EXCEPTION

            WHEN fnd_api.g_exc_error THEN

               GOTO Next_List_Entry;

            WHEN fnd_api.g_exc_unexpected_error THEN

               GOTO Next_List_Entry;

            WHEN OTHERS THEN

               RAISE;

         END;



         INSERT INTO IEC_VAL_ENTRY_CACHE

            ( LIST_ENTRY_ID

            , POSTAL_CODE

            , DO_NOT_USE_FLAG

            , DO_NOT_USE_REASON

            , PREV_STATUS_CODE

            , CURR_CP_INDEX

            , CURR_CP_ID

            , CURR_CP_TIME_ZONE

            , CURR_CP_COUNTRY_CODE

            , CURR_CP_AREA_CODE

            , CURR_CP_PHONE_NUMBER

            , CURR_CP_RAW_PHONE_NUMBER

            , CURR_CP_TERRITORY_CODE

            , CURR_CP_REGION_ID

            , CURR_CP_MKTG_ITEM_CC_TZS_ID

            , CURR_CP_PHONE_LINE_TYPE

            , CURR_CP_CONTACT_POINT_PURPOSE

            , CONTACT_POINT_ID_S1

            , TIME_ZONE_S1

            , PHONE_COUNTRY_CODE_S1

            , PHONE_AREA_CODE_S1

            , PHONE_NUMBER_S1

            , RAW_PHONE_NUMBER_S1

            , TERRITORY_CODE_S1

            , REGION_ID_S1

            , MKTG_ITEM_CC_TZS_ID_S1

            , VALID_FLAG_S1

            , DO_NOT_USE_REASON_S1

            , PHONE_LINE_TYPE_S1

            , CONTACT_POINT_PURPOSE_S1

            , CONTACT_POINT_ID_S2

            , TIME_ZONE_S2

            , PHONE_COUNTRY_CODE_S2

            , PHONE_AREA_CODE_S2

            , PHONE_NUMBER_S2

            , RAW_PHONE_NUMBER_S2

            , TERRITORY_CODE_S2

            , REGION_ID_S2

            , MKTG_ITEM_CC_TZS_ID_S2

            , VALID_FLAG_S2

            , DO_NOT_USE_REASON_S2

            , PHONE_LINE_TYPE_S2

            , CONTACT_POINT_PURPOSE_S2

            , CONTACT_POINT_ID_S3

            , TIME_ZONE_S3

            , PHONE_COUNTRY_CODE_S3

            , PHONE_AREA_CODE_S3

            , PHONE_NUMBER_S3

            , RAW_PHONE_NUMBER_S3

            , TERRITORY_CODE_S3

            , REGION_ID_S3

            , MKTG_ITEM_CC_TZS_ID_S3

            , VALID_FLAG_S3

            , DO_NOT_USE_REASON_S3

            , PHONE_LINE_TYPE_S3

            , CONTACT_POINT_PURPOSE_S3

            , CONTACT_POINT_ID_S4

            , TIME_ZONE_S4

            , PHONE_COUNTRY_CODE_S4

            , PHONE_AREA_CODE_S4

            , PHONE_NUMBER_S4

            , RAW_PHONE_NUMBER_S4

            , TERRITORY_CODE_S4

            , REGION_ID_S4

            , MKTG_ITEM_CC_TZS_ID_S4

            , VALID_FLAG_S4

            , DO_NOT_USE_REASON_S4

            , PHONE_LINE_TYPE_S4

            , CONTACT_POINT_PURPOSE_S4

            , CONTACT_POINT_ID_S5

            , TIME_ZONE_S5

            , PHONE_COUNTRY_CODE_S5

            , PHONE_AREA_CODE_S5

            , PHONE_NUMBER_S5

            , RAW_PHONE_NUMBER_S5

            , TERRITORY_CODE_S5

            , REGION_ID_S5

            , MKTG_ITEM_CC_TZS_ID_S5

            , VALID_FLAG_S5

            , DO_NOT_USE_REASON_S5

            , PHONE_LINE_TYPE_S5

            , CONTACT_POINT_PURPOSE_S5

            , CONTACT_POINT_ID_S6

            , TIME_ZONE_S6

            , PHONE_COUNTRY_CODE_S6

            , PHONE_AREA_CODE_S6

            , PHONE_NUMBER_S6

            , RAW_PHONE_NUMBER_S6

            , TERRITORY_CODE_S6

            , REGION_ID_S6

            , MKTG_ITEM_CC_TZS_ID_S6

            , VALID_FLAG_S6

            , DO_NOT_USE_REASON_S6

            , PHONE_LINE_TYPE_S6

            , CONTACT_POINT_PURPOSE_S6

            )

         VALUES

            ( l_list_entry_id

            , l_postal_code

            , l_do_not_use_flag

            , l_do_not_use_reason

            , l_prev_record_status

            , l_curr_contact_point_idx

            , l_curr_contact_point.id

            , l_curr_contact_point.time_zone

            , l_curr_contact_point.phone_country_code

            , l_curr_contact_point.phone_area_code

            , l_curr_contact_point.phone_number

            , l_curr_contact_point.raw_phone_number

            , l_curr_contact_point.territory_code

            , l_curr_contact_point.region_id

            , l_curr_contact_point.cc_tz_id

            , l_curr_contact_point.phone_line_type

            , l_curr_contact_point.purpose

            , l_contact_points(1).id

            , l_contact_points(1).time_zone

            , l_contact_points(1).phone_country_code

            , l_contact_points(1).phone_area_code

            , l_contact_points(1).phone_number

            , l_contact_points(1).raw_phone_number

            , l_contact_points(1).territory_code

            , l_contact_points(1).region_id

            , l_contact_points(1).cc_tz_id

            , l_contact_points(1).valid_flag

            , l_contact_points(1).dnu_reason

            , l_contact_points(1).phone_line_type

            , l_contact_points(1).purpose

            , l_contact_points(2).id

            , l_contact_points(2).time_zone

            , l_contact_points(2).phone_country_code

            , l_contact_points(2).phone_area_code

            , l_contact_points(2).phone_number

            , l_contact_points(2).raw_phone_number

            , l_contact_points(2).territory_code

            , l_contact_points(2).region_id

            , l_contact_points(2).cc_tz_id

            , l_contact_points(2).valid_flag

            , l_contact_points(2).dnu_reason

            , l_contact_points(2).phone_line_type

            , l_contact_points(2).purpose

            , l_contact_points(3).id

            , l_contact_points(3).time_zone

            , l_contact_points(3).phone_country_code

            , l_contact_points(3).phone_area_code

            , l_contact_points(3).phone_number

            , l_contact_points(3).raw_phone_number

            , l_contact_points(3).territory_code

            , l_contact_points(3).region_id

            , l_contact_points(3).cc_tz_id

            , l_contact_points(3).valid_flag

            , l_contact_points(3).dnu_reason

            , l_contact_points(3).phone_line_type

            , l_contact_points(3).purpose

            , l_contact_points(4).id

            , l_contact_points(4).time_zone

            , l_contact_points(4).phone_country_code

            , l_contact_points(4).phone_area_code

            , l_contact_points(4).phone_number

            , l_contact_points(4).raw_phone_number

            , l_contact_points(4).territory_code

            , l_contact_points(4).region_id

            , l_contact_points(4).cc_tz_id

            , l_contact_points(4).valid_flag

            , l_contact_points(4).dnu_reason

            , l_contact_points(4).phone_line_type

            , l_contact_points(4).purpose

            , l_contact_points(5).id

            , l_contact_points(5).time_zone

            , l_contact_points(5).phone_country_code

            , l_contact_points(5).phone_area_code

            , l_contact_points(5).phone_number

            , l_contact_points(5).raw_phone_number

            , l_contact_points(5).territory_code

            , l_contact_points(5).region_id

            , l_contact_points(5).cc_tz_id

            , l_contact_points(5).valid_flag

            , l_contact_points(5).dnu_reason

            , l_contact_points(5).phone_line_type

            , l_contact_points(5).purpose

            , l_contact_points(6).id

            , l_contact_points(6).time_zone

            , l_contact_points(6).phone_country_code

            , l_contact_points(6).phone_area_code

            , l_contact_points(6).phone_number

            , l_contact_points(6).raw_phone_number

            , l_contact_points(6).territory_code

            , l_contact_points(6).region_id

            , l_contact_points(6).cc_tz_id

            , l_contact_points(6).valid_flag

            , l_contact_points(6).dnu_reason

            , l_contact_points(6).phone_line_type

            , l_contact_points(6).purpose

            );



      <<Next_List_Entry>>

         NULL;



      END LOOP;



      EXECUTE IMMEDIATE

         'SELECT COUNT(*)

          FROM IEC_VAL_ENTRY_CACHE'

      INTO l_entry_count;



      EXIT WHEN l_entry_count = 0;



      -- Decrement callable zone counts for all previous contact point callable zones

      -- Required to maintain correct report counts when current contact point or subset

      -- changes

      Incr_CallableZoneCounts_Cache(l_callable_zone_id_col, l_callable_zone_incr_col);



      -- Decrement record loaded counts for any entries that were previously assigned

      -- to subsets

      Incr_RecordsLoadedCounts(p_campaign_schedule_id, p_list_id, l_subset_rec_loaded_id_col, l_subset_rec_loaded_incr_col);



      -- Assign entries to subsets before updating ALE and Return Entries

      Partition_SubsetEntries(p_list_id, l_subset_id_col, l_subset_view_col, l_subset_rec_loaded_col);



      -- Compile data on callable zones and initialize counts

      Update_CallableZones(p_list_id);



      Update_AmsListEntries(p_list_id, p_source_type_view);

      Update_ValidationReportDetails(p_list_id);

      Update_IecReturnEntries(p_list_id, p_campaign_schedule_id, p_campaign_id, p_source_type_view);



      Update_ReportCounts( p_campaign_id

                         , p_campaign_schedule_id

                         , p_list_id

                         , l_subset_id_col

                         , l_subset_rec_loaded_col);



      Purge_CallableZones(p_list_id, p_campaign_schedule_id);



      Truncate_IecValEntryCache;



      IF p_commit_flag = 'Y' THEN

         COMMIT;

      END IF;



   END LOOP;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Validate_List_Pvt'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Validate_List_Pvt;



FUNCTION Get_CampaignId

   (p_list_id IN NUMBER)

RETURN NUMBER

IS

   l_campaign_id NUMBER(15);

BEGIN

   -- Get Campaign Id

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT B.CAMPAIGN_ID

          FROM AMS_ACT_LISTS A, AMS_CAMPAIGN_SCHEDULES_B B

          WHERE A.LIST_HEADER_ID = :list_id

          AND A.LIST_USED_BY = ''CSCH''

          AND A.LIST_ACT_TYPE = ''TARGET''

          AND A.LIST_USED_BY_ID = B.SCHEDULE_ID'

      INTO l_campaign_id

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

          Log( 'Get_CampaignScheduleId'

             , 'MAIN'

             , SQLERRM

             );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   RETURN l_campaign_id;



END Get_CampaignId;



FUNCTION Get_ScheduleId

   (p_list_id IN NUMBER)

RETURN NUMBER

IS

   l_campaign_schedule_id NUMBER(15);

BEGIN



   IEC_COMMON_UTIL_PVT.Get_ScheduleId(p_list_id, l_campaign_schedule_id);

   RETURN l_campaign_schedule_id;



EXCEPTION

   WHEN OTHERS THEN

      Log('Get_ScheduleId', 'MAIN');

      RAISE fnd_api.g_exc_unexpected_error;



END Get_ScheduleId;



FUNCTION Get_ScheduleSourceCode

   (p_list_id IN NUMBER)

RETURN VARCHAR2

IS

   l_source_code VARCHAR2(30);

BEGIN



   BEGIN

      EXECUTE IMMEDIATE

         'SELECT B.SOURCE_CODE

          FROM AMS_ACT_LISTS A, AMS_CAMPAIGN_SCHEDULES_B B

          WHERE A.LIST_USED_BY_ID = B.SCHEDULE_ID

          AND A.LIST_HEADER_ID = :list_id'

      INTO l_source_code

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

          Log( 'Get_ScheduleSourceCode'

             , 'MAIN'

             , SQLERRM

             );

         RAISE fnd_api.g_exc_unexpected_error;

   END;



   RETURN l_source_code;



END Get_ScheduleSourceCode;



PROCEDURE Validate_List_Pre

   ( p_list_id          IN                NUMBER

   , p_use_rules_flag   IN                VARCHAR2

   , x_campaign_id             OUT NOCOPY NUMBER

   , x_campaign_schedule_id    OUT NOCOPY NUMBER

   , x_source_type_view        OUT NOCOPY VARCHAR2 )

IS

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN



   x_campaign_id := Get_CampaignId(p_list_id);

   x_campaign_schedule_id := Get_ScheduleId(p_list_id);

   x_source_type_view := Get_SourceTypeView(p_list_id);



   Truncate_Temporary_Tables;

   Init_GlobalVariables;

   Init_LookupTables;

   Load_CallableZones(p_list_id);



   IF p_use_rules_flag = 'Y' THEN

      Init_Rules(p_list_id);

   END IF;



   COMMIT;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Validate_List_Pre'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK;

      RAISE fnd_api.g_exc_unexpected_error;

END Validate_List_Pre;



PROCEDURE Validate_List_Post

   ( p_list_id          IN                NUMBER)

IS

 --  PRAGMA AUTONOMOUS_TRANSACTION;  //FP For bug 8853233

BEGIN



   Truncate_Temporary_Tables;

   Refresh_MViews;

 --  COMMIT; //FP For bug 8853233



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Validate_List_Post'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK;

      RAISE fnd_api.g_exc_unexpected_error;

END Validate_List_Post;



/* No longer checking for required columns preemptively

   due to 8i/9i compatibility problems using ALL_TAB_COLS

   Since we must use ALL_TAB_COLUMNS to check for columns

   and we don't want to impact the performance of validation,

   we will only find the missing columns if the error occurs

   see the Log_MissingSourceTypeColumns for implementation.



FUNCTION Verify_SourceTypeColumns

   ( p_list_id          IN            NUMBER

   , p_source_type_view IN            VARCHAR2

   , p_source_type_code IN            VARCHAR2

   )

RETURN BOOLEAN

IS

   l_curr         VARCHAR2(32);

   l_view_ok      BOOLEAN := TRUE;

   l_columns      SYSTEM.varchar_tbl_type;

   l_missing_cols VARCHAR2(4000);

   l_table_owner  VARCHAR2(30);

BEGIN



   l_table_owner := Get_AppsSchemaName;



   -- Change to ALL_TAB_COLS for performance reasons when 9i db becomes prereq

   SELECT COLUMN_NAME

   BULK COLLECT INTO l_columns

   FROM ALL_TAB_COLUMNS

   WHERE TABLE_NAME = p_source_type_view

   AND OWNER = l_table_owner;



   l_curr := 'LIST_ENTRY_ID';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'POSTAL_CODE';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'DO_NOT_USE_FLAG';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'DO_NOT_USE_REASON';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'NEWLY_UPDATED_FLAG';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S1';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S2';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S3';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S4';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S5';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'CONTACT_POINT_ID_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'TIME_ZONE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_COUNTRY_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_AREA_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_NUMBER_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'RAW_PHONE_NUMBER_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'REASON_CODE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;

   l_curr := 'PHONE_LINE_TYPE_S6';

   IF NOT Contains(l_columns, l_curr) THEN

      l_missing_cols := l_missing_cols || ' ' || l_curr;

   END IF;



   IF l_missing_cols IS NOT NULL THEN

      l_view_ok := FALSE;



      FND_MESSAGE.SET_NAME( 'IEC'

                          , 'IEC_VAL_STV_MISSING_COLUMNS');

      FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE'

                           , NVL(p_source_type_code, 'UNKNOWN')

                           , TRUE);

      FND_MESSAGE.SET_TOKEN( 'MISSING_COLUMNS'

                           , NVL(l_missing_cols, 'UNKNOWN')

                           , TRUE);



      -- References FND_MESSAGE object initialized above

      Set_ValidationHistoryDetails('FAILED_VALIDATION', 'VERIFY_SOURCETYPECOLUMNS', 'MAIN', NULL);



   END IF;



   RETURN l_view_ok;



END Verify_SourceTypeColumns;

*/

FUNCTION Verify_EntrySourceTypes

   ( p_list_id     IN            NUMBER

   )

RETURN BOOLEAN

IS

   l_entries_ok             BOOLEAN := TRUE;

   l_str                    VARCHAR2(4000);

   l_found_list_source_type BOOLEAN := FALSE;

   l_source_type_col        SYSTEM.varchar_tbl_type;

   l_source_type_count_col  SYSTEM.number_tbl_type;

   l_list_source_type       VARCHAR2(32);

BEGIN



   SELECT LIST_ENTRY_SOURCE_SYSTEM_TYPE, COUNT(*)

   BULK COLLECT INTO l_source_type_col, l_source_type_count_col

   FROM AMS_LIST_ENTRIES

   WHERE LIST_HEADER_ID = p_list_id

   GROUP BY LIST_ENTRY_SOURCE_SYSTEM_TYPE;



   SELECT LIST_SOURCE_TYPE

   INTO l_list_source_type

   FROM AMS_LIST_HEADERS_ALL

   WHERE LIST_HEADER_ID = p_list_id;



   IF l_source_type_col IS NOT NULL AND l_source_type_col.COUNT > 0 THEN

      FOR i IN l_source_type_col.FIRST..l_source_type_col.LAST LOOP

         IF l_source_type_col(i) = l_list_source_type THEN

            l_found_list_source_type := TRUE;

            IF l_source_type_col.COUNT = 1 THEN

               EXIT; -- all entries belong to list source type

            ELSE

               -- some entries belong to other source types, so document count for error message

               l_str := l_str || ' (' || l_source_type_col(i) || '=' || l_source_type_count_col(i) || ')';

            END IF;

         ELSE

            -- document counts for other source types for error message

            l_str := l_str || ' (' || l_source_type_col(i) || '=' || l_source_type_count_col(i) || ')';

         END IF;

      END LOOP;



      IF NOT l_found_list_source_type THEN

         l_entries_ok := FALSE;

         Log_SourceTypeMismatchAll('Verify_EntrySourceTypes', 'MAIN', l_list_source_type, l_str);

      ELSIF l_str IS NOT NULL THEN

         l_entries_ok := TRUE;

         Log_SourceTypeMismatchSome('Verify_EntrySourceTypes', 'MAIN', l_list_source_type, l_str);

      END IF;



   ELSE

      -- no entries exist in the list for any source types

      l_entries_ok := FALSE;

      Log_NoEntriesFound('Verify_EntrySourceTypes', 'MAIN');



   END IF;



   RETURN l_entries_ok;



END Verify_EntrySourceTypes;



PROCEDURE Insert_ValidationHistoryRec

   ( p_list_id    IN NUMBER

   )

IS

   PRAGMA AUTONOMOUS_TRANSACTION;



   l_user_id NUMBER;

   l_login_id NUMBER;

BEGIN

   l_user_id := nvl(FND_GLOBAL.user_id, -1);

   l_login_id := nvl(FND_GLOBAL.conc_login_id, -1);

   INSERT INTO IEC_O_VALIDATION_HISTORY

      ( VALIDATION_HISTORY_ID

      , LIST_HEADER_ID

      , STATUS

      , START_TIME

      , END_TIME

      , DESCRIPTION

      , CREATED_BY

      , CREATION_DATE

      , LAST_UPDATED_BY

      , LAST_UPDATE_DATE

      , LAST_UPDATE_LOGIN

      , OBJECT_VERSION_NUMBER

      )

   VALUES

      ( IEC_O_VALIDATION_HISTORY_S.NEXTVAL

      , p_list_id

      , g_status

      , g_start_time

      , g_end_time

      , g_encoded_message

      , l_user_id

      , SYSDATE

      , l_user_id

      , SYSDATE

      , l_login_id

      , 1

      );



   -- We can assume that FND_MESSAGE has been initialized b/c

   -- Set_ValidationHistoryDetails creates a message if message

   -- hasn't already been created

   IF g_status = 'FAILED_VALIDATION' THEN

      IEC_OCS_LOG_PVT.Log_Message(g_module);

   END IF;



   COMMIT;

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Insert_ValidationHistoryRec'

         , 'MAIN'

         , SQLERRM);

END Insert_ValidationHistoryRec;



PROCEDURE Validate_List

   ( p_list_id         IN            NUMBER

   , x_return_code        OUT NOCOPY VARCHAR2)   -- OUT

IS



   l_campaign_id NUMBER(15);

   l_campaign_schedule_id NUMBER(15);

   l_source_type_view VARCHAR2(32);

   l_list_entry_csr ListEntryCsrType;


   l_record_invalid NUMBER := 0;

   l_valid_count NUMBER := 0;

   l_total_count NUMBER := 0;



BEGIN



   x_return_code := FND_API.G_RET_STS_SUCCESS;



   -- Setup logging information

   Init_LoggingVariables;

   Disable_FndLogging;

   Set_MessagePrefix('validate_list_' || p_list_id);



   Update_Status(p_list_id, 'VALIDATING');



   Validate_List_Pre( p_list_id

                    , 'Y'       -- enable use of validation rules

                    , l_campaign_id

                    , l_campaign_schedule_id

                    , l_source_type_view

                    );



   -- Check to see if all entries are assigned to the list's source type

   IF NOT Verify_EntrySourceTypes(p_list_id) THEN

      RAISE fnd_api.g_exc_error;

   END IF;



   -- Validate records that have at least one invalid contact point that have not been

   -- marked as do not use for some reason other than failed validation

   -- also look for updated records

   -- FIX: NULL is placeholder for contact point purpose when it is added to the source type views

   BEGIN

      OPEN l_list_entry_csr FOR

           'SELECT A.LIST_ENTRY_ID, A.POSTAL_CODE, A.DO_NOT_USE_FLAG, A.DO_NOT_USE_REASON, A.NEWLY_UPDATED_FLAG, B.SUBSET_ID, B.ITM_CC_TZ_ID, B.CONTACT_POINT_INDEX,

            A.CONTACT_POINT_ID_S1, A.TIME_ZONE_S1, A.PHONE_COUNTRY_CODE_S1, A.PHONE_AREA_CODE_S1, A.PHONE_NUMBER_S1, A.RAW_PHONE_NUMBER_S1, A.REASON_CODE_S1, A.PHONE_LINE_TYPE_S1, NULL,

            A.CONTACT_POINT_ID_S2, A.TIME_ZONE_S2, A.PHONE_COUNTRY_CODE_S2, A.PHONE_AREA_CODE_S2, A.PHONE_NUMBER_S2, A.RAW_PHONE_NUMBER_S2, A.REASON_CODE_S2, A.PHONE_LINE_TYPE_S2, NULL,

            A.CONTACT_POINT_ID_S3, A.TIME_ZONE_S3, A.PHONE_COUNTRY_CODE_S3, A.PHONE_AREA_CODE_S3, A.PHONE_NUMBER_S3, A.RAW_PHONE_NUMBER_S3, A.REASON_CODE_S3, A.PHONE_LINE_TYPE_S3, NULL,

            A.CONTACT_POINT_ID_S4, A.TIME_ZONE_S4, A.PHONE_COUNTRY_CODE_S4, A.PHONE_AREA_CODE_S4, A.PHONE_NUMBER_S4, A.RAW_PHONE_NUMBER_S4, A.REASON_CODE_S4, A.PHONE_LINE_TYPE_S4, NULL,

            A.CONTACT_POINT_ID_S5, A.TIME_ZONE_S5, A.PHONE_COUNTRY_CODE_S5, A.PHONE_AREA_CODE_S5, A.PHONE_NUMBER_S5, A.RAW_PHONE_NUMBER_S5, A.REASON_CODE_S5, A.PHONE_LINE_TYPE_S5, NULL,

            A.CONTACT_POINT_ID_S6, A.TIME_ZONE_S6, A.PHONE_COUNTRY_CODE_S6, A.PHONE_AREA_CODE_S6, A.PHONE_NUMBER_S6, A.RAW_PHONE_NUMBER_S6, A.REASON_CODE_S6, A.PHONE_LINE_TYPE_S6, NULL

            FROM ' || l_source_type_view || ' A, IEC_G_RETURN_ENTRIES B

            WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID(+)

            AND A.LIST_ENTRY_ID = B.LIST_ENTRY_ID(+)

            AND A.LIST_HEADER_ID = :list_id

            AND A.ENABLED_FLAG = ''Y''

            AND (((

                    ((A.PHONE_NUMBER_S1 IS NOT NULL OR A.RAW_PHONE_NUMBER_S1 IS NOT NULL) AND A.REASON_CODE_S1 IS NULL)

                    OR

                    ((A.PHONE_NUMBER_S2 IS NOT NULL OR A.RAW_PHONE_NUMBER_S2 IS NOT NULL) AND A.REASON_CODE_S2 IS NULL)

                    OR

                    ((A.PHONE_NUMBER_S3 IS NOT NULL OR A.RAW_PHONE_NUMBER_S3 IS NOT NULL) AND A.REASON_CODE_S3 IS NULL)

                    OR

                    ((A.PHONE_NUMBER_S4 IS NOT NULL OR A.RAW_PHONE_NUMBER_S4 IS NOT NULL) AND A.REASON_CODE_S4 IS NULL)

                    OR

                    ((A.PHONE_NUMBER_S5 IS NOT NULL OR A.RAW_PHONE_NUMBER_S5 IS NOT NULL) AND A.REASON_CODE_S5 IS NULL)

                    OR

                    ((A.PHONE_NUMBER_S6 IS NOT NULL OR A.RAW_PHONE_NUMBER_S6 IS NOT NULL) AND A.REASON_CODE_S6 IS NULL)

                   )

                AND (A.DO_NOT_USE_FLAG = ''N'' OR A.DO_NOT_USE_FLAG IS NULL OR A.DO_NOT_USE_REASON = 4)

                 )

                OR A.NEWLY_UPDATED_FLAG = ''Y''

                )'

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

         IF SQLCODE = -904 THEN

            Log_MissingSourceTypeColumns(p_list_id, l_source_type_view, Get_SourceType(p_list_id), 'VALIDATE_LIST', 'SELECT_ENTRIES_FOR_VALIDATION');

            RAISE fnd_api.g_exc_error;

         ELSE

            RAISE;

         END IF;

   END;



   Validate_List_Pvt( p_list_id

                    , l_campaign_schedule_id

                    , l_campaign_id

                    , l_source_type_view

                    , l_list_entry_csr

                    , 'Y' -- commit each batch

                    );



   CLOSE l_list_entry_csr;



   Remove_DeletedRecords(p_list_id, l_campaign_schedule_id);

   COMMIT;



   Validate_List_Post(p_list_id);



   Update_Status(p_list_id, 'VALIDATED');

-- fix bug 4260294 by Jean Zhu

/*   SELECT (RECORD_VALID_ALL_CPS + RECORD_VALID_SOME_CPS)

        , (RECORD_VALID_ALL_CPS + RECORD_VALID_SOME_CPS + RECORD_INVALID)

   INTO l_valid_count

      , l_total_count

   FROM IEC_G_REP_LIST_DETAILS_V

   WHERE LIST_HEADER_ID = p_list_id; */

   SELECT COUNT(*) RECORDS_INVALID
	into l_record_invalid
	FROM IEC_O_VALIDATION_REPORT_DETS
	WHERE ( DO_NOT_USE_REASON_S1 IS NOT NULL AND
		DO_NOT_USE_REASON_S2 IS NOT NULL AND
		DO_NOT_USE_REASON_S3 IS NOT NULL AND
		DO_NOT_USE_REASON_S4 IS NOT NULL AND
		DO_NOT_USE_REASON_S5 IS NOT NULL AND
		DO_NOT_USE_REASON_S6 IS NOT NULL ) AND
	 	LIST_HEADER_ID = p_list_id;

  SELECT SUM(NVL(A.RECORD_LOADED, 0))
	into l_valid_count
	FROM IEC_G_REP_SUBSET_COUNTS A,
	     IEC_G_LIST_SUBSETS D
	where A.SUBSET_ID = D.LIST_SUBSET_ID AND
		D.LIST_HEADER_ID = p_list_id AND D.STATUS_CODE <> 'DELETED';


   l_total_count := l_valid_count + l_record_invalid;

   Log_ValidationSuccess('VALIDATE_LIST', 'MAIN', l_total_count, l_valid_count);

   Insert_ValidationHistoryRec(p_list_id);



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      x_return_code := FND_API.G_RET_STS_ERROR;

      ROLLBACK;

      Validate_List_Post(p_list_id);

      Update_Status(p_list_id, 'FAILED_VALIDATION');

      Insert_ValidationHistoryRec(p_list_id);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_code := FND_API.G_RET_STS_ERROR;

      ROLLBACK;

      Validate_List_Post(p_list_id);

      Update_Status(p_list_id, 'FAILED_VALIDATION');

      Insert_ValidationHistoryRec(p_list_id);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN OTHERS THEN

      Log( 'Validate_List'

         , 'MAIN'

         , SQLERRM

         );

      x_return_code := FND_API.G_RET_STS_ERROR;

      ROLLBACK;

      Validate_List_Post(p_list_id);

      Update_Status(p_list_id, 'FAILED_VALIDATION');

      Insert_ValidationHistoryRec(p_list_id);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

END Validate_List;



PROCEDURE Copy_AmsListEntries

   ( p_from_list_entry_id_col  IN            SYSTEM.number_tbl_type

   , p_from_list_id_col        IN            SYSTEM.number_tbl_type

   , x_to_list_entry_id_col       OUT NOCOPY SYSTEM.number_tbl_type   -- OUT

   , p_to_list_id              IN            NUMBER)
IS
    l_api_version     CONSTANT NUMBER   := 1.0;
    l_init_msg_list		VARCHAR2(1);
    l_return_status		VARCHAR2(1);
    l_msg_count			  NUMBER;
    l_msg_data			  VARCHAR2(2000);
    l_listentry_rec AMS_LISTENTRY_PVT.entry_rec_type;
BEGIN
    l_init_msg_list		:=FND_API.G_TRUE;

    x_to_list_entry_id_col := SYSTEM.number_tbl_type();

    x_to_list_entry_id_col.EXTEND(p_from_list_entry_id_col.COUNT);

    FOR i IN 1..x_to_list_entry_id_col.COUNT

    LOOP
      SELECT  SYSDATE, LAST_UPDATED_BY, SYSDATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER

       , LIST_SELECT_ACTION_ID, ARC_LIST_SELECT_ACTION_FROM, LIST_SELECT_ACTION_FROM_NAME, SOURCE_CODE, ARC_LIST_USED_BY_SOURCE, SOURCE_CODE_FOR_ID

       , PIN_CODE, LIST_ENTRY_SOURCE_SYSTEM_ID, LIST_ENTRY_SOURCE_SYSTEM_TYPE, VIEW_APPLICATION_ID, MANUALLY_ENTERED_FLAG

       , MARKED_AS_DUPLICATE_FLAG, MARKED_AS_RANDOM_FLAG, PART_OF_CONTROL_GROUP_FLAG, EXCLUDE_IN_TRIGGERED_LIST_FLAG, ENABLED_FLAG, CELL_CODE, DEDUPE_KEY

       , RANDOMLY_GENERATED_NUMBER, CAMPAIGN_ID, MEDIA_ID, CHANNEL_ID, CHANNEL_SCHEDULE_ID, EVENT_OFFER_ID, CUSTOMER_ID, MARKET_SEGMENT_ID

       , PARTY_ID, PARENT_PARTY_ID, VENDOR_ID, TRANSFER_FLAG, TRANSFER_STATUS, LIST_SOURCE, DUPLICATE_MASTER_ENTRY_ID, MARKED_FLAG, LEAD_ID, LETTER_ID

       , PICKING_HEADER_ID, BATCH_ID, SUFFIX, FIRST_NAME, LAST_NAME, CUSTOMER_NAME, TITLE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIPCODE, COUNTRY, FAX, PHONE, EMAIL_ADDRESS

       , COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8, COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16, COL17, COL18

       , COL19, COL20, COL21, COL22, COL23, COL24, COL25, COL26, COL27, COL28, COL29, COL30, COL31, COL32, COL33, COL34, COL35

       , COL36, COL37, COL38, COL39, COL40, COL41, COL42, COL43, COL44, COL45, COL46, COL47, COL48, COL49, COL50, COL51, COL52

       , COL53, COL54, COL55, COL56, COL57, COL58, COL59, COL60, COL61, COL62, COL63, COL64, COL65, COL66, COL67, COL68, COL69

       , COL70, COL71, COL72, COL73, COL74, COL75, COL76, COL77, COL78, COL79, COL80, COL81, COL82, COL83, COL84, COL85, COL86

       , COL87, COL88, COL89, COL90, COL91, COL92, COL93, COL94, COL95, COL96, COL97, COL98, COL99, COL100, COL101, COL102, COL103

       , COL104, COL105, COL106, COL107, COL108, COL109, COL110, COL111, COL112, COL113, COL114, COL115, COL116, COL117, COL118, COL119

       , COL120, COL121, COL122, COL123, COL124, COL125, COL126, COL127, COL128, COL129, COL130, COL131, COL132, COL133, COL134, COL135

       , COL136, COL137, COL138, COL139, COL140, COL141, COL142, COL143, COL144, COL145, COL146, COL147, COL148, COL149, COL150, COL151

       , COL152, COL153, COL154, COL155, COL156, COL157, COL158, COL159, COL160, COL161, COL162, COL163, COL164, COL165, COL166, COL167

       , COL168, COL169, COL170, COL171, COL172, COL173, COL174, COL175, COL176, COL177, COL178, COL179, COL180, COL181, COL182, COL183

       , COL184, COL185, COL186, COL187, COL188, COL189, COL190, COL191, COL192, COL193, COL194, COL195, COL196, COL197, COL198, COL199

       , COL200, COL201, COL202, COL203, COL204, COL205, COL206, COL207, COL208, COL209, COL210, COL211, COL212, COL213, COL214, COL215

       , COL216, COL217, COL218, COL219, COL220, COL221, COL222, COL223, COL224, COL225, COL226, COL227, COL228, COL229, COL230, COL231

       , COL232, COL233, COL234, COL235, COL236, COL237, COL238, COL239, COL240, COL241, COL242, COL243, COL244, COL245, COL246, COL247

       , COL248, COL249, COL250, IMP_SOURCE_LINE_ID, USAGE_RESTRICTION, COL251, COL252, COL253, COL254, COL255, COL256, COL257, COL258

       , COL259, COL260, COL261, COL262, COL263, COL264, COL265, COL266, COL267, COL268, COL269, COL270, COL271, COL272, COL273, COL274

       , COL275, COL276, COL277, COL278, COL279, COL280, COL281, COL282, COL283, COL284, COL285, COL286, COL287, COL288, COL289, COL290

       , COL291, COL292, COL293, COL294, COL295, COL296, COL297, COL298, COL299, COL300 INTO

       l_listentry_rec.LAST_UPDATE_DATE, l_listentry_rec.LAST_UPDATED_BY, l_listentry_rec.CREATION_DATE, l_listentry_rec.CREATED_BY, l_listentry_rec.LAST_UPDATE_LOGIN

       , l_listentry_rec.OBJECT_VERSION_NUMBER, l_listentry_rec.LIST_SELECT_ACTION_ID, l_listentry_rec.ARC_LIST_SELECT_ACTION_FROM, l_listentry_rec.LIST_SELECT_ACTION_FROM_NAME

       , l_listentry_rec.SOURCE_CODE, l_listentry_rec.ARC_LIST_USED_BY_SOURCE, l_listentry_rec.SOURCE_CODE_FOR_ID, l_listentry_rec.PIN_CODE

       , l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID, l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE, l_listentry_rec.VIEW_APPLICATION_ID, l_listentry_rec.MANUALLY_ENTERED_FLAG

       , l_listentry_rec.MARKED_AS_DUPLICATE_FLAG, l_listentry_rec.MARKED_AS_RANDOM_FLAG, l_listentry_rec.PART_OF_CONTROL_GROUP_FLAG,l_listentry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG

       , l_listentry_rec.ENABLED_FLAG, l_listentry_rec.CELL_CODE, l_listentry_rec.DEDUPE_KEY, l_listentry_rec.RANDOMLY_GENERATED_NUMBER, l_listentry_rec.CAMPAIGN_ID

       , l_listentry_rec.MEDIA_ID, l_listentry_rec.CHANNEL_ID, l_listentry_rec.CHANNEL_SCHEDULE_ID, l_listentry_rec.EVENT_OFFER_ID, l_listentry_rec.CUSTOMER_ID

       , l_listentry_rec.MARKET_SEGMENT_ID, l_listentry_rec.PARTY_ID, l_listentry_rec.PARENT_PARTY_ID, l_listentry_rec.VENDOR_ID, l_listentry_rec.TRANSFER_FLAG

       , l_listentry_rec.TRANSFER_STATUS, l_listentry_rec.LIST_SOURCE, l_listentry_rec.DUPLICATE_MASTER_ENTRY_ID, l_listentry_rec.MARKED_FLAG, l_listentry_rec.LEAD_ID

       , l_listentry_rec.LETTER_ID, l_listentry_rec.PICKING_HEADER_ID, l_listentry_rec.BATCH_ID, l_listentry_rec.SUFFIX, l_listentry_rec.FIRST_NAME, l_listentry_rec.LAST_NAME

       , l_listentry_rec.CUSTOMER_NAME, l_listentry_rec.TITLE, l_listentry_rec.ADDRESS_LINE1, l_listentry_rec.ADDRESS_LINE2, l_listentry_rec.CITY, l_listentry_rec.STATE

       , l_listentry_rec.ZIPCODE, l_listentry_rec.COUNTRY, l_listentry_rec.FAX, l_listentry_rec.PHONE, l_listentry_rec.EMAIL_ADDRESS

       , l_listentry_rec.COL1, l_listentry_rec.COL2, l_listentry_rec.COL3, l_listentry_rec.COL4, l_listentry_rec.COL5, l_listentry_rec.COL6, l_listentry_rec.COL7

       , l_listentry_rec.COL8,l_listentry_rec.COL9, l_listentry_rec.COL10, l_listentry_rec.COL11, l_listentry_rec.COL12, l_listentry_rec.COL13, l_listentry_rec.COL14

       , l_listentry_rec.COL15, l_listentry_rec.COL16, l_listentry_rec.COL17, l_listentry_rec.COL18, l_listentry_rec.COL19, l_listentry_rec.COL20, l_listentry_rec.COL21

       , l_listentry_rec.COL22, l_listentry_rec.COL23, l_listentry_rec.COL24, l_listentry_rec.COL25, l_listentry_rec.COL26, l_listentry_rec.COL27, l_listentry_rec.COL28

       , l_listentry_rec.COL29, l_listentry_rec.COL30, l_listentry_rec.COL31, l_listentry_rec.COL32, l_listentry_rec.COL33, l_listentry_rec.COL34, l_listentry_rec.COL35

       , l_listentry_rec.COL36, l_listentry_rec.COL37, l_listentry_rec.COL38, l_listentry_rec.COL39, l_listentry_rec.COL40, l_listentry_rec.COL41, l_listentry_rec.COL42

       , l_listentry_rec.COL43, l_listentry_rec.COL44, l_listentry_rec.COL45, l_listentry_rec.COL46, l_listentry_rec.COL47, l_listentry_rec.COL48, l_listentry_rec.COL49

       , l_listentry_rec.COL50, l_listentry_rec.COL51, l_listentry_rec.COL52, l_listentry_rec.COL53, l_listentry_rec.COL54, l_listentry_rec.COL55, l_listentry_rec.COL56

       , l_listentry_rec.COL57, l_listentry_rec.COL58, l_listentry_rec.COL59, l_listentry_rec.COL60, l_listentry_rec.COL61, l_listentry_rec.COL62, l_listentry_rec.COL63

       , l_listentry_rec.COL64, l_listentry_rec.COL65, l_listentry_rec.COL66, l_listentry_rec.COL67, l_listentry_rec.COL68, l_listentry_rec.COL69, l_listentry_rec.COL70

       , l_listentry_rec.COL71, l_listentry_rec.COL72, l_listentry_rec.COL73, l_listentry_rec.COL74, l_listentry_rec.COL75, l_listentry_rec.COL76, l_listentry_rec.COL77

       , l_listentry_rec.COL78, l_listentry_rec.COL79, l_listentry_rec.COL80, l_listentry_rec.COL81, l_listentry_rec.COL82, l_listentry_rec.COL83, l_listentry_rec.COL84

       , l_listentry_rec.COL85, l_listentry_rec.COL86, l_listentry_rec.COL87, l_listentry_rec.COL88, l_listentry_rec.COL89, l_listentry_rec.COL90, l_listentry_rec.COL91

       , l_listentry_rec.COL92, l_listentry_rec.COL93, l_listentry_rec.COL94, l_listentry_rec.COL95, l_listentry_rec.COL96, l_listentry_rec.COL97, l_listentry_rec.COL98

       , l_listentry_rec.COL99, l_listentry_rec.COL100, l_listentry_rec.COL101, l_listentry_rec.COL102, l_listentry_rec.COL103, l_listentry_rec.COL104, l_listentry_rec.COL105

       , l_listentry_rec.COL106, l_listentry_rec.COL107, l_listentry_rec.COL108, l_listentry_rec.COL109, l_listentry_rec.COL110, l_listentry_rec.COL111, l_listentry_rec.COL112

       , l_listentry_rec.COL113, l_listentry_rec.COL114, l_listentry_rec.COL115, l_listentry_rec.COL116, l_listentry_rec.COL117, l_listentry_rec.COL118, l_listentry_rec.COL119

       , l_listentry_rec.COL120, l_listentry_rec.COL121, l_listentry_rec.COL122, l_listentry_rec.COL123, l_listentry_rec.COL124, l_listentry_rec.COL125, l_listentry_rec.COL126

       , l_listentry_rec.COL127, l_listentry_rec.COL128, l_listentry_rec.COL129, l_listentry_rec.COL130, l_listentry_rec.COL131, l_listentry_rec.COL132, l_listentry_rec.COL133

       , l_listentry_rec.COL134, l_listentry_rec.COL135, l_listentry_rec.COL136, l_listentry_rec.COL137, l_listentry_rec.COL138, l_listentry_rec.COL139, l_listentry_rec.COL140

       , l_listentry_rec.COL141, l_listentry_rec.COL142, l_listentry_rec.COL143, l_listentry_rec.COL144, l_listentry_rec.COL145, l_listentry_rec.COL146, l_listentry_rec.COL147

       , l_listentry_rec.COL148, l_listentry_rec.COL149, l_listentry_rec.COL150, l_listentry_rec.COL151, l_listentry_rec.COL152, l_listentry_rec.COL153, l_listentry_rec.COL154

       , l_listentry_rec.COL155, l_listentry_rec.COL156, l_listentry_rec.COL157, l_listentry_rec.COL158, l_listentry_rec.COL159, l_listentry_rec.COL160, l_listentry_rec.COL161

       , l_listentry_rec.COL162, l_listentry_rec.COL163, l_listentry_rec.COL164, l_listentry_rec.COL165, l_listentry_rec.COL166, l_listentry_rec.COL167, l_listentry_rec.COL168

       , l_listentry_rec.COL169, l_listentry_rec.COL170, l_listentry_rec.COL171, l_listentry_rec.COL172, l_listentry_rec.COL173, l_listentry_rec.COL174, l_listentry_rec.COL175

       , l_listentry_rec.COL176, l_listentry_rec.COL177, l_listentry_rec.COL178, l_listentry_rec.COL179, l_listentry_rec.COL180, l_listentry_rec.COL181, l_listentry_rec.COL182

       , l_listentry_rec.COL183, l_listentry_rec.COL184, l_listentry_rec.COL185, l_listentry_rec.COL186, l_listentry_rec.COL187, l_listentry_rec.COL188, l_listentry_rec.COL189

       , l_listentry_rec.COL190, l_listentry_rec.COL191, l_listentry_rec.COL192, l_listentry_rec.COL193, l_listentry_rec.COL194, l_listentry_rec.COL195, l_listentry_rec.COL196

       , l_listentry_rec.COL197, l_listentry_rec.COL198, l_listentry_rec.COL199, l_listentry_rec.COL200, l_listentry_rec.COL201, l_listentry_rec.COL202, l_listentry_rec.COL203

       , l_listentry_rec.COL204, l_listentry_rec.COL205, l_listentry_rec.COL206, l_listentry_rec.COL207, l_listentry_rec.COL208, l_listentry_rec.COL209, l_listentry_rec.COL210

       , l_listentry_rec.COL211, l_listentry_rec.COL212, l_listentry_rec.COL213, l_listentry_rec.COL214, l_listentry_rec.COL215, l_listentry_rec.COL216, l_listentry_rec.COL217

       , l_listentry_rec.COL218, l_listentry_rec.COL219, l_listentry_rec.COL220, l_listentry_rec.COL221, l_listentry_rec.COL222, l_listentry_rec.COL223, l_listentry_rec.COL224

       , l_listentry_rec.COL225, l_listentry_rec.COL226, l_listentry_rec.COL227, l_listentry_rec.COL228, l_listentry_rec.COL229, l_listentry_rec.COL230, l_listentry_rec.COL231

       , l_listentry_rec.COL232, l_listentry_rec.COL233, l_listentry_rec.COL234, l_listentry_rec.COL235, l_listentry_rec.COL236, l_listentry_rec.COL237, l_listentry_rec.COL238

       , l_listentry_rec.COL239, l_listentry_rec.COL240, l_listentry_rec.COL241, l_listentry_rec.COL242, l_listentry_rec.COL243, l_listentry_rec.COL244, l_listentry_rec.COL245

       , l_listentry_rec.COL246, l_listentry_rec.COL247, l_listentry_rec.COL248, l_listentry_rec.COL249, l_listentry_rec.COL250, l_listentry_rec.IMP_SOURCE_LINE_ID

       , l_listentry_rec.USAGE_RESTRICTION, l_listentry_rec.COL251, l_listentry_rec.COL252, l_listentry_rec.COL253, l_listentry_rec.COL254, l_listentry_rec.COL255, l_listentry_rec.COL256

       , l_listentry_rec.COL257, l_listentry_rec.COL258, l_listentry_rec.COL259, l_listentry_rec.COL260, l_listentry_rec.COL261, l_listentry_rec.COL262, l_listentry_rec.COL263

       , l_listentry_rec.COL264, l_listentry_rec.COL265, l_listentry_rec.COL266, l_listentry_rec.COL267, l_listentry_rec.COL268, l_listentry_rec.COL269, l_listentry_rec.COL270

       , l_listentry_rec.COL271, l_listentry_rec.COL272, l_listentry_rec.COL273, l_listentry_rec.COL274, l_listentry_rec.COL275, l_listentry_rec.COL276, l_listentry_rec.COL277

       , l_listentry_rec.COL278, l_listentry_rec.COL279, l_listentry_rec.COL280, l_listentry_rec.COL281, l_listentry_rec.COL282, l_listentry_rec.COL283, l_listentry_rec.COL284

       , l_listentry_rec.COL285, l_listentry_rec.COL286, l_listentry_rec.COL287, l_listentry_rec.COL288, l_listentry_rec.COL289, l_listentry_rec.COL290, l_listentry_rec.COL291

       , l_listentry_rec.COL292, l_listentry_rec.COL293, l_listentry_rec.COL294, l_listentry_rec.COL295, l_listentry_rec.COL296, l_listentry_rec.COL297, l_listentry_rec.COL298

       , l_listentry_rec.COL299, l_listentry_rec.COL300

       FROM AMS_LIST_ENTRIES

       WHERE LIST_HEADER_ID = p_from_list_id_col(i) AND LIST_ENTRY_ID = p_from_list_entry_id_col(i);

       l_listentry_rec.list_header_id := p_to_list_id;

       AMS_LISTENTRY_PUB.create_listentry(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_entry_rec => l_listentry_rec,
        x_entry_id => x_to_list_entry_id_col(i) );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          Log_msg('AMS_LISTENTRY_PUB.create_listentry', l_msg_data);
        END IF;
    END LOOP;
 /*
   FOR i IN 1..x_to_list_entry_id_col.COUNT

   LOOP

      EXECUTE IMMEDIATE

         'SELECT AMS_LIST_ENTRIES_S.NEXTVAL FROM DUAL'

      INTO x_to_list_entry_id_col(i);

   END LOOP;



   EXECUTE IMMEDIATE

      'BEGIN

       FORALL i IN :first .. :last

       INSERT INTO AMS_LIST_ENTRIES

       ( LIST_ENTRY_ID, LIST_HEADER_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER

       , LIST_SELECT_ACTION_ID, ARC_LIST_SELECT_ACTION_FROM, LIST_SELECT_ACTION_FROM_NAME, SOURCE_CODE, ARC_LIST_USED_BY_SOURCE, SOURCE_CODE_FOR_ID

       , PIN_CODE, LIST_ENTRY_SOURCE_SYSTEM_ID, LIST_ENTRY_SOURCE_SYSTEM_TYPE, VIEW_APPLICATION_ID, MANUALLY_ENTERED_FLAG

       , MARKED_AS_DUPLICATE_FLAG, MARKED_AS_RANDOM_FLAG, PART_OF_CONTROL_GROUP_FLAG, EXCLUDE_IN_TRIGGERED_LIST_FLAG, ENABLED_FLAG, CELL_CODE, DEDUPE_KEY

       , RANDOMLY_GENERATED_NUMBER, CAMPAIGN_ID, MEDIA_ID, CHANNEL_ID, CHANNEL_SCHEDULE_ID, EVENT_OFFER_ID, CUSTOMER_ID, MARKET_SEGMENT_ID

       , PARTY_ID, PARENT_PARTY_ID, VENDOR_ID, TRANSFER_FLAG, TRANSFER_STATUS, LIST_SOURCE, DUPLICATE_MASTER_ENTRY_ID, MARKED_FLAG, LEAD_ID, LETTER_ID

       , PICKING_HEADER_ID, BATCH_ID, SUFFIX, FIRST_NAME, LAST_NAME, CUSTOMER_NAME, TITLE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIPCODE, COUNTRY, FAX, PHONE, EMAIL_ADDRESS

       , COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8, COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16, COL17, COL18

       , COL19, COL20, COL21, COL22, COL23, COL24, COL25, COL26, COL27, COL28, COL29, COL30, COL31, COL32, COL33, COL34, COL35

       , COL36, COL37, COL38, COL39, COL40, COL41, COL42, COL43, COL44, COL45, COL46, COL47, COL48, COL49, COL50, COL51, COL52

       , COL53, COL54, COL55, COL56, COL57, COL58, COL59, COL60, COL61, COL62, COL63, COL64, COL65, COL66, COL67, COL68, COL69

       , COL70, COL71, COL72, COL73, COL74, COL75, COL76, COL77, COL78, COL79, COL80, COL81, COL82, COL83, COL84, COL85, COL86

       , COL87, COL88, COL89, COL90, COL91, COL92, COL93, COL94, COL95, COL96, COL97, COL98, COL99, COL100, COL101, COL102, COL103

       , COL104, COL105, COL106, COL107, COL108, COL109, COL110, COL111, COL112, COL113, COL114, COL115, COL116, COL117, COL118, COL119

       , COL120, COL121, COL122, COL123, COL124, COL125, COL126, COL127, COL128, COL129, COL130, COL131, COL132, COL133, COL134, COL135

       , COL136, COL137, COL138, COL139, COL140, COL141, COL142, COL143, COL144, COL145, COL146, COL147, COL148, COL149, COL150, COL151

       , COL152, COL153, COL154, COL155, COL156, COL157, COL158, COL159, COL160, COL161, COL162, COL163, COL164, COL165, COL166, COL167

       , COL168, COL169, COL170, COL171, COL172, COL173, COL174, COL175, COL176, COL177, COL178, COL179, COL180, COL181, COL182, COL183

       , COL184, COL185, COL186, COL187, COL188, COL189, COL190, COL191, COL192, COL193, COL194, COL195, COL196, COL197, COL198, COL199

       , COL200, COL201, COL202, COL203, COL204, COL205, COL206, COL207, COL208, COL209, COL210, COL211, COL212, COL213, COL214, COL215

       , COL216, COL217, COL218, COL219, COL220, COL221, COL222, COL223, COL224, COL225, COL226, COL227, COL228, COL229, COL230, COL231

       , COL232, COL233, COL234, COL235, COL236, COL237, COL238, COL239, COL240, COL241, COL242, COL243, COL244, COL245, COL246, COL247

       , COL248, COL249, COL250, IMP_SOURCE_LINE_ID, USAGE_RESTRICTION, COL251, COL252, COL253, COL254, COL255, COL256, COL257, COL258

       , COL259, COL260, COL261, COL262, COL263, COL264, COL265, COL266, COL267, COL268, COL269, COL270, COL271, COL272, COL273, COL274

       , COL275, COL276, COL277, COL278, COL279, COL280, COL281, COL282, COL283, COL284, COL285, COL286, COL287, COL288, COL289, COL290

       , COL291, COL292, COL293, COL294, COL295, COL296, COL297, COL298, COL299, COL300

       )

       (SELECT

         :new_list_entry_id(i), :to_list_id, SYSDATE, LAST_UPDATED_BY, SYSDATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER

       , LIST_SELECT_ACTION_ID, ARC_LIST_SELECT_ACTION_FROM, LIST_SELECT_ACTION_FROM_NAME, SOURCE_CODE, ARC_LIST_USED_BY_SOURCE, SOURCE_CODE_FOR_ID

       , PIN_CODE, LIST_ENTRY_SOURCE_SYSTEM_ID, LIST_ENTRY_SOURCE_SYSTEM_TYPE, VIEW_APPLICATION_ID, MANUALLY_ENTERED_FLAG

       , MARKED_AS_DUPLICATE_FLAG, MARKED_AS_RANDOM_FLAG, PART_OF_CONTROL_GROUP_FLAG, EXCLUDE_IN_TRIGGERED_LIST_FLAG, ENABLED_FLAG, CELL_CODE, DEDUPE_KEY

       , RANDOMLY_GENERATED_NUMBER, CAMPAIGN_ID, MEDIA_ID, CHANNEL_ID, CHANNEL_SCHEDULE_ID, EVENT_OFFER_ID, CUSTOMER_ID, MARKET_SEGMENT_ID

       , PARTY_ID, PARENT_PARTY_ID, VENDOR_ID, TRANSFER_FLAG, TRANSFER_STATUS, LIST_SOURCE, DUPLICATE_MASTER_ENTRY_ID, MARKED_FLAG, LEAD_ID, LETTER_ID

       , PICKING_HEADER_ID, BATCH_ID, SUFFIX, FIRST_NAME, LAST_NAME, CUSTOMER_NAME, TITLE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIPCODE, COUNTRY, FAX, PHONE, EMAIL_ADDRESS

       , COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8, COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16, COL17, COL18

       , COL19, COL20, COL21, COL22, COL23, COL24, COL25, COL26, COL27, COL28, COL29, COL30, COL31, COL32, COL33, COL34, COL35

       , COL36, COL37, COL38, COL39, COL40, COL41, COL42, COL43, COL44, COL45, COL46, COL47, COL48, COL49, COL50, COL51, COL52

       , COL53, COL54, COL55, COL56, COL57, COL58, COL59, COL60, COL61, COL62, COL63, COL64, COL65, COL66, COL67, COL68, COL69

       , COL70, COL71, COL72, COL73, COL74, COL75, COL76, COL77, COL78, COL79, COL80, COL81, COL82, COL83, COL84, COL85, COL86

       , COL87, COL88, COL89, COL90, COL91, COL92, COL93, COL94, COL95, COL96, COL97, COL98, COL99, COL100, COL101, COL102, COL103

       , COL104, COL105, COL106, COL107, COL108, COL109, COL110, COL111, COL112, COL113, COL114, COL115, COL116, COL117, COL118, COL119

       , COL120, COL121, COL122, COL123, COL124, COL125, COL126, COL127, COL128, COL129, COL130, COL131, COL132, COL133, COL134, COL135

       , COL136, COL137, COL138, COL139, COL140, COL141, COL142, COL143, COL144, COL145, COL146, COL147, COL148, COL149, COL150, COL151

       , COL152, COL153, COL154, COL155, COL156, COL157, COL158, COL159, COL160, COL161, COL162, COL163, COL164, COL165, COL166, COL167

       , COL168, COL169, COL170, COL171, COL172, COL173, COL174, COL175, COL176, COL177, COL178, COL179, COL180, COL181, COL182, COL183

       , COL184, COL185, COL186, COL187, COL188, COL189, COL190, COL191, COL192, COL193, COL194, COL195, COL196, COL197, COL198, COL199

       , COL200, COL201, COL202, COL203, COL204, COL205, COL206, COL207, COL208, COL209, COL210, COL211, COL212, COL213, COL214, COL215

       , COL216, COL217, COL218, COL219, COL220, COL221, COL222, COL223, COL224, COL225, COL226, COL227, COL228, COL229, COL230, COL231

       , COL232, COL233, COL234, COL235, COL236, COL237, COL238, COL239, COL240, COL241, COL242, COL243, COL244, COL245, COL246, COL247

       , COL248, COL249, COL250, IMP_SOURCE_LINE_ID, USAGE_RESTRICTION, COL251, COL252, COL253, COL254, COL255, COL256, COL257, COL258

       , COL259, COL260, COL261, COL262, COL263, COL264, COL265, COL266, COL267, COL268, COL269, COL270, COL271, COL272, COL273, COL274

       , COL275, COL276, COL277, COL278, COL279, COL280, COL281, COL282, COL283, COL284, COL285, COL286, COL287, COL288, COL289, COL290

       , COL291, COL292, COL293, COL294, COL295, COL296, COL297, COL298, COL299, COL300

       FROM AMS_LIST_ENTRIES

       WHERE LIST_HEADER_ID = :list_id_col(i) AND LIST_ENTRY_ID = :list_entry_id_col(i));

       END;'

   USING IN p_from_list_entry_id_col.FIRST

       , IN p_from_list_entry_id_col.LAST

       , IN x_to_list_entry_id_col

       , IN p_to_list_id

       , IN p_from_list_id_col

       , IN p_from_list_entry_id_col;

*/

   Update_AmsListHeaderCounts( p_to_list_id

                             , x_to_list_entry_id_col.COUNT

                             , x_to_list_entry_id_col.COUNT

                             );

EXCEPTION

   WHEN OTHERS THEN

      x_to_list_entry_id_col := NULL;

      Log( 'Copy_AmsListEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Copy_AmsListEntries;





PROCEDURE Mark_EntriesDoNotUse

   ( p_returns_id_col  IN            SYSTEM.number_tbl_type

   , x_returns_id_col     OUT NOCOPY SYSTEM.number_tbl_type

   , x_list_entry_id_col  OUT NOCOPY SYSTEM.number_tbl_type

   , x_list_id_col        OUT NOCOPY SYSTEM.number_tbl_type

   )

IS

   l_callable_zone_id_col SYSTEM.number_tbl_type;

   l_do_not_use_col       SYSTEM.varchar_tbl_type;

   l_decr_count_col       SYSTEM.number_tbl_type;

BEGIN



   x_returns_id_col := SYSTEM.number_tbl_type();

   x_list_entry_id_col := SYSTEM.number_tbl_type();

   x_list_id_col := SYSTEM.number_tbl_type();

   l_callable_zone_id_col := SYSTEM.number_tbl_type();

   l_do_not_use_col := SYSTEM.varchar_tbl_type();

   l_decr_count_col := SYSTEM.number_tbl_type();



   -- Get all records that need to be marked as dnu

   -- Need to do this prior to updating them as dnu so that we

   -- can retrieve the previous dnu status - don't want to decrement

   -- callable zone counts if was already marked as dnu

   EXECUTE IMMEDIATE

      'BEGIN

       SELECT RETURNS_ID, LIST_ENTRY_ID, LIST_HEADER_ID, ITM_CC_TZ_ID, DO_NOT_USE_FLAG

       BULK COLLECT INTO :returns_id_col, :list_entry_id_col, :list_id_col, :callable_zone_id_col, :do_not_use_col

       FROM IEC_G_RETURN_ENTRIES

       WHERE RETURNS_ID IN (SELECT * FROM TABLE(CAST(:p_returns_id_col AS SYSTEM.NUMBER_TBL_TYPE)));

       END;'

   USING OUT x_returns_id_col

       , OUT x_list_entry_id_col

       , OUT x_list_id_col

       , OUT l_callable_zone_id_col

       , OUT l_do_not_use_col

       , IN p_returns_id_col;



   IF x_returns_id_col IS NOT NULL AND x_returns_id_col.COUNT > 0 THEN



      EXECUTE IMMEDIATE

         'BEGIN

          FORALL i IN :first .. :last

             UPDATE IEC_G_RETURN_ENTRIES A

             SET A.DO_NOT_USE_FLAG = ''Y''

               , A.DO_NOT_USE_REASON = 5

             WHERE A.RETURNS_ID = :returns_id(i);

          END;'

      USING IN x_returns_id_col.FIRST

          , IN x_returns_id_col.LAST

          , IN x_returns_id_col;



      FOR i IN 1..l_do_not_use_col.LAST LOOP

         l_decr_count_col.EXTEND;

         IF l_do_not_use_col(i) = 'N' THEN

            l_decr_count_col(i) := -1;

         ELSE

            l_decr_count_col(i) := 0;

         END IF;

      END LOOP;



      Incr_CallableZoneCounts( l_callable_zone_id_col

                             , l_decr_count_col);



   END IF;



END Mark_EntriesDoNotUse;



PROCEDURE Mark_EntriesDoNotUse

   ( p_returns_id_col    IN            SYSTEM.number_tbl_type

   , p_to_list_id        IN            NUMBER

   , x_returns_id_col       OUT NOCOPY SYSTEM.number_tbl_type   -- OUT

   , x_list_entry_id_col    OUT NOCOPY SYSTEM.number_tbl_type   -- OUT

   , x_list_id_col          OUT NOCOPY SYSTEM.number_tbl_type)  -- OUT

IS

   l_temp_returns_id_col SYSTEM.number_tbl_type;

BEGIN



   -- Get all records that need to be marked as dnu

   -- Excludes for all duplicate party ids

   EXECUTE IMMEDIATE

      'BEGIN

       SELECT A.RETURNS_ID

       BULK COLLECT INTO :returns_id_col

       FROM IEC_G_RETURN_ENTRIES A

       WHERE A.RETURNS_ID IN (SELECT * FROM TABLE(CAST(:p_returns_id_col AS SYSTEM.NUMBER_TBL_TYPE)))

       AND A.LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID

                               FROM AMS_LIST_ENTRIES

                               WHERE A.LIST_HEADER_ID = LIST_HEADER_ID

                               AND A.LIST_ENTRY_ID = LIST_ENTRY_ID

                               AND PARTY_ID NOT IN (SELECT PARTY_ID FROM AMS_LIST_ENTRIES WHERE LIST_HEADER_ID = :to_list_id));

       END;'

   USING OUT l_temp_returns_id_col

       , IN p_returns_id_col

       , IN p_to_list_id;



   IF l_temp_returns_id_col IS NOT NULL AND l_temp_returns_id_col.COUNT > 0 THEN

      Mark_EntriesDoNotUse

         ( l_temp_returns_id_col

         , x_returns_id_col

         , x_list_entry_id_col

         , x_list_id_col

         );

   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Mark_EntriesDoNotUse'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Mark_EntriesDoNotUse;



PROCEDURE Move_CallHistory

   ( p_from_returns_id_col    IN  SYSTEM.number_tbl_type

   , p_to_list_entry_id_col   IN  SYSTEM.number_tbl_type

   , p_to_list_id             IN  NUMBER)

IS



   l_new_returns_id_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();



   l_cp_index_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

   l_cp_postfix_col SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();

   l_callback_flag_col SYSTEM.varchar_tbl_type := SYSTEM.varchar_tbl_type();

   l_next_call_time_col SYSTEM.date_tbl_type := SYSTEM.date_tbl_type();



BEGIN



   l_cp_index_col.EXTEND(p_from_returns_id_col.COUNT);

   l_cp_postfix_col.EXTEND(p_from_returns_id_col.COUNT);

   l_callback_flag_col.EXTEND(p_from_returns_id_col.COUNT);

   l_next_call_time_col.EXTEND(p_from_returns_id_col.COUNT);



   IF p_from_returns_id_col IS NOT NULL AND p_from_returns_id_col.COUNT > 0 THEN



      FOR i IN 1..p_from_returns_id_col.COUNT

      LOOP

         EXECUTE IMMEDIATE

            'SELECT CALLBACK_FLAG

                  , NEXT_CALL_TIME

                  , CONTACT_POINT_INDEX

                  , DECODE(CONTACT_POINT_INDEX, 1, ''_S1''

                                              , 2, ''_S2''

                                              , 3, ''_S3''

                                              , 4, ''_S4''

                                              , 5, ''_S5''

                                              , 6, ''_S6''

                                                 , ''_S1'')

             FROM IEC_G_RETURN_ENTRIES

             WHERE RETURNS_ID = :returns_id'

         INTO l_callback_flag_col(i)

            , l_next_call_time_col(i)

            , l_cp_index_col(i)

            , l_cp_postfix_col(i)

         USING p_from_returns_id_col(i);

      END LOOP;



      l_new_returns_id_col.EXTEND(p_to_list_entry_id_col.COUNT);

      FOR i IN 1..p_to_list_entry_id_col.COUNT

      LOOP

         EXECUTE IMMEDIATE

            'UPDATE IEC_G_RETURN_ENTRIES

             SET CALLBACK_FLAG = :callback_flag

               , NEXT_CALL_TIME = :next_call_time

               , ( CONTACT_POINT_ID

                 , ITM_CC_TZ_ID

                 , CONTACT_POINT_INDEX

                 , COUNTRY_CODE

                 , AREA_CODE

                 , PHONE_NUMBER

                 , RAW_PHONE_NUMBER

                 , TIME_ZONE ) =

                 (SELECT CONTACT_POINT_ID' || l_cp_postfix_col(i) || '

                       , MKTG_ITEM_CC_TZS_ID' || l_cp_postfix_col(i) || '

                       , :cp_index

                       , PHONE_COUNTRY_CODE' || l_cp_postfix_col(i) || '

                       , PHONE_AREA_CODE' || l_cp_postfix_col(i) || '

                       , PHONE_NUMBER' || l_cp_postfix_col(i) || '

                       , RAW_PHONE_NUMBER' || l_cp_postfix_col(i) || '

                       , TIME_ZONE' || l_cp_postfix_col(i) || '

                  FROM IEC_VAL_ENTRY_CACHE

                  WHERE LIST_ENTRY_ID = :list_entry_id)

             WHERE  LIST_HEADER_ID = :to_list_id AND LIST_ENTRY_ID = :list_entry_id

             RETURNING RETURNS_ID INTO :returns_id'

         USING IN l_callback_flag_col(i)

             , IN l_next_call_time_col(i)

             , IN l_cp_index_col(i)

             , IN p_to_list_entry_id_col(i)

             , IN p_to_list_id

             , IN p_to_list_entry_id_col(i)

             , OUT l_new_returns_id_col(i);

      END LOOP;



      -- Delete call history on destination list

      -- so that it can be replaced by call history

      -- from source list

      EXECUTE IMMEDIATE

         'BEGIN

          FORALL i IN :first .. :last

             DELETE IEC_O_RCY_CALL_HISTORIES

             WHERE RETURNS_ID = :new_returns_id(i);

          END;'

      USING IN l_new_returns_id_col.FIRST

          , IN l_new_returns_id_col.LAST

          , IN l_new_returns_id_col;



      -- Move call history from source list to destination list

      EXECUTE IMMEDIATE

         'BEGIN

          FORALL i IN :first .. :last

             UPDATE IEC_O_RCY_CALL_HISTORIES

             SET RETURNS_ID = :new_returns_id(i)

             WHERE RETURNS_ID = :old_returns_id(i);

          END;'

      USING IN l_new_returns_id_col.FIRST

          , IN l_new_returns_id_col.LAST

          , IN l_new_returns_id_col

          , IN p_from_returns_id_col;



   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Move_CallHistory'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Move_CallHistory;



-- Loads a collection of new/recycled entries into AO system

PROCEDURE Load_Entries_Pvt

   ( p_list_entry_id_col     IN SYSTEM.number_tbl_type

   , p_list_id               IN NUMBER

   , p_enable_val_rules_flag IN VARCHAR2

   )

IS

   l_list_entry_csr       ListEntryCsrType;



   l_campaign_id          NUMBER(15);

   l_campaign_schedule_id NUMBER(15);

   l_source_type_view     VARCHAR2(32);



BEGIN



   Validate_List_Pre( p_list_id

                    , p_enable_val_rules_flag

                    , l_campaign_id

                    , l_campaign_schedule_id

                    , l_source_type_view

                    );



   -- FIX: NULL is placeholder for contact point purpose when it is added to the source type views

   BEGIN

      OPEN l_list_entry_csr FOR

           'SELECT A.LIST_ENTRY_ID, A.POSTAL_CODE, A.DO_NOT_USE_FLAG, A.DO_NOT_USE_REASON, A.NEWLY_UPDATED_FLAG, B.SUBSET_ID, B.ITM_CC_TZ_ID, B.CONTACT_POINT_INDEX,

            A.CONTACT_POINT_ID_S1, A.TIME_ZONE_S1, A.PHONE_COUNTRY_CODE_S1, A.PHONE_AREA_CODE_S1, A.PHONE_NUMBER_S1, A.RAW_PHONE_NUMBER_S1, A.REASON_CODE_S1, A.PHONE_LINE_TYPE_S1, NULL,

            A.CONTACT_POINT_ID_S2, A.TIME_ZONE_S2, A.PHONE_COUNTRY_CODE_S2, A.PHONE_AREA_CODE_S2, A.PHONE_NUMBER_S2, A.RAW_PHONE_NUMBER_S2, A.REASON_CODE_S2, A.PHONE_LINE_TYPE_S2, NULL,

            A.CONTACT_POINT_ID_S3, A.TIME_ZONE_S3, A.PHONE_COUNTRY_CODE_S3, A.PHONE_AREA_CODE_S3, A.PHONE_NUMBER_S3, A.RAW_PHONE_NUMBER_S3, A.REASON_CODE_S3, A.PHONE_LINE_TYPE_S3, NULL,

            A.CONTACT_POINT_ID_S4, A.TIME_ZONE_S4, A.PHONE_COUNTRY_CODE_S4, A.PHONE_AREA_CODE_S4, A.PHONE_NUMBER_S4, A.RAW_PHONE_NUMBER_S4, A.REASON_CODE_S4, A.PHONE_LINE_TYPE_S4, NULL,

            A.CONTACT_POINT_ID_S5, A.TIME_ZONE_S5, A.PHONE_COUNTRY_CODE_S5, A.PHONE_AREA_CODE_S5, A.PHONE_NUMBER_S5, A.RAW_PHONE_NUMBER_S5, A.REASON_CODE_S5, A.PHONE_LINE_TYPE_S5, NULL,

            A.CONTACT_POINT_ID_S6, A.TIME_ZONE_S6, A.PHONE_COUNTRY_CODE_S6, A.PHONE_AREA_CODE_S6, A.PHONE_NUMBER_S6, A.RAW_PHONE_NUMBER_S6, A.REASON_CODE_S6, A.PHONE_LINE_TYPE_S6, NULL

            FROM ' || l_source_type_view || ' A, IEC_G_RETURN_ENTRIES B

            WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID(+)

            AND A.LIST_ENTRY_ID = B.LIST_ENTRY_ID(+)

            AND A.LIST_HEADER_ID = :list_id

            AND A.LIST_ENTRY_ID IN (SELECT * FROM TABLE(CAST(:list_entry_id_col AS SYSTEM.NUMBER_TBL_TYPE)))'
      USING p_list_id, p_list_entry_id_col;
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -904 THEN
            Log_MissingSourceTypeColumns(p_list_id, l_source_type_view, Get_SourceType(p_list_id), 'LOAD_ENTRIES_PVT', 'SELECT_ENTRIES_FOR_LOAD');
            RAISE fnd_api.g_exc_error;
         ELSE
            RAISE;
         END IF;
   END;



   Validate_List_Pvt( p_list_id

                    , l_campaign_schedule_id

                    , l_campaign_id

                    , l_source_type_view

                    , l_list_entry_csr

                    , 'N' -- do not commit each batch (handled by calling program)

                    );



   CLOSE l_list_entry_csr;



   Validate_List_Post(p_list_id);



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Load_Entries_Pvt'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Load_Entries_Pvt;



PROCEDURE Update_DuplicateEntries

   ( p_from_list_id    IN            NUMBER

   , p_to_list_id      IN            NUMBER

   , p_mark_do_not_use IN            BOOLEAN

   , x_records_updated    OUT NOCOPY NUMBER

   )

IS
   l_to_list_entry_id_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type(0);
   l_from_returns_id_col SYSTEM.number_tbl_type;
   l_ignore1 SYSTEM.number_tbl_type;
   l_ignore2 SYSTEM.number_tbl_type;
   l_ignore3 SYSTEM.number_tbl_type;
   l_num  NUMBER := 1;

   Cursor c_listentryrec IS
      SELECT B.list_entry_id, B.list_header_id, A.LAST_UPDATE_DATE, A.LAST_UPDATED_BY, A.CREATION_DATE, A.CREATED_BY, A.LAST_UPDATE_LOGIN, A.OBJECT_VERSION_NUMBER

       , A.LIST_SELECT_ACTION_ID, A.ARC_LIST_SELECT_ACTION_FROM, A.LIST_SELECT_ACTION_FROM_NAME, A.SOURCE_CODE, A.ARC_LIST_USED_BY_SOURCE, A.SOURCE_CODE_FOR_ID

       , A.PIN_CODE, A.LIST_ENTRY_SOURCE_SYSTEM_ID, A.LIST_ENTRY_SOURCE_SYSTEM_TYPE, A.VIEW_APPLICATION_ID, A.MANUALLY_ENTERED_FLAG

       , A.MARKED_AS_DUPLICATE_FLAG, A.MARKED_AS_RANDOM_FLAG, A.PART_OF_CONTROL_GROUP_FLAG, A.EXCLUDE_IN_TRIGGERED_LIST_FLAG, A.ENABLED_FLAG, A.CELL_CODE, A.DEDUPE_KEY

       , A.RANDOMLY_GENERATED_NUMBER, A.CAMPAIGN_ID, A.MEDIA_ID, A.CHANNEL_ID, A.CHANNEL_SCHEDULE_ID, A.EVENT_OFFER_ID, A.CUSTOMER_ID, A.MARKET_SEGMENT_ID

       , A.PARTY_ID, A.PARENT_PARTY_ID, A.VENDOR_ID, A.TRANSFER_FLAG, A.TRANSFER_STATUS, A.LIST_SOURCE, A.DUPLICATE_MASTER_ENTRY_ID, A.MARKED_FLAG, A.LEAD_ID, A.LETTER_ID

       , A.PICKING_HEADER_ID, A.BATCH_ID, A.SUFFIX, A.FIRST_NAME, A.LAST_NAME, A.CUSTOMER_NAME, A.TITLE, A.ADDRESS_LINE1, A.ADDRESS_LINE2, A.CITY, A.STATE, A.ZIPCODE

       , A.COUNTRY, A.FAX, A.PHONE, A.EMAIL_ADDRESS

       , A.COL1, A.COL2, A.COL3, A.COL4, A.COL5, A.COL6, A.COL7, A.COL8, A.COL9, A.COL10, A.COL11, A.COL12, A.COL13, A.COL14, A.COL15, A.COL16, A.COL17, A.COL18

       , A.COL19, A.COL20, A.COL21, A.COL22, A.COL23, A.COL24, A.COL25, A.COL26, A.COL27, A.COL28, A.COL29, A.COL30, A.COL31, A.COL32, A.COL33, A.COL34, A.COL35

       , A.COL36, A.COL37, A.COL38, A.COL39, A.COL40, A.COL41, A.COL42, A.COL43, A.COL44, A.COL45, A.COL46, A.COL47, A.COL48, A.COL49, A.COL50, A.COL51, A.COL52

       , A.COL53, A.COL54, A.COL55, A.COL56, A.COL57, A.COL58, A.COL59, A.COL60, A.COL61, A.COL62, A.COL63, A.COL64, A.COL65, A.COL66, A.COL67, A.COL68, A.COL69

       , A.COL70, A.COL71, A.COL72, A.COL73, A.COL74, A.COL75, A.COL76, A.COL77, A.COL78, A.COL79, A.COL80, A.COL81, A.COL82, A.COL83, A.COL84, A.COL85, A.COL86

       , A.COL87, A.COL88, A.COL89, A.COL90, A.COL91, A.COL92, A.COL93, A.COL94, A.COL95, A.COL96, A.COL97, A.COL98, A.COL99, A.COL100, A.COL101, A.COL102, A.COL103

       , A.COL104, A.COL105, A.COL106, A.COL107, A.COL108, A.COL109, A.COL110, A.COL111, A.COL112, A.COL113, A.COL114, A.COL115, A.COL116, A.COL117, A.COL118, A.COL119

       , A.COL120, A.COL121, A.COL122, A.COL123, A.COL124, A.COL125, A.COL126, A.COL127, A.COL128, A.COL129, A.COL130, A.COL131, A.COL132, A.COL133, A.COL134, A.COL135

       , A.COL136, A.COL137, A.COL138, A.COL139, A.COL140, A.COL141, A.COL142, A.COL143, A.COL144, A.COL145, A.COL146, A.COL147, A.COL148, A.COL149, A.COL150, A.COL151

       , A.COL152, A.COL153, A.COL154, A.COL155, A.COL156, A.COL157, A.COL158, A.COL159, A.COL160, A.COL161, A.COL162, A.COL163, A.COL164, A.COL165, A.COL166, A.COL167

       , A.COL168, A.COL169, A.COL170, A.COL171, A.COL172, A.COL173, A.COL174, A.COL175, A.COL176, A.COL177, A.COL178, A.COL179, A.COL180, A.COL181, A.COL182, A.COL183

       , A.COL184, A.COL185, A.COL186, A.COL187, A.COL188, A.COL189, A.COL190, A.COL191, A.COL192, A.COL193, A.COL194, A.COL195, A.COL196, A.COL197, A.COL198, A.COL199

       , A.COL200, A.COL201, A.COL202, A.COL203, A.COL204, A.COL205, A.COL206, A.COL207, A.COL208, A.COL209, A.COL210, A.COL211, A.COL212, A.COL213, A.COL214, A.COL215

       , A.COL216, A.COL217, A.COL218, A.COL219, A.COL220, A.COL221, A.COL222, A.COL223, A.COL224, A.COL225, A.COL226, A.COL227, A.COL228, A.COL229, A.COL230, A.COL231

       , A.COL232, A.COL233, A.COL234, A.COL235, A.COL236, A.COL237, A.COL238, A.COL239, A.COL240, A.COL241, A.COL242, A.COL243, A.COL244, A.COL245, A.COL246, A.COL247

       , A.COL248, A.COL249, A.COL250, A.IMP_SOURCE_LINE_ID, A.USAGE_RESTRICTION, A.COL251, A.COL252, A.COL253, A.COL254, A.COL255, A.COL256, A.COL257, A.COL258

       , A.COL259, A.COL260, A.COL261, A.COL262, A.COL263, A.COL264, A.COL265, A.COL266, A.COL267, A.COL268, A.COL269, A.COL270, A.COL271, A.COL272, A.COL273, A.COL274

       , A.COL275, A.COL276, A.COL277, A.COL278, A.COL279, A.COL280, A.COL281, A.COL282, A.COL283, A.COL284, A.COL285, A.COL286, A.COL287, A.COL288, A.COL289, A.COL290

       , A.COL291, A.COL292, A.COL293, A.COL294, A.COL295, A.COL296, A.COL297, A.COL298, A.COL299, A.COL300, A.NEWLY_UPDATED_FLAG

         FROM AMS_LIST_ENTRIES A, AMS_LIST_ENTRIES B

         WHERE A.LIST_HEADER_ID = p_from_list_id AND B.LIST_HEADER_ID = p_to_list_id AND A.PARTY_ID = B.PARTY_ID AND A.ENABLED_FLAG = 'Y' AND B.ENABLED_FLAG = 'Y';

    l_api_version     CONSTANT NUMBER   := 1.0;
    l_init_msg_list		VARCHAR2(1);
    l_return_status		VARCHAR2(1);
    l_msg_count			  NUMBER;
    l_msg_data			  VARCHAR2(2000);
    l_listentry_rec AMS_LISTENTRY_PVT.entry_rec_type;
BEGIN
    l_init_msg_list		:=FND_API.G_TRUE;

   -- Update duplicate records in ams list entries

   -- From Source List to Destination List
    FOR v_listentryrec IN c_listentryrec LOOP
      l_to_list_entry_id_col(l_num) := v_listentryrec.list_entry_id;

      l_listentry_rec.list_entry_id := v_listentryrec.list_entry_id;
      l_listentry_rec.list_header_id := v_listentryrec.list_header_id;
      l_listentry_rec.last_update_date := v_listentryrec.last_update_date;
      l_listentry_rec.last_updated_by := v_listentryrec.last_updated_by;
      l_listentry_rec.creation_date := v_listentryrec.creation_date;
      l_listentry_rec.created_by := v_listentryrec.created_by;
      l_listentry_rec.last_update_login := v_listentryrec.last_update_login;
      l_listentry_rec.object_version_number := v_listentryrec.object_version_number;
      l_listentry_rec.list_select_action_id := v_listentryrec.list_select_action_id;
      l_listentry_rec.arc_list_select_action_from := v_listentryrec.arc_list_select_action_from;
      l_listentry_rec.list_select_action_from_name := v_listentryrec.list_select_action_from_name;
      l_listentry_rec.source_code := v_listentryrec.source_code;
      l_listentry_rec.arc_list_used_by_source := v_listentryrec.arc_list_used_by_source;
      l_listentry_rec.source_code_for_id := v_listentryrec.source_code_for_id;
      l_listentry_rec.pin_code := v_listentryrec.pin_code;
      l_listentry_rec.list_entry_source_system_id := v_listentryrec.list_entry_source_system_id;
      l_listentry_rec.list_entry_source_system_type := v_listentryrec.list_entry_source_system_type;
      l_listentry_rec.view_application_id := v_listentryrec.view_application_id;
      l_listentry_rec.manually_entered_flag := v_listentryrec.manually_entered_flag;
      l_listentry_rec.marked_as_duplicate_flag := v_listentryrec.marked_as_duplicate_flag;
      l_listentry_rec.marked_as_random_flag := v_listentryrec.marked_as_random_flag;
      l_listentry_rec.part_of_control_group_flag := v_listentryrec.part_of_control_group_flag;
      l_listentry_rec.exclude_in_triggered_list_flag := v_listentryrec.exclude_in_triggered_list_flag;
      l_listentry_rec.enabled_flag := v_listentryrec.enabled_flag;
      l_listentry_rec.cell_code := v_listentryrec.cell_code;
      l_listentry_rec.dedupe_key := v_listentryrec.dedupe_key;
      l_listentry_rec.randomly_generated_number := v_listentryrec.randomly_generated_number;
      l_listentry_rec.campaign_id := v_listentryrec.campaign_id;
      l_listentry_rec.media_id := v_listentryrec.media_id;
      l_listentry_rec.channel_id := v_listentryrec.channel_id;
      l_listentry_rec.channel_schedule_id := v_listentryrec.channel_schedule_id;
      l_listentry_rec.event_offer_id := v_listentryrec.event_offer_id;
      l_listentry_rec.customer_id := v_listentryrec.customer_id;
      l_listentry_rec.market_segment_id := v_listentryrec.market_segment_id;
      l_listentry_rec.vendor_id := v_listentryrec.vendor_id;
      l_listentry_rec.transfer_flag := v_listentryrec.transfer_flag;
      l_listentry_rec.transfer_status := v_listentryrec.transfer_status;
      l_listentry_rec.list_source := v_listentryrec.list_source;
      l_listentry_rec.duplicate_master_entry_id := v_listentryrec.duplicate_master_entry_id;
      l_listentry_rec.marked_flag := v_listentryrec.marked_flag;
      l_listentry_rec.lead_id := v_listentryrec.lead_id;
      l_listentry_rec.letter_id := v_listentryrec.letter_id;
      l_listentry_rec.picking_header_id := v_listentryrec.picking_header_id;
      l_listentry_rec.batch_id := v_listentryrec.batch_id;
      l_listentry_rec.first_name := v_listentryrec.first_name;
      l_listentry_rec.last_name := v_listentryrec.last_name;
      l_listentry_rec.customer_name := v_listentryrec.customer_name;
      l_listentry_rec.col1 := v_listentryrec.col1;
      l_listentry_rec.col2 := v_listentryrec.col2;
      l_listentry_rec.col3 := v_listentryrec.col3;
      l_listentry_rec.col4 := v_listentryrec.col4;
      l_listentry_rec.col5 := v_listentryrec.col5;
      l_listentry_rec.col6 := v_listentryrec.col6;
      l_listentry_rec.col7 := v_listentryrec.col7;
      l_listentry_rec.col8 := v_listentryrec.col8;
      l_listentry_rec.col9 := v_listentryrec.col9;
      l_listentry_rec.col10 := v_listentryrec.col10;
      l_listentry_rec.col11 := v_listentryrec.col11;
      l_listentry_rec.col12 := v_listentryrec.col12;
      l_listentry_rec.col13 := v_listentryrec.col13;
      l_listentry_rec.col14 := v_listentryrec.col14;
      l_listentry_rec.col15 := v_listentryrec.col15;
      l_listentry_rec.col16 := v_listentryrec.col16;
      l_listentry_rec.col17 := v_listentryrec.col17;
      l_listentry_rec.col18 := v_listentryrec.col18;
      l_listentry_rec.col19 := v_listentryrec.col19;
      l_listentry_rec.col20 := v_listentryrec.col20;
      l_listentry_rec.col21 := v_listentryrec.col21;
      l_listentry_rec.col22 := v_listentryrec.col22;
      l_listentry_rec.col23 := v_listentryrec.col23;
      l_listentry_rec.col24 := v_listentryrec.col24;
      l_listentry_rec.col25 := v_listentryrec.col25;
      l_listentry_rec.col26 := v_listentryrec.col26;
      l_listentry_rec.col27 := v_listentryrec.col27;
      l_listentry_rec.col28 := v_listentryrec.col28;
      l_listentry_rec.col29 := v_listentryrec.col29;
      l_listentry_rec.col30 := v_listentryrec.col30;
      l_listentry_rec.col31 := v_listentryrec.col31;
      l_listentry_rec.col32 := v_listentryrec.col32;
      l_listentry_rec.col33 := v_listentryrec.col33;
      l_listentry_rec.col34 := v_listentryrec.col34;
      l_listentry_rec.col35 := v_listentryrec.col35;
      l_listentry_rec.col36 := v_listentryrec.col36;
      l_listentry_rec.col37 := v_listentryrec.col37;
      l_listentry_rec.col38 := v_listentryrec.col38;
      l_listentry_rec.col39 := v_listentryrec.col39;
      l_listentry_rec.col40 := v_listentryrec.col40;
      l_listentry_rec.col41 := v_listentryrec.col41;
      l_listentry_rec.col42 := v_listentryrec.col42;
      l_listentry_rec.col43 := v_listentryrec.col43;
      l_listentry_rec.col44 := v_listentryrec.col44;
      l_listentry_rec.col45 := v_listentryrec.col45;
      l_listentry_rec.col46 := v_listentryrec.col46;
      l_listentry_rec.col47 := v_listentryrec.col47;
      l_listentry_rec.col48 := v_listentryrec.col48;
      l_listentry_rec.col49 := v_listentryrec.col49;
      l_listentry_rec.col50 := v_listentryrec.col50;
      l_listentry_rec.col51 := v_listentryrec.col51;
      l_listentry_rec.col52 := v_listentryrec.col52;
      l_listentry_rec.col53 := v_listentryrec.col53;
      l_listentry_rec.col54 := v_listentryrec.col54;
      l_listentry_rec.col55 := v_listentryrec.col55;
      l_listentry_rec.col56 := v_listentryrec.col56;
      l_listentry_rec.col57 := v_listentryrec.col57;
      l_listentry_rec.col58 := v_listentryrec.col58;
      l_listentry_rec.col59 := v_listentryrec.col59;
      l_listentry_rec.col60 := v_listentryrec.col60;
      l_listentry_rec.col61 := v_listentryrec.col61;
      l_listentry_rec.col62 := v_listentryrec.col62;
      l_listentry_rec.col63 := v_listentryrec.col63;
      l_listentry_rec.col64 := v_listentryrec.col64;
      l_listentry_rec.col65 := v_listentryrec.col65;
      l_listentry_rec.col66 := v_listentryrec.col66;
      l_listentry_rec.col67 := v_listentryrec.col67;
      l_listentry_rec.col68 := v_listentryrec.col68;
      l_listentry_rec.col69 := v_listentryrec.col69;
      l_listentry_rec.col70 := v_listentryrec.col70;
      l_listentry_rec.col71 := v_listentryrec.col71;
      l_listentry_rec.col72 := v_listentryrec.col72;
      l_listentry_rec.col73 := v_listentryrec.col73;
      l_listentry_rec.col74 := v_listentryrec.col74;
      l_listentry_rec.col75 := v_listentryrec.col75;
      l_listentry_rec.col76 := v_listentryrec.col76;
      l_listentry_rec.col77 := v_listentryrec.col77;
      l_listentry_rec.col78 := v_listentryrec.col78;
      l_listentry_rec.col79 := v_listentryrec.col79;
      l_listentry_rec.col80 := v_listentryrec.col80;
      l_listentry_rec.col81 := v_listentryrec.col81;
      l_listentry_rec.col82 := v_listentryrec.col82;
      l_listentry_rec.col83 := v_listentryrec.col83;
      l_listentry_rec.col84 := v_listentryrec.col84;
      l_listentry_rec.col85 := v_listentryrec.col85;
      l_listentry_rec.col86 := v_listentryrec.col86;
      l_listentry_rec.col87 := v_listentryrec.col87;
      l_listentry_rec.col88 := v_listentryrec.col88;
      l_listentry_rec.col89 := v_listentryrec.col89;
      l_listentry_rec.col90 := v_listentryrec.col90;
      l_listentry_rec.col91 := v_listentryrec.col91;
      l_listentry_rec.col92 := v_listentryrec.col92;
      l_listentry_rec.col93 := v_listentryrec.col93;
      l_listentry_rec.col94 := v_listentryrec.col94;
      l_listentry_rec.col95 := v_listentryrec.col95;
      l_listentry_rec.col96 := v_listentryrec.col96;
      l_listentry_rec.col97 := v_listentryrec.col97;
      l_listentry_rec.col98 := v_listentryrec.col98;
      l_listentry_rec.col99 := v_listentryrec.col99;
      l_listentry_rec.col100 := v_listentryrec.col100;
      l_listentry_rec.col101 := v_listentryrec.col101;
      l_listentry_rec.col102 := v_listentryrec.col102;
      l_listentry_rec.col103 := v_listentryrec.col103;
      l_listentry_rec.col104 := v_listentryrec.col104;
      l_listentry_rec.col105 := v_listentryrec.col105;
      l_listentry_rec.col106 := v_listentryrec.col106;
      l_listentry_rec.col107 := v_listentryrec.col107;
      l_listentry_rec.col108 := v_listentryrec.col108;
      l_listentry_rec.col109 := v_listentryrec.col109;
      l_listentry_rec.col110 := v_listentryrec.col110;
      l_listentry_rec.col111 := v_listentryrec.col111;
      l_listentry_rec.col112 := v_listentryrec.col112;
      l_listentry_rec.col113 := v_listentryrec.col113;
      l_listentry_rec.col114 := v_listentryrec.col114;
      l_listentry_rec.col115 := v_listentryrec.col115;
      l_listentry_rec.col116 := v_listentryrec.col116;
      l_listentry_rec.col117 := v_listentryrec.col117;
      l_listentry_rec.col118 := v_listentryrec.col118;
      l_listentry_rec.col119 := v_listentryrec.col119;
      l_listentry_rec.col120 := v_listentryrec.col120;
      l_listentry_rec.col121 := v_listentryrec.col121;
      l_listentry_rec.col122 := v_listentryrec.col122;
      l_listentry_rec.col123 := v_listentryrec.col123;
      l_listentry_rec.col124 := v_listentryrec.col124;
      l_listentry_rec.col125 := v_listentryrec.col125;
      l_listentry_rec.col126 := v_listentryrec.col126;
      l_listentry_rec.col127 := v_listentryrec.col127;
      l_listentry_rec.col128 := v_listentryrec.col128;
      l_listentry_rec.col129 := v_listentryrec.col129;
      l_listentry_rec.col130 := v_listentryrec.col130;
      l_listentry_rec.col131 := v_listentryrec.col131;
      l_listentry_rec.col132 := v_listentryrec.col132;
      l_listentry_rec.col133 := v_listentryrec.col133;
      l_listentry_rec.col134 := v_listentryrec.col134;
      l_listentry_rec.col135 := v_listentryrec.col135;
      l_listentry_rec.col136 := v_listentryrec.col136;
      l_listentry_rec.col137 := v_listentryrec.col137;
      l_listentry_rec.col138 := v_listentryrec.col138;
      l_listentry_rec.col139 := v_listentryrec.col139;
      l_listentry_rec.col140 := v_listentryrec.col140;
      l_listentry_rec.col141 := v_listentryrec.col141;
      l_listentry_rec.col142 := v_listentryrec.col142;
      l_listentry_rec.col143 := v_listentryrec.col143;
      l_listentry_rec.col144 := v_listentryrec.col144;
      l_listentry_rec.col145 := v_listentryrec.col145;
      l_listentry_rec.col146 := v_listentryrec.col146;
      l_listentry_rec.col147 := v_listentryrec.col147;
      l_listentry_rec.col148 := v_listentryrec.col148;
      l_listentry_rec.col149 := v_listentryrec.col149;
      l_listentry_rec.col150 := v_listentryrec.col150;
      l_listentry_rec.col151 := v_listentryrec.col151;
      l_listentry_rec.col152 := v_listentryrec.col152;
      l_listentry_rec.col153 := v_listentryrec.col153;
      l_listentry_rec.col154 := v_listentryrec.col154;
      l_listentry_rec.col155 := v_listentryrec.col155;
      l_listentry_rec.col156 := v_listentryrec.col156;
      l_listentry_rec.col157 := v_listentryrec.col157;
      l_listentry_rec.col158 := v_listentryrec.col158;
      l_listentry_rec.col159 := v_listentryrec.col159;
      l_listentry_rec.col160 := v_listentryrec.col160;
      l_listentry_rec.col161 := v_listentryrec.col161;
      l_listentry_rec.col162 := v_listentryrec.col162;
      l_listentry_rec.col163 := v_listentryrec.col163;
      l_listentry_rec.col164 := v_listentryrec.col164;
      l_listentry_rec.col165 := v_listentryrec.col165;
      l_listentry_rec.col166 := v_listentryrec.col166;
      l_listentry_rec.col167 := v_listentryrec.col167;
      l_listentry_rec.col168 := v_listentryrec.col168;
      l_listentry_rec.col169 := v_listentryrec.col169;
      l_listentry_rec.col170 := v_listentryrec.col170;
      l_listentry_rec.col171 := v_listentryrec.col171;
      l_listentry_rec.col172 := v_listentryrec.col172;
      l_listentry_rec.col173 := v_listentryrec.col173;
      l_listentry_rec.col174 := v_listentryrec.col174;
      l_listentry_rec.col175 := v_listentryrec.col175;
      l_listentry_rec.col176 := v_listentryrec.col176;
      l_listentry_rec.col177 := v_listentryrec.col177;
      l_listentry_rec.col178 := v_listentryrec.col178;
      l_listentry_rec.col179 := v_listentryrec.col179;
      l_listentry_rec.col180 := v_listentryrec.col180;
      l_listentry_rec.col181 := v_listentryrec.col181;
      l_listentry_rec.col182 := v_listentryrec.col182;
      l_listentry_rec.col183 := v_listentryrec.col183;
      l_listentry_rec.col184 := v_listentryrec.col184;
      l_listentry_rec.col185 := v_listentryrec.col185;
      l_listentry_rec.col186 := v_listentryrec.col186;
      l_listentry_rec.col187 := v_listentryrec.col187;
      l_listentry_rec.col188 := v_listentryrec.col188;
      l_listentry_rec.col189 := v_listentryrec.col189;
      l_listentry_rec.col190 := v_listentryrec.col190;
      l_listentry_rec.col191 := v_listentryrec.col191;
      l_listentry_rec.col192 := v_listentryrec.col192;
      l_listentry_rec.col193 := v_listentryrec.col193;
      l_listentry_rec.col194 := v_listentryrec.col194;
      l_listentry_rec.col195 := v_listentryrec.col195;
      l_listentry_rec.col196 := v_listentryrec.col196;
      l_listentry_rec.col197 := v_listentryrec.col197;
      l_listentry_rec.col198 := v_listentryrec.col198;
      l_listentry_rec.col199 := v_listentryrec.col199;
      l_listentry_rec.col200 := v_listentryrec.col200;
      l_listentry_rec.col201 := v_listentryrec.col201;
      l_listentry_rec.col202 := v_listentryrec.col202;
      l_listentry_rec.col203 := v_listentryrec.col203;
      l_listentry_rec.col204 := v_listentryrec.col204;
      l_listentry_rec.col205 := v_listentryrec.col205;
      l_listentry_rec.col206 := v_listentryrec.col206;
      l_listentry_rec.col207 := v_listentryrec.col207;
      l_listentry_rec.col208 := v_listentryrec.col208;
      l_listentry_rec.col209 := v_listentryrec.col209;
      l_listentry_rec.col210 := v_listentryrec.col210;
      l_listentry_rec.col211 := v_listentryrec.col211;
      l_listentry_rec.col212 := v_listentryrec.col212;
      l_listentry_rec.col213 := v_listentryrec.col213;
      l_listentry_rec.col214 := v_listentryrec.col214;
      l_listentry_rec.col215 := v_listentryrec.col215;
      l_listentry_rec.col216 := v_listentryrec.col216;
      l_listentry_rec.col217 := v_listentryrec.col217;
      l_listentry_rec.col218 := v_listentryrec.col218;
      l_listentry_rec.col219 := v_listentryrec.col219;
      l_listentry_rec.col220 := v_listentryrec.col220;
      l_listentry_rec.col221 := v_listentryrec.col221;
      l_listentry_rec.col222 := v_listentryrec.col222;
      l_listentry_rec.col223 := v_listentryrec.col223;
      l_listentry_rec.col224 := v_listentryrec.col224;
      l_listentry_rec.col225 := v_listentryrec.col225;
      l_listentry_rec.col226 := v_listentryrec.col226;
      l_listentry_rec.col227 := v_listentryrec.col227;
      l_listentry_rec.col228 := v_listentryrec.col228;
      l_listentry_rec.col229 := v_listentryrec.col229;
      l_listentry_rec.col230 := v_listentryrec.col230;
      l_listentry_rec.col231 := v_listentryrec.col231;
      l_listentry_rec.col232 := v_listentryrec.col232;
      l_listentry_rec.col233 := v_listentryrec.col233;
      l_listentry_rec.col234 := v_listentryrec.col234;
      l_listentry_rec.col235 := v_listentryrec.col235;
      l_listentry_rec.col236 := v_listentryrec.col236;
      l_listentry_rec.col237 := v_listentryrec.col237;
      l_listentry_rec.col238 := v_listentryrec.col238;
      l_listentry_rec.col239 := v_listentryrec.col239;
      l_listentry_rec.col240 := v_listentryrec.col240;
      l_listentry_rec.col241 := v_listentryrec.col241;
      l_listentry_rec.col242 := v_listentryrec.col242;
      l_listentry_rec.col243 := v_listentryrec.col243;
      l_listentry_rec.col244 := v_listentryrec.col244;
      l_listentry_rec.col245 := v_listentryrec.col245;
      l_listentry_rec.col246 := v_listentryrec.col246;
      l_listentry_rec.col247 := v_listentryrec.col247;
      l_listentry_rec.col248 := v_listentryrec.col248;
      l_listentry_rec.col249 := v_listentryrec.col249;
      l_listentry_rec.col250 := v_listentryrec.col250;
      l_listentry_rec.col251 := v_listentryrec.col251;
      l_listentry_rec.col252 := v_listentryrec.col252;
      l_listentry_rec.col253 := v_listentryrec.col253;
      l_listentry_rec.col254 := v_listentryrec.col254;
      l_listentry_rec.col255 := v_listentryrec.col255;
      l_listentry_rec.col256 := v_listentryrec.col256;
      l_listentry_rec.col257 := v_listentryrec.col257;
      l_listentry_rec.col258 := v_listentryrec.col258;
      l_listentry_rec.col259 := v_listentryrec.col259;
      l_listentry_rec.col260 := v_listentryrec.col260;
      l_listentry_rec.col261 := v_listentryrec.col261;
      l_listentry_rec.col262 := v_listentryrec.col262;
      l_listentry_rec.col263 := v_listentryrec.col263;
      l_listentry_rec.col264 := v_listentryrec.col264;
      l_listentry_rec.col265 := v_listentryrec.col265;
      l_listentry_rec.col266 := v_listentryrec.col266;
      l_listentry_rec.col267 := v_listentryrec.col267;
      l_listentry_rec.col268 := v_listentryrec.col268;
      l_listentry_rec.col269 := v_listentryrec.col269;
      l_listentry_rec.col270 := v_listentryrec.col270;
      l_listentry_rec.col271 := v_listentryrec.col271;
      l_listentry_rec.col272 := v_listentryrec.col272;
      l_listentry_rec.col273 := v_listentryrec.col273;
      l_listentry_rec.col274 := v_listentryrec.col274;
      l_listentry_rec.col275 := v_listentryrec.col275;
      l_listentry_rec.col276 := v_listentryrec.col276;
      l_listentry_rec.col277 := v_listentryrec.col277;
      l_listentry_rec.col278 := v_listentryrec.col278;
      l_listentry_rec.col279 := v_listentryrec.col279;
      l_listentry_rec.col280 := v_listentryrec.col280;
      l_listentry_rec.col281 := v_listentryrec.col281;
      l_listentry_rec.col282 := v_listentryrec.col282;
      l_listentry_rec.col283 := v_listentryrec.col283;
      l_listentry_rec.col284 := v_listentryrec.col284;
      l_listentry_rec.col285 := v_listentryrec.col285;
      l_listentry_rec.col286 := v_listentryrec.col286;
      l_listentry_rec.col287 := v_listentryrec.col287;
      l_listentry_rec.col288 := v_listentryrec.col288;
      l_listentry_rec.col289 := v_listentryrec.col289;
      l_listentry_rec.col290 := v_listentryrec.col290;
      l_listentry_rec.col291 := v_listentryrec.col291;
      l_listentry_rec.col292 := v_listentryrec.col292;
      l_listentry_rec.col293 := v_listentryrec.col293;
      l_listentry_rec.col294 := v_listentryrec.col294;
      l_listentry_rec.col295 := v_listentryrec.col295;
      l_listentry_rec.col296 := v_listentryrec.col296;
      l_listentry_rec.col297 := v_listentryrec.col297;
      l_listentry_rec.col298 := v_listentryrec.col298;
      l_listentry_rec.col299 := v_listentryrec.col299;
      l_listentry_rec.col300 := v_listentryrec.col300;
      l_listentry_rec.address_line1 := v_listentryrec.address_line1;
      l_listentry_rec.address_line2 := v_listentryrec.address_line2;
     	l_listentry_rec.callback_flag := FND_API.g_miss_char;
      l_listentry_rec.city := v_listentryrec.city;
      l_listentry_rec.country := v_listentryrec.country;
      l_listentry_rec.do_not_use_flag := FND_API.g_miss_char;
      l_listentry_rec.do_not_use_reason := FND_API.g_miss_char;
      l_listentry_rec.email_address := v_listentryrec.email_address;
      l_listentry_rec.fax := v_listentryrec.fax;
      l_listentry_rec.phone := v_listentryrec.phone;
      l_listentry_rec.record_out_flag := FND_API.g_miss_char;
      l_listentry_rec.state := v_listentryrec.state;
      l_listentry_rec.suffix := v_listentryrec.suffix;
      l_listentry_rec.title := v_listentryrec.title;
      l_listentry_rec.usage_restriction := FND_API.g_miss_char;
      l_listentry_rec.zipcode := v_listentryrec.zipcode;
      l_listentry_rec.curr_cp_country_code := FND_API.g_miss_char;
      l_listentry_rec.curr_cp_phone_number := FND_API.g_miss_char;
      l_listentry_rec.curr_cp_raw_phone_number := FND_API.g_miss_char;
      l_listentry_rec.curr_cp_area_code := FND_API.g_miss_num;
      l_listentry_rec.curr_cp_id := FND_API.g_miss_num;
      l_listentry_rec.curr_cp_index := FND_API.g_miss_num;
      l_listentry_rec.curr_cp_time_zone := FND_API.g_miss_num;
      l_listentry_rec.curr_cp_time_zone_aux := FND_API.g_miss_num;
      l_listentry_rec.imp_source_line_id := v_listentryrec.imp_source_line_id;
      l_listentry_rec.next_call_time := FND_API.g_miss_date;
      l_listentry_rec.record_release_time := FND_API.g_miss_date;
      l_listentry_rec.party_id := v_listentryrec.party_id;
      l_listentry_rec.parent_party_id := v_listentryrec.parent_party_id;

      AMS_LISTENTRY_PUB.update_listentry(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_entry_rec => l_listentry_rec);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        Log_msg('AMS_LISTENTRY_PUB.update_listentry', l_msg_data);
      END IF;

      UPDATE AMS_LIST_ENTRIES
      SET NEWLY_UPDATED_FLAG = v_listentryrec.NEWLY_UPDATED_FLAG
      WHERE LIST_ENTRY_ID = v_listentryrec.list_entry_id
      AND LIST_HEADER_ID= v_listentryrec.list_header_id;

      l_to_list_entry_id_col.extend(1,1);
      l_num := l_num + 1;

    END LOOP;

/*
       UPDATE AMS_LIST_ENTRIES A

       SET ( LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER

       , LIST_SELECT_ACTION_ID, ARC_LIST_SELECT_ACTION_FROM, LIST_SELECT_ACTION_FROM_NAME, SOURCE_CODE, ARC_LIST_USED_BY_SOURCE, SOURCE_CODE_FOR_ID

       , PIN_CODE, LIST_ENTRY_SOURCE_SYSTEM_ID, LIST_ENTRY_SOURCE_SYSTEM_TYPE, VIEW_APPLICATION_ID, MANUALLY_ENTERED_FLAG

       , MARKED_AS_DUPLICATE_FLAG, MARKED_AS_RANDOM_FLAG, PART_OF_CONTROL_GROUP_FLAG, EXCLUDE_IN_TRIGGERED_LIST_FLAG, ENABLED_FLAG, CELL_CODE, DEDUPE_KEY

       , RANDOMLY_GENERATED_NUMBER, CAMPAIGN_ID, MEDIA_ID, CHANNEL_ID, CHANNEL_SCHEDULE_ID, EVENT_OFFER_ID, CUSTOMER_ID, MARKET_SEGMENT_ID

       , PARTY_ID, PARENT_PARTY_ID, VENDOR_ID, TRANSFER_FLAG, TRANSFER_STATUS, LIST_SOURCE, DUPLICATE_MASTER_ENTRY_ID, MARKED_FLAG, LEAD_ID, LETTER_ID

       , PICKING_HEADER_ID, BATCH_ID, SUFFIX, FIRST_NAME, LAST_NAME, CUSTOMER_NAME, TITLE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIPCODE, COUNTRY, FAX, PHONE, EMAIL_ADDRESS

       , COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8, COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16, COL17, COL18

       , COL19, COL20, COL21, COL22, COL23, COL24, COL25, COL26, COL27, COL28, COL29, COL30, COL31, COL32, COL33, COL34, COL35

       , COL36, COL37, COL38, COL39, COL40, COL41, COL42, COL43, COL44, COL45, COL46, COL47, COL48, COL49, COL50, COL51, COL52

       , COL53, COL54, COL55, COL56, COL57, COL58, COL59, COL60, COL61, COL62, COL63, COL64, COL65, COL66, COL67, COL68, COL69

       , COL70, COL71, COL72, COL73, COL74, COL75, COL76, COL77, COL78, COL79, COL80, COL81, COL82, COL83, COL84, COL85, COL86

       , COL87, COL88, COL89, COL90, COL91, COL92, COL93, COL94, COL95, COL96, COL97, COL98, COL99, COL100, COL101, COL102, COL103

       , COL104, COL105, COL106, COL107, COL108, COL109, COL110, COL111, COL112, COL113, COL114, COL115, COL116, COL117, COL118, COL119

       , COL120, COL121, COL122, COL123, COL124, COL125, COL126, COL127, COL128, COL129, COL130, COL131, COL132, COL133, COL134, COL135

       , COL136, COL137, COL138, COL139, COL140, COL141, COL142, COL143, COL144, COL145, COL146, COL147, COL148, COL149, COL150, COL151

       , COL152, COL153, COL154, COL155, COL156, COL157, COL158, COL159, COL160, COL161, COL162, COL163, COL164, COL165, COL166, COL167

       , COL168, COL169, COL170, COL171, COL172, COL173, COL174, COL175, COL176, COL177, COL178, COL179, COL180, COL181, COL182, COL183

       , COL184, COL185, COL186, COL187, COL188, COL189, COL190, COL191, COL192, COL193, COL194, COL195, COL196, COL197, COL198, COL199

       , COL200, COL201, COL202, COL203, COL204, COL205, COL206, COL207, COL208, COL209, COL210, COL211, COL212, COL213, COL214, COL215

       , COL216, COL217, COL218, COL219, COL220, COL221, COL222, COL223, COL224, COL225, COL226, COL227, COL228, COL229, COL230, COL231

       , COL232, COL233, COL234, COL235, COL236, COL237, COL238, COL239, COL240, COL241, COL242, COL243, COL244, COL245, COL246, COL247

       , COL248, COL249, COL250, IMP_SOURCE_LINE_ID, USAGE_RESTRICTION, COL251, COL252, COL253, COL254, COL255, COL256, COL257, COL258

       , COL259, COL260, COL261, COL262, COL263, COL264, COL265, COL266, COL267, COL268, COL269, COL270, COL271, COL272, COL273, COL274

       , COL275, COL276, COL277, COL278, COL279, COL280, COL281, COL282, COL283, COL284, COL285, COL286, COL287, COL288, COL289, COL290

       , COL291, COL292, COL293, COL294, COL295, COL296, COL297, COL298, COL299, COL300, NEWLY_UPDATED_FLAG

       ) =

       (SELECT

         LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER

       , LIST_SELECT_ACTION_ID, ARC_LIST_SELECT_ACTION_FROM, LIST_SELECT_ACTION_FROM_NAME, SOURCE_CODE, ARC_LIST_USED_BY_SOURCE, SOURCE_CODE_FOR_ID

       , PIN_CODE, LIST_ENTRY_SOURCE_SYSTEM_ID, LIST_ENTRY_SOURCE_SYSTEM_TYPE, VIEW_APPLICATION_ID, MANUALLY_ENTERED_FLAG

       , MARKED_AS_DUPLICATE_FLAG, MARKED_AS_RANDOM_FLAG, PART_OF_CONTROL_GROUP_FLAG, EXCLUDE_IN_TRIGGERED_LIST_FLAG, ENABLED_FLAG, CELL_CODE, DEDUPE_KEY

       , RANDOMLY_GENERATED_NUMBER, CAMPAIGN_ID, MEDIA_ID, CHANNEL_ID, CHANNEL_SCHEDULE_ID, EVENT_OFFER_ID, CUSTOMER_ID, MARKET_SEGMENT_ID

       , PARTY_ID, PARENT_PARTY_ID, VENDOR_ID, TRANSFER_FLAG, TRANSFER_STATUS, LIST_SOURCE, DUPLICATE_MASTER_ENTRY_ID, MARKED_FLAG, LEAD_ID, LETTER_ID

       , PICKING_HEADER_ID, BATCH_ID, SUFFIX, FIRST_NAME, LAST_NAME, CUSTOMER_NAME, TITLE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIPCODE, COUNTRY, FAX, PHONE, EMAIL_ADDRESS

       , COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8, COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16, COL17, COL18

       , COL19, COL20, COL21, COL22, COL23, COL24, COL25, COL26, COL27, COL28, COL29, COL30, COL31, COL32, COL33, COL34, COL35

       , COL36, COL37, COL38, COL39, COL40, COL41, COL42, COL43, COL44, COL45, COL46, COL47, COL48, COL49, COL50, COL51, COL52

       , COL53, COL54, COL55, COL56, COL57, COL58, COL59, COL60, COL61, COL62, COL63, COL64, COL65, COL66, COL67, COL68, COL69

       , COL70, COL71, COL72, COL73, COL74, COL75, COL76, COL77, COL78, COL79, COL80, COL81, COL82, COL83, COL84, COL85, COL86

       , COL87, COL88, COL89, COL90, COL91, COL92, COL93, COL94, COL95, COL96, COL97, COL98, COL99, COL100, COL101, COL102, COL103

       , COL104, COL105, COL106, COL107, COL108, COL109, COL110, COL111, COL112, COL113, COL114, COL115, COL116, COL117, COL118, COL119

       , COL120, COL121, COL122, COL123, COL124, COL125, COL126, COL127, COL128, COL129, COL130, COL131, COL132, COL133, COL134, COL135

       , COL136, COL137, COL138, COL139, COL140, COL141, COL142, COL143, COL144, COL145, COL146, COL147, COL148, COL149, COL150, COL151

       , COL152, COL153, COL154, COL155, COL156, COL157, COL158, COL159, COL160, COL161, COL162, COL163, COL164, COL165, COL166, COL167

       , COL168, COL169, COL170, COL171, COL172, COL173, COL174, COL175, COL176, COL177, COL178, COL179, COL180, COL181, COL182, COL183

       , COL184, COL185, COL186, COL187, COL188, COL189, COL190, COL191, COL192, COL193, COL194, COL195, COL196, COL197, COL198, COL199

       , COL200, COL201, COL202, COL203, COL204, COL205, COL206, COL207, COL208, COL209, COL210, COL211, COL212, COL213, COL214, COL215

       , COL216, COL217, COL218, COL219, COL220, COL221, COL222, COL223, COL224, COL225, COL226, COL227, COL228, COL229, COL230, COL231

       , COL232, COL233, COL234, COL235, COL236, COL237, COL238, COL239, COL240, COL241, COL242, COL243, COL244, COL245, COL246, COL247

       , COL248, COL249, COL250, IMP_SOURCE_LINE_ID, USAGE_RESTRICTION, COL251, COL252, COL253, COL254, COL255, COL256, COL257, COL258

       , COL259, COL260, COL261, COL262, COL263, COL264, COL265, COL266, COL267, COL268, COL269, COL270, COL271, COL272, COL273, COL274

       , COL275, COL276, COL277, COL278, COL279, COL280, COL281, COL282, COL283, COL284, COL285, COL286, COL287, COL288, COL289, COL290

       , COL291, COL292, COL293, COL294, COL295, COL296, COL297, COL298, COL299, COL300, NEWLY_UPDATED_FLAG

         FROM AMS_LIST_ENTRIES

         WHERE LIST_HEADER_ID = p_from_list_id AND PARTY_ID = A.PARTY_ID AND ENABLED_FLAG = 'Y')

       WHERE LIST_HEADER_ID = p_to_list_id

       AND ENABLED_FLAG = 'Y'

       AND PARTY_ID IN (SELECT PARTY_ID

                        FROM AMS_LIST_ENTRIES

                        WHERE LIST_HEADER_ID = p_from_list_id

                        AND ENABLED_FLAG = 'Y')

       RETURNING LIST_ENTRY_ID BULK COLLECT INTO l_to_list_entry_id_col;

*/
   l_to_list_entry_id_col.delete(l_num);
   x_records_updated := l_to_list_entry_id_col.COUNT;


   IF p_mark_do_not_use THEN



      SELECT RETURNS_ID

      BULK COLLECT INTO l_from_returns_id_col

      FROM IEC_G_RETURN_ENTRIES

      WHERE LIST_HEADER_ID = p_from_list_id

      AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID

                            FROM AMS_LIST_ENTRIES

                            WHERE LIST_HEADER_ID = p_from_list_id

                            AND ENABLED_FLAG = 'Y'

                            AND PARTY_ID IN (SELECT PARTY_ID

                                             FROM AMS_LIST_ENTRIES

                                             WHERE LIST_HEADER_ID = p_to_list_id

                                             AND ENABLED_FLAG = 'Y'));


      Mark_EntriesDoNotUse

         ( l_from_returns_id_col

         , l_ignore1

         , l_ignore2

         , l_ignore3

         );


   END IF;


   Load_Entries_Pvt( l_to_list_entry_id_col

                   , p_to_list_id

                   , 'Y'    -- enable validation rules

                   );

EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Update_DuplicateEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_DuplicateEntries;


PROCEDURE Log_DuplicateEntries

   ( p_from_returns_id_col IN SYSTEM.number_tbl_type

   , p_to_list_id          IN NUMBER

   , p_to_schedule_id      IN NUMBER

   , x_duplicate_incr_count    OUT NOCOPY NUMBER

   )

IS

   l_from_returns_id_col    SYSTEM.number_tbl_type;   -- will only contain duplicates

   l_from_list_id_col       SYSTEM.number_tbl_type;

   l_from_list_entry_id_col SYSTEM.number_tbl_type;

   l_from_schedule_id_col   SYSTEM.number_tbl_type;

   l_party_id_col           SYSTEM.number_tbl_type;



   l_error_msg              VARCHAR2(4000);
   l_duplicate_incr_count NUMBER :=0;
BEGIN



   -- Find duplicate record ids in order to log them

   SELECT A.RETURNS_ID, A.LIST_HEADER_ID, A.LIST_ENTRY_ID, A.CAMPAIGN_SCHEDULE_ID, B.PARTY_ID

   BULK COLLECT INTO l_from_returns_id_col, l_from_list_id_col, l_from_list_entry_id_col, l_from_schedule_id_col, l_party_id_col

   FROM IEC_G_RETURN_ENTRIES A, AMS_LIST_ENTRIES B

   WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID

   AND A.LIST_ENTRY_ID = B.LIST_ENTRY_ID

   AND A.RETURNS_ID IN (SELECT * FROM TABLE(CAST(p_from_returns_id_col AS SYSTEM.NUMBER_TBL_TYPE)))

   AND B.PARTY_ID IN (SELECT PARTY_ID FROM AMS_LIST_ENTRIES WHERE LIST_HEADER_ID = p_to_list_id);



   IF l_from_returns_id_col IS NOT NULL AND l_from_returns_id_col.COUNT > 0 THEN

      l_duplicate_incr_count := l_from_returns_id_col.COUNT;

      FOR i IN l_from_returns_id_col.FIRST..l_from_returns_id_col.LAST LOOP

         IEC_OCS_LOG_PVT.LOG_RECYCLE_MV_DUP_REC_STMT

            ( 'Iec_Validate_Pvt'

            , 'Move_RecycledEntries'

            , 'FOUND_DUPLICATE_RECORD'

            , l_from_schedule_id_col(i)

            , l_from_list_id_col(i)

            , l_from_list_entry_id_col(i)

            , l_from_returns_id_col(i)

            , l_party_id_col(i)

            , p_to_schedule_id

            , l_error_msg

            );

      END LOOP;

   END IF;

  x_duplicate_incr_count := l_duplicate_incr_count;

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Log_DuplicateEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Log_DuplicateEntries;




-- Called by Recycling plugin to move recycled entry

PROCEDURE Move_RecycledEntry

   ( p_returns_id            IN  NUMBER

   , p_to_list_id            IN  NUMBER)

IS

   l_returns_id_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

BEGIN

   IF p_returns_id IS NULL OR p_to_list_id IS NULL THEN

      RETURN;

   END IF;



   l_returns_id_col.EXTEND(1);

   l_returns_id_col(1) := p_returns_id;



   Move_RecycledEntries( l_returns_id_col

                       , p_to_list_id);



END Move_RecycledEntry;



-- Called by Recycling plugin to move recycled entries

PROCEDURE Move_RecycledEntries

   ( p_returns_id_col         IN  SYSTEM.number_tbl_type

   , p_to_list_id             IN  NUMBER)

IS

   l_from_returns_id_col    SYSTEM.number_tbl_type;

   l_from_list_entry_id_col SYSTEM.number_tbl_type;

   l_from_list_id_col       SYSTEM.number_tbl_type;

   l_to_list_entry_id_col   SYSTEM.number_tbl_type;

   l_schedule_id  NUMBER(15) := 0;

   l_list_duplicate_incr NUMBER := 0;
BEGIN



   IF p_returns_id_col IS NULL OR p_to_list_id IS NULL THEN

      RETURN;

   END IF;



   -- Log duplicate records

   -- Must do this before move non-duplicate records b/c they will become

   -- duplicates after the move

   SELECT LIST_USED_BY_ID into l_schedule_id FROM AMS_ACT_LISTS
   WHERE LIST_HEADER_ID = p_to_list_id AND LIST_ACT_TYPE = 'TARGET';

   Log_DuplicateEntries

      ( p_returns_id_col

      , p_to_list_id

      , l_schedule_id

      ,l_list_duplicate_incr

      );


    EXECUTE IMMEDIATE

      'UPDATE AMS_LIST_HEADERS_ALL

       SET NO_OF_ROWS_DUPLICATES = NVL(NO_OF_ROWS_DUPLICATES, 0) + :rows_incr

       WHERE LIST_HEADER_ID = :list_id'

   USING IN l_list_duplicate_incr, IN p_to_list_id;

   -- Mark entries as do not use in source list

   -- Retrieve the list_entry_id and list_header_id corresponding to the returns_id

   Mark_EntriesDoNotUse( p_returns_id_col

                       , l_from_returns_id_col

                       , l_from_list_entry_id_col

                       , l_from_list_id_col

                       );



   IF l_from_returns_id_col IS NOT NULL AND l_from_returns_id_col.COUNT > 0 THEN


      Copy_AmsListEntries( l_from_list_entry_id_col

                         , l_from_list_id_col

                         , l_to_list_entry_id_col

                         , p_to_list_id);



      -- Load non-duplicate records into destination list
/*
      Load_Entries_Pvt( l_to_list_entry_id_col

                      , p_to_list_id

                      , 'N'    -- disable validation rules

                      );

*/

      -- Move call history for non-duplicate records
/*
      Move_CallHistory( l_from_returns_id_col

                      , l_to_list_entry_id_col

                      , p_to_list_id);



      Truncate_Temporary_Tables;
*/
   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Move_RecycledEntries;


-- Procedure to be called by public api to move schedule

-- entries

PROCEDURE Move_ScheduleEntries_Pub

   ( p_src_schedule_id  IN            NUMBER

   , p_dest_schedule_id IN            NUMBER

   , p_commit           IN            BOOLEAN

   , x_return_status       OUT NOCOPY VARCHAR2)

IS

   l_src_list_id  NUMBER(15);

   l_dest_list_id NUMBER(15);



   l_call_center_ready_flag VARCHAR2(1);

   l_status_code VARCHAR2(30);

   l_validated_once_flag VARCHAR2(1);



   l_records_updated NUMBER;



   l_returns_id_col         SYSTEM.number_tbl_type;



   l_src_returns_id_col     SYSTEM.number_tbl_type;

   l_src_list_entry_id_col  SYSTEM.number_tbl_type;

   l_src_list_id_col        SYSTEM.number_tbl_type;

   l_dest_list_entry_id_col SYSTEM.number_tbl_type;



   -- Cursor to retrieve non-duplicate records

   CURSOR c1(src_list_id NUMBER, dest_list_id NUMBER) IS

      SELECT B.RETURNS_ID

      FROM IEC_G_RETURN_ENTRIES B

      WHERE B.LIST_HEADER_ID = src_list_id

      AND B.LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID

                              FROM AMS_LIST_ENTRIES

                              WHERE B.LIST_HEADER_ID = LIST_HEADER_ID

                              AND B.LIST_ENTRY_ID = LIST_ENTRY_ID

                              AND PARTY_ID NOT IN (SELECT PARTY_ID

                                                   FROM AMS_LIST_ENTRIES

                                                   WHERE LIST_HEADER_ID = dest_list_id));



BEGIN



   x_return_status := FND_API.G_RET_STS_SUCCESS;



   SAVEPOINT move_entry;



   Init_LoggingVariables;

   Set_MessagePrefix('move_schedule_' || p_src_schedule_id || '_to_' || p_dest_schedule_id);



   IF p_src_schedule_id IS NULL THEN

      Log_CopySrcListNullMsg('Move_ScheduleEntries_Pub','CHECK_SRC_SCHED_NULL', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   IF p_dest_schedule_id IS NULL THEN

      Log_CopyDestListNullMsg('Move_ScheduleEntries_Pub','CHECK_DEST_SCHED_NULL', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   -- get list header ids corresponding to schedule ids

   BEGIN

      IEC_COMMON_UTIL_PVT.Get_ListId(p_src_schedule_id, l_src_list_id);

      IEC_COMMON_UTIL_PVT.Get_ListId(p_dest_schedule_id, l_dest_list_id);

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Move_ScheduleEntries_Pub'

            , 'GET_LIST_HEADER_ID'

            );

   END;



   -- There is no work to be done if source and destination

   -- lists are the same

   IF l_src_list_id = l_dest_list_id THEN

      RETURN;

   END IF;



   -- Perform prerequisite status checks.

   EXECUTE IMMEDIATE

      'SELECT A.CALL_CENTER_READY_FLAG

            , A.STATUS_CODE

            , B.VALIDATED_ONCE_FLAG

       FROM IEC_G_AO_LISTS_V A

            , IEC_O_VALIDATION_STATUS B

       WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID

       AND A.LIST_HEADER_ID = :list_id

       AND LANGUAGE = USERENV(''LANG'')'

   INTO l_call_center_ready_flag

      , l_status_code

      , l_validated_once_flag

   USING l_src_list_id;



   IF l_call_center_ready_flag <> 'Y' THEN

      Log_CopySrcListNotCCRMsg('Move_ScheduleEntries_Pub','CHECK_SRC_SCHED_CCR', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;

   IF l_validated_once_flag <> 'Y' THEN

      Log_CopySrcListNotValMsg('Move_ScheduleEntries_Pub','CHECK_SRC_SCHED_VAL_ONCE', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;

   -- not sure if we can do a move unless the list is stopped

   -- what if record is checked out and we mark it dnu?

   IF l_status_code <> 'ACTIVE' AND

      l_status_code <> 'INACTIVE' AND

      l_status_code <> 'VALIDATED'

   THEN

      Log_CopySrcListInvalidStatMsg('Move_ScheduleEntries_Pub','CHECK_SRC_SCHED_STATUS', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   EXECUTE IMMEDIATE

      'SELECT A.CALL_CENTER_READY_FLAG

            , A.STATUS_CODE

            , B.VALIDATED_ONCE_FLAG

       FROM IEC_G_AO_LISTS_V A

          , IEC_O_VALIDATION_STATUS B

       WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID

       AND A.LIST_HEADER_ID = :list_id

       AND LANGUAGE = USERENV(''LANG'')'

   INTO l_call_center_ready_flag

      , l_status_code

      , l_validated_once_flag

   USING l_dest_list_id;



   IF l_call_center_ready_flag <> 'Y' THEN

      Log_CopyDestListNotCCRMsg('Move_ScheduleEntries_Pub','CHECK_DEST_SCHED_CCR', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;

   IF l_validated_once_flag <> 'Y' THEN

      Log_CopyDestListNotValMsg('Move_ScheduleEntries_Pub','CHECK_DEST_SCHED_VAL_ONCE', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;

   -- maybe want to ensure that list is shut down

   IF l_status_code <> 'ACTIVE' AND

      l_status_code <> 'INACTIVE' AND

      l_status_code <> 'VALIDATED'

   THEN

      Log_CopyDestListInvalidStaMsg('Move_ScheduleEntries_Pub','CHECK_DEST_SCHED_STATUS', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   -- Update duplicate records

   -- Must do this before move non-duplicate records b/c they will become

   -- duplicates after the move

   Update_DuplicateEntries

      ( l_src_list_id

      , l_dest_list_id

      , TRUE            -- p_mark_do_not_use

      , l_records_updated

      );



   -- Fetch non-duplicate records

   OPEN c1(l_src_list_id, l_dest_list_id);

   LOOP

      FETCH c1

      BULK COLLECT INTO l_returns_id_col

      LIMIT g_row_increment;



      EXIT WHEN l_returns_id_col.COUNT = 0;



      IF l_returns_id_col IS NOT NULL AND l_returns_id_col.COUNT > 0 THEN



         -- Mark entries as do not use in source list

         -- Retrieve the list_entry_id and list_header_id corresponding to the returns_id

         -- Excludes duplicate party ids

         Mark_EntriesDoNotUse( l_returns_id_col

                             , l_dest_list_id

                             , l_src_returns_id_col

                             , l_src_list_entry_id_col

                             , l_src_list_id_col

                             );



         IF l_src_returns_id_col IS NOT NULL AND l_src_returns_id_col.COUNT > 0 THEN



            -- Copy non-duplicate records into destination list

            Copy_AmsListEntries( l_src_list_entry_id_col

                               , l_src_list_id_col

                               , l_dest_list_entry_id_col

                               , l_dest_list_id);



            -- Load non-duplicate records into destination list

            Load_Entries_Pvt( l_dest_list_entry_id_col

                            , l_dest_list_id

                            , 'Y'    -- enable validation rules

                            );



            -- Move call history for non-duplicate records

            Move_CallHistory( l_src_returns_id_col

                            , l_dest_list_entry_id_col

                            , l_dest_list_id);



            Truncate_Temporary_Tables;

         END IF;



      END IF;



      IF p_commit THEN

         COMMIT;

      END IF;



      EXIT WHEN l_returns_id_col.COUNT < g_row_increment;



   END LOOP;

   CLOSE c1;



EXCEPTION

   WHEN OTHERS THEN

      FND_MSG_PUB.ADD;

      x_return_status := FND_API.G_RET_STS_ERROR;



END Move_ScheduleEntries_Pub;



PROCEDURE Copy_ScheduleEntries_Pvt

   ( p_from_list_id       IN NUMBER

   , p_from_schedule_id   IN NUMBER

   , p_to_list_id         IN NUMBER

   , p_to_schedule_id     IN NUMBER

   , p_api_initiated      IN BOOLEAN

   , p_commit_flag        IN BOOLEAN)

IS

   l_from_returns_id_col    SYSTEM.number_tbl_type;

   l_from_list_entry_id_col SYSTEM.number_tbl_type;

   l_from_list_id_col       SYSTEM.number_tbl_type;

   l_to_list_entry_id_col   SYSTEM.number_tbl_type;



   l_api_initiated BOOLEAN;



   l_call_center_ready_flag VARCHAR2(1);

   l_status_code VARCHAR2(30);

   l_validated_once_flag VARCHAR2(1);



   l_records_moved   NUMBER := 0;

   l_records_updated NUMBER := 0;



   -- Cursor to retrieve non-duplicate records

   CURSOR c1(from_list_id NUMBER) IS

      SELECT B.RETURNS_ID, B.LIST_ENTRY_ID, B.LIST_HEADER_ID

      FROM IEC_G_RETURN_ENTRIES B

      WHERE B.LIST_HEADER_ID = from_list_id

      AND B.LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID

                              FROM AMS_LIST_ENTRIES

                              WHERE B.LIST_HEADER_ID = LIST_HEADER_ID

                              AND B.LIST_ENTRY_ID = LIST_ENTRY_ID

                              AND PARTY_ID NOT IN (SELECT PARTY_ID

                                                   FROM AMS_LIST_ENTRIES

                                                   WHERE LIST_HEADER_ID = p_to_list_id));



BEGIN



   SAVEPOINT move_entry;



   Init_LoggingVariables;

   Set_MessagePrefix('copy_schedule_' || p_from_schedule_id || '_to_' || p_to_schedule_id);



   -- There is no work to be done if source and destination

   -- lists are the same

   IF p_to_list_id = p_from_list_id THEN

      RETURN;

   END IF;



   IF p_from_list_id IS NULL THEN

      Log_CopySrcListNullMsg('Copy_ScheduleEntries_Pvt','CHECK_SRC_SCHED_NULL', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   IF p_to_list_id IS NULL THEN

      Log_CopyDestListNullMsg('Copy_ScheduleEntries_Pvt','CHECK_DEST_SCHED_NULL', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   l_api_initiated := FALSE; -- Default value

   IF p_api_initiated IS NOT NULL THEN

      l_api_initiated := p_api_initiated;

   END IF;



   -- Perform prerequisite status checks.  This is only

   -- necessary when we initiate the copy via the public api

   -- b/c this is handled via plugin and view IEC_O_LISTS_TO_COPY_V

   -- when the copy is initiated via the admin screens.

   IF l_api_initiated THEN

      EXECUTE IMMEDIATE

         'SELECT A.CALL_CENTER_READY_FLAG

               , A.STATUS_CODE

               , B.VALIDATED_ONCE_FLAG

          FROM IEC_G_AO_LISTS_V A

               , IEC_O_VALIDATION_STATUS B

          WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID

          AND A.LIST_HEADER_ID = :list_id

          AND LANGUAGE = USERENV(''LANG'')'

      INTO l_call_center_ready_flag

         , l_status_code

         , l_validated_once_flag

      USING p_from_list_id;



      IF l_call_center_ready_flag <> 'Y' THEN

         Log_CopySrcListNotCCRMsg('Copy_ScheduleEntries_Pvt','CHECK_SRC_SCHED_CCR', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;

      IF l_validated_once_flag <> 'Y' THEN

         Log_CopySrcListNotValMsg('Copy_ScheduleEntries_Pvt','CHECK_SRC_SCHED_VAL_ONCE', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;

      IF l_status_code <> 'ACTIVE' AND

         l_status_code <> 'INACTIVE' AND

         l_status_code <> 'VALIDATED'

      THEN

         Log_CopySrcListInvalidStatMsg('Copy_ScheduleEntries_Pvt','CHECK_SRC_SCHED_STATUS', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;



      EXECUTE IMMEDIATE

         'SELECT A.CALL_CENTER_READY_FLAG

               , A.STATUS_CODE

               , B.VALIDATED_ONCE_FLAG

          FROM IEC_G_AO_LISTS_V A

             , IEC_O_VALIDATION_STATUS B

          WHERE A.LIST_HEADER_ID = B.LIST_HEADER_ID

          AND A.LIST_HEADER_ID = :list_id

          AND LANGUAGE = USERENV(''LANG'')'

      INTO l_call_center_ready_flag

         , l_status_code

         , l_validated_once_flag

      USING p_to_list_id;



      IF l_call_center_ready_flag <> 'Y' THEN

         Log_CopyDestListNotCCRMsg('Copy_ScheduleEntries_Pvt','CHECK_DEST_SCHED_CCR', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;

      IF l_validated_once_flag <> 'Y' THEN

         Log_CopyDestListNotValMsg('Copy_ScheduleEntries_Pvt','CHECK_DEST_SCHED_VAL_ONCE', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;

      IF l_status_code <> 'ACTIVE' AND

         l_status_code <> 'INACTIVE' AND

         l_status_code <> 'VALIDATED'

      THEN

         Log_CopyDestListInvalidStaMsg('Copy_ScheduleEntries_Pvt','CHECK_DEST_SCHED_STATUS', Get_ScheduleName(p_from_schedule_id), Get_ScheduleName(p_to_schedule_id));

         RAISE fnd_api.g_exc_error;

      END IF;



   END IF;



   Update_MoveEntriesStatus(p_from_list_id, p_to_list_id, 'MOVING', l_api_initiated);



    -- Update party/contact point data for duplicate records in destination list

   Update_DuplicateEntries( P_from_list_id

                          , p_to_list_id

                          , FALSE

                          , l_records_updated);



   Update_MoveEntriesStatusCounts(p_from_list_id, 0, l_records_updated);



   IF p_commit_flag THEN

      COMMIT;

   END IF;



   -- Fetch non-duplicate records

   OPEN c1(p_from_list_id);

   LOOP

      FETCH c1

      BULK COLLECT INTO l_from_returns_id_col

                      , l_from_list_entry_id_col

                      , l_from_list_id_col

      LIMIT g_row_increment;



      EXIT WHEN l_from_returns_id_col.COUNT = 0;



      l_records_moved := l_from_returns_id_col.COUNT;



      IF l_from_returns_id_col IS NOT NULL AND l_from_returns_id_col.COUNT > 0 THEN



         -- Copy non-duplicate records into destination list

         Copy_AmsListEntries( l_from_list_entry_id_col

                            , l_from_list_id_col

                            , l_to_list_entry_id_col

                            , p_to_list_id);



         -- Load non-duplicate records into destination list

         Load_Entries_Pvt( l_to_list_entry_id_col

                         , p_to_list_id

                         , 'Y'    -- enable validation rules

                         );



         Update_MoveEntriesStatusCounts(p_from_list_id, l_records_moved, 0);

      END IF;



      IF p_commit_flag THEN

         COMMIT;

      END IF;



      EXIT WHEN l_from_returns_id_col.COUNT < g_row_increment;



   END LOOP;

   CLOSE c1;



   Update_MoveEntriesStatus(p_from_list_id, p_to_list_id, 'MOVED', l_api_initiated);



   IF p_commit_flag THEN

      COMMIT;

   END IF;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO move_entry;

      Update_MoveEntriesStatus(p_from_list_id, p_to_list_id, 'FAILED_MOVE', l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO move_entry;

      Update_MoveEntriesStatus(p_from_list_id, p_to_list_id, 'FAILED_MOVE', l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN OTHERS THEN

      ROLLBACK TO move_entry;

      Log( 'Copy_ScheduleEntries'

         , 'MAIN'

         , SQLERRM

         );

      Update_MoveEntriesStatus(p_from_list_id, p_to_list_id, 'FAILED_MOVE', l_api_initiated);

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Copy_ScheduleEntries_Pvt;



-- Procedure to be called by public api to copy schedule

-- entries

PROCEDURE Copy_ScheduleEntries_Pub

   ( p_src_schedule_id  IN            NUMBER

   , p_dest_schedule_id IN            NUMBER

   , p_commit           IN            BOOLEAN

   , x_return_status       OUT NOCOPY VARCHAR2)

IS

   l_src_list_id NUMBER(15);

   l_dest_list_id NUMBER(15);

BEGIN



   x_return_status := FND_API.G_RET_STS_SUCCESS;



   IF p_src_schedule_id IS NULL THEN

      Log_CopySrcListNullMsg('Copy_ScheduleEntries_Pub','CHECK_SRC_SCHED_NULL', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   IF p_dest_schedule_id IS NULL THEN

      Log_CopyDestListNullMsg('Copy_ScheduleEntries_Pub','CHECK_DEST_SCHED_NULL', Get_ScheduleName(p_src_schedule_id), Get_ScheduleName(p_dest_schedule_id));

      RAISE fnd_api.g_exc_error;

   END IF;



   -- get list header ids corresponding to schedule ids

   BEGIN

      IEC_COMMON_UTIL_PVT.Get_ListId(p_src_schedule_id, l_src_list_id);

      IEC_COMMON_UTIL_PVT.Get_ListId(p_dest_schedule_id, l_dest_list_id);

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Copy_ScheduleEntries_Pub'

            , 'GET_LIST_HEADER_ID'

            );

         RAISE fnd_api.g_exc_error;

   END;



   Copy_ScheduleEntries_Pvt

      ( l_src_list_id

      , p_src_schedule_id

      , l_dest_list_id

      , p_dest_schedule_id

      , TRUE                 -- p_api_initiated

      , p_commit

      );



EXCEPTION

   WHEN OTHERS THEN

      FND_MSG_PUB.ADD;

      x_return_status := FND_API.G_RET_STS_ERROR;



END Copy_ScheduleEntries_Pub;



-- Procedure to be called by plugin to copy schedule

-- entries (leaving name as Copy_TargetGroupEntries so

-- that existing calls will still be valid)

PROCEDURE Copy_TargetGroupEntries

   ( p_from_list_id  IN  NUMBER

   , p_to_list_id    IN  NUMBER)

IS

BEGIN



   Copy_ScheduleEntries_Pvt

      ( p_from_list_id

      , Get_ScheduleId(p_from_list_id)

      , p_to_list_id

      , Get_ScheduleId(p_to_list_id)

      , FALSE               -- p_api_initiated

      , TRUE                -- p_commit_flag

      );



EXCEPTION

   WHEN OTHERS THEN

      RAISE;

END Copy_TargetGroupEntries;



PROCEDURE Load_NewEntry

   ( p_list_entry_id         IN  NUMBER

   , p_list_id               IN  NUMBER)

IS

   l_list_entry_id_col SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();

BEGIN



   SAVEPOINT load_entry;



   l_list_entry_id_col.EXTEND;

   l_list_entry_id_col(1) := p_list_entry_id;



   Load_Entries_Pvt( l_list_entry_id_col

                   , p_list_id

                   , 'N'    -- disable validation rules

                   );



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN OTHERS THEN

      Log( 'Load_NewEntry'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Load_NewEntry;



PROCEDURE Load_NewEntries

   ( p_list_entry_id_col     IN  SYSTEM.number_tbl_type

   , p_list_id               IN  NUMBER)

IS

BEGIN



   SAVEPOINT load_entry;



   Load_Entries_Pvt( p_list_entry_id_col

                   , p_list_id

                   , 'N'    -- disable validation rules

                   );



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

   WHEN OTHERS THEN

      Log( 'Load_NewEntries'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK TO load_entry;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Load_NewEntries;



PROCEDURE Insert_AmsListEntries

   ( p_list_id            IN            NUMBER

   , p_list_source_type   IN            VARCHAR2

   , p_list_source_code   IN            VARCHAR2

   , p_schedule_id        IN            NUMBER

   , p_party_id           IN            NUMBER

   , x_list_entry_id         OUT NOCOPY NUMBER

   )
IS
  l_api_version     CONSTANT NUMBER   := 1.0;
  l_init_msg_list		VARCHAR2(1);
  l_return_status		VARCHAR2(1);
  l_msg_count			  NUMBER;
  l_msg_data			  VARCHAR2(2000);
  l_listentry_rec AMS_LISTENTRY_PVT.entry_rec_type;
BEGIN
  l_init_msg_list		:=FND_API.G_TRUE;

   IF p_party_id IS NOT NULL THEN

    l_listentry_rec.LIST_HEADER_ID := p_list_id;

    l_listentry_rec.LAST_UPDATE_DATE := sysdate;

    l_listentry_rec.LAST_UPDATED_BY := 1;

    l_listentry_rec.CREATION_DATE := sysdate;

    l_listentry_rec.CREATED_BY := 1;

    l_listentry_rec.LIST_SELECT_ACTION_ID := 0;

    l_listentry_rec.ARC_LIST_SELECT_ACTION_FROM :='NONE';

    l_listentry_rec.SOURCE_CODE := p_list_source_code;

    l_listentry_rec.ARC_LIST_USED_BY_SOURCE := 'CSCH';

    l_listentry_rec.SOURCE_CODE_FOR_ID := p_schedule_id;

    l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID := p_party_id;

    l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE := p_list_source_type;

    l_listentry_rec.VIEW_APPLICATION_ID := 545;

    l_listentry_rec.MANUALLY_ENTERED_FLAG := 'N';

    l_listentry_rec.MARKED_AS_DUPLICATE_FLAG := 'N';

    l_listentry_rec.MARKED_AS_RANDOM_FLAG := 'N';

    l_listentry_rec.PART_OF_CONTROL_GROUP_FLAG := 'N';

    l_listentry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG := 'N';

    l_listentry_rec.ENABLED_FLAG := 'Y';

    AMS_LISTENTRY_PUB.create_listentry(
      p_api_version => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_entry_rec => l_listentry_rec,
      x_entry_id => x_list_entry_id );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Log_msg('AMS_LISTENTRY_PUB.create_listentry', l_msg_data);
  END IF;

/*
      EXECUTE IMMEDIATE

         'SELECT AMS_LIST_ENTRIES_S.NEXTVAL FROM DUAL'

      INTO x_list_entry_id;



      EXECUTE IMMEDIATE

         'INSERT INTO AMS_LIST_ENTRIES

                  ( LIST_ENTRY_ID

                  , LIST_HEADER_ID

                  , LAST_UPDATE_DATE

                  , LAST_UPDATED_BY

                  , CREATION_DATE

                  , CREATED_BY

                  , LIST_SELECT_ACTION_ID

                  , ARC_LIST_SELECT_ACTION_FROM

                  , SOURCE_CODE

                  , ARC_LIST_USED_BY_SOURCE

                  , SOURCE_CODE_FOR_ID

                  , PIN_CODE

                  , LIST_ENTRY_SOURCE_SYSTEM_ID

                  , LIST_ENTRY_SOURCE_SYSTEM_TYPE

                  , VIEW_APPLICATION_ID

                  , MANUALLY_ENTERED_FLAG

                  , MARKED_AS_DUPLICATE_FLAG

                  , MARKED_AS_RANDOM_FLAG

                  , PART_OF_CONTROL_GROUP_FLAG

                  , EXCLUDE_IN_TRIGGERED_LIST_FLAG

                  , ENABLED_FLAG

                  )

               VALUES

                  ( :list_entry_id

                  , :list_header_id

                  , SYSDATE

                  , 1

                  , SYSDATE

                  , 1

                  , 0

                  , ''NONE''

                  , :list_source_code

                  , ''CSCH''

                  , :schedule_id

                  , :list_entry_id

                  , :party_id

                  , :list_source_type

                  , 545

                  , ''N''

                  , ''N''

                  , ''N''

                  , ''N''

                  , ''N''

                  , ''Y''

                  )'

         USING IN x_list_entry_id

             , IN p_list_id

             , IN p_list_source_code

             , IN p_schedule_id

             , IN x_list_entry_id

             , IN p_party_id

             , IN p_list_source_type;
*/
    END IF;

EXCEPTION

   WHEN OTHERS THEN

      Log( 'Insert_AmsListEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Insert_AmsListEntries;



PROCEDURE Update_AmsListEntries

   ( p_list_id            IN            NUMBER

   , p_list_entry_id      IN            NUMBER

   , p_source_type_view   IN            VARCHAR2

   , p_col_names          IN            SYSTEM.varchar_tbl_type

   , p_col_values         IN            SYSTEM.varchar_tbl_type

   )

IS

   l_sql VARCHAR2(4000);

   l_first_col_idx NUMBER;

BEGIN

   l_first_col_idx := -1;



   IF p_list_entry_id IS NOT NULL THEN



      l_sql := 'UPDATE ' || p_source_type_view;



      l_sql := l_sql || ' SET LIST_ENTRY_ID = ''' || p_list_entry_id || '''';



      IF p_col_names.COUNT > 0 THEN

         FOR i IN 1..p_col_names.LAST LOOP

            IF p_col_names(i) IS NOT NULL THEN

               l_sql := l_sql || ', ' || p_col_names(i) || ' = ''' || p_col_values(i) || '''';

            END IF;

         END LOOP;

      END IF;



      l_sql := l_sql || ' WHERE LIST_HEADER_ID = ' || p_list_id;

      l_sql := l_sql || ' AND LIST_ENTRY_ID = ' || p_list_entry_id;



      EXECUTE IMMEDIATE l_sql;



    END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Updating_AmsListEntries'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;



END Update_AmsListEntries;

/*

PROCEDURE Init_RequiredColumns

   ( x_col_names       OUT NOCOPY SYSTEM.varchar_tbl_type

   , x_col_exists_flag OUT NOCOPY SYSTEM.varchar_tbl_type

   )

IS

BEGIN

   x_col_names := SYSTEM.varchar_tbl_type();

   x_col_exists_flag := SYSTEM.varchar_tbl_type();



   x_col_names.EXTEND(9);

   x_col_names(1) := 'PARTY_ID';

   x_col_names(2) := 'PERSON_FIRST_NAME';

   x_col_names(3) := 'PERSON_LAST_NAME';

   x_col_names(4) := 'CONTACT_POINT_ID_S1';

   x_col_names(5) := 'PHONE_COUNTRY_CODE_S1';

   x_col_names(6) := 'PHONE_AREA_CODE_S1';

   x_col_names(7) := 'PHONE_NUMBER_S1';

   x_col_names(8) := 'TIME_ZONE_S1';

   x_col_names(9) := 'PHONE_LINE_TYPE_S1';



   x_col_exists_flag.EXTEND(1);

   x_col_exists_flag(1) := 'N';

   x_col_exists_flag.EXTEND(8,1);



END Init_RequiredColumns;



PROCEDURE Verify_RequiredColumns

   ( p_col_names         IN            SYSTEM.varchar_tbl_type

     x_missing_col_names    OUT NOCOPY SYSTEM.varchar_tbl_type

     x_failure_code         OUT NOCOPY VARCHAR2

   )

IS

   l_req_col_names       SYSTEM.varchar_tbl_type;

   l_req_col_exists_flag SYSTEM.varchar_tbl_type;

BEGIN



   Init_RequiredColumns(l_req_col_names, l_req_col_exists_flag);



   IF p_col_names IS NOT NULL AND p_col_names.COUNT > 0 THEN

      FOR i IN p_col_names.FIRST .. p_col_names.LAST LOOP

         FOR j IN l_req_col_names.FIRST .. l_req_col_names.LAST LOOP

            IF p_col_names(i) = l_req_col_names(j) THEN

               l_req_col_exists_flag(j) := 'Y';

               BREAK;

            END IF;

         END LOOP;

      END LOOP;

   END IF;



   FOR i IN l_req_col_exists_flag.FIRST..l_req_col_exists_flag.LAST LOOP

      IF l_req_col_exists_flag(i) <> 'Y' THEN

         IF x_missing_col_names IS NULL THEN

            x_missing_col_names := SYSTEM.varchar_tbl_type();

         END IF;

         x_missing_col_names.EXTEND;

         x_missing_col_names(x_missing_col_names.LAST) := l_req_col_names(i);

      END IF;

   END LOOP;



END Verify_RequiredColumns;

*/



FUNCTION ToString_ColumnValuePairs

   ( p_col_names  IN            SYSTEM.varchar_tbl_type

   , p_col_values IN            SYSTEM.varchar_tbl_type

   )

RETURN VARCHAR2

IS

   l_string VARCHAR2(4000);

BEGIN



   IF p_col_names IS NOT NULL AND p_col_names.COUNT > 0 THEN

      FOR i IN p_col_names.FIRST .. p_col_names.LAST LOOP

         l_string := l_string || '(' || p_col_names(i) || '=' || p_col_values(i) || ')';

      END LOOP;

   END IF;

   RETURN l_string;



END ToString_ColumnValuePairs;



-- Verify the parameters necessary to insert a record

-- into AMS_LIST_ENTRIES with one contact point, and to

-- validate the record

PROCEDURE Verify_AllRequiredColumns

   ( p_col_names    IN            SYSTEM.varchar_tbl_type

   , p_col_values   IN            SYSTEM.varchar_tbl_type

   , x_party_id        OUT NOCOPY NUMBER

   , x_failure_code    OUT NOCOPY VARCHAR2

   )

IS

BEGIN



   IF p_col_names IS NOT NULL AND p_col_names.COUNT > 0 THEN



      -- assume that no party id is provided until found

      x_failure_code := 490;



<<verify_party_id>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PARTY_ID' AND p_col_values(i) IS NOT NULL THEN

            x_party_id := p_col_values(i);

            x_failure_code := 491;

            GOTO verify_first_name;

         END IF;

      END LOOP;

      RETURN;



<<verify_first_name>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PERSON_FIRST_NAME' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 492;

            GOTO verify_last_name;

         END IF;

      END LOOP;

      RETURN;



<<verify_last_name>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

        IF p_col_names(i) = 'PERSON_LAST_NAME' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 493;

            GOTO verify_contact_point_id;

         END IF;

      END LOOP;

      RETURN;



<<verify_contact_point_id>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'CONTACT_POINT_ID_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 494;

            GOTO verify_country_code;

         END IF;

      END LOOP;

      RETURN;



<<verify_country_code>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PHONE_COUNTRY_CODE_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 495;

            GOTO verify_area_code;

         END IF;

      END LOOP;

      RETURN;



<<verify_area_code>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PHONE_AREA_CODE_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 496;

            GOTO verify_phone_number;

         END IF;

      END LOOP;

      RETURN;



<<verify_phone_number>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PHONE_NUMBER_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := 497;

            GOTO verify_time_zone;

         END IF;

      END LOOP;

      RETURN;



<<verify_time_zone>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'TIME_ZONE_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := NULL;

            EXIT;

         END IF;

      END LOOP;

      RETURN;



   ELSE

      -- if no columns provided, default to missing party id

      x_party_id := NULL;

      x_failure_code := 490;

   END IF;



END Verify_AllRequiredColumns;



-- Verify only the parameters necessary to insert a record

-- into AMS_LIST_ENTRIES with one contact point

PROCEDURE Verify_MinRequiredColumns

   ( p_col_names    IN            SYSTEM.varchar_tbl_type

   , p_col_values   IN            SYSTEM.varchar_tbl_type

   , x_party_id        OUT NOCOPY NUMBER

   , x_failure_code    OUT NOCOPY VARCHAR2

   )

IS

BEGIN



   IF p_col_names IS NOT NULL AND p_col_names.COUNT > 0 THEN



      x_failure_code := 490;



<<verify_party_id>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PARTY_ID' AND p_col_values(i) IS NOT NULL THEN

            x_party_id := p_col_values(i);

            x_failure_code := 496;

            GOTO verify_phone_number;

         END IF;

      END LOOP;

      RETURN;



<<verify_phone_number>>

      FOR i IN p_col_names.FIRST..p_col_names.LAST LOOP

         IF p_col_names(i) = 'PHONE_NUMBER_S1' AND p_col_values(i) IS NOT NULL THEN

            x_failure_code := NULL;

            EXIT;

         END IF;

      END LOOP;

      RETURN;



   ELSE

      -- if no columns provided, default to missing party id

      x_party_id := NULL;

      x_failure_code := 490;

   END IF;



END Verify_MinRequiredColumns;



PROCEDURE Create_NewEntry

   ( p_list_id	        IN            NUMBER

   , p_column_name	    IN            SYSTEM.varchar_tbl_type

   , p_column_value     IN            SYSTEM.varchar_tbl_type

   , x_party_id            OUT NOCOPY NUMBER

   , x_list_entry_id       OUT NOCOPY NUMBER

   , x_failure_code        OUT NOCOPY VARCHAR2

   )

IS

   l_count         NUMBER;

BEGIN



   x_failure_code := NULL;



   -- Check for minimum columns required for insert into AMS_LIST_ENTRIES

   Verify_MinRequiredColumns( p_column_name

                            , p_column_value

                            , x_party_id

                            , x_failure_code);



   IF x_failure_code IS NOT NULL THEN

      RETURN;

   END IF;



   -- Check for duplicate party id

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT COUNT(*)

          FROM AMS_LIST_ENTRIES

          WHERE LIST_HEADER_ID = :list_id

          AND PARTY_ID = :party_id'

      INTO l_count

      USING IN p_list_id, IN x_party_id;

   EXCEPTION

      WHEN OTHERS THEN

         Log( 'Add_Record_To_List'

            , 'CHECK_DUPLICATE_PARTY_IN_LIST'

            , SQLERRM

            );

   END;



   -- If party already exists in list, then cannot add record

   IF l_count > 0 THEN

      x_failure_code := '499';

      RETURN;

   END IF;



   -- Create record in AMS_LIST_ENTRIES

   Insert_AmsListEntries( p_list_id

                        , Get_SourceType(p_list_id)

                        , Get_ScheduleSourceCode(p_list_id)

                        , Get_ScheduleId(p_list_id)

                        , x_party_id

                        , x_list_entry_id

                        );



   -- Update record details in AMS_LIST_ENTRIES using Source Type Views

   Update_AmsListEntries( p_list_id

                        , x_list_entry_id

                        , Get_SourceTypeView(p_list_id)

                        , p_column_name

                        , p_column_value

                        );



   -- Update List Header Counts

   Update_AmsListHeaderCounts( p_list_id

                             , 1

                             , 1

                             );



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      RAISE;

   WHEN OTHERS THEN

      Log( 'Create_NewEntry'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;

END Create_NewEntry;



PROCEDURE Get_ValidationFailureCode

   ( p_list_id	        IN            NUMBER

   , p_list_entry_id    IN            NUMBER

   , x_failure_code        OUT NOCOPY VARCHAR2

   )

IS

BEGIN



   x_failure_code := NULL;



   EXECUTE IMMEDIATE

      'SELECT DO_NOT_USE_REASON_S1

       FROM IEC_O_VALIDATION_REPORT_DETS

       WHERE LIST_HEADER_ID = :list_id

       AND LIST_ENTRY_ID = :list_entry_id'

   INTO x_failure_code

   USING IN p_list_id, IN p_list_entry_id;



EXCEPTION

    WHEN NO_DATA_FOUND THEN

       x_failure_code := NULL;

    WHEN OTHERS THEN

      Log( 'Get_ValidationFailureCode'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;

END Get_ValidationFailureCode;



PROCEDURE Update_CallbackTime

   ( p_list_id	        IN            NUMBER

   , p_list_entry_id    IN            NUMBER

   , p_callback_time    IN            DATE

   )

IS

   l_callback_flag VARCHAR2(1);

BEGIN



   IF p_callback_time IS NOT NULL THEN



      EXECUTE IMMEDIATE

         'UPDATE IEC_G_RETURN_ENTRIES

          SET CALLBACK_FLAG = ''Y''

            , NEXT_CALL_TIME = :callback_time

          WHERE LIST_HEADER_ID = :list_id

          AND LIST_ENTRY_ID = :list_entry_id'

      USING IN p_callback_time

          , IN p_list_id

          , IN p_list_entry_id;

   END IF;



EXCEPTION

   WHEN OTHERS THEN

      Log( 'Update_CallbackTime'

         , 'MAIN'

         , SQLERRM

         );

      RAISE fnd_api.g_exc_unexpected_error;

END Update_CallbackTime;



PROCEDURE Add_Record_To_List_Pvt

   ( p_list_id	                 IN            NUMBER

   , p_column_name	             IN            SYSTEM.varchar_tbl_type

   , p_column_value              IN            SYSTEM.varchar_tbl_type

   , p_callback_time             IN            DATE

   , p_interactive_mode          IN            BOOLEAN

   , x_failure_code                 OUT NOCOPY VARCHAR2

   )

IS

   PRAGMA AUTONOMOUS_TRANSACTION;



   l_list_entry_id NUMBER(15);

   l_party_id      NUMBER(15);

   l_list_entry_id_col SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();



BEGIN



   x_failure_code := NULL;



   -- Setup logging information

   Init_LoggingVariables;

--   FND_MESSAGE.SET_NAME( 'IEC'

--                       , 'IEC_LOG_ADD_PARTY_EXCEPTION');

--   FND_MESSAGE.SET_TOKEN( 'RECORD'

--                        , NVL(ToString_ColumnValuePairs(p_column_name,p_column_value), 'UNKNOWN')

--                        , TRUE);

--   FND_MESSAGE.SET_TOKEN( 'TARGET_GROUP_NAME'

--                        , NVL(Get_ListName(p_list_id), 'UNKNOWN')

--                        , TRUE);

--   FND_MESSAGE.SET_TOKEN( 'LIST_HEADER_ID'

--                        , NVL(TO_CHAR(p_list_id), 'UNKNOWN')

--                        , TRUE);

--   Set_MessagePrefix(FND_MESSAGE.GET);

   Set_MessagePrefix('add_list_entry');



   -- In interactive mode, require all parameters for first contact point

   -- Requirements may be relaxed in future, but this makes sense for now

   -- since validation rules are not used in to validate this record.

   -- In batch mode, we do not require all parameters - we only require

   -- enough parameters to insert the record into AMS_LIST_ENTRIES since

   -- it doesn't matter if the record fails validation.

   IF p_interactive_mode THEN

      Verify_AllRequiredColumns( p_column_name

                               , p_column_value

                               , l_party_id

                               , x_failure_code

                               );

      IF x_failure_code IS NOT NULL THEN

         ROLLBACK;

         RETURN;

      END IF;

   END IF;



   -- Create the new entry in AMS_LIST_ENTRIES

   Create_NewEntry( p_list_id

                  , p_column_name

                  , p_column_value

                  , l_party_id

                  , l_list_entry_id

                  , x_failure_code

                  );



   -- Must rollback if unable to insert entry into AMS_LIST_ENTRIES

   -- Possible reasons include missing parameters, or duplicate party id

   IF x_failure_code IS NOT NULL THEN

      ROLLBACK;

      RETURN;

   END IF;



   -- Load the new entry into the system

   l_list_entry_id_col.EXTEND;

   l_list_entry_id_col(1) := l_list_entry_id;



   Load_Entries_Pvt( l_list_entry_id_col

                   , p_list_id

                   , 'N'    -- disable validation rules

                   );



   -- Need to get feedback about whether or not entry passed validation

   Get_ValidationFailureCode( p_list_id

                            , l_list_entry_id

                            , x_failure_code

                            );



   -- In interactive mode, if the record fails validation,

   -- we rollback the entire transaction.  User will have

   -- to resubmit request with updated customer information.

   -- In batch mode, do not rollback b/c we want to leave

   -- the entry as invalid in the system.  User will have

   -- to "fix" the data in our system and revalidate using

   -- the standard validation process.

   IF x_failure_code IS NOT NULL THEN

      IF p_interactive_mode THEN

         ROLLBACK;

         RETURN;

      END IF;

   ELSE

      -- If record was successfully inserted, update callback time

      Update_CallbackTime(p_list_id, l_list_entry_id, p_callback_time);

   END IF;



   COMMIT;



EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      ROLLBACK;

      RAISE;

   WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK;

      RAISE;

   WHEN OTHERS THEN

      Log( 'Add_Record_To_List_Pvt'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK;

      RAISE fnd_api.g_exc_unexpected_error;

END Add_Record_To_List_Pvt;



PROCEDURE Add_Record_To_List

   ( p_list_id	                 IN            NUMBER

   , p_column_name	             IN            SYSTEM.varchar_tbl_type

   , p_column_value              IN            SYSTEM.varchar_tbl_type

   , p_callback_time             IN            DATE DEFAULT NULL

   , x_failure_code                 OUT NOCOPY VARCHAR2

   )

IS

BEGIN



   Add_Record_To_List_Pvt( p_list_id

                         , p_column_name

                         , p_column_value

                         , p_callback_time

                         , FALSE  -- batch mode

                         , x_failure_code

                         );



EXCEPTION

   WHEN OTHERS THEN

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

END Add_Record_To_List;



PROCEDURE Add_Record_To_List_Interactive

   ( p_list_id	                 IN            NUMBER

   , p_column_name	             IN            SYSTEM.varchar_tbl_type

   , p_column_value              IN            SYSTEM.varchar_tbl_type

   , p_callback_time             IN            DATE DEFAULT NULL

   , x_failure_code                 OUT NOCOPY VARCHAR2

   )

IS

BEGIN



   Add_Record_To_List_Pvt( p_list_id

                         , p_column_name

                         , p_column_value

                         , p_callback_time

                         , TRUE  -- interactive mode

                         , x_failure_code

                         );



EXCEPTION

   WHEN OTHERS THEN

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);



END Add_Record_To_List_Interactive;



FUNCTION Get_Postfix

   ( p_index IN NUMBER)

RETURN VARCHAR2

IS

   l_postfix VARCHAR2(3);

BEGIN



   SELECT DECODE( p_index

                , 1, '_S1'

                , 2, '_S2'

                , 3, '_S3'

                , 4, '_S4'

                , 5, '_S5'

                , 6, '_S6'

                , NULL)

   INTO l_postfix

   FROM DUAL;



   RETURN l_postfix;



END Get_Postfix;



PROCEDURE Update_ContactPoint

   ( p_list_id	        IN            NUMBER

   , p_list_entry_id    IN            NUMBER

   , p_party_id         IN            NUMBER

   , p_contact_point_id IN            NUMBER

   , p_index            IN            NUMBER

   , p_country_code	    IN            VARCHAR2

   , p_area_code        IN            VARCHAR2

   , p_phone_number     IN            VARCHAR2

   , p_time_zone        IN            NUMBER

   , p_update_tca_flag  IN            VARCHAR2

   )

IS

   l_source_type_view      VARCHAR2(32);

   l_postfix               VARCHAR2(3);



   l_contact_point_rec     HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;

   l_phone_rec             HZ_CONTACT_POINT_V2PUB.phone_rec_type;



   l_object_version_number NUMBER;

   l_return_status         VARCHAR2(1);

   l_msg_count             NUMBER;

   l_msg_data              VARCHAR2(4000);

   l_error_msg             VARCHAR2(4000);

BEGIN



   -- Update TCA contact point record

   IF p_update_tca_flag = 'Y' THEN

      l_contact_point_rec.contact_point_id := p_contact_point_id;



      l_phone_rec.phone_country_code := p_country_code;

      l_phone_rec.phone_area_code := p_area_code;

      l_phone_rec.phone_number := p_phone_number;

      l_phone_rec.timezone_id := p_time_zone;



      -- Get object version number

      SELECT OBJECT_VERSION_NUMBER

      INTO l_object_version_number

      FROM HZ_CONTACT_POINTS

      WHERE CONTACT_POINT_ID = p_contact_point_id;



      HZ_CONTACT_POINT_V2PUB.update_phone_contact_point

         ( fnd_api.g_true            -- init msg list

         , l_contact_point_rec

         , l_phone_rec

         , l_object_version_number   -- object version number

         , l_return_status

         , l_msg_count

         , l_msg_data

         );



      ----------------------------------------------------------------

      -- If the call to the ams api did not complete successfully then write

      -- a log and stop the update list procedure.

      ----------------------------------------------------------------

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         BEGIN

            -- Get Marketing API Error Message

            FOR i IN 1..FND_MSG_PUB.count_msg LOOP

               l_msg_data := LTRIM(RTRIM(FND_MSG_PUB.GET(i, FND_API.G_FALSE)));

               IF (NVL(LENGTH(l_error_msg), 0) + NVL(LENGTH(l_msg_data), 0) < 1000) THEN

                  l_error_msg := l_error_msg || l_msg_data;

               ELSIF (NVL(LENGTH(l_error_msg), 0) = 0) THEN

                  l_error_msg := SUBSTR(l_msg_data, 1000);

               END IF;

            END LOOP;

         EXCEPTION

            WHEN OTHERS THEN

               l_error_msg := NULL;

         END;



         Log( 'Update_ContactPoint'

            , 'UPDATE_HZ_CONTACT_POINTS'

            , l_error_msg

            );



         IF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

      END IF;



   END IF;



   -- Update AMS_LIST_ENTRIES contact point

   BEGIN

      l_source_type_view := Get_SourceTypeView(p_list_id);

      l_postfix := Get_Postfix(p_index);

      EXECUTE IMMEDIATE

         'UPDATE ' || l_source_type_view ||

         ' SET PHONE_COUNTRY_CODE' || l_postfix || ' = ' || p_country_code ||

         '  , PHONE_AREA_CODE' || l_postfix || ' = ' || p_area_code ||

         '  , PHONE_NUMBER' || l_postfix || ' = ' || p_phone_number ||

         '  , RAW_PHONE_NUMBER' || l_postfix || ' = NULL

            , TIME_ZONE' || l_postfix || ' = ' || p_time_zone ||

         'WHERE LIST_HEADER_ID = :list_id

          AND LIST_ENTRY_ID = :list_entry_id

          AND CONTACT_POINT_ID' || l_postfix || ' = ' || p_contact_point_id

      USING IN p_list_id, IN p_list_entry_id;

   EXCEPTION

      WHEN OTHERS THEN

         IF SQLCODE = -904 THEN

            Log_MissingSourceTypeColumns(p_list_id, l_source_type_view, Get_SourceType(p_list_id), 'Update_ContactPoint', 'UPDATE_AMS_LIST_ENTRIES');

            RAISE fnd_api.g_exc_unexpected_error;

         ELSE

            Log( 'Update_ContactPoint'

               , 'UPDATE_AMS_LIST_ENTRIES'

               , SQLERRM

               );

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

   END;



EXCEPTION

   WHEN OTHERS THEN

      RAISE_APPLICATION_ERROR(-20999, Get_TranslatedErrorMessage);

END Update_ContactPoint;

/*

PROCEDURE SubsetTransition_List

   ( p_list_id         IN            NUMBER

   , p_schedule_id     IN            NUMBER

   , p_source_type_v   IN            VARCHAR2

   , x_return_code        OUT NOCOPY VARCHAR2)   -- OUT

IS



   l_subset_id_col         SYSTEM.number_tbl_type;

   l_subset_view_col       SYSTEM.varchar_tbl_type;

   l_subset_rec_loaded_col SYSTEM.number_tbl_type;



   l_list_entry_csr        ListEntryCsrType;

   l_entry_count           PLS_INTEGER;



   l_list_entry_id         NUMBER(15);

   l_callback_flag         VARCHAR2(1);

   l_next_call_time        DATE;

   l_do_not_use_flag       VARCHAR2(1);

   l_do_not_use_reason     NUMBER;

   l_record_out_flag       VARCHAR2(1);

   l_record_release_time   DATE;



   l_cpc_id                NUMBER(15);

   l_cpc_index             NUMBER;

   l_cpc_cc                VARCHAR2(240);

   l_cpc_ac                NUMBER;

   l_cpc_pn                VARCHAR2(240);

   l_cpc_rpn               VARCHAR2(240);



   l_cpc_cc_tz_id          NUMBER(15);

   l_cc_tz_id_s1           NUMBER(15);

   l_cc_tz_id_s2           NUMBER(15);

   l_cc_tz_id_s3           NUMBER(15);

   l_cc_tz_id_s4           NUMBER(15);

   l_cc_tz_id_s5           NUMBER(15);

   l_cc_tz_id_s6           NUMBER(15);



   l_cpc_tz                NUMBER(15);

   l_tz_s1                 NUMBER(15);

   l_tz_s2                 NUMBER(15);

   l_tz_s3                 NUMBER(15);

   l_tz_s4                 NUMBER(15);

   l_tz_s5                 NUMBER(15);

   l_tz_s6                 NUMBER(15);



   l_cpc_tc                VARCHAR2(2);

   l_tc_s1                 VARCHAR2(2);

   l_tc_s2                 VARCHAR2(2);

   l_tc_s3                 VARCHAR2(2);

   l_tc_s4                 VARCHAR2(2);

   l_tc_s5                 VARCHAR2(2);

   l_tc_s6                 VARCHAR2(2);



   l_cpc_rc                NUMBER(15);

   l_rc_s1                 NUMBER(15);

   l_rc_s2                 NUMBER(15);

   l_rc_s3                 NUMBER(15);

   l_rc_s4                 NUMBER(15);

   l_rc_s5                 NUMBER(15);

   l_rc_s6                 NUMBER(15);



   l_cpc_valid_flag        VARCHAR2(1);

   l_valid_flag_s1         VARCHAR2(1);

   l_valid_flag_s2         VARCHAR2(1);

   l_valid_flag_s3         VARCHAR2(1);

   l_valid_flag_s4         VARCHAR2(1);

   l_valid_flag_s5         VARCHAR2(1);

   l_valid_flag_s6         VARCHAR2(1);



   l_records_passed        NUMBER(9) := 0;

   l_records_failed        NUMBER(9) := 0;



   l_count                 NUMBER(9);



BEGIN



   x_return_code := FND_API.G_RET_STS_SUCCESS;



   SAVEPOINT subset_transition;



   -- Make sure that data hasn't already been transitioned

   EXECUTE IMMEDIATE

      'SELECT COUNT(*)

       FROM IEC_G_REP_SUBSET_COUNTS

       WHERE LIST_HEADER_ID = :list_id'

   INTO l_count

   USING p_list_id;



   IF l_count > 0 THEN

      GOTO Done;

   END IF;



   -- Ensure that marketing objects created prior to Minipack N are updated

   -- with the ITM_CC_TZ_ID populated in the REASON_CODE_S? column instead of 'Y' or 'N'

   EXECUTE IMMEDIATE

         'BEGIN

          UPDATE ' || p_source_type_v || ' A' || '

          SET

            REASON_CODE_S1 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S1 AND B.TIMEZONE_ID = A.TIME_ZONE_S1 AND B.LIST_HEADER_ID = :1 AND B.REGION_ID IS NULL)

          , REASON_CODE_S2 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S2 AND B.TIMEZONE_ID = A.TIME_ZONE_S2 AND B.LIST_HEADER_ID = :2 AND B.REGION_ID IS NULL)

          , REASON_CODE_S3 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S3 AND B.TIMEZONE_ID = A.TIME_ZONE_S3 AND B.LIST_HEADER_ID = :3 AND B.REGION_ID IS NULL)

          , REASON_CODE_S4 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S4 AND B.TIMEZONE_ID = A.TIME_ZONE_S4 AND B.LIST_HEADER_ID = :4 AND B.REGION_ID IS NULL)

          , REASON_CODE_S5 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S5 AND B.TIMEZONE_ID = A.TIME_ZONE_S5 AND B.LIST_HEADER_ID = :5 AND B.REGION_ID IS NULL)

          , REASON_CODE_S6 = (SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S6 AND B.TIMEZONE_ID = A.TIME_ZONE_S6 AND B.LIST_HEADER_ID = :6 AND B.REGION_ID IS NULL)

          WHERE LIST_HEADER_ID = :list_header_id

          AND TRANSLATE(UPPER(CURR_CP_COUNTRY_CODE), ''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'', ''0123456789'') IS NULL

          AND (DO_NOT_USE_FLAG = ''N'' OR (DO_NOT_USE_FLAG = ''Y'' AND DO_NOT_USE_REASON <> 4));

          END;'

   USING p_list_id

   ,     p_list_id

   ,     p_list_id

   ,     p_list_id

   ,     p_list_id

   ,     p_list_id

   ,     p_list_id;



   EXECUTE IMMEDIATE

         'BEGIN

          UPDATE ' || p_source_type_v || ' A' || '

          SET

            CURR_CP_COUNTRY_CODE = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.CURR_CP_COUNTRY_CODE)

          , PHONE_COUNTRY_CODE_S1 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S1)

          , PHONE_COUNTRY_CODE_S2 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S2)

          , PHONE_COUNTRY_CODE_S3 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S3)

          , PHONE_COUNTRY_CODE_S4 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S4)

          , PHONE_COUNTRY_CODE_S5 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S5)

          , PHONE_COUNTRY_CODE_S6 = (SELECT PHONE_COUNTRY_CODE FROM HZ_PHONE_COUNTRY_CODES B WHERE B.TERRITORY_CODE = A.PHONE_COUNTRY_CODE_S6)

          WHERE LIST_HEADER_ID = :list_header_id

          AND TRANSLATE(UPPER(CURR_CP_COUNTRY_CODE), ''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'', ''0123456789'') IS NULL

          AND (DO_NOT_USE_FLAG = ''N'' OR (DO_NOT_USE_FLAG = ''Y'' AND DO_NOT_USE_REASON <> 4));

          END;'

   USING p_list_id;





   -- Assign load priorities to subsets

   EXECUTE IMMEDIATE

      'UPDATE IEC_G_LIST_SUBSETS

       SET LOAD_PRIORITY = ROWNUM

       WHERE LIST_HEADER_ID = :1

       AND (DEFAULT_SUBSET_FLAG IS NULL OR DEFAULT_SUBSET_FLAG = ''N'')

       AND LOAD_PRIORITY IS NULL'

   USING p_list_id;



   Init_SubsetRtInfo(p_list_id, p_source_type_v, l_subset_id_col, l_subset_view_col);



   -- Load current callable zones into cache with special flag 'O' to indicate that they should not be

   -- used when assigning new callable zones (with subsets) to entries

   EXECUTE IMMEDIATE

         'INSERT INTO IEC_TC_TZ_PAIRS_CACHE (SUBSET_ID, TERRITORY_CODE, REGION_ID, TIMEZONE_ID, TC_TZ_PAIR_ID, RECORD_COUNT, CACHE_ONLY_FLAG)

          SELECT SUBSET_ID, TERRITORY_CODE, REGION_ID, TIMEZONE_ID, ITM_CC_TZ_ID, RECORD_COUNT, ''O''

          FROM IEC_G_MKTG_ITEM_CC_TZS

          WHERE LIST_HEADER_ID = :list_id'

   USING p_list_id;



   -- Need to delete them from IEC_G_MKTG_ITEM_CC_TZS to avoid unique constraint violation on purge

   EXECUTE IMMEDIATE

      'DELETE FROM IEC_G_MKTG_ITEM_CC_TZS

       WHERE LIST_HEADER_ID = :list_id'

   USING p_list_id;



   -- Load entries into IEC_VAL_ENTRY_CACHE

   BEGIN

      OPEN l_list_entry_csr FOR

           'SELECT LIST_ENTRY_ID

                 , CALLBACK_FLAG

                 , NEXT_CALL_TIME

                 , DO_NOT_USE_FLAG

                 , DO_NOT_USE_REASON

                 , RECORD_OUT_FLAG

                 , RECORD_RELEASE_TIME

                 , CURR_CP_ID

                 , CURR_CP_INDEX

                 , CURR_CP_COUNTRY_CODE

                 , CURR_CP_AREA_CODE

                 , CURR_CP_PHONE_NUMBER

                 , CURR_CP_RAW_PHONE_NUMBER

                 , CURR_CP_TIME_ZONE_AUX

                 , REASON_CODE_S1

                 , REASON_CODE_S2

                 , REASON_CODE_S3

                 , REASON_CODE_S4

                 , REASON_CODE_S5

                 , REASON_CODE_S6

            FROM ' || p_source_type_v || '

            WHERE LIST_HEADER_ID = :list_id' || '

            AND ( DO_NOT_USE_FLAG = ''N''

                  OR

                  (DO_NOT_USE_FLAG = ''Y'' AND DO_NOT_USE_REASON <> 4 AND (DO_NOT_USE_REASON < 400 OR DO_NOT_USE_REASON > 499))

                )'

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

         IF SQLCODE = -904 THEN

            g_error_msg := 'Source type view ' || p_source_type_v || ' is missing at least one of the following columns: ' ||

                           'REASON_CODE_S1, REASON_CODE_S2, REASON_CODE_S3, REASON_CODE_S4, REASON_CODE_S5, REASON_CODE_S6';

            RAISE fnd_api.g_exc_unexpected_error;

         ELSE

            RAISE;

         END IF;

   END;



   LOOP



      FOR I IN 1..g_row_increment LOOP



         FETCH l_list_entry_csr INTO

               l_list_entry_id,

               l_callback_flag,

               l_next_call_time,

               l_do_not_use_flag,

               l_do_not_use_reason,

               l_record_out_flag,

               l_record_release_time,

               l_cpc_id,

               l_cpc_index,

               l_cpc_cc,

               l_cpc_ac,

               l_cpc_pn,

               l_cpc_rpn,

               l_cpc_cc_tz_id,

               l_cc_tz_id_s1,

               l_cc_tz_id_s2,

               l_cc_tz_id_s3,

               l_cc_tz_id_s4,

               l_cc_tz_id_s5,

               l_cc_tz_id_s6;



         EXIT WHEN l_list_entry_csr%NOTFOUND;



         -- Map CC_TZ_ID to territory code, region code, and time zone

         Get_CallableZoneDetail_Cache(l_cpc_cc_tz_id, l_cpc_tc, l_cpc_rc, l_cpc_tz, l_cpc_valid_flag);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s1, l_tc_s1, l_rc_s1, l_tz_s1, l_valid_flag_s1);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s2, l_tc_s2, l_rc_s2, l_tz_s2, l_valid_flag_s2);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s3, l_tc_s3, l_rc_s3, l_tz_s3, l_valid_flag_s3);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s4, l_tc_s4, l_rc_s4, l_tz_s4, l_valid_flag_s4);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s5, l_tc_s5, l_rc_s5, l_tz_s5, l_valid_flag_s5);

         Get_CallableZoneDetail_Cache(l_cc_tz_id_s6, l_tc_s6, l_rc_s6, l_tz_s6, l_valid_flag_s6);



         INSERT INTO IEC_VAL_ENTRY_CACHE

            ( LIST_ENTRY_ID

            , CALLBACK_FLAG

            , NEXT_CALL_TIME

            , DO_NOT_USE_FLAG

            , PREV_STATUS_CODE

            , DO_NOT_USE_REASON

            , RECORD_OUT_FLAG

            , RECORD_RELEASE_TIME

            , CURR_CP_ID

            , CURR_CP_INDEX

            , CURR_CP_COUNTRY_CODE

            , CURR_CP_AREA_CODE

            , CURR_CP_PHONE_NUMBER

            , CURR_CP_RAW_PHONE_NUMBER

            , CURR_CP_TIME_ZONE

            , CURR_CP_TERRITORY_CODE

            , CURR_CP_REGION_ID

            , TIME_ZONE_S1, TERRITORY_CODE_S1, REGION_ID_S1, VALID_FLAG_S1

            , TIME_ZONE_S2, TERRITORY_CODE_S2, REGION_ID_S2, VALID_FLAG_S2

            , TIME_ZONE_S3, TERRITORY_CODE_S3, REGION_ID_S3, VALID_FLAG_S3

            , TIME_ZONE_S4, TERRITORY_CODE_S4, REGION_ID_S4, VALID_FLAG_S4

            , TIME_ZONE_S5, TERRITORY_CODE_S5, REGION_ID_S5, VALID_FLAG_S5

            , TIME_ZONE_S6, TERRITORY_CODE_S6, REGION_ID_S6, VALID_FLAG_S6

            )

         VALUES

            ( l_list_entry_id

            , l_callback_flag

            , l_next_call_time

            , 'N'                      -- Default DO_NOT_USE_FLAG in temp table to 'N' for processing

            , l_do_not_use_flag        -- Store actual value of DO_NOT_USE_FLAG in PREV_STATUS_CODE column of temp table

            , l_do_not_use_reason

            , l_record_out_flag

            , l_record_release_time

            , l_cpc_id

            , l_cpc_index

            , l_cpc_cc

            , l_cpc_ac

            , l_cpc_pn

            , l_cpc_rpn

            , l_cpc_tz

            , l_cpc_tc

            , l_cpc_rc

            , l_tz_s1, l_tc_s1, l_rc_s1, l_valid_flag_s1

            , l_tz_s2, l_tc_s2, l_rc_s2, l_valid_flag_s2

            , l_tz_s3, l_tc_s3, l_rc_s3, l_valid_flag_s3

            , l_tz_s4, l_tc_s4, l_rc_s4, l_valid_flag_s4

            , l_tz_s5, l_tc_s5, l_rc_s5, l_valid_flag_s5

            , l_tz_s6, l_tc_s6, l_rc_s6, l_valid_flag_s6

            );



      END LOOP;



      EXECUTE IMMEDIATE

         'SELECT COUNT(*)

          FROM IEC_VAL_ENTRY_CACHE'

      INTO l_entry_count;



      EXIT WHEN l_entry_count = 0;



      l_records_passed := l_records_passed + l_entry_count;



      -- Assign subsets

      Partition_SubsetEntries( p_list_id

                             , l_subset_id_col

                             , l_subset_view_col

                             , l_subset_rec_loaded_col);



      -- Compile data on callable zones (incorporating subsets) and initialize counts

      Update_CallableZones(p_list_id);



      -- Update AMS_LIST_ENTRIES and IEC_G_RETURN_ENTRIES

      EXECUTE IMMEDIATE

         'BEGIN

             UPDATE ' || p_source_type_v || ' A' ||

             ' SET ( REASON_CODE_S1

                   , REASON_CODE_S2

                   , REASON_CODE_S3

                   , REASON_CODE_S4

                   , REASON_CODE_S5

                   , REASON_CODE_S6 )

               =

                   ( SELECT MKTG_ITEM_CC_TZS_ID_S1

                          , MKTG_ITEM_CC_TZS_ID_S2

                          , MKTG_ITEM_CC_TZS_ID_S3

                          , MKTG_ITEM_CC_TZS_ID_S4

                          , MKTG_ITEM_CC_TZS_ID_S5

                          , MKTG_ITEM_CC_TZS_ID_S6

                     FROM IEC_VAL_ENTRY_CACHE B WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID )

          WHERE LIST_HEADER_ID = :list_id AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE);

          END;'

      USING p_list_id;



      EXECUTE IMMEDIATE

         'BEGIN

          UPDATE IEC_G_RETURN_ENTRIES A

          SET ( SUBSET_ID

              , ITM_CC_TZ_ID

              , CALLBACK_FLAG

              , NEXT_CALL_TIME

              , DO_NOT_USE_FLAG

              , DO_NOT_USE_REASON

              , RECORD_OUT_FLAG

              , RECORD_RELEASE_TIME

              , CONTACT_POINT_ID

              , CONTACT_POINT_INDEX

              , COUNTRY_CODE

              , AREA_CODE

              , PHONE_NUMBER

              , RAW_PHONE_NUMBER

              , TIME_ZONE )

              =

              ( SELECT SUBSET_ID

                     , CURR_CP_MKTG_ITEM_CC_TZS_ID

                     , CALLBACK_FLAG

                     , NEXT_CALL_TIME

                     , PREV_STATUS_CODE    -- ACTUAL DO_NOT_USE_FLAG VALUE FROM ALE

                     , DO_NOT_USE_REASON

                     , RECORD_OUT_FLAG

                     , RECORD_RELEASE_TIME

                     , CURR_CP_ID

                     , CURR_CP_INDEX

                     , CURR_CP_COUNTRY_CODE

                     , CURR_CP_AREA_CODE

                     , CURR_CP_PHONE_NUMBER

                     , CURR_CP_RAW_PHONE_NUMBER

                     , CURR_CP_TIME_ZONE

                FROM IEC_VAL_ENTRY_CACHE B

                WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID )

          WHERE LIST_HEADER_ID = :list_id AND LIST_ENTRY_ID IN (SELECT LIST_ENTRY_ID FROM IEC_VAL_ENTRY_CACHE);

          END;'

      USING p_list_id;



      Update_ReportCounts( p_campaign_id

                         , p_schedule_id

                         , p_list_id

                         , l_subset_id_col

                         , l_subset_rec_loaded_col);



      Purge_CallableZones(p_list_id, p_schedule_id);



      Truncate_IecValEntryCache;



   END LOOP;



   CLOSE l_list_entry_csr;



   l_count := NULL;



   -- Check for existence of record in IEC_O_VALIDATION_STATUS

   EXECUTE IMMEDIATE

      'SELECT COUNT(*)

       FROM IEC_O_VALIDATION_STATUS

       WHERE LIST_HEADER_ID = :list_id'

   INTO l_count

   USING p_list_id;



   IF l_count = 0 THEN

      EXECUTE IMMEDIATE

         'INSERT INTO IEC_O_VALIDATION_STATUS

          ( VALIDATION_STATUS_ID

          , LIST_HEADER_ID

          , VALIDATED_ONCE_FLAG

          , CREATED_BY

          , CREATION_DATE

          , LAST_UPDATED_BY

          , LAST_UPDATE_DATE

          , OBJECT_VERSION_NUMBER)

          VALUES

          ( IEC_O_VALIDATION_STATUS_S.NEXTVAL

          , :list_id

          , ''Y''

          , 1

          , SYSDATE

          , 1

          , SYSDATE

          , 0)'

      USING p_list_id;

   END IF;



   l_count := NULL;



   -- Update execution start time for list

   EXECUTE IMMEDIATE

      'UPDATE IEC_G_LIST_RT_INFO

       SET EXECUTION_START_TIME = SYSDATE

         , LAST_UPDATED_BY = 0

         , LAST_UPDATE_DATE = SYSDATE

       WHERE LIST_HEADER_ID IN (SELECT LIST_HEADER_ID FROM AMS_LIST_HEADERS_ALL WHERE LIST_HEADER_ID = :list_id AND STATUS_CODE = ''EXECUTING'')

       AND EXECUTION_START_TIME IS NULL'

   USING p_list_id;



   Truncate_Temporary_Tables;



<<Done>>



   Update_Status(p_list_id, 'VALIDATED');

   COMMIT;



EXCEPTION

   WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_code := FND_API.G_RET_STS_ERROR;

      ROLLBACK TO subset_transition;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

   WHEN OTHERS THEN

      x_return_code := FND_API.G_RET_STS_ERROR;

      Log( 'SubsetTransition_list'

         , 'MAIN'

         , SQLERRM

         );

      ROLLBACK TO subset_transition;

      Truncate_Temporary_Tables;

      RAISE_APPLICATION_ERROR(-20999, g_error_msg);



END SubsetTransition_List;

*/

PROCEDURE UPDATE_TZ_MAPPINGS

IS

   L_COUNT NUMBER(9);

   L_TERRITORY_CODE VARCHAR2(2);

   L_TIMEZONE_ID NUMBER(15);



   CURSOR AREA_CODE_LIST IS

      SELECT DISTINCT PHONE_AREA_CODE FROM IEC_G_TIMEZONE_MAPPINGS;



BEGIN



   FOR REC IN AREA_CODE_LIST LOOP



      SELECT COUNT(*) INTO L_COUNT FROM

             (SELECT DISTINCT TIMEZONE_ID FROM IEC_G_TIMEZONE_MAPPINGS WHERE PHONE_AREA_CODE = REC.PHONE_AREA_CODE);



      IF L_COUNT = 1 THEN



         SELECT DISTINCT TERRITORY_CODE INTO L_TERRITORY_CODE

                FROM IEC_G_TIMEZONE_MAPPINGS

                WHERE PHONE_AREA_CODE = REC.PHONE_AREA_CODE;



         SELECT DISTINCT TIMEZONE_ID INTO L_TIMEZONE_ID

                FROM IEC_G_TIMEZONE_MAPPINGS

                WHERE PHONE_AREA_CODE = REC.PHONE_AREA_CODE;



         DELETE IEC_G_TIMEZONE_MAPPINGS WHERE PHONE_AREA_CODE = REC.PHONE_AREA_CODE;



         INSERT INTO IEC_G_TIMEZONE_MAPPINGS

                (TIMEZONE_MAPPING_ID, TERRITORY_CODE, PHONE_AREA_CODE, POSTAL_CODE, TIMEZONE_ID, CREATED_BY,

                 CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER)

                VALUES

                (IEC_G_TIMEZONE_MAPPINGS_S.NEXTVAL, L_TERRITORY_CODE, REC.PHONE_AREA_CODE, NULL, L_TIMEZONE_ID, 0,

                 SYSDATE, 0, SYSDATE, 0, 1);

      END IF;

      COMMIT;

   END LOOP;

END UPDATE_TZ_MAPPINGS;





END IEC_VALIDATE_PVT;


/
