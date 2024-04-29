--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUP_STATUS_HST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUP_STATUS_HST" AS
/* $Header: hrioshst.pkb 120.7 2006/12/13 10:34:17 jtitmas noship $ */
--
-- Information to be held for each link in a chain
--
g_chunk_size              PLS_INTEGER;
--
-- Stores current time
--
g_current_time            DATE;
--
-- End of time
--
g_end_of_time             DATE := hr_general.end_of_time;
--
-- Full or incremental refresh
--
g_run_mode                VARCHAR2(30);
--
-- ---------------------------------------------------------------------------
-- GLOBAL CONSTANTS
-- ---------------------------------------------------------------------------
--
c_OUTPUT_LINE_LENGTH    CONSTANT NUMBER := 255;
--
-- ---------------------------------------------------------------------------
-- PRIVATE GLOBALS
-- ---------------------------------------------------------------------------
--
-- Bug 4105868: global to store msg_sub_group
--
g_msg_sub_group           VARCHAR(400) := '';
--
-- ---------------------------------------------------------------------------
-- Procedure msg logs a message, either using fnd_file, or
-- hr_utility.trace
-- ---------------------------------------------------------------------------
--
PROCEDURE output(p_text IN VARCHAR2) IS
  --
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;
--
-- ---------------------------------------------------------------------------
-- Procedure dbg decides whether to log the passed in message
-- depending on whether debug mode is set.
-- ---------------------------------------------------------------------------
--
PROCEDURE dbg(p_text IN VARCHAR2) IS
  --
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- ---------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ---------------------------------------------------------------------------
--
PROCEDURE run_sql_stmt_noerr( p_sql_stmt   VARCHAR2 ) IS
  --
BEGIN
  --
  dbg('Inside run_sql_stmt_noerr');
  --
  EXECUTE IMMEDIATE p_sql_stmt;
  --
  dbg('Exiting run_sql_stmt_noerr');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Error running sql:');
    --
    dbg(SUBSTR(p_sql_stmt,1,230));
    --
    -- Bug 4105868: Collection Diagnostics
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'WARNING'
            ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
            ,p_msg_group     => 'SUP_STS_HST'
            ,p_msg_sub_group => 'RUN_SQL_STMT_NOERR'
            ,p_sql_err_code  => SQLCODE
            ,p_note          => SUBSTR(p_sql_stmt, 1, 3900)
            );
    --
END run_sql_stmt_noerr;
--
-- ---------------------------------------------------------------------------
-- Disables/drops indexes and triggers before process begins
-- ---------------------------------------------------------------------------
--
PROCEDURE disable_objects(p_schema       IN VARCHAR2,
                          p_object_name  IN VARCHAR2) IS
--
BEGIN
  --
  dbg('Inside disable_objects for ' || p_object_name);
  --
  run_sql_stmt_noerr('ALTER TRIGGER ' || p_object_name || '_WHO DISABLE');
  --
  -- Disable all the indexes on the table
  --
  hri_utl_ddl.log_and_drop_indexes
          (p_application_short_name => 'HRI'
          ,p_table_name             => p_object_name
          ,p_table_owner            => p_schema
          );
  --
  dbg('Exiting disable_objects');
--
END disable_objects;
--
-- ---------------------------------------------------------------------------
-- Disables/drops indexes and triggers before process begins
-- ---------------------------------------------------------------------------
--
PROCEDURE enable_objects(p_schema       IN VARCHAR2,
                         p_object_name  IN VARCHAR2) IS
--
BEGIN
  --
  dbg('Inside enable_objects for ' || p_object_name);
  --
  run_sql_stmt_noerr('ALTER TRIGGER ' || p_object_name || '_WHO ENABLE');
  --
  -- Recreate indexes
  --
  hri_utl_ddl.recreate_indexes
          (p_application_short_name => 'HRI'
          ,p_table_name             => p_object_name
          ,p_table_owner            => p_schema
          );
  --
  dbg('Inside enable_objects');
  --
END enable_objects;
--
-- ---------------------------------------------------------------------------
-- Collect the supervisor status history data
-- ---------------------------------------------------------------------------
--
PROCEDURE collect_data( p_collect_from    IN DATE,
                        p_collect_to      IN DATE) IS
  --
  l_end_of_time             DATE;
  l_user_id                 NUMBER;
  l_current_time            DATE;
  --
BEGIN
  --
  dbg('Inside collect_data');
  --
  -- Initialize variables
  --
  l_end_of_time             := hr_general.end_of_time;
  l_user_id                 := fnd_global.user_id;
  l_current_time            := SYSDATE;
  --
  -- This sql statement creates the supervisor status history records, which tells
  -- whether a person is a supervisor on a particular date or not
  -- The query works on the basis that a person's supervisory status
  -- can only change on dates when the his subordinate's assignment records
  -- are update for following reason
  --
  -- 1. A subordinate starts reporting
  -- 2. A subordinate is transfered out (from next day)
  -- 3. A subordinates primary assignment changes
  -- 4. A suboridnate is terminated (from next day)
  --
  -- Using the dates on which the above events occur to a person's subordinate
  -- we can determine if a person is a subordinate or not on that date (there
  -- won't be a per_system_status record for subordinate on that date)
  --
  INSERT /*+ APPEND */
  INTO   HRI_CL_WKR_SUP_STATUS_CT
         (person_id
         ,effective_start_date
         ,effective_end_date
         ,supervisor_flag
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date)
  SELECT chgs.person_id,
         chgs.effective_date effective_start_date,
         least(nvl((LEAD(chgs.effective_date, 1)
                    OVER (PARTITION BY chgs.person_id
                    ORDER BY chgs.effective_date)) - 1,
                    chgs.termination_date),
                    chgs.termination_date)     effective_end_date,
         decode(chgs.leaf_indicator,1,'N','Y'),
         l_current_time,
         l_user_id,
         l_user_id,
         l_user_id,
         l_current_time
  FROM   --
         -- Calculate supervisory status (leaf node) status for every person on any particular date
         -- Use an analytic function to get previous leaf node status
         --
         (SELECT /*+ USE_HASH(asg ast leaf_date) */
                 leaf_date.event_supervisor_id   person_id,
                 leaf_date.effective_date       effective_date,
                 NVL(pos.actual_termination_date, l_end_of_time) termination_date,
                 --
                 -- If there is no asg status reporting to a person then he is not a
                 -- supervisor
                 --
                 DECODE(MIN(ast.per_system_status), null, 1, 0)            leaf_indicator,
                 --
                 -- The leaf_indicator_prev column returns a person's supervisory status
                 -- on a previous effective date. However when a person has been re-hired
                 -- and if the records are not contiguous. Then two records should be
                 -- created even if his supervisory status is unchanged.
                 -- We don't want his records for duration he was not there
                 -- with the organization
                 --
                 CASE WHEN  leaf_date.effective_date - 1  =
                      NVL(LAG(pos.actual_termination_date,1) OVER (PARTITION BY leaf_date.event_supervisor_id
                      ORDER BY leaf_date.effective_date), l_end_of_time)
                 THEN
                   --
                   -- 4099447 When the person is rehired the next day, then two records
                   -- two different records should be created. Return the leaf_indicator_prev
                   -- as null
                   --
                   NULL
                 WHEN leaf_date.effective_date - 1  BETWEEN
                       LAG(leaf_date.effective_date ,1)
                          OVER (PARTITION BY leaf_date.event_supervisor_id
                          ORDER BY leaf_date.effective_date)
                       AND  LAG(NVL(pos.actual_termination_date, l_end_of_time),1)
                          OVER (PARTITION BY leaf_date.event_supervisor_id
                          ORDER BY leaf_date.effective_date)
                 THEN
                   --
                   -- records are contiguous. Return the prev_leaf_indicator status
                   --
                   LAG(DECODE(MIN(ast.per_system_status), null, 1, 0),1)
                            OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                 ELSE
                   --
                   -- previous records and current record is not contiguous
                   -- return null. So that the present record does not get
                   -- filtered out.
                   --
                   null
                 END leaf_indicator_prev,
                 NVL(pos.actual_termination_date, l_end_of_time)
           FROM  (--
                  -- Using a inline view as oracle doesn't like outer joins with in clause..
                  --
                  SELECT supervisor_id,
                         effective_start_date,
                         effective_end_date,
                         assignment_status_type_id
                  FROM   per_all_assignments_f
                  WHERE  assignment_type in ('E','C')
                  AND    primary_flag = 'Y'
                 ) asg,
                 per_assignment_status_types ast,
                 (select person_id,
                         date_start,
                         actual_termination_date
                  from   per_periods_of_service
                  UNION ALL
                  select person_id,
		         date_start,
		         actual_termination_date
                  from   per_periods_of_placement
                 )pos,
                 (--
                 -- This gets all supervisors whose subordinates have had events that
                 -- can affects his supervisory status
                 --
                 SELECT CASE WHEN WORKER_TERM_IND = 1 THEN
                 --
                 -- For the termination records get the person's
                 -- previous supervisor_id, as the supervisor_id
                 -- is set to -1
                 --
                          evt.supervisor_prv_id
                        ELSE
                          evt.supervisor_id
                        END event_supervisor_id,
                        evt.effective_change_date effective_date
                 FROM   hri_mb_asgn_events_ct evt
                 WHERE  (
                          (--
                           -- get only those asg records which have had a
                           -- change in supervisor
                           --
                           supervisor_change_ind = 1
                           --
                           -- or change in the primary assignment
                           --
                           OR primary_flag <> primary_flag_prv
                           --
                           -- or if the event record is a retrospective
                           -- record
                           --
                           OR asg_rtrspctv_strt_event_ind = 1
                          )
                         AND     evt.supervisor_id <> -1
                         )
                 AND     PRIMARY_FLAG = 'Y'
                 UNION
                 --
                 -- The Previous query will only get the assignment events records
                 -- for Transfer In. But Transfer Out's also affect a person's
                 -- supervisory status. Get all the transfer out events
                 --
                 SELECT evt.supervisor_prv_id  event_supervisor_id,
                        evt.effective_change_date effective_date
                 FROM   hri_mb_asgn_events_ct evt
                 WHERE  (
                          (
                            (supervisor_change_ind = 1
                             OR worker_term_ind = 1
                            )
                            AND     primary_flag = 'Y'
                          )
                          OR
                          (evt.primary_flag_prv='Y'
                           AND evt.primary_flag='N'
                           )
                         )
                 AND     evt.supervisor_prv_id <> -1
                 UNION
                 --
                 -- Gets all active person's
                 --
                 SELECT pos.person_id,
                        GREATEST(p_collect_from,pos.date_start)
                 FROM   per_periods_of_service pos
                 WHERE  (p_collect_from BETWEEN pos.date_start AND NVL(pos.actual_termination_date, hr_general.end_of_time)
                         OR p_collect_from <= pos.date_start)
                 --
                 -- Gets all active contingent workers
                 --
                 UNION
                 SELECT pop.person_id,
                        GREATEST(p_collect_from,pop.date_start)
                 FROM   per_periods_of_placement pop
                 WHERE  (p_collect_from BETWEEN pop.date_start AND NVL(pop.actual_termination_date, hr_general.end_of_time)
                         OR p_collect_from <= pop.date_start)
                 )leaf_date
          WHERE  leaf_date.event_supervisor_id = asg.supervisor_id (+)
          AND    leaf_date.event_supervisor_id = pos.person_id
          AND    leaf_date.effective_date BETWEEN pos.date_start
                                          AND NVL(pos.actual_termination_date, l_end_of_time)
          AND    ast.assignment_status_type_id (+) = asg.assignment_status_type_id
          AND    ast.per_system_status (+) <> 'TERM_ASSIGN'
          AND    leaf_date.effective_date BETWEEN asg.effective_start_date (+) AND asg.effective_end_date (+)
          GROUP BY leaf_date.event_supervisor_id, leaf_date.effective_date, pos.actual_termination_date
         )chgs
  WHERE  (chgs.leaf_indicator <> NVL(chgs.leaf_indicator_prev, -1));
  --
  dbg('Exiting collect_data');
  --
  -- Bug 4105868: Collection Diagnostics
  --
-- EXCEPTION
  --
--   WHEN OTHERS THEN
   --
--    g_msg_sub_group := NVL(g_msg_sub_group, 'COLLECT_DATA');
   --
--    RAISE;
   --
  --
END collect_data;
--
-- ---------------------------------------------------------------------------
-- Collect the supervisor status history data for incremental refresh
-- ---------------------------------------------------------------------------
--
PROCEDURE collect_incremental_data IS
  --
  l_end_of_time             DATE;
  l_start_date              DATE;
  l_user_id                 NUMBER;
  l_current_time            DATE;
  --
BEGIN
  --
  dbg('Inside collect_incremental_data');
  --
  -- Initialize variables
  --
  l_end_of_time             := hr_general.end_of_time;
  l_start_date              := hri_bpl_parameter.get_bis_global_start_date;
  l_user_id                 := fnd_global.user_id;
  l_current_time            := SYSDATE;
  --
  INSERT /*+ APPEND */
  INTO   hri_cl_wkr_sup_status_ct
         (person_id
         ,effective_start_date
         ,effective_end_date
         ,supervisor_flag
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date
         )
  SELECT chgs.person_id,
         chgs.effective_date effective_start_date,
         least(nvl((LEAD(chgs.effective_date, 1)
                    OVER (PARTITION BY chgs.person_id
                    ORDER BY chgs.effective_date)) - 1,
                    chgs.termination_date),
                    chgs.termination_date)     effective_end_date,
         decode(chgs.leaf_indicator,1,'N','Y'),
         l_current_time,
         l_user_id,
         l_user_id,
         l_user_id,
         l_current_time
  FROM   --
         -- Calculate supervisory status (leaf node) status for every person on any particular date
         -- Use an analytic function to get previous leaf node status
         --
         (SELECT /*+ USE_HASH(asg ast leaf_date) */
                 leaf_date.event_supervisor_id   person_id,
                 leaf_date.effective_date       effective_date,
                 NVL(pos.actual_termination_date, l_end_of_time) termination_date,
                 --
                 -- If there is no asg status reporting to a person then he is not a
                 -- supervisor
                 --
                 DECODE(MIN(ast.per_system_status), null, 1, 0)            leaf_indicator,
                 --
                 -- The leaf_indicator_prev column returns a person's supervisory status
                 -- on a previous effective date. However when a person has been re-hired
                 -- and if the records are not contiguous. Then two records should be
                 -- created even if his supervisory status is unchanged.
                 -- We don't want his records for duration he was not there
                 -- with the organization
                 --
                 CASE WHEN  leaf_date.effective_date - 1  =
                      NVL(LAG(pos.actual_termination_date,1) OVER (PARTITION BY leaf_date.event_supervisor_id
                      ORDER BY leaf_date.effective_date), l_end_of_time)
                 THEN
                   --
                   -- 4099447 When the person is rehired the next day, then two records
                   -- two different records should be created. Return the leaf_indicator_prev
                   -- as null
                   --
                   NULL
                 WHEN leaf_date.effective_date - 1  BETWEEN
                      LAG(leaf_date.effective_date ,1)
                             OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                      AND  LAG(NVL(pos.actual_termination_date, l_end_of_time),1)
                              OVER (PARTITION BY leaf_date.event_supervisor_id
                              ORDER BY leaf_date.effective_date)
                 THEN
                   --
                   -- records are contiguous. Return the prev_leaf_indicator status
                   --
                   LAG(DECODE(MIN(ast.per_system_status), null, 1, 0),1)
                            OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                 ELSE
                 --
                 -- previous records and current record is not contiguous
                 -- return null. So that the present record does not get
                 -- filtered out.
                 --
                 null
                 END leaf_indicator_prev,
                 NVL(pos.actual_termination_date, l_end_of_time)
          FROM   (--
                  -- Using a inline view as oracle doesn't like outer joins with in clause..
                  --
                  SELECT supervisor_id,
                         effective_start_date,
                         effective_end_date,
                         assignment_status_type_id
                  FROM   per_all_assignments_f
                  WHERE  assignment_type in ('E','C')
                  AND    primary_flag = 'Y'
                 ) asg,
                 per_assignment_status_types ast,
                 --
                 -- CWK Change
                 --
                 (select pos.person_id,
                         pos.date_start,
                         pos.actual_termination_date
                  from   per_periods_of_service pos,
                         hri_eq_sprvsr_hstry_chgs eq
                  where  eq.person_id=pos.person_id
                  UNION ALL
                  select pop.person_id,
		         pop.date_start,
		         pop.actual_termination_date
                  from   per_periods_of_placement pop,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pop.person_id
                 )pos,
                 (--
                  -- This gets all supervisors whose subordinates have had events that
                  -- can affects his supervisory status
                  --
                  SELECT CASE WHEN WORKER_TERM_IND = 1 THEN
                  --
                  -- For the termination records get the person's
                  -- previous supervisor_id, as the supervisor_id
                  -- is set to -1
                  --
                         evt.supervisor_prv_id
                         ELSE
                         evt.supervisor_id
                         END event_supervisor_id,
                         evt.effective_change_date effective_date
                   FROM  hri_mb_asgn_events_ct evt,
                         hri_eq_sprvsr_hstry_chgs eq
                   WHERE (
                           (--
                            -- get only those asg records which have had a
                            -- change in supervisor
                            --
                            supervisor_change_ind = 1
                            --
                            -- or change in the primary assignment
                            --
                            OR primary_flag <> primary_flag_prv
                            --
                            -- or if the event record is a retrospective
                            -- record
                            --
                            OR asg_rtrspctv_strt_event_ind = 1
                           )
                           AND evt.supervisor_id <> -1
                         )
                  AND    PRIMARY_FLAG = 'Y'
                  AND    eq.person_id=evt.supervisor_id
                  UNION
                  --
                  -- The Previous query will only get the assignment events records
                  -- for Transfer In. But Transfer Out's also affect a person's
                  -- supervisory status. Get all the transfer out events
                  --
                  SELECT evt.supervisor_prv_id  event_supervisor_id,
                         evt.effective_change_date effective_date
                  FROM   hri_mb_asgn_events_ct evt,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  (
                           (
                             (supervisor_change_ind = 1
                              OR worker_term_ind = 1
                              )
                           AND     primary_flag = 'Y'
                           )
                         OR
                           (evt.primary_flag_prv='Y'
                            AND evt.primary_flag='N'
                           )
                         )
                  AND    evt.supervisor_prv_id <> -1
                  AND    eq.person_id = evt.supervisor_prv_id
                  UNION
                  --
                  -- Gets all active person's
                  --
                  SELECT pos.person_id,
                         GREATEST(hri_bpl_parameter.get_bis_global_start_date
                                 ,pos.date_start)
                  FROM   per_periods_of_service pos,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pos.person_id
                  UNION
                  --
                  -- Gets all active placements
                  --
                  SELECT pop.person_id,
                         GREATEST(hri_bpl_parameter.get_bis_global_start_date
                                 ,pop.date_start)
                  FROM   per_periods_of_placement pop,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pop.person_id
                ) leaf_date
          WHERE   leaf_date.event_supervisor_id = asg.supervisor_id (+)
          AND     leaf_date.event_supervisor_id = pos.person_id
          AND     leaf_date.effective_date BETWEEN pos.date_start
                                           AND NVL(pos.actual_termination_date, l_end_of_time)
          AND     ast.assignment_status_type_id (+) = asg.assignment_status_type_id
          AND     ast.per_system_status (+) <> 'TERM_ASSIGN'
          AND     leaf_date.effective_date BETWEEN asg.effective_start_date (+) AND asg.effective_end_date (+)
          GROUP BY leaf_date.event_supervisor_id, leaf_date.effective_date, pos.actual_termination_date
         )chgs
  WHERE  (chgs.leaf_indicator <> NVL(chgs.leaf_indicator_prev, -1));
  --
  dbg('Exiting collect_incremental_data');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'COLLECT_INCREMENTAL_DATA');
    --
    RAISE;
    --
  --
end collect_incremental_data;
--
-- ---------------------------------------------------------------------------
-- Collect the supervisor status history data
-- ---------------------------------------------------------------------------
--
PROCEDURE collect_asg_data( p_collect_from    IN DATE,
                            p_collect_to      IN DATE) IS
  --
  l_end_of_time             DATE;
  l_user_id                 NUMBER;
  l_current_time            DATE;
  --
BEGIN
  --
  dbg('Inside collect_asg_data');
  --
  -- Initialize variables
  --
  l_end_of_time             := hr_general.end_of_time;
  l_user_id                 := fnd_global.user_id;
  l_current_time            := SYSDATE;
  --
  -- This sql statement creates the supervisor status history records, which tells
  -- whether a person is a supervisor on a particular date or not
  -- The query works on the basis that a person's supervisory status
  -- can only change on dates when the his subordinate's assignment records
  -- are update for following reason
  --
  -- 1. A subordinate starts reporting
  -- 2. A subordinate is transfered out (from next day)
  -- 3. A subordinates primary assignment changes
  -- 4. A suboridnate is terminated (from next day)
  --
  -- Using the dates on which the above events occur to a person's subordinate
  -- we can determine if a person is a subordinate or not on that date (there
  -- won't be a per_system_status record for subordinate on that date)
  --
  INSERT /*+ APPEND */
  INTO   HRI_CL_WKR_SUP_STATUS_ASG_CT
         (person_id
         ,effective_start_date
         ,effective_end_date
         ,supervisor_flag
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date)
  SELECT chgs.person_id,
         chgs.effective_date effective_start_date,
         least(nvl((LEAD(chgs.effective_date, 1)
                    OVER (PARTITION BY chgs.person_id
                    ORDER BY chgs.effective_date)) - 1,
                    chgs.termination_date),
                    chgs.termination_date)     effective_end_date,
         decode(chgs.leaf_indicator,1,'N','Y'),
         l_current_time,
         l_user_id,
         l_user_id,
         l_user_id,
         l_current_time
  FROM   --
         -- Calculate supervisory status (leaf node) status for every person on any particular date
         -- Use an analytic function to get previous leaf node status
         --
         (SELECT /*+ USE_HASH(asg ast leaf_date) */
                 leaf_date.event_supervisor_id   person_id,
                 leaf_date.effective_date       effective_date,
                 NVL(pos.actual_termination_date, l_end_of_time) termination_date,
                 --
                 -- If there is no asg status reporting to a person then he is not a
                 -- supervisor
                 --
                 DECODE(MIN(ast.per_system_status), null, 1, 0)            leaf_indicator,
                 --
                 -- The leaf_indicator_prev column returns a person's supervisory status
                 -- on a previous effective date. However when a person has been re-hired
                 -- and if the records are not contiguous. Then two records should be
                 -- created even if his supervisory status is unchanged.
                 -- We don't want his records for duration he was not there
                 -- with the organization
                 --
                 CASE WHEN  leaf_date.effective_date - 1  =
                      NVL(LAG(pos.actual_termination_date,1) OVER (PARTITION BY leaf_date.event_supervisor_id
                      ORDER BY leaf_date.effective_date), l_end_of_time)
                 THEN
                   --
                   -- 4099447 When the person is rehired the next day, then two records
                   -- two different records should be created. Return the leaf_indicator_prev
                   -- as null
                   --
                   NULL
                 WHEN leaf_date.effective_date - 1  BETWEEN
                       LAG(leaf_date.effective_date ,1)
                          OVER (PARTITION BY leaf_date.event_supervisor_id
                          ORDER BY leaf_date.effective_date)
                       AND  LAG(NVL(pos.actual_termination_date, l_end_of_time),1)
                          OVER (PARTITION BY leaf_date.event_supervisor_id
                          ORDER BY leaf_date.effective_date)
                 THEN
                   --
                   -- records are contiguous. Return the prev_leaf_indicator status
                   --
                   LAG(DECODE(MIN(ast.per_system_status), null, 1, 0),1)
                            OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                 ELSE
                   --
                   -- previous records and current record is not contiguous
                   -- return null. So that the present record does not get
                   -- filtered out.
                   --
                   null
                 END leaf_indicator_prev,
                 NVL(pos.actual_termination_date, l_end_of_time)
           FROM  (--
                  -- Using a inline view as oracle doesn't like outer joins with in clause..
                  --
                  SELECT supervisor_id,
                         effective_start_date,
                         effective_end_date,
                         assignment_status_type_id
                  FROM   per_all_assignments_f
                  WHERE  assignment_type in ('E','C')
                 ) asg,
                 per_assignment_status_types ast,
                 (select person_id,
                         date_start,
                         actual_termination_date
                  from   per_periods_of_service
                  UNION ALL
                  select person_id,
                         date_start,
                         actual_termination_date
                  from   per_periods_of_placement
                 )pos,
                 (--
                 -- This gets all supervisors whose subordinates have had events that
                 -- can affects his supervisory status
                 --
                 SELECT evt.supervisor_id         event_supervisor_id,
                        evt.effective_change_date effective_date
                 FROM   hri_mb_asgn_events_ct evt
                 WHERE  (worker_hire_ind = 1
                      OR post_hire_asgn_start_ind = 1
                      OR supervisor_change_ind = 1
                      OR asg_rtrspctv_strt_event_ind = 1)
                 AND     evt.supervisor_id <> -1
                 UNION
                 --
                 -- The Previous query will only get the assignment events records
                 -- for Transfer In. But Transfer Out's also affect a person's
                 -- supervisory status. Get all the transfer out events
                 --
                 SELECT evt.supervisor_prv_id  event_supervisor_id,
                        evt.effective_change_date effective_date
                 FROM   hri_mb_asgn_events_ct evt
                 WHERE  (supervisor_change_ind = 1
                      OR worker_term_ind = 1
                      OR pre_sprtn_asgn_end_ind = 1)
                 AND     evt.supervisor_prv_id <> -1
                 UNION
                 --
                 -- Gets all active employees
                 --
                 SELECT pos.person_id, GREATEST(p_collect_from,pos.date_start)
                 FROM   per_periods_of_service pos
                 WHERE  (p_collect_from BETWEEN pos.date_start
                                        AND NVL(pos.actual_termination_date, hr_general.end_of_time)
                         OR p_collect_from <= pos.date_start)
                 --
                 -- Gets all active contingent workers
                 --
                 UNION
                 SELECT pop.person_id, GREATEST(p_collect_from,pop.date_start)
                 FROM   per_periods_of_placement pop
                 WHERE  (p_collect_from BETWEEN pop.date_start
                                        AND NVL(pop.actual_termination_date, hr_general.end_of_time)
                         OR p_collect_from <= pop.date_start)
                 )leaf_date
          WHERE leaf_date.event_supervisor_id = asg.supervisor_id (+)
          AND leaf_date.event_supervisor_id = pos.person_id
          AND leaf_date.effective_date BETWEEN pos.date_start
                                       AND NVL(pos.actual_termination_date, l_end_of_time)
          AND ast.assignment_status_type_id (+) = asg.assignment_status_type_id
          AND ast.per_system_status (+) <> 'TERM_ASSIGN'
          AND leaf_date.effective_date BETWEEN asg.effective_start_date (+)
                                       AND asg.effective_end_date (+)
          GROUP BY
           leaf_date.event_supervisor_id
          ,leaf_date.effective_date
          ,pos.actual_termination_date
         )  chgs
  WHERE  (chgs.leaf_indicator <> NVL(chgs.leaf_indicator_prev, -1));
  --
  dbg('Exiting collect_asg_data');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
   --
   g_msg_sub_group := NVL(g_msg_sub_group, 'COLLECT_DATA');
   --
   RAISE;
   --
  --
END collect_asg_data;
--
-- ---------------------------------------------------------------------------
-- Collect the supervisor status history data for incremental refresh
-- ---------------------------------------------------------------------------
--
PROCEDURE collect_asg_incremental_data IS
  --
  l_end_of_time             DATE;
  l_start_date              DATE;
  l_user_id                 NUMBER;
  l_current_time            DATE;
  --
BEGIN
  --
  dbg('Inside collect_asg_incremental_data');
  --
  -- Initialize variables
  --
  l_end_of_time             := hr_general.end_of_time;
  l_start_date              := hri_bpl_parameter.get_bis_global_start_date;
  l_user_id                 := fnd_global.user_id;
  l_current_time            := SYSDATE;
  --
  INSERT /*+ APPEND */
  INTO   hri_cl_wkr_sup_status_asg_ct
         (person_id
         ,effective_start_date
         ,effective_end_date
         ,supervisor_flag
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date
         )
  SELECT chgs.person_id,
         chgs.effective_date effective_start_date,
         least(nvl((LEAD(chgs.effective_date, 1)
                    OVER (PARTITION BY chgs.person_id
                    ORDER BY chgs.effective_date)) - 1,
                    chgs.termination_date),
                    chgs.termination_date)     effective_end_date,
         decode(chgs.leaf_indicator,1,'N','Y'),
         l_current_time,
         l_user_id,
         l_user_id,
         l_user_id,
         l_current_time
  FROM   --
         -- Calculate supervisory status (leaf node) status for every person on any particular date
         -- Use an analytic function to get previous leaf node status
         --
         (SELECT /*+ USE_HASH(asg ast leaf_date) */
                 leaf_date.event_supervisor_id   person_id,
                 leaf_date.effective_date       effective_date,
                 NVL(pos.actual_termination_date, l_end_of_time) termination_date,
                 --
                 -- If there is no asg status reporting to a person then he is not a
                 -- supervisor
                 --
                 DECODE(MIN(ast.per_system_status), null, 1, 0)            leaf_indicator,
                 --
                 -- The leaf_indicator_prev column returns a person's supervisory status
                 -- on a previous effective date. However when a person has been re-hired
                 -- and if the records are not contiguous. Then two records should be
                 -- created even if his supervisory status is unchanged.
                 -- We don't want his records for duration he was not there
                 -- with the organization
                 --
                 CASE WHEN  leaf_date.effective_date - 1  =
                      NVL(LAG(pos.actual_termination_date,1) OVER (PARTITION BY leaf_date.event_supervisor_id
                      ORDER BY leaf_date.effective_date), l_end_of_time)
                 THEN
                   --
                   -- 4099447 When the person is rehired the next day, then two records
                   -- two different records should be created. Return the leaf_indicator_prev
                   -- as null
                   --
                   NULL
                 WHEN leaf_date.effective_date - 1  BETWEEN
                      LAG(leaf_date.effective_date ,1)
                             OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                      AND  LAG(NVL(pos.actual_termination_date, l_end_of_time),1)
                              OVER (PARTITION BY leaf_date.event_supervisor_id
                              ORDER BY leaf_date.effective_date)
                 THEN
                   --
                   -- records are contiguous. Return the prev_leaf_indicator status
                   --
                   LAG(DECODE(MIN(ast.per_system_status), null, 1, 0),1)
                            OVER (PARTITION BY leaf_date.event_supervisor_id
                            ORDER BY leaf_date.effective_date)
                 ELSE
                 --
                 -- previous records and current record is not contiguous
                 -- return null. So that the present record does not get
                 -- filtered out.
                 --
                 null
                 END leaf_indicator_prev,
                 NVL(pos.actual_termination_date, l_end_of_time)
          FROM   (--
                  -- Using a inline view as oracle doesn't like outer joins with in clause..
                  --
                  SELECT supervisor_id,
                         effective_start_date,
                         effective_end_date,
                         assignment_status_type_id
                  FROM   per_all_assignments_f
                  WHERE  assignment_type in ('E','C')
                 ) asg,
                 per_assignment_status_types ast,
                 --
                 -- CWK Change
                 --
                 (select pos.person_id,
                         pos.date_start,
                         pos.actual_termination_date
                  from   per_periods_of_service pos,
                         hri_eq_sprvsr_hstry_chgs eq
                  where  eq.person_id=pos.person_id
                  UNION ALL
                  select pop.person_id,
		         pop.date_start,
		         pop.actual_termination_date
                  from   per_periods_of_placement pop,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pop.person_id
                 )pos,
                 (--
                  -- This gets all supervisors whose subordinates have had events that
                  -- can affects his supervisory status
                  --
                  SELECT evt.supervisor_id          event_supervisor_id,
                         evt.effective_change_date  effective_date
                  FROM  hri_mb_asgn_events_ct evt,
                        hri_eq_sprvsr_hstry_chgs eq
                  WHERE (worker_hire_ind = 1
                      OR post_hire_asgn_start_ind = 1
                      OR supervisor_change_ind = 1
                      OR asg_rtrspctv_strt_event_ind = 1)
                  AND     evt.supervisor_id <> -1
                  AND    eq.person_id=evt.supervisor_id
                  UNION
                  --
                  -- The Previous query will only get the assignment events records
                  -- for Transfer In. But Transfer Out's also affect a person's
                  -- supervisory status. Get all the transfer out events
                  --
                  SELECT evt.supervisor_prv_id  event_supervisor_id,
                         evt.effective_change_date effective_date
                  FROM   hri_mb_asgn_events_ct evt,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  (supervisor_change_ind = 1
                       OR worker_term_ind = 1
                       OR pre_sprtn_asgn_end_ind = 1)
                  AND    evt.supervisor_prv_id <> -1
                  AND    eq.person_id = evt.supervisor_prv_id
                  UNION
                  --
                  -- Gets all active person's
                  --
                  SELECT pos.person_id,
                         GREATEST(hri_bpl_parameter.get_bis_global_start_date
                                 ,pos.date_start)
                  FROM   per_periods_of_service pos,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pos.person_id
                  UNION
                  --
                  -- Gets all active placements
                  --
                  SELECT pop.person_id,
                         GREATEST(hri_bpl_parameter.get_bis_global_start_date
                                 ,pop.date_start)
                  FROM   per_periods_of_placement pop,
                         hri_eq_sprvsr_hstry_chgs eq
                  WHERE  eq.person_id=pop.person_id
                ) leaf_date
          WHERE   leaf_date.event_supervisor_id = asg.supervisor_id (+)
          AND     leaf_date.event_supervisor_id = pos.person_id
          AND     leaf_date.effective_date BETWEEN pos.date_start
                                           AND NVL(pos.actual_termination_date, l_end_of_time)
          AND     ast.assignment_status_type_id (+) = asg.assignment_status_type_id
          AND     ast.per_system_status (+) <> 'TERM_ASSIGN'
          AND     leaf_date.effective_date BETWEEN asg.effective_start_date (+)
                                           AND asg.effective_end_date (+)
          GROUP BY
           leaf_date.event_supervisor_id
          ,leaf_date.effective_date
          ,pos.actual_termination_date
         )   chgs
  WHERE  (chgs.leaf_indicator <> NVL(chgs.leaf_indicator_prev, -1));
  --
  dbg('Exiting collect_asg_incremental_data');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'COLLECT_INCREMENTAL_DATA');
    --
    RAISE;
    --
  --
end collect_asg_incremental_data;
--
-- ---------------------------------------------------------------------------
-- This procedure populates the person_id column in hri_eq_sprvsr_hstry_chgs
-- by using the value of assignment_id
-- ---------------------------------------------------------------------------
--
PROCEDURE update_event_queue IS
--
BEGIN
  --
  dbg('Inside update_event_queue');
  --
  UPDATE hri_eq_sprvsr_hstry_chgs  eq
  SET    person_id = (SELECT   person_id
                      FROM     per_all_assignments_f asg
                      WHERE    eq.assignment_id=asg.assignment_id
                      AND      rownum=1
                      );
  --
  dbg('Exiting update_event_queue');
  --
--
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('An error occured while updating events queue records.');
    output(sqlerrm);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'UPDATE_EVENT_QUEUE');
    --
    RAISE;
    --
  --
END update_event_queue;
--
-- ---------------------------------------------------------------------------
-- When an assignment event occurs the following need to be processed
-- as they can potentially have a changed status
--   A - any previously connected supervisor of the assignment from
--       the event date forwards
--       (e.g. assignment event is last subordinate transferring out)
--   B - any connected supervisor of the assignment from the event
--       date forwards
--       (e.g. assignment event is a new hire for a first time supervisor)
--   C - the assignment person, if the event is a start, end or purge
--       (to create, end date or purge the person's status)
-- ---------------------------------------------------------------------------
--
PROCEDURE find_changed_supervisors IS
  --
BEGIN
  --
  dbg('Finding changed supervisors');
  --
  dbg('Calling update_event_queue');
  --
  update_event_queue;
  --
  dbg('Case A');
  --
  -- Insert previous supervisors
  -- NOTE - THIS MUST BE CALLED BEFORE hri_mb_asgn_events_ct IS REFRESHED
  --
  INSERT /*+ APPEND */ INTO hri_eq_sprvsr_hstry_chgs
   (person_id
   ,erlst_evnt_effective_date
   ,source_code)
  SELECT DISTINCT
   evt.supervisor_id
  ,eq.erlst_evnt_effective_date
  ,'DERIVED'
  FROM
   hri_eq_sprvsr_hstry_chgs  eq
  ,hri_mb_asgn_events_ct     evt
  WHERE eq.assignment_id = evt.assignment_id
  AND evt.effective_change_end_date >= eq.erlst_evnt_effective_date
  AND eq.source_code IS NULL
  AND NOT EXISTS
   (SELECT null
    FROM hri_eq_sprvsr_hstry_chgs eq2
    WHERE eq2.person_id = evt.supervisor_id);
  --
  dbg(sql%rowcount||' old supervisors found and added to the change list.');
  --
  dbg(' ');
  dbg('Case B');
  --
  -- Insert current supervisors
  --
  INSERT /*+ APPEND */ INTO hri_eq_sprvsr_hstry_chgs
   (person_id
   ,erlst_evnt_effective_date
   ,source_code)
  SELECT DISTINCT
   asg.supervisor_id
  ,eq.erlst_evnt_effective_date
  ,'DERIVED'
  FROM
   hri_eq_sprvsr_hstry_chgs  eq
  ,per_all_assignments_f     asg
  WHERE eq.assignment_id = asg.assignment_id
  AND asg.effective_start_date >= eq.erlst_evnt_effective_date
  AND eq.source_code IS NULL
  AND NOT EXISTS
   (SELECT null
    FROM hri_eq_sprvsr_hstry_chgs eq2
    WHERE eq2.person_id = asg.supervisor_id);
  --
  dbg(sql%rowcount||' new supervisors found and added to the change list.');
  --
  dbg(' ');
  dbg('Case C');
  --
  -- Delete original records where there is no hire or termination
  -- after the event date
  --
  DELETE FROM hri_eq_sprvsr_hstry_chgs eq
  WHERE eq.source_code IS NULL
  AND eq.person_id IN
   (SELECT
     pps.person_id
    FROM
     hri_eq_sprvsr_hstry_chgs eq2
    ,per_periods_of_service   pps
    WHERE eq2.person_id = pps.person_id
    AND pps.date_start <> eq2.erlst_evnt_effective_date
    AND pps.actual_termination_date IS NULL);
  --
  dbg(sql%rowcount||' redundant employee assignment changes removed');
  --
  DELETE FROM hri_eq_sprvsr_hstry_chgs eq
  WHERE eq.source_code IS NULL
  AND eq.person_id IN
   (SELECT
     ppp.person_id
    FROM
     hri_eq_sprvsr_hstry_chgs eq2
    ,per_periods_of_placement ppp
    WHERE eq2.person_id = ppp.person_id
    AND ppp.date_start <> eq2.erlst_evnt_effective_date
    AND ppp.actual_termination_date IS NULL);
  --
  dbg(sql%rowcount||' redundant contingent worker assignment changes removed');
  --
  COMMIT;
  --
  dbg(' ');
  dbg('Exiting find_changed_supervisors');
  --
  RETURN;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('An error occured while adding records to the change list.');
    output(sqlerrm);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FIND_CHANGED_SUPERVISORS');
    --
    RAISE;
    --
END find_changed_supervisors;
--
-- ---------------------------------------------------------------------------
-- This procedure deletes the supervisor status history for people whose
-- supervisory status will changes due to events that have happened
-- to be subordinates
-- ---------------------------------------------------------------------------
--
PROCEDURE delete_old_supervisor_status IS
--
BEGIN
  --
  dbg('Inside delete_old_supervisor_status');
  --
        --
        DELETE HRI_CL_WKR_SUP_STATUS_CT
        WHERE  person_id in (SELECT      person_id
                             FROM        hri_eq_sprvsr_hstry_chgs
                             );
        --
  --
  dbg('Exiting delete_old_supervisor_status');
  --
--
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('An error occured while deleteing old supervisor status records.');
    output(sqlerrm);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'DELETE_OLD_SUPERVISOR_STATUS');
    --
    RAISE;
    --
  --
END delete_old_supervisor_status;
--
-- ---------------------------------------------------------------------------
-- This procedure deletes the supervisor status history for people whose
-- supervisory status will changes due to events that have happened
-- to be subordinates (secondary asg version)
-- ---------------------------------------------------------------------------
--
PROCEDURE delete_asg_supervisor_status IS
--
BEGIN
  --
  dbg('Inside delete_asg_supervisor_status');
  --
        --
        DELETE HRI_CL_WKR_SUP_STATUS_ASG_CT
        WHERE  person_id in (SELECT      person_id
                             FROM        hri_eq_sprvsr_hstry_chgs
                             );
        --
  --
  dbg('Exiting delete_asg_supervisor_status');
  --
--
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('An error occured while deleteing asg supervisor status records.');
    output(sqlerrm);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'DELETE_OLD_SUPERVISOR_STATUS');
    --
    RAISE;
    --
  --
END delete_asg_supervisor_status;
--
-- ---------------------------------------------------------------------------
-- Main entry point to reload the supervisor status history
-- ---------------------------------------------------------------------------
--
PROCEDURE full_refresh(p_start_date  IN DATE
                      ,p_end_date    IN DATE
                      )
IS
--
  l_sql_stmt                   VARCHAR2(2000);
  l_dummy1                     VARCHAR2(2000);
  l_dummy2                     VARCHAR2(2000);
  l_schema                     VARCHAR2(400);
  l_effective_start_date       DATE;
--
BEGIN
  --
  dbg('Inside full_refresh');
  --
  -- Initialize variables
  --
  l_effective_start_date       := p_start_date;
  --
  -- Time at start
  dbg('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Get HRI schema name - get_app_info populates l_schema
  --
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    --
    -- Set start time
    --
    g_current_time := SYSDATE;
    --
    --
    --Insert new supervisor status history records for DBI
    --
    IF fnd_profile.value('HRI_IMPL_DBI') = 'Y' THEN
      --
      -- Disable/drop objects (indexes and triggers)
      --
      disable_objects(p_schema      => l_schema,
                      p_object_name => 'HRI_CL_WKR_SUP_STATUS_CT');
      --
      dbg('Disabled/dropped objects:   '  || to_char(sysdate,'HH24:MI:SS'));
      --
      -- Empty out supervisor hierarchy history table
      --
      l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CL_WKR_SUP_STATUS_CT';
      EXECUTE IMMEDIATE(l_sql_stmt);
      --
      -- Write timing information to log
      --
      dbg('Truncated Supervisor Status History table: ' ||to_char(sysdate,'HH24:MI:SS'));
      --
      collect_data (p_collect_from => TRUNC(l_effective_start_date) ,
                    p_collect_to   => TRUNC(p_end_date));
      dbg('Re-populated Supervisor History table: '  || to_char(sysdate,'HH24:MI:SS'));
      --
      -- Re-enable/recreate objects
      --
      enable_objects(p_schema      => l_schema,
                     p_object_name => 'HRI_CL_WKR_SUP_STATUS_CT');
      dbg('Re-enabled/recreated objects:  '  || to_char(sysdate,'HH24:MI:SS'));
      --
    END IF;
    --
    --Insert new supervisor status history records for OBIEE
    --
    IF fnd_profile.value('HRI_IMPL_OBIEE') = 'Y' THEN
      --
      -- Disable/drop objects (indexes and triggers)
      --
      run_sql_stmt_noerr('ALTER TRIGGER HRI_CL_WKR_SUP_STATUS_ASG_WHO DISABLE');
      --
      hri_utl_ddl.log_and_drop_indexes
          (p_application_short_name => 'HRI'
          ,p_table_name             => 'HRI_CL_WKR_SUP_STATUS_ASG_CT'
          ,p_table_owner            => l_schema);
      --
      dbg('Disabled/dropped objects:   '  || to_char(sysdate,'HH24:MI:SS'));
      --
      -- Empty out supervisor hierarchy history table
      --
      l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CL_WKR_SUP_STATUS_ASG_CT';
      EXECUTE IMMEDIATE(l_sql_stmt);
      --
      -- Write timing information to log
      --
      dbg('Truncated Supervisor Status History table: ' ||to_char(sysdate,'HH24:MI:SS'));
      --
      collect_asg_data (p_collect_from => TRUNC(l_effective_start_date) ,
                        p_collect_to   => TRUNC(p_end_date));
      dbg('Re-populated Supervisor History table (secondary): '  || to_char(sysdate,'HH24:MI:SS'));
      --
      -- Re-enable/recreate objects
      --
      run_sql_stmt_noerr('ALTER TRIGGER HRI_CL_WKR_SUP_STATUS_ASG_WHO ENABLE');
      --
      hri_utl_ddl.recreate_indexes
          (p_application_short_name => 'HRI'
          ,p_table_name             => 'HRI_CL_WKR_SUP_STATUS_ASG_CT'
          ,p_table_owner            => l_schema);
      --
      dbg('Re-enabled/recreated objects:  '  || to_char(sysdate,'HH24:MI:SS'));
      --
      -- Gather index stats
      --
      fnd_stats.gather_table_stats(l_schema, 'HRI_CL_WKR_SUP_STATUS_ASG_CT');
      --
    END IF;
    --
    -- Purge the events queue
    --
    HRI_OPL_EVENT_CAPTURE.purge_queue('HRI_EQ_SPRVSR_HSTRY_CHGS');
    --
    -- Write timing information to log
    dbg('Gathered stats:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
  ELSE
    --
    dbg('HRI not installed');
    --
  END IF;
  --
  dbg('Exiting full_refresh');
  --
  -- Bug 4105868: Collection Diagnostics
  --
-- EXCEPTION
  --
--   WHEN OTHERS THEN
    --
--     g_msg_sub_group := NVL(g_msg_sub_group, 'FULL_REFRESH');
    --
--     RAISE;
    --
END full_refresh;
--
-- ---------------------------------------------------------------------------
-- Incremental Update Process Entry Point
-- p_start_date - is the earliest update date of assignment record
-- p_end_date   - is the latest update date of assignment record
-- ---------------------------------------------------------------------------
--
PROCEDURE incremental_update( p_start_date    IN DATE,
                              p_end_date      IN DATE) IS
  --
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_dummy1                      VARCHAR2(2000);
  l_dummy2                      VARCHAR2(2000);
  l_schema                      VARCHAR2(400);
  --
BEGIN
  --
  dbg('Inside incremental_update');
  --
  -- Initialize variables
  --
  l_effective_start_date        := p_start_date;
  l_effective_end_date          := p_end_date;
  --
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    --
    dbg('Starting incremental Update ...');
    --
    g_run_mode := 'INCREMENTAL';
    --
    -- Time at start
    --
    dbg('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));
    --
    -- Set start time
    --
    g_current_time := SYSDATE;
    --
    IF fnd_profile.value('HRI_IMPL_DBI') = 'Y' THEN
      --
      -- Delete the status records of people whose status could have changed
      --
      dbg('Calling delete_old_supervisor_status...');
      delete_old_supervisor_status;
      --
      -- Insert Changed Records
      --
      dbg('Calling collect_incremental_data...');
      --
      collect_incremental_data;
      --
    END IF;
    --
    IF fnd_profile.value('HRI_IMPL_OBIEE') = 'Y' THEN
      --
      -- Delete the status records of people whose status could have changed
      --
      dbg('Calling delete_asg_supervisor_status...');
      delete_asg_supervisor_status;
      --
      -- Insert Changed Records
      --
      dbg('Calling collect_incremental_data...');
      --
      collect_asg_incremental_data;
      --
    END IF;
    --
    -- Purge the events queue
    --
    HRI_OPL_EVENT_CAPTURE.purge_queue('HRI_EQ_SPRVSR_HSTRY_CHGS');
    --
    -- Write timing information to log
    --
    dbg('Incremental supervisor status history collection completed successfully at '  ||
           to_char(sysdate,'HH24:MI:SS')||'.');
     --
  ELSE
     dbg('HRI not installed');
  END IF;
  --
  dbg('Exiting incremental_update');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'INCREMENTAL_UPDATE');
    --
    RAISE;
    --
END incremental_update;
--
-- ---------------------------------------------------------------------------
-- This procedure will be called by the Concurrent Manager for running
-- the full refresh collection program
-- ---------------------------------------------------------------------------
--
PROCEDURE full_refresh( errbuf          OUT  NOCOPY VARCHAR2,
                        retcode         OUT  NOCOPY VARCHAR2,
                        p_start_date    IN VARCHAR2,
                        p_end_date      IN VARCHAR2,
                        p_debugging     IN VARCHAR2 DEFAULT 'N')
IS
--
  l_start_date            DATE;
  l_end_date              DATE;
  l_is_hr_installed       VARCHAR2(10);
  l_frc_shrd_hr_prfl_val  VARCHAR2(30); -- Variable to store value for
                                        -- Profile HRI:DBI Force Shared HR Processes
  --
BEGIN
  --
  hri_bpl_conc_log.record_process_start('HRI_CL_WKR_SUP_STATUS_CT');
  --
  l_is_hr_installed      := hr_general.chk_product_installed(800);
  l_frc_shrd_hr_prfl_val := nvl(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');
  --
  IF l_is_hr_installed = 'FALSE'
     OR l_frc_shrd_hr_prfl_val = 'Y' THEN
    --
    l_start_date := TRUNC(SYSDATE);
    l_end_date   := hr_general.end_of_time;
    --
    IF l_is_hr_installed = 'FALSE' THEN
      --
      dbg('Foundation HR detected. Defaulting '||
             'collection to run from SYSDATE to end of time.');
      --
    ELSE
      --
      dbg('Profile HRI:DBI Force Foundation HR Processes has been set. '||
             'Forcing the collection to run from SYSDATE to end of time.');
      --
    END IF;
    --
  --
  -- If Full HR is installed
  --
  ELSE
    --
    -- Set dates
    --
    l_start_date := TRUNC(fnd_date.canonical_to_date(p_start_date));
    l_end_date   := TRUNC(fnd_date.canonical_to_date(p_end_date));
    --
  END IF;
  --
  dbg('start date = '||to_char(l_start_date,'DD-MON-RRRR HH24:MI:SS'));
  dbg('end date   = '||to_char(l_end_date,'DD-MON-RRRR HH24:MI:SS'));
  full_refresh( p_start_date    => l_start_date,
                p_end_date      => l_end_date);
  --
  -- Bug 4105868: Collection Diagnostic Call
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => TRUNC(l_start_date)
          ,p_period_to      => TRUNC(l_end_date)
          ,p_attribute1     => p_debugging);
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    ROLLBACK;
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    output(SQLERRM);
    --
    dbg('Supervisor Status History collection failed at '  ||
            to_char(sysdate,'HH24:MI:SS')||'.');
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FULL_REFRESH');
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_note          => SQLERRM
            ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE
            ,p_msg_group     => 'SUP_STS_HST');
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => TRUNC(l_start_date)
            ,p_period_to      => TRUNC(l_end_date)
            ,p_attribute1     => p_debugging);
    --
    RAISE;
    --
  --
END full_refresh;
--
-- ---------------------------------------------------------------------------
-- This procedure will be called by the Concurrent Manager to run the
-- incrmental collection process
-- ---------------------------------------------------------------------------
--
PROCEDURE incremental_update( errbuf          OUT NOCOPY VARCHAR2,
                              retcode         OUT NOCOPY VARCHAR2,
                              p_debugging     IN VARCHAR2 DEFAULT 'N') IS
--
  l_start_date            DATE ;
  l_end_date              DATE ;
  l_bis_start_date        DATE;
  l_bis_end_date          DATE;
  l_period_from           DATE;
  l_period_to             DATE;
  l_is_hr_installed       VARCHAR2(10);
  l_frc_shrd_hr_prfl_val  VARCHAR2(30); -- Variable to store value for
                                        -- Profile HRI:DBI Force Shared HR Processes
--
BEGIN
  --
  hri_bpl_conc_log.record_process_start('HRI_CL_WKR_SUP_STATUS_CT');
  --
  -- If Full HR has not been installed or if profile HRI:DBI Force Shared HR
  -- Processes has been set, then the force the process to run in
  -- full refresh mode and from SYSDATE
  --
  l_is_hr_installed      := hr_general.chk_product_installed(800);
  l_frc_shrd_hr_prfl_val := nvl(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');
  --
  IF l_is_hr_installed = 'FALSE'
     OR l_frc_shrd_hr_prfl_val = 'Y'
  THEN
  --
    --
    -- Insert the appropriate message in the log file
    --
    IF l_is_hr_installed = 'FALSE' THEN
    --
      dbg('HR not installed on this instance, defaulting the full refresh of '||
             'the process to run with following parameters');
    --
    ELSIF l_frc_shrd_hr_prfl_val = 'Y' THEN
    --
      dbg('Profile HRI:DBI Force Shared HR Processes has been set. '||
             'Forcing the full refresh of the process to run with following parameters');
    --
    END IF;
    --
    l_start_date       := trunc(SYSDATE);
    l_end_date         := hr_general.end_of_time;
    --
    dbg('Collect From Date   : '||l_start_date);
    dbg('Collect To Date     : '||l_end_date);
    --
    full_refresh( p_start_date    => l_start_date,
                  p_end_date      => l_end_date);
    --
  --
  ELSE
  --
    --
    -- get the last run dates
    --
    bis_collection_utilities.get_last_refresh_dates('HRI_CL_WKR_SUP_STATUS_CT'
                                                    ,l_bis_start_date
                                                    ,l_bis_end_date
                                                    ,l_period_from
                                                    ,l_period_to);
    --
    l_start_date       := TRUNC(l_period_to) + 1;
    l_end_date         := TRUNC(SYSDATE);
    --
    dbg('start date = '||to_char(l_start_date,'DD-MON-RRRR HH24:MI:SS'));
    dbg('end date = '||to_char(l_end_date,'DD-MON-RRRR HH24:MI:SS'));
    --
    incremental_update( p_start_date    => l_start_date,
                        p_end_date      => l_end_date);
    --
  --
  END IF;
  --
  -- Bug 4105868: Collection Diagnostic Call
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => TRUNC(l_start_date)
          ,p_period_to      => TRUNC(l_end_date)
          ,p_attribute1     => p_debugging);
  --
  COMMIT;
  --
EXCEPTION
--
  WHEN OTHERS  THEN
  --
    ROLLBACK;
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    output(SQLERRM);
    --
    dbg('Incremental Supervisor Status History collection failed at '  ||
            to_char(sysdate,'HH24:MI:SS')||'.');
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'INCREMENTAL_UPDATE');
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_note          => SQLERRM
            ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE
            ,p_msg_group     => 'SUP_STS_HST');
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => TRUNC(l_start_date)
            ,p_period_to      => TRUNC(l_end_date)
            ,p_attribute1     => p_debugging);
    --
    RAISE;
    --
--
END;
--
-- ---------------------------------------------------------------------------
-- This procedure will be called by the Concurrent Manager for running
-- the full or incremental refresh
-- ---------------------------------------------------------------------------
--
PROCEDURE run_request (errbuf          OUT  NOCOPY VARCHAR2,
                       retcode         OUT  NOCOPY VARCHAR2,
                       p_start_date    IN VARCHAR2,
                       p_end_date      IN VARCHAR2,
                       p_full_refresh  IN VARCHAR2,
                       p_debugging     IN VARCHAR2 DEFAULT 'N') IS
--
  l_start_date             DATE;
  l_end_date               DATE;
  l_is_hr_installed        VARCHAR2(10);
  l_full_refresh           VARCHAR2(10);
  l_frc_shrd_hr_prfl_val   VARCHAR2(30);
  l_message                fnd_new_messages.message_text%TYPE;
--
BEGIN
  --
  dbg('Inside run_request');
  --
  hri_bpl_conc_log.record_process_start('HRI_CL_WKR_SUP_STATUS_CT');
  --
  -- Determine if the process needs to be run in Foundation HR mode
  --
  l_is_hr_installed      := hr_general.chk_product_installed(800);
  l_frc_shrd_hr_prfl_val := nvl(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');
  --
  l_end_date   := fnd_date.canonical_to_date(p_end_date);
  --
  IF l_is_hr_installed = 'FALSE'
     OR l_frc_shrd_hr_prfl_val = 'Y'
  THEN
    --
    -- Run the process in Foundation HR Mode, default the start date to sysdate and run
    -- full refresh
    --
    l_full_refresh := 'Y';
    l_start_date := trunc(SYSDATE);
    --
    -- Insert the appropriate message in the log file
    --
    IF l_is_hr_installed = 'FALSE' THEN
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407287_FNDTN_HR_INSTLD');
      --
      fnd_message.set_token('START_DATE', l_start_date);
      fnd_message.set_token('END_DATE', l_end_date);
      fnd_message.set_token('FULL_REFRESH', l_full_refresh);
      --
      l_message := nvl(fnd_message.get, SQLERRM);
      --
      hri_bpl_conc_log.log_process_info
              (p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
              ,p_msg_sub_group => 'RUN_REQUEST'
              ,p_sql_err_code  => SQLCODE
              ,p_msg_group     => 'SUP_STS_HST'
              );
      --
      output(l_message);
      --
      -- output('HR not installed on this instance, defaulting the process '||
      --       'to run with following parameters');
      --
    ELSIF l_frc_shrd_hr_prfl_val = 'Y' THEN
      --
      -- Bug 4105868: Collection Diagnostics
      --
      fnd_message.set_name('HRI', 'HRI_407159_PRF_SHRD_IMPCT');
      --
      fnd_message.set_token('PROFILE_NAME', 'HRI:DBI Force Foundation HR Processes');
      --
      l_message := fnd_message.get;
      --
      hri_bpl_conc_log.log_process_info
              (p_msg_type      => 'WARNING'
              ,p_note          => l_message
              ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
              ,p_msg_sub_group => 'RUN_REQUEST'
              ,p_sql_err_code  => SQLCODE
              ,p_msg_group     => 'SUP_STS_HST');
      --
      output(l_message);
      --
      -- output('Profile HRI:DBI Force Foundation HR Processes has been set. '||
      --       'Forcing the full refresh of the process to run with following parameters');
      --
    END IF;
      --
  ELSE
    --
    IF (p_full_refresh IS NULL) THEN
      l_full_refresh := hri_oltp_conc_param.get_parameter_value
                         (p_parameter_name => 'FULL_REFRESH',
                          p_process_table_name => 'HRI_CL_WKR_SUP_STATUS_CT');
      IF (l_full_refresh = 'Y') THEN
        l_start_date := hri_oltp_conc_param.get_date_parameter_value
                         (p_parameter_name => 'FULL_REFRESH_FROM_DATE',
                          p_process_table_name => 'HRI_CL_WKR_SUP_STATUS_CT');
      ELSE
        l_start_date := fnd_date.canonical_to_date(p_start_date);
      END IF;
    ELSE
      l_full_refresh := p_full_refresh;
      l_start_date   := fnd_date.canonical_to_date(p_start_date);
    END IF;
    --
  END IF;
  --
  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   ' || l_start_date);
  --
  IF (l_full_refresh = 'Y') THEN
    --
    dbg('Calling full refresh of supervisor status history');
    --
    hri_opl_sup_status_hst.full_refresh(p_start_date  => l_start_date
                                       ,p_end_date    => l_end_date);
    --
  ELSE
    --
    dbg('Calling incremental update of supervisor status history');
    --
    hri_opl_sup_status_hst.incremental_update(p_start_date => l_start_date
                                             ,p_end_date   => l_end_date);
    --
  END IF;
  --
  -- Bug 4105868: Collection Diagnostic Call
  --
  hri_bpl_conc_log.log_process_end(
          p_status         => TRUE,
          p_period_from    => TRUNC(l_start_date),
          p_period_to      => TRUNC(l_end_date),
          p_attribute1     => p_full_refresh);
  --
  COMMIT;
  --
  dbg('Exiting run_request');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
    output(SQLERRM);
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'RUN_REQUEST');
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_note          => SQLERRM
            ,p_package_name  => 'HRI_OPL_SUP_STATUS_HST'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE
            ,p_msg_group     => 'SUP_STS_HST');
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => TRUNC(l_start_date)
            ,p_period_to      => TRUNC(l_end_date)
            ,p_attribute1     => p_full_refresh);
    --
    RAISE;
  --
--
END run_request;
--
END HRI_OPL_SUP_STATUS_HST;

/
