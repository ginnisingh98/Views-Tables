--------------------------------------------------------
--  DDL for Package Body HXC_RESOURCE_RULES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RESOURCE_RULES_UTILS" as
/* $Header: hxchrrutl.pkb 120.3.12010000.4 2009/11/11 06:32:10 amakrish ship $ */
--
g_debug	boolean	:=hr_utility.debug_enabled;

PROCEDURE get_value_set_sql ( 	p_flex_Field_name 	varchar2
			,	p_legislation_code	varchar2 ) IS

l_id_flex_code	fnd_id_flexs.id_flex_code%TYPE;
l_id_flex_num	fnd_id_flex_segments.id_flex_num%TYPE;
l_flex_seg	varchar2(9);
l_where_clause	fnd_flex_validation_tables.additional_where_clause%TYPE;

r_valueset	fnd_vset.valueset_r;
l_valueset_dr	fnd_vset.valueset_dr;

CURSOR  csr_get_scl_vset_id ( p_flex_code   varchar2
			,     p_id_flex_num number ) IS
SELECT 	seg.flex_value_Set_id
FROM
	fnd_id_flex_segments seg
,	fnd_id_Flexs fl
WHERE
	fl.id_flex_code	= p_flex_code
AND
	seg.id_flex_code= fl.id_flex_code AND
	-- ***** Start new code for bug 2669059 **************
	seg.application_id = fl.application_id AND
	-- ***** End new code for bug 2669059 **************
	seg.id_flex_num = p_id_flex_num;


FUNCTION get_scl_flex_num RETURN NUMBER IS

CURSOR	csr_get_id_flex_num IS
SELECT	rule_mode
FROM	pay_legislation_rules
WHERE	legislation_code = p_legislation_code
AND	rule_type 	 = 'S';

l_id_flex_num	fnd_id_flex_segments.id_flex_num%TYPE;

BEGIN

OPEN  csr_get_id_flex_num;
FETCH csr_get_id_flex_num INTO l_id_flex_num;
CLOSE csr_get_id_flex_num;

RETURN l_id_flex_num;

END get_scl_flex_num;


BEGIN

l_id_flex_code := SUBSTR( p_flex_field_name, 1, (INSTR(p_flex_field_name, '-',1,1)-1) );
l_flex_seg  := SUBSTR( p_flex_field_name, (INSTR(p_flex_field_name, '-',1,1)+1) );

IF ( l_id_flex_code = 'SCL' )
THEN

	l_id_flex_num := get_scl_flex_num;

	-- get the value set id associated with each segment

	-- gaz - need to add param to the cursor for segment


	FOR vset_rec IN csr_get_scl_vset_id ( p_flex_code   => l_id_flex_code
					    , p_id_flex_num => l_id_flex_num )
	LOOP

	IF ( vset_rec.flex_value_set_id IS NOT NULL )
	THEN

	fnd_vset.get_valueset(
			valueset_id	=> vset_rec.flex_value_set_id
                   ,    valueset	=> r_valueset
                   ,    format		=> l_valueset_dr);

/*
	insert into gaz_value_set ( vset_id, name, where_clause )
	values ( vset_rec.flex_value_set_id, r_valueset.name, r_valueset.table_info.where_clause );
*/

	END IF;

	END LOOP;

END IF;

END get_value_set_sql;

FUNCTION get_sequence ( p_type varchar2
		,	p_id_flex_num number default null ) RETURN NUMBER IS

-- ***** Start commented code for bug 2669059 **************


-- CURSOR	csr_scl_get_seq IS
-- SELECT	seg.application_column_name
-- FROM
-- 	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- ,	pay_legislation_rules lr
-- WHERE
-- 	fl.id_flex_name	= 'Soft Coded KeyFlexfield'
-- AND
-- 	s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num = seg.id_flex_num AND
-- 	s.id_flex_structure_code = 'GRES_AND_OTHER_DATA'
-- AND
-- 	lr.legislation_code = 'US' AND
-- 	lr.rule_type = 'S'
-- AND
-- 	seg.id_flex_num = lr.rule_mode AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.display_flag = 'Y'
-- order by seg.segment_num;

-- ***** End commented code for bug 2669059 **************

-- ***** Start new code for bug 2669059 **************

CURSOR	csr_scl_get_seq IS
SELECT	seg.application_column_name
FROM
	fnd_id_flex_segments seg
,	fnd_id_flex_structures s
,	fnd_id_Flexs fl
,	pay_legislation_rules lr
WHERE
-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name	 	 = 'Soft Coded KeyFlexfield' AND
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'SCL' AND
-- ***** End new code for bug 2678547 **************

	fl.application_id  	 = 800 AND
	s.id_flex_code 		 = fl.id_flex_code AND
	s.application_id         = fl.application_id AND
	s.id_flex_num 		 = seg.id_flex_num AND
	s.id_flex_structure_code = 'GRES_AND_OTHER_DATA' AND
	lr.legislation_code 	 = 'US' AND
	lr.rule_type 		 = 'S' AND
	seg.id_flex_num 	 = lr.rule_mode AND
	seg.application_id 	 = s.application_id AND
	seg.id_flex_code	 = fl.id_flex_code AND
	seg.display_flag 	 = 'Y'

ORDER BY seg.segment_num;

-- ***** End new code for bug 2669059 **************


-- ***** Start commented code for bug 2669059 **************


-- CURSOR	csr_people_get_seq IS
-- SELECT	seg.application_column_name
-- FROM
-- 	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'People Group Flexfield'
-- AND
-- 	s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num  = seg.id_flex_num
-- AND
-- 	seg.id_flex_num = p_id_flex_num   AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.display_flag = 'Y'
-- order by seg.segment_num;
-- ***** End commented code for bug 2669059 **************

-- ***** Start new code for bug 2669059 **************

CURSOR	csr_people_get_seq IS
select	seg.application_column_name
from
	fnd_id_flex_segments seg,
	fnd_id_flex_structures s,
	fnd_id_Flexs fl
where
-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name		   = 'People Group Flexfield' 	and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'GRP' and
-- ***** End new code for bug 2678547 **************

	fl.application_id 	   = 801 and
    	s.id_flex_code 		   = fl.id_flex_code and
    	s.application_id  	   = fl.application_id and
	s.id_flex_num  		   = seg.id_flex_num and
	seg.id_flex_num 	   = p_id_flex_num and
	seg.application_id 	   = s.application_id and
	seg.id_flex_code	   = fl.id_flex_code and
	seg.display_flag 	   = 'Y'
order by  seg.segment_num;

-- ***** End new code for bug 2669059 **************

-- ***** Start commented code for bug 2669059 **************


-- CURSOR	csr_grade_get_seq IS
-- SELECT	seg.application_column_name
-- FROM
-- 	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'Grade Flexfield'
-- AND
-- 	s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num  = seg.id_flex_num
-- AND
-- 	seg.id_flex_num = p_id_flex_num   AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.display_flag = 'Y'
-- order by seg.segment_num;

-- ***** End commented code for bug 2669059 **************

-- ***** Start new code for bug 2669059 **************

CURSOR	csr_grade_get_seq IS
select	seg.application_column_name
from
	fnd_id_flex_segments seg
,	fnd_id_flex_structures s
,	fnd_id_Flexs fl
where
-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name		   = 'Grade Flexfield' and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'GRD' and
-- ***** End new code for bug 2678547 **************

	fl.application_id 	   = 800 and
	s.id_flex_code 		   = fl.id_flex_code and
    	s.application_id  	   = fl.application_id and
	s.id_flex_num  		   = seg.id_flex_num and
	seg.id_flex_num 	   = p_id_flex_num   and
	seg.application_id 	   = s.application_id and
	seg.id_flex_code	   = fl.id_flex_code and
	seg.display_flag 	   = 'Y'
order by seg.segment_num;

-- ***** End new code for bug 2669059 **************


l_seq NUMBER(2) := 1;


BEGIN
g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.set_location('gaz - in get sequence',10);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

IF (SUBSTR(p_type, 1, 3) = 'SCL')
THEN
if g_debug then
	hr_utility.set_location('gaz - in get sequence',20);
end if;

-- loop to find a value - sometimes null when keyflex
-- has had different number of segments and concatenated segment value
-- has different number of values.

FOR scl IN csr_scl_get_seq
LOOP
if g_debug then
	hr_utility.set_location('gaz - in get sequence',30);
end if;

	IF ( scl.application_column_name = SUBSTR( p_type, 5 ) )
	THEN
		EXIT;
	END IF;

	l_seq := l_seq + 1;

END LOOP;

ELSIF ( SUBSTR( p_type, 1, 6) = 'PEOPLE' )
THEN
if g_debug then
	hr_utility.set_location('gaz - in get sequence',40);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

FOR grp IN csr_people_get_seq
LOOP
if g_debug then
	hr_utility.set_location('gaz - in get sequence',50);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

	IF ( grp.application_column_name = SUBSTR( p_type, 8 ) )
	THEN
		EXIT;
	END IF;

	l_seq := l_seq + 1;

END LOOP;
if g_debug then
	hr_utility.set_location('gaz - in get sequence',60);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

ELSIF ( SUBSTR( p_type, 1, 5) = 'GRADE' )
THEN
if g_debug then
	hr_utility.set_location('gaz - in get sequence',70);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

FOR grd IN csr_grade_get_seq
LOOP
if g_debug then
	hr_utility.set_location('gaz - in get sequence',80);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

	IF ( grd.application_column_name = SUBSTR( p_type, 7 ) )
	THEN
		EXIT;
	END IF;

	l_seq := l_seq + 1;

END LOOP;
if g_debug then
	hr_utility.set_location('gaz - in get sequence',90);
	hr_utility.set_location('gaz - l seq is '||to_char(l_seq),10);
end if;

END IF;

RETURN l_seq;

END get_sequence;

FUNCTION get_meaning (  p_type  VARCHAR2
		,	p_value VARCHAR2
		,	p_business_group_id NUMBER default null
		,	p_legislation_code  VARCHAR2 ) RETURN VARCHAR2 IS

l_sequence NUMBER(2);
l_meaning  VARCHAR2(240);


-- Perf Rep.Fix - SQL ID:3174489
CURSOR	csr_get_scl_segs IS
SELECT  COUNT( seg.display_flag)
,	ifs.concatenated_segment_delimiter
,	lr.rule_mode
FROM
	fnd_id_flex_segments seg
,	fnd_id_flex_structures ifs
,	pay_legislation_rules  lr
WHERE
	lr.legislation_code	= p_legislation_code AND
	lr.rule_type		= 'S' AND
	ifs.id_flex_num	= lr.rule_mode 	AND

	-- ***** Start new code for bug 2669059 **************
	ifs.application_id = 800 AND
	-- ***** End new code for bug 2669059 **************

	seg.id_flex_num	 = ifs.id_flex_num AND

	-- ***** Start new code for bug 2669059 **************
	seg.application_id = ifs.application_id AND
	-- ***** End new code for bug 2669059 **************

	seg.display_flag = 'Y'
GROUP BY
	ifs.concatenated_segment_delimiter
,	lr.rule_mode;


-- ***** Start commented code for bug 2669059 **************

-- CURSOR  csr_get_people_segs IS
-- SELECT
-- 	COUNT(seg.display_flag)
-- ,	ifs.concatenated_segment_delimiter
-- ,	ifs.id_flex_num
-- FROM
-- 	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures ifs
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'People Group Flexfield'
-- AND
-- 	ifs.id_flex_code		= fl.id_Flex_code AND
-- 	ifs.id_flex_num  = (
-- 	SELECT	DISTINCT z.id_flex_num
-- 	FROM	per_all_assignments_f asg
-- 	,	pay_people_groups z
-- 	WHERE	asg.people_group_id   = z.people_group_id
-- 	AND	asg.business_group_id = p_business_group_id )
-- AND
-- 	seg.id_flex_num	= ifs.id_flex_num AND
-- 	seg.display_flag = 'Y'
-- GROUP BY
-- 	ifs.concatenated_segment_delimiter
-- ,	ifs.id_flex_num;
-- ***** End commented code for bug 2669059 **************


-- ***** Start new code for bug 2669059 **************

CURSOR  csr_get_people_segs IS
select
	COUNT(seg.display_flag)
,	ifs.concatenated_segment_delimiter
,	ifs.id_flex_num
from
	fnd_id_flex_segments seg
,	fnd_id_flex_structures ifs
,	fnd_id_Flexs fl
where
-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name		= 'People Group Flexfield' AND
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'GRP' AND
-- ***** End new code for bug 2678547 **************

	fl.application_id 	= 801 AND
	ifs.id_flex_code 	= fl.id_Flex_code AND
	ifs.application_id  	= fl.application_id AND
	ifs.id_flex_num  	=
	(
--***** Start new code for Bug 5089488**************
	select 	hoi.ORG_INFORMATION5
	from   hr_organization_units hou,
       	   hr_organization_information hoi,
       	   hr_organization_information hoi2
	where  hou.business_group_id = p_business_group_id
	and    hou.organization_id = hoi.organization_id
	and    hoi.organization_id = hoi2.organization_id
	and    hoi.org_information_context = 'Business Group Information'
	and    sysdate between hou.Date_from and nvl(hou.date_to,sysdate)
	and    hoi2.org_information1='HR_BG' and hoi2.org_information2='Y'
--***** end new code for Bug 5089488**************
	) 	AND
	seg.id_flex_num		= ifs.id_flex_num AND
	seg.application_id 	= ifs.application_id AND
-- Bug 2926733
	seg.id_flex_code = ifs.id_flex_code AND
	seg.display_flag 	= 'Y'
group by
	ifs.concatenated_segment_delimiter
,	ifs.id_flex_num;

-- ***** End new code for bug 2669059 **************


-- ***** Start commented code for bug 2669059 **************

-- CURSOR  csr_get_grade_segs IS
-- SELECT
-- COUNT(seg.display_flag)
-- ,	ifs.concatenated_segment_delimiter
-- ,	ifs.id_flex_num
-- FROM
-- fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures ifs
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'Grade Flexfield'
-- AND
-- 	ifs.id_flex_code = fl.id_Flex_code AND
-- 	ifs.id_flex_num  = (
-- 	SELECT	DISTINCT gd.id_flex_num
-- 	FROM	per_grades g
-- 	,	per_grade_Definitions gd
-- 	WHERE	gd.grade_definition_id = g.grade_definition_id
-- 	AND	g.business_group_id    = p_business_group_id )
-- AND
-- 	seg.id_flex_num	= ifs.id_flex_num AND
-- 	seg.display_flag = 'Y'
-- GROUP BY
-- 	ifs.concatenated_segment_delimiter
-- ,	ifs.id_flex_num;
-- ***** End commented code for bug 2669059 **************


-- ***** Start new code for bug 2669059 **************

CURSOR  csr_get_grade_segs IS
select
	COUNT(seg.display_flag),
	ifs.concatenated_segment_delimiter,
	ifs.id_flex_num
from
	fnd_id_flex_segments seg,
	fnd_id_flex_structures ifs,
	fnd_id_Flexs fl
where
-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name		= 'Grade Flexfield' and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'GRD' and
-- ***** End new code for bug 2678547 **************

	fl.application_id 	= 800 and
	ifs.id_flex_code 	= fl.id_Flex_code and
    	ifs.application_id  	= fl.application_id and
	ifs.id_flex_num  =
	(
--***** start new code for Bug 5089488**************
	select 	hoi.ORG_INFORMATION4
	from   hr_organization_units hou,
       	   hr_organization_information hoi,
       	   hr_organization_information hoi2
	where  hou.business_group_id = p_business_group_id
	and    hou.organization_id = hoi.organization_id
	and    hoi.organization_id = hoi2.organization_id
	and    hoi.org_information_context = 'Business Group Information'
	and    sysdate between hou.Date_from and nvl(hou.date_to,sysdate)
	and    hoi2.org_information1='HR_BG' and hoi2.org_information2='Y'
--***** end new code for Bug 5089488**************
	) and
	seg.id_flex_num		= ifs.id_flex_num and
	seg.application_id 	= ifs.application_id and
-- Bug 2926733
	seg.id_flex_code = ifs.id_flex_code AND
	seg.display_flag 	= 'Y'
group by
	ifs.concatenated_segment_delimiter,
	ifs.id_flex_num;
-- ***** End new code for bug 2669059 **************


-- Modified DECODE statement for bug 9104542
CURSOR csr_get_scl_meaning(p_id_flex_num NUMBER
			,  p_sequence    NUMBER
			,  p_max_sequence NUMBER
			,  p_delimiter   VARCHAR2
			,  p_type        VARCHAR2
			,  p_value       VARCHAR2 ) IS
SELECT
DECODE ( p_sequence,
     1,
   REPLACE( SUBSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), 0,DECODE(INSTR ( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ),p_delimiter,1,1),0,LENGTH(concatenated_segments),
                  INSTR ( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), p_delimiter, 1,1)-1)), '\ ', p_delimiter),
     p_max_sequence,
   REPLACE( SUBSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), INSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1), '\ ', p_delimiter ),
   REPLACE( SUBSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), (INSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1),
	        ( INSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), p_delimiter, 1, p_sequence)
                -(INSTR( REPLACE(concatenated_segments, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1))), '\ ', p_delimiter )
        ) meaning
FROM	hr_soft_coding_keyflex
WHERE	id_flex_num = p_id_flex_num
AND	DECODE ( SUBSTR( p_type, 5 ),
	'SEGMENT1', segment1,
	'SEGMENT2', segment2,
	'SEGMENT3', segment3,
	'SEGMENT4', segment4,
	'SEGMENT5', segment5,
	'SEGMENT6', segment6,
	'SEGMENT7', segment7,
	'SEGMENT8', segment8,
	'SEGMENT9', segment9,
	'SEGMENT10', segment10,
	'SEGMENT11', segment11,
	'SEGMENT12', segment12,
	'SEGMENT13', segment13,
	'SEGMENT14', segment14,
	'SEGMENT15', segment15,
	'SEGMENT16', segment16,
	'SEGMENT17', segment17,
	'SEGMENT18', segment18,
	'SEGMENT19', segment19,
	'SEGMENT20', segment20,
	'SEGMENT21', segment21,
	'SEGMENT22', segment22,
	'SEGMENT23', segment23,
	'SEGMENT24', segment24,
	'SEGMENT25', segment25,
	'SEGMENT26', segment26,
	'SEGMENT27', segment27,
	'SEGMENT28', segment28,
	'SEGMENT29', segment29,
	'SEGMENT30', segment30, -1 ) = p_value;


-- Modified DECODE statement for bug 9104542
CURSOR csr_get_people_meaning(
			   p_id_flex_num NUMBER
			,  p_sequence    NUMBER
			,  p_max_sequence NUMBER
			,  p_delimiter   VARCHAR2
			,  p_type        VARCHAR2
			,  p_value       VARCHAR2 ) IS
SELECT
DECODE ( p_sequence,
     1,
   REPLACE( SUBSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), 0,DECODE(INSTR ( REPLACE(group_name, '\'||p_delimiter, '\ ' ),p_delimiter,1,1),0,LENGTH(group_name),
   		  INSTR ( REPLACE(group_name, '\'||p_delimiter, '\ ' ), p_delimiter, 1,1)-1)), '\ ', p_delimiter),
     p_max_sequence,
   REPLACE( SUBSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), INSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1), '\ ', p_delimiter ),
   REPLACE( SUBSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), (INSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1),
	        ( INSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), p_delimiter, 1, p_sequence)
                -(INSTR( REPLACE(group_name, '\'||p_delimiter, '\ ' ), p_delimiter, 1, (p_sequence-1))+1))), '\ ', p_delimiter )
        ) meaning
 FROM	pay_people_groups
WHERE	id_flex_num = p_id_flex_num
AND	DECODE ( SUBSTR( p_type, 8 ),
	'SEGMENT1', segment1,
	'SEGMENT2', segment2,
	'SEGMENT3', segment3,
	'SEGMENT4', segment4,
	'SEGMENT5', segment5,
	'SEGMENT6', segment6,
	'SEGMENT7', segment7,
	'SEGMENT8', segment8,
	'SEGMENT9', segment9,
	'SEGMENT10', segment10,
	'SEGMENT11', segment11,
	'SEGMENT12', segment12,
	'SEGMENT13', segment13,
	'SEGMENT14', segment14,
	'SEGMENT15', segment15,
	'SEGMENT16', segment16,
	'SEGMENT17', segment17,
	'SEGMENT18', segment18,
	'SEGMENT19', segment19,
	'SEGMENT20', segment20,
	'SEGMENT21', segment21,
	'SEGMENT22', segment22,
	'SEGMENT23', segment23,
	'SEGMENT24', segment24,
	'SEGMENT25', segment25,
	'SEGMENT26', segment26,
	'SEGMENT27', segment27,
	'SEGMENT28', segment28,
	'SEGMENT29', segment29,
	'SEGMENT30', segment30, -1 ) = p_value;


-- Modified DECODE statement for bug 9104542
CURSOR csr_get_grade_meaning(
			   p_id_flex_num NUMBER
			,  p_sequence    NUMBER
			,  p_max_sequence NUMBER
			,  p_delimiter   VARCHAR2
			,  p_type        VARCHAR2
			,  p_value       VARCHAR2 ) IS
SELECT
DECODE ( p_sequence,
     1,
   REPLACE( SUBSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), 0,DECODE(INSTR ( REPLACE(g.name, '\'||p_delimiter, '\ '),p_delimiter,1,1),0,LENGTH(g.name), INSTR ( REPLACE(g.name, '\'||p_delimiter, '\ '), p_delimiter, 1,1)-1)), '\ ', p_delimiter),
     p_max_sequence,
   REPLACE( SUBSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), INSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), p_delimiter, 1, (p_sequence-1))+1), '\ ', p_delimiter),
   REPLACE( SUBSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), (INSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), p_delimiter, 1, (p_sequence-1))+1),
	        ( INSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), p_delimiter, 1, p_sequence)
                -(INSTR( REPLACE(g.name, '\'||p_delimiter, '\ '), p_delimiter, 1, (p_sequence-1))+1))), '\ ', p_delimiter)
        ) meaning
FROM	per_grades_vl g
,	per_grade_definitions gd
WHERE	gd.id_flex_num = p_id_flex_num
AND	gd.grade_definition_id = g.grade_definition_id
AND	DECODE ( SUBSTR( p_type, 7 ),
	'SEGMENT1', gd.segment1,
	'SEGMENT2', gd.segment2,
	'SEGMENT3', gd.segment3,
	'SEGMENT4', gd.segment4,
	'SEGMENT5', gd.segment5,
	'SEGMENT6', gd.segment6,
	'SEGMENT7', gd.segment7,
	'SEGMENT8', gd.segment8,
	'SEGMENT9', gd.segment9,
	'SEGMENT10', gd.segment10,
	'SEGMENT11', gd.segment11,
	'SEGMENT12', gd.segment12,
	'SEGMENT13', gd.segment13,
	'SEGMENT14', gd.segment14,
	'SEGMENT15', gd.segment15,
	'SEGMENT16', gd.segment16,
	'SEGMENT17', gd.segment17,
	'SEGMENT18', gd.segment18,
	'SEGMENT19', gd.segment19,
	'SEGMENT20', gd.segment20,
	'SEGMENT21', gd.segment21,
	'SEGMENT22', gd.segment22,
	'SEGMENT23', gd.segment23,
	'SEGMENT24', gd.segment24,
	'SEGMENT25', gd.segment25,
	'SEGMENT26', gd.segment26,
	'SEGMENT27', gd.segment27,
	'SEGMENT28', gd.segment28,
	'SEGMENT29', gd.segment29,
	'SEGMENT30', gd.segment30, -1 ) = p_value;

BEGIN



IF ( SUBSTR( p_type,1,3) = 'SCL' )
THEN
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_scl_num_of_segs), 999);
end if;
	IF ( hxc_resource_rules_utils.g_scl_num_of_segs IS NULL )
	THEN
		OPEN  csr_get_scl_segs;
		FETCH csr_get_scl_segs
		INTO 	hxc_resource_rules_utils.g_scl_num_of_segs
		,	hxc_resource_rules_utils.g_scl_delimiter
		,	hxc_resource_rules_utils.g_scl_id_flex_num;
		CLOSE csr_get_scl_segs;

	END IF;
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_scl_num_of_segs), 999);
end if;

-- get sequence

l_sequence := hxc_resource_rules_utils.get_sequence ( p_type );

-- get value

if g_debug then
	hr_utility.set_location('gaz - params are  ', 999);
	hr_utility.set_location('gaz - p id_flex_num '||to_char(hxc_resource_rules_utils.g_scl_id_flex_num) , 999);
	hr_utility.set_location('gaz - p sequence '||to_char(l_Sequence) , 999);
	hr_utility.set_location('gaz - p max sequence '||to_char(hxc_resource_rules_utils.g_scl_num_of_segs) , 999);
	hr_utility.set_location('gaz - p delim '||hxc_resource_rules_utils.g_scl_delimiter , 999);
	hr_utility.set_location('gaz - p type '||p_type , 999);
	hr_utility.set_location('gaz - p value '||p_value , 999);
end if;

FOR scl IN csr_get_scl_meaning (
                           p_id_flex_num => hxc_resource_rules_utils.g_scl_id_flex_num
			,  p_sequence    => l_sequence
			,  p_max_sequence=> hxc_resource_rules_utils.g_scl_num_of_segs
			,  p_delimiter   => hxc_resource_rules_utils.g_scl_delimiter
			,  p_type        => p_type
			,  p_value       => p_value )
LOOP

	IF scl.meaning IS NOT NULL
	THEN
		l_meaning := scl.meaning;
		EXIT;
	END IF;

END LOOP;

ELSIF ( SUBSTR( p_type,1,6) = 'PEOPLE' )
THEN
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_people_num_of_segs), 999);
end if;
	IF ( hxc_resource_rules_utils.g_people_num_of_segs IS NULL )
	THEN
		OPEN  csr_get_people_segs;
		FETCH csr_get_people_segs
		INTO 	hxc_resource_rules_utils.g_people_num_of_segs
		,	hxc_resource_rules_utils.g_people_delimiter
		,	hxc_resource_rules_utils.g_people_id_flex_num;
		CLOSE csr_get_people_segs;

	END IF;
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_people_num_of_segs), 999);
end if;

-- get sequence

l_sequence := hxc_resource_rules_utils.get_sequence ( p_type, hxc_resource_rules_utils.g_people_id_flex_num );

-- get value

if g_debug then
	hr_utility.set_location('gaz - params are  ', 999);
	hr_utility.set_location('gaz - p id_flex_num '||to_char(hxc_resource_rules_utils.g_people_id_flex_num) , 999);
	hr_utility.set_location('gaz - l sequence '||to_char(l_Sequence) , 999);
	hr_utility.set_location('gaz - p max sequence '||to_char(hxc_resource_rules_utils.g_people_num_of_segs) , 999);
	hr_utility.set_location('gaz - p delim '||hxc_resource_rules_utils.g_people_delimiter , 999);
	hr_utility.set_location('gaz - p type '||p_type , 999);
	hr_utility.set_location('gaz - p value '||p_value , 999);
end if;

FOR people IN csr_get_people_meaning (
                           p_id_flex_num => hxc_resource_rules_utils.g_people_id_flex_num
			,  p_sequence    => l_sequence
			,  p_max_sequence=> hxc_resource_rules_utils.g_people_num_of_segs
			,  p_delimiter   => hxc_resource_rules_utils.g_people_delimiter
			,  p_type        => p_type
			,  p_value       => p_value )
LOOP

	IF people.meaning IS NOT NULL
	THEN
		l_meaning := people.meaning;
		EXIT;
	END IF;

END LOOP;

if g_debug then
	hr_utility.set_location('gaz - meaning is '||l_meaning, 999);
end if;

ELSIF ( SUBSTR( p_type,1,5) = 'GRADE' )
THEN
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_grade_num_of_segs), 999);
end if;
	IF ( hxc_resource_rules_utils.g_grade_num_of_segs IS NULL )
	THEN
		OPEN  csr_get_grade_segs;
		FETCH csr_get_grade_segs
		INTO 	hxc_resource_rules_utils.g_grade_num_of_segs
		,	hxc_resource_rules_utils.g_grade_delimiter
		,	hxc_resource_rules_utils.g_grade_id_flex_num;
		CLOSE csr_get_grade_segs;

	END IF;
if g_debug then
	hr_utility.set_location('gaz - num of segs is '||to_Char(hxc_resource_rules_utils.g_grade_num_of_segs), 999);
end if;

-- get sequence

l_sequence := hxc_resource_rules_utils.get_sequence ( p_type, hxc_resource_rules_utils.g_grade_id_flex_num );

-- get value

if g_debug then
	hr_utility.set_location('gaz - params are  ', 999);
	hr_utility.set_location('gaz - p id_flex_num '||to_char(hxc_resource_rules_utils.g_grade_id_flex_num) , 999);
	hr_utility.set_location('gaz - l sequence '||to_char(l_Sequence) , 999);
	hr_utility.set_location('gaz - p max sequence '||to_char(hxc_resource_rules_utils.g_grade_num_of_segs) , 999);
	hr_utility.set_location('gaz - p delim '||hxc_resource_rules_utils.g_grade_delimiter , 999);
	hr_utility.set_location('gaz - p type '||p_type , 999);
	hr_utility.set_location('gaz - p value '||p_value , 999);
end if;

FOR grade IN csr_get_grade_meaning (
			   p_id_flex_num => hxc_resource_rules_utils.g_grade_id_flex_num
			,  p_sequence    => l_sequence
			,  p_max_sequence=> hxc_resource_rules_utils.g_grade_num_of_segs
			,  p_delimiter   => hxc_resource_rules_utils.g_grade_delimiter
			,  p_type        => p_type
			,  p_value       => p_value )
LOOP

	IF grade.meaning is not null
	THEN
		l_meaning := grade.meaning;
	if g_debug then
		hr_utility.set_location('gaz - meaning is '||l_meaning, 999);
	end if;
		exit;
	END IF;

END LOOP;

END IF;

RETURN l_meaning;

END get_meaning;

FUNCTION get_criteria_meaning ( p_type varchar2
			,	p_business_group_id number ) RETURN VARCHAR2 IS

l_meaning varchar2(240);

-- ***** Start commented code for bug 2669059 **************

-- CURSOR csr_get_people_tl IS
-- SELECT
-- 	tl.form_left_prompt meaning
-- FROM
-- 	fnd_id_flex_segments_tl tl
-- ,	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'People Group Flexfield'
-- AND
-- 	s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num = seg.id_flex_num
-- AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.id_flex_num = (
-- 	SELECT	DISTINCT z.id_flex_num
-- 	FROM	per_all_assignments_f asg
-- 	,	pay_people_groups z
-- 	WHERE	asg.people_group_id   = z.people_group_id
-- 	AND	asg.business_group_id = p_business_group_id ) AND
-- 	seg.display_flag = 'Y'
-- AND
-- 	seg.application_column_name = SUBSTR(p_type, 8)
-- AND
-- 	tl.application_id	= seg.application_id AND
-- 	tl.id_flex_num		= seg.id_flex_num    AND
-- 	tl.id_flex_code		= seg.id_flex_code   AND
-- 	tl.application_column_name = seg.application_column_name;
-- ***** End commented code for bug 2669059 **************

-- ***** Start new code for bug 2669059 **************


CURSOR csr_get_people_tl IS
  SELECT
  	tl.form_left_prompt meaning
  FROM
  	fnd_id_flex_segments_tl tl
  ,	fnd_id_flex_segments seg
  ,	fnd_id_flex_structures s
  ,	fnd_id_Flexs fl
  WHERE
-- ***** Start commented code for bug 2678547 **************
--  	fl.id_flex_name		= 'People Group Flexfield'   and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
  	fl.id_flex_code = 'GRP' and
-- ***** End new code for bug 2678547 **************

	fl.application_id 	= 801   AND
  	s.id_flex_code 		= fl.id_flex_code AND
   	s.application_id  	= fl.application_id and
  	s.id_flex_num 		= seg.id_flex_num AND
  	seg.id_flex_code	= fl.id_flex_code AND
	seg.application_id 	= fl.application_id AND
	seg.id_flex_num 	=
	(
--***** start new code for Bug 5089488**************
	select 	hoi.ORG_INFORMATION5
	from   hr_organization_units hou,
       	   hr_organization_information hoi,
       	   hr_organization_information hoi2
	where  hou.business_group_id = p_business_group_id
	and    hou.organization_id = hoi.organization_id
	and    hoi.organization_id = hoi2.organization_id
	and    hoi.org_information_context = 'Business Group Information'
	and    sysdate between hou.Date_from and nvl(hou.date_to,sysdate)
	and    hoi2.org_information1='HR_BG' and hoi2.org_information2='Y'
--***** end new code for Bug 5089488**************
    	)
  and
  seg.display_flag 		= 'Y' and
  seg.application_column_name 	= SUBSTR(p_type, 8) and
  tl.application_id		= seg.application_id and
  tl.id_flex_num		= seg.id_flex_num    and
  tl.id_flex_code		= seg.id_flex_code   and
  tl.language                   = USERENV('LANG')    and
  tl.application_column_name 	= seg.application_column_name;

-- ***** End new code for bug 2669059 **************


-- ***** Start commented code for bug 2669059 **************

-- CURSOR  csr_get_grade_tl IS
-- SELECT
-- 	tl.form_left_prompt meaning
-- FROM
-- 	fnd_id_flex_segments_tl tl
-- ,	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- WHERE
-- 	fl.id_flex_name	= 'Grade Flexfield'
-- AND
-- s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num = seg.id_flex_num
-- AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.id_flex_num = (
-- 	SELECT	DISTINCT z.id_flex_num
-- 	FROM	per_grade_definitions z
-- 	,	per_grades y
-- 	WHERE	y.business_group_id	= p_business_group_id
-- 	AND	y.grade_definition_id	= z.grade_definition_id ) AND
-- 	seg.display_flag = 'Y'
-- AND
-- 	seg.application_column_name = SUBSTR(p_type, 7)
-- AND
-- 	tl.application_id	= seg.application_id AND
-- 	tl.id_flex_num		= seg.id_flex_num    AND
-- 	tl.id_flex_code		= seg.id_flex_code   AND
-- 	tl.application_column_name = seg.application_column_name;

-- ***** End commented code for bug 2669059 **************


-- ***** Start new code for bug 2669059 **************


	CURSOR  csr_get_grade_tl IS
	select
		tl.form_left_prompt meaning
	from
		fnd_id_flex_segments_tl tl
	,	fnd_id_flex_segments seg
	,	fnd_id_flex_structures s
	,	fnd_id_Flexs fl
	where
-- ***** Start commented code for bug 2678547 **************
--		fl.id_flex_name		= 'Grade Flexfield' and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
		fl.id_flex_code = 'GRD' and
-- ***** End new code for bug 2678547 **************

		fl.application_id 	= 800 and
		s.id_flex_code 		= fl.id_flex_code and
	        s.application_id  	= fl.application_id and
		s.id_flex_num 		= seg.id_flex_num and
		seg.id_flex_code 	= fl.id_flex_code and
		seg.application_id 	= fl.application_id and
		seg.id_flex_num =
		(
--***** start new code for Bug 5089488**************
			select 	hoi.ORG_INFORMATION4
			from   hr_organization_units hou,
		       	   hr_organization_information hoi,
		       	   hr_organization_information hoi2
			where  hou.business_group_id = p_business_group_id
			and    hou.organization_id = hoi.organization_id
			and    hoi.organization_id = hoi2.organization_id
			and    hoi.org_information_context = 'Business Group Information'
			and    sysdate between hou.Date_from and nvl(hou.date_to,sysdate)
			and    hoi2.org_information1='HR_BG' and hoi2.org_information2='Y'
--***** end new code for Bug 5089488**************
	    ) 	and
		seg.display_flag = 'Y' and
		seg.application_column_name = SUBSTR(p_type, 7) and
		tl.application_id	= seg.application_id and
		tl.id_flex_num		= seg.id_flex_num    and
		tl.id_flex_code		= seg.id_flex_code   and
                tl.language             = USERENV('LANG')    and
		tl.application_column_name = seg.application_column_name;

-- ***** End new code for bug 2669059 **************

-- ***** Start commented code for bug 2669059 **************


-- CURSOR	csr_get_scl_tl IS
-- SELECT	tl.form_left_prompt meaning
-- FROM
-- fnd_id_flex_segments_tl tl
-- ,	fnd_id_flex_segments seg
-- ,	fnd_id_flex_structures s
-- ,	fnd_id_Flexs fl
-- ,	pay_legislation_rules lr
-- WHERE
-- lr.legislation_code = 'US' AND
-- 	lr.rule_type        = 'S'
-- AND
-- 	fl.id_flex_name	= 'Soft Coded KeyFlexfield'
-- AND
-- 	s.id_flex_code = fl.id_flex_code AND
-- 	s.id_flex_num = seg.id_flex_num
-- AND
-- 	seg.id_flex_code= fl.id_flex_code AND
-- 	seg.id_flex_num = lr.rule_mode    AND
-- 	seg.display_flag = 'Y'
-- AND
-- 	seg.application_column_name = SUBSTR(p_type,5)
-- AND
-- 	tl.application_id	= seg.application_id AND
-- 	tl.id_flex_num		= seg.id_flex_num    AND
-- 	tl.id_flex_code		= seg.id_flex_code   AND
-- 	tl.application_column_name = seg.application_column_name;
-- ***** End commented code for bug 2669059 **************

-- ***** Start new code for bug 2669059 **************

CURSOR	csr_get_scl_tl IS
select	tl.form_left_prompt meaning
from
	fnd_id_flex_segments_tl tl
,	fnd_id_flex_segments seg
,	fnd_id_flex_structures s
,	fnd_id_Flexs fl
,	pay_legislation_rules lr
where
	lr.legislation_code = 'US' and
	lr.rule_type        = 'S' and

-- ***** Start commented code for bug 2678547 **************
--	fl.id_flex_name		= 'Soft Coded KeyFlexfield' and
-- ***** End commented code for bug 2678547 **************

-- ***** Start new code for bug 2678547 **************
	fl.id_flex_code = 'SCL' and
-- ***** End new code for bug 2678547 **************

	fl.application_id 	= 800 and
	s.id_flex_code 	  	= fl.id_flex_code and
	s.application_id	= fl.application_id and
	s.id_flex_num 		= seg.id_flex_num and
	seg.id_flex_code	= fl.id_flex_code and
	seg.application_id 	= fl.application_id  and
	seg.id_flex_num 	= lr.rule_mode    and
	seg.display_flag 	= 'Y' and
	seg.application_column_name = SUBSTR(p_type,5) and
	tl.application_id	= seg.application_id and
	tl.id_flex_num		= seg.id_flex_num    and
	tl.id_flex_code		= seg.id_flex_code   and
        tl.language             = USERENV('LANG')    and
	tl.application_column_name = seg.application_column_name;

-- ***** End new code for bug 2669059 **************


BEGIN

IF ( SUBSTR( p_type,1,6 ) = 'PEOPLE' )
THEN

OPEN  csr_get_people_tl;
FETCH csr_get_people_tl INTO l_meaning;
CLOSE csr_get_people_tl;

ELSIF ( SUBSTR( p_type,1,3 ) = 'SCL' )
THEN

OPEN  csr_get_scl_tl;
FETCH csr_get_scl_tl INTO l_meaning;
CLOSE csr_get_scl_tl;

ELSIF ( SUBSTR( p_type,1,5 ) = 'GRADE' )
THEN

OPEN  csr_get_grade_tl;
FETCH csr_get_grade_tl INTO l_meaning;
CLOSE csr_get_grade_tl;

END IF;

RETURN l_meaning;


END get_criteria_meaning;

FUNCTION check_flex(  p_flex_id in number
					, p_segment in	VARCHAR2
					, p_value in	VARCHAR2
					, p_type in varchar2
					, p_flex_tab IN OUT NOCOPY t_flex_valid) RETURN NUMBER
IS
cursor get_scl_segment_value IS
select SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8,SEGMENT9,SEGMENT10,
	  SEGMENT11,SEGMENT12,SEGMENT13,SEGMENT14,SEGMENT15,SEGMENT16,SEGMENT17,SEGMENT18,SEGMENT19,SEGMENT20,
	  SEGMENT21,SEGMENT22,SEGMENT23,SEGMENT24,SEGMENT25,SEGMENT26,SEGMENT27,SEGMENT28,SEGMENT29,SEGMENT30
FROM hr_soft_coding_keyflex scl
WHERE scl.soft_coding_keyflex_id = p_flex_id;


cursor get_people_segment_value IS
select SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8,SEGMENT9,SEGMENT10,
	  SEGMENT11,SEGMENT12,SEGMENT13,SEGMENT14,SEGMENT15,SEGMENT16,SEGMENT17,SEGMENT18,SEGMENT19,SEGMENT20,
	  SEGMENT21,SEGMENT22,SEGMENT23,SEGMENT24,SEGMENT25,SEGMENT26,SEGMENT27,SEGMENT28,SEGMENT29,SEGMENT30
FROM pay_people_groups grp
WHERE grp.people_group_id = p_flex_id;

cursor get_grade_segment_value IS
select gd.SEGMENT1,gd.SEGMENT2,gd.SEGMENT3,gd.SEGMENT4,gd.SEGMENT5,gd.SEGMENT6,gd.SEGMENT7,gd.SEGMENT8,gd.SEGMENT9,gd.SEGMENT10,
	  gd.SEGMENT11,gd.SEGMENT12,gd.SEGMENT13,gd.SEGMENT14,gd.SEGMENT15,gd.SEGMENT16,gd.SEGMENT17,gd.SEGMENT18,gd.SEGMENT19,gd.SEGMENT20,
	  gd.SEGMENT21,gd.SEGMENT22,gd.SEGMENT23,gd.SEGMENT24,gd.SEGMENT25,gd.SEGMENT26,gd.SEGMENT27,gd.SEGMENT28,gd.SEGMENT29,gd.SEGMENT30
FROM per_grades g,per_grade_definitions gd
WHERE g.grade_id = p_flex_id
AND gd.grade_definition_id = g.grade_definition_id;


BEGIN


   if (not p_flex_tab.exists(p_flex_id))
   then
	      --segment does not exist in the cache. let us get it

	      if p_type = 'SCL' then

			  OPEN get_scl_segment_value;
			  FETCH get_scl_segment_value into p_flex_tab(p_flex_id);
			  CLOSE get_scl_segment_value;

		  elsif p_type = 'PEOPLE' then

			  OPEN get_people_segment_value;
			  FETCH get_people_segment_value into p_flex_tab(p_flex_id);
			  CLOSE get_people_segment_value;

		  elsif p_type = 'GRADE' then

			  OPEN get_grade_segment_value;
			  FETCH get_grade_segment_value into p_flex_tab(p_flex_id);
			  CLOSE get_grade_segment_value;

		  end if;

	end if;


	if (p_flex_tab.exists(p_flex_id))
	then

	      if (p_segment = 'SEGMENT1' and p_value = p_flex_tab(p_flex_id).segment1) then
	            return 1;
	   elsif (p_segment = 'SEGMENT2' and p_value = p_flex_tab(p_flex_id).segment2) then
	            return 1;
	   elsif (p_segment = 'SEGMENT3' and p_value = p_flex_tab(p_flex_id).segment3) then
	            return 1;
	   elsif (p_segment = 'SEGMENT4' and p_value = p_flex_tab(p_flex_id).segment4) then
	            return 1;
	   elsif (p_segment = 'SEGMENT5' and p_value = p_flex_tab(p_flex_id).segment5) then
	            return 1;
	   elsif (p_segment = 'SEGMENT6' and p_value = p_flex_tab(p_flex_id).segment6) then
	            return 1;
	   elsif (p_segment = 'SEGMENT7' and p_value = p_flex_tab(p_flex_id).segment7) then
	            return 1;
	   elsif (p_segment = 'SEGMENT8' and p_value = p_flex_tab(p_flex_id).segment8) then
	            return 1;
	   elsif (p_segment = 'SEGMENT9' and p_value = p_flex_tab(p_flex_id).segment9) then
	            return 1;
	   elsif (p_segment = 'SEGMENT10' and p_value = p_flex_tab(p_flex_id).segment10) then
	            return 1;
	   elsif (p_segment = 'SEGMENT11' and p_value = p_flex_tab(p_flex_id).segment11) then
	            return 1;
	   elsif (p_segment = 'SEGMENT12' and p_value = p_flex_tab(p_flex_id).segment12) then
	            return 1;
	   elsif (p_segment = 'SEGMENT13' and p_value = p_flex_tab(p_flex_id).segment13) then
	            return 1;
	   elsif (p_segment = 'SEGMENT14' and p_value = p_flex_tab(p_flex_id).segment14) then
	            return 1;
	   elsif (p_segment = 'SEGMENT15' and p_value = p_flex_tab(p_flex_id).segment15) then
	            return 1;
	   elsif (p_segment = 'SEGMENT16' and p_value = p_flex_tab(p_flex_id).segment16) then
	            return 1;
	   elsif (p_segment = 'SEGMENT17' and p_value = p_flex_tab(p_flex_id).segment17) then
	            return 1;
	   elsif (p_segment = 'SEGMENT18' and p_value = p_flex_tab(p_flex_id).segment18) then
	            return 1;
	   elsif (p_segment = 'SEGMENT19' and p_value = p_flex_tab(p_flex_id).segment19) then
	            return 1;
	   elsif (p_segment = 'SEGMENT20' and p_value = p_flex_tab(p_flex_id).segment20) then
	            return 1;
	   elsif (p_segment = 'SEGMENT21' and p_value = p_flex_tab(p_flex_id).segment21) then
	            return 1;
	   elsif (p_segment = 'SEGMENT22' and p_value = p_flex_tab(p_flex_id).segment22) then
	            return 1;
	   elsif (p_segment = 'SEGMENT23' and p_value = p_flex_tab(p_flex_id).segment23) then
	            return 1;
	   elsif (p_segment = 'SEGMENT24' and p_value = p_flex_tab(p_flex_id).segment24) then
	            return 1;
	   elsif (p_segment = 'SEGMENT25' and p_value = p_flex_tab(p_flex_id).segment25) then
	            return 1;
	   elsif (p_segment = 'SEGMENT26' and p_value = p_flex_tab(p_flex_id).segment26) then
	            return 1;
	   elsif (p_segment = 'SEGMENT27' and p_value = p_flex_tab(p_flex_id).segment27) then
	            return 1;
	   elsif (p_segment = 'SEGMENT28' and p_value = p_flex_tab(p_flex_id).segment28) then
	            return 1;
	   elsif (p_segment = 'SEGMENT29' and p_value = p_flex_tab(p_flex_id).segment29) then
	            return 1;
	   elsif (p_segment = 'SEGMENT30' and p_value = p_flex_tab(p_flex_id).segment30) then
	            return 1;
       else
                return 0;
	   end if;
	 end if;
  return 0;

END check_flex;



FUNCTION chk_flex_valid ( p_type	VARCHAR2
		,	 p_flex_id	NUMBER
		,	 p_segment	VARCHAR2
		,	 p_value	VARCHAR2 ) RETURN NUMBER IS

BEGIN

if (p_type = 'SCL') then
	return check_flex(p_flex_id,p_segment,p_value,p_type,g_flex_valid_scl_ct);
elsif (p_type = 'PEOPLE') then
	return check_flex(p_flex_id,p_segment,p_value,p_type,g_flex_valid_people_ct);
elsif (p_type = 'GRADE') then
	return check_flex(p_flex_id,p_segment,p_value,p_type,g_flex_valid_grade_ct);
end if;
END chk_flex_valid;

-- Bug 3322725
FUNCTION chk_criteria_exists ( p_eligibility_criteria_type VARCHAR2,
			       p_eligibility_criteria_id VARCHAR2) RETURN BOOLEAN IS

l_criteria_exists number;

CURSOR c_chk_resource_rules( p_eligibility_criteria_type varchar,
		             p_eligibility_criteria_id varchar) IS
   SELECT '1' FROM hxc_resource_rules
   WHERE eligibility_criteria_type = p_eligibility_criteria_type
     and eligibility_criteria_id = p_eligibility_criteria_id;

BEGIN
Open c_chk_resource_rules(p_eligibility_criteria_type,p_eligibility_criteria_id);
Fetch c_chk_resource_rules into l_criteria_exists;
	If c_chk_resource_rules%FOUND then
		Close c_chk_resource_rules;
		return(TRUE);
	else
		Close c_chk_resource_rules;
		return(FALSE);
	end if;
END chk_criteria_exists;

END hxc_resource_rules_utils;

/
