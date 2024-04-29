--------------------------------------------------------
--  DDL for Package Body HXC_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOAD_PKG" AS
/* $Header: hxcload.pkb 120.3 2005/11/14 22:48:24 jdupont noship $ */

g_debug boolean := hr_utility.debug_enabled;

FUNCTION get_pref_def_name ( p_pref_definition_id NUMBER ) RETURN VARCHAR2 IS

l_name		fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;

CURSOR	csr_get_name IS
SELECT	df.descriptive_flex_context_name
FROM	fnd_descr_flex_contexts_vl df
,	hxc_pref_definitions pd
WHERE	pd.pref_definition_id	= p_pref_definition_id
AND	df.application_id	=809
AND	df.descriptive_flexfield_name  = 'OTC PREFERENCES'
AND	df.descriptive_flex_context_code = pd.code;

BEGIN

OPEN  csr_get_name;
FETCH csr_get_name INTO l_name;
CLOSE csr_get_name;

RETURN l_name;

END get_pref_def_name;


FUNCTION get_attribute ( p_attribute_category	VARCHAR2
		,	 p_attribute		VARCHAR2
		,	  p_attribute_name   IN VARCHAR2 DEFAULT null
		) RETURN VARCHAR2 IS

l_real_value	VARCHAR2(150);

CURSOR	csr_get_retrieval_rule IS
SELECT	name
FROM	hxc_retrieval_rules
WHERE	RETRIEVAL_RULE_ID	= TO_NUMBER(p_attribute);

CURSOR	csr_get_approval_style IS
SELECT	name
FROM	hxc_approval_styles
WHERE	approval_style_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_application_set IS
SELECT	aps.application_set_name
FROM	(SELECT heg.rowid row_id ,heg.ENTITY_GROUP_ID application_set_id ,heg.NAME application_set_name ,heg.OBJECT_VERSION_NUMBER ,heg.CREATED_BY ,
                heg.CREATION_DATE ,heg.LAST_UPDATED_BY ,heg.LAST_UPDATE_DATE ,heg.LAST_UPDATE_LOGIN
	 FROM hxc_entity_groups heg
	 WHERE heg.entity_type = 'TIME_RECIPIENTS') APS
WHERE	aps.application_set_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_retrieval_rule_grp IS
SELECT	ret.retrieval_rule_group_name
FROM	(SELECT heg.rowid row_id ,heg.ENTITY_GROUP_ID retrieval_rule_group_id ,heg.NAME retrieval_rule_group_name ,heg.OBJECT_VERSION_NUMBER ,heg.CREATED_BY ,heg.CREATION_DATE ,
                heg.LAST_UPDATED_BY ,heg.LAST_UPDATE_DATE ,heg.LAST_UPDATE_LOGIN
	  FROM hxc_entity_groups heg
	  WHERE heg.entity_type = 'RETRIEVAL_RULES') RET
WHERE	ret.retrieval_rule_group_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_public_template_group IS
select heg.name  FROM hxc_entity_groups heg where
 heg.entity_type = 'PUBLIC_TEMPLATE_GROUP' and
 heg.ENTITY_GROUP_ID= TO_NUMBER(p_attribute);

CURSOR	csr_get_alias IS
SELECT	alias_definition_name
FROM	hxc_alias_definitions
WHERE	alias_definition_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_recurring_period IS
SELECT	rp.name
FROM	hxc_recurring_periods rp
WHERE	recurring_period_id = TO_NUMBER(p_attribute);

CURSOR	csr_get_approval_period IS
SELECT	aps.name
FROM	hxc_approval_period_sets aps
WHERE	approval_period_set_id = TO_NUMBER(p_attribute);

CURSOR	csr_get_layout IS
SELECT	layout_name
FROM	hxc_layouts
WHERE	layout_id		= TO_NUMBER(p_attribute);

CURSOR  csr_get_date_format IS
SELECT  egc.attribute2
FROM    hxc_entity_group_comps egc
WHERE   egc.attribute1 = p_attribute
AND EXISTS ( SELECT 'x'
             FROM   hxc_entity_groups eg
             WHERE  eg.entity_group_id = egc.entity_group_id
             AND    eg.entity_type     = 'HXC_SS_TC_DATE_FORMATS' );

CURSOR
csr_get_time_entry_rule_name IS
SELECT  ter.time_entry_rule_group_name
FROM    (SELECT heg.rowid row_id ,heg.ENTITY_GROUP_ID time_entry_rule_group_id ,heg.NAME time_entry_rule_Group_name ,
                heg.OBJECT_VERSION_NUMBER ,heg.CREATED_BY ,heg.CREATION_DATE ,heg.LAST_UPDATED_BY ,heg.LAST_UPDATE_DATE ,heg.LAST_UPDATE_LOGIN
	 FROM hxc_entity_groups heg
	 WHERE heg.entity_type = 'TIME_ENTRY_RULES') TER
WHERE   ter.time_entry_rule_group_id = TO_NUMBER(p_attribute);

BEGIN

IF ( p_attribute_category = 'TS_PER_APPROVAL_STYLE' )
THEN

	OPEN  csr_get_approval_style;
	FETCH csr_get_approval_style INTO l_real_Value;
	CLOSE csr_get_approval_style;

ELSIF ( p_attribute_category = 'TS_PER_APPLICATION_SET' )
THEN

	OPEN  csr_get_application_set;
	FETCH csr_get_application_set INTO l_real_Value;
	CLOSE csr_get_application_set;

ELSIF ( p_attribute_category = 'TS_PER_RETRIEVAL_RULES' )
THEN

	OPEN  csr_get_retrieval_rule_grp;
	FETCH csr_get_retrieval_rule_grp INTO l_real_Value;
	CLOSE csr_get_retrieval_rule_grp;

ELSIF ( p_attribute_category = 'TS_PER_APPROVAL_PERIODS' )
THEN

	OPEN  csr_get_approval_period;
	FETCH csr_get_approval_period INTO l_real_Value;
	CLOSE csr_get_approval_period;

ELSIF ( p_attribute_category = 'TC_W_TCRD_PERIOD' )
THEN

	OPEN  csr_get_recurring_period;
	FETCH csr_get_recurring_period INTO l_real_value;
	CLOSE csr_get_recurring_period;

ELSIF ( p_attribute_category = 'TC_W_TCRD_ALIASES' )
THEN

-- GPM: 115.9
-- commented in cursor now that we have alias preference.

	OPEN  csr_get_alias;
	FETCH csr_get_alias INTO l_real_value;
	CLOSE csr_get_alias;

ELSIF ( p_attribute_category = 'TC_W_TCRD_LAYOUT' )
THEN

	OPEN  csr_get_layout;
	FETCH csr_get_layout INTO l_real_value;
	CLOSE csr_get_layout;
ELSIF ( p_attribute_category = 'TC_W_PUBLIC_TEMPLATE' )
THEN

	OPEN  csr_get_public_template_group;
	FETCH csr_get_public_template_group INTO l_real_value;
	CLOSE csr_get_public_template_group;

ELSIF ( p_attribute_category = 'TC_W_DATE_FORMATS' )
THEN

	OPEN  csr_get_date_format;
	FETCH csr_get_date_format INTO l_real_value;
	CLOSE csr_get_date_format;

ELSIF ( p_attribute_category = 'TS_PER_AUDIT_REQUIREMENTS' )
THEN
       OPEN csr_get_time_entry_rule_name;
       FETCH csr_get_time_entry_rule_name INTO l_real_value;
       CLOSE csr_get_time_entry_rule_name;
ELSIF ( p_attribute_category = 'TC_W_RULES_EVALUATION' )  --115.3
THEN
  IF (p_attribute_name = 'ATTRIBUTE2') then
	OPEN  csr_get_retrieval_rule;
	FETCH csr_get_retrieval_rule INTO l_real_value;
	CLOSE csr_get_retrieval_rule;
  elsif (p_attribute_name = 'ATTRIBUTE3') then
      OPEN  csr_get_recurring_period;
	FETCH csr_get_recurring_period INTO l_real_value;
	CLOSE csr_get_recurring_period;
  end if;
ELSE

	l_real_value	:= p_attribute;

END IF;

RETURN l_real_value;

END get_attribute;

-- ----------------------------------------------------------------------------
-- |----------------------------< get_value_set_sql >-------------------------|
-- ----------------------------------------------------------------------------
--
-- public function
--   get_value_set_sql
--
-- description
--   get the SQL associated with a particular value set


FUNCTION get_value_set_sql
              (p_flex_value_set_id IN NUMBER,
               p_session_date   IN     DATE ) RETURN LONG
is
   --
   -- Declare local variables
   --
   l_sql_text LONG;
   l_sql_text_id LONG;
   l_valueset_r  fnd_vset.valueset_r;
   l_valueset_dr fnd_vset.valueset_dr;
   l_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   l_order_by_start NUMBER;
   l_from_start NUMBER;
   l_additional_and_clause VARCHAR2(2000);
   l_from_where VARCHAR2(2000);
   l_select_clause VARCHAR2(2000);
   l_dep_parent_column_name fnd_columns.column_name%TYPE;
   --
begin -- get_value_set_sql

l_value_set_id := p_flex_value_set_id;

 fnd_vset.get_valueset(l_value_set_id,l_valueset_r,l_valueset_dr);

--
-- Initailize the SQL text columns.
--
   l_sql_text := '';
   l_sql_text_id := '';
   --
-- Ok next build the SQL text that can be used to build a pop-list
-- for this segment, if this is a table validated or independant
-- validated value set - i.e. it has an associated list of values.
-- We are going to build two versions of the SQL.  One can be used
-- to define the list of values associated with this segment(SQL_TEXT), the
-- other is used to converted a value (ID) stored on the database into a
-- a description (VALUE) (SQL_DESCR_TXT).
--
IF l_valueset_r.validation_type = 'F'
THEN
	-- TABLE validated

      select 'SELECT ' ||
          l_valueset_r.table_info.value_column_name ||
          decode(l_valueset_r.table_info.meaning_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.meaning_column_name)||
          decode(l_valueset_r.table_info.id_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.id_column_name)||
                 ' FROM ' ||
                 l_valueset_r.table_info.table_name || ' ' ||
                 l_valueset_r.table_info.where_clause
      into l_sql_text
      from dual;

      l_order_by_start := INSTR(upper(l_sql_text),'ORDER BY');
      l_from_start := INSTR(upper(l_sql_text),'FROM');

-- Build the SQL for the FROM clause

      if(l_order_by_start >0) then
          l_from_where := substr(l_sql_text,l_from_start,(
                                            l_order_by_start-l_from_start));
      else
          l_from_where := substr(l_sql_text,l_from_start);
      end if;
--

      if(l_valueset_r.table_info.meaning_column_name is not null) then
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                    meaning_column_name||' ';
      else
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                      value_column_name||' ';
      end if;

     l_sql_text_id := l_select_clause||l_from_where;

	IF ( INSTR( UPPER(l_sql_text_id) , 'WHERE') = 0 )
	THEN

     l_sql_text_id   := l_select_clause||l_from_where ||'WHERE '||l_valueset_r.table_info.id_column_name||' = ';

	ELSE

     l_sql_text_id   := l_select_clause||l_from_where ||'and '||l_valueset_r.table_info.id_column_name||' = ';

	END IF;


   elsif l_valueset_r.validation_type = 'I' then

--
-- We can hard code the DESC SQL this time, since we know explicitly
-- how independant value sets are built.  This should be changed once
-- we have the procedure from AOL.
--
         l_sql_text_id := 'SELECT FLEX_VALUE'||
                       ' FROM FND_FLEX_VALUES_VL'||
                       ' WHERE FLEX_VALUE_SET_ID =' || l_value_set_id ||
                       ' AND ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND FLEX_VALUE = ';


   end if; -- validation type

RETURN l_sql_text_id;

end get_value_set_sql;

-- ----------------------------------------------------------------------------
-- |----------------------------< get_parent         >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_parent ( p_pref_top_node	VARCHAR2
		,   p_pref_node		VARCHAR2
		,   p_pref_level	NUMBER
		,   p_count		NUMBER ) RETURN VARCHAR2 IS

l_level_one	hxc_pref_hierarchies.name%TYPE	:= NULL;
l_level_two	hxc_pref_hierarchies.name%TYPE	:= NULL;
l_level_three	hxc_pref_hierarchies.name%TYPE	:= NULL;
l_level_four	hxc_pref_hierarchies.name%TYPE	:= NULL;
l_level_five	hxc_pref_hierarchies.name%TYPE	:= NULL;

l_full_name	VARCHAR2(500);

l_last_level	NUMBER(1)	:= 1;

CURSOR get_pref_hierarchy ( p_top_node VARCHAR2 ) IS
SELECT	name
,	level
,	rownum cnt
from hxc_pref_hierarchies
start with name = p_top_node
connect by prior pref_hierarchy_id = parent_pref_hierarchy_id;

BEGIN

FOR t IN get_pref_hierarchy ( p_pref_top_node )
LOOP

IF ( l_last_level > t.level )
THEN
	IF ( t.level = 2 )
	THEN
		l_level_two   := NULL;
		l_level_three := NULL;
		l_level_four  := NULL;
		l_level_five  := NULL;

	ELSIF ( t.level = 3 )
	THEN
		l_level_three := NULL;
		l_level_four  := NULL;
		l_level_five  := NULL;

	ELSIF ( t.level = 4 )
	THEN
		l_level_four  := NULL;
		l_level_five  := NULL;
	END IF;
END IF;


IF ( p_pref_level = t.level AND p_pref_node = t.name AND p_count = t.cnt )
THEN

	l_full_name := l_level_one||l_level_two||l_level_three||l_level_four||l_level_five;

	RETURN LTRIM(RTRIM(l_full_name));
END IF;

IF ( t.level = 1 AND t.level <> p_pref_level )
THEN
	l_level_one	:= t.name;

ELSIF ( t.level = 2 AND t.level <> p_pref_level )
THEN
	l_level_two	:= '.'||t.name;

ELSIF ( t.level = 3 AND t.level <> p_pref_level )
THEN
	l_level_three	:= '.'||t.name;

ELSIF ( t.level = 4 AND t.level <> p_pref_level )
THEN
	l_level_four	:= '.'||t.name;

ELSIF ( t.level = 5 AND t.level <> p_pref_level )
THEN
	l_level_five	:= '.'||t.name;

END IF;

l_last_level := t.level;

END LOOP;

END get_parent;

-- ----------------------------------------------------------------------------
-- |----------------------------< get_flex_value     >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_flex_value (  p_flex_value_set_id NUMBER
	,		p_id  VARCHAR2 ) RETURN VARCHAR2 IS

l_sql LONG;
l_description VARCHAR2(150) := NULL;

-- GPM v115.26

CURSOR csr_get_element_name ( p_element_type_id VARCHAR2 ) IS
select   pett.element_name Display_Value
from     pay_element_types_f_tl pett
where pett.element_type_id = p_element_type_id
and   pett.language = USERENV('LANG');

l_csr INTEGER;

BEGIN

IF ( p_flex_value_set_id = -1 )
THEN

-- no value set therefore at the moment is 'Dummy Element Context'

OPEN  csr_get_element_name ( p_id );
FETCH csr_get_element_name INTO l_description;
CLOSE csr_get_element_name;

ELSIF ( p_flex_value_set_id = -2 )
THEN

-- no value set at all -free form text Valeu = Value_Id

	l_description := p_id;

ELSE

l_sql := get_value_set_sql (
	p_flex_value_set_id => p_flex_value_set_id
,       p_session_date => sysdate );


BEGIN

	execute immediate l_sql||''''||p_id||'''' INTO l_description;

EXCEPTION WHEN OTHERS THEN

-- GPM v115.12 WWB 3254482
-- for customers who modify the value sets
-- which allow duplicate entries !!!

	IF SQLCODE = -1422 -- exact fetch returns more then one row
	THEN
		null;
	ELSE
		raise;
	END IF;
END;

END IF;

RETURN l_description;

END get_flex_value;


-- ----------------------------------------------------------------------------
-- |----------------------------< upgrade_custom_tcs>-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upgrade_custom_tcs ( p_time_category_id NUMBER ) IS

BEGIN

null;

END upgrade_custom_tcs;

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_tc_ref_integrity>-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_tc_ref_integrity ( p_time_category_id NUMBER ) RETURN BOOLEAN IS

l_referenced BOOLEAN := TRUE;

l_exists r_ter_record;

BEGIN

OPEN  csr_chk_ref_integ ( p_time_category_id );
FETCH csr_chk_ref_integ INTO l_exists;

IF ( csr_chk_ref_integ%FOUND )
THEN

	l_referenced := FALSE;

END IF;

CLOSE csr_chk_ref_integ;

RETURN l_referenced;

END chk_tc_ref_integrity;

-- ----------------------------------------------------------------------------
-- |------------------< get_tc_ref_integrity_list >---------------------------|
-- ----------------------------------------------------------------------------

-- Description:

--   SEE DESCRIPTION IN PACKAGE HEADER

-- ----------------------------------------------------------------------------

FUNCTION get_tc_ref_integrity_list ( p_time_category_id NUMBER ) RETURN t_ter_table IS

l_ter_list t_ter_table;
l_index BINARY_INTEGER := 1;

BEGIN

OPEN  csr_chk_ref_integ ( p_time_category_id );
FETCH csr_chk_ref_integ INTO l_ter_list(l_index);

IF ( csr_chk_ref_integ%FOUND )
THEN

	l_index := l_index + 1;

	FETCH csr_chk_ref_integ INTO l_ter_list(l_index);

END IF;

CLOSE csr_chk_ref_integ;

RETURN l_ter_list;

END get_tc_ref_integrity_list;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_node_data        >-------------------------|
-- ----------------------------------------------------------------------------
Procedure get_node_data
  (
   p_preference_full_name     in varchar2
  ,p_name                     in varchar2
  ,p_business_group_id	      in number
  ,p_legislation_code         in varchar2
  ,p_mode                     out nocopy varchar2
  ,p_pref_hierarchy_id        out nocopy number
  ,p_parent_pref_hierarchy_id out nocopy number
  ,p_object_version_number    out nocopy number
   ) IS
--


  l_period                   number;
  l_next_period              number;
  l_name                     varchar2(80);

  l_parent_pref_hierarchy_id number       := null;
  l_pref_hierarchy_id        number       := null;
  l_object_version_number    number       := null;
  l_mode                     varchar2(50) := null;

  cursor c_top_node(l_name varchar2) is
       SELECT pref_hierarchy_id,object_version_number
       FROM   hxc_pref_hierarchies
       WHERE  parent_pref_hierarchy_id is null
       AND    name = l_name;

  cursor c_child_nodes(l_parent_pref_hierarchy_id number,l_name varchar2) is
       SELECT pref_hierarchy_id,object_version_number
       FROM   hxc_pref_hierarchies
       WHERE  parent_pref_hierarchy_id = l_parent_pref_hierarchy_id
       AND    name = l_name;

--
begin
--
if p_preference_full_name is not null then



   -- Consider preference_full_name A.B.C being passed.In this case the ID of node
   -- C needs to be calculated.
   -- Loop till the instr function,which gives the position of the next period in
   -- the string,returns 0 implying that the end of the string is reached.

   l_period := 0;

   -- This loop gives the parent_pref_hierarchy_id for new node to be created

    WHILE l_period <> (length(p_preference_full_name) + 1) LOOP

      -- find the position of the delimiter

      l_next_period := instr(p_preference_full_name,'.',l_period + 1,1);

      -- if l_next_period is 0,i.e.,another delimiter could not be found,implies
      -- that end of the sring is reached.

      if (l_next_period = 0) then
          l_next_period := length(p_preference_full_name) + 1;
      end if;

      -- get the name of the preference(i.e., the text between the two delimiters)

      l_name := substr(p_preference_full_name,l_period + 1,l_next_period
                                                           - (l_period + 1));

      -- get the id of the preference with this name(l_name)

      if (l_parent_pref_hierarchy_id is null) then

         open c_top_node(l_name);
         fetch c_top_node into l_parent_pref_hierarchy_id,l_object_version_number;
         close c_top_node;

      else

         open c_child_nodes(l_parent_pref_hierarchy_id,l_name);
         fetch c_child_nodes into l_parent_pref_hierarchy_id,l_object_version_number;
         close c_child_nodes;

      end if;

      l_period := l_next_period;

    end loop;

    open c_child_nodes(l_parent_pref_hierarchy_id,p_name);
    fetch c_child_nodes into l_pref_hierarchy_id,l_object_version_number;

    -- set the OUT parameter
    if c_child_nodes%found then
       l_mode                     := 'UPDATE';
    else
       l_mode                     := 'INSERT';
       l_pref_hierarchy_id        := null;
       l_object_version_number    := null;
    end if;
    close c_child_nodes;

elsif p_preference_full_name is null then

    l_name := p_name;
    open c_top_node(l_name);
    fetch c_top_node into l_pref_hierarchy_id,l_object_version_number;

       if l_pref_hierarchy_id is null then
        l_mode := 'INSERT';
       else
        l_mode := 'UPDATE';
       end if;
    close c_top_node;

end if;

p_mode                     := l_mode;
p_pref_hierarchy_id        := l_pref_hierarchy_id;
p_object_version_number    := l_object_version_number;
p_parent_pref_hierarchy_id := l_parent_pref_hierarchy_id;



end get_node_data;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< get_ter_attributes  >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_ter_attributes(p_formula_id       IN NUMBER,
			    p_attribute_name   IN VARCHAR2,
			    p_attrubute_val    IN VARCHAR2
			   )
RETURN VARCHAR2 IS

cursor c_formula is
select formula_name
from ff_formulas_f
where formula_id=p_formula_id;

cursor c_flex_attribute(p_formula_name VARCHAR2) is
select FLEX_VALUE_SET_ID
from fnd_descr_flex_col_usage_vl
where descriptive_flexfield_name = 'OTL Formulas'
and application_id = 809
and descriptive_flex_context_code =p_formula_name
and enabled_flag = 'Y'
and APPLICATION_COLUMN_NAME =p_attribute_name;

l_formula_name  VARCHAR2(80);
l_vset_id	NUMBER;
l_vset_sql	LONG;

l_return_value   VARCHAR2(250);

BEGIN

open c_formula;
fetch c_formula into l_formula_name;
close c_formula;

IF l_formula_name is null then
   -- no formula so we can return the same id
   RETURN p_attrubute_val;
ELSE

  open c_flex_attribute(l_formula_name);
  fetch c_flex_attribute into l_vset_id;
  close c_flex_attribute;

  IF l_vset_id is null then
    RETURN p_attrubute_val;
  ELSE

    l_vset_sql :=get_value_set_sql(l_vset_id,sysdate);

    IF l_vset_sql is null  then
       RETURN p_attrubute_val;
    ELSE

     l_vset_sql :=l_vset_sql ||':1';

     EXECUTE IMMEDIATE l_vset_sql into l_return_value using p_attrubute_val;

     RETURN l_return_value;
    END IF;

  END IF;

END IF;

EXCEPTION

when others then
 return p_attrubute_val;
END;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_id_set_sql  >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_id_set_sql
              (p_flex_value_set_id    IN NUMBER,
               p_session_date         IN DATE ) RETURN LONG
is
   --
   -- Declare local variables
   --
   l_sql_text LONG;
   l_sql_text_id LONG;
   l_valueset_r  fnd_vset.valueset_r;
   l_valueset_dr fnd_vset.valueset_dr;
   l_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   l_order_by_start NUMBER;
   l_from_start NUMBER;
   l_additional_and_clause VARCHAR2(2000);
   l_from_where VARCHAR2(2000);
   l_select_clause VARCHAR2(2000);
   l_dep_parent_column_name fnd_columns.column_name%TYPE;
   --
begin -- get_value_set_sql

l_value_set_id := p_flex_value_set_id;

 fnd_vset.get_valueset(l_value_set_id,l_valueset_r,l_valueset_dr);

--
-- Initailize the SQL text columns.
--
   l_sql_text := '';
   l_sql_text_id := '';
   --
-- Ok next build the SQL text that can be used to build a pop-list
-- for this segment, if this is a table validated or independant
-- validated value set - i.e. it has an associated list of values.
-- We are going to build two versions of the SQL.  One can be used
-- to define the list of values associated with this segment(SQL_TEXT), the
-- other is used to converted a value (ID) stored on the database into a
-- a description (VALUE) (SQL_DESCR_TXT).
--
IF l_valueset_r.validation_type = 'F'
THEN
	-- TABLE validated

      select 'SELECT ' ||
          l_valueset_r.table_info.value_column_name ||
          decode(l_valueset_r.table_info.meaning_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.meaning_column_name)||
          decode(l_valueset_r.table_info.id_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.id_column_name)||
                 ' FROM ' ||
                 l_valueset_r.table_info.table_name || ' ' ||
                 l_valueset_r.table_info.where_clause
      into l_sql_text
      from dual;

      l_order_by_start := INSTR(upper(l_sql_text),'ORDER BY');
      l_from_start := INSTR(upper(l_sql_text),'FROM');

-- Build the SQL for the FROM clause

      if(l_order_by_start >0) then
          l_from_where := substr(l_sql_text,l_from_start,(
                                            l_order_by_start-l_from_start));
      else
          l_from_where := substr(l_sql_text,l_from_start);
      end if;
--

        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                    id_column_name||' ';

/*
      if(l_valueset_r.table_info.meaning_column_name is not null) then
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                    meaning_column_name||' ';
      else
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                      value_column_name||' ';
      end if;
*/
     l_sql_text_id := l_select_clause||l_from_where;


	IF ( INSTR( UPPER(l_sql_text_id) , 'WHERE') = 0 )
	THEN

     l_sql_text_id   := l_select_clause||l_from_where ||'WHERE '||l_valueset_r.table_info.value_column_name||' = ';

	ELSE

     l_sql_text_id   := l_select_clause||l_from_where ||'and '||l_valueset_r.table_info.value_column_name||' = ';

	END IF;


   elsif l_valueset_r.validation_type = 'I' then

--
-- We can hard code the DESC SQL this time, since we know explicitly
-- how independant value sets are built.  This should be changed once
-- we have the procedure from AOL.
--
         l_sql_text_id := 'SELECT FLEX_VALUE'||
                       ' FROM FND_FLEX_VALUES_VL'||
                       ' WHERE FLEX_VALUE_SET_ID =' || l_value_set_id ||
                       ' AND ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND FLEX_VALUE = ';

   end if; -- validation type

RETURN l_sql_text_id;

end get_id_set_sql;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_ter_attribute_id  >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_ter_attribute_id(p_formula_name   IN VARCHAR2,
			    p_attribute_name   IN VARCHAR2,
			    p_attrubute_val    IN VARCHAR2
			   )
RETURN VARCHAR2 IS

cursor c_flex_attribute(p_formula_name VARCHAR2) is
select FLEX_VALUE_SET_ID
from fnd_descr_flex_col_usage_vl
where descriptive_flexfield_name = 'OTL Formulas'
and application_id = 809
and descriptive_flex_context_code =p_formula_name
and enabled_flag = 'Y'
and APPLICATION_COLUMN_NAME =p_attribute_name;

l_formula_name  VARCHAR2(80);
l_vset_id	NUMBER;
l_vset_sql	LONG;

l_return_value   VARCHAR2(250);

BEGIN

IF p_formula_name is null then
   -- no formula so we can return the same id
   RETURN p_attrubute_val;
ELSE

  open c_flex_attribute(p_formula_name);
  fetch c_flex_attribute into l_vset_id;
  close c_flex_attribute;

  IF l_vset_id is null then
    RETURN p_attrubute_val;
  ELSE

    l_vset_sql :=get_id_set_sql(l_vset_id,sysdate);

    IF l_vset_sql is null  then
       RETURN p_attrubute_val;
    ELSE

     l_vset_sql :=l_vset_sql ||':1';

     EXECUTE IMMEDIATE l_vset_sql into l_return_value using p_attrubute_val;

     RETURN l_return_value;
    END IF;

  END IF;

END IF;

EXCEPTION

when others then
 return p_attrubute_val;
END;

-- ----------------------------------------------------------------------------
-- |--------------------------< set_dynamic_sql_string  >-------------------------|
-- ----------------------------------------------------------------------------

procedure set_dynamic_sql_string ( p_time_category_id NUMBER ) IS

CURSOR  csr_get_operator ( p_time_category_id NUMBER ) IS
SELECT  operator
FROM    hxc_time_categories
WHERE   time_category_id = p_time_category_id;


CURSOR	csr_get_category_comps ( p_time_category_id NUMBER ) IS
SELECT
	bbit.bld_blk_info_type context
,	bbit.bld_blk_info_type_id
,	mpc.segment
,	NVL(tcc.value_id, DECODE(tcc.is_null, 'N', '<WILDCARD>', '<IS NULL>')) value_id
,	tcc.ref_time_category_id
,	tcc.flex_value_set_id
,       tcc.equal_to
FROM
        hxc_bld_blk_info_types bbit
,       hxc_mapping_components mpc
,       hxc_time_category_comps tcc
WHERE	tcc.time_category_id = p_time_category_id AND
        tcc.type = 'MC'
AND
        mpc.mapping_component_id (+) = tcc.component_type_id
AND
        bbit.bld_blk_info_type_id (+) = mpc.bld_blk_info_type_id;


l_time_sql 	     LONG;
l_time_category_id   hxc_time_Categories.time_category_id%TYPE;
l_operator           hxc_time_categories.operator%TYPE;

l_last_update_date   DATE;
l_first_time_round   BOOLEAN;
l_comps_r 	     csr_get_category_comps%ROWTYPE;


-- ----------------------------------------------------------------------------
-- |--------------------------< validate_time_category_sql         >-------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE validate_time_category_sql ( p_sql_string IN LONG ) IS

l_sql   LONG := 'select distinct ta.bb_id from hxc_tmp_atts ta where '||p_sql_string;

t_bb_id dbms_sql.Number_Table;

l_csr          INTEGER;
l_rows_fetched INTEGER;
l_dummy        INTEGER;

BEGIN

-- the SQL MUST returns rows to show all possible errors
-- particularly implicit character to number and vice
-- versa

INSERT INTO hxc_tmp_atts (
      ta_id
,     bb_id
,     attribute1
,     attribute2
,     attribute3
,     attribute4
,     attribute5
,     attribute6
,     attribute7
,     attribute8
,     attribute9
,     attribute10
,     attribute11
,     attribute12
,     attribute13
,     attribute14
,     attribute15
,     attribute16
,     attribute17
,     attribute18
,     attribute19
,     attribute20
,     attribute21
,     attribute22
,     attribute23
,     attribute24
,     attribute25
,     attribute26
,     attribute27
,     attribute28
,     attribute29
,     attribute30
,     bld_blk_info_type_id
,     attribute_category )
VALUES (
      1
,     2
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     1
,     'Dummy' );


	BEGIN

	l_rows_fetched := 100;

	l_csr := dbms_sql.open_cursor;

	dbms_sql.parse ( l_csr, l_sql, dbms_sql.native );

	dbms_sql.define_array (
		c		=> l_csr
	,	position	=> 1
	,	n_tab		=> t_bb_id
	,	cnt		=> l_rows_fetched
	,	lower_bound	=> 1 );

	l_dummy	:=	dbms_sql.execute ( l_csr );

	-- loop to ensure we fetch all the rows

	WHILE ( l_rows_fetched = 100 )
	LOOP

		l_rows_fetched	:=	dbms_sql.fetch_rows ( l_csr );

		IF ( l_rows_fetched > 0 )
		THEN

			dbms_sql.column_value (
				c		=> l_csr
			,	position	=> 1
			,	n_tab		=> t_bb_id );

		t_bb_id.DELETE;

		END IF;

	END LOOP;

	dbms_sql.close_cursor ( l_csr );

--		execute immediate l_sql INTO l_dummy;

	EXCEPTION WHEN NO_DATA_FOUND THEN

		null;

		WHEN OTHERS THEN

                fnd_message.set_name('HXC', 'HXC_HTC_INVALID_SQL');
                fnd_message.set_token('ERROR', SQLERRM );
                fnd_message.raise_error;

	END;

END validate_time_category_sql;


-- ----------------------------------------------------------------------------
-- |--------------------------< get_dyn_sql         >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_dyn_sql ( p_time_sql IN OUT NOCOPY LONG
                      , p_comps_r  IN            csr_get_category_comps%ROWTYPE
                      , p_operator IN            VARCHAR2
                      , p_an_sql   IN            BOOLEAN DEFAULT FALSE
                      , p_vs_sql   IN            BOOLEAN DEFAULT FALSE ) IS

l_proc        varchar2(72);
l_dyn_sql     LONG;
l_ref_dyn_sql LONG;

l_value_string  VARCHAR2(150);
l_string_start  VARCHAR2(30) := '( ta.bld_blk_info_type_id = ';
l_string_and    VARCHAR2(10)  := ' AND ta.';


BEGIN

IF ( g_debug ) THEN
  l_proc := g_package||'get_dyn_sql';
  hr_utility.trace('get dyn sql params are ....');
  hr_utility.trace('dyn sql is '||p_time_sql);
END IF;

-- we want the dynamic sql string

l_dyn_sql := p_time_sql;

l_ref_dyn_sql := NULL;

IF ( p_comps_r.context = 'Dummy Element Context' AND p_comps_r.flex_value_set_id = -1 AND
     p_comps_r.value_id <> '<WILDCARD>' )
THEN
  l_value_string := 'ELEMENT - '||p_comps_r.value_id;
ELSE
  l_value_string := p_comps_r.value_id;
END IF;


IF ( l_first_time_round )
THEN

-- set string for an sql
IF ( p_an_sql )
THEN
  l_string_and := ' AND ( ta.';
END IF;
  IF ( p_comps_r.segment IS NOT NULL )
  THEN
    IF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'Y' ) )
    THEN
	IF ( p_an_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL ';
	ELSE
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL )';
	END IF;

    ELSIF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'N' ) )
    THEN
      IF ( g_debug ) THEN
	hr_utility.trace('GAZ - INVALID COMBO');
      END IF;

      fnd_message.set_name('HXC', 'HXC_TC_INV_EQUAL_IS_NULL_COMBO');
      fnd_message.raise_error;

    ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'Y' ) )
    THEN
      IF ( p_an_sql )
      THEN
          l_dyn_sql := l_dyn_sql
          ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NULL ';
      ELSE
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NULL )';
      END IF;

    ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'N' ) )
    THEN
	IF ( p_an_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL ';
	ELSE
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL )';
	END IF;

    ELSIF ( p_comps_r.equal_to = 'Y' )
    THEN
	IF ( p_an_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' = '''||l_value_string||''' ';
	ELSIF ( p_vs_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IN ( '||l_value_string||' ) ';
	ELSE
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' = '''||l_value_string||''' )';
	END IF;
     ELSE
	IF ( p_an_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' <> '''||l_value_string||''' ';
	ELSIF ( p_vs_sql )
	THEN
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' NOT IN ( '||l_value_string||' ) ';
	ELSE
	  l_dyn_sql := l_dyn_sql
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' <> '''||l_value_string||''' )';
	END IF;
     END IF;
   ELSE
     -- Ignore these TC components
     -- EAch Time Category SQL to be evaluated seperately from
     -- now on so combining of TIME_SQL not necessary

     IF ( g_debug ) THEN
	hr_utility.trace('GAZ - another TC !!!!');
     END IF;
   END IF;

ELSE

  IF ( g_debug ) THEN
    hr_utility.trace('not first time round');
    hr_utility.trace('sql is '||l_dyn_sql);
  END IF;

-- set l_string_start for the case when generating SQL for alernate name
  IF ( p_comps_r.segment IS NOT NULL )
  THEN
   IF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'Y' ) )
   THEN
     IF ( p_an_sql )
     THEN
	  l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
	  ||p_comps_r.segment||' IS NOT NULL ';
     ELSE
	  l_dyn_sql := l_dyn_sql||' '||p_operator||' '
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL )';
     END IF;

   ELSIF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'N' ) )
   THEN
     IF ( g_debug ) THEN
	hr_utility.trace('GAZ - INVALID COMBO');
     END IF;

     fnd_message.set_name('HXC', 'HXC_TC_INV_EQUAL_IS_NULL_COMBO');
     fnd_message.raise_error;

   ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'Y' ) )
   THEN
     IF ( p_an_sql )
     THEN
	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
	  ||p_comps_r.segment||' IS NULL ';
     ELSE
	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NULL )';
     END IF;

   ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'N' ) )
   THEN
     IF ( p_an_sql )
     THEN
	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
	  ||p_comps_r.segment||' IS NOT NULL ';
     ELSE
	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' IS NOT NULL )';
     END IF;

   ELSIF ( p_comps_r.equal_to = 'Y' )
   THEN
     IF ( p_an_sql )
     THEN
	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
	  ||p_comps_r.segment||' = '''||l_value_string||''' ';
     ELSE
	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' = '''||l_value_string||''' )';
     END IF;
   ELSE
     IF ( p_an_sql )
     THEN
	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
	  ||p_comps_r.segment||' <> '''||l_value_string||''' ';
     ELSE
	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
	  ||l_string_start||p_comps_r.bld_blk_info_type_id
	  ||l_string_and  ||p_comps_r.segment
	  ||' <> '''||l_value_string||''' )';
     END IF;
   END IF;
  ELSE
    -- Ignore these TC components
    -- EAch Time Category SQL to be evaluated seperately from
    -- now on so combining of TIME_SQL not necessary

    IF ( g_debug ) THEN
      hr_utility.trace('GAZ - another TC !!!!');
    END IF;
  END IF;
END IF;

IF ( g_debug ) THEN
  hr_utility.trace('dyn sql is '||l_dyn_sql);
END IF;

p_time_sql := l_dyn_sql;

END get_dyn_sql;

-- ----------------------------------------------------------------------------
-- |--------------------------< mapping_component_string  >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE mapping_component_string ( p_time_category_id NUMBER
                                   , p_time_sql	    IN OUT NOCOPY LONG ) IS



l_proc      varchar2(72);

l_dynamic_sql	LONG;
l_ref_dyn_sql	LONG;


BEGIN -- mapping_component_string

g_debug := hr_utility.debug_enabled;

l_first_time_round := TRUE;

-- ***************************************
--       MAPPING_COMPONENT_STRING
-- ***************************************

IF ( g_debug ) THEN
	l_proc := g_package||'mapping_component_string';
	hr_utility.set_location('Processing '||l_proc, 10);

	hr_utility.trace('Time Category ID is '||to_char(p_time_category_id));
END IF;

-- get the time category operator

OPEN  csr_get_operator ( p_time_category_id);
FETCH csr_get_operator INTO l_operator;
CLOSE csr_get_operator;

-- check for cached value first

-- maintain index value

OPEN	csr_get_category_comps ( p_time_category_id );
FETCH	csr_get_category_comps INTO l_comps_r;

IF ( g_debug ) THEN
  hr_utility.set_location('Processing '||l_proc, 20);
END IF;

WHILE csr_get_category_comps%FOUND
LOOP

  IF ( g_debug ) THEN
    hr_utility.set_location('Processing '||l_proc, 30);
  END IF;

  get_dyn_sql ( p_time_sql => l_dynamic_sql
 	      , p_comps_r  => l_comps_r
              , p_operator => l_operator );

  IF ( g_debug ) THEN
    hr_utility.set_location('Processing '||l_proc, 60);
  END IF;

  FETCH	csr_get_category_comps INTO l_comps_r;

  l_first_time_round := FALSE;

END LOOP;

IF ( g_debug ) THEN
  hr_utility.set_location('Processing '||l_proc, 70);
END IF;

CLOSE csr_get_category_comps;

IF ( g_debug ) THEN
  hr_utility.set_location('Processing '||l_proc, 80);
END IF;

IF ( l_dynamic_sql IS NOT NULL )
THEN

  l_dynamic_sql := ' ( '||l_dynamic_sql||' ) ';
  validate_time_category_sql ( l_dynamic_sql );

END IF;

p_time_sql := l_dynamic_sql;

IF ( g_debug ) THEN
 hr_utility.trace('Final dyn sql is '||NVL(p_time_sql,'Empty'));
END IF;


END mapping_component_string;

-- ----------------------------------------------------------------------------
-- |-------------< BEGIN OF set_dynamic_sql_string  >-------------------------|
-- ----------------------------------------------------------------------------


BEGIN

g_debug := hr_utility.debug_enabled;

mapping_component_string (
	p_time_category_id => p_time_category_id
,	p_time_sql	   => l_time_sql );

if g_debug then
  hr_utility.trace('set dyn sql string string is '||l_time_sql);
end if;

UPDATE hxc_time_categories
SET    time_sql = l_time_sql
WHERE  time_category_id = p_time_category_id;

exception when others then

if g_debug then
  hr_utility.trace('exception is '||SQLERRM);
end if;

raise;

END set_dynamic_sql_string;

END hxc_load_pkg;

/
