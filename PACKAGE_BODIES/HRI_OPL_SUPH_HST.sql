--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUPH_HST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUPH_HST" AS
/* $Header: hrioshh.pkb 120.18 2007/01/02 13:58:59 jtitmas noship $ */
/******************************************************************************/
/*                                                                            */
/* OUTLINE / DEFINITIONS                                                      */
/*                                                                            */
/* A chain is defined for an employee as a list starting with the employee    */
/* which contains their supervisor, and successive higher level supervisors   */
/* finishing with the highest level (overall) supervisor.                     */
/*                                                                            */
/* Each chain is valid for the length of time it describes the supervisor     */
/* hierarchy between the employee it is defined for and the overall           */
/* supervisor in the hierarchy.                                               */
/*                                                                            */
/* The supervisor hierarchy table implements each link in the chain as a      */
/* row with the employee the chain is defined for as the subordinate. The     */
/* absolute levels refer to absolute positions within the overall hierarchy   */
/* whereas the relative level refers to the difference in the absolute levels */
/* for the row.                                                               */
/*                                                                            */
/* When an employee changes supervisor, their chain must change since their   */
/* immediate supervisor is different. However, the chains of all that         */
/* employee's subordinates must also change because a chain consists of       */
/* each higher level supervisor up to and including the overall supervisor.   */
/*                                                                            */
/* IMPLEMENTATION LOGIC                                                       */
/*                                                                            */
/* The supervisor hierarchy history table is populated by carrying out the    */
/* following steps using the multi-threading wrapper
/*                                                                            */
/*  Pre-process (single-thread)                                               */
/*  ===========================                                               */
/*  1) Update event queue (incremental only)                                  */
/*  2) Empty out existing table (all or queued supervisors)                   */
/*  3) End date chains for queued supervisors (incremental only)              */
/*  4) Remove indexes (full refresh only)                                     */
/*  5) Disable WHO trigger                                                    */
/*                                                                            */
/*  Main collection (multi-thread by person)                                  */
/*  ========================================                                  */
/*  1) Set first date to sample management chain as later of person hire      */
/*     or refresh from date                                                   */
/*  2) Loop through sample dates:                                             */
/*      i) Insert links in chain when there is a change in supervisor,        */
/*         assignment, levels or orphan status.                               */
/*     ii) Retain the next sample date as the earliest date any link in       */
/*         the sampled chain has the next supervisor change event             */
/*  3) Exit the loop when either:                                             */
/*      i) No data is found - person has been terminated on the previous date */
/*     ii) Sample date hits end of time - no further changes                  */
/*  4) Ensure PL/SQL table of rows to insert is fully updated and execute     */
/*     the bulk insert                                                        */
/*                                                                            */
/*  Post-process (single-thread)                                              */
/*  ============================                                              */
/*  1) Recreate indexes (full refresh only)                                   */
/*  2) Enable WHO trigger                                                     */
/*                                                                            */
/*  Data Structures                                                           */
/*  ===============                                                           */
/*  A chain cache table stores information about each link in the chain. It   */
/*  is indexed by link level. It should be well maintained (i.e. links are    */
/*  removed when no longer required). The person being processed will always  */
/*  be the last link in the chain.                                            */
/*                                                                            */
/*  Error handling                                                            */
/*  ==============                                                            */
/*                                                                            */
/*  Orphans (no exception raised)                                             */
/*  -----------------------------                                             */
/*  If the management chain is sampled and it is found that the top manager   */
/*  has a supervisor assigned then the chain is said to be orphaned.          */
/*                                                                            */
/*  If the supervisor of the top manager has been terminated, it is possible  */
/*  they may be re-hired. This should be taken into account when deciding     */
/*  which date to next sample the hierarchy.                                  */
/*                                                                            */
/*  Loops (exception explicitly trapped)                                      */
/*  ------------------------------------                                      */
/*  When a loop is encountered the person being processed is deemed an orphan */
/*  (since no management chain can be found for them).                        */
/*                                                                            */
/*  They are then treated as an orphan but the chain resampled at regular     */
/*  intervals up to system date in case the data is fixed at a later date.    */
/*                                                                            */
/*  Other errors (not trapped)                                                */
/*  --------------------------                                                */
/*  Other errors are not handled.                                             */
/******************************************************************************/

-- Information to be held for each link in a chain
TYPE g_link_record_type IS RECORD
  (chain_id            NUMBER
  ,person_id           per_all_assignments_f.person_id%TYPE
  ,assignment_id       per_all_assignments_f.assignment_id%TYPE
  ,business_group_id   per_all_assignments_f.business_group_id%TYPE
  ,asg_status_type_id  per_all_assignments_f.assignment_status_type_id%TYPE
  ,start_date          DATE
  ,relative_level      PLS_INTEGER
  ,orphan_flag         VARCHAR2(30));

-- Information relating to transfers
TYPE g_trn_rec_type IS RECORD
 (node_exists_before  BOOLEAN
 ,node_exists_after   BOOLEAN
 ,node_direct_before  NUMBER
 ,node_direct_after   NUMBER);

-- Table type to hold information about the current chain
TYPE g_chain_type IS TABLE OF g_link_record_type INDEX BY BINARY_INTEGER;

-- Table tpye to hold transfer information
TYPE g_trn_tab_type IS TABLE OF g_trn_rec_type INDEX BY BINARY_INTEGER;

-- Simple table types
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- PLSQL table of tables representing database table
g_suph_sup_psn_id         g_number_tab_type;
g_suph_sup_asg_id         g_number_tab_type;
g_suph_sup_ast_id         g_number_tab_type;
g_suph_sup_level          g_number_tab_type;
g_suph_sup_bgr_id         g_number_tab_type;
g_suph_sup_sub1_psn_id    g_number_tab_type;
g_suph_sup_sub2_psn_id    g_number_tab_type;
g_suph_sup_sub3_psn_id    g_number_tab_type;
g_suph_sup_sub4_psn_id    g_number_tab_type;
g_suph_sub_psn_id         g_number_tab_type;
g_suph_sub_asg_id         g_number_tab_type;
g_suph_sub_level          g_number_tab_type;
g_suph_sub_bgr_id         g_number_tab_type;
g_suph_sub_rlt_lvl        g_number_tab_type;
g_suph_sub_chain_id       g_number_tab_type;
g_suph_start_date         g_date_tab_type;
g_suph_end_date           g_date_tab_type;
g_suph_orphan_flg         g_varchar2_tab_type;
g_suph_row_count          PLS_INTEGER;

-- PLSQL table of tables representing database table
g_chn_psn_id              g_number_tab_type;
g_chn_asg_id              g_number_tab_type;
g_chn_start_date          g_date_tab_type;
g_chn_end_date            g_date_tab_type;
g_chn_chain_id            g_number_tab_type;
g_chn_psn_lvl             g_number_tab_type;
g_chn_row_count           PLS_INTEGER;

-- PLSQL table of tables representing database table
g_trn_sup_psn_id          g_number_tab_type;
g_trn_sup_sc_fk           g_number_tab_type;
g_trn_psn_id              g_number_tab_type;
g_trn_ref_id              g_number_tab_type;
g_trn_asg_id              g_number_tab_type;
g_trn_wty_fk              g_varchar2_tab_type;
g_trn_date                g_date_tab_type;
g_trn_in_ind              g_number_tab_type;
g_trn_out_ind             g_number_tab_type;
g_trn_dir_ind             g_number_tab_type;
g_trn_dir_rec             g_number_tab_type;
g_trn_sec_asg_ind         g_number_tab_type;
g_trn_hdc_trn             g_number_tab_type;
g_trn_fte_trn             g_number_tab_type;
g_trn_row_count           PLS_INTEGER;

-- Global time variables
g_current_time            DATE;
g_end_of_time             DATE := hr_general.end_of_time;

-- Whether OBIEE is implemented
g_implement_obiee         VARCHAR2(30);

-- Whether to print debug messages
g_debug                   BOOLEAN := FALSE;
g_log_sup_loop            BOOLEAN;

-- Global HRI Multithreading Array
g_mthd_action_array       HRI_ADM_MTHD_ACTIONS%rowtype;

-- Global parameters
g_refresh_start_date      DATE;
g_full_refresh            VARCHAR2(30);
g_load_helper_table       VARCHAR2(30);

-- DBI global start date
g_dbi_collection_start_date DATE := TRUNC(TO_DATE(fnd_profile.value
                                     ('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY'));

-- Bug 4105868: Global to store msg_sub_group
g_msg_sub_group          VARCHAR2(400);

-- Write to log
PROCEDURE output(p_message  IN VARCHAR2) IS

BEGIN
  HRI_BPL_CONC_LOG.output(p_message);
END output;

-- Write to log if debugging is set
PROCEDURE debug(p_message IN VARCHAR2) IS

BEGIN
  HRI_BPL_CONC_LOG.dbg(p_message);
END debug;

-- Get the supervisor loop message
FUNCTION get_sup_loop_message(p_message         IN VARCHAR2,
                              p_effective_date  IN DATE,
                              p_person_id       IN VARCHAR2)
       RETURN VARCHAR2 IS

  CURSOR person_name_csr IS
  SELECT full_name
  FROM per_people_x
  WHERE person_id = p_person_id;

  l_person_name   VARCHAR2(240);

BEGIN

  -- Get person name
  OPEN person_name_csr;
  FETCH person_name_csr INTO l_person_name;
  CLOSE person_name_csr;

  -- Set message parameters
  fnd_message.set_name('HRI', p_message);
  fnd_message.set_token('DATE',to_char(p_effective_date, 'YYYY/MM/DD'));
  fnd_message.set_token('PERSON_NAME',l_person_name);

  -- Get the message and return it
  RETURN fnd_message.get;

END get_sup_loop_message;


-- ----------------------------------------------------------------------------
-- Adds change records to workforce events fact event queue
-- ----------------------------------------------------------------------------
PROCEDURE populate_wrkfc_evt_eq IS

BEGIN

  IF g_implement_obiee = 'Y' THEN

    -- Insert assignments with manager who have had chain changes
    -- to workforce event fact queue
    INSERT INTO hri_eq_wrkfc_evt
     (assignment_id
     ,erlst_evnt_effective_date
     ,source_code)
      SELECT /*+ ORDERED */
       wevt.asg_assgnmnt_fk
      ,eq.erlst_evnt_effective_date
      ,'ASG_MGR_' || eq.source_code
      FROM
       hri_eq_sprvsr_hrchy_chgs  eq
      ,hri_mb_wrkfc_evt_ct       wevt
      WHERE wevt.time_day_evt_end_fk >= eq.erlst_evnt_effective_date
      AND wevt.per_person_mgr_fk = eq.person_id;

    INSERT INTO hri_eq_wrkfc_mnth
     (assignment_id
     ,erlst_evnt_effective_date
     ,source_code)
      SELECT /*+ ORDERED */
       wevt.asg_assgnmnt_fk
      ,eq.erlst_evnt_effective_date
      ,'ASG_MGR_' || eq.source_code
      FROM
       hri_eq_sprvsr_hrchy_chgs  eq
      ,hri_mb_wrkfc_evt_ct       wevt
      WHERE wevt.time_day_evt_end_fk >= eq.erlst_evnt_effective_date
      AND wevt.per_person_mgr_fk = eq.person_id;

    -- commit
    COMMIT;

  END IF;

END populate_wrkfc_evt_eq;


-- ----------------------------------------------------------------------------
-- Adds change records to workforce events by manager summary event queue
-- ----------------------------------------------------------------------------
PROCEDURE populate_wrkfc_evt_mgrh_eq IS

BEGIN

  IF g_implement_obiee = 'Y' THEN

    INSERT INTO hri_eq_wrkfc_evt_mgrh
     (sup_person_id
     ,erlst_evnt_effective_date
     ,source_code)
      SELECT
       person_id
      ,erlst_evnt_effective_date
      ,source_code
      FROM hri_eq_sprvsr_hrchy_chgs;

    -- commit
    COMMIT;

  END IF;

END populate_wrkfc_evt_mgrh_eq;


-- ----------------------------------------------------------------------------
-- POPULATE_ASG_DELTA_EQ (4259598 Incremental Changes)
-- This procedure inserts all records from the supervisor event queue into the
-- assignment event delta queue, which is used to incrementally refresh
-- the assignment delta table
--
-- Also, if absence is used, the corresponding absences event queue is
-- populated
-- ----------------------------------------------------------------------------
PROCEDURE populate_asg_delta_eq IS

BEGIN

-- 4259598 Incremental Changes
-- Populate the assignment event delta queue using which the assignment delta
-- table can be refrshed incrementally It should be noted that any point in
-- time there should only be one record for an assingment and type in the event
-- queue which contains the earliest event date for the assignment. Therefore,
-- if a record exists for the asg then update the record otherwise, insert a
-- new record for the assignment
  IF (fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN

    MERGE INTO hri_eq_asg_sup_wrfc delta_eq
    USING (SELECT assignment_id,
                  erlst_evnt_effective_date,
                  'SUPERVISOR' source_type
           FROM   hri_eq_sprvsr_hrchy_chgs) sup_eq
    ON    (       delta_eq.source_type = 'SUPERVISOR'
           AND    sup_eq.assignment_id = delta_eq.source_id)
    WHEN MATCHED THEN
      UPDATE SET delta_eq.erlst_evnt_effective_date =
                 least(delta_eq.erlst_evnt_effective_date,sup_eq.erlst_evnt_effective_date)
    WHEN NOT MATCHED THEN
      INSERT (delta_eq.source_type,
              delta_eq.source_id,
              delta_eq.erlst_evnt_effective_date
              )
      VALUES (sup_eq.source_type,
              sup_eq.assignment_id,
              sup_eq.erlst_evnt_effective_date);
  -- Commit
    COMMIT;

  END IF;

-- Check if absence is required
  IF (fnd_profile.value('HRI_COL_ABSNCE_EVENT_EQ') = 'Y') THEN

    MERGE INTO hri_eq_sup_absnc absnc_eq
    USING (SELECT person_id,
                  erlst_evnt_effective_date,
                  'SUPERVISOR' source_type
           FROM   hri_eq_sprvsr_hrchy_chgs) sup_eq
    ON    (       absnc_eq.source_type = 'SUPERVISOR'
           AND    sup_eq.person_id = absnc_eq.source_id)
    WHEN MATCHED THEN
      UPDATE SET absnc_eq.erlst_evnt_effective_date =
                 LEAST(absnc_eq.erlst_evnt_effective_date,
                       sup_eq.erlst_evnt_effective_date)
    WHEN NOT MATCHED THEN
      INSERT (absnc_eq.source_type,
              absnc_eq.source_id,
              absnc_eq.erlst_evnt_effective_date
              )
      VALUES (sup_eq.source_type,
              sup_eq.person_id,
              sup_eq.erlst_evnt_effective_date);

  -- Commit
    COMMIT;

  END IF;

END populate_asg_delta_eq;

-- ----------------------------------------------------------------------------
-- Recovers rows to insert when an exception occurs
-- ----------------------------------------------------------------------------
PROCEDURE recover_insert_rows IS

  -- variables needed for populating the WHO columns
  l_user_id      NUMBER;

BEGIN

  -- Initialize variables
  l_user_id      := fnd_global.user_id;
  g_current_time := sysdate;

  -- Loop through rows one at a time
  FOR i IN 1..g_suph_row_count LOOP

    -- Trap unique constraint errors
    BEGIN

      -- Perform single row insert
      INSERT INTO hri_cs_suph
        (sup_person_id
        ,sup_assignment_id
        ,sup_level
        ,sup_business_group_id
        ,sup_assignment_status_type_id
        ,sup_invalid_flag_code
        ,sup_sub1_mgr_person_fk
        ,sup_sub2_mgr_person_fk
        ,sup_sub3_mgr_person_fk
        ,sup_sub4_mgr_person_fk
        ,sub_person_id
        ,sub_assignment_id
        ,sub_level
        ,sub_relative_level
        ,sub_business_group_id
        ,sub_invalid_flag_code
        ,sub_primary_asg_flag_code
        ,orphan_flag_code
        ,sub_mngrsc_fk
        ,effective_start_date
        ,effective_end_date
        ,last_update_date
        ,last_update_login
        ,last_updated_by
        ,created_by
        ,creation_date)
          VALUES
            (g_suph_sup_psn_id(i)
            ,g_suph_sup_asg_id(i)
            ,g_suph_sup_level(i)
            ,g_suph_sup_bgr_id(i)
            ,g_suph_sup_ast_id(i)
            ,'N'
            ,g_suph_sup_sub1_psn_id(i)
            ,g_suph_sup_sub2_psn_id(i)
            ,g_suph_sup_sub3_psn_id(i)
            ,g_suph_sup_sub4_psn_id(i)
            ,g_suph_sub_psn_id(i)
            ,g_suph_sub_asg_id(i)
            ,g_suph_sub_level(i)
            ,g_suph_sub_rlt_lvl(i)
            ,g_suph_sub_bgr_id(i)
            ,'N'
            ,'Y'
            ,g_suph_orphan_flg(i)
            ,g_suph_sub_chain_id(i)
            ,g_suph_start_date(i)
            ,g_suph_end_date(i)
            ,g_current_time
            ,l_user_id
            ,l_user_id
            ,l_user_id
            ,g_current_time);

    EXCEPTION
      WHEN OTHERS THEN

         -- Probable overlap on date tracked assignment rows
         output('Assignment error: ' || to_char(g_suph_sub_asg_id(i)) ||
                ' on ' || to_char(g_suph_start_date(i),'DD-MON-YYYY'));

    END;

  END LOOP;

  FOR i IN 1..g_chn_row_count LOOP

    BEGIN

      INSERT INTO hri_cs_mngrsc_ct
       (mgrs_mngrsc_pk
       ,mgrs_person_fk
       ,mgrs_assignment_fk
       ,mgrs_date_start
       ,mgrs_date_end
       ,mgrs_level
       ,last_update_date
       ,last_update_login
       ,last_updated_by
       ,created_by
       ,creation_date)
       VALUES
        (g_chn_chain_id(i)
        ,g_chn_psn_id(i)
        ,g_chn_asg_id(i)
        ,g_chn_start_date(i)
        ,g_chn_end_date(i)
        ,g_chn_psn_lvl(i)
        ,g_current_time
        ,l_user_id
        ,l_user_id
        ,l_user_id
        ,g_current_time);

    EXCEPTION WHEN OTHERS THEN
      -- If this insert errors the above insert will have also failed
      null;
    END;

  END LOOP;

  -- Insert manager hierarchy transfers
  IF (g_trn_row_count > 0) THEN

    FOR i IN 1..g_trn_row_count LOOP

      BEGIN

        INSERT INTO hri_mdp_mgrh_transfers_ct
         (mgr_sup_person_fk
         ,per_person_fk
         ,asg_assgnmnt_fk
         ,per_person_trn_fk
         ,time_day_evt_fk
         ,ptyp_wrktyp_fk
         ,transfer_in_ind
         ,transfer_out_ind
         ,direct_ind
         ,direct_record_ind
         ,sec_asg_ind
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date)
          VALUES
           (g_trn_sup_psn_id(i)
           ,g_trn_psn_id(i)
           ,g_trn_asg_id(i)
           ,g_trn_ref_id(i)
           ,g_trn_date(i)
           ,g_trn_wty_fk(i)
           ,g_trn_in_ind(i)
           ,g_trn_out_ind(i)
           ,g_trn_dir_ind(i)
           ,g_trn_dir_rec(i)
           ,g_trn_sec_asg_ind(i)
           ,g_current_time
           ,l_user_id
           ,l_user_id
           ,l_user_id
           ,g_current_time);

      EXCEPTION WHEN OTHERS THEN
        -- If this insert errors the above insert will have also failed
        null;
      END;

    END LOOP;

  END IF;

  -- Commit the chunk of rows
  COMMIT;

  -- Reset the row counters
  g_suph_row_count := 0;
  g_chn_row_count := 0;
  g_trn_row_count := 0;

END recover_insert_rows;

-- ----------------------------------------------------------------------------
-- Bulk inserts rows from global temporary table to database table
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_rows IS

l_user_id      NUMBER;

BEGIN

  -- Initialize variables
  l_user_id      := fnd_global.user_id;
  g_current_time := sysdate;

  IF (g_suph_row_count > 0) THEN

  -- insert chunk of rows
  FORALL i IN 1..g_suph_row_count
    INSERT INTO hri_cs_suph
      (sup_person_id
      ,sup_assignment_id
      ,sup_level
      ,sup_business_group_id
      ,sup_assignment_status_type_id
      ,sup_invalid_flag_code
      ,sup_sub1_mgr_person_fk
      ,sup_sub2_mgr_person_fk
      ,sup_sub3_mgr_person_fk
      ,sup_sub4_mgr_person_fk
      ,sub_person_id
      ,sub_assignment_id
      ,sub_level
      ,sub_relative_level
      ,sub_business_group_id
      ,sub_invalid_flag_code
      ,sub_primary_asg_flag_code
      ,orphan_flag_code
      ,sub_mngrsc_fk
      ,effective_start_date
      ,effective_end_date
      ,last_update_date
      ,last_update_login
      ,last_updated_by
      ,created_by
      ,creation_date)
        VALUES
          (g_suph_sup_psn_id(i)
          ,g_suph_sup_asg_id(i)
          ,g_suph_sup_level(i)
          ,g_suph_sup_bgr_id(i)
          ,g_suph_sup_ast_id(i)
          ,'N'
          ,g_suph_sup_sub1_psn_id(i)
          ,g_suph_sup_sub2_psn_id(i)
          ,g_suph_sup_sub3_psn_id(i)
          ,g_suph_sup_sub4_psn_id(i)
          ,g_suph_sub_psn_id(i)
          ,g_suph_sub_asg_id(i)
          ,g_suph_sub_level(i)
          ,g_suph_sub_rlt_lvl(i)
          ,g_suph_sub_bgr_id(i)
          ,'N'
          ,'Y'
          ,g_suph_orphan_flg(i)
          ,g_suph_sub_chain_id(i)
          ,g_suph_start_date(i)
          ,g_suph_end_date(i)
          ,g_current_time
          ,l_user_id
          ,l_user_id
          ,l_user_id
          ,g_current_time);

  END IF;

  IF (g_chn_row_count > 0) THEN

  FORALL i IN 1..g_chn_row_count
    INSERT INTO hri_cs_mngrsc_ct
     (mgrs_mngrsc_pk
     ,mgrs_person_fk
     ,mgrs_assignment_fk
     ,mgrs_date_start
     ,mgrs_date_end
     ,mgrs_level
     ,last_update_date
     ,last_update_login
     ,last_updated_by
     ,created_by
     ,creation_date)
     VALUES
      (g_chn_chain_id(i)
      ,g_chn_psn_id(i)
      ,g_chn_asg_id(i)
      ,g_chn_start_date(i)
      ,g_chn_end_date(i)
      ,g_chn_psn_lvl(i)
      ,g_current_time
      ,l_user_id
      ,l_user_id
      ,l_user_id
      ,g_current_time);

  END IF;

  -- Insert manager hierarchy transfers
  IF (g_trn_row_count > 0) THEN

    FORALL i IN 1..g_trn_row_count
      INSERT INTO hri_mdp_mgrh_transfers_ct
       (mgr_sup_person_fk
       ,per_person_fk
       ,asg_assgnmnt_fk
       ,per_person_trn_fk
       ,time_day_evt_fk
       ,ptyp_wrktyp_fk
       ,transfer_in_ind
       ,transfer_out_ind
       ,direct_ind
       ,direct_record_ind
       ,sec_asg_ind
       ,last_update_date
       ,last_update_login
       ,last_updated_by
       ,created_by
       ,creation_date)
        VALUES
         (g_trn_sup_psn_id(i)
         ,g_trn_psn_id(i)
         ,g_trn_asg_id(i)
         ,g_trn_ref_id(i)
         ,g_trn_date(i)
         ,g_trn_wty_fk(i)
         ,g_trn_in_ind(i)
         ,g_trn_out_ind(i)
         ,g_trn_dir_ind(i)
         ,g_trn_dir_rec(i)
         ,g_trn_sec_asg_ind(i)
         ,g_current_time
         ,l_user_id
         ,l_user_id
         ,l_user_id
         ,g_current_time);

  END IF;

  -- commit the chunk of rows
  COMMIT;

  -- Reset the row counters
  g_suph_row_count := 0;
  g_chn_row_count  := 0;
  g_trn_row_count := 0;

EXCEPTION
  WHEN OTHERS THEN

  recover_insert_rows;

END bulk_insert_rows;


-- ----------------------------------------------------------------------------
-- Inserts row into global temporary table
-- ----------------------------------------------------------------------------
PROCEDURE insert_row(p_supv_person_id           IN NUMBER
                    ,p_supv_assignment_id       IN NUMBER
                    ,p_supv_level               IN NUMBER
                    ,p_supv_business_group_id   IN NUMBER
                    ,p_supv_asg_status_type_id  IN NUMBER
                    ,p_supv_sub1_psn_id         IN VARCHAR2
                    ,p_supv_sub2_psn_id         IN VARCHAR2
                    ,p_supv_sub3_psn_id         IN VARCHAR2
                    ,p_supv_sub4_psn_id         IN VARCHAR2
                    ,p_sub_person_id            IN NUMBER
                    ,p_sub_assignment_id        IN NUMBER
                    ,p_sub_level                IN NUMBER
                    ,p_sub_relative_level       IN NUMBER
                    ,p_sub_business_group_id    IN NUMBER
                    ,p_effective_start_date     IN DATE
                    ,p_effective_end_date       IN DATE
                    ,p_orphan_flag              IN VARCHAR2
                    ,p_chain_id                 IN VARCHAR2) IS

BEGIN

  -- increment the index
  g_suph_row_count := g_suph_row_count + 1;

  -- set the table structures
  g_suph_sup_psn_id(g_suph_row_count)      := p_supv_person_id;
  g_suph_sup_asg_id(g_suph_row_count)      := p_supv_assignment_id;
  g_suph_sup_level(g_suph_row_count)       := p_supv_level;
  g_suph_sup_bgr_id(g_suph_row_count)      := p_supv_business_group_id;
  g_suph_sup_ast_id(g_suph_row_count)      := p_supv_asg_status_type_id;
  g_suph_sup_sub1_psn_id(g_suph_row_count) := p_supv_sub1_psn_id;
  g_suph_sup_sub2_psn_id(g_suph_row_count) := p_supv_sub2_psn_id;
  g_suph_sup_sub3_psn_id(g_suph_row_count) := p_supv_sub3_psn_id;
  g_suph_sup_sub4_psn_id(g_suph_row_count) := p_supv_sub4_psn_id;
  g_suph_sub_psn_id(g_suph_row_count)      := p_sub_person_id;
  g_suph_sub_asg_id(g_suph_row_count)      := p_sub_assignment_id;
  g_suph_sub_level(g_suph_row_count)       := p_sub_level;
  g_suph_sub_rlt_lvl(g_suph_row_count)     := p_sub_relative_level;
  g_suph_sub_bgr_id(g_suph_row_count)      := p_sub_business_group_id;
  g_suph_start_date(g_suph_row_count)      := p_effective_start_date;
  g_suph_end_date(g_suph_row_count)        := p_effective_end_date;
  g_suph_orphan_flg(g_suph_row_count)      := p_orphan_flag;
  g_suph_sub_chain_id(g_suph_row_count)    := p_chain_id;

END insert_row;

-- ----------------------------------------------------------------------------
-- Inserts row into global temporary table
-- ----------------------------------------------------------------------------
PROCEDURE insert_chn_row(p_person_id      IN NUMBER
                        ,p_assignment_id  IN NUMBER
                        ,p_start_date     IN DATE
                        ,p_end_date       IN DATE
                        ,p_chain_id       IN NUMBER
                        ,p_person_level   IN NUMBER) IS

  l_user_id      NUMBER;

BEGIN

  -- Initialize variables
  l_user_id      := fnd_global.user_id;
  g_current_time := sysdate;

  -- Add row
  g_chn_row_count := g_chn_row_count + 1;
  g_chn_psn_id(g_chn_row_count)     := p_person_id;
  g_chn_asg_id(g_chn_row_count)     := p_assignment_id;
  g_chn_start_date(g_chn_row_count) := p_start_date;
  g_chn_end_date(g_chn_row_count)   := p_end_date;
  g_chn_chain_id(g_chn_row_count)   := p_chain_id;
  g_chn_psn_lvl(g_chn_row_count)    := p_person_level;

END insert_chn_row;

-- ----------------------------------------------------------------------------
-- Inserts row into global pl/sql table
-- ----------------------------------------------------------------------------
PROCEDURE insert_trn_row(p_sup_person_id     IN NUMBER
                        ,p_trn_person_id     IN NUMBER
                        ,p_trn_assignment_id IN NUMBER
                        ,p_ref_person_id     IN NUMBER
                        ,p_transfer_date     IN DATE
                        ,p_trn_wrktyp_fk     IN VARCHAR2
                        ,p_transfer_in_ind   IN NUMBER
                        ,p_transfer_out_ind  IN NUMBER
                        ,p_direct_ind        IN NUMBER
                        ,p_direct_rec        IN NUMBER
                        ,p_sec_asg_ind       IN NUMBER) IS

BEGIN

  -- Add row
  g_trn_row_count := g_trn_row_count + 1;
  g_trn_sup_psn_id(g_trn_row_count)  := p_sup_person_id;
  g_trn_psn_id(g_trn_row_count)      := p_trn_person_id;
  g_trn_ref_id(g_trn_row_count)      := p_ref_person_id;
  g_trn_asg_id(g_trn_row_count)      := p_trn_assignment_id;
  g_trn_date(g_trn_row_count)        := p_transfer_date;
  g_trn_wty_fk(g_trn_row_count)      := p_trn_wrktyp_fk;
  g_trn_in_ind(g_trn_row_count)      := p_transfer_in_ind;
  g_trn_out_ind(g_trn_row_count)     := p_transfer_out_ind;
  g_trn_dir_ind(g_trn_row_count)     := p_direct_ind;
  g_trn_dir_rec(g_trn_row_count)     := p_direct_rec;
  g_trn_sec_asg_ind(g_trn_row_count) := p_sec_asg_ind;

END insert_trn_row;

-- ----------------------------------------------------------------------------
-- This procedure populates the person_id column in hri_eq_sprvsr_hrchy_chgs
-- by using the value of assignment_id
-- ----------------------------------------------------------------------------
PROCEDURE update_event_queue IS

BEGIN

-- 3667099 The events queue may contain records for events that have taken place
-- to assignment records which do not affect the supervisor hierarchy, for
-- example secondary assingments and non employee assingments.
-- Delete event queue records that are related to secondary assingments
-- ,non employee assignments and assignments that do not have any supervisor
-- 4186087 If a person is made a top supervisor or if a new top supervisor is
-- added the event should not be deleted, otherwise the person's record may
-- not be correct in the hiearchy.
-- Removed the condition (AND    supervisor_id is not null) from the inner query

-- Delete records that are not primary employee assignment change events
  DELETE /*+ PARALLEL(eq, default,default)*/ hri_eq_sprvsr_hrchy_chgs eq
  WHERE assignment_id NOT IN
         (SELECT assignment_id
          FROM per_all_assignments_f asg
          WHERE eq.assignment_id = asg.assignment_id
          AND primary_flag = 'Y'
          AND assignment_type IN ('E','C')
          AND asg.effective_end_date >= eq.erlst_evnt_effective_date);

  debug(sql%rowcount || ' records deleted from supervior events queue.');

-- Commit
  commit;

-- Set person ids on event queue
  UPDATE hri_eq_sprvsr_hrchy_chgs  eq
  SET person_id =
       (SELECT person_id
        FROM per_all_assignments_f asg
        WHERE eq.assignment_id = asg.assignment_id
        AND rownum = 1);

EXCEPTION
  WHEN OTHERS THEN

  output('An error occured while updating events queue records.');
  output(sqlerrm);
  g_msg_sub_group := NVL(g_msg_sub_group, 'UPDATE_EVENT_QUEUE');
  RAISE;

END update_event_queue;


-- ----------------------------------------------------------------------------
-- Removes records from the supervisor hierarchy after the earliest event date
-- End dates latest remaining record
-- Processes all records for the chunk
-- ----------------------------------------------------------------------------
PROCEDURE delete_and_end_date_suph_recs
  (p_start_person_id   IN NUMBER,
   p_end_person_id     IN NUMBER) IS

BEGIN

  -- Delete chain updates after the date of refresh
  DELETE FROM hri_cs_suph sph
  WHERE sph.rowid IN
         (SELECT sph2.rowid
          FROM   hri_eq_sprvsr_hrchy_chgs evt,
                 hri_cs_suph           sph2
          WHERE evt.person_id   = sph2.sub_person_id
          AND evt.person_id BETWEEN p_start_person_id
                            AND p_end_person_id
          AND evt.erlst_evnt_effective_date <= sph2.effective_start_date);

  debug(sql%rowcount || ' supervisor hierarchy records deleted.');

  -- Delete lookup chain updates after the date of refresh
  DELETE FROM hri_cs_mngrsc_ct chn
  WHERE chn.rowid IN
         (SELECT chn2.rowid
          FROM   hri_eq_sprvsr_hrchy_chgs evt,
                 hri_cs_mngrsc_ct      chn2
          WHERE evt.person_id   = chn2.mgrs_person_fk
          AND evt.person_id BETWEEN p_start_person_id
                            AND p_end_person_id
          AND evt.erlst_evnt_effective_date <= chn2.mgrs_date_start);

  debug(sql%rowcount || ' supervisor chain lookup records deleted.');

  -- Set end dates to the day before the earliest effective change date
  -- for latest chains of supervisor in event queue
  UPDATE hri_cs_suph sph
  SET effective_end_date =
        (SELECT (evt.erlst_evnt_effective_date - 1)
         FROM   hri_eq_sprvsr_hrchy_chgs evt
         WHERE  evt.person_id = sph.sub_person_id
         AND evt.erlst_evnt_effective_date BETWEEN sph.effective_start_date
         AND     sph.effective_end_date)
     ,last_update_date = sysdate
  WHERE (sph.sub_person_id,
         sph.sup_person_id,
         sph.effective_start_date) IN
        (SELECT
          sph2.sub_person_id,
          sph2.sup_person_id,
          sph2.effective_start_date
         FROM   hri_eq_sprvsr_hrchy_chgs evt,
                hri_cs_suph sph2
         WHERE  evt.person_id = sph2.sub_person_id
         AND evt.person_id BETWEEN p_start_person_id
                           AND p_end_person_id
         AND    evt.erlst_evnt_effective_date BETWEEN sph2.effective_start_date
                                                  AND sph2.effective_end_date);

  debug(sql%rowcount || ' supervisor hierarchy records end dated.');

  -- Set end dates to the day before the earliest effective change date
  -- for latest lookup chains of supervisor in event queue
  UPDATE hri_cs_mngrsc_ct      chn
  SET chn.mgrs_date_end =
        (SELECT (evt.erlst_evnt_effective_date - 1)
         FROM   hri_eq_sprvsr_hrchy_chgs evt
         WHERE  evt.person_id = chn.mgrs_person_fk
         AND evt.erlst_evnt_effective_date BETWEEN chn.mgrs_date_start
                                           AND chn.mgrs_date_end)
     ,last_update_date = sysdate
  WHERE chn.mgrs_mngrsc_pk IN
        (SELECT
          chn2.mgrs_mngrsc_pk
         FROM   hri_eq_sprvsr_hrchy_chgs evt,
                hri_cs_mngrsc_ct         chn2
         WHERE  evt.person_id = chn2.mgrs_person_fk
         AND evt.person_id BETWEEN p_start_person_id
                           AND p_end_person_id
         AND    evt.erlst_evnt_effective_date BETWEEN chn.mgrs_date_start
                                              AND chn.mgrs_date_end);

  debug(sql%rowcount || ' supervisor lookup records end dated.');

EXCEPTION
  WHEN OTHERS THEN

    output('An error occured while deleting and end dating records');
    output(SQLERRM);
    g_msg_sub_group := NVL(g_msg_sub_group, 'END_DATE_PRIOR_RECORDS');
    RAISE;

END delete_and_end_date_suph_recs;

-- ----------------------------------------------------------------------------
-- Removes later duplicate events for a person in hri_eq_sprvsr_hrchy_chgs
-- leaving only the earliest recorded event held in the table
-- ----------------------------------------------------------------------------
PROCEDURE remove_duplicates IS

BEGIN

  -- Delete duplicate events from queue
  DELETE FROM hri_eq_sprvsr_hrchy_chgs evt
  WHERE EXISTS
    (SELECT 'x'
     FROM   hri_eq_sprvsr_hrchy_chgs evt2
     WHERE  evt2.person_id = evt.person_id
     AND ((evt.erlst_evnt_effective_date = evt2.erlst_evnt_effective_date
           AND evt.rowid < evt2.rowid)
      OR
          evt.erlst_evnt_effective_date > evt2.erlst_evnt_effective_date));

  debug(sql%rowcount || ' duplicate records deleted.');

  -- Commit
  commit;

EXCEPTION
  WHEN OTHERS THEN

    output('An error occured while removing duplicates from the change list.');
    output(SQLERRM);
    g_msg_sub_group := NVL(g_msg_sub_group, 'REMOVE_DUPLICATES');
    RAISE;

END remove_duplicates;

-- ----------------------------------------------------------------------------
-- For every change for a supervisor there is a knock on effect on his
-- subordinates i.e. the supervisor hierarchy for the subordinates changes.
-- This procedure finds the subordinates for a supervisor that has an event
-- and inserts them into 'hri_eq_sprvsr_hrchy_chgs'.
-- ----------------------------------------------------------------------------
PROCEDURE find_subordinates IS

BEGIN

  -- Insert subordinate records into event queue
  INSERT /*+ append */ INTO hri_eq_sprvsr_hrchy_chgs
   (person_id
   ,assignment_id
   ,erlst_evnt_effective_date
   ,source_code)
  SELECT
   sph.sub_person_id
  ,sph.sub_assignment_id
  ,GREATEST(evt.erlst_evnt_effective_date,sph.effective_start_date)
  ,'DERIVED'
  FROM
   hri_eq_sprvsr_hrchy_chgs evt
  ,hri_cs_suph sph
  WHERE sph.sup_person_id = evt.person_id
  AND sph.sub_relative_level > 0
  AND sph.effective_end_date >= evt.erlst_evnt_effective_date;

  debug(sql%rowcount || ' subordinate records inserted.');

  -- Commit
  commit;

EXCEPTION
  WHEN OTHERS THEN

    output('An error occured while adding subordinates to the change list.');
    output(SQLERRM);
    g_msg_sub_group := NVL(g_msg_sub_group, 'FIND_SUBORDINATES');
    RAISE;

END find_subordinates;

-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS

BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  output('Error running sql:');
  output(SUBSTR(p_sql_stmt,1,230));

END run_sql_stmt_noerr;

-- ----------------------------------------------------------------------------
-- Sets global parameters from multi-threading process parameters
-- ----------------------------------------------------------------------------
PROCEDURE set_parameters(p_mthd_action_id  IN NUMBER) IS

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL) THEN
    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_load_helper_table    := g_mthd_action_array.attribute1;
    IF (fnd_profile.value('HRI_IMPL_OBIEE') = 'Y') THEN
      g_implement_obiee      := 'Y';
    ELSE
      g_implement_obiee      := 'N';
    END IF;
  END IF;

END set_parameters;

-- ----------------------------------------------------------------------------
-- Returns next value from chain id sequence
-- ----------------------------------------------------------------------------
FUNCTION get_chain_id RETURN NUMBER IS

  l_chain_id    NUMBER;

BEGIN

  SELECT hri_cs_mngrsc_ct_s.nextval
  INTO l_chain_id
  FROM dual;

  RETURN l_chain_id;

END get_chain_id;


-- ----------------------------------------------------------------------------
-- Given a transfer table containing all nodes before and after with details
-- of whether each node existed in the transferees management chain before and
-- after, insert a row for each node having the transfer.
-- ----------------------------------------------------------------------------
PROCEDURE process_transfer
     (p_trn_psn_id     IN NUMBER,
      p_trn_asg_id     IN NUMBER,
      p_trn_aty_id     IN VARCHAR2,
      p_trn_date       IN DATE,
      p_trn_tab        IN g_trn_tab_type) IS

  -- All secondary assignments reporting to the transferee before
  -- and after the transfer
  CURSOR sec_directs_csr IS
  SELECT
   sec_pre.person_id
  ,sec_pre.assignment_id
  ,CASE WHEN sec_pre.assignment_type = 'E'
        THEN 'EMP'
        ELSE 'CWK'
   END            ptyp_wrktyp_fk
  FROM
   per_all_assignments_f  sec_pre
  ,per_all_assignments_f  sec_post
  WHERE sec_pre.supervisor_id = p_trn_psn_id
  AND sec_post.assignment_id = sec_pre.assignment_id
  AND sec_post.supervisor_id = sec_pre.supervisor_id
  AND sec_post.primary_flag = 'N'
  AND sec_pre.assignment_type IN ('E','C')
  AND p_trn_date - 1 BETWEEN sec_pre.effective_start_date AND sec_pre.effective_end_date
  AND p_trn_date BETWEEN sec_post.effective_start_date AND sec_post.effective_end_date;

  l_idx               NUMBER;
  l_direct_ind        NUMBER;
  l_transfer_in_ind   NUMBER;
  l_transfer_out_ind  NUMBER;
  l_wrktyp_fk         VARCHAR2(30);

  l_sec_psn_tab       g_number_tab_type;
  l_sec_asg_tab       g_number_tab_type;
  l_sec_wrktyp_tab    g_varchar2_tab_type;

BEGIN

  -- Load list of secondary assignments reporting to the transferee before
  -- and after the transfer
  OPEN sec_directs_csr;
  FETCH sec_directs_csr BULK COLLECT INTO
    l_sec_psn_tab, l_sec_asg_tab, l_sec_wrktyp_tab;
  CLOSE sec_directs_csr;

  -- Set worker type for transferee
  IF p_trn_aty_id = 'E' THEN
    l_wrktyp_fk := 'EMP';
  ELSE
    l_wrktyp_fk := 'CWK';
  END IF;

  l_idx := p_trn_tab.FIRST;

  WHILE l_idx IS NOT NULL LOOP

    -- If node exists before and after transfer it is a transfer within
    -- the hierarchy, so do not do anything
    IF (p_trn_tab(l_idx).node_exists_before AND
        p_trn_tab(l_idx).node_exists_after) THEN
      null;

    ELSE

      -- If node exists before (but not after) then it is a transfer out
      IF (p_trn_tab(l_idx).node_exists_before) THEN

        l_transfer_in_ind  := 0;
        l_transfer_out_ind := 1;
        l_direct_ind       := p_trn_tab(l_idx).node_direct_before;

      -- If node exists after (but not before) then it is a transfer in
      ELSE

        l_transfer_in_ind  := 1;
        l_transfer_out_ind := 0;
        l_direct_ind       := p_trn_tab(l_idx).node_direct_after;

      END IF;

      -- Insert transfer record for transferee
      insert_trn_row
       (p_sup_person_id     => l_idx
       ,p_trn_person_id     => p_trn_psn_id
       ,p_trn_assignment_id => p_trn_asg_id
       ,p_ref_person_id     => -1
       ,p_transfer_date     => p_trn_date
       ,p_trn_wrktyp_fk     => l_wrktyp_fk
       ,p_transfer_in_ind   => l_transfer_in_ind
       ,p_transfer_out_ind  => l_transfer_out_ind
       ,p_direct_ind        => l_direct_ind
       ,p_direct_rec        => 0
       ,p_sec_asg_ind       => 0);

      -- Insert transfer record for any secondary assignments reporting to the
      -- transferee before and after transfer
      IF l_sec_psn_tab.EXISTS(1) THEN
        FOR i IN 1..l_sec_psn_tab.LAST LOOP
          insert_trn_row
           (p_sup_person_id     => l_idx
           ,p_trn_person_id     => l_sec_psn_tab(i)
           ,p_trn_assignment_id => l_sec_asg_tab(i)
           ,p_ref_person_id     => p_trn_psn_id
           ,p_transfer_date     => p_trn_date
           ,p_trn_wrktyp_fk     => l_sec_wrktyp_tab(i)
           ,p_transfer_in_ind   => l_transfer_in_ind
           ,p_transfer_out_ind  => l_transfer_out_ind
           ,p_direct_ind        => 0
           ,p_direct_rec        => 0
           ,p_sec_asg_ind       => 1);
        END LOOP;
      END IF;

    END IF;

    -- Filter out direct record transfers within
    IF (p_trn_tab(l_idx).node_direct_before = 1 AND
        p_trn_tab(l_idx).node_direct_after = 1) THEN

      null;

    ELSE

      -- If node is a direct manager before but not after it is a direct record transfer out
      IF (p_trn_tab(l_idx).node_direct_before = 1) THEN

        -- Insert transfer record for transferee
        insert_trn_row
         (p_sup_person_id     => l_idx
         ,p_trn_person_id     => p_trn_psn_id
         ,p_trn_assignment_id => p_trn_asg_id
         ,p_ref_person_id     => -1
         ,p_transfer_date     => p_trn_date
         ,p_trn_wrktyp_fk     => l_wrktyp_fk
         ,p_transfer_in_ind   => 0
         ,p_transfer_out_ind  => 1
         ,p_direct_ind        => 1
         ,p_direct_rec        => 1
         ,p_sec_asg_ind       => 0);

      -- If node is a direct manager after but not before it is a direct record transfer in
      ELSIF (p_trn_tab(l_idx).node_direct_after = 1) THEN

        -- Insert transfer record for transferee
        insert_trn_row
         (p_sup_person_id     => l_idx
         ,p_trn_person_id     => p_trn_psn_id
         ,p_trn_assignment_id => p_trn_asg_id
         ,p_ref_person_id     => -1
         ,p_transfer_date     => p_trn_date
         ,p_trn_wrktyp_fk     => l_wrktyp_fk
         ,p_transfer_in_ind   => 1
         ,p_transfer_out_ind  => 0
         ,p_direct_ind        => 1
         ,p_direct_rec        => 1
         ,p_sec_asg_ind       => 0);

      END IF;

    END IF;

    -- Increment index
    l_idx := p_trn_tab.NEXT(l_idx);

  END LOOP;

END process_transfer;


-- ----------------------------------------------------------------------------
-- Given a chain cache table containing the previous manager chain and a new
-- manager chain
--   - Insert new chain records
--   - Insert chain id lookups
-- ----------------------------------------------------------------------------
PROCEDURE process_chain
 (p_new_psn_tab     IN g_number_tab_type,
  p_new_asg_tab     IN g_number_tab_type,
  p_new_bgr_tab     IN g_number_tab_type,
  p_new_sup_tab     IN g_number_tab_type,
  p_new_ast_tab     IN g_number_tab_type,
  p_new_end_tab     IN g_date_tab_type,
  p_new_aty_tab     IN g_varchar2_tab_type,
  p_orphan_flag     IN VARCHAR2,
  p_chain_table     IN OUT NOCOPY g_chain_type,
  p_loop_date       IN  DATE,
  p_next_loop_date  IN  DATE) IS

  l_sup_level         PLS_INTEGER;
  l_sub_level         PLS_INTEGER;

  l_chain_id          NUMBER;
  l_sup_sub1_psn_id   NUMBER;
  l_sup_sub2_psn_id   NUMBER;
  l_sup_sub3_psn_id   NUMBER;
  l_sup_sub4_psn_id   NUMBER;

  l_chain_end_date    DATE;

  l_trn_tab           g_trn_tab_type;
  l_is_a_trn          BOOLEAN;

BEGIN

  -- Get chain id
  l_chain_id := get_chain_id;

  -- Set chain end date
  IF (p_next_loop_date = g_end_of_time) THEN
    l_chain_end_date := g_end_of_time;
  ELSE
    l_chain_end_date := p_next_loop_date - 1;
  END IF;

  -- Set the new level for the person (equal to the number of links in
  -- the new chain)
  l_sub_level := p_new_psn_tab.LAST;

  -- Load manager chain before transfer
  IF p_chain_table.EXISTS(1) THEN
    l_is_a_trn := TRUE;
    FOR i IN 1..p_chain_table.LAST LOOP
      l_trn_tab(p_chain_table(i).person_id).node_exists_before := TRUE;
      IF i = p_chain_table.LAST - 1 THEN
        l_trn_tab(p_chain_table(i).person_id).node_direct_before := 1;
      ELSE
        l_trn_tab(p_chain_table(i).person_id).node_direct_before := 0;
      END IF;
    END LOOP;
  ELSE
    l_is_a_trn := FALSE;
  END IF;

  -- Loop through new management chain (top supervisor last)
  FOR i IN 1..l_sub_level LOOP

    -- Set manager chain after transfer
    l_trn_tab(p_new_psn_tab(i)).node_exists_after := TRUE;
    IF i = 2 THEN
      l_trn_tab(p_new_psn_tab(i)).node_direct_after := 1;
    ELSE
      l_trn_tab(p_new_psn_tab(i)).node_direct_after := 0;
    END IF;

    -- Set level for link as default order is reverse level order
    l_sup_level := l_sub_level - i + 1;

    -- Set relative levels
    IF (i - 1) >= 1 THEN
      l_sup_sub1_psn_id := p_new_psn_tab(i - 1);
    ELSE
      l_sup_sub1_psn_id := p_new_psn_tab(1);
    END IF;
    IF (i - 2) >= 1 THEN
      l_sup_sub2_psn_id := p_new_psn_tab(i - 2);
    ELSE
      l_sup_sub2_psn_id := p_new_psn_tab(1);
    END IF;
    IF (i - 3) >= 1 THEN
      l_sup_sub3_psn_id := p_new_psn_tab(i - 3);
    ELSE
      l_sup_sub3_psn_id := p_new_psn_tab(1);
    END IF;
    IF (i - 4) >= 1 THEN
      l_sup_sub4_psn_id := p_new_psn_tab(i - 4);
    ELSE
      l_sup_sub4_psn_id := p_new_psn_tab(1);
    END IF;

    -- Insert row
    insert_row
     (p_supv_person_id          => p_new_psn_tab(i)
     ,p_supv_assignment_id      => p_new_asg_tab(i)
     ,p_supv_level              => l_sup_level
     ,p_supv_business_group_id  => p_new_bgr_tab(i)
     ,p_supv_asg_status_type_id => p_new_ast_tab(i)
     ,p_supv_sub1_psn_id        => l_sup_sub1_psn_id
     ,p_supv_sub2_psn_id        => l_sup_sub2_psn_id
     ,p_supv_sub3_psn_id        => l_sup_sub3_psn_id
     ,p_supv_sub4_psn_id        => l_sup_sub4_psn_id
     ,p_sub_person_id           => p_new_psn_tab(1)
     ,p_sub_assignment_id       => p_new_asg_tab(1)
     ,p_sub_level               => l_sub_level
     ,p_sub_relative_level      => l_sub_level - l_sup_level
     ,p_sub_business_group_id   => p_new_bgr_tab(1)
     ,p_effective_start_date    => p_loop_date
     ,p_effective_end_date      => l_chain_end_date
     ,p_orphan_flag             => p_orphan_flag
     ,p_chain_id                => l_chain_id);

    -- Update chain table with new link details
    p_chain_table(l_sup_level).person_id          := p_new_psn_tab(i);
    p_chain_table(l_sup_level).assignment_id      := p_new_asg_tab(i);
    p_chain_table(l_sup_level).business_group_id  := p_new_bgr_tab(i);
    p_chain_table(l_sup_level).asg_status_type_id := p_new_ast_tab(i);
    p_chain_table(l_sup_level).start_date         := p_loop_date;
    p_chain_table(l_sup_level).relative_level     := l_sub_level - l_sup_level;
    p_chain_table(l_sup_level).orphan_flag        := p_orphan_flag;

  END LOOP;

  -- Remove any additional records in the chain table that result from
  -- a promotion (person decrease in absolute level)
  FOR i IN (l_sub_level + 1)..p_chain_table.LAST LOOP
    p_chain_table.DELETE(i);
  END LOOP;

  -- Insert chain lookup
  insert_chn_row
   (p_person_id     => p_new_psn_tab(1)
   ,p_assignment_id => p_new_asg_tab(1)
   ,p_start_date    => p_loop_date
   ,p_end_date      => l_chain_end_date
   ,p_chain_id      => l_chain_id
   ,p_person_level  => l_sub_level);

  -- Process transfer
  IF l_is_a_trn THEN
    process_transfer
     (p_trn_psn_id => p_new_psn_tab(1),
      p_trn_asg_id => p_new_asg_tab(1),
      p_trn_aty_id => p_new_aty_tab(1),
      p_trn_date   => p_loop_date,
      p_trn_tab    => l_trn_tab);
  END IF;

END process_chain;


-- ----------------------------------------------------------------------------
-- Tree-walk the manager hierarchy for a person on a given date
-- Trap loops and return as orphans
-- ----------------------------------------------------------------------------
PROCEDURE get_manager_chain
 (p_person_id         IN NUMBER,
  p_effective_date    IN DATE,
  p_hier_psn_tab      OUT NOCOPY g_number_tab_type,
  p_hier_asg_tab      OUT NOCOPY g_number_tab_type,
  p_hier_bgr_tab      OUT NOCOPY g_number_tab_type,
  p_hier_sup_tab      OUT NOCOPY g_number_tab_type,
  p_hier_ast_tab      OUT NOCOPY g_number_tab_type,
  p_hier_end_tab      OUT NOCOPY g_date_tab_type,
  p_hier_aty_tab      OUT NOCOPY g_varchar2_tab_type,
  p_next_change_date  OUT NOCOPY DATE) IS

  -- Return PL/SQL tables
  l_psn_tab     g_number_tab_type;
  l_asg_tab     g_number_tab_type;
  l_bgr_tab     g_number_tab_type;
  l_sup_tab     g_number_tab_type;
  l_ast_tab     g_number_tab_type;
  l_end_tab     g_date_tab_type;
  l_aty_tab     g_varchar2_tab_type;

  -- Loop message
  l_loop_msg    VARCHAR2(2000);

  -- Main tree walk returns rows in default order starting with
  -- the person and ending with the top manager
  CURSOR manager_chain_csr(v_effective_date   DATE) IS
  SELECT
   hier.person_id
  ,hier.assignment_id
  ,hier.business_group_id
  ,hier.supervisor_person_id
  ,hier.assignment_status_type_id
  ,hier.effective_end_date
  ,hier.assignment_type
  FROM
   (SELECT
     ase.person_id
    ,ase.assignment_id
    ,ase.business_group_id
    ,ase.supervisor_person_id
    ,ase.assignment_status_type_id
    ,ase.effective_end_date
    ,ase.assignment_type
    FROM
     hri_cs_asgn_suph_events_ct  ase
    WHERE ase.primary_flag = 'Y'
    AND v_effective_date BETWEEN ase.effective_start_date
                         AND ase.effective_end_date
   ) hier
  START WITH hier.person_id = p_person_id
  CONNECT BY hier.person_id = PRIOR hier.supervisor_person_id;
-- NO ORDER BY LEAVE DEFAULT!

  -- If the main tree walk fails then treat the person as an orphan
  -- and get their next change date which is the earlier of:
  --    - Next change date
  --    - 1 month on provided this is less than system date
  CURSOR loop_in_chain_csr(v_effective_date   DATE) IS
  SELECT
   ase.person_id
  ,ase.assignment_id
  ,ase.business_group_id
  ,ase.supervisor_person_id
  ,ase.assignment_status_type_id
  ,CASE WHEN v_effective_date >= ADD_MONTHS(TRUNC(SYSDATE), -1)
        THEN ase.effective_end_date
        ELSE LEAST(ase.effective_end_date, ADD_MONTHS(v_effective_date, 1))
   END
  ,ase.assignment_type
  FROM
   hri_cs_asgn_suph_events_ct  ase
  WHERE ase.person_id = p_person_id
  AND ase.primary_flag = 'Y'
  AND v_effective_date BETWEEN ase.effective_start_date
                       AND ase.effective_end_date;

BEGIN

  -- PL/SQL block to trap loop exceptions
  BEGIN

    -- Get first supervisor chain for person
    OPEN manager_chain_csr(p_effective_date);
    FETCH manager_chain_csr
      BULK COLLECT INTO
        l_psn_tab,
        l_asg_tab,
        l_bgr_tab,
        l_sup_tab,
        l_ast_tab,
        l_end_tab,
        l_aty_tab;
    CLOSE manager_chain_csr;

    -- Loop not encountered, so output next loop message
    g_log_sup_loop := TRUE;

  EXCEPTION WHEN OTHERS THEN

    -- Close cursor
    IF manager_chain_csr%ISOPEN THEN
      CLOSE manager_chain_csr;
    END IF;

    -- Log message if first iteration of encountering loop
    IF g_log_sup_loop THEN

      -- Loop diagnostics
      l_loop_msg := get_sup_loop_message
                     (p_message        => 'HRI_407283_SUP_LOOP_MSG'
                     ,p_effective_date => p_effective_date
                     ,p_person_id      => p_person_id);

      -- Write message to concurrent program log
      output(l_loop_msg);

      -- Write message to log table hri_adm_msg_log
      hri_bpl_conc_log.log_process_info
       (p_package_name      => 'HRI_OPL_SUPH_HST'
       ,p_msg_type          => 'WARNING'
       ,p_effective_date    => p_effective_date
       ,p_person_id         => p_person_id
       ,p_note              => l_loop_msg
       ,p_msg_group         => 'SUP_LOOP');

    END IF;

    -- Do not output further loop messages until the loop is fixed
    g_log_sup_loop := FALSE;

    -- Loop in chain
    -- get default information for the person
    OPEN loop_in_chain_csr(p_effective_date);
    FETCH loop_in_chain_csr
      BULK COLLECT INTO
        l_psn_tab,
        l_asg_tab,
        l_bgr_tab,
        l_sup_tab,
        l_ast_tab,
        l_end_tab,
        l_aty_tab;
    CLOSE loop_in_chain_csr;

  END;

  -- Get next change date
  IF l_end_tab.EXISTS(1) THEN

    -- Initialize to end of time
    p_next_change_date := g_end_of_time;

    -- Set to day after earliest link end date
    FOR i IN 1..l_end_tab.LAST LOOP
      IF (l_end_tab(i) < p_next_change_date) THEN
        p_next_change_date := l_end_tab(i) + 1;
      END IF;
    END LOOP;

  END IF;

  -- Return the tables
  p_hier_psn_tab := l_psn_tab;
  p_hier_asg_tab := l_asg_tab;
  p_hier_bgr_tab := l_bgr_tab;
  p_hier_sup_tab := l_sup_tab;
  p_hier_ast_tab := l_ast_tab;
  p_hier_end_tab := l_end_tab;
  p_hier_aty_tab := l_aty_tab;

EXCEPTION WHEN OTHERS THEN

  IF loop_in_chain_csr%ISOPEN THEN
    CLOSE loop_in_chain_csr;
  END IF;

  g_msg_sub_group := NVL(g_msg_sub_group, 'GET_MANAGER_CHAIN');

  RAISE;

END get_manager_chain;


-- ----------------------------------------------------------------------------
-- Initializes chain cache in incremental mode
-- ----------------------------------------------------------------------------
PROCEDURE initialize_previous_chain
   (p_person_id        IN NUMBER,
    p_effective_date   IN DATE,
    p_chain_table      IN OUT NOCOPY g_chain_type) IS

  -- Results of tree walk
  l_hier_psn_tab     g_number_tab_type;
  l_hier_asg_tab     g_number_tab_type;
  l_hier_bgr_tab     g_number_tab_type;
  l_hier_sup_tab     g_number_tab_type;
  l_hier_ast_tab     g_number_tab_type;
  l_hier_end_tab     g_date_tab_type;
  l_hier_aty_tab     g_varchar2_tab_type;
  l_dummy            DATE;
  l_sup_level        NUMBER;

BEGIN

  -- Leave chain table as NULL in full refresh mode
  -- as there data before global start date are ignored
  IF (g_full_refresh = 'N') THEN

    -- Get previous supervisor chain for person
    get_manager_chain
     (p_person_id        => p_person_id,
      p_effective_date   => p_effective_date,
      p_hier_psn_tab     => l_hier_psn_tab,
      p_hier_asg_tab     => l_hier_asg_tab,
      p_hier_bgr_tab     => l_hier_bgr_tab,
      p_hier_sup_tab     => l_hier_sup_tab,
      p_hier_ast_tab     => l_hier_ast_tab,
      p_hier_end_tab     => l_hier_end_tab,
      p_hier_aty_tab     => l_hier_aty_tab,
      p_next_change_date => l_dummy);

    -- If previous chain found
    IF l_hier_psn_tab.EXISTS(1) THEN

      -- Loop through previous chain
      FOR i IN 1..l_hier_psn_tab.LAST LOOP

        -- Set level for link as default order is reverse level order
        l_sup_level := l_hier_psn_tab.LAST - i + 1;

        -- Update chain table with new link details
        p_chain_table(l_sup_level).person_id          := l_hier_psn_tab(i);
        p_chain_table(l_sup_level).assignment_id      := l_hier_asg_tab(i);
        p_chain_table(l_sup_level).business_group_id  := l_hier_bgr_tab(i);
        p_chain_table(l_sup_level).asg_status_type_id := l_hier_ast_tab(i);
        p_chain_table(l_sup_level).start_date         := p_effective_date;
        p_chain_table(l_sup_level).relative_level     := l_hier_psn_tab.LAST - l_sup_level;

        -- Set orphan flag
        IF (l_hier_sup_tab(l_hier_psn_tab.LAST) = -1) THEN
          p_chain_table(l_sup_level).orphan_flag := 'N';
        ELSE
          p_chain_table(l_sup_level).orphan_flag := 'Y';
        END IF;

      END LOOP;

    END IF;
  END IF;

END initialize_previous_chain;


-- ----------------------------------------------------------------------------
-- Samples manager chain for given person between the given dates for the
-- period of service
-- ----------------------------------------------------------------------------
PROCEDURE process_period_of_work(p_person_id   IN NUMBER,
                                 p_start_date  IN DATE,
                                 p_end_date    IN DATE) IS

  -- Main loop variable
  l_loop_date        DATE;
  l_next_loop_date   DATE;

  -- Whether the chain is an orphan
  l_orphan_flag      VARCHAR2(30);

  -- Results of tree walk
  l_hier_psn_tab     g_number_tab_type;
  l_hier_asg_tab     g_number_tab_type;
  l_hier_bgr_tab     g_number_tab_type;
  l_hier_sup_tab     g_number_tab_type;
  l_hier_ast_tab     g_number_tab_type;
  l_hier_end_tab     g_date_tab_type;
  l_hier_aty_tab     g_varchar2_tab_type;

  -- Information about current chain within the hierarchy
  l_chain_table              g_chain_type;

  -- Whether to exit the loop
  l_exit_loop        VARCHAR2(30);

BEGIN

  -- Initialization
  l_loop_date := p_start_date;
  l_exit_loop := 'N';
  g_log_sup_loop := TRUE;
  initialize_previous_chain
   (p_person_id      => p_person_id,
    p_effective_date => l_loop_date - 1,
    p_chain_table    => l_chain_table);

  -- Get first supervisor chain for person
  get_manager_chain
   (p_person_id        => p_person_id,
    p_effective_date   => l_loop_date,
    p_hier_psn_tab     => l_hier_psn_tab,
    p_hier_asg_tab     => l_hier_asg_tab,
    p_hier_bgr_tab     => l_hier_bgr_tab,
    p_hier_sup_tab     => l_hier_sup_tab,
    p_hier_ast_tab     => l_hier_ast_tab,
    p_hier_end_tab     => l_hier_end_tab,
    p_hier_aty_tab     => l_hier_aty_tab,
    p_next_change_date => l_next_loop_date);

  -- If no data is found there may be assignment records missing
  -- at the start of the period of service. Attempt to re-initialize
  -- based on the earliest assignment record
  IF (NOT l_hier_psn_tab.EXISTS(1)) THEN

  -- Output warning message
    output('WARNING: No chain found for person ' || to_char(p_person_id) ||
          ' on ' || to_char(l_loop_date, 'DD-MON-YYYY'));

  -- Get the earliest assignment record
    SELECT MIN(effective_start_date)
    INTO l_loop_date
    FROM hri_cs_asgn_suph_events_ct
    WHERE person_id = p_person_id
    AND primary_flag = 'Y';

  -- If the earliest assignment record exists and is later than
  -- the date already attempted then retry chain initialization
    IF (l_loop_date > p_start_date) THEN

      -- Get first supervisor chain for person
      get_manager_chain
       (p_person_id        => p_person_id,
        p_effective_date   => l_loop_date,
        p_hier_psn_tab     => l_hier_psn_tab,
        p_hier_asg_tab     => l_hier_asg_tab,
        p_hier_bgr_tab     => l_hier_bgr_tab,
        p_hier_sup_tab     => l_hier_sup_tab,
        p_hier_ast_tab     => l_hier_ast_tab,
        p_hier_end_tab     => l_hier_end_tab,
        p_hier_aty_tab     => l_hier_aty_tab,
        p_next_change_date => l_next_loop_date);

    END IF;

  END IF;

  -- If still no data is found there is some data issue since
  -- this procedure is called with the start date set within
  -- an active period of service
  IF (NOT l_hier_psn_tab.EXISTS(1)) THEN

  -- Output warning message
    output('WARNING: No chain found for person ' || to_char(p_person_id) ||
          ' on ' || to_char(l_loop_date, 'DD-MON-YYYY'));

  ELSE

    -- Test for orphan chain
    -- Chain is an orphan if the top manager, ordered last, has a
    -- not-null supervisor id
    IF (l_hier_sup_tab(l_hier_psn_tab.LAST) = -1) THEN
      l_orphan_flag := 'N';
    ELSE
      l_orphan_flag := 'Y';
    END IF;

    -- Process chain
    process_chain
     (p_new_psn_tab    => l_hier_psn_tab,
      p_new_asg_tab    => l_hier_asg_tab,
      p_new_bgr_tab    => l_hier_bgr_tab,
      p_new_sup_tab    => l_hier_sup_tab,
      p_new_ast_tab    => l_hier_ast_tab,
      p_new_end_tab    => l_hier_end_tab,
      p_new_aty_tab    => l_hier_aty_tab,
      p_orphan_flag    => l_orphan_flag,
      p_chain_table    => l_chain_table,
      p_loop_date      => l_loop_date,
      p_next_loop_date => l_next_loop_date);

    -- Set new loop date
    l_loop_date := l_next_loop_date;

    -- Loop through dates to tree walk supervisor hierarchy
    -- for the given person and period of work
    -- Exit loop when the next date to sample goes beyond the period of
    -- work or reaches end of time
    WHILE (l_loop_date <= p_end_date AND
           l_loop_date < g_end_of_time AND
           l_exit_loop = 'N') LOOP

      -- Reset local PL/SQL tables with latest manager chain
      get_manager_chain
       (p_person_id        => p_person_id,
        p_effective_date   => l_loop_date,
        p_hier_psn_tab     => l_hier_psn_tab,
        p_hier_asg_tab     => l_hier_asg_tab,
        p_hier_bgr_tab     => l_hier_bgr_tab,
        p_hier_sup_tab     => l_hier_sup_tab,
        p_hier_ast_tab     => l_hier_ast_tab,
        p_hier_end_tab     => l_hier_end_tab,
        p_hier_aty_tab     => l_hier_aty_tab,
        p_next_change_date => l_next_loop_date);

      -- If no data is returned then there is some data problem since
      -- the loop date is within an active period of service
      -- Print the issue to the log and exit the loop
      IF (NOT l_hier_psn_tab.EXISTS(1)) THEN

        output('No chain found for person ' || to_char(p_person_id) ||
              ' on ' || to_char(l_loop_date, 'DD-MON-YYYY'));

        -- Set flag to exit loop
        l_exit_loop := 'Y';

      ELSE

        -- Test for orphan chain
        -- Chain is an orphan if the top manager, ordered last, has a
        -- not-null supervisor id
        IF (l_hier_sup_tab(l_hier_psn_tab.LAST) = -1) THEN
          l_orphan_flag := 'N';
        ELSE
          l_orphan_flag := 'Y';
        END IF;

        -- Process chain
        process_chain
         (p_new_psn_tab    => l_hier_psn_tab,
          p_new_asg_tab    => l_hier_asg_tab,
          p_new_bgr_tab    => l_hier_bgr_tab,
          p_new_sup_tab    => l_hier_sup_tab,
          p_new_ast_tab    => l_hier_ast_tab,
          p_new_end_tab    => l_hier_end_tab,
          p_new_aty_tab    => l_hier_aty_tab,
          p_orphan_flag    => l_orphan_flag,
          p_chain_table    => l_chain_table,
          p_loop_date      => l_loop_date,
          p_next_loop_date => l_next_loop_date);

        -- Set new loop date
        l_loop_date := l_next_loop_date;

      END IF;

    END LOOP;

  END IF;

END process_period_of_work;

-- ----------------------------------------------------------------------------
-- Calls process_period_of_work with the start and end dates for each active
-- period of service in the collection range
-- ----------------------------------------------------------------------------
PROCEDURE process_person(p_person_id          IN NUMBER,
                         p_refresh_from_date  IN DATE) IS

  -- Gets all periods of work for a person
  CURSOR period_of_work_csr IS
  SELECT
   GREATEST(pos.date_start,
            p_refresh_from_date)  start_date
  ,LEAST(NVL(pos.actual_termination_date, g_end_of_time),
         g_end_of_time)  end_date
  FROM
   per_periods_of_service pos
  WHERE pos.person_id = p_person_id
  AND (p_refresh_from_date BETWEEN pos.date_start
                           AND NVL(pos.actual_termination_date, g_end_of_time)
    OR pos.date_start > p_refresh_from_date)
  UNION ALL
  SELECT
   GREATEST(pop.date_start,
            p_refresh_from_date)  start_date
  ,LEAST(NVL(pop.actual_termination_date, g_end_of_time),
         g_end_of_time)  end_date
  FROM
   per_periods_of_placement  pop
  WHERE pop.person_id = p_person_id
  AND (p_refresh_from_date BETWEEN pop.date_start
                           AND NVL(pop.actual_termination_date, g_end_of_time)
    OR pop.date_start > p_refresh_from_date);

BEGIN

  -- Loop through periods of work
  FOR pow_rec IN period_of_work_csr LOOP

    -- Process the period of work
    process_period_of_work
     (p_person_id  => p_person_id
     ,p_start_date => pow_rec.start_date
     ,p_end_date   => pow_rec.end_date);

  END LOOP;

END process_person;

-- ----------------------------------------------------------------------------
-- Main process entry point
-- ----------------------------------------------------------------------------
PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_mthd_action_id   IN NUMBER,
                        p_mthd_range_id    IN NUMBER,
                        p_start_object_id  IN NUMBER,
                        p_end_object_id    IN NUMBER) IS

  CURSOR person_csr_full IS
  SELECT DISTINCT
   ase.person_id
  FROM
   hri_cs_asgn_suph_events_ct ase
  WHERE ase.person_id BETWEEN p_start_object_id and p_end_object_id
  AND ase.effective_end_date >= g_refresh_start_date;

  CURSOR person_csr_incr IS
  SELECT DISTINCT
   eq.person_id
  ,eq.erlst_evnt_effective_date  change_date
  FROM
   hri_eq_sprvsr_hrchy_chgs eq
  WHERE eq.person_id BETWEEN p_start_object_id and p_end_object_id;

BEGIN

  -- Initialization
  g_suph_row_count := 0;
  g_chn_row_count  := 0;
  g_trn_row_count  := 0;

  -- Set parameter globals
  set_parameters(p_mthd_action_id);

  -- Full refresh
  IF (g_full_refresh = 'Y') THEN

    -- Loop through all employees in range
    FOR person_rec IN person_csr_full LOOP

      -- Process each person from refresh start date
      process_person(p_person_id => person_rec.person_id,
                     p_refresh_from_date => g_refresh_start_date);
    END LOOP;

  -- Incremental refresh
  ELSE

    -- Loop through all employees in range
    FOR person_rec IN person_csr_incr LOOP

      -- Process each person from their earliest change date
      process_person(p_person_id => person_rec.person_id,
                     p_refresh_from_date => person_rec.change_date);
    END LOOP;

    -- Delete and end date supervisor hierarchy rows
    delete_and_end_date_suph_recs
     (p_start_person_id => p_start_object_id,
      p_end_person_id   => p_end_object_id);

    -- Remove transfer records for range
    hri_opl_wrkfc_trnsfr_events.delete_transfers_mgrh
     (p_start_object_id => p_start_object_id,
      p_end_object_id   => p_end_object_id);

  END IF;

  -- Insert stored rows
  IF g_suph_row_count > 0 THEN
    bulk_insert_rows;
  END IF;

  -- Flush log messages
  hri_bpl_conc_log.flush_process_info('HRI_CS_SUPH');

END process_range;

-- ----------------------------------------------------------------------------
-- Pre process entry point
-- ----------------------------------------------------------------------------
PROCEDURE pre_process(p_mthd_action_id  IN NUMBER,
                      p_sqlstr          OUT NOCOPY VARCHAR2) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Set parameter globals
  set_parameters( p_mthd_action_id => p_mthd_action_id );

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Disable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_SUPH_WHO DISABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_MNGRSC_CT_WHO DISABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_MGRH_TRANSFERS_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y') THEN

    -- Drop all the indexes on the table (except the unique index)
    hri_utl_ddl.log_and_drop_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_SUPH',
      p_table_owner            => l_schema,
      p_index_excptn_lst       => 'HRI_CS_SUPH_U1');
    hri_utl_ddl.log_and_drop_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_MNGRSC_CT',
      p_table_owner            => l_schema,
      p_index_excptn_lst       => 'HRI_CS_MNGRSC_CT_U1');
    hri_utl_ddl.log_and_drop_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MDP_MGRH_TRANSFERS_CT',
      p_table_owner            => l_schema,
      p_index_excptn_lst       => 'HRI_MDP_MGRH_TRANSFERS_CT_U1');

    -- Empty out supervisor hierarchy history table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_SUPH';
    EXECUTE IMMEDIATE(l_sql_stmt);
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_MNGRSC_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MDP_MGRH_TRANSFERS_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- Insert chain lookup
    g_chn_row_count := 0;
    insert_chn_row
     (p_person_id     => -1
     ,p_assignment_id => -1
     ,p_start_date    => hr_general.start_of_time
     ,p_end_date      => g_end_of_time
     ,p_chain_id      => -1
     ,p_person_level  => to_number(null));
    bulk_insert_rows;

    -- Set the SQL statement for the entire range
    p_sqlstr :=
      'SELECT DISTINCT person_id  object_id
       FROM hri_cs_asgn_suph_events_ct
       ORDER BY person_id';

  -- ***************************
  -- Incremental refresh section
  -- ***************************
  ELSE

    -- STEP A - Populate the person_id column in events queue
    --          and remove events that are not required
    update_event_queue;

    -- STEP B - Find Subordinates
    find_subordinates;

    -- STEP C - Remove Duplicates
    remove_duplicates;

    -- STEP D - Delete Records After last Change
    -- STEP E - End Date Prior Records
    --   These steps are done by process_range
    --   for each chunk to ensure consistency of
    --   table during incremental load

    -- 4259598 Incremental Changes
    -- Populate the assignment event delta queue in order to incrementally refresh
    -- the assignment delta table
    populate_asg_delta_eq;
    -- Populate workforce events fact event queue
    populate_wrkfc_evt_eq;
    -- Populate workforce events by manager event queue
    populate_wrkfc_evt_mgrh_eq;

    -- Set the SQL statement for the entire range
    p_sqlstr :=
      'SELECT person_id  object_id
       FROM hri_eq_sprvsr_hrchy_chgs
       ORDER BY person_id';

  END IF;

END pre_process;

-- ----------------------------------------------------------------------------
-- Post process entry point
-- ----------------------------------------------------------------------------
PROCEDURE post_process(p_mthd_action_id NUMBER) IS

  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Check parameters are set
  set_parameters(p_mthd_action_id);

  -- Get HRI schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_SUPH_WHO ENABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_MNGRSC_CT_WHO ENABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_MGRH_TRANSFERS_CT_WHO ENABLE');

  -- Recreate indexes if they were dropped (full refresh)
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_SUPH',
      p_table_owner            => l_schema);
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_MNGRSC_CT',
      p_table_owner            => l_schema);
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MDP_MGRH_TRANSFERS_CT',
      p_table_owner            => l_schema);
  END IF;

  -- As the supervisor hierarchy has been rebuilt, purge the events queue
  hri_opl_event_capture.purge_queue('HRI_EQ_SPRVSR_HRCHY_CHGS');

  IF (p_mthd_action_id > -1) THEN

    -- Log process end
    hri_bpl_conc_log.record_process_start('HRI_CS_SUPH');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

END post_process;

-- --------------------------------------------
-- API to run single thread incremental refresh
-- --------------------------------------------
PROCEDURE incremental_refresh_single IS

  l_dummy   VARCHAR2(32000);

  CURSOR sup_event_queue_csr IS
  SELECT
   person_id
  ,erlst_evnt_effective_date  start_date
  FROM
   hri_eq_sprvsr_hrchy_chgs;

BEGIN

  -- Set globals
  g_debug := TRUE;
  g_full_refresh := 'N';
  g_refresh_start_date := trunc(sysdate);

  -- Pre process
  pre_process(-1, l_dummy);

  -- Loop through supervisors in event queue
  FOR sup_rec IN sup_event_queue_csr LOOP
    process_person(sup_rec.person_id, sup_rec.start_date);
  END LOOP;

  -- Post process
  post_process(-1);

END incremental_refresh_single;

-- --------------------------------------------
-- API to run single thread full refresh
-- --------------------------------------------
PROCEDURE full_refresh_single IS

  CURSOR psn_csr IS
  SELECT DISTINCT person_id
  FROM hri_cs_asgn_suph_events_ct
  WHERE primary_flag = 'Y';

  l_dummy   VARCHAR2(32000);

BEGIN

  -- Set globals
  g_debug := FALSE;
  g_full_refresh := 'Y';
  g_refresh_start_date := g_dbi_collection_start_date;

  -- Pre process
  pre_process(-1, l_dummy);

  -- Set number of rows to 0
  g_suph_row_count := 0;
  g_chn_row_count  := 0;
  g_trn_row_count  := 0;

  -- Loop through all employees
  FOR psn_rec IN psn_csr LOOP

    process_person(psn_rec.person_id, g_dbi_collection_start_date);

    -- Insert stored rows
    IF g_suph_row_count > 2000 THEN
      bulk_insert_rows;
    END IF;

  END LOOP;

  -- Insert stored rows
  IF g_suph_row_count > 0 THEN
    bulk_insert_rows;
  END IF;

  -- Post process
  post_process(-1);

END full_refresh_single;

-- ---------------------------------------------
-- API to run a full refresh for a single person
-- ---------------------------------------------
PROCEDURE run_for_person(p_person_id  IN NUMBER) IS

BEGIN

  debug('Start');

  DELETE FROM hri_cs_suph
  WHERE sub_person_id = p_person_id;

  g_suph_row_count := 0;
  g_chn_row_count  := 0;

  process_person(p_person_id, g_dbi_collection_start_date);

  -- Insert stored rows
  IF g_suph_row_count > 0 THEN
    bulk_insert_rows;
  END IF;

  debug('End');

END run_for_person;

END hri_opl_suph_hst;

/
