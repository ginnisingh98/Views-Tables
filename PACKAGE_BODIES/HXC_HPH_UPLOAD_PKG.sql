--------------------------------------------------------
--  DDL for Package Body HXC_HPH_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HPH_UPLOAD_PKG" AS
/* $Header: hxchphupl.pkb 115.26 2003/09/22 10:05:51 mvilrokx noship $ */

PROCEDURE load_hph_row (
	  p_name		VARCHAR2
	, p_legislation_code	VARCHAR2
	, p_parent_name 	varchar2
	, p_type		varchar2
	, p_edit_allowed	varchar2
	, p_displayed		varchar2
	, p_pref_def_name	varchar2
	, p_attribute_category	varchar2
	, p_attribute1		 varchar2
	, p_attribute2		  varchar2
	, p_attribute3		  varchar2
	, p_attribute4		  varchar2
	, p_attribute5		  varchar2
	, p_attribute6		  varchar2
	, p_attribute7		  varchar2
	, p_attribute8		  varchar2
	, p_attribute9		  varchar2
	, p_attribute10	   	  varchar2
	, p_attribute11	   	  varchar2
	, p_attribute12	   	  varchar2
	, p_attribute13	   	  varchar2
	, p_attribute14	   	  varchar2
	, p_attribute15	   	  varchar2
	, p_attribute16	   	  varchar2
	, p_attribute17	   	  varchar2
	, p_attribute18	   	  varchar2
	, p_attribute19	   	  varchar2
	, p_attribute20	   	  varchar2
	, p_attribute21	   	  varchar2
	, p_attribute22	   	  varchar2
	, p_attribute23	   	  varchar2
	, p_attribute24	   	  varchar2
	, p_attribute25	   	  varchar2
	, p_attribute26	   	  varchar2
	, p_attribute27	   	  varchar2
	, p_attribute28	   	  varchar2
	, p_attribute29	   	  varchar2
	, p_attribute30	   	  varchar2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 ) IS

l_pref_hierarchy_id		hxc_pref_hierarchies.pref_hierarchy_id%TYPE;
l_parent_pref_hierarchy_id	hxc_pref_hierarchies.parent_pref_hierarchy_id%TYPE;
l_pref_definition_id		hxc_pref_hierarchies.pref_definition_id%TYPE;

l_attribute1			hxc_pref_hierarchies.attribute1%TYPE;
l_attribute2			hxc_pref_hierarchies.attribute1%TYPE;
l_attribute3			hxc_pref_hierarchies.attribute1%TYPE;
l_attribute4			hxc_pref_hierarchies.attribute1%TYPE;
l_attribute5			hxc_pref_hierarchies.attribute1%TYPE;
l_attribute6			hxc_pref_hierarchies.attribute1%TYPE;

l_ovn				hxc_pref_hierarchies.object_version_number%TYPE := NULL;
l_owner				VARCHAR2(6);
l_dummy				VARCHAR2(6);


CURSOR  csr_get_owner ( p_pref_hierarchy_id NUMBER ) IS
SELECT  DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
FROM    hxc_pref_hierarchies;

FUNCTION get_pref_def_id ( p_pref_def_name VARCHAR2 ) RETURN NUMBER IS

l_pref_definition_id		hxc_pref_hierarchies.pref_definition_id%TYPE;

CURSOR	csr_get_pref_def_id IS
SELECT	pd.pref_definition_id
FROM	hxc_pref_definitions pd
,	fnd_descr_flex_contexts_vl df
WHERE	df.application_id		 = 809
AND	df.descriptive_flexfield_name	 = 'OTC PREFERENCES'
AND	df.descriptive_flex_context_name = p_pref_def_name
AND	df.descriptive_flex_context_code = pd.code;

BEGIN

OPEN  csr_get_pref_def_id;
FETCH csr_get_pref_def_id INTO l_pref_definition_id;
CLOSE csr_get_pref_def_id;

RETURN l_pref_definition_id;

END get_pref_def_id;


FUNCTION get_attribute_id ( p_attribute_category	VARCHAR2
			,   p_attribute			VARCHAR2 ) RETURN VARCHAR2 IS

l_attribute_id	hxc_entity_group_comps.attribute1%TYPE;

CURSOR	csr_get_approval_style_id IS
SELECT	TO_CHAR(approval_style_id)
FROM	hxc_approval_styles
WHERE	name	= p_attribute;

CURSOR	csr_get_alias_id IS
SELECT	TO_CHAR(alias_definition_id)
FROM	hxc_alias_definitions
WHERE	alias_definition_name	= p_attribute;

CURSOR csr_get_recurring_period_id IS
SELECT TO_CHAR(rp.recurring_period_id)
FROM   hxc_recurring_periods rp
WHERE  rp.name	= p_attribute;

CURSOR	csr_get_application_set_id IS
SELECT	TO_CHAR(aps.application_set_id)
FROM	hxc_application_sets_v aps
WHERE	aps.application_set_name = p_attribute;

CURSOR	csr_get_retrieval_rule_grp_id IS
SELECT	TO_CHAR(rrg.retrieval_rule_group_id)
FROM	hxc_retrieval_rule_groups_v rrg
WHERE	rrg.retrieval_rule_group_name = p_attribute;

CURSOR	csr_get_approval_period_id IS
SELECT	TO_CHAR(aps.approval_period_set_id)
FROM	hxc_approval_period_sets aps
WHERE	aps.name = p_attribute;

CURSOR	csr_get_layout_id IS
SELECT	layout_id
FROM	hxc_layouts
WHERE	layout_name		= p_attribute;

CURSOR  csr_get_date_format IS
SELECT  egc.attribute1
FROM    hxc_entity_group_comps egc
WHERE   egc.attribute2 = p_attribute
AND EXISTS ( SELECT 'x'
             FROM   hxc_entity_groups eg
             WHERE  eg.entity_group_id = egc.entity_group_id
             AND    eg.entity_type     = 'HXC_SS_TC_DATE_FORMATS' );

CURSOR  csr_get_rule_group_id IS
SELECT  time_entry_rule_group_id
FROM    hxc_time_entry_rule_groups_v
WHERE   time_entry_rule_group_name = p_attribute1;

BEGIN

IF ( p_attribute_category = 'TS_PER_APPROVAL_STYLE' )
THEN

	OPEN  csr_get_approval_style_id;
	FETCH csr_get_approval_style_id INTO l_attribute_id;
	CLOSE csr_get_approval_style_id;

ELSIF ( p_attribute_category = 'TC_W_TCRD_PERIOD' )
THEN

	OPEN  csr_get_recurring_period_id;
	FETCH csr_get_recurring_period_id INTO l_attribute_id;
	CLOSE csr_get_recurring_period_id;

--
-- ARR: 115.7
--     Get value from cursor now, as there is a recurring period
-- loader.
--
--	l_attribute_id	:= p_attribute;
--

ELSIF ( p_attribute_category = 'TC_W_TCRD_ALIASES' )
THEN

	OPEN  csr_get_alias_id;
	FETCH csr_get_alias_id INTO l_attribute_id;
	CLOSE csr_get_alias_id;

--
-- GPM: 115.9
--     Commented out because now we are seeding aliases
--
--	l_attribute_id	:= p_attribute;

ELSIF ( p_attribute_category = 'TS_PER_APPLICATION_SET' )
THEN

	OPEN  csr_get_application_set_id;
	FETCH csr_get_application_set_id INTO l_attribute_id;
	CLOSE csr_get_application_set_id;

ELSIF ( p_attribute_category = 'TS_PER_RETRIEVAL_RULES' )
THEN

	OPEN  csr_get_retrieval_rule_grp_id;
	FETCH csr_get_retrieval_rule_grp_id INTO l_attribute_id;
	CLOSE csr_get_retrieval_rule_grp_id;

ELSIF ( p_attribute_category = 'TS_PER_APPROVAL_PERIODS' )
THEN

	OPEN  csr_get_approval_period_id;
	FETCH csr_get_approval_period_id INTO l_attribute_id;
	CLOSE csr_get_approval_period_id;

ELSIF ( p_attribute_category = 'TC_W_TCRD_LAYOUT' )
THEN

	OPEN  csr_get_layout_id;
	FETCH csr_get_layout_id INTO l_attribute_id;
	CLOSE csr_get_layout_id;

ELSIF ( p_attribute_category = 'TC_W_DATE_FORMATS' )
THEN

	OPEN  csr_get_date_format;
	FETCH csr_get_date_format INTO l_attribute_id;
	CLOSE csr_get_date_format;

ELSIF ( p_attribute_category = 'TS_PER_AUDIT_REQUIREMENTS')
THEN

       OPEN csr_get_rule_group_id;
       FETCH csr_get_rule_group_id into l_attribute_id;
       CLOSE csr_get_rule_group_id;
ELSE

	l_attribute_id	:= p_attribute;

END IF;

RETURN ltrim(rtrim(l_attribute_id));

END get_attribute_id;

BEGIN -- load_hph_row

l_pref_definition_id := get_pref_def_id ( p_pref_def_name );

l_attribute2 := p_attribute2;
l_attribute3 := p_attribute3;
l_attribute4 := p_attribute4;
l_attribute5 := p_attribute5;
l_attribute6 := p_attribute6;

IF ( p_attribute_category = 'TS_PER_APPROVAL_STYLE' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );
	l_attribute2	:= get_attribute_id ( p_attribute_category, p_attribute2 );

ELSIF ( p_attribute_category = 'TC_W_TCRD_ALIASES' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );

ELSIF ( p_attribute_category = 'TS_PER_APPLICATION_SET' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );

ELSIF ( p_attribute_category = 'TS_PER_APPROVAL_PERIODS' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );

ELSIF ( p_attribute_category = 'TS_PER_RETRIEVAL_RULES' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );

ELSIF ( p_attribute_category = 'TC_W_TCRD_LAYOUT' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );
	l_attribute2	:= get_attribute_id ( p_attribute_category, p_attribute2 );
	l_attribute3	:= get_attribute_id ( p_attribute_category, p_attribute3 );
	l_attribute4	:= get_attribute_id ( p_attribute_category, p_attribute4 );
	l_attribute5	:= get_attribute_id ( p_attribute_category, p_attribute5 );
	l_attribute6	:= get_attribute_id ( p_attribute_category, p_attribute6 );

ELSIF ( p_attribute_category = 'TC_W_TCRD_PERIOD' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );

ELSIF ( p_attribute_category = 'TC_W_DATE_FORMATS' )
THEN
	l_attribute1	:= get_attribute_id ( p_attribute_category, p_attribute1 );
	l_attribute2	:= get_attribute_id ( p_attribute_category, p_attribute2 );
	l_attribute3	:= get_attribute_id ( p_attribute_category, p_attribute3 );

ELSIF (p_attribute_category = 'TS_PER_AUDIT_REQUIREMENTS' )
THEN
       l_attribute1     := get_attribute_id ( p_attribute_category, p_attribute1);

ELSE
	l_attribute1	:= p_attribute1;
END IF;

-- check to see if the preference we are about to load already exists

hxc_pref_hierarchies_api.get_node_data (
		p_preference_full_name	=>	p_parent_name
	,	p_name			=>	p_name
	,	p_business_group_id	=>	null
	,	p_legislation_code	=>	p_legislation_code
	,	p_pref_hierarchy_id	=> 	l_pref_hierarchy_id
	,	p_parent_pref_hierarchy_id =>	l_parent_pref_hierarchy_id
	,	p_object_version_number    => 	l_ovn
	,	p_mode			=>	l_dummy );

IF ( l_pref_hierarchy_id IS NOT NULL )
THEN

	OPEN  csr_get_owner ( l_pref_hierarchy_id );
	FETCH csr_get_owner INTO l_owner;
	CLOSE csr_get_owner;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

	hxc_pref_hierarchies_api.update_pref_hierarchies (
				  p_effective_date	=> sysdate
				, p_name		=> p_name
				, p_business_group_id	=> null
				, p_legislation_code	=> p_legislation_code
				, p_pref_hierarchy_id	=> l_pref_hierarchy_id
				, p_parent_pref_hierarchy_id	=> l_parent_pref_hierarchy_id
				, p_type		=> p_type
				, p_edit_allowed	=> p_edit_allowed
				, p_displayed		=> p_displayed
				, p_pref_definition_id	=>  l_pref_definition_id
				, p_attribute_category	   => p_attribute_category
				, p_attribute1		=> l_attribute1
				, p_attribute2		=> l_attribute2
				, p_attribute3		=> l_attribute3
				, p_attribute4		=> l_attribute4
				, p_attribute5		=> l_attribute5
				, p_attribute6		=> l_attribute6
				, p_attribute7		=> p_attribute7
				, p_attribute8		=> p_attribute8
				, p_attribute9		=> p_attribute9
				, p_attribute10		=> p_attribute10
				, p_attribute11		=> p_attribute11
				, p_attribute12		=> p_attribute12
				, p_attribute13		=> p_attribute13
				, p_attribute14		=> p_attribute14
				, p_attribute15		=> p_attribute15
				, p_attribute16		=> p_attribute16
				, p_attribute17		=> p_attribute17
				, p_attribute18		=> p_attribute18
				, p_attribute19		=> p_attribute19
				, p_attribute20		=> p_attribute20
				, p_attribute21		=> p_attribute21
				, p_attribute22		=> p_attribute22
				, p_attribute23		=> p_attribute23
				, p_attribute24		=> p_attribute24
				, p_attribute25		=> p_attribute25
				, p_attribute26		=> p_attribute26
				, p_attribute27		=> p_attribute27
				, p_attribute28		=> p_attribute28
				, p_attribute29		=> p_attribute29
				, p_attribute30		=> p_attribute30
	  			, p_object_version_number  => l_ovn );

	END IF;

ELSE

	hxc_pref_hierarchies_api.create_pref_hierarchies (
			  p_effective_date	=> sysdate
			, p_name		=> p_name
			, p_business_group_id	=> null
			, p_legislation_code	=> p_legislation_code
			, p_pref_hierarchy_id	=> l_pref_hierarchy_id
			, p_parent_pref_hierarchy_id	=> l_parent_pref_hierarchy_id
			, p_type		=> p_type
			, p_edit_allowed	=> p_edit_ALLOWED
			, p_displayed		=> p_displayed
			, p_pref_definition_id	=>  l_pref_definition_id
			, p_attribute_category	   => p_attribute_category
			, p_attribute1		=> l_attribute1
			, p_attribute2		=> l_attribute2
			, p_attribute3		=> l_attribute3
			, p_attribute4		=> l_attribute4
			, p_attribute5		=> l_attribute5
			, p_attribute6		=> l_attribute6
			, p_attribute7		=> p_attribute7
			, p_attribute8		=> p_attribute8
			, p_attribute9		=> p_attribute9
			, p_attribute10		=> p_attribute10
			, p_attribute11		=> p_attribute11
			, p_attribute12		=> p_attribute12
			, p_attribute13		=> p_attribute13
			, p_attribute14		=> p_attribute14
			, p_attribute15		=> p_attribute15
			, p_attribute16		=> p_attribute16
			, p_attribute17		=> p_attribute17
			, p_attribute18		=> p_attribute18
			, p_attribute19		=> p_attribute19
			, p_attribute20		=> p_attribute20
			, p_attribute21		=> p_attribute21
			, p_attribute22		=> p_attribute22
			, p_attribute23		=> p_attribute23
			, p_attribute24		=> p_attribute24
			, p_attribute25		=> p_attribute25
			, p_attribute26		=> p_attribute26
			, p_attribute27		=> p_attribute27
			, p_attribute28		=> p_attribute28
			, p_attribute29		=> p_attribute29
			, p_attribute30		=> p_attribute30
  			, p_object_version_number  => l_ovn );

END IF; -- l_ovn check

END load_hph_row;

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
		,	 p_attribute		VARCHAR2 ) RETURN VARCHAR2 IS

l_real_value	VARCHAR2(150);

CURSOR	csr_get_approval_style IS
SELECT	name
FROM	hxc_approval_styles
WHERE	approval_style_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_application_set IS
SELECT	application_set_name
FROM	hxc_application_sets_v
WHERE	application_set_id	= TO_NUMBER(p_attribute);

CURSOR	csr_get_retrieval_rule_grp IS
SELECT	retrieval_rule_group_name
FROM	hxc_retrieval_rule_groups_v
WHERE	retrieval_rule_group_id	= TO_NUMBER(p_attribute);

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

CURSOR  csr_get_time_entry_rule_name IS
SELECT  time_entry_rule_group_name
FROM    hxc_time_entry_rule_groups_v
WHERE   time_entry_rule_group_id = TO_NUMBER(p_attribute);

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

ELSE

	l_real_value	:= p_attribute;

END IF;

RETURN l_real_value;

END get_attribute;

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

END hxc_hph_upload_pkg;

/
