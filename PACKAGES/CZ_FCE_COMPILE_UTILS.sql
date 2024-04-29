--------------------------------------------------------
--  DDL for Package CZ_FCE_COMPILE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_FCE_COMPILE_UTILS" AUTHID CURRENT_USER AS
/*	$Header: czfceuts.pls 120.9 2008/03/12 20:04:20 asiaston ship $		*/
---------------------------------------------------------------------------------------
const_iconst_min               CONSTANT NUMBER        := -1;
const_iconst_max               CONSTANT NUMBER        := 5;
const_min_unsigned_byte        CONSTANT NUMBER        := 0;
const_max_unsigned_byte        CONSTANT NUMBER        := 255;
const_min_byte                 CONSTANT PLS_INTEGER   := -128;
const_max_byte                 CONSTANT PLS_INTEGER   := 127;
const_min_unsigned_word        CONSTANT NUMBER        := 0;
const_max_unsigned_word        CONSTANT NUMBER        := 65535;
const_min_word                 CONSTANT PLS_INTEGER   := -32768;
const_max_word                 CONSTANT PLS_INTEGER   := 32767;
const_min_integer              CONSTANT PLS_INTEGER   := -2147483648;
const_max_integer              CONSTANT PLS_INTEGER   := 2147483647;
const_max_unsigned_long        CONSTANT NUMBER        := 18446744073709551616;  -- 2^64
const_min_long                 CONSTANT NUMBER        := -9223372036854775808;
const_max_long                 CONSTANT NUMBER        := 9223372036854775807;

-- CZ_DB_LOGS.URGENCY valid values
CONST_URGENCY_ERROR                 CZ_DB_LOGS.URGENCY%TYPE := 0;
CONST_URGENCY_WARNING               CZ_DB_LOGS.URGENCY%TYPE := 1;
CONST_URGENCY_INFORMATION           CZ_DB_LOGS.URGENCY%TYPE := 2;

---------------------------------------------------------------------------------------
cz_cpl_internal_float          EXCEPTION;
---------------------------------------------------------------------------------------
FUNCTION assert_unsigned_byte ( p_int IN PLS_INTEGER ) RETURN BOOLEAN;
FUNCTION assert_byte ( p_int IN PLS_INTEGER ) RETURN BOOLEAN;
FUNCTION assert_unsigned_word ( p_int IN PLS_INTEGER ) RETURN BOOLEAN;
FUNCTION assert_word ( p_int IN PLS_INTEGER ) RETURN BOOLEAN;
FUNCTION assert_iconst ( p_int IN PLS_INTEGER ) RETURN BOOLEAN;
FUNCTION assert_integer ( p_int IN NUMBER ) RETURN BOOLEAN;
FUNCTION assert_long ( p_int IN NUMBER ) RETURN BOOLEAN;
FUNCTION unsigned_byte ( p_int IN PLS_INTEGER ) RETURN RAW;
FUNCTION byte ( p_int IN PLS_INTEGER ) RETURN RAW;
FUNCTION unsigned_word ( p_int IN PLS_INTEGER ) RETURN RAW;
FUNCTION word ( p_int IN PLS_INTEGER ) RETURN RAW;
FUNCTION integer_raw ( p_int IN NUMBER ) RETURN RAW;
FUNCTION long_raw ( p_int IN NUMBER ) RETURN RAW;
FUNCTION float_raw ( p_number IN NUMBER ) RETURN RAW;
FUNCTION double_raw ( p_number IN NUMBER ) RETURN RAW;
---------------------------------------------------------------------------------------
PROCEDURE init_timing;
PROCEDURE start_timing ( p_label IN VARCHAR2 );
PROCEDURE end_timing ( p_label IN VARCHAR2 );
PROCEDURE spool_timing_data ( p_run_id IN NUMBER );
---------------------------------------------------------------------------------------
-- Report procedures
/**
  This procedure is used to report the FCE model compile warnings.
  This procedure is responsible for truncating the message to the
  database limit of 4000 characters. Its sets the
  urgency level to 1.

    Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */

PROCEDURE REPORT_WARNING (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
);

/**
  This procedure is used to report the FCE model compile system warnings.
  System warnings are caused most likely due to code bugs or
  environment level issues.
  This procedure is responsible for truncating the message to the
  database limit of 4000 characters. Its sets the
  urgency level to 1.

    Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */

PROCEDURE REPORT_SYS_WARNING (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
);


/**
 This procedure is used to report the FCE model compile errors that
 are caused due to the user defined model errors that can be fixed
 by the user.
 This procedure is responsible for truncating the message to the
 database limit of 4000 characters. Its sets the
 urgency level to 0.

   Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
*/
PROCEDURE REPORT_ERROR (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
);

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
PROCEDURE REPORT_SYSTEM_ERROR (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
);

/**
 This procedure is used to report the FCE model information messages that
 are useful for debugging purposes or other information purposes.

 This procedure is responsible for truncating the message to the
 database limit of 4000 characters. It sets the
 urgency level to 0.

   Note: URGENCY - 0 - fatal error, 1 - warning, 2 - informational message;
 */
PROCEDURE REPORT_INFO (
  p_message     IN VARCHAR2
, p_run_id      IN NUMBER
, p_model_id    IN NUMBER
, p_ps_node_id  IN NUMBER DEFAULT NULL
, p_rule_id     IN NUMBER DEFAULT NULL
, p_error_stack IN VARCHAR2 DEFAULT NULL
, p_message_id  IN VARCHAR2 DEFAULT NULL
);
---------------------------------------------------------------------------------------
/**
 This function returns the full path of the model for the given model id.
 For the root model id, only model name will be returned.
 */
FUNCTION GET_MODEL_PATH (
  p_model_id IN NUMBER,
  p_model_path IN VARCHAR2 DEFAULT NULL )
RETURN VARCHAR2;

/**
 This function returns the full path of the rule for the given rule id.
 */
FUNCTION GET_RULE_PATH (
  p_rule_id IN NUMBER,
  p_rule_name IN VARCHAR2 DEFAULT NULL )
RETURN VARCHAR2;

/**
 This function returns the full path of the node for the given node id.
 */
FUNCTION GET_NODE_PATH (
  p_node_id IN NUMBER,
  p_node_path IN VARCHAR2 DEFAULT NULL )
RETURN VARCHAR2;

/**
 This function returns the full path of the property for the given property id.
 */
FUNCTION GET_PROPERTY_PATH (
  p_prop_id IN NUMBER )
RETURN VARCHAR2;
---------------------------------------------------------------------------------------
END;

/
