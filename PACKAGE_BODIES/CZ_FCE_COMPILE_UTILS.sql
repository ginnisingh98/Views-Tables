--------------------------------------------------------
--  DDL for Package Body CZ_FCE_COMPILE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_FCE_COMPILE_UTILS" AS
/*	$Header: czfceutb.pls 120.13 2008/03/12 20:04:47 asiaston ship $		*/

const_long_reverse   CONSTANT NUMBER := const_max_long + const_max_long + 2;
---------------------------------------------------------------------------------------
TYPE type_timing_structure IS RECORD (
    start_time   NUMBER
  , total_time   NUMBER
  , active_flag  PLS_INTEGER
  );

TYPE type_timing_table     IS TABLE OF type_timing_structure INDEX BY VARCHAR2(4000);
timing_table               type_timing_table;
---------------------------------------------------------------------------------------
FUNCTION assert_unsigned_byte ( p_int IN PLS_INTEGER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_unsigned_byte OR p_int > const_max_unsigned_byte ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_unsigned_byte;
---------------------------------------------------------------------------------------
FUNCTION assert_byte ( p_int IN PLS_INTEGER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_byte OR p_int > const_max_byte ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_byte;
---------------------------------------------------------------------------------------
FUNCTION assert_unsigned_word ( p_int IN PLS_INTEGER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_unsigned_word OR p_int > const_max_unsigned_word ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_unsigned_word;
---------------------------------------------------------------------------------------
FUNCTION assert_word ( p_int IN PLS_INTEGER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_word OR p_int > const_max_word ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_word;
---------------------------------------------------------------------------------------
FUNCTION assert_iconst ( p_int IN PLS_INTEGER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_iconst_min OR p_int > const_iconst_max ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_iconst;
---------------------------------------------------------------------------------------
FUNCTION assert_integer ( p_int IN NUMBER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_integer OR p_int > const_max_integer ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_integer;
---------------------------------------------------------------------------------------
FUNCTION assert_long ( p_int IN NUMBER ) RETURN BOOLEAN IS
BEGIN

   IF ( p_int < const_min_long OR p_int > const_max_long ) THEN RETURN FALSE; END IF;
   RETURN TRUE;

END assert_long;
---------------------------------------------------------------------------------------
FUNCTION unsigned_byte ( p_int IN PLS_INTEGER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.SUBSTR ( UTL_RAW.CAST_FROM_BINARY_INTEGER ( p_int ), 4);

END unsigned_byte;
---------------------------------------------------------------------------------------
FUNCTION byte ( p_int IN PLS_INTEGER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.SUBSTR ( UTL_RAW.CAST_FROM_BINARY_INTEGER ( p_int ), 4);

END byte;
---------------------------------------------------------------------------------------
FUNCTION unsigned_word ( p_int IN PLS_INTEGER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.SUBSTR ( UTL_RAW.CAST_FROM_BINARY_INTEGER ( p_int ), 3);

END unsigned_word;
---------------------------------------------------------------------------------------
FUNCTION word ( p_int IN PLS_INTEGER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.SUBSTR ( UTL_RAW.CAST_FROM_BINARY_INTEGER ( p_int ), 3);

END word;
---------------------------------------------------------------------------------------
FUNCTION integer_raw ( p_int IN NUMBER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.CAST_FROM_BINARY_INTEGER ( p_int );

END integer_raw;
---------------------------------------------------------------------------------------
FUNCTION long_raw ( p_int IN NUMBER ) RETURN RAW IS

  l_num     NUMBER;

BEGIN

   IF ( p_int < 0 ) THEN

      l_num := const_long_reverse + p_int;

   ELSE

      l_num := p_int;

   END IF;

   RETURN HEXTORAW( TO_CHAR ( l_num, 'FM0XXXXXXXXXXXXXXX'));
END long_raw;
---------------------------------------------------------------------------------------
FUNCTION float_raw ( p_number IN NUMBER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.CAST_FROM_BINARY_FLOAT ( p_number );

EXCEPTION
   WHEN OTHERS THEN

     RAISE cz_cpl_internal_float;

END float_raw;
---------------------------------------------------------------------------------------
FUNCTION double_raw ( p_number IN NUMBER ) RETURN RAW IS
BEGIN

   RETURN UTL_RAW.CAST_FROM_BINARY_DOUBLE ( p_number );

END double_raw;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
PROCEDURE init_timing IS
BEGIN

   timing_table.DELETE;

END init_timing;
---------------------------------------------------------------------------------------
PROCEDURE start_timing ( p_label IN VARCHAR2 ) IS
BEGIN

   IF ( NOT timing_table.EXISTS ( p_label )) THEN

       timing_table ( p_label ).total_time := 0;
       timing_table ( p_label ).active_flag := 0;

   END IF;

   IF ( timing_table ( p_label ).active_flag = 0 ) THEN

       timing_table ( p_label ).start_time := DBMS_UTILITY.GET_TIME ();
       timing_table ( p_label ).active_flag := 1;

   END IF;
END start_timing;
---------------------------------------------------------------------------------------
PROCEDURE end_timing ( p_label IN VARCHAR2 ) IS
BEGIN

   IF ( timing_table.EXISTS ( p_label ) AND timing_table ( p_label ).active_flag = 1 ) THEN

        timing_table ( p_label ).active_flag := 0;
        timing_table ( p_label ).total_time := timing_table ( p_label ).total_time + (( DBMS_UTILITY.GET_TIME () - timing_table ( p_label ).start_time ) / 100.00 );

   END IF;
END end_timing;
---------------------------------------------------------------------------------------
PROCEDURE spool_timing_data ( p_run_id IN NUMBER ) IS

   l_value   VARCHAR2(4000);

BEGIN

   l_value := timing_table.FIRST;

   WHILE ( l_value IS NOT NULL ) LOOP

      report_info (
        p_message => l_value || ': ' || TO_CHAR ( timing_table ( l_value ).total_time )
      , p_run_id => p_run_id
      , p_model_id => null );
      l_value := timing_table.NEXT ( l_value );

   END LOOP;
END spool_timing_data;
---------------------------------------------------------------------------------------
/**
 This is an internal report procedure that is used by declared public report_
 procedures.
 */
PROCEDURE report_any_error (
  p_urgency     IN NUMBER
, p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS
PRAGMA AUTONOMOUS_TRANSACTION;

 l_fit_message CZ_DB_LOGS.MESSAGE%TYPE := NULL;
 l_fit_error_stack CZ_DB_LOGS.ERROR_STACK%TYPE := NULL;

BEGIN

 -- Truncate the message if it is more than 4000 characters

 IF p_message IS NOT NULL THEN
    l_fit_message := SUBSTR( p_message, 1, 4000 );
 END IF;

 -- Truncate the error stack if it is more than 4000 charcaters

 IF p_error_stack IS NOT NULL THEN
    l_fit_error_stack := SUBSTR( p_error_stack, 1, 4000 );
 END IF;

 /*
  List of all columns in CZ_DB_LOGS. Not all columns are populated because some
  of them are not relavent for FCE_COMPILE case.
    LOGTIME
    LOGUSER
    URGENCY
    CALLER
    STATUSCODE
    MESSAGE
    CREATED_BY
    CREATION_DATE
    SESSION_ID
    MESSAGE_ID
    RUN_ID
    MODEL_ID
    OBJECT_TYPE
    OBJECT_ID
    MODEL_CONVERSION_SET_ID
    ERROR_STACK
    PS_NODE_ID
    RULE_ID
   Note: STATUSCODE is currently displayed by CZ Developer to show the section
   where the validation exception happening. This must be changed to display
   stack traces associated with the message. In FCE we are inserting urgency
   code in place of status code.
   */

   INSERT INTO  CZ_DB_LOGS (
    LOGTIME, LOGUSER, URGENCY, CALLER, MESSAGE,
    RUN_ID, MODEL_ID, PS_NODE_ID, RULE_ID, ERROR_STACK, STATUSCODE, message_id )
   VALUES (
    SYSDATE, USER, p_urgency, 'CZ_FCE_COMPILE', l_fit_message,
    p_run_id, p_model_id, p_ps_node_id, p_rule_id, l_fit_error_stack, p_urgency, p_message_id );

   COMMIT;

EXCEPTION
 WHEN OTHERS THEN
  -- TODO SV:Find out in the case of logging failures what is the right thing to do?
  --         For now reraise the exception and let the caller decide what to do.
  RAISE;
END report_any_error;
---------------------------------------------------------------------------------------
/**
  This procedure is used to report the FCE model compile warnings.
  This procedure is responsible for truncating the message to the
  database limit of 4000 characters. Its sets the
  urgency level to 1.

    Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */

PROCEDURE report_warning (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

 REPORT_ANY_ERROR ( CONST_URGENCY_WARNING, p_message, p_run_id, p_model_id, p_ps_node_id, p_rule_id, p_error_stack, p_message_id );

END report_warning;
---------------------------------------------------------------------------------------
/**
  This procedure is used to report the FCE model compile system warnings.
  System warnings are caused most likely due to code bugs or
  environment level issues.
  This procedure is responsible for truncating the message to the
  database limit of 4000 characters. Its sets the
  urgency level to 1.

    Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */

PROCEDURE report_sys_warning (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

 -- TODO: SV Consider added an explicit exception message prefix that states
 --          this is a system type exception

 REPORT_ANY_ERROR ( CONST_URGENCY_WARNING, p_message, p_run_id, p_model_id, p_ps_node_id, p_rule_id, p_error_stack, p_message_id );

END report_sys_warning;
---------------------------------------------------------------------------------------
/**
 This procedure is used to report the FCE model compile errors that
 are caused due to the user defined model errors that can be fixed
 by the user.
 This procedure is responsible for truncating the message to the
 database limit of 4000 characters. Its sets the
 urgency level to 0.

   Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
*/
PROCEDURE report_error (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

 REPORT_ANY_ERROR ( CONST_URGENCY_ERROR, p_message, p_run_id, p_model_id, p_ps_node_id, p_rule_id, p_error_stack, p_message_id );

END report_error;
---------------------------------------------------------------------------------------
/**
 This procedure is used to report the FCE model compile errors that
 are caused due to the unexpected failures that are caused by the
 system errors. These errors are caused typically due to
 environment issues (like data corruption etc.), can potentially
 a code bug etc.

 This procedure is responsible for truncating the message to the
 database limit of 4000 characters. It sets the
 urgency level to 0.

   Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */
PROCEDURE report_system_error (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

 -- TODO: SV Consider added an explicit exception message that states
 --          this is a system type exception

 REPORT_ANY_ERROR ( CONST_URGENCY_ERROR, p_message, p_run_id, p_model_id, p_ps_node_id, p_rule_id, p_error_stack, p_message_id );

END report_system_error;
---------------------------------------------------------------------------------------
/**
 This procedure is used to report the FCE model information messages that
 are useful for debugging purposes or other information purposes.

 This procedure is responsible for truncating the message to the
 database limit of 4000 characters. It sets the
 urgency level to 0.

   Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */
PROCEDURE report_info (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

 REPORT_ANY_ERROR ( CONST_URGENCY_INFORMATION, p_message, p_run_id, p_model_id, p_ps_node_id, p_rule_id, p_error_stack, p_message_id );

END report_info;
---------------------------------------------------------------------------------------
/**
 This function returns the full path of the model for the given model id.
 For the root model id, only model name will be returned.
 */
FUNCTION GET_MODEL_PATH(
  p_model_id IN NUMBER,
  p_model_path IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
 l_model_name VARCHAR2(255) := NULL;
BEGIN
  IF p_model_path IS NULL THEN
   BEGIN --select name from cz_devl_projects where devl_project_id=285121
    EXECUTE IMMEDIATE 'SELECT NAME from cz_devl_projects where devl_project_id= :1'
    INTO l_model_name
    USING p_model_id;
    RETURN '"' || l_model_name || '"';
   EXCEPTION WHEN OTHERS THEN
    RETURN TO_CHAR(p_model_id);
   END;
  ELSE
    RETURN '"' || p_model_path || '"';
  END IF;
END;
---------------------------------------------------------------------------------------
/**
 This function returns the full path of the rule for the given rule id.
 */
FUNCTION GET_RULE_PATH(
  p_rule_id IN NUMBER,
  p_rule_name IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
 v_rule_type VARCHAR2(10) := 'RUL';
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT CASE WHEN rule_type = 30 THEN ''DCH'' WHEN rule_type=24 THEN ''XCP'' ELSE ''RUL'' END from cz_rules where rule_id = :1'
    INTO v_rule_type
    USING p_rule_id;
  EXCEPTION WHEN OTHERS THEN
    v_rule_type := 'RUL';
  END;
  RETURN '"' || CZ_DEVELOPER_UTILS_PVT.get_Rule_Folder_Path(p_rule_id, v_rule_type) || '"';
EXCEPTION WHEN OTHERS THEN
  IF p_rule_name IS NULL THEN
    RETURN TO_CHAR(p_rule_id);
  ELSE
    RETURN '"' || p_rule_name || '"';
  END IF;
END;
---------------------------------------------------------------------------------------
/**
 This function returns the full path of the node for the given node id.
 */
FUNCTION GET_NODE_PATH(
  p_node_id IN NUMBER,
  p_node_path IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
 l_node_name VARCHAR2(1000) := NULL;
BEGIN
  IF p_node_path IS NULL THEN
   BEGIN --select name from cz_devl_projects where devl_project_id=285121
    EXECUTE IMMEDIATE 'SELECT NAME from cz_ps_nodes where PS_NODE_ID = :1'
    INTO l_node_name
    USING p_node_id;
    RETURN '"' || l_node_name || '"';
   EXCEPTION WHEN OTHERS THEN
    RETURN TO_CHAR(p_node_id);
   END;
  ELSE
    RETURN '"' || p_node_path || '"';
  END IF;
END;
---------------------------------------------------------------------------------------
/**
 This function returns the full path of the property for the given property id.
 Note: Full path is needed for properties, because property names must be unique,
 and not allowed to be duplicate.
 */
FUNCTION GET_PROPERTY_PATH(
  p_prop_id IN NUMBER)
RETURN VARCHAR2 IS
  v_prop_name VARCHAR2(255) := null;
BEGIN
  EXECUTE IMMEDIATE 'select name from cz_properties where property_id=:1'
  INTO v_prop_name
  USING p_prop_id;
  RETURN '"' || v_prop_name || '"';
EXCEPTION WHEN OTHERS THEN
 BEGIN
  EXECUTE IMMEDIATE 'select name from cz_system_properties_v where rule_id=:1'
  INTO v_prop_name
  USING p_prop_id;
  RETURN '"' || v_prop_name || '"';
 EXCEPTION WHEN OTHERS THEN
  RETURN '"' || TO_CHAR(p_prop_id) || '"';
 END;
END;
---------------------------------------------------------------------------------------
END;

/
