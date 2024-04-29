--------------------------------------------------------
--  DDL for Package Body HXC_EXT_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_EXT_TIMECARD" as
/* $Header: hxcxtime.pkb 120.3 2005/10/05 16:52 jdupont noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Public Global Definitions                           |
-- ----------------------------------------------------------------------------
--
/*
g_debug boolean := hr_utility.debug_enabled;
CURSOR csr_get_po_tc ( p_person_id  NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE,
		       p_status     VARCHAR2 ) IS
SELECT	tbb_time.start_time
,	tbb_time.stop_time
,	tbb_time.comment_text comments
,       DECODE( tbb_time.date_to, hr_general.end_of_time, 'N', 'Y' ) deleted
,	tbb_time.time_building_block_id
,	tbb_time.object_version_number
,       tbb_summary.approval_status
FROM
	hxc_time_building_blocks tbb_time
,	hxc_timecard_summary tbb_summary
WHERE
	tbb_time.resource_id	= p_person_id AND
	tbb_time.scope 		= 'TIMECARD'  AND
	tbb_time.object_version_number = ( select MAX( tbb.object_version_number )
					   from   hxc_time_building_Blocks tbb
					   where  tbb.time_building_block_id = tbb_time.time_building_block_id )
AND
	p_start_date <= tbb_time.stop_time  AND
	p_end_date   >= tbb_time.start_time
AND
	tbb_summary.timecard_id     = tbb_time.time_building_block_id AND
	tbb_summary.timecard_ovn    = tbb_time.object_version_number  AND
	tbb_summary.approval_status = p_status
ORDER BY
	tbb_time.start_time;

CURSOR csr_get_tc ( p_person_id  NUMBER ) IS
SELECT
	tbb_time.start_time
,	tbb_time.stop_time
,	tbb_time.comment_text comments
,       DECODE( tbb_time.date_to, hr_general.end_of_time, 'N', 'Y' ) deleted
,	tbb_time.time_building_block_id
,	tbb_time.object_version_number
,       tbb_summary.approval_status
FROM
	hxc_time_building_blocks tbb_time
,	hxc_timecard_summary tbb_summary
WHERE
	tbb_time.resource_id	= p_person_id AND
	tbb_time.scope 		= 'TIMECARD'  AND
	tbb_time.object_version_number = ( select MAX( tbb.object_version_number )
					   from   hxc_time_building_Blocks tbb
					   where  tbb.time_building_block_id = tbb_time.time_building_block_id )
AND
	tbb_summary.timecard_id  = tbb_time.time_building_block_id AND
	tbb_summary.timecard_ovn = tbb_time.object_version_number
ORDER BY
	tbb_time.start_time;

CURSOR  csr_get_day ( p_tbb_id NUMBER, p_tbb_ovn NUMBER ) IS
SELECT	/*+ ORDERED /
        tbb_day.time_building_block_id tbb_day_id
,       tbb_day.start_time day_start_time
,	tbb_day.comment_text comments
,       tbb_detail.time_building_block_id
,       tbb_detail.object_version_number
,	tbb_detail.measure
,	tbb_detail.start_time
,	tbb_detail.stop_time
,       ta.attribute_category
,       ta.attribute1
,       ta.attribute2
,       ta.attribute3
,       ta.attribute4
,       ta.attribute5
,       ta.attribute6
,       ta.attribute7
FROM
	hxc_time_building_blocks tbb_day
,	hxc_time_building_blocks tbb_detail
,	hxc_time_attribute_usages tau
,	hxc_time_attributes ta
WHERE
	tbb_day.parent_building_block_id  = p_tbb_id AND
	tbb_day.parent_building_block_ovn = p_tbb_ovn AND
	tbb_day.object_version_number = ( select MAX ( tbb.object_version_number )
                                          from   hxc_time_building_blocks tbb
                                          where  tbb.time_building_block_id = tbb_day.time_building_block_id )
AND
	tbb_detail.parent_building_block_id = tbb_day.time_building_block_id AND
	tbb_detail.object_version_number    = ( select MAX ( tbb1.object_version_number )
                                                from   hxc_time_building_blocks tbb1
                                                where  tbb1.time_building_block_id
                                                     = tbb_detail.time_building_block_id )
AND
	tau.time_building_block_id  = tbb_detail.time_building_block_id AND
	tau.time_building_block_ovn = tbb_detail.object_version_number
AND
	ta.time_attribute_id  = tau.time_attribute_id AND
	ta.attribute_category <> 'SECURITY'
ORDER BY
	tbb_day.start_time
,       tbb_detail.time_building_block_id;

-- Inclusion Variables

l_project_id      VARCHAR2(150);
l_task_id         VARCHAR2(150);
l_exp_typ_id      VARCHAR2(150);
l_element_type_id VARCHAR2(150);
l_po_num          VARCHAR2(150);

*/

PROCEDURE clear_summary_globals IS

l_proc	VARCHAR2(72) ;

BEGIN
/*
if g_debug then
	l_proc := g_package||'summary_globals';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

hxc_ext_timecard.OTL_TC_START_DATE := NULL;
hxc_ext_timecard.OTL_TC_END_DATE   := NULL;
hxc_ext_timecard.OTL_TC_STATUS     := NULL;
hxc_ext_timecard.OTL_TC_COMMENTS   := NULL;
hxc_ext_timecard.OTL_TC_DELTED     := NULL;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;
*/ null;
END clear_summary_globals;
/*
PROCEDURE populate_summary ( p_summary_rec csr_get_po_tc%ROWTYPE ) IS

l_proc	VARCHAR2(72) ;

BEGIN
/*
if g_debug then
	l_proc := g_package||'populate_summary';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

hxc_ext_timecard.OTL_TC_START_DATE := p_summary_rec.start_time;
hxc_ext_timecard.OTL_TC_END_DATE   := p_summary_rec.stop_time;
hxc_ext_timecard.OTL_TC_STATUS     := p_summary_rec.approval_status;
hxc_ext_timecard.OTL_TC_COMMENTS   := p_summary_rec.comments;
hxc_ext_timecard.OTL_TC_DELTED     := p_summary_rec.deleted;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;

END populate_summary;
*/
PROCEDURE clear_detail_globals IS

l_proc	VARCHAR2(72) ;

BEGIN
/*
if g_debug then
	l_proc := g_package||'clear_Details';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

l_project_id      := NULL;
l_task_id         := NULL;
l_exp_typ_id      := NULL;
l_element_type_id := NULL;
l_po_num          := NULL;

hxc_ext_timecard.OTL_DAY                   := NULL;
hxc_ext_timecard.OTL_DAY_COMMENTS          := NULL;

hxc_ext_timecard.OTL_MEASURE               := NULL;
hxc_ext_timecard.OTL_DAY_START             := NULL;
hxc_ext_timecard.OTL_DAY_STOP              := NULL;
hxc_ext_timecard.OTL_PA_SYS_LINK_FUNCN     := NULL;
hxc_ext_timecard.OTL_PA_BILLABLE_FLAG      := NULL;
hxc_ext_timecard.OTL_PA_TASK               := NULL;
hxc_ext_timecard.OTL_PA_PROJECT            := NULL;
hxc_ext_timecard.OTL_PA_EXPENDITURE_TYPE   := NULL;
hxc_ext_timecard.OTL_PA_EXPENDITURE_COMMENT:= NULL;
hxc_ext_timecard.OTL_PAY_ELEMENT_NAME      := NULL;
hxc_ext_timecard.OTL_PAY_COST_CENTRE       := NULL;
hxc_ext_timecard.OTL_PO_NUMBER             := NULL;
hxc_ext_timecard.OTL_PO_LINE_ID            := NULL;
hxc_ext_timecard.OTL_PO_PRICE_TYPE         := NULL;
hxc_ext_timecard.OTL_ALIAS_ELEMENTS_EXP_SLF := NULL;
hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_ELEMENTS := NULL;
hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_TYPES    := NULL;
hxc_ext_timecard.OTL_ALIAS_LOCATIONS            := NULL;
hxc_ext_timecard.OTL_ALIAS_PAYROLL_ELEMENTS     := NULL;
hxc_ext_timecard.OTL_ALIAS_PROJECTS             := NULL;
hxc_ext_timecard.OTL_ALIAS_TASKS                := NULL;
hxc_ext_timecard.OTL_ALIAS_RATE_TYPE_EXP_SLF    := NULL;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;
*/ null;
END clear_detail_globals;

/*
PROCEDURE populate_details ( p_detail_rec  csr_get_day%ROWTYPE ) IS

CURSOR  csr_get_po_line ( p_line_id VARCHAR2 ) IS
SELECT  line_num
FROM    po_lines_all
WHERE   po_line_id = TO_NUMBER(p_line_id);


CURSOR  csr_get_po_price_type ( p_price_type VARCHAR2 ) IS
SELECT  meaning
FROM    fnd_lookups
WHERE   lookup_type = 'PRICE DIFFERENTIALS'
AND     lookup_code = p_price_type;

CURSOR csr_get_pa_task ( p_task_id VARCHAR2 ) IS
SELECT task_name
FROM   pa_online_tasks_v
WHERE  task_id = TO_NUMBER( p_task_id );

CURSOR csr_get_pa_project ( p_project_id VARCHAR2 ) IS
SELECT project_name
FROM   pa_online_projects_v
WHERE  project_id = TO_NUMBER( p_project_id );

CURSOR csr_get_element_name ( p_element_type_id VARCHAR2 ) IS
SELECT element_name
from   pay_element_types_f
where  element_type_id = TO_NUMBER(p_element_type_id);

l_att_cat hxc_time_attributes.attribute_category%TYPE;

l_proc	VARCHAR2(72) ;

BEGIN
/*
if g_debug then
	l_proc := g_package||'populate_details';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

hxc_ext_timecard.OTL_DAY                   := p_detail_rec.day_start_time;
hxc_ext_timecard.OTL_DAY_COMMENTS          := p_detail_rec.comments;

hxc_ext_timecard.OTL_MEASURE               := p_detail_rec.measure;
hxc_ext_timecard.OTL_DAY_START             := p_detail_rec.start_time;
hxc_ext_timecard.OTL_DAY_STOP              := p_detail_rec.stop_time;

IF ( p_detail_rec.attribute_category = 'PROJECTS' )
THEN

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

hxc_ext_timecard.OTL_PA_SYS_LINK_FUNCN     := p_detail_rec.attribute5;
hxc_ext_timecard.OTL_PA_BILLABLE_FLAG      := p_detail_rec.attribute7;

OPEN  csr_get_pa_task ( p_detail_rec.attribute2 );
FETCH csr_get_pa_task INTO hxc_ext_timecard.OTL_PA_TASK;
CLOSE csr_get_pa_task;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

l_task_id := p_detail_rec.attribute2;

OPEN  csr_get_pa_project ( p_detail_rec.attribute1 );
FETCH csr_get_pa_project INTO hxc_ext_timecard.OTL_PA_PROJECT;
CLOSE csr_get_pa_project;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;

l_project_id := p_detail_rec.attribute1;

l_exp_typ_id := p_detail_rec.attribute3;

hxc_ext_timecard.OTL_PA_EXPENDITURE_TYPE   := p_detail_rec.attribute3;
hxc_ext_timecard.OTL_PA_EXPENDITURE_COMMENT:= p_detail_rec.attribute4;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

ELSIF ( p_detail_rec.attribute_category like 'ELEMENT%' )
THEN

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

l_att_cat := p_detail_rec.attribute_category;
l_element_type_id := SUBSTR( l_att_cat, (INSTR(l_att_cat,'-',1,1)+2));

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

OPEN  csr_get_element_name ( l_element_type_id );
FETCH csr_get_element_name INTO hxc_ext_timecard.OTL_PAY_ELEMENT_NAME;
CLOSE csr_get_element_name;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 80);
end if;

ELSIF ( p_detail_rec.attribute_category like 'COST%' )
THEN

hxc_ext_timecard.OTL_PAY_COST_CENTRE       := 'Not Currently Supported';

ELSIF ( p_detail_rec.attribute_category = 'PURCHASING' )
THEN

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 90);
end if;

OPEN  csr_get_po_line ( p_detail_rec.attribute2 );
FETCH csr_get_po_line INTO hxc_ext_timecard.OTL_PO_LINE_ID;
CLOSE csr_get_po_line;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

OPEN  csr_get_po_price_type ( p_detail_rec.attribute3 );
FETCH csr_get_po_price_type INTO hxc_ext_timecard.OTL_PO_PRICE_TYPE;
CLOSE csr_get_po_price_type;

hxc_ext_timecard.OTL_PO_NUMBER             := p_detail_rec.attribute1;

l_po_num := p_detail_rec.attribute1;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 110);
end if;

END IF;

END populate_details;
*/

PROCEDURE populate_alias_values (
  p_detail_id   NUMBER
, p_detail_ovn  NUMBER
, p_resource_id NUMBER ) IS

l_messages HXC_MESSAGE_TABLE_TYPE;

l_alias_att HXC_ATTRIBUTE_TABLE_TYPE;

l_index BINARY_INTEGER;

l_proc	VARCHAR2(72) ;

BEGIN
/*

if g_debug then
	l_proc := g_package||'populate_alias_values';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

hxc_alias_utility.get_translated_detail (
  p_detail_bb_id  => p_detail_id
, p_detail_bb_ovn => p_detail_ovn
, p_resource_id   => p_resource_id
, p_attributes    => l_alias_att
, p_messages      => l_messages );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

	l_index := l_alias_att.FIRST;

	WHILE l_index IS NOT NULL
	LOOP

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 30);
	end if;

		IF ( l_alias_att(l_index).attribute29 = 'ELEMENTS_EXPENDITURE_SLF' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 40);
			end if;

			hxc_ext_timecard.OTL_ALIAS_ELEMENTS_EXP_SLF
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'EXPENDITURE_ELEMENTS' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 50);
			end if;

			hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_ELEMENTS
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'EXPENDITURE_TYPES' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 60);
			end if;

			hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_TYPES
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'LOCATIONS' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 70);
			end if;

			hxc_ext_timecard.OTL_ALIAS_LOCATIONS
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'PAYROLL_ELEMENTS' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 80);
			end if;

			hxc_ext_timecard.OTL_ALIAS_PAYROLL_ELEMENTS
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'PROJECTS' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 90);
			end if;

			hxc_ext_timecard.OTL_ALIAS_PROJECTS
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'TASKS' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 100);
			end if;

			hxc_ext_timecard.OTL_ALIAS_TASKS
			:= l_alias_att(l_index).attribute30;

		ELSIF ( l_alias_att(l_index).attribute29 = 'RATE_TYPE_EXPENDITURE_SLF' )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 110);
			end if;

			hxc_ext_timecard.OTL_ALIAS_RATE_TYPE_EXP_SLF
			:= l_alias_att(l_index).attribute30;

		ENd IF;

	l_index := l_alias_att.NEXT( l_index );

	END LOOP;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 120);
end if;
*/

null;
END populate_alias_values;


PROCEDURE clear_all_globals IS

l_proc	VARCHAR2(72) ;

BEGIN
/*
if g_debug then
	l_proc := g_package||'clear_all_globals';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

clear_summary_globals;
clear_detail_globals;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;
*/

null;
END clear_all_globals;


PROCEDURE process_summary (
  p_person_id          in number,
  p_ext_rslt_id        in number,
  p_ext_file_id        in number,
  p_ext_crit_prfl_id   in number,
  p_data_typ_cd        in varchar2,
  p_ext_typ_cd         in varchar2,
  p_effective_date     in date ) IS

l_start_date DATE;
l_end_date   DATE;
l_tc_status  VARCHAR2(30);

--l_tc_summary csr_get_po_tc%ROWTYPE;

l_include VARCHAR2(1);

l_proc	VARCHAR2(72) ;

BEGIN
	/*
g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'process_summary';
	hr_utility.trace('p person id is '||to_char(p_person_id));
	hr_utility.trace('p bg     id is '||to_char(hxc_ext_timecard.g_params.p_business_group_id));
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

clear_all_globals;

IF ( hxc_ext_timecard.g_params.retrieval_process = 'Purchasing Retrieval Process' AND
     p_person_id = NVL( hxc_ext_timecard.g_params.p_person_id, p_person_id ) )
THEN

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

l_tc_status  := hxc_ext_timecard.g_params.status;
l_start_date := TRUNC(hxc_ext_timecard.g_params.start_date);
l_end_date   := TRUNC(hxc_ext_timecard.g_params.end_date);

if g_debug then
	hr_utility.trace('start date is '||to_char(l_start_date,'hh24:mi:ss dd/mm/yyyy'));
	hr_utility.trace('end   date is '||to_char(l_end_date,'hh24:mi:ss dd/mm/yyyy'));
	hr_utility.trace('status is '||l_tc_status);
end if;

OPEN  csr_get_po_tc ( p_person_id,
                      l_start_date,
		      l_end_date,
		      l_tc_status );

FETCH csr_get_po_tc INTO l_tc_summary;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

WHILE csr_get_po_tc%FOUND
LOOP

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 40);
	end if;

	ben_ext_evaluate_inclusion.evaluate_timecard_incl
	(p_otl_lvl    => 'SUMMARY'
	,p_tc_status  => l_tc_summary.approval_status
	,p_tc_deleted => l_tc_summary.deleted
	,p_include    => l_include );


	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 50);
	end if;

	IF ( l_include = 'Y' )
	THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

		populate_summary ( l_tc_summary );

	--	IF ( ben_extract.g_otl_summ_lvl = 'Y' )
		--THEN

		--	if g_debug then
		--		hr_utility.set_location('Processing '||l_proc, 70);
		--	end if;

			-- do not want to o/p until we know there
			-- are details for this timecard

		--	null;

	--	END IF;

		--IF ( ben_extract.g_otl_detl_lvl = 'Y' )
		--THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 80);
			end if;

			process_detail (    p_tbb_id          => l_tc_summary.time_building_block_id
	                                 ,  p_tbb_ovn         => l_tc_summary.object_version_number
	                                 ,  p_person_id       => p_person_id
	                                 ,  p_ext_rslt_id     => p_ext_rslt_id
	                                 ,  p_ext_file_id     => p_ext_file_id
	                                 ,  p_ext_crit_prfl_id=> p_ext_crit_prfl_id
	                                 ,  p_data_typ_cd     => p_data_typ_cd
	                                 ,  p_ext_typ_cd      => p_ext_typ_cd
	                                 ,  p_effective_date  => p_effective_date );

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 90);
			end if;

		--END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 100);
		end if;

	END IF; -- ben_ext_evaluate_inclusion.otl_inclusion_function

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 110);
	end if;

	clear_all_globals;

	FETCH csr_get_po_tc INTO l_tc_summary;

END LOOP;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 120);
end if;

CLOSE csr_get_po_tc;

END IF; -- ( hxc_ext_timecard.g_params.retrieval_process = 'Purchasing Retrieval Process' )

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 130);
end if;


*/

null;


END process_summary;

PROCEDURE process_detail (
   p_tbb_id             in number,
   p_tbb_ovn            in number,
   p_person_id          in number,
   p_ext_rslt_id        in number,
   p_ext_file_id        in number,
   p_ext_crit_prfl_id   in number,
   p_data_typ_cd        in varchar2,
   p_ext_typ_cd         in varchar2,
   p_effective_date     in date ) IS


--l_day_rec csr_get_day%ROWTYPE;

l_summary_written   BOOLEAN := FALSE;
l_skip_PO           BOOLEAN := FALSE;
l_already_called_PO BOOLEAN := FALSE;

l_old_det_id hxc_time_building_blocks.time_building_block_id%TYPE := -1;

l_include VARCHAR2(1) := 'N';

l_proc	VARCHAR2(72) ;

BEGIN
/*
g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'process_detail';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

OPEN  csr_get_day ( p_tbb_id, p_tbb_ovn );

FETCH csr_get_day INTO l_day_rec;

WHILE csr_get_day%FOUND
LOOP

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 20);
	end if;

	IF ( l_old_det_id <> l_day_rec.time_building_block_id )
	THEN

		if g_debug then
			hr_utility.trace('New Detail is '||to_char(l_day_rec.time_building_block_id));
			hr_utility.set_location('Processing '||l_proc, 30);
		end if;

		-- new detail so all globals for OLD detail populated
		-- decide if we are going to write this information

		IF ( ( NOT l_skip_PO ) AND ( l_old_det_id <> -1 ) )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 40);
			end if;

			--IF NOT l_summary_written AND ben_extract.g_otl_summ_lvl = 'Y'
			--THEN
			--	if g_debug then
			--		hr_utility.set_location('Processing '||l_proc, 50);
			--	end if;

				ben_ext_fmt.process_ext_recs(
                                   p_ext_rslt_id      => p_ext_rslt_id,
                                   p_ext_file_id      => p_ext_file_id,
                                   p_data_typ_cd      => p_data_typ_cd,
                                   p_ext_typ_cd       => p_ext_typ_cd,
                                   p_rcd_typ_cd       => 'D',
                                   p_low_lvl_cd       => 'T',
                                   p_person_id        => p_person_id,
                                   p_chg_evt_cd       => ben_ext_person.g_chg_evt_cd,
                                   p_business_group_id=> hxc_ext_timecard.g_params.p_business_group_id,
                                   p_effective_date   => p_effective_date );

				l_summary_written := TRUE;
			--END IF;

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 60);
			end if;

			-- call detail inclusion

			l_include := 'N';

			ben_ext_evaluate_inclusion.evaluate_timecard_incl
			(p_otl_lvl         => 'DETAIL'
		        ,p_project_id      => l_project_id
		        ,p_task_id         => l_task_id
		        ,p_exp_typ_id      => l_exp_typ_id
		        ,p_element_type_id => l_element_type_id
		        ,p_po_num          => l_po_num
			,p_include         => l_include );

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 70);
			end if;

			IF ( l_include = 'Y' )
			THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 80);
			end if;

				--IF ( ben_extract.g_otl_detl_lvl = 'Y' )
				--THEN

					if g_debug then
						hr_utility.set_location('Processing '||l_proc, 90);
						hr_utility.trace('Writing Detail for '||to_char(l_day_rec.time_building_block_id));
					end if;

					-- write l_detail

					ben_ext_fmt.process_ext_recs(
	                                   p_ext_rslt_id      => p_ext_rslt_id,
	                                   p_ext_file_id      => p_ext_file_id,
	                                   p_data_typ_cd      => p_data_typ_cd,
	                                   p_ext_typ_cd       => p_ext_typ_cd,
	                                   p_rcd_typ_cd       => 'D',
	                                   p_low_lvl_cd       => 'TS',
	                                   p_person_id        => p_person_id,
	                                   p_chg_evt_cd       => ben_ext_person.g_chg_evt_cd,
	                                   p_business_group_id=> hxc_ext_timecard.g_params.p_business_group_id,
	                                   p_effective_date   => p_effective_date );

				--END IF;

			END IF; -- detail inclusion

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 100);
			end if;

			l_skip_PO           := FALSE;
			l_already_called_PO := FALSE;
			clear_detail_globals;

		END IF; -- ( NOT l_skip_PO ) AND ( l_old_det_id <> -1 )

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 110);
		end if;

		populate_alias_values (
		  p_detail_id   => l_day_rec.time_building_block_id
		, p_detail_ovn  => l_day_rec.object_version_number
		, p_resource_id => p_person_id );

		l_old_det_id := l_day_rec.time_building_block_id;

	END IF; -- l_old_det_id <> l_day_rec.time_building_block_id

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 120);
end if;


	-- check whether or not the PO assocaited with this line
	-- is permitted to be shown thos this Supplier

	IF ( hxc_ext_timecard.g_params.buyer_supplier = 'SUPPLIER' AND
             l_day_rec.attribute_category = 'PURCHASING' AND
             NOT l_already_called_PO )
	THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 130);
		end if;

		-- call PO inclusion function

		IF ( FALSE )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 140);
			end if;

			l_skip_PO := TRUE;

		END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 150);
		end if;

		l_already_called_PO := TRUE;

	END IF; -- ( hxc_ext_timecard.g_params.buyer_supplier = 'SUPPLIER' )

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 160);
	end if;

	populate_details ( l_day_rec );

	FETCH csr_get_day INTO l_day_rec;

END LOOP;

CLOSE csr_get_day;

-- INCLUDE writing record logic here too !!!
-- since the last record will not go back into the loop

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 170);
end if;

IF ( NOT l_skip_PO )
THEN

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 180);
	end if;

	IF NOT l_summary_written --AND ben_extract.g_otl_summ_lvl = 'Y'
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 190);
		end if;

		--write header

		ben_ext_fmt.process_ext_recs(
                  p_ext_rslt_id      => p_ext_rslt_id,
                  p_ext_file_id      => p_ext_file_id,
                  p_data_typ_cd      => p_data_typ_cd,
                  p_ext_typ_cd       => p_ext_typ_cd,
                  p_rcd_typ_cd       => 'D',
                  p_low_lvl_cd       => 'T',
                  p_person_id        => p_person_id,
                  p_chg_evt_cd       => ben_ext_person.g_chg_evt_cd,
                  p_business_group_id=> hxc_ext_timecard.g_params.p_business_group_id,
                  p_effective_date   => p_effective_date );

		l_summary_written := TRUE;
	END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 200);
	end if;

	-- call detail inclusion

	l_include := 'N';

	ben_ext_evaluate_inclusion.evaluate_timecard_incl
	(p_otl_lvl         => 'DETAIL'
        ,p_project_id      => l_project_id
        ,p_task_id         => l_task_id
        ,p_exp_typ_id      => l_exp_typ_id
        ,p_element_type_id => l_element_type_id
        ,p_po_num          => l_po_num
	,p_include         => l_include );

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 210);
	end if;

	IF ( l_include = 'Y' )
	THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 220);
		end if;

		--IF ( ben_extract.g_otl_detl_lvl = 'Y' )
		--THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 230);
			end if;

			-- write l_detail

			ben_ext_fmt.process_ext_recs(
                           p_ext_rslt_id      => p_ext_rslt_id,
                           p_ext_file_id      => p_ext_file_id,
                           p_data_typ_cd      => p_data_typ_cd,
                           p_ext_typ_cd       => p_ext_typ_cd,
                           p_rcd_typ_cd       => 'D',
                           p_low_lvl_cd       => 'TS',
                           p_person_id        => p_person_id,
                           p_chg_evt_cd       => ben_ext_person.g_chg_evt_cd,
                           p_business_group_id=> hxc_ext_timecard.g_params.p_business_group_id,
                           p_effective_date   => p_effective_date );

		--END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 240);
		end if;

	END IF; -- detail inclusion

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 250);
end if;

END IF; -- ( NOT l_skip_PO )

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 260);
end if;
*/
null;

END process_detail;

PROCEDURE po_otl_extract (
                errbuf               out NOCOPY varchar2,
                retcode              out NOCOPY number,
                p_ext_dfn_id	     in number,
                p_effective_date     in varchar2,
                p_business_group_id  in number,
                p_start_date        in varchar2,
                p_end_date          in varchar2,
                p_timecard_status   in varchar2,
                p_vendor_id         in varchar2 default null,
                p_person_id         in varchar2 default null,
                p_retrieval_process in varchar2,
                p_buyer_supplier    in varchar2 default 'BUYER' ) IS

l_dummy_errbuf varchar2(2000);
l_dummy_retcode number;

l_proc	VARCHAR2(72) ;

BEGIN
	/*
g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'po_otl_extract';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

if g_debug then
	hr_utility.trace('po_otl_extract : 1');
	hr_utility.trace('date is '||p_start_date);
end if;

hxc_ext_timecard.g_params.start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
hxc_ext_timecard.g_params.end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
hxc_ext_timecard.g_params.status     := p_timecard_status;
hxc_ext_timecard.g_params.vendor_id := p_vendor_id;
hxc_ext_timecard.g_params.retrieval_process := p_retrieval_process;
hxc_ext_timecard.g_params.retrieval_process := 'Purchasing Retrieval Process';
hxc_ext_timecard.g_params.buyer_supplier := p_buyer_supplier;
hxc_ext_timecard.g_params.p_business_group_id := p_business_group_id;
hxc_ext_timecard.g_params.p_person_id := p_person_id;

if g_debug then
	hr_utility.trace('po_otl_extract : 2');
end if;

-- Code to dynamically set Person criteria

if g_debug then
	hr_utility.trace('po_otl_extract : 3');
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

ben_ext_thread.process (
 errbuf               => l_dummy_errbuf
,retcode              => l_dummy_retcode
,p_benefit_action_id  => NULL
,p_ext_dfn_id         => p_ext_dfn_id
,p_effective_date     => p_effective_date
,p_business_group_id  => p_business_group_id );

if g_debug then
	hr_utility.trace('l err buff is '||l_dummy_errbuf);
	hr_utility.trace('l ret code is '||l_dummy_retcode);
	hr_utility.trace('po_otl_extract : 4');
	hr_utility.set_location('Leaving '||l_proc, 30);
end if;
*/
null;
END po_otl_extract;

end hxc_ext_timecard;

/
