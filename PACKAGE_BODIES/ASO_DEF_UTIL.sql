--------------------------------------------------------
--  DDL for Package Body ASO_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEF_UTIL" AS
/* $Header: asodutlb.pls 120.1 2005/07/01 10:19:48 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Def_Util';

   -- parameters
   TYPE Parameter_Rec_Type IS RECORD
   (
     parameter_name       varchar2(30),
     parameter_value      varchar2(255)
   );

   TYPE Parameter_Tbl_Type IS TABLE OF Parameter_Rec_Type
   INDEX BY BINARY_INTEGER;

   g_parameter_tbl	Parameter_Tbl_Type;
   ---------------------------------------

---------------------------------------------
Procedure Set_Parameter_Value(
   p_param_name    IN  varchar2,
   p_value         in  varchar2
)
IS
  l_add_parameter boolean := TRUE;
  l_count  number := g_parameter_tbl.COUNT;
BEGIN

   -- if the parameter name already exists in the
   -- table, assign assign the value to that index. otherwise add
   -- a new element
   for i in 1..l_count loop
      if (g_parameter_tbl(i).parameter_name = p_param_name) then
          g_parameter_tbl(i).parameter_value := p_value;
          l_add_parameter := FALSE;
          exit;
      end if;
   end loop;

   if (l_add_parameter = TRUE) then
      g_parameter_tbl(l_count+1).parameter_name  := p_param_name;
      g_parameter_tbl(l_count+1).parameter_value := p_value;
   end if;

END Set_Parameter_Value;
--------------------------------

Function Get_Parameter_Value(
   p_param_name  in varchar2
)
Return Varchar2
IS
BEGIN
   for i in 1..g_parameter_tbl.COUNT loop
      if (g_parameter_tbl(i).parameter_name = p_param_name) then
          return g_parameter_tbl(i).parameter_value;
      end if;
   end loop;
   return null;
END Get_Parameter_Value;
-----------------------------------

Function Get_Database_Default_Varchar2(
   p_column_name in varchar2,
   p_table_name  in varchar2
)
Return Varchar2
IS
    l_default_value    long;
    l_status           varchar2(30);
    l_schema           varchar2(30);
    l_industry         varchar2(30);
    l_return_status    boolean;

   CURSOR C(l_schema varchar2)
   IS
   SELECT data_default
   FROM   all_tab_columns
   WHERE  table_name = p_table_name
   AND    column_name = p_column_name
   AND    owner = l_schema;

BEGIN
   l_return_status := FND_INSTALLATION.get_app_info('ONT',l_status,l_industry,l_schema);
   Open C (l_schema);
   Fetch C into l_default_value;
   close C;
   return l_default_value;

END Get_Database_Default_Varchar2;
--------------------------------------

Function Get_Attr_Default_Varchar2(
   p_attribute_code in varchar2,
   p_application_id in varchar2
)
Return Varchar2
IS
   l_value_varchar2 AK_ATTRIBUTES.DEFAULT_VALUE_VARCHAR2%TYPE;
   l_value_number   number;
   l_value_date     date;

   CURSOR C IS
   SELECT default_value_varchar2, default_value_number, default_value_date
   FROM   ak_Attributes
   WHERE  attribute_application_id = p_application_id
   AND    attribute_code = p_attribute_code;

BEGIN

  open C;
  fetch C into l_value_varchar2, l_value_number, l_value_date;
  CLOSE C;

  if (l_value_date is not null) then
    l_value_varchar2 := l_value_date;
  elsif (l_value_number is not null) then
    l_value_varchar2 := l_value_number;
  end if;
  return l_value_varchar2;

END Get_Attr_Default_Varchar2;
---------------------------------------

Function Get_ObjAttr_Default_Varchar2(
   p_attribute_code        in varchar2,
   p_database_object_name  in varchar2,
   p_application_id        in varchar2
) Return Varchar2
IS
   l_value_varchar2 AK_OBJECT_ATTRIBUTES.DEFAULT_VALUE_VARCHAR2%TYPE;
   l_value_number   number;
   l_value_date     date;

   CURSOR C  IS
   SELECT default_value_varchar2, default_value_number, default_value_date
   FROM   ak_OBJECT_Attributes
   WHERE  attribute_application_id = p_application_id
   AND    database_object_name = p_database_object_name
   AND    attribute_code = p_attribute_code;

BEGIN

  open C;
  fetch C into l_value_varchar2, l_value_number, l_value_date;
  Close C;

  if (l_value_date is not null) then
    l_value_varchar2 := l_value_date;
  elsif (l_value_number is not null) then
    l_value_varchar2 := l_value_number;
  end if;
  return l_value_varchar2;

END Get_ObjAttr_Default_Varchar2;
-----------------------------------

-- resolve system variable/expression
Function Get_Expression_Value_Varchar2(
   p_expression_string in varchar2
) Return Varchar2
IS
   l_sql_String   long;
   l_expression_value  varchar2(255);
BEGIN

        l_sql_string :=  'SELECT '||p_expression_string||' FROM SYS.DUAL';
	EXECUTE IMMEDIATE l_sql_string INTO l_expression_value;

	RETURN l_expression_value;

END Get_Expression_Value_Varchar2;

---------------------------------------------------------------------
-- resolve system variable/expression for DATE attributes
---------------------------------------------------------------------
Function Get_Expression_Value_Date(
   p_expression_string in varchar2
) Return Date
IS
l_sql_string           	VARCHAR2(500);
l_return_value           DATE;
BEGIN

     IF lower(p_expression_string) = 'sysdate' THEN
          l_return_value := sysdate;
     ELSE
		l_sql_string :=  'SELECT '||p_expression_string||' FROM DUAL';
     	EXECUTE IMMEDIATE l_sql_string INTO l_return_value;
     END IF;

	RETURN l_return_value;

END Get_Expression_Value_Date;
-------------------------------------


Function Validate_Value(p_required_value in varchar2,
                        p_validation_op  in varchar2,
                        p_actual_value   in varchar2
) Return Boolean
IS
BEGIN
   If (p_validation_op = 'IS NULL') then
      If (p_actual_value IS NULL) then
         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = 'IS NOT NULL') then
      If (p_actual_value IS NOT NULL) then
         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = '=') then

      If (p_actual_value = p_required_value) then
         return TRUE;
      Else

         return FALSE;
      End If;
  Elsif (p_validation_op = '!=') then
      If (p_actual_value <> p_required_value) then
         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = '<') then
      If (p_actual_value < p_required_value) then
         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = '<=') then
      If (p_actual_value <= p_required_value) then

         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = '>') then
      If (p_actual_value > p_required_value) then
         return TRUE;
      Else
         return FALSE;
      End If;
  Elsif (p_validation_op = '>=') then
      If (p_actual_value >= p_required_value) then
         return TRUE;
      Else
         return FALSE;
      End If;
  End If;
  return FALSE;
END Validate_Value;


FUNCTION Get_API_Value_Varchar2  (
	p_api_name	in	varchar2,
	p_database_object_name in varchar2,
	p_attribute_code            in varchar2)
 RETURN VARCHAR2
IS
l_func_block		VARCHAR2(4000);
l_return_value		VARCHAR2(2000);
begin

     l_func_block :=
  	  'declare '||
          'begin '||
	      ':return_value := '||
           p_api_name||'(p_database_object_name => :p_database_object_name
		,p_attribute_code => :p_attribute_code);'|| ' end;' ;

	EXECUTE IMMEDIATE l_func_block USING OUT l_return_value,
		IN p_database_object_name, IN p_attribute_code;

     RETURN l_return_value;

END Get_API_Value_Varchar2;

FUNCTION Get_API_Value_Date  (
	p_api_name	in	varchar2,
	p_database_object_name in varchar2,
	p_attribute_code            in varchar2)
RETURN DATE
IS
l_func_block		VARCHAR2(4000);
l_return_value		DATE;
begin

     l_func_block :=
  	  'declare '||
          'begin '||
	      ':return_value := '||
           p_api_name||'(p_database_object_name => :p_database_object_name
		,p_attribute_code => :p_attribute_code);'|| ' end;' ;

	EXECUTE IMMEDIATE l_func_block USING OUT l_return_value,
		IN p_database_object_name, IN p_attribute_code;

     RETURN l_return_value;

END Get_API_Value_Date;


FUNCTION Get_Sequence_Value
( p_sequence_name		IN VARCHAR2)
RETURN VARCHAR2
IS
l_next_val	NUMBER;
l_select_stmt		VARCHAR2(200);
BEGIN

        l_select_stmt :=  'SELECT '||p_sequence_name||'.NEXTVAL FROM DUAL';
	EXECUTE IMMEDIATE l_select_stmt INTO l_next_val;

     RETURN to_char(l_next_val);

END Get_Sequence_Value;


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
)
IS
l_default_source			VARCHAR2(240);
l_attribute				VARCHAR2(80);
l_src_attribute			VARCHAR2(80);
l_src_object				VARCHAR2(30);
l_src_type				VARCHAR2(80);
l_src_type_value			VARCHAR2(80);
l_error					VARCHAR2(500);
l_src_api_name	VARCHAR2(2031);
l_src_database_object_name	VARCHAR2(30);
l_src_attribute_code		VARCHAR2(30);
l_src_constant_value		VARCHAR2(240);
l_src_profile_option		VARCHAR2(240);
l_src_system_variable_expr	VARCHAR2(255);
l_src_sequence_name		VARCHAR2(30);
BEGIN

  l_error := substr(sqlerrm,1,500);

  if p_rule_id is not null then
     select src_type, src_api_pkg||'.'||src_api_fn
            ,src_database_object_name, src_attribute_code
            ,src_constant_value, src_profile_option
            ,src_system_variable_expr, src_sequence_name
     into l_src_type, l_src_api_name
            ,l_src_database_object_name, l_src_attribute_code
            ,l_src_constant_value, l_src_profile_option
            ,l_src_system_variable_expr, l_src_sequence_name
     from oe_def_attr_def_rules
     where attr_def_rule_id = p_rule_id;
  else
     l_src_type := p_src_type;
     l_src_api_name := p_src_api_name;
     l_src_database_object_name := p_src_database_object_name;
     l_src_attribute_code := p_src_attribute_code;
     l_src_constant_value := p_src_constant_value;
     l_src_profile_option := p_src_profile_option;
     l_src_system_variable_expr := p_src_system_variable_expr;
     l_src_sequence_name := p_src_sequence_name;
  end if;

  -- If src_type_code is same as the attribute_code, then it is
  -- a CONSTANT value rule
  select meaning
  into l_src_type_value
  from oe_lookups
  where lookup_type = 'DEFAULTING_SOURCE_TYPE'
  and lookup_code = decode(l_src_type,p_attribute_code,'CONSTANT'
					,l_src_type);

  l_attribute := OE_Order_Util.Get_Attribute_Name(p_attribute_code);

  if l_src_attribute_code is not null then
    l_src_attribute := OE_Order_Util.Get_Attribute_Name(l_src_attribute_code);
  end if;

  if l_src_database_object_name is not null then
    select name
    into l_src_object
    from ak_objects_vl
    where database_object_name = l_src_database_object_name;
  end if;

  -- Set up the token for the default source/value based on the
  -- source type

  if l_src_type = 'SAME_RECORD' then

    l_default_source	:= l_src_attribute;

  elsif l_src_type = 'RELATED_RECORD' then

    l_default_source	:= l_src_object||'.'||l_src_attribute;

  elsif l_src_type = 'API' then

    l_default_source := substr(l_src_api_name,1,240);
    if l_src_database_object_name is not null then
      l_default_source := substr(l_default_source
			||'.'||l_src_database_object_name,1,240);
    end if;
    if l_src_attribute_code is not null then
      l_default_source := substr(l_default_source
	          ||'.'||l_src_attribute_code,1,240);
    end if;

  elsif l_src_type = 'PROFILE_OPTION' then

    select user_profile_option_name
    into l_default_source
    from fnd_profile_options_vl
    where profile_option_name = l_src_profile_option;

  elsif l_src_type = 'CONSTANT' then

    l_default_source	:= l_src_constant_value;

  elsif l_src_type = 'SYSTEM' then

    l_default_source := l_src_system_variable_expr;

  elsif l_src_type = 'SEQUENCE' then

    l_default_source := l_src_sequence_name;

  elsif l_src_type = p_attribute_code then

    fnd_flex_descval.set_context_value(p_attribute_code);
    fnd_flex_descval.set_column_value('SRC_CONSTANT_VALUE'
							   ,l_src_constant_value);
    if fnd_flex_descval.validate_desccols
	  ('ONT','Defaulting Rules Flexfield') then
	l_default_source := fnd_flex_descval.concatenated_values;
    else
	raise_application_error(-20000,fnd_flex_descval.error_message);
    end if;

  end if;

  FND_MESSAGE.SET_NAME('ONT','OE_DEF_INVALID_RULE');
  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
  FND_MESSAGE.SET_TOKEN('SOURCE_TYPE',l_src_type_value);
  FND_MESSAGE.SET_TOKEN('DEFAULT_SOURCE',l_default_source);
  FND_MESSAGE.SET_TOKEN('ERROR',l_error);
  OE_MSG_PUB.ADD;

EXCEPTION
  WHEN OTHERS THEN
     OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
         ,   'Add_Invalid_Rule_Message');
END Add_Invalid_Rule_Message;

End ASO_Def_Util;

/
