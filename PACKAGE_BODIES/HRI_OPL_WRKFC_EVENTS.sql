--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WRKFC_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WRKFC_EVENTS" AS
/* $Header: hriowevt.pkb 120.12.12000000.2 2007/04/12 13:22:41 smohapat noship $ */

  -- End of time
  g_end_of_time    DATE := hr_general.end_of_time;

  -- Global HRI Multithreading Array
  g_mthd_action_array       HRI_ADM_MTHD_ACTIONS%rowtype;

  -- Global parameters
  g_refresh_start_date      DATE;
  g_full_refresh            VARCHAR2(30);
  g_sysdate                 DATE;
  g_user                    NUMBER;
  g_dbi_start_date          DATE;


-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS

BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  null;

END run_sql_stmt_noerr;

-- ----------------------------------------------------------------------------
-- Sets global parameters from multi-threading process parameters
-- ----------------------------------------------------------------------------
PROCEDURE set_parameters(p_mthd_action_id   IN NUMBER,
                         p_mthd_stage_code  IN VARCHAR2) IS

  l_dbi_collection_start_date     DATE;

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL OR
      p_mthd_stage_code = 'PRE_PROCESS') THEN

    l_dbi_collection_start_date :=
           hri_oltp_conc_param.get_date_parameter_value
            (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
             p_process_table_name => 'HRI_MB_WRKFC_EVT_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh :=
           hri_oltp_conc_param.get_parameter_value
            (p_parameter_name     => 'FULL_REFRESH',
             p_process_table_name => 'HRI_MB_WRKFC_EVT_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => l_dbi_collection_start_date);

    END IF;

    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_sysdate              := sysdate;
    g_user                 := fnd_global.user_id;
    g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:    N/A');

  END IF;

END set_parameters;


-- ----------------------------------------------------------------------------
-- Processes  base fact in full refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_month_summary_full(p_start_asg_id    IN NUMBER,
                                     p_end_asg_id      IN NUMBER) IS

BEGIN

  INSERT INTO hri_mds_wrkfc_mnth_ct
   (wevt_evtypcmb_fk
   ,asg_assgnmnt_fk
   ,per_person_fk
   ,per_person_mgr_fk
   ,per_person_mgr_prv_fk
   ,mgr_mngrsc_fk
   ,mgr_mngrsc_prv_fk
   ,org_organztn_fk
   ,org_organztn_prv_fk
   ,job_job_fk
   ,job_job_prv_fk
   ,grd_grade_fk
   ,grd_grade_prv_fk
   ,pos_position_fk
   ,pos_position_prv_fk
   ,geo_location_fk
   ,geo_location_prv_fk
   ,asgrsn_asgrsn_fk
   ,sprn_sprtnrsn_fk
   ,scat_spcatgry_fk
   ,ptyp_pertyp_fk
   ,prfm_perfband_fk
   ,pow_powband_fk
   ,time_month_snp_fk
   ,time_day_mnth_start_fk
   ,time_day_mnth_end_fk
   ,time_quarter_fk
   ,time_year_fk
   ,cur_currency_fk
   ,headcount_start
   ,headcount_end
   ,headcount_hire
   ,headcount_term
   ,headcount_sep_vol
   ,headcount_sep_invol
   ,headcount_prmtn
   ,fte_start
   ,fte_end
   ,fte_hire
   ,fte_term
   ,fte_sep_vol
   ,fte_sep_invol
   ,fte_prmtn
   ,count_pasg_end
   ,count_pasg_hire
   ,count_pasg_term
   ,count_pasg_sep_vol
   ,count_pasg_sep_invol
   ,count_asg_end
   ,count_asg_hire
   ,count_asg_term
   ,count_asg_sep_vol
   ,count_asg_sep_invol
   ,count_asg_prmtn
   ,pow_days_on_end_date
   ,pow_months_on_end_date
   ,days_since_last_prmtn
   ,months_since_last_prmtn
   ,anl_slry_start
   ,anl_slry_end
   ,employee_ind
   ,contingent_ind
   ,last_month_in_qtr_ind
   ,last_month_in_year_ind
   ,adt_pow_band
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_login
   ,last_update_date)
    SELECT
     to_number(null)               wevt_evtypcmb_fk
    ,fct.asg_assgnmnt_fk
    ,fct.per_person_fk
    ,fct.per_person_mgr_fk
    ,fct.per_person_mgr_prv_fk
    ,fct.mgr_mngrsc_fk
    ,fct.mgr_mngrsc_prv_fk
    ,fct.org_organztn_fk
    ,fct.org_organztn_prv_fk
    ,fct.job_job_fk
    ,fct.job_job_prv_fk
    ,fct.grd_grade_fk
    ,fct.grd_grade_prv_fk
    ,fct.pos_position_fk
    ,fct.pos_position_prv_fk
    ,fct.geo_location_fk
    ,fct.geo_location_prv_fk
    ,fct.asgrsn_asgrsn_fk
    ,fct.sprn_sprtnrsn_fk
    ,fct.scat_spcatgry_fk
    ,fct.ptyp_pertyp_fk
    ,fct.prfm_perfband_fk
    ,fct.pow_powband_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_month_snp_fk
          ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
     END                           time_month_snp_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_start_fk
          ELSE msrs.time_day_mnth_end_fk + 1
     END                           time_day_mnth_start_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_end_fk
          ELSE ADD_MONTHS(msrs.time_day_mnth_start_fk, 2) - 1
     END                           time_day_mnth_end_fk
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 100, 0)                 time_quarter_end_fk
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 1000, 0)                time_year_end_fk
    ,fct.cur_currency_fk
    ,SUM(msrs.headcount_start)
    ,SUM(msrs.headcount_end)
    ,SUM(msrs.headcount_hire)
    ,SUM(msrs.headcount_term)
    ,SUM(msrs.headcount_sep_vol)
    ,SUM(msrs.headcount_sep_invol)
    ,SUM(msrs.headcount_prmtn)
    ,SUM(msrs.fte_start)
    ,SUM(msrs.fte_end)
    ,SUM(msrs.fte_hire)
    ,SUM(msrs.fte_term)
    ,SUM(msrs.fte_sep_vol)
    ,SUM(msrs.fte_sep_invol)
    ,SUM(msrs.fte_prmtn)
    ,SUM(msrs.count_pasg_end)
    ,SUM(msrs.count_pasg_hire)
    ,SUM(msrs.count_pasg_term)
    ,SUM(msrs.count_pasg_sep_vol)
    ,SUM(msrs.count_pasg_sep_invol)
    ,SUM(msrs.count_asg_end)
    ,SUM(msrs.count_asg_hire)
    ,SUM(msrs.count_asg_term)
    ,SUM(msrs.count_asg_sep_vol)
    ,SUM(msrs.count_asg_sep_invol)
    ,SUM(msrs.count_asg_prmtn)
    ,SUM(msrs.pow_days_on_end_date)
    ,SUM(msrs.pow_months_on_end_date)
    ,SUM(msrs.days_since_last_prmtn)
    ,SUM(msrs.months_since_last_prmtn)
    ,SUM(msrs.anl_slry_start)
    ,SUM(msrs.anl_slry_end)
    ,fct.employee_ind
    ,fct.contingent_ind
    ,msrs.last_month_in_qtr_ind
    ,msrs.last_month_in_year_ind
    ,fct.adt_pow_band
    ,g_sysdate
    ,g_user
    ,g_user
    ,g_user
    ,g_sysdate
    FROM
     (SELECT
       wevt.asg_assgnmnt_fk
      ,wevt.per_person_fk
      ,wevt.per_person_mgr_fk
      ,NVL(LAG(wevt.per_person_mgr_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                                ORDER BY mnth.month_id)
          ,-1)                       per_person_mgr_prv_fk
      ,wevt.mgr_mngrsc_fk
      ,NVL(LAG(wevt.mgr_mngrsc_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                            ORDER BY mnth.month_id)
          ,-1)                       mgr_mngrsc_prv_fk
      ,wevt.org_organztn_fk
      ,NVL(LAG(wevt.org_organztn_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       org_organztn_prv_fk
      ,wevt.job_job_fk
      ,NVL(LAG(wevt.job_job_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                         ORDER BY mnth.month_id)
          ,-1)                       job_job_prv_fk
      ,wevt.grd_grade_fk
      ,NVL(LAG(wevt.grd_grade_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                           ORDER BY mnth.month_id)
          ,-1)                       grd_grade_prv_fk
      ,wevt.pos_position_fk
      ,NVL(LAG(wevt.pos_position_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       pos_position_prv_fk
      ,wevt.geo_location_fk
      ,NVL(LAG(wevt.geo_location_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       geo_location_prv_fk
      ,wevt.asgrsn_asgrsn_fk
      ,wevt.sprn_sprtnrsn_fk
      ,wevt.scat_spcatgry_fk
      ,wevt.ptyp_pertyp_fk
      ,wevt.prfm_perfband_fk
      ,wevt.pow_powband_fk
      ,mnth.month_id                 time_month_snp_fk
      ,wevt.cur_currency_fk
      ,wevt.employee_ind
      ,wevt.contingent_ind
      ,wevt.adt_pow_band
      FROM
       hri_mb_wrkfc_evt_ct   wevt
      ,fii_time_month        mnth
      WHERE  mnth.end_date BETWEEN wevt.time_day_evt_fk
                           AND wevt.time_day_evt_end_fk
-- If assignment is ended, only snapshot the ended assignment once
      AND ((wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0)
        OR mnth.start_date <= wevt.time_day_evt_fk)
      AND wevt.asg_assgnmnt_fk BETWEEN p_start_asg_id
                                 AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.start_date <= TRUNC(g_sysdate)
     )      fct
    ,(SELECT
       mnth.month_id          time_month_snp_fk
      ,mnth.start_date        time_day_mnth_start_fk
      ,mnth.end_date          time_day_mnth_end_fk
      ,wevt.asg_assgnmnt_fk   asg_assgnmnt_fk
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.headcount
                ELSE 0
           END)               headcount_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.headcount
                ELSE 0
           END)               headcount_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_hire
                ELSE 0
           END)               headcount_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term
                ELSE 0
           END)               headcount_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term * wevt.term_voluntary_ind
                ELSE 0
           END)               headcount_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term * wevt.term_involuntary_ind
                ELSE 0
           END)               headcount_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount * wevt.promotion_ind
                ELSE 0
           END)               headcount_prmtn
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.fte
                ELSE 0
           END)               fte_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.fte
                ELSE 0
           END)               fte_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_hire
                ELSE 0
           END)               fte_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term
                ELSE 0
           END)               fte_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term * wevt.term_voluntary_ind
                ELSE 0
           END)               fte_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term * wevt.term_involuntary_ind
                ELSE 0
           END)               fte_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte * wevt.promotion_ind
                ELSE 0
           END)               fte_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.primary_ind
                ELSE 0
           END)               count_pasg_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.hire_or_start_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_or_end_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_voluntary_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_involuntary_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_sep_invol
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN 1
                ELSE 0
           END)               count_asg_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.hire_or_start_ind
                ELSE 0
           END)               count_asg_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_or_end_ind
                ELSE 0
           END)               count_asg_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_voluntary_ind
                ELSE 0
           END)               count_asg_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_involuntary_ind
                ELSE 0
           END)               count_asg_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.promotion_ind
                ELSE 0
           END)               count_asg_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.pow_days_on_event_date +
                     (mnth.end_date - wevt.time_day_evt_fk)
                ELSE 0
           END)               pow_days_on_end_date
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN MONTHS_BETWEEN
                     (mnth.end_date,
                      wevt.time_day_evt_fk - wevt.pow_days_on_event_date)
                ELSE 0
           END)               pow_months_on_end_date
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.days_since_last_prmtn +
                     (mnth.end_date - wevt.time_day_evt_fk)
                ELSE 0
           END)               days_since_last_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN MONTHS_BETWEEN
                     (mnth.end_date,
                      wevt.time_day_evt_fk - wevt.days_since_last_prmtn)
                ELSE 0
           END)               months_since_last_prmtn
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.anl_slry
                ELSE 0
           END)               anl_slry_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.anl_slry
                ELSE 0
           END)               anl_slry_end
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Q'), 3) - 1
            THEN 1
            WHEN MAX(wevt.worker_term_ind) = 1 OR MAX(wevt.pre_sprtn_asgn_end_ind) = 1
            THEN 1
            WHEN TRUNC(g_sysdate) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_qtr_ind
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Y'), 12) - 1
            THEN 1
            WHEN MAX(wevt.worker_term_ind) = 1 OR MAX(wevt.pre_sprtn_asgn_end_ind) = 1
            THEN 1
            WHEN TRUNC(g_sysdate) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_year_ind
      ,0                      zero_row_ind
      FROM
       hri_mb_wrkfc_evt_ct  wevt
      ,fii_time_month       mnth
      WHERE wevt.time_day_evt_fk <= mnth.end_date
      AND mnth.start_date <= wevt.time_day_evt_end_fk
-- If assignment is ended, only snapshot the ended assignment once
      AND ((wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0)
        OR mnth.start_date <= wevt.time_day_evt_fk)
      AND wevt.asg_assgnmnt_fk BETWEEN p_start_asg_id
                                 AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.start_date <= TRUNC(g_sysdate)
      GROUP BY
       mnth.month_id
      ,mnth.start_date
      ,mnth.end_date
      ,wevt.asg_assgnmnt_fk
      UNION ALL
      SELECT
       mnth.month_id          time_month_snp_fk
      ,mnth.start_date        time_day_mnth_start_fk
      ,mnth.end_date          time_day_mnth_end_fk
      ,wevt.asg_assgnmnt_fk   asg_assgnmnt_fk
      ,0                      headcount_start
      ,0                      headcount_end
      ,0                      headcount_hire
      ,0                      headcount_term
      ,0                      headcount_sep_vol
      ,0                      headcount_sep_invol
      ,0                      headcount_prmtn
      ,0                      fte_start
      ,0                      fte_end
      ,0                      fte_hire
      ,0                      fte_term
      ,0                      fte_sep_vol
      ,0                      fte_sep_invol
      ,0                      fte_prmtn
      ,0                      count_pasg_end
      ,0                      count_pasg_hire
      ,0                      count_pasg_term
      ,0                      count_pasg_sep_vol
      ,0                      count_pasg_sep_invol
      ,0                      count_asg_end
      ,0                      count_asg_hire
      ,0                      count_asg_term
      ,0                      count_asg_sep_vol
      ,0                      count_asg_sep_invol
      ,0                      count_asg_prmtn
      ,0                      pow_days_on_end_date
      ,0                      pow_months_on_end_date
      ,to_number(null)        days_since_last_prmtn
      ,to_number(null)        months_since_last_prmtn
      ,0                      anl_slry_start
      ,0                      anl_slry_end
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Q'), 2) - 1
            THEN 1
            WHEN wevt.worker_term_nxt_ind = 1 OR wevt.pre_sprtn_asgn_end_nxt_ind = 1
            THEN 1
            WHEN ADD_MONTHS(TRUNC(g_sysdate), -1) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_qtr_ind
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Y'), 11) - 1
            THEN 1
            WHEN wevt.worker_term_nxt_ind = 1 OR wevt.pre_sprtn_asgn_end_nxt_ind = 1
            THEN 1
            WHEN ADD_MONTHS(TRUNC(g_sysdate), -1) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_year_ind
      ,1                      zero_row_ind
      FROM
       hri_mb_wrkfc_evt_ct  wevt
      ,fii_time_month       mnth
      WHERE mnth.end_date BETWEEN wevt.time_day_evt_fk
                          AND wevt.time_day_evt_end_fk
-- If assignment is ended, no need to snapshot
      AND wevt.worker_term_ind = 0
      AND wevt.pre_sprtn_asgn_end_ind = 0
      AND wevt.asg_assgnmnt_fk BETWEEN p_start_asg_id
                                 AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.end_date < TRUNC(g_sysdate)
     )    msrs
    WHERE msrs.asg_assgnmnt_fk =  fct.asg_assgnmnt_fk
    AND msrs.time_month_snp_fk = fct.time_month_snp_fk
    GROUP BY
     fct.asg_assgnmnt_fk
    ,fct.per_person_fk
    ,fct.per_person_mgr_fk
    ,fct.per_person_mgr_prv_fk
    ,fct.mgr_mngrsc_fk
    ,fct.mgr_mngrsc_prv_fk
    ,fct.org_organztn_fk
    ,fct.org_organztn_prv_fk
    ,fct.job_job_fk
    ,fct.job_job_prv_fk
    ,fct.grd_grade_fk
    ,fct.grd_grade_prv_fk
    ,fct.pos_position_fk
    ,fct.pos_position_prv_fk
    ,fct.geo_location_fk
    ,fct.geo_location_prv_fk
    ,fct.asgrsn_asgrsn_fk
    ,fct.sprn_sprtnrsn_fk
    ,fct.scat_spcatgry_fk
    ,fct.ptyp_pertyp_fk
    ,fct.prfm_perfband_fk
    ,fct.pow_powband_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_month_snp_fk
          ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
     END
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_start_fk
          ELSE msrs.time_day_mnth_end_fk + 1
     END
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_end_fk
          ELSE ADD_MONTHS(msrs.time_day_mnth_start_fk, 2) - 1
     END
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 100, 0)
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 1000, 0)
    ,fct.cur_currency_fk
    ,fct.employee_ind
    ,fct.contingent_ind
    ,msrs.last_month_in_qtr_ind
    ,msrs.last_month_in_year_ind
    ,fct.adt_pow_band;

  -- Commit
  COMMIT;

END process_month_summary_full;


-- ----------------------------------------------------------------------------
-- Processes  base fact in incremental refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_month_summary_incr(p_start_asg_id    IN NUMBER,
                                     p_end_asg_id      IN NUMBER) IS

BEGIN

  INSERT INTO hri_mds_wrkfc_mnth_ct
   (wevt_evtypcmb_fk
   ,asg_assgnmnt_fk
   ,per_person_fk
   ,per_person_mgr_fk
   ,per_person_mgr_prv_fk
   ,mgr_mngrsc_fk
   ,mgr_mngrsc_prv_fk
   ,org_organztn_fk
   ,org_organztn_prv_fk
   ,job_job_fk
   ,job_job_prv_fk
   ,grd_grade_fk
   ,grd_grade_prv_fk
   ,pos_position_fk
   ,pos_position_prv_fk
   ,geo_location_fk
   ,geo_location_prv_fk
   ,asgrsn_asgrsn_fk
   ,sprn_sprtnrsn_fk
   ,scat_spcatgry_fk
   ,ptyp_pertyp_fk
   ,prfm_perfband_fk
   ,pow_powband_fk
   ,time_month_snp_fk
   ,time_day_mnth_start_fk
   ,time_day_mnth_end_fk
   ,time_quarter_fk
   ,time_year_fk
   ,cur_currency_fk
   ,headcount_start
   ,headcount_end
   ,headcount_hire
   ,headcount_term
   ,headcount_sep_vol
   ,headcount_sep_invol
   ,headcount_prmtn
   ,fte_start
   ,fte_end
   ,fte_hire
   ,fte_term
   ,fte_sep_vol
   ,fte_sep_invol
   ,fte_prmtn
   ,count_pasg_end
   ,count_pasg_hire
   ,count_pasg_term
   ,count_pasg_sep_vol
   ,count_pasg_sep_invol
   ,count_asg_end
   ,count_asg_hire
   ,count_asg_term
   ,count_asg_sep_vol
   ,count_asg_sep_invol
   ,count_asg_prmtn
   ,pow_days_on_end_date
   ,pow_months_on_end_date
   ,days_since_last_prmtn
   ,months_since_last_prmtn
   ,anl_slry_start
   ,anl_slry_end
   ,employee_ind
   ,contingent_ind
   ,last_month_in_qtr_ind
   ,last_month_in_year_ind
   ,adt_pow_band
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_login
   ,last_update_date)
    SELECT
     to_number(null)               wevt_evtypcmb_fk
    ,fct.asg_assgnmnt_fk
    ,fct.per_person_fk
    ,fct.per_person_mgr_fk
    ,fct.per_person_mgr_prv_fk
    ,fct.mgr_mngrsc_fk
    ,fct.mgr_mngrsc_prv_fk
    ,fct.org_organztn_fk
    ,fct.org_organztn_prv_fk
    ,fct.job_job_fk
    ,fct.job_job_prv_fk
    ,fct.grd_grade_fk
    ,fct.grd_grade_prv_fk
    ,fct.pos_position_fk
    ,fct.pos_position_prv_fk
    ,fct.geo_location_fk
    ,fct.geo_location_prv_fk
    ,fct.asgrsn_asgrsn_fk
    ,fct.sprn_sprtnrsn_fk
    ,fct.scat_spcatgry_fk
    ,fct.ptyp_pertyp_fk
    ,fct.prfm_perfband_fk
    ,fct.pow_powband_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_month_snp_fk
          ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
     END                           time_month_snp_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_start_fk
          ELSE msrs.time_day_mnth_end_fk + 1
     END                           time_day_mnth_start_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_end_fk
          ELSE ADD_MONTHS(msrs.time_day_mnth_start_fk, 2) - 1
     END                           time_day_mnth_end_fk
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 100, 0)                 time_quarter_end_fk
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 1000, 0)                time_year_end_fk
    ,fct.cur_currency_fk
    ,SUM(msrs.headcount_start)
    ,SUM(msrs.headcount_end)
    ,SUM(msrs.headcount_hire)
    ,SUM(msrs.headcount_term)
    ,SUM(msrs.headcount_sep_vol)
    ,SUM(msrs.headcount_sep_invol)
    ,SUM(msrs.headcount_prmtn)
    ,SUM(msrs.fte_start)
    ,SUM(msrs.fte_end)
    ,SUM(msrs.fte_hire)
    ,SUM(msrs.fte_term)
    ,SUM(msrs.fte_sep_vol)
    ,SUM(msrs.fte_sep_invol)
    ,SUM(msrs.fte_prmtn)
    ,SUM(msrs.count_pasg_end)
    ,SUM(msrs.count_pasg_hire)
    ,SUM(msrs.count_pasg_term)
    ,SUM(msrs.count_pasg_sep_vol)
    ,SUM(msrs.count_pasg_sep_invol)
    ,SUM(msrs.count_asg_end)
    ,SUM(msrs.count_asg_hire)
    ,SUM(msrs.count_asg_term)
    ,SUM(msrs.count_asg_sep_vol)
    ,SUM(msrs.count_asg_sep_invol)
    ,SUM(msrs.count_asg_prmtn)
    ,SUM(msrs.pow_days_on_end_date)
    ,SUM(msrs.pow_months_on_end_date)
    ,SUM(msrs.days_since_last_prmtn)
    ,SUM(msrs.months_since_last_prmtn)
    ,SUM(msrs.anl_slry_start)
    ,SUM(msrs.anl_slry_end)
    ,fct.employee_ind
    ,fct.contingent_ind
    ,msrs.last_month_in_qtr_ind
    ,msrs.last_month_in_year_ind
    ,fct.adt_pow_band
    ,g_sysdate
    ,g_user
    ,g_user
    ,g_user
    ,g_sysdate
    FROM
     (SELECT
       wevt.asg_assgnmnt_fk
      ,wevt.per_person_fk
      ,wevt.per_person_mgr_fk
      ,NVL(LAG(wevt.per_person_mgr_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                                ORDER BY mnth.month_id)
          ,-1)                       per_person_mgr_prv_fk
      ,wevt.mgr_mngrsc_fk
      ,NVL(LAG(wevt.mgr_mngrsc_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                            ORDER BY mnth.month_id)
          ,-1)                       mgr_mngrsc_prv_fk
      ,wevt.org_organztn_fk
      ,NVL(LAG(wevt.org_organztn_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       org_organztn_prv_fk
      ,wevt.job_job_fk
      ,NVL(LAG(wevt.job_job_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                         ORDER BY mnth.month_id)
          ,-1)                       job_job_prv_fk
      ,wevt.grd_grade_fk
      ,NVL(LAG(wevt.grd_grade_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                           ORDER BY mnth.month_id)
          ,-1)                       grd_grade_prv_fk
      ,wevt.pos_position_fk
      ,NVL(LAG(wevt.pos_position_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       pos_position_prv_fk
      ,wevt.geo_location_fk
      ,NVL(LAG(wevt.geo_location_fk, 1) OVER (PARTITION BY wevt.asg_assgnmnt_fk
                                              ORDER BY mnth.month_id)
          ,-1)                       geo_location_prv_fk
      ,wevt.asgrsn_asgrsn_fk
      ,wevt.sprn_sprtnrsn_fk
      ,wevt.scat_spcatgry_fk
      ,wevt.ptyp_pertyp_fk
      ,wevt.prfm_perfband_fk
      ,wevt.pow_powband_fk
      ,mnth.month_id                 time_month_snp_fk
      ,wevt.cur_currency_fk
      ,wevt.employee_ind
      ,wevt.contingent_ind
      ,wevt.adt_pow_band
      ,eq.erlst_evnt_effective_date  adt_event_date
      FROM
       hri_eq_wrkfc_mnth    eq
      ,hri_mb_wrkfc_evt_ct  wevt
      ,fii_time_month       mnth
      WHERE eq.assignment_id = wevt.asg_assgnmnt_fk
      AND mnth.end_date BETWEEN wevt.time_day_evt_fk
                        AND wevt.time_day_evt_end_fk
-- Snapshot previous value for zero record
      AND mnth.end_date >= ADD_MONTHS(eq.erlst_evnt_effective_date, -2)
-- If assignment is ended, only snapshot the ended assignment once
      AND ((wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0)
        OR mnth.start_date <= wevt.time_day_evt_fk)
      AND wevt.asg_assgnmnt_fk BETWEEN p_start_asg_id
                                 AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.start_date <= TRUNC(g_sysdate)
     )      fct
    ,(SELECT
       mnth.month_id          time_month_snp_fk
      ,mnth.start_date        time_day_mnth_start_fk
      ,mnth.end_date          time_day_mnth_end_fk
      ,wevt.asg_assgnmnt_fk   asg_assgnmnt_fk
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.headcount
                ELSE 0
           END)               headcount_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.headcount
                ELSE 0
           END)               headcount_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_hire
                ELSE 0
           END)               headcount_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term
                ELSE 0
           END)               headcount_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term * wevt.term_voluntary_ind
                ELSE 0
           END)               headcount_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount_term * wevt.term_involuntary_ind
                ELSE 0
           END)               headcount_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.headcount * wevt.promotion_ind
                ELSE 0
           END)               headcount_prmtn
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.fte
                ELSE 0
           END)               fte_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.fte
                ELSE 0
           END)               fte_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_hire
                ELSE 0
           END)               fte_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term
                ELSE 0
           END)               fte_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term * wevt.term_voluntary_ind
                ELSE 0
           END)               fte_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte_term * wevt.term_involuntary_ind
                ELSE 0
           END)               fte_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.fte * wevt.promotion_ind
                ELSE 0
           END)               fte_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.primary_ind
                ELSE 0
           END)               count_pasg_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.hire_or_start_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_or_end_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_voluntary_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_involuntary_ind * wevt.primary_ind
                ELSE 0
           END)               count_pasg_sep_invol
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN 1
                ELSE 0
           END)               count_asg_end
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.hire_or_start_ind
                ELSE 0
           END)               count_asg_hire
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_or_end_ind
                ELSE 0
           END)               count_asg_term
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_voluntary_ind
                ELSE 0
           END)               count_asg_sep_vol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.term_involuntary_ind
                ELSE 0
           END)               count_asg_sep_invol
      ,SUM(CASE WHEN wevt.time_day_evt_fk BETWEEN mnth.start_date
                                          AND mnth.end_date
                THEN wevt.promotion_ind
                ELSE 0
           END)               count_asg_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.pow_days_on_event_date +
                     (mnth.end_date - wevt.time_day_evt_fk)
                ELSE 0
           END)               pow_days_on_end_date
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN MONTHS_BETWEEN
                     (mnth.end_date,
                      wevt.time_day_evt_fk - wevt.pow_days_on_event_date)
                ELSE 0
           END)               pow_months_on_end_date
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.days_since_last_prmtn +
                     (mnth.end_date - wevt.time_day_evt_fk)
                ELSE 0
           END)               days_since_last_prmtn
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN MONTHS_BETWEEN
                     (mnth.end_date,
                      wevt.time_day_evt_fk - wevt.days_since_last_prmtn)
                ELSE 0
           END)               months_since_last_prmtn
      ,SUM(CASE WHEN mnth.start_date BETWEEN wevt.time_day_evt_fk
                                     AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.anl_slry
                ELSE 0
           END)               anl_slry_start
      ,SUM(CASE WHEN mnth.end_date BETWEEN wevt.time_day_evt_fk
                                   AND wevt.time_day_evt_end_fk
                AND wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0
                THEN wevt.anl_slry
                ELSE 0
           END)               anl_slry_end
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Q'), 3) - 1
            THEN 1
            WHEN MAX(wevt.worker_term_ind) = 1 OR MAX(wevt.pre_sprtn_asgn_end_ind) = 1
            THEN 1
            WHEN TRUNC(g_sysdate) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_qtr_ind
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Y'), 12) - 1
            THEN 1
            WHEN MAX(wevt.worker_term_ind) = 1 OR MAX(wevt.pre_sprtn_asgn_end_ind) = 1
            THEN 1
            WHEN TRUNC(g_sysdate) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_year_ind
      ,0                      zero_row_ind
      FROM
       hri_eq_wrkfc_mnth    eq
      ,hri_mb_wrkfc_evt_ct  wevt
      ,fii_time_month       mnth
      WHERE eq.assignment_id = wevt.asg_assgnmnt_fk
      AND mnth.end_date >= ADD_MONTHS(eq.erlst_evnt_effective_date, -1)
      AND wevt.time_day_evt_fk <= mnth.end_date
      AND mnth.start_date <= wevt.time_day_evt_end_fk
-- If assignment is ended, only snapshot the ended assignment once
      AND ((wevt.worker_term_ind = 0 AND wevt.pre_sprtn_asgn_end_ind = 0)
        OR mnth.start_date <= wevt.time_day_evt_fk)
      AND eq.assignment_id BETWEEN p_start_asg_id
                             AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.start_date <= TRUNC(g_sysdate)
      GROUP BY
       mnth.month_id
      ,mnth.start_date
      ,mnth.end_date
      ,wevt.asg_assgnmnt_fk
      UNION ALL
      SELECT
       mnth.month_id          time_month_snp_fk
      ,mnth.start_date        time_day_mnth_start_fk
      ,mnth.end_date          time_day_mnth_end_fk
      ,wevt.asg_assgnmnt_fk   asg_assgnmnt_fk
      ,0                      headcount_start
      ,0                      headcount_end
      ,0                      headcount_hire
      ,0                      headcount_term
      ,0                      headcount_sep_vol
      ,0                      headcount_sep_invol
      ,0                      headcount_prmtn
      ,0                      fte_start
      ,0                      fte_end
      ,0                      fte_hire
      ,0                      fte_term
      ,0                      fte_sep_vol
      ,0                      fte_sep_invol
      ,0                      fte_prmtn
      ,0                      count_pasg_end
      ,0                      count_pasg_hire
      ,0                      count_pasg_term
      ,0                      count_pasg_sep_vol
      ,0                      count_pasg_sep_invol
      ,0                      count_asg_end
      ,0                      count_asg_hire
      ,0                      count_asg_term
      ,0                      count_asg_sep_vol
      ,0                      count_asg_sep_invol
      ,0                      count_asg_prmtn
      ,0                      pow_days_on_end_date
      ,0                      pow_months_on_end_date
      ,to_number(null)        days_since_last_prmtn
      ,to_number(null)        months_since_last_prmtn
      ,0                      anl_slry_start
      ,0                      anl_slry_end
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Q'), 2) - 1
            THEN 1
            WHEN wevt.worker_term_nxt_ind = 1 OR wevt.pre_sprtn_asgn_end_nxt_ind = 1
            THEN 1
            WHEN ADD_MONTHS(TRUNC(g_sysdate), -1) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_qtr_ind
      ,CASE WHEN mnth.end_date = ADD_MONTHS(TRUNC(mnth.end_date, 'Y'), 11) - 1
            THEN 1
            WHEN wevt.worker_term_nxt_ind = 1 OR wevt.pre_sprtn_asgn_end_nxt_ind = 1
            THEN 1
            WHEN ADD_MONTHS(TRUNC(g_sysdate), -1) BETWEEN mnth.start_date AND mnth.end_date
            THEN 1
            ELSE 0
       END                    last_month_in_year_ind
      ,1                      zero_row_ind
      FROM
       hri_eq_wrkfc_mnth    eq
      ,hri_mb_wrkfc_evt_ct  wevt
      ,fii_time_month       mnth
      WHERE eq.assignment_id = wevt.asg_assgnmnt_fk
      AND mnth.end_date BETWEEN wevt.time_day_evt_fk
                          AND wevt.time_day_evt_end_fk
-- Include month of change and the previous month (to zero out)
      AND mnth.end_date >= ADD_MONTHS(eq.erlst_evnt_effective_date, -1)
-- If assignment is ended, no need to snapshot
      AND wevt.worker_term_ind = 0
      AND wevt.pre_sprtn_asgn_end_ind = 0
      AND eq.assignment_id BETWEEN p_start_asg_id
                             AND p_end_asg_id
      AND mnth.end_date >= g_dbi_start_date
      AND mnth.end_date < TRUNC(g_sysdate)
     )    msrs
    WHERE msrs.asg_assgnmnt_fk =  fct.asg_assgnmnt_fk
    AND msrs.time_month_snp_fk = fct.time_month_snp_fk
-- Restrict to snapshots from event date onwards
    AND DECODE(msrs.zero_row_ind,
                 0, msrs.time_day_mnth_end_fk,
               ADD_MONTHS(msrs.time_day_mnth_start_fk, 2) - 1) >= fct.adt_event_date
    GROUP BY
     fct.asg_assgnmnt_fk
    ,fct.per_person_fk
    ,fct.per_person_mgr_fk
    ,fct.per_person_mgr_prv_fk
    ,fct.mgr_mngrsc_fk
    ,fct.mgr_mngrsc_prv_fk
    ,fct.org_organztn_fk
    ,fct.org_organztn_prv_fk
    ,fct.job_job_fk
    ,fct.job_job_prv_fk
    ,fct.grd_grade_fk
    ,fct.grd_grade_prv_fk
    ,fct.pos_position_fk
    ,fct.pos_position_prv_fk
    ,fct.geo_location_fk
    ,fct.geo_location_prv_fk
    ,fct.asgrsn_asgrsn_fk
    ,fct.sprn_sprtnrsn_fk
    ,fct.scat_spcatgry_fk
    ,fct.ptyp_pertyp_fk
    ,fct.prfm_perfband_fk
    ,fct.pow_powband_fk
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_month_snp_fk
          ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
     END
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_start_fk
          ELSE msrs.time_day_mnth_end_fk + 1
     END
    ,CASE WHEN msrs.zero_row_ind = 0
          THEN msrs.time_day_mnth_end_fk
          ELSE ADD_MONTHS(msrs.time_day_mnth_start_fk, 2) - 1
     END
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 100, 0)
    ,TRUNC((CASE WHEN msrs.zero_row_ind = 0
                 THEN msrs.time_month_snp_fk
                 ELSE to_number(to_char(msrs.time_day_mnth_end_fk + 1, 'YYYYQMM'))
            END) / 1000, 0)
    ,fct.cur_currency_fk
    ,fct.employee_ind
    ,fct.contingent_ind
    ,msrs.last_month_in_qtr_ind
    ,msrs.last_month_in_year_ind
    ,fct.adt_pow_band;

  -- Commit
  COMMIT;

END process_month_summary_incr;


-- ----------------------------------------------------------------------------
-- Deletes records from month summary for incremental maintenance
-- ----------------------------------------------------------------------------
PROCEDURE delete_month_summary_incr(p_start_asg_id    IN NUMBER,
                                    p_end_asg_id      IN NUMBER) IS

BEGIN

  DELETE FROM hri_mds_wrkfc_mnth_ct  snp
  WHERE snp.rowid IN
   (SELECT /*+ ORDERED */
     snp2.rowid
    FROM
     hri_eq_wrkfc_mnth      eq
    ,hri_mds_wrkfc_mnth_ct  snp2
    WHERE eq.assignment_id = snp2.asg_assgnmnt_fk
    AND eq.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id
    AND snp2.time_month_snp_fk >=
        to_number(to_char(eq.erlst_evnt_effective_date, 'YYYYQMM')));

END delete_month_summary_incr;


-- ----------------------------------------------------------------------------
-- Processes  base fact in full refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_base_fact_full(p_start_asg_id    IN NUMBER,
                                 p_end_asg_id      IN NUMBER) IS

BEGIN

  INSERT INTO hri_mb_wrkfc_evt_ct
   (wevt_evtypcmb_fk
   ,asg_assgnmnt_fk
   ,per_person_fk
   ,per_person_mgr_fk
   ,per_person_mgr_prv_fk
   ,mgr_mngrsc_fk
   ,mgr_mngrsc_prv_fk
   ,org_organztn_fk
   ,org_organztn_prv_fk
   ,job_job_fk
   ,job_job_prv_fk
   ,grd_grade_fk
   ,grd_grade_prv_fk
   ,pos_position_fk
   ,pos_position_prv_fk
   ,geo_location_fk
   ,geo_location_prv_fk
   ,asgrsn_asgrsn_fk
   ,sprn_sprtnrsn_fk
   ,scat_spcatgry_fk
   ,ptyp_pertyp_fk
   ,prfm_perfband_fk
   ,pow_powband_fk
   ,time_day_evt_fk
   ,time_day_evt_end_fk
   ,cur_currency_fk
   ,headcount
   ,headcount_prv
   ,headcount_hire
   ,headcount_term
   ,fte
   ,fte_prv
   ,fte_hire
   ,fte_term
   ,pow_days_on_event_date
   ,pow_months_on_event_date
   ,days_since_last_prmtn
   ,months_since_last_prmtn
   ,anl_slry
   ,anl_slry_prv
   ,assignment_change_ind
   ,primary_ind
   ,headcount_gain_ind
   ,headcount_loss_ind
   ,headcount_change_ind
   ,fte_gain_ind
   ,fte_loss_ind
   ,fte_change_ind
   ,contingent_ind
   ,employee_ind
   ,grade_change_ind
   ,job_change_ind
   ,position_change_ind
   ,location_change_ind
   ,organization_change_ind
   ,supervisor_change_ind
   ,worker_hire_ind
   ,term_voluntary_ind
   ,term_involuntary_ind
   ,worker_term_ind
   ,hire_or_start_ind
   ,term_or_end_ind
   ,start_asg_sspnsn_ind
   ,end_asg_sspnsn_ind
   ,post_hire_asgn_start_ind
   ,pre_sprtn_asgn_end_ind
   ,prsntyp_change_ind
   ,mgrh_node_change_ind
   ,promotion_ind
   ,worker_term_nxt_ind
   ,pre_sprtn_asgn_end_nxt_ind
   ,adt_event_id
   ,adt_assignment_id
   ,adt_asg_effctv_start_date
   ,adt_asg_effctv_end_date
   ,adt_business_group_id
   ,adt_perf_review_id
   ,adt_period_of_service_id
   ,adt_period_of_placement_id
   ,adt_pow_band
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_login
   ,last_update_date)
    SELECT
     CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN -1
          ELSE wevt.wevt_evtypcmb_fk
     END                              wevt_evtypcmb_fk
    ,wevt.asg_assgnmnt_fk
    ,wevt.per_person_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.per_person_mgr_fk
          ELSE wevt.per_person_mgr_prv_fk
     END                              per_person_mgr_fk
    ,wevt.per_person_mgr_prv_fk
    ,NVL(chn.mgrs_mngrsc_pk, -1)      mgr_mngrsc_fk
    ,NVL(chn_prv.mgrs_mngrsc_pk, -1)  mgr_mngrsc_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.org_organztn_fk
          ELSE wevt.org_organztn_prv_fk
     END                              org_organztn_fk
    ,wevt.org_organztn_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.job_job_fk
          ELSE wevt.job_job_prv_fk
     END                              job_job_fk
    ,wevt.job_job_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.grd_grade_fk
          ELSE wevt.grd_grade_prv_fk
     END                              grd_grade_fk
    ,wevt.grd_grade_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.pos_position_fk
          ELSE wevt.pos_position_prv_fk
     END                              pos_position_fk
    ,wevt.pos_position_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.geo_location_fk
          ELSE wevt.geo_location_prv_fk
     END                              geo_location_fk
    ,wevt.geo_location_prv_fk
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_end_fk)
          THEN 'NA_EDW'
          ELSE wevt.asgrsn_asgrsn_fk
     END                              asgrsn_asgrsn_fk
    ,CASE WHEN wevt.employee_ind = 1 AND
               wevt.sprn_sprtnrsn_fk <> 'NA_EDW'
          THEN 'LEAV_REAS' || '-' || wevt.sprn_sprtnrsn_fk
          WHEN wevt.contingent_ind = 1 AND
               wevt.sprn_sprtnrsn_fk <> 'NA_EDW'
          THEN 'HR_CWK_TERMINATION_REASONS' || '-' || wevt.sprn_sprtnrsn_fk
          ELSE 'NA_EDW'
     END                              sprn_sprtnrsn_fk
    ,wevt.scat_spcatgry_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.ptyp_pertyp_fk
          ELSE wevt.ptyp_pertyp_prv_fk
     END                              ptyp_pertyp_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.prfm_perfband_fk
          ELSE wevt.prfm_perfband_prv_fk
     END                              prfm_perfband_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.pow_powband_fk
          ELSE wevt.pow_powband_prv_fk
     END                              pow_powband_fk
    ,GREATEST(wevt.time_day_evt_fk,
              NVL(chn.mgrs_date_start, wevt.time_day_evt_fk))
                                   time_day_evt_fk
    ,LEAST(wevt.time_day_evt_end_fk,
           NVL(chn.mgrs_date_end, wevt.time_day_evt_end_fk))
                                   time_day_evt_end_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.cur_currency_fk
          ELSE wevt.cur_currency_prv_fk
     END                              cur_currency_fk
    ,NVL(wevt.headcount, 0)           headcount
    ,NVL(wevt.headcount_prv, 0)       headcount_prv
    ,CASE WHEN wevt.time_day_evt_fk >= NVL(chn.mgrs_date_start,
                                           wevt.time_day_evt_fk) AND
               wevt.worker_hire_ind = 1
          THEN wevt.headcount
          ELSE 0
     END                              headcount_hire
    ,CASE WHEN wevt.worker_term_ind = 1 OR
               wevt.pre_sprtn_asgn_end_ind = 1
          THEN wevt.headcount_prv
          ELSE 0
     END                              headcount_term
    ,NVL(wevt.fte, 0)                 fte
    ,NVL(wevt.fte_prv, 0)             fte_prv
    ,CASE WHEN wevt.time_day_evt_fk >= NVL(chn.mgrs_date_start,
                                           wevt.time_day_evt_fk) AND
               wevt.worker_hire_ind = 1
          THEN wevt.fte
          ELSE 0
     END                              fte_hire
    ,CASE WHEN wevt.worker_term_ind = 1 OR
               wevt.pre_sprtn_asgn_end_ind = 1
          THEN wevt.fte_prv
          ELSE 0
     END                              fte_term
    ,GREATEST(wevt.time_day_evt_fk,
              NVL(chn.mgrs_date_start, wevt.time_day_evt_fk))
       - wevt.time_day_pow_start_fk
                                      pow_days_on_event_date
    ,MONTHS_BETWEEN
      (GREATEST(wevt.time_day_evt_fk,
                NVL(chn.mgrs_date_start, wevt.time_day_evt_fk)),
       wevt.time_day_pow_start_fk)    pow_months_on_event_date
    ,wevt.days_since_last_prmtn
    ,wevt.months_since_last_prmtn
    ,NVL(wevt.anl_slry, 0)            anl_slry
    ,NVL(wevt.anl_slry_prv, 0)        anl_slry_prv
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.assignment_change_ind
     END                              assignment_change_ind
    ,wevt.primary_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_gain_ind
     END                              headcount_gain_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_loss_ind
     END                              headcount_loss_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_loss_ind + wevt.headcount_gain_ind
     END                              headcount_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_gain_ind
     END                              fte_gain_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_loss_ind
     END                              fte_loss_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_loss_ind + wevt.fte_gain_ind
     END                              fte_change_ind
    ,wevt.contingent_ind
    ,wevt.employee_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.grade_change_ind
     END                              grade_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.job_change_ind
     END                              job_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.position_change_ind
     END                              position_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.location_change_ind
     END                              location_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.organization_change_ind
     END                              organization_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.supervisor_change_ind
     END                              supervisor_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.worker_hire_ind
     END                              worker_hire_ind
    ,wevt.term_voluntary_ind
    ,wevt.term_involuntary_ind
    ,wevt.worker_term_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.post_hire_asgn_start_ind + wevt.worker_hire_ind
     END                              hire_or_start_ind
    ,wevt.worker_term_ind + wevt.pre_sprtn_asgn_end_ind
                                      term_or_end_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.start_asg_sspnsn_ind
     END                              start_asg_sspnsn_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.end_asg_sspnsn_ind
     END                              end_asg_sspnsn_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.post_hire_asgn_start_ind
     END                              post_hire_asgn_start_ind
    ,wevt.pre_sprtn_asgn_end_ind
--    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
--                                          wevt.time_day_evt_fk)
--          THEN 0
--          ELSE wevt.prsntyp_change_ind
--     END                              prsntyp_change_ind
    ,to_number(null)                 prsntyp_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 1
          ELSE 0
     END                              mgrh_node_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.promotion_ind
     END                              promotion_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.worker_term_nxt_ind
     END                              worker_term_nxt_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.pre_sprtn_asgn_end_nxt_ind
     END                              pre_sprtn_asgn_end_nxt_ind
    ,wevt.adt_event_id                adt_event_id
    ,wevt.asg_assgnmnt_fk             adt_assignment_id
    ,wevt.time_day_evt_fk             adt_asg_effctv_start_date
    ,wevt.time_day_evt_end_fk         adt_asg_effctv_end_date
    ,wevt.adt_business_group_id       adt_business_group_id
    ,wevt.adt_perf_review_id          adt_perf_review_id
    ,to_number(null)                  adt_period_of_service_id
    ,to_number(null)                  adt_period_of_placement_id
    ,pow.band_sequence                adt_pow_band
    ,g_sysdate
    ,g_user
    ,g_user
    ,g_user
    ,g_sysdate
    FROM
     hri_cs_mngrsc_ct   chn
    ,hri_cs_mngrsc_ct   chn_prv
    ,hri_cs_pow_band_ct pow
    ,(SELECT /*+ NO_MERGE */
       hri_opl_wrkfc_evt_type.get_evtypcmb_fk
        (assignment_change_ind
        ,salary_change_ind
        ,perf_rating_change_ind
        ,perf_band_change_ind
        ,pow_band_change_ind
        ,headcount_gain_ind
        ,headcount_loss_ind
        ,fte_gain_ind
        ,fte_loss_ind
        ,grade_change_ind
        ,job_change_ind
        ,position_change_ind
        ,location_change_ind
        ,organization_change_ind
        ,supervisor_change_ind
        ,worker_hire_ind
        ,post_hire_asgn_start_ind
        ,pre_sprtn_asgn_end_ind
        ,term_voluntary_ind
        ,term_involuntary_ind
        ,worker_term_ind
        ,start_asg_sspnsn_ind
        ,end_asg_sspnsn_ind
        ,promotion_ind)               wevt_evtypcmb_fk
      ,evt.assignment_id              asg_assgnmnt_fk
      ,evt.person_id                  per_person_fk
      ,evt.supervisor_id              per_person_mgr_fk
      ,evt.supervisor_prv_id          per_person_mgr_prv_fk
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN evt.supervisor_id
            ELSE evt.supervisor_prv_id
       END                            psn_chain_mgr_fk
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN evt.effective_change_date
            ELSE evt.effective_change_date - 1
       END                            psn_chain_time_fk
      ,evt.organization_id            org_organztn_fk
      ,evt.organization_prv_id        org_organztn_prv_fk
      ,evt.job_id                     job_job_fk
      ,evt.job_prv_id                 job_job_prv_fk
      ,evt.grade_id                   grd_grade_fk
      ,evt.grade_prv_id               grd_grade_prv_fk
      ,evt.position_id                pos_position_fk
      ,evt.position_prv_id            pos_position_prv_fk
      ,evt.location_id                geo_location_fk
      ,evt.location_prv_id            geo_location_prv_fk
      ,evt.change_reason_code         asgrsn_asgrsn_fk
      ,evt.leaving_reason_code        sprn_sprtnrsn_fk
      ,evt.separation_category        scat_spcatgry_fk
      ,evt.prsntyp_sk_fk              ptyp_pertyp_fk
      ,LAG(evt.prsntyp_sk_fk, 1) OVER (PARTITION BY evt.assignment_id
                                       ORDER BY evt.effective_change_date)
                                      ptyp_pertyp_prv_fk
      ,evt.perf_band                  prfm_perfband_fk
      ,evt.perf_band_prv              prfm_perfband_prv_fk
      ,evt.pow_band_sk_fk             pow_powband_fk
      ,evt.pow_band_prv_sk_fk         pow_powband_prv_fk
      ,evt.effective_change_date      time_day_evt_fk
      ,evt.effective_change_end_date  time_day_evt_end_fk
      ,evt.pow_start_date_adj         time_day_pow_start_fk
      ,evt.anl_slry_currency          cur_currency_fk
      ,evt.anl_slry_currency_prv      cur_currency_prv_fk
      ,evt.headcount                  headcount
      ,evt.headcount_prv              headcount_prv
      ,evt.fte                        fte
      ,evt.fte_prv                    fte_prv
      ,evt.pow_days_on_event_date     pow_days_on_event_date
      ,evt.pow_months_on_event_date   pow_months_on_event_date
      ,evt.days_since_last_prmtn
      ,evt.months_since_last_prmtn
      ,evt.anl_slry                   anl_slry
      ,evt.anl_slry_prv               anl_slry_prv
      ,evt.assignment_change_ind      assignment_change_ind
      ,CASE WHEN evt.primary_flag = 'Y'
            THEN 1
            ELSE 0
       END                            primary_ind
      ,evt.headcount_gain_ind         headcount_gain_ind
      ,evt.headcount_loss_ind         headcount_loss_ind
      ,evt.fte_gain_ind               fte_gain_ind
      ,evt.fte_loss_ind               fte_loss_ind
      ,CASE WHEN evt.asg_type_code = 'C'
            THEN 1
            ELSE 0
       END                            contingent_ind
      ,CASE WHEN evt.asg_type_code = 'E'
            THEN 1
            ELSE 0
       END                            employee_ind
      ,evt.grade_change_ind           grade_change_ind
      ,evt.job_change_ind             job_change_ind
      ,evt.position_change_ind        position_change_ind
      ,evt.location_change_ind        location_change_ind
      ,evt.organization_change_ind    organization_change_ind
      ,evt.supervisor_change_ind      supervisor_change_ind
      ,evt.worker_hire_ind            worker_hire_ind
      ,evt.term_voluntary_ind         term_voluntary_ind
      ,evt.term_involuntary_ind       term_involuntary_ind
      ,evt.worker_term_ind            worker_term_ind
      ,evt.start_asg_sspnsn_ind       start_asg_sspnsn_ind
      ,evt.end_asg_sspnsn_ind         end_asg_sspnsn_ind
      ,evt.post_hire_asgn_start_ind   post_hire_asgn_start_ind
      ,evt.pre_sprtn_asgn_end_ind     pre_sprtn_asgn_end_ind
      ,to_number(null)                prsntyp_change_ind
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN 0
            ELSE 1
       END                            termination_ind
      ,evt.promotion_ind              promotion_ind
      ,evt.worker_term_nxt_ind        worker_term_nxt_ind
      ,evt.pre_sprtn_asgn_end_nxt_ind pre_sprtn_asgn_end_nxt_ind
      ,evt.event_id                   adt_event_id
      ,evt.business_group_id          adt_business_group_id
      ,evt.performance_review_id      adt_perf_review_id
      FROM
       hri_mb_asgn_events_ct  evt
      WHERE evt.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id
      AND evt.summarization_rqd_ind = 1
     )  wevt
    WHERE wevt.pow_powband_fk = pow.pow_band_sk_pk
    AND chn.mgrs_person_fk (+) = wevt.psn_chain_mgr_fk
    AND chn.mgrs_date_start (+) <= wevt.time_day_evt_end_fk
    AND chn.mgrs_date_end (+) >= wevt.psn_chain_time_fk
    AND chn.mgrs_date_start (+) <= DECODE(wevt.termination_ind,
                                            0, wevt.time_day_evt_end_fk,
                                          wevt.psn_chain_time_fk)
    AND chn_prv.mgrs_person_fk (+) = wevt.per_person_mgr_prv_fk
    AND wevt.time_day_evt_fk - 1 BETWEEN chn_prv.mgrs_date_start (+)
                                 AND chn_prv.mgrs_date_end (+);

  COMMIT;

END process_base_fact_full;


-- ----------------------------------------------------------------------------
-- Processes  base fact in incremental refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_base_fact_incr(p_start_asg_id    IN NUMBER,
                                 p_end_asg_id      IN NUMBER) IS

BEGIN

  INSERT INTO hri_mb_wrkfc_evt_ct
   (wevt_evtypcmb_fk
   ,asg_assgnmnt_fk
   ,per_person_fk
   ,per_person_mgr_fk
   ,per_person_mgr_prv_fk
   ,mgr_mngrsc_fk
   ,mgr_mngrsc_prv_fk
   ,org_organztn_fk
   ,org_organztn_prv_fk
   ,job_job_fk
   ,job_job_prv_fk
   ,grd_grade_fk
   ,grd_grade_prv_fk
   ,pos_position_fk
   ,pos_position_prv_fk
   ,geo_location_fk
   ,geo_location_prv_fk
   ,asgrsn_asgrsn_fk
   ,sprn_sprtnrsn_fk
   ,scat_spcatgry_fk
   ,ptyp_pertyp_fk
   ,prfm_perfband_fk
   ,pow_powband_fk
   ,time_day_evt_fk
   ,time_day_evt_end_fk
   ,cur_currency_fk
   ,headcount
   ,headcount_prv
   ,headcount_hire
   ,headcount_term
   ,fte
   ,fte_prv
   ,fte_hire
   ,fte_term
   ,pow_days_on_event_date
   ,pow_months_on_event_date
   ,days_since_last_prmtn
   ,months_since_last_prmtn
   ,anl_slry
   ,anl_slry_prv
   ,assignment_change_ind
   ,primary_ind
   ,headcount_gain_ind
   ,headcount_loss_ind
   ,headcount_change_ind
   ,fte_gain_ind
   ,fte_loss_ind
   ,fte_change_ind
   ,contingent_ind
   ,employee_ind
   ,grade_change_ind
   ,job_change_ind
   ,position_change_ind
   ,location_change_ind
   ,organization_change_ind
   ,supervisor_change_ind
   ,worker_hire_ind
   ,term_voluntary_ind
   ,term_involuntary_ind
   ,worker_term_ind
   ,hire_or_start_ind
   ,term_or_end_ind
   ,start_asg_sspnsn_ind
   ,end_asg_sspnsn_ind
   ,post_hire_asgn_start_ind
   ,pre_sprtn_asgn_end_ind
   ,prsntyp_change_ind
   ,mgrh_node_change_ind
   ,promotion_ind
   ,worker_term_nxt_ind
   ,pre_sprtn_asgn_end_nxt_ind
   ,adt_event_id
   ,adt_assignment_id
   ,adt_asg_effctv_start_date
   ,adt_asg_effctv_end_date
   ,adt_business_group_id
   ,adt_perf_review_id
   ,adt_period_of_service_id
   ,adt_period_of_placement_id
   ,adt_pow_band
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_login
   ,last_update_date)
    SELECT
     CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN -1
          ELSE wevt.wevt_evtypcmb_fk
     END                              wevt_evtypcmb_fk
    ,wevt.asg_assgnmnt_fk
    ,wevt.per_person_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.per_person_mgr_fk
          ELSE wevt.per_person_mgr_prv_fk
     END                              per_person_mgr_fk
    ,wevt.per_person_mgr_prv_fk
    ,NVL(chn.mgrs_mngrsc_pk, -1)      mgr_mngrsc_fk
    ,NVL(chn_prv.mgrs_mngrsc_pk, -1)  mgr_mngrsc_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.org_organztn_fk
          ELSE wevt.org_organztn_prv_fk
     END                              org_organztn_fk
    ,wevt.org_organztn_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.job_job_fk
          ELSE wevt.job_job_prv_fk
     END                              job_job_fk
    ,wevt.job_job_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.grd_grade_fk
          ELSE wevt.grd_grade_prv_fk
     END                              grd_grade_fk
    ,wevt.grd_grade_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.pos_position_fk
          ELSE wevt.pos_position_prv_fk
     END                              pos_position_fk
    ,wevt.pos_position_prv_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.geo_location_fk
          ELSE wevt.geo_location_prv_fk
     END                              geo_location_fk
    ,wevt.geo_location_prv_fk
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_end_fk)
          THEN 'NA_EDW'
          ELSE wevt.asgrsn_asgrsn_fk
     END                              asgrsn_asgrsn_fk
    ,CASE WHEN wevt.employee_ind = 1 AND
               wevt.sprn_sprtnrsn_fk <> 'NA_EDW'
          THEN 'LEAV_REAS' || '-' || wevt.sprn_sprtnrsn_fk
          WHEN wevt.contingent_ind = 1 AND
               wevt.sprn_sprtnrsn_fk <> 'NA_EDW'
          THEN 'HR_CWK_TERMINATION_REASONS' || '-' || wevt.sprn_sprtnrsn_fk
          ELSE 'NA_EDW'
     END                              sprn_sprtnrsn_fk
    ,wevt.scat_spcatgry_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.ptyp_pertyp_fk
          ELSE wevt.ptyp_pertyp_prv_fk
     END                              ptyp_pertyp_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.prfm_perfband_fk
          ELSE wevt.prfm_perfband_prv_fk
     END                              prfm_perfband_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.pow_powband_fk
          ELSE wevt.pow_powband_prv_fk
     END                              pow_powband_fk
    ,GREATEST(wevt.time_day_evt_fk,
              NVL(chn.mgrs_date_start, wevt.time_day_evt_fk))
                                   time_day_evt_fk
    ,LEAST(wevt.time_day_evt_end_fk,
           NVL(chn.mgrs_date_end, wevt.time_day_evt_end_fk))
                                   time_day_evt_end_fk
    ,CASE WHEN wevt.termination_ind = 0
          THEN wevt.cur_currency_fk
          ELSE wevt.cur_currency_prv_fk
     END                              cur_currency_fk
    ,NVL(wevt.headcount, 0)           headcount
    ,NVL(wevt.headcount_prv, 0)       headcount_prv
    ,CASE WHEN wevt.time_day_evt_fk >= NVL(chn.mgrs_date_start,
                                           wevt.time_day_evt_fk) AND
               wevt.worker_hire_ind = 1
          THEN wevt.headcount
          ELSE 0
     END                              headcount_hire
    ,CASE WHEN wevt.worker_term_ind = 1 OR
               wevt.pre_sprtn_asgn_end_ind = 1
          THEN wevt.headcount_prv
          ELSE 0
     END                              headcount_term
    ,NVL(wevt.fte, 0)                 fte
    ,NVL(wevt.fte_prv, 0)             fte_prv
    ,CASE WHEN wevt.time_day_evt_fk >= NVL(chn.mgrs_date_start,
                                           wevt.time_day_evt_fk) AND
               wevt.worker_hire_ind = 1
          THEN wevt.fte
          ELSE 0
     END                              fte_hire
    ,CASE WHEN wevt.worker_term_ind = 1 OR
               wevt.pre_sprtn_asgn_end_ind = 1
          THEN wevt.fte_prv
          ELSE 0
     END                              fte_term
    ,GREATEST(wevt.time_day_evt_fk,
              NVL(chn.mgrs_date_start, wevt.time_day_evt_fk))
       - wevt.time_day_pow_start_fk
                                      pow_days_on_event_date
    ,MONTHS_BETWEEN
      (GREATEST(wevt.time_day_evt_fk,
                NVL(chn.mgrs_date_start, wevt.time_day_evt_fk)),
       wevt.time_day_pow_start_fk)    pow_months_on_event_date
    ,wevt.days_since_last_prmtn
    ,wevt.months_since_last_prmtn
    ,NVL(wevt.anl_slry, 0)            anl_slry
    ,NVL(wevt.anl_slry_prv, 0)        anl_slry_prv
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.assignment_change_ind
     END                              assignment_change_ind
    ,wevt.primary_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_gain_ind
     END                              headcount_gain_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_loss_ind
     END                              headcount_loss_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.headcount_loss_ind + wevt.headcount_gain_ind
     END                              headcount_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_gain_ind
     END                              fte_gain_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_loss_ind
     END                              fte_loss_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.fte_loss_ind + wevt.fte_gain_ind
     END                              fte_change_ind
    ,wevt.contingent_ind
    ,wevt.employee_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.grade_change_ind
     END                              grade_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.job_change_ind
     END                              job_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.position_change_ind
     END                              position_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.location_change_ind
     END                              location_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.organization_change_ind
     END                              organization_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.supervisor_change_ind
     END                              supervisor_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.worker_hire_ind
     END                              worker_hire_ind
    ,wevt.term_voluntary_ind
    ,wevt.term_involuntary_ind
    ,wevt.worker_term_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.post_hire_asgn_start_ind + wevt.worker_hire_ind
     END                              hire_or_start_ind
    ,wevt.worker_term_ind + wevt.pre_sprtn_asgn_end_ind
                                      term_or_end_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.start_asg_sspnsn_ind
     END                              start_asg_sspnsn_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.end_asg_sspnsn_ind
     END                              end_asg_sspnsn_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.post_hire_asgn_start_ind
     END                              post_hire_asgn_start_ind
    ,wevt.pre_sprtn_asgn_end_ind
--    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
--                                          wevt.time_day_evt_fk)
--          THEN 0
--          ELSE wevt.prsntyp_change_ind
--     END                              prsntyp_change_ind
    ,to_number(null)                 prsntyp_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 1
          ELSE 0
     END                              mgrh_node_change_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.promotion_ind
     END                              promotion_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.worker_term_nxt_ind
     END                              worker_term_nxt_ind
    ,CASE WHEN wevt.time_day_evt_fk < NVL(chn.mgrs_date_start,
                                          wevt.time_day_evt_fk)
          THEN 0
          ELSE wevt.pre_sprtn_asgn_end_nxt_ind
     END                              pre_sprtn_asgn_end_nxt_ind
    ,wevt.adt_event_id                adt_event_id
    ,wevt.asg_assgnmnt_fk             adt_assignment_id
    ,wevt.time_day_evt_fk             adt_asg_effctv_start_date
    ,wevt.time_day_evt_end_fk         adt_asg_effctv_end_date
    ,wevt.adt_business_group_id       adt_business_group_id
    ,wevt.adt_perf_review_id          adt_perf_review_id
    ,to_number(null)                  adt_period_of_service_id
    ,to_number(null)                  adt_period_of_placement_id
    ,pow.band_sequence                adt_pow_band
    ,g_sysdate
    ,g_user
    ,g_user
    ,g_user
    ,g_sysdate
    FROM
     hri_cs_mngrsc_ct   chn
    ,hri_cs_mngrsc_ct   chn_prv
    ,hri_cs_pow_band_ct pow
    ,(SELECT /*+ NO_MERGE */
       hri_opl_wrkfc_evt_type.get_evtypcmb_fk
        (assignment_change_ind
        ,salary_change_ind
        ,perf_rating_change_ind
        ,perf_band_change_ind
        ,pow_band_change_ind
        ,headcount_gain_ind
        ,headcount_loss_ind
        ,fte_gain_ind
        ,fte_loss_ind
        ,grade_change_ind
        ,job_change_ind
        ,position_change_ind
        ,location_change_ind
        ,organization_change_ind
        ,supervisor_change_ind
        ,worker_hire_ind
        ,post_hire_asgn_start_ind
        ,pre_sprtn_asgn_end_ind
        ,term_voluntary_ind
        ,term_involuntary_ind
        ,worker_term_ind
        ,start_asg_sspnsn_ind
        ,end_asg_sspnsn_ind
        ,promotion_ind)               wevt_evtypcmb_fk
      ,evt.assignment_id              asg_assgnmnt_fk
      ,evt.person_id                  per_person_fk
      ,evt.supervisor_id              per_person_mgr_fk
      ,evt.supervisor_prv_id          per_person_mgr_prv_fk
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN evt.supervisor_id
            ELSE evt.supervisor_prv_id
       END                            psn_chain_mgr_fk
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN evt.effective_change_date
            ELSE evt.effective_change_date - 1
       END                            psn_chain_time_fk
      ,evt.organization_id            org_organztn_fk
      ,evt.organization_prv_id        org_organztn_prv_fk
      ,evt.job_id                     job_job_fk
      ,evt.job_prv_id                 job_job_prv_fk
      ,evt.grade_id                   grd_grade_fk
      ,evt.grade_prv_id               grd_grade_prv_fk
      ,evt.position_id                pos_position_fk
      ,evt.position_prv_id            pos_position_prv_fk
      ,evt.location_id                geo_location_fk
      ,evt.location_prv_id            geo_location_prv_fk
      ,evt.change_reason_code         asgrsn_asgrsn_fk
      ,evt.leaving_reason_code        sprn_sprtnrsn_fk
      ,evt.separation_category        scat_spcatgry_fk
      ,evt.prsntyp_sk_fk              ptyp_pertyp_fk
      ,LAG(evt.prsntyp_sk_fk, 1) OVER (PARTITION BY evt.assignment_id
                                       ORDER BY evt.effective_change_date)
                                      ptyp_pertyp_prv_fk
      ,evt.perf_band                  prfm_perfband_fk
      ,evt.perf_band_prv              prfm_perfband_prv_fk
      ,evt.pow_band_sk_fk             pow_powband_fk
      ,evt.pow_band_prv_sk_fk         pow_powband_prv_fk
      ,evt.effective_change_date      time_day_evt_fk
      ,evt.effective_change_end_date  time_day_evt_end_fk
      ,evt.pow_start_date_adj         time_day_pow_start_fk
      ,evt.anl_slry_currency          cur_currency_fk
      ,evt.anl_slry_currency_prv      cur_currency_prv_fk
      ,evt.headcount                  headcount
      ,evt.headcount_prv              headcount_prv
      ,evt.fte                        fte
      ,evt.fte_prv                    fte_prv
      ,evt.pow_days_on_event_date     pow_days_on_event_date
      ,evt.pow_months_on_event_date   pow_months_on_event_date
      ,evt.days_since_last_prmtn
      ,evt.months_since_last_prmtn
      ,evt.anl_slry                   anl_slry
      ,evt.anl_slry_prv               anl_slry_prv
      ,evt.assignment_change_ind      assignment_change_ind
      ,CASE WHEN evt.primary_flag = 'Y'
            THEN 1
            ELSE 0
       END                            primary_ind
      ,evt.headcount_gain_ind         headcount_gain_ind
      ,evt.headcount_loss_ind         headcount_loss_ind
      ,evt.fte_gain_ind               fte_gain_ind
      ,evt.fte_loss_ind               fte_loss_ind
      ,CASE WHEN evt.asg_type_code = 'C'
            THEN 1
            ELSE 0
       END                            contingent_ind
      ,CASE WHEN evt.asg_type_code = 'E'
            THEN 1
            ELSE 0
       END                            employee_ind
      ,evt.grade_change_ind           grade_change_ind
      ,evt.job_change_ind             job_change_ind
      ,evt.position_change_ind        position_change_ind
      ,evt.location_change_ind        location_change_ind
      ,evt.organization_change_ind    organization_change_ind
      ,evt.supervisor_change_ind      supervisor_change_ind
      ,evt.worker_hire_ind            worker_hire_ind
      ,evt.term_voluntary_ind         term_voluntary_ind
      ,evt.term_involuntary_ind       term_involuntary_ind
      ,evt.worker_term_ind            worker_term_ind
      ,evt.start_asg_sspnsn_ind       start_asg_sspnsn_ind
      ,evt.end_asg_sspnsn_ind         end_asg_sspnsn_ind
      ,evt.post_hire_asgn_start_ind   post_hire_asgn_start_ind
      ,evt.pre_sprtn_asgn_end_ind     pre_sprtn_asgn_end_ind
      ,to_number(null)                prsntyp_change_ind
      ,CASE WHEN evt.worker_term_ind = 0 AND
                 evt.pre_sprtn_asgn_end_ind = 0
            THEN 0
            ELSE 1
       END                            termination_ind
      ,evt.promotion_ind              promotion_ind
      ,evt.worker_term_nxt_ind        worker_term_nxt_ind
      ,evt.pre_sprtn_asgn_end_nxt_ind pre_sprtn_asgn_end_nxt_ind
      ,evt.event_id                   adt_event_id
      ,evt.business_group_id          adt_business_group_id
      ,evt.performance_review_id      adt_perf_review_id
      ,eq.erlst_evnt_effective_date   adt_event_date
      FROM
       hri_eq_wrkfc_evt       eq
      ,hri_mb_asgn_events_ct  evt
      WHERE evt.assignment_id = eq.assignment_id
      AND evt.effective_change_end_date >= eq.erlst_evnt_effective_date - 1
      AND eq.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id
      AND evt.summarization_rqd_ind = 1
     )  wevt
    WHERE wevt.pow_powband_fk = pow.pow_band_sk_pk
    AND chn.mgrs_person_fk (+) = wevt.psn_chain_mgr_fk
    AND chn.mgrs_date_start (+) <= wevt.time_day_evt_end_fk
    AND chn.mgrs_date_end (+) >= wevt.psn_chain_time_fk
    AND chn.mgrs_date_start (+) <= DECODE(wevt.termination_ind,
                                            0, wevt.time_day_evt_end_fk,
                                          wevt.psn_chain_time_fk)
    AND chn_prv.mgrs_person_fk (+) = wevt.per_person_mgr_prv_fk
    AND wevt.time_day_evt_fk - 1 BETWEEN chn_prv.mgrs_date_start (+)
                                 AND chn_prv.mgrs_date_end (+)
    AND wevt.time_day_evt_fk >= wevt.adt_event_date;

  COMMIT;

END process_base_fact_incr;


-- ----------------------------------------------------------------------------
-- Deletes rows to be refreshed in incremental mode
-- ----------------------------------------------------------------------------
PROCEDURE delete_base_fact_incr(p_start_asg_id    IN NUMBER,
                                p_end_asg_id      IN NUMBER) IS

BEGIN

  -- Delete records later than earliest event date
  DELETE FROM hri_mb_wrkfc_evt_ct  evt
  WHERE evt.rowid IN
   (SELECT /*+ ORDERED */
     evt2.rowid
    FROM
     hri_eq_wrkfc_evt       eq
    ,hri_mb_wrkfc_evt_ct    evt2
    WHERE evt2.asg_assgnmnt_fk = eq.assignment_id
    AND evt2.time_day_evt_fk >= eq.erlst_evnt_effective_date
    AND eq.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id);

  -- End date records overlapping with event date
  UPDATE hri_mb_wrkfc_evt_ct  evt
  SET evt.time_day_evt_end_fk =
    (SELECT eq.erlst_evnt_effective_date - 1
     FROM hri_eq_wrkfc_evt       eq
     WHERE evt.asg_assgnmnt_fk = eq.assignment_id)
  WHERE evt.rowid IN
   (SELECT /*+ ORDERED */
     evt2.rowid
    FROM
     hri_eq_wrkfc_evt       eq2
    ,hri_mb_wrkfc_evt_ct    evt2
    WHERE evt2.asg_assgnmnt_fk = eq2.assignment_id
    AND eq2.erlst_evnt_effective_date BETWEEN evt2.time_day_evt_fk
                                      AND evt2.time_day_evt_end_fk
    AND eq2.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id);

END delete_base_fact_incr;


-- ----------------------------------------------------------------------------
-- Processes chunk in full refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_range_full(p_start_asg_id    IN NUMBER,
                             p_end_asg_id      IN NUMBER) IS

BEGIN

  process_base_fact_full
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

  process_month_summary_full
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

END process_range_full;


-- ----------------------------------------------------------------------------
-- Removes processed rows from event queue
-- ----------------------------------------------------------------------------
PROCEDURE delete_eq_incr(p_start_asg_id    IN NUMBER,
                         p_end_asg_id      IN NUMBER) IS

BEGIN

  DELETE FROM hri_eq_wrkfc_evt
  WHERE assignment_id BETWEEN p_start_asg_id AND p_end_asg_id;

  DELETE FROM hri_eq_wrkfc_mnth
  WHERE assignment_id BETWEEN p_start_asg_id AND p_end_asg_id;

END delete_eq_incr;


-- ----------------------------------------------------------------------------
-- Processes chunk in incremental refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_range_incr(p_start_asg_id    IN NUMBER,
                             p_end_asg_id      IN NUMBER) IS

BEGIN

  delete_base_fact_incr
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

  process_base_fact_incr
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

  delete_month_summary_incr
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

  process_month_summary_incr
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

  delete_eq_incr
   (p_start_asg_id => p_start_asg_id,
    p_end_asg_id   => p_end_asg_id);

END process_range_incr;


-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure includes the logic required for processing the assignments
-- which have been included in the range. It is dynamically invoked by the
-- multithreading child process. It manages the multithreading ranges.
-- ----------------------------------------------------------------------------
PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2
                       ,retcode            OUT NOCOPY NUMBER
                       ,p_mthd_action_id   IN NUMBER
                       ,p_mthd_range_id    IN NUMBER
                       ,p_start_object_id  IN NUMBER
                       ,p_end_object_id    IN NUMBER) IS

BEGIN

-- Set the parameters
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');

-- Set sysdate parameter
  g_sysdate := sysdate;

-- Process range in corresponding refresh mode
  IF g_full_refresh = 'Y' THEN
    process_range_full
     (p_start_asg_id => p_start_object_id,
      p_end_asg_id   => p_end_object_id);
  ELSE
    process_range_incr
     (p_start_asg_id => p_start_object_id,
      p_end_asg_id   => p_end_object_id);
  END IF;

END process_range;


-- ----------------------------------------------------------------------------
-- Removes duplicates from event queue
-- ----------------------------------------------------------------------------
PROCEDURE remove_eq_duplicates IS

BEGIN

  -- Remove records in event queue that have duplicate records in event queue for
  -- an earlier refresh date
  DELETE FROM hri_eq_wrkfc_evt  eq
  WHERE EXISTS
   (SELECT null
    FROM hri_eq_wrkfc_evt  eq2
    WHERE eq2.assignment_id = eq.assignment_id
    AND (eq2.erlst_evnt_effective_date < eq.erlst_evnt_effective_date
      OR (eq2.rowid < eq.rowid AND
          eq2.erlst_evnt_effective_date = eq.erlst_evnt_effective_date)));

  -- Remove records in event queue that have duplicate records in event queue for
  -- an earlier refresh date
  DELETE FROM hri_eq_wrkfc_mnth  eq
  WHERE EXISTS
   (SELECT null
    FROM hri_eq_wrkfc_mnth  eq2
    WHERE eq2.assignment_id = eq.assignment_id
    AND (eq2.erlst_evnt_effective_date < eq.erlst_evnt_effective_date
      OR (eq2.rowid < eq.rowid AND
          eq2.erlst_evnt_effective_date = eq.erlst_evnt_effective_date)));

END remove_eq_duplicates;


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

  IF (p_mthd_action_id > -1) THEN

    -- Set parameter globals
    set_parameters
     (p_mthd_action_id  => p_mthd_action_id,
      p_mthd_stage_code => 'PRE_PROCESS');

  END IF;

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Disable WHO triggers
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_WRKFC_EVT_CT_WHO DISABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDS_WRKFC_MNTH_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out base fact table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_WRKFC_EVT_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- Empty out month summary table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MDS_WRKFC_MNTH_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- Empty out event type combination table
    hri_opl_wrkfc_evt_type.truncate_evtypcmb_table;

    -- In shared HR mode do not return a SQL statement so that the
    -- process_range and post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Drop all the indexes on the table
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_MB_WRKFC_EVT_CT',
        p_table_owner            => l_schema,
        p_index_excptn_lst       => 'HRI_MB_WRKFC_EVT_CT_U1');

      -- Drop all the indexes on the table
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_MDS_WRKFC_MNTH_CT',
        p_table_owner            => l_schema);

      -- Set the SQL statement for the entire range
      p_sqlstr :=
        'SELECT /*+ PARALLEL(asg, DEFAULT, DEFAULT) */ DISTINCT
           assignment_id object_id
         FROM hri_mb_asgn_events_ct
         ORDER BY assignment_id';

    END IF;

  ELSE

    -- Remove duplicates from event queue
    remove_eq_duplicates;

    -- Set the SQL statement for the incremental range
      p_sqlstr :=
        'SELECT
           assignment_id  object_id
         FROM hri_eq_wrkfc_mnth
         ORDER BY assignment_id';

  END IF;

END pre_process;

-- ----------------------------------------------------------------------------
-- Post process entry point
-- ----------------------------------------------------------------------------
PROCEDURE post_process(p_mthd_action_id NUMBER) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  IF (p_mthd_action_id > -1) THEN

    -- Check parameters are set
    set_parameters
     (p_mthd_action_id  => p_mthd_action_id,
      p_mthd_stage_code => 'POST_PROCESS');

    -- Log process end
    hri_bpl_conc_log.record_process_start('HRI_MB_WRKFC_EVT_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_WRKFC_EVT_CT_WHO ENABLE');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDS_WRKFC_MNTH_CT_WHO ENABLE');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MB_WRKFC_EVT_CT',
      p_table_owner            => l_schema);
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MDS_WRKFC_MNTH_CT',
      p_table_owner            => l_schema);
  END IF;

  -- Empty out absence summary event queue
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_WRKFC_EVT';
  -- EXECUTE IMMEDIATE(l_sql_stmt);

END post_process;

-- Populates table in a single thread
PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2) IS

  CURSOR chunk_csr IS
  SELECT
   chunk_no
  ,MIN(assignment_id)  start_asg_id
  ,MAX(assignment_id)  end_asg_id
  FROM
   (SELECT
     assignment_id
    ,CEIL(ROWNUM / 20)  chunk_no
    FROM
     (SELECT DISTINCT
       assignment_id
      FROM hri_mb_asgn_events_ct
      ORDER BY assignment_id
     )  tab
   )  chunks
  GROUP BY
   chunk_no;

  CURSOR chunk_csr_incr IS
  SELECT
   chunk_no
  ,MIN(assignment_id)  start_asg_id
  ,MAX(assignment_id)  end_asg_id
  FROM
   (SELECT
     assignment_id
    ,CEIL(ROWNUM / 20)  chunk_no
    FROM
     (SELECT
       assignment_id
      FROM hri_eq_wrkfc_mnth
      ORDER BY assignment_id
     )  tab
   )  chunks
  GROUP BY
   chunk_no;

  l_dummy    VARCHAR2(2000);

BEGIN

  g_full_refresh := p_full_refresh_flag;
  g_sysdate := trunc(sysdate);
  g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;
  g_refresh_start_date := g_dbi_start_date;
  g_user := fnd_global.user_id;

  pre_process(-1, l_dummy);

  IF (p_full_refresh_flag = 'Y') THEN

    FOR chunk_rec IN chunk_csr LOOP
      process_range_full(chunk_rec.start_asg_id, chunk_rec.end_asg_id);
    END LOOP;

  ELSE

    FOR chunk_rec IN chunk_csr_incr LOOP
      process_range_incr(chunk_rec.start_asg_id, chunk_rec.end_asg_id);
    END LOOP;

  END IF;

  post_process(-1);

END single_thread_process;

END hri_opl_wrkfc_events;

/
