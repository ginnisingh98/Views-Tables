--------------------------------------------------------
--  DDL for Package Body HXC_TIME_ENTRY_RULES_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_ENTRY_RULES_UTILS_PKG" as
/* $Header: hxcterutl.pkb 120.15.12010000.8 2009/10/13 11:47:24 asrajago ship $ */
--
-- Package Variables
--

g_debug boolean := hr_utility.debug_enabled;

TYPE r_message_record IS RECORD ( name fnd_new_messages.message_name%TYPE,
                                  token_name varchar2(240),
                                  token_value varchar2(4000),
                                  extent varchar2(20) );
TYPE t_message_table IS TABLE OF r_message_record INDEX BY BINARY_INTEGER;



PROCEDURE get_timecard_info (
		p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info ) IS

l_proc	VARCHAR2(72);

l_tbb_index	BINARY_INTEGER;

deletedFlag boolean := true;

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'get_timecard_info';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

l_tbb_index := p_time_building_blocks.FIRST;

WHILE ( l_tbb_index IS NOT NULL )
LOOP

	IF p_time_building_blocks(l_tbb_index).SCOPE = 'TIMECARD'
	THEN
		if g_debug then
			hr_utility.trace('************* Timecard details *****************');
			hr_utility.trace('timecard bb id is '||to_char(p_time_building_blocks(l_tbb_index).time_building_block_id));
			hr_utility.trace('timecard ovn is '||to_char(p_time_building_blocks(l_tbb_index).object_version_number));
			hr_utility.trace('start time is '||to_char(p_time_building_blocks(l_tbb_index).start_time, 'dd-mon-yyyy hh24:mi:ss'));
			hr_utility.trace('stop time is ' ||to_char(p_time_building_blocks(l_tbb_index).stop_time,  'dd-mon-yyyy hh24:mi:ss'));
			hr_utility.trace('resource id is '||to_char(p_time_building_blocks(l_tbb_index).resource_id));
			hr_utility.trace('************************************************');
		end if;

		p_timecard_rec.start_date	:= p_time_building_blocks(l_tbb_index).start_time;
		p_timecard_rec.end_date	        := p_time_building_blocks(l_tbb_index).stop_time;
		p_timecard_rec.resource_id	:= p_time_building_blocks(l_tbb_index).resource_id;
		p_timecard_rec.timecard_bb_id   := p_time_building_blocks(l_tbb_index).time_building_block_id;
		p_timecard_rec.timecard_ovn     := p_time_building_blocks(l_tbb_index).object_version_number;
		p_timecard_rec.approval_status  := p_time_building_blocks(l_tbb_index).approval_status;

		-- GPM v115.32
		p_timecard_rec.new              := p_time_building_blocks(l_tbb_index).new;

		IF ( p_time_building_blocks(l_tbb_index).date_to = hr_general.end_of_time )
		THEN
			--p_timecard_rec.deleted := 'N';
			deletedFlag := false;
			EXIT;
--		ELSE
			--p_timecard_rec.deleted := 'Y';
		END IF;
--		EXIT;
	END IF;

l_tbb_index := p_time_building_blocks.NEXT(l_tbb_index);

END LOOP; -- get timecard info loop

if(deletedFlag)	then
	p_timecard_rec.deleted := 'Y';
else
	p_timecard_rec.deleted := 'N';
end if;


if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;

END get_timecard_info;


PROCEDURE get_timecard_info (
		p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info ) IS

l_proc	VARCHAR2(72);

l_att_index	BINARY_INTEGER;

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'get_timecard_info';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

get_timecard_info ( p_time_building_blocks => p_time_building_blocks
	,           p_timecard_rec         => p_timecard_rec );

l_att_index := p_time_attributes.FIRST;

WHILE ( l_att_index IS NOT NULL )
LOOP

	IF ( p_time_attributes(l_att_index).attribute_category = 'SECURITY' )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 30);
		end if;

		p_timecard_rec.bg_id := TO_NUMBER(p_time_attributes(l_att_index).attribute2);

	EXIT;

	END IF;

l_att_index := p_time_attributes.NEXT(l_att_index);

END LOOP;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;

END get_timecard_info;

PROCEDURE get_timecard_info (
		p_time_building_blocks  HXC_BLOCK_TABLE_TYPE
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info ) IS

l_blocks hxc_self_service_time_deposit.timecard_info;

BEGIN

l_blocks := hxc_timecard_block_utils.convert_to_dpwr_blocks(
			p_blocks => p_time_building_blocks );

get_timecard_info ( p_time_building_blocks => l_blocks
		,   p_timecard_rec         => p_timecard_rec );

END get_timecard_info;



PROCEDURE calc_timecard_periods (
		p_timecard_period_start	DATE
	,	p_timecard_period_end	DATE
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_duration_in_days	NUMBER
	,	p_periods_tab		IN OUT NOCOPY t_period ) IS

l_proc	VARCHAR2(72);

l_cnt 			BINARY_INTEGER := 1;
l_period_start_date	DATE;
l_period_end_date	DATE;

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'calc_timecard_periods';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

l_period_start_date	:= p_period_start_date;
l_period_end_date	:= p_period_end_date;

WHILE ( l_period_start_date <= p_timecard_period_end )
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;


IF ( l_period_start_date >= p_timecard_period_start AND
     TRUNC(l_period_end_date)   <= p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

	-- period completely within TCO

	p_periods_tab(l_cnt).period_start  := l_period_start_date;
	p_periods_tab(l_cnt).period_end	   := l_period_end_date;

	p_periods_tab(l_cnt).db_pre_period_start  := NULL;
	p_periods_tab(l_cnt).db_pre_period_end    := NULL;
	p_periods_tab(l_cnt).db_post_period_start := NULL;
	p_periods_tab(l_cnt).db_post_period_end   := NULL;

ELSIF ( l_period_start_date < p_timecard_period_start AND
        TRUNC(l_period_end_date)   <= p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

	-- period includes TC and stradles TCO start

	p_periods_tab(l_cnt).period_start  := p_timecard_period_start;
	p_periods_tab(l_cnt).period_end	   := l_period_end_date;

	p_periods_tab(l_cnt).db_pre_period_start := l_period_start_date;
	p_periods_tab(l_cnt).db_pre_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	p_periods_tab(l_cnt).db_post_period_start := NULL;
	p_periods_tab(l_cnt).db_post_period_end   := NULL;


-- Bug 7671493 (12.1.1) raised due to previous fix 7380862
-- Before 7380862, the following condition used to cover the fourth
-- condition also, and the fourth condition never worked.
-- Post 7380862, the case of period start date coinciding with the timecard start
-- date and period end date greater than the timecard end date condition would
-- never be checked -- this is the case of employees terminated mid period.
-- Changed '>' to '>='

ELSIF ( l_period_start_date >= p_timecard_period_start AND
	TRUNC(l_period_end_date)   > p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 50);
	end if;

	-- period includes TC and stradles TC end

	p_periods_tab(l_cnt).period_start := l_period_start_date;
	p_periods_tab(l_cnt).period_end	  :=
                    TO_DATE(TO_CHAR(p_timecard_period_end, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	p_periods_tab(l_cnt).db_pre_period_start := NULL;
	p_periods_tab(l_cnt).db_pre_period_end   := NULL;

	p_periods_tab(l_cnt).db_post_period_start := TRUNC(p_timecard_period_end) + 1;
	p_periods_tab(l_cnt).db_post_period_end   := l_period_end_date;


ELSIF ( l_period_start_date < p_timecard_period_start AND
	TRUNC(l_period_end_date)  > p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 60);
	end if;

	-- period completely stradles TCO

	p_periods_tab(l_cnt).period_start	:= p_timecard_period_start;
	p_periods_tab(l_cnt).period_end	:=
                    TO_DATE(TO_CHAR(p_timecard_period_end, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	p_periods_tab(l_cnt).db_pre_period_start := l_period_start_date;
	p_periods_tab(l_cnt).db_pre_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	p_periods_tab(l_cnt).db_post_period_start := TRUNC(p_timecard_period_end) + 1;
	p_periods_tab(l_cnt).db_post_period_end   := l_period_end_date;

END IF;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace(' ********** Periods ************** ');
	hr_utility.trace(' Actual TC period start is :'||TO_CHAR(p_timecard_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' Actual TC period end is   :'||TO_CHAR(p_timecard_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' TC period start is     :'||TO_CHAR(p_periods_tab(l_cnt).period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' TC period end is       :'||TO_CHAR(p_periods_tab(l_cnt).period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period start is :'||TO_CHAR(p_periods_tab(l_cnt).db_pre_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period end is   :'||TO_CHAR(p_periods_tab(l_cnt).db_pre_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period start is:'||TO_CHAR(p_periods_tab(l_cnt).db_post_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period end is  :'||TO_CHAR(p_periods_tab(l_cnt).db_post_period_end, 'DD-MON-YY HH24:MI:SS'));
end if;

l_period_start_date	:= l_period_start_date + p_duration_in_days;
l_period_end_date	:= l_period_end_date   + p_duration_in_days;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('start is '||to_char(l_period_start_date, 'dd-mon-yyyy hh24:mi:ss'));
	hr_utility.trace('end is '||to_char(l_period_end_date, 'dd-mon-yyyy hh24:mi:ss'));
	hr_utility.trace('');
end if;

l_cnt	:= l_cnt + 1;

END LOOP;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 70);
end if;

END calc_timecard_periods;

PROCEDURE calc_reference_periods (
		p_timecard_period_start	DATE
	,	p_timecard_period_end	DATE
	,	p_ref_period_start      DATE
	,	p_ref_period_end	DATE
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_duration_in_days	NUMBER
	,	p_periods_tab		IN OUT NOCOPY t_period ) IS

l_proc	VARCHAR2(72);

l_cnt 			BINARY_INTEGER := 1;

l_period_start_date	DATE;
l_period_end_date	DATE;

l_ref_period_start	DATE;
l_ref_period_end	DATE;

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'calc_reference_periods';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

l_period_start_date := p_period_start_date;
l_period_end_date   := p_period_end_date;

l_ref_period_start  := p_ref_period_start;
l_ref_period_end    := p_ref_period_end;

WHILE ( l_period_start_date <= p_timecard_period_end )
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

IF ( l_period_start_date        >= p_timecard_period_start AND
     TRUNC(l_period_end_date)   <= p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Entering '||l_proc, 30);
	end if;

	-- timecard period completely within TCO

	-- set reference period
	-- note reference period dates are always less than period start

	IF ( l_ref_period_end    > p_timecard_period_start AND
	     l_ref_period_start >= p_timecard_period_start )
	THEN

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 40);
		end if;

		-- ref period completely enclosed in TCO

		p_periods_tab(l_cnt).period_start	:= l_ref_period_start;

		p_periods_tab(l_cnt).db_ref_period_start := NULL;
		p_periods_tab(l_cnt).db_ref_period_end   := NULL;

	ELSIF ( TRUNC(l_ref_period_end) >= p_timecard_period_start AND
	        l_ref_period_start      < p_timecard_period_start )
	THEN

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 50);
		end if;

		-- ref period stradles start of TCO or end falls exactly on TC start

		p_periods_tab(l_cnt).period_start	:= p_timecard_period_start;

		p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
		p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	ELSE

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 70);
		end if;

		p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
		p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	END IF;


ELSIF ( l_period_start_date       < p_timecard_period_start AND
        TRUNC(l_period_end_date) <= p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Entering '||l_proc, 80);
	end if;

	-- period includes TC and stradles TCO start

	p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
	p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR(l_ref_period_end, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

ELSIF ( l_period_start_date     <= p_timecard_period_end AND
	TRUNC(l_period_end_date) > p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Entering '||l_proc, 90);
	end if;

	-- period includes TC and stradles TC end

	-- set reference period

	IF ( l_ref_period_end    > p_timecard_period_start AND
	     l_ref_period_start >= p_timecard_period_start )
	THEN

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 100);
		end if;

		-- reference period completely enclosed in TCO

		p_periods_tab(l_cnt).period_start	:= l_ref_period_start;

		p_periods_tab(l_cnt).db_ref_period_start := NULL;
		p_periods_tab(l_cnt).db_ref_period_end   := NULL;

	ELSIF ( TRUNC(l_ref_period_end) >= p_timecard_period_start AND
	        l_ref_period_start       < p_timecard_period_start )
	THEN

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 110);
		end if;

		-- ref period stradles start of TCO or end falls exactly on start of TCO

		p_periods_tab(l_cnt).period_start	:= p_timecard_period_start;

		p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
		p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	ELSE

		if g_debug then
			hr_utility.set_location('Entering '||l_proc, 130);
		end if;

		p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
		p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR((p_timecard_period_start-1), 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

	END IF;

ELSIF ( l_period_start_date < p_timecard_period_start AND
	l_period_end_date  > p_timecard_period_end )
THEN

	if g_debug then
		hr_utility.set_location('Entering '||l_proc, 140);
	end if;

	-- period completely stradles TCO
	-- reference period outside of TCO

	p_periods_tab(l_cnt).db_ref_period_start := l_ref_period_start;
	p_periods_tab(l_cnt).db_ref_period_end   :=
		TO_DATE(TO_CHAR(l_ref_period_end, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

END IF;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace(' ********** Periods ************** ');
	hr_utility.trace(' Actual TC period start is :'||TO_CHAR(p_timecard_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' Actual TC period end is   :'||TO_CHAR(p_timecard_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' TC period start is     :'||TO_CHAR(p_periods_tab(l_cnt).period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' TC period end is       :'||TO_CHAR(p_periods_tab(l_cnt).period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period start is :'||TO_CHAR(p_periods_tab(l_cnt).db_pre_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period end is   :'||TO_CHAR(p_periods_tab(l_cnt).db_pre_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period start is:'||TO_CHAR(p_periods_tab(l_cnt).db_post_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period end is  :'||TO_CHAR(p_periods_tab(l_cnt).db_post_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' ref period start is    :'||TO_CHAR(p_periods_tab(l_cnt).db_ref_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' ref period end is      :'||TO_CHAR(p_periods_tab(l_cnt).db_ref_period_end, 'DD-MON-YY HH24:MI:SS'));
end if;

l_period_start_date	:= l_period_start_date + p_duration_in_days;
l_period_end_date	:= l_period_end_date   + p_duration_in_days;

l_ref_period_start	:= l_ref_period_start + p_duration_in_days;
l_ref_period_end	:= l_ref_period_end + p_duration_in_days;

l_cnt	:= l_cnt + 1;

END LOOP;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 160);
end if;

END calc_reference_periods;


-- public function (Overloaded)
--   calc_timecard_hrs
--
-- description
--   calculates timecard hrs by traversing the self service time
--   deposit building block and attribute PL/SQL tables for a
--   specified date range.
--   Uses dynamic SQL to determine if the hours fall into the
--   time category specified by passing the name, id or setting
--   a global variable for the time_category_id

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info )
RETURN NUMBER IS

l_hours            NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;

BEGIN

l_hours := calc_timecard_hrs (
		p_hrs_period_start => p_hrs_period_start
	,	p_hrs_period_end   => p_hrs_period_end
	,	p_tco_bb	   => p_tco_bb
	,	p_tco_att	   => p_tco_att
	,	p_time_category_id => hxc_time_category_utils_pkg.g_time_category_id );

RETURN l_hours;

END calc_timecard_hrs;


-- public function
--   calc_timecard_hrs (Overloaded)
--
-- description
--   calculates timecard hrs by traversing the self service time
--   deposit building block and attribute PL/SQL tables for a
--   specified date range.
--   Uses dynamic SQL to determine if the hours fall into the
--   time category specified by passing the name, id or setting
--   a global variable for the time_category_id

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info
	,	p_time_category_name    VARCHAR2 )
RETURN NUMBER IS

l_hours            NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;

BEGIN

l_time_category_id := hxc_time_category_utils_pkg.get_time_category_id ( p_time_category_name => p_time_category_name );

l_hours := calc_timecard_hrs (
		p_hrs_period_start => p_hrs_period_start
	,	p_hrs_period_end   => p_hrs_period_end
	,	p_tco_bb	   => p_tco_bb
	,	p_tco_att	   => p_tco_att
	,	p_time_category_id => l_time_category_id );

RETURN l_hours;

END calc_timecard_hrs;


-- public function
--   calc_timecard_hrs (Overloaded)
--
-- description
--   New time category phase II function

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        HXC_BLOCK_TABLE_TYPE
	,	p_tco_att	        HXC_ATTRIBUTE_TABLE_TYPE
        ,       p_time_category_id      NUMBER )
RETURN NUMBER IS

l_proc	VARCHAR2(72);

l_timecard_hrs NUMBER;

BEGIN -- calc_timecard_hrs

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'calc_timecard_hrs';
	hr_utility.trace('p hrs period start is :'||to_char(p_hrs_period_start, 'DD-MON-YYYY HH24:MI:SS'));
	hr_utility.trace('p hrs period end is :'||to_char(p_hrs_period_end, 'DD-MON-YYYY HH24:MI:SS'));
end if;

IF ( p_time_category_id IS NOT NULL )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 15);
	end if;

        hxc_time_category_utils_pkg.initialise_time_category (
                        p_time_category_id => p_time_category_id
               ,        p_tco_att          => p_tco_att );

	hxc_time_category_utils_pkg.sum_tc_bb_ok_hrs (
                             p_tc_bb_ok_string   => hxc_time_category_utils_pkg.g_tc_bb_ok_string
                           , p_hrs               => l_timecard_hrs
                           , p_period_start      => p_hrs_period_start
                           , p_period_end        => p_hrs_period_end );

ELSE

	-- no time category set this sum all hours on the timecard regardless

	hxc_time_category_utils_pkg.sum_tc_bb_ok_hrs (
                             p_tc_bb_ok_string   => NULL
                           , p_hrs               => l_timecard_hrs
                           , p_period_start      => p_hrs_period_start
                           , p_period_end        => p_hrs_period_end );

END IF;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace(' TC hours are '||TO_CHAR(l_timecard_hrs));
	hr_utility.trace('');
end if;

RETURN l_timecard_hrs;

exception when others then

if g_debug then
	hr_utility.trace('In exception ....');
	hr_utility.trace(SUBSTR(SQLERRM,1 ,80));
	hr_utility.trace(SUBSTR(SQLERRM,81, 160));
end if;

raise;

END calc_timecard_hrs;



-- public function
--   calc_timecard_hrs (Overloaded)
--
-- description
--   calculates timecard hrs by traversing the self service time
--   deposit building block and attribute PL/SQL tables for a
--   specified date range.
--   Uses dynamic SQL to determine if the hours fall into the
--   time category specified by passing the name, id or setting
--   a global variable for the time_category_id

-- THIS FUNCTION IS FOR BACKWARD COMPATIBILTY ONLY WITH TIME
-- CATEGORIES PHASE II

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info
        ,       p_time_category_id      NUMBER )
RETURN NUMBER IS

l_proc	VARCHAR2(72);

-- for backward compatibility

l_tco_bb_dummy  HXC_BLOCK_TABLE_TYPE;
l_tco_att_dummy HXC_ATTRIBUTE_TABLE_TYPE;

l_hrs NUMBER;

BEGIN -- calc_timecard_hrs

g_debug := hr_utility.debug_enabled;

l_hrs := calc_timecard_hrs (
		p_hrs_period_start	=> p_hrs_period_start
	,	p_hrs_period_end	=> p_hrs_period_end
	,	p_tco_bb	        => l_tco_bb_dummy
	,	p_tco_att	        => l_tco_att_dummy
        ,       p_time_category_id      => p_time_category_id );

if g_debug then
	l_proc := g_package||'calc_timecard_hrs';
	hr_utility.trace('');
	hr_utility.trace(' TC hours are '||TO_CHAR(l_hrs));
	hr_utility.trace('');
end if;

RETURN l_hrs;

exception when others then

if g_debug then
	hr_utility.trace(SUBSTR(SQLERRM,1 ,80));
	hr_utility.trace(SUBSTR(SQLERRM,81, 160));
end if;

raise;

END calc_timecard_hrs;




-- public procedure
--   add_error_to_table
--
-- description
--   adds error to the TCO message stack

PROCEDURE add_error_to_table (
		p_message_table	in out nocopy HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE
	,	p_message_name  in     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
	,	p_message_token in     VARCHAR2
	,	p_message_level in     VARCHAR2
        ,	p_message_field in     VARCHAR2
	,	p_application_short_name IN VARCHAR2 default 'HXC'
	,	p_timecard_bb_id     in     NUMBER
	,	p_time_attribute_id  in     NUMBER
        ,       p_timecard_bb_ovn    in     NUMBER default null
        ,       p_time_attribute_ovn in     NUMBER default null
        ,       p_message_extent     in   VARCHAR2 default null) is    --Bug#2873563

l_last_index BINARY_INTEGER;

l_proc	VARCHAR2(72);

l_tbb_ovn number(9);

l_message_name FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
l_message_token varchar2(4000);

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'add_error_to_table';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

l_tbb_ovn := p_timecard_bb_ovn+1;

l_last_index := NVL(p_message_table.last,0);

if g_debug then
	hr_utility.trace('index is '||to_char(l_last_index));
end if;

l_message_token := SUBSTR(p_message_token,1,4000);

IF ( p_message_name = 'EXCEPTION' )
THEN

	hr_message.provide_error;
        l_message_name := hr_message.last_message_name;

	IF ( l_message_name IS NULL )
	THEN
                -- Bug 3036930
		l_message_name := 'HXC_HXT_DEP_VAL_ORAERR';
		l_message_token := substr('ERROR&' || SQLERRM,1,4000);
	END IF;

ELSE

	l_message_name := p_message_name;

END IF;

p_message_table(l_last_index+1).message_name := l_message_name;
p_message_table(l_last_index+1).message_level := p_message_level;
p_message_table(l_last_index+1).message_field := p_message_field;
p_message_table(l_last_index+1).message_tokens:= l_message_token;
p_message_table(l_last_index+1).application_short_name := p_application_short_name;
p_message_table(l_last_index+1).time_building_block_id  := p_timecard_bb_id;
p_message_table(l_last_index+1).time_building_block_ovn := l_tbb_ovn;
p_message_table(l_last_index+1).time_attribute_id  := p_time_attribute_id;
p_message_table(l_last_index+1).time_attribute_ovn := p_time_attribute_ovn;
p_message_table(l_last_index+1).message_extent := p_message_extent;	--Bug#2873563

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;

END add_error_to_table;


-- public procedure
--   execute_time_entry_rules
--
-- description
--   executes a given time entry rule called from the self service time
--   deposit API based on resources preference time entry rule group

PROCEDURE execute_time_entry_rules (
		p_operation		VARCHAR2
	,	p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
	,	p_messages	        IN OUT nocopy hxc_self_service_time_deposit.message_table
        ,       p_resubmit              VARCHAR2
        ,       p_blocks                hxc_block_table_type
        ,       p_attributes            hxc_attribute_table_type ) IS

l_proc	VARCHAR2(72);

l_submission_date	DATE;

l_timecard_info_rec r_timecard_info;
l_terg_id           hxc_pref_hierarchies.attribute1%TYPE;
l_rules_evl         hxc_pref_hierarchies.attribute1%TYPE;

l_alter_session VARCHAR2(1000);
l_run_id number;

l_pref_table  hxc_preference_evaluation.t_pref_table;

p_master_pref_table  hxc_preference_evaluation.t_pref_table;

cursor gaz_time_sql is
select time_category_id
from hxc_time_Categories
where time_category_name = 'GARRYS TIME SQL TEST';

CURSOR  csr_get_first_asg_date ( p_resource_id NUMBER
                               , p_tc_start DATE
                               , p_tc_end   DATE ) IS
SELECT	MAX( asg.effective_start_date)
,       asg.assignment_id
FROM	per_assignments_f asg
WHERE	asg.person_id	= p_resource_id
AND	asg.primary_flag = 'Y'
AND	asg.assignment_type in ('E','C')
AND     asg.effective_start_date <= TRUNC(p_tc_end)
AND     asg.effective_end_date   >= TRUNC(p_tc_start)
GROUP BY asg.assignment_id;


PROCEDURE set_global_asg_info ( p_resource_id  NUMBER
	                      , p_start_date   DATE
	                      , p_end_date     DATE ) IS

l_assignment_id   per_all_assignments_f.assignment_id%TYPE;

BEGIN

OPEN  csr_get_first_asg_date ( p_resource_id
                             , p_start_date
                             , p_end_date );

FETCH csr_get_first_asg_date INTO l_submission_date, l_assignment_id;

CLOSE csr_get_first_asg_date;

l_submission_date := GREATEST( l_submission_date, p_start_date );

hxc_time_entry_rules_utils_pkg.g_assignment_info(p_resource_id).assignment_id
  := l_assignment_id;
hxc_time_entry_rules_utils_pkg.g_assignment_info(p_resource_id).submission_date
  := l_submission_date;
hxc_time_entry_rules_utils_pkg.g_assignment_info(p_resource_id).start_date
  := p_start_date;
hxc_time_entry_rules_utils_pkg.g_assignment_info(p_resource_id).end_date
  := p_end_date;

END set_global_asg_info;



-- private procedure
--   execute_formula
--
-- description
--   executes and evaluates each WTD rule

PROCEDURE execute_formula (	p_formula_name	varchar2
			,	p_message_table	IN OUT NOCOPY hxc_self_service_time_deposit.message_table
			,       p_message_level varchar2
			,	p_rule_record	hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
			,	p_tco_bb	hxc_self_service_time_deposit.timecard_info
			,	p_tco_att       hxc_self_service_time_deposit.building_block_attribute_info
                        ,       p_timecard_info r_timecard_info ) IS

l_proc	VARCHAR2(72);

l_param_rec		hxc_ff_dict.r_param;

l_period_type		hxc_recurring_periods.period_type%TYPE;
l_period_id		hxc_recurring_periods.recurring_period_id%TYPE;
l_reference_period	NUMBER(10);
l_consider_zero_hours   VARCHAR2(10) := 'Y'; -- fault tolerant thus larger than 1 char

l_period_tab	t_period;

l_duration_in_days	hxc_recurring_periods.duration_in_days%TYPE;
l_period_start		DATE;
l_period_start_date	DATE;
l_period_end_date	DATE;
l_ref_period_start	DATE;
l_ref_period_end	DATE;

l_timecard_hrs		NUMBER := 0;

l_outputs	ff_exec.outputs_t;
l_result	VARCHAR2(1);

l_message_table t_message_table;
l_message_count PLS_INTEGER;

l_token_string VARCHAR2(4000) := NULL;

l_cnt BINARY_INTEGER;

l_new_index BINARY_INTEGER;

PROCEDURE process_message (
		p_output_name   IN VARCHAR2
        ,       p_output_value  IN VARCHAR2
        ,       p_output_number IN NUMBER
        ,       p_message_table IN OUT NOCOPY t_message_table
	,	p_rule_record   IN hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype ) IS

l_index BINARY_INTEGER;

BEGIN

l_index := p_output_number;

IF (   p_output_name = 'MESSAGE' AND
     ( p_output_value = 'HXC_WTD_PERIOD_MAXIMUM' OR p_output_value = 'HXC_TER_VIOLATION' ) )
THEN

	p_message_table(l_index).name        := p_output_value;
	p_message_table(l_index).token_name  := 'TER';
	p_message_table(l_index).token_value := p_rule_record.ter_message_name;

	IF ( p_message_table(l_index).extent IS NULL )
	THEN
		p_message_table(l_index).extent := hxc_timecard.c_blk_children_extent;

	END IF;

ELSIF ( p_output_name = 'MESSAGE' )
THEN

	p_message_table(l_index).name := p_output_value;

	IF ( p_message_table(l_index).extent IS NULL )
	THEN
		p_message_table(l_index).extent := hxc_timecard.c_blk_children_extent;

	END IF;

ELSIF ( p_output_name = 'TOKEN_VALUE' )
THEN

	p_message_table(l_index).token_value := p_output_value;

ELSIF ( p_output_name = 'TOKEN_NAME' )
THEN

	p_message_table(l_index).token_name := UPPER(p_output_Value);

END IF;

END process_message;

FUNCTION check_commit ( p_message_table IN OUT NOCOPY hxc_self_service_time_deposit.message_table
                       ,p_timecard_info r_timecard_info ) RETURN BOOLEAN IS

CURSOR chk_global_table IS
select 1
from   hxc_tmp_blks;


l_dummy number;

BEGIN



IF ( p_timecard_info.deleted = 'N' )
THEN

	if g_debug then
		hr_utility.trace('Entering check_commit');
	end if;

	OPEN  chk_global_table;
	FETCH chk_global_table INTO l_dummy;

	IF ( chk_global_table%NOTFOUND )
	THEN

		CLOSE chk_global_table;

		if g_debug then
			hr_utility.trace('hxc tmp bld blks empty');
		end if;

		add_error_to_table (
			p_message_table	=> p_message_table
		,	p_message_name	=> 'HXC_TER_NO_COMMIT'
		,	p_message_token	=> NULL
		,	p_message_level	=> 'ERROR'
		,	p_message_field		=> NULL
		,	p_timecard_bb_id	=> NULL
		,	p_time_attribute_id	=> NULL
	        ,       p_timecard_bb_ovn       => NULL
	        ,       p_time_attribute_ovn    => NULL
	        ,       p_message_extent        => hxc_timecard.c_blk_children_extent );


		RETURN FALSE;

	ELSE

		CLOSE chk_global_table;

		if g_debug then
			hr_utility.trace('hxc tmp bld blks populated');
		end if;

		RETURN TRUE;

	END IF;

ELSE

	RETURN TRUE;

END IF; -- p_timecard_info.delete

END check_commit;




BEGIN -- execute_formula



/**********************************************
*        Execute Formula                      *
**********************************************/

if g_debug then
	l_proc := g_package||'execute_formula';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

hxc_ff_dict.decode_formula_segments (
		p_formula_name	      => p_formula_name
	,       p_rule_rec            => p_rule_record
	,	p_param_rec	      => l_param_rec
	,	p_period_value        => l_period_id
	,	p_reference_value     => l_reference_period
        ,       p_consider_zero_hours => l_consider_zero_hours );


if g_debug then
	hr_utility.trace(' ************* Param values are.... ************ ');
	hr_utility.trace('');
	hr_utility.trace(' Rule name is '||p_rule_record.name);
	hr_utility.trace('');
	hr_utility.trace(' Period Id is '||to_char(l_period_id));
	hr_utility.trace(' Reference Period is '||to_char(l_reference_period));
	hr_utility.trace(' Period Max is '||l_param_rec.param2_value);


	hr_utility.set_location('Processing '||l_proc, 20);
end if;

-- if either PERIOD or REFERENCE_PERIOD specified.

IF ( l_period_id IS NOT NULL OR l_reference_period IS NOT NULL )
THEN

-- we are looking for either of the inputs availabe to the seeded formulae

IF ( l_period_id IS NOT NULL )
THEN

OPEN  csr_get_period_info ( p_recurring_period_id => l_period_id );
FETCH csr_get_period_info INTO l_period_type, l_duration_in_days, l_period_start;
CLOSE csr_get_period_info;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('*********** Period Info ************');
	hr_utility.trace('period type is '||l_period_type);
	hr_utility.trace('duration in days is  '||TO_CHAR(l_duration_in_days));
	hr_utility.trace('period start date is '||TO_CHAR(l_period_start,'DD-MON-YY HH24:MI:SS'));
end if;


IF ( l_duration_in_days IS NOT NULL )
THEN

   l_period_start_date := l_period_start +
        (l_duration_in_days *
         FLOOR(((p_timecard_info.start_date - l_period_start)/l_duration_in_days)));

   l_period_end_date := l_period_start_date + l_duration_in_days - 1;

ELSE

   -- Call application specific function to generate the period
   -- start and end dates from the period type.

   hr_generic_util.get_period_dates
            (p_rec_period_start_date => l_period_start
            ,p_period_type           => l_period_type
            ,p_current_date          => p_timecard_info.start_date
            ,p_period_start_date     => l_period_start_date
            ,p_period_end_date       => l_period_end_date);

   l_duration_in_days := ( l_period_end_date - l_period_start_date ) + 1;

END IF;

-- now add time component to l_period_end

   l_period_end_date := TO_DATE(TO_CHAR(l_period_end_date, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

if g_debug then
	Hr_utility.trace('');
	hr_utility.trace('*********** Period Start and End ************');
	hr_utility.trace('period start date is '||TO_CHAR(l_period_start_date,'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('period end date is   '||TO_CHAR(l_period_end_date,'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('duration in days is  '||TO_CHAR(l_duration_in_days));
end if;

-- now build up table of time entry rule periods that the timecard
-- may span

calc_timecard_periods (
		p_timecard_period_start	=> p_timecard_info.start_date
	,	p_timecard_period_end	=> p_timecard_info.end_date
	,	p_period_start_date	=> l_period_start_date
	,	p_period_end_date	=> l_period_end_date
	,	p_duration_in_days	=> l_duration_in_days
	,	p_periods_tab		=> l_period_tab );

END IF; -- ( l_period_id IS NOT NULL )


-- now check to see if the formula uses Reference Period

IF ( l_reference_period IS NOT NULL )
THEN

/*******************************
*   Reference Period Stuff     *
*******************************/

-- now need to work out the reference period start date in case any of those
-- hours are included on the timecard object. If they are then this will affect
-- the l_period_start_date

-- no need to calculate reference period if reference period is less than or equal to
-- the actual period

IF ( l_reference_period > l_duration_in_days )
THEN

l_ref_period_start := ( l_period_start_date  - ( l_reference_period - l_duration_in_days ) );
l_ref_period_end   := l_period_start_date - 1;

calc_reference_periods (
		p_timecard_period_start	=> p_timecard_info.start_date
	,	p_timecard_period_end	=> p_timecard_info.end_date
        ,       p_ref_period_start      => l_ref_period_start
        ,       p_ref_period_end        => l_ref_period_end
	,	p_period_start_date	=> l_period_start_date
	,	p_period_end_date	=> l_period_end_date
	,	p_duration_in_days	=> l_duration_in_days
	,	p_periods_tab		=> l_period_tab );

END IF;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('********** Original reference period ************');
	hr_utility.trace('ref period start is   '||TO_CHAR(l_ref_period_start,'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('ref period end is     '||TO_CHAR(l_ref_period_end,'DD-MON-YY HH24:MI:SS'));
end if;

END IF; -- ( l_reference_period IS NOT NULL )

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

ELSE -- ( l_period and l_ref_period are NULL )

-- set the start date and end date equal to the TC start and end date

	l_period_tab(1).period_start      := p_timecard_info.start_date;
	l_period_tab(1).period_end	   :=
			TO_DATE(TO_CHAR(p_timecard_info.end_date,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

 	l_period_tab(1).db_pre_period_start  := NULL;
	l_period_tab(1).db_pre_period_end    := NULL;
	l_period_tab(1).db_post_period_start := NULL;
	l_period_tab(1).db_post_period_end   := NULL;
	l_period_tab(1).db_ref_period_start  := NULL;
	l_period_tab(1).db_ref_period_end    := NULL;

END IF; --  ( l_period_id IS NOT NULL OR l_reference_period_id )

if g_debug then
	hr_utility.trace('*********************************************** ******');
	hr_utility.trace('****** TIME CARD is                             ******');
	hr_utility.trace('*********************************************** ******');
end if;

l_new_index := p_tco_bb.FIRST;

WHILE ( l_new_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('index is    '||to_char(l_new_index));
	hr_utility.trace('scope is    '||p_tco_bb(l_new_index).scope);
	hr_utility.trace('bb id       '||to_char(p_tco_bb(l_new_index).time_building_block_id));
	hr_utility.trace('parent bb id '||to_char(p_tco_bb(l_new_index).parent_building_block_id));
	hr_utility.trace('start       '||to_char(p_tco_bb(l_new_index).start_time, 'dd-mon-yy'));
	hr_utility.trace('measure     '||to_char(p_tco_bb(l_new_index).measure));
	hr_utility.trace('');
end if;

l_new_index := p_tco_bb.NEXT(l_new_index);

END LOOP;



-- now loop through the table of periods and calc hrs and execute formula

FOR p IN l_period_tab.FIRST .. l_period_tab.LAST
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;

IF ( hxc_time_entry_rules_utils_pkg.return_archived_status(l_period_tab(p)) = false )
THEN

-- check to see if any time entry rule has issued a commit i.e. the global tmp tables
-- are empty. Stop processing of remaining time entry rules

IF ( NOT check_commit ( p_messages, p_timecard_info ) )
THEN

	if g_debug then
		hr_utility.trace('Exiting period loop - check_commit');
	end if;
	EXIT;

END IF;

l_timecard_hrs := 0;

l_timecard_hrs := calc_timecard_hrs (
		p_hrs_period_start => l_period_tab(p).period_start
	,	p_hrs_period_end   => l_period_tab(p).period_end
	,	p_tco_bb           => p_tco_bb
	,	p_tco_att          => p_tco_att );

 	if g_debug then
 		hr_utility.trace('TER INC PTO plan id is '||hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id);
 	end if;

 	IF ( hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id IS NOT NULL )
 	THEN
 		-- calc incrementing PTO time category hours

 	l_timecard_hrs := l_timecard_hrs - calc_timecard_hrs (
 			p_hrs_period_start => l_period_tab(p).period_start
 		,	p_hrs_period_end   => l_period_tab(p).period_end
 		,	p_tco_bb           => p_tco_bb
 		,	p_tco_att          => p_tco_att
 	        ,       p_time_category_id => hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id );

 	END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

-- now call the formula

   if g_debug then
   	hr_utility.trace('consider zero hours is '||l_consider_zero_hours);
   end if;

    IF ( l_consider_zero_hours = 'Y' OR ( l_consider_zero_hours = 'N' AND l_timecard_hrs > 0 ) )
    THEN

        if g_debug then
        	hr_utility.trace('Calling ff dict . formula');
        end if;

	l_outputs := hxc_ff_dict.formula (
			p_formula_id		=> p_rule_record.formula_id
		,	p_resource_id		=> p_timecard_info.resource_id
		,	p_submission_date	=> l_submission_date
		,	p_ss_timecard_hours	=> l_timecard_hrs
		,       p_period_start_date     => l_period_tab(p).period_start
		,       p_period_end_date       => l_period_tab(p).period_end
		,	p_db_pre_period_start	=> l_period_tab(p).db_pre_period_start
		,	p_db_pre_period_end	=> l_period_tab(p).db_pre_period_end
		,	p_db_post_period_start	=> l_period_tab(p).db_post_period_start
		,	p_db_post_period_end	=> l_period_tab(p).db_post_period_end
		,	p_db_ref_period_start	=> l_period_tab(p).db_ref_period_start
		,	p_db_ref_period_end	=> l_period_tab(p).db_ref_period_end
		,	p_duration_in_days	=> l_duration_in_days
		,	p_param_rec		=> l_param_rec );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

	l_message_table.DELETE;

        if g_debug then
        	hr_utility.trace('l_outputs.COUNT = '||l_outputs.COUNT);
        end if;

	IF (l_outputs.COUNT > 0) THEN   -- Bug 8875292
  	  FOR l_count IN l_outputs.FIRST .. l_outputs.LAST
	  LOOP

		IF ( l_outputs(l_count).name = 'RULE_STATUS' )
		THEN

		      l_result := l_outputs(l_count).value;

		-- since approval formulas can potentially also be used
		-- in time entry rules translate the approval return
		-- value to a value the time entry rule code can
		-- understand. TO_APPROVE=Y is an exception in the
		-- approval world...

		-- GPaytonM 115.12

		ELSIF ( l_outputs(l_count).name = 'TO_APPROVE' )
		THEN

			IF ( l_outputs(l_count).value = 'Y' )
			THEN
				l_result := 'E';
			ELSE
				l_result := 'S';
			END IF;

		ELSIF ( l_outputs(l_count).name like 'MESSAGE%' )
		THEN

			l_cnt := SUBSTR(l_outputs(l_count).name, LENGTH('MESSAGE')+1);

			process_message (
                                        p_output_name   => 'MESSAGE'
				,	p_output_value  => l_outputs(l_count).value
                                ,       p_output_number => l_cnt
				,	p_message_table => l_message_table
				,	p_rule_record   => p_rule_record );

		ELSIF ( l_outputs(l_count).name like 'TOKEN_VALUE%' )
		THEN

			l_cnt := SUBSTR(l_outputs(l_count).name, LENGTH('TOKEN_VALUE')+1);

			process_message (
                                        p_output_name   => 'TOKEN_VALUE'
				,	p_output_value  => l_outputs(l_count).value
                                ,       p_output_number => l_cnt
				,	p_message_table => l_message_table
				,	p_rule_record   => p_rule_record );

		ELSIF ( l_outputs(l_count).name like 'TOKEN_NAME%' )
		THEN

			l_cnt := SUBSTR(l_outputs(l_count).name, LENGTH('TOKEN_NAME')+1);

			process_message (
                                        p_output_name   => 'TOKEN_NAME'
				,	p_output_value  => l_outputs(l_count).value
                                ,       p_output_number => l_cnt
				,	p_message_table => l_message_table
				,	p_rule_record   => p_rule_record );

		END IF;

	  END LOOP; -- formula outputs loop
	END IF;     -- Bug 8875292

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

	-- populate message table

	-- GPM v115.4

	IF ( ( l_result = 'E' ) AND ( l_message_table.COUNT <> 0 ) )
	THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 80);
		end if;

		l_message_count := l_message_table.FIRST;

		WHILE l_message_count IS NOT NULL
		LOOP

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 90);
			end if;

			IF ( l_message_table(l_message_count).name IS NOT NULL )
			THEN


				IF ( l_message_table(l_message_count).token_name is not null )
				THEN
					l_token_string := SUBSTR(UPPER(l_message_table(l_message_count).token_name)
                                                       ||'&'|| l_message_table(l_message_count).token_value ,1,4000);
				END IF;

				add_error_to_table (
					p_message_table	=> p_message_table
				,	p_message_name	=> l_message_table(l_message_count).name
				,	p_message_token	=> l_token_string
				,	p_message_level	=> p_message_level
				,	p_message_field		=> NULL
				,	p_timecard_bb_id	=> p_timecard_info.timecard_bb_id
				,	p_time_attribute_id	=> NULL
                                ,       p_timecard_bb_ovn       => p_timecard_info.timecard_ovn
                                ,       p_time_attribute_ovn    => NULL
                                ,       p_message_extent =>l_message_table(l_message_count).extent);   --Bug#2873563
			END IF;

		l_message_count := l_message_table.NEXT(l_message_count);

		END LOOP;

		l_message_table.DELETE; ----Bug#3090409
	END IF;

   END IF; -- l_consider_zero_hours check

else

	add_error_to_table (
			p_message_table	=> p_message_table
		       ,p_message_name	=> 'HXC_ARCHIVE_TER_ERROR'
		       ,p_message_token	=> 'TER_NAME&'||hxc_time_entry_rules_utils_pkg.g_ter_record.ter_message_name
		       ,p_message_level	=> 'ERROR'
		       ,p_message_field	=> NULL
		       ,p_timecard_bb_id=> NULL
		       ,p_time_attribute_id=> NULL
                       ,p_timecard_bb_ovn => NULL
                       ,p_time_attribute_ovn=> NULL
                       ,p_message_extent =>hxc_timecard.c_blk_children_extent);

 end if; -- hxc_time_entry_rules_utils_pkg.return_archived_status(l_period_tab(p)) = false )


if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

END LOOP; -- t_periods

if g_debug then
	hr_utility.trace('After period loop');
end if;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 110);
end if;

-- reset variables

l_period_tab.delete;

END execute_formula;


PROCEDURE check_time_overlaps
   (p_time_building_blocks IN hxc_self_service_time_deposit.timecard_info
   ,p_messages         IN OUT nocopy hxc_self_service_time_deposit.message_table) IS

l_bb_id        NUMBER;
l_bb_id_detail NUMBER;
l_type         VARCHAR2(30);
l_type_detail  VARCHAR2(30);
l_start_time   DATE;
l_start_detail DATE;
l_stop_time    DATE;
l_stop_detail  DATE;
l_scope        VARCHAR2(30);
l_scope_detail VARCHAR2(30);
l_date_to      DATE;
l_date_to_detail DATE;
-- vars for used for detecting potential db overlaps.
l_start_day_period DATE;
l_end_day_period DATE;
l_earliest_tc  DATE;
l_latest_tc    DATE;
l_resource_id  NUMBER;
l_cnt  NUMBER;
l_detail  NUMBER;
l_tc_db_overlap BOOLEAN;

l_detail_ovn  number;	--added for bug 2796204

l_timecardid  number;   --added for bug 2796204
l_timecardovn  number;  --added for bug 2796204


-- Start new code for Bug 2889097

TYPE t_left_overlap_row IS RECORD
( earliest_tc DATE,
  detail_id NUMBER,
  detail_ovn NUMBER);

TYPE t_left_overlap_t IS TABLE OF
     t_left_overlap_row
INDEX BY BINARY_INTEGER;

l_left_overlap t_left_overlap_t;

l_detail_count number;

l_detailid_right number;
l_detailovn_right number;

-- End new code for Bug 2889097

-- Modified for Bug 8281720
/*
  Modified the cursor to take care of overlapping of timecard with another timecard period for the
  below scenario.

  1. Create TEMPLATE with Start time on LAST day 18:00 and stop time at 07:20
     on the last day of the week.
  2. DO NOT create a timecard for the current week.
  3. Create timecard (without template) for following week with Start time on
     FIRST day 06:00 and stop time at 18:00 on the FIRST day of the week.

*/
cursor range_details_of_day(p_day_date in DATE,p_resource_id in NUMBER)
IS
select  /*+ ORDERED */
tbbdet.start_time, tbbdet.stop_time
from hxc_time_building_blocks tbbdet,
     hxc_time_building_blocks tbbday,
     hxc_time_building_blocks tbbtc
where
     tbbtc.scope     = 'TIMECARD'
and  tbbdet.scope    = 'DETAIL'
and  tbbdet.type     = 'RANGE'
and  tbbday.scope    = 'DAY'
and  tbbtc.time_building_block_id        = tbbday.parent_building_block_id
and  tbbtc.object_version_number         = tbbday.parent_building_block_ovn
and  tbbdet.parent_building_block_id     = tbbday.time_building_block_id
and  tbbdet.parent_building_block_ovn    = tbbday.object_version_number
and  trunc(tbbday.start_time)		 = trunc(p_day_date)
and  tbbdet.resource_id 		 = l_resource_id
and  tbbday.resource_id 		 = l_resource_id
and  tbbtc.resource_id 			 = l_resource_id
and  tbbdet.date_to 			 = hr_general.end_of_time;



BEGIN


l_earliest_tc := hr_general.end_of_time;

l_latest_tc := hr_general.start_of_time;

l_timecardid:=null;	--added for bug 2796204
l_timecardovn:=null;	--added for bug 2796204

-- Start new code for Bug 2889097

l_detail_count := 0;

l_detailid_right := NULL;

l_detailovn_right := NULL;

-- End new code for Bug 2889097

if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECK_TIME_OVERLAPS',
               'Number of BBs '||p_time_building_blocks.count);
end if;

l_cnt := p_time_building_blocks.first ;
LOOP
   EXIT WHEN NOT p_time_building_blocks.EXISTS(l_cnt);

   l_bb_id      := p_time_building_blocks(l_cnt).TIME_BUILDING_BLOCK_ID;
   l_type       := p_time_building_blocks(l_cnt).TYPE;
   l_start_time := p_time_building_blocks(l_cnt).START_TIME;
   l_stop_time  := p_time_building_blocks(l_cnt).STOP_TIME;
   l_scope      := p_time_building_blocks(l_cnt).SCOPE;
   l_resource_id := p_time_building_blocks(l_cnt).RESOURCE_ID;
   l_date_to    := p_time_building_blocks(l_cnt).DATE_TO;

   -- Record the period start / end
   IF (l_scope = 'TIMECARD') THEN
     l_timecardid :=p_time_building_blocks(l_cnt).TIME_BUILDING_BLOCK_ID;	--added for bug 2796204
     l_timecardovn :=p_time_building_blocks(l_cnt).object_version_number;	--added for bug 2796204
     l_start_day_period := l_start_time;
     l_end_day_period := l_stop_time;
   END IF;

   if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECK_TIME_OVERLAPS',
               'Outer Loop BB_ID '||l_bb_id);
   end if;
   --
   -- Check for Overlap Time for DETAIL blocks of type RANGE and start_time
   -- and stop_time not null and make sure they are not end-dated!
   --
   IF (l_scope = 'DETAIL' AND l_type  = 'RANGE' AND
       l_start_time is NOT NULL AND l_stop_time  is NOT NULL AND
       l_date_to = hr_general.end_of_time   ) THEN

     --
     if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Outer is a DETAIL RANGE');
     end if;

     -- Keep track of earliest / latest building block start / stop times

-- Start commented code for Bug 2889097
--     IF( l_start_time < l_earliest_tc) THEN
-- End commented code for Bug 2889097

-- Start new code for Bug 2889097
-- Trap all the Timecards as on earliest day of timecard period.
       IF( TRUNC(l_start_time) <= TRUNC(l_earliest_tc) ) THEN
-- End new code for Bug 2889097
       l_earliest_tc := l_start_time;

-- Start new code for Bug 2889097
       l_left_overlap(l_detail_count).earliest_tc := l_start_time;
       l_left_overlap(l_detail_count).detail_id := p_time_building_blocks(l_cnt).TIME_BUILDING_BLOCK_ID;
       l_left_overlap(l_detail_count).detail_ovn := p_time_building_blocks(l_cnt).object_version_number;
       l_detail_count := l_detail_count + 1;
-- End new code for Bug 2889097
     END IF;

     IF( l_stop_time > l_latest_tc) THEN
       l_latest_tc := l_stop_time;
-- Start new code for Bug 2889097
       l_detailid_right := p_time_building_blocks(l_cnt).TIME_BUILDING_BLOCK_ID;
       l_detailovn_right := p_time_building_blocks(l_cnt).object_version_number;
-- End new code for Bug 2889097
     END IF;

     l_detail := l_cnt;
     LOOP
       EXIT WHEN NOT p_time_building_blocks.EXISTS(l_detail);

         l_bb_id_detail := p_time_building_blocks(l_detail).time_building_block_id;
         l_type_detail  := p_time_building_blocks(l_detail).TYPE;
         l_start_detail := p_time_building_blocks(l_detail).START_TIME;
         l_stop_detail  := p_time_building_blocks(l_detail).STOP_TIME;
         l_scope_detail := p_time_building_blocks(l_detail).SCOPE;
         l_date_to_detail := p_time_building_blocks(l_detail).DATE_TO;
 	 l_detail_ovn     := p_time_building_blocks(l_detail).OBJECT_VERSION_NUMBER;	--added for bug 2796204

         if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
                       'Inner Loop BB_ID '||l_bb_id_detail);
         end if;
     --
     IF (l_scope_detail = 'DETAIL' AND l_type_detail  = 'RANGE'
         AND l_start_detail is NOT NULL AND l_stop_detail  is NOT NULL AND
         l_date_to_detail = hr_general.end_of_time   )  THEN
     --
        if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Inner is a DETAIL RANGE');
        end if;

        IF (l_stop_time  > l_start_detail AND
            l_start_time < l_stop_detail  AND
            l_bb_id     <> l_bb_id_detail)
        THEN
           if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Overlap Detected');
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Start BB Outer '||to_char(l_start_time,'DD-MON-YYYY:HH24:MI'));
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Stop  BB Outer '||to_char(l_stop_time,'DD-MON-YYYY:HH24:MI'));
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Start BB Inner '||to_char(l_start_detail,'DD-MON-YYYY:HH24:MI'));
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'Stop BB Inner '||to_char(l_stop_detail,'DD-MON-YYYY:HH24:MI'));
           end if;
           --
           hxc_time_entry_rules_utils_pkg.add_error_to_table (
                   p_message_table => p_messages
           ,       p_message_name  => 'HXT_39256_OVERLAPPING_TIME'
           ,       p_message_token => NULL
           ,       p_message_level => 'ERROR'
           ,       p_message_field => NULL
           ,       p_application_short_name => 'HXT'
           ,       p_timecard_bb_id     => l_bb_id_detail        --added for bug 2796204
           ,       p_time_attribute_id  => NULL
           ,       p_timecard_bb_ovn       => l_detail_ovn       --added for bug 2796204
           ,       p_time_attribute_ovn    => NULL );

           --
           EXIT;
           --
        END IF;
        --
       END IF;
     --
       l_detail := p_time_building_blocks.NEXT(l_detail);
     END LOOP;
     --
     END IF;
     --
       l_cnt := p_time_building_blocks.NEXT(l_cnt);
     END LOOP;

-- we have checked for overlaps within the timecard. Now we need to check to
-- if any of the db ranges overlap the ranges in the timecard due to graveyard type
-- work patterns.
-- We have also stored the start of the earliest DETAIL RANGE (l_earliest_tc) and the
--                         stop of the latest  DETAIL RANGE (l_latest_tc)

-- We know the latest day and the earliest day in the timecard period.
-- We make the assumption that only the day before the first day in the current period
-- and the day after the last day in the period could have details that overlap.

l_tc_db_overlap := FALSE;

-- Start new code for Bug 2889097
-- Check if the earliest day is infact the start day of Timecard period.
If ( TRUNC(l_start_day_period) = TRUNC(l_earliest_tc) ) Then
-- End new code for Bug 2889097

-- we pick up the details of the day before the first day in the current period
 FOR l_range_detail IN range_details_of_day(trunc(l_start_day_period-1),l_resource_id) LOOP
-- Start new code for Bug 2889097
  l_detail_count := l_left_overlap.first;
  LOOP
  EXIT WHEN NOT l_left_overlap.exists(l_detail_count);
-- End new code for Bug 2889097

-- Start commented code for Bug 2889097
--  IF(l_range_detail.stop_time > l_earliest_tc) THEN
-- End commented code for Bug 2889097

-- Start new code for Bug 2889097
  IF(l_range_detail.stop_time > l_left_overlap(l_detail_count).earliest_tc) THEN
-- End new code for Bug 2889097
    l_tc_db_overlap :=TRUE;

-- Start new code for Bug 2889097
    hxc_time_entry_rules_utils_pkg.add_error_to_table (
                     p_message_table => p_messages
	           , p_message_name => 'HXC_OVRLPPNG_TIME_TC_V_DB'
                   , p_message_token => NULL
                   , p_message_level => 'ERROR'
                   , p_message_field => NULL
                   , p_application_short_name => 'HXC'
                   , p_timecard_bb_id => l_left_overlap(l_detail_count).detail_id
		   , p_time_attribute_id => NULL
                   , p_timecard_bb_ovn => l_left_overlap(l_detail_count).detail_ovn
                   , p_time_attribute_ovn => NULL );
-- End new code for Bug 2889097

  END IF;

-- Start new code for Bug 2889097
  l_detail_count := l_left_overlap.next(l_detail_count);
 END Loop;
-- End new code for Bug 2889097
 END LOOP;
-- Start new code for Bug 2889097
End If;
-- End new code for Bug 2889097

-- pick up the details of the day after the last day in the current period

FOR l_range_detail IN range_details_of_day(trunc(l_end_day_period+1),l_resource_id) LOOP
  IF(l_range_detail.start_time < l_latest_tc ) THEN
    l_tc_db_overlap :=TRUE;
-- Start new code for Bug 2889097
    hxc_time_entry_rules_utils_pkg.add_error_to_table (
                     p_message_table => p_messages
                   , p_message_name => 'HXC_OVRLPPNG_TIME_TC_V_DB'
                   , p_message_token => NULL
                   , p_message_level => 'ERROR'
                   , p_message_field => NULL
                   , p_application_short_name => 'HXC'
                   , p_timecard_bb_id => l_detailid_right
                   , p_time_attribute_id => NULL
                   , p_timecard_bb_ovn => l_detailovn_right
                   , p_time_attribute_ovn => NULL );
-- End new code for Bug 2889097
  END IF;
END LOOP;

if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'L_TC_EARLIEST:'||to_char(l_earliest_tc,'DD-MON:HH24:MI'));
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'L_TC_LATEST:'||to_char(l_latest_tc,'DD-MON:HH24:MI'));
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'DAY_BEFORE:'||to_char(trunc(l_start_day_period-1)));
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'HXC_CHECKTIME_OVERLAPS',
               'DAY_AFTER:'||to_char(trunc(l_end_day_period+1)));
end if;

-- Start commented code for Bug 2889097
-- if we have found an overlap, add and error. Note that the error differs from
-- the error raised if the overlap is detected within the timecard to help the user.
-- Note also that we could give the user more information in the msgs such as
-- times of overlapping ranges if this is required.

--IF (l_tc_db_overlap = TRUE) THEN
--  hxc_time_entry_rules_utils_pkg.add_error_to_table (
--                   p_message_table => p_messages
--           ,       p_message_name  => 'HXC_OVRLPPNG_TIME_TC_V_DB'
--           ,       p_message_token => NULL
--           ,       p_message_level => 'ERROR'
--           ,       p_message_field => NULL
--           ,       p_application_short_name => 'HXC'
--           ,       p_timecard_bb_id     => l_timecardid			--added for bug 2796204
--           ,       p_time_attribute_id  => NULL
--           ,       p_timecard_bb_ovn       => l_timecardovn		--added for bug 2796204
--           ,       p_time_attribute_ovn    => NULL );
--
--END IF;
-- End commented code for Bug 2889097

END check_time_overlaps;


--
-- ----------------------------------------------------------------------------
-- |------------------------< execute_field_combo_rule >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:  executes rules which reference the two seeded field combination
--               formulae and populates the global error table accordingly
--
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type      Description
--
--   p_formula_name	            Yes  varchar2  formula name
--   p_message_table	            Yes  hxc_self_service_time_deposit.message_table
--   p_message_level                Yes  varchar2  TER message level
--   p_rule_record	            Yes  hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
--   p_tco_bb	                    Yes  hxc_self_service_time_deposit.timecard_info
--   p_tco_att                      Yes  hxc_self_service_time_deposit.building_block_attribute_info
--   p_timecard_info                Yes  r_timecard_info  Timecard Information
--
--
-- Access Status:
--   Public.
--

PROCEDURE execute_field_combo_rule (
                                p_formula_name	varchar2
			,	p_message_table	IN OUT NOCOPY hxc_self_service_time_deposit.message_table
			,       p_message_level varchar2
			,	p_rule_record	hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
			,	p_tco_bb	hxc_self_service_time_deposit.timecard_info
			,	p_tco_att       hxc_self_service_time_deposit.building_block_attribute_info ) IS

l_proc	VARCHAR2(72);

l_param_rec		hxc_ff_dict.r_param;

l_period_id		hxc_recurring_periods.recurring_period_id%TYPE;
l_reference_period	NUMBER(10);
l_consider_zero_hours   VARCHAR2(10);

l_tc_id_1               hxc_time_categories.time_category_id%TYPE;
l_tc_id_2               hxc_time_categories.time_category_id%TYPE;

l_bb_ind                BINARY_INTEGER;

TYPE r_tc1 IS RECORD ( match VARCHAR2(1) );

TYPE t_tc1 IS TABLE OF r_tc1 INDEX BY BINARY_INTEGER;

l_tc1_tab t_tc1;

BEGIN



if g_debug then
	l_proc := g_package||'execute_field_combo_rule';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

hxc_ff_dict.decode_formula_segments (
		p_formula_name	      => p_formula_name
	,       p_rule_rec            => p_rule_record
	,	p_param_rec	      => l_param_rec
	,	p_period_value        => l_period_id
	,	p_reference_value     => l_reference_period
        ,       p_consider_zero_hours => l_consider_zero_hours );

if g_debug then
	hr_utility.trace(' ************* Param values are.... ************ ');
	hr_utility.trace('');
	hr_utility.trace(' Rule name is '||p_rule_record.name);
	hr_utility.trace('');
	hr_utility.trace(' Time Category ID I  is '||l_param_rec.param1_value);
	hr_utility.trace(' Time Category ID II is '||l_param_rec.param2_value);
end if;

l_tc_id_1 := to_number(l_param_rec.param1_value);
l_tc_id_2 := to_number(l_param_rec.param2_value);

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

-- we always have to intialise the first time category so do it now

hxc_time_category_utils_pkg.initialise_time_category (
                        p_time_category_id => l_tc_id_1
               ,        p_tco_att          => p_tco_att );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- now process the first time category

l_bb_ind := p_tco_bb.FIRST;

WHILE l_bb_ind IS NOT NULL
LOOP

	IF ( p_tco_bb(l_bb_ind).scope = 'DETAIL' and
	     p_tco_bb(l_bb_ind).date_to = hr_general.end_of_time ) --Fix for Bug#2943285
	THEN

          IF ( NOT hxc_time_category_utils_pkg.chk_tc_bb_ok ( p_tco_bb(l_bb_ind).time_building_block_id ) )
	  THEN

		IF ( l_tc_id_2 IS NULL )
		THEN

			hxc_time_entry_rules_utils_pkg.add_error_to_table (
						p_message_table	=> p_message_table
					,	p_message_name	=> 'HXC_TER_VIOLATION' --'HXC_'||p_rule_record.name
					,	p_message_token	=> 'TER&'|| p_rule_record.ter_message_name
					,	p_message_level	=> p_message_level
					,	p_message_field		=> NULL
					,	p_timecard_bb_id	=> p_tco_bb(l_bb_ind).time_building_block_id
					,	p_time_attribute_id	=> NULL
		                        ,       p_timecard_bb_ovn       => p_tco_bb(l_bb_ind).object_version_number
		                        ,       p_time_attribute_ovn    => NULL );

		END IF;

           ELSE

		IF ( l_tc_id_2 IS NOT NULL )
		THEN

			l_tc1_tab(p_tco_bb(l_bb_ind).time_building_block_id).match := 'Y';

		END IF;

           END IF;

	END IF;

l_bb_ind := p_tco_bb.NEXT(l_bb_ind);

END LOOP;

IF ( l_tc_id_2 IS NOT NULL )
THEN

	hxc_time_category_utils_pkg.initialise_time_category (
                        p_time_category_id => l_tc_id_2
               ,        p_tco_att          => p_tco_att );

	-- now process the second time category

	l_bb_ind := p_tco_bb.FIRST;

	WHILE l_bb_ind IS NOT NULL
	LOOP

		IF ( p_tco_bb(l_bb_ind).scope = 'DETAIL' and
		     p_tco_bb(l_bb_ind).date_to = hr_general.end_of_time ) --Fix for Bug#2943285
		THEN

	          IF ( hxc_time_category_utils_pkg.chk_tc_bb_ok ( p_tco_bb(l_bb_ind).time_building_block_id ) )
		  THEN

			-- since this building block matches the time category check to make sure that the bb
			-- did not match the first time category, if it did then raise an error

			IF l_tc1_tab.EXISTS(p_tco_bb(l_bb_ind).time_building_block_id)
			THEN

			hxc_time_entry_rules_utils_pkg.add_error_to_table (
						p_message_table	=> p_message_table
					,	p_message_name	=> 'HXC_TER_VIOLATION' --'HXC_'||p_rule_record.name
					,	p_message_token	=> 'TER&'|| p_rule_record.ter_message_name
					,	p_message_level	=> p_message_level
					,	p_message_field		=> NULL
					,	p_timecard_bb_id	=> p_tco_bb(l_bb_ind).time_building_block_id
					,	p_time_attribute_id	=> NULL
		                        ,       p_timecard_bb_ovn       => p_tco_bb(l_bb_ind).object_version_number
		                        ,       p_time_attribute_ovn    => NULL );

			END IF;

	          END IF;

		END IF;

	l_bb_ind := p_tco_bb.NEXT(l_bb_ind);

	END LOOP;

END IF; -- ( l_tc_id_2 IS NOT NULL )

EXCEPTION WHEN OTHERS THEN

	hxc_time_entry_rules_utils_pkg.add_error_to_table (
			p_message_table	=> p_message_table
		,	p_message_name	=> 'EXCEPTION'
		,	p_message_token	=> NULL
		,	p_message_level	=> p_message_level
		,	p_message_field		=> NULL
		,	p_timecard_bb_id	=> p_tco_bb(l_bb_ind).time_building_block_id
		,	p_time_attribute_id	=> NULL
                ,       p_timecard_bb_ovn       => p_tco_bb(l_bb_ind).object_version_number
                ,       p_time_attribute_ovn    => NULL );

END execute_field_combo_rule;


/*****************************************************************
*
*   Main Procedure - execute time entry rules
*
*****************************************************************/

BEGIN -- execute_time_entry_rules

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'execute_time_entry_rules';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

get_timecard_info (
		p_time_building_blocks	=> p_time_building_blocks
	,	p_timecard_rec          => l_timecard_info_rec );

-- set submission date to be within valid assignment

-- GPM v115.69

IF ( hxc_time_entry_rules_utils_pkg.g_assignment_info.EXISTS ( l_timecard_info_Rec.resource_id ) )
THEN

	IF ( ( l_timecard_info_Rec.start_date =
               hxc_time_entry_rules_utils_pkg.g_assignment_info(l_timecard_info_Rec.resource_id).start_date )
              AND
             ( l_timecard_info_Rec.end_date =
               hxc_time_entry_rules_utils_pkg.g_assignment_info(l_timecard_info_Rec.resource_id).end_date ) )
	THEN

		l_submission_date :=
		hxc_time_entry_rules_utils_pkg.g_assignment_info(l_timecard_info_Rec.resource_id).submission_date;

	ELSE

		-- overwrite cached assignment info since for a different timecard period
		-- this would only happen if the timecard period on a submission change
		-- i.e. if the cached value is used for a different timecard submission for the
		--      same user

		set_global_asg_info (  l_timecard_info_Rec.resource_id
	                             , l_timecard_info_Rec.start_date
	                             , l_timecard_info_Rec.end_date );

		l_submission_date :=
		hxc_time_entry_rules_utils_pkg.g_assignment_info(l_timecard_info_Rec.resource_id).submission_date;

	END IF;
ELSE

	set_global_asg_info (  l_timecard_info_Rec.resource_id
                             , l_timecard_info_Rec.start_date
                             , l_timecard_info_Rec.end_date );

	l_submission_date :=
	hxc_time_entry_rules_utils_pkg.g_assignment_info(l_timecard_info_Rec.resource_id).submission_date;

END IF;


IF ( l_timecard_info_rec.resource_id = 13577 )
THEN

null;


END IF;

-- loop through the time entry rules based on the resource's
-- preference and get the message level

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

l_rules_evl := hxc_preference_evaluation.resource_preferences(
		          p_resource_id	    => l_timecard_info_rec.resource_id
	             ,p_pref_code       => 'TC_W_RULES_EVALUATION'
                 ,p_attribute_n     => 1
                 ,p_evaluation_date => l_submission_date );

IF l_rules_evl = 'Y'
THEN
		check_time_overlaps (
			p_time_building_blocks => p_time_building_blocks
   		,	p_messages             => p_messages );

END IF;

 hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
  			       p_preference_code => 'TS_PER_TIME_ENTRY_RULES',
                                p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

l_terg_id := l_pref_table(1).attribute1 ;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 25);
end if;

FOR r_rules IN csr_get_rules ( p_terg_id        => l_terg_id
			,      p_start_date	=> l_timecard_info_rec.start_date
			,      p_end_date	=> l_timecard_info_rec.end_date )
LOOP
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- GPM v115.61 2180942

if g_debug then
	hr_utility.trace('GAZ OPERATION IS '||p_operation);
	hr_utility.trace('GAZ RESUBMIT  IS '||p_resubmit);
end if;

-- maintain global record of TER info

hxc_time_entry_rules_utils_pkg.g_ter_record.ter_name  := r_rules.name;
hxc_time_entry_rules_utils_pkg.g_ter_record.ter_message_name  := r_rules.ter_message_name;
hxc_time_entry_rules_utils_pkg.g_ter_record.ter_usage := r_rules.rule_usage;
hxc_time_entry_rules_utils_pkg.g_ter_record.ter_formula_name := NVL( r_rules.formula_name, 'NULL FORMULA');
hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id := NULL;

IF ( ( p_operation = 'SAVE'   AND r_rules.rule_usage = 'SAVE'                                 ) OR
     ( p_operation = 'SUBMIT' AND p_resubmit  = 'NO'  AND r_rules.rule_usage = 'SUBMISSION'   ) OR
     ( p_operation = 'SUBMIT' AND p_resubmit  = 'YES' AND r_rules.rule_usage = 'RESUBMISSION' ) OR
     ( p_operation = 'SUBMIT' AND r_rules.rule_usage = 'BOTH'                                 ) OR
     ( p_operation = 'SUBMIT' AND r_rules.rule_usage = 'DELETE_ONLY' AND l_timecard_info_rec.deleted = 'Y' ) OR
     ( p_operation = 'SUBMIT' AND r_rules.rule_usage = 'BOTH_EX_DEL' AND l_timecard_info_rec.deleted = 'N' )
    )
THEN

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('********** Rule Name is '||r_rules.name||' **************');
	hr_utility.trace('');
end if;

IF ( r_rules.formula_id IS NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;
if(FND_LOG.LEVEL_STATEMENT>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'hxc_time_entry_rules', 'after 40');
end if;

	-- GPM v115.87

	IF ( r_rules.name in ( 'Overlapping Time Entries', 'Overlapping Time Entries - Save') )
      AND l_rules_evl = 'N'
	THEN

		-- still need to decide if we call the chk mapping changed

		check_time_overlaps (
			p_time_building_blocks => p_time_building_blocks
   		,	p_messages             => p_messages );

	END IF;

-- in the case of wtd a rule without a formula is meaningless
-- if the formula is null then we must have a mapping id but if we evaluate
-- the mapping what do we do?
--
-- gaz - maybe need to look into this further or add formula_id is not null in csr

ELSIF ( r_rules.formula_id IS NOT NULL AND r_rules.mapping_id IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

        IF ( hxc_mapping_utilities.chk_mapping_changed(
                               p_mapping_id     => r_rules.mapping_id
                              ,p_timecard_bb_id => l_timecard_info_rec.timecard_bb_id
                              ,p_timecard_ovn   => l_timecard_info_rec.timecard_ovn
                              ,p_start_date     => l_timecard_info_rec.start_date
                              ,p_end_date       => l_timecard_info_rec.end_date
                              ,p_last_status    =>
                                            p_time_building_blocks(p_time_building_blocks.FIRST).approval_status
                              ,p_time_building_blocks => p_time_building_blocks
			      ,p_time_attributes      => p_time_attributes
                              ,p_called_from          => 'TIME_ENTRY'
 ))
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

		execute_formula ( p_formula_name=> r_rules.formula_name
			,	p_message_table	=> p_messages
			,	p_message_level	=> r_rules.rule_outcome
			,	p_rule_record	=> r_rules
			,	p_tco_bb	=> p_time_building_blocks
			,	p_tco_att       => p_time_attributes
			,	p_timecard_info => l_timecard_info_rec );

	END IF;

ELSE -- basically means ( r_rules.formula_id IS NOT NULL AND r_rules.mapping_id IS NULL )

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

	-- special case for Field Combination rules

	IF ( r_rules.formula_name in ( 'HXC_FIELD_COMBO_INCLUSIVE', 'HXC_FIELD_COMBO_EXCLUSIVE' ) )
	THEN

		execute_field_combo_rule (
                                p_formula_name	=> r_rules.formula_name
			,	p_message_table	=> p_messages
			,       p_message_level => r_rules.rule_outcome
			,	p_rule_record	=> r_rules
			,	p_tco_bb	=> p_time_building_blocks
			,	p_tco_att       => p_time_attributes );

	ELSE

		execute_formula ( p_formula_name=> r_rules.formula_name
			,	p_message_table	=> p_messages
			,	p_message_level	=> r_rules.rule_outcome
			,	p_rule_record	=> r_rules
			,	p_tco_bb	=> p_time_building_blocks
			,	p_tco_att       => p_time_attributes
			,	p_timecard_info => l_timecard_info_rec );

	END IF;

END IF;

END IF; -- p_operator / r_rules.rule_usage test



IF ( l_timecard_info_rec.resource_id = 13577 )
THEN

null;


END IF;


END LOOP; -- csr_get_rules

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 75);
end if;

EXCEPTION WHEN OTHERS THEN

        if g_debug then
        	hr_utility.trace('SQLERRM is '||SQLERRM);
        end if;

	hxc_time_entry_rules_utils_pkg.add_error_to_table (
				p_message_table	=> p_messages
			,	p_message_name	=> 'EXCEPTION'
			,	p_message_token	=> NULL
			,	p_message_level	=> 'ERROR'
			,	p_message_field		=> NULL
			,	p_timecard_bb_id	=> l_timecard_info_rec.timecard_bb_id
			,	p_time_attribute_id	=> NULL
                        ,       p_timecard_bb_ovn       => l_timecard_info_rec.timecard_ovn
                        ,       p_time_attribute_ovn    => NULL );

IF ( l_timecard_info_rec.resource_id = 13577 )
THEN

null;


END IF;

END execute_time_entry_rules;
--

FUNCTION period_maximum (
		p_resource_id		NUMBER
	,	p_submission_date	VARCHAR2
	,	p_period_maximum	NUMBER
	,	p_period		NUMBER default 1
	,	p_reference_period	NUMBER default 1
	,	p_pre_period_start	VARCHAR2
	,	p_pre_period_end	VARCHAR2
	,	p_post_period_start	VARCHAR2 default null
	,	p_post_period_end	VARCHAR2 default null
	,	p_ref_period_start	VARCHAR2 default null
	,	p_ref_period_end	VARCHAR2 default null
	,	p_duration_in_days	NUMBER default 1
	,	p_timecard_hrs		NUMBER default 0 ) RETURN NUMBER IS

l_return NUMBER;

BEGIN

l_return := period_maximum (
		p_resource_id		=> p_resource_id
	,	p_submission_date	=> p_submission_date
	,	p_period_maximum	=> p_period_maximum
	,	p_period		=> p_period
	,	p_reference_period	=> p_reference_period
	,	p_pre_period_start	=> p_pre_period_start
	,	p_pre_period_end	=> p_pre_period_end
	,	p_post_period_start	=> p_post_period_start
	,	p_post_period_end	=> p_post_period_end
	,	p_ref_period_start	=> p_ref_period_start
	,	p_ref_period_end	=> p_ref_period_end
	,	p_duration_in_days	=> p_duration_in_days
	,	p_timecard_hrs		=> p_timecard_hrs
        ,       p_operator              => NULL );

RETURN l_return;

END period_maximum;


FUNCTION period_maximum (
		p_resource_id		NUMBER
	,	p_submission_date	VARCHAR2
	,	p_period_maximum	NUMBER
	,	p_period		NUMBER default 1
	,	p_reference_period	NUMBER default 1
	,	p_pre_period_start	VARCHAR2
	,	p_pre_period_end	VARCHAR2
	,	p_post_period_start	VARCHAR2 default null
	,	p_post_period_end	VARCHAR2 default null
	,	p_ref_period_start	VARCHAR2 default null
	,	p_ref_period_end	VARCHAR2 default null
	,	p_duration_in_days	NUMBER default 1
	,	p_timecard_hrs		NUMBER default 0
        ,       p_operator              VARCHAR2 ) RETURN NUMBER IS


CURSOR	csr_get_total_hrs ( p_start_date DATE, p_end_date DATE) IS
SELECT NVL(SUM(SUM(NVL(hxc_time_category_utils_pkg.category_detail_hrs( tbb_detail.time_building_block_id,
  tbb_detail.object_version_number),0)) ),0)
FROM
   hxc_timecard_summary ts,
   hxc_time_building_blocks tbb_day,
   hxc_time_building_blocks tbb_detail
WHERE
   tbb_day.time_building_block_id = tbb_detail.parent_building_block_id and
   ts.timecard_id = tbb_day.parent_building_block_id and
   tbb_detail.scope='DETAIL' and
   tbb_detail.date_to=hr_general.end_of_time and
   tbb_day.scope='DAY' and
   tbb_day.type='RANGE' and
   tbb_day.date_to=hr_general.end_of_time and
   ts.resource_id = p_resource_id and
   to_date(to_char(tbb_day.start_time,
   'DD-MON-YYYY'),
   'DD-MON-YYYY') BETWEEN p_start_date AND p_end_date
   AND	to_date(to_char(tbb_day.stop_time,
   'DD-MON-YYYY'),
   'DD-MON-YYYY') BETWEEN p_start_date AND p_end_date
 group by ts.timecard_id ;

l_submission_date DATE;

l_period_type	   hxc_recurring_periods.period_type%TYPE;
l_duration_in_days hxc_recurring_periods.duration_in_days%TYPE;

l_return		NUMBER;

l_total_hrs		NUMBER := 0;
l_hrs			NUMBER := 0;
l_ref_period_hrs	NUMBER := 0;
l_number_of_periods	NUMBER(6,2);

l_old_tc_id             NUMBER(15);

l_period_start		DATE;
l_period_start_date	DATE;
l_period_end_date	DATE;

l_db_pre_period_start	DATE;
l_db_pre_period_end	DATE;
l_db_post_period_start	DATE;
l_db_post_period_end	DATE;
l_db_ref_period_start	DATE;
l_db_ref_period_end	DATE;

l_proc	VARCHAR2(72);

l_tc_bld_blks         hxc_self_service_time_deposit.timecard_info;
l_tc_ind binary_integer;


BEGIN -- period_maximum

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'period_maximum';
	hr_utility.set_location('Processing '||l_proc, 10);

	hr_utility.trace('Lets see what is in the structure');
end if;

l_tc_bld_blks := hxc_self_service_time_deposit.get_building_blocks;

l_tc_ind := l_tc_bld_blks.first;

while l_tc_ind is not null
loop

	if g_debug then
		hr_utility.trace('scope is '||l_tc_bld_blks(l_tc_ind).scope);
		hr_utility.trace('bb id is '||to_number(l_tc_bld_blks(l_tc_ind).time_building_Block_id));
		hr_utility.trace('new is '||l_tc_bld_blks(l_tc_ind).new);
		hr_utility.trace('changed is '||l_tc_bld_blks(l_tc_ind).changed);
	end if;

l_tc_ind := l_tc_bld_blks.NEXT(l_tc_ind);

end loop;

-- first convert dates to proper dates

l_submission_date      := TO_DATE(p_submission_date,      'YYYY/MM/DD HH24:MI:SS');

IF ( p_pre_period_start <> ' ' )
THEN
	l_db_pre_period_start  := TO_DATE(p_pre_period_start, 'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_pre_period_start  := NULL;
END IF;

IF ( p_pre_period_end <> ' ' )
THEN
	l_db_pre_period_end    := TO_DATE(p_pre_period_end,   'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_pre_period_end    := NULL;
END IF;

IF ( p_post_period_start <> ' ' )
THEN
	l_db_post_period_start := TO_DATE(p_post_period_start,'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_post_period_start := NULL;
END IF;

IF ( p_post_period_end <> ' ' )
THEN
	l_db_post_period_end   := TO_DATE(p_post_period_end,  'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_post_period_end   := NULL;
END IF;

IF ( p_ref_period_start <> ' ' )
THEN
	l_db_ref_period_start := TO_DATE(p_ref_period_start,'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_ref_period_start := NULL;
END IF;

IF ( p_ref_period_end <> ' ' )
THEN
	l_db_ref_period_end   := TO_DATE(p_ref_period_end,  'YYYY/MM/DD HH24:MI:SS');
ELSE
	l_db_ref_period_end   := NULL;
END IF;

-- remember p_period_start/end is the remainder of the period
-- not included in the time card object which we must derive
-- from the database.

IF ( l_db_pre_period_start IS NOT NULL AND l_db_post_period_start IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

	-- now lets get the total hours worked based on the pre TC window

	OPEN  csr_get_total_hrs ( l_db_pre_period_start, l_db_pre_period_end );
	FETCH csr_get_total_hrs INTO l_hrs;
	CLOSE csr_get_total_hrs;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('Pre period hours are '||to_char(l_hrs));
	hr_utility.trace('');
end if;

	l_total_hrs := l_hrs;

	l_hrs := 0;

	-- now lets get the total hours worked based on the post TC window

	OPEN  csr_get_total_hrs ( l_db_post_period_start, l_db_post_period_end );
	FETCH csr_get_total_hrs INTO l_hrs;
	CLOSE csr_get_total_hrs;

if g_debug then
	hr_utility.trace('Post period hours are '||to_char(l_hrs));
	hr_utility.trace('');
end if;

	l_total_hrs := l_total_hrs + l_hrs + p_timecard_hrs;

	IF ( hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id IS NOT NULL )
	THEN

		-- calculate PTO INC hours

		l_old_tc_id := hxc_time_category_utils_pkg.g_time_category_id;
		hxc_time_category_utils_pkg.g_time_category_id
			:= hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id;

		l_hrs := 0;

		OPEN  csr_get_total_hrs ( l_db_pre_period_start, l_db_pre_period_end );
		FETCH csr_get_total_hrs INTO l_hrs;
		CLOSE csr_get_total_hrs;

		if g_debug then
			hr_utility.trace('');
			hr_utility.trace('Pre period hours are '||to_char(l_hrs));
			hr_utility.trace('');
		end if;

		l_total_hrs := l_total_hrs - l_hrs;

		-- now lets get the total hours worked based on the post TC window

		l_hrs := 0;

		OPEN  csr_get_total_hrs ( l_db_post_period_start, l_db_post_period_end );
		FETCH csr_get_total_hrs INTO l_hrs;
		CLOSE csr_get_total_hrs;

		if g_debug then
			hr_utility.trace('Post period hours are '||to_char(l_hrs));
			hr_utility.trace('');
		end if;

		l_total_hrs := l_total_hrs - l_hrs;

		hxc_time_category_utils_pkg.g_time_category_id := l_old_tc_id;

	END IF;

ELSIF ( l_db_pre_period_start IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

	-- now lets get the total hours worked based on the pre TC window

	OPEN  csr_get_total_hrs ( l_db_pre_period_start, l_db_pre_period_end );
	FETCH csr_get_total_hrs INTO l_hrs;
	CLOSE csr_get_total_hrs;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('Pre period hours are '||to_char(l_hrs));
	hr_utility.trace('');
end if;

	l_total_hrs := l_total_hrs + l_hrs + p_timecard_hrs;

	IF ( hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id IS NOT NULL )
	THEN

		-- calculate PTO INC hours

		l_old_tc_id := hxc_time_category_utils_pkg.g_time_category_id;
		hxc_time_category_utils_pkg.g_time_category_id
			:= hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id;

		l_hrs := 0;

		OPEN  csr_get_total_hrs ( l_db_pre_period_start, l_db_pre_period_end );
		FETCH csr_get_total_hrs INTO l_hrs;
		CLOSE csr_get_total_hrs;

		if g_debug then
			hr_utility.trace('');
			hr_utility.trace('Pre period hours are '||to_char(l_hrs));
			hr_utility.trace('');
		end if;

		l_total_hrs := l_total_hrs - l_hrs;

		hxc_time_category_utils_pkg.g_time_category_id := l_old_tc_id;

	END IF;

ELSIF( l_db_post_period_start IS NOT NULL )
THEN
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;

	-- now lets get the total hours worked based on the post TC window

	OPEN  csr_get_total_hrs ( l_db_post_period_start, l_db_post_period_end );
	FETCH csr_get_total_hrs INTO l_hrs;
	CLOSE csr_get_total_hrs;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('Post period hours are '||to_char(l_hrs));
	hr_utility.trace('');
end if;

	l_total_hrs := l_hrs + p_timecard_hrs;

	IF ( hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id IS NOT NULL )
	THEN

		-- calculate PTO INC hours

		l_old_tc_id := hxc_time_category_utils_pkg.g_time_category_id;
		hxc_time_category_utils_pkg.g_time_category_id
			:= hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id;

		l_hrs := 0;

		OPEN  csr_get_total_hrs ( l_db_post_period_start, l_db_post_period_end );
		FETCH csr_get_total_hrs INTO l_hrs;
		CLOSE csr_get_total_hrs;

		if g_debug then
			hr_utility.trace('Post period hours are '||to_char(l_hrs));
			hr_utility.trace('');
		end if;

		l_total_hrs := l_total_hrs - l_hrs;

		hxc_time_category_utils_pkg.g_time_category_id := l_old_tc_id;

	END IF;

ELSE
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

-- i.e. the whole time entry rule period is
-- encompassed by the TCO

l_total_hrs := p_timecard_hrs;

END IF;
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

IF ( l_db_ref_period_start IS NOT NULL )
THEN

-- now get the number of hours in the reference period

l_number_of_periods := ROUND( p_reference_period / p_duration_in_days, 2);

OPEN  csr_get_total_hrs ( l_db_ref_period_start, l_db_ref_period_end );
FETCH csr_get_total_hrs INTO l_ref_period_hrs;
CLOSE csr_get_total_hrs;

l_total_hrs := (( l_total_hrs + l_ref_period_hrs ) / l_number_of_periods );

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('************* reference period info ****************');
	hr_utility.trace('reference period start is '||TO_CHAR(l_db_ref_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('reference period end is   '||TO_CHAR(l_db_ref_period_end  , 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('number of periods is '||TO_CHAR(l_number_of_periods));
	hr_utility.trace('ref period hours are '||to_char(l_ref_period_hrs));
end if;

END IF;

if g_debug then
	hr_utility.trace('period maximum is '||to_char(p_period_maximum));
	hr_utility.trace('total hours are '||to_char(l_total_hrs));
	hr_utility.trace('');
end if;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

-- WWB 3738796
-- check to see if period max is being called from a TER which is using the seeded PTO formula
-- In this case if the l_total_hrs are 0 then we should always return success since
-- there are no hours which will be deducted from the accrual balance

IF ( ( hxc_time_entry_rules_utils_pkg.g_ter_record.ter_formula_name = 'HXC_PTO_ACCRUAL_COMPARISON' )
    AND
     ( l_total_hrs = 0 ) )
THEN

	l_return := 1;
	RETURN l_return;

ELSE

IF ( p_operator IS NULL OR p_operator = '<' )
THEN

	IF ( p_period_maximum < l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;

ELSIF ( p_operator = '<=' )
THEN

	IF ( p_period_maximum <= l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;


ELSIF ( p_operator = '<>' )
THEN

	IF ( p_period_maximum <> l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;


ELSIF ( p_operator = '=' )
THEN

	IF ( p_period_maximum = l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;


ELSIF ( p_operator = '>' )
THEN

	IF ( p_period_maximum > l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;


ELSIF ( p_operator = '>=' )
THEN

	IF ( p_period_maximum >= l_total_hrs )
	THEN
		l_return	:= -1;
		RETURN l_return;
	ELSE
		l_return 	:= 1;
		RETURN l_return;
	END IF;


END IF; -- p_operator

END IF; -- g_ter_record.ter_formula_name = 'HXC_PTO_ACCRUAL_COMPARISON'

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

END period_maximum;

FUNCTION asg_status_id ( p_assignment_id  NUMBER
		,	 p_effective_date VARCHAR2 ) RETURN NUMBER IS

l_proc varchar2(72) := g_package||'.asg_status_id';
l_asg_status_id per_assignment_status_types.assignment_status_type_id%TYPE;

CURSOR	csr_get_asg_status_id IS
SELECT	a.assignment_status_type_id
FROM	per_assignment_status_types a
,	per_assignments_f asg
WHERE
	asg.assignment_id = p_assignment_id AND
	TO_DATE(p_effective_date, 'YYYY/MM/DD HH24:MI:SS')
	BETWEEN asg.effective_start_date AND asg.effective_end_date
AND
	asg.assignment_status_type_id = a.assignment_status_type_id;

BEGIN

OPEN  csr_get_asg_status_id;
FETCH csr_get_asg_status_id INTO l_asg_status_id;

IF csr_get_asg_status_id%NOTFOUND
THEN

	CLOSE csr_get_asg_status_id;

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','assignment status');
    fnd_message.raise_error;

END IF;

CLOSE csr_get_asg_status_id;

RETURN l_asg_status_id;

END asg_status_id;

PROCEDURE tc_edit_allowed (
                         p_timecard_id                  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
			,p_timecard_ovn                 HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
                        ,p_edit_allowed_preference      HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE
                        ,p_edit_allowed IN OUT nocopy   VARCHAR2
                        ) IS

begin

   tc_edit_allowed
      (p_timecard_id            => p_timecard_id,
       p_timecard_ovn           => p_timecard_ovn,
       p_timecard_status        => null,
       p_edit_allowed_preference=> p_edit_allowed_preference,
       p_edit_allowed           => p_edit_allowed
       );

end tc_edit_allowed;

PROCEDURE tc_edit_allowed (
                         p_timecard_id                  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
			,p_timecard_ovn                 HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
                        ,p_timecard_status              HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE
                        ,p_edit_allowed_preference      HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE
                        ,p_edit_allowed IN OUT nocopy   VARCHAR2
                        ) is

CURSOR  csr_chk_transfer IS
SELECT  1
FROM	dual
WHERE EXISTS (
	SELECT	1
	FROM	hxc_transactions t
	,	hxc_transaction_details td
	WHERE	td.time_building_block_id	= p_timecard_id
	AND
		t.transaction_id	= td.transaction_id	AND
		t.type			= 'RETRIEVAL'		AND
		t.status		= 'SUCCESS' );

l_proc	VARCHAR2(72);

l_tc_status	hxc_time_building_blocks.approval_status%TYPE;

l_dummy		NUMBER(1);

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'tc_edit_allowed';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

-- GPM v115.25
-- WWB - 2109325
-- ARR v115.99.11512.7, only fetch approval status if not already known.

if(p_timecard_status is null) then
   l_tc_status := hxc_timecard_search_pkg.get_timecard_status_code(p_timecard_id,p_Timecard_Ovn);
else
   l_tc_status := p_timecard_status;
end if;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;


IF ( p_edit_allowed_preference = 'NEW_WORKING_REJECTED' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

	IF ( ( l_tc_status = 'REJECTED' ) OR ( l_tc_status = 'WORKING' ) )
	THEN
		p_edit_allowed	:= 'TRUE';
	ELSE
		p_edit_allowed	:= 'FALSE';
	END IF;

ELSIF ( p_edit_allowed_preference = 'SUBMITTED' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

	IF ( ( l_tc_status = 'REJECTED' ) OR ( l_tc_status = 'WORKING' ) OR ( l_tc_status = 'SUBMITTED' ) )
	THEN
		p_edit_allowed	:= 'TRUE';
	ELSE
		p_edit_allowed	:= 'FALSE';
	END IF;

ELSIF ( p_edit_allowed_preference = 'APPROVALS_INITIATED' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 50);
	end if;

	-- all we need to do here is check that this timecard
	-- has not been transferred successfully to any recipient
	-- applications

	OPEN  csr_chk_transfer;
	FETCH csr_chk_transfer INTO l_dummy;

	IF csr_chk_transfer%FOUND
	THEN
		p_edit_allowed := 'FALSE';
	ELSE
		p_edit_allowed := 'TRUE';
	END IF;

ELSIF ( p_edit_allowed_preference = 'RETRO' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 60);
	end if;

	IF ( ( l_tc_status = 'REJECTED' ) OR ( l_tc_status = 'WORKING' ) OR ( l_tc_status = 'SUBMITTED' )
	  OR ( l_tc_status = 'APPROVED' ) OR ( l_tc_status = 'ERROR' ) )
	THEN
		p_edit_allowed	:= 'TRUE';
	ELSE
		p_edit_allowed	:= 'FALSE';
	END IF;

ELSE
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 70);
	end if;

	p_edit_allowed := 'FALSE';

END IF;

-- if the status is ERROR, we don't need to look at
-- the pref -> JUST RETURN TRUE;
IF (l_tc_status = 'ERROR') THEN
  p_edit_allowed	:= 'TRUE';
END IF;


if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 80);
end if;

END tc_edit_allowed;







-- Public Function
--
--  Test whether the assignment is enrolled in
--  the specified accrual plan as of the
--  effective date
--
-- Usage
--   Called from the PTO BAl comparison formula
--

FUNCTION chk_pto_plan ( p_assignment_id   NUMBER
		,       p_accrual_plan_id NUMBER
		,	p_effective_date  VARCHAR2 )
RETURN NUMBER IS

l_pto_ok  pay_accrual_plans.accrual_plan_id%TYPE := -1;

CURSOR csr_chk_pto_ok IS
SELECT pap.accrual_plan_id
FROM
         pay_accrual_plans pap
        ,pay_element_types_f pet
        ,pay_element_links_f pel
        ,pay_element_entries_f pee
WHERE
         pap.accrual_plan_id = p_accrual_plan_id  AND
         pap.accrual_plan_element_type_id = pet.element_type_id
AND
         pet.element_type_id = pel.element_type_id AND
         pee.effective_start_date BETWEEN
         pet.effective_start_date AND pet.effective_end_date
AND
         pel.element_link_id = pee.element_link_id AND
         pee.effective_start_date BETWEEN
         pel.effective_start_date AND pel.effective_end_date
AND
         pee.assignment_id = p_assignment_id  AND
         to_date(p_effective_date, 'YYYY/MM/DD HH24:MI:SS')
         BETWEEN pee.effective_start_date AND pee.effective_end_date;


BEGIN

g_debug := hr_utility.debug_enabled;

OPEN  csr_chk_pto_ok;
FETCH csr_chk_pto_ok INTO l_pto_ok;

IF csr_chk_pto_ok%FOUND
THEN

if g_debug then
	hr_utility.trace('PTO PLAN OK');
end if;
	l_pto_ok := 1;

ELSE

if g_debug then
	hr_utility.trace('PTO PLAN NOT OK');
end if;


END IF;

CLOSE csr_chk_pto_ok;

RETURN l_pto_ok;

END chk_pto_plan;


PROCEDURE EXECUTE_ELP_TIME_ENTRY_RULES( P_TIME_BUILDING_BLOCKS HXC_BLOCK_TABLE_TYPE
				       ,P_TIME_ATTRIBUTES HXC_ATTRIBUTE_TABLE_TYPE
				       ,P_MESSAGES in out NOCOPY hxc_self_service_time_deposit.MESSAGE_TABLE
				       ,P_TIME_ENTRY_RULE_GROUP_ID NUMBER) IS
n number;
l_timecard_info_rec hxc_time_entry_rules_utils_pkg.r_timecard_info;
l_terg_id           hxc_pref_hierarchies.attribute1%TYPE;
l_time_category_id  hxc_time_categories.time_category_id%TYPE;

l_prefs hxc_preference_evaluation.t_pref_table;

Begin
g_debug := hr_utility.debug_enabled;

get_timecard_info (
		p_time_building_blocks	=> p_time_building_blocks
	,	p_timecard_rec          => l_timecard_info_rec );
if g_debug then
	hr_utility.trace('After get_timecard_info');
	hr_utility.trace('start_date ' || l_timecard_info_rec.start_date);
end if;
-- Start 2944785
/*
hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_ELP_RULES',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table  => l_prefs );

IF ( l_prefs.COUNT > 1 )
THEN

	-- error since cannot have more than one ELP preference in timecard period

	-- in the interim take the first available value

	l_terg_id := l_prefs(1).attribute1;

ELSE

	l_terg_id := l_prefs(1).attribute1;

END IF;
-- GPM v115.55
*/
l_terg_id := P_TIME_ENTRY_RULE_GROUP_ID;

-- End 2944785

FOR r_rules IN csr_get_rules ( p_terg_id        => l_terg_id
			,      p_start_date	=> l_timecard_info_rec.start_date
			,      p_end_date	=> l_timecard_info_rec.end_date )
LOOP
    if g_debug then
    	hr_utility.trace('r_rules.Timecategory_name' || r_rules.attribute2);
    	hr_utility.trace('r_rules.Recipient Application' || r_rules.attribute1);
    end if;
    l_time_category_id :=  r_rules.attribute2;
    if g_debug then
    	hr_utility.trace('Time Category ID' || l_time_category_id);
    end if;
    hxc_time_category_utils_pkg.initialise_time_category(
				p_time_category_id => to_number(l_time_category_id),
				p_tco_att => P_TIME_ATTRIBUTES);
    n := p_time_building_blocks.first;
    loop
        exit when not p_time_building_blocks.exists(n);
        if (p_time_building_blocks(n).scope = 'DETAIL') then
	   if (hxc_time_category_utils_pkg.chk_tc_bb_ok( p_time_building_blocks(n).time_building_block_id)) then
	      add_error_to_table (
					p_message_table	=> p_messages
				,	p_message_name	=> r_rules.attribute1
				,	p_message_token	=> NULL
				,	p_message_level	=> 'PTE'
				,	p_message_field	=> NULL
				,	p_timecard_bb_id => p_time_building_blocks(n).time_building_block_id
				,	p_time_attribute_id => NULL
                                ,       p_timecard_bb_ovn => p_time_building_blocks(n).object_version_number
                                ,       p_time_attribute_ovn => NULL );
	    end if;
	end if;
	n := p_time_building_blocks.next(n);
    end loop;
end loop;

if g_debug then
	hr_utility.trace('Message Table');
end if;
n := p_messages.first;
loop
    exit when not p_messages.exists(n);
    if (p_messages(n).message_level = 'PTE') then
        if g_debug then
        	hr_utility.trace('Time Building Block Id' || p_messages(n).time_building_block_id);
		hr_utility.trace('Time Building Block OVN' || p_messages(n).time_building_block_ovn);
		hr_utility.trace('Recipient Application ID' || p_messages(n).message_name);
	end if;
    end if;
    n := p_messages.next(n);
end loop;

if g_debug then
	hr_utility.trace('End of execute ELP time entry rules');
end if;

end execute_ELP_time_entry_rules;

PROCEDURE EXECUTE_CLA_TIME_ENTRY_RULES( P_TIME_BUILDING_BLOCKS hxc_self_service_time_deposit.timecard_info
				       ,P_TIME_ATTRIBUTES hxc_self_service_time_deposit.building_block_attribute_info
				       ,P_MESSAGES in out NOCOPY hxc_self_service_time_deposit.MESSAGE_TABLE
				       ,P_TIME_ENTRY_RULE_GROUP_ID NUMBER) IS
n number;
l_timecard_info_rec hxc_time_entry_rules_utils_pkg.r_timecard_info;
l_terg_id           hxc_pref_hierarchies.attribute1%TYPE;
l_time_category_id  hxc_time_categories.time_category_id%TYPE;

l_prefs hxc_preference_evaluation.t_pref_table;

      FUNCTION chk_bb_late (
         p_stop_time      DATE,
         p_st_late_hrs    NUMBER,
         p_qnt_late_hrs   NUMBER,
	 p_date_worked    DATE
      )
         RETURN BOOLEAN
      IS
         l_late_measure   NUMBER;
	 l_client_tz fnd_timezones_b.timezone_code%type;
	 l_server_tz fnd_timezones_b.timezone_code%type;
	 l_client_time DATE;
      BEGIN
         g_debug := hr_utility.debug_enabled;

         if g_debug then
         	hr_utility.TRACE (   'Stop Time '
         	                  || p_stop_time);
         	hr_utility.TRACE (   'p_st_late_hrs '
         	                  || p_st_late_hrs);
         	hr_utility.TRACE (   'p_qnt_late_hrs '
         	                  || p_qnt_late_hrs);
         end if;
	 --Fix for Bug No:4948883
	 fnd_date.timezones_enabled := true;
         l_client_tz := fnd_timezones.get_client_timezone_code;
         l_server_tz := fnd_timezones.get_server_timezone_code;
         l_client_time := fnd_date.adjust_datetime(sysdate,l_server_tz,l_client_tz);

         IF (p_stop_time IS NOT NULL)
         THEN
            l_late_measure := (  l_client_time - p_stop_time
                              ) * 24;
            if g_debug then
            	hr_utility.TRACE (   'l_late_measure '
            	                  || l_late_measure);
            end if;

            IF (l_late_measure > p_st_late_hrs)
            THEN
               RETURN TRUE;
            END IF;
         ELSE
	 if g_debug then
	 	hr_utility.trace('L_date_worked...............' || to_char(p_date_worked,'dd-mon-rrrr hh:mi:ss'));
	 end if;
            IF ((  TRUNC (p_date_worked)
                 + (p_qnt_late_hrs / 24)
                ) < l_client_time
               )
            THEN
               if g_debug then
               	hr_utility.TRACE ('Late.....');
               end if;
               RETURN TRUE;
            END IF;
         END IF;

         RETURN FALSE;
      END chk_bb_late;

      PROCEDURE populate_old_tco (
         p_timecard_rec               IN              hxc_time_entry_rules_utils_pkg.r_timecard_info,
         p_timecard_building_blocks   IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
         p_timecard_attributes        IN OUT NOCOPY   hxc_self_service_time_deposit.building_block_attribute_info
      )
      IS
         CURSOR csr_get_det_bbs
         IS
            SELECT detail.time_building_block_id, detail.TYPE, detail.measure,
                   detail.unit_of_measure, detail.start_time,
                   detail.stop_time, detail.parent_building_block_id,
                   'N' parent_is_new, detail.SCOPE,
                   detail.object_version_number, detail.approval_status,
                   detail.resource_id, detail.resource_type,
                   detail.approval_style_id, detail.date_from, detail.date_to,
                   detail.comment_text, detail.parent_building_block_ovn,
                   'N' NEW, 'N' changed
              FROM hxc_time_building_blocks detail,
                   hxc_time_building_blocks DAY
             WHERE DAY.parent_building_block_id =
                                                p_timecard_rec.timecard_bb_id
               AND DAY.parent_building_block_ovn =
                                                  p_timecard_rec.timecard_ovn
               AND detail.date_to = hr_general.end_of_time
               AND detail.SCOPE = 'DETAIL'
               AND detail.parent_building_block_id =
                                                   DAY.time_building_block_id
               AND detail.parent_building_block_ovn =
                                                    DAY.object_version_number
               AND DAY.SCOPE = 'DAY'
               AND DAY.date_to = hr_general.end_of_time;

         -- Bug 8920374
         -- Changed the below query to resolve the perf issue.
         /*
         CURSOR csr_get_det_attr (p_building_block_id NUMBER, p_bb_ovn NUMBER)
         IS
            SELECT a.time_attribute_id, au.time_building_block_id,
                   bbit.bld_blk_info_type, a.attribute_category, a.attribute1,
                   a.attribute2, a.attribute3, a.attribute4, a.attribute5,
                   a.attribute6, a.attribute7, a.attribute8, a.attribute9,
                   a.attribute10, a.attribute11, a.attribute12, a.attribute13,
                   a.attribute14, a.attribute15, a.attribute16, a.attribute17,
                   a.attribute18, a.attribute19, a.attribute20, a.attribute21,
                   a.attribute22, a.attribute23, a.attribute24, a.attribute25,
                   a.attribute26, a.attribute27, a.attribute28, a.attribute29,
                   a.attribute30, a.bld_blk_info_type_id,
                   a.object_version_number, 'N' NEW, 'N' changed
              FROM hxc_time_attributes a,
                   hxc_time_attribute_usages au,
                   hxc_bld_blk_info_types bbit
             WHERE au.time_building_block_id = p_building_block_id
               AND au.time_building_block_ovn = p_bb_ovn
               AND au.time_attribute_id = a.time_attribute_id
               AND NOT (a.attribute_category = 'TEMPLATES')
               AND a.bld_blk_info_type_id = bbit.bld_blk_info_type_id
               AND a.object_version_number =
                         (SELECT MAX (object_version_number)
                            FROM hxc_time_attributes
                           WHERE time_attribute_id = a.time_attribute_id);
          */

         CURSOR csr_get_det_attr (p_building_block_id NUMBER, p_bb_ovn NUMBER)
         IS
            SELECT /*+ LEADING(AU)
                       INDEX(AU HXC_TIME_ATTRIBUTE_USAGES_FK2)
	  	       INDEX(A HXC_TIME_ATTRIBUTES_PK)
		       INDEX(BBIT HXC_BUILD_BLK_INFO_TYPES_PK) */
                   a.time_attribute_id, au.time_building_block_id,
                   bbit.bld_blk_info_type, a.attribute_category, a.attribute1,
                   a.attribute2, a.attribute3, a.attribute4, a.attribute5,
                   a.attribute6, a.attribute7, a.attribute8, a.attribute9,
                   a.attribute10, a.attribute11, a.attribute12, a.attribute13,
                   a.attribute14, a.attribute15, a.attribute16, a.attribute17,
                   a.attribute18, a.attribute19, a.attribute20, a.attribute21,
                   a.attribute22, a.attribute23, a.attribute24, a.attribute25,
                   a.attribute26, a.attribute27, a.attribute28, a.attribute29,
                   a.attribute30, a.bld_blk_info_type_id,
                   a.object_version_number, 'N' NEW, 'N' changed
              FROM hxc_time_attributes a,
                   hxc_time_attribute_usages au,
                   hxc_bld_blk_info_types bbit
             WHERE au.time_building_block_id = p_building_block_id
               AND au.time_building_block_ovn = p_bb_ovn
               AND au.time_attribute_id = a.time_attribute_id
               AND NOT (a.attribute_category = 'TEMPLATES')
               AND a.bld_blk_info_type_id = bbit.bld_blk_info_type_id ;

         l_tbb_index   NUMBER;
         l_att_index   NUMBER;
         r_det_rec     csr_get_det_bbs%ROWTYPE;
      BEGIN


         if g_debug then
         	hr_utility.TRACE ('Start of populate old tco');
         end if;
         p_timecard_building_blocks.DELETE;
         p_timecard_attributes.DELETE;
         l_tbb_index := 0;
         l_att_index := 0;

         FOR r_det_rec IN csr_get_det_bbs
         LOOP
            if g_debug then
            	hr_utility.TRACE (
            	      'r_det_rec.time_building_block_id '
            	   || r_det_rec.time_building_block_id
            	);
            	hr_utility.TRACE (
            	      'r_det_rec.object_version_number '
            	   || r_det_rec.object_version_number
            	);
            end if;
            p_timecard_building_blocks (l_tbb_index).time_building_block_id :=
                                             r_det_rec.time_building_block_id;
            p_timecard_building_blocks (l_tbb_index).TYPE := r_det_rec.TYPE;
            p_timecard_building_blocks (l_tbb_index).measure :=
                                                            r_det_rec.measure;
            p_timecard_building_blocks (l_tbb_index).unit_of_measure :=
                                                    r_det_rec.unit_of_measure;
            p_timecard_building_blocks (l_tbb_index).start_time :=
                                                         r_det_rec.start_time;
            p_timecard_building_blocks (l_tbb_index).stop_time :=
                                                          r_det_rec.stop_time;
            p_timecard_building_blocks (l_tbb_index).parent_building_block_id :=
                                           r_det_rec.parent_building_block_id;
            p_timecard_building_blocks (l_tbb_index).parent_is_new :=
                                                      r_det_rec.parent_is_new;
            p_timecard_building_blocks (l_tbb_index).SCOPE := r_det_rec.SCOPE;
            p_timecard_building_blocks (l_tbb_index).object_version_number :=
                                              r_det_rec.object_version_number;
            p_timecard_building_blocks (l_tbb_index).approval_status :=
                                                    r_det_rec.approval_status;
            p_timecard_building_blocks (l_tbb_index).resource_id :=
                                                        r_det_rec.resource_id;
            p_timecard_building_blocks (l_tbb_index).resource_type :=
                                                      r_det_rec.resource_type;
            p_timecard_building_blocks (l_tbb_index).approval_style_id :=
                                                  r_det_rec.approval_style_id;
            p_timecard_building_blocks (l_tbb_index).date_from :=
                                                          r_det_rec.date_from;
            p_timecard_building_blocks (l_tbb_index).date_to :=
                                                            r_det_rec.date_to;
            p_timecard_building_blocks (l_tbb_index).comment_text :=
                                                       r_det_rec.comment_text;
            p_timecard_building_blocks (l_tbb_index).parent_building_block_ovn :=
                                          r_det_rec.parent_building_block_ovn;
            p_timecard_building_blocks (l_tbb_index).NEW := r_det_rec.NEW;
            p_timecard_building_blocks (l_tbb_index).changed :=
                                                            r_det_rec.changed;
            l_tbb_index :=   l_tbb_index
                           + 1;

            FOR r_der_attr IN
                csr_get_det_attr (
                   r_det_rec.time_building_block_id,
                   r_det_rec.object_version_number
                )
            LOOP
               if g_debug then
               	hr_utility.TRACE (
               	      'Attribute Id'
               	   || r_der_attr.time_attribute_id
               	);
               	hr_utility.TRACE (
               	      'Attribute Category '
               	   || r_der_attr.attribute_category
               	);
               end if;
               p_timecard_attributes (l_att_index).time_attribute_id :=
                                                 r_der_attr.time_attribute_id;
               p_timecard_attributes (l_att_index).building_block_id :=
                                            r_der_attr.time_building_block_id;
               p_timecard_attributes (l_att_index).bld_blk_info_type :=
                                                 r_der_attr.bld_blk_info_type;
               p_timecard_attributes (l_att_index).attribute_category :=
                                                r_der_attr.attribute_category;
               p_timecard_attributes (l_att_index).attribute1 :=
                                                        r_der_attr.attribute1;
               p_timecard_attributes (l_att_index).attribute2 :=
                                                        r_der_attr.attribute2;
               p_timecard_attributes (l_att_index).attribute3 :=
                                                        r_der_attr.attribute3;
               p_timecard_attributes (l_att_index).attribute4 :=
                                                        r_der_attr.attribute4;
               p_timecard_attributes (l_att_index).attribute5 :=
                                                        r_der_attr.attribute5;
               p_timecard_attributes (l_att_index).attribute6 :=
                                                        r_der_attr.attribute6;
               p_timecard_attributes (l_att_index).attribute7 :=
                                                        r_der_attr.attribute7;
               p_timecard_attributes (l_att_index).attribute8 :=
                                                        r_der_attr.attribute8;
               p_timecard_attributes (l_att_index).attribute9 :=
                                                        r_der_attr.attribute9;
               p_timecard_attributes (l_att_index).attribute10 :=
                                                       r_der_attr.attribute10;
               p_timecard_attributes (l_att_index).attribute11 :=
                                                       r_der_attr.attribute11;
               p_timecard_attributes (l_att_index).attribute12 :=
                                                       r_der_attr.attribute12;
               p_timecard_attributes (l_att_index).attribute13 :=
                                                       r_der_attr.attribute13;
               p_timecard_attributes (l_att_index).attribute14 :=
                                                       r_der_attr.attribute14;
               p_timecard_attributes (l_att_index).attribute15 :=
                                                       r_der_attr.attribute15;
               p_timecard_attributes (l_att_index).attribute16 :=
                                                       r_der_attr.attribute16;
               p_timecard_attributes (l_att_index).attribute17 :=
                                                       r_der_attr.attribute17;
               p_timecard_attributes (l_att_index).attribute18 :=
                                                       r_der_attr.attribute18;
               p_timecard_attributes (l_att_index).attribute19 :=
                                                       r_der_attr.attribute19;
               p_timecard_attributes (l_att_index).attribute20 :=
                                                       r_der_attr.attribute20;
               p_timecard_attributes (l_att_index).attribute21 :=
                                                       r_der_attr.attribute21;
               p_timecard_attributes (l_att_index).attribute22 :=
                                                       r_der_attr.attribute22;
               p_timecard_attributes (l_att_index).attribute23 :=
                                                       r_der_attr.attribute23;
               p_timecard_attributes (l_att_index).attribute24 :=
                                                       r_der_attr.attribute24;
               p_timecard_attributes (l_att_index).attribute25 :=
                                                       r_der_attr.attribute25;
               p_timecard_attributes (l_att_index).attribute26 :=
                                                       r_der_attr.attribute26;
               p_timecard_attributes (l_att_index).attribute27 :=
                                                       r_der_attr.attribute27;
               p_timecard_attributes (l_att_index).attribute28 :=
                                                       r_der_attr.attribute28;
               p_timecard_attributes (l_att_index).attribute29 :=
                                                       r_der_attr.attribute29;
               p_timecard_attributes (l_att_index).attribute30 :=
                                                       r_der_attr.attribute30;
               p_timecard_attributes (l_att_index).bld_blk_info_type_id :=
                                              r_der_attr.bld_blk_info_type_id;
               p_timecard_attributes (l_att_index).object_version_number :=
                                             r_der_attr.object_version_number;
               p_timecard_attributes (l_att_index).NEW := r_der_attr.NEW;
               p_timecard_attributes (l_att_index).changed :=
                                                           r_der_attr.changed;
               l_att_index :=   l_att_index
                              + 1;
            END LOOP;
         END LOOP;

         if g_debug then
         	hr_utility.TRACE ('Leaving populate old tco');
         end if;
      END populate_old_tco;

      FUNCTION compare_tbb_attributes (
         p_attribute1   hxc_self_service_time_deposit.attribute_info,
         p_attribute2   hxc_self_service_time_deposit.attribute_info,
         p_tbb_deleted   BOOLEAN,
	 p_change_att_tab  IN OUT NOCOPY t_change_att_tab
      )
         RETURN VARCHAR2
      IS
         CURSOR csr_get_mapping_name (
            p_attribute      VARCHAR2,
            p_attribute_id   NUMBER,
            p_att_ovn        NUMBER
         )
         IS
            SELECT hmc.field_name
              FROM hxc_mapping_components hmc, hxc_time_attributes hta
             WHERE hta.time_attribute_id = p_attribute_id
               AND hta.object_version_number = p_att_ovn
               AND hta.bld_blk_info_type_id = hmc.bld_blk_info_type_id
               AND hmc.SEGMENT = UPPER (p_attribute);

         l_category_flag   BOOLEAN        := FALSE;
         l_mapping_name    VARCHAR2 (80);
         l_return_mapp     VARCHAR2 (200);
	 l_change_att_index  NUMBER:=0;

      BEGIN



	  IF p_change_att_tab.count = 0 then
	     l_change_att_index :=1;
	  ELSE
             l_change_att_index := p_change_att_tab.last+1;
          END IF;

         IF (NVL (p_attribute1.attribute_category, 'NULL') <>
                                 NVL (p_attribute2.attribute_category, 'NULL')
            )
         THEN
            l_category_flag := TRUE;
	    --Changes made to make use of bld_blk_info_type always. Removed the Attribute cateogory check
	    -- for ELEMENT -%.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    l_return_mapp :=
                        l_return_mapp
                     || ':'
                     || p_attribute1.attribute_category;

	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE_CATEGORY';
            l_change_att_index := l_change_att_index+1;

         END IF;


         IF ((NVL (p_attribute1.attribute1, 'NULL') <>
                                          NVL (p_attribute2.attribute1, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute1 IS NOT NULL
                OR p_attribute2.attribute1 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute1',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE1';
	    l_change_att_index := l_change_att_index+1;

            if g_debug then
            	hr_utility.TRACE ('Att1');
            	hr_utility.TRACE (   'l_mapping_name '
            	                  || l_mapping_name);
            	hr_utility.TRACE (   'l_return_mapp '
            	                  || l_return_mapp);
            end if;
            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute2, 'NULL') <>
                                          NVL (p_attribute2.attribute2, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

	    IF (   p_attribute1.attribute2 IS NOT NULL
                OR p_attribute2.attribute2 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute2',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE2';
	    l_change_att_index := l_change_att_index+1;

            if g_debug then
            	hr_utility.TRACE ('Att2');
            	hr_utility.TRACE (   'l_mapping_name '
            	                  || l_mapping_name);
            	hr_utility.TRACE (   'l_return_mapp '
            	                  || l_return_mapp);
            end if;
            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute3, 'NULL') <>
                                          NVL (p_attribute2.attribute3, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute3 IS NOT NULL
                OR p_attribute2.attribute3 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute3',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE3';
	    l_change_att_index := l_change_att_index+1;

            if g_debug then
            	hr_utility.TRACE ('Att3');
            	hr_utility.TRACE (   'l_mapping_name '
            	                  || l_mapping_name);
            	hr_utility.TRACE (   'l_return_mapp '
            	                  || l_return_mapp);
            end if;
            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute4, 'NULL') <>
                                          NVL (p_attribute2.attribute4, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute4 IS NOT NULL
                OR p_attribute2.attribute4 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute4',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE4';
	    l_change_att_index := l_change_att_index+1;

            if g_debug then
            	hr_utility.TRACE ('Att4');
            	hr_utility.TRACE (   'l_mapping_name '
            	                  || l_mapping_name);
            	hr_utility.TRACE (   'l_return_mapp '
            	                  || l_return_mapp);
            end if;
            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute5, 'NULL') <>
                                          NVL (p_attribute2.attribute5, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;



            IF (   p_attribute1.attribute5 IS NOT NULL
                OR p_attribute2.attribute5 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute5',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE5';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute6, 'NULL') <>
                                          NVL (p_attribute2.attribute6, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute6 IS NOT NULL
                OR p_attribute2.attribute6 IS NOT NULL
               )
            THEN


               OPEN csr_get_mapping_name (
                  'attribute6',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
    	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE6';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute7, 'NULL') <>
                                          NVL (p_attribute2.attribute7, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute7 IS NOT NULL
                OR p_attribute2.attribute7 IS NOT NULL
               )
            THEN


               OPEN csr_get_mapping_name (
                  'attribute7',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE7';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute8, 'NULL') <>
                                          NVL (p_attribute2.attribute8, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute8 IS NOT NULL
                OR p_attribute2.attribute8 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute8',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
    	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE8';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute9, 'NULL') <>
                                          NVL (p_attribute2.attribute9, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute9 IS NOT NULL
                OR p_attribute2.attribute9 IS NOT NULL
               )
            THEN
               OPEN csr_get_mapping_name (
                  'attribute9',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE9';
		    l_change_att_index := l_change_att_index+1;


            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute10, 'NULL') <>
                                         NVL (p_attribute2.attribute10, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute10 IS NOT NULL
                OR p_attribute2.attribute10 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute10',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE10';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute11, 'NULL') <>
                                         NVL (p_attribute2.attribute11, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute11 IS NOT NULL
                OR p_attribute2.attribute11 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute11',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE11';
	    l_change_att_index := l_change_att_index+1;


            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute12, 'NULL') <>
                                         NVL (p_attribute2.attribute12, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute12 IS NOT NULL
                OR p_attribute2.attribute12 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute12',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE12';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute13, 'NULL') <>
                                         NVL (p_attribute2.attribute13, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN

            l_mapping_name := NULL;


            IF (   p_attribute1.attribute13 IS NOT NULL
                OR p_attribute2.attribute13 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute13',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE13';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute14, 'NULL') <>
                                         NVL (p_attribute2.attribute14, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute14 IS NOT NULL
                OR p_attribute2.attribute14 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute14',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE14';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute15, 'NULL') <>
                                         NVL (p_attribute2.attribute15, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute15 IS NOT NULL
                OR p_attribute2.attribute15 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute15',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE15';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute16, 'NULL') <>
                                         NVL (p_attribute2.attribute16, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute16 IS NOT NULL
                OR p_attribute2.attribute16 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute16',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE16';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute17, 'NULL') <>
                                         NVL (p_attribute2.attribute17, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute17 IS NOT NULL
                OR p_attribute2.attribute17 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute17',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE17';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute18, 'NULL') <>
                                         NVL (p_attribute2.attribute18, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute18 IS NOT NULL
                OR p_attribute2.attribute18 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute18',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE18';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute19, 'NULL') <>
                                         NVL (p_attribute2.attribute19, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute19 IS NOT NULL
                OR p_attribute2.attribute19 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute19',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
            p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE19';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute20, 'NULL') <>
                                         NVL (p_attribute2.attribute20, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute20 IS NOT NULL
                OR p_attribute2.attribute20 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute20',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE20';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute21, 'NULL') <>
                                         NVL (p_attribute2.attribute21, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute21 IS NOT NULL
                OR p_attribute2.attribute21 IS NOT NULL
               )
            THEN


               OPEN csr_get_mapping_name (
                  'attribute21',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE21';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute22, 'NULL') <>
                                         NVL (p_attribute2.attribute22, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute22 IS NOT NULL
                OR p_attribute2.attribute22 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute22',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE22';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute23, 'NULL') <>
                                         NVL (p_attribute2.attribute23, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute23 IS NOT NULL
                OR p_attribute2.attribute23 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute23',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE23';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute24, 'NULL') <>
                                         NVL (p_attribute2.attribute24, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute24 IS NOT NULL
                OR p_attribute2.attribute24 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute24',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE24';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute25, 'NULL') <>
                                         NVL (p_attribute2.attribute25, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute25 IS NOT NULL
                OR p_attribute2.attribute25 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute25',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE25';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute26, 'NULL') <>
                                         NVL (p_attribute2.attribute26, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;


            IF (   p_attribute1.attribute26 IS NOT NULL
                OR p_attribute2.attribute26 IS NOT NULL
               )
            THEN
               OPEN csr_get_mapping_name (
                  'attribute26',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE26';
	    l_change_att_index := l_change_att_index+1;


            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute27, 'NULL') <>
                                         NVL (p_attribute2.attribute27, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute27 IS NOT NULL
                OR p_attribute2.attribute27 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute27',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
		    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE27';
		    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute28, 'NULL') <>
                                         NVL (p_attribute2.attribute28, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute28 IS NOT NULL
                OR p_attribute2.attribute28 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute28',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
            p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE28';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute29, 'NULL') <>
                                         NVL (p_attribute2.attribute29, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute29 IS NOT NULL
                OR p_attribute2.attribute29 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute29',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE29';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

         IF ((NVL (p_attribute1.attribute30, 'NULL') <>
                                         NVL (p_attribute2.attribute30, 'NULL')
	     OR p_tbb_deleted)
            )
         THEN
            l_mapping_name := NULL;

            IF (   p_attribute1.attribute30 IS NOT NULL
                OR p_attribute2.attribute30 IS NOT NULL
               )
            THEN

               OPEN csr_get_mapping_name (
                  'attribute30',
                  p_attribute1.time_attribute_id,
                  p_attribute1.object_version_number
               );
               FETCH csr_get_mapping_name INTO l_mapping_name;
               CLOSE csr_get_mapping_name;
            END IF;
	    --Changes made to make use of bld_blk_info_type always.
    	    p_change_att_tab(l_change_att_index).attribute_category :=p_attribute1.bld_blk_info_type;
	    p_change_att_tab(l_change_att_index).changed_attribute  :='ATTRIBUTE30';
	    l_change_att_index := l_change_att_index+1;

            l_return_mapp :=    l_return_mapp
                             || ':'
                             || l_mapping_name;
         END IF;

	 if g_debug then
	 	hr_utility.TRACE (l_return_mapp);
	 end if;
         RETURN l_return_mapp;
      END compare_tbb_attributes;

      FUNCTION compare_time_building_blocks (
         p_block1   hxc_self_service_time_deposit.building_block_info,
         p_block2   hxc_self_service_time_deposit.building_block_info,
	 p_tbb_deleted BOOLEAN,
	 p_change_att_tab  IN OUT NOCOPY t_change_att_tab
	 )
         RETURN VARCHAR2
      IS
      CURSOR csr_get_mapping_name(p_segment varchar2)
      IS
      SELECT hmc.field_name
        FROM hxc_mapping_components hmc, hxc_bld_blk_info_types hbb
       WHERE hmc.segment = upper(p_segment)
         AND hbb.BLD_BLK_INFO_TYPE_ID = hmc.bld_blk_info_type_id
         AND hbb.BLD_BLK_INFO_TYPE = 'BUILDING_BLOCKS';
/*
CURSOR csr_get_mapping_name(p_segment varchar2)
      IS
select substr(fcu.form_left_prompt,1,30)
from hxc_mapping_components mc
    ,hxc_bld_blk_info_types bbit
    ,fnd_descr_flex_col_usage_tl fcu
where
  mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  and fcu.application_column_name = mc.segment
  and fcu.descriptive_flex_context_code = bbit.bld_blk_info_type
  and fcu.descriptive_flexfield_name = 'OTC Information Types'
  and fcu.application_id = 809
  and fcu.language = userenv('LANG')
  and fcu.application_column_name=p_segment
  AND bbit.bld_blk_info_type='BUILDING_BLOCKS';
*/

         l_ret_val   VARCHAR2 (300);
	 l_mapping_name VARCHAR2(80);
	 l_change_att_index NUMBER;
      BEGIN



	  IF p_change_att_tab.count = 0 then
	     l_change_att_index :=1;
	  ELSE
             l_change_att_index := p_change_att_tab.last+1;
          END IF;

         if g_debug then
         	hr_utility.TRACE (   'p_block1.scope'
         	                  || p_block1.SCOPE);
         	hr_utility.TRACE (   'p_block2.scope'
         	                  || p_block2.SCOPE);
         end if;

         IF (p_block1.SCOPE = 'DETAIL')
         THEN

--
-- There is only a subset of things that
-- can be changed in the block, we
-- look for these things
--
-- 1. Measure
            IF ((NVL (p_block1.measure,0) <> NVL (p_block2.measure, 0))
	         OR
		(p_block1.measure is not null and p_tbb_deleted ))
            THEN
               if g_debug then
               	hr_utility.TRACE ('Before assignment');
               end if;
	       OPEN csr_get_mapping_name('ATTRIBUTE1');
               FETCH  csr_get_mapping_name INTO l_mapping_name;
	       CLOSE csr_get_mapping_name;

	       p_change_att_tab(l_change_att_index).attribute_category :=NULL;
	       p_change_att_tab(l_change_att_index).changed_attribute  :=l_mapping_name;
	       p_change_att_tab(l_change_att_index).org_attribute_category :='BUILDING_BLOCKS';
	       p_change_att_tab(l_change_att_index).org_changed_attribute  :='ATTRIBUTE1';
	       l_change_att_index := p_change_att_tab.last+1;

               l_ret_val := 'BUILDING_BLOCKS'||'|'||'ATTRIBUTE1'||'|'||l_mapping_name;
               if g_debug then
               	hr_utility.TRACE ('After Assignment');
               end if;
            END IF;

            if g_debug then
            	hr_utility.TRACE ('l_ret_val');
            end if;

-- 2. Start Time
            IF ((NVL (p_block1.start_time, to_date('01-01-0090','dd-mm-rrrr')) <>
                NVL (p_block2.start_time, to_date('01-01-0090','dd-mm-rrrr')))
	         OR
		(p_block1.start_time is not null and p_tbb_deleted )
               )
            THEN
               if g_debug then
               	hr_utility.TRACE (   'l_ret_val'
               	                  || l_ret_val);
               end if;
       	       OPEN csr_get_mapping_name('ATTRIBUTE2');
	          FETCH  csr_get_mapping_name INTO l_mapping_name;
	       CLOSE csr_get_mapping_name;

	       p_change_att_tab(l_change_att_index).attribute_category :=NULL;
	       p_change_att_tab(l_change_att_index).changed_attribute  :=l_mapping_name;
       	       p_change_att_tab(l_change_att_index).org_attribute_category :='BUILDING_BLOCKS';
	       p_change_att_tab(l_change_att_index).org_changed_attribute  :='ATTRIBUTE2';
	       l_change_att_index := p_change_att_tab.last+1;

               l_ret_val := l_ret_val || ':' || 'BUILDING_BLOCKS'||'|'||'ATTRIBUTE2'||'|'||l_mapping_name;

            END IF;


-- 3. Stop Time
            IF ((NVL (p_block1.stop_time, to_date('01-01-0090','dd-mm-rrrr')) <>
                NVL (p_block2.stop_time, to_date('01-01-0090','dd-mm-rrrr')))
		OR
		(p_block1.stop_time is not null and p_tbb_deleted )
               )
            THEN
       	       OPEN csr_get_mapping_name('ATTRIBUTE3');
	          FETCH  csr_get_mapping_name INTO l_mapping_name;
	       CLOSE csr_get_mapping_name;
       	       p_change_att_tab(l_change_att_index).attribute_category :=NULL;
	       p_change_att_tab(l_change_att_index).changed_attribute  :=l_mapping_name;
       	       p_change_att_tab(l_change_att_index).org_attribute_category :='BUILDING_BLOCKS';
	       p_change_att_tab(l_change_att_index).org_changed_attribute  :='ATTRIBUTE3';

	       l_change_att_index := p_change_att_tab.last+1;

               l_ret_val := l_ret_val || ':' || 'BUILDING_BLOCKS'||'|'||'ATTRIBUTE3'||'|'||l_mapping_name;
            END IF;


-- 4. Comment

            IF ((NVL (p_block1.comment_text, 'NULL') <>
                                            NVL (p_block2.comment_text, 'NULL'))
		OR
		(p_block1.comment_text is not null and p_tbb_deleted )
               )
            THEN
       	       OPEN csr_get_mapping_name('ATTRIBUTE4');
	          FETCH  csr_get_mapping_name INTO l_mapping_name;
	       CLOSE csr_get_mapping_name;
       	       p_change_att_tab(l_change_att_index).attribute_category :=NULL;
	       p_change_att_tab(l_change_att_index).changed_attribute  :=l_mapping_name;
       	       p_change_att_tab(l_change_att_index).org_attribute_category :='BUILDING_BLOCKS';
	       p_change_att_tab(l_change_att_index).org_changed_attribute  :='ATTRIBUTE4';
	       l_change_att_index := p_change_att_tab.last+1;

              l_ret_val := l_ret_val || ':' ||'BUILDING_BLOCKS'||'|'||'ATTRIBUTE4'||'|'||l_mapping_name;

            END IF;
	 END IF;
         RETURN l_ret_val;
      END compare_time_building_blocks;

      PROCEDURE execute_change_ter (
         p_tco_bb          IN       hxc_self_service_time_deposit.timecard_info,
         p_tco_att         IN       hxc_self_service_time_deposit.building_block_attribute_info,
         p_message_table   IN OUT NOCOPY  hxc_self_service_time_deposit.message_table,
         p_message_level            VARCHAR2,
         p_rule_record              hxc_time_entry_rules_utils_pkg.csr_get_rules%ROWTYPE
      )
      IS
   /*   CURSOR csr_get_mapping_name(p_segment varchar2)
      IS
      SELECT hmc.field_name
        FROM hxc_mapping_components hmc, hxc_bld_blk_info_types hbb
       WHERE hmc.segment = upper(p_segment)
         AND hbb.BLD_BLK_INFO_TYPE_ID = hmc.bld_blk_info_type_id
         AND hbb.BLD_BLK_INFO_TYPE = 'BUILDING_BLOCKS';*/

         l_time_category_id    hxc_time_categories.time_category_id%TYPE;
         l_tbb_index           NUMBER;
         l_att_index           NUMBER;
         l_old_tbb_index       NUMBER;
         l_old_att_index       NUMBER;
         l_old_tco_bb          hxc_self_service_time_deposit.timecard_info;
         l_old_tco_att         hxc_self_service_time_deposit.building_block_attribute_info;
         l_timecard_info_rec   hxc_time_entry_rules_utils_pkg.r_timecard_info;
         l_build_change_list   VARCHAR2 (2000);
         l_change_list         VARCHAR2 (2000);
         l_time_cat_tab        hxc_time_category_utils_pkg.t_time_category;
         l_long                LONG;
         l_operator            hxc_time_categories.OPERATOR%TYPE;
         l_tc_bb_ok_tab        hxc_time_category_utils_pkg.t_tc_bb_ok;
         l_tc_bb_ok_tab_old    hxc_time_category_utils_pkg.t_tc_bb_ok;
	 l_tc_bb_ok_string     VARCHAR2(32000);
	 l_tc_bb_not_ok_string VARCHAR2(32000);
         n                     NUMBER;
	 l_tbb_deleted         BOOLEAN;
         l_change_att_tab      t_change_att_tab;

      BEGIN


         if g_debug then
         	hr_utility.TRACE ('Before get_timecard_info');
         end if;
         get_timecard_info (
            p_time_building_blocks=> P_TIME_BUILDING_BLOCKS,
            p_timecard_rec=> l_timecard_info_rec
         );

         if g_debug then
         	hr_utility.TRACE ('Before populate_old_tco');
         end if;
         populate_old_tco (
            p_timecard_rec=> l_timecard_info_rec,
            p_timecard_building_blocks=> l_old_tco_bb,
            p_timecard_attributes=> l_old_tco_att
         );

         IF (p_rule_record.attribute1 IS NOT NULL)
         THEN
            if g_debug then
            	hr_utility.TRACE (
            	      'Attribute 1 -- Time Category '
            	   || p_rule_record.attribute1
            	);
            end if;

            -- populate the time category bb ok  table

		hxc_time_category_utils_pkg.evaluate_time_category (
                            p_time_category_id     => p_rule_record.attribute1
                        ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab
                        ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                        ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string );

	    -- populate the old attribute table


	hxc_time_category_utils_pkg.push_attributes ( l_old_tco_att );


            -- populate the time category bb ok  table

		hxc_time_category_utils_pkg.evaluate_time_category (
                            p_time_category_id     => p_rule_record.attribute1
                        ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab_old
                        ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                        ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string
                        ,   p_use_tc_bb_cache      => FALSE );

	      -- put back the original attributes

		hxc_time_category_utils_pkg.push_attributes ( p_tco_att );

         END IF;

         if g_debug then
         	hr_utility.TRACE ('Returned from populate_old_tco');
         end if;

        n:= l_old_tco_bb.first;
	loop
	   exit when not l_old_tco_bb.exists(n);
	   if g_debug then
	   	hr_utility.trace('ID    ' || 'OVN'  || 'SCOPE' || 'Changed' || 'New' || 'Date To');
	   	hr_utility.trace(l_old_tco_bb(n).time_building_block_id||'   ' || l_old_tco_bb(n).object_version_number|| '  ' || l_old_tco_bb(n).scope ||'  '
	   	|| l_old_tco_bb(n).changed|| '   ' ||l_old_tco_bb(n).new || to_char(l_old_tco_bb(n).date_to,'dd-mon-rrrr'));
	   end if;
	   n := p_time_building_blocks.next(n);
	end loop;

         l_tbb_index := p_tco_att.FIRST;

         LOOP
            EXIT WHEN NOT p_tco_att.EXISTS (l_tbb_index);
            if g_debug then
            	hr_utility.TRACE (
            	      p_tco_att (l_tbb_index).time_attribute_id
            	   || '   ' || p_tco_att (l_tbb_index).object_version_number
            	   ||  'attribute_category' || p_tco_att (l_tbb_index).attribute_category
            	   || 'attribute1 '|| p_tco_att (l_tbb_index).attribute1
            	   || 'Attribute2 '|| p_tco_att (l_tbb_index).attribute2
            	);
            end if;
            l_tbb_index := p_tco_att.NEXT (l_tbb_index);
         END LOOP;

         if g_debug then
         	hr_utility.TRACE ('OLD TBB');
         end if;
         l_old_tbb_index := l_old_tco_att.FIRST;

         LOOP
            EXIT WHEN NOT l_old_tco_att.EXISTS (l_old_tbb_index);
            if g_debug then
            	hr_utility.TRACE (
            	      l_old_tco_att (l_old_tbb_index).time_attribute_id
            	   || '  '|| l_old_tco_att (l_old_tbb_index).object_version_number
            	   ||  'Attribute_category '|| l_old_tco_att (l_old_tbb_index).attribute_category
            	   || 'Attribute1 '|| l_old_tco_att (l_old_tbb_index).attribute1
            	   || 'Attribute2 '|| l_old_tco_att (l_old_tbb_index).attribute2
            	);
            end if;
            l_old_tbb_index := l_old_tco_att.NEXT (l_old_tbb_index);
         END LOOP;

         l_tbb_index := p_tco_bb.FIRST;


/* Loop through Building blocks */
         LOOP
            if g_debug then
            	hr_utility.TRACE ('Timecard Loop');
            end if;
            l_build_change_list := null;
            l_tbb_deleted := FALSE;
            EXIT WHEN NOT p_tco_bb.EXISTS (l_tbb_index);

            L_CHANGE_ATT_TAB.delete;

            IF (    p_tco_bb (l_tbb_index).SCOPE = 'DETAIL'
                AND p_tco_bb (l_tbb_index).new <> 'Y'
               )
            THEN


	       l_old_tbb_index := l_old_tco_bb.FIRST;
               if g_debug then
               	hr_utility.TRACE ('Old Timecard Loop');
               end if;
               if (trunc(p_tco_bb(l_tbb_index).date_to) = trunc(sysdate)) then
	          l_tbb_deleted := TRUE;
	       else
	          l_tbb_deleted := FALSE;
	       end if;
               LOOP
                  EXIT WHEN NOT l_old_tco_bb.EXISTS (l_old_tbb_index); -- OR l_tbb_deleted;
                  l_change_list := NULL;
                  if g_debug then
                  	hr_utility.TRACE ('TBB Test');
                  end if;

if g_debug then
	hr_utility.trace('new bb/ovn is '||to_char(p_tco_bb(l_tbb_index).time_building_block_id)||':'
	||to_char(p_tco_bb(l_tbb_index).object_version_number));

	hr_utility.trace('old bb/ovn is '||to_char(l_old_tco_bb(l_old_tbb_index).time_building_block_id)||':'
	||to_char(l_old_tco_bb(l_old_tbb_index).object_version_number));
end if;

                  IF (    p_tco_bb (l_tbb_index).time_building_block_id =
                                l_old_tco_bb (l_old_tbb_index).time_building_block_id
                      AND p_tco_bb (l_tbb_index).object_version_number =
                                l_old_tco_bb (l_old_tbb_index).object_version_number
                     )
                  THEN

                     IF (   (p_rule_record.attribute1 IS NULL)
                         OR (    p_rule_record.attribute1 IS NOT NULL
                             AND (   l_tc_bb_ok_tab.EXISTS (
                                        p_tco_bb (l_tbb_index).time_building_block_id
                                     )
                                  OR l_tc_bb_ok_tab_old.EXISTS (
                                        p_tco_bb (l_tbb_index).time_building_block_id
                                     )
                                 )
                            )
                        )
                     THEN

		-- GPM v115.76 WWB 3027077

		-- moved the compare time building blocks to after the
		-- above time category check.

                     l_change_list := NULL;
                     l_build_change_list := NULL;

                     l_change_list :=
                           compare_time_building_blocks (
                              l_old_tco_bb (l_old_tbb_index),
                              p_tco_bb (l_tbb_index),
			      l_tbb_deleted,
			      l_change_att_tab
			      );
/*
		     l_build_change_list :=
                                         l_build_change_list
                                      || l_change_list;


		        l_build_change_list := l_change_list;
*/
                        l_old_att_index := l_old_tco_att.FIRST;

                        LOOP
                           EXIT WHEN NOT l_old_tco_att.EXISTS (
                                            l_old_att_index
                                         );

                           IF (l_old_tco_att (l_old_att_index).building_block_id =
                                     p_tco_bb (l_tbb_index).time_building_block_id
			       AND l_old_tco_att(l_old_att_index).attribute_category <> 'REASON'
                              )
                           THEN

                              l_att_index := p_tco_att.FIRST;

                              LOOP
                                 EXIT WHEN NOT p_tco_att.EXISTS (l_att_index);
                                 IF (l_old_tco_att (l_old_att_index).time_attribute_id =
                                        p_tco_att (l_att_index).time_attribute_id
				     --AND p_tco_att(l_att_index).changed = 'Y'
                                    )
                                 THEN
                                    l_change_list := NULL;
                                    l_change_list :=
                                       compare_tbb_attributes (
                                          p_tco_att (l_att_index),
                                          l_old_tco_att (l_old_att_index),
					  l_tbb_deleted,
					  l_change_att_tab
                                       );
				       /*
				    IF (l_change_list IS NOT NULL)
                                    THEN
                                       l_build_change_list :=
                                             l_build_change_list
                                          || l_change_list;
                                    END IF;
				    */
                                 END IF;

                                 l_att_index := p_tco_att.NEXT (l_att_index);
                                 if g_debug then
                                 	hr_utility.TRACE ('After old attr loop');
                                 end if;
                              END LOOP;
                           END IF;

                           l_old_att_index :=l_old_tco_att.NEXT (l_old_att_index);
                        END LOOP;
                     END IF; -- TBB in attribute category.
                  END IF; -- l_tc_bb_ok_tab.EXISTS and l_tc_bb_ok_tab_old.EXISTS check

                  l_old_tbb_index := l_old_tco_bb.NEXT (l_old_tbb_index);

               END LOOP;
            END IF;

	IF L_CHANGE_ATT_TAB.count >0 then

		hxc_alias_utility.time_entry_rules_segment_trans
		(
		p_timecard_id	    =>l_timecard_info_rec.timecard_bb_id
               ,p_timecard_ovn      =>l_timecard_info_rec.timecard_ovn
               ,p_start_time        =>l_timecard_info_rec.start_date
               ,p_stop_time         =>l_timecard_info_rec.end_date
               ,p_resource_id       =>l_timecard_info_rec.resource_id
               ,p_attr_change_table =>L_CHANGE_ATT_TAB
		);

	    FOR I IN 1..L_CHANGE_ATT_TAB.COUNT LOOP

	        IF nvl(L_CHANGE_ATT_TAB(i).attribute_category,'xx') <> 'ATTRIBUTE_CATEGORY'
		  then
		   if nvl(L_CHANGE_ATT_TAB(i).org_attribute_category,'XX') ='BUILDING_BLOCKS' then

			if l_build_change_list is null then
				l_build_change_list :=  L_CHANGE_ATT_TAB(i).org_attribute_category ||'|'||L_CHANGE_ATT_TAB(i).org_changed_attribute||'|'||L_CHANGE_ATT_TAB(i).field_name;
			else
  			        l_build_change_list := l_build_change_list ||':'|| L_CHANGE_ATT_TAB(i).org_attribute_category ||'|'||L_CHANGE_ATT_TAB(i).org_changed_attribute||'|'||L_CHANGE_ATT_TAB(i).field_name;
			end if;
		   else
   			if l_build_change_list is null then
				l_build_change_list :=  L_CHANGE_ATT_TAB(i).attribute_category ||'|'||L_CHANGE_ATT_TAB(i).changed_attribute||'|'||L_CHANGE_ATT_TAB(i).field_name;
			else
  			        l_build_change_list := l_build_change_list ||':'|| L_CHANGE_ATT_TAB(i).attribute_category ||'|'||L_CHANGE_ATT_TAB(i).changed_attribute||'|'||L_CHANGE_ATT_TAB(i).field_name;
			end if;
		   end if;
		END IF;

	    END LOOP;

         END IF;


/*	    if (l_tbb_deleted ) then
               open csr_get_mapping_name('attribute1');
   	         fetch csr_get_mapping_name into l_build_change_list;
   	       close csr_get_mapping_name;
	    end if;*/

            IF (l_build_change_list IS NOT NULL)
            THEN
               add_error_to_table (
                  p_message_table=> p_message_table,
                  p_message_name=> 'HXC_AUDIT_MSG',
                  p_message_token=> 'CHANGE',
                  p_message_level=> p_message_level,
                  p_message_field=> substr(l_build_change_list,1,2000),
                  p_timecard_bb_id=> p_tco_bb (l_tbb_index).time_building_block_id,
                  p_time_attribute_id=> NULL,
                  p_timecard_bb_ovn=> p_tco_bb (l_tbb_index).object_version_number,
                  p_time_attribute_ovn=> NULL
               );
            END IF;

            l_tbb_index := p_tco_bb.NEXT (l_tbb_index);
         END LOOP;

      END execute_change_ter;

      PROCEDURE execute_late_ter (
         p_tco_bb          IN       hxc_self_service_time_deposit.timecard_info,
         p_tco_att         IN       hxc_self_service_time_deposit.building_block_attribute_info,
         p_message_table   IN OUT  NOCOPY  hxc_self_service_time_deposit.message_table,
         p_message_level            VARCHAR2,
         p_rule_record              hxc_time_entry_rules_utils_pkg.csr_get_rules%ROWTYPE
      )
      IS
         l_time_category_id   hxc_time_categories.time_category_id%TYPE;
         l_tbb_index          NUMBER;
	 l_tbb_parent_index   NUMBER;
	 l_date_worked        DATE;
         n                    NUMBER;
      BEGIN



         l_time_category_id := p_rule_record.attribute1;

         IF (l_time_category_id IS NOT NULL)
         THEN
            hxc_time_category_utils_pkg.initialise_time_category (
               p_time_category_id=> TO_NUMBER (l_time_category_id),
               p_tco_att=> p_tco_att
            );
            l_tbb_index := p_tco_bb.FIRST;
            if g_debug then
            	hr_utility.TRACE ('Outside Loop');
            end if;

            LOOP
               EXIT WHEN NOT p_tco_bb.EXISTS (l_tbb_index);

               IF (    p_tco_bb (l_tbb_index).SCOPE = 'DETAIL'
                   AND p_tco_bb (l_tbb_index).new = 'Y'
		   -- Bug 2958441
		   AND p_tco_bb (l_tbb_index).date_to = hr_general.end_of_time
		   -- Bug 2958441
                  )
               THEN
	          l_date_worked := NULL;
	          If (p_tco_bb (l_tbb_index).stop_time is null) then
		      l_tbb_parent_index := p_tco_bb.first;
		      LOOP
		         exit when not p_tco_bb.exists(l_tbb_parent_index);
		         if (p_tco_bb(l_tbb_parent_index).time_building_block_id = p_tco_bb(l_tbb_index).parent_building_block_id )
			 THEN
			     l_date_worked := p_tco_bb(l_tbb_parent_index).start_time;
			     exit;
			 end if;
			 l_tbb_parent_index := p_tco_bb.next(l_tbb_parent_index);
		      END LOOP;
		   END IF;

                  IF (hxc_time_category_utils_pkg.chk_tc_bb_ok (
                         p_tco_bb (l_tbb_index).time_building_block_id
                      )
                     )
                  THEN
                     IF (chk_bb_late (
                            p_stop_time=> p_tco_bb (l_tbb_index).stop_time,
                            p_st_late_hrs=> fnd_number.canonical_to_number(p_rule_record.attribute2),
                            p_qnt_late_hrs=> fnd_number.canonical_to_number(p_rule_record.attribute3),
			    p_date_worked => l_date_worked
                         )
                        )
                     THEN
                        hxc_time_entry_rules_utils_pkg.add_error_to_table (
                           p_message_table=> p_messages,
                           p_message_name=> 'HXC_AUDIT_MSG',
                           p_message_token=> 'LATE',
                           p_message_level=> p_message_level,
                           p_message_field=> NULL,
                           p_timecard_bb_id=> p_tco_bb (l_tbb_index).time_building_block_id,
                           p_time_attribute_id=> NULL,
                           p_timecard_bb_ovn=> p_tco_bb (l_tbb_index).object_version_number,
                           p_time_attribute_ovn=> NULL
                        );
                     END IF;
                  END IF;
               END IF;

               l_tbb_index := p_tco_bb.NEXT (l_tbb_index);
            END LOOP;
         ELSE
            l_tbb_index := p_tco_bb.FIRST;

            LOOP
               EXIT WHEN NOT p_tco_bb.EXISTS (l_tbb_index);

               IF (    p_tco_bb (l_tbb_index).SCOPE = 'DETAIL'
                   AND p_tco_bb (l_tbb_index).new = 'Y'
		   -- Bug 2958441
		   AND p_tco_bb (l_tbb_index).date_to = hr_general.end_of_time
		   -- Bug 2958441
                  )
               THEN
  	          l_date_worked := NULL;
	          If (p_tco_bb (l_tbb_index).stop_time is null) then
		      l_tbb_parent_index := p_tco_bb.first;
		      LOOP
		         exit when not p_tco_bb.exists(l_tbb_parent_index);
		         if (p_tco_bb(l_tbb_parent_index).time_building_block_id = p_tco_bb(l_tbb_index).parent_building_block_id )
			 THEN
			     l_date_worked := p_tco_bb(l_tbb_parent_index).start_time;
			     exit;
			 end if;
			 l_tbb_parent_index := p_tco_bb.next(l_tbb_parent_index);
		      END LOOP;
		   END IF;
                  IF (chk_bb_late (
                         p_stop_time=> p_tco_bb (l_tbb_index).stop_time,
                         p_st_late_hrs=> fnd_number.canonical_to_number(p_rule_record.attribute2),
                         p_qnt_late_hrs=> fnd_number.canonical_to_number(p_rule_record.attribute3),
			 p_date_worked => l_date_worked
                      )
                     )
                  THEN
                     hxc_time_entry_rules_utils_pkg.add_error_to_table (
                        p_message_table=> p_messages,
                        p_message_name=> 'HXC_AUDIT_MSG',
                        p_message_token=> 'LATE' --p_rule_record.rule_outcome
                                                ,
                        p_message_level=> p_message_level,
                        p_message_field=> NULL,
                        p_timecard_bb_id=> p_tco_bb (l_tbb_index).time_building_block_id,
                        p_time_attribute_id=> NULL,
                        p_timecard_bb_ovn=> p_tco_bb (l_tbb_index).object_version_number,
                        p_time_attribute_ovn=> NULL
                     );
                  END IF;
               END IF;

               l_tbb_index := p_tco_bb.NEXT (l_tbb_index);
            END LOOP;
         END IF;

         if g_debug then
         	hr_utility.TRACE ('CLA Lateeeeeeeeeeeeeee Message Table');
	 	hr_utility.trace('Count ' || p_messages.count);
	 end if;
         n := p_messages.FIRST;

         LOOP
            EXIT WHEN NOT p_messages.EXISTS (n);

            IF (p_messages (n).message_level = 'REASON')
            THEN
               if g_debug then
               	hr_utility.TRACE ('Time Building Block Id' || 'Time Building Block OVN' || 'message_name');
	       	hr_utility.trace(p_messages (n).time_building_block_id || '   ' || p_messages (n).time_building_block_ovn || '  ' || p_messages (n).message_name);
	       end if;
            END IF;
            n := p_messages.NEXT (n);
         END LOOP;
	 if g_debug then
	 	hr_utility.trace('End Lateeeeeeeeeeeeeee');
	 end if;
      END execute_late_ter;
Begin

g_debug := hr_utility.debug_enabled;

n:= p_time_building_blocks.first;
loop
   exit when not p_time_building_blocks.exists(n);
   if g_debug then
   	hr_utility.trace('ID    ' || 'OVN'  || 'SCOPE' || 'Changed' || 'New' || '   ' || 'Date to');
   	hr_utility.trace(p_time_building_blocks(n).time_building_block_id||'   ' || p_time_building_blocks(n).object_version_number|| '  ' || p_time_building_blocks(n).scope ||'  '
   	|| p_time_building_blocks(n).changed|| '   ' ||p_time_building_blocks(n).new || to_char(p_time_building_blocks(n).date_to,'dd-mon-rrrr'));
   end if;
   n := p_time_building_blocks.next(n);
end loop;
get_timecard_info (
		p_time_building_blocks	=> P_TIME_BUILDING_BLOCKS
	,	p_timecard_rec          => l_timecard_info_rec );
if g_debug then
	hr_utility.trace('After get_timecard_info');
	hr_utility.trace('start_date ' || l_timecard_info_rec.start_date);
end if;

n := p_messages.first;
loop
    exit when not p_messages.exists(n);
    if (p_messages(n).message_level = 'ERROR') then
        return;
    end if;
    n := p_messages.next(n);
end loop;
/*  Start 2944785
-- GPM v115.55 / v115.56
hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_AUDIT_REQUIREMENTS',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table  => l_prefs );

IF ( l_prefs.COUNT > 1 )
THEN
	-- error since cannot have more than one CLA preference in timecard period
	-- in the interim take the first available value
	l_terg_id := l_prefs(1).attribute1;
ELSE
	l_terg_id := l_prefs(1).attribute1;
END IF;
*/
l_terg_id := P_TIME_ENTRY_RULE_GROUP_ID;
-- GPM v115.55
-- End 2944785
FOR r_rules IN csr_get_rules ( p_terg_id        => l_terg_id
			,      p_start_date	=> l_timecard_info_rec.start_date
			,      p_end_date	=> l_timecard_info_rec.end_date )
LOOP
               IF (r_rules.formula_name = 'HXC_CLA_CHANGE_FORMULA')
               THEN
                  execute_change_ter (
                     p_tco_bb=> P_TIME_BUILDING_BLOCKS,
                     p_tco_att=> p_time_attributes,
                     p_message_table=> p_messages,
                     p_message_level=> r_rules.rule_outcome,
                     p_rule_record=> r_rules
                  );
               ELSIF (r_rules.formula_name = 'HXC_CLA_LATE_FORMULA')
               THEN
                  execute_late_ter (
                     p_tco_bb=> P_TIME_BUILDING_BLOCKS,
                     p_tco_att=> p_time_attributes,
                     p_message_table=> p_messages,
                     p_message_level=> r_rules.rule_outcome,
                     p_rule_record=> r_rules
                  );
	      END IF;
end loop;


if g_debug then
	hr_utility.trace('Final Message Table -- Late + Change......');
end if;
n := p_messages.first;
loop
    exit when not p_messages.exists(n);
    if (p_messages(n).message_level = 'REASON') then
        if g_debug then
        	hr_utility.trace('Time Building Block Id' || p_messages(n).time_building_block_id);
		hr_utility.trace('Time Building Block OVN' || p_messages(n).time_building_block_ovn);
		hr_utility.trace('Message name' || p_messages(n).message_name);
		hr_utility.trace('Message Level' || p_messages(n).message_level);
		hr_utility.trace('Message Tokens' || p_messages(n).message_tokens);
		hr_utility.trace('Field name' || p_messages(n).message_field);
		hr_utility.trace('Recipient Application ID' || p_messages(n).message_name);
	end if;
    end if;
    n := p_messages.next(n);
end loop;

if g_debug then
	hr_utility.trace('End of execute CLA time entry rules');
end if;

end EXECUTE_CLA_TIME_ENTRY_RULES;

PROCEDURE GET_PROMPTS (p_block_id IN NUMBER,
		      p_blk_ovn IN NUMBER,
		      p_attribute  IN VARCHAR2,
		      p_blk_type IN VARCHAR2,
		      p_prompt IN OUT NOCOPY VARCHAR2)
IS
CURSOR C_GET_PROMPT_NAME(p_attribute VARCHAR2) IS
SELECT substr(fcu.form_left_prompt,1,30) prompt
FROM hxc_mapping_components mc
    ,hxc_bld_blk_info_types bbit
    ,fnd_descr_flex_col_usage_tl fcu
    ,hxc_time_attributes hta
WHERE mc.SEGMENT= UPPER(p_attribute) --mapping_component_id = p_comp_id
  AND mc.bld_blk_info_type_id = hta.bld_blk_info_type_id
  AND hta.time_attribute_id = p_block_id
  AND hta.object_version_number = p_blk_ovn
  AND mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
  AND fcu.application_column_name = mc.segment
  AND fcu.descriptive_flex_context_code = bbit.bld_blk_info_type
  AND fcu.descriptive_flexfield_name = 'OTC Information Types'
  AND fcu.application_id = 809
  AND fcu.language = userenv('LANG');

CURSOR C_GET_PROMPT_BLK(p_attribute VARCHAR2) is
SELECT hmc.field_name
  FROM hxc_mapping_components hmc, hxc_bld_blk_info_types hbb
 WHERE hmc.segment = upper(p_attribute)
   AND hbb.BLD_BLK_INFO_TYPE_ID = hmc.bld_blk_info_type_id
   AND hbb.BLD_BLK_INFO_TYPE = 'BUILDING_BLOCKS';
l_prompt_name varchar2(30);
Begin
   g_debug := hr_utility.debug_enabled;

   if (p_blk_type = 'BUILDING_BLOCK' ) then
     open c_get_prompt_blk(p_attribute);
       fetch c_get_prompt_blk into l_prompt_name;
       if g_debug then
       	hr_utility.trace('Prompt ' || l_prompt_name);
       end if;
       if c_get_prompt_blk%FOUND then
          p_prompt := l_prompt_name;
       end if;
     close c_get_prompt_blk;
   else
     open c_get_prompt_name (p_attribute);
      fetch c_get_prompt_name into l_prompt_name;
      if c_get_prompt_name%FOUND then
          p_prompt := l_prompt_name;
      end if;
    close c_get_prompt_name;
   end if;
END GET_PROMPTS;



PROCEDURE publish_message (
		p_name          in     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
        ,       p_message_level in   VARCHAR2 DEFAULT 'ERROR'
	,	p_token_name  in     VARCHAR2 DEFAULT NULL
	,	p_token_value in     VARCHAR2 DEFAULT NULL
	,	p_application_short_name  IN VARCHAR2 default 'HXC'
	,	p_time_building_block_id  in     NUMBER
        ,       p_time_attribute_id       in     NUMBER DEFAULT NULL
        ,       p_message_extent          in     VARCHAR2 DEFAULT NULL ) IS


l_message_table hxc_message_table_type := hxc_message_table_type();

l_ind PLS_INTEGER;

l_token_string VARCHAR2(4000) := NULL;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( p_token_name is not null )
THEN

if g_debug then
	hr_utility.trace('GAZ token  is '||p_token_name);
	hr_utility.trace('GAZ length P token value is '||to_char(length(p_token_value)));
end if;

	l_token_string := SUBSTR(UPPER(p_token_name)||'&'||p_token_Value,1,4000);

if g_debug then
	hr_utility.trace('GAZ length token string is '||to_char(length(l_token_string)));
end if;

END IF;

 publish_message (
		p_name          => p_name
        ,       p_message_level => p_message_level
	,	p_token_string  => l_token_string
	,	p_application_short_name => p_application_short_name
	,	p_time_building_block_id => p_time_building_block_id
        ,       p_time_attribute_id      => p_time_attribute_id
        ,       p_message_extent         => p_message_extent );

END publish_message;


PROCEDURE publish_message (
		p_name          in   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
        ,       p_message_level in   VARCHAR2 DEFAULT 'ERROR'
	,	p_token_string  in   VARCHAR2 DEFAULT NULL
	,	p_application_short_name  IN VARCHAR2 default 'HXC'
	,	p_time_building_block_id  in     NUMBER
        ,       p_time_attribute_id       in     NUMBER DEFAULT NULL
        ,       p_message_extent          in     VARCHAR2 DEFAULT NULL ) IS



l_message_table hxc_message_table_type := hxc_message_table_type();

l_ind PLS_INTEGER;

l_token_string VARCHAR2(4000) := NULL;

BEGIN

IF ( p_token_string is not null )
THEN

	l_token_string := SUBSTR(p_token_string,1,4000);

END IF;

l_message_table.extend;

l_ind := l_message_table.last;

l_message_table(l_ind) := hxc_message_type( p_name,
                                            p_message_level,
                                            NULL,
                                            l_token_string,
                                            p_application_short_name,
                                            p_time_building_block_id,
                                            NULL,
                                            p_time_attribute_id,
                                            NULL,
                                            p_message_extent );

 hxc_timecard_message_helper.processErrors(p_messages => l_message_table);

END publish_message;

function return_archived_status(p_period in r_period)
return boolean is


cursor csr_status(p_start_date date,p_end_date date) is
 select 'Y' from hxc_data_sets
 where status in ('OFF_LINE','BACKUP_IN_PROGRESS','RESTORE_IN_PROGRESS')
 and trunc(p_start_date) <=end_date
 and trunc(p_end_date)  >=start_date;

 l_dummy varchar2(1);
 l_period varchar2(100);

 begin

 open csr_status(p_period.period_start,p_period.period_end);
 fetch csr_status into l_dummy;
 if(csr_status%found) then
   close csr_status;
   return true;
 end if;

 close csr_status;

 if(p_period.db_pre_period_start is not null and p_period.db_pre_period_end is not null) then
    open csr_status(p_period.db_pre_period_start,p_period.db_pre_period_end);
    fetch csr_status into l_dummy;
    if(csr_status%found) then
      close csr_status;
      return true;
    else
      close csr_status;
    end if;
 end if;


 if(p_period.db_ref_period_start is not null and p_period.db_ref_period_end is not null) then
     open csr_status(p_period.db_ref_period_start,p_period.db_ref_period_end);
     fetch csr_status into l_dummy;
     if(csr_status%found) then
       close csr_status;
       return true;
     else
      close csr_status;
     end if;
 end if;

 return false;

 end return_archived_status;

function check_valid_calc_date_accrual(p_resource_id NUMBER, p_calculate_date DATE) return varchar2
is

cursor emp_hire_info(p_resource_id hxc_time_building_blocks.resource_id%TYPE) IS
select date_start from per_periods_of_service where person_id=p_resource_id order by date_start desc;

l_emp_hire_date		date;

begin

    OPEN  emp_hire_info (p_resource_id);
    FETCH emp_hire_info into l_emp_hire_date;
    CLOSE emp_hire_info;

    if trunc(l_emp_hire_date) >= trunc(p_calculate_date)
    then
        return 'N';
    else
        return 'Y';
    end if;

end check_valid_calc_date_accrual;

end hxc_time_entry_rules_utils_pkg;

/
