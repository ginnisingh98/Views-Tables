--------------------------------------------------------
--  DDL for Package ONT_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXDUTLS.pls 120.0 2005/05/31 23:58:02 appldev noship $ */


l_api_return_value VARCHAR2(255);
G_MAX_DEF_ITERATIONS NUMBER :=10;
NONE		   VARCHAR2(4) := 'NONE';

-- Maximum number of defaulting conditions for an attribute in the
-- table oe_def_attr_condns. For each attribute, the attribute
-- conditions cache will hold the conditions for that attribute
-- from the index, attribute constant * G_MAX_ATTR_CONDNS
-- to (attribute constant * G_MAX_ATTR_CONDN + G_MAX_ATTR_CONDN - 1)
-- For e.g. for attribute accounting_rule_id, the value of
-- attribute constant is OE_HEADER_UTIL.G_ACCOUNTING_RULE_ID = 1
-- therefore the conditions are stored in the cache from index
-- 100 to 199
G_MAX_ATTR_CONDNS		CONSTANT			NUMBER := 100;

-- Attribute Conditions Record
-- Used to cache the defaulting conditions setup for each
-- attribute.
-- e.g. ONT_LINE_Def_Util.g_attr_condns_cache
-- As the rules are cached for each attribute per condition,
-- the start and end index for the rules in the rules cache
-- is also updated.

    TYPE Attr_Condn_Rec_Type IS RECORD (
    condition_id        NUMBER ,
    attribute_code      VARCHAR2(30) ,
    conditions_defined  VARCHAR2(1),
    rules_start_index   NUMBER,
    rules_stop_index    NUMBER
        );

    TYPE Attr_Condn_Tbl_Type IS TABLE OF Attr_Condn_Rec_Type
    INDEX BY BINARY_INTEGER;


-- Defaulting Rules Record Definition
-- Used to cache the rules for each entity's attributes
-- In the entity defaulting util package
-- e.g. ONT_LINE_DEF_UTIL.g_attr_rules_cache

   TYPE Attr_Def_Rule_REC_Type IS RECORD
	( SRC_TYPE			     VARCHAR2(30)
	, SRC_ATTRIBUTE_CODE		VARCHAR2(30)
	, SRC_DATABASE_OBJECT_NAME	VARCHAR2(30)
	, SRC_PARAMETER_NAME		VARCHAR2(30)
	, SRC_SYSTEM_VARIABLE_EXPR	VARCHAR2(255)
	, SRC_PROFILE_OPTION		VARCHAR2(30)
	, SRC_API_NAME			     VARCHAR2(2031)
	, SRC_CONSTANT_VALUE		VARCHAR2(240)
	, SRC_SEQUENCE_NAME		     VARCHAR2(30)
	);

    TYPE Attr_Def_Rule_TBL_Type IS TABLE OF Attr_Def_Rule_Rec_Type
    INDEX BY BINARY_INTEGER;

   Procedure Set_Parameter_Value(
      p_param_name  IN  varchar2,
      p_value       in  varchar2
   );

   --
   Function Get_Parameter_Value(
      p_param_name  IN  varchar2
   ) Return Varchar2;

   -- database default
   Function Get_Database_Default_Varchar2(
      p_column_name in varchar2,
      p_table_name  in varchar2
   ) Return Varchar2;

   -- web apps dictionary attribute default
   Function Get_Attr_Default_Varchar2(
      p_attribute_code in varchar2,
      p_application_id in varchar2
   ) Return Varchar2;

   -- web apps dictionary object attribute default
   Function Get_ObjAttr_Default_Varchar2(
      p_attribute_code        in varchar2,
      p_database_object_name  in varchar2,
      p_application_id        in varchar2
   ) Return Varchar2;

   -- resolve system variable/expression
   Function Get_Expression_Value_Varchar2(
      p_expression_string in varchar2
   ) Return Varchar2;

   -- resolve system variable/expression for attributes with datatype = DATE
   -- Do not use function Get_Expression_Value_Varchar2 as converting
   -- from date to varchar2 loses the time components
   Function Get_Expression_Value_Date(
      p_expression_string in varchar2
   ) Return Date;

   Function Validate_Value(p_required_value in varchar2,
                        p_validation_op  in varchar2,
                        p_actual_value   in varchar2
   ) Return Boolean;

   -- resolve default value by calling a custom API
	FUNCTION Get_API_Value_Varchar2  (
	p_api_name	in	varchar2,
	p_database_object_name in varchar2,
	p_attribute_code in varchar2
	)
	RETURN VARCHAR2;

   -- resolve default DATE value by calling a custom API
	FUNCTION Get_API_Value_Date  (
	p_api_name	in	varchar2,
	p_database_object_name in varchar2,
	p_attribute_code in varchar2
	)
	RETURN DATE;

   -- default is next number in the sequence
	FUNCTION Get_Sequence_Value (
	p_sequence_name	in	varchar2
	)
	RETURN VARCHAR2;

	---------------------------------------------------------------------
	-- PROCEDURE Add_Invalid_Rule_Message
	-- Fix bug#1063896
	-- This procedure is called from the generated attribute handlers
	-- packages when there is a runtime error when evaluating a defaulting
	-- rule.
	-- This procedure adds an error message (OE_DEF_INVALID_RULE)
	-- to the stack after resolving the tokens for the attribute being
	-- defaulted and the default source type, default source/value and
	-- also prints out the SQL error message.
	---------------------------------------------------------------------
	PROCEDURE Add_Invalid_Rule_Message
	(p_attribute_code		IN VARCHAR2
        ,p_rule_id                      IN NUMBER   DEFAULT NULL
	,p_src_type			IN VARCHAR2 DEFAULT NULL
	,p_src_api_name			IN VARCHAR2 DEFAULT NULL
	,p_src_database_object_name	IN VARCHAR2 DEFAULT NULL
	,p_src_attribute_code		IN VARCHAR2 DEFAULT NULL
	,p_src_constant_value		IN VARCHAR2 DEFAULT NULL
	,p_src_profile_option		IN VARCHAR2 DEFAULT NULL
	,p_src_system_variable_expr	IN VARCHAR2 DEFAULT NULL
	,p_src_sequence_name		IN VARCHAR2 DEFAULT NULL
	);

End ONT_Def_Util;
-----------------------------------------------------------


 

/
