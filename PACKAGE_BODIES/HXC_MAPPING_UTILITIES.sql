--------------------------------------------------------
--  DDL for Package Body HXC_MAPPING_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MAPPING_UTILITIES" as
/* $Header: hxcmputl.pkb 120.7.12010000.3 2008/08/07 12:59:05 asrajago ship $ */

g_debug boolean := hr_utility.debug_enabled;

CURSOR	csr_get_timecard ( p_timecard_bb_id NUMBER
			,  p_timecard_ovn   NUMBER
			,  p_start_date     DATE
			,  p_end_date       DATE ) IS
SELECT
	bb.time_building_block_id bb_id
,	bb.object_Version_number bb_ovn
,	bb.scope
,	bb.type
,	bb.start_time
,	bb.stop_time
,	bb.measure
,	bb.date_to
,       bb.comment_text
FROM
	hxc_time_building_blocks bb
WHERE
	bb.object_version_number = (
	SELECT	MAX(bb1.object_version_number)
	FROM	hxc_time_building_blocks bb1
	WHERE	bb1.time_building_block_id = bb.time_building_block_id )
AND
((
p_start_date BETWEEN
DECODE ( bb.type, 'RANGE', bb.start_time,
	( hxc_mapping_utilities.get_day_date
        ( 'START', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) )
AND
DECODE ( bb.type, 'RANGE', bb.stop_time,
	( hxc_mapping_utilities.get_day_date
	( 'STOP', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) )
OR
p_end_date BETWEEN
DECODE ( bb.type, 'RANGE', bb.start_time,
	( hxc_mapping_utilities.get_day_date
        ( 'START', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) )
AND
DECODE ( bb.type, 'RANGE', bb.stop_time,
	( hxc_mapping_utilities.get_day_date
	( 'STOP', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) ) )
OR (
DECODE ( bb.type, 'RANGE', bb.start_time,
	( hxc_mapping_utilities.get_day_date
        ( 'START', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) )
BETWEEN p_start_date AND p_end_date
OR
DECODE ( bb.type, 'RANGE', bb.stop_time,
	( hxc_mapping_utilities.get_day_date
	( 'STOP', bb.parent_building_block_id, bb.parent_building_block_ovn ) ) )
BETWEEN p_start_date AND p_end_date ))
START WITH bb.time_building_block_id = p_timecard_bb_id
AND	   bb.object_version_number  = p_timecard_ovn
CONNECT BY PRIOR bb.time_building_block_id = bb.parent_building_block_id
AND        PRIOR bb.object_version_number  = bb.parent_building_block_ovn;

-- ****************************************
-- Declare mapping changed local functions
-- ****************************************

FUNCTION get_field_mappings (
	p_mapping_id	hxc_mappings.mapping_id%TYPE )
RETURN hxc_generic_retrieval_pkg.t_field_mappings
IS
--
l_mapping_record hxc_generic_retrieval_pkg.r_field_mappings;
l_mappings_table hxc_generic_retrieval_pkg.t_field_mappings;
--
CURSOR csr_get_mappings IS
SELECT
	mpc.bld_blk_info_type_id
,	UPPER(mpc.field_name)
,	mpc.segment
,	bbit.bld_blk_info_type context
,	bbitu.building_block_category category
FROM
	hxc_bld_blk_info_type_usages bbitu
,	hxc_bld_blk_info_types bbit
,	hxc_mapping_components mpc
,	hxc_mapping_comp_usages mcu
,	hxc_mappings map
WHERE	map.mapping_id		= p_mapping_id
AND
	mcu.mapping_id		= map.mapping_id
AND
	mpc.mapping_component_id= mcu.mapping_component_id
AND
	bbit.bld_blk_info_type_id	= mpc.bld_blk_info_type_id
AND
	bbitu.bld_blk_info_type_id	= bbit.bld_blk_info_type_id
ORDER BY 1;


  l_table_index NUMBER := 0;

  l_proc	VARCHAR2(72);


BEGIN -- get field mappings
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.get_field_mappings';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

	OPEN csr_get_mappings;
	FETCH csr_get_mappings INTO l_mapping_record;
	IF csr_get_mappings%NOTFOUND
	THEN
		fnd_message.set_name('HXC', 'HXC_0016_GNRET_NO_MAPPINGS');
		fnd_message.raise_error;
		CLOSE csr_get_mappings;
	END IF;

	LOOP

--if g_debug then
	-- hr_utility.set_location('Processing '||l_proc, 20);
--end if;

		l_table_index := l_table_index + 1;
		l_mappings_table ( l_table_index ) := l_mapping_record;

		FETCH csr_get_mappings INTO l_mapping_record;

		EXIT WHEN csr_get_mappings%NOTFOUND;

	END LOOP;

	CLOSE csr_get_mappings;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 30);
end if;

RETURN l_mappings_table;

END get_field_mappings;


FUNCTION get_day_date ( p_type VARCHAR2, p_bb_id NUMBER, p_bb_ovn NUMBER ) RETURN DATE IS

CURSOR  csr_get_start IS
SELECT	start_time
FROM	hxc_time_building_blocks bb
WHERE	bb.time_building_block_id = p_bb_id
AND	bb.object_version_number  = p_bb_ovn;

CURSOR  csr_get_stop IS
SELECT	stop_time
FROM	hxc_time_building_blocks bb
WHERE	bb.time_building_block_id = p_bb_id
AND	bb.object_version_number  = p_bb_ovn;

l_date DATE;

BEGIN

IF ( p_type = 'START' )
THEN

OPEN  csr_get_start;
FETCH csr_get_start INTO l_date;
CLOSE csr_get_start;

ELSE

OPEN  csr_get_stop;
FETCH csr_get_stop INTO l_date;
CLOSE csr_get_stop;

END IF;

RETURN l_date;

END get_day_date;

-- private function
--    compare_attributes
-- description
--    function which returns TRUE if any attribute has changed between
--    the old and new tables of attributes


FUNCTION compare_attributes ( p_new_attributes_table	hxc_self_service_time_deposit.building_block_attribute_info
		,	      p_old_attributes_table 	hxc_self_service_time_deposit.building_block_attribute_info
		,	      p_mappings_tab            hxc_generic_retrieval_pkg.t_field_mappings )
RETURN BOOLEAN IS

l_changed	      BOOLEAN := FALSE;
l_attribute_row_found BOOLEAN := FALSE;

l_old_index BINARY_INTEGER;
l_new_index BINARY_INTEGER;

l_proc	VARCHAR2(72);

-- private function
--   in_mapping
-- description
--   retruns true if the attribute is in the mapping

FUNCTION in_mapping ( p_bld_blk_info_type_id NUMBER
		,     p_mappings_tab         hxc_generic_retrieval_pkg.t_field_mappings
		,     p_attribute            VARCHAR2 )
RETURN BOOLEAN IS

l_return BOOLEAN := FALSE;

BEGIN

FOR map IN p_mappings_tab.FIRST .. p_mappings_tab.LAST
LOOP

IF ( p_mappings_tab(map).bld_blk_info_type_id = p_bld_blk_info_type_id )
THEN
	IF ( p_mappings_tab(map).attribute = p_attribute )
	THEN
		l_return := TRUE;
		EXIT;
	END IF;
END IF;

END LOOP;

RETURN l_return;

END in_mapping;

BEGIN -- compare_attributes


if g_debug then
	l_proc := g_package||'.compare_attributes';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

IF ( p_old_attributes_table.COUNT = 0 AND p_new_attributes_table.COUNT = 0 )
THEN

	l_changed := FALSE;

ELSIF ( p_old_attributes_table.COUNT = 0 )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 20);
		hr_utility.trace('No old attributes');
	end if;

	-- there were no prior time attributes to compare against
	-- then for all intents and purposes the mapping has changed.

	l_changed := TRUE;

ELSIF ( p_new_attributes_table.COUNT = 0 )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 25);
		hr_utility.trace('No new attributes');
	end if;

	l_changed := TRUE;

ELSE

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- count the number of new and old bld blks.
-- if these numbers are different then changed

IF ( p_new_attributes_table.COUNT <> p_old_attributes_table.COUNT )
THEN

if g_debug then
	hr_utility.trace('*******************************');
	hr_utility.trace('number of info types different ');
	hr_utility.trace('*******************************');
end if;

	l_changed := TRUE;

ELSE
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

-- check to see if even though we have the same number that there are
-- no new bld blk info types or that any have been removed.

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- check to see if any new new

l_new_index := p_new_attributes_table.FIRST;

WHILE ( l_new_index IS NOT NULL AND NOT l_changed )
LOOP

	IF NOT ( p_old_attributes_table.EXISTS(l_new_index) )
	THEN
		l_changed := TRUE;
	END IF;

l_new_index := p_new_attributes_table.NEXT(l_new_index);

END LOOP;

-- check to see if any new old

l_old_index := p_old_attributes_table.FIRST;

WHILE ( l_old_index IS NOT NULL AND NOT l_changed )
LOOP

	IF NOT ( p_new_attributes_table.EXISTS(l_old_index) )
	THEN
		l_changed := TRUE;
	END IF;

l_old_index := p_old_attributes_table.NEXT(l_old_index);

END LOOP;

END IF; --( p_new_attributes_table.COUNT <> p_old_attributes_table.COUNT )

IF ( NOT l_changed )
THEN

-- compare the attributes directly

l_new_index := p_new_attributes_table.FIRST;

WHILE ( l_new_index IS NOT NULL )
LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

			IF ( ( NVL( p_old_attributes_table(l_new_index).attribute1 , 'zZz' )
			    <> NVL( p_new_attributes_table(l_new_index).attribute1 , 'zZz' ) )
			  AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE1' ) ) )
			THEN
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 80);
				end if;

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute2 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute2 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE2' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute3 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute3 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE3' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute4 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute4 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE4' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute5 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute5 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE5' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute6 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute6 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE6' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute7 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute7 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE7' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute8 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute8 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE8' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute9 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute9 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE9' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute10 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute10 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE10' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute11 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute11 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE11' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute12 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute12 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE12' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute13 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute13 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE13' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute14 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute14 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE14' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute15 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute15 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE15' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute16 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute16 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE16' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute17 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute17 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE17' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute18 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute18 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE18' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute19 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute19, 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE19' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute20 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute20 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE20' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute21 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute21 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE21' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute22 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute22 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE22' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute23 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute23 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE23' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute24 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute24 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE24' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute25 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute25 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE25' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute26 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute26 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE26' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute27 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute27 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE27' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute28 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute28 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE28' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute29 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute29 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE29' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute30 , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute30 , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE30' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;


			-- GPM - v115.13

			ELSIF ( ( NVL( p_old_attributes_table(l_new_index).attribute_category , 'zZz' )
			       <> NVL( p_new_attributes_table(l_new_index).attribute_category , 'zZz' ) )
			    AND ( in_mapping ( l_new_index, p_mappings_tab, 'ATTRIBUTE_CATEGORY' ) ) )
			THEN

				l_changed := TRUE;
				EXIT;

			END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 90);
		end if;


IF l_changed
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 140);
	end if;

	EXIT;
END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 160);
end if;

l_new_index := p_new_attributes_table.NEXT(l_new_index);

END LOOP; -- p_new_atts

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 170);
end if;

END IF;

END IF; -- if l changed

RETURN l_changed;

END compare_attributes;

-- public function
--   chk_mapping_changed
-- description
--   see package specification

FUNCTION chk_mapping_changed ( 	p_mapping_id	NUMBER
			,	p_timecard_bb_id NUMBER
			,	p_timecard_ovn	 NUMBER
			,	p_start_date	DATE
			,	p_end_date	DATE
			,	p_last_status   VARCHAR2
			,	p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
			,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
                        ,       p_called_from   VARCHAR2 default 'APPROVALS' )
RETURN BOOLEAN IS

-- ***************************************
-- Declare mapping changed local variables
-- ***************************************

l_proc	VARCHAR2(72);

t_mapping hxc_generic_retrieval_pkg.t_field_mappings;

r_new_atts		hxc_self_service_time_deposit.attribute_info;
r_old_atts		hxc_self_service_time_deposit.attribute_info;

t_old_attributes	hxc_self_service_time_deposit.building_block_attribute_info;
t_new_attributes	hxc_self_service_time_deposit.building_block_attribute_info;

l_parsed_attributes	hxc_self_service_time_deposit.building_block_attribute_info;

l_mapping_changed BOOLEAN := FALSE;
l_no_such_bb_id   BOOLEAN := TRUE;
l_all_first_ovn   BOOLEAN := TRUE;

l_decision varchar2(10) := 'TEST';
l_bld_blk_info_tab t_bld_blk_info;

l_old_index BINARY_INTEGER :=1;
l_new_index BINARY_INTEGER :=1;
l_del_index BINARY_INTEGER;
l_index
BINARY_INTEGER;

-- ***************************************
-- Declare mapping changed local cursors
-- ***************************************

CURSOR csr_get_attributes ( p_bb_id NUMBER, p_bb_ovn NUMBER ) IS
SELECT
	ta.time_attribute_id
,	bb.time_building_block_id
,       bbit.bld_blk_info_type
,	ta.attribute_category
,	ta.attribute1
,	ta.attribute2
,	ta.attribute3
,	ta.attribute4
,	ta.attribute5
,	ta.attribute6
,	ta.attribute7
,	ta.attribute8
,	ta.attribute9
,	ta.attribute10
,	ta.attribute11
,	ta.attribute12
,	ta.attribute13
,	ta.attribute14
,	ta.attribute15
,	ta.attribute16
,	ta.attribute17
,	ta.attribute18
,	ta.attribute19
,	ta.attribute20
,	ta.attribute21
,	ta.attribute22
,	ta.attribute23
,	ta.attribute24
,	ta.attribute25
,	ta.attribute26
,	ta.attribute27
,	ta.attribute28
,	ta.attribute29
,	ta.attribute30
,	ta.bld_blk_info_type_id
,	ta.object_version_number
,	'X' dummy1
,	'X' dummy2
,       'X' process
FROM
	hxc_time_building_blocks bb
,	hxc_time_attributes ta
,	hxc_time_attribute_usages tau
,       hxc_bld_blk_info_types bbit
WHERE
	bb.time_building_block_id	= p_bb_id AND
	bb.object_version_number	= p_bb_ovn
AND
	tau.time_building_block_id(+)   = bb.time_building_block_id AND
	tau.time_building_block_ovn(+)  = bb.object_version_number
AND
	ta.time_attribute_id(+)	    = tau.time_attribute_id AND
	ta.object_version_number(+) = 1 -- gaz
AND
        bbit.bld_blk_info_type_id = ta.bld_blk_info_type_id
ORDER BY
	ta.bld_blk_info_type_id;

-- *********************************************************
-- private function
--   get_old_atts
--
-- description
--   gets all the attributes for a prior time building block
--   with a given status
--   returns a table of attributes - if no attributes then the
--   table is empty

FUNCTION get_old_atts (	p_bb_id	 NUMBER
		,	p_bb_ovn NUMBER
		,	p_status VARCHAR2
		,	p_bld_blk_info_tab t_bld_blk_info )
RETURN hxc_self_service_time_deposit.building_block_attribute_info IS

l_proc		VARCHAR2(72);

l_decr_ovn	hxc_time_building_blocks.object_version_number%TYPE := 0;
l_attributes_exist BOOLEAN := TRUE;
l_old           BINARY_INTEGER := 1;
r_old_atts	hxc_self_service_time_deposit.attribute_info;
t_old_atts	hxc_self_service_time_deposit.building_block_attribute_info;


CURSOR	csr_get_old_atts ( p_decr_ovn NUMBER ) IS
SELECT
	ta.time_attribute_id
,	bb.time_building_block_id
,       bbit.bld_blk_info_type
,	ta.attribute_category
,	ta.attribute1
,	ta.attribute2
,	ta.attribute3
,	ta.attribute4
,	ta.attribute5
,	ta.attribute6
,	ta.attribute7
,	ta.attribute8
,	ta.attribute9
,	ta.attribute10
,	ta.attribute11
,	ta.attribute12
,	ta.attribute13
,	ta.attribute14
,	ta.attribute15
,	ta.attribute16
,	ta.attribute17
,	ta.attribute18
,	ta.attribute19
,	ta.attribute20
,	ta.attribute21
,	ta.attribute22
,	ta.attribute23
,	ta.attribute24
,	ta.attribute25
,	ta.attribute26
,	ta.attribute27
,	ta.attribute28
,	ta.attribute29
,	ta.attribute30
,	ta.bld_blk_info_type_id
,	ta.object_version_number
,	'X'
,	'X'
,       'X'
FROM
	hxc_time_attributes ta
,	hxc_time_attribute_usages tau
,	hxc_time_building_blocks bb
,       hxc_bld_blk_info_types bbit
WHERE
	bb.time_building_block_id	= p_bb_id AND
	bb.object_version_number	= p_decr_ovn AND
	bb.approval_status		= p_status
AND
	tau.time_building_block_id(+)   = bb.time_building_block_id AND
	tau.time_building_block_ovn(+)  = bb.object_Version_number
AND
	ta.time_attribute_id(+)		= tau.time_attribute_id AND
	ta.object_version_number(+)     = 1 -- gaz
AND
        bbit.bld_blk_info_type_id = ta.bld_blk_info_type_id
ORDER BY
	ta.bld_blk_info_type_id;

BEGIN -- get_old_atts



if g_debug then
	l_proc := g_package||'.get_old_attributes';
	hr_utility.trace('************* In get old atts  ***************');
	hr_utility.trace('bb id is '||to_char(p_bb_id));
	hr_utility.trace('bb ovn is '||to_char(p_bb_ovn));

	hr_utility.set_location('Processing '||l_proc, 10);
end if;

-- remember that the smallest p_bb_ovn is going to be 2
-- otherwise this function is never called.

l_decr_ovn := p_bb_ovn;

l_decr_ovn := l_decr_ovn - 1;

-- iteratively open the cursor while decrementing the ovn
-- and looking for given status until rows are returned

OPEN  csr_get_old_atts ( p_decr_ovn => l_decr_ovn );
FETCH csr_get_old_atts INTO r_old_atts;

WHILE ( csr_get_old_atts%NOTFOUND )
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

	CLOSE csr_get_old_atts;
	l_decr_ovn := l_decr_ovn - 1;

	IF ( l_decr_ovn <> 0 )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 30);
			hr_utility.trace('object version number is '||TO_CHAR(l_decr_ovn));
		end if;

		OPEN csr_get_old_atts ( p_decr_ovn => l_decr_ovn );
		FETCH csr_get_old_atts INTO r_old_atts;

	ELSE
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 40);
		end if;

		-- if we reach here l_decr ovn is 0 and
		-- so we have no old attributes

		l_attributes_exist := FALSE;
		EXIT;

	END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

END LOOP;

IF l_attributes_exist
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

-- lets continue to get those attributes

	WHILE csr_get_old_atts%FOUND
	LOOP
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 70);
		end if;

		-- before we write it to the table check that it is
		-- in the mapping

		IF ( p_bld_blk_info_tab.EXISTS(r_old_atts.bld_blk_info_type_id) )
		THEN

			t_old_atts(r_old_atts.bld_blk_info_type_id) := r_old_atts;

		END IF;

		FETCH csr_get_old_atts INTO r_old_atts;

	END LOOP;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 80);
end if;

CLOSE csr_get_old_atts;

END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 90);
end if;

RETURN t_old_atts;

END get_old_atts;


-- private procedure
--   chk_att_tco_not_changed
-- description
--   creates a table of distinct bld blk info type ids which have changed
--   and are in the mapping
--   Also returns table (l_time_attributes) indexed by time_attribute
--   _id with the rows which need to be tested.
--
--   checks to see if the NEW flag is Y, if so, then if it is
--   for a bld blk info type which is in the mapping, returns
--   CHANGED. if not then deletes from table
--
--   IF NEW flag is N then checks changed flag, if Y
--   then checks that bld blk type in mapping, if so
--   then returns TEST, if not deletes from table
--
--   IF NEW flag is N and CHANGED flag is N, then
--   deletes from table
--
--   IF NEW flags are all N and changed flags N for bld blks
--   info types in mapping RETURN NOTCHANGED

PROCEDURE chk_att_tco_not_changed ( p_time_attributes IN OUT NOCOPY hxc_self_service_time_deposit.building_block_attribute_info
				,   p_mappings_tab     hxc_generic_retrieval_pkg.t_field_mappings
				,   p_decision         IN OUT NOCOPY VARCHAR2
                                ,   p_bld_blk_info_tab IN OUT NOCOPY t_bld_blk_info ) IS

l_changed   VARCHAR2(10) := 'NOTCHANGED';
l_att_index BINARY_INTEGER;
l_map_index BINARY_INTEGER;
l_del_index BINARY_INTEGER;

l_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info;

l_proc		VARCHAR2(72);

BEGIN


if g_debug then
	l_proc := g_package||'.chk_att_tco_not_changed';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

-- build table of mapping bld blk info type ids

l_map_index := p_mappings_tab.FIRST;

WHILE ( l_map_index IS NOT NULL )
LOOP

	IF NOT ( p_bld_blk_info_tab.EXISTS(p_mappings_tab(l_map_index).bld_blk_info_type_id) )
	THEN
		p_bld_blk_info_tab(p_mappings_tab(l_map_index).bld_blk_info_type_id).bld_blk_info_type_id
		:= p_mappings_tab(l_map_index).bld_blk_info_type_id;

	END IF;

l_map_index := p_mappings_tab.NEXT(l_map_index);

END LOOP;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

-- kluge since APPROVALS does not pass tco anymore
-- thus if attributes 0 called from approvals

l_att_index := p_time_attributes.COUNT;

IF ( l_att_index = 0 )
THEN
	l_changed := 'TEST';
END IF;

l_att_index := p_time_attributes.FIRST;

WHILE ( l_att_index IS NOT NULL )
LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

	IF ( p_time_attributes(l_att_index).new = 'Y' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 40);
		end if;

		-- check to see if this attribute category is in the mapping

		IF ( p_bld_blk_info_tab.EXISTS(p_time_attributes(l_att_index).bld_blk_info_type_id) )
		THEN
			l_changed := 'CHANGED';
			EXIT;
		ELSE
			l_del_index := l_att_index;
			l_att_index := p_time_attributes.NEXT(l_att_index);
			p_time_attributes.DELETE(l_del_index);

		END IF;

	ELSIF ( p_time_attributes(l_att_index).changed = 'Y' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 50);
		end if;

		-- check to see if this attribute category is in the mapping

		IF ( p_bld_blk_info_tab.EXISTS(p_time_attributes(l_att_index).bld_blk_info_type_id) )
		THEN
			l_changed   := 'TEST';

			-- maintain new parsed time attribute table with time attribute id index

			l_time_attributes(p_time_attributes(l_att_index).time_attribute_id)
				    := p_time_attributes(l_att_index);

			l_att_index := p_time_attributes.NEXT(l_att_index);

		ELSE
			l_del_index := l_att_index;
			l_att_index := p_time_attributes.NEXT(l_att_index);
			p_time_attributes.DELETE(l_del_index);
		END IF;

	ELSE
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

		l_del_index := l_att_index;
		l_att_index := p_time_attributes.NEXT(l_att_index);
		p_time_attributes.DELETE(l_del_index);

	END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

END LOOP;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 80);
end if;

p_time_attributes.DELETE;

p_time_attributes := l_time_attributes;

p_decision := l_changed;

END chk_att_tco_not_changed;


BEGIN -- chk_mapping_changed

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.chk_mapping_changed';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

-- first of all populate the mapping table

t_mapping := get_field_mappings ( p_mapping_id );

-- regardless of where this is called from
-- we should check the TCO to see if anything has changed
-- which is relevant to the mapping

l_parsed_attributes := p_time_attributes;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

chk_att_tco_not_changed ( p_time_attributes => l_parsed_attributes
		,         p_mappings_tab    => t_mapping
		,         p_decision        => l_decision
                ,         p_bld_blk_info_tab=> l_bld_blk_info_tab );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

IF ( l_decision = 'NOTCHANGED' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

	l_mapping_changed := FALSE;

ELSIF ( l_decision = 'CHANGED' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 50);
	end if;

	l_mapping_changed := TRUE;

ELSE

IF ( p_called_from = 'TIME_ENTRY' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 60);
	end if;

-- row has not been committed to the database
-- TCO bb id and ovn is of the current row on the
-- database but the values are the new values.

-- now loop through the building blocks one at a time
-- and compare the current and new attribute tables

if g_debug then
	hr_utility.trace('************* TIME_ENTRY ***************');
end if;

FOR tc IN csr_get_timecard (
			   p_timecard_bb_id => p_timecard_bb_id
			,  p_timecard_ovn   => p_timecard_ovn
			,  p_start_date     => p_start_date
			,  p_end_date       => p_end_date )
LOOP

l_no_such_bb_id := FALSE;

if g_debug then
	hr_utility.trace('************* Timecard Loop ***************');
	hr_utility.trace('bb id is '||to_char(tc.bb_id));
	hr_utility.trace('bb ovn is '||to_char(tc.bb_ovn));
end if;


FOR bb IN csr_get_attributes ( p_bb_id => tc.bb_id, p_bb_ovn => tc.bb_ovn )
LOOP

if g_debug then
	hr_utility.trace('************* Attribute Loop ***************');
	hr_utility.trace('bb id is '||to_char(tc.bb_id));
	hr_utility.trace('bb ovn is '||to_char(tc.bb_ovn));
	hr_utility.trace('bld blk info type '||to_char(bb.bld_blk_info_type_id));

	hr_utility.set_location('Processing '||l_proc, 70);
end if;

-- Maintain old attributes record and table

r_old_atts := bb;

IF ( l_parsed_attributes.EXISTS(r_old_atts.time_attribute_id) )
THEN

	-- this is called from TIME_ENTRY and thus
	-- these attributes are the old values
	-- since nothing has been committed yet
	-- and the values used to get this data
	-- are the old bb_id and bb_ovn

	t_old_attributes(r_old_atts.bld_blk_info_type_id):= r_old_atts;

	t_new_attributes(r_old_atts.bld_blk_info_type_id):=
					l_parsed_attributes(r_old_atts.time_attribute_id);

END IF;

END LOOP; -- csr_get_attributes

-- compare old and new values.
-- if values are different return true

-- remember we delete from l_parsed_attributes (the table used to populate t_new_attributes)
-- in chk_att_tco changed if the attribute row has not been changed
-- thus when we select the old value from the database this does not necessarily
-- need to be compared, we must first check that the new attributes table is not ZERO

IF ( compare_attributes ( p_new_attributes_table => t_new_attributes
		,	  p_old_attributes_table => t_old_attributes
		,	  p_mappings_tab         => t_mapping ) )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 90);
	end if;

	l_mapping_changed := TRUE;
	EXIT;
END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

t_old_attributes.delete;
t_new_attributes.delete;
l_new_index := 1;
l_old_index := 1;

END LOOP; -- csr_get_timecard

-- raise an error if the bb_id, ovn and dates returned no rows

IF ( l_no_such_bb_id )
THEN
    fnd_message.set_name('HXC', 'HXC_0013_GNRET_NO_BLD_BLKS');
    fnd_message.raise_error;
END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 110);
end if;


ELSE -- p_called_from = 'APPROVALS'

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 120);
end if;

-- now loop through the building blocks one at a time
-- and compare the current and new attribute tables

FOR tc IN csr_get_timecard (
			   p_timecard_bb_id => p_timecard_bb_id
			,  p_timecard_ovn   => p_timecard_ovn
			,  p_start_date     => p_start_date
			,  p_end_date       => p_end_date )
LOOP

l_no_such_bb_id := FALSE;

-- make sure that this is not the first bb
-- otherwise there cannot be any history

IF ( tc.bb_ovn <> 1 )
THEN

if g_debug then
	hr_utility.trace('************* Timecard Loop ***************');
	hr_utility.trace('bb id is '||to_char(tc.bb_id));
	hr_utility.trace('bb ovn is '||to_char(tc.bb_ovn));
end if;


FOR bb IN csr_get_attributes ( p_bb_id => tc.bb_id, p_bb_ovn => tc.bb_ovn )
LOOP

if g_debug then
	hr_utility.trace('************* Attribute Loop ***************');
	hr_utility.trace('bb id is '||to_char(tc.bb_id));
	hr_utility.trace('bb ovn is '||to_char(tc.bb_ovn));
	hr_utility.trace('bld blk info type '||to_char(bb.bld_blk_info_type_id));
end if;

-- flag to be able to set changed flag if all the bld blks in the hierarchy
-- have ovn = 1

l_all_first_ovn := FALSE;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 130);
end if;

-- Maintain new attributes record and table

r_new_atts := bb;

IF ( l_bld_blk_info_tab.EXISTS(r_new_atts.bld_blk_info_type_id) )
THEN

	t_new_attributes(r_new_atts.bld_blk_info_type_id):= r_new_atts;

END IF;

END LOOP; -- csr_get_attributes

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 140);
end if;

-- populate old attributes

t_old_attributes := get_old_atts (
		p_bb_id		=> tc.bb_id
	,	p_bb_ovn	=> tc.bb_ovn
	,	p_status	=> p_last_status
	,	p_bld_blk_info_tab => l_bld_blk_info_tab );

-- compare old and new values.
-- if values are different return true

/*
if g_debug then
	hr_utility.trace('');
	hr_utility.trace('****** old table is ********');
end if;

l_new_index := t_old_attributes.FIRST;

WHILE ( l_new_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('bb id      '||to_char(t_old_attributes(l_new_index).building_block_id));
	hr_utility.trace('bld blk id '||to_char(t_old_attributes(l_new_index).bld_blk_info_type_id));
	hr_utility.trace('attribute category '||t_old_attributes(l_new_index).attribute_category);
	hr_utility.trace('attribute1 '||t_old_attributes(l_new_index).attribute1);
	hr_utility.trace('attribute2 '||t_old_attributes(l_new_index).attribute2);
	hr_utility.trace('attribute3 '||t_old_attributes(l_new_index).attribute3);
	hr_utility.trace('attribute4 '||t_old_attributes(l_new_index).attribute4);
	hr_utility.trace('attribute5 '||t_old_attributes(l_new_index).attribute5);
	hr_utility.trace('new        '||t_old_attributes(l_new_index).new);
	hr_utility.trace('changed    '||t_old_attributes(l_new_index).changed);
	hr_utility.trace('');
end if;

l_new_index := t_old_attributes.NEXT(l_new_index);

END LOOP;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('****** new table is ********');
end if;

l_new_index := t_new_attributes.FIRST;

WHILE ( l_new_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('bb id      '||to_char(t_new_attributes(l_new_index).building_block_id));
	hr_utility.trace('bld blk id '||to_char(t_new_attributes(l_new_index).bld_blk_info_type_id));
	hr_utility.trace('attribute category '||t_new_attributes(l_new_index).attribute_category);
	hr_utility.trace('attribute1 '||t_new_attributes(l_new_index).attribute1);
	hr_utility.trace('attribute2 '||t_new_attributes(l_new_index).attribute2);
	hr_utility.trace('attribute3 '||t_new_attributes(l_new_index).attribute3);
	hr_utility.trace('attribute4 '||t_new_attributes(l_new_index).attribute4);
	hr_utility.trace('attribute5 '||t_new_attributes(l_new_index).attribute5);
	hr_utility.trace('new        '||t_new_attributes(l_new_index).new);
	hr_utility.trace('changed    '||t_new_attributes(l_new_index).changed);
	hr_utility.trace('');
end if;

l_new_index := t_new_attributes.NEXT(l_new_index);

END LOOP;

*/

IF ( compare_attributes ( p_new_attributes_table => t_new_attributes
		,	  p_old_attributes_table => t_old_attributes
		,	  p_mappings_tab         => t_mapping ) )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 150);
	end if;

	l_mapping_changed := TRUE;
	EXIT;
END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 160);
end if;

t_old_attributes.delete;
t_new_attributes.delete;
l_new_index := 1;
l_old_index := 1;

-- Maintain old bld blk

END IF; -- chk ovn <> 1

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 170);
end if;

END LOOP; -- csr_get_timecard

-- raise an error if the bb_id, ovn and dates returned no rows

IF ( l_no_such_bb_id )
THEN
    fnd_message.set_name('HXC', 'HXC_0013_GNRET_NO_BLD_BLKS');
    fnd_message.raise_error;
END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 180);
end if;

-- chk that all bld blks were not the first bls blks

IF l_all_first_ovn
THEN
	l_mapping_changed := TRUE;
END IF;

END IF; -- p_called_from = 'TIME_ENTRY'

END IF; -- l_decision = 'NOTCHANGED'

RETURN l_mapping_changed;

END chk_mapping_changed;


-- public function
--   chk_bld_blk_changed
-- description
--   see package specification

FUNCTION chk_bld_blk_changed (  p_timecard_bb_id NUMBER
			,	p_timecard_ovn	NUMBER
			,	p_start_date	DATE
			,	p_end_date	DATE
			,	p_last_status   VARCHAR2
			,	p_time_bld_blks hxc_self_service_time_deposit.timecard_info ) RETURN BOOLEAN IS

l_proc VARCHAR2(72);

r_bld_blks           csr_get_timecard%rowtype;
r_old_bld_blks       csr_get_timecard%rowtype;
r_del_bld_blks       csr_get_timecard%rowtype;
r_old_del_bld_blks   csr_get_timecard%rowtype;

TYPE t_bld_blk IS TABLE OF csr_get_timecard%ROWTYPE INDEX BY BINARY_INTEGER;

t_bld_blks	t_bld_blk;
t_old_bld_blks	t_bld_blk;
t_del_bld_blks  t_bld_blk;

l_return		BOOLEAN := FALSE;

l_bld_blk_cnt	  BINARY_INTEGER := 0;
l_old_bld_blk_cnt BINARY_INTEGER := 0;

l_index BINARY_INTEGER :=0;

l_decr_ovn NUMBER(9);

CURSOR	csr_get_bld_blk (  p_bb_id   NUMBER
			,  p_bb_ovn  NUMBER
			,  p_status  VARCHAR2 ) IS
SELECT
	bb.time_building_block_id bb_id
,	bb.object_Version_number bb_ovn
,	bb.scope
,	bb.type
,	bb.start_time
,	bb.stop_time
,	bb.measure
,       bb.date_to
,       bb.comment_text
FROM
	hxc_time_building_blocks bb
WHERE
	bb.time_building_block_id = p_bb_id   AND
        bb.object_version_number  = p_bb_ovn  AND
	bb.approval_status        = p_status;


BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.chk_bld_blk_changed';
	hr_utility.set_location('Entering '||l_proc, 10);
	hr_utility.trace('last status is '||p_last_status);
end if;

-- before we do anything else lets check to see
-- if any of the bld blks are new

l_index := p_time_bld_blks.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP

	IF ( p_time_bld_blks(l_index).new = 'Y' )
	THEN

		l_return	:= TRUE;
		RETURN		l_return;

	END IF;

l_index := p_time_bld_blks.NEXT(l_index);

END LOOP;

-- loop to populate the current bld blks record

FOR tc IN csr_get_timecard (
			   p_timecard_bb_id => p_timecard_bb_id
			,  p_timecard_ovn   => p_timecard_ovn
			,  p_start_date     => p_start_date
			,  p_end_date       => p_end_date )
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

	IF ( tc.bb_ovn <> 1 )
	THEN
		-- only want to populate current bld blks whose ovn is not 1

		l_index := tc.bb_id;

		IF ( tc.date_to = hr_general.end_of_time )
		THEN
			t_bld_blks(l_index) := tc;
		ELSE
			t_del_bld_blks(l_index) := tc;
		END IF;

	END IF;

END LOOP; -- csr_get_timecard

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;

l_index     := t_del_bld_blks.FIRST;

IF ( l_index IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

l_decr_ovn  := t_del_bld_blks(l_index).bb_ovn;

WHILE ( l_index IS NOT NULL AND l_decr_ovn >= 2 )
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

-- loop to populate the last bld blk of given status

	l_decr_ovn := l_decr_ovn - 1;

	OPEN  csr_get_bld_blk (    p_bb_id          => l_index
				,  p_bb_ovn         => l_decr_ovn
				,  p_status         => p_last_status );
	FETCH csr_get_bld_blk INTO r_old_del_bld_blks;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 70);
	end if;

	WHILE ( csr_get_bld_blk%NOTFOUND )
	LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 80);
	end if;

		l_decr_ovn := l_decr_ovn - 1;

		IF ( l_decr_ovn <> 0 )
		THEN
			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 90);
				hr_utility.trace('bb id is '||TO_CHAR(l_index));
				hr_utility.trace('object version number is '||TO_CHAR(l_decr_ovn));
			end if;

			CLOSE csr_get_bld_blk;

			OPEN  csr_get_bld_blk (
				   p_bb_id    => l_index
				,  p_bb_ovn   => l_decr_ovn
				,  p_status   => p_last_status );

			FETCH csr_get_bld_blk INTO r_old_del_bld_blks;

		ELSE
			-- l_decr_ovn = 0

			EXIT;

		END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 100);
	end if;

	END LOOP; -- csr_get_timecard for old timecard

	-- if we found a prior del bld blk check to see if it was deleted
	-- if it was deleted or we did not find one then do nothing

	IF ( csr_get_bld_blk%FOUND )
	THEN
		IF ( r_old_del_bld_blks.date_to <> hr_general.end_of_time )
		THEN
			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 110);
			end if;

			CLOSE csr_get_bld_blk;

			l_return := TRUE;
			RETURN	 l_return;

		END IF;
	END IF;

	CLOSE csr_get_bld_blk;

	l_index := t_del_bld_blks.NEXT(l_index);

	IF ( l_index IS NOT NULL )
	THEN
		l_decr_ovn   := t_del_bld_blks(l_index).bb_ovn;
	END IF;

END LOOP; -- WHILE ( l_index IS NOT NULL )

END IF; -- ( l_index IS NOT NULL )

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 120);
end if;


-- check non deleted bld blks

l_index    := t_bld_blks.FIRST;

IF ( l_index IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 130);
end if;

l_decr_ovn := t_bld_blks(l_index).bb_ovn;

WHILE ( l_index IS NOT NULL AND l_decr_ovn >= 2 )
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 140);
end if;

-- loop to populate the last bld blk of given status

	l_decr_ovn := l_decr_ovn - 1;

	OPEN  csr_get_bld_blk (    p_bb_id          => l_index
				,  p_bb_ovn         => l_decr_ovn
				,  p_status         => p_last_status );
	FETCH csr_get_bld_blk INTO r_old_bld_blks;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 150);
	end if;

	WHILE ( csr_get_bld_blk%NOTFOUND )
	LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 160);
	end if;

		l_decr_ovn := l_decr_ovn - 1;

		IF ( l_decr_ovn <> 0 )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 170);
				hr_utility.trace('bb id is '||TO_CHAR(l_index));
				hr_utility.trace('object version number is '||TO_CHAR(l_decr_ovn));
			end if;

			CLOSE csr_get_bld_blk;

			OPEN  csr_get_bld_blk (
				   p_bb_id    => l_index
				,  p_bb_ovn   => l_decr_ovn
				,  p_status   => p_last_status );

			FETCH csr_get_bld_blk INTO r_old_bld_blks;

		ELSE
			-- l_decr_ovn = 0

			EXIT;

		END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 180);
	end if;

	END LOOP; -- csr_get_timecard for old timecard

	-- if bld blk of prior status found populate table for comparison
	-- otherwise flag change

	IF ( csr_get_bld_blk%FOUND )
	THEN
		t_old_bld_blks(l_index) := r_old_bld_blks;
	END IF;

	CLOSE csr_get_bld_blk;

	l_index := t_bld_blks.NEXT(l_index);

	IF ( l_index IS NOT NULL )
	THEN
		l_decr_ovn   := t_bld_blks(l_index).bb_ovn;
	END IF;

END LOOP; -- WHILE ( l_index IS NOT NULL )

END IF; -- ( l_index IS NOT NULL )

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 200);
end if;

-- if we have reached here then we have two tables of bld blks
-- one for the current timecard and one for the timecard of the prior status
-- it is time to start comparing actual attributes

-- first lets just make sure that the timecard dates have not changed
-- if the timecard bld blk has changed

IF ( t_old_bld_blks.EXISTS(p_timecard_bb_id) )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 210);
end if;

-- compare old timecard dates with new

IF ( ( t_bld_blks(p_timecard_bb_id).start_time <> t_old_bld_blks(p_timecard_bb_id).start_time )
  OR ( t_bld_blks(p_timecard_bb_id).stop_time  <> t_old_bld_blks(p_timecard_bb_id).stop_time ) )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 220);
	end if;

	l_return	:= TRUE;
	RETURN		l_return;
END IF;

END IF; -- t_old_bld_blks.EXISTS(p_timecard_bb_id)

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 230);
end if;

-- compare DAY scope start and stop times

l_index := t_old_bld_blks.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 240);
	end if;

	-- GPM v115.22

        IF ( NVL(t_bld_blks(l_index).comment_text,'XxX') <> NVL(t_old_bld_blks(l_index).comment_text,'XxX') )
        THEN

               l_return   := TRUE;
               RETURN     l_return;

        END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 245);
	end if;

	IF ( t_old_bld_blks(l_index).SCOPE = 'DAY' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 250);
		end if;

		-- compare dates

		IF ( ( t_bld_blks(l_index).start_time <> t_old_bld_blks(l_index).start_time )
		  OR ( t_bld_blks(l_index).stop_time  <> t_old_bld_blks(l_index).stop_time ) )
		THEN
			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 260);
			end if;

			l_return	:= TRUE;
			RETURN		l_return;
		END IF;

	ELSIF ( t_old_bld_blks(l_index).SCOPE = 'DETAIL' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 270);
		end if;

		IF ( t_old_bld_blks(l_index).TYPE = 'MEASURE' )
		THEN

		-- compare measure

			IF ( t_bld_blks(l_index).measure <> t_old_bld_blks(l_index).measure )
			THEN
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 280);
				end if;

				l_return	:= TRUE;
				RETURN		l_return;
			END IF;

		ELSE

			IF ((t_bld_blks(l_index).stop_time - t_bld_blks(l_index).start_time ) <>
	                    (t_old_bld_blks(l_index).stop_time - t_old_bld_blks(l_index).start_time ))
			THEN
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 290);
				end if;

				l_return	:= TRUE;
				RETURN		l_return;
			END IF;


		END IF; -- TYPE = 'MEASURE'

	END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 300);
	end if;

	l_index := t_old_bld_blks.NEXT(l_index);

END LOOP;

RETURN l_return;

END chk_bld_blk_changed;

-- function
--   attribute_column
--
-- description
--   returns the name of the attribute column in HXC_TIME_ATTRIBUTES which
--   maps to the parameter p_field_name, based on the building block
--   category and information type
--
-- parameters
--   p_field_name                 - the name of the field to be mapped
--   p_bld_blk_info_type          - the information of the attribute
--   p_descriptive_flexfield_name - the name of the flexfield

function attribute_column
  (p_field_name                 in varchar2
  ,p_bld_blk_info_type          in varchar2
  ,p_descriptive_flexfield_name in varchar2
  ) return varchar2 is

cursor c_map is
  select hmc.segment
  from hxc_mapping_components hmc,
       hxc_bld_blk_info_types hit
  where hit.descriptive_flexfield_name = p_descriptive_flexfield_name
  and   hit.bld_blk_info_type_id       = hmc.bld_blk_info_type_id
  and   hit.bld_blk_info_type          = p_bld_blk_info_type
  and   hmc.field_name                 = p_field_name;

e_no_mapping_exists exception;

l_column_name varchar2(30);

begin

  open c_map;
  fetch c_map into l_column_name;
  if c_map%notfound then
    close c_map;
    raise e_no_mapping_exists;
  else
    close c_map;
    return l_column_name;
  end if;

exception
  when e_no_mapping_exists then
    -- no mapping has been defined for the specified combination
    fnd_message.set_name('HXC', 'HXC_NO_MAPPING_SEGMENT');
    fnd_message.raise_error;
  when others then
    raise;

end attribute_column;


-- function
--   attribute_column
--
-- description
--   overload of attribute_column function.  returns the name of the
--   attribute column in HXC_TIME_ATTRIBUTES which maps to the parameter
--   p_field_name, based on the deposit or retrieval process identifier.
--   since there is no guarantee that mappings have been explicitly defined
--   for the given process, the column name is returned in an out parameter,
--   and the function returns true or false depending on whether a mapping
--   was found.
--
-- parameters
--   p_field_name              - the name of the field to be mapped
--   p_process_type            - (D)eposit or (R)etrieval
--   p_process_id              - deposit or retrieval process id
--   p_column_name (out)       - the column name where the specified field is
--                               stored
--   p_bld_blk_info_type (out) - the information type of the mapped field

function attribute_column
  (p_field_name        in     varchar2
  ,p_process_type      in     varchar2
  ,p_process_id        in     number
  ,p_column_name       in out nocopy varchar2
  ,p_bld_blk_info_type in out nocopy varchar2
  ) return boolean is

cursor c_map_ret is
  select distinct hmc.segment, hit.bld_blk_info_type
  from hxc_mapping_components  hmc
  ,    hxc_mapping_comp_usages hmu
  ,    hxc_mappings            hmp
  ,    hxc_retrieval_processes hrp
  ,    hxc_bld_blk_info_types  hit
  where hmu.mapping_id           = hmp.mapping_id
  and   hmp.mapping_id           = hrp.mapping_id
  and   hmc.bld_blk_info_type_id = hit.bld_blk_info_type_id
  and   hrp.retrieval_process_id = p_process_id
  and   hmc.mapping_component_id = hmu.mapping_component_id
  and   hmc.field_name           = p_field_name;

cursor c_map_dep is
  select distinct hmc.segment, hit.bld_blk_info_type
  from hxc_mapping_components  hmc
  ,    hxc_mapping_comp_usages hmu
  ,    hxc_mappings            hmp
  ,    hxc_deposit_processes   hdp
  ,    hxc_bld_blk_info_types  hit
  where hmu.mapping_id           = hmp.mapping_id
  and   hmp.mapping_id           = hdp.mapping_id
  and   hmc.bld_blk_info_type_id = hit.bld_blk_info_type_id
  and   hdp.deposit_process_id   = p_process_id
  and   hmc.mapping_component_id = hmu.mapping_component_id
  and   hmc.field_name           = p_field_name;


e_no_distinct_mapping exception;

l_column_name       varchar2(30);
l_bld_blk_info_type varchar2(80);

begin

if(p_process_type = 'D') then
  open c_map_dep;
  fetch c_map_dep into l_column_name, l_bld_blk_info_type;
  if c_map_dep%notfound then
    close c_map_dep;
    return false;
  elsif c_map_dep%rowcount > 1 then
    close c_map_dep;
    raise e_no_distinct_mapping;
  else
    close c_map_dep;
    p_column_name := l_column_name;
    p_bld_blk_info_type := l_bld_blk_info_type;
    return true;
  end if;
elsif(p_process_type = 'R') then
open c_map_ret;
  fetch c_map_ret into l_column_name, l_bld_blk_info_type;
  if c_map_ret%notfound then
    close c_map_ret;
    return false;
  elsif c_map_ret%rowcount > 1 then
    close c_map_ret;
    raise e_no_distinct_mapping;
  else
    close c_map_ret;
    p_column_name := l_column_name;
    p_bld_blk_info_type := l_bld_blk_info_type;
    return true;
  end if;
end if;

exception
  when e_no_distinct_mapping then
    -- more than one mapping has been defined for the specified combination
    fnd_message.set_name('HXC', 'HXC_NO_DISTINCT_MAPPING');
    fnd_message.raise_error;
  when others then
    raise;

end attribute_column;


Procedure get_mapping_value(p_bld_blk_info_type in varchar2,
			    p_field_name  in varchar2,
			    p_segment out nocopy hxc_mapping_components.segment%TYPE,
			    p_bld_blk_info_type_id out nocopy hxc_mapping_components.bld_blk_info_type_id%TYPE ) is

CURSOR	csr_parse_mapping(p_bld_blk_info_type varchar2,p_field_name varchar2) IS
SELECT	segment
,	bld_blk_info_type_id
FROM	hxc_mapping_components_v
WHERE	bld_blk_info_type	= p_bld_blk_info_type
AND	field_name		= p_field_name;


l_proc	VARCHAR2(72);

begin

g_debug := hr_utility.debug_enabled;

OPEN  csr_parse_mapping(p_bld_blk_info_type,p_field_name);

	FETCH csr_parse_mapping INTO p_segment, p_bld_blk_info_type_id;

	if g_debug then
		l_proc := g_package||'.get_mapping_value';
		hr_utility.set_location('Processing '||l_proc, 15);
	end if;

	IF csr_parse_mapping%NOTFOUND
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 20);
		end if;

		CLOSE csr_parse_mapping;
	        hr_utility.set_message(809, 'HXC_0026_MPC_TYPE_INVALID');
	        hr_utility.raise_error;
	END IF;

	CLOSE csr_parse_mapping;


end get_mapping_value;



FUNCTION chk_mapping_exists ( p_bld_blk_info_type VARCHAR2
		,	      p_field_name  VARCHAR2
		,             p_field_value VARCHAR2
		,	      p_bld_blk_info_type2 VARCHAR2 default null
		,	      p_field_name2  VARCHAR2 default null
		,             p_field_value2 VARCHAR2 default null
		,	      p_bld_blk_info_type3 VARCHAR2 default null
		, 	      p_field_name3  VARCHAR2 default null
		,             p_field_value3 VARCHAR2 default null
		,	      p_bld_blk_info_type4 VARCHAR2 default null
		,	      p_field_name4  VARCHAR2 default null
		,             p_field_value4 VARCHAR2 default null
		,	      p_bld_blk_info_type5 VARCHAR2 default null
		,	      p_field_name5  VARCHAR2 default null
		,             p_field_value5 VARCHAR2 default null
		,             p_scope        VARCHAR2
                ,             p_retrieval_process_name VARCHAR2 DEFAULT 'None'
                ,             p_status VARCHAR2 DEFAULT 'None'
                ,             p_end_date DATE DEFAULT null) RETURN BOOLEAN IS

l_proc	VARCHAR2(72);

l_mapping_exists BOOLEAN := FALSE;

l_exists  VARCHAR2(1)    := 'N';

l_bld_blk_info_type_id	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id2	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id3	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id4	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id5	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_segment1		hxc_mapping_components.segment%TYPE;
l_segment2		hxc_mapping_components.segment%TYPE;
l_segment3		hxc_mapping_components.segment%TYPE;
l_segment4		hxc_mapping_components.segment%TYPE;
l_segment5		hxc_mapping_components.segment%TYPE;

l_bld_block_info_id_outer hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_field_name_outer     varchar2(1000);
l_field_value_outer     varchar2(1000);
l_segment_outer 	  hxc_mapping_components.segment%TYPE;

l_bld_block_info_id_inner hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_field_name_inner     varchar2(1000);
l_field_value_inner     varchar2(1000);
l_segment_inner 	 hxc_mapping_components.segment%TYPE;

l_ret_id                hxc_retrieval_processes.retrieval_process_id%TYPE;

l_query VARCHAR2(8000);

l_status_list varchar2(400);

l_status varchar2(1000);

l_end_date varchar2(400);

l_field_value varchar2(4000);

l_index number;

l_index_inner number;

l_cons_index number;

t_consolidated_info hxc_mapping_utilities.t_consolidated_info_1;


l_installed varchar2(1) := 'N';

TYPE MapExistsCur IS REF CURSOR;
map_cr   MapExistsCur;

TYPE MapTxfrdCur IS REF CURSOR;
txfrd_cr   MapTxfrdCur;

CURSOR  csr_chk_otl_installed IS
SELECT  'Y'
FROM    fnd_product_installations pi
WHERE   pi.application_id = 809
AND     pi.status in ( 'S', 'I' );


CURSOR  csr_get_ret_id IS
SELECT  ret.retrieval_process_id
FROM 	hxc_retrieval_processes ret
WHERE	ret.name = p_retrieval_process_name;



BEGIN -- chk_mapping_exists

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.chk_mapping_exists';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

-- chk to see if OTL is installed

OPEN  csr_chk_otl_installed;

FETCH csr_chk_otl_installed INTO l_installed;

IF ( csr_chk_otl_installed%FOUND )
THEN

	IF ( p_scope <> 'DETAIL' AND p_status <> 'None' )
	THEN

		fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
		fnd_message.set_token('PROCEDURE', l_proc);
		fnd_message.set_token('STEP','Scope Status combo not supported');
		fnd_message.raise_error;

	END IF;




	if(p_field_name is not null) then

	get_mapping_value(p_bld_blk_info_type,p_field_name,l_segment1,l_bld_blk_info_type_id);

	end if;

	if(p_field_name2 is not null) then

	get_mapping_value(p_bld_blk_info_type2,p_field_name2,l_segment2,l_bld_blk_info_type_id2);

	end if;

	if(p_field_name3 is not null) then

	get_mapping_value(p_bld_blk_info_type3,p_field_name3,l_segment3,l_bld_blk_info_type_id3);

	end if;


	if(p_field_name4 is not null) then

	get_mapping_value(p_bld_blk_info_type4,p_field_name4,l_segment4,l_bld_blk_info_type_id4);

	end if;


	if(p_field_name5 is not null) then

	get_mapping_value(p_bld_blk_info_type5,p_field_name5,l_segment5,l_bld_blk_info_type_id5);

	end if;





	if(p_bld_blk_info_type is not null and p_field_name is not null) then
		if(t_consolidated_info.count>0) then
		l_cons_index:=t_consolidated_info.count+1;
		else
		l_cons_index:=1;
		end if;

	t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id;
	t_consolidated_info(l_cons_index).field_name :=p_field_name;
	t_consolidated_info(l_cons_index).field_value:=p_field_value ;
	t_consolidated_info(l_cons_index).segment:=l_segment1;

	end if;

	if(p_bld_blk_info_type2 is not null and p_field_name2 is not null) then
		if(t_consolidated_info.count>0) then
			l_cons_index:=t_consolidated_info.count+1;
		else
			l_cons_index:=1;
		end if;

	t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id2;
	t_consolidated_info(l_cons_index).field_name :=p_field_name2;
	t_consolidated_info(l_cons_index).field_value:=p_field_value2 ;
	t_consolidated_info(l_cons_index).segment:=l_segment2;


	end if;

	if(p_bld_blk_info_type3 is not null and p_field_name3 is not null) then
		if(t_consolidated_info.count>0) then
			l_cons_index:=t_consolidated_info.count+1;
		else
			l_cons_index:=1;
		end if;

	t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id3;
	t_consolidated_info(l_cons_index).field_name :=p_field_name3;
	t_consolidated_info(l_cons_index).field_value:=p_field_value3 ;
	t_consolidated_info(l_cons_index).segment:=l_segment3;

	end if;

	if(p_bld_blk_info_type4 is not null and p_field_name4 is not null) then
		if(t_consolidated_info.count>0) then
			l_cons_index:=t_consolidated_info.count+1;
		else
			l_cons_index:=1;
		end if;

	t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id4;
	t_consolidated_info(l_cons_index).field_name :=p_field_name4;
	t_consolidated_info(l_cons_index).field_value:=p_field_value4 ;
	t_consolidated_info(l_cons_index).segment:=l_segment4;

	end if;

	if(p_bld_blk_info_type5 is not null and p_field_name5 is not null) then
		if(t_consolidated_info.count>0) then
			l_cons_index:=t_consolidated_info.count+1;
		else
			l_cons_index:=1;
		end if;

	t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id5;
	t_consolidated_info(l_cons_index).field_name :=p_field_name5;
	t_consolidated_info(l_cons_index).field_value:=p_field_value5 ;
	t_consolidated_info(l_cons_index).segment:=l_segment5;

	end if;


	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

	-- build dynamic SQL query

	IF ( p_scope <> 'DETAIL' )
	THEN

	l_query := '
	SELECT  ''Y''
	FROM    dual
	WHERE EXISTS (
		SELECT  1
		FROM    hxc_time_building_blocks tbb
		WHERE   tbb.scope = :p_scope AND
			tbb.object_version_number = (
			   SELECT MAX ( tbb1.object_version_number )
			   FROM   hxc_time_building_blocks tbb1
			   WHERE  tbb1.time_building_block_id = tbb.time_building_block_id )';

	ELSE

	-- p scope must be DETAIL which means we can use the summary table hxc_latest_details

	l_query := '
	SELECT  ''Y''
	FROM    dual
	WHERE EXISTS (
		SELECT  1
		FROM    hxc_latest_details tbb
		WHERE 1=1';

	END IF;



	l_index:=t_consolidated_info.first;

	loop exit when not t_consolidated_info.exists(l_index);


			l_bld_block_info_id_outer:=t_consolidated_info(l_index).bld_blk_info_type_id;
			l_field_name_outer:=t_consolidated_info(l_index).field_name;
			l_field_value_outer:=t_consolidated_info(l_index).field_value;
			l_segment_outer:=t_consolidated_info(l_index).segment;

		if(l_field_value_outer is not null) then




			l_field_value:= l_field_value||' AND (tbb.time_building_block_id,tbb.object_version_number)in  (
							select  /*+ LEADING(ta1) INDEX(ta1)
							            INDEX(tau1 HXC_TIME_ATTRIBUTE_USAGES_FK1) */
							tau1.time_building_block_id,tau1.time_building_block_ovn from
							hxc_time_attribute_usages tau1,
							hxc_time_attributes ta1
							where   tau1.time_building_block_id      = tbb.time_building_block_id
							AND	tau1.time_building_block_ovn     = tbb.object_version_number
							AND     tau1.time_attribute_id           = ta1.time_attribute_id
							AND     ta1.bld_blk_info_type_id         = '||l_bld_block_info_id_outer||
							' AND     ta1.'||l_segment_outer||' = '''|| l_field_value_outer||'''' ;


		else


			l_field_value:= l_field_value||' AND (tbb.time_building_block_id,tbb.object_version_number)in  (
							select   /*+ LEADING(ta1) INDEX(ta1)
							             INDEX(tau1 HXC_TIME_ATTRIBUTE_USAGES_FK1) */
							tau1.time_building_block_id,tau1.time_building_block_ovn from
							hxc_time_attribute_usages tau1,
							hxc_time_attributes ta1
								where   tau1.time_building_block_id      = tbb.time_building_block_id
								AND	tau1.time_building_block_ovn     = tbb.object_version_number
								AND     tau1.time_attribute_id           = ta1.time_attribute_id
								AND     ta1.bld_blk_info_type_id         =  '||l_bld_block_info_id_outer||
								' AND     ta1.'||l_segment_outer||'		is null ';


		end if;

		        l_index_inner:=t_consolidated_info.next(l_index);


			loop exit when not t_consolidated_info.exists(l_index_inner);

			   if (l_bld_block_info_id_outer=t_consolidated_info(l_index_inner).bld_blk_info_type_id) then

				l_bld_block_info_id_inner:=t_consolidated_info(l_index_inner).bld_blk_info_type_id;
				l_field_name_inner:=t_consolidated_info(l_index_inner).field_name;
				l_field_value_inner:=t_consolidated_info(l_index_inner).field_value;
				l_segment_inner:=t_consolidated_info(l_index_inner).segment;

				if(l_field_value_inner is not null) then

				l_field_value:=l_field_value||' AND ta1.'||l_segment_inner||' = '''||l_field_value_inner||'''' ;

				else

					l_field_value:=l_field_value||' AND ta1.'||l_segment_inner||' is null ';

				end if;

				t_consolidated_info.delete(l_index_inner);

			   end if;


		         	l_index_inner:=t_consolidated_info.next(l_index_inner);

		        end loop;
		        l_field_value:=l_field_value||')';

			l_index:= t_consolidated_info.next(l_index);

	end loop;

        	l_query:=l_query||l_field_value;


	--let us add the status check
	if p_status = 'WORKING' then
	    l_status_list := '(''WORKING'''||','||'''SUBMITTED'''||','||'''APPROVED'')';
	elsif p_status = 'SUBMITTED' then
	    l_status_list := '(''SUBMITTED'''||','||'''APPROVED'')';
	elsif p_status = 'APPROVED' then
	    l_status_list := '(''APPROVED'')';
	end if;

        if p_status in ('WORKING','SUBMITTED','APPROVED') then

		l_status := '
		  AND exists (
		   select ''Y''
		   from  hxc_time_building_blocks detbb,
                         hxc_time_building_blocks daybb,
                         hxc_timecard_summary     time_status
		   where tbb.time_building_Block_id      = detbb.time_building_block_id
                     and tbb.object_version_number       = detbb.object_version_number
                     and detbb.parent_building_block_id  = daybb.time_building_block_id
		     and detbb.parent_building_block_ovn = daybb.object_version_number
                     and time_status.timecard_id         = daybb.parent_building_block_id
		     and detbb.date_to                   = hr_general.end_of_time
                     and time_status.approval_status    IN '||l_status_list||' ) ';

		l_query := l_query ||l_status;

	end if;

	IF ( p_scope = 'DETAIL' )
	THEN

	l_end_date := '
                  AND tbb.stop_time >= :p_end_date ';

	ELSE

	l_end_date := '
                  AND exists (
                   select 1 from hxc_time_building_blocks daybb1
		   where tbb.parent_building_block_id = daybb1.time_building_block_id
		     and tbb.parent_building_block_ovn = daybb1.object_version_number
		     and daybb1.stop_time >= :p_end_date) ';

	END IF;

        if (p_end_date is not null) then

                l_query := l_query || l_end_date;
        end if;




	l_query := l_query||')';

	if g_debug then
		hr_utility.trace(' ');
		hr_utility.trace('Now let us print the query');

		hr_utility.trace(substr(l_query,1,200));
		hr_utility.trace(substr(l_query,201,200));
		hr_utility.trace(substr(l_query,401,200));
		hr_utility.trace(substr(l_query,601,200));
		hr_utility.trace(substr(l_query,801,200));
		hr_utility.trace(substr(l_query,1001,200));
		hr_utility.trace(substr(l_query,1201,200));
		hr_utility.trace(substr(l_query,1401,200));
		hr_utility.trace(substr(l_query,1601,200));
		hr_utility.trace(substr(l_query,1801,200));
		hr_utility.trace(substr(l_query,2001,200));
		hr_utility.trace(substr(l_query,2201,200));
		hr_utility.trace(substr(l_query,2401,200));
		hr_utility.trace(substr(l_query,2601,200));
		hr_utility.trace(substr(l_query,2801,200));
		hr_utility.trace(substr(l_query,3001,200));
		hr_utility.trace(' ');

		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

        if (p_end_date is not null and p_scope = 'DETAIL' ) then

        	OPEN map_cr FOR l_query USING p_end_date;

        elsif (p_end_date is not null ) then

		OPEN map_cr FOR l_query USING p_scope,p_end_date;

        elsif (p_end_date is null and p_scope = 'DETAIL' ) then

		OPEN map_cr FOR l_query ;

	else
		OPEN map_cr FOR l_query USING p_scope;

        end if;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 50);
	end if;

	FETCH map_cr INTO l_exists;

	CLOSE map_cr;

	IF ( l_exists = 'Y' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

		l_mapping_exists := TRUE;

	END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 70);

		hr_utility.trace('ret proc name is '||p_retrieval_process_name);
	end if;

	IF ( ( p_retrieval_process_name = 'None' ) OR ( NOT l_mapping_exists ) )
	THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 75);
		end if;

		RETURN l_mapping_exists;

	END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 80);
	end if;

	-- the mapping exists and p_retrieval_process_name <> 'None'
	-- continue to check if it has been transferred.

	-- check to see if the Retrieval Process is valid

	OPEN  csr_get_ret_id;
	FETCH csr_get_ret_id INTO l_ret_id;

	IF csr_get_ret_id%NOTFOUND
	THEN

		CLOSE csr_get_ret_id;

		fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
		fnd_message.set_token('PROCEDURE', l_proc);
		fnd_message.set_token('STEP','Invalid Retrieval Process Name');
		fnd_message.raise_error;

	END IF;

	CLOSE csr_get_ret_id;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 90);
	end if;

	IF ( p_scope <> 'DETAIL' )
	THEN

	l_query := '
	SELECT  ''Y''
	FROM    dual
	WHERE EXISTS (
		SELECT  1
		FROM    hxc_time_building_blocks tbb
		WHERE   tbb.scope = :p_scope AND
			tbb.object_version_number = (
			   SELECT MAX ( tbb1.object_version_number )
			   FROM   hxc_time_building_blocks tbb1
			   WHERE  tbb1.time_building_block_id = tbb.time_building_block_id )
		AND NOT EXISTS (
			  SELECT  1
			  FROM    hxc_transactions tx
			  ,       hxc_transaction_details txd
			  WHERE   tx.transaction_process_id = :p_ret_id
			  AND     tx.status = ''SUCCESS''
			  AND     txd.transaction_id = tx.transaction_id
			  AND     txd.status = ''SUCCESS''
			  AND     txd.time_building_block_id = tbb.time_building_block_id
			  AND     txd.time_building_block_ovn = tbb.object_version_number ) ';

	ELSE

		-- must be DETAIL scope thus use hxc_latest_details

	l_query := '
	SELECT  ''Y''
	FROM    dual
	WHERE EXISTS (
		SELECT  1
		FROM  hxc_latest_details tbb
		WHERE NOT EXISTS (
			  SELECT  1
			  FROM    hxc_transactions tx
			  ,       hxc_transaction_details txd
			  WHERE   tx.transaction_process_id = :p_ret_id
			  AND     tx.status = ''SUCCESS''
			  AND     txd.transaction_id = tx.transaction_id
			  AND     txd.status = ''SUCCESS''
			  AND     txd.time_building_block_id = tbb.time_building_block_id
			  AND     txd.time_building_block_ovn = tbb.object_version_number ) ';


	END IF;


		l_query:=l_query||l_field_value;


        if p_status in ('WORKING','SUBMITTED','APPROVED') then

		l_query := l_query ||l_status;

	end if;

        if (p_end_date is not null) then

                l_query := l_query || l_end_date;
        end if;


	l_exists := 'N';
	l_mapping_exists := FALSE;

	l_query := l_query||')';

	if g_debug then
		hr_utility.trace(' ');
		hr_utility.trace('Now let us print the query that also includes check for retrieval status of timecards');

		hr_utility.trace(substr(l_query,1,200));
		hr_utility.trace(substr(l_query,201,200));
		hr_utility.trace(substr(l_query,401,200));
		hr_utility.trace(substr(l_query,601,200));
		hr_utility.trace(substr(l_query,801,200));
		hr_utility.trace(substr(l_query,1001,200));
		hr_utility.trace(substr(l_query,1201,200));
		hr_utility.trace(substr(l_query,1401,200));
		hr_utility.trace(substr(l_query,1601,200));
		hr_utility.trace(substr(l_query,1801,200));
		hr_utility.trace(substr(l_query,2001,200));
		hr_utility.trace(substr(l_query,2201,200));
		hr_utility.trace(substr(l_query,2401,200));
		hr_utility.trace(substr(l_query,2601,200));
		hr_utility.trace(substr(l_query,2801,200));
		hr_utility.trace(substr(l_query,3001,200));
		hr_utility.trace(' ');
	end if;


        if (p_end_date is not null and p_scope = 'DETAIL' ) then

		OPEN  txfrd_cr FOR l_query USING l_ret_id, p_end_date;

        elsif (p_end_date is not null ) then

		OPEN  txfrd_cr FOR l_query USING p_scope, l_ret_id, p_end_date;

        elsif (p_end_date is null and p_scope = 'DETAIL' ) then

        	OPEN  txfrd_cr FOR l_query USING  l_ret_id;

	else
        	OPEN  txfrd_cr FOR l_query USING p_scope, l_ret_id;

        end if;

	FETCH txfrd_cr INTO l_exists;

	CLOSE txfrd_cr;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 100);
	end if;

	IF ( l_exists = 'Y' )
	THEN
		l_mapping_exists := TRUE;
	END IF;

END IF; -- IF ( csr_chk_otl_installed%FOUND )

CLOSE csr_chk_otl_installed;


RETURN l_mapping_exists;

END chk_mapping_exists;



FUNCTION get_mappingvalue_sum ( p_bld_blk_info_type  VARCHAR2
		,	        p_field_name1        VARCHAR2
		,               p_bld_blk_info_type2 VARCHAR2 default null
		,	        p_field_name2        VARCHAR2
		,               p_field_value2       VARCHAR2
		,               p_bld_blk_info_type3 VARCHAR2 default null
		,	        p_field_name3        VARCHAR2 default null
		,               p_field_value3       VARCHAR2 default null
		,               p_bld_blk_info_type4 VARCHAR2 default null
		,	        p_field_name4        VARCHAR2 default null
		,               p_field_value4       VARCHAR2 default null
		,               p_bld_blk_info_type5 VARCHAR2 default null
		,	        p_field_name5        VARCHAR2 default null
		,               p_field_value5       VARCHAR2 default null
		,               p_status             VARCHAR2
                ,               p_resource_id        VARCHAR2
		) RETURN NUMBER IS

l_proc	VARCHAR2(72);

l_sum  NUMBER(20);

l_bld_blk_info_type_id	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id2	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id3	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id4	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type_id5	hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_segment1		hxc_mapping_components.segment%TYPE;
l_segment2		hxc_mapping_components.segment%TYPE;
l_segment3		hxc_mapping_components.segment%TYPE;
l_segment4		hxc_mapping_components.segment%TYPE;
l_segment5		hxc_mapping_components.segment%TYPE;

t_consolidated_info hxc_mapping_utilities.t_consolidated_info_1;

l_bld_block_info_id_outer hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_field_name_outer     varchar2(1000);
l_field_value_outer     varchar2(1000);
l_segment_outer 	  hxc_mapping_components.segment%TYPE;

l_bld_block_info_id_inner hxc_mapping_components.bld_blk_info_type_id%TYPE;
l_field_name_inner     varchar2(1000);
l_field_value_inner     varchar2(1000);
l_segment_inner 	 hxc_mapping_components.segment%TYPE;


l_query VARCHAR2(8000);

l_status_list varchar2(400);

l_status varchar2(1000);

l_installed varchar2(1) := 'N';

l_field_value varchar2(6000);

l_index Number;

l_index_inner Number;

l_cons_index Number;


TYPE MapExistsCur IS REF CURSOR;
map_cr   MapExistsCur;

CURSOR  csr_chk_otl_installed IS
SELECT  'Y'
FROM    fnd_product_installations pi
WHERE   pi.application_id = 809
AND     pi.status in ( 'S', 'I' );


BEGIN --
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.get_mappingvalue_sum';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;


-- chk to see if OTL is installed

t_consolidated_info.delete;

OPEN  csr_chk_otl_installed;

FETCH csr_chk_otl_installed INTO l_installed;

IF ( csr_chk_otl_installed%FOUND )
THEN


	if(p_field_name1 is not null) then

		get_mapping_value(p_bld_blk_info_type,p_field_name1,l_segment1,l_bld_blk_info_type_id);

	end if;


	if(p_field_name2 is not null) then

		if(p_bld_blk_info_type2 is not null) then

		get_mapping_value(p_bld_blk_info_type2,p_field_name2,l_segment2,l_bld_blk_info_type_id2);

		else

		get_mapping_value(p_bld_blk_info_type,p_field_name2,l_segment2,l_bld_blk_info_type_id2);
		end if;
	end if;



	if(p_field_name3 is not null) then

		get_mapping_value(p_bld_blk_info_type3,p_field_name3,l_segment3,l_bld_blk_info_type_id3);

	end if;

	if(p_field_name4 is not null) then

		get_mapping_value(p_bld_blk_info_type4,p_field_name4,l_segment4,l_bld_blk_info_type_id4);

	end if;


	if(p_field_name5 is not null) then

		get_mapping_value(p_bld_blk_info_type5,p_field_name5,l_segment5,l_bld_blk_info_type_id5);

	end if;



	if(p_field_name2 is not null) then
			if(t_consolidated_info.count>0) then
				l_cons_index:=t_consolidated_info.count+1;
			else
				l_cons_index:=1;
			end if;

		t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id2;
		t_consolidated_info(l_cons_index).field_name :=p_field_name2;
		t_consolidated_info(l_cons_index).field_value:=p_field_value2 ;
		t_consolidated_info(l_cons_index).segment:=l_segment2;

	end if;

	if(p_bld_blk_info_type3 is not null and p_field_name3 is not null) then
			if(t_consolidated_info.count>0) then
				l_cons_index:=t_consolidated_info.count+1;
			else
				l_cons_index:=1;
			end if;

		t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id3;
		t_consolidated_info(l_cons_index).field_name :=p_field_name3;
		t_consolidated_info(l_cons_index).field_value:=p_field_value3 ;
		t_consolidated_info(l_cons_index).segment:=l_segment3;

	end if;

	if(p_bld_blk_info_type4 is not null and p_field_name4 is not null) then
			if(t_consolidated_info.count>0) then
				l_cons_index:=t_consolidated_info.count+1;
			else
				l_cons_index:=1;
			end if;

		t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id4;
		t_consolidated_info(l_cons_index).field_name :=p_field_name4;
		t_consolidated_info(l_cons_index).field_value:=p_field_value4 ;
		t_consolidated_info(l_cons_index).segment:=l_segment4;

	end if;

	if(p_bld_blk_info_type5 is not null and p_field_name5 is not null) then
			if(t_consolidated_info.count>0) then
				l_cons_index:=t_consolidated_info.count+1;
			else
				l_cons_index:=1;
			end if;

		t_consolidated_info(l_cons_index).bld_blk_info_type_id:=l_bld_blk_info_type_id5;
		t_consolidated_info(l_cons_index).field_name :=p_field_name5;
		t_consolidated_info(l_cons_index).field_value:=p_field_value5 ;
		t_consolidated_info(l_cons_index).segment:=l_segment5;

	end if;




	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

	-- build dynamic SQL query

	l_query := '
	select sum(ta.'||l_segment1||')
	from   	hxc_time_attributes ta,
        	hxc_time_attribute_usages tau,
		hxc_time_building_blocks tbb
	where
    	        tbb.scope = :p_scope
    	AND     tbb.resource_id = :p_resource_id
	AND     tbb.object_version_number = (
			   SELECT MAX ( tbb1.object_version_number )
			   FROM   hxc_time_building_blocks tbb1
			   WHERE  tbb1.time_building_block_id = tbb.time_building_block_id )
	AND	tau.time_building_block_id  = tbb.time_building_block_id
	AND	tau.time_building_block_ovn = tbb.object_version_number
	AND 	tau.time_attribute_id       = ta.time_attribute_id
	AND     tbb.date_to                 = hr_general.end_of_time
	And     ta.bld_blk_info_type_id     = :l_bld_blk_info_type_id';


	 if g_debug then
	 	hr_utility.set_location('Processing '||l_proc, 30.01);
	 end if;
	l_index:=t_consolidated_info.first;

		loop exit when not t_consolidated_info.exists(l_index);


				l_bld_block_info_id_outer:=t_consolidated_info(l_index).bld_blk_info_type_id;
				l_field_name_outer:=t_consolidated_info(l_index).field_name;
				l_field_value_outer:=t_consolidated_info(l_index).field_value;
				l_segment_outer:=t_consolidated_info(l_index).segment;

			if(l_field_value_outer is not null) then

				l_field_value:= l_field_value||' AND EXISTS ( select 1 from hxc_time_attribute_usages tau2,
											hxc_time_attributes ta2
										where   tau2.time_building_block_id      = tbb.time_building_block_id
										AND 	tau2.time_building_block_ovn     = tbb.object_version_number
										AND     tau2.time_attribute_id           = ta2.time_attribute_id
										AND     ta2.bld_blk_info_type_id         = '||l_bld_block_info_id_outer||
										' AND     ta2.'||l_segment_outer||' = '''|| l_field_value_outer||'''' ;


			else


				l_field_value:= l_field_value||' AND EXISTS ( select 1 from hxc_time_attribute_usages tau2,
											hxc_time_attributes ta2
										where   tau2.time_building_block_id      = tbb.time_building_block_id
										AND 	tau2.time_building_block_ovn     = tbb.object_version_number
										AND     tau2.time_attribute_id           = ta2.time_attribute_id
										AND     ta2.bld_blk_info_type_id         = '||l_bld_block_info_id_outer||
										' AND     ta2.'||l_segment_outer||'		is null ';


			end if;

			 if g_debug then
			 	hr_utility.set_location('Processing '||l_proc, 30.02);
			 end if;

			        l_index_inner:=t_consolidated_info.next(l_index);


				loop exit when not t_consolidated_info.exists(l_index_inner);

				   if (l_bld_block_info_id_outer=t_consolidated_info(l_index_inner).bld_blk_info_type_id) then

					l_bld_block_info_id_inner:=t_consolidated_info(l_index_inner).bld_blk_info_type_id;
					l_field_name_inner:=t_consolidated_info(l_index_inner).field_name;
					l_field_value_inner:=t_consolidated_info(l_index_inner).field_value;
					l_segment_inner:=t_consolidated_info(l_index_inner).segment;

					if(l_field_value_inner is not null) then

					l_field_value:=l_field_value||' AND ta2.'||l_segment_inner||' = '''||l_field_value_inner||'''' ;

					else

						l_field_value:=l_field_value||' AND ta2.'||l_segment_inner||' is null ';

					end if;

					t_consolidated_info.delete(l_index_inner);

				   end if;


			         	l_index_inner:=t_consolidated_info.next(l_index_inner);

			        end loop;
			        l_field_value:=l_field_value||')';

				l_index:= t_consolidated_info.next(l_index);

	end loop;

		l_query:=l_query||l_field_value;

         if g_debug then
         	hr_utility.set_location('Processing '||l_proc, 30.1);
         end if;

	--let us add the status check
	if p_status = 'WORKING' then
	    l_status_list := '(''WORKING'''||','||'''SUBMITTED'''||','||'''APPROVED'')';
	elsif p_status = 'SUBMITTED' then
	    l_status_list := '(''SUBMITTED'''||','||'''APPROVED'')';
	elsif p_status = 'APPROVED' then
	    l_status_list := '(''APPROVED'')';
	end if;


        if g_debug then
        	hr_utility.set_location('Processing '||l_proc, 30.2);
        end if;
        if p_status in ('WORKING','SUBMITTED','APPROVED') then

		l_status := '
		  AND exists (
		   select ''Y''
		   from hxc_time_building_blocks daybb,
			hxc_time_building_blocks timebb,
                        hxc_timecard_summary time_status
		   where tbb.parent_building_block_id = daybb.time_building_block_id
		     and tbb.parent_building_block_ovn = daybb.object_version_number
		     and daybb.parent_building_block_id = timebb.time_building_block_id
		     and daybb.parent_building_block_ovn = timebb.object_version_number
                     and time_status.timecard_id  = timebb.time_building_block_id
                     and time_status.approval_status IN '||l_status_list||' ) ';

		l_query := l_query ||l_status;

	end if;


	if g_debug then
		hr_utility.trace(' ');
		hr_utility.trace('Now let us print the query');

		hr_utility.trace(substr(l_query,1,200));
		hr_utility.trace(substr(l_query,201,200));
		hr_utility.trace(substr(l_query,401,200));
		hr_utility.trace(substr(l_query,601,200));
		hr_utility.trace(substr(l_query,801,200));
		hr_utility.trace(substr(l_query,1001,200));
		hr_utility.trace(substr(l_query,1201,200));
		hr_utility.trace(substr(l_query,1401,200));
		hr_utility.trace(substr(l_query,1601,200));
		hr_utility.trace(substr(l_query,1801,200));
		hr_utility.trace(substr(l_query,2001,200));
		hr_utility.trace(substr(l_query,2201,200));
		hr_utility.trace(substr(l_query,2401,200));
		hr_utility.trace(substr(l_query,2601,200));
		hr_utility.trace(substr(l_query,2801,200));
		hr_utility.trace(substr(l_query,3001,200));
		hr_utility.trace(' ');

		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

	OPEN map_cr FOR l_query USING 'DETAIL', p_resource_id,l_bld_blk_info_type_id;

	FETCH map_cr INTO l_sum;

	CLOSE map_cr;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 70);
	end if;


END IF; -- IF ( csr_chk_otl_installed%FOUND )

CLOSE csr_chk_otl_installed;


RETURN l_sum;

EXCEPTION

  WHEN OTHERS then

    if g_debug then
    	hr_utility.trace('Error is '||substr(sqlerrm,1,200));
    end if;
    hr_utility.set_message(809, sqlerrm);
    hr_utility.raise_error;

END get_mappingvalue_sum;


end hxc_mapping_utilities;

/
