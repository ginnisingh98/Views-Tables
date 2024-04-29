--------------------------------------------------------
--  DDL for Package Body HXC_SETUP_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SETUP_VALIDATION_PKG" as
/* $Header: hxcotcvld.pkb 120.15.12010000.3 2009/09/23 16:21:06 asrajago ship $ */

g_debug boolean := hr_utility.debug_enabled;

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< execute_otc_validation >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- This procedure is used to check that certain areas of OTC are configured
-- correctly at time entry. This is to avoid usability issues later on in the
-- system.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Access Status:
--   Public.
--

PROCEDURE execute_otc_validation (
		p_operation	    VARCHAR2
        ,       p_resource_id       NUMBER
	,       p_timecard_bb_id    NUMBER
        ,       p_timecard_bb_ovn   NUMBER
        ,       p_start_date        DATE
        ,       p_end_date          DATE
        ,       p_master_pref_table IN OUT NOCOPY hxc_preference_evaluation.t_pref_table
	,	p_messages	    IN OUT NOCOPY hxc_message_table_type ) IS

CURSOR csr_get_retrieval_rules ( p_rtr_grp_id NUMBER ) IS
SELECT
	DISTINCT( rrc.time_recipient_id )
FROM
	hxc_retrieval_rule_comps rrc
,	hxc_retrieval_rules rr
,	hxc_retrieval_rule_grp_comps_v rrgc
,	hxc_retrieval_rule_groups_v rrg
WHERE
	rrg.retrieval_rule_group_id  = p_rtr_grp_id
AND
	rrgc.retrieval_rule_group_id = rrg.retrieval_rule_group_id
AND
	rr.retrieval_rule_id	= rrgc.retrieval_rule_id
AND
	rrc.retrieval_rule_id	= rr.retrieval_rule_id AND
	rrc.status <> 'WORKING';


-- retrieves list of time recipients in retrieval rule group

CURSOR	csr_get_rtr ( p_rtr_id NUMBER ) IS
SELECT
	DISTINCT( rrc.time_recipient_id )
FROM
	hxc_retrieval_rule_comps rrc
,	hxc_retrieval_rules rr
WHERE
	rr.retrieval_rule_id	= p_rtr_id
AND
	rrc.retrieval_rule_id	= rr.retrieval_rule_id AND
	rrc.status <> 'WORKING';


-- retrieves list of time recipients in application set

CURSOR  csr_get_app_sets ( p_app_set_id NUMBER ) IS
SELECT	apsc.time_recipient_id
FROM	hxc_application_set_comps_v apsc
,	hxc_application_sets_v aps
WHERE	aps.application_set_id = p_app_set_id
AND
	apsc.application_set_id = aps.application_set_id;


-- tests that the time recipient from the application set
-- has a corresponding row in the approval period set

CURSOR	csr_get_app_rec_period(p_time_recipient_id number,
                               p_app_periods       number) is
SELECT	'Y'
FROM	hxc_approval_period_comps hapc,
        hxc_approval_period_sets haps
WHERE	haps.approval_period_set_id = p_app_periods
AND
	hapc.approval_period_set_id = haps.approval_period_set_id AND
	hapc.time_recipient_id      = p_time_recipient_id;


-- tests that the time recipients in the application set have
-- corresponding entries in the approval style components


CURSOR  csr_get_approval_style_comps ( p_time_recipient_id number,
                                       p_approval_style_id number ) IS
SELECT	'Y'
FROM	hxc_approval_comps hac,
	hxc_approval_styles has
WHERE	hac.approval_style_id = p_approval_style_id
AND	hac.time_recipient_id = p_time_recipient_id
OR      (has.approval_style_id = p_approval_style_id
         AND has.name	      = 'Approval on Submit');


CURSOR csr_get_elp_terg_comps(p_elp_terg_id number,
		              p_time_recipient_id number) IS
SELECT  'Y'
FROM    hxc_entity_groups heg,
        hxc_entity_group_comps hec,
	hxc_time_entry_rules hte
WHERE   heg.entity_type = 'TIME_ENTRY_RULES' and
        heg.entity_group_id = p_elp_terg_id and
	hec.ENTITY_GROUP_ID =heg.entity_group_id and
        hec.entity_id = hte.TIME_ENTRY_RULE_ID and
	hte.attribute1 = p_time_recipient_id;
--
-- Added for 115.26, gets timecard information for self
-- service, since we can not know it in the properties
-- package
cursor c_timecard_info
(p_timecard_bb_id in NUMBER,
p_timecard_bb_ovn in NUMBER) is
 select approval_status
 from hxc_timecard_summary
 where timecard_id = p_timecard_bb_id
 and timecard_ovn =p_timecard_bb_ovn;

l_tc_approval_status hxc_timecard_summary.approval_status%type;
l_test_edit boolean;

l_proc	VARCHAR2(72);

l_index       BINARY_INTEGER;
l_pref_table  hxc_preference_evaluation.t_pref_table;

l_id          NUMBER(15);
l_pref_code   VARCHAR2(30);

l_rtr_grp_id  NUMBER(15);
l_app_set_id  NUMBER(15);
l_approval_period_set_id  NUMBER(15);
l_approval_style_id NUMBER(15);
l_override_approval_style_id hxc_approval_styles.approval_style_id%type;
l_elp_terg_id NUMBER(15);
l_cla_terg_id  NUMBER(15);
l_cla_prefs_ok BOOLEAN := FALSE;
l_dummy       VARCHAR2(1);

-- Default override approver validation
l_default_override_approver_id number(15);
l_can_enter_override_approver  hxc_pref_hierarchies.attribute1%type;

l_past_limit_date	VARCHAR2(80);
l_futur_limit_date	VARCHAR2(80);


l_otm_explosion VARCHAR2(1);
l_otm_rtr_id	hxc_retrieval_rules.retrieval_rule_id%TYPE;

l_status_allowing_edits hxc_pref_hierarchies.attribute1%TYPE;
l_edit_allowed VARCHAR2(5);

l_rtr_tr_id   hxc_time_recipients.time_recipient_id%TYPE;
l_aps_tr_id   hxc_time_recipients.time_recipient_id%TYPE;

l_timecard_info_rec	hxc_time_entry_rules_utils_pkg.r_timecard_info;

-- OTL - ABS Integration
l_absences_integration    VARCHAR2(5);
l_mismatch_abs            BOOLEAN := FALSE;
l_ind                     BINARY_INTEGER;

TYPE r_time_recipient IS RECORD ( DUMMY VARCHAR2(1) );

TYPE t_time_recipient IS TABLE OF r_time_recipient INDEX BY BINARY_INTEGER;

-- table for application set and retrieval rule time recipients
-- note we are going to use the table index to store the time
-- recipient id

t_aps_tr t_time_recipient;
t_rtr_tr t_time_recipient;

e_no_resource_id_error   exception;
e_no_rtr_id		 exception;

FUNCTION test_aps_vs_rtr (
		p_rtr_tr	t_time_recipient
	,	p_aps_tr	t_time_recipient ) RETURN BOOLEAN IS

l_rtr_index BINARY_INTEGER;
l_return BOOLEAN := FALSE;

BEGIN

l_rtr_index := t_rtr_tr.FIRST;

WHILE ( l_rtr_index IS NOT NULL )
LOOP

	IF NOT t_aps_tr.EXISTS(l_rtr_index)
	THEN

		l_return	:= TRUE;
		EXIT;

	END IF;

l_rtr_index := t_rtr_tr.NEXT(l_rtr_index);

END LOOP;

RETURN l_return;

END test_aps_vs_rtr;

BEGIN -- execute_otc_Validation

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'execute_otc_validation';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

l_timecard_info_rec.resource_id     := p_resource_id;
l_timecard_info_rec.timecard_bb_id  := p_timecard_bb_id;
l_timecard_info_rec.timecard_ovn    := p_timecard_bb_ovn;
l_timecard_info_rec.start_date      := p_start_date;
l_timecard_info_rec.end_date        := p_end_date;

-- now get the retrieval rule grp id and application set id
-- based on the resource id

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_APPLICATION_SET',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_app_set_id	:= TO_NUMBER(l_pref_table(1).attribute1);
		if g_debug then
			hr_utility.trace('OTL Setup - app set id is '||to_char(l_app_set_id));
		end if;

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_RETRIEVAL_RULES',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_rtr_grp_id	:= TO_NUMBER(l_pref_table(1).attribute1);
		if g_debug then
			hr_utility.trace('OTL Setup - rtr grp id is '||to_char(l_rtr_grp_id));
		end if;

-- OTL - ABS Integration

IF NVL(FND_PROFILE.VALUE('HR_ABS_OTL_INTEGRATION'),'N') = 'Y'
THEN
hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_ABS_PREFERENCES',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_absences_integration := l_pref_table(1).attribute1;
		if g_debug then
			hr_utility.trace('OTL Setup - Abs Integration is  '||l_absences_integration);
		end if;
   -- Bug 8855103
   -- Mid period pref changes should be disabled.
   IF l_pref_table.COUNT > 0
   THEN
      l_ind := l_pref_table.FIRST;
      LOOP
         IF l_pref_table(l_ind).attribute1 <> l_absences_integration
         THEN
             l_mismatch_abs := TRUE;
             EXIT;
         END IF;
         l_ind := l_pref_table.NEXT(l_ind);
         EXIT WHEN NOT l_pref_table.EXISTS(l_ind);
      END LOOP;
   END IF;
END IF;


hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TC_W_RULES_EVALUATION',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_otm_explosion := l_pref_table(1).attribute1;
		l_otm_rtr_id	:= TO_NUMBER(l_pref_table(1).attribute2);
		if g_debug then
			hr_utility.trace('OTL Setup - otm explosion is '||l_otm_explosion);
		end if;

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_APPROVAL_PERIODS',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_approval_period_set_id := TO_NUMBER(l_pref_table(1).attribute1);
		if g_debug then
			hr_utility.trace('OTL Setup - approval period set id is '||to_char(l_approval_period_set_id));
		end if;

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_APPROVAL_STYLE',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_approval_style_id := TO_NUMBER(l_pref_table(1).attribute1);
		l_override_approval_style_id := TO_NUMBER(l_pref_table(1).attribute2);
		if g_debug then
			hr_utility.trace('OTL Setup - approval style id is '||to_char(l_approval_style_id));
			hr_utility.trace('OTL Setup - override approval style id is '||to_char(l_override_approval_style_id));
		end if;

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TC_W_TCRD_ST_ALW_EDITS',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_status_allowing_edits := l_pref_table(1).attribute1;
		l_past_limit_date	:= l_pref_table(1).attribute6;
		l_futur_limit_date	:= l_pref_table(1).attribute11;
		if g_debug then
			hr_utility.trace('OTL Setup - status allowing edits is '||l_status_allowing_edits);
			hr_utility.trace('OTL Setup - past limit date  is '||l_past_limit_date);
			hr_utility.trace('OTL Setup - futur limit date is '||l_futur_limit_date);
		end if;

--ELP Validation

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TS_PER_ELP_RULES',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_elp_terg_id := TO_NUMBER(l_pref_table(1).attribute1);
		if g_debug then
			hr_utility.trace('OTL Setup- ELP TERG is ' || to_char(l_elp_terg_id));
		end if;

-- Override Approval Validation

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TC_W_APRVR_DFLT_OVRD',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

		l_default_override_approver_id := TO_NUMBER(l_pref_table(1).attribute1);

hxc_preference_evaluation.resource_preferences(p_resource_id  => l_timecard_info_rec.resource_id,
			       p_preference_code => 'TC_W_APRVR_ENBLE_OVRD',
                               p_start_evaluation_date => l_timecard_info_rec.start_date,
                               p_end_evaluation_date => l_timecard_info_rec.end_date,
                               p_sorted_pref_table => l_pref_table,
                               p_master_pref_table => p_master_pref_table );

                l_can_enter_override_approver := l_pref_table(1).attribute1;

hxc_preference_evaluation.clear_sort_pref_table_cache;


IF l_past_limit_date is null THEN
    l_past_limit_date := '0001/01/01';
ELSE
    l_past_limit_date := to_char((sysdate - to_number(l_past_limit_date)),'YYYY/MM/DD');
END IF;

IF l_futur_limit_date is null THEN
    l_futur_limit_date := '4712/12/31';
ELSE
    l_futur_limit_date := to_char((sysdate + to_number(l_futur_limit_date)),'YYYY/MM/DD');
END IF;

if g_debug then
	hr_utility.trace('OTL Setup - past limit date is '||l_past_limit_date);
	hr_utility.trace('OTL Setup - futur limit date is '||l_futur_limit_date);
end if;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;

-- now get the application set time recipients and retrieval rule group time recipients
-- and make sure they match.

OPEN  csr_get_retrieval_rules ( l_rtr_grp_id );
FETCH csr_get_retrieval_rules INTO l_rtr_tr_id;

WHILE csr_get_retrieval_rules%FOUND
LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 25);
	end if;

	t_rtr_tr(l_rtr_tr_id).dummy := 'N';

	FETCH csr_get_retrieval_rules INTO l_rtr_tr_id;

END LOOP;

CLOSE  csr_get_retrieval_rules;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

OPEN  csr_get_app_sets ( l_app_set_id );
FETCH csr_get_app_sets INTO l_aps_tr_id;

WHILE csr_get_app_sets%FOUND
LOOP
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 35);
	end if;

	t_aps_tr(l_aps_tr_id).dummy := 'N';

	FETCH csr_get_app_sets INTO l_aps_tr_id;

END LOOP;

CLOSE  csr_get_app_sets;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;

-- now test to see if the retrieval rule group time recipients
-- is at least a subset of the application set time recipients

IF ( test_aps_vs_rtr ( p_rtr_tr	=> t_rtr_tr
	,	       p_aps_tr	=> t_aps_tr ) )
THEN

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_VLD_APS_VS_RTR_GRP'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

END IF;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

-- now get the time recipients associated with the
-- OTM Evaluation rtr if the person has their
-- apply schedule rule prefernce set

IF ( l_otm_explosion = 'Y' )
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 55);
	end if;

	IF ( l_otm_rtr_id IS NULL )
	THEN
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

		raise e_no_rtr_id;

	END IF;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 70);
	end if;

	t_rtr_tr.DELETE;

	OPEN  csr_get_rtr ( l_otm_rtr_id );
	FETCH csr_get_rtr INTO l_rtr_tr_id;

	WHILE csr_get_rtr%FOUND
	LOOP
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 80);
		end if;

		t_rtr_tr(l_rtr_tr_id).dummy := 'N';

		FETCH csr_get_rtr INTO l_rtr_tr_id;

	END LOOP;

	CLOSE  csr_get_rtr;

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 90);
	end if;

	-- now test to see if the retrieval rule group time recipients
	-- is at least a subset of the application set time recipients

	IF ( test_aps_vs_rtr ( p_rtr_tr	=> t_rtr_tr
		,	       p_aps_tr	=> t_aps_tr ) )
	THEN

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_VLD_APS_VS_RTR_GRP'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

	END IF;


if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

END IF; -- IF ( l_otm_explosion = 'Y' ) GPM v115.19

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 130);
end if;

-- test that the applications in the application set have a corresponding
-- period in the Approval Periods Group

l_index := t_aps_tr.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.trace('Here is the time recipient '||to_char(l_index));

	hr_utility.set_location('Processing '||l_proc, 140);
end if;

OPEN  csr_get_app_rec_period(l_index, l_approval_period_set_id);
FETCH csr_get_app_rec_period into l_dummy;

IF csr_get_app_rec_period%NOTFOUND
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 150);
	end if;

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_APR_NO_REC_PERIOD'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

	CLOSE csr_get_app_rec_period;

	EXIT;

END IF;

CLOSE csr_get_app_rec_period;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 160);
end if;

l_index := t_aps_tr.NEXT(l_index);

END LOOP; -- t_aps_tr

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 170);
end if;


-- tests that the time recipients in the application set have
-- corresponding entries in the approval style components

l_index := t_aps_tr.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 180);
end if;

OPEN  csr_get_approval_style_comps(l_index, l_approval_style_id);
FETCH csr_get_approval_style_comps into l_dummy;

IF csr_get_approval_style_comps%NOTFOUND
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 190);
	end if;

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_APR_NO_APP_STYLE_COMP'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

	CLOSE csr_get_approval_style_comps;

	EXIT;

END IF;

CLOSE csr_get_approval_style_comps;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 200);
end if;

l_index := t_aps_tr.NEXT(l_index);

END LOOP; -- t_aps_tr
--
-- tests that the time recipients in the application set have
-- corresponding entries in the override approval style components,
-- if it is set
--
if(l_override_approval_style_id is not null)then
   l_index := t_aps_tr.FIRST;
   WHILE ( l_index IS NOT NULL ) LOOP

      if g_debug then
      	hr_utility.set_location('Processing '||l_proc, 201);
      end if;
      OPEN  csr_get_approval_style_comps(l_index, l_override_approval_style_id);
      FETCH csr_get_approval_style_comps into l_dummy;

      IF csr_get_approval_style_comps%NOTFOUND THEN
         if g_debug then
         	hr_utility.set_location('Processing '||l_proc, 202);
         end if;

         hxc_timecard_message_helper.adderrortocollection
            (p_messages                => p_messages,
             p_message_name 	       => 'HXC_APR_NO_APP_STYLE_COMP',
             p_message_level	       => 'ERROR' ,
             p_message_field	       => NULL,
             p_message_tokens	       => NULL,
             p_application_short_name  => 'HXC',
             p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id,
             p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn,
             p_time_attribute_id       => NULL,
             p_time_attribute_ovn      => NULL
             );

	CLOSE csr_get_approval_style_comps;

	EXIT;

     END IF;

     CLOSE csr_get_approval_style_comps;

     if g_debug then
     	hr_utility.set_location('Processing '||l_proc, 203);
     end if;

     l_index := t_aps_tr.NEXT(l_index);

  END LOOP; -- t_aps_tr
end if; -- Is the Override Style set?

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 210);
end if;

--ELP Validation
-- tests that the time recipients in the application set have
-- corresponding entries in the ELP TERG components

if (l_elp_terg_id is not null) then
   l_index := t_aps_tr.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 211);
end if;

OPEN  csr_get_elp_terg_comps(l_elp_terg_id,l_index);
FETCH csr_get_elp_terg_comps into l_dummy;

IF csr_get_elp_terg_comps%NOTFOUND
THEN
	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 212);
	end if;

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_VLD_ELP_VIOLATION'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

	CLOSE csr_get_elp_terg_comps;

	EXIT;

END IF;

CLOSE csr_get_elp_terg_comps;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 213);
end if;

l_index := t_aps_tr.NEXT(l_index);

END LOOP; -- t_aps_tr

END IF;
if g_debug then
	hr_utility.set_location('Processing '||l_proc, 214);
end if;

-- Now let's check to see if the user is still allowed to update the timecard
-- WWB 2290884
-- GPM v115.11
-- ARR v115.26 - 4561454
--Bug 4733480
if(l_timecard_info_rec.timecard_bb_id is null) then
      l_test_edit := false;
else
   open c_timecard_info(l_timecard_info_rec.timecard_bb_id,l_timecard_info_rec.timecard_ovn);
   fetch c_timecard_info into  l_tc_approval_status;
   if(c_timecard_info%found) then -- condition added to allow edit check only for timecard and not for templates
   l_test_edit := true;
   else
   l_test_edit := false;
   l_tc_approval_status := null;
   end if;
   close c_timecard_info;
end if;

if l_test_edit then

   l_edit_allowed := NULL;

   IF (to_char(l_timecard_info_rec.start_date,'YYYY/MM/DD') <= l_futur_limit_date and
       to_char(l_timecard_info_rec.end_date,'YYYY/MM/DD') >= l_past_limit_date )
   THEN
      hxc_time_entry_rules_utils_pkg.tc_edit_allowed
         (p_timecard_id             => l_timecard_info_rec.timecard_bb_id
          ,p_timecard_ovn            => l_timecard_info_rec.timecard_ovn
          ,p_timecard_status         => l_tc_approval_status
          ,p_edit_allowed_preference => l_status_allowing_edits
          ,p_edit_allowed            => l_edit_allowed
          );
   ELSE
      l_edit_allowed := 'FALSE';
   END IF;

   IF ( l_edit_allowed = 'FALSE' )
   THEN
      --
      -- Make sure this is raised at page level, i.e.
      -- pass null for the timecard id and ovn.
      --
	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_VLD_TC_STATUS_CHANGED'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => NULL
                    ,   p_time_building_block_ovn => NULL
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

	END IF;

END IF; -- Test edit
-- +---------------------------------------------------------------------------+
-- |                                                                           |
-- |                    Change Late Audit Set Up Validation                    |
-- |                                                                           |
-- +---------------------------------------------------------------------------+

   l_cla_prefs_ok := FALSE;
   hxc_preference_evaluation.resource_preferences
    (p_resource_id           => l_timecard_info_rec.resource_id,
     p_preference_code       => 'TC_W_FLOW_PROCESS_NAME',
     p_start_evaluation_date => l_timecard_info_rec.start_date,
     p_end_evaluation_date   => l_timecard_info_rec.end_date,
     p_sorted_pref_table     => l_pref_table,
     p_master_pref_table     => p_master_pref_table);

   if ( l_pref_table(1).attribute1 = 'AUDIT' ) then
     -- For AUDIT Flow:
     -- Audit Layout Must be set
     -- Delete is *NOT* allowed
     -- CLA TERG must be specified
     hxc_preference_evaluation.resource_preferences
       (p_resource_id           => l_timecard_info_rec.resource_id,
        p_preference_code       => 'TC_W_TCRD_LAYOUT',
        p_start_evaluation_date => l_timecard_info_rec.start_date,
        p_end_evaluation_date   => l_timecard_info_rec.end_date,
        p_sorted_pref_table     => l_pref_table,
        p_master_pref_table     => p_master_pref_table );

     if ( l_pref_table(1).attribute6 IS NOT NULL ) then
       --Audit Layout is Not Null
       hxc_preference_evaluation.resource_preferences
         (p_resource_id           => l_timecard_info_rec.resource_id,
          p_preference_code       => 'TC_W_DELETE_ALLOW',
          p_start_evaluation_date => l_timecard_info_rec.start_date,
          p_end_evaluation_date   => l_timecard_info_rec.end_date,
          p_sorted_pref_table     => l_pref_table,
          p_master_pref_table     => p_master_pref_table );

       if(l_pref_table(1).attribute1 = 'N'  )then
         hxc_preference_evaluation.resource_preferences
           (p_resource_id           => l_timecard_info_rec.resource_id,
            p_preference_code       => 'TS_PER_AUDIT_REQUIREMENTS',
            p_start_evaluation_date => l_timecard_info_rec.start_date,
            p_end_evaluation_date   => l_timecard_info_rec.end_date,
            p_sorted_pref_table     => l_pref_table,
            p_master_pref_table     => p_master_pref_table );

         l_cla_terg_id := to_number(l_pref_table(1).attribute1);
         if ( l_cla_terg_id is not null )then
           l_cla_prefs_ok := TRUE;
         end if; -- Null CLA TERG ?
       end if; -- Delete Allowed ?
     end if; -- Null Audit Layout ?

     if not l_cla_prefs_ok then
       -- Failed CLA set up validation for AUDIT flow
       hxc_timecard_message_helper.adderrortocollection
         (p_messages                => p_messages,
          p_message_name            => 'HXC_VLD_CLA_PREF_DFN',
          p_message_level           => 'ERROR',
          p_message_field           => NULL,
          p_message_tokens          => NULL,
          p_application_short_name  => 'HXC',
          p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id,
          p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn,
          p_time_attribute_id       => NULL,
          p_time_attribute_ovn      => NULL );

     end if;
   else if ( nvl(l_pref_table(1).attribute1,'STANDARD') = 'STANDARD' ) then
   --
   -- Non Audit flow:
   -- Audit layout must be null
   -- CLA TERG must be null
     hxc_preference_evaluation.resource_preferences
       (p_resource_id           => l_timecard_info_rec.resource_id,
        p_preference_code       => 'TC_W_TCRD_LAYOUT',
        p_start_evaluation_date => l_timecard_info_rec.start_date,
        p_end_evaluation_date   => l_timecard_info_rec.end_date,
        p_sorted_pref_table     => l_pref_table,
        p_master_pref_table     => p_master_pref_table );

     if ( l_pref_table(1).attribute6 is null ) then
       --Audit Layout is null
       hxc_preference_evaluation.resource_preferences
         (p_resource_id           => l_timecard_info_rec.resource_id,
          p_preference_code       => 'TS_PER_AUDIT_REQUIREMENTS',
          p_start_evaluation_date => l_timecard_info_rec.start_date,
          p_end_evaluation_date   => l_timecard_info_rec.end_date,
          p_sorted_pref_table     => l_pref_table,
          p_master_pref_table     => p_master_pref_table );

       l_cla_terg_id := to_number(l_pref_table(1).attribute1);
       if ( l_cla_terg_id is null )then
         l_cla_prefs_ok := TRUE;
       end if; -- Null CLA TERG ?
     end if; -- Null Audit Layout ?

     if not l_cla_prefs_ok then
       -- Failed CLA Setup validation for STANDARD flow.
       hxc_timecard_message_helper.adderrortocollection
         (p_messages                => p_messages,
          p_message_name            => 'HXC_VLD_NON_CLA_PREF_DFN',
          p_message_level           => 'ERROR',
          p_message_field           => NULL,
          p_message_tokens          => NULL,
          p_application_short_name  => 'HXC',
          p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id,
          p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn,
          p_time_attribute_id       => NULL,
          p_time_attribute_ovn      => NULL );
     end if;
   end if; -- Flow Style
 end if; -- What is this?

-- Override Approval Validation

If (l_can_enter_override_approver = 'Y') OR (l_default_override_approver_id is not null) then

   If(l_override_approval_style_id is null) then

		hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_VLD_OAPPROVER_INCOMPLETE'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

   End if;

End if;

-- OTL - ABS Integration
If (NVL(l_absences_integration,'N') = 'Y') AND
   (l_otm_explosion = 'Y') then

		hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_ABS_NO_OTLR'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );


End if;

-- Bug 8855103
-- Added the below error message for mid period pref changes for ABS.
IF (NVL(l_absences_integration,'N') = 'Y')
  AND l_mismatch_abs
THEN
		hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HXC_ABS_MID_PERIOD_PREF'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );
END IF;



EXCEPTION WHEN e_no_resource_id_error
THEN

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HR_6153_ALL_PROCEDURE_FAIL'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => 'PROCEDURE&'||l_proc||'&STEP&1'
                    ,   p_application_short_name  => 'PAY'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

WHEN e_no_rtr_id
THEN

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'HR_6153_ALL_PROCEDURE_FAIL'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => 'PROCEDURE&no rtr id for rules evaluation&STEP&2'
                    ,   p_application_short_name  => 'PAY'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

WHEN OTHERS
THEN

-- v115.9 - SUBSTR syntax

	hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		  => 'EXCEPTION'
                    ,   p_message_level		  => 'ERROR'
                    ,   p_message_field		  => NULL
                    ,   p_message_tokens	  => NULL
                    ,   p_application_short_name  => 'HXC'
                    ,   p_time_building_block_id  => l_timecard_info_rec.timecard_bb_id
                    ,   p_time_building_block_ovn => l_timecard_info_rec.timecard_ovn
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );

END execute_otc_validation;


end hxc_setup_validation_pkg;

/
