--------------------------------------------------------
--  DDL for Package CZ_FCE_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_FCE_COMPILE" AUTHID CURRENT_USER AS
/*	$Header: czfcecps.pls 120.39 2008/05/12 21:06:12 asiaston ship $		*/
---------------------------------------------------------------------------------------
TYPE type_varchar1_table          IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE type_varchar16_table         IS TABLE OF VARCHAR2(16) INDEX BY BINARY_INTEGER;
TYPE type_varchar4000_table       IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE type_integer_table           IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
TYPE type_number_table            IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE type_date_table              IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE type_byte_table              IS TABLE OF RAW(1) INDEX BY VARCHAR2(30);

TYPE type_meta_hashtable          IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);
TYPE type_data_hashtable          IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(4000);
TYPE type_node_hashtable          IS TABLE OF NUMBER INDEX BY VARCHAR2(4000);
TYPE type_name_hashtable          IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
TYPE type_flag_hashtable          IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(4000);
TYPE type_date_hashtable          IS TABLE OF DATE INDEX BY VARCHAR2(4000);
TYPE type_bool_hashtable          IS TABLE OF BOOLEAN INDEX BY VARCHAR2(4000);

TYPE type_datahashtable_hashtable IS TABLE OF type_data_hashtable INDEX BY VARCHAR2(4000);
TYPE type_integertable_hashtable  IS TABLE OF type_integer_table INDEX BY VARCHAR2(4000);
TYPE type_numbertable_hashtable   IS TABLE OF type_number_table INDEX BY VARCHAR2(4000);
TYPE type_nodehashtable_hashtable IS TABLE OF type_node_hashtable INDEX BY VARCHAR2(4000);
TYPE type_numbertable_table       IS TABLE OF type_number_table INDEX BY PLS_INTEGER;
TYPE type_integertable_table      IS TABLE OF type_integer_table INDEX BY PLS_INTEGER;
TYPE type_nodehashtable_table     IS TABLE OF type_node_hashtable INDEX BY PLS_INTEGER;
TYPE type_datahashtable_table     IS TABLE OF type_data_hashtable INDEX BY PLS_INTEGER;
TYPE type_varchar4000table_table  IS TABLE OF type_varchar4000_table INDEX BY PLS_INTEGER;

TYPE expression_context           IS RECORD (
    context_type                  PLS_INTEGER
  , context_num_data              PLS_INTEGER
  , context_data                  VARCHAR2(4000)
  );

TYPE type_iterator_node           IS RECORD (
    ps_node_id                    NUMBER
  , model_ref_expl_id             NUMBER
  , argument_name                 VARCHAR2(4000)
  , expr_index                    PLS_INTEGER
  );

TYPE type_iteratornode_table      IS TABLE OF type_iterator_node INDEX BY BINARY_INTEGER;

TYPE type_iterator_value          IS RECORD (
    value_type                    PLS_INTEGER
  , ps_node_id                    NUMBER
  , model_ref_expl_id             NUMBER
  , data_value                    VARCHAR2(4000)
  , data_num_value                NUMBER
  , data_type                     NUMBER
  );

TYPE type_iterator_table          IS TABLE OF type_iterator_value INDEX BY BINARY_INTEGER;
TYPE type_iteratortable_table     IS TABLE OF type_iterator_table INDEX BY BINARY_INTEGER;

TYPE type_contributor_record      IS RECORD (
    effective_from                DATE
  , effective_until               DATE
  , effective_usage_mask          VARCHAR2(16)
  , interval_key                  VARCHAR2(4000)
  , quantifiers                   type_varchar4000_table
  , hash_quantifiers              type_data_hashtable
  );

TYPE type_contributor_table       IS TABLE OF type_contributor_record INDEX BY BINARY_INTEGER;
TYPE type_contributortable_table  IS TABLE OF type_contributor_table INDEX BY BINARY_INTEGER;

TYPE type_compat_table            IS RECORD (
    participants                  type_iteratornode_table
  , combinations                  type_iteratortable_table
  );

TYPE type_compattable_table       IS TABLE OF type_compat_table INDEX BY BINARY_INTEGER;

TYPE type_iterator_hashtable      IS TABLE OF type_iterator_value INDEX BY VARCHAR2(4000);
TYPE type_iteratorhashtable_table IS TABLE OF type_iterator_hashtable INDEX BY BINARY_INTEGER;

TYPE type_integervalue_table      IS TABLE OF type_integertable_table INDEX BY BINARY_INTEGER;
TYPE type_numbervalue_table       IS TABLE OF type_numbertable_table INDEX BY BINARY_INTEGER;
TYPE type_varchar4000value_table  IS TABLE OF type_varchar4000table_table INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------------------------
-- Exceptions and Messages
---------------------------------------------------------------------------------------
-- Warning exceptions are reported and logic gen will not be stopped
-- User warnings: User can make corrections to avoid warnings
CZ_LOGICGEN_WARNING     EXCEPTION; -- (Must use CZ_FCE_W_ prefix for message names)
-- System warnings: Caused due to either an environment or code issues
CZ_LOGICGEN_SYS_WARNING EXCEPTION; -- (Must use CZ_FCE_SW_ prefix for message names)
-- Errors are reoprted and logic gen will be stopped
-- User errors: User can make corrections to avoid these errors
CZ_LOGICGEN_ERROR       EXCEPTION; -- (Must use CZ_FCE_E_ prefix for message names)
-- System errors: Caused due to either an environment or code issues
CZ_LOGICGEN_SYS_ERROR   EXCEPTION; -- (Must use CZ_FCE_SE_ prefix for message names)

---------------------------------------------------------------------------------------
-- Messages that must be translated
---------------------------------------------------------------------------------------
--  Note: Use this query to get this list from the FND_NEW_MESSAGES
/* select mtext from (
select message_name, message_name || ' CONSTANT VARCHAR2(30) := ''' || message_name || ''';' mtext from fnd_new_messages where message_name like 'CZ_FCE%'
UNION ALL
select message_name, '--  ' || REPLACE(message_text, '&', '^') mtext from fnd_new_messages where message_name like 'CZ_FCE%'
)
order by message_name desc, mtext asc */
---------------------------------------------------------------------------------------
--  The rule is incomplete because a property is undefined. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_UNDEFINED_PROPERTY CONSTANT VARCHAR2(30) := 'CZ_FCE_W_UNDEFINED_PROPERTY';
--  Invalid or incomplete rule, please check the rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_TEMPLATE_INVALID CONSTANT VARCHAR2(30) := 'CZ_FCE_W_TEMPLATE_INVALID';
--  Defaults and search decisions cannot be defined across different models.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_SD_NOT_ACROSS_MODELS CONSTANT VARCHAR2(30) := 'CZ_FCE_W_SD_NOT_ACROSS_MODELS';
--  Property ^PROP_NAME has no value for node ^NODE_NAME. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_PROPERTY_NULL_VALUE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_PROPERTY_NULL_VALUE';
--  Parsing errors found. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_PARSE_FAILED CONSTANT VARCHAR2(30) := 'CZ_FCE_W_PARSE_FAILED';
--  Property ^PROP_NAME is not defined for node ^NODE_NAME.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NO_PROPERTY_FOR_NODE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NO_PROPERTY_FOR_NODE';
--  The primary feature in the design chart is either missing or duplicated.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NO_PRIMARY_FEAT_DC CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NO_PRIMARY_FEAT_DC';
--  BOM node ^NODE_NAME has no optional selections to participate in rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NO_OPTIONAL_CHILDREN CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NO_OPTIONAL_CHILDREN';
--  System properties DefinitionMinInstances and DefinitionMaxInstances cannot directly participate in rules.  Rule ^RULE_NAME  in the Model ^MODEL_NAME ignored.
-- CZ_FCE_W_NO_MINMAX_INSTANCES CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NO_MINMAX_INSTANCES';
--  No selection made between primary and defining feature in design chart rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NO_COMBINATIONS_DC CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NO_COMBINATIONS_DC';
--  Node ^NODE_NAME has no children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NODE_MUST_HAVE_CHILD CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NODE_MUST_HAVE_CHILD';
--  Rule participant ^NODE_NAME has been deleted.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NODE_DELETED CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NODE_DELETED';
--  COLLECT DISTINCT and FOR ALL operations are not supported when there is more than one iterator.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_MORE_THAN_ONE_IT_LIM CONSTANT VARCHAR2(30) := 'CZ_FCE_W_MORE_THAN_ONE_IT_LIM';
--  Right-hand side participants are missing.  Logic rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_LR_MISSING_RHS_PARTS CONSTANT VARCHAR2(30) := 'CZ_FCE_W_LR_MISSING_RHS_PARTS';
--  Left-hand side participants are missing.  Logic rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_LR_MISSING_LHS_PARTS CONSTANT VARCHAR2(30) := 'CZ_FCE_W_LR_MISSING_LHS_PARTS';
--  No one-to-one correspondence between options of primary and defining feature in design chart rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_INVALID_NUM_COMB_DC CONSTANT VARCHAR2(30) := 'CZ_FCE_W_INVALID_NUM_COMB_DC';
--  A contribution expression that uses a participant which is under an instantiable Component or referenced Model cannot also use another participant. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_INVALID_CONTRIB CONSTANT VARCHAR2(30) := 'CZ_FCE_W_INVALID_CONTRIB';
--  The reference ^NODE_NAME is invalid. At least one node does not exist in the Model or is not effective when the rule is effective. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_INCORRECT_REFERENCE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_INCORRECT_REFERENCE';
--  Incomplete simple Property-based Compatibility rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_INCOMPLETE_PROPBASED CONSTANT VARCHAR2(30) := 'CZ_FCE_W_INCOMPLETE_PROPBASED';
--  Heuristic operators (IncMin, DecMax, Assign, MinFirst, MaxFirst) can only be used in defaults or search decisions.  Rule ^RULE_NAME in model ^MODEL_NAME ignored.
CZ_FCE_W_HEUR_ONLY_IN_DEF CONSTANT VARCHAR2(30) := 'CZ_FCE_W_HEUR_ONLY_IN_DEF';
--  Rule definition is empty.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_EMPTY_RULE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_EMPTY_RULE';
--  Design chart is empty.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_EMPTY_DESIGN_CHART CONSTANT VARCHAR2(30) := 'CZ_FCE_W_EMPTY_DESIGN_CHART';
--  System Property ^PROP_NAME is invalid in WHERE clause of a COMPATIBLE or FORALL operator because it is translatable. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_DESCRIPTION_IN_WHERE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_DESCRIPTION_IN_WHERE';
--  Only one participant of a compatibility rule is allowed to have non-mutually-exclusive children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_CT_ONLY_ONE_NON_MEXC CONSTANT VARCHAR2(30) := 'CZ_FCE_W_CT_ONLY_ONE_NON_MEXC';
-- Incomplete Compatibility rule: participants or selections are missing.  Rule ^RULE_NAME in the model ^MODEL_NAME ignored.
CZ_FCE_W_CT_INCOMPLETE_RULE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_CT_INCOMPLETE_RULE';
--  Cyclic relationship between compatibility rule participants.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_CT_CYCLIC_RELATION CONSTANT VARCHAR2(30) := 'CZ_FCE_W_CT_CYCLIC_RELATION';
--  Right-hand side participants are missing.  Comparison rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_CR_MISSING_RHS_PARTS CONSTANT VARCHAR2(30) := 'CZ_FCE_W_CR_MISSING_RHS_PARTS';
--  Compatibility rule must have at least two participating features. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_COMPAT_SINGLE_FEAT CONSTANT VARCHAR2(30) := 'CZ_FCE_W_COMPAT_SINGLE_FEAT';
--  No valid combinations. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_COMPAT_NO_COMB CONSTANT VARCHAR2(30) := 'CZ_FCE_W_COMPAT_NO_COMB';
--  Invalid participant in compatibility rule.  Valid participants are Option Feature or BOM Option Class nodes.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_CMR_INVALID_PART CONSTANT VARCHAR2(30) := 'CZ_FCE_W_CMR_INVALID_PART';
--  Unable to resolve Model node reference ^NODE_NAME because it is ambiguous. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_AMBIGUOUS_REFERENCE CONSTANT VARCHAR2(30) := 'CZ_FCE_W_AMBIGUOUS_REFERENCE';
--  Property ^PROP_NAME is only applicable to nodes that can contain instances. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_PROP_ONLY_ICOMP_REF CONSTANT VARCHAR2(30) := 'CZ_FCE_W_PROP_ONLY_ICOMP_REF';
--  Property ^PROP_NAME is invalid for the node ^NODE_NAME. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_INVALID_PROPERTY CONSTANT VARCHAR2(30) := 'CZ_FCE_W_INVALID_PROPERTY';
-- Only static System Properties are allowed in the WHERE clause of a COMPATIBLE or FORALL operator.
-- The value of the System Property ^PROPERTY_NAME can change at runtime, therefore it is invalid in
-- this context. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_PROPERTY_NOT_STATIC CONSTANT VARCHAR2(30) := 'CZ_FCE_W_PROPERTY_NOT_STATIC';
-- Rule participant ^NODE_NAME is not accessible. May be its model reference has been deleted. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_NODE_NOT_FOUND CONSTANT VARCHAR2(30) := 'CZ_FCE_W_NODE_NOT_FOUND';
-- Incorrect COLLECT or FOR ALL Rule: The conditional expression in the WHERE clause must be static. A dynamic source for
-- a value provided for iterator ^ITER was detected.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
CZ_FCE_W_DYNAMIC_ITERATOR CONSTANT VARCHAR2(30) := 'CZ_FCE_W_DYNAMIC_ITERATOR';

--  Unknown Error:
CZ_FCE_UE_GENERIC_PREFIX CONSTANT VARCHAR2(30) := 'CZ_FCE_UE_GENERIC_PREFIX';
--  System Warning: Generally caused by environment or system issues.
CZ_FCE_SW_GENERIC_PREFIX CONSTANT VARCHAR2(30) := 'CZ_FCE_SW_GENERIC_PREFIX';
--  System Error: Generally caused by environment or system issues.
CZ_FCE_SE_GENERIC_PREFIX CONSTANT VARCHAR2(30) := 'CZ_FCE_SE_GENERIC_PREFIX';
--  Invalid problem definition: Option Feature with maximum quantity greater than 0 must have children. The Option Feature is ^NODE_NAME in the Model ^MODEL_NAME.
CZ_FCE_E_OPTION_MAXQ_NO_CHILD CONSTANT VARCHAR2(30) := 'CZ_FCE_E_OPTION_MAXQ_NO_CHILD';
--  Node ^NODE_NAME in Model ^MODEL_NAME is a Connector. In this release, Connectors are only supported in Orginal Configuration Engine type models.
CZ_FCE_E_CONNECTNOTSUPPORTED CONSTANT VARCHAR2(30) := 'CZ_FCE_E_CONNECTNOTSUPPORTED';

---------------------------------------------------------------------------------------
-- Messages that do not need translations
---------------------------------------------------------------------------------------
-- System Errors
CZ_FCE_SE_POINTER_TOO_LONG CONSTANT VARCHAR2(4000) :=
    'Pointer too long in emit_ldc.';
CZ_FCE_SE_STRING_TOO_LONG CONSTANT VARCHAR2(4000) :=
    'String constant is too long.';
CZ_FCE_SE_INTEGER_TOO_LONG CONSTANT VARCHAR2(4000) :=
    'Integer constant is too long, value = ^VALUE.';
CZ_FCE_SE_LONG_TOO_LONG CONSTANT VARCHAR2(4000) :=
    'Long constant is too long, value = ^VALUE.';
CZ_FCE_SE_METHODIX_OUTOFRANGE CONSTANT VARCHAR2(4000) :=
    'Method descriptor index is out of range, value = ^VALUE.';
CZ_FCE_SE_UNKNOWN_OPERATION CONSTANT VARCHAR2(4000) :=
    'Unknown register operation: ^OPERATION';
CZ_FCE_SE_INVALID_ACCESS_VAR CONSTANT VARCHAR2(4000) :=
    '"^OPERATION" instruction can only access variables from 0 to 255, attempt to access variable #^VAR.';
CZ_FCE_SE_INVALID_ACCESS_VARW CONSTANT VARCHAR2(4000) :=
    '"^OPERATION_w" instruction can only access variables from 0 to 65535, attempt to access variable #^VAR.';
CZ_FCE_SE_UNDEFINED_LOCAL_VAR CONSTANT VARCHAR2(4000) :=
    'Local variable is not defined for key: "^KEY".';
CZ_FCE_SE_NO_MORE_REGISTERS CONSTANT VARCHAR2(4000) :=
    'No registers available, all are allocated.';
CZ_FCE_SE_UNDEFINED_REGISTER CONSTANT VARCHAR2(4000) :=
    'Register is not defined for key: "^KEY".';
CZ_FCE_SE_INCORRECT_IX CONSTANT VARCHAR2(4000) :=
    'Incorrect index "^VALUE" to object type for array.';
CZ_FCE_SE_EXCEED_INTTABLESIZE CONSTANT VARCHAR2(4000) :=
    'Exceeded maximum supported integer table, size of the current table is "^VALUE".';
CZ_FCE_SE_UNKNOWN_IN_RULE  CONSTANT VARCHAR2(4000) :=
    'In the rule ^RULE_NAME, unknown system error occurred.';
CZ_FCE_SE_REVCONNMODELNOTFOUND CONSTANT VARCHAR2(4000) :=
    'Reverse Connector target model "^MODELNAME" not found in the repository.';
CZ_FCE_SE_OPTION_MAXQ_NOT_ZERO CONSTANT VARCHAR2(4000) :=
    'Invalid problem definition: maximum quantity per option cannot be 0 for a "option quantities" enabled Option Feature "^NODE_NAME".';

-- System Warnings

CZ_FCE_SW_NO_VALID_CHILDREN   CONSTANT VARCHAR2(4000)  :=
  'Node ^NODE_NAME has no children. Rule ^RULE_NAME in the Model ^MODEL_NAME" ignored.';
CZ_FCE_SW_UKNOWN_OP_IN_COMPAT  CONSTANT VARCHAR2(4000) :=
  'Unknown operator in the WHERE clause. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNKNOWN_EXPR_TYPE      CONSTANT VARCHAR2(4000) :=
  'Unknown expression type in the rule. Rule ^RULE_NAME in the Model ^MODEL_NAME" ignored.';
CZ_FCE_SW_UNKNOWN_OP_TYPE  CONSTANT VARCHAR2(4000) :=
  'Unknown operator type "^OPERTYPE" in the rule. Rule ^RULE_NAME in the Model ^MODEL_NAME" ignored.';
CZ_FCE_SW_WRONG_OPER_IN_COMPAT   CONSTANT VARCHAR2(4000) :=
  'Invalid operator in compatibility rule. Rule ^RULE_NAME in the Model ^MODEL_NAME" ignored.';
CZ_FCE_SW_NODEINCORRECTEFFSET CONSTANT VARCHAR2(4000) :=
    'Effectivity set, assigned to the node ^NODE_NAME in the Model ^MODEL_NAME, does not exist. Effectivity interval of the node will be used.';
CZ_FCE_SW_RULEINCORRECTEFFSET CONSTANT VARCHAR2(4000) :=
    'Effectivity set, assigned to the rule ^RULE_NAME in the Model ^MODEL_NAME, does not exist. Effectivity interval of the rule will be used.';
CZ_FCE_SW_INCORRECT_EXPL_ID CONSTANT VARCHAR2(4000) :=
     'Incorrect explosion_id "^EXPLOSION_ID" occurred. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_BOM_INVAL_CHILD_TYP CONSTANT VARCHAR2(4000) :=
    'Type ^TYPE is not a known BOM child node type. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNKNOWN_TEMPLATE CONSTANT VARCHAR2(4000) :=
    'Unknown property template "^TEMPLATE" found. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_OPTIONS_PARENT_NULL CONSTANT VARCHAR2(4000) :=
    'Parent is null for property Options() in logical context. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_OPTIONS_PARENT_INVA CONSTANT VARCHAR2(4000) :=
    'Invalid parent operator "^OPERATOR" for property options(). Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_BOM_NUM_INVALPROP CONSTANT VARCHAR2(4000) :=
    'In the numeric context invalid property applied to a BOM node. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNKNOWN_CONTEXT CONSTANT VARCHAR2(4000) :=
    'Unknown context occurred for options(). Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_LIT_DTYPE CONSTANT VARCHAR2(4000) :=
    'Invalid literal data type "^TYPE" found for the expression with the id ^EXPR_ID. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVAL_CONST_DTYPE CONSTANT VARCHAR2(4000) :=
    'Invalid constant data type "^TYPE" found. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NULL_CONSTANT_VALUE CONSTANT VARCHAR2(4000) :=
    'Null constant value occurred. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_PROP_ID_EXPR_ID CONSTANT VARCHAR2(4000) :=
    'No property id found for the expression id "^EXPR_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_TYPE_FOR_PROP_ID CONSTANT VARCHAR2(4000) :=
    'No property type foound for the property id "^PROP_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NOT_STATIC_PROPERTY CONSTANT VARCHAR2(4000) :=
    'Property with the template id "^PROP_ID" is not static. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_FAILED_NODE_PROP CONSTANT VARCHAR2(4000) :=
    'Node ''^NODE_NAME'' property with the id "^PROP_ID" is failed. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_TEXT_PROP CONSTANT VARCHAR2(4000) :=
    'Found property with the id "^PROP_ID" as text property. Rules cannot handle text properties. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CT_INCORRECT_SIZE CONSTANT VARCHAR2(4000) :=
    'Incorrect size of a compatible combination occurred. Compatibility Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_VALUE_PARAMSTK CONSTANT VARCHAR2(4000) :=
    'Value does not exist on parameter stack for parameter "^PARAM". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVAL_VAL_PARAMSTK CONSTANT VARCHAR2(4000) :=
    'In paramater stack invalid value type ^VALUE_TYPE associated with the parameter "^PARAM". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVAL_E_ID_IN_WHERE CONSTANT VARCHAR2(4000) :=
    'Unknown expression node type in the WHERE clause, expr_node_id "^EXPR_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_EXPR_NODE CONSTANT VARCHAR2(4000) :=
    'Invalid expression node of type ''^EXPR_TYPE'' found in iterator definition. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INCOMPLETE_FOR_ALL CONSTANT VARCHAR2(4000) :=
    'Incomplete forall rule, no iterator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_PROP_IN_WHERE CONSTANT VARCHAR2(4000) :=
    'WHERE clause do not have property. Only "literal iterator" can have where clause without any property. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_IT_VALUE CONSTANT VARCHAR2(4000) :=
    'Found invalid iterator value type "^VALUE". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NON_LIT_IN_COLLECT CONSTANT VARCHAR2(4000) :=
    'Found non-literal value type in COLLECT DISTINCT. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_ARG_PARAM CONSTANT VARCHAR2(4000) :=
    'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_PROP_NOT_DEFINED CONSTANT VARCHAR2(4000) :=
    'Property is not defined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_STRUCTURE CONSTANT VARCHAR2(4000) :=
    'Invalid structure of a compatibility rule. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_ITERATOR CONSTANT VARCHAR2(4000) :=
    'No iterator specified. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVALID_NUMBER CONSTANT VARCHAR2(4000) :=
    'Invalid number "^VALUE" found. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_LR_MISSING_LHS_OP CONSTANT VARCHAR2(4000) :=
    'Left-hand side operator is either not-specified or invalid. Logic rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_LR_MISSING_LOGIC_OP CONSTANT VARCHAR2(4000) :=
    'Logic operator is either not-specified or invalid. Logic rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_LR_MISSING_RHS_OP CONSTANT VARCHAR2(4000) :=
    'Right-hand side operator is either not-specified or invalid. Logic rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CR_NO_LHS_OPAND CONSTANT VARCHAR2(4000) :=
    'Left-hand side operands to comparison operator is either not-specified or invalid. Comparison rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CR_NO_OPERATOR CONSTANT VARCHAR2(4000) :=
    'Comparison operator is either not-specified or invalid. Comparison rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CR_NO_RHS_OPAND CONSTANT VARCHAR2(4000) :=
    'Right-hand side operand to comparison operator is either not-specified or invalid. Comparison rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CR_NO_LOGIC_OP CONSTANT VARCHAR2(4000) :=
    'Logic operator is either not-specified or invalid. Comparison rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_CR_NO_RHS_OP CONSTANT VARCHAR2(4000) :=
    'Right-hand side operator is either not-specified or invalid. Comparison rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW__NO_MATH_CONST CONSTANT VARCHAR2(4000) :=
    'Mathematical constant is not implemented for template_id "^TEMPL_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW__NO_MATH_OP CONSTANT VARCHAR2(4000) :=
    'Mathematical operator is not implemented for template_id "^TEMPL_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_INVAL_SPROP_SELECT CONSTANT VARCHAR2(4000) :=
    'Invalid system property is used with the "Selection()" operator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

-- Rule Expression(RE) level Warnings
CZ_FCE_SW_RE_ENODE_CHILDREN CONSTANT VARCHAR2(4000) :=
    'The expression node with the id-^EXPR_ID must have child expression nodes. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_RE_ENODE_ONE_CHILD CONSTANT VARCHAR2(4000) :=
    'The expression node with the id-^EXPR_ID must have exactly one child. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_RE_ENODE_TWO_CHILD CONSTANT VARCHAR2(4000) :=
    'The expression node with the id-^EXPR_ID must have exactly one child. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_RE_ENODE_NO_DTYPE CONSTANT VARCHAR2(4000) :=
    'Unable to get context data type for expression node with the id "^EXPR_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_RE_ENSARG_NO_DTYPE CONSTANT VARCHAR2(4000) :=
    'Unable to get the data type of the argument "^ARG_IX" for signature "^SIGNATURE_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

CZ_FCE_SW_DEFPROP_INVAL_CTX CONSTANT VARCHAR2(4000) :=
    'Invalid context found for applying default property. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

CZ_FCE_SW_INVALID_PROP_USAGE CONSTANT VARCHAR2(4000) :=
    'In the rule ^RULE_NAME, found invalid usage of the property. Only structure nodes can have user or system properties. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

-- Simple accumulator rules (AR) related
CZ_FCE_SW_AR_NO_LHS_OPAND CONSTANT VARCHAR2(4000) :=
    'Left-hand side operand to comparison operator is either not-specified or invalid. Accumulator Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_AR_NO_MLTIPLIER CONSTANT VARCHAR2(4000) :=
    'Multiplier not-specified. Accumulator Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_AR_NO_OPERATOR CONSTANT VARCHAR2(4000) :=
    'Accumulator operator is either not-specified or invalid. Accumulator Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_AR_NO_ROUND_OP CONSTANT VARCHAR2(4000) :=
    'Round operator is either not-specified or invalid. Accumulator Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_AR_NO_RHS_OPAND VARCHAR2(4000) :=
    'Right-hand side operand to accumulator operator is either not-specified or invalid. Accumulator Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

CZ_FCE_SW_INVAL_FEAT_TYPE_DC CONSTANT VARCHAR2(4000) :=
    'Found invalid feature type "^FEAT_TYPE". Design Chart Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

-- Compile Constraints
CZ_FCE_SW_UNDEFINED_STRUC_NODE CONSTANT VARCHAR2(4000) :=
    'Incomplete rule: structure node is undefined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNDEFINED_SYS_PROP CONSTANT VARCHAR2(4000) :=
    'Incomplete rule: system property is undefined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNDEFINED_OPERATOR CONSTANT VARCHAR2(4000) :=
    'Incomplete rule: operator is undefined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNDEFINED_OP_TEMPL CONSTANT VARCHAR2(4000) :=
    'Incomplete rule: operator template is undefined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_UNDEFINED_OP_BY_NAME CONSTANT VARCHAR2(4000) :=
    'Incomplete rule: operator by name is undefined. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_NO_INTL_TEXT CONSTANT VARCHAR2(4000) :=
    'Localized text record does not exist for reason_id. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

-- must have children
 -- parse_where_clause
CZ_FCE_SW_SNODE_WHERE_LIMITS CONSTANT VARCHAR2(4000) :=
    'Structure node can only participate in a WHERE clause of a Property-based Compatibility rule. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- generate_iterator
CZ_FCE_SW_INCOMPLETE_FORALL CONSTANT VARCHAR2(4000) :=
    'Incomplete forall rule, empty iterator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- parse_template_application
 -- generate_heuristics
CZ_FCE_SW_INCOMPLETE_SEARCH CONSTANT VARCHAR2(4000) :=
    'Incomplete Default or Search Decision. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- generate_power
CZ_FCE_SW_INCOMPLETE_POWER CONSTANT VARCHAR2(4000) :=
    'Incomplete power operator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- generate_mathrounding
CZ_FCE_SW_INCOMPLETE_MROUND CONSTANT VARCHAR2(4000) :=
    'Incomplete math rounding operator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- generate_trigonometric
CZ_FCE_SW_INCOMPLETE_TRIG CONSTANT VARCHAR2(4000) :=
    'Incomplete math trigonometric operator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
 -- generate_aggregatesum
CZ_FCE_SW_INCOMPLETE_AGSUM CONSTANT VARCHAR2(4000) :=
    'Incomplete AggregateSum operator. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
-- must_be_structure_node
CZ_FCE_SW_SD_OPAND_STRUCT_N CONSTANT VARCHAR2(4000) :=
    'Invalid default or search decision is found. Here operand can only be a structure node. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_AS_OPAND_STRUCT_N CONSTANT VARCHAR2(4000) :=
    'Invalid AggregateSum operator is found. Here operand can only be a structure node. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

CZ_FCE_SW_EXPR_N_MUST_STRUC_N CONSTANT VARCHAR2(4000) :=
    'Expression node expr_node_id ^EXPR_ID must represent a structure node. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_EXP_PWR_MUST_BE_INT CONSTANT VARCHAR2(4000) :=
    'The exponent of the power operaror must be an integer constant. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

-- node_must_be_port
CZ_FCE_SW_NODE_MUST_BE_PORT CONSTANT VARCHAR2(4000) :=
    'Node ^NODE_NAME must be a component or model reference or connector. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
  -- generate_expression
CZ_FCE_SW_AS_PORT_LIMITS CONSTANT VARCHAR2(4000) :=
    'Only References and Components can participate in Union or SubsetOf operations. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_COMPARE_TXPROP_TXLIT CONSTANT VARCHAR2(4000) :=
    'Selection with text property can only be compared to a text literal. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';
CZ_FCE_SW_SELECT_PROP_NOTALLOW CONSTANT VARCHAR2(4000) :=
    '"Selection()" property is allowed only for Option Feature or BOM Option Class. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

---------------------------------------------------------------------------------------
--These tables are used in Property-based Compatibility and ForAll rule generation. The
--names are hard-coded in corresponding procedures, do not change just here.

c_                                type_compat_table;
o_                                type_iteratortable_table;
n_                                type_numbervalue_table;
s_                                type_integer_table;
t_                                type_varchar4000value_table;
b_                                type_integervalue_table;
---------------------------------------------------------------------------------------

h_inst                            type_byte_table;

h_psntypes                        type_meta_hashtable;
h_instantiability                 type_meta_hashtable;
h_ruletypes                       type_meta_hashtable;
h_ruleclasses                     type_meta_hashtable;
h_designtypes                     type_meta_hashtable;
h_exprtypes                       type_meta_hashtable;
h_datatypes                       type_meta_hashtable;
h_templates                       type_meta_hashtable;
h_javatypes                       type_meta_hashtable;
h_mathconstants                   type_meta_hashtable;

h_operators_1                     type_varchar4000_table;
h_operators_2                     type_varchar4000_table;
h_operators_2_int                 type_varchar4000_table;
h_operators_2_double              type_varchar4000_table;
h_operators_2_boolean             type_varchar4000_table;
h_operators_2_text                type_varchar4000_table;
h_operators_3                     type_varchar4000_table;
h_operators_3_opt                 type_varchar4000_table;
h_heuristic_ops                   type_varchar4000_table;
h_template_tokens                 type_varchar4000_table;
h_quantities                      type_varchar4000_table;
h_mathrounding_ops                type_varchar4000_table;

h_methoddescriptors               type_data_hashtable;

h_accumulation_ops                type_integer_table;
h_rounding_ops                    type_integer_table;
h_logical_ops                     type_integer_table;
h_numeric_ops                     type_integer_table;
h_trigonometric_ops               type_integer_table;
h_runtime_properties              type_integer_table;

const_string_tag                  CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (1), 4);
const_integer_tag                 CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (3), 4);
const_float_tag                   CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (4), 4);
const_long_tag                    CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (5), 4);
const_double_tag                  CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (6), 4);
const_method_tag                  CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (10), 4);
const_date_tag                    CONSTANT RAW(1) := UTL_RAW.SUBSTR (UTL_RAW.CAST_FROM_BINARY_INTEGER (20), 4);
---------------------------------------------------------------------------------------
/*#
 * Reporting procedure.
 *
 * @param p_message Message text.
 * @param p_urgency Urgency level of the message.
 * @param p_run_id Unique id of the compilation session.
 */
 /*
 PROCEDURE report ( p_message IN VARCHAR2
                  , p_urgency IN PLS_INTEGER
                  , p_run_id  IN NUMBER
                  );
                  */
---------------------------------------------------------------------------------------
/*#
 * Default method to generate logic for a model in the database in debug mode.
 *
 * @param p_object_id Database model id.
 * @param x_run_id Unique id of the compilation session. If NULL value is passes, the
 * id will be generated.
 */

PROCEDURE debug_logic ( p_object_id IN NUMBER
                      , x_run_id    IN OUT NOCOPY NUMBER
                      );
---------------------------------------------------------------------------------------
/*#
 * Default method to generate logic for a model in the database.
 *
 * @param p_object_id Database model id.
 * @param x_run_id Unique id of the compilation session. If NULL value is passes, the
 * id will be generated.
 */

PROCEDURE compile_logic ( p_object_id IN NUMBER
                        , x_run_id    IN OUT NOCOPY NUMBER
                        );
---------------------------------------------------------------------------------------
/*#
 * This method enables logic compiler to work remotely in a distributed transaction even
 * if the model contains property-based compatibility rules - bug #2028790.
 * DDL used in the property-based compatibility rules makes implicit commits and commits
 * are not allowed in a distributed transaction when the remote procedure has parameters
 * of type OUT.
 *
 * @param p_object_id Database model id.
 * @param p_run_id Unique id of the compilation session, specified by the caller.
 */

PROCEDURE compile_logic__ ( p_object_id IN NUMBER
                          , p_run_id    IN NUMBER
                          );
---------------------------------------------------------------------------------------
END;

/
