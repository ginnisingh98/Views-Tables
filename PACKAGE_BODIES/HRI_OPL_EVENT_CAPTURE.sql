--------------------------------------------------------
--  DDL for Package Body HRI_OPL_EVENT_CAPTURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_EVENT_CAPTURE" AS
/* $Header: hrioetcp.pkb 120.9 2006/12/06 11:02:14 jtitmas noship $ */
--
-- ----------------------------------------------------------------------------
--
-- Overview
-- ========
-- This purpose of this package is to interogate the PEM architecture in a
-- single pass, to glean details of all the events that have occurred that are
-- relevant to various HRMSi DBI base collections.
--
-- A single record per assignment, is then stored in the appropriate event
-- queue table for a given collection, for each collection that is interested
-- in the event.
--
-- Example
-- ~~~~~~~
-- For example a supervisor change maybe of interest to the supervisor hierachy
-- collection process, the assignments events fact collection, and the
-- supervisor status history collection. In this case a row will be maintained
-- in each of the queue tables for these object's assignment change.
--
-- Maintaining the Event Queues
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Providing that there is no other change recorded for the assignment in the
-- queue already the earliest change for that assignment is simply
-- inserted into the qeueue. If there is a row in the queue that has an
-- earlier change date, then we will do nothing, otherwise if the change
-- pre-dates the record in the queue table, then we will update the record for
-- that assignment in the queue to set the change date to the earlier date.
--
-- Further Information
-- ===================
-- For details of the process flows in this package it is recomended that you
-- look at the detailed design using the following URL:
--
-- http://files.oraclecorp.com/content/AllPublic/Workspaces/
--      HRMS%20Intelligence%20(HRMSi)%20-%20Documents-Public/
--      Design%20Specifications/hri_lld_base_incremental_event_capture.doc
--
-- Process flow
-- ============
--
-- -----------------------------------------------------------------------------
-- Process flow
-- ============
--
-- BEFORE MULTI-THREADING
-- ----------------------
-- PRE_PROCESS
--   - Shared HR mode
--       - Call the bis process to insert a entry in the bis refresh log
--         for the process
--   - Full Refresh mode / Process Running for the first time
--       - Call the bis process to insert a entry in the bis refresh log
--         for the process
--   - When the event queue profiles are not set
--       - Call the bis process to insert a entry in the bis refresh log
--         for the process
--   - Incremental Mode
--       - Return the SQL based on which the range will be generated
--
-- PROCESS_RANGE
--       - Evaluate the events for every assignment in the range and
--         insert/update the records in the event queue
--
-- POST_PROCESS
--       - Call the bis process to insert a entry in the bis refresh log
--         for the process
--
-- -----------------------------------------------------------------------------
  --
  -- Start of global variable setup
  -- ----------------------------------------------------------------------------
  --
  --
  -- Global end of time date initialization from the package hr_general
  --
  g_end_of_time            DATE := hr_general.end_of_time;
  --
  -- Global DBI collection start date initialization
  --
  g_dbi_collection_start_date DATE := hri_bpl_parameter.get_bis_global_start_date;
  --
  -- Global flag which determines whether debugging is turned on
  --
  g_debug_flag             VARCHAR2(5) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
  --
  -- Global flag which determines whether archiving is turned on
  --
  --
  g_enable_archive_flag VARCHAR2(5);
  --
  -- Global Variable to store the profile value for HRI:Populate Assignment Events Queue
  --
  g_col_asg_events_eq VARCHAR2(5);
  --
  -- Global Variable to store the profile value for HRI:Populate Supervisor Hierarchy Events Queue
  --
  g_col_sup_hrchy_eq VARCHAR2(5);
  --
  -- Global Variable to store the profile value for HRI:Populate Supervisor Status History Events Queue
  --
  g_col_sup_hstry_eq VARCHAR2(5);
  --
  -- Global Variable to store the profile value for 'HRI:Absence Dimension Queue' Events Queue
  --
  g_col_absence_events_eq VARCHAR2(5);
  --
  -- 3716747 Global Variable to store the date track id of the period of service table
  --
  g_prd_of_srvc_table_id          NUMBER;
  g_appraisal_table_id            NUMBER;
  g_perf_review_table_id          NUMBER;
  g_asg_table_id                  NUMBER;
  g_person_type_table_id          NUMBER;
  g_absence_attendance_table_id   NUMBER;
  --
  -- Gloabl variable to store the NLS Date format
  --
  g_date_format          VARCHAR2(30);
  --
  -- Gloabl variable to store the Minimum date in Supervisor Hierarchy or
  -- the collection from date for the last full refresh
  --
  g_min_suph_date        DATE;
  --
  -- Global HRI Multithreading Array
  --
  g_mthd_action_array    HRI_ADM_MTHD_ACTIONS%rowtype;
  g_full_refresh         VARCHAR2(30);
  --
  -- End of global variable setup
  --
  -- -----------------------------------------------------------------------------
  --
  --
  -- Start of global constant setup
  --
  c_object_name            VARCHAR2(30) := 'HRI_OPL_EVENT_CAPTURE';
  c_ee_id                  NUMBER       := -1;
  --
-- End of global setting
--
PROCEDURE process_range(p_start_object_id   IN NUMBER
                       ,p_end_object_id     IN NUMBER ) ;
--
PROCEDURE Update_Asgn_Evnt_Fct_Evnt_Q
  (p_assignment_id IN NUMBER
  ,p_change_date   IN DATE -- The effective change date
  ,p_start_date    IN DATE -- The date the events were captured from
  );
--
-- ----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- ----------------------------------------------------------------------------
--
PROCEDURE msg(p_text  VARCHAR2) IS
  --
BEGIN
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END msg;
--
-- ----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- ----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
  --
BEGIN
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- 3716747 Get the date track table id for PER_PERIODS_OF_SERVICE
--
FUNCTION get_dated_table_id(p_table_name varchar2)
RETURN NUMBER
IS
  --
  CURSOR c_date_table_id (p_table_name varchar2) IS
  SELECT dated_table_id
  FROM   pay_dated_tables
  WHERE  table_name = p_table_name;
  --
  l_table_id      NUMBER;
  --
BEGIN
  --
  OPEN  c_date_table_id (p_table_name);
  FETCH c_date_table_id into l_table_id;
  CLOSE c_date_table_id;
  --
  RETURN l_table_id;
  --
END get_dated_table_id;
--
-- 3716747 This function will be called if the change is to column
-- PER_PERIODS_OF_SERVICES.DATE_START. This means that the latest hire
-- data has been changed. The output should be least of the old and
-- new date. In case there is a formating error the effective_date of
-- the transaction will be returned
--
FUNCTION get_least_date(p_change_values  IN VARCHAR2,
                        p_effective_date IN DATE)
RETURN DATE IS
  --
  CURSOR c_date_format_mast IS
  SELECT VALUE
  FROM   V$PARAMETER
  WHERE  NAME = 'nls_date_format';
  --
  l_old_value            DATE;
  l_new_value            DATE;
  l_length_to_grab       NUMBER;
  l_effective_date       DATE;
  --
BEGIN
  --
  IF g_date_format is null THEN
    --
    OPEN  c_date_format_mast;
    FETCH c_date_format_mast into g_date_format;
    CLOSE c_date_format_mast;
    --
  END IF;
  --
  -- The change_value column contains data in this format
  -- 01-jan-03 -> 01-jan-03
  -- compare the two dates and return the least
  --
  l_length_to_grab := (length(p_change_values) - 4)/2;
  --
  l_old_value := to_date(substr(p_change_values,0,l_length_to_grab),g_date_format);
  --
  l_new_value := to_date(substr(p_change_values,l_length_to_grab+4),g_date_format);
  --
  l_effective_date := least(l_old_value, l_new_value);
  --
  RETURN l_effective_date;
  --
EXCEPTION
  --
  -- In case an error is raised in formating the date, do not raise an error
  -- return the effective date on PEM record
  --
  WHEN others THEN
    --
    dbg('Exception Raised in determine change in latest hire date');
    dbg(sqlerrm);
    l_effective_date := p_effective_date;
    --
    RETURN l_effective_date;
    --
END get_least_date;
--
--
-- Populate snapshot fact EQs with any new snapshot dates
--
PROCEDURE check_for_new_snapshot_dates IS

  l_implement_obiee        VARCHAR2(30);
  l_implement_obiee_orgh   VARCHAR2(30);
  l_implement_obiee_mgrh   VARCHAR2(30);

BEGIN

  -- Set OBIEE parameters
  IF (fnd_profile.value('HRI_IMPL_OBIEE') = 'Y') THEN
    l_implement_obiee      := 'Y';
    IF (fnd_profile.value('HRI_COL_SUP_HRCHY_EQ') = 'Y') THEN
      l_implement_obiee_mgrh := 'Y';
    ELSE
      l_implement_obiee_mgrh := 'N';
    END IF;
    IF (fnd_profile.value('HRI_COL_ORG_HRCHY_EQ') = 'Y') THEN
      l_implement_obiee_orgh := 'Y';
    ELSE
      l_implement_obiee_orgh := 'N';
    END IF;
  ELSE
    l_implement_obiee      := 'N';
    l_implement_obiee_mgrh := 'N';
    l_implement_obiee_orgh := 'N';
  END IF;

  -- If OBIEE is implemented, check OBIEE facts
  IF l_implement_obiee = 'Y' THEN

    -- If a new month is reached since the last collection run
    -- then update event queues
    IF (trunc(g_capture_from_date,'MONTH') < trunc(sysdate, 'MONTH')) THEN

      dbg('Found new month for OBIEE summaries');

      EXECUTE IMMEDIATE 'alter session enable parallel dml';

      commit;

      -- Insert new snapshots into workforce events fact EQ
      -- add assignments active between last refresh date and current month end
      INSERT /*+ APPEND PARALLEL */ INTO hri_eq_wrkfc_mnth
       (assignment_id
       ,erlst_evnt_effective_date)
      SELECT DISTINCT
       asg_assgnmnt_fk
      ,add_months(trunc(g_capture_from_date,'MONTH'), 1)
      FROM
       hri_mb_wrkfc_evt_ct
      WHERE g_capture_from_date <= time_day_evt_end_fk
      AND add_months(trunc(sysdate,'MONTH'), 1) > time_day_evt_fk
      AND term_or_end_ind = 0;

      commit;

      -- Check manager hierarchy implemented
      IF l_implement_obiee_mgrh = 'Y' THEN

        -- Insert new snapshots into workforce manager summary EQ
        -- Add managers active between last refresh date and current month end
        INSERT /*+ APPEND PARALLEL */ INTO hri_eq_wrkfc_evt_mgrh
         (sup_person_id
         ,erlst_evnt_effective_date
         ,source_code)
        SELECT DISTINCT
         mgrs_person_fk
        ,add_months(trunc(g_capture_from_date,'MONTH'), 1)
        ,'NEW_SNAP_DATE'
        FROM
         hri_cs_mngrsc_ct
        WHERE g_capture_from_date <= mgrs_date_end
        AND add_months(trunc(sysdate,'MONTH'), 1) > mgrs_date_start;

        commit;

      END IF;

      -- Check organization hierarchy implemented
      IF l_implement_obiee_orgh = 'Y' THEN

        -- Insert new snapshots into workforce organization summary
        -- Add one record per hierarchy node
        INSERT /*+ APPEND PARALLEL */ INTO hri_eq_wrkfc_evt_orgh
         (organization_id
         ,erlst_evnt_effective_date)
        SELECT
         orgh_sup_organztn_fk
        ,add_months(trunc(g_capture_from_date,'MONTH'), 1)
        FROM
         hri_cs_orgh_ct
        WHERE orgh_relative_level = 0;

        commit;

      END IF;

    END IF;

  END IF;

END check_for_new_snapshot_dates;
--
--
--
FUNCTION get_min_suph_date
RETURN DATE
IS
  --
  l_min_suph_date    DATE;
  --
  CURSOR c_last_full_suph_col_run IS
  SELECT period_from
  FROM   bis_refresh_log
  WHERE  object_name = 'HRI_CS_SUPH'
  AND    status='SUCCESS'
  AND    attribute1 = 'Y'
  AND    last_update_date =( SELECT max(last_update_date)
                             FROM   bis_refresh_log
                             WHERE  object_name= 'HRI_CS_SUPH'
                             AND    status='SUCCESS'
                             AND    attribute1 = 'Y')
  ORDER BY last_update_date DESC;
  --
  CURSOR c_min_suph_date IS
  SELECT min(effective_start_date)
  FROM   hri_cs_suph;
  --
BEGIN
  --
  -- 3906029 The event date to be populated in the supervisor hierarchy
  -- events queue should not be lesser than the last full refresh date
  -- or the minimum date in the hierarchy
  --
  OPEN   c_last_full_suph_col_run;
  FETCH  c_last_full_suph_col_run INTO l_min_suph_date;
  CLOSE  c_last_full_suph_col_run ;
  --
  dbg('last collection date='|| l_min_suph_date );
  --
  -- In case the collection start date for last full refresh could not
  -- be found from bis_refresh table, get the data from supervisor hierarchy
  -- table.
  --
  IF g_min_suph_date is null THEN
    --
    OPEN   c_min_suph_date;
    FETCH  c_min_suph_date INTO l_min_suph_date;
    CLOSE  c_min_suph_date;
    --
  END IF;
  --
  RETURN NVL(l_min_suph_date,g_dbi_collection_start_date);
  --
END get_min_suph_date;
--
-- ----------------------------------------------------------------------------
-- 3829100 When an event occurs due to changes to PER_PERSON_TYPE_USAGES
-- the events can is useful to DBI only if the change is made to a record with
-- EMP on CWK system person type, otherwise the event is of no use for DBI
-- ----------------------------------------------------------------------------
--
FUNCTION valid_for_dbi_ptu_rec(p_person_type_usage_id   NUMBER
                              ,p_effective_date         DATE)
RETURN BOOLEAN
IS
  --
  CURSOR c_ptu IS
  SELECT 1
  FROM   per_person_type_usages_f ptu,
         per_person_types ppt
  WHERE  1=1
  AND    ptu.person_type_usage_id = p_person_type_usage_id
  AND    p_effective_date BETWEEN ptu.effective_start_date and ptu.effective_end_date
  AND    ptu.person_type_id = ppt.person_type_id
  AND    ppt.system_person_type in ('EMP','CWK');
  --
  l_dummy         NUMBER;
  --
BEGIN
  --
  -- Open the cursor to determine if the change has been made to a EMP or CWK
  --
  OPEN  c_ptu;
  FETCH c_ptu INTO l_dummy;
  CLOSE c_ptu;
  --
  IF l_dummy = 1 THEN
    --
    -- Change made to EMP or CWK person type so return true
    --
    dbg('emp asg change so return true');
    RETURN TRUE;
    --
  ELSE
    --
    -- Change not made to EMP or CWK person type so return false
    --
    dbg('not a emp asg change so return false');
    RETURN FALSE;
    --
  END IF;
  --
END valid_for_dbi_ptu_rec;
--
-- ----------------------------------------------------------------------------
-- 4469175 The function is invoked when the projected end date is changed or when there
-- is a change in primary asg for a person. The function re-evaluates the extension start
-- date and returns the value. Additionally the function also creates event records for
-- other assignment records for the person to ensure that the extension date is
-- correctly set
-- ----------------------------------------------------------------------------
--
FUNCTION get_extnsn_strt_dt(
                    p_assignment_id  IN NUMBER,
                    p_effective_date IN DATE)
RETURN DATE IS
  --
  l_person_id             NUMBER;
  l_extnsn_strt_dt        DATE;
  --
  -- Cursor to get the earlierst extn date from asg events.
  -- Note: extension starts one day after the projected assignment end specified
  -- in the assignment record
  --
  -- Bug 4533293 - return event date (using NVL) if no projected end date exists in
  --               per_all_assignments_f but does exist in hri_mb_asgn_events_ct
  --
  CURSOR c_extsn_strt_dt IS
  SELECT asgn.person_id, NVL(min(asgn.projected_assignment_end) + 1, p_effective_date)
  FROM   per_all_assignments_f asgn
  WHERE  primary_flag = 'Y'
  --
  -- For people with multiple placement (rehire), the extsn date specified during
  -- a particular term should only be considered for evaluating the extsn date
  --
  AND    (person_id,period_of_placement_date_start)  =
                     ( SELECT asgn.person_id , asgn.period_of_placement_date_start
                       FROM   per_all_assignments_f asgn
                       WHERE  asgn.assignment_id = p_assignment_id
                       AND    rownum = 1)
  GROUP BY asgn.person_id
  --
  -- The cursor should only return a record is the extension date in asg event
  -- is not equal to the min date in the asg table
  -- Bug 4533293 - changed subquery to use NVLs so that cursor will return a
  --               record in the null case i.e. no previous extension existed
  --               or previous extension removed
  --
  HAVING   NVL(min(asgn.projected_assignment_end), g_end_of_time) <>
   (SELECT NVL(MIN(asg.pow_extn_strt_dt) - 1, g_end_of_time)
    FROM   hri_mb_asgn_events_ct asg
    WHERE  asg.assignment_id = p_assignment_id);
  --
  CURSOR c_othr_prmry_asg IS
  SELECT assignment_id,
         least(min(asgn.effective_change_date),l_extnsn_strt_dt) change_date
  FROM   hri_mb_asgn_events_ct asgn
  WHERE  asgn.person_id  = l_person_id
  AND    pow_extn_strt_dt is not null
  AND    asgn.pow_extn_strt_dt   <> l_extnsn_strt_dt
  AND    assignment_id <> p_assignment_id
  GROUP BY asgn.assignment_id;
  --
BEGIN
  --
  dbg('Inside get_least_projected_end_date');
  --
  OPEN  c_extsn_strt_dt;
  FETCH c_extsn_strt_dt INTO l_person_id,l_extnsn_strt_dt;
  CLOSE c_extsn_strt_dt;
  --
  -- The event should be generated for all assignment for the person as it is
  -- likely that asg event records for the person have some incorrect data
  --
  IF l_extnsn_strt_dt is not null THEN
    --
    FOR l_asg IN c_othr_prmry_asg LOOP
      --
      dbg('creating event for asg = '|| l_asg.assignment_id||
          ' as the extnsn date is changed to'||l_extnsn_strt_dt);
      --
      Update_Asgn_Evnt_Fct_Evnt_Q
          (p_assignment_id => l_asg.assignment_id
          ,p_change_date   => l_asg.change_date
          ,p_start_date    => l_asg.change_date
          );
      --
    END LOOP;
    --
  END IF;
  --
  dbg('the extension start date is '||l_extnsn_strt_dt);
  --
  RETURN l_extnsn_strt_dt;
  --
EXCEPTION
  --
  -- In case an error is raised in formating the date, do not raise an error
  -- return the effective date on PEM record
  --
  WHEN others THEN
    --
    dbg('Exception Raised in get_least_projected_end_date');
    dbg(sqlerrm);
    --
    RETURN p_effective_date;
    --
END get_extnsn_strt_dt;
--
-- 3906029, In case of termination events for the supervisor hierarchy
-- the date retunred should not be PRE_PERIODS_OF_SERVICE.DATE_START. It should
-- be termination_date + 1. This will prevent the hierarchy from recollecting
-- the hierarchy from start date for the person. However, in case of rehire
-- the effective date should be PRE_PERIODS_OF_SERVICE.DATE_START
--
--
FUNCTION get_changed_termination_date(p_change_values  IN VARCHAR2,
                                      p_effective_date IN DATE)
RETURN DATE IS
  --
  CURSOR c_date_format_mast IS
  SELECT VALUE
  FROM   V$PARAMETER
  WHERE  NAME = 'nls_date_format';
  --
  l_old_value            DATE;
  l_new_value            DATE;
  l_length_to_grab       NUMBER;
  l_effective_date       DATE;
  --
BEGIN
  --
  IF g_date_format is null THEN
    --
    OPEN  c_date_format_mast;
    FETCH c_date_format_mast into g_date_format;
    CLOSE c_date_format_mast;
    --
  END IF;
  --
  -- The following changes can be done to actual termination and final
  -- process date columns
  --   A date can be assigned which means that the person is terminated
  --   The date can be changed
  --   In case of rehire the date will be removed.
  -- Based of these the change_value column can contains data in the
  -- following formats
  --   01-jan-03 -> 01-jan-04    Change is termination date
  --   <null> -> 11-OCT-04       Termination
  --   31-OCT-04 -> <null>       Rehire
  -- Find out the exact format and pass out the values
  --
  IF instr(p_change_values,'<null>') = 0 THEN
    --
    -- The format is 01-jan-03 -> 01-jan-04
    -- So the person's termination date has changed
    --
    l_length_to_grab := (length(p_change_values) - 4)/2;
    --
    l_old_value := to_date(substr(p_change_values,0,l_length_to_grab),g_date_format);
    --
    l_new_value := to_date(substr(p_change_values,l_length_to_grab+4),g_date_format);
    --
    l_effective_date := least(l_old_value, l_new_value);
    --
  ELSIF instr(p_change_values,'<null>') = 1 THEN
    --
    -- The format is <null> -> 11-OCT-04
    -- So the person has been terminated
    -- A person termination one day after the end date of the record, so add 1
    l_effective_date := to_date(substr(p_change_values,11),g_date_format) + 1;
    --
  ELSE
    --
    -- The format is 31-OCT-04 -> <null>
    -- So the person has been rehired, create the event as of the
    -- effective date
    --
    l_effective_date := p_effective_date;
    --
  END IF;
  --
  dbg('the termination event date is '||l_effective_date);
  RETURN l_effective_date;
  --
EXCEPTION
  --
  -- In case an error is raised in formating the date, do not raise an error
  -- return the effective date on PEM record
  --
  WHEN others THEN
    --
    dbg('Exception Raised in determine termination date, returning effective date');
    dbg(sqlerrm);
    l_effective_date := p_effective_date;
    --
    RETURN l_effective_date;
    --
END get_changed_termination_date;
--
-- ----------------------------------------------------------------------------
-- The function evaluates the dates for all one off cases, and adjust the
-- effective date so that the event is created on a correct date
-- ----------------------------------------------------------------------------
--
FUNCTION eval_one_off_cases
          (p_sub_evt_grp_tbl   pay_interpreter_pkg.t_detailed_output_tab_rec
          ,p_assignment_id     NUMBER
          ,p_comment_text      VARCHAR2
          ,p_effective_date    DATE)
RETURN DATE IS
  --
  l_effective_date  DATE := p_effective_date;
  l_extns_date      DATE;
  --
BEGIN
  --
  -- 3716747
  -- If a person's latest hire date is changed to a future date,
  -- e.g. from 01-jan-2004 to 15-Jan-2004, the effective date of the transaction
  -- return by PEM is 15-Jan-2004. It's likely that the person's data in
  -- base collection table start from the old hire date (01-jan-2004). If the
  -- event created due to change in latest hire date is created on 15-jan-2004
  -- the data in base table will not be correct and this will result is errors
  -- on DBI pages. Therefore, if the event has been caused due to change in person's
  -- hire date PRE_PERIODS_OF_SERVICE.DATE_START then event date should be set the least
  -- of the old-new hire dates i.e. 01-jan-2004 in this case. This will ensure that old
  -- data for the assignment is delete by the collection processes.
  -- 3952026, extended the case to change in effective date of other non datetrack tables
  -- per_appraisals and per_periods_of_service
  -- 3170971, extending the case to per_all_assignments_f, In case of cancel hire of an
  -- applicant, the previously end dated applicant asg record is end dated to end of
  -- time from current date and the asg record is deleted. However PEM will detect only
  -- the update of effective_end_date column
  --
  IF (g_prd_of_srvc_table_id = p_sub_evt_grp_tbl.dated_table_id
      AND p_sub_evt_grp_tbl.column_name = 'DATE_START')
     OR ( g_appraisal_table_id = p_sub_evt_grp_tbl.dated_table_id
      AND p_sub_evt_grp_tbl.column_name = 'APPRAISAL_DATE' )
     OR ( g_perf_review_table_id = p_sub_evt_grp_tbl.dated_table_id
      AND p_sub_evt_grp_tbl.column_name = 'REVIEW_DATE' )
     OR ( g_asg_table_id = p_sub_evt_grp_tbl.dated_table_id
      AND p_sub_evt_grp_tbl.column_name = 'EFFECTIVE_END_DATE' )
  THEN
    --
    dbg('change detected in column '||p_sub_evt_grp_tbl.column_name ||' of table_id '||g_prd_of_srvc_table_id);
    dbg('p_sub_evt_grp_tbl.change_values = '||p_sub_evt_grp_tbl.change_values);
    --
    l_effective_date := get_least_date(
           p_change_values  => p_sub_evt_grp_tbl.change_values,
           p_effective_date => p_sub_evt_grp_tbl.effective_date);
    --
  --
  -- Extension Start Date
  -- 4469175 When the projected end date of the record is changed the event should
  -- be created on the minimum of all projected end dates + 1 stored in the
  -- primary asg records of the person. If the new date is not less than the
  -- date in the system, a new event should be created for all other asg for the
  -- person
  --
  ELSIF   ( g_asg_table_id = p_sub_evt_grp_tbl.dated_table_id AND
      p_comment_text <> 'Supervisor' AND
      p_sub_evt_grp_tbl.column_name = 'PROJECTED_ASSIGNMENT_END' )
  THEN
    --
    dbg('In period of extension change calculation');
    --
    l_effective_date := get_extnsn_strt_dt(
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_sub_evt_grp_tbl.effective_date);
    --
  --
  -- 4469175
  -- Change of primary assignment and extension calculation
  -- In case the primary assignment for a record is changed the event date should
  -- set as least of
  -- A. Effective change date
  -- B. The extension date for the person if it has been reset due to the change in
  --    primary assignment
  --
  ELSIF  ( g_asg_table_id = p_sub_evt_grp_tbl.dated_table_id AND
     p_comment_text <> 'Supervisor' AND
     p_sub_evt_grp_tbl.column_name = 'PRIMARY_FLAG' )
  THEN
    --
    dbg('In change of primary assignment calculation');
    --
    l_extns_date := get_extnsn_strt_dt(
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_sub_evt_grp_tbl.effective_date);
    --
    l_effective_date := least(l_extns_date,p_sub_evt_grp_tbl.effective_date);
    --
  ELSIF g_person_type_table_id = p_sub_evt_grp_tbl.dated_table_id THEN
    --
    -- 3829100 If event is due to change to PER_PERSON_TYPE_USAGE_F, the event
    -- affect DBI only when the change is made to PTU record with EMP, CWK
    -- person type. The queues should be populated for such events
    --
    dbg('inside ptu check');
    IF valid_for_dbi_ptu_rec(p_sub_evt_grp_tbl.surrogate_key,
           p_sub_evt_grp_tbl.effective_date)
    THEN
      --
      -- in case the the change is to EFFECTIVE_END_DATE column then
      -- the effective_date should be set to least of the prev and current dates
      --
      IF p_sub_evt_grp_tbl.column_name = 'EFFECTIVE_END_DATE' THEN
        --
        l_effective_date := get_least_date(
	      p_change_values  => p_sub_evt_grp_tbl.change_values,
              p_effective_date => p_sub_evt_grp_tbl.effective_date);
        --
      END IF;
      --
    ELSE
      --
      l_effective_date := null;
      --
    END IF;
    --
  ELSIF p_comment_text = 'Supervisor'
    AND g_prd_of_srvc_table_id = p_sub_evt_grp_tbl.dated_table_id
    AND p_sub_evt_grp_tbl.column_name in ('ACTUAL_TERMINATION_DATE','FINAL_PROCESS_DATE' )
  THEN
    --
    -- 3906029, In case of termination events for the supervisor hierarchy
    -- the min date should not be PRE_PERIODS_OF_SERVICE.DATE_START. It should
    -- be termination_date + 1. This will prevent the hierarchy from recollecting
    -- the hierarchy from start date for the person. However, in case of rehire
    -- the effective date should be PRE_PERIODS_OF_SERVICE.DATE_START
    --
    l_effective_date := get_changed_termination_date(
           p_change_values  => p_sub_evt_grp_tbl.change_values,
           p_effective_date => p_sub_evt_grp_tbl.effective_date);
    dbg('termination date = '||l_effective_date);
    --
  END IF;
  --
  dbg('effective date = '||l_effective_date);
  --
  RETURN l_effective_date;
  --
END eval_one_off_cases;
--
-- ----------------------------------------------------------------------------
-- empty_evnts_cptr_refresh_log
-- Empty events Capture Refresh Log.
-- ============================================================================
-- This procedure truncates the BIS log information, for the events capture
-- process. This is useful for testing purposes, so that we can re-run tests
-- over given date ranges.
--
-- The logic in this procedure DOES NOT form part of the normal incremental
-- events capture process.
--
PROCEDURE empty_evnts_cptr_refresh_log
IS
  --
BEGIN
  --
  hri_bpl_conc_log.delete_process_log(c_object_name);
  --
END empty_evnts_cptr_refresh_log;
--
-- ----------------------------------------------------------------------------
-- truncate_table
-- The following procedure truncates the passed in table.
-- ============================================================================
--
PROCEDURE truncate_table(p_table_name VARCHAR2)
IS
  --
  l_sql_stmt   VARCHAR2(200);
  l_dummy1     VARCHAR2(1);
  l_dummy2     VARCHAR2(1);
  l_schema     VARCHAR2(50);
  --
BEGIN
  --
  IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)
  THEN
    --
    RAISE schema_name_not_set;
    --
  END IF;
  --
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.' || p_table_name;
  --
  dbg(l_sql_stmt);
  --
  EXECUTE IMMEDIATE(l_sql_stmt);
  --
  COMMIT;
  --
  dbg('Truncated table: '||p_table_name);
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('An error occurred while truncating table '||p_table_name);
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
            ,p_msg_type      => 'ERROR'
            ,p_note          => SQLERRM
            ,p_msg_group     => 'EVT_CPTR'
            ,p_msg_sub_group => 'TRUNCATE_TABLE'
            ,p_sql_err_code  => SQLCODE);
    --
    RAISE;
    --
  --
END truncate_table;
--
-- ----------------------------------------------------------------------------
-- purge_queue
-- The following procedure purges the passed in queue table.
-- ============================================================================
--
PROCEDURE purge_queue(p_queue_table_name VARCHAR2)
IS
BEGIN
  --
  truncate_table(p_queue_table_name);
  --
END purge_queue;
--
-- ----------------------------------------------------------------------------
-- Full Refresh
-- ============================================================================
-- This procedure does very little, other than to set the date that the events
-- capture process, needs to run from, subsequent to the full refresh.
-- The process also purges the event queues,as the data will no longer be
-- required after a full refresh.
--
PROCEDURE full_refresh (p_refresh_to_date IN DATE DEFAULT NULL)
IS
  --
  -- Date to set fo full refresh end date.
  --
  l_refresh_to_date DATE;
  --
BEGIN
  --
  -- Record that the full refresh process has started.
  --
  hri_bpl_conc_log.record_process_start(c_object_name);
  --
  -- Set the date that the full refresh is refreshed to. Normally this will be
  -- trunc SYSDATE, but for testing purposes, we may sometimes wish to set an
  -- earlier date.
  --
  IF p_refresh_to_date IS NULL
  THEN
    --
    dbg('Setting refresh date to TRUNC(SYSDATE).');
    --
    l_refresh_to_date := SYSDATE;
    --
  --
  -- This logic path will only ever be used for testing. It will allow
  -- full refresh to be run up to a specified date.
  --
  ELSE
    --
    dbg('Setting refresh date to p_refresh_to_date.');
    --
    l_refresh_to_date := p_refresh_to_date;
    --
    -- Purge the dbi collection log, so that we do not have any more recent
    -- processes in the log.
    --
    empty_evnts_cptr_refresh_log;
    --
  END IF;
  --
  dbg('l_refresh_to_date: '||TO_CHAR(l_refresh_to_date));
  --
  -- Empty the Event Queues
  --
  -- Truncate archive table
  truncate_table('HRI_ARCHIVE_EVENTS');
  -- Purge supervisor hierarchy queue
  purge_queue('HRI_EQ_SPRVSR_HRCHY_CHGS');
  -- Purge supervisor history queue
  purge_queue('HRI_EQ_SPRVSR_HSTRY_CHGS');
  -- Purge assignment events queue
  purge_queue('HRI_EQ_ASGN_EVNTS');
  -- Purge absence events queue
  purge_queue('HRI_EQ_UTL_ABSNC_DIM');
  --
  -- Record the full refresh process has ended. This is the main purpose of
  -- full refresh, as these dates will then be used to drive the dates that
  -- the events capture process is then run for.
  --
  --
  commit;
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => g_dbi_collection_start_date
          ,p_period_to      => l_refresh_to_date);
  --
  commit;
  --
END full_refresh;
--
-- ----------------------------------------------------------------------------
-- get_business_group_id
-- Gets the Business group ID for a given assignment_id
-- ============================================================================
--
FUNCTION get_business_group_id(p_assignment_id IN VARCHAR2)
RETURN NUMBER IS
  --
  CURSOR c_business_group(p_assignment_id IN VARCHAR2) IS
    SELECT          business_group_id
    FROM            per_all_assignments_f
    WHERE           assignment_id = p_assignment_id;
  --
  l_business_group_id NUMBER;
  --
BEGIN
  --
  -- Get the event group id
  --
  OPEN c_business_group(p_assignment_id);
  FETCH c_business_group INTO l_business_group_id;
  IF c_business_group%NOTFOUND
  THEN
    --
    -- 3710454 There are certain cases when the business_group_id will not
    -- be available eg. when the assignment is deleted. In such a case
    -- exception should not be raised but the interpreter should be called without
    -- with out the business_group parameter
    --
    dbg('Business Group for assignment "'||p_assignment_id||'" not found.');
    --
  END IF;
  --
  CLOSE c_business_group;
  --
  RETURN l_business_group_id;
  --
END get_business_group_id;
--
-- ----------------------------------------------------------------------------
-- get_event_group_id
-- Gets the event group ID based on its name.
-- ============================================================================
--
FUNCTION get_event_group_id(p_event_group_name IN VARCHAR2)
RETURN NUMBER IS
  --
  CURSOR get_evt(p_grp IN VARCHAR2) IS
    SELECT          event_group_id
    FROM            pay_event_groups
    WHERE           event_group_name = p_grp;
  --
  l_event_group_id NUMBER;
  --
BEGIN
  --
  dbg('Getting Event Group Id for '||p_event_group_name||' event group.');
  --
  -- Get the event group id
  --
  OPEN get_evt(p_event_group_name);
  FETCH get_evt INTO l_event_group_id;
  IF get_evt%NOTFOUND
  THEN
    --
    -- Trace some debug info and raise the error
    --
    dbg('Event group "'||p_event_group_name||'" not found.');
    --
    CLOSE get_evt;
    RAISE event_group_not_found;
    --
  END IF;
  --
  CLOSE get_evt;
  --
  dbg('Getting Event Group Id is '||l_event_group_id||'.');
  --
  RETURN l_event_group_id;
  --
END get_event_group_id;
--
-- ----------------------------------------------------------------------------
-- 5.1.1 (interpret_all_asgnmnt_changes)
-- Get All Assignment Changes For The Master Event Group
-- ============================================================================
-- This procedure calls PEM interpreter package to populate a PLSQL table of
-- all of the events that have occurred for assignments, where the event exists
-- in the master event group. The master event group is an event group that
-- contains all of the events contained in all of the sub event groups.
-- The sub event groups contain only those events that relate to a given
-- collection e.g. the supervisor hierarchy collection.
--
-- The concept of master event groups and sub event groups does not actually
-- exist in PEM, so we need to make sure when we seed the sub event groups or
-- change them, that the master event groups are also maintained.
--
PROCEDURE interpret_all_asgnmnt_changes
  (
   p_assignment_id IN NUMBER
  ,p_start_date IN DATE
  ,p_master_events_table
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type
  )
IS
  --
  -- The following 3 PLSQL tables are required as return placeholders for
  -- the procedure pay_interpreter_pkg.entry_affected. The results from
  -- these tables is CURRENTLY IGNORED.
  --
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
  l_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
  --
  -- The business group id of the assignent
  --
  l_business_group_id    NUMBER;
  --
BEGIN
  --
  dbg('Executing interpret_all_asgnmnt_changes ....');
  --
  -- Get the business group id for the assignment (p_assignment_id)
  -- this is not strictly necessary, but improves the performance
  -- of pay_interpreter_pkg.entry_affected
  --
  l_business_group_id := get_business_group_id(p_assignment_id);
  --
  -- Call the Payroll Events Model (PEM) interpreter to identify all
  -- of the events that have occurred for the assignment since p_start_date,
  -- in the master event group.
  --
  dbg('c_ee_id: '||c_ee_id);
  dbg('p_assignment_id: '||p_assignment_id);
  dbg('g_master_event_group_id: '||g_master_event_group_id);
  dbg('p_start_date: '||p_start_date);
  dbg('g_end_of_time: '||g_end_of_time);
  dbg('l_business_group_id: '||l_business_group_id);
  --
  IF l_business_group_id is not null THEN
    --
    pay_interpreter_pkg.entry_affected(
      p_element_entry_id      => c_ee_id
     ,p_assignment_action_id  => NULL
     ,p_assignment_id         => p_assignment_id
     ,p_mode                  => NULL -- pickup events of all types including
                                      -- 'REPORTS' and 'DATE_PROCESSED'
     ,p_process               => NULL
     ,p_event_group_id        => g_master_event_group_id
     ,p_process_mode          => 'ENTRY_CREATION_DATE'-- means I am
                                                      -- interested in
                                                      -- events created
     ,p_start_date            => p_start_date          -- between here
     ,p_end_date              => g_end_of_time            -- and here
     ,p_unique_sort           => 'N' -- tells the interpreter not to do a
                                     -- unique sort, and this improves
                                     -- performance.
     ,p_business_group_id     => l_business_group_id
     ,t_detailed_output       => p_master_events_table  --OUTPUT OF RESULTS
     ,t_proration_dates       => l_proration_dates      --IGNORED
     ,t_proration_change_type => l_proration_changes    --IGNORED
     ,t_proration_type        => l_pro_type_tab);       --IGNORED
    --
  ELSE
    --
    -- 3710454 As business_group_id is not found for the assignment, call the
    -- interpreter version which does not take the business group parameters.
    -- Note: This version is inefficient, but we don't want to miss any events
    -- which has happened to an assignment
    --
    pay_interpreter_pkg.entry_affected(
      p_element_entry_id      => c_ee_id
     ,p_assignment_action_id  => NULL
     ,p_assignment_id         => p_assignment_id
     ,p_mode                  => NULL
     ,p_process               => NULL
     ,p_event_group_id        => g_master_event_group_id
     ,p_process_mode          => 'ENTRY_CREATION_DATE'
     ,p_start_date            => p_start_date           -- Events from
     ,p_end_date              => g_end_of_time          -- till here
     ,t_detailed_output       => p_master_events_table  -- OUTPUT OF RESULTS
     ,t_proration_dates       => l_proration_dates      -- IGNORED
     ,t_proration_change_type => l_proration_changes    -- IGNORED
     ,t_proration_type        => l_pro_type_tab);       -- IGNORED
    --
  END IF;
  --
  dbg('Rows Returned: '||TO_CHAR(p_master_events_table.COUNT));
  --
  -- Loop through rows returned by the interpreter for dubug
  -- purposes only.
  --
  -- ONLY if debugging is on output log information
  --
  IF g_debug_flag = 'Y' THEN
    --
    FOR i in 1..p_master_events_table.COUNT
    LOOP
      --
      dbg(' dated_table_id: '||TO_CHAR(p_master_events_table(i).dated_table_id)
        ||', datetracked_event: '||p_master_events_table(i).datetracked_event
        ||', update_type: '||p_master_events_table(i).update_type
        ||', surrogate_key: '||TO_CHAR(p_master_events_table(i).surrogate_key)
        ||', column_name: '||TO_CHAR(p_master_events_table(i).column_name)
        ||', Effective_date: '||p_master_events_table(i).effective_date
        ||', old_value: '||p_master_events_table(i).old_value
        ||', new_value: '||p_master_events_table(i).new_value
        ||', change_values: '||p_master_events_table(i).change_values
        ||', proration_type: '||p_master_events_table(i).proration_type
        ||', change_mode: '||p_master_events_table(i).change_mode
        ||', element_entry_id: '||p_master_events_table(i).element_entry_id
        ||', next_ee: '||p_master_events_table(i).next_ee
       );
      --
    END LOOP;
    --
  END IF; -- end of debug condition
  --
END interpret_all_asgnmnt_changes;
--
-- ----------------------------------------------------------------------------
-- Update_archive_record
-- Log details for the identified event
-- ============================================================================
-- Updates hri_archive_events with details of the action taken for
-- the earliest event found for an assignent event.
--
PROCEDURE Update_archive_record
  (p_assignment_id         IN NUMBER
  ,p_change_date           IN DATE     -- The effective change date
  ,p_event_queue_table     IN VARCHAR2 -- The table name of the event queue we
                                       -- have identified the event for.
  ,p_action_taken          IN VARCHAR2 -- The action taken with the event we
                                       -- have identified.
  ,p_capture_from_date     IN DATE     -- The date that the event queue was
                                       -- was using as a start date when the
                                       -- event was found.
  )
IS
  --
BEGIN
  --
  INSERT INTO hri_archive_events
  (
   assignment_id
  ,event_queue_table
  ,action_taken
  ,erlst_evnt_effective_date
  ,capture_from_date
  )
  VALUES
  (
   p_assignment_id
  ,p_event_queue_table
  ,p_action_taken
  ,p_change_date
  ,p_capture_from_date
  );
  --
END Update_archive_record;
--
-- ----------------------------------------------------------------------------
-- 5.1.2.2 (Update_Sprvsr_Hstry_Evnt_Q)
-- Update the Supervisor Hierarchy Event Queue
-- ============================================================================
-- This procedure will for the given assignment_id and change date, update
-- the event queue by either:
--
-- + Insert a new record in the event queue (if no record for that assignment
--   exists for the assignment).
-- + Update the existing record in the event queue for the assignment, if it
--   exists, and has a later date than the new event you have found.
-- + Do nothing to the event queue as there is already an early change record
--   for the assignment.
--
-- The procedure will also insert arecord of the event in hri_archive_events
-- for audit purposes to record the event capture and what was done to the
-- event queue as a result of the event capture.
--
PROCEDURE Update_Sprvsr_Hstry_Evnt_Q
  (p_assignment_id IN NUMBER
  ,p_change_date   IN DATE -- The effective change date
  ,p_start_date    IN DATE -- The date the events were captured from
  )
IS
  --
  -- Select the erlst_evnt_processed_date from the event queue
  -- for the assignment_id if it exists, so that we can decide
  -- whether we need to:
  --
  -- + Insert if there is no record for the assignment in the queue.
  -- + Update the queue if p_change_date is earlier than
  --   erlst_evnt_processed_date.
  -- + Do nothing.
  --
  CURSOR c_get_queued_event(cp_assignment_id IN NUMBER) IS
    SELECT erlst_evnt_effective_date
    FROM   hri_eq_sprvsr_hstry_chgs
    WHERE  assignment_id = cp_assignment_id;
  --
  l_erlst_evnt_effective_date DATE; -- Stores the earliest event data for
                                    -- the assignment currently stored
                                    -- in the event queue.
  --
  l_action_taken VARCHAR2(30); -- used to store what we do with the passed
                               -- in event. This is used when inserting
                               -- into hri_archive_events to show what action
                               -- we took with the captured event.
  --
BEGIN
  --
  dbg('Updating the Supervisor History Events Queue for '||p_assignment_id||'.');
  --
  -- Exit if HRI:Populate Supervisor Status History Events Queue is not enabled
  --
  IF g_col_sup_hstry_eq = 'N' THEN
    --
    dbg('Profile HRI:Populate Supervisor Status History Events Queue not enabled, '||
        'skip populating supervisor status history events queue');
    return;
    --
  END IF;
  --
  -- Get the earliest change date currently stored in the event queue
  -- (l_erlst_evnt_processed_date), where it exists.
  --
  OPEN c_get_queued_event(p_assignment_id);
  FETCH c_get_queued_event INTO l_erlst_evnt_effective_date;
  --
  -- If no record exists in the queue for the assignment, then we need to
  -- INSERT into the event queue.
  --
  IF c_get_queued_event%NOTFOUND OR c_get_queued_event%NOTFOUND IS NULL
  THEN
    --
    dbg('No record  for assignment '||p_assignment_id||' exists, so INSERT.');
    --
    INSERT INTO hri_eq_sprvsr_hstry_chgs
    (
     assignment_id
    ,erlst_evnt_effective_date
    )
    VALUES
    (
     p_assignment_id
    ,p_change_date
    );
    --
    l_action_taken := 'INSERTED';
    --
  --
  -- If there is already a record in hri_eq_asgn_evnts for the assignment_id
  -- but it is for an event that occurred later or at the same time as the
  -- new event we have found (p_change_date), then update the queue with the
  -- earlier date.
  --
  ELSIF l_erlst_evnt_effective_date > p_change_date
  THEN
    --
    dbg('Record is earlier than one in queue currently for '||p_assignment_id||', so UPDATE.');
    --
    UPDATE hri_eq_sprvsr_hstry_chgs
    SET erlst_evnt_effective_date = p_change_date
    WHERE assignment_id = p_assignment_id;
    --
    l_action_taken := 'UPDATED';
    --
  ELSE
    --
    dbg('Record is later, or the same date as the one in queue currently for '||p_assignment_id||', so do NOTHING.');
    --
    l_action_taken := 'NONE';
    --
  END IF;
  --
  -- Update the hri_archive_events table with details of what we have
  -- done for the identified event.
  --
  IF g_enable_archive_flag = 'Y' THEN
    --
    Update_archive_record
      (
       p_assignment_id     => p_assignment_id
      ,p_change_date       => p_change_date
      ,p_event_queue_table => 'HRI_EQ_SPRVSR_HSTRY_CHGS'
      ,p_action_taken      => l_action_taken
      ,p_capture_from_date => p_start_date
      );
    --
  END IF;
  --
END Update_Sprvsr_Hstry_Evnt_Q;
--
--
-- ----------------------------------------------------------------------------
-- 5.1.2.1 (Update_Sprvsr_Hrchy_Evnt_Q)
-- Update the Supervisor Hierarchy Event Queue
-- ============================================================================
-- This procedure will for the given assignment_id and change date, update
-- the event queue by either:
--
-- + Insert a new record in the event queue (if no record for that assignment
--   exists for the assignment).
-- + Update the existing record in the event queue for the assignment, if it
--   exists, and has a later date than the new event you have found.
-- + Do nothing to the event queue as there is already an early change record
--   for the assignment.
--
-- The procedure will also insert arecord of the event in hri_archive_events
-- for audit purposes to record the event capture and what was done to the
-- event queue as a result of the event capture.
--
PROCEDURE Update_Sprvsr_Hrchy_Evnt_Q
  (p_assignment_id IN NUMBER
  ,p_change_date   IN DATE -- The effective change date
  ,p_start_date    IN DATE -- The date the events were captured from
  )
IS
  --
  -- Select the erlst_evnt_processed_date from the event queue
  -- for the assignment_id if it exists, so that we can decide
  -- whether we need to:
  --
  -- + Insert if there is no record for the assignment in the queue.
  -- + Update the queue if p_change_date is earlier than
  --   erlst_evnt_processed_date.
  -- + Do nothing.
  --
  CURSOR c_get_queued_event(cp_assignment_id IN NUMBER) IS
    SELECT erlst_evnt_effective_date
    FROM   hri_eq_sprvsr_hrchy_chgs
    WHERE  assignment_id = cp_assignment_id;
  --
  l_erlst_evnt_effective_date DATE; -- Stores the earliest event data for
                                    -- the assignment currently stored
                                    -- in the event queue.
  --
  l_action_taken VARCHAR2(30); -- used to store what we do with the passed
                               -- in event. This is used when inserting
                               -- into hri_archive_events to show what action
                               -- we took with the captured event.
  --
BEGIN
  --
  dbg('Updating the Supervisor Hierarchy Events Queue for '||p_assignment_id||'.');
  --
  -- Exit if HRI:Populate Supervisor Hierarchy Events Queue is not enabled
  --
  IF g_col_sup_hrchy_eq = 'N' THEN
    --
    dbg('Profile HRI:Populate Supervisor Hierarchy Events Queue not enabled, '||
        'skip populating supervisor hierarchy events queue');
    return;
    --
  END IF;
  --
  -- Get the earliest change date currently stored in the event queue
  -- (l_erlst_evnt_processed_date), where it exists.
  --
  OPEN c_get_queued_event(p_assignment_id);
  FETCH c_get_queued_event INTO l_erlst_evnt_effective_date;
  --
  -- If no record exists in the queue for the assignment, then we need to
  -- INSERT into the event queue.
  --
  IF c_get_queued_event%NOTFOUND OR c_get_queued_event%NOTFOUND IS NULL
  THEN
    --
    dbg('No record  for assignment '||p_assignment_id||' exists, so INSERT.');
    --
    INSERT INTO hri_eq_sprvsr_hrchy_chgs
    (
     assignment_id
    ,erlst_evnt_effective_date
    )
    VALUES
    (
     p_assignment_id
    ,p_change_date
    );
    --
    l_action_taken := 'INSERTED';
    --
  --
  -- If there is already a record in hri_eq_asgn_evnts for the assignment_id
  -- but it is for an event that occurred later or at the same time as the
  -- new event we have found (p_change_date), then update the queue with the
  -- earlier date.
  --
  ELSIF l_erlst_evnt_effective_date > p_change_date
  THEN
    --
    dbg('Record is earlier than one in queue currently for '
        ||p_assignment_id||', so UPDATE.');
    --
    UPDATE hri_eq_sprvsr_hrchy_chgs
    SET erlst_evnt_effective_date = p_change_date
    WHERE assignment_id = p_assignment_id;
    --
    l_action_taken := 'UPDATED';
    --
  ELSE
    --
    dbg('Record is later, or the same date as the one in queue currently for '
        ||p_assignment_id||', so do NOTHING.');
    --
    l_action_taken := 'NONE';
    --
  END IF;
  --
  -- Update the hri_archive_events table with details of what we have
  -- done for the identified event.
  --
  IF g_enable_archive_flag = 'Y' THEN
    --
    Update_archive_record
      (
       p_assignment_id     => p_assignment_id
      ,p_change_date       => p_change_date
      ,p_event_queue_table => 'HRI_EQ_SPRVSR_HRCHY_CHGS'
      ,p_action_taken      => l_action_taken
      ,p_capture_from_date => p_start_date
      );
    --
  END IF;
  --
END Update_Sprvsr_Hrchy_Evnt_Q;
--
-- ----------------------------------------------------------------------------
-- Find_sub_event_group_events
-- Find the earliest event in the master event group PLSQL table for a given
-- sub event group id.
-- ============================================================================
--
-- This procedure calls pay_interpreter_pkg.get_subset_given_new_evg to
-- process the alreadu identified events in the master event group, to see
-- if any of those events are in the sub event group.
--
-- If any events are found in the sub event group, then the earliest event date
-- found is returned via p_event_date to the calling process.
--
-- The package pay_interpreter_pkg.get_subset_given_new_evg returns a PLSQL
-- table similar to the one passed in, but only containing those rows that
-- are relevant to these event queues. The earliest of the records found in
-- the returned PLSQL table, is then used to update the event queues.
--
--
PROCEDURE Find_sub_event_group_events
  (
   p_assignment_id IN NUMBER    -- The assignment id that we are currently
                                -- processing.
  ,p_start_date IN DATE         -- Used for updating the event archive only.
                                -- Does not effect process flow in this
                                -- procedure.
  ,p_sub_event_grp_id IN NUMBER -- The event group id of the sub event group
                                -- that we are trying to find events for.
  ,p_comment_text VARCHAR2      -- Text used by debug comments to indicate
                                -- which queue's sub eveng group is being
                                -- processed.
  ,p_master_events_table        -- The Master Event Group PLSQL table.
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type
  ,p_event_date OUT nocopy DATE -- Event date of the earliest sub event found
                                -- in the passed in event group and
                                -- master events table
  ,p_sub_evt_grp_tbl OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type
                                 -- This array is only relevant as an
                                 -- output value when p_event_capture_mode
                                 -- is 'S'.
                                 --
  ,p_event_capture_mode IN VARCHAR2 -- Indicates whether the process should
                                 -- E) return the earliest date for a
                                 --    relevant change.
                                 -- OR
                                 -- R) Return simply the fact that a
                                 --    relevant change has been found
                                 -- OR
                                 -- S) Return the sub event group array
                                 --    for further processing.
  )
IS
  --
  -- We only care about the earliest change for an assignment. l_min_date is
  -- used to store the earliest effective_date date found in the PLSQL table
  -- l_sub_evt_grp_tbl returned from the call to
  -- pay_interpreter_pkg.get_subset_given_new_evg
  --
  --
  l_min_date             DATE;
  l_effective_date       DATE;
  l_extns_date           DATE;
  --
BEGIN
  --
  dbg('Executing Find_sub_event_group_events for '||p_comment_text
      ||' in mode '|| p_event_capture_mode ||'....');
  --
  -- If the master event group PLSQL table is empty then there is no
  -- point continuing, so exit procedure.
  --
  IF p_master_events_table.COUNT = 0
  THEN
    --
    dbg('0 records in master table for '||p_comment_text||
        ', exiting Find_sub_event_group_events');
    --
    p_event_date := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- Set the minimum change date for the assignment to end of time.
  --
  l_min_date := g_end_of_time;
  --
  -- Find all the events in the master event group for the assignment that
  -- relate to the sub event group for changes relevant to the assignment
  -- events fact.
  --
  dbg('Calling pay_interpreter_pkg.get_subset_given_new_evg ...');
  --
  pay_interpreter_pkg.get_subset_given_new_evg
    (p_filter_event_group_id => p_sub_event_grp_id
    ,p_complete_detail_tab   => p_master_events_table
    ,p_subset_detail_tab     => p_sub_evt_grp_tbl
    );
  --
  dbg('Sub Event Rows Returned: '||p_sub_evt_grp_tbl.COUNT);
  --
  -- The followin IF statement is used for debugging only.
  --
  IF (p_sub_evt_grp_tbl.COUNT <> p_master_events_table.COUNT)
     AND
     (g_debug_flag = 'Y')
  THEN
    --
    dbg(
        'Row number discrepency found for assignment: '
        ||TO_CHAR(p_assignment_id)||','
        ||TO_CHAR(p_master_events_table.COUNT)||','
        ||TO_CHAR(p_sub_evt_grp_tbl.COUNT)
       );
    --
  END IF;
  --
  -- Only need to check find the earliest change if rows have been found
  -- that relate to the sub event group.
  --
  IF p_sub_evt_grp_tbl.COUNT > 0
  THEN
    --
    dbg('Found some records in the '||p_comment_text||' sub event group');
    --
  ELSE
    --
    dbg('No relevant records found that affect '||p_comment_text||'.');
    --
    -- No relevant events found, so return NULL date, this will be used by the
    -- calling process, to decide not to do anything further.
    --
    p_event_date := NULL;
    --
    RETURN;
    --
  END IF; -- If l_sub_evt_grp_tbl.COUNT > 0
  --
  -- If we are in mode 'R' simply return the fact that an
  -- event has been found within the specified period.
  --
  IF p_event_capture_mode = 'R'
  THEN
    --
    -- If any events have occurred for the sub event group within
    -- the period this mode will simply return 'end of time'
    --
    dbg('An event has been found within the period ...');
    dbg('As called in mode ''R'' return p_event_date as ''end of time''.');
    --
    p_event_date := g_end_of_time;
    --
    RETURN;
    --
  END IF;
  --
  -- Default mode 'S' will return the earliest relevent sub event group
  -- event date for the assignment within the period, and p_sub_evt_grp_tbl
  -- which can be ignored.
  --
  IF p_event_capture_mode = 'S'
  THEN
    --
    -- If any events have occurred for the sub event group within
    -- the period this mode will simply return 'end of time' and the
    -- array p_sub_evt_grp_tbl.
    --
    dbg('An event has been found within the period ...');
    dbg('As called in mode ''S'' return p_event_date as ''end of time'''||
        ' and return the sub event group array ''p_sub_evt_grp_tbl'''||
        ' for further processing.');
    --
    p_event_date := g_end_of_time;
    --
    RETURN;
    --
  END IF; -- Default get earliest date of change mode 'S'
  --
  -- Default mode 'E' will return the earliest relevent sub event group
  -- event date for the assignment within the period.
  --
  IF p_event_capture_mode = 'E'
  THEN
    --
    -- Default get earliest date of change mode 'E'
    --
    dbg('Find_sub_event_group_events has been called in mode ''E''.');
    --
    FOR i in 1..p_sub_evt_grp_tbl.COUNT
    LOOP
      --
      -- Call the function which evaluates the event date for special cases
      -- such as Termination date evaluation, extension date calculations etc.
      -- It returns the adjusted event date or the effective change date
      --
      l_effective_date := eval_one_off_cases
                            (p_sub_evt_grp_tbl   => p_sub_evt_grp_tbl(i)
                            ,p_assignment_id     => p_assignment_id
                            ,p_comment_text      => p_comment_text
                            ,p_effective_date    => p_sub_evt_grp_tbl(i).effective_date);
      --
      -- If the change date of the current record is less than l_min_date
      -- change l_min_date to equal that date. At the end of the loop
      -- l_min_date will be set to the earliest change date for the assignment
      -- since p_start_date.
      --
      IF l_effective_date < l_min_date
      THEN
        --
        l_min_date := l_effective_date;
        --
        dbg('Earliest date found so far: '||TO_CHAR(l_min_date));
        --
      END IF;
      --
      -- Following IF statement is for debug purposes only.
      --
      IF g_debug_flag = 'Y'
      THEN
        --
        dbg('Datetracked_event: '||p_sub_evt_grp_tbl(i).datetracked_event
          ||', Change_mode: '||p_sub_evt_grp_tbl(i).change_mode
          ||', Effective_date: '||p_sub_evt_grp_tbl(i).effective_date
          ||', dated_table_id: '||TO_CHAR(p_sub_evt_grp_tbl(i).dated_table_id)
          ||', surrogate_key: '||TO_CHAR(p_sub_evt_grp_tbl(i).surrogate_key)
          ||', column_name: '||TO_CHAR(p_sub_evt_grp_tbl(i).column_name)
          ||', old_value: '||p_sub_evt_grp_tbl(i).old_value
          ||', new_value: '||p_sub_evt_grp_tbl(i).new_value
          ||', change_values: '||p_sub_evt_grp_tbl(i).change_values
          );
        --
      END IF; -- g_debug_flag = 'Y'
      --
    END LOOP;
    --
    -- Set p_event_date to the earliest event date found. This will be used
    -- by the calling procedure to update the relevant event queue.
    --
    -- 3906029, For supervisor hierarchy events the min date returned by the
    -- wrapper, cannot be used directly. In case the event occurs before the
    -- minimum date for which the hierarchy is populated, the collection program
    -- will collect data which can corrupt the hierarchy with duplicate records
    -- for subordinates. So the min date should returned should not be
    -- less than the Refresh From Date for the last full refresh run of supervisor
    -- hierarchy
    --
    IF p_comment_text = 'Supervisor' THEN
      --
      dbg('As this is a supervisor event, we need to make sure event date '||
          'returned (p_event_date) is no less than minimum date for which '||
          'the supervisor hierarchy has been populated');
      --
      p_event_date := greatest(l_min_date,g_min_suph_date);
      --
    ELSIF l_min_date = g_end_of_time THEN
      --
      -- In case the min event date is eot then there is no need to create an event
      -- the l_min_date is initialized to EOT, and there is no point in capturing an event
      -- which is happening so far in time.
      --
      dbg('l_min_date IS EOT so set p_event_date to NULL');
      --
      p_event_date := null;
      --
    ELSE
      --
      dbg('Just return the earliest date found');
      --
      p_event_date := l_min_date;
      --
    END IF;
    --
    dbg('Returning p_event_date as '||TO_CHAR(p_event_date)||'.');
    --
    RETURN;
    --
  END IF; -- Default get earliest date of change mode 'E'
  --
END Find_sub_event_group_events;
--
-- Overloaded version of procedure to be called for event groups where we
-- are interested in the earliest change for an assignment, as opposed
-- to just being interested in the whether an event has occurred at all.
--
PROCEDURE Find_sub_event_group_events
  (
   p_assignment_id IN NUMBER    -- The assignment id that we are currently
                                -- processing.
  ,p_start_date IN DATE         -- Used for updating the event archive only.
                                -- Does not effect process flow in this
                                -- procedure.
  ,p_sub_event_grp_id IN NUMBER -- The event group id of the sub event group
                                -- that we are trying to find events for.
  ,p_comment_text VARCHAR2      -- Text used by debug comments to indicate
                                -- which queue's sub eveng group is being
                                -- processed.
  ,p_master_events_table        -- The Master Event Group PLSQL table.
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type
  ,p_event_date OUT nocopy DATE -- Event date of the earliest sub event found
                                -- in the passed in event group and
                                -- master events table
  )
IS
  --
  -- The following PLSQL table will hold the events found from the master
  -- event group that relate to sub event group for the passed in sub event
  -- group id (p_sub_event_grp_id). It's return value is ignored
  --
  l_sub_evt_grp_tbl pay_interpreter_pkg.t_detailed_output_table_type;
  --
BEGIN
  --
  Find_sub_event_group_events
  (
   p_assignment_id => p_assignment_id
  ,p_start_date => p_start_date
  ,p_sub_event_grp_id => p_sub_event_grp_id
  ,p_comment_text => p_comment_text
  ,p_master_events_table => p_master_events_table
  ,p_event_date => p_event_date
  ,p_sub_evt_grp_tbl => l_sub_evt_grp_tbl -- result ignored when called from here
  ,p_event_capture_mode => 'E' -- Indicates we want to know earliest event
  );
  --
END;
--
-- ----------------------------------------------------------------------------
-- 5.1.2 (Process_supervisor_events)
-- Get Earliest Supervisor Event For Assignment
-- ============================================================================
-- This procedure calls the procedure Find_sub_event_group_events, passing
-- in the master event group PLSQL table (containing all the interpreted
-- events that have occurred since p_start_date for the assignment), to
-- identify all of the events that have occurred that are relevent to
-- the supervisor hierarchy, and supervisor status history event queues.
--
PROCEDURE Process_supervisor_events
  (p_assignment_id IN NUMBER
  ,p_start_date IN DATE
  ,p_master_events_table
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type)
IS
  --
  -- l_min_date is used to store the earliest effective_date date found
  -- by the procedure Find_sub_event_group_events for the sub event group
  --
  l_min_date DATE;
  --
BEGIN
  --
  dbg('Executing Process_supervisor_events ....');
  --
  -- 3658545 exit if the supervisor related queues are not to be populated
  --
  IF g_col_sup_hrchy_eq = 'N' AND
     g_col_sup_hstry_eq = 'N'
  THEN
    --
    dbg('Not populating supervisor related queues');
    RETURN;
    --
  END IF;
  --
  Find_sub_event_group_events
    (
     p_assignment_id => p_assignment_id
    ,p_start_date => p_start_date
    ,p_sub_event_grp_id => g_sprvsr_change_event_grp_id
    ,p_comment_text => 'Supervisor'
    ,p_master_events_table => p_master_events_table
    ,p_event_date => l_min_date
    );
  --
  -- If l_min_date is NOT NULL this means that Find_sub_event_group_events
  -- has found an event for the sub event group, and assignment id on that
  -- date. We therefore need to see if it is necessary to update the relevant
  -- event queues with this information.
  --
  IF l_min_date IS NOT NULL
  THEN
    --
    Update_Sprvsr_Hrchy_Evnt_Q
      (
       p_assignment_id => p_assignment_id
      ,p_change_date   => l_min_date
      ,p_start_date    => p_start_date
      );
    --
    Update_Sprvsr_Hstry_Evnt_Q
      (
       p_assignment_id => p_assignment_id
      ,p_change_date   => l_min_date
      ,p_start_date    => p_start_date
      );
    --
  END IF;
  --
END Process_supervisor_events;
--
-- ----------------------------------------------------------------------------
-- 5.1.3.1 (Update_Asgn_Evnt_Fct_Evnt_Q)
-- Update the Assignment Event Fact Event Queue
-- ============================================================================
-- This procedure will for the given assignment_id and change date, update
-- the event queue by either:
--
-- + Insert a new record in the event queue (if no record for that assignment
--   exists for the assignment).
-- + Update the existing record in the event queue for the assignment, if it
--   exists, and has a later date than the new event you have found.
-- + Do nothing to the event queue as there is already an early change record
--   for the assignment.
--
-- The procedure will also insert arecord of the event in hri_archive_events
-- for audit purposes to record the event capture and what was done to the
-- event queue as a result of the event capture.
--
PROCEDURE Update_Asgn_Evnt_Fct_Evnt_Q
  (p_assignment_id IN NUMBER
  ,p_change_date   IN DATE -- The effective change date
  ,p_start_date    IN DATE -- The date the events were captured from
  )
IS
  --
  -- Select the erlst_evnt_processed_date from the event queue
  -- for the assignment_id if it exists, so that we can decide
  -- whether we need to:
  --
  -- + Insert if there is no record for the assignment in the queue.
  -- + Update the queue if p_change_date is earlier than
  --   erlst_evnt_processed_date.
  -- + Do nothing.
  --
  CURSOR c_get_queued_event(cp_assignment_id IN NUMBER) IS
    SELECT erlst_evnt_effective_date
    FROM   hri_eq_asgn_evnts
    WHERE  assignment_id = cp_assignment_id;
  --
  l_erlst_evnt_effective_date DATE; -- Stores the earliest event data for
                                    -- the assignment currently stored
                                    -- in the wvwnt queue.
  --
  l_action_taken VARCHAR2(30); -- used to store what we do with the passed
                               -- in event. This is used when inserting
                               -- into hri_archive_events to show what action
                               -- we took with the captured event.
  --
BEGIN
  --
  dbg('Updating the Assignment Events Queue for '||p_assignment_id||'.');
  --
  -- Get the earliest change date currently stored in the event queue
  -- (l_erlst_evnt_processed_date), where it exists.
  --
  OPEN c_get_queued_event(p_assignment_id);
  FETCH c_get_queued_event INTO l_erlst_evnt_effective_date;
  --
  -- If no record exists in the queue for the assignment, then we need to
  -- INSERT into the event queue.
  --
  IF c_get_queued_event%NOTFOUND OR c_get_queued_event%NOTFOUND IS NULL
  THEN
    --
    dbg('No record  for assignment '||p_assignment_id||' exists, so INSERT.');
    --
    INSERT INTO hri_eq_asgn_evnts
    (
     assignment_id
    ,erlst_evnt_effective_date
    )
    VALUES
    (
     p_assignment_id
    ,p_change_date
    );
    --
    l_action_taken := 'INSERTED';
    --
  --
  -- If there is already a record in hri_eq_asgn_evnts for the assignment_id
  -- but it is for an event that occurred later or at the same time as the
  -- new event we have found (p_change_date), then update the queue with the
  -- earlier date.
  --
  ELSIF l_erlst_evnt_effective_date > p_change_date
  THEN
    --
    dbg('Record is earlier than one in queue currently for '||p_assignment_id||', so UPDATE.');
    --
    UPDATE hri_eq_asgn_evnts
    SET erlst_evnt_effective_date = p_change_date
    WHERE assignment_id = p_assignment_id;
    --
    l_action_taken := 'UPDATED';
    --
  ELSE
    --
    dbg('Record is later, or the same date as the one in queue currently for '||p_assignment_id||', so do NOTHING.');
    --
    l_action_taken := 'NONE';
    --
  END IF;
  --
  -- Update the hri_archive_events table with details of what we have
  -- done for the identified event.
  --
  IF g_enable_archive_flag = 'Y' THEN
    --
    Update_archive_record
      (
       p_assignment_id     => p_assignment_id
      ,p_change_date       => p_change_date
      ,p_event_queue_table => 'HRI_EQ_ASGN_EVNTS'
      ,p_action_taken      => l_action_taken
      ,p_capture_from_date => p_start_date
      );
  --
  END IF;
  --
END Update_Asgn_Evnt_Fct_Evnt_Q;


--
-- ----------------------------------------------------------------------------
-- 5.1.3.??? (Update_Absence_Dim_Evnt_Q)
-- Update the Assignment Event Fact Event Queue
-- ============================================================================
-- This procedure will for the given assignment_id and change date, update
-- the event queue by either:
--
-- + Insert a new record in the event queue (if no record for that assignment
--   exists for the assignment).
-- + Do nothing to the event queue as there is already a change record
--   for the assignment.
--
-- The procedure will also insert arecord of the event in hri_archive_events
-- for audit purposes to record the event capture and what was done to the
-- event queue as a result of the event capture.
--
PROCEDURE Update_Absence_Dim_Evnt_Q
  (p_assignment_id   IN NUMBER
  ,p_start_date      IN DATE     -- The date the events were captured from
  ,p_sub_evt_grp_tbl IN  pay_interpreter_pkg.t_detailed_output_table_type
                                 -- The events found in the sub event group
                                 -- that need to be processed to identify
                                 -- which absence_attendance_ids have had
                                 -- events.
  )
IS
  --
  -- Identify if an event is already queued for the absence_attendance_id
  --
  CURSOR c_get_queued_event(cp_absence_attendance_id IN NUMBER) IS
    SELECT 'X' h_dummy
    FROM   hri_eq_utl_absnc_dim
    WHERE  absence_attendance_id = cp_absence_attendance_id;
  --
  -- Stores the previous absence attendance id being processed.
  --
  l_prv_absence_attendance_id NUMBER DEFAULT -1;
  --
  -- Stores a dummy value returned from cursor c_get_queued_event
  --
  l_dummy VARCHAR2(1);
  --
  -- l_action_taken used to store the type of event that has occurred
  -- to be stored in the archive table.
  --
  l_action_taken VARCHAR2(10) DEFAULT NULL;
  --
BEGIN
  --
  dbg('In procedure Update_Absence_Dim_Evnt_Q ...');
  --
  dbg('Updating the Absence Dimension Queue for '||p_assignment_id||'.');
  --
  -- Loop through sub event group and identify the unique
  -- absence_attendance_ids that have had an event.
  --
  FOR i in 1..p_sub_evt_grp_tbl.COUNT
  LOOP
    --
    -- Holds the surrogate key value for the event that has occurred
    -- for absence eevents this will be the absence_attendance_id
    --
    IF l_prv_absence_attendance_id <>
       p_sub_evt_grp_tbl(i).surrogate_key
    THEN
      --
      dbg('Found event for absence_attendance_id '||
          p_sub_evt_grp_tbl(i).surrogate_key);
      --
      -- Check if there is already an event for this absence_attendance_id
      -- in the queue.
      --
      OPEN c_get_queued_event(p_sub_evt_grp_tbl(i).surrogate_key);
      FETCH c_get_queued_event INTO l_dummy;

      --
      -- If no record in the event queue is found for the absence_attendance_id
      -- then insert it into the queue
      --
      IF c_get_queued_event%NOTFOUND OR c_get_queued_event%NOTFOUND IS NULL
      THEN
        --
        dbg('No record  for assignment '||p_assignment_id||' exists, so INSERT.');
        --
        INSERT INTO hri_eq_utl_absnc_dim
        (
         absence_attendance_id
        )
        VALUES
        (
         p_sub_evt_grp_tbl(i).surrogate_key
        );
        --
        l_action_taken := 'INSERTED';
        --
      --
      -- IF a record already exists for the absence
      --
      ELSE
        --
        dbg('Record already exists.');
        --        --
        l_action_taken := 'NONE';
        --
      END IF;
      --
      -- Close Curosr c_get_queued_event
      --
      CLOSE c_get_queued_event;
      --
      -- Update the hri_archive_events table with details of what we have
      -- done for the identified event.
      --
      IF g_enable_archive_flag = 'Y' THEN
        --
        -- Instead of assignment_id pass in absence_attendance_id
        --
        Update_archive_record
          (
           p_assignment_id     => p_sub_evt_grp_tbl(i).surrogate_key
          ,p_change_date       => NULL
          ,p_event_queue_table => 'HRI_EQ_UTL_ABSNC_DIM '
          ,p_action_taken      => l_action_taken
          ,p_capture_from_date => p_start_date
          );
        --
      END IF;
      --
      -- Set the value of the value for l_prv_absence_attendance_id
      -- to the current absence_attendance_id so that we can see
      -- if it has changed in the next loop.
      --
      l_prv_absence_attendance_id := p_sub_evt_grp_tbl(i).surrogate_key;
      --
      -- Following IF statement is for debug purposes only.
      --
      IF g_debug_flag = 'Y'
      THEN
        --
        dbg('Datetracked_event: '||p_sub_evt_grp_tbl(i).datetracked_event
          ||', Change_mode: '||p_sub_evt_grp_tbl(i).change_mode
          ||', Effective_date: '||p_sub_evt_grp_tbl(i).effective_date
          ||', dated_table_id: '||TO_CHAR(p_sub_evt_grp_tbl(i).dated_table_id)
          ||', surrogate_key: '||TO_CHAR(p_sub_evt_grp_tbl(i).surrogate_key)
          ||', column_name: '||TO_CHAR(p_sub_evt_grp_tbl(i).column_name)
          ||', old_value: '||p_sub_evt_grp_tbl(i).old_value
          ||', new_value: '||p_sub_evt_grp_tbl(i).new_value
          ||', change_values: '||p_sub_evt_grp_tbl(i).change_values
          );
        --
      END IF; -- g_debug_flag = 'Y'
      --
    END IF; -- If the absence_attendance_id has changed.
    --
  END LOOP;
  --
END Update_Absence_Dim_Evnt_Q;
--
-- ----------------------------------------------------------------------------
-- 5.1.3 (Process_assgnmnt_evnt_changes)
-- Get Earliest Assignment Events Fact Event For Assignment
-- ============================================================================
-- This procedure calls the procedure Find_sub_event_group_events, passing
-- in the master event group PLSQL table (containing all the interpreted
-- events that have occurred since p_start_date for the assignment), to
-- identify all of the events that have occurred that are relevent to
-- the assignment events fact event queue.
--
PROCEDURE Process_assgnmnt_evnt_changes
  (p_assignment_id IN NUMBER
  ,p_start_date IN DATE
  ,p_master_events_table
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type)
IS
  --
  -- l_min_date is used to store the earliest effective_date date found
  -- by the procedure Find_sub_event_group_events for the sub event group
  --
  l_min_date DATE;
  --
BEGIN
  --
  dbg('Executing Process_assgnmnt_evnt_changes ....');
  --
  -- 3658545 Populate assignment events queue only if g_col_asg_events_eq = 'Y'
  --
  IF g_col_asg_events_eq = 'N' THEN
    --
    dbg('Profile HRI:Populate Assignment Events Queue not enabled, skip populating '||
        'assignment events queue');
    return;
    --
  END IF;
  --
  Find_sub_event_group_events
    (
     p_assignment_id => p_assignment_id
    ,p_start_date => p_start_date
    ,p_sub_event_grp_id => g_assgnmnt_evnt_event_grp_id
    ,p_comment_text => 'Assignment Events'
    ,p_master_events_table => p_master_events_table
    ,p_event_date => l_min_date
    );
  --
  -- If l_min_date is NOT NULL this means that Find_sub_event_group_events
  -- has found an event for the sub event group, and assignment id on that
  -- date. We therefore need to see if it is necessary to update the relevant
  -- event queues with this information.
  --
  IF l_min_date IS NOT NULL
  THEN
    --
    -- Insert a record in the event queue for the earliest change for the
    -- assignment for the sub event group.
    --
    Update_Asgn_Evnt_Fct_Evnt_Q
      (
       p_assignment_id => p_assignment_id
      ,p_change_date   => l_min_date
      ,p_start_date    => p_start_date
      );
    --
  END IF;
  --
END Process_assgnmnt_evnt_changes;
--
-- ----------------------------------------------------------------------------
-- 5.1.4 (Process_absence_evnt_changes)
-- Get Absence Events For Assignment
-- ============================================================================
-- This procedure calls the procedure Find_sub_event_group_events, passing
-- in the master event group PLSQL table (containing all the interpreted
-- events that have occurred since p_start_date for the assignment), to
-- identify any events that have occurred that are relevent to
-- the absence dimension event queue.
--
PROCEDURE Process_absence_dim_changes
  (p_assignment_id IN NUMBER
  ,p_start_date IN DATE
  ,p_master_events_table
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type)
IS
  --
  -- l_min_date is used to store the earliest effective_date date found
  -- by the procedure Find_sub_event_group_events for the sub event group
  --
  l_min_date DATE;
  --
  -- The following PLSQL table will hold the sub events returned by
  -- Find_sub_event_group_events.
  --
  l_sub_evt_grp_tbl pay_interpreter_pkg.t_detailed_output_table_type;
  --
BEGIN
  --
  dbg('Executing Process_absence_evnt_changes ....');
  --
  -- 3658545 Populate assignment events queue only if g_col_asg_events_eq = 'Y'
  --
  IF g_col_absence_events_eq = 'N' THEN
    --
    dbg('Profile HRI:Absence Dimension Queue not enabled, skip populating '||
        'absence events queue');
    return;
    --
  END IF;
  --
  Find_sub_event_group_events
    (
     p_assignment_id => p_assignment_id
    ,p_start_date => p_start_date
    ,p_sub_event_grp_id => g_absence_dim_event_grp_id
    ,p_comment_text => 'Absences'
    ,p_master_events_table => p_master_events_table
    ,p_event_date => l_min_date
    ,p_sub_evt_grp_tbl => l_sub_evt_grp_tbl
    ,p_event_capture_mode => 'S' -- Tells process just tell if there has been
                                 -- an event within the period. D not care
                                 -- when this was, as absences are not date
                                 -- tracked.
    );
  --
  -- If l_min_date is NOT NULL this means that Find_sub_event_group_events
  -- has found an event for the sub event group, and assignment id on that
  -- date. We therefore need to see if it is necessary to update the relevant
  -- event queues with this information.
  --
  IF l_min_date IS NOT NULL
  THEN
    --
    dbg('Absence Events have been found ....');
    --
    -- Insert a record in the event queue for the earliest change for the
    -- assignment for the sub event group.
    --
    dbg('Calling Update_Absence_Dim_Evnt_Q ....');
    --
    Update_Absence_Dim_Evnt_Q
      (
       p_assignment_id => p_assignment_id
      ,p_start_date    => p_start_date
      ,p_sub_evt_grp_tbl => l_sub_evt_grp_tbl
      );
    --
  ELSE
    --
    dbg('Absence Events have NOT been found ....');
    --
  END IF;
  --
END Process_absence_dim_changes;
--
-- ----------------------------------------------------------------------------
-- Capture_Events
-- Main Entry point for capturing events for a given assignment
-- ============================================================================
-- This procedure is the main contoling processing of a given
-- assignment. It is called by process_range, the entry point for handling a
-- single assignment called by the child multithreading process.
--
PROCEDURE capture_events
  (p_assignment_id NUMBER
  ,p_start_date DATE)
IS
  --
  l_master_events_table pay_interpreter_pkg.t_detailed_output_table_type;
  --
BEGIN
  --
  interpret_all_asgnmnt_changes(p_assignment_id
                               ,p_start_date
                               ,l_master_events_table);
  --
  Process_supervisor_events(p_assignment_id
                           ,p_start_date
                           ,l_master_events_table);
  --
  Process_assgnmnt_evnt_changes(p_assignment_id
                                ,p_start_date
                                ,l_master_events_table);
  --
  Process_absence_dim_changes(p_assignment_id
                              ,p_start_date
                              ,l_master_events_table);
  --
END;
--
-- ----------------------------------------------------------------------------
-- run_for_bg
-- Test procedure to run for all assignments consecutively
-- ============================================================================
--
PROCEDURE run_for_bg(
   p_business_group_id  IN NUMBER
  ,p_collect_from       IN DATE
  )
IS
  --
  CURSOR asg_csr IS
  SELECT DISTINCT assignment_id
  FROM per_all_assignments_f
  WHERE assignment_type = 'E'
  AND business_group_id = NVL(p_business_group_id, business_group_id)
  AND (effective_start_date >= p_collect_from
    OR effective_end_date >= p_collect_from);
  --
BEGIN
  --
  FOR asg_rec IN asg_csr LOOP
    --
    capture_events(
      p_assignment_id  => asg_rec.assignment_id
     ,p_start_date => SYSDATE) ;
    --
  END LOOP;
  --
  COMMIT;
  --
END run_for_bg;
--
-- ----------------------------------------------------------------------------
-- run_for_asg
-- Debugging procedure to run for a single assignment
-- ============================================================================
--
PROCEDURE run_for_asg(
                      p_assignment_id     IN NUMBER
                     ,p_capture_from_date IN DATE
                     )
IS
  --
BEGIN
  --
  g_master_event_group_id      := get_event_group_id('HRI_ASG_MASTER_GROUP');
  g_sprvsr_change_event_grp_id := get_event_group_id('HRI_SUPERVISOR_EVENTS');
  g_assgnmnt_evnt_event_grp_id := get_event_group_id('HRI_ASG_EVNTS_FCT');
  g_absence_dim_event_grp_id   := get_event_group_id('HRI_ABSENCE_EVENTS');
  --
  g_prd_of_srvc_table_id    := get_dated_table_id('PER_PERIODS_OF_SERVICE');
  g_appraisal_table_id      := get_dated_table_id('PER_APPRAISALS');
  g_perf_review_table_id    := get_dated_table_id('PER_PERFORMANCE_REVIEWS');
  g_asg_table_id            := get_dated_table_id('PER_ALL_ASSIGNMENTS_F');
  g_person_type_table_id    := get_dated_table_id('PER_PERSON_TYPE_USAGES_F');
  --
  g_absence_attendance_table_id := get_dated_table_id('PER_ABSENCE_ATTENDANCES');
  --
  capture_events
    (
     p_assignment_id  => p_assignment_id
    ,p_start_date     => p_capture_from_date
    );
  --
  -- Commit is okay here as we are not executing the PYUGEN portion of this
  -- package.
  --
  COMMIT;
  --
END run_for_asg;
--
-- Decides whether to full refresh
--
FUNCTION get_full_refresh_value RETURN VARCHAR2
  IS
  --
  -- Indicators showing whether particular tables should be fully or
  -- incrementally refreshed.
  --
  l_suph_full_refresh     VARCHAR2(30);
  l_asgn_full_refresh     VARCHAR2(30);
  l_spst_full_refresh     VARCHAR2(30);
  l_absc_full_refresh     VARCHAR2(30);
  --
BEGIN
  --
  -- Get full refresh value for each of dependent tables
  --
  dbg('Getting full refresh value for each of dependent tables ...');
  --
  l_suph_full_refresh := hri_oltp_conc_param.get_parameter_value
                          (p_parameter_name     => 'FULL_REFRESH',
                           p_process_table_name => 'HRI_CS_SUPH');
  l_asgn_full_refresh := hri_oltp_conc_param.get_parameter_value
                          (p_parameter_name     => 'FULL_REFRESH',
                           p_process_table_name => 'HRI_MB_ASGN_EVENTS_CT');
  l_spst_full_refresh := hri_oltp_conc_param.get_parameter_value
                          (p_parameter_name     => 'FULL_REFRESH',
                           p_process_table_name => 'HRI_CL_WKR_SUP_STATUS_CT');
  l_absc_full_refresh := hri_oltp_conc_param.get_parameter_value
                          (p_parameter_name     => 'FULL_REFRESH',
                           p_process_table_name => 'HRI_CS_ABSENCE_CT');
  --
  -- Only do the following if you are in debug mode for information purposes
  --
  IF g_debug_flag = 'Y'
  THEN
    --
    msg('l_suph_full_refresh: '||l_suph_full_refresh);
    msg('l_asgn_full_refresh: '||l_asgn_full_refresh);
    msg('l_spst_full_refresh: '||l_spst_full_refresh);
    msg('l_absc_full_refresh: '||l_absc_full_refresh);
    --
  END IF;
  --
  -- If any of these processes is incremental then
  -- event capture must be incremental
  --
  IF (l_suph_full_refresh = 'N' OR
      l_asgn_full_refresh = 'N' OR
      l_spst_full_refresh = 'N' OR
      l_absc_full_refresh = 'N')
  THEN
    --
    dbg('Return ''N'' to indicate incremental refresh should take place.');
    --
    RETURN 'N';
    --
  ELSE
    --
    dbg('Return ''Y'' to indicate full refresh should take place.');
    --
    RETURN 'Y';
    --
  END IF;
  --
END get_full_refresh_value;
--
--
-- -----------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--                         Multithreading Calls                               --
-- -----------------------------------------------------------------------------
-- The Multithreading Utility Provides the Framework for processing collection
-- using multiple threads. The sequence of operation performed by the utility are
--   a) Invoke the PRE_PROCESS procedure to initialize the global variables and
--      return a SQL based on which the processing ranges will be created.
--      In case of Foundation HR environment or when the process is being run in
--      full refresh mode the process will not return any SQL. Therefore the
--      mulithtreading utility will not invoke the PROCESS_RANGE and POST_PROCESS
--      process.
--   b) Invoke the PROCESS_RANGE procedure to process the assignments in the range
--      This part is done by multiple threads
--   c) Invoke the POST_PROCESS procedure to perform the post processing tasks
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- SET_PARAMETERS
-- sets up parameters required for the events capture processes
-- Sets up global list of parameters, this is the way that parameters need
-- to be set up for collecting incremental events by HRI multithreading utility
-- ----------------------------------------------------------------------------
--
PROCEDURE set_parameters( p_mthd_action_id  IN NUMBER,
                          p_called_from     IN VARCHAR2 default null)
IS
  --
  l_bis_start_date   DATE;
  l_bis_end_date     DATE; -- Dummy variable return value ignored
  l_period_from      DATE; -- Dummy variable return value ignored
  l_period_to        DATE; -- Dummy variable return value ignored
  l_message          fnd_new_messages.message_text%TYPE;
  --
BEGIN
  --
  dbg('Setting parameters ...');
  --
  -- If parameters haven't already been set, then set them
  --
  IF p_called_from = 'PRE_PROCESS'
  THEN
    --
    dbg('Parameters haven''t been set yet, so set them ...');
    --
    -- Populate the multithread action arrays
    --
    g_mthd_action_array   := hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
    --
    -- Decide whether to full refresh
    --
    g_full_refresh := get_full_refresh_value;
    dbg('Full refresh:   ' || g_full_refresh);
    --
    -- Get the profile value which determines whether Archiving has been turned on
    --
    g_enable_archive_flag := NVL(fnd_profile.value('HRI_SET_EVENTS_ARCHIVE'),'N');
    --
    -- 3658545 The Events Collection process should populate the events queues
    -- based on the following profile
    --
    -- a) HRI:Populate Assignment Events Queue
    -- b) HRI:Populate Supervisor Hierarchy Events Queue
    -- c) HRI:Populate Supervisor Status History Events Queue
    --
    -- The process will only populate the queues for which the profile has been enabled.
    -- However, as the Supervisor Status History collection is dependent on assignment events
    -- fact table, even if HRI:Populate Assignment Events Queue profile has not been enabled
    -- the Assignment Events Queue will be populated.
    --
    --
    -- Get the profile value to determine which events queue is to be populated
    --
    g_col_asg_events_eq   := NVL(fnd_profile.value('HRI_COL_ASG_EVENTS_EQ'),'Y');
    g_col_sup_hrchy_eq    := NVL(fnd_profile.value('HRI_COL_SUP_HRCHY_EQ'),'Y');
    g_col_sup_hstry_eq    := NVL(fnd_profile.value('HRI_COL_SUP_STATUS_EQ'),'Y');
    g_col_absence_events_eq := NVL(fnd_profile.value('HRI_COL_ABSNCE_DIM_EQ'),'Y');
    --
    IF g_col_asg_events_eq = 'N' AND
       g_col_sup_hstry_eq = 'N'
    THEN
      --
      -- msg('Profile HRI:Populate Assignment Events Queue is not enabled.');
      -- msg('  Assignment Events queue will not be populated');
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407162_PRF_ASGEQ_IMPCT');
      fnd_message.set_token('PROFILE_NAME', 'HRI:Populate Assignment Events Queue');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
              ,p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_msg_group     => 'EVT_CPTR'
	      ,p_msg_sub_group => 'SET_PARAMETERS'
              ,p_sql_err_code  => SQLCODE);
      --
      msg(l_message);
      --
    END IF;
    --
    IF g_col_sup_hrchy_eq = 'N' THEN
      --
      -- msg('Profile HRI:Populate Supervisor Hierarchy Events Queue is not enabled.');
      -- msg('  Supervisor Hierarch Events queue will not be populated');
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407163_PRF_SUPH_EQ_IMPCT');
      fnd_message.set_token('PROFILE_NAME', 'HRI:Populate Supervisor Hierarchy Events Queue');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
              ,p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_msg_group     => 'EVT_CPTR'
              ,p_msg_sub_group => 'SET_PARAMETERS'
              ,p_sql_err_code  => SQLCODE);
      --
      msg(l_message);
      --
    END IF;
    --
    dbg('Start collection diagnostics ...');
    --
    IF g_col_sup_hstry_eq = 'N' THEN
      --
      -- msg('Profile HRI:Populate Supervisor Status History Events Queue is not enabled.');
      -- msg('  Supervisor Status History Events queue will not be populated');
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407164_PRF_SUPST_EQ_IMPCT');
      fnd_message.set_token('PROFILE_NAME', 'HRI:Populate Supervisor Status History Events Queue');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
              ,p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_msg_group     => 'EVT_CPTR'
              ,p_msg_sub_group => 'SET_PARAMETERS'
              ,p_sql_err_code  => SQLCODE);
      --
      msg(l_message);
      --
    ELSIF g_col_sup_hstry_eq  = 'Y' AND
          g_col_asg_events_eq = 'N'
    THEN
      --
      -- msg('Profile HRI:Populate Supervisor Status History Events Queue is enabled.');
      -- msg('  Assignment Events queue will also be populated');
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407293_PRF_SUPST_ENBLD');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
              ,p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_msg_group     => 'EVT_CPTR'
              ,p_msg_sub_group => 'SET_PARAMETERS'
              ,p_sql_err_code  => SQLCODE);
      --
      msg(l_message);
      --
    END IF;
    --
    IF g_col_absence_events_eq = 'N' THEN
      --
      -- msg('Profile HRI:Populate Absence Dimension Queue is not enabled.');
      -- msg('  Absence Events queue will not be populated');
      --
      fnd_message.set_name('HRI', 'HRI_407200_PRF_ABS_EQ_IMPCT');
      fnd_message.set_token('PROFILE_NAME', 'HRI:Populate Absence Dimension Queue');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_package_name  => 'HRI_OPL_EVENT_CAPTURE'
              ,p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_msg_group     => 'EVT_CPTR'
              ,p_msg_sub_group => 'SET_PARAMETERS'
              ,p_sql_err_code  => SQLCODE);
      --
      msg(l_message);
      --
    END IF;
    --
    dbg('Finished collection diagnostics ...');
    --
    IF g_col_sup_hstry_eq = 'Y' THEN
      --
      g_col_asg_events_eq := 'Y';
      --
    END IF;
    --
    -- If only Supervisor Hierachy events needs to be populated then set the master group
    -- as HRI_SUPERVISOR_EVENTS
    --
    dbg('Start setting up event groups ...');
    --
    IF g_col_sup_hrchy_eq  = 'Y' AND
       g_col_asg_events_eq = 'N' AND
       g_col_sup_hstry_eq  = 'N' AND
       g_col_absence_events_eq = 'N'
    THEN
      --
      dbg('Only supervisor events being collected ...');
      --
      g_master_event_group_id  := get_event_group_id('HRI_SUPERVISOR_EVENTS');
      --
      g_sprvsr_change_event_grp_id := get_event_group_id('HRI_SUPERVISOR_EVENTS');
      --
    ELSIF g_col_asg_events_eq = 'Y' AND
       g_col_sup_hrchy_eq  = 'N' AND
       g_col_sup_hstry_eq  = 'N' AND
       g_col_absence_events_eq = 'N'
    THEN
      --
      dbg('Only assignment events being collected ...');
      --
      g_master_event_group_id      := get_event_group_id('HRI_ASG_EVNTS_FCT');
      --
      g_assgnmnt_evnt_event_grp_id := get_event_group_id('HRI_ASG_EVNTS_FCT');
      --
    ELSIF g_col_absence_events_eq = 'Y' AND
       g_col_asg_events_eq = 'N' AND
       g_col_sup_hrchy_eq  = 'N' AND
       g_col_sup_hstry_eq  = 'N'
    THEN
      --
      dbg('Only absence events being collected ...');
      --
      g_master_event_group_id    := get_event_group_id('HRI_ABSENCE_EVENTS');
      --
      g_absence_dim_event_grp_id := get_event_group_id('HRI_ABSENCE_EVENTS');
      --
    ELSE
      --
      dbg('Do normal event group setup ...');
      --
      g_master_event_group_id      := get_event_group_id('HRI_ASG_MASTER_GROUP');
      --
      g_sprvsr_change_event_grp_id := get_event_group_id('HRI_SUPERVISOR_EVENTS');
      --
      g_assgnmnt_evnt_event_grp_id := get_event_group_id('HRI_ASG_EVNTS_FCT');
      --
      g_absence_dim_event_grp_id   := get_event_group_id('HRI_ABSENCE_EVENTS');
      --
      dbg('Finished doing normal event group setup ...');
      --
    END IF;
    --
    dbg('Finished setting up event groups ...');
    --
    -- Get the dates of the last refresh of this program
    --
    dbg('Get the dates of the last refresh of this program ...');
    --
    bis_collection_utilities.get_last_refresh_dates(
            c_object_name,
            l_bis_start_date,
            l_bis_end_date,
            l_period_from,
            l_period_to);
    --
    -- If the Events capture process has never been run before then the
    -- dates returned by bis_collection_utilities will be NULL, so we
    -- need to switch to full refresh mode.
    --
    dbg('Capture From Date: '||to_char(l_bis_start_date,'MM/DD/YYYY HH24:MI:SS')||'.');
    --
    IF l_bis_start_date  IS NULL
       OR
       l_period_to IS NULL
    THEN
      --
      -- Set indicator to show that full refresh has not been run,
      -- and so we need fail cleanly. This will be cause the HRI
      -- Multithreading process to end cleanly.
      --
      dbg('Setting indocators to show ull refresh has not been run.');
      --
      g_full_refresh_not_run := TRUE;
      g_full_refresh := 'Y';
      --
    ELSE
      --
      -- The start of this refresh should be the time at which the last one
      -- started running so that any changes made during the last run are
      -- picked up by this one. The end should be now
      --
      -- 3696594 changed the capture from date to be start_date of the
      -- last process
      --
      dbg('Setting g_capture_from_date to start date of last run.');
      --
      g_capture_from_date := l_bis_start_date;
      --
    END IF;
    --
    -- Get the dated table id of the non data tracked tables, this is used for
    -- determining the change to effective dates of non datetracked tables
    --
    dbg(' Get the dated table id of the non data tracked tables ...');
    --
    g_prd_of_srvc_table_id    := get_dated_table_id('PER_PERIODS_OF_SERVICE');
    g_appraisal_table_id      := get_dated_table_id('PER_APPRAISALS');
    g_perf_review_table_id    := get_dated_table_id('PER_PERFORMANCE_REVIEWS');
    g_asg_table_id            := get_dated_table_id('PER_ALL_ASSIGNMENTS_F');
    g_person_type_table_id    := get_dated_table_id('PER_PERSON_TYPE_USAGES_F');
    --
    -- 3906029 The event date to be populated in the supervisor hierarchy
    -- events queue should not be lesser than the last full refresh date
    -- or the minimum date in the hierarchy
    --
    g_min_suph_date := get_min_suph_date;
    --
    dbg('Store the parameter values for use by slave processes...');
    --
    UPDATE hri_adm_mthd_actions
    SET    full_refresh_flag = g_full_refresh,
           collect_from_date =  g_capture_from_date,
           attribute1  =  g_master_event_group_id,
           attribute2  =  g_assgnmnt_evnt_event_grp_id,
           attribute3  =  g_sprvsr_change_event_grp_id,
           attribute4  =  g_col_asg_events_eq,
           attribute5  =  g_col_sup_hrchy_eq,
           attribute6  =  g_col_sup_hstry_eq,
           attribute7  =  g_enable_archive_flag,
           attribute8  =  g_min_suph_date,
           attribute9  =  g_prd_of_srvc_table_id,
           attribute10 =  g_appraisal_table_id,
           attribute11 =  g_perf_review_table_id,
           attribute12 =  g_asg_table_id,
           attribute13 =  g_person_type_table_id          -- Dated table id of PER_PERSON_TYPE_USAGES_F
    WHERE  mthd_action_id = p_mthd_action_id;
    --
    dbg('Completed storing the parameter values for use by the slave processes ...');
    --
    COMMIT;
  --
  -- Parameters have already been set so don't need to be set again.
  --
  ELSIF (g_capture_from_date IS NULL) THEN
    --
    dbg('Set parameters has been called from a slave process. Retrieve '||
        'the parameter values.');
    --
    -- Populate the multithread action arrays
    --
    g_mthd_action_array := hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
    g_full_refresh      := 'N';
    --
    -- Populate the global variables
    --
    g_capture_from_date           := g_mthd_action_array.collect_from_date;
    g_master_event_group_id       := g_mthd_action_array.attribute1;
    g_assgnmnt_evnt_event_grp_id  := g_mthd_action_array.attribute2;
    g_sprvsr_change_event_grp_id  := g_mthd_action_array.attribute3;
    g_col_asg_events_eq           := g_mthd_action_array.attribute4;
    g_col_sup_hrchy_eq            := g_mthd_action_array.attribute5;
    g_col_sup_hstry_eq            := g_mthd_action_array.attribute6;
    g_enable_archive_flag         := g_mthd_action_array.attribute7;
    g_min_suph_date               := g_mthd_action_array.attribute8;
    --
    -- ID of table on which HRI PEM triggers can be created
    --
    g_prd_of_srvc_table_id        := g_mthd_action_array.attribute9;
    g_appraisal_table_id          := g_mthd_action_array.attribute10;
    g_perf_review_table_id        := g_mthd_action_array.attribute11;
    g_asg_table_id                := g_mthd_action_array.attribute12;
    g_person_type_table_id        := g_mthd_action_array.attribute13;
    --
    dbg('Finished retrieving parameter values.');
    --
  END IF;
  --
END set_parameters;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes all the logic required for performing the pre_process
-- task of HRI multithreading utility.
-- ----------------------------------------------------------------------------
--
PROCEDURE PRE_PROCESS(
--
  p_mthd_action_id              IN             NUMBER,
  p_sqlstr                                 OUT NOCOPY VARCHAR2) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
--
BEGIN
  --
  -- Set up the parameters
  --
  set_parameters( p_mthd_action_id  => p_mthd_action_id,
                  p_called_from     => 'PRE_PROCESS');
  --
  -- In case the process is running in a Foundation HR environment run
  -- the post_process to update the bis_refresh_log table and return without
  -- returning any SQL. The mulithreading utility will then not invoke the
  -- PROCESS_RANGES and POST_PROCESS calls
  --
  IF g_mthd_action_array.foundation_hr_flag = 'Y' THEN
    --
    -- This process is not supported in Shared HR mode, update the
    -- bis refresh log table and return. The multithreading utility
    -- does not do any processing if no SQL is returned
    --
    dbg('Foundation HR environment found');
    post_process (p_mthd_action_id => p_mthd_action_id);
    --
  ELSIF g_full_refresh = 'Y'
        OR g_full_refresh_not_run
  THEN
    --
    dbg('calling full refresh');
    --
    -- In case the process is running in full refresh mode, directly call the
    -- full_refresh procedure and return without returning any SQL. The mulithreading
    -- utility will then not invoke the PROCESS_RANGES and POST_PROCESS calls
    --
    full_refresh (p_refresh_to_date => NULL);
    --
  ELSIF (g_col_asg_events_eq = 'N' AND
         g_col_sup_hrchy_eq  = 'N' AND
         g_col_sup_hstry_eq  = 'N' AND
         g_col_absence_events_eq = 'N')
  THEN
    --
    -- The events queue profile have been set, so events are not to be collected.
    -- The multithreading utility does not do any processing if no SQL is returned
    --
    dbg('All the events queues profiles have been set to ''N''');
    post_process(p_mthd_action_id => p_mthd_action_id);
    --
  ELSE
    --
    -- The SELECT statement built up underneath populates the out parameter sqlstr
    -- which is used by the utility to generate the range of assignments to be
    -- processed.
    --
    -- This is the normal execution path when the process is run correctly
    -- after a full refresh.
    --
    -- Generate a SQL statement that SELECTs all of the DISTINCT assignments
    -- that have had events in the pay_process_events table, since the last
    -- incremental refresh.
    --
    -- 3703498 Added restriction so that only assignments with changes that are
    -- being tracked in the event group are processed
    --
    p_sqlstr :=
      'SELECT /*+ parallel(ppe , default, default) */ DISTINCT
             ppe.assignment_id object_id
       FROM  pay_process_events ppe
       WHERE ppe.creation_date
         BETWEEN to_date('''
           || to_char(g_capture_from_date, 'DD-MON-YYYY HH24:MI:SS')
                       || ''',''DD-MON-YYYY HH24:MI:SS'')
         AND     to_date('''
           || to_char(g_end_of_time, 'DD-MON-YYYY HH24:MI:SS')
                       || ''',''DD-MON-YYYY HH24:MI:SS'')
         AND    EXISTS (SELECT distinct event_update_id
                    FROM   pay_datetracked_events pde,
                           pay_event_updates      peu
                    WHERE  pde.event_group_id  = '||g_master_event_group_id||'
                    AND    pde.dated_table_id  = peu.dated_table_id
                    AND    ppe.event_update_id = peu.event_update_id )
       ORDER BY ppe.assignment_id';
    --
  END IF;
  --
  dbg(p_sqlstr);
  --
  -- 4357755
  -- The central refresh procedure should be initialized so that entries
  -- about the process are correctly inserted into the bis refresh log table
  -- This information is used to determine the start time of the next process.
  --
  hri_bpl_conc_log.record_process_start(c_object_name);
  --
  dbg('Exiting pre_process');
  --
END PRE_PROCESS;
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure is dynamically the HRI multithreading utility child threads
-- for processing the assignment ranges. The procedure manages the mulithreading
-- ranges and invokes the overloaded process_range procedure to process the
-- ranges.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_mthd_action_id            IN             NUMBER
  ,p_mthd_range_id             IN             NUMBER
  ,p_start_object_id           IN             NUMBER
  ,p_end_object_id             IN             NUMBER)
IS
  --
  l_error_step        NUMBER;
  l_mthd_range_id     NUMBER;
  l_start_object_id   NUMBER;
  l_end_object_id     NUMBER;
  --
BEGIN
  --
  dbg('Inside process_range');
  --
  set_parameters(p_mthd_action_id);
  --
  dbg('processing range='||p_mthd_range_id);
  --
  process_range(p_start_object_id    => p_start_object_id
                ,p_end_object_id     => p_end_object_id);
  --
  errbuf  := 'SUCCESS';
  retcode := 0;
  --
  dbg('Exiting process_range');
  --
EXCEPTION
  when others then
    dbg('Error at step '||l_error_step );
    msg(sqlerrm);
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    raise;
   --
END process_range;
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This is an overloaded procedure which is invoked by PROCESS_RANGE above.
-- For each of the assignment in the range, this procedure invokes the
-- capture_events process to populate the events queues
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(p_start_object_id   IN NUMBER
                       ,p_end_object_id     IN NUMBER )
IS
  --
  -- Cursor to get the assignment_id for assignment action for full refresh
  --
  CURSOR c_asg_to_process IS
  SELECT DISTINCT ppe.assignment_id
  FROM   pay_process_events ppe
  WHERE  assignment_id between p_start_object_id and p_end_object_id
  AND    ppe.creation_date BETWEEN g_capture_from_date and g_end_of_time
  AND    EXISTS (SELECT distinct event_update_id
                 FROM   pay_datetracked_events pde,
                        pay_event_updates      peu
                 WHERE  pde.event_group_id  =  g_master_event_group_id
                 AND    pde.dated_table_id  =  peu.dated_table_id
                 AND    ppe.event_update_id =  peu.event_update_id );
  --
  -- Holds assignment from the cursor
  --
  l_assignment_id     NUMBER;
  l_change_date       DATE;
  l_error_step        NUMBER;
  --
BEGIN
  --
  --
  --
  FOR l_asg_to_process in c_asg_to_process LOOP
    --
    -- For each of the
    --
    capture_events
       (p_assignment_id   => l_asg_to_process.assignment_id,
        p_start_date      => g_capture_from_date);
    --
  END LOOP;
  --
END process_range;
--
-- ----------------------------------------------------------------------------
-- POST_PROCESS
-- This procedure is dynamically invoked by the HRI Multithreading utility.
-- It finishes the processing by updating the BIS_REFRESH_LOG table
-- ----------------------------------------------------------------------------
--
PROCEDURE post_process (p_mthd_action_id NUMBER) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  --
--
BEGIN
  --
  dbg('Inside post_process');
  --
  set_parameters(p_mthd_action_id);
  --
  -- 4765258
  -- Update the supervisor history events queue with the supervisors
  -- to process
  --
  -- Also check snapshot facts for new snapshot dates
  -- and populate EQs accordingly
  --
  IF (g_full_refresh = 'N') THEN
    hri_opl_sup_status_hst.find_changed_supervisors;
    check_for_new_snapshot_dates;
  END IF;
  --
  -- 4357755
  -- Insert the details of the run in the bis refresh log table. This info is
  -- read used to set the start date of next run
  --
  hri_bpl_conc_log.log_process_end
    (
     p_status         => TRUE
    ,p_period_from    => g_capture_from_date
    ,p_period_to      => SYSDATE
    );
  --
  dbg('Exiting post_process ....');
  --
  commit;
  --
END post_process;
--
END HRI_OPL_EVENT_CAPTURE;

/
