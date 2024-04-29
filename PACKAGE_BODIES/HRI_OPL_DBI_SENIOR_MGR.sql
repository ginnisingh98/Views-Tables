--------------------------------------------------------
--  DDL for Package Body HRI_OPL_DBI_SENIOR_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_DBI_SENIOR_MGR" AS
/* $Header: hriodmgr.pkb 120.1 2005/10/10 01:53:43 anmajumd noship $ */

  g_max_period_length   NUMBER := 365;

PROCEDURE load_senior_mgrs IS

  l_senior_mgr_threshold   NUMBER;
  l_sql_stmt      VARCHAR2(1000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

/* Truncate tables */
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CL_PER_SNRMGR_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CL_PER_SNAP_PRDS_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);
  END IF;

/* If snapshots are enabled then reload the tables */
  IF (fnd_profile.value('HRI_DBI_PER_SNRMGR_SNPSHTS') = 'Y') THEN

  /* Get threshold from profile option */
    l_senior_mgr_threshold := fnd_profile.value('HRI_DBI_PER_SNRMGR_THRSHLD');

  /* Default the value if the profile option is not populated */
    IF (l_senior_mgr_threshold IS NULL) THEN
      l_senior_mgr_threshold := 2500;
    END IF;

  /* Populate the senior manager list of values */
    INSERT INTO hri_cl_per_snrmgr_ct
     (id
     ,value
     ,start_date
     ,end_date
     ,snapshot_start_date
     ,snapshot_end_date)
      SELECT
       hsal.supervisor_person_id
      ,hsal.supervisor_person_id
      ,MIN(effective_start_date)
      ,MAX(effective_end_date)
      ,MIN(effective_start_date)
      ,MAX(effective_end_date)
      FROM
       hri_mdp_sup_wcnt_sup_mv  hsal
      WHERE hsal.total_headcount > l_senior_mgr_threshold
      GROUP BY
       hsal.supervisor_person_id;

  /* Commit */
    commit;

  /* Populate the snapshot periods table with the senior managers and */
  /* their direct reports and the date ranges in which to snapshot */
    INSERT INTO hri_cl_per_snap_prds_ct
     (id
     ,value
     ,snapshot_start_date
     ,snapshot_end_date
     ,senior_manager_flag)
      SELECT
       id
      ,value
      ,MIN(snapshot_start_date)  snapshot_start_date
      ,MAX(snapshot_end_date)    snapshot_end_date
      ,DECODE(SUM(senior_manager_ind), 1, 'Y', 'N')
                                 senior_manager_flag
      FROM
       (SELECT
         tab.person_id                       id
        ,to_char(tab.person_id)              VALUE
        ,GREATEST(MIN(sub_mgr.effective_start_date),
                  tab.snapshot_start_date)   snapshot_start_date
/* Snapshot period should continue for the length of the longest period */
/* beyond the subordinate having manager status so that snapshots */
/* are available - bug 4300189 */
        ,LEAST(MAX(sub_mgr.effective_end_date) + g_max_period_length,
               tab.snapshot_end_date)        snapshot_end_date
        ,0                                   senior_manager_ind
        FROM
         (SELECT /*+ ORDERED USE_NL(sub) */
           sub.person_id
          ,GREATEST(MIN(snrmgr.snapshot_start_date),
                    MIN(sub.effective_change_date))
                     snapshot_start_date
          ,LEAST(MAX(snrmgr.snapshot_end_date),
                 MAX(sub.effective_change_end_date))
                     snapshot_end_date
          FROM
           hri_cl_per_snrmgr_ct  snrmgr
          ,hri_mb_asgn_events_ct sub
          WHERE sub.supervisor_id = snrmgr.id
    /* Non-terminated primary subordinates */
          AND sub.worker_term_ind = 0
          AND sub.primary_flag = 'Y'
    /* Slicing date join */
          AND (sub.effective_change_date BETWEEN snrmgr.snapshot_start_date
                                         AND snrmgr.snapshot_end_date
            OR snrmgr.snapshot_start_date BETWEEN sub.effective_change_date
                                          AND sub.effective_change_end_date)
          GROUP BY
           sub.person_id
         )  tab
         ,hri_cl_wkr_sup_status_ct  sub_mgr
        WHERE tab.person_id = sub_mgr.person_id
  /* Who are supervisors during the snapshot period or in the year preceding */
        AND sub_mgr.supervisor_flag = 'Y'
  /* Slicing Date Join including rolling year (365 days) preceding */
        AND (tab.snapshot_start_date - g_max_period_length
                BETWEEN sub_mgr.effective_start_date
                AND sub_mgr.effective_end_date
          OR sub_mgr.effective_start_date
                BETWEEN tab.snapshot_start_date - g_max_period_length
                AND tab.snapshot_end_date)
        GROUP BY
         tab.person_id
        ,tab.snapshot_start_date
        ,tab.snapshot_end_date
        UNION ALL
        SELECT
         id
        ,VALUE
        ,snapshot_start_date
        ,snapshot_end_date
        ,1
        FROM hri_cl_per_snrmgr_ct
       )
      GROUP BY
       id
      ,value;

  /* Commit */
    commit;

  END IF;

END load_senior_mgrs;

PROCEDURE load_senior_mgrs(errbuf    OUT NOCOPY VARCHAR2,
                           retcode   OUT NOCOPY VARCHAR2) IS

BEGIN

  load_senior_mgrs;

END load_senior_mgrs;

END hri_opl_dbi_senior_mgr;

/
