--------------------------------------------------------
--  DDL for Package Body HXC_GENERIC_RETRIEVAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_GENERIC_RETRIEVAL_UTILS" as
/* $Header: hxcretutl.pkb 120.8.12010000.9 2010/05/06 10:38:36 amakrish ship $ */

-- global package data type and variables

g_debug boolean := hr_utility.debug_enabled;

l_message_table HXC_MESSAGE_TABLE_TYPE;
l_rowid ROWID;
l_boolean boolean;

-- public function
--   time_bld_blk_changed
--
-- description
--   This function returns TRUE if the latest version of the
--   time building block specified by its ID has a greater
--   Object Version Number in the time store than that specified
--   in the call to the function
--
-- parameters
--   p_bb_id         -  time building block id
--   p_bb_ovn        -  time building block object version number

FUNCTION time_bld_blk_changed ( p_bb_id	 NUMBER
		,		p_bb_ovn NUMBER )RETURN BOOLEAN IS

CURSOR csr_get_bb_ovn IS
SELECT	MAX(tbb.object_version_number)
FROM	hxc_time_building_blocks tbb
WHERE	tbb.time_building_block_id	= p_bb_id;

l_ovn	hxc_time_building_blocks.object_version_number%TYPE;

BEGIN

OPEN  csr_get_bb_ovn;
FETCH csr_get_bb_ovn INTO l_ovn;
CLOSE csr_get_bb_ovn;

IF ( l_ovn > p_bb_ovn )
THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END time_bld_blk_changed;

-- Bug 6121705
-- Private function chk_need_adj
-- Checks to see if the detail record referred to had a history of transfer previously
-- thru a different process ( OTM or BEE). If it is transferred, need to capture those
-- ovns, so insert those into the temp table created for reversal batches.

-- Bug 8366309
-- Added new parameters p_bb_ovn and p_action.

FUNCTION chk_need_adj ( p_tc_id           NUMBER,
                        p_tc_ovn          NUMBER,
                        p_resource_id     NUMBER,
                        p_date_earned     DATE,
                        p_bb_id           NUMBER,
                        p_bb_ovn          NUMBER,
                        p_action          VARCHAR2,
                        p_retr_process_id NUMBER )
RETURN BOOLEAN
IS

-- This cursor would pull out the last transferred ovn (if any) for the given
-- detail block, where transaction process is either transfer_to_bee or transfer
-- to_otm.
   CURSOR cur_chk_retr_history (p_curr_bb_id NUMBER ) IS
   SELECT htd.time_building_block_id,
          htd.time_building_block_ovn,
          ht.transaction_process_id
     FROM hxc_transaction_details htd,
          hxc_transactions ht,
          hxc_retrieval_processes hrp
    WHERE htd.time_building_block_id = p_curr_bb_id
      AND htd.transaction_id         = ht.transaction_id
      AND ht.type                    = 'RETRIEVAL'
      AND htd.status                 = 'SUCCESS'
      AND ht.transaction_process_id IN (-1,hrp.retrieval_process_id)
      AND hrp.name    =  'BEE Retrieval Process'
      ORDER BY 2 DESC ;

   l_tbb_id       NUMBER;
   l_tbb_ovn      NUMBER;
   l_rt_id        NUMBER;
   l_return       BOOLEAN := FALSE;
   l_batch_source VARCHAR2(15);

BEGIN

      OPEN cur_chk_retr_history ( p_bb_id);

      -- Fetch the first value, which is the last transferred ovn.
      -- We dont need anything else, just close of the cursor.

      FETCH cur_chk_retr_history
       INTO l_tbb_id,
            l_tbb_ovn,
            l_rt_id ;

      CLOSE cur_chk_retr_history;

      -- If the last transferred ovn is for the same process id, we are safe, do nothing.

      -- Bug 8366309
      -- If p_action = 'Y', then it is a DELETE action, DELETED flag = 'Y'
      --   We need to reverse this item only if the DELETED item was not
      --   retrieved earlier.  If the Deleted item was retrieved earlier
      --   the item is already adjusted;  why bother now ??
      --   So check if the OVN we are having is higher than the last
      --   one retrieved. If yes, this is a DELETE and the DELETE was
      --   retrieved earlier, so dont go in at all.
      -- If p_action = N , then this is a new entry or an update. We need to
      --   reverse out what went in. Go in.

      IF ( l_rt_id <> p_retr_process_id)
         AND(  ( p_action = 'N' )
             OR (p_action = 'Y' AND p_bb_ovn > l_tbb_ovn)
            )
      THEN
          -- If it was different, find out what source it was. Write down corresponding
          -- values into the table.
          IF(l_rt_id = -1)
          THEN
             l_batch_source := 'OTM';
          ELSE
             l_batch_source := 'Time Store';
          END IF;
          INSERT INTO hxc_bee_pref_adj_lines
                    ( timecard_id,
                      timecard_ovn,
                      resource_id,
                      detail_bb_id,
                      detail_bb_ovn,
                      date_earned,
                      batch_source
                     )
          VALUES    ( p_tc_id,
                      p_tc_ovn,
                      p_resource_id,
                      l_tbb_id,
                      l_tbb_ovn,
                      p_date_earned,
                      l_batch_source
                     );
          -- And adjustment needs to be done, return true.
          l_return := TRUE;
      END IF;
      -- If it came here, it means you dont have to adjust, so return the default value - FALSE.
      RETURN l_return;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          CLOSE  cur_chk_retr_history;
          RETURN l_return;
END chk_need_adj;


-- Bug 8366309
-- Added the new function to chk if the deleted entries
-- have the required preference to be adjusted.
-- Returns TRUE or FALSE accordingly.

FUNCTION chk_otm_pref ( p_resource_id    IN   NUMBER,
                        p_date           IN   DATE,
                        p_process_id     IN   NUMBER)
RETURN BOOLEAN
IS

l_ind   NUMBER;
l_flag  VARCHAR2(2) := 'X';

BEGIN
    -- This table would have been populated by parse_resources
    -- If the entry doesnt exist, return FALSE. something wrong.
    IF g_res_pref_list.exists(p_resource_id)
    THEN
       -- Start from this guy's first record in the rules list.
       l_ind  := g_res_pref_list(p_resource_id).otm_rules.FIRST;
       LOOP
          -- If the date we are looking for falls here
          IF p_date BETWEEN TRUNC(g_res_pref_list(p_resource_id).otm_rules(l_ind).start_date)
                        AND TRUNC(g_res_pref_list(p_resource_id).otm_rules(l_ind).end_date)
          THEN
             -- Copy the pref flag, and come out of the loop.
             l_flag := g_res_pref_list(p_resource_id).otm_rules(l_ind).flag;
             EXIT;
          ELSE
             -- Look for the next record and exit when appropriate.
             l_ind := g_res_pref_list(p_resource_id).otm_rules.NEXT(l_ind);
             EXIT WHEN NOT g_res_pref_list(p_resource_id).otm_rules.EXISTS(l_ind);
          END IF;
       END LOOP;
       -- This is the default value -- meaning we dint find a good record
       -- Send FALSE anyway.
       IF l_flag = 'X'
       THEN
          RETURN FALSE;
       -- If rules evaluation is Y and process is Apply Scheduled Rules
       ELSIF l_flag = 'Y' AND p_process_id = -1
       THEN
          RETURN TRUE;
       -- If rules evaluation is N and process is not Apply Scheduled Rules
       ELSIF l_flag = 'N' AND p_process_id <> -1
       THEN
          RETURN TRUE;
       -- None of the above, so send FALSE anyway.
       ELSE
          RETURN FALSE;
       END IF;

    ELSE
       -- No pref, send FALSE
       RETURN FALSE;
    END IF;

END chk_otm_pref;



--


PROCEDURE populate_rtr_outcomes (
			p_resource_id		NUMBER
		,   p_ret_ranges        IN t_ret_ranges
		,	p_ret_rules_tab		IN OUT NOCOPY t_ret_rule
		,	p_ret_rules_start	PLS_INTEGER
		,	p_rtr_outcomes_tab	IN OUT NOCOPY t_rtr_outcome
		) IS

l_proc 	varchar2(72);

l_start_time	hxc_time_building_blocks.start_time%TYPE;
l_stop_time	hxc_time_building_blocks.stop_time%TYPE;

l_period_tab hxc_app_period_summary_api.valid_period_tab;
l_ind PLS_INTEGER;
l_cnt PLS_INTEGER;
l_iter PLS_INTEGER;

l_outcome_index	PLS_INTEGER := 1;

l_overall_outcome_exists varchar2(1) ;

BEGIN
g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'populate_rtr_outcomes';
	hr_utility.set_location('Processing '||l_proc, 10);
END IF;

l_cnt := p_ret_rules_start;

WHILE ( l_cnt IS NOT NULL )
LOOP
l_overall_outcome_exists := 'N';

 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 20);
 END IF;

l_iter := p_ret_ranges.first;

WHILE l_iter is not null
LOOP

 if p_ret_ranges(l_iter).rtr_grp_id = p_ret_rules_tab(l_cnt).rtr_grp_id then

	-- convert to character to pass to the dyn SQL

IF ( g_debug ) THEN
	hr_utility.trace('Params for Get Valid Periods are ...');
	hr_utility.trace('Start Time is '||to_char(p_ret_ranges(l_iter).start_date,'dd-mon-yy'));
	hr_utility.trace('Stop  Time is '||to_char(p_ret_ranges(l_iter).stop_date,'dd-mon-yy'));
	hr_utility.trace('App Status is '||p_ret_rules_tab(l_cnt).status);
	hr_utility.trace('Time Recip is '||p_ret_rules_tab(l_cnt).time_recipient_id);
END IF;


-- get valid periods

	hxc_app_period_summary_api.get_valid_periods (
	  P_RESOURCE_ID			=> p_resource_id
	 ,P_TIME_RECIPIENT_ID		=> p_ret_rules_tab(l_cnt).time_recipient_id
	 ,P_START_DATE			=> TRUNC(p_ret_ranges(l_iter).start_date)
	 ,P_STOP_DATE			=> TRUNC(p_ret_ranges(l_iter).stop_date)
	 ,P_VALID_STATUS 		=> p_ret_rules_tab(l_cnt).status
	 ,P_VALID_PERIODS		=> l_period_tab );

	l_outcome_index := NVL(p_rtr_outcomes_tab.LAST,0) + 1;

	-- set outcomes exists flag in rtr_rules table so later on we know
	-- to interogate the outcome table

	IF ( l_period_tab.COUNT <> 0 )
	THEN

		IF ( l_overall_outcome_exists = 'N' )
		THEN
			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 30);
			END IF;

			p_ret_rules_tab(l_cnt).outcome_exists := 'Y';
			p_ret_rules_tab(l_cnt).outcome_start  := l_outcome_index;

			l_overall_outcome_exists := 'Y';

		END IF;

		l_ind := l_period_tab.FIRST;

		WHILE l_ind IS NOT NULL
		LOOP

			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 50);
			END IF;

			p_rtr_outcomes_tab(l_outcome_index).rtr_grp_id        := p_ret_rules_tab(l_cnt).rtr_grp_id;
			p_rtr_outcomes_tab(l_outcome_index).time_recipient_id := p_ret_rules_tab(l_cnt).time_recipient_id;
			p_rtr_outcomes_tab(l_outcome_index).start_time        := l_period_tab(l_ind).start_time;
			p_rtr_outcomes_tab(l_outcome_index).stop_time         := l_period_tab(l_ind).stop_time;

			l_outcome_index := l_outcome_index + 1;

			l_ind := l_period_tab.NEXT(l_ind);

		END LOOP;

		 IF ( g_debug ) THEN
		 	hr_utility.set_location('Processing '||l_proc, 60);
		 END IF;

	l_period_tab.DELETE;

	END IF;	-- l_period_tab.COUNT <> 0

 End if; --if p_ret_ranges(iter).rtr_grp_id = p_ret_rules_tab(l_cnt).rtr_grp_id

l_iter := p_ret_ranges.next(l_iter);


END LOOP;

if (l_overall_outcome_exists = 'Y') then
	p_ret_rules_tab(l_cnt).outcome_stop := l_outcome_index - 1;
else
    p_ret_rules_tab(l_cnt).outcome_exists := 'N';
end if;

l_cnt := p_ret_rules_tab.NEXT(l_cnt);

END LOOP;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 70);
END IF;

END populate_rtr_outcomes;

PROCEDURE parse_resources (
		    p_process_id   NUMBER
		,   p_ret_tr_id    NUMBER
		,   p_prefs IN OUT NOCOPY t_pref
		,   p_ret_rules IN OUT NOCOPY t_ret_rule
		,   p_rtr_outcomes IN OUT NOCOPY t_rtr_outcome
		,   p_errors IN OUT NOCOPY t_errors ) IS



TYPE r_resource_rtr is RECORD (
dummy VARCHAR2(1)
);

TYPE t_resource_rtr IS TABLE OF r_resource_rtr INDEX BY BINARY_INTEGER;

l_resource_rtr t_resource_rtr;

l_resource_rrg_id_tab t_resource_rtr;

l_ret_ranges_tmp_tab t_resource_rtr;


l_tmp_otm_tab hxc_preference_evaluation.t_pref_table;
l_tmp_rtr_tab hxc_preference_evaluation.t_pref_table;


l_ret_ranges  t_ret_ranges;
l_ret_ranges1  t_ret_ranges;

l_tmp_otm_iter PLS_INTEGER;
l_tmp_rtr_iter PLS_INTEGER;


l_iter PLS_INTEGER;
l_ret_range_iter PLS_INTEGER;

l_proc 	varchar2(72);

l_dummy NUMBER(1);

l_rr_index PLS_INTEGER := 1;
l_index	   PLS_INTEGER;
l_resource_index PLS_INTEGER;



l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_status                VARCHAR2(40);
l_emp			per_people_f.last_name%TYPE;
l_rtr_grp_id		NUMBER(15);
l_app_set_id		NUMBER(15);

l_otm_explosion		VARCHAR2(1);

l_rtr_exists		t_rtr_exists;


l_bee_ret_id            hxc_retrieval_processes.retrieval_process_id%TYPE;


l_process_id		hxc_retrieval_processes.retrieval_process_id%TYPE;
l_rtr_process_id	hxc_retrieval_processes.retrieval_process_id%TYPE;


l_resource_start_time DATE;
l_resource_stop_time DATE;
l_pref_date_not_ok BOOLEAN := FALSE;
l_pref_date DATE;

l_set_rtr BOOLEAN;

-- GPM v115.40

CURSOR csr_get_retrieval_rules ( p_rtr_grp_id NUMBER, p_process_id NUMBER ) IS
SELECT
	rrc.time_recipient_id
,	rrc.status
FROM
	hxc_retrieval_rule_comps rrc
,	hxc_retrieval_rules rr
,	hxc_retrieval_rule_grp_comps_v rrgc
,	hxc_retrieval_rule_groups_v rrg
WHERE
	rrg.retrieval_rule_group_id  = p_rtr_grp_id
AND
	rrgc.retrieval_rule_group_id = rrg.retrieval_rule_group_id AND
	rrgc.retrieval_process_id    = p_process_id
AND
	rr.retrieval_rule_id	= rrgc.retrieval_rule_id
AND
	rrc.retrieval_rule_id	= rr.retrieval_rule_id;

CURSOR 	csr_get_emp ( p_resource_id NUMBER ) IS
SELECT	last_name
FROM	per_people_f
WHERE	person_id = p_resource_id;

CURSOR  csr_get_app_sets ( p_app_set_id NUMBER ) IS
SELECT	1
FROM	hxc_application_set_comps_v apsc
,	hxc_application_sets_v aps
WHERE	aps.application_set_id = p_app_set_id
AND
	apsc.application_set_id = aps.application_set_id AND
	apsc.time_recipient_id  = p_ret_tr_id;

CURSOR  csr_get_bee_ret_id IS
SELECT	ret.retrieval_process_id
FROM    hxc_retrieval_processes ret
WHERE   ret.name = 'BEE Retrieval Process';


BEGIN -- parse_resources

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
 l_proc := g_package||'parse_resources';
 hr_utility.set_location('Processing '||l_proc, 10);

 hr_utility.trace('');
 hr_utility.trace('************** Params are: *****************');
 hr_utility.trace('is p_process_id '||to_char(p_process_id));
 hr_utility.trace('is p_ret_tr_id '||to_char(p_ret_tr_id));
 hr_utility.trace('');

END IF;

l_process_id := p_process_id;


-- Get the BEE retrieval process id

OPEN  csr_get_bee_ret_id;
FETCH csr_get_bee_ret_id INTO l_bee_ret_id;

IF ( csr_get_bee_ret_id%NOTFOUND )
THEN

    CLOSE csr_get_bee_ret_id;

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','no BEE Retrieval Process id');
    fnd_message.raise_error;

END IF;

CLOSE csr_get_bee_ret_id;

-- GPM v115.40

-- loop through the resources table and get the preferences

l_resource_index := hxc_generic_retrieval_utils.g_resources.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP

BEGIN

--
-- REMEMBER the index on g_resources is the resource id!!!
--

WHILE l_resource_index IS NOT NULL
LOOP
	IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 15);
	END IF;

	--delete the ret ranges table. This is because we maintain ret ranges table for each resource
        l_ret_ranges.delete;

	-- need to hit the database to retrieve this person's prefs

	l_resource_start_time := TRUNC(hxc_generic_retrieval_utils.g_resources(l_resource_index).start_time);

	l_resource_stop_time  := TRUNC(hxc_generic_retrieval_utils.g_resources(l_resource_index).stop_time);

-- GPM v115.27

IF ( g_debug ) THEN

hr_utility.trace('************* NEW RESOURCE ********************');
hr_utility.trace('resource id is '||to_char(l_resource_index));
hr_utility.trace('resource start date is '||to_char(l_resource_start_time,  'dd-mon-yyyy hh24:mi:ss'));
hr_utility.trace('resource stop  date is '||to_char(l_resource_stop_time,  'dd-mon-yyyy hh24:mi:ss'));
hr_utility.trace('************* NEW RESOURCE ********************');

END IF;


--Changing the call to preference evaluation here. We are passing the entire range of time
--so that the pref table contains date tracked changes also. The following procedures
--would return tables sorted on start date.

BEGIN

hxc_preference_evaluation.resource_preferences(
                                               p_resource_id  => l_resource_index,
                                               p_preference_code => 'TS_PER_RETRIEVAL_RULES',
                                               p_start_evaluation_date =>l_resource_start_time,
                                               p_end_evaluation_date =>l_resource_stop_time,
                                               p_sorted_pref_table => l_tmp_rtr_tab,
                                               p_no_prefs_outside_asg => TRUE );

IF l_process_id IN ( -1, l_bee_ret_id)
THEN
hxc_preference_evaluation.resource_preferences(
                                               p_resource_id  => l_resource_index,
                                               p_preference_code => 'TC_W_RULES_EVALUATION',
                                               p_start_evaluation_date => l_resource_start_time,
                                               p_end_evaluation_date => l_resource_stop_time,
                                               p_sorted_pref_table => l_tmp_otm_tab,
                                               p_clear_cache => TRUE,
                                               p_no_prefs_outside_asg => FALSE );
END IF;

--clear the cache, since we have obtained the values
hxc_preference_evaluation.clear_sort_pref_table_cache;

EXCEPTION
WHEN OTHERS THEN
		IF ( g_debug ) THEN
			hr_utility.trace('Error 1 : '||substr(sqlerrm,1,100));
		END IF;
	hr_utility.set_message(809, SUBSTR('HXC_NO_RESRC_DATES-'||to_char(l_resource_index),1,28));
	p_errors(l_resource_index).exception_description := SUBSTR('HXC_NO_RESRC_DATES-'||to_char(l_resource_index),1,2000);
	p_prefs(l_resource_index).prefs_ok := 'X';
END;

--Check for any errors - if not proceed

IF ( NOT p_errors.EXISTS(l_resource_index) )
THEN

-- Now we need to make sure that we have the preferences we are interested in

IF (l_process_id = -1 or l_process_id = l_bee_ret_id)
THEN
	IF ( l_tmp_otm_tab.COUNT = 0 OR l_tmp_rtr_tab.COUNT = 0 )
	THEN
		IF ( g_debug ) THEN
			hr_utility.trace('Error 2 : '||substr(sqlerrm,1,100));
		END IF;
		p_errors(l_resource_index).exception_description := 'HXC_NO_HIER_FOR_DATE';
		p_prefs(l_resource_index).prefs_ok := 'X';
	END IF;
ELSE
	IF ( l_tmp_rtr_tab.COUNT = 0 )
	THEN
		IF ( g_debug ) THEN
			hr_utility.trace('Error 3 : '||substr(sqlerrm,1,100));
		END IF;
		p_errors(l_resource_index).exception_description := 'HXC_NO_HIER_FOR_DATE';
		p_prefs(l_resource_index).prefs_ok := 'X';
	END IF;
END IF; -- (l_process_id = -1 or l_process_id = l_bee_ret_id)


--Check for any errors - if not proceed
IF ( NOT p_errors.EXISTS(l_resource_index) )
THEN

-- Bug 8366309
-- Copy down the preferences for this employee into
-- the global table of tables. Do this only for
-- BEE retrievals.
IF l_process_id IN (-1, l_bee_ret_id)
THEN
   FOR l_filter_ind IN 1 .. l_tmp_otm_tab.LAST
   LOOP
      --Copy attribute1 as the flag.
      g_res_pref_list(l_resource_index).otm_rules(l_filter_ind).flag := l_tmp_otm_tab(l_filter_ind).attribute1;
      -- Copy the date ranges.
      g_res_pref_list(l_resource_index).otm_rules(l_filter_ind).start_date
                                 := l_tmp_otm_tab(l_filter_ind).start_date;
      g_res_pref_list(l_resource_index).otm_rules(l_filter_ind).end_date
                                 := l_tmp_otm_tab(l_filter_ind).end_date;

   END LOOP;
END IF;


IF ( g_debug ) AND l_process_id IN (-1, l_bee_ret_id)
THEN

hr_utility.trace('OTM prefs tab is');
hr_utility.trace('Preference Code         ATT1    ATT2   Start Date             End Date');
hr_utility.trace('---------------------   ------  -----  --------------------   ---------------------');

FOR l_filter_ind IN 1 .. l_tmp_otm_tab.LAST
LOOP

	hr_utility.trace(l_tmp_otm_tab(l_filter_ind).preference_code||'   '||
                         l_tmp_otm_tab(l_filter_ind).attribute1||'       '||
                         l_tmp_otm_tab(l_filter_ind).attribute2||'      '||
                         to_char(l_tmp_otm_tab(l_filter_ind).start_date,'DD-MON-YYYY HH24:MI:SS')||'   '||
                         to_char(l_tmp_otm_tab(l_filter_ind).end_date,'DD-MON-YYYY HH24:MI:SS'));

END LOOP;

hr_utility.trace('---------------------   ------  -----  --------------------   ---------------------');

hr_utility.trace('RTR prefs tab is');
hr_utility.trace('Preference Code         ATT1    ATT2   Start Date             End Date');
hr_utility.trace('---------------------   ------  -----  --------------------   ---------------------');

FOR l_filter_ind IN 1 .. l_tmp_rtr_tab.LAST
LOOP

	hr_utility.trace(l_tmp_rtr_tab(l_filter_ind).preference_code||'  '||
                         l_tmp_rtr_tab(l_filter_ind).attribute1||'       '||
                         l_tmp_rtr_tab(l_filter_ind).attribute2||'      '||
                         to_char(l_tmp_rtr_tab(l_filter_ind).start_date,'DD-MON-YYYY HH24:MI:SS')||'   '||
                         to_char(l_tmp_rtr_tab(l_filter_ind).end_date,'DD-MON-YYYY HH24:MI:SS'));

END LOOP;

hr_utility.trace('---------------------   ------  -----  --------------------   ---------------------');

END IF; -- l debug

--We have filtered the main pref table and populated the temporary tables we created.
--we need to get a merged table based on Application process..
--The merge logic assumes that the temporary tables are sorted on start_date.
--Since the above call to pref evaluation returns rows in a sorted order we dont have any problem.

--we need to get a merged table based on Application process..
--however this will be done only if the process is Apply Schedule Rules or BEE process
--otherwise the l_tmp_rtr_tab table will be copied to ret_ranges table.
--Note : We dont need the merge logic in case the Application Process is not BEE or Apply Schedule Rules

IF ( g_debug ) THEN
	hr_utility.trace('Merge logic starts');
END IF;

if (l_process_id = -1 or l_process_id = l_bee_ret_id) then
--merge logic
IF ( g_debug ) THEN
	hr_utility.trace('merge logic');
END IF;

l_ret_range_iter :=1;
l_tmp_rtr_iter := l_tmp_rtr_tab.first;

WHILE l_tmp_rtr_iter is not null
LOOP
  l_tmp_otm_iter := l_tmp_otm_tab.first;

  WHILE l_tmp_otm_iter is not null
  LOOP
   --check for overlap

   if (l_tmp_rtr_tab(l_tmp_rtr_iter).end_date >= l_tmp_otm_tab(l_tmp_otm_iter).start_date ) and
      (l_tmp_rtr_tab(l_tmp_rtr_iter).start_date <= l_tmp_otm_tab(l_tmp_otm_iter).end_date ) then

     --there is a overlap

     IF ( (l_process_id = l_bee_ret_id AND l_tmp_otm_tab (l_tmp_otm_iter).attribute1 = 'N') OR
	      (l_process_id = -1 AND l_tmp_otm_tab (l_tmp_otm_iter).attribute1 = 'Y')
	    )
     THEN
       --we need this record
     l_ret_ranges (l_ret_range_iter).rtr_grp_id := l_tmp_rtr_tab (l_tmp_rtr_iter).attribute1;
     l_ret_ranges (l_ret_range_iter).start_date := greatest (l_tmp_rtr_tab (l_tmp_rtr_iter).start_date,l_tmp_otm_tab (l_tmp_otm_iter).start_date);
	 l_ret_ranges (l_ret_range_iter).stop_date := least (l_tmp_rtr_tab (l_tmp_rtr_iter).end_date,l_tmp_otm_tab (l_tmp_otm_iter).end_date);
     l_ret_range_iter := l_ret_range_iter+1;

     END IF;

   end if;

  l_tmp_otm_iter := l_tmp_otm_tab.next(l_tmp_otm_iter);
  END LOOP;

l_tmp_rtr_iter := l_tmp_rtr_tab.next(l_tmp_rtr_iter);
END LOOP;

IF ( g_debug ) THEN
	hr_utility.trace('merge logic over');
END IF;

--merge logic over
else

--process is neither Apply Schedule rules nor BEE. Hence we just copy
--l_tmp_rtr_tab to l_ret_ranges

IF ( g_debug ) THEN
	hr_utility.trace('not BEE or Apply thus copy RTR');
END IF;

l_iter := 1;
l_tmp_rtr_iter := l_tmp_rtr_tab.first;

while l_tmp_rtr_iter is not null
loop
  l_ret_ranges(l_iter).rtr_grp_id :=  l_tmp_rtr_tab(l_tmp_rtr_iter).attribute1;
  l_ret_ranges(l_iter).start_date :=  l_tmp_rtr_tab(l_tmp_rtr_iter).start_date;
  l_ret_ranges(l_iter).stop_date :=  l_tmp_rtr_tab(l_tmp_rtr_iter).end_date;

l_iter := l_iter + 1;
l_tmp_rtr_iter := l_tmp_rtr_tab.next(l_tmp_rtr_iter);
end loop;


end if;
IF ( g_debug ) THEN
	hr_utility.trace('Merge logic ends');
END IF;

--we can delete the pref table and temporary tables to save space
l_tmp_otm_tab.DELETE;
l_tmp_rtr_tab.DELETE;


--the resulting l_ret_ranges table is not sorted on rtr_grp_id. This needs to be done because
--ret_rules needs to be in sorted order and so this table must be in a sorted manner.
--Please note that we are just sorting the table only on rtr_grp_id.The table is already sorted based
--on start date.

--the unsorted table is l_ret_ranges.
--we shall have a temporary table that we can use to store the distinct
--rtr grp ids. It will be indexed on rtr grp id.

IF ( g_debug ) THEN
	hr_utility.trace('Sorting the unsorted ret ranges table');
END IF;
l_iter:= l_ret_ranges.first;

WHILE l_iter is not null
LOOP
	l_tmp_rtr_iter := l_ret_ranges(l_iter).rtr_grp_id;
	l_ret_ranges_tmp_tab(l_tmp_rtr_iter).dummy := 'Y';

	l_iter:= l_ret_ranges.next(l_iter);
END LOOP;

--we have got the tmp table.
l_tmp_rtr_iter := l_ret_ranges_tmp_tab.first;
l_index := 1;

WHILE l_tmp_rtr_iter is not null
LOOP --through the tmp table

	l_iter:= l_ret_ranges.first;

	WHILE l_iter is not null
	LOOP -- through the ret ranges and retrieve columns and put them into another temporary table.
		 -- we can use the l_ret_ranges1 here.That will contain the sorted columns.
	     if l_ret_ranges(l_iter).rtr_grp_id = l_tmp_rtr_iter then
			l_ret_ranges1(l_index).rtr_grp_id := l_ret_ranges(l_iter).rtr_grp_id;
			l_ret_ranges1(l_index).start_date := l_ret_ranges(l_iter).start_date;
			l_ret_ranges1(l_index).stop_date := l_ret_ranges(l_iter).stop_date;
			l_index := l_index +1;
		 end if;

	     l_iter:= l_ret_ranges.next(l_iter);
	END LOOP;

	l_tmp_rtr_iter:= l_ret_ranges_tmp_tab.next(l_tmp_rtr_iter);
END LOOP;
--

l_ret_ranges := l_ret_ranges1;
l_ret_ranges1.delete;
l_ret_ranges_tmp_tab.delete;

IF ( g_debug ) THEN
	hr_utility.trace('Sorting the unsorted ret ranges table over');
END IF;


--Now we have the final ret ranges table in l_ret_ranges. We will use the ret ranges table to populate
--ret_rules and outcomes table.

--We need to ensure that the l_ret_ranges contains atleast 1 record for
--us to proceed.
if (l_ret_ranges.COUNT >0) then


IF ( g_debug ) THEN

hr_utility.trace('Ret Ranges Table');
hr_utility.trace('Index    RTR GRP ID   Start Date             End Date');
hr_utility.trace('------   -----------  --------------------   ---------------------');

FOR l_filter_ind IN 1 .. l_ret_ranges.LAST
LOOP

	hr_utility.trace(to_char(l_filter_ind)||'    '||
                         to_char(l_ret_Ranges(l_filter_ind).rtr_grp_id)||'  '||
                         to_char(l_ret_ranges(l_filter_ind).start_date,'DD-MON-YYYY HH24:MI:SS')||'   '||
                         to_char(l_ret_ranges(l_filter_ind).stop_date,'DD-MON-YYYY HH24:MI:SS'));

END LOOP;

hr_utility.trace('-----------  --------------------   ---------------------');

END IF;

l_resource_rtr.DELETE;
l_resource_rrg_id_tab.DELETE;
l_set_rtr := FALSE;

-- build a distinct table of resource RRGs
-- this is so we can detect whether or not to error if the
-- resource does not have a RRG for this process when there are more
-- than one RRG for the resource

FOR x IN l_ret_ranges.FIRST .. l_ret_ranges.LAST
LOOP

	l_resource_rrg_id_tab(l_ret_ranges(x).rtr_grp_id).dummy := 'Y';

END LOOP;



FOR ret_range_iter IN l_ret_ranges.FIRST .. l_ret_ranges.LAST
LOOP

 if not (l_resource_rtr.exists(l_ret_ranges(ret_range_iter).rtr_grp_id)) then

 l_rtr_grp_id := l_ret_ranges(ret_range_iter).rtr_grp_id;

 l_resource_rrg_id_tab.DELETE(l_rtr_grp_id);

 l_resource_rtr(l_ret_ranges(ret_range_iter).rtr_grp_id).dummy := 'Y';

 IF ( g_debug ) THEN
 hr_utility.set_location('Processing '||l_proc, 55);
 END IF;

	-- check to see that we haven't got these rules before

	IF ( l_rtr_exists.EXISTS(l_rtr_grp_id) )
	THEN
		IF ( g_debug ) THEN
		hr_utility.trace('hitting PL/SQL table for rtr');
		END IF;

		l_rr_index := NVL(p_ret_rules.LAST, 0) + 1;

		IF NOT l_set_rtr
		THEN

			p_prefs(l_resource_index).rtr_start := l_rr_index;
			p_prefs(l_resource_index).prefs_ok  := 'Y';

			l_set_rtr := TRUE;

		END IF;

		FOR x IN l_rtr_exists(l_rtr_grp_id).rtr_start ..
                         l_rtr_exists(l_rtr_grp_id).rtr_stop
		LOOP
			p_ret_rules(l_rr_index) := p_ret_rules(x);

			-- GPM v115.12 30-JUL-01

			l_rr_index := l_rr_index + 1;

		END LOOP;

		p_prefs(l_resource_index).rtr_end := l_rr_index -1;

	ELSE

		-- get the retrieval rules for the given resource ids retrieval group

		IF ( g_debug ) THEN
		hr_utility.trace('hitting db for rtr');
		END IF;

-- l_process_id is passed to the cursor csr_get_retrieval_rules. However
--for the 'Apply Schedule Rules' Process the process id is 1 and the
--cursor will not retrieve rows in case 1 is passed. Hence we need to
--pass the BEE Retrieval ID in that case.
if (l_process_id = -1) then
l_rtr_process_id := l_bee_ret_id;
else
l_rtr_process_id := l_process_id;
end if;

		OPEN  csr_get_retrieval_rules ( l_ret_ranges(ret_range_iter).rtr_grp_id, l_rtr_process_id );
		FETCH csr_get_retrieval_rules INTO l_time_recipient_id, l_status;

		-- if there are no retrieval rules for the person for this retrieval
		-- then error.

		IF csr_get_retrieval_rules%NOTFOUND
		THEN

                   -- only error if this is the last RRG for this person

		   IF ( l_resource_rrg_id_tab.COUNT = 0 )
                   THEN

			OPEN  csr_get_emp ( l_resource_index);
			FETCH csr_get_emp INTO l_emp;
			CLOSE csr_get_emp;

			hr_utility.set_message(809, 'HXC_NO_RET_RULE_FOR_RET');
			hr_utility.set_message_token('EMP', l_emp);

			p_errors(l_resource_index).exception_description := SUBSTR('HXC_NO_RET_RULE_FOR_RET: '||l_emp,1,2000);
			p_prefs(l_resource_index).prefs_ok := 'X';

                   END IF;

			CLOSE csr_get_retrieval_rules;

		ELSE
			-- get next index value for the retrieval rules

			l_rr_index := NVL(p_ret_rules.LAST,0) + 1;

			IF NOT l_set_rtr
			THEN

				-- set this value in the prefs table for use later

				p_prefs(l_resource_index).rtr_start := l_rr_index;
				p_prefs(l_resource_index).prefs_ok  := 'Y';

				l_set_rtr := TRUE;

			END IF;

		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 60);
		END IF;

		WHILE csr_get_retrieval_rules%FOUND
		LOOP
			IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 70);
			END IF;

			-- maintain table of retrieval rules

			p_ret_rules(l_rr_index).rtr_grp_id        := l_ret_ranges(ret_range_iter).rtr_grp_id;
			p_ret_rules(l_rr_index).time_recipient_id := l_time_recipient_id;
			p_ret_rules(l_rr_index).status            := l_status;

			FETCH csr_get_retrieval_rules INTO l_time_recipient_id, l_status;

			l_rr_index := l_rr_index + 1;

		END LOOP;

		Close csr_get_retrieval_rules;

		-- maintain l_rtr_exists

		l_rtr_exists(l_rtr_grp_id).rtr_start := p_prefs(l_resource_index).rtr_start;
		l_rtr_exists(l_rtr_grp_id).rtr_stop  := l_rr_index - 1;
		p_prefs(l_resource_index).rtr_end    := l_rr_index - 1;

		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 80);
		END IF;

		END IF; -- csr_get_retrieval_rules%NOTFOUND

	END IF; -- l_rtr_exists.EXISTS(l_resource_index)

-- now get the application period dates for these

 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 90);
 END IF;

END IF; -- if not
        --(l_resource_rtr.exists(p_ret_range(ret_range).rtr_grp_id) then

END LOOP; -- FOR ret_range_iter l_ret_ranges.FIRST .. l_ret_ranges.LAST

-- make sure the retrieval rule did not error

IF NOT p_errors.EXISTS(l_resource_index)
THEN
 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 95);
 END IF;

populate_rtr_outcomes (
			p_resource_id		=> l_resource_index
		,   p_ret_ranges        => l_ret_ranges
		,	p_ret_rules_tab		=> p_ret_rules
		,	p_ret_rules_start	=> p_prefs(l_resource_index).rtr_start
		,	p_rtr_outcomes_tab	=> p_rtr_outcomes
        );

END IF; --IF NOT p_errors.EXISTS(l_resource_index)

 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 97);
 END IF;

ELSE

-- not an error - there were just no valid RTRs for this person for this
-- date range

 	p_prefs(l_resource_index).prefs_ok := 'N';

END IF; --IF (l_ret_ranges.COUNT > 0)

 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 98);
 END IF;

END IF; -- NOT p_errors.EXISTS(l_resource_index) - hxc_no_hier_for_date check

END IF; -- NOT p_errors.EXISTS(l_resource_index) - preference call

l_resource_index := hxc_generic_retrieval_utils.g_resources.NEXT(l_resource_index);

END LOOP; -- g_resources loop

 IF ( g_debug ) THEN
 	hr_utility.set_location('Processing '||l_proc, 110);
 END IF;

EXCEPTION WHEN OTHERS
THEN
	-- unhandled excpetion whilst processing resource table

	IF ( g_debug ) THEN
		hr_utility.trace('in parse resources unhandled exception');
		hr_utility.trace('resource is '||to_char(l_resource_index));
		hr_utility.trace('error is '||SUBSTR(SQLERRM,1,150));
	END IF;

	p_errors(l_resource_index).exception_description := SUBSTR(l_proc||':'||SQLERRM,1,2000);
	p_prefs(l_resource_index).prefs_ok := 'X';
	l_resource_index := hxc_generic_retrieval_utils.g_resources.NEXT(l_resource_index);

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 150);
	END IF;

END;

END LOOP; -- master g_resources loop

IF ( g_debug ) THEN

hr_utility.trace('****** Resources  ********');

l_resource_index := hxc_generic_retrieval_utils.g_resources.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP
	hr_utility.trace('');
	hr_utility.trace('index is '||to_char(l_resource_index));
	hr_utility.trace('start time is '||to_char(hxc_generic_retrieval_utils.g_resources(l_resource_index).start_time,'dd-mon-yyyy'));
	hr_utility.trace('stop time is '||to_char(hxc_generic_retrieval_utils.g_resources(l_resource_index).stop_time,'dd-mon-yyyy'));
	hr_utility.trace('');

l_resource_index := hxc_generic_retrieval_utils.g_resources.NEXT(l_resource_index);

END LOOP;

hr_utility.trace('****** Prefs  ********');

l_resource_index := p_prefs.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP
	hr_utility.trace('');
	hr_utility.trace('index is '||to_char(l_resource_index));
	hr_utility.trace('prefs_ok flag is '||p_prefs(l_resource_index).prefs_ok);
	hr_utility.trace('rtr grp start is '||to_char(p_prefs(l_resource_index).rtr_start));
	hr_utility.trace('rtr grp end is '||to_char(p_prefs(l_resource_index).rtr_end));
	hr_utility.trace('');

l_resource_index := p_prefs.NEXT(l_resource_index);

END LOOP;

hr_utility.trace('****** RTR Rules  ********');

l_resource_index := p_ret_rules.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP
	hr_utility.trace('');
	hr_utility.trace('index is '||to_char(l_resource_index));
	hr_utility.trace('rtr grp id is '||to_char(p_ret_rules(l_resource_index).rtr_grp_id));
	hr_utility.trace('time recipient id is '||to_char(p_ret_rules(l_resource_index).time_recipient_id));
	hr_utility.trace('status is :'||p_ret_rules(l_resource_index).status||':');
	hr_utility.trace('outcome exists is '||p_ret_rules(l_resource_index).outcome_exists);
	hr_utility.trace('outcome start is '||to_char(p_ret_rules(l_resource_index).outcome_start));
	hr_utility.trace('outcome stop is '||to_char(p_ret_rules(l_resource_index).outcome_stop));
	hr_utility.trace('');

l_resource_index := p_ret_rules.NEXT(l_resource_index);

END LOOP;

hr_utility.trace('****** RTR Outcome  ********');

l_resource_index := p_rtr_outcomes.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP
	hr_utility.trace('');
	hr_utility.trace('index is '||to_char(l_resource_index));
	hr_utility.trace('rtr grp id is '||to_char(p_rtr_outcomes(l_resource_index).rtr_grp_id));
	hr_utility.trace('time recipient id is '||to_char(p_rtr_outcomes(l_resource_index).time_recipient_id));
	hr_utility.trace('start time is '||to_char(p_rtr_outcomes(l_resource_index).start_time,'dd-mon-yyyy'));
	hr_utility.trace('stop time is '||to_char(p_rtr_outcomes(l_resource_index).stop_time,'dd-mon-yyyy'));
	hr_utility.trace('');

l_resource_index := p_rtr_outcomes.NEXT(l_resource_index);

END LOOP;

hr_utility.trace('****** Errors ********');

l_resource_index := p_errors.FIRST;

WHILE l_resource_index IS NOT NULL
LOOP
	hr_utility.trace('');
	hr_utility.trace('index is '||to_char(l_resource_index));
	hr_utility.trace('exception is '||SUBSTR(p_errors(l_resource_index).exception_description,1,60));
	hr_utility.trace('');

l_resource_index := p_errors.NEXT(l_resource_index);

END LOOP;

END IF; -- g_debug

END parse_resources;

--
-- private function
--   chk_retrieve
--
-- description
--   returns TRUE or FALSE depending on whether the bld blks is allowed
--   to be retrieved based on the resources application set and retrieval
--   time recipient and then if this is OK, based on the retrieval rules
--   for the bld blks resource.

PROCEDURE chk_retrieve (
			p_resource_id	NUMBER
		,	p_bb_status	VARCHAR2
                ,       p_bb_deleted    VARCHAR2
		,	p_bb_start_time	DATE
		,	p_bb_stop_time	DATE
		,       p_bb_id         NUMBER  -- 6121705
		,       p_bb_ovn        NUMBER  -- 6121705
		,	p_attribute_category  VARCHAR2   -- Absences Integration -- 8779478
		,       p_process       VARCHAR2 -- 6121705
		,  	p_prefs		t_pref
		,  	p_ret_rules	t_ret_rule
		,	p_rtr_outcomes	t_rtr_outcome
                ,       p_tc_bb_id      NUMBER
                ,       p_tc_bb_ovn     NUMBER
		,	p_timecard_retrieve IN OUT NOCOPY BOOLEAN
		,	p_day_retrieve	    IN OUT NOCOPY BOOLEAN
                ,       p_tc_locked         IN OUT NOCOPY BOOLEAN
		,       p_tc_first_lock     IN OUT NOCOPY BOOLEAN
		,	p_bb_skipped_reason    OUT NOCOPY VARCHAR2) IS

l_outcome_start	PLS_INTEGER;
l_outcome_stop	PLS_INTEGER;

l_rtr_start	PLS_INTEGER;
l_rtr_end	PLS_INTEGER;

l_working	varchar2(15) := 'WORKING';

l_overall_outcome BOOLEAN := FALSE;

l_proc 	varchar2(72);

TYPE r_rtr_grp IS RECORD (dummy VARCHAR2(1));
TYPE t_rtr_grp IS TABLE OF r_rtr_grp INDEX BY BINARY_INTEGER;
l_rtr_grp t_rtr_grp;

l_old_rtr_grp_id NUMBER(15) := -1;

l_rsn_blk_wrking 	varchar2(80) := 'Block Status does not meet the Retrieval Rule Group preference';
l_rsn_blk_not_approved 	varchar2(50) := 'Block is not yet Approved';
-- Bug 8888911
-- Reason corrected.
l_rsn_blk_transferred 	varchar2(150):= 'Block does not meet Retrieval Preference for this process';
l_rsn_locked 		varchar2(50) := 'Timecard is already locked';
l_rsn_failed_lock 	varchar2(50) := 'Failed to obtain a lock';

-- Added for OTL-Absences Integration (Bug 8779478)
-- Bug 9657355
-- Reason corrected
l_rsn_absence_detail    varchar2(100) := 'Absence detail does not get processed by Transfer time from OTL to BEE process';


BEGIN

g_debug := hr_utility.debug_enabled;

-- Absences code starts
-- OTL-Absences Integration (Bug 8779478)


IF g_debug THEN
	hr_utility.trace('ABS:Entered chk_retrieve');
	hr_utility.trace('ABS:p_attribute_category = '|| p_attribute_category);
END IF;

IF (p_attribute_category like 'ELEMENT%') THEN

 	 IF g_debug THEN
		hr_utility.trace('ABS:p_bb_id = '||p_bb_id);
		hr_utility.trace('ABS:p_bb_ovn = '||p_bb_ovn);
	 END IF;

 	 IF (absence_link_exists(to_number(substr(p_attribute_category, 10)))) THEN

	      	  IF g_debug THEN
	              hr_utility.trace('ABS:***** Skip this Absence record *****'|| p_bb_id);
	       	  END IF;

       		  p_timecard_retrieve	:= FALSE;
		  p_day_retrieve	:= FALSE;
		  p_bb_skipped_reason 	:= l_rsn_absence_detail;

		  RETURN;

	  END IF;
END IF;

-- Absences code ends



-- check to see if we have tried to lock this timecard before
-- or if the timecard is already locked

IF ( ( p_tc_first_lock ) OR ( NOT p_tc_first_lock AND p_tc_locked ) )
THEN

-- first check preferences were OK
IF ( p_prefs(p_resource_id).prefs_ok = 'Y' AND p_bb_deleted = 'N' )
THEN

	l_rtr_start	:= p_prefs(p_resource_id).rtr_start;
	l_rtr_end	:= p_prefs(p_resource_id).rtr_end;

-- create a table of distinct RRG IDs for this resource

FOR x in l_rtr_start .. l_rtr_end
LOOP
     l_rtr_grp(p_ret_rules(x).rtr_grp_id).dummy := 'Y';
END LOOP;

WHILE l_rtr_grp.count >0 LOOP

	FOR rtr_cnt IN l_rtr_start .. l_rtr_end
	LOOP

	   IF (l_rtr_grp.EXISTS(p_ret_rules(rtr_cnt).rtr_grp_id))
           THEN
                 l_rtr_grp.DELETE(p_ret_rules(rtr_cnt).rtr_grp_id);
	   END IF;

	IF l_overall_outcome AND ( l_old_rtr_grp_id <> p_ret_rules(rtr_cnt).rtr_grp_id )
	THEN
		p_day_retrieve := TRUE;
		l_rtr_grp.DELETE;
		EXIT;
	END IF;

	IF ( p_ret_rules(rtr_cnt).status <> l_working )
	THEN

			-- need to test bld blk status

			IF ( p_bb_status = 'WORKING' )
			THEN
				p_day_retrieve := FALSE;
				l_rtr_grp.DELETE;
				p_bb_skipped_reason := l_rsn_blk_wrking;
				EXIT;
			ELSE

				-- test approval outcomes

				IF ( p_ret_rules(rtr_cnt).outcome_exists = 'Y' )
				THEN

					-- if they exist then loop for the time recipient id
					-- identified in the p_ret_rules for the resource

					l_outcome_start := p_ret_rules(rtr_cnt).outcome_start;
					l_outcome_stop  := p_ret_rules(rtr_cnt).outcome_stop;

					l_overall_outcome := FALSE;

				FOR outcome_cnt IN l_outcome_start .. l_outcome_stop
				LOOP

					IF ( ( TRUNC(p_bb_start_time) >= p_rtr_outcomes(outcome_cnt).start_time )
					AND
					   ( TRUNC(p_bb_start_time) <= p_rtr_outcomes(outcome_cnt).stop_time )
					AND
					   ( TRUNC(p_bb_stop_time)  >= p_rtr_outcomes(outcome_cnt).start_time )
					AND
					   ( TRUNC(p_bb_stop_time)  <= p_rtr_outcomes(outcome_cnt).stop_time ) )
					THEN
						-- approval OK
						l_overall_outcome := TRUE;

					END IF;

				END LOOP;

				-- check to see that approvals for this time recipient
				-- were existing, if only one missing then do not retrieve

				IF NOT ( l_overall_outcome )
				THEN
					IF l_rtr_grp.count =0 then
						p_day_retrieve := FALSE;
						p_bb_skipped_reason := l_rsn_blk_not_approved;
						EXIT;
	         	               END IF;
		                END IF;


				ELSE -- p_ret_rules(rtr_cnt).outcome_exists = 'Y'

					IF l_rtr_grp.count =0 then
					p_day_retrieve := FALSE;
					p_bb_skipped_reason := l_rsn_blk_not_approved;
					EXIT;
                                END IF;

				END IF; -- p_ret_rules(rtr_cnt).outcome_exists = 'Y'

			END IF; -- p_bb_status = 'WORKING'

	END IF; -- p_ret_rules(rtr_cnt).status <> l_working

		IF ( l_old_rtr_grp_id <> p_ret_rules(rtr_cnt).rtr_grp_id )
		THEN
			l_old_rtr_grp_id := p_ret_rules(rtr_cnt).rtr_grp_id;
		END IF;

	END LOOP; -- rtr_cnt IN l_rtr_start .. l_rtr_end

END LOOP; -- WHILE l_rtr_grp.count >0 LOOP

ELSIF ( p_prefs(p_resource_id).prefs_ok = 'Y' AND p_bb_deleted = 'Y' )
THEN

	p_day_retrieve		:= TRUE;

ELSE

	-- prefs_ok either 'X' or 'N' - either way no retrieve

	p_timecard_retrieve	:= FALSE;
	p_day_retrieve		:= FALSE;
	p_bb_skipped_reason	:= l_rsn_blk_transferred;

END IF; -- p_prefs(p_resource_id).prefs_ok <> 'X'

-- now lock the TC if p_day_retrieve is TRUE

IF ( p_day_retrieve AND p_tc_first_lock )
THEN

	hxc_lock_api.request_lock
         (p_process_locker_type      => hxc_generic_retrieval_pkg.g_lock_type
         ,p_time_building_block_id  => p_tc_bb_id
         ,p_time_building_block_ovn => p_tc_bb_ovn
         ,p_expiration_time         => 60
         ,p_messages                => l_message_table
         ,p_row_lock_id             => l_rowid
         ,p_locked_success          => p_tc_locked
	 ,p_transaction_lock_id     => hxc_generic_retrieval_pkg.g_transaction_id
         );

	IF ( NOT p_tc_locked )
	THEN
		IF ( g_debug ) THEN
			l_proc := g_package||'chk_retrieve';
			hr_utility.trace('not locked');
			hr_utility.trace('message is '||l_message_table(1).message_name);
		END IF;

		p_day_retrieve := FALSE;
		p_timecard_retrieve := FALSE;
		p_bb_skipped_reason	:= l_rsn_failed_lock;
	END IF;

	p_tc_first_lock := FALSE;

END IF;

ELSE
	-- we have not been able to lock this timecard

	p_day_retrieve := FALSE;
	p_timecard_retrieve := FALSE;
	p_bb_skipped_reason	:= l_rsn_locked;

END IF; -- ( p_tc_first_lock OR p_tc_locked )

/*
IF ( p_day_retrieve )
THEN
IF ( g_debug ) THEN
	hr_utility.trace('');
	hr_utility.trace('day retrieve is TRUE for resource '||to_char(p_resource_id));
	hr_utility.trace('day is '||to_char(p_bb_start_time, 'dd-mon-yyyy hh:mi:ss'));
	hr_utility.trace('');
END IF;
ELSE
IF ( g_debug ) THEN
	hr_utility.trace('');
	hr_utility.trace('day retrieve is FALSE for resource '||to_char(p_resource_id));
	hr_utility.trace('');
END IF;
END IF;

IF ( p_timecard_retrieve )
THEN
IF ( g_debug ) THEN
	hr_utility.trace('');
	hr_utility.trace('time retrieve is TRUE for resource '||to_char(p_resource_id));
	hr_utility.trace('');
END IF;
ELSE
IF ( g_debug ) THEN
	hr_utility.trace('');
	hr_utility.trace('time retrieve is FALSE for resource '||to_char(p_resource_id));
	hr_utility.trace('');
END IF;
END IF;
*/

-- Bug 6121705
-- If this is BEE retrieval process, you have to do an additional check to find
-- out if this record was transferred to BEE earlier while you are running
-- transfer to OTM now and vice versa.  After you decide to retrieve it,
-- check if this is BEE retreival process.
IF ((p_day_retrieve = TRUE) AND
          (p_process IN ( 'BEE Retrieval Process',
                          'Apply Schedule Rules' ) ) )
THEN
     -- Check if you need to make adjustment batches.
     IF ( chk_need_adj ( p_tc_bb_id,
                         p_tc_bb_ovn,
                         p_resource_id,
                         p_bb_start_time,
                         p_bb_id,
                         p_bb_ovn,  -- Bug 8366309
                         'N',       -- Bug 8366309 'N' is an UPDATE or NEW entry; DELETED = 'N'
                         hxc_generic_retrieval_pkg.g_retrieval_process_id ) )
     THEN
         -- If you need adjustments, log it down.
         IF(g_debug)
         THEN
            hr_utility.trace('Resource '||p_resource_id||
            ' had a different Rules evaluation preference earlier and needs adjustment this time');
         END IF;
     END IF;
END IF;


END chk_retrieve;

PROCEDURE set_parent_statuses IS

l_proc 	varchar2(72);

TYPE r_day_record IS RECORD ( ind BINARY_INTEGER );
TYPE t_day_table IS TABLE OF r_day_record INDEX BY BINARY_INTEGER;

l_day_table 	t_day_table;

l_day_parent	hxc_time_building_blocks.time_building_block_id%TYPE;

l_day_changed	BOOLEAN;
l_same_timecard BOOLEAN;

l_day_index	PLS_INTEGER;
l_detail_index	PLS_INTEGER;

l_last_day_index	PLS_INTEGER;
l_last_detail_index	PLS_INTEGER;

l_overall_status	hxc_transaction_details.status%TYPE;

BEGIN
g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'set_parent_statuses';
	hr_utility.set_location('Processing '||l_proc, 10);
END IF;

IF (   ( hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT <> 0 )
   AND ( hxc_generic_retrieval_pkg.t_tx_time_bb_id.COUNT <> 0 )
   AND ( hxc_generic_retrieval_pkg.t_tx_day_bb_id.COUNT <> 0 ) )
THEN

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 20);
END IF;

-- loop through timecard statuses

FOR time IN hxc_generic_retrieval_pkg.t_tx_time_bb_id.FIRST ..
            hxc_generic_retrieval_pkg.t_tx_time_bb_id.LAST
LOOP
	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 30);
	END IF;

	l_day_parent	:= hxc_generic_retrieval_pkg.t_tx_time_bb_id(time);
	l_day_changed	:= TRUE;

	-- loop through day statues

	l_day_index := NVL( l_last_day_index, hxc_generic_retrieval_pkg.t_tx_day_bb_id.FIRST );

	WHILE ( l_day_changed )
	LOOP
		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 40);
		END IF;

		-- store day index in day table indexed by day bb id

		l_day_table(hxc_generic_retrieval_pkg.t_tx_day_bb_id(l_day_index)).ind := l_day_index;

		l_day_index := hxc_generic_retrieval_pkg.t_tx_day_bb_id.NEXT(l_day_index);

		IF ( l_day_index IS NOT NULL )
		THEN
			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 50);
			END IF;

			IF ( hxc_generic_retrieval_pkg.t_tx_day_parent_id(l_day_index) <> l_day_parent )
			THEN
				IF ( g_debug ) THEN
					hr_utility.set_location('Processing '||l_proc, 60);
				END IF;

				l_day_changed := FALSE;
				l_last_day_index := l_day_index;
			END IF;
		ELSE
			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 70);
			END IF;

			l_day_changed := FALSE;
		END IF;

		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 80);
		END IF;

		IF NOT ( l_day_changed )
		THEN
			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 90);
			END IF;

			IF ( l_day_table.COUNT <> 0 )
			THEN
				IF ( g_debug ) THEN
					hr_utility.set_location('Processing '||l_proc, 100);
				END IF;

				-- get detail statuses

				l_same_timecard	:= TRUE;
				l_detail_index  := NVL( l_last_detail_index,
							hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST );
				l_overall_status:= 'IN PROGRESS';

				WHILE ( l_same_timecard )
				LOOP
					IF ( g_debug ) THEN
						hr_utility.set_location('Processing '||l_proc, 110);
					END IF;

					IF ( hxc_generic_retrieval_pkg.t_tx_detail_status(l_detail_index) = 'ERRORS' )
					THEN
						l_overall_status	:= 'ERRORS';

					ELSIF (hxc_generic_retrieval_pkg.t_tx_detail_status(l_detail_index) = 'SUCCESS'
					    AND l_overall_status <> 'ERRORS' )
					THEN
						l_overall_status	:= 'SUCCESS';
					END IF;

					IF ( g_debug ) THEN
						hr_utility.set_location('Processing '||l_proc, 120);
					END IF;

					IF NOT ( l_day_table.EXISTS( hxc_generic_retrieval_pkg.t_tx_detail_parent_id(l_detail_index) ) )
					THEN
						IF ( g_debug ) THEN
							hr_utility.set_location('Processing '||l_proc, 130);
						END IF;

						l_same_timecard := FALSE;
						l_last_detail_index := l_detail_index;
						hxc_generic_retrieval_pkg.t_tx_time_status(time) := l_overall_status;
						l_day_table.DELETE;
					ELSE
						IF ( g_debug ) THEN
							hr_utility.set_location('Processing '||l_proc, 140);
						END IF;


hxc_generic_retrieval_pkg.t_tx_day_status(l_day_table(hxc_generic_retrieval_pkg.t_tx_detail_parent_id(l_detail_index)).ind)
	:= hxc_generic_retrieval_pkg.t_tx_detail_status(l_detail_index);
					END IF;

					l_detail_index :=
						hxc_generic_retrieval_pkg.t_tx_detail_bb_id.NEXT(l_detail_index);

					IF ( l_detail_index IS NULL )
					THEN
						IF ( g_debug ) THEN
							hr_utility.set_location('Processing '||l_proc, 150);
						END IF;

						hxc_generic_retrieval_pkg.t_tx_time_status(time) := l_overall_status;
						l_same_timecard := FALSE;
					END IF;

				END LOOP; -- detail loop

			END IF; -- l_day_table.COUNT <> 0

		END IF; -- IF NOT ( l_day_changed )

	END LOOP; -- day loop

END LOOP; -- timecard loop


END IF; -- hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT <> 0 )

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 170);
END IF;

END set_parent_statuses;


PROCEDURE recovery ( p_process_id     NUMBER
		   , p_process        VARCHAR2 ) IS

PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR  csr_chk_for_in_progress ( p_conc_date DATE ) IS
SELECT  transaction_id
,	TRUNC(transaction_date) transaction_date
FROM    hxc_transactions tx
WHERE   tx.transaction_process_id = p_process_id
AND     tx.type = 'RETRIEVAL'
AND     tx.status = 'IN PROGRESS'
AND     tx.transaction_date < p_conc_date
FOR UPDATE OF status NOWAIT;

CURSOR  csr_chk_conc_request ( p_conc_program_name VARCHAR2
			,      p_app_id            NUMBER ) IS
SELECT  MIN(cr.actual_start_date)
FROM
	fnd_concurrent_programs cp
,	fnd_concurrent_requests cr
WHERE
	cp.concurrent_program_name = p_conc_program_name AND
	cp.application_id = p_app_id
AND
        cr.concurrent_program_id = cp.concurrent_program_id AND
        cr.status_code = 'R';

CURSOR  csr_get_appl_id ( p_appl_short_name VARCHAR2 ) IS
SELECT  a.application_id
FROM    fnd_application a
WHERE   a.application_short_name = p_appl_short_name;

TYPE r_date_record IS RECORD ( run_date DATE );
TYPE t_date_table  IS TABLE OF r_date_record INDEX BY BINARY_INTEGER;

l_tx_tab   t_date_table;

l_tx_rec csr_chk_for_in_progress%ROWTYPE;

l_req_date DATE;

l_index PLS_INTEGER;

l_cleaned_up BOOLEAN := FALSE;
l_locking_retrieval_ranges BOOLEAN := FALSE;
l_cnt NUMBER := 0;

l_proc 	varchar2(72);

l_appl_id fnd_application.application_id%TYPE;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'recovery';
	hr_utility.set_location('Processing '||l_proc, 10);

	hr_utility.trace('process id is '||to_char(p_process_id));
	hr_utility.trace('process is    '||p_process);
END IF;

WHILE NOT l_cleaned_up
LOOP

	BEGIN

	-- get the minimum process date for this process

	IF ( p_process = 'Projects Retrieval Process' )
	THEN

		OPEN  csr_get_appl_id ( 'PA' );
		FETCH csr_get_appl_id INTO l_appl_id;
		CLOSE csr_get_appl_id;

		OPEN  csr_chk_conc_request ( 'PAXTRTRX', l_appl_id );
		FETCH csr_chk_conc_request INTO l_req_date;
		CLOSE csr_chk_conc_request;

		IF ( g_debug ) THEN
			hr_utility.trace('Minimum Conc Date for PA is '||to_char(l_req_date,'DD-MON-YYYY HH24:MI:SS'));
		END IF;

	ELSIF ( p_process  in ( 'BEE Retrieval Process', 'Apply Schedule Rules') )
	THEN

		OPEN  csr_get_appl_id ( 'PER' );
		FETCH csr_get_appl_id INTO l_appl_id;
		CLOSE csr_get_appl_id;

		OPEN  csr_chk_conc_request ( 'PYTSHPRI', l_appl_id );
		FETCH csr_chk_conc_request INTO l_req_date;
		CLOSE csr_chk_conc_request;

		IF ( g_debug ) THEN
			hr_utility.trace('Minimum Conc Date for BEE is '||to_char(l_req_date,'DD-MON-YYYY HH24:MI:SS'));
		END IF;

	ELSIF ( p_process = 'Purchasing Retrieval Process' )
	THEN

		OPEN  csr_get_appl_id ( 'PO' );
		FETCH csr_get_appl_id INTO l_appl_id;
		CLOSE csr_get_appl_id;

		OPEN  csr_chk_conc_request ( 'RCVGHXT', l_appl_id );
		FETCH csr_chk_conc_request INTO l_req_date;
		CLOSE csr_chk_conc_request;

		IF ( g_debug ) THEN
			hr_utility.trace('Minimum Conc Date for PO is '||to_char(l_req_date,'DD-MON-YYYY HH24:MI:SS'));
		END IF;

	ELSIF ( p_process = 'Maintenance Retrieval Process' )
	THEN

		OPEN  csr_get_appl_id ( 'EAM' );
		FETCH csr_get_appl_id INTO l_appl_id;
		CLOSE csr_get_appl_id;

		OPEN  csr_chk_conc_request ( 'EAMTROTL', l_appl_id );
		FETCH csr_chk_conc_request INTO l_req_date;
		CLOSE csr_chk_conc_request;

		IF ( g_debug ) THEN
			hr_utility.trace('Minimum Conc Date for EAM is '||to_char(l_req_date,'DD-MON-YYYY HH24:MI:SS'));
		END IF;

	END IF;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 20);
	END IF;

	-- chk to see if there are any IN PROGRESS transactions for this retrieval process
	-- which were created before the minimum process date - these MUST be rogue
	-- transactions

	OPEN  csr_chk_for_in_progress ( l_req_date );
	FETCH csr_chk_for_in_progress INTO l_tx_rec;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 25);
	END IF;

	IF ( csr_chk_for_in_progress%FOUND )
	THEN
		-- if we know there are outstanding transactions then lock the retrieval
		-- range table now to ensure no other processes are accessing it

		IF ( g_debug ) THEN
			hr_utility.trace('Locking table');
		END IF;

		l_locking_retrieval_ranges := TRUE;

		LOCK TABLE hxc_retrieval_ranges IN EXCLUSIVE MODE NOWAIT;

	END IF;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 30);
	END IF;

	WHILE csr_chk_for_in_progress%FOUND
	LOOP

		IF ( g_debug ) THEN
			hr_utility.trace('tx id is   '||to_char(l_tx_rec.transaction_id));
			hr_utility.trace('tx date is '||to_char(l_tx_rec.transaction_date,'DD-MON-YYYY HH24:MI:SS'));
		END IF;

		l_tx_tab(l_tx_rec.transaction_id).run_date := l_tx_rec.transaction_date;

		FETCH csr_chk_for_in_progress INTO l_tx_rec;

	END LOOP;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 40);
	END IF;

	IF l_tx_tab.COUNT > 0
	THEN

		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 50);
		END IF;

		-- we have some rogue transactions - let's update them

		l_index := l_tx_tab.FIRST;

		WHILE l_index IS NOT NULL
		LOOP

			IF ( g_debug ) THEN
				hr_utility.trace('Updating tx id '||to_char(l_index));
			END IF;

			UPDATE	hxc_transactions tx
			SET	tx.status = 'RECOVERED'
			WHERE   tx.transaction_id = l_index;

			l_index := l_tx_tab.NEXT(l_index);

			-- unlock any outstanding TC locks

			hxc_lock_api.release_lock ( p_transaction_lock_id => l_index
						,   p_process_locker_type => hxc_generic_retrieval_pkg.g_lock_type
						,   p_row_lock_id         => NULL
						,   p_messages            => l_message_table
						,   p_released_success    => l_boolean );

		END LOOP;

--		COMMIT;

		IF ( g_debug ) THEN
			hr_utility.set_location('Processing '||l_proc, 60);
		END IF;


	END IF; -- l_tx_tab.COUNT > 0

	CLOSE csr_chk_for_in_progress;

	-- now check to see if there are any retrieval ranges which need to be
	-- cleared up (even if there were no IN PROGRESS transactions

	-- NOTE: removed lock table here since if there are orphaned ranges here
	--       without in progress transactions then the transactions must have
	--       been updated in SQL. 99.9% of the time the transaction will
	--       exist thus the table will be locked

	UPDATE	hxc_retrieval_ranges rr
	SET	rr.transaction_id = -999
	WHERE   rr.creation_date < l_req_date
	AND	rr.retrieval_process_id = p_process_id
	AND	rr.transaction_id = 0;

	COMMIT;

	l_cleaned_up := TRUE;

	EXCEPTION WHEN OTHERS
	THEN

		IF ( SQLCODE = '-54' )
		THEN
			IF ( g_debug ) THEN
				hr_utility.set_location('Processing '||l_proc, 70);
			END IF;

			IF ( l_locking_retrieval_ranges )
			THEN

				CLOSE csr_chk_for_in_progress;

				l_locking_retrieval_ranges := FALSE;

			END IF;

			l_cnt := l_cnt + 1;
		ELSE

			IF ( g_debug ) THEN
				hr_utility.trace('SQLERRM is '||SQLERRM);
			END IF;

			raise;
		END IF;

	END;

IF ( l_cnt > 10000 )
THEN

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','recovery cannot clean up');
    fnd_message.raise_error;

END IF;

END LOOP;

END recovery;

FUNCTION chk_terminated ( p_conc_request_id  NUMBER ) RETURN BOOLEAN IS

CURSOR csr_chk_terminated IS
SELECT cr.status_code
FROM   fnd_concurrent_requests cr
WHERE  cr.request_id = p_conc_request_id;

l_status_code fnd_concurrent_requests.status_code%TYPE;

BEGIN

OPEN  csr_chk_terminated;
FETCH csr_chk_terminated INTO l_status_code;
CLOSE csr_chk_terminated;

IF ( l_status_code <> 'R' )
THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END chk_terminated;

FUNCTION get_ret_criteria
RETURN VARCHAR2
IS
l_ret_criteria_clause VARCHAR2(1000) := null;


l_payroll_criteria VARCHAR2(200) := ' and paa.payroll_id = :p_payroll_id ';
l_location_criteria VARCHAR2(200) := ' and paa.location_id = :p_location_id ';
l_org_criteria VARCHAR2(200) := ' and paa.organization_id = :p_org_id ';

l_eff_date_criteria VARCHAR2(200) := '
                           and tbb_latest.start_time
                              between paa.effective_start_date and paa.effective_end_date )';

l_ret_criteria hxc_generic_retrieval_pkg.r_ret_criteria;
BEGIN

l_ret_criteria := hxc_generic_retrieval_pkg.g_ret_criteria;

	IF l_ret_criteria.gre_id is not null then
	l_ret_criteria_clause := ' AND exists (
			       select 1
				 from per_all_assignments_f paa, hr_soft_coding_keyflex hsk
				where paa.person_id = rrr.resource_id
				and paa.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
				and hsk.segment1 = :p_gre_id
			  ';
	else
	l_ret_criteria_clause := ' AND exists (
			       select 1
				 from per_all_assignments_f paa
				where paa.person_id = rrr.resource_id
			  ';
	END IF;

	IF l_ret_criteria.payroll_id is not null then
	 l_ret_criteria_clause := l_ret_criteria_clause ||l_payroll_criteria;
	END IF;

	IF l_ret_criteria.location_id is not null then
	 l_ret_criteria_clause := l_ret_criteria_clause ||l_location_criteria;
	END IF;

	IF l_ret_criteria.organization_id is not null then
	 l_ret_criteria_clause := l_ret_criteria_clause ||l_org_criteria;
	END IF;

	IF l_ret_criteria.payroll_id is null and
	   l_ret_criteria.location_id is  null and
	   l_ret_criteria.organization_id is null and
	   l_ret_criteria.gre_id is null
	then
	  l_ret_criteria_clause := null;
	else
	  l_ret_criteria_clause := l_ret_criteria_clause ||l_eff_date_criteria;
	END IF;

        RETURN l_ret_criteria_clause;

END get_ret_criteria;

-- Added this function for Absences Integration
-- OTL-Absences Integration (Bug 8779478)
FUNCTION absence_link_exists
   (p_element_type_id NUMBER)
RETURN BOOLEAN
IS

  l_exists NUMBER;

BEGIN

  SELECT count(*) INTO l_exists
    FROM hxc_absence_type_elements
   WHERE element_type_id = p_element_type_id
     AND rownum < 2;

  IF (l_exists = 0) THEN
      IF g_debug THEN
      	hr_utility.trace('Absence Element - False');
      END IF;

      RETURN FALSE;
  ELSE
      IF g_debug THEN
      	hr_utility.trace('Absence Element - True');
      END IF;

      RETURN TRUE;
  END IF;


END absence_link_exists;


end hxc_generic_retrieval_utils;

/
